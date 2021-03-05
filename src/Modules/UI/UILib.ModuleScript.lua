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
end

return UILibrary
