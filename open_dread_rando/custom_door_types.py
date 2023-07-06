import copy
import dataclasses
import functools
import json
from enum import Enum
from pathlib import Path

from mercury_engine_data_structures.formats import Bmsad

from open_dread_rando.material_patcher import MaterialData, create_custom_material
from open_dread_rando.model_patcher import ModelData, create_custom_model
from open_dread_rando.patcher_editor import PatcherEditor

MISSILE_MDL = "actors/props/doorshieldmissile/models/doorshieldmissile.bcmdl"
SUPER_MDL = "actors/props/doorshieldsupermissile/models/doorshieldsupermissile.bcmdl"
ENERGY_MDL = "actors/props/door_shield_plasma/models/doorshieldplasma.bcmdl"
MISSILE_MAT = "actors/props/doorshieldmissile/models/imats/doorshieldmissile_mp_opaque_01.bsmat"
SUPER_MAT = "actors/props/doorshieldsupermissile/models/imats/doorshieldsupermissile_mp_opaque_01.bsmat"
ENERGY_MP_MAT = "actors/props/door_shield_plasma/models/imats/doorshieldplasma_mp_opaque_01.bsmat"
ENERGY_FX_MAT = "actors/props/door_shield_plasma/models/imats/doorshieldplasma_matfx.bsmat"
SMOOTH_NORMALS = "actors/props/doorshieldmissile/models/textures/shield_no_normals.bctex"
SMOOTH_ATTRIBUTES = "actors/props/doorshieldmissile/models/textures/shield_no_attribs.bctex"

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
    type: DoorTemplates # TODO make these modify the in-game bmsad's so we don't need templates
    weaknesses: list[str]
    actordef: str
    default_mdl: ModelData # the default new model
    default_mats: list[MaterialData] # a list of materials needed for the default model
    alternate_mats: list[MaterialData] # a list of materials needed for the alternate model
    alternate_mdl: ModelData = None # if none, ALTERNATE shields use default model and only change materials
    collision: str = None

ALL_SHIELD_DATA: dict[str, ShieldData] = {
    "ice_missile": ShieldData(
        name="doorshieldicemissile",
        type=DoorTemplates.TRIANGLES,
        weaknesses=["ICE_MISSILE"],
        actordef="actors/props/doorshieldicemissile/charclasses/doorshieldicemissile.bmsad",
        default_mdl=ModelData(
            base_model=SUPER_MDL,
            new_path="actors/props/doorshieldicemissile/models/doorshieldicemissile.bcmdl",
            materials={
                "mp_opaque_01": "actors/props/doorshieldicemissile/models/imats/doorshieldicemissile_mp_opaque_01.bsmat"
            }
        ),
        default_mats=[
            MaterialData(
                base_mat=MISSILE_MAT,
                new_mat_name="doorshieldicemissile_mp_opaque_01",
                new_path="actors/props/doorshieldicemissile/models/imats/doorshieldicemissile_mp_opaque_01.bsmat",
                uniform_params={
                    "vConstant0": [0.0, 0.94, 0.95, 1.0]
                }
            )
        ],
        alternate_mats=[
            MaterialData(
                base_mat=MISSILE_MAT,
                new_mat_name="doorshieldicemissile_mp_opaque_01",
                new_path="actors/props/doorshieldicemissile/models/imats/doorshieldicemissile_mp_opaque_01.bsmat",
                uniform_params={
                    "vConstant0": [0.0, 0.94, 0.95, 1.0]
                },
                sampler_params={
                    "texBaseColor": { "filepath": ("actors/props/doorshieldicemissile/models"
                                                   "/textures/doorshieldicemissile_alt_bc.bctex") },
                    "texAttributes": { "filepath": SMOOTH_ATTRIBUTES },
                    "texNormals": { "filepath": SMOOTH_NORMALS }
                }
            )
        ]
    ),

    "diffusion_beam": ShieldData(
        name="shield_diffusion", # NOTE required to be <= len("doorshieldplasma") until bcmdl can alter pointers
        type=DoorTemplates.ENERGY,
        weaknesses=["DIFFUSION_BEAM"],
        actordef="actors/props/shield_diffusion/charclasses/shield_diffusion.bmsad",
        default_mdl=ModelData(
            base_model=ENERGY_MDL,
            new_path="actors/props/shield_diffusion/models/shield_diffusion.bcmdl",
            materials={
                "matfx": "actors/props/shield_diffusion/models/imats/shield_diffusion_matfx.bsmat",
                "mp_opaque_01": "actors/props/shield_diffusion/models/imats/shield_diffusion_mp_opaque_01.bsmat"
            }
        ),
        alternate_mdl=ModelData(
            base_model=SUPER_MDL,
            new_path="actors/props/shield_diffusion/models/shield_diffusion.bcmdl",
            materials={
                "mp_opaque_01": "actors/props/shield_diffusion/models/imats/shield_diffusion_mp_opaque_01.bsmat"
            }
        ),
        default_mats=[
            # matfx
            MaterialData(
                base_mat=ENERGY_FX_MAT,
                new_mat_name="shield_diffusion_matfx",
                new_path="actors/props/shield_diffusion/models/imats/shield_diffusion_matfx.bsmat",
                uniform_params={
                    "vConstant0": [1.0, 0.05, 0.05, 1.0]
                }
            ),
            # mp_opaque_01
            MaterialData(
                base_mat=ENERGY_MP_MAT,
                new_mat_name="shield_diffusion_mp_opaque_01",
                new_path="actors/props/shield_diffusion/models/imats/shield_diffusion_mp_opaque_01.bsmat",
                uniform_params={
                    "vConstant1": [1.0, 0.05, 0.05, 0.0]
                }
            )
        ],
        alternate_mats=[
            # mp_opaque_01
            MaterialData(
                base_mat=SUPER_MAT,
                new_mat_name="shield_diffusion_mp_opaque_01",
                new_path="actors/props/shield_diffusion/models/imats/shield_diffusion_mp_opaque_01.bsmat",
                uniform_params={
                    #"fAlbedoEmissiveFactor": [2.0],
                    "vAlbedoEmissiveColorMultiplier": [1.0, 0.05, 0.05, 1.0]
                },
                sampler_params={
                    "texBaseColor": { "filepath": ("actors/props/shield_diffusion/models/"
                                                   "textures/shield_diffusion_alt_bc.bctex")},
                    "texAttributes": { "filepath": SMOOTH_ATTRIBUTES },
                    "texNormals": { "filepath": SMOOTH_NORMALS }
                }
            )
        ]
    ),

    "storm_missile": ShieldData(
        name="doorshieldstormmissile",
        type=DoorTemplates.TRIANGLES,
        weaknesses=["MULTI_LOCKON_MISSILE"],
        actordef="actors/props/doorshieldstormmissile/charclasses/doorshieldstormmissile.bmsad",
        default_mdl=ModelData(
            base_model=SUPER_MDL,
            new_path="actors/props/doorshieldstormmissile/models/doorshieldstormmissile.bcmdl",
            materials={
                "mp_opaque_01": ("actors/props/doorshieldstormmissile/models"
                                 "/imats/doorshieldstormmissile_mp_opaque_01.bsmat")
            }
        ),
        default_mats=[
            MaterialData(
                base_mat=SUPER_MAT,
                new_mat_name="doorshieldstormmissile_mp_opaque_01",
                new_path="actors/props/doorshieldstormmissile/models/imats/doorshieldstormmissile_mp_opaque_01.bsmat",
                uniform_params={
                    "fAlbedoEmissiveFactor": [2.0],
                    "vAlbedoEmissiveColorMultiplier": [1.0, 1.0, 1.0, 1.0],
                    "vConstant0": [7.0, 0.15, 0.0, 1.0]
                },
                sampler_params={
                    "texBaseColor": { "filepath": ("actors/props/doorshieldstormmissile/models"
                                                   "/textures/doorshieldstormmissile_bc.bctex")},
                    # "texAttributes": { "filepath": SMOOTH_ATTRIBUTES },
                    # "texNormals": { "filepath": SMOOTH_NORMALS }
                }
            )
        ],
        alternate_mats=[
            MaterialData(
                base_mat=SUPER_MAT,
                new_mat_name="doorshieldstormmissile_mp_opaque_01",
                new_path="actors/props/doorshieldstormmissile/models/imats/doorshieldstormmissile_mp_opaque_01.bsmat",
                uniform_params={
                    "fAlbedoEmissiveFactor": [7.0],
                    "fSpecularPower": [25.0],
                    "vAlbedoEmissiveColorMultiplier": [7.0, 0.15, 0.0, 1.0],
                    "vConstant0": [1.0, 1.0, 1.0, 1.0]
                },
                sampler_params={
                    "texBaseColor": { "filepath": ("actors/props/doorshieldstormmissile/models"
                                                   "/textures/doorshieldstormmissile_alt_bc.bctex")},
                    "texAttributes": { "filepath": SMOOTH_ATTRIBUTES },
                    "texNormals": { "filepath": SMOOTH_NORMALS }
                }
            )
        ]
    ),

    "bomb": ShieldData(
        name="doorshieldbomb",
        type=DoorTemplates.TRIANGLES,
        weaknesses=["BOMB"],
        collision="actors/props/doorshieldmissile/collisions/shield_bomb_colls.bmscd",
        actordef="actors/props/doorshieldbomb/charclasses/doorshieldbomb.bmsad",
        default_mdl=ModelData(
            base_model=SUPER_MDL,
            new_path="actors/props/doorshieldbomb/models/doorshieldbomb.bcmdl",
            materials={
                "mp_opaque_01": "actors/props/doorshieldbomb/models/imats/doorshieldbomb_mp_opaque_01.bsmat"
            }
        ),
        default_mats=[
            MaterialData(
                base_mat=SUPER_MAT,
                new_mat_name="doorshieldbomb_mp_opaque_01",
                new_path="actors/props/doorshieldbomb/models/imats/doorshieldbomb_mp_opaque_01.bsmat",
                uniform_params={
                    "vAlbedoEmissiveColorMultiplier": [0.987, 0.168, 0.976, 1.0]
                },
                sampler_params={
                    "texBaseColor": { "filepath": ("actors/props/doorshieldbomb/models"
                                                   "/textures/doorshieldbomb_bc.bctex")},
                    "texAttributes": { "filepath": SMOOTH_ATTRIBUTES },
                    "texNormals": { "filepath": SMOOTH_NORMALS }
                }
            )
        ],
        alternate_mats=[
            MaterialData(
                base_mat=SUPER_MAT,
                new_mat_name="doorshieldbomb_mp_opaque_01",
                new_path="actors/props/doorshieldbomb/models/imats/doorshieldbomb_mp_opaque_01.bsmat",
                uniform_params={
                    "vAlbedoEmissiveColorMultiplier": [0.987, 0.168, 0.976, 1.0]
                },
                sampler_params={
                    "texBaseColor": { "filepath": ("actors/props/doorshieldbomb/models"
                                                   "/textures/doorshieldbomb_alt_bc.bctex")},
                    "texAttributes": { "filepath": SMOOTH_ATTRIBUTES },
                    "texNormals": { "filepath": SMOOTH_NORMALS }
                }
            )
        ]
    ),

    "cross_bomb": ShieldData(
        name="doorshieldcrossbomb",
        type=DoorTemplates.TRIANGLES,
        weaknesses=["LINE_BOMB"],
        collision="actors/props/doorshieldmissile/collisions/shield_bomb_colls.bmscd",
        actordef="actors/props/doorshieldcrossbomb/charclasses/doorshieldcrossbomb.bmsad",
        default_mdl=ModelData(
            base_model=SUPER_MDL,
            new_path="actors/props/doorshieldcrossbomb/models/doorshieldcrossbomb.bcmdl",
            materials={
                "mp_opaque_01": ("actors/props/doorshieldcrossbomb/models"
                                 "/imats/doorshieldcrossbomb_mp_opaque_01.bsmat")
            }
        ),
        default_mats=[
            MaterialData(
                base_mat=SUPER_MAT,
                new_mat_name="doorshieldcrossbomb_mp_opaque_01",
                new_path="actors/props/doorshieldcrossbomb/models/imats/doorshieldcrossbomb_mp_opaque_01.bsmat",
                uniform_params={
                    "vAlbedoEmissiveColorMultiplier": [0.987, 0.168, 0.976, 1.0]
                },
                sampler_params={
                    "texBaseColor": { "filepath": ("actors/props/doorshieldpowerbomb/models"
                                                   "/textures/doorshieldpowerbomb_rdv_bc.bctex") },
                    "texAttributes": { "filepath": SMOOTH_ATTRIBUTES },
                    "texNormals": { "filepath": SMOOTH_NORMALS }
                }
            )
        ],
        alternate_mats=[
            MaterialData(
                base_mat=SUPER_MAT,
                new_mat_name="doorshieldcrossbomb_mp_opaque_01",
                new_path="actors/props/doorshieldcrossbomb/models/imats/doorshieldcrossbomb_mp_opaque_01.bsmat",
                uniform_params={
                    "vAlbedoEmissiveColorMultiplier": [0.987, 0.168, 0.976, 1.0]
                },
                sampler_params={
                    # TODO cross bomb basecolor
                    "texBaseColor": { "filepath": ("actors/props/doorshieldcrossbomb/models"
                                                   "/textures/doorshieldcrossbomb_alt_bc.bctex") },
                    "texAttributes": { "filepath": SMOOTH_ATTRIBUTES },
                    "texNormals": { "filepath": SMOOTH_NORMALS }
                }
            )
        ]
    ),

    "power_bomb": ShieldData(
        name="doorshieldpowerbomb",
        type=DoorTemplates.TRIANGLES,
        weaknesses=["POWER_BOMB"],
        collision="actors/props/doorshieldmissile/collisions/shield_bomb_colls.bmscd",
        actordef="actors/props/doorshieldpowerbomb/charclasses/doorshieldpowerbomb.bmsad",
        default_mdl=ModelData(
            base_model=SUPER_MDL,
            new_path="actors/props/doorshieldpowerbomb/models/doorshieldpowerbomb.bcmdl",
            materials={
                "mp_opaque_01": ("actors/props/doorshieldpowerbomb/models"
                                 "/imats/doorshieldpowerbomb_mp_opaque_01.bsmat")
            }
        ),
        default_mats=[
            MaterialData(
                base_mat=SUPER_MAT,
                new_mat_name="doorshieldpowerbomb_mp_opaque_01",
                new_path="actors/props/doorshieldpowerbomb/models/imats/doorshieldpowerbomb_mp_opaque_01.bsmat",
                uniform_params={
                    "vAlbedoEmissiveColorMultiplier": [1.0, 0.15, 0.0, 1.0]
                },
                sampler_params={
                    "texBaseColor": { "filepath": ("actors/props/doorshieldpowerbomb/models"
                                                   "/textures/doorshieldpowerbomb_rdv_bc.bctex") },
                    "texAttributes": { "filepath": SMOOTH_ATTRIBUTES },
                    "texNormals": { "filepath": SMOOTH_NORMALS }
                }
            )
        ],
        alternate_mats=[
            MaterialData(
                base_mat=SUPER_MAT,
                new_mat_name="doorshieldpowerbomb_mp_opaque_01",
                new_path="actors/props/doorshieldpowerbomb/models/imats/doorshieldpowerbomb_mp_opaque_01.bsmat",
                uniform_params={
                    "vAlbedoEmissiveColorMultiplier": [1.0, 0.15, 0.0, 1.0]
                },
                sampler_params={
                    "texBaseColor": { "filepath": ("actors/props/doorshieldpowerbomb/models"
                                                   "/textures/doorshieldpowerbomb_alt_bc.bctex") },
                    "texAttributes": { "filepath": SMOOTH_NORMALS },
                    "texNormals": { "filepath": SMOOTH_NORMALS }
                }
            )
        ],
    ),
}

class BaseShield:
    def __init__(self, shield: ShieldData):
        self.data = shield

    def patch_model_data(self, new_template: dict, editor: PatcherEditor, version: str):
        # select the default or alternate model
        if version == "DEFAULT" or self.data.alternate_mdl is None:
            model = self.data.default_mdl
        else:
            model = self.data.alternate_mdl

        create_custom_model(editor, model)
        new_template["property"]["model_name"] = model.new_path
        model_updater = new_template["property"]["components"]["MODELUPDATER"]
        model_updater["functions"][0]["params"]["Param1"]["value"] = model.new_path

    def patch_material_data(self, editor: PatcherEditor, version: str):
        if version == "DEFAULT":
            for mat_dat in self.data.default_mats:
                create_custom_material(editor, mat_dat)

        else:
            for mat_dat in self.data.alternate_mats:
                create_custom_material(editor, mat_dat)
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
        if self.data.collision is None:
            return

        coll_comp = new_template["property"]["components"]["COLLISION"]
        coll_comp["dependencies"]["file"] = self.data.collision

    def patch(self, editor: PatcherEditor, version: str = "DEFAULT"):
        template_bmsad = _template_read_shield(self.data.type.value)

        new_template = copy.deepcopy(template_bmsad)
        new_template["name"] = self.data.name

        self.patch_model_data(new_template, editor, version)
        self.patch_material_data(editor, version)

        for w in self.data.weaknesses:
            self.add_weakness(w, new_template)

        self.change_collision(new_template)

        editor.add_new_asset(self.data.actordef, Bmsad(new_template, editor.target_game), [])

def create_all_shield_assets(editor: PatcherEditor, shield_model_config: dict[str, str]):
    for shield_name, shield_type in shield_model_config.items():
        BaseShield(ALL_SHIELD_DATA.get(shield_name)).patch(editor, shield_type)
