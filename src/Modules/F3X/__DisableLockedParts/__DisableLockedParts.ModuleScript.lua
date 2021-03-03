local DisableLockedF3XParts = {}
local config = require(script:WaitForChild("Configuration"))
-- As a note, we *could* set the DisallowedLock option in SyncModule, but that does not prevent players from selecting modules with a
-- locked part.

local function getNonLocked(parts)
	for i, part in pairs(parts) do
		if part:IsA("BasePart") and part.Locked then
			table.remove(parts, i)
		end
		if #part:GetChildren() > 0 then
			for _, desc in pairs(part:GetDescendants()) do
				if desc:IsA("BasePart") and desc.Locked then
					table.remove(parts, i)
					break
				end
			end
		end
	end
	return parts
end

function DisableLockedF3XParts.client(core)
	--core:addFunction("addF3XAttachment", function(moduleName, functionName, typ, func, priority)
	if false and core.getSecurityLevel() < config.RankToBypass then
		core.addF3XAttachment("Selection", "Add", "Before", function(parts, registerhistory)
			return getNonLocked(parts), registerhistory
		end)
	end
end

function DisableLockedF3XParts.server(core)
	core.addF3XAttachment("SyncModule", "PerformAction", "Before", function(Client, ActionName, ...)
		local parts = core.GetSyncModifyingParts(ActionName, ...)
		if parts ~= nil then
			for _, part in pairs(parts) do
				if part.Locked then
					return Client, nil, ...
				end
			end
		end
		return Client, ActionName, ...
	end)
end

DisableLockedF3XParts["Description"] = "Prevents players from selection parts that are locked"

DisableLockedF3XParts["ConfigurationDescription"] = {
	["RankToBypass"] = "What rank will be able to bypass this feature",
	["AllowPlayerSelection"] = "Allow players to select themselves with Shift + K",
}

DisableLockedF3XParts["InitRequirements"] = {
	"addF3XAttachment",
	"attachNewF3X",
	["getSecurityLevel"] = false,
}

return DisableLockedF3XParts
