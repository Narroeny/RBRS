--[[
This code (with remodel on cli) allows you to turn a directory into a rbxmx, to import into Studio.
]]

print("Please ensure you have a build with a RBRS.lua (top script) in the src directory in the running directory")

local path = "src"

local function removefromlist(tab, value)
	for i, v in pairs(tab) do
		if v == value then
			table.remove(tab, i)
		end
	end
end

local function getScriptInfo(name)	
	local a = {}
	for str in string.gmatch(name, "([^.]+)") do
		table.insert(a, str)
	end
	return a[1], a[#a - 1]
end

local function writeChildren(inst, path, children)
	if children == nil then
		children = remodel.readDir(path)
	end
	for i, v in pairs(children) do
		local newPath = path .. "/" .. v
		if remodel.isDir(newPath) and string.find(v, "__") == 1 then
			local scriptChildren = remodel.readDir(newPath)
			for _, search in pairs(scriptChildren) do
				if string.find(search, v .. ".") then
					local name, class = getScriptInfo(search)
					local newscript = Instance.new(class)
					newscript.Parent = inst
					newscript.Name = name:gsub("__", "")
					remodel.setRawProperty(newscript, "Source", "String", remodel.readFile(newPath .. "/" .. search))
					removefromlist(scriptChildren, search)
					writeChildren(newscript, newPath, scriptChildren)
					break
				end
			end
		elseif remodel.isDir(newPath) then
			local newFold = Instance.new("Folder")
			newFold.Name = v
			newFold.Parent = inst
			writeChildren(newFold, newPath)
		elseif string.find(v, ".rbxmx") then
			local info = remodel.readModelFile(newPath)[1]
			info.Parent = inst
		elseif string.find(v, ".lua") then
			local name, classname = getScriptInfo(v)
			local newscript = Instance.new(classname)
			newscript.Name = name
			newscript.Parent = inst
			remodel.setRawProperty(newscript, "Source", "String", remodel.readFile(newPath))
		end
	end
end

local RBRS = Instance.new("Script")
RBRS.Name = "RBRS"
remodel.setRawProperty(RBRS, "Source", "String", remodel.readFile(path .. "/RBRS.lua"))

local children = remodel.readDir(path)
removefromlist(children, "RBRS.lua")
local mainscript = nil

writeChildren(RBRS, path, children)
remodel.writeModelFile(RBRS, "RBRSBuild.rbxmx")