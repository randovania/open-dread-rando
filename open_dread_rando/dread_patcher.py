import json
import logging
from pathlib import Path

import jsonschema
from mercury_engine_data_structures.pkg_editor import PkgEditor

LOG = logging.getLogger("dread_patcher")


def _read_schema():
    with Path(__file__).parent.joinpath("schema.json").open() as f:
        return json.load(f)


def create_init_copy(editor: PkgEditor):
    original_init = "system/scripts/original_init.lc"
    if not editor.does_asset_exists(original_init):
        original_lc = editor.get_raw_asset("system/scripts/init.lc")
        editor.add_new_asset(
            original_init,
            original_lc,
            editor.find_pkgs("system/scripts/init.lc")
        )


def create_custom_init(inventory: dict[str, int], starting_location: dict):
    return """
    Game.ImportLibrary("system/scripts/original_init.lua")

    Init.tNewGameInventory = {{ 
    {new_game_inventory}
    }}

    Game.LogWarn(0, "Inventory:")
    for k, v in pairs(Init.tNewGameInventory) do
        Game.LogWarn(0, tostring(k) .. " = " .. tostring(v))
    end

    function Game.StartPrologue(arg1, arg2, arg3, arg4, arg4)
        Game.LogWarn(0, string.format("Will start Game - %s / %s / %s / %s", tostring(arg1), tostring(arg2), tostring(arg3), tostring(arg4)))
        Game.LoadScenario("c10_samus", "{starting_level}", "{starting_actor}", "", 1)
    end

    Game.LogWarn(0, "Finished modded system/init.lc")

    """.format(
        new_game_inventory="\n".join(
            "{} = {},".format(key, value)
            for key, value in inventory.items()
        ),
        starting_level=starting_location["level"],
        starting_actor=starting_location["actor"],
    )


def patch(input_path: Path, output_path: Path, configuration: dict):
    LOG.info("Will patch files at %s", input_path)

    jsonschema.validate(instance=configuration, schema=_read_schema())

    out_romfs = output_path.joinpath("romfs")
    editor = PkgEditor(input_path)

    create_init_copy(editor)
    custom_init = create_custom_init(configuration["starting_items"], configuration["starting_location"])
    editor.replace_asset("system/scripts/init.lc", custom_init.encode("ascii"))
    editor.save_modified_pkgs(out_romfs)
