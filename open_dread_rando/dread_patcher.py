import json
import logging
import shutil
import typing
from pathlib import Path

from mercury_engine_data_structures.file_tree_editor import OutputFormat

from open_dread_rando import elevator, lua_util
from open_dread_rando.exefs import include_depackager, patch_exefs
from open_dread_rando.logger import LOG
from open_dread_rando.lua_editor import LuaEditor
from open_dread_rando.map_icons import MapIconEditor
from open_dread_rando.output_config import output_format_for_category, output_paths_for_compatibility
from open_dread_rando.patcher_editor import PatcherEditor
from open_dread_rando.pickup import pickup_object_for
from open_dread_rando.static_fixes import apply_static_fixes
from open_dread_rando.text_patches import apply_text_patches, patch_hints, patch_text
from open_dread_rando.validator_with_default import DefaultValidatingDraft7Validator

T = typing.TypeVar("T")


def _read_schema():
    with Path(__file__).parent.joinpath("files", "schema.json").open() as f:
        return json.load(f)


def create_custom_init(editor: PatcherEditor, configuration: dict):
    inventory: dict[str, int] = configuration["starting_items"]
    starting_location: dict = configuration["starting_location"]
    starting_text: list[list[str]] = configuration.get("starting_text", [])

    energy_per_tank = configuration.get("energy_per_tank", 100)
    energy_per_part = configuration.get("energy_per_part", energy_per_tank / 4)

    max_life = energy_per_tank - 1

    # increase starting HP if starting with etanks/parts
    if "ITEM_ENERGY_TANKS" in inventory:
        etanks = inventory.pop("ITEM_ENERGY_TANKS")
        max_life += etanks * energy_per_tank
    if "ITEM_LIFE_SHARDS" in inventory and configuration.get("immediate_energy_parts"):
        shards = inventory.pop("ITEM_LIFE_SHARDS")
        max_life += shards * energy_per_part

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

    def chunks(l, n):
        for i in range(0, len(l), n):
            yield l[i:i + n]

    textboxes = 0
    for group in starting_text:
        boxes = chunks(group, 3)
        for box in boxes:
            textboxes += 1
            box_text = "|".join(box)
            patch_text(editor, f"RANDO_STARTING_TEXT_{textboxes}", box_text)

    replacement = {
        "new_game_inventory": final_inventory,
        "starting_scenario": lua_util.wrap_string(starting_location["scenario"]),
        "starting_actor": lua_util.wrap_string(starting_location["actor"]),
        "textbox_count": textboxes,
        "energy_per_tank": energy_per_tank,
        "energy_per_part": energy_per_part,
        "immediate_energy_parts": configuration.get("immediate_energy_parts", False),
    }

    return lua_util.replace_lua_template("custom_init.lua", replacement)


def patch_pickups(editor: PatcherEditor, lua_scripts: LuaEditor, pickups_config: list[dict], configuration: dict):
    # add to the TOC
    editor.add_new_asset("actors/items/randomizer_powerup/scripts/randomizer_powerup.lc", b'', [])
    map_icon_editor = MapIconEditor(editor)

    for i, pickup in enumerate(pickups_config):
        LOG.debug("Writing pickup %d: %s", i, pickup["resources"][0]["item_id"])
        try:
            pickup_object_for(lua_scripts, pickup, i, configuration, map_icon_editor).patch(editor)
        except NotImplementedError as e:
            LOG.warning(e)


def add_custom_files(editor: PatcherEditor):
    custom_romfs = Path(__file__).parent.joinpath("files", "romfs")
    for child in custom_romfs.rglob("*"):
        if not child.is_file():
            continue
        relative = child.relative_to(custom_romfs).as_posix()
        editor.add_new_asset(str(relative), child.read_bytes(), [])


def patch(input_path: Path, output_path: Path, configuration: dict):
    LOG.info("Will patch files from %s", input_path)

    DefaultValidatingDraft7Validator(_read_schema()).validate(configuration)

    editor = PatcherEditor(input_path)
    lua_scripts = LuaEditor()

    apply_static_fixes(editor)

    # Copy custom files
    add_custom_files(editor)

    # Update init.lc
    lua_util.create_script_copy(editor, "system/scripts/init")
    editor.replace_asset(
        "system/scripts/init.lc",
        create_custom_init(editor, configuration).encode("ascii"),
    )

    # Update scenario.lc
    lua_util.replace_script(editor, "system/scripts/scenario", "custom_scenario.lua")

    # Elevators
    if "elevators" in configuration:
        elevator.patch_elevators(editor, configuration["elevators"])

    # Pickups
    patch_pickups(editor, lua_scripts, configuration["pickups"], configuration)

    # Hints
    if "hints" in configuration:
        patch_hints(editor, configuration["hints"])

    # Text patches
    if "text_patches" in configuration:
        apply_text_patches(editor, configuration["text_patches"])

    out_romfs, out_exefs, exefs_patches = output_paths_for_compatibility(
        output_path,
        configuration["mod_compatibility"],
    )
    output_format = output_format_for_category(configuration["mod_category"])

    # Exefs
    LOG.info("Creating exefs patches")
    patch_exefs(exefs_patches, configuration)

    if output_format == OutputFormat.ROMFS:
        assert out_exefs is not None
        include_depackager(out_exefs)

    LOG.info("Saving modified lua scripts")
    lua_scripts.save_modifications(editor)

    LOG.info("Flush modified assets")
    editor.flush_modified_assets()

    if configuration.get("debug_export_modified_files", False):
        editor.save_modified_saves_to(out_romfs.parent.joinpath("_debug"))

    LOG.info("Saving modified pkgs to %s", out_romfs)
    shutil.rmtree(out_romfs, ignore_errors=True)
    editor.save_modifications(out_romfs, output_format=output_format)

    LOG.info("Done")


def patch_with_status_update(input_path: Path, output_path: Path, configuration: dict,
                             status_update: typing.Callable[[float, str], None]):
    total_logs = 108

    class StatusUpdateHandler(logging.Handler):
        count = 0

        def emit(self, record: logging.LogRecord) -> None:
            message = self.format(record)

            # Ignore "Writing <...>.pkg" messages, since there's also Updating...
            if message.startswith("Writing ") and message.endswith(".pkg"):
                return

            # Encoding a bmsad is quick, skip these
            if message.endswith(".bmsad"):
                return

            # These can come up frequently and are benign
            if message.startswith("Skipping extracted file"):
                return

            self.count += 1
            status_update(self.count / total_logs, message)

    new_handler = StatusUpdateHandler()
    # new_handler.setFormatter(logging.Formatter('[%(asctime)s] [%(levelname)s] %(message)s'))
    tree_editor_log = logging.getLogger("mercury_engine_data_structures.file_tree_editor")

    try:
        tree_editor_log.setLevel(logging.DEBUG)
        tree_editor_log.handlers.insert(0, new_handler)
        tree_editor_log.propagate = False
        LOG.setLevel(logging.INFO)
        LOG.handlers.insert(0, new_handler)
        LOG.propagate = False

        patch(input_path, output_path, configuration)
        if new_handler.count < total_logs:
            status_update(1, f"Done was {new_handler.count}")

    finally:
        tree_editor_log.removeHandler(new_handler)
        tree_editor_log.propagate = True
        LOG.removeHandler(new_handler)
        LOG.propagate = True
