local module = {}

function module.f3xFirstEquipped(coretab) -- when the selection in f3x changes
	local lp = game:GetService("Players").LocalPlayer
	local core = require(coretab["core"])
	local selectionmod = require(coretab["fselect"])
	local prank = core.getPlayerRank()
	
	selectionmod.Changed:Connect(function()
		for i, v in pairs(selectionmod.Parts) do
			if v.Locked == true then
				selectionmod:Clear(false)
				break
			end
		end
	end)
end

return module