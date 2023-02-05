DeathCounter = DeathCounter or {
	didPatchOnPlayerDead = false,
	newPlayerDeathCount = nil,
}

function DeathCounter.Init()
	if DeathCounter.ui then
		GUI.DestroyDisplayObject(DeathCounter.ui)
	end

	if not DeathCounter.didPatchOnPlayerDead then
		-- Patch the "DamagePlants.OnPlayerDeath" function, which is unused in Dread, to detect when the player has died
		local original_OnPlayerDead = DamagePlants.OnPlayerDead

		DamagePlants.OnPlayerDead = function(...)
			original_OnPlayerDead(...)

			local deathCount = Blackboard.GetProp("GAME", "Rando_PlayerDeathCount") or 0

			DeathCounter.newPlayerDeathCount = deathCount + 1
		end

		DeathCounter.didPatchOnPlayerDead = true
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
end

function DeathCounter.OnScenarioInitialized()
	-- If we store the new death count on "OnPlayerDead", it will get reset back to 0 when the player continues, because
	-- the Blackboard will be loaded from the last checkpoint. We have to store the new value into the Blackboard AFTER
	-- the player loads back to the checkpoint.
	if type(DeathCounter.newPlayerDeathCount) == "number" then
		Game.LogWarn(0, ("Storing %d to Rando_PlayerDeathCount"):format(DeathCounter.newPlayerDeathCount))
		Blackboard.SetProp("GAME", "Rando_PlayerDeathCount", "i", DeathCounter.newPlayerDeathCount)
		DeathCounter.newPlayerDeathCount = nil
	end
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

	-- Try to use official BB property if present (2.0.0+). The official stat is guaranteed to match the end screen,
	-- so in case our custom property somehow gets out of sync, the HUD will still show the correct count on newer
	-- game versions.
	local deathCount = Blackboard.GetProp("GAME", "ProgressStat_PlayerDeaths")

	Game.LogWarn(0, ("deathCount: %s = %s"):format(type(deathCount), tostring(deathCount)))

	if type(deathCount) ~= "number" then
		-- Official prop didn't exist (we're probably on 1.0.x), use our own stat
		deathCount = Blackboard.GetProp("GAME", "Rando_PlayerDeathCount") or 0
		Game.LogWarn(0, ("Got %s back from Rando_PlayerDeathCount"):format(tostring(deathCount)))
	end

	GUI.SetLabelText(label, "Deaths: " .. deathCount)
end