local module = {}
module.Version = 2 -- Create Composition checks for this, and disables itself when this value exists, as this version of Sets works without it.

local rs = game:GetService("RunService")
local plrs = game:GetService("Players")
local contentProv = game:GetService("ContentProvider")
local uis = game:GetService("UserInputService")
local httpService = game:GetService("HttpService")

local assets = script:WaitForChild("Assets")
local dss = require(assets:WaitForChild("DataStoreSafe"))
local integration = assets:WaitForChild("Integration")
local regNewSet = assets:WaitForChild("RegisterNewSet")
local viewportmodels = assets:WaitForChild("ViewportModels")
local compress = require(assets:WaitForChild("TextCompress"))

local setsFolder = script:WaitForChild("SetsFolder")
local publicSets = setsFolder:WaitForChild("PublicSets")
local privateSets = setsFolder:WaitForChild("PrivateSets")

local configuration = require(script:WaitForChild("Configuration"))
local groupRankReq = configuration.GroupRankToUse

local saveimg = "http://www.roblox.com/asset/?id=5851860479"
local delimg = "http://www.roblox.com/asset/?id=5851860262"
local waitimg = "http://www.roblox.com/asset/?id=5851859944"


local unknownFailureText = "There has been a failure in saving/loading/deleting your data. Please take a screenshot of the error "
unknownFailureText = unknownFailureText .. "(likely orange) in F9, and send it to r_aidmaster or a game developer."
-- i dont want side scrolling lol

-- server globals
dataStore = nil
-- just the datastore
playerSetNameData = {}
-- [PlayerID] = table
playerCooldown = {}
-- [Username] = last time

-- client globals
currentSelection = {}
currentSet = nil
-- name

local function tablefind(tab, comp) -- so this guy named hollowmariofan aka john told me that table.find could return a bad number
	-- and we really really really do not want to lose player saves
	local ind = 0
	for _, v in pairs(tab) do
		ind += 1
		if v == comp then
			return ind
		end
	end
end

local function getAllSets(player) -- gets all the sets. if player is nil, and we are the server, it includes all private sets
	if player == nil and not rs:IsServer() then
		player = plrs.LocalPlayer.Name
	end
	if typeof(player) == "Instance" then
		player = player.Name
	end
	
	local Sets = publicSets:GetChildren()
	for i, v in pairs(Sets) do
		if not v:IsA("Model") then
			table.remove(Sets, i)
		end
	end
	if player then
		local playerPriv = privateSets:FindFirstChild(player)
		if playerPriv ~= nil then
			for i, v in pairs(playerPriv:GetChildren()) do
				if v:IsA("Model") then
					table.insert(Sets, v)
				end
			end
		end
	else
		for i, v in pairs(privateSets:GetChildren()) do
			for _, set in pairs(v:GetChildren()) do
				if set:IsA("Model") then
					table.insert(Sets, set)
				end
			end
		end
	end
	
	return Sets
end

local function enforcePrimaryPart(model) -- makes sure a model is a model and that it has a primary part
	-- also anchors all parts
	if model:IsA("Model") then
		for i, v in pairs(model:GetDescendants()) do
			if v:IsA("BasePart") or v:IsA("UnionOperation") then
				v.Anchored = true
			end
		end
		if model.PrimaryPart == nil then
			model.PrimaryPart = model:FindFirstChildWhichIsA("BasePart", true)
			
			if model.PrimaryPart == nil then
				model:Destroy()
			end
		end
	else
		warn("Removing bad item " .. model:GetFullName())
		model:Destroy()
	end
end

local function makeViewportModel(model)
	if model:IsA("Model") then
		local viewportmodel = model:Clone()
		if model.Parent ~= publicSets then
			viewportmodel.Name = model.Parent.Name .. viewportmodel.Name
		end
		viewportmodel:SetPrimaryPartCFrame(model.PrimaryPart.CFrame - model.PrimaryPart.CFrame.p)
		
		local highestYPos, allVectors, pCount = nil, Vector3.new(0,0,0), 0
		for i, v in pairs(viewportmodel:GetDescendants()) do
			if v:IsA("BasePart") or v:IsA("UnionOperation") then
				if v.Size.X < 1 and v.Size.Y < 1 and v.Size.Z < 1 then
					v:Destroy() -- we don't need super small parts, this is for performance reasons as well
				else
					v.Anchored = true
					if highestYPos == nil or v.Position.Y > highestYPos then
						highestYPos = v.Position.Y
					end
					allVectors += v.Position
					pCount += 1
				end
			end
		end
		if highestYPos == nil then
			highestYPos = 0
		end
		
		local midp = allVectors / pCount
		local val = Instance.new("CFrameValue", viewportmodel)
		val.Value = CFrame.new(Vector3.new(midp.X + (highestYPos / 2), highestYPos + 24, midp.Z), midp)
		val.Name = "ViewportCFrameValue"
		
		viewportmodel.Parent = viewportmodels
	end
end

local function newListener(folder)
	folder.ChildAdded:Connect(function(m)
		enforcePrimaryPart(m)
		makeViewportModel(m)
	end)
end

function module.load(core)
	if core.getPlayerRank() >= groupRankReq then
		local lp = plrs.LocalPlayer
		local m = lp:GetMouse()
		local coretab = core.getCoreTable()
		local masterFrame = script:WaitForChild("Sets"):Clone()
		masterFrame.Parent = coretab["ui"]
		local ui = masterFrame:WaitForChild("Sets")
		local topBar = masterFrame:WaitForChild("TopBar")
		local UIMain = ui:WaitForChild("Main")
		local UIPlacing = ui:WaitForChild("PlacingSet")
		local PlaceCancel = UIPlacing:WaitForChild("TextButton")
		local setlist = UIMain:WaitForChild("List")
		local listasset = UIMain:WaitForChild("ListAsset")
		local searchFrame = UIMain:WaitForChild("Search")
		local searchBox = searchFrame:WaitForChild("TextBox")
		local selectedSet = UIMain:WaitForChild("SelectedText")
		local viewportFrame = UIMain:WaitForChild("ViewportFrame")
		local viewportCamera = Instance.new("Camera")
		viewportFrame.CurrentCamera = viewportCamera
		local selectionCache
		
		local savedNames = core.escalateFunction(script, "getSavedSetNames")
		if savedNames == nil then
			savedNames = {}
			warn("Failed to get saved set names.")
		end
		
		local SpawnSet = UIMain:WaitForChild("SpawnSet")
		local PlaceSet = UIMain:WaitForChild("PlaceSet")
		local saveFrame = UIMain:WaitForChild("SaveFrame")
		local savebutton = saveFrame:WaitForChild("SaveDeleteSet")
		local waitimage = saveFrame:WaitForChild("WaitImage")
		
		local waitScreen = ui:WaitForChild("PerformingDataOperation")
		local throttlescreen = ui:WaitForChild("CooldownWarning")
		local dataError = ui:WaitForChild("DataError")
		
		local nameComposition = ui:WaitForChild("CompositionName")
		local makeComposition = ui:WaitForChild("CompositionHint")
		
		local savePermanantely = ui:WaitForChild("SavePermanently")
		
		local deletePrompt = ui:WaitForChild("DeletePrompt")
		
		local allButtons = {}
		
		contentProv:PreloadAsync({"http://www.roblox.com/asset/?id=5853180566", "http://www.roblox.com/asset/?id=5851860262",
			"http://www.roblox.com/asset/?id=5851860479"
		})
		
		core.makeDraggable(masterFrame)
		core.automaticScrollFrameUpdate(setlist, true)
		
		local function showUI(name, opt)
			UIMain.Visible = (name == "Main")
			UIPlacing.Visible = (name == "Placing")
			waitScreen.Visible = (name == "WaitScreen")
			if (name == "ThrottleScreen") then
				throttlescreen.Visible = true
				wait(5)
				throttlescreen.Visible = false
				showUI(opt)
			end
			nameComposition.Visible = (name == "NameComposition")
			makeComposition.Visible = (name == "MakeComposition")
			deletePrompt.Visible = (name == "DeletePrompt")
			savePermanantely.Visible = (name == "SavePrompt")
			if (name == "DataError") then
				dataError.TextLabel.Text = opt
				dataError.Visible = true
				wait(8)
				dataError.Visible = false
				showUI("Main")
			end
		end
		
		local function open()
			masterFrame.Visible = true
			showUI("Main")
		end
		
		local function openComposition()
			masterFrame.Visible = true
			showUI("MakeComposition")
		end
		
		local function createSetEntry(model)
			local ourasset = listasset:Clone()
			local name = model
			if typeof(model) == "Instance" then
				name = model.Name
			end
			
			ourasset.Name = name
			ourasset.Parent = setlist
			ourasset.Visible = true
			local but = ourasset.TextButton
			but.Text = name
			local isPrivate = ourasset:WaitForChild("IsPrivate")
			local isSaved = ourasset:WaitForChild("IsSaved")
			
			if typeof(model) == "string" or model.Parent.Parent == privateSets then
				isPrivate.Visible = true
				if typeof(model) == "string" or model:FindFirstChild("IsSaved") ~= nil then
					isSaved.Visible = true
				end
			end
			-- create our event to destroy this if it's nil
			if typeof(model) == "Instance" then
				model.Parent.ChildRemoved:Connect(function(inst)
					if inst == model then
						ourasset:Destroy()
					end
					if currentSet == model then
						selectedSet.Text = "None"
						viewportFrame.Visible = false
						SpawnSet.Visible = false
						PlaceSet.Visible = false
						savebutton.Visible = false
					end
				end)
			end
			
			but.MouseButton1Click:Connect(function()
				PlaceSet.Visible = true
				SpawnSet.Visible = true
				selectedSet.Text = name
				currentSet = model
				
				if typeof(model) == "Instance" then
					local vpmodel
					if model.Parent ~= publicSets then
						vpmodel = viewportmodels:FindFirstChild(lp.Name .. name)
					else
						vpmodel = viewportmodels:FindFirstChild(name)
					end
					if vpmodel and vpmodel:FindFirstChild("ViewportCFrameValue") then
						viewportFrame.Visible = true
						viewportCamera.CFrame = vpmodel.ViewportCFrameValue.Value
						local old = viewportFrame:FindFirstChildWhichIsA("Model")
						if old then
							old:Destroy()
						end
						vpmodel:Clone().Parent = viewportFrame
					end
					
					if model.Parent.Parent == privateSets and model:FindFirstChild("ReadOnly") == nil then
						saveFrame.Visible = true
						if model:FindFirstChild("IsSaved") ~= nil then
							savebutton.Image = delimg
						else
							savebutton.Image = saveimg
						end
					else
						saveFrame.Visible = false
					end
				else
					saveFrame.Visible = true
					viewportFrame.Visible = false
					savebutton.Image = delimg
				end
			end)
		end
		
		local sets = getAllSets(lp)
		for i, v in pairs(sets) do
			createSetEntry(v)
		end
		
		for _, v in pairs(savedNames) do
			if setlist:FindFirstChild(v) == nil then
				createSetEntry(v)
			end
		end
		
		local function verifySet()
			if currentSet ~= nil then
				if typeof(currentSet) == "Instance" then
					return currentSet
				elseif typeof(currentSet) == "string" then
					showUI("WaitScreen")
					local succ, model = core.escalateFunction(script, "loadSetData", currentSet)
					if not succ then
						showUI("DataError", model)
					else
						showUI("Main")
						if setlist:FindFirstChild(currentSet) then
							setlist[currentSet]:Destroy()
						end
						currentSet = model
						createSetEntry(model)
						return model
					end
				end
			end
		end
		
		SpawnSet.MouseButton1Click:Connect(function()
			currentSet = verifySet()
			if currentSet ~= nil then
				core.escalateEvent(script, currentSet)
				SpawnSet.Visible = false
				PlaceSet.Visible = false
				wait(2.1)
				SpawnSet.Visible = true
				PlaceSet.Visible = true
			end
		end)
		
		PlaceSet.MouseButton1Click:Connect(function()
			currentSet = verifySet()
			showUI("Placing")
			if currentSet ~= nil then
				local ghost = currentSet:Clone()
				local bottompos
				local offset
				local cf

				for i, v in pairs(ghost:GetDescendants()) do
					if v:IsA("BasePart") or v:IsA("UnionOperation") then
						v.Transparency = 0.5 -- do this for ease of use
						v.Anchored = true
						v.CanCollide = false
						v.CastShadow = false
						if bottompos == nil or bottompos > v.Position.Y then
							bottompos = v.Position.Y - (v.Size.Y / 2)
						end
					end
				end

				local pp = ghost.PrimaryPart
				m.TargetFilter = ghost

				local function moveset()
					cf = pp.CFrame
					cf = cf - cf.p
					local pos = (m.Hit.p + offset)
					cf = cf + pos
					ghost:SetPrimaryPartCFrame(cf)
				end

				while m.Target == nil do -- wait until we are actually over something
					wait()
				end

				local calcpos = m.Hit.p -- get our offset
				pp = ghost.PrimaryPart
				offset = pp.Position.Y - bottompos
				offset = Vector3.new(0, (offset), 0)

				ghost.Parent = workspace

				local modelmove = rs.RenderStepped:Connect(moveset)
				local mconnect
				local gencancel

				local function clean()
					modelmove:Disconnect()
					mconnect:Disconnect()
					gencancel:Disconnect()
					ghost:Destroy()
					UIPlacing.Visible = false
					UIMain.Visible = true
					SpawnSet.Visible = false
					PlaceSet.Visible = false
					wait(2.1)
					SpawnSet.Visible = true
					PlaceSet.Visible = true
				end

				local function mconnectfunc()
					if m.Target ~= nil and (uis:GetLastInputType() == Enum.UserInputType.MouseButton1) then -- second is to make sure this was infact a mouse
						core.escalateEvent(script, currentSet, cf)
						clean()
					end
				end
				mconnect = m.Button1Down:Connect(mconnectfunc)

				local mobile
				if uis.TouchEnabled then -- mobile user stuff here
					local function getworldposfromtouch(vec2, proc)
						if not proc then
							local ur = workspace.CurrentCamera:ViewportPointToRay(vec2.X, vec2.Y)
							local r = Ray.new(ur.Origin, ur.Direction * 350)
							local hitpart, pos = workspace:FindPartOnRay(r)

							if hitpart then
								local cf = CFrame.new(pos + offset)
								core.escalateEvent(script, currentSet, cf)
								mobile:Disconnect()
								clean()
							end
						end
					end
					mobile = uis.TouchTapInWorld:Connect(getworldposfromtouch)
				end

				local function gencancelfunc() -- cancel button clicked
					clean()
				end
				gencancel = PlaceCancel.MouseButton1Click:Connect(gencancelfunc)
			end
		end)
		
		makeComposition.Finish.MouseButton1Click:Connect(function()
			if #currentSelection > 0 then
				selectionCache = {}
				for i, v in pairs(currentSelection) do
					selectionCache[i] = v
				end
				showUI("NameComposition")
			end
		end)
		
		makeComposition.Cancel.MouseButton1Click:Connect(function()
			showUI("Main")
		end)
		
		nameComposition.Finish.MouseButton1Click:Connect(function()
			if #nameComposition.TextBox.Text > 0 and #nameComposition.TextBox.Text <= 35 then
				showUI("WaitScreen")
				local model = core.escalateFunction(script, "CreateComp", nameComposition.TextBox.Text, selectionCache)
				if setlist:FindFirstChild(nameComposition.TextBox.Text) ~= nil then
					setlist[nameComposition.TextBox.Text]:Destroy()
				end
				currentSet = model
				if currentSet == nameComposition.TextBox.Text then
					selectedSet.Text = "None"
					viewportFrame.Visible = false
					SpawnSet.Visible = false
					PlaceSet.Visible = false
					savebutton.Visible = false
				end
				createSetEntry(model)
				showUI("SavePrompt")
			elseif #nameComposition.TextBox.Text > 35 then
				nameComposition.TextBox.Text = "The maximum name size is 35 characters."
			end
		end)
		
		nameComposition.Cancel.MouseButton1Click:Connect(function()
			showUI("Main")
		end)
		
		savePermanantely.Yes.MouseButton1Click:Connect(function()
			showUI("WaitScreen")
			local succ, err = core.escalateFunction(script, "saveSetData", currentSet)
			if not succ then
				showUI("DataError", err)
				setlist[currentSet.Name].IsSaved.Visible = false
			else
				setlist[currentSet.Name].IsSaved.Visible = true
			end
			savebutton.Visible = false
			waitimage.Visible = true
			coroutine.wrap(function()
				wait(12)
				savebutton.Visible = true
				waitimage.Visible = false
			end)()
			showUI("Main")
		end)
		
		savePermanantely.No.MouseButton1Click:Connect(function()
			showUI("Main")
		end)
		
		savebutton.MouseButton1Click:Connect(function()
			if savebutton.Image == saveimg and currentSet ~= nil and typeof(currentSet) == "Instance" then
				showUI("WaitScreen")
				local succ, err = core.escalateFunction(script, "saveSetData", currentSet)
				if not succ then
					showUI("DataError", err)
					setlist[currentSet.Name].IsSaved.Visible = false
				else
					setlist[currentSet.Name].IsSaved.Visible = true
				end
				savebutton.Visible = false
				waitimage.Visible = true
				coroutine.wrap(function()
					wait(12)
					savebutton.Visible = true
					waitimage.Visible = false
				end)()
				showUI("Main")
			elseif savebutton.Image == delimg then
				showUI("DeletePrompt")
			end
		end)
		
		deletePrompt.Yes.MouseButton1Click:Connect(function()
			if string.lower(deletePrompt.TextBox.Text) == "confirm" or string.lower(deletePrompt.TextBox.Text) == '"confirm"' then
				local name = currentSet
				if typeof(currentSet) == "Instance" then
					name = currentSet.Name
				end
				deletePrompt.TextBox.Text = ""
				showUI("WaitScreen")
				core.escalateFunction(script, "deleteSetData", name)
				savebutton.Visible = false
				waitimage.Visible = true
				coroutine.wrap(function()
					wait(6)
					savebutton.Visible = true
					waitimage.Visible = false
				end)()
				if setlist:FindFirstChild(name) ~= nil then
					setlist[name]:Destroy()
				end
				selectedSet.Text = "None"
				viewportFrame.Visible = false
				SpawnSet.Visible = false
				PlaceSet.Visible = false
				saveFrame.Visible = false
				showUI("Main")
			end
		end)
		
		deletePrompt.No.MouseButton1Click:Connect(function()
			showUI("Main")
		end)
		
		topBar.CloseButton.MouseButton1Click:Connect(function()
			masterFrame.Visible = false
		end)
		
		regNewSet.Event:Connect(function(set)
			createSetEntry(set)
		end)
		
		searchBox:GetPropertyChangedSignal("Text"):Connect(function()
			for i, v in pairs(setlist:GetChildren()) do
				if v:IsA("Frame") and string.find(string.lower(v.Name), string.lower(searchBox.Text)) then
					v.Visible = true
				elseif v:IsA("Frame") then
					v.Visible = false
				end
			end
		end)
		
		if core.getPlayerRank() >= groupRankReq then
			core.createUIButton("Sets", open, "aaaaa")
			
			core.createUIButton("Create Composition", openComposition, "aaaab")
		end
	end
end

function module.loadServer(core)
	local coretab = core.getCoreTable()
	local folder = Instance.new("Folder", coretab["assetfold"])
	folder.Name = "SetsPartHolder"
	local sets = getAllSets()
	dataStore = dss:GetDataStore("raidRoleplaySets")
	for i, v in pairs(sets) do
		enforcePrimaryPart(v)
		makeViewportModel(v)
	end
	
	publicSets.ChildAdded:Connect(function(m)
		if m:IsA("Model") then
			enforcePrimaryPart(m)
			makeViewportModel(m)
		else
			m:Destroy()
		end
	end)
	newListener(publicSets)
	for _, v in pairs(privateSets:GetChildren()) do
		newListener(v)
		for _, model in pairs(v:GetChildren()) do
			if model:IsA("Model") then
				local v = Instance.new("BoolValue", model)
				v.Name = "ReadOnly"
			else
				model:Destroy()
			end
		end
	end
	
	privateSets.ChildAdded:Connect(function(v)
		newListener(v)
	end)
	local function init(p)
		if privateSets:FindFirstChild(p.Name) == nil then
			local fold = Instance.new("Folder", privateSets)
			fold.Name = p.Name
		end
		local playerNameData = dataStore:GetAsync(tostring(p.UserId))
		if playerNameData == nil then
			warn("Creating new player name data for " .. p.Name)
			playerNameData = {}
			dataStore:UpdateAsync(tostring(p.UserId), function(oldtab)
				if oldtab == nil then
					return {}
				end
			end)
		end
		playerSetNameData[p.Name] = playerNameData
	end
	plrs.PlayerAdded:Connect(init)
	for _, v in pairs(plrs:GetChildren()) do
		init(v)
	end
end

--[[ Actions:
getSavedSetNames - no arguments
loadSetData - pass name
saveSetData - pass model
deleteSetData - pass name
]]

function module.escalatedFunction(p, action, argument, argument2) -- this is our datastore handler and create composition
	local core = require(game:GetService("ReplicatedStorage").raidRoleplay.Assets.Core)
	local coretab = core.getCoreTable()
	local playerprivfolder = privateSets:WaitForChild(p.Name)
	local tempfold = coretab["assetfold"].SetsPartHolder
	
	if playerCooldown[p.Name] ~= nil and playerCooldown[p.Name] > tick() then
		wait(playerCooldown[p.Name] - tick())
	end
	
	playerCooldown[p.Name] = tick() + 6
	local userid = tostring(p.UserId)
	local serial = require(assets:WaitForChild("Serialization"))
	if action == "CreateComp" then
		if argument == "" then
			argument = "CreatedComposition"
		end
		local newmodel = Instance.new("Model", game:GetService("ReplicatedStorage"))
		newmodel.Name = argument

		for i, v in pairs(argument2) do
			if v ~= nil then
				local newclone = v:Clone()
				for i, v in pairs(newclone:GetChildren()) do -- remove welds, this is the lazy way but good for 99% of cases
					if v:IsA("Weld") or v:IsA("WeldConstraint") or v:IsA("ManualWeld") then
						v:Destroy()
					elseif v:IsA("BasePart") or v:IsA("UnionOperation") then
						v.Anchored = true
					end
				end
				newclone.Parent = newmodel
			end
		end

		if playerprivfolder:FindFirstChild(argument) then
			playerprivfolder[argument]:Destroy()
		end
		if viewportmodels:FindFirstChild(p.Name .. argument) then
			viewportmodels[p.Name .. argument]:Destroy()
		end
		newmodel.Parent = playerprivfolder
		return newmodel
	elseif action == "getSavedSetNames" then
		local timeout = 0
		while playerSetNameData[p.Name] == nil and timeout < 5 do
			wait(1)
			timeout += 1
		end
		return playerSetNameData[p.Name]
	elseif action == "loadSetData" then
		local succ, err = pcall(function()
			local data = dataStore:GetAsync(userid .. argument)
			if typeof(data) == "table" and data["Compressed"] and data["Version"] == 1 then
				data = compress.decompress(data["Data"])
				data = httpService:JSONDecode(data)
			else
				data = httpService:JSONDecode(data)
			end
			local parts = serial.InflateBuildData(data)
			local newmodel = Instance.new("Model")
			for i, v in pairs(parts) do
				v.Parent = newmodel
			end
			newmodel.Name = argument
			newmodel.Parent = playerprivfolder
			local notif = Instance.new("BoolValue", newmodel)
			notif.Name = "IsSaved"
			return newmodel	
		end)
		return succ, err
	elseif action == "saveSetData" then
		local Parts = {}
		if argument.Name == "" then
			argument.Name = " " -- :^)
		end
		if #argument.Name > 35 then -- shouldn't occur, but safety check
			argument.Name = "SavedComposition"
		end
		local hashTable = {}
		for i, v in pairs(argument:GetDescendants()) do
			if hashTable[v] == nil then
				hashTable[v] = true
				table.insert(Parts, v)
			end
		end
		local data = serial.SerializeModel(Parts)
		if string.len(data["Data"]) > 4000000 then
			return false, "The data you attempted to save was too large. Try splitting your build into separate parts."
		end
		local data, code, err = dataStore:SetAsync(userid .. argument.Name, data["Data"])
		if data == nil and code == 1 then
			return false, "The data you attempted to save was too large. Try splitting your build into separate parts."
		elseif data == nil then
			return false, err
		else
			dataStore:UpdateAsync(userid, function(oldtab)
				if table.find(oldtab, argument.Name) == nil then
					table.insert(oldtab, argument.Name)
					playerSetNameData[p.Name] = oldtab
					return oldtab
				else
					playerSetNameData[p.Name] = oldtab
				end
			end)
		end
		local saved = Instance.new("BoolValue", argument)
		saved.Name = "IsSaved"
		return true
	elseif action == "deleteSetData" then
		dataStore:UpdateAsync(userid, function(oldtab)
			local ind = tablefind(oldtab, argument)
			if ind then
				table.remove(oldtab, ind)
				playerSetNameData[userid] = oldtab
				return oldtab
			end
		end)
		if playerprivfolder:FindFirstChild(argument) then
			playerprivfolder[argument]:Destroy()
		end
	end
end

setsCooldown = {}

function module.escalatedEvent(p, model, cf)
	if setsCooldown[p.Name] == nil or setsCooldown[p.Name] < tick() then
		local core = require(game:GetService("ReplicatedStorage").raidRoleplay.Assets.Core)
		if core.getPlayerRank(p) >= groupRankReq and (model.Parent == publicSets or model.Parent == privateSets[p.Name]) then
			local partCount = 0
			if model:IsA("BasePart") or model:IsA("UnionOperation") then
				partCount = 1
			end
			for _, v in pairs(model:GetDescendants()) do
				if v:IsA("BasePart") or v:IsA("UnionOperation") then
					partCount += 1
				end
			end
			core.addLog({["Text"] = p.Name .. " has spawned a set with " .. partCount .. " parts."})
			local newmodel = model:Clone()
			local check = newmodel:FindFirstChild("IsSaved", true)
			if check then
				check:Destroy()
			end
			if cf ~= nil then
				newmodel:SetPrimaryPartCFrame(cf)
			end
			newmodel.Parent = game:GetService("Workspace")
			integration:Fire(p, newmodel)
		end
		setsCooldown[p.Name] = tick() + 2
	end
end

function module.f3xSelectionUpdated(coretab)
	local sel = require(coretab["fselect"])
	currentSelection = sel.Items
end

return module