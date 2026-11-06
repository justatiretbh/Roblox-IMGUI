-- Simple Config System

local Config = {}
Config.Data = {}

function Config.Set(key, value)
	Config.Data[key] = value
end

function Config.Get(key, default)
	if Config.Data[key] ~= nil then
		return Config.Data[key]
	end
	return default
end

function Config.Save(name)
	print("[Config] Saved:", name)
	-- Expand with writefile if your executor supports it
end

function Config.Load(name)
	print("[Config] Loaded:", name)
	-- Expand with readfile if your executor supports it
end

return Config
