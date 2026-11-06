-- Utility System

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local Utility = {}

function Utility.Rejoin()
	TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

function Utility.ServerHop()
	local success, data = pcall(function()
		return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
	end)

	if success and data and data.data then
		local list = {}
		for _, s in pairs(data.data) do
			if s.playing < s.maxPlayers and s.id ~= game.JobId then
				table.insert(list, s.id)
			end
		end
		if #list > 0 then
			TeleportService:TeleportToPlaceInstance(game.PlaceId, list[math.random(1, #list)], LocalPlayer)
		end
	end
end

function Utility.Notify(text)
	print("[Notify]", text)
end

return Utility
