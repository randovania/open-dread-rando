import dataclasses

from open_dread_rando.misc_patches.material_patcher import MaterialData
from open_dread_rando.misc_patches.model_patcher import StaticModelChanger
from open_dread_rando.patcher_editor import PatcherEditor


# model names for pride missiles
@dataclasses.dataclass()
class MissileTankRecolor(StaticModelChanger):
    def __init__(self, name: str, color: tuple[float, float, float, float]):
        self.materials = {
            "mp_fxhologram_01": MaterialData(
                base_mat="actors/items/item_missiletank/models/imats/item_missiletank_mp_fxhologram_01.bsmat",
                new_mat_name=f"{name}_mp_fxhologram_01",
                new_path=f"actors/items/item_missiletank/models/imats/{name}_mp_fxhologram_01.bsmat",
                uniform_params={
                    "vTex0EmissiveColor": color
                }
            )
        }

        self.base_model_path="actors/items/item_missiletank/models/item_missiletank.bcmdl"
        self.new_model_path=f"actors/items/item_missiletank/models/{name}.bcmdl"


MISSILE_TANK_RECOLORS: dict[str, MissileTankRecolor] = {
    "ORANGE": MissileTankRecolor(
        name="item_missile__OR",
        color=(75.0, 10.0, 0.0, 1.0),
    ),
    "YELLOW": MissileTankRecolor(
        name="item_missile__YL",
        color=(30.0, 30.0, 0.0, 1.0),
    ),
    "GREEN": MissileTankRecolor(
        name="item_missile__GN",
        color=(0.0, 30.0, 0.0, 1.0),
    ),
    "BLUE": MissileTankRecolor(
        name="item_missile__BL",
        color=(0.05, 0.5, 75.0, 1.0),
    ),
    "CYAN": MissileTankRecolor(
        name="item_missile__CY",
        color=(0.05, 10.0, 10.0, 1.0),
    ),
    "PURPLE": MissileTankRecolor(
        name="item_missile__PR",
        color=(15.0, 0.5, 70.0, 1.0),
    ),
    "PINK": MissileTankRecolor(
        name="item_missile__PK",
        color=(70.0, 0.5, 7.0, 1.0),
    ),
    "MAGENTA": MissileTankRecolor(
        name="item_missile__MG",
        color=(70.0, 0.5, 70.0, 1.0),
    ),
    "WHITE": MissileTankRecolor(
        name="item_missile__WH",
        color=(30.0, 30.0, 30.0, 1.0),
    ),
    "BLACK": MissileTankRecolor(
        name="item_missile__BK",
        color=(0.0, 0.0, 0.0, 1.0),
    ),
    "GRAY": MissileTankRecolor(
        name="item_missile__GY",
        color=(0.2, 0.2, 0.2, 1.0),
    ),
}


def generate_missile_colors(editor: PatcherEditor):
    for _, recolor in MISSILE_TANK_RECOLORS.items():
        recolor.generate(editor)
