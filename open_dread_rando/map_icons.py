import dataclasses
from typing import Tuple, Union

from mercury_engine_data_structures.formats import Bmmdef

from open_dread_rando.patcher_editor import PatcherEditor
from open_dread_rando.text_patches import patch_text


@dataclasses.dataclass(frozen=True)
class MapIcon:
    icon_id: str
    coords: Tuple[int, int]
    label: str
    disabled_id: str = 'ItemAdquired'
    offset: Tuple[int, int] = (0, 0)
    auto_scale: bool = True
    is_global: bool = True
    full_zoom_scale: bool = True

    def __post_init__(self):
        object.__setattr__(self, "string_key", f"MAP_ICON_{self.icon_id}")

    def add_to_defs(self, bmmdef: Bmmdef, editor: PatcherEditor):
        patch_text(editor, self.string_key, self.label)
        bmmdef.add_icon(
            self.icon_id,
            self.coords[1],
            self.coords[0],
            f"#{self.string_key}",
            self.disabled_id,
            self.offset,
            self.auto_scale,
            bIsGlobal=self.is_global,
            bFullZoomScale=self.full_zoom_scale
        )

ALL_ICONS: dict[str, Union[MapIcon, str]] = {
    "powerup_speedbooster": MapIcon(
        icon_id="ItemSpeedBooster",
        coords=(3, 7),
        label="SPEED BOOSTER"
    ),
    "powerup_widebeam": MapIcon(
        icon_id="ItemWideBeam",
        coords=(0, 6),
        label="WIDE BEAM"
    ),
    "powerup_plasmabeam": MapIcon(
        icon_id="ItemPlasmaBeam",
        coords=(1, 6),
        label="PLASMA BEAM"
    ),
    "powerup_wavebeam": MapIcon(
        icon_id="ItemWaveBeam",
        coords=(2, 6),
        label="WAVE BEAM"
    ),
    "PROGRESSIVE_BEAM": MapIcon(
        icon_id="ItemProgressiveBeam",
        coords=(7, 7),
        label="PROGRESSIVE BEAM"
    ),
    "powerup_chargebeam": MapIcon(
        icon_id="ItemChargeBeam",
        coords=(3, 6),
        label="CHARGE BEAM"
    ),
    "powerup_diffusionbeam": MapIcon(
        icon_id="ItemDiffusionBeam",
        coords=(4, 6),
        label="DIFFUSION BEAM"
    ),
    "PROGRESSIVE_CHARGE": MapIcon(
        icon_id="ItemProgressiveCharge",
        coords=(8, 7),
        label="PROGRESSIVE CHARGE"
    ),
    "powerup_grapplebeam": MapIcon(
        icon_id="ItemGrappleBeam",
        coords=(5, 6),
        label="GRAPPLE BEAM"
    ),
    "powerup_supermissile": MapIcon(
        icon_id="ItemSuperMissile",
        coords=(6, 6),
        label="SUPER MISSILE"
    ),
    "powerup_icemissile": MapIcon(
        icon_id="ItemIceMissile",
        coords=(7, 6),
        label="ICE MISSILE"
    ),
    "PROGRESSIVE_MISSILE": MapIcon(
        icon_id="ItemProgressiveMissile",
        coords=(9, 7),
        label="PROGRESSIVE MISSILE"
    ),
    "powerup_stormmissile": MapIcon(
        icon_id="ItemStormMissile",
        coords=(8, 6),
        label="STORM MISSILE"
    ),
    "powerup_opticcamo": MapIcon(
        icon_id="ItemOpticCamo",
        coords=(9, 6),
        label="PHANTOM CLOAK"
    ),
    "powerup_ghostaura": MapIcon(
        icon_id="ItemGhostAura",
        coords=(10, 6),
        label="FLASH SHIFT"
    ),
    "powerup_sonar": MapIcon(
        icon_id="ItemSonar",
        coords=(11, 6),
        label="PULSE RADAR"
    ),
    "powerup_variasuit": MapIcon(
        icon_id="ItemVariaSuit",
        coords=(12, 6),
        label="VARIA SUIT"
    ),
    "powerup_gravitysuit": MapIcon(
        icon_id="ItemGravitySuit",
        coords=(13, 6),
        label="GRAVITY SUIT"
    ),
    "PROGRESSIVE_SUIT": MapIcon(
        icon_id="ItemProgressiveSuit",
        coords=(10, 7),
        label="PROGRESSIVE SUIT"
    ),
    "powerup_morphball": MapIcon(
        icon_id="ItemMorphBall",
        coords=(14, 6),
        label="MORPH BALL"
    ),
    "powerup_bomb": MapIcon(
        icon_id="ItemBomb",
        coords=(15, 6),
        label="BOMB"
    ),
    "powerup_crossbomb": MapIcon(
        icon_id="ItemCrossBomb",
        coords=(0, 7),
        label="CROSS BOMB"
    ),
    "PROGRESSIVE_BOMB": MapIcon(
        icon_id="ItemProgressiveBomb",
        coords=(11, 7),
        label="PROGRESSIVE BOMB"
    ),
    "powerup_powerbomb": MapIcon(
        icon_id="ItemPowerBomb",
        coords=(1, 7),
        label="MAIN POWER BOMB"
    ),
    "powerup_doublejump": MapIcon(
        icon_id="ItemDoubleJump",
        coords=(4, 7),
        label="SPIN BOOST"
    ),
    "powerup_spacejump": MapIcon(
        icon_id="ItemSpaceJump",
        coords=(5, 7),
        label="SPACE JUMP"
    ),
    "PROGRESSIVE_SPIN": MapIcon(
        icon_id="ItemProgressiveSpin",
        coords=(12, 7),
        label="PROGRESSIVE SPIN"
    ),
    "powerup_spidermagnet": MapIcon(
        icon_id="ItemSpiderMagnet",
        coords=(2, 7),
        label="SPIDER MAGNET"
    ),
    "powerup_screwattack": MapIcon(
        icon_id="ItemScrewAttack",
        coords=(6, 7),
        label="SCREW ATTACK"
    ),
    "item_energytank": "ItemEnergyTank",
    "item_energyfragment": "ItemEnergyFragment",
    "item_missiletank": "ItemMissileTank",
    "item_missiletankplus": "ItemMissileTankPlus",
    "item_powerbombtank": "ItemPowerbombExpansion",
    "itemsphere": MapIcon(
        icon_id="ItemNothing",
        coords=(4, 0),
        label="NOTHING",
        is_global=False,
        full_zoom_scale=False
    ),
    "unknown": MapIcon(
        icon_id="ItemUnknown",
        coords=(4, 0),
        label="UNKNOWN ITEM"
    )
}

class MapIconEditor:
    def __init__(self, editor: PatcherEditor) -> None:
        self.editor = editor
        self.custom_icons = 0
        self.mapdefs = self.editor.get_file("system/minimap/minimap.bmmdef", Bmmdef)

    def _get_icon(self, key: str) -> str:
        icon = ALL_ICONS.get(key, ALL_ICONS["unknown"])
        if isinstance(icon, str):
            return icon
        self.add_icon(icon)
        return icon.icon_id
    
    def add_icon(self, icon: MapIcon):
        if icon.icon_id not in self.mapdefs.icons:
            icon.add_to_defs(self.mapdefs, self.editor)

    def get_data(self, pickup: dict) -> str:
        if "map_icon" not in pickup:
            return self._get_icon(pickup["model"])

        map_icon: dict = pickup["map_icon"]
        if "icon_id" in map_icon:
            return self._get_icon(map_icon["icon_id"])
        
        custom_icon: dict = map_icon["custom_icon"]
        if "coords" in custom_icon:
            coords = (custom_icon["coords"]["col"], custom_icon["coords"]["row"])
        else:
            coords = (4, 0)
        icon = MapIcon(
            icon_id=f"ItemCustom{self.custom_icons}",
            coords=coords,
            label=custom_icon["label"],
            is_global=custom_icon.get("is_global", True),
            full_zoom_scale=custom_icon.get("full_zoom_scale", True),
            **custom_icon.get("extras", {})
        )
        self.custom_icons += 1
        self.add_icon(icon)
        return icon.icon_id
    