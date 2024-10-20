import hashlib
import json
from pathlib import Path

from open_dread_rando import dread_patcher


def _try_hash_path(path: Path) -> str:
    try:
        data = path.read_text("utf-8").encode("utf-8")
    except UnicodeError:
        data = path.read_bytes()

    return hashlib.sha256(data).hexdigest()


def _hash_everything(root: Path) -> dict[str, str]:
    return dict(sorted(
        (p.relative_to(root).as_posix(), _try_hash_path(p))
        for p in root.rglob("*.*")
    ))


def test_export(dread_path, tmp_path, test_files_dir):
    output_path = tmp_path.joinpath("out")
    configuration = test_files_dir.read_json("starter_preset_patcher.json")

    dread_patcher.patch_extracted(
        input_path=dread_path,
        output_path=output_path,
        configuration=configuration,
    )

    # Sort the replacements.json
    replacements_path = "DreadRandovania/romfs/replacements.json"
    replacements = json.loads(output_path.joinpath(replacements_path).read_text())
    replacements["replacements"] = sorted(replacements["replacements"])
    output_path.joinpath(replacements_path).write_text(json.dumps(replacements, indent=4))

    # Hash things
    output_hashes = _hash_everything(output_path)
    output_hashes["___replacements"] = output_path.joinpath(replacements_path).read_text()

    expected_hashes = "starter_preset_expected_hashes.json"

    # # # Uncomment these lines to quickly update the expected hashes file
    # test_files_dir.joinpath(expected_hashes).write_text(json.dumps(output_hashes, indent=4)); assert False

    assert output_hashes == test_files_dir.read_json(expected_hashes)

    ips = sorted(
        f.relative_to(output_path).as_posix()
        for f in output_path.joinpath("DreadRandovania", "exefs").glob("*.ips")
    )
    assert ips == [
        "DreadRandovania/exefs/49161D9CCBC15DF944D0B6278A3C446C006B0BE8.ips",
        "DreadRandovania/exefs/646761F643AFEBB379EDD5E6A5151AF2CEF93DC1.ips",
    ]
