local RemoveF3XExplorer = {}
local config = require(script:WaitForChild("Configuration"))

function RemoveF3XExplorer.client(core)
	--core:addFunction("addF3XAttachment", function(moduleName, functionName, typ, func, priority)
	if core.getSecurityLevel() < config.RankToBypass then
		core.addF3XAttachment("Core", "OpenExplorer", "Intercept", function()
			return nil
		end)
		
		core.attachNewF3X(function(tool, dataTab)
			local core = dataTab["Core"]["Data"]
			while core.UI == nil do
				wait()
			end
			core.UI:WaitForChild("Dock"):WaitForChild("SelectionPane"):WaitForChild("ExplorerButton").Visible = false
		end)
	end
end

function RemoveF3XExplorer.server(core)
	core.addF3XAttachment("SyncModule", "PerformAction", "Before", function(Client, ActionName, ...)
		if core.getSecurityLevel(Client) < config.RankToBypass then
			if ActionName == "SyncAnchor" then
				ActionName = nil
			end
			return Client, ActionName, ...
		end
	end)
end

RemoveF3XExplorer["Description"] = "Removes and disables the F3X Explorer"

RemoveF3XExplorer["InitRequirements"] = {
	"addF3XAttachment",
	"attachNewF3X",
	["getSecurityLevel"] = false,
}

RemoveF3XExplorer["ConfigurationDescription"] = {
	["RankToBypass"] = "What rank will be able to bypass this feature",
}

return RemoveF3XExplorer
