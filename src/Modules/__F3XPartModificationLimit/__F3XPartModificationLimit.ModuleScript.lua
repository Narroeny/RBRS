local module = {}

function module.getMaxParts(prank)
	local maxparts = 0
	local currank = 0
	for i, v in pairs(require(script.Configuration)) do -- loop through the config
		if i <= prank and i >= currank then -- if the player has a rank less than or equal to the config
			currank = i
			maxparts = v -- set their maxparts
		end
	end
	return maxparts
end

function module.f3xFirstEquipped(coretab) -- when the selection in f3x changes
	local lp = game:GetService("Players").LocalPlayer
	local core = require(coretab["core"])
	local selectionmod = require(coretab["fselect"])
	local prank = core.getPlayerRank()
	local maxparts = module.getMaxParts(prank)
	
	selectionmod.Changed:Connect(function()
		local partcount = #(selectionmod.Parts)
		--print(maxparts)
		--print("stuff")
		-- we have the player's part count, now we can get the limit done
		local toolname, _ = core.historyUnpack(coretab["newfhist"])
		--print(partcount, maxparts)
		--print(maxparts, partcount)
		if maxparts ~= true and partcount > maxparts then -- clear the selection
			--print("should be clearing selection")
			selectionmod:Clear(false)
		end
	end)
end

function module.f3xHistoryUpdated(coretab) -- when the history is updated, this is
	-- to prevent people from spamming new parts (though it's not really too harmful)
	local core = require(coretab["core"])
	local hist = require(coretab["fhist"])
	local histlog = coretab["newfhist"]
	local prank = core.getPlayerRank()
	local maxparts = module.getMaxParts(prank)
	local toolname, partsedited = core.historyUnpack(histlog) -- break down the log
	
	if toolname == "newpart" and maxparts == 0 then -- if a new part was made and they have a limit of 0, send that part
		-- to the shadow realm aka nil
		core.escalateEvent(script, histlog.Part)
	else
		if maxparts ~= true and partsedited > maxparts then -- if the player bypasses the selection limit, remove f3x and add to core noting it,
			-- as well as undoing last record to undo the actio
			-- the bypass is literally spam clicking
			hist.Undo()
			coretab["f3x"].Parent = nil
			core.addLog({["Text"] = game:GetService("Players").LocalPlayer.Name .. " tried to bypass the part selection limit."})
		end
	end
end

function module.escalatedEvent(p, part) -- literally just destroy the part lol!
	part:Destroy()
end

return module
