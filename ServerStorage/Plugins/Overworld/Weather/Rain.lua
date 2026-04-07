return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local stepped = game:GetService("RunService").RenderStepped
	local rain = {
		reverbOn = false,
		newRainEnabled = false,
		lightningEnabled = false,
		IndoorReverb = create("SoundGroup")({
			Archivable = false,
			Volume = 1,
			Parent = game:GetService("SoundService"),
			create("EqualizerSoundEffect")({
				HighGain = -10,
				MidGain = -5,
				LowGain = 1,
				Priority = 2,
				Enabled = false
			}),
			create("ReverbSoundEffect")({
				DecayTime = 1.5,
				Density = 1,
				Diffusion = 1,
				DryLevel = -6,
				WetLevel = 0.4,
				Priority = 1,
				Enabled = false
			})
		})
	}

	local TweenService = game:GetService("TweenService")
	local Lighting = game:GetService("Lighting")

	local DEFAULT_LIGHTING_BRIGHTNESS = Lighting.Brightness
	local DEFAULT_LIGHTING_EXPOSURE_COMPENSATION = Lighting.ExposureCompensation
	local DEFAULT_LIGHTING_OUTDOOR_AMBIENT = Lighting.OutdoorAmbient
	local DEFAULT_LIGHTING_FOG_END = Lighting.FogEnd

	local function getLightingBrightness()
		return (_p.Constants and _p.Constants.LIGHTING_BRIGHTNESS) or DEFAULT_LIGHTING_BRIGHTNESS
	end

	local function getLightingExposure()
		return (_p.Constants and _p.Constants.LIGHTING_EXPOSURE_COMPENSATION) or DEFAULT_LIGHTING_EXPOSURE_COMPENSATION
	end

	local function getLightingOutdoorAmbient()
		return (_p.Constants and _p.Constants.LIGHTING_OUTDOOR_AMBIENT) or DEFAULT_LIGHTING_OUTDOOR_AMBIENT
	end

	local function makeSound(id, vol)
		if not vol then vol = .8 end
		Utilities.sound(id, vol, nil, 10)
	end

	function rain:Tween(p3, p4, p5)
		local timin = nil
		local numValue = Instance.new("NumberValue")
		numValue.Value = 0
		local v14 = TweenService:Create(numValue, p3, {
			Value = 1
		})
		timin = v14.TweenInfo.Time
		local v15 = numValue:GetPropertyChangedSignal("Value")
		local u2 = tick() + v14.TweenInfo.DelayTime
		local u3 = numValue
		v15:Connect(function()
			if p5(u3.Value, tick() - u2) ~= false then
				return
			end
			u3:Destroy()
			v14:Cancel()
		end)
		v14:Play()
		if not p4 then
			v14.Completed:Connect(function()
				p5(1, timin)
				if u3 then
					u3:Destroy()
					u3 = nil
				end
			end)
			return v14
		end
		v14.Completed:Wait()
		p5(1, timin)
		if u3 then
			u3:Destroy()
			u3 = nil
		end
	end

	function rain:lerp(p26, p27, p28)
		return p26 + (p27 - p26) * p28
	end

	function rain:BeamLightning(Origin, EndPoint, Amount, Range, Color, Width, timing)
		local magnitude = math.random(1, 100)
		local rngSeed = Random.new(magnitude)

		timing = timing and 0.3
		local tweenData = TweenInfo.new(timing, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
		local amount = {}

		for v102 = 0, Amount do
			local lerpPos = self:lerp(Origin, EndPoint, v102 / Amount)
			local Radi = Range * math.clamp(1 - v102 / Amount, 0, 0.6)
			local VectorX = rngSeed:NextInteger(-Radi, Radi)
			local VectorY = rngSeed:NextInteger(-Radi, Radi)
			local Attachment = Instance.new("Attachment")
			local newPos = Vector3.new(VectorX, rngSeed:NextInteger(-Radi, Radi), VectorY)

			if v102 == 0 then
				newPos = Vector3.new()
			elseif v102 == Amount then
				newPos = Vector3.new(VectorX, 0, VectorY)
			end

			Attachment.Position = lerpPos + newPos
			Attachment.Parent = workspace.Terrain
			table.insert(amount, Attachment)

			if amount[#amount - 1] then
				local Beam = Instance.new("Beam")
				Beam.Attachment0 = amount[#amount - 1]
				Beam.Attachment1 = Attachment
				Beam.LightEmission = 1
				Beam.LightInfluence = 0
				Beam.Transparency = NumberSequence.new(0)
				Beam.Color = ColorSequence.new(Color)
				Beam.Parent = workspace.Terrain
				Beam.Width0 = Width
				Beam.Width1 = Width

				self:Tween(tweenData, false, function(p115, p116)
					Beam.Transparency = NumberSequence.new(p115)
					Beam.Width0 = Width - 0.99 * Width * p115
					Beam.Width1 = Width - 0.99 * Width * p115
				end)

				delay(timing, function()
					if Beam then
						Beam:Destroy()
					end
				end)
			end
		end

		task.spawn(function()
			if _p.Battle.currentBattle or not _p.Menu.options.weatherEnabled then return end
			local cam = workspace.CurrentCamera
			_p.CameraShaker:BeginEarthquake(function(cf)
				cam.CFrame = cam.CFrame * cf
			end, 0.2)
			local sounds = {4961088919, 821439273, 2036960141, 6767188184}
			makeSound(sounds[math.random(1, #sounds)])
			wait(.15)
			_p.CameraShaker:EndEarthquake(0.22)
		end)

		delay(timing * Amount, function()
			for _, v111 in pairs(amount) do
				if v111 then
					v111:Destroy()
				end
			end
		end)
	end

	function rain:start(frame, imageId, ar, velocity)
		ar = ar or 1.3254786450662739
		if not velocity then
			local angle = math.rad(105)
			velocity = Vector2.new(math.cos(angle), math.sin(angle)) * 2
		end

		local img = create("ImageLabel")({
			BackgroundTransparency = 1,
			ImageTransparency = 0.1,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(ar, 0, 1, 0)
		})

		if imageId then
			if type(imageId) == "number" then
				imageId = "rbxassetid://" .. imageId
			end
			img.Image = imageId
		else
			img.Image = "rbxassetid://6607874247"
			img.ImageColor3 = Color3.new(0.6, 0.7, 1)
		end

		local imgs = {
			img:Clone(),
			img:Clone(),
			img:Clone(),
			img:Clone()
		}

		local pos = Vector2.new(0.5, 0.5)
		local lastTick = tick()
		imgs[1].Parent = frame
		imgs[2].Parent = frame
		local raining = true

		Utilities.fastSpawn(function()
			while raining do
				local now = tick()
				local dt = now - lastTick
				lastTick = now
				local posX = pos.X + dt * frame.AbsoluteSize.Y * velocity.X / frame.AbsoluteSize.X
				local sx = frame.AbsoluteSize.Y * ar / frame.AbsoluteSize.X

				while posX < 0 do
					posX = posX + sx
				end

				pos = Vector2.new(posX, (pos.Y + velocity.Y * dt) % 1)
				imgs[1].Position = UDim2.new(posX, 0, pos.Y - 1, 0)
				imgs[2].Position = UDim2.new(posX, 0, pos.Y, 0)

				local i = 3
				local x = posX

				while x > 0 do
					x = x - sx
					if not imgs[i] then
						imgs[i] = img:Clone()
						imgs[i + 1] = img:Clone()
					end
					imgs[i].Position = UDim2.new(x, 0, pos.Y - 1, 0)
					imgs[i].Parent = frame
					imgs[i + 1].Position = UDim2.new(x, 0, pos.Y, 0)
					imgs[i + 1].Parent = frame
					i = i + 2
				end

				x = pos.X + sx
				while x < 1 do
					if not imgs[i] then
						imgs[i] = img:Clone()
						imgs[i + 1] = img:Clone()
					end
					imgs[i].Position = UDim2.new(x, 0, pos.Y - 1, 0)
					imgs[i].Parent = frame
					imgs[i + 1].Position = UDim2.new(x, 0, pos.Y, 0)
					imgs[i + 1].Parent = frame
					i = i + 2
					x = x + sx
				end

				for j = i, #imgs do
					imgs[j].Parent = nil
				end

				stepped:Wait()
			end
		end)

		local obj = {}
		function obj:setTransparency(t)
			img.ImageTransparency = t
			for _, img in pairs(imgs) do
				img.ImageTransparency = t
			end
		end
		function obj:setColor(c)
			img.ImageColor3 = c
			for _, img in pairs(imgs) do
				img.ImageColor3 = c
			end
		end
		function obj:destroy()
			raining = false
			for _, i in pairs(imgs) do
				i:Destroy()
			end
		end
		return obj
	end

	function rain:enableNewRain(Scene, tweenTime)
		if self.newRainEnabled then
			return
		end
		self.newRainEnabled = true
		rain.newRainEnabled = true

		local thisThread = {}
		self.rainThread = thisThread
		local lighting = game:GetService("Lighting")
		local sky = lighting:FindFirstChildOfClass("Sky")
		if sky then
			sky.CelestialBodiesShown = false
			sky.StarCount = 0
		end

		self.Atmosphere = create("Atmosphere")({
			Density = 0,
			Offset = 0,
			Color = Color3.fromRGB(32, 32, 48),
			Decay = Color3.fromRGB(32, 32, 48),
			Glare = 0,
			Haze = 0,
			Parent = lighting
		})

		if self.lightningEnabled then
			_p.DataManager:lockClockTime(6.2)
			lighting.Brightness = 1
			lighting.ExposureCompensation = 0
			lighting.FogColor = Color3.fromRGB(0, 143, 168)
			lighting.OutdoorAmbient = Color3.fromRGB(56, 80, 169)
			lighting.FogEnd = 358
			self.Atmosphere.Density = .251
			self.Atmosphere.Haze = 2.11
		else
			self.blueFrame = create("Frame")({
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				BackgroundColor3 = Color3.fromRGB(14, 15, 32),
				Size = UDim2.new(1, 0, 1, 60),
				Position = UDim2.new(0, 0, 0, -60),
				Parent = Utilities.backGui
			})

			if tweenTime then
				Utilities.spTween(lighting, "Brightness", 0, tweenTime, nil, nil, function()
					_p.DataManager:lockClockTime(6.2)
				end)
				Utilities.spTween(lighting, "ExposureCompensation", 0, tweenTime)
				Utilities.spTween(lighting, "OutdoorAmbient", Color3.fromRGB(60, 74, 129), tweenTime)
				Utilities.spTween(self.Atmosphere, "Density", 0.506, tweenTime)
				Utilities.spTween(self.Atmosphere, "Haze", 2.21, tweenTime)
				Utilities.spTween(self.blueFrame, "BackgroundTransparency", 0.8, tweenTime)
			else
				_p.DataManager:lockClockTime(6.2)
				lighting.Brightness = 0
				lighting.ExposureCompensation = 0
				lighting.FogColor = Color3.fromRGB(25, 23, 62)
				lighting.OutdoorAmbient = Color3.fromRGB(106, 99, 169)
				lighting.FogEnd = 250
				self.Atmosphere.Density = .506
				self.Atmosphere.Haze = 2.21
			end
		end

		spawn(function()
			local player = _p.player
			local rainParts = {}
			local nRainParts = 0
			local random = math.random
			local twoPi = math.pi * 2
			local sin, cos = math.sin, math.cos
			local cf = CFrame.new
			local v3 = Vector3.new
			local down = Vector3.new(0, -150, 0)
			local splashOffset = Vector3.new(0, 0.6, 0)
			local xzPlane = Vector3.new(1, 0, 1)
			local DataManager = _p.DataManager

			local baseDrop = create("Part")({
				Anchored = true,
				CanCollide = false,
				CanTouch = false,
				CanQuery = true,
				Material = Enum.Material.SmoothPlastic,
				Color = Color3.fromRGB(175, 221, 255),
				Transparency = 1,
				Size = Vector3.new(0.15, 2, 0.15),
				TopSurface = Enum.SurfaceType.Smooth,
				BottomSurface = Enum.SurfaceType.Smooth,
				create("Decal")({
					Texture = "rbxassetid://2878049753",
					Face = Enum.NormalId.Back
				})
			})

			local splashLocation = create("Attachment")({
				Parent = workspace.Terrain
			})

			local splashEmitter = create("ParticleEmitter")({
				Color = ColorSequence.new(Color3.fromRGB(205, 232, 255), Color3.fromRGB(124, 139, 157)),
				LightEmission = 0,
				LightInfluence = 0,
				Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0, 0),
					NumberSequenceKeypoint.new(0.56, 2.2, 0.6),
					NumberSequenceKeypoint.new(1, 0, 0)
				}),
				Texture = "rbxassetid://1890069725",
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0, 0),
					NumberSequenceKeypoint.new(0.06, 0.44, 0.09),
					NumberSequenceKeypoint.new(0.1, 0.33, 0.19),
					NumberSequenceKeypoint.new(0.15, 0.36, 0.17),
					NumberSequenceKeypoint.new(0.2, 0.34, 0.15),
					NumberSequenceKeypoint.new(0.33, 0.41, 0.13),
					NumberSequenceKeypoint.new(0.5, 0.44, 0.09),
					NumberSequenceKeypoint.new(0.68, 0.87, 0.04),
					NumberSequenceKeypoint.new(0.9, 0.75, 0),
					NumberSequenceKeypoint.new(1, 1, 0)
				}),
				Acceleration = Vector3.new(0, 0, 0),
				LockedToPart = false,
				Lifetime = NumberRange.new(0.2),
				Rate = 0,
				Enabled = false,
				EmissionDirection = Enum.NormalId.Top,
				Speed = NumberRange.new(1),
				RotSpeed = NumberRange.new(-170),
				Parent = splashLocation
			})

			local camera = workspace.CurrentCamera

			while self.rainThread == thisThread do
				local now = tick()
				local camPos = camera.CFrame.Position

				for i = nRainParts, 1, -1 do
					local rain = rainParts[i]
					local l = (now - rain[3]) * 100
					if l >= rain[4] then
						rainParts[i] = rainParts[nRainParts]
						nRainParts = nRainParts - 1
						rain[1]:Destroy()
						if (camPos - rain[5]).Magnitude < 40 then
							splashLocation.Position = rain[5]
							splashEmitter:Emit(1)
						end
					else
						local pos = rain[2] + v3(0, -0.7 - l, 0)
						rain[1].CFrame = cf(pos, pos + (pos - camPos) * xzPlane)
					end
				end

				if nRainParts < 200 then
					local chunkModel = DataManager.currentChunk and DataManager.currentChunk.map
					if chunkModel then
						local rainFocus = self.rainFocus
						if not self.rainFocus then
							if self.useCameraPosition then
								rainFocus = camPos
							else
								pcall(function()
									local head = player.Character.Head
									rainFocus = head.Position + 1.5 * head.Velocity
								end)
							end
						end
						if rainFocus then
							for i = 1, 4 do
								local r = random() ^ 1.2 * 120 + 4
								local t = random() * twoPi
								local p = rainFocus + v3(r * sin(t), 100, r * cos(t))
								local ray = Ray.new(p, down)
								local hit, pos = workspace:FindPartOnRayWithWhitelist(ray, {chunkModel, Scene}, true)
								if hit then
									if math.random(1, 1850) == 69 and self.lightningEnabled then
										local Color = _p.Overworld.Weather.possibleThunderColors[math.random(1, #_p.Overworld.Weather.possibleThunderColors)]
										self:BeamLightning(p, pos, 4, 6, Color, math.random(4, 12), .45)
									else
										local drop = baseDrop:Clone()
										drop.Parent = camera
										drop.CFrame = cf(p)
										nRainParts = nRainParts + 1
										rainParts[nRainParts] = {
											drop,
											p,
											now,
											p.Y - pos.Y,
											pos + splashOffset
										}
									end
								end
							end
						end
					end
				end

				stepped:Wait()
			end

			for i = 1, nRainParts do
				rainParts[i][1]:Destroy()
			end
			rainParts = nil
		end)
	end

	do
		local indoorReverb = rain.IndoorReverb
		local eq = indoorReverb.EqualizerSoundEffect
		local rv = indoorReverb.ReverbSoundEffect
		local log10 = math.log10

		local function interpolateDecibel(from, to)
			local fromPower = 10 ^ (from / 10)
			local toPower = 10 ^ (to / 10)
			local difPower = toPower - fromPower
			return function(alpha)
				return 10 * log10(fromPower + difPower * alpha)
			end
		end

		local fadeThread

		function rain:fadeIndoorReverbOn(duration)
			if self.reverbOn then
				return
			end
			self.reverbOn = true
			if duration == 0 then
				fadeThread = nil
				eq.HighGain = -10
				eq.MidGain = -5
				eq.LowGain = 1
				eq.Enabled = true
				rv.DryLevel = -6
				rv.WetLevel = 0.4
				rv.Enabled = true
				return
			end
			local thisThread = {}
			fadeThread = thisThread
			if not eq.Enabled then
				eq.HighGain = 0
				eq.MidGain = 0
				eq.LowGain = 0
				eq.Enabled = true
			end
			if not rv.Enabled then
				rv.DryLevel = 0
				rv.WetLevel = -30
				rv.Enabled = true
			end
			local eqHighLerp = interpolateDecibel(eq.HighGain, -10)
			local eqMidLerp = interpolateDecibel(eq.MidGain, -5)
			local eqLowLerp = interpolateDecibel(eq.LowGain, 1)
			local reverbDryLerp = interpolateDecibel(rv.DryLevel, -6)
			local reverbWetLerp = interpolateDecibel(rv.WetLevel, 0.4)
			Utilities.Tween(duration, nil, function(a)
				if fadeThread ~= thisThread then
					return false
				end
				eq.HighGain = eqHighLerp(a)
				eq.MidGain = eqMidLerp(a)
				eq.LowGain = eqLowLerp(a)
				rv.DryLevel = reverbDryLerp(a)
				rv.WetLevel = reverbWetLerp(a)
			end)
		end

		function rain:fadeIndoorReverbOff(duration)
			if not self.reverbOn then
				return
			end
			self.reverbOn = false
			if duration == 0 then
				fadeThread = nil
				eq.Enabled = false
				rv.Enabled = false
				return
			end
			local thisThread = {}
			fadeThread = thisThread
			local eqHighLerp = interpolateDecibel(eq.HighGain, 0)
			local eqMidLerp = interpolateDecibel(eq.MidGain, 0)
			local eqLowLerp = interpolateDecibel(eq.LowGain, 0)
			local reverbDryLerp = interpolateDecibel(rv.DryLevel, 0)
			local reverbWetLerp = interpolateDecibel(rv.WetLevel, -30)
			Utilities.Tween(duration, nil, function(a)
				if fadeThread ~= thisThread then
					return false
				end
				eq.HighGain = eqHighLerp(a)
				eq.MidGain = eqMidLerp(a)
				eq.LowGain = eqLowLerp(a)
				rv.DryLevel = reverbDryLerp(a)
				rv.WetLevel = reverbWetLerp(a)
			end)
			if fadeThread == thisThread then
				eq.Enabled = false
				rv.Enabled = false
			end
		end
	end

	function rain:setupBuildingReverb()
		local chunk = _p.DataManager.currentChunk
		if not chunk then return end

		chunk:registerEnterDoorEvent("rainReverbEnable", function(doorId, state)
			spawn(function()
				while state[1] < 4 do
					if state[1] == -1 then
						return
					end
					wait()
				end
				self:fadeIndoorReverbOn(1.5)
				while state[1] < 6 do
					if state[1] == -1 then
						return
					end
					wait()
				end
				game:GetService("Lighting").OutdoorAmbient = getLightingOutdoorAmbient()
				if self.blueFrame then
					self.blueFrame.Visible = false
				end
			end)
		end)

		chunk:registerExitDoorEvent("rainReverbDisable", function(doorId, state)
			game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(106, 99, 169)
			if self.blueFrame then
				self.blueFrame.Visible = true
			end
			spawn(function()
				while state[1] < 1 do
					if state[1] == -1 then
						return
					end
					wait()
				end
				self:fadeIndoorReverbOff(1.5)
			end)
		end)

		if chunk.map:FindFirstChild("TriggerReverbOn") then
			local touchConns = {}

			local function tryTriggerOn(p)
				if not p or p.Parent ~= _p.player.Character then
					return
				end
				rain:fadeIndoorReverbOn(1)
			end

			local function tryTriggerOff(p)
				if not p or p.Parent ~= _p.player.Character then
					return
				end
				rain.rainFocus = nil
				rain:fadeIndoorReverbOff(1)
			end

			for _, ch in ipairs(chunk.map:GetChildren()) do
				if ch.Name == "TriggerReverbOn" then
					local attachment = ch:FindFirstChild("RainPos")
					if attachment then
						local pos = attachment.WorldPosition
						touchConns[#touchConns + 1] = ch.Touched:Connect(function(p)
							if not p or p.Parent ~= _p.player.Character then
								return
							end
							rain.rainFocus = pos
							rain:fadeIndoorReverbOn(1)
						end)
					else
						touchConns[#touchConns + 1] = ch.Touched:Connect(tryTriggerOn)
					end
				elseif ch.Name == "TriggerReverbOff" then
					touchConns[#touchConns + 1] = ch.Touched:Connect(tryTriggerOff)
				end
			end

			if #touchConns > 0 then
				self.reverbTriggerTouchConns = touchConns
			end
		end

		if chunk.indoors then
			self:fadeIndoorReverbOn(0)
			game:GetService("Lighting").OutdoorAmbient = getLightingOutdoorAmbient()
			if self.blueFrame then
				self.blueFrame.Visible = false
			end
		end
	end

	function rain:disableNewRain(fadeTime, leaveClockLocked)
		if not self.newRainEnabled then
			return
		end

		self.newRainEnabled = false
		rain.newRainEnabled = false
		self.rainThread = nil

		local lighting = game:GetService("Lighting")
		local sky = lighting:FindFirstChildOfClass("Sky")
		if sky then
			sky.CelestialBodiesShown = true
			sky.StarCount = 3000
		end

		local chunk = _p.DataManager.currentChunk
		if chunk then
			chunk:registerEnterDoorEvent("rainReverbEnable", nil)
			chunk:registerExitDoorEvent("rainReverbDisable", nil)
		end

		if self.reverbTriggerTouchConns then
			for _, cn in ipairs(self.reverbTriggerTouchConns) do
				pcall(function()
					cn:Disconnect()
				end)
			end
			self.reverbTriggerTouchConns = nil
		end

		if not leaveClockLocked then
			_p.DataManager:unlockClockTime()
		end

		local atmo = self.Atmosphere
		local blueFrame = self.blueFrame

		if fadeTime and not self.lightningEnabled then
			Utilities.spTween(lighting, "Brightness", getLightingBrightness(), fadeTime)
			Utilities.spTween(lighting, "ExposureCompensation", getLightingExposure(), fadeTime)
			Utilities.spTween(lighting, "OutdoorAmbient", getLightingOutdoorAmbient(), fadeTime)
			Utilities.spTween(lighting, "FogEnd", DEFAULT_LIGHTING_FOG_END, fadeTime)

			if self.Atmosphere then
				Utilities.spTween(self.Atmosphere, "Density", 0, fadeTime)
				Utilities.spTween(self.Atmosphere, "Haze", 0, fadeTime)
			end

			if blueFrame then
				Utilities.spTween(blueFrame, "BackgroundTransparency", 1, fadeTime, nil, nil, function()
					if blueFrame then
						blueFrame:Destroy()
					end
				end)
			end
		elseif self.lightningEnabled and not fadeTime then
			lighting.Brightness = getLightingBrightness()
			lighting.ExposureCompensation = getLightingExposure()
			lighting.OutdoorAmbient = getLightingOutdoorAmbient()
			lighting.FogEnd = DEFAULT_LIGHTING_FOG_END

			if self.Atmosphere then
				self.Atmosphere.Density = 0
				self.Atmosphere.Haze = 0
			end
		end

		if blueFrame then
			blueFrame:Destroy()
			self.blueFrame = nil
		end

		if atmo then
			atmo:Destroy()
			self.Atmosphere = nil
		end
	end

	return rain
end