import re
from pathlib import Path

from mercury_engine_data_structures.file_tree_editor import FileTreeEditor


def _templates() -> Path:
    return Path(__file__).parent.joinpath("templates")


def _files() -> Path:
    return Path(__file__).parent.joinpath("files")


def replace_lua_template(file: str, replacement: dict[str, str]) -> str:
    code = _templates().joinpath(file).read_text()
    for key, content in replacement.items():
        code = code.replace(f'TEMPLATE("{key}")', lua_convert(content))

    unknown_templates = re.findall(r'TEMPLATE\("([^"]+)"\)', code)

    if unknown_templates:
        raise ValueError("The following templates were left unfulfilled: " + str(unknown_templates))

    return code


def lua_convert(data) -> str:
    if isinstance(data, list):
        return "{\n" + "\n".join(
            "{},".format(lua_convert(item))
            for item in data
        ) + "\n}"
    if isinstance(data, dict):
        return "{\n" + "\n".join(
            "{} = {},".format(key, lua_convert(value))
            for key, value in data.items()
        ) + "\n}"
    if isinstance(data, bool):
        return "true" if data else "false"
    return str(data)


def wrap_string(data: str) -> str:
    return f'"{data}"'


def create_script_copy(editor: FileTreeEditor, path: str):
    original = path + "_original.lc"
    if not editor.does_asset_exists(original):
        original_lc = editor.get_raw_asset(path + ".lc")
        editor.add_new_asset(
            original,
            original_lc,
            editor.find_pkgs(path + ".lc")
        )


def replace_script(editor: FileTreeEditor, path: str, replacement_path: str):
    create_script_copy(editor, path)
    editor.replace_asset(path + ".lc", _files().joinpath(replacement_path).read_bytes())
