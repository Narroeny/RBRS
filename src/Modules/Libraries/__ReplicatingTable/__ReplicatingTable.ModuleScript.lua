local ReplicatingTable = {}
ReplicatingTable.ReplicatedTables = {} -- Used on the server to store tags

local runService = game:GetService("RunService")
local httpService = game:GetService("HttpService")
local players = game:GetService("Players")

ReplicatingTable.__index = function(self, ind)
	if self.__trueValues[ind] ~= nil then
		return self.__trueValues[ind]
	else
		local func
		local succ = pcall(function()
			func = rawget(ReplicatingTable[ind])
		end)
		if not succ then
			return nil
		else
			return func
		end
	end
end

ReplicatingTable.__newindex = function(self, ind, value)
	if typeof(value) ~= "Instance" and typeof(ind) ~= "number" then
		self.__trueValues[ind] = value
		if runService:IsServer() then
			self.__changedEvent:FireAllClients(httpService:JSONEncode(self.__trueValues))
		elseif self.__replicateClient then
			self.__changedEvent:FireServer(httpService:JSONEncode(self.__trueValues))
		end
	elseif typeof(value) == "Instance" then
		warn("Failed attempt to add an instance to index " .. ind)
	else
		warn("Failed attempt to add to ReplicatedTable " .. ind .. " because ind is a number.")
	end
end

function ReplicatingTable:Destroy()
	if runService:IsServer() then
		self.__changedEvent:FireAllClients("DESTROYTAB")
		if self["__changedEvent"] then
			self.__changedEvent:Destroy()
		end
		if self["__changedBind"] then
			self.__changedBind:Destroy()
		end
	end
end

function ReplicatingTable.client(core)
	core:addFunction("wrapReplicatingTable", function(tab, tag)
		local tableData, bindable, event, replicateclient = core:InvokeServer("getReplicatedTable", tag)
		tableData = httpService:JSONDecode(tableData)
		assert(typeof(tableData) == "table", "Failed to get ReplicatingTable, or ReplicatingTable is invalid.")
		
		for i, v in pairs(tab) do -- don't automatically replicate changes
			if tableData[i] == nil then
				tableData[i] = v
				tab[i] = nil
			end
		end
		
		tab.Changed = bindable.Event
		tab.__trueValues = tableData or {}
		tab.__changedBind = bindable
		tab.__replicateClient = replicateclient
		tab.__changedEvent = event
		
		-- now replicate to server, if we do that
		if tab.__replicateClient then
			tab.__changedEvent:FireServer(httpService:JSONEncode(tab.__trueValues))
		end
		
		setmetatable(tab, ReplicatingTable)
		event.OnClientEvent:Connect(function(updatedTab)
			if updatedTab == "DESTROYTAB" then
				setmetatable(tab, {})
				for i, v in pairs(tab.__trueValues) do
					tab[i] = v
				end
				tab.Changed = nil
				tab.__trueValues = nil
				tab.__changedEvent:Destroy()
				tab.__changedBind:Destroy()
				tab.__replicateClient:Destroy()
				tab.__changedEvent = nil
				tab.__changedBind = nil
				tab.__replicateClient = nil
			else
				tab.__trueValues = httpService:JSONDecode(updatedTab)
				tab.__changedBind:Fire()
			end
		end)
	end)
end

function ReplicatingTable.server(core)
	local replicatingTableFolder = Instance.new("Folder", core.env)
	replicatingTableFolder.Name = "ReplicatingTable"
	
	core.createRemoteListener("getReplicatedTable", function(p, tag)
		if ReplicatingTable.ReplicatedTables[tag] == nil then
			wait(1)
			if ReplicatingTable.ReplicatedTables[tag] == nil then
				warn("Failure to get ReplicatingTable " .. tag .. " by " .. p.Name)
			end
		end
		local tab = ReplicatingTable.ReplicatedTables[tag]
		return httpService:JSONEncode(tab.__trueValues), tab.__changedBind, tab.__changedEvent, tab.__replicateClient
	end)
	
	core:addFunction("wrapReplicatingTable", function(tab, tag, allowClientWrite)
		if ReplicatingTable.ReplicatedTables[tag] then
			return ReplicatingTable.ReplicatedTables[tag]
		end
		assert(typeof(tab) == "table", "Invalid table.")
		
		tab.__trueValues = {}
		for i, v in pairs(tab) do
			if i ~= "__trueValues" then
				tab.__trueValues[i] = v
				tab[i] = nil
			end
		end
		
		tab.__replicateClient = allowClientWrite or false
		tab.__changedEvent = Instance.new("RemoteEvent", replicatingTableFolder)
		tab.__changedBind = Instance.new("BindableEvent", replicatingTableFolder)
		tab.Changed = tab.__changedBind.Event
		tab.__changedEvent.OnServerEvent:Connect(function(p, updatetab)
			if tab.__replicateClient then
				tab.__trueValues = httpService:JSONDecode(updatetab)
				for _, plr in pairs(players:GetPlayers()) do
					if plr ~= p then
						tab.__changedEvent:FireClient(httpService:JSONEncode(tab.__trueValues))
					end
				end
				tab.__changedBind:Fire()
			end
		end)
		
		ReplicatingTable.ReplicatedTables[tag] = tab
		setmetatable(tab, ReplicatingTable)
	end)
end

ReplicatingTable["InitRequirements"] = {
	"createRemoteListener",
}

ReplicatingTable["ServerRequirements"] = {
	"FireAllClients",
	"FireClient",
}

ReplicatingTable["ClientRequirements"] = {
	"FireServer",
}

ReplicatingTable["Description"] = "The Replicating Table module allows the developer to make a table that will automatically replicate"
ReplicatingTable["Description"] = ReplicatingTable["Description"] .. " from server to client, and optionally from client to server."

return ReplicatingTable
