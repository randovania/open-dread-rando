import copy
import dataclasses
import itertools
from enum import Enum
from typing import Any, Generic, Optional, TypeVar

from construct import Container
from mercury_engine_data_structures.formats.bmsad import Bmsad

from open_dread_rando.patcher_editor import PatcherEditor


@dataclasses.dataclass
class Color3f:
    r: float
    g: float
    b: float


class BeamInput(Enum):
    NONE = 0
    ZR = 1
    L = 2


class MissileInput(Enum):
    NONE = 0
    L = 1


class CCFunc:
    def __init__(self, raw: dict) -> None:
        self.raw = raw

    def _param(self, i: int) -> Container:
        return self.raw["params"][f"Param{i}"]

    def get_param(self, i: int) -> Any:
        return self._param(i).value

    def set_param(self, i: int, value: Any):
        self._param(i).value = value


T = TypeVar('T')
class Param(Generic[T]):
    def __init__(self, index: int) -> None:
        self.index = index

    def __get__(self, inst: CCFunc, objtype=None) -> T:
        return inst.get_param(self.index)

    def __set__(self, inst: CCFunc, value: T):
        inst.set_param(self.index, value)


class AddPrimaryGun(CCFunc):
    name = Param[str](1)
    class_name = Param[str](2)
    subactor_name = Param[str](3)
    autofire_delay = Param[float](4)
    inventory_item = Param[str](5)
    burst_fx = Param[str](6)
    chargeburst_fx = Param[str](7)
    charge_fx = Param[str](8)
    on_fire = Param[str](9)
    charge_sfx = Param[str](10)
    priority = Param[int](12)

    @property
    def input_type(self) -> BeamInput:
        return BeamInput(self.get_param(11))

    @input_type.setter
    def input_type(self, value: BeamInput):
        self.set_param(11, value.value)

    @property
    def color(self) -> Color3f:
        return Color3f(
            self.get_param(13),
            self.get_param(14),
            self.get_param(15),
        )

    @color.setter
    def color(self, value: Color3f):
        self.set_param(13, value.r)
        self.set_param(14, value.g)
        self.set_param(15, value.b)


@dataclasses.dataclass(frozen=True)
class BillBoardGroupParams:
    texture: str
    unk1: int
    unk2: int
    unk3: int
    unk4: float


class SetBillBoardGroupParams(CCFunc):
    name = Param[str](1)

    def _get_group(self, i: int) -> BillBoardGroupParams:
        i *= 5
        return BillBoardGroupParams(
            self.get_param(2 + i),
            self.get_param(3 + i),
            self.get_param(4 + i),
            self.get_param(5 + i),
            self.get_param(6 + i),
        )

    def _set_group(self, i: int, value: BillBoardGroupParams):
        i *= 5
        self.set_param(2 + i, value.texture)
        self.set_param(3 + i, value.unk1)
        self.set_param(4 + i, value.unk2)
        self.set_param(5 + i, value.unk3)
        self.set_param(6 + i, value.unk4)

    @property
    def beam(self) -> BillBoardGroupParams:
        return self._get_group(0)

    @beam.setter
    def beam(self, value: BillBoardGroupParams):
        self._set_group(0, value)

    @property
    def charge(self) -> BillBoardGroupParams:
        return self._get_group(1)

    @charge.setter
    def charge(self, value: BillBoardGroupParams):
        self._set_group(1, value)

    @property
    def boost(self) -> BillBoardGroupParams:
        return self._get_group(2)

    @boost.setter
    def boost(self, value: BillBoardGroupParams):
        self._set_group(2, value)


class SetGunChargeParams(CCFunc):
    name = Param[str](1)


@dataclasses.dataclass
class PrimaryGunFuncs:
    add_primary_gun: AddPrimaryGun
    set_billboard_group_params: Optional[SetBillBoardGroupParams]
    set_gun_charge_params: Optional[SetGunChargeParams]

    @classmethod
    def from_raw(cls,
                 add_primary_gun: dict,
                 set_billboard_group_params: Optional[dict] = None,
                 set_gun_charge_params: Optional[dict] = None
    ):
        add_primary_gun = AddPrimaryGun(add_primary_gun)
        if set_billboard_group_params is not None:
            set_billboard_group_params = SetBillBoardGroupParams(set_billboard_group_params)
        if set_gun_charge_params is not None:
            set_gun_charge_params = SetGunChargeParams(set_gun_charge_params)
        return cls(
            add_primary_gun,
            set_billboard_group_params,
            set_gun_charge_params
        )

    @property
    def as_list(self) -> list[dict]:
        ret = [self.add_primary_gun.raw]
        if self.set_billboard_group_params is not None:
            ret.append(self.set_billboard_group_params.raw)
        if self.set_gun_charge_params is not None:
            ret.append(self.set_gun_charge_params.raw)
        return ret

    @property
    def name(self) -> str:
        return self.add_primary_gun.params.name

    @name.setter
    def name(self, value: str):
        self.add_primary_gun.name = value
        if self.set_billboard_group_params is not None:
            self.set_billboard_group_params.name = value
        if self.set_gun_charge_params is not None:
            self.set_gun_charge_params.name = value



class AddSecondaryGun(CCFunc):
    pass


def select_gun(param1: str, param2: bool) -> dict:
    return {
        "name": "SelectGun",
        "unk": 1,
        "params": {
            "Param1": {
                "type": "s",
                "value": param1,
            },
            "Param2": {
                "type": "b",
                "value": param2,
            },
        },
    }


SAMUS_BMSAD_PATH = "actors/characters/samus/charclasses/samus.bmsad"

def patch_split_pickups(editor: PatcherEditor):
    samus = editor.get_file(SAMUS_BMSAD_PATH, Bmsad)

    primaries = _patch_split_beams(editor)
    print(primaries)
    secondaries = _patch_split_missiles(editor)
    selections = [
        select_gun("PowerBeam", True),
        select_gun("Missile", False),
    ]

    samus.raw.property.components["GUN"].functions = primaries + secondaries + selections


def _patch_split_beams(editor: PatcherEditor) -> list[dict]:
    samus = editor.get_file(SAMUS_BMSAD_PATH, Bmsad)
    gun_funcs = samus.raw.property.components["GUN"].functions

    power = PrimaryGunFuncs.from_raw(
        gun_funcs[0],
        gun_funcs[1],
        gun_funcs[2],
    )
    wide = PrimaryGunFuncs.from_raw(
        gun_funcs[3],
        gun_funcs[4],
        gun_funcs[5],
    )
    plasma = PrimaryGunFuncs.from_raw(
        gun_funcs[6],
        gun_funcs[7],
        gun_funcs[8],
    )
    wave = PrimaryGunFuncs.from_raw(
        gun_funcs[9],
        gun_funcs[10],
        gun_funcs[11],
    )
    hyper = PrimaryGunFuncs.from_raw(
        gun_funcs[12],
        gun_funcs[13],
    )
    grapple = PrimaryGunFuncs.from_raw(
        gun_funcs[14],
    )
    spbgun = PrimaryGunFuncs.from_raw(
        gun_funcs[15],
    )

    power.add_primary_gun.inventory_item = "ITEM_WEAPON_POWER_BEAM"
    power.add_primary_gun.priority = 0

    solo_wide = copy.deepcopy(wide)
    solo_wide.name = "SoloWideBeam"
    solo_wide.add_primary_gun.inventory_item = "ITEM_WEAPON_SOLO_WIDE_BEAM"
    solo_wide.add_primary_gun.priority = 1

    solo_plasma = copy.deepcopy(plasma)
    solo_plasma.name = "SoloPlasmaBeam"

    solo_plasma.add_primary_gun.inventory_item = "ITEM_WEAPON_SOLO_PLASMA_BEAM"
    solo_plasma.add_primary_gun.priority = 2
    solo_plasma.add_primary_gun.on_fire = "OnPowerBeamFire"
    solo_plasma.add_primary_gun.charge_sfx = "weapons/chargedloop_beam.wav"

    solo_plasma.set_billboard_group_params.beam = power.set_billboard_group_params.beam
    solo_plasma.set_billboard_group_params.charge = power.set_billboard_group_params.charge
    solo_plasma.set_billboard_group_params.boost = power.set_billboard_group_params.boost

    solo_wave = copy.deepcopy(wave)
    solo_wave.name = "SoloWaveBeam"
    solo_wave.add_primary_gun.inventory_item = "ITEM_WEAPON_SOLO_WAVE_BEAM"
    solo_wave.add_primary_gun.priority = 3
    solo_wave.add_primary_gun.on_fire = "OnPowerBeamFire"
    solo_wave.add_primary_gun.charge_sfx = "weapons/chargedloop_beam.wav"
    solo_wave.add_primary_gun.color = Color3f(2.0, 0.0, 70.0)
    solo_wave.set_billboard_group_params.beam = power.set_billboard_group_params.beam
    solo_wave.set_billboard_group_params.charge = power.set_billboard_group_params.charge
    solo_wave.set_billboard_group_params.boost = power.set_billboard_group_params.boost

    wide_plasma = copy.deepcopy(plasma)
    wide_plasma.name = "WidePlasmaBeam"
    wide_plasma.add_primary_gun.inventory_item = "ITEM_WEAPON_WIDE_PLASMA_BEAM"
    wide_plasma.add_primary_gun.priority = 4

    wide_wave = copy.deepcopy(wave)
    wide_wave.name = "WideWaveBeam"
    wide_wave.add_primary_gun.inventory_item = "ITEM_WEAPON_WIDE_WAVE_BEAM"
    wide_wave.add_primary_gun.priority = 5
    wide_wave.add_primary_gun.color = Color3f(2.0, 0.0, 70.0)

    plasma_wave = copy.deepcopy(wave)
    plasma_wave.name = "PlasmaWaveBeam"
    plasma_wave.add_primary_gun.inventory_item = "ITEM_WEAPON_PLASMA_WAVE_BEAM"
    plasma_wave.add_primary_gun.priority = 6
    plasma_wave.add_primary_gun.on_fire = "OnPowerBeamFire"
    plasma_wave.add_primary_gun.charge_sfx = "weapons/chargedloop_beam.wav"
    plasma_wave.set_billboard_group_params.beam = power.set_billboard_group_params.beam
    plasma_wave.set_billboard_group_params.charge = power.set_billboard_group_params.charge
    plasma_wave.set_billboard_group_params.boost = power.set_billboard_group_params.boost

    full = copy.deepcopy(wave)
    full.name = "AllBeams"
    full.add_primary_gun.inventory_item = "ITEM_WEAPON_WIDE_PLASMA_WAVE_BEAM"
    full.add_primary_gun.priority = 7

    hyper.add_primary_gun.priority = 8

    return list(itertools.chain.from_iterable(gun.as_list for gun in [
        power,
        solo_wide,
        solo_plasma,
        solo_wave,
        wide_plasma,
        wide_wave,
        plasma_wave,
        full,
        hyper,
        grapple,
        spbgun,
    ]))


def _patch_split_missiles(editor: PatcherEditor) -> list[dict]:
    samus = editor.get_file(SAMUS_BMSAD_PATH, Bmsad)
    gun = samus.raw.property.components["GUN"]

    # TODO
    return gun.functions[16:-2]
