import copy

from json_delta import patch

from open_dread_rando.patcher_editor import PatcherEditor


def _modify_actor(editor: PatcherEditor, original_reference: dict, modifications: list,
                  new_reference: dict, make_copy: bool = False):
    if new_reference:
        actor = copy.deepcopy(editor.resolve_actor_reference(original_reference))
    else:
        actor = editor.resolve_actor_reference(original_reference)

    if new_reference:
        actor.sName = new_reference["actor"]
    patch(actor, modifications)

    if new_reference:
        scenario = editor.get_scenario(new_reference["scenario"])

        scenario.actors_for_layer(new_reference["layer"])[new_reference["actor"]] = actor

        for group in scenario.all_actor_groups():
            if (group in new_reference["actor_groups"]):
                scenario.add_actor_to_group(group, new_reference["actor"])
            else:
                scenario.remove_actor_from_group(group, new_reference["actor"])

        if not make_copy:
            editor.remove_entity(original_reference)

def _remove_actor(editor: PatcherEditor, actor: dict):
    editor.remove_entity(actor["actor"], actor["map_category"])

def apply_actor_patches(editor: PatcherEditor, actors_config: dict):
    if "modify" in actors_config:
        for actor in actors_config["modify"]:
            _modify_actor(
                editor,
                actor["original_reference"],
                actor["modifications"],
                actor["new_reference"] if "new_reference" in actor else None,
                actor["copy"] if "copy" in actor else None
            )

    if "remove" in actors_config:
        for actor in actors_config["remove"]:
            _remove_actor(editor, actor)
