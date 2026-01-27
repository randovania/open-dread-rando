from pathlib import Path

import pytest

from open_dread_rando import dread_patcher

configuration_jsons = [x for x in Path(__file__).parent.joinpath("test_files", "patcher_files").glob("*.json")]

@pytest.mark.parametrize("configuration_path", configuration_jsons)
def test_export(dread_path, tmp_path, test_files_dir, configuration_path):
    output_path = tmp_path.joinpath("out")
    configuration = test_files_dir.read_json(configuration_path)

    dread_patcher.patch_extracted(
        input_path=dread_path,
        output_path=output_path,
        configuration=configuration,
    )
    assert len(list(output_path.rglob("*.lc"))) == 34

    exefs_path = output_path.joinpath("DreadRandovania", "exefs")

    exefs_files = sorted(
        f.relative_to(output_path).as_posix()
        for f in exefs_path.iterdir() if f.name != ".gitignore"
    )
    assert exefs_files == [
        "DreadRandovania/exefs/49161D9CCBC15DF944D0B6278A3C446C006B0BE8.ips",
        "DreadRandovania/exefs/646761F643AFEBB379EDD5E6A5151AF2CEF93DC1.ips",
        "DreadRandovania/exefs/main.npdm",
        "DreadRandovania/exefs/subsdk9",
    ]
