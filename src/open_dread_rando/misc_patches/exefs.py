import shutil
from pathlib import Path

from open_dread_rando.files import files_path


def patch_exefs(exefs_patches: Path, configuration: dict):
    exefs_patches.mkdir(parents=True, exist_ok=True)

    provided_patches = files_path().joinpath("exefs_patches")
    shutil.copytree(provided_patches, exefs_patches, dirs_exist_ok=True)
