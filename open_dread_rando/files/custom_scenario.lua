Game.ImportLibrary("system/scripts/scenario_original.lua")

function Scenario.EmmyAbilityObtained_ShowMessage(message, callback, finalcallback, skipped)
    Scenario.sEmmyAbilityObtainedCallback = callback
    Scenario.sEmmyAbilityObtainedFinalCallback = finalcallback

    local post_gui_callback = "Scenario.EmmyAbilityObtained_ShowMessageCallback"
    if skipped then
        post_gui_callback = "Scenario.EmmyAbilityObtained_ShowMessageLaunchCallbacks"
    end
    GUI.ShowMessage(message, true, post_gui_callback, false)
end

local init_scenario = Scenario.InitScenario
function Scenario.InitScenario(arg1, arg2, arg3, arg4)
    init_scenario(arg1, arg2, arg3, arg4)
    if not Scenario.ReadFromBlackboard(Scenario.LUAPropIDs.CAVES_GAME_INTRO, false) then
        Scenario.WriteToBlackboard(Scenario.LUAPropIDs.CAVES_GAME_INTRO, "b", true)
        Game.AddSF(0.8, Scenario.ShowText, "")
    end
end

local textboxes_seen = 0
function Scenario.ShowText()
    if Init.iNumRandoTextBoxes - textboxes_seen > 0 then
        textboxes_seen = textboxes_seen + 1
        GUI.ShowMessage("#RANDO_STARTING_TEXT_" .. textboxes_seen, true, "Scenario.ShowText")
    end
end
