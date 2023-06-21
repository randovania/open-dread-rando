import copy
import dataclasses

from mercury_engine_data_structures.formats.bcmdl import Bcmdl
from open_dread_rando.patcher_editor import PatcherEditor


@dataclasses.dataclass(frozen=True)
class ModelData:
    base_model: str # the model this is based on
    new_path: str = None # the new path of the model
    materials: dict[str, str] = None # dictionary connecting model names (i.e. "mp_opaque_01") to material files


def create_custom_model(editor: PatcherEditor, model_data: ModelData) -> Bcmdl:
    orig_mdl = editor.get_parsed_asset(model_data.base_model, type_hint=Bcmdl)
    
    mdl = copy.deepcopy(orig_mdl)

    if model_data.materials is not None:
        for mat_name, mat_path in model_data.materials.items():
          mdl.change_material_path(mat_name, mat_path)  

    if model_data.new_path:
        editor.add_new_asset(model_data.new_path, mdl, [])
    
    return mdl