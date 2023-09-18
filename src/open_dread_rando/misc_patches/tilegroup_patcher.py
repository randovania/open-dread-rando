from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from open_dread_rando.configuration import ConfigurationTileGroupPatchesItem
    from open_dread_rando.patcher_editor import PatcherEditor


def is_tilegroup(actor):
    return "TILEGROUP" in actor.pComponents and actor.pComponents.TILEGROUP["@type"] == "CBreakableTileGroupComponent"


def patch_tilegroup(editor: PatcherEditor, group: ConfigurationTileGroupPatchesItem) -> None:
    """
    Patches a tilegroup from its original tile type into a new tile type

    :param editor: the PatcherEditor
    :param group: a dictionary containing the actor reference stored in 'actor' key and a tile type
    stored in 'tiletype' key
    """
    actor = editor.resolve_actor_reference(group["actor"])

    if not is_tilegroup(actor):
        raise ValueError(f"Actor at {group['actor']} is not a breakable tile group.")

    grid_tiles = actor.pComponents.TILEGROUP.aGridTiles
    for tile in grid_tiles:
        tile.eTileType = group["tiletype"]
