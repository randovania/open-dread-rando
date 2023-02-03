DeathCounter = DeathCounter or {}

function DeathCounter.Create()
	if DeathCounter.ui then
		GUI.DestroyDisplayObject(DeathCounter.ui)
	end

	local hud = GUI.GetDisplayObject("IngameMenuRoot.iconshudcomposition")
	local container = GUI.CreateDisplayObject(hud, "DeathCounter", "CDisplayObjectContainer", {
		X = "0.025",
		Y = "0.1975",
		ScaleX = "1.0",
		ScaleY = "1.0",
		Angle = "0.0",
		SizeX = "0.2",
		SizeY = "0.04",
		Enabled = true,
		Visible = true,
	})

	DeathCounter.CreateBackgroundComposition(container)

	local label = GUI.CreateDisplayObject(container, "DeathCounter_Label", "CLabel", {
		X = "0.0075",
		Y = "0.0",
		ScaleX = "1.0",
		ScaleY = "1.0",
		Angle = "0.0",
		SizeX = "0.2",
		SizeY = "0.04",
		Enabled = true,
		Visible = true,
		Text = "Deaths: 0",
		Font = "digital_small",
		TextAlignment = "Left",
		TextVerticalAlignment = "Centered",
		Autosize = false,
		ColorR = "1.0",
		ColorG = "1.0",
		ColorB = "1.0",
		ColorA = "1.0",
	})

	DeathCounter.ui = container
	DeathCounter.label = label
	DeathCounter.Update()

	return container
end

function DeathCounter.CreateBackgroundComposition(container)
	GUI.CreateDisplayObject(container, "Background", "CSprite", {
		X = "0.0",
		Y = "0.0",
		SizeX = "0.1",
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

function DeathCounter.Update()
	local label = DeathCounter.label

	if not label then
		return
	end

	local deathCount = Blackboard.GetProp("GAME", "ProgressStat_PlayerDeaths") or 0

	GUI.SetLabelText(label, "Deaths: " .. deathCount)
end