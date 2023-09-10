from __future__ import annotations

import copy
import dataclasses
import itertools
import typing
from enum import Enum
from typing import Generic, TypeVar

from mercury_engine_data_structures.formats.bmsad import ActorDefFunc, ArgAnyType, Bmsad

from open_dread_rando.patcher_editor import PatcherEditor

if typing.TYPE_CHECKING:
    from typing_extensions import Self


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


T = TypeVar('T', bound=ArgAnyType)


class CCFunc:
    def __init__(self, raw: ActorDefFunc) -> None:
        self.raw = raw

    def get_param(self, i: int) -> ArgAnyType:
        return self.raw.get_param(i)

    def set_param(self, i: int, value: ArgAnyType) -> None:
        self.raw.set_param(i, value)


class Param(Generic[T]):
    def __init__(self, index: int) -> None:
        self.index = index

    def __get__(self, inst: CCFunc, objtype: type | None = None) -> T:
        return typing.cast(T, inst.get_param(self.index))

    def __set__(self, inst: CCFunc, value: T) -> None:
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
    def input_type(self, value: BeamInput) -> None:
        self.set_param(11, value.value)

    @property
    def color(self) -> Color3f:
        return Color3f(
            typing.cast(float, self.get_param(13)),
            typing.cast(float, self.get_param(14)),
            typing.cast(float, self.get_param(15)),
        )

    @color.setter
    def color(self, value: Color3f) -> None:
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
            typing.cast(str, self.get_param(2 + i)),
            typing.cast(int, self.get_param(3 + i)),
            typing.cast(int, self.get_param(4 + i)),
            typing.cast(int, self.get_param(5 + i)),
            typing.cast(float, self.get_param(6 + i)),
        )

    def _set_group(self, i: int, value: BillBoardGroupParams) -> None:
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
    def beam(self, value: BillBoardGroupParams) -> None:
        self._set_group(0, value)

    @property
    def charge(self) -> BillBoardGroupParams:
        return self._get_group(1)

    @charge.setter
    def charge(self, value: BillBoardGroupParams) -> None:
        self._set_group(1, value)

    @property
    def boost(self) -> BillBoardGroupParams:
        return self._get_group(2)

    @boost.setter
    def boost(self, value: BillBoardGroupParams) -> None:
        self._set_group(2, value)


class SetGunChargeParams(CCFunc):
    name = Param[str](1)


@dataclasses.dataclass
class PrimaryGunFuncs:
    add_primary_gun: AddPrimaryGun
    set_billboard_group_params: SetBillBoardGroupParams | None
    set_gun_charge_params: SetGunChargeParams | None

    @classmethod
    def from_raw(cls,
                 add_primary_gun: ActorDefFunc,
                 set_billboard_group_params: ActorDefFunc | None = None,
                 set_gun_charge_params: ActorDefFunc | None = None
                 ) -> Self:

        gun = AddPrimaryGun(add_primary_gun)

        if set_billboard_group_params is not None:
            set_billboard_group = SetBillBoardGroupParams(set_billboard_group_params)
        else:
            set_billboard_group = None

        if set_gun_charge_params is not None:
            set_gun_charge = SetGunChargeParams(set_gun_charge_params)
        else:
            set_gun_charge = None

        return cls(
            gun,
            set_billboard_group,
            set_gun_charge,
        )

    @property
    def as_list(self) -> list[ActorDefFunc]:
        ret: list[ActorDefFunc] = [self.add_primary_gun.raw]
        if self.set_billboard_group_params is not None:
            ret.append(self.set_billboard_group_params.raw)
        if self.set_gun_charge_params is not None:
            ret.append(self.set_gun_charge_params.raw)
        return ret

    @property
    def name(self) -> str:
        return self.add_primary_gun.name

    @name.setter
    def name(self, value: str) -> None:
        self.add_primary_gun.name = value
        if self.set_billboard_group_params is not None:
            self.set_billboard_group_params.name = value
        if self.set_gun_charge_params is not None:
            self.set_gun_charge_params.name = value


class AddSecondaryGun(CCFunc):
    name = Param[str](1)
    class_name = Param[str](2)
    subactor_name = Param[str](3)
    fire_delay = Param[float](4)

    main_inventory_item = Param[str](5)
    ammo_inventory_item = Param[str](6)
    capacity_inventory_item = Param[str](11)

    burst_fx = Param[str](7)
    on_fire = Param[str](8)
    priority = Param[int](10)

    @property
    def input_type(self) -> MissileInput:
        return MissileInput(self.get_param(9))

    @input_type.setter
    def input_type(self, value: MissileInput) -> None:
        self.set_param(9, value.value)


def select_gun(param1: str, param2: bool) -> ActorDefFunc:
    result = ActorDefFunc.new("SelectGun")
    result.set_param(1, param1)
    result.set_param(2, param2)
    return result


SAMUS_BMSAD_PATH = "actors/characters/samus/charclasses/samus.bmsad"


# ruff: noqa: C901


def update_starting_inventory_split_pickups(inventory: dict) -> dict:
    inventory = copy.copy(inventory)

    power = "ITEM_WEAPON_POWER_BEAM" in inventory
    wide = "ITEM_WEAPON_WIDE_BEAM" in inventory
    plasma = "ITEM_WEAPON_PLASMA_BEAM" in inventory
    wave = "ITEM_WEAPON_WAVE_BEAM" in inventory

    if power:
        if wide:
            inventory["ITEM_WEAPON_SOLO_WIDE_BEAM"] = 1
        if plasma:
            inventory["ITEM_WEAPON_SOLO_PLASMA_BEAM"] = 1
        if wave:
            inventory["ITEM_WEAPON_SOLO_WAVE_BEAM"] = 1
        if wide and plasma:
            inventory["ITEM_WEAPON_WIDE_PLASMA_BEAM"] = 1
        if wide and wave:
            inventory["ITEM_WEAPON_WIDE_WAVE_BEAM"] = 1
        if plasma and wave:
            inventory["ITEM_WEAPON_PLASMA_WAVE_BEAM"] = 1
        if wide and plasma and wave:
            inventory["ITEM_WEAPON_WIDE_PLASMA_WAVE_BEAM"] = 1

    missile = "ITEM_WEAPON_MISSILE_LAUNCHER" in inventory
    supers = "ITEM_WEAPON_SUPER_MISSILE" in inventory
    ice = "ITEM_WEAPON_ICE_MISSILE" in inventory
    storm = "ITEM_MULTILOCKON" in inventory

    if missile:
        if supers:
            inventory["ITEM_WEAPON_SOLO_SUPER_MISSILE"] = 1
        if ice:
            inventory["ITEM_WEAPON_SOLO_ICE_MISSILE"] = 1
        if supers and ice:
            inventory["ITEM_WEAPON_SUPER_ICE_MISSILE"] = 1
        if storm:
            inventory["ITEM_WEAPON_STORM_MISSILE"] = 1

    return inventory


def patch_split_pickups(editor: PatcherEditor) -> None:
    samus = editor.get_file(SAMUS_BMSAD_PATH, Bmsad)

    primaries = _patch_split_beams(editor)
    secondaries = _patch_split_missiles(editor)
    selections = [
        select_gun("PowerBeam", True),
        select_gun("Missile", False),
    ]

    new_funcs: list[ActorDefFunc] = primaries + secondaries + selections
    samus.components["GUN"].functions = new_funcs

    _patch_blast_shields(editor)


def _patch_split_beams(editor: PatcherEditor) -> list[ActorDefFunc]:
    samus = editor.get_file(SAMUS_BMSAD_PATH, Bmsad)
    gun_funcs = samus.components["GUN"].functions

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
    assert power.set_billboard_group_params is not None

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

    assert solo_plasma.set_billboard_group_params is not None
    solo_plasma.set_billboard_group_params.beam = power.set_billboard_group_params.beam
    solo_plasma.set_billboard_group_params.charge = power.set_billboard_group_params.charge
    solo_plasma.set_billboard_group_params.boost = power.set_billboard_group_params.boost

    solo_wave = copy.deepcopy(wave)
    solo_wave.name = "SoloWaveBeam"
    solo_wave.add_primary_gun.inventory_item = "ITEM_WEAPON_SOLO_WAVE_BEAM"
    solo_wave.add_primary_gun.priority = 3
    solo_wave.add_primary_gun.on_fire = "OnPowerBeamFire"
    solo_wave.add_primary_gun.charge_sfx = "weapons/chargedloop_beam.wav"
    solo_wave.add_primary_gun.color = Color3f(0.8, 0.0, 70.0)
    assert solo_wave.set_billboard_group_params is not None
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
    wide_wave.add_primary_gun.color = Color3f(0.8, 0.0, 70.0)

    plasma_wave = copy.deepcopy(wave)
    plasma_wave.name = "PlasmaWaveBeam"
    plasma_wave.add_primary_gun.inventory_item = "ITEM_WEAPON_PLASMA_WAVE_BEAM"
    plasma_wave.add_primary_gun.priority = 6
    plasma_wave.add_primary_gun.on_fire = "OnPowerBeamFire"
    plasma_wave.add_primary_gun.charge_sfx = "weapons/chargedloop_beam.wav"
    assert plasma_wave.set_billboard_group_params is not None
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


def _patch_split_missiles(editor: PatcherEditor) -> list[ActorDefFunc]:
    samus = editor.get_file(SAMUS_BMSAD_PATH, Bmsad)
    gun = samus.components["GUN"]

    solo_ice_bmsad = editor.get_parsed_asset("actors/weapons/icemissile/charclasses/icemissile.bmsad",
                                             type_hint=Bmsad)
    solo_ice_bmsad.name = "soloicemissile"
    movement = solo_ice_bmsad.components["MOVEMENT"].fields
    movement.fInitialSpeed = 1250.0
    movement.fTimeInInitialSpeed = 0.2
    movement.fTimeToReachSpeed = 0.6
    editor.add_new_asset(
        "actors/weapons/soloicemissile/charclasses/soloicemissile.bmsad",
        solo_ice_bmsad,
        editor.find_pkgs("actors/weapons/icemissile/charclasses/icemissile.bmsad"),
    )

    samus.sub_actors.append("soloicemissile")

    missile = AddSecondaryGun(gun.functions[16])
    supers = AddSecondaryGun(gun.functions[17])
    ice = AddSecondaryGun(gun.functions[18])
    lockon = AddSecondaryGun(gun.functions[19])
    omega = AddSecondaryGun(gun.functions[20])

    missile.main_inventory_item = "ITEM_WEAPON_MISSILE_LAUNCHER"
    missile.priority = 0

    solo_super = copy.deepcopy(supers)
    solo_super.name = "SoloSuperMissile"
    solo_super.main_inventory_item = "ITEM_WEAPON_SOLO_SUPER_MISSILE"
    solo_super.priority = 1

    solo_ice = copy.deepcopy(ice)
    solo_ice.name = "SoloIceMissile"
    solo_ice.main_inventory_item = "ITEM_WEAPON_SOLO_ICE_MISSILE"
    solo_ice.subactor_name = "soloicemissile"
    solo_ice.fire_delay = 0.27
    solo_ice.priority = 2

    super_ice = copy.deepcopy(ice)
    super_ice.name = "SuperIceMissile"
    super_ice.main_inventory_item = "ITEM_WEAPON_SUPER_ICE_MISSILE"
    super_ice.priority = 3

    lockon.main_inventory_item = "ITEM_WEAPON_STORM_MISSILE"

    return [gun.raw for gun in [
        missile,
        solo_super,
        solo_ice,
        super_ice,
        lockon,
        omega,
    ]]


def _patch_blast_shields(editor: PatcherEditor) -> None:
    supers = editor.get_file("actors/props/doorshieldsupermissile/charclasses/doorshieldsupermissile.bmsad", Bmsad)
    super_life = supers.components["LIFE"]
    funcs = list(super_life.functions)
    funcs.pop(1)  # AddDamageSource("SUPER_MISSILE")
    funcs.pop(1)  # AddDamageSource("ICE_MISSILE")
    super_life.functions = funcs

    plasma = editor.get_file("actors/props/door_shield_plasma/charclasses/door_shield_plasma.bmsad", Bmsad)
    plasma_life = plasma.components["LIFE"]
    funcs = list(plasma_life.functions)
    funcs.pop(1)  # AddDamageSource("PLASMA_BEAM")
    plasma_life.functions = funcs
