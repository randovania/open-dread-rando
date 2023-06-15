import dataclasses
from copy import deepcopy

from open_dread_rando.patcher_editor import PatcherEditor

from mercury_engine_data_structures.formats.bsmat import Bsmat

# model names for pride missiles
@dataclasses.dataclass()
class MissileVariant:
    mat_name: str
    shader_path: str
    rgba: tuple[float, float, float, float]

    def __init__(self, name: str, color: tuple[float, float, float, float]):
        self.mat_name = f"{name}_mp_fxhologram_01"
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
    mat = editor.get_file("actors/items/item_missiletank/models/imats/item_missiletank_mp_fxhologram_01.bsmat", Bsmat)

    for _, variant in ALL_VARIANTS.items():
        # copy missile material
        new_mat = deepcopy(mat)

        # replace texture name and vTex0EmissiveColor
        new_mat.raw.name = variant.mat_name
        tex0_emissive = new_mat.raw.shader_stages[0].uniform_params[5]
        tex0_emissive.value = variant.rgba

        editor.add_new_asset(variant.shader_path, new_mat, [])
