from mercury_engine_data_structures.formats import Bmsad

from open_dread_rando.patcher_editor import PatcherEditor

from open_dread_rando.environmental_damage_sources import ALL_DAMAGE_ROOM_ACTORS

from math import ceil

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
    
    if configuration["linear_damage_runs"]:
        
        if configuration["linear_dps"] <= 0:    #This case circumvents a potential divide-by-zero from the tick length calculation, as well as a negative tick length.
        
            damage = 0          #Damage value of 0 to bypass divide-by-zero later
            tick = 0.5          #Tick length of 0.5 is default for damage rooms, lava uses 1 second, but this should not matter.
        elif configuration["linear_dps"] > 0:
            
            #Damage per tick (or 'fDamagePerTime') must be a whole number, this calculation finds a value of damage that will be multiplied by the tick length to equal the total DPS, such that the tick length is between 0.2s and 0.4s
            damage = ceil(float(configuration["linear_dps"])/5)
        
            #Tick length (or 'fInBetweenDamageTime') is found by dividing the damage value by the DPS input, and a value of 1.5/60 is subtracted from the result.
            tick = damage/float(configuration["linear_dps"]) - (1.5/60) #1/60 is meant to account for the frame that damage is applied to Samus, which does not count toward the timer, but 1.5/60 worked more accurately in testing for an unknown reason.
        
        
        for reference in ALL_DAMAGE_ROOM_ACTORS:
        
            actor = editor.resolve_actor_reference(reference)
            
            if actor.oActorDefLink == "actordef:actors/props/env_frozen_gen_001/charclasses/env_frozen_gen_001.bmsad":
                config_name = 'oFreezeConfig'
            elif actor.oActorDefLink == "actordef:actors/props/env_heat_gen_001/charclasses/env_heat_gen_001.bmsad":
                config_name = 'oHeatConfig'
            elif actor.oActorDefLink == "actordef:actors/props/lavazone/charclasses/lavazone.bmsad":
                config_name = 'oConfig'
            else:
                raise ValueError(f"{reference} does not have a valid actorDef for environmental damage")

            damage_config = actor.pComponents.ACTIVATABLE[config_name]
            damage_config.fDamagePerTime = damage
            damage_config.fInBetweenDamageTime = tick
            damage_config.fDamageIncreaseAmount = 0     #Setting this value to 0 removes the damage ramp that exists in vanilla for damage rooms.
            damage_config.fMaxDamage = 1000             #1000 Max damage is an arbitrary limit, also set as the maximum in Randovania. There is no reason this could not be larger if needed.
            