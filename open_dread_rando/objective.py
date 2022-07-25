import copy
from open_dread_rando.text_patches import patch_text
from open_dread_rando.patcher_editor import PatcherEditor
from mercury_engine_data_structures.formats.dread_types import CTriggerComponent_EEvent


# when playing with artifacts, ensure that sufficient artifact items are shuffled
# artifact item IDs follow the pattern "ITEM_RANDO_ARTIFACT_N" where N is an integer in [1, required_artifacts]
def apply_objective_patches(editor: PatcherEditor, configuration: dict):
    if configuration["objective"]["required_artifacts"] == 0:
        return
    
    patch_text(
        editor,
        "RANDO_ARTIFACTS_ALL",
        r"All Metroid DNA acquired.|{c3}Raven Beak{c0} awaits you in {c5}Itorash{c0}."
    )

    access_point = copy.deepcopy(editor.resolve_actor_reference({
        "scenario": "s080_shipyard",
        "actor": "accesspoint_000"
    }))
    ap_platform = copy.deepcopy(editor.resolve_actor_reference({
        "scenario": "s080_shipyard",
        "actor": "weightactivatedplatform_access_000"
    }))
    ap_trigger = copy.deepcopy(editor.resolve_actor_reference({
        "scenario": "s080_shipyard",
        "actor": "AP_10"
    }))

    origin = access_point.vPos
    new_origin = (-2232.221 - origin[0], -3475.0 - origin[1], 0.0)
    itorash = editor.get_scenario("s090_skybase")

    # add actors to Itorash and update their position
    for actor in [access_point, ap_platform, ap_trigger]:
        itorash.actors_for_layer('default')[actor.sName] = actor
        itorash.add_actor_to_group('eg_collision_camera_001_Default', actor.sName)
        actor.vPos = [c + offset for c, offset in zip(actor.vPos, new_origin)]
    
    for charclass in [
        "actors/props/weightactivatedplatform_access",
        "actors/props/accesspoint",
        "actors/logic/trigger",
    ]:
        for asset in editor.get_asset_names_in_folder(charclass):
            editor.ensure_present_in_scenario("s090_skybase", asset)
    
    trigger = ap_trigger.pComponents.TRIGGER
    on_exit = copy.deepcopy(trigger.lstActivationConditions[0])
    on_exit.eEvent = CTriggerComponent_EEvent.OnExit
    on_exit.vLogicActions[0].sCallback = "CurrentScenario.OnExit_AP_10"
    trigger.lstActivationConditions.append(on_exit)

    usable = access_point.pComponents.USABLE

    usable.vDoorsToChange = [itorash.link_for_actor('doorpowerpower_000')]
    usable.wpThermalDevice = ""

    hints = {
        f"DIAG_ADAM_SHIP_2_PAGE_{i}": hint
        for i, hint in enumerate(configuration['objective']['hints'])
    }
    for k, v in hints.items():
        patch_text(editor, k, v)

    usable.tCaptionList = {
        "DIAG_ADAM_SHIP_2": list(hints) or ["DIAG_ADAM_SHIP_2_PAGE_1"]
    }
