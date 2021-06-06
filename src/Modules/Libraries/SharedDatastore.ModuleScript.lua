--[[ 
This module manages a table that multiple scripts can write to in order to reduce datastore operations by only using one
key and one set of values for saved data.

Note that this will not perform any extra checks, so if you need to compare values and such, don't use this.

Saving misc data (that doesn't expand) should be done through the "GLOBAL" container, and extraneous player data should be done through the
***string*** of the player's UserId.

Player data saves will automatically be saved and cleaned after the player leaves.

This module has one function, .GetContainer which when passed with the Data name (ex: UserId)
and the Container name (ex: PlayerSettings) will return a table to write in.
]]

local SharedDatastore = {}
SharedDatastore.Data = {}
SharedDatastore.MakingGetRequest = {} -- we mark when we are doing requests to prevent requests from running multiple times

local Players = game:GetService("Players")
local HTTPService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local DataStore

if RunService:IsClient() then
	return {}
end

function SharedDatastore.server(Core)
	DataStore = Core:GetDataStore("SharedData")
	
	Core:addFunction("getDatastoreContainer", function(DataName, ContainerName)
		local ThisDataStore = SharedDatastore.Data[DataName]
		if not ThisDataStore and table.find(SharedDatastore.MakingGetRequest, DataName) then -- wait until we aren't making a request
			while table.find(SharedDatastore.MakingGetRequest, DataName) do
				wait(1)
			end
			ThisDataStore = SharedDatastore.Data[DataName]
		end
		if not ThisDataStore then
			table.insert(SharedDatastore.MakingGetRequest, DataName)
			local ResponseCode, ErrorMessage
			ThisDataStore, ResponseCode, ErrorMessage = DataStore:GetAsync(DataName)
			if ResponseCode ~= 0 then
				warn("uh oh.")
				warn(ResponseCode, ErrorMessage)
				error()
			else
				if ThisDataStore == nil then
					ThisDataStore = {}
				else
					ThisDataStore = HTTPService:JSONDecode(ThisDataStore)
				end
				SharedDatastore.Data[DataName] = ThisDataStore
			end
			table.remove(SharedDatastore.MakingGetRequest, table.find(SharedDatastore.MakingGetRequest, DataName))
		end
		
		if ThisDataStore[ContainerName] ~= nil then
			return ThisDataStore[ContainerName]
		else
			ThisDataStore[ContainerName] = {}
			return ThisDataStore[ContainerName]
		end
	end)
end

-- Data saving related stuff here
local function SaveData(Index)
	-- Compile our data into the datastore form
	local SavingData = {}
	for ContainerName, ContainerData in pairs(SharedDatastore.Data[Index]) do
		SavingData[ContainerName] = {}
		for Index, Value in pairs(ContainerData) do
			SavingData[ContainerName][Index] = Value
		end
	end
	
	DataStore:UpdateAsync(Index, function(OldData)
		if OldData == nil then
			OldData = {}
		else
			OldData = HTTPService:JSONDecode(OldData)
		end
		for ContainerName, Data in pairs(SavingData) do
			if OldData[ContainerName] == nil then
				OldData[ContainerName] = {}
			end
			OldData[ContainerName] = Data
		end
		return HTTPService:JSONEncode(OldData)
	end)
end

local function SaveAll() -- small proxy func
	for ContainerName, _ in pairs(SharedDatastore.Data) do
		SaveData(ContainerName)
	end
end

local Closing = false

-- Normal data save stuff here
coroutine.wrap(function()
	while true do
		wait(60)
		if not Closing then
			print("Auto SaveAll")
			SaveAll()
		end
	end
end)()

game:BindToClose(function()
	Closing = true
	print("Closing SaveAll")
	SaveAll()
end)

-- Special player events now
Players.PlayerRemoving:Connect(function(Player)
	local UID = tostring(Player.UserId)
	local Data = SharedDatastore.Data[UID]
	if (not Closing) and Data then
		print("Calling SaveData")
		SaveData(UID)
		SharedDatastore.Data[UID] = nil
	end
end)

SharedDatastore.ServerRequirements = {
	"GetDataStore"
}


return SharedDatastore