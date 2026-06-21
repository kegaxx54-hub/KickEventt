local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

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
frame.Size = UDim2.fromOffset(320, 240)
frame.Position = UDim2.fromScale(0.5, 0.45)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local titleBar = Instance.new("TextButton")
titleBar.Size = UDim2.fromOffset(320, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
titleBar.BorderSizePixel = 0
titleBar.Text = "Kick Event Menu"
titleBar.TextColor3 = Color3.new(1, 1, 1)
titleBar.TextSize = 16
titleBar.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(30, 30)
closeButton.Position = UDim2.fromOffset(290, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextSize = 16
closeButton.Parent = frame

local runButton = Instance.new("TextButton")
runButton.Size = UDim2.fromOffset(280, 40)
runButton.Position = UDim2.fromOffset(20, 45)
runButton.BackgroundColor3 = Color3.fromRGB(70, 110, 150)
runButton.BorderSizePixel = 0
runButton.Text = "Déclencher l'Event"
runButton.TextColor3 = Color3.new(1, 1, 1)
runButton.TextSize = 16
runButton.Parent = frame

local saveCheckpointButton = Instance.new("TextButton")
saveCheckpointButton.Size = UDim2.fromOffset(135, 36)
saveCheckpointButton.Position = UDim2.fromOffset(20, 95)
saveCheckpointButton.BackgroundColor3 = Color3.fromRGB(60, 140, 80)
saveCheckpointButton.BorderSizePixel = 0
saveCheckpointButton.Text = "Sauver Checkpoint"
saveCheckpointButton.TextColor3 = Color3.new(1, 1, 1)
saveCheckpointButton.TextSize = 14
saveCheckpointButton.Parent = frame

local teleportButton = Instance.new("TextButton")
teleportButton.Size = UDim2.fromOffset(135, 36)
teleportButton.Position = UDim2.fromOffset(165, 95)
teleportButton.BackgroundColor3 = Color3.fromRGB(140, 100, 50)
teleportButton.BorderSizePixel = 0
teleportButton.Text = "TP Checkpoint"
teleportButton.TextColor3 = Color3.new(1, 1, 1)
teleportButton.TextSize = 14
teleportButton.Parent = frame

local coordsLabel = Instance.new("TextLabel")
coordsLabel.Size = UDim2.fromOffset(280, 40)
coordsLabel.Position = UDim2.fromOffset(20, 140)
coordsLabel.BackgroundTransparency = 1
coordsLabel.Text = "Coordonnées : ..."
coordsLabel.TextColor3 = Color3.new(1, 1, 1)
coordsLabel.TextSize = 14
coordsLabel.TextWrapped = true
coordsLabel.TextXAlignment = Enum.TextXAlignment.Left
coordsLabel.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.fromOffset(280, 35)
statusLabel.Position = UDim2.fromOffset(20, 185)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Prêt"
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.TextSize = 14
statusLabel.TextWrapped = true
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

closeButton.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

local dragging = false
local dragStart
local startPos
local dragInput

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

local savedCheckpoint = nil
local running = false

local function getCharacter()
	return player.Character or player.CharacterAdded:Wait()
end

local function getRootPart()
	local character = getCharacter()
	return character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart")
end

RunService.RenderStepped:Connect(function()
	local hrp = getRootPart()
	if hrp then
		local pos = hrp.Position
		coordsLabel.Text = string.format("Coordonnées : X %.2f | Y %.2f | Z %.2f", pos.X, pos.Y, pos.Z)
	end
end)

saveCheckpointButton.MouseButton1Click:Connect(function()
	local hrp = getRootPart()
	if hrp then
		savedCheckpoint = hrp.CFrame
		local pos = hrp.Position
		statusLabel.Text = string.format("Checkpoint sauvé : %.2f, %.2f, %.2f", pos.X, pos.Y, pos.Z)
	end
end)

teleportButton.MouseButton1Click:Connect(function()
	if not savedCheckpoint then
		statusLabel.Text = "Aucun checkpoint sauvé"
		return
	end

	local character = getCharacter()
	if character then
		character:PivotTo(savedCheckpoint)
		statusLabel.Text = "Téléporté au checkpoint"
	end
end)

local function runSequence()
	if running then
		statusLabel.Text = "Déjà en cours"
		return
	end

	running = true
	runButton.Text = "En cours..."

	local shared = ReplicatedStorage:WaitForChild("Shared")
	local packages = shared:WaitForChild("Packages")
	local network = packages:WaitForChild("Network")
	local kickEvent = network:WaitForChild("rev_KickEvent")
	local ballKick = network:WaitForChild("rev_ballKick")

	statusLabel.Text = "TP avant tir"
	local hrp = getRootPart()
	local currentPos = hrp.Position
	hrp.CFrame = CFrame.new(702.90, currentPos.Y, currentPos.Z) * (hrp.CFrame - hrp.Position)

	task.wait(0.2)

	statusLabel.Text = "rev_KickEvent envoyé"
	kickEvent:FireServer(1, 1)

	for t = 27, 1, -1 do
		statusLabel.Text = "Attente " .. t .. "s"
		task.wait(1)
	end

	for i = 100, 1, -1 do
		ballKick:FireServer(i)
		statusLabel.Text = "rev_ballKick(" .. i .. ")"
		task.wait(0.05)
	end

	statusLabel.Text = "Terminé"
	runButton.Text = "Déclencher l'Event"
	running = false
end

runButton.MouseButton1Click:Connect(function()
	task.spawn(runSequence)
end)
