from construct import Container
from mercury_engine_data_structures.common_types import Vec2
from mercury_engine_data_structures.formats import Bmsss

from open_dread_rando.patcher_editor import PatcherEditor


def patch_sprites(editor: PatcherEditor):
    """
    Patches a sprite to the hud tileset for a disconnect symbol

    :param editor: the PatcherEditor
    """
    hud_bmsss = editor.get_file("gui/scripts/sprites_hud_tileset.bmsss", Bmsss)
    # position in bctex is (446, 6) with 59x59 pixels in a 512x512 pixels tile
    cont = Container(
        sID="DISCONNECT",
        oTexUVs=Container(
            v2Offset=Vec2(446 / 512, 6 / 512),
            v2Scale=Vec2(59 / 512, 59 / 512),
        )
    )
    hud_bmsss.raw.Root.mapSpriteSheets.HUD_TILESET.vecItems.append(cont)
