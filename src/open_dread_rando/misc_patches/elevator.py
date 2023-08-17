import dataclasses
from enum import Enum

from open_dread_rando.logger import LOG
from open_dread_rando.patcher_editor import PatcherEditor
from open_dread_rando.pickups.map_icons import MapIcon


class TransporterType(Enum):
    TRANSPORT = "TRANSPORT"
    TELEPORTAL = "TELEPORTAL"

@dataclasses.dataclass
class TransporterIcon:
    default_icon_id: str
    coords: tuple[int, int]
    prefix: str
    disabled_id: str = ''

    def map_icon(self, icon_id: str, label: str) -> MapIcon:
        return MapIcon(
            icon_id=icon_id,
            coords=self.coords,
            label=self.prefix + label.upper(),
            disabled_id=self.disabled_id
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
        disabled_id="DisabledElevator",
    ),
    "Train": TransporterIcon(
        default_icon_id="UsableTrain",
        coords=(1,4),
        prefix="SHUTTLE TO ",
    ),
    "Transport": TransporterIcon(
        default_icon_id="UsableTransport",
        coords=(8,2),
        prefix = "TRANSPORT CAPSULE TO ",
    )
}

def _get_type_and_usable(editor: PatcherEditor, elevator: dict) -> tuple[TransporterType, dict]:
    level = editor.get_scenario(elevator["teleporter"]["scenario"])
    actor = level.actors_for_layer(elevator["teleporter"]["layer"])[elevator["teleporter"]["actor"]]
    try:
        usable = actor.pComponents.USABLE
    except AttributeError:
        raise ValueError(f'Actor {elevator["teleporter"]} is not usable')

    if usable["@type"] in ["CElevatorUsableComponent", "CTrainUsableComponent", "CTrainUsableComponentCutScene",
                           "CTrainWithPortalUsableComponent", "CCapsuleUsableComponent"]:
        return TransporterType.TRANSPORT, usable
    elif usable["@type"] == "CTeleporterUsableComponent":
        return TransporterType.TELEPORTAL, usable
    else:
        raise ValueError(f"Elevator {elevator['teleporter']['scenario']}/{elevator['teleporter']['actor']} "
                         "is not an elevator, shuttle, capsule or teleporter!\n"
                         f"USABLE type: {usable['@type']}")

def _patch_actor(usable: dict, elevator: dict):
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
        transporter_type, usable = _get_type_and_usable(editor, elevator)

        if transporter_type == TransporterType.TRANSPORT:
            _patch_actor(usable, elevator)
            _patch_minimap_arrows(editor, elevator)
            _patch_map_icon(editor, elevator)
        else:
            # TODO implement teleporter rando
            _patch_actor(usable, elevator)
