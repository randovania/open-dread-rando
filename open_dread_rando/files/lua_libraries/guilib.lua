Game.ImportLibrary("system/scripts/class.lua", false)

local function merge(table1, table2)
    if not table2 then
        return
    end

    for k, v in pairs(table2) do
        table1[k] = v
    end
end

-- #region GUILib

---@class GUILib
---@field name string
---@field root userdata
---@field main userdata
---@field children table
GUILib = class.New(function(obj, guiName)
    obj.name = guiName
    obj.root = nil
    obj.main = nil
    obj.children = {}
    obj.root = GUI.CreateDisplayObjectEx(guiName, "CDisplayObjectContainer", {StageID = "Up", X = "0.0", Y = "0.0", SizeX = "1.0", SizeY = "1.0", ScaleX = "1.0", ScaleY = "1.0", ColorA = "1.0"})
    obj.main = GUI.CreateDisplayObject((obj.root), guiName.."Main", "CDisplayObjectContainer", {StageID = "Up", X = "0.0", Y = "0.0", SizeX = "1.0", SizeY = "1.0", ScaleX = "1.0", ScaleY = "1.0", ColorA = "1.0"})

    GUI.GetDisplayObject("[Root]"):AddChild((obj.root))
end)

function GUILib:Get(childName)
    for _, child in pairs(self.children) do
        if child.name == childName then
            return child
        end
    end
    return nil
end

function GUILib:AddContainer(containerName, ContainerProperties)
    if ContainerProperties == nil then
        ContainerProperties = {StageID = "Up", X = "0.0", Y = "0.0", SizeX = "1.0", SizeY = "1.0", ScaleX = "1.0", ScaleY = "1.0", ColorA = "1.0", Enabled = true, Visible = true}
    end
    ContainerProperties["StageID"] = "Up"

    table.insert(self.children, Container(containerName, ContainerProperties, self.main))
    return self:Get(containerName)
end

function GUILib:AddSprite(spriteName, spritePath, spriteProperties)
    if spriteProperties ~= nil then
        spriteProperties["SpriteSheetItem"] = spritePath
    else
        spriteProperties = { X = "0.00000", Y = "0.00000", SizeX = "1.00000", SizeY = "1.00000", ScaleX = "1.00000", ScaleY = "1.00000", Angle = "0.00000", FlipX = false, FlipY = false, ColorR = "0.0000", ColorG = "0.00000", ColorB = "0.00000", ColorA = "1.00000", Enabled = true, Visible = true, Autosize = false, SpriteSheetItem = spritePath, USelMode = "Scale", VSelMode = "Scale"}
    end
    table.insert(self.children, Sprite(spriteName, spriteProperties, self.main))
    return self:Get(spriteName)
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
    -- Game.LogWarn(0, "TRYING TO SHOW GUI")
    GUI.SetProperties((self.root), {
        Enabled = true,
        Visible = true,
        FadeColorR = "-1.0",
        FadeColorG = "-1.0",
        FadeColorB = "-1.0",
        FadeColorA = "1.0",
    FadeTime = "0.5"
    })

    GUI.SetProperties((self.main), {
        Enabled = true,
        Visible = true
    })
end

function GUILib:Hide()
    GUI.SetProperties((self.root), {
        Enabled = false,
        Visible = false,
        FadeColorR = "-1.0",
        FadeColorG = "-1.0",
        FadeColorB = "-1.0",
        FadeColorA = "1.0",
    FadeTime = "0.5"
    })

    GUI.SetProperties((self.main), {
        Enabled = false,
        Visible = false
    })
end

-- #endregion GUILib

-- #region Container

---@class Container
---@field name string
---@field container userdata
---@field parent userdata
---@field parameters table
---@field children table
Container = class.New(function(obj, containerName, containerParameters, containerParent)
	obj.name = containerName
	obj.container = nil
	obj.parent = containerParent
	obj.parameters = {}
	obj.children = {}

	--We will have one root and main container that everything else will\should be parented to
	--Check if they exist and create them otherwise.

	obj.container = GUI.CreateDisplayObject(obj.parent, containerName, "CDisplayObjectContainer", containerParameters)
	obj.parameters = containerParameters
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
    local properties = { MinCharWidth = "14", X = "0.0", Y = "0.0", Font = "digital_hefty", TextAlignment = "Left", VerticalTextAlignment = "Center", ScaleX = "1.0", ScaleY = "1.0", Text = labelText }
    merge(properties, labelProperties)

    local label = Label(labelName, labelText, properties, self.container)
    table.insert(self.children, label)
    return label
end

--#endregion Container

--#region Label

Label = class.New(function(obj, labelName, labelText, labelProperties, labelParent)
	obj.name = labelName
	obj.text = labelText
	obj.label = nil
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
    GUI.SetLabelText(self.label,self.text)
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

Sprite = class.New(function(obj, spriteName, spriteProperties, spriteRoot)
	obj.name = spriteName

	obj.sprite = spriteRoot:AddChild(GUI.CreateDisplayObjectEx(spriteName, "CSprite", spriteProperties))
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