-- It is very important to consider all cases for arguments, as the client can send anything for arguments via exploit.
-- Pretty much just return false for requests with invalid arguments.

-- search "OVH" for overhaul notes
-- search "PDL" and also look for other potential pokemon data leaks
--   todo: search all instances of Pokemon:new on server, ensure PlayerData is included in call
--         destroy Pokemon objects where appropriate

-- OVH  remove rc4 as much as possible on server side
local _f = require(script.Parent)

local PlayerData, PC
local PlayerDataByPlayer = {}--setmetatable({}, {__mode = 'k'})
local function onPlayerEnter(player)
	if not player or not player:IsA('Player') or PlayerDataByPlayer[player] then return end
	local pd = PlayerData:new(player)
	PlayerDataByPlayer[player] = pd
end

local network = _f.Network
local context = _f.Context

local publicFns = {
	getContinueScreenInfo = true,
	continueGame          = true,
	startNewGame          = true,
	saveGame              = true,
	completeEvent         = true,

	getStarterData        = true,
	buyStarter            = true,
	buyAshGreninja        = true,
	roStatus              = true,
	pauseRoPower          = true,
	resumeRoPower         = true,

	getParty              = true,
	getHealing            = true,
	getDevHealing         = true,
	getPokemonSummary     = true,
	getCutter             = true,
	getDigger             = true,
	getHeadbutter         = true,
	getSmasher            = true,
	getClimber            = true,
	getHappiness          = true,
	approveNickname       = true,

	getDex                = true,
	getCardInfo           = true,

	getBagPouch           = true,
	getTMs                = true,
	getBattleBag          = true,
	useItem               = true,
	giveItem              = true,
	takeItem              = true,
	tossItem              = true,
	teachTM               = true,
	obtainItem            = true,

	deleteMove            = true,
	remindMove            = true,
	getShop               = true,
	maxBuy                = true,
	buyItem               = true,
	bMaxBuy               = true,
	RevealCatacombs       = true,
	buyWithBP             = true,
	sellItem              = true,

	makeDecision          = true,
	openPC                = true,
	cPC                   = true,
	closePC               = true,

	getDCPhrase           = true,
	takeEgg               = true,
	getDCInfo             = true,
	leaveDCPokemon        = true,
	takeDCPokemon         = true,

	countBatteries        = true,
	hasFossil             = true,
	reviveFossil          = true,
	dive                  = true,
	nextDig               = true,
	finishDig             = true,

	nSpins                = true,
	spinForStamp          = true,
	stampInventory        = true,
	setStamps             = true,

	hasOKS                = true,
	hasSTP                = true,
	hasTT                 = true,
	hasFlute              = true,
	hasRTM                = true,
	hasJKey               = true,
	has3birds             = true,
	has3forces            = true,
	hasdss                = true,
	has3regis             = true,
	hasSwordsOJ           = true,
	hasvolitems           = true,
	getHoneyData          = true,
	getHoney              = true,
	isDinWM               = true,
	isTinD                = true,
	isLapD                = true,
	buySushi              = true,
	getGreenhouseState    = true,
	giveEkans             = true,
	birdsitem             = true,
	buybirdsitem          = true,
	motorize              = true,

	hover                 = true,
	setHoverboard         = true,
	ownsHoverboard        = true,
	purchaseHoverboard    = true,
	hasbottlecaps         = true,
	trainpokemon          = true,
	pickberry             = true,
	checkFurfrou          = true,
	changeForme           = true,
	getMovesBag           = true,
	getivs                = true,
	checkHPType           = true,
	getFroster            = true,
	getStrengthen         = true,
	surf                  = true,
	getSurfer             = true,
	getWtrOp              = true,
	getLottoPrizes        = true,
	drawLotto             = true,
	getLottoResults       = true,

	getFilteredString     = true,
	reportSlopeTime       = true,
	pdc                   = true,
	HasZMoveOn            = true,
	buyWithTix            = true,
	tMaxBuy               = true,
	ArcadeReward          = true,
	spinRouletteForPoke   = true,
	weatherUpdate 			   = true,
	checkCode             = true,
	SpawnPoke             = true,
	SpawnItem             = true,
	SpawnCurrency         = true,
	ShutdownServers       = true,
	GetPerms              = true,
	getChainInfo          = true,
	ServerPortal          = true,
	getCSceptileStage     = true, --// 2022 Winter Event
	moneySafari		   	  = true,
	getSubcontexts        = true,
	has3ghosts            = true, --// 2023 Halloween Event
	getMarshadowBattle    = true,
	getBMode 			  = true,
	getObj			      = true,
	getAllRegionNames     = true,
	getInfoOf             = true,
	getChunkData          = true,
	roPauseText 	      = true,
	roPauseStatus 	      = true,
	productValue          = true,
	keepRaidTraits        = true,
	maxRaidIcon 		  = true,
	getRaidDenData 		  = true,
	getRaidDenRewards 	  = true, 
	RaidParty 			  = true,
	CheckBanlist          = true,
	setFormat             = true,
	getFormat             = true,
	getLevelCap 	      = true,
	getPseudoEncounter 	  = true,
	moveTutor             = true,

}
local publicEvents = {
	chooseName            = true,
	completedEggCycle     = true,
	rearrangeParty        = true,
	keepEgg               = true,
	resetFishStreak       = true,
	slatherHoney          = true,
	purchaseRoPower       = true,
	ROPowers_pause 		  = true,
	ROPowers_resume 	  = true,
	unhover               = true,
	hoverboardAction      = true,
	unsurf                = true,
	TixPurchase           = true,
	changeMoveOrder       = true,
	setBMode 		      = true, 
	rearrangeMoves		  = true,

}
network:bindFunction('PDS', function(player, fnName, ...)
	if not publicFns[fnName] then network.GenerateReport(player, 'attempted to call PDS function "'..tostring(fnName)..'"') return end
	local pd = PlayerDataByPlayer[player]
	if not pd then
		-- uh, we should have created PlayerData for this player... what happened?
		error(player.Name .. ' has no Player Data')
	end
	return pd[fnName](pd, ...)
end)
network:bindEvent('PDS', function(player, fnName, ...)
	if not publicEvents[fnName] then network.GenerateReport(player, 'attempted to call PDS event "'..tostring(fnName)..'"') return end
	local pd = PlayerDataByPlayer[player]
	if not pd then
		-- uh, we should have created PlayerData for this player... what happened?
		error(player.Name .. ' has no Player Data')
	end
	pd[fnName](pd, ...)
end)


local storage = game:GetService('ServerStorage')
local Utilities = _f.Utilities
local BitBuffer = _f.BitBuffer--require(storage.Plugins.BitBuffer)
local Region = require(storage.Plugins.Region)
local Assets = require(storage.src.Assets) -- for game passes
local UsableItemsClient = require(storage.src.UsableItemsClient)() -- note: nothing passed for _p
local RoamingPokemon = require(storage.Data.Chunks).roamingEncounter

local MAX_MONEY = 9999999
local MAX_BP = 9999
local MAX_TIX = 9999999
local RO_POWER_EFFECT_DURATION = 60 * 60

local RUN_FULL_CHECK = false

PlayerData = Utilities.class({
	className = 'ServerPlayerData',
	gameBegan = false,
	trainerName = '',
	pokedex = '',
	money = 0,
	bp = 0,
	tix = 0,
	obtainedItems = '',
	tms = '',
	hms = '',
	defeatedTrainers = '',
	expShareOn = false,
	lastDrifloonEncounterWeek = 0,
	lastTrubbishEncounterWeek = 0,
	lastLaprasEncounterWeek = 0,
	lastHoneyGivenDay = 0,
	fishingStreak = 0,
	starterType = '',
	lottoTries = 0,
	lastLottoTryDay = 0,
	stampSpins = 0,
	currentHoverboard = '',
	captureChain = {
		poke = '',
		chain = 0
	},
	battleMode = 1
}, function(player)
	local self = {
		player = player,
		userId = player.UserId,
		trainerName = player.Name,
		pc = PC:new(),
		party = {},
		bag = {{},{},{},{},{},{}}, -- Items, Medicine, Poke Balls, Berries, Key Items, Z-Moves
		badges = {},
		completedEvents = {},
		daycare = {
			depositedPokemon = {},
			manHasEgg = false
		},
		ownedGamePassCache = {},
		rtick = tick()%1,
		roPowers = {
			powerLevel = {0, 0, 0, 0, 0, 0, 0},
			lastPurchasedAt = {0, 0, 0, 0, 0, 0, 0},
			paused = {false, false, false, false, false, false, false},
			pausedRemaining = {0, 0, 0, 0, 0, 0, 0}
		},
		flags = {},
		lastCompletedEggCycle = tick(),
		decision_data = {},
		decision_count = 0,
		starterProductStack = {},
		ashGreninjaProductStack = {},
		lottoTicketProductStack = {},
		hoverboardProductStack = {},
		pbStamps = {},
		ownedHoverboards = {},
		SurfEnabled = false,
		gamemode = 'adventure',
		keepTraits = {
			shiny = false,
			HA = false,
			gmax = false,
		},
	}
	setmetatable(self, PlayerData)
	-- cache player save data as soon as possible
	Utilities.fastSpawn(PlayerData.getSaveData, self)
	-- cache owned game passes for quicker lookup
	if self.userId > 0 then
		Utilities.fastSpawn(function()
			for _, passId in pairs(Assets.passId) do
				self:ownsGamePass(passId)
			end
		end)
	end
	return self
end)

function PlayerData:getSubcontexts()
	return {
		{
			name = "Battle Colosseum",
			colorLight = Color3.fromRGB(232, 55, 67),
			colorDark = Color3.fromRGB(138, 38, 41),
			dest = Assets.placeId.Battle
		},
		{
			name = "Trade Resort",
			colorLight = Color3.fromRGB(0, 163, 255),
			colorDark = Color3.fromRGB(33, 84, 185),
			dest = Assets.placeId.Trade
		},
		{
			name = "Player Search",
			colorLight = Color3.fromRGB(243, 243, 243),
			colorDark = Color3.fromRGB(140, 140, 140),
			search = true
		}
	}
end

function PlayerData:changeMoveOrder(index, newMoves)
	if self:isInBattle() then return end

	local poke = self.party[index]

	if not poke then return end

	local newMoveData = {}

	for i, move in pairs(poke.moves) do
		local newIndex = table.find(newMoves, move.id)

		if not newIndex then 
			_f.Logger:logError(self.player, {
				ErrType = "changeMoveOrder",
				Errors = 'newMoves list is missing the "'..move.id..'" move id.'
			})
			return 
		end 

		newMoveData[newIndex] = Utilities.deepcopy(move)
	end

	poke.moves = newMoveData
end

function PlayerData:getBMode()
	return self.battleMode
end
function PlayerData:getObj()
	return self.obj
end
function PlayerData:setBMode(i)
	if not table.find({1, 2}, i) or self:isInBattle() then return end
	self.battleMode = i
end

function PlayerData:random(x, y)
	local r = (math.random()+self.rtick)%1
	if x and y then
		return math.floor(x + (y+1-x)*r)
	elseif x then
		return math.floor(1 + x*r)
	end
	return r
end
function PlayerData:random2(x, y)
	local r = (math.random()-self.rtick+1)%1
	if x and y then
		return math.floor(x + (y+1-x)*r)
	elseif x then
		return math.floor(1 + x*r)
	end
	return r
end


function PlayerData:check() end -- OVH  todo


function PlayerData:isInBattle() 
	return _f.BattleEngine:getBattleSideForPlayer(self.player) ~= nil
end

function PlayerData:isInTrade()
	return _f.TradeManager:playerIsInTrade(self.player)
end

function PlayerData:getParty(context)
	-- check for open battles involving this player 
	--  party order may change, hp, etc.
	local battleSide = _f.BattleEngine:getBattleSideForPlayer(self.player)
	local battleParty
	if battleSide then
		battleParty = battleSide.pokemon
		-- 2v2
		if battleSide.isTwoPlayerSide and battleSide.battle.is2v2 then
			local lp = battleSide.battle.listeningPlayers
			local teamn = (lp[battleSide.id]==self.player) and 1 or 2
			--			local indexOffset = (teamn==2) and battleSide.nPokemonFromTeam1 or 0
			local party = {}
			for _, battlePokemon in pairs(battleSide.pokemon) do
				if battlePokemon.teamn == teamn then
					table.insert(party, self.party[battlePokemon.originalPartyIndex]:getPartyData(battlePokemon, context))
				end
			end
			return party
		end
		--
	end

	local party = {0, 0, 0, 0, 0, 0} -- placeholders
	for i, pokemon in ipairs(self.party) do
		if battleParty then
			local battlePokemon
			for _, p in pairs(battleParty) do
				if p.index == i then
					battlePokemon = p
					break
				end
			end
			if battlePokemon then
				party[battlePokemon.position] = pokemon:getPartyData(battlePokemon, context)
			end
		else
			party[i] = pokemon:getPartyData({}, context)
		end
	end
	for i = 6, 1, -1 do
		if party[i] == 0 then
			table.remove(party, i)
		end
	end
	return party
end
function PlayerData:maxRaidIcon(name, forme)
	if not name then name = 'Magikarp' end
	local pkData = _f.Database.PokemonById[Utilities.toId(name..(forme and '-'..forme or ''))]
	if not pkData then
		pkData = _f.Database.PokemonById[Utilities.toId(name)] --only if the data does not exist in dex and instead serverPokemon
	end
	if not pkData then
		print("Invalid name is: ", name)
		_f.ServerError("Invalid Pokemon for Raid: " .. name, "PDS:maxRaidIcon, Line 411", script, self.player)
	end
	local types = pkData.types or {18}
	local icon = pkData.icon-1 or 136

	return {
		types=types,--todo
		icon=icon,
	}
end
function PlayerData:getHealing()
	self:heal()
	local balls = {}
	for _, p in pairs(self.party) do
		if not p.egg then
			table.insert(balls, p.pokeball or 1)
		end
	end
	return balls
end

function PlayerData:getDevHealing()
	local perms = self:GetPerms()
	if perms[2] then
		self:heal()
	else
		pcall(function()
			_f.Logger:logExploit(self.player,{
				exploit = "FN Abuse",
				extra = "Tried to abuse healing through a restricted FN without a valid whitelist."
			})
		end)
		self.player:Kick('Please avoid exploiting. Further exploitation can and will result in a permanent ban.')
	end
end



function PlayerData:getPokemonSummary(index)
	local battleSide = _f.BattleEngine:getBattleSideForPlayer(self.player)
	local pokemon, BattlePokemon
	if battleSide then
		-- 2v2
		if battleSide.battle.is2v2 then --?
			local lp = battleSide.battle.listeningPlayers
			local teamn = (lp[battleSide.id]==self.player) and 1 or 2
			--			local indexOffset = (teamn==2) and battleSide.nPokemonFromTeam1 or 0
			for _, BattlePokemon in pairs(battleSide.pokemon) do
				if BattlePokemon.teamn == teamn then
					index -= 1
					if index == 0 then
						--					if BattlePokemon.index == index then
						return self.party[BattlePokemon.originalPartyIndex]:getSummary(BattlePokemon)
					end
				end
			end
			return nil
		end

		if battleSide.isTwoPlayerSide and _f.Context == 'adventure' then --incase colo messes up fr            			
			index = index == 1 and 1 or index+1         
		end    
		--
		BattlePokemon = battleSide.pokemon[index]
		pokemon = self.party[BattlePokemon.index]
	else
		pokemon = self.party[index]
	end
	if not pokemon then return end
	return pokemon:getSummary(BattlePokemon or {})
end

function PlayerData:getMoveUser(moveId)
	for _, p in pairs(self.party) do
		if not p.egg then
			for _, m in pairs(p.moves) do
				if m.id == moveId then
					return p:getName()
				end
			end
		end
	end
end

function PlayerData:getCutter()
	if not self.badges[1] then return end
	return self:getMoveUser('cut')
end

function PlayerData:getDigger()
	return self:getMoveUser('dig')
end

function PlayerData:getHeadbutter()
	return self:getMoveUser('headbutt')
end

local rockSmashEncounter
function PlayerData:getSmasher()
	if not self.badges[5] then return end
	local pName = self:getMoveUser('rocksmash')
	if pName then
		local model = storage.Models.BrokenRock:Clone()
		model.Parent = self.player:WaitForChild('PlayerGui')
		local enc
		if self:random2(3) == 2 then
			if not rockSmashEncounter then
				rockSmashEncounter = require(storage.Data.Chunks).rockSmashEncounter
			end
			enc = rockSmashEncounter
		end
		return pName, model, enc
	end
end

function PlayerData:getClimber()
	if not self.badges[6] then return end
	return self:getMoveUser('rockclimb')
end

function PlayerData:getHappiness()
	local p = self:getFirstNonEgg()
	if not p then return end
	local h = p.happiness
	local n = 'Your '..p.name..'...'
	if h >= 255 then
		return {n, 'It\'s extremely friendly toward you.', 'It couldn\'t possibly love you more.', 'It\'s a pleasure to see!'}
	elseif h >= 200 then
		return {n, 'It seems to be very happy.', 'It\'s obviously friendly toward you.'}
	elseif h >= 150 then
		return {n, 'It\'s quite friendly toward you.', 'It seems to want to be babied a little.'}
	elseif h >= 100 then
		return {n, 'It\'s getting used to you.', 'It seems to believe in you.'}
	elseif h >= 50 then
		return {n, 'It\'s not very used to you yet.', 'It neither loves nor hates you.'}
	elseif h > 0 then
		return {n, 'It\'s very wary.', 'It has a scary look in its eyes.', 'It doesn\'t like you much at all.'}
	end
	return {n, 'This is a little hard for me to say...', 'Your pokemon simply detests you.', 'Doesn\'t that make you uncomfortable?'}
end

function PlayerData:getDex()
	return self.pokedex
end

function PlayerData:getCardInfo()
	return {
		name = self.trainerName,
		dex = select(2, self:countSeenAndOwnedPokemon()),
		badges = Utilities.map({1,2,3,4,5,6,7,8}, function(i) return self.badges[i] and 1 or 0 end),
		money = self.money,
		bp = self.bp,
		tix = self.tix
	}
end

function PlayerData:getFilteredString(text)
	local s, r = pcall(function()
		return game:GetService('TextService'):FilterStringAsync(text, self.player.UserId)
	end)

	if s and r then
		return r:GetNonChatStringForBroadcastAsync()
	else
		warn("couldn't filter text T_T (thank you roblox textservice api)")
		return self.player.Name
	end
end

function PlayerData:chooseName(tName)
	local fname = self:getFilteredString(tName)
	if not fname or fname == '' then
		warn("didnt get name for some reason")
		self.trainerName = self.player.Name
	end

	self.trainerName = fname
end

function PlayerData:approveNickname(name)
	return self:getFilteredString(name)
end

function PlayerData:getBattleTeam(ignoreHPState, teamPreviewOrder) -- todo: connect team preview
	if ignoreHPState and teamPreviewOrder then
		local team = {}
		for teamIndex, partyIndex in pairs(teamPreviewOrder) do
			team[teamIndex] = self.party[partyIndex]:getBattleData(true)
		end
		return team
	end

	local team = {}
	local fainted = {}
	for _, p in pairs(self.party) do
		local d = p:getBattleData(ignoreHPState)
		if (ignoreHPState or p.hp > 0) and not p.egg then
			table.insert(team, d)
		else
			table.insert(fainted, d)
		end
	end
	assert(#team > 0, 'No healthy Pokemon')
	for _, d in pairs(fainted) do
		table.insert(team, d)
	end
	return team
end

function PlayerData:ServerPortal()
	local do_debug = true
	local portalSpawns = {
		'chunk91992',  --// Lagoona Lake
		'chunk91993', --// Route 9
		'chunk91994', --// Route 10 
		'chunk91995', --// Route 11
		'chunk91996', --// Route 12 
		'chunk91997', --// Route 15
		'chunk91998', --// Cosmeos Valley 
	}
	local min = game:GetService('Lighting'):GetMinutesAfterMidnight()
	local isDay = (min > 6.5*60 and min < (17+5/6)*60 and true or false)
	if not _f.portalLocation then --10mins per new location
		local rng = portalSpawns[math.random(1, #portalSpawns)]
		local sTime = os.time()
		_f.portalLocation = {location=rng,sTime=sTime}
	end
	if isDay then _f.portalLocation = false end --reset at night (server)
	--check time of day
	if do_debug then
		return {location = 'chunk9'}
	else
		return _f.portalLocation
	end
end

function PlayerData:getMarshadowBattle()
	if not table.find(_f.PortalLocations, self.currentChunk) then return false end
	return require(storage.Data.Chunks).MarshEnc
end

function PlayerData:newPokemon(data)
	return _f.ServerPokemon:new(data, self)
end

function PlayerData:startNewGame(gamemode)
	if self.gameBegan then return false end
	self.gameBegan = true
	local Objective = _f.Database.Objectives.Default
	_f.Network:post('newObjective', self.player, Objective.Texts, Objective.Mark)
	self:onGameBegin(gamemode)
end

function PlayerData:continueGame(gamemode)
	if self.gameBegan then --[[ERROR]] return false end
	local k = gamemode
	if not k then
		k = "adventure"
	end
	if not self.noData then
		self.noData = {}
	end
	if self.noData[k] then
		return 
	end

	local data, pcData = self:getSaveData(gamemode)
	if not data then --[[ERROR]] 
		self.noData[k] = true
		return false 
	end
	self.gameBegan = true
	self.loadedData = nil -- remove cached data

	pcall(function()
		if self:ownsGamePass('MoreBoxes', true) then
			if self.pc.maxBoxes == 8 then
				self.pc.maxBoxes = 50
			end
		end
		if self:ownsGamePass('PondPass', true) then
			self.flags.PondPass = true
			_f.Network:post('PondPassPassPurchased', self.player)
		end
	end)
	local etc = self:deserialize(data)
	if pcData then
		self:PC_deserialize(pcData)
	end
	self:onGameBegin(gamemode)
	return true, etc
end
function PlayerData:getLevelCap()
	local levelCap = 100
	if (self.gamemode == 'nuzlocke' or self.gamemode == 'random nuzlocke') then
		local badgeToLvl = {
			[1] = 25,
			[2] = 37,
			[3] = 50,
			[4] = 57,
			[5] = 66,
			[6] = 75,
			[7] = 83,
			[8] = 100
		}
		if not self.badges[1] then
			levelCap = 18
		end
		for index, lvl in ipairs(badgeToLvl) do
			if self.badges[1] and self.badges[index] then
				levelCap = lvl
			end
		end
	end

	return levelCap
end
function PlayerData:onGameBegin(gamemode)
	if self.gameBeganExtras then return end -- dispatch once
	self.gameBeganExtras = true
	-- cache game passes that may have been deleted (but the player has the key item for them still)
	-- or, if they own the pass but not the key item, give them the key item
	for _, passName in pairs({'ShinyCharm', 'AbilityCharm', 'OvalCharm'}) do
		local itemId = passName:lower()
		if self:getBagDataById(itemId, 5) then
			self.ownedGamePassCache[Assets.passId[passName] ] = true
		elseif self.ownedGamePassCache[Assets.passId[passName] ] then
			self:addBagItems({id = itemId, quantity = 1})
		end
	end
	-- the following passes have a special function to run when purchased, activate them
	for _, passName in pairs({'ExpShare', 'MoreBoxes', 'PondPass'}) do
		local passId = Assets.passId[passName]
		if self.ownedGamePassCache[passId] then
			self:onAssetPurchased(passId)
		end
	end
	pcall(function()
		if self:ownsGamePass('MoreBoxes', true) then
			if self.pc.maxBoxes == 8 then
				self.pc.maxBoxes = 50
			end
		end
		if self:ownsGamePass('PondPass', true) then
			self.flags.PondPass = true
			_f.Network:post('PondPassPassPurchased', self.player)
		end
	end)
	-- let the player know what these initial values are
	local firstNonEgg = self:getFirstNonEgg()
	if firstNonEgg then
		_f.Network:post('PDChanged', self.player,
			'firstNonEggLevel', firstNonEgg.level,
			'firstNonEggAbility', firstNonEgg:getAbilityName(),
			'money', self.money,
			'bp', self.bp,
			'tix', self.tix)
	end
	-- etc.
	self.gamemode = gamemode
	self:checkForHatchables(true)
	self:updatePlayerListEntry()
	if tonumber(os.date('%j')) ~= self.lastLottoTryDay then 
		self.lottoTries = 0
	end
end

local shopProducts = {
	[Assets.productId.MasterBall.Value] = {id = 'masterball', icon = 8820446373}

}

local function productValue(v)
	if typeof(v) == "Instance" and v:IsA("ValueBase") then
		return v.Value
	end
	return v
end
function PlayerData:onDevProductPurchased(id)
	if not id then return false end

	local attemptAutosave = false


	-- Starter Product
	if id == productValue(Assets.productId.Starter) then
		local s = self.starterProductStack
		if #s > 0 then
			table.remove(s, #s)()
			return true
		end
		return false

		-- Ash-Greninja
	elseif id == productValue(Assets.productId.AshGreninja) then
		local s = self.ashGreninjaProductStack
		if #s > 0 then
			table.remove(s, #s)()
			return true
		end
		return false

		-- Hoverboard
	elseif id == productValue(Assets.productId.Hoverboard) then
		local s = self.hoverboardProductStack
		if #s > 0 then
			table.remove(s, #s)()
			return true
		end
		return false

		-- Lotto Ticket
	elseif id == productValue(Assets.productId.LottoTicket) then
		self.ticket = math.random(1, 99999)
		attemptAutosave = true
		local s = self.lottoTicketProductStack
		if #s > 0 then
			table.remove(s, #s)()
		end

		if attemptAutosave then
			task.spawn(function()
				if self.lastSaveEtc then
					self:saveGame(self.lastSaveEtc)
				end
			end)
		end
		return true

		-- BP Products
	elseif id == productValue(Assets.productId.TenBP) then
		self:addBP(10, true, true)
		return true
	elseif id == productValue(Assets.productId.FiftyBP) then
		self:addBP(50, true, true)
		return true
	elseif id == productValue(Assets.productId.TwoHundredBP) then
		self:addBP(200, true, true)
		return true
	elseif id == productValue(Assets.productId.FiveHundredBP) then
		self:addBP(500, true, true)
		return true

		-- UMV Battery Products
	elseif id == productValue(Assets.productId.UMV1) then
		self:addBagItems({id = "umvbattery", quantity = 1})
		return true
	elseif id == productValue(Assets.productId.UMV3) then
		self:addBagItems({id = "umvbattery", quantity = 3})
		return true
	elseif id == productValue(Assets.productId.UMV6) then
		self:addBagItems({id = "umvbattery", quantity = 6})
		return true

		-- Money Products
	elseif id == productValue(Assets.productId._10kP) then
		self:addMoney(10000, true)
		return true
	elseif id == productValue(Assets.productId._50kP) then
		self:addMoney(50000, true)
		return true
	elseif id == productValue(Assets.productId._100kP) then
		self:addMoney(100000, true)
		return true
	elseif id == productValue(Assets.productId._200kP) then
		self:addMoney(200000, true)
		return true

		-- Tix Products
	elseif id == productValue(Assets.productId.TixPurchase) then
		self:addTix(5000)
		return true

		-- Stamp Spinner Products
	elseif id == productValue(Assets.productId.PBSpins1) then
		self.stampSpins = math.min(999, self.stampSpins + 1)
		_f.Network:post("uPBSpins", self.player, self.stampSpins)
		attemptAutosave = true

	elseif id == productValue(Assets.productId.PBSpins5) then
		self.stampSpins = math.min(999, self.stampSpins + 5)
		_f.Network:post("uPBSpins", self.player, self.stampSpins)
		attemptAutosave = true

	elseif id == productValue(Assets.productId.PBSpins10) then
		self.stampSpins = math.min(999, self.stampSpins + 10)
		_f.Network:post("uPBSpins", self.player, self.stampSpins)
		attemptAutosave = true

	elseif id == productValue(Assets.productId.RouletteSpinBasic)
		or id == productValue(Assets.productId.RouletteSpinBronze)
		or id == productValue(Assets.productId.RouletteSpinSilver)
		or id == productValue(Assets.productId.RouletteSpinGold)
		or id == productValue(Assets.productId.RouletteSpinDiamond) then

		self.rouletteSpins = 1
		self.currentRouletteTier = id
		_f.Network:post("doBoughtSpin", self.player)
		return true

	else
		local shopItem = shopProducts[id]
		if shopItem then
			local item = _f.Database.ItemById[shopItem.id]
			self:addBagItems({num = item.num, quantity = shopItem.qty or 1})
			_f.Network:post("ItemProductPurchased", self.player, item.name, shopItem.icon)
			return true
		else
			for g, list in pairs(Assets.productId.RoPowers) do
				for l, pId in pairs(list) do
					if id == productValue(pId) then
						_f.Network:post("rpActivate", self.player, g, l, RO_POWER_EFFECT_DURATION)
						self:ROPowers_setTimePurchasedAndLevelForPower(g, os.time(), l)
						self:ROPowers_save()
						return true
					end
				end
			end
		end
	end

	if attemptAutosave then
		task.spawn(function()
			if self.lastSaveEtc then
				self:saveGame(self.lastSaveEtc)
			end
		end)
		return true
	end

	warn("Unhandled dev product id:", id)
	return false
end
function PlayerData:onAssetPurchased(id) -- keep in mind this will be called at least once every session after the pass is purchased (protect it from multi-awarding)
	if id == Assets.passId.ExpShare then
		if not self:getBagDataById('expshare', 5) then
			self:addBagItems({id = 'expshare', quantity = 1})
			_f.Network:post('PDChanged', self.player, 'expShareOn', true) -- when initially given, automatically turn it on
		end
	elseif id == Assets.passId.MoreBoxes then
		if self.pc.maxBoxes == 8 then
			self.pc.maxBoxes = 50
			_f.Network:post('PCPassPurchased', self.player)
		end
	elseif id == Assets.passId.PondPass then
		self.flags.PondPass = true
		_f.Network:post('PondPassPassPurchased', self.player)
	end
end

function PlayerData:completeEvent(eventName, ...)
	if self.completedEvents[eventName] then return false end
	local event = _f.PlayerEvents[eventName]
	if not self.fakeEvents then
		self.fakeEvents = {}
	end
	if not event then return false end
	local function logEventCompleted(missing)
		_f.Logger:logExploit(self.player,{
			exploit = "Complete Event",
			extra = 'Tried to complete "'..eventName..'" without having "'..missing..'" completed.'
		})
		self.player:Kick("Please avoid exploiting. Further exploitation can and will result in a permanent ban.")
	end
	local r = event
	local pseudo = false
	if type(event) == 'function' then
		r = event(self, ...)
	elseif type(event) == 'table' then
		if event.manual then return false end
		if event.pseudo then pseudo = true end
		if event.callback then
			r = event.callback(self, ...)
		end
		if event.DependsOn and not self.completedEvents[event.DependsOn] then
			logEventCompleted(event.DependsOn)
			return
		end
	elseif type(event) == "string" then
		if not self.completedEvents[event] then
			logEventCompleted(event)
			return
		end
		-- todo: continue to fill cases
	end
	if r ~= false and not pseudo then
		self.completedEvents[eventName] = true
	end
	--Objectives
	if r ~= false and not pseudo then
		self.completedEvents[eventName] = true
		if _f.Database.Objectives.Events[eventName] then
			print('we got objective for '..eventName)
			local Objective = _f.Database.Objectives.Events[eventName]
			_f.Network:post('newObjective', self.player, Objective.Texts, Objective.Mark)
		end
	end
	return r
end

function PlayerData:completeEventServer(eventName, ...)
	if self.completedEvents[eventName] then return false end
	local event = _f.PlayerEvents[eventName]
	if event == nil then return false end
	local r = event
	if type(event) == 'function' then
		r = event(self, ...)
	elseif type(event) == 'table' then
		-- todo: other cases where server is concerned with the data in the table
		if type(event.pseudo) == 'function' and event.pseudo(self) then return false end
		if event.callback then
			r = event.callback(self, ...)
		end
	elseif r == false then
		r = nil
	end
	if r ~= false then
		self.completedEvents[eventName] = true
		_f.Network:post('eventCompleted', self.player, eventName) -- notify client
	end
	--Objectives
	if r ~= false then
		self.completedEvents[eventName] = true
		_f.Network:post('eventCompleted', self.player, eventName) -- notify client
		if _f.Database.Objectives.Events[eventName] then
			print('we got objective for '..eventName)
			local Objective = _f.Database.Objectives.Events[eventName]
			_f.Network:post('newObjective', self.player, Objective.Texts, Objective.Mark)
		end
	end
	return r
end
function PlayerData:giveStoryAbsol(slot)
	local hadSeenAbsol  = self:hasSeenPokemon(359)
	local hadOwnedAbsol = self:hasOwnedPokemon(359)
	local absol = self:newPokemon {
		name = 'Absol',
		level = 50,
		shinyChance = 2048,
		item = 534,
		moves = {{id = 'nightslash'},{id = 'psychocut'},{id = 'megahorn'},{id = 'detect'}}
	}
	local box, position
	if slot then
		box, position = self:PC_sendToStore(table.remove(self.party, slot), true)
	end
	table.insert(self.party, 1, absol)
	self:onOwnPokemon(359)
	self.absolMeta = {
		slot = slot, box = box, position = position,
		seen = hadSeenAbsol,
		owned = hadOwnedAbsol
	}
end

function PlayerData:undoGiveStoryAbsol()
	self:incrementBagItem('megakeystone', -1)
	self.flags.gotAbsol = nil
	if self.party[1].name == 'Absol' then
		table.remove(self.party, 1)
	end
	local meta = self.absolMeta
	if not meta then return end
	self.absolMeta = nil
	local slot, box, position = meta.slot, meta.box, meta.position
	if slot and box and position then
		table.insert(self.party, slot, _f.ServerPokemon:deserialize(self.pc.boxes[box][position][3], self))
		self.pc.boxes[box][position] = nil
	end
	if not meta.seen  then self:unseePokemon(359) end
	if not meta.owned then self:unownPokemon(359) end
end

function PlayerData:getStarterData()
	local starters = {}
	local randomized = { 
		'Bulbasaur',  'Charmander', 'Squirtle',
		'Chikorita',  'Cyndaquil',  'Totodile',
		'Treecko',    'Torchic',    'Mudkip',
		'Turtwig',    'Chimchar',   'Piplup',
		'Snivy',      'Tepig',      'Oshawott',
		'Chespin',    'Fennekin',   'Froakie',
		'Rowlet',     'Litten',     'Popplio',
		'Grookey',    'Scorbunny',  'Sobble',
		'Sprigatito', 'Fuecoco',    'Quaxly',
	}
	if self.gamemode == 'randomizer' then
		local rngTbl = _f.randomizePoke(#randomized)
		randomized = {}
		for i=1, #rngTbl do
			local poke = rngTbl[i]
			if poke[2] then
				randomized[i] = poke[1]..'-'..poke[2]
			else
				randomized[i] = poke[1]
			end
		end
	end
	for i, v in pairs(randomized) do
		if _f.Database.GifData._FRONT[v] then --Should be checked for anyways
			starters[i] = {v, _f.Database.GifData._FRONT[v]}
		else
			starters[i] = {v, _f.Database.GifData._FRONT['Bidoof-ray']}
		end
	end
	return starters
end

function PlayerData:buyStarter(species)
	if not species then return false end
	if self.gamemode ~= 'randomizer' then
		local valid = {
			Bulbasaur = true,  Charmander = true, Squirtle = true,
			Chikorita = true,  Cyndaquil  = true, Totodile = true,
			Treecko   = true,  Torchic    = true, Mudkip   = true,
			Turtwig   = true,  Chimchar   = true, Piplup   = true,
			Snivy     = true,  Tepig      = true, Oshawott = true,
			Chespin   = true,  Fennekin   = true, Froakie  = true,
			Rowlet    = true,  Litten     = true, Popplio  = true,
			Grookey   = true,  Scorbunny  = true, Sobble   = true,
			Sprigatito = true, Fuecoco = true,    Quaxly = true,
		}
		if not valid[species] then return false end
	end

	local sendToPC = false
	local processed = false
	local pokemon
	table.insert(self.starterProductStack, function()
		if string.find(species, '-') and not (_f.validSpecies[string.lower(species)]) then
			species = string.split(species, '-')
		else
			species = {species, nil}
		end
		if processed then return end
		pokemon = self:newPokemon {
			name = species[1],
			forme  = species[2],
			level = 5,
			shinyChance = 2048,
		}
		if sendToPC then
			self:PC_sendToStore(pokemon)
			return
		end
		processed = true
		-- defer storage until after nickname
	end)
	game:GetService('MarketplaceService'):PromptProductPurchase(self.player, Assets.productId.Starter.Value)
	for i = 1, 20 do
		wait(.5)
		if processed then break end
	end
	if not processed then
		-- timed out
		sendToPC = true
		return 'to'
	end
	if pokemon then
		return {
			d = self:createDecision {
				callback = function(_, nickname)
					if type(nickname) == 'string' then
						pokemon:giveNickname(nickname)
					end
					local box = self:caughtPokemon(pokemon)
					if box then
						return pokemon:getName() .. ' has been transferred to Box ' .. box .. '!'
					end
				end
			},
			i = pokemon:getIcon(),
			s = pokemon.shiny
		}
	end
	-- is there a condition that reaches here?
end

function PlayerData:buyAshGreninja()
	if #self.party > 5 then return 'fp' end
	local sendToPC = false
	local processed = false
	local pokemon
	table.insert(self.ashGreninjaProductStack, function()
		if processed then return end
		pokemon = self:newPokemon {
			name = 'Greninja',
			forme = 'bb',
			level = 36,
			shinyChance = 2048,
			ot = 12301,
			moves = {
				{id = 'watershuriken'},{id = 'aerialace'},
				{id = 'doubleteam'},   {id = 'nightslash'}
			}
		}
		if sendToPC then
			-- processed after timeout, store without nicknaming
			self:PC_sendToStore(pokemon)
			return
		end
		processed = true
		-- defer storage until after nickname
	end)
	game:GetService('MarketplaceService'):PromptProductPurchase(self.player, Assets.productId.AshGreninja.Value)
	for i = 1, 20 do
		wait(.5)
		if processed then break end
	end
	if not processed then
		-- timed out
		sendToPC = true
		return 'to'
	end
	if pokemon then
		return {
			d = self:createDecision {
				callback = function(_, nickname)
					if type(nickname) == 'string' then
						pokemon:giveNickname(nickname)
					end
					local box = self:caughtPokemon(pokemon)
					if box then
						return pokemon:getName() .. ' has been transferred to Box ' .. box .. '!'
					end
				end
			},
			i = pokemon:getIcon(),
			s = pokemon.shiny
		}
	end
end

function PlayerData:completedEggCycle()
	local now = tick()
	local duration = tick()-self.lastCompletedEggCycle
	local maxStepTime = (self.currentHoverboard~='' and self.hoverboardModel) and (self.currentHoverboard:sub(1,6)=='Basic ' and 20 or 15) or 30
	if duration < maxStepTime then--30 then
		-- TODO
		return
	end
	self.lastCompletedEggCycle = now

	local party = self.party
	self:Daycare_tryBreed()
	local reduceBy = 1
	for _, p in pairs(party) do
		local a = p:getAbilityName()
		if not p.egg and (a == 'Flame Body' or a == 'Magma Armor') then
			reduceBy = 2
			break
		end
	end
	reduceBy = reduceBy * (1 + self:ROPowers_getPowerLevel(2))
	for _, p in pairs(party) do
		if p.egg then
			if not p.fossilEgg then
				p.eggCycles = p.eggCycles - reduceBy
			end
		else
			p:addHappiness(2, 2, 1)
		end
	end
	self:checkForHatchables()
	-- add 256 Exp. to Pokemon in the Day Care
	for _, p in pairs(self.daycare.depositedPokemon) do
		p.experience = p.experience + 256
	end
end

function PlayerData:rearrangeParty(indices)
	if self:isInBattle() then return end
	local nParty = #self.party
	if #indices ~= nParty then return end
	local ii = {}
	local vv = {}
	for i, v in pairs(indices) do
		if type(i) ~= 'number' or i > nParty or type(v) ~= 'number' or v > nParty then return end
		if ii[i] or vv[v] then return end -- clone attempt
		ii[i] = true
		vv[v] = true
	end
	for i = 1, nParty do if not ii[i] or not vv[i] then return end end
	local party = {}
	for i = 1, nParty do
		party[i] = self.party[indices[i]]
	end
	self.party = party
	local firstNonEgg = self:getFirstNonEgg()
	_f.Network:post('PDChanged', self.player, 'firstNonEggLevel', firstNonEgg.level,
		'firstNonEggAbility', firstNonEgg:getAbilityName())
end

-- BGC Here, battle bag bs is under 

local battleBagTypes = {
	normal = {
		pouches = {1, 2, 3, 4},
	},
	safari = {
		pouches = {4},
		modify = function(item)    
			if item.isBerry then
				item.battleCategory = 1
			end

			return item
		end,    
	},
}

function PlayerData:getBattleBag()
	if not self:isInBattle() then return end

	local side, battle = _f.BattleEngine:getBattleSideForPlayer(self.player)
	local bags = {{},{},{}}
	local Type = "normal"

	if battle.isSafari then  
		Type = "safari"
	end

	local bagTypeData = battleBagTypes[Type]

	for i, n in pairs(bagTypeData.pouches) do
		for _, bd in pairs(self.bag[n]) do
			local item = Utilities.deepcopy(_f.Database.ItemByNumber[bd.num])

			if bagTypeData.modify then
				item = bagTypeData.modify(item)
			end    

			if item and item.battleCategory then
				table.insert(bags[item.battleCategory], {
					id = item.id,
					name = item.name,
					icon = item.icon or item.num,
					qty = bd.quantity,
					desc = item.desc,
					isBerry = item.isBerry,
					bUse = item.isPokeball or type(item.onUse) == 'function',
					bCat = item.battleCategory
				})
			end
		end
	end

	return bags, Type
end

function PlayerData:getBagDataForTransfer(item, bd, context) -- helper function
	local itemId = item.id
	local canUse
	local usableItemClient = UsableItemsClient[itemId]
	if not usableItemClient or not usableItemClient.canUse then
		local usableItemServer = _f.UsableItems[itemId]
		if usableItemServer then
			local s_canUse = usableItemServer.canUse
			if s_canUse then
				if type(s_canUse) == 'function' then
					canUse = {}
					for i, p in pairs(self.party) do
						canUse[tostring(i)] = s_canUse(p) -- stupid table limitations...
					end
				else
					canUse = s_canUse
				end
			end
		end
	end
	return {
		id = itemId,
		name = item.name,
		icon = item.icon or item.num,
		qty = (item.bagCategory~=5 or item.showsQuantity) and bd.quantity or nil,
		desc = item.desc,
		canUse = canUse, -- true or false or a table of true/false (1 for each pokemon in party)
		-- ^ exists when UsableItemsServer has a canUse function but UsableItemsClient doesn't

		sell = (context=='sell' and item.sellPrice or nil),
	}
end

function PlayerData:getBagPouch(n, context)
	local pouch = {}
	local count = 0
	for _, bd in pairs(self.bag[n]) do
		local item = _f.Database.ItemByNumber[bd.num]
		count = count + 1
		pouch[count] = self:getBagDataForTransfer(item, bd, context)
	end
	return pouch
end

function PlayerData:getTMs()
	local list = {}

	local partyKnownMoves = {}
	local partyLearnedMachines = {}
	for i, p in pairs(self.party) do
		local k = {}
		local l = {}
		if not p.egg then
			for _, move in pairs(p:getMoves()) do
				k[move.num] = true
			end
			pcall(function()
				for _, num in pairs(p:getLearnedMoves().machine) do
					l[num] = true
				end
			end)
		end
		partyKnownMoves[i] = k
		partyLearnedMachines[i] = l
	end

	local buffer = BitBuffer.Create()
	local function add(str, isHMs)
		buffer:FromBase64(str)
		local data = _f.Database.Machines[isHMs and 'hms' or 'tms']
		for m = 1, str:len()*6 do
			if buffer:ReadBool() then
				local moveId = data[m]
				local move = _f.Database.MoveById[moveId]
				local moveNum = move.num
				local canLearn = {}
				for i, p in pairs(self.party) do
					canLearn[i] = (partyKnownMoves[i][moveNum] and 2) or (partyLearnedMachines[i][moveNum] and 1) or 0
				end
				list[#list+1] = {
					mName = move.name,
					num = m,
					hm = isHMs,
					type = move.type,
					desc = move.category..', '..move.type..'-type, '..(move.basePower or 0)..' Power,\n'..(move.accuracy==true and '--' or ((move.accuracy or 0)..'%'))..' Accuracy'..((move.desc and move.desc~='') and ('. Effect: '..move.desc) or ''),
					learn = canLearn
				}
			end
		end
	end
	add(self.tms)
	add(self.hms, true)

	return list
end

function PlayerData:teachTM(pokemonIndex, tmNum, isHM)
	-- verify arguments
	local moveId;  pcall(function() moveId  = _f.Database.Machines[isHM and 'hms' or 'tms'][tmNum] end)
	local pokemon; pcall(function() pokemon = self.party[pokemonIndex] end)
	if not moveId or not pokemon or pokemon.egg then return false end
	-- verify player owns TM/HM
	if not BitBuffer.GetBit(isHM and self.hms or self.tms, tmNum) then return false end
	-- verify pokemon can learn TM/HM
	local canLearn = false
	pcall(function()
		local moveNum = _f.Database.MoveById[moveId].num
		for _, num in pairs(pokemon:getLearnedMoves().machine) do
			if num == moveNum then
				canLearn = true
				break
			end
		end
	end)
	if not canLearn then return false end
	-- verify pokemon doesn't already know the move
	for _, move in pairs(pokemon.moves) do
		if move.id == moveId then
			return false
		end
	end
	-- learn immediately if there is space
	if #pokemon.moves < 4 then
		pokemon.moves[#pokemon.moves+1] = {id = moveId}
		return true
	end
	-- gather data about known moves and the move to learn
	local moves = {}
	local function add(move)
		moves[#moves+1] = {
			name = move.name,
			category = move.category,
			type = move.type,
			power = move.basePower,
			accuracy = move.accuracy,
			pp = move.pp,
			desc = move.desc
		}
	end
	for _, move in pairs(pokemon.moves) do
		if move.id == moveId then return false end -- make sure move is not already known
		add(_f.Database.MoveById[move.id])
	end
	add(_f.Database.MoveById[moveId])
	-- send data & new decision id to player
	return moves, self:createDecision {
		callback = function(_, moveSlot)
			if type(moveSlot) ~= 'number' or moveSlot < 1 or moveSlot > 4 then return end
			pokemon.moves[math.floor(moveSlot)] = {id = moveId}
		end
	}
end

function PlayerData:useItem(itemId, targetIndex, _index)
	if not itemId or type(itemId) ~= 'string' then return false end
	local usableItemServer = _f.UsableItems[itemId]
	local usableItemClient = UsableItemsClient[itemId]
	-- .noTarget and .nonConsumable are preferred to be placed on the client's usableItem (or else the client will be confused
	local hasTarget = not ((usableItemServer and usableItemServer.noTarget) or (usableItemClient and usableItemClient.noTarget))
	local consume = not ((usableItemServer and usableItemServer.nonConsumable) or (usableItemClient and usableItemClient.nonConsumable))
	if (targetIndex ~= nil) ~= (hasTarget and true or false) then return false end
	local target
	if hasTarget then
		target = self.party[targetIndex]
		if not target then return false end
	end

	if itemId == 'rarecandy' then
		if not usableItemServer.canUse(target) then return false end
	end

	local item = _f.Database.ItemById[itemId]
	if not item then return false end
	local bd = self:getBagDataByNum(item.num)
	if not bd or not bd.quantity or bd.quantity < 1 then return false end
	local used
	if usableItemServer and usableItemServer.onUse then
		used = usableItemServer.onUse(target, _index)
		if used == false then return false end
	end
	if consume then

		local _, bd = self:incrementBagItem(item.num, -1) -- qty verified above
		if itemId:match('repel$') then -- repels report whether there are any remaining
			return (bd and bd.quantity and bd.quantity > 0) and 1 or 0
		end
	end
	return used, (target and target:getPartyData({}))
end

function PlayerData:isAdventure()
	return game.PlaceId == Assets.placeId.Main
end

function PlayerData:giveItem(itemId, pokemonIndex)
	if not itemId or type(itemId) ~= 'string' or not pokemonIndex or type(pokemonIndex) ~= 'number' then print('err 1') return false end

	if itemId == "safariball" then 
		if require(storage.Data.Chunks)[self.currentChunk].isSafari or not self:isAdventure() then
			return false, "sf" 
		end	
	end

	local item = _f.Database.ItemById[itemId]
	local pokemon = self.party[pokemonIndex]
	if not item or not pokemon or pokemon.egg then print('no item no pokemon') return false end
	if item.bagCategory == 6 then  --zmove
		local mon = self.party[pokemonIndex]
		if not mon:canUseZCrystal(itemId) then 
			return false, 'nocrystal'
		end
	end
	if not item.bagCategory or (item.bagCategory == 5) then print('invalid bagcategory') return false end -- check whether it can even be held
	if not item.zMove then
		if not self:incrementBagItem(item.num, -1) then print('no increment') return false end
	end
	local taking = pokemon:getHeldItem()
	local takenBD
	if taking.num then
		local s, r = self:incrementBagItem(taking.num, 1)
		if s then takenBD = r end
	end
	pokemon.item = item.num
	return true, (takenBD and self:getBagDataForTransfer(taking, takenBD)), (takenBD and taking.bagCategory)
end

function PlayerData:takeItem(pokemonIndex)
	if not pokemonIndex or type(pokemonIndex) ~= 'number' then return false end
	local pokemon = self.party[pokemonIndex]
	if not pokemon or pokemon.egg then return false end
	local item = pokemon:getHeldItem()
	if not item.num then return false end
	if item.zMove then
		pokemon.item = nil
		return true
	else
		local s, bd = self:incrementBagItem(item.num, 1)
		if not s then return false end
		pokemon.item = nil
		return true, self:getBagDataForTransfer(item, bd), item.bagCategory
	end
end

function PlayerData:tossItem(itemId, amount) 
	if not itemId or type(itemId) ~= 'string' or not amount or type(amount) ~= 'number' or amount < 1 then return false end
	local item = _f.Database.ItemById[itemId]
	if not item or not item.bagCategory or item.bagCategory > 4 or itemId == 'masterball' or item.zMove then return false end -- check whether it can be tossed
	if not self:incrementBagItem(item.num, -amount) then return false end
	return true
end

function PlayerData:deleteMove(pokemonIndex)
	if not pokemonIndex or not self.party[pokemonIndex] then return end
	local pokemon = self.party[pokemonIndex]
	if pokemon.egg then return 0, 'eg' end
	if #pokemon.moves == 0 then return 0, '0m' end
	if #pokemon.moves == 1 then return pokemon.name, '1m' end
	return pokemon.name, {
		moves = pokemon:getCurrentMovesData(),
		d = self:createDecision {
			callback = function(_, moveslot)
				if not moveslot or not pokemon.moves[moveslot] then return end
				table.remove(pokemon.moves, moveslot)
			end
		}
	}
end

function PlayerData:remindMove()
	local heartscale = _f.Database.ItemById.heartscale
	local nHeartScales = 0
	pcall(function() nHeartScales = self:getBagDataByNum(heartscale.num, 1).quantity end)
	return {
		hsi = heartscale.icon or heartscale.num,
		nhs = nHeartScales,
		money = self.money,
		d = self:createDecision {
			callback = function(_, pokemonIndex)
				if not pokemonIndex or not self.party[pokemonIndex] then return end
				local pokemon = self.party[pokemonIndex]
				if pokemon.egg then return 0, 'eg' end

				local learnedMoves
				pcall(function() learnedMoves = pokemon:getLearnedMoves().levelUp end)
				local moves = {}
				if learnedMoves then
					-- get moves by level (earliest learned to latest learned)
					local level = pokemon.level
					for _, d in pairs(learnedMoves) do
						if level < d[1] then break end
						for i = 2, #d do
							table.insert(moves, d[i])
						end
					end
					-- remove duplicate moves
					for i, move in pairs(moves) do
						for j = #moves, i+1, -1 do
							if move == moves[j] then
								table.remove(moves, j)
							end
						end
					end
					-- remove currently known moves
					for _, move in pairs(pokemon:getMoves()) do
						for j = #moves, 1, -1 do
							if move.num == moves[j] then
								table.remove(moves, j)
								break
							end
						end
					end
				end
				if #moves == 0 then return pokemon.name, 'nm' end
				local validMovesNumToId = {}
				for i, moveNum in pairs(moves) do
					local move = _f.Database.MoveByNumber[moveNum]
					moves[i] = {
						num = move.num,
						name = move.name,
						category = move.category,
						type = move.type,
						power = move.basePower,
						accuracy = move.accuracy,
						pp = move.pp,
						desc = move.desc
					}
					validMovesNumToId[moveNum] = move.id
				end

				return pokemon.name, {
					nn = pokemon:getName(),
					known = pokemon:getCurrentMovesData(),
					moves = moves,
					d = self:createDecision {
						callback = function(_, paymentMethod, moveNum, moveSlot)
							if (paymentMethod ~= 1 and paymentMethod ~= 2)
								or (moveSlot ~= 1 and moveSlot ~= 2 and moveSlot ~= 3 and moveSlot ~= 4) then
								return
							end
							local moveId = validMovesNumToId[moveNum]
							if not moveId then return end
							if paymentMethod == 1 then
								if not (self:incrementBagItem(heartscale.num, -1)) then return end
							else
								if not (self:addMoney(-30000)) then return end
							end
							pokemon.moves[moveSlot] = {id = moveId}
						end
					}
				}
			end
		}
	}
end

local getShop = require(script.GetShop)
function PlayerData:getShop(shopId)
	local items, other = getShop(self, shopId)
	if not items then return false end
	self.currentShop = items
	return items, other
end

function PlayerData:getChainInfo()
	local chain = self.captureChain.chain
	local defaultChances = {
		4096, --Shiny
		1500, --Roaming
		512 --HA
	}
	local percentiles = {0, 0, 1, 0}
	local function doCalc(chance, changePoint)
		return math.floor(chance * math.max(.025, math.cos(math.min(chain, 1000)/changePoint*math.pi/2)))
	end
	if chain >= 1 then
		local newShiny =  doCalc(defaultChances[1], 200)--math.floor(defaultChances[1]/(chain/12))
		local newRoam = doCalc(defaultChances[2], 200)
		local newHA = doCalc(defaultChances[3], 200)
		if newShiny <= 25 then
			newShiny = 25
		end
		if newRoam <= 29 then
			newRoam = 29
		end
		if newHA <= 25 then
			newHA = 25
		end
		percentiles[1] = tostring(math.floor(((defaultChances[1]-newShiny)/defaultChances[1])*100))
		percentiles[2] = tostring(math.floor(((defaultChances[2]-newRoam)/defaultChances[2])*100))
		percentiles[3] = tostring(math.floor(((defaultChances[3]-newHA)/defaultChances[3])*100))
	end

	if chain >= 31 then
		percentiles[4] = 4
	elseif chain >= 21 then
		percentiles[4] = 3
	elseif chain >= 11 then --So guaranteed 3x31 aren't wiped
		percentiles[4] = 2
	end
	return table.unpack(percentiles)
end

function PlayerData:maxBuyInternal(itemId)
	if not self.currentShop then return false end
	pcall(function() itemId = Utilities.rc4(itemId) end)
	if type(itemId) ~= 'string' then return false end
	local item = _f.Database.ItemById[itemId]
	if not item then return false end
	local price
	for _, l in pairs(self.currentShop) do
		if Utilities.rc4(l[1]) == itemId then
			price = l[2]
			break
		end
	end
	if not price then return false end
	local currentQty = 0
	local bd = self:getBagDataByNum(item.num)
	if bd then
		currentQty = bd.quantity or 0
	end
	if currentQty >= 99   then return 'fb' end -- full bag
	if self.money < price then return 'nm' end -- not enough money
	return math.min(99-currentQty, math.floor(self.money/price)), item, price
end
function PlayerData:maxBuy(itemId) -- rc4'd (from client)
	return (self:maxBuyInternal(itemId)) -- return single value to client
end

function PlayerData:buyItem(itemId, qty) -- rc4'd
	local max, item, price = self:maxBuyInternal(itemId)
	if type(max) ~= 'number' or not item or not price or qty > max or qty < 1 then return false end
	qty = math.floor(qty)
	if not self:addMoney(-price*qty) then return false end
	self:addBagItems{num = item.num, quantity = qty}
	local givePremierBall = false
	if item.isPokeball and qty > 9 then
		self:addBagItems{id = 'premierball', quantity = 1}
		givePremierBall = true
	end
	return true, givePremierBall
end

function PlayerData:bMaxBuyInternal(shopIndex)
	if not self.currentShop then return false end
	local itemIdPricePair = self.currentShop[shopIndex]
	if type(itemIdPricePair) ~= 'table' then return false end
	local itemId = itemIdPricePair[1]
	if type(itemId) ~= 'string' then return false end
	local price = itemIdPricePair[2]
	if type(price) ~= 'number' then return false end
	if itemId:sub(1, 2) == 'BP' then return false end -- assumption: no items sold here later will start with "BP"
	local tmNum = itemId:match('^TM(%d+)')
	if tmNum then
		tmNum = tonumber(tmNum)
		if BitBuffer.GetBit(self.tms, tmNum) then return 'ao' end -- already own
		if self.bp < price then return 'nm' end
		return 'tm', tonumber(tmNum), price
	end
	local item = _f.Database.ItemById[itemId]
	if not item then return false end
	local currentQty = 0
	local bd = self:getBagDataByNum(item.num)
	if bd then
		currentQty = bd.quantity or 0
	end
	if currentQty >= 99 then return 'fb' end -- full bag
	if self.bp < price  then return 'nm' end -- not enough money
	return math.min(99-currentQty, math.floor(self.bp/price)), item, price
end
function PlayerData:bMaxBuy(shopIndex)
	return (self:bMaxBuyInternal(shopIndex))
end

function PlayerData:buyWithBP(shopIndex, qty)
	local max, item, price = self:bMaxBuyInternal(shopIndex)
	if max == 'tm' then
		self:obtainTM(item)
		self.bp = self.bp - price
		return true, self.bp
	end
	if not item or type(max) ~= 'number' or type(qty) ~= 'number' or max < qty or qty < 1 then return false end
	qty = math.floor(qty)
	self.bp = self.bp - price*qty
	self:addBagItems{num = item.num, quantity = qty}
	return true, self.bp
end

function PlayerData:sellItem(itemId, qty) -- NOT rc4'd
	if type(itemId) ~= 'string' or type(qty) ~= 'number' or qty < 1 then return false end
	local item = _f.Database.ItemById[itemId]
	if not item or not item.sellPrice then return false end
	local bd = self:getBagDataByNum(item.num)
	qty = math.floor(qty)
	if not bd or not bd.quantity or bd.quantity < 1 or qty > bd.quantity then return false end
	if not self:addMoney(qty*item.sellPrice) then return 'fw' end
	self:incrementBagItem(item.num, -qty)
	return self.money
end

function PlayerData:obtainItem(id)
	if not self.currentObtainableItems then return end
	local item = self.currentObtainableItems[id]
	if not item then return end
	self.currentObtainableItems[id] = nil -- no repeat obtains
	if type(item) == 'number' then
		-- TM
		self:obtainTM(item)
		return 'TM'..(item<10 and '0' or '')..item
	elseif type(item) == 'table' then
		-- item
		local oin = item[2]
		item = _f.Database.ItemById[item[1] ]
		if not item then return end
		self.obtainedItems = BitBuffer.SetBit(self.obtainedItems, oin, true)
		self:addBagItems({num = item.num, quantity = 1})
		return item.name
	end
end

function PlayerData:makeDecision(id, ...)
	if not id or type(id) ~= 'number' then return false end
	local data = self.decision_data[id]
	if not data then return false end
	local ret = {data.callback(data, ...)}
	if ret[1] == false then return false end
	self.decision_data[id] = false
	return unpack(ret)
end

function PlayerData:openPC()
	if self.pcSession then
		self.pcSession:close()
	end
	if self:isInBattle() then return end
	local newSession = _f.PCService:new(self)
	self.pcSession = newSession
	return newSession:getStartPacket()
end

function PlayerData:cPC(fn, ...)
	if type(fn) ~= 'string' then return end
	local pc = self.pcSession
	if not pc or not pc.public[fn] then return end
	return pc[fn](pc, ...)
end

function PlayerData:closePC(id, ch)
	local pc = self.pcSession
	if not pc then return end
	if id and pc.id ~= id then return end
	local ret = pc:close(ch)
	self.pcSession = nil
	return ret
end

function PlayerData:createDecision(data)
	assert(data.callback ~= nil, 'decision must include a callback')
	local id = self.decision_count + 1
	self.decision_count = id
	self.decision_data[id] = data
	return id
end

function PlayerData:checkForHatchables(forceClear)
	-- make sure that there isn't a queued hatch waiting
	for i, d in pairs(self.decision_data) do -- note that d can be `false`
		if d and d.hatch then
			if forceClear then
				self.decision_data[i] = false
			else
				return
			end
		end
	end
	-- check for hatchable egg in party
	for _, p in pairs(self.party) do
		if p.egg and not p.fossilEgg and p.eggCycles <= 0 then
			local id = self:createDecision {
				hatch = true,
				callback = function(data, nickname)
					-- hatch pokemon
					self:onOwnPokemon(p.num)
					p.egg = nil
					p.ot = self.userId
					if nickname and type(nickname) == 'string' then
						p:giveNickname(nickname)
					end
					-- check for another hatchable
					self:checkForHatchables(true)
				end
			}
			-- send event to player
			_f.Network:post('hatch', self.player, {
				d_id = id,
				eggIcon = p:getIcon(),
				pSprite = p:getSprite(true),
				pName = p.data.baseSpecies or p.data.species,
				pIcon = p:getIcon(true),
				pShiny = p.shiny and true or false
			})
			-- only allow one at a time
			return
		end
	end
end

function PlayerData:resetFishStreak()
	self.fishingStreak = 0
end

function PlayerData:getRegion()
	-- not perfect, just gives a best guess (can only be depended on when player is assumed to be outdoors)
	if not self.currentChunk then return end
	local chunkData = _f.Database.ChunkData[self.currentChunk]
	if chunkData then
		local onlyRegion
		for name in pairs(chunkData.regions) do
			if not onlyRegion then
				onlyRegion = name
			else
				onlyRegion = nil
				break
			end
		end
		if onlyRegion then return onlyRegion end
	end
	local map = storage.MapChunks:FindFirstChild(self.currentChunk)
	if not map then return end
	local regions = map:FindFirstChild('Regions')
	if not regions then return end
	local pos; pcall(function() pos = self.player.Character.HumanoidRootPart.Position end)
	if not pos then return end
	for _, part in pairs(regions:GetChildren()) do
		if part:IsA('BasePart') then
			if Region.FromPart(part):CastPoint(pos) then
				return part.Name
			end
		end
	end
end


function PlayerData:addMoney(amount)
	if amount < 0 and self.money+amount < 0 then return false end
	if amount > 0 and self.money > MAX_MONEY then return false end
	self.money = math.min(self.money + amount, MAX_MONEY)
	_f.Network:post('PDChanged', self.player, 'money', self.money)
	return true
end

function PlayerData:addBP(amount, showGui)
	self.bp = math.min(self.bp + amount, MAX_BP)
	if showGui then
		_f.Network:post('bpAwarded', self.player, amount, self.bp)
	end
end

function PlayerData:ownsGamePass(passId, mustReturnInstantly)
	if self.userId < 1 then return false end
	if type(passId) == 'string' then
		passId = Assets.passId[passId]
	end
	if self.ownedGamePassCache[passId] then return true end
	if mustReturnInstantly then -- the old PD model checked once when the player entered whether the game pass was owned, so this behavior is acceptable (it's an improvement)
		spawn(function() self:ownsGamePass(passId) end) -- attempt to cache
		return false -- return false for now
	end
	local marketplaceService = game:GetService('MarketplaceService')
	local s, r = pcall(function() return self.player:IsInGroup(794929668) end)
	if r then
		self.ownedGamePassCache[passId] = true
		return true
	end
	return false
end

function PlayerData:updatePlayerListEntry(awardDexBadges)
	-- the PlayerList displays Name, badge icon, and Pokedex (or Rank in PVP)
	-- Name never changes; only badges and Pokedex[/Rank]
	local badgeId, ownedPokemon = self:getPlayerListInfo()
	local player = self.player
	local changed = false
	if not player:FindFirstChild('BadgeId') then
		Instance.new('IntValue', player).Name = 'BadgeId'
		changed = true
	end
	if not player:FindFirstChild('OwnedPokemon') then
		Instance.new('IntValue', player).Name = 'OwnedPokemon'
		changed = true
	end
	if not player:FindFirstChild('gamemode') then
		Instance.new('StringValue', player).Name = 'gamemode'
	end
	changed = changed or (badgeId ~= player.BadgeId.Value) or (ownedPokemon ~= player.OwnedPokemon.Value)
	if not changed then return end
	player.BadgeId.Value = badgeId
	player.OwnedPokemon.Value = ownedPokemon
	player.gamemode.Value = tostring(self.gamemode)
	network:postAll('UpdatePlayerlist', player.Name, badgeId, ownedPokemon, self.gamemode)
	if _f.Context ~= 'battle' and awardDexBadges then
		for _, badgeData in pairs(Assets.badgeId.DexCompletion) do
			local reqOwnedPokemon, badgeId = unpack(badgeData)
			if ownedPokemon >= reqOwnedPokemon then
				pcall(function() game:GetService('BadgeService'):AwardBadge(self.userId, badgeId) end)
			else
				break
			end
		end
	end
	return player.Name, badgeId, ownedPokemon
end

local BattleEloManager
function PlayerData:getPlayerListInfo()    
	local badgesByPlayerId = {

		--// Founder
		[5627521936] = 10313625280, --// Houndoomin1te
		[5046473125] = 14808111673, --// Budles

		--// Co-Founder
		[236162530] = 10968944935, --// JayLP
		[86670975] = 10511855986, --// Astral

	}
	local badgeId

	if not badgeId then 
		badgeId = badgesByPlayerId[self.userId]
	end

	if not badgeId then
		badgeId = table.find(_f.bgc_accs, self.userId) and 14824419035 or nil
	end

	pcall(function()
		local GStatus = self.player:GetRankInGroup(565786887)

		if not badgeId then
			if GStatus == 2 then
				badgeId = 11582964590 --// CCs
			elseif GStatus >= 243 and GStatus < 245 then
				badgeId = 12511864418 --// Bug Hunters & Testers
			elseif GStatus >= 245 and GStatus < 246 then
				badgeId = 11582940034 --// Developers
			elseif GStatus >= 246 and GStatus < 248 then
				badgeId = 11582929532 --// Moderation
			elseif GStatus >= 248 and GStatus < 251 then
				badgeId = 11582930414 --// Management
			elseif GStatus >= 251 and GStatus < 253 then
				badgeId = 11582931615 --// HRs
			end
		end
	end)

	if not badgeId then
		local latestBadge = 0
		for i, b in pairs(self.badges) do
			if b then
				latestBadge = math.max(latestBadge, i)
			end
		end
		badgeId = Assets.badgeImageId[latestBadge] or 0
	end

	local ownedPokemon
	-- if PVP, override pokedex with rank
	if _f.Context == 'battle' then
		if not BattleEloManager then
			BattleEloManager = require(script.Parent.BattleEngine.BattleEloManager)
		end
		ownedPokemon = BattleEloManager:getPlayerRank(self.player.UserId)
	else
		ownedPokemon = select(2, self:countSeenAndOwnedPokemon())
	end
	return badgeId, ownedPokemon
end

local function concatenate(s, ...)
	-- this is weird, yes, but there was actually a period of time
	-- where the concatenation operation seemed to randomly return 
	-- a partial version of what it should
	local function concatenateInner(a, b)
		local totalLen = a:len() + b:len()
		local c = a .. b
		local attempts = 0
		while c:len() ~= totalLen do
			attempts = attempts + 1
			if attempts > 5 then
				error('failed concatenation: failed too many times')
			end
			warn('failed concatenation: retrying')
			c = a .. b
		end
		return c
	end
	for _, o in pairs({...}) do
		s = concatenateInner(s, o)
	end
	return s
end


-- RO Powers
function PlayerData:purchaseRoPower(group, level)
	if self:ROPowers_getPowerLevel(group) > 0 then return end
	game:GetService('MarketplaceService'):PromptProductPurchase(self.player, Assets.productId.RoPowers[group][level].Value)
end

-- For most of these, g = group, t = time, l = level
function PlayerData:ROPowers_getPowerLevel(g)
	local ro = self.roPowers
	local l = ro.powerLevel[g]

	if l <= 0 then
		return 0
	end

	if ro.paused[g] then
		local remaining = ro.pausedRemaining[g] or 0
		if remaining <= 0 then
			ro.powerLevel[g] = 0
			ro.lastPurchasedAt[g] = 0
			ro.paused[g] = false
			ro.pausedRemaining[g] = 0
			return 0
		end
		return l
	end

	if os.time() - ro.lastPurchasedAt[g] > RO_POWER_EFFECT_DURATION then
		ro.powerLevel[g] = 0
		ro.lastPurchasedAt[g] = 0
		ro.paused[g] = false
		ro.pausedRemaining[g] = 0
		return 0
	end

	return l
end

function PlayerData:ROPowers_getTimePurchased(g)
	return self.roPowers.lastPurchasedAt[g]
end

function PlayerData:ROPowers_setTimePurchasedAndLevelForPower(g, t, l)
	local ro = self.roPowers
	ro.lastPurchasedAt[g] = t
	ro.powerLevel[g] = l
	ro.paused[g] = false
	ro.pausedRemaining[g] = 0
end

-- Pausing by Infrared
function PlayerData:ROPowers_pause(g)
	local ro = self.roPowers
	local currentLevel = self:ROPowers_getPowerLevel(g)

	if currentLevel > 0 and not ro.paused[g] then
		local now = os.time()
		local elapsed = now - ro.lastPurchasedAt[g]
		local remaining = math.max(0, RO_POWER_EFFECT_DURATION - elapsed)

		if remaining > 0 then
			ro.paused[g] = true
			ro.pausedRemaining[g] = remaining
		else
			ro.powerLevel[g] = 0
			ro.lastPurchasedAt[g] = 0
			ro.paused[g] = false
			ro.pausedRemaining[g] = 0
		end
	end

	self:ROPowers_save()
end

function PlayerData:ROPowers_resume(g)
	local ro = self.roPowers

	if ro.paused[g] then
		local remaining = ro.pausedRemaining[g] or 0

		if remaining > 0 and ro.powerLevel[g] > 0 then
			local now = os.time()
			ro.paused[g] = false
			ro.lastPurchasedAt[g] = now - (RO_POWER_EFFECT_DURATION - remaining)
			ro.pausedRemaining[g] = 0
		else
			ro.powerLevel[g] = 0
			ro.lastPurchasedAt[g] = 0
			ro.paused[g] = false
			ro.pausedRemaining[g] = 0
		end
	end

	self:ROPowers_save()
end

function PlayerData:ROPowers_save()
	local now = os.time()
	local buffer = BitBuffer.Create()
	local version = 2

	buffer:WriteUnsigned(6, version)

	for i = 1, 7 do
		local p = self:ROPowers_getPowerLevel(i)

		if p == 0 then
			buffer:WriteBool(false)
			buffer:WriteUnsigned(12, 0)
		else
			buffer:WriteBool(p == 2)

			if self.roPowers.paused[i] then
				local remaining = math.max(0, self.roPowers.pausedRemaining[i] or 0)
				buffer:WriteUnsigned(12, remaining)
				buffer:WriteBool(remaining > 0)
			else
				local s = RO_POWER_EFFECT_DURATION - math.ceil(now - self.roPowers.lastPurchasedAt[i])
				s = math.max(0, s)
				buffer:WriteUnsigned(12, s)
				buffer:WriteBool(false)
			end
		end
	end

	_f.DataPersistence.ROPowerSave(self.player, 'save', buffer:ToBase64())
end

function PlayerData:ROPowers_restore()
	local data = _f.DataPersistence.ROPowerSave(self.player, 'load')
	local ro = self.roPowers

	ro.powerLevel = {0, 0, 0, 0, 0, 0, 0}
	ro.lastPurchasedAt = {0, 0, 0, 0, 0, 0, 0}
	ro.paused = {false, false, false, false, false, false, false}
	ro.pausedRemaining = {0, 0, 0, 0, 0, 0, 0}

	if not data then
		return
	end

	local buffer = BitBuffer.Create()
	buffer:FromBase64(data)

	if data:len() > 20 then
		for i = 1, 7 do
			pcall(function()
				local isLv2 = buffer:ReadBool()
				local pTime = buffer:ReadFloat64()
				if pTime > ro.lastPurchasedAt[i] then
					ro.lastPurchasedAt[i] = pTime
					ro.powerLevel[i] = isLv2 and 2 or 1
					ro.paused[i] = false
					ro.pausedRemaining[i] = 0
				end
			end)
		end
		return
	end

	local now = os.time()
	local version = buffer:ReadUnsigned(6)

	for i = 1, 7 do
		local isLv2 = buffer:ReadBool()
		local s = buffer:ReadUnsigned(12)

		local isPaused = false
		if version >= 2 and s > 0 then
			isPaused = buffer:ReadBool()
		end

		if s <= 0 then
			ro.powerLevel[i] = 0
			ro.lastPurchasedAt[i] = 0
			ro.paused[i] = false
			ro.pausedRemaining[i] = 0
		elseif isPaused then
			ro.powerLevel[i] = isLv2 and 2 or 1
			ro.lastPurchasedAt[i] = 0
			ro.paused[i] = true
			ro.pausedRemaining[i] = math.max(0, s)
		else
			s -= 20 -- WE DEDUCT 20 SECONDS for the shiny soft-resetters

			if s > 0 then
				ro.powerLevel[i] = isLv2 and 2 or 1
				ro.lastPurchasedAt[i] = now - RO_POWER_EFFECT_DURATION + s
				ro.paused[i] = false
				ro.pausedRemaining[i] = 0
			else
				ro.powerLevel[i] = 0
				ro.lastPurchasedAt[i] = 0
				ro.paused[i] = false
				ro.pausedRemaining[i] = 0
			end
		end
	end
end

function PlayerData:roStatus()
	local now = os.time()
	local r = {}
	for i = 1, 7 do
		local p = self:ROPowers_getPowerLevel(i)
		if p > 0 then
			if self.roPowers.paused[i] then
				r[tostring(i)] = {p, math.max(0, self.roPowers.pausedRemaining[i] or 0)}
			else
				local remaining = self.roPowers.lastPurchasedAt[i] + RO_POWER_EFFECT_DURATION - now
				r[tostring(i)] = {p, math.max(0, remaining)}
			end
		end
	end
	local icons = {}
	for eventName, pokemonList in pairs(RoamingPokemon) do
		if self.completedEvents[eventName] then
			for _, enc in pairs(pokemonList) do
				icons[#icons+1] = _f.Database.PokemonById[Utilities.toId(enc[1])].icon-1
			end
		end
	end
	table.sort(icons)
	r.r = icons
	return r
end

function PlayerData:roPauseText()
	local ro = self.roPowers
	local r = {}
	for i = 1, 7 do
		local p = self:ROPowers_getPowerLevel(i)
		if p == 0 then
			r[tostring(i)] = "Inactive"
		elseif ro.paused[i] then
			r[tostring(i)] = "Paused"
		else
			r[tostring(i)] = "Pause?"
		end
	end
	return r
end

function PlayerData:roPauseStatus()
	local ro = self.roPowers
	local r = {}
	for i = 1, 7 do
		local p = self:ROPowers_getPowerLevel(i)
		if p == 0 then
			r[tostring(i)] = nil
		elseif ro.paused[i] then
			r[tostring(i)] = true
		else
			r[tostring(i)] = false
		end
	end
	return r
end

-- Party
function PlayerData:getFirstNonEgg()
	for _, p in pairs(self.party) do
		if not p.egg then
			return p
		end
	end
end

function PlayerData:heal()
	for _, p in pairs(self.party) do
		p:heal()
	end
end

function PlayerData:caughtPokemon(pokemon)
	if not pokemon.egg then
		self:onOwnPokemon(pokemon.num)
	end
	if not pokemon.ot then pokemon.ot = self.userId end
	for i = 1, 6 do
		if not self.party[i] then
			self.party[i] = pokemon
			-- OVH  send sprite to player to cache?
			return
		end
	end
	local box = (self:PC_sendToStore(pokemon))
	if box then
		return box--pokemon:getName() .. ' has been transferred to Box ' .. box .. '!'
	else
		-- OVH  need new backup system

	end
end

-- Pokedex
function PlayerData:onSeePokemon(num)
	self.pokedex = BitBuffer.SetBit(self.pokedex, num*2-1, true)
end

function PlayerData:onOwnPokemon(num)
	self:onSeePokemon(num)
	self.pokedex = BitBuffer.SetBit(self.pokedex, num*2, true)
	self:updatePlayerListEntry(true)
end

function PlayerData:hasSeenPokemon(num)
	return BitBuffer.GetBit(self.pokedex, num*2-1)
end

function PlayerData:hasOwnedPokemon(num)
	return BitBuffer.GetBit(self.pokedex, num*2)
end

function PlayerData:unseePokemon(num)
	self.pokedex = BitBuffer.SetBit(self.pokedex, num*2-1, false)
end

function PlayerData:unownPokemon(num)
	self.pokedex = BitBuffer.SetBit(self.pokedex, num*2, false)
	self:updatePlayerListEntry()
end

function PlayerData:countSeenAndOwnedPokemon(str)
	str = str or self.pokedex
	local seen = 0
	local owned = 0
	local buffer = BitBuffer.Create()
	buffer:FromBase64(str)
	for _ = 1, str:len()*3 do
		if buffer:ReadBool() then
			seen = seen + 1
		end
		if buffer:ReadBool() then
			owned = owned + 1
		end
	end
	return seen, owned
end

-- Badges
function PlayerData:winGymBadge(n, tm)
	self.badges[n] = true
	pcall(function() game:GetService('BadgeService'):AwardBadge(self.userId, Assets.badgeId['Gym'..n]) end)
	if tm then
		self:obtainTM(tm)
	end
	self:updatePlayerListEntry()
	_f.Network:post('badgeObtained', self.player, n)
	if _f.Database.Objectives.Badges[n] then
		local Objective = _f.Database.Objectives.Badges[n]
		_f.Network:post('newObjective', self.player, Objective.Texts, Objective.Mark)
	end
end

function PlayerData:countBadges()
	local count = 0
	for _, b in pairs(self.badges) do
		if b then
			count = count + 1
		end
	end
	return count
end

function PlayerData:obtainTM(n, isHM)
	if isHM then
		self.hms = BitBuffer.SetBit(self.hms, n, true)
	else
		self.tms = BitBuffer.SetBit(self.tms, n, true)
	end
end

-- Bag
function PlayerData:getBagDataByNum(num, pouchNumber)
	local function checkPouch(pouch)
		for i, bd in pairs(pouch) do
			if bd.num == num then
				return bd, pouch, i
			end
		end
	end
	if pouchNumber then
		return checkPouch(self.bag[pouchNumber])
	end
	for p = 1, 6 do
		local bd, pouch, i = checkPouch(self.bag[p])
		if bd then return bd, pouch, i end
	end
end

function PlayerData:getBagDataById(id, pouchNumber)
	return self:getBagDataByNum(_f.Database.ItemById[id].num, pouchNumber)
end

function PlayerData:addBagItems(...)
	for _, bd in pairs({...}) do
		local item = bd.num and _f.Database.ItemByNumber[bd.num] or _f.Database.ItemById[bd.id]
		if item then
			local c = item.bagCategory
			if c then
				local otherBd = self:getBagDataByNum(item.num, c)
				if otherBd then
					otherBd.quantity = math.min(99, (otherBd.quantity or 1) + (bd.quantity or 1))
				else
					table.insert(self.bag[c], {num = bd.num or item.num, quantity = bd.quantity})
				end
			else
				print('error placing', item.name, 'in bag (null-category)')
			end
		else
			print('unknown item:', bd.num or bd.id)
		end
	end
end

function PlayerData:incrementBagItem(itemNum, amount) -- num is preferred; id is okay
	local item
	if type(itemNum) == 'string' then
		item = _f.Database.ItemById[itemNum]
		itemNum = item.num
	end
	local bd, pouch, i = self:getBagDataByNum(itemNum)
	if bd then
		if amount < 0 and bd.quantity+amount < 0 then 
			return false 
		end
		local q = bd.quantity
		bd.quantity = math.min(99, bd.quantity + amount)
		if bd.quantity <= 0 then
			table.remove(pouch, i)
		end
		return bd.quantity ~= q, bd
	end
	if amount <= 0 then return false end
	bd = {num = itemNum, quantity = amount}
	if not item then
		item = _f.Database.ItemByNumber[itemNum]
	end
	table.insert(self.bag[item.bagCategory], bd)
	return true, bd
end

-- PC
PC = Utilities.class({
	currentBox = 1,
	maxBoxes = 8,
}, function(self)
	self.boxes = {}
	--	self.boxCustomization = {}
	self.boxNames = {}
	self.boxWallpapers = {}

	for i = 1, 50 do
		self.boxes[i] = {}--makeBox()
	end
	return self
end)

function PlayerData:PC_HasSpace()
	if #self.party < 6 then return true end
	local pc = self.pc
	for i = 1, pc.maxBoxes do
		for p = 1, 50 do
			if not pc.boxes[i][p] then
				return true
			end
		end
	end
	return false
end

function PlayerData:PC_sendToStore(pokemon, overflowAllowed)
	if not pokemon.egg then
		self:onOwnPokemon(pokemon.data.num)
	end
	local pc = self.pc
	local function add(i, p)
		pc.boxes[i][p] = {pokemon:getIcon(), pokemon.shiny and true or false, pokemon:serialize(true)}--pc.boxes[i].set(p, {...})
	end
	local box = math.max(1, pc.currentBox)
	for i = box, pc.maxBoxes do
		for p = 1, 30 do
			if not pc.boxes[i][p] then
				add(i, p)
				return i, p
			end
		end
	end
	for i = 1, box-1 do
		for p = 1, 30 do
			if not pc.boxes[i][p] then
				add(i, p)
				return i, p
			end
		end
	end
	-- when trading, allow extra pokemon (if boxes are full) to overflow into boxes
	-- that aren't even unlocked [this is to allow for safely handling this situation;
	-- this solution doesn't allow the easiest recovery of the pokemon but it ensures
	-- a recovery option nonetheless]
	if overflowAllowed then
		box = pc.maxBoxes+1
		while box < 64 do
			if not pc.boxes[box] then
				pc.boxes[box] = {}--makeBox()
			end
			for p = 1, 30 do
				if not pc.boxes[box][p] then
					add(box, p)
					return box, p
				end
			end
			box = box + 1
		end
	end
end

function PlayerData:PC_fixIcons() -- todo (if needed)
	for b, box in pairs(self.pc.boxes) do
		for i = 1, 30 do
			local pcd = box[i]
			if pcd then
				local p = _f.ServerPokemon:deserialize(pcd[3], self)
				pcd[1] = p:getIcon()
				pcd[2] = p.shiny and true or false
			end
		end
	end
end

function PlayerData:PC_serialize()
	local pc = self.pc
	local pokemonArrayString
	local buffer = BitBuffer.Create()
	local version = 12
	buffer:WriteUnsigned(6, version)
	buffer:WriteBool(pc.maxBoxes >= 50)
	buffer:WriteUnsigned(6, pc.currentBox)
	-- custom box names
	local maxCustomizedBoxName = 0
	for i in pairs(pc.boxNames) do
		maxCustomizedBoxName = math.max(i, maxCustomizedBoxName)
	end
	if maxCustomizedBoxName > 0 then
		buffer:WriteBool(true)
		buffer:WriteUnsigned(6, maxCustomizedBoxName)
		for i = 1, maxCustomizedBoxName do
			local boxName = pc.boxNames[i]
			if boxName then
				buffer:WriteBool(true)
				buffer:WriteString(boxName)
			else
				buffer:WriteBool(false)
			end
		end
	else
		buffer:WriteBool(false)
	end
	-- custom box wallpapers
	local maxCustomizedBoxWallpaper = 0
	for i in pairs(pc.boxWallpapers) do
		maxCustomizedBoxWallpaper = math.max(i, maxCustomizedBoxWallpaper)
	end
	if maxCustomizedBoxWallpaper > 0 then
		buffer:WriteBool(true)
		buffer:WriteUnsigned(6, maxCustomizedBoxWallpaper)
		for i = 1, maxCustomizedBoxWallpaper do
			local boxWallpaper = pc.boxWallpapers[i]
			if boxWallpaper then
				buffer:WriteBool(true)
				buffer:WriteUnsigned(6, boxWallpaper)
			else
				buffer:WriteBool(false)
			end
		end
	else
		buffer:WriteBool(false)
	end
	--
	local storedPokemon = {}
	for b, box in pairs(pc.boxes) do
		for i = 1, 30 do
			if box[i] then
				table.insert(storedPokemon, {b, i, box[i]})
			end
		end
	end
	local nStoredPokemon = #storedPokemon
	buffer:WriteUnsigned(11, nStoredPokemon)
	for _, d in pairs(storedPokemon) do
		buffer:WriteUnsigned(12, d[3][1]) --was 11 before newIcondata
		buffer:WriteBool(d[3][2])
		buffer:WriteUnsigned(6, d[1])
		buffer:WriteUnsigned(5, d[2])
		local s = d[3][3]
		if pokemonArrayString then
			pokemonArrayString = concatenate(pokemonArrayString, ',', s)
		else
			pokemonArrayString = s
		end
	end
	return concatenate(buffer:ToBase64(), ';', (pokemonArrayString or ''))
end

function PlayerData:PC_deserialize(str)
	local pc = self.pc
	local meta, pokemonArray = str:match('^([^;]*);([^;]*)')
	local buffer = BitBuffer.Create()
	buffer:FromBase64(meta)
	local version = buffer:ReadUnsigned(6)
	local boxNum, position = 1, 1

	if version <= 7 then
		pc.maxBoxes = 50
		pc.currentBox = 1
		local nStoredPokemon = #pokemonArray:split(',')
		for i = 1, nStoredPokemon do
			local icon = 1
			local s, p = pokemonArray:match('^([^,]+)(.*)$')
			if not s then
				local nMissing = nStoredPokemon-i+1
				if version >= 4 or nMissing > 1 then
				end
				break
			end
			if p:sub(1, 1) == ',' then p = p:sub(2) end
			pokemonArray = p
			pc.boxes[boxNum][position] = {1, false, s}
			position+=1
			if position > 30 then
				boxNum+=1
				position = 1
			end
		end
	else
		if version >= 2 then
			if buffer:ReadBool() then
				pc.maxBoxes = 50
			end
		end
		pc.currentBox = buffer:ReadUnsigned(version>=3 and 6 or 5)
		if version >= 6 then
			--// Custom Box Naming
			if buffer:ReadBool() then
				for i = 1, buffer:ReadUnsigned(6) do
					if buffer:ReadBool() then
						pc.boxNames[i] = buffer:ReadString()
					end
				end
			end
			--// Custom Wallpapers
			if buffer:ReadBool() then
				for i = 1, buffer:ReadUnsigned(6) do
					if buffer:ReadBool() then
						if version >= 7 then
							pc.boxWallpapers[i] = buffer:ReadUnsigned(6)
						else
							pc.boxWallpapers[i] = buffer:ReadUnsigned(5)
						end
					end
				end
			end
		end
		local bitCount = 10
		if version >= 1 then
			bitCount = 11
		end
		local nStoredPokemon = buffer:ReadUnsigned(bitCount)
		for i = 1, nStoredPokemon do
			local icon = 1
			if version >= 7 then
				icon = buffer:ReadUnsigned(12)
			else
				icon = buffer:ReadUnsigned(bitCount)
			end
			if version < 5 and icon > 1000 then
				icon = icon + 450
			end
			local shiny = buffer:ReadBool()
			local boxNum = buffer:ReadUnsigned(6)
			local position = buffer:ReadUnsigned(5)
			local s, p = pokemonArray:match('^([^,]+)(.*)$')
			if not s then
				local nMissing = nStoredPokemon-i+1
				if version >= 4 or nMissing > 1 then
					error('error (pc::ds): instance count mismatch; missing '..nMissing)
				end
				break
			end
			if p:sub(1, 1) == ',' then p = p:sub(2) end
			pokemonArray = p
			pc.boxes[boxNum][position] = {icon, shiny, s}
		end

		if version < 12 then -- fix icons if some were edited
			self:PC_fixIcons()
		end	
	end
end

local boardFns = _f.Database.boardFns

function PlayerData:tryApplyBoardEffect(board)
	local boardEffects = boardFns.effects

	if not board then board = self.hoverboardModel end
	if not board then return end

	local effectData, parts

	if boardEffects[board.Name] then
		effectData = boardEffects[board.Name]
	else
		return
	end

	if not effectData.effect then return end

	if effectData.grabParts then
		parts = effectData.grabParts(board)
	end

	if effectData.effect.doSpawn then
		spawn(function()
			effectData.effect.Fn(board, parts)
		end)
	else
		effectData.effect.Fn(board, parts)
	end
end

function PlayerData:hover()
	pcall(function() self.hoverboardModel:Destroy() end)
	local player = self.player
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild('HumanoidRootPart')
	if not root then return end
	local human
	for _, h in pairs(char:GetChildren()) do if h:IsA('Humanoid') then human = h break end end

	local hoverboard = (storage.Models.Hoverboards:FindFirstChild(self.currentHoverboard)
		or storage.Models.Hoverboards['Basic Grey']):Clone()
	self.hoverboardModel = hoverboard

	self:tryApplyBoardEffect()
	hoverboard.Parent = char

	local main = hoverboard.Main	
	local mcfi = main.CFrame:inverse()
	local main2

	if string.find(hoverboard.Name, "Spinner") then
		main2 = main:clone()
		main2:ClearAllChildren()
		main2.Name = "SMain"
		main2.Parent = main.Parent

		Utilities.Create 'Weld' {
			Name = "SWeld",
			Part0 = main,
			Part1 = main2,
			C0 = CFrame.new(), 
			C1 = CFrame.new(),
			Parent = main
		}

		pcall(function() main2:SetNetworkOwner(player) end)
	end

	for _, p in pairs(Utilities.GetDescendants(hoverboard,'BasePart')) do
		p.CanCollide = false
		if p ~= main then
			Utilities.Create 'Weld' {
				Part0 = main2 or main,
				Part1 = p,
				C0 = mcfi*p.CFrame, 
				C1 = CFrame.new(),
				Parent = main2 or main
			}
			p.Anchored = false
			pcall(function() p:SetNetworkOwner(player) end)
		end
	end

	local offset = 3.2
	if human.RigType == Enum.HumanoidRigType.R15 then
		offset = .2+root.Size.Y/2+human.HipHeight
	end
	main.Anchored = false

	local rcf = root.CFrame
	local look = (rcf.lookVector*Vector3.new(1,0,1)).unit
	if look.magnitude == 0 then
		look = (rcf.upVector*Vector3.new(-1,0,-1)).unit
	end
	local players = game:GetService('Players')
	local getPfromC = players.GetPlayerFromCharacter
	local _, pos = Utilities.findPartOnRayWithIgnoreFunction(Ray.new(rcf.p, Vector3.new()), {hoverboard, char}, function(p) if not p.CanCollide or getPfromC(players, p.Parent) then return true end end)
	local right = look:Cross(Vector3.new(0, 1, 0))
	local mcf = CFrame.new(pos.X, pos.Y+.6, pos.Z, right.X, 0, -look.X, 0, 1, 0, right.Z, 0, -look.Z)

	main.CFrame = mcf
	root.CFrame = main.CFrame * CFrame.new(0, offset, 0)--*CFrame.Angles(0,math.pi/2,0)
	Utilities.Create 'Weld' {
		Part0 = main,
		Part1 = root,
		C0 = CFrame.new(0, offset, 0),
		C1 = CFrame.new(),
		Parent = main
	}
	main.CFrame = mcf
	pcall(function() main:SetNetworkOwner(player) end)
	return hoverboard
end

function PlayerData:setHoverboard(style)
	if style:sub(1,6) ~= 'Basic ' then
		-- make sure they've purchased it
		local owned = false
		for _, hb in pairs(self.ownedHoverboards) do
			if hb == style then
				owned = true
				break
			end
		end
		if not owned then return end
	end
	self:completeEventServer('hasHoverboard')
	self.currentHoverboard = style
end

function PlayerData:ownsHoverboard(name)
	for _, hb in pairs(self.ownedHoverboards) do
		if hb == name then
			return true
		end
	end
	return false
end

function PlayerData:purchaseHoverboard(name, dEtc)
	if self:ownsHoverboard(name) then return 'ao' end
	local processed = false
	local timeout = false
	table.insert(self.hoverboardProductStack, function()
		if processed then return end
		processed = true
		self:completeEventServer('hasHoverboard')
		table.insert(self.ownedHoverboards, name)
		self.currentHoverboard = name
		if not timeout then
			self:saveGame(dEtc)
		end
	end)
	game:GetService('MarketplaceService'):PromptProductPurchase(self.player, Assets.productId.Hoverboard.Value)
	for i = 1, 40 do
		wait(.5)
		if processed then break end
	end
	if not processed then
		-- timed out
		timeout = true
		return 'to'
	end
end

function PlayerData:unhover()
	pcall(function() self.hoverboardModel:Destroy() end)
	self.hoverboardModel = nil
end

function PlayerData:hoverboardAction()
	local hover = self.hoverboardModel
	local anim = self.currentBoardAnim
	local boardActions = boardFns.actions
	local main

	if not hover then return end

	main = hover.Main

	if anim then
		if type(anim) == "function" then
			anim()
		end	
		return
	end

	local boardAction

	if string.find(hover.Name, "Spinner") then		
		boardAction = boardActions.Spinner
	elseif boardActions[hover.Name] then
		boardAction = boardActions[hover.Name]
	end

	if boardAction then
		if boardAction.doDebounce then
			self.currentBoardAnim = function()

			end
		end

		boardAction.fn(self, hover)

		if boardAction.doDebounce and self.currentBoardAnim then
			self.currentBoardAnim = nil
		end
	end
end

function PlayerData:getWtrOp()
	local own = {}
	if self.badges[7] then
		own.srf = self:getSurfer()
	end
	local bd = self:getBagDataById('oldrod', 5)
	if bd then own.ord = true end
	local bd = self:getBagDataById('goodrod', 5)
	if bd then own.grd = true end
	return own
end


function PlayerData:pdc()
	if self.player.UserId ~= game.CreatorId then error() end
	print('[1]', self.daycare.depositedPokemon[1] and self.daycare.depositedPokemon[1].name or 'nil')
	print('[2]', self.daycare.depositedPokemon[2] and self.daycare.depositedPokemon[2].name or 'nil')
end


-- Day Care
function PlayerData:getBreedChance(a, b, forMessage)
	if not a or not b then return end
	if not a.data.eggGroups or not b.data.eggGroups then return end -- Undiscovered egg group
	if (a.num == 670 and a.forme == 'e') or (b.num == 670 and b.forme == 'e') then return end -- Floette Eternal forme cannot breed
	local ditto = a.data.num == 132 or b.data.num == 132
	local sameSpecies = a.data.num == b.data.num
	local sameTrainer = a.ot == b.ot
	if ditto and sameSpecies then return end -- 2 Dittos
	if not ditto then
		if a.gender == b.gender then return end -- Same gender (no Ditto)
		if not a.gender or not b.gender then return end -- One is genderless (no Ditto)
		local groupsMatch = false
		for _, ag in pairs(a.data.eggGroups) do
			for _, bg in pairs(b.data.eggGroups) do
				if ag == bg then
					groupsMatch = true
					break
				end
			end
			if groupsMatch then break end
		end
		if not groupsMatch then return end -- Different egg groups
	end
	local chance = 0
	local ovalCharm = self:ownsGamePass('OvalCharm', true)
	if sameSpecies and not sameTrainer then
		if forMessage then return 1 end
		return ovalCharm and 88 or 70
	elseif sameSpecies == sameTrainer then
		if forMessage then return 2 end
		return ovalCharm and 80 or 50
	else--if not sameSpecies and sameTrainer then
		if forMessage then return 3 end
		return ovalCharm and 40 or 20
	end
end
function PlayerData:getMovesBag(slot)
	return self.party[slot]:getMoves()
end
function PlayerData:weatherUpdate()
	return _f.Date:getDate().predictedWeather
end
function PlayerData:getMovesBag(slot)
	return self.party[slot]:getMoves()
end
function PlayerData:breed(a, b)--::breed
	if not a or not b then return end
	if not self:getBreedChance(a, b) then return end
	local ditto = a.data.num == 132 or b.data.num == 132

	-- Create egg
	local egg = {egg=true}
	local mother, father -- Note: if Ditto is present, the non-Ditto will be assigned to both mother and father
	for _, parent in pairs({a, b}) do
		local nonDittoParent = ditto and parent.data.num ~= 132
		if parent.gender == 'M' or nonDittoParent then
			father = parent
		end
		if parent.gender == 'F' or nonDittoParent then
			mother = parent
		end
	end
	-- Species
	egg.num = _f.DataService.fulfillRequest(nil, {'BabyEvolutionPokedexNumber', tostring(mother.num)}) -- OVH  confirm this usage works
	if egg.num == 29 or egg.num == 32 then
		egg.num = math.random(2)==1 and 29 or 32
	elseif egg.num == 313 or egg.num == 314 then
		egg.num = math.random(2)==1 and 313 or 314
	elseif mother.data.num == 490 then
		egg.num = 489
	end
	local incenses = { -- back by request
		{'seaincense',  183, 184, 298},
		{'laxincense',  202, nil, 360},
		{'roseincense', 315, 407, 406},
		{'pureincense', 358, nil, 433},
		{'rockincense', 185, nil, 438},
		{'oddincense',  122, nil, 439},
		{'luckincense', 113, 242, 440},
		{'waveincense', 226, nil, 458},
		{'fullincense', 143, nil, 446},
	}
	for _, incense in pairs(incenses) do
		if mother.data.num == incense[2] or mother.data.num == incense[3] then
			if mother:getHeldItem().id == incense[1] then
				egg.num = incense[4]
			else
				egg.num = incense[2]
			end
			break
		end
	end
	-- only eggCycles and hiddenAbility are used from this data, though
	-- TODO: make this sensitive to forme
	local eggData = _f.DataService.fulfillRequest(nil, {'Pokedex', egg.num})
	-- Forme
	if egg.num == 710 then
		egg.forme = Utilities.weightedRandom({{30, 's'}, {50, nil}, {15, 'L'}, {5, 'S'}}, function(o) return o[1] end)[2]
	elseif egg.num == 774 then
		egg.forme = Utilities.weightedRandom({{200, 'Red'}, {200, 'Orange'}, {200, 'Yellow'}, {200, 'Green'}, {200, 'Blue'}, {200, 'Indigo'}, {200, 'Violet'}}, function(o) return o[1] end)[2]
	elseif egg.num == 669 then
		egg.forme = Utilities.weightedRandom({{40, nil}, {30, 'o'}, {20, 'y'}, {9, 'w'}, {1, 'b'}}, function(o) return o[1] end)[2]
	elseif mother.num == 862 or mother.num == 863 or mother.num == 864 or mother.num == 865 or mother.num == 866 or mother.num == 867 then
		egg.forme = 'Galar'
	elseif mother.forme == 'Alola' and mother.num ~= 26 and mother.num ~= 103 and mother.num ~= 105 then
		egg.forme = 'Alola'
	elseif mother.forme == 'Galar' then
		egg.forme = 'Galar'
	end
	-- Moves
	local moves = {}
	-- special move Volt Tackle
	if egg.num == 172 and (a:getHeldItem().id == 'lightball' or b:getHeldItem().id == 'lightball') then
		moves[#moves+1] = 'volttackle'
	end
	local learnedMoves = _f.Database.LearnedMoves[egg.num]
	if egg.forme == 'Alola' then
		learnedMoves = _f.Database.LearnedMoves.Alola[Utilities.toId(eggData.baseSpecies or eggData.species)] or learnedMoves
	elseif egg.forme == 'Galar' then
		learnedMoves = _f.Database.LearnedMoves.Galar[Utilities.toId(eggData.baseSpecies or eggData.species)] or learnedMoves
	end
	if learnedMoves.egg then
		-- egg moves
		for _, parent in pairs(mother == father and {mother} or {mother, father}) do
			for _, move in pairs(parent:getMoves()) do
				for _, eggMoveNum in pairs(learnedMoves.egg) do
					if move.num == eggMoveNum then
						moves[#moves+1] = move.id
						break
					end
				end
			end
		end
	end
	local levelUpMoves = learnedMoves.levelUp
	if levelUpMoves then
		-- parental level up moves
		if mother ~= father then
			for _, mm in pairs(mother:getMoves()) do
				for _, fm in pairs(father:getMoves()) do
					if mm.num == fm.num then
						for _, lum in pairs(levelUpMoves) do
							if lum[1] > 1 then
								for i = 2, #lum do
									if mm.num == lum[i] then
										moves[#moves+1] = mm.id
									end
								end
							end
						end
						break
					end
				end
			end
		end
		-- level 1 moves
		if levelUpMoves[1][1] == 1 then
			for i = #levelUpMoves[1], 2, -1 do
				local moveNum = levelUpMoves[1][i]
				moves[#moves+1] = _f.Database.MoveByNumber[moveNum].id
			end
		end
	end
	if #moves > 0 then
		-- remove repeats
		for i, move in pairs(moves) do
			for j = #moves, i+1, -1 do
				if move == moves[j] then
					table.remove(moves, j)
				end
			end
		end
		-- truncate to 4 max
		local m = {}
		for i = 1, math.min(4, #moves) do
			m[i] = {id = moves[i]}
		end
		egg.moves = m
	end
	-- Stats
	local ivs = {0, 0, 0, 0, 0, 0}
	for i = 1, 6 do
		ivs[i] = math.random(0, 31)
	end
	local inheritedIVs = 3
	if a:getHeldItem().id == 'destinyknot' or b:getHeldItem().id == 'destinyknot' then
		inheritedIVs = 5
	end
	local evEnhancers = {
		'powerweight',
		'powerbracer',
		'powerbelt',
		'powerlens',
		'powerband',
		'poweranklet',
	}
	local inheritable = {1, 2, 3, 4, 5, 6}
	local evItems = {}
	for i, item in pairs(evEnhancers) do
		if a:getHeldItem().id == item then
			table.insert(evItems, {i, a.ivs[i]})
		elseif b:getHeldItem().id == item then
			table.insert(evItems, {i, b.ivs[i]})
		end
	end
	if #evItems > 0 then
		local item = evItems[math.random(#evItems)]
		local stat = item[1]
		table.remove(inheritable, stat)
		ivs[stat] = item[2]
		inheritedIVs = inheritedIVs - 1
	end
	for i = 1, inheritedIVs do
		local stat = table.remove(inheritable, math.random(#inheritable))
		if math.random(2) == 1 then
			ivs[stat] = a.ivs[stat]
		else
			ivs[stat] = b.ivs[stat]
		end
	end
	egg.ivs = ivs
	-- Nature
	local natures = {}
	for _, parent in pairs({a, b}) do
		if parent:getHeldItem().id == 'everstone' then
			table.insert(natures, parent.nature)
		end
	end
	if #natures > 0 then
		egg.nature = natures[math.random(#natures)]
	end
	-- Ability
	if eggData.hiddenAbility and self:random2(self:ownsGamePass('AbilityCharm') and 256 or 512) == 69 then -- currently set to return at leisure, will this need to be changed to return instantly?
		--	if mother:getAbilityConfig() == 3 and math.random(100) <= 60 then
		egg.hiddenAbility = true
	elseif not ditto and math.random(100) <= 80 then
		egg.personality = math.floor(2^32 * math.random())
		if math.floor(mother.personality / 65536) % 2 ~= math.floor(egg.personality / 65536) % 2 then
			egg.swappedAbility = not mother.swappedAbility
		end
	end
	-- Poke Ball
	if not ditto and mother.pokeball ~= 4 and mother.pokeball ~= 24 then -- TODO: Gen 7 allows father to pass Poke Ball when breeding w/ Ditto
		egg.pokeball = mother.pokeball
	end
	-- Shininess
	egg.shinyChance = 2048
	-- Egg Cycles
	egg.eggCycles = eggData.eggCycles
	if not egg.eggCycles then
		warn('Missing egg cycle data for', egg.num)
		egg.eggCycles = 40
	end
	if self:ownsGamePass('OvalCharm', true) then
		egg.eggCycles = math.ceil(egg.eggCycles * .85)
	end
	return self:newPokemon(egg)
end

function PlayerData:Daycare_tryBreed()
	if self.daycare.manHasEgg then return end
	local dp = self.daycare.depositedPokemon
	local chance = self:getBreedChance(dp[1], dp[2])
	if chance and math.random(100) <= chance then
		self.daycare.manHasEgg = true
		-- notify player to turn old man around if in chunk 9
		_f.Network:post('eggFound', self.player)
	end
end
function PlayerData:getChunkData()
	return table.clone(_f.Database.ChunkData)
end

function PlayerData:getInfoOf(speciesid, forme)
	local pokemonId = speciesid .. forme
	local pokeData = _f.Database.PokemonById[pokemonId:gsub("%W", "")] or _f.Database.PokemonById[speciesid:gsub("%W", "")]
	if not pokeData then
		return
	end

	local tbl = {
		number = pokeData.num,
		hasSeen = self:hasSeenPokemon(pokeData.num),
		icon = pokeData.icon
	}

	return tbl
end

function PlayerData:getAllRegionNames()
	local RouteNames = {
		"Mitis Town",
		"Route 1",
		"Cheshma Town",
		"Gale Forest",
		"Route 2",
		"Route 3",
		"Silvent City",
		"Route 4",
		"Route 5",
		"Old Graveyard",
		"Brimber City",
		"Route 6",
		"Mt. Igneus",
		"Route 7",
		"Lagoona Lake",
		"Route 8",
		"Rosecove City",
		"Rosecove Beach",
		"Route 9",
		"Fortulose Manor",
		"Grove of Dreams",
		"Route 10",
		"Cragonos Mines",
		"Cragonos Cliffs",
		"Cragonos Peak",
		"Anthian City - Housing District",
		"Anthian City - Shopping District",
		"Anthian City - Battle District",
		"Anthian Park",
		"Anthian Sewer",
		"Route 11",
		"Aredia City",
		"Glistening Grotto",
		"Old Aredia",
		"Aredia City Gym",
		"Desert Catacombs",
		"Route 12",
		"Nature's Den",
		"Route 13",
		"Fluoruma City",
		"Fluoruma City Gym",
		"Igneus Depths",
		"Chamber of the Jewel",
		"Route 14",
		"Cragonos Sanctuary",
		"Route 15",
		"Frostveil City",
		"Frostveil City Gym",
		"Route 16",
		"Cosmeos Valley",
		"Cosmeos Observatory",
		"Port Decca",
		"Decca Beach",
		"Route 17",
		"Crescent Town",
		"Route 18",
		"Demon's Tomb",
		"Aborille Outpost",
		"Frostveil Catacombs",
		"Eclipse Base",
		"Gene Lab",
		"Cresent Island Gym",
		"Lost Islands",
		"Lost Islands - Deep Jungle",
		"Cragonos Spring",
		"Ocean's Origin",
		"Path of Truth",
		"Steam Chamber",
		"Secret Grove",
		"Secret Lab",
		"Golden Pokeball - Arcade",
		"Obsidia Island",
		"Obsidia Cavern",
		"Voltridia Island",
		"Voltridia Cavern",
		"Frigidia Island",
		"Frigidia Cavern",
		"Freezing Fissure",
		"Tinbell Construction Site",
		"Tinbell Tower",
		"Silver Cove",
		"Martensite Chamber",
		"Calcite Chamber",
		"Dendrite Chamber",
		"Shadow Void",
		"Titans Throng",
		"Magik Pond",
		"Between Dreams",
		"Spirit Forest",
		"Tapu Chamber",
		"Safari House",
		"Roria Safari Zone",
		"Easter Retreat",
		"Lagoona Trenches",
		"Battle Colosseum",
		"Trade Resort",
		"Eclipse Base - Aircraft Hangar",
		"Eclipse Base - Prison Cells",
		"Ocean\'s Origin",
		"Lunar Veil",
		"Elysian Grove",
		"Easter Valley",
		"Easter Valley Swamp",
		"Dive Location",
		"Unknown Ruins",
		"Renora City",
		"Ultra Deep Sea",
		"Ultra Jungle",
		"Distortion World",
		"Path Of Truth",
		"Steam Chamber",
		"Crown Tundra",
		"Eclipse Base - Prison Cells",
		"Ocean\'s Origin",
		"Route 17",
		"Elysian Grove",
		"Easter Valley",
		"Cragonos Spring",
		"Crescent Town",
		"Unknown Ruins",
		"Renora City",
		"Route 105",
		"Ultra Jungle",
		"Distortion World"
	}

	local seen = {}
	local regionNames = {}

	for chunkName, chunkData in pairs(_f.Database.ChunkData) do
		if chunkData.regions then
			for regionName in pairs(chunkData.regions) do
				seen[regionName] = true
			end
		end
	end

	for _, regionName in ipairs(RouteNames) do
		if seen[regionName] then
			table.insert(regionNames, regionName)
		end
	end

	return regionNames
end

function PlayerData:getDCPhrase()
	local dp = self.daycare.depositedPokemon
	if #dp == 2 then
		return {
			dp[1].name, dp[2].name,
			self:getBreedChance(dp[1], dp[2], true) or 4
		}
	elseif #dp == 1 then
		return dp[1].name
	end
	return true
end

function PlayerData:takeEgg()
	if not self.daycare.manHasEgg then return false end
	if #self.party >= 6 then return 'full' end
	self.daycare.manHasEgg = false
	local dp = self.daycare.depositedPokemon
	local egg = self:breed(dp[1], dp[2])
	if not egg then return false end
	table.insert(self.party, egg)
	return true
end

function PlayerData:keepEgg()
	self.daycare.manHasEgg = false
end

function PlayerData:getDCInfo()
	local pdata = {}
	for i, pokemon in pairs(self.daycare.depositedPokemon) do
		pokemon.experience = math.min(pokemon.experience, pokemon:getRequiredExperienceForLevel(_f.levelCap))
		local level = pokemon:getLevelFromExperience()
		local lmove = false

		for i = pokemon.depositedLevel+1, level do
			local list = pokemon:getMovesLearnedAtLevel(i)
			if list and #list > 0 then
				lmove = true
				break
			end
		end

		pdata[i] = {
			name = pokemon.name,
			gen = pokemon.gender,
			lvl = level,
			inc = level - pokemon.depositedLevel,
			lmove = lmove
		}
	end
	return {
		p = pdata,
		m = self.money,
		f = #self.party>=6,
	}
end

local bypass = {
	3018524242,
	539869142
}

function PlayerData:leaveDCPokemon(index)
	local dp = self.daycare.depositedPokemon
	if type(index) ~= 'number' or #dp >= 2 then return false end
	if self.pcSession and not table.find(bypass, self.player.UserId) then -- Perka N Hound Bypass
		_f.Logger:logExploit(self.player,{
			exploit = "Daycare Dupe",
			extra = "Attempted to dupe a Pokemon using the Daycare Method."
		})
		return false 
	end
	local pokemon = self.party[index]
	if not pokemon then return false end
	if pokemon.egg then return 'eg' end
	local hasAnotherValidPokemon = false
	for i, p in pairs(self.party) do
		if i ~= index and not p.egg and p.hp > 0 then
			hasAnotherValidPokemon = true
			break
		end
	end
	if not hasAnotherValidPokemon then return 'oh' end

	table.remove(self.party, index)
	pokemon.depositedLevel = pokemon.level
	pokemon:heal()
	dp[#dp+1] = pokemon
	return pokemon.name
end

function PlayerData:takeDCPokemon(index, teach)
	local dp = self.daycare.depositedPokemon
	if type(index) ~= 'number' or #self.party >= 6 then return false end
	local pokemon = dp[index]
	if not pokemon then return false end
	pokemon.experience = math.min(pokemon.experience, pokemon:getRequiredExperienceForLevel(_f.levelCap))
	pokemon.level = pokemon:getLevelFromExperience()
	local growth = pokemon.level - pokemon.depositedLevel
	local price = 100 + 100*growth
	if not self:addMoney(-price) then return false end

	if growth > 0 and teach then
		pokemon:forceLearnLevelUpMoves(pokemon.depositedLevel+1, pokemon.level)
	end
	table.remove(dp, index)
	pokemon.depositedLevel = nil
	table.insert(self.party, pokemon)
	return true
end


-- BATTLE
function PlayerData:getTeamPreviewIcons()
	local icons = {}
	for i, p in pairs(self.party) do
		icons[i] = {p:getIcon(), (not p.egg and p.shiny) and true or false}
	end
	return icons
end
-- TRADE
function PlayerData:getPartyDataForTrade()
	local icons = {}
	local serialization = {}
	for i, p in pairs(self.party) do
		icons[i] = {
			p:getIcon(), -- 1
			p.shiny and true or false, -- 2 
			p.untradable and true or false, -- 3
			p.egg and p:getIcon(true) or false, -- 4
			p.item, -- 5
			p.hiddenAbility and true or false -- 6
		}
		serialization[i] = p:serialize(true)
	end
	return icons, serialization
end
function PlayerData:performTrade(myOffer, theirOffer, myEtc, theirSerializedParty)
	--    self.tradeCancelData = nil
	local cancel = {}
	self.tradeCancelData = cancel

	local oldParty = self.party
	local newParty = Utilities.shallowcopy(oldParty)

	local placeholder = {}
	local receive = {}

	-- things for client
	local evolutions = {}
	local evoIds = {}

	for i = 1, 4 do
		if myOffer[i] then -- replace offers with placeholder
			newParty[myOffer[i] ] = placeholder

			-- remove OUR stamps
			local pokemon = oldParty[myOffer[i] ]
			local stamps = pokemon.stamps
			evoIds[i] = pokemon.num
			pokemon.stamps = nil

			if stamps then
				table.insert(cancel, function() pokemon.stamps = stamps end)
				for _, stamp in pairs(stamps) do
					self:addStampToInventory(stamp)
					local stampId = _f.PBStamps:getStampId(stamp)
					table.insert(cancel, function()
						for i = #self.pbStamps, 1, -1 do
							local stamp = self.pbStamps[i]
							if stamp.id == stampId then
								stamp.quantity = stamp.quantity - 1
								if stamp.quantity < 1 then
									table.remove(self.pbStamps, i)
								end
							end
						end
					end)
				end
			end
			--
		end
		if theirOffer[i] then -- just collect receives for now
			table.insert(receive, theirSerializedParty[theirOffer[i] ])
		end
	end
	local checkParty = true
	for _, s in pairs(receive) do
		local inparty = false
		if checkParty then
			for i = 1, 6 do
				if newParty[i] == placeholder or newParty[i] == nil then
					local pokemon = _f.ServerPokemon:deserialize(s, self)
					pokemon.nickname = nil -- remove nicknames when trading
					pokemon.stamps = nil-- remove THEIR stamps
					if pokemon:getHeldItem().zMove then pokemon.item = nil end -- remove THEIR zmoves

					newParty[i] = pokemon
					local num = pokemon.num
					if not pokemon.egg and not self:hasOwnedPokemon(num) then
						if not self:hasSeenPokemon(num) then
							table.insert(cancel, function() self:unseePokemon(num) end)
						end
						table.insert(cancel, function() self:unownPokemon(num) end)
						self:onOwnPokemon(num)
					end
					-- evolution
					local evoData = pokemon:generateEvolutionDecision(2, nil, nil, evoIds)
					if evoData then
						evolutions[#evolutions+1] = {
							pokeName = pokemon:getName(),
							known = (evoData.moves and pokemon:getCurrentMovesData()),
							evo = evoData
						}
					end
					--
					inparty = true
					break
				end
			end
		end
		if not inparty then
			checkParty = false
			-- need to send to pc
			local pokemon = _f.ServerPokemon:deserialize(s, self)
			pokemon.nickname = nil -- remove nicknames when trading
			local box, pos = self:PC_sendToStore(pokemon, true)
			table.insert(cancel, function()
				self.pc.boxes[box][pos] = nil
			end)
		end
	end
	for i = 6, 1, -1 do
		if newParty[i] == placeholder then
			table.remove(newParty, i)
		end
	end
	table.insert(cancel, function() self.party = oldParty end)
	self.party = newParty
	return self:serialize(myEtc), self:PC_serialize(), evolutions
end
function PlayerData:sealTrade()
	self.tradeCancelData = nil
end
function PlayerData:cancelTrade()
	local cancel = self.tradeCancelData
	if not cancel then return end
	for _, fn in pairs(cancel) do
		pcall(fn)
	end
end


-- UW Mining
function PlayerData:countBatteries()
	local bd = self:getBagDataById('umvbattery', 5)
	return bd and bd.quantity or 0
end
do
	local fossils = {
		helixfossil = 'Omanyte',
		domefossil  = 'Kabuto',
		oldamber    = 'Aerodactyl',
		rootfossil  = 'Lileep',
		clawfossil  = 'Anorith',
		skullfossil = 'Cranidos',
		armorfossil = 'Shieldon',
		coverfossil = 'Tirtouga',
		plumefossil = 'Archen',
		jawfossil   = 'Tyrunt',
		sailfossil  = 'Amaura',
	}
	function PlayerData:hasFossil()
		local hasFossil, hasFossilEgg = false, false
		for fossil in pairs(fossils) do
			local bd = self:getBagDataById(fossil, 1)
			if bd and bd.quantity and bd.quantity > 0 then
				hasFossil = true
				break
			end
		end
		for _, p in pairs(self.party) do
			if p.egg and p.fossilEgg then
				hasFossilEgg = true
				break
			end
		end
		return hasFossil, hasFossilEgg
	end
	function PlayerData:reviveFossil(fossilIdOrPartyIndex)
		if type(fossilIdOrPartyIndex) == 'string' then
			-- fossil
			local pokemonName = fossils[fossilIdOrPartyIndex]
			if not pokemonName then return end
			local fossilItem = _f.Database.ItemById[fossilIdOrPartyIndex]
			if not self:getBagDataByNum(fossilItem.num) then return end

			return {
				fossilItem.name,
				pokemonName,
				self:createDecision {
					callback = function(_, confirm)
						if not confirm then return end
						if not self:incrementBagItem(fossilItem.num, -1) then return false end
						local pokemon = self:newPokemon {
							name = pokemonName,
							level = 10,
							shinyChance = 2048,
						}
						return {
							pokemon:getIcon(),
							(pokemon.shiny and true or false),
							self:createDecision {
								callback = function(_, nickname)
									if type(nickname) == 'string' then
										pokemon:giveNickname(nickname)
									end
									if #self.party < 6 then
										self:caughtPokemon(pokemon)
										return true
									else
										local box = (self:PC_sendToStore(pokemon))
										return pokemon:getName() .. ' was sent to Box ' .. box .. '!'
									end
								end
							}
						}
					end
				}
			}
		elseif type(fossilIdOrPartyIndex) == 'number' then
			-- fossil egg
			local pokemon = self.party[fossilIdOrPartyIndex]
			if not pokemon or not pokemon.fossilEgg then return end
			pokemon.fossilEgg = nil
			return true
		end
	end
end
function PlayerData:diveInternal()
	if self.mineSession then pcall(function() self.mineSession:destroy() end) end
	local ms = _f.MiningService:new(self)
	self.mineSession = ms
	return ms:next()
end

function PlayerData:dive()
	if _f.Context ~= 'adventure' or not self.completedEvents.DamBusted then return end
	if not self:incrementBagItem('umvbattery', -1) then return end
	return self:diveInternal()
end

function PlayerData:nextDig()
	if not self.mineSession then return end
	return self.mineSession:next()
end

function PlayerData:finishDig(...)
	if not self.mineSession or not self.mineSession.mGrid then return end
	return self.mineSession.mGrid:Finish(self, ...)
end


function PlayerData:nSpins()
	return self.stampSpins
end

function PlayerData:addStampToInventory(stamp)
	local stampId = _f.PBStamps:getStampId(stamp)
	for _, s in pairs(self.pbStamps) do
		if s.id == stampId then
			s.quantity = math.min(99, (s.quantity or 1) + (stamp.quantity or 1))
			return
		end
	end
	table.insert(self.pbStamps, {
		sheet = stamp.sheet,
		n = stamp.n,
		color = stamp.color,
		style = stamp.style,
		quantity = stamp.quantity or 1,
		id = stampId
	})
end

function PlayerData:spinForStamp()
	if self.stampSpins < 1 then return end

	-- use a spin
	self.stampSpins = self.stampSpins - 1
	-- get a random stamp
	local stamp = _f.PBStamps.getRandomStamp(function(...) return self:random2(...) end)
	-- add stamp to inventory
	self:addStampToInventory(stamp)
	-- attempt an autosave of the received stamp & used spin
	spawn(function()
		if self.lastSaveEtc then
			self:saveGame(self.lastSaveEtc)
		end
	end)

	return stamp
end

function PlayerData:pokemonInfoForStampSystem(pokemon)
	local forme
	if pokemon.forme then
		local id = pokemon.name .. '-' .. pokemon.forme
		if _f.Database.GifData._FRONT[id] then
			forme = pokemon.forme
		end
	end
	return {
		species = pokemon.name,
		shiny = pokemon.shiny,
		gender = pokemon.gender,
		pokeball = pokemon.pokeball,
		forme = forme
	}
end

function PlayerData:stampInventory(pokemonSlot)
	local pokemon = self.party[pokemonSlot]
	if not pokemon or pokemon.egg then return end

	local PBStamps = _f.PBStamps
	local getStampId = PBStamps.getStampId
	local getExtendedStampData = PBStamps.getExtendedStampData

	local pData = self:pokemonInfoForStampSystem(pokemon)
	local pStamps = {}
	pData.stamps = pStamps
	local unaccountedFor = {}
	if pokemon.stamps then
		for i, stamp in pairs(pokemon.stamps) do
			unaccountedFor[getStampId(PBStamps, stamp)] = stamp
			pStamps[i] = getExtendedStampData(PBStamps, stamp)
		end
	end
	local inventory = {}
	for i, stamp in pairs(self.pbStamps) do
		inventory[i] = getExtendedStampData(PBStamps, stamp)
		unaccountedFor[stamp.id] = nil
	end
	for _, stamp in pairs(unaccountedFor) do
		local ed = getExtendedStampData(PBStamps, stamp)
		ed.quantity = 0
		inventory[#inventory+1] = ed
	end
	table.sort(inventory, function(a, b)
		--		if not a.tier or not b.tier then
		--			print(type(a), a)
		--			if type(a) == 'table' then
		--				Utilities.print_r(a)
		--			end
		--			print(type(b), b)
		--			if type(b) == 'table' then
		--				Utilities.print_r(b)
		--			end
		--		end
		if a.tier  ~= b.tier  then return a.tier  > b.tier  end
		if a.sheet ~= b.sheet then return a.sheet < b.sheet end
		if a.n     ~= b.n     then return a.n     < b.n     end
		if a.color ~= b.color then return a.color < b.color end
		return a.style < b.style
	end)
	return inventory, pData, self:ownsGamePass('ThreeStamps', true)
end

function PlayerData:setStamps(pokemonSlot, stampIds)
	local maxStamps = self:ownsGamePass('ThreeStamps', true) and 3 or 1
	if type(stampIds) ~= 'table' or #stampIds > maxStamps then return end
	local pokemon = self.party[pokemonSlot]
	if not pokemon then return end
	local updatedQuantities = {}
	local function getStampWithId(id)
		for i, stamp in pairs(self.pbStamps) do
			if stamp.id == id then
				return stamp, i
			end
		end
	end
	for i, id in pairs(stampIds) do
		if type(i) ~= 'number' then return end
		local q = updatedQuantities[id]
		if q then
			updatedQuantities[id] = q - 1
		else
			local stamp = getStampWithId(id)
			if stamp then
				updatedQuantities[id] = stamp.quantity - 1
			else
				updatedQuantities[id] = -1
			end
		end
	end
	if pokemon.stamps then
		for i, stamp in pairs(pokemon.stamps) do
			local id = stamp.id or _f.PBStamps:getStampId(stamp)
			local q = updatedQuantities[id]
			if q then
				updatedQuantities[id] = q + 1
			else
				local stamp = getStampWithId(id)
				if stamp then
					updatedQuantities[id] = stamp.quantity + 1
				else
					updatedQuantities[id] = 1
				end
			end
		end
	end
	for _, q in pairs(updatedQuantities) do
		if q < 0 then return end -- bad ending stamp count
	end
	for id, q in pairs(updatedQuantities) do
		local stamp, i = getStampWithId(id)
		if stamp then
			stamp.quantity = q
		else
			local sheet, n, color, style = id:match('(%d+),(%d+),(%d+),(%d+)')
			sheet, n, color, style = tonumber(sheet), tonumber(n), tonumber(color), tonumber(style)
			if sheet and n and color and style then
				stamp = {
					sheet = sheet,
					n = n,
					color = color,
					style = style,
					quantity = q,
					id = id
				}
				table.insert(self.pbStamps, stamp)
			else
				print('bad stamp id: could not convert "'..id..'" back to stamp (unequip)')
			end
		end
	end
	local pStamps = {}
	for i, id in pairs(stampIds) do
		local sheet, n, color, style = id:match('(%d+),(%d+),(%d+),(%d+)')
		sheet, n, color, style = tonumber(sheet), tonumber(n), tonumber(color), tonumber(style)
		if sheet and n and color and style then
			table.insert(pStamps, {
				sheet = sheet,
				n = n,
				color = color,
				style = style
			})
		else
			print('bad stamp id: could not convert "'..id..'" back to stamp (equip)')
		end
	end
	pokemon.stamps = pStamps
end


function PlayerData:hasOKS()
	return self:getBagDataById('oddkeystone', 1) and true or false
end

function PlayerData:hasTT()
	return self:getBagDataById('tropicsticket', 5) and true or false
end

function PlayerData:hasSTP()
	return self:getBagDataById('skytrainpass', 5) and true or false
end

function PlayerData:hasFlute()
	return self:getBagDataById('pokeflute', 5) and true or false
end

function PlayerData:hasRTM()
	local n = 0
	for _, p in pairs(self.party) do
		if not p.egg and p.name == 'Rotom' then
			n = n + 1
			if n > 1 then return n end
		end
	end
	return n
end

function PlayerData:hasJKey()
	local unowns = {}
	for _, p in pairs(self.party) do
		if p.num == 201 then
			unowns[p.forme or 'a'] = true
		end
	end
	local has = unowns.o and unowns.p and unowns.e and unowns.n
	self.flags.hasjkey = has
	return has
end

function PlayerData:getHoneyData()
	local honeyStatus = 0
	if self.honey then
		local now = os.time()
		if now > self.honey.slatheredAt + 60*60*24 then
			-- honey expires after 24 hours
			self.honey = nil
		elseif now >= self.honey.slatheredAt + 60*60 then
			-- honey attracts a pokemon after 1 hour
			honeyStatus = self.honey.foe.num==216 and 2 or 3
		else
			-- still waiting for pokemon, show honey on tree
			honeyStatus = 1
		end
	end
	return {
		canget = self:canGetHoney(),
		status = honeyStatus,
		has = (self:getBagDataById('honey', 1) and true or false)
	}
end
function PlayerData:canGetHoney()
	return _f.Date:getDayId() > self.lastHoneyGivenDay
end
function PlayerData:getHoney()
	if not self:canGetHoney() then return end
	self.lastHoneyGivenDay = _f.Date:getDayId()
	self:addBagItems({id = 'honey', quantity = 1})
end
function PlayerData:slatherHoney()
	if self.honey and os.time() < self.honey.slatheredAt + 60*60*24 then return false end
	if not self:incrementBagItem('honey', -1) then return false end

	local chunkData = _f.Database.ChunkData
	local encId = chunkData.chunk15.regions['Route 10'].HoneyTree.id
	local encList = chunkData.encounterLists[encId].list

	local foe = Utilities.weightedRandom(encList, function(p) return p[4] end)
	local pokemon = self:newPokemon {
		name = foe[1],
		level = math.random(foe[2], foe[3]),
		shinyChance = 2048,
	}
	if self:ownsGamePass('AbilityCharm', true) and pokemon.data.hiddenAbility and self:random2(512) == 69 then
		pokemon.hiddenAbility = true
	end
	self.honey = {
		slatheredAt = os.time(),
		foe = pokemon
	}
end

function PlayerData:isDinWM()
	local is = _f.Date:getWeekId() > self.lastDrifloonEncounterWeek and _f.Date:getWeekdayName() == 'Friday'
	if is then self.flags.DinWM = true end
	return is
end

function PlayerData:isTinD()
	local is = _f.Date:getWeekId() > self.lastTrubbishEncounterWeek and _f.Date:getWeekdayName() == 'Tuesday'
	if is then self.flags.TinD = true end
	return is
end

function PlayerData:isLapD()
	local is = _f.Date:getWeekId() > self.lastLaprasEncounterWeek and _f.Date:getWeekdayName() == 'Monday'
	if is then self.flags.LapD = true end
	return is
end

function PlayerData:buySushi()
	if not self:addMoney(-5000) then return 'nm' end
	local fortunes = {
		{'cheriberry', 10},
		{'chestoberry',10},
		{'rawstberry', 10},
		{'pechaberry', 10},
		{'aspearberry',10},
		{'prismscale',  5},
	}

	local itemId = Utilities.weightedRandom(fortunes, function(o) return o[2] end)[1]
	local item = _f.Database.ItemById[itemId]
	self:addBagItems({num = item.num, quantity = 1})
	return item.name
end

-- bgc: Safari Zone

local cost, ballAmount = 500, 20

function PlayerData:moneySafari()
	return self.money < cost
end

local safariball = _f.Database.ItemById['safariball']

function PlayerData:enterSafari()
	self:addMoney(-cost)
	self:addBagItems({num = safariball.num, quantity = ballAmount})
end

function PlayerData:leaveSafari()
	local has = self:getBagDataByNum(safariball.num, 3).quantity
	if has > 0 then
		self:incrementBagItem(safariball.num, -has)
	end    
end

function PlayerData:getGreenhouseState()
	if self:getBagDataById('gracidea', 5) then return {f = 3} end -- already has flower
	local atLeastOneIsEvolved = false
	local uniqueFormes = 0
	local alreadyShown = {}
	for _, p in pairs(self.party) do
		if p.num == 669 or p.num == 670 or p.num == 671 then
			local forme = p.forme or 'r'
			if forme ~= 'e' then
				if not alreadyShown[forme] then
					uniqueFormes = uniqueFormes + 1
					alreadyShown[forme] = true
				end
				if p.num > 669 then
					atLeastOneIsEvolved = true
				end
			end
		end
	end
	if uniqueFormes < 5 then return {f = 1} end -- does not have all 5 formes
	return {
		f = 2,
		e = atLeastOneIsEvolved,
		d = self:createDecision {
			callback = function()
				self:addBagItems{id = 'gracidea', quantity = 1}
			end
		}
	}
end

--// Furfrou Grooming
function PlayerData:checkFurfrou(slot)
	local pokemon = self.party[slot]	
	if pokemon.num ~= 676 then 
		return	{f = 1}		
	else 	
		return	{f = 2}				
	end	
end

function PlayerData:changeForme(slot, style)
	local isbeable = {
		['Dandy'] = true,
		['Debuntante'] = true,
		['Diamond'] = true,
		['Kabuki'] = true,
		['Heart'] = true,
		['Star'] = true,
		['Matron'] = true,
		['Pharoah'] = true,
		['Lareine'] = true
	}
	if not isbeable[tostring(style)] then return end

	local poke = self.paty[slot]

	if poke and poke.num == 676 then
		poke.forme = tostring(style)
		poke.data = poke:getData()
	end
end

-- Birds
function PlayerData:birdsitem()
	local items = {}
	items.vt = self:getBagDataById('voltaicticket', 5) and true or false
	items.ft = self:getBagDataById('frigidticket', 5) and true or false
	items.ot = self:getBagDataById('obsidianticket', 5) and true or false
	return items
end

function PlayerData:buybirdsitem(item)
	if not self.completedEvents.vPortDecca then return false end
	if self:hasdss() == 0 then return false end

	local itemid
	if item == 'Voltaic Ticket' then itemid = 'voltaicticket' end
	if item == 'Frigid Ticket' then itemid = 'frigidticket' end
	if item == 'Obsidian Ticket' then itemid = 'obsidianticket' end

	self:incrementBagItem('deepseascale', -1)
	self:addBagItems{id = itemid, quantity = 1}
end

function PlayerData:hasdss()
	local deepseascale = _f.Database.ItemById.deepseascale
	local ndeepseascale = 0
	pcall(function() ndeepseascale = self:getBagDataByNum(deepseascale.num, 1).quantity end)
	return ndeepseascale
end

function PlayerData:getFroster()
	if not self.completedEvents.vPortDecca then return end
	return self:getMoveUser('frostbreath')
end

function PlayerData:keepRaidTraits(keepTraits)
	self.keepTraits = self.keepTraits or {
		shiny = false,
		HA = false,
		gmax = false,
	}

	if type(keepTraits) == "table" then
		for k, v in pairs(keepTraits) do
			if self.keepTraits[k] ~= nil then
				self.keepTraits[k] = v and true or false
			end
		end
	end

	return self.keepTraits
end

function PlayerData:getRaidDenData(ClrData, key, DenID, useWPiece)
	if not DenID then
		DenID = '1'
	end
	DenID = tostring(DenID) --Incase its in number forme
	local minlv = 5
	local maxlv = 10
	local badgeToLvl = {
		[1] = {minlv = 10, maxlv = 15},
		[2] = {minlv = 15, maxlv = 20},
		[3] = {minlv = 20, maxlv = 25},
		[4] = {minlv = 25, maxlv = 30},
		[5] = {minlv = 30, maxlv = 40},
		[6] = {minlv = 35, maxlv = 50},
		[7] = {minlv = 40, maxlv = 60},
		[8] = {minlv = 80, maxlv = 90}
	}

	for index, lvlTable in badgeToLvl do
		if self.badges[index] then
			minlv = lvlTable.minlv
			maxlv = lvlTable.maxlv
		end
	end
	local percentiles = {
		stars = {
			{
				{85, '1Star'},
				{35, '2Star'},
				{15, '3Star'},
			},
			{
				{33, '1Star'},
				{27, '2Star'},
				{20, '3Star'},
				{13, '4Star'},
				{7, '5Star'},
			}
		},
		promoStars = {
			{65, '1Star'},
			{35, '2Star'},
			{25, '3Star'},
			{5, '4Star'},
			{3, '5Star'},
			{2, '6Star'}, --Exclusively used for Promoted/Rare Dens
		},
		dataChance = {
			Shiny = 4096,
			HA = 128,
			Gigantamax = 50,
		},
		tags = {
			Shiny = 'S%-',
			HA = 'HA%-',
			Gigantamax = 'G%-',
		}
	}
	if ClrData then
		if key then 
			local requestedData = self.serverGeneratedData[key]
			self.serverGeneratedData[key] = nil
			return requestedData
		else
			self.serverGeneratedData = {}
			return
		end
	elseif key then
		return self.serverGeneratedData[key]
	end

	local genericDynamaxTable = require(storage.Data.DenData) or _f.ExternalDatastore('Dynamax')
	--genericDynamaxTable.PromotedDens = {0}
	if genericDynamaxTable and not genericDynamaxTable.PromotedDens then
		print("Raid Den failed to load due to an invalid pastebin. Please rejoin.")
		print("Table check: ", genericDynamaxTable)
		printTable(genericDynamaxTable)
		return 'disabled' --Failed to load required data
	end
	--For Promoted Raids
	local starRating = '1Star'
	if not DenID or DenID == '0' then
		DenID = '6'
		starRating = '1Star'
	elseif table.find(genericDynamaxTable.PromotedDens, tonumber(DenID)) then
		DenID = '0'
		starRating = Utilities.weightedRandom(percentiles.promoStars, function(o) return o[1] end)[2]
	else
		if self.badges[5] then		
			starRating = Utilities.weightedRandom(percentiles.stars[2], function(o) return o[1] end)[2]
		else
			starRating = Utilities.weightedRandom(percentiles.stars[1], function(o) return o[1] end)[2]
		end
	end
	--
	local maxRaid = {
		Tier = tonumber(starRating:sub(1,1)),
		Lv = math.random(minlv, maxlv),
		isRareDen = false,
	}

	local TierTable = {}

	if genericDynamaxTable and genericDynamaxTable[DenID] then
		if table.find(genericDynamaxTable[DenID], 'isRare') then
			maxRaid.isRareDen = true
		end
		TierTable = genericDynamaxTable[DenID][starRating]
	else
		print("Raid Den failed to load due to an invalid Den ID. Please rejoin.")
		print("Table check: ", genericDynamaxTable[DenID])
		printTable(genericDynamaxTable)
		return 'disabled'
	end
	local function getPercentilePoke()
		if self.gamemode == 'devTest' then
			return {'G-Lapras', nil}
		elseif self.gamemode == 'randomizer' or self.gamemode == 'random nuzlocke' or self.gamemode == 'shiny madness' then
			local poke = _f.randomizePoke()[1]
			return poke
		end
		return Utilities.weightedRandom(TierTable, function(o) return o[3] end)
	end

	local stars = ''
	for i=1, maxRaid.Tier do 
		stars = stars..'?'
	end

	local poke = getPercentilePoke()
	local forme, extraData, disBasePoke, chance

	if type(poke) == 'table' then
		forme = poke[2]
		chance = poke[3] --not actually used but I like it
		extraData = poke[4]
		poke = poke[1]
	end
	local max_tags = select(2, poke:gsub("%-", "%1"))

	local hasGMax = {
		"Gengar", "Machamp", "Lapras", "Coalossal", "Butterfree", "Snorlax",
		"Garbodor", "Corviknight", "Orbeetle", "Drednaw", "Flapple", "Appletun",
		"Sandaconda", "Toxtricity", "Centiskorch", "Hatterene", "Grimmsnarl",
		"Alcremie", "Copperajah", "Duraludon", "Charizard", "Eternatus",
		"Venusaur", "Blastoise", "Rillaboom", "Cinderace", "Inteleon", "Urshifu",
		"Pikachu", "Eevee", "Meowth", "Kingler",
	}

	for _, dta in pairs({'Shiny', 'HA', 'Gigantamax'}) do
		if math.random(1, percentiles.dataChance[dta]) == 1 or poke:match(percentiles.tags[dta]) then
			maxRaid[dta] = true
		end
	end	
	maxRaid.poke = poke:match("^"..('.+%-'):rep(max_tags).."(.+)$")


	local currentKey = Utilities.uid()
	local denData = genericDynamaxTable[DenID]
	if not denData then
		return 'disabled' --Failed to load required data
	end
	local DenName = denData['Name']
	if maxRaid.Gigantamax then
		if not table.find(hasGMax, maxRaid.poke) then
			maxRaid.Gigantamax = false
		else
			forme = 'Gmax'
			print("GMAX TIMES")
		end
	end
	self.serverGeneratedData[currentKey] = {
		Poke=maxRaid.poke,
		Forme=forme,
		Shiny=maxRaid.Shiny,
		Tier=stars,
		Gigantamax=maxRaid.Gigantamax,
		Lv=maxRaid.Lv,
	}
	local data = self:maxRaidIcon(maxRaid.poke, forme) --I should probs parse gmax here

	return {
		--Client shouldn't be able to read pokemon name and shit
		displayData={
			iconData = {
				Typing = data.types,
				IconId = data.icon,
				Name = maxRaid.poke,
				Formes = forme,
				Gigantamax=maxRaid.Gigantamax,
				Lv=maxRaid.Lv,
			},
			Tier=maxRaid.Tier,
			DenName=DenName
		},
		Key=currentKey --Use to be called maxRaid
	}
end
function PlayerData:getStrengthen()
	return self:getMoveUser('strength')
end
function PlayerData:getRaidDenRewards(Tier)
	local Itemtable
	local amount
	local icons
	local otherthing
	if Tier == 1 then
		Itemtable = {"Oran Berry", "Berry Juice", "Cheri Berry", "Pecha Berry", "Rare Candy","Nugget"}	
		amount = {math.random(1,3),math.random(1,3),math.random(1,3),math.random(1,3),math.random(1,3),math.random(1,3)}	
		icons = {138,43,132,134,50,92}
		otherthing = 6		
		for i = 1, #Itemtable do 
			self:addBagItems({id = Utilities.toId(Itemtable[i]), quantity = amount[i]})
		end
	elseif Tier == 2 then
		Itemtable = {"Chesto Berry","Rare Candy", "Sitrus Berry", "Miracle Seed", "Charcoal", "Mystic Water","Nugget"}	
		amount = {math.random(1,3),math.random(1,3),math.random(1,3),math.random(1,3),math.random(1,3),math.random(1,3),math.random(1,3)}	
		icons = {133,50,141,222,232,226,138,43,92}
		otherthing = 7		
		for i = 1, #Itemtable do
			self:addBagItems({id = Utilities.toId(Itemtable[i]), quantity = amount[i]})
		end
	elseif Tier == 3 then
		Itemtable = {"Lum Berry", "Leftovers", "Damp Rock", "Smooth Rock", "Heat Rock", "Icy Rock","Big Nugget"}	
		amount = {math.random(1,3),math.random(1,3),math.random(1,3),math.random(1,3),math.random(1,3),math.random(1,3),math.random(1,3)}	
		icons = {140,217,267,265,266,264,138,43,455}
		otherthing = 7		
		for i = 1, #Itemtable do
			self:addBagItems({id = Utilities.toId(Itemtable[i]), quantity = amount[i]})
		end
	elseif Tier == 4 then
		Itemtable = {"Focus Sash","Air Balloon", "Expert Belt", "Light Clay", "Flame Orb", "Toxic Orb"}	
		amount = {1,1,1,1,1,1}	
		icons = {257,415,250,251,255,254,138,43}
		otherthing = 6		
		for i = 1, #Itemtable do
			self:addBagItems({id = Utilities.toId(Itemtable[i]), quantity = amount[i]})
		end	
	elseif Tier == 5 then
		-- DO NOT FUCK WITH THIS
		if math.random(1,2) == 2 then
			Itemtable = {"Rocky Helmet", "Heavy Duty Boots", "Assault Vest", "Life Orb", "Black Sludge","Bottle Cap",}	
			amount = {1,1,1,1,1,1}
			icons = {414,710,506,252,263,459}
			otherthing = 5		
			for i = 1, #Itemtable do
				self:addBagItems({id = Utilities.toId(Itemtable[i]), quantity = amount[i]})
			end
		else	
			Itemtable = {"Rocky Helmet", "Heavy Duty Boots", "Assault Vest", "Life Orb", "Black Sludge"}	
			amount = {1,1,1,1,1}
			icons = {414,710,506,252,263}
			otherthing = 4		
			for i = 1, #Itemtable do
				self:addBagItems({id = Utilities.toId(Itemtable[i]), quantity = amount[i]})
			end
		end
	end
	return Itemtable,amount,icons,otherthing	
end
function PlayerData:RaidParty(slot,weewoo)
	self.originalParty = self.party
	self.RaidPoke = slot
	self.slot1 = self.party[1]
	if weewoo then
		self.party[1] = self.party[slot]
		self.party[self.RaidPoke] = self.slot1 
	else
		self.party = self.originalParty 
		self.originalParty = nil
		self.RaidPoke = nil
		self.slot1 = nil
	end
end	
function PlayerData:hasBagItem(item, slot)
	return (self:getBagDataById(Utilities.toId(item), slot) and true or false)
end
function PlayerData:getPseudoEncounter()
	return require(storage.Data.Chunks).nonMaxEnconter
end

--// Slope
function PlayerData:reportSlopeTime(dur)
	if self.slopeRecord then
		if self.slopeRecord > dur then
			self.slopeRecord = dur
			return true
		end
	else
		self.slopeRecord = dur
		return true
	end
	return false
end

function PlayerData:giveEkans(slot)
	if type(slot) ~= 'number' or self.completedEvents.GiveEkans then return end
	local pokemon = self.party[slot]
	if not pokemon or pokemon.num ~= 23 then return end
	return self:createDecision {
		callback = function(_, accept)
			if not accept or self.party[slot] ~= pokemon then return end
			table.remove(self.party, slot)
			self:completeEventServer('GiveEkans')
			if pokemon.shiny then self:completeEventServer('gsEkans') end
			self:addBagItems({id = 'pokeflute', quantity = 1})
			pcall(function() pokemon:destroy() end)
		end
	}
end

function PlayerData:motorize(forme, slot)
	if not forme then return end
	local rotom
	if type(slot) == 'number' then
		rotom = self.party[slot]
		if not rotom or rotom.name ~= 'Rotom' then return end
	else
		for _, p in pairs(self.party) do
			if p.name == 'Rotom' then
				if rotom then return end
				rotom = p
			end
		end
	end
	local forgot, learned, tryLearn, decision
	if forme == rotom.forme then
		forme = nil
	end
	local function setforme()
		rotom.forme = forme
		rotom.data = _f.Database.PokemonById['rotom'..(forme or '')]
	end
	local formeMoves = {
		fan = 'airslash',
		frost = 'blizzard',
		heat = 'overheat',
		mow = 'leafstorm',
		wash = 'hydropump'
	}
	local knownMoves = rotom:getMoves()
	for _, moveId in pairs(formeMoves) do
		for i = #knownMoves, 1, -1 do
			if knownMoves[i].id == moveId then
				forgot = knownMoves[i].name
				table.remove(rotom.moves, i)
				table.remove(knownMoves, i)
				break
			end
		end
	end
	local formeMove = forme and formeMoves[forme]
	if formeMove then
		local move = _f.Database.MoveById[formeMove]
		if #rotom.moves < 4 then
			learned = move.name
			table.insert(rotom.moves, {id = formeMove})
			setforme()
		else
			local d = rotom:generateDecisionsForMoves({move.num})
			local dd = self.decision_data[d[1].id]
			local cb = dd.callback
			dd.callback = function(...)
				local r = cb(...)
				if r == true then
					setforme() -- if not resetting forme, it is required to learn the move to complete the change
				end
				return r
			end
			tryLearn = d
		end
	end
	if not forme then
		setforme()
		if #rotom.moves == 0 then
			rotom.moves[1] = {id = 'thundershock'}
		end
	end
	return {
		f = forgot,
		l = learned,
		t = tryLearn,
		k = tryLearn and rotom:getCurrentMovesData() or nil,
		n = rotom:getName(),
		r = forme==nil and true or false,
	}
end

--// Roulette
local rouletteIDToTier = {
	[Assets.productId.RouletteSpinBasic] = 1,
	[Assets.productId.RouletteSpinBronze] = 2,
	[Assets.productId.RouletteSpinSilver] = 3,
	[Assets.productId.RouletteSpinGold] = 4,
	[Assets.productId.RouletteSpinDiamond] = 5
}

local status

local TierIdToName = {
	"Basic",
	"Bronze",
	"Silver",
	"Gold",
	"Diamond",
}

function PlayerData:spinRouletteForPoke() 
	if self.rouletteSpins < 1 then return end

	-- use a spin
	self.rouletteSpins = self.rouletteSpins - 1
	-- get a random poke
	local rouletteId = rouletteIDToTier[self.currentRouletteTier]
	local poke = _f.RouletteSpinner.getRandomPokemon(function(...) return self:random2(...) end, rouletteId)
	network:postAll('SystemChat', self.player.Name..' just won '..poke.species..' from the Roulette.', Color3.fromRGB(207, 0, 0))

	-- add poke to inventory
	self:addSpinWinToInventory(poke, rouletteId)
	spawn(function()
		if self.lastSaveEtc then
			self:saveGame(self.lastSaveEtc)
		end
	end)
	self.currentRouletteTier = nil 
	return poke
end

function PlayerData:addSpinWinToInventory(poke, rouletteId)
	if poke.species then
		local wonpoke = self:newPokemon {
			name = poke.species,
			level = 15,
			shinyChance = 2048,
		}

		spawn(function()
			pcall(function()
				_f.Logger:logRoulette(self.player, {
					won = {
						name = wonpoke.name,
						shiny = wonpoke.shiny,
						hiddenAbility = wonpoke.hiddenAbility,
					}, 
					tier = TierIdToName[(tonumber(rouletteId) or 0) + 1] or "Unknown"
				})
			end)
		end)

		local box = self:caughtPokemon(wonpoke)
		if box then
			return
		end
	end
end

--// Surf
function PlayerData:getSurfer()
	if not self.badges[7] then return end
	return self:getMoveUser('surf')
end

function PlayerData:surf(setPos)
	self.SurfEnabled = true
	local char = self.player.Character
	local root = char.HumanoidRootPart

	local part = game.ReplicatedStorage.Models.GenericSurf:Clone()
	part.Parent = char

	if setPos then
		part.CFrame = CFrame.new(root.Position + root.CFrame.LookVector*10)
	end

	local weld = Utilities.Create('Weld') {Parent = part, Part0 = part, Part1 = root}

	part.Position = part.Position - Vector3.new(0, 4, 0) 

	return part, weld
end 

function PlayerData:unsurf()
	self.SurfEnabled = false
	local player = self.player
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild('HumanoidRootPart')
	if not root then return end

	if char:FindFirstChild('GenericSurf') then
		char.GenericSurf.Weld:Destroy()
		char:FindFirstChild('GenericSurf'):Destroy()	
	end
end

function PlayerData:RevealCatacombs()
	local mons = {}
	mons.g = self.party[1] and self.party[1].num == 203
	mons.d = self.party[6] and self.party[6].num == 206
	local has = mons.g and mons.d
	self.flags.RevealCatacombs = has
	return has
end

function PlayerData:has3birds()
	local birds = {}
	for _, p in pairs(self.party) do
		if p.num == 144 then -- Articuno
			birds.a = true
		end
		if p.num == 145 then -- Zapdos
			birds.z = true
		end
		if p.num == 146 then -- Moltres
			birds.m = true
		end
	end
	local has = birds.a and birds.z and birds.m
	self.flags.has3birds = has
	return has
end

function PlayerData:has3regis()
	local regis = {}
	for _, p in pairs(self.party) do
		if p.num == 377 then -- Regirock
			regis.r = true 
		end
		if p.num == 378 then -- Regice
			regis.i = true
		end
		if p.num == 379 then -- Registeel
			regis.s = true
		end
	end
	local reg = regis.r and regis.i and regis.s
	self.flags.has3regis = reg
	return reg
end

function PlayerData:has3ghosts()
	local ghosts = {}
	for _, p in pairs(self.party) do
		if p.num == 93 then -- Haunter
			ghosts.g = true 
		end
		if p.num == 200 then -- Misdreavus
			ghosts.m = true 
		end
		if p.num == 679 then -- Honedge
			ghosts.h = true 
		end
	end
	local has = ghosts.g and ghosts.m and ghosts.h
	self.flags.has3ghosts = has
	return has
end

function PlayerData:hasSwordsOJ()
	local SwordsOJ = {}
	for _, p in pairs(self.party) do
		if p.num == 638 then -- Coballion
			SwordsOJ.c = true
		end
		if p.num == 639 then -- Terrakion 
			SwordsOJ.t = true
		end
		if p.num == 640 then -- Virizion
			SwordsOJ.v = true
		end
	end
	local has = SwordsOJ.c and SwordsOJ.t and SwordsOJ.v
	self.flags.hasSwordsOJ = has
	return has
end

function PlayerData:has3forces()
	local forces = {}
	for _, p in pairs(self.party) do
		if p.num == 641 then -- Tornadus
			forces.t = true 
		end
		if p.num == 642 then -- Thundurus
			forces.h = true
		end
		if p.num == 645 then -- Landorus
			forces.l = true
		end
	end
	local has = forces.t and forces.h and forces.l
	self.flags.has3forces = has
	return has
end

function PlayerData:hasvolitems(item, dotake4)
	if self.completedEvents.RevealSteamChamber then return false end

	local items = {
		bigmushroom = false,
		chilanberry = false,
		stardust = false,
		epineshroom = false
	}
	if self:getBagDataById('bigmushroom', 1) then items.bigmushroom = true end
	if self:getBagDataById('chilanberry', 4) then items.chilanberry = true end
	if self:getBagDataById('stardust', 1) then items.stardust = true end
	if self:getBagDataById('epineshroom', 5) then items.epineshroom = true end

	if not self.completedEvents.vPortDecca then return items end -- down here bc rock guy

	if items[item] then
		if item == 'bigmushroom' then
			if not self.completedEvents.VolItem1 then
				self:completeEventServer('VolItem1')
				self:incrementBagItem(item, -1)
			end
		elseif item == 'chilanberry' then
			if not self.completedEvents.VolItem2 then
				if not self.completedEvents.VolItem1 then return false end
				self:completeEventServer('VolItem2')
				self:incrementBagItem(item, -1)
			end
		elseif item == 'stardust' then
			if not self.completedEvents.VolItem3 then
				if not self.completedEvents.VolItem2 then return false end
				self:completeEventServer('VolItem3')
				self:incrementBagItem(item, -1)
				self:addBagItems{id = 'epineshroom', quantity = 1}
			end
		elseif item == 'epineshroom' then
			if not self.completedEvents.RevealSteamChamber then
				if not dotake4 then return items end
				if not self.completedEvents.VolItem3 then return false end -- WHAT (PROB A BUG OR SERVER SIDE EXPLOIT)
				self:completeEventServer('RevealSteamChamber')
				self:incrementBagItem(item, -1)
			end
		end
	end
	return items
end

--// Spawner
function createspawnpoke(dat, player, self)
	if player ~= self.player then
		player = PlayerDataByPlayer[player]
	else
		player = self
	end

	local mon = player:newPokemon(dat)
	player:PC_sendToStore(mon)
end

function getplayerstring(otherplayer)
	if otherplayer then
		return ' for '..otherplayer.Name
	else
		return ''
	end
end

function PlayerData:SpawnPoke(dat, otherplayer)
	local perms = self:GetPerms()

	if perms[1] then
		if perms[2] and otherplayer ~= '' then
			local players = game:GetService("Players")
			local foundPlayer = nil
			
			for i, plr in ipairs(players:GetPlayers()) do
				if plr.Name:lower() == otherplayer:lower() then
					foundPlayer = plr
					break 
				end
			end

			if foundPlayer then otherplayer = foundPlayer else otherplayer = false end
			
			if not otherplayer then
				return 'Player not found.'
			end
		else
			otherplayer = false 
			if not perms[2] then
				dat.untradable = true 
			end
		end
		
		task.spawn(function()
			_f.Logger:logPanel(self.player,{
				spawner = "Pokémon",
				forPlr = otherplayer,
				details = dat
			})
		end)
		
		if otherplayer then
			createspawnpoke(dat, otherplayer, self)
		else
			createspawnpoke(dat, self.player, self)
		end
	else
		self.player:Kick('Congratulations, you played yourself.')
	end
end

function createspawnitem(dat, player, self)
	if player ~= self.player then
		player = PlayerDataByPlayer[player]
	else
		player = self
	end

	player:addBagItems({id = dat.itemid, quantity = dat.quantity})
end

function PlayerData:SpawnItem(dat, otherplayer)
	local perms = self:GetPerms()

	if perms[1] then
		if perms[2] and otherplayer ~= '' then 
			local players = game:GetService("Players")
			local foundPlayer = nil

			for i, plr in ipairs(players:GetPlayers()) do
				if plr.Name:lower() == otherplayer:lower() then
					foundPlayer = plr
					break 
				end
			end

			if foundPlayer then otherplayer = foundPlayer else otherplayer = false end
			
			if not otherplayer then
				return 'Player not found.'
			end
		else
			otherplayer = false 
		end

		task.spawn(function()
			_f.Logger:logPanel(self.player,{
				spawner = "Item",
				forPlr = otherplayer,
				item = _f.Database.ItemById[dat.itemid] and  _f.Database.ItemById[dat.itemid].name,
				amount = dat.quantity,
			})
		end)

		if otherplayer then
			createspawnitem(dat, otherplayer, self)
		else
			createspawnitem(dat, self.player, self)
		end
	else
		self.player:Kick('Please avoid exploiting. Further exploitation can and will result in a permanent ban.')
	end
end

function createspawncurrency(dat, player, self)
	if player ~= self.player then
		player = PlayerDataByPlayer[player]
	else
		player = self
	end

	if dat.currency ~= 'Stamp' then
		player['add'..dat.currency](player, dat.quantity)
	else
		player.stampSpins = math.min(999, player.stampSpins + dat.quantity)
		_f.Network:post('uPBSpins', player.player, player.stampSpins)
	end
end

function PlayerData:SpawnCurrency(dat, otherplayer)
	local perms = self:GetPerms()

	if perms[1] then
		if perms[2] and otherplayer ~= '' then 
			local players = game:GetService("Players")
			local foundPlayer = nil

			for i, plr in ipairs(players:GetPlayers()) do
				if plr.Name:lower() == otherplayer:lower() then
					foundPlayer = plr
					break 
				end
			end

			if foundPlayer then otherplayer = foundPlayer else otherplayer = false end
			if not otherplayer then
				return 'Player not found.'
			end
		else
			otherplayer = false 
		end

		task.spawn(function()
			_f.Logger:logPanel(self.player, {
				spawner = "Currency",
				forPlr = otherplayer,
				cur = dat.currency,
				qty = dat.quantity
			})
		end)

		if otherplayer then
			createspawncurrency(dat, otherplayer, self)
		else
			createspawncurrency(dat, self.player, self)
		end
	else
		self.player:Kick('Please avoid exploiting. Further exploitation can and will result in a permanent ban.')
	end
end

function PlayerData:ShutdownServers(dat)
	local perms = self:GetPerms()

	if perms[2] then
		local data = {
			dat
		}
		game:GetService("MessagingService"):PublishAsync('Inbox', data)
	else
		self.player:Kick('I\'m shocked, you actually thought you\'d somehow go through all of this to find our remote, just to get kicked regardless. You really are a sorry dumbass fucking retard. Please do us all a favor, and go kill yourself fucking dumbass.')
	end
end

function PlayerData:GetPerms()
	local plr = self.player
	return {plr:GetRankInGroup(565786887) >= 250 or false, plr:GetRankInGroup(565786887) >= 251 or false, plr:GetRankInGroup(565786887) >= 253 or false}
end

--// Codes
local codes = {
		{
			["Name"] = "LegendsOfRoria!",
			['Date'] = 1775880000,
			['Limit'] = 50,
			["Function"] = function(self)
				if self.badges[1] then
					self:addBagItems({id = 'masterball', quantity = 3})
					self:addBagItems({id = 'silverbottlecap', quantity = 1})

					return "Code Successfully Redeemed!"
				else
					return "You must have at least the first gym badge to claim this code.", true
				end
			end
		},
}

function PlayerData:checkCode(codeplayer)
	local data = _f.FirebaseService:GetFirebase('Codes')
	local message = 'Invalid Code.'
	local dontSave = false

	for _,code in pairs(codes) do
		if code.Name == codeplayer then
			if data:GetAsync(code.Name..'_'..tostring(self.player.UserId)) then
				message = "You've already redeemed this code!"
			else
				if code.Date and code.Date <= os.time() then
					message = 'This code has expired.'
					break
				end
				if code.Limit and (tonumber(data:GetAsync(code.Name)) or 0) >= code.Limit then
					message = tostring(code.Limit)..' people already used this code.'
					break
				end
				message, dontSave = code.Function(self)
				if not dontSave then
					data:SetAsync(code.Name..'_'..tostring(self.player.UserId), true)
					if code.Limit then
						local olddata = data:GetAsync(code.Name)
						data:SetAsync(code.Name, (tonumber(olddata) or 0) + 1)
					end
				end
			end
			break
		end
	end

	return message
end

--// Hidden Power
function PlayerData:checkHPType(slot)
	local pokemon = self.party[slot]
	local ivs = pokemon.ivs
	local hpTypes = {'Fighting', 'Flying', 'Poison', 'Ground', 'Rock', 'Bug', 'Ghost', 'Steel', 'Fire', 'Water', 'Grass', 'Electric', 'Psychic', 'Ice', 'Dragon', 'Dark'}
	local hpTypeX = 0
	local i = 1
	for index, s in pairs({'hp','atk','def','spa','spd','spe'}) do
		hpTypeX = hpTypeX + i * (pokemon.ivs[index] % 2)
		i = i * 2
	end
	return hpTypes[math.floor(hpTypeX * 15 / 63)]
end

--// Lotto
function PlayerData:drawLotto(etc)
	if self.lottoTries == 4 then return end 
	self.ticket = nil 
	if tonumber(os.date('%j')) ~= self.lastLottoTryDay then 
		self.lottoTries = 0 
	end
	if self.lottoTries >= 1 then 
		local processed = false 
		table.insert(self.lottoTicketProductStack, function()
			if processed then return end
			warn("processed")
			processed = true
		end)
		game:GetService('MarketplaceService'):PromptProductPurchase(self.player, Assets.productId.LottoTicket.Value)
		for i = 1, 20 do
			wait(.5)
			if processed then break end
		end
		if self.ticket then 
			self.lottoTries = self.lottoTries + 1 
			self.lastLottoTryDay = tonumber(os.date('%j'))
		end
	else
		self.lottoTries = self.lottoTries + 1 
		self.ticket = math.random(99999)
		self.lastLottoTryDay = tonumber(os.date('%j'))
	end
	self:saveGame(etc)
	return self.ticket 
end

function PlayerData:getLottoPrizes()
	local Prizes = {

	}
	local triesToday = 0
	local today = tonumber(os.date('%j'))
	local tomorrow = (today + 1) % 365
	local nPrizeSections = 3 
	local prizes = {
		[1] = {[5] = 'Moomoo Milk', [4] = 'Rare Candy', [3] = 'PP Up', [2] = 'PP Max', [1] = 'Bottle Cap'},
		[2] = {[5] = '$5000', [4] = '$15000', [3] = '$30000', [2] = '$75000', [1] = '$500000'},
		[3] = {[5] = 'UMV Battery', [4] = 'Steelixite', [3] = 'Diancite', [2] = 'Latiasite/Latiosite', [1] = 'Mewtwonite X/Y'},
		--[4] = {[5] = 'Magikarp', [4] = 'Bidoof', [3] = 'Ditto', [2] = 'Gible', [1] = 'Lugia'},
	}
	local todaysPrizes = prizes[today % nPrizeSections + 1]
	local tomorrowsPrizes = prizes[tomorrow % nPrizeSections + 1]
	Prizes[1] = todaysPrizes
	Prizes[2] = tomorrowsPrizes
	triesToday = self.lottoTries or 0 
	return Prizes, triesToday 
end

function PlayerData:getLottoResults() 
	if not self.ticket then 
		return false 
	end
	local results = {}
	local MAX_CONSECUTIVE_DIGITS = 5 
	local todaysPrizes = self:getLottoPrizes()[1]
	local ticket = self.ticket 
	local collectiveDigitsMatched = 0 
	local largestConsecutiveDigits = 0 
	local largestConsecutiveDigitsData = {}
	local prizeWon = nil
	local matchedPokemon = nil 
	local function getMatchingDigits(id)
		local matchedDigits = 0 
		local sid = tostring(id)
		local tid = tostring(ticket)
		local consecutiveDigits = 0 
		for i = 0, 4 do 
			local currentDigit = sid:sub(#sid-i, #sid-i)
			local tCurrentDigit = tid:sub(#tid-i, #tid-i)
			if tonumber(currentDigit) == tonumber(tCurrentDigit) then 
				consecutiveDigits = consecutiveDigits + 1 
			else
				consecutiveDigits = 0 
			end
		end
		return consecutiveDigits
	end
	for i = 1, #self.party do 
		local pokeSummary = self.party[i]:getSummary({})
		local matchingDigits = getMatchingDigits(pokeSummary.id)
		if matchingDigits > largestConsecutiveDigits and matchingDigits <= MAX_CONSECUTIVE_DIGITS then 
			largestConsecutiveDigits = matchingDigits
			matchedPokemon = pokeSummary.species or pokeSummary.name
			largestConsecutiveDigitsData = {'Party', {i}, pokeSummary.id}
		end
	end
	for box = 1, #self.pc.boxes do 
		for p = 1, 30 do 
			if not self.pc.boxes[box][p] then break end 
			local pokeSummary = _f.ServerPokemon:deserialize(self.pc.boxes[box][p][3], self):getSummary({})
			local matchingDigits = getMatchingDigits(pokeSummary.id)
			if matchingDigits > largestConsecutiveDigits and matchingDigits <= MAX_CONSECUTIVE_DIGITS then 
				largestConsecutiveDigits = matchingDigits
				matchedPokemon = pokeSummary.species or pokeSummary.name
				largestConsecutiveDigitsData = {{'Box', box}, {box, p}, pokeSummary.id}
			end
		end
	end
	for i = 1, #self.daycare.depositedPokemon do
		local daycareDepositedPokemon = self.daycare.depositedPokemon[i]:getSummary({})
		local pokeSummary = daycareDepositedPokemon--:getSummary()
		local matchingDigits = getMatchingDigits(daycareDepositedPokemon.id)
		if matchingDigits > largestConsecutiveDigits and matchingDigits <= MAX_CONSECUTIVE_DIGITS then 
			largestConsecutiveDigits = matchingDigits
			matchedPokemon = pokeSummary.species or pokeSummary.name
			largestConsecutiveDigitsData = {'Daycare', {i}, daycareDepositedPokemon.id}
		end
	end
	local matchLocationFormat = {
		Party = 1,
		Daycare = 2,
		Box = 3
	}
	local prizeData = {}
	local matchLocation = largestConsecutiveDigitsData[1] 
	local extraneousArgument = nil 
	if typeof(matchLocation) == 'table' then
		extraneousArgument = matchLocation[2]
		matchLocation = matchLocation[1]
	end
	local formattedMatchLocation = matchLocationFormat[matchLocation]
	local matchData = {matchedPokemon, formattedMatchLocation}
	if extraneousArgument then 
		table.insert(matchData, extraneousArgument)
	end
	prizeWon = todaysPrizes[6-largestConsecutiveDigits]
	prizeData[1] = prizeWon 
	if not prizeWon then 
		return largestConsecutiveDigits, matchData, prizeData
	end
	local prizeData1, prizeData2 = string.match(prizeData[1], "([%w%s]+)/([%w%s]+)")
	if prizeData1 and prizeData2 then 
		local validPrizeData = {
			[1] = _f.Database.ItemById[Utilities.toId(prizeData1)],
			[2] = _f.Database.ItemById[Utilities.toId(prizeData2)]
		}
		if not validPrizeData[2] then --Mewtwonite Y
			local firstItem = prizeData[1]:match("([%w%s]+)/-")
			validPrizeData[2] = _f.Database.ItemById[Utilities.toId(string.format(firstItem:match("[%w]+")..'%s%s', ' ', prizeData2))]
		end
		if validPrizeData[1] and validPrizeData[2] then 
			local prizeWonName = validPrizeData[math.random(#validPrizeData)].name
			prizeWon = Utilities.toId(prizeWonName)
			prizeData[1] = prizeWonName
		end
	end
	local s, pokedexData = pcall(function()
		_f.DataService.fulfillRequest(nil, {'Pokedex', Utilities.toId(prizeWon)})
	end)
	if _f.Database.ItemById[Utilities.toId(prizeWon)] then 
		prizeData[2] = true 
	end
	local isItem = prizeData[2] == true 
	local numericMoneyValue = prizeData[1]:match("^%$([%d]+)")
	if isItem then
		self:addBagItems({id = Utilities.toId(prizeWon), quantity = 1})
	elseif numericMoneyValue then 
		if tonumber(numericMoneyValue) and typeof(tonumber(numericMoneyValue)) == 'number' then 
			self:addMoney(tonumber(numericMoneyValue))
		end
	elseif pokedexData then
		prizeData[3] = true 
		local pokemon = self:newPokemon({
			name = prizeWon,
			level = 6,
			shinyChance = 2048
		})
		self:PC_sendToStore(pokemon)
	end
	self.ticket = nil 
	return largestConsecutiveDigits, matchData, prizeData
end

--// Hyper Trainer
function PlayerData:hasbottlecaps()
	local bottlecaps = {
		_f.Database.ItemById.bottlecap,
		_f.Database.ItemById.goldbottlecap,
	}
	local e = {
		0,
		0
	}

	for i=1, #bottlecaps do
		pcall(function() 
			e[i] = self:getBagDataByNum(bottlecaps[i].num, 1).quantity 
		end)    
	end

	return unpack(e)
end
function PlayerData:ReturnMoves(moves)
	local Moves = {}		
	for _,v in pairs(moves) do
		for i,m in pairs(v) do
			if typeof(m) == 'string' then
				table.insert(Moves,m)
			end
		end
	end	
	return Moves
end
function PlayerData:CheckBanlist(Tier)
	self.format = Tier
	local tierList = {"Ubers", "UUbers", "OU", "UU"}
	if Tier == 'AG' then 
		return 
	end
	local banned = false
	local reason
	local Moves
	local seenSpecies = {}

	local MoveBans = {"doubleteam", "batonpass", "dragonascent", "minimize", "shedtail", "fissure", "sheercold", "guillotine", "horndrill", "lastrespects", "terablast", "assist"}
	local itemBans = {"BrightPowder", "King's Rock", "Razor Fang", "Quick Claw"}
	local bannedAbilities = {"Shadow Tag", "Arena Trap", "Moody"}

	local function ItemToNumber(id)
		return _f.Database.ItemById[id]
	end

	local function MoveToName(id)
		return _f.Database.MoveById[id]
	end

	if Tier == 'UU' then
		table.insert(itemBans, "Light Clay")
		table.insert(bannedAbilities, "Drizzle")
	end

	if Tier == 'Ubers' then
		table.remove(bannedAbilities, 1)
		table.remove(bannedAbilities, 1)
		table.remove(MoveBans, 5)
	end

	if Tier == 'UUbers' then
		table.remove(MoveBans, 5)
	end

	local banlists = {}
	for _, format in ipairs(tierList) do
		banlists[format] = require(game.ServerStorage.Data.ColoBanlist[format])
	end

	for _, poke in pairs(self.party) do
		local mon = string.lower(poke.name)
		Moves = self:ReturnMoves(poke.moves)

		-- Species Clause
		local formString = poke.forme or 'Base'
		local speciesKey = mon .. ":" .. formString

		if seenSpecies[speciesKey] then
			banned = true
			reason = "You cannot use more than one Pokemon with the same name and form. Please remove any duplicates or try another format."
			break
		end

		seenSpecies[speciesKey] = true

		-- Check move bans
		for _, move in pairs(Moves) do
			if table.find(MoveBans, move) then
				banned = true
				reason = poke.name .. " with the move " .. MoveToName(move) .. " is banned in this format. Please remove it or try a different format."
				break
			end
		end

		-- Check ability bans
		if not banned and table.find(bannedAbilities, poke:getAbilityName()) then
			banned = true
			reason = poke.name .. " with the ability " .. poke:getAbilityName() .. " is banned in this format. Please remove it from your team or try another format."
			break
		end

		-- Check item bans
		if not banned and table.find(itemBans, poke:getHeldItem().name) then
			banned = true
			reason = "The item " .. poke:getHeldItem().name .. " is banned in this format. Please remove it from your Pokemon or try another format."
			break
		end

		-- Pokemon-Specific Bans
		if not banned then
			for _, format in ipairs(tierList) do
				local bn = banlists[format]
				for _, entry in pairs(bn) do
					if entry.name == mon then
						-- Check banned moves
						for _, move in pairs(Moves) do
							if entry.moves and entry.moves == move then
								banned = true
								reason = poke.name .. " with the move " .. MoveToName(move) .. " is banned in this format. Please remove it from your team or try another format."
								break
							end
						end
						-- Check banned items
						if not banned and entry.item and ItemToNumber(entry.item) == poke.item then
							banned = true
							reason = poke.name .. " is holding an item that is banned from this format. Remove the item or try another format."
						end
						-- Check banned formes
						if not banned and entry.forme and entry.forme == poke.forme then
							banned = true
							reason = poke.name .. " in its " .. poke.forme .. " form is banned in this format. Please remove it from your team or try another format."
						elseif not banned and entry.forme == 'Base' and (poke.forme == '' or not poke.forme) then
							banned = true
							reason = poke.name .. " in its base form is banned in this format. Please remove it from your team or try another format."
						end
						-- Check general ban
						if not banned and entry.tier == "ALL" then
							banned = true
							reason = poke.name .. " is banned in this format. Try another format or remove it from your team."
						end
					end
					if banned then break end
				end
				if banned then break end
				if format == Tier then break end
			end
		end
		if banned then break end
	end

	return not banned, reason
end


function PlayerData:setFormat(format)
	if format then self.format = format end
	return self.format or 'AG'
end

function PlayerData:getFormat()
	return self.format or 'AG'
end

function PlayerData:pickberry(berrytype)
	if self.currentChunk ~= 'chunk76' then return false end

	local vaildberries = {
		['nanabberry'] = true,
		['razzberry'] = true,
		['blukberry'] = true,
		['wepearberry'] = true,
		['pinapberry'] = true
	}
	if not vaildberries[berrytype] then return false end

	local amount = self:random(3, 6)

	self:addBagItems({id = berrytype, quantity = amount})

	return amount
end

function PlayerData:trainpokemon(pokemonIndex, stat)
	local s, g = self:hasbottlecaps()
	if s == 0 and g == 0 then return end
	if not pokemonIndex or not self.party[pokemonIndex] then return end
	local pokemon = self.party[pokemonIndex]
	local stattable = {
		['HP'] = 1,
		['Attack'] = 2,
		['Defense'] = 3,
		['Sp Atk'] = 4,
		['Sp Def'] = 5,
		['Speed'] = 6,
	}
	if stat == 'all' then
		for k, v in pairs(stattable) do
			pokemon.ivs[v] = 31
		end
		local gbottlecap = _f.Database.ItemById.goldbottlecap
		self:incrementBagItem(gbottlecap.num, -1)
	else
		local ivindex = stattable[stat]
		for i,v in pairs(pokemon.ivs) do
			if i == ivindex then
				pokemon.ivs[i] = 31
			end
		end
		local bottlecap = _f.Database.ItemById.bottlecap
		self:incrementBagItem(bottlecap.num, -1)
	end

	self.party[pokemonIndex] = pokemon
end

function PlayerData:getivs(pokemonIndex, stat)
	if not pokemonIndex or not self.party[pokemonIndex] then return end
	local pokemon = self.party[pokemonIndex]
	if stat == 'all' then
		for i,v in pairs(pokemon.ivs) do
			if v ~= 31 then
				return false
			end
		end
		return true
	else
		local stattable = {
			['HP'] = 1,
			['Attack'] = 2,
			['Defense'] = 3,
			['Sp Atk'] = 4,
			['Sp Def'] = 5,
			['Speed'] = 6,
		}
		local ivindex = stattable[stat]
		for i,v in pairs(pokemon.ivs) do
			if i == ivindex then
				return pokemon.ivs[i]
			end
		end
	end
end

--// Z-Moves
function PlayerData:HasZMoveOn(pokemonIndex, itemId)
	local item = _f.Database.ItemById[itemId]
	local mon = self.party[pokemonIndex]

	if mon:getHeldItem() and mon:getHeldItem().zMove and mon:getHeldItem().num == item.num then
		return "Holding", Color3.fromRGB(85,145,211,255)
	elseif mon:canUseZCrystal(itemId) then 
		return "Compatible", Color3.fromRGB(255, 255, 255)
	else
		return "Incompatible", Color3.fromRGB(222, 99, 91, 255)
	end
end

function PlayerData:getCSceptileStage(stage) --// 2022 Winter Event
	local disabled = true
	if disabled then return false end
	local things = {}
	things.Minior = false
	things.Comfey = false
	things.Stardust = false

	local formeoverlap = false
	local miniorcount = 0
	local lastforme
	for _, p in pairs(self.party) do
		if p.num == 774 then
			miniorcount = miniorcount + 1
		end
	end
	for _, p in pairs(self.party) do
		if p.forme == lastforme then
			formeoverlap = true
		end
		lastforme = p.forme
	end
	if miniorcount == 6 and not formeoverlap then
		things.Minior = true
	end

	for _, p in pairs(self.party) do
		if p.num == 764 then
			things.Comfey = true
		end
	end

	if self:getBagDataById('stardust', 1) and self:getBagDataById('starpiece', 1) then
		if self:getBagDataById('stardust', 1).quantity >= 3 and self:getBagDataById('starpiece', 1).quantity >= 1 then
			things.Stardust = true
		end
	end

	if stage == 'check' then
		return things
	end

	if stage == 1 and things.Minior and not self.completedEvents.CollectMiniors then
		self:completeEventServer('CollectMiniors')
		return true
	end

	if stage == 2 and self.completedEvents.CollectMiniors and things.Comfey and not self.completedEvents.CollectComfeys then
		self:completeEventServer('CollectComfeys')
		return true
	end

	if stage == 3 and self.completedEvents.CollectComfeys and things.Stardust and not self.completedEvents.CollectStarItems then
		self:completeEventServer('CollectStarItems')

		self:incrementBagItem('stardust', -3)
		self:incrementBagItem('starpiece', -1)

		self:addBagItems({id = 'sceptilitec', quantity = 1})
		return true
	end
	return false
end

--// Arcade
function PlayerData:TixPurchase()
	game:GetService('MarketplaceService'):PromptProductPurchase(self.player, Assets.productId.TixPurchase.Value)
end

function PlayerData:buyWithTix(shopIndex, qty)
	local max, item, price = self:tMaxBuyInternal(shopIndex)
	if max == 'tm' then
		self:obtainTM(item)
		self.tix = self.tix - price
		return true, self.tix
	elseif type(max) == 'string' and max:sub(1,2) == 'pk' then
		qty = math.floor(qty)
		self.tix = self.tix - price*qty
		for i = 1,qty do
			-- Party
			local putmoninpc
			if #self.party >= 6 then
				putmoninpc = true
			end

			local pnum = 0
			if item == 'Ditto' then
				pnum = 132
			elseif item == 'Chansey' then
				pnum = 113
			elseif item == 'Audino' then
				pnum = 531
			end
			if not self:hasOwnedPokemon(pnum) then
				self:onOwnPokemon(pnum)	
			end

			local pokemon = self:newPokemon {
				name = item,
				level = 30,
				shinyChance = 2048,
				untradable = (item == 'Ditto'),
			}

			if putmoninpc then
				self:PC_sendToStore(pokemon)
			else
				self.party[#self.party + 1] = pokemon
			end
		end
		return true, self.tix
	elseif max == 'hb' then
		self:completeEventServer('hasHoverboard')
		table.insert(self.ownedHoverboards, item)
		self.tix = self.tix - price
		return true, self.tix
	end

	if not item or type(max) ~= 'number' or type(qty) ~= 'number' or max < qty or qty < 1 then return false end
	qty = math.floor(qty)
	self.tix = self.tix - price*qty
	self:addBagItems{num = item.num, quantity = qty}
	return true, self.tix
end

function PlayerData:tMaxBuyInternal(shopIndex)
	if not self.currentShop then return false end
	local itemIdPricePair = self.currentShop[shopIndex]
	if type(itemIdPricePair) ~= 'table' then return false end
	local itemId = itemIdPricePair[1]
	if type(itemId) ~= 'string' then return false end
	local price = itemIdPricePair[2]
	if type(price) ~= 'number' then return false end
	if itemId:sub(1, 2) == 'Tix' then return false end -- assumption: no items sold here later will start with "Tix"
	local tmNum = itemId:match('^TM(%d+)')
	local pkmn = itemId:sub(1, 4) == 'PKMN'
	local hover = itemId:sub(1, 5) == 'HOVER'
	local currentQty = 0
	if tmNum then
		tmNum = tonumber(tmNum)
		if BitBuffer.GetBit(self.tms, tmNum) then return 'ao' end -- already own
		if self.tix < price then return 'nm' end
		return 'tm', tonumber(tmNum), price
	elseif pkmn then
		local mon = string.split(itemId, ' ')[2]
		if not mon then return false end
		if self.tix < price  then return 'nm' end -- not enough money
		return 'pk-'..tostring(math.min(99-currentQty, math.floor(self.tix/price))), mon, price
	elseif hover then
		local hb = itemId:sub(7,#itemId)
		if not hb then return false end
		if self:ownsHoverboard(hb) then return 'aoh' end
		if self.tix < price  then return 'nm' end -- not enough money
		return 'hb', hb, price
	end

	local item = _f.Database.ItemById[itemId]
	if not item then return false end
	local bd = self:getBagDataByNum(item.num)
	if bd then
		currentQty = bd.quantity or 0
	end
	if currentQty >= 99 then return 'fb' end -- full bag
	if self.tix < price  then return 'nm' end -- not enough money
	return math.min(99-currentQty, math.floor(self.tix/price)), item, price
end

local MAX_RATE = 1
local CHECK_TIME = 10

function PlayerData:TixCheck(score, maxscore)
	if not self.tixcheck then
		self.tixcheck = {
			['Rate'] = 0,
		}
	end

	if not self.completedEvents.BlimpwJT then
		return 0
	end

	spawn(function()
		if score > 0 then
			self.tixcheck.Rate = self.tixcheck.Rate + 1
			wait(CHECK_TIME)
			self.tixcheck.Rate = self.tixcheck.Rate - 1
		end
	end)
	wait(.5)
	return score
end

function PlayerData:getArcadeRewardInfo(minigame)
	local minigameInfo = {
		alolan = {
			500,
			function(score)
				return score * 2
			end,
		},
		whack = {
			10000,
			function(score)
				return score / 170
			end,
		},
		skeeball = {
			800,
			function(score)
				return score / 10
			end,
		},
		hammer = {
			300,
			function(score)
				return score / 30
			end,
		},
	}

	return unpack(minigameInfo[minigame])
end

function PlayerData:ArcadeReward(minigame, score)
	if minigame == "alolan" and score >= 50 then
		self.flags.AA50 = true
	end
	local max, fn = self:getArcadeRewardInfo(minigame)
	score = self:TixCheck(score, max)
	local reward = fn(score)
	self:addTix(reward) 
end

function PlayerData:addTix(amount)
	if amount < 0 and self.tix+amount < 0 then return false end
	if amount > 0 and self.tix > MAX_TIX then return false end
	self.tix = math.min(math.floor(self.tix + amount), MAX_TIX)
	_f.Network:post('PDChanged', self.player, 'tix', self.tix)
	return true
end

function PlayerData:tMaxBuy(shopIndex)
	return (self:tMaxBuyInternal(shopIndex))
end
function PlayerData:rearrangeMoves(pokemonIndex, arrangedMoves)
	if type(pokemonIndex) ~= 'number' then return end    
	if pokemonIndex < 1 then return end
	if self:isInBattle() then return end
	if not self.party[pokemonIndex] then return end
	if self.party[pokemonIndex].egg then return end

	local poke = self.party[pokemonIndex]

	local newMoves = {}
	local valid = 1

	for _, oldmove in pairs(poke.moves) do
		if not table.find(arrangedMoves, oldmove.id) then 
			warn("Cannot find", oldmove.id, 'in new index') 
			valid = nil
			return
		end    
		newMoves[table.find(arrangedMoves, oldmove.id)] = Utilities.deepcopy(oldmove)
		valid = valid + 1
	end

	if valid == 5 then
		poke.moves = newMoves
	else
		return
	end
end

-- Save/Load Data
do
	local indexToEvent = {
		'MeetJake',
		'MeetParents',
		'ChooseFirstPokemon',
		'JakeBattle',
		'ParentsKidnappedScene',
		'BronzeBrickStolen',
		'JakeTracksLinda',
		'BronzeBrickRecovered',
		'PCPorygonEncountered',
		'EeveeAwarded',
		'IntroducedToGym1',		
		'GivenSawsbuckCoffee',
		'ReceivedRTD',
		'RunningShoesGiven',
		'GroudonScene',
		'JakeBattle2',
		'TalkToJakeAndSebastian',
		'IntroToUMV',
		'TestDriveUMV',
		'ReceivedBWEgg',			
		'DamBusted',
		'JakeStartFollow',
		'JakeEndFollow',
		'GivenSnover',
		'KingsRockGiven',
		'RosecoveWelcome',
		'LighthouseScene',
		'ProfAfterGym3',
		'JakeAndTessDepart',
		'RotomBit0',			
		'RotomBit1',
		'RotomBit2',
		'JTBattlesR9',
		'GivenLeftovers',
		'Jirachi',
		'Shaymin',
		'MeetAbsol',
		'ReachCliffPC',
		'BlimpwJT',
		'MeetGerald',
		'hasHoverboard',
		'G4FoundTape',			
		'G4GaveTape',
		'G4FoundWrench',
		'G4GaveWrench',
		'G4FoundHammer',
		'G4GaveHammer',
		'SeeTEship',
		'GeraldKey',
		'TessStartFollow',
		'TessEndFollow',
		'DefeatTEinAC',	
		'EnteredPast',
		'LearnAboutSanta',
		'BeatSanta',
		'NiceListReward',
		'vAredia',	
		'GiveEkans',
		'gsEkans',
		'Snorlax',			
		'TEinCastle',
		'G5Shovel',
		'G5Pickaxe',
		'RNatureForces',
		'Landorus',
		'RJO', 
		'RJP',
		'GJO',
		'GJP',
		'PJO',
		'PJP',
		'BJO',
		'BJP',
		'Victini',
		'vFluoruma',
		'PBSIntro',
		'FluoDebriefing',
		'OpenJDoor',
		'Diancie',
		'RBeastTrio',
		'Heatran',
		'TERt14',  
		'EonDuo',
		'vFrostveil',
		'TessBattle',
		'RevealCatacombs',
		'LightPuzzle',
		'SmashRockDoor',
		'CompletedCatacombs',
		'Regirock',
		'Registeel',
		'Regice',
		'OpenRDoor',
		'Regigigas',
		'GetSootheBell',
		'DefeatTinbell',
		'SwordsOJ',
		'Keldeo',
		'vPortDecca',
		'TalkToCap',
		'MeetScaleBuyer',
		'AdoptAifesShelter',
		'PushBarrels',
		'UnlockMewLab',
		'Mew',
		'VolItem1',
		'VolItem2',
		'VolItem3',
		'RevealSteamChamber',
		'Volcanion',
		'ObtainedZPouch',
		'FindZGrass',
		'FindZFire',
		'FindZWater',
		'FindZBug',
		'FindZIce',
		'FindZDragon',
		'BreakIceDoor',
		'WaterStone',
		'GrassStone',
		'OpenDDoor',
		'Articuno',
		'Zapdos',
		'Moltres',
		'GetSWing',
		'GetRevealGlass',
		'Lugia',
		'MeetTessBeach',
		'GRGiven',
		'SebastianRebattle',
		'Groudon',
		'MarshadowBattle',
		'LearnAboutSceptile',
		'CollectMiniors',
		'CollectComfeys',
		'CollectStarItems',
		'ZeldaSword',
		'vCrescent',
		'MeetFisherman',
		'EclipseBaseReveal',
		'ExposeSecurity',
		'PressSecurityButton',
		'FindCardKey',
		'UnlockGenDoor',
		'burndrive',
		'chilldrive',
		'dousedrive',
		'shockdrive',
		'Genesect',
		'ParentalSightings',
		'DefeatEclipseBase',
		'OpenEclipseGate',
		'DefeatHoopa',
		'ParentalReunion',
		'GrimReaper',
		'MarshBattle',
		'CresseliaBattle',

	}
	local div = ';'
	local div2 = '-'
	local pokemonDiv = ','

	local CHAT = game:GetService('TextService')

	function PlayerData:getContinueScreenInfo(gamemode)
		if not self.DataCache then
			self.DataCache = {}
		end

		local k = gamemode
		if not k then
			k = "adventure"
		end

		if self.DataCache[k] then
			return unpack(self.DataCache[k])
		end


		local str = select(1, self:getSaveData(gamemode))
		if not str then 
			self.DataCache[k] = {false}
			return false 
		end

		local ndiv = '([^'..div..']*)'
		local basic = str:match('^'..ndiv..div)
		local pokedex = ''
		local s = basic:find(div2, 1, true)
		if s then
			pokedex = basic:sub(s+1)
			basic = basic:sub(1, s-1)
			s = pokedex:find(div2, 1, true)
			if s then
				pokedex = pokedex:sub(1, s-1)
			end
		end
		local buffer = BitBuffer.Create()
		buffer:FromBase64(basic)
		local version = buffer:ReadUnsigned(6)
		local player = self.player
		local trainerName = buffer:ReadString()

		local success, r = pcall(function()
			return CHAT:FilterStringAsync(trainerName, player.UserId)
		end)

		if success and r then
			trainerName = r:GetNonChatStringForBroadcastAsync()
		else
			trainerName = player.Name
		end

		if trainerName == '' then trainerName = player.Name end
		local badges = 0
		for i = 1, 8 do
			if buffer:ReadBool() then
				badges = badges + 1
			end
		end
		local owned = 0
		buffer:FromBase64(pokedex)
		for _ = 1, pokedex:len()*3 do
			buffer:ReadBool()
			if buffer:ReadBool() then
				owned = owned + 1
			end
		end
		self.DataCache[k] = {true, trainerName, badges, owned}
		return true, trainerName, badges, owned
	end

	function PlayerData:serialize(etc)
		if not self.gameBegan then error('Attempted to save before game file was created.') end

		--// Basic Data Layout
		local saveString
		local buffer = BitBuffer.Create()

		local version = 16
		buffer:WriteUnsigned(6, version)

		--// Name
		buffer:WriteString(--[[etc.tName or]] self.trainerName)

		--// Badges
		for i = 1, 8 do
			buffer:WriteBool(self.badges[i] and true or false)
		end

		--// Events
		local maxEventIndex = 0
		for i = #indexToEvent, 1, -1 do
			if self.completedEvents[indexToEvent[i]] then
				maxEventIndex = i
				break
			end
		end
		buffer:WriteUnsigned(10, maxEventIndex)
		for i = 1, maxEventIndex do
			buffer:WriteBool(self.completedEvents[indexToEvent[i]] and true or false)
		end

		--// Currencies
		buffer:WriteUnsigned(24, math.min(self.money, MAX_MONEY))
		buffer:WriteUnsigned(14, math.min(self.bp, MAX_BP))
		buffer:WriteUnsigned(24, math.min(self.tix, MAX_TIX))

		--// Startables
		buffer:WriteBool(etc.expShareOn and true or false)
		buffer:WriteBool(self.flags.AA50 and true or false)
		buffer:WriteString(self.starterType or '')

		--// Repels
		if etc.repel and etc.repel.steps and etc.repel.steps > 0 then
			buffer:WriteBool(true)
			buffer:WriteUnsigned(2, etc.repel.kind)
			buffer:WriteUnsigned(8, math.ceil(etc.repel.steps/2))
		else
			buffer:WriteBool(false)
		end

		--// Honey & Encounters
		buffer:WriteUnsigned(12, math.min(4095, self.lastDrifloonEncounterWeek))
		buffer:WriteUnsigned(12, math.min(4095, self.lastTrubbishEncounterWeek))
		buffer:WriteUnsigned(12, math.min(4095, self.lastLaprasEncounterWeek))
		buffer:WriteUnsigned(15, math.min(32767, self.lastHoneyGivenDay))
		if self.honey then
			buffer:WriteBool(true)
			buffer:WriteFloat64(self.honey.slatheredAt)
			buffer:WriteString(self.honey.foe:serialize(true))
		else
			buffer:WriteBool(false)
		end

		--// Daycare
		buffer:WriteBool(self.daycare.manHasEgg and true or false)
		for i = 1, 2 do
			local poke = self.daycare.depositedPokemon[i]
			if poke then
				buffer:WriteBool(true)
				buffer:WriteString(poke:serialize(true))
				buffer:WriteUnsigned(7, poke.depositedLevel or poke.level)
			else
				buffer:WriteBool(false)
				break
			end
		end

		--// Options
		local function WriteOptBool(name, t)
			buffer:WriteBool((t or etc.options)[name] and true or false)
		end

		for i, v in pairs({"autosaveEnabled", "reduceGraphics"}) do
			WriteOptBool(v)
		end

		buffer:WriteUnsigned(7, etc.options.cSpeed)

		for i, v in pairs({"tSkip", "IconSFX", "pkmnIcon", "itemIcon", "sprite", "cHints", "weatherEnabled"}) do
			WriteOptBool(v, table.find({3, 4, 5}, i) and etc.options.pxSetting or nil)
		end

		buffer:WriteUnsigned(7, etc.options.page)
		buffer:WriteUnsigned(7, self.battleMode)
		buffer:WriteFloat64(etc.options.lastUnstuckTick or 0.0)

		--// Stamps
		buffer:WriteUnsigned(10, math.min(999, self.stampSpins))
		buffer:WriteUnsigned(10, #self.pbStamps)
		for _, stamp in pairs(self.pbStamps) do
			buffer:WriteUnsigned(4, stamp.sheet)
			buffer:WriteUnsigned(5, stamp.n)
			buffer:WriteUnsigned(5, stamp.color)
			buffer:WriteUnsigned(3, stamp.style)
			buffer:WriteUnsigned(7, math.min(99, stamp.quantity or 1))
		end

		--// Lotto
		if self.lottoTries and self.lastLottoTryDay then
			buffer:WriteBool(true)
			buffer:WriteFloat64(self.lottoTries)
			buffer:WriteFloat64(self.lastLottoTryDay)
		else
			buffer:WriteBool(false)
		end

		--// Hoverboards
		buffer:WriteString(self.currentHoverboard)
		buffer:WriteUnsigned(5, #self.ownedHoverboards)
		for _, h in ipairs(self.ownedHoverboards) do
			buffer:WriteString(h)
		end

		--// Surf
		buffer:WriteBool(self.SurfEnabled and true or false)

		--// Slope
		if self.slopeRecord then
			buffer:WriteBool(true)
			buffer:WriteFloat64(self.slopeRecord)
		else
			buffer:WriteBool(false)
		end

		saveString = buffer:ToBase64()

		--// Pokedex
		saveString = concatenate(saveString, div2, self.pokedex)

		--// Trainers
		saveString = concatenate(saveString, div2, self.defeatedTrainers, div2, self.tms, div2, self.hms)

		--// Party
		saveString = concatenate(saveString, div)
		for i = 1, 6 do
			if self.party[i] then
				if i ~= 1 then saveString = concatenate(saveString, pokemonDiv) end
				saveString = concatenate(saveString, self.party[i]:serialize())
			end
		end

		--// Bag
		saveString = concatenate(saveString, div, self.obtainedItems, div2)
		buffer:Reset()
		local stuff = {}
		for i = 1, 6 do
			for _, bd in pairs(self.bag[i]) do
				if bd.quantity > 0 then
					table.insert(stuff, { bd.num, bd.quantity or 1 })
				end
			end
		end
		buffer:WriteUnsigned(10, #stuff)
		for _, item in pairs(stuff) do
			buffer:WriteUnsigned(10, item[1])
			buffer:WriteUnsigned(7, math.min(99, item[2]))
		end
		saveString = concatenate(saveString, buffer:ToBase64())

		--// Location
		saveString = concatenate(saveString, div)
		if context == 'adventure' then
			saveString = concatenate(saveString, etc.location)
		else
			saveString = concatenate(saveString, self.adventureLocationData)
		end
		return saveString
	end

	function PlayerData:deserialize(str)
		if select(2, str:gsub(div, div)) ~= 3 then
			error('error (pd::ds): div count mismatch')
		end
		local etc = {}
		local ndiv = '([^'..div..']*)'
		local basic, party, bag, location = str:match('^'..string.rep(ndiv..div, 3)..ndiv)
		local s = basic:find(div2, 1, true)
		if s then
			self.pokedex = basic:sub(s+1)
			basic = basic:sub(1, s-1)
			s = self.pokedex:find(div2, 1, true)
			if s then
				self.defeatedTrainers = self.pokedex:sub(s+1)
				self.pokedex = self.pokedex:sub(1, s-1)
				s = self.defeatedTrainers:find(div2, 1, true)
				if s then
					self.tms = self.defeatedTrainers:sub(s+1)
					self.defeatedTrainers = self.defeatedTrainers:sub(1, s-1)
					s = self.tms:find(div2, 1, true)
					if s then
						self.hms = self.tms:sub(s+1)
						self.tms = self.tms:sub(1, s-1)
					end
				end
			end
		else
			print(basic, 'No pokedex data found')
		end
		etc.dTrainers = self.defeatedTrainers

		--// Basic Data Layout
		local buffer = BitBuffer.Create()
		buffer:FromBase64(basic)
		local version = buffer:ReadUnsigned(6)

		--// Name
		self.trainerName = buffer:ReadString()
		spawn(function()
			local player = self.player
			local success, r = pcall(function()
				return CHAT:FilterStringAsync(self.trainerName, player.UserId)
			end)

			if success and r then
				self.trainerName = r:GetNonChatStringForBroadcastAsync()
			else
				self.trainerName = player.Name
			end
			--self.trainerName = CHAT:FilterStringAsync(self.trainerName, player, player)
		end)
		if self.trainerName == '' then self.trainerName = self.player.Name end
		etc.tName = self.trainerName

		--// Badges
		local eb = {}
		for i = 1, 8 do
			if buffer:ReadBool() then
				self.badges[i] = true
				eb[tostring(i)] = true
			end
		end
		etc.badges = eb

		--// Events
		local maxEventIndex = buffer:ReadUnsigned(10)
		for i = 1, maxEventIndex do
			if buffer:ReadBool() then
				self.completedEvents[indexToEvent[i]] = true
			end
		end
		etc.completedEvents = Utilities.shallowcopy(self.completedEvents)

		--// Currencies
		self.money = buffer:ReadUnsigned(24)
		if version >= 1 then
			self.bp = buffer:ReadUnsigned(14)
		end
		if version >= 2 then
			self.tix = buffer:ReadUnsigned(24)
		end

		--// Startables
		if version >= 3 then
			etc.expShareOn = buffer:ReadBool()
			self.flags.AA50 = buffer:ReadBool()
			self.starterType = buffer:ReadString()
		end

		--// Repels
		if version >= 4 and buffer:ReadBool() then
			etc.repel = {}
			etc.repel.kind = buffer:ReadUnsigned(2)
			etc.repel.steps = buffer:ReadUnsigned(8) * 2
			local id = ({'repel', 'superrepel', 'maxrepel'})[etc.repel.kind]
			local more = self:getBagDataById(id, 1)
			if more and more.quantity and more.quantity > 0 then
				etc.repel.more = true
			end
		end

		--// Encounters
		if version >= 5 then
			self.lastDrifloonEncounterWeek = buffer:ReadUnsigned(12)
			self.lastTrubbishEncounterWeek = buffer:ReadUnsigned(12)
			self.lastLaprasEncounterWeek = buffer:ReadUnsigned(12)
			self.lastHoneyGivenDay = buffer:ReadUnsigned(15)
			if buffer:ReadBool() then
				local honey = {}
				honey.slatheredAt = buffer:ReadFloat64()
				honey.foe = _f.ServerPokemon:deserialize(buffer:ReadString(), self)
				self.honey = honey
			end
		end

		--// Daycare
		if version >= 6 then
			self.daycare.manHasEgg = buffer:ReadBool()
			if self.daycare.manHasEgg then
				etc.dcEgg = true
			end
			for i = 1, 2 do
				if not buffer:ReadBool() then break end
				local poke = _f.ServerPokemon:deserialize(buffer:ReadString(), self)
				poke.depositedLevel = buffer:ReadUnsigned(7)
				self.daycare.depositedPokemon[i] = poke
			end
		end

		--// Options
		if version >= 7 then
			etc.options = {}

			local function ReadOptBool(name)
				if buffer:ReadBool() then
					etc.options[name] = true
				end
			end

			for _, v in pairs({"autosaveEnabled", "reduceGraphics"}) do
				ReadOptBool(v)
			end

			if version >= 16 then
				etc.options.cSpeed = buffer:ReadUnsigned(7)

				for _, v in pairs({"tSkip", "IconSFX", "pkmnIcon", "itemIcon", "sprite", "cHints", "weatherEnabled"}) do
					ReadOptBool(v)
				end

				etc.options.page = buffer:ReadUnsigned(7)
				self.battleMode = buffer:ReadUnsigned(7)

			elseif version >= 15 then
				etc.options.cSpeed = buffer:ReadUnsigned(7)

				for _, v in pairs({"tSkip", "IconSFX", "pkmnIcon", "itemIcon", "sprite", "cHints"}) do
					ReadOptBool(v)
				end

				etc.options.weatherEnabled = true
				etc.options.page = buffer:ReadUnsigned(7)
				self.battleMode = buffer:ReadUnsigned(7)

			else
				etc.options.cSpeed = buffer:ReadBool() and 9 or 4
				etc.options.tSkip = false
				etc.options.IconSFX = false
				etc.options.pkmnIcon = true
				etc.options.itemIcon = true
				etc.options.sprite = true
				etc.options.cHints = true
				etc.options.weatherEnabled = true
				etc.options.page = 1
			end

			pcall(function()
				etc.options.lastUnstuckTick = buffer:ReadFloat64()
			end)
		end
		--// Stamps
		if version >= 8 then
			self.stampSpins = buffer:ReadUnsigned(10)
			local pbStamps = {}
			for i = 1, buffer:ReadUnsigned(10) do
				local stamp = {}
				stamp.sheet = buffer:ReadUnsigned(4)
				stamp.n     = buffer:ReadUnsigned(5)
				stamp.color = buffer:ReadUnsigned(5)
				stamp.style = buffer:ReadUnsigned(3)
				stamp.quantity = buffer:ReadUnsigned(7)
				stamp.id    = _f.PBStamps:getStampId(stamp)
				pbStamps[i] = stamp
			end
			self.pbStamps = pbStamps
		end

		--// Lotto
		if version >= 9 then
			if buffer:ReadBool() then
				self.lottoTries = buffer:ReadFloat64()
				self.lastLottoTryDay = buffer:ReadFloat64()
			end
		end
		function PlayerData:moveTutor()

			return {
				bp = self.bp,
				money = self.money,
				d = self:createDecision {
					callback = function(_, pokemonIndex)
						if not pokemonIndex or not self.party[pokemonIndex] then return end
						local pokemon = self.party[pokemonIndex]
						if pokemon.egg then return 0, 'eg' end

						local allMoves
						pcall(function() allMoves = pokemon:getLearnedMoves() end)
						local moves = {}
						if allMoves then

							-- get moves that level up
							for _, d in pairs(allMoves) do					
								if type(d) == 'number' then
									table.insert(moves, d)
								else
									for i = 2, #d do
										table.insert(moves, d[i])
									end
								end

							end
							-- remove duplicate moves
							for i, move in pairs(moves) do
								for j = #moves, i+1, -1 do
									if move == moves[j] then
										table.remove(moves, j)
									end
								end
							end
							-- remove currently known moves
							for _, move in pairs(pokemon:getMoves()) do
								for j = #moves, 1, -1 do
									if move.num == moves[j] then
										table.remove(moves, j)
										break
									end
								end
							end
						end
						if #moves == 0 then return pokemon.name, 'nm' end
						local validMovesNumToId = {}
						for i, moveNum in pairs(moves) do
							local move = _f.Database.MoveByNumber[moveNum]
							if type(moveNum) == 'number' then
								pcall(function()
									local move = _f.Database.MoveByNumber[moveNum]
									if move then
										moves[i] = {
											num = move.num,
											name = move.name,
											category = move.category,
											type = move.type,
											power = move.basePower,
											accuracy = move.accuracy,
											pp = move.pp,
											desc = move.desc
										}
										validMovesNumToId[moveNum] = move.id
									end
								end)
							elseif type(moveNum) == 'table' then
								if not moveNum['type'] then
									moves[i] = nil
								else
									validMovesNumToId[moveNum] = moveNum.id
								end
							else
								moves[i] = nil
							end
						end

						return pokemon.name, {
							nn = pokemon:getName(),
							known = pokemon:getCurrentMovesData(),
							moves = moves,
							d = self:createDecision {
								callback = function(_, paymentMethod, moveNum, moveSlot)
									if (paymentMethod ~= 1 and paymentMethod ~= 2)
										or (moveSlot ~= 1 and moveSlot ~= 2 and moveSlot ~= 3 and moveSlot ~= 4) then
										return
									end
									local moveId = validMovesNumToId[moveNum]
									if not moveId then warn("NO MOVEID") return end
									pokemon.moves[moveSlot] = {id = moveId}
									if paymentMethod == 1 then
										if not (self:addBP(-100)) then return end
									else
										if not (self:addMoney(-100000)) then return end
									end
								end
							}
						}
					end
				}
			}
		end
		--// Hoverboards
		if version >= 10 then
			local function tryFixSpinnerBoard(board)
				if not board then return "" end

				local l = string.len(board)
				local res, n = string.gsub(board, " ", ".")

				if string.find(board, "Spinner") and n == 1 then
					return string.sub(board, 1, l-8).. " Fidget Spinner"
				end

				return board
			end

			self.currentHoverboard = tryFixSpinnerBoard(buffer:ReadString())

			local oh = {}

			for i = 1, buffer:ReadUnsigned(5) do
				oh[i] = tryFixSpinnerBoard(buffer:ReadString())
			end

			self.ownedHoverboards = oh
		end

		--// Surf
		if version >= 11 then
			self.SurfEnabled = buffer:ReadBool()
			if self.SurfEnabled then
				etc.Surfing = true
			end
		end

		--// Slope
		if version >= 12 then
			if buffer:ReadBool() then
				self.slopeRecord = buffer:ReadFloat64()
				etc.slopeRecord = self.slopeRecord
			end
		end

		--// Party
		local p = 1
		for s in party:gmatch('[^'..pokemonDiv..']+') do
			if s and s ~= '' then
				self.party[p] = _f.ServerPokemon:deserialize(s, self)
				p = p + 1
			end
		end
		if not self.party[1] then
			etc.newGameFlag = true
		end

		--// Bag
		if bag and bag ~= '' then
			local s = bag:find(div2, 1, true)
			if s then
				self.obtainedItems = bag:sub(1, s-1)
				bag = bag:sub(s+1)
				buffer:FromBase64(bag)
				for _ = 1, buffer:ReadUnsigned(10) do
					local num = buffer:ReadUnsigned(10)
					local qty = buffer:ReadUnsigned(7)
					self:addBagItems({num = num, quantity = qty})
				end
			end
		end

		--// Location
		if context == 'adventure' then
			etc.location = location
		else
			self.adventureLocationData = location
		end
		if #self.daycare.depositedPokemon > 0 then
			etc.daycareHasPokemon = true
		end

		-- Restore RO Powers
		self:ROPowers_restore()

		-- Absol Failsafe (Pokedex & Mega Keystone)
		if self.completedEvents.EnteredPast then
			if not self:getBagDataById('megakeystone', 5) then
				self:addBagItems{id = 'megakeystone', quantity = 1}
				self:onOwnPokemon(359)
			else
				self:onOwnPokemon(359)
			end
		end

		--// Lugia Failsafe
		if self.completedEvents.Lugia then
			if not self.completedEvents.GetSWing then
				self.completedEvents.Lugia = nil
			else
			end
		end

		--// Groudon Failsafe
		if self.completedEvents.Groudon then
			if not self.completedEvents.SebastianRebattle then
				self.completedEvents.Groudon = nil
			else
			end
		end

		--// Reveal Glass Failsafe
		if self.completedEvents.GetRevealGlass then
			if not self:getBagDataById('revealglass', 5) then
				self:addBagItems{id = 'revealglass', quantity = 1}
			end
		end

		-- Update Player Lists (and get dex count)
		self:updatePlayerListEntry(true)

		-- Pseudo-events / Server-events
		if BitBuffer.GetBit(self.hms, 1) then
			etc.completedEvents.GetCut = true
		end
		if self:getBagDataById('oldrod', 5) then
			etc.completedEvents.GetOldRod = true
		end
		for k, v in pairs(_f.PlayerEvents) do
			if type(v) == 'table' and v.server then
				etc.completedEvents[k] = nil
			end
		end

		etc.rotom = self:getRotomEventLevel()

		--Objectives
		local l_event
		for i=1, #indexToEvent do
			local Objectives = _f.Database.Objectives.Events
			local Event = indexToEvent[i]

			local v = self.completedEvents
			if self.completedEvents[Event] then
				if Objectives[Event] then
					l_event = Event
				end
			end
		end
		local BagesObjectives = {
			'BronzeBrickRecovered',
			'GroudonScene',
			'LighthouseScene',
			'MeetGerald',
			'TEinCastle',
			'vFluoruma',
			'vFrostveil',
			'vCrescent'
		}

		local Objective = _f.Database.Objectives.Events[l_event]
		if table.find(BagesObjectives, l_event) then
			local num = table.find(BagesObjectives, l_event)
			if self.badges[num] then
				Objective = _f.Database.Objectives.Badges[num]
			end
		end
		if not Objective or not Objective.Texts then
			Objective = {}
			Objective.Texts = {'Please Report this and how it showed up', 'Join the Community server and report this in Bugs'}
		end
		_f.Network:post('newObjective', self.player, Objective.Texts)
		--Objectives

		return etc
	end
end

function PlayerData:getSaveData(gamemode)
	if self.loadedData and self.gamemode == gamemode then 
		return self.loadedData[1], self.loadedData[2]
	end
	local data, pcData
	self.gamemode = gamemode
	while true do
		local s, d, p
		pcall(function()
			s, d, p = _f.DataPersistence.LoadData(self.player, gamemode)
		end)
		if s then
			data = d
			pcData = p
			break
		end
		wait(1.5)
	end
	self.loadedData = {data, pcData}
	return data, pcData
end

function PlayerData:saveGame(etc)
	if not self.gameBegan or self.userId < 1 then return false end -- refuse to save guests' data
	-- todo: refuse during battle or trade?
	if not etc or type(etc)  ~= 'table'
		--		or type(etc.tName)   ~= 'string'
		or type(etc.options) ~= 'table'
		or type(etc.options.lastUnstuckTick) ~= 'number'
		or (type(etc.location) ~= 'string' and _f.Context == 'adventure') -- location is not required in battle/trade contexts
	then
		print('BAD ETC FROM PLAYER '..self.player.Name)
		return false
	end
	local s, r = pcall(function() return self:serialize(etc) end)

	if not s then
		print(self.player.Name..' ENCOUNTERED ERROR DURING SERIALIZATION:')
		_f.Logger:logError(self.player, {
			ErrType = "Serialization Error",
			Errors = tostring(r)
		})
		return false
	end
	local saveString = r
	s, r = pcall(function() return self:PC_serialize() end)
	if not s then
		print(self.player.Name..' ENCOUNTERED ERROR DURING PC SERIALIZATION:')
		_f.Logger:logError(self.player, {
			ErrType = "PC Serialization Error",
			Errors = tostring(r)
		})
		return false
	end
	local pcString = r
	for _ = 1, 3 do
		s = _f.DataPersistence.SaveData(self.player, saveString, pcString, self.gamemode)
		if s then
			self.lastSaveEtc = etc
			return true
		end
		wait(.1)
	end
	return false
end

function PlayerData:getRotomEventLevel()
	local v = 0
	for i = 0, 2 do
		if self.completedEvents['RotomBit'..i] then
			v = v + 2^i
		end
	end
	return v
end
function PlayerData:setRotomEventLevel(v)
	for i = 2, 0, -1 do
		local p = 2^i
		if v >= p then
			v = v - p
			self.completedEvents['RotomBit'..i] = true
		else
			self.completedEvents['RotomBit'..i] = false
		end
	end
end

-- important for preventing data leaks
function PlayerData:destroy()
	for _, p in pairs(self.party) do
		p:destroy()
	end
	self.party = nil
	for _, p in pairs(self.daycare.depositedPokemon) do
		p:destroy()
	end
	self.daycare = nil
	if self.honey and self.hony.foe then
		self.honey.foe:destroy()
	end
	self.honey = nil
	pcall(function() self.pcSession:destroy() end)
	self.pcSession = nil
	pcall(function() self.mineSession:destroy() end)
	self.mineSession = nil
end

--// enter/leave connections //--
local players = game:GetService('Players')
players.PlayerAdded:connect(onPlayerEnter)
for _, p in pairs(players:GetChildren()) do onPlayerEnter(p) end
players.PlayerRemoving:connect(function()
	for player, data in pairs(PlayerDataByPlayer) do
		if not player or not player.Parent then
			PlayerDataByPlayer[player] = nil
			if data.gameBegan then
				pcall(function() data:ROPowers_save() end)
			end
			pcall(function() data:destroy() end)
		end
	end
end)

return PlayerDataByPlayer--PlayerData -- OVH  is this what we want?