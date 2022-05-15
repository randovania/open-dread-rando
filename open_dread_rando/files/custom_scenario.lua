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

    -- Cross-check the seed hash in the Blackboard with the one in Init.sThisRandoSeedHash to make sure they match.
    -- If they don't, show a warning to the player, and DO NOT save over their game!
    if currentSaveRandoIdentifier ~= Init.sThisRandoIdentifier then
        Game.AddSF(0.8, Scenario.ShowNotRandoGameMessage, "")
        return
    end

    if not randoInitialized then
        Game.SetXparasite(Init.bDefaultXRelease)
        Blackboard.SetProp("GAME_PROGRESS", "QUARENTINE_OPENED", "b", Init.bDefaultXRelease)
    end

    init_scenario(arg1, arg2, arg3, arg4)

    if not randoInitialized then
        Blackboard.SetProp(playerSection, "RANDO_GAME_INITIALIZED", "b", true)
        Game.AddSF(0.9, Init.SaveGameAtStartingLocation, "")
        Game.AddSF(0.8, Scenario.ShowText, "")
    end
end

local warning_messages_seen = 0
local total_warning_messages = 2
function Scenario.ShowNotRandoGameMessage()
    warning_messages_seen = warning_messages_seen + 1
    if warning_messages_seen > total_warning_messages then
        Scenario.FadeOutAndGoToMainMenu(0.3)
        return
    end
    GUI.ShowMessage("#GUI_WARNING_NOT_RANDO_GAME_" .. warning_messages_seen, true, "Scenario.ShowNotRandoGameMessage")
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
