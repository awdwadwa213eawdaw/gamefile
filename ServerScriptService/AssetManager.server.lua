local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local baseURL = "https://raw.githubusercontent.com/awdwadwa213eawdaw/game-uploader/main/Baba/assets.json"

local updateEvent = ReplicatedStorage:FindFirstChild("UpdateAssetList")
if not updateEvent then
	updateEvent = Instance.new("RemoteEvent")
	updateEvent.Name = "UpdateAssetList"
	updateEvent.Parent = ReplicatedStorage
end

local assetsModule = require(ReplicatedStorage:WaitForChild("AssetsInit"))
local assetList = nil

local function fetchAssets()
	for i = 1, 5 do
		local ok, response = pcall(function()
			return HttpService:GetAsync(baseURL)
		end)

		if ok and response and response ~= "" then
			local decodeOk, decoded = pcall(function()
				return HttpService:JSONDecode(response)
			end)

			if decodeOk and type(decoded) == "table" then
				assetList = decoded
				return true
			else
				warn("[AssetLoader] JSON decode failed on attempt", i)
			end
		else
			warn("[AssetLoader] HTTP fetch failed on attempt", i)
		end

		task.wait(1)
	end

	return false
end

local function installAssets()
	local success = fetchAssets()

	if not success then
		warn("[AssetLoader] Failed to load GitHub assets, using fallback defaults")
		assetList = {
			RTD = {
				Main = 0,
				Battle = 1,
				Trade = 2
			},
			Animations = {},
		}
	end

	local RTDSource = assetList.RTD or {}

	local RTD = {
		Main = tonumber(RTDSource.Main) or 0,
		Battle = tonumber(RTDSource.Battle) or 1,
		Trade = tonumber(RTDSource.Trade) or 2
	}

	if RTD.Battle == 0 then
		RTD.Battle = 1
	end

	if RTD.Trade == 0 then
		RTD.Trade = 2
	end

	assetsModule.RTD = RTD
	assetsModule.Animations = assetList.Animations or {}
	assetsModule.INITIALIZED = true

	updateEvent:FireAllClients({
		RTD = assetsModule.RTD,
		Animations = assetsModule.Animations,
	})
end

installAssets()

Players.PlayerAdded:Connect(function(player)
	if assetsModule.INITIALIZED then
		updateEvent:FireClient(player, {
			RTD = assetsModule.RTD,
			Animations = assetsModule.Animations,
			Products = assetsModule.Products
		})
	end
end)