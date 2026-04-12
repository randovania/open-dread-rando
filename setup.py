import os
import subprocess
import sys
from pathlib import Path

from setuptools import setup
from setuptools.command.build_py import build_py


def generate_exefs_patches():
    subprocess.run(
        [
            sys.executable,
            os.fspath(Path(__file__).parent.joinpath("tools", "create_exefs_patches.py")),
            "dread",
        ],
        check=True,
    )


class BuildPyCommand(build_py):
    """
    Generate script templates code before building the package.
    """

    def run(self):
        generate_exefs_patches()
        build_py.run(self)


setup(
    cmdclass={
        "build_py": BuildPyCommand,
    },
)
