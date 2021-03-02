--[[ 
env Core.getCallingEnv(getfenv())
Returns the environment of the function that called the function that called getCallingEnv.
You must call it with getfenv() as the argument.

string Core.getCallingScript(getfenv())
Returns the environment of the function that called the function that called getCallingScript.
You must call it with getfenv() as the argument.

nil Core.loadEnv(getfenv())
loadEnv takes the environment of the calling script, and inserts variables into it responding to various commonly used services.
You must call it with getfenv() as the argument.
These are the variables added:
{
	chat = game:GetService("Chat")
	contentProvider = game:GetService("ContentProvider")
	contextActionService = game:GetService("ContextActionService")
	debris = game:GetService("Debris")
	groupService = game:GetService("GroupService")
	httpService = game:GetService("HTTPService")
	lighting = game:GetService("Lighting")
	players = game:GetService("Players")
	replicatedStorage = game:GetService("ReplicatedStorage")
	runService = game:GetService("RunService")
	starterPack = game:GetService("StarterPack")
	starterPlayer = game:GetService("StarterPlayer")
	teams = game:GetService("Teams")
	tweenService = game:GetService("TweenService")
	
	dataStoreService = game:GetService("dataStoreService")
	serverStorage = game:GetService("ServerStorage") -- Server only
	
	backpack = localPlayer.Backpack -- Client only
	character = localPlayer.Character -- Client only
	localPlayer = players.localPlayer -- Client only
	playerGui = localPlayer.PlayerGui -- Client only
}

script Core.getClientScript(player)
getClientScript returns the LocalScript inside of the player, which is the preferred place to store things such as events that will be
discarded when the player respawns.

If player is not provided, it will either return nil or assume it is LocalPlayer.
]]

return {}