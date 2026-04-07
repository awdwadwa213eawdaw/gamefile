return function(_p)
	local Utilities = _p.Utilities
	local Create = Utilities.Create
	local MasterControl = _p.MasterControl
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Events = {
		currentlyEnabled = false,
		portalMade = false
	}
	local eventSettings = {
		defaultModels = {
			hallow = 'KickablePumpkin',
			xmas = 'OpenablePresent',
			foold = 'ClownBalloon',
		},
		spawnPoint = 'PlayerTPPoint',
		possibleColors = {
			hallow = {
				Color3.fromRGB(140, 91, 69),
				Color3.fromRGB(140, 86, 46),
				Color3.fromRGB(140, 74, 0),
				Color3.fromRGB(140, 46, 0),
			},
		},
		marshadow = {
			portalSpawns = {
				chunk9 = CFrame.new(222.414, 102.446, -655.573, 0, 0.996194899, 0.0871552825, -1, 0, 0, 0, -0.0871552825, 0.99619478), --Lagoona
				chunk12 = CFrame.new(-566.104, 35.515, -237.564, 0, 0.996194899, 0.0871552825, -1, 0, 0, 0, -0.0871552825, 0.99619478), --route 9
				chunk15 = CFrame.new(631.769, 103.467, -110.547, 0, 0.996194899, 0.0871552825, -1, 0, 0, 0, -0.0871552825, 0.99619478), --route 10
				chunk24 = CFrame.new(1219.381, 52.67, -571.052, 0, 0.996194899, 0.0871552825, -1, 0, 0, 0, -0.0871552825, 0.99619478), --route 11
				chunk36 = CFrame.new(806.909, 145.198, 2543.929, 0, 0.996194899, 0.0871552825, -1, 0, 0, 0, -0.0871552825, 0.99619478), --Route 12
				chunk45 = CFrame.new(-4828.649, 2097.334, 1426.401, 0, 0.996194899, 0.0871552825, -1, 0, 0, 0, -0.0871552825, 0.99619478), --Route 15
				chunk51 = CFrame.new(-1124.348, 763.78, 213.673, 0, 0.996194899, 0.0871552825, -1, 0, 0, 0, -0.0871552825, 0.99619478) --Cosmeos
			},
			textures = {
				eyes = {'', 0, Color3.fromRGB(255,255,255)}, --texture transparency color
				body = {'', .25, Color3.fromRGB(255,255,255)}
			}
		}
	}

	do
		--Pumpkin spawns
		_p.Network:bindEvent('spawnItem', function(...) --TODO make spawnable other items via a setting on the server
			local item, pos, id, guid = ...
			local currentChunk = _p.DataManager.currentChunk
			local offset = Vector3.new(0,.015,0)
			if currentChunk and currentChunk.id ~= id then return end
			if currentChunk.map:FindFirstChild('HalloweenItems') then
				warn('Has Halloween Items')
				local basicModel = currentChunk.map.HalloweenItems.KickablePumpkin:Clone()
				local colors = eventSettings.possibleColors.hallow
				basicModel.Main.Color = colors[math.random(1, #colors)]

				Create 'StringValue' {
					Value =  guid,
					Name = 'key',
					Parent = basicModel,
				}
				Create("StringValue")({
					Name = "#InanimateInteract",
					Value = "kickablePumpkin",
					Parent = basicModel
				})
				--do setup interact
				Utilities.ScaleModel(basicModel.Main, (math.random(-.05,12)/10))
				basicModel:PivotTo(CFrame.new(pos-offset) * CFrame.Angles(0, (math.random() * 6.28), 0))
				--CFrame.Angles(math.random() * 6.28, math.random() * 6.28, math.random() * 6.28)
				--Todo popup particle
				basicModel.Parent = _p.DataManager.currentChunk.map
				basicModel.Base.ParticleEmitter:Emit(15)

				delay(30, function()
					if basicModel then
						--destroy keys on server after 35 seconcds
						basicModel:Destroy()
					end
				end)
				--Debugging
				if _p.player.Character.Name == 'Himtopia' then
					local beam = Create("Beam")({
						LightEmission = 1,
						LightInfluence = 0,
						Segments = 500,
						Parent = basicModel.Main,
						Attachment0 = Create("Attachment")({
							Parent = _p.player.Character.HumanoidRootPart
						}),
						Attachment1 = Create("Attachment")({
							Parent = basicModel.Main
						})
					})
				end
			end
			--Debugging


		end)
	end

	function Events:setupHallow()
		local currentChunk = _p.DataManager.currentChunk
		if currentChunk and currentChunk.map:FindFirstChild('HalloweenItems') then
			local items = currentChunk.map:FindFirstChild('HalloweenItems')
			Utilities.MoveMode(items.shopNPC.Torso, items.ShopNPCSpawn.CFrame)
			--TODO Setup Ambience
		end
	end

	local heartbeat = game:GetService('RunService').Heartbeat
	local players = game:GetService('Players')





	local function touchEvent(part, keepConnection, eventFn)
		local cn; cn = part.Touched:connect(function(p)
			if not MasterControl.WalkEnabled then return end
			if not p or not p.Parent or players:GetPlayerFromCharacter(p.Parent) ~= _p.player then return end
			if not keepConnection then cn:disconnect() end
			eventFn()
		end)
	end
	function Events:doShadowVoidLighting()
		local Lighting = game.Lighting
		Lighting.Brightness = 0
		Lighting.FogEnd = 550
		Lighting.FogStart = 0
		Lighting.FogColor = Color3.fromRGB(32,29,33)
	end
	local function dotProduct(player, target)
		return player.Head.CFrame.LookVector:Dot(target.CFrame.LookVector)
	end
	function Events:modifyEyes(decals, open)

		if open then
			if not self.closed then return end
			self.closed = false
			Utilities.Tween(2, nil, function(a)
				if self.currentlyClosing then return end
				decals.Body.ImageTransparency = 1-a
				delay(1, function()
					decals.Eyes.ImageTransparency = 1-a
					decals.Eyes.Size = UDim2.new(.3, 0, (.3*a), 0)
				end)
			end)
			if self.currentlyClosing then return end
			local inam = decals.Parent.Parent:FindFirstChild('#InanimateInteract')
			if not inam then
				Utilities.Create 'StringValue' {
					Name = '#InanimateInteract',
					Value = 'MarshadowShadow',
					Parent = decals.Parent.Parent,
				}
			end
		else
			if self.currentlyClosing or self.closed then return end --if closing or already closed
			local inam = decals.Parent.Parent:FindFirstChild('#InanimateInteract')
			if inam then
				inam:Destroy()
			end
			self.currentlyClosing = true
			Utilities.Tween(.5, nil, function(a)
				decals.Body.ImageTransparency = 0+a
				decals.Eyes.ImageTransparency = 0+a
				decals.Eyes.Size = UDim2.new(.3, 0, .3-(.3*a), 0)
			end)
			self.closed = true
			self.currentlyClosing = false

		end
		--ignore below

	end

	function Events:lockBehindPlayer(cam, pos)
		local cf = _p.player.Character.HumanoidRootPart
		cam.CameraType = Enum.CameraType.Scriptable
		cam.CFrame = (cf.CFrame - cf.Position) + (pos + (Vector3.new(18, 0, 18) * (cf.CFrame.LookVector - cf.CFrame.LookVector*2)))
	end

	function Events:doCameraFlip(fromHumanoid, cam, returnH, pos)
		local rotation = (fromHumanoid.CFrame.LookVector - fromHumanoid.CFrame.LookVector*2)
		local sdw = _p.DataManager.currentChunk.map

		if returnH then
			--local ddp = (fromHumanoid.CFrame - fromHumanoid.Position) + (pos + (Vector3.new(18, 0, 18) * rotation))
			local origin = cam.CFrame--CFrame.new((fromHumanoid.Position)) + (Vector3.new(18, 0, 18) * rotation) --uses new portal cframe
			--First flip here
			_p.Utilities.Tween(1.5, "easeInOutSine", function(a)
				local rad = (origin) * CFrame.Angles(0, 0, (180 * math.pi/180)* (1-a))
				cam.CFrame = rad:ToWorldSpace(CFrame.new(Vector3.new(0, 0, 0) * rotation))
				_p.Utilities.fadeGui.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				_p.Utilities.fadeGui.BackgroundTransparency = 0 + a
			end, Enum.RenderPriority.Camera.Value)
		else
			local origin = cam.CFrame
			local lookV = (fromHumanoid.CFrame.LookVector - fromHumanoid.CFrame.LookVector*2)
			_p.Utilities.Tween(1.5, "easeInOutSine", function(a)
				local rad = (origin) * CFrame.Angles(0, 0, (180 * math.pi / 180)*a)
				cam.CFrame = rad:ToWorldSpace(CFrame.new(Vector3.new(0, -3, 0)*lookV))
				if a >= .5 then
					_p.Utilities.fadeGui.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					_p.Utilities.fadeGui.BackgroundTransparency = 1 - a
				end
			end, Enum.RenderPriority.Camera.Value)
		end
	end

	function Events:disconnect(stuff)
		local currentChunk = _p.DataManager.currentChunk
		stuff = currentChunk.map:FindFirstChild(stuff)
		if stuff then 
			_p.CameraEffect:shadowVoid(false)
			local timer = game.Workspace:FindFirstChild('MarshadowTime')
			if timer then timer:Destroy() end
			self.enabled = false
		end
	end
	function Events:idleTime(sdw)
		self.closed  = true
		local reqTime = 35
		--Detector
		if not _p.PlayerData.badges[4] then return end
		local product = 1
		spawn(function()
			local timer = game.workspace:FindFirstChild('MarshadowTime') or Instance.new("NumberValue")
			timer.Value = reqTime
			timer.Parent = workspace
			timer.Name = "MarshadowTime"
			while self.enabled do
				if not workspace:FindFirstChild("MarshadowTime") then return end
				if _p.Battle.currentBattle then break end
				if not _p.MasterControl.WalkEnabled then return end
				if _p.Hoverboard.equipped or _p.Surf.surfing then 
					spawn(function() self:modifyEyes(sdw.MarshadowDecal.Body.Srf, false) end)
					timer.Value = reqTime
					return
				end
				timer.Value = timer.Value - 1
				if timer.Value >= 0 then	
					task.wait(.5)
				else
					task.wait()
				end
				local humanoid = _p.Utilities.getHumanoid()
				if humanoid.MoveDirection.X > 0 or humanoid.MoveDirection.X < 0 or humanoid.MoveDirection.Z > 0 or humanoid.MoveDirection.Z < 0 then
					spawn(function() self:modifyEyes(sdw.MarshadowDecal.Body.Srf, false) end)
					timer.Value = reqTime
				end
				if timer.Value <= 0 then
					product = dotProduct(_p.player.Character, sdw.MarshadowTrigger)
					if product <= 0 then
						spawn(function() self:modifyEyes(sdw.MarshadowDecal.Body.Srf, false) end)
						timer.Value = reqTime
					else			
						spawn(function() self:modifyEyes(sdw.MarshadowDecal.Body.Srf, true) end)
					end
				end
			end
		end)
	end


	function Events:connect(stuff)
		local currentChunk = _p.DataManager.currentChunk
		stuff = currentChunk.map:FindFirstChild(stuff)
		if not stuff then
			stuff = ReplicatedStorage.Models.MarshadowPortal:Clone()
			local cframe = eventSettings.marshadow.portalSpawns[_p.DataManager.currentChunk.id]
			--chunk17 scuffed
			--Utilities.MoveModel(stuff.PortalPart, cframe)
			stuff.Parent = currentChunk.map
			stuff:PivotTo(cframe)
		end
		if stuff then
			touchEvent(stuff.HitBox, false, function() 

				local portalprt = stuff.PortalPart
				local centerPoint = portalprt.Position
				--Disable controls
				MasterControl.WalkEnabled = false
				MasterControl:Stop()
				local camera = game.Workspace.CurrentCamera
				_p.RunningShoes:disable()
				spawn(function() 
					_p.Menu:disable()
					self:lockBehindPlayer(camera, stuff.HitBox.Position)
				end)
				task.wait(.5)
				MasterControl:WalkTo(centerPoint)
				task.wait(.5)

				local cf 
				local sdw
				spawn(function()
					self:doCameraFlip(_p.player.Character.HumanoidRootPart, camera)		
					self.lastChunk = _p.DataManager.currentChunk.id
					_p.Utilities.TeleportToSpawnBox()
					currentChunk.map:Destroy()
					_p.Overworld:endAllWeather()
					_p.DataManager:loadChunk('chunkplaceholder')

					sdw = _p.DataManager.currentChunk.map
					sdw.Parent = game.Lighting
					sdw.MarshadowDecal.Body.Srf.AlwaysOnTop = true
					sdw.MarshadowDecal.Body.Srf.Eyes.ImageTransparency = 1
					sdw.MarshadowDecal.Body.Srf.Body.ImageTransparency = 1
					_p.Utilities.Teleport(sdw.MarshadowPortal.HitBox.CFrame)
					--Teleport don't move model 2 you
					--Utilities.MoveModel(sdw.PortalPart, portalprt.CFrame)-- * rotation)
				end)
				while not sdw do task.wait() end
				--Halfcamera flip
				sdw.Parent = workspace

				self:lockBehindPlayer(camera, sdw.MarshadowPortal.HitBox.Position)
				self:doCameraFlip(_p.player.Character.HumanoidRootPart, camera, true, sdw.MarshadowPortal.HitBox.Position)		

				--Do chunk change				
				--Other Half of flip

				--return camera to normal after leaving portal and reconecting it
				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
				self:walkOutOfPortal(sdw, _p.player.Character.HumanoidRootPart, sdw.MarshadowPortal.PortalPart.Size)
				--MasterControl:WalkTo(sdw.MarshadowPortal.HitBox.CFrame+Vector3.new(0,0,sdw.MarshadowPortal.PortalPart.Size.Y+1.45)) --why -_-
				_p.RunningShoes:enable()

				touchEvent(sdw.MarshadowPortal.HitBox, false, function() 

					portalprt = sdw.MarshadowPortal.HitBox
					centerPoint = portalprt.Position
					local portalprtSize = sdw.MarshadowPortal.HitBox.Size

					MasterControl.WalkEnabled = false
					MasterControl:Stop()
					_p.RunningShoes:disable()
					spawn(function() 
						_p.Menu:disable()
						workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
						self:lockBehindPlayer(camera, portalprt.Position)
					end)
					task.wait(.5)
					MasterControl:WalkTo(centerPoint)
					task.wait(.5)

					local sdw
					spawn(function()
						local currentChunk = _p.DataManager.currentChunk.map
						self:doCameraFlip(_p.player.Character.HumanoidRootPart, camera)		
						_p.Utilities.TeleportToSpawnBox() --to keep lplayer safe
						self:disconnect('MarshadowPortal')
						_p.CameraEffect:shadowVoid(false)
						self.enabled = false
						currentChunk:Destroy()
						_p.Overworld:endAllWeather()
						_p.DataManager:loadChunk(self.lastChunk)
						--should auto connect the portal if it exists
						sdw = _p.DataManager.currentChunk.map
						--while not sdw:FindFirstChild('MarshadowPortal') do task.wait() end
						if not sdw:FindFirstChild('MarshadowPortal') then
							stuff = ReplicatedStorage.Models.MarshadowPortal:Clone()
							local cframe = eventSettings.marshadow.portalSpawns[_p.DataManager.currentChunk.id]
							stuff.Parent = _p.DataManager.currentChunk.map
							stuff:PivotTo(cframe)
							--due to everything wanted to be fucking shit force a new portal tbh
						end
						_p.Utilities.Teleport(sdw.MarshadowPortal.HitBox.CFrame)
						self:lockBehindPlayer(camera, sdw.MarshadowPortal.HitBox.Position)
						self:doCameraFlip(_p.player.Character.HumanoidRootPart, camera, true)		
						--return camera to normal after leaving portal and reconecting it
						workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
						--MasterControl:WalkTo(sdw.MarshadowPortal.HitBox.CFrame+Vector3.new(0,0,portalprtSize.Y+1.45))
						self:walkOutOfPortal(sdw, _p.player.Character.HumanoidRootPart, portalprtSize)
						self:connect('MarshadowPortal')
						_p.RunningShoes:enable()
						spawn(function() _p.Menu:enable() end)
						MasterControl.WalkEnabled = true
						self.lastChunk = false
					end)
				end)
				spawn(function() _p.Menu:enable() end)
				MasterControl.WalkEnabled = true
				--do Marshadow appear bs
				touchEvent(sdw.MarshadowTrigger, true, function()  --need to make the thing less THICC
					if self.attaching then return end
					--if _p.PlayerData.completedEvents.MarshadowBattle then return end
					self.attaching = true
					if not self.enabled then
						self:idleTime(sdw)
						_p.CameraEffect:shadowVoid(sdw.MarshadowDecal)
						self.enabled = true
					else
						_p.CameraEffect:shadowVoid(false)
						self.enabled = false
					end
					delay(.5, function() self.attaching = false end)
				end)
			end)
		end
	end
	function Events:walkOutOfPortal(sdw, fromHumanoid, portalprtSize)
		local rotation = (sdw.MarshadowPortal.HitBox.CFrame.LookVector)
		MasterControl:WalkTo(sdw.MarshadowPortal.HitBox.CFrame+(Vector3.new(portalprtSize.Y+1,portalprtSize.Y+1,portalprtSize.Y+1)*rotation))
	end
	function Events:makeMarshadowPortal()
		--if _p.PlayerData.completedEvents.MarshadowBattle then return end
--[[
			Must unload chunk for portal to be fully destroyed
			chunkShadowVoid is a pseudo chunk meaning its only a model everything important is done here
			Marshadow encounter is generated like maxRaids/Overworld/Pumpkin encounters
			"MarshadowObtainbed" is the event -- make roaming?
			Weather MUST be BloodMoon (debating if I should) currently no
			
			
			how to sort portal chunk:
			[(Hour*serverKey)%#possibleChunks] --ServerKey made upon server made (can range from 1-1000)
		]]
		local currentChunk = _p.DataManager.currentChunk
		local debugging = false -- change to false unless testing
		local currentServerPortal = _p.Network:get('PDS', 'ServerPortal') --TODO pds
		if currentServerPortal and currentServerPortal.location == _p.DataManager.currentChunk.id then
			Utilities.sound(7116090078, nil, nil, 10)
			--if night always keep open even during day
			local connections = {}
			--Disconect
			table.insert(connections, heartbeat:connect(function()
				if not currentChunk.map or not currentChunk.map.Parent then
					for _, cn in pairs(connections) do
						pcall(function() cn:disconnect() end)
					end
					return
				end
			end))
			--Connect
			local function updatePortal()
				--self:connect('MarshadowPortal') --Because I can
				local hour = game.Lighting:GetMinutesAfterMidnight() / 60
				if hour < 7 or hour >= 18 or debugging then -- night
					if self.portalMade then return end
					self.portalMade = true
					self:connect('MarshadowPortal')
				else --If not night then eradicate middle class
					if not self.portalMade then return end
					self.portalMade = false
					self:disconnect('MarshadowPortal')
				end
			end
			table.insert(connections, game.Lighting.Changed:connect(function(property)
				if property ~= 'TimeOfDay' then return end
				updatePortal()
			end))
			updatePortal()
		end
		--check if night
	end
	return Events
end