import copy
import functools
import json
from enum import Enum
from pathlib import Path

from mercury_engine_data_structures.formats import Bmsad, Txt

from open_dread_rando import lua_util
from open_dread_rando.model_data import ALL_MODEL_DATA
from open_dread_rando.patcher_editor import PatcherEditor, path_for_level

EXPANSION_ITEM_IDS = {
    "ITEM_ENERGY_TANKS",
    "ITEM_LIFE_SHARDS",
    "ITEM_WEAPON_MISSILE_MAX",
    "ITEM_WEAPON_POWER_BOMB_MAX",
    "ITEM_WEAPON_POWER_BOMB",
}


@functools.cache
def _read_template_powerup():
    with Path(__file__).parent.joinpath("templates", "template_powerup_bmsad.json").open() as f:
        return json.load(f)


def _read_powerup_lua() -> bytes:
    return Path(__file__).parent.joinpath("files", "randomizer_powerup.lua").read_bytes()


_progressive_classes = {}


def get_script_class(pickup: dict, boss: bool = False) -> str:
    main_pb = pickup["resources"][0]["item_id"] == "ITEM_WEAPON_POWER_BOMB"
    if not boss and len(pickup["resources"]) == 1:
        return "RandomizerPowerBomb" if main_pb else "RandomizerPowerup"

    hashable_progression = "_".join([f'{res["item_id"]}_{res["quantity"]}' for res in pickup["resources"]])

    if hashable_progression in _progressive_classes.keys():
        return _progressive_classes[hashable_progression]

    class_name = f"RandomizerProgressive{hashable_progression}"

    resources = [
        {
            "item_id": lua_util.wrap_string(res["item_id"]),
            "quantity": res["quantity"]
        }
        for res in pickup["resources"]
    ]
    replacement = {
        "name": class_name,
        "progression": resources,
        "parent": "RandomizerPowerBomb" if main_pb else "RandomizerPowerup",
    }
    add_progressive_class(replacement)

    _progressive_classes[hashable_progression] = class_name
    return class_name


_powerup_script: str = None


def add_progressive_class(replacement):
    global _powerup_script
    if _powerup_script is None:
        _powerup_script = _read_powerup_lua()

    new_class = lua_util.replace_lua_template("randomizer_progressive_template.lua", replacement)
    _powerup_script += new_class.encode("utf-8")


class PickupType(Enum):
    ACTOR = "actor"
    EMMI = "emmi"
    COREX = "corex"
    CORPIUS = "corpius"


class BasePickup:
    def __init__(self, pickup: dict, pickup_id: int):
        self.pickup = pickup
        self.pickup_id = pickup_id

    def patch(self, editor: PatcherEditor):
        raise NotImplementedError()


class ActorPickup(BasePickup):
    def patch_single_item_pickup(self, bmsad: dict) -> dict:
        PICKABLE: dict = bmsad["property"]["components"]["PICKABLE"]
        SCRIPT: dict = bmsad["property"]["components"]["SCRIPT"]

        set_custom_params: dict = PICKABLE["functions"][0]["params"]
        item_id: str = self.pickup["resources"][0]["item_id"]
        quantity: float = self.pickup["resources"][0]["quantity"]

        if item_id == "ITEM_ENERGY_TANKS":
            item_id = "fMaxLife"
            quantity *= 100.0
            set_custom_params["Param4"]["value"] = "Full"
            set_custom_params["Param5"]["value"] = "fCurrentLife"
            set_custom_params["Param6"]["value"] = "LIFE"

        elif item_id == "ITEM_LIFE_SHARDS":
            item_id = "fLifeShards"
            set_custom_params["Param4"]["value"] = "Custom"
            set_custom_params["Param5"]["value"] = ""
            set_custom_params["Param6"]["value"] = "LIFE"
            set_custom_params["Param7"]["value"] = "#GUI_ITEM_ACQUIRED_ENERGY_SHARD"
            caption = self.pickup["caption"]
            PICKABLE["fields"]["fields"]["sOnPickEnergyFragment1Caption"] = caption
            PICKABLE["fields"]["fields"]["sOnPickEnergyFragment2Caption"] = caption
            PICKABLE["fields"]["fields"]["sOnPickEnergyFragment3Caption"] = caption
            PICKABLE["fields"]["fields"]["sOnPickEnergyFragmentCompleteCaption"] = caption

        elif item_id in {"ITEM_WEAPON_MISSILE_MAX", "ITEM_WEAPON_POWER_BOMB_MAX", "ITEM_WEAPON_POWER_BOMB"}:
            current = item_id.replace("_MAX", "_CURRENT")
            if item_id == current:
                current += "_CURRENT"

            set_custom_params["Param4"]["value"] = "Custom"
            set_custom_params["Param5"]["value"] = current
            set_custom_params["Param8"]["value"] = "guicallbacks.OnSecondaryGunsFire"
            set_custom_params["Param13"] = {
                "type": "f",
                "value": quantity,
            }

        SCRIPT["functions"][0]["params"]["Param2"]["value"] = get_script_class(self.pickup)

        if item_id == "ITEM_WEAPON_POWER_BOMB":
            item_id = "ITEM_WEAPON_POWER_BOMB_MAX"

        set_custom_params["Param1"]["value"] = item_id
        set_custom_params["Param2"]["value"] = quantity

        return bmsad

    def patch_progressive_pickup(self, bmsad: dict) -> dict:
        item_ids = {resource["item_id"] for resource in self.pickup["resources"]}
        if not EXPANSION_ITEM_IDS.isdisjoint(item_ids):
            raise NotImplementedError("Progressive pickups cannot include expansions.")

        PICKABLE: dict = bmsad["property"]["components"]["PICKABLE"]
        SCRIPT: dict = bmsad["property"]["components"]["SCRIPT"]

        set_custom_params: dict = PICKABLE["functions"][0]["params"]
        set_custom_params["Param1"]["value"] = "ITEM_NONE"

        SCRIPT["functions"][0]["params"]["Param2"]["value"] = get_script_class(self.pickup)

        return bmsad

    def patch(self, editor: PatcherEditor):
        template_bmsad = _read_template_powerup()

        pickup_actor = self.pickup["pickup_actor"]
        pkgs_for_level = set(editor.find_pkgs(path_for_level(pickup_actor["scenario"]) + ".brfld"))
        level = editor.get_scenario(pickup_actor["scenario"])
        actor = level.actors_for_layer(pickup_actor["layer"])[pickup_actor["actor"]]

        model_name: str = self.pickup["model"]
        model_data = ALL_MODEL_DATA.get(model_name, ALL_MODEL_DATA["itemsphere"])

        new_template = copy.deepcopy(template_bmsad)
        new_template["name"] = f"randomizer_powerup_{self.pickup_id}"

        # Update used model
        new_template["property"]["model_name"] = model_data.bcmdl_path
        MODELUPDATER = new_template["property"]["components"]["MODELUPDATER"]
        MODELUPDATER["functions"][0]["params"]["Param1"]["value"] = model_data.bcmdl_path

        # Update caption
        PICKABLE = new_template["property"]["components"]["PICKABLE"]
        PICKABLE["fields"]["fields"]["sOnPickCaption"] = self.pickup["caption"]
        PICKABLE["fields"]["fields"]["sOnPickTankUnknownCaption"] = self.pickup["caption"]

        # Update given item
        if len(self.pickup["resources"]) == 1:
            new_template = self.patch_single_item_pickup(new_template)
        else:
            new_template = self.patch_progressive_pickup(new_template)

        new_path = f"actors/items/randomizer_powerup/charclasses/randomizer_powerup_{self.pickup_id}.bmsad"
        editor.add_new_asset(new_path, Bmsad(new_template, editor.target_game), in_pkgs=pkgs_for_level)
        actor.oActorDefLink = f"actordef:{new_path}"

        # Powerup is in plain sight (except for the part we're using the sphere model)
        actor.pComponents.pop("LIFE", None)

        # Dependencies
        for level_pkg in pkgs_for_level:
            editor.ensure_present(level_pkg, "system/animtrees/base.bmsat")
            editor.ensure_present(level_pkg, "actors/items/itemsphere/charclasses/timeline.bmsas")
            for dep in model_data.dependencies:
                editor.ensure_present(level_pkg, dep)

        for pkg in pkgs_for_level:
            editor.ensure_present(pkg, "actors/items/randomizer_powerup/scripts/randomizer_powerup.lc")


class ActorDefPickup(BasePickup):
    def _patch_actordef_pickup(self, editor: PatcherEditor, item_id_field: str) -> tuple[str, Bmsad]:
        resources = self.pickup["resources"]
        item_id: str = resources[0]["item_id"]

        if len(resources) > 1 or resources[0]["quantity"] > 1 or item_id in EXPANSION_ITEM_IDS:
            item_id = "ITEM_NONE"
            _patch_actordef_pickup_script(editor, self.pickup)

        bmsad_path: str = self.pickup["pickup_actordef"]
        actordef = editor.get_file(bmsad_path, Bmsad)

        AI = actordef.raw["property"]["components"]["AI"]
        AI["fields"]["fields"][item_id_field] = item_id

        # may want to edit all the localization files?
        text_files = {
            # "eu_dutch.txt",
            # "eu_french.txt",
            # "eu_german.txt",
            # "eu_italian.txt",
            # "eu_spanish.txt",
            # "japanese.txt",
            # "korean.txt",
            # "russian.txt",
            # "simplified_chinese.txt",
            # "traditional_chinese.txt",
            "us_english.txt",
            # "us_french.txt",
            # "us_spanish.txt"
        }
        for text_file in text_files:
            text_file = "system/localization/" + text_file
            text = editor.get_file(text_file, Txt)
            text.strings[self.pickup["pickup_string_key"]] = self.pickup["caption"]
            editor.replace_asset(text_file, text)

        return bmsad_path, actordef

    def patch(self, editor: PatcherEditor):
        raise NotImplementedError()


class EmmiPickup(ActorDefPickup):
    def patch(self, editor: PatcherEditor):
        bmsad_path, actordef = self._patch_actordef_pickup(editor, "sInventoryItemOnKilled")
        editor.replace_asset(bmsad_path, actordef)


class CoreXPickup(ActorDefPickup):
    def patch(self, editor: PatcherEditor):
        bmsad_path, actordef = self._patch_actordef_pickup(editor, "sInventoryItemOnBigXAbsorbed")
        editor.replace_asset(bmsad_path, actordef)


class CorpiusPickup(ActorDefPickup):
    def patch(self, editor: PatcherEditor):
        # TODO: fix weirdness with aeion suit upgrade thingy
        bmsad_path, actordef = self._patch_actordef_pickup(editor, "sInventoryItemOnKilled")
        if self.pickup["resources"][0]["item_id"] not in EXPANSION_ITEM_IDS:
            actordef.raw["property"]["components"]["AI"]["fields"]["fields"]["bGiveInventoryItemOnDead"] = True

        editor.replace_asset(bmsad_path, actordef)


_custom_level_scripts: dict[str, str] = {}


def _patch_actordef_pickup_script(editor: PatcherEditor, pickup: dict):
    scenario: str = pickup["pickup_lua_callback"]["scenario"]

    scenario_path = path_for_level(scenario)
    lua_util.create_script_copy(editor, scenario_path)

    if scenario not in _custom_level_scripts.keys():
        _custom_level_scripts[scenario] = "\n".join([
            f"Game.LogWarn(0, 'Loading original {scenario}...')",
            f"Game.ImportLibrary('{scenario_path}_original.lua')",
            f"Game.LogWarn(0, 'Loaded original {scenario}.')",
            f"Game.DoFile('actors/items/randomizer_powerup/scripts/randomizer_powerup.lua')\n\n",
        ])

    replacement = {
        "scenario": scenario,
        "funcname": pickup["pickup_lua_callback"]["function"],
        "pickup_class": get_script_class(pickup, True),
        "args": ", ".join([f"_ARG_{i}_" for i in range(pickup["pickup_lua_callback"]["args"])])
    }
    _custom_level_scripts[scenario] += lua_util.replace_lua_template("boss_powerup_template.lua", replacement)


_PICKUP_TYPE_TO_CLASS = {
    PickupType.ACTOR: ActorPickup,
    PickupType.EMMI: EmmiPickup,
    PickupType.COREX: CoreXPickup,
    PickupType.CORPIUS: CorpiusPickup,
}


def pickup_object_for(pickup: dict, pickup_id: int) -> "BasePickup":
    pickup_type = PickupType(pickup["pickup_type"])
    return _PICKUP_TYPE_TO_CLASS[pickup_type](pickup, pickup_id)
