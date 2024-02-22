import dataclasses
import typing

from mercury_engine_data_structures.formats.bcmdl import Bcmdl

from open_dread_rando.misc_patches.material_patcher import MaterialData, create_custom_material
from open_dread_rando.patcher_editor import PatcherEditor


@dataclasses.dataclass(frozen=True)
class ModelData:
    base_model: str  # the model this is based on

    # the new path of the model
    new_path: typing.Optional[str] = None

    # dictionary connecting model names (i.e. "mp_opaque_01") to material files
    materials: typing.Optional[dict[str, str]] = None

# contains static data to generate model/material changes
@dataclasses.dataclass()
class StaticModelChanger:
    base_model_path: str
    new_model_path: str
    materials: dict[str, MaterialData] # key is material name in bcmdl

    def generate(self, editor: PatcherEditor):
        mats: dict[str, str] = {}

        for name, mat in self.materials.items():
            create_custom_material(editor, mat)
            mats[name] = mat.new_path

        create_custom_model(editor, ModelData(
            base_model=self.base_model_path,
            new_path=self.new_model_path,
            materials=mats
        ))


ADVANCED_RECOLORS: dict[str, StaticModelChanger] = {
    "item_supermissiletank": StaticModelChanger(
        base_model_path="actors/items/item_missiletankplus/models/item_missiletankplus.bcmdl",
        new_model_path="actors/items/item_missiletankplus/models/super_missile_tank.bcmdl",
        materials={
            "mat01": MaterialData(
                base_mat="actors/items/item_missiletankplus/models/imats/item_missiletankplus_mat01.bsmat",
                new_mat_name="supermissiletank_mat01",
                new_path="actors/items/item_missiletankplus/models/imats/super_missile_tank_mat01.bsmat",
                uniform_params={
                    "vConstant0": (0.0, 10.0, 0.15, 1.0)
                }
            ),
            "mp_fxhologram_01": MaterialData(
                base_mat="actors/items/item_missiletankplus/models/imats/item_missiletankplus_mp_fxhologram_01.bsmat",
                new_mat_name="supermissiletank_mp_fxhologram_01",
                new_path="actors/items/item_missiletankplus/models/imats/super_missile_tank_mp_fxhologram_01.bsmat",
                uniform_params={
                    "vTex0EmissiveColor": (10.0, 10.0, 10.0, 1.0)
                }
            )
        }
    )
}

def create_custom_model(editor: PatcherEditor, model_data: ModelData) -> Bcmdl:
    mdl = editor.get_parsed_asset(model_data.base_model, type_hint=Bcmdl)

    if model_data.materials is not None:
        for mat_name, mat_path in model_data.materials.items():
            editor.check_file_exists(mat_path, "Custom model material")
            mdl.change_material_path(mat_name, mat_path)

    if model_data.new_path:
        editor.add_new_asset(model_data.new_path, mdl, [])

    return mdl

def generate_custom_models(editor: PatcherEditor):
    for _, recolor in ADVANCED_RECOLORS.items():
        recolor.generate(editor)
