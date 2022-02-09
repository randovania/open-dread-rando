import copy
import functools
import json
from enum import Enum
from pathlib import Path

from mercury_engine_data_structures.formats import Bmsad, Txt

from open_dread_rando import model_data
from open_dread_rando.lua_editor import LuaEditor
from open_dread_rando.patcher_editor import PatcherEditor, path_for_level

EXPANSION_ITEM_IDS = {
    "ITEM_ENERGY_TANKS",
    "ITEM_LIFE_SHARDS",
    "ITEM_WEAPON_MISSILE_MAX",
    "ITEM_WEAPON_POWER_BOMB_MAX",
    "ITEM_WEAPON_POWER_BOMB",
}

# may want to edit all the localization files?
ALL_TEXT_FILES = {
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


@functools.cache
def _read_template_powerup():
    with Path(__file__).parent.joinpath("templates", "template_powerup_bmsad.json").open() as f:
        return json.load(f)


class PickupType(Enum):
    ACTOR = "actor"
    EMMI = "emmi"
    COREX = "corex"
    CORPIUS = "corpius"


class BasePickup:
    def __init__(self, lua_editor: LuaEditor, pickup: dict, pickup_id: int):
        self.lua_editor = lua_editor
        self.pickup = pickup
        self.pickup_id = pickup_id

    def patch(self, editor: PatcherEditor):
        raise NotImplementedError()


class ActorPickup(BasePickup):
    def patch_single_item_pickup(self, bmsad: dict) -> dict:
        pickable: dict = bmsad["property"]["components"]["PICKABLE"]
        script: dict = bmsad["property"]["components"]["SCRIPT"]

        set_custom_params: dict = pickable["functions"][0]["params"]
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

            fields = pickable["fields"]["fields"]
            caption = self.pickup["caption"]
            if caption == "Energy Part acquired.\nCollect 4 to increase energy capacity.":
                # If text is vanilla, then support showing how many parts we had.
                fields["sOnPickEnergyFragment1Caption"] = "#GUI_TANK_ACQUIRED_ENERGY_FRAGMENT_1"
                fields["sOnPickEnergyFragment2Caption"] = "#GUI_TANK_ACQUIRED_ENERGY_FRAGMENT_2"
                fields["sOnPickEnergyFragment3Caption"] = "#GUI_TANK_ACQUIRED_ENERGY_FRAGMENT_3"
                fields["sOnPickEnergyFragmentCompleteCaption"] = "#GUI_TANK_ACQUIRED_ENERGY_FRAGMENT_COMPLETE"
            else:
                for field_name in ["sOnPickEnergyFragment1Caption", "sOnPickEnergyFragment2Caption",
                                   "sOnPickEnergyFragment3Caption", "sOnPickEnergyFragmentCompleteCaption"]:
                    fields[field_name] = caption

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

        script["functions"][0]["params"]["Param2"]["value"] = self.lua_editor.get_script_class(self.pickup["resources"])

        if item_id == "ITEM_WEAPON_POWER_BOMB":
            item_id = "ITEM_WEAPON_POWER_BOMB_MAX"

        set_custom_params["Param1"]["value"] = item_id
        set_custom_params["Param2"]["value"] = quantity

        return bmsad

    def patch_progressive_pickup(self, bmsad: dict) -> dict:
        item_ids = {resource["item_id"] for resource in self.pickup["resources"]}
        if not EXPANSION_ITEM_IDS.isdisjoint(item_ids):
            raise NotImplementedError("Progressive pickups cannot include expansions.")

        pickable: dict = bmsad["property"]["components"]["PICKABLE"]
        script: dict = bmsad["property"]["components"]["SCRIPT"]

        set_custom_params: dict = pickable["functions"][0]["params"]
        set_custom_params["Param1"]["value"] = "ITEM_NONE"

        script["functions"][0]["params"]["Param2"]["value"] = self.lua_editor.get_script_class(self.pickup["resources"])

        return bmsad

    def patch(self, editor: PatcherEditor):
        template_bmsad = _read_template_powerup()

        pickup_actor = self.pickup["pickup_actor"]
        pkgs_for_level = set(editor.find_pkgs(path_for_level(pickup_actor["scenario"]) + ".brfld"))
        level = editor.get_scenario(pickup_actor["scenario"])
        actor = level.actors_for_layer(pickup_actor["layer"])[pickup_actor["actor"]]

        model_name: str = self.pickup["model"]
        selected_model_data = model_data.get_data(model_name)

        new_template = copy.deepcopy(template_bmsad)
        new_template["name"] = f"randomizer_powerup_{self.pickup_id}"

        # Update used model
        new_template["property"]["model_name"] = selected_model_data.bcmdl_path
        model_updater = new_template["property"]["components"]["MODELUPDATER"]
        model_updater["functions"][0]["params"]["Param1"]["value"] = selected_model_data.bcmdl_path

        # Apply grapple particles
        if selected_model_data.grapple_fx:
            grapple = editor.get_file("actors/items/powerup_grapplebeam/charclasses/powerup_grapplebeam.bmsad", Bmsad)
            grapple_components = grapple.raw["property"]["components"]
            components = new_template["property"]["components"]
            components["MATERIALFX"] = grapple_components["MATERIALFX"]
            components["FX"] = grapple_components["FX"]
        
        if selected_model_data.transform is not None:
            model_updater["fields"] = {
                "empty_string": "",
                "root": "Root",
                "fields": {
                    "vInitScale": list(selected_model_data.transform.scale)
                }
            }
            actor.vPos = [a+b for a,b in zip(actor.vPos, selected_model_data.transform.position)]
            actor.vAng = [a+b for a,b in zip(actor.vAng, selected_model_data.transform.angle)]

        # Update caption
        pickable = new_template["property"]["components"]["PICKABLE"]
        pickable["fields"]["fields"]["sOnPickCaption"] = self.pickup["caption"]
        pickable["fields"]["fields"]["sOnPickTankUnknownCaption"] = self.pickup["caption"]

        # Animation/BMSAS
        new_template["property"]["binaries"][0] = selected_model_data.bmsas

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
            editor.ensure_present(level_pkg, selected_model_data.bmsas)
            for dep in selected_model_data.dependencies:
                editor.ensure_present(level_pkg, dep)

        for pkg in pkgs_for_level:
            editor.ensure_present(pkg, "actors/items/randomizer_powerup/scripts/randomizer_powerup.lc")


class ActorDefPickup(BasePickup):
    def _patch_actordef_pickup_script_help(self, editor: PatcherEditor):
        return self.lua_editor.patch_actordef_pickup_script(
            editor,
            self.pickup["resources"],
            self.pickup["pickup_lua_callback"],
        )

    def _patch_actordef_pickup(self, editor: PatcherEditor, item_id_field: str) -> tuple[str, Bmsad]:
        resources = self.pickup["resources"]
        item_id: str = resources[0]["item_id"]

        if len(resources) > 1 or resources[0]["quantity"] > 1 or item_id in EXPANSION_ITEM_IDS:
            item_id = "ITEM_NONE"
            self._patch_actordef_pickup_script_help(editor)

        bmsad_path: str = self.pickup["pickup_actordef"]
        actordef = editor.get_file(bmsad_path, Bmsad)

        ai_component = actordef.raw["property"]["components"]["AI"]
        ai_component["fields"]["fields"][item_id_field] = item_id

        for text_file in ALL_TEXT_FILES:
            text_file = "system/localization/" + text_file
            text = editor.get_file(text_file, Txt)
            text.strings[self.pickup["pickup_string_key"]] = self.pickup["caption"]

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

    def _patch_actordef_pickup_script_help(self, editor: PatcherEditor):
        return self.lua_editor.patch_corex_pickup_script(
            editor,
            self.pickup["resources"],
            self.pickup["pickup_lua_callback"],
        )


class CorpiusPickup(ActorDefPickup):
    def patch(self, editor: PatcherEditor):
        bmsad_path, actordef = self._patch_actordef_pickup(editor, "sInventoryItemOnKilled")
        if self.pickup["resources"][0]["item_id"] not in EXPANSION_ITEM_IDS:
            actordef.raw["property"]["components"]["AI"]["fields"]["fields"]["bGiveInventoryItemOnDead"] = True

        editor.replace_asset(bmsad_path, actordef)


_PICKUP_TYPE_TO_CLASS = {
    PickupType.ACTOR: ActorPickup,
    PickupType.EMMI: EmmiPickup,
    PickupType.COREX: CoreXPickup,
    PickupType.CORPIUS: CorpiusPickup,
}


def pickup_object_for(lua_scripts: LuaEditor, pickup: dict, pickup_id: int) -> "BasePickup":
    pickup_type = PickupType(pickup["pickup_type"])
    return _PICKUP_TYPE_TO_CLASS[pickup_type](lua_scripts, pickup, pickup_id)
