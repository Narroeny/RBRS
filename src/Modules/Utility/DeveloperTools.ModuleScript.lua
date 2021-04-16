-- This module adds one chat command (dumpfunctions), which lists currently active function info.

local DeveloperTools = {}

function DeveloperTools:addModuleCommand(name, command, func, levelreq)
	while self.Core.LoadedModules[name] == nil do
		wait(1)
	end

	self.Core.addChatCommand(command, func, levelreq)
end

function DeveloperTools.init(core)
	DeveloperTools.Core = core
	core.addChatCommand("dumpfunctions", function()
		for i, v in pairs(core.Functions.trueValues) do
			if typeof(i) == "string" and typeof(v) == "table" and v["srcScript"] ~= nil then
				print(i)
				print("		Source: " .. v.srcScript)
				print("		Priority: " .. v.Priority)
			end
		end
	end)
	
	DeveloperTools:addModuleCommand("Attach", "dumpattachments", function()
		if core.LoadedModules["Attach"]["Attachments"] then
			local attachments = core.LoadedModules["Attach"]["Attachments"]
			for _, v in pairs(attachments) do
				if v["__ModuleObject"] then
					print(v["__ModuleObject"]:GetFullName())
					for modifiedfuncName, data in pairs(v) do
						if typeof(data) == "table" and (data["BeforeRun"] or data["Run"] or data["AfterRun"]) then
							print("		" .. modifiedfuncName .. ":")
							if data["BeforeRun"] then
								print("			BeforeRun:")
								for _, func in pairs(data["BeforeRun"]) do
									if func["Creator"] and func["Priority"] then
										print("				Creator: " .. func["Creator"])
										print("				Priority: " .. func["Priority"])
									end
								end
							end
							if data["Run"] then
								print("			Run:")
								print("				Creator: " .. data["Run"][1]["Creator"])
								print("				Priority: " .. data["Run"][1]["Priority"])
							end
							if data["AfterRun"] then
								print("			AfterRun:")
								for _, func in pairs(data["AfterRun"]) do
									if func["Creator"] and func["Priority"] then
										print("				Creator: " .. func["Creator"])
										print("				Priority: " .. func["Priority"])
									end
								end
							end
						end
					end
				end
			end
		end
	end)
end

DeveloperTools["InitRequirements"] = {
	"addChatCommand"
}

return DeveloperTools