-- This module provides the F3X event capturing, module collection, etc. for code.

local module = {}

local rs = game:GetService("RunService")

function module.Listener(core)
	local inittab = {} -- table for f3x that has already been initialized, aka firstrun from modules has already been run
	local modules = script.Parent.Parent.Parent:WaitForChild("Modules")
	local currenttool = "Move Tool"
	local lp = game:GetService("Players").LocalPlayer
	local char = lp.Character or lp.CharacterAdded:Wait() -- speculative fix maybe
	local cas = game:GetService("ContextActionService")
	
	local onequipevs = {} -- modules that have an event when they are equipped at any time
	local firstequipevs = {}
	local histupdatedevs = {}
	local selectchangedevs = {}
	
	for i, v in pairs(modules:GetChildren()) do -- adding to event tables
		local mod = require(v)
		if mod.f3xEquipped ~= nil then
			table.insert(onequipevs, mod.f3xEquipped)
		end
		if mod.f3xFirstEquipped ~= nil then
			table.insert(firstequipevs, mod.f3xFirstEquipped)
		end
		if mod.f3xHistoryUpdated ~= nil then
			table.insert(histupdatedevs, mod.f3xHistoryUpdated)
		end
		if mod.f3xSelectionUpdated ~= nil then
			table.insert(selectchangedevs, mod.f3xSelectionUpdated)
		end
	end
	
	local function callmods(modtab, coretab)
		for i, v in pairs(modtab) do
			if not rs:IsStudio() then
				coroutine.wrap(function()
					v(coretab)
				end)()
			else
				spawn(function()
					v(coretab)
				end)
			end
		end
	end
	
	local function f3xInit(t)
		if t:FindFirstChild("Core") and t:FindFirstChild("Loader") ~= nil and table.find(inittab, t) == nil then 
			-- check to see if we just equipped f3x
			local coretabaddtable = {
				["fcore"] = t:WaitForChild("Core"),
				["fhist"] = t.Core:WaitForChild("History"),
				["fselect"] = t.Core:WaitForChild("Selection"),
				["f3x"] = t,
				["fsyncapi"] = t:WaitForChild("SyncAPI")
			}
			local coretab = core.getCoreTable(coretabaddtable)
			callmods(onequipevs, coretab)
			if table.find(inittab, t) == nil then -- if this is first equip
				table.insert(inittab, t)
				callmods(firstequipevs, coretab) -- firstly call any blatant "first equipped" things
				
				-- secondly now we need to call our history updates
				local f3xhist = require(t.Core.History)
				f3xhist.Changed:Connect(function() -- when the history is updated f3x
					--print("History updated.")
					local newrecord = f3xhist.Stack[f3xhist.Index]
					coretab["newfhist"] = newrecord
					callmods(histupdatedevs, coretab)
				end)
				
				
				-- thirdly attach our tool equipped listener for history
				require(coretab["fcore"]).ToolChanged:Connect(function(dict)
					--print(dict["Name"])
					currenttool = dict["Name"]
				end)
				
				local f3xselect = require(t.Core.Selection)
				-- fourthly attach the selection module changed event
				f3xselect.Changed:Connect(function()
					callmods(selectchangedevs, coretab)
				end)
			end
		end
	end
	
	cas.LocalToolEquipped:Connect(f3xInit) -- grab our tools when they are equipped
	
	if char:FindFirstChildWhichIsA("Tool") then
		f3xInit(lp.Character:FindFirstChildWhichIsA("Tool"))
	end
	
	local ev = script:WaitForChild("GetCurrentF3XTool") -- attach to the remote function so that core can get the current tool
	ev.OnInvoke = function()
		--print("wat")
		--print(currenttool)
		return currenttool
	end
end

return module
