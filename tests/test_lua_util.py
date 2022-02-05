from unittest.mock import MagicMock

from open_dread_rando import lua_util


def test_create_script_copy_exists():
    editor = MagicMock()
    editor.does_asset_exists.return_value = True

    # Run
    lua_util.create_script_copy(editor, "system/scripts/init")

    # Assert
    editor.does_asset_exists.assert_called_once_with("system/scripts/init_original.lc")
    editor.add_new_asset.assert_not_called()
