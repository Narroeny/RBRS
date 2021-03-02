-- hhhhh

local module = {}

local plrs = game:GetService("Players")
local ts = game:GetService("TweenService")
local conf = require(script:WaitForChild("Configuration"))

banList = {}
serverVoteCooldown = tick()
playerCooldowns = {}
activeVote = false

playerParts = {}

function module.load(core)
	local coretab = core.getCoreTable()
	local topui = script:WaitForChild("KickMenu"):Clone()
	local ui = topui:WaitForChild("KickMenu")
	local topbar = topui:WaitForChild("TopBar")
	local kickuimain = script:WaitForChild("VotingMenu"):Clone()
	local kickui = kickuimain:WaitForChild("VotingMenu")
	local votingUI = kickui:WaitForChild("Voting")
	local resultUI = kickui:WaitForChild("Result")
	
	local banneduimain = script:WaitForChild("UnbanMenu"):Clone()
	local bannedui = banneduimain:WaitForChild("UnbanMenu")
	
	local openPos = kickuimain.Position
	local closePos = kickuimain.Position + UDim2.new(0.3, 0, 0, 0)
	
	kickuimain:WaitForChild("TopBar"):WaitForChild("CloseButton").MouseButton1Click:Connect(function()
		kickuimain.Position = closePos
		kickuimain.Visible = false
	end)
	kickuimain.Position = closePos
	
	core.makeDraggable(topui)
	core.makeDraggable(banneduimain)
	topui.Parent = coretab["ui"]
	kickuimain.Parent = coretab["ui"]
	banneduimain.Parent = coretab["ui"]
	
	topbar:WaitForChild("CloseButton").MouseButton1Click:Connect(function()
		topui.Visible = false
	end)
	
	banneduimain:WaitForChild("TopBar"):WaitForChild("CloseButton").MouseButton1Click:Connect(function()
		banneduimain.Visible = false
	end)
	
	local function open()
		topui.Visible = true
	end
	
	local function addEntry(p)
		if not core.isAdmin(p) and p ~= plrs.LocalPlayer then
			local newEntry = ui.EntryAsset:Clone()
			newEntry.Name = p.Name
			newEntry.TextLabel.Text = p.Name
			newEntry.Parent = ui.KickTargets
			newEntry.Visible = true
			if ui.KickTargets:FindFirstChild("NoEntryInfo") then
				ui.KickTargets["NoEntryInfo"]:Destroy()
			end
			newEntry.Button.MouseButton1Click:Connect(function()
				if not activeVote then
					topui.Visible = false
					core.escalateEvent(script, p.Name)
					ui.KickTargets.Visible = false
					ui.WaitScreen.Visible = true
					wait(conf.PlayerVoteKickCooldown + 1)
					ui.KickTargets.Visible = true
					ui.WaitScreen.Visible = false
				end
			end)
			ui.KickTargets.CanvasSize += UDim2.new(0, 0, 0, 55)
		end
	end
	
	for _, v in pairs(plrs:GetChildren()) do
		addEntry(v)
	end
	
	plrs.PlayerAdded:Connect(function(p)
		addEntry(p)
	end)
	
	plrs.PlayerRemoving:Connect(function(p)
		if ui.KickTargets:FindFirstChild(p.Name) then
			ui.KickTargets[p.Name]:Destroy()
		end
		if #(ui.KickTargets:GetChildren()) == 2 then
			local a = ui.NoEntryInfo:Clone()
			a.Parent = ui.KickTargets
			a.Visible = true
		end
	end)
	
	coroutine.wrap(function()
		while true do
			votingUI.Timer.Text = tonumber(votingUI.Timer.Text) - 1
			wait(1)
		end
	end)()
	
	script:WaitForChild("Vote").OnClientEvent:Connect(function(info)
		-- the info that passes is formatted like this
		--[[
		{["Yes"] = number, ["No"] = number, ["Target"] = string, ["InitPlayer"] = string, ["Voting"] = true, ["VoteStarted"] = true
		["VotePassed"] = true,
		]]
		activeVote = true
		if kickuimain.Position ~= openPos then
			ts:Create(kickuimain, TweenInfo.new(0.45, Enum.EasingStyle.Quad), {Position = openPos}):Play()
		end
		if info["Voting"] then
			votingUI.Info.Text = info["InitPlayer"] .. " has started a vote kick on: " .. info["Target"]
			votingUI.UserPrompt.Text = "Would you like to kick " .. info["Target"]
			votingUI.Yes.TextLabel.Text = info["Yes"]
			votingUI.No.TextLabel.Text = info["No"]
			votingUI.Visible = true
			resultUI.Visible = false
				-- pName has started a vote kick on:
			--Would you like to kick targname?
		else
			local status = "SUCCEEDED"
			if not info["VotePassed"] then
				status = "FAILED"
			end
			resultUI.TextLabel.Text = "The vote to kick " .. info["Target"] .. " by " .. info["InitPlayer"]
			resultUI.TextLabel.Text = resultUI.TextLabel.Text .. " has " .. status .. ". [" .. info["Yes"] .. "-" .. info["No"] .. "]"
			-- The vote to kick [pname] by [pname] has SUCCEEDED / FAILED. [0-0]
			votingUI.Visible = false
			resultUI.Visible = true
			wait(5)
			ts:Create(kickuimain, TweenInfo.new(0.45, Enum.EasingStyle.Quad), {Position = closePos}):Play()
			activeVote = false
		end
		if info["VoteStarted"] then 
			kickuimain.Position = closePos
			votingUI.Timer.Text = conf.KickTime
			script.Notification:Play()
			kickuimain.Visible = true
			votingUI.Yes.TextButton.Visible = true
			votingUI.No.TextButton.Visible = true
		end
	end)
	
	votingUI:WaitForChild("Yes"):WaitForChild("TextButton").MouseButton1Click:Connect(function()
		script.Vote:FireServer(true)
	end)
	
	votingUI:WaitForChild("No"):WaitForChild("TextButton").MouseButton1Click:Connect(function()
		script.Vote:FireServer(false)
	end)
	
	core.createUIButton("Vote Kick", open, "hhhhh")
	
	if core.isAdmin() then
		local function open2()
			banneduimain.Visible = true
			local bannedPlayers = core.escalateFunction(script)
			for i, v in pairs(bannedui.UnbanTargets:GetChildren()) do
				if v:IsA("Frame") then
					v:Destroy()
				end
			end
			bannedui.UnbanTargets.CanvasSize = UDim2.new(0, 0, 0, 5)
			if #bannedPlayers > 0 then
				for i, v in pairs(bannedPlayers) do
					local newasset = bannedui.EntryAsset:Clone()
					newasset.Visible = true
					newasset.Parent = bannedui.UnbanTargets
					newasset.TextLabel.Text = v
					newasset.Button.MouseButton1Click:Connect(function()
						newasset:Destroy()
						bannedui.UnbanTargets.CanvasSize -= UDim2.new(0, 0, 0, 55)
						script.UnbanPlayer:FireServer(v)
					end)
					bannedui.UnbanTargets.CanvasSize += UDim2.new(0, 0, 0, 55)
				end
			else
				local nobanned = bannedui.NoEntryInfo:Clone()
				nobanned.Parent = bannedui.UnbanTargets
				nobanned.Visible = true
			end
		end
		
		core.createUIButton("Banned Players", open2, "hhhhi")
	end
end

function module.loadServer(core)
	script:WaitForChild("LogCreatedParts").OnServerEvent:Connect(function(p, parts)
		if not core.isAdmin(p) then
			for _, v in pairs(parts) do
				if v.Locked or (v:FindFirstChild("RRPartOwner") and v.RRPartOwner.Value ~= p.Name) then
					--v:Kick("Failure to validate proper part creation call.")
				else
					if playerParts[p.Name] == nil then
						playerParts[p.Name] = {}
					end
					table.insert(playerParts[p.Name], v)
				end
			end
		end
	end)
	
	plrs.PlayerAdded:Connect(function(p)
		if table.find(banList, p.Name) then
			p:Kick("You have been kicked from this game server.")
		end
	end)
	
	script:WaitForChild("UnbanPlayer").OnServerEvent:Connect(function(p, player)
		if core.isAdmin(p) then
			for i, name in pairs(banList) do
				if name == player then
					table.remove(banList, i)
				end
			end
		end
	end)
end

function module.escalatedEvent(p, target)
	local core = require(game:GetService("ReplicatedStorage").raidRoleplay.Assets.Core)
	if plrs:FindFirstChild(target) ~= nil and (not core.isAdmin(target)) and (playerCooldowns[p.Name] == nil or playerCooldowns[p.Name] < tick()) and serverVoteCooldown < tick() and not activeVote then
		local initPlayer = p.Name
		local target = plrs[target].Name
		core.addLog({["Text"] = initPlayer .. " has started a vote kick on " .. target .. "."})
		activeVote = true
		local voteTable = {}
		local rem = script:WaitForChild("Vote")
		rem:FireAllClients({["Yes"] = 0, ["No"] = 0, ["Target"] = target, ["InitPlayer"] = initPlayer, ["Voting"] = true, ["VoteStarted"] = true})
		local con
		
		local function updateClients()
			local yes = 0
			local no = 0
			for i, v in pairs(voteTable) do
				if v then
					yes += 1
				else
					no += 1
				end
			end
			rem:FireAllClients({["Yes"] = yes, ["No"] = no, ["Target"] = target, ["InitPlayer"] = initPlayer, ["Voting"] = true})
		end
		
		con = rem.OnServerEvent:Connect(function(p, vote)
			voteTable[p.Name] = vote
			updateClients()
		end)
	
		wait(conf.KickTime)
		
		con:Disconnect()
		
		local yes = 0
		local no = 0
		for i, v in pairs(voteTable) do
			if v then
				yes += 1
			else
				no += 1
			end
		end
		
		local resetNo = false
		if no == 0 then 
			no = 1
			resetNo = true
		end
		if (yes / no) >= conf.PlayerPercentageRequired and yes > conf.MinimumVotesRequired then
			rem:FireAllClients({["Yes"] = yes, ["No"] = (resetNo and 0) or no, ["Target"] = target, ["InitPlayer"] = initPlayer, ["Voting"] = false, ["VotePassed"] = true})
			table.insert(banList, target)
			print(target)
			if plrs:FindFirstChild(target) then
				plrs[target]:Kick("You have been vote-kicked from the game.")
			end
			if playerParts[target] then
				for i, v in pairs(playerParts[target]) do
					v:Destroy("You have been vote kicked from the game.")
				end
			end
		else
			rem:FireAllClients({["Yes"] = yes, ["No"] = (resetNo and 0) or no, ["Target"] = target, ["InitPlayer"] = initPlayer, ["Voting"] = false, ["VotePassed"] = false})
		end
		wait(3)
		playerCooldowns[initPlayer] = tick() + conf.PlayerVoteKickCooldown
		serverVoteCooldown = tick() + conf.VoteKickCooldown
		activeVote = false
	end
end

function module.f3xHistoryUpdated(coretab)
	local core = require(coretab["core"])
	local toolname, _, parts = core.historyUnpack(coretab["newfhist"])
	if toolname == "newpart" or toolname == "clone" then
		script.LogCreatedParts:FireServer(parts)
	end
end

function module.escalatedFunction(p)
	return banList
end

return module