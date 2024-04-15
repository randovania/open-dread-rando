import copy
from typing import Optional

import construct
from mercury_engine_data_structures.formats import Bmmap, Brfld
from mercury_engine_data_structures.formats.gui_files import Bmscp

from open_dread_rando.constants import ALL_SCENARIOS
from open_dread_rando.door_locks import door_patcher
from open_dread_rando.logger import LOG
from open_dread_rando.patcher_editor import PatcherEditor
from open_dread_rando.pickups.map_icons import MapIconEditor


def flip_icon_id(icon_id: str) -> str:
    if icon_id.endswith("R"):
        return icon_id[:-1] + "L"
    elif icon_id.endswith("L"):
        return icon_id[:-1] + "R"
    raise ValueError(f"Unable to flip icon {icon_id}")


def _apply_one_sided_door_fix(scenario: Brfld, map_blockages: construct.Container,
                              layer_name: str, actor_name: str, actor: construct.Container):
    # Continue if this isn't a door
    if not door_patcher.is_door(actor):
        return

    if actor.oActorDefLink != "actordef:actors/props/doorpowerpower/charclasses/doorpowerpower.bmsad":
        return

    life_comp = actor.pComponents.LIFE
    left = scenario.follow_link(life_comp.wpLeftDoorShieldEntity)
    right = scenario.follow_link(life_comp.wpRightDoorShieldEntity)

    if left is None and right is None:
        return

    elif left is None:
        other = right
        direction = "wpLeftDoorShieldEntity"

    elif right is None:
        other = left
        direction = "wpRightDoorShieldEntity"
    else:
        return

    if "db_hdoor" in other.oActorDefLink:
        return

    LOG.debug("%s/%s: copy %s into %s", layer_name, actor_name, other.sName, direction)
    mirrored = copy.deepcopy(other)
    mirrored.sName += "_mirrored"
    mirrored.vAng = [other.vAng[0], -other.vAng[1], other.vAng[2]]
    scenario.actors_for_layer(layer_name)[mirrored.sName] = mirrored

    mirrored_map = copy.deepcopy(map_blockages[other.sName])
    mirrored_map["sIconId"] = flip_icon_id(mirrored_map["sIconId"])
    delta = 450 if mirrored_map["sIconId"].endswith("R") else -450
    mirrored_map["oBox"]["Min"][0] += delta
    mirrored_map["oBox"]["Max"][0] += delta
    map_blockages[mirrored.sName] = mirrored_map

    # Add a reference to the other shield to the main actor
    life_comp[direction] = f"Root:pScenario:rEntitiesLayer:dctSublayers:{layer_name}:dctActors:{mirrored.sName}"

    for group_name in scenario.all_actor_groups():
        if any(scenario.is_actor_in_group(group_name, x, layer_name) for x in [actor_name, other.sName]):
            for name in [actor_name, mirrored.sName, other.sName]:
                scenario.add_actor_to_group(group_name, name, layer_name)


def apply_one_sided_door_fixes(editor: PatcherEditor):
    for scenario_name in ALL_SCENARIOS:
        scenario = editor.get_scenario(scenario_name)
        bmmap = editor.get_scenario_map(scenario_name)
        map_blockages = bmmap.raw.Root.mapBlockages

        for layer_name, actor_name, actor in list(scenario.all_actors()):
            _apply_one_sided_door_fix(scenario, map_blockages, layer_name, actor_name, actor)


PROBLEM_LAYERS = {
    "PostXRelease": {
        "s010_cave": [
            "collision_camera_026",  # Chain reaction
            "collision_camera_020",  # Corpius arena
            "collision_camera_073",  # Corpius entrance
        ],
        "s020_magma": [
            "collision_camera_063",  # Kraid arena
        ],
        "s040_aqua": [
            "collision_camera_007",  # Below Drogyga
            "collision_camera_028",  # Drogyga arena
        ],
        "s070_basesanc": [
            "collision_camera_005",  # Quiet Robe room
        ]
    },
    "Cooldown": {
        "s020_magma": [
            "collision_camera_004",  # Z-57 Access
        ]
    },
    "PostEmmy": {
        "s070_basesanc": [
            "collision_camera_040",  # Purple Emmi Introduction
        ]
    }
}


def remove_problematic_x_layers(editor: PatcherEditor):
    # these X layers have priority, so they will set some rooms to their post-state
    # even if they've never been entered. in these particular problem rooms, this
    # can cause softlocks (e.g. phantom cloak on golzuna, main PBs on corpius)
    for setup, levels in PROBLEM_LAYERS.items():
        for level, layers in levels.items():
            manager = editor.get_subarea_manager(level)
            configs = manager.get_subarea_setup(setup).vSubareaConfigs
            manager.get_subarea_setup(setup).vSubareaConfigs = [
                config for config in configs if config.sId not in layers
            ]


def _apply_boss_cutscene_fixes(editor: PatcherEditor, cutscene_ref: dict, callback: str,
                               insert_callback_at: Optional[int] = None):
    cutscene_player = editor.resolve_actor_reference(cutscene_ref)
    callbacks_after_cutscene = cutscene_player.pComponents.CUTSCENE.vctOnAfterCutsceneEndsLA

    # Add the custom call when the boss dies
    if callback:
        callback_action = {
            "@type": "CLuaCallsLogicAction",
            "sCallbackEntityName": "",
            "sCallback": callback,
            "bCallbackEntity": False,
            "bCallbackPersistent": False,
        }
        if insert_callback_at is None:
            callbacks_after_cutscene.append(callback_action)
        else:
            i = insert_callback_at
            callbacks_after_cutscene[i:i] = [callback_action]


def apply_corpius_fixes(editor: PatcherEditor):
    _apply_boss_cutscene_fixes(editor, {
        "scenario": "s010_cave",
        "layer": "Cutscenes",
        "actor": "cutsceneplayer_57"
    }, "CurrentScenario.OnCorpiusDeath_CUSTOM", 0)


def apply_kraid_fixes(editor: PatcherEditor):
    _apply_boss_cutscene_fixes(editor, {
        "scenario": "s020_magma",
        "layer": "cutscenes",
        "actor": "cutsceneplayer_61"
    }, "CurrentScenario.OnKraidDeath_CUSTOM", -1)


def apply_drogyga_fixes(editor: PatcherEditor):
    _apply_boss_cutscene_fixes(editor, {
        "scenario": "s040_aqua",
        "layer": "cutscenes",
        "actor": "cutsceneplayer_65"
    }, "CurrentScenario.OnHydrogigaDead_CUSTOM", -1)

    # remove the trigger that deletes drogyga until after beating drogyga
    aqua = editor.get_scenario("s040_aqua")
    aqua.remove_actor_from_group("eg_collision_camera_007_Default", "TG_WaterPoolAfterHydrogiga", "Boss")


def activate_emmi_zones(editor: PatcherEditor):
    # Remove the cutscene that plays when you enter the emmi zone for the first time
    # This causes the border of the zone to not be revealed, but it should be possible to do that in another way
    editor.remove_entity(
        {
            "scenario": "s010_cave",
            "layer": "Cutscenes",
            "actor": "cutscenetrigger_36"
        },
        None,
    )

    # Remove the cutscene that introduces the speed emmi
    # This causes the border of the zone to not be revealed, but it should be possible to do that in another way
    editor.remove_entity(
        {
            "scenario": "s030_baselab",
            "layer": "cutscenes",
            "actor": "cutscenetrigger_39"
        },
        None,
    )


def fix_backdoor_white_cu(editor: PatcherEditor):
    new_door = construct.Container({
        "@type": "CEntity",
        "sName": "DreadRando_CUDoor",
        "oActorDefLink": "actordef:actors/props/doorclosedpower/charclasses/doorclosedpower.bmsad",
        "vPos": [
            8300.000,
            -4700.000,
            0.0
        ],
        "vAng": [
            0.0,
            0.0,
            0.0
        ],
        "pComponents": {
            "LIFE": {
                "@type": "CDoorLifeComponent",
                "bWantsEnabled": True,
                "bUseDefaultValues": True,
                "fMaxDistanceOpened": 400.0,
                "wpLeftDoorShieldEntity": "{EMPTY}",
                "wpRightDoorShieldEntity": "{EMPTY}",
                "fMinTimeOpened": 3.0,
                "bStayOpen": True,
                "bStartOpened": False,
                "bOnBlackOutOpened": False,
                "bDoorIsWet": False,
                "bFrozenDuringColdown": True,
                "iAreaLeft": 0,
                "iAreaRight": 0,
                "aVignettes": []
            },
            "AUDIO": {
                "@type": "CAudioComponent",
                "bWantsEnabled": True,
                "bUseDefaultValues": True
            },
            "FX": {
                "@type": "CFXComponent",
                "bWantsEnabled": True,
                "bUseDefaultValues": True,
                "fSelectedHighRadius": 250.0,
                "fSelectedLowRadius": 350.0
            },
            "COLLISION": {
                "@type": "CCollisionComponent",
                "bWantsEnabled": True,
                "bUseDefaultValues": True
            },
            "TIMELINECOMPONENT": {
                "@type": "CTimelineComponent",
                "bWantsEnabled": True,
                "bUseDefaultValues": True
            },
            "NAVMESHITEM": {
                "@type": "CNavMeshItemComponent",
                "bWantsEnabled": True,
                "bUseDefaultValues": True,
                "tForbiddenEdgesSpawnPoints": []
            },
            "ANIMATION": {
                "@type": "CAnimationComponent",
                "bWantsEnabled": True,
                "bUseDefaultValues": True
            },
            "MODELUPDATER": {
                "@type": "CModelUpdaterComponent",
                "bWantsEnabled": True,
                "bUseDefaultValues": True,
                "sDefaultModelPath": ""
            }
        },
        "bEnabled": True
    })

    cave = editor.get_scenario("s010_cave")
    cave.actors_for_layer("default")[new_door["sName"]] = new_door

    for group in ["eg_collision_camera_018_Default", "eg_collision_camera_090_Default",
                  "eg_collision_camera_049_Default", "eg_collision_camera_090_PostXRelease",
                  "eg_collision_camera_049_PostXRelease"]:
        cave.add_actor_to_group(group, new_door["sName"])


def patch_corpius_checkpoints(editor: PatcherEditor):
    cave = editor.get_scenario("s010_cave")

    # Fix checkpoint before Corpius fight not working if the X were released
    cave.add_actor_to_group("eg_collision_camera_072_PostXRelease", "SP_Checkpoint_Scorpius")


def apply_experiment_fixes(editor: PatcherEditor):
    magma = editor.get_scenario("s020_magma")

    _apply_boss_cutscene_fixes(editor, {
        "scenario": "s020_magma",
        "layer": "cutscenes",
        "actor": "cutsceneplayer_81"
    }, "CurrentScenario.OnExperimentDeath_CUSTOM", 0)

    new_triggers = {
        "TriggerEnableCooldown": (5050.000, -5346.150, 0.000),
        "TriggerDisableCooldown": (5000.000, -7350.000, 0.000),
    }

    # create triggers to update the cooldown status appropriately
    for name, pos in new_triggers.items():
        ap_trigger = copy.deepcopy(editor.resolve_actor_reference({
            "scenario": "s020_magma",
            "layer": "default",
            "actor": "AP_03"
        }))

        ap_trigger.sName = name
        ap_trigger.vPos = pos

        activation_conditions = ap_trigger.pComponents.TRIGGER.lstActivationConditions
        activation_conditions[0].vLogicActions[0].sCallback = f"CurrentScenario.OnEnter_{name}"

        magma.actors_for_layer('default')[name] = ap_trigger
        magma.add_actor_to_group("eg_collision_camera_004_PostXRelease", name)

    # make thermal doors always closed during the fight
    for name in ["trap_thermal_horizontal_000", "trap_thermal_horizontal_005"]:
        magma.remove_actor_from_group("eg_collision_camera_009_Cooldown", name)

        trap = copy.deepcopy(editor.resolve_actor_reference({
            "scenario": "s020_magma",
            "layer": "default",
            "actor": name
        }))

        trap.sName = f"{name}_EXPERIMENT"
        magma.actors_for_layer('default')[trap.sName] = trap
        magma.add_actor_to_group('eg_collision_camera_009_Cooldown', trap.sName)

    # disable closing the thermal door permanently after experiment
    editor.remove_entity({
        "scenario": "s020_magma",
        "layer": "default",
        "actor": "trap_thermal_horizontal_POSTCOOL"
    }, "mapDoors")

    # add thermal door in front of morph launcher
    new_door = copy.deepcopy(editor.resolve_actor_reference({
        "scenario": "s020_magma",
        "actor": "trap_thermal_horizontal_004"
    }))

    new_name = "trap_thermal_horizontal_006"

    new_door.sName = new_name
    new_door.vPos = [5840.0, -5455.0, 0.0]

    magma.actors_for_layer('default')[new_name] = new_door
    for group in ["eg_collision_camera_004_Default", "eg_collision_camera_004_PostXRelease"]:
        magma.add_actor_to_group(group, new_door.sName)

    # update thermal switch to open new door
    thermal_switch = copy.deepcopy(editor.resolve_actor_reference({
        "scenario": "s020_magma",
        "actor": "deviceheat"
    }))

    thermal_switch.pComponents.USABLE.vThermalDoors.append(construct.Container({
        "wpThermalDoor": magma.link_for_actor(new_name),
        "sDoorState": 1
    }))

    magma.actors_for_layer('default')[thermal_switch.sName] = thermal_switch
    for group in ["eg_collision_camera_004_Default", "eg_collision_camera_004_PostXRelease"]:
        magma.add_actor_to_group(group, thermal_switch.sName)


def apply_main_menu_fixes(editor: PatcherEditor):
    extras = editor.get_file("gui/scripts/extrasmenucomposition.bmscp", Bmscp)
    listcomp = extras.get_child("Content.ListComposition").lstChildren
    listcomp.pop(2)  # remove the credits button from the extras menu


def disable_hanubia_cutscene(editor: PatcherEditor):
    # disable cutscene 12 (hanubia - tank room) because it teleports samus to the lower section (bad for door rando)
    cutscene_player = editor.resolve_actor_reference({
        "scenario": "s080_shipyard",
        "layer": "cutscenes",
        "actor": "cutsceneplayer_12",
    })
    cutscene_player.bEnabled = False


def fix_map_icons(map_editor: MapIconEditor):
    map_editor.mirror_bmmdef_icons()
    map_editor.mirror_bmmap_icons()


def move_artaria_missile_tank(editor: PatcherEditor):
    actor_ref = {
        "scenario": "s010_cave",
        "layer": "default",
        "actor": "item_missiletank_000"
    }
    missile_tank = editor.resolve_actor_reference(actor_ref)
    artaria_map = editor.get_scenario_file(actor_ref["scenario"], Bmmap)

    new_x_pos = 15450.0
    missile_tank.vPos[0] = new_x_pos
    artaria_map.items[actor_ref["actor"]].vPos[0] = new_x_pos


def apply_static_fixes(editor: PatcherEditor):
    remove_problematic_x_layers(editor)
    activate_emmi_zones(editor)
    apply_one_sided_door_fixes(editor)
    apply_kraid_fixes(editor)
    apply_corpius_fixes(editor)
    fix_backdoor_white_cu(editor)
    patch_corpius_checkpoints(editor)
    apply_experiment_fixes(editor)
    apply_drogyga_fixes(editor)
    apply_main_menu_fixes(editor)
    disable_hanubia_cutscene(editor)
    fix_map_icons(editor.map_icon_editor)
    move_artaria_missile_tank(editor)
