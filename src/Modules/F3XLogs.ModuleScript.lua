local module = {}

local dicttable = {
	["Move Tool"] = "moved",
	["Resize Tool"] = "resized",
	["Rotate Tool"] = "rotated",
	["Paint Tool"] = "painted",
	["Surface Tool"] = "changed the surface settings of",
	["Material Tool"] = "changed the material settings of",
	["Anchor Tool"] = {
		["added"] = "anchored",
		["removed"] = "unanchored",
	},
	["Collision Tool"] = {
		["added"] = "collidable",
		["removed"] = "non-collidable",	
	},
	["Mesh Tool"] = {
		["Mesh Create"] = "added meshes to",
		["Mesh Destroy"] = "removed meshes from",
		["Mesh Edit"] = "changed the mesh settings of",
	},
	["Texture Tool"] = {
		["Texture Create"] = "added a texture/decal to",
		["Texture Destroy"] = "removed a texture/decal from",
		["Texture Edit"] = "changed the texture/decal settings of",
	},
	["Weld Tool"] = {
		["Weld Create"] = "added",
		["Weld Destroy"] = "removed",
	},
	["Lighting Tool"] = {
		["Lighting Create"] = "added lights to",
		["Lighting Destroy"] = "removed lights from",
		["Lighting Edit"] = "changed the lighting properties of",
	},
	["Decorate Tool"] = {
		["Decorate Create"] = "added decorations to",
		["Decorate Destroy"] = "removed decorations from",
		["Decorate Edit"] = "changed the decoration settings of",
	},
	["delete"] = "removed",
	["clone"] = "cloned",
	["newpart"] = "made a new part."
}

function module.f3xHistoryUpdated(coretab)
	--print("wth")
	local newhist = coretab["newfhist"] -- get our new history log,
	local core = require(coretab["core"]) -- acquire the core
	local tool, count, allparts, special = core.historyUnpack(newhist) -- unpack our history log
	--print(tool)
	if tool == nil then
		return
	end
	
	local common -- get the nice formatted text
	if typeof(dicttable[tool]) == "string" then
		common = dicttable[tool]
	else
		common = dicttable[tool][special]
	end
	
	if tool ~= nil and count ~= 0 and tool ~= '' and common ~= nil then
		--print('xd')
		local lp = game:GetService("Players").LocalPlayer
		local log = {}
		local speciallog = {} -- if we want to add a special log, used for the anchor hook
		local t = core.getUTCTime()
		log["Count"] = count
		if tool ~= "newpart" and tool ~= "Weld Tool" then -- if this wasn't the creation of a new part
			log["Text"] = lp.Name .. " has " .. common .. " " .. count .. " parts." -- create the log
		elseif tool == "Weld Tool" then
			log["Text"] = lp.Name .. " has " .. common .. " " .. count .. " welds." -- create the log
		elseif tool == "Collision Tool" then
			log["Text"] = lp.Name .. " has made " .. count .. " objects " .. common .. "."
		else -- if this was a new count, don't include a count (or it shows 0)
			log["Text"] = lp.Name .. " has " .. common
			log["Count"] = nil
		end
		newhist["ToolName"] = tool
		log["F3XHistoryLog"] = newhist
		--[[for i, v in pairs(newhist) do
			print(i, v)
		end]]
		-- code here to unpack the edited parts, reference if a table exists and if so save that table to a special array in the log
		-- dictionary indexes when they are instances are not preserved after replication
		local array = {}
		if newhist["BeforeSize"] ~= nil then -- resize tool
			--print("resize tool")
			for _, v in pairs(newhist.Parts) do
				local entry = {v}
				table.insert(entry, newhist.BeforeSize[v])
				table.insert(entry, newhist.BeforeCFrame[v]) -- create our entry
				table.insert(array, entry) -- add it to the array
			end
			log["F3XUndoInformation"] = array
		elseif newhist["BeforeCFrame"] ~= nil then -- for the move tool and rotate tool
			--print("move tool")
			for i, v in pairs(newhist.BeforeCFrame) do
				table.insert(array, {i, v})
			end
			log["F3XUndoInformation"] = array
		elseif newhist["InitialColor"] ~= nil then -- paint tool[2]
			--print("also paint tool?")
			for i, v in pairs(newhist.InitialColor) do
				local entry = {i}
				table.insert(entry, v)
				table.insert(entry, newhist.InitialUnionColoring[i])
				table.insert(array, entry)
			end
			log["F3XUndoInformation"] = array
		elseif tool == "Surface Tool" then -- surface tool
			--print("surface tool")
			for i, v in pairs(newhist.BeforeSurfaces) do
				table.insert(array, {i, v})
			end
			log["F3XUndoInformation"] = array
		elseif tool == "Mesh Edit" then -- mesh tool
			--print("mesh tool")
			for i, v in pairs(newhist.Before) do
				table.insert(array, {i, v})
			end
			log["F3XUndoInformation"] = array
		elseif tool == "Material Tool" then
			for i, v in pairs(newhist.Before) do -- we don't know what the other elements are named, so we have to iterate through to get all
				local mattable = {}
				for x, z in pairs(v) do
					if x ~= "Part" then
						table.insert(mattable, x)
					end
					table.insert(mattable, z)
				end
				table.insert(array, mattable)
			end
			log["F3XUndoInformation"] = array
		elseif tool == "Anchor Tool" and special == "removed" then
			--print("hello")
			-- first, forge our own move log and apply it
			for i, v in pairs(newhist.Before) do
				if typeof(v) == "Instance" and v:IsA("BasePart") then
					table.insert(array, {v.Part, v.Part.CFrame})
				elseif typeof(v) == "table" and v["Part"] and v["Part"]:IsA("BasePart") then
					table.insert(array, {v.Part, v.Part.CFrame})
				end
			end
			speciallog = {}
			speciallog["Text"] = "Due to the previous unanchor, " .. count .. " parts were moved."
			speciallog["Count"] = count
			speciallog["F3XUndoInformation"] = array
			speciallog["F3XHistoryLog"] = { -- forge a fake history log so that historyUnpack assumes that this is an actual thing
				AfterCFrame = {},
				Selection = allparts,
				Apply = {},
				Unapply = {},
				BeforeCFrame = array,
				Parts = allparts,
				ToolName = "Move Tool",
			}		
		end
		
		-- COMPATIBILITY PATCH WITH PART SELECTION LIMIT HERE:
		-- Makes it so that this doesn't add a log if the part is going to be removed anyways aka part count is 0
		local modules = coretab["modules"]
		if modules:FindFirstChild("F3XPartSelectionLimit") ~= nil then
			local mod = require(modules.F3XPartSelectionLimit)
			local prank = core.getPlayerRank()
			if mod.getMaxParts ~= nil then
				local maxparts = mod.getMaxParts(prank)
				if maxparts ~= 0 or count > 1 then -- if we should add the log aka max parts is not 0,
					-- or if the count is > 1 (adding a new part makes some move history logs so we just ignore 1 part moves)
					-- (from those players)
					core.addLog(log) -- finally, add the log
					if speciallog ~= nil then
						core.addLog(speciallog)
					end
				end
			else -- if for some reason the max parts doesn't exist, just add the log out of safety
				core.addLog(log) -- finally, add the log
				if speciallog ~= nil then
					core.addLog(speciallog)
				end
			end
		else -- if we don't have the part selection limit, just add the log
			core.addLog(log) -- finally, add the log
			if speciallog ~= nil then
				core.addLog(speciallog)
			end
		end
		
	end
end


return module
