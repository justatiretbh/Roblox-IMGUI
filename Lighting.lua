-- Lighting System (Modular)

local Lighting = game:GetService("Lighting")

local LightingSystem = {}
LightingSystem.Fullbright = false

local old = {
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime,
	FogEnd = Lighting.FogEnd,
	GlobalShadows = Lighting.GlobalShadows,
	OutdoorAmbient = Lighting.OutdoorAmbient,
}

function LightingSystem.ToggleFullbright(on)
	LightingSystem.Fullbright = on
	if on then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 1000000
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.fromRGB(140, 140, 140)
	else
		Lighting.Brightness = old.Brightness
		Lighting.ClockTime = old.ClockTime
		Lighting.FogEnd = old.FogEnd
		Lighting.GlobalShadows = old.GlobalShadows
		Lighting.OutdoorAmbient = old.OutdoorAmbient
	end
end

return LightingSystem
