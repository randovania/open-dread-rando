from typing import Any

from mercury_engine_data_structures.formats.ini import Ini

from open_dread_rando.patcher_editor import PatcherEditor


def apply_cosmetic_patches(editor: PatcherEditor, cosmetic: dict):
    edit_config(editor, cosmetic["config"])


def edit_config(editor: PatcherEditor, config_patches: dict[str, dict[str, Any]]):
    if not config_patches:
        return

    config_file = editor.get_file('config.ini', Ini)

    for section, items in config_patches.items():
        for k, v in items.items():
            config_file.config[section][k] = Ini.parse_option(v)
