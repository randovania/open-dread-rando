import copy

import construct
from mercury_engine_data_structures.formats.dread_types import CActor, CTriggerComponent_EEvent
from mercury_engine_data_structures.formats.gui_files import Bmscp

from open_dread_rando import door_patcher
from open_dread_rando.logger import LOG
from open_dread_rando.patcher_editor import PatcherEditor


def flip_icon_id(icon_id: str) -> str:
    if icon_id.endswith("R"):
        return icon_id[:-1] + "L"
    elif icon_id.endswith("L"):
        return icon_id[:-1] + "R"
    raise ValueError(f"Unable to flip icon {icon_id}")


def apply_one_sided_door_fixes(editor: PatcherEditor):
    all_scenarios = [
        "s010_cave",
        "s020_magma",
        "s030_baselab",
        "s040_aqua",
        "s050_forest",
        "s060_quarantine",
        "s070_basesanc",
        "s080_shipyard",
    ]

    for scenario_name in all_scenarios:
        scenario = editor.get_scenario(scenario_name)
        bmmap = editor.get_scenario_map(scenario_name)
        map_blockages = bmmap.raw.Root.mapBlockages

        for layer_name, actor_name, actor in list(scenario.all_actors()):
            if not door_patcher.is_door(actor):
                continue

            if actor.oActorDefLink != "actordef:actors/props/doorpowerpower/charclasses/doorpowerpower.bmsad":
                continue

            life_comp = actor.pComponents.LIFE
            left = scenario.follow_link(life_comp.wpLeftDoorShieldEntity)
            right = scenario.follow_link(life_comp.wpRightDoorShieldEntity)

            if left is None and right is None:
                continue

            elif left is None:
                other = right
                direction = "wpLeftDoorShieldEntity"

            elif right is None:
                other = left
                direction = "wpRightDoorShieldEntity"
            else:
                continue

            if "db_hdoor" in other.oActorDefLink:
                continue

            LOG.debug("%s/%s/%s: copy %s into %s", scenario_name, layer_name, actor_name, other.sName, direction)
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
            "collision_camera_004", # Z-57 Access
        ]
    },
    "PostEmmy": {
        "s070_basesanc": [
            "collision_camera_040", # Purple Emmi Introduction
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


def _apply_boss_cutscene_fixes(editor: PatcherEditor, cutscene_ref: dict, callback: str, is_kraid: bool = False):
    cutscene_player = editor.resolve_actor_reference(cutscene_ref)
    callbacks_after_cutscene = cutscene_player.pComponents.CUTSCENE.vctOnAfterCutsceneEndsLA
    # kraid's item drop needs to be placed before the cp is saved
    placement = len(callbacks_after_cutscene) - 1 if is_kraid else len(callbacks_after_cutscene)

    # Add the custom call when the boss dies
    if callback:
        callbacks_after_cutscene.insert(placement, {
            "@type": "CLuaCallsLogicAction",
            "sCallbackEntityName": "",
            "sCallback": callback,
            "bCallbackEntity": False,
            "bCallbackPersistent": False,
        })

def apply_kraid_fixes(editor: PatcherEditor):
    _apply_boss_cutscene_fixes(editor, {
        "scenario": "s020_magma",
        "layer": "cutscenes",
        "actor": "cutsceneplayer_61"
    }, "CurrentScenario.OnKraidDeath_CUSTOM", True)

def apply_drogyga_fixes(editor: PatcherEditor):
    _apply_boss_cutscene_fixes(editor, {
        "scenario": "s040_aqua",
        "layer": "cutscenes",
        "actor": "cutsceneplayer_65"
    }, "CurrentScenario.OnHydrogigaDead_CUSTOM")

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
    }, "")

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

        ap_trigger.pComponents.TRIGGER.lstActivationConditions[0].vLogicActions[0].sCallback = f"CurrentScenario.OnEnter_{name}"

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


def apply_main_menu_fixes(editor: PatcherEditor):
    extras = editor.get_file("gui/scripts/extrasmenucomposition.bmscp", Bmscp)
    listcomp = extras.get_child("Content.ListComposition").lstChildren
    listcomp.pop(2) # remove the credits button from the extras menu


def apply_static_fixes(editor: PatcherEditor):
    remove_problematic_x_layers(editor)
    activate_emmi_zones(editor)
    apply_one_sided_door_fixes(editor)
    apply_kraid_fixes(editor)
    fix_backdoor_white_cu(editor)
    patch_corpius_checkpoints(editor)
    apply_experiment_fixes(editor)
    apply_drogyga_fixes(editor)
    apply_main_menu_fixes(editor)
