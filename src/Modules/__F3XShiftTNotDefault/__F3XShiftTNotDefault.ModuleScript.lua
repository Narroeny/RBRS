-- This module changes the selection mode to single part, and removes the Shift T keybind. Players can still switch to model mode
-- by clicking the button in the bottom left.

-- Also basically an import from Legacy

local module = {}

function module.f3xFirstEquipped(coretab)
	local cas = game:GetService("ContextActionService")
	local targmod = require(coretab["fcore"].Targeting)
	targmod:SetTargetingMode("Direct") -- directly change the mode to direct
	local conf = require(script:WaitForChild("Configuration"))
	
	if conf["RemoveModelSelectKeybind"] then
		local function removebind()
			cas:UnbindAction('BT: Toggle Targeting Mode') -- make our function to remove the bind
		end
		
		cas:BindActionAtPriority('Remove Shift-T from F3X', removebind, false, 20000, Enum.KeyCode.T) -- 20000 > 2000, therefore we are
		-- more epic than f3x :sunglasses:
	end
end

return module
