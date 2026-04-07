local _f = require(script.Parent)

local storage = game:GetService('ServerStorage')
local repStorage = game:GetService('ReplicatedStorage')
local teleportService = game:GetService("TeleportService")
local Assets = require(storage.src.Assets) -- for follow privacy
local Utilities = _f.Utilities--require(storage:WaitForChild('Utilities'))
local network = _f.Network--require(script.Parent.Network)
local remote = repStorage:WaitForChild('Remote')
--local Date = require(script.Parent.Date)
local totalWeather=3
local dataTime
pcall(function()
	dataTime = _f.Date:getDate()
end)

local weathers={
	'',
	'rain',
	'wind',
}
local currentHour
pcall(function()
	currentHour = _f.Date:getDate().Hour
	_f.currentWeather =  dataTime.Weather

end)
--weathers[(((dataTime.DayOfMonth+dataTime.Hour)*(dataTime.MonthNum-dataTime.Hour%dataTime.MonthNum))%totalWeather)+1]
local weather

local function kick(player)
	pcall(function() player:Kick() end)
	wait()
	pcall(function() player:Kick() end)
	pcall(function() player:Destroy() end)
end
local function getWeather()
	return _f.Date:getDate().Weather
	--weathers[(((_f.Date:getDate().DayOfMonth+_f.Date:getDate().Hour)*(_f.Date:getDate().MonthNum-_f.Date:getDate().Hour%_f.Date:getDate().MonthNum))%totalWeather)+1]
end

-- Launch
do
	local launchedPlayers = setmetatable({}, {__mode='k'})
	local function newPlayer(player)
		if not player:IsA('Player') then return end

		-- Remove sounds from Hats
		local function checkObj(obj)
			local function check(o)
				if o:IsA('Sound') then
					wait()
					o:Destroy()
				else
					for _, ch in pairs(o:GetChildren()) do
						checkObj(ch)
					end
				end
			end
			if obj:IsA('Accoutrement') then
				check(obj)
				obj.DescendantAdded:connect(check)
			end
		end
		local function scanCharacter(character)
			character.ChildAdded:connect(checkObj)
			for _, ch in pairs(character:GetChildren()) do
				checkObj(ch)
			end
		end
		player.CharacterAdded:connect(scanCharacter)
		if player.Character then
			scanCharacter(player.Character)
		end

		-- Initiate Secure Launch
		--		local p_launch = storage.Launcher:Clone()
		--		p_launch.Changed:connect(function(property)
		--			if property == 'Disabled' then
		--				kick(player)
		--			elseif property == 'Parent' then
		--				if not p_launch.Parent and not launchedPlayers[player] then
		--					kick(player)
		--				end
		--			end
		--		end)
		--		p_launch.Parent = player:WaitForChild('PlayerScripts')
	end

	remote:WaitForChild('Launch').OnServerInvoke = function(player)
		if launchedPlayers[player] then
			kick(player)
			return nil
		end
		launchedPlayers[player] = true
		local dest = player:WaitForChild('PlayerGui')
		local d = storage.Driver:Clone()
		storage.Utilities:Clone().Parent = d
		storage.Plugins:Clone().Parent = d
		storage.src.Assets:Clone().Parent = d
		local ui = storage.src.UsableItemsClient:Clone()
		ui.Name = 'UsableItems'
		ui.Parent = d.Plugins.Menu.Bag
		storage.src.BattleUtilities:Clone().Parent = d.Plugins.Battle
		d.Parent = dest
		return d
	end

	local players = game:GetService('Players')
	players.ChildAdded:connect(newPlayer)
	for _, p in pairs(players:GetChildren()) do newPlayer(p) end
end

do -- system shouts
	spawn(function()
		local shouts = {
			'There is an Autosave feature that you can enable from the Options menu.',
			'If you ever get stuck, go to the Options menu and click "Get Unstuck".',
			'Don\'t forget to save often! If you don\'t save, your data cannot be restored.',
			'If you find a bug in the game, please take a screenshot and/or record a video and post it in the #bug-reports channel in the Community server server with an explanation of what\'s wrong.',
			'Don\'t forget to join the Community server! If you don\'t join, your data cannot be restored.',
			'Can\'t use the shop on mobile? Tap with two fingers to fix this issue.',
			'All gamepasses have been made free to reduce hassle and to increase player enjoyment! To obtain them, make sure to join the group in the description!',
			'Experiencing freezes, but no errors in the client console? Try to avoid using third party applications, such as FPS unlockers & exploits as these may cause issues or get you banned!',
			'Stuck in the void? Inside of a white box, and getting unstuck won\'t work no matter how many times you try to use it? Don\'t worry, this is easily fixable by simply saving inside of the white box and then immediately rejoining the game. Once you\'ve done so, pressing the unstuck button should now work flawlessly.',
			'Everything looking blurry? Hard to read certain text, or text missing entirely? Try reinstalling Roblox, or head over to your settings and clear data and cache. This is an issue out of our control however, this method should fix everything.'
		}
		if _f.Context == 'adventure' then
			table.insert(shouts, 3, 'The "Reduced Graphics" feature is available in the Options menu. Turn it on and you may find that the game runs more smoothly.')
			table.insert(shouts, 4, 'The RTD that you receive after beating the first gym allows you to travel to places where you can trade and battle with other trainers.')
			table.insert(shouts, 'The game is not yet complete. There are currently 7 gyms, and content is continually being added to the game.')
		elseif _f.Context == 'trade' then
			table.insert(shouts, 1, 'When trading Pokemon, please follow the trading rules listed in the official Community server. This will prevent you from getting scammed.')
			table.insert(shouts, 2, 'PB Stamps do not trade. When a Pokemon with stamps is traded, the stamps return to the owner\'s Stamp Case.')
		elseif _f.Context == 'battle' then
			table.insert(shouts, 1, 'If you battle the same player more than once within an hour, only the first battle will award BP. Battle a variety of trainers!')
			table.insert(shouts, 2, 'All purchasable items in the BP Shop have been cut in half for your enjoyment. This is not to be taken advantage of and they will not be reduced or increased in price.')
			table.insert(shouts, 3, 'Even more TMs and Items will be added to the BP Shop in the future. Patience is greatly appreciated!')
		end
		local shoutNumber = 0
		while true do
			wait(6 * 30)
			shoutNumber = (shoutNumber % #shouts) + 1
			network:postAll('SystemChat', shouts[shoutNumber])
		end
	end)
end
spawn(function()
	while true do
		--wait(1)
		wait(math.random(28, 55))
		if _f.currentWeather == 'meteor' then
			local RNG = Random.new()
			local items = game:GetService('ServerStorage').MeteorHitLocations.RockGoBrrr:GetChildren() --Change for cosmeos 🙂
			local Part = items[math.random(1, #items)]        
			local Position = Part.Position
			local Size = Part.Size

			local MinX , MaxX= Position.X - Size.X/2, Position.X + Size.X/2
			local MinY, MaxY = Position.Y - Size.Y/2, Position.Y + Size.Y/2
			local MinZ, MaxZ = Position.Z - Size.Z/2, Position.Z + Size.Z/2
			local X, Y, Z = RNG:NextNumber(MinX, MaxX), RNG:NextNumber(MinY, MaxY), RNG:NextNumber(MinZ, MaxZ) 

			local RanPosition = Vector3.new(X, Y, Z)
			local variant
			if math.random(1, 75) == 35 then
				variant = (math.random(1,2) == 1 and 1 or 2)
			end
			--Randomize chunk that'll have the meteors crashing
			network:postAll('smallCrash', 'chunk51', RanPosition, variant or 3, variant) --4
			--game:GetService('ServerStorage')
		end
	end
end)

do -- weather update
	spawn(function()        
		local mins = _f.Date:getDate().Minute
		local sec = _f.Date:getDate().Second
		while true do
			if _f.Context ~= 'adventure' then break end
			wait((60*(60 - tonumber(mins)))-tonumber(sec))
			weather = getWeather()
			if weather == '' then
				network:postAll('weatherChange', {End={{''}, _f.currentWeather}})
			else                
				network:postAll('weatherChange', {End={{''}, _f.currentWeather},Start={{''},weather},StartNotif={Poke={name='',icon=9999},regionName='Roria',weatherKind=weather}})
			end
			_f.currentWeather = weather
			mins = _f.Date:getDate().Minute
			sec = _f.Date:getDate().Second
		end
	end)
end
-- Wear Submarine :]
do
	local pdata = {}
	network:bindFunction('ToggleSubmarine', function(player, on)
		if not _f.PlayerDataService[player] or (_f.PlayerDataService[player] and not _f.PlayerDataService[player].mineSession) then return end
		if not player.Character then return end
		if on then
			if pdata[player] then return end
			local d = {hats = {}, parts = {}}
			for _, ch in pairs(player.Character:GetChildren()) do
				if ch:IsA('BasePart') then
					d.parts[ch] = ch.Transparency
					ch.Transparency = 1.0
				elseif ch:IsA('Accoutrement') then
					table.insert(d.hats, ch)
					ch.Parent = nil
				end
			end
			local model = game:GetService('ServerStorage').Models.UMVModel:Clone()
			model.Parent = player.Character
			local root = model.Root
			for _, p in pairs(model:GetChildren()) do
				if p ~= root and p:IsA('BasePart') then
					local w = Instance.new('Weld', root)
					w.Part0 = root
					w.Part1 = p
					w.C0 = CFrame.new()
					w.C1 = p.CFrame:inverse() * root.CFrame
					w.Parent = root
					p.Anchored = false
					p.CanCollide = false
				end
			end
			local motor = model.Propellor.Motor
			for _, p in pairs(model.Propellor:GetChildren()) do
				if p ~= motor and p:IsA('BasePart') then
					local w = Instance.new('Weld', motor)
					w.Part0 = motor
					w.Part1 = p
					w.C0 = CFrame.new()
					w.C1 = p.CFrame:inverse() * motor.CFrame
					w.Parent = root
					p.Anchored = false
					p.CanCollide = false
				end
			end
			local motorWeld = Instance.new('Weld', root)
			motorWeld.Part0 = model.MotorHinge
			motorWeld.Part1 = motor
			motorWeld.C0 = CFrame.new()
			motorWeld.C1 = CFrame.new()
			motorWeld.Parent = model.MotorHinge
			motor.Anchored = false
			motor.CanCollide = false
			root.Anchored = false
			root.CanCollide = false
			local hroot = player.Character:FindFirstChild('HumanoidRootPart')
			local w = Instance.new('Weld', hroot)
			w.Part0 = hroot
			w.Part1 = root
			w.C0 = CFrame.Angles(0, math.pi, 0)
			w.C1 = CFrame.new()
			w.Parent = hroot
			d.model = model
			pdata[player] = d
			return motorWeld, model.MotorHinge.Bubbles
		else
			if not pdata[player] then return end
			local d = pdata[player]
			pdata[player] = nil
			for _, hat in pairs(d.hats) do
				hat.Parent = player.Character
			end
			for part, trans in pairs(d.parts) do
				part.Transparency = trans
			end
			d.model:Destroy()
			pcall(function()
				local pd = _f.PlayerDataService[player]
				pd.mineSession:destroy()
				pd.mineSession = nil
			end)
		end
	end)
end


-- Relay Battle Requests
local battling = {}
local function battlesec(from, to, settings)
	if _f.Context ~= 'battle' then return false end
	if not settings.error and not settings.joinBattle and not settings.accepted and not settings.teamPreviewReady then
		battling[from.UserId] = to
		return true
	elseif settings.accepted then
		if battling[to.UserId] == from then
			return true
		end
		return false
	elseif battling[to.UserId] == from or battling[from.UserId] == to then
		return true
	else
		return false
	end
end
network:bindEvent('BattleRequest', function(from, to, settings)
	if not battlesec(from, to, settings) then return end
	-- inject team party icons if appropriate
	local myIcons, theirIcons
	if settings.accepted or settings.joinBattle then
		if settings.teamPreviewEnabled then
			theirIcons = _f.PlayerDataService[from]:getTeamPreviewIcons()
		end
		myIcons = _f.PlayerDataService[to]:getTeamPreviewIcons()
	end
	if myIcons then
		settings.icons = {myIcons, theirIcons}
	end
	--
	network:post('BattleRequest', to, from, settings)
end)

-- Relay Trade Requests
local trading = {}
local function tradesec(from, to, settings)
	if _f.Context ~= 'trade' then return false end
	if not settings.error and not settings.joinTrade and not settings.accepted then
		trading[from.UserId] = to
		return true
	elseif settings.accepted then
		if trading[to.UserId] == from then
			return true
		end
		return false
	elseif trading[to.UserId] == from or trading[from.UserId] == to then
		if settings.joinTrade then
			_f.updateTitle(from, 'Trading')
		end
		return true
	else
		return false
	end
end
network:bindEvent('TradeRequest', function(from, to, settings)
	if not tradesec(from, to, settings) then return end
	network:post('TradeRequest', to, from, settings)
end)

-- Update Player Title (currently only relevant in battle/trade contexts)
do -- OVH  TODO: REMOVE CLIENT INTERFACE (alerady did)
	local write = Utilities.Write
	local titles = {}
	function _f.updateTitle(player, title, color, clearIfNotBattling)
		if clearIfNotBattling and player and titles[player] and titles[player].Name == 'Battling' then return end
		pcall(function() titles[player]:Destroy() end)
		if not player or not player.Parent or not title or not player.Character then return end
		local head = player.Character:FindFirstChild('Head')
		if not head then return end
		local part = Utilities.Create 'Part' {
			Name = title,
			Transparency = 1.0,
			Anchored = false,
			CanCollide = false,
			--			FormFactor = Enum.FormFactor.Custom,
			Size = Vector3.new(.2, .2, .2),
			CFrame = head.CFrame * CFrame.new(0, 2, 0),
			Archivable = false,
			Parent = player.Character,
		}
		titles[player] = part
		Utilities.Create 'Weld' {
			Part0 = head,
			Part1 = part,
			C0 = CFrame.new(0, 2, 0),
			C1 = CFrame.new(),
			Parent = head,
		}
		local bbg = Utilities.Create 'BillboardGui' {
			Size = UDim2.new(10.0, 0, 0.8, 0),
			Parent = part, Adornee = part,
		}
		--		wait()
		write(title) {
			Frame = Utilities.Create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.8, 0),
				Position = UDim2.new(0.5, 0, 0.1, 0),
				Parent = bbg,
			}, Scaled = true, Color = color,
		}
	end
	network:bindEvent('UpdateTitle', function(player)
		_f.updateTitle(player)
	end)
	--	_G.UpdateTitle = updateTitle
end

-- GetPlayerPlaceInstanceAsync
do
	local returnedSetting = {}

	local FirebaseService = _f.FirebaseService
	local pOptions = {1, 2, 3} -- for protection

	-- Privacy Data
	local FollowPrivacyStore = FirebaseService:GetFirebase('FP')

	local function getPrivacy(plr, UserId)
		local id = tostring(UserId)

		local data

		local succ, err = pcall(function()
			data = FollowPrivacyStore:GetAsync(id) 
		end)

		if not succ then
			_f.Logger:logError(plr, {
				ErrType = "Follow Privacy",
				Errors = 'Couldn\'t fetch follow privacy options for "'..UserId..'", ('..(err and err or "No error given")..')'
			})
		end

		return (succ and data) and tonumber(data) or 1
	end

	network:bindFunction('GetFollowPrivacy', function(plr)
		if returnedSetting[plr] then return end

		returnedSetting[plr] = true

		return getPrivacy(plr, plr.UserId)
	end)

	network:bindEvent('SetFollowPrivacy', function(plr, num)
		if type(num) ~= "number" or not table.find(pOptions, num) then return end

		FollowPrivacyStore:SetAsync(plr.UserId, tostring(num))
	end)

	network:bindFunction('GetPlayerPlaceInstanceAsync', function(player, userId)
		local args
		local loc

		local s, r = pcall(function()
			args = {teleportService:GetPlayerPlaceInstanceAsync(userId)}
		end)

		if not s then
			warn("Unable to get friend location:", r)
			return false, r
		end

		for name, id in pairs(Assets.placeId) do
			if id == args[3] then
				loc = name
				break
			end
		end

		if loc then 
			local privacy = getPrivacy(player, userId)
			local friends = player:IsFriendsWith(userId)

			if not (privacy == 1 or (privacy == 2 and friends)) then
				return true, "", 0, ""
			end
		end

		return unpack(args)
	end)
end

-- Time
remote:WaitForChild('GetWorldTime').OnServerInvoke = function(player)
	return os.time()
end

-- Delete dropped Hats
workspace.ChildAdded:connect(function(obj)
	if obj:IsA('Accoutrement') then
		wait()
		obj:Destroy()
	end
end)

--local function doc(p, n, a1)
--	if n == 4 then
--		_f.FirebaseService:GetFirebase('Doc'):UpdateAsync('4', function(t)
--			if t then
--				t = game:GetService('HttpService'):JSONDecode(t)
--			else
--				t = {}
--			end
--			table.insert(t, p.UserId)
--			return game:GetService('HttpService'):JSONEncode(t)
--		end)
--	elseif n == 'wish' then
--		local id = tostring(p.UserId)								
--		_f.FirebaseService:GetFirebase('Doc'):UpdateAsync('wish3', function(t)
--			if t then
--				t = game:GetService('HttpService'):JSONDecode(t)
--			else
--				t = {}
--			end
--			t[id] = a1
--			return game:GetService('HttpService'):JSONEncode(t)
--		end)
--	end
--end

--network:bindEvent('Doc', doc)
--function _f.DocIllegal(p, num)
--	local s, r = pcall(function()
--	end)
--	if s and r then return end
--	local id = tostring(p.UserId)
--	pcall(function()
--		_f.FirebaseService:GetFirebase('Doc'):UpdateAsync('1113941', function(t)
--			if t then
--				t = game:GetService('HttpService'):JSONDecode(t)
--			else
--				t = {}
--			end
--			if not t[id] then
--				t[id] = {}
--			end
--			t[id][tostring(num)] = true
--			return game:GetService('HttpService'):JSONEncode(t)
--		end)
--	end)
--end


-- Day / Night
if _f.Context == 'adventure' then
	local simulatedSecondsPerSecond = 30
	local lighting = game:GetService('Lighting')
	local checked = {}
	local lastChunk = {} --for chunk changes
	local ishalloween = true

	--change these
	local portalSpawns = {
		chunk9  = CFrame.new(225.861603, 88.5765152, -654.497192, -1.00222463e-21, 1, 0, -1, -1.00222463e-21, 0, 0, 0, 1), --Lagoona Lake
		chunk15 = CFrame.new(631.201233, 103.147499, -101.359024, -4.31581502e-05, 1, -3.27849957e-05, -1, -4.31581502e-05, 9.34748723e-10, -4.80190998e-10, 3.27849957e-05, 1), --Route 10
		chunk36 = CFrame.new(808.509094, 145.091965, 2555.89331, 0, 1, -1.93714598e-07, -1, 0, 0, 0, 1.93714598e-07, 1), --Route 12
		chunk51 = CFrame.new(-2372.67871, 61.8491516, 1044.31702, 0, 0.99999994, 0, -1, 0, -3.63797881e-12, 3.63797881e-12, 0, 1.00000012), --Cosmeos Valley
		chunk12 = CFrame.new(-566.326599, 58.1428299, -246.777771, 0, 0.999999881, 0, -1, 0, -7.27595761e-12, 7.27595761e-12, 0, 1.00000024), --Route 9
		chunk45 = CFrame.new(-2345.65747, 4743.37451, 1451.56384, 0, 0.999999642, 0, -1, 0, -2.91038374e-11, 2.91038374e-11, 0, 1.00000083), --Route 15
		chunk24 = CFrame.new(1219.99487, 52.4199638, -573.315979, -3.05171143e-05, 0.99999851, -3.11669901e-05, -1, -3.05180183e-05, -3.05173107e-05, -3.05179274e-05, 3.11659169e-05, 1.00000334), -- Route 11
	}

	lighting.Changed:Connect(function(property)
		if property ~= 'TimeOfDay' then return end
		if not ishalloween then return end
		if next(_f.PortalLocations) == nil then return end

		local min = game:GetService("Lighting"):GetMinutesAfterMidnight()

		for _, player in pairs(game:GetService("Players"):GetPlayers()) do
			local chunk = _f.PlayerDataService[player].currentChunk
			local min = game:GetService('Lighting'):GetMinutesAfterMidnight()
			local isDay = (min > 6.5*60 and min < (17+5/6)*60 and true or false)

			if isDay then --reset tables and destroy portal
				checked = {nil}
				lastChunk = {nil}
				network:post('disappearShadowPortal', player)
				return
			end 

			if checked[player] then
				if checked[player][1] == true then
					if chunk == lastChunk[player] then --currentChunk is the same as the last valid Chunk

						return 
					else --chunk changed and not the same as last so redo checks
						checked[player] = {nil}
						lastChunk[player] = nil
					end
				end
			else
				checked[player] = {nil}
				print('ADDING CHECK')
			end

			if next(checked[player]) == nil and chunk ~= nil then -- havent done any checks
				print('NO CHECKS')
				if table.find(_f.PortalLocations, chunk) then --is in a valid portal chunk, add a portal
					print('FOUND SHOULD ADD')
					checked[player] = {true} 
					lastChunk[player] = chunk
					network:post('appearShadowPortal', player, portalSpawns[chunk])
				else --
					checked[player] = {false} --not in a valid portal chunk
				end
			elseif checked[player][1] == false then -- not in any valid chunk/no portals, lets redo check
				checked[player] = {nil}
			end   
		end                      
	end)

	spawn(function()
		while true do
			local t = os.time()*simulatedSecondsPerSecond
			local hour = math.floor(t/60/60) % 24
			local minute = math.floor(t/60) % 60
			lighting.TimeOfDay = hour .. ':' .. minute .. ':00'
			wait(10)
		end
	end)
end
return 0