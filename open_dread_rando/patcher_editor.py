import copy
import shutil
import typing
from pathlib import Path

from construct import Container
from mercury_engine_data_structures.file_tree_editor import FileTreeEditor
from mercury_engine_data_structures.formats import BaseResource, Brfld, Brsa, ALL_FORMATS, Bmmap
from mercury_engine_data_structures.game_check import Game
from open_dread_rando.logger import LOG

T = typing.TypeVar("T")


def path_for_level(level_name: str) -> str:
    return f"maps/levels/c10_samus/{level_name}/{level_name}"


def extension_for_type(type_hint: typing.Type[T]) -> str:
    return next(ext for ext, t in ALL_FORMATS.items() if t == type_hint).lower()


class PatcherEditor(FileTreeEditor):
    memory_files: dict[str, BaseResource]

    def __init__(self, root: Path):
        super().__init__(root, target_game=Game.DREAD)
        self.memory_files = {}

    def get_file(self, path: str, type_hint: typing.Type[T] = BaseResource) -> T:
        if path not in self.memory_files:
            self.memory_files[path] = self.get_parsed_asset(path, type_hint=type_hint)
        return self.memory_files[path]

    def get_scenario_file(self, name: str, type_hint: typing.Type[T]) -> T:
        path = f"{path_for_level(name)}.{extension_for_type(type_hint)}"
        return self.get_file(path, type_hint)

    def get_scenario(self, name: str) -> Brfld:
        return self.get_scenario_file(name, Brfld)

    def get_subarea_manager(self, name: str) -> Brsa:
        return self.get_scenario_file(name, Brsa)

    def get_scenario_map(self, name: str) -> Bmmap:
        return self.get_scenario_file(name, Bmmap)

    def get_level_pkgs(self, name: str) -> set[str]:
        return set(self.find_pkgs(path_for_level(name) + ".brfld"))

    def ensure_present_in_scenario(self, scenario: str, asset):
        for pkg in self.get_level_pkgs(scenario):
            self.ensure_present(pkg, asset)

    def resolve_actor_reference(self, ref: dict) -> Container:
        scenario = self.get_scenario(ref["scenario"])
        layer = ref.get("layer", "default")
        return scenario.actors_for_layer(layer)[ref["actor"]]

    def flush_modified_assets(self):
        for name, resource in self.memory_files.items():
            self.replace_asset(name, resource)
        self.memory_files = {}

    def add_new_asset(self, name: str, new_data: typing.Union[bytes, BaseResource], in_pkgs: typing.Iterable[str]):
        super().add_new_asset(name, new_data, in_pkgs)
        # Hack for textures' weird folder layout
        if name.startswith("textures/") and isinstance(new_data, bytes):
            self._toc.add_file(name[9:], len(new_data))

    def save_modified_saves_to(self, debug_path: Path):
        shutil.rmtree(debug_path, ignore_errors=True)
        for asset_id, asset in self._modified_resources.items():
            if asset is not None:
                path = debug_path.joinpath(self._name_for_asset_id[asset_id])
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(asset)

    def remove_entity(self, reference: dict, map_category: typing.Optional[str]):
        scenario = self.get_scenario(reference["scenario"])
        layer = reference.get("layer", "default")
        actor_name = reference["actor"]

        for group_name in scenario.all_actor_groups():
            scenario.remove_actor_from_group(group_name, actor_name, layer)

        scenario.actors_for_layer(layer).pop(actor_name)
        if map_category is not None:
            category = self.get_scenario_map(reference["scenario"]).raw.Root[map_category]
            if actor_name in category:
                category.pop(actor_name)
            else:
                LOG.debug(f"Entity {actor_name} in scenario {reference['scenario']} does not exist in map category {map_category}")

    def copy_actor_groups(self, scenario_name: str, base_actor_name: str, new_actor_name: str):
        """
        Copies a base actor's groups to a new actor's groups. Both actors must be in the same scenario. 
        
        param baseRef: the actor that you are copying groups from
        param newRef: the actor that will have the same actor groups as baseRef
        """
        scenario = self.get_scenario(scenario_name)
        for group_name in scenario.all_actor_groups():
            if (scenario.is_actor_in_group(group_name, base_actor_name)):
                scenario.add_actor_to_group(group_name, new_actor_name)
            else:
                scenario.remove_actor_from_group(group_name, new_actor_name)

    def copy_actor(self, scenario: str, coords, templateActor: Container, newName: str, offset: tuple = (0, 0, 0)):
        """
        Copies an actor into a scenario at a specific location

        @param scenario: the scenario to place the door
        @param coords: the position coordinate to place the door
        @param actor: The actor to be copied into door's scenario
        @param sName: The name of the new actor
        @param offset: a tuple containing the offset coordinates, if any
        @returns: the new copied actor
        """
        # print(coords)
        newActor = copy.deepcopy(templateActor)
        newActor.sName = newName
        currentScenario = self.get_scenario(scenario)
        currentScenario.actors_for_layer('default')[newActor.sName] = newActor
        newActor.vPos = [float(c) + offset for c, offset in zip(coords, offset)]

        return newActor

    def find_type_of_actor(self, scenarioStr: str, actordef: str, layer: str = "default"):
        """
        Returns a list of actors with given actordef in the scenario
        
        param scenario: the scenario string
        param layer: an optional layer to filter, standard layer is default
        param actordef: the actor definition (bmsad) to filter for
        returns: a list of all actors that match the criteria
        """
        scenario = self.get_scenario(scenarioStr)
        actors_on_layer = scenario.actors_for_layer(layer)
        filtered = []
        for actor in actors_on_layer:
            a = self.resolve_actor_reference({"actor": actor, "layer": layer, "scenario": scenarioStr})
            if a.oActorDefLink.split(':')[1] == actordef:
                filtered.append(actor)
        return filtered

    def reference_for_link(self, link: str, scenario: str) -> dict:
        """
        Changes a link string (wp data type) into a reference dict
        
        param link: a reference string consisting of 7 components separated by colons
        param scenario: the scenario this actor is in
        returns: a reference dict
        """
        split_link = link.split(":")
        if len(split_link) != 7:
            raise ValueError(f"Expected 7 components in {link}, got {len(split_link)}")

        layer = split_link[4]
        actor = split_link[6]

        return {
            "scenario": scenario,
            "layer": layer,
            "actor": actor,
        }

    def get_asset_names_in_folder(self, folder: str) -> typing.Iterator[str]:
        yield from (name for name in self._name_for_asset_id.values() if name.startswith(folder))
