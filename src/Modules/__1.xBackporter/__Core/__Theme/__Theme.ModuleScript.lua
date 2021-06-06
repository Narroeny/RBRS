-- This is the themeing engine of raidRoleplay

if not game:GetService("RunService"):IsServer() then
	return {}
end

local mainFold = game:GetService("ReplicatedStorage"):WaitForChild("raidRoleplay")
local assets = mainFold:WaitForChild("Assets")
local ourTheme = script:WaitForChild("ubuntu-dark")

local tbut = ourTheme.TextButton
local tbox = ourTheme.TextBox
local bg = ourTheme.Background
local mtext = ourTheme.MainText
local stext = ourTheme.SubText
local topbar = ourTheme.TopBar
local scroll = ourTheme:FindFirstChild("ScrollingFrame")

local function copyProperties(ref, targ)
	if targ:FindFirstChild("doNotTheme") == nil then
		if targ:IsA("TextBox") or targ:IsA("TextLabel") or targ:IsA("TextButton") then
			targ.TextColor3 = ref.TextColor3
			if ref:FindFirstChildWhichIsA("UITextSizeConstraint") then
				ref:FindFirstChildWhichIsA("UITextSizeConstraint"):Clone().Parent = targ
				targ:FindFirstChildWhichIsA("UITextSizeConstraint").MaxTextSize = targ.TextSize
				targ.TextScaled = true
			end
			targ.TextStrokeColor3 = ref.TextStrokeColor3
			targ.TextStrokeTransparency = ref.TextStrokeTransparency
			targ.TextTransparency = ref.TextTransparency
			targ.Font = ref.Font		
		elseif targ:IsA("ImageLabel") or targ:IsA("ImageButton") then
			targ.Image = ref.Image
			targ.ImageTransparency = ref.Image
			targ.ImageRectOffset = ref.ImageRectOffset
			targ.ImageRectSize = ref.ImageRectSize
			targ.ImageTransparency = ref.ImageTransparency
			targ.ScaleType = ref.ScaleType
			targ.SliceScale = ref.SliceScale
		end
		
		if not ((targ:IsA("Frame") or targ:IsA("ScrollingFrame")) and targ.BackgroundTransparency == 1) then
			targ.BackgroundTransparency = ref.BackgroundTransparency
		end -- we don't want to change the background transparency of invisible frames
		
		if not ref:IsA("Frame") then
			for i, v in pairs(ref:GetChildren()) do
				if targ:FindFirstChildOfClass(v.ClassName) == nil then
					v:Clone().Parent = targ
				end
			end
		end
		
		targ.BackgroundColor3 = ref.BackgroundColor3
		targ.BorderColor3 = ref.BorderColor3
		targ.BorderMode = ref.BorderMode
		targ.BorderSizePixel = ref.BorderSizePixel
		
		if targ:IsA("ScrollingFrame") then
			targ.BottomImage = ref.BottomImage
			targ.MidImage = ref.MidImage
			targ.TopImage = ref.TopImage
			targ.ScrollBarImageColor3 = ref.ScrollBarImageColor3
			targ.VerticalScrollBarInset = ref.VerticalScrollBarInset
		end
	end
end

local function transformUI(target)
	for i, v in pairs(target:GetDescendants()) do
		if v:IsA("TextButton") then
			copyProperties(tbut, v)
		elseif v:IsA("TextBox") then
			copyProperties(tbox, v)
		elseif v:IsA("Frame") then
			copyProperties(bg, v)
		elseif v:IsA("TextLabel") then
			copyProperties(mtext, v)
		elseif v:IsA("ScrollingFrame") and scroll ~= nil then
			copyProperties(scroll, v)
		end
	end
	
	local mFrame = Instance.new("Frame")
	mFrame.Name = target.Name
	mFrame.Parent = target.Parent
	mFrame.Position = target.Position
	mFrame.Size = target.Size
	mFrame.Visible = false
	target.Position = UDim2.new(0, 0, topbar.Size.Y.Scale, topbar.Size.Y.Offset)
	target.Size = UDim2.new(1, 0, 1 - topbar.Size.Y.Scale, -topbar.Size.Y.Offset)
	target.Parent = mFrame
	if topbar:FindFirstChild("TitleBar") ~= nil then
		topbar.TitleBar.Text = target.Parent.Name
	end
	copyProperties(bg, target)
	copyProperties(ourTheme, mFrame)			
	if target.BackgroundTransparency ~= 1 then
		topbar:Clone().Parent = mFrame
	end
end

-- change the logs and notifications
if assets.Core.Logs.Logs:FindFirstChild("Logs") == nil then
	transformUI(assets.Core.Logs.Logs)
end

-- change the modules
for i, v in pairs(mainFold:WaitForChild("Modules"):GetChildren()) do
	for _, frame in pairs(v:GetChildren()) do
		if frame:IsA("Frame") then
			transformUI(frame)
		end
	end
end

local module = {}

return module