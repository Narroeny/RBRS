local module = {}

function module.Main() -- loading stuff
	local main = script.Parent.Parent
	local assets = script.Parent -- get assets
	local ui = script:WaitForChild("raidRoleplayUI")
	-- make some folders and unpack
	local mainfold = Instance.new("Folder", game:GetService("ReplicatedStorage"))
	mainfold.Name = "raidRoleplay"
	assets.Parent = mainfold
	ui.Parent = game:GetService("StarterGui")
	
	local remfold = Instance.new("Folder", mainfold)
	remfold.Name = "Events"
	
	local mods = main:WaitForChild("Modules")
	mods.Parent = mainfold
	
	local themes = main:WaitForChild("Themes")
	themes.Parent = mainfold
	
	local config = main:WaitForChild("Configuration")
	config.Parent = mainfold
	
	local gicon = main:WaitForChild("GroupLogo")
	if gicon.Image == "" then -- move the scrolling frame if invalid image
		ui.Main.ScrollingFrame.Size = UDim2.new(0.895, 0, 0.83, 0)
		ui.Main.ScrollingFrame.Position = UDim2.new(0.05, 0, 0.02, 0)
	else
		gicon.Parent = ui:WaitForChild("Main")
	end
	
	local ssfold = Instance.new("Folder", game:GetService("ServerScriptService"))
	ssfold.Name = "raidRoleplay"
	local escalate = script:WaitForChild("ServerEscalation")
	local logscript = script:WaitForChild("Logs")
	local serverendpoint = script:WaitForChild("ServerEndpoint")
	
	local ev1 = escalate:WaitForChild("EscalateEvent")
	local ev2 = escalate:WaitForChild("EscalateFunc")
	local ev3 = logscript:WaitForChild("AddLog")
	local ev4 = logscript:WaitForChild("RecieveLogs")
	local ev5 = logscript:WaitForChild("LogsUpdated")
	local ev6 = logscript:WaitForChild("SSAddLog")
	
	for i, v in pairs({ev1, ev2, ev3, ev4, ev5, ev6}) do
		v.Parent = remfold
	end	
	
	escalate.Parent = ssfold
	escalate.Disabled = false
	logscript.Parent = ssfold
	logscript.Disabled = false
	serverendpoint.Parent = ssfold
	serverendpoint.Disabled = false
	
	return
end

return module
