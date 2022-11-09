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

def patch_door(editor: PatcherEditor, door: dict):
    print(f"======{door['actor']}")
    actor = editor.resolve_actor_reference(door["actor"])

    if not is_door(actor):
        raise ValueError(f"Actor at {door['actor']} is not a door.")

    door_type = door["door_type"]
    need_shield = door_type in {"wide_beam", "plasma_beam", "wave_beam", "missile", "super_missile"}

    life_comp = actor.pComponents.LIFE
    if need_shield:
        print(f"======{door_type}")
        for link_name in ["wpLeftDoorShieldEntity", "wpRightDoorShieldEntity"]:
            link = life_comp[link_name]
            print(f"=======link={link}")
            if link != '{EMPTY}':
                aShieldActor = editor.resolve_actor_reference(reference_for_link(link, door["actor"]["scenario"]))
                aShieldActor.oActorDefLink = _SHIELD_ACTOR_DEF_FOR_TYPE[door_type]

                # ensure asset is present in new scenario
                folder = "/".join(_SHIELD_ACTOR_DEF_FOR_TYPE[door_type].split("/",3)[:3])
                print(f"##########{folder}")
                for asset in editor.get_asset_names_in_folder(folder):
                    editor.ensure_present_in_scenario(door["actor"]["scenario"], asset)
                    print(f"***********{asset} in {door['actor']['scenario']}")
            """ else:
                # copy a shield actor ref over
                aShieldActor = copy.deepcopy(editor.resolve_actor_reference(_SHIELD_ACTOR_REFS[f"{link_name}_{door_type}"]))
                currentScenario = editor.get_scenario(door["actor"]["scenario"])
                currentScenario.actors_for_layer('default')[f"{link_name}_{actor.sName}"] = aShieldActor
                editor.copy_actor_groups(door["actor"]["scenario"], actor.sName, aShieldActor.sName)
                aShieldActor.vPos = actor.vPos

                # ensure asset is present in new scenario
                # str thing is slightly cursed but it splits on slashes to the third one, takes those split strings and joins them with slashes
                for asset in editor.get_asset_names_in_folder("/".join(_SHIELD_ACTOR_DEF_FOR_TYPE[door_type].split("/",3)[:3])):
                    editor.ensure_present_in_scenario(door["actor"]["scenario"], asset)
                
                # add reference to shield onto the door
                newlink = f"Root:pScenario:rEntitiesLayer:dctSublayers:default:dctActors:{aShieldActor.sName}"
                life_comp[link_name] = newlink """

        #raise NotImplementedError("Adding shields to doors is not implemented")
    else:
        for link_name in ["wpLeftDoorShieldEntity", "wpRightDoorShieldEntity"]:
            link = life_comp[link_name]
            if link != '{EMPTY}':
                editor.remove_entity(reference_for_link(link, door["actor"]["scenario"]), "mapBlockages")
                life_comp[link_name] = '{EMPTY}'

        actor.oActorDefLink = f"actordef:{_DOOR_ACTOR_DEF_FOR_TYPE[door_type]}"
        for pkg_name in editor.get_level_pkgs(door["actor"]["scenario"]):
            editor.ensure_present(pkg_name, _DOOR_ACTOR_DEF_FOR_TYPE[door_type])
