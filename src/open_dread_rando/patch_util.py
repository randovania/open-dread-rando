import logging
import typing
from pathlib import Path

from open_dread_rando.logger import LOG


def patch_with_status_update(input_path: Path, output_path: Path, configuration: dict,
                             status_update: typing.Callable[[float, str], None]):
    from open_dread_rando.dread_patcher import patch_extracted
    total_logs = 108

    class StatusUpdateHandler(logging.Handler):
        count = 0

        def emit(self, record: logging.LogRecord) -> None:
            message = self.format(record)

            # Ignore "Writing <...>.pkg" messages, since there's also Updating...
            if message.startswith("Writing ") and message.endswith(".pkg"):
                return

            # Encoding a bmsad is quick, skip these
            if message.endswith(".bmsad"):
                return

            # These can come up frequently and are benign
            if message.startswith("Skipping extracted file"):
                return

            self.count += 1
            status_update(self.count / total_logs, message)

    new_handler = StatusUpdateHandler()
    # new_handler.setFormatter(logging.Formatter('[%(asctime)s] [%(levelname)s] %(message)s'))
    tree_editor_log = logging.getLogger("mercury_engine_data_structures.file_tree_editor")

    try:
        tree_editor_log.setLevel(logging.DEBUG)
        tree_editor_log.handlers.insert(0, new_handler)
        tree_editor_log.propagate = False
        LOG.setLevel(logging.INFO)
        LOG.handlers.insert(0, new_handler)
        LOG.propagate = False

        patch_extracted(input_path, output_path, configuration)
        if new_handler.count < total_logs:
            status_update(1, f"Done was {new_handler.count}")

    finally:
        tree_editor_log.removeHandler(new_handler)
        tree_editor_log.propagate = True
        LOG.removeHandler(new_handler)
        LOG.propagate = True
