return function(_p)

	local Utilities = _p.Utilities
	local Create = Utilities.Create

	local Overworld = {
		currentWeather = '',
		eventWeather = false,
		isLocked = false
	}

	local overworldSettings = {
		defaultModel = 'Pikachu',
		validWeather = {'','rain','wind','snow','hail','fog','aurora','meteor','blood','thunder','smog','sun','sand','spacial','fireworks'},
	}

	local cloudPropeties = {
		clear = {.7, .6},
		rain = {.4, 1},
		thunder = {.4, 1},
		blood = {0, 0, true},
		aurora = {0, 0, true},
		sun = {0, 0, true},
		hail = {.5, .3},
		wind = {.55, .6},
		snow = {.5, .3},
		sand = {0, 0, true},
		fireworks = {0, 0, true},
	}

	local TweenTime = .25

	local weatherMusic = {
		['rain'] = {6288548495, 3},
		['wind'] = {6527090659, 3},
		['snow']= {7031629626, 3},
		['hail']= {5688742207, 1.8},
		['meteor'] = {6689145449, 3},
		['fog'] = {7023143807, 3},
		['aurora'] = {7135187840, 3},
		['spacial'] = {7135185224, 3},
		['sun'] = {7471271584, 1.68},
		['smog'] = {1835315307, 3},
		['thunder'] = {3694981522, 3},
		['sand'] = {8106698910, 2},
	}

	local staticWeather = {
		['rain'] = {2878066395, .5},
		['wind'] = {6527086351, .28},
		['hail']= {236328822, .4},
		['thunder'] = {372183961, .5},
		['blood'] = {7591624708, .5},
		['sand'] = {8106431360, .5}
	}

	function Overworld:CheckForMusic(musicID)
		for _, Music in pairs(_p.MusicManager:getMusicStack()) do
			if musicID[Music.Name] then
				return true
			end
		end
		return false
	end

	function Overworld:updateMusicOption(enable)
		if enable and not self.currentWeatherMusicId then
			local weather = self.currentWeather
			if weather and weather ~= '' then
				local currentChunk = _p.DataManager.currentChunk
				if currentChunk then
					currentChunk.regionMusicDisabled = true
				end
				if weatherMusic[weather] then
					_p.MusicManager:stackMusic(weatherMusic[weather][1], weather.."Music", weatherMusic[weather][2], 0.4)
				end
				self.currentWeatherMusicId = weather..'Music'
				if staticWeather[weather] then
					self.staticSound = Utilities.loopSound(staticWeather[weather][1], staticWeather[weather][2])
				end
				if self.staticSound and (weather == 'rain' or weather == 'thunder') then
					self.staticSound.SoundGroup = _p.Overworld.Weather.Rain.IndoorReverb
				end
			end
		elseif not enable and self.currentWeatherMusicId then
			if self.staticSound then
				self.staticSound:Destroy()
				self.staticSound = nil
			end
			if self.currentWeatherMusicId then
				_p.MusicManager:popMusic(self.currentWeatherMusicId, 1)
				self.currentWeatherMusicId = nil
				local currentChunk = _p.DataManager.currentChunk
				if currentChunk and not currentChunk.destroying then
					currentChunk.regionMusicDisabled = false
					currentChunk:startRegionMusic()
				end
			end
		end
	end

	function Overworld:LoadingNotice(text)
		local Slot = _p.NotificationManager:ReserveSlot(0.2, 0.05, 2)
		local frame = Create 'Frame' {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(.1, .1, .1),
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(1.1, 0),
			Parent = Slot.gui
		}
		Create("UICorner")({
			Parent = frame,
			CornerRadius = UDim.new(0.08, 0)
		})
		Create("TextLabel")({
			Parent = frame,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0.949, 0.75),
			Position = UDim2.fromScale(0.02, 0.03),
			ZIndex = 2,
			Text = text.item,
			Font = Enum.Font.GothamBold,
			TextScaled = true,
			TextColor3 = Color3.fromRGB(255,255,255)
		})
		Utilities.spTween(frame, "Position", UDim2.fromScale(-0.1, 0), 0.5, "easeOutCubic")
		wait(16)
		Utilities.spTween(frame, "Position", UDim2.fromScale(1.1, 0), 0.5, "easeOutCubic")
		wait(.8)
		_p.NotificationManager:Destroys(Slot)
	end

	function Overworld:updateEventWeather()
		if _p.PlayerData.isDate == 'halloween' then
			self.eventWeather = {
				name = "Blood Moon",
				id = 'blood',
				color = {Color3.fromRGB(Utilities.hexToRGB('#FF5F6D')), Color3.fromRGB(Utilities.hexToRGB('#FFC371'))},
				iconOffset = Vector2.new(101, 101)
			}
		elseif _p.PlayerData.isDate == 'christmas' then
			self.eventWeather = {
				name = "Seasonal Fireworks",
				id = 'fireworks',
				color = {Color3.fromRGB(Utilities.hexToRGB('#4ECDC4')), Color3.fromRGB(Utilities.hexToRGB('#BE93C5'))},
				iconOffset = Vector2.new(1, 101)
			}
		end
	end

	function Overworld:toggleWeather(useCameraPos, model, ignoreReset)
		local weatherData = _p.Network:get('PDS', 'weatherUpdate')
		local currentWeather = weatherData[1][3] or self.currentWeather

		_p.Overworld.Weather.WindEffect.useCameraPosition = useCameraPos
		_p.Overworld.Weather.Rain.useCameraPosition = useCameraPos
		_p.Overworld.Weather.Hail.useCameraPosition = useCameraPos

		if ignoreReset and _p.DataManager.currentChunk then
			self:startWeather(currentWeather, model, true)
			return
		end

		if currentWeather and currentWeather ~= '' then
			self:endWeather(currentWeather, true)
			task.wait(0.05)
			self:startWeather(currentWeather, model, true)
		end
	end

	function Overworld:startWeather(weather, model, noMusic, indoor)
		if self.isLocked then return end
		if not _p.Menu.options.weatherEnabled then return end
		if not _p.DataManager.currentChunk then return end
		if _p.DataManager.currentChunk.data.noWeather and not _p.DataManager.currentChunk.data.forcedWeather then return end

		weather = weather or ''

		if weather == '' then
			self.currentWeather = ''
			return
		end

		if self.currentWeather == weather and not indoor then
			return
		end

		if self.currentWeather ~= '' and self.currentWeather ~= weather then
			self:endWeather(self.currentWeather, true, indoor)
			task.wait(0.05)
		end

		if self.staticSound then
			self.staticSound:Destroy()
			self.staticSound = nil
		end

		if staticWeather[weather] then
			self.staticSound = Utilities.loopSound(staticWeather[weather][1], staticWeather[weather][2])
		end

		if weather == 'rain' then
			_p.Overworld.Weather.Rain.lightningEnabled = false
			_p.Overworld.Weather:StartRain(model)
			if self.staticSound then
				self.staticSound.SoundGroup = _p.Overworld.Weather.Rain.IndoorReverb
			end
		elseif weather == 'wind' then
			_p.Overworld.Weather:StartWind()
		elseif weather == 'fog' then
			_p.Overworld.Weather:StartFog()
		elseif weather == 'hail' then
			_p.Overworld.Weather:StartHail(model)
		elseif weather == 'snow' then
			_p.Overworld.Weather:StartSnow()
		elseif weather == 'meteor' then
			_p.Overworld.Weather:StartShower()
		elseif weather == 'aurora' then
			_p.Overworld.Weather:StartAurora()
		elseif weather == 'blood' then
			_p.Overworld.Weather:StartBloodMoon()
		elseif weather == 'sand' then
			_p.Overworld.Weather:StartSandstorm()
		elseif weather == 'fireworks' then
			_p.Overworld.Weather:StartFireworks()
		elseif weather == 'spacial' then
			_p.Overworld.Weather:StartSpacial()
		elseif weather == 'thunder' then
			_p.Overworld.Weather.Rain.lightningEnabled = true
			_p.Overworld.Weather:StartRain(model)
			if self.staticSound then
				self.staticSound.SoundGroup = _p.Overworld.Weather.Rain.IndoorReverb
			end
		elseif weather == 'smog' then
			_p.Overworld.Weather:StartFog('smog')
		elseif weather == 'sun' then
			if _p.Overworld.Weather.StartSun then
				_p.Overworld.Weather:StartSun()
			end
		end

		self.currentWeather = weather

		if not noMusic and weather ~= '' then
			if weatherMusic[weather] and _p.Menu.options.noWeatherMusic then
				_p.MusicManager:stackMusic(weatherMusic[weather][1], weather.."Music", weatherMusic[weather][2], 0.4)
			end
			local currentChunk = _p.DataManager.currentChunk
			if currentChunk then
				currentChunk.regionMusicDisabled = true
			end
			self.currentWeatherMusicId = weather..'Music'
		end

		local wth = cloudPropeties[weather] or cloudPropeties.clear
	end

	function Overworld:endWeather(weather, ignoreRegion, indoor)
		if self.isLocked then return end
		if _p.DataManager.currentChunk and _p.DataManager.currentChunk.data.noWeather and not _p.DataManager.currentChunk.data.forcedWeather then return end

		weather = weather or self.currentWeather or ''
		if weather == '' then
			self.currentWeather = ''
			return
		end

		if not ignoreRegion then
			if self.staticSound then
				self.staticSound:Destroy()
				self.staticSound = nil
			end

			if self.currentWeatherMusicId then
				_p.MusicManager:popMusic(self.currentWeatherMusicId, 1)
				self.currentWeatherMusicId = nil

				local currentChunk = _p.DataManager.currentChunk
				if currentChunk then
					currentChunk.regionMusicDisabled = false
					if not indoor then
						currentChunk:startRegionMusic()
					end
				end
			end
		end

		if weather == 'rain' then
			_p.Overworld.Weather:EndRain()
		elseif weather == 'wind' then
			_p.Overworld.Weather:EndWind()
		elseif weather == 'fog' then
			_p.Overworld.Weather:EndFog()
		elseif weather == 'hail' then
			_p.Overworld.Weather:EndHail()
		elseif weather == 'snow' then
			_p.Overworld.Weather:EndSnow()
		elseif weather == 'meteor' then
			_p.Overworld.Weather:EndShower()
		elseif weather == 'aurora' then
			_p.Overworld.Weather:EndAurora()
		elseif weather == 'blood' then
			_p.Overworld.Weather:EndBloodMoon()
		elseif weather == 'sand' then
			_p.Overworld.Weather:EndSandstorm()
		elseif weather == 'fireworks' then
			_p.Overworld.Weather:EndFireworks()
		elseif weather == 'spacial' then
			_p.Overworld.Weather:EndSpacial()
		elseif weather == 'thunder' then
			_p.Overworld.Weather.Rain.lightningEnabled = false
			_p.Overworld.Weather:EndRain()
		elseif weather == 'smog' then
			_p.Overworld.Weather:EndFog()
		elseif weather == 'sun' then
			if _p.Overworld.Weather.EndSun then
				_p.Overworld.Weather:EndSun()
			end
		end

		if not indoor then
			self.currentWeather = ''
		end

		local wth = cloudPropeties.clear
	end

	function Overworld:enableForcedWeather()
		self:endAllWeather()
		task.wait(0.05)
		if _p.DataManager.currentChunk and not _p.DataManager.currentChunk.data.forcedWeather then
			self:startWeather(_p.DataManager.currentChunk.data.weather)
			return
		end
		self:startWeather(_p.DataManager.currentChunk.data.forcedWeather)
	end

	function Overworld:endAllWeather()
		if self.staticSound then
			self.staticSound:Destroy()
			self.staticSound = nil
		end

		if self.currentWeatherMusicId then
			_p.MusicManager:popMusic(self.currentWeatherMusicId, 1)
			self.currentWeatherMusicId = nil

			local currentChunk = _p.DataManager.currentChunk
			if currentChunk then
				currentChunk.regionMusicDisabled = false
				currentChunk:startRegionMusic()
			end
		end

		_p.Overworld.Weather.Rain.lightningEnabled = false

		_p.Overworld.Weather:EndBloodMoon()
		_p.Overworld.Weather:EndAurora()
		_p.Overworld.Weather:EndShower()
		_p.Overworld.Weather:EndSnow()
		_p.Overworld.Weather:EndHail()
		_p.Overworld.Weather:EndFog()
		_p.Overworld.Weather:EndWind()
		_p.Overworld.Weather:EndSpacial()
		_p.Overworld.Weather:EndRain()
		_p.Overworld.Weather:EndSandstorm()
		_p.Overworld.Weather:EndFireworks()

		if _p.Overworld.Weather.EndSun then
			_p.Overworld.Weather:EndSun()
		end

		self.currentWeather = ''
	end

	function Overworld:startRandomWeather()
		self:endAllWeather()
		task.wait(0.05)
		self:startWeather(overworldSettings.validWeather[math.random(1, #overworldSettings.validWeather)])
	end

	function Overworld:endIndoorWeather()
		local weatherSave = self.currentWeather
		self:endWeather(weatherSave)
		return weatherSave
	end

	function Overworld:toggleWeatherIndoors(toggle)
		self.toggledWeather = {}
		self.toggledWeather[1] = self.currentWeather
		for _, weather in pairs(self.toggledWeather) do
			if toggle then
				self:startWeather(weather, false, false, true)
			else
				self:endWeather(weather, false, true)
			end
		end
	end

	Overworld.SFXData = require(script.SFXData)(_p)
	Overworld.Weather = require(script.Weather)(_p)
	Overworld.Events = require(script.Events)(_p)

	return Overworld
end