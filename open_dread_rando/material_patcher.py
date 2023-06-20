import copy
import dataclasses

from mercury_engine_data_structures.formats.bsmat import Bsmat
from open_dread_rando.patcher_editor import PatcherEditor


@dataclasses.dataclass(frozen=True)
class MaterialData:
    base_mat: str
    new_mat_name: str = None
    new_path: str = None
    uniform_params: dict[str, list] = None
    sampler_params: dict[str, dict[str, str | list | int]] = None


def create_custom_material(editor: PatcherEditor, material_data: MaterialData) -> Bsmat:
    orig_mat = editor.get_parsed_asset(material_data.base_mat, type_hint=Bsmat)

    # deepcopy and add asset if this is a new material
    if material_data.new_path is not None:
        mat = copy.deepcopy(orig_mat)
        editor.add_new_asset(material_data.new_mat_name, mat, [])
    else:
        mat = orig_mat

    # update name
    if material_data.new_mat_name:
        mat.raw.name = material_data.new_mat_name
    
    # update uniforms
    if material_data.uniform_params:
        for uni_name, uni_value in material_data.uniform_params.items():
            mat.get_uniform(uni_name).value = uni_value
    
    # update samplers
    if material_data.sampler_params:
        for sam_name, sam_dict in material_data.sampler_params.items():
            sampler = mat.get_sampler(sam_name)
            for sam_key, sam_value in sam_dict:
                sampler[sam_key] = sam_value

    return mat