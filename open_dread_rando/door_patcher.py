import copy

from open_dread_rando.patcher_editor import PatcherEditor

def is_door(actor):
    return "LIFE" in actor.pComponents and "CDoorLifeComponent" == actor.pComponents.LIFE["@type"]


class DoorPatcher:
    """An API to patch doors. Call patch_door() to use. """
    def __init__(self, editor: PatcherEditor) -> None:
        # get actors from reference dicts
        self.editor = editor
        self.SHIELD_ACTORS = {k: editor.resolve_actor_reference(v) for k,v in _SHIELD_ACTOR_REFS.items()}
        self.SPECIAL_DOOR_REFS = {k: editor.resolve_actor_reference(v) for k,v in _SPECIAL_DOOR_REFS.items()}

        # get shield minimap prop
        map1 = editor.get_scenario_map(_SHIELD_ACTOR_REFS["L_missile"]["scenario"])
        self.SHIELD_MINIMAP_PROP = map1.raw.Root.mapBlockages[_SHIELD_ACTOR_REFS["L_missile"]["actor"]]

        # get footstep platform minimap prop
        map2 = editor.get_scenario_map(_SPECIAL_DOOR_REFS["footstep_platform"]["scenario"])
        self.FOOTSTEP_MINIMAP_PROP = map2.raw.Root.mapProps[_SPECIAL_DOOR_REFS["footstep_platform"]["actor"]]

    def patch_door(self, door: dict):
        """
        Patches a door given a reference. 
        
        @param door: A dictionary representing a requested door patch. 
        
        door["actor"] contains a dict(scenario, layer, actor) referencing the door to be patched.
        
        door["door_type"] contains a string representing the type of door that will be replaced. 
        """
        actor = self.editor.resolve_actor_reference(door["actor"])

        if not is_door(actor):
            raise ValueError(f"Actor at {door['actor']} is not a door.")

        door_type = door["door_type"]
        need_shield = door_type in {"wide_beam", "plasma_beam", "wave_beam", "missile", "super_missile"}
        replace_door = door_type in {"phantom_cloak", "phase_shift"}

        life_comp = actor.pComponents.LIFE
        
        # change door if it's becoming a cloak or flashshift door
        if replace_door:
            actor = self.change_door(door)
            if(door_type == "phase_shift"):
                self.add_footstep_platforms(door)
        
        if need_shield:
            # change door to the correct type
            actor.oActorDefLink = f"actordef:{_DOOR_ACTOR_DEF_FOR_TYPE[door_type]}"
            # add shields
            for link_name, dir in [("wpLeftDoorShieldEntity", "L"), ("wpRightDoorShieldEntity", "R")]:
                link = life_comp[link_name]
                if link != '{EMPTY}':
                    # change the existing shield actor to the new type and update the shield prop
                    aShieldActor = self.editor.resolve_actor_reference(self.reference_for_link(link, door["actor"]["scenario"]))
                    aShieldActor.oActorDefLink = f"actordef:{_SHIELD_ACTOR_DEF_FOR_TYPE[door_type]}"
                    self.update_shield_prop(door["actor"]["scenario"], aShieldActor, dir, _MAP_ICONS_FOR_TYPE[door_type][dir])

                    # ensure asset is present in new scenario
                    folder = "/".join(_SHIELD_ACTOR_DEF_FOR_TYPE[door_type].split("/",3)[:3])
                    for asset in self.editor.get_asset_names_in_folder(folder):
                        self.editor.ensure_present_in_scenario(door["actor"]["scenario"], asset)
                else:
                    # create a new shield
                    self.create_shield(door, link_name)

        else:
            for link_name in ["wpLeftDoorShieldEntity", "wpRightDoorShieldEntity"]:
                link = life_comp[link_name]
                if link != '{EMPTY}':
                    self.editor.remove_entity(self.reference_for_link(link, door["actor"]["scenario"]), "mapBlockages")
                    life_comp[link_name] = '{EMPTY}'

            actor.oActorDefLink = f"actordef:{_DOOR_ACTOR_DEF_FOR_TYPE[door_type]}"
            for pkg_name in self.editor.get_level_pkgs(door["actor"]["scenario"]):
                self.editor.ensure_present(pkg_name, _DOOR_ACTOR_DEF_FOR_TYPE[door_type])
    
    def create_shield(self, door: dict, link_name: str):
        """
        Creates a new shield for a door that does not have one
        
        @param door: a door reference
        @param link_name: the link name of the shield
        """
        
        doorActor = self.editor.resolve_actor_reference(door["actor"])
        door_type = door["door_type"]
        life_comp = doorActor.pComponents.LIFE
        scenarioStr = door["actor"]["scenario"]

        dir = "L" if link_name == "wpLeftDoorShieldEntity" else "R"

        # copy a shield actor ref over and update minimap
        aShieldActor = self.copy_actor(door, self.SHIELD_ACTORS[f"{dir}_{door_type}"], f"{doorActor.sName}_{dir}")
        self.editor.copy_actor_groups(scenarioStr, doorActor.sName, aShieldActor.sName)
        self.update_shield_prop(scenarioStr, aShieldActor, dir, _MAP_ICONS_FOR_TYPE[door_type][dir])

        # ensure asset is present in new scenario
        for asset in self.editor.get_asset_names_in_folder("/".join(_SHIELD_ACTOR_DEF_FOR_TYPE[door_type].split("/",3)[:3])):
            self.editor.ensure_present_in_scenario(scenarioStr, asset)
        
        # add reference to shield onto the door
        newlink = f"Root:pScenario:rEntitiesLayer:dctSublayers:default:dctActors:{aShieldActor.sName}"
        life_comp[link_name] = newlink
    
    def update_shield_prop(self, scenario, actor, dir, iconId):
        """
        Updates the map blockages to show a new shield
        
        @param scenario: a string representing the scenario
        @param actor: the updated shield actor
        @param dir: the direction the shield is facing (L/R)
        @param iconId: the string of the shield's map prop
        """
        sName = actor.sName
        vPos = actor.vPos
        map = self.editor.get_scenario_map(scenario)
        blockages = map.raw.Root.mapBlockages

        # create new blockage
        newBlockage = copy.deepcopy(self.SHIELD_MINIMAP_PROP)
        newBlockage.sIconId = iconId
        newBlockage.vPos[0] = vPos[0]
        newBlockage.vPos[1] = vPos[1]
        
        # set oBox in correct position
        delta = -450 if dir == "L" else 0
        newBlockage.oBox.Min[0] = vPos[0] + 150 + delta
        newBlockage.oBox.Min[1] = vPos[1]
        newBlockage.oBox.Max[0] = vPos[0] + 300 + delta
        newBlockage.oBox.Max[1] = vPos[1] + 300
        blockages[f"{sName}_{dir}"] = newBlockage
    
    def copy_actor(self, door: dict, actor: any, sName: str, offset: tuple =(0,0,0)):
        """
        Copies an actor ref into the same scenario as the door, stored at the location of the door ref

        @param door: The original door's reference
        @param actor: The actor to be copied into door's scenario
        @param sName: The name of the copied actor
        @param offset: a tuple containing the offset coordinates, if any
        @returns: the new copied actor
        """
        doorActor = self.editor.resolve_actor_reference(door["actor"])

        newActor = copy.deepcopy(actor)
        newActor.sName = sName
        currentScenario = self.editor.get_scenario(door["actor"]["scenario"])
        currentScenario.actors_for_layer('default')[newActor.sName] = newActor
        newActor.vPos = [c + offset for c, offset in zip(doorActor.vPos, offset)]

        return newActor

    def reference_for_link(self, link: str, scenario: str) -> dict:
        split_link = link.split(":")
        if len(split_link) != 7:
            raise ValueError(f"Expected 7 components in {link}, got {len(split_link)}")

        layer = split_link[4]
        actor = split_link[6]

        return {
            "scenario": scenario,
            "layer": layer,
            "actor": actor,
        }
    
    def change_door(self, door: dict):
        """
        Changes a Door into a new door type listed in _SPECIAL_DOOR_REFS
        @param editor: the editor
        @param door: the dictionary passed to patch_door(). updates door[actor][actor] to reference new actor. 
        @returns: the new Door actor
        """
        sName = self.editor.resolve_actor_reference(door["actor"]).sName
        door_type = door["door_type"]

        # generate the new door
        newDoor = self.copy_actor(door, self.SPECIAL_DOOR_REFS[door_type], f"{sName}_new")
        self.editor.copy_actor_groups(door["actor"]["scenario"], sName, f"{sName}_new")

        # add new minimap entry
        map = self.editor.get_scenario_map(door["actor"]["scenario"])
        doors = map.raw.Root.mapDoors
        newDoorsEntry = copy.deepcopy(doors[sName])
        newDoorsEntry.sLeftIconId = _MAP_ICONS_FOR_TYPE[door_type]["L"]
        newDoorsEntry.sRightIconId = _MAP_ICONS_FOR_TYPE[door_type]["R"]
        # fix some fudgery with shutter door's oBox since it's silly and only has one
        if door_type == "phase_shift":
            self.fix_phase_shift_prop(newDoorsEntry)
        doors[f"{sName}_new"] = newDoorsEntry

        # delete old door
        self.editor.remove_entity(door["actor"], "mapDoors")

        # reference new door
        door["actor"]["actor"] = newDoor.sName

        return newDoor
    
    def fix_phase_shift_prop(self, prop):
        """sets the correct oBox values for shutter doors on minimap"""
        prop.oBoxL.Min[0] = prop.vPos[0] - 100
        prop.oBoxL.Min[1] = prop.vPos[1]
        prop.oBoxL.Max[0] = prop.vPos[0] + 100
        prop.oBoxL.Max[1] = prop.vPos[1] + 400
        prop.oBoxR.Min[0] = 3.4028234663852886e+38 # max float32, probably a NaN
        prop.oBoxR.Min[1] = 3.4028234663852886e+38
        prop.oBoxR.Max[0] = -3.4028234663852886e+38
        prop.oBoxR.Max[1] = -3.4028234663852886e+38

    def add_footstep_platforms(self, door: dict):
        """
        Add footstep platforms to the door
        @param editor: the editor
        @param door: the dictionary passed to patch_door
        """
        doorActor = self.editor.resolve_actor_reference(door["actor"])
        scenario = door["actor"]["scenario"]

        # copy both footsteps and actor groups
        footstepL = self.copy_actor(door, self.SPECIAL_DOOR_REFS["footstep_platform"], f"{doorActor.sName}_footstepL", (-300, -100, 0))
        footstepR = self.copy_actor(door, self.SPECIAL_DOOR_REFS["footstep_platform"], f"{doorActor.sName}_footstepR", (300, -100, 0))
        self.editor.copy_actor_groups(scenario, doorActor.sName, footstepL.sName)
        self.editor.copy_actor_groups(scenario, doorActor.sName, footstepR.sName)

        # link footsteps to door
        footstepL.pComponents.FOOTSTEP.wpActivableEntity = f"Root:pScenario:rEntitiesLayer:dctSublayers:default:dctActors:{doorActor.sName}"
        footstepL.pComponents.FOOTSTEP.wpPartnerFootStepPlatformEntity = f"Root:pScenario:rEntitiesLayer:dctSublayers:default:dctActors:{footstepR.sName}"
        footstepR.pComponents.FOOTSTEP.wpActivableEntity = f"Root:pScenario:rEntitiesLayer:dctSublayers:default:dctActors:{doorActor.sName}"
        footstepR.pComponents.FOOTSTEP.wpPartnerFootStepPlatformEntity = f"Root:pScenario:rEntitiesLayer:dctSublayers:default:dctActors:{footstepL.sName}"

        # add platforms to minimap
        map = self.editor.get_scenario_map(scenario)
        props = map.raw.Root.mapProps
        footstepLProp = self.new_footstep_prop(footstepL)
        footstepRProp = self.new_footstep_prop(footstepR)
        props[footstepL.sName] = footstepLProp
        props[footstepR.sName] = footstepRProp
    
    def new_footstep_prop(self, footstepActor):
        """
        Creates a new footstep mapProp to render on the minimap.
        
        @param footstepActor: the footstep actor
        @returns: the new mapProp item
        """
        prop = copy.deepcopy(self.FOOTSTEP_MINIMAP_PROP)
        prop.vPos[0] = footstepActor.vPos[0]
        prop.vPos[1] = footstepActor.vPos[1] + 100
        prop.oBox.Min[0] = prop.vPos[0] - 180
        prop.oBox.Min[1] = prop.vPos[1]
        prop.oBox.Max[0] = prop.vPos[0] + 180
        prop.oBox.Max[1] = prop.vPos[1] + 50

        return prop

        

# actordefs for each door
_DOOR_ACTOR_DEF_FOR_TYPE = {
    "frame": "actors/props/doorframe/charclasses/doorframe.bmsad",
    "power_beam": "actors/props/doorpowerpower/charclasses/doorpowerpower.bmsad",
    "charge_beam": "actors/props/doorchargecharge/charclasses/doorchargecharge.bmsad",
    "wide_beam": "actors/props/doorpowerpower/charclasses/doorpowerpower.bmsad",
    "plasma_beam": "actors/props/doorpowerpower/charclasses/doorpowerpower.bmsad",
    "wave_beam": "actors/props/doorpowerpower/charclasses/doorpowerpower.bmsad",
    "missile": "actors/props/doorpowerpower/charclasses/doorpowerpower.bmsad",
    "super_missile": "actors/props/doorpowerpower/charclasses/doorpowerpower.bmsad",
    "grapple_beam": "actors/props/doorgrapplegrapple/charclasses/doorgrapplegrapple.bmsad",
    "phantom_cloak": "actors/props/doorpresencepresence/charclasses/doorpresencepresence.bmsad",
    "phase_shift": "actors/props/doorshutter/charclasses/doorshutter.bmsad",
}

# shield actordefs
_SHIELD_ACTOR_DEF_FOR_TYPE = {
    "wide_beam": "actors/props/doorwidebeam/charclasses/doorwidebeam.bmsad",
    "plasma_beam": "actors/props/door_shield_plasma/charclasses/door_shield_plasma.bmsad",
    "wave_beam": "actors/props/doorwavebeam/charclasses/doorwavebeam.bmsad",
    "missile": "actors/props/doorshieldmissile/charclasses/doorshieldmissile.bmsad",
    "super_missile": "actors/props/doorshieldsupermissile/charclasses/doorshieldsupermissile.bmsad",
}

# references to shield actors in each direction
_SHIELD_ACTOR_REFS = {
    "L_wide_beam": {"scenario": "s030_baselab", "layer": "default", "actor": "doorwidebeam_000"},
    "R_wide_beam": {"scenario": "s030_baselab", "layer": "default", "actor": "doorwidebeam_002"},
    "L_plasma_beam": {"scenario": "s060_quarantine", "layer": "default", "actor": "door_shield_plasma_001"},
    "R_plasma_beam": {"scenario": "s060_quarantine", "layer": "default", "actor": "door_shield_plasma_005"},
    "L_wave_beam": {"scenario": "s080_shipyard", "layer": "default", "actor": "doorwavebeam_000"},
    "R_wave_beam": {"scenario": "s080_shipyard", "layer": "default", "actor": "doorwavebeam_003"},
    "L_missile": {"scenario": "s010_cave", "layer": "default", "actor": "Door003_missileShield"},
    "R_missile": {"scenario": "s020_magma", "layer": "default", "actor": "doorshieldmissile"},
    "L_super_missile": {"scenario": "s050_forest", "layer": "default", "actor": "doorshieldsupermissile_000"},
    "R_super_missile": {"scenario": "s050_forest", "layer": "default", "actor": "doorshieldsupermissile_002"}
}

# references to special doors (ok, footsteps aren't a door but they aren't a shield either, it's a gray area)
_SPECIAL_DOOR_REFS = {
    "phantom_cloak": {"scenario": "s010_cave", "layer": "default", "actor": "Door049 (PR-PR)"},
    "phase_shift": {"scenario": "s040_aqua", "layer": "default", "actor": "doorshutter_001"},
    "footstep_platform": {"scenario": "s040_aqua", "layer": "default", "actor": "footstepplatform_001"}
}

# map icon strings for [door_type][direction]
_MAP_ICONS_FOR_TYPE = {
    "frame": {"L": "DoorFrameL", "DoorR": "FrameR"},
    "power_beam": {"L": "DoorPowerL", "R": "DoorPowerR"},
    "charge_beam": {"L": "DoorChargeL", "R": "DoorChargeR"},
    "wide_beam": {"L": "DoorWideL", "R": "DoorWideR"},
    "plasma_beam": {"L": "BlockagePlasmaL", "R": "BlockagePlasmaR"},
    "wave_beam": {"L": "BlockageWaveL", "R": "BlockageWaveR"},
    "missile": {"L": "BlockageMissileL", "R": "BlockageMissileR"},
    "super_missile": {"L": "BlockageSuperMissileL", "R": "BlockageSuperMissileR"},
    "grapple_beam": {"L": "DoorGrappleL", "R": "DoorGrappleR"},
    "phantom_cloak": {"L": "DoorPresenceL", "R": "DoorPresenceR"},
    "phase_shift": {"L": "DoorShutter", "R": "", "footstep": "PropFootstepPlatform"},
}