return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local stepped = game:GetService("RunService").RenderStepped
	local lighting = game:GetService("Lighting")
	local player = _p.player
	local camera = game.Workspace.CurrentCamera
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local RunService = game:GetService("RunService")

	local NorthernLights = {
		enabled = false,
		chunk = false,
		cframe = false,
		globalNorthernBeams = {},
		returnedFromDream = false,
		idleTimes = {(60 * 2), (60 * 5)}
	}

	local LightTextures = {
		'7141623030',
	}

	local LightColors = {
		{
			Color3.fromRGB(2, 87, 0),
			Color3.fromRGB(16, 157, 0),
			Color3.fromRGB(29, 255, 0),
			Color3.fromRGB(139, 255, 146),
			Color3.fromRGB(176, 255, 57),
			Color3.fromRGB(227, 255, 21),
			Color3.fromRGB(0, 255, 136),
		},
		{
			Color3.fromRGB(118, 2, 0),
			Color3.fromRGB(255, 70, 76),
			Color3.fromRGB(255, 77, 169),
			Color3.fromRGB(255, 178, 73),
			Color3.fromRGB(155, 44, 104),
			Color3.fromRGB(255, 121, 33),
			Color3.fromRGB(255, 175, 176),
			Color3.fromRGB(255, 242, 0),
		},
		{
			Color3.fromRGB(23, 35, 71),
			Color3.fromRGB(2, 83, 133),
			Color3.fromRGB(14, 243, 197),
			Color3.fromRGB(4, 226, 183),
			Color3.fromRGB(3, 130, 152),
			Color3.fromRGB(1, 82, 104),
			Color3.fromRGB(0, 255, 226),
		}
	}

	local SecondaryColors = {
		Color3.fromRGB(255, 0, 4),
		Color3.fromRGB(255, 141, 0),
		Color3.fromRGB(255, 227, 0),
		Color3.fromRGB(166, 255, 0),
		Color3.fromRGB(24, 255, 0),
		Color3.fromRGB(0, 255, 128),
		Color3.fromRGB(0, 255, 241),
		Color3.fromRGB(0, 144, 255),
		Color3.fromRGB(13, 0, 255),
		Color3.fromRGB(146, 0, 255),
		Color3.fromRGB(247, 0, 255),
		Color3.fromRGB(255, 0, 176),

		Color3.fromRGB(255, 106, 117),
		Color3.fromRGB(255, 176, 96),
		Color3.fromRGB(255, 255, 109),
		Color3.fromRGB(198, 255, 96),
		Color3.fromRGB(157, 255, 153),
		Color3.fromRGB(124, 255, 197),
		Color3.fromRGB(132, 244, 255),
		Color3.fromRGB(122, 196, 255),
		Color3.fromRGB(126, 123, 255),
		Color3.fromRGB(203, 132, 255),
		Color3.fromRGB(252, 125, 255),
		Color3.fromRGB(255, 127, 228),

		{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(Utilities.hexToRGB('#8E0E00'))),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(Utilities.hexToRGB('#1F1C18')))
		},
		{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(Utilities.hexToRGB('#200122'))),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(Utilities.hexToRGB('#6f0000')))
		},
		{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(Utilities.hexToRGB('#ED213A'))),
			ColorSequenceKeypoint.new(.5, Color3.fromRGB(Utilities.hexToRGB('#56ab2f'))),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(Utilities.hexToRGB('#283c86')))
		},
	}

	local function safeDestroy(obj)
		if obj and obj.Destroy then
			obj:Destroy()
		end
	end

	function NorthernLights:returnHome()
		if not self.chunk then
			self.chunk = 'chunk2'
			self.cframe = CFrame.new(-636.162, 84.108, -431.439, 0, 0, 1, 0, 1, 0, -1, 0, 0)
		end

		self.returnedFromDream = true

		local rtHm, cf = self.chunk, self.cframe
		self:transToChunk({
			chunk = rtHm,
			cframe = cf,
			name = 'Unknown Location',
		}, 'chunk92', true)
	end

	function NorthernLights:idleTime(reqTime)
		if not _p.PlayerData.badges[4] then return end

		spawn(function()
			local timer = game.workspace:FindFirstChild('DrowzyTime') or Instance.new("NumberValue")
			timer.Value = reqTime
			timer.Parent = workspace
			timer.Name = "DrowzyTime"

			while self.enabled do
				if not workspace:FindFirstChild("DrowzyTime") then return end

				if _p.Battle.currentBattle or not _p.MasterControl.WalkEnabled or _p.Hoverboard.equipped or _p.Surf.surfing then
					timer.Value = reqTime
				end

				timer.Value = timer.Value - 1
				wait(1)

				if not workspace:FindFirstChild("DrowzyTime") then return end
				local humanoid = _p.Utilities.getHumanoid()
				if humanoid.MoveDirection.X > 0 or humanoid.MoveDirection.X < 0 or humanoid.MoveDirection.Z > 0 or humanoid.MoveDirection.Z < 0 then
					timer.Value = reqTime
				end

				if timer.Value == 0 then
					timer:Destroy()
					if _p.DataManager.currentChunk.id == 'chunk92' then
						self:returnHome()
					else
						self:transToChunk({
							name = 'Between Dreams',
							returnTxt = {
								'You start to feel drowsy...',
								'You feel uneasy. Stand still for 2 mins to wake up',
								'[y/n]would you like to travel to Between Dreams?'
							},
							chunk = 'chunk92',
							cframe = CFrame.new(-16.65, 23.134, -22.46)
						}, _p.DataManager.currentChunk.id, true)
					end
					break
				end
			end
		end)
	end

	function NorthernLights:transToChunk(data, oldChunk, allow)
		local bannedIdle = {chunk65 = true, chunkGSM = true}
		local chunkDialogues = {
			chunk92 = {
				'You start to feel drowsy...',
				'You feel uneasy. Stand still for 2 mins to wake up',
				'[y/n]would you like to travel to Between Dreams?'
			},
			chunkGSM = {
				'The world starts to deform around you.',
				'A Spacial Anomalie has stabalized here. Return to this fracture to go home.',
				'[y/n]Would you like to enter?'
			},
			chunkhallow = {
				'The world around you starts to fade into black...',
				'To return walk into the portal once more.',
				'[y/n]Would you like to enter?'
			},
		}

		local txt = {}
		if chunkDialogues[data.chunk] then
			txt = chunkDialogues[data.chunk]
		else
			txt = {
				'You start to wake up...',
				'You think to yourself, what a strange dream.',
				'[y/n]would you like to travel home?'
			}
		end

		local cam = game.Workspace.CurrentCamera
		_p.MasterControl.WalkEnabled = false
		_p.Menu:disable()

		if not _p.NPCChat:say(txt[3]) and not bannedIdle[oldChunk] then
			self:idleTime((60 * 5))
			_p.MasterControl.WalkEnabled = true
			_p.Menu:enable()
			return
		end

		_p.NPCChat:say(txt[1])
		self.chunk = _p.DataManager.currentChunk.id
		self.cframe = _p.player.Character.HumanoidRootPart.CFrame

		if not data.variant then
			_p.CameraEffect:TweenIntoNL(_p.player.Character.Head, data, true)
		elseif data.variant == 'Warp' then
			_p.CameraEffect:CamDistort(data, _p.player.Character.Head)
		end

		_p.Overworld:enableForcedWeather()

		if oldChunk ~= 'chunk92' and allow then
			if not self.returnHomeBut then
				self.returnHomeBut = create 'Frame' {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, 0, 0, 0),
					Parent = Utilities.gui,
				}

				local cancel = _p.RoundedFrame:new {
					Button = true,
					Size = UDim2.new(1 / 8, 0, 1 / 16, 0),
					Position = UDim2.new(3 / 4, 0, 19 / 20, 0),
					ZIndex = 3,
					BackgroundColor3 = Color3.fromRGB(234, 53, 180),
					Parent = self.returnHomeBut,
					MouseButton1Click = function()
						self.returnHomeBut:Destroy()
						self.returnHomeBut = nil
						self:returnHome()
					end,
				}

				Utilities.Write 'Return' {
					Frame = create 'Frame' {
						Name = 'ButtonText',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(1.0, 0, 0.7, 0),
						Position = UDim2.new(0.0, 0, 0.15, 0),
						Parent = cancel.gui,
						ZIndex = 4,
					},
					Scaled = true,
				}

				spawn(function()
					while self.returnHomeBut do
						wait()
						if _p.Battle.currentBattle then
							cancel.Position = UDim2.new(2, 0, 2, 0)
						else
							cancel.Position = UDim2.new(7 / 8, 0, 14 / 16, 0)
						end
					end
				end)
			end
		end

		cam.CameraType = Enum.CameraType.Custom
		_p.NPCChat:say(txt[2])
		_p.MasterControl.WalkEnabled = true
		_p.Menu:enable()
	end

	function NorthernLights:makeBeam(texture, zoffset, height, Color)
		local part = self.part
		if not part then
			part = create("Part")({
				Name = "Northern",
				Transparency = 1,
				Anchored = true,
				CanCollide = false,
				Size = Vector3.new(0.05, 0.05, 0.05)
			})
			self.part = part
		end

		return create("Beam")({
			Transparency = NumberSequence.new(.75),
			LightEmission = 0,
			LightInfluence = 0,
			Texture = texture,
			TextureLength = 1,
			TextureSpeed = 0.001,
			Color = ColorSequence.new(Color),
			TextureMode = Enum.TextureMode.Stretch,
			CurveSize0 = 0,
			CurveSize1 = 0,
			Segments = 1,
			Width0 = 50000,
			Width1 = 50000,
			ZOffset = zoffset,
			Parent = self.part,
			Attachment0 = create("Attachment")({
				Orientation = Vector3.new(90, 0, 0),
				Position = Vector3.new(-25000, height, 0),
				Parent = self.part
			}),
			Attachment1 = create("Attachment")({
				Orientation = Vector3.new(90, 0, 0),
				Position = Vector3.new(25000, height, 0),
				Parent = self.part
			})
		})
	end

	function NorthernLights:makeStreakBeam(texture, height, Color, width)
		local data = {}
		if texture == "rbxassetid://7141623030" then
			data = {
				mode = Enum.TextureMode.Static,
				length = 650,
				speed = .02,
				trans = {
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(.3, .48),
					NumberSequenceKeypoint.new(.5, .75),
					NumberSequenceKeypoint.new(.7, .5),
					NumberSequenceKeypoint.new(1, 1),
				},
				inverse = true
			}
			width = math.random(2500, 3500)
		else
			data = {
				mode = Enum.TextureMode.Static,
				length = 650,
				speed = .02,
				trans = {
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(.3, .48),
					NumberSequenceKeypoint.new(.5, .75),
					NumberSequenceKeypoint.new(.7, .5),
					NumberSequenceKeypoint.new(1, 1),
				},
				inverse = false
			}
			width = math.random(2500, 3500)
		end

		local beam = create("Beam")({
			Transparency = NumberSequence.new(data.trans),
			LightEmission = 1,
			LightInfluence = 0,
			Texture = texture,
			TextureLength = data.length,
			TextureSpeed = data.speed,
			Color = ColorSequence.new(Color[1]),
			TextureMode = data.mode,
			CurveSize0 = 25000,
			CurveSize1 = 25000,
			Segments = 500,
			Width0 = width,
			Width1 = width - 100,
			ZOffset = 0,
			Parent = self.part,
			Attachment0 = self.lastAttach or create("Attachment")({
				Orientation = Vector3.new(0, 0, -180),
				Position = Vector3.new(math.random(-20000, 20000), height - math.random(-100, 100), math.random(-20000, 20000)),
				Parent = self.part
			}),
			Attachment1 = create("Attachment")({
				Orientation = Vector3.new(0, 0, 180),
				Position = Vector3.new(math.random(-20000, 20000), height - math.random(-100, 100), math.random(-20000, 20000)),
				Parent = self.part
			})
		})

		self.lastAttach = self.lastAttach == beam.Attachment0 and beam.Attachment1 or beam.Attachment0

		if data.inverse then
			local inverse = beam:Clone()
			inverse.TextureSpeed = -0.02
			inverse.TextureLength = 800
			inverse.Parent = self.part
			local Set = SecondaryColors[math.random(1, #SecondaryColors)]
			inverse.Color = self.lastInverseColor or ColorSequence.new(Set)
			self.lastInverseColor = inverse.Color
		end

		return beam
	end

	function NorthernLights:enableNorthernLights(cf)
		if self.enabled then
			return
		end

		self.enabled = true
		self.globalNorthernBeams = {}
		self.lastAttach = nil
		self.lastInverseColor = nil

		local ColorSet = LightColors[math.random(1, #LightColors)]
		self.beamClouds = self:makeBeam("rbxassetid://748176914", 0, 2500, ColorSet[1])

		for i = 1, 2 do
			self.lastAttach = nil
			self.lastInverseColor = nil
			local width = math.random(600, 1200)
			local Color = ColorSet[math.random(1, #ColorSet)]
			local texture = LightTextures[math.random(1, #LightTextures)]
			for num = 1, 2 do
				local height = 2500 + 30
				self.globalNorthernBeams[#self.globalNorthernBeams + 1] = self:makeStreakBeam("rbxassetid://" .. texture, height, {Color, ColorSet}, width)
			end
		end

		local part = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not self.part then
			return
		end

		self.part.Position = (cf or part.Position) + Vector3.new(0, 125, 0)
		_p.DataManager:lockClockTime(0)
		game.Lighting.FogEnd = 100000000
		self.part.Parent = workspace
		self:idleTime((60 * 2))
	end

	function NorthernLights:disableNorthernLights(fadeTime)
		if not self.enabled then
			return
		end

		self.enabled = false

		local cloudPart = _p.DataManager.currentChunk and _p.DataManager.currentChunk.map and _p.DataManager.currentChunk.map:FindFirstChild("Clouds")
		if cloudPart then
			-- _p.Clouds:enable(cloudPart.CFrame)
		else
			if _p.Clouds and _p.Clouds.disable then
				_p.Clouds:disable()
			end
		end

		_p.DataManager:unlockClockTime()

		if self.beamClouds then
			safeDestroy(self.beamClouds)
			self.beamClouds = nil
		end

		if self.globalNorthernBeams then
			for _, beam in pairs(self.globalNorthernBeams) do
				safeDestroy(beam)
			end
		end
		self.globalNorthernBeams = {}

		self.lastAttach = nil
		self.lastInverseColor = nil

		if self.part then
			safeDestroy(self.part)
			self.part = nil
		end
	end

	return NorthernLights
end