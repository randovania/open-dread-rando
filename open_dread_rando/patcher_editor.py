import shutil
import typing
from pathlib import Path

from construct import Container
from mercury_engine_data_structures.file_tree_editor import FileTreeEditor
from mercury_engine_data_structures.formats import BaseResource, Brfld, Brsa, ALL_FORMATS, Bmmap

T = typing.TypeVar("T")


def path_for_level(level_name: str) -> str:
    return f"maps/levels/c10_samus/{level_name}/{level_name}"


def extension_for_type(type_hint: typing.Type[T]) -> str:
    return next(ext for ext, t in ALL_FORMATS.items() if t == type_hint).lower()


class PatcherEditor(FileTreeEditor):
    memory_files: dict[str, BaseResource]

    def __init__(self, root: Path):
        super().__init__(root)
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
            self.get_scenario_map(reference["scenario"]).raw.Root[map_category].pop(actor_name)

