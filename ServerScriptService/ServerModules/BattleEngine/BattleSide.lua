local undefined, null, class, jsonEncode, Not, shallowcopy; do
	local util = require(game:GetService('ServerStorage'):WaitForChild('src').BattleUtilities)
	undefined = util.undefined
	null = util.null
	class = util.class
	Not = util.Not
	jsonEncode = util.jsonEncode
	shallowcopy = util.shallowcopy
end

local weightedRandom = require(script.Parent.Parent).Utilities.weightedRandom
local BattlePokemon = require(script.Parent.BattlePokemon)
local _debug = game:GetService("RunService"):IsStudio()

local function dprint(...)
	if _debug then print(...) end
end

local AI_TEST_LOGS_IN_STUDIO = true
local AI_TEST_CALLBACKS = false

local BattleSide = class({
	className = 'BattleSide',

	isActive = false,
	pokemonLeft = 0,
	faintedLastTurn = false,
	faintedThisTurn = false,
	totalFainted = 0,
	currentRequest = '',
	--	decision = nil,
	--	foe = nil,
	--	megaAdornment = nil,

}, function(self, name, battle, n, team, megaAdornment, zmoveAdornment, dynaAdornment)
	self.battle = battle
	self.n = n
	self.name = name
	self.megaAdornment = megaAdornment
	self.zmoveAdornment = zmoveAdornment
	self.dynaAdornment = dynaAdornment
	self.pokemon = {}
	self.active = {null}
	self.totalFainted = 0
	self.sideConditions = {}

	self.id = 'p'..n

	if battle.gameType == 'doubles' then
		self.active = {null, null}
	elseif battle.gameType == 'triples' or battle.gameType == 'rotation' then
		self.active = {null, null, null}
	end

	local pl = 0
	for i = 1, math.min(#team, 6) do
		local p = BattlePokemon:new(nil, team[i], self)
		if not p.index then
			p.index = i
		end
		table.insert(self.pokemon, p)
		p.fainted = p.hp == 0
		if p.hp > 0 then
			pl = pl + 1
		end
	end
	self.pokemonLeft = pl
	for i = 1, #self.pokemon do
		self.pokemon[i].position = i
	end

	self.switchQueue = {}
	self.alreadySwitched = {}

	return self
end)

function BattleSide:toString()
	return self.id .. ': ' .. self.name
end

function BattleSide:start()
	local pos = 1
	for i, p in pairs(self.pokemon) do
		if p.hp > 0 then
			self.battle:switchIn(p, pos)
			pos = pos + 1
			if pos > #self.active then break end
		end
	end
end

function BattleSide:getDifficulty()
	if _debug then return 6 end
	return self.difficulty or 1
end

function BattleSide:getData(context)
	local data = {
		id = self.id,
		nActive = #self.active,
	}
	if context == 'switch' then
		local h = {}
		data.healthy = h
		for i, pokemon in pairs(self.pokemon) do
			h[i] = not pokemon.egg and pokemon.hp > 0
		end
	end
	return data
end

function BattleSide:getRelevantDataChanges()
	local data = {
		pokemon = {}
	}
	if self.battle.pvp then return data end
	for i, pokemon in pairs(self.pokemon) do
		local d = {
			hp = pokemon.hp,
			status = pokemon.status,
			moves = {},
			index = pokemon.index,
			evs = {pokemon.evs.hp, pokemon.evs.atk, pokemon.evs.def, pokemon.evs.spa, pokemon.evs.spd, pokemon.evs.spe},
		}
		if pokemon.statusData and pokemon.statusData.time then
			if pokemon.statusData.time <= 0 then
				d.status = nil
			else
				d.status = d.status .. math.min(3, pokemon.statusData.time)
			end
		end
		for i2, move in pairs(pokemon.moveset) do
			d.moves[i2] = {
				id = move.move,
				pp = move.pp,
			}
		end
		table.insert(data.pokemon, d)
	end
	return data
end

function BattleSide:canSwitch()
	for _, pokemon in pairs(self.pokemon) do
		if not pokemon.isActive and not pokemon.fainted then
			return true
		end
	end
	return false
end

function BattleSide:randomActive()
	local actives = {}
	for _, p in pairs(self.active) do
		if p ~= null and not p.fainted then
			table.insert(actives, p)
		end
	end
	if #actives == 0 then return null end
	return actives[math.random(#actives)]
end

function BattleSide:addSideCondition(status, source, sourceEffect)
	status = self.battle:getEffect(status)
	if self.sideConditions[status.id] then
		if not status.onRestart then return false end
		if self.battle:singleEvent('Restart', status, self.sideConditions[status.id], self, source, sourceEffect) then
			self.sideConditions[status.id].layers = (self.sideConditions[status.id].layers or 1) + 1
			return true
		end
		return false
	end
	self.sideConditions[status.id] = {id = status.id, target = self, layers = 1}
	if source then
		self.sideConditions[status.id].source = source
		self.sideConditions[status.id].sourcePosition = source.position
	end
	if status.duration then
		self.sideConditions[status.id].duration = status.duration
	end
	if status.durationCallback then
		self.sideConditions[status.id].duration = self.battle:call(status.durationCallback, self, source, sourceEffect)
	end
	if not self.battle:singleEvent('Start', status, self.sideConditions[status.id], self, source, sourceEffect) then
		self.sideConditions[status.id] = nil
		return false
	end
	self.battle:runEvent('SideConditionStart', source, source, status)
	self.battle:update()
	return true
end

function BattleSide:getSideCondition(status)
	status = self.battle:getEffect(status)
	if not self.sideConditions[status.id] then return null end
	return status
end

function BattleSide:getSCDur(status)
	status = self.battle:getEffect(status)
	return self.sideConditions[status.id].duration or 0
end

function BattleSide:removeSideCondition(status)
	status = self.battle:getEffect(status)
	if not self.sideConditions[status.id] then return false end
	self.battle:singleEvent('End', status, self.sideConditions[status.id], self)
	self.sideConditions[status.id] = nil
	self.battle:update()
	return true
end

function BattleSide:send(...)
	local sideUpdate = {...}
	for i, su in pairs(sideUpdate) do
		if type(su) == 'function' then
			sideUpdate[i] = su(self)
		end
	end
	self.battle:send('sideupdate', self.id, unpack(sideUpdate))
end

function BattleSide:emitCallback(...)
	if self.name == '#Wild' then
		return
	end
	self.battle:sendToPlayer(self.id, 'callback', self.id, ...)
end


function BattleSide:_aiDebugEnabled()
	if self.forceAIDebug ~= nil then
		return self.forceAIDebug
	end
	if self.battle and self.battle.aiDebug ~= nil then
		return self.battle.aiDebug
	end
	return _debug and AI_TEST_LOGS_IN_STUDIO
end

function BattleSide:_aiEmitTestMessage(msg)
	if not self:_aiDebugEnabled() then return end
	print('[AI TEST]', self.id, msg)
	if AI_TEST_CALLBACKS and self.emitCallback then
		-- Avoid re-entrant callback execution on the same stack, which can
		-- cascade into ScriptTimeout when debug callbacks trigger additional
		-- battle-side work.
		task.defer(function()
			pcall(function()
				self:emitCallback('aidebug', msg)
			end)
		end)
	end
end

function BattleSide:_aiDescribeTarget(target)
	if not target or target == null then
		return 'none'
	end
	return target.species or target.name or target.id or '?'
end

function BattleSide:_aiDescribeMove(user, moveSlot)
	if not user or not moveSlot then return 'unknown' end
	return tostring(user.moves[moveSlot] or moveSlot)
end

function BattleSide:_aiLogTopChoices(user, candidateRows, chosenMove, chosenTargetLoc, chosenScore)
	if not self:_aiDebugEnabled() then return end
	if not user then return end
	table.sort(candidateRows, function(a, b)
		return a.score > b.score
	end)
	local parts = {}
	for i = 1, math.min(3, #candidateRows) do
		local row = candidateRows[i]
		parts[#parts+1] = string.format('%s->%s=%.1f', row.moveName, row.targetName, row.score)
	end
	local chosenMoveName = self:_aiDescribeMove(user, chosenMove)
	local chosenTargetName = 'self'
	if chosenTargetLoc and chosenTargetLoc ~= 0 and self.foe and self.foe.active and self.foe.active[chosenTargetLoc] then
		chosenTargetName = self:_aiDescribeTarget(self.foe.active[chosenTargetLoc])
	elseif chosenTargetLoc and chosenTargetLoc ~= 0 and self.active and self.active[chosenTargetLoc] then
		chosenTargetName = self:_aiDescribeTarget(self.active[chosenTargetLoc])
	end
	self:_aiEmitTestMessage(string.format('%s chose %s -> %s (%.1f) | top: %s', self:_aiDescribeTarget(user), chosenMoveName, chosenTargetName, chosenScore or -9999, table.concat(parts, ' | ')))
end


local function _aiClamp(x, lo, hi)
	if x < lo then return lo end
	if x > hi then return hi end
	return x
end

function BattleSide:_aiGetChoiceSuffix(a, pokemon)
	local suffix = ''
	if a.canMegaEvo then
		suffix = ' mega'
	elseif a.canZMove then
		suffix = ' zmov'
	elseif a.canUltra then
		suffix = ' ultra'
	elseif a.canDynamax then
		suffix = ' dynamax'
	elseif a.currentDyna then
		suffix = ''
	end

	if pokemon and pokemon.willDmax then
		pokemon.willDmax = false
		suffix = ' dynamax'
	end

	return suffix
end

function BattleSide:_aiTypeEffectiveness(moveData, target)
	if not target or target == null then return 1 end
	local effectiveness = 1
	for _, t in pairs(target:getTypes()) do
		effectiveness = effectiveness * (self.battle.data.TypeChart[t][moveData.type] or 1)
	end
	return effectiveness
end

function BattleSide:_aiEstimateDamage(user, target, moveData)
	if not user or not target or target == null or target.fainted then
		return 0
	end

	local effectiveBaseDamage = moveData.baseDamage or moveData.basePower or 0
	if effectiveBaseDamage <= 0 then
		return 0
	end

	if user.ability == 'technician' and effectiveBaseDamage <= 60 then
		effectiveBaseDamage = effectiveBaseDamage * 1.5
	end
	if moveData.id == 'venoshock' and (target.status == 'psn' or target.status == 'tox') then
		effectiveBaseDamage = effectiveBaseDamage * 2
	end

	if moveData.flags and moveData.flags.charge and user.item ~= 'powerherb' and not (moveData.id == 'solarbeam' and self.battle:isWeather({'sunnyday', 'desolateland'})) then
		effectiveBaseDamage = effectiveBaseDamage / 2
	elseif moveData.flags and moveData.flags.recharge and self.foe and self.foe.pokemonLeft > 1 then
		effectiveBaseDamage = effectiveBaseDamage / 2
	end

	local accuracy = type(moveData.accuracy) == 'number' and moveData.accuracy or 100
	effectiveBaseDamage = effectiveBaseDamage * accuracy / 100

	if moveData.willCrit then
		effectiveBaseDamage = effectiveBaseDamage * 1.5
	elseif moveData.critRatio and moveData.critRatio > 1 then
		effectiveBaseDamage = effectiveBaseDamage * (1.5 / (({16, 8, 2, 1})[math.min(4, moveData.critRatio)]))
	end

	if user:hasType(moveData.type) then
		effectiveBaseDamage = effectiveBaseDamage * (moveData.stab or 1.5)
	end

	local minDamage, maxDamage
	if moveData.damage == 'level' then
		minDamage, maxDamage = user.level, user.level
	elseif moveData.damage then
		minDamage, maxDamage = moveData.damage, moveData.damage
	else
		local category = self.battle:getCategory(moveData)
		local defensiveCategory = moveData.defensiveCategory or category
		local level = user.level
		local attackStat = (category == 'Physical') and 'atk' or 'spa'
		local defenseStat = (defensiveCategory == 'Physical') and 'def' or 'spd'

		local atkBoosts = moveData.useTargetOffensive and target.boosts[attackStat] or user.boosts[attackStat]
		local defBoosts = moveData.useSourceDefensive and user.boosts[defenseStat] or target.boosts[defenseStat]

		if moveData.ignoreOffensive or (moveData.ignoreNegativeOffensive and atkBoosts < 0) then
			atkBoosts = 0
		end
		if moveData.ignoreDefensive or (moveData.ignorePositiveDefensive and defBoosts > 0) then
			defBoosts = 0
		end

		local attack
		if moveData.useTargetOffensive then
			attack = target:calculateStat(attackStat, atkBoosts)
		else
			attack = user:calculateStat(attackStat, atkBoosts)
		end

		local defense
		if moveData.useSourceDefensive then
			defense = user:calculateStat(defenseStat, defBoosts)
		else
			defense = target:calculateStat(defenseStat, defBoosts)
		end

		maxDamage = math.floor(math.floor(math.floor(2 * level / 5 + 2) * effectiveBaseDamage * attack / math.max(1, defense)) / 50) + 2
		maxDamage = math.floor(maxDamage * self:_aiTypeEffectiveness(moveData, target))
		minDamage = math.floor(.85 * maxDamage)
	end

	local estimated = (minDamage + maxDamage) / 2

	if moveData.multihit then
		if type(moveData.multihit) == 'table' then
			estimated = estimated * moveData.multihit[1]
		else
			estimated = estimated * moveData.multihit
		end
	end

	return math.max(0, estimated)
end

function BattleSide:_aiSupportsSelf(moveData)
	return moveData.target == 'self' or moveData.target == 'allySide' or moveData.target == 'allyTeam'
end

function BattleSide:_aiSupportsAlly(moveData)
	return moveData.target == 'adjacentAlly' or moveData.target == 'adjacentAllyOrSelf'
end

function BattleSide:_aiScoreMove(user, moveSlot, target, targetLoc)
	local moveId = user.moves[moveSlot]
	local moveData = self.battle:getMove(moveId)
	local score = 0

	-- Hard fail-state checks for obviously unusable moves.
	if moveData.id == 'snore' or moveData.id == 'sleeptalk' then
		if user.status ~= 'slp' then
			return -100000, targetLoc
		end
	end
	if moveData.id == 'rest' then
		if user.status == 'slp' then
			return -100000, targetLoc
		end
		if user.hp >= user.maxhp then
			return -100000, targetLoc
		end
	end
	if moveData.id == 'dreameater' then
		if not target or target == user or target.status ~= 'slp' then
			return -100000, targetLoc
		end
	end

	if self:_aiSupportsSelf(moveData) then
		target = user
		targetLoc = 0
	end

	if not target and not self:_aiSupportsSelf(moveData) and not self:_aiSupportsAlly(moveData) and moveData.target ~= 'allAdjacentFoes' then
		return -100000, nil
	end

	if moveData.weather then
		if self.battle:isWeather(moveData.weather) then
			score = score - 30
		else
			score = score + 18
		end
	end

	if moveData.flags and moveData.flags.heal and (not moveData.basePower or moveData.basePower < 1) then
		local missing = user.maxhp - user.hp
		if missing <= 0 then
			score = score - 60
		else
			score = score + 70 * (missing / math.max(1, user.maxhp))
			if user.hp <= user.maxhp * 0.35 then
				score = score + 25
			end
		end
	end

	if moveData.id == 'rest' then
		local hpRatio = user.hp / math.max(1, user.maxhp)
		if hpRatio <= 0.25 then
			score = score + 95
		elseif hpRatio <= 0.4 then
			score = score + 45
		elseif hpRatio <= 0.6 then
			score = score + 8
		else
			score = score - 80
		end
		if user.status ~= '' and user.status ~= 'slp' then
			score = score + 22
		end
	end

	if moveData.id == 'protect' or moveData.id == 'detect' or moveData.id == 'kingsshield' or moveData.id == 'spikyshield' or moveData.id == 'banefulbunker' then
		local protectScore = 5
		if user.hp <= user.maxhp * 0.35 then
			protectScore = protectScore + 45
		end
		score = score + protectScore
	end

	if moveData.status and target and target ~= user then
		if target.status ~= '' then
			score = score - 25
		else
			score = score + 28
			if moveData.status == 'slp' then
				score = score + 20
			elseif moveData.status == 'par' then
				score = score + 12
			elseif moveData.status == 'brn' and target:getStat('atk') >= target:getStat('spa') then
				score = score + 14
			end
		end
	end

	if moveData.boosts and target == user then
		local boostScore = 0
		for stat, amount in pairs(moveData.boosts) do
			if amount > 0 and (stat == 'atk' or stat == 'spa' or stat == 'spe') then
				boostScore = boostScore + amount * 18
			end
		end
		if user.hp > user.maxhp * 0.55 then
			score = score + boostScore
		else
			score = score + boostScore * 0.35
		end
	end

	if moveData.id == 'helpinghand' then
		local ally = nil
		for _, p in pairs(self.active) do
			if p ~= null and p ~= user and not p.fainted then
				ally = p
				break
			end
		end
		if ally then
			score = score + 34
		else
			score = score - 50
		end
	end

	local estimatedDamage = self:_aiEstimateDamage(user, target, moveData)
	if estimatedDamage > 0 and target and target ~= user then
		local hp = math.max(1, target.hp)
		local ratio = estimatedDamage / hp
		score = score + _aiClamp(ratio, 0, 2.5) * 75

		local effectiveness = self:_aiTypeEffectiveness(moveData, target)
		if effectiveness == 0 then
			score = score - 200
		elseif effectiveness > 1 then
			score = score + 22 * effectiveness
		elseif effectiveness < 1 then
			score = score - 18
		end

		if target.ability == 'wonderguard' and effectiveness <= 1 then
			score = score - 200
		end

		if estimatedDamage >= target.hp then
			score = score + 120
			if moveData.priority and moveData.priority > 0 then
				score = score + 20
			end
			if not self.battle:getPseudoWeather('trickroom') and user:getStat('spe') > target:getStat('spe') then
				score = score + 20
			end
		end

		if moveData.target == 'allAdjacentFoes' or moveData.target == 'allAdjacent' then
			local extraTargets = 0
			for _, foe in pairs(self.foe.active) do
				if foe ~= null and foe ~= target and not foe.fainted then
					extraTargets = extraTargets + 1
				end
			end
			score = score + extraTargets * 20
		end
	elseif (moveData.baseDamage or moveData.basePower or 0) > 0 then
		score = score - 80
	end

	if type(moveData.accuracy) == 'number' then
		score = score - math.max(0, 100 - moveData.accuracy) * 0.35
	end

	return score, targetLoc
end

function BattleSide:_aiChooseBestMoveForPokemon(user, requestData, slot)
	if not user or user == null or user.fainted or not requestData then
		return nil, nil, '', -100000
	end

	local enabledMoves = {}
	for i, m in pairs(requestData.moves) do
		if not m.disabled and (not m.pp or m.pp > 0) then
			table.insert(enabledMoves, i)
		end
	end

	if #enabledMoves == 0 then
		return 1, nil, self:_aiGetChoiceSuffix(requestData, user), -100000
	end

	local bestMove, bestTargetLoc
	local bestScore = -100000
	local suffix = self:_aiGetChoiceSuffix(requestData, user)
	local candidateRows = {}

	local foeTargets = {}
	for i, foe in pairs(self.foe.active) do
		if foe ~= null and foe and not foe.fainted then
			table.insert(foeTargets, {pokemon = foe, loc = i})
		end
	end

	local allyTargets = {}
	for i, ally in pairs(self.active) do
		if ally ~= null and ally and ally ~= user and not ally.fainted then
			table.insert(allyTargets, {pokemon = ally, loc = i})
		end
	end

	for _, moveSlot in pairs(enabledMoves) do
		local moveData = self.battle:getMove(user.moves[moveSlot])

		if user.aiStrategy then
			local preferred = user.aiStrategy(self.battle, self, user, foeTargets[1] and foeTargets[1].pokemon or nil)
			if preferred and user.moves[moveSlot] == preferred then
				local forcedLoc = foeTargets[1] and foeTargets[1].loc or nil
				candidateRows[#candidateRows+1] = {moveName = self:_aiDescribeMove(user, moveSlot), targetName = forcedLoc and self:_aiDescribeTarget(foeTargets[1].pokemon) or 'self', score = 9999}
				self:_aiLogTopChoices(user, candidateRows, moveSlot, forcedLoc, 9999)
				return moveSlot, forcedLoc, suffix, 9999
			end
		end

		if self:_aiSupportsSelf(moveData) then
			local score = self:_aiScoreMove(user, moveSlot, user, 0)
			candidateRows[#candidateRows+1] = {moveName = self:_aiDescribeMove(user, moveSlot), targetName = 'self', score = score}
			if score > bestScore then
				bestScore, bestMove, bestTargetLoc = score, moveSlot, 0
			end
		elseif self:_aiSupportsAlly(moveData) then
			if #allyTargets == 0 and moveData.target == 'adjacentAllyOrSelf' then
				local score = self:_aiScoreMove(user, moveSlot, user, 0)
				candidateRows[#candidateRows+1] = {moveName = self:_aiDescribeMove(user, moveSlot), targetName = 'self', score = score}
				if score > bestScore then
					bestScore, bestMove, bestTargetLoc = score, moveSlot, 0
				end
			end
			for _, allyData in pairs(allyTargets) do
				local score, loc = self:_aiScoreMove(user, moveSlot, allyData.pokemon, allyData.loc)
				candidateRows[#candidateRows+1] = {moveName = self:_aiDescribeMove(user, moveSlot), targetName = self:_aiDescribeTarget(allyData.pokemon), score = score}
				if score > bestScore then
					bestScore, bestMove, bestTargetLoc = score, moveSlot, loc
				end
			end
		elseif moveData.target == 'allAdjacentFoes' or moveData.target == 'allAdjacent' then
			local anchor = foeTargets[1]
			local score, loc = self:_aiScoreMove(user, moveSlot, anchor and anchor.pokemon or nil, anchor and anchor.loc or 1)
			candidateRows[#candidateRows+1] = {moveName = self:_aiDescribeMove(user, moveSlot), targetName = anchor and self:_aiDescribeTarget(anchor.pokemon) or 'spread', score = score}
			if score > bestScore then
				bestScore, bestMove, bestTargetLoc = score, moveSlot, loc
			end
		else
			for _, foeData in pairs(foeTargets) do
				local score, loc = self:_aiScoreMove(user, moveSlot, foeData.pokemon, foeData.loc)
				candidateRows[#candidateRows+1] = {moveName = self:_aiDescribeMove(user, moveSlot), targetName = self:_aiDescribeTarget(foeData.pokemon), score = score}
				if score > bestScore then
					bestScore, bestMove, bestTargetLoc = score, moveSlot, loc
				end
			end
		end
	end

	if not bestMove then
		bestMove = enabledMoves[math.random(#enabledMoves)]
	end

	self:_aiLogTopChoices(user, candidateRows, bestMove, bestTargetLoc, bestScore)
	return bestMove, bestTargetLoc, suffix, bestScore
end

function BattleSide:AIChooseMove(request)
	if request.requestType ~= 'move' then
		self.battle:debug('non-move request sent to AI foe side')
		return
	end

	local choices = {}

	for n, a in pairs(request.active) do
		local pokemon = self.active[n]
		if pokemon ~= null and pokemon and not pokemon.fainted then
			local move, targetLoc, suffix, bestScore = self:_aiChooseBestMoveForPokemon(pokemon, a, n)
			if move then
				local choice = 'move ' .. move
				if targetLoc and targetLoc ~= 0 and #self.foe.active > 1 then
					choice = choice .. ' ' .. targetLoc
				end
				choices[n] = choice .. (suffix or '')
				self:_aiEmitTestMessage(string.format('slot %d command = %s', n, choices[n]))
			end
		end
	end

	self.battle:choose(nil, self.id, choices, self.battle.rqid)
end

function BattleSide:getSwitchIndex(battle, target, alreadySwitched, midTurn)
	local smartTrainer = self:getDifficulty() > 5
	local switchScores = {}
	local moveData = target and target.lastMove and battle:getMoveCopy(target.lastMove) or nil
	local switchIndex = nil
	local highScore = -10

	if Not(target) or Not(target.lastMove) or not smartTrainer then
		return false
	end

	for i, pokemon in pairs(self.pokemon) do
		local score = 0
		battle.npcMove = true
		moveData = battle:runEvent('ModifyMove', target, pokemon, moveData, moveData)

		if alreadySwitched[i] or pokemon.isActive or pokemon.hp <= 0 then
			score = -10
		else
			local enabledMoves = pokemon:getEnabledMoves()
			local estimatedDamage = battle:getDamage(target, pokemon, moveData, true) or 0
			local hitResult = battle:runEvent('Try', moveData, nil, pokemon, target, moveData)
			local suckerCheck = moveData.category ~= 'Status'

			if Not(estimatedDamage) then
				estimatedDamage = 0
			end

			if moveData.multihit then
				if type(moveData.multihit) == 'table' then
					estimatedDamage *= moveData.multihit[1]
				else
					estimatedDamage *= moveData.multihit
				end
			end

			if (moveData.basePower or 0) > 0 then
				if estimatedDamage > 0 and estimatedDamage < 0.4 * pokemon.hp then
					score += math.floor((0.4 - (estimatedDamage / pokemon.hp)) * 10) / 10
				elseif estimatedDamage == 0 then
					score += 1
				end
			end

			if Not(hitResult) then
				if not (moveData.id == 'suckerpunch' and suckerCheck) then
					score += 2
				end
			end

			if not (pokemon:getItem().id == 'heavydutyboots' or pokemon:hasAbility('tangledfeet')) then
				if self.sideConditions.stealthrock and pokemon:runEffectiveness('Rock') > 1 then
					score -= 1 * (pokemon:runEffectiveness('Rock') / 2)
				end
				if self.sideConditions.spikes and pokemon:isGrounded() then
					score -= self.sideConditions.spikes.layers / 3
				end
				if self.sideConditions.toxicspikes and pokemon:isGrounded() and not pokemon:hasType("Steel", "Poison") then
					score -= self.sideConditions.toxicspikes.layers / 2
				end
			end

			if midTurn then
				if pokemon:getItem().megaStone then
					score -= 10
				end
			end

			if pokemon:hasAbility('supremeoverlord') then
				score -= 1
			end

			for _, m in pairs(enabledMoves) do
				battle.npcMove = true
				local userMove = battle:getMoveCopy(pokemon.moves[m])
				userMove = battle:runEvent('ModifyMove', pokemon, target, userMove, userMove)
				local revengeDamage = battle:getDamage(pokemon, target, userMove, true) or 0
				local userHitResult = battle:runEvent('Try', userMove, nil, pokemon, target, userMove)

				if Not(revengeDamage) then
					revengeDamage = 0
				end

				if userMove.multihit then
					if type(userMove.multihit) == 'table' then
						revengeDamage *= userMove.multihit[1]
					else
						revengeDamage *= userMove.multihit
					end
				end

				if Not(userHitResult) then
					if not (userMove.id == 'suckerpunch' and userMove.category ~= 'Status') then
						revengeDamage = 0
					end
				end

				if revengeDamage >= target.hp and pokemon:getStat('spe') > target:getStat('spe') and not battle:getPseudoWeather('trickroom') then
					score += 1
					break
				end
			end
		end

		switchScores[i] = score
		dprint(pokemon.species, score)
		if score > highScore then
			highScore = score
			switchIndex = i
		end
	end

	if highScore <= 0 then
		return false
	end

	print("Switch Index: ", switchIndex, self.pokemon[switchIndex].species)
	return switchIndex
end

function BattleSide:AIChooseSwitch(choices, target)
	local battle = self.battle
	self.alreadySwitched = self.alreadySwitched or {}
	local smartSwitch = self:getSwitchIndex(battle, target, self.alreadySwitched, true)

	if not smartSwitch or self:getDifficulty() < 6 then
		self.switchQueue = {}
		return false
	end

	for n, a in pairs(self.switchQueue) do
		local s = smartSwitch
		if s then
			choices[n] = 'switch ' .. s
			self.alreadySwitched[s] = true
		end
	end

	self.switchQueue = {}
	self.battle:choose(nil, self.id, choices, self.battle.rqid)
	return true
end

function BattleSide:AIForceSwitch(request)
	local battle = self.battle
	local target = self.foe.active[1] or self.foe.active[2] or self.foe.active[3]
	self.alreadySwitched = self.alreadySwitched or {}

	local smartSwitch = self:getSwitchIndex(battle, target, self.alreadySwitched)

	local function getValidPokemonIndex()
		for i, p in pairs(self.pokemon) do
			if not self.alreadySwitched[i] and not p.isActive and p.hp > 0 then
				return i
			end
		end
	end

	local fs = request.forceSwitch
	local choices = {}
	for i = 1, #fs do
		if fs[i] then
			local s = smartSwitch or getValidPokemonIndex()
			if s then
				choices[i] = 'switch ' .. s
				self.alreadySwitched[s] = true
			else
				choices[i] = 'pass'
			end
		else
			choices[i] = 'pass'
		end
	end

	dprint("Choices: ")
	dprint(choices)
	self.battle:choose(nil, self.id, choices, self.battle.rqid)
end

function BattleSide:emitRequest(request)
	if request.forceSwitch or request.foeAboutToSendOut then
		request.requestType = 'switch'
	elseif request.teamPreview then
		request.requestType = 'team'
	elseif request.wait then
		request.requestType = 'wait'
	elseif request.active then
		request.requestType = 'move'
	end

	if (self.name == '#Wild' or self.battle.isTrainer) and self.n == 2 then
		if request.requestType == 'move' then
			if self.name == '#Wild' and self.battle.isSafari then
				self.battle:choose(nil, self.id, {"pokerun"}, self.battle.rqid)
			else
				self:AIChooseMove(request)
			end
		elseif request.requestType == 'switch' then
			self:AIForceSwitch(request)
		end
		return
	end

	local d = self.battle:getDataForTransferToPlayer(self.id, true)
	if d and #d > 0 then
		request.qData = d
	end
	self.battle:sendToPlayer(self.id, 'request', self.id, self.battle.rqid, request)
end

function BattleSide:resolveDecision()
	if self.decision then
		return self.decision
	end

	local decisions = {}
	local cr = self.currentRequest
	self.battle:debug('resolving:', cr)

	if cr == 'move' then
		for _, pokemon in pairs(self.active) do
			if pokemon ~= null and not pokemon.fainted then
				local lockedMove = pokemon:getLockedMove()
				if lockedMove then
					table.insert(decisions, {
						choice = 'move',
						pokemon = pokemon,
						targetLoc = self.battle:runEvent('LockMoveTarget', pokemon) or 0,
						move = lockedMove
					})
				else
					local moveid = 'struggle'
					for _, m in pairs(pokemon:getMoves()) do
						if not m.disabled then
							moveid = m.id
							break
						end
					end
					table.insert(decisions, {
						choice = 'move',
						pokemon = pokemon,
						targetLoc = 0,
						move = moveid
					})
				end
			end
		end
	elseif cr == 'switch' then
		local canSwitchOut = {}
		for i, pokemon in pairs(self.active) do
			if pokemon ~= null and pokemon.switchFlag then
				table.insert(canSwitchOut, i)
			end
		end

		local canSwitchIn = {}
		for i = #self.active + 1, #self.pokemon do
			if self.pokemon[i] ~= null and not self.pokemon[i].fainted then
				table.insert(canSwitchIn, i)
			end
		end

		for i, s in pairs(canSwitchOut) do
			table.insert(decisions, {
				choice = self.foe.currentRequest == 'switch' and 'instaswitch' or 'switch',
				pokemon = self.active[s],
				target = self.pokemon[canSwitchIn[i]]
			})
		end

		for i = math.min(#canSwitchOut, #canSwitchIn) + 1, #canSwitchOut do
			table.insert(decisions, {
				choice = 'pass',
				pokemon = self.active[canSwitchOut[i]],
				priority = 102
			})
		end
	elseif cr == 'teampreview' then
		local team = {}
		for i = 1, #self.pokemon do
			team[i] = i
		end
		table.insert(decisions, {
			choice = 'team',
			side = self,
			team = team
		})
	end

	return decisions
end

function BattleSide:destroy()
	for i = 1, #self.pokemon do
		if self.pokemon[i] then
			self.pokemon[i]:destroy()
		end
		self.pokemon[i] = nil
	end
	self.pokemon = nil

	for i = 1, #self.active do
		self.active[i] = nil
	end
	self.active = nil

	if self.decision and self.decision ~= true then
		self.decision.side = nil
		self.decision.pokemon = nil
	end
	self.decision = nil

	self.battle = nil
	self.foe = nil
end

return BattleSide
