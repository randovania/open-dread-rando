import shutil
from pathlib import Path
from typing import NamedTuple, Tuple

import ips
import keystone

VERSIONS = {
    "1.0.0": "49161D9CCBC15DF944D0B6278A3C446C006B0BE8",
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


class AsmVersion(NamedTuple):
    offset: int
    replacements: dict[str, str]


class AsmPatch:
    assembler = keystone.Ks(keystone.KS_ARCH_ARM64, keystone.KS_MODE_LITTLE_ENDIAN)

    def __init__(self, asm_template: str, versions: dict[str, AsmVersion]) -> None:
        self.asm_template = asm_template
        self.versions = versions

    def _asm(self, version: str) -> bytes:
        return self.asm_template.format_map(self.versions[version].replacements).encode('ascii')

    def _data(self, version: str) -> bytes:
        encoding, count = self.assembler.asm(self._asm(version), self.versions[version].offset, True)
        return encoding

    def patch(self, version: str) -> Tuple[int, bytes]:
        if version not in self.versions:
            raise RuntimeError(f"Unsupported version: {version}")
        return self.versions[version].offset, self._data(version)


def _patch_corpius(patch: ips.Patch, version: str, configuration: dict):
    # patches corpius to not give the phantom cloak, and not to display the
    # "Upgrading suit for Aeion compatibility" message which causes softlocks
    grant_item_none = VersionedPatch({
        "1.0.0": (0x00d94890, bytes.fromhex('A13F00D0 21D81591')),
        "2.1.0": (0x00da7380, bytes.fromhex('81410090 21B82091')),
    })
    stub_aeion_message = VersionedPatch({
        "1.0.0": (0x011a1f4c, NOP),
        "2.1.0": (0x011e7f1c, NOP),
    })

    for p in [grant_item_none, stub_aeion_message]:
        offset, data = p[version]
        patch.add_record(offset, data)


def _add_version_sentinel(patch: ips.Patch, version: str):
    # Replace `IsInSTEAM_PC_FINAL_RETAIL` with a custom name, so lua code can know if the exefs was properly patched
    randomized_sentinel = {
        "1.0.0": (0x0158c3c2, b"HasRandomizerPatches\x00"),
        "2.1.0": (0x015d9780, b"HasRandomizerPatches\x00"),
    }

    offset, data = randomized_sentinel[version]
    patch.add_record(offset, data)


debug_input = AsmPatch(
    Path(__file__).parent.joinpath("files/exefs_patches/debug_input.s").read_text(),
    {
        "1.0.0": AsmVersion(0x010525f0, {
            "getNpadState1": "0x011f3630",
            "getNpadState2": "0x011f3640",
            "lua_pushinteger": "0x01060730",
        }),
        "2.1.0": AsmVersion(0x010943a0, {
            "getNpadState1": "0x012393d0",
            "getNpadState2": "0x012393e0",
            "lua_pushinteger": "0x010a25f0",
        }),
    }
)


def _add_debug_input(patch: ips.Patch, version: str):
    offset, data = debug_input.patch(version)
    if offset is not None:
        patch.add_record(offset, data)

def _patch_door_lock_buffer(patch: ips.Patch, version: str):
    """ Update capacities in unknown allocator to avoid doorlock crash
    changes size of buffer inside data field initializer (I think)
    size of linked-list buffer increased from 500 to 1000.
    if 0x33250c in 1.0.0 is crashing, it's likely that this is still too small.
    original instruction: MOV w2,#0x1f4
    patched instruction: MOV w2,#0x3e8
    """
    buffer_size = {
        "1.0.0": (0x00ae6f70, bytes.fromhex('027D8052')),
        "2.1.0": (0x00ae9d70, bytes.fromhex('027D8052')),
    }

    offset, data = buffer_size[version]
    patch.add_record(offset, data)

def patch_exefs(exefs_patches: Path, configuration: dict):
    exefs_patches.mkdir(parents=True, exist_ok=True)

    for version, exefs_hash in VERSIONS.items():
        patch = NSOPatch()
        _patch_corpius(patch, version, configuration)
        _add_version_sentinel(patch, version)
        _add_debug_input(patch, version)
        _patch_door_lock_buffer(patch, version)
        exefs_patches.joinpath(f"{exefs_hash}.ips").write_bytes(bytes(patch))


def include_depackager(exefs_path: Path):
    exefs_path.mkdir(parents=True, exist_ok=True)

    dread_depackager = Path(__file__).parent.joinpath("files", "dread_depackager")
    shutil.copytree(dread_depackager, exefs_path, dirs_exist_ok=True)
