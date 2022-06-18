from mercury_engine_data_structures.formats import Bmsad

from open_dread_rando.patcher_editor import PatcherEditor

from open_dread_rando.environmental_damage_sources import _ALL_DAMAGE_ROOM_ACTORS

_HANUBIA_SHORTCUT_GRAPPLE_BLOCKS = [
    {
        "scenario": "s080_shipyard",
        "layer": "default",
        "actor": "grapplepulloff1x2_000"
    },
    {
        "scenario": "s080_shipyard",
        "layer": "default",
        "actor": "grapplepulloff1x2"
    }
]


def apply_game_patches(editor: PatcherEditor, configuration: dict):
    if configuration.get("consistent_raven_beak_damage_table", True):
        rb_bmsad = editor.get_file("actors/characters/chozocommander/charclasses/chozocommander.bmsad", Bmsad)

        life_component = rb_bmsad.raw.property.components.LIFE
        ai_component = rb_bmsad.raw.property.components.AI
        factors = [
            life_component.fields.fields.oDamageSourceFactor,
            ai_component.fields.fields.oDamageSourceFactorShortShootingGrab,
            ai_component.fields.fields.oDamageSourceFactorLongShootingGrab,
        ]

        for factor in factors:
            for beam in ["fPowerBeamFactor", "fWideBeamFactor", "fPlasmaBeamFactor"]:
                factor[beam] = factor.fWaveBeamFactor
            for beam in ["fChargePowerBeamFactor", "fChargeWideBeamFactor", "fChargePlasmaBeamFactor"]:
                factor[beam] = factor.fChargeWaveBeamFactor
            for beam in ["fMeleeChargePowerBeamFactor", "fMeleeChargeWideBeamFactor", "fMeleeChargePlasmaBeamFactor"]:
                factor[beam] = factor.fMeleeChargeWaveBeamFactor
            for missile in ["fMissileFactor", "fSuperMissileFactor"]:
                factor[missile] = factor.fIceMissileFactor

    if configuration["remove_grapple_blocks_hanubia_shortcut"]:
        for reference in _HANUBIA_SHORTCUT_GRAPPLE_BLOCKS:
            editor.remove_entity(reference, "mapProps")

    if configuration["remove_grapple_block_path_to_itorash"]:
        editor.remove_entity(
            {
                "scenario": "s080_shipyard",
                "layer": "default",
                "actor": "grapplepulloff1x2_001"
            },
            "mapProps"
        )
    if configuration.get("linear_damage_runs", True) and configuration["linear_dps"] > 0:
        for AREA in _ALL_DAMAGE_ROOM_ACTORS:
            for reference in AREA:
                actor = editor.resolve_actor_reference(reference)
                if actor.oActorDefLink == "actordef:actors/props/env_frozen_gen_001/charclasses/env_frozen_gen_001.bmsad":
                    actor.pComponents.ACTIVATABLE.oFreezeConfig.fDamagePerTime = configuration["linear_dps"]/2
                    actor.pComponents.ACTIVATABLE.oFreezeConfig.fInBetweenDamageTime = 0.5
                    actor.pComponents.ACTIVATABLE.oFreezeConfig.fDamageIncreaseAmount = 0
                elif actor.oActorDefLink == "actordef:actors/props/env_heat_gen_001/charclasses/env_heat_gen_001.bmsad":
                    actor.pComponents.ACTIVATABLE.oHeatConfig.fDamagePerTime = configuration["linear_dps"]/2
                    actor.pComponents.ACTIVATABLE.oHeatConfig.fInBetweenDamageTime = 0.5
                    actor.pComponents.ACTIVATABLE.oHeatConfig.fDamageIncreaseAmount = 0
