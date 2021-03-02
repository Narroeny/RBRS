local module = {}

function module.load(core)
	while true do
		core.sendNotification("test")
		wait(2)
	end
end

return module
