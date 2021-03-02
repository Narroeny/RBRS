--[[
	INSTALL INSTRUCTIONS:
	Firstly, place this script inside of ServerScriptService.
	
	Secondly, move modules and features that you don't care for into the DeactivatedModules folder, and if any modules in there are ones you would
	like, just drop them into Modules!
	
	Configuration for each module should be stored in a configuration folder inside of the module, or in a module script named "Configuration."
	
	raidRoleplay is meant to be modular, so read the documentation and write your own code, or simply install modules created by others into the
	"Modules" folder.
	
	Finally, global configuration for rank ID and such should be in the Configuration folder attached to this script.
	
	Made by r_aidmaster
--]]

-- Safety catch to catch any malignant folders that would mess with the system
local firstcatch = true
local rand = Random.new()
for _, src in pairs({game:GetService("ServerScriptService"), game:GetService("ReplicatedStorage"), game:GetService("StarterGui")}) do
	for _, item in pairs(src:GetChildren()) do
		if (item.Name == "raidRoleplay" or item.Name == "raidRoleplayUI") and item ~= script then
			if firstcatch then
				warn("Malignant raidRoleplay files found.")
				firstcatch = false
				wait(rand:NextNumber(0, 2)) -- This will cause delays, and the early joining players won't get the UI,
				-- but it's better than it not working at all
				if script.Parent == nil then
					break
				end
			end
			warn("Destroying malignant file: " .. item:GetFullName())
			item:Destroy()
		end
	end
end

if script.Parent ~= nil then
	require(script:WaitForChild("Assets"):WaitForChild("Loader")).Main()
end