import json
from pathlib import Path

from open_dread_rando import dread_patcher


def test_starter_preset():
    test_files: Path = Path(__file__).parent.joinpath("test_files")

    with test_files.joinpath("starter_preset_patcher.json").open() as f:
        configuration = json.load(f)

    dread_patcher.validate(configuration)
