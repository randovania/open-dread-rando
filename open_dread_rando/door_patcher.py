from enum import Enum
from pathlib import Path

from construct import Container, ListContainer
from mercury_engine_data_structures.formats.bmmap import Bmmap
from open_dread_rando.patcher_editor import PatcherEditor

# copied from existing entity so we don't have to make a whole shield
_EXAMPLE_SHIELD = {"scenario": "s010_cave", "layer": "default", "actor": "Door003_missileShield"}
# this one is just copied because *something* weird kills you whenever you touch it otherwise. 
_EXAMPLE_PHANTOM_DOOR = {"scenario": "s010_cave", "layer": "default", "actor": "Door049 (PR-PR)"}

"""
Enum representing minimap data. Also contains functions that return mapDoor and mapBlockage Containers. 

iconId: a nondirectional icon id. 'L' or 'R' is appended for each direction. 
tuple: the offsets for the oBoxes. All values should be taken from a "left" entity:
    0: x-axis offset from vPos to the bottom-right corner
    1: x-axis offset from vPos to the top-left corner
    2: y-axis offset from vPos to the bottom-right corner
    3: y-axis offset from vPos to the top-left corner
"""
class MinimapIconData(Enum):
    INVALID = ("INVALID", (0, 0, 0, 0))
    DOOR_FRAME = ("DoorFrame", (-150, -50, 0, 300))
    DOOR_POWER = ("DoorPower", (-150, -50, 0, 300))
    DOOR_CHARGE = ("DoorCharge", (-150, -50, 0, 300))
    DOOR_GRAPPLE = ("DoorGrapple", (-150, -50, 0, 300))
    DOOR_PRESENCE = ("DoorPresence", (-150, -50, 0, 300))
    SHIELD_WIDE_BEAM = ("BlockageWide", (-300, -150, 0, 300))
    SHIELD_PLASMA_BEAM = ("BlockagePlasma", (-300, -150, 0, 300))
    SHIELD_WAVE_BEAM = ("BlockageWave", (-300, -150, 0, 300))
    SHIELD_MISSILE = ("BlockageMissile", (-300, -150, 0, 300))
    SHIELD_SUPER_MISSILE = ("BlockageSuperMissile", (-300, -150, 0, 300))

    def __init__(self, iconId: str, oBoxOffsets: tuple[float, float, float, float], directional: bool =True):
        """
        Initializes a new MinimapIconData with the given icon id and offsets for the right-facing direction
        """
        self.iconId = iconId
        self.directional = directional
        self.oBoxMin = (oBoxOffsets[0], oBoxOffsets[1])
        self.oBoxMax = (oBoxOffsets[2], oBoxOffsets[3])
    
    def create_mapDoor(self, vPos: ListContainer[float, float, float]) -> Container:
        """creates a mapDoor for a given element"""
        cont = Container()
        cont["vPos"] = ListContainer([vPos[0], vPos[1]])
        cont["oBoxL"] = Container()
        cont["oBoxL"]["Min"] = ListContainer([vPos[0] + self.oBoxMin[0], vPos[1] - self.oBoxMin[1]])
        cont["oBoxL"]["Max"] = ListContainer([vPos[0] + self.oBoxMax[0], vPos[1] + self.oBoxMax[1]])
        cont["oBoxR"] = Container()
        cont["oBoxR"]["Min"] = ListContainer([vPos[0] - self.oBoxMax[0], vPos[1] - self.oBoxMin[1]])
        cont["oBoxR"]["Max"] = ListContainer([vPos[0] - self.oBoxMin[0], vPos[1] + self.oBoxMax[1]])
        cont["sLeftIconId"] = f"{self.iconId}L"
        cont["sRightIconId"] = f"{self.iconId}R"
        cont["aRoomIds"] = ListContainer()
        
        return cont

    def create_mapBlockage(self, vPos: ListContainer[float, float, float], dir: str) -> Container:
        """Creates a mapBlockage for a shield in a given direction"""
        cont = Container()
        cont["vPos"] = ListContainer([vPos[0], vPos[1]])

        # get delta, which depends on shield dir. 
        # shield L needs no adjustments so delta is zero. shield R needs to be moved oBoxMin[0] + oBoxMax[0] to the right. 
        delta = 0 if dir == "L" else self.oBoxMin[0] + self.oBoxMax[0]

        cont["oBox"] = Container()
        cont["oBox"]["Min"] = ListContainer([vPos[0] + self.oBoxMin[0] + delta, vPos[1] + self.oBoxMin[1]])
        cont["oBox"]["Max"] = ListContainer([vPos[0] + self.oBoxMax[0] + delta, vPos[1] + self.oBoxMax[1]])
        cont["sIconId"] = f"{self.iconId}{dir}"
        cont["bFlipX"] = False
        cont["bFlipY"] = False

        return cont

"""
Enum containing data on actors

actordef: the actordef for the actor
minimapData: the MinimapIconData for this type
"""
class ActorData(Enum):
    INVALID = ("INVALID", MinimapIconData.INVALID)
    DOOR_FRAME = ("actors/props/doorframe/charclasses/doorframe.bmsad", MinimapIconData.DOOR_FRAME)
    DOOR_POWER = ("actors/props/doorpowerpower/charclasses/doorpowerpower.bmsad", MinimapIconData.DOOR_POWER)
    DOOR_CHARGE = ("actors/props/doorchargecharge/charclasses/doorchargecharge.bmsad", MinimapIconData.DOOR_CHARGE)
    DOOR_GRAPPLE = ("actors/props/doorgrapplegrapple/charclasses/doorgrapplegrapple.bmsad", MinimapIconData.DOOR_GRAPPLE)
    DOOR_PRESENCE = ("actors/props/doorpresencepresence/charclasses/doorpresencepresence.bmsad", MinimapIconData.DOOR_PRESENCE)
    SHIELD_WIDE_BEAM = ("actors/props/doorwidebeam/charclasses/doorwidebeam.bmsad", MinimapIconData.SHIELD_WIDE_BEAM)
    SHIELD_PLASMA_BEAM = ("actors/props/door_shield_plasma/charclasses/door_shield_plasma.bmsad", MinimapIconData.SHIELD_PLASMA_BEAM)
    SHIELD_WAVE_BEAM = ("actors/props/doorwavebeam/charclasses/doorwavebeam.bmsad", MinimapIconData.SHIELD_WAVE_BEAM)
    SHIELD_MISSILE = ("actors/props/doorshieldmissile/charclasses/doorshieldmissile.bmsad", MinimapIconData.SHIELD_MISSILE)
    SHIELD_SUPER_MISSILE = ("actors/props/doorshieldsupermissile/charclasses/doorshieldsupermissile.bmsad", MinimapIconData.SHIELD_SUPER_MISSILE)

    def __init__(self, actordef: str, minimap: MinimapIconData):
        self.actordef = actordef
        self.minimapData = minimap

"""
Enum containing info on each door type

type: the name Randovania calls the door
door: the door's ActorData
need_shield: whether the actor needs a shield
shield: the shield's ActorData
"""
class DoorType(Enum):
    INVALID = ("invalid", ActorData.INVALID)
    POWER = ("power_beam", ActorData.DOOR_POWER)
    CHARGE = ("charge_beam", ActorData.DOOR_CHARGE)
    WIDE_BEAM = ("wide_beam", ActorData.DOOR_POWER, True, ActorData.SHIELD_WIDE_BEAM)
    PLASMA_BEAM = ("plasma_beam", ActorData.DOOR_POWER, True, ActorData.SHIELD_PLASMA_BEAM)
    WAVE_BEAM = ("wave_beam", ActorData.DOOR_POWER, True, ActorData.SHIELD_WAVE_BEAM)
    MISSILE = ("missile", ActorData.DOOR_POWER, True, ActorData.SHIELD_MISSILE)
    SUPER_MISSILE = ("super_missile", ActorData.DOOR_POWER, True, ActorData.SHIELD_SUPER_MISSILE)
    GRAPPLE = ("grapple_beam", ActorData.DOOR_GRAPPLE)
    PRESENCE = ("phantom_cloak", ActorData.DOOR_PRESENCE)

    def __init__(self, rdv_door_type: str, shield_data: ActorData, need_shield: bool =False, shield_actordef: ActorData =None):
        self.type = rdv_door_type
        self.need_shield = need_shield
        self.door = shield_data
        self.shield = shield_actordef
    
    def get_type(type: str):
        for e in DoorType:
            if e.type == type:
                return e
        
        return DoorType.INVALID

_Door049 = {"scenario": "s010_cave", "layer": "default", "actor": "Door049 (PR-PR)"}
_Door008 = {"scenario": "s010_cave", "layer": "default", "actor": "Door008 (PW-PW)"}

class DoorPatcher:
    """An API to patch doors. Call patch_door() to use. """
    def __init__(self, editor: PatcherEditor) -> None:
        # get actors from reference dicts
        self.editor = editor
        self.SHIELD = editor.resolve_actor_reference(_EXAMPLE_SHIELD)
        self.PHANTOMDOOR = editor.resolve_actor_reference(_EXAMPLE_PHANTOM_DOOR)

    def door_actor_to_type(self, door: Container, scenario: str) -> DoorType:
        """
        find's a door's DoorType
        creates a list of all doortype enums, and filters them by various means until there is one remaining
        raises an exception if door is not a patchable type
        """
        # filter enums by door's actorref
        door_actor_ref = door.oActorDefLink.split(':')[1]
        possible_enum_values = list()
        for type in DoorType:
            if door_actor_ref == type.door.actordef:
                possible_enum_values.append(type)
        
        if len(possible_enum_values) == 1:
            return possible_enum_values[0]
        
        # check for shields
        shield_actor = None
        life_comp = door.pComponents.LIFE
        for link_name in ["wpLeftDoorShieldEntity", "wpRightDoorShieldEntity"]:
            if life_comp[link_name] != '{EMPTY}':
                shield_actor = self.editor.resolve_actor_reference(self.editor.reference_for_link(life_comp[link_name], scenario))
        
        if shield_actor is not None:
            # remove non shielded doors if shield exists
            possible_enum_values = list(filter(lambda e: (e.need_shield is True), possible_enum_values))

            # check shields
            shield_actor_ref = shield_actor.oActorDefLink.split(':')[1]
            possible_enum_values = list(filter(lambda e: (e.shield.actordef == shield_actor_ref), possible_enum_values))
        else:
            possible_enum_values = list(filter(lambda e: (e.need_shield is False), possible_enum_values))

        if len(possible_enum_values) == 1:
            return possible_enum_values[0]
        else:
            return DoorType.INVALID


    def patch_door(self, door: dict):
        """
        Patches a door given a reference. 
        
        @param door: A dictionary representing a requested door patch.
        """

        scenario = door["actor"]["scenario"]
        door_type = DoorType.get_type(door["door_type"])
        if door_type is DoorType.INVALID:
            raise ValueError(f"{door['door_type']} is not a valid type!")
        map = self.editor.get_scenario_map(scenario)
        doorActor = self.editor.resolve_actor_reference(door["actor"])

        actorType = self.door_actor_to_type(doorActor, scenario)
        if actorType is DoorType.INVALID:
            raise ValueError(f"Door {doorActor.sName} in scenario {scenario} is not a patchable door!")
        
        self.door_to_basic(doorActor, actorType, scenario, map)
        if door_type is DoorType.PRESENCE: # because cloak doors have garbo hitboxes and idk how to fix it
            self.power_to_presence_door(doorActor, door["actor"], scenario, map)
            return
        self.power_to_door_type(doorActor, door_type, scenario, map)

    def door_to_basic(self, door: Container, door_type: DoorType, scenario: str, map: Bmmap):
        """
        Reverts a door to a basic (power) door based on its door_type
        """
        if door_type is DoorType.POWER:
            return
        
        if door_type.need_shield:
            self.remove_shields(door, scenario)

        # only needs patching if door isn't power
        if door_type.door is not ActorData.DOOR_POWER:
            self.any_door_to_power(door, map)


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
            if link == '{EMPTY}': continue # skip shield if not linked
            self.editor.remove_entity(self.editor.reference_for_link(link, scenario), "mapBlockages")
            life_comp[link_name] = '{EMPTY}'

    # turns the door into a power beam door
    def any_door_to_power(self, door: Container, map: Bmmap):
        door.oActorDefLink = f"actordef:{ActorData.DOOR_POWER.actordef}"
        self.update_minimap_for_doors(door, DoorType.POWER, map)
    
    def power_to_door_type(self, door: Container, door_type: DoorType, scenario: str, map: Bmmap):
        # set door and ensure door assets are present
        self.set_door_type(door, door_type, map)
        print(scenario)
        door_actor_folder = str(Path(door_type.door.actordef).parent.parent.as_posix())
        for asset in self.editor.get_asset_names_in_folder(door_actor_folder):
            self.editor.ensure_present_in_scenario(scenario, asset)

        # if needed, set shield and ensure shield assets are present
        if door_type.need_shield:
            life_comp = door.pComponents["LIFE"]

            shieldL = self.create_shield(scenario, door, door_type.shield, "L")
            shieldR = self.create_shield(scenario, door, door_type.shield, "R")
            life_comp["wpLeftDoorShieldEntity"] = f"Root:pScenario:rEntitiesLayer:dctSublayers:default:dctActors:{shieldL.sName}"
            life_comp["wpRightDoorShieldEntity"] = f"Root:pScenario:rEntitiesLayer:dctSublayers:default:dctActors:{shieldR.sName}"

            self.update_minimap_for_shield(shieldL, door_type.shield, "L", map)
            self.update_minimap_for_shield(shieldR, door_type.shield, "R", map)

            shield_actor_folder = str(Path(door_type.shield.actordef).parent.parent.as_posix())
            for asset in self.editor.get_asset_names_in_folder(shield_actor_folder):
                self.editor.ensure_present_in_scenario(scenario, asset)
    
    def set_door_type(self, door: Container, door_type: DoorType, map: Bmmap):
        door.oActorDefLink = f"actordef:{door_type.door.actordef}"
        self.update_minimap_for_doors(door, door_type, map)

    def create_shield(self, scenario: str, door: Container, shield_data: ActorData, dir: str):
        # make shields
        shield = self.editor.copy_actor(scenario, door.vPos, self.SHIELD, f"{door.sName}{dir}")
        self.editor.copy_actor_groups(scenario, door.sName, shield.sName)
        shield.oActorDefLink = f"actordef:{shield_data.actordef}"
        shield.vAng[1] = shield.vAng[1] if dir == "L" else -shield.vAng[1]

        return shield
        
    def power_to_presence_door(self, door: Container, door_dict: dict, scenario: str, map: Bmmap):
        # temporary rename so we can destroy the old door safely
        sName = door.sName
        presence_door = self.editor.copy_actor(scenario, door.vPos, self.PHANTOMDOOR, f"{sName}_")
        self.editor.copy_actor_groups(scenario, sName, f"{sName}_")
        self.editor.remove_entity(door_dict, "mapDoors")
        presence_door.sName = sName
        s = self.editor.get_scenario(scenario)
        s.actors_for_layer("default")[sName] = presence_door
        s.actors_for_layer("default").pop(f"{sName}_")

        
        presence_door.sName = sName

        # fix minimap
        patchedContainer = MinimapIconData.DOOR_PRESENCE.create_mapDoor(presence_door.vPos)
        map.raw.Root.mapDoors[sName] = patchedContainer

    def update_minimap_for_doors(self, door: Container, door_type: DoorType, map: Bmmap):
        mapDoors = map.raw.Root.mapDoors
        patchedContainer = door_type.door.minimapData.create_mapDoor(door.vPos)
        mapDoors[door.sName] = patchedContainer
        print(patchedContainer)
    
    def update_minimap_for_shield(self, shield: Container, shield_type: ActorData, dir: str, map: Bmmap):
        mapBlockages = map.raw.Root.mapBlockages
        patchedContainer = shield_type.minimapData.create_mapBlockage(shield.vPos, dir)
        mapBlockages[shield.sName] = patchedContainer
    