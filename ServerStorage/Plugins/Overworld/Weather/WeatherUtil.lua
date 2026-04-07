return function(_p)
	local Utilities = _p.Utilities
	local Create = Utilities.Create
	local Lighting = game:GetService("Lighting")

	local WeatherUtil = {
		ambienceReverb = false,
		defaultFadeTime = .5

	}

	local TweenService = game:GetService("TweenService")

	local function makeSound(id, vol)
		if not vol then vol = .8 end
		Utilities.sound(id, vol, nil, 10)
	end
	function WeatherUtil:Tween(tweenData, destroyOnFinish, func)
		local timin = nil
		local numValue = Instance.new("NumberValue")
		numValue.Value = 0
		local createdTween = TweenService:Create(numValue, tweenData, {
			Value = 1
		})
		timin = createdTween.TweenInfo.Time
		local changedSignal = numValue:GetPropertyChangedSignal("Value")
		local finishTime = tick() + createdTween.TweenInfo.DelayTime
		local Item = numValue
		changedSignal:connect(function()
			if func(Item.Value, tick() - finishTime) ~= false then
				return
			end
			Item:Destroy()
			createdTween:Cancel()
		end)
		createdTween:Play()
		if not destroyOnFinish then
			createdTween.Completed:Connect(function()
				func(1, timin)
				Item:Destroy()
				Item = nil
			end)
			return createdTween
		end
		createdTween.Completed:Wait()
		func(1, timin)
		Item:Destroy()
		Item = nil
	end

	function WeatherUtil:lerp(Origin, EndPoint, Amount)
		return Origin + (EndPoint - Origin) * Amount
	end

	function WeatherUtil:saveLighting()	
		for _, dta in pairs({'OutdoorAmbient', 'ExposureCompensation', 'Brightness', 'FogEnd'}) do
			--add a util function to get properties of an instance
			_p.Settings.Lighting['Lighting_'..dta] = Lighting[dta]
		end
	end

	function WeatherUtil:createReverbGroup()
		if not self.IndoorReverb then
			self.IndoorReverb = Create("SoundGroup")({
				Archivable = false,
				Volume = 1,
				Parent = game:GetService("SoundService"),
				Create("EqualizerSoundEffect")({
					HighGain = -10,
					MidGain = -5,
					LowGain = 1,
					Priority = 2,
					Enabled = false
				}),
				Create("ReverbSoundEffect")({
					DecayTime = 1.5,
					Density = 1,
					Diffusion = 1,
					DryLevel = -6,
					WetLevel = 0.4,
					Priority = 1,
					Enabled = false
				})
			})
		end
		return self.IndoorReverb
	end
	function WeatherUtil:setupBuildingReverb()
		local chunk = _p.DataManager.currentChunk
		--Clear existing reverb 
		chunk:registerEnterDoorEvent("ReverbEnable", nil)
		chunk:registerExitDoorEvent("ReverbDisable", nil)
		--Setup new reverb
		if _p.DataManager.currentChunk and _p.DataManager.currentChunk.indoors and not self.ambienceReverb then
			--enables reverb indoors if it isn't already
			self:toggleReverb(1)
		end
		chunk:registerEnterDoorEvent("ReverbEnable", function(doorId, state)
			spawn(function()
				self:toggleReverb(1)
			end)
		end)
		chunk:registerExitDoorEvent("ReverbDisable", function(doorId, state)
			spawn(function()
				self:toggleReverb(1)
			end)
		end)
		
	end
	function WeatherUtil:toggleReverb(fadeTime)	
		if not self.IndoorReverb then
			self:createReverbGroup()
		end
		local ese = self.IndoorReverb.EqualizerSoundEffect
		local rse = self.IndoorReverb.ReverbSoundEffect
		local mainModule = _p.Overworld

		if not fadeTime then
			fadeTime = self.defaultFadeTime
		end
		if self.ambienceReverb then 
			self.ambienceReverb = false
			Utilities.spTween(ese, 'HighGain', 0, fadeTime)
			Utilities.spTween(ese, 'MidGain', 0, fadeTime)
			Utilities.spTween(ese, 'LowGain', 0, fadeTime)

			Utilities.spTween(rse, 'DryLevel', 0, fadeTime)
			Utilities.spTween(rse, 'WetLevel', -30, fadeTime)
			ese.Enabled = false
			rse.Enabled = false
			return
		elseif _p.Settings.Weather.indoorReverb[mainModule.currentWeather] then
			self.ambienceReverb = true
			ese.Enabled = true
			rse.Enabled = true
			for index, dta in pairs({'HighGain' ,'MidGain', 'LowGain', 'DryLevel', 'WetLevel'}) do
				if _p.Settings.Weather.indoorReverb[mainModule.currentWeather][dta] then
					if index >= 4 then
						Utilities.spTween(rse, dta, _p.Settings.Weather.indoorReverb[mainModule.currentWeather][dta], fadeTime)
					else
						Utilities.spTween(ese, dta, _p.Settings.Weather.indoorReverb[mainModule.currentWeather][dta], fadeTime)
					end
				end
			end
		else
			warn('Unable to verify if indoorReverb applies to: '..mainModule.currentWeather) 
		end
	end
	
	
	function WeatherUtil:BeamLightning(Origin, EndPoint, Amount, Range, Color, Width)
		local magnitude = math.random(1, 100)
		local rngSeed = Random.new(magnitude)

		local timing = .3
		local tweenData = TweenInfo.new(timing, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
		local amount = {}

		for currentBeams = 0, Amount do
			local lerpPos = self:lerp(Origin, EndPoint, currentBeams / Amount)
			local Radi = Range * math.clamp(1 - currentBeams / Amount, 0, 0.6)
			local VectorX = rngSeed:NextInteger(-Radi, Radi)
			local VectorY = rngSeed:NextInteger(-Radi, Radi)
			local Attachment = Instance.new("Attachment")
			local newPos = Vector3.new(VectorX, rngSeed:NextInteger(-Radi, Radi), VectorY)
			if currentBeams == 0 then
				newPos = Vector3.new()
			elseif currentBeams == Amount then
				newPos = Vector3.new(VectorX, 0, VectorY)
				--local thundering = create ('Attachment')({
				--	Name = 'ThunderingSpot',
				--	Parent = workspace.Terrain,
				--})
				--thundering.Position = lerpPos + newPos + Vector3.new(0, 0.6, 0)
				--local eh = create ('ParticleEmitter') (
				--	_p.Overworld.SFXData.lightning			
				--)
				--eh.Parent = thundering
				--delay(8, function()
				--	thundering:Destroy()
				--end)			
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
				self:Tween(tweenData, false, function(a)
					Beam.Transparency = NumberSequence.new(a)
					Beam.Width0 = Width - 0.99 * Width * a
					Beam.Width1 = Width - 0.99 * Width * a
				end)
				delay(timing, function()
					Beam:Destroy()
				end)
			end
		end
		spawn(function()
			local cam = workspace.CurrentCamera
			if _p.Battle.currentBattle then return end -- or camera scriptable?
			_p.CameraShaker:BeginEarthquake(function(cf)
				cam.CFrame = cam.CFrame * cf
			end, 0.2)
			local sounds = {4961088919, 821439273, 2036960141, 6767188184}
			makeSound(sounds[math.random(1, #sounds)])
			wait(.15)
			_p.CameraShaker:EndEarthquake(0.22)
		end)
		delay(timing * Amount, function()
			for _, cycleBeam in pairs(amount) do
				cycleBeam:Destroy()
			end
		end)
	end

	return WeatherUtil
end

