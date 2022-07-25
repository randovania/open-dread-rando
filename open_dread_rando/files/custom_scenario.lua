Game.ImportLibrary("system/scripts/scenario_original.lua")

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


local teleportal_names = {
    "teleport_baselab_000",
    "LE_Teleport_FromMagma",
    "teleporter_magma_000",
    "LE_Teleport_Secret",
    "teleporter_forest_000",
    "teleporter_cave_000",
    "LE_Teleport_FromCave",
    "teleport_baselab_000",
    "teleport_cave_000",
    "teleport_magma_000",
    "teleporter_000",
    "teleporter_aqua_000"
}
function Scenario.IsTeleportal(actor)
    for _, name in ipairs(teleportal_names) do
        if actor.sName == name then return true end
    end
    return false
end

function Scenario.DisableGlobalTeleport(actor)
    if not Scenario.IsTeleportal(actor) then return end
    if not Blackboard.GetProp("GAME_PROGRESS", "TeleportWorldUnlocked") then return end

    local teleportal_id, target_id = Scenario.GetTeleportalIDs(actor)
    if Blackboard.GetProp("GAME_PROGRESS", teleportal_id) then return end
    Blackboard.SetProp("GAME_PROGRESS", "RandoTeleportWorldUnlocked", "b", true)
    Blackboard.SetProp("GAME_PROGRESS", "TeleportWorldUnlocked", "b", false)
end

function Scenario.GetTeleportalIDs(actor)
    local teleportal_id = CurrentScenarioID .. actor.sName
    local target_id = actor.USABLE.sTargetSpawnPoint

    return teleportal_id, target_id
end

function Scenario.ResetGlobalTeleport(actor)
    if not Scenario.IsTeleportal(actor) then return end
    if not Blackboard.GetProp("GAME_PROGRESS", "RandoTeleportWorldUnlocked") then return end

    Blackboard.SetProp("GAME_PROGRESS", "TeleportWorldUnlocked", "b", true)
end

function Scenario.SetTeleportalUsed(actor)
    if not Scenario.IsTeleportal(actor) then return end

    local teleportal_id, target_id = Scenario.GetTeleportalIDs(actor)
    Blackboard.SetProp("GAME_PROGRESS", teleportal_id, "b", true)
    Blackboard.SetProp("GAME_PROGRESS", "RandoUnlockTeleportal", "s", target_id)
    Scenario.ResetGlobalTeleport(actor)
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

local original_onload = Scenario.OnLoadScenarioFinished
function Scenario.OnLoadScenarioFinished()
    original_onload()

    Blackboard.SetProp("GAME_PROGRESS", "RandoVisited" .. CurrentScenarioID, "b", true)

    if Scenario.VisitAllTeleportScenarios() then return end

    local teleportal_id = Blackboard.GetProp("GAME_PROGRESS", "RandoUnlockTeleportal")
    if teleportal_id == nil then return end
    local platform = Game.GetActor(teleportal_id)
    if platform ~= nil then
        Blackboard.SetProp("GAME_PROGRESS", CurrentScenarioID .. platform.SMARTOBJECT.sUsableEntity, "b", true)
    end
end
