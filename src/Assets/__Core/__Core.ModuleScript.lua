local Core = {}
Core.Version = "2.0.0.indev"

local runService = game:GetService("RunService")

Core.ProtectedFunctions = {}
Core.Functions = {}
Core.References = {}
Core.LoadedModules = {}

Core.script = script
Core.Environment = script:FindFirstAncestor("RBRS"):WaitForChild("Environment")
Core.env = Core.Environment -- add an alias
Core.Loaded = Instance.new("BoolValue")
Core.Loaded.Value = false

-- used for loaded value
local allModules = {}
local loadedModules = {}

setmetatable(Core, Core)

Core.__index = function(self, ind)
	if Core.ProtectedFunctions[ind] ~= nil then
		return Core.ProtectedFunctions[ind]
	elseif Core.Functions[ind] ~= nil then
		return Core.Functions[ind]["Function"]
	else
		warn(ind)
		pcall(function()
			rawget(Core.ProtectedFunctions, "getCallingScript")
			error(Core.getCallingScript(getfenv()).. " attempted to call a value of Core that doesn't exist. (" .. ind .. ")")
		end)
	end
end

function Core.ProtectedFunctions:waitForRequirements(reqs, module)
	if typeof(reqs) ~= "table" then
		reqs = {reqs}
	end
	for ind, val in pairs(reqs) do
		local isHardRequirement = true
		local funcName = val
		if tonumber(ind) == nil then
			isHardRequirement = val
			funcName = ind
		end
		if funcName ~= "Loaded" then
			coroutine.wrap(function()
				wait(5)
				if self.Functions[funcName] == nil then
					if not isHardRequirement then
						self:addFunction(funcName, function(...) return 0 end, -1000, "STUB FUNCTION")
						warn("Failed to get " .. funcName .. ". Adding stub function. - " .. module:GetFullName())
					else
						warn("Failing to get " .. funcName ..  ". Continuing to yield. - " .. module:GetFullName())
					end
				end
			end)()
			while self.Functions[funcName] == nil do
				self.Functions.Changed:Wait()
			end
		else
			coroutine.wrap(function()
				wait(5)
				if not self.Loaded.Value then
					warn("Loading is not finished, something may be going wrong... - " .. module:GetFullName() .. " - " .. #allModules
						.. " - " .. #loadedModules
					)
				end
			end)()
			if not table.find(loadedModules, module) then
				table.insert(loadedModules, module)
			end
			if #allModules == #loadedModules then
				self.Loaded.Value = true
			end
			if not self.Loaded.Value then
				self.Loaded.Changed:Wait()
			end
		end
	end
end

function Core.ProtectedFunctions:getGlobal(name)
	assert(typeof(name) ~= "table", "Please call getGlobal with : - " .. self.getCallingScript(getfenv()))
	if self.References[name] == nil then
		warn("Invalid global " .. name .. " requested by " .. self.getCallingScript(getfenv()))
		return nil, 0
	else
		return self.References[name]["Value"], self.References[name]["Priority"]
	end
end

function Core.ProtectedFunctions:waitForGlobal(name)
	assert(typeof(name) ~= "table", "Please call waitForGlobal with : - " .. self.getCallingScript(getfenv()))
	coroutine.wrap(function()
		wait(5)
		if self.References[name] == nil then
			warn("waitForGlobal call for " .. name .. " by " .. self.getCallingScript(getfenv()) .. " is still yielding.")
		end
	end)()
	while self.References[name] == nil do
		self.References.Changed:Wait()
	end
	return self.References[name]["Value"], self.References[name]["Priority"]
end

function Core.ProtectedFunctions:setGlobal(name, value, priority)
	assert(typeof(name) ~= "table", "Please call setGlobal with : - " .. self.getCallingScript(getfenv()))
	if priority == true then
		if self.References[name] ~= nil and self.References[name]["Priority"] ~= nil then
			priority = self.References[name]["Priority"]
		else
			priority = 1
		end
	end
	
	assert(typeof(name) == "string", "Global name was not valid from " .. self.getCallingScript(getfenv()))
	assert(typeof(priority) == "number" or priority == nil, "Invalid priority from " .. self.getCallingScript(getfenv()) .. " for " .. name)
	
	self.References[name] = { -- this is also wrapped into a PriorityTable
		["Priority"] = priority,
		["Value"] = value,
	}
end

local function sget(mod, name)
	local ret = nil
	local succ, err = pcall(function()
		ret = rawget(mod, name)
	end)
	return ret
end

function Core.ProtectedFunctions:initMod(Module)
	if Module:IsA("ModuleScript") then
		local mod = require(Module)
		-- but if rawget [ind] doesn't exist then it errors so pcall spam
		-- also the requirement calls shouldn't error but we check just incase
		local init = sget(mod, "init")
		local server = sget(mod, "server")
		local client = sget(mod, "client")
		
		if init or server or client then
			if self.LoadedModules[Module.Name] then
				warn("Replacing an entry " .. Module.Name .. " because another module has the same name.")
			end
			self.LoadedModules[Module.Name] = mod
			if sget(mod, "InitRequirements") then  -- we have to pcall all of these because metamethods may call metamethod spam
				self:waitForRequirements(mod.InitRequirements, Module)
			end
			if init then
				init(self)
			end
			-- now we call server/client specific
			if runService:IsServer() and server then
				if sget(mod, "ServerRequirements") then
					self:waitForRequirements(mod.ServerRequirements, Module)
				end
				server(self)
			elseif (not runService:IsServer()) and client then
				if sget(mod, "ClientRequirements") then
					self:waitForRequirements(mod.ClientRequirements, Module)
				end
				client(self)
			end
		end
		if not table.find(loadedModules, Module) then
			table.insert(loadedModules, Module)
		end
		if #allModules == #loadedModules then
			self.Loaded.Value = true
		end
	end
end

function Core.ProtectedFunctions:init(moduleFolder)
	-- Wait for the game to be loaded
	if runService:IsClient() then
		if not game:IsLoaded() then
			game.Loaded:Wait()
		end
	end
	
	print("Initializing RBRS " .. Core.Version)
	
	-- Core has a requirement for Utility, so we init that first.
	local priorityTable = script:WaitForChild("PriorityTable")
	local utility = script:WaitForChild("Utility")
	self.Functions = {}
	self.References = {}
	self.LoadedModules = {}
	
	self:initMod(priorityTable)
	self.wrapPriorityTable(self.Functions)
	self.wrapPriorityTable(self.References)
	self:initMod(utility)
	
	if runService:IsClient() then
		Core.ClientEnvironment = self.getClientScript()
		Core.clientenv = self.ClientEnvironment
	end
	
	local modules = moduleFolder:GetDescendants()
	
	-- Make our AllModules table
	for _, mod in pairs(moduleFolder:GetDescendants()) do
		if mod:IsA("ModuleScript") then
			table.insert(allModules, mod)
		end
	end
	
	-- Run all of our modules
	for _, mod in pairs(moduleFolder:GetDescendants()) do
		if runService:IsStudio() then
			spawn(function()
				self:initMod(mod)
			end)
		else -- We do this because coroutine messes up output errors, and so we use spawn in studio
			coroutine.wrap(function()
				self:initMod(mod)
			end)()
		end
	end
end

function Core.ProtectedFunctions:addFunction(functionName, func, priority, srcScript) -- Ensures that add Function is called properly, 
	-- and then determines which function should take priority.
	if srcScript == nil then
		--assert(typeof(functionName) ~= "table", "Please call addFunction with : - " .. self.getCallingScript(getfenv()))
		srcScript = "FAILED TO GET FUNCTION SOURCE"
		pcall(function()
			srcScript = getfenv(func).script:GetFullName()
		end)
	end
	assert(typeof(functionName) == "string", srcScript .. " provided an invalid function name.")
	assert(typeof(priority) == "number" or priority == nil, srcScript .. " provided an invalid priority.")	
	assert(typeof(func) == "function", srcScript .. " provided an invalid function.")	
	
	self.Functions[functionName] = {
		["Priority"] = priority,
		["Function"] = func,
		["srcScript"] = srcScript,
	} -- The Functions table is wrapped by the PriorityTable module
end

function Core.ProtectedFunctions:runFunctionWhenAvailable(name, ...)
	assert(typeof(name) ~= "table", "Please call runFunctionWhenAvailable with : - " .. self.getCallingScript(getfenv()))
	while self.Functions[name] == nil do
		self.Functions.Changed:Wait()
	end
	return self.Functions[name](...)
end

return Core
