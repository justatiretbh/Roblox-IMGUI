-- code made by @sumothemofo on discord 
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local C = {
	bg = Color3.fromRGB(15, 15, 18),
	title = Color3.fromRGB(41, 74, 122),
	frame = Color3.fromRGB(32, 48, 74),
	accent = Color3.fromRGB(66, 150, 250),
	btn = Color3.fromRGB(45, 90, 150),
	text = Color3.fromRGB(235, 235, 235),
	border = Color3.fromRGB(60, 60, 75),
}
local FONT = Enum.Font.Code

local function new(class, props, parent)
	local i = Instance.new(class)
	for k, v in pairs(props) do i[k] = v end
	i.Parent = parent
	return i
end

local function layout(parent, pad)
	new("UIListLayout", { Padding = UDim.new(0, pad or 4), SortOrder = Enum.SortOrder.LayoutOrder }, parent)
end


local Container = {}
Container.__index = Container

local function newContainer(frame)
	return setmetatable({ Frame = frame }, Container)
end

function Container:Text(str)
	return new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = str,
		TextColor3 = C.text, Font = FONT, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
	}, self.Frame)
end

function Container:Separator()
	return new("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = C.border, BorderSizePixel = 0 }, self.Frame)
end

function Container:Button(label, callback)
	local b = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = C.btn, BorderSizePixel = 0,
		Text = label, TextColor3 = C.text, Font = FONT, TextSize = 14, AutoButtonColor = false,
	}, self.Frame)
	b.MouseEnter:Connect(function() b.BackgroundColor3 = C.accent end)
	b.MouseLeave:Connect(function() b.BackgroundColor3 = C.btn end)
	b.MouseButton1Click:Connect(function() if callback then callback() end end)
	return b
end

function Container:Checkbox(label, default, callback)
	local state = default and true or false
	local row = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
	}, self.Frame)
	local box = new("Frame", {
		Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(0, 2),
		BackgroundColor3 = C.frame, BorderSizePixel = 0,
	}, row)
	local mark = new("Frame", {
		Size = UDim2.fromOffset(10, 10), Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = C.accent, BorderSizePixel = 0, Visible = state,
	}, box)
	new("TextLabel", {
		Size = UDim2.new(1, -24, 1, 0), Position = UDim2.fromOffset(24, 0), BackgroundTransparency = 1,
		Text = label, TextColor3 = C.text, Font = FONT, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	row.MouseButton1Click:Connect(function()
		state = not state
		mark.Visible = state
		if callback then callback(state) end
	end)
	return { Get = function() return state end }
end

function Container:SliderFloat(label, min, max, default, callback)
	local value = default or min
	local row = new("Frame", { Size = UDim2.new(1, 0, 0, 20), BackgroundColor3 = C.frame, BorderSizePixel = 0 }, self.Frame)
	local fill = new("Frame", { Size = UDim2.fromScale((value - min) / (max - min), 1), BackgroundColor3 = C.accent, BackgroundTransparency = 0.4, BorderSizePixel = 0 }, row)
	local txt = new("TextLabel", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, TextColor3 = C.text, Font = FONT, TextSize = 14,
	}, row)
	local function render() txt.Text = string.format("%s: %.2f", label, value) end
	render()
	local dragging = false
	local function set(x)
		local a = math.clamp((x - row.AbsolutePosition.X) / row.AbsoluteSize.X, 0, 1)
		value = min + (max - min) * a
		fill.Size = UDim2.fromScale(a, 1)
		render()
		if callback then callback(value) end
	end
	row.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			set(i.Position.X)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			set(i.Position.X)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	return { Get = function() return value end }
end

function Container:CollapsingHeader(label, open)
	open = open and true or false
	local head = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = C.title, BorderSizePixel = 0, AutoButtonColor = false,
		Text = (open and "v " or "> ") .. label, TextColor3 = C.text, Font = FONT, TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, self.Frame)
	new("UIPadding", { PaddingLeft = UDim.new(0, 6) }, head)
	local body = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Visible = open,
	}, self.Frame)
	layout(body)
	new("UIPadding", { PaddingLeft = UDim.new(0, 10) }, body)
	head.MouseButton1Click:Connect(function()
		open = not open
		body.Visible = open
		head.Text = (open and "v " or "> ") .. label
	end)
	return newContainer(body)
end

---------------------------------------------------------------- Window
local ImGui = {}
ImGui.__index = ImGui

function ImGui.new(toggleKey)
	local self = setmetatable({}, ImGui)
	self.Gui = new("ScreenGui", { Name = "ImGuiLib", ResetOnSpawn = false, DisplayOrder = 100 }, Players.LocalPlayer:WaitForChild("PlayerGui"))
	UIS.InputBegan:Connect(function(i, gp)
		if not gp and i.KeyCode == (toggleKey or Enum.KeyCode.RightShift) then
			self.Gui.Enabled = not self.Gui.Enabled
		end
	end)
	return self
end

function ImGui:Window(title, pos, width)
	local win = new("Frame", {
		Position = UDim2.fromOffset(pos.X, pos.Y), Size = UDim2.fromOffset(width or 300, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.bg, BackgroundTransparency = 0.05, BorderSizePixel = 0,
	}, self.Gui)
	new("UIStroke", { Color = C.border }, win)
	layout(win, 0)

	local bar = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = C.title, BorderSizePixel = 0,
		Text = "  " .. title, TextColor3 = C.text, Font = FONT, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 1,
	}, win)

	-- dragging
	local drag, startPos, startMouse
	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			drag, startPos, startMouse = true, win.Position, i.Position
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - startMouse
			win.Position = UDim2.fromOffset(startPos.X.Offset + d.X, startPos.Y.Offset + d.Y)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
	end)

	local tabBar = new("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, LayoutOrder = 2 }, win)
	new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 2) }, tabBar)
	new("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingTop = UDim.new(0, 2) }, tabBar)

	local pages, buttons = {}, {}
	local function select(name)
		for n, p in pairs(pages) do p.Visible = (n == name) end
		for n, b in pairs(buttons) do b.BackgroundColor3 = (n == name) and C.accent or C.btn end
	end

	local W = {}
	function W:Tab(name)
		local btn = new("TextButton", {
			Size = UDim2.fromOffset(#name * 9 + 16, 22), BackgroundColor3 = C.btn, BorderSizePixel = 0,
			Text = name, TextColor3 = C.text, Font = FONT, TextSize = 14, AutoButtonColor = false,
		}, tabBar)
		local page = new("Frame", {
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
			Visible = false, LayoutOrder = 3,
		}, win)
		layout(page)
		new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }, page)
		pages[name], buttons[name] = page, btn
		btn.MouseButton1Click:Connect(function() select(name) end)
		if next(pages, nil) and #tabBar:GetChildren() <= 3 then select(name) end
		return newContainer(page)
	end
	return W
end

---- Text And GUI
local gui = ImGui.new(Enum.KeyCode.RightShift)
local w = gui:Window("Dear Roblox GUI", Vector2.new(40, 60), 300)

local main = w:Tab("Main")
main:Text("DearIMGUI")
main:Separator()
main:Checkbox("Show crosshair", true, function(on) print("crosshair", on) end)
main:Checkbox("Show FPS counter", false, function(on) print("fps", on) end)
main:SliderFloat("FOV", 50, 120, 70, function(v) workspace.CurrentCamera.FieldOfView = v end)
main:Button("Reset", function() print("reset") end)

local misc = w:Tab("Misc")
local h = misc:CollapsingHeader("Audio", true)
h:SliderFloat("Volume", 0, 1, 0.5, function(v) print("vol", v) end)
h:Checkbox("Mute", false)
local h2 = misc:CollapsingHeader("Info")
h2:Text("RightShift = hide/show")

return gui