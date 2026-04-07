task.wait(0.5)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Storage = game:GetService("ServerStorage")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local assetsInit = require(ReplicatedStorage:WaitForChild("AssetsInit"))
local contextLighting = require(script.ContextLighting)
repeat task.wait() until assetsInit.INITIALIZED

local COLOSSEUM_ID = assetsInit.RTD.Battle
local RESORT_ID = assetsInit.RTD.Trade

if game.CreatorId == 1 then
	COLOSSEUM_ID = 16673262598
	RESORT_ID = 16673263398
end

local subContextStorage = Storage:WaitForChild("SubContexts")
local placeId = game.PlaceId
local context

if placeId == COLOSSEUM_ID then
	context = "battle"

	Storage.MapChunks:ClearAllChildren()
	Storage.Indoors:ClearAllChildren()

	local worldModel = subContextStorage.Colosseum.WorldModel
	worldModel.Parent = workspace

	pcall(function()
		require(script["2v2Board"]):enable(worldModel:WaitForChild("2v2Board").Screen.SurfaceGui.Container)
	end)

	pcall(function()
		require(script.SpectateBoard):enable(worldModel:WaitForChild("SpectateBoard").Screen.SurfaceGui.Container)
	end)

	local chunk = subContextStorage.Colosseum.chunk
	chunk.Name = "colosseum"
	chunk.Parent = Storage.MapChunks

	Storage.Models.BattleScenes:ClearAllChildren()
	subContextStorage.Colosseum.SingleFields.Parent = Storage.Models.BattleScenes
	subContextStorage.Colosseum.DoubleFields.Parent = Storage.Models.BattleScenes

	subContextStorage:Destroy()
	Lighting.TimeOfDay = "14:00:00"
	Lighting.Brightness = 2.5

elseif placeId == RESORT_ID then
	context = "trade"

	Storage.MapChunks:ClearAllChildren()
	Storage.Indoors:ClearAllChildren()

	subContextStorage.Resort.WorldModel.Parent = workspace

	local chunk = subContextStorage.Resort.chunk
	chunk.Name = "resort"
	chunk.Parent = Storage.MapChunks

	subContextStorage:Destroy()
	Lighting.TimeOfDay = "14:30:00"

else
	context = "adventure"
	subContextStorage:Destroy()
end

if context ~= "adventure" then
	Players.ChildAdded:Connect(function(player)
		if not player or not player:IsA("Player") then
			return
		end
		if player.UserId < 1 then
			player:Kick()
		end
	end)
end

task.spawn(function()
	contextLighting(context)
end)

local tag = Instance.new("StringValue")
tag.Name = "GameContext"
tag.Parent = ReplicatedStorage.Version
tag.Value = context

return context