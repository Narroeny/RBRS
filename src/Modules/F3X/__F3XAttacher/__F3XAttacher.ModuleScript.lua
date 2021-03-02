local F3XAttacher = {}
local ClientNodepoints = { -- values are either tables (for childen) or string (for name used when calling)
	["Core"] = {"Core",
		["History"] = "History",
		["Selection"] = "Selection",
		["Security"] = "Security",
		},
	["Tools"] = {
		["Anchor"] = "Anchor",
		["Collision"] = "Collision",
		["Decorate"] = "Decorate",
		["Lighting"] = "Lighting",
		["Material"] = "Material",
		["Mesh"] = "Mesh",
		["Move"] = "Move",
		["NewPart"] = "NewPart",
		["Paint"] = "Paint",
		["Resize"] = "Resize",
		["Rotate"] = "Rotate",
		["Surface"] = "Surface",
		["Texture"] = "Texture",
		["Weld"] = "Weld",
	},
	["Libraries"] = {
		["Signal"] = "Signal",
	},
}

local ServerNodepoints = {
	["SyncAPI"] = {
		["SyncModule"] = "SyncModule"
	}
}

function F3XAttacher.init(core)
	core.loadEnv(getfenv())
	local newF3XFuncs = {}
	local currentF3X = {} --[[
	[Instance] = {
		["Core"] = {["Script"] = Instance, ["Data"] = required module}
		["Paint"] = {["Script"] = Instance, ["Data"] = required module}
	}
	]]
	local attachments = {} --[[
		["ModuleName"] = {
			["FunctionName"] = {
				["Before"] = {
					{
					["Function"] = function
					["Creator"] = creator
					["Priority"] = number
					}
				}
				["After"] = ...
				["Intercept"] = ...
			}
		}
	]]
	local ourNodepoints = (runService:IsServer() and ServerNodepoints) or ClientNodepoints
	
	local function hookToF3X(tool)
		local f3xTable = {}
		if typeof(tool) == "Instance" and tool:IsA("Tool") and currentF3X[tool] == nil and tool:WaitForChild("Core", 1) then
			local function writeFromNodes(tab, parentMod)
				for name, ent in pairs(tab) do
					if typeof(name) == "number" and typeof(ent) == "string" and parentMod:IsA("ModuleScript") then
						f3xTable[ent] = parentMod
					elseif typeof(name) == "string" and typeof(ent) == "string" then
						f3xTable[ent] = parentMod:FindFirstChild(ent)
					elseif typeof(ent) == "table" then
						if parentMod:FindFirstChild(name) ~= nil then
							writeFromNodes(ent, parentMod[name])
						end
					end
				end
			end
			writeFromNodes(ourNodepoints, tool)
			
			for name, module in pairs(f3xTable) do
				f3xTable[name] = {
					["Script"] = module,
					["Data"] = require(module),
				}
			end
			
			currentF3X[tool] = f3xTable
			-- now attach all current attachments to the F3X brick
			for moduleName, functionName in pairs(attachments) do
				if f3xTable[moduleName] then
					for typ, data in pairs(functionName) do
						if typ == "Before" then
							core.AttachBeforeRun(f3xTable[moduleName]["Script"], functionName, data["Function"], data["Priority"])
						elseif typ == "After" then
							core.AttachAfterRun(f3xTable[moduleName]["Script"], functionName, data["Function"], data["Priority"])
						elseif typ == "Intercept" then
							core.AttachIntercept(f3xTable[moduleName]["Script"], functionName, data["Function"], data["Priority"])
						end
					end
				end
			end
			
			-- now run all of our new f3x functions
			for _, func in pairs(newF3XFuncs) do
				coroutine.wrap(function()
					func(tool, f3xTable)
				end)()
			end
		end
	end
	
	local function attachToPlayer(player)
		local function pseudo()
			local char = player.Character or player.CharacterAdded:Wait()
			char.ChildAdded:Connect(hookToF3X)
			hookToF3X(char:FindFirstChildWhichIsA("Tool"))
			
			local backpack = player:WaitForChild("Backpack")
			player.Backpack.ChildAdded:Connect(hookToF3X)
			for _, v in pairs(player.Backpack:GetChildren()) do
				hookToF3X(v)
			end
		end
		
		pseudo(player)
		player.CharacterAdded:Connect(pseudo)
	end
	
	if runService:IsServer() then
		for _, player in pairs(players:GetPlayers()) do
			attachToPlayer(player)
		end
		players.PlayerAdded:Connect(function(player)
			attachToPlayer(player)
		end)
	else
		attachToPlayer(localPlayer)
	end
	
	core:addFunction("addF3XAttachment", function(moduleName, functionName, typ, func, priority)
		assert(typ == "Before" or typ == "After" or typ == "Intercept", "Invalid type value, please use 'Before', 'After', or 'Intercept' -"
			.. core.getCallingScript(getfenv()))
		assert(typeof(func) == "function", "Non-function sent by " .. core.getCallingScript(getfenv()))
		assert(typeof(functionName) == "string", "Invalid function name sent by " .. core.getCallingScript(getfenv()))
		if attachments[moduleName] == nil then
			attachments[moduleName] = {
			}
		end
		if attachments[moduleName][functionName] == nil then
			attachments[moduleName][functionName] = {
				["Before"] = {},
				["After"] = {},
				["Intercept"] = {}
			}
		end
		local entry = {
			["Function"] = func,
			["Priority"] = priority,
			["Creator"] = core.getCallingScript(getfenv())
		}
		table.insert(attachments[moduleName][functionName][typ], entry) 

		-- now load it for all current f3x bricks
		for tool, inf in pairs(currentF3X) do
			if inf[moduleName] ~= nil then
				if typ == "Before" then
					core.AttachBeforeRun(inf[moduleName]["Script"], functionName, func, priority)
				elseif typ == "After" then
					core.AttachAfterRun(inf[moduleName]["Script"], functionName, func, priority)
				elseif typ == "Intercept" then
					core.AttachIntercept(inf[moduleName]["Script"], functionName, func, priority)
				end
			end
		end
	end)
	
	core:addFunction("attachNewF3X", function(func)
		assert(typeof(func) == "function", "Invalid function sent to attachNewF3X by " .. core.getCallingScript(getfenv()))
		table.insert(newF3XFuncs, func)
		for tool, dataTab in pairs(currentF3X) do
			coroutine.wrap(function()
				func(tool, dataTab)
			end)()
		end
	end)
end

F3XAttacher["InitRequirements"] = {
	"AttachBeforeRun",
	"AttachIntercept",
	"AttachAfterRun",
}

F3XAttacher["Description"] = "Provides the library for easy attachment to F3X tools and events."

return F3XAttacher