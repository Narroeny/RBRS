local DisableLockedF3XParts = {}
local config = require(script:WaitForChild("Configuration"))
local players = game:GetService("Players")
-- As a note, we *could* set the DisallowedLock option in SyncModule, but that does not prevent players from selecting modules with a
-- locked part.

local function getNonLocked(parts)
	local pChar = players.LocalPlayer.Character
	for i, part in pairs(parts) do
		if part:IsA("BasePart") and part.Locked and 
			not (part:FindFirstAncestorWhichIsA("Model") == pChar and config.AllowLocalPlayerSelection) then
			table.remove(parts)
			--offset += 1
		elseif #part:GetChildren() > 0 then
			for _, desc in pairs(part:GetDescendants()) do
				if desc:IsA("BasePart") and desc.Locked and 
					not (desc:FindFirstAncestorWhichIsA("Model") == pChar and config.AllowLocalPlayerSelection) then
					table.remove(parts)
					break
				end
			end
		end
	end
	return parts
end

function DisableLockedF3XParts.client(core)
	--core:addFunction("addF3XAttachment", function(moduleName, functionName, typ, func, priority)
	if core.getSecurityLevel() < config.RankToBypass then
		core.addF3XAttachment("Selection", "Add", "Before", function(parts, registerhistory)
			return getNonLocked(parts), registerhistory
		end)
	end
end

function DisableLockedF3XParts.server(core)
	core.addF3XAttachment("SyncModule", "PerformAction", "Before", function(Client, ActionName, ...)
		local clientCharacter = Client.Character
		local parts = core.GetSyncModifyingParts(ActionName, ...)
		if parts ~= nil then
			for _, part in pairs(parts) do
				if part.Locked and not (part:FindFirstAncestorWhichIsA("Model") == clientCharacter and config.AllowLocalPlayerSelection) then
					return Client, nil, ...
				end
			end
		end
		return Client, ActionName, ...
	end)
end

DisableLockedF3XParts["Description"] = "Prevents players from selection parts that are locked"

DisableLockedF3XParts["ConfigurationDescription"] = {
	["RankToBypass"] = "What rank will be able to bypass this feature, giving the locked part selection with Shift + K",
	["AllowLocalPlayerSelection"] = "Allow players to select themselves with Shift + K",
}

DisableLockedF3XParts["InitRequirements"] = {
	"addF3XAttachment",
	"attachNewF3X",
	["getSecurityLevel"] = false,
}

return DisableLockedF3XParts
