Game.DoFile('actors/items/randomizer_powerup/scripts/randomizer_powerup.lua')

-- Escue
function CoreX_SuperQuetzoa.main()
end
function CoreX_SuperQuetzoa.LaunchDamageSound(_ARG_0_)
end

local reward_class = TEMPLATE("escue")

function CoreX_SuperQuetzoa.OnRewardMessageClosed()
  Scenario.ResumeEnvironmentSound()
  reward_class.OnPickedUp(nil)
end

function CoreX_SuperQuetzoa.OnBigXAbsorbed(_ARG_0_)
  RandomizerPowerup.MarkLocationCollected("s070_basesanc_escue")
  Game.PushSetup("PostSuperQuetzoaDead", true, false)
  if reward_class then
    GUI.ShowMessage("#GUI_ITEM_ACQUIRED_MULTI_LOCK", true, "CoreX_SuperQuetzoa.OnRewardMessageClosed", false)
  end
  local door = Game.GetActor("doorpowerpower_014")
  if  door ~= nil then
    door.LIFE:UnLockDoor()
  end
  Game.SaveGame("checkpoint", "SuperQuetzoa_Dead", "SP_Checkpoint_MultiLockOn", true)

  Scenario.IncrementCompletion()
end
