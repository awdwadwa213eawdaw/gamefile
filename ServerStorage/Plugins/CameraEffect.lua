return function(_p)
	local cameraEffects = {
		currentEffects = '',
		oldValues = {},
		pushableButtons = false, --Check if in the 7th gym and mechanics are enabled
		Precip = workspace

	}
	local RunService = game:GetService("RunService")
	local camera = workspace.CurrentCamera
	local create = _p.Utilities.Create
	local TweenService = game:GetService('TweenService')

	function cameraEffects:setupBuildingReverb()
		local chunk = _p.DataManager.currentChunk
		if not chunk then return end
		chunk:registerEnterDoorEvent("EffectReverbEnable", function(doorId, state)
			local particles = self.Precip:GetChildren()
			for _, particle in pairs(particles) do
				particle.Enabled = false
			end
		end)
		chunk:registerExitDoorEvent("EffectReverbDisable", function(doorId, state)
			local particles = self.Precip:GetChildren()
			for _, particle in pairs(particles) do
				particle.Enabled = true
			end
		end)
	end
	function cameraEffects:CamAround(rootCF)
		_p.Utilities.Tween(3, "easeInOutSine", function(a)
			camera.CFrame = rootCF * CFrame.new(0, 0, -10) * CFrame.Angles(0, math.rad(180), 0) * CFrame.new(-10 * math.sin(math.pi * a), 1 * a,0) * CFrame.new(0, 0 ,-20 * a) * CFrame.Angles(0, math.rad(-180 * a), 0)
		end)
	end
	local canSound = {
		--6439289406,
		--6978456591,
		406109258,
	}
	local function makeSound(id, vol)
		if not vol then vol = .8 end
		if not id then id = canSound[math.random(1, #canSound)] end
		_p.Utilities.sound(id, vol, nil, 10)
	end
	function cameraEffects:CamDistort(data, rootCF)
		local CurrentCamera = workspace.CurrentCamera
		local oldFOV = CurrentCamera.FieldOfView
		local cam = workspace.CurrentCamera
		_p.CameraShaker:BeginEarthquake(function(cf)
			cam.CFrame = cam.CFrame * cf
		end, 0.2)
		makeSound(data.warpSound)
		_p.Utilities.Tween(1.5, "easeInOutSine", function(a)
			game.Lighting.ColorCorrection.Saturation = .2 - (1.2*a)
			CurrentCamera.FieldOfView = oldFOV - (oldFOV * a)

			delay(.85, function()
				_p.Utilities.fadeGui.BackgroundColor3 = data.Color or Color3.fromRGB(0, 0, 0)
				_p.Utilities.fadeGui.BackgroundTransparency = 1 - a
				--camera.CFrame = rootCF * CFrame.new(0, 0, -10) * CFrame.Angles(0, math.rad(180), 0) * CFrame.new(-10 * math.sin(math.pi * a), 1 * a,0) * CFrame.new(0, 0 ,-20 * a) * CFrame.Angles(0, math.rad(-180 * a), 0)
			end)
		end)
		--do tp here
		_p.Utilities.TeleportToSpawnBox();
		if _p.DataManager.currentChunk.id ~= data['chunk'] then
			_p.DataManager.currentChunk:destroy()
			workspace.Terrain:Clear()
			wait()
			_p.DataManager:loadChunk(data['chunk'])
			_p.Utilities.Teleport(data['cframe'])
		end		
		repeat wait() until _p.Utilities.fadeGui.BackgroundTransparency == 0
		CurrentCamera.CameraType = Enum.CameraType.Custom
		--makeSound(data.warpSound)
		_p.Utilities.Tween(1.5, nil, function(a)
			delay(.85, function()
				game.Lighting.ColorCorrection.Saturation = -1 + (1.2*a)
			end)
			_p.Utilities.fadeGui.BackgroundTransparency = 0 + a
			CurrentCamera.FieldOfView = (oldFOV * a)
		end)
		_p.CameraShaker:EndEarthquake(0.22)
		repeat wait() until _p.Utilities.fadeGui.BackgroundTransparency == 1
	end
	function cameraEffects:shadowVoid(model)
		local human = _p.Utilities.getHumanoid()
		local root = human.Parent.HumanoidRootPart
		local player = _p.player		--Lighting
		--Movement + Camera
		if model then
			local cf = model.MainPrt.Orientation
			local ogY = model.MainPrt.CFrame.Position.Y--:GetBoundingBox()
			local cframe, size = model:GetBoundingBox()
			local pcframe, psize = player.Character:GetBoundingBox()
			local oldY = (pcframe.Position.Y-(psize.Y/2))-(size.Y/2)+.45
			local rotation = model.PrimaryPart.CFrame - model.PrimaryPart.Position
			RunService:BindToRenderStep('MarshadowSus', 200, function()
				model:PivotTo(CFrame.new(Vector3.new(root.Position.X, ogY-.5, root.Position.Z)) * rotation)
			end)
		else
			RunService:UnbindFromRenderStep('MarshadowSus')
		end
		--Finished Loading
	end
	function cameraEffects:Gym7Enter(model)
		local human = _p.Utilities.getHumanoid()
		local root = human.Parent.HumanoidRootPart
		local player = _p.player		--Lighting
		--Movement + Camera
		_p.MasterControl:lockPlayerMovement()
		if model then
			game.Lighting.FogColor = Color3.new(0,0,0)
			game.Lighting.FogStart = 0
			game.Lighting.FogEnd = 0
			--game.SoundService.Sun.Parent = game.Lighting
			RunService:BindToRenderStep('DarknessFader', 200, function()
				if _p.Battle.currentBattle then return end --to keep the battle effects
				camera.CameraType = Enum.CameraType.Scriptable
				local vec = root.Position - Vector3.new(0, 0, 19) 
				local cf = CFrame.new(vec, root.Position) 
				camera.CameraType = Enum.CameraType.Scriptable
				camera.CFrame = cf
				model:PivotTo(CFrame.new(Vector3.new(root.Position.X, root.Position.Y, 1)) * CFrame.Angles(0, math.rad(-90), math.rad(90)))
			end)
		end
		--Finished Loading
		self.pushableButtons = true
	end
	function cameraEffects:Gym7Exit(model)
		--if _p.DataManager.currentChunk == 'gym7' then return end --Change to exit chunk
		self.pushableButtons = false
		--pcall(function() game.Lighting:FindFirstChild('Sun').Parent = game.SoundService end)
		_p.MasterControl:unlockPlayerMovement()
		RunService:UnbindFromRenderStep('DarknessFader')
		--model:Destroy()
		camera.CameraType = Enum.CameraType.Custom
	end

	function cameraEffects:ParticleFollow(particles, Emittype, pos, UID)
		if not UID then UID = 'PRTCL' end
		local human = _p.Utilities.getHumanoid()
		local root = human.Parent.HumanoidRootPart
		local player = _p.player

		if self.currentEffects ~= '' then return end
		local prt = create 'Part' ({
			Name = 'Precip',
			Size = Vector3.new(pos and pos[1] or 250, pos and pos[1] or .2, pos and pos[1] or 250),
			Orientation = Vector3.new(0, 180, 0),
			Transparency = 1,
			CastShadow = false,
			CanCollide = false,
			CanTouch = false,
			Anchored = true,
		})
		self.Precip = prt
		for _, particle in pairs(particles) do
			particle.Parent = prt
			particle.Enabled = true
		end
		if Emittype == 'Above' then
			self.Precip.Position = camera.CoordinateFrame.p + Vector3.new(0, pos and pos[2] or 50, 0)
		elseif Emittype == 'Side' then
			self.Precip.Position = camera.CoordinateFrame.p + Vector3.new(0, 0, 50) --Not added yet
		end
		if game.Workspace.FilteringEnabled == true then --Allows for free cam fixes
			self.Precip.Parent = game.Workspace
		else 
			self.Precip.Parent = camera
		end
		RunService:BindToRenderStep("Precipitation_"..UID, Enum.RenderPriority.Camera.Value, function()
			local CFrame = camera.CoordinateFrame
			if player.Character:FindFirstChild("Torso") then
				if not self.Precip then return end
				self.Precip.Position = CFrame.p + Vector3.new(CFrame.lookVector.x * 50 + player.Character.Torso.Velocity.x, pos and pos[2] or 75, CFrame.lookVector.z * 50 + player.Character.Torso.Velocity.z)
			else
				self.Precip.Position = CFrame.p + Vector3.new(CFrame.lookVector.x * 50, 75, CFrame.lookVector.z * 50)
			end
		end)
		self:setupBuildingReverb()
		self.currentEffects = 'Particle'		
	end
	function cameraEffects:ParticleUnfollow(UID)
		if self.currentEffects ~= 'Particle' then return end
		if not UID then UID = 'PRTCL' end

		RunService:UnbindFromRenderStep("Precipitation_"..UID)
		local chunk = _p.DataManager.currentChunk
		if chunk then
			chunk:registerEnterDoorEvent("EffectReverbEnable", nil)
			chunk:registerExitDoorEvent("EffectReverbDisable", nil)
		end
		self.Precip:Destroy()
		self.Precip = nil
		self.currentEffects = ''
	end
	function cameraEffects:TweenIntoNL(prt, data, leaveScript)
		local character = _p.player.Character
		local playCFrame = character.HumanoidRootPart.CFrame
		local fronton = playCFrame * Vector3.new(2.4, 2.2, -6.8)
		local Position = character.Head.Position
		local CurrentCamera = workspace.CurrentCamera
		CurrentCamera.CameraType = Enum.CameraType.Scriptable
		CurrentCamera.CFrame = CFrame.new(fronton, Position)
		local u42 = 0
		delay(0.2, function()
			_p.Utilities.Tween(3, "easeInOutSine", function(p30)
				local v160
				fronton = playCFrame * CFrame.Angles(0, p30 * 0.7, 0) * Vector3.new(2.4, 2.2, -6.8)
				v160 = CFrame.new(fronton, Position)
				if not (u42 > 0) then
					CurrentCamera.CFrame = v160
					return
				end
				local v161 = v160:Lerp(v160 - v160.Position + (prt.Position - 0.6 * v160.LookVector), u42)
				CurrentCamera.CFrame = CFrame.new(v161.Position, v161.Position + v161.LookVector)
				CurrentCamera.FieldOfView = 70 - u42 * 65
			end, Enum.RenderPriority.Camera.Value)
		end)
		_p.Utilities.Tween(1.5, nil, function(a)
			_p.Utilities.fadeGui.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			_p.Utilities.fadeGui.BackgroundTransparency = 1 - a
			a = a * 1.5
			u42 = math.clamp(a - 0.5, 0, 1)
		end)
		--TP
		_p.Utilities.TeleportToSpawnBox();
		if _p.DataManager.currentChunk.id ~= data['chunk'] then
			_p.DataManager.currentChunk:destroy()
			workspace.Terrain:Clear()
			wait()
			_p.DataManager:loadChunk(data['chunk'])
			_p.Utilities.Teleport(data['cframe'])
		end
		---
		wait(.5)--So play falls
		---
		--CurrentCamera.CFrame = CFrame.new(character.HumanoidRootPart.CFrame * Vector3.new(2.4, 2.2, -6.8), character.Head.Position)
		spawn(function() _p.Utilities.sound(1843130513, .5, nil, 4) end)
		spawn(function() self:CamAround(_p.player.Character:FindFirstChild("HumanoidRootPart").CFrame) end)
		_p.Utilities.Tween(1.5, nil, function(a)
			_p.Utilities.fadeGui.BackgroundTransparency = 0 + a
			CurrentCamera.FieldOfView = 70 * a
		end)

		if not leaveScript then
			CurrentCamera.CameraType = Enum.CameraType.Custom
		end
	end
	return cameraEffects
end