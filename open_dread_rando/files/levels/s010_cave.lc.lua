
s010_cave.HasRandomizerChanges = true
function s010_cave.main()

  s010_cave.PatrolRoutesGeneration()
  s010_cave.PatrolRoutesFinalNodesAssignation()
end

function s010_cave.SetupDebugGameBlackboard()

    
    
    
    
    
    
    
    
    
    
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_CURRENT_SPECIAL_ENERGY", "f", 1000)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_MAX_SPECIAL_ENERGY", "f", 1000)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_SPECIAL_ENERGY", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_CURRENT_LIFE", "f", 99)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_MAX_LIFE", "f", 99)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_MISSILE_MAX", "f", 10)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_MISSILE_CURRENT", "f", 10)
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
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_CHARGE_BEAM", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_WIDE_BEAM", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_DIFFUSION_BEAM", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_GRAPPLE_BEAM", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_PLASMA_BEAM", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_WEAPON_WAVE_BEAM", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_MAGNET_GLOVE", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_SPEED_BOOSTER", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_OPTIC_CAMOUFLAGE", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_GHOST_AURA", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_SONAR", "f", 0)
  Blackboard.SetProp("PLAYER_INVENTORY", "ITEM_METROIDNIZATION", "f", 0)
end

local QUARENTINE_OPENED = Blackboard.GetProp("GAME_PROGRESS", "QUARENTINE_OPENED")
local L1_1 = false
local CAVES_GAME_INTRO = false
local CAVES_EMMY_SPAWNED = false
local CAVES_CENTRAL_UNIT_WAKE_UP_CUTSCENE_LAUNCHED = false
local CAVES_COOLDOWN_APPLIED = false
local CAVES_POSTXRELEASE_APPLIED = false
local L7_1 = false
local L8_1 = false
local L9_1 = false
local L10_1 = false
local L11_1 = false
local L12_1 = ""
local CAVES_TUTO_MAP_DONE = false
local CAVES_TUTO_MAP_ROOM_DONE = false





function s010_cave.OnLoadScenarioFinished()
  -- if not CAVES_GAME_INTRO then
  --   Game.ResetFader()
  --   Game.FadeOut(0)
  -- end
end

function s010_cave.InitFromBlackboard()
    
    
    
    
    
    
    
    
    
 
    
  Game.ReinitPlayerFromBlackboard()
  
  if CurrentScenario.oEmmyProtoEntity ~= nil then
    print("ProtoEmmyAntiguo presente")
  end
  
  s010_cave.Event_WaterPoolInfiltration_Deactivate()
  CAVES_GAME_INTRO = Scenario.ReadFromBlackboard(Scenario.LUAPropIDs.CAVES_GAME_INTRO, false)
  CAVES_EMMY_SPAWNED = Scenario.ReadFromBlackboard(Scenario.LUAPropIDs.CAVES_EMMY_SPAWNED, false)
  CAVES_CENTRAL_UNIT_WAKE_UP_CUTSCENE_LAUNCHED = Scenario.ReadFromBlackboard(Scenario.LUAPropIDs.CAVES_CENTRAL_UNIT_WAKE_UP_CUTSCENE_LAUNCHED, false)
  CAVES_COOLDOWN_APPLIED = Scenario.ReadFromBlackboard(Scenario.LUAPropIDs.CAVES_COOLDOWN_APPLIED, false)
  CAVES_POSTXRELEASE_APPLIED = Scenario.ReadFromBlackboard(Scenario.LUAPropIDs.CAVES_POSTXRELEASE_APPLIED, false)
  CAVES_TUTO_MAP_DONE = Scenario.ReadFromBlackboard(Scenario.LUAPropIDs.CAVES_TUTO_MAP_DONE, false)
  CAVES_TUTO_MAP_ROOM_DONE = Scenario.ReadFromBlackboard(Scenario.LUAPropIDs.CAVES_TUTO_MAP_ROOM_DONE, false)
  QUARENTINE_OPENED = Blackboard.GetProp("GAME_PROGRESS", "QUARENTINE_OPENED")
  s010_cave.CheckScorpiusDead()
  if not CAVES_EMMY_SPAWNED then
    s010_cave.EmmyCaveSpawnSequence()
  end

  if Game.GetFromGameBlackboardSection("PlayedCutscenes", "CutScenePlayed[cutscenes/0049centralunitdetectsamus01/0049centralunitdetectsamus01.bmscu]") == 0 then
    local L0_2 =  Game.GetActor( "DoorEmmy11")
    if L0_2 ~= nil then
      L0_2.STARTPOINT:SetSaveGameToCheckpoint(false)
    end
  end

  if QUARENTINE_OPENED == true then
    s010_cave.Activate_Setup_PostXRelease()
  end
 
  if Game.GetCooldownFlag() == true then
    if CAVES_COOLDOWN_APPLIED == false then
      s010_cave.Cooldown_Activation()
    end
  elseif CAVES_COOLDOWN_APPLIED == true then
      s010_cave.Cooldown_Deactivation()
  end
  
  
  local oCutsceneTheatre = Blackboard.GetProp("GAME_PROGRESS", "CUTSCENE_THEATRE_CUTSCENE")  
  if oCutsceneTheatre ~= nil then
    print(oCutsceneTheatre)
    Game.LaunchCutscene(oCutsceneTheatre)
  end
  
  if not CAVES_GAME_INTRO then
    s010_cave.OnEnd_Cutscene_intro_end()
  end
end




function s010_cave.Activate_Setup_PostXRelease()
  if CAVES_POSTXRELEASE_APPLIED == false then
    Game.PushSetup("PostXRelease", true, true)
    Scenario.WriteToBlackboard(Scenario.LUAPropIDs.CAVES_POSTXRELEASE_APPLIED, "b", true)
    CAVES_POSTXRELEASE_APPLIED = true
  end
end









function s010_cave.OnBegin_Cutscene_intro_space()

    
    
  local oIntroSpace = Game.GetActor("cutsceneplayer_intro_space")
  if oIntroSpace ~= nil then
    local oIntroFlashbackInit = Game.GetActor("cutsceneplayer_intro_flashbackinit")
    if oIntroFlashbackInit ~= nil then
      oIntroSpace.CUTSCENE:QueueCutscenePlayer(oIntroFlashbackInit) 
      local oIntroLanding =  Game.GetActor("cutsceneplayer_intro_landing")
      if oIntroLanding ~= nil then
        oIntroFlashbackInit.CUTSCENE:QueueCutscenePlayer(oIntroLanding)
        local oIntroArrivalAtrium = Game.GetActor("cutsceneplayer_intro_arrivalatrium")
        if oIntroArrivalAtrium ~= nil then
          oIntroLanding.CUTSCENE:QueueCutscenePlayer(oIntroArrivalAtrium)
          local oIntroFight = Game.GetActor("cutsceneplayer_intro_fight")
          if oIntroFight ~= nil then
            oIntroArrivalAtrium.CUTSCENE:QueueCutscenePlayer(oIntroFight)
            local oIntroFlashbackEnd = Game.GetActor("cutsceneplayer_intro_flashbackend")
            if oIntroFlashbackEnd ~= nil then
              oIntroFight.CUTSCENE:QueueCutscenePlayer(oIntroFlashbackEnd)
            end
          end
        end
      end
    end
    
    oIntroSpace.CUTSCENE:TryLaunchCutscene()
  end
end

function s010_cave.OnEnd_Cutscene_intro_end()
    
  
  Scenario.WriteToBlackboard(Scenario.LUAPropIDs.CAVES_GAME_INTRO, "b", true)
  CAVES_GAME_INTRO = true
  Game.PushSetup("PostIntro", true, true)
  Game.PlayCurrentEnvironmentMusic()
  -- Game.SaveGame("savedata", "IntroEnd", "StartPoint0", true)
end





function s010_cave.OnEmmyCaveDead()
    
    
    
    
    
    
    
    
    
  Game.PushSetup("PostEmmy", true, true)
end

function s010_cave.OnEmmyAbilityObtainedFadeOutCompleted()
    
  local L0_2 = Game.GetActor("ev_entercu_cv_001")
  if L0_2 ~= nil then
    L0_2.TUNNEL_TRAP:SetOpenState()
  end  
  --Game.GetActor("Door062 (PW-PW, Special)").LIFE:LockDoor()
  local L1_2 = Game.GetActor( "SG_WarLotus_000")
  if L1_2 ~= nil then
    L1_2.SPAWNGROUP:EnableSpawnGroup()
  end  
  local L2_2 = Game.GetActor("PRP_CV_CentralUnitCaves")
  if L2_2 ~= nil then
    L2_2.CENTRALUNIT:OnEmmyAbilityObtainedFadeOutCompleted()
  end
end


function s010_cave.DelayedOnEmmyCaveDead()
    
  local cu_door = Game.GetActor("Door017 (CU)_000")
  if cu_door ~= nil then
    cu_door.LIFE:UnLockDoor()
  end
    
    
    
    
end

function s010_cave.OnEmmyDeathMessageSkipped()
end

s010_cave.tGetOnDeathOverrides = {ShowDeath = true, GoToMainMenu = false}
function s010_cave.GetOnDeathOverrides()
  return s010_cave.tGetOnDeathOverrides
end


function s010_cave.SPRTutoTriggerEnable()
  Game.AddSF(0.1, "s010_cave.DelayedSPRTutoTriggerEnable", "")
end


function s010_cave.DelayedSPRTutoTriggerEnable()
  local oActor = Game.GetActor("SPRCentralUnitTutoTrigger") 
  if oActor ~= nil then
    oActor.bEnabled = true
  end
end


function s010_cave.SPBTutoTriggerEnable()
  Game.AddSF(0.1, "s010_cave.DelayedSPBTutoTriggerEnable", "")
end


function s010_cave.DelayedSPBTutoTriggerEnable()
  local oActor = Game.GetActor("SPBCentralUnitTutoTrigger")
  if oActor ~= nil then
    oActor.bEnabled = true
  end
end




function s010_cave.OnBeforeGenerate()
end


function s010_cave.OnEmmyCaveGenerated(_ARG_0_, _ARG_1_)
  CurrentScenario.oEmmyEntity = _ARG_1_
  AI.SetWorldGraphToEmmy("LE_WorldGraph", _ARG_1_.sName)
  s010_cave.ChangePatrolEmmy("PATROLROUTE_02")
  print("EMMY: Generation OK. Starting patrol: " .. _ARG_1_.AI.sCurrentPatrol)
end


function s010_cave.EmmyCaveSpawnSequence()
    
  --local oActor1 = Game.GetActor("Door062 (PW-PW, Special)")
  --if oActor1 ~= nil then
  --  oActor1.LIFE:CloseDoor(true, true, true)
  --  oActor1.LIFE:LockDoor()
  --end
  
  local oActor2 = Game.GetActor("PRP_CV_CentralUnitCaves")
  if oActor2 ~= nil then
    oActor2.CENTRALUNIT:Activate()
  else
    print("CENTRAL_UNIT: PRP_CV_CentralUnitCaves not found")
  end
  
  local oActor3 = Game.GetActor("TG_EnableSpawnEmmy")
  if oActor3 ~= nil then
    oActor3.bEnabled = false
  end
  
  --GUI.AddEmmyMissionLogEntry("#MLOG_ENCOUNTER_EMMY_CAVE")
  if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
    CurrentScenario.oEmmyEntity.bEnabled = true
  end
  
  Scenario.WriteToBlackboard(Scenario.LUAPropIDs.CAVES_EMMY_SPAWNED, "b", true)
  CAVES_EMMY_SPAWNED = true
end


function s010_cave.EmmyCaveSpawnSequenceEnd()
  if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
    CurrentScenario.oEmmyEntity.AI:OnPresentationCutsceneEnd()
  end
end


function s010_cave.EmmyProtoSpawnSequence()
  local oActor = Game.GetActor("PRP_CV_CentralUnitProto")
  if oActor ~= nil then
    oActor.CENTRALUNIT:Activate()
  else
    print("CENTRAL_UNIT: PRP_CV_CentralUnitProto not found")
  end
  
  GUI.AddEmmyMissionLogEntry("#MLOG_ENCOUNTER_PROTOEMMY_CAVE")
end


function s010_cave.OnEmmyProtoGenerated(_ARG_0_, _ARG_1_)
  CurrentScenario.oEmmyProtoEntity = _ARG_1_
end


function s010_cave.EmmyProtoClimbSequenceMessageSkipped()
  local oActor1  =  Game.GetActor("LM_AfterEmmyProtoClimbSequence_Samus")
  local oPlayer = Game.GetPlayer()
  
  if oPlayer ~= nil and oActor1 ~= nil then
    oPlayer.vPos = oActor1.vPos
    oPlayer.vAng = oActor1.vAng
  end
  
  local oActor2 = Game.GetActor("LM_AfterEmmyProtoClimbSequence_Emmy")
  if CurrentScenario.oEmmyProtoEntity ~= nil and oActor2 ~= nil then
    CurrentScenario.oEmmyProtoEntity.bEnabled = false
    CurrentScenario.oEmmyProtoEntity.vPos = oActor2.vPos
    CurrentScenario.oEmmyProtoEntity.vAng = oActor2.vAng
    CurrentScenario.oEmmyProtoEntity.bEnabled = true
  end
end





function s010_cave.OnProtoEmmyCantClimbCutsceneStart()   
    
  local oActor = Game.GetActor("LM_AfterEmmyProtoClimbSequence_Emmy")
  if CurrentScenario.oEmmyProtoEntity ~= nil and oActor ~= nil then
    CurrentScenario.oEmmyProtoEntity.bEnabled = false
    CurrentScenario.oEmmyProtoEntity.vPos = oActor.vPos
    CurrentScenario.oEmmyProtoEntity.vAng = oActor.vAng
    CurrentScenario.oEmmyProtoEntity.ANIMATION:SetAction("relax", true)
    CurrentScenario.oEmmyProtoEntity.bEnabled = true
  end
end


function s010_cave.OnProtoEmmyCantClimbCutsceneEnd()
  print("OnProtoEmmyCantClimbCutsceneEnd")
  if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyProtoEntity) then
    CurrentScenario.oEmmyProtoEntity.AI:OnPresentationCutsceneEnd()
  end
end


function s010_cave.OnProtoEmmyWalkThroughCentralUnitDoor()
  local oActor1 = Game.GetActor("TG_PROTOEMMY_ACTIVATE")
  if oActor1 ~= nil then
    oActor1.bEnabled = true
  end
  local oActor2 = Game.GetActor("TG_PROTOEMMY_ACTIVATE_TIMER")
  if oActor2 ~= nil then
    oActor2.bEnabled = true
  end
end


function s010_cave.OnAimCameraPossess()
    
    
  
  local L0_2 = Game.GetActor("TG_PROTOEMMY_ACTIVATE_TIMER")
  if L0_2 ~= nil and L0_2.bEnabled == false then
    local L1_2 = Game.GetActor("TG_PROTOEMMY_ACTIVATE")
    if L1_2 ~= nil and L1_2.bEnabled then
      s010_cave.OnEnter_ActivateProtoEmmy()
      L1_2.bEnabled = false
    end
  end
end


function s010_cave.OnEnter_ActivateProtoEmmy()
    
  if CurrentScenario.oEmmyProtoEntity ~= nil then
    CurrentScenario.oEmmyProtoEntity.bEnabled = true
    CurrentScenario.oEmmyProtoEntity.AI:StandStillFor(1)
  end
  local oActor1 = Game.GetActor("TG_PROTOEMMY_ACTIVATE")
  if oActor1 ~= nil then
    oActor1.bEnabled = false
  end
  local oActor2 = Game.GetActor("TG_PROTOEMMY_ACTIVATE_TIMER")
  if oActor2 ~= nil then
    oActor2.bEnabled = false
  end
end


function s010_cave.OnEnter_ActivateProtoEmmyTimer()
  Game.AddSF(3, "s010_cave.OnAimCameraPossess", "")
  
  local oActor = Game.GetActor("TG_PROTOEMMY_ACTIVATE_TIMER") 
  if oActor ~= nil then
    oActor.bEnabled = false
  end  
end




function s010_cave.PatrolRoutesGeneration()
  
  

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
    oEmmy.SPAWNPOINT:AddPatrolShape("LS_PATROLEMMY_15")
    oEmmy.SPAWNPOINT:AddPatrolShape("LS_PATROLTUTOFOCUS")
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
  AI.AddPatrol("LE_WorldGraph", "PATROLROUTE_15", "LS_PATROLEMMY_15")
  AI.AddPatrol("LE_WorldGraph", "PATROLTUTOFOCUS", "LS_PATROLTUTOFOCUS")
  
  print("s010_cave.PatrolRoutesGeneration(): Patrol designation OK")
end

function s010_cave.PatrolRoutesFinalNodesAssignation()
 
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_01", { "WorldGraph_60"}, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_01", { "WorldGraph_69", "WorldGraph_70", "WorldGraph_72" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_02", { "WorldGraph_73", "WorldGraph_70" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_02", { "WorldGraph_51", "WorldGraph_60" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_02", { "WorldGraph_59" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_03", { "WorldGraph_65" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_03", { "WorldGraph_59" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_03", { "WorldGraph_52", "WorldGraph_53" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_03", { "WorldGraph_36" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_03", { "WorldGraph_45" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_04", { "WorldGraph_36" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_04", { "WorldGraph_44", "WorldGraph_45"  }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_04", { "WorldGraph_52" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_04", { "WorldGraph_50" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_04", { "WorldGraph_60", "WorldGraph_61" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_05", { "WorldGraph_32", "WorldGraph_38" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_05", { "WorldGraph_34", "WorldGraph_37" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_05", { "WorldGraph_41" , "WorldGraph_42" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_06", { "WorldGraph_25" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_06", { "WorldGraph_28", "WorldGraph_37" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_06", { "WorldGraph_40" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_07", { "WorldGraph_15", "WorldGraph_22" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_07", { "WorldGraph_9", "WorldGraph_11" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_07", { "WorldGraph_16", "WorldGraph_18" }, 2)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_07", { "WorldGraph_25", "WorldGraph_33" }, 3)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_08", { "WorldGraph_9" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_08", { "WorldGraph_1" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_08", { "WorldGraph_15" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_09", { "WorldGraph_2" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_09", { "WorldGraph_4" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_09", { "WorldGraph_0", "WorldGraph_7" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_10", { "WorldGraph_111", "WorldGraph_112" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_10", { "WorldGraph_105", "WorldGraph_103" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_10", { "WorldGraph_98", "WorldGraph_101" }, 2)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_11", { "WorldGraph_116", "WorldGraph_126" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_11", { "WorldGraph_115", "WorldGraph_123" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_12", { "WorldGraph_59" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_12", { "WorldGraph_92" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_12", { "WorldGraph_56" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_12", { "WorldGraph_60" }, 2)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_13", { "WorldGraph_71", "WorldGraph_73" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_13", { "WorldGraph_72", "WorldGraph_65" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_13", { "WorldGraph_97", "WorldGraph_93" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_13", { "WorldGraph_90" }, 2)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_14", { "WorldGraph_88" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_14", { "WorldGraph_96" }, 1)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_14", { "WorldGraph_80", "WorldGraph_79" }, 2)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_14", { "WorldGraph_76" }, 2)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_15", { "WorldGraph_88" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_15", { "WorldGraph_80" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_15", { "WorldGraph_76" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLROUTE_15", { "WorldGraph_85" }, 0)
  AI.SetPatrolFinalNode("LE_WorldGraph", "PATROLTUTOFOCUS", { "WorldGraph_21" }, 0)
  print("s010_cave.PatrolRoutesFinalNodesAssignation(): Final Nodes Assignation OK")
end




function s010_cave.ChangePatrolEmmy(_ARG_0_)
    
    
  if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
    CurrentScenario.oEmmyEntity.AI.sCurrentPatrol = _ARG_0_
    print("EMMY: Assigned route " .. _ARG_0_)
  else
    print("EMMY: Not found, route " .. _ARG_0_ .. " not assigned")
  end
end

function s010_cave.OnEnter_PatrolEmmyActivator(_ARG_0_, _ARG_1_)
  local sPatrol = string.gsub(_ARG_0_.sName, "TG_PATROLEMMYACTIVATOR_", "PATROLROUTE_")
  s010_cave.ChangePatrolEmmy(sPatrol)
end

function s010_cave.OnExit_PatrolEmmyActivator(_ARG_0_, _ARG_1_)

end


s010_cave.tEmmyDoor = nil




function s010_cave.OnWalkThroughEmmyDoor(_ARG_0_, _ARG_1_, _ARG_2_)
    
    
    
    
    
  if CAVES_EMMY_SPAWNED then
    if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
      if _ARG_1_ then
        if CurrentScenario.oEmmyEntity ~= nil then
          if _ARG_2_ then
            sTeleportLandmark = s010_cave.HardEmmyRelocationDoor(_ARG_0_)
          else
            sTeleportLandmark = s010_cave.EmmyRelocationDoor(_ARG_0_)
          end
          if sTeleportLandmark ~= nil then
            local L3_2 = Game.GetActor(sTeleportLandmark)
            print(L3_2)
            if L3_2 ~= nil then
              CurrentScenario.oEmmyEntity.bEnabled = false
              CurrentScenario.oEmmyEntity.vPos =  L3_2.vPos
              CurrentScenario.oEmmyEntity.vAng = L3_2.vAng
              if s010_cave.Check_WakeUpCU_Completed(_ARG_0_) then
                CurrentScenario.oEmmyEntity.bEnabled = true
              end
            end
          end
        end
      else 
        CurrentScenario.oEmmyEntity.bEnabled = false
      end
    end
  end
end

function s010_cave.HardEmmyRelocationDoor(_ARG_0_)
    
    
    
    
    
    
  print("Door: Hard " .. _ARG_0_.sName)
  
  if _ARG_0_.sName == "DoorEmmy03" then
    s010_cave.tEmmyDoor = {
        "LM_EmmyEntrancePoint_004"
    }
  elseif _ARG_0_.sName == "DoorEmmy02" then
    s010_cave.tEmmyDoor = {
        "LM_EmmyEntrancePoint_005"
    }
  elseif _ARG_0_.sName == "DoorEmmy01" then
    s010_cave.tEmmyDoor = {
        "LM_EmmyEntrancePoint_008"
    }
  elseif _ARG_0_.sName == "DoorEmmy10" then
    s010_cave.tEmmyDoor = {
        "LM_EmmyEntrancePoint_012"
    }
  elseif _ARG_0_.sName == "DoorEmmy11" then
    s010_cave.tEmmyDoor = {
        "LM_EmmyEntrancePoint_011","LM_EmmyEntrancePoint_013"
    }
  elseif _ARG_0_.sName == "DoorEmmy06" or _ARG_0_.sName == "DoorEmmy07" then
    local bEnabled = Blackboard.GetProp("s010_cave", "TG_TutoFocus_Caves_001:TRIGGER:Enabled")
    
    if bEnabled == false then
      s010_cave.tEmmyDoor = {
          "LM_EmmyEntrancePoint_000"
      }
    else
      s010_cave.tEmmyDoor = nil
    end
  else
    s010_cave.tEmmyDoor = nil
  end
  
  if s010_cave.tEmmyDoor ~= nil then
    return s010_cave.tEmmyDoor[math.random(table.maxn(s010_cave.tEmmyDoor))]
  else
    return nil
  end
end

function s010_cave.EmmyRelocationDoor(_ARG_0_)

    
    
    
    
    
  if _ARG_0_.sName == "DoorEmmy03" then
    s010_cave.tEmmyDoor = {
      "LM_EmmyEntrancePoint_003",
      "LM_EmmyEntrancePoint_004"
    }
  elseif _ARG_0_.sName == "DoorEmmy02" then
    s010_cave.tEmmyDoor = {
      "LM_EmmyEntrancePoint_005",
      "LM_EmmyEntrancePoint_006"
    }
  elseif _ARG_0_.sName == "DoorEmmy01" then
    s010_cave.tEmmyDoor = {
      "LM_EmmyEntrancePoint_008",
      "LM_EmmyEntrancePoint_009",
      "LM_EmmyEntrancePoint_010"
    }
  elseif _ARG_0_.sName == "DoorEmmy10" then
    s010_cave.tEmmyDoor = {
      "LM_EmmyEntrancePoint_011",
      "LM_EmmyEntrancePoint_012"
    }
  elseif _ARG_0_.sName == "DoorEmmy11" then
    s010_cave.tEmmyDoor = {
      "LM_EmmyEntrancePoint_011",
      "LM_EmmyEntrancePoint_013"
    }
  elseif _ARG_0_.sName == "DoorEmmy06" or _ARG_0_.sName == "DoorEmmy07" then
      
    local bEnabled = Blackboard.GetProp("s010_cave", "TG_TutoFocus_Caves_001:TRIGGER:Enabled")
    if bEnabled == false then
      s010_cave.tEmmyDoor = {
        "LM_EmmyEntrancePoint_000",
        "LM_EmmyEntrancePoint_001",
        "LM_EmmyEntrancePoint_002"
      }
    else
      s010_cave.tEmmyDoor = nil
    end
  else
    s010_cave.tEmmyDoor = nil
  end
  
  if s010_cave.tEmmyDoor ~= nil then
    return s010_cave.tEmmyDoor[math.random(table.maxn(s010_cave.tEmmyDoor))]
  else
    return nil
  end
end





function s010_cave.OnTeleport_Checkpoint_CU()
  Game.AddSF(1, "s010_cave.Checkpoint_RelocatingEmmy_CU", "")
end

function s010_cave.Checkpoint_RelocatingEmmy_CU()
  Game.GetActor("DreadRando_CUDoor").bEnabled = false
  if CurrentScenario.oEmmyEntity ~= nil then
    local oActor = Game.GetActor("LM_EmmyDestroySearchLandmark01")
    if  oActor ~= nil then
        CurrentScenario.oEmmyEntity.bEnabled = false
        CurrentScenario.oEmmyEntity.vPos = oActor.vPos
        CurrentScenario.oEmmyEntity.vAng = oActor.vAng
        CurrentScenario.oEmmyEntity.bEnabled = true
        s010_cave.ChangePatrolEmmy("PATROLROUTE_14")
    end
  end
end




function s010_cave.ActivateGrabOverride_Right()
  local oActor1 = Game.GetActor("LS_EmmyGrabOverride_000")
  local oActor2 = Game.GetActor("LS_EmmyGrabOverride_001")
  if oActor1 ~= nil and oActor2 ~= nil then
    oActor2.bEnabled = false
    oActor1.bEnabled = true
  end
end

function s010_cave.ActivateGrabOverride_Left()
  local oActor1 = Game.GetActor("LS_EmmyGrabOverride_000")
  local oActor2 = Game.GetActor("LS_EmmyGrabOverride_001")
  if oActor1 ~= nil and oActor2 ~= nil then
    oActor1.bEnabled = false
    oActor2.bEnabled = true
  end
end




function s010_cave.EmmyCaveTryToEndStagger()
    
  if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
      local oActor1 =  Game.GetActor("LS_EmmyEndStagger_000")
      if oActor1 ~= nil and oActor1.LOGICSHAPE:IsActorInside(CurrentScenario.oEmmyEntity) then
        CurrentScenario.oEmmyEntity.AI:ForceStopStagger()
      end
  end
end


s010_cave.tWaterPoolsToEnable = {
  "PRP_CV_watercave02",
  "PRP_CV_watercave05",
  "waterstream01_caveinit",
  "waterstream01_caveinit_001",
  "waterstream01_caveinit_002",
  "waterstream01_caveinit_003",
  "waterstream01_caveinit_004",
  "waterstream01_caveinit_005"
}




function s010_cave.Event_WaterPoolInfiltration_Activate()
  print("Event_WaterPoolInfiltration started!")
  
  
  
  for _FORV_3_, _FORV_4_ in ipairs(s010_cave.tWaterPoolsToEnable) do
    local oActor = Game.GetActor(_FORV_4_)
    if oActor ~= nil then
      oActor.bEnabled = true
    else
      print("Entity " .. _FORV_4_ .. " not found")
    end
  end
  
  local oActor = Game.GetActor("Watervalve_fillmap")
  if oActor ~= nil then
    Game.SetMinimapRegionVisited("Watervalve_fillmap")
  end
end


function s010_cave.Event_WaterPoolInfiltration_Deactivate()
    
    
    
  for _FORV_3_, _FORV_4_ in ipairs(s010_cave.tWaterPoolsToEnable) do
    local oActor = Game.GetActor(_FORV_4_)
    if oActor ~= nil then
      oActor.bEnabled = false
    else
      print("Entity " .. _FORV_4_ .. " not found")
    end
  end
end




function s010_cave.Event_EmmyPatrolFocusTutorial_DisableEmmy()  
    
  if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
    CurrentScenario.oEmmyEntity.bEnabled = false
  else
    print("Emmy not found")
  end
  Game.GetActor("Door062 (PW-PW, Special)").LIFE:UnLockDoor()
  print("Emmy deshabilitado")
end

function s010_cave.Event_EmmyWaterValveTutorial()
    
  print("Event: Water valve tutorial")
  if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
    local oActor = Game.GetActor("LM_Emmy_WaterPlant")
    CurrentScenario.oEmmyEntity.bEnabled = false
    CurrentScenario.oEmmyEntity.vPos = oActor.vPos
    CurrentScenario.oEmmyEntity.vAng = oActor.vAng
    CurrentScenario.oEmmyEntity.bEnabled = true
    CurrentScenario.oEmmyEntity.ANIMATION:SetAction("standby", true)
  end
end

function s010_cave.Event_EmmyPatrolFocusTutorial()
    
    
    
    
    
    
  local oPlayer = Game.GetPlayer()
  if oPlayer ~= nil then
    print("Event: Patrol Focus Tutorial")
    if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
      local oActor = Game.GetActor("LM_TutoFocus_EmmyNoFocusTutorialPoint")
      CurrentScenario.oEmmyEntity.bEnabled = false
      CurrentScenario.oEmmyEntity.vPos = oActor.vPos
      CurrentScenario.oEmmyEntity.vAng = oActor.vAng
      CurrentScenario.oEmmyEntity.bEnabled = true
    else
      print("Emmy not found")
    end
  end
end




function s010_cave.OnEnter_ChangeMusic_ScrewAttack()
  Game.PushSetup("ScrewAttack", true, true)
end
function s010_cave.OnExit_ChangeMusic_ScrewAttack()
  Game.PopSetup("ScrewAttack", true, true)
end






function s010_cave.OnEnter_ChangeCamera_003_B()
  Game.SetCollisionCameraLocked("collision_camera_003_B", true)
end

function s010_cave.OnCaptionFinished()
  print("caption finished")
end

function s010_cave.OnExit_ChangeCamera_003_B()
  Game.SetCollisionCameraLocked("collision_camera_003_B", false)
end

function s010_cave.OnEnter_ChangeCamera_003_C()
  Game.SetCollisionCameraLocked("collision_camera_003_C", true)
end
function s010_cave.OnExit_ChangeCamera_003_C()
  Game.SetCollisionCameraLocked("collision_camera_003_C", false)
end

function s010_cave.OnEnter_ChangeCamera_050_B()
  Game.SetCollisionCameraLocked("collision_camera_050_B", true)
end
function s010_cave.OnExit_ChangeCamera_050_B()
  Game.SetCollisionCameraLocked("collision_camera_050_B", false)
end

function s010_cave.OnEnter_ChangeCamera_056_B()
  Game.SetCollisionCameraLocked("collision_camera_056_B", true)
end
function s010_cave.OnExit_ChangeCamera_056_B()
  Game.SetCollisionCameraLocked("collision_camera_056_B", false)
end

function s010_cave.OnEnter_ChangeCamera_056_C()
  Game.SetCollisionCameraLocked("collision_camera_056_C", true)
end
function s010_cave.OnExit_ChangeCamera_056_C()
  Game.SetCollisionCameraLocked("collision_camera_056_C", false)
end

function s010_cave.OnEnter_ChangeCamera_064B()
  local oProp = Blackboard.GetProp("PLAYER_INVENTORY", "ITEM_CENTRAL_UNIT_DECAYED_ENERGY")
  if oProp ~= nil and oProp > 0 then
    Game.SetCollisionCameraLocked("collision_camera_064B", false)
  else
    Game.SetCollisionCameraLocked("collision_camera_064B", true)
  end
end

function s010_cave.OnExit_ChangeCamera_064B()
  Game.SetCollisionCameraLocked("collision_camera_064B", false)
end

function s010_cave.OnEnter_ChangeCamera_015_B()
  Game.SetCollisionCameraLocked("collision_camera_015_B", true)
end
function s010_cave.OnExit_ChangeCamera_015_B()
  Game.SetCollisionCameraLocked("collision_camera_015_B", false)
end

function s010_cave.OnEnter_ChangeCamera_031_B()
  Game.SetCollisionCameraLocked("collision_camera_031_B", true)
end
function s010_cave.OnExit_ChangeCamera_031_B()
  Game.SetCollisionCameraLocked("collision_camera_031_B", false)
end


function s010_cave.OnEnter_ChangeCamera_048_C()
  local oActor = Game.GetActor("TG_ChangeCamera_048_B")
  oActor.bEnabled = false  
  print("OnEnter_ChangeCamera_048_C")
  Game.SetCollisionCameraLocked("collision_camera_048_C", true)
end

function s010_cave.OnEnter_ChangeCamera_048_C_Delayed()
  local oActor = Game.GetActor("TG_ChangeCamera_048_C")
  oActor.bEnabled = true
end

function s010_cave.OnExit_ChangeCamera_048_C()
  Game.SetCollisionCameraLocked("collision_camera_048_C", false)
  print("OnExit_ChangeCamera_048_C")
  Game.AddSF(0, "s010_cave.OnEnter_ChangeCamera_048_B_Delayed", "")
end

function s010_cave.OnEnter_ChangeCamera_048_B()
  local oActor = Game.GetActor("TG_ChangeCamera_048_C")
  oActor.bEnabled = false
  Game.SetCollisionCameraLocked("collision_camera_048_B", true)
  print("OnEnter_ChangeCamera_048_B")
end

function s010_cave.OnEnter_ChangeCamera_048_B_Delayed()
  local oActor = Game.GetActor("TG_ChangeCamera_048_B")
  oActor.bEnabled = true
end

function s010_cave.OnExit_ChangeCamera_048_B()
  Game.SetCollisionCameraLocked("collision_camera_048_B", false)
  print("OnExit_ChangeCamera_048_B")
  Game.AddSF(0, "s010_cave.OnEnter_ChangeCamera_048_C_Delayed", "")
end

function s010_cave.OnEnter_DisableCamera_048()
  Game.PushSetup("DisableCamera_048", false, true)
end

function s010_cave.OnExit_DisableCamera_048()
  Game.PopSetup("DisableCamera_048", false, true)
end

function s010_cave.OnEnter_ChangeCamera_023_B()
  Game.PushSetup("ChangeCamera_023_B", false, true)
end
function s010_cave.OnExit_ChangeCamera_023_B()
  Game.PopSetup("ChangeCamera_023_B", false, true)
end

function s010_cave.OnEnter_ChangeCamera_091_B()
  Game.SetCollisionCameraLocked("collision_camera_091_B", true)
end
function s010_cave.OnExit_ChangeCamera_091_B()
  Game.SetCollisionCameraLocked("collision_camera_091_B", false)
end





















function s010_cave.OnEnter_ChangeCamera_Far()
  Game.GetCamera().CAMERA:SetLogicCameraParams("CAM_Far", true)
  print("OnEnter_ChangeCamera_Far")
end

function s010_cave.OnExit_ChangeCamera_Far()
  Game.GetCamera().CAMERA:SetLogicCameraParams("CAM_Default", true)
  print("OnExit_ChangeCamera_Far")
end


function s010_cave.OnEnter_EnableFade()
  print("Enable Fade")
  Game.SetSubAreasPreferredTransitionType("Fade")
end

function s010_cave.OnExit_DisableFade()
  print("Disable Fade")
  Game.SetSubAreasPreferredTransitionType("None")
end


function s010_cave.OnEnter_DeactivationEmmy_CameraRail_CU()
  print("EMMY DEACTIVATE")
  if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
    print("EMMY DEACTIVATION")
    CurrentScenario.oEmmyEntity.bEnabled = false
  end
end
function s010_cave.OnExit_ActivationEmmy_CameraRail_CU()
  if Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
    local oActor = Game.GetActor("LM_EnterEmmyZoneSecondTime")
    CurrentScenario.oEmmyEntity.bEnabled = false
    CurrentScenario.oEmmyEntity.vPos = oActor.vPos
    CurrentScenario.oEmmyEntity.vAng = oActor.vAng
    CurrentScenario.oEmmyEntity.bEnabled = true
  end
end




function s010_cave.OnEnter_AP_01()
  Scenario.CheckRandoHint("PRP_CV_AccessPoint001", "CAVE_1")
end

function s010_cave.OnEnter_AP_02()
  Scenario.CheckRandoHint("PRP_CV_AccessPoint002", "CAVE_2")
end





function s010_cave.OnLE_Platform_Elevator_FromMagma(_ARG_0_, _ARG_1_, _ARG_2_)
  Elevator.Use("c10_samus", "s020_magma", "ST_FromCave", _ARG_2_)
end






function s010_cave.SubAreaChangeRequest(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_)
  Scenario.SubAreaChangeRequest(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_)
end


function s010_cave.OnSubAreaChange(old_subarea, old_actorgroup, new_subarea, new_actorgroup, disable_fade)
  if old_subarea == "collision_camera_005" and new_subarea == "collision_camera_006" then
    if disable_fade and CAVES_EMMY_SPAWNED == false then
        Game.SetSubAreasPreferredTransitionType("None")
    elseif Scenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
        if CurrentScenario.oEmmyEntity.bEnabled == false then
          if CAVES_CENTRAL_UNIT_WAKE_UP_CUTSCENE_LAUNCHED == true then
            CurrentScenario.oEmmyEntity.bEnabled = true
            print("EMMY REACTIVATION AFTER WAKE-UP CU")
          end
        end
    end
    
    --local oActor = Game.GetActor("cutsceneplayer_37")
    --if oActor ~= nil then
    --  oActor.CUTSCENE:TryLaunchCutscene()
    --end
  elseif old_subarea == "collision_camera_064" and new_subarea == "collision_camera_074" then
    if disable_fade then
      local oActor = Game.GetActor("TG_EnableSubareaChangeFade_001")
      if oActor ~= nil then
        oActor.bEnabled = false
      end
    end
    
    local oActor = Game.GetActor("cutsceneplayer_48")
    if oActor ~= nil then
      oActor.CUTSCENE:TryLaunchCutscene()
    end
  elseif old_subarea == "collision_camera_002" and new_subarea == "collision_camera_003" then
    local oActor = Game.GetActor("cutsceneplayer_5")
    if oActor ~= nil then
      oActor.CUTSCENE:TryLaunchCutscene()
    end
  -- elseif old_subarea == "collision_camera_000" and new_subarea == "collision_camera_068" then
    
  --     local oActor = Game.GetActor("cutsceneplayer_3")
  --   if oActor ~= nil then
  --     oActor.CUTSCENE:TryLaunchCutscene()
  --   end
  elseif old_subarea == "collision_camera_073" and new_subarea == "collision_camera_020" then
    local oActor = Game.GetActor("cutsceneplayer_54")
    if oActor ~= nil then
      oActor.CUTSCENE:TryLaunchCutscene()
    end
  elseif old_subarea == "collision_camera_049" and new_subarea == "collision_camera_090" then
    Game.GetActor("DreadRando_CUDoor").bEnabled = false
    local oActor = Game.GetActor("cutsceneplayer_50")
    if oActor ~= nil then
      oActor.CUTSCENE:TryLaunchCutscene()
    end
  elseif old_subarea == "collision_camera_003" and new_subarea == "collision_camera_018" then
    
  --  local oActor = Game.GetActor("cutsceneplayer_49-1")
  --  if oActor ~= nil then
  --    oActor.CUTSCENE:TryLaunchCutscene()
  --  end
  elseif old_subarea == "collision_camera_018" and new_subarea == "collision_camera_005" then
    
  --  local oActor1 = Game.GetActor("cutsceneplayer_49-1")
  --  if oActor1 ~= nil then
  --    if oActor1.CUTSCENE:HasCutsceneBeenPlayed() == true then
  --      local oActor2 = Game.GetActor("cutsceneplayer_49-2")
  --      if oActor2 ~= nil then
  --        oActor2.CUTSCENE:TryLaunchCutscene()
  --      end
  --    end
  --  end
    
    if not CAVES_CENTRAL_UNIT_WAKE_UP_CUTSCENE_LAUNCHED then
      Scenario.WriteToBlackboard(Scenario.LUAPropIDs.CAVES_CENTRAL_UNIT_WAKE_UP_CUTSCENE_LAUNCHED, "b", true)
      CAVES_CENTRAL_UNIT_WAKE_UP_CUTSCENE_LAUNCHED = true
    end
  elseif new_subarea == "collision_camera_049" and 
      old_subarea ~= "collision_camera_090" and
      CurrentScenario.CheckEmmyAlive(CurrentScenario.oEmmyEntity) then
    -- lock CU door except when entering from the CU room if emmi is alive
    local cu_door = Game.GetActor("Door017 (CU)_000")
    if cu_door ~= nil then
      cu_door.LIFE:LockDoor()
    end
  end
end


s010_cave.tTriggersToEnable = {
  "TG_ChainReaction_Camera_001",
  "TG_ChainReaction_SteamJet_016",
  "TG_ChainReaction_SteamJet_017"
}













function s010_cave.OnEnter_ChainReaction_Steamjet(_ARG_0_, _ARG_1_)
  local sName = string.gsub(_ARG_0_.sName, "TG_ChainReaction_SteamJet_", "steammag01_chainreaction_")
  Game.EnableEntityComponent(sName, "ACTIVATABLE")
end

function s010_cave.OnEnter_ChainReaction_Steamjet_CameraShake()
  Game.PlayCameraFXPreset("CHAINREACTION_BIG_EXP")
  Game.PlayPresetSound("chainreaction_rumble_sound_03")
  Game.PlayVibration("props/chainreaction/chain_reaction_rumble_03.bnvib", false)
end


function s010_cave.InitChainReaction()
  Game.AddSF(2.5, "s010_cave.ChainReaction_Preparation", "")
  local oActor = Game.GetActor("camRail_PreChain")
  if oActor ~= nil then
    oActor.bEnabled = false
  end
end

function s010_cave.ChainReaction_Preparation()
    
    
    
  Game.PlayCameraFXPreset("CHAINREACTION_MED_EXP")
  Game.PlayPresetSound("chainreaction_rumble_sound_02")
  Game.PlayVibration("props/chainreaction/chain_reaction_rumble_02.bnvib", false)
  Game.PushSetup("ChainReaction", true, true)
  Game.AddSF(2, "s010_cave.ChainReaction_WaterPumpStep1", "")
end

function s010_cave.ChainReaction_WaterPumpStep1()
  
  
  for _FORV_3_, _FORV_4_ in ipairs(s010_cave.tTriggersToEnable) do
    local oActor = Game.GetActor(_FORV_4_)
    if oActor ~= nil then
      oActor.bEnabled = true
    end
  end
  
  local oActor = Game.GetActor("ev_chainreaction_cv_001")
  if oActor ~= nil then
    Game.PlayCameraFXPreset("CHAINREACTION_MED_EXP")
    Game.PlayPresetSound("chainreaction_rumble_sound_02")
    Game.PlayVibration("props/chainreaction/chain_reaction_rumble_02.bnvib", false)
    oActor.CHAIN_REACTION_ACTION_SWITCHER:ChangeActionAndNavhMeshStage("action1", "action1")
  end
end


function s010_cave.ChainReaction_Drop_CV_002()
  local oActor1 = Game.GetActor("ev_chainreaction_cv_fx_006") 
  if oActor1 ~= nil then
    oActor1:StartTimeline("q_001", true)
  end
  
  local oActor2 = Game.GetActor("ev_chainreaction_cv_fx_007")
  if oActor2 ~= nil then
    oActor2:StartTimeline("q_delay01_001", true)
  end
  
  local oActor3 = Game.GetActor("ev_chainreaction_cv_fx_011")
  if oActor3 ~= nil then
    oActor3:StartTimeline("q_delay01_002", true)
  end
  
  local oActor4 = Game.GetActor("ev_chainreaction_cv_fx_008")
  if oActor4 ~= nil then
    oActor4:StartTimeline("q_002", true)
  end
end


function s010_cave.ChainReaction_Drop_CV_003()
  local oActor1 = Game.GetActor("ev_chainreaction_cv_003")
  if oActor1 ~= nil then
    Game.PlayCameraFXPreset("CHAINREACTION_MED_EXP")
    Game.PlayPresetSound("chainreaction_rumble_sound_02")
    Game.PlayVibration("props/chainreaction/chain_reaction_rumble_02.bnvib", false)
    oActor1.ACTIVATABLE:Activate()
  end
  
  local oActor2 = Game.GetActor("ev_chainreaction_cv_fx_001")
  if oActor2 ~= nil then
    oActor2:StartTimeline("q_001", true)
  end
  
  local oActor3 = Game.GetActor("ev_chainreaction_cv_fx_003")
  if oActor3 ~= nil then
    oActor3:StartTimeline("q_delay01_003", true)
  end
  
  local oActor4 = Game.GetActor("ev_chainreaction_cv_fx_009")
  if oActor4 ~= nil then
    oActor4:StartTimeline("q_002", true)
  end
  
  local oActor5 = Game.GetActor("ev_chainreaction_cv_fx_010")
  if oActor5 ~= nil then
    oActor5:StartTimeline("q_delay01_002", true)
  end
  
  local oActor6 = Game.GetActor("ev_chainreaction_cv_fx_018")
  if oActor6 ~= nil then
    oActor6:StartTimeline("q_delay02_001", true)
  end
  
  local oActor7 = Game.GetActor("ev_chainreaction_cv_fx_015")
  if oActor7 ~= nil then
   oActor7:StartTimeline("q_delay02_001", true)
  end
  
  local oActor8 =  Game.GetActor("ev_chainreaction_cv_fx_016")
  if oActor8 ~= nil then
    oActor8:StartTimeline("q_delay01_002", true)
  end
end


function s010_cave.ChainReaction_WaterPumpPreStep2()
  local oActor = Game.GetActor("ev_chainreaction_cv_001")
  if oActor ~= nil then
    Game.PlayCameraFXPreset("CHAINREACTION_SMALL_EXP")
    oActor.ANIMATION:SetAction("preaction2")
  end
end


function s010_cave.ChainReaction_WaterPumpStep2()
  local oActor = Game.GetActor("ev_chainreaction_cv_001")
  if oActor ~= nil then
    Game.PlayCameraFXPreset("CHAINREACTION_BIG_EXP")
    Game.PlayPresetSound("chainreaction_rumble_sound_03")
    Game.PlayVibration("props/chainreaction/chain_reaction_rumble_03.bnvib", false)
    oActor.CHAIN_REACTION_ACTION_SWITCHER:ChangeActionAndNavhMeshStage("action2", "action2")
  end
end


function s010_cave.ChainReaction_WaterPumpPreStep3()
 local oActor = Game.GetActor("ev_chainreaction_cv_001")
  if oActor ~= nil then
    Game.PlayCameraFXPreset("CHAINREACTION_SMALL_EXP")
    Game.PlayPresetSound("chainreaction_rumble_sound_01")
    Game.PlayVibration("props/chainreaction/chain_reaction_rumble_01.bnvib", false)
    oActor.ANIMATION:SetAction("preaction3")
  end
end


function s010_cave.ChainReaction_WaterPumpStep3()
  local oActor = Game.GetActor("ev_chainreaction_cv_001")
  if oActor ~= nil then
    Game.PlayCameraFXPreset("CHAINREACTION_BIG_EXP")
    Game.PlayPresetSound("chainreaction_rumble_sound_03")
    Game.PlayVibration("props/chainreaction/chain_reaction_rumble_03.bnvib", false)
    oActor.CHAIN_REACTION_ACTION_SWITCHER:ChangeActionAndNavhMeshStage("action3", "action3")
  end
end


function s010_cave.ChainReaction_Drop_CV_005()
  local oActor1 = Game.GetActor("ev_chainreaction_cv_005")
  if oActor1 ~= nil then
    Game.PlayCameraFXPreset("CHAINREACTION_MED_EXP")
    Game.PlayPresetSound("chainreaction_rumble_sound_02")
    Game.PlayVibration("props/chainreaction/chain_reaction_rumble_02.bnvib", false)
    oActor1.ACTIVATABLE:Activate()
  end
  
  local oActor2 = Game.GetActor("ev_chainreaction_cv_fx_004")
  if oActor2 ~= nil then
    oActor2:StartTimeline("q_001", true)
  end
  
  local oActor3 = Game.GetActor("ev_chainreaction_cv_fx_000")
  if oActor3 ~= nil then
    oActor3:StartTimeline("q_delay01_001", true)
  end
  
  local oActor4 = Game.GetActor("ev_chainreaction_cv_fx_005")
  if oActor4 ~= nil then
    oActor4:StartTimeline("q_delay02_003", true)
  end
  
  local oActor5 = Game.GetActor("ev_chainreaction_cv_fx_002")
  if oActor5 ~= nil then
    oActor5:StartTimeline("q_002", true)
  end
end


function s010_cave.ChainReaction_Drop_CV_006()
  local oActor1 = Game.GetActor("ev_chainreaction_cv_fx_014")
  if oActor1 ~= nil then
    oActor1:StartTimeline("q_001", true)
  end
  
  local oActor2 = Game.GetActor("ev_chainreaction_cv_fx_012")
  if oActor2 ~= nil then
    oActor2:StartTimeline("q_003", true)
  end
  
  local oActor3 = Game.GetActor("ev_chainreaction_cv_fx_013")
  if oActor3 ~= nil then
    oActor3:StartTimeline("q_004", true)
  end
end


function s010_cave.ChainReaction_BigExplosion()
  
  Game.StopCameraFXPreset("CHAINREACTION_SOFT")
  Game.PlayCameraFXPreset("QUEEN_SHAKING_JUMP")
  Game.PlayPresetSound("events/chainreaction_bigexplosion")
  Game.PlayVibration("props/chainreaction/chainreaction_bigexplosion.bnvib", false)
  
  local oActor = Game.GetActor("env_heat_gen_001_CR_END")
  if oActor ~= nil then
    oActor.bEnabled = true
    oActor.ACTIVATABLE:Activate(1)
  end
end

function s010_cave.ChainReaction_ChangeFinalSetup()
  Game.PopSetup("ChainReaction", true, true)
  Game.PushSetup("Post_ChainReaction", true, true)
  
  local oActor1 = Game.GetActor("ev_chainreaction_cv_004")
  if oActor1 ~= nil then
    oActor1.CHANGE_STAGE_NAVMESH_ITEM:RefreshNavMeshState()
  end
  
  local oActor2 = Game.GetActor("ev_chainreaction_cv_004_a")
  if oActor2 ~= nil then
   oActor2.CHANGE_STAGE_NAVMESH_ITEM:RefreshNavMeshState()
  end
  
  local oActor3 = Game.GetActor("ev_chainreaction_cv_009")
  if oActor3 ~= nil then
    oActor3.CHANGE_STAGE_NAVMESH_ITEM:RefreshNavMeshState()
  end
  
  local oActor4 = Game.GetActor("ev_chainreaction_cv_010")
  if oActor4 ~= nil then
    oActor4.CHANGE_STAGE_NAVMESH_ITEM:RefreshNavMeshState()
  end
  
  local oActor5 = Game.GetActor("db_reg_cv_022")
  if oActor5 ~= nil then
    oActor5.NAVMESHITEM:OverrideInitialStage("initial")
    oActor5.NAVMESHITEM:ChangeStage("initial")
  end
end


function s010_cave.ShakingCameraDelayed()
  Game.PlayCameraFXPreset("CHAINREACTION_SOFT")
end

function s010_cave.ShakingCameraHeatCompleted()
  Game.PlayCameraFXPreset("CHAINREACTION_BIG_EXP")
  Game.PlayPresetSound("chainreaction_rumble_sound_03")
  Game.PlayVibration("props/chainreaction/chain_reaction_rumble_03.bnvib", false)
end


function s010_cave.OnEnter_ChainReaction_ChangeCamera(_ARG_0_, _ARG_1_)
  local L2_2 = string.gsub(_ARG_0_.sName, "TG_ChainReaction_Camera_", "collision_camera_CR_")
  Game.SetCollisionCameraLocked(L2_2, true)
  Game.StopCameraFXPreset("CHAINREACTION_SOFT")
  local L3_2 = string.gsub(_ARG_0_.sName, "TG_ChainReaction_Camera_", "env_heat_gen_001_CR_")
  local L4_2 =  Game.GetActor(L3_2)
  L12_1 = L3_2
  
  
  
  
  
  
  
  
  if L4_2 ~= nil then
    if L4_2.bEnabled == false then
      L4_2.bEnabled = true
      local L5_2 = 4
      local L6_2 = 4
      if L3_2 == "env_heat_gen_001_CR_001" then
        Game.AddSF(4, "s010_cave.ChainReaction_HeatZone_001_Activated",  "")
        L5_2 = 4
        L6_2 = 8
      elseif L3_2 == "env_heat_gen_001_CR_002" then
        Game.AddSF(4, "s010_cave.ChainReaction_HeatZone_002_Activated", "")
        L5_2 = 4
        L6_2 = 8
      elseif L3_2 == "env_heat_gen_001_CR_003" then
        Game.AddSF(11, "s010_cave.ChainReaction_HeatZone_003_Activated", "")
        L5_2 = 11
        L6_2 = 15
      elseif L3_2 == "env_heat_gen_001_CR_004" then
        Game.AddSF(6, "s010_cave.ChainReaction_HeatZone_004_Activated",  "")
        L5_2 = 6
        L6_2 = 10
      elseif L3_2 == "env_heat_gen_001_CR_005" then
        Game.AddSF(6, "s010_cave.ChainReaction_HeatZone_005_Activated", "")
        L5_2 = 6
        L6_2 = 10
      end
    elseif L3_2 == "env_heat_gen_001_CR_001" and L7_1 then
        s010_cave.ShakingCameraDelayed()
      elseif L3_2 == "env_heat_gen_001_CR_002" and L8_1 then
        s010_cave.ShakingCameraDelayed()
      elseif L3_2 == "env_heat_gen_001_CR_003" and L9_1 then
        s010_cave.ShakingCameraDelayed()
      elseif L3_2 == "env_heat_gen_001_CR_004" and L10_1 then
        s010_cave.ShakingCameraDelayed()
      elseif L3_2 == "env_heat_gen_001_CR_005" and L11_1 then
        s010_cave.ShakingCameraDelayed()
      end
  end
end

function s010_cave.ChainReaction_HeatZone_001_Activated()
  L7_1 = true
  if L12_1 == "env_heat_gen_001_CR_001" then
    s010_cave.ShakingCameraDelayed()
  end
end
function s010_cave.ChainReaction_HeatZone_002_Activated()
  L8_1 = true
  if L12_1 == "env_heat_gen_001_CR_002" then
    s010_cave.ShakingCameraDelayed()
  end
end
function s010_cave.ChainReaction_HeatZone_003_Activated()
  L9_1 = true
  if L12_1 == "env_heat_gen_001_CR_003" then
    s010_cave.ShakingCameraDelayed()
  end
end
function s010_cave.ChainReaction_HeatZone_004_Activated()
  L10_1 = true
  if L12_1 == "env_heat_gen_001_CR_004" then
    s010_cave.ShakingCameraDelayed()
  end
end
function s010_cave.ChainReaction_HeatZone_005_Activated()
  L11_1 = true
  if L12_1 == "env_heat_gen_001_CR_005" then
    s010_cave.ShakingCameraDelayed()
  end
end


function s010_cave.OnEnter_ChainReaction_ChangeCamera_000()
  Game.SetCollisionCameraLocked("collision_camera_CR_001", false)
end

function s010_cave.OnEnter_ChainReaction_ChangeCamera_006()
  Game.SetCollisionCameraLocked("collision_camera_CR_005", false)
end





function s010_cave.OnEnter_StartCUProtoEmmy()
    
    
    
  local oActor1 = Game.GetActor("TG_PROTOEMMY_BEHAVIOR_002")
  if oActor1 ~= nil then
    oActor1.bEnabled = false
  end
  
  local oActor2 = Game.GetActor("TG_PROTOEMMY_BEHAVIOR_001") 
  if oActor2 ~= nil then
    oActor2.bEnabled = false
  end
  
  local oActor3 = Game.GetActor("TG_PROTOEMMY_BEHAVIOR_003")
  if oActor3 ~= nil then
    oActor3.bEnabled = true
  end
  
  local oActor4 = Game.GetActor("TG_PROTOEMMY_BEHAVIOR")
  if oActor4 ~= nil then
    oActor4.bEnabled = false
  end
end

function s010_cave.OnEnter_EndCUProtoEmmy()
    
    
  local oActor1 = Game.GetActor("TG_PROTOEMMY_BEHAVIOR_002")
  if oActor1  ~= nil then
    oActor1.bEnabled = true
  end
  
  local oActor2 = Game.GetActor("TG_PROTOEMMY_BEHAVIOR_001")
  if oActor2 ~= nil then
    oActor2.bEnabled = true
  end
  
  local oActor3 = Game.GetActor("TG_PROTOEMMY_BEHAVIOR_003")
  if oActor3 ~= nil then
    oActor3.bEnabled = false
  end
  
  local oActor4 = Game.GetActor("TG_PROTOEMMY_BEHAVIOR")
  if oActor4 ~= nil then
    oActor4.bEnabled = true
  end
end





function s010_cave.SetCooldownFlag(_ARG_0_)
  Game.SetCooldownFlag(_ARG_0_)
end

function s010_cave.GetCooldownFlag(_ARG_0_)
  Game.GetCooldownFlag(_ARG_0_)
end



function s010_cave.OnEnter_CoolDownEvent(_ARG_0_, _ARG_1_)
  
  
  _ARG_0_.bEnabled = false
  Game.AddSF(0.8, "s010_cave.Delayed_CoolDownEventCutscenePlaceholder", "")
  
  local oPlayer = Game.GetPlayer()
  if oPlayer ~= nil then
    oPlayer.INPUT:IgnoreInput(true, false, "CoolDownCutscene")
  end
end

function s010_cave.Delayed_CoolDownEventCutscenePlaceholder()
  
    
  GUI.ShowMessage("#CUT_COOLDOWN", true, "s010_cave.Skipped_CoolDownEventCutscenePlaceholder")
  
  local oPlayer = Game.GetPlayer() 
  if oPlayer ~= nil then
    oPlayer.INPUT:IgnoreInput(false, false, "CoolDownCutscene")
  end
end

function s010_cave.Skipped_CoolDownEventCutscenePlaceholder()
  s010_cave.Cooldown_Activation()
end

function s010_cave.Cooldown_Activation()
  Game.SetCooldownFlag(false)
  s010_cave.Cooldown_Deactivation()
  -- Cooldown has been removed from rando

  -- if Game.GetCurrentGameModeID() ~= "EDITOR" then
  --   Game.SetCooldownFlag(true)
  --   if CAVES_COOLDOWN_APPLIED == false then
  --     Game.PushSetup("Cooldown", true, true)
  --     Scenario.WriteToBlackboard(Scenario.LUAPropIDs.CAVES_COOLDOWN_APPLIED, "b", true)
  --     CAVES_COOLDOWN_APPLIED = true
  --     local oActor = Game.GetActor("elevator_aqua_000_platform")
  --     if oActor ~= nil then
  --       oActor.bEnabled = false
  --     end
  --   end
  -- end
end

function s010_cave.Cooldown_Deactivation()
  if CAVES_COOLDOWN_APPLIED == true then
    Game.PopSetup("Cooldown", true, true)
    Scenario.WriteToBlackboard(Scenario.LUAPropIDs.CAVES_COOLDOWN_APPLIED, "b", false)
    CAVES_COOLDOWN_APPLIED = false
  end
end





function s010_cave.OnCutsceneTheater()
  local L0_2 = Blackboard.GetProp("GAME_PROGRESS", "CUTSCENE_THEATRE_CUTSCENE")
end





function s010_cave.OnBefore_Cutscene_5_Begins()
  local oActor = Game.GetActor("cutsceneplayer_5") 
  if oActor ~= nil then
    oActor.CUTSCENE:SetTakePlayMode(4, "Loop")
  end
end

function s010_cave.OnBegin_Cutscene_5()
  local oActor = Game.GetActor("cutsceneplayer_5")
  if oActor ~= nil then
    oActor.CUTSCENE:TryLaunchCutscene()
  end
end

function s010_cave.OnMeleeTutorialInputPressed()
  local oActor = Game.GetActor("cutsceneplayer_5")
  if oActor ~= nil then
    oActor.CUTSCENE:ContinueCutsceneIfTakeLooped()
  end
end

function s010_cave.OnCutscene0049_01Ended()
  Game.FadeIn(0, 0.5)
end

function s010_cave.OnCutscene0049_02Ended()
  Game.FadeIn(0, 0.5)
end

function s010_cave.OnCutscene0050_Ended()
end

function s010_cave.OpenTrapDoorCutscene50()
end

function s010_cave.Check_WakeUpCU_Completed(_ARG_0_)
    
    
    
    
    
    
  if _ARG_0_.sName == "DoorEmmy11" and not CAVES_CENTRAL_UNIT_WAKE_UP_CUTSCENE_LAUNCHED then
    return false
  else
    return true
  end
end

function s010_cave.OnCutscene34Ended()
  local oActor = Game.GetActor("Door058 (PW-PW)")
  if oActor ~= nil then
    oActor.LIFE:ForceOpenDoor(false, "0034protoemmyappears")
  end
end

function s010_cave.CloseProtoEmmyCeilingGate()
  local oActor = Game.GetActor("LE_GateProtoEmmy")
  if oActor ~= nil then
    oActor.ANIMATION:SetAction("close")
  end
end

function s010_cave.OpenProtoEmmyCorridorPowerDoor()
  local oActor = Game.GetActor("Door058 (PW-PW)")
  if oActor ~= nil then
    Game.SetActorVolumeOverride("Door058 (PW-PW)", 0, 0, "ALL")
    oActor.LIFE:ForceOpenDoor(true, "0034protoemmyappears")
  end
end

function s010_cave.SetVariaSuitForCutscene()
  Game.SetSendReports(false)
  Game.GetPlayer().INVENTORY:SetItemAmount("ITEM_VARIA_SUIT", 1, true)
  Game.SetSendReports(true)
end

function s010_cave.RemoveVariaSuitForCutscene()
  Game.GetPlayer().INVENTORY:SetItemAmount("ITEM_VARIA_SUIT", 0, true)
  Game.GetPlayer().MODELUPDATER.sModelAlias = "Default"
  Game.GetPlayer().MODELUPDATER:ForceUpdate()
end

function s010_cave.SetPlasmaBeamForCutscene()
  Game.SetSendReports(false)
  Game.GetPlayer().INVENTORY:SetItemAmount("ITEM_WEAPON_PLASMA_BEAM", 1, true)
  Game.SetSendReports(true)
end

function s010_cave.RemovePlasmaBeamForCutscene()
  Game.GetPlayer().INVENTORY:SetItemAmount("ITEM_WEAPON_PLASMA_BEAM", 0, true)
end

function s010_cave.OnBeforeCutscene0001FlashbackEndStarted()
  s010_cave.RemoveVariaSuitForCutscene()
  s010_cave.RemovePlasmaBeamForCutscene()
end

function s010_cave.OnBeforeCutscene0001IntroLandingStarted()
  s010_cave.SetVariaSuitForCutscene()
  s010_cave.SetPlasmaBeamForCutscene()
end

function s010_cave.OnBeforeCutscene0001IntroSpaceStarted()
  s010_cave.SetVariaSuitForCutscene()
  s010_cave.SetPlasmaBeamForCutscene()
end

function s010_cave.OnBeforeCutscene0001FlashbackInitStarted()
  s010_cave.RemoveVariaSuitForCutscene()
  s010_cave.RemovePlasmaBeamForCutscene()
end

function s010_cave.OnCutscene0057Ended()
  s010_cave.SwapScorpiusStatues()
end

function s010_cave.OnCutscene0057Finished()
  Game.ResetAndStopUpdateSpecialEnergy()
end

function s010_cave.CheckScorpiusDead()
  local oActor = Game.GetActor("SG_Scorpius")
  if oActor ~= nil then
    print(oActor.SPAWNGROUP.iNumDeaths)
    if oActor.SPAWNGROUP.iNumDeaths > 0 then
      s010_cave.SwapScorpiusStatues()
    end
  end
end

function s010_cave.SwapScorpiusStatues()
  local oActor1 = Game.GetActor("cut_54_scorpiusstatue")
  local oActor2 = Game.GetActor("ev_scorpiusstatue_end")
  if oActor2 ~= nil then
    oActor2.bEnabled = true
  end
  if oActor1 ~= nil then
    oActor1.bEnabled = false
  end
end

function s010_cave.OnCutscene0007Finished()
  local oActor = Game.GetActor("elevator_with_cutscene_aqua_000")
  if oActor ~= nil then
    oActor.USABLE.bFadeInActived = false
  end
end

function s010_cave.OnScorpiusPresentationFinished()
  local oActor = Game.GetActor("SP_Scorpius_scorpius") 
  if oActor ~= nil then
    oActor.AI:NotifyAfterPresentation()
  end
end

function s010_cave.OnScorpiusPresentationSkipped()
  Game.StopMusic(true)
end





function s010_cave.OnEnter_FinishScorpiusEvent(_ARG_0_, _ARG_1_)
  Game.PopSetup("Scorpius_Event", true, true)
  local oActor1 = Game.GetActor("SG_Bigfist_000")
  if oActor1 ~= nil then
    oActor1.SPAWNGROUP:EnableSpawnGroup()
  end  
  local oActor2 = Game.GetActor("SG_ScorpiusEventEnemies")
  if oActor2 ~= nil then
    oActor2.SPAWNGROUP:DisableSpawnGroup()
  end  
  local oActor3 = Game.GetActor("TG_EnableEnemiesAfterScorpiusTail")
  if oActor3 ~= nil then
    oActor3.bEnabled = true
  end
  _ARG_0_.bEnabled = false
end

function s010_cave.OnEnter_EnableEnemiesAfterScorpiusTail(_ARG_0_, _ARG_1_)
  local oActor = Game.GetActor("SG_ScorpiusEventEnemies")
  if oActor ~= nil then
    oActor.SPAWNGROUP:EnableSpawnGroup()
  end
  _ARG_0_.bEnabled = false
end


function s010_cave.OnEnter_InitScorpiusEvent(_ARG_0_, _ARG_1_)
  print("INIT SCORPIUS ANIMATION EVENT")
  Game.PushSetup("Scorpius_Event", true, true)
  _ARG_0_.bEnabled = false
end

function s010_cave.OnEnter_ScorpiusFirstShown(_ARG_0_, _ARG_1_)
  print("ScorpiusFirstAppearance")
  Game.PushSetup("ScorpiusFirstAppearance", true, true)
  _ARG_0_.bEnabled = false
end





function s010_cave.OnEnter_ActivatePostEmmyEnemies(_ARG_0_, _ARG_1_)
  local oActor1 = Game.GetActor("SG_PostEmmy_002")
  local oActor2 = Game.GetActor("SG_PostEmmy_003") 
  if oActor1 ~= nil then
    oActor1.SPAWNGROUP:EnableSpawnGroup()
  end  
  if oActor2 ~= nil then
    oActor2.SPAWNGROUP:EnableSpawnGroup()
  end
  _ARG_0_.bEnabled = false
end




function s010_cave.FakeAdamDialogueWeightPlate()
  local oActor = Game.GetActor("PRP_CV_AccessPoint001_WeightPlate")
  if oActor ~= nil then
    oActor.SMARTOBJECT:SetStateDuringFakeAdamDialogueCutScene()
  end
end

function s010_cave.FakeAdamDialogueBegins()
  local oActor = Game.GetActor("PRP_CV_AccessPoint001_WeightPlate")
  
  if oActor ~= nil then
    oActor.SMARTOBJECT:SetStateAfterCutScene()
  end
  Blackboard.SetProp("GAME_PROGRESS", "ADAMDIALOGUE", "s", "DIAG_ADAM_CAVE_1")
  Blackboard.SetProp("GAME_PROGRESS", "SHOWADAMDIALOGUE", "b", true)
end




function s010_cave.DiscoverAccessPointOnCutScene()
  local oActor = Game.GetActor("PRP_CV_AccessPoint001")
  if oActor ~= nil then
    oActor.USABLE:Discover(true)
    oActor:StartTimeline("discovernotransition", true)
  end
end

function s010_cave.DiscoverNotransitionAccessPointOnCutScene()
  local oActor = Game.GetActor("PRP_CV_AccessPoint001")
  if oActor ~= nil then
    oActor.USABLE:Discover(false)
  end
end




function s010_cave.Enter_CWX_Arena()
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

function s010_cave.Exit_CWX_Arena()
  local oPlayer = Game.GetPlayer()
  
  if oPlayer ~= nil then
    oPlayer.INPUT:IgnoreInput(false, false, "Enter_CWX_Arena")
  end
end






function s010_cave.EnablePostScorpiusTrigger()
  local oActor1 = Game.GetActor("TG_AfterScorpiusBattle")
  if oActor1 ~= nil then
    oActor1.bEnabled = true
  end  
  local oActor2 = Game.GetActor("TG_ActivateArenaSpawngroup")
  if oActor2 ~= nil then
    oActor2.bEnabled = true
  end
end

function s010_cave.OnEnter_ScorpiusArenaAfterBattle(_ARG_0_, _ARG_1_)
  --Game.GetActor("Door062 (PW-PW, Special)").LIFE:UnLockDoor()
  Game.PopSetup("SP_Scorpius_scorpius_Boss_Defeated", true, true)
  Game.PushSetup("PostScorpius", true, true)
  _ARG_0_.bEnabled = false
end

function s010_cave.OnEnter_ActivateArenaSpawngroup(_ARG_0_, _ARG_1_)
  local oActor = Game.GetActor("SG_Bigfist_007")
  if oActor ~= nil then
    oActor.SPAWNGROUP:EnableSpawnGroup()
  end
  _ARG_0_.bEnabled = false
end





function s010_cave.ActivationMeleeTutoReminder()
  Game.AddSF(3, "s010_cave.ActivationMeleeTutoReminder_delayed", "")
end

function s010_cave.ActivationMeleeTutoReminder_02()
  Game.AddSF(2, "s010_cave.ActivationMeleeTutoReminder_02_delayed", "")
end

function s010_cave.ActivationMeleeTutoReminder_03()
  Game.AddSF(2, "s010_cave.ActivationMeleeTutoReminder_03_delayed", "")
end

function s010_cave.ActivationMeleeTutoReminder_delayed()
  local oActor1 = Game.GetActor("MeleeTutoTriggerEnter")
  local oActor2 = Game.GetActor("MeleeTutoTriggerExit")
  
  
  if oActor1 ~= nil and oActor2 ~= nil then
    oActor1.bEnabled = true
    oActor2.bEnabled = true
  end
  
  local oActor3 = Game.GetActor("MeleeTutoTriggerExit_002")
  if oActor3 ~= nil then
    oActor3.bEnabled = true
  end
  
  local oActor4 = Game.GetActor("MeleeTutoTriggerExit_003")
  if oActor4 ~= nil then
    oActor4.bEnabled = true
  end
end

function s010_cave.ActivationMeleeTutoReminder_02_delayed()
  local oActor = Game.GetActor("MeleeTutoTriggerEnter_002")
  if oActor ~= nil then
    oActor.bEnabled = true
  end
end

function s010_cave.ActivationMeleeTutoReminder_03_delayed()
  local oActor = Game.GetActor("MeleeTutoTriggerEnter_003")
  if oActor ~= nil then
    oActor.bEnabled = true
  end
end




function s010_cave.OnUsableFinishInteract(_ARG_0_)
  if _ARG_0_.sName == "PRP_CV_AccessPoint001" or _ARG_0_.sName == "PRP_CV_AccessPoint002" then
    Scenario.SetRandoHintSeen()
  elseif _ARG_0_.sName == "PRP_CV_MapStation001" then
    s010_cave.OnTutoMapRoomBegins(true)
  end
end

function s010_cave.OnUsableCancelUse(_ARG_0_)
  if _ARG_0_.sName == "PRP_CV_AccessPoint001" then
    s010_cave.OnTutoMapOptionsBegins(true)
  elseif _ARG_0_.sName == "PRP_CV_MapStation001" then
    s010_cave.OnTutoMapRoomBegins(true)
  end

  Scenario.ResetGlobalTeleport(actor)
end

function s010_cave.OnUsablePrepareUse(_ARG_0_)
  if _ARG_0_.sName == "PRP_CV_AccessPoint001" then
    s010_cave.OnTutoMapOptionsBegins(false)
  elseif _ARG_0_.sName == "PRP_CV_MapStation001" then
    s010_cave.OnTutoMapRoomBegins(false)
  end

  Scenario.DisableGlobalTeleport(_ARG_0_)
end

function s010_cave.OnUsableUse(_ARG_0_)
  if _ARG_0_.sName == "LE_Elevator_FromMagma" and not CAVES_TUTO_MAP_ROOM_DONE then
    Scenario.WriteToBlackboard(Scenario.LUAPropIDs.CAVES_TUTO_MAP_ROOM_DONE, "b", true)
  end

  Scenario.SetTeleportalUsed(_ARG_0_)
end


function s010_cave.OnTutoMapOptionsBegins(_ARG_0_)
  local oActor1 = Game.GetActor("MapOptionsTutoTriggerEnter")
  local oActor2 = Game.GetActor("MapOptionsTutoTriggerExit")
  
  
  
  if oActor1 ~= nil and oActor2 ~= nil then
    if not CAVES_TUTO_MAP_DONE and _ARG_0_ then
      oActor1.bEnabled = true
      oActor2.bEnabled = true
    else
      oActor1.bEnabled = false
      oActor2.bEnabled = false
    end
  end
end

function s010_cave.OnTutoMapOptionsEnds()
  Scenario.WriteToBlackboard(Scenario.LUAPropIDs.CAVES_TUTO_MAP_DONE, "b", true)
  CAVES_TUTO_MAP_DONE = true
  print(CAVES_TUTO_MAP_DONE)
end


function s010_cave.OnTutoMapRoomBegins(_ARG_0_)
  local oActor1 = Game.GetActor("MapRoomTutoTriggerEnter")
  local oActor2 = Game.GetActor("MapRoomTutoTriggerExit")
  
  
  
  if oActor1 ~= nil and oActor2 ~= nil then
    if not CAVES_TUTO_MAP_ROOM_DONE and _ARG_0_ then
      oActor1.bEnabled = true
      oActor2.bEnabled = true
    else
      oActor1.bEnabled = false
      oActor2.bEnabled = false
    end
  end
end

function s010_cave.OnTutoMapRoomEnds()
  Scenario.WriteToBlackboard(Scenario.LUAPropIDs.CAVES_TUTO_MAP_ROOM_DONE, "b", true)
  CAVES_TUTO_MAP_ROOM_DONE = true
  print(CAVES_TUTO_MAP_ROOM_DONE)
end





function s010_cave.EnableChozoWarriorX(_ARG_0_, _ARG_1_)
  Game.PushSetup("ChozoWarriorX", true, true)
end

function s010_cave.PostChozoWarriorX(_ARG_0_, _ARG_1_)
  Game.PopSetup("ChozoWarriorX", true, true)
end





function s010_cave.cutsceneplayer_intro_space_full()

  local L0_2 = Game.GetActor("cutsceneplayer_intro_space")
  if L0_2 ~= nil then
    local L1_2 = Game.GetActor("cutsceneplayer_intro_flashbackinit")
    if L1_2 ~= nil then
      L0_2.CUTSCENE:QueueCutscenePlayer(L1_2)
      local L2_2 = Game.GetActor("cutsceneplayer_intro_landing")
      if L2_2 ~= nil then
        L1_2.CUTSCENE:QueueCutscenePlayer(L2_2)
        local L3_2 = Game.GetActor("cutsceneplayer_intro_arrivalatrium")
        if L3_2 ~= nil then
          L2_2.CUTSCENE:QueueCutscenePlayer(L3_2)
          local L4_2 = Game.GetActor("cutsceneplayer_intro_fight")
          if L4_2 ~= nil then
            L3_2.CUTSCENE:QueueCutscenePlayer(L4_2)
            local L5_2 = Game.GetActor("cutsceneplayer_intro_flashbackend")
            if L5_2 ~= nil then
              L4_2.CUTSCENE:QueueCutscenePlayer(L5_2)
            end
          end
        end
      end
    end
  end
end

function s010_cave.cutsceneplayer_3()
  Game.AddSF(0.1, "s010_cave.cutsceneplayer_3_delayed", "")
end

function s010_cave.cutsceneplayer_3_delayed()
  local oActor = Game.GetActor("PRP_CV_AccessPoint001")
  if oActor ~= nil then
    oActor.bEnabled = false
  end
end

function s010_cave.cutsceneplayer_48()
  Game.AddSF(0.1, "s010_cave.cutsceneplayer_48_delayed", "")
end

function s010_cave.cutsceneplayer_48_delayed()
  local oActor = Game.GetActor("PRP_CV_AccessPoint001")
  if oActor ~= nil then
    oActor.bEnabled = false
  end
end


function s010_cave.cutsceneplayer_54_delayed()
  local oActor = Game.GetActor("SP_Scorpius_scorpius")
  if oActor ~= nil then
    oActor.bEnabled = false
  end
end

function s010_cave.cutsceneplayer_55()
  Game.AddSF(0.1, "s010_cave.cutsceneplayer_55_delayed", "")
end


function s010_cave.cutsceneplayer_55_delayed()
  local oActor = Game.GetActor("SP_Scorpius_scorpius")
  if oActor ~= nil then
    oActor.bEnabled = false
  end
end

function s010_cave.cutsceneplayer_155()
  Game.AddSF(0.1, "s010_cave.cutsceneplayer_155_delayed", "")
end


function s010_cave.cutsceneplayer_155_delayed()
  local oActor = Game.GetActor("SP_Scorpius_scorpius")
  if oActor ~= nil then
    oActor.bEnabled = false
  end
end

function s010_cave.cutsceneplayer_57()
  Game.AddSF(0.1, "s010_cave.cutsceneplayer_57_delayed", "")
end


function s010_cave.cutsceneplayer_57_delayed()
  local oActor = Game.GetActor("SP_Scorpius_scorpius")
  if oActor ~= nil then
    oActor.bEnabled = false
  end
end
