function s050_forest.main()
  s050_forest.PatrolRoutesGeneration()
  s050_forest.PatrolRoutesFinalNodesAssignation()
end


function s050_forest.SetupDebugGameBlackboard()

    
    
  
    
 
    
    
    
    
    
    
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_CURRENT_SPECIAL_ENERGY", "f", 1000)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_MAX_SPECIAL_ENERGY", "f", 1000)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_SPECIAL_ENERGY", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_CURRENT_LIFE", "f", 499)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_MAX_LIFE", "f", 499)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_MISSILE_MAX", "f", 52)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_MISSILE_CURRENT", "f", 52)
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







local QUARENTINE_OPENED = Blackboard.GetProp("GAME_PROGRESS", "QUARENTINE_OPENED")
local FOREST_POSTXRELEASE_APPLIED = false
function s050_forest.InitFromBlackboard()
    
    

  Game.ReinitPlayerFromBlackboard()
  FOREST_POSTXRELEASE_APPLIED = Scenario.ReadFromBlackboard(Scenario.LUAPropIDs.FOREST_POSTXRELEASE_APPLIED, false)
  QUARENTINE_OPENED = Blackboard.GetProp("GAME_PROGRESS", "QUARENTINE_OPENED")
  if QUARENTINE_OPENED == true then
    s050_forest.Activate_Setup_PostXRelease()
  end
end

function s050_forest.Activate_Setup_PostXRelease()
  if FOREST_POSTXRELEASE_APPLIED == false then
    Game.PushSetup("PostXRelease", true, true)
    Scenario.WriteToBlackboard(Scenario.LUAPropIDs.FOREST_POSTXRELEASE_APPLIED, "b", true)
    FOREST_POSTXRELEASE_APPLIED = true
  end
end
s050_forest.tGetOnDeathOverrides = {
    ShowDeath = true, 
    GoToMainMenu = false
}
function s050_forest.GetOnDeathOverrides()
  return s050_forest.tGetOnDeathOverrides
end


function s050_forest.OnEntityGenerated(_ARG_0_, _ARG_1_)
  if _ARG_1_ ~= nil then
    print("OnEntityGenerated!!!!!!")
  end
end

function s050_forest.SonarObtained()
  local oActor = Game.GetActor("powerup_sonar")
  if oActor ~= nil then
    oActor.PICKABLE:OnPickUpAfterCutScene()
  end
end





function s050_forest.OnEnter_trigger_LineBoomObtained(_ARG_0_, _ARG_1_)
    
    

  _ARG_0_.bEnabled = false
  Game.AddSF(1, "s050_forest.DelayedLineBoomObtined", "")
  local oPlayer = Game.GetPlayer()
  if oPlayer ~= nil then
    oPlayer.INPUT:IgnoreInput(true, false, "OnEnter_trigger_LineBoomObtained")
  end
end


function s050_forest.DelayedLineBoomObtined()
    
    
    
  GUI.ShowMessage("#CUT_LINE_BOMB", true, "s050_forest.LineBoomObtainedMessageSkipped")
  local oPlayer = Game.GetPlayer()
  if oPlayer ~= nil then
    oPlayer.INPUT:IgnoreInput(false, false, "OnEnter_trigger_LineBoomObtained")
  end
end


function s050_forest.LineBoomObtainedMessageSkipped()
  local oPlayer = Game.GetPlayer()
  if oPlayer ~= nil then
    oPlayer.INVENTORY:SetItemAmount("ITEM_WEAPON_LINE_BOMB", 1, true)
  end
end




function s050_forest.OnEnter_trigger_BossPresentation(_ARG_0_, _ARG_1_)
    
    
    
  _ARG_0_.bEnabled = false
  Game.AddSF(1, "s050_forest.DelayedBossPresentation", "")
  local oPlayer = Game.GetPlayer()
  if oPlayer ~= nil then
    oPlayer.INPUT:IgnoreInput(true, false, "OnEnter_trigger_BossPresentation")
  end
end


function s050_forest.DelayedBossPresentation()
    
    

  GUI.ShowMessage("#CUT_FOREST_BOSS_PRESENTATION", true, "s050_forest.BossPresentationMessageSkipped")
  local oPlayer = Game.GetPlayer()
  if oPlayer ~= nil then
    oPlayer.INPUT:IgnoreInput(false, false, "OnEnter_trigger_BossPresentation")
  end
end


function s050_forest.BossPresentationMessageSkipped()
    
end







function s050_forest.OnEnter_ChangeCamera_003_B()
  Game.SetCollisionCameraLocked("collision_camera_003_B", true)
end
function s050_forest.OnExit_ChangeCamera_003_B()
  Game.SetCollisionCameraLocked("collision_camera_003_B", false)
end

function s050_forest.OnEnter_ChangeCamera_003_C()
  Game.SetCollisionCameraLocked("collision_camera_003_C", true)
end
function s050_forest.OnExit_ChangeCamera_003_C()
  Game.SetCollisionCameraLocked("collision_camera_003_C", false)
end

function s050_forest.OnEnter_ChangeCamera_019_B()
  Game.PushSetup("ChangeCamera_019_B", false, true)
end
function s050_forest.OnExit_ChangeCamera_019_B()
  Game.PopSetup("ChangeCamera_019_B", false, true)
end

function s050_forest.OnEnter_ChangeCamera_023_B()
  Game.SetCollisionCameraLocked("collision_camera_023_B", true)
end
function s050_forest.OnExit_ChangeCamera_023_B()
  Game.SetCollisionCameraLocked("collision_camera_023_B", false)
end

function s050_forest.OnEnter_ChangeCamera_024_B()
  Game.PushSetup("ChangeCamera_024_B", false, true)
end
function s050_forest.OnExit_ChangeCamera_024_B()
  Game.PopSetup("ChangeCamera_024_B", false, true)
end

function s050_forest.OnEnter_ChangeCamera_025_B()
  Game.PushSetup("ChangeCamera_025_B", false, true)
end
function s050_forest.OnExit_ChangeCamera_025_B()
  Game.PopSetup("ChangeCamera_025_B", false, true)
end

function s050_forest.OnEnter_ChangeCamera_025_C()
  Game.PushSetup("ChangeCamera_025_C", false, true)
end
function s050_forest.OnExit_ChangeCamera_025_C()
  Game.PopSetup("ChangeCamera_025_C", false, true)
end

function s050_forest.OnEnter_TG_camera_ZoomIn_On(_ARG_0_, _ARG_1_)
  _ARG_0_.bEnabled = false
  Game.PushSetup("ZoomIn_Magnet", true, true)
  local oActor = Game.GetActor("trigger_camera_ZoomIn_off")
  if oActor ~= nil then
    oActor.bEnabled = true
  end
end

function s050_forest.OnEnter_TG_camera_ZoomIn_Off(_ARG_0_, _ARG_1_)
  _ARG_0_.bEnabled = false
  Game.PopSetup("ZoomIn_Magnet", true, true)
end

function s050_forest.OnEnter_PostSuperGoliathDefeated()
  Game.PopSetup("SuperGoliath_CoreX_Env", true)
  Game.PushSetup("goliath_Boss_Defeated", true)
  Game.GetActor("TG_PreBossCheckpoint_SuperGoliath").bEnabled = false
  Game.GetActor("TG_Checkpoint_SuperGoliath").bEnabled = false
end

function s050_forest.OnBossDefeated(_ARG_0_)
    
    
  if _ARG_0_ ~= nil and _ARG_0_ == "SP_SuperGoliath_CoreX_core_x" then
    Game.PopSetup("SP_Goliath_B_goliath_Fake_Boss_Defeated", true, false)
  end
end



function s050_forest.OnEnter_AP_07()
  Scenario.CheckRandoHint("accesspoint_000", "FOREST_1")
end

function s050_forest.OnUsableFinishInteract(_ARG_0_)
  if _ARG_0_.sName == "accesspoint_000" then
    Scenario.SetRandoHintSeen()
  end
end





function s050_forest.SubAreaChangeRequest(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_)   
  Scenario.SubAreaChangeRequest(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_)
end


function s050_forest.OnSubAreaChange(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_)
    
    
    
    
    
    
    
    
    
    

  if _ARG_0_ == "collision_camera_039" and _ARG_2_ == "collision_camera_032" then
    s050_forest.LaunchCutscene_33()
  end
  
  if _ARG_0_ == "collision_camera_002" and _ARG_1_ == "Default" then
    local L5_2 = Game.GetActor("SG_ChozoRobotSoldier")
    if L5_2 ~= nil then
      print(L5_2.SPAWNGROUP.iNumDeaths)
      if L5_2.SPAWNGROUP.iNumDeaths > 0 then
        Game.PushSetup("PostChozoRobotSoldier", true, true)
      end
    end
  end
  
  if _ARG_0_ == "collision_camera_023" and _ARG_1_ == "ChozoWarriorX" then
    local L5_2 = Game.GetActor( "SG_ChozoWarriorX")
    if L5_2 ~= nil then
      print(L5_2.SPAWNGROUP.iNumDeaths)
      if L5_2.SPAWNGROUP.iNumDeaths > 0 then
        Game.PopSetup("ChozoWarriorX", true, true)
        Game.PushSetup("PostChozoWarriorX", false, true)
      end
    end
  end
end

function s050_forest.LaunchCutscene_33()
  local oActor = Game.GetActor("cutsceneplayer_33") 
  if oActor ~= nil then
    oActor.CUTSCENE:TryLaunchCutscene()
  end
end













Scenario.AddFadeTransition("collision_camera_024", "Default", "collision_camera_031", "Default", "Fade")
function s050_forest.OnBeforeGenerate()
end


function s050_forest.OnEmmyForestGenerated(_ARG_0_, _ARG_1_)
  CurrentScenario.oEmmyEntity = _ARG_1_
  AI.SetWorldGraphToEmmy("LE_WorldGraph", _ARG_1_.sName)
  s050_forest.ChangePatrolEmmy("PATROLROUTE_03")
  print("EMMY: Generation OK. Starting patrol: " .. _ARG_1_.AI.sCurrentPatrol)
  if QUARENTINE_OPENED == true then
    print("QUARANTINE IS OPENED")
  else
    CurrentScenario.oEmmyEntity.bEnabled = false
    print("QUARANTINE IS NOT OPENED")
  end
end

function s050_forest.AddForestEmmyToMissionLog()
  GUI.AddEmmyMissionLogEntry("#MLOG_ENCOUNTER_EMMY_FOREST")
end





function s050_forest.OnEmmyForestDead()
    
    
    
    
    
    
    
    
    
  Game.PushSetup("PostEmmy", true, true)
end

function s050_forest.OnEmmyAbilityObtainedFadeOutCompleted()
  
  Game.GetActor("TG_EnablePostEmmyEnemies").bEnabled = true
  local oActor = Game.GetActor("centralunitmagmacontroller")
  if oActor ~= nil then
    oActor.CENTRALUNIT:OnEmmyAbilityObtainedFadeOutCompleted()
  end
end


function s050_forest.DelayedOnEmmyForestDead()

  GUI.ShowMessage("#CUT_ICE_MISSILE", true, "")
  local oPlayer = Game.GetPlayer()
  if oPlayer ~= nil then
    oPlayer.INPUT:IgnoreInput(false, false, "OnEmmyForestDead")
  end
end


function s050_forest.OnEmmyDeathMessageSkipped()
end


function s050_forest.OnUnlockEmmyDoors()
  
  local oActor = Game.GetActor("centralunitmagmacontroller")
  if oActor ~= nil then
    oActor.CENTRALUNIT:UnlockDoors()
  else
    print("CENTRAL_UNIT: centralunitmagmacontroller not found")
  end
end






function s050_forest.PatrolRoutesGeneration()
    
    
    
    
    
    
  local oEmmy = Game.GetActor("SP_Emmy")
  if oEmmy ~= nil then
    oEmmy.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_01")
    oEmmy.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_02")
    oEmmy.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_03")
    oEmmy.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_04")
    oEmmy.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_05")
    oEmmy.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_06")
    oEmmy.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_07")
    oEmmy.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_08")
    oEmmy.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_09")
    oEmmy.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_10")
  end
  AI.AddPatrol("LE_WorldGraph", "PATROLROUTE_01", "LS_PATROLEMMY_01")
  AI.AddPatrol("LE_WorldGraph", "PATROLROUTE_02", "LS_PATROLEMMY_02")
  AI.AddPatrol("LE_WorldGraph", "PATROLROUTE_03", "LS_PATROLEMMY_03")
  AI.AddPatrol("LE_WorldGraph", "PATROLROUTE_04", "LS_PATROLEMMY_04")
  AI.AddPatrol("LE_WorldGraph", "PATROLROUTE_05", "LS_PATROLEMMY_05")
  AI.AddPatrol("LE_WorldGraph", "PATROLROUTE_06", "LS_PATROLEMMY_06")
  AI.AddPatrol("LE_WorldGraph", "PATROLROUTE_07", "LS_PATROLEMMY_07")
  AI.AddPatrol("LE_WorldGraph", "PATROLROUTE_08", "LS_PATROLEMMY_08")
  AI.AddPatrol("LE_WorldGraph", "PATROLROUTE_09", "LS_PATROLEMMY_09")
  AI.AddPatrol("LE_WorldGraph", "PATROLROUTE_10", "LS_PATROLEMMY_10")
  print("s050_forest.PatrolRoutesGeneration(): Patrol designation OK")
end


function s050_forest.PatrolRoutesFinalNodesAssignation()
    
    
    
    
    
    
    
    
    
    
    
    
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_01", { "WorldGraph_0", "WorldGraph_2" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_01", { "WorldGraph_11", "WorldGraph_6" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_02", { "WorldGraph_10", "WorldGraph_12" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_02", { "WorldGraph_1", "WorldGraph_11" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_03", { "WorldGraph_10", "WorldGraph_1" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_03", { "WorldGraph_9", "WorldGraph_12" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_04", { "WorldGraph_16", "WorldGraph_14" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_04", { "WorldGraph_15", "WorldGraph_13" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_04", { "WorldGraph_11", "WorldGraph_12" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_05", { "WorldGraph_13" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_05", { "WorldGraph_14" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_05", { "WorldGraph_15" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_06", { "WorldGraph_42", "WorldGraph_12" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_06", { "WorldGraph_16", "WorldGraph_14" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_06", { "WorldGraph_12", "WorldGraph_19" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_07", { "WorldGraph_17", "WorldGraph_21" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_07", { "WorldGraph_18", "WorldGraph_41", "WorldGraph_23" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_08", { "WorldGraph_26" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_08", { "WorldGraph_27" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_08", { "WorldGraph_24" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_09", { "WorldGraph_25", "WorldGraph_29" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_09", { "WorldGraph_26", "WorldGraph_31" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_09", { "WorldGraph_48", "WorldGraph_24" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_10", { "WorldGraph_39", "WorldGraph_32" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_10", { "WorldGraph_40", "WorldGraph_34" }, 1)
  print("s050_forest.PatrolRoutesFinalNodesAssignation(): Final Nodes Assignation OK")
end




function s050_forest.ChangePatrolEmmy(_ARG_0_)
  if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
    CurrentScenario.oEmmyEntity.AI.sCurrentPatrol = _ARG_0_
    print("EMMY: Assigned route " .. _ARG_0_)
  else
    print("EMMY: Not found, route " .. _ARG_0_ .. " not assigned")
  end
end

function s050_forest.OnEnter_PatrolEmmyActivator(_ARG_0_, _ARG_1_)
  local sName = string.gsub(_ARG_0_.sName, "TG_PATROLEMMYACTIVATOR_", "PATROLROUTE_")
  s050_forest.ChangePatrolEmmy(sName)
end

function s050_forest.OnExit_PatrolEmmyActivator(_ARG_0_, _ARG_1_)

end






s050_forest.tEmmyDoor = nil
function s050_forest.OnWalkThroughEmmyDoor(_ARG_0_, _ARG_1_, _ARG_2_)
    
    
    
    
  if QUARENTINE_OPENED == true and Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
    if _ARG_1_ then
      if CurrentScenario.oEmmyEntity ~= nil then
        if _ARG_2_ then
          sTeleportLandmark = s050_forest.HardEmmyRelocationDoor(_ARG_0_)
        else
          sTeleportLandmark = s050_forest.EmmyRelocationDoor(_ARG_0_)
        end
        if sTeleportLandmark ~= nil then
          local oActor = Game.GetActor(sTeleportLandmark)
          print(oActor.sName)
          CurrentScenario.oEmmyEntity.bEnabled = false
          CurrentScenario.oEmmyEntity.vPos = oActor.vPos
          CurrentScenario.oEmmyEntity.vAng = oActor.vAng
          CurrentScenario.oEmmyEntity.bEnabled = true
        end
      end
    else
      CurrentScenario.oEmmyEntity.bEnabled = false
    end
  end
end

function s050_forest.HardEmmyRelocationDoor(_ARG_0_)
    
    
    
    
    
    
    
    
    
    
    
  print("Door: Hard " .. _ARG_0_.sName)
  if _ARG_0_.sName == "dooremmy" then
    s050_forest.tEmmyDoor = {
      "LM_EmmyEntrancePoint_019"
    }
  elseif _ARG_0_.sName == "dooremmy_000" then
    s050_forest.tEmmyDoor = {
      "LM_EmmyEntrancePoint_004"
    }
  elseif _ARG_0_.sName == "dooremmy_001" then
    s050_forest.tEmmyDoor = {
      "LM_EmmyEntrancePoint_003"
    }
  elseif _ARG_0_.sName == "dooremmy_002" then
    s050_forest.tEmmyDoor = {
      "LM_EmmyEntrancePoint_006"
    }
  elseif _ARG_0_.sName == "dooremmy_003" then
    s050_forest.tEmmyDoor = {
      "LM_EmmyEntrancePoint_005",
      "LM_EmmyEntrancePoint_006",
      "LM_EmmyEntrancePoint_010"
    }
  elseif _ARG_0_.sName == "dooremmy_004" then
    s050_forest.tEmmyDoor = {
      "LM_EmmyEntrancePoint_011"
    }
  elseif _ARG_0_.sName == "dooremmy_005" then
    s050_forest.tEmmyDoor = {
      "LM_EmmyEntrancePoint_011",
      "LM_EmmyEntrancePoint_010",
      "LM_EmmyEntrancePoint_019"
    }
  elseif _ARG_0_.sName == "dooremmy_006" then
    s050_forest.tEmmyDoor = {
      "LM_EmmyEntrancePoint_015"
    }
  elseif _ARG_0_.sName == "dooremmy_007" then
    s050_forest.tEmmyDoor = {
      "LM_EmmyEntrancePoint_015"
    }
  else
    s050_forest.tEmmyDoor = nil
  end
  if s050_forest.tEmmyDoor ~= nil then
    return s050_forest.tEmmyDoor[math.random(table.maxn(s050_forest.tEmmyDoor))]
  else
    return nil
  end
end

function s050_forest.EmmyRelocationDoor(_ARG_0_)
  
  
  
  
  
  
  
  
  
  
  
  if _ARG_0_.sName == "dooremmy" then
    s050_forest.tEmmyDoor = {
      "LM_EmmyEntrancePoint_012",
      "LM_EmmyEntrancePoint_013",
      "LM_EmmyEntrancePoint_019",
      "LM_EmmyEntrancePoint_020"
    }
  elseif _ARG_0_.sName == "dooremmy_000" then
    s050_forest.tEmmyDoor = {
      "LM_EmmyEntrancePoint_018",
      "LM_EmmyEntrancePoint_003",
      "LM_EmmyEntrancePoint_004"
    }
  elseif _ARG_0_.sName == "dooremmy_001" then
    s050_forest.tEmmyDoor = {
      "LM_EmmyEntrancePoint_000",
      "LM_EmmyEntrancePoint_002"
    }
  elseif _ARG_0_.sName == "dooremmy_002" then
    s050_forest.tEmmyDoor = {
      "LM_EmmyEntrancePoint_004",
      "LM_EmmyEntrancePoint_005"
    }
  elseif _ARG_0_.sName == "dooremmy_003" then
    s050_forest.tEmmyDoor = {
      "LM_EmmyEntrancePoint_005",
      "LM_EmmyEntrancePoint_006",
      "LM_EmmyEntrancePoint_010"
    }
  elseif _ARG_0_.sName == "dooremmy_004" then
    s050_forest.tEmmyDoor = {
      "LM_EmmyEntrancePoint_004",
      "LM_EmmyEntrancePoint_008"
    }
  elseif _ARG_0_.sName == "dooremmy_005" then
    s050_forest.tEmmyDoor = {
      "LM_EmmyEntrancePoint_010",
      "LM_EmmyEntrancePoint_011",
      "LM_EmmyEntrancePoint_019"
    }
  elseif _ARG_0_.sName == "dooremmy_006" then
    s050_forest.tEmmyDoor = {
      "LM_EmmyEntrancePoint_015",
      "LM_EmmyEntrancePoint_016",
      "LM_EmmyEntrancePoint_017"
    }
  elseif _ARG_0_.sName == "dooremmy_007" then
    s050_forest.tEmmyDoor = {
      "LM_EmmyEntrancePoint_015"
    }
  else
    s050_forest.tEmmyDoor = nil
  end
  if s050_forest.tEmmyDoor ~= nil then
    return s050_forest.tEmmyDoor[math.random(table.maxn(s050_forest.tEmmyDoor))]
  else
    return nil
  end
end




function s050_forest.OnTeleport_Checkpoint_CU()
  Game.AddSF(1, "s050_forest.Checkpoint_RelocatingEmmy_CU", "")
end

function s050_forest.Checkpoint_RelocatingEmmy_CU()
    
    
    
  if CurrentScenario.oEmmyEntity ~= nil then
    local oActor = Game.GetActor("LM_EmmyEntrancePoint_017")
    if oActor ~= nil then
      CurrentScenario.oEmmyEntity.bEnabled = false
      CurrentScenario.oEmmyEntity.vPos = oActor.vPos
      CurrentScenario.oEmmyEntity.vAng = oActor.vAng
      CurrentScenario.oEmmyEntity.bEnabled = true
      s050_forest.ChangePatrolEmmy("PATROLROUTE_10")
    end
  end
end






function s050_forest.OnEnter_Enable_ChozoWarriorX(_ARG_0_, _ARG_1_)
  local oActor = Game.GetActor("SG_PostDoubleJump")
  _ARG_0_.bEnabled = false
  Game.PushSetup("ChozoWarriorX", true, true)
  if oActor ~= nil then
    oActor.SPAWNGROUP:EnableSpawnGroup()
  end
end






function s050_forest.OnEnter_Enable_Trigger_AfterCWX()
    
  Game.GetActor("TG_AfterChozoWarriorXEncounter").bEnabled = true
end






function s050_forest.OnEnter_Disable_PostChozoWarriorSetup(_ARG_0_, _ARG_1_)
  _ARG_0_.bEnabled = false
  Game.PopSetup("PostChozoWarriorX", true, true)
end




function s050_forest.StartEmmyWeightedEdges()
  if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
    CurrentScenario.oEmmyEntity.AI:StartWeightedEdges()
  end
end

function s050_forest.StopEmmyWeightedEdges()
  if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
    CurrentScenario.oEmmyEntity.AI:StopWeightedEdges()
  end
end




function s050_forest.OnEnter_ChangeMusic_SuperMissile()
  Game.PushSetup("ChangeMusic_010_StatueRoom", true, true)
end
function s050_forest.OnExit_ChangeMusic_SuperMissile()
  Game.PopSetup("ChangeMusic_010_StatueRoom", true, true)
end





function s050_forest.OnEnter_ActivatePostEmmyEnemies(_ARG_0_, _ARG_1_)
  local oActor1 = Game.GetActor("SG_PostEmmy_000")
  local oActor2 = Game.GetActor("SG_PostEmmy_001")
  local oActor3 = Game.GetActor("SG_PostEmmy_002")
  local oActor4 = Game.GetActor("SG_PostEmmy_003")
  if oActor1 ~= nil then
    oActor1.SPAWNGROUP:EnableSpawnGroup()
  end
  if oActor2 ~= nil then
    oActor2.SPAWNGROUP:EnableSpawnGroup()
  end
  if oActor3 ~= nil then
    oActor3.SPAWNGROUP:EnableSpawnGroup()
  end
  if oActor4 ~= nil then
    oActor4.SPAWNGROUP:EnableSpawnGroup()
  end
  _ARG_0_.bEnabled = false
end






function s050_forest.OnEnter_ActivateArenaSpawngroup(_ARG_0_, _ARG_1_)
  local oActor = Game.GetActor("SG_Gooplot_000")
  if oActor ~= nil then
    oActor.SPAWNGROUP:EnableSpawnGroup()
  end
  _ARG_0_.bEnabled = false
end






function s050_forest.OnEnter_PostSuperGoliath(_ARG_0_, _ARG_1_)
  local oActor = Game.GetActor("SG_PostSuperGoliath_000")
  if oActor ~= nil then
    oActor.SPAWNGROUP:EnableSpawnGroup()
  end
  _ARG_0_.bEnabled = false
end





function s050_forest.Enter_CWX_Arena()

  local oActor = Game.GetActor("LM_EnteringCWXArena")
  local oPlayer = Game.GetPlayer()
  if oPlayer ~= nil and oActor ~= nil then
    oPlayer.INPUT:IgnoreInput(true, false, "Enter_CWX_Arena")
    oPlayer.ANIMATION:SetAction("fall", true)
    oPlayer.vPos = oActor.vPos
    oPlayer.vAng = oActor.vAng
    Game.ForceConvertToSamus()
  end
end

function s050_forest.Exit_CWX_Arena()
  
  local oPlayer = Game.GetPlayer()
  if oPlayer ~= nil then
    oPlayer.INPUT:IgnoreInput(false, false, "Enter_CWX_Arena")
  end
end






function s050_forest.LockDoorSuperGoliathArena(_ARG_0_, _ARG_1_)
  local oActor = Game.GetActor("doorpowerclosed_003")
  if oActor ~= nil then
    oActor.LIFE:LockDoor()
  end
  _ARG_0_.bEnabled = false
end







function s050_forest.OnEnter_Presentation_ChozoRobotSoldier(_ARG_0_, _ARG_1_)
  local oActor = Game.GetActor("SG_ChozoRobotSoldier")
  if oActor ~= nil then
    oActor.SPAWNGROUP:EnableSpawnGroup()
  end
  Game.GetActor("TG_ActivateArenaSpawngroup").bEnabled = true
  _ARG_0_.bEnabled = false
end






function s050_forest.CRS_DetectingDirection()
  print("----- DETECTING DIRECTION -----")
  local L0_2 = Game.GetActor("SP_ChozoRobotSoldier_chozorobotsoldier")
  if L0_2 ~= nil then
    local L1_2 = Game.GetPlayer()
    local L2_2 = V3D(-1, 0, 0)
    if L1_2 ~= nil then
      L2_2 = L1_2.vPos - L0_2.vPos
    end
    if L2_2.x > 0 then
      print("----- TURN RIGHT -----")
      L0_2.ANIMATION:SetAction("spawn_front_turn_right", true)
      L2_2 = V3D(1, 0, 0)
    else
      print("----- TURN LEFT -----")
      L0_2.ANIMATION:SetAction("spawn_front_turn_left", true)
      L2_2 = V3D(-1, 0, 0)
    end
  end
end
