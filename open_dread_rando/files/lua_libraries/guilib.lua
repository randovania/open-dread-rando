Game.ImportLibrary("system/scripts/class.lua", false)
GUILib = class.New(function(selfref, GUIName)
	selfref.name = GUIName
	selfref.root = nil
	selfref.main = nil
	selfref.children = {}
	-- if GUI.GetDisplayObject(GUIName) == nil then
		selfref.root = GUI.CreateDisplayObjectEx(GUIName, "CDisplayObjectContainer", {StageID = "Up", X = "0.0", Y = "0.0", SizeX = "1.0", SizeY = "1.0", ScaleX = "1.0", ScaleY = "1.0", ColorA = "1.0"})
		selfref.main = GUI.CreateDisplayObject((selfref.root), GUIName.."Main", "CDisplayObjectContainer", {StageID = "Up", X = "0.0", Y = "0.0", SizeX = "1.0", SizeY = "1.0", ScaleX = "1.0", ScaleY = "1.0", ColorA = "1.0"})

		GUI.GetDisplayObject("[Root]"):AddChild((selfref.root))
	-- end

	selfref.Get = function (aself, childName)
		for _, child in pairs(aself.children) do
			if child.name == childName then
				return child
			end
		end
		return nil
	end

	selfref.AddContainer = function(aself, containerName, ContainerProperties)
        if ContainerProperties == nil then
            ContainerProperties = {StageID = "Up", X = "0.0", Y = "0.0", SizeX = "1.0", SizeY = "1.0", ScaleX = "1.0", ScaleY = "1.0", ColorA = "1.0", Enabled = true, Visible = true}
        end
        ContainerProperties["StageID"] = "Up"

		table.insert(aself.children, Container(containerName, ContainerProperties, aself.main))
		return aself:Get(containerName)
	end


    selfref.AddSprite = function(aself, spriteName, spritePath, spriteProperties)
        if spriteProperties ~= nil then
            spriteProperties["SpriteSheetItem"] = spritePath
        else
            spriteProperties = { X = "0.00000", Y = "0.00000", SizeX = "1.00000", SizeY = "1.00000", ScaleX = "1.00000", ScaleY = "1.00000", Angle = "0.00000", FlipX = false, FlipY = false, ColorR = "0.0000", ColorG = "0.00000", ColorB = "0.00000", ColorA = "1.00000", Enabled = true, Visible = true, Autosize = false, SpriteSheetItem = spritePath, USelMode = "Scale", VSelMode = "Scale"}
        end
		table.insert(aself.children, Sprite(spriteName, spriteProperties, aself.main))
		return aself:Get(spriteName)
	end


    selfref.AddMenu = function(aself, menuName, ContainerProperties) --We need a way to add a menu and its children to this list
        if ContainerProperties == nil then
            ContainerProperties = {StageID = "Up", X = "0.0", Y = "0.0", SizeX = "1.0", SizeY = "1.0", ScaleX = "1.0", ScaleY = "1.0", ColorA = "1.0", Enabled = true, Visible = true}
        end
        ContainerProperties["StageID"] = "Up"

		table.insert(aself.children, Container(menuName, ContainerProperties, aself.main))
		return aself:Get(menuName)
	end

    selfref.Show = function(aself)
       -- Game.LogWarn(0, "TRYING TO SHOW GUI")
        GUI.SetProperties((aself.root), {
            Enabled = true,
            Visible = true,
            FadeColorR = "-1.0",
            FadeColorG = "-1.0",
            FadeColorB = "-1.0",
            FadeColorA = "1.0",
        FadeTime = "0.5"
        })

        GUI.SetProperties((aself.main), {
            Enabled = true,
            Visible = true
        })
    end

    selfref.Hide = function(aself)
        GUI.SetProperties((aself.root), {
            Enabled = false,
            Visible = false,
            FadeColorR = "-1.0",
            FadeColorG = "-1.0",
            FadeColorB = "-1.0",
            FadeColorA = "1.0",
        FadeTime = "0.5"
        })

        GUI.SetProperties((aself.main), {
            Enabled = false,
            Visible = false
        })
    end

end)

Container = class.New(function(selfref, containerName, containerParameters, containerParent)
	selfref.name = containerName
	selfref.container = nil
	selfref.parent = containerParent
	selfref.parameters = {}
	selfref.children = {}
--	Game.LogWarn(0, "ALRIGHT SO WE GOT HERE THE FUCK")
	
	--We will have one root and main container that everything else will\should be parented to
	--Check if they exist and create them otherwise.

	selfref.container = GUI.CreateDisplayObject(selfref.parent, containerName, "CDisplayObjectContainer", containerParameters)
	selfref.parameters = containerParameters

	selfref.Get = function (aself, childName)
		for _, child in pairs(aself.children) do
			if child.name == childName then
				return child
			end
		end
		return nil
	end
    selfref.SetProperties = function(aself, props)
        if props ~= nil and type(props) == "table" then
            GUI.SetProperties(aself.container, props)
        end
    end

	selfref.AddLabel = function(aself, labelName, labelText, labelProperties)
        if labelProperties ~= nil then
            labelProperties["Text"] = labelText
        else
            labelProperties = { MinCharWidth = "14", X = "0.0", Y = "0.0", Font = "digital_hefty", TextAlignment = "Left", ScaleX = "0.8", ScaleY = "0.8", Text = labelText}
        end
		table.insert(aself.children, Label(labelName, labelText, labelProperties, aself.container))
        aself:Get(labelName):SetText(labelText)
		return aself:Get(labelName)
	end




  end)

Label = class.New(function(selfref, labelName, labelText, labelProperties, labelParent)
	selfref.name = labelName
	selfref.text = labelText
	selfref.label = nil
	selfref.parent = labelParent

	selfref.label = GUI.CreateDisplayObject(labelParent, labelName, "CLabel", labelProperties)

    selfref.SetProperties = function(aself, props)
        if props ~= nil and type(props) == "table" then
            GUI.SetProperties(aself.label, props)
        end
    end
	selfref.SetText = function(aself, lblText)
		aself.text = lblText
		GUI.SetLabelText(aself.label,aself.text)
		return aself.text
	end
	selfref.GetText = function(aself)
		return aself.text
	end

    ----Some helper functions like SetColor, SetPosition, SetScale
    selfref.SetColor = function(aself, r, g, b, a)
        GUI.SetProperties(aself.label, {
            ColorR = tostring(r),
            ColorG = tostring(g),
            ColorB = tostring(b),
            ColorA = tostring(a)
        })
    end

    selfref.SetPosition = function(aself, x, y)
        GUI.SetProperties(aself.label, {
            X = tostring(x),
            Y = tostring(y)
        })
    end

  end)



  Sprite = class.New(function(selfref, spriteName, spriteProperties, spriteRoot)
	selfref.name = spriteName
	selfref.sprite = spriteRoot:AddChild(GUI.CreateDisplayObjectEx(spriteName, "CSprite", spriteProperties))
    


	

    selfref.SetProperties = function(aself, props)
        if props ~= nil and type(props) == "table" then
            GUI.SetProperties(aself.sprite, props)
        end
    end
    ----Some helper functions like SetColor, SetPosition, SetScale
    selfref.SetColor = function(aself, r, g, b, a)
        GUI.SetProperties(aself.sprite, {
            ColorR = tostring(r),
            ColorG = tostring(g),
            ColorB = tostring(b),
            ColorA = tostring(a)
        })
    end

    selfref.SetPosition = function(aself, x, y)
        GUI.SetProperties(aself.sprite, {
            X = tostring(x),
            Y = tostring(y)
        })
    end

    selfref.SetScale = function(aself, x, y)
        GUI.SetProperties(aself.sprite, {
            ScaleX = tostring(x),
            ScaleY = tostring(y)
        })
    end

  end)

  --Menu class
  --Should contain
    --A container that holds the menu
    --A menu items which contains a display string and an OnActivate function

Menu = class.new(function(selfref, menuName, menuItems)
    selfref.name = menuName
    selfref.hasfocus = false
    selfref.selectedIndex = 1
    selfref.items = {}
    if menuItems ~= nil then
        for _,v in pairs(menuItems) do
            table.insert(selfref.items, v)
        end
    end

    selfref.AddItem = function(aselfref, menuItem)
        table.insert(aselfref.items, menuItem)
    end
end)

MenuItem = class.new(function(selfref, itemName, itemActivated, itemGetText)
    selfref.name = itemName
    selfref.OnActivated = nil
    selfref.GetText = nil
    if itemActivated ~= nil then
        selfref.OnActivated = itemActivated
    end

    if itemGetText == nil then
        selfref.GetText = function()
            return selfref.name
        end
    else
        selfref.GetText = itemGetText
    end
end)