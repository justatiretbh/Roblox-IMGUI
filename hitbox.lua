-- Hitbox Expander System (Modular)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Hitbox = {}
Hitbox.Enabled = false
Hitbox.Size = 3.5
Hitbox.TeamCheck = true

local original = {}

local function isEnemy(player)
	if player == LocalPlayer then return false end
	if not Hitbox.TeamCheck then return true end
	local myTeam, theirTeam = LocalPlayer.Team, player.Team
	if not myTeam or not theirTeam then return true end
	return myTeam ~= theirTeam
end

function Hitbox.Update()
	for _, player in ipairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end
		local char = player.Character
		if not char then continue end
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then continue end

		if Hitbox.Enabled and isEnemy(player) then
			if not original[player] then
				original[player] = root.Size
			end
			root.Size = Vector3.new(Hitbox.Size, Hitbox.Size, Hitbox.Size)
			root.Transparency = 0.7
			root.CanCollide = false
		else
			if original[player] then
				root.Size = original[player]
				root.Transparency = 1
				original[player] = nil
			end
		end
	end
end

Players.PlayerRemoving:Connect(function(player)
	original[player] = nil
end)

return Hitbox
