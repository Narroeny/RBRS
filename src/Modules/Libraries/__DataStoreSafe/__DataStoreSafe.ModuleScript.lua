local DoNotWriteInStudio = false
local PrintWhenRequestOccurs = false -- Use this to debug when your code is making requests

local dataStoreServiceSafe = {}
local dataStoreSafe = {}
dataStoreSafe.__index = dataStoreSafe

local dss = game:GetService("DataStoreService")
local rs = game:GetService("RunService")

dataCache = {}

local function doSafe(targFunc)
	local succ, err, toRet
	local errCode = 0
	local safetyCount = 0
	while not succ do
		succ, err = pcall(function()
			toRet = targFunc()
		end)
		if err then
			warn(err)
			if string.find(err, "4MB limit") then
				errCode = 1
				succ = true -- return so script using dss can fix issue
			elseif string.find(err, "Request was throttled, but throttled request queue") then
				wait(60) -- wait extra if we're spamming datastore for some reason
				safetyCount += 1
				if safetyCount >= 3 then -- If we're still throttled over three minutes:
					-- 1. Fix your code
					-- 2. Return anyways so we stop trying since we're probably going totally haywire right now
					succ = true
				end
				errCode = 2
				-- hopefully we aren't attempting more requests as we wait
			elseif string.find(err, "studio if API access is not enabled") then
				DoNotWriteInStudio = true
				succ = true
				errCode = 3
			elseif string.find(err, "DataStore Request successful, but key not found") then
				succ = true -- same as 4mb limit
				errCode = 4
			else
				wait(7)
			end
		end
	end
	return toRet, errCode, err
end

function dataStoreServiceSafe.server(core)
	--core:addFunction("FireClient", function(self, client, tag, ...)
	core:addFunction("GetDataStore", function(self, datastoreName)
		assert(typeof(self) == "table", 'Please call FireClient with ":" - ' .. core.getCallingScript(getfenv()))
		if PrintWhenRequestOccurs then
			print("GetDataStore " .. datastoreName .. " - " .. core.getCallingScript(getfenv()))
		end
		local newdss = {}
		setmetatable(newdss, dataStoreSafe)
		local ds = doSafe(function()
			return dss:GetDataStore(datastoreName)
		end)
		newdss.DataStore = ds
		return newdss
	end)

	function dataStoreSafe:GetAsync(key)
		if PrintWhenRequestOccurs then
			print("GetAsync " .. key .. " - " .. core.getCallingScript(getfenv()))
		end
		return doSafe(function()
			return self.DataStore:GetAsync(key)
		end)
	end

	function dataStoreSafe:SetAsync(key, value)
		if PrintWhenRequestOccurs then
			print("SetAsync " .. key .. " - " .. core.getCallingScript(getfenv()))
		end
		return doSafe(function()
			if rs:IsStudio() and DoNotWriteInStudio then
				dataCache[key] = value
			else
				self.DataStore:SetAsync(key, value)
			end
			return true
		end)
	end

	function dataStoreSafe:UpdateAsync(key, func)
		if PrintWhenRequestOccurs then
			print("UpdateAsync " .. key .. " - " .. core.getCallingScript(getfenv()))
		end
		doSafe(function()
			if rs:IsStudio() and DoNotWriteInStudio then
				if dataCache[key] == nil then
					local data = self.DataStore:GetAsync(key)
					dataCache[key] = data
				end
				func(dataCache[key])
			else
				self.DataStore:UpdateAsync(key, func)
			end
		end)
	end
end

return dataStoreServiceSafe
