dofile("system/scripts/cc_to_room_name.lua")

RoomNameGui = RoomNameGui or {
    cameraDict = RANDO_CC_DICTIONARY,
	fadeTime = -1.0,
	fadeOutSFID = nil,
}

function RoomNameGui.GetRoomName(scenario, camera)
	local dict = RoomNameGui.cameraDict
	if dict == nil then
		Game.LogWarn(0, "No camera dict present!")
		return
	end

	local scenario_dict = dict[scenario]
	if scenario_dict == nil then
		Game.LogWarn(0, scenario .. " has nil dict!")
		return nil
	end

	local rando_name = scenario_dict[camera]
	return rando_name
end

function RoomNameGui.Init(time_to_fade)
	RoomNameGui.fadeTime = time_to_fade
    if RoomNameGui.ui then
        GUI.DestroyDisplayObject(RoomNameGui.ui)
    end

    local hud = GUI.GetDisplayObject("IngameMenuRoot.iconshudcomposition")
    local container = GUI.CreateDisplayObject(hud, "RoomNameGui", "CDisplayObjectContainer", {
        X = "0.025",
		Y = "0.925",
		ScaleX = "1.0",
		ScaleY = "1.0",
		Angle = "0.0",
		SizeX = "0.2",
		SizeY = "0.04",
		Enabled = true,
		Visible = true,
    })

    RoomNameGui.CreateBackgroundComposition(container)

    local label = GUI.CreateDisplayObject(container, "RoomNameGui_Label", "CText", {
		X = "0.0075",
		Y = "0.01",
		ScaleX = "1.0",
		ScaleY = "1.0",
		Angle = "0.0",
		SizeX = "0.2",
		SizeY = "0.04",
		FlipX = false,
		FlipY = false,
		ColorR = "1.0",
		ColorG = "1.0",
		ColorB = "1.0",
		ColorA = "1.0",
		Enabled = true,
		SkinItemType = "",
		TextString = "Room:",
		Font = "digital_small",
		TextAlignment = "Left",
		Autosize = true,
		Outline = true,
		EmbeddedSpritesSuffix = "",
		BlinkColorR = "1.00000",
		BlinkColorG = "1.00000",
		BlinkColorB = "1.00000",
		BlinkAlpha = "1.00000",
		Blink = "-1.00000"
	})

    RoomNameGui.ui = container
    RoomNameGui.label = label
	
	local current_cc = Game.GetCurrentSubAreaId()
	local current_scenario = RoomNameGui.ScenarioToName(Game.GetScenarioID())
	RoomNameGui.Update(current_scenario, current_cc)
end

function RoomNameGui.CreateBackgroundComposition(container)
	GUI.CreateDisplayObject(container, "Background", "CSprite", {
		X = "0.0",
		Y = "0.0",
		SizeX = "0.3",
		SizeY = "0.06",
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
		SizeX = "0.05",
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

function RoomNameGui.ScenarioToName(scenario)
	local dict = {
		s010_cave = "Artaria",
		s020_magma = "Cataris",
		s030_baselab = "Dairon",
		s040_aqua = "Burenia",
		s050_forest = "Ghavoran",
		s060_quarantine = "Elun",
		s070_basesanc = "Ferenia",
		s080_shipyard = "Hanubia",
		s090_skybase = "Itorash"
	}

	return dict[scenario]
end

-- updates the room name gui label
-- optional time_to_fade arg will set visibility to false after the time in seconds. -1 means it does not fade. 
function RoomNameGui.Update(scenario, new_cc, time_to_fade)
    local label = RoomNameGui.label

	if not label then
		Game.LogWarn(0, "No Label for RoomNameGui")
		return
	end
	
	if type(new_cc) ~= "string" then
		GUI.LogWarn(0, "collision camera is not string")
		return
	end
	
	local room_name = RoomNameGui.GetRoomName(scenario, new_cc)
	if room_name == nil then
		Game.LogWarn(0, string.format("Couldn't find name for %s/%s", scenario, new_cc))
		GUI.SetTextText(label, string.format("Room: %s", new_cc))
	else
		GUI.SetTextText(label, string.format("Room: %s", room_name))
	end
	
	RoomNameGui.SetUIVisibility(true)
	if RoomNameGui.fadeTime ~= -1 then
		if RoomNameGui.fadeOutSFID ~= nil then
			Game.DelSFById(RoomNameGui.fadeOutSFID)
		end
		RoomNameGui.fadeOutSFID = Game.AddGUISF(RoomNameGui.fadeTime, "RoomNameGui.FadeOut", "")
	end
end

function RoomNameGui.FadeOut()
	local ui = RoomNameGui.ui
	if not ui then
		Game.LogWarn(0, "No ui for RoomNameGui")
		return
	end

	-- TODO fade alpha by 0.00625 every frame 
	GUI.SetProperties(ui, {FadeColorR = "-1.0", FadeColorG = "-1.0", FadeColorB = "-1.0", FadeColorA = "0.0", FadeTime = "0.5"})
end