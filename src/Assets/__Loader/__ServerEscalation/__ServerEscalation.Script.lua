local repfold = game:GetService("ReplicatedStorage"):WaitForChild("raidRoleplay")
local events = repfold:WaitForChild("Events")
local ev = events:WaitForChild("EscalateEvent")
local ev2 = events:WaitForChild("EscalateFunc")
local modulesfold = repfold:WaitForChild("Modules")
local coremod = repfold:WaitForChild("Assets"):WaitForChild("Core")
local core = require(coremod)
local rs = game:GetService("RunService")

ev.OnServerEvent:Connect(function(p, module, ...) -- call the module with the passed arguments
	if module ~= nil and typeof(module) == "Instance" and module:IsA("ModuleScript") and (module.Parent == modulesfold or module.Parent == coremod) then
		local m = require(module)
		if m.escalatedEvent ~= nil then
			return m.escalatedEvent(p, ...)	
		else
			warn("escalateEvent call had no corresponding escalatedEvent.") -- provide some warnings so that there's output incase if bad
		end
	else
		warn("escalateEvent call gave an invalid module.")
	end
end)

local function oninvoke(p, module, ...) -- call the module with the passed arguments, function edition
	if module ~= nil and typeof(module) == "Instance" and module:IsA("ModuleScript") and (module.Parent == modulesfold or module.Parent == coremod) then
		local m = require(module)
		if m.escalatedFunction ~= nil then
			--print("We are granting access.")
			return m.escalatedFunction(p, ...)
		else
			warn("escalateFunction call had no corresponding escalatedFunction.")
		end
	else
		warn("escalateFunction call gave an invalid module.")
	end
	return nil
end

ev2.OnServerInvoke = oninvoke

-- initiate modules with loadServer()
for i, v in pairs(modulesfold:GetChildren()) do
	if v:IsA("ModuleScript") then -- check and see if we have a module
		if rs:IsStudio() then
			spawn(function()
				local newmod = require(v)
				if newmod.loadServer ~= nil then
					newmod.loadServer(core) -- if we have a load function, run it
				end
			end)
		else
			coroutine.wrap(function()
				local newmod = require(v)
				if newmod.loadServer ~= nil then
					newmod.loadServer(core) -- if we have a load function, run it
				end
			end)()
		end
	end
end


local http = game:GetService("HttpService")
local version = core.getVer()
local coretable = core.getCoreTable()
local allmods = ""
for i, v in pairs(coretable["modules"]:GetChildren()) do
	allmods = allmods .. v.Name .. ", "
end

pcall(function()
	local data = {
	['content'] = "PLACE LINK: https://www.roblox.com/games/" .. game.PlaceId ..  "\nVERSION: " .. version .. "\nLOADED MODULES: " .. allmods,
	['username'] = "raidRoleplay Metrics",
	}

	data = http:JSONEncode(data)

	http:PostAsync("https://discordapp.com/api/webhooks/716164697463849020/8_5ClJaiyTnSujKvxfkVUIvMf-JYjuUIDZjU16nMPrD86vpsc-XsjbLmWTE5_u8z7Cyp", data)
end)