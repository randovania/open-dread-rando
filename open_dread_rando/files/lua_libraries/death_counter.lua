DeathCounter = DeathCounter or {
	didPatchOnPlayerDead = false,
	newPlayerDeathCount = nil,
}

function DeathCounter.Init()
	if DeathCounter.ui then
		DeathCounter.ui:Destroy()
		DeathCounter.ui = nil
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
	local ui = GUILib("DeathCounter", hud)
	local container = ui:AddContainer("Content", {
		X = 0.025,
		Y = 0.1975,
		SizeX = 0.2,
		SizeY = 0.04,
	})

	-- Create background
	container:AddSprite("Background", "HUD_TILESET/BACKGROUND", {
		SizeX = 0.1,
		SizeY = 0.04,
	})
	container:AddSprite("Frame_top", "HUD_TILESET/FRAME_TOP", {
		X = -0.0005,
		Y = -0.0005,
		SizeX = 0.05,
		SizeY = 0.015,
		ColorR = 0.8773584961891174,
		ColorG = 0.8773584961891174,
		ColorB = 0.8773584961891174,
	})

	local label = container:AddLabel("DeathCounter_Label", "Deaths: 0", {
		X = 0.0075,
		Y = 0.0,
		SizeX = 0.2,
		SizeY = 0.04,
		Font = "digital_small",
        Autosize = false,
	})

	DeathCounter.ui = ui
	DeathCounter.label = label
	DeathCounter.Update()
end

function DeathCounter.OnScenarioInitialized()
	-- If we store the new death count on "OnPlayerDead", it will get reset back to 0 when the player continues, because
	-- the Blackboard will be loaded from the last checkpoint. We have to store the new value into the Blackboard AFTER
	-- the player loads back to the checkpoint.
	if type(DeathCounter.newPlayerDeathCount) == "number" then
		Blackboard.SetProp("GAME", "Rando_PlayerDeathCount", "i", DeathCounter.newPlayerDeathCount)
		DeathCounter.newPlayerDeathCount = nil
	end
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

	if type(deathCount) ~= "number" then
		-- Official prop didn't exist (we're probably on 1.0.x), use our own stat
		deathCount = Blackboard.GetProp("GAME", "Rando_PlayerDeathCount") or 0
		Game.LogWarn(0, ("Got %s back from Rando_PlayerDeathCount"):format(tostring(deathCount)))
	end

	label:SetText("Deaths: " .. deathCount)
end