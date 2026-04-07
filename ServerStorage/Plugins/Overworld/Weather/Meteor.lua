return function(_p)
	local Utilities = _p.Utilities
	local Create = Utilities.Create
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Max_Rocks = 9999
	local tries = 0
	local SFXTable = {{ --Red
		MainColor = Color3.fromRGB(255, 58, 24), 
		FragmentRockColor = Color3.fromRGB(75, 75, 75), 
		FragmentGlowColor = Color3.fromRGB(179, 56, 58), 
		SmokeColor = Color3.fromRGB(171, 61, 39)
	}, 
	{--Blue
		MainColor = Color3.fromRGB(35, 167, 255), 
		FragmentRockColor = Color3.fromRGB(91, 103, 129), 
		FragmentGlowColor = Color3.fromRGB(0, 124, 207), 
		SmokeColor = Color3.fromRGB(37, 124, 171)
	}, 
	{--Green
		MainColor = Color3.fromRGB(80, 230, 110), 
		FragmentRockColor = Color3.fromRGB(79, 81, 129), 
		FragmentGlowColor = Color3.fromRGB(150, 235, 0), 
		SmokeColor = Color3.fromRGB(103, 171, 40)
	}, 
	{--Purple
		MainColor = Color3.fromRGB(131, 90, 255), 
		FragmentRockColor = Color3.fromRGB(139, 155, 165), 
		FragmentGlowColor = Color3.fromRGB(141, 0, 192), 
		SmokeColor = Color3.fromRGB(112, 44, 171)
	},
	{--Pink
		MainColor = Color3.fromRGB(255, 111, 207), 
		FragmentRockColor = Color3.fromRGB(139, 155, 165), 
		FragmentGlowColor = Color3.fromRGB(128, 0, 64), 
		SmokeColor = Color3.fromRGB(255, 0, 128)
	}
	}
	local v5 = { {
		FragmentRockColor = Color3.fromRGB(47, 47, 47), 
		FragmentGlowColor = Color3.fromRGB(255, 255, 255)
	}, {
		FragmentRockColor = Color3.fromRGB(245, 245, 245), 
		FragmentGlowColor = Color3.fromRGB(13, 13, 13), 
		FragmentGlowParticles0LightEmission = true
	} }
	local Meteor = {
		enabled = false
	}
	local ChunkData = {
		chunk48 = 5.2740903539559 --math.rad()
	}
	local u2 = Color3.new(1, 1, 1)
	local shootingstar = ReplicatedStorage.Models.Misc.shootingstar
	local u4 = Vector3.new(1, 0, 1)
	local u5 = nil
	local u6 = Random.new()
	local u7 = SFXTable[1]
	local function u8(p2, p3)
		local Part = p2.Part1
		local v8 = ColorSequence.new(p3)
		Part.ColorCore.Color = v8
		Part.Particles.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, u2), ColorSequenceKeypoint.new(0.35, p3), ColorSequenceKeypoint.new(1, p3) })
		Part.Trail.Color = v8
		Part.Trail2.Color = v8
		p2.Part2.Particles2.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, u2), ColorSequenceKeypoint.new(0.65, u2), ColorSequenceKeypoint.new(1, p3) })
	end
	local function u9(p4)
		if not p4 then
			local currentChunk = _p.DataManager.currentChunk
			if currentChunk then
				p4 = currentChunk.id
			end
		end
		local random = math.rad(math.random(1,360))
		--warn(random)
		local v10 = ChunkData[p4] or random 
		return Vector3.new(-math.sin(v10), 0, -math.cos(v10))
	end
	local u10 = false
	local RunService = game:GetService("RunService")
	local function u12()
		coroutine.wrap(function()
			local v11 = shootingstar:Clone()
			local u13 = nil
			local CurrentCamera = workspace.CurrentCamera
			pcall(function()
				if not _p.Battle.currentBattle then
					u13 = _p.player.Character.HumanoidRootPart.Position
					return
				end
				u13 = _p.Battle.currentBattle.CoordinateFrame1.Position + (CurrentCamera.CFrame.LookVector * u4).Unit * 100 + Vector3.new(0, -50, 0)
			end)
			if not u13 then
				return
			end
			local Unit = (u5 + Vector3.new(0, u6:NextNumber(-0.2, -0.4), 0)).Unit
			local v13 = u13 + Vector3.new(u6:NextNumber(-200, 200), 150, u6:NextNumber(-200, 200)) - Unit * 250
			CFrame.new(v13)
			CFrame.new(v13)
			v11.Parent = game.Workspace.Particles--_p.Particles.folder
			local u15 = -Unit
			local Part1 = v11.Part1
			local Part2 = v11.Part2
			local u18 = true
			local u19 = true
			Utilities.Tween(6, nil, function(p5)
				local v14 = v13 + Unit * (500 * p5)
				local v15 = CFrame.fromMatrix(v14, u15, (v14 - CurrentCamera.CFrame.Position).Unit:Cross(u15).Unit)
				Part1.CFrame = v15
				Part2.CFrame = v15
				if p5 < 0.1 then
					local v16 = NumberSequence.new(1 - p5 / 0.1)
					Part1.Trail.Transparency = v16
					Part1.Trail2.Transparency = v16
					Part1.WhiteTrail.Transparency = v16
					Part1.ColorCore.Transparency = v16
					Part1.WhiteCore.Transparency = v16
					return
				end
				if not (p5 > 0.8) then
					if u19 then
						u19 = false
						local v17 = NumberSequence.new(0)
						Part1.Trail.Transparency = v17
						Part1.Trail2.Transparency = v17
						Part1.WhiteTrail.Transparency = v17
						Part1.ColorCore.Transparency = v17
						Part1.WhiteCore.Transparency = v17
					end
					return
				end
				if u18 then
					Part1.Particles.Enabled = false
					Part2.Particles2.Enabled = false
					u18 = false
				end
				local v18 = NumberSequence.new((p5 - 0.8) / 0.2)
				Part1.Trail.Transparency = v18
				Part1.Trail2.Transparency = v18
				Part1.WhiteTrail.Transparency = v18
				Part1.ColorCore.Transparency = v18
				Part1.WhiteCore.Transparency = v18
			end)
			v11:Destroy()
		end)()
	end
	function Meteor:Enable(p7)
		if self.enabled then
			return
		end
		self.enabled = true
		if p7 then
			u7 = SFXTable[p7]
		end
		u8(shootingstar, u7.MainColor)
		pcall(function()
			--_p.DataManager.currentChunk.map.MeteorSite.Meteor.Front_12.Color = u7.ShopEyeBorderColor
		end)
		u5 = u9()
		if not u10 then
			u10 = true
			local u20 = os.clock()
			RunService:BindToRenderStep("LegacyOverworldMeteorEffect", Enum.RenderPriority.Last.Value, function()
				if u20 < os.clock() then
					u20 = os.clock() + u6:NextNumber(0.4, 2)
					u12()
				end
			end)
		end
	end
	function Meteor:Disable()
		if not self.enabled then
			return
		end
		self.enabled = false
		if u10 then
			u10 = false
			RunService:UnbindFromRenderStep("LegacyOverworldMeteorEffect")
		end
	end
	function Meteor:OnInteractWithMeteor(p11)
		if not _p.MasterControl.WalkEnabled or not _p.Menu.enabled then
			return
		end
		if _p.PlayerData.completedEvents.DeoxysBattle then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		_p.Menu:disable()
		spawn(function()
			_p.MasterControl:LookAt(p11.Main.Position)
		end)
		Utilities.pTween(p11.Main, "Color", Color3.fromRGB(255, 128, 0), 0.4, "easeInOutQuad")
		task.wait(.55)
		Utilities.pTween(p11.Main, "Color", Color3.fromRGB(149, 115, 115), 0.4, "easeInOutQuad")
		_p.NPCChat:say("...")
		_p.NPCChat:say("A weird aura can be felt!")
		_p.NPCChat:say("It sounds like there is a Pokemon inside. Maybe I should try breaking it open?")
		local smasher, rm, enc, done
		Utilities.fastSpawn(function()
			smasher, rm, enc = _p.Network:get('PDS', 'getSmasher')
			done = true
		end)
		while not done do task.wait() end
		if not smasher or not rm or not _p.NPCChat:say('[y/n]Would you like ' .. smasher .. ' to use Rock Smash?') then
			_p.MasterControl.WalkEnabled = true
			_p.Menu:enable()
			return
		end
		tries += 1
		if tries <= 5 then 
			if tries == 4 then
				p11.ImpactParticle.ParticleEmitter:Emit(25)
				Utilities.sound(2162237743, 6, 0.99, 1).PlaybackSpeed = 0.7
				_p.NPCChat:say("The Meteorite broke open!")
			elseif tries == 3 then
				p11.ImpactParticle.ParticleEmitter:Emit(25)
				Utilities.sound(2162237743, 6, 0.99, 1).PlaybackSpeed = 0.7
				_p.NPCChat:say("The Meteorite craked more.",
					"A Creature can be seen inside!")
				_p.MasterControl.WalkEnabled = true
				_p.Menu:enable()
				return
			elseif tries <= 2 then
				p11.ImpactParticle.ParticleEmitter:Emit(25)
				Utilities.sound(2162237743, 6, 0.99, 1).PlaybackSpeed = 0.7
				_p.NPCChat:say("The Meteorite started to crack!")	
				_p.MasterControl.WalkEnabled = true
				_p.Menu:enable()
				return
			end		 
		end
		--wait(2)
		p11:Destroy()
		--_p.Battle._SpriteClass:playCry(1, _p.DataManager:getSprite('_FRONT', 'Deoxys').cry)
		_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Deoxys2, {musicId = 71567023146130, musicVolume = 4})					
		_p.MasterControl.WalkEnabled = true
		_p.Menu:enable()
	end
	--_p.Network:bindEvent("bigCrash", function(p12, p13)
	function Meteor:bigCrash(p12, p13, p14, model)
		--if not self.rng then
		--	self.rng = math.random(1,100)
		--end
		--if self.rng <= 99 then return end
		local currentChunk = _p.DataManager.currentChunk
		if currentChunk and currentChunk.id == p12 then
			pcall(function()
				currentChunk.map:FindFirstChild("MeteorSite"):Destroy()
				for _, v in pairs(currentChunk.map.CrashSite1.Meteor1.Crash:GetDescendants()) do
					v.Transparency = 1
					v.CanCollide = false
					v.CanTouch = false
				end
			end)
			local v20 = model or ReplicatedStorage.Models.Misc.MeteorSite:Clone()--p14--_p.DataManager:getModel("MeteorSites", p12)
			
			if v20 then
				v20.Name = "MeteorSite"
				if p13 then
					u7 = SFXTable[(p13 and 0) + 1]
				end
				local v21 = u9(p12)
				local v22 = math.rad(35)
				local v23 = Vector3.new(v21.X * math.sin(v22), -math.cos(v22), v21.Z * math.sin(v22))
				local Collision = v20.Collision
				Collision.Parent = nil
				local l__Meteor__25 = v20.Meteor
				--l__Meteor__25.Front_12.Color = u7.ShopEyeBorderColor
				local Main = l__Meteor__25.Main
				--_p.ModelEffect:RadiantJewel_AddModel(Main, 1)
				--_p.ModelEffect:AddGalaxyParticle(Main, 1, 2)
				local FallingParticles = Main.CenterAttachment.FallingParticles
				local v28 = Color3.fromRGB(72, 72, 72)
				FallingParticles.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, u7.SmokeColor), ColorSequenceKeypoint.new(0.25, v28), ColorSequenceKeypoint.new(1, v28) })
				FallingParticles.Enabled = true
				local v29 = Utilities.GetModelMover(Main)
				local CFrame = Main.CFrame
				local v34 = CFrame - v23 * 306.45
				v29(v34)
				v20.Parent = currentChunk.map
				Utilities.Tween(2.7, nil, function(p14, p15)
					v29(v34 + v23 * (100 * p15 + 5 * p15 * p15))
				end)
				v29(CFrame)
				local v35 = nil
				local v36 = nil
				local Player = _p.player
				v35 = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
				v36 = Utilities.getHumanoid()
				if v35 and (v35.Position - CFrame.Position).Magnitude < 20 then
					if v36 then
						v36:ChangeState(Enum.HumanoidStateType.Ragdoll)
					end
					v35.Velocity = 90 * ((v35.Position - CFrame.Position).Unit + Vector3.new(0, 0.4, 0)).Unit
					v35.RotVelocity = 30 * Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5)	
					spawn(function()
						local win = _p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Deoxys, {cantRun = true, cantUseBag = true, battleSceneType = 'Valley', musicId = 71567023146130, musicVolume = 4})					
						if win then 
							_p.NPCChat:say("Deoxys fled back into the Meteorite!")	
						end
					end)
				end
				v20.ImpactParticle.ParticleEmitter:Emit(25)
				FallingParticles.Enabled = false
				Main.Parent = v20
				for _, v in pairs(currentChunk.map.CrashSite1.Meteor1.Crash:GetDescendants()) do
					v.Transparency = 0
					v.CanCollide = true
					v.CanTouch = true
				end
			end
		end
	end
	local collectionOfRocks = 0
	function Meteor:smallCrash(p17, p18, p19, p20)
		--_p.Network:bindEvent("smallCrash", function(p17, p18, p19, p20)
		--if collectionOfRocks >= Max_Rocks then return end
		collectionOfRocks += 1
		local currentChunk = _p.DataManager.currentChunk
		if currentChunk and currentChunk.id == p17 then --change
			local v43 = shootingstar:Clone()
			local Part1 = v43.Part1
			local Part2 = v43.Part2
			local v46 = u9(p17)
			local v47 = math.rad(35)
			local v48 = Vector3.new(v46.X * math.sin(v47), -math.cos(v47), v46.Z * math.sin(v47))
			local v49 = p18 - v48 * 250
			Part1.CFrame = CFrame.new(v49)
			Part2.CFrame = CFrame.new(v49)
			v43.Parent = game.Workspace.Particles--_p.Particles.folder
			local CurrentCamera = workspace.CurrentCamera
			local u22 = -v48
			local u23 = true
			local u24 = true
			Utilities.Tween(3, nil, function(p21)
				local v50 = v49 + v48 * (250 * p21)
				local v51 = CFrame.fromMatrix(v50, u22, (v50 - CurrentCamera.CFrame.Position).Unit:Cross(u22).Unit)
				Part1.CFrame = v51
				Part2.CFrame = v51
				if p21 < 0.1 then
					local v52 = NumberSequence.new(1 - p21 / 0.1)
					Part1.Trail.Transparency = v52
					Part1.Trail2.Transparency = v52
					Part1.WhiteTrail.Transparency = v52
					Part1.ColorCore.Transparency = v52
					Part1.WhiteCore.Transparency = v52
					return
				end
				if not (p21 > 0.8) then
					if u24 then
						u24 = false
						local v53 = NumberSequence.new(0)
						Part1.Trail.Transparency = v53
						Part1.Trail2.Transparency = v53
						Part1.WhiteTrail.Transparency = v53
						Part1.ColorCore.Transparency = v53
						Part1.WhiteCore.Transparency = v53
					end
					return
				end
				if u23 then
					Part1.Particles.Enabled = false
					Part2.Particles2.Enabled = false
					u23 = false
				end
				local v54 = NumberSequence.new((p21 - 0.8) / 0.2)
				Part1.Trail.Transparency = v54
				Part1.Trail2.Transparency = v54
				Part1.WhiteTrail.Transparency = v54
			end)
			Part1.Trail:Destroy()
			Part1.Trail2:Destroy()
			local v55 = p20 and v5[p20] or u7
			local v56 = ReplicatedStorage.Models.Misc.starfrag:Clone()
			Utilities.MoveModel(v56.Main, CFrame.new(p18) * CFrame.Angles(math.random() * 6.28, math.random() * 6.28, math.random() * 6.28))
			v56.Main.Color = v55.FragmentRockColor
			v56.Glow.Color = v55.FragmentGlowColor
			v56.Glow.ParticleAttachment.WorldCFrame = CFrame.new(v56.Glow.Position + Vector3.new(0, 3.4, 0))
			v56.Glow.ParticleAttachment.ParticleEmitter.Color = ColorSequence.new(v55.FragmentGlowColor)
			if v55.FragmentGlowParticles0LightEmission then
				v56.Glow.ParticleAttachment.ParticleEmitter.LightEmission = 0
			end
			v56.Parent = currentChunk.map
			Utilities.Tween(0.5, nil, function(p22)
				Part1.CFrame = CFrame.fromMatrix(p18, u22, (p18 - CurrentCamera.CFrame.Position).Unit:Cross(u22).Unit)
				local v57 = NumberSequence.new(p22)
				Part1.ColorCore.Transparency = v57
				Part1.WhiteCore.Transparency = v57
			end)
			v43:Destroy()
			local u25 = false
			v56.Main.Touched:Connect(function(p23)
				if not (not u25) or not p23 or p23.Parent ~= _p.player.Character then
					return
				end
				if _p.MasterControl.WalkEnabled and not _p.Battle.currentBattle then
					u25 = true
					_p.MasterControl.WalkEnabled = false
					_p.MasterControl:Stop()
					_p.Menu:disable()
					local v58 = {}
					local u26 = nil
					v58[1] = function()
						_p.NPCChat:say(_p.PlayerData.trainerName .. " found a Meteorite!")
					end
					v58[2] = function()
						u26 = _p.Network:get("PDS", "collectMeteorFragment",  p19, '37')						
					end
					Utilities.Sync(v58) --tdo
					v56:Destroy()
					if u26 then
						if math.random(1,1000) <= 1 then
							_p.NPCChat:say("The Omnitrix grabbed onto your arm!")
						end
						_p.NPCChat:say("The "..u26.." was stored in the Bag.")
					else
						_p.NPCChat:say("An error occurred.")
					end		
					collectionOfRocks -= 1
					_p.MasterControl.WalkEnabled = true
					_p.Menu:enable()
					return
				end
			end)
			delay(150, function()
				u25 = true
				v56:Destroy()
			end)
		end
	end--)
	return Meteor
end
