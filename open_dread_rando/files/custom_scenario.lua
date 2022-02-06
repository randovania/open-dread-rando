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
