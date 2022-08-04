
s020_magma.HasRandomizerChanges = true
function s020_magma.main()
  s020_magma.PatrolRoutesGeneration()
  s020_magma.PatrolRoutesFinalNodesAssignation()
end


function s020_magma.SetupDebugGameBlackboard()
    
    
    
    
    
    
    
    
    
    
    
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_CURRENT_SPECIAL_ENERGY", "f", 1000)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_MAX_SPECIAL_ENERGY", "f", 1000)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_SPECIAL_ENERGY", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_CURRENT_LIFE", "f", 199)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_MAX_LIFE", "f", 199)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_MISSILE_MAX", "f", 20)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_MISSILE_CURRENT", "f", 20)
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
local KRAID_STAGE_ACTIVATION_APPLIED = false
local MAGMA_COOLDOWN_APPLIED = false
local MAGMA_POSTXRELEASE_APPLIED = false






function s020_magma.InitFromBlackboard()
    
    
    
    
    
    
    
    
  Game.ReinitPlayerFromBlackboard()
  MAGMA_COOLDOWN_APPLIED = Scenario.ReadFromBlackboard(Scenario.LUAPropIDs.MAGMA_COOLDOWN_APPLIED, false)
  MAGMA_POSTXRELEASE_APPLIED = Scenario.ReadFromBlackboard(Scenario.LUAPropIDs.MAGMA_POSTXRELEASE_APPLIED, false)
  QUARENTINE_OPENED = Blackboard.GetProp("GAME_PROGRESS", "QUARENTINE_OPENED")
  if QUARENTINE_OPENED == true then
    s020_magma.Activate_Setup_PostXRelease()
  end
  if Game.GetCooldownFlag() == true then
    s020_magma.Enable_PistonOff()
    s020_magma.Cooldown_Activation()
  end
  if Scenario.ReadFromBlackboard(Scenario.LUAPropIDs.COOLDOWN_FINISHED, false) then
    s020_magma.ThermalTrapChange()
    s020_magma.PistonDeactivation()
  end
  if QUARENTINE_OPENED ~= true then
    local oActor1 = Game.GetActor("ev_lavapump_mg_001")
    if oActor1 ~= nil then
      oActor1.MODELUPDATER:SetMeshVisible("Slime_MESH", false)
    end
    local oActor2 = Game.GetActor("fan_cooldown_000")
    if oActor2 ~= nil then
      oActor2.MODELUPDATER:SetMeshVisible("Slime_MESH", false)
    end
  end
end




function s020_magma.Activate_Setup_PostXRelease()
  if MAGMA_POSTXRELEASE_APPLIED == false then
    Game.PushSetup("PostXRelease", true, true)
    Scenario.WriteToBlackboard(Scenario.LUAPropIDs.MAGMA_POSTXRELEASE_APPLIED, "b", true)
    MAGMA_POSTXRELEASE_APPLIED = true
  end
end
s020_magma.tGetOnDeathOverrides = {ShowDeath = true, GoToMainMenu = false}




function s020_magma.GetOnDeathOverrides()
  return s020_magma.tGetOnDeathOverrides
end





function s020_magma.OnBeforeGenerate()
end


function s020_magma.OnEmmyMagmaGenerated(_ARG_0_, _ARG_1_)
  CurrentScenario.oEmmyEntity = _ARG_1_
  AI.SetWorldGraphToEmmy("LE_WorldGraph", _ARG_1_.sName)
  s020_magma.ChangePatrolEmmy("PATROLROUTE_01")
  print("EMMY: Generation OK. Starting patrol: " .. _ARG_1_.AI.sCurrentPatrol)
end

function s020_magma.RelocateEmmy_AfterPresentation()
  if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
    local oActor = Game.GetActor("LM_EmmyEntrancePoint_024")
    CurrentScenario.oEmmyEntity.bEnabled = false
    CurrentScenario.oEmmyEntity.vPos = oActor.vPos
    CurrentScenario.oEmmyEntity.vAng = oActor.vAng
    CurrentScenario.oEmmyEntity.bEnabled = true
  end
  GUI.AddEmmyMissionLogEntry("#MLOG_ENCOUNTER_EMMY_MAGMA")
end





function s020_magma.OnEmmyMagmaDead()

    
    
    
    
    
    
    
    
    Game.PushSetup("PostEmmy", true, true)
end

function s020_magma.OnEmmyAbilityObtainedFadeOutCompleted()

  local oActor = Game.GetActor("centralunitmagmacontroller")
  if oActor ~= nil then
    oActor.CENTRALUNIT:OnEmmyAbilityObtainedFadeOutCompleted()
  end
end


function s020_magma.DelayedOnEmmyMagmaDead()
    
  GUI.ShowMessage("#PLACEHOLDER_EMMYMAGMA_KILLED", true, "")
  local oPlayer = Game.GetPlayer()
  if oPlayer ~= nil then
    oPlayer.INPUT:IgnoreInput(false, false, "OnEmmyMagmaDead")
  end
end


function s020_magma.OnEmmyDeathMessageSkipped()
end


function s020_magma.OnUnlockEmmyDoors()
    
  local oActor = Game.GetActor("centralunitmagmacontroller")
  if oActor ~= nil then
    oActor.CENTRALUNIT:UnlockDoors()
  else
    print("CENTRAL_UNIT: centralunitmagmacontroller not found")
  end
end


function s020_magma.OnLockEmmyDoors()
    
  local oActor = Game.GetActor("centralunitmagmacontroller")
  if oActor ~= nil then
    oActor.CENTRALUNIT:LockDoors()
  else
    print("CENTRAL_UNIT: centralunitmagmacontroller not found")
  end
end


function s020_magma.OnCheckpoint_MorphBall()

  s020_magma.OnLockEmmyDoors()
end





function s020_magma.PatrolRoutesGeneration()
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
    oEmmy.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_11")
    oEmmy.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_12")
    oEmmy.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_13")
    oEmmy.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_14")
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
  print("s020_magma.PatrolRoutesGeneration(): Patrol designation OK")
end

function s020_magma.PatrolRoutesFinalNodesAssignation()
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_01", { "WorldGraph_41" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_01", { "WorldGraph_38" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_02", { "WorldGraph_4", "WorldGraph_36" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_02", { "WorldGraph_62", "WorldGraph_81" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_02", { "WorldGraph_0", "WorldGraph_13", "WorldGraph_12" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_02", { "WorldGraph_11", "WorldGraph_59" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_03", { "WorldGraph_35", "WorldGraph_31" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_03", { "WorldGraph_26", "WorldGraph_36" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_03", { "WorldGraph_83", "WorldGraph_64" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_03", { "WorldGraph_23", "WorldGraph_6" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_04", { "WorldGraph_27", "WorldGraph_36" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_04", { "WorldGraph_25", "WorldGraph_38" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_05", { "WorldGraph_25", "WorldGraph_35", "WorldGraph_20" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_05", { "WorldGraph_21", "WorldGraph_83" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_05", { "WorldGraph_64", "WorldGraph_33" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_06", { "WorldGraph_58", "WorldGraph_53"  }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_06", { "WorldGraph_50" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_06", { "WorldGraph_55", "WorldGraph_67" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_07", { "WorldGraph_88" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_07", { "WorldGraph_98", "WorldGraph_48" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_07", { "WorldGraph_54", "WorldGraph_60" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_08", { "WorldGraph_60", "WorldGraph_41" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_08", { "WorldGraph_49", "WorldGraph_54" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_08", { "WorldGraph_58", "WorldGraph_54" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_08", { "WorldGraph_48", "WorldGraph_80" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_08", { "WorldGraph_77", "WorldGraph_45" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_09", { "WorldGraph_71", "WorldGraph_73" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_09", { "WorldGraph_70", "WorldGraph_69" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_09", { "WorldGraph_77" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_09", { "WorldGraph_68", "WorldGraph_76" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_10", { "WorldGraph_102" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_10", { "WorldGraph_93", "WorldGraph_92" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_10", { "WorldGraph_98", "WorldGraph_97" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_10", { "WorldGraph_101", "WorldGraph_92" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_10", { "WorldGraph_99", "WorldGraph_91", "WorldGraph_94" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_11", { "WorldGraph_26", "WorldGraph_9" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_11", { "WorldGraph_109", "WorldGraph_27" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_12", { "WorldGraph_75" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_12", { "WorldGraph_76", "WorldGraph_77" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_13", { "WorldGraph_57", "WorldGraph_65" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_13", { "WorldGraph_1", "WorldGraph_57" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_13", { "WorldGraph_3", "WorldGraph_59" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_13", { "WorldGraph_5", "WorldGraph_59" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_14", { "WorldGraph_81", "WorldGraph_11" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_14", { "WorldGraph_4", "WorldGraph_13" }, 1)
  print("s020_magma.PatrolRoutesFinalNodesAssignation(): Final Nodes Assignation OK")
end




function s020_magma.ChangePatrolEmmy(_ARG_0_)
  if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
    CurrentScenario.oEmmyEntity.AI.sCurrentPatrol = _ARG_0_
    print("EMMY: Assigned route " .. _ARG_0_)
  else
    print("EMMY: Not found, route " .. _ARG_0_ .. " not assigned")
  end
end

function s020_magma.OnEnter_PatrolEmmyActivator(_ARG_0_, _ARG_1_)
  local sName = string.gsub(_ARG_0_.sName, "TG_PATROLEMMYACTIVATOR_", "PATROLROUTE_")
  s020_magma.ChangePatrolEmmy(sName)
end

function s020_magma.OnExit_PatrolEmmyActivator(_ARG_0_, _ARG_1_)

end
s020_magma.tEmmyDoor = nil






function s020_magma.OnWalkThroughEmmyDoor(_ARG_0_, _ARG_1_, _ARG_2_)
    
    
  if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
    if _ARG_1_ then
      if CurrentScenario.oEmmyEntity ~= nil then
        local L3_2 = nil
        if _ARG_2_ then
          L3_2 = s020_magma.HardEmmyRelocationDoor(_ARG_0_)
        else
          L3_2 = s020_magma.EmmyRelocationDoor(_ARG_0_)
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

function s020_magma.HardEmmyRelocationDoor(_ARG_0_) 
    
    
    
    
    
    
    
    
    
    
    
    
    
    
  print("Door: Hard " .. _ARG_0_.sName)
  if _ARG_0_.sName == "dooremmy" then
    s020_magma.tEmmyDoor = {
      "LM_EmmyEntrancePoint_025"
    }
  elseif _ARG_0_.sName == "dooremmy_001" then
    local oProp = Blackboard.GetProp("s020_magma", "ev_dspiston_mg_001:ACTIVATABLE:Activated")
    if oProp ~= nil then
      s020_magma.tEmmyDoor = {
        "LM_EmmyEntrancePoint_017"
      }
    else
      s020_magma.tEmmyDoor = {
        "LM_EmmyEntrancePoint_004"
      }
    end
  elseif _ARG_0_.sName == "dooremmy_002" then
    local oProp = Blackboard.GetProp("s020_magma", "ev_tpiston_mg_001:ACTIVATABLE:Activated")
    if oProp ~= nil then
      s020_magma.tEmmyDoor = {
        "LM_EmmyEntrancePoint_021"
      }
    else
      s020_magma.tEmmyDoor = {
        "LM_EmmyEntrancePoint_006"
      }
    end
  elseif _ARG_0_.sName == "dooremmy_003" then
    s020_magma.tEmmyDoor = {
      "LM_EmmyEntrancePoint_003"
    }
  elseif _ARG_0_.sName == "dooremmy_004" then
    s020_magma.tEmmyDoor = {
      "LM_EmmyEntrancePoint_012"
    }
  elseif _ARG_0_.sName == "dooremmy_005" then
    s020_magma.tEmmyDoor = {
      "LM_EmmyEntrancePoint_014"
    }
  elseif _ARG_0_.sName == "dooremmy_006" then
    s020_magma.tEmmyDoor = {
      "LM_EmmyEntrancePoint_015"
    }
  elseif _ARG_0_.sName == "dooremmy_007" then
    s020_magma.tEmmyDoor = {
      "LM_EmmyEntrancePoint_013"
    }
  elseif _ARG_0_.sName == "dooremmy_008" then
    s020_magma.tEmmyDoor = {
      "LM_EmmyEntrancePoint_012"
    }
  elseif _ARG_0_.sName == "dooremmy_009" then
    s020_magma.tEmmyDoor = {
      "LM_EmmyEntrancePoint_008"
    }
  else
    s020_magma.tEmmyDoor = nil
  end
  if s020_magma.tEmmyDoor ~= nil then
    return s020_magma.tEmmyDoor[math.random(table.maxn(s020_magma.tEmmyDoor))]
  else
    return nil
  end
end

function s020_magma.EmmyRelocationDoor(_ARG_0_)
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
  if _ARG_0_.sName == "dooremmy" then
    s020_magma.tEmmyDoor = {
      "LM_EmmyEntrancePoint_005",
      "LM_EmmyEntrancePoint_006",
      "LM_EmmyEntrancePoint_025"
    }
  elseif _ARG_0_.sName == "dooremmy_001" then
    local oProp = Blackboard.GetProp("s020_magma", "ev_dspiston_mg_001:ACTIVATABLE:Activated")
    if oProp ~= nil then
      s020_magma.tEmmyDoor = {
        "LM_EmmyEntrancePoint_017"
      }
    else
      s020_magma.tEmmyDoor = {
        "LM_EmmyEntrancePoint_004"
      }
    end
  elseif _ARG_0_.sName == "dooremmy_002" then
    local oProp = Blackboard.GetProp("s020_magma", "ev_tpiston_mg_001:ACTIVATABLE:Activated")
    if oProp ~= nil then
      s020_magma.tEmmyDoor = {
        "LM_EmmyEntrancePoint_020",
        "LM_EmmyEntrancePoint_021",
        "LM_EmmyEntrancePoint_024"
      }
    else
      s020_magma.tEmmyDoor = {
        "LM_EmmyEntrancePoint_017",
        "LM_EmmyEntrancePoint_024",
        "LM_EmmyEntrancePoint_006"
      }
    end
  elseif _ARG_0_.sName == "dooremmy_003" then
    s020_magma.tEmmyDoor = {
      "LM_EmmyEntrancePoint_002",
      "LM_EmmyEntrancePoint_003"
    }
  elseif _ARG_0_.sName == "dooremmy_004" then
    s020_magma.tEmmyDoor = {
      "LM_EmmyEntrancePoint_000",
      "LM_EmmyEntrancePoint_012",
      "LM_EmmyEntrancePoint_015"
    }
  elseif _ARG_0_.sName == "dooremmy_005" then
    s020_magma.tEmmyDoor = {
      "LM_EmmyEntrancePoint_014"
    }
  elseif _ARG_0_.sName == "dooremmy_006" then
    s020_magma.tEmmyDoor = {
      "LM_EmmyEntrancePoint_015",
      "LM_EmmyEntrancePoint_014"
    }
  elseif _ARG_0_.sName == "dooremmy_007" then
    s020_magma.tEmmyDoor = {
      "LM_EmmyEntrancePoint_010",
      "LM_EmmyEntrancePoint_009",
      "LM_EmmyEntrancePoint_013"
    }
  elseif _ARG_0_.sName == "dooremmy_008" then
    s020_magma.tEmmyDoor = {
      "LM_EmmyEntrancePoint_012"
    }
  elseif _ARG_0_.sName == "dooremmy_009" then
    s020_magma.tEmmyDoor = {
      "LM_EmmyEntrancePoint_007",
      "LM_EmmyEntrancePoint_008",
      "LM_EmmyEntrancePoint_009"
    }
  else
    s020_magma.tEmmyDoor = nil
  end
  if s020_magma.tEmmyDoor ~= nil then
    return s020_magma.tEmmyDoor[math.random(table.maxn(s020_magma.tEmmyDoor))]
  else
    return nil
  end
end






function s020_magma.OnEnter_ChangeCamera_000_B() 
  Game.SetCollisionCameraLocked("collision_camera_000_B", true)
  print("OnEnter_ChangeCamera_000_B")
end
function s020_magma.OnExit_ChangeCamera_000_B()
  Game.SetCollisionCameraLocked("collision_camera_000_B", false)
  print("OnExit_ChangeCamera_000_B")
end

function s020_magma.OnEnter_ChangeCamera_009_B()
  Game.SetCollisionCameraLocked("collision_camera_009_B", true)
  print("OnEnter_ChangeCamera_009_B")
end
function s020_magma.OnExit_ChangeCamera_009_B()
  Game.SetCollisionCameraLocked("collision_camera_009_B", false)
  print("OnExit_ChangeCamera_009_B")
end

function s020_magma.OnEnter_ChangeCamera_009_C()
  Game.SetCollisionCameraLocked("collision_camera_009_C", true)
end
function s020_magma.OnExit_ChangeCamera_009_C()
  Game.SetCollisionCameraLocked("collision_camera_009_C", false)
end

function s020_magma.OnEnter_ChangeCamera_015_B()
  Game.SetCollisionCameraLocked("collision_camera_015_B", true)
  print("OnEnter_ChangeCamera_015_B")
end
function s020_magma.OnExit_ChangeCamera_015_B()
  Game.SetCollisionCameraLocked("collision_camera_015_B", false)
  print("OnExit_ChangeCamera_015_B")
end

function s020_magma.OnEnter_ChangeCamera_023_B()
  Game.SetCollisionCameraLocked("collision_camera_023_B", true)
  print("OnEnter_ChangeCamera_023_B")
end
function s020_magma.OnExit_ChangeCamera_023_B()
  Game.SetCollisionCameraLocked("collision_camera_023_B", false)
  print("OnExit_ChangeCamera_023_B")
end

function s020_magma.OnEnter_ChangeCamera_024_B()
  Game.SetCollisionCameraLocked("collision_camera_024_B", true)
  print("OnEnter_ChangeCamera_024_B")
end
function s020_magma.OnExit_ChangeCamera_024_B()
  Game.SetCollisionCameraLocked("collision_camera_024_B", false)
  print("OnExit_ChangeCamera_024_B")
end

function s020_magma.OnEnter_ChangeCamera_025_B()
  Game.SetCollisionCameraLocked("collision_camera_025_B", true)
  print("OnEnter_ChangeCamera_025_B")
end
function s020_magma.OnExit_ChangeCamera_025_B()
  Game.SetCollisionCameraLocked("collision_camera_025_B", false)
  print("OnExit_ChangeCamera_025_B")
end

function s020_magma.OnEnter_ChangeCamera_026_B()
  Game.SetCollisionCameraLocked("collision_camera_026_B", true)
  print("OnEnter_ChangeCamera_026_B")
end
function s020_magma.OnExit_ChangeCamera_026_B()
  Game.SetCollisionCameraLocked("collision_camera_026_B", false)
  print("OnExit_ChangeCamera_026_B")
end

function s020_magma.OnEnter_ChangeCamera_051_B()
  Game.SetCollisionCameraLocked("collision_camera_051_B", true)
  print("OnEnter_ChangeCamera_051_B")
end
function s020_magma.OnExit_ChangeCamera_051_B()
  Game.SetCollisionCameraLocked("collision_camera_051_B", false)
  print("OnExit_ChangeCamera_051_B")
end

function s020_magma.Enable_TG__ZoomOutQuit()
  local oActor = Game.GetActor("TG_ZoomOutQuit")
  if oActor ~= nil then
    oActor.TRIGGER.bWantsEnabled = true
  end
end

function s020_magma.Disable_MagnetRailCam()

  local oActor = Game.GetActor("camerarailpath")
  if oActor ~= nil then
    oActor.bEnabled = false
  end
end

function s020_magma.Disable_CamToKraid()
    
  local oActor = Game.GetActor("CameraRail_PathToKraid")
  if oActor ~= nil then
    oActor.bEnabled = false
  end
end







function s020_magma.Cooldown_Activation()
  s020_magma.Cooldown_Deactivation()
  -- Cooldown has been removed from rando
  
  -- if MAGMA_COOLDOWN_APPLIED == false then
  --   Game.PushSetup("Cooldown", true, true)
  --   Scenario.WriteToBlackboard(Scenario.LUAPropIDs.MAGMA_COOLDOWN_APPLIED, "b", true)
  --   MAGMA_COOLDOWN_APPLIED = true
  -- end
end

function s020_magma.Cooldown_Deactivation()
    

  Game.SetCooldownFlag(false)
  Scenario.WriteToBlackboard(Scenario.LUAPropIDs.COOLDOWN_FINISHED, "b", true)
  s020_magma.ThermalTrapChange()
  s020_magma.PistonDeactivation()
  -- Game.PushSetup("PostCooldown", true, true)
  Scenario.WriteToBlackboard(Scenario.LUAPropIDs.MAGMA_COOLDOWN_APPLIED, "b", false)
  MAGMA_COOLDOWN_APPLIED = false
end

function s020_magma.ThermalTrapChange()
  local L0_2 = Game.GetActor("trap_thermal_horizontal_PRECOOL")
  local L1_2 = Game.GetActor("trap_thermal_horizontal_POSTCOOL")
  if L0_2 ~= nil and L1_2 ~= nil then
    L1_2.bEnabled = true
    L0_2.bEnabled = false
  end
end

function s020_magma.PistonDeactivation()

  s020_magma.Enable_PistonOff()
  local L0_2 = Game.GetActor("ev_hpiston_mg_001")
  local L1_2 = Game.GetActor("pistonmag01_001")
  local L2_2 = Game.GetActor("shootactivatormag01_001")
  local L3_2 = Game.GetActor("pistonmag01_off_post")
  local L4_2 = Game.GetActor("shootactivatoroff_000_post")
  if L0_2 ~= nil and L1_2 ~= nil and L2_2 ~= nil and L3_2 ~= nil and L4_2 ~= nil then
    L0_2.bEnabled = false
    L1_2.bEnabled = false
    L2_2.bEnabled = false
    L3_2.bEnabled = true
    L4_2.bEnabled = true
  end
  local L5_2 = Game.GetActor("fusiblebox_000")
  local L6_2 = Game.GetActor( "fusiblebox_broken_000")
  if L5_2 ~= nil and L6_2 ~= nil then
    L6_2.bEnabled = true
    L5_2.bEnabled = false
  end
end

function s020_magma.Enable_PistonOff()
  local oActor = Game.GetActor("ev_hpiston_mg_001_off")
  if oActor ~= nil then
    oActor.bEnabled = true
  end
end




function s020_magma.OnEnter_FadeOutCooldownX()
    
    
  print("FADE OUT COOLDOW-X")
  Game.FadeOut(0.6)
  s020_magma.fSFXVolume = Game.GetSFXVolume()
  Game.SetSFXVolume(0, 0.7)
  Game.StopMusicWithFade(0.6, true)
end




function s020_magma.OnEnter_AP_03()
  Scenario.CheckRandoHint("accesspoint", "MAGMA_1")
end

function s020_magma.OnEnter_AP_03B()
  Scenario.CheckRandoHint("accesspoint_000", "MAGMA_2")
end

function s020_magma.OnUsableFinishInteract(_ARG_0_)
  if _ARG_0_.sName == "accesspoint" or _ARG_0_.sName == "accesspoint_000" then
    Scenario.SetRandoHintSeen()
  end
end

function s020_magma.OnUsablePrepareUse(actor)
  Scenario.DisableGlobalTeleport(actor)
end

function s020_magma.OnUsableCancelUse(actor)
  Scenario.ResetGlobalTeleport(actor)
  Scenario.CheckWarpToStart(actor)
end

function s020_magma.OnUsableUse(actor)
  Scenario.SetTeleportalUsed(actor)
end





function s020_magma.SubAreaChangeRequest(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_)
  Scenario.SubAreaChangeRequest(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_)
end


function s020_magma.SetCooldown(state)
  Game.SetCooldownFlag(state)
  if state then
    Game.PushSetup("Cooldown", true, true)
  else
    Game.PopSetup("Cooldown", true, true)
  end
end

function s020_magma.OnEnter_TriggerEnableCooldown()
  if not Init.bEnableExperimentBoss or Scenario.ReadFromPlayerBlackboard("RANDO_DEFEATED_EXPERIMENT", false) then return end
  s020_magma.SetCooldown(true)
end

function s020_magma.OnEnter_TriggerDisableCooldown()
  s020_magma.SetCooldown(false)
end


function s020_magma.OnSubAreaChange(old_subarea, old_actorgroup, new_subarea, new_actorgroup, disable_fade)
    
    
    
    
    
  if s020_magma.IsKraidCombatBegin(old_subarea, old_actorgroup, new_subarea, new_actorgroup, disable_fade) then
    s020_magma.Kraid_InitCutscene()
  end

  if old_subarea == "collision_camera_004" and (new_subarea ~= "collision_camera_009" or Game.GetPlayer().vPos[1] < -7000) then
    s020_magma.SetCooldown(false)
  end
  if old_subarea == "collision_camera_009" and old_actorgroup == "PostCooldown" then
    Game.PopSetup("Cooldown", true, true)
    Game.PushSetup("PostXRelease", true, true)
  elseif Init.bEnableExperimentBoss and QUARENTINE_OPENED
      and new_subarea == "collision_camera_009" and old_subarea == "collision_camera_004"
      and Game.GetPlayer().vPos[1] > -7000 -- entered through the morph ball launcher
      and not Scenario.ReadFromPlayerBlackboard("RANDO_DEFEATED_EXPERIMENT", false) then
    -- begin Experiment fight

    local oActor = Game.GetActor("cutsceneplayer_78")
    if oActor ~= nil then
      oActor.CUTSCENE:TryLaunchCutscene()
    end
  --elseif old_subarea == "collision_camera_052" and new_subarea == "collision_camera_020" then
  --  local oActor = Game.GetActor("cutsceneplayer_38")
  --  if oActor ~= nil then
  --    oActor.CUTSCENE:TryLaunchCutscene()
  --  end
  elseif old_subarea == "collision_camera_063" and new_subarea == "collision_camera_044" then
    Game.PlayCurrentEnvironmentMusic()
  elseif old_subarea == "collision_camera_022" and new_subarea == "collision_camera_030" then
    Game.StopMusic(true)
    Game.PlayCurrentEnvironmentMusic()
  end
end

function s020_magma.Kraid_InitCutscene()
  Game.PushSetup("Kraid_Stage_01", true, true)
  local oActor1 = Game.GetActor("cutsceneplayer_59") 
  if oActor1 ~= nil then
    oActor1.CUTSCENE:TryLaunchCutscene()
  end
  local oActor2 = Game.GetActor("block_slide_reg_002")
  if oActor2 ~= nil then
    oActor2.ANIMATION:SetAction("closed", true)
  end
end

function s020_magma.OnCutscene78Started()
    
    
    
    
    
  Game.SetActorVolumeOverride("Samus", 0, 0, "ALL")
  local L0_2 = 1

  if s020_magma.fSFXVolume ~= nil then
    L0_2 = s020_magma.fSFXVolume
  end
  Game.SetSFXVolume(L0_2, 0)
end

function s020_magma.OnCutscene81Ended()
    
    
  s020_magma.Cooldown_Deactivation()
  Game.PushSetup("PostCooldown", true, true)
  Blackboard.SetProp("s010_cave", "SubareaSetupID[collision_camera_080]", "s", "Default>PostXRelease")
  Scenario.WriteToPlayerBlackboard("RANDO_DEFEATED_EXPERIMENT", "b", true)
  Game.SetPlayerInteractMovementState()
end

function s020_magma.OnCutscene81Skipped()

  local oActor = Game.GetActor("fan_cooldown_000")
  if oActor ~= nil then
    oActor.ANIMATION:SetAction("relax", true)
    oActor.TIMELINECOMPONENT:EndAction("dissolve_in_cut_scene")
    oActor.TIMELINECOMPONENT:StartAction("dissolve_in_cut_scene_no_transition", -1, false)
  end
end

function s020_magma.OnBeforeCutscene0059Started()
  CurrentScenario.oKraid.AI:SetBossCamera(true, true)
end

function s020_magma.OnCutscene0059Ended()


end













function s020_magma.OnKraidGenerated(_ARG_0_, _ARG_1_)
  CurrentScenario.oKraid = _ARG_1_
  if CurrentScenario.oKraid ~= nil then
    CurrentScenario.oKraid.ANIMATION:SetAction("kraid_stage1", true)
    print("ANIMATION 1")
  end
end

function s020_magma.OnEnter_Kraid_Activation_Stage_02()
    
    
    
  Game.PushSetup("Kraid_Stage_02", true, true)
  local oActor1 = Game.GetActor("ev_kraid_platform")
  if oActor1 ~= nil then
    oActor1.CHANGE_STAGE_NAVMESH_ITEM:RefreshNavMeshState()
  end
  local oActor2 = Game.GetActor("ev_kraid_structure") 
  if oActor2 ~= nil then
    oActor2.CHANGE_STAGE_NAVMESH_ITEM:RefreshNavMeshState()
  end
  if CurrentScenario.oKraid ~= nil then
    CurrentScenario.oKraid.ANIMATION:SetAction("kraid_stage2", true)
    print("ANIMATION 2")
  end
end

function s020_magma.OnEnter_Kraid_Activation_Stage_02B()
  if KRAID_STAGE_ACTIVATION_APPLIED == false then
    Game.PushSetup("Kraid_Stage_02B", true, true)
    KRAID_STAGE_ACTIVATION_APPLIED = true
  else
    Game.PopSetup("Kraid_Stage_02B", true, true)
    KRAID_STAGE_ACTIVATION_APPLIED = false
  end
end

function s020_magma.OpenKraidMorphBallLauncherExit()
  local oActor = Game.GetActor("mblauncher_exit_gen_002")
  if oActor ~= nil then
    oActor.ANIMATION:SetAction("open", true)
  end
end




function s020_magma.OnEnter_Kraid_Activation_Stage_02(_ARG_0_, _ARG_1_)
    

  Game.AddSF(0.1, "s020_magma.Delayed_Kraid_Activation_Stage_02", "")
  local oPlayer = Game.GetPlayer()
  if oPlayer ~= nil then
    oPlayer.INPUT:IgnoreInput(true, false, "OnEnter_Kraid_Activation_Stage_02")
  end
end


function s020_magma.Delayed_Kraid_Activation_Stage_02()
    
    
    
  GUI.ShowMessage("#KRAID_STAGE_2", true, "s020_magma.Kraid_Activation_Stage_02_MessageSkipped")
  local oPlayer = Game.GetPlayer()
  if oPlayer ~= nil then
    oPlayer.INPUT:IgnoreInput(false, false, "OnEnter_Kraid_Activation_Stage_02")
  end
end


function s020_magma.Kraid_Activation_Stage_02_MessageSkipped()
    
    
    
  Game.GetPlayer().vPos = V3D(-16900, -6900, 0)
  Game.PushSetup("Kraid_Stage_02", true, true)
  local L0_2 = Game.GetActor("ev_kraid_platform")
  if L0_2 ~= nil then
    L0_2.CHANGE_STAGE_NAVMESH_ITEM:RefreshNavMeshState()
  end
  local L1_2 = Game.GetActor("ev_kraid_structure")
  if L1_2 ~= nil then
    L1_2.CHANGE_STAGE_NAVMESH_ITEM:RefreshNavMeshState()
  end
  if CurrentScenario.oKraid ~= nil then
    CurrentScenario.oKraid.AI:ChangeKraidAnimToStage2()
  end
end


function s020_magma.Kraid_Activation_Stage_02_With_Cut_Scene()
    
    
  Game.PushSetup("Kraid_Stage_02", true, true)
  local oActor1 = Game.GetActor("ev_kraid_platform")
  if oActor1 ~= nil then
    oActor1.CHANGE_STAGE_NAVMESH_ITEM:RefreshNavMeshState()
  end
  local oActor2 = Game.GetActor("ev_kraid_structure")
  if oActor2 ~= nil then
    oActor2.CHANGE_STAGE_NAVMESH_ITEM:RefreshNavMeshState()
  end
end







function s020_magma.OnEnter_Kraid_Activation_Stage_03(_ARG_0_, _ARG_1_)
    
    
  GUI.ShowMessage("#KRAID_STAGE_3", true, "s020_magma.Kraid_Activation_Stage_03_MessageSkipped")
end


function s020_magma.Kraid_Activation_Stage_03_MessageSkipped()

  s020_magma.Kraid_Activation_Stage_03_CutsceneStart()
  s020_magma.Kraid_Activation_Stage_03_CutsceneEnd()
end


function s020_magma.Kraid_Activation_Stage_03_CutsceneStart()
    
    
    
    
    
  local oActor = Game.GetActor("TG_KraidRoars_Ambient")
  if oActor ~= nil then
    oActor.bEnabled = false
  end
  Game.DeleteEntity("SP_Kraid_kraid")
  Game.PushSetup("Kraid_Stage_03", true, true)
end


function s020_magma.Kraid_Activation_Stage_03_CutsceneEnd()

end

function s020_magma.OnKraidDeath_CUSTOM()
  Game.AddGUISF(0, "s020_magma.Kraid_Activation_Stage_03_CutsceneEnd", "")
end

function s020_magma.IsKraidCombatBegin(old_subarea, old_actorgroup, new_subarea, new_actorgroup, disable_fade)
  if old_subarea == "collision_camera_024" and new_subarea == "collision_camera_063" and new_actorgroup == "Default" then
    return true
  else
    return false
  end
end






function s020_magma.OnShootActivationCompleted(_ARG_0_, _ARG_1_)
    
    
  if _ARG_0_ == "shootactivatormag01_000" and _ARG_1_ then
    Game.PushSetup("LavaDrained_Right", true, true)
  elseif _ARG_0_ == "shootactivatormag01" and _ARG_1_ then
    Game.PushSetup("LavaDrained_Left", true, true)
  end
end




function s020_magma.OnEnter_KraidZone_CameraShake()
  Game.PlayCameraFXPreset("KRAID_ROAR_WEAK")
  Game.PlayPresetSound("events/kraidscream")
  Game.PlayVibration("levels/magma/kraid_outscream_01.bnvib", false)
end







function s020_magma.OnEnter_ActivatePostEmmyEnemies(_ARG_0_, _ARG_1_)
  local L2_2 = Game.GetActor("SG_PostEmmy_007")
  local L3_2 = Game.GetActor("SG_PostEmmy_008")
  local L4_2 = Game.GetActor("SG_PostEmmy_Caterzilla")
  local L5_2 = Game.GetActor("SG_PostEmmy_Poisonfly")
  local L6_2 = Game.GetActor("SG_PostEmmy_Vulkran")
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
  if L6_2 ~= nil then
    L6_2.SPAWNGROUP:EnableSpawnGroup()
  end
  _ARG_0_.bEnabled = false
end







function s020_magma.OnEnter_EnableEnemiesPistonLeft(_ARG_0_, _ARG_1_)
  local L2_2 = Game.GetActor("SG_Sclawk_000")
  local L3_2 = Game.GetActor("SG_Sclawk_001")
  local L4_2 = Game.GetActor("SG_Poisonfly_003A")
  local L5_2 = Game.GetActor("SG_Poisonfly_003B")
  local L6_2 = Game.GetActor("spawngroup_026")
  
  
  
  
  if L2_2 ~= nil then
    L2_2.SPAWNGROUP:EnableSpawnGroup()
  end
  if L3_2 ~= nil then
    L3_2.SPAWNGROUP:EnableSpawnGroup()
  end
  if L4_2 ~= nil then
    L4_2.SPAWNGROUP:DisableSpawnGroup()
  end
  if L5_2 ~= nil then
    L5_2.SPAWNGROUP:EnableSpawnGroup()
  end
  if L6_2 ~= nil then
    L6_2.SPAWNGROUP:EnableSpawnGroup()
  end
  _ARG_0_.bEnabled = false
end






function s020_magma.OnEnter_EnableEnemiesPistonRight(_ARG_0_, _ARG_1_)
  local oActor1 = Game.GetActor("spawngroup_007")
  local oActor2 = Game.GetActor("SG_Poisonfly_044")
  
  if oActor1 ~= nil then
    oActor1.SPAWNGROUP:EnableSpawnGroup()
  end
  if oActor2 ~= nil then
    oActor2.SPAWNGROUP:EnableSpawnGroup()
  end
  _ARG_0_.bEnabled = false
end





function s020_magma.OnEnter_PistonLeftMusicChange(_ARG_0_, _ARG_1_)
  Game.PushSetup("heat_zone_protected", true, false)
end

function s020_magma.OnExit_PistonLeftMusicChange(_ARG_0_, _ARG_1_)
  Game.PopSetup("heat_zone_protected", true, false)
  if not Game.IsPlayingPreset("s_magma_001") then
    Game.StopStream("streams/music/s_magma_001.wav")
  end
end

function s020_magma.OnEnter_SubArea_043_MusicChange(_ARG_0_, _ARG_1_)
  Game.PushSetup("heat_zone_protected_043", true, false)
end

function s020_magma.OnExit_SubArea_043_MusicChange(_ARG_0_, _ARG_1_)
  Game.PopSetup("heat_zone_protected_043", true, false)
end

function s020_magma.OnEnter_PistonRight_MusicChange(_ARG_0_, _ARG_1_)
  Game.PushSetup("heat_zone_protected_piston_right", true, false)
end

function s020_magma.OnExit_PistonRight_MusicChange(_ARG_0_, _ARG_1_)
  Game.PopSetup("heat_zone_protected_piston_right", true, false)
end

function s020_magma.OnEnter_Diffusion_MusicChange(_ARG_0_, _ARG_1_)
  Game.PushSetup("difussion_statueroom", true, false)
end

function s020_magma.OnExit_Diffusion_MusicChange(_ARG_0_, _ARG_1_)
  Game.PopSetup("difussion_statueroom", true, false)
end














function s020_magma.OnEnter_InsideTunnel_011(_ARG_0_, _ARG_1_)
  Game.PushSetup("InsideTunnel_011", true, false)
end

function s020_magma.OnExit_InsideTunnel_011(_ARG_0_, _ARG_1_)
  Game.PopSetup("InsideTunnel_011", true, false)
end





function s020_magma.DeviceHeatCameraFar000OnSetupInitialState()
  AI.SetWorldGraphNodeEnabled("LE_WorldGraph", "WorldGraph_119", true)
end

function s020_magma.DeviceHeatCameraFar000OnSetupUseState()
  AI.SetWorldGraphNodeEnabled("LE_WorldGraph", "WorldGraph_119", false)
end





function s020_magma.OnEmmyGrabStart(_ARG_0_)
    
  local L1_2 = Game.GetActor("TG_TutoOC_Exit")
  if L1_2 ~= nil and L1_2.bEnabled then
    local oActor2 = Game.GetActor("TG_TutoOC_Enter")
    oActor2.bEnabled = false
  end
end
function s020_magma.OnEmmyGrabEnd(_ARG_0_)

  local L1_2 = Game.GetActor("TG_TutoOC_Exit")
  if L1_2 ~= nil and L1_2.bEnabled then
    local L2_2 = Game.GetActor("TG_TutoOC_Enter")
    L2_2.bEnabled = true
  end
end

function s020_magma.OnCutscene38End()
    
  s020_magma.RelocateEmmy_AfterPresentation()
  local oActor = Game.GetActor("emmyvalve_reg_gen_001")
  if oActor ~= nil then
    oActor.EMMYVALVE:CleanForceStateFlag()
  end
end




function s020_magma.cutsceneplayer_61()
  Game.PushSetup("Kraid_Stage_02", true, true)
end
function s020_magma.cutsceneplayer_61_zipline_mb()
  local L0_2 = Game.GetActor("cutsceneplayer_61_zipline_mb")
  if L0_2 ~= nil then
    local L1_2 = Game.GetActor("cutsceneplayer_61")
    if L1_2 ~= nil then
      L0_2.CUTSCENE:QueueCutscenePlayer(L1_2)
    end
  end
  Game.PushSetup("Kraid_Stage_02", true, true)
end

function s020_magma.cutsceneplayer_80_grab()
  local L0_2 = Game.GetActor("cutsceneplayer_80_grab")
  if L0_2 ~= nil then
    local L1_2 = Game.GetActor("cutsceneplayer_81")
    if L1_2 ~= nil then
      L0_2.CUTSCENE:QueueCutscenePlayer(L1_2)
    end
  end
end
