
from __future__ import annotations

from typing import TYPE_CHECKING, Any

from mercury_engine_data_structures.formats.ini import Ini

if TYPE_CHECKING:
    from open_dread_rando.configuration import ConfigurationCosmeticPatches
    from open_dread_rando.patcher_editor import PatcherEditor


def apply_cosmetic_patches(editor: PatcherEditor, cosmetic: ConfigurationCosmeticPatches) -> None:
    edit_config(editor, cosmetic["config"])


def edit_config(editor: PatcherEditor, config_patches: dict[str, dict[str, Any]]) -> None:
    config_file = editor.get_file('config.ini', Ini)

    for section, items in config_patches.items():
        for k, v in items.items():
            config_file.config[section][k] = Ini.parse_option(v)
