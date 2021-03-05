local Slide = {}
-- Table values
Slide.Locked = false -- locks the UI closed

Slide.UIOpen = false -- final "is ui open" variable
Slide.ToggleOpen = false -- for when the button is clicked or something
Slide.CurrentEntered = 0 -- used to tell how many of our UIs have been dragged into

Slide.ClosePosition = nil
Slide.OpenPosition = nil
Slide.Active = false

-- these values are written when this is called
Slide.UI = nil
Slide.Configuration = nil
Slide.Core = nil

function Slide:SlideSizeListener() -- Ensures that the slide is in the proper close position
	self.ClosePosition = UDim2.new(0, -self.UI.AbsoluteSize.X, 0, 0)
	self.UI:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if self.UI.AbsoluteSize.X ~= self.ClosePosition.X.Offset then
			self.ClosePosition = UDim2.new(0, -self.UI.AbsoluteSize.X, 0, 0)
			if not self.UIOpen then
				self.UI.Position = self.ClosePosition
			end
		end
	end)
end

function Slide:UpdateStatus(forcedStatus) -- forcedStatus is true for open, false for closed
	if not self.Locked or forcedStatus ~= nil then
		if (self.ToggleOpen or self.CurrentEntered > 0 or forcedStatus == true) and not self.UIOpen then
			self.UIOpen = true
			self.Core.hideChat()
			self.UI:TweenPosition(self.OpenPosition, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 
				self.Configuration["UISlideTime"] or 0.5, true)
		elseif (((not self.ToggleOpen) and self.CurrentEntered == 0) or forcedStatus == false) and self.UIOpen then
			self.UIOpen = false
			self.Core.showChat()
			self.UI:TweenPosition(self.ClosePosition, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 
				self.Configuration["UISlideTime"] or 0.5, true)
		end
	end
end

function Slide:Activate(openAreas, buttons) -- main function
	-- ensure none of these are invalid
	openAreas = openAreas or {}
	buttons = buttons or {}
	--
	if not self.Active then
		self.Active = true
		self:SlideSizeListener()
		self.OpenPosition = self.UI.Position
		self.UI.Position = self.ClosePosition
		
		for _, item in pairs(openAreas) do -- mouse over areas
			if item:IsA("GuiObject") then
				item.MouseEnter:Connect(function()
					self.CurrentEntered += 1
					self:UpdateStatus()
					item.MouseLeave:Wait()
					self.CurrentEntered -= 1
					self:UpdateStatus()
				end)
			end
		end
		
		for _, item in pairs(buttons) do
			if item:IsA("GuiButton") then
				item.Activated:Connect(function()
					self.ToggleOpen = not self.ToggleOpen
					self:UpdateStatus()
				end)
			end
		end
	end
end

return Slide
