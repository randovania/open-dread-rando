from unittest.mock import MagicMock

from open_dread_rando import dread_patcher


def test_create_init_copy_exists():
    editor = MagicMock()
    editor.does_asset_exists.return_value = True

    # Run
    dread_patcher.create_init_copy(editor)

    # Assert
    editor.does_asset_exists.assert_called_once_with("system/scripts/original_init.lc")
    editor.add_new_asset.assert_not_called()
