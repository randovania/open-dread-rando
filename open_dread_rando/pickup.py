import copy
import functools
import json
from enum import Enum
from pathlib import Path
from typing import Type

from construct import Container
from mercury_engine_data_structures.formats import Bmsad, Bmmap

from open_dread_rando import model_data
from open_dread_rando.lua_editor import LuaEditor
from open_dread_rando.patcher_editor import PatcherEditor
from open_dread_rando.text_patches import patch_text

EXPANSION_ITEM_IDS = {
    "ITEM_ENERGY_TANKS",
    "ITEM_LIFE_SHARDS",
    "ITEM_WEAPON_MISSILE_MAX",
    "ITEM_WEAPON_POWER_BOMB_MAX",
    "ITEM_WEAPON_POWER_BOMB",
    "ITEM_UPGRADE_FLASH_SHIFT_CHAIN",

    # For multiworld
    "ITEM_NONE",
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
    CUTSCENE = "cutscene"


class BasePickup:
    def __init__(self, lua_editor: LuaEditor, pickup: dict, pickup_id: int, configuration: dict):
        self.lua_editor = lua_editor
        self.pickup = pickup
        self.pickup_id = pickup_id
        self.configuration = configuration

    def patch(self, editor: PatcherEditor):
        raise NotImplementedError()


class ActorPickup(BasePickup):
    def patch_single_item_pickup(self, bmsad: dict) -> dict:
        pickable: dict = bmsad["property"]["components"]["PICKABLE"]
        script: dict = bmsad["property"]["components"]["SCRIPT"]

        set_custom_params: dict = pickable["functions"][0]["params"]
        item_id: str = self.pickup["resources"][0][0]["item_id"]
        quantity: float = self.pickup["resources"][0][0]["quantity"]

        if item_id == "ITEM_ENERGY_TANKS":
            quantity *= self.configuration["energy_per_tank"]
            set_custom_params["Param4"]["value"] = "Full"
            set_custom_params["Param5"]["value"] = "fCurrentLife"
            set_custom_params["Param6"]["value"] = "LIFE"

            item_id = "fMaxLife"

        elif item_id == "ITEM_LIFE_SHARDS" and self.configuration["immediate_energy_parts"]:
            item_id = "ITEM_NONE"

        elif item_id == "ITEM_LIFE_SHARDS" and not self.configuration["immediate_energy_parts"]:
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

        script["functions"][0]["params"]["Param2"]["value"] = self.lua_editor.get_script_class(self.pickup)

        set_custom_params["Param1"]["value"] = item_id
        set_custom_params["Param2"]["value"] = quantity

        return bmsad

    def patch_multi_item_pickup(self, bmsad: dict) -> dict:
        pickable: dict = bmsad["property"]["components"]["PICKABLE"]
        script: dict = bmsad["property"]["components"]["SCRIPT"]

        set_custom_params: dict = pickable["functions"][0]["params"]
        set_custom_params["Param1"]["value"] = "ITEM_NONE"

        script["functions"][0]["params"]["Param2"]["value"] = self.lua_editor.get_script_class(self.pickup,
                                                                                               actordef_name=bmsad[
                                                                                                   "name"])

        return bmsad

    def patch_model(self, editor: PatcherEditor, model_names: list[str], actor: Container,
                    new_template: dict):
        if len(model_names) == 1:
            selected_model_data = model_data.get_data(model_names[0])

            # Update used model
            new_template["property"]["model_name"] = selected_model_data.bcmdl_path
            model_updater = new_template["property"]["components"]["MODELUPDATER"]
            model_updater["functions"][0]["params"]["Param1"]["value"] = selected_model_data.bcmdl_path

            # Apply grapple particles
            if selected_model_data.grapple_fx:
                grapple = editor.get_file("actors/items/powerup_grapplebeam/charclasses/powerup_grapplebeam.bmsad",
                                          Bmsad)
                grapple_components = grapple.raw["property"]["components"]
                components = new_template["property"]["components"]
                components["MATERIALFX"] = grapple_components["MATERIALFX"]
                components["FX"] = grapple_components["FX"]

            if selected_model_data.transform is not None:
                model_updater["fields"] = {
                    "empty_string": "",
                    "root": "Root",
                    "fields": {
                        "vInitScale": list(selected_model_data.transform.scale),
                        "vInitPosWorldOffset": list(selected_model_data.transform.position),
                        "vInitAngWorldOffset": list(selected_model_data.transform.angle),
                    }
                }

            # Animation/BMSAS
            new_template["property"]["binaries"][0] = selected_model_data.bmsas
        else:
            default_model_data = model_data.get_data(model_names[0])
            model_updater = new_template["property"]["components"]["MODELUPDATER"]

            new_template["property"]["model_name"] = default_model_data.bcmdl_path
            model_updater["type"] = "CMultiModelUpdaterComponent"
            model_updater["fields"] = {
                "empty_string": "",
                "root": "Root",
                "fields": {
                    "dctModels": {
                        name: model_data.get_data(name).bcmdl_path
                        for name in model_names
                    }
                }
            }
            model_updater["functions"] = []

            new_template["property"]["binaries"][:0] = [model_data.get_data(name).bmsas for name in model_names]

            actor.pComponents.MODELUPDATER["@type"] = "CMultiModelUpdaterComponent"
            actor.pComponents.MODELUPDATER.sModelAlias = model_names[0]

    def patch_minimap_icon(self, editor: PatcherEditor, actor: Container):
        if "map_icon" in self.pickup and "original_actor" in self.pickup["map_icon"]:
            map_actor = self.pickup["map_icon"]["original_actor"]
        else:
            map_actor = self.pickup["pickup_actor"]

        map_def = editor.get_scenario_file(map_actor["scenario"], Bmmap)
        if map_actor["actor"] in map_def.ability_labels:
            map_def.ability_labels.pop(map_actor["actor"])
        if map_actor["actor"] in map_def.items:
            icon = map_def.items.pop(map_actor["actor"])
            icon.sIconId = editor.map_icon_editor.get_data(self.pickup)
            map_def.items[actor.sName] = icon

    def patch(self, editor: PatcherEditor):
        template_bmsad = _read_template_powerup()

        pickup_actor = self.pickup["pickup_actor"]
        pkgs_for_level = editor.get_level_pkgs(pickup_actor["scenario"])
        actor = editor.resolve_actor_reference(pickup_actor)

        new_template = copy.deepcopy(template_bmsad)
        new_template["name"] = f"randomizer_powerup_{self.pickup_id}"

        # Update model
        model_names: list[str] = self.pickup["model"]
        self.patch_model(editor, model_names, actor, new_template)

        # Update minimap
        self.patch_minimap_icon(editor, actor)

        # Update caption
        pickable = new_template["property"]["components"]["PICKABLE"]
        pickable["fields"]["fields"]["sOnPickCaption"] = self.pickup["caption"]
        pickable["fields"]["fields"]["sOnPickTankUnknownCaption"] = self.pickup["caption"]

        # Update given item
        if len(self.pickup["resources"]) == 1 and len(self.pickup["resources"][0]) == 1:
            new_template = self.patch_single_item_pickup(new_template)
        else:
            new_template = self.patch_multi_item_pickup(new_template)

        new_path = f"actors/items/randomizer_powerup/charclasses/randomizer_powerup_{self.pickup_id}.bmsad"
        editor.add_new_asset(new_path, Bmsad(new_template, editor.target_game), in_pkgs=pkgs_for_level)
        actor.oActorDefLink = f"actordef:{new_path}"

        # Powerup is in plain sight (except for the part we're using the sphere model)
        actor.pComponents.pop("LIFE", None)

        actor.bEnabled = True
        actor.pComponents.MODELUPDATER.bWantsEnabled = True

        # Dependencies
        for level_pkg in pkgs_for_level:
            editor.ensure_present(level_pkg, "system/animtrees/base.bmsat")

            for name in model_names:
                selected_model_data = model_data.get_data(name)
                editor.ensure_present(level_pkg, selected_model_data.bmsas)
                for dep in selected_model_data.dependencies:
                    editor.ensure_present(level_pkg, dep)
                if selected_model_data.grapple_fx:
                    # always include Grapple FX particle or the game could crash
                    editor.ensure_present(level_pkg, "actors/items/powerup_grapplebeam/fx/auraitemparticle.bcptl")

            editor.ensure_present(level_pkg, "actors/items/randomizer_powerup/scripts/randomizer_powerup.lc")


class ActorDefPickup(BasePickup):
    def _patch_actordef_pickup_script_help(self, editor: PatcherEditor):
        return self.lua_editor.patch_actordef_pickup_script(
            editor,
            self.pickup,
            self.pickup["pickup_lua_callback"],
        )

    def _patch_actordef_pickup(self, editor: PatcherEditor, item_id_field: str) -> tuple[str, Bmsad]:
        self._patch_actordef_pickup_script_help(editor)

        bmsad_path: str = self.pickup["pickup_actordef"]
        actordef = editor.get_file(bmsad_path, Bmsad)

        ai_component = actordef.raw["property"]["components"]["AI"]
        ai_component["fields"]["fields"][item_id_field] = "ITEM_NONE"

        patch_text(editor, self.pickup["pickup_string_key"], self.pickup["caption"])

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
            self.pickup,
            self.pickup["pickup_lua_callback"],
        )


class CorpiusPickup(ActorDefPickup):
    def patch(self, editor: PatcherEditor):
        bmsad_path, actordef = self._patch_actordef_pickup(editor, "sInventoryItemOnKilled")
        if self.pickup["resources"][0][0]["item_id"] not in EXPANSION_ITEM_IDS:
            actordef.raw["property"]["components"]["AI"]["fields"]["fields"]["bGiveInventoryItemOnDead"] = True

        editor.replace_asset(bmsad_path, actordef)


class CutscenePickup(BasePickup):
    def patch(self, editor: PatcherEditor):
        self.lua_editor.patch_actordef_pickup_script(
            editor,
            self.pickup,
            self.pickup["pickup_lua_callback"],
            'GUI.ShowMessage({}, true, "")'.format(repr(self.pickup["caption"]))
        )


_PICKUP_TYPE_TO_CLASS: dict[PickupType, Type[BasePickup]] = {
    PickupType.ACTOR: ActorPickup,
    PickupType.EMMI: EmmiPickup,
    PickupType.COREX: CoreXPickup,
    PickupType.CORPIUS: CorpiusPickup,
    PickupType.CUTSCENE: CutscenePickup,
}


def pickup_object_for(lua_scripts: LuaEditor, pickup: dict, pickup_id: int, configuration: dict) -> "BasePickup":
    pickup_type = PickupType(pickup["pickup_type"])
    return _PICKUP_TYPE_TO_CLASS[pickup_type](lua_scripts, pickup, pickup_id, configuration)
