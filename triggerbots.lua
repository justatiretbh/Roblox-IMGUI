-- Triggerbot System (Modular)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Triggerbot = {}
Triggerbot.Enabled = false
Triggerbot.Delay = 0.05
Triggerbot.FOV = 20
Triggerbot.TeamCheck = true

local lastTrigger = 0

local function isAlive(player)
	local char = player.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	return hum and hum.Health > 0
end

local function isEnemy(player)
	if player == LocalPlayer then return false end
	if not Triggerbot.TeamCheck then return true end
	local myTeam, theirTeam = LocalPlayer.Team, player.Team
	if not myTeam or not theirTeam then return true end
	return myTeam ~= theirTeam
end

local function getClosest()
	local closest, closestDist = nil, Triggerbot.FOV
	local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

	for _, player in ipairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end
		if not isAlive(player) then continue end
		if Triggerbot.TeamCheck and not isEnemy(player) then continue end

		local char = player.Character
		local head = char:FindFirstChild("Head")
		if not head then continue end

		local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
		if not onScreen then continue end

		local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
		if dist < closestDist then
			closestDist = dist
			closest = player
		end
	end
	return closest
end

function Triggerbot.Update()
	if not Triggerbot.Enabled then return end
	if tick() - lastTrigger < Triggerbot.Delay then return end

	local target = getClosest()
	if target then
		pcall(function()
			mouse1press()
			task.wait(0.012)
			mouse1release()
		end)
		lastTrigger = tick()
	end
end

return Triggerbot
