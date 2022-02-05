Game.ImportLibrary("system/scripts/init_original.lua")

Init.tNewGameInventory = TEMPLATE("new_game_inventory")

Game.LogWarn(0, "Inventory:")
for k, v in pairs(Init.tNewGameInventory) do
    Game.LogWarn(0, tostring(k) .. " = " .. tostring(v))
end

local buff = {}

function Game.StartPrologue(arg1, arg2, arg3, arg4, arg4)
    Game.LogWarn(0, string.format("Will start Game - %s / %s / %s / %s", tostring(arg1), tostring(arg2), tostring(arg3), tostring(arg4)))
    Game.LoadScenario("c10_samus", TEMPLATE("starting_scenario"), TEMPLATE("starting_actor"), "", 1)
end

Game.SetForceSkipCutscenes(true)
Game.LogWarn(0, "Finished modded system/init.lc")
