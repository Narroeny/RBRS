-- This module simply sets network ownership of all parts to the client that made them

--	core:addFunction("addF3XAttachment", function(moduleName, functionName, typ, func, priority)

-- note to self: figure out why we're not attaching properly

local AntiAnchorBomb = {}

function AntiAnchorBomb.server(core)
	core.loadEnv(getfenv())
	local anchoredParts = {}	

	core.addF3XAttachment("SyncModule", "PerformAction", "After", function(p, actionname, parts, ...)
		if actionname == "SyncAnchor" then
			for _, info in pairs(parts) do
				if info.Part and info.Part:FindFirstAncestorWhichIsA("Workspace") and (not info.Part.Anchored) then
					info.Part:SetNetworkOwner(p)
					if anchoredParts[p.Name] == nil then
						anchoredParts[p.Name] = {}
					end
					table.insert(anchoredParts[p.Name], info.Part)
				end
			end
		end
		return p, actionname, parts, ...
	end)
	
	core.addF3XAttachment("SyncModule", "PerformAction", "After", function(clones, p, actionname, ...)
		if actionname == "Clone" then
			for _, part in pairs(clones) do
				if (not part.Anchored) and part:FindFirstAncestorWhichIsA("Workspace") then
					part:SetNetworkOwner(p)
				end
			end
		end
		return clones, p, actionname, ...
	end)
	
	players.PlayerRemoving:Connect(function(p)
		if anchoredParts[p.Name] ~= nil then
			for _, part in pairs(anchoredParts[p.Name]) do
				part.Anchored = true
			end
		end
	end)
end

AntiAnchorBomb.ServerRequirements = {
	"addF3XAttachment"
}

return AntiAnchorBomb