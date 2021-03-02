local module = {}

function module.escalatedEvent(plr, val) -- changes whether the player is hidden or not
	game:GetService("ReplicatedStorage").raidRoleplay.Assets.PlayerHiddenValues[plr.Name].Value = val
end

function module.load(core)
	local coretable = core.getCoreTable()
	local mainui = script:WaitForChild("TeleportMenu"):Clone()
	local ui = mainui:WaitForChild("TeleportMenu")
	mainui.Parent = coretable["ui"]
	core.makeDraggable(mainui)
	local hidden = false
	local secdelay = false
	local nav = ui:WaitForChild("NavigationOptions")
	local toggles = ui:WaitForChild("Toggles")
	local maptpframe = ui:WaitForChild("MapTeleportFrame")
	local plrtpframe = ui:WaitForChild("PlayerTeleportFrame")
	local buttonasset = ui:WaitForChild("ButtonAsset")
	local plrs = game:GetService("Players")
	local char = plrs.LocalPlayer.Character or game:GetService("Players").LocalPlayer.CharacterAdded:Wait()
	-- tabs here
	local plrtptab = nav:WaitForChild("PlayerTeleport")
	local maptptab = nav:WaitForChild("PlaceTeleport")
	
	-- options here
	local delaybutton = core.createToggle(toggles:WaitForChild("Delay"))
	delaybutton:Deactivate()
	
	local hiddenbutton = core.createToggle(toggles:WaitForChild("Hidden"))
	hiddenbutton:Deactivate()
	-- other stuff
	
	local blocktpfold = coretable["assetfold"]:WaitForChild("PlayerHiddenValues")
	local ourhiddenval = blocktpfold:WaitForChild(game:GetService("Players").LocalPlayer.Name)
	hidden = ourhiddenval.Value
	
	delaybutton.MouseButton1Click:Connect(function()
		secdelay = not secdelay
	end)
	
	hiddenbutton.MouseButton1Click:Connect(function()
		hidden = not hidden
		core.escalateEvent(script, hidden)
	end)
	
	local function genplayerbuttons()
		for i, v in pairs(plrtpframe:GetChildren()) do
			if v:IsA("TextButton") then
				v:Destroy()
			end
		end
		plrtpframe.CanvasSize = UDim2.new(0, 0, 0, 10)
		local validcount = 0
		for i, v in pairs(game:GetService("Players"):GetChildren()) do
			if not blocktpfold[v.Name].Value and v ~= game:GetService("Players").LocalPlayer then -- if they aren't blocking tps
				local newbutton = buttonasset:Clone()
				newbutton.Parent = plrtpframe
				--newbutton.Position = UDim2.new(0.05, 0, 0, 5) + UDim2.new(0, 0, 0, 35 * validcount)
				newbutton.Visible = true
				newbutton.Text = v.Name
				newbutton.Name = v.Name
				newbutton.MouseButton1Click:Connect(function()
					if not blocktpfold[v.Name].Value and v.Character ~= nil and v.Character:FindFirstChild("HumanoidRootPart") ~= nil then
						if secdelay then
							wait(3)
						end
						char:MoveTo(v.Character.HumanoidRootPart.Position)
					end
				end)
				validcount = validcount + 1
				plrtpframe.CanvasSize = plrtpframe.CanvasSize + UDim2.new(0, 0, 0, 35)
			end
		end
	end
	
	local function openui()
		genplayerbuttons()
		mainui.Visible = true
	end
	
	maptptab.MouseButton1Click:Connect(function()
		plrtpframe.Visible = false
		maptpframe.Visible = true
	end)
	
	plrtptab.MouseButton1Click:Connect(function()
		genplayerbuttons()
		plrtpframe.Visible = true
		maptpframe.Visible = false
	end)
	
	
	
	mainui:WaitForChild("TopBar"):WaitForChild("CloseButton").MouseButton1Click:Connect(function()
		mainui.Visible = false
	end)
	
	-- generate map teleports here
	maptpframe.CanvasSize = UDim2.new(0, 0, 0, 10)
	local maptps = game:GetService("Workspace"):WaitForChild("MapTeleports", 3)
	if maptps ~= nil then
		for i, v in pairs(maptps:GetChildren()) do
			local newbutton = buttonasset:Clone()
			newbutton.Parent = maptpframe
			newbutton.Text = v.Name
			newbutton.Name = v.Name
			newbutton.Position = UDim2.new(0.05, 0, 0, 5) + UDim2.new(0, 0, 0, 35 * (i - 1))
			newbutton.Visible = true
			newbutton.MouseButton1Click:Connect(function()
				if secdelay then
					wait(3)
				end
				char:MoveTo(v.Position)
			end)
			maptpframe.CanvasSize = maptpframe.CanvasSize + UDim2.new(0, 0, 0, 35)
		end
	else
		maptptab.Visible = false
		plrtptab.Position = UDim2.new(0.35, 0, 0, 0)
		plrtpframe.Visible = true
		maptpframe.Visible = false
	end
	
	core.createUIButton("Teleport Menu", openui, "fffff")
end

function module.loadServer(core)
	local maptps = game:GetService("Workspace"):WaitForChild("MapTeleports", 5)
	if maptps ~= nil then
		for i, v in pairs(maptps:GetChildren()) do -- loop through, make sure all teleports are locked, or if it isn't a part, remove it
			if v:IsA("BasePart") then
				v.Locked = true
			else
				v:Destroy()
			end
		end
	end
	
	local coretable = core.getCoreTable()
	local hiddenvals = Instance.new("Folder", coretable["assetfold"])
	hiddenvals.Name = "PlayerHiddenValues"
	local function addval(p) -- makes each player's hidden value
		if hiddenvals:FindFirstChild(p.Name) == nil then
			local val = Instance.new("BoolValue", hiddenvals)
			val.Name = p.Name
			val.Value = false
		end		
	end
	
	game:GetService("Players").PlayerAdded:Connect(function(p)
		addval(p)
	end)
	
	for i, v in pairs(game:GetService("Players"):GetChildren()) do -- loop through pre-existing players because loadServer loads a bit late in studio mainly
		addval(v)
	end
end

return module
