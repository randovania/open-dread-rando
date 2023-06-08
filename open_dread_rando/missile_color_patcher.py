from copy import deepcopy
from enum import Enum

from open_dread_rando.patcher_editor import PatcherEditor

from mercury_engine_data_structures.formats.bsmat import Bsmat

# model names for pride missiles
class MissileVariant(Enum):
    ORANGE = ("item_missile__OR", [75.0, 10.0, 0.0, 1.0])
    YELLOW = ("item_missile__YL", [30.0, 30.0, 0.0, 1.0])
    GREEN = ("item_missile__GR", [0.0, 30.0, 0.0, 1.0])
    BLUE = ("item_missile__BL", [0.05, 0.5, 75.0, 1.0])
    CYAN = ("item_missile__CY", [0.05, 10.0, 10.0, 1.0])
    PURPLE = ("item_missile__PR", [15.0, 0.5, 70.0, 1.0])
    PINK = ("item_missile__PK", [70.0, 0.5, 7.0, 1.0])
    MAGENTA = ("item_missile__MG", [70.0, 0.5, 70.0, 1.0])
    WHITE = ("item_missile__WH", [30.0, 30.0, 30.0, 1.0])
    BLACK = ("item_missile__BK", [0.0, 0.0, 0.0, 1.0])
    GRAY = ("item_missile__GY", [0.5, 0.5, 0.5, 1.0])


    def __init__(self, path: str, color: list[float]):
        self.mat_name = f"{path}_mp_fxhologram_01"
        self.shader_path = f"actors/items/item_missiletank/models/imats/{self.mat_name}.bsmat"

        if len(color) != 4:
            raise ValueError(f"Missile Variant {self.name} has {len(color)} values for RGBA, 4 is expected.")
        self.rgba = color

def generate_missile_colors(editor: PatcherEditor):
    mat = editor.get_file("actors/items/item_missiletank/models/imats/item_missiletank_mp_fxhologram_01.bsmat", Bsmat)

    for variant in MissileVariant:
        # copy missile material
        new_mat = deepcopy(mat)
        
        # replace texture name and vTex0EmissiveColor
        new_mat.raw.name = variant.mat_name
        tex0_emissive = new_mat.raw.shader_stages[0].uniform_params[5]
        tex0_emissive.value = variant.rgba

        editor.add_new_asset(variant.shader_path, new_mat, [])
