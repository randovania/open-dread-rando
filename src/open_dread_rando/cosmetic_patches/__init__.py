from typing import Any

from open_dread_rando.misc_patches.tunable_patcher import apply_tunable_patches
from open_dread_rando.patcher_editor import PatcherEditor


def apply_cosmetic_patches(editor: PatcherEditor, cosmetic: dict):
    apply_tunable_patches(editor, cosmetic["config"])
