RandoSamusGui = RandoSamusGui or {}

function RandoSamusGui.Update()
    -- Find the objects
    local samusMenu = GUI.GetDisplayObject("IngameMenuRoot.samusmenucomposition")

    if not samusMenu then
        -- Not open right now
        return
    end

    local composition = samusMenu:FindChild("randosamuscomposition")

    -- FindChild seems to return some non-nil object representing "not found", so we also need
    -- to test if it's really our composition by looking for the "FindDescendant" function
    if not composition or not composition.FindDescendant then
        composition = GUI.CreateMSCPInstanceEx("randosamuscomposition")
        samusMenu:AddChild(composition)
    end

    local upgrade1Icon = composition:FindDescendant("RandoContent.Upgrade1_Icon")
    local upgrade1Label = composition:FindDescendant("RandoContent.Upgrade1_Label")
    local upgrade2Icon = composition:FindDescendant("RandoContent.Upgrade2_Icon")
    local upgrade2Label = composition:FindDescendant("RandoContent.Upgrade2_Label")

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
