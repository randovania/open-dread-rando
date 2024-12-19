from collections import namedtuple

from open_dread_rando.patcher_editor import PatcherEditor

ActorReferenceTuple = namedtuple("ActorReferenceTuple", ["scenario", "actor_layer", "sublayer", "actor"])

def _remove_all_actors(editor: PatcherEditor, scenario_name: str, actor_layer: str,
                       to_remove: set[ActorReferenceTuple]) -> None:
    scenario = editor.get_scenario(scenario_name)

    for sublayer_name, actor_name, actor in scenario.all_actors_in_actor_layer(actor_layer):
        to_remove.add(ActorReferenceTuple(scenario_name, actor_layer, sublayer_name, actor_name))

def _remove_actors_from_groups(editor: PatcherEditor, scenario_name: str, actor_layer: str,
                               actor_groups: list[str], to_remove: set) -> None:
    scenario = editor.get_scenario(scenario_name)

    for group in actor_groups:
        for actor_link in scenario.get_actor_group(group, actor_layer):
            to_remove.add(ActorReferenceTuple(**editor.reference_for_link(actor_link, scenario_name)))

def _remove_actors_not_in_groups(editor: PatcherEditor, scenario_name: str, actor_layer: str,
                                 actor_groups: list[str], to_remove: set, to_keep) -> None:
    scenario = editor.get_scenario(scenario_name)

    for group in scenario.actor_groups_for_actor_layer(actor_layer):
        if group not in actor_groups:
            for actor_link in scenario.get_actor_group(group, actor_layer):
                to_remove.add(ActorReferenceTuple(**editor.reference_for_link(actor_link, scenario_name)))
        else:
            for actor_link in scenario.get_actor_group(group, actor_layer):
                to_keep.add(ActorReferenceTuple(**editor.reference_for_link(actor_link, scenario_name)))

def mass_delete_actors(editor: PatcherEditor, configuration: dict) -> None:
    # Sets of tuples will be used to ensure no duplicate entries
    to_remove = set()
    to_keep = set()

    for reference in configuration["to_keep"]:
        to_keep.add(ActorReferenceTuple(
            reference["scenario"],
            reference["actor_layer"],
            reference.get("sublayer", reference["layer"]),
            reference["actor"]
        ))

    for scenario_config in configuration["to_remove"]:
        scenario_name = scenario_config["scenario"]
        actor_layer = scenario_config["actor_layer"]
        method = scenario_config["method"]

        if method == "all":
            _remove_all_actors(editor, scenario_name, actor_layer, to_remove)

        elif method == "remove_from_groups":
            _remove_actors_from_groups(editor, scenario_name, actor_layer, scenario_config["actor_groups"], to_remove)

        elif method == "keep_from_groups":
            _remove_actors_not_in_groups(editor, scenario_name, actor_layer,
                                         scenario_config["actor_groups"], to_remove, to_keep)

    for reference in to_keep:
        to_remove.discard(reference)

    for actor in to_remove:
        editor.remove_entity(actor._asdict(), None)
