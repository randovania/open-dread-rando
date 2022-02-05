import json
import logging
import shutil
import typing
from pathlib import Path

import jsonschema

from open_dread_rando import elevator, lua_util
from open_dread_rando.logger import LOG
from open_dread_rando.patcher_editor import path_for_level, PatcherEditor
from open_dread_rando.pickup import _read_powerup_lua, PickupType, _powerup_script, _custom_level_scripts, \
    pickup_object_for

T = typing.TypeVar("T")


def _read_schema():
    with Path(__file__).parent.joinpath("files", "schema.json").open() as f:
        return json.load(f)


def create_custom_init(inventory: dict[str, int], starting_location: dict):
    # Game doesn't like to start if some fields are missing, like ITEM_WEAPON_POWER_BOMB_MAX
    final_inventory = {
        "ITEM_MAX_LIFE": 99,
        "ITEM_CURRENT_SPECIAL_ENERGY": 1000,
        "ITEM_MAX_SPECIAL_ENERGY": 1000,
        "ITEM_METROID_COUNT": 0,
        "ITEM_METROID_TOTAL_COUNT": 40,
        "ITEM_WEAPON_MISSILE_MAX": 0,
        "ITEM_WEAPON_POWER_BOMB_MAX": 0,
    }
    final_inventory.update(inventory)

    replacement = {
        "new_game_inventory": final_inventory,
        "starting_scenario": lua_util.wrap_string(starting_location["scenario"]),
        "starting_actor": lua_util.wrap_string(starting_location["actor"]),
    }

    return lua_util.replace_lua_template("custom_init.lua", replacement)


def powerup_lua():
    return _powerup_script or _read_powerup_lua()


def patch_pickups(editor: PatcherEditor, pickups_config: list[dict]):
    # add to the TOC
    editor.add_new_asset("actors/items/randomizer_powerup/scripts/randomizer_powerup.lc", b'', [])

    for i, pickup in enumerate(pickups_config):
        LOG.info("Writing pickup %d: %s", i, pickup["resources"][0]["item_id"])
        try:
            pickup_object_for(pickup, i).patch(editor)
        except NotImplementedError as e:
            LOG.warning(e)

    # replace with the generated script
    editor.replace_asset("actors/items/randomizer_powerup/scripts/randomizer_powerup.lc", powerup_lua())
    for scenario, script in _custom_level_scripts.items():
        editor.replace_asset(path_for_level(scenario) + ".lc", script.encode("utf-8"))


def patch(input_path: Path, output_path: Path, configuration: dict):
    LOG.info("Will patch files from %s", input_path)

    jsonschema.validate(instance=configuration, schema=_read_schema())

    out_romfs = output_path.joinpath("romfs")
    editor = PatcherEditor(input_path)

    lua_util.create_script_copy(editor, "system/scripts/init")

    editor.replace_asset(
        "system/scripts/init.lc",
        create_custom_init(
            configuration["starting_items"],
            configuration["starting_location"]
        ).encode("ascii"),
    )

    if "elevators" in configuration:
        elevator.patch_elevators(editor, configuration["elevators"])

    patch_pickups(editor, configuration["pickups"])
    editor.flush_modified_assets()

    shutil.rmtree(out_romfs, ignore_errors=True)
    editor.save_modified_pkgs(out_romfs)
    logging.info("Done")
