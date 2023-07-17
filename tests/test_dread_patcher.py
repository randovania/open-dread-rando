from unittest.mock import MagicMock

from open_dread_rando import dread_patcher


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
