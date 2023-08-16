import dataclasses

from open_dread_rando.logger import LOG
from open_dread_rando.patcher_editor import PatcherEditor
from open_dread_rando.pickups.map_icons import MapIcon


@dataclasses.dataclass
class TransporterIcon:
    default_icon_id: str
    coords: tuple[int, int]
    disabled_id: str
    prefix: str
    offset: tuple[int, int] = (0, 0)

    def map_icon(self, icon_id: str, label: str) -> MapIcon:
        return MapIcon(
            icon_id=icon_id,
            coords=self.coords,
            label=self.prefix + label.upper(),
            disabled_id=self.disabled_id,
            offset=self.offset
        )

    @classmethod
    def get_icon(cls, usable: dict):
        usable_id = usable["sIconId"]
        for trans_type in TRANSPORT_TYPES.values():
            if trans_type.default_icon_id == usable_id:
                return trans_type
        return None

TRANSPORT_TYPES = {
    "Elevator": TransporterIcon(
        default_icon_id="UsableElevator",
        coords=(2,4),
        prefix="ELEVATOR TO ",
        disabled_id="DisabledElevator"
    ),
    "Train": TransporterIcon(
        default_icon_id="UsableTrain",
        coords=(1,4),
        prefix="SHUTTLE TO ",
        disabled_id=''
    ),
    "Transport": TransporterIcon(
        default_icon_id="UsableTransport",
        coords=(8,2),
        prefix = "TRANSPORT CAPSULE TO ",
        disabled_id=''
    )
}
def _patch_actor(editor: PatcherEditor, elevator: dict):
    level = editor.get_scenario(elevator["teleporter"]["scenario"])
    actor = level.actors_for_layer(elevator["teleporter"]["layer"])[elevator["teleporter"]["actor"]]
    try:
        usable = actor.pComponents.USABLE
    except AttributeError:
        raise ValueError(f'Actor {elevator["teleporter"]} is not a teleporter')
    usable.sScenarioName = elevator["destination"]["scenario"]
    usable.sTargetSpawnPoint = elevator["destination"]["actor"]

def _patch_minimap_arrows(editor: PatcherEditor, elevator: dict):
    map = editor.get_scenario_map(elevator["teleporter"]["scenario"])
    sign = map.get_category("mapTransportSigns")[ elevator["teleporter"]["actor"] ]
    sign["sDestAreaId"] = elevator["destination"]["scenario"]

def _patch_map_icon(editor: PatcherEditor, elevator: dict):
    # get transporter type from mapUsables entry
    conn_name: str = elevator["connection_name"]
    icon_id = f'RDV_TRANSPORT_{conn_name.replace(" ", "")}' # ex: "RDV_TRANSPORT_Artaria-ThermalDevice"

    bmmap = editor.get_scenario_map(elevator["teleporter"]["scenario"])
    usable = bmmap.get_category("mapUsables")[ elevator["teleporter"]["actor"] ]
    ti = TransporterIcon.get_icon(usable)
    if ti is None:
        raise ValueError(f'Usable icon_id {usable["sIconId"]} invalid!')

    # add BMMDEF
    editor.map_icon_editor.add_icon(ti.map_icon(icon_id, elevator["connection_name"]))

    # update usable
    usable["sIconId"] = icon_id

def patch_elevators(editor: PatcherEditor, elevators_config: list[dict]):
    for elevator in elevators_config:
        LOG.debug("Writing elevator from: %s", str(elevator["teleporter"]))
        _patch_actor(editor, elevator)
        _patch_minimap_arrows(editor, elevator)
        _patch_map_icon(editor, elevator)
