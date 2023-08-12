Game.ImportLibrary("system/scripts/scenario_original.lua")

Game.DoFile("system/scripts/input_handling.lua")
Game.DoFile("system/scripts/data_structures.lua")
Game.DoFile("system/scripts/guilib.lua")
Game.DoFile("system/scripts/death_counter.lua")
Game.DoFile("system/scripts/room_names.lua")

Scenario.tRandoHintPropIDs = {
    CAVE_1 = Blackboard.RegisterLUAProp("HINT_CAVE_1", "bool"),
    CAVE_2 = Blackboard.RegisterLUAProp("HINT_CAVE_2", "bool"),
    MAGMA_1 = Blackboard.RegisterLUAProp("HINT_MAGMA_1", "bool"),
    MAGMA_2 = Blackboard.RegisterLUAProp("HINT_MAGMA_2", "bool"),
    LAB_1 = Blackboard.RegisterLUAProp("HINT_LAB_1", "bool"),
    LAB_2 = Blackboard.RegisterLUAProp("HINT_LAB_2", "bool"),
    AQUA_1 = Blackboard.RegisterLUAProp("HINT_AQUA_1", "bool"),
    AQUA_2 = Blackboard.RegisterLUAProp("HINT_AQUA_2", "bool"),
    FOREST_1 = Blackboard.RegisterLUAProp("HINT_FOREST_1", "bool"),
    SANC_1 = Blackboard.RegisterLUAProp("HINT_SANC_1", "bool"),
    SHIP_1 = Blackboard.RegisterLUAProp("HINT_SHIP_1", "bool")
}

Scenario.RandoTrueXRelease = Blackboard.RegisterLUAProp("X_RELEASE_TRUE", "bool")

function Scenario.CheckRandoHint(ap_id, hint_id)
    local access_point = Game.GetActor(ap_id)
    local seen = Scenario.ReadFromBlackboard(Scenario.tRandoHintPropIDs[hint_id], false)
    if access_point ~= nil and not seen then
        access_point.USABLE:ActiveDialogue("DIAG_ADAM_" .. hint_id)
        Scenario.sHintId = hint_id
    end
end

function Scenario.SetRandoHintSeen()
    if Scenario.sHintId == nil then return end
    local hint_id = Scenario.tRandoHintPropIDs[Scenario.sHintId]
    if not Scenario.ReadFromBlackboard(hint_id, false) then
        Scenario.WriteToBlackboard(hint_id, "b", true)
    end
end

function Scenario.EmmyAbilityObtained_ShowMessage(message, callback, finalcallback, skipped)
    Scenario.sEmmyAbilityObtainedCallback = callback
    Scenario.sEmmyAbilityObtainedFinalCallback = finalcallback

    local post_gui_callback = "Scenario.EmmyAbilityObtained_ShowMessageCallback"
    if skipped then
        post_gui_callback = "Scenario.EmmyAbilityObtained_ShowMessageLaunchCallbacks"
    end
    GUI.ShowMessage(message, true, post_gui_callback, false)
    Game.AddSF(0.5, Game.PlayCurrentEnvironmentMusic, "")
end

function Scenario.ReadFromPlayerBlackboard(prop_id, default)
    local playerSection = Game.GetPlayerBlackboardSectionName()
    local value = Blackboard.GetProp(playerSection, prop_id)
    return value or default
end

function Scenario.WriteToPlayerBlackboard(prop_id, type, value)
    local playerSection = Game.GetPlayerBlackboardSectionName()
    Blackboard.SetProp(playerSection, prop_id, type, value)
end

local init_scenario = Scenario.InitScenario
function Scenario.InitScenario(arg1, arg2, arg3, arg4)
    local playerSection =  Game.GetPlayerBlackboardSectionName()
    local currentSaveRandoIdentifier = Blackboard.GetProp(playerSection, "THIS_RANDO_IDENTIFIER")
    local randoInitialized = Blackboard.GetProp(playerSection, "RANDO_GAME_INITIALIZED")

    Game.LogWarn(0, string.format(
            "Cross-checking seed hashes. The current patch's hash is %q, and the current save's hash is %q.",
            Init.sThisRandoIdentifier, tostring(currentSaveRandoIdentifier)
    ))

    -- This function is added via an exefs patch. It not existing means either broken install or unknown executable
    if not Game.HasRandomizerPatches then
        return Scenario.ShowFatalErrorMessage({
            "{c2}Error!{c0}|Unsupported Metroid Dread version.",
            "Only {c6}1.0.0{c0} and {c6}2.1.0{c0} are supported.|Returning to title screen.",
        })
    end

    -- Cross-check the seed hash in the Blackboard with the one in Init.sThisRandoSeedHash to make sure they match.
    -- If they don't, show a warning to the player, and DO NOT save over their game!
    if currentSaveRandoIdentifier ~= Init.sThisRandoIdentifier then
        return Scenario.ShowFatalErrorMessage({
            "#GUI_WARNING_NOT_RANDO_GAME_1",
            "#GUI_WARNING_NOT_RANDO_GAME_2",
        })
    end

    if not randoInitialized then
        Game.SetXparasite(Init.bDefaultXRelease)
        Blackboard.SetProp("GAME_PROGRESS", "QUARENTINE_OPENED", "b", Init.bDefaultXRelease)
    end

    init_scenario(arg1, arg2, arg3, arg4)

    if not CurrentScenario.HasRandomizerChanges then
        return Scenario.ShowFatalErrorMessage({
            "{c2}Error!{c0}|Unable to find modifications to the level data.",
            "Please verify if the mod was installed properly.|Returning to title screen.",
        })
    end

    if not randoInitialized then
        Blackboard.SetProp(playerSection, "RANDO_GAME_INITIALIZED", "b", true)
        Game.AddSF(0.9, Init.SaveGameAtStartingLocation, "")
        Game.AddSF(0.8, Scenario.ShowText, "")
    end

    if Init.bEnableDeathCounter then
        DeathCounter.OnScenarioInitialized()
    end
end

local fatal_messages_seen = 0
local fatal_messages
function Scenario._ShowNextFatalErrorMessage()
    fatal_messages_seen = fatal_messages_seen + 1
    if fatal_messages_seen > #fatal_messages then
        Scenario.FadeOutAndGoToMainMenu(0.3)
        return
    end
    GUI.ShowMessage(fatal_messages[fatal_messages_seen], true, "Scenario._ShowNextFatalErrorMessage")
end
function Scenario.ShowFatalErrorMessage(messageBoxes)
    fatal_messages_seen = 0
    fatal_messages = messageBoxes
    Game.AddSF(0.8, Scenario._ShowNextFatalErrorMessage, "")
end

Scenario.sRandoStartingTextSeenPropID = Blackboard.RegisterLUAProp("RANDO_START_TEXT", "bool")
local textboxes_seen = 0
function Scenario.ShowText()
    if Scenario.ReadFromBlackboard(Scenario.sRandoStartingTextSeenPropID, false) then return end

    if Init.iNumRandoTextBoxes == textboxes_seen then
        Scenario.WriteToBlackboard(Scenario.sRandoStartingTextSeenPropID, "b", true)
    elseif Init.iNumRandoTextBoxes - textboxes_seen > 0 then
        textboxes_seen = textboxes_seen + 1
        GUI.ShowMessage("#RANDO_STARTING_TEXT_" .. textboxes_seen, true, "Scenario.ShowText")
    end
end

function Scenario.IsTeleportal(actor)
    return Scenario.GetCharclass(actor) == "teleporter"
end

function Scenario.DisableGlobalTeleport(actor)
    if not Scenario.IsTeleportal(actor) then return end
    if not Blackboard.GetProp("GAME_PROGRESS", "TeleportWorldUnlocked") then return end

    local teleportal_id = Scenario.GetTeleportalID(actor)
    if Blackboard.GetProp("GAME_PROGRESS", teleportal_id) then return end
    if Blackboard.GetProp("GAME_PROGRESS", "RandoMapSeen" .. actor.USABLE.sScenarioName) then return end
    Blackboard.SetProp("GAME_PROGRESS", "RandoTeleportWorldUnlocked", "b", true)
    Blackboard.SetProp("GAME_PROGRESS", "TeleportWorldUnlocked", "b", false)
end

function Scenario.GetTeleportalID(actor)
    return CurrentScenarioID .. actor.sName
end

function Scenario.ResetGlobalTeleport(actor)
    if not Scenario.IsTeleportal(actor) then return end
    if not Blackboard.GetProp("GAME_PROGRESS", "RandoTeleportWorldUnlocked") then return end

    Blackboard.SetProp("GAME_PROGRESS", "TeleportWorldUnlocked", "b", true)
end

function Scenario.SetTeleportalUsed(actor)
    if not Scenario.IsTeleportal(actor) then return end

    Scenario.ResetGlobalTeleport(actor)

    local teleportal_id = Scenario.GetTeleportalID(actor)
    local target_id = actor.USABLE.sTargetSpawnPoint
    Blackboard.SetProp("GAME_PROGRESS", teleportal_id, "b", true)
    Blackboard.SetProp("GAME_PROGRESS", "RandoUnlockTeleportal", "s", target_id)
end

local scenarios_with_teleport = {
    s010_cave = "StartPoint0",
    s020_magma = "savestation_000",
    s030_baselab = "savestation_000",
    s040_aqua = "savestation_000",
    s050_forest = "savestation_000",
    s070_basesanc = "savestation_000"
}

function Scenario.VisitAllTeleportScenarios()
    if CurrentScenarioID == "s090_skybase" then
        Blackboard.SetProp("GAME_PROGRESS", "RandoVisitScenarios", "b", true)
    end

    if not Blackboard.GetProp("GAME_PROGRESS", "RandoVisitScenarios") then return end

    for scenario, spawn in pairs(scenarios_with_teleport) do
        if not Blackboard.GetProp("GAME_PROGRESS", "RandoVisited"..scenario) then
            Game.LoadScenario("c10_samus", scenario, spawn, "", 1)
            return true
        end
    end

    Blackboard.SetProp("GAME_PROGRESS", "RandoVisitScenarios", "b", false)
    if CurrentScenarioID == "s090_skybase" then return false end
    Game.LoadScenario("c10_samus", "s090_skybase", "elevator_shipyard_000_platform", "", 1)
    return true
end

function Scenario._UpdateProgressiveItemModels()
    for name, actordef in pairs(Game.GetEntities()) do
        local progressive_models = RandomizerPowerup.tProgressiveModels[actordef]
        if progressive_models ~= nil then
            for _, model in ipairs(progressive_models) do
                if RandomizerPowerup.HasItem(model.item) then
                    local pickup = Game.GetActor(name)
                    pickup.MODELUPDATER.sModelAlias = model.alias
                    pickup.MODELUPDATER:ForceUpdate()
                    break
                end
            end
        end
    end
end

function Scenario.UpdateProgressiveItemModels()
    Game.AddSF(0.1, "Scenario._UpdateProgressiveItemModels", "")
end

Scenario._BlastShieldTypes = {
    doorshieldsupermissile = {
        item = "ITEM_WEAPON_SUPER_MISSILE",
        damage = {"SUPER_MISSILE", "ICE_MISSILE"},
    },
    door_shield_plasma = {
        item = "ITEM_WEAPON_PLASMA_BEAM",
        damage = {"PLASMA_BEAM"}
    },
    doorshieldbomb = {
        item = "ITEM_WEAPON_BOMB",
        damage = {"BOMB"}
    }
}
function Scenario._UpdateBlastShields()
    for name, actordef in pairs(Game.GetEntities()) do
        shield_type = Scenario._BlastShieldTypes[actordef]
        if shield_type ~= nil and RandomizerPowerup.HasItem(shield_type.item) then
            local shield = Game.GetActor(name)
            for _, damage in ipairs(shield_type.damage) do
                shield.LIFE:AddDamageSource(damage)
            end
        end
    end
end

function Scenario.UpdateBlastShields()
    Game.AddSF(0.1, "Scenario._UpdateBlastShields", "")
end

local original_onload = Scenario.OnLoadScenarioFinished
function Scenario.OnLoadScenarioFinished()
    original_onload()

    exclude_function_from_logging("ShowNextAsyncPopup")
    exclude_function_from_logging("HideAsyncPopup")
    exclude_function_from_logging("CheckDebugInputs")

    -- delete all SF functions
    if Scenario.hideSFID ~= nil then
        Game.DelSFByID(Scenario.hideSFID)
        -- hide old popup
        Scenario.HideAsyncPopup()
    end
    if Scenario.showNextSFID ~= nil then
        Game.DelSFByID(Scenario.showNextSFID)
    end

    Scenario.InitGui()
    Scenario.ShowingPopup = false
    Scenario.ShowNextAsyncPopup()

    Blackboard.SetProp("GAME_PROGRESS", "RandoVisited" .. CurrentScenarioID, "b", true)

    if Scenario.VisitAllTeleportScenarios() then return end

    Scenario.UpdateProgressiveItemModels()
    Scenario.UpdateBlastShields()

    Blackboard.SetProp("GAME_PROGRESS", "RandoMapSeen" .. CurrentScenarioID, "b", true)

    Game.AddSF(0, "Scenario.CheckDebugInputs", "")
    RL.UpdateRDVClient(true)

    local teleportal_id = Blackboard.GetProp("GAME_PROGRESS", "RandoUnlockTeleportal")
    if teleportal_id == nil then return end
    local platform = Game.GetActor(teleportal_id)
    if platform ~= nil then
        Blackboard.SetProp("GAME_PROGRESS", CurrentScenarioID .. platform.SMARTOBJECT.sUsableEntity, "b", true)
    end
end

function Scenario.CheckArtifactsObtained(actor, diag)
    if RandomizerPowerup.GetItemAmount("ITEM_METROIDNIZATION") == 0 then
        local oActor = Game.GetActor(actor)
        if oActor ~= nil then
            oActor.USABLE:ActiveDialogue(diag)
        end
    end
end

local save_charclasses = {
    savestation=true,
    accesspoint=true,
    maproom=true,
}

function Scenario.GetCharclass(actor)
    if type(actor) == "userdata" and actor.sName ~= nil then
        actor = actor.sName
    elseif type(actor) ~= "string" then
        Game.LogWarn(0, "Invalid argument for GetCharclass, " .. actor .. " is neither an actor nor a string")
        return nil
    end

    local charclass = Game.GetEntities()[actor]
    Game.LogWarn(0, charclass)
    return charclass
end

function Scenario.IsSaveStation(actor)
    local charclass = Scenario.GetCharclass(actor)
    return save_charclasses[charclass] ~= nil
end

function Scenario.CheckWarpToStart(actor)
    if not Scenario.IsSaveStation(actor) then return end
    if not Init.bWarpToStart then return end

    Input.LogInputs()
    if Input.CheckInputs("ZL", "ZR") then
        Game.LoadScenario("c10_samus", Init.sStartingScenario, Init.sStartingActor, "", 1)
    end
end

function Scenario.CheckDebugInputs()
    push_debug_print_override()
    local delay = 0

    if Scenario.IsUserInteractionEnabled(true) then
        if Input.CheckInputs("ZL", "ZR", "DPAD_UP") then
            delay = 0.5
            -- Game.ReinitPlayerFromBlackboard()
            RandomizerPowerup.DisableInput()
            RandomizerPowerup.ChangeSuit()
        end
    end

    Game.AddSF(delay, "Scenario.CheckDebugInputs", "")
    pop_debug_print_override()
end

function Scenario.SetTunableValue(category, property, value)
    local tunableData = msemenu.GetTunableData(category, property)

    tunableData.category[tunableData.property] = value
end

function Scenario.InitFromBlackboard()
    RandomizerPowerup.ApplyTunableChanges()
    RandomizerPowerup.UpdateWeapons()
end

function Scenario.OnSubAreaChange(old_subarea, old_actorgroup, new_subarea, new_actorgroup, disable_fade)
    Scenario.UpdateProgressiveItemModels()
    Scenario.UpdateBlastShields()
    Scenario.UpdateRoomName(new_subarea)
end

Scenario.NumUIs = 0
function Scenario.InitGui()
    Game.LogWarn(0, "Creating GUI")
    if Scenario.RandoUI ~= nil then
        Scenario.RandoUI:Destroy()
    end
    Scenario.NumUIs = Scenario.NumUIs +1
    local ui = GUILib("RandoUI"..Scenario.NumUIs)
    ui:AddContainer("Content")
    ui:Get("Content"):AddLabel("Popup", "", {
        X = "0.3",
        Y = "0.2",
        SizeX = "0.4",
        SizeY = "0.04",
        CenterX = "0.0", CenterY = "-0.3",
        Font = "digital_hefty",
        TextAlignment = "Centered",
        TextVerticalAlignment = "Centered",
        ScaleX = "1.0", ScaleY = "1.0",
        Enabled = true,
        Visible = false
    })
    ui:Show()
    Scenario.RandoUI = ui

    if Init.bEnableDeathCounter then
        DeathCounter.Init()
    end

    if Init.bEnableRoomIds then
        RoomNameGui.Init()
    end
end

Scenario.QueuedPopups = Scenario.QueuedPopups or Queue()
Scenario.ShowingPopup = false

function Scenario.QueueAsyncPopup(text, time)
    Scenario.QueuedPopups:push({Text = text, Time = time or 5.0})
end

function Scenario.ShowNextAsyncPopup()
    push_debug_print_override()
    if Scenario.QueuedPopups:empty() then
        Scenario.showNextSFID = Game.AddGUISF(0, "Scenario.ShowNextAsyncPopup", "")
        pop_debug_print_override()
        return
    end
    local popup = Scenario.QueuedPopups:peek()
    Scenario.ShowAsyncPopup(popup.Text, popup.Time)
    pop_debug_print_override()
end

function Scenario.ShowAsyncPopup(text, time)
    Scenario.ShowingPopup = true
    Game.LogWarn(0, "Showing text '"..text.."' for "..time.." seconds")

    local popup = Scenario.RandoUI:Get("Content"):Get("Popup")
    popup:SetText(text)
    popup:SetProperties({Visible = true})
    Scenario.hideSFID = Game.AddGUISF(time, "Scenario.HideAsyncPopup", "")
    Scenario.showNextSFID = nil
end

function Scenario.HideAsyncPopup()
    push_debug_print_override()
    Scenario.ShowingPopup = false
    if not Scenario.QueuedPopups:empty() then
        Scenario.QueuedPopups:pop()
    end
    Scenario.RandoUI:Get("Content"):Get("Popup"):SetProperties({Visible = false})
    Scenario.showNextSFID = Game.AddGUISF(0.5, "Scenario.ShowNextAsyncPopup", "")
    Scenario.hideSFID = nil
    pop_debug_print_override()
end

function Scenario.UpdateRoomName(new_subarea)
    RoomNameGui.Update(new_subarea)
end