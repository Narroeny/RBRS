-- Welcome to raidRoleplay 2.0 (now called "r_aidmaster's Build and Roleplay Suite"

--[[
INSTALLATION INSTRUCTIONS:
EASY:
For easy installation, install/update the RBRS Setup Tool, which will help automatically configure your RBRS installation.
https://www.roblox.com/library/5804626696/raidRoleplay-Updater

ADVANCED:
Configuration options for modules should be directly parented to the module itself. Go through each module, and find the configuration
option inside of it.

For extra help, see the bottom of the Dev Forum post, which can be found in the description of the model.
(There are very strange limitations on how the dev forum link can be posted)
]]

local Assets = script:WaitForChild("Assets")
local Client = Assets:WaitForChild("RBRSClient")
local Modules = script:WaitForChild("Modules")

local assetFold = Instance.new("Folder", game:GetService("ReplicatedStorage"))
assetFold.Name = "RBRS"

local envFolder = Instance.new("Folder", assetFold)
envFolder.Name = "Environment"

for _, v in pairs(script:GetChildren()) do
	v.Parent = assetFold
end

Client.Parent = game:GetService("StarterPlayer"):WaitForChild("StarterCharacterScripts")

local Core = require(Assets:WaitForChild("Core"))
Core:init(Modules)