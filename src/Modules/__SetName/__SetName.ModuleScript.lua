local module = {}

if script.Parent:FindFirstChild("OldSetName") ~= nil then
	return {}
end

local currentFont = "Gotham"

function module.load(core)
	-- Load name of all players
	local coretab = core.getCoreTable()
	local fold = coretab["assetfold"]:WaitForChild("PlayerNames")
	local ourname = fold:WaitForChild(game:GetService("Players").LocalPlayer.Name)
	local uis = game:GetService("UserInputService")
	local curname = ourname.Value
	local lp = game:GetService("Players").LocalPlayer
	local m = lp:GetMouse()
	local rs = game:GetService("RunService")
	
	local function onValueChange(p) -- p is other player's name
		if game:GetService("Players"):FindFirstChild(p) ~= nil and fold[p].Value ~= "" then -- if the player exists
			local filtered = core.escalateFunction(script, fold[p].Value, game:GetService("Players"):FindFirstChild(p))
			local ui = game:GetService("Players")[p].Character.HumanoidRootPart.NameUI.Text
			ui.Text = filtered
		end
	end
	
	for i, v in pairs(fold:GetChildren()) do -- go through and set all current names
		onValueChange(v) -- update now
		v:GetPropertyChangedSignal("Value"):Connect(function() -- whenever the value changes, send update
			onValueChange(v.Name)
		end)
		if game:GetService("Players"):FindFirstChild(v.Name) ~= nil and game:GetService("Players")[v.Name].Character ~= nil and game:GetService("Players"):FindFirstChild(v.Name) ~= game:GetService("Players").LocalPlayer then
			local nameui = game:GetService("Players")[v.Name].Character:WaitForChild("HumanoidRootPart"):WaitForChild("NameUI", 3)
			if nameui ~= nil and v.Value ~= "" and game:GetService("Players"):FindFirstChild(v.Name) ~= nil then
				local filtered = core.escalateFunction(script, v.Value, game:GetService("Players"):FindFirstChild(v.Name))
				nameui.Text.Text = filtered
			end
		end
	end
	
	fold.ChildAdded:Connect(function(v) -- when a new value is added, attach listener
		v:GetPropertyChangedSignal("Value"):Connect(function() -- whenever the value changes, send update
			onValueChange(v.Name)
		end)
	end)
	
	-- now for the actual UI stuff
	local masterFrame = script:WaitForChild("SetName"):Clone()
	core.makeDraggable(masterFrame)
	local mainui = masterFrame:WaitForChild("SetName")
	masterFrame.Parent = coretab["ui"]
	
	mainui:WaitForChild("NameBox").TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
	
	local function uiclicked()
		masterFrame.Visible = true
	end
	
	masterFrame:WaitForChild("TopBar"):WaitForChild("CloseButton").MouseButton1Click:Connect(function()
		masterFrame.Visible = false
	end)
	
	mainui:WaitForChild("FinishButton").MouseButton1Click:Connect(function()
		local textbox = mainui.NameBox
		local text = textbox.Text .. "\n[ " .. game:GetService("Players").LocalPlayer.Name .. " ]"
		core.escalateEvent(script, text, textbox.TextColor3, textbox.TextStrokeColor3, textbox.Font, textbox.TextStrokeTransparency)
	end)
	
	mainui:WaitForChild("RemoveName").MouseButton1Click:Connect(function()
		core.escalateEvent(script, false)
	end)
	
	
	-- new color applet stuff
	local TextColorWindow = script:WaitForChild("ColorSelector")
	local BorderColorWindow = script:WaitForChild("BorderColorSelector")
	local FontWindow = script:WaitForChild("FontSelector")
	TextColorWindow.Parent = coretab["ui"]
	BorderColorWindow.Parent = coretab["ui"]
	FontWindow.Parent = coretab["ui"]
	
	local TextApplet = TextColorWindow:WaitForChild("ColorSelector")
	local BorderApplet = BorderColorWindow:WaitForChild("BorderColorSelector")
	local FontApplet = FontWindow:WaitForChild("FontSelector")
	
	core.makeDraggable(TextColorWindow)
	core.makeDraggable(BorderColorWindow)
	core.makeDraggable(FontWindow)
	TextColorWindow.Visible = false
	BorderColorWindow.Visible = false
	FontWindow.Visible = false
	
	local namebox = mainui.NameBox
	namebox.TextColor3 = Color3.fromRGB(255, 255, 255)
	namebox.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	namebox.TextStrokeTransparency = 0.6
	namebox.Font = Enum.Font.Gotham
	
	
	mainui:WaitForChild("TextColor").MouseButton1Click:Connect(function()
		TextColorWindow.Visible = true
	end)
	
	mainui.TextColor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	
	mainui:WaitForChild("TextBorderColor").MouseButton1Click:Connect(function()
		BorderColorWindow.Visible = true
	end)
	
	mainui.TextBorderColor.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	
	mainui:WaitForChild("Font").MouseButton1Click:Connect(function()
		FontWindow.Visible = true
	end)
	
	TextColorWindow:WaitForChild("TopBar"):WaitForChild("CloseButton").MouseButton1Click:Connect(function()
		TextColorWindow.Visible = false
	end)
	
	BorderColorWindow:WaitForChild("TopBar"):WaitForChild("CloseButton").MouseButton1Click:Connect(function()
		BorderColorWindow.Visible = false
	end)
	
	FontWindow:WaitForChild("TopBar"):WaitForChild("CloseButton").MouseButton1Click:Connect(function()
		FontWindow.Visible = false
	end)
	
	local tccolorbut = TextApplet:WaitForChild("ColorBar"):WaitForChild("TextButton")
	tccolorbut.BackgroundTransparency = 1
	tccolorbut.TextTransparency = 1
	local tcgradbut = TextApplet:WaitForChild("Gradient"):WaitForChild("TextButton")
	tcgradbut.BackgroundTransparency = 1
	tcgradbut.TextTransparency = 1
	
	local bccolorbut = BorderApplet:WaitForChild("ColorBar"):WaitForChild("TextButton")
	bccolorbut.BackgroundTransparency = 1
	bccolorbut.TextTransparency = 1
	local bcgradbut = BorderApplet:WaitForChild("Gradient"):WaitForChild("TextButton")
	bcgradbut.BackgroundTransparency = 1
	bcgradbut.TextTransparency = 1
	local bctransbut = BorderApplet:WaitForChild("StrokeTransparency"):WaitForChild("TextButton")
	bctransbut.BackgroundTransparency = 1
	bctransbut.TextTransparency = 1
	
	local colorframe = mainui:WaitForChild("ColorFrame")
	local borderframe = mainui:WaitForChild("BorderFrame")
	local textr = colorframe.R.TextBox
	local textg = colorframe.G.TextBox
	local textb = colorframe.B.TextBox
	local borderr = borderframe.R.TextBox
	local borderg = borderframe.G.TextBox
	local borderb = borderframe.B.TextBox
	local lasttextcolorr = textr.Text
	local lasttextcolorg = textg.Text
	local lasttextcolorb = textb.Text
	
	TextApplet.ColorBar.Selector.BackgroundTransparency = 0
	TextApplet.ColorBar.Selector.BorderSizePixel = 3
	TextApplet.ColorBar.Selector.BackgroundColor3 = Color3.new(255, 0, 0)
	TextApplet.Gradient.Selector.BackgroundTransparency = 0
	TextApplet.Gradient.Selector.BorderSizePixel = 3
	TextApplet.Gradient.Selector.BackgroundColor3 = Color3.new(255, 255, 255)
	
	BorderApplet.ColorBar.Selector.BackgroundTransparency = 0
	BorderApplet.ColorBar.Selector.BorderSizePixel = 3
	BorderApplet.ColorBar.Selector.BackgroundColor3 = Color3.new(255, 0, 0)
	BorderApplet.Gradient.Selector.BackgroundTransparency = 0
	BorderApplet.Gradient.Selector.BorderSizePixel = 3
	BorderApplet.Gradient.Selector.BackgroundColor3 = Color3.new(255, 255, 255)
	BorderApplet.StrokeTransparency.Selector.BackgroundTransparency = 0
	BorderApplet.StrokeTransparency.Selector.BorderSizePixel = 3
	BorderApplet.StrokeTransparency.Selector.BackgroundColor3 = Color3.new(255, 255, 255)
	
	local ver1 = mainui:WaitForChild("NameBox")
	
	local function update()
		lasttextcolorr = textr.Text
		lasttextcolorg = textg.Text
		lasttextcolorb = textb.Text
	end
	
	local function gradientupd(gradient, colorbar)
		local selector = gradient.Selector
		local mx = m.X
		local my = m.Y
		local minx = gradient.AbsolutePosition.X
		local miny = gradient.AbsolutePosition.Y
		local maxx = minx + gradient.AbsoluteSize.X - 5 -- the 5 is to prevent the selector from going totally off
		local maxy = miny + gradient.AbsoluteSize.Y - 5
		if mx > maxx then -- make sure we are within extents
			mx = maxx
		elseif mx < minx then
			mx = minx
		end
		if my > maxy then -- make sure we are within extents
			my = maxy
		elseif my < miny then
			my = miny
		end
		selector.Position = UDim2.new(0, mx - minx, 0, my - miny) -- Change the selector position
		local scaley = (my - miny) / (gradient.AbsoluteSize.Y - 5)
		if scaley > 1 then 
			scaley = 1
		end
		local scalex = (mx - minx) / (gradient.AbsoluteSize.X - 5)
		if scalex > 1 then 
			scalex = 1
		end
		scaley = 1 - scaley
		local colorselector = colorbar.Selector
		local color, _, _ = Color3.toHSV(colorselector.BackgroundColor3)
		selector.BackgroundColor3 = Color3.fromHSV(color, scalex, scaley)
		return scalex, scaley
	end

	local function colorbarupd(colorbar, gradient)
		local my = m.Y
		local selector = colorbar.Selector
		local miny = colorbar.AbsolutePosition.Y
		local maxy = miny + colorbar.AbsoluteSize.Y - 5
		if my > maxy then -- make sure we are within extents
			my = maxy
		elseif my < miny then
			my = miny
		end
		selector.Position = UDim2.new(0, 0, 0, my - miny) -- Change the selector position
		-- note to self: hsv is hue, saturation, brightness - hue is 0-360, saturation and brightness are 0-100
		local scale = (my - miny) / (colorbar.AbsoluteSize.Y - 5)
		if scale > 1 then 
			scale = 1
		end
		selector.BackgroundColor3 = Color3.fromHSV(scale, 1, 1)
		-- we also have to change our gradient
		local gradselector = gradient.Selector
		local a, b, c = Color3.toHSV(gradselector.BackgroundColor3)
		gradselector.BackgroundColor3 = Color3.fromHSV(scale, b, c)
		gradient.Image.BackgroundColor3 = Color3.fromHSV(scale, 1, 1)
		return scale
	end
	
	tccolorbut.MouseButton1Down:Connect(function()
		local curcolor = ver1.TextColor3
		local hue, sat, val = Color3.toHSV(curcolor)
		local gradselector = TextApplet.Gradient.Selector
		local con
		con = rs.RenderStepped:Connect(function()
			local curcolor = colorbarupd(TextApplet.ColorBar, TextApplet.Gradient)
			local _, sat, hue = Color3.toHSV(gradselector.BackgroundColor3)
			local newcolor = Color3.fromHSV(curcolor, sat, hue)
			ver1.TextColor3 = newcolor
			mainui.TextColor.BackgroundColor3 = newcolor
			local r, g, b = newcolor.R, newcolor.G, newcolor.B
			textr.Text = math.ceil(r * 255)
			textg.Text = math.ceil(g * 255)
			textb.Text = math.ceil(b * 255)
			-- update text here
		end)
		while uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
			wait()
		end
		update()
		con:Disconnect()
	end)

	tcgradbut.MouseButton1Down:Connect(function()
		local curcolor = TextApplet.ColorBar.Selector.BackgroundColor3
		local hue, _, _ = Color3.toHSV(curcolor)
		local con
		con = rs.RenderStepped:Connect(function()
			local sat, bright = gradientupd(TextApplet.Gradient, TextApplet.ColorBar)
			local newcolor = Color3.fromHSV(hue, sat, bright)
			ver1.TextColor3 = newcolor
			mainui.TextColor.BackgroundColor3 = newcolor
			local r, g, b = newcolor.R, newcolor.G, newcolor.B
			textr.Text = math.ceil(r * 255)
			textg.Text = math.ceil(g * 255)
			textb.Text = math.ceil(b * 255)
		end)
		while uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
			wait()
		end
		update()
		con:Disconnect()
	end)

	bccolorbut.MouseButton1Down:Connect(function() -- i hate copying and pasting like this but this isn't going to change anyways
		-- also it works i guess
		local curcolor = ver1.TextStrokeColor3
		local hue, sat, val = Color3.toHSV(curcolor)
		local gradselector = BorderApplet.ColorBar.Selector
		local con
		con = rs.RenderStepped:Connect(function()
			local curcolor = colorbarupd(BorderApplet.ColorBar, BorderApplet.Gradient)
			local _, sat, hue = Color3.toHSV(gradselector.BackgroundColor3)
			local newcolor = Color3.fromHSV(curcolor, sat, hue)
			ver1.TextStrokeColor3 = newcolor
			mainui.TextBorderColor.BackgroundColor3 = newcolor
			local r, g, b = newcolor.R, newcolor.G, newcolor.B
			borderr.Text = math.ceil(r * 255)
			borderg.Text = math.ceil(g * 255)
			borderb.Text = math.ceil(b * 255)
			-- update text here
		end)
		while uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
			wait()
		end
		update()
		con:Disconnect()
	end)

	bcgradbut.MouseButton1Down:Connect(function()
		local curcolor = BorderApplet.ColorBar.Selector.BackgroundColor3
		local hue, sat, val = Color3.toHSV(curcolor)
		local con
		con = rs.RenderStepped:Connect(function()
			local sat, bright = gradientupd(BorderApplet.Gradient, BorderApplet.ColorBar)
			local newcolor = Color3.fromHSV(hue, sat, bright)
			ver1.TextStrokeColor3 = newcolor
			mainui.TextBorderColor.BackgroundColor3 = newcolor
			local r, g, b = newcolor.R, newcolor.G, newcolor.B
			borderr.Text = math.ceil(r * 255)
			borderg.Text = math.ceil(g * 255)
			borderb.Text = math.ceil(b * 255)
		end)
		while uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
			wait()
		end
		update()
		con:Disconnect()
	end)
	
	bctransbut.MouseButton1Down:Connect(function()
		local con
		con = rs.RenderStepped:Connect(function()
			local my = m.Y
			local selector = BorderApplet.StrokeTransparency.Selector
			local miny = BorderApplet.StrokeTransparency.AbsolutePosition.Y
			local maxy = miny + BorderApplet.StrokeTransparency.AbsoluteSize.Y - 5
			if my > maxy then -- make sure we are within extents
				my = maxy
			elseif my < miny then
				my = miny
			end
			selector.Position = UDim2.new(0, 0, 0, my - miny) -- Change the selector position
			-- note to self: hsv is hue, saturation, brightness - hue is 0-360, saturation and brightness are 0-100
			local scale = (my - miny) / (BorderApplet.StrokeTransparency.AbsoluteSize.Y - 5)
			if scale > 1 then 
				scale = 1
			end
			ver1.TextStrokeTransparency = scale
		end)
		while uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
			wait()
		end
		update()
		con:Disconnect()
	end)
	
	local function validatergb(num, last) -- takes a number and returns it back
		if num == nil then
			num = last
		elseif num > 255 then
			num = 255
		elseif num < 0 then
			num = 0
		end
		return num
	end
	
	local function updatefromtext(rt, gt, bt, colorbar, gradient, prop)
		-- first, validate all of our numbers
		local r = tonumber(rt.Text)
		r = validatergb(r, lasttextcolorr)
		local g = tonumber(gt.Text)
		g = validatergb(g, lasttextcolorg)
		local b = tonumber(bt.Text)
		b = validatergb(b, lasttextcolorb)

		-- now we have our values, and first we need to update the values
		rt.Text = r
		gt.Text = g
		bt.Text = b
		
		-- get our preview color
		local newcolor = Color3.fromRGB(r, g, b)
		
		local hue, sat, val = Color3.toHSV(newcolor)
		colorbar.Selector.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
		gradient.Selector.BackgroundColor3 = newcolor
		gradient.Image.BackgroundColor3 = newcolor
		
		colorbar.Selector.Position = UDim2.new(0, 0, hue, -2.5)
		gradient.Selector.Position = UDim2.new(sat, -3.5, 1-val, -3.5)
		
		return newcolor
	end
	
	uis.InputBegan:Connect(function(key, waschat)
		if masterFrame.Visible == true and key.KeyCode == Enum.KeyCode.Return then
			local newcolor = updatefromtext(textr, textg, textb, TextApplet.ColorBar, TextApplet.Gradient, "TextColor3")
			ver1.TextColor3 = newcolor
			mainui.TextColor.BackgroundColor3 = newcolor

			newcolor = updatefromtext(borderr, borderg, borderb, BorderApplet.ColorBar, BorderApplet.Gradient, "TextStrokeColor3")
			ver1.TextStrokeColor3 = newcolor
			mainui.TextBorderColor.BackgroundColor3 = newcolor
			
			update()
		end
	end)
	-- color stuff end
	
	-- new font selection
	
	for _, v in pairs(FontApplet:WaitForChild("ScrollingFrame"):GetChildren()) do
		if v:IsA("TextButton") then
			v.MouseButton1Click:Connect(function()
				ver1.Font = Enum.Font[v.Name] -- not attached to the update function
				mainui.Font.Text = v.Name
			end)
		end
	end
	
	core.createUIButton("Set Name", uiclicked, "eeeee")
	
	local char = lp.Character or lp.CharacterAdded:Wait()
	char:WaitForChild("HumanoidRootPart"):WaitForChild("NameUI")
	
	if curname ~= "" then -- HACK HACK HACK HKACH KACHK AHCKACH KACHAKR HACK!!!
		-- big big hack please fix raidmaster please fix bad hack big hack big hack
		-- basically instead of implementing checks we just change the name value to force an update from all users
		core.escalateEvent(script, false)
		while ourname.Value ~= "" do -- HACK MORE HACK HACK HACK BAD HACK HACK HACK
			wait()
		end
		core.escalateEvent(script, curname)
	end
end

function module.loadServer(core) -- This loads the naming service, creates folders & stuff
	local coretab = core.getCoreTable()
	local folder = Instance.new("Folder", coretab["assetfold"])
	folder.Name = "PlayerNames"
	
	for i, v in pairs(game:GetService("Players"):GetChildren()) do -- Since load server has a delay, we need to register our first players
		local name = Instance.new("StringValue", folder)
		name.Value = ""
		name.Name = v.Name
		local pchar = v.Character or v.CharacterAdded:Wait()
		local newui = script.NameUI:Clone()
		newui.Parent = v.Character.HumanoidRootPart
		v.CharacterAdded:Connect(function(c) -- set up listener to clone ui
			local newui = script.NameUI:Clone()
			newui.Parent = c.HumanoidRootPart
			newui.Adornee = c.HumanoidRootPart
		end)
	end
	
	-- Set up listener for value creation
	game:GetService("Players").PlayerAdded:Connect(function(p)
		if not folder:FindFirstChild(p.Name) then
			local name = Instance.new("StringValue", folder)
			name.Value = ""
			name.Name = p.Name
		end
		p.CharacterAdded:Connect(function(c) -- set up listener to clone ui
			local newui = script.NameUI:Clone()
			newui.Parent = c.HumanoidRootPart
			newui.Adornee = c.HumanoidRootPart
		end)
	end)
end

function module.escalatedEvent(p, newname, textcolor, strokecolor, font, stroketrans) -- just changes the value
	local chat = game:GetService("Chat")
	local core = require(game:GetService("ReplicatedStorage").raidRoleplay.Assets.Core)
	local coretab = core.getCoreTable()
	local fold = coretab["assetfold"]:WaitForChild("PlayerNames")
	if newname ~= false then
		fold:FindFirstChild(p.Name).Value = newname
		local char = p.Character
		local ui = char.HumanoidRootPart:WaitForChild("NameUI")
		char.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		if textcolor ~= nil then
			ui.Text.Text = chat:FilterStringForBroadcast(newname, p)
			ui.Text.TextColor3 = textcolor
			ui.Text.TextStrokeColor3 = strokecolor
			ui.Text.TextStrokeTransparency = stroketrans
			ui.Text.Font = font
		end
		ui.Enabled = true
	else
		fold:FindFirstChild(p.Name).Value = ""
		local char = p.Character
		local ui = char.HumanoidRootPart:WaitForChild("NameUI")
		char.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
		ui.Enabled = false
	end
end

function module.escalatedFunction(p, name, otherp) -- this is just a filter function that clients will request because
	--print(p, otherp)
	--print(type(p), type(otherp))
	--print("HELLO???")
	-- filtering on server because we have to
	local chat = game:GetService("Chat")
	local xd = chat:FilterStringAsync(name, otherp, p)
	return xd
end

return module
