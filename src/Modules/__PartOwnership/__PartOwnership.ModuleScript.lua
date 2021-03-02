local module = {}
local players = game:GetService("Players")

function module.ownModel(p, model) -- this is for sets integration
	local parttable = {}
	for i, v in pairs(model:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("UnionOperation") then
			local newval = Instance.new("StringValue", v)
			newval.Name = "RRPartOwner"
			newval.Value = p.Name
			table.insert(parttable, v)
		end
	end
	script.updateTable:Fire(p.Name, parttable)
end

function module.loadServer(core) -- This keeps track of a dict with an entry for each player and every part they have taken ownership of.
	local ev = script:WaitForChild("updateTable")
	local ev2 = script:WaitForChild("cleanPlayerTable")
	local coretab = core.getCoreTable()
	local conf = require(script:WaitForChild("Configuration"))
	local playerLeaveTimes = {}
	
	game:GetService("Players").PlayerRemoving:Connect(function(p)
		playerLeaveTimes[p.Name] = os.time()
	end)
	
	script:WaitForChild("getPlayerLeaveTimes").OnServerInvoke = function()
		return playerLeaveTimes
	end
	
	ev2.OnInvoke = function(p, toremove) -- p is a string
		local prank = core.getPlayerRank(p)
		for i, v in pairs(toremove) do
			--print(v)
			if v:FindFirstChild("RRPartOwner") ~= nil and (v.RRPartOwner.Value == p or prank >= conf.RankToBypass) then
				v.RRPartOwner:Destroy()
			end
		end
	end
	
	local sets = coretab["modules"]:FindFirstChild("Sets")
	if sets ~= nil then -- if the sets module is infact existing, wait for its event and set up a listener
		local integration = sets:WaitForChild("Assets"):WaitForChild("Integration")
		integration.Event:Connect(module.ownModel)
	end
	
	local folder = Instance.new("Folder", coretab["assetfold"])
	folder.Name = "PlayerTrustValues"
	local function gennewfolder(p)
		local newfold = folder:FindFirstChild(p.Name)
		if newfold == nil then 
			newfold = Instance.new("Folder", folder)
			newfold.Name = p.Name
		end
		for i, v in pairs(game:GetService("Players"):GetChildren()) do
			if v.Name ~= p.Name then
				local newval = Instance.new("BoolValue", newfold)
				newval.Name = v.Name
				newval.Value = false
			end
		end
		game:GetService("Players").PlayerAdded:Connect(function(newp)
			local val = newfold:FindFirstChild(newp.Name)
			if val == nil then
				val = Instance.new("BoolValue", newfold)
				val.Name = newp.Name
				val.Value = false
			end
		end)
	end

	for i, v in pairs(game:GetService("Players"):GetChildren()) do -- this is for test studio
		gennewfolder(v)
	end
	
	game:GetService("Players").PlayerAdded:Connect(gennewfolder) -- set up event to make serverside bools
	
	local trustev = script:WaitForChild("TrustEvent")
	trustev.OnServerEvent:Connect(function(p, opname, val)
		print('test')
		coretab["assetfold"].PlayerTrustValues[p.Name][opname].Value = val
	end)
end

function module.escalatedEvent(player, allparts)
	-- first, make sure there are no ownership values stored, and then add a new one
	for i, v in pairs(allparts) do
		if v:FindFirstChild("RRPartOwner") then
			v.RRPartOwner:Destroy()
		end
		local stringval = Instance.new("StringValue", v)
		stringval.Name = "RRPartOwner"
		stringval.Value = player.Name
	end
end

function module.escalatedFunction(player, toremove)
	script:WaitForChild("cleanPlayerTable"):Invoke(player.Name, toremove)
end

-- Parts should be owned when: Cloned, New Part, New Set
function module.f3xHistoryUpdated(coretab)
	local core = require(coretab["core"])
	local toolname, _, allparts = core.historyUnpack(coretab["newfhist"])
	local conf = require(script:WaitForChild("Configuration"))
	local hist = require(coretab["fhist"])
	if toolname == "clone" or toolname == "newpart" then
		core.escalateEvent(script, allparts)
	end
	local function amtrusted(v)
		local pval = coretab["assetfold"].PlayerTrustValues:FindFirstChild(v.Value)
		if pval ~= nil then
			pval = pval:FindFirstChild(game:GetService("Players").LocalPlayer.Name)
			if pval ~= nil then
				if not pval.Value then -- if we are not trusted
					return false
				else
					return true
				end
			else
				return false
			end
		else -- rather safe than sorry
			return false
		end
	end
	
	local prank = core.getPlayerRank()
	local playerLeaveTimes = script.getPlayerLeaveTimesTable:Invoke()
	if allparts ~= nil and not (prank >= conf.RankToBypass) then
		for i, v in pairs(allparts) do 
			local v = v:FindFirstChild("RRPartOwner")
			if v ~= nil and v:IsA("StringValue") and v.Value ~= game:GetService("Players").LocalPlayer.Name and 
				(game:GetService("Players"):FindFirstChild(v.Value) ~= nil or 
					(playerLeaveTimes[v.Value] == nil or playerLeaveTimes[v.Value] > (os.time() - conf.PlayerLeaveTimeout))
				) and not amtrusted(v) then
				hist.Undo()
				coretab["f3x"].Parent = nil
				core.addLog({["Text"] = game:GetService("Players").LocalPlayer.Name .. " tried to bypass part ownership."})
				break
			end
		end
	end
end

function module.f3xFirstEquipped(coretab) -- this is responsible for setting up the deselect when owned parts are selected
	-- just to note, i was rushing this section out pre raid for a warclan, i very much need to rewrite this section in particular if not this
	-- entire module
	local conf = require(script:WaitForChild("Configuration"))
	local core = require(coretab["core"])
	local rank = core.getPlayerRank()
	
	local function amtrusted(v)
		local pval = coretab["assetfold"].PlayerTrustValues:FindFirstChild(v.Value)
		if pval ~= nil then
			pval = pval:FindFirstChild(game:GetService("Players").LocalPlayer.Name)
			if pval ~= nil then
				if not pval.Value then -- if we are not trusted
					return false
				else
					return true
				end
			else
				return false
			end
		else -- rather safe than sorry
			return false
		end
	end
	if rank < conf.RankToBypass then -- if this rank is lower than required to ignore
		-- this
		local selectionmod = require(coretab["fselect"])
		selectionmod.Changed:Connect(function()
			local playerLeaveTimes = script.getPlayerLeaveTimesTable:Invoke()
			local partstoremove = {}
			local lpName = players.LocalPlayer.Name
			local function checkIfRemove(partownval, part)
				if partownval.Value ~= lpName and (not amtrusted(partownval)) and 
					(players:FindFirstChild(partownval.Value) ~= nil or playerLeaveTimes[partownval.Value] == nil 
							or playerLeaveTimes[partownval.Value] > (os.time() - conf.PlayerLeaveTimeout)) then
					table.insert(partstoremove, part)
				end
			end
			for i, v in pairs(selectionmod.Items) do -- pretty sure this is redundant but i'm leaving it for now
				for _, desc in pairs(v:GetDescendants()) do
					if desc.Name == "RRPartOwner" then
						checkIfRemove(desc, v)
					end
				end
			end
			if #partstoremove > 0 then
				selectionmod.Remove(partstoremove)
			end
		end)
	end
end

function module.load(core) -- creates the clear ownership button
	local coretab = core.getCoreTable()
	local conf = require(script:WaitForChild("Configuration"))
	local playerLeaveTimes = {}
	playerLeaveTimes = script:WaitForChild("getPlayerLeaveTimes"):InvokeServer()
	
	game:GetService("Players").PlayerRemoving:Connect(function(p)
		playerLeaveTimes[p.Name] = os.time()
	end)
	
	script:WaitForChild("getPlayerLeaveTimesTable").OnInvoke = function()
		return playerLeaveTimes
	end
	
	local function clearownership()
		core.lockUIClosed(false)
		local tool = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool")
		if tool ~= nil and tool:FindFirstChild("SyncAPI") ~= nil and tool:FindFirstChild("Core") ~= nil then -- check if this is f3x
			local selectmod = require(tool.Core.Selection)
			local tab = selectmod.Parts
			core.escalateFunction(script, tab)
		end
		core.unlockUIClosed()
	end
	
	core.createUIButton("Clear Ownership From Selection", clearownership, "ffggg")	
	
	-- Copy the mouse UI over and start tracking it on the mouse
	local ui = script:WaitForChild("OwnerUI"):Clone()
	local m = game:GetService("Players").LocalPlayer:GetMouse()
	ui.Parent = coretab["ui"]
	
	local rs = game:GetService("RunService")
	
	local trustmain = script:WaitForChild("TrustMenu"):Clone()
	core.makeDraggable(trustmain)
	local trustmenu = trustmain:WaitForChild("TrustMenu")
	trustmain.Parent = coretab["ui"]
	
	local notif = trustmenu:WaitForChild("__noPlayers"):Clone()
	notif.Parent = trustmenu.Frame
	notif.Visible = true
	
	local function open()
		trustmain.Visible = true
	end
	
	trustmain.TopBar.CloseButton.MouseButton1Click:Connect(function()
		trustmain.Visible = false
	end)
	
	core.createUIButton("Trust Menu", open, "fffgg")
	
	local trustev = script:WaitForChild("TrustEvent")
	local uiasset = trustmenu:WaitForChild("Asset")
	
	local function newbutton(v)
		local prank = core.getPlayerRank(v)
		if prank < conf.RankToBypass then -- no need to show admins
			if trustmenu.Frame:FindFirstChild("__noPlayers") ~= nil then
				trustmenu.Frame["__noPlayers"]:Destroy()
			end
			local a = uiasset:Clone()
			a.Name = v.Name
			a:WaitForChild("TextLabel").Text = v.Name
			a.Parent = trustmenu.Frame
			a.Visible = true
			local val = coretab["assetfold"].PlayerTrustValues[game:GetService("Players").LocalPlayer.Name]:WaitForChild(v.Name) -- incase if the player is rejoining
			local toggle = core.createToggle(a.Indicator)
			toggle.MouseButton1Click:Connect(function()
				trustev:FireServer(v.Name, toggle.Status)
			end)
			trustmenu.Frame.CanvasSize = trustmenu.Frame.CanvasSize + UDim2.new(0, 0, 0, 70)
		end
	end
	-- init buttons
	for i, v in pairs(game:GetService("Players"):GetChildren()) do -- load players already ingame
		if v.Name ~= game:GetService("Players").LocalPlayer.Name then
			newbutton(v)
		end
	end
	
	-- listen for new players
	game:GetService("Players").PlayerAdded:Connect(function(p)
		newbutton(p)
	end)
	
	game:GetService("Players").PlayerRemoving:Connect(function(p)
		if trustmenu.Frame:FindFirstChild(p.Name) ~= nil then
			trustmenu.Frame[p.Name]:Destroy()
			trustmenu.Frame.CanvasSize = trustmenu.Frame.CanvasSize - UDim2.new(0, 0, 0, 70)
			if #(trustmenu.Frame:GetChildren()) == 1 then
				local notif = trustmenu["__noPlayers"]:Clone()
				notif.Parent = trustmenu.Frame
				notif.Visible = true
			end
		end
	end)
	
	-- Set up the cycle here
	while true do -- gloryy!!!!
		wait(1/60)
		if m.Target ~= nil and m.Target:FindFirstChild("RRPartOwner") ~= nil and m.Target.RRPartOwner.Value ~= game:GetService("Players").LocalPlayer.Name then
			ui.Visible = true
			ui.Text = m.Target.RRPartOwner.Value .. "'s part"
			ui.Position = UDim2.new(0, m.X - 20, 0, m.Y - 40)
		else
			ui.Visible = false
		end
	end
end

return module
