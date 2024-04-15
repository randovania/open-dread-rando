from unittest.mock import MagicMock

from open_dread_rando.misc_patches import lua_util


def test_create_script_copy_exists():
    editor = MagicMock()
    editor.does_asset_exists.return_value = True

    # Run
    lua_util.create_script_copy(editor, "system/scripts/init")

    # Assert
    editor.does_asset_exists.assert_called_once_with("system/scripts/init_original.lc")
    editor.add_new_asset.assert_not_called()


def test_template_replacement(test_files_dir):
    generated_code = lua_util.replace_lua_template("custom_powerup_template.lua", {
        "name": "RandomizerTestPowerup",
        "parent": "RandomizerPowerup",
        "resources": [
            [{ "item_id": lua_util.wrap_string("ITEM_TEST_POWERUP"), "quantity": 1 }],
        ],
    })

    expected_code = test_files_dir.joinpath("randomizer_progressive_expected.lua").read_text()

    assert generated_code == expected_code
