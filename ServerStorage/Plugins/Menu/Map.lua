return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local mapId = 6803967463
	local cityId = 7828476384
	local townId = 7828475893
	local cityDisabledId = 6604624134
	local townDisabledId = 6604625329

	local map = {}

	local mapData = { -- total 586 586
		{'Mitis Town',      1, .39, .75, 'chunk1', nil, 'yourhomef1'},
		{'Cheshma Town',    1, .41, .81, 'chunk2'},
		{'Silvent City',    2, .48, .87, 'chunk3'},
		{'Brimber City',    2, .3 , .8 , 'chunk5'},
		{'Lagoona Lake',    1, .23, .7 , 'chunk9'},
		{'Rosecove City',   2, .11, .51, 'chunk11'},
		{'Cragonos Cliffs', 1, .12, .32, 'chunk17'},
		{'Anthian City',    2, .67, .62, 'chunk21'},
		{'Aredia City',     2, .27, .16, 'chunk25', 'vAredia'},
		{'Fluoruma City',   2, .50, .20, 'chunk39', 'vFluoruma'},
		{'Frostveil City',  2, 0.7, 0.15, 'chunk46', 'vFrostveil'},
		{'Port Decca',      1, 0.85, 0.40, 'chunk58', 'vPortDecca'},
		{'Crescent Island', 1, .85, .60, 'chunk79', 'vCrescent'}
	}

	function map:getWeatherForecast(dnf)
		local eventWeather = _p.Overworld.eventWeather
		local WeatherData = _p.Overworld.Weather.Icons

		pcall(function()
			if dnf and dnf:FindFirstChild("ForecastContainerW") then
				dnf.ForecastContainerW:Destroy()
			end
		end)

		local v163 = Color3.new(1, 1, 1)
		local v164 = math.floor(0.00528 * dnf.AbsoluteSize.X + 0.5)

		local u45 = create("Frame")({
			Name = "ForecastContainerW",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0.92),
			Position = UDim2.fromScale(0, 0.08),
			Parent = dnf,
			create("Frame")({
				Name = "TimelineVertical",
				BorderSizePixel = 0,
				BackgroundColor3 = v163,
				Size = UDim2.new(0, v164, 1, 0),
				Position = UDim2.fromScale(0.012, 0),
				ZIndex = 4,
				create("Frame")({
					Name = "CurrentTime",
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 66, 66),
					SizeConstraint = Enum.SizeConstraint.RelativeXX,
					Size = UDim2.new(6, 0, 0, math.floor(v164 * 1.2 + 0.5)),
					AnchorPoint = Vector2.new(0.5, 0.5),
					ZIndex = 5
				})
			})
		})

		Utilities.fastSpawn(function()
			local Weather = _p.Network:get('PDS', 'weatherUpdate')
			local u46 = {}
			local date = os.date("*t")

			for i = 1, 5 do
				u46[i] = create("Frame")({
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 0.2),
					Position = UDim2.fromScale(0, (i - 1) / 5),
					Parent = u45,
					create("Frame")({
						Name = "TimelineTick",
						BorderSizePixel = 0,
						BackgroundColor3 = v163,
						Size = UDim2.new(0.14, 0, 0, 1),
						ZIndex = 3,
						create("TextButton")({
							Name = "HourLabel",
							BackgroundTransparency = 1,
							Size = UDim2.fromScale(0.8, 15),
							Position = UDim2.fromScale(0.16, 1.2),
							ZIndex = 4,
							Text = tostring((date.hour + (i - 1)) % 24) .. ':00',
							Font = Enum.Font.GothamBold,
							TextScaled = true,
							TextColor3 = v163
						})
					})
				})
			end

			for i = 1, 5 do
				spawn(function()
					local weatherState = Weather[i] and Weather[i][1]
					local weatherKey = Weather[i] and Weather[i][3]
					local WeatherVariantData = weatherKey and WeatherData[weatherKey] or nil
					local data = {location = 'Roria'}

					if WeatherVariantData and WeatherVariantData.data then
						data = WeatherVariantData.data
					end

					local v182
					if eventWeather then
						local eventColor = eventWeather.color or Color3.new(1, 1, 1)

						v182 = {
							BorderSizePixel = 0,
							BackgroundColor3 = Color3.new(.1, .1, .1),
							Size = UDim2.fromScale(0.65, 0.95),
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.fromScale(0.79, 0.04),
							ZIndex = 3,
							Parent = u46[i]
						}

						create("Frame")({
							Size = UDim2.fromScale(0.18, 0.95),
							BackgroundColor3 = Color3.new(.1, .1, .1),
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.fromScale(0.98, 0.04),
							ZIndex = 4,
							Parent = u46[i],
							create("UICorner")({
								CornerRadius = UDim.new(0.08, 0)
							}),
							create("ImageLabel")({
								BackgroundTransparency = 1,
								Image = eventWeather.image or "",
								SizeConstraint = Enum.SizeConstraint.RelativeYY,
								Size = UDim2.fromScale(0.6, 0.6),
								Position = UDim2.fromScale(.2, .29),
								ZIndex = 4
							}),
							create("TextLabel")({
								BackgroundTransparency = 1,
								Size = UDim2.fromScale(.96, 0.3),
								Position = UDim2.fromScale(.02, 0.08),
								ZIndex = 4,
								Text = eventWeather.name or "Event Weather",
								Font = Enum.Font.LuckiestGuy,
								TextScaled = true,
								TextColor3 = Color3.fromRGB(255, 255, 255),
								TextXAlignment = Enum.TextXAlignment.Center,
								create("UIGradient")({
									Color = ColorSequence.new{
										ColorSequenceKeypoint.new(0, eventColor),
										ColorSequenceKeypoint.new(1, eventColor)
									}
								})
							})
						})
					else
						v182 = {
							BorderSizePixel = 0,
							BackgroundColor3 = Color3.new(.1, .1, .1),
							Size = UDim2.fromScale(0.85, 0.95),
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.fromScale(0.98, 0.04),
							ZIndex = 3,
							Parent = u46[i]
						}
					end

					if weatherState == 'Clear' or weatherKey == '' or not WeatherVariantData then
						u45.TimelineVertical.CurrentTime.Position = UDim2.fromScale(0.5, (date.min / 60) / 5)
						return
					end

					local v183 = {
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(0.75, 0.3),
						Position = UDim2.fromScale(0.02, 0.1),
						ZIndex = 4,
						Text = (data.location or "Roria") .. " is " .. ((i == 1) and "experiencing" or "anticipating"),
						Font = Enum.Font.GothamBold,
						TextScaled = true,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextXAlignment = Enum.TextXAlignment.Left
					}

					v182[#v182+1] = create("ImageLabel")({
						BackgroundTransparency = 1,
						Image = WeatherVariantData.image or "",
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Size = UDim2.fromScale(0.5, 0.5),
						Position = UDim2.fromScale(0.025, 0.425),
						ZIndex = 4
					})

					v182[#v182+1] = create("TextLabel")(v183)

					v182[#v182+1] = create("TextLabel")({
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(0.6, eventWeather and .34 or 0.35),
						Position = UDim2.fromScale(eventWeather and .16 or .14, 0.5),
						ZIndex = 4,
						Text = WeatherVariantData.name or "Unknown Weather",
						Font = Enum.Font.GothamBlack,
						TextScaled = true,
						TextColor3 = WeatherVariantData.color or Color3.new(1, 1, 1),
						TextXAlignment = Enum.TextXAlignment.Left
					})

					local v185 = create("Frame")(v182)
					create("UICorner")({
						Parent = v185,
						CornerRadius = UDim.new(0.08, 0)
					})

					if data.name and data.icon and i == 1 then
						create("TextLabel")({
							BackgroundTransparency = 1,
							Size = UDim2.fromScale(0.265, 0.183),
							Position = UDim2.fromScale(0.718, 0.392),
							ZIndex = 4,
							Text = "Acting Strangely:",
							Font = Enum.Font.GothamBold,
							TextScaled = true,
							TextColor3 = Color3.fromRGB(128, 128, 128),
							Parent = v185
						})

						local v186 = _p.Pokemon:getIcon(data.icon - 1)
						v186.SizeConstraint = Enum.SizeConstraint.RelativeYY
						v186.Size = UDim2.fromScale(0.3333333333333333, 0.25)
						v186.AnchorPoint = Vector2.new(0.125, 0)
						v186.Position = UDim2.fromScale(0.718, 0.588)
						v186.ZIndex = 4
						v186.Parent = v185

						create("TextLabel")({
							BackgroundTransparency = 1,
							Size = UDim2.fromScale(0.183, 0.254),
							Position = UDim2.fromScale(0.784, 0.62),
							ZIndex = 4,
							Text = data.name,
							Font = Enum.Font.GothamBlack,
							TextScaled = true,
							TextColor3 = Color3.fromRGB(255, 128, 0),
							TextXAlignment = Enum.TextXAlignment.Left,
							Parent = v185
						})
					end

					u45.TimelineVertical.CurrentTime.Position = UDim2.fromScale(0.5, (date.min / 60) / 5)
				end)
			end
		end)

		self.weatherVari = u45
	end

	function map:fly()
		local busy = false
		local sig = Utilities.Signal()

		local container = create 'Frame' {
			BackgroundTransparency = 1.0,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(.9, 0, .9, 0),
			Parent = Utilities.gui
		}

		local mapGui; mapGui = create 'ImageButton' {
			BackgroundColor3 = BrickColor.new('Cyan').Color,
			BorderSizePixel = 4,
			BorderColor3 = BrickColor.new('Deep blue').Color,
			Image = 'rbxassetid://'..mapId,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			Position = UDim2.new(-.5, 0, 0.0, 0),
			ZIndex = 3, Parent = container,
		}

		local bg = create 'ImageButton' {
			AutoButtonColor = false,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, 1.0, 60),
			Position = UDim2.new(0.0, 0, 0.0, -60),
			Parent = Utilities.gui
		}

		local activeLocation

		local function onMouseLeave(loc)
			if not loc then return end
			loc.button.ZIndex = 4
			loc.container:Destroy()
		end

		local function onMouseEnter(button, data)
			if activeLocation then
				local loc = activeLocation
				activeLocation = nil
				onMouseLeave(loc)
			end

			local holder = create 'Frame' {
				ClipsDescendants = true,
				BackgroundTransparency = 1.0,
				Position = UDim2.new(.5, 0, 0.0, 0),
				ZIndex = 5,
				Parent = button
			}

			local label = Utilities.Write('  '..data[1]) {
				Frame = holder,
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Left
			}.Frame

			local thisLocation = {
				button = button,
				data = data,
				container = holder,
				label = label,
			}

			button.ZIndex = 6
			activeLocation = thisLocation
			label.Size = UDim2.new(label.Size.X.Scale * .7, 0, .7, 0)
			holder.Size = UDim2.new(label.Size.X.Scale + .5, 0, 1.0, 0)

			Utilities.Tween(.5, 'easeOutCubic', function(a)
				if activeLocation ~= thisLocation then return false end
				label.Position = UDim2.new(a - 1, 0, 0.15, 0)
			end)
		end

		local function onClick(button, data)
			busy = true
			local fly = _p.NPCChat:say('[y/n]Fly to '..data[1]..'?')
			if fly then
				sig:fire(data)
			elseif activeLocation then
				local loc = activeLocation
				activeLocation = nil
				onMouseLeave(loc)
				busy = false
			end
		end

		local function locationHover()
			for _, d in pairs(mapData) do
				local rEvent = d[6]
				local enabled = not rEvent or _p.PlayerData.completedEvents[rEvent]
				local locType = d[2]

				local enabledIDs = {townId, cityId}
				local disabledIDs = {townDisabledId, cityDisabledId}

				local i; i = create 'ImageButton' {
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://'..(enabled and enabledIDs[locType] or disabledIDs[locType]),
					Size = UDim2.new(.055, 0, .055, 0),
					Position = UDim2.new(d[3] - .0275, 0, d[4] - .0275, 0),
					ZIndex = 4,
					Parent = mapGui
				}

				if Utilities.isTouchDevice() then
					if busy then return end
					i.TouchTap:connect(function()
						if activeLocation and activeLocation.data == d then
							if enabled then
								onClick(i, d)
							end
						else
							onMouseEnter(i, d)
						end
					end)
				else
					i.MouseEnter:connect(function()
						if busy or (activeLocation and activeLocation.data == d) then return end
						onMouseEnter(i, d)
					end)
					i.MouseLeave:connect(function()
						if busy then return end
						local loc = activeLocation
						activeLocation = nil
						onMouseLeave(loc)
					end)
					if enabled then
						i.MouseButton1Click:connect(function()
							if busy then return end
							onClick(i, d)
						end)
					end
				end
			end
		end

		locationHover()

		local showingForecast = false
		local weather
		local forecastFrame

		local function destroyForecastFrame()
			if forecastFrame and forecastFrame.Frame then
				forecastFrame.Frame:Destroy()
				forecastFrame = nil
			end
		end

		weather = _p.RoundedFrame:new {
			Button = true,
			BackgroundColor3 = BrickColor.new('Baby blue').Color,
			Size = UDim2.new(.31, 0, .08, 0),
			Position = UDim2.new(.5, 0, -.03, 0),
			ZIndex = 9,
			Parent = mapGui,
			MouseButton1Click = function()
				showingForecast = not showingForecast
				if showingForecast then
					if self.weatherVari then
						self.weatherVari:Destroy()
					end
					mapGui.Image = ''
					for _, d in ipairs(mapGui:GetChildren()) do
						if d:IsA("ImageButton") and (
							d.Image == 'rbxassetid://'..cityId or
								d.Image == 'rbxassetid://'..townId or
								d.Image == 'rbxassetid://'..cityDisabledId or
								d.Image == 'rbxassetid://'..townDisabledId or
								d.Image == 'rbxassetid://'
							) then
							d:Destroy()
						end
					end
					self:getWeatherForecast(mapGui)
					destroyForecastFrame()
					forecastFrame = Utilities.Write 'Map' {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(1.0, 0, 0.7, 0),
							Position = UDim2.new(0.0, 0, 0.15, 0),
							ZIndex = 10,
							Parent = weather.gui
						},
						Scaled = true,
					}
				else
					if mapGui:FindFirstChild("ForecastContainerW") then
						mapGui.ForecastContainerW:Destroy()
					end
					mapGui.Image = 'rbxassetid://'..mapId
					locationHover()
					destroyForecastFrame()
					forecastFrame = Utilities.Write 'Forecast' {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(1.0, 0, 0.7, 0),
							Position = UDim2.new(0.0, 0, 0.15, 0),
							ZIndex = 10,
							Parent = weather.gui
						},
						Scaled = true,
					}
				end
			end
		}

		forecastFrame = Utilities.Write 'Forecast' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, 0.6, 0),
				Position = UDim2.new(0.0, 0, 0.2, 0),
				ZIndex = 10,
				Parent = weather.gui
			},
			Scaled = true,
		}

		local close = _p.RoundedFrame:new {
			Button = true,
			BackgroundColor3 = BrickColor.new('Deep blue').Color,
			Size = UDim2.new(.31, 0, .08, 0),
			Position = UDim2.new(.85, 0, -.03, 0),
			ZIndex = 9,
			Parent = mapGui,
			MouseButton1Click = function()
				sig:fire()
			end
		}

		Utilities.Write 'Cancel' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, 0.6, 0),
				Position = UDim2.new(0.0, 0, 0.2, 0),
				ZIndex = 10,
				Parent = close.gui
			},
			Scaled = true,
		}

		Utilities.Tween(.8, 'easeOutCubic', function(a)
			bg.BackgroundTransparency = 1 - .3 * a
			container.Position = UDim2.new(.5, 0, .05 + 1 - a, 0)
		end)

		local location = sig:wait()
		if not location then
			spawn(function() _p.Menu.party:open() end)
		end

		Utilities.Tween(.8, 'easeOutCubic', function(a)
			bg.BackgroundTransparency = .7 + .3 * a
			container.Position = UDim2.new(.5, 0, .05 + a, 0)
		end)

		close:destroy()
		bg:Destroy()
		container:Destroy()

		if location then
			local cam = workspace.CurrentCamera
			cam.CameraType = Enum.CameraType.Scriptable
			_p.Hoverboard:unequip(true)

			local bird = _p.storage.Models.GenericFly:Clone()
			local cfs = {}
			local mcf = bird.Main.CFrame
			for _, p in pairs(bird:GetChildren()) do
				if p:IsA('BasePart') then
					cfs[p] = mcf:toObjectSpace(p.CFrame)
				end
			end
			bird.Parent = workspace

			local root = _p.player.Character.HumanoidRootPart
			local forward = root.CFrame.lookVector
			forward = (forward * Vector3.new(1, 0, 1)).unit
			if forward.magnitude < .5 then
				forward = Vector3.new(0, 0, -1)
			end

			local human = Utilities.getHumanoid()
			local r = 20
			local right = root.CFrame.rightVector
			local sin, cos = math.sin, math.cos
			local up = Vector3.new(0, 1, 0)

			local function swoop(rp)
				local focus = rp + Vector3.new(0, r + (human.RigType == Enum.HumanoidRigType.R15 and (-root.Size.Y/2 - human.HipHeight + 1) or -2), 0)
				Utilities.Tween(.75, nil, function(a)
					local th = a * 3.14
					local s, c = sin(th), cos(th)
					local pos = focus + r * (forward * -c + up * -s)
					local dir = forward * s + up * -c
					local top = right:Cross(dir)
					local cf = CFrame.new(
						pos.X, pos.Y, pos.Z,
						dir.X, top.X, right.X,
						dir.Y, top.Y, right.Y,
						dir.Z, top.Z, right.Z
					)
					for p, rcf in pairs(cfs) do
						p.CFrame = cf:toWorldSpace(rcf)
					end
				end)
			end

			task.delay(.375, Utilities.TeleportToSpawnBox)
			swoop(root.Position)

			Utilities.FadeOut(.5)
			local chunk = _p.DataManager.currentChunk
			if _p.Surf.surfing then
				_p.Surf:forceUnsurf()
			end
			if location[5] ~= chunk.id then
				chunk:destroy()
				task.wait()
				chunk = _p.DataManager:loadChunk(location[5])
			end

			local door = chunk:getDoor(location[7] or 'PokeCenter') or chunk:getCaveDoor(location[7])
			local cf = door.CFrame * CFrame.new(0, -door.Size.Y/2 + 3, -5)
			cam.CFrame = CFrame.new(cf * Vector3.new(0, 10, -14), cf * Vector3.new(0, 1.5, 0))
			Utilities.FadeIn(.5)

			forward = door.CFrame.rightVector
			task.delay(.375, function() Utilities.Teleport(cf) end)
			swoop(cf.p)
			bird:Destroy()
			cam.CameraType = Enum.CameraType.Fixed
			Utilities.lookBackAtMe(0.5)
			task.wait(0.5)
			if _p.RunningShoes and _p.RunningShoes.removeSpeedMultiplier then
				_p.RunningShoes:removeSpeedMultiplier('Sand')
			end			cam.CameraType = Enum.CameraType.Custom
			_p.MasterControl.WalkEnabled = true
			_p.Menu:enable()
		end
	end

	function map:open()
		local busy = false
		local sig = Utilities.Signal()

		local container = create 'Frame' {
			BackgroundTransparency = 1.0,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(.9, 0, .9, 0),
			Parent = Utilities.gui
		}

		local mapGui; mapGui = create 'ImageButton' {
			BackgroundColor3 = BrickColor.new('Cyan').Color,
			BorderSizePixel = 4,
			BorderColor3 = BrickColor.new('Deep blue').Color,
			Image = 'rbxassetid://'..mapId,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			Position = UDim2.new(-.5, 0, 0.0, 0),
			ZIndex = 3,
			Parent = container,
		}

		local bg = create 'ImageButton' {
			AutoButtonColor = false,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, 1.0, 60),
			Position = UDim2.new(0.0, 0, 0.0, -60),
			Parent = Utilities.gui
		}

		local activeLocation

		local function onMouseLeave(loc)
			if not loc then return end
			loc.button.ZIndex = 4
			loc.container:Destroy()
		end

		local function onMouseEnter(button, data)
			if activeLocation then
				local loc = activeLocation
				activeLocation = nil
				onMouseLeave(loc)
			end

			local holder = create 'Frame' {
				ClipsDescendants = true,
				BackgroundTransparency = 1.0,
				Position = UDim2.new(.5, 0, 0.0, 0),
				ZIndex = 5,
				Parent = button
			}

			local label = Utilities.Write('  '..data[1]) {
				Frame = holder,
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Left
			}.Frame

			local thisLocation = {
				button = button,
				data = data,
				container = holder,
				label = label,
			}

			button.ZIndex = 6
			activeLocation = thisLocation
			label.Size = UDim2.new(label.Size.X.Scale * .7, 0, .7, 0)
			holder.Size = UDim2.new(label.Size.X.Scale + .5, 0, 1.0, 0)

			Utilities.Tween(.5, 'easeOutCubic', function(a)
				if activeLocation ~= thisLocation then return false end
				label.Position = UDim2.new(a - 1, 0, 0.15, 0)
			end)
		end

		local function onClick(button, data)
			busy = true
			if activeLocation then
				local loc = activeLocation
				activeLocation = nil
				onMouseLeave(loc)
				busy = false
			end
		end

		local function locationHover()
			for _, d in pairs(mapData) do
				local rEvent = d[6]
				local enabled = not rEvent or _p.PlayerData.completedEvents[rEvent]
				local locType = d[2]

				local enabledIDs = {townId, cityId}
				local disabledIDs = {townDisabledId, cityDisabledId}

				local i; i = create 'ImageButton' {
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://'..(enabled and enabledIDs[locType] or disabledIDs[locType]),
					Size = UDim2.new(.055, 0, .055, 0),
					Position = UDim2.new(d[3] - .0275, 0, d[4] - .0275, 0),
					ZIndex = 4,
					Parent = mapGui
				}

				if Utilities.isTouchDevice() then
					if busy then return end
					i.TouchTap:connect(function()
						if activeLocation and activeLocation.data == d then
							if enabled then
								onClick(i, d)
							end
						else
							onMouseEnter(i, d)
						end
					end)
				else
					i.MouseEnter:connect(function()
						if busy or (activeLocation and activeLocation.data == d) then return end
						onMouseEnter(i, d)
					end)
					i.MouseLeave:connect(function()
						if busy then return end
						local loc = activeLocation
						activeLocation = nil
						onMouseLeave(loc)
					end)
					if enabled then
						i.MouseButton1Click:connect(function()
							if busy then return end
							onClick(i, d)
						end)
					end
				end
			end
		end

		locationHover()

		local showingForecast = false
		local weather
		local forecastFrame

		local function destroyForecastFrame()
			if forecastFrame and forecastFrame.Frame then
				forecastFrame.Frame:Destroy()
				forecastFrame = nil
			end
		end

		weather = _p.RoundedFrame:new {
			Button = true,
			BackgroundColor3 = BrickColor.new('Baby blue').Color,
			Size = UDim2.new(.31, 0, .08, 0),
			Position = UDim2.new(.5, 0, -.03, 0),
			ZIndex = 9,
			Parent = mapGui,
			MouseButton1Click = function()
				showingForecast = not showingForecast
				if showingForecast then
					if self.weatherVari then
						self.weatherVari:Destroy()
					end
					mapGui.Image = ''
					for _, d in ipairs(mapGui:GetChildren()) do
						if d:IsA("ImageButton") and (
							d.Image == 'rbxassetid://'..cityId or
								d.Image == 'rbxassetid://'..townId or
								d.Image == 'rbxassetid://'..cityDisabledId or
								d.Image == 'rbxassetid://'..townDisabledId or
								d.Image == 'rbxassetid://'
							) then
							d:Destroy()
						end
					end
					self:getWeatherForecast(mapGui)
					destroyForecastFrame()
					forecastFrame = Utilities.Write 'Map' {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(1.0, 0, 0.6, 0),
							Position = UDim2.new(0.0, 0, 0.2, 0),
							ZIndex = 10,
							Parent = weather.gui
						},
						Scaled = true,
					}
				else
					if mapGui:FindFirstChild("ForecastContainerW") then
						mapGui.ForecastContainerW:Destroy()
					end
					mapGui.Image = 'rbxassetid://'..mapId
					locationHover()
					destroyForecastFrame()
					forecastFrame = Utilities.Write 'Forecast' {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(1.0, 0, 0.7, 0),
							Position = UDim2.new(0.0, 0, 0.15, 0),
							ZIndex = 10,
							Parent = weather.gui
						},
						Scaled = true,
					}
				end
			end
		}

		forecastFrame = Utilities.Write 'Forecast' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, 0.7, 0),
				Position = UDim2.new(0.0, 0, 0.15, 0),
				ZIndex = 10,
				Parent = weather.gui
			},
			Scaled = true,
		}

		local close = _p.RoundedFrame:new {
			Button = true,
			BackgroundColor3 = BrickColor.new('Deep blue').Color,
			Size = UDim2.new(.31, 0, .08, 0),
			Position = UDim2.new(.85, 0, -.03, 0),
			ZIndex = 9,
			Parent = mapGui,
			MouseButton1Click = function()
				sig:fire()
			end
		}

		Utilities.Write 'Cancel' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, 0.6, 0),
				Position = UDim2.new(0.0, 0, 0.2, 0),
				ZIndex = 10,
				Parent = close.gui
			},
			Scaled = true,
		}

		Utilities.Tween(.8, 'easeOutCubic', function(a)
			bg.BackgroundTransparency = 1 - .3 * a
			container.Position = UDim2.new(.5, 0, .05 + 1 - a, 0)
		end)

		local location = sig:wait()
		if not location then
			spawn(function() _p.Menu.bag:open() end)
		end

		Utilities.Tween(.8, 'easeOutCubic', function(a)
			bg.BackgroundTransparency = .7 + .3 * a
			container.Position = UDim2.new(.5, 0, .05 + a, 0)
		end)

		close:destroy()
		bg:Destroy()
		container:Destroy()
	end

	return map
end