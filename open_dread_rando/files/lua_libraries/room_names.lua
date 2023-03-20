RoomNameGui = RoomNameGui or {
    currentRoomName = nil,
    currentCollisionCamera = nil
}

function RoomNameGui.Init()
    if RoomNameGui.ui then
        GUI.DestroyDisplayObject(RoomNameGui.ui)
    end

    local hud = GUI.GetDisplayObject("IngameMenuRoot.iconshudcomposition")
    local container = GUI.CreateDisplayObject(hud, "RoomNameGui", "CDisplayObjectContainer", {
        X = "0.025",
		Y = "0.9",
		ScaleX = "1.0",
		ScaleY = "1.0",
		Angle = "0.0",
		SizeX = "0.2",
		SizeY = "0.04",
		Enabled = true,
		Visible = true,
    })

    RoomNameGui.CreateBackgroundComposition(container)

    local label = GUI.CreateDisplayObject(container, "RoomNameGui_Label", "CLabel", {
		X = "0.0075",
		Y = "0.0",
		ScaleX = "1.0",
		ScaleY = "1.0",
		Angle = "0.0",
		SizeX = "0.2",
		SizeY = "0.04",
		Enabled = true,
		Visible = true,
		Text = "Room: Unknown",
		Font = "digital_small",
		TextAlignment = "Left",
		TextVerticalAlignment = "Centered",
		Autosize = false,
		ColorR = "1.0",
		ColorG = "1.0",
		ColorB = "1.0",
		ColorA = "1.0",
	})

    RoomNameGui.ui = container
    RoomNameGui.label = label
	Game.AddGUISF(10, "RoomNameGui.Update", 's', "ASDF")
end

function RoomNameGui.CreateBackgroundComposition(container)
	GUI.CreateDisplayObject(container, "Background", "CSprite", {
		X = "0.0",
		Y = "0.0",
		SizeX = "0.2",
		SizeY = "0.04",
		Autosize = false,
		SpriteSheetItem = "HUD_TILESET/BACKGROUND",
		BlendMode = "AlphaBlend",
		USelMode = "Scale",
		VSelMode = "Scale",
		ColorR = "1.0",
		ColorG = "1.0",
		ColorB = "1.0",
		ColorA = "1.0",
	})

	GUI.CreateDisplayObject(container, "Frame_top", "CSprite", {
		X = "0.0",
		Y = "0.0",
		SizeX = "0.1",
		SizeY = "0.015",
		Autosize = false,
		SpriteSheetItem = "HUD_TILESET/FRAME_TOP",
		BlendMode = "AlphaBlend",
		USelMode = "Scale",
		VSelMode = "Scale",
		ColorR = "0.8773584961891174",
		ColorG = "0.8773584961891174",
		ColorB = "0.8773584961891174",
		ColorA = "1.0",
	})
end

function RoomNameGui.Update(new_cc)
    local label = RoomNameGui.label

	if not label then
		GUI.ShowMessage("WTF", true, "")
		return
	end
	
	if type(new_cc) ~= "string" then
		GUI.ShowMessage("Not String", true, "")
	end
	
	GUI.SetLabelText(label, "Room: " .. new_cc)
	GUI.ShowMessage("Should be \nRoom: " .. new_cc, true, "")
end