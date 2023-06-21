import dataclasses

from open_dread_rando.patcher_editor import PatcherEditor
from open_dread_rando.material_patcher import MaterialData, create_custom_material
from open_dread_rando.model_patcher import ModelData, create_custom_model

# model names for pride missiles
@dataclasses.dataclass()
class MissileVariant:
    mat_name: str
    model_path: str
    shader_path: str
    rgba: tuple[float, float, float, float]

    def __init__(self, name: str, color: tuple[float, float, float, float]):
        self.mat_name = f"{name}_mp_fxhologram_01"
        self.model_path = f"actors/items/item_missiletank/models/{name}.bcmdl"
        self.shader_path = f"actors/items/item_missiletank/models/imats/{self.mat_name}.bsmat"

        self.rgba = color
    
ALL_VARIANTS: dict[str, MissileVariant] = {
    
    "ORANGE": MissileVariant(
        name="item_missile__OR", 
        color=[75.0, 10.0, 0.0, 1.0]
    ),
    "YELLOW": MissileVariant(
        name="item_missile__YL", 
        color=[30.0, 30.0, 0.0, 1.0]
    ),
    "GREEN": MissileVariant(
        name="item_missile__GN", 
        color=[0.0, 30.0, 0.0, 1.0]
    ),
    "BLUE": MissileVariant(
        name="item_missile__BL", 
        color=[0.05, 0.5, 75.0, 1.0]
    ),
    "CYAN": MissileVariant(
        name="item_missile__CY", 
        color=[0.05, 10.0, 10.0, 1.0]
    ),
    "PURPLE": MissileVariant(
        name="item_missile__PR", 
        color=[15.0, 0.5, 70.0, 1.0]
    ),
    "PINK": MissileVariant(
        name="item_missile__PK", 
        color=[70.0, 0.5, 7.0, 1.0]
    ),
    "MAGENTA": MissileVariant(
        name="item_missile__MG",
        color=[70.0, 0.5, 70.0, 1.0]
    ),
    "WHITE": MissileVariant(
        name="item_missile__WH",
        color=[30.0, 30.0, 30.0, 1.0]
    ),
    "BLACK": MissileVariant(
        name="item_missile__BK",
        color=[0.0, 0.0, 0.0, 1.0]
    ),
    "GRAY": MissileVariant(
        name="item_missile__GY",
        color=[0.2, 0.2, 0.2, 1.0]
    ),
}

def generate_missile_colors(editor: PatcherEditor):
    for _, variant in ALL_VARIANTS.items():
        mat_dat = MaterialData(
            base_mat="actors/items/item_missiletank/models/imats/item_missiletank_mp_fxhologram_01.bsmat",
            new_mat_name=variant.mat_name,
            new_path=variant.shader_path,
            uniform_params={
                "vTex0EmissiveColor": variant.rgba
            }
        )

        model_dat = ModelData(
            base_model="actors/items/item_missiletank/models/item_missiletank.bcmdl",
            new_path=variant.model_path,
            materials={"mp_fxhologram_01": variant.shader_path}
        )

        create_custom_material(editor, mat_dat)
        create_custom_model(editor, model_dat)
