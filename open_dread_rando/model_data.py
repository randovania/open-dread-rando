import dataclasses
from typing import Optional, Tuple


@dataclasses.dataclass(frozen=True)
class Transform:
    position: Tuple[float, float, float] = (0.0, 0.0, 0.0)
    angle: Tuple[float, float, float] = (0.0, 0.0, 0.0)
    scale: Tuple[float, float, float] = (1.0, 1.0, 1.0)

@dataclasses.dataclass(frozen=True)
class ModelData:
    bcmdl_path: str
    bmsas: str
    dependencies: tuple[str, ...]
    grapple_fx: bool = False
    transform: Optional[Transform] = None


ALL_MODEL_DATA: dict[str, ModelData] = {
    "itemsphere": ModelData(
        bcmdl_path="actors/items/itemsphere/models/itemsphere.bcmdl",
        bmsas="actors/items/itemsphere/charclasses/timeline.bmsas",
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

    "powerup_speedbooster": ModelData(
        bcmdl_path="actors/items/itemsphere/models/speed_booster.bcmdl",
        bmsas="actors/items/itemsphere/charclasses/timeline.bmsas",
        dependencies=(
            "actors/items/itemsphere/animations/relax.bcskla",
            "actors/items/itemsphere/collisions/itemsphere.bmscd",
            "actors/items/itemsphere/fx/impact.bcptl",
            "actors/items/itemsphere/fx/impact_itemsphere.bcmdl",
            "actors/items/itemsphere/fx/impact_itemsphere.bcskla",
            "actors/items/itemsphere/fx/imats/impact_itemsphere_itemsphere.bsmat",
            "actors/items/itemsphere/models/speed_booster.bcmdl",
            "actors/items/itemsphere/models/imats/speedboost_mp_opaque_01.bsmat",
        ),
    ),

    "powerup_widebeam": ModelData(
        bcmdl_path="actors/items/powerup_widebeam/models/powerup_widebeam.bcmdl",
        bmsas="actors/items/powerup_widebeam/charclasses/powerup_widebeam.bmsas",
        dependencies=(
            "actors/items/powerup_widebeam/models/powerup_widebeam.bcmdl",
            "actors/items/powerup_widebeam/models/imats/powerup_widebeam_autoilum.bsmat",
            "actors/items/powerup_widebeam/models/imats/powerup_widebeam_bola.bsmat",
            "actors/items/powerup_widebeam/models/imats/powerup_widebeam_cangrejo.bsmat",
        ),
    ),

    "powerup_wavebeam": ModelData(
        bcmdl_path="actors/items/powerup_widebeam/models/powerup_wavebeam.bcmdl",
        bmsas="actors/items/powerup_widebeam/charclasses/powerup_widebeam.bmsas",
        dependencies=(
            "actors/items/powerup_widebeam/models/powerup_wavebeam.bcmdl",
            "actors/items/powerup_widebeam/models/imats/powerup_wavebeam_autoilum.bsmat",
            "actors/items/powerup_widebeam/models/imats/powerup_wavebeam_bola.bsmat",
            "actors/items/powerup_widebeam/models/imats/powerup_wavebeam_cangrejo.bsmat",
        ),
    ),

    "powerup_plasmabeam": ModelData(
        bcmdl_path="actors/items/powerup_plasmabeam/models/powerup_plasmabeam.bcmdl",
        bmsas="actors/items/powerup_plasmabeam/charclasses/powerup_plasmabeam.bmsas",
        dependencies=(
            "actors/items/powerup_plasmabeam/models/powerup_plasmabeam.bcmdl",
            "actors/items/powerup_plasmabeam/models/imats/powerup_plasmabeam_autoilum.bsmat",
            "actors/items/powerup_plasmabeam/models/imats/powerup_plasmabeam_body.bsmat",
            "actors/items/powerup_plasmabeam/models/imats/powerup_plasmabeam_mp_glass_01.bsmat",
        ),
    ),

    "powerup_chargebeam": ModelData(
        bcmdl_path="actors/items/powerup_chargebeam/models/powerup_chargebeam.bcmdl",
        bmsas="actors/items/powerup_chargebeam/charclasses/powerup_chargebeam.bmsas",
        dependencies=(
            "actors/items/powerup_chargebeam/models/powerup_chargebeam.bcmdl",
            "actors/items/powerup_chargebeam/models/imats/powerup_chargebeam_autoilum.bsmat",
            "actors/items/powerup_chargebeam/models/imats/powerup_chargebeam_body.bsmat",
            "actors/items/powerup_chargebeam/models/imats/powerup_chargebeam_mp_glass_01.bsmat",
        ),
    ),

    "powerup_diffusionbeam": ModelData(
        bcmdl_path="actors/items/powerup_diffusionbeam/models/powerup_diffusionbeam.bcmdl",
        bmsas="actors/items/powerup_diffusionbeam/charclasses/powerup_diffusionbeam.bmsas",
        dependencies=(
            "actors/items/powerup_diffusionbeam/models/powerup_diffusionbeam.bcmdl",
            "actors/items/powerup_diffusionbeam/models/imats/powerup_diffusionbeam_autoilum.bsmat",
            "actors/items/powerup_diffusionbeam/models/imats/powerup_diffusionbeam_mp_glass_01.bsmat",
            "actors/items/powerup_diffusionbeam/models/imats/powerup_diffusionbeam_mp_opaque_01.bsmat",
        ),
    ),

    "powerup_grapplebeam": ModelData(
        bcmdl_path="actors/items/powerup_grapplebeam/models/powerup_grapplebeam.bcmdl",
        bmsas="actors/items/powerup_grapplebeam/charclasses/powerup_grapplebeam.bmsas",
        dependencies=(
            "actors/items/powerup_grapplebeam/fx/auraitemparticle.bcptl",
            "actors/items/powerup_grapplebeam/models/powerup_grapplebeam.bcmdl",
            "actors/items/powerup_grapplebeam/models/imats/powerup_grapplebeam_grapplebeam.bsmat",
        ),
        grapple_fx=True,
    ),

    "powerup_supermissile": ModelData(
        bcmdl_path="actors/items/powerup_supermissile/models/powerup_supermissile.bcmdl",
        bmsas="actors/items/powerup_supermissile/charclasses/powerup_supermissile.bmsas",
        dependencies=(
            "actors/items/powerup_supermissile/models/powerup_supermissile.bcmdl",
            "actors/items/powerup_supermissile/models/imats/powerup_supermissile_hologram.bsmat",
            "actors/items/powerup_supermissile/models/imats/powerup_supermissile_mp_opaque_01.bsmat",
        ),
    ),

    "powerup_icemissile": ModelData(
        bcmdl_path="actors/items/powerup_supermissile/models/powerup_ice__missile.bcmdl",
        bmsas="actors/items/powerup_supermissile/charclasses/powerup_supermissile.bmsas",
        dependencies=(
            "actors/items/powerup_supermissile/models/powerup_ice__missile.bcmdl",
            "actors/items/powerup_supermissile/models/imats/powerup_supermissile_hologram.bsmat",
            "actors/items/powerup_supermissile/models/imats/powerup_ice__missile_mp_opaque_01.bsmat",
        ),
    ),

    "powerup_stormmissile": ModelData(
        bcmdl_path="actors/items/powerup_supermissile/models/powerup_supermissile.bcmdl",
        bmsas="actors/items/powerup_supermissile/charclasses/powerup_supermissile.bmsas",
        dependencies=(
            "actors/items/powerup_supermissile/models/powerup_supermissile.bcmdl",
            "actors/items/powerup_supermissile/models/imats/powerup_supermissile_hologram.bsmat",
            "actors/items/powerup_supermissile/models/imats/powerup_supermissile_mp_opaque_01.bsmat",
            "actors/items/powerup_grapplebeam/fx/auraitemparticle.bcptl",
        ),
        grapple_fx=True,
    ),

    "powerup_opticcamo": ModelData(
        bcmdl_path="actors/items/item_cube_broken/model/itemcube_camo.bcmdl",
        bmsas="actors/items/itemsphere/charclasses/timeline.bmsas",
        dependencies=(
            "actors/items/item_cube_broken/model/itemcube_camo.bcmdl",
            "actors/items/item_cube/model/imats/itemcube_camo.bsmat",
            "actors/items/item_cube/model/imats/itemcube_emisive.bsmat",
        ),
        transform=Transform(
            scale=(0.5, 0.5, 0.5),
            position=(0.0, 30.0, 0.0),
        )
    ),

    "powerup_ghostaura": ModelData(
        bcmdl_path="actors/items/item_cube_broken/model/itemcube_broken.bcmdl",
        bmsas="actors/items/itemsphere/charclasses/timeline.bmsas",
        dependencies=(
            "actors/items/item_cube_broken/model/itemcube_broken.bcmdl",
            "actors/items/item_cube/model/imats/itemcube_cube.bsmat",
            "actors/items/item_cube/model/imats/itemcube_emisive.bsmat",
        ),
        transform=Transform(
            scale=(0.5, 0.5, 0.5),
            position=(0.0, 30.0, 0.0),
        )
    ),

    "powerup_sonar": ModelData(
        bcmdl_path="actors/items/item_cube_broken/model/itemcube_sonr.bcmdl",
        bmsas="actors/items/itemsphere/charclasses/timeline.bmsas",
        dependencies=(
            "actors/items/item_cube_broken/model/itemcube_sonr.bcmdl",
            "actors/items/item_cube/model/imats/itemcube_sonr.bsmat",
            "actors/items/item_cube/model/imats/itemcube_emisive.bsmat",
        ),
        transform=Transform(
            scale=(0.5, 0.5, 0.5),
            position=(0.0, 30.0, 0.0),
        )
    ),

    "powerup_variasuit": ModelData(
        bcmdl_path="actors/items/powerup_variasuit/models/powerup_variasuit.bcmdl",
        bmsas="actors/items/powerup_variasuit/charclasses/powerup_variasuit.bmsas",
        dependencies=(
            "actors/items/powerup_variasuit/models/powerup_variasuit.bcmdl",
            "actors/items/powerup_variasuit/models/imats/powerup_variasuit_material01.bsmat",
        ),
    ),

    "powerup_gravitysuit": ModelData(
        bcmdl_path="actors/items/powerup_gravitysuit/models/powerup_gravitysuit.bcmdl",
        bmsas="actors/items/powerup_gravitysuit/charclasses/powerup_gravitysuit.bmsas",
        dependencies=(
            "actors/items/powerup_gravitysuit/models/powerup_gravitysuit.bcmdl",
            "actors/items/powerup_gravitysuit/models/imats/powerup_gravitysuit_ball.bsmat",
            "actors/items/powerup_gravitysuit/models/imats/powerup_gravitysuit_grav.bsmat",
            "actors/items/powerup_gravitysuit/models/imats/powerup_gravitysuit_mp_opaque_01.bsmat",
        ),
    ),

    "powerup_morphball": ModelData(
        bcmdl_path="actors/items/powerup_bomb/models/powerup_morph.bcmdl",
        bmsas="actors/items/powerup_bomb/charclasses/powerup_bomb.bmsas",
        dependencies=(
            "actors/items/powerup_bomb/models/powerup_morph.bcmdl",
            "actors/items/powerup_bomb/models/imats/powerup_morphhologram.bsmat",
            "actors/items/powerup_bomb/models/imats/powerup_morphmaterial.bsmat",
        ),
        transform=Transform(
            scale=(1.6, 1.6, 1.6),
            position=(0.0, -20.0, 0.0),
        )
    ),

    "powerup_bomb": ModelData(
        bcmdl_path="actors/items/powerup_bomb/models/powerup_bomb.bcmdl",
        bmsas="actors/items/powerup_bomb/charclasses/powerup_bomb.bmsas",
        dependencies=(
            "actors/items/powerup_bomb/models/powerup_bomb.bcmdl",
            "actors/items/powerup_bomb/models/imats/powerup_bomb_hologram.bsmat",
            "actors/items/powerup_bomb/models/imats/powerup_bomb_material.bsmat",
        ),
    ),

    "powerup_crossbomb": ModelData(
        bcmdl_path="actors/items/powerup_bomb/models/powerup_bomb.bcmdl",
        bmsas="actors/items/powerup_bomb/charclasses/powerup_bomb.bmsas",
        dependencies=(
            "actors/items/powerup_bomb/models/powerup_bomb.bcmdl",
            "actors/items/powerup_bomb/models/imats/powerup_bomb_hologram.bsmat",
            "actors/items/powerup_bomb/models/imats/powerup_bomb_material.bsmat",
            "actors/items/powerup_grapplebeam/fx/auraitemparticle.bcptl",
        ),
        grapple_fx=True,
    ),

    "powerup_doublejump": ModelData(
        bcmdl_path="actors/items/powerup_doublejump/models/powerup_doublejump.bcmdl",
        bmsas="actors/items/powerup_doublejump/charclasses/powerup_doublejump.bmsas",
        dependencies=(
            "actors/items/powerup_doublejump/models/powerup_doublejump.bcmdl",
            "actors/items/powerup_doublejump/models/imats/powerup_doublejump_mp_glass_01.bsmat",
            "actors/items/powerup_doublejump/models/imats/powerup_doublejump_mp_opaque_01.bsmat",
        ),
    ),

    "powerup_spidermagnet": ModelData(
        bcmdl_path="actors/items/powerup_doublejump/models/powerup_magnet.bcmdl",
        bmsas="actors/items/powerup_doublejump/charclasses/powerup_doublejump.bmsas",
        dependencies=(
            "actors/items/powerup_doublejump/models/powerup_magnet.bcmdl",
            "actors/items/powerup_doublejump/models/imats/powerup_doublejump_mp_magnet01.bsmat",
            "actors/items/powerup_doublejump/models/imats/powerup_doublejump_mp_white__01.bsmat",
        ),
    ),

    "powerup_spacejump": ModelData(
        bcmdl_path="actors/items/powerup_spacejump/models/powerup_spacejump.bcmdl",
        bmsas="actors/items/powerup_spacejump/charclasses/powerup_spacejump.bmsas",
        dependencies=(
            "actors/items/powerup_spacejump/models/powerup_spacejump.bcmdl",
            "actors/items/powerup_spacejump/models/imats/powerup_spacejump_mat01.bsmat",
        ),
    ),

    "powerup_screwattack": ModelData(
        bcmdl_path="actors/items/powerup_screwattack/models/powerup_screwattack.bcmdl",
        bmsas="actors/items/powerup_screwattack/charclasses/powerup_screwattack.bmsas",
        dependencies=(
            "actors/items/powerup_screwattack/models/powerup_screwattack.bcmdl",
            "actors/items/powerup_screwattack/models/imats/powerup_screwattack_mp_opaque_01.bsmat",
        ),
    ),

    "item_energytank": ModelData(
        bcmdl_path="actors/items/item_energytank/models/item_energytank.bcmdl",
        bmsas="actors/items/item_energytank/charclasses/item_energytank.bmsas",
        dependencies=(
            "actors/items/item_energytank/models/item_energytank.bcmdl",
            "actors/items/item_energytank/models/imats/item_energytank_mp_opaque_01.bsmat",
        ),
    ),

    "item_energyfragment": ModelData(
        bcmdl_path="actors/items/item_energyfragment/models/item_energyfragment.bcmdl",
        bmsas="actors/items/item_energyfragment/charclasses/item_energyfragment.bmsas",
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
        bmsas="actors/items/item_missiletank/charclasses/item_missiletank.bmsas",
        dependencies=(
            "actors/items/item_missiletank/models/item_missiletank.bcmdl",
            "actors/items/item_missiletank/models/imats/item_missiletank_mat01.bsmat",
            "actors/items/item_missiletank/models/imats/item_missiletank_mp_fxhologram_01.bsmat",
        ),
    ),

    "item_missiletankplus": ModelData(
        bcmdl_path="actors/items/item_missiletankplus/models/item_missiletankplus.bcmdl",
        bmsas="actors/items/item_missiletankplus/charclasses/item_missiletankplus.bmsas",
        dependencies=(
            "actors/items/item_missiletankplus/models/item_missiletankplus.bcmdl",
            "actors/items/item_missiletankplus/models/imats/item_missiletankplus_mat01.bsmat",
            "actors/items/item_missiletankplus/models/imats/item_missiletankplus_mp_fxhologram_01.bsmat",
        ),
    ),

    "item_powerbombtank": ModelData(
        bcmdl_path="actors/items/item_powerbombtank/models/item_powerbombtank.bcmdl",
        bmsas="actors/items/item_powerbombtank/charclasses/item_powerbombtank.bmsas",
        dependencies=(
            "actors/items/item_powerbombtank/models/item_powerbombtank.bcmdl",
            "actors/items/item_powerbombtank/models/imats/item_powerbombtank_mat01.bsmat",
            "actors/items/item_powerbombtank/models/imats/item_powerbombtank_mp_fxhologram_01.bsmat",
        ),
        transform=Transform(
            scale=(0.8, 0.8, 0.8),
        )
    ),

    "powerup_powerbomb": ModelData(
        bcmdl_path="actors/items/item_powerbombtank/models/item_powerbombtank.bcmdl",
        bmsas="actors/items/item_powerbombtank/charclasses/item_powerbombtank.bmsas",
        dependencies=(
            "actors/items/item_powerbombtank/models/item_powerbombtank.bcmdl",
            "actors/items/item_powerbombtank/models/imats/item_powerbombtank_mat01.bsmat",
            "actors/items/item_powerbombtank/models/imats/item_powerbombtank_mp_fxhologram_01.bsmat",
        ),
        transform=Transform(
            scale = (-1.25, 1.25, 1.25),
            position=(0.0, -30.0, 0.0),
        ),
    ),
}


def get_data(name: str) -> ModelData:
    return ALL_MODEL_DATA.get(name, ALL_MODEL_DATA["itemsphere"])
