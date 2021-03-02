--[[
This module has the source code to unpack with Remodel for pushing to Git. 
Using this is preferable to ensure compatibility with the current version.
]]

-- CONVERT RBXMX INTO DIRECTORY
-- This unpacks the rbxmx into the ./src directory
local data = remodel.readModelFile('raidRoleplay.rbxmx')
local raidRoleplay = data[1]

local function writeDirectory(inst, directoryName)
	for _, v in pairs(inst:GetChildren()) do
		if v.ClassName == "ModuleScript" or v.ClassName == "Script" or v.ClassName == "LocalScript" then
			if #v:GetChildren() > 0 then
				local newDirectory = directoryName .. "/__" .. v.Name
				remodel.createDirAll(newDirectory)
				remodel.writeFile(newDirectory .. "/__" .. v.Name .. "." .. v.ClassName .. ".lua", remodel.getRawProperty(v, "Source"))
				writeDirectory(v, newDirectory)
			else
				remodel.writeFile(directoryName .. "/" .. v.Name .. "." .. v.ClassName .. ".lua", remodel.getRawProperty(v, "Source"))
			end
		elseif v.ClassName == "Folder" then
			remodel.createDirAll(directoryName .. "/" .. v.Name)
			if #v:GetChildren() > 0 then
				writeDirectory(v, directoryName .. "/" .. v.Name)
			end
		else -- Make it into an rbxmx
			remodel.writeModelFile(v, directoryName .. "/" .. v.Name .. ".rbxmx")
		end
	end
end

pcall(function()
	remodel.isDir("src")
	print("src path already exists! This could mean files could combine.")
end)

remodel.createDirAll("src")
remodel.writeFile("src/raidRoleplay.lua", remodel.getRawProperty(raidRoleplay, "Source"))
writeDirectory(raidRoleplay, "src")