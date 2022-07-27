Game.DoFile('actors/items/randomizer_powerup/scripts/randomizer_powerup.lua')

function s090_skybase.main()
  Blackboard.SetProp("GAME_PROGRESS", "TeleportWorldUnlocked", "b", true)
end
s090_skybase.HasRandomizerChanges = true

function s090_skybase.InitFromBlackboard()
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_FLOOR_SLIDE", "f", 1)
  Game.ReinitPlayerFromBlackboard()
  Game.PopSetup("ChangeCamera_002_Distance", true, true)
end


function s090_skybase.SetupDebugGameBlackboard()

    
    
    
    
    
    
    
    
    
    
    
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_CURRENT_SPECIAL_ENERGY", "f", 1000)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_MAX_SPECIAL_ENERGY", "f", 1000)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_SPECIAL_ENERGY", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_CURRENT_LIFE", "f", 999)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_MAX_LIFE", "f", 999)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_MISSILE_MAX", "f", 84)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_MISSILE_CURRENT", "f", 84)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_SUPER_MISSILE", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_ICE_MISSILE", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_POWER_BOMB", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_POWER_BOMB_MAX", "f", 3)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_POWER_BOMB_CURRENT", "f", 3)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_VARIA_SUIT", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_GRAVITY_SUIT", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_DOUBLE_JUMP", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_SPACE_JUMP", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_SCREW_ATTACK", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_FLOOR_SLIDE", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_MORPH_BALL", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_BOMB", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_LINE_BOMB", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_CHARGE_BEAM", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_WIDE_BEAM", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_DIFFUSION_BEAM", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_GRAPPLE_BEAM", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_PLASMA_BEAM", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_WAVE_BEAM", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_MAGNET_GLOVE", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_SPEED_BOOSTER", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_OPTIC_CAMOUFLAGE", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_GHOST_AURA", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_SONAR", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_METROIDNIZATION", "f", 0)
end
s090_skybase.tGetOnDeathOverrides = {ShowDeath = true, GoToMainMenu = false}



function s090_skybase.GetOnDeathOverrides()
  return s090_skybase.tGetOnDeathOverrides
end


function s090_skybase.OnEntityGenerated(_ARG_0_, _ARG_1_)
  if _ARG_1_ ~= nil then
    print("OnEntityGenerated!!!!!!")
  end
end



function s090_skybase.OnComanderElevatorFinished()

    
    
    
    
    
    
    
    
    
    
    Game.AddSF(0.5, "s090_skybase.CommanderCutscenePresentation", "")
end

function s090_skybase.CommanderCutscenePresentation()
    local oActor = Game.GetActor("cutsceneplayer_86")
  if oActor ~= nil then
    oActor.CUTSCENE:TryLaunchCutscene()
  end
end


function s090_skybase.Delayed_OnComanderElevatorFinished()
    
    
  GUI.ShowMessage("#COMMANDER_CUTSCENE_ACCESSPOINT_REVEAL", true, "s090_skybase.OnComanderElevatorFinished_MessageSkipped")
  local oPlayer = Game.GetPlayer()
  if oPlayer ~= nil then
    oPlayer.INPUT:IgnoreInput(false, false, "OnComanderElevatorFinished")
  end
end



function s090_skybase.OnComanderElevatorFinished_MessageSkipped()









end


function s090_skybase.ActivateCommanderSpawnGroup()
  local oActor = Game.GetActor("SG_ChozoCommander")
  if oActor ~= nil then
    oActor.SPAWNGROUP:EnableSpawnGroup()
  end
end




function s090_skybase.FadeOutCommanderMusic1()
  Game.StopMusicStream(0, 1, 3)
end

function s090_skybase.FadeOutCommanderMusic2()
  Game.StopMusicStream(1, 1, 3)
end






function s090_skybase.SubAreaChangeRequest(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_)
  Scenario.SubAreaChangeRequest(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_)
end


function s090_skybase.OnSubAreaChange(old_subarea, old_actorgroup, new_subarea, new_actorgroup, disable_fade)

end

















function s090_skybase.OnEnter_ChangeCamera_002_Near()
  Game.PushSetup("ChangeCamera_002_Distance", true, true)
end
function s090_skybase.OnEnter_ChangeCamera_002_Far()
  Game.PopSetup("ChangeCamera_002_Distance", true, true)
end

function s090_skybase.OnEnter_ChangeInterp()
  Game.GetCamera().CAMERA:SetLogicCameraParams("CAM_Near", true)
end
function s090_skybase.OnExit_ChangeInterp()
  Game.GetCamera().CAMERA:SetLogicCameraParams("CAM_Default", true)
end





function s090_skybase.ObtainHyperSuit()
  Game.GetPlayer().INVENTORY:SetItemAmount("ITEM_HYPER_SUIT", 1, true)
  Game.GetPlayer().INVENTORY:SetItemAmount("ITEM_WEAPON_HYPER_BEAM", 1, true)
  Game.GetPlayer().LIFE:StopLifeAlarmSFX()
  Game.GetPlayer().MODELUPDATER.sModelAlias = "Hyper"
end




function s090_skybase.cutsceneplayer_101_left()
  local oActorPlayer =  Game.GetActor("cutsceneplayer_101")
  if oActorPlayer ~= nil then
    local oActorPlayerLeft = Game.GetActor("cutsceneplayer_101_left")
    if oActorPlayerLeft ~= nil then
      oActorPlayer.CUTSCENE:QueueCutscenePlayer(oActorPlayerLeft)
    end
  end
end
function s090_skybase.cutsceneplayer_101_right()
  local oActorPlayer =  Game.GetActor("cutsceneplayer_101")
  if oActorPlayer ~= nil then
    local oActorPlayerRight = Game.GetActor("cutsceneplayer_101_right")
    if oActorPlayerRight ~= nil then
      oActorPlayer.CUTSCENE:QueueCutscenePlayer(oActorPlayerRight)
    end
  end
end

function s090_skybase.cutsceneplayer_108_end()    
  local oPlayer = Game.GetPlayer()  
  if oPlayer ~= nil then      
    local L1_2 = oPlayer.INVENTORY    
    if L1_2 ~= nil then
      L1_2:SetItemAmount("ITEM_HYPER_SUIT", 1, true)
    end
    
    local oModelUpdater = oPlayer.MODELUPDATER
    if oModelUpdater ~= nil then
      oModelUpdater.sModelAlias = "Hyper"
      oModelUpdater.ForceUpdate()
    end
    
    Game.LoadScenario("c10_samus", "s080_shipyard", "SP_Checkpoint_CommanderX", "", 1)
    Game.PlayCutsceneOnScenarioLoaded("cutsceneplayer_108", true, true, true, false, false, "", "", 0, 0, 0)
  end
end

function s090_skybase.OnUsablePrepareUse(actor)
  Scenario.DisableGlobalTeleport(actor)
end

function s090_skybase.OnUsableCancelUse(actor)
  Scenario.ResetGlobalTeleport(actor)
end

function s090_skybase.OnUsableUse(actor)
  Scenario.SetTeleportalUsed(actor)
end

function s090_skybase.OnEnter_AP_10()
  s090_skybase.CheckArtifactsObtained("accesspoint_000", "DIAG_ADAM_SHIP_2")
end

function s090_skybase.OnExit_AP_10()
  s090_skybase.CheckArtifactsObtained("accesspoint_000", "DIAG_ADAM_SHIP_2")
end
