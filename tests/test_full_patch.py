from open_dread_rando import dread_patcher


def test_export(dread_path, tmp_path, test_files_dir):
    output_path = tmp_path.joinpath("out")
    configuration = test_files_dir.read_json("starter_preset_patcher.json")

    dread_patcher.patch_extracted(
        input_path=dread_path,
        output_path=output_path,
        configuration=configuration,
    )
    assert len(list(output_path.rglob("*.lc"))) == 33

