local Remote = {}
Remote.Calls = {}

local players = game:GetService("Players")

function Remote.init(core)
	core.wrapPriorityTable(Remote.Calls)
	
	core:addFunction("createRemoteListener", function(listenerName, func, priority) -- Priority will default to 1 if value is nil
		assert(typeof(listenerName) == "string", "Listener string was not a string from " .. core.getCallingScript(getfenv()))
		assert(typeof(func) == "function", "Invalid function from " .. core.getCallingScript(getfenv()) .. " for " .. listenerName)
		assert(priority == nil or typeof(priority) == "number", 
			"Invalid priority from " ..core.getCallingScript(getfenv()).." for "..listenerName)

		Remote.Calls[listenerName] = {
			["Priority"] = priority,
			["Function"] = func,
		}
	end)
end

function Remote.waitForListener(name, timeout, core)
	local timeWaiting = 0
	assert(typeof(name) == "string", "Invalid tag sent with remote call.")
	coroutine.wrap(function() -- timeout logic
		if timeout == nil then
			wait(5)
			if Remote.Calls[name] == nil then
				warn("Listener call for " .. name .. " does not seem to be implemented on the recieving end.")
			end
		else
			while timeWaiting < timeout do
				timeWaiting += 1
				if Remote.Calls[name] == nil and (timeWaiting == timeout - 1 or timeWaiting == 5) then
					warn("Listener call for " .. name .. " does not seem to be implemented on the recieving end. Adding stub.")
					core.createListener(name, function(...) end, -100)
				end
			end
		end
	end)()
	while Remote.Calls[name] == nil do
		Remote.Calls.Changed:Wait()
	end
end

function Remote.server(core)
	local folder = Instance.new("Folder", core.env)
	folder.Name = "RBRS_Remotes"
	
	local event = Instance.new("RemoteEvent", folder)
	local func = Instance.new("RemoteFunction", folder)
	
	core:addFunction("FireClient", function(self, client, tag, ...)
		assert(typeof(self) == "table", 'Please call FireClient with ":" - ' .. core.getCallingScript(getfenv()))
		event:FireClient(client, tag, ...)
	end)
	
	core:addFunction("FireAllClients", function(self, tag, ...)
		assert(typeof(self) == "table", 'Please call FireAllClients with ":" - ' .. core.getCallingScript(getfenv()))
		event:FireAllClients(tag, ...)
	end)
	
	core:addFunction("InvokeClient", function(self, client, tag, ...)
		assert(typeof(self) == "table", 'Please call InvokeClient with ":" - ' .. core.getCallingScript(getfenv()))
		return func:InvokeClient(client, tag, ...)
	end)
	
	event.OnServerEvent:Connect(function(p, tag, ...)
		Remote.waitForListener(tag, 15, core)
		Remote.Calls[tag].Function(p, ...)
	end)
	
	func.OnServerInvoke = function(p, tag, ...)
		Remote.waitForListener(tag, 15, core)
		return Remote.Calls[tag].Function(p, ...)
	end
end

function Remote.client(core)
	local folder = core.env:WaitForChild("RBRS_Remotes")
	
	local event = folder:WaitForChild("RemoteEvent")
	local func = folder:WaitForChild("RemoteFunction")
	
	core:addFunction("InvokeServer", function(self, tag, ...)
		assert(typeof(self) == "table", 'Please call InvokeServer with ":" - ' .. core.getCallingScript(getfenv()))
		return func:InvokeServer(tag, ...)
	end)
	
	core:addFunction("FireServer", function(self, tag, ...)
		assert(typeof(self) == "table", 'Please call FireServer with ":" - ' .. core.getCallingScript(getfenv()))
		event:FireServer(tag, ...)
	end)
	
	event.OnClientEvent:Connect(function(tag, ...)
		Remote.waitForListener(tag, 15, core)
		Remote.Calls[tag].Function(...)
	end)

	func.OnClientInvoke = function(tag, ...)
		Remote.waitForListener(tag, 15, core)
		return Remote.Calls[tag].Function(...)
	end
end

return Remote
