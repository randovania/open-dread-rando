RoomNameGui = RoomNameGui or {
    cameraDict = nil,
	fadeTime = -1
}

function RoomNameGui.BuildCameraDict()
	if RoomNameGui.cameraDict ~= nil then
		Game.LogWarn(0, "Camera dict exists!")
		return
	end

	local artaria = {
		collision_camera_000 = "First Tutorial",
		collision_camera_000_Init = "Intro Room",
		collision_camera_001 = "Charge Tutorial",
		collision_camera_002 = "Melee Tutorial West",
		collision_camera_003 = "Melee Tutorial Room",
		collision_camera_004 = "Early Cloak Room",
		collision_camera_005 = "EMMI Zone First Entrance",
		collision_camera_006 = "White EMMI Introduction",
		collision_camera_008 = "Teleport to Dairon",
		collision_camera_009 = "EMMI Zone Exit North",
		collision_camera_010 = "EMMI Zone Hub",
		collision_camera_011 = "Teleport to Cataris",
		collision_camera_012 = "Save Station West",
		collision_camera_013 = "Charge Beam Access",
		collision_camera_014 = "Charge Beam Room",
		collision_camera_015 = "EMMI Zone Spinner",
		collision_camera_016 = "Proto EMMI Introduction",
		collision_camera_017 = "White EMMI Arena",
		collision_camera_018 = "EMMI Zone Entrance Hallway",
		collision_camera_020 = "Corpius Arena",
		collision_camera_021 = "David Jaffe Room",
		collision_camera_022 = "Thermal Door Tutorial",
		collision_camera_023 = "Magma Flow Vista",
		collision_camera_023_B = "East Lava Missile Room",
		collision_camera_024 = "Hot Room Hub",
		collision_camera_025 = "Save Station East",
		collision_camera_026 = "Chain Reaction Room",
		collision_camera_028 = "Varia Suit Tutorial South",
		collision_camera_029 = "Varia Suit Tutorial North",
		collision_camera_030 = "Shutter Platform Puzzle",
		collision_camera_031 = "Varia Suit Room",
		collision_camera_032 = "Spider Beam Tower",
		collision_camera_033 = "Grapple Beam Room",
		collision_camera_034 = "Transport to Dairon",
		collision_camera_045 = "First Tutorial Access",
		collision_camera_048 = "EMMI Zone Dome",
		collision_camera_049 = "Central Unit Access",
		collision_camera_050 = "Invisible Corpius Room",
		collision_camera_051 = "EMMI Zone Exit Northwest",
		collision_camera_053 = "EMMI Zone Ballspark Hallway",
		collision_camera_054 = "Energy Recharge Station South",
		collision_camera_055 = "Chain Reaction Access",
		collision_camera_056 = "Waterfall",
		collision_camera_057 = "Water Tunnel under Map",
		collision_camera_058 = "Map Station",
		collision_camera_059 = "Behind Waterfall",
		collision_camera_060 = "Water Reservoir",
		collision_camera_061 = "EMMI Zone Exit South",
		collision_camera_062 = "Cold Introduction",
		collision_camera_063 = "Save Station South",
		collision_camera_064 = "Proto EMMI Battle",
		collision_camera_065 = "Navigation Station North",
		collision_camera_066 = "Path to Thermal Device",
		collision_camera_067 = "Thermal Device",
		collision_camera_068 = "Navigation Station South",
		collision_camera_069 = "Wide Beam Block Room",
		collision_camera_070 = "Arbitrary Enky Room",
		collision_camera_071 = "EMMI First Chase End",
		collision_camera_072 = "Path to Corpius",
		collision_camera_073 = "Phantom Cloak Tutorial",
		collision_camera_074 = "Proto EMMI CU",
		collision_camera_075 = "EMMI Zone Exit Southwest",
		collision_camera_076 = "Save Station North",
		collision_camera_077 = "Transport to Cataris",
		collision_camera_078 = "Hot Cataris Shortcut",
		collision_camera_079 = "Lower Path to Cataris",
		collision_camera_080 = "Transport to Burenia",
		collision_camera_081 = "Screw Attack Room",
		collision_camera_082 = "Freezer",
		collision_camera_083 = "Speed Booster Bonus Room",
		collision_camera_085 = "Shortcut to Screw Attack",
		collision_camera_086 = "Speed Hallway",
		collision_camera_088 = "Shinespark Tower to Grapple",
		collision_camera_089 = "Grapple Beam Tutorial",
		collision_camera_090 = "Central Unit",
		collision_camera_091 = "Red Chozo Arena"
	}

	local burenia = {
		collision_camera_000 = "Map Station",
		collision_camera_001 = "Upper Burenia Hub",
		collision_camera_002 = "Burenia Hub to Dairon",
		collision_camera_003 = "Upper Transport to Dairon",
		collision_camera_004 = "Lower Transport to Dairon",
		collision_camera_005 = "Drogyga Eyedoor",
		collision_camera_006 = "Transport to Ghavoran",
		collision_camera_007 = "Underneath Drogyga",
		collision_camera_008 = "Teleport to Ferenia",
		collision_camera_009 = "Navigation Station North",
		collision_camera_010 = "Main Hub Tower",
		collision_camera_011 = "Save Station Middle",
		collision_camera_012 = "Underwater Horseshoe",
		collision_camera_013 = "Energy Recharge South",
		collision_camera_014 = "Flash Shift Room",
		collision_camera_015 = "Teleport to Ghavoran",
		collision_camera_016 = "Navigation Station South",
		collision_camera_017 = "Transport to Artaria",
		collision_camera_018 = "Early Gravity Speedboost Room 1",
		collision_camera_019 = "Early Gravity Speedboost Room 2",
		collision_camera_021 = "Gravity Suit Tower",
		collision_camera_022 = "Ammo Recharge South",
		collision_camera_023_B = "Gravity Suit Room",
		collision_camera_024 = "Gravity Suit Room Access",
		collision_camera_025 = "Storm Missile Gate Room",
		collision_camera_026 = "Save Station South Access",
		collision_camera_027 = "Save Station South",
		collision_camera_028 = "Drogyga Arena",
		collision_camera_029 = "Drogyga Access",
		collision_camera_030 = "Save Station North"
	}

	local cataris = {
		collision_camera_000 = "Transport to Artaria",
		collision_camera_001 = "Dropdown Pit",
		collision_camera_002 = "Navigation Station Southeast",
		collision_camera_004 = "Thermal Device Room South",
		collision_camera_006 = "Artaria Transport Access",
		collision_camera_007 = "Total Recharge Station South",
		collision_camera_009 = "Above Z-57 Fight",
		collision_camera_010 = "EMMI Zone Exit East",
		collision_camera_012 = "Lava Button East",
		collision_camera_013 = "Tall Magnet Walls Access",
		collision_camera_014 = "Moving Magnet Walls (Tall)",
		collision_camera_015 = "Teleport to Artaria (Blue)",
		collision_camera_016 = "Total Recharge Station North",
		collision_camera_018 = "Energy Recharge Station",
		collision_camera_019 = "Z-57 Heat Room West (Left)",
		collision_camera_020 = "Green EMMI Introduction",
		collision_camera_021 = "Z-57 Heat Room West (Right)",
		collision_camera_022 = "EMMI Zone Exit to Map Station",
		collision_camera_023 = "Long Mouth Statue Room",
		collision_camera_024 = "Above Kraid",
		collision_camera_025 = "Teleport to Artaria (Red)",
		collision_camera_026 = "Teleport to Ghavoran",
		collision_camera_027 = "Ghavoran Teleport Access",
		collision_camera_028 = "EMMI Zone Exits West",
		collision_camera_029 = "EMMI Zone Item Tunnel",
		collision_camera_030 = "Map Station",
		collision_camera_031 = "Moving Magnet Walls (Small)",
		collision_camera_032 = "EMMI Zone Tower East",
		collision_camera_033 = "Save Station East",
		collision_camera_034 = "Hall Thermal Device Room",
		collision_camera_035 = "EMMI Zone Tower West",
		collision_camera_036 = "Central Unit Access",
		collision_camera_037 = "Central Unit",
		collision_camera_038 = "Lava Button West",
		collision_camera_040 = "Dairon Transport Access",
		collision_camera_041 = "Transport to Dairon",
		collision_camera_042 = "Thermal Device Room North",
		collision_camera_043 = "Path to Kraid Entryway",
		collision_camera_044 = "Diffusion Beam Room",
		collision_camera_045 = "Lava Button East Access",
		collision_camera_046 = "EMMI Zone East Tower Access",
		collision_camera_048 = "Double Obsydomithon Room",
		collision_camera_049 = "Z-57 Heat Room East",
		collision_camera_051 = "Teleport to Dairon",
		collision_camera_052 = "Green EMMI Introduction Access",
		collision_camera_053 = "Underlava Puzzle Room 2",
		collision_camera_054 = "Underlava Puzzle Room 1",
		collision_camera_055 = "EMMI Zone Hidden Missile Room",
		collision_camera_058 = "Navigation Station Northwest",
		collision_camera_059 = "EMMI Zone West Exit Path",
		collision_camera_060 = "Heated U-Turn",
		collision_camera_061 = "Kraid Eyedoor Room",
		collision_camera_062 = "Save Station West",
		collision_camera_063 = "Kraid Arena",
		collision_camera_064 = "West Teleport Access",
		collision_camera_CooldownX = "Experiment Z-57 Fight?"
	}

	local dairon = {
		collision_camera_000 = "Save Station East",
		collision_camera_001 = "Teleport to Artaria",
		collision_camera_002 = "Hub Access",
		collision_camera_003 = "East Transport to Ferenia",
		collision_camera_004 = "Big Hub",
		collision_camera_005 = "EMMI Zone Exit East",
		collision_camera_006 = "Wide Beam Room",
		collision_camera_007 = "Power Switch 1",
		collision_camera_008 = "Teleport to Cataris",
		collision_camera_009 = "Total Recharge Station East",
		collision_camera_010 = "Early Grapple Access",
		collision_camera_011 = "Transport to Artaria",
		collision_camera_012 = "Early Grapple Room",
		collision_camera_013 = "Heated Room West",
		collision_camera_014 = "Navigation Station South",
		collision_camera_015 = "Energy Recharge Station Middle",
		collision_camera_016 = "Shinespark Tutorial",
		collision_camera_017 = "EMMI Zone Exit North",
		collision_camera_018 = "Yellow EMMI Introduction",
		collision_camera_019 = "West Transport to Ferenia",
		collision_camera_020 = "Cross Bomb Puzzle Room",
		collision_camera_021 = "Bomb Room",
		collision_camera_022 = "Total Recharge Station West",
		collision_camera_023 = "Map Station",
		collision_camera_024 = "Power Switch 2",
		collision_camera_025 = "Freezer",
		collision_camera_026 = "Test Chamber Access",
		collision_camera_027 = "EMMI Zone Exit Northwest",
		collision_camera_028 = "Experiment Z-57 Test Chamber",
		collision_camera_029 = "EMMI Zone Exit West",
		collision_camera_030 = "Hidden Grapple Shortcut Room",
		collision_camera_031 = "Save Station West Tunnels",
		collision_camera_032 = "Save Station West",
		collision_camera_033 = "Storm Missile Gate Room",
		collision_camera_034 = "Ammo Recharge Station",
		collision_camera_035 = "Lake Puzzle Room",
		collision_camera_036 = "EMMI Zone Exit Southwest",
		collision_camera_037 = "EMMI Zone Exit South",
		collision_camera_038 = "Central Unit",
		collision_camera_039 = "Burenia Upper Transport Access",
		collision_camera_040 = "Central Unit Access",
		collision_camera_041 = "Burenia Lower Transport Access",
		collision_camera_042 = "Energy Recharge Station West",
		collision_camera_043 = "Transport to Cataris",
		collision_camera_044 = "Navigation Station North",
		collision_camera_045 = "Lower Transport to Burenia",
		collision_camera_046 = "Upper Transport to Burenia",
		collision_camera_047 = "Transport to Ghavoran"
	}

	local elun = {
		collision_camera_000 = "Bridge Gate",
		collision_camera_001 = "Transport to Ghavoran",
		collision_camera_002 = "Purple Drapes",
		collision_camera_003 = "Ammo Recharge Station",
		collision_camera_004 = "Chozo Soldier Arena",
		collision_camera_005 = "Gyroscope Room",
		collision_camera_006 = "Plasma Beam Room",
		collision_camera_007 = "Spider Magnet Room",
		collision_camera_008 = "Fan Room",
		collision_camera_009 = "Vertical Bomb Maze",
		collision_camera_010 = "Horizontal Bomb Maze",
		collision_camera_011 = "Exterior Bridge",
		collision_camera_012 = "Save Station",
		collision_camera_MBL_B = "Bottom Morph Launcher"
	}

	local ferenia = {
		collision_camera_000 = "East Transport to Darion",
		collision_camera_001 = "Purple EMMI Introduction Access",
		collision_camera_002 = "Total Recharge Station",
		collision_camera_003 = "EMMI Zone Exit West",
		collision_camera_004 = "Fan Room Access",
		collision_camera_005 = "Quiet Robe Room",
		collision_camera_006 = "Fan Room",
		collision_camera_007 = "Teleport to Burenia (Cyan)",
		collision_camera_008 = "Transport to Dairon",
		collision_camera_009 = "Speedboost Slopes Maze",
		collision_camera_010 = "Cold Room (Small)",
		collision_camera_011 = "Separate Tunnels Room",
		collision_camera_012 = "Space Jump Room",
		collision_camera_013 = "Pitfall Puzzle Room",
		collision_camera_014 = "Transport to Ghavoran",
		collision_camera_015 = "Space Jump Room Access",
		collision_camera_016 = "Navigation Station",
		collision_camera_017 = "Twin Robot Arena",
		collision_camera_018 = "Cold Room (Energy Recharge Station)",
		collision_camera_019 = "Energy Recharge Station (Gate)",
		collision_camera_020 = "Energy Recharge Station Secret",
		collision_camera_021 = "EMMI Zone Exit Middle",
		collision_camera_022 = "Map Station Access",
		collision_camera_023 = "Map Station",
		collision_camera_024 = "Storm Missile Tutorial",
		collision_camera_025 = "Path to Escue",
		collision_camera_026 = "Escue Eyedoor Room",
		collision_camera_027 = "Escue Arena",
		collision_camera_028 = "Transport to Hanubia",
		collision_camera_029 = "Save Station North",
		collision_camera_030 = "Cold Room (Storm Missile Gate)",
		collision_camera_031 = "Wave Beam Tutorial",
		collision_camera_032 = "EMMI Zone Exit East",
		collision_camera_033 = "EMMI Zone Exit East Access",
		collision_camera_034 = "Purple EMMI Arena",
		collision_camera_035 = "Central Unit",
		collision_camera_038_A = "Central Unit Access",
		collision_camera_040 = "Purple EMMI Introduction",
		collision_camera_041 = "Save Station Southeast"
	}

	local ghavoran = {
		collision_camera_000 = "Transport to Burenia",
		collision_camera_001 = "Right Entrance",
		collision_camera_002 = "Robot Fight Arena",
		collision_camera_003 = "Left Entrance",
		collision_camera_004 = "Blue EMMI Introduction",
		collision_camera_005 = "Navigation Station Access",
		collision_camera_006 = "Navigation Station",
		collision_camera_007 = "Flipper Room",
		collision_camera_008 = "Dairon Transport Access",
		collision_camera_009 = "Super Missile Room Access",
		collision_camera_010 = "Super Missile Room",
		collision_camera_011 = "EMMI Zone Exit Southeast",
		collision_camera_012 = "Map Station Access",
		collision_camera_013 = "Map Station",
		collision_camera_014 = "EMMI Zone Exit West",
		collision_camera_015 = "Early Ice Room",
		collision_camera_016 = "EMMI Zone Exit Northwest",
		collision_camera_017 = "Central Unit",
		collision_camera_018 = "EMMI Zone Middle Path",
		collision_camera_019 = "Central Unit Access",
		collision_camera_020 = "EMMI Zone Exit Northeast",
		collision_camera_021 = "Spin Boost Tower",
		collision_camera_022 = "Save Station Center",
		collision_camera_023 = "Chozo Warrior Arena",
		collision_camera_024 = "Golzuna Tower",
		collision_camera_025_B = "Total Recharge Station North",
		collision_camera_026 = "Golzuna Arena",
		collision_camera_027 = "Transport to Ferenia",
		collision_camera_028 = "Map Station Access Secret",
		collision_camera_029 = "Elun Transport Access",
		collision_camera_030 = "Spin Boost Room",
		collision_camera_031 = "Energy Recharge Station",
		collision_camera_032 = "Pulse Radar Room",
		collision_camera_033 = "Cross Bomb Tutorial",
		collision_camera_034 = "Transport to Hanubia",
		collision_camera_035 = "Spider Magnet Elevator",
		collision_camera_036 = "Above Golzuna",
		collision_camera_037 = "Transport to Elun",
		collision_camera_038 = "Transport to Dairon",
		collision_camera_039 = "Above Pulse Radar",
		collision_camera_040 = "Save Station East"
	}

	local hanubia = {
		collision_camera_000 = "Transport to Ferenia",
		collision_camera_001 = "Transport to Ghavoran",
		collision_camera_002 = "Ferenia Shortcut",
		collision_camera_003 = "Navigation Station",
		collision_camera_004 = "Entrance Tall Room",
		collision_camera_005 = "Gold Chozo Warrior Arena",
		collision_camera_006 = "Total Recharge Station North",
		collision_camera_007 = "Transport to Itorash",
		collision_camera_008 = "Ship Room",
		collision_camera_009 = "Speedboost Puzzle Room",
		collision_camera_010 = "Tank Room",
		collision_camera_011 = "EMMI Zone Exit West",
		collision_camera_012 = "Central Unit",
		collision_camera_013 = "EMMI Zone Exit East",
		collision_camera_014 = "Orange EMMI Introduction",
		collision_camera_015 = "Total Recharge Station East",
		collision_camera_016 = "Escape Room 3",
		collision_camera_018 = "Escape Room 2",
		collision_camera_019 = "Escape Room 1",
		collision_camera_020 = "Raven Beak X Arena",
		collision_camera_1000 = "collision_camera_1000 (H)"
	}

	local itorash = {
		collision_camera_000 = "Save Station",
		collision_camera_001 = "Transport to Hanubia",
		collision_camera_002 = "Elevator to Raven Beak",
		collision_camera_003 = "Elevator Cutscene",
		collision_camera_004 = "Raven Beak Arena"
	}

	local full_dict = {
		["Artaria"] = artaria,
		["Burenia"] = burenia,
		["Cataris"] = cataris,
		["Dairon"] = dairon,
		["Elun"] = elun,
		["Ferenia"] = ferenia,
		["Ghavoran"] = ghavoran,
		["Hanubia"] = hanubia,
		["Itorash"] = itorash
	}

	RoomNameGui.cameraDict = full_dict
end

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
		Game.AddGUISF(RoomNameGui.fadeTime, "RoomNameGui.SetUIVisibility", 'b', false)
	end
end

function RoomNameGui.FadeUIVisibility(alpha)
	local ui = RoomNameGui.ui
	if not ui then
		Game.LogWarn(0, "No ui for RoomNameGui")
		return
	end

	-- TODO fade alpha by 0.00625 every frame 
	alpha = alpha - 0.00625
	if alpha > 0 then
		Game.AddGUISF(0.016, "RoomNameGui.FadeUIVisibility", 'f', alpha)
	end
end