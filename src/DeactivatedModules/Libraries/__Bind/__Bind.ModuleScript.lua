-- Super simple library to allow bindables to be made and listened to. However, Signal is cooler so use that
-- Need to replace this ye

local Bind = {}
local currentBinds = {}

function Bind.init(core)
	core:addFunction("GetBind", function(name)
		if currentBinds[name] ~= nil then
			return currentBinds[name]
		else
			local newBind = Instance.new("BindableEvent", script)
			currentBinds[name] = newBind
			return newBind
		end
	end)
end

return Bind
