local module = {}

function module.checkIfInvalid(teamname)
	local invalid = false
	local conf = require(script.Configuration)
	for i, v in pairs(conf) do
		if teamname == v then
			invalid = true
		end
	end
	return invalid
end

function module.escalatedEvent(player, team)
	if team ~= nil then
		if not module.checkIfInvalid(team.Name) then
			player.Team = team
		end
	end
end

local function getvalidTeams()
	local teams = {}
	for i, v in pairs(game:GetService("Teams"):GetChildren()) do
		if not module.checkIfInvalid(v.Name) and v:IsA("Team") then
			table.insert(teams, v)
		end
	end
	return teams
end

function module.load(core)
	local valid = false
	
	local coretable = core.getCoreTable()
	local mainUI = script:WaitForChild("TeamMenu"):Clone()
	local ui = mainUI:WaitForChild("TeamMenu")
	mainUI.Parent = coretable["ui"]
	core.makeDraggable(mainUI)
	
	local function makeButton(team)
		local newbutton = ui:WaitForChild("ButtonAsset"):Clone()
		newbutton.Text = team.Name
		newbutton.BorderColor3 = team.TeamColor.Color
		newbutton.Visible = true
		newbutton.Parent = ui.TeamFrame
		newbutton.Name = team.Name
		ui.TeamFrame.CanvasSize = ui.TeamFrame.CanvasSize + UDim2.new(0, 0, 0, 40)
		newbutton.MouseButton1Click:Connect(function()
			core.escalateEvent(script, team)
			core.addLog({["Text"] = game:GetService("Players").LocalPlayer.Name .. " has switched to the team " .. team.Name .. "."})
		end)
	end
	
	local function open()
		ui:WaitForChild("TeamFrame").CanvasSize = UDim2.new(0, 0, 0, 15)
		mainUI.Visible = true
		local teams = getvalidTeams()
		for i, v in pairs(ui.TeamFrame:GetChildren()) do
			if v:IsA("TextButton") then
				v:Destroy()
			end
		end
		for i, v in pairs(teams) do
			makeButton(v)
		end
	end
	
	mainUI:WaitForChild("TopBar"):WaitForChild("CloseButton").MouseButton1Click:Connect(function()
		mainUI.Visible = false
	end)
	
	local button
	
	if #game:GetService("Teams"):GetChildren() > 0 then
		button = core.createUIButton("Teams", open, "ffffg")
	end

	game:GetService("Teams").ChildAdded:Connect(function(item)
		if #(getvalidTeams()) == 1 then
			button = core.createUIButton("Teams", open, "ffffg")
		end
		if not module.checkIfInvalid(item.Name) and item:IsA("Team") then
			makeButton(item)
		end
	end)
	
	game:GetService("Teams").ChildRemoved:Connect(function(item)
		if #(getvalidTeams()) == 1 then
			button:Destroy()
		end
		if ui.TeamFrame:FindFirstChild(item.Name) ~= nil then
			ui.TeamFrame[item.Name]:Destroy()
			ui.TeamFrame.CanvasSize -= UDim2.new(0, 0, 0, 50)
		end
	end)
end


return module
