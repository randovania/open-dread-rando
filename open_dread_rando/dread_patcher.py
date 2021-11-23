import logging
from pathlib import Path

LOG = logging.getLogger("dread_patcher")

def patch(input_path: Path, output_path: Path, configuration: dict):
    LOG.info("Will patch files at %s", input_path)
