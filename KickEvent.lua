local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
if not player then
	return
end

local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("KickLoopGui")
if oldGui then
	oldGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KickLoopGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.fromOffset(300, 140)
frame.Position = UDim2.fromScale(0.5, 0.45)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local titleBar = Instance.new("TextButton")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.fromOffset(300, 30)
titleBar.Position = UDim2.fromOffset(0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
titleBar.BorderSizePixel = 0
titleBar.Text = "BallKick Loop"
titleBar.TextColor3 = Color3.new(1, 1, 1)
titleBar.TextSize = 16
titleBar.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.fromOffset(30, 30)
closeButton.Position = UDim2.fromOffset(270, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextSize = 16
closeButton.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.fromOffset(260, 45)
toggleButton.Position = UDim2.fromOffset(20, 48)
toggleButton.BackgroundColor3 = Color3.fromRGB(140, 50, 50)
toggleButton.BorderSizePixel = 0
toggleButton.Text = "Loop OFF"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.TextSize = 18
toggleButton.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.fromOffset(260, 24)
statusLabel.Position = UDim2.fromOffset(20, 102)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Prêt"
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.TextSize = 14
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

titleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input == dragInput then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

local shared = ReplicatedStorage:WaitForChild("Shared")
local packages = shared:WaitForChild("Packages")
local network = packages:WaitForChild("Network")
local ballKick = network:WaitForChild("rev_ballKick")

local running = false
local loopThread = nil

local function stopLoop()
	running = false
	toggleButton.Text = "Loop OFF"
	toggleButton.BackgroundColor3 = Color3.fromRGB(140, 50, 50)
	statusLabel.Text = "Loop arrêtée"

	if loopThread then
		task.cancel(loopThread)
		loopThread = nil
	end
end

local function startLoop()
	if running then
		return
	end

	running = true
	toggleButton.Text = "Loop ON"
	toggleButton.BackgroundColor3 = Color3.fromRGB(50, 140, 70)
	statusLabel.Text = "Loop démarrée"

	loopThread = task.spawn(function()
		while running do
			for i = 100, 0, -1 do
				if not running then
					break
				end

				ballKick:FireServer(i)
				statusLabel.Text = "rev_ballKick(" .. i .. ")"
				task.wait(0.018)
			end

			task.wait(0.03)
		end
	end)
end

toggleButton.MouseButton1Click:Connect(function()
	if running then
		stopLoop()
	else
		startLoop()
	end
end)

closeButton.MouseButton1Click:Connect(function()
	stopLoop()
	screenGui:Destroy()
end)
