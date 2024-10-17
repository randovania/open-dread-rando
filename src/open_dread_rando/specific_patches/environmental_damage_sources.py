import itertools

_ARTARIA_HEAT_ROOM_ACTORS = [
    {
        "scenario": "s010_cave",
        "actor": "env_heat_gen_001_001"
    },
    {
        "scenario": "s010_cave",
        "actor": "env_heat_gen_001_002"
    },
    {
        "scenario": "s010_cave",
        "actor": "env_heat_gen_001_003"
    },
    {
        "scenario": "s010_cave",
        "actor": "env_heat_gen_001_004"
    },
    {
        "scenario": "s010_cave",
        "actor": "env_heat_gen_001_CR_001"
    },
    {
        "scenario": "s010_cave",
        "actor": "env_heat_gen_001_CR_002"
    },
    {
        "scenario": "s010_cave",
        "actor": "env_heat_gen_001_CR_003"
    },
    {
        "scenario": "s010_cave",
        "actor": "env_heat_gen_001_CR_004"
    },
    {
        "scenario": "s010_cave",
        "actor": "env_heat_gen_001_CR_005"
    },
    {
        "scenario": "s010_cave",
        "actor": "env_heat_gen_001_CR_END"
    }
]

_ARTARIA_COLD_ROOM_ACTORS = [
    {
        "scenario": "s010_cave",
        "actor": "env_frozen_gen_001_000"
    },
    {
        "scenario": "s010_cave",
        "actor": "env_frozen_gen_001_001"
    },
    {
        "scenario": "s010_cave",
        "actor": "env_frozen_gen_001_002"
    },
]

_ARTARIA_LAVA_ACTORS = [
    {
        "scenario": "s010_cave",
        "actor": "lavazone_001"
    },
    {
        "scenario": "s010_cave",
        "actor": "lavazone_002"
    },
    {
        "scenario": "s010_cave",
        "actor": "lavazone_003"
    },
]

_CATARIS_HEAT_ROOM_ACTORS = [
    {
        "scenario": "s020_magma",
        "actor": "env_heat_gen_001"
    },
    {
        "scenario": "s020_magma",
        "actor": "env_heat_gen_002"
    },
    {
        "scenario": "s020_magma",
        "actor": "env_heat_gen_003"
    },
    {
        "scenario": "s020_magma",
        "actor": "env_heat_gen_004"
    },
    {
        "scenario": "s020_magma",
        "actor": "env_heat_gen_005"
    },
    {
        "scenario": "s020_magma",
        "actor": "env_heat_gen_006"
    },
    {
        "scenario": "s020_magma",
        "actor": "env_heat_gen_007"
    },
]

_CATARIS_LAVA_ACTORS = [
    {
        "scenario": "s020_magma",
        "actor": "lavazone"
    },
    {
        "scenario": "s020_magma",
        "actor": "lavazone_000"
    },
    {
        "scenario": "s020_magma",
        "actor": "lavazone_001"
    },
    {
        "scenario": "s020_magma",
        "actor": "lavazone_002"
    },
    {
        "scenario": "s020_magma",
        "actor": "lavazone_003"
    },
    {
        "scenario": "s020_magma",
        "actor": "lavazone_004"
    },
    {
        "scenario": "s020_magma",
        "actor": "lavazone_005"
    },
    {
        "scenario": "s020_magma",
        "actor": "lavazone_006"
    },
    {
        "scenario": "s020_magma",
        "actor": "lavazone_007"
    },
    {
        "scenario": "s020_magma",
        "actor": "lavazone_008"
    },
    {

        "scenario": "s020_magma",
        "actor": "lavazone_009"
    },
    {
        "scenario": "s020_magma",
        "actor": "lavazone_010"
    },
    {
        "scenario": "s020_magma",
        "actor": "lavazone_011"
    },
    {
        "scenario": "s020_magma",
        "actor": "lavazone_012"
    },
    {
        "scenario": "s020_magma",
        "actor": "lavazone_013"
    },
    {
        "scenario": "s020_magma",
        "actor": "lavazone_014"
    },
    {
        "scenario": "s020_magma",
        "actor": "lavazone_015"
    },
]

_DAIRON_HEAT_ROOM_ACTORS = [
    {
        "scenario": "s030_baselab",
        "actor": "env_heat_gen_001"
    }
]

_DAIRON_COLD_ROOM_ACTORS = [
    {
        "scenario": "s030_baselab",
        "actor": "env_frozen_gen_001"
    }
]

_DAIRON_LAVA_ACTORS = [
    {
        "scenario": "s030_baselab",
        "actor": "lavazone_000"
    },
    {
        "scenario": "s030_baselab",
        "actor": "lavazone_001"
    },
    {
        "scenario": "s030_baselab",
        "actor": "lavazone_002"
    }
]

_FERENIA_COLD_ROOM_ACTORS = [
    {
        "scenario": "s070_basesanc",
        "actor": "env_frozen_gen_000"
    },
    {
        "scenario": "s070_basesanc",
        "actor": "env_frozen_gen_001"
    }
]

ALL_DAMAGE_ROOM_ACTORS = list(itertools.chain(
    _ARTARIA_HEAT_ROOM_ACTORS,
    _ARTARIA_COLD_ROOM_ACTORS,
    _ARTARIA_LAVA_ACTORS,
    _CATARIS_HEAT_ROOM_ACTORS,
    _CATARIS_LAVA_ACTORS,
    _DAIRON_HEAT_ROOM_ACTORS,
    _DAIRON_COLD_ROOM_ACTORS,
    _DAIRON_LAVA_ACTORS,
    _FERENIA_COLD_ROOM_ACTORS,
))
