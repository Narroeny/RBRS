--[[ this module provides a cross platform "mouse" object
it only has one function, :GetMouse(), which returns a mouse object

]]
--[[
this only has the features of the mouse i need rn, so add more later and update documentation
Mouse.Hit -- if target is nil, returns hit 2000 studs away
Mouse.Icon
Mouse.Target
Mouse.TargetFilter -- leads to FilterDescendantsInstances

-- SPECIAL
Mouse.FilterDescendantsInstances
Mouse.FilterType
--

Mouse.ViewSizeX
Mouse.ViewSizeY
Mouse.X
Mouse.Y
Mouse.Vector2 -- x + y in a vec2

Mouse.UIHit -- utility value, simple wrapper for getguiobjects call
Mouse.VisibleUIHit -- same as before, but filters out UIs that are invisible

Mouse.Button1Down
Mouse.Button1Up
Mouse.Button2Down
Mouse.Button2Up
Mouse.Move


For mobile, there is no button2 rn sorry Lul

For console, right trigger = button1, left trigger = button2
]]

local Mouse = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return {}
end

local Inset = GuiService:GetGuiInset()

local LocalPlayer = Players.LocalPlayer
local DefaultMouse = LocalPlayer:GetMouse()
local ReturnStandardValues = {
	"Icon",
	"ViewSizeX",
	"ViewSizeY",
} -- these values just return the value from mouse itself

local GlobalMouseValues = {
	-- These are just here for reference, but are handled by the Index metamethod
	["Target"] = nil,
	["Hit"] = nil,
	-- These are updated at runtime
	["MouseVector"] = nil,
	["X"] = nil,
	["Y"] = nil,
}

local Signals = {}

UserInputService.InputChanged:Connect(function(Input, GPE)
	if Input.UserInputType == Enum.UserInputType.MouseMovement then
		local UISVector = UserInputService:GetMouseLocation()
		--GlobalMouseValues["MouseVector"] = Vector2.new(UISVector.X + Inset.X, UISVector.Y + Inset.Y)
		GlobalMouseValues["MouseVector"] = Vector2.new(UISVector.X, UISVector.Y)
		GlobalMouseValues["X"] = UISVector.X
		GlobalMouseValues["Y"] = UISVector.Y
		
		Signals.Move:Fire()
	end
end)

UserInputService.InputBegan:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
		Signals.Button1Down:Fire()
	elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
		Signals.Button2Down:Fire()
	end
end)

UserInputService.InputEnded:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
		Signals.Button1Up:Fire()
	elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
		Signals.Button2Up:Fire()
	end
end)

UserInputService.TouchTapInWorld:Connect(function(Position, GPE)
	--GlobalMouseValues["MouseVector"] = Vector2.new(Position.X + Inset.X, Position.Y + Inset.Y)
	GlobalMouseValues["MouseVector"] = Vector2.new(Position.X, Position.Y)
	GlobalMouseValues["X"] = Position.X
	GlobalMouseValues["Y"] = Position.Y
	
	Signals.Button1Down:Fire()
	Signals.Move:Fire()
	
	RunService.RenderStepped:Wait()
	
	Signals.Button1Up:Fire()
end)

local ReturnCache = {
	["Time"] = 0
}
-- We use these to return the cached RaycastResult info if we're checking within ms of eachother

local function DrawRay(RayParams) -- Function returns a target, and a position.
	if (os.clock() - ReturnCache["Time"]) < 0.02 then
		return ReturnCache["Hit"], ReturnCache["Target"]
	end
	
	local Camera = workspace.CurrentCamera
	local MouseVector = GlobalMouseValues["MouseVector"]
	local Hit, Target
	
	if (not Camera) or (not MouseVector) then
		warn("Camera or MouseVector is nil. Returning.")
		return
	end
	
	local UnitRay = Camera:ViewportPointToRay(MouseVector.X, MouseVector.Y)
	
	local RaycastResult = workspace:Raycast(Camera.CFrame.Position, UnitRay.Direction * 2000, RayParams)
	if RaycastResult then
		Hit = RaycastResult.Position
		Target = RaycastResult.Instance
	else
		Hit = Camera.CFrame.Position + (UnitRay.Direction * 2000)
	end
	
	ReturnCache = {
		["Hit"] = Hit,
		["Target"] = Target,
		["Time"] = os.clock()
	}
	
	return Hit, Target
end

--[[
UserInputService.TouchLongPress:Connect(function(TouchArray, GPE)
	
end)
-- not implementing for now
]]

function Mouse.client(Core)
	Signals.Move = Core.getSignal("MouseMove")
	Signals.Button1Down = Core.getSignal("MouseButton1Down")
	Signals.Button1Up = Core.getSignal("MouseButton1Up")
	Signals.Button2Down = Core.getSignal("MouseButton2Down")
	Signals.Button2Up = Core.getSignal("MouseButton2Up")
	
	Core:addFunction("GetMouse", function()
		local NewMouse = {}
		NewMouse.TargetFilter = {}
		NewMouse.RaycastParams = RaycastParams.new()
		
		setmetatable(NewMouse, {
			__index = function(self, Index)
				if ReturnStandardValues[Index] ~= nil then
					return DefaultMouse[Index]
				elseif Index == "Hit" or Index == "Target" then
					local Hit, Target = DrawRay(self.RaycastParams)
					return (Index == "Hit" and Hit) or Target
				elseif Index == "UIHit" or Index == "VisibleUIHit" then
					local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
					if PlayerGui ~= nil then
						local UIObjs = PlayerGui:GetGuiObjectsAtPosition(GlobalMouseValues["X"], GlobalMouseValues["Y"])
						
						-- visible ui hit code
						if Index == "VisibleUIHit" then
							for i = #UIObjs, 1, -1 do
								local ScreenGui = UIObjs[1]:FindFirstAncestorWhichIsA("ScreenGui")
								if UIObjs[i].Visible == false or ScreenGui == nil or ScreenGui.Enabled == false then
									table.remove(UIObjs, i)
								elseif UIObjs[i].BackgroundTransparency == 1 then
									if (UIObjs[i]:IsA("TextButton") or UIObjs[i]:IsA("TextBox")) and UIObjs[i].TextTransparency == 1 then
										table.remove(UIObjs, i)
									elseif (UIObjs[i]:IsA("ImageLabel") or UIObjs[i]:IsA("ImageButton")) and UIObjs[i].ImageTransparency == 1 then
										table.remove(UIObjs, i)
									elseif UIObjs[i]:IsA("Frame") then
										table.remove(UIObjs, i)
									end
								end
							end
						end
						
						return UIObjs
					else
						warn("PlayerGui is nil.")
						return {}
					end
				elseif GlobalMouseValues[Index] ~= nil then
					return GlobalMouseValues[Index]
				elseif Signals[Index] ~= nil then
					return Signals[Index]
				end
			end,
			__newindex = function(self, Index, Value)
				if ReturnStandardValues[Index] ~= nil then
					DefaultMouse[Index] = Value
				elseif Index == "FilterDescendantsInstances" or Index == "TargetFilter" then
					self.RaycastParams.FilterDescendantsInstances = Value
				elseif Index == "FilterType" then
					self.RaycastParams.FilterType = Value
				end
			end,
		})
		
		return NewMouse
	end)
end

Mouse["ClientRequirements"] = {
	"getSignal"
}

setmetatable(Mouse, {
	__index = function(self, Index)
		warn("Failing attempt to get " .. Index .. " from mouse module. Please use :GetMouse()")
		return nil
	end,
	__newindex = function(self, Index)
		warn("Failing attempt to set " .. Index .. " from mouse module. Please use :GetMouse()")
		return nil
	end,
})

return Mouse
