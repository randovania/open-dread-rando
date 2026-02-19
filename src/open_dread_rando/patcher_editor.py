import copy
import shutil
import typing
from pathlib import Path

from construct import Container
from mercury_engine_data_structures.base_resource import BaseResource
from mercury_engine_data_structures.file_tree_editor import FileTreeEditor
from mercury_engine_data_structures.formats import ALL_FORMATS, Bmmap, Brfld, Brsa
from mercury_engine_data_structures.formats.brfld import ActorLayer
from mercury_engine_data_structures.game_check import Game
from mercury_engine_data_structures.romfs import ExtractedRomFs

from open_dread_rando.pickups.map_icons import MapIconEditor

T = typing.TypeVar("T")


def path_for_level(level_name: str) -> str:
    return f"maps/levels/c10_samus/{level_name}/{level_name}"


def extension_for_type(type_hint: type[T]) -> str:
    return next(ext for ext, t in ALL_FORMATS.items() if t == type_hint).lower()


class PatcherEditor(FileTreeEditor):
    memory_files: dict[str, BaseResource]
    map_icon_editor: MapIconEditor

    def __init__(self, root: Path):
        super().__init__(ExtractedRomFs(root), target_game=Game.DREAD)
        self.memory_files = {}
        self.map_icon_editor = MapIconEditor(self)

    def get_file(self, path: str, type_hint: type[T] = BaseResource) -> T:
        if path not in self.memory_files:
            self.memory_files[path] = self.get_parsed_asset(path, type_hint=type_hint)
        return self.memory_files[path]

    def get_scenario_file(self, name: str, type_hint: type[T]) -> T:
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
        actor_layer = ActorLayer(ref.get("actor_layer", "rEntitiesLayer"))
        sublayer = ref.get("sublayer", ref.get("layer", "default"))
        return scenario.actors_for_sublayer(sublayer, actor_layer)[ref["actor"]]

    def flush_modified_assets(self):
        for name, resource in self.memory_files.items():
            self.replace_asset(name, resource)
        self.memory_files = {}

    def add_new_asset(self, name: str, new_data: bytes | BaseResource, in_pkgs: typing.Iterable[str]):
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

    def remove_entity(self, reference: dict, map_category: str | None):
        scenario = self.get_scenario(reference["scenario"])
        actor_layer = ActorLayer(reference.get("actor_layer", "rEntitiesLayer"))
        sublayer = reference.get("sublayer", reference.get("layer", "default"))
        actor_name = reference["actor"]

        for group_name in scenario.actor_groups_for_actor_layer(actor_layer):
            if scenario.is_actor_in_group(group_name, actor_name, sublayer, actor_layer):
                scenario.remove_actor_from_group(group_name, actor_name, sublayer, actor_layer)

        scenario.actors_for_sublayer(sublayer, actor_layer).pop(actor_name)
        if map_category is not None:
            self.get_scenario_map(reference["scenario"]).raw.Root[map_category].pop(actor_name)

    def copy_actor_groups(self, base_reference: dict, new_reference: dict, scenario_name: str,
                          actor_layer: ActorLayer = ActorLayer.ENTITIES):
        """
        Copies a base actor's groups to a new actor's groups. Both actors must be in the same scenario and actor layer.

        param base_reference: a reference to the actor to copy the groups from
        param new_reference: a reference to the actor to copy the groups to
        """
        scenario = self.get_scenario(scenario_name)

        base_sublayer = base_reference.get("sublayer", base_reference.get("layer", "default"))
        base_actor_name = base_reference["actor"]
        new_sublayer = new_reference.get("sublayer", new_reference.get("layer", base_sublayer))
        new_actor_name = new_reference["actor"]

        for group_name in scenario.actor_groups_for_actor_layer(actor_layer):
            base_actor_in_group = scenario.is_actor_in_group(group_name, base_actor_name, base_sublayer, actor_layer)
            new_actor_in_group = scenario.is_actor_in_group(group_name, new_actor_name, new_sublayer, actor_layer)

            if base_actor_in_group and not new_actor_in_group:
                scenario.add_actor_to_group(group_name, new_actor_name, new_sublayer, actor_layer)
            elif not base_actor_in_group and new_actor_in_group:
                scenario.remove_actor_from_group(group_name, new_actor_name, new_sublayer, actor_layer)

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
        currentScenario.actors_for_sublayer("default")[newActor.sName] = newActor
        newActor.vPos = [float(c) + offset for c, offset in zip(coords, offset)]

        return newActor

    def find_type_of_actor(self, scenario_name: str, actordef: str,
                           actor_layer: ActorLayer = ActorLayer.ENTITIES) -> list[tuple[str, str, Container]]:
        """
        Get every actor with given actordef in a scenario

        param scenario: the name of the scenario
        param actordef: the actor definition (bmsad) to filter for
        param sublayer: if provided, the sublayer to search in, otherwise default sublayer
        param actor_layer: if provided, the actor layer to search in, otherwise entities layer
        returns: for each actor that matches the criteria: actor name, actor
        """
        scenario = self.get_scenario(scenario_name)
        filtered = []

        for sublayer, actor_name, actor in scenario.all_actors_in_actor_layer(actor_layer):
            a = self.resolve_actor_reference({
                "actor": actor_name,
                "sublayer": sublayer,
                "actor_layer": actor_layer,
                "scenario": scenario_name
            })

            if a.oActorDefLink.split(':')[1] == actordef:
                filtered.append((sublayer, actor_name, actor))

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

        actor_layer = split_link[2]
        sublayer = split_link[4]
        actor = split_link[6]

        return {
            "scenario": scenario,
            "actor_layer": actor_layer,
            "sublayer": sublayer,
            "actor": actor,
        }

    def build_link(self, sname: str, sublayer: str = "default", actor_layer: ActorLayer = ActorLayer.ENTITIES) -> str:
        return f"Root:pScenario:{actor_layer.value}:dctSublayers:{sublayer}:dctActors:{sname}"

    def get_asset_names_in_folder(self, folder: str) -> typing.Iterator[str]:
        yield from (name for name in self._name_for_asset_id.values() if name.startswith(folder))

    def check_file_exists(self, file_name: str, description: str = "Asset") -> None:
        actual_path = file_name
        if file_name.endswith(".bctex") and not file_name.startswith("textures/"):
            actual_path = "textures/" + file_name

        if not self.does_asset_exists(actual_path):
            raise ValueError(f"{description} {actual_path} does not exist.")
