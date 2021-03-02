-- This has a lot of extra stuff, and that's because this will serve as one of the bases that 2.0 works off of

local module = {}

function module.f3xFirstEquipped(coretab)
	local Signal = require(coretab["f3x"]:WaitForChild("Libraries"):WaitForChild("Signal"))
	local sig = Signal.new()

	local function afterRun(...)
		return ...
	end
	
	local function interceptRun(handler)
		if not (type(handler) == "function") then
			error(("connect(%s)"):format(typeof(handler)), 2)
		end

		return self._bindableEvent.Event:Connect(function()
			if self._argData and self._argCount ~= nil then
				handler(unpack(self._argData, 1, self._argCount))
			end
		end)
	end

	local function beforeRun(...)
		return ...
	end

	Signal.__index = function(self, ind)
		if ind ~= "Connect" then
			return Signal[ind]
		end
		return function(...)
			-- Right now, the first argument is going to be self when it is called with :, or the actual argument, so we need to separate
			-- that
			local args = table.pack(...)
			local targSelf
			
			if args[1] ~= nil and args[1] == self then -- Check if the first argument is self
				targSelf = self
				table.remove(args, 1)
			end
			args["n"] = nil -- we don't want this
			
			-- Set the self variable of the environment of our beforeRun function to the self of the original function, if it exists
			local env1 = getfenv(beforeRun)
			env1.self = targSelf
			
			local env2 = getfenv(afterRun)
			env2.self = targSelf
			
			-- ok now the fun block
			if targSelf ~= nil then -- In the case that we call function that was called by :, send it's self as
				-- first arg
				return afterRun ( -- Once we finish with everything inside, run and return afterRun
					interceptRun( -- Set the env of the target function to beforeRun's env incase if 
						-- beforeRun changes the env
						beforeRun( -- First, run the beforeRunFunction, with the args passed
							table.unpack(args)
						)
					)
				) -- make sure to call afterRun
			else
				return afterRun ( -- Once we finish with everything inside, run and return afterRun
					interceptRun( -- Set the env of the target function to beforeRun's env incase if 
						-- beforeRun changes the env
						beforeRun( -- First, run the beforeRunFunction, with the args passed
							table.unpack(args)
						)
					)
				)() -- make sure to call afterRun
			end
		end
	end
end

return module
