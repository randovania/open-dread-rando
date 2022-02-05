from pathlib import Path


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
