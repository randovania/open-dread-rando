Game.ImportLibrary("system/scripts/utils.lua", false)

RandoSamusGui = RandoSamusGui or {}

RandoSamusGui.fUpdateInterval = 4 / 60 -- Every 4 frames = 15 FPS

local function AddSprite(parent, name, properties)
    local sprite = GUI.CreateDisplayObjectEx(name, "CSprite", utils.Merge({
        Enabled = true,
        Visible = true,
        Autosize = false,
        ScaleX = 1,
        ScaleY = 1,
        Angle = 0,
        FlipX = false,
        FlipY = false,
		BlendMode = "AlphaBlend",
        USelMode = "Scale",
        VSelMode = "Scale",
    }, properties or {}))

    parent:AddChild(sprite)

    return sprite
end

function RandoSamusGui.Init()
    -- The Samus UI isn't always available (it's only accessible when open), so we have to update it
    -- using a timer. The Update function will try to find it, and update it as needed while it is open.
    Game.AddGUISF(0, RandoSamusGui.UpdateTimer, "")
end

function RandoSamusGui.UpdateTimer()
    RandoSamusGui.Update()
    Game.AddGUISF(RandoSamusGui.fUpdateInterval, RandoSamusGui.UpdateTimer, "")
end

function RandoSamusGui.InitCustomContent(samusMenu)
    composition = GUI.CreateMSCPInstanceEx("randosamuscomposition")
    samusMenu:AddChild(composition)

    -- Create custom indicators for beam type
    local beamCategory = samusMenu:FindDescendant("Content.INVCAT_BEAMS")

    AddSprite(beamCategory, "WideIcon", {
        RightX = 0.03112499,
        Y = 0.01666666,
        SizeX = (32 / 1600),
        SizeY = (32 / 900),
        SpriteSheetItem = "HUD_TILESET/WIDE_BEAM",
    })
    AddSprite(beamCategory, "PlasmaIcon", {
        RightX = 0.05362497,
        Y = 0.01666666,
        SizeX = (32 / 1600),
        SizeY = (32 / 900),
        SpriteSheetItem = "HUD_TILESET/PLASMA_BEAM",
    })

    -- Create custom indicator for missile type
    local missileCategory = samusMenu:FindDescendant("Content.INVCAT_MISSILE")

    AddSprite(missileCategory, "SupersIcon", {
        RightX = 0.03112499,
        Y = 0.01111111,
        SizeX = (32 / 1600),
        SizeY = (32 / 900),
        SpriteSheetItem = "HUD_TILESET/SUPER_MISSILE",
    })

    return composition
end

function RandoSamusGui.Update()
    -- Find the objects
    local samusMenu = GUI.GetDisplayObject("IngameMenuRoot.samusmenucomposition")

    if not samusMenu then
        -- Not open right now
        return
    end

    local customComposition = samusMenu:FindChild("randosamuscomposition")

    -- FindChild seems to return some non-nil object representing "not found", so we also need
    -- to test if it's really our composition by looking for the "FindDescendant" function
    if not customComposition or not customComposition.FindDescendant then
        customComposition = RandoSamusGui.InitCustomContent(samusMenu)
    end

    local success, err = pcall(function()
        RandoSamusGui.UpdateTopItemCounts(customComposition)
        RandoSamusGui.UpdatePowerupIcons(samusMenu)
    end)

    if not success then
        Game.LogWarn(0, "Error: " .. tostring(err))
    end
end

function RandoSamusGui.UpdateTopItemCounts(customComposition)
    local upgrade1Icon = customComposition:FindDescendant("RandoContent.Upgrade1_Icon")
    local upgrade1Label = customComposition:FindDescendant("RandoContent.Upgrade1_Label")
    local upgrade2Icon = customComposition:FindDescendant("RandoContent.Upgrade2_Icon")
    local upgrade2Label = customComposition:FindDescendant("RandoContent.Upgrade2_Label")

    -- Update the state
    local nextIcon = upgrade1Icon
    local nextLabel = upgrade1Label

    -- Hide everything at first
    GUI.SetProperties(upgrade1Icon, { Visible = false })
    GUI.SetProperties(upgrade1Label, { Visible = false })
    GUI.SetProperties(upgrade2Icon, { Visible = false })
    GUI.SetProperties(upgrade2Label, { Visible = false })

    -- Flash Shift upgrades
    local hasFlashShift = RandomizerPowerup.GetItemAmount("ITEM_GHOST_AURA") > 0
    local flashUpgradeCount = RandomizerPowerup.GetItemAmount("ITEM_UPGRADE_FLASH_SHIFT_CHAIN")

    if hasFlashShift or flashUpgradeCount > 0 then
        -- The flash shift upgrade icon is shown if the player has collected any, OR if they have flash shift itself

        if nextIcon and nextLabel then
            GUI.SetProperties(nextIcon, { Visible = true, SpriteSheetItem = "HUD_TILESET/FLASH_UPGRADE" })
            GUI.SetProperties(nextLabel, { Visible = true })
            GUI.SetLabelText(nextLabel, tostring(flashUpgradeCount))
            nextLabel:ForceRedraw()
        end

        nextIcon = upgrade2Icon
        nextLabel = upgrade2Label
    end

    -- Speed Booster upgrades
    local hasSpeedBooster = RandomizerPowerup.GetItemAmount("ITEM_SPEED_BOOSTER") > 0
    local speedUpgradeCount = RandomizerPowerup.GetItemAmount("ITEM_UPGRADE_SPEED_BOOST_CHARGE")

    if hasSpeedBooster or speedUpgradeCount > 0 then
        -- The speed booster upgrade icon is shown if the player has collected any, OR if they have speed booster itself

        if nextIcon and nextLabel then
            GUI.SetProperties(nextIcon, { Visible = true, SpriteSheetItem = "HUD_TILESET/SPEED_UPGRADE" })
            GUI.SetProperties(nextLabel, { Visible = true })
            GUI.SetLabelText(nextLabel, tostring(speedUpgradeCount))
            nextLabel:ForceRedraw()
        end

        nextIcon = nil
        nextLabel = nil
    end
end

local function numtostr(num)
    return string.format("%0.3f", num)
end

function RandoSamusGui.UpdatePowerupIcons(samusMenu)
    -- Beams
    local beamCategory = samusMenu:FindDescendant("Content.INVCAT_BEAMS")
    local beamCategoryBg = beamCategory:FindChild("Background")
    local beamCategoryFocused = beamCategoryBg:_ColorA_GetterFunction() > 0.5
    local beamCategoryAlphaMultiplier = beamCategoryFocused and 1.0 or 0.5
    local wideBeamIcon = beamCategory:FindChild("WideIcon")
    local plasmaBeamIcon = beamCategory:FindChild("PlasmaIcon")
    local hasWideBeam = RandomizerPowerup.GetItemAmount("ITEM_WEAPON_WIDE_BEAM") > 0
    local hasPlasmaBeam = RandomizerPowerup.GetItemAmount("ITEM_WEAPON_PLASMA_BEAM") > 0
    local hasWaveBeam = RandomizerPowerup.GetItemAmount("ITEM_WEAPON_WAVE_BEAM") > 0

    -- Wide Beam icon is visible whenever the player has Plasma Beam or Wave Beam.
    -- The opacity is faded out when the user does not have Wide Beam.
    GUI.SetProperties(wideBeamIcon, {
        -- Despite being able to set this as a number in CreateDisplayObjectEx,
        -- we have to set it as a string here for some reason!
        ColorA = numtostr((hasWideBeam and 1 or 0.25) * beamCategoryAlphaMultiplier),
        -- Desaturate with RGB too
        ColorR = hasWideBeam and "1.0" or "0.5",
        ColorG = hasWideBeam and "1.0" or "0.5",
        ColorB = hasWideBeam and "1.0" or "0.5",
        Visible = hasPlasmaBeam or hasWaveBeam,
    })

    -- Plasma Beam icon is visible whenever the player has Wave Beam.
    -- The opacity is faded out when the user does not have Plasma Beam.
    GUI.SetProperties(plasmaBeamIcon, {
        ColorA = numtostr((hasPlasmaBeam and 1 or 0.25) * beamCategoryAlphaMultiplier),
        ColorR = hasPlasmaBeam and "1.0" or "0.5",
        ColorG = hasPlasmaBeam and "1.0" or "0.5",
        ColorB = hasPlasmaBeam and "1.0" or "0.5",
        Visible = hasWaveBeam,
    })

    -- Missiles
    local missileCategory = samusMenu:FindDescendant("Content.INVCAT_MISSILE")
    local missileCategoryBg = missileCategory:FindChild("Background")
    local missileCategoryFocused = missileCategoryBg:_ColorA_GetterFunction() > 0.5
    local missileCategoryAlphaMultiplier = missileCategoryFocused and 1.0 or 0.5
    local superMissileIcon = missileCategory:FindChild("SupersIcon")
    local hasSuperMissiles = RandomizerPowerup.GetItemAmount("ITEM_WEAPON_SUPER_MISSILE") > 0
    local hasIceMissiles = RandomizerPowerup.GetItemAmount("ITEM_WEAPON_ICE_MISSILE") > 0

    -- Super Missile icon is visible whenever the player has Ice Beam.
    -- The opacity is faded out when the user does not have Super Missile.
    GUI.SetProperties(superMissileIcon, {
        ColorA = numtostr((hasSuperMissiles and 1 or 0.25) * missileCategoryAlphaMultiplier),
        ColorR = hasSuperMissiles and "1.0" or "0.5",
        ColorG = hasSuperMissiles and "1.0" or "0.5",
        ColorB = hasSuperMissiles and "1.0" or "0.5",
        Visible = hasIceMissiles,
    })
end