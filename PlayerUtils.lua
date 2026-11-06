-- Player Utils (Spectate + Helpers)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local PlayerUtils = {}
PlayerUtils.Spectating = false
PlayerUtils.SpectateTarget = nil

function PlayerUtils.Spectate(player)
	if not player or not player.Character then return end
	local hum = player.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		Camera.CameraSubject = hum
		PlayerUtils.Spectating = true
		PlayerUtils.SpectateTarget = player
	end
end

function PlayerUtils.StopSpectate()
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		Camera.CameraSubject = hum
	end
	PlayerUtils.Spectating = false
	PlayerUtils.SpectateTarget = nil
end

function PlayerUtils.GetEnemies()
	local list = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local myTeam = LocalPlayer.Team
			local theirTeam = player.Team
			if not myTeam or not theirTeam or myTeam ~= theirTeam then
				table.insert(list, player)
			end
		end
	end
	return list
end

return PlayerUtils
