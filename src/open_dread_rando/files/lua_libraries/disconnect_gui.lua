DisconnectGui = DisconnectGui or {
    ui = nil,
    container = nil,
}

function DisconnectGui.Init()
    if DisconnectGui.ui then
        DisconnectGui.ui:Destroy()
        DisconnectGui.ui = nil
        DisconnectGui.container = nil
    end

    local hud = GUI.GetDisplayObject("IngameMenuRoot.iconshudcomposition")
    local ui = GUILib("DisconnectUI", hud)
    local container = ui:AddContainer("Content", {
        X = 0.025,
        Y = 0.25,
        SizeX = 0.2,
        SizeY = 0.04,
        Visible = false,
    })

    container:AddSprite("DisconnetIcon", "HUD_TILESET/DISCONNECT", {
        X = 0.000,
        Y = 0.000,
        SizeX = 0.035,
        SizeY = 0.045,
        ColorR = 0.9, ColorG = 0.1, ColorB = 0.1,
        BlinkColorR = "0.9", BlinkColorG = "0.1", BlinkColorB = "0.1", BlinkAlpha = "0.00000", Blink = "1.00000",
        Enabled = true,
    })

    container:AddLabel("DisconnectText", "Disconnected!", {
        X = "0.042",
        Y = "0.0",
        SizeX = "0.3",
        SizeY = "0.04",
        Font = "digital_small",
        Autosize = false,
    })

    DisconnectGui.ui = ui
    DisconnectGui.container = container
end

function DisconnectGui.Update(visible)
    DisconnectGui.container:SetProperties({Visible = visible})
end
