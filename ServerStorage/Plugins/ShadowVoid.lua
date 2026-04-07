return function(_p) 
	local players = game:GetService("Players") 
	local cam = workspace.CurrentCamera
	local char = _p.player.Character
	local DataManager = _p.DataManager
	local Utilities = _p.Utilities
	local Tween = Utilities.Tween
	local create = Utilities.Create
	local mm = Utilities.MoveModel
	local MasterControl = _p.MasterControl

	local padDebounce2 = false
	local padDebounce = false
	local triggerDebounce = false
	local chunkTE = false 
	local marshTE = false
	local startedFollow = false
	local ShadowVoid = nil

	local marsh = {eyesClosed = true, eyesClosing = false, inVoid = false}
	local cachedLighting = {}
	local charList = {}    
	local music = {['LegendaryMusic'] = 10840573719, ['ShadowVoid'] = 11158727072} --easier for you if you want make it manual

	local function toggleMovement(enable, leaveCamCustom)     
		spawn(function()
			if not enable then
				cam.CameraType = leaveCamCustom and Enum.CameraType.Custom or Enum.CameraType.Scriptable
				MasterControl:Stop()
			end
			MasterControl.WalkEnabled = enable
		end)

		if enable then
			_p.Menu:enable()
			cam.CameraType = Enum.CameraType.Custom
		else
			_p.Menu:disable()
		end      
	end

	local function disableEyes(Decals, Duration, open, fn)    
		Utilities.Sync{
			function()
				Tween(Duration or .5, nil, function(a)
					-- dc.Body.ImageTransparency = open and 0+a or 0-a
					Decals.Eyes.ImageTransparency = open and 0+a or 0-a
					Decals.Eyes.Size = UDim2.new(0.3, 0, open and 0.3+(0.3*a) or 0.3-(0.3*a), 0)
				end)
			end,

			function()
				Tween(Duration or .5, nil, function(a)
					if fn then
						fn(a)
					end
				end)
			end,          
		}
	end   

	local function isTouchingTrigger(trigger)
		for _, v in pairs(char:GetChildren()) do
			if table.find(trigger:GetTouchingParts(), v) then
				return true     
			end
		end
		return false
	end

	function marsh:toggleEyes(decals, open)
		local model = decals.Parent.Parent

		if open then
			if not self.eyesClosed then return end
			self.eyesClosed = false
			Tween(2, nil, function(a)
				if self.eyesClosing then return end
				--  decals.Body.ImageTransparency = 1-a
				delay(1, function()
					decals.Eyes.ImageTransparency = 1-a
					decals.Eyes.Size = UDim2.new(0.3, 0, (0.3*a), 0)
				end)
			end)
			if self.eyesClosing then return end
			if not model:FindFirstChild('#InanimateInteract') then
				create('StringValue'){
					Name = '#InanimateInteract',
					Value = 'MarshadowShadow',
					Parent = model
				}
			end
		else
			if self.eyesClosing or self.eyesClosed then return end
			pcall(function() model:FindFirstChild('#InanimateInteract'):Destroy() end)
			self.eyesClosing = true
			disableEyes(decals, .5, false)
			self.eyesClosed = true
			self.eyesClosing = false
		end
	end

	function marsh:doBattleClick(void)
		if _p.PlayerData.completedEvents.MarshBattle then return end
		self.doingBattle = true
		toggleMovement(false, true)
		local decal = void:FindFirstChild('MarshadowDecal')
		spawn(function() MasterControl:LookAt(decal.Body.Position) end)
		Utilities.exclaim(char.Head)
		local decals = decal.Body.Srf
		local marsh = void.Marshadow
		local pos = marsh.Root.Position
		mm(marsh.Root, (marsh.Root.CFrame - Vector3.new(pos.X, 0, pos.Z)) + Vector3.new(decal.Main.Position.X, 0, decal.Main.Position.Z))
		local ogframe = marsh.Root.CFrame

		disableEyes(decals, 3, false)

		Tween(2, nil, function(a)
			mm(marsh.Root, ogframe + Vector3.new(0, 0 + (3.1 *a),0)) 
		end)

		task.wait(1)
		spawn(function()
			self:marshFollowFade(void, false)
			decal:destroy()
		end)

		delay(3, function()
			marsh:destroy()
		end)
		--todo: add battle to chunk?
		local battle = _p.Network:get('PDS', 'getMarshadowBattle')
		_p.Battle:doWildBattle(battle, {cantRun = true, musicId = music['LegendaryMusic'], battleSceneType = 'MarshadowBattle'})--jb
		toggleMovement(true) 
	end

	function marsh:marshFollowFade(void, enable)
		if not marshTE and not self.inVoid then return end 
		if _p.PlayerData.completedEvents.MarshBattle then return end

		if enable and startedFollow then          
			local model = void.MarshadowDecal           
			local root = char.HumanoidRootPart
			local trigger = void.MarshadowTrigger      
			local rf
			local lf
			local setY 

			if char:FindFirstChild('RightFoot') and char:FindFirstChild('LeftFoot') then
				rf = char.RightFoot.Position.Y
				lf = char.LeftFoot.Position.Y               
				setY = true
				print('sety')
			end

			local ogY = model.MainPrt.CFrame.Position.Y
			local rotation = model.PrimaryPart.CFrame - model.PrimaryPart.Position     

			game:GetService("RunService"):BindToRenderStep('MarshadowFollow', 200, function()
				if self.doingBattle then return end
				model:SetPrimaryPartCFrame(CFrame.new(Vector3.new(root.Position.X, (setY and ((rf+lf)/2 - 0.5) or ogY + 0.5) , root.Position.Z)) * rotation) 

				if root.Position.Z < trigger.Position.Z then 
					model.Body.Srf.Body.ImageTransparency = 1              
				else --todo like OG 
					model.Body.Srf.Body.ImageTransparency = 0       
				end
			end)

		else
			game:GetService("RunService"):UnbindFromRenderStep('MarshadowFollow')
			startedFollow = false
		end        
	end

	function marsh:idleCheck(void)
		if self.doingBattle then return end
		if _p.PlayerData.completedEvents.MarshBattle then return end
		local wtime = 3
		local direction = 1
		local humanoid = Utilities.getHumanoid()
		local timer

		if not workspace:FindFirstChild('MarshTime') then
			timer = Instance.new('NumberValue', workspace)
			timer.Value = wtime
			timer.Name = 'MarshTime'
		end

		local function resetTimer()
			if self.doingBattle then return end
			self:toggleEyes(void.MarshadowDecal.Body.Srf, false)
			timer.Value = wtime
		end

		while timer and not self.doingBattle and self.inVoid do
			timer.Value -= 1          
			if timer.Value >= 0 then task.wait(1) else task.wait() end  

			if _p.Hoverboard.equipped or _p.Surf.surfing then resetTimer() end        
			if humanoid.MoveDirection.X > 0 or humanoid.MoveDirection.X < 0 or humanoid.MoveDirection.Z > 0 or humanoid.MoveDirection.Z < 0 then resetTimer() end

			if timer.Value <= 0 then
				if self.doingBattle then return end
				direction = char.Head.CFrame.LookVector:Dot(void.EndTrigger.CFrame.LookVector) 
				if direction <= 0 then
					resetTimer()
				else        
					if char.HumanoidRootPart.Position.Z < void.EndTrigger.Position.Z then
						print('reseting br')
						resetTimer()
					else
						self:toggleEyes(void.MarshadowDecal.Body.Srf, true)
						spawn(function()
							timer:Destroy()
						end)
					end
				end
			end   
		end   
	end

	function marsh:FlipToVoid(ToChunk, voidMap)
		local chunk = DataManager.currentChunk
		local tweenType = 'easeInOutCubic'
		local charcf = char.HumanoidRootPart       
		local walkTo, hitBox, hitBox2, walkTo2       
		local msp = voidMap:FindFirstChild('MarshadowPortal')
		local sdp = chunk.map:FindFirstChild('ShadowPortal')
		local lkv = 2

		local function tweenByPlayer(Duration, ObjectPos, TweenTo, lookV, setPos)
			if setPos then
				pcall(function() MasterControl:LookAt(setPos) end)
				--      wait()
			end
			local camGoal = (charcf.CFrame - charcf.Position + Vector3.new(2,0,2)) + (ObjectPos + (Vector3.new(9, 0, 9) * (charcf.CFrame.LookVector - charcf.CFrame.LookVector*lookV)))-- (cf.CFrame - cf.Position) + (pos + (Vector3.new(18, -2) * (cf.CFrame.LookVector - cf.CFrame.LookVector*1.7)))
			local _, lerp = Utilities.lerpCFrame(cam.CoordinateFrame, camGoal)
			if TweenTo then
				Utilities.Tween(Duration or nil, 'easeOutCubic', function(a)
					local cf = lerp(a)
					cam.CoordinateFrame = cf
				end, Enum.RenderPriority.Camera.Value)
			else
				cam.CFrame = camGoal
			end
		end

		if not ToChunk then
			walkTo = sdp.ReturnTo
			hitBox = sdp.HitBox
		else
			walkTo = msp.SpawnTo
			hitBox = msp.HitBox
		end

		spawn(function() toggleMovement(false) end)
		MasterControl:LookAt(walkTo.CFrame)--look at portal
		tweenByPlayer(1, hitBox.Position, true, lkv)--tween cam to portal
		MasterControl:WalkTo(walkTo.Position) --walk to walkto

		local origin = cam.CFrame  
		local degrees = 180        
		local tweentime = 1
		local angle = ToChunk and -degrees or degrees --blue are you angry with me for being lazy? :goldkek:       
		local rotation = (char.HumanoidRootPart.CFrame.LookVector - char.HumanoidRootPart.CFrame.LookVector*lkv)

		Tween(tweentime, tweenType, function(a) --first rotation
			local rad = (origin) * CFrame.Angles(0, 0, -(angle*math.pi/angle)*(a)) --* (1-a) --50* math.pi/50
			cam.CFrame = rad:ToWorldSpace(CFrame.new(Vector3.new(0,0, 0) * rotation)) -- -3?
		end, Enum.RenderPriority.Camera.Value) 

		if ToChunk then
			voidMap:Destroy()
			ShadowVoid = nil
			pcall(function() chunk.map.InvertedSphere.Transparency = 0.1 end)
		else
			pcall(function() chunk.map.InvertedSphere.Transparency = 1 end)
			ShadowVoid = voidMap
			voidMap.Parent = workspace 
		end

		if ToChunk then
			hitBox2 = sdp.HitBox
			walkTo2 = sdp.ReturnTo
			self.inVoid = false
		else
			self.inVoid = true
			hitBox2 = msp.HitBox
			walkTo2 = msp.SpawnTo
		end

		local w2cf = walkTo2.CFrame

		--teleport to void map (or chunk)      

		Utilities.fastSpawn(function()
			Utilities.Teleport(w2cf)
		end)

		tweenByPlayer(0, hitBox2.Position, false, lkv) 

		local origin2 = cam.CFrame
		local rotation2 = (char.HumanoidRootPart.CFrame.LookVector - char.HumanoidRootPart.CFrame.LookVector*lkv)

		Utilities.fastSpawn(function()
			Utilities.Sync{
				function()
					Tween(0, tweenType, function(a) --set cf as bottom
						local rad = (origin2) * CFrame.Angles(0, 0 ,-(angle*math.pi/angle)*(a)) --* (1-a) --50* math.pi/50
						cam.CFrame = rad:ToWorldSpace(CFrame.new(Vector3.new(0,0, 0) * rotation2)) -- -3?
					end, Enum.RenderPriority.Camera.Value)                           
				end,
				function() --lighting/music           
					if not ToChunk then --pop region play void
						spawn(function()
							--cache chunk lighting
							--use shadowlighting
							local shadowLighting = {
								FogColor = Color3.fromRGB(32, 29, 33), 
								FogEnd = 300,
								FogStart = 200,
								Brightness = 0,              
							}

							for prop, val in pairs(shadowLighting) do
								cachedLighting[prop] = game:GetService("Lighting")[prop]
								game:GetService("Lighting")[prop] = val
							end
						end)
						_p.MusicManager:popMusic('RegionMusic', .5, true)
						_p.MusicManager:stackMusic(music['ShadowVoid'], 'VoidMusic')
					else -- play region pop void                   
						spawn(function()
							_p.MusicManager:popMusic('VoidMusic', .5, true)
							for prop, val in pairs(cachedLighting) do
								game:GetService("Lighting")[prop] = val
							end
							_p.MusicManager:stackMusic(chunk.regionData.Music, 'RegionMusic', chunk.regionData.MusicVolume or .5)
							--use normal chunk lighting
						end)
					end
				end,
			}   
		end)

		local origin3 = cam.CFrame
		local rotation3 = (char.HumanoidRootPart.CFrame.LookVector - char.HumanoidRootPart.CFrame.LookVector*lkv)        

		Tween(tweentime, tweenType, function(a) --return cf to normal
			local rad = (origin3) * CFrame.Angles(0, 0, (angle*math.pi/angle)*(a)) 
			cam.CFrame = rad:ToWorldSpace(CFrame.new(Vector3.new(0,3, 0) * rotation3)) -- -3?
		end, Enum.RenderPriority.Camera.Value) 

		if not ToChunk then --going to marshadow
			Utilities.exclaim(char.Head) 
			spawn(function() disableEyes(voidMap.MarshadowDecal.Body.Srf, 0, false) end)
			if _p.PlayerData.completedEvents.MarshBattle then
				voidMap.Marshadow:Destroy()
				voidMap.MarshadowDecal:Destroy()
				voidMap.MarshadowTrigger:Destroy()
				voidMap.EndTrigger:Destroy()
				toggleMovement(true) 
			 end
			
			

			voidMap.MarshadowTrigger.Touched:Connect(function(p)
				if not p or not p.Parent or players:GetPlayerFromCharacter(p.Parent) ~= _p.player then return end
				if self.doingBattle then return end
				if _p.PlayerData.completedEvents.MarshBattle then return end
				startedFollow = true                  
				self:marshFollowFade(voidMap, true)         
			end)

			hitBox2.TouchEnded:Connect(function(p) --stopped touching the pad you got tped to
				if not p or not p.Parent or players:GetPlayerFromCharacter(p.Parent) ~= _p.player then return end
				if marshTE then return end
				wait(3)
				if not isTouchingTrigger(msp.HitBox) then marshTE = true end
			end)  

			hitBox2.Touched:Connect(function(p) --now you can go back home
				if marshTE then
					if padDebounce then return end
					if not chunk.map:FindFirstChild('ShadowPortal') then return end--need to wait
					padDebounce, marshTE, chunkTE = true, false, false
					--GOING HOME
					if not self.doingBattle and not _p.PlayerData.completedEvents.MarshBattle then
						self:marshFollowFade(voidMap, false)
					end
					print('GOING HOME BOYS')

					self:FlipToVoid(true, voidMap)  

					padDebounce = false
				end
			end)      

			voidMap.EndTrigger.Touched:Connect(function(p)
				if not p or not p.Parent or players:GetPlayerFromCharacter(p.Parent) ~= _p.player then return end
				if triggerDebounce then return end
				triggerDebounce = true
				print('idleCheck')
				self:idleCheck(voidMap) 
			end)

		end        

		Utilities.lookBackAtMe()   

		if not ToChunk then _p.RunningShoes:disable() _p.PlayerData.disableFly = true  else _p.RunningShoes:enable() end
		toggleMovement(true)   
	end

	function marsh:doEvent(portal)        
		if self:doCheck() then
			local firsttime, firstdebounce = true, false
			portal.HitBox.Touched:Connect(function(p)
				if not p or not p.Parent or players:GetPlayerFromCharacter(p.Parent) ~= _p.player then return end
				if chunkTE or firsttime then
					if firstdebounce then return end
					firstdebounce, firsttime, chunkTE, marshTE = true, false, false, false           
					if not ShadowVoid then ShadowVoid = _p.storage.Models.ShadowVoid:Clone() end
					self:FlipToVoid(false, ShadowVoid)--self:teleport()
					firstdebounce = false
				end
			end)

			portal.HitBox.TouchEnded:Connect(function(p)
				if not p or not p.Parent or players:GetPlayerFromCharacter(p.Parent) ~= _p.player then return end
				if chunkTE then return end        
				wait(1.5)
				if not isTouchingTrigger(portal.HitBox) then chunkTE = true end
			end)
		end 
	end

	function marsh:doCheck()
		if DataManager.isDay then return false end   
		if not DataManager.currentChunk.map:FindFirstChild('ShadowPortal') then return false end
		if not ShadowVoid then ShadowVoid = _p.storage.Models.ShadowVoid:Clone() end   
		return true
	end

	return marsh
end