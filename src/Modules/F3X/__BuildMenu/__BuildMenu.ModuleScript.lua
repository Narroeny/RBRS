-- SetGui v5????!?!??!?!?!??!?!
--[[
["Frame"] = instance
["XSize"] = data.Frame.AbsoluteSize.X,
["YSize"] = data.Frame.AbsoluteSize.Y,
["SetSize"] = true,
["CloseFunction"] = function() end,
["Panel"] = nil,
["ButtonName"] = nil,
["ButtonPriority"] = 1,
["OpenFunction"] = function() end,
["AppletTitle"] = "",
["CenterUI"] = true,
]]

local BuildMenu = {}
local Configuration = require(script:WaitForChild("Configuration"))

function BuildMenu.server(core)
	
end

function BuildMenu.client(core)
	core.loadEnv(getfenv())
	local pRank = core.getSecurityLevel()
	if pRank < Configuration.LevelToUse then
		return
	end
	local MainUI = script:WaitForChild("BuildMenu")
	local MainPanel = MainUI:WaitForChild("Main")
	local OneOptionPanel = MainUI:WaitForChild("OneOption")
	local TwoOptionPanel = MainUI:WaitForChild("TwoOption")
	local TextPrompt = MainUI:WaitForChild("Text")
	local TextBoxPanel = MainUI:WaitForChild("TextBox")
	
	-- Switches the type of UI we are showing on our main panel
	local function switchUI(name)
		if name == nil then
			name = "Main"
		end
		MainPanel.Visible = (name == "Main")
		OneOptionPanel.Visible = (name == "OneOption")
		TwoOptionPanel.Visible = (name == "TwoOption")
		TextPrompt.Visible = (name == "Text")
		TextBoxPanel.Visible = (name == "TextBox")
	end
	
	-- Create our applet
	local ourApplet = core.createApplet({
		["Frame"] = script:WaitForChild("BuildMenu"),
		["XSize"] = 500,
		["YSize"] = 450,
		["Panel"] = "Building",
		["ButtonName"] = "Build Menu",
		["ButtonPriority"] = 10000,
		["AppletTitle"] = "Build Menu",
		["OpenFunction"] = switchUI
	})
end

BuildMenu.ServerRequirements = {
	
}

BuildMenu.ClientRequirements = {
	"createApplet"
}

BuildMenu.InitRequirements = {
	"getSecurityLevel"
}

return BuildMenu
