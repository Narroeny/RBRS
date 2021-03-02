-- This is simply just internal functions that no module scripts should call.

local module = {}

function module.slidelistener(ui) -- this controls the sliding
	local opentable = {}
	local locked = false
	local open = false
	ui.Position = UDim2.new(-0.10, -2, 0, 0) -- close the ui
	local sg = game:GetService("StarterGui")
	local uis = game:GetService("UserInputService")
	local o1 = ui:WaitForChild("OpenArea") -- get our open areas based upon scale
	local o2 = ui:WaitForChild("OpenArea2")
	local o3 = o2:WaitForChild("OpenButton")
	local o3active = false
	local openlogo = ui:WaitForChild("OpenLogo")
	local chatlocked = false
	local donewanim = true
	local notfirstopen = game:GetService("Players").LocalPlayer:FindFirstChild("raidRoleplayInitiated") -- this controls the animation
	-- to show people the ui exists
	if notfirstopen == nil then 
		local a = Instance.new("BoolValue", game:GetService("Players").LocalPlayer)
		a.Name = "raidRoleplayInitiated"
		local movetab = {0.917, 1.15, 0.917, 1.1, 0.917, 1.05, 0.917, 1, 0.917, 0.95, 0.917, 0.925, 0.917} -- locations
		local timetomove = {0.225, 0.155, 0.2, 0.15, 0.2, 0.1, 0.15, 0.05, 0.1, 0.025, 0.05, 0.0125, 0.025}	
		donewanim = false
		spawn(function()	
			while not donewanim do
				for i, loc in ipairs(movetab) do
					loc = loc + 0.05 -- hack for new ui theme
					local mtime = timetomove[i]
					openlogo:TweenPosition(UDim2.new(loc, 0, 0.4, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, mtime, true)
					wait(mtime)
				end
				wait()
			end
		end)
	end
	
	function dochange(x, evtype) -- this function changes the opentable and does some logic to tell whether
	-- we should open or close the sliding ui
		donewanim = true
		opentable[x] = evtype
		if ((opentable["o1"] or opentable["o2"]) or o3active) and not open and not locked and not uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
			sg:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
			open = true
			ui:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true)
		elseif (not opentable["o1"] and not opentable["o2"] and not o3active and open) or locked then
			open = false
			ui:TweenPosition(UDim2.new(-0.1, -2, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true)
			if not chatlocked then
				sg:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)		
			end
		end
	end
	
	o1.MouseEnter:Connect(function() -- listen for mouse in and out of open areas
		dochange("o1", true)
	end)
	o1.MouseLeave:Connect(function() 
		dochange("o1", false)
	end)
	o2.MouseEnter:Connect(function()
		dochange("o2", true)
	end)
	o2.MouseLeave:Connect(function() -- last one woo
		dochange("o2", false)
	end)
	o3.TouchTap:Connect(function()
		o3active = not o3active -- flip the bool
		dochange("random", false)
	end)
	local ev = script:WaitForChild("UILock")
	ev.Event:Connect(function(a, b) -- if we lock or unlock, do stuff
		locked = a
		chatlocked = b 
		dochange("random", false)
	end)
end

return module
