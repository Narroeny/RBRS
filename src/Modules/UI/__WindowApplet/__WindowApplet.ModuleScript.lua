-- This module allows the creation of a draggable applet, optionally tied to a text button.
-- The constructor for this is a large dictionary, and returns a dict

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

local Applet = {}
local topBarAsset = script:WaitForChild("TopBar")

local AppletToggle = {}
AppletToggle.__index = AppletToggle

function AppletToggle:Open()
	self.UI.Visible = true
	AppletToggle.Core.enforceUIBounds(self.TopBar, self.UI)
	if self["OpenFunction"] ~= nil then
		self.OpenFunction()
	end
end
function AppletToggle:Close()
	self.UI.Visible = false
	if self["CloseFunction"] ~= nil then
		self.CloseFunction()
	end
end

function Applet.client(core)
	local buttonApplets = {} -- holds tables for applets so that we can get and open them externally
	AppletToggle.Core = core
	
	core:addFunction("createApplet", function(data)
		assert(typeof(data) == "table", "Invalid data (or no data) sent by " .. core.getCallingScript(getfenv()))
		assert(typeof(data["Frame"]) == "Instance" and data["Frame"]:IsA("GuiObject"),
			"Invalid Frame sent by " .. core.getCallingScript(getfenv())
		)
		-- set our default data values and ensure they are the right type
		local defaultData = {
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
		}
		for i, v in pairs(defaultData) do
			if data[i] == nil then
				data[i] = v
			elseif typeof(data[i]) ~= typeof(v) then
				assert(false, "Invalid data for type " .. i .. " sent by " .. core.getCallingScript(getfenv()))
			end
		end
		-- ok now that all of our data is correct, we start doing stuff
		local newApplet = {}
		data["Frame"]:Clone().Parent = data["Frame"].Parent -- replace the UI since we use it here
		newApplet.UI = data["Frame"]
		newApplet.UI.Visible = false
		newApplet.UI.Parent = core:getGlobal("UI")
		newApplet.TopBar = topBarAsset:Clone()
		newApplet.TopBar.Parent = newApplet.UI
		newApplet.OpenFunction = data["OpenFunction"]
		newApplet.CloseFunction = data["CloseFunction"]
		setmetatable(newApplet, AppletToggle)
		
		-- resize our UI if needed
		if data["SetSize"] then
			newApplet.UI.Size = UDim2.new(0, data["XSize"], 0, data["YSize"])
		end
		
		-- now create our draggable stuff
		core.enableDragging(newApplet.UI, newApplet.TopBar, newApplet.TopBar)
		
		-- now deal with our close button
		newApplet.TopBar:WaitForChild("CloseButton").MouseButton1Click:Connect(function()
			newApplet:Close()
		end)
		
		-- now deal with creating our open button
		if data["ButtonName"] ~= nil then
			core.createCoreButton(data["ButtonName"], function()
				newApplet:Open()
			end, data["ButtonPriority"], data["Panel"])
			buttonApplets[data["ButtonName"]] = newApplet
		end
		
		-- center our UI
		if data["CenterUI"] then
			newApplet.UI.AnchorPoint = Vector2.new(0.5, 0.5)
			newApplet.UI.Position = UDim2.new(0.5, 0, 0.5, 0)
		end
		
		-- top bar text
		newApplet.TopBar.TitleBar.Text = data["AppletTitle"]
		
		return newApplet
	end) 
	
	core:addFunction("getApplets", function()
		return buttonApplets
	end)	
end

Applet.ClientRequirements = {
	"createCoreButton",
	"enableDragging",
	"enforceUIBounds",
}

return Applet
