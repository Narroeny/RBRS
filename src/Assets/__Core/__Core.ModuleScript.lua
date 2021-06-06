local Core = {}
Core.Version = "2.0.0.indev"

local RunService = game:GetService("RunService")

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
local AllModules = {}
local LoadedModules = {}

setmetatable(Core, Core)

Core.__index = function(self, Index)
	if Core.ProtectedFunctions[Index] ~= nil then
		return Core.ProtectedFunctions[Index]
	elseif Core.Functions[Index] ~= nil then
		return Core.Functions[Index]["Function"]
	else
		warn(Index)
		pcall(function()
			rawget(Core.ProtectedFunctions, "getCallingScript")
			error(Core.getCallingScript(getfenv()).. " attempted to call a value of Core that doesn't exist. (" .. Index .. ")")
		end)
	end
end

function Core.ProtectedFunctions:waitForRequirements(Requirements, Module)
	if typeof(Requirements) ~= "table" then
		Requirements = {Requirements}
	end
	for RequirementType, FuncName in pairs(Requirements) do
		local isHardRequirement = true
		if tonumber(RequirementType) == nil then
			isHardRequirement = RequirementType
			FuncName = RequirementType
		end
		if FuncName ~= "Loaded" then
			coroutine.wrap(function()
				wait(5)
				if self.Functions[FuncName] == nil then
					if not isHardRequirement then
						self:addFunction(FuncName, function(...) return 0 end, -1000, "STUB FUNCTION")
						warn("Failed to get " .. FuncName .. ". Adding stub function. - " .. Module:GetFullName())
					else
						warn("Failing to get " .. FuncName ..  ". Continuing to yield. - " .. Module:GetFullName())
					end
				end
			end)()
			while self.Functions[FuncName] == nil do
				self.Functions.Changed:Wait()
			end
		else
			coroutine.wrap(function()
				wait(5)
				if not self.Loaded.Value then
					warn("Loading is not finished, something may be going wrong... - " .. Module:GetFullName() .. " - " .. #AllModules
						.. " - " .. #LoadedModules
					)
				end
			end)()
			if not table.find(LoadedModules, Module) then
				table.insert(LoadedModules, Module)
			end
			if #AllModules == #LoadedModules then
				self.Loaded.Value = true
			end
			if not self.Loaded.Value then
				self.Loaded.Changed:Wait()
			end
		end
	end
end

function Core.ProtectedFunctions:getGlobal(Name)
	assert(typeof(Name) ~= "table", "Please call getGlobal with : - " .. self.getCallingScript(getfenv()))
	if self.References[Name] == nil then
		warn("Invalid global " .. Name .. " requested by " .. self.getCallingScript(getfenv()))
		return nil, 0
	else
		return self.References[Name]["Value"], self.References[Name]["Priority"]
	end
end

function Core.ProtectedFunctions:waitForGlobal(Name)
	assert(typeof(Name) ~= "table", "Please call waitForGlobal with : - " .. self.getCallingScript(getfenv()))
	coroutine.wrap(function()
		wait(5)
		if self.References[Name] == nil then
			warn("waitForGlobal call for " .. Name .. " by " .. self.getCallingScript(getfenv()) .. " is still yielding.")
		end
	end)()
	while self.References[Name] == nil do
		self.References.Changed:Wait()
	end
	return self.References[Name]["Value"], self.References[Name]["Priority"]
end

function Core.ProtectedFunctions:setGlobal(Name, Value, Priority)
	assert(typeof(Name) ~= "table", "Please call setGlobal with : - " .. self.getCallingScript(getfenv()))
	if Priority == true then
		if self.References[Name] ~= nil and self.References[Name]["Priority"] ~= nil then
			Priority = self.References[Name]["Priority"]
		else
			Priority = 1
		end
	end
	
	assert(typeof(Name) == "string", "Global name was not valid from " .. self.getCallingScript(getfenv()))
	assert(typeof(Priority) == "number" or Priority == nil, "Invalid priority from " .. self.getCallingScript(getfenv()) .. " for " .. Name)
	
	self.References[Name] = { -- this is also wrapped into a PriorityTable
		["Priority"] = Priority,
		["Value"] = Value,
	}
end

local function sget(Module, Name)
	local Return = nil
	pcall(function()
		Return = rawget(Module, Name)
	end)
	return Return
end

function Core.ProtectedFunctions:initMod(Module)
	if Module:IsA("ModuleScript") then
		local RequiredModule = require(Module)
		-- but if rawget [ind] doesn't exist then it errors so pcall spam
		-- also the requirement calls shouldn't error but we check just incase
		local init = sget(RequiredModule, "init")
		local server = sget(RequiredModule, "server")
		local client = sget(RequiredModule, "client")
		
		if init or server or client then
			if self.LoadedModules[Module.Name] then
				warn("Replacing an entry " .. Module.Name .. " because another module has the same name.")
			end
			self.LoadedModules[Module.Name] = RequiredModule
			if sget(RequiredModule, "InitRequirements") then  -- we have to pcall all of these because metamethods may call metamethod spam
				self:waitForRequirements(RequiredModule.InitRequirements, Module)
			end
			if init then
				init(self)
			end
			-- now we call server/client specific
			if RunService:IsServer() and server then
				if sget(RequiredModule, "ServerRequirements") then
					self:waitForRequirements(RequiredModule.ServerRequirements, Module)
				end
				server(self)
			elseif (not RunService:IsServer()) and client then
				if sget(RequiredModule, "ClientRequirements") then
					self:waitForRequirements(RequiredModule.ClientRequirements, Module)
				end
				client(self)
			end
		end
		if not LoadedModules[Module.Name] then
			LoadedModules[Module.Name] = Module
		end
		if #AllModules == #LoadedModules then
			self.Loaded.Value = true
		end
	end
end

function Core.ProtectedFunctions:init(ModuleFolder)
	-- Wait for the game to be loaded
	if RunService:IsClient() then
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
	
	if RunService:IsClient() then
		Core.ClientEnvironment = self.getClientScript()
		Core.clientenv = self.ClientEnvironment
	end
	
	local modules = ModuleFolder:GetDescendants()
	
	-- Make our AllModules table
	for _, Module in pairs(ModuleFolder:GetDescendants()) do
		if Module:IsA("ModuleScript") then
			table.insert(AllModules, Module)
		end
	end
	
	-- Run all of our modules
	for _, Module in pairs(ModuleFolder:GetDescendants()) do
		if RunService:IsStudio() then
			spawn(function()
				self:initMod(Module)
			end)
		else -- We do this because coroutine messes up output errors, and so we use spawn in studio
			coroutine.wrap(function()
				self:initMod(Module)
			end)()
		end
	end
end

function Core.ProtectedFunctions:addFunction(FunctionName, func, Priority, SrcScript) -- Ensures that add Function is called properly, 
	-- and then determines which function should take priority.
	if SrcScript == nil then
		--assert(typeof(functionName) ~= "table", "Please call addFunction with : - " .. self.getCallingScript(getfenv()))
		SrcScript = "FAILED TO GET FUNCTION SOURCE"
		pcall(function()
			SrcScript = getfenv(func).script:GetFullName()
		end)
	end
	assert(typeof(FunctionName) == "string", SrcScript .. " provided an invalid function name.")
	assert(typeof(Priority) == "number" or Priority == nil, SrcScript .. " provided an invalid priority.")	
	assert(typeof(func) == "function", SrcScript .. " provided an invalid function.")	
	
	self.Functions[FunctionName] = {
		["Priority"] = Priority,
		["Function"] = func,
		["srcScript"] = SrcScript,
	} -- The Functions table is wrapped by the PriorityTable module
end

function Core.ProtectedFunctions:runFunctionWhenAvailable(Name, ...)
	assert(typeof(Name) ~= "table", "Please call runFunctionWhenAvailable with : - " .. self.getCallingScript(getfenv()))
	while self.Functions[Name] == nil do
		self.Functions.Changed:Wait()
	end
	return self.Functions[Name](...)
end

return Core
