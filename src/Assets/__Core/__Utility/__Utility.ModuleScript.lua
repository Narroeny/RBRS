-- NOTE: Utility should have no requirements.
--[[
Utility implements functions required by Core and generic functions required by other modules.
]]
local Utility = {}
Utility["Description"] = "Provides utility functions for the sake of all modules."
local runService = game:GetService("RunService")
local players = game:GetService("Players")

local function getEnvironmentData(mainenv, name) -- actual code for both getCallingScript and getCallingEnv
	local returnEnv = {}
	local returnCallingScript = "FAILED TO GET CALLING SCRIPT"
	local currentLevel = 2
	local succ, err = pcall(function()
		for i = 2, 20 do
			currentLevel = 2
			local env = mainenv.getfenv(i)
			if env.script ~= mainenv.script and env.script ~= script and env.script:IsA("ModuleScript") then
				returnEnv = env
				returnCallingScript = env.script:GetFullName()
				break
			end
		end
	end)
	if not succ then
		warn(err)
		error(currentLevel .. " - FAILED TO GET ENV CALLING SCRIPT - " .. name)
	end
	return returnEnv, returnCallingScript
end

function Utility.init(core)	
	core:addFunction("getCallingEnv", function(env)
		local _, callerName = getEnvironmentData(getfenv(), "Utility.getCallingEnv")
		assert(typeof(env) == "table", "Invalid environment passed from" .. callerName)
		
		local retenv, _ = getEnvironmentData(env, callerName)
		return retenv
	end, 1, script:GetFullName())
	
	core:addFunction("getCallingScript", function(env)
		local _, callerName = getEnvironmentData(getfenv(), "Utility.getCallingScript")
		assert(typeof(env) == "table", "Invalid environment passed from" .. callerName)
		
		local _, name = getEnvironmentData(env, callerName)
		return name
	end, 1, script:GetFullName())
	
	core:addFunction("loadEnv", function(env)
		local _, callerName = getEnvironmentData(getfenv(), "Utility.getCallingEnv")
		assert(typeof(env) == "table", "Invalid environment passed from" .. callerName)
		
		for i, v in pairs({
			chat = game:GetService("Chat"),
			contentProvider = game:GetService("ContentProvider"),
			debris = game:GetService("Debris"),
			groupService = game:GetService("GroupService"),
			lighting = game:GetService("Lighting"),
			players = game:GetService("Players"),
			replicatedStorage = game:GetService("ReplicatedStorage"),
			runService = game:GetService("RunService"),
			starterPack = game:GetService("StarterPack"),
			starterPlayer = game:GetService("StarterPlayer"),
			teams = game:GetService("Teams"),
			tweenService = game:GetService("TweenService"),
			httpService = game:GetService("HttpService"),
			}) do
			env[i] = v
		end
		if runService:IsServer() then
			for i, v in pairs({
				dataStoreService = game:GetService("DataStoreService"),
				serverStorage = game:GetService("ServerStorage"),
				}) do
			env[i] = v
			end
		else
			local localPlayer = players.LocalPlayer
			for i, v in pairs({
				localPlayer = localPlayer,
				backpack = localPlayer:WaitForChild("Backpack"),
				character = localPlayer.Character or localPlayer.CharacterAdded:Wait(),
				contextActionService = game:GetService("ContextActionService"),
				playerGui = localPlayer:WaitForChild("PlayerGui"),
				}) do
				env[i] = v
			end
		end
	end)
	
	core:addFunction("getClientScript", function(plr)
		if plr == nil and not runService:IsServer() then
			plr = players.LocalPlayer
		else
			return nil
		end
		
		local character = plr.Character or plr.CharacterAdded:Wait()
		return character:WaitForChild("RBRSClient")
	end)
end

return Utility
