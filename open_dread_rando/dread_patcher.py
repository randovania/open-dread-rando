import copy
from enum import Enum
import functools
import json
import logging
import shutil
import typing
from pathlib import Path

import jsonschema
from mercury_engine_data_structures.file_tree_editor import FileTreeEditor
from mercury_engine_data_structures.formats import Brfld, Bmsad, BaseResource, Txt

from open_dread_rando.model_data import ALL_MODEL_DATA

T = typing.TypeVar("T")
LOG = logging.getLogger("dread_patcher")


def _read_schema():
    with Path(__file__).parent.joinpath("schema.json").open() as f:
        return json.load(f)


@functools.cache
def _read_template_powerup():
    with Path(__file__).parent.joinpath("template_powerup_bmsad.json").open() as f:
        return json.load(f)


def _read_powerup_lua() -> bytes:
    return Path(__file__).parent.joinpath("randomizer_powerup.lua").read_bytes()


def path_for_level(level_name: str) -> str:
    return f"maps/levels/c10_samus/{level_name}/{level_name}"


def create_init_copy(editor: FileTreeEditor):
    original_init = "system/scripts/original_init.lc"
    if not editor.does_asset_exists(original_init):
        original_lc = editor.get_raw_asset("system/scripts/init.lc")
        editor.add_new_asset(
            original_init,
            original_lc,
            editor.find_pkgs("system/scripts/init.lc")
        )


def create_custom_init(inventory: dict[str, int], starting_location: dict):
    def _wrap(v: str):
        return f'"{v}"'

    # Game doesn't like to start if some fields are missing, like ITEM_WEAPON_POWER_BOMB_MAX
    final_inventory = {
        "ITEM_MAX_LIFE": 99,
        "ITEM_MAX_SPECIAL_ENERGY": 1000,
        "ITEM_METROID_COUNT": 0,
        "ITEM_METROID_TOTAL_COUNT": 40,
        "ITEM_WEAPON_MISSILE_MAX": 0,
        "ITEM_WEAPON_POWER_BOMB_MAX": 0,
    }
    final_inventory.update(inventory)

    replacement = {
        "new_game_inventory": "\n".join(
            "{} = {},".format(key, value)
            for key, value in final_inventory.items()
        ),
        "starting_scenario": _wrap(starting_location["scenario"]),
        "starting_actor": _wrap(starting_location["actor"]),
    }

    code = Path(__file__).parent.joinpath("custom_init.lua").read_text()
    for key, content in replacement.items():
        code = code.replace(f'TEMPLATE("{key}")', content)

    return code


class PatcherEditor(FileTreeEditor):
    memory_files: dict[str, BaseResource]

    def __init__(self, root: Path):
        super().__init__(root)
        self.memory_files = {}

    def get_file(self, path: str, type_hint: typing.Type[T] = BaseResource) -> T:
        if path not in self.memory_files:
            self.memory_files[path] = self.get_parsed_asset(path, type_hint=type_hint)
        return self.memory_files[path]

    def get_scenario(self, name: str) -> Brfld:
        return self.get_file(path_for_level(name) + ".brfld", Brfld)

    def flush_modified_assets(self):
        for name, resource in self.memory_files.items():
            self.replace_asset(name, resource)
        self.memory_files = {}


def patch_elevators(editor: PatcherEditor, elevators_config: list[dict]):
    for elevator in elevators_config:
        LOG.info("Writing elevator from: %s", str(elevator["teleporter"]))
        level = editor.get_scenario(elevator["teleporter"]["scenario"])
        actor = level.actors_for_layer(elevator["teleporter"]["layer"])[elevator["teleporter"]["actor"]]
        try:
            usable = actor.pComponents.USABLE
        except AttributeError:
            raise ValueError(f'Actor {elevator["teleporter"]} is not a teleporter')
        usable.sScenarioName = elevator["destination"]["scenario"]
        usable.sTargetSpawnPoint = elevator["destination"]["actor"]

class PickupType(Enum):
    ACTOR = "actor"
    EMMI = "emmi"
    COREX = "corex"
    CORPIUS = "corpius"

    def patch_pickup(self, editor: PatcherEditor, pickup: dict, pickup_id: int):
        if self == PickupType.ACTOR:
            patch_actor_pickup(editor, pickup, pickup_id)
        if self == PickupType.EMMI:
            patch_emmi_pickup(editor, pickup, pickup_id)
        if self == PickupType.COREX:
            patch_corex_pickup(editor, pickup, pickup_id)
        if self == PickupType.CORPIUS:
            patch_corpius_pickup(editor, pickup, pickup_id)

def patch_actor_pickup(editor: PatcherEditor, pickup: dict, pickup_id: int):
    template_bmsad = _read_template_powerup()

    pkgs_for_level = set(editor.find_pkgs(path_for_level(pickup["pickup_actor"]["scenario"]) + ".brfld"))

    level = editor.get_scenario(pickup["pickup_actor"]["scenario"])
    actor = level.actors_for_layer(pickup["pickup_actor"]["layer"])[pickup["pickup_actor"]["actor"]]

    model_name: str = pickup["model"]
    model_data = ALL_MODEL_DATA.get(model_name, ALL_MODEL_DATA["itemsphere"])

    new_template = copy.deepcopy(template_bmsad)
    new_template["name"] = f"randomizer_powerup_{pickup_id}"

    # Update used model
    new_template["property"]["model_name"] = model_data.bcmdl_path
    MODELUPDATER = new_template["property"]["components"]["MODELUPDATER"]
    MODELUPDATER["functions"][0]["params"]["Param1"]["value"] = model_data.bcmdl_path

    # Update caption
    PICKABLE = new_template["property"]["components"]["PICKABLE"]
    PICKABLE["fields"]["fields"]["sOnPickCaption"] = pickup["caption"]
    PICKABLE["fields"]["fields"]["sOnPickTankUnknownCaption"] = pickup["caption"]

    # Update given item
    set_custom_params: dict = PICKABLE["functions"][0]["params"]
    item_id: str = pickup["item_id"]
    quantity: float = pickup["quantity"]

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
        PICKABLE["fields"]["fields"]["sOnPickEnergyFragment1Caption"] = pickup["caption"]
        PICKABLE["fields"]["fields"]["sOnPickEnergyFragment2Caption"] = pickup["caption"]
        PICKABLE["fields"]["fields"]["sOnPickEnergyFragment3Caption"] = pickup["caption"]
        PICKABLE["fields"]["fields"]["sOnPickEnergyFragmentCompleteCaption"] = pickup["caption"]

    elif item_id in {"ITEM_WEAPON_MISSILE_MAX", "ITEM_WEAPON_POWER_BOMB_MAX"}:
        set_custom_params["Param4"]["value"] = "Custom"
        set_custom_params["Param5"]["value"] = item_id.replace("_MAX", "_CURRENT")
        set_custom_params["Param8"]["value"] = "guicallbacks.OnSecondaryGunsFire"
        set_custom_params["Param13"] = {
            "type": "f",
            "value": quantity,
        }

    set_custom_params["Param1"]["value"] = item_id
    set_custom_params["Param2"]["value"] = quantity

    new_path = f"actors/items/randomizer_powerup/charclasses/randomizer_powerup_{pickup_id}.bmsad"
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

    # # For debugging, write the bmsad we just created
    # Path("custom_bmsad", f"randomizer_powerup_{i}.bmsad.json").write_text(
    #     json.dumps(new_template, indent=4)
    # )
    for pkg in pkgs_for_level:
        editor.ensure_present(pkg, "actors/items/randomizer_powerup/scripts/randomizer_powerup.lc")

def patch_emmi_pickup(editor: PatcherEditor, pickup: dict, pickup_id: int):
    bmsad_path, actordef = _patch_actordef_pickup(editor, pickup, pickup_id, "sInventoryItemOnKilled")
    editor.replace_asset(bmsad_path, actordef)

def patch_corex_pickup(editor: PatcherEditor, pickup: dict, pickup_id: int):
    bmsad_path, actordef = _patch_actordef_pickup(editor, pickup, pickup_id, "sInventoryItemOnBigXAbsorbed")
    editor.replace_asset(bmsad_path, actordef)

def patch_corpius_pickup(editor: PatcherEditor, pickup: dict, pickup_id: int):
    # TODO: fix weirdness with aeion suit upgrade thingy
    bmsad_path, actordef = _patch_actordef_pickup(editor, pickup, pickup_id, "sInventoryItemOnKilled")
    actordef._raw["property"]["components"]["AI"]["fields"]["fields"]["bGiveInventoryItemOnDead"] = True

    editor.replace_asset(bmsad_path, actordef)


def _patch_actordef_pickup(editor: PatcherEditor, pickup: dict, pickup_id: int, item_id_field: str) -> typing.Tuple[str, Bmsad]:
    if pickup["quantity"] > 1:
        raise NotImplementedError("Boss items cannot yet provide quantities greater than 1.")
    
    item_id: str = pickup["item_id"]
    if item_id in {"ITEM_ENERGY_TANKS", "ITEM_LIFE_SHARDS", "ITEM_WEAPON_MISSILE_MAX", "ITEM_WEAPON_POWER_BOMB_MAX"}:
        raise NotImplementedError("Boss items cannot yet provide expansions.")

    bmsad_path: str = pickup["pickup_actordef"]
    actordef = editor.get_file(bmsad_path, Bmsad)
    
    AI = actordef._raw["property"]["components"]["AI"]
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
        text_file = "system/localization/"+text_file
        text = editor.get_file(text_file, Txt)
        text.strings[pickup["pickup_string_key"]] = pickup["caption"]
        editor.replace_asset(text_file, text)

    return bmsad_path, actordef
    

def patch_pickups(editor: PatcherEditor, pickups_config: list[dict]):
    editor.add_new_asset("actors/items/randomizer_powerup/scripts/randomizer_powerup.lc", _read_powerup_lua(), [])

    for i, pickup in enumerate(pickups_config):
        LOG.info("Writing pickup %d: %s", i, pickup["item_id"])
        pickup_type = PickupType(pickup["pickup_type"])
        try:
            pickup_type.patch_pickup(editor, pickup, i)
        except NotImplementedError as e:
            LOG.warning(e)


def patch(input_path: Path, output_path: Path, configuration: dict):
    LOG.info("Will patch files from %s", input_path)

    jsonschema.validate(instance=configuration, schema=_read_schema())

    out_romfs = output_path.joinpath("romfs")
    editor = PatcherEditor(input_path)

    create_init_copy(editor)

    editor.replace_asset(
        "system/scripts/init.lc",
        create_custom_init(
            configuration["starting_items"],
            configuration["starting_location"]
        ).encode("ascii"),
    )

    if "elevators" in configuration:
        patch_elevators(editor, configuration["elevators"])

    patch_pickups(editor, configuration["pickups"])

    editor.flush_modified_assets()

    shutil.rmtree(out_romfs, ignore_errors=True)
    editor.save_modified_pkgs(out_romfs)
    logging.info("Done")
