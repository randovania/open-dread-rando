Game.ImportLibrary("gui/scripts/msemenu.lua")
Game.ImportLibrary("gui/scripts/scenariomenu_common.lua", false)
Game.ImportLibrary("gui/scripts/msemenu_presaved.lua")
Game.ImportLibrary("gui/scripts/msemenu_ingame.lua")
Game.ImportLibrary("gui/scripts/msemenu_checkpoint.lua")
Game.ImportLibrary("gui/scripts/msemenu_scenarios.lua", false)
Game.ImportLibrary("gui/scripts/msemenu_debug_locations.lua", false)
msemenu_mainmenu = {}



function msemenu_mainmenu.Create(_ARG_0_)
  Game.AddSF(0.5, RL.UpdateRDVClient, "")
  msemenu.items = msemenu_mainmenu.items
  if not Game.IsInFINAL() then
    msemenu.items.Debug = msemenu_mainmenu.debug_items
  end
  
  local L1_2 = msemenu.items.Config
  if L1_2 ~= nil and not Game.IsInWIN32() then
    local L2_2 = L1_2.Sound
    if L2_2 ~= nil then
      L2_2.SpeakerMode = msemenu.DebugSetSpeakerMode()
      L2_2.HeadphoneMultiplier = msemenu.DebugSetHeadPhoneMultiplier()
      L2_2.StreamMix = msemenu.GenerateSetMixValues()
      L2_2.FrontByPass = msemenu.GenerateSwitchFrontByPass()
    end
  end
  
  msemenu.OnClosed = 
  function() 
    GUI.ResetMainMenuReleaseGUI()
  end
  
  
  
  
  
  local L2_2 = nil
  local oFileInfo = Game.GetFileInfo("gui/scripts/msemenu_mainmenu_export.lua")
  if oFileInfo.Exists then
    Game.DoFile("gui/scripts/msemenu_mainmenu_export.lua")
  else
    L2_2 = msemenu.Create("Up", "items", true, true, true, 11, "CDebugMenuEntryItemRenderer")
  end
  
  return L2_2
end

function msemenu_mainmenu.EnableAmiiboMenu()

  Game.AddPSF(0.2, "Game.WriteToGameBlackboardSection", "ssb", "GAME", "AMIIBO_MENU_UNLOCKED", true)
end

function msemenu_mainmenu.LoadDebugScenario(_ARG_0_)
  Init.InitGameBlackboard()

  if _ARG_0_ ~= "surface" then
    msemenu_mainmenu.EnableAmiiboMenu()
  end

  ScenarioMenu.LoadScenario(_ARG_0_)
end

function msemenu_mainmenu.LoadPresavedDebugScenario(_ARG_0_)

  Game.LoadGameFromAssets(_ARG_0_)

  if _ARG_0_ ~= "surface" then
    msemenu_mainmenu.EnableAmiiboMenu()
  end
end







msemenu_mainmenu.tBossesTestScenarios = {}
msemenu_mainmenu.aArenasLevels = {
  "surface",
  "area1",
  "area2",
  "area2b",
  "area3",
  "area3b",
  "area3c",
  "area4",
  "area6",
  "area6b",
  "area6c",
  "area7",
  "area9",
  "area10"
}










function msemenu_mainmenu.GenerateLoadArenaItems(_ARG_0_)
  local L1_2 = {}
  for L5_2, L6_2 in ipairs(_ARG_0_) do
    local L7_2 = L6_2[1]
    local L8_2 = L6_2[2]
    local L9_2 =  { ItemKey = L7_2, ItemContent = {} }
    table.insert(L1_2, L9_2)
    local L10_2 = nil
    local L11_2 = msemenu_mainmenu.tBossesTestScenarios[L7_2]
    
    
    
    
    
    
    if L11_2 ~= nil then
      L10_2 = { OnDirActivated = 
      function(A0_3, A1_3)
        if A1_3 == "ActivationButton" then
          msemenu_mainmenu.LoadDebugScenario(L11_2)
        end
      end }
    end
    
    if #L8_2 > 0 then
      if L10_2 ~= nil then
        table.insert(L9_2.ItemContent, { ItemKey = "_Test", ItemContent = L10_2 })
      end

      for L15_2, L16_2 in pairs(L8_2) do
                
        local L17_2 = L16_2[1]
        local L18_2 = L16_2[2]
        local L19_2 = 0
        local L20_2 = {}
        local L21_2 = {}
        
        
        for L25_2, L26_2 in pairs(L18_2) do
          for L30_2, L31_2 in ipairs(L26_2) do
            local L32_2 = L31_2
            
            if string.sub(L32_2, 1, string.len(L7_2)) == string.lower(L7_2) then
              L32_2 = "#" .. string.sub(L32_2, string.len(L7_2) + 1)
            end
            
            L21_2 = { OnDirActivated = 
            function(A0_3, A1_3)
             if A1_3 == "ActivationButton" then
                Game.LoadGameFromAssets(L17_2 .. "/" .. L25_2 .. "/" .. L31_2)
              end
            end }
            
            L20_2[L7_2 ..  "_" .. L17_2 .. "_" .. L32_2] = L21_2
            L19_2 = L19_2 + 1
          end
        end
        
        if L19_2 > 0 or L10_2 ~= nil then
          table.insert(L9_2.ItemContent, { ItemKey = L7_2 .. "_" .. L17_2, ItemContent = L20_2 })
        else
          L9_2.ItemContent = L21_2
        end
        
      end
    elseif L10_2 ~= nil then
        
      L9_2.ItemContent = L10_2
    end
  end
  
  return L1_2
end

msemenu_mainmenu.aPopUps = {
  "#GUI_AMIIBO_NFC_READER_UPDATE",
  "#GUI_AMIIBO_IR_ERROR",
  "#GUI_AMIIBO_NFC_READER_ERROR",
  "#GUI_SAVE_DATA_CORRUPT"
}




function msemenu_mainmenu.GenerateEmmyTunnelConfig(_ARG_0_)
  
  return { OnDirActivated = 
  function(A0_3, A1_3)
  
    local L2_3 = not Blackboard.GetProp("EMMY",  _ARG_0_ .. "TunnelsEnabled")
    Blackboard.SetProp("EMMY", _ARG_0_ .. "TunnelsEnabled", "b", L2_3)
  end, GetCurrentValue = 
  function()
    local bTunnelsEnabled = Blackboard.GetProp("EMMY", _ARG_0_ .. "TunnelsEnabled")
    if bTunnelsEnabled then
      return "ENABLED"
    else
      return "DISABLED"
    end
  end
  }
end
msemenu_mainmenu.items = {}



local PlayAreas =
function()
  Game.DoFile("gui/scripts/scenariodata/areastoplay.lua")
  local L0_2 = "Play Areas"
  table.insert(msemenu_mainmenu.items, { ItemKey = L0_2, ItemContent = {} })
  msemenu_mainmenu.tAreasTable = msemenu.FindItemContent(msemenu_mainmenu.items, L0_2)
  for L4_2, L5_2 in ipairs(ScenarioData.tAreasToPlay) do
  
    if L5_2.bIsInFinal == true or not Game.IsInFINAL() then
  
      table.insert(msemenu_mainmenu.tAreasTable, { ItemKey= L5_2.sName, ItemContent = 
      function()
        if L5_2:Load() == false then
          ScenarioMenu.LoadScenario(L5_2.sMap, true)
        end
      end})
    end
  end
  
end
local RegularGyms = 
function()
  Game.DoFile("gui/scripts/scenariodata/regulargyms.lua")
  local L0_2 = "Regular Gyms"
  table.insert(msemenu_mainmenu.items, {
    ItemKey = L0_2,
    ItemContent = {}
  })
  msemenu_mainmenu.tRegularGymsTable = msemenu.FindItemContent(msemenu_mainmenu.items, L0_2)
  for _FORV_4_, _FORV_5_ in ipairs(ScenarioData.tRegularGyms) do
    if _FORV_5_.bIsInFinal == true or not Game.IsInFINAL() then
    
      table.insert(msemenu_mainmenu.tRegularGymsTable, { ItemKey = _FORV_5_.sName, ItemContent = function() _FORV_5_:Load() end })
    end
  end
end
local MidBossGyms = 
function()
  Game.DoFile("gui/scripts/scenariodata/midbossesgyms.lua")
  local L0_2 = "Mid Bosses Gyms"
  table.insert(msemenu_mainmenu.items, {
    ItemKey = L0_2,
    ItemContent = {}
  })
  msemenu_mainmenu.tMidBossesGymsTable = msemenu.FindItemContent(msemenu_mainmenu.items, L0_2)
  for _FORV_4_, _FORV_5_ in ipairs(ScenarioData.tMidBossesGyms) do
    if _FORV_5_.bIsInFinal == true or not Game.IsInFINAL() then
    
      table.insert(msemenu_mainmenu.tMidBossesGymsTable, { ItemKey = _FORV_5_.sName, ItemContent = function() _FORV_5_:Load() end })
    end
  end
  local L1_2 = "Hydrogiga Gyms"
  table.insert(msemenu_mainmenu.tMidBossesGymsTable, {
    ItemKey = L1_2,
    ItemContent = {}
  })
  msemenu_mainmenu.tMidBossesGymsTable_Hydrogiga = msemenu.FindItemContent(msemenu_mainmenu.tMidBossesGymsTable, L1_2)
  for _FORV_5_, _FORV_6_ in ipairs(ScenarioData.tMidBossesGyms_Hydrogiga) do
    if _FORV_6_.bIsInFinal == true or not Game.IsInFINAL() then
    
      table.insert(msemenu_mainmenu.tMidBossesGymsTable_Hydrogiga, { ItemKey = _FORV_6_.sName, ItemContent = function() _FORV_6_:Load() end })
    end
  end
  local L2_2 = "Chozo Robot Soldier Gyms" 
  table.insert(msemenu_mainmenu.tMidBossesGymsTable, {
    ItemKey = L2_2,
    ItemContent = {}
  })
  msemenu_mainmenu.tMidBossesGymsTable_CRS = msemenu.FindItemContent(msemenu_mainmenu.tMidBossesGymsTable, L2_2)
  for _FORV_6_, _FORV_7_ in ipairs(ScenarioData.tMidBossesGyms_CRS) do
    if _FORV_7_.bIsInFinal == true or not Game.IsInFINAL() then
      
      table.insert(msemenu_mainmenu.tMidBossesGymsTable_CRS, { ItemKey = _FORV_7_.sName, ItemContent = function() _FORV_7_:Load() end })
    end
  end
  local L3_2 = "Chozo Warrior X Gyms" 
  table.insert(msemenu_mainmenu.tMidBossesGymsTable, {
    ItemKey = L3_2,
    ItemContent = {}
  })
  msemenu_mainmenu.tMidBossesGymsTable_CWX = msemenu.FindItemContent(msemenu_mainmenu.tMidBossesGymsTable, L3_2)
  for _FORV_7_, _FORV_8_ in ipairs(ScenarioData.tMidBossesGyms_CWX) do
    if _FORV_8_.bIsInFinal == true or not Game.IsInFINAL() then
      
      table.insert(msemenu_mainmenu.tMidBossesGymsTable_CWX, { ItemKey = _FORV_8_.sName, ItemContent = function() _FORV_8_:Load() end })
    end
  end
  local L4_2 = "Super Quetzoa Gyms"
  table.insert(msemenu_mainmenu.tMidBossesGymsTable, {
    ItemKey = L4_2,
    ItemContent = {}
  })
  msemenu_mainmenu.tMidBossesGymsTable_SuperQuetzoa = msemenu.FindItemContent(msemenu_mainmenu.tMidBossesGymsTable, L4_2)
  for _FORV_8_, _FORV_9_ in ipairs(ScenarioData.tMidBossesGyms_SuperQuetzoa) do
    if _FORV_9_.bIsInFinal == true or not Game.IsInFINAL() then
      
      table.insert(msemenu_mainmenu.tMidBossesGymsTable_SuperQuetzoa, { ItemKey = _FORV_9_.sName, ItemContent = function() _FORV_9_:Load() end })
    end
  end
  local L5_2 = "Super Goliath Gyms"
  table.insert(msemenu_mainmenu.tMidBossesGymsTable, {
    ItemKey = L5_2,
    ItemContent = {}
  })
  msemenu_mainmenu.tMidBossesGymsTable_SuperGoliath = msemenu.FindItemContent(msemenu_mainmenu.tMidBossesGymsTable, L5_2)
  for _FORV_9_, _FORV_10_ in ipairs(ScenarioData.tMidBossesGyms_SuperGoliath) do
    if _FORV_10_.bIsInFinal == true or not Game.IsInFINAL() then
      
      table.insert(msemenu_mainmenu.tMidBossesGymsTable_SuperGoliath, { ItemKey = _FORV_10_.sName, ItemContent = function() _FORV_10_:Load() end })
    end
  end
  local L6_2 = "Cooldown X Gyms"
  table.insert(msemenu_mainmenu.tMidBossesGymsTable, {
    ItemKey = L6_2,
    ItemContent = {}
  })
  msemenu_mainmenu.tMidBossesGymsTable_CooldownX = msemenu.FindItemContent(msemenu_mainmenu.tMidBossesGymsTable, L6_2)
  for _FORV_10_, _FORV_11_ in ipairs(ScenarioData.tMidBossesGyms_CooldownX) do
    if _FORV_11_.bIsInFinal == true or not Game.IsInFINAL() then
      
      table.insert(msemenu_mainmenu.tMidBossesGymsTable_CooldownX, { ItemKey = _FORV_11_.sName, ItemContent = function() _FORV_11_:Load() end })
    end
  end
  Game.DoFile("gui/scripts/scenariodata/centralunitsgyms.lua")
  local L7_2 = "Central Unit"
  table.insert(msemenu_mainmenu.tMidBossesGymsTable, {
    ItemKey = L7_2,
    ItemContent = {}
  })
  msemenu_mainmenu.tCentralUnitGymsTable = msemenu.FindItemContent(msemenu_mainmenu.tMidBossesGymsTable, L7_2)
  for _FORV_11_, _FORV_12_ in ipairs(ScenarioData.tCentralUnitsGyms) do
    if _FORV_12_.bIsInFinal == true or not Game.IsInFINAL() then
      
      
      table.insert(msemenu_mainmenu.tCentralUnitGymsTable, { ItemKey = _FORV_12_.sName, ItemContent = function() _FORV_12_:Load() end })
    end
  end
  
end
local BossGyms = 
function()
  Game.DoFile("gui/scripts/scenariodata/bossesgyms.lua")
  local L0_2 = "Bosses Gyms"
  table.insert(msemenu_mainmenu.items, {
    ItemKey = L0_2,
    ItemContent = {}
  })
  msemenu_mainmenu.tBossesGymsTable = msemenu.FindItemContent(msemenu_mainmenu.items, L0_2)
  for _FORV_4_, _FORV_5_ in ipairs(ScenarioData.tBossesGyms) do
    if _FORV_5_.bIsInFinal == true or not Game.IsInFINAL() then
    
      table.insert(msemenu_mainmenu.tBossesGymsTable, { ItemKey = _FORV_5_.sName, ItemContent = function() _FORV_5_:Load() end })
    end
  end
  local L1_2 = "Kraid Gyms"
  table.insert(msemenu_mainmenu.tBossesGymsTable, {
    ItemKey = L1_2,
    ItemContent = {}
  })
  msemenu_mainmenu.tBossesGymsTable_Kraid = msemenu.FindItemContent(msemenu_mainmenu.tBossesGymsTable, L1_2)
  for _FORV_5_, _FORV_6_ in ipairs(ScenarioData.tBossesGyms_Kraid) do
    if _FORV_6_.bIsInFinal == true or not Game.IsInFINAL() then 
      
      table.insert(msemenu_mainmenu.tBossesGymsTable_Kraid, { ItemKey = _FORV_6_.sName, ItemContent = function() _FORV_6_:Load() end })
    end
  end
  
end
local AbilityGyms = 
function()
  Game.DoFile("gui/scripts/scenariodata/abilitiesgyms.lua")
  local L0_2 = "Abilities Gyms"
  table.insert(msemenu_mainmenu.items, {
    ItemKey = L0_2,
    ItemContent = {}
  })
  msemenu_mainmenu.tAbilitiesGymTable = msemenu.FindItemContent(msemenu_mainmenu.items, L0_2)
  for _FORV_4_, _FORV_5_ in ipairs(ScenarioData.tAbilitiesGyms) do
    if _FORV_5_.bIsInFinal == true or not Game.IsInFINAL() then
    
      table.insert(msemenu_mainmenu.tAbilitiesGymTable, { ItemKey = _FORV_5_.sName, ItemContent = function() _FORV_5_:Load() end })
    end
  end
end
local DevelopGyms = 
function()
  if not Game.IsInFINAL() then
    Game.DoFile("gui/scripts/scenariodata/developgyms.lua")
    local L0_2 = "Develop Gyms"
    table.insert(msemenu_mainmenu.items, {
      ItemKey = L0_2,
      ItemContent = {}
    })
    msemenu_mainmenu.tDevelopGymTable = msemenu.FindItemContent(msemenu_mainmenu.items, L0_2)
    for _FORV_4_, _FORV_5_ in ipairs(ScenarioData.tDevelopGyms) do
    
      table.insert(msemenu_mainmenu.tDevelopGymTable, { ItemKey = _FORV_5_.sName, ItemContent = function() _FORV_5_:Load() end })
    end
  end
end
local Cutscenes = 
function()
    
    
    
    
    
    
    
    local DEFAULT = { 
        PENDING = "P - ", 
        BLOCKING = "B - ", 
        WIP = "W - ", 
        FINAL = "F - " 
    }
    
    local CUTSCENES = {
      { "Cave", "s010_cave", {
          { DEFAULT.WIP, "0001gameintro_full", "cave_start", "cutsceneplayer_intro_space", true, true, false, false, false, "CurrentScenario.cutsceneplayer_intro_space_full", "", 0, 0, 0 },
          { DEFAULT.WIP, "0001gameintro_space", "cave_start", "cutsceneplayer_intro_space", true, true, false, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0001gameintro_flashbackinit", "cave_start", "cutsceneplayer_intro_flashbackinit", true, true, true, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0001gameintrolanding", "cave_start", "cutsceneplayer_intro_landing", true, true, false, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0001gameintro_arrivalatrium", "cave_start", "cutsceneplayer_intro_arrivalatrium", true, true, true, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0001gameintro_fight", "cave_start", "cutsceneplayer_intro_fight", true, true, true, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0001gameintro_flashbackend", "cave_start", "cutsceneplayer_intro_flashbackend", true, true, true, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0003firstcomunicationfakeadam", "cut_first_communication", "cutsceneplayer_3", false, true, true, true, true, "CurrentScenario.cutsceneplayer_3", "", 0, 0, 0 },
          { DEFAULT.WIP, "0005meleetutorial", "cave_start", "cutsceneplayer_5", true, true, true, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0034protoemmyappears", "cut_protoemmy_intro", "cutsceneplayer_34", false, true, true, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0035protoemmycantclimb", "cut_protoemmy_climb", "cutsceneplayer_35", true, true, true, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0048firstcupowerobtention", "cut_protoemmy_climb", "cutsceneplayer_48", false, true, true, true, true, "CurrentScenario.cutsceneplayer_48", "", 350, 0, 0 },
          { DEFAULT.WIP, "0036enteremmyzone", "cut_emmyzone_intro", "cutsceneplayer_36", true, true, true, false, false, "", "",0, 0, 0 },
          { DEFAULT.WIP, "0037emmycaveappears", "cut_emmycave_intro", "cutsceneplayer_37", false, true, true, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0049centralunitdetectsamus01", "cut_before_cu", "cutsceneplayer_49-1", true, true, true, false, false, "", "", 0, 1300, 0 },
          { DEFAULT.WIP, "0049centralunitdetectsamus02", "cut_before_cu", "cutsceneplayer_49-2", true, true, true, false, false, "", "", 0, 1300, 0 },
          { DEFAULT.WIP, "0050firstcupresentation", "cut_cu", "cutsceneplayer_50", true, true, true, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0051cudeathandpowerobtention", "cut_cu", "cutsceneplayer_51", true, true, true, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0054scorpiuspresentation", "scorpius", "cutsceneplayer_54", true, true, true, false, false, "CurrentScenario.cutsceneplayer_54", "", 0, 0, 0 },
          { DEFAULT.WIP, "0055scorpiusphase2", "scorpius", "cutsceneplayer_55", true, true, true, false, false, "CurrentScenario.cutsceneplayer_55", "", 0, 0, 0 },
          { DEFAULT.WIP, "0155scorpiusphase3", "scorpius", "cutsceneplayer_155", true, true, true, false, false, "CurrentScenario.cutsceneplayer_155", "", 0, 0, 0 },
          { DEFAULT.WIP, "0057scorpiusdeath", "scorpius", "cutsceneplayer_57", true, true, true, false, false, "CurrentScenario.cutsceneplayer_57", "", 0, 150, 0 },
          { DEFAULT.WIP, "0030variasuiteobtention", "variasuit", "cutsceneplayer_30", true, true, true, true, true, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0007beginningofcooldown", "chozowarriorcave", "elevator_with_cutscene_aqua_000", true, true, true, true, true, "", "", 0, 0, 0 }
        }
      }, 
      { "Magma", "s020_magma", 
          {
          { DEFAULT.WIP, "0038magmaemmypresentation", "emmymagma", "cutsceneplayer_38", true, true, true, false, false, "", "", 500, 100, 0 },
          { DEFAULT.WIP, "0059kraidpresentation", "kraid", "cutsceneplayer_59", false, true, false, false, false, "", "", -400, 2200, 0 },
          { DEFAULT.WIP, "0060kraidphase02", "kraid", "cutsceneplayer_60", true, true, false, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0061kraiddeath", "kraid", "cutsceneplayer_61", true, true, false, false, false, "CurrentScenario.cutsceneplayer_61", "", 0, 0, 0 },
          { DEFAULT.WIP, "0061kraiddeath_zipline_mb", "kraid", "cutsceneplayer_61_zipline_mb", true, true, false, "CurrentScenario.cutsceneplayer_61_zipline_mb", "", 0, 0, 0 },
          { DEFAULT.WIP, "0053genericcupowerobtention_r", "magma_cu", "cutsceneplayer_53", true, true, true, true, true, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0078cooldownpresentation", "cooldownx", "cutsceneplayer_78", true, true, true, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0081cooldowndeath", "cooldownx", "cutsceneplayer_81", true, true, true, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0081cooldowndeath_grab", "cooldownx", "cutsceneplayer_80_grab", true, true, true, false, false, "CurrentScenario.cutsceneplayer_80_grab", "", 0, 0, 0 }
        }
      }, 
      { "BaseLab", "s030_baselab", {
          { DEFAULT.WIP, "0053genericcupowerobtention", "base_cu", "cutsceneplayer_53", true, true, true, true, true, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0039labemmypresentation", "emmybase", "cutsceneplayer_39", true, true, true, false, false, "", "", 0, 0, 0 }
        }
      }, 
      { "Aqua", "s040_aqua", {
          { DEFAULT.WIP, "0031gravitysuiteobtention", "gravitysuit", "cutsceneplayer_31", true, true, true, true, true, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0032ghostdashobtention", "ghostdash", "cutsceneplayer_32", true, true, true, true, true, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0063_hydrogiga-presentation", "hydrogiga", "cutsceneplayer_63", true, true, false, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0065hydrogigadeath", "hydrogiga", "cutsceneplayer_65", true, true, false, false, false, "", "", 500, 100, 0 }
        }
      }, 
      { "Forest", "s050_forest", {
          { DEFAULT.WIP, "0033sonarobtention", "sonar", "cutsceneplayer_33", true, true, true, true, true, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0053genericcupowerobtention_r", "forest_cu", "cutsceneplayer_53", true, true, true, true, true, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0042professorxpresentation", "afterquarantine", "cutsceneplayer_42", true, true, false, false, false, "", "", 0, 0, 0 }
        }
      },
      { "Quarantine", "s060_quarantine", {
          { DEFAULT.WIP, "0067chozowarriorxpresentation", "chozowarriorx", "cutsceneplayer_67", true, true, true, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0113quarantinearrival", "quarantine_maingate", "cutsceneplayer_113", true, true, true, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0004quarantinedoorsopen", "quarantine_opened", "cutsceneplayer_4", true, true, true, true, true, "", "", -500, 0, 0 },
          { DEFAULT.WIP, "0013firstencounterchozozombie", "quarantine_xenemy", "cutsceneplayer_13", true, true, true, false, false, "", "", 100, 0, 0 }
        }
      },
      { "Sanctuary", "s070_basesanc", {
          { DEFAULT.WIP, "0040sancemmypresentation_full", "encounterprofessor", "cutsceneplayer_40", true, true, true, false, false, "CurrentScenario.cutsceneplayer_40_full", "", 0, 0, 0 },
          { DEFAULT.WIP, "0040sancemmypresentation_part1", "encounterprofessor", "cutsceneplayer_40", true, true, true, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0040sancemmypresentation_part2a", "encounterprofessor", "cutsceneplayer_40b_part1", true, true, true, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0040sancemmypresentation_part2b", "encounterprofessor", "cutsceneplayer_40b_part2", true, true, true, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0040sancemmypresentation_part3", "encounterprofessor", "cutsceneplayer_40c", true, true, true, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0053genericcupowerobtention", "sanc_cu", "cutsceneplayer_53", true, true, true, true, true, "", "", 0, 0, 0 }
        }
      },
      { "Shipyard", "s080_shipyard", {
          { DEFAULT.WIP, "0043emmymetroidnization", "powerbomb", "cutsceneplayer_43", true, true, true, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0012metroidnizationstrongreactionevent", "strongreaction", "cutsceneplayer_12", false, true, true, false, false, "", "", 300, 0, 0 },
          { DEFAULT.WIP, "0071chozowarriorxelitepresentation", "elitechozowarriorx", "cutsceneplayer_71", false, true, false, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0110commanderxdeath", "commanderx", "cutsceneplayer_110", true, true, true, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0108shipyard", "commanderx", "cutsceneplayer_108", true, true, true, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0112endgame", "endgame", "cutsceneplayer_112", true, true, false, false, false, "", "", 0, 500, 0 }
        }
      }, { "Skybase", "s090_skybase", {
          { DEFAULT.WIP, "0086commanderorbital", "commander", "cutsceneplayer_86", true, true, true, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "100commandershowswings", "commander", "cutsceneplayer_100", true, true, true, false, false, "", "", 0, 0, 0 },
          { DEFAULT.WIP, "0101commanderlosehiswings_left", "commander", "cutsceneplayer_101", true, true, true, false, false, "CurrentScenario.cutsceneplayer_101_left", "", 0, 0, 0 },
          { DEFAULT.WIP, "0101commanderlosehiswings_right", "commander", "cutsceneplayer_101", true, true, true, false, false, "CurrentScenario.cutsceneplayer_101_right", "", 0, 0, 0 },
          { DEFAULT.WIP, "0108fallofskybase", "commander", "cutsceneplayer_108", true, true, true, false, false, "", "CurrentScenario.cutsceneplayer_108_end", 0, 0, 0 }
        }
      }
    }
  
  local L2_2 = "Cutscenes"
  table.insert(msemenu_mainmenu.items, { ItemKey = L2_2, ItemContent = {} })
  msemenu_mainmenu.tCutScenes = msemenu.FindItemContent(msemenu_mainmenu.items, L2_2)
  
  for L6_2, L7_2 in ipairs(CUTSCENES) do
    table.insert(msemenu_mainmenu.tCutScenes, { ItemKey = L7_2[1], ItemContent = {} })
    local L8_2 = msemenu.FindItemContent(msemenu_mainmenu.tCutScenes, L7_2[1])
    for L12_2, L13_2 in ipairs(L7_2[3]) do
      local Key = L13_2[1] .. L13_2[2]
      
      
      
      table.insert(L8_2, { ItemKey = Key, ItemContent = 
      function()
        Game.LaunchCutsceneFromPlaythrough(L13_2[3], L13_2[4], L13_2[5], L13_2[6], L13_2[7], L13_2[8], L13_2[9], L13_2[10], L13_2[11], L13_2[12], L13_2[13], L13_2[14])
      end 
      })
    end
  end
end
local Credits =
function()
  local L0_2 = 0
  local L1_2 = 1
  local L2_2 = 0
  local L3_2 = 1
  local L4_2 = 2
  table.insert(msemenu_mainmenu.items, { ItemKey = "Credits", ItemContent = {} })
  local L5_2 = msemenu.FindItemContent(msemenu_mainmenu.items, "Credits")
  table.insert(L5_2, { ItemKey = "Load Credits From Menu",  ItemContent = function() Game.ShowEndGameCredits(false) end })
  table.insert(L5_2, { ItemKey = "Load Game Ending", ItemContent = {} })
  local L6_2 = msemenu.FindItemContent(L5_2, "Load Game Ending")
  table.insert(L6_2, { ItemKey = "Normal OK", ItemContent = function() Game.LoadGameEnding(L0_2, L2_2) end })
  table.insert(L6_2, { ItemKey = "Normal GREAT", ItemContent =  function() Game.LoadGameEnding(L0_2, L3_2) end })
  table.insert(L6_2, { ItemKey = "Normal EXCELLENT", ItemContent =  function() Game.LoadGameEnding(L0_2, L4_2) end })
  table.insert(L6_2, { ItemKey = "Hard OK", ItemContent =  function() Game.LoadGameEnding(L1_2, L2_2) end })
  table.insert(L6_2, { ItemKey = "Hard GREAT", ItemContent =  function() Game.LoadGameEnding(L1_2, L3_2) end })
  table.insert(L6_2, { ItemKey = "Hard EXCELLENT", ItemContent =  function() Game.LoadGameEnding(L1_2, L4_2) end })
end

if not Game.IsInFINAL() then
  PlayAreas()
  RegularGyms()
  MidBossGyms()
  BossGyms()
  AbilityGyms()
  DevelopGyms()
  Cutscenes()
end

table.insert(msemenu_mainmenu.items, {
  ItemKey = "Load Checkpoint",
  ItemContent = msemenu_presaved.GenerateLoadMenuForPlaythrought("pt_official")
})
table.insert(msemenu_mainmenu.items, {
  ItemKey = "Load Savedata",
  ItemContent = msemenu.GenerateDefaultTableItems(function(_ARG_0_)
    Game.LoadProfile(_ARG_0_.ID, true)
  end, msemenu_checkpoint.profiles, "Desc")
})
if not Game.IsInFINAL() then
  Credits()
end







msemenu_mainmenu.debug_items = {
  {
    ItemKey = "Load Savedata",
    ItemContent = msemenu.GenerateDefaultTableItems(
    function(_ARG_0_)
      Game.LoadGame("savedata")
    end, msemenu_checkpoint.profiles, "Desc")
  },
  ["Load Scenario"] = msemenu.GenerateDefaultItemsWithAlias(ScenarioMenu.LoadScenario, tScenarioMenuDefs.aScenarios, tScenarioMenuDefs.aScenariosWithAlias)
}
table.insert(msemenu_mainmenu.items, {
  ItemKey = "Loading Tooltip",
  ItemContent = msemenu_ingame.GenerateForceLoadingScreenTooltip()
})
table.insert(msemenu_mainmenu.items, {
  ItemKey = "Show Subtitles",
  ItemContent = msemenu_ingame.SwitchShowSubtitles()
})
