import copy

import json_delta

from open_dread_rando.patcher_editor import PatcherEditor


def _modify_actor(editor: PatcherEditor, original_reference: dict[str, str], new_reference: dict[str, str],
                  modifications: list[dict], actor_groups: list[str], make_copy: bool = False):
    is_in_place = original_reference == new_reference
    scenario = editor.get_scenario(new_reference["scenario"])

    if is_in_place:
        actor = editor.resolve_actor_reference(original_reference)
        make_copy = False
    else:
        actor = copy.deepcopy(editor.resolve_actor_reference(original_reference))
        actor.sName = new_reference["actor"]
        scenario.actors_for_layer(new_reference["layer"])[new_reference["actor"]] = actor

    if modifications:
        json_delta.patch(actor, [
            [modification["path"], modification["update_to"]] if "update_to" in modification
            else [modification["path"]]
            for modification in modifications
        ])

    if actor_groups:
        for group in scenario.all_actor_groups():
            if (group in actor_groups):
                scenario.add_actor_to_group(group, new_reference["actor"], new_reference["layer"])
            else:
                scenario.remove_actor_from_group(group, new_reference["actor"], new_reference["layer"])

    elif not is_in_place and original_reference["scenario"] == new_reference["scenario"]:
        for group in scenario.all_actor_groups():
            if (scenario.is_actor_in_group(group, original_reference["actor"], original_reference["layer"])):
                scenario.add_actor_to_group(group, new_reference["actor"], new_reference["layer"])
            else:
                scenario.remove_actor_from_group(group, new_reference["actor"], new_reference["layer"])

    if not is_in_place and not make_copy:
        editor.remove_entity(original_reference, None)

def _remove_actor(editor: PatcherEditor, actor: dict):
    editor.remove_entity(actor["actor"], actor.get("map_category", None))

def apply_actor_patches(editor: PatcherEditor, actors_config: dict):
    if "modify" in actors_config:
        for actor in actors_config["modify"]:
            _modify_actor(
                editor,
                actor["actor"],
                actor.get("new_reference", actor["actor"]),
                actor["modifications"],
                actor["actor_groups"],
                actor["make_copy"]
            )

    if "remove" in actors_config:
        for actor in actors_config["remove"]:
            _remove_actor(editor, actor)
