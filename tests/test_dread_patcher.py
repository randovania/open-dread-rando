from unittest.mock import MagicMock

from mercury_engine_data_structures.formats.brfld import ActorLayer

from open_dread_rando import dread_patcher
from open_dread_rando.specific_patches.mass_delete_actors import mass_delete_actors


def test_cosmetic_options(lua_runtime):
    # Setup
    layoutUUID = "33aead28-ab1f-4d55-bbd9-fc0da5b48469"

    editor = MagicMock()
    configuration = {
        "starting_items": {},
        "starting_location": {
            "scenario": "s010_cave",
            "actor": "StartPoint0"
        },
        "configuration_identifier": "<identifier>",
        "layout_uuid": layoutUUID,
        "cosmetic_patches": {
            "config": {
            },
            "lua": {
                "custom_init": {
                    "enable_death_counter": False,
                    "enable_room_name_display": "NEVER"
                },
                "camera_names_dict": {
                }
            },
            "shield_versions": {
                "ice_missile": "ALTERNATE",
                "diffusion_beam": "ALTERNATE",
                "storm_missile": "ALTERNATE",
                "bomb": "ALTERNATE",
                "cross_bomb": "ALTERNATE",
                "power_bomb": "DEFAULT"
            }
        },
        "energy_per_tank": 75,
        "immediate_energy_parts": True,
        "constant_environment_damage": {
            "heat": 20,
            "cold": 20,
            "lava": 20
        },
        "game_patches": {
            "raven_beak_damage_table_handling": "consistent_low",
            "remove_grapple_blocks_hanubia_shortcut": True,
            "remove_grapple_block_path_to_itorash": True,
            "default_x_released": False,
            "enable_experiment_boss": True,
            "warp_to_start": True,
        },
        "objective": {
            "required_artifacts": 3,
            "hints": []
        },
    }

    # Run
    result = dread_patcher.create_custom_init(editor, configuration)

    # Assert
    lua_runtime.execute("Init = {}")
    lua_runtime.execute(result)

    assert lua_runtime.eval("Init.fEnergyPerTank") == 75
    assert lua_runtime.eval("Init.sLayoutUUID") == layoutUUID

def test_mass_delete_actors(patcher_editor):
    configuration = {
        "to_remove": [
            {
                "scenario": "s020_magma",
                "actor_layer": "rEntitiesLayer",
                "method": "all"
            },
            {
                "scenario": "s010_cave",
                "actor_layer": "rLightsLayer",
                "method": "remove_from_groups",
                "actor_groups": [
                    "lg_collision_camera_001"
                ]
            },
            {
                "scenario": "s030_baselab",
                "actor_layer": "rLightsLayer",
                "method": "keep_from_groups",
                "actor_groups": [
                    "lg_collision_camera_011_Default"
                ]
            }
        ],
        "to_keep": [
            {
                "scenario": "s010_cave",
                "actor_layer": "rLightsLayer",
                "sublayer": "cave_001_light",
                "actor": "spot_001_1"
            }
        ]
    }

    mass_delete_actors(patcher_editor, configuration)

    s010_cave = patcher_editor.get_scenario("s010_cave")
    cave_light_001 = s010_cave.get_actor_group("lg_collision_camera_001", "rLightsLayer")
    cave_spot_001_1_link = patcher_editor.build_link("spot_001_1", "cave_001_light", ActorLayer.LIGHTS)

    assert cave_light_001 == [cave_spot_001_1_link]

    s020_magma = patcher_editor.get_scenario("s020_magma")
    magma_entities = [actor_name for (sublayer_name, actor_name, actor) in s020_magma.all_actors_in_actor_layer()]

    assert len(magma_entities) == 0

    s030_baselab = patcher_editor.get_scenario("s030_baselab")
    lab_light_001 = s030_baselab.get_actor_group("lg_collision_camera_001_Default", "rLightsLayer")
    lab_light_010 = s030_baselab.get_actor_group("lg_collision_camera_010_Default", "rLightsLayer")
    lab_light_011 = s030_baselab.get_actor_group("lg_collision_camera_011_Default", "rLightsLayer")
    cubemap_010_link = patcher_editor.build_link("cubemap_010", "base_010_light", ActorLayer.LIGHTS)

    assert len(lab_light_011) == 3 and len(lab_light_001) == 0 and cubemap_010_link in lab_light_010
