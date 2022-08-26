from mercury_engine_data_structures.formats import Bmsad

from open_dread_rando.patcher_editor import PatcherEditor
from open_dread_rando.text_patches import patch_text

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
        _consistent_raven_beak_damage_table(editor)

    _remove_grapple_blocks(editor, configuration)

    if configuration["warp_to_start"]:
        _warp_to_start(editor)


def _consistent_raven_beak_damage_table(editor: PatcherEditor):
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


def _remove_grapple_blocks(editor: PatcherEditor, configuration: dict):
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


def _warp_to_start(editor: PatcherEditor):
    text = "Save your progress?|Hold \u1806 and \u1807 while selecting {c6}Cancel{c0}|to warp to the starting location."
    patch_text(editor, "GUI_SAVESTATION_QUESTION", text)
