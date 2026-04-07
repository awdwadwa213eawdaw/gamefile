return function(_p)
	local Create = _p.Utilities.Create
	local Terrain = workspace.Terrain
	local RunService = game:GetService("RunService")

	local attachmentParent = Instance.new("Attachment")
	local attachmentPool = {}
	local activeTrails = {}
	local poolActive = false

	local trailTemplate = Create("Trail")({
		Color = ColorSequence.new(Color3.new(1, 1, 1)),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.25, 0.5),
			NumberSequenceKeypoint.new(0.75, 0.75),
			NumberSequenceKeypoint.new(1, 1)
		}),
		WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(0.5, 1),
			NumberSequenceKeypoint.new(1, 1)
		}),
		LightInfluence = 0,
		LightEmission = 0
	})

	local WindEffect = {
		enabled = false,
		windFocus = nil,
	}

	local upVector = Vector3.new(0, 1, 0)
	local rng = Random.new()

	local emitter = Create("ParticleEmitter")({
		Color = ColorSequence.new(Color3.fromRGB(134, 255, 90)),
		LightEmission = 0,
		LightInfluence = 0,
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.2, 0.5),
			NumberSequenceKeypoint.new(0.7, 0.5),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Texture = "rbxassetid://242830579",
		Transparency = NumberSequence.new(0, 1),
		Acceleration = Vector3.new(0, -2, 0),
		EmissionDirection = Enum.NormalId.Front,
		Enabled = false,
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-360, 360),
		SpreadAngle = Vector2.new(0, 0),
		Parent = attachmentParent
	})

	local windAngle = 0
	local noiseOffset = 0
	local timeOffset = 0
	local enabledChunk = nil

	local function getTrailAttachments(worldPos, lifetime)
		local a0, a1

		if #attachmentPool > 0 then
			local pair = table.remove(attachmentPool)
			a0 = pair[1]
			a1 = pair[2]

			a0.WorldPosition = worldPos
			a1.WorldPosition = worldPos
			a0.Parent = Terrain
			a1.Parent = Terrain

			local trail = a0:FindFirstChildOfClass("Trail")
			if trail then
				trail.Lifetime = lifetime
			end
		else
			a0 = Instance.new("Attachment")
			a1 = Instance.new("Attachment")

			a0.WorldPosition = worldPos
			a1.WorldPosition = worldPos
			a0.Parent = Terrain
			a1.Parent = Terrain

			local trail = trailTemplate:Clone()
			trail.Attachment0 = a0
			trail.Attachment1 = a1
			trail.Lifetime = lifetime
			trail.Parent = a0
		end

		return a0, a1
	end

	local function recycleTrailAttachments(a0, a1)
		if not poolActive then
			if a0 then a0:Destroy() end
			if a1 then a1:Destroy() end
			return
		end

		if a0 then a0.Parent = nil end
		if a1 then a1.Parent = nil end
		table.insert(attachmentPool, {a0, a1})
	end

	local function spawnWindTrail(direction, speed)
		local focusPos

		if _p.Overworld.useCameraPosition then
			WindEffect.windFocus = workspace.CurrentCamera.CFrame.Position
		end

		pcall(function()
			focusPos = WindEffect.windFocus or _p.player.Character.HumanoidRootPart.Position
		end)

		if not focusPos then
			return
		end

		local sideways = direction:Cross(upVector) * rng:NextNumber(-150, 150)
		local startPos = focusPos
			+ Vector3.new(0, rng:NextNumber(5, 60), 0)
			- direction * rng:NextNumber(150, 300)
			+ sideways

		if rng:NextInteger(1, 100) <= 40 then
			attachmentParent.CFrame = CFrame.lookAt(startPos, startPos + direction) - sideways * 0.5
			emitter.Speed = NumberRange.new(speed * 0.25, speed * 0.5)
			emitter.Lifetime = NumberRange.new(600 / speed, 1200 / speed)
			emitter.Acceleration = Vector3.new(0, rng:NextNumber(-6, 2), 0)
			emitter:Emit(1)
		end

		local dropOffset = rng:NextNumber(0.4, 0.6)
		local wobbleAmount = rng:NextNumber(0.1, 0.15)
		local wobbleSpeed = rng:NextNumber(1, 4)
		local wobblePhase = rng:NextNumber(0, 2 * math.pi)
		local fadeLifetime = 300 / speed * wobbleAmount + 0.2
		local segmentOffset = Vector3.new(0, -dropOffset, 0)

		local a0, a1 = getTrailAttachments(startPos, fadeLifetime)

		table.insert(activeTrails, {
			startClock = os.clock(),
			state = 1,
			travelDuration = 600 / speed,
			fadeLifetime = fadeLifetime,
			startPos = startPos,
			velocity = direction * speed,
			wobbleAmount = wobbleAmount,
			wobbleSpeed = wobbleSpeed + speed / 150,
			wobblePhase = wobblePhase,
			a0 = a0,
			a1 = a1,
			offset = segmentOffset,
			accumulatedY = 0
		})
	end

	function WindEffect:Clear()
		for i = #activeTrails, 1, -1 do
			local item = activeTrails[i]
			if item.a0 then item.a0:Destroy() end
			if item.a1 then item.a1:Destroy() end
			activeTrails[i] = nil
		end

		for i = #attachmentPool, 1, -1 do
			local pair = attachmentPool[i]
			if pair[1] then pair[1]:Destroy() end
			if pair[2] then pair[2]:Destroy() end
			attachmentPool[i] = nil
		end
	end

	function WindEffect:Enable(direction, p10, p11)
		if self.enabled then
			return
		end

		self.enabled = true

		if direction then
			windAngle = math.atan2(direction.X, direction.Z)
		else
			windAngle = 0
		end

		noiseOffset = p10 or 0
		timeOffset = os.clock() - (p11 or 0)
		enabledChunk = _p.DataManager.currentChunk

		if not poolActive then
			poolActive = true
			attachmentParent.Parent = Terrain

			local lastSpawn = 0

			RunService:BindToRenderStep("loomOverworldWindEffect", Enum.RenderPriority.Last.Value, function()
				local now = os.clock()

				if self.enabled
					and #activeTrails < 50
					and now - lastSpawn > 0.03
					and ((not enabledChunk or not enabledChunk.indoors) and rng:NextInteger(1, 100) <= 17) then
					lastSpawn = now
					local angle = windAngle + 1.2 * math.noise(noiseOffset, (now - timeOffset) * 0.02, 0)
					spawnWindTrail(Vector3.new(math.sin(angle), 0, math.cos(angle)), 150 * rng:NextNumber(1, 1.5))
				end

				local count = #activeTrails
				if count <= 0 then
					if not self.enabled then
						poolActive = false
						RunService:UnbindFromRenderStep("loomOverworldWindEffect")
						attachmentParent.Parent = nil

						for i = #attachmentPool, 1, -1 do
							local pair = attachmentPool[i]
							if pair[1] then pair[1]:Destroy() end
							if pair[2] then pair[2]:Destroy() end
							attachmentPool[i] = nil
						end
					end
					return
				end

				for i = count, 1, -1 do
					local item = activeTrails[i]
					local elapsed = now - item.startClock

					if item.state == 1 then
						if item.travelDuration < elapsed then
							item.state = 2
							item.startClock = item.startClock + item.travelDuration
						else
							item.accumulatedY = item.accumulatedY + item.wobbleAmount * math.sin(item.wobbleSpeed * elapsed + item.wobblePhase)
							local pos = item.startPos + item.velocity * elapsed + Vector3.new(0, item.accumulatedY, 0)
							item.a0.WorldPosition = pos
							item.a1.WorldPosition = pos + item.offset
						end
					elseif item.fadeLifetime < elapsed then
						activeTrails[i] = activeTrails[#activeTrails]
						activeTrails[#activeTrails] = nil
						recycleTrailAttachments(item.a0, item.a1)
					end
				end
			end)
		end
	end

	function WindEffect:Disable(clearImmediately)
		if not self.enabled then
			return
		end

		self.enabled = false

		if clearImmediately then
			self:Clear()
			poolActive = false
			RunService:UnbindFromRenderStep("loomOverworldWindEffect")
			attachmentParent.Parent = nil
		end
	end

	return WindEffect
end