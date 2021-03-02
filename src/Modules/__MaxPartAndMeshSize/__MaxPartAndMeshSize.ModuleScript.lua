local module = {}
-- verifies that the scale and offset of a part / mesh isn't too large
local conf = require(script.Configuration)

--[[	for i, v in pairs(part:GetDescendants()) do
	if v:IsA("BasePart") or v:IsA("UnionOperation") then]]

local function verifyScale(mesh)
	local scale = mesh.Scale
	local newX = scale.X
	local newY = scale.Y
	local newZ = scale.Z
	if scale.X > conf.maxMeshScale.X then
		newX = conf.maxMeshScale.X
	end
	if scale.Y > conf.maxMeshScale.Y then
		newY = conf.maxMeshScale.Y
	end
	if scale.Z > conf.maxMeshScale.Z then
		newZ = conf.maxMeshScale.Z
	end
	local newsize = Vector3.new(newX, newY, newZ)
	if newsize ~= mesh.Scale then
		mesh.Scale = Vector3.new(newX, newY, newZ)
		return true
	else
		return false
	end
end

local function verifySize(part)
	local size = part.Size
	local newX = size.X
	local newY = size.Y
	local newZ = size.Z
	if size.X > conf.maxPartSize.X then
		newX = conf.maxPartSize.X
	end
	if size.Y > conf.maxPartSize.Y then
		newY = conf.maxPartSize.Y
	end
	if size.Z > conf.maxPartSize.Z then
		newZ = conf.maxPartSize.Z
	end
	local newsize = Vector3.new(newX, newY, newZ)
	if newsize ~= part.Size then
		part.Size = Vector3.new(newX, newY, newZ)
		return true
	else
		return false
	end
end

local function check(inst)
	if inst:IsA("BasePart") or inst:IsA("UnionOperation") then
		return verifySize(inst)
	elseif inst:IsA("SpecialMesh") then
		return verifyScale(inst)
	end
end

function module.escalatedEvent(p, allparts)
	local core = require(game:GetService("ReplicatedStorage").raidRoleplay.Assets.Core)
	local violations = 0
	if allparts ~= nil then
		for _, v in ipairs(allparts) do
			for _, z in ipairs(v:GetDescendants()) do
				local returncode = check(z)
				if returncode == true then
					violations += 1
				end
			end
			local returncode = check(v)
			if returncode == true then
				violations += 1
			end
		end
		if violations >= 1 then
			core.addLog({["Text"] = p.Name .. " has tried to oversize " .. violations .. " objects."})
		end
	end
end

function module.f3xHistoryUpdated(coretab)
	local newhist = coretab["newfhist"]
	local core = require(coretab["core"])
	local toolname, partcount, allparts, special = core.historyUnpack(newhist)
	local prank = core.getPlayerRank()
	if not core.isAdmin() and not (prank > conf.rankToBypass) then
		if special == "Mesh Edit" or toolname == "Resize Tool" then
			core.escalateEvent(script, allparts)
		end
	end
end

return module
