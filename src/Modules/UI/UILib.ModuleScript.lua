-- This module provides a large amount of functions for creating / managing UI elements.

local UILibrary = {}

function UILibrary.client(core)
	core.loadEnv(getfenv())
	
	core:addFunction("hideChat", function()
		starterGui:SetCore("ChatActive", false)
	end)
	
	core:addFunction("showChat", function()
		starterGui:SetCore("ChatActive", true)
	end)
	
	core:addFunction("calculateScrollSize", function(scrollFrame, padding, disableX) 
		-- Calculates the size the scrolling frame needs to be
		local minX = 9999
		local minY = 9999
		local maxX = -9999
		local maxY = -9999
		for _, obj in pairs(scrollFrame:GetDescendants()) do
			if obj:IsA("GuiObject") and obj.Visible then
				if (obj.AbsolutePosition.X + obj.AbsoluteSize.X) > maxX then
					maxX = obj.AbsolutePosition.X + obj.AbsoluteSize.X
				end
				if (obj.AbsolutePosition.Y + obj.AbsoluteSize.Y) > maxY then
					maxY = obj.AbsolutePosition.Y + obj.AbsoluteSize.Y
				end
				if obj.AbsolutePosition.X < minX then
					minX = obj.AbsolutePosition.X
				end
				if obj.AbsolutePosition.Y < minY then
					minY = obj.AbsolutePosition.Y
				end
			end
		end
		if disableX then
			maxX = 0
			minX = 0
		end
		scrollFrame.CanvasSize = UDim2.new(0, maxX - minX, 0, maxY - minY + (padding or 0))
	end)
	
	core:addFunction("enforceUIBounds", function(frame, moveFrame)
		assert(typeof(frame) == "Instance" and frame:IsA("Frame"), "Invalid frame sent to checkUIBounds by " 
			.. core.getCallingScript(getfenv()))
		
		if moveFrame == nil then
			moveFrame = frame
		end
		
		local inset = guiService:GetGuiInset()
		if frame.AbsolutePosition.X < 0 then
			moveFrame.Position += UDim2.new(0, -frame.AbsolutePosition.X, 0, 0)
		elseif frame.AbsolutePosition.X + frame.AbsoluteSize.X > mouse.ViewSizeX then
			moveFrame.Position = UDim2.new(0, mouse.ViewSizeX - frame.AbsoluteSize.X, 
				frame.Position.Y.Scale, frame.Position.X.Offset) 
		end
		if frame.AbsolutePosition.Y < 0 then
			moveFrame.Position += UDim2.new(0, 0, 0, -frame.AbsolutePosition.Y)
		elseif frame.AbsolutePosition.Y + frame.AbsoluteSize.Y > mouse.ViewSizeY then
			moveFrame.Position = UDim2.new(frame.Position.X.Scale, frame.Position.X.Offset, 
				0, mouse.ViewSizeY + inset.Y - frame.AbsoluteSize.Y) 
		end
	end)
	
	core:addFunction("enableDragging", function(dragFrame, dragHitbox, extentsObject) 
		-- allows a UI to be dragged on mobile and desktop
		assert(typeof(dragFrame) == "Instance" and dragFrame:IsA("GuiObject"), 
			"Invalid dragging frame sent by " .. core.getCallingScript(getfenv()))
		if dragHitbox == nil then
			dragHitbox = dragFrame
		end
		if extentsObject == nil then
			extentsObject = dragFrame
		end
		
		local dragging = false
		local startPos, dragStart, inputObj, uiOffsetX, uiOffsetY
		
		dragHitbox.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch and not dragging then
				dragging = true
				dragStart = inp.Position
				startPos = dragFrame.Position
				uiOffsetX = math.abs(inp.Position.X - dragHitbox.AbsolutePosition.X)
				uiOffsetY = math.abs(inp.Position.Y - dragHitbox.AbsolutePosition.Y)
			end		
			
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end)
		
		dragHitbox.InputChanged:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch and dragging then
				inputObj = inp
			end
		end)
		
		userInputService.InputChanged:Connect(function(inp)
			if inp == inputObj and dragging then
				local d = inp.Position - dragStart
				local inset = guiService:GetGuiInset()
				if (inp.Position.X - uiOffsetX) < 0 then
					d = Vector2.new(-dragStart.X + uiOffsetX, d.Y)
				elseif (inp.Position.X + (extentsObject.AbsoluteSize.X - uiOffsetX)) > (mouse.ViewSizeX) then
					d = Vector2.new(mouse.ViewSizeX - dragStart.X - (extentsObject.AbsoluteSize.X - uiOffsetX), d.Y)
					-- dragStart.X, + uiOffsetX
				end
				if (inp.Position.Y - uiOffsetY) < 0 then
					d = Vector2.new(d.X, -dragStart.Y + uiOffsetY)
				elseif (inp.Position.Y + (extentsObject.AbsoluteSize.Y - uiOffsetY)) > (mouse.ViewSizeY + inset.Y) then
					d = Vector2.new(d.X, mouse.ViewSizeY + inset.Y - dragStart.Y - (extentsObject.AbsoluteSize.Y - uiOffsetY))
				end
				dragFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end)
	end)	
end

return UILibrary
