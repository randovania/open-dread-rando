import copy
import dataclasses

from mercury_engine_data_structures.formats.bcmdl import Bcmdl
from open_dread_rando.patcher_editor import PatcherEditor


@dataclasses.dataclass(frozen=True)
class ModelData:
    base_model: str
    new_path: str = None
    materials: dict[str, str] = None


def create_custom_model(editor: PatcherEditor, model_data: ModelData) -> Bcmdl:
    orig_mat = editor.get_parsed_asset(model_data.base_model, type_hint=Bcmdl)
    
    if model_data.new_path is not None:
        mdl = copy.deepcopy(orig_mat)
        editor.add_new_asset(model_data.new_path, mdl, [])
    else:
        mdl = orig_mat

    if model_data.materials is not None:
        for mat_name, mat_path in model_data.materials.items():
          mdl.change_material_path(mat_name, mat_path)  

    return mdl