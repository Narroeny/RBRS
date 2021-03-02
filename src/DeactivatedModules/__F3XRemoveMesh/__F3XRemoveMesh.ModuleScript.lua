local module = {}

function module.f3xFirstEquipped(coretab)
	local core = require(coretab["core"])
	local bypassrank = require(script:WaitForChild("Configuration"))
	local plrrank = core.getPlayerRank()
	local tool = coretab["f3x"]
	
	if plrrank < bypassrank then
		local int = tool:WaitForChild("Interfaces")
		int:WaitForChild("BTMeshToolGUI"):Destroy()
		
		local ui = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("Building Tools by F3X (UI)")
		local dock = ui:WaitForChild("Dock"):WaitForChild("ToolList"):WaitForChild("List")
		for i, v in pairs(dock:GetChildren()) do -- clear dock icons
			if v:IsA("ImageButton") and v.Image == "rbxassetid://141806786" then
				v:Destroy()
			end
		end
	end
end

return module
