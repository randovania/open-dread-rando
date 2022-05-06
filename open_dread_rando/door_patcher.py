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


_ACTOR_DEF_FOR_TYPE = {
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


def patch_door(editor: PatcherEditor, door: dict):
    actor = editor.resolve_actor_reference(door["actor"])

    if not is_door(actor):
        raise ValueError(f"Actor at {door['actor']} is not a door.")

    door_type = door["door_type"]
    need_shield = door_type in {"wide_beam", "plasma_beam", "wave_beam", "missile", "super_missile"}

    life_comp = actor.pComponents.LIFE
    if need_shield:
        raise NotImplementedError("Adding shields to doors is not implemented")
    else:
        for link_name in ["wpLeftDoorShieldEntity", "wpRightDoorShieldEntity"]:
            link = life_comp[link_name]
            if link != '{EMPTY}':
                editor.remove_entity(reference_for_link(link, door["actor"]["scenario"]), "mapBlockages")
                life_comp[link_name] = '{EMPTY}'

        actor.oActorDefLink = f"actordef:{_ACTOR_DEF_FOR_TYPE[door_type]}"
        for pkg_name in editor.get_level_pkgs(door["actor"]["scenario"]):
            editor.ensure_present(pkg_name, _ACTOR_DEF_FOR_TYPE[door_type])
