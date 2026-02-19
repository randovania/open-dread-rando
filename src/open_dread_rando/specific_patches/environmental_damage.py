from math import ceil

from open_dread_rando.patcher_editor import PatcherEditor
from open_dread_rando.specific_patches.environmental_damage_sources import ALL_DAMAGE_ROOM_ACTORS


def get_damage_and_tick(value: float) -> tuple[float, float]:
    if value <= 0:
        damage = 0  # Damage value of 0 to bypass divide-by-zero later
        tick = 0.5  # Tick length of 0.5 is default for damage rooms, lava uses 1 second, but this should not matter.
    else:
        # Damage per tick (or 'fDamagePerTime') must be a whole number, this calculation
        # finds a value of damage that will be multiplied by the tick length to equal the
        # total DPS, such that the tick length is between 0.2s and 0.4s
        damage = ceil(value / 5)

        # Tick length (or 'fInBetweenDamageTime') is found by dividing the damage value by the DPS input,
        # and a value of 1.5/60 is subtracted from the result.
        # 1/60 is meant to account for the frame that damage is applied to Samus,
        # which does not count toward the timer, but 1.5/60 worked more accurately in testing for an unknown reason.
        tick = damage / value - (1.5 / 60)

    return damage, tick


def apply_constant_damage(editor: PatcherEditor, configuration: dict):
    for reference in ALL_DAMAGE_ROOM_ACTORS:
        actor = editor.resolve_actor_reference(reference)

        if actor.oActorDefLink == "actordef:actors/props/env_frozen_gen_001/charclasses/env_frozen_gen_001.bmsad":
            config_name = "oFreezeConfig"
            config_field = "cold"
        elif actor.oActorDefLink == "actordef:actors/props/env_heat_gen_001/charclasses/env_heat_gen_001.bmsad":
            config_name = "oHeatConfig"
            config_field = "heat"
        elif actor.oActorDefLink == "actordef:actors/props/lavazone/charclasses/lavazone.bmsad":
            config_name = "oConfig"
            config_field = "lava"
        else:
            raise ValueError(f"{reference} does not have a valid actorDef for environmental damage")

        if configuration[config_field] is None:
            continue

        damage, tick = get_damage_and_tick(configuration[config_field])

        damage_config = actor.pComponents.ACTIVATABLE[config_name]
        damage_config.fDamagePerTime = damage
        damage_config.fInBetweenDamageTime = tick
        # Setting this value to 0 removes the damage ramp that exists in vanilla for damage rooms.
        damage_config.fDamageIncreaseAmount = 0
        # 1000 Max damage is an arbitrary limit, also set as the maximum in Randovania.
        # There is no reason this could not be larger if needed.
        damage_config.fMaxDamage = 1000
