local asdf = {}

function asdf.init(core)
	core:addFunction("getSecurityLevel", function()
		return 0
	end)
end

return asdf
