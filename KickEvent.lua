local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KickGui"
screenGui.Parent = playerGui

local kickButton = Instance.new("TextButton")
kickButton.Size = UDim2.fromScale(0.15, 0.08)
kickButton.Position = UDim2.fromScale(0.42, 0.45)
kickButton.Text = "Déclencher l'Event"
kickButton.TextSize = 14
kickButton.TextColor3 = Color3.new(1, 1, 1)
kickButton.BackgroundColor3 = Color3.new(0.4, 0.5, 0.6)
kickButton.Parent = screenGui

local function callRevBallKick(delayTime)
	task.wait(delayTime)

	local event = ReplicatedStorage.Shared.Packages.Network:FindFirstChild("rev_ballKick")
	if event then
		event:FireServer(100)

		for i = 100, 1, -1 do
			task.wait(0.1)
			event:FireServer(i)
		end
	end
end

local function triggerKickEvent()
	local event = ReplicatedStorage.Shared.Packages.Network:FindFirstChild("rev_KickEvent")
	if event then
		event:FireServer(1, 1)
		callRevBallKick(27)
	else
		warn("rev_KickEvent introuvable")
	end
end

kickButton.MouseButton1Click:Connect(triggerKickEvent)
