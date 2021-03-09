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

function Applet.client(core)
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
		newApplet.UI = data["Frame"]:Clone()
		newApplet.UI.Visible = false
		newApplet.UI.Parent = core:getGlobal("UI")
		newApplet.TopBar = topBarAsset:Clone()
		newApplet.TopBar.Parent = newApplet.UI
		newApplet.OpenFunction = data["OpenFunction"]
		newApplet.CloseFunction = data["CloseFunction"]
		
		-- resize our UI if needed
		if data["SetSize"] then
			newApplet.UI.Size = UDim2.new(0, data["XSize"], 0, data["YSize"])
		end
		
		-- now create our draggable stuff
		core.enableDragging(newApplet.UI, newApplet.TopBar)
		
		-- now deal with our close button
		newApplet.TopBar:WaitForChild("CloseButton").MouseButton1Click:Connect(function()
			newApplet.UI.Visible = false
			if newApplet["CloseFunction"] ~= nil then
				newApplet.CloseFunction()
			end
		end)
		
		-- now deal with creating our open button
		if data["ButtonName"] ~= nil then
			core.createCoreButton(data["ButtonName"], function()
				newApplet.UI.Visible = true
				core.enforceUIBounds(newApplet.TopBar, newApplet.UI)
				if newApplet["OpenFunction"] ~= nil then
					newApplet.OpenFunction()
				end
			end, data["ButtonPriority"], data["Panel"])
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
end

Applet.ClientRequirements = {
	"createCoreButton",
	"enableDragging",
	"enforceUIBounds",
}

return Applet
