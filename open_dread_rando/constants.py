from enum import Enum
# constant data, including "magic numbers" and common data that many modules use

# list of all scenarios
ALL_SCENARIOS = [
    "s010_cave", "s020_magma", 
    "s030_baselab",
    "s040_aqua",
    "s050_forest",
    "s060_quarantine",
    "s070_basesanc",
    "s080_shipyard",
    "s090_skybase"
]

# fade in/out values (in seconds) for room name GUI
class FadeTimes(Enum):
    NO_FADE = -1
    ROOM_FADE = 3