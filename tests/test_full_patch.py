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

    ips = sorted(
        f.relative_to(output_path).as_posix()
        for f in output_path.joinpath("DreadRandovania", "exefs").glob("*.ips")
    )
    assert ips == [
        "DreadRandovania/exefs/49161D9CCBC15DF944D0B6278A3C446C006B0BE8.ips",
        "DreadRandovania/exefs/646761F643AFEBB379EDD5E6A5151AF2CEF93DC1.ips",
    ]

