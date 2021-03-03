-- adds a small convenience function to Server, GetSyncModifyingParts
-- gives you back what parts are being modified

local GetPartsBeingModified = {}
local ChangesFunctions = {"SyncMove", "SyncResize", "SyncRotate", "SyncColor", "SyncSurface", "CreateLights", "CreateDecorations", 
	"SyncDecorate", "CreateMeshes", "SyncMesh", "CreateTextures", "SyncAnchor", "SyncCollision", "SyncMaterial",
} 
-- for functions that use Changes as a format
local FirstArgItems = {"Clone", "SetParent", "SetName", "Remove", "Parts", "Export", "UndoRemove"} 
local WeldFunctions = {"RemoveWelds", "UndoRemovedWelds"}
-- for functions that use the first argument as items

local function getPartsFromInstances(tab)
	local allItems = {}
	
	for _, v in pairs(tab) do
		if v:IsA("BasePart") then
			table.insert(allItems, v)
		end
		if #v:GetChildren() > 0 then
			for _, v in pairs(v:GetDescendants()) do
				if v:IsA("BasePart") then
					table.insert(allItems, v)
				end
			end
		end
	end
	
	return allItems
end

function GetPartsBeingModified.server(core)
	core:addFunction("GetSyncModifyingParts", function(ActionName, ...)
		if ActionName == "CreateGroup" then
			local _, _, items = ...
			return getPartsFromInstances(items)
		elseif ActionName == "Ungroup" then
			local groups = ...
			local trueAllItems = {}
			for _, group in pairs(groups) do
				local allItems = getPartsFromInstances(group)
				for _, v in pairs(allItems) do
					table.insert(trueAllItems, v)
				end
			end
			return trueAllItems
		elseif table.find(WeldFunctions, ActionName) then
			local allItems = {}
			local welds = ...
			for _, weld in pairs(welds) do
				table.insert(allItems, weld.Part0)
				table.insert(allItems, weld.Part1)
			end
			return allItems
		elseif table.find(ChangesFunctions, ActionName) then
			local allItems = {}
			local changes = ...
			for _, v in pairs(changes) do
				if v["Part"] then
					table.insert(allItems, v.Part)
				end
			end
			return allItems
		elseif table.find(FirstArgItems, ActionName) then
			local items = table.pack(...)[1]
			return getPartsFromInstances(items)
		end
	end)
end

GetPartsBeingModified["Description"] = "Adds a small utility function to figure out which parts are being modified on F3X's server code"

return GetPartsBeingModified
