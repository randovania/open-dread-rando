Game.DoFile("system/scripts/cc_to_room_name.lc")

RoomNameGui = RoomNameGui or {
    ui = nil,
    container = nil,
    cameraDict = RANDO_CC_DICTIONARY,
    fadeTime = Init.bRoomIdFadeTime,
    fadeOutSFID = nil,
}

function RoomNameGui.GetRoomName(camera)
    local dict = RoomNameGui.cameraDict
    local scenario = Game.GetScenarioID()
    if dict == nil then
        Game.LogWarn(0, "No camera dict present!")
        return
    end

    local scenario_dict = dict[scenario]
    if scenario_dict == nil then
        Game.LogWarn(0, scenario .. " has nil dict!")
        return nil
    end

    local rando_name = scenario_dict[camera]
    return rando_name
end

function RoomNameGui.Init()
    if RoomNameGui.ui then
        RoomNameGui.ui:Destroy()
        RoomNameGui.ui = nil
        RoomNameGui.container = nil
    end

    local hud = GUI.GetDisplayObject("IngameMenuRoot.iconshudcomposition")
    local ui = GUILib("RoomName", hud)
    local container = ui:AddContainer("Content", {
        X = 0.025,
        Y = 0.925,
        SizeX = 0.2,
        SizeY = 0.04,
    })

    container:AddSprite("Background", "HUD_TILESET/BACKGROUND", {
        SizeX = 0.3,
        SizeY = 0.06,
    })
    container:AddSprite("Frame_top", "HUD_TILESET/FRAME_TOP", {
        X = -0.0005,
        Y = -0.0005,
        SizeX = 0.05,
        SizeY = 0.015,
        ColorR = 0.8773584961891174,
        ColorG = 0.8773584961891174,
        ColorB = 0.8773584961891174,
    })

    local label = container:AddLabel("RoomNameGui_Text", "Room: Unknown", {
        X = "0.0075",
        Y = "0.01",
        SizeX = "0.3",
        SizeY = "0.04",
        Font = "digital_small",
        Autosize = false,
    })

    RoomNameGui.ui = ui
    RoomNameGui.container = container
    RoomNameGui.label = label

    local current_cc = Game.GetCurrentSubAreaId()

    RoomNameGui.Update(current_cc)
end

-- updates the room name gui label
-- optional time_to_fade arg will set visibility to false after the time in seconds. -1 means it does not fade.
function RoomNameGui.Update(new_cc)
    local label = RoomNameGui.label

    if not label then
        Game.LogWarn(0, "No Label for RoomNameGui")
        return
    end

    if type(new_cc) ~= "string" then
        GUI.LogWarn(0, "collision camera is not string")
        return
    end

    local room_name = RoomNameGui.GetRoomName(new_cc)
    if room_name == nil then
        Game.LogWarn(0, string.format("Couldn't find name for %s/%s", Game.GetScenarioID(), new_cc))
        RoomNameGui.Fade("0.0", "0.01")
        return
    else
        RoomNameGui.Fade("1.0")
        label:SetText(room_name)
    end

    if RoomNameGui.fadeTime ~= nil and RoomNameGui.fadeTime ~= -1 then
        if RoomNameGui.fadeOutSFID ~= nil then
            Game.DelSFByID(RoomNameGui.fadeOutSFID)
        end
        RoomNameGui.fadeOutSFID = Game.AddGUISF(RoomNameGui.fadeTime, "RoomNameGui.Fade", "s", "0.0")
    end
end

---fades the room name in or out
---@param fade_val string the alpha value assigned to `FadeColorRGB`
---@param fade_time string? the time to fade to `fade_val`, in seconds. defaults to `"0.5"`
function RoomNameGui.Fade(fade_val, fade_time)
    fade_time = fade_time or "0.5"

    local container = RoomNameGui.container
    if not container then
        Game.LogWarn(0, "No ui for RoomNameGui")
        return
    end

    container:SetProperties({FadeColorR = "-1.0", FadeColorG = "-1.0", FadeColorB = "-1.0", FadeColorA = fade_val, FadeTime = fade_time})
end