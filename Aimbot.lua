-- Aimbot System (Modular)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Aimbot = {}
Aimbot.Enabled = false
Aimbot.Silent = false
Aimbot.Sticky = true
Aimbot.FOV = 160
Aimbot.Smooth = 0.15
Aimbot.Prediction = 0.12
Aimbot.TeamCheck = true
Aimbot.WallCheck = false
Aimbot.Part = "Head"
Aimbot.ShowFOV = true

local currentTarget = nil
local fovCircle = nil

local function isAlive(player)
	local char = player.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	return hum and hum.Health > 0 and char:FindFirstChild("HumanoidRootPart")
end

local function isEnemy(player)
	if player == LocalPlayer then return false end
	if not Aimbot.TeamCheck then return true end
	local myTeam, theirTeam = LocalPlayer.Team, player.Team
	if not myTeam or not theirTeam then return true end
	return myTeam ~= theirTeam
end

local function getClosest()
	local closest, closestDist = nil, Aimbot.FOV
	local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

	for _, player in ipairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end
		if not isAlive(player) then continue end
		if Aimbot.TeamCheck and not isEnemy(player) then continue end

		local char = player.Character
		local part = char:FindFirstChild(Aimbot.Part) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
		if not part then continue end

		local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
		if not onScreen then continue end

		if Aimbot.WallCheck then
			local ray = Workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position))
			if ray and ray.Instance and not ray.Instance:IsDescendantOf(char) then continue end
		end

		local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
		if dist < closestDist then
			closestDist = dist
			closest = player
		end
	end
	return closest
end

function Aimbot.Update()
	if not (Aimbot.Enabled or Aimbot.Silent) then
		currentTarget = nil
		if fovCircle then fovCircle.Visible = false end
		return
	end

	if Aimbot.ShowFOV then
		if not fovCircle then
			fovCircle = Drawing.new("Circle")
			fovCircle.Thickness = 1.5
			fovCircle.NumSides = 64
			fovCircle.Filled = false
			fovCircle.Color = Color3.fromRGB(0, 200, 255)
		end
		fovCircle.Visible = true
		fovCircle.Radius = Aimbot.FOV
		fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
	elseif fovCircle then
		fovCircle.Visible = false
	end

	local target = getClosest()

	if Aimbot.Sticky and currentTarget and isAlive(currentTarget) and isEnemy(currentTarget) then
		local part = currentTarget.Character and (currentTarget.Character:FindFirstChild(Aimbot.Part) or currentTarget.Character:FindFirstChild("Head"))
		if part then
			local pos = Camera:WorldToViewportPoint(part.Position)
			local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
			if dist < Aimbot.FOV * 1.4 then
				target = currentTarget
			end
		end
	end

	if not target then
		currentTarget = nil
		return
	end

	currentTarget = target
	local char = target.Character
	local part = char:FindFirstChild(Aimbot.Part) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
	if not part then return end

	local velocity = part.AssemblyLinearVelocity or Vector3.zero
	local predicted = part.Position + (velocity * Aimbot.Prediction)
	local cf = CFrame.new(Camera.CFrame.Position, predicted)
	local smooth = Aimbot.Silent and 0.92 or Aimbot.Smooth
	Camera.CFrame = Camera.CFrame:Lerp(cf, smooth)
end

function Aimbot.GetCurrentTarget()
	return currentTarget
end

return Aimbot
