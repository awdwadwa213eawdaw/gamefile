return function(_p)
	local Utilities = _p.Utilities
	local Create = Utilities.Create

	local Weather = {
		isRaining = false,
		isWindy = false,
		isHailing = false,
		isSnowing = false,
		isFoggy = false,
		isSunny = false,
		isMeteor = false,
		isAurora = false,
		isBlood = false,
		isStorm = false,
		isSpacial = false,
		isFireworks = false,
		isOn = false,
	}

	Weather.possibleThunderColors = {
		{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(Utilities.hexToRGB('#fc4a1a'))),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(Utilities.hexToRGB('#f7b733')))
		},
		{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(Utilities.hexToRGB('#fceabb'))),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(Utilities.hexToRGB('#f8b500')))
		},
		{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(Utilities.hexToRGB('#000428'))),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(Utilities.hexToRGB('#004e92')))
		},
	}

	Weather.Icons = {
		rain = {
			name = "Heavy Rainfall",
			color = Color3.fromRGB(90, 128, 209),
			image = "rbxassetid://136612960915552"
		},
		seismic = {
			name = "Seismic Activity",
			color = Color3.fromRGB(158, 84, 66),
			image = "rbxassetid://81776243378880"
		},
		wind = {
			name = "Strong Gusts",
			color = Color3.fromRGB(156, 156, 156),
			image = "rbxassetid://124931661853682"
		},
		hail = {
			name = "Pelting Hailstorm",
			color = Color3.fromRGB(185, 236, 255),
			image = "rbxassetid://108938052463811"
		},
		fog = {
			name = "Thick Fog",
			color = Color3.fromRGB(147, 147, 147),
			image = "rbxassetid://85425371525673"
		},
		snow = {
			name = "Blinding Snowstorm",
			color = Color3.fromRGB(255, 255, 255),
			image = "rbxassetid://103238506365620"
		},
		sun = {
			name = "Extreme Heat",
			color = Color3.fromRGB(255, 255, 0),
			image = "rbxassetid://105712101835155"
		},
		meteor = {
			name = "Meteor Shower",
			color = Color3.fromRGB(255, 204, 102),
			image = "rbxassetid://115524878206610",
			data = {
				name = "Deoxys",
				icon = 443,
				location = "Cosmeos Valley"
			}
		},
		aurora = {
			name = "Northern Lights",
			color = Color3.fromRGB(119, 255, 170),
			image = "rbxassetid://75024477794863",
			data = {
				name = "Cresselia",
				icon = 564,
				location = "???"
			}
		},
		blood = {
			name = "Blood Moon",
			color = Color3.fromRGB(255, 0, 70),
			image = "rbxassetid://102063254827567"
		},
		thunder = {
			name = "Explosive Thunderstorms",
			color = Color3.fromRGB(255, 141, 0),
			image = "rbxassetid://125908855265096"
		},
		smog = {
			name = "Toxic Smog",
			color = Color3.fromRGB(100, 81, 123),
			image = "rbxassetid://112626458040489"
		},
		sand = {
			name = "Savage Sandstorms",
			color = Color3.fromRGB(205, 201, 0),
			image = "rbxassetid://105389417376124"
		},
		fireworks = {
			name = "Seasonal Fireworks",
			color = Color3.fromRGB(255, 0, 0),
			image = "rbxassetid://132647801449572"
		},
		spacial = {
			name = "Spacial Anomalies",
			color = Color3.fromRGB(107, 96, 255),
			image = "rbxassetid://107257085566155"
		},
	}

	Weather.Popup = {
		aurora = {name='Cresselia',icon=564,location='???',pp=true},
		meteor = {name='Deoxys',icon=443,location='Cosmeos Valley',pp=true}
	}

	function Weather:Clear()
		if self.isRaining then self:EndRain() end
		if self.isWindy then self:EndWind(true) end
		if self.isHailing then self:EndHail() end
		if self.isSnowing then self:EndSnow() end
		if self.isFoggy then self:EndFog() end
		if self.isSunny then self:EndSun() end
		if self.isMeteor then self:EndShower() end
		if self.isAurora then self:EndAurora() end
		if self.isBlood then self:EndBloodMoon() end
		if self.isStorm then self:EndSandstorm() end
		if self.isSpacial then self:EndSpacial() end
		if self.isFireworks then self:EndFireworks() end
	end

	function Weather:Notification(p37)
		local v190 = _p.NotificationManager:ReserveSlot(0.16, 0.16, 14)
		local v189 = self.Icons[p37.weatherKind]

		local v191 = Create 'Frame' {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(.1, .1, .1),
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(1.1, 0),
			Parent = v190.gui
		}
		Create("UICorner")({Parent=v191,CornerRadius=UDim.new(0.08,0)})

		Create("TextLabel")({
			Parent=v191,
			BackgroundTransparency=1,
			Size=UDim2.fromScale(0.949,0.212),
			Position=UDim2.fromScale(0.02,0.03),
			ZIndex=2,
			Text=p37.regionName,
			Font=Enum.Font.GothamBold,
			TextScaled=true,
			TextColor3=Color3.fromRGB(255,255,255)
		})

		Create("TextLabel")({
			Parent=v191,
			BackgroundTransparency=1,
			Size=UDim2.fromScale(0.9,0.142),
			AnchorPoint=Vector2.new(0.5,0),
			Position=UDim2.fromScale(0.5,0.25),
			ZIndex=2,
			Text="is now experiencing",
			Font=Enum.Font.GothamBold,
			TextScaled=true,
			TextColor3=Color3.fromRGB(255,255,255)
		})

		Create("ImageLabel")({
			Parent=v191,
			BackgroundTransparency=1,
			Image=v189.image,
			SizeConstraint=Enum.SizeConstraint.RelativeYY,
			Size=UDim2.fromScale(0.322,0.322),
			Position=UDim2.fromScale(0.035,0.391),
			ZIndex=2
		})

		Create("TextLabel")({
			Parent=v191,
			BackgroundTransparency=1,
			Size=UDim2.fromScale(0.528,0.322),
			Position=UDim2.fromScale(0.422,0.391),
			ZIndex=2,
			Text=v189.name,
			Font=Enum.Font.GothamBlack,
			TextScaled=true,
			TextColor3=v189.color
		})

		if p37.Poke and p37.Poke.name then
			Create("TextLabel")({
				Parent=v191,
				BackgroundTransparency=1,
				Size=UDim2.fromScale(0.636,0.096),
				Position=UDim2.fromScale(0.347,0.747),
				ZIndex=2,
				Text="Acting Strangely",
				Font=Enum.Font.GothamBold,
				TextScaled=true,
				TextColor3=Color3.fromRGB(255,255,255)
			})

			Create("TextLabel")({
				Parent=v191,
				BackgroundTransparency=1,
				Size=UDim2.fromScale(0.603,0.128),
				Position=UDim2.fromScale(0.347,0.843),
				ZIndex=2,
				Text=p37.Poke.name,
				Font=Enum.Font.GothamBlack,
				TextScaled=true,
				TextColor3=Color3.fromRGB(200,200,200),
				TextXAlignment=Enum.TextXAlignment.Left
			})

			local v192 = _p.Pokemon:getIcon(p37.Poke.icon - 1, false)
			v192.SizeConstraint = Enum.SizeConstraint.RelativeYY
			v192.Size = UDim2.fromScale(0.2986666666666667,0.224)
			v192.AnchorPoint = Vector2.new(0.125,0)
			v192.Position = UDim2.fromScale(0.071,0.747)
			v192.ZIndex = 4
			v192.Parent = v191
		end

		Utilities.spTween(v191,"Position",UDim2.fromScale(-0.1,0),0.5,"easeOutCubic")
		wait(6)
		Utilities.spTween(v191,"Position",UDim2.fromScale(1.1,0),0.5,"easeOutCubic")
		wait(.6)
		v190:Destroy()
	end

	function Weather:StartRain(plc)
		if self.isRaining or not _p.Menu.options.weatherEnabled then return end
		self.isRaining = true
		_p.Overworld.Weather.Rain:enableNewRain(plc,1.5)
		_p.Overworld.Weather.Rain:setupBuildingReverb()
	end

	function Weather:EndRain(p4)
		if not self.isRaining then return end
		self.isRaining = false
		local v7 = p4 or 1.5
		_p.Overworld.Weather.Rain:disableNewRain(v7)
	end

	function Weather:StartWind()
		if self.isWindy or not _p.Menu.options.weatherEnabled then
			return
		end

		self.isWindy = true
		_p.Clouds:setCloudSpeed(3)

		local dir
		pcall(function()
			if _p.Clouds and _p.Clouds.part then
				dir = _p.Clouds.part.CFrame.RightVector
			end
		end)

		if not dir then
			dir = Vector3.new(1, 0, 0)
		end

		self.WindEffect:Enable(dir)
	end

	function Weather:EndWind(p8)
		if not self.isWindy then
			return
		end
		self.isWindy = false
		_p.Clouds:setCloudSpeed(1)
		self.WindEffect:Disable(p8)
	end

	function Weather:StartSnow()
		if self.isSnowing or not _p.Menu.options.weatherEnabled then return end
		self.isSnowing = true
		_p.Overworld.Weather.Snow:enableSnow()
	end

	function Weather:EndSnow()
		if not self.isSnowing then return end
		self.isSnowing = false
		_p.MusicManager:popMusic('SnowMusic',1)
		_p.Overworld.Weather.Snow:disableSnow()
	end

	function Weather:StartHail(model)
		if self.isHailing or not _p.Menu.options.weatherEnabled then return end
		self.isHailing = true
		_p.Overworld.Weather.Hail:enableHail(model)
	end

	function Weather:EndHail()
		if not self.isHailing then return end
		self.isHailing = false
		_p.Overworld.Weather.Hail:disableHail()
	end

	function Weather:StartFog(variant)
		if self.isFoggy or not _p.Menu.options.weatherEnabled then return end
		self.isFoggy = true
		_p.Overworld.Weather.Fog:enableFog(2.5,nil,variant)
	end

	function Weather:EndFog()
		if not self.isFoggy then return end
		self.isFoggy = false
		_p.Overworld.Weather.Fog:disableFog(2.5)
	end

	function Weather:StartSun()
		if self.isSunny or not _p.Menu.options.weatherEnabled then
			return
		end

		self.isSunny = true

		if _p.Clouds then
			_p.Clouds:setTransparency(0.8)
			_p.Clouds:setCloudSpeed(0.35)
		end

		self.Heat:Enable({
			damage = false,
			damagePerTick = 2,
			damageInterval = 2,
			forceDay = true,
			dayClockTime = 13
		})
	end
	
	function Weather:EndSun()
		if not self.isSunny then
			return
		end

		self.isSunny = false

		if _p.Clouds then
			_p.Clouds:setTransparency(0)
			_p.Clouds:setCloudSpeed(1)
		end

		self.Heat:Disable()
	end

	function Weather:StartAurora()
		if self.isAurora or not _p.Menu.options.weatherEnabled then return end
		self.isAurora = true
		local cf
		if _p.DataManager.currentChunk then
			cf = _p.DataManager.currentChunk.map:GetBoundingBox()
		end
		if cf then
			cf = cf:PointToWorldSpace()
			_p.Overworld.Weather.NorthernLights:enableNorthernLights(cf)
		end
	end

	function Weather:EndAurora()
		if not self.isAurora then return end
		self.isAurora = false
		_p.Overworld.Weather.NorthernLights:disableNorthernLights()
	end

	function Weather:StartBloodMoon()
		if self.isBlood or not _p.Menu.options.weatherEnabled then return end
		self.isBlood = true
		_p.Overworld.Weather.BloodMoon:enableBloodMoon()
	end

	function Weather:EndBloodMoon()
		if not self.isBlood then return end
		self.isBlood = false
		_p.Overworld.Weather.BloodMoon:disableBloodMoon()
	end

	function Weather:StartShower()
		if self.isMeteor or not _p.Menu.options.weatherEnabled then return end
		self.isMeteor = true
		_p.DataManager:lockClockTime(0)
		_p.Overworld.Weather.Meteor:Enable(math.random(1,5))
		spawn(function()
			_p.Overworld.Weather.Meteor:bigCrash('chunk51')
		end)
	end

	function Weather:EndShower()
		if not self.isMeteor then return end
		self.isMeteor = false
		_p.MusicManager:popMusic('MeteorMusic',1)
		_p.Overworld.Weather.Meteor:Disable()
		_p.DataManager:unlockClockTime()
		local currentChunk = _p.DataManager.currentChunk
		if currentChunk and not currentChunk.destroying then
			pcall(function()
				currentChunk.map:FindFirstChild("MeteorSite"):Destroy()
			end)
		end
	end

	function Weather:StartSandstorm()
		if self.isStorm or not _p.Menu.options.weatherEnabled then return end
		self.isStorm = true
		_p.Overworld.Weather.Sandstorm:enableStorm()
	end

	function Weather:EndSandstorm()
		if not self.isStorm then return end
		self.isStorm = false
		_p.Overworld.Weather.Sandstorm:disableStorm()
	end

	function Weather:StartSpacial()
		if self.isSpacial or not _p.Menu.options.weatherEnabled then return end
		self.isSpacial = true
		_p.Overworld.Weather.Spacial:setupSpacial()
	end

	function Weather:EndSpacial()
		if not self.isSpacial then return end
		self.isSpacial = false
		_p.Overworld.Weather.Spacial:removeSpacial()
	end

	function Weather:StartFireworks()
		if self.isFireworks or not _p.Menu.options.weatherEnabled then return end
		self.isFireworks = true
		_p.Overworld.Weather.Fireworks:startFireworks()
	end

	function Weather:EndFireworks()
		if not self.isFireworks then return end
		self.isFireworks = false
		_p.Overworld.Weather.Fireworks:endFireworks()
	end

	Weather.Rain = require(script.Rain)(_p)
	Weather.WindEffect = require(script.WindEffect)(_p)
	Weather.Fog = require(script.Fog)(_p)
	Weather.Meteor = require(script.Meteor)(_p)
	Weather.Snow = require(script.Snow)(_p)
	Weather.Hail = require(script.Hail)(_p)
	Weather.NorthernLights = require(script.NorthernLights)(_p)
	Weather.BloodMoon = require(script.BloodMoon)(_p)
	Weather.Sandstorm = require(script.Sandstorm)(_p)
	Weather.Fireworks = require(script.Fireworks)(_p)
	Weather.Spacial = require(script.Spacial)(_p)
	Weather.Heat = require(script.ExtremeHeat)(_p)

	return Weather
end