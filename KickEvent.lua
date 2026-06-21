local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
if not player then return end

local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("KickGui")
if oldGui then
	oldGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KickGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(260, 140)
frame.Position = UDim2.fromScale(0.5, 0.45)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local titleBar = Instance.new("TextButton")
titleBar.Size = UDim2.fromOffset(260, 30)
titleBar.Position = UDim2.fromOffset(0, 0)
titleBar.Text = "Kick Event Menu"
titleBar.TextSize = 16
titleBar.TextColor3 = Color3.new(1,1,1)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(30, 30)
closeButton.Position = UDim2.fromOffset(230, 0)
closeButton.Text = "X"
closeButton.TextSize = 16
closeButton.TextColor3 = Color3.new(1,1,1)
closeButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
closeButton.BorderSizePixel = 0
closeButton.Parent = frame

local kickButton = Instance.new("TextButton")
kickButton.Size = UDim2.fromOffset(220, 40)
kickButton.Position = UDim2.fromOffset(20, 50)
kickButton.Text = "Déclencher l'Event"
kickButton.TextSize = 16
kickButton.TextColor3 = Color3.new(1, 1, 1)
kickButton.BackgroundColor3 = Color3.fromRGB(70, 100, 130)
kickButton.BorderSizePixel = 0
kickButton.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.fromOffset(220, 20)
statusLabel.Position = UDim2.fromOffset(20, 100)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Prêt"
statusLabel.TextSize = 14
statusLabel.TextColor3 = Color3.new(1,1,1)
statusLabel.Parent = frame

closeButton.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

local dragging = false
local dragInput, dragStart, startPos

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
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

local function getNetwork()
	local shared = ReplicatedStorage:FindFirstChild("Shared")
	if not shared then return nil end

	local packages = shared:FindFirstChild("Packages")
	if not packages then return nil end

	local network = packages:FindFirstChild("Network")
	if not network then return nil end

	return network
end

local running = false

local function runSequence()
	if running then
		statusLabel.Text = "Déjà en cours"
		return
	end

	running = true
	statusLabel.Text = "Recherche des remotes..."

	local network = getNetwork()
	if not network then
		statusLabel.Text = "Network introuvable"
		running = false
		return
	end

	local kickEvent = network:FindFirstChild("rev_KickEvent")
	local ballEvent = network:FindFirstChild("rev_ballKick")

	if not kickEvent then
		statusLabel.Text = "rev_KickEvent introuvable"
		running = false
		return
	end

	if not ballEvent then
		statusLabel.Text = "rev_ballKick introuvable"
		running = false
		return
	end

	statusLabel.Text = "Envoi rev_KickEvent"
	kickEvent:FireServer(1, 1)

	statusLabel.Text = "Attente 27 sec"
	task.wait(27)

	for i = 100, 1, -1 do
		statusLabel.Text = "rev_ballKick : "..i
		ballEvent:FireServer(i)
		task.wait(0.1)
	end

	statusLabel.Text = "Fini"
	running = false
end

kickButton.MouseButton1Click:Connect(function()
	task.spawn(runSequence)
end)
