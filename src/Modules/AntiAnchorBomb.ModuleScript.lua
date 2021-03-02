local module = {}

anchorOwnerTable = {}
partHashTable = {}

local function isWeldedToAnchored(part)
	for i, v in pairs(part:GetDescendants()) do
		if v:IsA("Weld") or v:IsA("WeldConstraint") or v:IsA("ManualWeld") then
			if (v.Part0 ~= nil and v.Part0.Anchored) or (v.Part1 ~= nil and v.Part1.Anchored) then
				return false
			end
		end
	end
	return true
end

local function getWeldedParts(part)
	local weldedto = {}
	for i, v in pairs(part:GetDescendants()) do
		if v:IsA("Weld") or v:IsA("WeldConstraint") or v:IsA("ManualWeld") then
			if v.Part0 ~= nil then
				table.insert(weldedto, v.Part0)
			elseif v.Part1 ~= nil then
				table.insert(weldedto, v.Part1)
			end
		end
	end
	return weldedto
end

local function getApplicable(allparts)
	local Applicable = {}
	local weldcheckHash = {} -- hash table for making sure parts aren't welded
	for i, v in ipairs(allparts) do 
		if not v.Anchored then -- if we are not anchored, check to make sure that we are not welded to an anchored part
			--print("notanchored")
			local applicable = isWeldedToAnchored(v)
			--print(applicable)
			if applicable then
				--print("adding to weldcheckhash")
				weldcheckHash[v] = i
			end
		else -- if we are anchored, make sure we remove any parts that are welded from our hash table
			--print("anchored")
			local weldedto = getWeldedParts(v)
			for _, v in ipairs(weldedto) do
				if weldcheckHash[v] ~= nil then
					--print("removing from weldcheckhash")
					weldcheckHash[v] = nil
				end
			end
		end
	end
	for i, v in pairs(weldcheckHash) do -- return it to a hash table
		if v ~= nil then -- extra check
			table.insert(Applicable, {i, v})
		end
	end
	
	return Applicable
end

function module.f3xHistoryUpdated(coretab)
	-- okay, so minor problem is that f3x will update the history before it actually finishes unanchoring
	-- to get around this we fire this in batches until we time out or we anchor everything
	local newhist = coretab["newfhist"] -- get our new history log,
	local core = require(coretab["core"]) -- acquire the core
	local tool, count, allparts, special = core.historyUnpack(newhist) -- unpack our history log
	if tool == "Anchor Tool" then
		coroutine.wrap(function()
			for i = 1, 15 do -- 15 cycles of checking, aka 3 seconds
				--print(#allparts)
				local applicable = getApplicable(allparts)
				--print(#applicable)
				local parttable = {}
				local removeIndexes = {}
				for i, v in ipairs(applicable) do
					table.insert(parttable, v[1])
					removeIndexes[tostring(i)] = v[2]
				end
				
				local newallparts = {} -- make a new table
				for ind, v in ipairs(newallparts) do
					if removeIndexes[tostring(i)] == nil then
						--print("part still needed to be added")
						table.insert(newallparts, v)
					else
						--print("removing part")
					end
				end
				-- clone the new table over
				allparts = {}
				for i, v in ipairs(newallparts) do
					table.insert(allparts, v)
				end
				--print(#allparts)
					
				core.escalateEvent(script, parttable, "SetOwner")
				if #allparts <= 0 then -- if we've finished on all parts, return back
					break
				end
				wait(0.2)
			end
			if #allparts > 0 then
				core.escalateEvent(script, allparts, "Failsafe") -- delete / clone the remaining parts since they probably just anchored too much
			end
		end)()
	elseif tool == "clone" then
		core.escalateEvent(script, allparts, "Anchor")
	end
end

function module.escalatedEvent(p, parts, action)
	--print("setting network owner")
	local core = require(game:GetService("ReplicatedStorage").raidRoleplay.Assets.Core)
	if action == "SetOwner" then
		--print("test")
		--print(#parts)
		for i, v in pairs(parts) do
			--print(v)
			if (not partHashTable[v] or partHashTable[v] ~= p) and v:IsA("BasePart") or v:IsA("UnionOperation") then
				v:SetNetworkOwner(p)
				--print("sup")
				--print("setting network owner")
				partHashTable[v] = p
				if anchorOwnerTable[p] == nil then
					anchorOwnerTable[p] = {}
				end
				table.insert(anchorOwnerTable[p], v)
			end
		end
	elseif action == "Failsafe" then
		core.addLog({["Text"] = "Player " .. p.Name .. " has anchored so many parts that the operation took over 3 seconds, or some other sort of conflict occured."})
		for i, v in pairs(parts) do
			local clone = v:Clone()
			clone.Anchored = true
			clone.Parent = game:GetService("Workspace")
			v:Destroy()
		end
	elseif action == "Anchor" then
		for i, v in pairs(parts) do
			--print("hi")
			v.Anchored = true
		end
	else
		warn("Invalid action " .. action .. " called inside of AntiAnchorBomb.")
	end
end

function module.loadServer(core)
	game:GetService("Players").PlayerRemoving:Connect(function(p)
		if anchorOwnerTable[p] then
			--print("purging their records")
			for i, v in pairs(anchorOwnerTable[p]) do
				v.Anchored = true
			end
			anchorOwnerTable[p] = nil
		end
	end)
end

return module
