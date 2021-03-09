-- This module provides the functions and code for the original raidRoleplay UI
-- If making a custom UI system, add implementations (or even just stubs) of all of the functions in here.
-- See the DeveloperDocumentation

local CoreUI = {}
local Configuration = require(script:WaitForChild("Configuration"))

function CoreUI.client(core)
	core.loadEnv(getfenv())
	local ui = script:WaitForChild("RBRSUI", 5)
	assert(ui ~= nil, "UI is missing from CoreUISlide!")
	ui.Parent = playerGui
	
	core:setGlobal("UI", ui) -- set our UI global
	
	-- make variables for our stuffs
	local coreUI = ui:WaitForChild("CoreUI")
	
	local mouseOverAreas = {
		coreUI:WaitForChild("ButtonList"),
		coreUI:WaitForChild("OpenButton"),
	}
	local buttonAreas = {
		coreUI:WaitForChild("OpenButton"),
	}
	
	local mainPanel = coreUI:WaitForChild("ButtonList")
	core.setMainPanel(mainPanel)
	local buttonAsset = coreUI:WaitForChild("ButtonAsset")
	
	-- deal with our sliding now
	local slideMod = require(script:WaitForChild("Slide"))
	slideMod.UI = coreUI
	slideMod.Configuration = Configuration
	slideMod.Core = core
	slideMod:Activate(mouseOverAreas, buttonAreas)
	
	-- main ui sliding related functions
	core:addFunction("lockCoreUI", function(setOpen) -- not recommended that you use this w/o a very good reason
		slideMod.Locked = true
		if typeof(setOpen) == "boolean" then
			slideMod:UpdateStatus(setOpen)
		end
	end)
	
	core:addFunction("unlockCoreUI", function()
		slideMod.Locked = false
	end)
	
	core:addFunction("createCoreButton", function(buttonName, func, layoutOrder, parent)
		assert(typeof(buttonName) == "string", "Invalid button name sent by " .. core.getCallingScript(getfenv()))
		assert(typeof(func) == "function", "Invalid function sent by " .. core.getCallingScript(getfenv()))
		if typeof(layoutOrder) ~= "number" then
			layoutOrder = 0
		end
		if typeof(parent) ~= "Instance" then
			parent = mainPanel
		end
		
		local newButton = buttonAsset:Clone()
		newButton.TextLabel.Text = buttonName
		newButton.LayoutOrder = layoutOrder
		newButton.Parent = parent
		newButton.Visible = true
		
		newButton.Activated:Connect(func)
		
		return newButton
	end)	
end

CoreUI.ClientRequirements = {
	"setMainPanel",
	"createCorePanel",
	"getCorePanel",
}

return CoreUI