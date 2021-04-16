local RemoveF3XAnchor = {}
local config = require(script:WaitForChild("Configuration"))

function RemoveF3XAnchor.client(core)
	--core:addFunction("addF3XAttachment", function(moduleName, functionName, typ, func, priority)
	if core.getSecurityLevel() < config.RankToBypass then
		core.addF3XAttachment("Anchor", "Equip", "Intercept", function()
			return nil
		end)
		core.addF3XAttachment("Anchor", "ShowUI", "Intercept", function()
			return nil
		end)
		core.addF3XAttachment("Anchor", "BindShortcutKeys", "Intercept", function()
			return nil
		end)
		
		core.attachNewF3X(function(tool, dataTab)
			local core = dataTab["Core"]["Data"]
			if not tool.Loaded.Value then
				tool.Loaded.Changed:Wait()
			end
			local assets = require(tool.Assets)
			local icon = assets["AnchorIcon"]
			for i, v in pairs(core.UI.Dock.ToolList.List:GetChildren()) do
				if v:IsA("ImageButton") and v.Image == icon then
					v.Visible = false
				end
			end
			core.UI.Dock.ToolList.List.ChildAdded:Connect(function(child) -- quick patch until F3XTools system releases
				if child:IsA("ImageButton") then
					wait(0.5)
					if child.Image == icon then
						child:Destroy()
					end
				end
			end)
		end)
	end
end

function RemoveF3XAnchor.server(core)
	core.addF3XAttachment("SyncModule", "PerformAction", "Before", function(Client, ActionName, ...)
		if core.getSecurityLevel(Client) < config.RankToBypass then
			if ActionName == "SetAnchored" then
				ActionName = nil
			end
			return Client, ActionName, ...
		end
	end)
end

RemoveF3XAnchor["Description"] = "Removes and disables the F3X Anchor Tool"

RemoveF3XAnchor["InitRequirements"] = {
	"addF3XAttachment",
	"attachNewF3X",
	["getSecurityLevel"] = false,
}

RemoveF3XAnchor["ConfigurationDescription"] = {
	["RankToBypass"] = "What rank will be able to bypass this feature",
}

return RemoveF3XAnchor
