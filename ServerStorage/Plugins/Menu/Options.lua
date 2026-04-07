return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local write = Utilities.Write

	local options = {
		isOpen = false,
		lastUnstuckTick = 0,
		reduceGraphics = false,
		codesEnabled = true,
		cSpeed = 4,
		tSkip = false,
		IconSFX = false,
		pxSetting = {
			pkmnIcon = true,
			itemIcon = true,
			sprite = true,
		},
		cHints = true,
		currentPage = 1,
		weatherEnabled = true,
	}
	local bg, bg2, fr, overlay, arrowR, arrowL
	local close, unstuckButton, unstuckTimerContainer, CodesTextBox, CodesFrame
	local madePages = false
	local busy = false
	local toggles, dropdowns = {}, {}
	local unstuckCooldown = 5 * 3

	local function color(r, g, b)
		return Color3.new(r/255, g/255, b/255)
	end

	local function unstuckTimer()
		Utilities.fastSpawn(function()
			unstuckTimerContainer:ClearAllChildren()
			local et = tick()-options.lastUnstuckTick
			if et >= unstuckCooldown then
				write 'Ready' {
					Frame = unstuckTimerContainer,
					Scaled = true,
					Color = color(124, 200, 99),
				}
				return
			end
			et = math.floor(et+.5)
			while bg.Parent do
				local t = options.lastUnstuckTick + et + 1
				wait(t-tick())
				unstuckTimerContainer:ClearAllChildren()
				et = math.floor(tick()-options.lastUnstuckTick+.5)
				if et >= unstuckCooldown then
					write 'Ready' {
						Frame = unstuckTimerContainer,
						Scaled = true,
						Color = color(124, 200, 99),
					}
					return
				end
				local rt = unstuckCooldown-et
				local rm = math.floor(rt/60)
				local rs = rt%60
				write(rm..':'..(rs<10 and ('0'..rs) or rs)) {
					Frame = unstuckTimerContainer,
					Scaled = true,
				}
			end
		end)
	end

	local function setupBusyFn(fn)
		return function()
			if busy then return end
			fn()
		end
	end

	local function ThreeDotButton(gui, pos, func)
		write("...")({
			Frame = create("Frame")({
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 0, 0.5, 0),
				Position = UDim2.new(0.5, 0, 0.25, 0),
				ZIndex = 4,
				Parent = _p.RoundedFrame:new({
					Button = true,
					CornerRadiusConstraint = _p.RoundedFrame.CORNER_RADIUS_CONSTRAINT.FRAME,
					CornerRadius = 0.18,
					BackgroundColor3 = Color3.new(0.4, 0.4, 0.4),
					Size = UDim2.new(0.06, 0, 0.06, 0),
					Position = pos,
					ZIndex = 3,
					Parent = gui,
					MouseButton1Click = func and setupBusyFn(func) or nil
				}).gui
			}),
			Scaled = true,
			Color = Color3.new(0.8, 0.8, 0.8)
		})
	end

	local function InfoBox(gui, pos, txt)
		_p.ToolTip:create(create("TextButton")({
			BackgroundTransparency = 1,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(1, 0, 1, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.49, 0, 0.47, 0),
			Font = Enum.Font.Gotham,
			Text = utf8.char(9432),
			TextScaled = true,
			TextColor3 = Color3.new(1, 1, 1),
			ZIndex = 6,
			Parent = _p.RoundedFrame:new({
				CornerRadiusConstraint = _p.RoundedFrame.CORNER_RADIUS_CONSTRAINT.FRAME,
				CornerRadius = 0.18,
				BackgroundColor3 = Color3.new(0.4, 0.4, 0.4),
				Size = UDim2.new(0.06, 0, 0.06, 0),
				Position = pos,
				ZIndex = 3,
				Parent = gui,
			}).gui
		}), txt)
	end

	local function makeTab(size, pos, endPos, parent, fn)
		local tab = create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://11106811143',
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = size,
			Position = endPos,
			Parent = parent,
			ZIndex = 7,
		}

		local function open()
			options:setBusy(true)
			local lerp = Utilities.lerpUDim2(endPos, pos)
			Utilities.Tween(.8, 'easeOutCubic', function(a)
				bg2.BackgroundTransparency = 1-.3*a
				bg.BackgroundTransparency = .7+.3*a
				tab.Position = lerp(a)
			end)
		end

		local function close()
			local lerp = Utilities.lerpUDim2(pos, endPos)
			Utilities.Tween(.8, 'easeOutCubic', function(a)
				bg.BackgroundTransparency = 1-.3*a
				bg2.BackgroundTransparency = .7+.3*a
				tab.Position = lerp(a)
			end)
			options:setBusy(false)
		end

		local cBtn = _p.RoundedFrame:new {
			Button = true,
			BackgroundColor3 = color(1, 1, 0),
			Size = UDim2.new(.31, 0, .08, 0),
			Position = UDim2.new(.65, 0, -.03, 0),
			ZIndex = 8, Parent = tab,
			MouseButton1Click = close,
		}

		write 'Close' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, 0.6, 0),
				Position = UDim2.new(0.0, 0, 0.2, 0),
				Parent = cBtn.gui,
				ZIndex = 9,
			}, Scaled = true,
		}

		fn(tab)

		return {
			gui = tab,
			open = open,
			close = close,
		}
	end

	function options:setLightingForReducedGraphics(isReduced)
		local lighting = game:GetService('Lighting')
		lighting.GlobalShadows = not isReduced
		lighting.Ambient = isReduced and Color3.new(.6, .6, .6) or Color3.new(.3, .3, .3)
		lighting.OutdoorAmbient = isReduced and Color3.new(.75, .75, .75) or Color3.new(.5, .5, .5)
		pcall(function() _p.DataManager.currentChunk:setDay(_p.DataManager.isDay) end)
	end

	function options:getUnstuck(manually)
		if not manually and tick()-self.lastUnstuckTick < unstuckCooldown then return end
		local chunk = _p.DataManager.currentChunk
		_p.Hoverboard:unequip(true)
		if _p.Surf.surfing then
			if chunk.id ~= 'chunk69' then
				_p.Surf:forceUnsurf()
			end
		end
		local cf
		if _p.context == 'battle' then
			local t = math.random()*math.pi*2
			local r = math.random()*40
			cf = CFrame.new(-24.4, 3.5, -206.5) + Vector3.new(math.cos(t)*r, 0, math.sin(t)*r)
		elseif _p.context == 'trade' then
			cf = CFrame.new(10.8, 3.5, 10.1) + Vector3.new(math.random()*40-20, 0, math.random()*40-20)
		else
			if chunk.id == 'mining' then
				cf = CFrame.new(350, 93, -883)
				if manually then
					Utilities.TeleportToSpawnBox()
					chunk:destroy()
					wait(.5)
					_p.DataManager:loadChunk('chunk9')
					wait(.5)
					Utilities.Teleport(cf)
				else
					Utilities.FadeOut(.5, Color3.new(0, 0, 0))
					Utilities.TeleportToSpawnBox()
					chunk:destroy()
					wait(.5)
					_p.DataManager:loadChunk('chunk9')
					wait(.5)
					Utilities.Teleport(cf)
					self.lastUnstuckTick = tick()
					self:fastClose(false)
					wait(.5)
					Utilities.FadeIn(.5)
					_p.MasterControl.WalkEnabled = true
				end
				return
			end
			if chunk.indoors then
				local room = chunk:topRoom()
				local entrance = room.Entrance
				if entrance then
					cf = entrance.CFrame * CFrame.new(0, 3, 3.5) * CFrame.Angles(0, math.pi, 0)
				else
					entrance = room.model:FindFirstChild('ToChunk:'..chunk.id)
					if entrance then
						cf = entrance.CFrame * CFrame.new(0, 0, -5.5)
					end
				end
			else
				local door
				if chunk.id == 'chunk1' then
					door = chunk:getDoor('yourhomef1')
				elseif chunk.id == 'chunk7' then
					cf = CFrame.new(-761, 45.2, -705)
				elseif chunk.id == 'chunk9' then
					door = chunk:getDoor('PokeCenter')
				elseif chunk.id == 'chunk16' then
					cf = CFrame.new(662.3, 9.5, 628.5)
				elseif chunk.id == 'chunk20' then
					cf = CFrame.new(-272.789, 66.969, 590.84)
				elseif chunk.id == 'chunk23' then
					door = chunk:getDoor('C_chunk20')
				elseif chunk.id == 'gym6' then
					cf = CFrame.new(989, 52, 503)
				elseif chunk.id == 'chunk45' then
					cf = CFrame.new(-5086.791, 2007.131, 1738.624)
				elseif chunk.id == 'gym7' then
					door = chunk:getDoor('C_chunk46')
				elseif chunk.id == 'chunk55' then
					door = chunk:getDoor('C_chunk54')
				elseif chunk.id == 'chunk65' then
					cf = CFrame.new(736.754, 9641.552, 7278.048)
				elseif chunk.id == 'chunk74' then
					cf = CFrame.new(-106, 184.117, -1603.9)
				elseif chunk.id == 'chunk75' then
					cf = CFrame.new(352.687, 144.879, 1451.358)
				elseif chunk.id == 'chunk80' then
					cf = CFrame.new(-91.224, 325.377, -744.127)
				elseif chunk.id == 'chunk81' then
					door = chunk:getDoor('C_chunk80|a')
				elseif chunk.id == 'chunk82' then
					door = chunk:getDoor('C_chunk82|a')
				elseif chunk.id == 'chunk83' then
					door = chunk:getDoor('C_chunk80')
				elseif chunk.id == 'chunk84' then
					door = chunk:getDoor('C_chunk80')
				elseif chunk.id == 'chunk85' then
					door = chunk:getDoor('C_chunk80')
				elseif chunk.id == 'chunk86' then
					door = chunk:getDoor('C_chunk80')
				elseif chunk.id == 'chunk87' then
					door = chunk:getDoor('C_chunk86')
				elseif chunk.id == 'chunk88' then
					door = chunk:getDoor('C_chunk82')
				elseif chunk.id == 'gym8' then
					cf = CFrame.new(-342.538, 9.446, 122.843)
				else
					door = chunk:getDoor('PokeCenter')
					if not door then
						local gateNum = 999
						for _, d in pairs(chunk.doors) do
							if d.id:sub(1, 4) == 'Gate' then
								local n = tonumber(d.id:sub(5))
								if n and n < gateNum then
									door = d
									gateNum = n
								end
							end
						end
					end
					if not door then
						print('trying cave doors')
						local caveDoor
						local cdn
						for _, p in pairs(chunk.map:GetChildren()) do
							if p:IsA('BasePart') then
								local id = p.Name:match('^CaveDoor:([^:]+)')
								if id then
									local n
									if id:sub(1, 5) == 'chunk' then
										n = tonumber(id:sub(6))
									end
									print('found cave door:', n or '?')
									if not caveDoor or (not cdn and n) or (cdn and n and n < cdn) then
										print('setting')
										caveDoor = p
										cdn = n
									end
								end
							end
						end
						if caveDoor then
							cf = caveDoor.CFrame * CFrame.new(0, -caveDoor.Size.Y/2+3, -caveDoor.Size.Z-4)
						end
					end
				end
				if door then
					cf = door.CFrame * CFrame.new(0, 0, -5)
				end
			end
		end
		if cf then
			if manually then
				Utilities.Teleport(cf)
			else
				Utilities.FadeOut(.5, Color3.new(0, 0, 0))
				Utilities.Teleport(cf)
				self.lastUnstuckTick = tick()
				self:fastClose(false)
				wait(.5)
				Utilities.FadeIn(.5)
				_p.MasterControl.WalkEnabled = true
			end
		end
	end

	local StarterGui = game:GetService("StarterGui")
	local BindableEvent = create("BindableEvent")({
		Event = function()
			if not _p.MasterControl.WalkEnabled then
				return
			end
			if not (tick() - options.lastUnstuckTick < unstuckCooldown) then
				options:getUnstuck(false)
				return
			end
			StarterGui:SetCore("SendNotification", {
				Title = "Reset Cooldown",
				Text = "Please wait " .. math.ceil(unstuckCooldown - (tick() - options.lastUnstuckTick)) .. " seconds before trying again.",
				Duration = 5
			})
		end
	})

	local function connect()
		return pcall(function()
			StarterGui:SetCore("ResetButtonCallback", BindableEvent)
		end)
	end

	if not connect() then
		delay(5, function()
			while not connect() do
				wait(5)
			end
		end)
	end

	local function getPageXPos(page, cPage)
		if not cPage then cPage = options.currentPage end

		for _, v in pairs({1, -1}) do
			if cPage+v == page then
				return v
			end
		end

		return page == cPage and 0 or 1
	end

	local function updatePagesPos(pages, cPage)
		if #pages >= cPage+1 then
			pages[cPage+1].Position = UDim2.new(getPageXPos(cPage+1), 0, 0, 0)
		end
		if cPage-1 > 0 then
			pages[cPage-1].Position = UDim2.new(getPageXPos(cPage-1), 0, 0, 0)
		end
	end

	function options:setBusy(val)
		busy = val and true or false

		for _, toggle in pairs(toggles) do
			toggle.Enabled = not busy
		end

		for _, dropdown in pairs(dropdowns) do
			dropdown.Enabled = not busy
		end
	end

	function options:makePages()
		if madePages then return end
		madePages = true

		local pages = {
			function(gui)
				local autosaveToggle = _p.ToggleButton:new {
					Size = UDim2.new(0.0, 0, 0.1, 0),
					Position = UDim2.new(0.8, 0, 0.075, 0),
					Value = _p.Autosave.enabled,
					ZIndex = 3, Parent = gui,
				}
				autosaveToggle.ValueChanged:connect(function()
					if autosaveToggle.Value then
						autosaveToggle.Enabled = false
						wait(.2)
						if _p.NPCChat:say('Autosave will save every two minutes, and after completing battles.',
							'It is recommended that you still manually save before leaving the game.',
							'[y/n]Would you like to enable Autosave?') then
							if _p.Menu.willOverwriteIfSaveFlag then
								if _p.NPCChat:say('There is another save file that may be overwritten by Autosave.',
									'[y/n]Would you still like to enable Autosave?') then
									_p.Autosave:enable()
								else
									autosaveToggle:animateToValue(false)
								end
							else
								_p.Autosave:enable()
							end
						else
							autosaveToggle:animateToValue(false)
						end
						autosaveToggle.Enabled = true
					else
						_p.Autosave:disable()
					end
				end)
				table.insert(toggles, autosaveToggle)

				write 'Autosave' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.045, 0),
						Position = UDim2.new(0.05, 0, 0.1, 0),
						ZIndex = 3, Parent = gui,
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
				}

				local reducedGraphicsToggle = _p.ToggleButton:new {
					Size = UDim2.new(0.0, 0, 0.1, 0),
					Position = UDim2.new(0.8, 0, 0.225, 0),
					Value = self.reduceGraphics,
					ZIndex = 3, Parent = gui,
				}
				reducedGraphicsToggle.ValueChanged:connect(function()
					reducedGraphicsToggle.Enabled = false
					local chunk = _p.DataManager.currentChunk
					local v = reducedGraphicsToggle.Value
					self.reduceGraphics = v
					self:setLightingForReducedGraphics(v)
					if not _p.Utilities.isTouchDevice() then
						local grass = _p.DataManager:request({'Grass', chunk.id, v})
						if grass then
							pcall(function() chunk.map[v and 'Grass' or 'MGrass']:Destroy() end)
							grass.Parent = chunk.map
						end
					end
					reducedGraphicsToggle.Enabled = true
				end)
				table.insert(toggles, reducedGraphicsToggle)

				write 'Reduced Graphics' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.045, 0),
						Position = UDim2.new(0.05, 0, 0.25, 0),
						ZIndex = 3, Parent = gui,
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
				}

				write 'Stuck?' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.045, 0),
						Position = UDim2.new(0.05, 0, 0.4, 0),
						ZIndex = 3, Parent = gui,
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
				}
				unstuckButton = _p.RoundedFrame:new {
					Button = true,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.3, 0, 0.375, 0),
					ZIndex = 3, Parent = gui,
					MouseButton1Click = setupBusyFn(function()
						self:getUnstuck()
					end),
				}
				write 'Get Unstuck' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.4, 0, 0.045, 0),
						Position = UDim2.new(0.3, 0, 0.402, 0),
						ZIndex = 4, Parent = gui,
					}, Scaled = true, Color = Color3.new(.8, .8, .8),
				}
				unstuckTimerContainer = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.045, 0),
					Position = UDim2.new(0.825, 0, 0.4, 0),
					ZIndex = 3, Parent = gui,
				}

				write("Follow Privacy")({
					Frame = create("Frame")({
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 0, 0.045, 0),
						Position = UDim2.new(0.05, 0, 0.58, 0),
						ZIndex = 3,
						Parent = gui
					}),
					Scaled = true,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				spawn(function()
					local setting = _p.Network:get("GetFollowPrivacy")
					local privacy_dd = _p.DropDown:new(gui, {
						"Anyone",
						"Friends",
						"No one"
					}, 0.892)
					if setting then
						privacy_dd:setValue(setting)
					end
					privacy_dd:setSize(UDim2.new(0.35, 0, 0.08, 0))
					privacy_dd:setPosition(UDim2.new(0.56, 0, 0.565, 0))
					privacy_dd.changed:connect(function(_, index)
						_p.Network:post("SetFollowPrivacy", index)
					end)
					table.insert(dropdowns, privacy_dd)
				end)

				write("Show Objective")({
					Frame = create("Frame")({
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 0, 0.045, 0),
						Position = UDim2.new(0.05, 0, 0.76, 0),
						ZIndex = 3,
						Parent = gui
					}),
					Scaled = true,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				local obj = _p.Network:get("PDS", "getObj")
				local obj_dd = _p.DropDown:new(gui, {
					"Always",
					"When New",
					"Never"
				}, 0.892)
				obj_dd:setSize(UDim2.new(0.35, 0, 0.08, 0))
				obj_dd:setPosition(UDim2.new(0.56, 0, 0.745, 0))
				obj_dd:setValue(_p.ObjectiveManager.notifPreference + 1, obj)
				obj_dd.changed:connect(function(_, index)
					_p.Network:post("PDS", "setObj", index)
					_p.ObjectiveManager:SetNotificationPreference(index - 1)
				end)
				table.insert(dropdowns, obj_dd)
				ThreeDotButton(gui, UDim2.new(0.925, 0, 0.755, 0), function()
					_p.ObjectiveManager:ViewObjectiveDetails()
				end)
			end,

			function(gui)
				write("Text Speed")({
					Frame = create("Frame")({
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 0, 0.045, 0),
						Position = UDim2.new(0.05, 0, 0.1, 0),
						ZIndex = 3,
						Parent = gui
					}),
					Scaled = true,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				spawn(function()
					local speed_dd = _p.DropDown:new(gui, {
						"0.25x",
						"0.5x",
						"0.75x",
						"Normal",
						"1.25x",
						"1.5x",
						"1.75x",
						"2x",
						"3x",
						"4x",
					}, 0.892)

					if self.cSpeed then
						speed_dd:setValue(self.cSpeed)
					end

					speed_dd:setSize(UDim2.new(0.35, 0, 0.08, 0))
					speed_dd:setPosition(UDim2.new(0.54, 0, 0.085, 0))
					speed_dd.changed:connect(function(_, index)
						self.cSpeed = index
					end)

					table.insert(dropdowns, speed_dd)
				end)

				ThreeDotButton(gui, UDim2.new(0.915, 0, 0.095, 0), function()
					_p.NPCChat:say("A quick brown fox jumps over the lazy dog.")
				end)

				local intr = (Utilities.isTouchDevice() and 'Tap' or 'Click')

				write(intr..' To Skip Text')({
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.045, 0),
						Position = UDim2.new(0.05, 0, 0.25, 0),
						ZIndex = 3, Parent = gui,
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
				})

				local tSkipToggle = _p.ToggleButton:new {
					Size = UDim2.new(0.0, 0, 0.1, 0),
					Position = UDim2.new(0.75, 0, 0.225, 0),
					Value = self.tSkip,
					ZIndex = 3, Parent = gui,
				}

				tSkipToggle.ValueChanged:connect(function()
					self.tSkip = tSkipToggle.Value
				end)

				table.insert(toggles, tSkipToggle)

				InfoBox(gui, UDim2.new(0.915, 0, 0.245, 0), 'If on, when you see dialogue text you can '..string.lower(intr)..' again mid writing animation and skip it.')

				write("Codes:") {
					Frame = create 'Frame' {
						BackgroundTransparency = 1;
						Size = UDim2.new(0, 0, 0.045, 0);
						Position = UDim2.new(0.05, 0, 0.4, 0);
						ZIndex = 3; Parent = gui;
					}; Scaled = true; TextXAlignment = Enum.TextXAlignment.Left;
				}
				CodesFrame = _p.RoundedFrame:new {
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.3, 0, 0.375, 0),
					ZIndex = 3, Parent = gui,
				}
				CodesTextBox = create 'TextBox' {
					BackgroundTransparency = 1,
					TextColor3 = Color3.fromRGB(204, 204, 204);
					TextScaled = true,
					Text = "Enter Code Here!";
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold;
					Size = UDim2.new(0.4, 0, 0.1, 0);
					Position = UDim2.new(0.31, 0, 0.375, 0);
					ZIndex = 4, Parent = gui
				}
				CodesTextBox.FocusLost:connect(setupBusyFn(function()
					if CodesTextBox.Text == '' then CodesTextBox.Text = '' return end
					if not self.codesEnabled then return end
					self.codesEnabled = false

					local chat = _p.NPCChat
					local text = CodesTextBox.Text

					CodesTextBox.TextEditable = false
					CodesTextBox.ClearTextOnFocus = false
					chat:say('Processing...')

					if chat:say('You must save after entering a code.', '[y/n]Would you like to save the game?') then
						if self.willOverwriteIfSaveFlag and not chat:say('There is another save file that will be overwritten.', '[y/n]Are you sure you want to save?') then
							self.codesEnabled = true
							CodesTextBox.TextEditable = true
							CodesTextBox.ClearTextOnFocus = true
							return
						end
						spawn(function() chat:say('[ma]Saving...') end)
						local success = _p.PlayerData:save()
						wait()
						chat:manualAdvance()
						if success then
							Utilities.sound(301970897, nil, nil, 3)
							chat:say('Save successful!')
							self.willOverwriteIfSaveFlag = nil
							local s, r = pcall(function() return _p.Network:get("PDS", "checkCode", text) end)
							if s and r then
								chat:say(r)
							else
								chat:say('ERROR: Please try again later.')
							end
							_p.PlayerData:save()
						else
							chat:say('SAVE FAILED!', 'You were unable to redeem the code.', 'Please try again.')
						end
					end
					wait(2)

					CodesTextBox.TextEditable = true
					CodesTextBox.ClearTextOnFocus = true
					CodesTextBox.Text = "Enter Codes Here!"

					self.codesEnabled = true
				end))

				local tgAll, pxToggle
				pxToggle = _p.ToggleButton:new {
					Size = UDim2.new(0.0, 0, 0.1, 0),
					Position = UDim2.new(0.61, 0, 0.525, 0),
					ZIndex = 3, Parent = gui,
				}

				table.insert(toggles, pxToggle)

				write("Pixelization") {
					Frame = create 'Frame' {
						BackgroundTransparency = 1;
						Size = UDim2.new(0, 0, 0.045, 0);
						Position = UDim2.new(0.05, 0, 0.55, 0);
						ZIndex = 3; Parent = gui;
					}; Scaled = true; TextXAlignment = Enum.TextXAlignment.Left;
				}

				InfoBox(gui, UDim2.new(0.915, 0, 0.545, 0), 'Makes sprites, pokemon and item icons pixlated thus removing the blur and making them HD, '..string.lower(intr)..' on the cog for advanced options.')

				local tab = makeTab(UDim2.new(0.9, 0, 0.7, 0), UDim2.new(0.5, 0, 0.5, 0), UDim2.new(0.5, 0, 1.37, 0), gui, function(tab)
					local tab_toggles = {}
					local pxSetting = self.pxSetting

					local function updateTgs()
						local v = (pxSetting.pkmnIcon or pxSetting.itemIcon or pxSetting.sprite)

						if v ~= pxToggle.Value or v ~= tgAll.Value then
							spawn(function()
								pxToggle:updateAlpha(v and 1 or 0)
								tgAll:animateToValue(v)
							end)
							pxToggle.Value = v
							tgAll.Value = v
						end
					end

					local function setPxVal(name, val)
						self.pxSetting[name] = val and true or false
						updateTgs()
					end

					write 'Pixelization Options' {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.075, 0),
							Position = UDim2.new(0.1, 0, 0.08, 0),
							ZIndex = 7, Parent = tab,
						}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
					}

					tgAll = _p.ToggleButton:new {
						Size = UDim2.new(0.0, 0, 0.1, 0),
						Position = UDim2.new(0.65, 0, 0.225, 0),
						ZIndex = 7, Parent = tab,
					}

					updateTgs()

					local function onAllToggle(val)
						for _, v in pairs(tab_toggles) do
							local t, name = unpack(v)
							if t.Value ~= val then
								spawn(function()
									t:animateToValue(val)
								end)
								self.pxSetting[name] = val and true or false
							end
						end
						updateTgs()
					end

					tgAll.ValueChanged:connect(function()
						onAllToggle(tgAll.Value)
					end)
					pxToggle.ValueChanged:connect(function()
						onAllToggle(pxToggle.Value)
					end)

					write 'Toggle All:' {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.045, 0),
							Position = UDim2.new(0.25, 0, 0.25, 0),
							ZIndex = 7, Parent = tab,
						}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
					}

					local PkmnToggle = _p.ToggleButton:new {
						Size = UDim2.new(0.0, 0, 0.15, 0),
						Position = UDim2.new(0.8, 0, 0.375, 0),
						Value = pxSetting.pkmnIcon,
						ZIndex = 7, Parent = tab,
					}
					PkmnToggle.ValueChanged:connect(function()
						setPxVal("pkmnIcon", PkmnToggle.Value)
					end)
					table.insert(tab_toggles, {PkmnToggle, "pkmnIcon"})

					write 'Poke Icons' {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.07, 0),
							Position = UDim2.new(0.05, 0, 0.4, 0),
							ZIndex = 7, Parent = tab,
						}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
					}

					local ItemToggle = _p.ToggleButton:new {
						Size = UDim2.new(0.0, 0, 0.15, 0),
						Position = UDim2.new(0.8, 0, 0.575, 0),
						Value = pxSetting.itemIcon,
						ZIndex = 7, Parent = tab,
					}
					ItemToggle.ValueChanged:connect(function()
						setPxVal("itemIcon", ItemToggle.Value)
					end)
					table.insert(tab_toggles, {ItemToggle, "itemIcon"})

					write 'Item Icons' {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.07, 0),
							Position = UDim2.new(0.05, 0, 0.6, 0),
							ZIndex = 7, Parent = tab,
						}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
					}

					local SpriteToggle = _p.ToggleButton:new {
						Size = UDim2.new(0.0, 0, 0.15, 0),
						Position = UDim2.new(0.8, 0, 0.775, 0),
						Value = pxSetting.sprite,
						ZIndex = 7, Parent = tab,
					}
					SpriteToggle.ValueChanged:connect(function()
						setPxVal("sprite", SpriteToggle.Value)
					end)
					table.insert(tab_toggles, {SpriteToggle, "sprite"})

					write 'Sprites' {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.07, 0),
							Position = UDim2.new(0.05, 0, 0.8, 0),
							ZIndex = 7, Parent = tab,
						}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
					}
				end)

				create("ImageLabel")({
					BackgroundTransparency = 1,
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.new(0.85, 0, 0.85, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Image = "rbxassetid://11106811143",
					ImageColor3 = Color3.new(0.8, 0.8, 0.8),
					ZIndex = 6,
					Parent = _p.RoundedFrame:new({
						Button = true,
						CornerRadiusConstraint = _p.RoundedFrame.CORNER_RADIUS_CONSTRAINT.FRAME,
						CornerRadius = 0.18,
						BackgroundColor3 = Color3.new(0.4, 0.4, 0.4),
						Size = UDim2.new(0.1, 0, 0.1, 0),
						Position = UDim2.new(0.775, 0, 0.525, 0),
						ZIndex = 3,
						Parent = gui,
						MouseButton1Click = setupBusyFn(tab.open)
					}).gui
				})

				local IconSFXToggle = _p.ToggleButton:new {
					Size = UDim2.new(0.0, 0, 0.1, 0),
					Position = UDim2.new(0.75, 0, 0.675, 0),
					Value = self.IconSFX,
					ZIndex = 3, Parent = gui,
				}
				IconSFXToggle.ValueChanged:connect(function()
					self.IconSFX = IconSFXToggle.Value
				end)
				table.insert(toggles, IconSFXToggle)

				write("Icons SFX") {
					Frame = create 'Frame' {
						BackgroundTransparency = 1;
						Size = UDim2.new(0, 0, 0.045, 0);
						Position = UDim2.new(0.05, 0, 0.7, 0);
						ZIndex = 3; Parent = gui;
					}; Scaled = true; TextXAlignment = Enum.TextXAlignment.Left;
				}

				InfoBox(gui, UDim2.new(0.915, 0, 0.695, 0), 'Enables SFX for icons, such as shiny pokemon icons having sparkles.')

				local chatHintsToggle = _p.ToggleButton:new {
					Size = UDim2.new(0.0, 0, 0.1, 0),
					Position = UDim2.new(0.75, 0, 0.825, 0),
					Value = self.cHints,
					ZIndex = 3, Parent = gui,
				}
				chatHintsToggle.ValueChanged:connect(function()
					self.cHints = chatHintsToggle.Value
				end)
				table.insert(toggles, chatHintsToggle)

				write("Chat Hints") {
					Frame = create 'Frame' {
						BackgroundTransparency = 1;
						Size = UDim2.new(0, 0, 0.045, 0);
						Position = UDim2.new(0.05, 0, 0.85, 0);
						ZIndex = 3; Parent = gui;
					}; Scaled = true; TextXAlignment = Enum.TextXAlignment.Left;
				}

				InfoBox(gui, UDim2.new(0.915, 0, 0.845, 0), 'Toggles the blue hint messages in your chat, doesn\'t remove already existing messages only disables new ones from appearing.')
			end,

			function(gui)
				write("Battle Style")({
					Frame = create("Frame")({
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 0, 0.045, 0),
						Position = UDim2.new(0.05, 0, 0.12, 0),
						ZIndex = 3,
						Parent = gui
					}),
					Scaled = true,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				spawn(function()
					local bmode = _p.Network:get("PDS", "getBMode")
					local bmode_dd = _p.DropDown:new(gui, {
						"Shift",
						"Set",
					}, 0.892)

					if bmode then
						bmode_dd:setValue(bmode)
					end

					bmode_dd:setSize(UDim2.new(0.35, 0, 0.08, 0))
					bmode_dd:setPosition(UDim2.new(0.54, 0, 0.105, 0))
					bmode_dd.changed:connect(function(_, index)
						_p.Network:post("PDS", "setBMode", index)
					end)

					table.insert(dropdowns, bmode_dd)
				end)

				InfoBox(gui, UDim2.new(0.915, 0, 0.115, 0), "After you KO your opponent's Pokemon:\n\nShift - You are told what Pokemon your opponent will send out, and you are given the option to switch out to the option of your choice.\n\nSet - You don't get the option to switch.")

				write("Weather FX")({
					Frame = create("Frame")({
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 0, 0.045, 0),
						Position = UDim2.new(0.05, 0, 0.33, 0),
						ZIndex = 3,
						Parent = gui
					}),
					Scaled = true,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				local weatherToggle = _p.ToggleButton:new {
					Size = UDim2.new(0.0, 0, 0.1, 0),
					Position = UDim2.new(0.75, 0, 0.305, 0),
					Value = self.weatherEnabled,
					ZIndex = 3, Parent = gui,
				}
				weatherToggle.ValueChanged:connect(function()
					weatherToggle.Enabled = false
					self.weatherEnabled = weatherToggle.Value
					weatherToggle.Enabled = true
				end)
				table.insert(toggles, weatherToggle)

				InfoBox(gui, UDim2.new(0.915, 0, 0.325, 0), 'Toggles weather effects like rain, snow, and other visual weather particles.')
			end,
		}

		local uis = {}

		if self.currentPage > #pages then
			self.currentPage = 1
		end

		for i, fn in pairs(pages) do
			local pageBg = create 'Frame' {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(getPageXPos(i), 0, 0, 0),
				Parent = fr,
			}

			write("Page "..i.. "/"..#pages)({
				Frame = create("Frame")({
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 0.02, 0),
					Position = UDim2.new(0.45, 0, 0.95, 0),
					ZIndex = 3,
					Parent = pageBg
				}),
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Left
			})

			fn(pageBg)
			table.insert(uis, pageBg)
		end

		return uis
	end

	function options:setPage(index)
	end

	function options:open()
		if self.isOpen or not _p.MasterControl.WalkEnabled then return end
		self.isOpen = true

		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		spawn(function() _p.Menu:disable() end)

		local function doArrowHover(arrow)
			arrow.MouseEnter:connect(function()
				arrow.Size = UDim2.new(0.29, 0, 0.39, 0)
			end)
			arrow.MouseLeave:connect(function()
				arrow.Size = UDim2.new(0.25, 0, 0.35, 0)
			end)
		end

		if not fr then
			bg = create 'Frame' {
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(0, 0, 0),
				Size = UDim2.new(1.0, 0, 1.0, 36),
				Position = UDim2.new(0.0, 0, 0.0, -36),
			}

			bg2 = bg:Clone()
			bg2.BackgroundTransparency = 1
			bg2.ZIndex = 6

			fr = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://11106811143',
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				AnchorPoint = Vector2.new(0.5, 0),
				Size = UDim2.new(0.9, 0, 0.9, 0),
				Position = UDim2.new(0.5, 0, 1.03, 0),
				ClipsDescendants = true,
				ZIndex = 2,
			}

			overlay = create 'Frame' {
				BackgroundTransparency = 1,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				AnchorPoint = Vector2.new(0.5, 0),
				Size = UDim2.new(0.9, 0, 0.9, 0),
				Position = UDim2.new(0.5, 0, 1.03, 0),
			}

			arrowR = create("ImageButton")({
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Position = UDim2.new(0.88, 0, 0.5, 0),
				Size = UDim2.new(0.25, 0, 0.35, 0),
				Image = "rbxassetid://16680956871",
				Parent = overlay
			})

			arrowL = arrowR:Clone()
			arrowL.Position = UDim2.new(0.12, 0, 0.5, 0)
			arrowL.Rotation = 180
			arrowL.Parent = overlay

			for _, arrow in pairs({arrowR, arrowL}) do
				doArrowHover(arrow)
			end

			close = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = color(1, 1, 0),
				Size = UDim2.new(.31, 0, .08, 0),
				Position = UDim2.new(.65, 0, -.03, 0),
				ZIndex = 3, Parent = overlay,
			}

			write 'Close' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.6, 0),
					Position = UDim2.new(0.0, 0, 0.2, 0),
					Parent = close.gui,
					ZIndex = 4,
				}, Scaled = true,
			}

			_p.DataManager:preload("Image", 15242595572)

			local pages = self:makePages()

			arrowR.MouseButton1Click:connect(setupBusyFn(function()
				if self.currentPage+1 > #pages then return end

				self:setBusy(true)
				updatePagesPos(pages, self.currentPage)

				local oldUi = pages[self.currentPage]
				local newUi = pages[self.currentPage+1]

				Utilities.Tween(.8, 'easeOutCubic', function(a)
					oldUi.Position = UDim2.new(-1*a, 0, 0, 0)
					newUi.Position = UDim2.new(1-1*a, 0, 0, 0)
				end)

				self.currentPage += 1
				self:setBusy(false)
			end))

			arrowL.MouseButton1Click:connect(setupBusyFn(function()
				if self.currentPage-1 < 1 then return end

				self:setBusy(true)
				updatePagesPos(pages, self.currentPage)

				local oldUi = pages[self.currentPage]
				local newUi = pages[self.currentPage-1]

				Utilities.Tween(.8, 'easeOutCubic', function(a)
					oldUi.Position = UDim2.new(1*a, 0, 0, 0)
					newUi.Position = UDim2.new(-1+1*a, 0, 0, 0)
				end)

				self.currentPage -= 1
				self:setBusy(false)
			end))

			close.gui.MouseButton1Click:connect(function()
				self:close()
			end)
		end

		bg.Parent = Utilities.gui
		bg2.Parent = Utilities.gui
		fr.Parent = Utilities.gui
		overlay.Parent = Utilities.gui

		close.CornerRadius = Utilities.gui.AbsoluteSize.Y*.015
		unstuckButton.CornerRadius = Utilities.gui.AbsoluteSize.Y*.02

		unstuckTimer()

		Utilities.Tween(.8, 'easeOutCubic', function(a)
			if not self.isOpen then return false end
			bg.BackgroundTransparency = 1-.3*a
			fr.Position = UDim2.new(0.5, 0, 1.03-(1.03-0.05)*a, 0)
			overlay.Position = fr.Position
			arrowR.Position = UDim2.new(0.88+(1.2-0.88)*a, 0, 0.5, 0)
			arrowL.Position = UDim2.new(0.12+(-0.2-0.12)*a, 0, 0.5, 0)
		end)
	end

	function options:close()
		if not self.isOpen then return end
		self.isOpen = false

		spawn(function() _p.Menu:enable() end)

		Utilities.Tween(.8, 'easeOutCubic', function(a)
			if self.isOpen then return false end
			bg.BackgroundTransparency = .7+.3*a
			fr.Position = UDim2.new(0.5, 0, 0.05+(1.03-0.05)*a, 0)
			overlay.Position = fr.Position
			arrowR.Position = UDim2.new(1.2-(1.2-0.88)*a, 0, 0.5, 0)
			arrowL.Position = UDim2.new(-0.2+(0.2+0.12)*a, 0, 0.5, 0)
		end)

		bg.Parent = nil
		fr.Parent = nil
		overlay.Parent = nil

		_p.MasterControl.WalkEnabled = true
	end

	function options:fastClose(enableWalk)
		if not self.isOpen then return end
		self.isOpen = false

		spawn(function() _p.Menu:enable() end)

		bg.BackgroundTransparency = 1.0
		fr.Position = UDim2.new(0.5, 0, 1.03, 0)
		overlay.Position = fr.Position
		arrowR.Position = UDim2.new(0.88, 0, 0.5, 0)
		arrowL.Position = UDim2.new(0.12, 0, 0.5, 0)
		bg.Parent = nil
		fr.Parent = nil
		overlay.Parent = nil

		_p.MasterControl.WalkEnabled = enableWalk and true or false
	end

	return options
end