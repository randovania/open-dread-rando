import json
import logging
from pathlib import Path

import jsonschema
from mercury_engine_data_structures.pkg_editor import PkgEditor

LOG = logging.getLogger("dread_patcher")


def _read_schema():
    with Path(__file__).parent.joinpath("schema.json").open() as f:
        return json.load(f)


def patch(input_path: Path, output_path: Path, configuration: dict):
    LOG.info("Will patch files at %s", input_path)

    jsonschema.validate(instance=configuration, schema=_read_schema())

    editor = PkgEditor(input_path)

    if not editor.does_asset_exists("system/scripts/original_init.lc"):
        original_lc = editor.get_raw_asset("system/scripts/init.lc")
        editor.replace_asset("system/scripts/original_init.lc", original_lc)

    # inventory = {
    #     "ITEM_MAX_LIFE": 99,
    #     "ITEM_MAX_SPECIAL_ENERGY": 1000,
    #     "ITEM_WEAPON_MISSILE_MAX": 15,
    #     "ITEM_WEAPON_POWER_BOMB_MAX": 0,
    #     "ITEM_METROID_COUNT": 0,
    #     "ITEM_METROID_TOTAL_COUNT": 40,
    #     "ITEM_FLOOR_SLIDE": 1,
    # }

    custom_init = """
Game.ImportLibrary("system/scripts/init.lua")

Init.tNewGameInventory = {{ 
{new_game_inventory}
}}

function Game.StartPrologue(arg1, arg2, arg3, arg4, arg4)
    Game.LoadScenario("c10_samus", "{starting_level}", "{starting_actor}", "", 1)
end
""".format(
        new_game_inventory="\n".join(
            "{} = {},".format(key, value)
            for key, value in configuration["starting_items"].items()
        ),
        starting_level=configuration["starting_location"]["level"],
        starting_actor=configuration["starting_location"]["actor"],
    )

    editor.replace_asset("system/scripts/init.lc", custom_init.encode("ascii"))
    editor.save_modified_pkgs(output_path)
