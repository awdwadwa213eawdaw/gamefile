return function(_p)
	local Lighting = game:GetService("Lighting")
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")

	local player = Players.LocalPlayer

	local Heat = {
		enabled = false,
		damageConnection = nil,
		renderConnection = nil,
		visualPart = nil,
		emitter = nil,
		colorCorrection = nil,
		bloom = nil,
		sunRays = nil,
		atmosphere = nil,
		forcedClock = false,
	}

	local function getCharacter()
		local char = player.Character
		if not char then return nil end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then return nil end
		return char, hrp, hum
	end

	local function createVisuals(self)
		if self.visualPart then
			return
		end

		local part = Instance.new("Part")
		part.Name = "ExtremeHeatVisual"
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
		part.Size = Vector3.new(1, 1, 1)
		part.Parent = workspace

		local attachment = Instance.new("Attachment")
		attachment.Parent = part

		local emitter = Instance.new("ParticleEmitter")
		emitter.Name = "HeatShimmer"
		emitter.Enabled = false
		emitter.Texture = "rbxassetid://284205403"
		emitter.LightInfluence = 0
		emitter.LightEmission = 0.06
		emitter.Rate = 10
		emitter.Lifetime = NumberRange.new(2.5, 4)
		emitter.Speed = NumberRange.new(0.5, 1.25)
		emitter.Rotation = NumberRange.new(0, 360)
		emitter.RotSpeed = NumberRange.new(0, 0)
		emitter.SpreadAngle = Vector2.new(8, 8)
		emitter.Acceleration = Vector3.new(0, 1.2, 0)
		emitter.Drag = 1

		emitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 4),
			NumberSequenceKeypoint.new(0.5, 6),
			NumberSequenceKeypoint.new(1, 8),
		})

		emitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.94),
			NumberSequenceKeypoint.new(0.5, 0.88),
			NumberSequenceKeypoint.new(1, 1),
		})

		emitter.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 235, 190)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 210, 140)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 180, 110)),
		})

		emitter.Parent = attachment

		self.visualPart = part
		self.emitter = emitter
	end

	local function createLightingEffects(self)
		if not self.colorCorrection then
			local cc = Instance.new("ColorCorrectionEffect")
			cc.Name = "ExtremeHeatColorCorrection"
			cc.Brightness = 0.06
			cc.Contrast = 0.08
			cc.Saturation = -0.02
			cc.TintColor = Color3.fromRGB(255, 225, 170)
			cc.Enabled = false
			cc.Parent = Lighting
			self.colorCorrection = cc
		end

		if not self.bloom then
			local bloom = Instance.new("BloomEffect")
			bloom.Name = "ExtremeHeatBloom"
			bloom.Enabled = false
			bloom.Intensity = 0.3
			bloom.Size = 18
			bloom.Threshold = 0.9
			bloom.Parent = Lighting
			self.bloom = bloom
		end

		if not self.sunRays then
			local rays = Instance.new("SunRaysEffect")
			rays.Name = "ExtremeHeatSunRays"
			rays.Enabled = false
			rays.Intensity = 0.05
			rays.Spread = 0.75
			rays.Parent = Lighting
			self.sunRays = rays
		end

		if not self.atmosphere then
			local atmosphere = Lighting:FindFirstChild("ExtremeHeatAtmosphere")
			if not atmosphere then
				atmosphere = Instance.new("Atmosphere")
				atmosphere.Name = "ExtremeHeatAtmosphere"
				atmosphere.Density = 0.14
				atmosphere.Offset = 0
				atmosphere.Color = Color3.fromRGB(255, 230, 185)
				atmosphere.Decay = Color3.fromRGB(255, 195, 135)
				atmosphere.Glare = 1.0
				atmosphere.Haze = 2
				atmosphere.Parent = Lighting
			end
			self.atmosphere = atmosphere
		end
	end

	local function updateVisualPosition(self)
		if not self.enabled or not self.visualPart then
			return
		end

		local _, hrp = getCharacter()
		if not hrp then
			return
		end

		self.visualPart.Position = hrp.Position + Vector3.new(0, 3, 0)
	end

	function Heat:Enable(config)
		if self.enabled then
			return
		end
		self.enabled = true

		config = config or {}

		local doDamage = config.damage == true
		local damagePerTick = config.damagePerTick or 2
		local damageInterval = config.damageInterval or 2
		local forceDay = config.forceDay ~= false
		local dayClockTime = config.dayClockTime or 13

		createVisuals(self)
		createLightingEffects(self)

		if self.visualPart then
			self.visualPart.Parent = workspace
		end

		if self.emitter then
			self.emitter.Enabled = true
		end
		if self.colorCorrection then
			self.colorCorrection.Enabled = true
		end
		if self.bloom then
			self.bloom.Enabled = true
		end
		if self.sunRays then
			self.sunRays.Enabled = true
		end
		if self.atmosphere then
			self.atmosphere.Parent = Lighting
		end

		if forceDay and _p.DataManager then
			self.forcedClock = true
			pcall(function()
				_p.DataManager:lockClockTime(dayClockTime)
			end)
		end

		updateVisualPosition(self)

		self.renderConnection = RunService.RenderStepped:Connect(function()
			updateVisualPosition(self)
		end)

		if doDamage then
			local lastTick = 0
			self.damageConnection = RunService.Heartbeat:Connect(function()
				local now = os.clock()
				if now - lastTick < damageInterval then
					return
				end

				local _, _, hum = getCharacter()
				if hum and hum.Health > 0 then
					lastTick = now
					hum:TakeDamage(damagePerTick)
				end
			end)
		end
	end

	function Heat:Disable()
		if not self.enabled then
			return
		end
		self.enabled = false

		if self.renderConnection then
			self.renderConnection:Disconnect()
			self.renderConnection = nil
		end

		if self.damageConnection then
			self.damageConnection:Disconnect()
			self.damageConnection = nil
		end

		if self.emitter then
			self.emitter.Enabled = false
		end

		if self.colorCorrection then
			self.colorCorrection.Enabled = false
		end

		if self.bloom then
			self.bloom.Enabled = false
		end

		if self.sunRays then
			self.sunRays.Enabled = false
		end

		if self.atmosphere then
			self.atmosphere.Parent = nil
		end

		if self.forcedClock and _p.DataManager then
			self.forcedClock = false
			pcall(function()
				_p.DataManager:unlockClockTime()
			end)
		end

		if self.visualPart then
			self.visualPart.Parent = nil
		end
	end

	function Heat:Destroy()
		self:Disable()

		if self.visualPart then
			self.visualPart:Destroy()
			self.visualPart = nil
			self.emitter = nil
		end

		if self.colorCorrection then
			self.colorCorrection:Destroy()
			self.colorCorrection = nil
		end

		if self.bloom then
			self.bloom:Destroy()
			self.bloom = nil
		end

		if self.sunRays then
			self.sunRays:Destroy()
			self.sunRays = nil
		end

		if self.atmosphere then
			self.atmosphere:Destroy()
			self.atmosphere = nil
		end
	end

	return Heat
end