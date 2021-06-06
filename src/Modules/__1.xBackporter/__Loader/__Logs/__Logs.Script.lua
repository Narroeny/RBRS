local nowtime = os.date("!*t") -- just to get our timestamp for server start
local envs = game:GetService("ReplicatedStorage"):WaitForChild("raidRoleplay"):WaitForChild("Events")
local reqlogs = envs:WaitForChild("RecieveLogs")
local notifupdate = envs:WaitForChild("LogsUpdated")
local addlogev = envs:WaitForChild("AddLog")
local ssaddlogev = envs:WaitForChild("SSAddLog")
local currentLog = 0

local function gettimetext()
	local nowtime = os.date("!*t") -- just to get our timestamp for server start
	local hr = tostring(nowtime["hour"])
	local min = tostring(nowtime["min"])
	local sec = tostring(nowtime["sec"])
	if #hr == 1 then -- HACK HACK HACK HACK HACK HACK HACK HACK ALERT HACK ALERT HACK ALERT
		hr = "0" .. hr
	end
	if #min == 1 then
		min = "0" .. min
	end
	if #sec == 1 then
		sec = "0" .. sec
	end
	local finaltime = hr .. ":" .. min .. ":" .. sec
	--print(finaltime)
	return tostring(finaltime)
end

local nowtime = gettimetext()
local logtable = {
{["Text"] = "The server, and therefore the logger, was started at " .. nowtime}
}

--[[
log entry:
{["Text"] = log_entry_text, ["Count"] = number for part count search, ["ButtonText"] = undo_text_name, ["Module"] = mod, ["F3XHistoryLog"] = log}
]]

reqlogs.OnServerInvoke = function() return logtable end

local function addlog(p, log)
	--print("logs")
	local t = gettimetext()
	log["Text"] = t .. " | " .. log["Text"]
	log["Player"] = p.Name
	currentLog += 1
	log["ID"] = currentLog
	table.insert(logtable, 1, log)
	if #logtable > 3000 then
		table.remove(logtable, 3001)
	end
	notifupdate:FireAllClients(log)
end

ssaddlogev.Event:Connect(addlog)
addlogev.OnServerEvent:Connect(addlog)