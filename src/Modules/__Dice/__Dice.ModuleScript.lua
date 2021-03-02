-- basically just imported from Legacy

local module = {}

local function verifynumber(before, now)
	local now = tonumber(now)
	if now ~= nil then
		if now > 2147483645 then
			now = 2147483645
		elseif now < -2147483645 then
			now = -2147483645
		end
		return now
	else
		return before
	end
end

function module.load(core)
	local coretab = core.getCoreTable()
	local mainui = script:WaitForChild("DiceMenu"):Clone()
	local ui = mainui:WaitForChild("DiceMenu")
	mainui.Parent = coretab["ui"]
	core.makeDraggable(mainui)
	local curmin = 1
	local curmax = 20
	
	local function opendiceui()
		mainui.Visible = true
	end
	
	local settingframes = ui:WaitForChild("SettingsFrames")
	local maxframe = settingframes:WaitForChild("Max")
	local minframe = settingframes:WaitForChild("Min")
	
	mainui:WaitForChild("TopBar"):WaitForChild("CloseButton").MouseButton1Click:Connect(function()
		mainui.Visible = false
	end)
	
	maxframe:WaitForChild("TextBox").FocusLost:Connect(function()
		curmax = verifynumber(curmax, maxframe.TextBox.Text)
		maxframe.TextBox.Text = curmax -- change back to before if number is bad
	end)
	
	minframe:WaitForChild("TextBox").FocusLost:Connect(function()
		curmin = verifynumber(curmin, minframe.TextBox.Text)
		minframe.TextBox.Text = curmin -- change back to before if number is bad
	end)
	
	ui:WaitForChild("Roll").MouseButton1Click:Connect(function()
		curmin = verifynumber(curmin, minframe.TextBox.Text)
		curmax = verifynumber(curmax, maxframe.TextBox.Text)
		minframe.TextBox.Text = curmin
		maxframe.TextBox.Text = curmax
		core.escalateEvent(script, curmin, curmax)
	end)
	
	core.createUIButton("Dice Menu", opendiceui, "ddddd")
end

local function copyProperties(ref, targ)
	if targ:FindFirstChild("doNotTheme") == nil then
		if targ:IsA("TextBox") or targ:IsA("TextLabel") or targ:IsA("TextButton") then
			targ.TextColor3 = ref.TextColor3
			if ref:FindFirstChildWhichIsA("UITextSizeConstraint") then
				ref:FindFirstChildWhichIsA("UITextSizeConstraint"):Clone().Parent = targ
				targ:FindFirstChildWhichIsA("UITextSizeConstraint").MaxTextSize = targ.TextSize
				targ.TextScaled = true
			end
			targ.TextStrokeColor3 = ref.TextStrokeColor3
			targ.TextStrokeTransparency = ref.TextStrokeTransparency
			targ.TextTransparency = ref.TextTransparency
			targ.Font = ref.Font		
		elseif targ:IsA("ImageLabel") or targ:IsA("ImageButton") then
			targ.Image = ref.Image
			targ.ImageTransparency = ref.Image
			targ.ImageRectOffset = ref.ImageRectOffset
			targ.ImageRectSize = ref.ImageRectSize
			targ.ImageTransparency = ref.ImageTransparency
			targ.ScaleType = ref.ScaleType
			targ.SliceScale = ref.SliceScale
		end

		if not ((targ:IsA("Frame") or targ:IsA("ScrollingFrame")) and targ.BackgroundTransparency == 1) then
			targ.BackgroundTransparency = ref.BackgroundTransparency
		end -- we don't want to change the background transparency of invisible frames

		if not ref:IsA("Frame") then
			for i, v in pairs(ref:GetChildren()) do
				if targ:FindFirstChildOfClass(v.ClassName) == nil then
					v:Clone().Parent = targ
				end
			end
		end

		targ.BackgroundColor3 = ref.BackgroundColor3
		targ.BorderColor3 = ref.BorderColor3
		targ.BorderMode = ref.BorderMode
		targ.BorderSizePixel = ref.BorderSizePixel
	end
end

function module.escalatedEvent(p, min, max)
	if not (typeof(min) == "number" and typeof(max) == "number") then
		return
	end
	if min < -2147483645 then
		min = -2147483645
	end
	if max > 2147483645 then
		max = 2147483645
	end
	if min > max then
		local a = min
		min = max
		max = a
	end
	math.randomseed(tick())
	local core = require(game:GetService("ReplicatedStorage").raidRoleplay.Assets.Core)
	local ct = core.getCoreTable()
	local count = 0
	local charch = p.Character:GetChildren()
	local existingd20tabs = {}
	local gui = script.d20gui
	copyProperties(ct.Theme, gui.Background)
	copyProperties(ct.Frame, gui.Frame)
	for i, v in pairs(ct.Frame:GetChildren()) do
		copyProperties(ct.MainText, v)
	end
	local db = game:GetService("Debris")
	for i, v in pairs(charch) do
		if v.Name == "d20gui" then
			count = count + 1
			table.insert(existingd20tabs, v)
		end
	end

	if count < 5 then
		for i, v in pairs(existingd20tabs) do
			v.StudsOffsetWorldSpace = v.StudsOffsetWorldSpace + Vector3.new(0, 2, 0)
		end
		local pgui = gui:Clone()
		pgui.Parent = p.Character
		db:AddItem(pgui, 30)
		pgui.Parent = p.Character
		pgui.Adornee = p.Character.HumanoidRootPart
		local frame = pgui:WaitForChild("Frame")
		local text = frame:WaitForChild("number")
		local text2 = frame:WaitForChild("min")
		local text3 = frame:WaitForChild("max")
		text2.Text = "Min: " .. min
		text3.Text = "Max: " .. max
		text.Text = math.random(min, max)
		for i = 1, 17 do
			local modifier = math.ceil(i / 5)
			local newnumber = math.random(min, max)
			--print(0.05 * modifier)
			wait(0.05 * modifier)
			text.Text = newnumber
		end
		wait(5)
		pgui:Destroy()
	end
end

return module
