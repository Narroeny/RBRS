-- allows the player to control the lighting settings of various effects on their client

local module = {}

function module.load(core)
	local coretab = core.getCoreTable()
	local mainui = script:WaitForChild("LightingMenu"):Clone()
	local ui = mainui:WaitForChild("LightingMenu")
	core.makeDraggable(mainui)
	mainui.Parent = coretab["ui"]
	
	-- this code is long and dumb and manual but i guess it works
	local navarea = ui:WaitForChild("NavigationOptions")
	local frames = ui:WaitForChild("SettingsFrames")
	
	-- do open and closing
	local function open()
		mainui.Visible = true
	end
	
	local function close()
		mainui.Visible = false
	end
	
	core.createUIButton("Lighting Menu", open, "fgggg")
	mainui:WaitForChild("TopBar"):WaitForChild("CloseButton").MouseButton1Click:Connect(close)
	
	-- Register all of our navigation buttons.
	local function registertab(button, menu)
		button.MouseButton1Click:Connect(function()
			for i, v in pairs(frames:GetChildren()) do
				if v.Name ~= menu.Name then
					v.Visible = false
				else
					v.Visible = true
				end
			end
		end)
	end
	
	-- register all of them (epic loop)
	for i, v in pairs(frames:GetChildren()) do -- loop through frames, find their buttons, set up events
		registertab(navarea:WaitForChild(v.Name), v)
	end
	-- locate all of our settings items, or make them if they do not exist
	local general = game:GetService("Lighting") -- i hope this one exists ---- edit 6/16/2020; people can rename this;
	-- it does not always exist... FRICK HECK HECK HECK POOP!!!!!!
	
	local function geteffect(name)
		local x = general:FindFirstChildWhichIsA(name)
		if x == nil then
			x = Instance.new(name, general)
			x.Enabled = false
		end
		return x
	end
	
	local bloom = geteffect("BloomEffect")
	local blur = geteffect("BlurEffect")
	local cc = geteffect("ColorCorrectionEffect")
	local dof = geteffect("DepthOfFieldEffect")
	local sr = geteffect("SunRaysEffect")
	local uis = game:GetService("UserInputService")
	
	-- utility functions
	local function color3pack(a, b, c)
		local a, b, c = tonumber(a), tonumber(b), tonumber(c)
		print(a, b, c)
		if a and b and c then
			return Color3.new(a, b, c)
		end
		return nil
	end
	
	local function color3unpack(c3)
		return math.floor(c3.R * 100) / 100, math.floor(c3.G * 100) / 100, math.floor(c3.B * 100) / 100
	end
	-- init all of our buttons
	for _, frame in pairs(frames:GetChildren()) do
		for _, prop in pairs(frame:GetChildren()) do
			if prop:IsA("Frame") then
				-- firstly, get our effect
				local master
				local changedsignal
				if frame.Name == "General" then
					master = general
					changedsignal = general:GetPropertyChangedSignal(prop.Name)
				else
					master = general[frame.Name]
					changedsignal = general[frame.Name]:GetPropertyChangedSignal(prop.Name)
				end
				if prop:FindFirstChild("Indicator") ~= nil then -- if the property is a toggle
					local toggle = core.createToggle(prop.Indicator)
					if master[prop.Name] == true then
						toggle:Activate()
					end
					toggle.MouseButton1Click:Connect(function()
						master[prop.Name] = toggle.Status
					end)
					changedsignal:Connect(function()
						if master[prop.Name] == true then
							toggle:Activate()
						else
							toggle:Deactivate()
						end
					end)
				end
				if prop:FindFirstChild("TextBox") ~= nil then -- single value, number value
					local textbox = prop.TextBox
					textbox.Text = math.floor(master[prop.Name] * 100) / 100
					textbox:GetPropertyChangedSignal("Text"):Connect(function()
						local num = tonumber(textbox.Text)
						if num ~= nil then
							master[prop.Name] = textbox.Text
						end
					end)
					changedsignal:Connect(function()
						textbox.Text = math.floor(master[prop.Name] * 100) / 100
					end)
				end
				if prop:FindFirstChild("1") ~= nil then -- oh fun
					local a = prop[1]
					local b = prop[2]
					local c = prop[3]
					local function resettext()
						local at, bt, ct = color3unpack(master[prop.Name])
						a.Text = at
						b.Text = bt
						c.Text = ct
					end
					resettext()
					for i, v in pairs({a, b, c}) do
						v.FocusLost:Connect(function()
							local c3 = color3pack(a.Text, b.Text, c.Text)
							if c3 ~= nil then
								master[prop.Name] = c3
							end
						end)
					end
					changedsignal:Connect(function()
						resettext()
					end)
				end
			end
		end
	end
end

return module

