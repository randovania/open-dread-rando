from pathlib import Path

import lupa
import pytest


@pytest.fixture()
def test_files():
    return Path(__file__).parent.joinpath("test_files")


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
