import json
import os
import typing
from pathlib import Path

import lupa
import pytest

from open_dread_rando.patcher_editor import PatcherEditor

_FAIL_INSTEAD_OF_SKIP = True


def get_env_or_skip(env_name, override_fail: typing.Optional[bool] = None):
    if override_fail is None:
        fail_or_skip = _FAIL_INSTEAD_OF_SKIP
    else:
        fail_or_skip = override_fail
    if env_name not in os.environ:
        if fail_or_skip:
            pytest.fail(f"Missing environment variable {env_name}")
        else:
            pytest.skip(f"Skipped due to missing environment variable {env_name}")
    return os.environ[env_name]


class TestFilesDir:
    def __init__(self, root: Path):
        self.root = root

    def joinpath(self, *paths) -> Path:
        return self.root.joinpath(*paths)

    def read_json(self, *paths) -> typing.Union[dict, list]:
        with self.joinpath(*paths).open() as f:
            return json.load(f)


@pytest.fixture(scope="session")
def dread_path():
    return Path(get_env_or_skip("DREAD_1_0_0_PATH"))


@pytest.fixture(scope="session")
def test_files_dir() -> TestFilesDir:
    return TestFilesDir(Path(__file__).parent.joinpath("test_files"))


@pytest.fixture()
def lua_runtime():
    runtime = lupa.LuaRuntime()
    runtime.execute("""
Game = {}
function Game.ImportLibrary() end
function Game.LogWarn() end
function Game.SetForceSkipCutscenes() end
""")
    return runtime


@pytest.fixture()
def patcher_editor(dread_path):
    return PatcherEditor(dread_path)


def pytest_addoption(parser):
    parser.addoption('--skip-if-missing', action='store_false', dest="fail_if_missing",
                     default=True, help="Skip tests instead of missing, in case any asset is missing")


def pytest_configure(config: pytest.Config):
    global _FAIL_INSTEAD_OF_SKIP
    _FAIL_INSTEAD_OF_SKIP = config.option.fail_if_missing
