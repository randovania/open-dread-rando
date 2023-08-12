from open_dread_rando import dread_patcher


def test_starter_preset(test_files_dir):
    configuration = test_files_dir.read_json("starter_preset_patcher.json")

    dread_patcher.validate(configuration)
