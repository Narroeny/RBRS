local RBRSFold = game:GetService("ReplicatedStorage"):WaitForChild("RBRS")
local modules = RBRSFold:WaitForChild("Modules")
local core = RBRSFold:WaitForChild("Assets"):WaitForChild("Core")

if not game:IsLoaded() then
	game.Loaded:Wait()
end

require(core):init(modules)