import copy
import functools
import json
from enum import Enum
from pathlib import Path

from mercury_engine_data_structures.formats import Bmsad

from open_dread_rando import model_data
from open_dread_rando.patcher_editor import PatcherEditor

@functools.cache
def _template_read_shieldcover():
    with Path(__file__).parent.joinpath("templates", "template_doorshield_bmsad.json").open() as f:
        return json.load(f)
    
class DoorTemplates(Enum):
    COVER = "SHIELD_COVER"
    ENERGY = "SHIELD_ENERGY"

class ShieldType(Enum):
    
    ICE_MISSILE = {
        "name" : "shield_icemissile",
        "type" : DoorTemplates.COVER,
        "weaknesses" : ["ICE_MISSILE"],
        "model" : "actors/props/shield_icemissile/models/shield_icemissile.bcmdl",
        "actordef" : "actors/props/shield_icemissile/charclasses/shield_icemissile.bmsad"
    }

    DIFFUSION = {
        "name" : "shield_diffusion",
        "type" : DoorTemplates.ENERGY,
        "weaknesses" : ["DIFFUSION_BEAM"],
        "model" : "actors/props/shield___diffusion/models/shield_diffusion.bcmdl",
        "actordef" : "actors/props/shield___diffusion/charclasses/shield___diffusion.bmsad"
    }


class BaseShield:
    def __init__(self, shield: ShieldType):
        self.data = shield.value
    
    def patch_model_data(self, model_name: str, new_template: dict):
        selected_model_data = model_data.get_data(model_name)

        new_template["property"]["model_name"] = selected_model_data.bcmdl_path
        model_updater = new_template["property"]["components"]["MODELUPDATER"]
        model_updater["functions"][0]["params"]["Param1"]["value"] = selected_model_data.bcmdl_path
    
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

    def patch(self, editor: PatcherEditor):
        template_bmsad = _template_read_shieldcover()
        
        new_template = copy.deepcopy(template_bmsad)
        new_template["name"] = self.data["name"]

        self.patch_model_data(self.data["name"], new_template)

        for w in self.data["weaknesses"]:
            self.add_weakness(w, new_template)

        editor.add_new_asset(self.data["actordef"], Bmsad(new_template, editor.target_game), [])

def create_all_shield_assets(editor: PatcherEditor):
    for shield_type in ShieldType:
        BaseShield(shield_type).patch(editor)
