DisconnectGui = DisconnectGui or {
    container = nil,
}

function DisconnectGui.Init(panel)
    DisconnectGui.container = panel
    GUI.SetProperties(panel:FindChild("DisconnectIcon"), {
        BlinkColorR = "0.9",
        BlinkColorG = "0.1",
        BlinkColorB = "0.1",
        BlinkAlpha = "0.0",
        Blink = "1.0",
     })
end

function DisconnectGui.Update(visible)
    GUI.SetProperties(DisconnectGui.container, { Visible = visible })
end
