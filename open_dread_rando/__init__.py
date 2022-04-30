from pathlib import Path

from .patch_util import patch_with_status_update


def patch(input_path: Path, output_path: Path, configuration: dict):
    from .dread_patcher import patch_extracted
    return patch_extracted(input_path, output_path, configuration)
