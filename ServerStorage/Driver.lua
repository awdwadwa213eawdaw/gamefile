--[[-------------------------------------------------------------------------+
| ========================== : Master Todo List : ========================== |
+----------------------------------------------------------------------------+

- Bag prop (purchasable, wearable) (Plugins.Menu.Options)
- Battle bugs (see ServerScriptService.BattleEngine)
- Misc Todos (see ServerStorage.Todo)

- Running shoes options (Plugins.RunningShoes)

! Fix Hippowdon's icon(s)

+-]]-------------------------------------------------------------------------+

print('[──────────────────────────────────────────────────────────────────────]')
print([[

					 _                               _       _____  __  ______           _       
					| |                             | |     |  _  |/ _| | ___ \         (_)      
					| |     ___  __ _  ___ _ __   __| |___  | | | | |_  | |_/ /___  _ __ _  __ _ 
					| |    / _ \/ _` |/ _ \ '_ \ / _` / __| | | | |  _| |    // _ \| '__| |/ _` |
					| |___|  __/ (_| |  __/ | | | (_| \__ \ \ \_/ / |   | |\ \ (_) | |  | | (_| |
					\_____/\___|\__, |\___|_| |_|\__,_|___/  \___/|_|   \_| \_\___/|_|  |_|\__,_|
 					            __/ |                                                           
 				 	          |___/                                                            
                                           
]])
print('[──────────────────────────────────────────────────────────────────────]')
print()
print('Brought to you by us to bring back a classic Roblox experience, Pokemon Brick Bronze!')
print('If you see any errors highlighted in red below this point, please report them in our Community Server!')
print()
print('[──────────────────────────────────────────────────────────────────────]')

local player = game:GetService('Players').LocalPlayer
local userId = player.UserId
local playerName = player.Name
--math.randomseed(os.time()+userId)
local traceback = debug.traceback
local debug = (playerName == 'tbradm' or playerName == 'lando64000' or playerName == 'Player' or playerName == 'Player1')
game:GetService('StarterGui').ResetPlayerGuiOnSpawn = false

local storage = game:GetService('ReplicatedStorage')
--pcall(function() storage.RequestFulfillment:ClearAllChildren() end)
local utilModule = script.Utilities
utilModule.Parent = script.Parent
local Utilities = require(utilModule)
local create = Utilities.Create
local write = Utilities.Write
local Audios = require(game.ReplicatedStorage.AudioManager) -- Adjust the path as needed

local rc4 = Utilities.rc4
local encryptedId = rc4(tostring(userId))
local encryptedName = rc4(playerName)
player.Changed:connect(function()
	if player.UserId ~= userId or player.Name ~= playerName 
		or not Utilities.rc4equal(encryptedId, rc4(tostring(player.UserId)))
		or not Utilities.rc4equal(encryptedName, rc4(player.Name)) then
		wait(); player:Kick()
	end
end)

local context = storage.Version:WaitForChild('GameContext').Value

local pluginsModule = script.Plugins
pluginsModule.Parent = script.Parent
local _p = {}
local network = {}
do
	local loc = storage
	local event = loc.POST
	local func  = loc.GET

	local boundEvents = {}
	local boundFuncs  = {}

	local auth

	function network:getAuthKey()
		auth = func:InvokeServer('_gen')
	end

	event.OnClientEvent:connect(function(fnId, ...)
		if not boundEvents[fnId] then return end
		boundEvents[fnId](...)
	end)

	func.OnClientInvoke = function(fnId, ...)
		if not boundFuncs[fnId] then return end
		return boundFuncs[fnId](...)
	end

	function network:bindEvent(name, callback)
		boundEvents[name] = callback
	end

	function network:bindFunction(name, callback)
		boundFuncs[name] = callback
	end

	function network:post(...)
		if not auth then return end
		event:FireServer(auth, ...)
	end

	function network:get(...)
		if not auth then return end
		return func:InvokeServer(auth, ...)
	end
	_p.Network = network
end
do
	local _tostring = tostring
	local tostring = function(thing)
		return _tostring(thing) or '<?>'
	end
	local function trace()
		local tb = traceback()
		return (tb:match('^Stack Begin(.+)Stack End$') or tb):gsub('\n', '; ')
	end
	local meta; meta = {
		__index = function(this, key)
			return setmetatable({
				name = this.name .. '.' .. tostring(key)
			}, meta)
		end,
		__newindex = function(this, key, value)
			_p.Network:post('Report', 'set ' .. this.name .. '.' .. tostring(key) .. ' to ' .. tostring(value), trace())
		end,
		__call = function(this, ...)
			local arglist = ''
			for _, arg in pairs({...}) do
				local s = tostring(arg)
				if s:len() > 100 then
					s = s:sub(1, 100)
				end
				arglist = arglist .. s
			end
			_p.Network:post('Report', 'called ' .. this.name .. '(' .. arglist .. ')', trace())
		end,
		__metatable = 'nil',
	}
	local __p = require(pluginsModule)
	__p.name = '_p'
	setmetatable(__p, meta)
end
_p.Utilities = Utilities

_p.Animation = require(storage.Animation)

_p.player = player
_p.gamemode = 'adventure'
_p.userId = userId
_p.storage = storage
_p.debug = debug
_p.traceback = traceback
_p.context = context

for k, v in pairs(require(script.Assets)) do
	_p[k] = v
end

local deb = true
local loadfirst = {"RoundedFrame", "MasterControl"}

local function load(sc)
	local pl 
	local succ, err = pcall(function()
		pl = require(sc)
	end)
	if not succ then 
		if deb then
			warn(sc.Name.." Failed to load")
			if err then
				warn("Error: "..err)
			end
		end
		return
	end
	if type(pl) == 'function' then
		pl = pl(_p)
	end
	_p[sc.Name] = pl
	sc.Name = "ModuleScript"
	sc:Destroy()
end

for i=1, #loadfirst do
	local sc = pluginsModule:FindFirstChild(loadfirst[i])
	if sc then
		load(sc)
	else
		if deb then
			warn(loadfirst[i].." Is not a valid module script!")
		end
	end
end

for _, module in pairs(pluginsModule:GetChildren()) do
	load(module)
end

local MasterControl = _p.MasterControl

do
	local rtick = tick()%1 -- my pseudo-seed (by join-tick offset)
	function _p.random(x, y)
		local r = (math.random()+rtick)%1
		if x and y then
			return math.floor(x + (y+1-x)*r)
		elseif x then
			return math.floor(1 + x*r)
		end
		return r
	end
	function _p.random2(x, y)
		local r = (math.random()-rtick+1)%1
		if x and y then
			return math.floor(x + (y+1-x)*r)
		elseif x then
			return math.floor(1 + x*r)
		end
		return r
	end
end
_p.Repel = {
	steps = 0,
	kind = 0,
	kinds = {
		{id = Utilities.rc4('repel'),      name = 'Repel',       steps = 100},
		{id = Utilities.rc4('superrepel'), name = 'Super Repel', steps = 200},
		{id = Utilities.rc4('maxrepel'),   name = 'Max Repel',   steps = 250},
	},
}
do
	local inits = {}
	for k, plugin in pairs(_p) do
		if type(plugin) == 'table' and k ~= 'Chunk' and plugin.init then
			table.insert(inits, plugin)
		end
	end
	table.sort(inits, function(a, b) return (a.initPriority or 0) > (b.initPriority or 0) end)
	for _, plugin in pairs(inits) do
		plugin:init()
	end
end
pluginsModule:Destroy()
utilModule:Destroy()
pluginsModule = nil
utilModule = nil

Utilities.setupDestroyWatch()
MasterControl:init()
_p.Network:getAuthKey() -- potential to hang

Utilities:layerGuis()
local dataManager = _p.DataManager


local loaded
local playSolo = false
local forceContinue
pcall(function()

end)
if not playSolo then
	loaded = create 'ObjectValue' {
		Name = 'Waiting',
		Parent = game:GetService('ReplicatedFirst'),
	}
	repeat wait() until loaded.Name ~= 'Waiting'
	forceContinue = (loaded.Name == 'ForceContinue')
end

do
	local function onLoad()
		if context == 'Battle' then dataManager:preload(453664439, 9987215454, 9987208006) end
		-- preload sounds
		dataManager:preload(Audios.NormalEncounterTheme, Audios.NormalEncounterThemeLoop, Audios.NormalDamage,Audios.SuperEffective,Audios.NotEffective, Audios.LevelUp, Audios.Shiny, Audios.EvolutionTheme1,Audios.EvolutionTheme2,Audios.EvolutionTheme3, Audios.ObtainedItem, -- battle music [2], hit sounds [3], level-up, shiny sparkle sound, evolution[3], obtained item
			Audios.Pokeball,Audios.PokeballCapture,Audios.Caught,Audios.Retrieve,Audios.Rock, Audios.PcOpen,Audios.PcClose, Audios.ObtainedItem, Audios.ObtainedBadge, Audios.obtainedKeyItem, Audios.MegaEvo, -- pokeball[5], pc[2], obtained item, obtained badge, obtained key item, mega evolution
			Audios.Cry1, Audios.Cry2, Audios.Cry3, Audios.Cry4,--// Cries 1-4
			Audios.Cry5, Audios.Cry6, Audios.Cry7, Audios.Cry8, Audios.Cry9,--// Cries 5-9
			Audios.Cry10, Audios.Cry11, Audios.Cry12, Audios.Cry13, Audios.Cry14,--// Cries 10-14
			Audios.Cry15, Audios.Cry16, Audios.Cry17, Audios.Cry18) --// Cries 15-17				-- preload images
		dataManager:preload(287358263,287358312, 287358312, 287322897,286854973, 287129499, 285485468, 282175706, 317129150, 317480860, 478035099,478035064) -- abilities [2], boost, hit particles [2], battle message box, pokeball icon, summary backdrop, black fade circle, mega particles [2]

		dataManager.ignoreRegionChangeFlag = true
	end

	if (loaded and loaded.Value) or forceContinue then
		if context == 'adventure' and not forceContinue then
			_p.Overworld:toggleWeather(true, nil, true)
			_p.Intro:perform(loaded.Value, onLoad)
		else
			onLoad()
			task.wait(2) -- (allows data cache to initialize)
			local s, etc = _p.Network:get('PDS', 'continueGame', 'adventure')
			if s then
				_p.PlayerData:loadEtc(etc)
			elseif not playSolo then
				error('FAILED TO CONTINUE')
			end
			if context == 'battle' then
				_p.DataManager:loadChunk('colosseum')
				Utilities.Teleport(CFrame.new(-84.137, 1.15, -222.23))
				_p.PVP:enable()
				create 'ImageLabel' { -- preload vs icon
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://11226844934',
					Size = UDim2.new(0.0, 2, 0.0, 2),
					Position = UDim2.new(1.0, -10, 0.0, -15),
					Parent = Utilities.backGui,
				}
			elseif context == 'trade' then
				_p.DataManager:loadChunk('resort')
				Utilities.Teleport(CFrame.new(-77.01, 4.555, 31.912))
				_p.TradeMatching:enableRequestMenu()
			end
			--			_p.PlayerData:ch()
			local gui = loaded.Value
			if gui then
				local fader = gui:FindFirstChild("Frame")
				
				if fader then
					fader:ClearAllChildren()
					Utilities.Tween(.5, nil, function(a)
						fader.BackgroundTransparency = a
					end)
					gui:Destroy()
				end
			end
		end
	else
		onLoad()
	end
	
	pcall(function() loaded:Destroy() end)

	local sg = game:GetService('StarterGui')
	if not Utilities.isPhone() then _p.PlayerList:enable() end
	sg:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)

end

if debug or playerName == 'Our_Hero' then--or game:GetService('RunService'):IsServer() then
	local testFn
	player:GetMouse().KeyDown:connect(function(k)
		if k == 'p' then
			--_p.Network:get('PDS', 'pdc')
			_p.Menu.pc:bootUp()
		end
		if not debug then return end
		if k == 'b' then
			if _p.DataManager.currentChunk.id == 'chunkGSM' then
				_p.Overworld.Weather.NorthernLights:returnHome()
			else
				_p.Overworld.Weather.NorthernLights:transToChunk({
					name='Unknown Location',
					variant = 'Warp',
					chunk='chunkhallow',--'chunkGSM',
					cframe=CFrame.new(747.485474, 9.67688179, 3761.1333, 0.906306565, 0, -0.422618896, 0, 0.999999046, 0, 0.422618449, 0, 0.906307518)
					--CFrame.new(806.475525, 15.2346153, 3917.80933, 0.906307697, 0, -0.422618538, 0, 1, 0, 0.422618538, 0, 0.906307697)
				}, _p.DataManager.currentChunk.id)
			end
		elseif k == 'l' then
			if _p.DataManager.currentChunk.id == 'chunkcress' then
				_p.Overworld.Weather.NorthernLights:returnHome()
			else
				_p.Overworld.Weather.NorthernLights:transToChunk({
					name='Between Dreams',
					--variant = 'Warp',
					chunk='chunkcress',
					cframe=CFrame.new(-33, 10.0000048, 5, 0, 0, 1, 0, 1, 0, -1, 0, 0)
				}, _p.DataManager.currentChunk.id, true)
			end
		elseif k == 't' then
			local forecast = _p.Network:get('PDS', 'weatherUpdate')
			for _, v in pairs(forecast) do
				warn(v[2]..': '..v[1])
			end
			_p.Overworld:endAllWeather()
			_p.Overworld:startRandomWeather()--@ AMOOGUS
			--if _p.Weather.Meteor.enabled then
			--	_p.DataManager:unlockClockTime()
			--	_p.Weather.Meteor:Disable()
			--else
			--	_p.DataManager:lockClockTime(0)
			--	_p.Weather.Meteor:Enable(math.random(1, 4))
			--end
			--if _p.Weather.isMeteor then
			--	_p.Weather:StartWeather('meteor')
			--else
			--	_p.Weather:EndWeather('meteor')
			--end
		end
	end)
end--]]

do -- Shutdown Announcer
	--	local e = storage.Remote.ShuttingDownSoon
	local gui
	local function notifyShutdown(timeRemaining, reason)
		if gui then
			gui:Destroy()
		end
		if not timeRemaining then return end
		gui = _p.RoundedFrame:new {
			CornerRadius = Utilities.gui.AbsoluteSize.Y*.033,
			BackgroundColor3 = Color3.new(.3, .3, .3),
			Size = UDim2.new(.4, 0, .4, 0),
			ZIndex = 9, Parent = Utilities.frontGui,
		}
		local f1 = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.12, 0),
			Position = UDim2.new(0.5, 0, 0.0625, 0),
			ZIndex = 10, Parent = gui.gui,
		}
		write 'Shutting Down...' { Frame = f1, Scaled = true, Color = Color3.new(.8, .2, .2), }
		local f2 = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.12, 0),
			Position = UDim2.new(0.5, 0, 0.2875, 0),
			ZIndex = 10, Parent = gui.gui,
		}
		write(reason) { Frame = f2, Scaled = true, }
		local f3 = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.08, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			ZIndex = 10, Parent = gui.gui,
		}
		write 'Please SAVE as soon as possible!' { Frame = f3, Scaled = true, }
		local timer = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.28, 0),
			Position = UDim2.new(0.5, 0, 0.6625, 0),
			ZIndex = 10, Parent = gui.gui,
		}
		local countdown = math.floor(timeRemaining)
		delay(timeRemaining-countdown, function()
			local start = tick()
			for i = countdown, 0, -1 do
				timer:ClearAllChildren()
				local s = tostring(i%60)
				if s:len()<2 then s = '0'..s end
				write(math.floor(i/60)..':'..s) { Frame = timer, Scaled = true, }
				wait((countdown-i+1)-(tick()-start))
			end
		end)
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			gui.Position = UDim2.new(.3, 0, -0.6+0.9*a, 0)
		end)
		wait(5)
		local yOffset = context=='adventure' and .5 or .35
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			local s = 1-0.5*a
			gui.Size = UDim2.new(.4*s, 0, .4*s, 0)
			gui.Position = UDim2.new(0.3+0.5*a, 0, 0.3+yOffset*a, 0)
		end)
		local frame = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(.2, 0, .2, 0),
			Position = UDim2.new(.8, 0, 0.3+yOffset, 0),
			Parent = Utilities.frontGui,
		}
		f1.Parent = frame
		f2.Parent = frame
		f3.Parent = frame
		timer.Parent = frame
		gui:destroy()
		gui = frame
	end
	network:bindEvent('ShutdownEvent', notifyShutdown)
	network:post('ShutdownEvent')
end

MasterControl.WalkEnabled = true
MasterControl:Hidden(false)

spawn(function() _p.Menu:enable() end)
_p.NPCChat:enable()

do -- system messages
	local sg = game:GetService('StarterGui')
	local blue = Color3.fromRGB(105, 190, 250)
	network:bindEvent('SystemChat', function(msg, color)
		if not msg then return end
		if not color then color = blue end
		if color == blue and _p.Menu and _p.Menu.options and not _p.Menu.options.cHints then return end
		
		pcall(function()
			sg:SetCore('ChatMakeSystemMessage', {
				Text = msg,
				Color = color,
				--				Font = Enum.Font.Code,
				FontSize = Enum.FontSize.Size24
			})
		end)
	end)
	network:bindEvent("bigCrash", function(uno, dos, tres)
		spawn(function()
			_p.Overworld.Weather.Meteor:bigCrash(uno, dos, tres)
		end)
	end)
	network:bindEvent("smallCrash", function(uno, dos, tres, quart)
		spawn(function()
			--	local RNG = Random.new()
			--local items = _p.DataManager.currentChunk.map.CrashSpots:GetChildren()
			--local Part = items[math.random(1, #items)]		
			--local Position = Part.Position
			--local Size = Part.Size

			--local MinX , MaxX= Position.X - Size.X/2, Position.X + Size.X/2
			--local MinY, MaxY = Position.Y - Size.Y/2, Position.Y + Size.Y/2
			--local MinZ, MaxZ = Position.Z - Size.Z/2, Position.Z + Size.Z/2
			--local X, Y, Z = RNG:NextNumber(MinX, MaxX), RNG:NextNumber(MinY, MaxY), RNG:NextNumber(MinZ, MaxZ) 

			--local RanPosition = Vector3.new(X, Y, Z)
			_p.Overworld.Weather.Meteor:smallCrash(uno, dos, tres, quart)
		end)
	end)
	local function weatherChange(info: {any})
		if info.StartNotif then
			_p.Overworld.Weather:Notification(info.StartNotif)
		end

		local oldWeather = info.End and info.End[2] or nil
		local newWeather = info.Start and info.Start[2] or nil

		if oldWeather and newWeather and oldWeather == newWeather then
			return
		end

		if oldWeather and oldWeather ~= "" then
			_p.Overworld:endWeather(oldWeather, true)
		end

		task.wait(0.05)

		if newWeather and newWeather ~= "" then
			_p.Overworld:startWeather(newWeather)
		else
			_p.Overworld.currentWeather = ""
		end
	end

	network:bindEvent("weatherChange", weatherChange)
end

spawn(function() _p.WalkEvents:beginLoop() end)

return 0