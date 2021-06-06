local module = {}

DecreaseLogsShown = false

function module.AddLog(log, inv)
	local ui = _G["raidLogUI"]
	local asset = ui.LogEntry
	local core = require(game:GetService("ReplicatedStorage").raidRoleplay.Assets.Core)
	local textfilter = ui.TextSearch.Entry.Text
	local numfilter = tonumber(ui.PartCountSearch.Entry.Text)
	if (textfilter == nil or string.find(log["Text"], textfilter) ~= nil) and (numfilter == nil or (log["Count"]) ~= nil and log["Count"] >= numfilter) then
		ui.LogFrame.CanvasSize = ui.LogFrame.CanvasSize + UDim2.new(0, 0, 0, 25)
		local newentry = asset:Clone()
		local count = #(ui.LogFrame:GetChildren())
		if inv then
			newentry.LayoutOrder = -(count) -- flip the order
		else
			newentry.LayoutOrder = (count)
		end
		newentry.ActionButton.Visible = false -- to me: if we have an action to run along in the button, attach it here	
	
		if log["F3XHistoryLog"] ~= nil and core.isAdmin() then
			local f3xlog = log["F3XHistoryLog"]
			newentry.ActionButton.Visible = true
			local Unapply = require(script.Unapply)
			newentry.ActionButton.MouseButton1Click:Connect(function()
				local toolname, _, parts, special = core.historyUnpack(log["F3XHistoryLog"])
				local infotouse = log["F3XHistoryLog"]
				if log["F3XUndoInformation"] ~= nil then
					--print("Special F3XUndoInformation detected.")
					--Unapply[toolname](log["F3XUndoInformation"])
					infotouse = log["F3XUndoInformation"]
				end
				if Unapply[special] ~= nil then
					Unapply[special](infotouse)
				else
					Unapply[toolname](infotouse)
				end
			end)
		else
			newentry.TextEntry.Size = UDim2.new(0.98, 0, 1, 0) -- size it to full
		end
		newentry.TextEntry.Text = log["Text"]
		newentry.Visible = true
		newentry.Parent = ui.LogFrame
		
		if #(ui.LogFrame:GetChildren()) > 350 and DecreaseLogsShown then
			module.RequestLogReload()
		end
	end
end

function module.GenerateLogs(logs)
	-- first, we need to clear the logs we already have
	local ui = _G["raidLogUI"]
	for i, v in pairs(ui.LogFrame:GetChildren()) do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
	
	-- start generation
	local asset = ui.LogEntry
	ui.LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	for i, v in ipairs(logs) do -- loop through the logs
		module.AddLog(v, false)		
		if DecreaseLogsShown and i >= 200 then
			break
		end
	end
end

function module.RequestLogReload() -- this function requests the logs from the server, and then reloads the logs
	--print("*loads logs or something here*")
	local ev = game:GetService("ReplicatedStorage"):WaitForChild("raidRoleplay"):WaitForChild("Events"):WaitForChild("RecieveLogs")
	local logs = ev:InvokeServer()
	_G["raidRPLogTable"] = logs
	module.GenerateLogs(logs)
end

function module.Load(core) -- load module
	local coretab = core.getCoreTable()
	local ui = coretab["ui"] -- get our ui
	local logsui = script:WaitForChild("Logs"):Clone()
	logsui.Parent = game.Workspace
	core.makeDraggable(logsui)
	local newlogsui = logsui.Logs
	local uis = game:GetService("UserInputService")
	local textfilter = nil
	local partcountfilter = nil
	local textsearchbox = newlogsui:WaitForChild("TextSearch"):WaitForChild("Entry")
	local partcountsearchbox = newlogsui:WaitForChild("PartCountSearch"):WaitForChild("Entry")
	_G["raidRPLogTable"] = {}
	logsui.Parent = ui -- and then move into it
	_G["raidLogUI"] = newlogsui
	local function openlogs() -- this is our open logs function
		logsui.Visible = true
		module.RequestLogReload(_G["raidRPLogTable"]) -- reload and update our logs when opened automatically
	end
	
	local decreaselogs = core.createToggle(newlogsui:WaitForChild("CheckBoxes"):WaitForChild("LimitLogCountToggle"))
	decreaselogs.MouseButton1Click:Connect(function()
		DecreaseLogsShown = decreaselogs.Status
		module.RequestLogReload()
	end)
	local updateenv = coretab["mainfold"]:WaitForChild("Events"):WaitForChild("LogsUpdated")
	updateenv.OnClientEvent:Connect(function(log) -- whenever the logs are updated, check if the ui is open, and if so, update
		table.insert(_G["raidRPLogTable"], log)
		if logsui.Visible then
			local textfilter = newlogsui.TextSearch.Entry.Text
			local numfilter = tonumber(newlogsui.PartCountSearch.Entry.Text)
			if (textfilter == nil or string.find(log["Text"], textfilter) ~= nil) and (numfilter == nil or (log["Count"]) ~= nil and log["Count"] >= numfilter) then
				module.AddLog(log, true)
			end
		end
	end)
		
	logsui.TopBar.CloseButton.MouseButton1Click:Connect(function()
		--print("did we click yet")
		logsui.Visible = false
	end)
	
	local function filterupdate()
		if (textsearchbox.Text ~= textfilter or partcountsearchbox.Text ~= partcountfilter) then 
			-- if the log was visible, enter was pressed, it wasn't chat, and if one of the boxes have changed
			-- time to filter
			module.RequestLogReload() -- if something changed, update the filter
		end
	end
	
	uis.InputBegan:Connect(function(key) -- we don't actually have to worry about chat since we are testing to see
		-- if there was an actual change
		if logsui.Visible == true and key.KeyCode == Enum.KeyCode.Return then
			filterupdate()
		end
	end)
	
	core.createUIButton("Logs", openlogs, "zzzzz") -- create our ui button
end

return module
