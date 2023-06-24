import copy
import dataclasses
import typing

from mercury_engine_data_structures.formats.bsmat import Bsmat
from open_dread_rando.patcher_editor import PatcherEditor


@dataclasses.dataclass(frozen=True)
class MaterialData:
    base_mat: str # path to the "base" material
    new_mat_name: str = None # the name of the new material
    new_path: str = None # the new path for the material, none if its only modifiying an existing mat
    uniform_params: dict[str, list] = None # a dictionary of uniform params stored in shader_stages[0]
    sampler_params: dict[str, dict[str, typing.Union[str, int, float, list]]] = None 
    # a dictionary of sampler params stored in shader_stages[0]
    # key is the name of the sampler param
    # value is a dict of key/value pairs for keys of the sampler (i.e. { "filepath": "path/to/texture.bsmat" })

def create_custom_material(editor: PatcherEditor, material_data: MaterialData) -> Bsmat:
    orig_mat = editor.get_parsed_asset(material_data.base_mat, type_hint=Bsmat)

    # make this a deepcopy if it is a new material
    mat = copy.deepcopy(orig_mat) if material_data.new_path else orig_mat
    
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
            for sam_key, sam_value in sam_dict.items():
                sampler[sam_key] = sam_value

    if material_data.new_path:
        editor.add_new_asset(material_data.new_path, mat, [])

    return mat