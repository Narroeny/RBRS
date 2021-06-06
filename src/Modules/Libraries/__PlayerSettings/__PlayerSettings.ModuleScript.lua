--[[ This module acts as a way to save configuration options. It provides one function:

PSettings:GetContainer(name) -- Returns a table that can be written to / read from

]]

local PSettings = {}
PSettings.Settings = {}

local GetData = script:WaitForChild("GetData")
local WriteData = script:WaitForChild("WriteData")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if RunService:IsServer() then
	return {}
end

local mt = {}
mt.__index = function(self, Ind)
	local Succ, Err = pcall(function()
		rawget(self, "__trueOptions")
	end)
	if not Succ then
		warn(Err)
	else
		return self["__trueOptions"][Ind]
	end
end

mt.__newindex = function(self, Ind, Val)
	local Succ, Err = pcall(function()
		self["__trueOptions"][Ind] = Val
		
		-- Compile our data into the datastore form
		local SavingData = {}
		for ContainerName, ContainerData in pairs(PSettings.Settings) do
			SavingData[ContainerName] = {}
			for Index, Value in pairs(ContainerData.__trueOptions) do
				SavingData[ContainerName][Index] = Value
			end
		end
		
		SavingData["__trueOptions"] = nil
		
		WriteData:FireServer(SavingData)
	end)
	if not Succ then
		warn(Err)
	end
end

function PSettings.client(Core)
	Core:addFunction("getSettingsContainer", function(Name)
		if PSettings.Settings[Name] ~= nil then
			return PSettings.Settings[Name]
		else
			PSettings.Settings[Name] = {
				["__trueOptions"] = {}
			}
			setmetatable(PSettings.Settings[Name], mt)
			return PSettings.Settings[Name]
		end
	end)
end

-- Get and compile our current data
local OurData = GetData:InvokeServer()

for ContName, Data in pairs(OurData) do
	local Container = PSettings:GetContainer(ContName)
	
	for Ind, Val in pairs(Data) do
		rawset(Container["__trueOptions"], Ind, Val)
	end
end


return PSettings