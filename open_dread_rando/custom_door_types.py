import copy
import dataclasses
import functools
import json
from enum import Enum
from pathlib import Path

from mercury_engine_data_structures.formats import Bmsad

from open_dread_rando import model_data
from open_dread_rando.patcher_editor import PatcherEditor

@functools.cache
def _template_read_shield(file: str):
    with Path(__file__).parent.joinpath("templates", f"{file}.json").open() as f:
        return json.load(f)
    
class DoorTemplates(Enum):
    HEXAGONS = "template_doorshield_hexs_bmsad"
    TRIANGLES = "template_doorshield_tris_bmsad"
    ENERGY = "template_doorshield_energy_bmsad"

@dataclasses.dataclass(frozen=True)
class ShieldData:
    name: str
    type: DoorTemplates
    weaknesses: list[str]
    actordef: str
    collision: str = None

    @property
    def model(self) -> model_data.ModelData:
        return model_data.get_data(self.name)

ALL_SHIELD_DATA: dict[str, ShieldData] = {
    "ice_missile": ShieldData(
        name="shield_icemissile",
        type=DoorTemplates.HEXAGONS,
        weaknesses=["ICE_MISSILE"],
        actordef="actors/props/shield_icemissile/charclasses/shield_icemissile.bmsad"
    ),

    "diffusion_beam": ShieldData(
        name="shield_diffusion",
        type=DoorTemplates.ENERGY,
        weaknesses=["DIFFUSION_BEAM"],
        actordef="actors/props/shield___diffusion/charclasses/shield___diffusion.bmsad"
    ),

    "storm_missiles": ShieldData(
        name="shield_storm_mssl", # hard to fit in same char len as doorshieldmissile
        type=DoorTemplates.HEXAGONS,
        weaknesses=["MULTI_LOCKON_MISSILE"],
        actordef="actors/props/shield_storm_mssl/charclasses/shield_storm_mssl.bmsad"
    ),

    "bomb": ShieldData(
        name="shield_bombs_regular__",
        type=DoorTemplates.TRIANGLES,
        weaknesses=["BOMB"],
        collision="actors/props/doorshieldmissile/collisions/shield_bomb_colls.bmscd",
        actordef="actors/props/shield_bombs_regular__/charclasses/shield_bombs_regular__.bmsad"
    ),

    "cross_bombs": ShieldData(
        name="shield_cross_bomb",
        type=DoorTemplates.HEXAGONS,
        weaknesses=["LINE_BOMB"],
        collision="actors/props/doorshieldmissile/collisions/shield_bomb_colls.bmscd",
        actordef="actors/props/shield_cross_bomb/charclasses/shield_cross_bomb.bmsad"
    ),

    "power_bomb": ShieldData(
        name="shield_powerbomb",
        type=DoorTemplates.ENERGY,
        weaknesses=["POWER_BOMB"],
        collision="actors/props/doorshieldmissile/collisions/shield_bomb_colls.bmscd",
        actordef="actors/props/shield__power_bomb/charclasses/shield__power_bomb.bmsad"
    ),
}


class BaseShield:
    def __init__(self, shield: ShieldData):
        self.data = shield
    
    def patch_model_data(self, new_template: dict):
        new_template["property"]["model_name"] = self.data.model.bcmdl_path
        model_updater = new_template["property"]["components"]["MODELUPDATER"]
        model_updater["functions"][0]["params"]["Param1"]["value"] = self.data.model.bcmdl_path
    
    def add_weakness(self, weakness: str, new_template: dict):
        life_funcs: list = new_template["property"]["components"]["LIFE"]["functions"]

        new_func = {
            "name" : "AddDamageSource",
            "unk" : 1,
            "params" : {
                "Param1" : {
                    "type" : "s",
                    "value" : weakness
                }
            }
        }

        life_funcs.append(new_func)
    
    def change_collision(self, new_template: dict):
        coll_comp = new_template["property"]["components"]["COLLISION"]
        coll_comp["dependencies"]["file"] = self.data.collision

    def patch(self, editor: PatcherEditor):
        template_bmsad = _template_read_shield(self.data.type.value)
        
        new_template = copy.deepcopy(template_bmsad)
        new_template["name"] = self.data.name

        self.patch_model_data(new_template)

        for w in self.data.weaknesses:
            self.add_weakness(w, new_template)

        if self.data.collision:
            self.change_collision(new_template)

        editor.add_new_asset(self.data.actordef, Bmsad(new_template, editor.target_game), [])

def create_all_shield_assets(editor: PatcherEditor):
    for _, shield_type in ALL_SHIELD_DATA.items():
        BaseShield(shield_type).patch(editor)
