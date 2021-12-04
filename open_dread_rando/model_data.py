import dataclasses


@dataclasses.dataclass(frozen=True)
class ModelData:
    bcmdl_path: str
    dependencies: tuple[str, ...]


ALL_MODEL_DATA: dict[str, ModelData] = {
    "itemsphere": ModelData(
        bcmdl_path="actors/items/itemsphere/models/itemsphere.bcmdl",
        dependencies=(
            "actors/items/itemsphere/animations/relax.bcskla",
            "actors/items/itemsphere/collisions/itemsphere.bmscd",
            "actors/items/itemsphere/fx/impact.bcptl",
            "actors/items/itemsphere/fx/impact_itemsphere.bcmdl",
            "actors/items/itemsphere/fx/impact_itemsphere.bcskla",
            "actors/items/itemsphere/fx/imats/impact_itemsphere_itemsphere.bsmat",
            "actors/items/itemsphere/models/itemsphere.bcmdl",
            "actors/items/itemsphere/models/imats/itemsphere_mp_opaque_01.bsmat",
        ),
    ),
    "item_missiletank": ModelData(
        bcmdl_path="actors/items/item_missiletank/models/item_missiletank.bcmdl",
        dependencies=(
            "actors/items/item_missiletank/models/item_missiletank.bcmdl",
            "actors/items/item_missiletank/models/imats/item_missiletank_mat01.bsmat",
            "actors/items/item_missiletank/models/imats/item_missiletank_mp_fxhologram_01.bsmat",
        ),
    ),
    "item_missiletankplus": ModelData(
        bcmdl_path="actors/items/item_missiletankplus/models/item_missiletankplus.bcmdl",
        dependencies=(
            "actors/items/item_missiletankplus/models/item_missiletankplus.bcmdl",
            "actors/items/item_missiletankplus/models/imats/item_missiletankplus_mat01.bsmat",
            "actors/items/item_missiletankplus/models/imats/item_missiletankplus_mp_fxhologram_01.bsmat",
        ),
    ),
    "item_powerbombtank": ModelData(
        bcmdl_path="actors/items/item_powerbombtank/models/item_powerbombtank.bcmdl",
        dependencies=(
            "actors/items/item_powerbombtank/models/item_powerbombtank.bcmdl",
            "actors/items/item_powerbombtank/models/imats/item_powerbombtank_mat01.bsmat",
            "actors/items/item_powerbombtank/models/imats/item_powerbombtank_mp_fxhologram_01.bsmat",
        ),
    ),
    "item_energytank": ModelData(
        bcmdl_path="actors/items/item_energytank/models/item_energytank.bcmdl",
        dependencies=(
            "actors/items/item_energytank/models/item_energytank.bcmdl",
            "actors/items/item_energytank/models/imats/item_energytank_mp_opaque_01.bsmat",
        ),
    ),
    "powerup_spacejump": ModelData(
        bcmdl_path="actors/items/powerup_spacejump/models/powerup_spacejump.bcmdl",
        dependencies=(
            "actors/items/powerup_spacejump/models/powerup_spacejump.bcmdl",
            "actors/items/powerup_spacejump/models/imats/powerup_spacejump_mat01.bsmat",
        ),
    ),
    "powerup_gravitysuit": ModelData(
        bcmdl_path="actors/items/powerup_gravitysuit/models/powerup_gravitysuit.bcmdl",
        dependencies=(
            "actors/items/powerup_gravitysuit/models/powerup_gravitysuit.bcmdl",
            "actors/items/powerup_gravitysuit/models/imats/powerup_gravitysuit_ball.bsmat",
            "actors/items/powerup_gravitysuit/models/imats/powerup_gravitysuit_grav.bsmat",
            "actors/items/powerup_gravitysuit/models/imats/powerup_gravitysuit_mp_opaque_01.bsmat",
        ),
    ),
}
