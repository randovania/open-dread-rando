# This file is generated. Manual changes will be lost
# fmt: off
# ruff: noqa
from __future__ import annotations

import typing


class DefScenarioLuaCallback(typing.TypedDict):
    scenario: typing.NotRequired[def_scenario_name]
    function: typing.NotRequired[str]
    args: typing.NotRequired[int]


def_scenario_lua_callback = DefScenarioLuaCallback


class DefActorReferenceWithLayer(typing.TypedDict):
    scenario: typing.Required[def_scenario_name]
    layer: typing.NotRequired[str]
    actor: typing.Required[str]


def_actor_reference_with_layer = DefActorReferenceWithLayer


class DefActorReference(typing.TypedDict):
    scenario: typing.Required[def_scenario_name]
    actor: typing.Required[str]


def_actor_reference = DefActorReference
def_scenario_name = str
def_constant_damage_value = float | None
def_item_id = str


class DefItem(typing.TypedDict):
    item_id: typing.Required[def_item_id]
    quantity: typing.Required[float]


def_item = DefItem


class DefPosition(typing.TypedDict):
    x: typing.Required[float]
    y: typing.Required[float]
    z: typing.Required[float]


def_position = DefPosition


# The root object

class ConfigurationPickupsItemMapIconCustomIconCoords(typing.TypedDict, total=False):
    row: typing.Required[int]
    col: typing.Required[int]


class ConfigurationPickupsItemMapIconCustomIconExtras(typing.TypedDict, total=False):
    pass


class ConfigurationPickupsItemMapIconCustomIcon(typing.TypedDict, total=False):
    label: typing.Required[str]
    player: typing.NotRequired[str]
    base_icon: typing.NotRequired[str]
    coords: typing.NotRequired[ConfigurationPickupsItemMapIconCustomIconCoords]
    is_global: typing.NotRequired[bool]
    full_zoom_scale: typing.NotRequired[bool]
    extras: typing.NotRequired[ConfigurationPickupsItemMapIconCustomIconExtras]


class ConfigurationPickupsItemMapIcon(typing.TypedDict, total=False):
    original_actor: typing.NotRequired[def_actor_reference_with_layer]
    icon_id: typing.NotRequired[str]
    custom_icon: typing.NotRequired[ConfigurationPickupsItemMapIconCustomIcon]


class ConfigurationPickupsItem(typing.TypedDict, total=False):
    pickup_type: typing.Required[str]
    caption: typing.Required[str]
    resources: typing.Required[list[list[def_item]]]
    pickup_actor: typing.NotRequired[def_actor_reference_with_layer]
    model: typing.NotRequired[list[str]]
    map_icon: typing.NotRequired[ConfigurationPickupsItemMapIcon]
    pickup_lua_callback: typing.NotRequired[def_scenario_lua_callback]
    pickup_actordef: typing.NotRequired[str]
    pickup_string_key: typing.NotRequired[str]


class ConfigurationElevatorsItem(typing.TypedDict, total=False):
    teleporter: typing.Required[def_actor_reference_with_layer]
    destination: typing.Required[def_actor_reference]
    connection_name: typing.Required[str]


class ConfigurationStartingItems(typing.TypedDict, total=False):
    ITEM_LIFE_SHARDS: typing.NotRequired[float]


class ConfigurationHintsItem(typing.TypedDict, total=False):
    accesspoint_actor: typing.Required[def_actor_reference_with_layer]
    hint_id: typing.Required[str]
    text: typing.Required[str]


class ConfigurationTextPatches(typing.TypedDict, total=False):
    pass


class ConfigurationCosmeticPatchesConfig(typing.TypedDict, total=False):
    pass


class ConfigurationCosmeticPatchesLuaCustomInit(typing.TypedDict):
    enable_death_counter: typing.NotRequired[bool]
    enable_room_name_display: typing.NotRequired[str]


class ConfigurationCosmeticPatchesLuaCameraNamesDict(typing.TypedDict):
    pass


class ConfigurationCosmeticPatchesLua(typing.TypedDict):
    custom_init: typing.NotRequired[ConfigurationCosmeticPatchesLuaCustomInit]
    camera_names_dict: typing.NotRequired[ConfigurationCosmeticPatchesLuaCameraNamesDict]


class ConfigurationCosmeticPatchesShieldVersions(typing.TypedDict, total=False):
    ice_missile: typing.NotRequired[str]
    diffusion_beam: typing.NotRequired[str]
    storm_missile: typing.NotRequired[str]
    bomb: typing.NotRequired[str]
    cross_bomb: typing.NotRequired[str]
    power_bomb: typing.NotRequired[str]


class ConfigurationCosmeticPatches(typing.TypedDict, total=False):
    config: typing.Required[ConfigurationCosmeticPatchesConfig]
    lua: typing.Required[ConfigurationCosmeticPatchesLua]
    shield_versions: typing.Required[ConfigurationCosmeticPatchesShieldVersions]


class ConfigurationConstantEnvironmentDamage(typing.TypedDict):
    heat: typing.NotRequired[def_constant_damage_value]
    cold: typing.NotRequired[def_constant_damage_value]
    lava: typing.NotRequired[def_constant_damage_value]


class ConfigurationGamePatches(typing.TypedDict):
    raven_beak_damage_table_handling: typing.NotRequired[str]
    remove_grapple_blocks_hanubia_shortcut: typing.NotRequired[bool]
    remove_grapple_block_path_to_itorash: typing.NotRequired[bool]
    default_x_released: typing.NotRequired[bool]
    enable_experiment_boss: typing.NotRequired[bool]
    warp_to_start: typing.NotRequired[bool]
    nerf_power_bombs: typing.NotRequired[bool]


class ConfigurationObjective(typing.TypedDict):
    required_artifacts: typing.NotRequired[int]
    hints: typing.NotRequired[list[str]]


class ConfigurationDoorPatchesItem(typing.TypedDict):
    actor: typing.Required[def_actor_reference_with_layer]
    door_type: typing.Required[str]


class ConfigurationTileGroupPatchesItem(typing.TypedDict):
    actor: typing.Required[def_actor_reference_with_layer]
    tiletype: typing.Required[str]


class ConfigurationNewSpawnPointsItem(typing.TypedDict):
    new_actor: typing.Required[def_actor_reference]
    location: typing.Required[def_position]
    collision_camera_name: typing.Required[str]


class ConfigurationSpoilerLog(typing.TypedDict, total=False):
    pass


class Configuration(typing.TypedDict):
    configuration_identifier: typing.Required[str]
    layout_uuid: typing.NotRequired[str]
    starting_location: typing.Required[def_actor_reference]
    pickups: typing.Required[list[ConfigurationPickupsItem]]
    elevators: typing.NotRequired[list[ConfigurationElevatorsItem]]
    debug_export_modified_files: typing.NotRequired[bool]
    starting_items: typing.Required[ConfigurationStartingItems]
    starting_text: typing.NotRequired[list[list[str]]]
    energy_per_tank: typing.NotRequired[float]
    immediate_energy_parts: typing.NotRequired[bool]
    hints: typing.NotRequired[list[ConfigurationHintsItem]]
    text_patches: typing.NotRequired[ConfigurationTextPatches]
    mod_compatibility: typing.NotRequired[str]
    mod_category: typing.NotRequired[str]
    cosmetic_patches: typing.NotRequired[ConfigurationCosmeticPatches]
    enable_remote_lua: typing.NotRequired[bool]
    constant_environment_damage: typing.NotRequired[ConfigurationConstantEnvironmentDamage]
    game_patches: typing.NotRequired[ConfigurationGamePatches]
    objective: typing.NotRequired[ConfigurationObjective]
    show_shields_on_minimap: typing.NotRequired[bool]
    door_patches: typing.NotRequired[list[ConfigurationDoorPatchesItem]]
    tile_group_patches: typing.NotRequired[list[ConfigurationTileGroupPatchesItem]]
    new_spawn_points: typing.NotRequired[list[ConfigurationNewSpawnPointsItem]]
    spoiler_log: typing.NotRequired[ConfigurationSpoilerLog]


Configuration = Configuration
