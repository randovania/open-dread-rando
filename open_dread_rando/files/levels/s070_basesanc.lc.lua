function s070_basesanc.main()

  s070_basesanc.PatrolRoutesGeneration()
  s070_basesanc.PatrolRoutesFinalNodesAssignation()
  s070_basesanc.m_bSkipAquaOpening = false
end
s070_basesanc.HasRandomizerChanges = true

function s070_basesanc.SetupDebugGameBlackboard()

    
    
    
    
    
    
    
    
    
    
    
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_CURRENT_SPECIAL_ENERGY", "f", 1000)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_MAX_SPECIAL_ENERGY", "f", 1000)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_SPECIAL_ENERGY", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_CURRENT_LIFE", "f", 399)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_MAX_LIFE", "f", 399)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_MISSILE_MAX", "f", 38)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_MISSILE_CURRENT", "f", 38)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_SUPER_MISSILE", "f", 0)
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

function s070_basesanc.IsEmmiActive()
  return true
end


local QUARENTINE_OPENED = Blackboard.GetProp("GAME_PROGRESS", "QUARENTINE_OPENED")
local SANC_POSTXRELEASE_APPLIED = false
local CURRENT_CHOZOROBOT_SPAWNPOINT = "SP_Checkpoint_TwoChozoRobots"

function s070_basesanc.InitFromBlackboard()
    
  
  
  
  Game.ReinitPlayerFromBlackboard()
  SANC_POSTXRELEASE_APPLIED = Scenario.ReadFromBlackboard(Scenario.LUAPropIDs.SANC_POSTXRELEASE_APPLIED, false)
  QUARENTINE_OPENED = Blackboard.GetProp("GAME_PROGRESS", "QUARENTINE_OPENED")
  
  if QUARENTINE_OPENED == true then
    s070_basesanc.Activate_Setup_PostXRelease()
  end
  
  local L0_2 =  Game.GetActor("emmy_sanc_deactivated")
  if L0_2 ~= nil then
    if Scenario.ReadFromBlackboard(Scenario.LUAPropIDs.SANC_EMMY_DEACTIVATED_ENABLED, false) == true then
      L0_2.bEnabled = true
    else
      L0_2.bEnabled = false
    end
  end
end

function s070_basesanc.Activate_Setup_PostXRelease()
  if SANC_POSTXRELEASE_APPLIED == false then
    Game.PushSetup("PostXRelease", true, true)
    Scenario.WriteToBlackboard(Scenario.LUAPropIDs.SANC_POSTXRELEASE_APPLIED, "b", true)
    SANC_POSTXRELEASE_APPLIED = true
  end
end
s070_basesanc.tGetOnDeathOverrides = {
    ShowDeath = true, 
    GoToMainMenu = false
}
function s070_basesanc.GetOnDeathOverrides()
  return s070_basesanc.tGetOnDeathOverrides
end


function s070_basesanc.OnEntityGenerated(_ARG_0_, _ARG_1_)
  if _ARG_1_ ~= nil then
    print("OnEntityGenerated!!!!!!")
  end
end






function s070_basesanc.OnEnter_ChangeCamera_012_B()
  Game.SetCollisionCameraLocked("collision_camera_012_B", true)
  print("OnEnter_ChangeCamera_012_B")
end
function s070_basesanc.OnExit_ChangeCamera_012_B()
  Game.SetCollisionCameraLocked("collision_camera_012_B", false)
  print("OnExit_ChangeCamera_012_B")
end

function s070_basesanc.OnEnter_ChangeCamera_012_C()
  Game.SetCollisionCameraLocked("collision_camera_012_C", true)
  print("OnEnter_ChangeCamera_012_C")
end
function s070_basesanc.OnExit_ChangeCamera_012_C()
  Game.SetCollisionCameraLocked("collision_camera_012_C", false)
  print("OnExit_ChangeCamera_012_C")
end

function s070_basesanc.OnEnter_ChangeCamera_003_B()
  Game.SetCollisionCameraLocked("collision_camera_003_B", true)
  print("OnEnter_ChangeCamera_003_B")
end
function s070_basesanc.OnExit_ChangeCamera_003_B()
  Game.SetCollisionCameraLocked("collision_camera_003_B", false)
  print("OnExit_ChangeCamera_003_B")
end

function s070_basesanc.OnEnter_ChangeCamera_024_A()
  local oActor = Game.GetActor("TG_ChangeCamera_024_B")
  oActor.bEnabled = false
  print("OnEnter_ChangeCamera_024_A")
  Game.SetCollisionCameraLocked("collision_camera_024_A", true)
end
function s070_basesanc.OnEnter_ChangeCamera_024_A_Delayed()
  
  Game.GetActor("TG_ChangeCamera_024_A").bEnabled = true
end

function s070_basesanc.OnExit_ChangeCamera_024_A()
  Game.SetCollisionCameraLocked("collision_camera_024_A", false)
  print("OnExit_ChangeCamera_024_A")
  Game.AddSF(0, "s070_basesanc.OnEnter_ChangeCamera_024_B_Delayed", "")
end

function s070_basesanc.OnEnter_ChangeCamera_024_B()
  
  local oActor = Game.GetActor("TG_ChangeCamera_024_A")
  oActor.bEnabled = false
  Game.SetCollisionCameraLocked("collision_camera_024_B", true)
  print("OnEnter_ChangeCamera_024_B")
end
function s070_basesanc.OnEnter_ChangeCamera_024_B_Delayed()

  Game.GetActor("TG_ChangeCamera_024_B").bEnabled = true
end

function s070_basesanc.OnExit_ChangeCamera_024_B()
  Game.SetCollisionCameraLocked("collision_camera_024_B", false)
  print("OnExit_ChangeCamera_024_B")
  Game.AddSF(0, "s070_basesanc.OnEnter_ChangeCamera_024_A_Delayed", "")
end

function s070_basesanc.OnEnter_ChangeCamera_024_C()
  Game.SetCollisionCameraLocked("collision_camera_024_C", true)
end
function s070_basesanc.OnExit_ChangeCamera_024_C()
  Game.SetCollisionCameraLocked("collision_camera_024_C", false)
end

function s070_basesanc.OnEnter_ChangeCamera_030_B()
  Game.SetCollisionCameraLocked("collision_camera_030_B", true)
end
function s070_basesanc.OnExit_ChangeCamera_030_B()
  Game.SetCollisionCameraLocked("collision_camera_030_B", false)
end

function s070_basesanc.OnEnter_ChangeCamera_038_B()
  Game.SetCollisionCameraLocked("collision_camera_038_B", true)
end
function s070_basesanc.OnExit_ChangeCamera_038_B()
  Game.SetCollisionCameraLocked("collision_camera_038_B", false)
end




function s070_basesanc.AddProfessorDialogueToMissionLog()
  local L0_2 = {}
  
  for L4_2 = 1, 26, 1 do
    local L5_2 = string.format("%02d", L4_2)
    local L6_2 = "#CAPTION_PROFESSOREVENT_PAGE_" .. L5_2
    table.insert(L0_2, L6_2)
    if L4_2 == 5 or L4_2 == 11 then
      L6_2 = L6_2 .. "_B"
      table.insert(L0_2, L6_2)
    end
  end
  GUI.AddDialogMissionLogEntry(L0_2)
end

function s070_basesanc.OnAfter_Cutscene_40_Part1()

  if s070_basesanc.m_bSkipAquaOpening == false then
    local L0_2 = Game.GetActor("cutsceneplayer_40b_part1")
    if L0_2 ~= nil then
      local L1_2 = Game.GetCurrentCutsceneStr()
      local L2_2 = L0_2.CUTSCENE:GetCutscene().oDefinition.sId
      if L1_2 ~= L2_2 then
        L0_2.CUTSCENE:TryLaunchCutscene()
      end
    end
  end
  Game.SetAquaGateOpeningEventEndLUACallback("s070_basesanc.LaunchCutscene40_Part2b")
end

function s070_basesanc.OnSkip_Cutscene_40_Part1()

  s070_basesanc.m_bSkipAquaOpening = true
  local oActor = Game.GetActor("cutsceneplayer_40b_part1")
  if oActor ~= nil then
    oActor.CUTSCENE:LaunchCutsceneImmediate()
    oActor.CUTSCENE:SkipCutscene(true)
  end
end

function s070_basesanc.OnAfter_Cutscene_40_Part2a()
  Game.LaunchAquaGateOpening(s070_basesanc.m_bSkipAquaOpening)
end

function s070_basesanc.OnSkip_Cutscene_40_Part2a()
  s070_basesanc.m_bSkipAquaOpening = true
end

function s070_basesanc.LaunchCutscene40_Part2b(_ARG_0_)

  local oActor1 = Game.GetActor("cutsceneplayer_40b_part2")

  if oActor1 ~= nil then
    if _ARG_0_ == true then
      Game.SetSkippingQueuedCutscenes(true)
      local oActor2 = Game.GetActor("PRP_professor_death")
      if oActor2 ~= nil then
        oActor2:SetVisible(true)
      end
    end
    oActor1.CUTSCENE:GetCutscene():SetFadeInOnStart(false)
    oActor1.CUTSCENE:LaunchCutsceneImmediate()
    if _ARG_0_ == true then
      oActor1.CUTSCENE:SkipCutscene(true)
    end
  end
end

function s070_basesanc.OnBefore_Cutscene_40_Part2bStarted()    
  Game.SpawnEntity("SP_ChozoRobotSoldier")
  local oActor = Game.GetActor("CAM_ChozoRobotSoldier")
  
  if oActor ~= nil then
    oActor.LOGICCAMERA:GetLogicCamera().fMinExtraZDist = 2630
  end
end

function s070_basesanc.AddEmmyProfessorToMissionLog()
  GUI.AddEmmyMissionLogEntry("#MLOG_ENCOUNTER_EMMY_SANC")
  s070_basesanc.AddProfessorDialogueToMissionLog()
end

function s070_basesanc.OnAfter_Cutscene_40_Part2b()
  
  s070_basesanc.Professor_MET()
  s070_basesanc.m_bSkipAquaOpening = false
  Game.AddSF(0.5, "s070_basesanc.Delayed_RestoreRobotSoldierLogicCameraMinZ", "")
end

function s070_basesanc.Delayed_RestoreRobotSoldierLogicCameraMinZ()
  local oActor = Game.GetActor("CAM_ChozoRobotSoldier")
  if oActor ~= nil then
    oActor.LOGICCAMERA:GetLogicCamera().fMinExtraZDist = 1630
  end
end



function s070_basesanc.OnBossDeath(_ARG_0_)


  if _ARG_0_ == "SP_ChozoRobotSoldier_chozorobotsoldier" then
    Game.AddSF(2.5, "s070_basesanc.Delayed_Professor_CUT", "")

    local oActor1 = Game.GetActor("doorpowerpower_002")
    if oActor1 ~= nil then
      oActor1.LIFE:LockDoor()
    end

    local oActor2 = Game.GetActor("emmy_sanc_deactivated")
    if oActor2 ~= nil then
      oActor2.bEnabled = true
      Scenario.WriteToBlackboard(Scenario.LUAPropIDs.SANC_EMMY_DEACTIVATED_ENABLED, "b", true)
      oActor2:SetVisible(true)
    end
  end
end


function s070_basesanc.Delayed_Professor_CUT()
  local oActor1 =Game.GetActor("cutsceneplayer_40c")
  if oActor1 ~= nil then
    oActor1.CUTSCENE:LaunchCutscene()
  end

  s070_basesanc.TryUnlockProfessorDoor()

  Game.RemoveBossCameraCtrl()
end

local try_unlocking = false
function s070_basesanc.TryUnlockProfessorDoor()
  try_unlocking = true
  s070_basesanc._TryUnlockProfessorDoor()
end

function s070_basesanc._TryUnlockProfessorDoor()
  if not try_unlocking then return end

  local oActor2 = Game.GetActor("doorpowerpower_002")
  if oActor2 ~= nil then
    oActor2.LIFE:UnLockDoor()
  end

  Game.AddSF(1, "s070_basesanc._TryUnlockProfessorDoor", "")
end


function s070_basesanc.OnAfter_Cutscene_40_Part3()

end


function s070_basesanc.Professor_MET()
  Blackboard.SetProp("GAME_PROGRESS", "PROFESSOR_MET", "b", true)
end





function s070_basesanc.OnBeforeGenerate()
end


function s070_basesanc.OnEmmyBaseSancGenerated(_ARG_0_, _ARG_1_)

end


function s070_basesanc.OnCentralUnitEmmyReady(_ARG_0_, _ARG_1_)
  CurrentScenario.oEmmyEntity = _ARG_1_
  AI.SetWorldGraphToEmmy("LE_WorldGraph", _ARG_1_.sName)
  s070_basesanc.ChangePatrolEmmy("PATROLROUTE_01")
  print("EMMY: Generation OK. Starting patrol: " .. _ARG_1_.AI.sCurrentPatrol)

  local L2_2 = s070_basesanc.IsEmmiActive()
  if L2_2 == true and CurrentScenario.oEmmyEntity.AI.bTargetInsideEmmyZone then
    print("QUARANTINE IS OPENED")
  else
    CurrentScenario.oEmmyEntity.bEnabled = false
    print("QUARANTINE IS NOT OPENED")
  end
end





function s070_basesanc.OnEmmySancDead()
  Game.PushSetup("PostEmmy", true, true)
  
  
  
  
  
  
  
  
  
  
end

function s070_basesanc.OnEmmyAbilityObtainedFadeOutCompleted()
  Game.GetActor("TG_EnablePostEmmyEnemies").bEnabled = true
  
  local L0_2 = Game.GetActor("centralunitmagmacontroller")
  if L0_2 ~= nil then
    L0_2.CENTRALUNIT:OnEmmyAbilityObtainedFadeOutCompleted()
  end
end


function s070_basesanc.DelayedOnEmmySancDead()

  GUI.ShowMessage("#PLACEHOLDER_WAVEBEAM_OBTAINED", true, "")
  local oPlayer = Game.GetPlayer()
  if oPlayer ~= nil then
    oPlayer.INPUT:IgnoreInput(false, false, "OnEmmySancDead")
  end
end


function s070_basesanc.OnEmmyDeathMessageSkipped()
end


function s070_basesanc.OnUnlockEmmyDoors()

  local oActor = Game.GetActor("centralunitmagmacontroller")
  if oActor ~= nil then
    oActor.CENTRALUNIT:UnlockDoors()
  else
    print("CENTRAL_UNIT: centralunitmagmacontroller not found")
  end
end






function s070_basesanc.PatrolRoutesGeneration()
  
  
  
  
  
  
  
  
  
  local oEmmy = Game.GetActor("SP_Emmy") 
  if oEmmy ~= nil then
    oEmmy.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_01")
    oEmmy.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_02")
    oEmmy.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_03")
    oEmmy.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_05")
    oEmmy.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_06")
    oEmmy.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_07")
    oEmmy.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_08")
    oEmmy.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_10")
    oEmmy.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_11")
  end
  AI.AddPatrol("LE_WorldGraph", "PATROLROUTE_01", "LS_PATROLEMMY_01")
  AI.AddPatrol("LE_WorldGraph", "PATROLROUTE_02", "LS_PATROLEMMY_02")
  AI.AddPatrol("LE_WorldGraph", "PATROLROUTE_03", "LS_PATROLEMMY_03")
  AI.AddPatrol("LE_WorldGraph", "PATROLROUTE_05", "LS_PATROLEMMY_05")
  AI.AddPatrol("LE_WorldGraph", "PATROLROUTE_06", "LS_PATROLEMMY_06")
  AI.AddPatrol("LE_WorldGraph", "PATROLROUTE_07", "LS_PATROLEMMY_07")
  AI.AddPatrol("LE_WorldGraph", "PATROLROUTE_08", "LS_PATROLEMMY_08")
  AI.AddPatrol("LE_WorldGraph", "PATROLROUTE_10", "LS_PATROLEMMY_10")
  AI.AddPatrol("LE_WorldGraph", "PATROLROUTE_11", "LS_PATROLEMMY_11")
  print("s070_basesanc.PatrolRoutesGeneration(): Patrol designation OK")
end


function s070_basesanc.PatrolRoutesFinalNodesAssignation()











  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_01", { "WorldGraph_1" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_01", { "WorldGraph_4" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_02", { "WorldGraph_1" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_02", { "WorldGraph_6" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_03", { "WorldGraph_8", "WorldGraph_10" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_03", { "WorldGraph_6", "WorldGraph_7" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_05", { "WorldGraph_12" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_05", { "WorldGraph_20" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_06", { "WorldGraph_12" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_06", { "WorldGraph_16" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_07", { "WorldGraph_18" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_07", { "WorldGraph_23" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_07", { "WorldGraph_27", "WorldGraph_28" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_07", { "WorldGraph_29" }, 2)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_08", { "WorldGraph_31" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_08", { "WorldGraph_25" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_08", { "WorldGraph_36" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_10", { "WorldGraph_40" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_10", { "WorldGraph_44" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_11", { "WorldGraph_46", "WorldGraph_78", "WorldGraph_51" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_11", { "WorldGraph_49" }, 1)
  print("s070_basesanc.PatrolRoutesFinalNodesAssignation(): Final Nodes Assignation OK")
end




function s070_basesanc.ChangePatrolEmmy(_ARG_0_)
  if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
    CurrentScenario.oEmmyEntity.AI.sCurrentPatrol = _ARG_0_
    print("EMMY: Assigned route " .. _ARG_0_)
  else
    print("EMMY: Not found, route " .. _ARG_0_ .. " not assigned")
  end
end

function s070_basesanc.OnEnter_PatrolEmmyActivator(_ARG_0_, _ARG_1_)
  local sName = string.gsub(_ARG_0_.sName, "TG_PATROLEMMYACTIVATOR_", "PATROLROUTE_")
  s070_basesanc.ChangePatrolEmmy(sName)
end

function s070_basesanc.OnExit_PatrolEmmyActivator(_ARG_0_, _ARG_1_)

end





s070_basesanc.tEmmyDoor = nil
function s070_basesanc.OnWalkThroughEmmyDoor(_ARG_0_, _ARG_1_, _ARG_2_)


  local L3_2 = s070_basesanc.IsEmmiActive()
  if L3_2 == true and Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
    local L4_2 = Game.GetActor("emmy_sanc_deactivated")

    if L4_2 ~= nil then
      L4_2.bEnabled = false
      Scenario.WriteToBlackboard(Scenario.LUAPropIDs.SANC_EMMY_DEACTIVATED_ENABLED, "b", false)
    end

    if _ARG_1_ then
      if CurrentScenario.oEmmyEntity ~= nil then

        if _ARG_2_ then
          sTeleportLandmark =  s070_basesanc.HardEmmyRelocationDoor(_ARG_0_)
        else
          sTeleportLandmark = s070_basesanc.EmmyRelocationDoor(_ARG_0_)
        end

        if sTeleportLandmark ~= nil then
          local L5_2 = Game.GetActor(sTeleportLandmark)
          print(L5_2.sName)
          CurrentScenario.oEmmyEntity.bEnabled = false
          CurrentScenario.oEmmyEntity.vPos = L5_2.vPos
          CurrentScenario.oEmmyEntity.vAng = L5_2.vAng
          CurrentScenario.oEmmyEntity.bEnabled = true
        end

      end
    else
      CurrentScenario.oEmmyEntity.bEnabled = false
    end
  end

  local L4_2 = Game.GetActor("TG_EmmyZipline004Behavior")
  if L4_2 ~= nil then
    L4_2.bEnabled = false
  end
end

function s070_basesanc.HardEmmyRelocationDoor(_ARG_0_)








  print("Door: Hard " .. _ARG_0_.sName)
  if _ARG_0_.sName == "dooremmy_002" then
    s070_basesanc.tEmmyDoor = {
      "LM_EmmyEntrancePoint_005"
    }
  elseif _ARG_0_.sName == "dooremmy_003" then
    s070_basesanc.tEmmyDoor = {
      "LM_EmmyEntrancePoint_011"
    }
  elseif _ARG_0_.sName == "dooremmy_004" then
    s070_basesanc.tEmmyDoor = {
      "LM_EmmyEntrancePoint_008"
    }
  elseif _ARG_0_.sName == "dooremmy_005" then
    s070_basesanc.tEmmyDoor = {
      "LM_EmmyEntrancePoint_006"
    }
  elseif _ARG_0_.sName == "dooremmy_006" then
    s070_basesanc.tEmmyDoor = {
      "LM_EmmyEntrancePoint_012"
    }
  elseif _ARG_0_.sName == "dooremmy_008" then
    s070_basesanc.tEmmyDoor = {
      "LM_EmmyEntrancePoint_017",
      "LM_EmmyEntrancePoint_014"
    }
  else
    s070_basesanc.tEmmyDoor = nil
  end
  if s070_basesanc.tEmmyDoor ~= nil then
    return s070_basesanc.tEmmyDoor[math.random(table.maxn(s070_basesanc.tEmmyDoor))]
  else
    return nil
  end
end

function s070_basesanc.EmmyRelocationDoor(_ARG_0_)








  if _ARG_0_.sName == "dooremmy_002" then
    s070_basesanc.tEmmyDoor = {
      "LM_EmmyEntrancePoint_003",
      "LM_EmmyEntrancePoint_005"
    }
  elseif _ARG_0_.sName == "dooremmy_003" then
    s070_basesanc.tEmmyDoor = {
      "LM_EmmyEntrancePoint_010",
      "LM_EmmyEntrancePoint_011"
    }
  elseif _ARG_0_.sName == "dooremmy_004" then
    s070_basesanc.tEmmyDoor = {
      "LM_EmmyEntrancePoint_008",
      "LM_EmmyEntrancePoint_009"
    }
  elseif _ARG_0_.sName == "dooremmy_005" then
    s070_basesanc.tEmmyDoor = {
      "LM_EmmyEntrancePoint_005",
      "LM_EmmyEntrancePoint_006",
      "LM_EmmyEntrancePoint_007"
    }
  elseif _ARG_0_.sName == "dooremmy_006" then
    s070_basesanc.tEmmyDoor = {
      "LM_EmmyEntrancePoint_012",
      "LM_EmmyEntrancePoint_013",
      "LM_EmmyEntrancePoint_014"
    }
  elseif _ARG_0_.sName == "dooremmy_008" then
    s070_basesanc.tEmmyDoor = {
      "LM_EmmyEntrancePoint_017",
      "LM_EmmyEntrancePoint_014"
    }
  else
    s070_basesanc.tEmmyDoor = nil
  end
  if s070_basesanc.tEmmyDoor ~= nil then
    return s070_basesanc.tEmmyDoor[math.random(table.maxn(s070_basesanc.tEmmyDoor))]
  else
    return nil
  end
end




function s070_basesanc.OnEnter_EmmyRelocated_Phase2()
  
  
  
  if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) and CurrentScenario.oEmmyEntity ~= nil then
    local oActor = Game.GetActor("LM_EmmyLocation_Phase2")
    CurrentScenario.oEmmyEntity.bEnabled = false
    CurrentScenario.oEmmyEntity.vPos = oActor.vPos
    CurrentScenario.oEmmyEntity.vAng = oActor.vAng
    CurrentScenario.oEmmyEntity.bEnabled = true
  end
end






s070_basesanc.bFootStepPlatform000Opened = true
s070_basesanc.bFootStepPlatform001Opened = true
function s070_basesanc.OnShutterOpened(_ARG_0_)
  
  
  local L1_2 = s070_basesanc.bFootStepPlatform000Opened == false and s070_basesanc.bFootStepPlatform001Opened == false
  
  if _ARG_0_.sName == "footstepplatform_000" then
    s070_basesanc.bFootStepPlatform000Opened = true
  elseif _ARG_0_.sName == "footstepplatform_001" then
    s070_basesanc.bFootStepPlatform001Opened = true
  end

  
  local L2_2 = s070_basesanc.bFootStepPlatform000Opened == false and s070_basesanc.bFootStepPlatform001Opened == false
  if L1_2 == true and L2_2 == false and CurrentScenario.oEmmyEntity ~= nil and Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
      CurrentScenario.oEmmyEntity.AI:StopSancShutterPerceptionModifier()
  end
end

function s070_basesanc.OnShutterClosed(_ARG_0_)



  if _ARG_0_.sName == "footstepplatform_000" then
    s070_basesanc.bFootStepPlatform000Opened = false
  elseif _ARG_0_.sName == "footstepplatform_001" then
    s070_basesanc.bFootStepPlatform001Opened = false
  end

  local L1_2 = s070_basesanc.bFootStepPlatform000Opened == false and s070_basesanc.bFootStepPlatform001Opened == false
  if L1_2 and CurrentScenario.oEmmyEntity ~= nil and Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
    CurrentScenario.oEmmyEntity.AI:StartSancShutterPerceptionModifier("LS_EmmyTrap", "LM_EmmyTrap")
  end
end





function s070_basesanc.OnEnterEmmyZipline004Activator()
  local oActor = Game.GetActor("TG_EmmyZipline004Behavior")
  if oActor ~= nil then
    oActor.bEnabled = true
  end
end

function s070_basesanc.OnEnterEmmyZipline004Behavior()


  if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
    CurrentScenario.oEmmyEntity.AI.bZipLine004Behavior = true
  end
end

function s070_basesanc.OnExitEmmyZipline004Behavior()


  if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
    CurrentScenario.oEmmyEntity.AI.bZipLine004Behavior = false
  end
end





function s070_basesanc.RobotSnapshotToCheckpoint()
  Game.SaveSnapshotToCheckpoint("Checkpoint_Pre_ChozoRobots", "Checkpoint_Pre_ChozoRobots", CURRENT_CHOZOROBOT_SPAWNPOINT, true)
  print("guardo snapshot")
end

function s070_basesanc.OnEnter_SnapshotRobots_BottomRight()
  CURRENT_CHOZOROBOT_SPAWNPOINT = "SP_Checkpoint_TwoChozoRobots"
  print("actualizo startpoint:" .. CURRENT_CHOZOROBOT_SPAWNPOINT)
end

function s070_basesanc.OnEnter_SnapshotRobots_TopRight()
  CURRENT_CHOZOROBOT_SPAWNPOINT = "SP_Checkpoint_TwoChozoRobots_TopRight"
  print("actualizo startpoint:" .. CURRENT_CHOZOROBOT_SPAWNPOINT)
end

function s070_basesanc.OnEnter_SnapshotRobots_BottomLeft()
  CURRENT_CHOZOROBOT_SPAWNPOINT = "SP_Checkpoint_TwoChozoRobots_BottomLeft"
  print("actualizo startpoint:" .. CURRENT_CHOZOROBOT_SPAWNPOINT)
end

function s070_basesanc.OnEnter_SnapshotRobots_TopLeft()
  CURRENT_CHOZOROBOT_SPAWNPOINT = "SP_Checkpoint_TwoChozoRobots_TopLeft"
  print("actualizo startpoint:" .. CURRENT_CHOZOROBOT_SPAWNPOINT)
end

function s070_basesanc.CheckChozoRobots_State()
  local L0_2 = Blackboard.GetProp("PLAYER_INVENTORY", "ITEM_MULTILOCKON")
  if L0_2 ~= nil and L0_2 > 0 then
    local L1_2 = Game.GetActor("SG_2ChozoRobots")
    if L1_2 ~= nil then
      print(L1_2.SPAWNGROUP.iNumDeaths)
      if L1_2.SPAWNGROUP.iNumDeaths > 1 then
        Game.PopSetup("Post2ChozoRobots", true, true)
      else
        Game.PushSetup("2ChozoRobots", true, true)
      end
    end
  end
end

function s070_basesanc.CloseShutter(_ARG_0_, _ARG_1_)
  local oActor1 = Game.GetActor("doorshutter_000")
  local oActor2 = Game.GetActor("doorshutter_001")
  local oActor3 = Game.GetActor("doorshutter_002")
  local oActor4 = Game.GetActor("doorshutter_003")
  if oActor1 ~= nil then
    oActor1.LIFE:LockDoor()
  end
  if oActor2 ~= nil then
    oActor2.LIFE:LockDoor()
  end
  if oActor3 ~= nil then
    oActor3.LIFE:LockDoor()
  end
  if oActor4 ~= nil then
    oActor4.LIFE:LockDoor()
  end
  _ARG_0_.bEnabled = false
end


function s070_basesanc.OnEnter_PresentationCRS(_ARG_0_, _ARG_1_)
  local oActor = Game.GetActor("SG_2ChozoRobots")
  if oActor ~= nil then
    oActor.SPAWNGROUP:EnableSpawnGroup()
  end
  _ARG_0_.bEnabled = false
end

function s070_basesanc.OpenShutter()
  local oActor1 = Game.GetActor("doorshutter_000")
  local oActor2 = Game.GetActor("doorshutter_001")
  local oActor3 = Game.GetActor("doorshutter_002")
  local oActor4 = Game.GetActor("doorshutter_003")
  if oActor1 ~= nil then
    oActor1.LIFE:UnLockDoor()
  end
  if oActor2 ~= nil then
    oActor2.LIFE:UnLockDoor()
  end
  if oActor3 ~= nil then
    oActor3.LIFE:UnLockDoor()
  end
  if oActor4 ~= nil then
    oActor4.LIFE:UnLockDoor()
  end
end







function s070_basesanc.CRS_DetectingDirection()
  local oActor = Game.GetActor("SP_ChozoRobotSoldier_000_chozorobotsoldier")
  if oActor ~= nil then
    s070_basesanc.CRS_EvaluatingDirection(oActor)
  end
end

function s070_basesanc.CRS_DetectingDirection_B()
  local oActor = Game.GetActor("SP_ChozoRobotSoldier_001_chozorobotsoldier")
  if oActor ~= nil then
    s070_basesanc.CRS_EvaluatingDirection(oActor)
  end
end

function s070_basesanc.CRS_EvaluatingDirection(_ARG_0_)
  
  print( "----- DETECTING DIRECTION -----")
  if _ARG_0_ ~= nil then
    local L1_2 = Game.GetPlayer()
    local L2_2 = V3D(-1, 0, 0)
    if L1_2 ~= nil then
      L2_2 = L1_2.vPos - _ARG_0_.vPos
    end
    if L2_2.x > 0 then
      print("----- TURN RIGHT -----")
      _ARG_0_.ANIMATION:SetAction("spawn_front_turn_right", true)
      L2_2 = V3D(1, 0, 0)
    else
      print("----- TURN LEFT -----")
      _ARG_0_.ANIMATION:SetAction("spawn_front_turn_left", true)
      L2_2 = V3D(-1, 0, 0)
    end
  end
end







function s070_basesanc.OnEnter_AP_08()
  Scenario.CheckRandoHint("accesspoint_000", "SANC_1")
end

function s070_basesanc.OnUsableFinishInteract(_ARG_0_)
  if _ARG_0_.sName == "accesspoint_000" then
    Scenario.SetRandoHintSeen()
  end
end

function s070_basesanc.OnUsablePrepareUse(actor)
  Scenario.DisableGlobalTeleport(actor)
end

function s070_basesanc.OnUsableCancelUse(actor)
  Scenario.ResetGlobalTeleport(actor)
end

function s070_basesanc.OnUsableUse(actor)
  Scenario.SetTeleportalUsed(actor)
end




function s070_basesanc.SubAreaChangeRequest(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_)
  Scenario.SubAreaChangeRequest(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_)
end


function s070_basesanc.OnSubAreaChange(old_subarea, old_actorgroup, new_subarea, new_actorgroup, disable_fade)












  -- lock door to professor room before meeting him the first time
  local arena_door = Game.GetActor("doorpowerpower_002")
  if new_subarea == "collision_camera_004" then
    if arena_door ~= nil then
      if Blackboard.GetProp("GAME_PROGRESS", "PROFESSOR_MET") then
        arena_door.LIFE:UnLockDoor()
      else
        arena_door.LIFE:LockDoor()
      end
    end
  end

  if old_subarea == "collision_camera_005" and new_subarea == "collision_camera_004" then
    try_unlocking = false
  end

  local L5_2 = Game.GetActor("SG_2ChozoRobots")
  if old_subarea == "collision_camera_005" and old_actorgroup == "Default" then
    Game.PushSetup("PostChozoRobotSoldier_Arena", true, true)
  end

  if new_subarea == "collision_camera_005" and new_actorgroup == "Default" then
    Game.PushSetup("PostChozoRobotSoldier", true, true)
  end

  if old_subarea == "collision_camera_027" and old_actorgroup == "PostSuperQuetzoaDead" then
    Game.PushSetup("PostSuperQuetzoaArena", true, true)
  end

  if old_subarea == "collision_camera_017" and old_actorgroup == "2ChozoRobots" and L5_2 ~= nil then
    print(L5_2.SPAWNGROUP.iNumDeaths)

    if L5_2.SPAWNGROUP.iNumDeaths > 1 then
      Game.PopSetup("2ChozoRobots", true, true)
      Game.PushSetup("Post2ChozoRobots", false, true)
    end
  end
end






function s070_basesanc.ActivateGooShockers()
  Game.PushSetup("PostSuperQuetzoa", true, true)
end






function s070_basesanc.OnEnter_PostSuperQuetzoaEnemies(_ARG_0_, _ARG_1_)
  local oActor = Game.GetActor("SG_PostSuperQuetzoa")
  if oActor ~= nil then
    oActor.SPAWNGROUP:EnableSpawnGroup()
  end
  _ARG_0_.bEnabled = false
end
















function s070_basesanc.OnEnter_ActivatePostEmmyEnemies(_ARG_0_, _ARG_1_)
  local oActor = Game.GetActor("SG_PostEmmy_000")
  if oActor ~= nil then
    oActor.SPAWNGROUP:EnableSpawnGroup()
  end
  _ARG_0_.bEnabled = false
end





function s070_basesanc.Post_SuperQuetzoa_Dead(_ARG_0_, _ARG_1_)
  Game.PopSetup("SP_SuperQuetzoa_CoreX_core_x_superquetzoa_Boss_Defeated", false, false)
  Game.PushSetup("PostSuperQuetzoaDead", true, false)
end

function s070_basesanc.OnEnter_MusicChange_SpaceJump(_ARG_0_, _ARG_1_)
  Game.PushSetup("SpaceJump", true, false)
end

function s070_basesanc.OnExit_MusicChange_SpaceJump(_ARG_0_, _ARG_1_)
  Game.PopSetup("SpaceJump", true, false)
end

function s070_basesanc.OnEnter_MusicChange_SpaceJumpWater(_ARG_0_, _ARG_1_)
  Game.PushSetup("SpaceJumpWater", true, false)
end

function s070_basesanc.OnExit_MusicChange_SpaceJumpWater(_ARG_0_, _ARG_1_)
  Game.PopSetup("SpaceJumpWater", true, false)
end




function s070_basesanc.cutsceneplayer_40_full()
  local L0_2 = Game.GetActor("cutsceneplayer_40")
  if L0_2 ~= nil then
    local L1_2 = Game.GetActor("cutsceneplayer_40b_part1")
    if L1_2 ~= nil then
      L0_2.CUTSCENE:QueueCutscenePlayer(L1_2)
      local L2_2 = Game.GetActor("cutsceneplayer_40b_part2")
      if L2_2 ~= nil then
        L1_2.CUTSCENE:QueueCutscenePlayer(L2_2)
        local L3_2 = Game.GetActor("cutsceneplayer_40c")
        if L3_2 ~= nil then
          L2_2.CUTSCENE:QueueCutscenePlayer(L3_2)
        end
      end
    end
  end
end
