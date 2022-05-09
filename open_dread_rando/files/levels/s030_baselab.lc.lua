

function s030_baselab.main()
  s030_baselab.PatrolRoutesGeneration()
  s030_baselab.PatrolRoutesFinalNodesAssignation()
end



function s030_baselab.SetupDebugGameBlackboard()
    
    
    
    
    
    
    
    
    
    
    
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_CURRENT_SPECIAL_ENERGY", "f", 1000)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_MAX_SPECIAL_ENERGY", "f", 1000)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_SPECIAL_ENERGY", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_CURRENT_LIFE", "f", 299)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_MAX_LIFE", "f", 299)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_MISSILE_MAX", "f", 22)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_MISSILE_CURRENT", "f", 22)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_SUPER_MISSILE", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_ICE_MISSILE", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_POWER_BOMB", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_POWER_BOMB_MAX", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_POWER_BOMB_CURRENT", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_VARIA_SUIT", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_GRAVITY_SUIT", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_DOUBLE_JUMP", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_SPACE_JUMP", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_SCREW_ATTACK", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_FLOOR_SLIDE", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_MORPH_BALL", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_BOMB", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_LINE_BOMB", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_CHARGE_BEAM", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_WIDE_BEAM", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_DIFFUSION_BEAM", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_GRAPPLE_BEAM", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_PLASMA_BEAM", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_WAVE_BEAM", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_MAGNET_GLOVE", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_SPEED_BOOSTER", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_OPTIC_CAMOUFLAGE", "f", 1)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_GHOST_AURA", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_SONAR", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_METROIDNIZATION", "f", 0)
end

local QUARENTINE_OPENED = Blackboard.GetProp("GAME_PROGRESS", "QUARENTINE_OPENED")
local LAB_EMMY_SPAWNED = false
local LAB_POSTXRELEASE_APPLIED = false
local L3_1 = false

if s030_baselab.sRandoBlackoutPropID == nil then
  s030_baselab.sRandoBlackoutPropID = Blackboard.RegisterLUAProp("RANDO_BLACKOUT", "bool")
end



function s030_baselab.InitFromBlackboard()

 
    
 Game.ReinitPlayerFromBlackboard()
  LAB_EMMY_SPAWNED = Scenario.ReadFromBlackboard(Scenario.LUAPropIDs.LAB_EMMY_SPAWNED, false)
  LAB_POSTXRELEASE_APPLIED = Scenario.ReadFromBlackboard(Scenario.LUAPropIDs.LAB_POSTXRELEASE_APPLIED, false)
  QUARENTINE_OPENED = Blackboard.GetProp("GAME_PROGRESS", "QUARENTINE_OPENED")
  s030_baselab.OnEnter_EmmyLAB_Presentation()

  if QUARENTINE_OPENED == true then
    s030_baselab.Activate_Setup_PostXRelease()
  end
end

function s030_baselab.Activate_Setup_PostXRelease()
  if LAB_POSTXRELEASE_APPLIED == false then
    Game.PushSetup("PostXRelease", true, true)
    Scenario.WriteToBlackboard(Scenario.LUAPropIDs.LAB_POSTXRELEASE_APPLIED, "b", true)
    LAB_POSTXRELEASE_APPLIED = true
  end
end
s030_baselab.tGetOnDeathOverrides = {ShowDeath = true, GoToMainMenu = false}



function s030_baselab.GetOnDeathOverrides()
  return s030_baselab.tGetOnDeathOverrides
end









function s030_baselab.OnBeforeGenerate()
end


function s030_baselab.OnEmmyBaseLabGenerated(_ARG_0_, _ARG_1_)
  CurrentScenario.oEmmyEntity = _ARG_1_
  AI.SetWorldGraphToEmmy("LE_WorldGraph", _ARG_1_.sName)
  s030_baselab.ChangePatrolEmmy("PATROLROUTE_01")
  print("EMMY: Generation OK. Starting patrol: " .. _ARG_1_.AI.sCurrentPatrol)
end





function s030_baselab.OnEnter_EmmyLAB_Deactivation()
    

  if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) and CurrentScenario.oEmmyEntity ~= nil then
    CurrentScenario.oEmmyEntity.bEnabled = false
    print("EMMY DESACTIVADO")
  end
end

function s030_baselab.OnEnter_EmmyLAB_Presentation()
    
    
    
  
    
  
    
  print("ACTIVANDO EMMY")
  --GUI.AddEmmyMissionLogEntry("#MLOG_ENCOUNTER_EMMY_LAB")
  local oActor = Game.GetActor("TG_EmmyLAB_Deactivation") 
  if oActor ~= nil then
    oActor.bEnabled = false
  end
  Scenario.WriteToBlackboard(Scenario.LUAPropIDs.LAB_EMMY_SPAWNED, "b", true)
  LAB_EMMY_SPAWNED = true
  --if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) and CurrentScenario.oEmmyEntity ~= nil then
  --  local oActor = Game.GetActor("LM_EmmyPresentation")
  --  CurrentScenario.oEmmyEntity.bEnabled = false
  --  CurrentScenario.oEmmyEntity.vPos = oActor.vPos
  --  CurrentScenario.oEmmyEntity.vAng = oActor.vAng
  --  CurrentScenario.oEmmyEntity.bEnabled = true
  --  print("EMMY REACTIVADO")
  --end
  --local oShutter = Game.GetActor("doorshutter_001")
  --if oShutter ~= nil then
  --  oShutter.ANIMATION:SetAction("opened", true)
  --end
end

function s030_baselab.EmmyLabSpawnSequenceEnd()
  if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
    CurrentScenario.oEmmyEntity.AI:ForceStartChase()
  end
end



function s030_baselab.DelayedEmmyLABSpawnSequence()
    
    
    
    
    
  GUI.ShowMessage("#BASELAB_EMMY_PRESENTATION", true, "")
  local oPlayer = Game.GetPlayer()
  if oPlayer ~= nil then
    oPlayer.INPUT:IgnoreInput(false, false, "OnEnter_EmmyLAB_Presentation")
  end
  if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) and CurrentScenario.oEmmyEntity ~= nil then
    local oActor = Game.GetActor("LM_EmmyPresentation")
    CurrentScenario.oEmmyEntity.bEnabled = false
    CurrentScenario.oEmmyEntity.vPos = oActor.vPos
    CurrentScenario.oEmmyEntity.vAng = oActor.vAng
    CurrentScenario.oEmmyEntity.bEnabled = true
    print("EMMY REACTIVADO")
  end
end





function s030_baselab.OnEmmyBaseLabDead()
    
    
    
    
    
    
    
    
    
  Game.PushSetup("PostEmmy", true, true)
end

function s030_baselab.OnEmmyAbilityObtainedFadeOutCompleted()
    
  Game.GetActor("TG_EnablePostEmmyEnemies").bEnabled = true
  local oActor = Game.GetActor("centralunitmagmacontroller") 
  if oActor ~= nil then
    oActor.CENTRALUNIT:OnEmmyAbilityObtainedFadeOutCompleted()
  end
end


function s030_baselab.DelayedOnEmmyBaseLabDead()
    
  GUI.ShowMessage("#PLACEHOLDER_EMMYBASELAB_KILLED", true, "")
  local oPlayer = Game.GetPlayer()
  if oPlayer ~= nil then
    oPlayer.INPUT:IgnoreInput(false, false, "OnEmmyBaseLabDead")
  end
end


function s030_baselab.OnEmmyDeathMessageSkipped()

end


function s030_baselab.OnUnlockEmmyDoors()
    
  local oActor = Game.GetActor("centralunitmagmacontroller")
  if oActor ~= nil then
    oActor.CENTRALUNIT:UnlockDoors()
  else
    print("CENTRAL_UNIT: centralunitmagmacontroller not found")
  end
end



function s030_baselab.OnUnlockEmmyDoors()
    
  local oActor = Game.GetActor("centralunitmagmacontroller")
  if oActor ~= nil then
    oActor.CENTRALUNIT:UnlockDoors()
  else
    print("CENTRAL_UNIT: centralunitbaselabcontroller not found")
  end
end


function s030_baselab.OnLockEmmyDoors()
    
  local oActor = Game.GetActor("centralunitmagmacontroller")
  if oActor ~= nil then
    oActor.CENTRALUNIT:LockDoors()
  else
    print("CENTRAL_UNIT: centralunitbaselabcontroller not found")
  end
end


function s030_baselab.OnCheckpoint_SpeedBooster()
  s030_baselab.OnLockEmmyDoors()
end




function s030_baselab.PatrolRoutesGeneration()
    
    
    
    
    
    
  local oActor = Game.GetActor("SP_Emmy")
  if oActor ~= nil then
    oActor.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_01")
    oActor.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_02")
    oActor.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_03")
    oActor.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_04")
    oActor.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_05")
    oActor.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_06")
    oActor.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_07")
    oActor.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_08")
    oActor.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_09")
    oActor.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_10")
    oActor.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_11")
    oActor.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_12")
    oActor.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_13")
    oActor.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_14")
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
  AI.AddPatrol("LE_WorldGraph", "PATROLROUTE_11", "LS_PATROLEMMY_11")
  AI.AddPatrol("LE_WorldGraph", "PATROLROUTE_12", "LS_PATROLEMMY_12")
  AI.AddPatrol("LE_WorldGraph", "PATROLROUTE_13", "LS_PATROLEMMY_13")
  AI.AddPatrol("LE_WorldGraph", "PATROLROUTE_14", "LS_PATROLEMMY_14")
  print("s030_baselab.PatrolRoutesGeneration(): Patrol designation OK")
end


function s030_baselab.PatrolRoutesFinalNodesAssignation()
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_01", { "WorldGraph_21" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_01", { "WorldGraph_16", "WorldGraph_15" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_02", { "WorldGraph_5", "WorldGraph_11" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_02", { "WorldGraph_21" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_03", { "WorldGraph_22", "WorldGraph_24" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_03", { "WorldGraph_26" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_04", { "WorldGraph_57", "WorldGraph_56" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_04", { "WorldGraph_30", "WorldGraph_31" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_05", { "WorldGraph_56", "WorldGraph_38" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_05", { "WorldGraph_46" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_06", { "WorldGraph_46", "WorldGraph_47" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_06", { "WorldGraph_56" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_06", { "WorldGraph_31", "WorldGraph_35" }, 2)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_06", { "WorldGraph_55" }, 3)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_07", { "WorldGraph_65" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_07", { "WorldGraph_56" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_08", { "WorldGraph_60" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_08", { "WorldGraph_72" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_09", { "WorldGraph_60" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_09", { "WorldGraph_81" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_10", { "WorldGraph_75" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_10", { "WorldGraph_81" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_11", { "WorldGraph_1" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_11", { "WorldGraph_11" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_11", { "WorldGraph_17" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_12", { "WorldGraph_100", "WorldGraph_98" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_12", { "WorldGraph_94", "WorldGraph_93" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_12", { "WorldGraph_87", "WorldGraph_84" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_12", { "WorldGraph_85", "WorldGraph_86" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_13", { "WorldGraph_109" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_14", { "WorldGraph_109" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_14", { "WorldGraph_117" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_14", { "WorldGraph_115" }, 2)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_14", { "WorldGraph_111", "WorldGraph_112" }, 3)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_14", { "WorldGraph_101" }, 4)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_14", { "WorldGraph_107", "WorldGraph_105" }, 5)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_14", { "WorldGraph_104" }, 6)
  print("s030_baselab.PatrolRoutesFinalNodesAssignation(): Final Nodes Assignation OK")
end




function s030_baselab.ChangePatrolEmmy(_ARG_0_)
  if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
    CurrentScenario.oEmmyEntity.AI.sCurrentPatrol = _ARG_0_
    print("EMMY: Assigned route " .. _ARG_0_)
  else
    print("EMMY: Not found, route " .. _ARG_0_ .. " not assigned")
  end
end

function s030_baselab.OnEnter_PatrolEmmyActivator(_ARG_0_, _ARG_1_)
  local sName = string.gsub(_ARG_0_.sName, "TG_PATROLEMMYACTIVATOR_", "PATROLROUTE_")
  s030_baselab.ChangePatrolEmmy(sName)
end

function s030_baselab.OnExit_PatrolEmmyActivator(_ARG_0_, _ARG_1_)

end





function s030_baselab.OnEnter_EmmySpawnAfterAqua()
    
    

  if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) and CurrentScenario.oEmmyEntity ~= nil then
    L3_1 = true
    local oActor = Game.GetActor("LM_EmmySpawnAfterAqua")
    CurrentScenario.oEmmyEntity.bEnabled = false
    CurrentScenario.oEmmyEntity.vPos = oActor.vPos
    CurrentScenario.oEmmyEntity.vAng = oActor.vAng
    CurrentScenario.oEmmyEntity.bEnabled = true
    s030_baselab.ChangePatrolEmmy("PATROLROUTE_13")
  end
end







s030_baselab.tEmmyDoor = nil
function s030_baselab.OnWalkThroughEmmyDoor(_ARG_0_, _ARG_1_, _ARG_2_)
    

  if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) and LAB_EMMY_SPAWNED then
    if _ARG_1_ then
      if CurrentScenario.oEmmyEntity ~= nil then
        local L3_2 = nil
        if _ARG_2_ then
          L3_2 = s030_baselab.HardEmmyRelocationDoor(_ARG_0_)
        else
          L3_2 = s030_baselab.EmmyRelocationDoor(_ARG_0_)
        end
        if L3_2 ~= nil then
          local L4_2 = Game.GetActor(L3_2)
          print(L4_2.sName)
          CurrentScenario.oEmmyEntity.bEnabled = false
          CurrentScenario.oEmmyEntity.vPos = L4_2.vPos
          CurrentScenario.oEmmyEntity.vAng = L4_2.vAng
          CurrentScenario.oEmmyEntity.bEnabled = true
        end
      end
    else
      CurrentScenario.oEmmyEntity.bEnabled = false
    end
  end
end

function s030_baselab.HardEmmyRelocationDoor(_ARG_0_)
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
  print("Door: Hard " .. _ARG_0_.sName)
  if _ARG_0_.sName == "dooremmy_000" then
    s030_baselab.tEmmyDoor = {
      "LM_EmmyEntrancePoint_000"
    }
  elseif _ARG_0_.sName == "dooremmy_001" then
    s030_baselab.tEmmyDoor = {
      "LM_EmmyEntrancePoint_004"
    }
  elseif _ARG_0_.sName == "dooremmy_003" then
    s030_baselab.tEmmyDoor = {
      "LM_EmmyEntrancePoint_010"
    }
  elseif _ARG_0_.sName == "dooremmy_004" then
    s030_baselab.tEmmyDoor = {
      "LM_EmmyEntrancePoint_010"
    }
  elseif _ARG_0_.sName == "dooremmy_005" then
    s030_baselab.tEmmyDoor = {
      "LM_EmmyEntrancePoint_015"
    }
  elseif _ARG_0_.sName == "dooremmy_006" then
    s030_baselab.tEmmyDoor = {
      "LM_EmmyEntrancePoint_016"
    }
  elseif _ARG_0_.sName == "dooremmy_008" then
    s030_baselab.tEmmyDoor = {
      "LM_EmmyEntrancePoint_022"
    }
  elseif _ARG_0_.sName == "dooremmy_009" then
    s030_baselab.tEmmyDoor = {
      "LM_EmmyEntrancePoint_021"
    }
  elseif _ARG_0_.sName == "dooremmy_010" then
    s030_baselab.tEmmyDoor = {
      "LM_EmmyEntrancePoint_026"
    }
  elseif _ARG_0_.sName == "dooremmy_012" then
    if L3_1 then
      L3_1 = false
      return "nil"
    else
      s030_baselab.tEmmyDoor = {
        "LM_EmmyEntrancePoint_027"
      }
    end
  else
    s030_baselab.tEmmyDoor = nil
  end
  if s030_baselab.tEmmyDoor ~= nil then
    return s030_baselab.tEmmyDoor[math.random(table.maxn(s030_baselab.tEmmyDoor))]
  else
    return nil
  end
end

function s030_baselab.EmmyRelocationDoor(_ARG_0_)
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
  if _ARG_0_.sName == "dooremmy_000" then
    s030_baselab.tEmmyDoor = {
      "LM_EmmyEntrancePoint_000",
      "LM_EmmyEntrancePoint_001",
      "LM_EmmyEntrancePoint_002",
      "LM_EmmyEntrancePoint_006"
    }
  elseif _ARG_0_.sName == "dooremmy_001" then
    s030_baselab.tEmmyDoor = {
      "LM_EmmyEntrancePoint_003",
      "LM_EmmyEntrancePoint_005",
      "LM_EmmyEntrancePoint_007"
    }
  elseif _ARG_0_.sName == "dooremmy_003" then
    s030_baselab.tEmmyDoor = {
      "LM_EmmyEntrancePoint_012",
      "LM_EmmyEntrancePoint_010"
    }
  elseif _ARG_0_.sName == "dooremmy_004" then
    s030_baselab.tEmmyDoor = {
      "LM_EmmyEntrancePoint_010",
      "LM_EmmyEntrancePoint_011",
      "LM_EmmyEntrancePoint_013"
    }
  elseif _ARG_0_.sName == "dooremmy_005" then
    s030_baselab.tEmmyDoor = {
      "LM_EmmyEntrancePoint_023",
      "LM_EmmyEntrancePoint_015",
      "LM_EmmyEntrancePoint_017"
    }
  elseif _ARG_0_.sName == "dooremmy_006" then
    s030_baselab.tEmmyDoor = {
      "LM_EmmyEntrancePoint_015",
      "LM_EmmyEntrancePoint_016",
      "LM_EmmyEntrancePoint_020"
    }
  elseif _ARG_0_.sName == "dooremmy_008" then
    s030_baselab.tEmmyDoor = {
      "LM_EmmyEntrancePoint_022",
      "LM_EmmyEntrancePoint_021",
      "LM_EmmyEntrancePoint_024"
    }
  elseif _ARG_0_.sName == "dooremmy_009" then
    s030_baselab.tEmmyDoor = {
      "LM_EmmyEntrancePoint_021",
      "LM_EmmyEntrancePoint_022"
    }
  elseif _ARG_0_.sName == "dooremmy_010" then
    s030_baselab.tEmmyDoor = {
      "LM_EmmyEntrancePoint_025",
      "LM_EmmyEntrancePoint_026"
    }
  elseif _ARG_0_.sName == "dooremmy_012" then
    if L3_1 then
      L3_1 = false
      return "nil"
    else
      s030_baselab.tEmmyDoor = {
        "LM_EmmyEntrancePoint_027",
        "LM_EmmyEntrancePoint_028",
        "LM_EmmyEntrancePoint_029"
      }
    end
  else
    s030_baselab.tEmmyDoor = nil
  end
  if s030_baselab.tEmmyDoor ~= nil then
    return s030_baselab.tEmmyDoor[math.random(table.maxn(s030_baselab.tEmmyDoor))]
  else
    return nil
  end
end




function s030_baselab.OnTeleport_Checkpoint_CU()
  Game.AddSF(1, "s030_baselab.Checkpoint_RelocatingEmmy_CU", "")
end

function s030_baselab.Checkpoint_RelocatingEmmy_CU()
    
  if CurrentScenario.oEmmyEntity ~= nil then 
   local oActor = Game.GetActor("LM_EmmyEntrancePoint_027") 
   if oActor ~= nil then
      CurrentScenario.oEmmyEntity.bEnabled = false
      CurrentScenario.oEmmyEntity.vPos = oActor.vPos
      CurrentScenario.oEmmyEntity.vAng = oActor.vAng
      CurrentScenario.oEmmyEntity.bEnabled = true
      s030_baselab.ChangePatrolEmmy("PATROLROUTE_12")
   end
  end
end




function s030_baselab.OnEnter_AP_04()
  Scenario.CheckRandoHint("accesspoint_000", "LAB_1")
end

function s030_baselab.OnEnter_AP_06()
  Scenario.CheckRandoHint("accesspoint_001", "LAB_2")
end

function s030_baselab.OnUsableFinishInteract(_ARG_0_)
  if _ARG_0_.sName == "accesspoint_000" or _ARG_0_.sName == "accesspoint_001" then
    Scenario.SetRandoHintSeen()
  end
end



function s030_baselab.SubAreaChangeRequest(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_)
  Scenario.SubAreaChangeRequest(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_)
end


function s030_baselab.OnSubAreaChange(old_subarea, old_actorgroup, new_subarea, new_actorgroup, disable_fade)
  local disable_wide = not Scenario.ReadFromBlackboard(s030_baselab.sRandoBlackoutPropID, false)
  local wide_door_left = Game.GetActor("doorwidebeam_001")
  local wide_door_right = Game.GetActor("doorwidebeam_001_mirrored")

  if wide_door_left ~= nil then
    wide_door_left.LIFE:SetInvulnerable(disable_wide)
  end
  if wide_door_right ~= nil then
    wide_door_right.LIFE:SetInvulnerable(disable_wide)
  end
end














function s030_baselab.OnEnter_ActivatePostBlackout()
  Game.PushSetup("PostBlackout", true, true)
  Game.StopMusic(true)
  Scenario.WriteToBlackboard(s030_baselab.sRandoBlackoutPropID, "b", true)
end

function s030_baselab.Event_ShakerNaut_Activation()
  local oActor1 = Game.GetActor("SP_Shakernaut_001B_shakernaut")
  if oActor1 ~= nil then
    oActor1.ANIMATION:SetAction("spawn_baselab_part015_relaxtopath", true)
  end
  local oActor2 =  Game.GetActor("SP_Shakernaut_001B")
  if oActor2 ~= nil then
    oActor2.SPAWNPOINT:Deactivate()
  end
  local oActor3 = Game.GetActor("SP_Shakernaut_001")
  if oActor3 ~= nil then
    oActor3.SPAWNPOINT:Activate()
  end
end

function s030_baselab.DetectingDirection()
  local L0_2 = Game.GetActor("SP_Shakernaut_001B_shakernaut")
  if L0_2 ~= nil then
    if L0_2.ANIMATION:IsPlayingAnim("spawn_baselab_part015_relaxtopath", false) then
      Game.AddSF(0, "s030_baselab.DetectingDirection", "")
    else
      local L1_2 = Game.GetPlayer()
      local L2_2 = V3D(-1, 0, 0)
      if L1_2 ~= nil then
        L2_2 = L1_2.vPos - L0_2.vPos
      end      
      if L2_2.x > 0 then
        L0_2.ANIMATION:SetAction("spawn_baselab_part015_turn_right", true)
        L2_2 = V3D(1, 0, 0)
      else
        L0_2.ANIMATION:SetAction("spawn_baselab_part015_turn_left", true)
        L2_2 = V3D(-1, 0, 0)
      end
      L0_2.AI:SetNavigationDir(L2_2)
    end
  end
end




function s030_baselab.OnEnter_ActivatePostBlackout2()
  Game.PushSetup("PostBlackout2", true, true)
  Game.StopMusic(true)
end






function s030_baselab.OnEnter_ActivatePostEmmyEnemies(_ARG_0_, _ARG_1_)
  local oActor1 = Game.GetActor("SG_PostEmmy_000")
  local oActor2 = Game.GetActor("SG_PostEmmy_001")
  if oActor1 ~= nil then
    oActor1.SPAWNGROUP:EnableSpawnGroup()
  end
  if oActor2 ~= nil then
    oActor2.SPAWNGROUP:EnableSpawnGroup()
  end
  _ARG_0_.bEnabled = false
end





function s030_baselab.OnCutscene39End()

  s030_baselab.EmmyLabSpawnSequenceEnd()
  local oActor = Game.GetActor("emmyvalve_reg_gen_002")
  if oActor ~= nil then
    oActor.EMMYVALVE:CleanForceStateFlag()
  end
end
