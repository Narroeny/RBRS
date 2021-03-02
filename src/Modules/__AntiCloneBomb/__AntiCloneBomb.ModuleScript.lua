local module = {}

last2Clones = {}
-- this is used on the client, and just equals the parts
-- a key ["midp"] is included
conf = require(script:WaitForChild("Configuration"))

local function distChk(p1, p2)
	local dist = (p1 - p2).magnitude
	if dist < 0.05 then
		return true
	else
		return false
	end
end

local function calcMid(parts)
	local midp
	for i, v in pairs(parts) do
		if typeof(v) == "Instance" then
			if midp == nil then
				midp = v.Position
			else
				midp = (midp + v.Position)
			end
		end
	end
	midp /= #parts
	return midp
end

function module.f3xHistoryUpdated(coretab)
	local core = require(coretab["core"])
	if not core.isAdmin() then
		local tool, partcount, parts = core.historyUnpack(coretab["newfhist"])
		if tool == "clone" and partcount then
			local midp = calcMid(parts)
			if partcount > conf.Threshold and last2Clones[1] and distChk(calcMid(last2Clones[1]), midp) and last2Clones[2] and distChk(calcMid(last2Clones[2]), midp) then
				coretab["f3x"]:Destroy()
				core.escalateEvent(script, {parts, last2Clones[1], last2Clones[2]})
			end
			if #last2Clones == 2 then
				table.remove(last2Clones, 1)
			end
			table.insert(last2Clones, parts)
		end
	end
end

function module.f3xEquipped(coretab)
	local core = require(coretab["core"])
	local count = 0
	local uis = game:GetService("UserInputService")
	if not core.isAdmin() and coretab["f3x"].Parent == game:GetService("Players").LocalPlayer.Character then -- sanity check
		local ctrlCCon
		ctrlCCon = uis.InputBegan:Connect(function(key, waschat)
			if not waschat and uis:IsKeyDown(Enum.KeyCode.C) and ((uis:IsKeyDown(Enum.KeyCode.LeftShift) or uis:IsKeyDown(Enum.KeyCode.RightShift) or uis:IsKeyDown(Enum.KeyCode.LeftControl) or uis:IsKeyDown(Enum.KeyCode.RightControl))) then
				count += 1
				coroutine.wrap(function()
					wait(1)
					count -= 1
				end)()
				if count > 4 then
					core.escalateEvent(script, {})
				end
			end
		end)
		
		local unequipCon
		unequipCon = coretab["f3x"].Unequipped:Connect(function()
			unequipCon:Disconnect()
			ctrlCCon:Disconnect()
		end)
	end
end

local function verifySecure(p, parts)
	for _, v in pairs(parts) do
		if v.Locked or (v:FindFirstChild("RRPartOwner") and v.RRPartOwner.Value ~= p.Name) then
			return {}
		end
	end
	return parts
end

function module.escalatedEvent(p, allparts)
	local core = require(game:GetService("ReplicatedStorage").raidRoleplay.Assets.Core)
	core.addLog({["Text"] = "Player " .. p.Name .. " has failed the clone bombing check."})
	core.sendNotification("Player " .. p.Name .. " has failed to grief by clone bombing.")
	p:Kick("Please do not spam clones.")
	for _, v in pairs(allparts) do
		local parts = verifySecure(p, v)
		for i, v in pairs(parts) do
			v:Destroy()
		end
	end
end

return module
