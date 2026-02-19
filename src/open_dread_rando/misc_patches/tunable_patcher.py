from typing import Any

from mercury_engine_data_structures.formats.ini import Ini

from open_dread_rando.patcher_editor import PatcherEditor


def apply_tunable_patches(editor: PatcherEditor, tunable_patches: dict[str, dict[str, Any]]):
    config_file = editor.get_file("config.ini", Ini)

    for section, items in tunable_patches.items():
        for k, v in items.items():
            if section not in config_file.config:
                config_file.config[section] = {}
            config_file.config[section][k] = Ini.parse_option(v)
