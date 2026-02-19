The files in this folder are here to act as the source of custom files in the `src/open_dread_rando/files/romfs` folder, when there may be data loss upon producing those files.

### Custom Textures

BCTEX files are stored as a DDS format with lossy compression. Constantly reopening and editing them will result in compression artifacts being
more and more visible each time, so a PNG of any custom textures should be kept here which can be edited and re-encoded to BCTEX as necessary.

### Custom Samus Menu

The "randosamuscomposition_with_dummy" file here should be used for the basis of any changes made to the "files/romfs/gui/scripts/randosamuscomposition.bmscp" file.
That file has a copy of the actual Samus Menu stored in the "DummyContainer" object, which can be used to position custom UI elements relative to the existing UI.

After you make changes to that file and save them, delete the "DummyContainer" object and then use "Save Copy As..." to save over the "files/romfs/gui/scripts/randosamuscomposition.bmscp" file.
This ensures that the file that is appended into the game does not contain a huge number of extra objects present.