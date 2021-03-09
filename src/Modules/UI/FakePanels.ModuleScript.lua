-- FakePanels provides a library for creating a fake panel layout for CoreUIs that do not use Panels.
local FakePanels = {}
local runService = game:GetService("RunService")

function FakePanels.client(core)
	local mainPanel = nil
	
	local runTimeFolder = Instance.new("Folder", script)
	runTimeFolder.Name = "Runtime"
	
	local fakePanelLayoutOrders = {} -- holds our fake panel list so we can sort later
	core.wrapPriorityTable(fakePanelLayoutOrders)
	
	-- add our function to get main panels, and then wait for a coreui to tell us what it is
	core:addFunction("setMainPanel", function(panel)
		mainPanel = panel
	end)
	-- this assumes that the core ui doesn't try to fire twice, in which, uh oh
	
	-- actual stuff here
	local function sortPanels()
		local beforeMain = {}
		local afterMain = {}
		local haveSwitchedToNegative = false
		local allOtherIndex = 1
		
		for _, tab in pairs(fakePanelLayoutOrders["trueValues"]) do -- make our two tables so that our central point can be our pivot
			if tab["Priority"] < 0 then
				haveSwitchedToNegative = true
			end
			
			if haveSwitchedToNegative then
				table.insert(afterMain, tab["Children"])
			else
				table.insert(beforeMain, tab["Children"])
			end
		end
		
		-- now add our beforeMain tables
		for ind, children in ipairs(beforeMain) do
			for item, originalLayoutOrder in pairs(children) do
				local modifier = 100000 * ((#beforeMain - ind) + 1)
				item.LayoutOrder = originalLayoutOrder + modifier
			end
		end
		
		-- now add our after main
		for ind, children in ipairs(afterMain) do
			for item, originalLayoutOrder in pairs(children) do
				local modifier = -100000 * (ind)
				item.LayoutOrder = originalLayoutOrder + modifier
			end
		end
		
		-- all other UIs shouldn't be touched layout order wise, so we're good maybe??
	end
	
	core:addFunction("createCorePanel", function(panelName, _, priority)
		if fakePanelLayoutOrders[panelName] == nil or fakePanelLayoutOrders[panelName]["Item"] == nil then
			local fold = Instance.new("Folder", runTimeFolder)
			fold.Name = panelName
			fakePanelLayoutOrders[panelName] = {
				["Item"] = fold,
				["Priority"] = priority,
				["Children"] = {},
			}
			fold.ChildAdded:Connect(function(child)
				if child:IsA("GuiObject") then
					fakePanelLayoutOrders[panelName]["Children"][child] = child.LayoutOrder
					sortPanels()
					runService.RenderStepped:Wait()
					if mainPanel ~= nil then
						child.Parent = mainPanel
					else
						warn("mainPanel does not exist. The UI that was created will not appear.")
					end
				end
			end)
			return fold
		else
			return fakePanelLayoutOrders[panelName]["Item"]
		end
	end, -1000)
	
	core:addFunction("getCorePanel", function(panelName)
		if fakePanelLayoutOrders[panelName] then
			return fakePanelLayoutOrders[panelName]["Items"]
		end
	end, -1000)
end

--[[
]]

return FakePanels
