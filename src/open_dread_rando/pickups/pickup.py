import functools
from enum import Enum

from construct import Container
from mercury_engine_data_structures.formats import Bmmap, Bmsad

from open_dread_rando.files import templates_path
from open_dread_rando.misc_patches.text_patches import patch_text
from open_dread_rando.patcher_editor import PatcherEditor
from open_dread_rando.pickups import model_data
from open_dread_rando.pickups.lua_editor import LuaEditor

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
def _read_template_powerup() -> bytes:
    return templates_path().joinpath("template_powerup.bmsad").read_bytes()


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

    def patch(self, editor: PatcherEditor) -> None:
        raise NotImplementedError()


class ActorPickup(BasePickup):
    def patch_single_item_pickup(self, bmsad: Bmsad) -> Bmsad:
        pickable = bmsad.components["PICKABLE"]
        script = bmsad.components["SCRIPT"]

        set_custom = pickable.functions[0]
        item_id: str = self.pickup["resources"][0][0]["item_id"]
        quantity: float = self.pickup["resources"][0][0]["quantity"]

        if item_id == "ITEM_ENERGY_TANKS":
            quantity *= self.configuration["energy_per_tank"]
            set_custom.set_param(4, "Full")
            set_custom.set_param(5, "fCurrentLife")
            set_custom.set_param(6, "LIFE")

            item_id = "fMaxLife"

        elif item_id == "ITEM_LIFE_SHARDS" and self.configuration["immediate_energy_parts"]:
            item_id = "ITEM_NONE"

        elif item_id == "ITEM_LIFE_SHARDS" and not self.configuration["immediate_energy_parts"]:
            item_id = "fLifeShards"
            set_custom.set_param(4, "Custom")
            set_custom.set_param(5, "")
            set_custom.set_param(6, "LIFE")
            set_custom.set_param(7, "#GUI_ITEM_ACQUIRED_ENERGY_SHARD")

            fields = pickable.fields
            caption = self.pickup["caption"]
            if caption == "Energy Part acquired.\nCollect 4 to increase energy capacity.":
                # If text is vanilla, then support showing how many parts we had.
                fields.sOnPickEnergyFragment1Caption = "#GUI_TANK_ACQUIRED_ENERGY_FRAGMENT_1"
                fields.sOnPickEnergyFragment2Caption = "#GUI_TANK_ACQUIRED_ENERGY_FRAGMENT_2"
                fields.sOnPickEnergyFragment3Caption = "#GUI_TANK_ACQUIRED_ENERGY_FRAGMENT_3"
                fields.sOnPickEnergyFragmentCompleteCaption = "#GUI_TANK_ACQUIRED_ENERGY_FRAGMENT_COMPLETE"
            else:
                for field_name in ["sOnPickEnergyFragment1Caption", "sOnPickEnergyFragment2Caption",
                                   "sOnPickEnergyFragment3Caption", "sOnPickEnergyFragmentCompleteCaption"]:
                    setattr(fields, field_name, caption)

        elif item_id in {"ITEM_WEAPON_MISSILE_MAX", "ITEM_WEAPON_POWER_BOMB_MAX", "ITEM_WEAPON_POWER_BOMB"}:
            current = item_id.replace("_MAX", "_CURRENT")
            if item_id == current:
                current += "_CURRENT"

            set_custom.set_param(4, "Custom")
            set_custom.set_param(5, current)
            set_custom.set_param(8, "guicallbacks.OnSecondaryGunsFire")
            set_custom.set_param(13, quantity)

        script.functions[0].set_param(2, self.lua_editor.get_script_class(self.pickup))

        set_custom.set_param(1, item_id)
        set_custom.set_param(2, float(quantity))

        return bmsad

    def patch_multi_item_pickup(self, bmsad: Bmsad) -> Bmsad:
        pickable = bmsad.components["PICKABLE"]
        script = bmsad.components["SCRIPT"]

        item_id: str = "ITEM_NONE"
        first_progression: str = self.pickup["resources"][0][0]["item_id"]
        if first_progression in {"ITEM_WEAPON_WIDE_BEAM", "ITEM_WEAPON_SUPER_MISSILE"}:
            # the gun doesn't appear to be selected properly on pickup unless we do this
            item_id = first_progression

        set_custom_params = pickable.functions[0]
        set_custom_params.set_param(1, item_id)

        script.functions[0].set_param(2, self.lua_editor.get_script_class(
            self.pickup, actordef_name=bmsad.name
        ))

        return bmsad

    def patch_model(self, editor: PatcherEditor, model_names: list[str], actor: Container,
                    new_template: Bmsad) -> None:
        if len(model_names) == 1:
            selected_model_data = model_data.get_data(model_names[0])

            # Update used model
            new_template.model_name = selected_model_data.bcmdl_path
            model_updater = new_template.components["MODELUPDATER"]
            model_updater.functions[0].set_param(1, selected_model_data.bcmdl_path)

            # Apply grapple particles
            if selected_model_data.grapple_fx:
                grapple = editor.get_file("actors/items/powerup_grapplebeam/charclasses/powerup_grapplebeam.bmsad",
                                          Bmsad)
                grapple_components = grapple.components
                components = new_template.components
                components["MATERIALFX"] = grapple_components["MATERIALFX"]
                components["FX"] = grapple_components["FX"]
                new_template.components = components

            if selected_model_data.transform is not None:
                model_updater.fields.vInitScale = list(selected_model_data.transform.scale)
                model_updater.fields.vInitPosWorldOffset = list(selected_model_data.transform.position)
                model_updater.fields.vInitAngWorldOffset = list(selected_model_data.transform.angle)

            # Animation/BMSAS
            action_set_refs = list(new_template.action_set_refs)
            action_set_refs[0] = selected_model_data.bmsas
            new_template.action_set_refs = action_set_refs
        else:
            default_model_data = model_data.get_data(model_names[0])
            model_updater = new_template.components["MODELUPDATER"]

            new_template.model_name = default_model_data.bcmdl_path
            model_updater.type = "CMultiModelUpdaterComponent"
            model_updater.fields.dctModels = {
                name: model_data.get_data(name).bcmdl_path
                for name in model_names
            }
            model_updater.functions = []

            action_set_refs = list(new_template.action_set_refs)
            action_set_refs[:0] = [model_data.get_data(name).bmsas for name in model_names]
            new_template.action_set_refs = action_set_refs

            actor.pComponents.MODELUPDATER["@type"] = "CMultiModelUpdaterComponent"
            actor.pComponents.MODELUPDATER.sModelAlias = model_names[0]

    def patch_minimap_icon(self, editor: PatcherEditor, actor: Container) -> None:
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

    def patch(self, editor: PatcherEditor) -> None:
        template_bmsad = _read_template_powerup()

        pickup_actor = self.pickup["pickup_actor"]
        pkgs_for_level = editor.get_level_pkgs(pickup_actor["scenario"])
        actor = editor.resolve_actor_reference(pickup_actor)

        new_template = Bmsad.parse(template_bmsad, target_game=editor.target_game)
        new_template.name = f"randomizer_powerup_{self.pickup_id}"

        # Update model
        model_names: list[str] = self.pickup["model"]
        self.patch_model(editor, model_names, actor, new_template)

        # Update minimap
        self.patch_minimap_icon(editor, actor)

        # Update caption
        pickable = new_template.components["PICKABLE"]
        pickable.fields.sOnPickCaption = self.pickup["caption"]
        pickable.fields.sOnPickTankUnknownCaption = self.pickup["caption"]

        # Update given item
        if len(self.pickup["resources"]) == 1 and len(self.pickup["resources"][0]) == 1:
            new_template = self.patch_single_item_pickup(new_template)
        else:
            new_template = self.patch_multi_item_pickup(new_template)

        new_path = f"actors/items/randomizer_powerup/charclasses/randomizer_powerup_{self.pickup_id}.bmsad"
        editor.add_new_asset(new_path, new_template, in_pkgs=pkgs_for_level)
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
    def _patch_actordef_pickup_script_help(self, editor: PatcherEditor) -> None:
        return self.lua_editor.patch_actordef_pickup_script(
            editor,
            self.pickup,
            self.pickup["pickup_lua_callback"],
        )

    def _patch_actordef_pickup(self, editor: PatcherEditor, item_id_field: str) -> tuple[str, Bmsad]:
        self._patch_actordef_pickup_script_help(editor)

        bmsad_path: str = self.pickup["pickup_actordef"]
        actordef = editor.get_file(bmsad_path, Bmsad)

        ai_component = actordef.components["AI"]
        setattr(ai_component.fields, item_id_field, "ITEM_NONE")

        patch_text(editor, self.pickup["pickup_string_key"], self.pickup["caption"])

        return bmsad_path, actordef

    def patch(self, editor: PatcherEditor) -> None:
        raise NotImplementedError()


class EmmiPickup(ActorDefPickup):
    def patch(self, editor: PatcherEditor) -> None:
        bmsad_path, actordef = self._patch_actordef_pickup(editor, "sInventoryItemOnKilled")
        editor.replace_asset(bmsad_path, actordef)


class CoreXPickup(ActorDefPickup):
    def patch(self, editor: PatcherEditor) -> None:
        bmsad_path, actordef = self._patch_actordef_pickup(editor, "sInventoryItemOnBigXAbsorbed")
        editor.replace_asset(bmsad_path, actordef)

    def _patch_actordef_pickup_script_help(self, editor: PatcherEditor) -> None:
        return self.lua_editor.patch_corex_pickup_script(
            editor,
            self.pickup,
            self.pickup["pickup_lua_callback"],
        )


class CorpiusPickup(ActorDefPickup):
    def patch(self, editor: PatcherEditor) -> None:
        bmsad_path, actordef = self._patch_actordef_pickup(editor, "sInventoryItemOnKilled")
        if self.pickup["resources"][0][0]["item_id"] not in EXPANSION_ITEM_IDS:
            actordef.components["AI"].fields.bGiveInventoryItemOnDead = True

        editor.replace_asset(bmsad_path, actordef)


class CutscenePickup(BasePickup):
    def patch(self, editor: PatcherEditor) -> None:
        self.lua_editor.patch_actordef_pickup_script(
            editor,
            self.pickup,
            self.pickup["pickup_lua_callback"],
            'GUI.ShowMessage({}, true, "")'.format(repr(self.pickup["caption"]))
        )


_PICKUP_TYPE_TO_CLASS: dict[PickupType, type[BasePickup]] = {
    PickupType.ACTOR: ActorPickup,
    PickupType.EMMI: EmmiPickup,
    PickupType.COREX: CoreXPickup,
    PickupType.CORPIUS: CorpiusPickup,
    PickupType.CUTSCENE: CutscenePickup,
}


def pickup_object_for(lua_scripts: LuaEditor, pickup: dict, pickup_id: int, configuration: dict) -> "BasePickup":
    pickup_type = PickupType(pickup["pickup_type"])
    return _PICKUP_TYPE_TO_CLASS[pickup_type](lua_scripts, pickup, pickup_id, configuration)
