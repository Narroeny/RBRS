-- Removes the F3X Explorer feature in a hacky way.  Basically imported from the old code

local module = {}

function module.f3xFirstEquipped(coretab)
	local uis = game:GetService("UserInputService")
	local core = require(coretab["fcore"])
	local gui = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild('Building Tools by F3X (UI)')
	local badbutton = gui:WaitForChild("Dock"):WaitForChild("SelectionPane"):WaitForChild("ExplorerButton")
	badbutton.Visible = false
	badbutton.Activated:Connect(function()
		core.ToggleExplorer()
	end)
	uis.InputBegan:Connect(function(key, waschat)
		if not waschat and (uis:IsKeyDown(Enum.KeyCode.LeftShift) or uis:IsKeyDown(Enum.KeyCode.RightShift)) and uis:IsKeyDown(Enum.KeyCode.H) then
			if gui:WaitForChild("Explorer", 0.5) ~= nil then
				local ilist = gui.Explorer:WaitForChild("ItemList", 0.5)
				while ilist:FindFirstChildWhichIsA("ImageButton") == nil do
					wait()
				end
				core.ToggleExplorer()
			end
		end
	end)
end

return module
