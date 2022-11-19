import pprint

from mercury_engine_data_structures.formats import Txt

from open_dread_rando.patcher_editor import PatcherEditor

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


def patch_text(editor: PatcherEditor, key: str, value: str):
    for text_file in ALL_TEXT_FILES:
        text = editor.get_file(f"system/localization/{text_file}", Txt)
        text.strings[key] = value


def get_text(editor: PatcherEditor, key: str, text_file: str = "us_english.txt") -> str:
    text = editor.get_file(f"system/localization/{text_file}", Txt)
    return text.strings[key]


def apply_text_patches(editor: PatcherEditor, patches: dict[str, str]):
    for k, v in patches.items():
        patch_text(editor, k, v)


def patch_hints(editor: PatcherEditor, hints: list[dict]):
    # patch mission log titles
    for lvl in {"AQUA", "CAVE", "MAGMA", "FOREST", "LAB", "SANC", "SHIP"}:
        mlog_key = f"MLOG_ADAM_{lvl}"
        original = get_text(editor, mlog_key)
        new = original.replace("Adam Briefing", "a hint")
        patch_text(editor, mlog_key, new)

    for hint in hints:
        ap_actor = editor.resolve_actor_reference(hint["accesspoint_actor"])
        usable = ap_actor.pComponents.USABLE

        # don't lock any doors
        usable.vDoorsToChange = []
        usable.wpThermalDevice = ""

        # update hint text
        hint_id = f"DIAG_ADAM_{hint['hint_id']}"
        string_key = f"{hint_id}_PAGE_1"

        usable.tCaptionList = {
            hint_id: [string_key]
        }
        patch_text(editor, string_key, hint["text"])


_PROJECT_MEMBERS = {
    "Project Leads": [
        "Henrique 'Darkszero' Gemignani",
        "duncathan_salt",
    ],
    "Game Patching": [
        "stuckpixel",
        "ScorelessPine",
        "Arcanox",
        "Migs",
        "hyperbola0",
    ],
    "Logic Database": [
        "KirbymastaH",
        "Dyceron",
        "XenoWars",
        "Izzychu",
        "Hugoshido",
    ],
    "Additional Art": [
        "BigSharksZ",
        "SkyTheLucario"
    ],
    "     ": [
        "With contributions from many others.",
    ]
}


def patch_credits(editor: PatcherEditor, spoiler_log: dict[str, str]):
    text = editor.get_file("system/localization/credits.txt", Txt)
    ordered_credits = list(text.strings.items())

    rando_credits = [
        ("Randomizer Credits", "_TITLE"),
    ]

    for group, group_members in _PROJECT_MEMBERS.items():
        rando_credits.append((group, "_SUBTITLE"))
        for member in group_members:
            rando_credits.append((member, ""))

    if spoiler_log:
        rando_credits.append(("     ", "_SUBTITLE"))
        rando_credits.append(("Major Item Locations", "_TITLE"))
        for item, loc in spoiler_log.items():
            rando_credits.append((item, "_SUBTITLE"))
            rando_credits.append((loc, ""))

    rando_credits.append(("     ", "_SUBTITLE"))

    ordered_credits[1:1] = [
        (f"CREDIT_R_{i:03}{prefix}", item)
        for i, (item, prefix) in enumerate(rando_credits)
    ]
    text.strings = {k: v for k, v in ordered_credits}
