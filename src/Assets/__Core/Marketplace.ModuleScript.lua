-- does donation and get raidRoleplay stuff

local module = {}

function module.load(core)
	local coretab = core.getCoreTable()
	local lp = game:GetService("Players").LocalPlayer
	local ui = coretab["ui"]:WaitForChild("Main")
	local don10 = ui:WaitForChild("10")
	local don50 = ui:WaitForChild("50")
	local don250 = ui:WaitForChild("250")
	local getRR = ui:WaitForChild("getRR")
	local ms = game:GetService("MarketplaceService")
	don10.MouseButton1Click:Connect(function()
		ms:PromptPurchase(lp, 5044368881)
	end)
	don50.MouseButton1Click:Connect(function()
		ms:PromptPurchase(lp, 5044369661)
	end)
	don250.MouseButton1Click:Connect(function()
		ms:PromptPurchase(lp, 5044370017)
	end)
	getRR.MouseButton1Click:Connect(function()
		ms:PromptPurchase(lp, 5069640192)
	end)
end

return module
