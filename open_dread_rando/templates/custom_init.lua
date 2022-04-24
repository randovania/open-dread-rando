Game.ImportLibrary("system/scripts/init_original.lua")

local initOk, errorMsg = pcall(function()

Init.tNewGameInventory = TEMPLATE("new_game_inventory")

Init.iNumRandoTextBoxes = TEMPLATE("textbox_count")
Init.fEnergyPerTank = TEMPLATE("energy_per_tank")
Init.fEnergyPerPart = TEMPLATE("energy_per_part")
Init.bImmediateEnergyParts = TEMPLATE("immediate_energy_parts")
Init.bDefaultXRelease = TEMPLATE("default_x_released")

Game.LogWarn(0, "Inventory:")
for k, v in pairs(Init.tNewGameInventory) do
    Game.LogWarn(0, tostring(k) .. " = " .. tostring(v))
end

local buff = {}

Init.sStartingScenario = TEMPLATE("starting_scenario")
Init.sStartingActor = TEMPLATE("starting_actor")

function Game.StartPrologue(arg1, arg2, arg3, arg4, arg5)
    Game.LogWarn(0, string.format("Will start Game - %s / %s / %s / %s", tostring(arg1), tostring(arg2), tostring(arg3), tostring(arg4)))
    Game.LoadScenario("c10_samus", Init.sStartingScenario, Init.sStartingActor, "", 1)
end

function Init.SaveGameAtStartingLocation()
    Game.SaveGame("savedata", "IntroEnd", Init.sStartingActor, true)
end

Init.sThisRandoSeedHash = TEMPLATE("shareable_hash")

local original_Init_CreateNewGameData = Init.CreateNewGameData
function Init.CreateNewGameData(difficulty)
    original_Init_CreateNewGameData(difficulty)

    local playerSection =  Game.GetPlayerBlackboardSectionName()

    --[[
        When creating a new save file, store the current seed hash in the Blackboard.

        The seed hash will be cross-checked when loading a save (via Scenario.InitScenario), and a warning message will be shown if the
        hash in the Blackboard doesn't exist or doesn't match the copy stored in Init.sThisRandoSeedHash.

        If the player loads a non-rando save, the hash won't exist in the Blackboard, and if they load a save from a different seed, the
        hash in the Blackboard will be different than the one in Init.sThisRandoSeedHash.
    ]]

    Game.LogWarn(0, ("Setting THIS_RANDO_HASH Blackboard property to %q"):format(Init.sThisRandoSeedHash))
    Blackboard.SetProp(playerSection, "THIS_RANDO_HASH", "s", Init.sThisRandoSeedHash)

    -- Must explicitly set the "initialized" flag to false; it seems the Player Blackboard doesn't get fully wiped when making a new file
    -- after recently playing a file in the same slot.

    Game.LogWarn(0, "Resetting RANDO_GAME_INITIALIZED Blackboard property")
    Blackboard.SetProp(playerSection, "RANDO_GAME_INITIALIZED", "b", false)
end

Game.SetForceSkipCutscenes(true)
Game.LogWarn(0, "Finished modded system/init.lc")

end)
if not initOk then
    Game.LogWarn(0, "Init failed: " .. errorMsg)
    GUI.ShowMessage("Init failed: " .. errorMsg, true, "")
end