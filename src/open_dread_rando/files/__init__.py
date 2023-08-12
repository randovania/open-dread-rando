from pathlib import Path


def files_path() -> Path:
    return Path(__file__).parent

def templates_path() -> Path:
    return files_path().joinpath("templates")
