from mercury_engine_data_structures.formats import Bmsad

from open_dread_rando.patcher_editor import PatcherEditor

from open_dread_rando.environmental_damage_sources import ALL_DAMAGE_ROOM_ACTORS

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
    
    if configuration["linear_damage_runs"] and configuration["linear_dps"] > 0:
    
        from math import ceil   #couldnt find a better way to do this without loops
        
        #This section should find a tick speed between 0.2 and 0.4 and determine a damage amount that should calculate to be the total DPS
        #This *could* be customizable I suppose, but would require more UI work and the game is very picky on what values it allows. Only whole number damage values, and the tick speed cannot be too low or else it caps.
        
        damage = ceil(float(configuration["linear_dps"])/5)
        tick = damage/float(configuration["linear_dps"]) - (1.5/60) #1/60 is to account for the damage frame, which does not count toward the timer, but 1.5/60 worked better in testing.
        
        
        for reference in ALL_DAMAGE_ROOM_ACTORS:
        
            actor = editor.resolve_actor_reference(reference)
            
            if actor.oActorDefLink == "actordef:actors/props/env_frozen_gen_001/charclasses/env_frozen_gen_001.bmsad":
                config_name = 'oFreezeConfig'
            elif actor.oActorDefLink == "actordef:actors/props/env_heat_gen_001/charclasses/env_heat_gen_001.bmsad":
                config_name= 'oHeatConfig'
            else:
                raise ValueError(f"{reference} does not have a valid actorDef for environmental damage")

            damage_config = actor.pComponents.ACTIVATABLE[config_name]
            damage_config.fDamagePerTime = damage
            damage_config.fInBetweenDamageTime = tick
            damage_config.fDamageIncreaseAmount = 0
            damage_config.fMaxDamage = 1000
