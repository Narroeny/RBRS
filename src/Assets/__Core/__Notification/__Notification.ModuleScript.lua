local notification = {}

function notification.load(core)
	local db = game:GetService("Debris")
	local ts = game:GetService("TweenService")
	
	local ev = script:WaitForChild("Notification")
	local coretab = core.getCoreTable()
	local ui = coretab["ui"]
	local notiffold = Instance.new("Folder", ui)
	notiffold.Name = "Notifications"
	
	ev.OnClientEvent:Connect(function(text)
		local newent = script.Entry:Clone()
		newent.Text.Text = text
		for i, v in pairs(notiffold:GetChildren()) do
			v.Position += UDim2.new(0, 0, 0.1, newent.Size.Y.Offset + 2)
		end
		newent.Parent = notiffold
		db:AddItem(newent, 6.5)
	end)
end

function notification.escalatedEvent(p, text)
	local core = require(game:GetService("ReplicatedStorage").raidRoleplay.Assets.Core)
	if p ~= nil then
		text = p.Name .. " " .. text
	end
	for i, v in pairs(game.Players:GetChildren()) do
		if core.isAdmin(v) then
			script.Notification:FireClient(v, text)
		end
	end
end

return notification
