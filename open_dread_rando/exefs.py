import shutil
from pathlib import Path

import ips

VERSIONS = {
    "1.0.0": "49161D9CCBC15DF944D0B6278A3C446C006B0BE8",
    "2.0.0": "C447858C965A1A2EBCC506649CF87AC5665180ED",
    "2.1.0": "646761F643AFEBB379EDD5E6A5151AF2CEF93DC1",
}
NOP = bytes.fromhex('1F2003D5')


class NSOPatch(ips.Patch):
    def __init__(self):
        # always use IPS32
        super().__init__(True)

    def add_record(self, offset, content, rle_size=-1):
        # NSO files have a 0x100 byte header which is not accounted
        # for in Ghidra/IDA but is accounted for in the IPS
        return super().add_record(offset + 0x100, content, rle_size)


class VersionedPatch(dict):
    def __missing__(self, key):
        return self[max(self.keys())]
    # use the highest version with a patch defined


def _patch_corpius(patch: ips.Patch, version: str, configuration: dict):
    # patches corpius to not give the phantom cloak, and not to display the
    # "Upgrading suit for Aeion compatibility" message which causes softlocks
    grant_item_none = VersionedPatch({
        "1.0.0": (0x00d94890, bytes.fromhex('A13F00D0 21D81591')),
        "2.0.0": (0x00d99be0, bytes.fromhex('01400090 21DC3391')),
        "2.1.0": (0x00da7380, bytes.fromhex('81410090 21B82091')),
    })
    stub_aeion_message = VersionedPatch({
        "1.0.0": (0x011a1f4c, NOP),
        "2.0.0": (0x011af61c, NOP),
        "2.1.0": (0x011e7f1c, NOP),
    })

    for p in [grant_item_none, stub_aeion_message]:
        offset, data = p[version]
        patch.add_record(offset, data)


def patch_exefs(exefs_patches: Path, configuration: dict):
    shutil.rmtree(exefs_patches, ignore_errors=True)
    exefs_patches.mkdir(parents=True, exist_ok=True)

    for version, exefs_hash in VERSIONS.items():
        patch = NSOPatch()
        _patch_corpius(patch, version, configuration)
        exefs_patches.joinpath(f"{exefs_hash}.ips").write_bytes(bytes(patch))


def include_depackager(exefs_path: Path):
    shutil.rmtree(exefs_path, ignore_errors=True)
    exefs_path.mkdir(parents=True, exist_ok=True)

    dread_depackager = Path(__file__).parent.joinpath("files", "dread_depackager")
    shutil.copytree(dread_depackager, exefs_path, dirs_exist_ok=True)
