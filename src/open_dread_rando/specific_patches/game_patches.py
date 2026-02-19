from mercury_engine_data_structures.formats import Bmsad

from open_dread_rando.misc_patches.text_patches import patch_text
from open_dread_rando.patcher_editor import PatcherEditor

_HANUBIA_SHORTCUT_GRAPPLE_BLOCKS = [
    {"scenario": "s080_shipyard", "actor": "grapplepulloff1x2_000"},
    {"scenario": "s080_shipyard", "actor": "grapplepulloff1x2"},
]


def apply_game_patches(editor: PatcherEditor, configuration: dict):
    raven_beak_damage_mode = configuration["raven_beak_damage_table_handling"]
    early_cloak_water_mode = configuration["remove_early_cloak_water"]
    arbitrary_enky_mode = configuration["remove_arbitrary_enky"]

    if raven_beak_damage_mode != "unmodified":
        _modify_raven_beak_damage_table(editor, raven_beak_damage_mode)

    _remove_grapple_blocks(editor, configuration)

    if configuration["warp_to_start"]:
        _warp_to_start(editor)

    if configuration["nerf_power_bombs"]:
        _remove_pb_weaknesses(editor)

    if configuration["remove_water_platform_water"]:
        _remove_water_platform_water(editor)

    if early_cloak_water_mode != "unmodified":
        _remove_early_cloak_water(editor, early_cloak_water_mode)

    if arbitrary_enky_mode != "unmodified":
        _remove_arbitrary_enky(editor, arbitrary_enky_mode)


def _modify_raven_beak_damage_table(editor: PatcherEditor, mode: str):
    rb_bmsad = editor.get_file("actors/characters/chozocommander/charclasses/chozocommander.bmsad", Bmsad)

    life_component = rb_bmsad.components["LIFE"]
    ai_component = rb_bmsad.components["AI"]

    if mode == "consistent_high":
        base_factor = life_component.fields.oDamageSourceFactor  # Base damage during regular fight
        counter_factors = [
            ai_component.fields.oDamageSourceFactorShortShootingGrab,  # Most counter cutscenes
            ai_component.fields.oDamageSourceFactorLongShootingGrab,  # Unknown alternate counter cutscene
        ]

        # Buffs Wave Beam and Ice Missiles to have the same damage VALUES (not factors) as vanilla Plasma Beam and
        #   Ice Missiles, respectively.
        # Wave Beam typically deals 1.6x the damage as Plasma Beam, so its relative factor must be 1/1.6 that of
        #   Plasma Beam (or 5/8, or 0.625)
        # Ice Missiles typically deal 1.33x the damage as Super Missiles, so their relative factor must be 1/1.33
        #   that of Super Missiles (or 3/4, or 0.75)

        # Base factors will yield the correct ratio such that wave and plasma deal identical damage (Ice uses standard)
        base_factor.fWaveBeamFactor = 0.625
        base_factor.fChargeWaveBeamFactor = 0.625
        base_factor.fMeleeChargeWaveBeamFactor = 0.625
        base_factor.fIceMissileFactor = 1.0

        # All melee-counter factors will be reset to 1.0, except Ice, which uses the factor explained above
        for factor in counter_factors:
            factor.fWaveBeamFactor = 1.0
            factor.fChargeWaveBeamFactor = 1.0
            factor.fMeleeChargeWaveBeamFactor = 1.0
            factor.fIceMissileFactor = 0.75
    else:
        # Debuffs all weapons prior to Wave Beam and Ice Missiles using the same damage factor as Wave Beam and
        # Ice Missiles have in vanilla
        factors = [
            life_component.fields.oDamageSourceFactor,  # Base damage during regular fight
            ai_component.fields.oDamageSourceFactorShortShootingGrab,  # Most counter cutscenes
            ai_component.fields.oDamageSourceFactorLongShootingGrab,  # Unknown alternate counter cutscene
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


def _remove_grapple_blocks(editor: PatcherEditor, configuration: dict):
    if configuration["remove_grapple_blocks_hanubia_shortcut"]:
        for reference in _HANUBIA_SHORTCUT_GRAPPLE_BLOCKS:
            editor.remove_entity(reference, "mapProps")

    if configuration["remove_grapple_block_path_to_itorash"]:
        editor.remove_entity(
            {
                "scenario": "s080_shipyard",
                "actor": "grapplepulloff1x2_001",
            },
            "mapProps",
        )


def _remove_pb_weaknesses(editor: PatcherEditor):
    # enky
    warlotus = editor.get_file("actors/characters/warlotus/charclasses/warlotus.bmsad", Bmsad)
    warlotus.components["LIFE"].fields.bShouldDieWithPowerBomb = False
    warlotus.components["LIFE"].fields.oDamageSourceFactor.fPowerBombFactor = 0.0

    # charge door
    for door in ["doorchargecharge", "doorchargeclosed", "doorclosedcharge"]:
        charge_door = editor.get_file(f"actors/props/{door}/charclasses/{door}.bmsad", Bmsad)
        func = charge_door.components["LIFE"].functions[0]

        if func.get_param(1):
            func.set_param(1, "CHARGE_BEAM")
        if func.get_param(2):
            func.set_param(2, "CHARGE_BEAM")


def _warp_to_start(editor: PatcherEditor):
    text = "Save your progress?|Hold \u1806 and \u1807 while selecting {c6}Cancel{c0}|to warp to the starting location."
    patch_text(editor, "GUI_SAVESTATION_QUESTION", text)


def _remove_water_platform_water(editor: PatcherEditor):
    editor.remove_entity(
        {
            "scenario": "s010_cave",
            "actor": "PRP_CV_watercave05",
        },
        "mapWaterPoolGeos",
    )


def _remove_early_cloak_water(editor: PatcherEditor, mode: str):
    editor.remove_entity(
        {
            "scenario": "s010_cave",
            "actor": "PRP_CV_watercave01b",
        },
        "mapWaterPoolGeos",
    )

    if mode == "both_sides":
        editor.remove_entity(
            {
                "scenario": "s010_cave",
                "actor": "PRP_CV_watercave01a",
            },
            "mapWaterPoolGeos",
        )
        editor.remove_entity(
            {
                "scenario": "s010_cave",
                "actor": "PRP_DB_CV_003",
            },
            "mapOccluderGeos",
        )


def _remove_arbitrary_enky(editor: PatcherEditor, mode: str):
    arbitrary_enky_reference = {
        "scenario": "s010_cave",
        "sublayer": "Enemies",
        "actor": "SG_WarLotus_000",
    }

    if mode == "never":
        editor.remove_entity(arbitrary_enky_reference, "mapProps")
    elif mode == "always":
        arbitrary_enky = editor.resolve_actor_reference(arbitrary_enky_reference)

        arbitrary_enky.pComponents.SPAWNGROUP.bAutoenabled = True
