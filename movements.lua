-- Movement System (Modular)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Movement = {}
Movement.Fly = false
Movement.FlySpeed = 90
Movement.Speed = false
Movement.WalkSpeed = 32
Movement.JumpPower = 60
Movement.InfJump = false
Movement.Noclip = false
Movement.NoFall = true

local flyBV, flyBG, flyConn, noclipConn, infJumpConn

function Movement.ToggleFly(on)
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end

	if flyConn then flyConn:Disconnect() flyConn = nil end
	if flyBV then flyBV:Destroy() flyBV = nil end
	if flyBG then flyBG:Destroy() flyBG = nil end

	if on then
		flyBV = Instance.new("BodyVelocity")
		flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		flyBV.Parent = root
		flyBG = Instance.new("BodyGyro")
		flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		flyBG.P = 9e4
		flyBG.Parent = root
		hum.PlatformStand = true

		flyConn = RunService.RenderStepped:Connect(function()
			if not Movement.Fly or not flyBV then return end
			local cam = Camera.CFrame
			local move = Vector3.zero
			if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.yAxis end
			if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.yAxis end
			flyBV.Velocity = move.Magnitude > 0.1 and move.Unit * Movement.FlySpeed or Vector3.zero
			flyBG.CFrame = CFrame.new(root.Position, root.Position + cam.LookVector)
		end)
	else
		hum.PlatformStand = false
	end
end

function Movement.ApplySpeed()
	local char = LocalPlayer.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = Movement.Speed and Movement.WalkSpeed or 16
		hum.JumpPower = Movement.JumpPower
	end
end

function Movement.ToggleNoclip(on)
	if noclipConn then noclipConn:Disconnect() noclipConn = nil end
	if on then
		noclipConn = RunService.Stepped:Connect(function()
			local char = LocalPlayer.Character
			if char then
				for _, p in ipairs(char:GetDescendants()) do
					if p:IsA("BasePart") then p.CanCollide = false end
				end
			end
		end)
	end
end

function Movement.SetupInfJump()
	if infJumpConn then infJumpConn:Disconnect() end
	infJumpConn = UIS.JumpRequest:Connect(function()
		if Movement.InfJump then
			local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
		end
	end)
end

function Movement.SetupNoFall()
	local function apply(char)
		local hum = char:WaitForChild("Humanoid", 3)
		if hum then
			hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
			hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		end
	end
	LocalPlayer.CharacterAdded:Connect(apply)
	if LocalPlayer.Character then apply(LocalPlayer.Character) end
end

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.4)
	if Movement.Speed then Movement.ApplySpeed() end
	if Movement.Fly then Movement.ToggleFly(true) end
	if Movement.Noclip then Movement.ToggleNoclip(true) end
end)

Movement.SetupInfJump()
Movement.SetupNoFall()

return Movement
