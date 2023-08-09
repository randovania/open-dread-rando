import itertools

from open_dread_rando.constants import ALL_SCENARIOS
from open_dread_rando.files import files_path
from open_dread_rando.misc_patches import lua_util
from open_dread_rando.patcher_editor import PatcherEditor, path_for_level


def _read_powerup_lua() -> bytes:
    return files_path().joinpath("randomizer_powerup.lua").read_bytes()


def _read_level_lua(level_id: str) -> str:
    return files_path().joinpath("levels", f"{level_id}.lc.lua").read_text()


SPECIFIC_CLASSES = {
    "ITEM_WEAPON_POWER_BOMB": "RandomizerPowerBomb",
    "ITEM_OPTIC_CAMOUFLAGE": "RandomizerPhantomCloak",
    "ITEM_SPEED_BOOSTER": "RandomizerSpeedBooster",
    "ITEM_MULTILOCKON": "RandomizerStormMissile",
    "ITEM_LIFE_SHARDS": "RandomizerEnergyPart",
    "ITEM_GHOST_AURA": "RandomizerFlashShift",
}


class LuaEditor:
    def __init__(self):
        self._progressive_classes = {}
        self._powerup_script = _read_powerup_lua()
        self._custom_level_scripts: dict[str, dict] = self._read_levels()
        self._corex_replacement = {
            "escue": "false",
            "golzuna": "false",
        }

    def _read_levels(self) -> dict[str, dict]:
        return {
            scenario: {"script": _read_level_lua(scenario), "edited": False}
            for scenario in ALL_SCENARIOS
        }

    def get_parent_for(self, item_id) -> str:
        return SPECIFIC_CLASSES.get(item_id, "RandomizerPowerup")

    def get_script_class(self, pickup: dict, boss: bool = False, actordef_name: str = "") -> str:
        pickup_resources = pickup["resources"]
        parent = self.get_parent_for(pickup_resources[0][0]["item_id"])

        if not boss and len(pickup_resources) == 1 and len(pickup_resources[0]) == 1:
            # Single-item pickup; don't include progressive template
            return parent

        if actordef_name and len(pickup["model"]) > 1:
            self.add_progressive_models(pickup, actordef_name)

        hashable_progression = "_".join([
            f'{res[0]["item_id"]}_{res[0]["quantity"]}'
            for res in pickup_resources
        ]).replace("-", "MINUS")

        if hashable_progression in self._progressive_classes.keys():
            return self._progressive_classes[hashable_progression]

        class_name = f"RandomizerProgressive{hashable_progression}"

        resources = [
            [
                {
                    "item_id": lua_util.wrap_string(res["item_id"]),
                    "quantity": res["quantity"]
                }
                for res in resource_list
            ]
            for resource_list in pickup_resources
        ]
        replacement = {
            "name": class_name,
            "resources": resources,
            "parent": parent,
        }
        self.add_progressive_class(replacement)

        self._progressive_classes[hashable_progression] = class_name
        return class_name

    def add_progressive_class(self, replacement):
        new_class = lua_util.replace_lua_template("randomizer_progressive_template.lua", replacement)
        self._powerup_script += new_class.encode("utf-8")

    def add_progressive_models(self, pickup: dict, actordef_name: str):
        progressive_models = [
            {
                "item": lua_util.wrap_string(resource["item_id"]),
                "alias": lua_util.wrap_string(model_name),
            }
            for resource, model_name in itertools.chain(
                zip([r[0] for r in pickup["resources"]], pickup["model"][1:]),
                [(pickup["resources"][-1][0], pickup["model"][-1])],
            )
        ]
        progressive_models.reverse()

        replacement = {
            "actordef_name": actordef_name,
            "progressive_models": progressive_models,
        }

        models = lua_util.replace_lua_template("progressive_model_template.lua", replacement)
        self._powerup_script += models.encode("utf-8")

    def patch_actordef_pickup_script(self, editor: PatcherEditor, pickup: dict, pickup_lua_callback: dict,
                                     extra_code: str = ""):
        scenario = pickup_lua_callback["scenario"]
        scenario_path = path_for_level(scenario)
        lua_util.create_script_copy(editor, scenario_path)

        script = self._custom_level_scripts[scenario]

        if not script["edited"]:
            script["script"] += "\nGame.DoFile('actors/items/randomizer_powerup/scripts/randomizer_powerup.lua')\n\n"
            script["edited"] = True

        replacement = {
            "scenario": scenario,
            "funcname": pickup_lua_callback["function"],
            "pickup_class": self.get_script_class(pickup, True),
            "extra_code": extra_code,
            "args": ", ".join([f"_ARG_{i}_" for i in range(pickup_lua_callback["args"])])
        }
        script["script"] += lua_util.replace_lua_template("boss_powerup_template.lua", replacement)

    def patch_corex_pickup_script(self, editor: PatcherEditor, pickup: dict, pickup_lua_callback: dict):
        bossid = pickup_lua_callback["function"]
        self._corex_replacement[bossid] = self.get_script_class(pickup, True)

    def save_modifications(self, editor: PatcherEditor):
        editor.replace_asset("actors/items/randomizer_powerup/scripts/randomizer_powerup.lc", self._powerup_script)
        for scenario, script in self._custom_level_scripts.items():
            editor.replace_asset(path_for_level(scenario) + ".lc", script["script"].encode("utf-8"))

        for boss in {"core_x", "core_x_superquetzoa"}:
            corex_script = lua_util.replace_lua_template(f"custom_{boss}.lua", self._corex_replacement).encode("utf-8")
            editor.replace_asset(f"actors/characters/{boss}/scripts/{boss}.lc", corex_script)
