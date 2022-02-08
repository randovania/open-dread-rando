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

    "powerup_widebeam": ModelData(
        bcmdl_path="actors/items/powerup_widebeam/models/powerup_widebeam.bcmdl",
        dependencies=(
            "actors/items/powerup_widebeam/models/powerup_widebeam.bcmdl",
            "actors/items/powerup_widebeam/models/imats/powerup_widebeam_autoilum.bsmat",
            "actors/items/powerup_widebeam/models/imats/powerup_widebeam_bola.bsmat",
            "actors/items/powerup_widebeam/models/imats/powerup_widebeam_cangrejo.bsmat",
        ),
    ),

    "powerup_plasmabeam": ModelData(
        bcmdl_path="actors/items/powerup_plasmabeam/models/powerup_plasmabeam.bcmdl",
        dependencies=(
            "actors/items/powerup_plasmabeam/models/powerup_plasmabeam.bcmdl",
            "actors/items/powerup_plasmabeam/models/imats/powerup_plasmabeam_autoilum.bsmat",
            "actors/items/powerup_plasmabeam/models/imats/powerup_plasmabeam_body.bsmat",
            "actors/items/powerup_plasmabeam/models/imats/powerup_plasmabeam_mp_glass_01.bsmat",
        ),
    ),

    "powerup_chargebeam": ModelData(
        bcmdl_path="actors/items/powerup_chargebeam/models/powerup_chargebeam.bcmdl",
        dependencies=(
            "actors/items/powerup_chargebeam/models/powerup_chargebeam.bcmdl",
            "actors/items/powerup_chargebeam/models/imats/powerup_chargebeam_autoilum.bsmat",
            "actors/items/powerup_chargebeam/models/imats/powerup_chargebeam_body.bsmat",
            "actors/items/powerup_chargebeam/models/imats/powerup_chargebeam_mp_glass_01.bsmat",
        ),
    ),

    "powerup_diffusionbeam": ModelData(
        bcmdl_path="actors/items/powerup_diffusionbeam/models/powerup_diffusionbeam.bcmdl",
        dependencies=(
            "actors/items/powerup_diffusionbeam/models/powerup_diffusionbeam.bcmdl",
            "actors/items/powerup_diffusionbeam/models/imats/powerup_diffusionbeam_autoilum.bsmat",
            "actors/items/powerup_diffusionbeam/models/imats/powerup_diffusionbeam_mp_glass_01.bsmat",
            "actors/items/powerup_diffusionbeam/models/imats/powerup_diffusionbeam_mp_opaque_01.bsmat",
        ),
    ),

    "powerup_grapplebeam": ModelData(
        bcmdl_path="actors/items/powerup_grapplebeam/models/powerup_grapplebeam.bcmdl",
        dependencies=(
            "actors/items/powerup_grapplebeam/fx/auraitemparticle.bcptl",
            "actors/items/powerup_grapplebeam/models/powerup_grapplebeam.bcmdl",
            "actors/items/powerup_grapplebeam/models/imats/powerup_grapplebeam_grapplebeam.bsmat",
        ),
    ),

    "powerup_supermissile": ModelData(
        bcmdl_path="actors/items/powerup_supermissile/models/powerup_supermissile.bcmdl",
        dependencies=(
            "actors/items/powerup_supermissile/models/powerup_supermissile.bcmdl",
            "actors/items/powerup_supermissile/models/imats/powerup_supermissile_hologram.bsmat",
            "actors/items/powerup_supermissile/models/imats/powerup_supermissile_mp_opaque_01.bsmat",
        ),
    ),

    "powerup_ghostaura": ModelData(
        bcmdl_path="actors/items/powerup_ghostaura/models/powerup_ghostaura.bcmdl",
        dependencies=(
            "actors/items/powerup_ghostaura/models/powerup_ghostaura.bcmdl",
        ),
    ),

    "powerup_sonar": ModelData(
        bcmdl_path="actors/items/powerup_sonar/models/powerup_sonar.bcmdl",
        dependencies=(
            "actors/items/powerup_sonar/models/powerup_sonar.bcmdl",
        ),
    ),

    "powerup_variasuit": ModelData(
        bcmdl_path="actors/items/powerup_variasuit/models/powerup_variasuit.bcmdl",
        dependencies=(
            "actors/items/powerup_variasuit/models/powerup_variasuit.bcmdl",
            "actors/items/powerup_variasuit/models/imats/powerup_variasuit_material01.bsmat",
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

    "powerup_bomb": ModelData(
        bcmdl_path="actors/items/powerup_bomb/models/powerup_bomb.bcmdl",
        dependencies=(
            "actors/items/powerup_bomb/models/powerup_bomb.bcmdl",
            "actors/items/powerup_bomb/models/imats/powerup_bomb_hologram.bsmat",
            "actors/items/powerup_bomb/models/imats/powerup_bomb_material.bsmat",
        ),
    ),

    "powerup_doublejump": ModelData(
        bcmdl_path="actors/items/powerup_doublejump/models/powerup_doublejump.bcmdl",
        dependencies=(
            "actors/items/powerup_doublejump/models/powerup_doublejump.bcmdl",
            "actors/items/powerup_doublejump/models/imats/powerup_doublejump_mp_glass_01.bsmat",
            "actors/items/powerup_doublejump/models/imats/powerup_doublejump_mp_opaque_01.bsmat",
        ),
    ),

    "powerup_spacejump": ModelData(
        bcmdl_path="actors/items/powerup_spacejump/models/powerup_spacejump.bcmdl",
        dependencies=(
            "actors/items/powerup_spacejump/models/powerup_spacejump.bcmdl",
            "actors/items/powerup_spacejump/models/imats/powerup_spacejump_mat01.bsmat",
        ),
    ),

    "powerup_screwattack": ModelData(
        bcmdl_path="actors/items/powerup_screwattack/models/powerup_screwattack.bcmdl",
        dependencies=(
            "actors/items/powerup_screwattack/models/powerup_screwattack.bcmdl",
            "actors/items/powerup_screwattack/models/imats/powerup_screwattack_mp_opaque_01.bsmat",
        ),
    ),

    "item_energytank": ModelData(
        bcmdl_path="actors/items/item_energytank/models/item_energytank.bcmdl",
        dependencies=(
            "actors/items/item_energytank/models/item_energytank.bcmdl",
            "actors/items/item_energytank/models/imats/item_energytank_mp_opaque_01.bsmat",
        ),
    ),

    "item_energyfragment": ModelData(
        bcmdl_path="actors/items/item_energyfragment/models/item_energyfragment.bcmdl",
        dependencies=(
            "actors/items/item_energyfragment/models/item_energyfragment.bcmdl",
            "actors/items/item_energyfragment/models/imats/item_energyfragment_glow.bsmat",
            "actors/items/item_energyfragment/models/imats/item_energyfragment_inner.bsmat",
            "actors/items/item_energyfragment/models/imats/item_energyfragment_mat01.bsmat",
            "actors/items/item_energyfragment/models/imats/item_energyfragment_mat02.bsmat",
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
}


def get_data(name: str) -> ModelData:
    return ALL_MODEL_DATA.get(name, ALL_MODEL_DATA["itemsphere"])
