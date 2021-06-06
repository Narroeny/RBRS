local module = {}

function module.Main() -- loading stuff
	local main = script.Parent
	-- make some folders and unpack
	local mainfold = Instance.new("Folder", game:GetService("ReplicatedStorage"))
	mainfold.Name = "raidRoleplay"
	local assets = Instance.new("Folder", mainfold)
	assets.Name = "Assets"
	local Core = script.Parent:WaitForChild("Core")
	Core.Parent = assets
	
	local remfold = Instance.new("Folder", mainfold)
	remfold.Name = "Events"
	
	local mods = main:WaitForChild("Modules")
	mods.Parent = mainfold
	
	local ssfold = Instance.new("Folder", game:GetService("ServerScriptService"))
	ssfold.Name = "raidRoleplay"
	local logscript = script:WaitForChild("Logs")
	local serverendpoint = script:WaitForChild("ServerEndpoint")
	
	local ev3 = logscript:WaitForChild("AddLog")
	local ev4 = logscript:WaitForChild("RecieveLogs")
	local ev5 = logscript:WaitForChild("LogsUpdated")
	local ev6 = logscript:WaitForChild("SSAddLog")
	
	for i, v in pairs({ev3, ev4, ev5, ev6}) do
		v.Parent = remfold
	end	
	
	logscript.Parent = ssfold
	logscript.Disabled = false
	serverendpoint.Parent = ssfold
	serverendpoint.Disabled = false
	
	require(Core:WaitForChild("Theme"))
	
	return
end

return module
