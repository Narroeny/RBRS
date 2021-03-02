local module = {}

function module.load(core)
	local status = "walking"
	local conf = require(script:WaitForChild("Configuration"))
	local function pressed()
		local c = game:GetService("Players").LocalPlayer.Character
		if c ~= nil then
			local h = c:FindFirstChild("Humanoid")
			if h ~= nil then
				if status == "walking" then
					status = "running"
					h.WalkSpeed = conf.RunSpeed
				elseif status == "running" then
					status = "walking"
					h.WalkSpeed = conf.WalkSpeed
				end
			end
		end
	end
	core.createUIButton("Toggle Sprint", pressed, "eeef")
end

return module
