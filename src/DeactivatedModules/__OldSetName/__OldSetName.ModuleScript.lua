local module = {}

function module.load(core)
	-- Load name of all players
	local coretab = core.getCoreTable()
	local fold = coretab["assetfold"]:WaitForChild("PlayerNames")
	local ourname = fold:WaitForChild(game:GetService("Players").LocalPlayer.Name)
	local curname = ourname.Value
	local lp = game:GetService("Players").LocalPlayer
	
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
	
	local function uiclicked()
		masterFrame.Visible = true
	end
	
	masterFrame:WaitForChild("TopBar"):WaitForChild("CloseButton").MouseButton1Click:Connect(function()
		masterFrame.Visible = false
	end)
	
	mainui:WaitForChild("FinishButton").MouseButton1Click:Connect(function()
		local text = mainui.NameBox.Text .. "\n[ " .. game:GetService("Players").LocalPlayer.Name .. " ]"
		core.escalateEvent(script, text, fold)
	end)
	
	mainui:WaitForChild("RemoveName").MouseButton1Click:Connect(function()
		core.escalateEvent(script, false, fold)
	end)
	
	core.createUIButton("Set Name", uiclicked, "eeeee")
	
	local char = lp.Character or lp.CharacterAdded:Wait()
	char:WaitForChild("HumanoidRootPart"):WaitForChild("NameUI")
	
	if curname ~= "" then -- HACK HACK HACK HKACH KACHK AHCKACH KACHAKR HACK!!!
		-- big big hack please fix raidmaster please fix bad hack big hack big hack
		-- basically instead of implementing checks we just change the name value to force an update from all users
		core.escalateEvent(script, false, fold)
		while ourname.Value ~= "" do -- HACK MORE HACK HACK HACK BAD HACK HACK HACK
			wait()
		end
		core.escalateEvent(script, curname, fold)
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

function module.escalatedEvent(p, newname, fold) -- just changes the value
	local chat = game:GetService("Chat")
	if newname ~= false then
		fold:FindFirstChild(p.Name).Value = newname
		local char = p.Character
		local ui = char.HumanoidRootPart:WaitForChild("NameUI")
		char.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		ui.Text.Text = chat:FilterStringForBroadcast(newname, p)
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
