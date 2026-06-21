local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
if not player then
	return
end

local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("KickEventMenu")
if oldGui then
	oldGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KickEventMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(260, 140)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local titleBar = Instance.new("TextLabel")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.fromOffset(260, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
titleBar.BorderSizePixel = 0
titleBar.Text = "Kick Event Menu"
titleBar.TextColor3 = Color3.new(1, 1, 1)
titleBar.TextSize = 16
titleBar.Font = Enum.Font.SourceSansBold
titleBar.Parent = frame

local runButton = Instance.new("TextButton")
runButton.Name = "RunButton"
runButton.Size = UDim2.fromOffset(220, 40)
runButton.Position = UDim2.fromOffset(20, 50)
runButton.BackgroundColor3 = Color3.fromRGB(60, 120, 80)
runButton.BorderSizePixel = 0
runButton.Text = "Déclencher l'event"
runButton.TextColor3 = Color3.new(1, 1, 1)
runButton.TextSize = 18
runButton.Font = Enum.Font.SourceSansBold
runButton.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.fromOffset(30, 30)
closeButton.Position = UDim2.fromOffset(230, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextSize = 18
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.fromOffset(220, 20)
statusLabel.Position = UDim2.fromOffset(20, 100)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Prêt"
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.SourceSans
statusLabel.Parent = frame

closeButton.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

local dragging = false
local dragStart
local startPos

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

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

local running = false

local function getNetworkFolder()
	local shared = ReplicatedStorage:FindFirstChild("Shared")
	if not shared then return nil end

	local packages = shared:FindFirstChild("Packages")
	if not packages then return nil end

	local network = packages:FindFirstChild("Network")
	if not network then return nil end

	return network
end

local function runScript()
	if running then
		statusLabel.Text = "Déjà en cours..."
		return
	end

	running = true
	runButton.Text = "En cours..."
	statusLabel.Text = "Envoi de rev_KickEvent..."

	local network = getNetworkFolder()
	if not network then
		statusLabel.Text = "Network introuvable"
		runButton.Text = "Déclencher l'event"
		running = false
		return
	end

	local kickEvent = network:FindFirstChild("rev_KickEvent")
	local ballKick = network:FindFirstChild("rev_ballKick")

	if not kickEvent then
		statusLabel.Text = "rev_KickEvent introuvable"
		runButton.Text = "Déclencher l'event"
		running = false
		return
	end

	if not ballKick then
		statusLabel.Text = "rev_ballKick introuvable"
		runButton.Text = "Déclencher l'event"
		running = false
		return
	end

	kickEvent:FireServer(1, 1)
	statusLabel.Text = "Attente 27 secondes..."

	task.wait(27)

	statusLabel.Text = "Boucle de 100 à 1..."

	for i = 100, 1, -1 do
		ballKick:FireServer(i)
		statusLabel.Text = "rev_ballKick: "..i
		task.wait(0.1)
	end

	statusLabel.Text = "Terminé"
	runButton.Text = "Déclencher l'event"
	running = false
end

runButton.MouseButton1Click:Connect(function()
	task.spawn(runScript)
end)
