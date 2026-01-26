from construct import Container, ListContainer
from mercury_engine_data_structures.formats import Bmsss

from open_dread_rando.patcher_editor import PatcherEditor


def patch_sprites(editor: PatcherEditor):
    """
    Adds some custom sprites to the HUD sprite sheet

    :param editor: the PatcherEditor
    """
    hud_bmsss = editor.get_file("gui/scripts/sprites_hud_tileset.bmsss", Bmsss)
    hud_tileset = hud_bmsss.raw.Root.mapSpriteSheets.HUD_TILESET

    # Disconnect icon for multiworld
    _add_sprite(hud_tileset, "DISCONNECT", (446, 6), (59, 59))
    # Death counter icon
    _add_sprite(hud_tileset, "DEATHS", (462, 67), (48, 48))
    # DNA count icon
    _add_sprite(hud_tileset, "DNA", (462, 118), (48, 48))
    # Speed upgrade icon for Samus menu
    _add_sprite(hud_tileset, "SPEED_UPGRADE", (414, 67), (48, 48))
    # Flash upgrade icon for Samus menu
    _add_sprite(hud_tileset, "FLASH_UPGRADE", (414, 118), (48, 48))
    # Small Plasma Beam icon to show on the Power Beam list item of the Samus menu (for split beams)
    _add_sprite(hud_tileset, "PLASMA_BEAM", (413, 0), (32, 32))
    # Small Wide Beam icon to show on the Power Beam list item of the Samus menu (for split beams)
    _add_sprite(hud_tileset, "WIDE_BEAM", (413, 32), (32, 32))
    # Small Super Missile icon to show on the Power Beam list item of the Samus menu (for split beams)
    _add_sprite(hud_tileset, "SUPER_MISSILE", (381, 0), (32, 32))

def _add_sprite(tileset, name: str, pos: tuple[int, int], size: tuple[int, int]):
    # texture base size is 512x512 pixels
    spriteItem = Container(
        sID=name,
        oTexUVs=Container(
            v2Offset=ListContainer([pos[0] / 512, pos[1] / 512]),
            v2Scale=ListContainer([size[0] / 512, size[1] / 512])
        )
    )
    tileset.vecItems.append(spriteItem)