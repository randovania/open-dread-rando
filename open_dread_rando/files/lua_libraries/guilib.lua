Game.ImportLibrary("system/scripts/class.lua", false)
Game.ImportLibrary("system/scripts/utils.lua", false)

--#region GUILib

---@class GUILib
---@field name string
---@field root userdata
---@field main userdata
---@field children table
---@operator call(): GUILib
GUILib = class.New(function(obj, guiName, parent)
    obj.name = guiName
    obj.root = nil
    obj.main = nil
    obj.children = {}
    obj.root = GUI.CreateDisplayObjectEx(guiName, "CDisplayObjectContainer", {
        StageID = "Up",
        X = "0.0",
        Y = "0.0",
        SizeX = "1.0",
        SizeY = "1.0",
        ScaleX = "1.0",
        ScaleY = "1.0",
        ColorA = "1.0",
    })
    obj.main = GUI.CreateDisplayObject(obj.root, guiName.."Main", "CDisplayObjectContainer", {
        StageID = "Up",
        X = "0.0",
        Y = "0.0",
        SizeX = "1.0",
        SizeY = "1.0",
        ScaleX = "1.0",
        ScaleY = "1.0",
        ColorA = "1.0",
    })

    if not parent then
        parent = GUI.GetDisplayObject("[Root]")
    end

    parent:AddChild(obj.root)
end)

function GUILib:Destroy()
    GUI.DestroyDisplayObject(self.root)
end

function GUILib:Get(childName)
    for _, child in pairs(self.children) do
        if child.name == childName then
            return child
        end
    end
    return nil
end

function GUILib:AddContainer(containerName, containerProperties)
    local container = Container(containerName, containerProperties, self.main)
    table.insert(self.children, container)
    return container
end

function GUILib:AddPanel(name, properties)
    local panel = Panel(name, properties, self.main)
    table.insert(self.children, panel)
    return panel
end

function GUILib:AddMenu(menuName, ContainerProperties) --We need a way to add a menu and its children to this list
    if ContainerProperties == nil then
        ContainerProperties = {StageID = "Up", X = "0.0", Y = "0.0", SizeX = "1.0", SizeY = "1.0", ScaleX = "1.0", ScaleY = "1.0", ColorA = "1.0", Enabled = true, Visible = true}
    end
    ContainerProperties["StageID"] = "Up"

    table.insert(self.children, Container(menuName, ContainerProperties, self.main))
    return self:Get(menuName)
end

function GUILib:Show()
    GUI.SetProperties(self.root, {
        Enabled = true,
        Visible = true,
        FadeColorR = "-1.0",
        FadeColorG = "-1.0",
        FadeColorB = "-1.0",
        FadeColorA = "1.0",
        FadeTime = "0.5"
    })

    GUI.SetProperties(self.main, {
        Enabled = true,
        Visible = true
    })
end

function GUILib:Hide()
    GUI.SetProperties(self.root, {
        Enabled = false,
        Visible = false,
        FadeColorR = "-1.0",
        FadeColorG = "-1.0",
        FadeColorB = "-1.0",
        FadeColorA = "1.0",
        FadeTime = "0.5"
    })

    GUI.SetProperties(self.main, {
        Enabled = false,
        Visible = false
    })
end

--#endregion GUILib

--#region Container

---@class Container
---@field init fun(self: Container, name: string, properties: table, parent: userdata)
---@field name string
---@field container userdata
---@field parent userdata
---@field properties table
---@field children table
---@operator call(): Container
Container = class.New(function(obj, containerName, containerProperties, containerParent)
    -- Populate default properties
    containerProperties = utils.Merge({
        StageID = "Up",
        X = "0.0",
        Y = "0.0",
        Angle = "0.0",
        SizeX = "1.0",
        SizeY = "1.0",
        ScaleX = "1.0",
        ScaleY = "1.0",
        ColorA = "1.0",
        Enabled = true,
        Visible = true,
    }, containerProperties or {})

	obj.name = containerName
	obj.parent = containerParent
	obj.properties = containerProperties
	obj.children = {}
	obj.container = GUI.CreateDisplayObject(containerParent, containerName, "CDisplayObjectContainer", containerProperties)
end)

function Container:Get(childName)
    for _, child in pairs(self.children) do
        if child.name == childName then
            return child
        end
    end
    return nil
end

function Container:SetProperties(props)
    if props ~= nil and type(props) == "table" then
        GUI.SetProperties(self.container, props)
    end
end

function Container:AddLabel(labelName, labelText, labelProperties)
    local label = Label(labelName, labelText, labelProperties, self.container)
    table.insert(self.children, label)
    return label
end

function Container:AddSprite(spriteName, spritePath, spriteProperties)
    if spritePath then
        spriteProperties = spriteProperties or {}
        spriteProperties["SpriteSheetItem"] = spritePath
    end

    local sprite = Sprite(spriteName, spriteProperties, self.container)
    table.insert(self.children, sprite)
    return sprite
end

--#endregion Container

--#region Panel

---@class Panel: Container
---@field name string
---@field parent userdata
---@field container Container
---@operator call(): Panel
Panel = class.New(
    Container,
    ---@param obj Panel
    ---@param name string
    ---@param properties table
    ---@param parent userdata
    function(obj, name, properties, parent)
        Container.init(obj, name, properties, parent)

        -- Extract metrics from the container object
        local w = tonumber(obj.properties.SizeX)
        local h = tonumber(obj.properties.SizeY)

        -- Add the background
        obj:AddSprite("Background", "WhiteSquare", {
            SizeX = w,
            SizeY = h,
            ColorR = 0.026788899675011635,
            ColorG = 0.09196632355451584,
            ColorB = 0.1320755034685135,
            ColorA = 0.9519607901573181,
        })

        -- Add the corners
        local cornerW = 0.1
        local cornerH = 0.05
        local cornerMarginX = 0.0038
        local cornerMarginY = 0.00675
        local cornerProperties = {
            SizeX = cornerW,
            SizeY = cornerH,
            ColorR = 0.7688679099082947,
            ColorG = 0.9728078842163086,
            ColorB = 1.0,
        }

        obj:AddSprite("CornerDeco-TL", "CZDR-RWK/CORNER_DECO2", utils.Merge(cornerProperties, {
            X = -cornerMarginX,
            Y = -cornerMarginY,
        }))
        obj:AddSprite("CornerDeco-TR", "CZDR-RWK/CORNER_DECO2", utils.Merge(cornerProperties, {
            X = w - cornerW + cornerMarginX,
            Y = -cornerMarginY,
            FlipX = true,
        }))
        obj:AddSprite("CornerDeco-BL", "CZDR-RWK/CORNER_DECO2", utils.Merge(cornerProperties, {
            X = -cornerMarginX,
            Y = h - cornerH + cornerMarginY,
            FlipY = true,
        }))
        obj:AddSprite("CornerDeco-BR", "CZDR-RWK/CORNER_DECO2", utils.Merge(cornerProperties, {
            X = w - cornerW + cornerMarginX,
            Y = h - cornerH + cornerMarginY,
            FlipX = true,
            FlipY = true,
        }))

        -- Add the top/bottom lines
        local lineW = w - (cornerW / 4)
        local lineH = 0.003
        local lineOutset = 0.00425
        local lineProperties = {
            SizeX = lineW,
            SizeY = lineH,
            ColorR = 0.7725489735603333,
            ColorG = 0.9764705896377563,
            ColorB = 1.0,
        }

        obj:AddSprite("CornerDeco-LineT", "WhiteSquare", utils.Merge(lineProperties, {
            X = cornerW / 8,
            Y = -lineOutset,
        }))
        obj:AddSprite("CornerDeco-LineB", "WhiteSquare", utils.Merge(lineProperties, {
            X = cornerW / 8,
            Y = h - lineH + lineOutset,
        }))
    end
)

--#endregion Panel

--#region Label

---@class Label
---@field name string
---@field text userdata
---@field label userdata
---@field parent userdata
---@operator call(): Label
Label = class.New(function(obj, labelName, labelText, labelProperties, labelParent)
    -- Populate default properties
    labelText = labelText or ""
    labelProperties = utils.Merge({
        X = "0.0",
        Y = "0.0",
        Angle = "0.0",
        Font = "digital_hefty",
        TextAlignment = "Left",
        TextVerticalAlignment = "Centered",
        ScaleX = "1.0",
        ScaleY = "1.0",
        Text = labelText,
        Enabled = true,
        Visible = true,
        Autosize = true,
		ColorR = "1.0",
		ColorG = "1.0",
		ColorB = "1.0",
		ColorA = "1.0",
    }, labelProperties or {})

	obj.name = labelName
	obj.text = labelText
	obj.parent = labelParent
	obj.label = GUI.CreateDisplayObject(labelParent, labelName, "CLabel", labelProperties)
end)

function Label:SetProperties(props)
    if props ~= nil and type(props) == "table" then
        GUI.SetProperties(self.label, props)
    end
end

function Label:SetText(lblText)
    self.text = lblText
    GUI.SetLabelText(self.label, self.text)
    self.label:ForceRedraw()
    return self.text
end

function Label:GetText()
    return self.text
end

----Some helper functions like SetColor, SetPosition, SetScale
function Label:SetColor(r, g, b, a)
    GUI.SetProperties(self.label, {
        ColorR = tostring(r),
        ColorG = tostring(g),
        ColorB = tostring(b),
        ColorA = tostring(a)
    })
end

function Label:SetPosition(x, y)
    GUI.SetProperties(self.label, {
        X = tostring(x),
        Y = tostring(y)
    })
end

--#endregion Label

--#region Sprite

---@class Sprite
---@field name string
---@field sprite userdata
---@field parent userdata
---@operator call(): Sprite
Sprite = class.New(function(obj, spriteName, spriteProperties, spriteParent)
    -- Populate default properties
    spriteProperties = utils.Merge({
        X = "0.0",
        Y = "0.0",
        SizeX = "1.0",
        SizeY = "1.0",
        ScaleX = "1.0",
        ScaleY = "1.0",
        Angle = "0.0",
        FlipX = false,
        FlipY = false,
        ColorR = "0.0",
        ColorG = "0.0",
        ColorB = "0.0",
        ColorA = "1.0",
        Enabled = true,
        Visible = true,
        Autosize = false,
		BlendMode = "AlphaBlend",
        USelMode = "Scale",
        VSelMode = "Scale",
    }, spriteProperties or {})

	obj.name = spriteName
	obj.sprite = spriteParent:AddChild(GUI.CreateDisplayObjectEx(spriteName, "CSprite", spriteProperties))
    obj.parent = spriteParent
end)

function Sprite:SetProperties(props)
    if props ~= nil and type(props) == "table" then
        GUI.SetProperties(self.sprite, props)
    end
end

----Some helper functions like SetColor, SetPosition, SetScale
function Sprite:SetColor(r, g, b, a)
    GUI.SetProperties(self.sprite, {
        ColorR = tostring(r),
        ColorG = tostring(g),
        ColorB = tostring(b),
        ColorA = tostring(a)
    })
end

function Sprite:SetPosition(x, y)
    GUI.SetProperties(self.sprite, {
        X = tostring(x),
        Y = tostring(y)
    })
end

function Sprite:SetScale(x, y)
    GUI.SetProperties(self.sprite, {
        ScaleX = tostring(x),
        ScaleY = tostring(y)
    })
end

--#endregion Sprite

--#region Menu

---@class Menu
---@field name string
---@field hasFocus boolean
---@field selectedIndex number
---@field items MenuItem[]
---@operator call(): Menu
Menu = class.new(
    ---@param obj Menu
    function(obj, menuName, menuItems)
        obj.name = menuName
        obj.hasFocus = false
        obj.selectedIndex = 1
        obj.items = {}

        if menuItems then
            for _, v in ipairs(menuItems) do
                table.insert(obj.items, v)
            end
        end
    end
)

function Menu:AddItem(menuItem)
    table.insert(self.items, menuItem)
end

--#endregion Menu

--#region MenuItem

---@class MenuItem
---@field name string
---@field activatedHandler function
---@field text string | fun(): string
---@operator call(): MenuItem
MenuItem = class.new(
    ---@param obj MenuItem
    function(obj, itemName, itemActivated, itemText)
        obj.name = itemName
        obj.activatedHandler = itemActivated
        obj.text = itemText
    end
)

function MenuItem:OnActivated()
    if self.activatedHandler then
        self.activatedHandler()
    end
end

function MenuItem:GetText()
    if type(self.text) == "function" then
        return self.text()
    elseif type(self.text) == "string" then
        return self.text
    else
        return self.name
    end
end

--#endregion MenuItem
