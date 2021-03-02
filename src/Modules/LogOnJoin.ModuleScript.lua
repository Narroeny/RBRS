-- This module is very simple - it simply submits a log whenever a player joins or leaves the game.

local module = {}

function module.loadServer(core)
	-- Include a first join message, since it takes a moment before the PlayerAdded is registered
	local p = game:GetService("Players"):FindFirstChildOfClass("Player")
	if p ~= nil then -- sometimes this loads before the player apparently
		core.addLog({["Text"] = p.Name .. " has started the game server."})
	end
	
	game:GetService("Players").PlayerAdded:Connect(function(p)
		core.addLog({["Text"] = p.Name .. " has joined the server."})
	end)
	
	game:GetService("Players").PlayerRemoving:Connect(function(p)
		core.addLog({["Text"] = p.Name .. " has left the server."})
	end)
end

return module
