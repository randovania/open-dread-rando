Game.ImportLibrary("system/scripts/utils.lua", false)

RandoSamusGui = RandoSamusGui or {}

local FAST_UPDATE_INTERVAL = 4 / 60 -- Every 4 frames at 60fps
local SLOW_UPDATE_INTERVAL = 30 / 60 -- Twice a second

RandoSamusGui.fUpdateInterval = SLOW_UPDATE_INTERVAL
RandoSamusGui.iCallbackId = -1
RandoSamusGui.customComposition = nil
RandoSamusGui.samusMenu = nil
RandoSamusGui.icons = {}
RandoSamusGui.labels = {}
RandoSamusGui.itemDetails = {
    beams = {
        background = nil,
        wideIcon = nil,
        plasmaIcon = nil,
    },
    missiles = {
        background = nil,
        supersIcon = nil,
    },
}

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

local function Exists(guiObj)
    return guiObj and type(guiObj.ForceRedraw) == "function"
end

local function numtostr(num)
    return string.format("%0.3f", num)
end

function RandoSamusGui.Init()
    Game.LogWarn(0, "RandoSamusGui.Init")
    RandoSamusGui.samusMenu = nil

    if RandoSamusGui.customComposition then
        GUI.DestroyDisplayObject(RandoSamusGui.customComposition)
        RandoSamusGui.customComposition = nil
    end

    if RandoSamusGui.iCallbackId >= 0 then
        -- Prevent duplicate callbacks if script is somehow initialized multiple times
        Game.DelSFByID(RandoSamusGui.iCallbackId)
        RandoSamusGui.iCallbackId = -1
    end

    -- The Samus UI isn't always available (it's only accessible when open), so we have to update it
    -- using a timer. The Update function will try to find it, and update it as needed while it is open.
    RandoSamusGui.fUpdateInterval = SLOW_UPDATE_INTERVAL
    RandoSamusGui.iCallbackId = Game.AddGUISF(0, RandoSamusGui.UpdateTimer, "")
end

function RandoSamusGui.UpdateTimer()
    RandoSamusGui.Update()
    RandoSamusGui.iCallbackId = Game.AddGUISF(RandoSamusGui.fUpdateInterval, RandoSamusGui.UpdateTimer, "")
end

function RandoSamusGui.InitCustomContent(samusMenu)
    composition = GUI.CreateMSCPInstanceEx("randosamuscomposition")
    samusMenu:AddChild(composition)

    -- Get references to individual objects
    RandoSamusGui.icons = {
        composition:FindDescendant("RandoContent.Item1_Icon"),
        composition:FindDescendant("RandoContent.Item2_Icon"),
        composition:FindDescendant("RandoContent.Item3_Icon"),
    }
    RandoSamusGui.labels = {
        composition:FindDescendant("RandoContent.Item1_Label"),
        composition:FindDescendant("RandoContent.Item2_Label"),
        composition:FindDescendant("RandoContent.Item3_Label"),
    }

    -- Destroy old objects if they exist
    if RandoSamusGui.itemDetails.beams.wideIcon then
        GUI.DestroyDisplayObject(RandoSamusGui.itemDetails.beams.wideIcon)
    end
    if RandoSamusGui.itemDetails.beams.plasmaIcon then
        GUI.DestroyDisplayObject(RandoSamusGui.itemDetails.beams.plasmaIcon)
    end
    if RandoSamusGui.itemDetails.missiles.supersIcon then
        GUI.DestroyDisplayObject(RandoSamusGui.itemDetails.missiles.supersIcon)
    end

    -- Create custom indicators for beam type
    local beamCategory = samusMenu:FindDescendant("Content.INVCAT_BEAMS")
    local beamCategoryBg = beamCategory:FindChild("Background")

    RandoSamusGui.itemDetails.beams.background = beamCategoryBg
    RandoSamusGui.itemDetails.beams.wideIcon = AddSprite(beamCategory, "WideIcon", {
        RightX = 0.03112499,
        Y = 0.01666666,
        SizeX = (32 / 1600),
        SizeY = (32 / 900),
        SpriteSheetItem = "HUD_TILESET/WIDE_BEAM",
    })
    RandoSamusGui.itemDetails.beams.plasmaIcon = AddSprite(beamCategory, "PlasmaIcon", {
        RightX = 0.05362497,
        Y = 0.01666666,
        SizeX = (32 / 1600),
        SizeY = (32 / 900),
        SpriteSheetItem = "HUD_TILESET/PLASMA_BEAM",
    })

    -- Create custom indicator for missile type
    local missileCategory = samusMenu:FindDescendant("Content.INVCAT_MISSILE")
    local missileCategoryBg = missileCategory:FindChild("Background")

    RandoSamusGui.itemDetails.missiles.background = missileCategoryBg
    RandoSamusGui.itemDetails.missiles.supersIcon = AddSprite(missileCategory, "SupersIcon", {
        RightX = 0.03112499,
        Y = 0.01111111,
        SizeX = (32 / 1600),
        SizeY = (32 / 900),
        SpriteSheetItem = "HUD_TILESET/SUPER_MISSILE",
    })

    return composition
end

function RandoSamusGui.Update()
    local samusMenu = RandoSamusGui.samusMenu

    if not samusMenu then
        -- Try to find it
        samusMenu = GUI.GetDisplayObject("IngameMenuRoot.samusmenucomposition")

        if not samusMenu then
            -- Not open right now
            return
        end

        RandoSamusGui.samusMenu = samusMenu

        -- Finding the menu before we have a handle to it can be slow.
        -- Once we have a handle, we can increase our update interval, and selectively not update if the menu is closed.
        RandoSamusGui.fUpdateInterval = FAST_UPDATE_INTERVAL
    end

    local customComposition = RandoSamusGui.customComposition

    -- FindChild seems to return some non-nil object representing "not found", so we also need
    -- to test if it's really our composition by looking for the "FindDescendant" function
    if not customComposition or not customComposition.FindDescendant then
        if RandoSamusGui.customComposition then
            GUI.DestroyDisplayObject(RandoSamusGui.customComposition)
        end

        customComposition = RandoSamusGui.InitCustomContent(samusMenu)
        RandoSamusGui.customComposition = customComposition
    end

    local samusMenuOpen = samusMenu:_Enabled_GetterFunction()

    if samusMenuOpen then
        RandoSamusGui.UpdateResourceCounts()
        RandoSamusGui.UpdatePowerupIcons()
    end
end

function RandoSamusGui.UpdateResourceCounts()
    -- Resource icons/labels are populated left-to-right as resources become relevant
    local icons = RandoSamusGui.icons
    local labels = RandoSamusGui.labels
    local nextIcon = 1
    local nextLabel = 1

    -- Hide everything at first, and reset label colors
    for _, icon in ipairs(icons) do
        GUI.SetProperties(icon, { Visible = false })
    end
    for _, label in ipairs(labels) do
        GUI.SetProperties(label, { Visible = false, ColorR = "1.0", ColorG = "1.0", ColorB = "1.0" })
    end

    -- DNA
    local hasRequiredDna = Init.iNumRequiredArtifacts > 0
    local currentDnaCount = 0

    if hasRequiredDna then
        for i = 1, Init.iNumRequiredArtifacts do
            if RandomizerPowerup.GetItemAmount("ITEM_RANDO_ARTIFACT_" .. i) > 0 then
                currentDnaCount = currentDnaCount + 1
            end
        end

        local icon = icons[nextIcon]
        local label = labels[nextLabel]

        if Exists(icon) and Exists(label) then
            local countText = ("%d / %d"):format(currentDnaCount, Init.iNumRequiredArtifacts)
            local haveAllDna = currentDnaCount >= Init.iNumRequiredArtifacts

            GUI.SetProperties(icon, { Visible = true, SpriteSheetItem = "HUD_TILESET/DNA" })
            GUI.SetProperties(label, {
                Visible = true,
                -- Text is light red when all DNA are acquired
                ColorR = "1.0",
                ColorG = haveAllDna and "0.5" or "1.0",
                ColorB = haveAllDna and "0.5" or "1.0",
            })
            GUI.SetLabelText(label, countText)
            label:ForceRedraw()
        end

        nextIcon = nextIcon + 1
        nextLabel = nextLabel + 1
    end

    -- Flash Shift upgrades
    local hasFlashShift = RandomizerPowerup.GetItemAmount("ITEM_GHOST_AURA") > 0
    local flashUpgradeCount = RandomizerPowerup.GetItemAmount("ITEM_UPGRADE_FLASH_SHIFT_CHAIN")

    if Init.bHasFlashUpgrades and (hasFlashShift or flashUpgradeCount > 0) then
        -- The flash shift upgrade icon is shown if the player has collected any, OR if they have flash shift itself
        local icon = icons[nextIcon]
        local label = labels[nextLabel]

        if Exists(icon) and Exists(label) then
            local countText = tostring(flashUpgradeCount + 1) -- Add 1 because of "base" chain that is free with Flash Shift

            GUI.SetProperties(icon, { Visible = true, SpriteSheetItem = "HUD_TILESET/FLASH_UPGRADE" })
            GUI.SetProperties(label, { Visible = true })
            GUI.SetLabelText(label, countText)
            label:ForceRedraw()
        end

        nextIcon = nextIcon + 1
        nextLabel = nextLabel + 1
    end

    -- Speed Booster upgrades
    local hasSpeedBooster = RandomizerPowerup.GetItemAmount("ITEM_SPEED_BOOSTER") > 0
    local speedUpgradeCount = RandomizerPowerup.GetItemAmount("ITEM_UPGRADE_SPEED_BOOST_CHARGE")

    if Init.bHasSpeedUpgrades and (hasSpeedBooster or speedUpgradeCount > 0) then
        -- The speed booster upgrade icon is shown if the player has collected any, OR if they have speed booster itself
        local icon = icons[nextIcon]
        local label = labels[nextLabel]

        if Exists(icon) and Exists(label) then
            -- The minimum charge time is technically 0.55 seconds due to a game quirk, but for the sake of simplicity,
            -- we just show proper increments of 0.25.
            local chargeTime = math.max(0.5, 1.5 - speedUpgradeCount * 0.25)
            -- %0.2g would yield 1.2 if given 1.25, because the precision of "g" is given in significant figures.
            -- %0.3g will give us 1.25 if given 1.25, while trimming 1.50 down to 1.5.
            local chargeTimeText = string.format("%0.3gs", chargeTime)

            GUI.SetProperties(icon, { Visible = true, SpriteSheetItem = "HUD_TILESET/SPEED_UPGRADE" })
            GUI.SetProperties(label, { Visible = true })
            GUI.SetLabelText(label, chargeTimeText)
            label:ForceRedraw()
        end

        nextIcon = nextIcon + 1
        nextLabel = nextLabel + 1
    end
end

function RandoSamusGui.UpdatePowerupIcons()
    -- Beams
    local beamCategoryBg = RandoSamusGui.itemDetails.beams.background
    local beamCategoryFocused = beamCategoryBg and beamCategoryBg:_ColorA_GetterFunction() > 0.5
    local beamCategoryAlphaMultiplier = beamCategoryFocused and 1.0 or 0.5
    local wideBeamIcon = RandoSamusGui.itemDetails.beams.wideIcon
    local plasmaBeamIcon = RandoSamusGui.itemDetails.beams.plasmaIcon
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
    local missileCategoryBg = RandoSamusGui.itemDetails.missiles.background
    local missileCategoryFocused = missileCategoryBg and missileCategoryBg:_ColorA_GetterFunction() > 0.5
    local missileCategoryAlphaMultiplier = missileCategoryFocused and 1.0 or 0.5
    local superMissileIcon = RandoSamusGui.itemDetails.missiles.supersIcon
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