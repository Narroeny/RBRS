-- This module emulates an RBXScriptSignal in a way similar to a bindable event to prevent bindable spam

local Signal = {} -- Main Signal table
Signal.CurrentSignals = {}
local Connection = {} -- Table holding the Disconnect function
local CurrentIndex = 1 -- Used to make Wait calls know which Signal this is
local WaitBind = script:WaitForChild("Wait")

function Signal:Destroy() -- Disconnects all functions, the script using Signal still has to remove this
	for i = table.getn(self.Connected), 1, -1 do
		table.remove(self.Connected, i)
	end
end

function Signal:Wait() -- Wait until this signal table is called
	local Waiting = true
	
	local Connection
	Connection = WaitBind.Event:Connect(function(SingalIndex)
		if SingalIndex == self.SignalIndex then
			Waiting = false
		end
		Connection:Disconnect()
	end)
	
	while Waiting do
		WaitBind.Event:Wait()
		wait()
	end
end

function Signal:Fire(...) -- Call all of our connected functions
	for _, Function in pairs(self.Connected) do
		coroutine.wrap(Function)(...)
	end
	
	-- Call our Wait bind with this Signal table to process :Wait() reqs
	WaitBind:Fire(self.SignalIndex)
end

function Signal:Connect(Function) -- Connects a signal, returns a "RBXScriptSignal"
	assert(typeof(Function) == "function", "Non-function sent to Connect")
	
	local NewConnection = {}
	setmetatable(NewConnection, {
		__index = Connection
	})
	NewConnection.Connected = true
	NewConnection.Signal = self
	NewConnection.Function = Function
	
	table.insert(self.Connected, Function)
	
	return NewConnection
end

function Connection:Disconnect() -- Disconnects by removing function from list, script has to still dispose
	for Index, Function in ipairs(self.Signal.Connected) do
		if Function == self.Function then
			table.remove(self.Signal.Connected, Index)
			break
		end
	end
	self.Connected = false
end

function Signal.init(Core)
	Core:addFunction("getSignal", function(Name) -- Creates a new Signal
		if Signal.CurrentSignals[Name] ~= nil then
			return Signal.CurrentSignals[Name]
		end
		
		local NewSignal = {}
		setmetatable(NewSignal, {
			__index = Signal
		})
		NewSignal.Connected = {}
		NewSignal.SignalIndex = CurrentIndex
		CurrentIndex += 1
		
		Signal.CurrentSignals[Name] = NewSignal
		
		return NewSignal
	end)
end

return Signal