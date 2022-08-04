function s060_quarantine.main()
end
s060_quarantine.HasRandomizerChanges = true

function s060_quarantine.SetupDebugGameBlackboard()
    
    
    
    
    
    
    
    
    
    
    

  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_CURRENT_SPECIAL_ENERGY", "f", 1000)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_MAX_SPECIAL_ENERGY", "f", 1000)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_SPECIAL_ENERGY", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_CURRENT_LIFE", "f", 499)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_MAX_LIFE", "f", 499)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_MISSILE_MAX", "f", 54)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_MISSILE_CURRENT", "f", 54)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_SUPER_MISSILE", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_ICE_MISSILE", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_POWER_BOMB", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_POWER_BOMB_MAX", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_POWER_BOMB_CURRENT", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_VARIA_SUIT", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_GRAVITY_SUIT", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_DOUBLE_JUMP", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_SPACE_JUMP", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_SCREW_ATTACK", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_FLOOR_SLIDE", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_MORPH_BALL", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_BOMB", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_LINE_BOMB", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_CHARGE_BEAM", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_WIDE_BEAM", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_DIFFUSION_BEAM", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_GRAPPLE_BEAM", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_PLASMA_BEAM", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_WAVE_BEAM", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_MAGNET_GLOVE", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_SPEED_BOOSTER", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_OPTIC_CAMOUFLAGE", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_GHOST_AURA", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_SONAR", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_METROIDNIZATION", "f", 0)
end


function s060_quarantine.InitFromBlackboard()
  Game.ReinitPlayerFromBlackboard()
  if not Scenario.ReadFromBlackboard(Scenario.RandoTrueXRelease, false) then
    Game.SetXparasite(false)
    Blackboard.SetProp("GAME_PROGRESS", "QUARENTINE_OPENED", "b", false)
  end
  s060_quarantine.CheckGatesOpened()
end





function s060_quarantine.CheckGatesOpened()
  local L0_2 = Blackboard.GetProp("GAME_PROGRESS", "QUARENTINE_OPENED")
  if L0_2 == true then
    local L1_2 = Game.GetActor("ev_gatesealed_opened")
    if L1_2 ~= nil then
      L1_2.bEnabled = true
    end
    local L2_2 = Game.GetActor("ev_gatesealed_closed")
    if L2_2 ~= nil then
      L2_2.NAVMESHITEM:SetStage("removed")
      L2_2.bEnabled = false
    end
  else
    local L1_2 = Game.GetActor("ev_gatesealed_opened")
    if L1_2 ~= nil then
      L1_2.bEnabled = false
    end
    local L2_2 = Game.GetActor("ev_gatesealed_closed")
    if L2_2 ~= nil then
      L2_2.bEnabled = true
      L2_2.NAVMESHITEM:SetStage("initial")
    end
  end
end


s060_quarantine.tGetOnDeathOverrides = {ShowDeath = true, GoToMainMenu = false}
function s060_quarantine.GetOnDeathOverrides()
  return s060_quarantine.tGetOnDeathOverrides
end


function s060_quarantine.OnEntityGenerated(_ARG_0_, _ARG_1_)
  if _ARG_1_ ~= nil then
    print("OnEntityGenerated!!!!!!")
  end
end

function s060_quarantine.OnEnter_XParasite_Activated(_ARG_0_, _ARG_1_)
  Scenario.WriteToBlackboard(Scenario.RandoTrueXRelease, "b", true)
  Game.SetXparasite(true)
end

function s060_quarantine.OnEnter_TG_QuarentineOpen(_ARG_0_, _ARG_1_)
    
  local oActor1 = Game.GetActor("ev_gatesealed_opened")
  if oActor1 ~= nil then
    oActor1.bEnabled = true
  end
  
  local oActor2 = Game.GetActor("ev_gatesealed_closed")
  if oActor2 ~= nil then
    oActor2.NAVMESHITEM:SetStage("removed")
    oActor2.bEnabled = false
  end
  
  local oActor3 = Game.GetActor("ev_gatesealed_second")
  if oActor3 ~= nil then
    oActor3.EVENTPROP:LaunchEvent()
  end
  
  if _ARG_0_ ~= nil then
    _ARG_0_.bEnabled = false
  end
end







function s060_quarantine.SubAreaChangeRequest(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_)
  Scenario.SubAreaChangeRequest(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_)
end


function s060_quarantine.OnSubAreaChange(old_subarea, old_actorgroup, new_subarea, new_actorgroup, disable_fade)
  
    
  
  
  local L5_2 = Game.GetActor("TG_PostChozoWarriorEnemies")
  local L6_2 = Game.GetActor("SG_ChozoWarriorX")
  
  if old_subarea == "collision_camera_007" and new_subarea == "collision_camera_004" then
    Game.SaveGameToSnapshot("ChozoWarriorX_Quarantine")
    s060_quarantine.LaunchCutscene_67()
  end
  
  if old_subarea == "collision_camera_012" and new_subarea == "collision_camera_011" then
    s060_quarantine.LaunchCutscene_113()
  end
  
  if old_subarea == "collision_camera_003" and new_subarea == "collision_camera_002" then
    local L7_2 = Blackboard.GetProp("GAME_PROGRESS", "QUARENTINE_OPENED")
    if L7_2 == true then
      s060_quarantine.LaunchCutscene_4()
    end
  end
  
  if old_subarea == "collision_camera_003" and new_subarea == "collision_camera_005" then
    s060_quarantine.LaunchCutscene_13()
  end
  
  if old_subarea == "collision_camera_004" and L6_2 ~= nil then
    print(L6_2.SPAWNGROUP.iNumDeaths)
  
    if L6_2.SPAWNGROUP.iNumDeaths > 1 then
      Game.PopSetup("SP_ChozoWarriorX_Phase2_chozowarriorx_Boss_Defeated", true, true)
      Game.PushSetup("PostChozoWarriorX", true, true)
      if L5_2 ~= nil then
        L5_2.bEnabled = true
      end
    end
  end
end





function s060_quarantine.LaunchCutscene_67()
  local oActor = Game.GetActor("cutsceneplayer_67")
  if oActor ~= nil then
    oActor.CUTSCENE:TryLaunchCutscene()
  end
end

function s060_quarantine.LaunchCutscene_4()
  local oActor = Game.GetActor("cutsceneplayer_4")
  if oActor ~= nil then
    oActor.CUTSCENE:TryLaunchCutscene()
  end
end

function s060_quarantine.LaunchCutscene_13()
  local oActor = Game.GetActor("cutsceneplayer_13")
  if oActor ~= nil then
    oActor.CUTSCENE:TryLaunchCutscene()
  end
end

function s060_quarantine.OnBeforeCutscene13Started()
  local oActor = Game.GetActor("SP_ChozoZombieX_000")
  if oActor ~= nil then
    Game.SpawnEntity("SP_ChozoZombieX_000")
    oActor.SPAWNPOINT:Activate()
  end
end

function s060_quarantine.LaunchCutscene_113()
  local oActor = Game.GetActor("cutsceneplayer_113")
  if oActor ~= nil then
    oActor.CUTSCENE:TryLaunchCutscene()
  end
end

function s060_quarantine.OnCutscene113Ended()
  local oActor = Game.GetActor("ev_gatesealed_second")
  if oActor ~= nil then
    oActor.EVENTPROP:ForceOpen()
  else
    print("ev_gatesealed_second actor not found")
  end
end

function s060_quarantine.OnBeforeQuarantineDoorsOpenCutsceneStarts()
  s060_quarantine.OnCutscene113Ended()
end












function s060_quarantine.OnEnter_PostCWEnemies(_ARG_0_, _ARG_1_)
  local oActor = Game.GetActor("SG_PostChozoWarrior")

  if oActor ~= nil then
    oActor.SPAWNGROUP:EnableSpawnGroup()
  end
  _ARG_0_.bEnabled = false
end






function s060_quarantine.OnEnter_EnablePostPlasmaEnemies(_ARG_0_, _ARG_1_)
  local L2_2 = Game.GetActor("spawngroup_003")
  local L3_2 = Game.GetActor("SG_ChozoZombieX_000")
  local L4_2 = Game.GetActor("SG_GooShockerX_000")
  local L5_2 = Game.GetActor("SG_X_Cell_000")
  local L6_2 = Game.GetActor("TG_Disable_SG_X_Cell_000")
  
  if L6_2 ~= nil then
    L6_2.bEnabled = true
  end
  if L2_2 ~= nil then
    L2_2.SPAWNGROUP:EnableSpawnGroup()
  end
  if L3_2 ~= nil then
    L3_2.SPAWNGROUP:EnableSpawnGroup()
  end
  if L4_2 ~= nil then
    L4_2.SPAWNGROUP:EnableSpawnGroup()
  end
  if L5_2 ~= nil then
    L5_2.SPAWNGROUP:EnableSpawnGroup()
  end
  _ARG_0_.bEnabled = false
end





function s060_quarantine.Disable_SG_X_Cell(_ARG_0_, _ARG_1_)
  local oActor = Game.GetActor("SG_X_Cell_000")
  
  if oActor ~= nil then
    oActor.SPAWNGROUP:DisableSpawnGroup()
  end
  _ARG_0_.bEnabled = false
end




function s060_quarantine.ActivationTutoParasite()
  Game.AddSF(2.5, "s060_quarantine.ActivationTutoParasite_delayed", "")
end

function s060_quarantine.ActivationTutoParasite_delayed()
  local L0_2 = Game.GetActor("TutoParasiteEnter")
  local L1_2 = Game.GetActor("TutoParasiteExit")
  if L0_2 ~= nil and L1_2 ~= nil then
    L0_2.bEnabled = true
    L1_2.bEnabled = true
  end
end







function s060_quarantine.OnEnter_ChangeCamera_003_B()
  Game.SetCollisionCameraLocked("collision_camera_003_B", true)
  print("OnEnter_ChangeCamera_003_B")
end

function s060_quarantine.OnExit_ChangeCamera_003_B()
  Game.SetCollisionCameraLocked("collision_camera_003_B", false)
  print("OnExit_ChangeCamera_003_B")
end

function s060_quarantine.Disable_Camera_003_B()
  local oActor = Game.GetActor("TG_CameraChange_003_B")
  if oActor ~= nil then
    oActor.bEnabled = false
  end
end



function s060_quarantine.OnEnter_ChangeCamera_MBL()
  Game.SetCollisionCameraLocked("collision_camera_MBL", true)
end
function s060_quarantine.OnExit_ChangeCamera_MBL()
  Game.SetCollisionCameraLocked("collision_camera_MBL", false)
end

function s060_quarantine.OnEnter_ChangeSetup_MBL()
  Game.PushSetup("Camera_MBL", true, true)
end
function s060_quarantine.OnExit_ChangeSetup_MBL()
  Game.PopSetup("Camera_MBL", true, true)
end

function s060_quarantine.OnEnter_ChangeCamera_004_B()
  Game.SetCollisionCameraLocked("collision_camera_004_B", true)
end
function s060_quarantine.OnExit_ChangeCamera_004_B()
  Game.SetCollisionCameraLocked("collision_camera_004_B", false)
end

function s060_quarantine.OnUsablePrepareUse(actor)
  Scenario.DisableGlobalTeleport(actor)
end

function s060_quarantine.OnUsableCancelUse(actor)
  Scenario.ResetGlobalTeleport(actor)
end

function s060_quarantine.OnUsableUse(actor)
  if actor.sName == "wagontrain_forest_000" and Init.bDefaultXRelease then
    Game.SetXparasite(true)
    Blackboard.SetProp("GAME_PROGRESS", "QUARENTINE_OPENED", "b", true)
  end
  Scenario.SetTeleportalUsed(actor)
end
