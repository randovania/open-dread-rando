from enum import Enum
from pathlib import Path
from typing import Sequence

from construct import Container, ListContainer

from open_dread_rando.patcher_editor import PatcherEditor

# copied from existing entity, so we don't have to make a whole shield
_EXAMPLE_SHIELD = {"scenario": "s010_cave", "layer": "default", "actor": "Door003_missileShield"}


class MinimapIconData(Enum):
    """
    Enum representing minimap data. Also contains functions that return mapDoor and mapBlockage Containers.

    iconId: a non-directional icon id. 'L' or 'R' is appended for each direction.
    tuple: the offsets for the oBoxes. All values should be taken from a "left" entity:
        0: x-axis offset from vPos to the bottom-right corner
        1: x-axis offset from vPos to the top-left corner
        2: y-axis offset from vPos to the bottom-right corner
        3: y-axis offset from vPos to the top-left corner
    """
    DOOR_FRAME = ("DoorFrame", (-150, -50, 0, 300))
    DOOR_POWER = ("DoorPower", (-150, -50, 0, 300))
    DOOR_CHARGE = ("DoorCharge", (-150, -50, 0, 300))
    DOOR_GRAPPLE = ("DoorGrapple", (-150, -50, 0, 300))
    DOOR_PRESENCE = ("DoorPresence", (-150, -50, 0, 300))
    SHIELD_WIDE_BEAM = ("DoorWide", (-300, -150, 0, 300))
    SHIELD_PLASMA_BEAM = ("BlockagePlasma", (-300, -150, 0, 300))
    SHIELD_WAVE_BEAM = ("BlockageWave", (-300, -150, 0, 300))
    SHIELD_MISSILE = ("BlockageMissile", (-300, -150, 0, 300))
    SHIELD_SUPER_MISSILE = ("BlockageSuperMissile", (-300, -150, 0, 300))

    def __init__(self, icon_id: str, offsets: Sequence[float, float, float, float]):
        """
        Initializes a new MinimapIconData with the given icon id and offsets for the left-facing direction
        """
        self.icon_id = icon_id
        self.oBox_min = (offsets[0], offsets[2])
        self.oBox_max = (offsets[1], offsets[3])

    def create_map_door(self, pos: Sequence[float, float, float]) -> Container:
        """creates a mapDoor for a given element"""
        cont = Container()
        cont["vPos"] = ListContainer([pos[0], pos[1]])
        cont["oBoxL"] = Container(
            Min=ListContainer([pos[0] + self.oBox_min[0], pos[1] - self.oBox_min[1]]),
            Max=ListContainer([pos[0] + self.oBox_max[0], pos[1] + self.oBox_max[1]]))
        cont["oBoxR"] = Container(
            Min=ListContainer([pos[0] - self.oBox_max[0], pos[1] - self.oBox_min[1]]),
            Max=ListContainer([pos[0] - self.oBox_min[0], pos[1] + self.oBox_max[1]]))
        cont["sLeftIconId"] = f"{self.icon_id}L"
        cont["sRightIconId"] = f"{self.icon_id}R"
        cont["aRoomIds"] = ListContainer()

        return cont

    def create_map_blockage(self, pos: Sequence[float, float, float], dir: str) -> Container:
        """Creates a mapBlockage for a shield in a given direction"""
        cont = Container()
        cont["vPos"] = ListContainer([pos[0], pos[1]])

        # get delta, which depends on shield dir. 
        # shield L needs no adjustments so delta is zero.
        # shield R needs to be moved oBoxMin[0] + oBoxMax[0] to the right.
        delta = 0 if dir == "L" else -(self.oBox_min[0] + self.oBox_max[0])

        cont["oBox"] = Container(
            Min=ListContainer([pos[0] + self.oBox_min[0] + delta, pos[1] + self.oBox_min[1]]),
            Max=ListContainer([pos[0] + self.oBox_max[0] + delta, pos[1] + self.oBox_max[1]]))
        cont["sIconId"] = f"{self.icon_id}{dir}"
        cont["bFlipX"] = False
        cont["bFlipY"] = False

        return cont


class ActorData(Enum):
    """
    Enum containing data on actors

    actordef: the actordef for the actor
    minimapData: the MinimapIconData for this type
    """
    DOOR_FRAME = (["doorframe"], MinimapIconData.DOOR_FRAME)
    DOOR_POWER = (["doorpowerpower", "doorpowerclosed", "doorclosedpower"], MinimapIconData.DOOR_POWER)
    DOOR_CHARGE = (["doorchargecharge", "doorchargeclosed", "doorclosedcharge"], MinimapIconData.DOOR_CHARGE)
    DOOR_GRAPPLE = (["doorgrapplegrapple", "doorgrappleclosed", "doorclosedgrapple"], MinimapIconData.DOOR_GRAPPLE)
    DOOR_PRESENCE = (["doorpresencepresence", "doorframepresence", "doorpresenceframe"], MinimapIconData.DOOR_PRESENCE)
    SHIELD_WIDE_BEAM = (["doorwidebeam"], MinimapIconData.SHIELD_WIDE_BEAM)
    SHIELD_PLASMA_BEAM = (["door_shield_plasma"], MinimapIconData.SHIELD_PLASMA_BEAM)
    SHIELD_WAVE_BEAM = (["doorwavebeam"], MinimapIconData.SHIELD_WAVE_BEAM)
    SHIELD_MISSILE = (["doorshieldmissile"], MinimapIconData.SHIELD_MISSILE)
    SHIELD_SUPER_MISSILE = (["doorshieldsupermissile"], MinimapIconData.SHIELD_SUPER_MISSILE)

    def __init__(self, actordef: list[str], minimap: MinimapIconData):
        # generate actordefs
        self.actordefs = [f"actors/props/{v}/charclasses/{v}.bmsad" for v in actordef]
        self.minimapData = minimap


class DoorType(Enum):
    """
    Enum containing info on each door type

    type: the name Randovania calls the door
    door: the door's ActorData
    need_shield: whether the actor needs a shield
    shield: the shield's ActorData
    """
    FRAME = ("frame", ActorData.DOOR_FRAME)
    POWER = ("power_beam", ActorData.DOOR_POWER)
    CHARGE = ("charge_beam", ActorData.DOOR_CHARGE)
    WIDE_BEAM = ("wide_beam", ActorData.DOOR_POWER, True, ActorData.SHIELD_WIDE_BEAM)
    PLASMA_BEAM = ("plasma_beam", ActorData.DOOR_POWER, True, ActorData.SHIELD_PLASMA_BEAM)
    WAVE_BEAM = ("wave_beam", ActorData.DOOR_POWER, True, ActorData.SHIELD_WAVE_BEAM)
    MISSILE = ("missile", ActorData.DOOR_POWER, True, ActorData.SHIELD_MISSILE)
    SUPER_MISSILE = ("super_missile", ActorData.DOOR_POWER, True, ActorData.SHIELD_SUPER_MISSILE)
    GRAPPLE = ("grapple_beam", ActorData.DOOR_GRAPPLE)
    PRESENCE = ("phantom_cloak", ActorData.DOOR_PRESENCE, False, None, True, False)

    def __init__(self, rdv_door_type: str, shield_data: ActorData, need_shield: bool = False,
                 shield_actordef: ActorData = None, can_be_removed: bool = True, can_be_added: bool = True):
        self.type = rdv_door_type
        self.need_shield = need_shield
        self.door = shield_data
        self.shield = shield_actordef
        self.can_be_removed = can_be_removed
        self.can_be_added = can_be_added

    @classmethod
    def get_type(cls, type: str):
        for e in cls:
            if e.type == type:
                return e

        raise ValueError(f"{type} is not a patchable door! Please check DoorType enum for list of patchable doors.")


def is_door(actor: Container):
    return "LIFE" in actor.pComponents and "CDoorLifeComponent" == actor.pComponents.LIFE["@type"]


class DoorPatcher:
    """An API to patch doors. Call patch_door() to use. """

    def __init__(self, editor: PatcherEditor) -> None:
        # get actors from reference dicts
        self.editor = editor
        self.SHIELD = editor.resolve_actor_reference(_EXAMPLE_SHIELD)

    def door_actor_to_type(self, door: Container, scenario: str) -> DoorType:
        """
        find's a door's DoorType
        creates a list of all doortype enums, and filters them by various means until there is one remaining
        raises an exception if door is not a patchable type
        """
        # make sure it's a door
        if not is_door(door):
            raise ValueError(f"Actor {door.sName} in scenario {scenario} is not a door!")

        # filter enums by door's actorref
        door_actor_ref = door.oActorDefLink.split(':')[1]
        possible_enum_values = list()
        for type in DoorType:
            for tdef in type.door.actordefs:
                if door_actor_ref == tdef:
                    possible_enum_values.append(type)

        if len(possible_enum_values) == 1:
            return possible_enum_values[0]

        # check for shields
        shield_actor = None
        life_comp = door.pComponents.LIFE
        for link_name in ["wpLeftDoorShieldEntity", "wpRightDoorShieldEntity"]:
            if life_comp[link_name] != '{EMPTY}':
                shield_actor = self.editor.resolve_actor_reference(
                    self.editor.reference_for_link(life_comp[link_name], scenario))

        if shield_actor is not None:
            # remove non-shielded doors if shield exists
            possible_enum_values = [e for e in possible_enum_values if e.need_shield]

            # check shields
            shield_actor_ref = shield_actor.oActorDefLink.split(':')[1]
            possible_enum_values = [e for e in possible_enum_values if e.shield.actordefs[0] == shield_actor_ref]
        else:
            # remove shielded doors if shield does not exist
            possible_enum_values = [e for e in possible_enum_values if not e.need_shield]

        if len(possible_enum_values) == 1:
            return possible_enum_values[0]
        else:
            raise ValueError(f"Door {door.sName} in scenario {scenario} is not a patchable door!")

    def patch_door(self, door_ref: dict, door_type: str):
        """
        Patches a door given a reference. 
        
        @param door: A dictionary representing a requested door patch.
        """

        scenario = door_ref["scenario"]
        door_actor = self.editor.resolve_actor_reference(door_ref)

        # get the type of door we are patching to
        door_type = DoorType.get_type(door_type)
        if door_type.can_be_added is False:
            raise ValueError(f"Door type {door_type} cannot be patched in!")

        # get the type of door we are patching
        door_in_scenario_type = self.door_actor_to_type(door_actor, scenario)
        if door_in_scenario_type.can_be_removed is False:
            raise ValueError(
                f"Base game door {door_in_scenario_type.type} cannot be patched!\nRequested door: {door_ref['actor']} in {scenario}")

        self.door_to_basic(door_actor, door_in_scenario_type, scenario)
        self.power_to_door_type(door_actor, door_type, scenario)

    def door_to_basic(self, door: Container, door_type: DoorType, scenario: str):
        """
        Reverts a door to a basic (power) door based on its door_type
        """
        if door_type is DoorType.POWER:
            return

        if door_type.need_shield:
            self.remove_shields(door, scenario)

        # only needs patching if door isn't power
        if door_type.door is not ActorData.DOOR_POWER:
            self.any_door_to_power(door, scenario)

    # removes any shields if the door has them
    def remove_shields(self, door: Container, scenario: str):
        """
        Removes a door's shields. Assumes that the door has shields. 
        
        param door: a door actor
        param scenario: the scenario string
        """
        life_comp = door.pComponents.LIFE
        for link_name in ["wpLeftDoorShieldEntity", "wpRightDoorShieldEntity"]:
            link = life_comp[link_name]
            if link == '{EMPTY}':
                continue  # skip shield if not linked
            self.editor.remove_entity(self.editor.reference_for_link(link, scenario), "mapBlockages")
            life_comp[link_name] = '{EMPTY}'

    # turns the door into a power beam door
    def any_door_to_power(self, door: Container, scenario: str):
        door.oActorDefLink = f"actordef:{ActorData.DOOR_POWER.actordefs[0]}"
        self.update_minimap_for_doors(door, DoorType.POWER, scenario)

    def power_to_door_type(self, door: Container, door_type: DoorType, scenario: str):
        # set door and ensure door assets are present
        self.set_door_type(door, door_type, scenario)

        door_actor_folder = Path(door_type.door.actordefs[0]).parent.parent.as_posix()
        for asset in self.editor.get_asset_names_in_folder(door_actor_folder):
            self.editor.ensure_present_in_scenario(scenario, asset)

        # if needed, set shield and ensure shield assets are present
        if door_type.need_shield:
            life_comp = door.pComponents["LIFE"]

            shield_l = self.create_shield(scenario, door, door_type.shield, "L")
            shield_r = self.create_shield(scenario, door, door_type.shield, "R")
            life_comp[
                "wpLeftDoorShieldEntity"] = f"Root:pScenario:rEntitiesLayer:dctSublayers:default:dctActors:{shield_l.sName}"
            life_comp[
                "wpRightDoorShieldEntity"] = f"Root:pScenario:rEntitiesLayer:dctSublayers:default:dctActors:{shield_r.sName}"

            self.update_minimap_for_shield(shield_l, door_type.shield, "L", scenario)
            self.update_minimap_for_shield(shield_r, door_type.shield, "R", scenario)

            shield_actor_folder = Path(door_type.shield.actordefs[0]).parent.parent.as_posix()
            for asset in self.editor.get_asset_names_in_folder(shield_actor_folder):
                self.editor.ensure_present_in_scenario(scenario, asset)

    def set_door_type(self, door: Container, door_type: DoorType, scenario: str):
        # set actor def to two-sided actordef
        door.oActorDefLink = f"actordef:{door_type.door.actordefs[0]}"
        self.update_minimap_for_doors(door, door_type, scenario)

    def create_shield(self, scenario: str, door: Container, shield_data: ActorData, dir: str):
        # make shields
        shield = self.editor.copy_actor(scenario, door.vPos, self.SHIELD, f"{door.sName}{dir}")
        self.editor.copy_actor_groups(scenario, door.sName, shield.sName)
        shield.oActorDefLink = f"actordef:{shield_data.actordefs[0]}"
        shield.vAng[1] = shield.vAng[1] if dir == "L" else -shield.vAng[1]

        return shield

    def update_minimap_for_doors(self, door: Container, door_type: DoorType, scenario: str):
        scenario_map = self.editor.get_scenario_map(scenario)
        map_doors = scenario_map.raw.Root.mapDoors
        patched_container = door_type.door.minimapData.create_map_door(door.vPos)
        map_doors[door.sName] = patched_container

    def update_minimap_for_shield(self, shield: Container, shield_type: ActorData, dir: str, scenario: str):
        scenario_map = self.editor.get_scenario_map(scenario)
        map_blockages = scenario_map.raw.Root.mapBlockages
        patched_container = shield_type.minimapData.create_map_blockage(shield.vPos, dir)
        map_blockages[shield.sName] = patched_container
