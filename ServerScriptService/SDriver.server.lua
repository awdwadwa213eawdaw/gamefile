local scriptbin = script.Parent
local storage = game:GetService('ServerStorage')
local http = game:GetService("HttpService")

repeat wait() until _G.GameCompleted

-- SERVER LAUNCH PREP
-- move (specific) buildings to proper storage
--pcall(function() workspace.Museum.Parent = storage.Indoors.chunk19 end)
pcall(function() workspace.gym6.Parent = storage.MapChunks end)

-- move chunks to storage
for _, obj in pairs(workspace:GetChildren()) do
	if obj.Name:sub(1, 5) == 'chunk' and tonumber(obj.Name:sub(6)) then
		obj.Parent = storage.MapChunks
	end
end

-- fix regions
for _, r in pairs(storage.MapChunks.Regions:GetChildren()) do
	local chunk = storage.MapChunks:FindFirstChild(r.Name)
	if chunk then
		r.Name = 'Regions'
		r.Parent = chunk
	end
end

-- make spawn box invisible
for _, p in pairs(workspace.SpawnBox:GetChildren()) do
	pcall(function() p.Transparency = 1.0 end)
end

-- revert to legacy physics
local function applyOldPhysics(obj)
	for _, ch in pairs(obj:GetChildren()) do
		if ch:IsA('BasePart') then
			ch.CustomPhysicalProperties = PhysicalProperties.new(1, 0.3, 0.5)
		end
		applyOldPhysics(ch)
	end
end
applyOldPhysics(storage)

-- SERVER FRAMEWORK INSTALLATION
local moduleFolder = scriptbin:WaitForChild('ServerModules')
local frameworkModule = script:WaitForChild('SFramework')
frameworkModule.Parent = scriptbin

local _f = require(frameworkModule)
_f.Utilities = require(storage:WaitForChild('Utilities'))
_f.BitBuffer = require(storage:WaitForChild('Plugins'):WaitForChild('BitBuffer'))
_f.levelCap = 85
_f.currentweather = ''
_f.portalLocation = false
--_f.PortalLocations = {'chunk9', 'chunk12', 'chunk15', 'chunk24', 'chunk36', 'chunk45', 'chunk51'}
_f.PortalLocations = {'chunk24'}
--// External Data
local savedData = {
	Dynamax = {}
}
local lastDatastoreRequest = {
	Dynamax = 0
}
_f.ExternalDatastore = function(name, specificValue, splitToTable)
	local dataURLs = {
		Dynamax = "https://pastebin.com/raw/GGkC3TZ7",
		DynamaxFallback = "https://gist.githubusercontent.com/InfraredGodYT/b0cbefdce66b5dbd127a199f8b7b9ab5/raw/ee3b08943b1ba75e23d17d65bb625ee2b42ec311/raids.json"
	}
	local dividerKey = ";"
	local refreshRate = 60 * 5

	if lastDatastoreRequest[name] + refreshRate <= os.time() then
		lastDatastoreRequest[name] = os.time()

		local function fetchData(url)
			local success, result = pcall(function()
				local response = http:GetAsync(url)
				return http:JSONDecode(response)
			end)

			if success then
				return true, result
			else
				warn("Failed to load data for " .. name .. " from URL: " .. url .. " - " .. tostring(result))
				task.wait(1)
			end
			return false, "Data Failed to Load"
		end

		-- Try primary URL
		local success, result = fetchData(dataURLs[name])
		if success then
			savedData[name] = result
		else
			warn(result)
			-- Try fallback URL
			success, result = fetchData(dataURLs[name .. "Fallback"])
			if success then
				savedData[name] = result
				warn("Backup Loaded")
			else
				warn(result)
			end
		end
	end

	if specificValue then
		if savedData[name] then
			if type(specificValue) == 'table' then
				local returnTbl = {}
				for _, neededValue in pairs(specificValue) do
					local success, result = pcall(function()
						return string.split(savedData[name][neededValue], dividerKey)
					end)
					if success then
						returnTbl[neededValue] = result
					else
						warn("Failed to split value for " .. neededValue .. ": " .. tostring(result))
					end
				end
				return returnTbl
			elseif splitToTable then
				local success, result = pcall(function()
					return string.split(savedData[name][specificValue], dividerKey)
				end)
				if success then
					return result
				else
					warn("Failed to split value for " .. specificValue .. ": " .. tostring(result))
				end
			end
			return savedData[name][specificValue]
		else
			warn("No saved data found for " .. name)
		end
	end

	return savedData[name]
end
_f.isDay = function() -- Night is from 17:50 to 06:30, inclusive
	local min = game:GetService('Lighting'):GetMinutesAfterMidnight()
	return min > 6.5*60 and min < (17+5/6)*60
end
_f.bgc_accs = {
	452198911,
	3768615414,
	1906095486,
	3881398035
}

-- RANDOMIZER HANDLER
local PokemonByNumber = {}
local numerator = 1
local bannedSpecies = {
	forme = {
		white=true,black=true,
		mega=true,megax=true,
		megay=true,primal=true,
		zen=true, megac=true,
		megah=true,dark=true,hallow=true,ash=true,school=true,
		crowned=true,galarzen=true,busted=true,christmas=true,heart=true,zelda=true,aku=true,purple=true
	},
	pokemon = {minior=true},
	formeOfPokemon = {
		deoxys=true,
		vivillon=true,floette=true,arceus=true,silvally=true,
		Sceptile=true,florges=true,cramorant=true,flabebe=true,
		calyrex=true,necrozma=true,kyurem=true,morpeko=true,
		magikarp=true,gyarados=true,genesect=true
	},
}

----GET RANDOMIZER POSSIBLE POKES
_f.validSpecies = {['ho-oh']=true,['porygon-z']=true,['kommo-o']=true,['hakamo-o']=true,['jangmo-o']=true}

for _, data in pairs(require(game.ServerStorage.BattleData.Pokedex)) do	
	if not data.baseSpecies and data.species and not data.forme and not bannedSpecies['pokemon'][data.species] then --this makes it exclude formes because it checks through gifdata for it
		PokemonByNumber[tostring(numerator)] = {species=data.species,forme=nil}
		numerator += 1
	end
end
for name, data in pairs(require(game.ServerStorage.Data.GifData)._FRONT) do
	if string.find(name, '-') and not _f.validSpecies[string.lower(name)] then
		name = string.split(name, '-')
		if name and not bannedSpecies['formeOfPokemon'][string.lower(name[1])] and not bannedSpecies['forme'][string.lower(name[2])] then
			PokemonByNumber[tostring(numerator)] = {species=name[1],forme=name[2]}
			numerator += 1
		else
		end
	end
end
-----
_f.randomizePoke = function(max)
	local Pokes = {}
	local maxID = numerator-1
	if not max then max = 1 end
	for i = 1, max do  
		local forme = nil
		local Pokemon
		local gifData 
		local gifData2
		while true do
			Pokemon = PokemonByNumber[tostring(math.random(1, maxID))]
			--Should I check for shinies also?
			gifData = _f.Database.GifData._FRONT[Pokemon.species..(Pokemon.forme and '-'..Pokemon.forme or '')]
			gifData2 = _f.Database.GifData._BACK[Pokemon.species..(Pokemon.forme and '-'..Pokemon.forme or '')]
			if (Pokemon.species and not bannedSpecies['pokemon'][string.lower(Pokemon.species)]) and gifData and gifData2 then
				break
			end
		end
		if Pokemon.forme and not bannedSpecies['forme'][string.lower(Pokemon.forme)] then
			forme = Pokemon.forme
		end
		table.insert(Pokes, {Pokemon.species, forme})
	end
	return Pokes	
end

local function install(module, name)
	if name then module.Name = name end
	module.Parent = frameworkModule
	local s, r = pcall(function() _f[module.Name] = require(module) end)
	if not s then
		warn('ERROR WITH SCRIPT NAME:', module.Name, r)
	end
end

install(moduleFolder['FirebaseService'])

do
	local Firebases = _f.FirebaseService
	local stores = game:GetService("DataStoreService")
	local errorText = 'Place has to be opened with Edit button to access DataStores'
	local errorText2 = 'You must publish this place to the web to access DataStore.'
	local efunc = function() error(errorText) end
	local fakeDataStore = {
		GetAsync = efunc,
		SetAsync = efunc,
		UpdateAsync = efunc,
		IncrementAsync = efunc,
		OnUpdate = function() end
	}
	_f.safelyGetDataStore = function(n, s)
		local ds
		local s, r = pcall(function() ds = Firebases:GetFirebase(n, s) end)
		if not s then
			if r == errorText or r:find(errorText2) then
				return fakeDataStore
			else
				error(r)
			end
		end
		return ds
	end
	_f.safelyGetOrderedDataStore = function(n, s)
		local ds
		local s, r = pcall(function() ds = stores:GetOrderedDataStore(n, s) end)
		if not s then
			if r == errorText or r:find(errorText2) then
				return fakeDataStore
			else
				error(r)
			end
		end
		return ds
	end
end

-- install the modules that are expected to be pre-installed or installed in particular order
for _, name in pairs({'Network', 'Context', 'DataService', 'Elo', 'BattleEngine'}) do -- BattleEngine just has to be installed before DataPersistence, and Elo before BattleEngine
	install(moduleFolder[name])
end

-- install the usable items
install(storage.src.UsableItemsServer, 'UsableItems')

-- misc installs
_f.PBStamps = require(storage.RuntimeModules.PBStamps){Utilities = _f.Utilities}
_f.RouletteSpinner = require(storage.RuntimeModules.RouletteSpinner){Utilities = _f.Utilities}

-- install all other modules
for _, module in pairs(moduleFolder:GetChildren()) do
	if module:IsA('ModuleScript') then
		install(module)
	end
end

-- Load models
local insertService = game:GetService('InsertService')
local function safeLoadModel(groupAssetId, testAssetId)
	local assetId = (game.CreatorId == 1 and testAssetId or groupAssetId)
	while true do
		local success = false
		pcall(function()
			local loadedModel = insertService:LoadAsset(assetId)
			if loadedModel then
				success = true
				for _, m in pairs(loadedModel:GetChildren()) do
					if m:IsA('Model') then
						m.Parent = storage.Models
					end
				end
			end
		end)
		if success then break end
		wait(.5)
	end
end

wait()
spawn(function() safeLoadModel(656180015, 656169938) end) -- Heatran
wait(.25)






