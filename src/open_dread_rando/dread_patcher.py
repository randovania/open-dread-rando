import json
import logging
import shutil
import typing
from pathlib import Path

from construct import ListContainer
from mercury_engine_data_structures.file_tree_editor import OutputFormat

from open_dread_rando.constants import FadeTimes
from open_dread_rando.cosmetic_patches import apply_cosmetic_patches
from open_dread_rando.cosmetic_patches.missile_color_patcher import generate_missile_colors
from open_dread_rando.door_locks.custom_door_types import create_all_shield_assets
from open_dread_rando.door_locks.door_patcher import DoorPatcher
from open_dread_rando.files import files_path
from open_dread_rando.logger import LOG
from open_dread_rando.misc_patches import elevator, lua_util
from open_dread_rando.misc_patches.actor_patcher import apply_actor_patches
from open_dread_rando.misc_patches.exefs import include_depackager, patch_exefs
from open_dread_rando.misc_patches.model_patcher import generate_custom_models
from open_dread_rando.misc_patches.sprite_patches import patch_sprites
from open_dread_rando.misc_patches.text_patches import apply_text_patches, patch_credits, patch_hints, patch_text
from open_dread_rando.misc_patches.tilegroup_patcher import patch_individual_tiles, patch_tilegroup
from open_dread_rando.misc_patches.tunable_patcher import apply_tunable_patches
from open_dread_rando.output_config import output_format_for_category, output_paths_for_compatibility
from open_dread_rando.patcher_editor import PatcherEditor
from open_dread_rando.pickups.lua_editor import LuaEditor
from open_dread_rando.pickups.pickup import pickup_object_for
from open_dread_rando.pickups.split_pickups import patch_split_pickups, update_starting_inventory_split_pickups
from open_dread_rando.specific_patches import game_patches
from open_dread_rando.specific_patches.environmental_damage import apply_constant_damage
from open_dread_rando.specific_patches.objective import apply_objective_patches
from open_dread_rando.specific_patches.static_fixes import apply_static_fixes
from open_dread_rando.validator_with_default import DefaultValidatingDraft7Validator

T = typing.TypeVar("T")


def _read_schema():
    with files_path().joinpath("schema.json").open() as f:
        return json.load(f)


def create_custom_init(editor: PatcherEditor, configuration: dict) -> str:
    cosmetic_options: dict = configuration["cosmetic_patches"]["lua"]["custom_init"]
    inventory: dict[str, int] = configuration["starting_items"]
    starting_location: dict = configuration["starting_location"]
    starting_text: list[list[str]] = configuration.get("starting_text", [])
    configuration_identifier: str = configuration["configuration_identifier"]
    enable_remote_lua: bool = configuration.get("enable_remote_lua", False)

    energy_per_tank = configuration["energy_per_tank"]
    energy_per_part = energy_per_tank / 4

    max_life = energy_per_tank - 1

    # increase starting HP if starting with etanks/parts
    if "ITEM_ENERGY_TANKS" in inventory:
        etanks = inventory.pop("ITEM_ENERGY_TANKS")
        max_life += etanks * energy_per_tank
    if "ITEM_LIFE_SHARDS" in inventory and inventory["ITEM_LIFE_SHARDS"] > 0:
        total_shards = inventory["ITEM_LIFE_SHARDS"]
        leftover_shards = total_shards % 4
        if configuration["immediate_energy_parts"] or leftover_shards == 0:
            max_life += total_shards * energy_per_part
            inventory.pop("ITEM_LIFE_SHARDS")
        elif total_shards > leftover_shards:
            max_life += (total_shards - leftover_shards) * energy_per_part
            inventory["ITEM_LIFE_SHARDS"] = leftover_shards

    inventory.update({
        # TODO: expose shuffling these
        "ITEM_WEAPON_POWER_BEAM": 1,
        "ITEM_WEAPON_MISSILE_LAUNCHER": 1,
    })
    inventory = update_starting_inventory_split_pickups(inventory)

    # Game doesn't like to start if some fields are missing, like ITEM_WEAPON_POWER_BOMB_MAX
    final_inventory = {
        "ITEM_MAX_LIFE": max_life,
        "ITEM_CURRENT_SPECIAL_ENERGY": 1000,
        "ITEM_MAX_SPECIAL_ENERGY": 1000,
        "ITEM_METROID_COUNT": 0,
        "ITEM_METROID_TOTAL_COUNT": 40,
        "ITEM_WEAPON_MISSILE_MAX": 0,
        "ITEM_WEAPON_POWER_BOMB_MAX": 0,
    }
    final_inventory.update(inventory)

    def chunks(array, n):
        for i in range(0, len(array), n):
            yield array[i:i + n]

    textboxes = 0
    for group in starting_text:
        boxes = chunks(group, 3)
        for box in boxes:
            textboxes += 1
            box_text = "|".join(box)
            patch_text(editor, f"RANDO_STARTING_TEXT_{textboxes}", box_text)

    layout_uuid = None
    if "layout_uuid" in configuration:
        layout_uuid = lua_util.wrap_string(configuration["layout_uuid"])

    replacement = {
        "enable_remote_lua": enable_remote_lua,
        "new_game_inventory": final_inventory,
        "starting_scenario": lua_util.wrap_string(starting_location["scenario"]),
        "starting_actor": lua_util.wrap_string(starting_location["actor"]),
        "textbox_count": textboxes,
        "energy_per_tank": energy_per_tank,
        "energy_per_part": energy_per_part,
        "immediate_energy_parts": configuration["immediate_energy_parts"],
        "default_x_released": configuration.get("game_patches", {}).get("default_x_released", False),
        "linear_damage_runs": configuration.get("linear_damage_runs"),
        "linear_dps": configuration.get("linear_dps"),
        "configuration_identifier": lua_util.wrap_string(configuration_identifier),
        "required_artifacts": configuration["objective"]["required_artifacts"],
        "enable_death_counter": cosmetic_options["enable_death_counter"],
        "enable_room_ids": False if cosmetic_options["enable_room_name_display"] == "NEVER" else True,
        "room_id_fade_time": FadeTimes.NO_FADE.value if (
            cosmetic_options["enable_room_name_display"] != "WITH_FADE"
            ) else FadeTimes.ROOM_FADE.value,
        "layout_uuid": layout_uuid,
    }

    replacement.update(configuration.get("game_patches", {}))

    return lua_util.replace_lua_template("custom_init.lua", replacement)


def create_collision_camera_table(editor: PatcherEditor, configuration: dict):
    py_dict: dict = configuration["cosmetic_patches"]["lua"]["camera_names_dict"]

    file = lua_util.replace_lua_template("cc_to_room_name.lua", { "room_dict" : py_dict}, True).encode("ascii")
    editor.add_new_asset("system/scripts/cc_to_room_name.lc", file, ["packs/system/system.pkg"])


def patch_pickups(editor: PatcherEditor, lua_scripts: LuaEditor, pickups_config: list[dict], configuration: dict):
    patch_split_pickups(editor)

    # add to the TOC
    editor.add_new_asset("actors/items/randomizer_powerup/scripts/randomizer_powerup.lc", b'', [])

    for i, pickup in enumerate(pickups_config):
        LOG.debug("Writing pickup %d: %s", i, pickup["resources"][0][0]["item_id"])
        try:
            pickup_object_for(lua_scripts, pickup, i, configuration).patch(editor)
        except NotImplementedError as e:
            LOG.warning(e)


def patch_doors(editor: PatcherEditor, doors_config: list[dict], shield_model_config: dict[str, str]):
    editor.map_icon_editor.add_all_new_door_icons()
    create_all_shield_assets(editor, shield_model_config)

    door_patcher = DoorPatcher(editor)
    for door in doors_config:
        door_patcher.patch_door(door["actor"], door["door_type"])


def patch_spawn_points(editor: PatcherEditor, spawn_config: list[dict]):
    # create custom spawn point
    _EXAMPLE_SP = {"scenario": "s010_cave", "actor": "StartPoint0"}
    base_actor = editor.resolve_actor_reference(_EXAMPLE_SP)
    for new_spawn in spawn_config:
        scenario_name = new_spawn["new_actor"]["scenario"]
        new_actor_name = new_spawn["new_actor"]["actor"]
        collision_camera_name = new_spawn["collision_camera_name"]
        new_spawn_pos = ListContainer(
            (new_spawn["location"]["x"], new_spawn["location"]["y"], new_spawn["location"]["z"]))

        scenario = editor.get_scenario(scenario_name)

        editor.copy_actor(scenario_name, new_spawn_pos, base_actor, new_actor_name)
        scenario.add_actor_to_actor_groups(collision_camera_name, new_actor_name)


def add_custom_files(editor: PatcherEditor):
    custom_romfs = files_path().joinpath("romfs")
    for child in custom_romfs.rglob("*"):
        if not child.is_file():
            continue
        relative = child.relative_to(custom_romfs).as_posix()
        logging.info("Adding custom asset %s", relative)
        editor.add_new_asset(str(relative), child.read_bytes(), [])

    lua_libraries = files_path().joinpath("lua_libraries")
    for child in lua_libraries.rglob("*"):
        if not child.is_file():
            continue
        relative = child.relative_to(lua_libraries)
        full_path = Path("system/scripts").joinpath(relative)
        if full_path.suffix == ".lua":
            full_path = full_path.with_suffix(".lc")
        editor.add_new_asset(full_path.as_posix(), child.read_bytes(), ["packs/system/system.pkg"])


def validate(configuration: dict):
    DefaultValidatingDraft7Validator(_read_schema()).validate(configuration)


def patch_extracted(input_path: Path, output_path: Path, configuration: dict):
    LOG.info("Will patch files from %s", input_path)

    validate(configuration)

    editor = PatcherEditor(input_path)
    lua_scripts = LuaEditor()

    # Copy custom files
    add_custom_files(editor)
    generate_missile_colors(editor)
    generate_custom_models(editor)

    # Apply fixes
    apply_static_fixes(editor)

    # Update init.lc
    lua_util.create_script_copy(editor, "system/scripts/init")
    editor.replace_asset(
        "system/scripts/init.lc",
        create_custom_init(editor, configuration).encode("ascii"),
    )

    # Update cc_to_room_name.lua
    create_collision_camera_table(editor, configuration)

    # Update scenario.lc
    lua_util.replace_script(editor, "system/scripts/scenario", "custom_scenario.lua")

    # Update msemenu_mainmenu
    lua_util.replace_script(editor, "gui/scripts/msemenu_mainmenu", "msemenu_mainmenu.lua")

    # Elevators
    if "elevators" in configuration:
        elevator.patch_elevators(editor, configuration["elevators"])

    # Pickups
    patch_pickups(editor, lua_scripts, configuration["pickups"], configuration)

    # Hints
    if "hints" in configuration:
        patch_hints(editor, configuration["hints"])

    # Doors
    patch_doors(editor, configuration["door_patches"], configuration["cosmetic_patches"]["shield_versions"])

    # custom spawn points
    patch_spawn_points(editor, configuration["new_spawn_points"])

    for tile_group in configuration["tile_group_patches"]:
        if "tiletype" in tile_group:
            patch_tilegroup(editor, tile_group)
        else:
            patch_individual_tiles(editor, tile_group["actor"], tile_group["tiles"])

    # Text patches
    if "text_patches" in configuration:
        apply_text_patches(editor, configuration["text_patches"])
    patch_credits(editor, configuration["spoiler_log"])

    # Objective
    apply_objective_patches(editor, configuration)

    # Cosmetic patches
    if "cosmetic_patches" in configuration:
        apply_cosmetic_patches(editor, configuration["cosmetic_patches"])

    # Tunable patches
    if "tunables" in configuration:
        apply_tunable_patches(editor, configuration["tunables"])

    # Environmental Damage
    apply_constant_damage(editor, configuration["constant_environment_damage"])

    # Specific game patches
    game_patches.apply_game_patches(editor, configuration.get("game_patches", {}))

    # Actor patches
    apply_actor_patches(editor, configuration.get("actor_patches"))

    # remote connector disconnect symbol
    patch_sprites(editor)

    out_romfs, out_exefs, exefs_patches = output_paths_for_compatibility(
        output_path,
        configuration["mod_compatibility"],
    )
    shutil.rmtree(out_romfs, ignore_errors=True)
    shutil.rmtree(out_exefs, ignore_errors=True)
    shutil.rmtree(exefs_patches, ignore_errors=True)
    output_format = output_format_for_category(configuration["mod_category"])

    # Exefs
    LOG.info("Creating exefs patches")
    patch_exefs(exefs_patches, configuration)

    if output_format == OutputFormat.ROMFS:
        include_depackager(out_exefs)

    LOG.info("Saving modified lua scripts")
    lua_scripts.save_modifications(editor)

    LOG.info("Flush modified assets")
    editor.flush_modified_assets()

    if configuration.get("debug_export_modified_files", False):
        editor.save_modified_saves_to(out_romfs.parent.joinpath("_debug"))

    LOG.info("Saving modified pkgs to %s", out_romfs)
    editor.save_modifications(out_romfs, output_format=output_format)

    LOG.info("Done")
