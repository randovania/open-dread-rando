import copy

import json_delta

from open_dread_rando.patcher_editor import PatcherEditor


def _modify_actor(editor: PatcherEditor, original_reference: dict[str, str], new_reference: dict[str, str],
                  modifications: list[dict], actor_groups: list[str], make_copy: bool = False):
    is_in_place = original_reference == new_reference
    scenario = editor.get_scenario(new_reference["scenario"])
    new_actor_name = new_reference["actor"]
    new_sublayer = new_reference.get("sublayer", new_reference["layer"])
    new_actor_layer = new_reference["actor_layer"]

    if is_in_place:
        actor = editor.resolve_actor_reference(original_reference)
        make_copy = False
    else:
        actor = copy.deepcopy(editor.resolve_actor_reference(original_reference))
        actor.sName = new_actor_name
        actors_in_sublayer = scenario.actors_for_sublayer(new_sublayer, new_actor_layer)
        actors_in_sublayer[new_actor_name] = actor

    if modifications:
        json_delta.patch(actor, [
            [modification["path"], modification["update_to"]] if "update_to" in modification
            else [modification["path"]]
            for modification in modifications
        ])

    if actor_groups is not None:
        for group in scenario.actor_groups_for_actor_layer(new_actor_layer):

            is_actor_in_group = scenario.is_actor_in_group(group, new_actor_name, new_sublayer, new_actor_layer)

            if group in actor_groups and not is_actor_in_group:
                scenario.add_actor_to_group(group, new_actor_name, new_sublayer, new_actor_layer)
            elif is_actor_in_group:
                scenario.remove_actor_from_group(group, new_actor_name, new_sublayer, new_actor_layer)

    elif (not is_in_place and
          original_reference["scenario"] == new_reference["scenario"] and
          original_reference["actor_layer"] == new_actor_layer):
        editor.copy_actor_groups(original_reference, new_reference, scenario.name, new_actor_layer)

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
                actor.get("actor_groups"),
                actor["make_copy"]
            )

    if "remove" in actors_config:
        for actor in actors_config["remove"]:
            _remove_actor(editor, actor)
