import io
from typing import Any
from open_dread_rando.patcher_editor import PatcherEditor
from mercury_engine_data_structures.formats.ini import Ini


def apply_cosmetic_patches(editor: PatcherEditor, cosmetic: dict):
    edit_config(editor, cosmetic["config"])


def edit_config(editor: PatcherEditor, config_patches: dict[str, dict[str, Any]]):
    config_file = editor.get_file('config.ini', Ini)

    for section, items in config_patches.items():
        for k, v in items.items():
            config_file.config[section][k] = Ini.parse_option(v)
