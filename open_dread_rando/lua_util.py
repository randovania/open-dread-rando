from pathlib import Path

from mercury_engine_data_structures.file_tree_editor import FileTreeEditor


def replace_lua_template(file: str, replacement: dict[str, str]) -> str:
    code = Path(__file__).parent.joinpath("templates", file).read_text()
    for key, content in replacement.items():
        code = code.replace(f'TEMPLATE("{key}")', lua_convert(content))
    return code


def lua_convert(data) -> str:
    if isinstance(data, list):
        return "{\n" + "\n".join(
            "{},".format(lua_convert(item))
            for item in data
        ) + "\n}"
    elif isinstance(data, dict):
        return "{\n" + "\n".join(
            "{} = {},".format(key, lua_convert(value))
            for key, value in data.items()
        ) + "\n}"
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
