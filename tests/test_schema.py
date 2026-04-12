from pathlib import Path

import pytest

from open_dread_rando import dread_patcher

configuration_jsons = [x for x in Path(__file__).parent.joinpath("test_files", "patcher_files").glob("*.json")]


@pytest.mark.parametrize("configuration_path", configuration_jsons)
def test_schema_validation(test_files_dir, configuration_path):
    configuration = test_files_dir.read_json(configuration_path)

    dread_patcher.validate(configuration)
