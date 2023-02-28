Game.ImportLibrary("system/scripts/class.lua", false)
Game.ImportLibrary("system/scripts/utils.lua", false)

-- #region GUILib

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
    obj.root = GUI.CreateDisplayObjectEx(guiName, "CDisplayObjectContainer", {StageID = "Up", X = "0.0", Y = "0.0", SizeX = "1.0", SizeY = "1.0", ScaleX = "1.0", ScaleY = "1.0", ColorA = "1.0"})
    obj.main = GUI.CreateDisplayObject(obj.root, guiName.."Main", "CDisplayObjectContainer", {StageID = "Up", X = "0.0", Y = "0.0", SizeX = "1.0", SizeY = "1.0", ScaleX = "1.0", ScaleY = "1.0", ColorA = "1.0"})

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

-- #endregion GUILib

-- #region Container

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
	obj.container = GUI.CreateDisplayObject(obj.parent, containerName, "CDisplayObjectContainer", containerProperties)
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

--Menu class
--Should contain
--A container that holds the menu
--A menu items which contains a display string and an OnActivate function

Menu = class.new(function(obj, menuName, menuItems)
    obj.name = menuName
    obj.hasfocus = false
    obj.selectedIndex = 1
    obj.items = {}
    if menuItems ~= nil then
        for _,v in pairs(menuItems) do
            table.insert(obj.items, v)
        end
    end
end)

function Menu:AddItem(menuItem)
    table.insert(self.items, menuItem)
end

--#endregion Menu

--#region MenuItem

MenuItem = class.new(function(obj, itemName, itemActivated, itemGetText)
    obj.name = itemName
    obj.OnActivated = nil
    obj.GetText = nil

    if itemActivated ~= nil then
        obj.OnActivated = itemActivated
    end

    if itemGetText == nil then
        obj.GetText = function()
            return obj.name
        end
    else
        obj.GetText = itemGetText
    end
end)

--#endregion MenuItem