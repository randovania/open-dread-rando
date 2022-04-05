import enum
from enum import Enum
from pathlib import Path

from mercury_engine_data_structures.file_tree_editor import OutputFormat


class OutputCompatibility(Enum):
    RYUJINX = enum.auto()
    ATMOSPHERE = enum.auto()

    def paths(self, out_path: Path) -> tuple[Path, Path, Path]:
        if self == OutputCompatibility.RYUJINX:
            mod_path = out_path.joinpath("DreadRandovania")
            exefs_patches = mod_path.joinpath("exefs")
            romfs = mod_path.joinpath("romfs")
            exefs = None

        elif self == OutputCompatibility.ATMOSPHERE:
            exefs_patches = out_path.joinpath("exefs_patches", "DreadRandovania")
            mod_path = out_path.joinpath("contents", "010093801237c000")
            romfs = mod_path.joinpath("romfs")
            exefs = mod_path.joinpath("exefs")

        else:
            raise ValueError(f"Unknown value: {self}")

        return romfs, exefs, exefs_patches


def output_format_for_category(category: str) -> OutputFormat:
    if category == "pkg":
        return OutputFormat.PKG
    elif category == "romfs":
        return OutputFormat.ROMFS
    else:
        raise ValueError(f"unknown value: {category}")


def output_paths_for_compatibility(out_path: Path, compatibility: str) -> tuple[Path, Path, Path]:
    if compatibility == "ryujinx":
        compat = OutputCompatibility.RYUJINX
    elif compatibility == "atmosphere":
        compat = OutputCompatibility.ATMOSPHERE
    else:
        raise ValueError(f"unknown value: {compatibility}")
    return compat.paths(out_path)
