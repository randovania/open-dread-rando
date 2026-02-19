import re
from typing import Any

from mercury_engine_data_structures.file_tree_editor import FileTreeEditor

from open_dread_rando.files import files_path, templates_path


def replace_lua_template(file: str, replacement: dict[str, Any], wrap_strings: bool = False) -> str:
    code = templates_path().joinpath(file).read_text()
    for key, content in replacement.items():
        # Replace `TEMPLATE("key")`-style replacements
        code = code.replace(f'TEMPLATE("{key}")', lua_convert(content, wrap_strings))
        # Replace `T__key__T`-style replacements
        code = code.replace(f"T__{key}__T", lua_convert(content, wrap_strings))

    unknown_templates = re.findall(r'TEMPLATE\("([^"]+)"\)', code)
    unknown_templates.extend(re.findall(r"T__(\w+)__T", code))

    if unknown_templates:
        raise ValueError("The following templates were left unfulfilled: " + str(unknown_templates))

    return code


def lua_convert(data, wrap_strings: bool = False) -> str:
    if isinstance(data, list):
        return "{\n" + "\n".join(f"{lua_convert(item, wrap_strings)}," for item in data) + "\n}"
    if isinstance(data, dict):
        return "{\n" + "\n".join(f"{key} = {lua_convert(value, wrap_strings)}," for key, value in data.items()) + "\n}"
    if isinstance(data, bool):
        return "true" if data else "false"
    if data is None:
        return "nil"
    if wrap_strings and isinstance(data, str):
        return wrap_string(data)
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
            editor.find_pkgs(path + ".lc"),
        )


def replace_script(editor: FileTreeEditor, path: str, replacement_path: str):
    create_script_copy(editor, path)
    editor.replace_asset(path + ".lc", files_path().joinpath(replacement_path).read_bytes())
