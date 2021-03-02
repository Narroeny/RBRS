local PriorityTable = {}

PriorityTable.__index = function(self, ind)
	if self.trueValues[ind] ~= nil and self.trueValues[ind]["__nonTable"] ~= nil then
		return self.trueValues[ind]["Value"]
	elseif self.trueValues[ind] ~= nil then
		return self.trueValues[ind]
	else
		return PriorityTable[ind]
	end
end

PriorityTable.__newindex = function(self, ind, newEntry)
	local curEntry = self.trueValues[ind]
	
	if typeof(newEntry) == "table" and newEntry["Priority"] == nil then
		newEntry["Priority"] = 1
	end
	-- perform comparisons
	-- this could be one if statement but that would be ugly and kinda confusing
	if typeof(newEntry) ~= "table" then -- we make a special flag to return this value only, since that's prob what they are expecting
		self.trueValues[ind] = {
			["Value"] = newEntry,
			["__nonTable"] = true,
			["Priority"] = 1,
		}
	elseif curEntry == nil or newEntry["Priority"] == nil or curEntry["Priority"] == nil or curEntry["Priority"] <= newEntry["Priority"] then
		if self.__multipleValues and self.__isBaseTable then
			if self.trueValues[ind] == nil then
				self.trueValues[ind] = {}
			end
			table.insert(self.trueValues[ind], newEntry)
		else
			self.trueValues[ind] = newEntry
		end
	else
		return
	end
	self.__changed:Fire(ind, newEntry)
end

function PriorityTable:replace(index, val)
	assert(not self.__multipleValues, "Can not use :replace() with a MultipleValues table.")
	local priority = 1
	if self.trueValues[index] ~= nil and self.trueValues[index]["Priority"] then
		priority = self.trueValues[index]["Priority"]
	end
	if typeof(val) ~= "table" then
		val = {
			val,
			["Priority"] = priority,
		}
	else
		val["Priority"] = priority
	end
	self.trueValues[index] = val
end

function PriorityTable:getpriority(index, numIndex)
	if self.trueValues[index] then
		if self.__multipleValues and numIndex ~= nil and self.trueValues[index][numIndex] then
			return self.trueValues[index][numIndex]["Priority"]
		elseif self.trueValues[index]["Priority"] then
			return self.trueValues[index]["Priority"]
		end
	end
end

function PriorityTable:sort(ind)
	assert(self.trueValues[ind], "Index does not exist in trueValues")
	table.sort(self.trueValues[ind], function(a, b)
		if a["Priority"] ~= nil and (b["Priority"] == nil or a.Priority > b.Priority) then
			return true
		else
			return false
		end
	end)
end

function PriorityTable:get(ind)
	assert(self.__multipleValues, "Can not use :get() with a nonMultipleValues table.")
	if self.trueValues[ind] == nil then
		return {}
	end
	local retTab = {}
	for i, v in pairs(self.trueValues[ind]) do
		if typeof(v) == "table" then
			if v.__nonTable == nil then
				retTab[i] = v
			else
				retTab[i] = v["Value"]
			end
		end
	end

	return retTab
end

function PriorityTable:rawget(ind)
	assert(self.__multipleValues, "Can not use :rawget() with a nonMultipleValues table.")
	if self.trueValues[ind] == nil then
		return {}
	end
	local retTab = {}
	for i, v in pairs(self.trueValues[ind]) do
		if typeof(v) == "table" then
			retTab[i] = v
		end
	end
	return retTab
end

function PriorityTable:remove(ind, index)
	assert(self.__multipleValues, "Can not use :remove() with a nonMultipleValues table.")
	assert(typeof(index) == "number" or typeof(index) == "table", "Second argument (index) must be a number or array.")
	assert(self.trueValues[ind], "Index does not exist in trueValues")
	if typeof(index) == "number" then
		table.remove(self.trueValues[ind], index)
	elseif typeof(index) == "table" then
		table.sort(index)
		local currentOffset = 0
		for _, val in pairs(index) do
			table.remove(self.trueValues[ind], val - currentOffset)
			currentOffset += 1
		end
	end
	self:sort(ind)
end

function PriorityTable:set(ind, index, val)
	assert(self.__multipleValues, "Can not use :set() with a nonMultipleValues table.")
	assert(typeof(index) == "number", "Second argument (index) must be a number.")
	if self.trueValues[ind] == nil then
		self.trueValues[ind] = {}
	end
	local priority = 1
	local currentEntry = rawget(self.trueValues[ind], index)
	
	if currentEntry ~= nil and typeof(currentEntry) == "table" and currentEntry["Priority"] ~= nil then
		priority = currentEntry["Priority"]
	end
	
	if typeof(val) == "table" and val["Priority"] == nil then
		val["Priority"] = priority
	elseif typeof(val) ~= "table" then
		val = {
			["Value"] = val,
			["__nonTable"] = true,
			["Priority"] = priority,
		}
	end
	
	self.trueValues[ind][index] = val
	self:sort(ind)
end

function PriorityTable:insert(ind, value)
	assert(self.__multipleValues, "Can not use :insert() with a nonMultipleValues table.")
	if self.trueValues[ind] == nil then
		self.trueValues[ind] = {}
	end
	self:set(ind, #self.trueValues[ind] + 1, value)
end

function PriorityTable:findfromval(ind, value, valueName, returnmult)
	assert(self.__multipleValues, "Can not use :findfromval() with a nonMultipleValues table.")
	if not self.trueValues[ind] then
		return nil
	end
	if valueName == nil then
		valueName = "Value"
	end
	
	local toret = {}
	for i, v in pairs(self.trueValues[ind]) do
		if typeof(v) == "table" and v[valueName] ~= nil and v[valueName] == value then
			if returnmult then
				table.insert(toret, i)
			else
				return i	
			end
		end
	end
	
	if returnmult then
		return toret
	end
end

function PriorityTable.init(core)
	core:addFunction("wrapPriorityTable", function(tab, multipleVals)
		tab.trueValues = {} -- create our TrueFunctions tab

		for i, v in pairs(tab) do -- Copy existing values over to our trueFunctions table and remove anything else
			if i ~= "trueValues" then
				if typeof(v) ~= "table" then
					v = {
						["Value"] = v,
						["Priority"] = 1,
						["__nonTable"] = true,
					}
				end
				if not multipleVals then
					tab.trueValues[i] = v
				else
					if tab.trueValues[i] == nil then
						tab.trueValues[i] = {}
						tab.trueValues[i].__multipleValues = true
					end
					table.insert(tab.trueValues[i], v)
				end
				tab[i] = nil
			end
		end
		
		tab.__changed = Instance.new("BindableEvent")
		tab.Changed = tab.__changed.Event
		
		if multipleVals then
			tab.__multipleValues = true -- this is for the base table
			tab.__isBaseTable = true
			setmetatable(tab, PriorityTable)
			for i, _ in pairs(tab.trueValues) do
				tab:sort(i)
			end
		else
			setmetatable(tab, PriorityTable)
		end
	end, 1, script:GetFullName())
end

PriorityTable["Description"] = "Allows the developer to create a table where values will only be overwritten based on a priority, or one sorted by priority."
return PriorityTable