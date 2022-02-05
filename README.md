# Open Dread Rando
Open Source randomizer patcher for Metroid Dread. Intended for use in [Randovania](https://github.com/randovania).
Currently supports patching item pickups, starting items, and elevator/shuttle/teleportal destinations.

## Installation
`pip install open-dread-rando`

## Usage
You will need to provide JSON data matching the [JSON schema](https://github.com/randovania/open-dread-rando/blob/main/open_dread_rando/files/schema.json) in order to successfully patch the game. 

The patcher expects a path to an extracted romfs directory of Metroid Dread 1.0.0 as well as the desired output directory. Output files are in the Atmosphere format and should be compatible with Ryujinx and Yuzu.

With a JSON file:
`python -m open-dread-rando --input-path ~/dread/romfs --output-path ~/your-ryujinx-mod-folder/rando --input-json ~/dreadrando/patcher.json`

From stdin:
`python -m open-dread-rando --input-path ~/dread/romfs --output-path ~/your-ryujinx-mod-folder/rando`