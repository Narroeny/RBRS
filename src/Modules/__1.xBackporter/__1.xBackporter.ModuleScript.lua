local raidRoleplayBackporter = {}

function raidRoleplayBackporter.client(Core)
	Core.loadEnv(getfenv())
	local RRCore = require(ReplicatedStorage:WaitForChild("raidRoleplay"):WaitForChild("Assets"):WaitForChild("Core"))
	
	RRCore.lockUIClosed = function()
		Core.lockCoreUI()
	end
	
	RRCore.unlockUIClosed = function()
		Core.unlockCoreUI()
	end
	
	RRCore.escalateEvent = function(Module, ...)
		Core:FireServer("RRBackport", "Event", Module, ...)
	end
	
	RRCore.escalateFunction = function(Module, ...)
		return Core:InvokeServer("RRBackport", "Func", Module, ...)
	end
	
	RRCore.createUIButton = function(Text, Function, ButtonName)
		local LayoutOrder = 0
		for _, Character in pairs(string.split(ButtonName, "")) do
			LayoutOrder += (string.byte(Character))
		end
		LayoutOrder += 100000 -- RR backports go last.
		
		return Core.createCoreButton(Text, Function, LayoutOrder)
	end
	
	RRCore.getPlayerRank = function(Player)
		if Player == nil and not RunService:IsServer() then
			Player = game:GetService("Players").LocalPlayer -- if we're not the server and a player wasn't passed, assume localplayer
		end
		if typeof(Player) == "string" then
			Player = game:GetService("Players"):FindFirstChild(Player)
		end
		return Core.getSecurityLevel(Player)
	end
 
	RRCore.Load(Core:waitForGlobal("UI"))
end

function raidRoleplayBackporter.server(Core)
	Core.loadEnv(getfenv())
	
	local Modules = script:WaitForChild("Modules"):GetChildren()
	
	require(script:WaitForChild("Loader")).Main()
	
	local RRFolder = ReplicatedStorage:WaitForChild("raidRoleplay")
	local RRCore = require(RRFolder:WaitForChild("Assets"):WaitForChild("Core"))
	local RRModules = RRFolder:WaitForChild("Modules")

	RRCore.getPlayerRank = function(Player)
		if Player == nil and not RunService:IsServer() then
			Player = game:GetService("Players").LocalPlayer -- if we're not the server and a player wasn't passed, assume localplayer
		end
		if typeof(Player) == "string" then
			Player = game:GetService("Players"):FindFirstChild(Player)
		end
		return Core.getSecurityLevel(Player)
	end
	
	-- load all LoadServers
	-- for some reason it doesn't load all instantly
	for i, Module in pairs(Modules) do
		if Module:IsA("ModuleScript") then
			coroutine.wrap(function()
				local Mod = require(Module)
				if typeof(Mod) == "table" and Mod.loadServer ~= nil then
					Mod.loadServer(RRCore)
				end
			end)()
		end
	end
	
	Core.createRemoteListener("RRBackport", function(Player, Type, Module, ...)
		if Module.Parent == RRModules then
			local Module = require(Module)
			if Type == "Event" and Module.escalatedEvent then
				Module.escalatedEvent(Player, ...)
			elseif Type == "Func" and Module.escalatedFunction then
				return Module.escalatedFunction(Player, ...)
			end
		end
	end)
end

raidRoleplayBackporter["ClientRequirements"] = {
	"FireServer",
	"InvokeServer",
	"createApplet",
	"lockCoreUI",
	"unlockCoreUI",
	"createCoreButton",
}

raidRoleplayBackporter["ServerRequirements"] = {
	"FireClient",
	"InvokeClient",
}

raidRoleplayBackporter["InitRequirements"] = {
	"getSecurityLevel",
}

return raidRoleplayBackporter
