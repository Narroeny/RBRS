local module = {}
local forceprompt = false

local function showTimetext(ui, text, time)
	ui.TextLabel.Visible = true
	ui.TextLabel.Text = text
	wait(time)
	ui.TextLabel.Visible = false
	return
end

local function showText(ui, text)
	ui.TextLabel.Visible = true
	ui.TextLabel.Text = text
end

local function waitForInput(input)
	local inpvalid = false
	local uis = game:GetService("UserInputService")
	uis.InputBegan:Connect(function(_, waschat)
		if not waschat then
			local check = true
			for _, v in pairs(input) do
				local a = uis:IsKeyDown(v)
				if not a then
					check = false
				end
			end
			inpvalid = check
		end
	end)
	while not inpvalid do
		wait(0.1)
	end
	return
end

local function blinkUIRed(ui, time)
	local ts = game:GetService("TweenService")
	ui.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	local tinfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, time, true)
	local t = ts:Create(ui, tinfo, {BackgroundTransparency = 0.3})
	t:Play()
	return
end

function module.escalatedEvent(p, action)
	if action == "take" then
		local dest = script.ToolStorage:FindFirstChild(p.Name)
		if dest == nil then
			dest = Instance.new("Folder", script.ToolStorage)
			dest.Name = p.Name
			for i, v in pairs(p.Backpack:GetChildren()) do
				v.Parent = dest
			end
			local equipped = p.Character:FindFirstChildWhichIsA("Tool")
			if equipped ~= nil then
				equipped.Parent = dest
			end
		end
	elseif action == "give" then
		for i, v in pairs(script.ToolStorage[p.Name]:GetChildren()) do
			v.Parent = p.Backpack
		end
	end
end

local function startTutorialSequence(core, ui, mainUI)
	core.lockUIClosed(true) -- hide ui
	core.escalateEvent(script, "take")
	local lp = game.Players.LocalPlayer
	
	-- reset UI
	local bt = script.btoolsUI:Clone()
	bt.Parent = game:GetService("Players").LocalPlayer.PlayerGui
	mainUI.Visible = true
	bt.Enabled = true
	bt.Dock.Visible = false
	bt.BTMoveToolGUI.Visible = false
	ui.TextLabel.Visible = true
	ui.TextLabel.Text = ""
	bt.Dock.ToolButtons.MoveTool.BackgroundTransparency = 1
	ui.Visible = true
	local part, part2, part3, part4
	
	-- other stuff we need
	local coretab = core.getCoreTable()
	local m = lp:GetMouse()
	local Handles = require(ui.Handles)
	local uis = game:GetService("UserInputService")
	local doEnd = false
	
	local cancelcon
	local cor = coroutine.create(function()
		cancelcon = ui.TextButton.MouseButton1Click:Connect(function()
			cancelcon:Disconnect()
			doEnd = true
			coroutine.yield()
		end)
		
		showTimetext(ui, "Welcome to the raidRoleplay F3X Tutorial.", 3)
		showTimetext(ui, "The first part of F3X building tools you should learn is the dock!", 4)
		bt.Dock.Visible = true
		showTimetext(ui, "The dock of F3X allows you to access every tool provided through F3X.", 5)
		showTimetext(ui, "The dock will first show you each tool in an image form that you can click, as well as a keybind to access it.", 6)
		showText(ui, "As an example, try to access the first tool shown, the Move Tool, by pressing Z.")
		waitForInput({Enum.KeyCode.Z})
		bt.BTMoveToolGUI.Visible = true
		bt.Dock.ToolButtons.MoveTool.BackgroundTransparency = 0
		showTimetext(ui, "As you can see, when you opened the tool, it highlighted the option in the dock, and opened the tool's special interface.", 7)
		showTimetext(ui, "Let's familiarize you with the interface of the Move Tool!", 3.5)
		blinkUIRed(bt.BTMoveToolGUI.AxesOption.Global.Button, 5)
		blinkUIRed(bt.BTMoveToolGUI.AxesOption.Last.Button, 5)
		blinkUIRed(bt.BTMoveToolGUI.AxesOption.Local.Button, 5)
		showTimetext(ui, "The first entry of the list are the axis options. These will control how the parts move when they are in a model.", 6)
		blinkUIRed(bt.BTMoveToolGUI.IncrementOption.Increment.TextBox, 7)
		showTimetext(ui, "The next entry in the list is the Increment, which controls the precision. A lower number will make your building tools more precise.", 8)
		blinkUIRed(bt.BTMoveToolGUI.Info.Center.X.TextBox, 5)
		blinkUIRed(bt.BTMoveToolGUI.Info.Center.Y.TextBox, 5)
		blinkUIRed(bt.BTMoveToolGUI.Info.Center.Z.TextBox, 5)
		showTimetext(ui, "Finally, these are the coordinates for your part. They give you the exact location of your part in the game!", 6)
		showTimetext(ui, "Now, to actually move a part, you must first select a part. The easiest way to do this is to simply click a valid part.", 6)
		local pchar = lp.Character
		part = Instance.new("Part")
		part.Locked = true -- lol!
		if game:GetService("Workspace"):FindFirstChild("raidRoleplayTutorialPart" .. lp.Name) == nil then
			part.CFrame = pchar.HumanoidRootPart.CFrame + pchar.HumanoidRootPart.CFrame.lookVector * 3.5
		else
			part.CFrame = game:GetService("Workspace"):FindFirstChild("raidRoleplayTutorialPart" .. lp.Name).CFrame + Vector3.new(0, 2, 0)
		end
		part.CanCollide = false
		part.Anchored = true
		part.Parent = game:GetService("Workspace")
		
		showText(ui, "A part has been spawned infront of you. Click on it!")
		
		local clickvalid = false
		m.Button1Up:Connect(function()
			if m.Target == part then
				clickvalid = true
			end
		end)
		while not clickvalid do
			wait(0.1)
		end

		local hand = Handles.new({
			Color = Color3.fromRGB(255, 176, 0),
			Parent = coretab["ui"],
			Adornee = part,
		})
		
		ui.BTSelectionBox.Adornee = part
		
		showTimetext(ui, "As you can see, besides highlighting the part, the part now has circular objects around it.", 6)
		showTimetext(ui, 'The circular objects are the "Handles" of your selection, and can be used to drag an object in a specific direction.', 7)
		showTimetext(ui, "Of course, building one part at a time would be very tedious, so there are several ways to select multiple parts at the same time.", 8)
		
		part2 = Instance.new("Part")
		part2.Locked = true -- lol!
		part2.CFrame = part.CFrame + Vector3.new(0, 2, 0)
		part2.CanCollide = false
		part2.Anchored = true
		part2.Parent = game:GetService("Workspace")
		
		showText(ui, "A part has been spawned above the previous part. While holding shift, click on it.")
		
		local clickvalid = false
		m.Button1Up:Connect(function()
			if m.Target == part2 and (uis:IsKeyDown(Enum.KeyCode.LeftShift) or uis:IsKeyDown(Enum.KeyCode.RightShift)) then
				clickvalid = true
			end
		end)
		while not clickvalid do
			wait(0.1)
		end

		local hand2 = Handles.new({
			Color = Color3.fromRGB(255, 176, 0),
			Parent = coretab["ui"],
			Adornee = part2,
		})
		
		ui.BTSelectionBoxTwo.Adornee = part2
		
		showTimetext(ui, "Excellent. You now have both parts selected.", 4)
		showTimetext(ui, "Finally, you can also select parts by clicking and dragging, but to save time, you can practice that on your own.", 6)
		bt.Dock.ToolButtons.MoveTool.BackgroundTransparency = 1
		bt.BTMoveToolGUI.Visible = false
		hand:Destroy()
		hand2:Destroy()
		blinkUIRed(bt.Dock.SelectionButtons.DeleteButton, 5)
		blinkUIRed(bt.Dock.SelectionButtons.CloneButton, 5)
		showTimetext(ui, "Another important feature of F3X are the clone and delete, which are slightly different from the other tools.", 6)
		showTimetext(ui, "These tools, instead of opening a UI, will simply perform their actions when clicked or when their keybinds are pressed.", 7)
		showText(ui, "The keybind for the Clone tool is CTRL + C. Try cloning the two parts you have selected now with the keybind!")
		waitForInput({Enum.KeyCode.LeftControl, Enum.KeyCode.C})
		part3 = part:Clone()
		part4 = part2:Clone()
		part3.Parent = game:GetService("Workspace")
		part4.Parent = game:GetService("Workspace")
		showTimetext(ui, "Great! Your parts have now been cloned. The cloned parts appear in the exact same position as the original parts.", 6)
		local extra1 = ui.BTSelectionBox:Clone()
		local extra2 = ui.BTSelectionBoxTwo:Clone()
		extra1.Adornee = part3
		extra2.Adornee = part4
		extra1.Parent = part3
		extra2.Parent = part4
		showTimetext(ui, "I have automatically selected your original parts. Now, we will delete the parts.", 5)
		showText(ui, "The keybind for the Delete tool is CTRL + X. Use that to delete all of the parts.")
		waitForInput({Enum.KeyCode.X, Enum.KeyCode.LeftControl})
		
		-- cleanup and end
		part:Destroy()
		part2:Destroy()
		part3:Destroy()
		part4:Destroy()
		ui.BTSelectionBox.Adornee = nil
		ui.BTSelectionBoxTwo.Adornee = nil
		extra1:Destroy()
		extra2:Destroy()
		
		showTimetext(ui, "The last thing to note is that if you are confused about what a tool is or how it works, you can simply mouse over it on the dock to see an informational.", 10)
		showTimetext(ui, "This concludes the F3X tutorial. Thanks for sticking through!", 4)
		
		if cancelcon then
			cancelcon:Disconnect()
		end
		
		doEnd = true
	end)
	
	coroutine.resume(cor)
	
	while not doEnd do -- dirty, but this works
		wait(0.1)
	end
	
	ui.Visible = false
	mainUI.Visible = false
	bt.Dock.Visible = false
	bt.Enabled = false
	for _, v in pairs({part, part2, part3, part4}) do
		if v ~= nil then
			v:Destroy()
		end
	end
	core.escalateEvent(script, "give")
	core.unlockUIClosed()
end

function module.load(core)
	local uis = game:GetService("UserInputService")
	if uis.MouseEnabled then -- only launch if we have a mouse
		local coretab = core.getCoreTable()
		local havedone = core.escalateFunction(script, "getdatastore")
		local mainPrompt = script.TutorialPrompt:Clone()
		local prompt = mainPrompt.TutorialPrompt
		local mainUI = script:WaitForChild("Tutorial"):Clone()
		local ui = mainUI:WaitForChild("Tutorial")
		
		mainUI.Visible = false
		mainUI.Parent = coretab["ui"]
		--print(havedone, forceprompt)
		if (not havedone) or (forceprompt) then
			--print("forcing prompt")
			core.lockUIClosed(true)
			mainPrompt.Parent = coretab["ui"]
			mainPrompt.Visible = true
		end
		
		prompt:WaitForChild("Yes").MouseButton1Click:Connect(function()
			mainPrompt:Destroy()
			mainUI.Visible = true
			startTutorialSequence(core, ui, mainUI)
		end)
		
		prompt:WaitForChild("No").MouseButton1Click:Connect(function()
			mainPrompt:Destroy()
			core.unlockUIClosed()
		end)
		
		local pchar = game:GetService("Players").LocalPlayer.Character or game:GetService("Players").LocalPlayer.CharacterAdded:Wait()
		local h = pchar:WaitForChild("Humanoid")
		h.Died:Connect(function()
			core.escalateEvent(script, "destroypart") -- safety checks
			mainUI.Visible = false
		end)
		
		local function startTutorial()
			mainUI.Visible = false
			startTutorialSequence(core, ui, mainUI)
		end
		
		core.createUIButton("F3X Tutorial", startTutorial, "ggggg")
	end
end

function module.escalatedFunction(p, action)
	local hasDone = false
	local succ, err = pcall(function()
		if action == "getdatastore" then
			local dss = game:GetService("DataStoreService")
			local ds = dss:GetDataStore("F3XTutorialPrompt", p.UserId)
			local hasDoneTutorial = ds:GetAsync("HasF3XTutorialPrompted")
			if not hasDoneTutorial then
				ds:SetAsync("HasF3XTutorialPrompted", true)
			else
				hasDone = true
			end
		end
	end)
	if not succ then
		warn(err)
	end
	return hasDone
end

function module.loadServer(core) -- make sure we don't leave any locked parts if the player quits
	game:GetService("Players").PlayerRemoving:Connect(function(p)
		if game:GetService("Workspace"):FindFirstChild(p.Name) ~= nil then
			game:GetService("Workspace")[p.Name]:Destroy()
		end
		if game:GetService("Workspace"):FindFirstChild(p.Name) ~= nil then -- we make two parts so run it twice cuz lazy
			game:GetService("Workspace")[p.Name]:Destroy()
		end
	end)
end

return module
