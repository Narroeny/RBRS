local asdf = {}

function asdf.init(core)
	core:addFunction("getSecurityLevel", function()
		return 1
	end)
end

return asdf
