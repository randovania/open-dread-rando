function s080_shipyard.main()
end

function s080_shipyard.OnLoadScenarioFinished()
  if Game.GetCurrentSubAreaId() == "collision_camera_020" then
    local L0_2 = Game.GetActor("cutsceneplayer_108")
    if L0_2 ~= nil and L0_2.CUTSCENE:HasCutsceneBeenPlayed() == false then
        Game.ResetFader()
        Game.FadeOut(0)
    end
  end
end







local SHIP_EMMY_METROIDNIZATION = false
local SHIP_STRONG_REACTION = false
local SHIP_CWXELITE_PRESENTATION = false
function s080_shipyard.InitFromBlackboard()
  
  
  
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_FLOOR_SLIDE", "f", 1)
  Game.ReinitPlayerFromBlackboard()
  Game.ForceEntityIconVisible("LM_Samus_Ship")
  SHIP_EMMY_METROIDNIZATION = Scenario.ReadFromBlackboard(Scenario.LUAPropIDs.SHIP_EMMY_METROIDNIZATION, false)
  SHIP_STRONG_REACTION = Scenario.ReadFromBlackboard(Scenario.LUAPropIDs.SHIP_STRONG_REACTION, false)
  SHIP_CWXELITE_PRESENTATION = Scenario.ReadFromBlackboard(Scenario.LUAPropIDs.SHIP_CWXELITE_PRESENTATION, false)
  local oProp = Blackboard.GetProp("PLAYER_INVENTORY", "ITEM_WEAPON_WAVE_BEAM")
  if oProp ~= nil and oProp > 0 then
    s080_shipyard.Activate_Setup_WaveBeamAcquired()
  end
end

function s080_shipyard.Activate_Setup_WaveBeamAcquired()
  Game.PushSetup("WaveBeamAcquired", true, true)
end


function s080_shipyard.SetupDebugGameBlackboard()
  
  
  
  
  
  
  
  
  
  
  
  
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_CURRENT_SPECIAL_ENERGY", "f", 1000)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_MAX_SPECIAL_ENERGY", "f", 1000)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_SPECIAL_ENERGY", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_CURRENT_LIFE", "f", 899)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_MAX_LIFE", "f", 899)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_MISSILE_MAX", "f", 84)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_MISSILE_CURRENT", "f", 84)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_SUPER_MISSILE", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_ICE_MISSILE", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_POWER_BOMB", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_POWER_BOMB_MAX", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_POWER_BOMB_CURRENT", "f", 0)
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
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_WAVE_BEAM", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_MAGNET_GLOVE", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_SPEED_BOOSTER", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_OPTIC_CAMOUFLAGE", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_GHOST_AURA", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_SONAR", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_METROIDNIZATION", "f", 0)
end


s080_shipyard.tGetOnDeathOverrides = {ShowDeath = true, GoToMainMenu = false}
function s080_shipyard.GetOnDeathOverrides()
  return s080_shipyard.tGetOnDeathOverrides
end


function s080_shipyard.OnEntityGenerated(_ARG_0_, _ARG_1_)
  if _ARG_1_ ~= nil then
    print("OnEntityGenerated!!!!!!")
  end
end






function s080_shipyard.OnEnter_ChangeCamera_005_B()
  Game.SetCollisionCameraLocked("collision_camera_005_B", true)
end
function s080_shipyard.OnExit_ChangeCamera_005_B()
  Game.SetCollisionCameraLocked("collision_camera_005_B", false)
end

function s080_shipyard.OnEnter_ChangeCamera_006_B()
  Game.SetCollisionCameraLocked("collision_camera_006_B", true)
end
function s080_shipyard.OnExit_ChangeCamera_006_B()
  Game.SetCollisionCameraLocked("collision_camera_006_B", false)
end

function s080_shipyard.OnEnter_ChangeCamera_009_C()
  Game.PushSetup("ChangeCamera_009_C", false, true)
end
function s080_shipyard.OnExit_ChangeCamera_009_C()
  Game.PopSetup("ChangeCamera_009_C", false, true)
end

function s080_shipyard.OnEnter_ChangeCamera_009_B()
  Game.SetCollisionCameraLocked("collision_camera_009_B", true)
end
function s080_shipyard.OnExit_ChangeCamera_009_B()
  Game.SetCollisionCameraLocked("collision_camera_009_B", false)
end

function s080_shipyard.OnEnter_ChangeCamera_013_B()
  Game.SetCollisionCameraLocked("collision_camera_013_B", true)
end
function s080_shipyard.OnExit_ChangeCamera_013_B()
  Game.SetCollisionCameraLocked("collision_camera_013_B", false)
end

function s080_shipyard.OnEnter_ChangeCamera_013_C()
  Game.SetCollisionCameraLocked("collision_camera_013_C", true)
  local oActor = Game.GetActor("block_pbtube_2")
  if oActor ~= nil then
    oActor.LIFE.bWantsEnabled = true
  end
end
function s080_shipyard.OnExit_ChangeCamera_013_C()
  Game.SetCollisionCameraLocked("collision_camera_013_C", false)
  local oActor = Game.GetActor("block_pbtube_2")
  if oActor ~= nil then
    oActor.LIFE.bWantsEnabled = false
  end
end

function s080_shipyard.OnEnter_ChangeCamera_014_B()
  Game.SetCollisionCameraLocked("collision_camera_014_B", true)
end
function s080_shipyard.OnExit_ChangeCamera_014_B()
  Game.SetCollisionCameraLocked("collision_camera_014_B", false)
end




function s080_shipyard.OnEndStrongReactionEvent()
  Game.GetPlayer().INVENTORY:SetItemAmount("ITEM_METROIDNIZATION", 1, true)
end




function s080_shipyard.OnEnter_trigger_PowerBombObtained(_ARG_0_, _ARG_1_)
  
  
  
  _ARG_0_.bEnabled = false
  Game.AddSF(1, "s080_shipyard.DelayedPowerBombObtained", "")
  local oPlayer = Game.GetPlayer()
  if oPlayer ~= nil then
    oPlayer.INPUT:IgnoreInput(true, false, "OnEnter_trigger_PowerBombObtained")
  end
end


function s080_shipyard.DelayedPowerBombObtained()



  GUI.ShowMessage("#CUT_POWER_BOMB", true, "s080_shipyard.PowerBombObtainedMessageSkipped")
  local oPlayer = Game.GetPlayer()
  if oPlayer ~= nil then
    oPlayer.INPUT:IgnoreInput(false, false, "OnEnter_trigger_PowerBombObtained")
  end
end


function s080_shipyard.On0071Started()
    
    
  GUI.AddEmmyMissionLogEntry("#MLOG_ENCOUNTER_EMMY_SHIP")
end

function s080_shipyard.OnChozoWarriorActivated()








  GUI.WriteEmmyDeathToBlackboard()

  local oActor1 = Game.GetActor("SG_CWX") 
  if oActor1 ~= nil then
    oActor1.SPAWNGROUP:EnableSpawnGroup()
  end

  local oActor2 = Game.GetEntityFromSpawnPoint("SP_Emmy")
  if oActor2 ~= nil then
    oActor2.bEnabled = false
  end

  local oActor3 = Game.GetActor("PRP_EmmyShipyard")
  if oActor3 ~= nil then
    oActor3.bEnabled = true
  end

  local oActor4 = Game.GetActor("emmyvalve_reg_gen_000") 
  if oActor4 ~= nil then
    oActor4.EMMYVALVE:SetState(false, true)
  end

  local oActor5 = Game.GetActor("emmyvalve_reg_gen_001")
  if oActor5 ~= nil then
    oActor5.EMMYVALVE:SetState(false, true)
  end
end


function s080_shipyard.OnChozoWarriorXKilled(_ARG_0_, _ARG_1_, _ARG_2_)

















  if _ARG_1_ == "SP_CWX_Phase2" then
     local oActor = Game.GetActor("PRP_EmmyShipyard")
    if oActor ~= nil then
      oActor.bEnabled = false
    end

    Game.StopMusic(true)

    local oEntity = Game.GetEntityFromSpawnPoint("SP_Emmy")
    if oEntity  ~= nil then
      oEntity.bEnabled = true
    end

    Game.KillEmmy()
  end
end


function s080_shipyard.OnEmmyShipyardAbilityObtained()

  Game.AddSF(0.8, "s080_shipyard.OpenEmmyValves", "")
end


function s080_shipyard.OpenEmmyValves()
  local oActor1 = Game.GetActor("emmyvalve_reg_gen_000")
  if oActor1 ~= nil then
    oActor1.EMMYVALVE:CleanForceStateFlag(false)
  end
  local oActor2 = Game.GetActor("emmyvalve_reg_gen_001")
  if oActor2 ~= nil then
    oActor2.EMMYVALVE:CleanForceStateFlag(false)
  end
  local oActor3 = Game.GetActor("PRP_CUDeactivated")
  if oActor3 ~= nil then
    oActor3.bEnabled = true
  end
  Game.SaveGame("checkpoint", "ChozoWarriorX_Dead", "SP_Checkpoint_Dead_ChozoWarriorX", false)
end


function s080_shipyard.OnGiveInventoryItemOnDead(_ARG_0_)

end

function s080_shipyard.ChangeSetup_PostEmmy()
  Game.PushSetup("PostEmmy", true, true)
end







function s080_shipyard.ObtainHyperBeam()
  local oPlayer = Game.GetPlayer()
  if oPlayer ~= nil then
    oPlayer.INVENTORY:SetItemAmount("ITEM_WEAPON_HYPER_BEAM", 1, true)
  end
end







function s080_shipyard.OnEnterEscapeSequence()
  Game.PushSetup("Escape_Sequence", true, true)
  Game.AddSF(0.5, "s080_shipyard.InitEscapeSequence", "")
end


function s080_shipyard.InitEscapeSequence()
  local L0_2 = Game.GetActor("ev_evacuation")
  print("search ev_evacuation")
  if L0_2 ~= nil then
    print("Launch Event Evacuation")
    L0_2.EVENTPROP:LaunchEvent()
    Game.SaveGame("checkpoint", "Escape_Sequence", "SP_Checkpoint_Escape", true)
  end
end



function s080_shipyard.EscapeSquence_Drop_01()

  local oActor = Game.GetActor("escape_explosion_path_01")
  if oActor ~= nil then
    oActor:StartTimeline("explosion_01", true)
  end
end

function s080_shipyard.EscapeSquence_Drop_02()
  
  local oActor = Game.GetActor("escape_explosion_path_02")
  if oActor ~= nil then
    oActor:StartTimeline("explosion_03", true)
  end
end

function s080_shipyard.EscapeSquence_Drop_03()

  local oActor = Game.GetActor("escape_explosion_path_03")
  if oActor  ~= nil then
    oActor:StartTimeline("explosion_02", true)
  end
end

function s080_shipyard.EscapeSquence_Drop_04()

  local oActor1 = Game.GetActor("mapev_atriumdebris")
  if oActor1 ~= nil then
    oActor1:StartTimeline("explosion_01", true)
  end

  local oActor2 = Game.GetActor("escape_glass_01")
  if oActor2 ~= nil then
    oActor2.ANIMATION:SetAction("relax", true)
  end

  local oActor3 = Game.GetActor("escape_glass_02")
  if oActor3 ~= nil then
    oActor3.ANIMATION:SetAction("relax", true)
  end

  local oActor4 = Game.GetActor("escpe_glass_03")
  if oActor4 ~= nil then
    oActor4.ANIMATION:SetAction("relax", true)
  end
end






function s080_shipyard.OnEnter_trigger_EndGame(_ARG_0_, _ARG_1_)
  _ARG_0_.bEnabled = false
  
  
  
  
  local oActor1 = Game.GetActor("ev_evacuation")
  if oActor1 ~= nil then
    oActor1.EVENTPROP:StopCountDown()
  end
  
  GUI.HideEscapeCounter()
  
  local oActor2 = Game.GetActor("cutsceneplayer_112")
  if oActor2 ~= nil then
    oActor2.CUTSCENE:LaunchCutsceneImmediate()
  end
end

function s080_shipyard.OnEnter_EndGame()
  Game.GameCleared()
end




function s080_shipyard.OnEnter_AP_10()
  Scenario.CheckRandoHint("accesspoint_000", "SHIP_1")
end

function s080_shipyard.OnUsableFinishInteract(_ARG_0_)
  if _ARG_0_.sName == "accesspoint_000" then
    Scenario.SetRandoHintSeen()
  end
end





function s080_shipyard.SubAreaChangeRequest(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_)
  Scenario.SubAreaChangeRequest(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_)
end


function s080_shipyard.OnSubAreaChange(old_subarea, old_actorgroup, new_subarea, new_actorgroup, disable_fade)




  if old_subarea == "collision_camera_011" and new_subarea == "collision_camera_014" and SHIP_EMMY_METROIDNIZATION == false then
    s080_shipyard.ClosePowerBombDoor()
  elseif old_subarea == "collision_camera_009" and new_subarea == "collision_camera_010" and SHIP_STRONG_REACTION == false then
    s080_shipyard.OnBegin_Cutscene_12()
  elseif old_subarea == "collision_camera_006" and new_subarea == "collision_camera_005" and SHIP_CWXELITE_PRESENTATION == false then
    s080_shipyard.OnBegin_Cutscene_71()
  elseif old_subarea == "collision_camera_000" and new_subarea == "collision_camera_016" then
    Game.StopMusic(true)
  end
end

function s080_shipyard.ClosePowerBombDoor()
  
  local L0_2 = Game.GetActor("doorpowerclosed_001")
  if L0_2 ~= nil and L0_2.LIFE:CanBeClosedSafely() then
    Game.GetActor("doorpowerclosed_001").LIFE:CloseDoor(false, true, false)
    local L1_2 = Game.GetEntityFromSpawnPoint("SP_Emmy")
    if L1_2 ~= nil then
      L1_2.bEnabled = true
    end
  else
    Game.AddSF(0, "s080_shipyard.ClosePowerBombDoor", "")
  end
end






function s080_shipyard.OnEmmyShipyardTargetDetected()
  Game.AddSF(1.3, "s080_shipyard.OnEmmyShipyardLaunchFade", "")
end

s080_shipyard.fEmmyShipyardFadeOutTime = 0.25
s080_shipyard.fEmmyShipyardFadeTime = 0.5
s080_shipyard.fEmmyShipyardInTime = 0.25

function s080_shipyard.OnEmmyShipyardLaunchFade()
  
  
  
  local oActor1 = Game.GetActor("PRP_CUDeactivated")
  if oActor1 ~= nil then
    oActor1.bEnabled = false
  end
  
  local oActor2 = Game.GetActor("block_cut43")
  if oActor2 ~= nil then
    oActor2.TIMELINECOMPONENT:StartAction("powerbombexplosion", -1, false)
  end
end










function s080_shipyard.RemoveSamusHyperSuit()
  
  Game.SetSendReports(false)
  Game.GetPlayer().INVENTORY:SetItemAmount("ITEM_HYPER_SUIT", 0, true)
  Game.GetPlayer().INVENTORY:SetItemAmount("ITEM_WEAPON_HYPER_BEAM", 0, true)
  Game.GetPlayer().INVENTORY:SetItemAmount("ITEM_WEAPON_WAVE_BEAM", 1, true)
  Game.SetSendReports(true)
end



function s080_shipyard.OnBegin_Cutscene_43()
  
  local L0_2 = Game.GetActor("cutsceneplayer_43")
  if L0_2 ~= nil then
    L0_2.CUTSCENE:TryLaunchCutscene()
  end
  
  local L1_2 = Game.GetActor("centralunitmagmacontroller_000")
  if L1_2 ~= nil then
    L1_2.CENTRALUNIT:ForceEmmyDeadState()
  end
  Scenario.WriteToBlackboard(Scenario.LUAPropIDs.SHIP_EMMY_METROIDNIZATION, "b", true)
  SHIP_EMMY_METROIDNIZATION = true
  
  local L2_2 = Game.GetActor("block_cut43")
  if L2_2 ~= nil then
    L2_2.LIFE:ForceDead(false, true)
  end
  
  local L3_2 = Game.GetEntityFromSpawnPoint("SP_Emmy")
  if L3_2 ~= nil then
    L3_2.ANIMATION:SetAction("dead_shipyard", true)
  end
end

function s080_shipyard.OnBegin_Cutscene_12()
  local oActor = Game.GetActor("cutsceneplayer_12")
  if oActor ~= nil then
    oActor.CUTSCENE:TryLaunchCutscene()
  end
  Scenario.WriteToBlackboard(Scenario.LUAPropIDs.SHIP_STRONG_REACTION, "b", true)
  SHIP_STRONG_REACTION = true
end

function s080_shipyard.OnBegin_Cutscene_71()
  local oActor = Game.GetActor("cutsceneplayer_71")
  if oActor ~= nil then
    oActor.CUTSCENE:TryLaunchCutscene()
  end
  Scenario.WriteToBlackboard(Scenario.LUAPropIDs.SHIP_CWXELITE_PRESENTATION, "b", true)
  SHIP_CWXELITE_PRESENTATION = true
end









function s080_shipyard.AtriumBridgeEvent()
    
    
  Game.PlayCameraFXPreset("QUEEN_SHAKING_JUMP")
  Game.PlayPresetSound("events/chainreaction_bigexplosion")
end





function s080_shipyard.Activate_SG_PostWarrior()
  
  print("ACTIVATED POST CHOZO WARRIOR EVENT SETUP")
  Game.PushSetup("PostChozoWarriorEvent", true, true)
end





function s080_shipyard.OnEnter_ActivateArenaEnemies(_ARG_0_, _ARG_1_)
  local oActor = Game.GetActor("SG_Sharpaw_000")
  if oActor ~= nil then
    oActor.SPAWNGROUP:EnableSpawnGroup()
  end
  _ARG_0_.bEnabled = false
end





function s080_shipyard.StopCUAlarm()
  local oActor = Game.GetActor("centralunitmagmacontroller_000")
  if oActor ~= nil then
    oActor.CENTRALUNIT:AllowAlarm(false)
  end
end





function s080_shipyard.LightningEntitiesEnable()
  local oActor1 = Game.GetActor("ev_shi_ray02_004")
  if oActor1 ~= nil then
    oActor1.bEnabled = true
  end
  local oActor2 = Game.GetActor("ev_shi_rayimpact01_000")
  if oActor2 ~= nil then
    oActor2.bEnabled = true
  end
end

function s080_shipyard.LightningEntitiesDisable()
  local oActor1 = Game.GetActor("ev_shi_ray02_004")
  if oActor1 ~= nil then
    oActor1.bEnabled = false
  end
  local oActor2 = Game.GetActor("ev_shi_rayimpact01_000")
  if oActor2 ~= nil then
    oActor2.bEnabled = false
  end
end
