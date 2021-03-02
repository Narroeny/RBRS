--[[ This module is responsible for the interception of F3X module calls created by functions, and processing the data.
	As it can also be used to hijack Core functions (or realistically any module functions,) it is a Library.
]]

local Attach = {}
Attach.Attachments = {}
Attach.__index = Attach

function Attach:createFunctionStack(tab, origFunc, Module)
	if tab["trueValues"] ~= nil then
		tab = tab.trueValues
	end
	local functionStack = {}
	if tab["BeforeRun"] then
		for _, v in pairs(tab["BeforeRun"]) do
			if typeof(v) == "table" and v["Function"] and v["Creator"] then
				table.insert(functionStack, {
					["Function"] = v["Function"],
					["Creator"] = v["Creator"],
					["Type"] = "BeforeRun",
				})
			end
		end
	end
	if tab["Run"] and tab["Run"][1] then
		table.insert(functionStack, {
			["Function"] = tab["Run"][1]["Function"],
			["Creator"] = tab["Run"][1]["Creator"],
			["Type"] = "Run",
		})
	else
		table.insert(functionStack, {
			["Function"] = origFunc,
			["Creator"] = Module:GetFullName(),
			["Type"] = "Run"
		})
	end
	if tab["AfterRun"] then
		for _, v in pairs(tab["AfterRun"]) do
			if typeof(v) == "table" and v["Function"] and v["Creator"] then
				table.insert(functionStack, {
					["Function"] = v["Function"],
					["Creator"] = v["Creator"],
					["Type"] = "AfterRun",
				})
			end
		end
	end
	return functionStack
end

function Attach:runAttached(callerTab, tab, Module, targ, ind, ...)
	local args = {...}
	
	-- Check if args == callerTab, and if so, remove.
	if args[1] ~= nil and args[1] == callerTab then
		table.remove(args, 1)
	end
	-- Create our function stack
	local functionStack = self:createFunctionStack(tab, targ, Module)
	local data = args
	for i, func in pairs(functionStack) do
		if callerTab then
			local env = getfenv(func["Function"])
			env.self = callerTab
		end
		local succ, err
		succ, err = pcall(function()
			local ourRet = {func["Function"](table.unpack(data))}
			data = ourRet
		end)
		if not succ then
			warn(func["Type"] .. " function from " .. func["Creator"] .. ((ind and " for function " .. ind) or "") ..
				" for module " .. (Module and Module:GetFullName()) or "ERROR.." .. " has errored."
			)
			if i ~= 1 then
				warn("The function that ran before the erroring function was provided by " .. functionStack[i - 1]["Creator"])
			end
			warn(err)
		end
	end
end

function Attach.initFuncTab(Core, entry, Module, functionName)
	local funcTab = entry[functionName]
	if funcTab == nil then
		--[[funcTab = {
			["BeforeRun"] = {},
			["Run"] = {},
			["AfterRun"] = {},
		}]]
		funcTab = {}
		entry[functionName] = funcTab
		--Core.wrapPriorityTable(funcTab["BeforeRun"], true)
		--Core.wrapPriorityTable(funcTab["Run"], false)
		--Core.wrapPriorityTable(funcTab["AfterRun"], true)
		if entry["__Module"][functionName] ~= nil then -- only run this code if this isn't an mt function
			-- so that we can write to the function itself
			local targFunc = entry["__Module"][functionName]
			assert(typeof(targFunc == "function"), functionName .. " isn't a function in module. - " .. 
				Core.getCallingScript(getfenv()))
			funcTab["__OriginalFunction"] = targFunc
			entry["__Module"][functionName] = function(...)
				Attach:runAttached(nil, entry[functionName], Module, targFunc, functionName, ...)
			end
		end
		Core.wrapPriorityTable(funcTab, true)
	end
end

function Attach.init(core)
	Attach.Core = core
	
	core:addFunction("AttachBeforeRun", function(module, functionName, func, priority)
		assert(typeof(functionName) == "string", "Invalid functionName from " .. core.getCallingScript(getfenv()))
		assert(typeof(func) == "function", "Invalid function from " .. core.getCallingScript(getfenv()))
		Attach:loadModule(module)
		local entry = Attach.Attachments[module]
		Attach.initFuncTab(core, entry, module, functionName)
		entry[functionName]:insert("BeforeRun", {
			["Function"] = func,
			["Priority"] = priority, 
			["Creator"] = core.getCallingScript(getfenv()),
		})
		return Attach.Attachments[module]
	end)
	
	core:addFunction("AttachIntercept", function(module, functionName, func, priority)
		assert(typeof(functionName) == "string", "Invalid functionName from " .. core.getCallingScript(getfenv()))
		assert(typeof(func) == "function", "Invalid function from " .. core.getCallingScript(getfenv()))
		Attach:loadModule(module)
		local entry = Attach.Attachments[module]
		Attach.initFuncTab(core, entry, module, functionName)
		entry[functionName]["Run"] = {
			["Function"] = func,
			["Priority"] = priority, 
			["Creator"] = core.getCallingScript(getfenv()),
		}
		return Attach.Attachments[module]
	end)
	
	core:addFunction("AttachAfterRun", function(module, functionName, func, priority)
		assert(typeof(functionName) == "string", "Invalid functionName from " .. core.getCallingScript(getfenv()))
		assert(typeof(func) == "function", "Invalid function from " .. core.getCallingScript(getfenv()))
		Attach:loadModule(module)
		local entry = Attach.Attachments[module]
		Attach.initFuncTab(core, entry, module, functionName)
		entry[functionName]["AfterRun"] = {
			["Function"] = func,
			["Priority"] = priority, 
			["Creator"] = core.getCallingScript(getfenv()),
		}
		return Attach.Attachments[module]
	end)
	
	core:addFunction("getAttachments", function(module)
		return Attach.Attachments[module]
	end)
end

function Attach:loadModule(Module) -- This function attaches to a module and loads it into the table if not available
	-- as well as creating our primary handler for metamethods
	if typeof(Module) == "Instance" and Module:IsA("ModuleScript") then -- ensure this is a valid entry
		if self.Attachments[Module] ~= nil then
			return self.Attachments[Module]
		else
			local mod = require(Module)
			local tab = { -- Create our attachment table, and attach the module
				["__Module"] = mod,
				["__ModuleObject"] = Module,
			}
			self.Attachments[Module] = tab
			-- Perform our index hijacking
			local currentMt = getmetatable(mod)
			if currentMt == nil then
				currentMt = mod
			end
			local oldIndexMethod = currentMt["__index"] -- Store the old index metamethod so we can use it to find values
			if typeof(currentMt) ~= "string" then
				currentMt.__index = function(callerTab, ind) -- Set a new Index metamethod
					local targ = nil
					if typeof(oldIndexMethod) == "function" then
						targ = oldIndexMethod(callerTab, ind)
					elseif typeof(oldIndexMethod) == "table" then
						targ = oldIndexMethod[ind]
					else
						targ = mod[ind]
					end
					if typeof(targ) == "function" and tab[ind] ~= nil then
						return function(...)
							self:runAttached(callerTab, tab[ind], Module, targ, ind, ...)
						end
					else
						return targ
					end
				end
			end
			-- Hijack all of the functions directly in the module
			for i, v in pairs(mod) do
				if typeof(v) == "function" then
					mod[i] = function(...)
						if tab[i] ~= nil then
							self:runAttached(nil, tab[i], Module, v, i, ...)
						else
							return v(...)
						end
					end
				end
			end
		end
	else
		warn(typeof(Module), Module)
		if typeof(Module) == "Instance" then
			warn(Module:GetFullName())
		end
		error("Invalid call to Attach by " .. self.Core.getCallingScript(getfenv()))
	end
end

return Attach
