from pathlib import Path

from open_dread_rando import lua_util
from open_dread_rando.patcher_editor import PatcherEditor, path_for_level


def _read_powerup_lua() -> bytes:
    return Path(__file__).parent.joinpath("files", "randomizer_powerup.lua").read_bytes()


class LuaEditor:
    def __init__(self):
        self._progressive_classes = {}
        self._powerup_script = _read_powerup_lua()
        self._custom_level_scripts: dict[str, str] = {}
        self._corex_replacement = {}

    def get_script_class(self, pickup_resources: list[dict], boss: bool = False) -> str:
        main_pb = pickup_resources[0]["item_id"] == "ITEM_WEAPON_POWER_BOMB"
        if not boss and len(pickup_resources) == 1:
            return "RandomizerPowerBomb" if main_pb else "RandomizerPowerup"

        hashable_progression = "_".join([f'{res["item_id"]}_{res["quantity"]}' for res in pickup_resources])

        if hashable_progression in self._progressive_classes.keys():
            return self._progressive_classes[hashable_progression]

        class_name = f"RandomizerProgressive{hashable_progression}"

        resources = [
            {
                "item_id": lua_util.wrap_string(res["item_id"]),
                "quantity": res["quantity"]
            }
            for res in pickup_resources
        ]
        replacement = {
            "name": class_name,
            "progression": resources,
            "parent": "RandomizerPowerBomb" if main_pb else "RandomizerPowerup",
        }
        self.add_progressive_class(replacement)

        self._progressive_classes[hashable_progression] = class_name
        return class_name

    def add_progressive_class(self, replacement):
        new_class = lua_util.replace_lua_template("randomizer_progressive_template.lua", replacement)
        self._powerup_script += new_class.encode("utf-8")

    def patch_actordef_pickup_script(self, editor: PatcherEditor, resources: list[dict], pickup_lua_callback: dict):
        scenario = pickup_lua_callback["scenario"]
        scenario_path = path_for_level(scenario)
        lua_util.create_script_copy(editor, scenario_path)

        if scenario not in self._custom_level_scripts.keys():
            self._custom_level_scripts[scenario] = "\n".join([
                f"Game.LogWarn(0, 'Loading original {scenario}...')",
                f"Game.ImportLibrary('{scenario_path}_original.lua')",
                f"Game.LogWarn(0, 'Loaded original {scenario}.')",
                f"Game.DoFile('actors/items/randomizer_powerup/scripts/randomizer_powerup.lua')\n\n",
            ])

        replacement = {
            "scenario": scenario,
            "funcname": pickup_lua_callback["function"],
            "pickup_class": self.get_script_class(resources, True),
            "args": ", ".join([f"_ARG_{i}_" for i in range(pickup_lua_callback["args"])])
        }
        self._custom_level_scripts[scenario] += lua_util.replace_lua_template("boss_powerup_template.lua", replacement)
    
    def patch_corex_pickup_script(self, editor: PatcherEditor, resources: list[dict], pickup_lua_callback: dict):
        bossid = pickup_lua_callback["function"]
        self._corex_replacement[bossid] = self.get_script_class(resources, True)

    def save_modifications(self, editor: PatcherEditor):
        editor.replace_asset("actors/items/randomizer_powerup/scripts/randomizer_powerup.lc", self._powerup_script)
        for scenario, script in self._custom_level_scripts.items():
            editor.replace_asset(path_for_level(scenario) + ".lc", script.encode("utf-8"))
        
        corex_script = lua_util.replace_lua_template("custom_corex.lua", self._corex_replacement).encode("utf-8")
        for boss in {"core_x", "core_x_superquetzoa"}:
            editor.replace_asset(f"actors/characters/{boss}/scripts/{boss}.lc", corex_script)
