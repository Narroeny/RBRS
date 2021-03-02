local module = {}

function module.loadServer(core)
	local conf = script:WaitForChild("Configuration")
	local curtime = "day" -- two options, "day" or "night"
	local conf = require(script:WaitForChild("Configuration"))
	local ts = game:GetService("TweenService")
	local timetochange = conf.SecondsOfDay
	
	function changetime() -- flip the time
		local totime
		if curtime == "night" then
			totime = conf.TimeDay
			curtime = "day"
			timetochange = conf.SecondsOfDay
		else
			totime = conf.TimeNight
			curtime = "night"
			timetochange = conf.SecondsOfNight
		end
		local tinfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local t = ts:Create(game:GetService("Lighting"), tinfo, {["ClockTime"] = totime})
		t:Play()
		return
	end
	
	local lasttime = tick() -- for accurate time change because why not
	while true do -- main time loop
		wait(1)
		timetochange = timetochange - (tick() - lasttime) -- more accurate than just wait
		if timetochange <= 0 then
			changetime()
		end
		lasttime = tick()
	end
end

function module.escalatedEvent(p)
	local core = require(game:GetService("ReplicatedStorage").raidRoleplay.Assets.Core)
	local prank = core.getPlayerRank(p)
	local t = core.getUTCTime()
	local conf = require(script:WaitForChild("Configuration"))
	if prank >= conf.RankToSwitch then
		core.addLog({["Text"] = p.Name .. " has manually changed the time of day."})
		changetime()
	end
end

function module.load(core)
	local function xd()
		core.escalateEvent(script)
	end
	local conf = require(script:WaitForChild("Configuration"))
	local prank = core.getPlayerRank(game:GetService("Players").LocalPlayer)
	if prank >= conf.RankToSwitch then
		core.createUIButton("Toggle Day/Night", xd, "ggggg")
	end
end

return module
