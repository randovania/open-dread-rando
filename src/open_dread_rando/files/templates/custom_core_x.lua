Game.DoFile('actors/items/randomizer_powerup/scripts/randomizer_powerup.lua')

-- Golzuna
function CoreX_SuperGoliath.main()
end
function CoreX_SuperGoliath.LaunchDamageSound(A0_2)
end

local reward_class = TEMPLATE("golzuna")

function CoreX_SuperGoliath.OnRewardMessageClosed()
  Scenario.ResumeEnvironmentSound()
  reward_class.OnPickedUp(nil)
end

function CoreX_SuperGoliath.OnBigXAbsorbed(A0_2)
  RandomizerPowerup.MarkLocationCollected("s050_forest_golzuna")
  if reward_class then
    GUI.ShowMessage("#GUI_ITEM_ACQUIRED_LINE_BOMB", true, "CoreX_SuperGoliath.OnRewardMessageClosed", false)
  end
  local actor = Game.GetActor("doorpowerclosed_003")
  if actor ~= nil then
    actor.LIFE:UnLockDoor()
  end
  Game.SaveGame("checkpoint", "SuperGoliath_Dead", "SP_Checkpoint_LineBomb", true)

  Scenario.IncrementCompletion()
end
