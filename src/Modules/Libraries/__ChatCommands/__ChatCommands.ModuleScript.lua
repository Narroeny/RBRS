-- Implements functions to add chat commands
-- Only has one function - core.addChatCommand("commandName",

local chatCommands = {}
chatCommands.Configuration = require(script:WaitForChild("Configuration"))
chatCommands.Commands = {}

function chatCommands:chatHandler(plr) -- this command parser could be improved
	plr.Chatted:Connect(function(msg)
		if string.find(msg, chatCommands.Configuration.Prefix) == 1 then
			msg = string.gsub(msg, chatCommands.Configuration.Prefix, "", 1)
			local parts = string.split(msg, " ")
			if chatCommands.Commands[parts[1]] then
				local command = chatCommands.Commands[parts[1]]
				local ourLevel = self.Core.getSecurityLevel(plr)
				if ourLevel >= command["PermissionLevel"] then
					if #parts > 1 then
						command["Function"](table.unpack(parts, 2, #parts))
					else
						command["Function"]()
					end
				end
			end
		end
	end)
end

function chatCommands.init(core) -- just wraps the priority table, sets core, and sets up event
	core.wrapPriorityTable(chatCommands.Commands)
	chatCommands.Core = core
	
	core:addFunction("addChatCommand", function(commandName, func, permissionlevel, securityLevel, priority)
		assert(typeof(commandName) == "string")
		assert(typeof(func) == "function")
		chatCommands.Commands[commandName] = {
			["Function"] = func,
			["PermissionLevel"] = permissionlevel or 0,
			["Priority"] = priority,
		}
	end)
end

function chatCommands.client(core)
	core.loadEnv(getfenv())
	chatCommands:chatHandler(LocalPlayer)
end

function chatCommands.server(core) -- same as above but attaches to stuff
	core.loadEnv(getfenv())
	for _, p in pairs(Players:GetPlayers()) do
		chatCommands:chatHandler(p)
	end
	Players.PlayerAdded:Connect(function(p)
		chatCommands:chatHandler(p)
	end)
end

chatCommands["ConfigurationDescription"] = {
	["Prefix"] = "What prefix the chatCommands will use.",
}

chatCommands["Description"] = "This module adds a chat command listener and parser to allow modules to create chat commands."

chatCommands["InitRequirements"] = {
	"wrapReplicatingTable",
	["getSecurityLevel"] = false,
}

return chatCommands
