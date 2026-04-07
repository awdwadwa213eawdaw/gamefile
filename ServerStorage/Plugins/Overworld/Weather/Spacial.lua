return function(_p)
	local Utilities = _p.Utilities
	local Create = Utilities.Create
	local RunService = game:GetService("RunService")
	local Lighting = game:GetService("Lighting")
	local blurTime = 1.5
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local MasterControl = _p.MasterControl

	local Camera = game.Workspace.CurrentCamera
	local defaultSaturation = 0.2

	local Spacial = {
		enabled = false,
		isReady = false,
		isLoaded = false,
		UID = "",
		shardEmitter = nil,
		jewelColors = {
			Color3.fromRGB(157, 0, 255),
			Color3.fromRGB(200, 0, 113),
			Color3.fromRGB(226, 0, 0),
			Color3.fromRGB(206, 148, 0),
			Color3.fromRGB(0, 206, 34),
			Color3.fromRGB(85, 255, 255),
			Color3.fromRGB(255, 0, 255),
			Color3.fromRGB(170, 170, 255),
			Color3.fromRGB(0, 0, 0),
			Color3.fromRGB(255, 255, 255)
		}
	}

	local portalData = {
		chunk62 = {
			'chunkGSM',
			CFrame.new(617.934692, 4.79562378, 3273.05176, 0, -0.906308174, 0.4226183, -1, 0, 0, 0, -0.422618508, -0.906307817),
			CFrame.new(310.383545, 136.647949, 1007.17786, 0, -0.995252132, -0.0973398387, -1, 0, 0, 0, 0.0973398387, -0.995251358),
		}
	}

	local players = game:GetService("Players")

	local function safeDestroy(obj)
		if obj and obj.Destroy then
			obj:Destroy()
		end
	end

	local function safeUnbind(name)
		if name and name ~= "" then
			pcall(function()
				RunService:UnbindFromRenderStep(name)
			end)
		end
	end

	local function touchEvent(part, eventFn)
		if not part then
			return
		end

		local cn
		cn = part.Touched:Connect(function(p)
			if not MasterControl.WalkEnabled then return end
			if not p or not p.Parent or players:GetPlayerFromCharacter(p.Parent) ~= _p.player then return end
			if cn then
				cn:Disconnect()
			end
			eventFn()
		end)
	end

	local function lockBehindPlayer(cam, pos)
		local cf = _p.player.Character.HumanoidRootPart
		cam.CameraType = Enum.CameraType.Scriptable
		cam.CFrame = (cf.CFrame - cf.Position) + (pos + (Vector3.new(18, 0, 18) * (cf.CFrame.LookVector - cf.CFrame.LookVector * 2)))
	end

	function Spacial:doWarp()
		_p.MasterControl.WalkEnabled = false
		_p.Menu:disable()

		local currentChunk = _p.DataManager.currentChunk
		if currentChunk and currentChunk.map then
			currentChunk.map:FindFirstChild("TimeSpaceDistortion")
		end

		_p.NPCChat:say(
			"Reality seems to be weakened here.",
			"You should leave quickly before this reality collapses!"
		)
	end

	function Spacial:removePortal()
		local currentChunk = _p.DataManager.currentChunk
		if not currentChunk or currentChunk.id ~= "chunk62" then
			return
		end

		local portal = currentChunk.map and currentChunk.map:FindFirstChild("TimeSpaceDistortion")
		if portal then
			Utilities.sound(7369745305, nil, nil, 5)
			portal:Destroy()
		end
	end

	function Spacial:makePortal()
		local currentChunk = _p.DataManager.currentChunk
		if not self.isReady or not currentChunk or (currentChunk.id ~= "chunk62" and currentChunk.id ~= "chunkGSM") then
			return
		end

		local portal = ReplicatedStorage.Models:FindFirstChild("TimeSpaceDistortion")
		if not portal then
			return
		end

		Utilities.sound(8295269333, nil, nil, 5)

		if not currentChunk.map:FindFirstChild("TimeSpaceDistortion") then
			portal = portal:Clone()
			if portalData[currentChunk.id] and portalData[currentChunk.id][3] then
				portal:PivotTo(portalData[currentChunk.id][3])
			end
			portal.Parent = currentChunk.map
		else
			portal = currentChunk.map:FindFirstChild("TimeSpaceDistortion")
			repeat task.wait() until self.isLoaded

			if not portal or not portal:FindFirstChild("HitBox") or not portal:FindFirstChild("PortalPart") then
				return
			end

			touchEvent(portal.HitBox, function()
				MasterControl.WalkEnabled = false
				MasterControl:Stop()
				_p.RunningShoes:disable()
				_p.Menu:disable()
				lockBehindPlayer(workspace.CurrentCamera, portal.HitBox.Position)
				task.wait(1.75)
				MasterControl:WalkTo(portal.PortalPart.Position)

				local loadTag = {}
				_p.DataManager:setLoading(loadTag, true)

				_p.Overworld.Events:doCameraFlip(_p.player.Character.HumanoidRootPart, Camera)
				_p.Utilities.TeleportToSpawnBox()
				currentChunk:Destroy()
				_p.Overworld:endAllWeather()
				workspace.Terrain:Clear()
				_p.DataManager:loadChunk("chunk62")
				self:makePortal()

				local portal2 = _p.DataManager.currentChunk.map:FindFirstChild("TimeSpaceDistortion")
				if portal2 and portal2:FindFirstChild("HitBox") then
					_p.Utilities.Teleport(portal2.HitBox.CFrame)
					task.wait(0.5)
					lockBehindPlayer(Camera, portal2.HitBox.Position)
				end

				_p.DataManager:setLoading(loadTag, false)
				_p.Overworld.Events:doCameraFlip(_p.player.Character.HumanoidRootPart, Camera, true)

				if portal2 and portal2:FindFirstChild("HitBox") then
					local portalprtSize = portal2.HitBox.Size
					local rotation = portal2.HitBox.CFrame.LookVector
					MasterControl:WalkTo(portal2.HitBox.CFrame + (Vector3.new(portalprtSize.Y + 1, portalprtSize.Y + 1, portalprtSize.Y + 1) * rotation))
				end

				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
				_p.RunningShoes:enable()
				spawn(function() _p.Menu:enable() end)
				MasterControl.WalkEnabled = true
				self.isLoaded = false
			end)

			return
		end

		repeat task.wait() until self.isLoaded == false

		if not portal or not portal:FindFirstChild("HitBox") or not portal:FindFirstChild("PortalPart") then
			return
		end

		touchEvent(portal.HitBox, function()
			MasterControl.WalkEnabled = false
			MasterControl:Stop()
			_p.RunningShoes:disable()
			_p.Menu:disable()
			lockBehindPlayer(workspace.CurrentCamera, portal.HitBox.Position)
			task.wait(1.75)
			MasterControl:WalkTo(portal.PortalPart.Position)

			local loadTag = {}
			_p.DataManager:setLoading(loadTag, true)

			_p.Overworld.Events:doCameraFlip(_p.player.Character.HumanoidRootPart, Camera)
			_p.Utilities.TeleportToSpawnBox()
			currentChunk:Destroy()
			_p.Overworld:endAllWeather()
			workspace.Terrain:Clear()
			_p.DataManager:loadChunk("chunkGSM")

			local portal2 = _p.DataManager.currentChunk.map:FindFirstChild("TimeSpaceDistortion")
			if portal2 and portal2:FindFirstChild("HitBox") then
				_p.Utilities.Teleport(portal2.HitBox.CFrame)
				task.wait(0.5)
				lockBehindPlayer(Camera, portal2.HitBox.Position)
			end

			_p.DataManager:setLoading(loadTag, false)
			_p.Overworld.Events:doCameraFlip(_p.player.Character.HumanoidRootPart, Camera, true)

			if portal2 and portal2:FindFirstChild("HitBox") then
				local portalprtSize = portal2.HitBox.Size
				local rotation = portal2.HitBox.CFrame.LookVector
				MasterControl:WalkTo(portal2.HitBox.CFrame + (Vector3.new(portalprtSize.Y + 1, portalprtSize.Y + 1, portalprtSize.Y + 1) * rotation))
			end

			workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
			_p.RunningShoes:enable()
			spawn(function() _p.Menu:enable() end)
			MasterControl.WalkEnabled = true
			self.isLoaded = true
		end)
	end

	function Spacial:removeSpacial()
		if not self.enabled then
			return
		end

		self.enabled = false

		spawn(function()
			if _p.modelEffects and _p.modelEffects.disableJewel then
				pcall(function()
					_p.modelEffects:disableJewel()
				end)
			end
		end)

		if Lighting:FindFirstChild("ColorCorrectionSpacial") then
			local baseCC = Lighting:FindFirstChild("ColorCorrection")
			if baseCC then
				Utilities.pTween(baseCC, "Saturation", defaultSaturation, blurTime)
			end
			Lighting.ColorCorrectionSpacial:Destroy()
		end

		if Lighting:FindFirstChild("Distortion") then
			local atmo = Lighting:FindFirstChild("Distortion")
			Utilities.pTween(atmo, "Density", 0, blurTime)
			atmo:Destroy()
		end

		spawn(function()
			self:removePortal()
		end)

		safeUnbind("shardEmitter_" .. tostring(self.UID))

		if self.shardEmitter then
			safeDestroy(self.shardEmitter)
			self.shardEmitter = nil
		else
			local emitter = workspace:FindFirstChild("spacialShardEmitter")
			if emitter then
				safeDestroy(emitter)
			end
		end

		self.UID = ""
	end

	function Spacial:setupSpacial()
		if self.enabled then
			return
		end

		self.enabled = true

		local human = _p.Utilities.getHumanoid()
		if not human or not human.Parent or not human.Parent:FindFirstChild("HumanoidRootPart") then
			self.enabled = false
			return
		end

		local root = human.Parent.HumanoidRootPart

		if Lighting:FindFirstChild("ColorCorrection") then
			local defaultCC = Lighting:FindFirstChild("ColorCorrection")
			local clone = defaultCC:Clone()
			clone.Parent = Lighting
			clone.Name = "ColorCorrectionSpacial"
			Utilities.pTween(defaultCC, "Saturation", -1, blurTime)
			Utilities.pTween(clone, "Saturation", -1, blurTime)
		end

		local atmo = Create("Atmosphere")({
			Name = "Distortion",
			Parent = Lighting,
			Color = Color3.fromRGB(40, 0, 60),
			Decay = Color3.fromRGB(0, 0, 0)
		})

		spawn(function()
			Utilities.pTween(atmo, "Density", 0.65, blurTime)
			Utilities.pTween(atmo, "Offset", 0.2, blurTime)
			Utilities.pTween(atmo, "Glare", 0, blurTime)
			Utilities.pTween(atmo, "Haze", 10, blurTime)
		end)

		self.UID = Utilities.uid()

		local part = Create("Part")({
			Name = "spacialShardEmitter",
			Parent = workspace,
			Transparency = 1,
			CanCollide = false,
			Anchored = true,
			Size = Vector3.new(50, 40, 50)
		})
		self.shardEmitter = part

		spawn(function()
			-- self:makePortal()
		end)

		spawn(function()
			if _p.modelEffects and _p.modelEffects.animJewel and part and part.Parent then
				pcall(function()
					_p.modelEffects:animJewel(part, self.jewelColors)
				end)
			end
		end)

		RunService:BindToRenderStep("shardEmitter_" .. self.UID, Enum.RenderPriority.Camera.Value, function()
			if not self.enabled or not part or not part.Parent then
				safeUnbind("shardEmitter_" .. tostring(self.UID))
				return
			end

			if _p.Battle.currentBattle then
				part.Position = Camera.CFrame.Position
			else
				if root and root.Parent then
					part.Position = root.Position
				end
			end
		end)
	end

	return Spacial
end