import copy
from open_dread_rando.patcher_editor import PatcherEditor


def is_door(actor):
    return "LIFE" in actor.pComponents and "CDoorLifeComponent" == actor.pComponents.LIFE["@type"]


def reference_for_link(link: str, scenario: str) -> dict:
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

_SHIELD_ACTOR_DEF_FOR_TYPE = {
    "wide_beam": "actors/props/doorwidebeam/charclasses/doorwidebeam.bmsad",
    "plasma_beam": "actors/props/door_shield_plasma/charclasses/door_shield_plasma.bmsad",
    "wave_beam": "actors/props/doorwavebeam/charclasses/doorwavebeam.bmsad",
    "missile": "actors/props/doorshieldmissile/charclasses/doorshieldmissile.bmsad",
    "super_missile": "actors/props/doorshieldsupermissile/charclasses/doorshieldsupermissile.bmsad",
}

_SHIELD_ACTOR_REFS = {
    "wpLeftDoorShieldEntity_wide_beam": {"scenario": "s030_baselab", "layer": "default", "actor": "doorwidebeam_000"},
    "wpRightDoorShieldEntity_wide_beam": {"scenario": "s030_baselab", "layer": "default", "actor": "doorwidebeam_002"},
    "wpLeftDoorShieldEntity_plasma_beam": {"scenario": "s060_quarantine", "layer": "default", "actor": "door_shield_plasma_001"},
    "wpRightDoorShieldEntity_plasma_beam": {"scenario": "s060_quarantine", "layer": "default", "actor": "door_shield_plasma_005"},
    "wpLeftDoorShieldEntity_wave_beam": {"scenario": "s080_shipyard", "layer": "default", "actor": "doorwavebeam_000"},
    "wpRightDoorShieldEntity_wave_beam": {"scenario": "s080_shipyard", "layer": "default", "actor": "doorwavebeam_003"},
    "wpLeftDoorShieldEntity_missile": {"scenario": "s010_cave", "layer": "default", "actor": "Door003_missileShield"},
    "wpRightDoorShieldEntity_missile": {"scenario": "s020_magma", "layer": "default", "actor": "doorshieldmissile"},
    "wpLeftDoorShieldEntity_super_missile": {"scenario": "s050_forest", "layer": "default", "actor": "doorshieldsupermissile_000"},
    "wpRightDoorShieldEntity_super_missile": {"scenario": "s050_forest", "layer": "default", "actor": "doorshieldsupermissile_002"}
}

_SPECIAL_DOOR_REFS = {
    "phantom_cloak": {"scenario": "s010_cave", "layer": "default", "actor": "Door049 (PR-PR)"},
    "phase_shift": {"scenario": "s040_aqua", "layer": "default", "actor": "doorshutter_001"},
    "footstep_platform": {"scenario": "s040_aqua", "layer": "default", "actor": "footstepplatform_001"}
}

def copy_actor(editor: PatcherEditor, door: dict, actorRef: dict, sName: str, offset: tuple =(0,0,0)):
    """
    Copies an actor ref into the same scenario as the door, stored at the location of the door ref
    """
    doorActor = editor.resolve_actor_reference(door["actor"])
    scenarioStr = door["actor"]["scenario"]

    actor = copy.deepcopy(editor.resolve_actor_reference(actorRef))
    actor.sName = sName
    currentScenario = editor.get_scenario(scenarioStr)
    currentScenario.actors_for_layer('default')[actor.sName] = actor
    actor.vPos = [c + offset for c, offset in zip(doorActor.vPos, offset)]

    return actor

def change_door(editor: PatcherEditor, door: dict):
    """
    Changes a Door into a new door type listed in _SPECIAL_DOOR_REFS
    @param editor: the editor
    @param door: the dictionary passed to patch_door()
    @returns: the new Door actor
    """
    sName = editor.resolve_actor_reference(door["actor"]).sName
    door_type = door["door_type"]

    newDoor = copy_actor(editor, door, _SPECIAL_DOOR_REFS[door_type], f"{sName}_new")
    editor.copy_actor_groups(door["actor"]["scenario"], sName, f"{sName}_new")

    # delete old door
    editor.remove_entity(door["actor"], None)

    # reference new door
    door["actor"]["actor"] = newDoor.sName

    return newDoor

def add_footstep_platforms(editor: PatcherEditor, door: dict):
    """
    Add footstep platforms to the door
    @param editor: the editor
    @param door: the dictionary passed to patch_door"""
    doorActor = editor.resolve_actor_reference(door["actor"])
    scenario = door["actor"]["scenario"]

    # copy both footsteps and actor groups
    footstepL = copy_actor(editor, door, _SPECIAL_DOOR_REFS["footstep_platform"], f"{doorActor.sName}_footstepL", (-300, -100, 0))
    footstepR = copy_actor(editor, door, _SPECIAL_DOOR_REFS["footstep_platform"], f"{doorActor.sName}_footstepR", (300, -100, 0))
    editor.copy_actor_groups(scenario, doorActor.sName, footstepL.sName)
    editor.copy_actor_groups(scenario, doorActor.sName, footstepR.sName)

    # link footsteps to door
    footstepL.pComponents.FOOTSTEP.wpActivableEntity = f"Root:pScenario:rEntitiesLayer:dctSublayers:default:dctActors:{doorActor.sName}"
    footstepL.pComponents.FOOTSTEP.wpPartnerFootStepPlatformEntity = f"Root:pScenario:rEntitiesLayer:dctSublayers:default:dctActors:{footstepR.sName}"
    footstepR.pComponents.FOOTSTEP.wpActivableEntity = f"Root:pScenario:rEntitiesLayer:dctSublayers:default:dctActors:{doorActor.sName}"
    footstepR.pComponents.FOOTSTEP.wpPartnerFootStepPlatformEntity = f"Root:pScenario:rEntitiesLayer:dctSublayers:default:dctActors:{footstepL.sName}"


def create_shield(editor: PatcherEditor, door: dict, link_name: str):
    doorActor = editor.resolve_actor_reference(door["actor"])
    door_type = door["door_type"]
    life_comp = doorActor.pComponents.LIFE
    scenarioStr = door["actor"]["scenario"]

    dir = "L" if link_name == "wpLeftDoorShieldEntity" else "R"

    # copy a shield actor ref over
    aShieldActor = copy_actor(editor, door, _SHIELD_ACTOR_REFS[f"{link_name}_{door_type}"], f"{doorActor.sName}_{dir}")
    
    # copy its actor groups as well
    editor.copy_actor_groups(scenarioStr, doorActor.sName, aShieldActor.sName)

    # ensure asset is present in new scenario
    for asset in editor.get_asset_names_in_folder("/".join(_SHIELD_ACTOR_DEF_FOR_TYPE[door_type].split("/",3)[:3])):
        editor.ensure_present_in_scenario(scenarioStr, asset)
    
    # add reference to shield onto the door
    newlink = f"Root:pScenario:rEntitiesLayer:dctSublayers:default:dctActors:{aShieldActor.sName}"
    life_comp[link_name] = newlink

def patch_door(editor: PatcherEditor, door: dict):
    actor = editor.resolve_actor_reference(door["actor"])

    if not is_door(actor):
        raise ValueError(f"Actor at {door['actor']} is not a door.")

    door_type = door["door_type"]
    need_shield = door_type in {"wide_beam", "plasma_beam", "wave_beam", "missile", "super_missile"}
    replace_door = door_type in {"phantom_cloak", "phase_shift"}

    life_comp = actor.pComponents.LIFE
    
    # change door if it's becoming a cloak or flashshift door
    if replace_door:
        actor = change_door(editor, door)
        if(door_type == "phase_shift"):
            add_footstep_platforms(editor, door)
    
    if need_shield:
        # change door to the correct type
        actor.oActorDefLink = f"actordef:{_DOOR_ACTOR_DEF_FOR_TYPE[door_type]}"
        # add shields
        for link_name in ["wpLeftDoorShieldEntity", "wpRightDoorShieldEntity"]:
            link = life_comp[link_name]
            if link != '{EMPTY}':
                aShieldActor = editor.resolve_actor_reference(reference_for_link(link, door["actor"]["scenario"]))
                aShieldActor.oActorDefLink = f"actordef:{_SHIELD_ACTOR_DEF_FOR_TYPE[door_type]}"

                # ensure asset is present in new scenario
                folder = "/".join(_SHIELD_ACTOR_DEF_FOR_TYPE[door_type].split("/",3)[:3])
                for asset in editor.get_asset_names_in_folder(folder):
                    editor.ensure_present_in_scenario(door["actor"]["scenario"], asset)
            else:
                create_shield(editor, door, link_name)

    else:
        for link_name in ["wpLeftDoorShieldEntity", "wpRightDoorShieldEntity"]:
            link = life_comp[link_name]
            if link != '{EMPTY}':
                editor.remove_entity(reference_for_link(link, door["actor"]["scenario"]), "mapBlockages")
                life_comp[link_name] = '{EMPTY}'

        actor.oActorDefLink = f"actordef:{_DOOR_ACTOR_DEF_FOR_TYPE[door_type]}"
        for pkg_name in editor.get_level_pkgs(door["actor"]["scenario"]):
            editor.ensure_present(pkg_name, _DOOR_ACTOR_DEF_FOR_TYPE[door_type])
