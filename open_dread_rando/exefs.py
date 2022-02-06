from pathlib import Path
import shutil
import ips

from open_dread_rando.logger import LOG


VERSIONS = {
    "1.0.0": "49161D9CCBC15DF944D0B6278A3C446C006B0BE8"
}
NOP = bytes.fromhex('1F2003D5')

class NSOPatch(ips.Patch):
    def __init__(self):
        # always use IPS32
        super().__init__(True)
    
    def add_record(self, offset, content, rle_size=-1):
        # NSO files have a 0x100 byte header which is not accounted
        # for in Ghidra/IDA but is accounted for in the IPS
        return super().add_record(offset+0x100, content, rle_size)

class VersionedPatch(dict):
    def __missing__(self, key):
        return self[max(self.keys())]
    # use the highest version with a patch defined

def _patch_corpius(patch: ips.Patch, version: str, configuration: dict):
    grant_item_none = VersionedPatch({
        "1.0.0": (0x00d94890, bytes.fromhex('A13F00D0 21D81591'))
    })
    stub_aeion_message = VersionedPatch({
        "1.0.0": (0x011a1f4c, NOP)
    })

    for p in [grant_item_none, stub_aeion_message]:
        offset, data = p[version]
        patch.add_record(offset, data)

def patch_exefs(output_path: Path, configuration: dict):
    LOG.info("Patching exefs...")
    exefs = output_path.joinpath("exefs")
    shutil.rmtree(exefs, ignore_errors=True)
    exefs.mkdir()

    for version, exefs_hash in VERSIONS.items():
        patch = NSOPatch()
        _patch_corpius(patch, version, configuration)
        exefs.joinpath(f"{exefs_hash}.ips").write_bytes(bytes(patch))
