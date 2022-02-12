import argparse
import json
import logging
import logging.config
from pathlib import Path

from open_dread_rando import dread_patcher


def create_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input-path", required=True, type=Path,
                        help="Path to where the extracted Metroid Dread romfs to randomize can be found.")
    parser.add_argument("--output-path", required=True, type=Path,
                        help="Path to where the modified files will be written to.")
    parser.add_argument("--input-json", type=Path,
                        help="Path to the configuration json. If missing, it's read from standard input")
    return parser


def setup_logging():
    handlers = {
        'default': {
            'level': 'DEBUG',
            'formatter': 'default',
            'class': 'logging.StreamHandler',
            'stream': 'ext://sys.stdout',  # Default is stderr
        },
    }
    logging.config.dictConfig({
        'version': 1,
        'formatters': {
            'default': {
                'format': '[%(asctime)s] [%(levelname)s] [%(name)s] %(funcName)s: %(message)s',
            }
        },
        'handlers': handlers,
        'disable_existing_loggers': False,
        'loggers': {
            'default': {
                'level': 'DEBUG',
            },
        },
        'root': {
            'level': 'DEBUG',
            'handlers': list(handlers.keys()),
        },
    })
    logging.info("Hello world.")


def main():
    setup_logging()
    parser = create_parser()
    args = parser.parse_args()

    with args.input_json.open() as f:
        configuration = json.load(f)

    dread_patcher.patch(
        args.input_path,
        args.output_path,
        configuration,
    )
