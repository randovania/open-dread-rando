import shutil
from pathlib import Path

from open_dread_rando.files import files_path


def patch_exefs(exefs_patches: Path) -> None:
    exefs_patches.mkdir(parents=True, exist_ok=True)

    provided_patches = files_path().joinpath("exefs_patches")
    shutil.copytree(provided_patches, exefs_patches, dirs_exist_ok=True)


def include_depackager(exefs_path: Path) -> None:
    exefs_path.mkdir(parents=True, exist_ok=True)

    dread_depackager = files_path().joinpath("dread_depackager")
    shutil.copytree(dread_depackager, exefs_path, dirs_exist_ok=True)
