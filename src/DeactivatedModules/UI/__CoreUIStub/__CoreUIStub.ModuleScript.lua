-- This module implements all of the functions of CoreUISlide, but in a way that doesn't actually do anything.
-- Use this to prevent "Adding stub function." spam.

local CoreUIStub = {}

function CoreUIStub.client(core)
	local ui = Instance.new("ScreenGui", script)
	core:setGlobal("UI", ui) -- set our UI global
	
	core:addFunction("lockCoreUI", function()
		return
	end)
	
	core:addFunction("unlockCoreUI", function()
		return
	end)
	
	core:addFunction("createCoreButton", function()
		local newButton = script.ButtonAsset:Clone()
		newButton.Parent = script
		return newButton
	end)
end

CoreUIStub.ClientRequirements = {
	"setMainPanel",
}

return CoreUIStub
