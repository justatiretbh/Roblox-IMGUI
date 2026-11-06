-- ESP System (Modular)
-- Works with Drawing library (executors)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ESP = {}
ESP.Enabled = false
ESP.Boxes = true
ESP.Names = true
ESP.Health = true
ESP.Distance = true
ESP.Tracers = false
ESP.TeamCheck = true
ESP.MaxDistance = 2000

local objects = {}

local function isAlive(player)
	local char = player.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	return hum and hum.Health > 0 and root
end

local function isEnemy(player)
	if player == LocalPlayer then return false end
	if not ESP.TeamCheck then return true end
	local myTeam = LocalPlayer.Team
	local theirTeam = player.Team
	if not myTeam or not theirTeam then return true end
	return myTeam ~= theirTeam
end

local function remove(player)
	local data = objects[player]
	if not data then return end
	for _, obj in pairs(data) do
		pcall(function() obj.Visible = false obj:Remove() end)
	end
	objects[player] = nil
end

function ESP.Clear()
	for player in pairs(objects) do
		remove(player)
	end
end

function ESP.Update()
	if not ESP.Enabled then
		ESP.Clear()
		return
	end

	for player in pairs(objects) do
		if not player.Parent or not isAlive(player) or (ESP.TeamCheck and not isEnemy(player)) then
			remove(player)
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end
		if not isAlive(player) then continue end
		if ESP.TeamCheck and not isEnemy(player) then continue end

		local char = player.Character
		local root = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not root or not hum then continue end

		local dist = (root.Position - Camera.CFrame.Position).Magnitude
		if dist > ESP.MaxDistance then
			if objects[player] then
				local d = objects[player]
				d.box.Visible = false
				d.name.Visible = false
				d.hp.Visible = false
				d.hpBg.Visible = false
				d.tracer.Visible = false
			end
			continue
		end

		if not objects[player] then
			objects[player] = {
				box = Drawing.new("Square"),
				name = Drawing.new("Text"),
				hpBg = Drawing.new("Square"),
				hp = Drawing.new("Square"),
				tracer = Drawing.new("Line"),
			}
			local d = objects[player]
			d.box.Thickness = 1.5
			d.box.Filled = false
			d.name.Size = 13
			d.name.Center = true
			d.name.Outline = true
			d.hpBg.Filled = true
			d.hpBg.Color = Color3.fromRGB(20,20,20)
			d.hpBg.Transparency = 0.3
			d.hp.Filled = true
			d.tracer.Thickness = 1.3
		end

		local data = objects[player]
		local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
		if not onScreen then
			data.box.Visible = false
			data.name.Visible = false
			data.hp.Visible = false
			data.hpBg.Visible = false
			data.tracer.Visible = false
			continue
		end

		local color = isEnemy(player) and Color3.fromRGB(255,65,65) or Color3.fromRGB(70,170,255)
		local size = math.clamp(2000 / pos.Z, 14, 78)
		local boxW, boxH = size * 0.6, size

		if ESP.Boxes then
			data.box.Visible = true
			data.box.Color = color
			data.box.Size = Vector2.new(boxW, boxH)
			data.box.Position = Vector2.new(pos.X - boxW/2, pos.Y - boxH/2)
		else data.box.Visible = false end

		if ESP.Names or ESP.Distance then
			data.name.Visible = true
			data.name.Color = color
			local str = (ESP.Names and player.Name or "") .. (ESP.Distance and (" ["..math.floor(dist).."m]") or "")
			data.name.Text = str
			data.name.Position = Vector2.new(pos.X, pos.Y - boxH/2 - 15)
		else data.name.Visible = false end

		if ESP.Health then
			local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
			local barX = pos.X - boxW/2 - 6
			data.hpBg.Visible = true
			data.hpBg.Size = Vector2.new(3, boxH)
			data.hpBg.Position = Vector2.new(barX, pos.Y - boxH/2)
			data.hp.Visible = true
			data.hp.Color = Color3.fromRGB(255*(1-hp), 255*hp, 40)
			data.hp.Size = Vector2.new(3, boxH * hp)
			data.hp.Position = Vector2.new(barX, pos.Y - boxH/2 + boxH*(1-hp))
		else
			data.hp.Visible = false
			data.hpBg.Visible = false
		end

		if ESP.Tracers then
			data.tracer.Visible = true
			data.tracer.Color = color
			data.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
			data.tracer.To = Vector2.new(pos.X, pos.Y + boxH/2)
		else data.tracer.Visible = false end
	end
end

Players.PlayerRemoving:Connect(function(player)
	remove(player)
end)

return ESP
