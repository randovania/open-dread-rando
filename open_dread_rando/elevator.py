from open_dread_rando.logger import LOG
from open_dread_rando.patcher_editor import PatcherEditor


def patch_elevators(editor: PatcherEditor, elevators_config: list[dict]):
    for elevator in elevators_config:
        LOG.debug("Writing elevator from: %s", str(elevator["teleporter"]))
        level = editor.get_scenario(elevator["teleporter"]["scenario"])
        actor = level.actors_for_layer(elevator["teleporter"]["layer"])[elevator["teleporter"]["actor"]]
        try:
            usable = actor.pComponents.USABLE
        except AttributeError:
            raise ValueError(f'Actor {elevator["teleporter"]} is not a teleporter')
        usable.sScenarioName = elevator["destination"]["scenario"]
        usable.sTargetSpawnPoint = elevator["destination"]["actor"]
