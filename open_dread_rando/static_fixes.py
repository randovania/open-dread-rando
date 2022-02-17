import copy
import typing
from open_dread_rando.logger import LOG
from open_dread_rando.patcher_editor import PatcherEditor


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

        for layer_name, actor_name, actor in list(scenario.all_actors()):
            is_door = "LIFE" in actor.pComponents and "CDoorLifeComponent" == actor.pComponents.LIFE["@type"]
            if not is_door:
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

            # Add a reference to the other shield to the main actor
            life_comp[direction] = f"Root:pScenario:rEntitiesLayer:dctSublayers:{layer_name}:dctActors:{mirrored.sName}"

            for group_name in scenario.all_actor_groups():
                if any(scenario.is_actor_in_group(group_name, x, layer_name) for x in [actor_name, other.sName]):
                    for name in [actor_name, mirrored.sName, other.sName]:
                        scenario.add_actor_to_group(group_name, name, layer_name)

PROBLEM_X_LAYERS = {
    "s010_cave": [
        "collision_camera_026", # Chain reaction
        "collision_camera_020", # Corpius arena
        "collision_camera_073", # Corpius entrance
    ],
    "s020_magma": [
        "collision_camera_063", # Kraid arena
    ],
    "s070_basesanc": [
        "collision_camera_005", # Quiet Robe room
    ]
}
def remove_problematic_x_layers(editor: PatcherEditor):
    # these X layers have priority, so they will set some rooms to their post-state
    # even if they've never been entered. in these particular problem rooms, this
    # can cause softlocks (e.g. phantom cloak on golzuna, main PBs on corpius)
    for level, layers in PROBLEM_X_LAYERS.items():
        manager = editor.get_subarea_manager(level)
        configs = manager.get_subarea_setup("PostXRelease").vSubareaConfigs
        manager.get_subarea_setup("PostXRelease").vSubareaConfigs = [
            config for config in configs if config.sId not in layers
        ]


def apply_static_fixes(editor: PatcherEditor):
    remove_problematic_x_layers(editor)
    apply_one_sided_door_fixes(editor)
