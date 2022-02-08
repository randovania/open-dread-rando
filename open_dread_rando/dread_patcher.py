import json
import logging
import shutil
import typing
from pathlib import Path

import jsonschema

from open_dread_rando import elevator, lua_util
from open_dread_rando.exefs import patch_exefs
from open_dread_rando.logger import LOG
from open_dread_rando.lua_editor import LuaEditor
from open_dread_rando.patcher_editor import PatcherEditor
from open_dread_rando.pickup import pickup_object_for

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


def patch_pickups(editor: PatcherEditor, lua_scripts: LuaEditor, pickups_config: list[dict]):
    # add to the TOC
    editor.add_new_asset("actors/items/randomizer_powerup/scripts/randomizer_powerup.lc", b'', [])

    for i, pickup in enumerate(pickups_config):
        LOG.debug("Writing pickup %d: %s", i, pickup["resources"][0]["item_id"])
        try:
            pickup_object_for(lua_scripts, pickup, i).patch(editor)
        except NotImplementedError as e:
            LOG.warning(e)


def patch(input_path: Path, output_path: Path, configuration: dict):
    LOG.info("Will patch files from %s", input_path)

    jsonschema.validate(instance=configuration, schema=_read_schema())

    editor = PatcherEditor(input_path)
    lua_scripts = LuaEditor()

    # Update init.lc
    lua_util.create_script_copy(editor, "system/scripts/init")
    editor.replace_asset(
        "system/scripts/init.lc",
        create_custom_init(
            configuration["starting_items"],
            configuration["starting_location"]
        ).encode("ascii"),
    )

    # Update scenario.lc
    lua_util.replace_script(editor, "system/scripts/scenario", "custom_scenario.lua")

    # Elevators
    if "elevators" in configuration:
        elevator.patch_elevators(editor, configuration["elevators"])

    # Pickups
    patch_pickups(editor, lua_scripts, configuration["pickups"])

    # Exefs
    LOG.info("Creating exefs patches")
    patch_exefs(output_path, configuration)

    LOG.info("Saving modified lua scripts")
    lua_scripts.save_modifications(editor)

    LOG.info("Flush modified assets")
    editor.flush_modified_assets()

    if configuration.get("debug_export_modified_files", False):
        editor.save_modified_saves_to(output_path.joinpath("_debug"))

    out_romfs = output_path.joinpath("romfs")
    LOG.info("Saving modified pkgs to %s", out_romfs)
    shutil.rmtree(out_romfs, ignore_errors=True)
    editor.save_modified_pkgs(out_romfs)

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
