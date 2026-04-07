-- Thank you Llama Train Studio, Party, Brewster, and Topia.

return function(_p)
	local Utilities = _p.Utilities
	local Tween = Utilities.Tween
	local create = Utilities.Create
	local storage = game:GetService('ReplicatedStorage')
	local stepped = game:GetService('RunService').RenderStepped
	local RunService = game:GetService("RunService");
	local TweenService = game:GetService("TweenService");
	local Misc = storage.Models.Misc;
	local v6 = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.16666666666666666, Color3.fromRGB(218, 133, 65)), ColorSequenceKeypoint.new(0.3333333333333333, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.6666666666666666, Color3.fromRGB(9, 137, 207)), ColorSequenceKeypoint.new(0.8333333333333334, Color3.fromRGB(61, 21, 133)), (ColorSequenceKeypoint.new(1, Color3.fromRGB(107, 50, 124))) });
	local v7 = {};
	local Lighting = game:GetService("Lighting");
	local Particles = Misc.Particles;
	local Random_new_ret = Random.new();	
	local u13 = require(script.MoveUtil);

	local battle
	-- Hazard BS reworked by Infrared

	-- NOTE:
	--  Sprite.cf is at the BOTTOM CENTER of the part on which the sprite is rendered, already INCLUDES inAir, and is
	--	oriented such that its lookVector (no matter which side it is on) is the direction pointing from the opposing
	--	side to the viewer's side

	-- queue:
	--	make explosion/selfdestruct use 644263953 animation (8 rows, 8 columns, 128x128 frames, play once)
	-- 
	--	psychic
	--	earthquake
	--	brave bird
	--  stealth rock
	--	dragon rush
	--	leafage
	--	sticky web

	-- For light shifting (Infrared)
	local ambientInitial = Lighting.Ambient
	local outdoorAmbientInitial = Lighting.OutdoorAmbient
	local colorShiftBottomInitial = Lighting.ColorShift_Bottom
	local colorShiftTopInitial = Lighting.ColorShift_Top

	local u1 = nil
	local u11 = Random.new();
	local u2
	local function u9(p28, duration)
		if not u1 then
			local CurrentCamera_10 = workspace.CurrentCamera;
			u1 = _p.CameraShaker.new(Enum.RenderPriority.Camera.Value + 5, function(p29)
				CurrentCamera_10.CFrame = u2 * p29;
			end);
			u1.AutoStop = true;
		end
		if not duration then
			duration = 0.5
		end
		local v63 = nil;
		if type(p28) == "string" then
			v63 = _p.CameraShaker.Presets[p28];
		else
			error("other shakeKinds not yet implemented");
		end

		u1:Shake(v63);

		if not u1._running then
			u2 = workspace.CurrentCamera.CFrame;
			u1:Start();
		end

		-- Add a timer to stop the camera shake after the specified duration
		spawn(function()
			task.wait(duration)
			u1:Stop()
		end)
	end

	local function targetPoint(pokemon, dist)
		local sprite = pokemon.sprite or pokemon
		return sprite.cf * Vector3.new(0, sprite.part.Size.Y/2, (dist or 1) * (sprite.siden==1 and 1 or -1))
	end

	local function spikes(pokemon, modelName, color, swap)
		battle = pokemon.side.battle
		if not swap then
			if modelName == "ToxicSpikes" then
				if battle.yourSide.sideConditions["toxicspikes"] and battle.yourSide.sideConditions["toxicspikes"][2] >= 2 then
					return
				end
			else
				if battle.yourSide.sideConditions["spikes"] and battle.yourSide.sideConditions["spikes"][2] >= 3 then
					return
				end
			end
		end

		-- get platforms
		local platforms = {}
		local names
		local sideNumber = pokemon.side.n
		if sideNumber == 1 then
			names = {'pos21', 'pos22', 'pos23'}
			if battle.gameType ~= 'doubles' then -- todo: triples?
				names[4] = '_Foe'
			end
		else
			names = {'pos11', 'pos12', 'pos13'}
			if battle.gameType ~= 'doubles' then -- todo: triples?
				names[4] = '_User'
			end
		end
		for _, name in pairs(names) do
			local p = battle.scene:FindFirstChild(name)
			if p then
				platforms[#platforms+1] = p
			end
		end
		--
		local spike = create 'Part' {
			Anchored = true,
			CanCollide = false,
			BrickColor = BrickColor.new(color or 'Smoky grey'),
			Reflectance = .1,
			Size = Vector3.new(1, 1, 1),

			create 'SpecialMesh' {
				MeshType = Enum.MeshType.FileMesh,
				MeshId = 'rbxassetid://629819743',
				Scale = Vector3.new(.01, .01, .01)
			}
		}
		local spikeContainer = create 'Model' {
			Name = (modelName or 'Spikes')..(3-pokemon.side.n),
			Parent = battle.scene
		}

		delay(10, function() spike:Destroy() end)
		local throwFrom = targetPoint(pokemon, 1.5)
		for _, platform in pairs(platforms) do
			spawn(function()
				local available = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}
				local function r()
					local n = math.random(#available)
					local v = table.remove(available, n) -- middle
					table.remove(available, #available < n and 1 or n) -- right
					table.remove(available, n==1 and #available or n-1) -- left
					return v
				end
				local offset = math.random()*math.pi*2
				for _, v in pairs({r(), r(), r()}) do
					local angle = offset+(v+math.random())*math.pi/6
					local r = 2+math.random()
					local cf = platform.CFrame * CFrame.Angles(0, math.random()*6.28, 0) + Vector3.new(math.cos(angle)*r, -platform.Size.Y/2+.25, math.sin(angle)*r)
					local throw = throwFrom - cf.p
					local rx, ry, rz = (math.random()-.5)*3, (math.random()-.5)*3, (math.random()-.5)*3
					local sp = spike:Clone()
					sp.Parent = spikeContainer
					spawn(function()
						Tween(.5, 'easeOutQuad', function(a)
							local o = 1-a
							sp.CFrame = cf * CFrame.Angles(o*rx, o*ry, o*rz) + throw*o + Vector3.new(0, 2*math.sin(a*math.pi), 0)
						end)
					end)
					task.wait(.2)
				end
			end)
		end
	end

	local function stickyweb(poke, swap)
		local parts = {}
		local poses
		local sideNumber = poke.side.n
		battle = poke.side.battle

		if battle.yourSide.sideConditions["stickyweb"] and not swap then
			return
		end

		if sideNumber == 1 then
			poses = { "pos21", "pos22", "pos23" }
			if battle.gameType ~= "doubles" then
				poses[4] = "_Foe"
			end
		else
			poses = { "pos11", "pos12", "pos13" }
			if battle.gameType ~= "doubles" then
				poses[4] = "_User"
			end
		end
		for i, v in pairs(poses) do
			local part = battle.scene:FindFirstChild(v)
			if part then
				parts[#parts + 1] = part
			end;
		end;
		local model = create("Model")({
			Name = "StickyWeb" .. 3 - poke.side.n, 
			Parent = battle.scene
		})

		local targ = targetPoint(poke, 1.5)
		for i, v in pairs(parts) do
			spawn(function()
				local part = create("Part")({
					Anchored = true, 
					CanCollide = false, 
					BrickColor = BrickColor.new("Institutional white"), 
					Size = Vector3.new(3, 3, 0.2)
				})
				local pos = Vector3.new(1.2, 1.2, 0.1)
				local smesh = create("SpecialMesh")({
					MeshType = Enum.MeshType.FileMesh, 
					MeshId = "rbxassetid://299832836", 
					Parent = part
				})
				part.Parent = model
				local angle = CFrame.Angles(math.random() < 0.5 and math.pi or 0, 0, math.random() * math.pi * 2)
				local pos2 = v.Position + Vector3.new(math.random() - 0.5, -v.Size.Y / 2 + 0.05, math.random() - 0.5)
				local cf = CFrame.new(pos2, pos2 + Vector3.new(pos2.X - targ.X, 0, pos2.Z - targ.Z))
				local targetPoint89 = targ - cf.p
				Tween(0.8, "easeOutQuad", function(a)
					smesh.Scale = pos * (0.5 + 0.5 * a)
					part.CFrame = cf * CFrame.Angles(1 - 2.57 * a, 0, 0) * angle + targetPoint89 * (1 - a) + Vector3.new(0, 2 * math.sin(a * math.pi), 0)
				end)
			end)
		end
	end

	local function stealthrock(pokemon, swap)
		local parts = {}
		local poses
		local sideNumber = pokemon.side.n
		battle = pokemon.side.battle

		if battle.yourSide.sideConditions["stealthrock"] and not swap then
			return
		end

		if sideNumber == 1 then
			poses = { "pos21", "pos22", "pos23" }
			if battle.gameType ~= "doubles" then
				poses[4] = "_Foe"
			end
		else
			poses = { "pos11", "pos12", "pos13" }
			if battle.gameType ~= "doubles" then
				poses[4] = "_User"
			end
		end
		for i, v in pairs(poses) do
			local part = battle.scene:FindFirstChild(v)
			if part then
				parts[#parts + 1] = part
			end
		end
		local rock = create("Part")({
			Anchored = true, 
			CanCollide = false, 
			BrickColor = BrickColor.new("Dark orange"), 
			Size = Vector3.new(0.5, 1, 0.5),
			create("SpecialMesh")({
				MeshType = Enum.MeshType.FileMesh, 
				MeshId = "rbxassetid://818652045", 
				Scale = Vector3.new(0.01, 0.01, 0.01)
			})
		})
		local model = create("Model")({
			Name = "StealthRock" .. 3 - pokemon.side.n, 
			Parent = battle.scene
		})

		local targ = targetPoint(pokemon, 1.5);
		for i, v in pairs(parts) do
			spawn(function()
				local available = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
				local function getpart()
					local ran = math.random(#available)
					local removed = table.remove(available, ran)
					local num
					if #available < ran then
						num = 1
					else
						num = ran
					end;
					table.remove(available, num)
					table.remove(available, ran == 1 and #available or ran - 1)
					return removed
				end
				local rnum = math.random() * math.pi * 2
				for i = 1, 5 do
					local num = rnum + (getpart() + math.random()) * math.pi / 10
					local num2 = 2.5 + math.random()
					local cf = v.CFrame * CFrame.Angles(0, math.random() * 6.28, 0) + Vector3.new(math.cos(num) * num2, -v.Size.Y / 2 + 0.5 + 0.3 * math.random(), math.sin(num) * num2)
					local num3 = (math.random() - 0.5) * 3
					local num4 = (math.random() - 0.5) * 3
					local srock = i == 5 and rock or rock:Clone()
					srock.Parent = model
					local num5 = (math.random() - 0.5) * 3
					local num6 = targ - cf.p
					spawn(function()
						Tween(0.5, "easeOutQuad", function(a)
							local num7 = 1 - a
							srock.CFrame = cf * CFrame.Angles(num7 * num3, num7 * num4, num7 * num5) + num6 * num7 + Vector3.new(0, 2 * math.sin(a * math.pi), 0)
						end)
					end)
					task.wait(0.1)
				end
			end)
		end
	end

	local function lightShift(ambient, outdoor, shiftbottom, shifttop, duration)
		-- All parameters except duration & start are Color3 values, duration is a number
		local ambientTarget = ambient
		local outdoorAmbientTarget = outdoor
		local colorShiftBottomTarget = shiftbottom
		local colorShiftTopTarget = shifttop

		local activate = TweenInfo.new(
			duration or 0.9, -- Duration
			Enum.EasingStyle.Linear, -- Easing style
			Enum.EasingDirection.InOut, -- Easing direction
			0, -- Repetition
			false, -- Reverse
			0 -- Delay
		)

		local tween = TweenService:Create(Lighting, activate, {
			Ambient = ambientTarget,
			OutdoorAmbient = outdoorAmbientTarget,
			ColorShift_Bottom = colorShiftBottomTarget,
			ColorShift_Top = colorShiftTopTarget,
		})
		tween:Play()
	end

	local function lightRestore(duration)
		local deactivate = TweenInfo.new(
			duration or 0.5,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.InOut,
			0, 
			false, 
			0
		)

		local tween = TweenService:Create(Lighting, deactivate, {
			Ambient = ambientInitial,
			OutdoorAmbient = outdoorAmbientInitial,
			ColorShift_Bottom = colorShiftBottomInitial,
			ColorShift_Top = colorShiftTopInitial,
		})
		tween:Play()
	end

	local function absorb(pokemon, target, amount, color)
		local from = targetPoint(pokemon)
		local to = targetPoint(target)
		local dif = from-to
		local cf = target.sprite.part.CFrame
		cf = cf-cf.p
		for i = 1, (amount or 6) do
			local a = math.random()*6.3
			local offset = (cf*Vector3.new(math.cos(a),math.sin(a),0))*.75
			local so = math.random()*6.3
			_p.Particles:new {
				Image = 478035064,
				Color = (color or Color3.fromHSV((90+40*math.random())/360, 1, .75)),
				Lifetime = .9,
				Size = .7,
				OnUpdate = function(a, gui)
					gui.CFrame = CFrame.new(to+dif*a+(1-a*.6)*(offset+Vector3.new(0,math.sin(so+a*3),0)))
				end
			}
			task.wait(.06)
		end
		task.wait(.7)
	end

	local function u138(p832, p833, p834)
		local v1595 = CFrame.new(targetPoint(p832, 2.5), targetPoint(p832, 0));
		if p833 then
			delay(0.1, function()
				local Particles_1596 = _p.Particles;
				local v1597 = 0.5 * (p834 and 1);
				for v1598 = 1, 5 do
					task.wait(0.04);
					for v1599 = 1, 2 do
						local v1600 = math.random();
						local v1601 = math.random() * math.pi * 2;
						local v1602 = Vector3.new(v1600 * math.cos(v1601), v1600 * 0.5 * math.sin(v1601), 0);
						local unit_1603 = ((v1595 - v1595.p) * v1602).unit;
						local v1604 = {
							Position = v1595 * (v1602 + Vector3.new(0, 0, -2.5)), 
							Rotation = -math.deg(v1601) + 90, 
							Velocity = unit_1603 * 6, 
							Acceleration = -unit_1603 * 7, 
							Lifetime = 0.3, 
							Image = p833
						};
						function v1604.OnUpdate(p835, p836)
							local v1605 = v1597 * math.sin(p835 * math.pi);
							p836.BillboardGui.Size = UDim2.new(v1605, 0, v1605, 0);
						end;
						Particles_1596:new(v1604);
					end;
				end;
			end);
		end;
		Tween(0.6, "easeInOutQuad", function(p837)
			local v1606 = (1 + math.sin(0.5 + p837 * 5.28)) / 2;
		end);
	end;
	local function u204(p994, p995)
		local sprite_1853 = p994.sprite;
		local unit_205 = ((p995.sprite.part.Position - sprite_1853.part.Position) * Vector3.new(1, 0, 1)).unit;
		Tween(0.1, nil, function(p996)
			sprite_1853.offset = unit_205 * 2 * p996;
		end);
		spawn(function()
			Tween(0.17, "easeOutCubic", function(p997)
				sprite_1853.offset = unit_205 * 2 * (1 - p997);
			end);
		end);
	end;
	local function bite(target, particle, pSize, isCrunch)
		local b = storage.Models.Misc.Bite:Clone()
		if isCrunch then
			Utilities.ScaleModel(b.Main, 1.3)
		end
		local top, btm = b.Top, b.Bottom
		local inv = b.Main.CFrame:inverse()
		local tc, bc = inv * top.CFrame, inv * btm.CFrame
		b.Main:Destroy()
		b.Parent = workspace
		local mcf = CFrame.new(targetPoint(target, 2.5), targetPoint(target, 0))
		if particle then
			delay(.25, function()
				local p = _p.Particles
				local size = .5*(pSize or 1)
				for _ = 1, 5 do
					task.wait(.04)
					for _ = 1, 2 do
						local r = math.random()
						local t = math.random()*math.pi*2
						local d = Vector3.new(r*math.cos(t), r*.5*math.sin(t), 0)
						local v = ((mcf-mcf.p)*d).unit
						p:new {
							Position = mcf * (d + Vector3.new(0, 0, -1)),
							Rotation = -math.deg(t)+90,
							Velocity = v*6,
							Acceleration = -v*7,
							Lifetime = .7,
							Image = particle,
							OnUpdate = function(a, gui)
								local s = size*math.sin(a*math.pi)
								gui.BillboardGui.Size = UDim2.new(s, 0, s, 0)
							end,
						}
					end
				end
			end)
		end
		--	if isCrunch then
		--		Tween(2, nil, function(a)
		--			local s = (1+math.sin(.5+a*5.28))/2
		--			local m = CFrame.new(0, 0, -.6*(1-s))
		--			top.CFrame = mcf * m * CFrame.Angles( .7*s, 0, 0) * tc
		--			btm.CFrame = mcf * m * CFrame.Angles(-.7*s, 0, 0) * bc
		--		end)
		--	else
		Tween(.6, 'easeInOutQuad', function(a)
			local s = (1+math.sin(.5+a*5.28))/2
			--		local t = a<.1 and (1-10*a) or (a>.9 and ((a-.9)*10) or 0)
			--		top.Transparency = t
			--		btm.Transparency = t
			local m = CFrame.new(0, 0, -.6*(1-s))
			top.CFrame = mcf * m * CFrame.Angles( .7*s, 0, 0) * tc
			btm.CFrame = mcf * m * CFrame.Angles(-.7*s, 0, 0) * bc
		end)
		--	end
		b:Destroy()
	end

	local function shield(pokemon, color)
		local sprite = pokemon.sprite
		local part = sprite.part
		local s = create 'Part' {
			Anchored = true,
			CanCollide = false,
			Transparency = .3,
			Reflectance = .4,
			BrickColor = BrickColor.new(color or 'Alder'),
			Parent = part.Parent,

			create 'CylinderMesh' {Scale = Vector3.new(1, 0.01, 1)}
		}
		local cf = sprite.cf * CFrame.new(0, 1.5-(sprite.spriteData.inAir or 0), 2.5 * (sprite.siden==1 and 1 or -1)) * CFrame.Angles(math.pi/2, .5, 0)
		Tween(.6, 'easeOutCubic', function(a)
			s.Size = Vector3.new(3*a, .2, 3*a)
			s.CFrame = cf
		end)
		delay(1, function()
			Tween(.5, 'easeOutCubic', function(a)
				s.Transparency = .3 + .7*a
				s.Reflectance = .4 * (1-a)
			end)
			s:Destroy()
		end)
	end

	local function cut(target, color, qty, pcolor1, pcolor2)
		local parts = {}
		local size
		local scale = .1
		local mscale = scale * 2
		if qty == 3 then
			for i = 1, 3 do
				local p = storage.Models.Misc.SlashEffect:Clone()
				size = p.Size * 4
				parts[p] = target.sprite.part.CFrame * CFrame.new(0, 0, -1) * CFrame.new(Vector3.new(.6, .6, 0)*(i-2))
				p.BrickColor = BrickColor.new(color or 'White')
				p.Parent = workspace
			end
		elseif qty == 2 then
			local p = storage.Models.Misc.SlashEffect:Clone()
			size = p.Size * 4
			parts[p] = target.sprite.part.CFrame * CFrame.new(0, 0, -1)
			p.BrickColor = BrickColor.new(color or 'White')
			p.Parent = workspace
			local p2 = p:Clone()
			parts[p2] = target.sprite.part.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0, 0, -math.pi/2)
			p2.Parent = workspace
		else
			local p = storage.Models.Misc.SlashEffect:Clone()
			size = p.Size * 4
			parts[p] = target.sprite.part.CFrame * CFrame.new(0, 0, -1)
			p.BrickColor = BrickColor.new(color or 'White')
			p.Parent = workspace
		end
		--	local lastParticle = {}
		Utilities.Tween(.4, nil, function(a)
			for part, cf in pairs(parts) do
				part.Size = size*(0.2+1.2*math.sin(a*math.pi))*scale
				part.CFrame = cf * CFrame.new((-3+6*a)*mscale, (3-6*a)*mscale, 0) * CFrame.Angles(0, math.pi/2, 0) * CFrame.Angles(math.pi/4, 0, 0)
			end
		end)
		for part in pairs(parts) do
			part:Destroy()
		end
	end

	local function tackle(pokemon, target)
		local sprite = pokemon.sprite
		local s = sprite.part.Position
		local e = target.sprite.part.Position
		local dir = ((e-s)*Vector3.new(1,0,1)).unit
		Tween(.1, nil, function(a)
			sprite.offset = dir*2*a
		end)
		spawn(function()
			Tween(.17, 'easeOutCubic', function(a)
				sprite.offset = dir*2*(1-a)
			end)
		end)
	end

	local function cParticle(image, size, color)
		local p = create 'Part' {
			Transparency = 1.0,
			Anchored = true,
			CanCollide = false,
			Size = Vector3.new(.2, .2, .2),
			Parent = workspace,
		}
		local bbg = create 'BillboardGui' {
			Adornee = p,
			Size = UDim2.new(size or 1, 0, size or 1, 0),
			Parent = p
		}
		local img = create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = type(image) == 'number' and ('rbxassetid://'..image) or image,
			ImageColor3 = color or nil,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			ZIndex = 2,
			Parent = bbg
		}
		return p, bbg, img
	end

	return {
		setTweenFunc = function(fn) -- to fastforward
			Tween = fn
		end,

		-- STATUS ANIMS

		status = {
			psn = function(pokemon)
				local p = _p.Particles
				local isTox = pokemon.status=='tox'
				local part = pokemon.sprite.part
				for i = 1, 10 do
					task.wait(.1)
					p:new {
						Position = (part.CFrame*CFrame.new(part.Size.X*(math.random()-.5)*.7, -part.Size.Y/2*math.random()*.8, -.2)).p,
						Velocity = Vector3.new(0, 3, 0),
						Acceleration = false,
						Color = isTox and Color3.new(111/255, 9/255, 95/255) or Color3.new(175/255, 106/255, 206/255),
						Lifetime = .5,
						Image = 243953162,
						OnUpdate = function(a, gui)
							local s = .8*math.sin(a*math.pi)
							gui.BillboardGui.Size = UDim2.new(s, 0, s, 0)
						end,
					}
				end
			end,
			brn = function(pokemon)
				local p = _p.Particles
				local part = pokemon.sprite.part
				for i = 1, 10 do
					task.wait(.1)
					p:new {
						Position = (part.CFrame*CFrame.new(part.Size.X*(math.random()-.5)*.7, -part.Size.Y/2*math.random()*.8, -.2)).p,
						Velocity = Vector3.new(0, 4, 0),
						Acceleration = false,
						Lifetime = .5,
						Image = 11601142,
						OnUpdate = function(a, gui)
							local s = 1.2*math.cos(a*math.pi/2)
							gui.BillboardGui.Size = UDim2.new(s, 0, s, 0)
						end,
					}
				end
			end,
			par = function(pokemon)
				local p = _p.Particles
				local part = pokemon.sprite.part
				pokemon.sprite.animation:Pause()
				for i = 1, 10 do
					task.wait(.1)
					local rs = 360*math.random()
					p:new {
						Position = (part.CFrame*CFrame.new(part.Size.X*(math.random()-.5)*.7, -part.Size.Y*(math.random()-.5)*.7, -.2)).p,
						Size = .7+.4*math.random(),
						Acceleration = false,
						Lifetime = .2,
						Image = {326993171, 326993181, 326993188},
						Rotation = rs,
					}
				end
				delay(.5, function()
					pokemon.sprite.animation:Play()
				end)
			end,
			slp = function(pokemon)
				local p = _p.Particles
				local part = pokemon.sprite.part
				local dir = 1
				if pokemon.side.n == 2 then
					dir = -1
				end
				for i = 1, 5 do
					p:new {
						Position = (part.CFrame*CFrame.new(part.Size.X*-.25*dir, part.Size.Y*.4, -.2)).p,
						Velocity = Vector3.new(0, 1, 0),
						Acceleration = false,
						Lifetime = 1,
						Color = Color3.new(.7, .7, .7),
						Image = 77146622,
						OnUpdate = function(a, gui)
							local s = .2+.4*math.sin(a*math.pi/2)
							gui.BillboardGui.Size = UDim2.new(s, 0, s, 0)
							gui.BillboardGui.ImageLabel.Rotation = -30*a*dir
							if a > .6 then
								gui.BillboardGui.ImageLabel.ImageTransparency = (a-.6)/.4
							end
						end,
					}
					task.wait(.3)
				end
			end,
			confused = function(pokemon)
				local part = pokemon.sprite.part
				local cf = part.CFrame * CFrame.new(0, part.Size.Y/2+.25, 0)
				local duck1 = create 'Part' {
					Anchored = true,
					CanCollide = false,
					--				FormFactor = Enum.FormFactor.Custom,
					Size = Vector3.new(.2, .2, .2),
					Parent = workspace,

					create 'SpecialMesh' {
						MeshType = Enum.MeshType.FileMesh,
						MeshId = 'rbxassetid://9419831',
						TextureId = 'rbxassetid://9419827',
						Scale = Vector3.new(.5, .5, .5),
					}
				}
				local duck2, duck3 = duck1:Clone(), duck1:Clone()
				duck2.Parent, duck3.Parent = workspace, workspace
				local r = part.Size.X*.45
				local o2, o3 = math.pi*2/3, math.pi*4/3
				Tween(1.5, nil, function(a)
					local angle = a*7
					local a1 = angle
					local a2 = angle + o2
					local a3 = angle + o3
					duck1.CFrame = cf * CFrame.new(math.cos(a1)*r, 0, math.sin(a1)*r) * CFrame.Angles(0, a1*2, 0)
					duck2.CFrame = cf * CFrame.new(math.cos(a2)*r, 0, math.sin(a2)*r) * CFrame.Angles(0, a2*2, 0)
					duck3.CFrame = cf * CFrame.new(math.cos(a3)*r, 0, math.sin(a3)*r) * CFrame.Angles(0, a3*2, 0)
				end)
				duck1:Destroy()
				duck2:Destroy()
				duck3:Destroy()
			end,

			dynamax = function(pokemon,targets)
				local part = pokemon.sprite.part
				local cf = part.CFrame
				local of = workspace.CurrentCamera.FieldOfView
				local df = 45
				local psv3 = part.Size
				local sprite = pokemon.sprite
				local from = targetPoint(pokemon, -2)
				local to = targetPoint(pokemon, 0.5) - from
				local unt = to * Vector3.new(1, 0, 1).unit
				local air = sprite.spriteData.inAir or 0
				--spawn(function()
				--	Tween(0.6, nil, function(b)
				--		sprite.offset = unt * -2 * b + Vector3.new(0, math.sin(b * math.pi) - air * b, 0)
				--	end)
				--end)
				Tween(1, 'easeInCubic', function(a)
					part.Size = psv3 * (1 + 1*a-0.45)
					workspace.CurrentCamera.FieldOfView = of+(df-of)*a
				end)
			end,
			maxraid = function(pokemon)
				local part = pokemon.sprite.part
				local cf = part.CFrame
				local of = workspace.CurrentCamera.FieldOfView
				local df = 70
				local xz = Vector3.new(1, 0, 1)
				local psv3 = part.Size 
				Tween(1, 'easeInCubic', function(a)
					part.Size = psv3 * (1 + 3*a)
					workspace.CurrentCamera.FieldOfView = of+(df-of)*a
				end)
			end,
			UBEntry = function(pokemon)
				local part = pokemon.sprite.part
				local particle = storage.Models.Misc.Particles.ShadowBall:Clone()
				particle.Parent = part
				particle:Emit(15)
				delay(1.5, function()
					particle.Enabled = true
				end)
			end,
			redmax = function(pokemon)
				local part = pokemon.sprite.part
				local cf = part.CFrame
				local of = workspace.CurrentCamera.FieldOfView
				local df = 35
				battle = pokemon.side.battle
				if battle.gameType == "doubles" then
					df = 40
				end
				local xz = Vector3.new(1, 0, 1)
				local psv3 = part.Size
				local sprite = pokemon.sprite
				local from = targetPoint(pokemon, 2)
				local to = targetPoint(pokemon, 0.5) - from
				local unt = to * Vector3.new(1, 0, 1).unit
				local air = sprite.spriteData.inAir or 0
				--Tween(0.6, nil, function(b)
				--	sprite.offset = unt * -2 * b + Vector3.new(0, math.sin(b * math.pi) - air * b, 0)
				--end)
				Tween(1, 'easeInCubic', function(a)
					part.Size = psv3 / (1 + 1*a)
					workspace.CurrentCamera.FieldOfView = of+(df-of)*a
				end)
			end,
			heal = function(pokemon)
				local sprite = pokemon.sprite
				local cf = sprite.part.CFrame
				local size = sprite.part.Size
				for i = 1, 8 do
					_p.Particles:new {
						Rotation = math.random()*360,
						RotVelocity = (math.random(2)==1 and 1 or -1)*(80+math.random(80)),
						Image = 644321851,
						Color = Color3.fromHSV((150+math.random()*20)/360, .5, 1),
						Position = cf*Vector3.new((math.random()-.5)*.8*size.X, (math.random()-.5)*.8*size.Y, -.5),
						Lifetime = .7,
						Acceleration = false,
						Velocity = Vector3.new(0, 1.5, 0),
						OnUpdate = function(a, gui)
							local s = math.sin(a*math.pi)
							gui.BillboardGui.Size = UDim2.new(.5*s, 0, .5*s, 0)
						end
					}
					task.wait(.06)
				end
			end
		},
		-- MOVE PREP ANIMS

		prepare = { -- args: pokemon, target, battle, move
			-- in-game, in essence: fall into purple puddle, then on second turn appear behind opponent (fall out of purple thing) and attack
			-- phantomforce  pokemon:getName() .. ' vanished instantly!'
			bounce = function(pokemon, _, _, _, ff)
				local sprite = pokemon.sprite
				if ff then sprite.offset = Vector3.new(0, 10, 0) return end
				for i = 1, 2 do
					Tween(.7, nil, function(a)
						sprite.offset = Vector3.new(0, 2*i*math.sin(a*math.pi), 0)
					end)
				end
				Tween(.5, 'easeOutCubic', function(a)
					sprite.offset = Vector3.new(0, 10*a, 0)
				end)
				return pokemon:getName() .. ' sprang up!'
			end,

			floatyfall = function(pokemon, _, _, _, ff)
				local sprite = pokemon.sprite
				if ff then sprite.offset = Vector3.new(0, 10, 0) return end
				for i = 1, 2 do
					Tween(.7, nil, function(a)
						sprite.offset = Vector3.new(0, 2*i*math.sin(a*math.pi), 0)
					end)
				end
				Tween(.5, 'easeOutCubic', function(a)
					sprite.offset = Vector3.new(0, 10*a, 0)
				end)
				return pokemon:getName() .. ' sprang up!'
			end,

			dig = function(pokemon, _, _, _, ff)
				local sprite = pokemon.sprite
				local y = sprite.part.Size.Y+(sprite.spriteData.inAir or 0)+.2
				if ff then sprite.offset = Vector3.new(0, -y, 0) return end
				local n = 5
				for i = 1, n do
					Tween(.25, 'easeOutCubic', function(a)
						sprite.offset = Vector3.new(0, (i-1+a)/n*-y, 0)
					end)
					task.wait(.1)
				end
				return pokemon:getName() .. ' burrowed its way under the ground!'
			end,
			dive = function(pokemon, _, _, _, ff)
				local sprite = pokemon.sprite
				local y = sprite.part.Size.Y+(sprite.spriteData.inAir or 0)
				if ff then sprite.offset = Vector3.new(0, -y, 0) return end
				Tween(.9, 'easeOutCubic', function(a)
					sprite.offset = Vector3.new(0, a*-y, 0)
				end)
				return pokemon:getName() .. ' hid underwater!'
			end,
			fly = function(pokemon, _, _, _, ff)
				local sprite = pokemon.sprite
				if ff then sprite.offset = Vector3.new(0, 10, 0) return end
				Tween(1, 'easeInCubic', function(a)
					sprite.offset = Vector3.new(0, 10*a, 0)
				end)
				return pokemon:getName() .. ' flew up high!'
			end,
			freezeshock = function(pokemon, _, _, _, ff)
				-- todo
				return pokemon:getName() .. ' became cloaked in a freezing light!'
			end,
			geomancy = function(pokemon, _, _, _, ff)
				-- todo?
				return pokemon:getName() .. ' is absorbing power!'
			end,
			iceburn = function(pokemon, _, _, _, ff)
				-- todo
				return pokemon:getName() .. ' became cloaked in freezing air!'
			end,
			razorwind = function(pokemon, _, _, _, ff)
				-- todo
				return pokemon:getName() .. ' whipped up a whirlwind!'
			end,
			shadowforce = function(pokemon, _, _, _, ff)
				local spriteLabel = pokemon.sprite.animation.spriteLabel
				if ff then spriteLabel.ImageTransparency = 1.0 return end
				Tween(.5, 'easeOutCubic', function(a)
					spriteLabel.ImageTransparency = a
				end)
				return pokemon:getName() .. ' vanished instantly!'
			end,
			solarbeam = function(pokemon, _, _, _, ff)
				-- todo
				return pokemon:getName() .. ' absorbed light!'
			end,
			skullbash = function(pokemon, _, _, _, ff)
				-- todo
				return pokemon:getName() .. ' tucked in its head!'
			end,
			skyattack = function(pokemon, _, _, _, ff)
				-- todo
				return pokemon:getName() .. ' became cloaked in a harsh light!'
			end,
			skydrop = function(pokemon, target, _, _, ff)
				if not target then return end
				target.skydropper = pokemon
				local sprite = pokemon.sprite
				local sp = sprite.offset
				local ep = (target.sprite.cf.p - sprite.cf.p)*Vector3.new(.9,0,.9)+Vector3.new(0, target.sprite.part.Size.Y*.3, 0)
				if ff then
					sprite.offset = ep + Vector3.new(0, 10, 0)
					target.sprite.offset = Vector3.new(0, 10, 0)
					return
				end
				Tween(.6, nil, function(a)
					sprite.offset = sp + (ep-sp)*a
				end)
				Tween(1, 'easeInCubic', function(a)
					local rise = Vector3.new(0, 10*a, 0)
					sprite.offset = ep+rise
					target.sprite.offset = rise
				end)
				return pokemon:getName() .. ' took ' .. target:getLowerName() .. ' into the sky!'
			end
		},

		-- REGULAR MOVE ANIMS

		absorb = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			absorb(pokemon, target)
			return true
		end,
		aerialace = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Medium blue')
			return 'sound'
		end,
		branchpoke = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Earth Green')
			return 'sound'
		end,	


		aurasphere = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			local sprite = pokemon.sprite
			local centroid = targetPoint(pokemon, 2.5)
			local cf = CFrame.new(centroid, centroid + workspace.CurrentCamera.CFrame.lookVector)
			local function makeParticle(hue)
				local p = create 'Part' {
					Transparency = 1.0,
					Anchored = true,
					CanCollide = false,
					Size = Vector3.new(.2, .2, .2),
					Parent = workspace,
				}
				local bbg = create 'BillboardGui' {
					Adornee = p,
					Size = UDim2.new(.7, 0, .7, 0),
					Parent = p,
					create 'ImageLabel' {
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://6294357140',
						ImageTransparency = .15,
						ImageColor3 = Color3.fromHSV(hue/360, 1, .85),
						Size = UDim2.new(1.0, 0, 1.0, 0),
						ZIndex = 2
					}
				}
				return p, bbg
			end
			local main, mbg = makeParticle(260)
			main.CFrame = cf
			local allParticles = {main}
			delay(.3, function()
				local rand = math.random
				for i = 2, 11 do
					local theta = rand()*6.28
					local offset = Vector3.new(math.cos(theta), math.sin(theta), .5)
					local p, b = makeParticle(rand(175, 230))
					allParticles[i] = p
					local r = math.random()*.35+.2
					spawn(function()
						local st = tick()
						local function o(r)
							local et = (tick()-st)*7
							p.CFrame = cf * CFrame.new(offset*r+.125*Vector3.new(math.cos(et), math.sin(et)*math.cos(et), 0))
						end
						Tween(.2, 'easeOutCubic', function(a)
							if not p.Parent then return false end
							b.Size = UDim2.new(.5*a, 0, .5*a, 0)
							o(r+.6)
						end)
						Tween(.25, 'easeOutCubic', function(a)
							if not p.Parent then return false end
							o(r+.6*(1-a))
						end)
						while p.Parent do
							o(r)
							stepped:wait()
						end
					end)
					task.wait(.1)
				end
			end)
			Tween(1.5, nil, function(a)
				mbg.Size = UDim2.new(2.5*a, 0, 2.5*a, 0)
			end)
			task.wait(.3)
			local targPos = targetPoint(target)
			local dp = targPos - centroid
			local v = 30
			local scf = cf
			Tween(dp.magnitude/v, nil, function(a)
				cf = scf + dp*a
				main.CFrame = cf
			end)
			for _, p in pairs(allParticles) do
				p:Destroy()
			end
			return true -- perform usual hit anim
		end,
		fleurcannon = function(p770, p771, p772) --- Rainbow blast
			local v2194 = p771[1];
			if not v2194 then
				return;
			end;
			local v2195 = targetPoint(p770);
			local v2196 = targetPoint(v2194);
			local v2197 = v2196 - v2195;
			local v2198 = CFrame.new(v2195, v2196) * CFrame.new(0, 0, -1);
			local v2199 = { Color3.fromRGB(255, 0, 0), Color3.fromRGB(248, 129, 60), Color3.fromRGB(255, 240, 17), Color3.fromRGB(0, 255, 0), Color3.fromRGB(9, 137, 207), Color3.fromRGB(71, 24, 158), Color3.fromRGB(152, 71, 177) };
			local v2200 = {};
			for v2201, v2202 in pairs(v2199) do
				local v2203 = Utilities.Create("Part")({
					Anchored = true, 
					CanCollide = false, 
					Shape = "Ball", 
					Size = Vector3.new(0.2, 0.2, 0.2), 
					Color = v2202, 
					Material = "Neon", 
					Transparency = 1, 
					CFrame = v2198, 
					Parent = p772.scene
				});
				local v2204 = Instance.new("Attachment", v2203);
				v2204.Position = Vector3.new(0, 0.1, 0);
				local v2205 = v2204:Clone();
				v2205.Position = Vector3.new(0, -0.1, 0);
				v2205.Parent = v2203;
				local v2206 = Utilities.Create("Trail")({
					Color = ColorSequence.new(v2202), 
					Transparency = NumberSequence.new(0, 1), 
					WidthScale = NumberSequence.new(1, 0), 
					Attachment0 = v2204, 
					Attachment1 = v2205, 
					Lifetime = 1, 
					LightEmission = 1, 
					Parent = v2203
				});
				table.insert(v2200, {
					part = v2203, 
					pos = v2201, 
					rot = 2 * math.pi * v2201 / #v2199, 
					radius = 0
				});
			end;
			local u433 = v2200;
			local u434 = 2;
			RunService:BindToRenderStep("rainbowblast", Enum.RenderPriority.Camera.Value - 1, function()
				for v2207, v2208 in ipairs(u433) do
					v2208.rot = v2208.rot + math.rad(u434);
					v2208.part.CFrame = v2198 * CFrame.new(v2208.radius * math.cos(v2208.rot), v2208.radius * math.sin(v2208.rot), 0);
				end;
			end);
			u13.Tween(TweenInfo.new(0.5), true, function(p773)
				local v2209 = 3 * p773;
				local v2210 = 0.1 + 0.4 * p773;
				u434 = 5 - 3 * p773;
				for v2211, v2212 in ipairs(u433) do
					v2212.part.Transparency = 1 - p773;
					v2212.part.Size = Vector3.new(v2210, v2210, v2210);
					v2212.radius = v2209;
				end;
			end);
			u13.Tween(TweenInfo.new(1), true, function(p774)
				u434 = 2 + 4 * p774;
			end);
			RunService:UnbindFromRenderStep("rainbowblast");
			u13.Tween(TweenInfo.new(0.05), true, function(p775)
				local v2213 = 3 - 2.5 * p775;
				for v2214, v2215 in ipairs(u433) do
					v2215.radius = v2213;
					v2215.part.CFrame = v2198 * CFrame.new(v2215.radius * math.cos(v2215.rot), v2215.radius * math.sin(v2215.rot), 0);
				end;
			end);
			for v2216 = #u433, 1, -1 do
				u433[v2216].part:Destroy();
				table.remove(u433, v2216);
			end;
			u433 = {};
			u434 = 2;
			local v2217 = Instance.new("Attachment", workspace.Terrain);
			v2217.WorldCFrame = v2198 + v2197;
			local v2218 = Particles.Blast:Clone();
			v2218.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255));
			v2218.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1, 10), NumberSequenceKeypoint.new(1, 10) });
			v2218.Lifetime = NumberRange.new(1);
			v2218.Transparency = NumberSequence.new(0, 1);
			v2218.RotSpeed = NumberRange.new(180);
			v2218.Enabled = false;
			v2218.Parent = v2217;
			for v2219, v2220 in pairs(v2199) do
				local v2221 = Misc.HalfSpiral:Clone();
				v2221.Color = v2220;
				v2221.Size = Vector3.new(1, 1, 1);
				v2221.CFrame = v2198 * CFrame.Angles(math.pi / 2, v2219 * math.pi / 4, 0);
				v2221.Parent = p772.scene;
				local v2222 = Particles.SparkV2:Clone();
				v2222.Color = ColorSequence.new(v2220);
				v2222.Speed = NumberRange.new(20, 30);
				v2222.Size = NumberSequence.new(0.25, 0.1);
				v2222.Enabled = false;
				v2222.Acceleration = Vector3.new(0, 0, 0);
				v2222.Transparency = NumberSequence.new(0, 1);
				v2222.Parent = v2217;
				table.insert(u433, {
					part = v2221, 
					pos = v2219, 
					rot = v2219 * math.pi / 4, 
					particle = v2222
				});
			end;
			local v2223 = Utilities.Create("Part")({
				Anchored = true, 
				CanCollide = false, 
				Material = "Neon", 
				Color = Color3.fromRGB(255, 255, 255), 
				Size = Vector3.new(1, 1, 1), 
				CFrame = v2198, 
				Shape = "Ball", 
				Parent = p772.scene
			});
			local u435 = v2198;
			RunService:BindToRenderStep("rainbowblast2", Enum.RenderPriority.Camera.Value - 1, function()
				for v2224, v2225 in ipairs(u433) do
					v2225.rot = v2225.rot + math.rad(u434);
					v2225.part.CFrame = u435 * CFrame.Angles(math.pi / 2, v2225.rot, 0);
				end;
			end);
			u9("BigExplosion",1);
			local u436 = 1;
			spawn(function()
				for v2226 = 1, 7 do
					local v2227 = Misc.ThinRing:Clone();
					v2227.Color = Color3.fromRGB(255, 255, 255);
					v2227.CFrame = (v2198 + v2197 * v2226 / 7) * CFrame.Angles(math.pi / 2, 0, 0);
					v2227.Size = Vector3.new(u436, 0.1, u436);
					v2227.Parent = p772.scene;
					local v2228 = TweenInfo.new(0.1);
					local u437 = 5 + u436;
					u13.Tween(v2228, false, function(p776)
						v2227.Size = Vector3.new(u437 + u437 * p776, 0.1, u437 + u437 * p776);
					end).Completed:Connect(function()
						v2227:Destroy();
					end);
					task.wait();
				end;
			end);
			local v2229 = Instance.new("Attachment", workspace.Terrain);
			v2229.WorldCFrame = v2198;
			local v2230 = v2218:Clone();
			v2230.Parent = v2229;
			v2230:Emit(1);
			local magnitude_438 = v2197.magnitude;
			u13.Tween(TweenInfo.new(0.1), true, function(p777)
				u435 = v2198 + v2197 * p777 / 2;
				u434 = 3 + 10 * p777;
				u436 = 1 + 5 * p777;
				v2223.Size = Vector3.new(u436, u436, u436);
				for v2231, v2232 in ipairs(u433) do
					v2232.part.Size = Vector3.new(u436 - 0.5, magnitude_438 * p777, u436 - 0.5);
				end;
			end);
			local v2234 = v2223:Clone();
			v2234.CFrame = v2198 + v2197;
			v2234.Size = Vector3.new(3, 3, 3);
			v2234.Parent = p772.scene;
			local v2235 = Misc.ThinRing:Clone();
			v2235.Color = Color3.fromRGB(255, 255, 255);
			v2235.Size = Vector3.new(3, 0.1, 3);
			v2235.Parent = p772.scene;
			local v2236 = Misc.HitEffect1:Clone();
			v2236.Size = Vector3.new(6, 1, 6);
			v2236.Color = Color3.fromRGB(255, 255, 255);
			v2236.Parent = p772.scene;
			local v2237 = v2235:Clone();
			v2237.Parent = p772.scene;
			local v2238 = v2234:Clone();
			v2238.Shape = "Cylinder";
			v2238.CFrame = (v2198 + v2197 / 2) * CFrame.Angles(math.pi / 2, 0, math.pi / 2);
			v2238.Size = Vector3.new(magnitude_438 + u436 / 2, 0.5, 0.5);
			v2238.Parent = p772.scene;
			for v2239, v2240 in pairs(u433) do
				v2240.particle:Emit(20);
				v2240.particle.Enabled = true;
			end;
			spawn(function()
				u13.Tween(TweenInfo.new(0.2), true, function(p778)
					local v2241 = 3 + 7 * p778;
					v2234.Size = Vector3.new(v2241, v2241, v2241);
				end);
				v2218.Lifetime = NumberRange.new(1.5);
				v2218.Transparency = NumberSequence.new(0, 1);
				v2218.Size = NumberSequence.new(10, 30);
				spawn(function()
					for v2242 = 1, 10 do
						v2218:Emit(1);
						task.wait();
					end;
				end);
				delay(1, function()
					for v2243, v2244 in pairs(u433) do
						v2244.particle.Enabled = false;
					end;
				end);
				u13.Tween(TweenInfo.new(1.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), true, function(p779)
					local v2245 = 5 + 40 * p779;
					v2235.Size = Vector3.new(v2245, 0.5, v2245);
					v2237.Size = Vector3.new(v2245 * 1.25, 0.5, v2245 * 1.25);
					v2235.Transparency = p779;
					v2237.Transparency = p779;
					local v2246 = 10 + 15 * p779;
					v2234.Size = Vector3.new(v2246, v2246, v2246);
					v2236.Size = Vector3.new(6 + (v2245 - 11), 1 + 2 * p779, 6 + (v2245 - 11));
					v2236.Transparency = p779;
					v2234.Transparency = p779;
					v2223.Transparency = p779;
					v2238.Transparency = 1 - p779;
					for v2247, v2248 in pairs(u433) do
						v2248.part.Size = Vector3.new(6 - 6 * p779, magnitude_438, 6 - 6 * p779);
					end;
				end);
				for v2249, v2250 in pairs(u433) do
					v2250.part.Transparency = 1;
				end;
				RunService:UnbindFromRenderStep("rainbowblast2");
				u13.Tween(TweenInfo.new(0.5), true, function(p780)
					v2238.Transparency = p780;
					v2238.Size = Vector3.new(magnitude_438 + u436 / 2, 0.5 - 0.5 * p780, 0.5 - 0.5 * p780);
				end);
				v2238:Destroy();
				game.Debris:AddItem(v2217, 1);
				v2229:Destroy();
				v2235:Destroy();
				v2237:Destroy();
				v2223:Destroy();
				v2236:Destroy();
				v2234:Destroy();
				for v2251, v2252 in pairs(u433) do
					v2252.part:Destroy();
				end;
				u433 = nil;
			end);
			return true;
		end;
		triattack = function(p590, p591, p592) --- Elemental Burst
			local v1597 = p591[1];
			if not v1597 then
				return;
			end;
			local v1598 = targetPoint(p590);
			local v1599 = targetPoint(v1597);
			local v1600 = Instance.new("Part");
			v1600.Anchored = true;
			v1600.CanCollide = false;
			v1600.Shape = "Ball";
			v1600.Color = Color3.fromRGB(196, 40, 28);
			v1600.Material = "Neon";
			v1600.Transparency = 0.3;
			v1600.Size = Vector3.new(1, 1, 1);
			local v1601 = v1600:Clone();
			v1601.Color = Color3.fromRGB(245, 205, 48);
			local v1602 = v1600:Clone();
			v1602.Color = Color3.fromRGB(18, 238, 212);
			v1602.Transparency = 0.5;
			local v1603 = Particles.Fire:Clone();
			v1603.Parent = v1600;
			v1603.Enabled = true;
			local v1604 = Particles.ElementalTrail:Clone();
			local v1605 = Instance.new("Attachment", v1600);
			v1605.Position = Vector3.new(0, 0.5, 0);
			local v1606 = Instance.new("Attachment", v1600);
			v1606.Position = Vector3.new(0, -0.5, 0);
			v1604.Attachment0 = v1605;
			v1604.Attachment1 = v1606;
			v1604.Color = ColorSequence.new(v1600.Color);
			v1604.Parent = v1600;
			local v1607 = Particles.Lightning:Clone();
			v1607.Parent = v1601;
			v1607.Enabled = true;
			local v1608 = Particles.ElementalTrail:Clone();
			local v1609 = Instance.new("Attachment", v1601);
			v1609.Position = Vector3.new(0, 0.5, 0);
			local v1610 = Instance.new("Attachment", v1601);
			v1610.Position = Vector3.new(0, -0.5, 0);
			v1608.Attachment0 = v1609;
			v1608.Attachment1 = v1610;
			v1608.Color = ColorSequence.new(v1601.Color);
			v1608.Parent = v1601;
			local v1611 = Particles.Ice:Clone();
			v1611.Parent = v1602;
			v1611.Enabled = true;
			local v1612 = Particles.ElementalTrail:Clone();
			local v1613 = Instance.new("Attachment", v1602);
			v1613.Position = Vector3.new(0, 0.5, 0);
			local v1614 = Instance.new("Attachment", v1602);
			v1614.Position = Vector3.new(0, -0.5, 0);
			v1612.Attachment0 = v1613;
			v1612.Attachment1 = v1614;
			v1612.Color = ColorSequence.new(v1602.Color);
			v1612.Parent = v1602;
			local v1615 = CFrame.new(v1598, v1599) * CFrame.new(0, 0, -1.5);
			local v1616 = v1615 * CFrame.Angles(0, 0, math.pi / 2 + math.pi / 6);
			local v1617 = v1615 * CFrame.Angles(0, 0, -math.pi / 6 - math.pi / 2);
			v1600.CFrame = v1615;
			v1601.CFrame = v1615;
			v1602.CFrame = v1615;
			v1600.Parent = p592.scene;
			v1601.Parent = p592.scene;
			v1602.Parent = p592.scene;
			local v1618 = v1599 - v1615.p;
			local u325 = v1615;
			local u326 = 0.1;
			local u327 = v1616;
			local u328 = v1617;
			local u329 = 0;
			local u330 = 0;
			RunService:BindToRenderStep("Elemental Burst", Enum.RenderPriority.Camera.Value, function()
				u325 = u325 * CFrame.Angles(0, 0, u326);
				u327 = u327 * CFrame.Angles(0, 0, u326);
				u328 = u328 * CFrame.Angles(0, 0, u326);
				v1600.CFrame = u325 * CFrame.new(0, u329, -u330);
				v1601.CFrame = u327 * CFrame.new(0, u329, -u330);
				v1602.CFrame = u328 * CFrame.new(0, u329, -u330);
			end);
			u13.Tween(TweenInfo.new(1, Enum.EasingStyle.Cubic), true, function(p593)
				u329 = 5 * p593;
				local v1619 = 1 + 2 * p593;
				v1600.Size = Vector3.new(v1619, v1619, v1619);
				v1601.Size = v1600.Size;
				v1602.Size = v1600.Size;
			end);
			task.wait(0.1);
			local magnitude_331 = v1618.magnitude;
			u13.Tween(TweenInfo.new(0.45, Enum.EasingStyle.Cubic), true, function(p594)
				u329 = 5 - 4.8 * p594;
				u330 = magnitude_331 * p594;
				u326 = 0.1 + 0.3 * p594;
			end);
			RunService:UnbindFromRenderStep("Elemental Burst");
			local v1620 = CFrame.new(v1598, v1599) + v1618;
			local v1621 = v1600:Clone();
			v1600:Destroy();
			v1601:Destroy();
			v1602:Destroy();
			v1621:ClearAllChildren();
			v1621.CastShadow = false;
			v1621.Color = Color3.fromRGB(255, 255, 255);
			v1621.Transparency = 0;
			v1621.Size = Vector3.new(5, 5, 5);
			v1621.CFrame = v1620;
			local v1622 = Misc.ThinRing:Clone();
			v1622.Size = Vector3.new(3, 0.1, 3);
			v1622.Color = Color3.fromRGB(196, 40, 28);
			v1622.Material = "Neon";
			v1622.CFrame = v1620 * CFrame.Angles(2 * math.pi / 3, 0, 0);
			local v1623 = v1622:Clone();
			v1623.Color = Color3.fromRGB(245, 205, 48);
			v1623.CFrame = v1620 * CFrame.Angles(4 * math.pi / 3, 0, 0);
			local v1624 = v1622:Clone();
			v1624.Color = Color3.fromRGB(18, 238, 212);
			v1624.CFrame = v1620;
			local v1625 = Particles.Sparks:Clone();
			v1625.Rate = 100;
			v1625.Lifetime = NumberRange.new(1, 1.5);
			v1625.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255));
			v1625.Parent = v1621;
			v1621.Parent = p592.scene;
			v1622.Parent = p592.scene;
			v1623.Parent = p592.scene;
			v1624.Parent = p592.scene;
			spawn(function()
				u13.Tween(TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), false, function(p595)
					local v1626 = 3 + 25 * p595;
					local v1627 = 3 + 33 * p595;
					local v1628 = 3 + 30 * p595;
					v1622.Size = Vector3.new(v1626, 0.1, v1626);
					v1623.Size = Vector3.new(v1627, 0.1, v1627);
					v1624.Size = Vector3.new(v1628, 0.1, v1628);
					v1622.Transparency = p595;
					v1624.Transparency = p595;
					v1623.Transparency = p595;
				end);
				u13.Tween(TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), true, function(p596)
					local v1629 = 5 + 15 * p596;
					v1621.Size = Vector3.new(v1629, v1629, v1629);
					v1621.Transparency = 0.5 * p596;
				end);
				v1623:Destroy();
				v1622:Destroy();
				v1624:Destroy();
				u13.Tween(TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), true, function(p597)
					v1621.Transparency = 0.5 * p597 + 0.5;
				end);
				v1625.Enabled = false;
				v1621:Destroy();
			end);
			return true;
		end;
		fireblast = function(p590, p591, p592) --- Elemental Burst
			local v1597 = p591[1];
			if not v1597 then
				return;
			end;
			lightShift(Color3.fromRGB(192, 0, 0), Color3.fromRGB(128, 0, 0), Color3.fromRGB(255, 50, 50), Color3.fromRGB(255, 50, 50), 0.9)	
			local v1598 = targetPoint(p590);
			local v1599 = targetPoint(v1597);
			local v1600 = Instance.new("Part");
			v1600.Anchored = true;
			v1600.CanCollide = false;
			v1600.Shape = "Ball";
			v1600.Color = Color3.fromRGB(196, 40, 28);
			v1600.Material = "Neon";
			v1600.Transparency = 0.3;
			v1600.Size = Vector3.new(1.5, 1.5, 1.5);
			local v1601 = v1600:Clone();
			v1601.Color = Color3.fromRGB(196, 40, 28);
			local v1602 = v1600:Clone();
			v1602.Color = Color3.fromRGB(196, 40, 28);
			v1602.Transparency = 0.5;
			local v1603 = Particles.Fire:Clone();
			v1603.Parent = v1600;
			v1603.Enabled = true;
			local v1604 = Particles.ElementalTrail:Clone();
			local v1605 = Instance.new("Attachment", v1600);
			v1605.Position = Vector3.new(0, 0.5, 0);
			local v1606 = Instance.new("Attachment", v1600);
			v1606.Position = Vector3.new(0, -0.5, 0);
			v1604.Attachment0 = v1605;
			v1604.Attachment1 = v1606;
			v1604.Color = ColorSequence.new(v1600.Color);
			v1604.Parent = v1600;
			local v1607 = Particles.Fire:Clone();
			v1607.Parent = v1601;
			v1607.Enabled = true;
			local v1608 = Particles.ElementalTrail:Clone();
			local v1609 = Instance.new("Attachment", v1601);
			v1609.Position = Vector3.new(0, 0.5, 0);
			local v1610 = Instance.new("Attachment", v1601);
			v1610.Position = Vector3.new(0, -0.5, 0);
			v1608.Attachment0 = v1609;
			v1608.Attachment1 = v1610;
			v1608.Color = ColorSequence.new(v1601.Color);
			v1608.Parent = v1601;
			local v1611 = Particles.Fire:Clone();
			v1611.Parent = v1602;
			v1611.Enabled = true;
			local v1612 = Particles.ElementalTrail:Clone();
			local v1613 = Instance.new("Attachment", v1602);
			v1613.Position = Vector3.new(0, 0.5, 0);
			local v1614 = Instance.new("Attachment", v1602);
			v1614.Position = Vector3.new(0, -0.5, 0);
			v1612.Attachment0 = v1613;
			v1612.Attachment1 = v1614;
			v1612.Color = ColorSequence.new(v1602.Color);
			v1612.Parent = v1602;
			local v1615 = CFrame.new(v1598, v1599) * CFrame.new(0, 0, -1.5);
			local v1616 = v1615 * CFrame.Angles(0, 0, math.pi / 2 + math.pi / 6);
			local v1617 = v1615 * CFrame.Angles(0, 0, -math.pi / 6 - math.pi / 2);
			v1600.CFrame = v1615;
			v1601.CFrame = v1615;
			v1602.CFrame = v1615;
			v1600.Parent = p592.scene;
			v1601.Parent = p592.scene;
			v1602.Parent = p592.scene;
			local v1618 = v1599 - v1615.p;
			local u325 = v1615;
			local u326 = 0.1;
			local u327 = v1616;
			local u328 = v1617;
			local u329 = 0;
			local u330 = 0;
			RunService:BindToRenderStep("Elemental Burst", Enum.RenderPriority.Camera.Value, function()
				u325 = u325 * CFrame.Angles(0, 0, u326);
				u327 = u327 * CFrame.Angles(0, 0, u326);
				u328 = u328 * CFrame.Angles(0, 0, u326);
				v1600.CFrame = u325 * CFrame.new(0, u329, -u330);
				v1601.CFrame = u327 * CFrame.new(0, u329, -u330);
				v1602.CFrame = u328 * CFrame.new(0, u329, -u330);
			end);
			u13.Tween(TweenInfo.new(1, Enum.EasingStyle.Cubic), true, function(p593)
				u329 = 5 * p593;
				local v1619 = 1 + 2 * p593;
				v1600.Size = Vector3.new(v1619, v1619, v1619);
				v1601.Size = v1600.Size;
				v1602.Size = v1600.Size;
			end);
			task.wait(0.1);
			local magnitude_331 = v1618.magnitude;
			u13.Tween(TweenInfo.new(0.45, Enum.EasingStyle.Cubic), true, function(p594)
				u329 = 5 - 4.8 * p594;
				u330 = magnitude_331 * p594;
				u326 = 0.1 + 0.3 * p594;
			end);
			RunService:UnbindFromRenderStep("Elemental Burst");
			local v1620 = CFrame.new(v1598, v1599) + v1618;
			local v1621 = v1600:Clone();
			local v1630 = v1600:Clone();
			v1600:Destroy();
			v1601:Destroy();
			v1602:Destroy();
			v1621:ClearAllChildren();
			v1621.CastShadow = false;
			v1621.Color = Color3.fromRGB(196, 40, 28);
			v1621.Transparency = 0;
			v1621.Size = Vector3.new(5, 5, 5);
			v1621.CFrame = v1620;
			v1630.CastShadow = false;
			v1630.Color = Color3.fromRGB(245, 205, 48);
			v1630.Transparency = 0;
			v1630.Size = Vector3.new(3, 3, 3);
			v1630.CFrame = v1620;
			local v1622 = Misc.ThinRing:Clone();
			v1622.Size = Vector3.new(3, 0.1, 3);
			v1622.Color = Color3.fromRGB(196, 40, 28);
			v1622.Material = "Neon";
			v1622.CFrame = v1620 * CFrame.Angles(2 * math.pi / 3, 0, 0);
			local v1623 = v1622:Clone();
			v1623.Color = Color3.fromRGB(196, 40, 28);
			v1623.CFrame = v1620 * CFrame.Angles(4 * math.pi / 3, 0, 0);
			local v1624 = v1622:Clone();
			v1624.Color = Color3.fromRGB(196, 40, 28);
			v1624.CFrame = v1620;
			local v1625 = Particles.Fire:Clone();
			v1625.Rate = 100;
			v1625.Lifetime = NumberRange.new(1, 1.5);
			v1625.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0));
			v1625.Parent = v1621;
			v1621.Parent = p592.scene;
			v1630.Parent = p592.scene;
			v1622.Parent = p592.scene;
			v1623.Parent = p592.scene;
			v1624.Parent = p592.scene;
			spawn(function()
				u13.Tween(TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), false, function(p595)
					local v1626 = 3 + 25 * p595;
					local v1627 = 3 + 33 * p595;
					local v1628 = 3 + 30 * p595;
					v1622.Size = Vector3.new(v1626, 0.1, v1626);
					v1623.Size = Vector3.new(v1627, 0.1, v1627);
					v1624.Size = Vector3.new(v1628, 0.1, v1628);
					v1622.Transparency = p595;
					v1624.Transparency = p595;
					v1623.Transparency = p595;
				end);
				u13.Tween(TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), true, function(p596)
					local v1629 = 5 + 15 * p596;
					v1621.Size = Vector3.new(v1629, v1629, v1629);
					v1630.Size = Vector3.new(v1629*0.6, v1629*0.6, v1629*0.6);
					v1621.Transparency = 0.5 * p596;
					v1630.Transparency = 0.5 * p596;
				end);
				v1623:Destroy();
				v1622:Destroy();
				v1624:Destroy();
				u13.Tween(TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), true, function(p597)
					v1621.Transparency = 0.5 * p597 + 0.5;
					v1630.Transparency = 0.5 * p597 + 0.5;
				end);
				lightRestore(0.5)
				v1625.Enabled = false;
				v1621:Destroy();
				v1630:Destroy();
			end);
			return true;
		end;
		thunder = function(p398, p399, p400) --Storm Summon
			local v1070 = p399[1];
			if not v1070 then
				return;
			end;
			local v1071 = targetPoint(p398);
			local v1072 = targetPoint(v1070);
			local v1073 = CFrame.new(v1071, v1072);
			local v1074 = v1072 - v1071;
			local magnitude_1075 = v1074.magnitude;
			local v1076 = u13.MaxYFOV(v1072, v1071) + 2;
			local v1077 = v1073 + v1074 / 2;
			local v1078 = Particles.Gust:Clone();
			local v1079 = Utilities.Create("Part")({
				Anchored = true, 
				Size = Vector3.new(80, 1, 80), 
				Transparency = 1, 
				CanCollide = false, 
				CFrame = v1077 + Vector3.new(0, v1076, 0), 
				Parent = workspace
			});
			v1078.Color = ColorSequence.new(Color3.fromRGB(87, 87, 87), Color3.fromRGB(0, 0, 0));
			v1078.Acceleration = Vector3.new(0, 0, 0);
			v1078.Speed = NumberRange.new(0);
			v1078.Lifetime = NumberRange.new(2.5, 3.5);
			v1078.Rotation = NumberRange.new(-5, 5);
			v1078.RotSpeed = NumberRange.new(0);
			v1078.SpreadAngle = Vector2.new(5, 5);
			v1078.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1, 0.5), NumberSequenceKeypoint.new(0.5, 0.25), NumberSequenceKeypoint.new(1, 0.5) });
			v1078.Size = NumberSequence.new(10);
			v1078.Parent = v1079;
			v1078:Emit(50);
			spawn(function()
				while true do
					v1079.CFrame = v1079.CFrame * CFrame.Angles(0, 0.05, 0);
					task.wait();			
				end;
			end);
			--	local Brightness_228 = Lighting_37.Brightness;
			u13.Tween(TweenInfo.new(1), true, function(p401)
				--Lighting_37.Brightness = Brightness_228 - Brightness_228 * p401;
			end);
			local v1080 = CFrame.new(p399[1].sprite.cf.p);
			local v1081 = false;
			for v1082 = 1, 15 do
				local v1083 = u11:NextNumber() * 2 * math.pi;
				local v1084 = 5 + u11:NextNumber() * 15;
				local u229 = v1077.p + Vector3.new(v1084 * math.cos(v1083), 0, v1084 * math.sin(v1083));
				local u230 = v1081;
				spawn(function()
					local v1085 = Vector3.new(u229.x, v1080.y, u229.z);
					u13.BranchLightning(u229 + Vector3.new(0, v1076, 0), v1085, 5, 4, 0.25, Color3.fromRGB(245, 238, 159), 1);
					u230 = not u230;
					if u230 == true then
						u9("Bump", 1);
					end;
					u13.ballExplosion(TweenInfo.new(1, Enum.EasingStyle.Cubic), CFrame.new(v1085), 10, Color3.fromRGB(245, 238, 159), Color3.fromRGB(245, 238, 159), "Neon", "Neon");
				end);
				task.wait(0.05);
			end;
			v1078.Enabled = false;
			u13.Tween(TweenInfo.new(0.5), true, function(p402)
				--Lighting_37.Brightness = Brightness_228 * p402;
			end);
			game.Debris:AddItem(v1079, 2);
			return true;
		end;
		dracometeor = function(p681, p682, p683) --- Metal Burst
			local v1912 = p682[1];
			if not v1912 then
				return;
			end;
			local v1913 = targetPoint(v1912);
			local Ful1914 = p681.sprite.part
			local v1915 = Vector3.new(1, 0, 1);
			local v1916 = CFrame.new(targetPoint(p681) * v1915, v1913 * v1915);
			local v1917 = Utilities.Create("Part")({
				Anchored = true, 
				Shape = "Ball", 
				Material = "Neon", 
				Color = Color3.fromRGB(87, 87, 87), 
				CanCollide = false, 
				Size = Vector3.new(0.2, 0.2, 0.2), 
				Transparency = 1, 
				CFrame = CFrame.new(p681.sprite.cf.p + Vector3.new(0, Ful1914.Size.Y / 2, 0), v1913)
			});
			v1917.Parent = p683.scene;
			local u370 = true;
			local u371 = 0.5;
			spawn(function()
				while u370 == true do
					local v1918 = Misc.HitEffect2:Clone();
					v1918.Color = Color3.fromRGB(208, 59, 9);
					v1918.Material = "Neon";
					local v1919 = CFrame.Angles(math.pi / 2, 2 * math.pi * u11:NextNumber(), 0);
					v1918.CFrame = CFrame.new(v1917.Position) - Vector3.new(0, v1917.Size.Y / 2, 0);
					local CFrame_1920 = v1918.CFrame;
					v1918.Parent = p683.scene;
					local v1921 = Vector3.new(v1917.Size.X * 1.5, v1917.Size.X * 1.5, v1917.Size.X * 1.5);
					local v1922 = v1921 - Vector3.new(1, 0.2, 1);
					v1918.Size = v1921;
					u13.Tween(TweenInfo.new(u371), false, function(p684)
						v1918.Transparency = 0.5 + 0.5 * p684;
						v1918.CFrame = v1917.CFrame * v1919;
					end);
					game.Debris:AddItem(v1918, 0.5);
					task.wait(0.05);			
				end;
			end);
			local u372 = v1917.CFrame;
			local u373 = false;
			u13.Tween(TweenInfo.new(1), true, function(p685)
				v1917.CFrame = u372 + Vector3.new(0, 5 * p685, 0) - v1916.lookVector * 2.5 * p685;
				local v1923 = 0.2 + 7.8 * p685;
				v1917.Size = Vector3.new(v1923, v1923, v1923);
				if not u373 and p685 > 0.5 then
					u373 = true;
					v1917.Material = "Metal";
				end;
				v1917.Transparency = 1 - p685;
			end);
			u371 = u371 / 2;
			local v1924 = Misc.HitEffect2:Clone();
			v1924.Transparency = 0.5;
			v1924.Material = "Neon";
			v1924.Color = Color3.fromRGB(179, 0, 0);
			v1924.Size = Vector3.new(10, 10, 10);
			v1924.CFrame = v1917.CFrame * CFrame.Angles(math.pi / 2, 0, 0) * CFrame.new(0, -v1917.Size.Y / 4, 0);
			v1924.Parent = p683.scene;
			u372 = CFrame.new(v1917.Position, v1913);
			local v1925 = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out);
			local u374 = v1913 - v1917.Position;
			u13.Tween(v1925, false, function(p686)
				v1917.CFrame = u372 + u374 * p686;
				v1924.Size = Vector3.new(10 - 8 * p686, 10 + (u374.magnitude - 10) * p686, 10 - 8 * p686);
				v1924.CFrame = u372 * CFrame.Angles(math.pi / 2, 0, 0) + u374 / 2 * p686;
			end);
			task.wait(0.15);
			u370 = false;
			coroutine.wrap(function()
				local v1926 = v1924:Clone();
				v1926.CFrame = v1917.CFrame * CFrame.Angles(math.pi / 2, 0, 0);
				v1926.Size = Vector3.new(5, u374.magnitude, 5);
				v1926.Parent = p683.scene;
				u9("Explosion", 1);
				u13.ballExplosion(TweenInfo.new(1.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), CFrame.new(v1913), 24, Color3.fromRGB(141, 0, 0), Color3.fromRGB(255, 127, 42), "Neon", "Neon");
				u13.Tween(TweenInfo.new(0.75), true, function(p687)
					v1924.Transparency = 0.5 + 0.5 * p687;
					v1917.Transparency = p687;
					v1926.Size = Vector3.new(5 + 25 * p687, u374.magnitude - u374.magnitude * p687, 5 + 25 * p687);
					v1924.Size = Vector3.new(2 - 2 * p687, u374.magnitude, 2 - 2 * p687);
					v1926.Transparency = 0.5 + 0.5 * p687;
				end);
				v1924:Destroy();
				v1917:Destroy();
				v1926:Destroy();
			end)();
			return true;
		end;	
		psystrike = function(p569, p570, p571) --- Brainwash
			local v1564 = p570[1];
			if not v1564 then
				return;
			end;
			local v1565 = targetPoint(p569);
			local v1566 = targetPoint(v1564);
			local v1567 = {
				Color = ColorSequence.new(Color3.fromRGB(244, 158, 255)), 
				Transparency = NumberSequence.new(0, 1), 
				WidthScale = NumberSequence.new(1, 0), 
				LightEmission = 1, 
				Lifetime = 0.35
			};
			for v1568 = 1, 25 do
				local v1569 = Misc.Petal:Clone();
				v1569.Size = Vector3.new(1.25, 0.05, 0.9);
				v1569.Material = "Neon";
				local v1570 = Instance.new("Trail", v1569);
				v1570.Color = ColorSequence.new(Color3.fromRGB(244, 158, 255));
				v1570.LightEmission = 1;
				v1570.Lifetime = 0.5;
				v1570.WidthScale = NumberSequence.new(0, 1);
				local v1571 = Instance.new("Attachment", v1569);
				v1571.Position = Vector3.new(1, 0, 0);
				local v1572 = Instance.new("Attachment", v1569);
				v1572.Position = Vector3.new(0.9, 0, 0);
				v1570.Attachment0 = v1571;
				v1570.Attachment1 = v1572;
				local v1573 = -12 - 4 * u11:NextNumber();
				v1569.CFrame = CFrame.new((CFrame.new(v1566) * CFrame.Angles(-math.pi + math.pi * u11:NextNumber(), 2 * math.pi * u11:NextNumber(), 0) * CFrame.new(0, 0, -v1573)).Position, v1566);
				v1569.Parent = p571.scene;
				local CFrame_319 = v1569.CFrame;
				u13.Tween(TweenInfo.new(0.3), false, function(p572)
					v1569.CFrame = CFrame_319 * CFrame.new(0, 0, v1573 * p572) * CFrame.Angles(0, 0, 3 * math.pi * p572);
				end).Completed:Connect(function()
					local v1574 = v1569.CFrame + Vector3.new(u11:NextNumber(-1, 1), u11:NextNumber(-1, 1), u11:NextNumber(-1, 1));
					v1569.Transparency = 1;
					u13.trailSwirl(v1574, 0.25, 4, 0.2, 3 * math.pi, v1567, false);
					u13.ballExplosion(TweenInfo.new(0.75, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), v1574, 1.5, Color3.fromRGB(244, 158, 255), Color3.fromRGB(255, 255, 255), "Neon", "Neon");
				end);
				task.wait();
			end;
			task.wait(0.5);
			return true;
		end;
		eruption = function(p351, p352, p353) --- Magma Burst
			local v932 = p352[1];
			if not v932 then
				return;
			end;
			local v933 = targetPoint(p351);
			local v934 = targetPoint(v932);
			local v935 = CFrame.new(v933, v934);
			local magnitude_936 = (v934 - v933).magnitude;
			local v937 = CFrame.new(p352[1].sprite.cf.p);
			local v938 = Misc.Frustum:Clone();
			v938.Size = Vector3.new(12, 2, 12);
			v938.Color = Color3.fromRGB(108, 88, 75);
			v938.Material = "Slate";
			v938.CFrame = v937 + Vector3.new(0, -2, 0);
			local v939 = Utilities.Create("Part")({
				Anchored = true, 
				Transparency = 1, 
				CanCollide = false, 
				Material = "Neon", 
				Shape = "Cylinder", 
				Color = Color3.fromRGB(252, 102, 2), 
				Size = Vector3.new(0.5, 10.8, 10.8), 
				CFrame = (v937 + Vector3.new(0, 0.25, 0)) * CFrame.Angles(0, 0, math.pi / 2)
			});
			v938.Parent = p353.scene;
			v939.Parent = p353.scene;
			u13.Tween(TweenInfo.new(0.5), true, function(p354)
				v938.CFrame = v937 + Vector3.new(0, -2 + 3 * p354, 0);
			end);
			u13.Tween(TweenInfo.new(0.5), true, function(p355)
				v939.Transparency = 1 - p355;
			end);
			local v940 = v939:Clone();
			v940.Parent = p353.scene;
			local v941 = {
				Color = ColorSequence.new(Color3.fromRGB(218, 133, 65), Color3.fromRGB(255, 0, 0)), 
				Transparency = NumberSequence.new(0, 1), 
				WidthScale = NumberSequence.new(0.1, 1), 
				LightEmission = 0.5, 
				Lifetime = 1.5
			};
			local u194 = true;
			local u195 = 3 * math.pi;
			local u196 = 0.65 * v938.Size.X;
			coroutine.wrap(function()
				while u194 == true do
					local v942 = ({ -1, 1 })[u11:NextInteger(1, 2)];
					local u197 = 2 * u11:NextNumber();
					spawn(function()
						u13.makeSpiral(1, v937 * CFrame.Angles(0, u197 * math.pi, 0), u195 * v942, 30, u196, 5, TweenInfo.new(0.5, Enum.EasingStyle.Linear), nil, v941);
					end);
					task.wait();			
				end;
			end)();
			local v943 = Particles.Splash:Clone();
			v943.Color = ColorSequence.new(Color3.fromRGB(255, 107, 0), Color3.fromRGB(255, 0, 0));
			v943.Acceleration = Vector3.new(0, -5, 0);
			v943.Speed = NumberRange.new(10);
			v943.LightEmission = 1;
			v943.Enabled = false;
			v943:Emit(30);
			v943.SpreadAngle = Vector2.new(45, 45);
			v943.Parent = v938;
			local v944 = Instance.new("Attachment", workspace.Terrain);
			v944.WorldCFrame = v938.CFrame;
			local v945 = Particles.SparkV2:Clone();
			v945.Enabled = false;
			v945.Speed = NumberRange.new(25, 50);
			v945.Parent = v944;
			v945:Emit(80);
			u9("BigExplosion",1);
			for v946 = 1, 30 do
				local v947 = 1 + u11:NextNumber() * 2;
				local v948 = Utilities.Create("Part")({
					Size = Vector3.new(v947, v947, v947), 
					Color = Color3.fromRGB(77, 62, 53), 
					Material = "Slate", 
					CanCollide = false
				});
				v948.CFrame = v937 * CFrame.Angles(math.pi / 4 + math.pi / 4 * u11:NextNumber(), 2 * math.pi * u11:NextNumber(), 0) * CFrame.new(0, 0, -v947);
				v948.Velocity = v948.CFrame.LookVector * 75;
				v948.Parent = p353.scene;
				game.Debris:AddItem(v948, 1.5);
			end;
			u13.Tween(TweenInfo.new(0.5, Enum.EasingStyle.Cubic), true, function(p356)
				local v949 = v938.Size.X * 0.65 * p356;
				v940.Size = Vector3.new(0.5 + 50 * p356, v949, v949);
				v940.CFrame = (v937 + Vector3.new(0, -0.5 + 25 * p356, 0)) * CFrame.Angles(0, 0, math.pi / 2);
			end);
			task.wait(0.25);
			u194 = false;
			task.wait(0.1);
			local Size_198 = v940.Size;
			u13.Tween(TweenInfo.new(1), true, function(p357)
				local v950 = v938.Size.X * 0.55 * p357;
				v940.Size = Size_198 + Vector3.new(-v950, 0, -v950);
				v940.Transparency = p357;
			end);
			v940:Destroy();
			spawn(function()
				u13.Tween(TweenInfo.new(0.3), true, function(p358)
					v939.Transparency = p358;
				end);
				local CFrame_199 = v938.CFrame;
				u13.Tween(TweenInfo.new(0.5), true, function(p359)
					v938.CFrame = CFrame_199 + Vector3.new(0, -3 * p359, 0);
				end);
				v944:Destroy();
				v939:Destroy();
				v938:Destroy();
			end);
			return true;
		end;
		crunch = function(p307, p308, p309)
			local u170 = nil;
			local v778 = p308[1];
			if not v778 then
				return;
			end;
			local v779 = targetPoint(p307);
			local v780 = targetPoint(v778);
			local v781 = CFrame.new(v779, v780);
			local v782 = storage.Models.Misc.Bite:Clone();
			local Top_783 = v782.Top;
			local Bottom_784 = v782.Bottom;
			--	v782.anchored = true
			Top_783.Color = Color3.fromRGB(42, 42, 42);
			Bottom_784.Color = Color3.fromRGB(42, 42, 42);
			Top_783.Transparency = 1;
			Bottom_784.Transparency = 1;
			Top_783.Material = "Neon";
			Bottom_784.Material = "Neon";
			v782.PrimaryPart = v782.Main;
			v782:PivotTo(v781);
			local v785 = v780 - v779;
			Utilities.ScaleModel(v782.Main, 3);
			v782.Parent = p309.scene;
			local v786 = v782.Main.CFrame:inverse();
			local X_787 = Top_783.Size.X;
			v782:PivotTo(v781);
			local v788 = TweenInfo.new(0.6);
			local u171 = v786 * Top_783.CFrame;
			local u172 = v786 * Bottom_784.CFrame;
			u13.Tween(v788, true, function(p310)
				local v789 = 1 - p310;
				local v790 = CFrame.new(0, 0, -1 * v789);
				local v791 = 0.4 - 0.4 * v789;
				Top_783.CFrame = v782.PrimaryPart.CFrame * v790 * CFrame.Angles(v791, 0, 0) * u171;
				Bottom_784.CFrame = v782.PrimaryPart.CFrame * v790 * CFrame.Angles(-v791, 0, 0) * u172;
				Top_783.Transparency = 1 - p310;
				Bottom_784.Transparency = 1 - p310;
			end);
			for v792 = 1, 5 do
				local v793 = Misc.HalfCircle:Clone();
				v793.Color = Color3.fromRGB(0, 0, 0);
				v793.Material = "SmoothPlastic";
				v793.Transparency = 0.5;
				v793.Parent = p309.scene;
				local v794 = TweenInfo.new(0.15);
				u170 = v785;
				local u173 = v781 * CFrame.new(X_787 * math.cos(2 * math.pi * v792 / 5), X_787 * math.sin(2 * math.pi * v792 / 5), 0);
				u13.Tween(v794, false, function(p311)
					v793.Size = Vector3.new(0.1, 0.1 + u170.magnitude * p311, 0.1);
					v793.CFrame = u173 * CFrame.new(0, 0, -u170.magnitude * p311 / 2) * CFrame.Angles(math.pi / 2, 0, 0);
				end);
				game.Debris:AddItem(v793, 0.15);
			end;
			spawn(function()
				for v795 = 1, 5 do
					local v796 = Misc.ThinRing:Clone();
					v796.Color = Color3.fromRGB(0, 0, 0);
					v796.Size = Vector3.new(1, 0.1, 1);
					v796.CFrame = v781 * CFrame.new(0, 0, -u170.magnitude * v795 / 5) * CFrame.Angles(math.pi / 2, 0, 0);
					v796.Parent = p309.scene;
					u13.Tween(TweenInfo.new(0.15), false, function(p312)
						v796.Size = Vector3.new(1 + 15 * p312, 0.1, 1 + 15 * p312);
						v796.Transparency = p312;
					end);
					game.Debris:AddItem(v796, 0.15);
					task.wait(0.03);
				end;
			end);
			local CFrame_174 = v782.PrimaryPart.CFrame;
			u13.Tween(TweenInfo.new(0.15), true, function(p313)
				local v797 = 1 - p313;
				local v798 = CFrame.new(0, 0, -1 * v797);
				local v799 = 0.9 * v797;
				v782:PivotTo(CFrame_174 + (u170 - u170.unit * Top_783.Size.X) * p313);
				Top_783.CFrame = v782.PrimaryPart.CFrame * v798 * CFrame.Angles(v799, 0, 0) * u171;
				Bottom_784.CFrame = v782.PrimaryPart.CFrame * v798 * CFrame.Angles(-v799, 0, 0) * u172;
			end);
			v782:Destroy();
			local v800 = v781 + u170;
			local v801 = Utilities.Create("Part")({
				Shape = "Ball", 
				Material = "Neon", 
				Size = Vector3.new(10, 10, 10), 
				Color = Color3.fromRGB(0, 0, 0), 
				Anchored = true, 
				CanCollide = false, 
				CFrame = v800
			});
			local v802 = Utilities.Create("Part")({
				Shape = "Cylinder", 
				Size = Vector3.new(1, 10, 10), 
				Material = "Neon", 
				Color = Color3.fromRGB(0, 0, 0), 
				Anchored = true, 
				CanCollide = false, 
				CFrame = CFrame.new(v800.p) * CFrame.Angles(0, math.pi / 2, math.pi / 2)
			});
			v802.Parent = p309.scene;
			v801.Parent = p309.scene;
			--	local v803 = CFrame.new(5, 1.9, 9);
			local u175 = 5 * math.pi;
			local v804 = Misc.ThinRing:Clone();
			v804.Color = Color3.fromRGB(0, 0, 0);
			v804.Size = Vector3.new(1, 0.1, 1);
			v804.CFrame = CFrame.new(v780);
			local u176 = {
				Color = ColorSequence.new(Color3.fromRGB(0, 0, 0)), 
				Transparency = NumberSequence.new(0, 1), 
				WidthScale = NumberSequence.new(0, 1), 
				LightEmission = 0, 
				Lifetime = 0.7
			};
			coroutine.wrap(function()
				u13.makeSpiral(5, (v800 - Vector3.new(0, 20, 0)) * CFrame.Angles(0, 0, 0), u175, 40, 5, 0.5, TweenInfo.new(0.35, Enum.EasingStyle.Linear), nil, u176);
			end)();
			v804.Parent = p309.scene;
			local v805 = Color3.fromRGB(0, 0, 0);
			u13.Tween(TweenInfo.new(0.7), false, function(p314)
				local v806 = 10 + 10 * p314;
				v801.Size = Vector3.new(v806, v806, v806);
				v801.Transparency = p314;
				v802.Transparency = p314;
				v802.Size = Vector3.new(1 + 30 * p314, 10 - 10 * p314, 10 - 10 * p314);
				v804.Size = Vector3.new(50 * p314, 0.1, 50 * p314);
				v804.Transparency = p314;
			end).Completed:Connect(function()
				v801:Destroy();
				v802:Destroy();
				v804:Destroy();
			end);
			return true;
		end;
		bounce = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			local sprite = pokemon.sprite
			local ep = (target.sprite.cf.p - sprite.cf.p)*Vector3.new(.9,0,.9)
			local sp = ep+Vector3.new(0, 10, 0)--sprite.offset
			Tween(.3, nil, function(a)
				sprite.offset = sp + (ep-sp)*a
			end)
			spawn(function()
				task.wait(.1)
				Tween(1, 'easeOutCubic', function(a)
					sprite.offset = ep*(1-a)
				end)
			end)
			return true -- perform usual hit anim
		end,
		stealthrock = function(pokemon, swap)
			stealthrock(pokemon, swap)
		end,
		stickyweb = function(poke, swap)
			stickyweb(poke, swap)
		end,
		swordsdance = function(poke)
			local cf = poke.sprite.part.CFrame * CFrame.new(0, poke.sprite.part.Size.Y / 2, 0)
			local part = create("Part")({
				BrickColor = BrickColor.new("Dark stone grey"), 
				Reflectance = 0.4, 
				Anchored = true, 
				CanCollide = false, 
				Size = Vector3.new(1, 0.8, 4) * 0.6, 
				Parent = workspace,
				create("SpecialMesh")({
					MeshType = Enum.MeshType.FileMesh, 
					MeshId = "rbxasset://fonts/sword.mesh", 
					TextureId = "rbxasset://textures/SwordTexture.png", 
					Scale = Vector3.new(0.6, 0.6, 0.6)
				})
			});
			local Swords = {};
			for i = 1, 6 do
				local cpart = i == 1 and part or part:Clone()
				cpart.Parent = workspace
				Swords[cpart] = cf * CFrame.Angles(0, math.pi / 3 * i, 0) * CFrame.new(0, 0, 2) * CFrame.Angles(-math.pi / 2, 0, 0)
			end;
			local cf2 = CFrame.new(Vector3.new(0, 0, 0.85) * 0.6)
			Tween(0.6, nil, function(a)
				for i, v in pairs(Swords) do
					i.CFrame = v * CFrame.Angles(0, -math.pi * a, 0) * cf2
				end
			end)
			for i, v in pairs(Swords) do
				Swords[i] = v * CFrame.Angles(0, -math.pi, 0)
			end
			Tween(0.6, nil, function(a)
				for i, v in pairs(Swords) do
					i.CFrame = v * CFrame.Angles(0, 0, math.pi / 2 * a) * CFrame.Angles(0, -math.pi * a, 0) * cf2
				end
			end)
			for i, v in pairs(Swords) do
				Swords[i] = v * CFrame.Angles(0, 0, math.pi / 2) * CFrame.Angles(0, -math.pi, 0)
			end
			task.wait(0.3)
			delay(0.25, function()
				Utilities.sound("rbxasset://sounds/unsheath.wav", 1, nil, 2)
			end)
			Tween(0.4, nil, function(a)
				for i, v in pairs(Swords) do
					i.CFrame = v * CFrame.Angles(0, -0.9 * a, 0) * CFrame.new(0, 0, 0.6 * a) * cf2 + Vector3.new(0, 0.3 * a, 0);
				end
			end)
			task.wait(0.5);
			for i, v in pairs(Swords) do
				i:Destroy()
			end
		end,	

		darkpulse = function (poke, targets)
			local targ = targetPoint(poke)
			for i = 1, 3 do
				spawn(function()
					local part = create("Part")({
						BrickColor = BrickColor.new("Black"), 
						Transparency = 0.5, 
						Anchored = true, 
						CanCollide = false, 
						Size = Vector3.new(1, 1, 1), 
						Parent = workspace
					})
					part.CFrame = poke.sprite.part.CFrame * CFrame.Angles(math.pi / 2, 0, 0)
					local sMesh = create("SpecialMesh")({
						MeshType = Enum.MeshType.FileMesh, 
						MeshId = "rbxassetid://3270017", 
						Parent = part
					})
					Tween(0.5, nil, function(a)
						local num = a * 25
						sMesh.Scale = Vector3.new(num, num, 1)
						if a > 0.75 then
							part.Transparency = 0.5 + 0.5 * ((a - 0.75) * 4)
						end
					end)
					part:Destroy()
				end)
				task.wait(0.1)
			end
			task.wait(0.25)
			return true
		end,	

		rockblast = function(poke, targets)
			local target = targets[1]; if not target then return end
			local targ = targetPoint(poke)
			local targ2 = targetPoint(target) - targ
			local Boulder = create("Part")({
				Anchored = true, 
				CanCollide = false, 
				BrickColor = BrickColor.new("Dirt brown"), 
				Size = Vector3.new(1.4, 1.4, 1.4), 
				Parent = workspace,
				create("SpecialMesh")({
					MeshType = Enum.MeshType.FileMesh, 
					MeshId = "rbxassetid://1290033", 
					Scale = Vector3.new(0.8, 0.8, 0.8)
				})
			});
			local cf = CFrame.new(targ) * CFrame.Angles(math.pi * 2 * math.random(), math.pi * 2 * math.random(), math.pi * 2 * math.random())
			Tween(0.4, nil, function(a)
				Boulder.CFrame = cf + targ2 * a
			end)
			Boulder:Destroy()
			return true
		end,	

		bulletseed = function(poke, targets)
			local target = targets[1]
			if not target then
				return true
			end
			local targ = targetPoint(poke)
			local targ2 = targetPoint(target) - targ
			for i = 1, 4 do
				spawn(function()
					local part = create("Part")({
						BrickColor = BrickColor.new("Olive"), 
						Anchored = true, 
						CanCollide = false, 
						TopSurface = Enum.SurfaceType.Smooth, 
						BottomSurface = Enum.SurfaceType.Smooth, 
						Shape = Enum.PartType.Ball, 
						Size = Vector3.new(0.5, 0.5, 0.5), 
						Parent = workspace
					})
					Tween(0.4, nil, function(a)
						part.CFrame = CFrame.new(targ + targ2 * a)
					end)
					part:Destroy()
				end)
				task.wait(0.15)
			end
			task.wait(0.25)
			return true
		end,	



		shadowclaw = function(p90, targets, p92)
			local target = targets[1];
			if not target then
				return;
			end;
			local v211 = targetPoint(target);
			local v212 = Instance.new("Attachment", workspace.Terrain);
			v212.WorldCFrame = CFrame.new(v211);
			local v213 = Particles.SparkV2:Clone();
			v213.Enabled = false;
			v213.Color = ColorSequence.new(Color3.fromRGB(93, 22, 175));
			v213.Acceleration = Vector3.new(0, 0, 0);
			v213.Size = NumberSequence.new(0.1, 0.01);
			v213.Speed = NumberRange.new(10, 25);
			v213.Parent = v212;
			u13.ClawSlash(targetPoint(p90), v211, p92, Color3.fromRGB(89, 28, 150), Color3.fromRGB(84, 38, 148));
			v213:Emit(50);
			game.Debris:AddItem(v212, v213.Lifetime.Max);
			return true;
		end;	
		dragonclaw = function(p90, targets, p92)
			local target = targets[1];
			if not target then
				return;
			end;
			local v211 = targetPoint(target);
			local v212 = Instance.new("Attachment", workspace.Terrain);
			v212.WorldCFrame = CFrame.new(v211);
			local v213 = Particles.SparkV2:Clone();
			v213.Enabled = false;
			v213.Color = ColorSequence.new(Color3.fromRGB(55, 22, 175));
			v213.Acceleration = Vector3.new(0, 0, 0);
			v213.Size = NumberSequence.new(0.1, 0.01);
			v213.Speed = NumberRange.new(10, 25);
			v213.Parent = v212;
			u13.ClawSlash(targetPoint(p90), v211, p92, Color3.fromRGB(55, 28, 150), Color3.fromRGB(55, 38, 148));
			v213:Emit(50);
			game.Debris:AddItem(v212, v213.Lifetime.Max);
			return true;
		end;	
		aquacutter = function(p90, targets, p92)
			local target = targets[1];
			if not target then
				return;
			end;
			local v211 = targetPoint(target);
			local v212 = Instance.new("Attachment", workspace.Terrain);
			v212.WorldCFrame = CFrame.new(v211);
			local v213 = Particles.SparkV2:Clone();
			v213.Enabled = false;
			v213.Color = ColorSequence.new(Color3.fromRGB(15, 22, 255));
			v213.Acceleration = Vector3.new(0, 0, 0);
			v213.Size = NumberSequence.new(0.1, 0.01);
			v213.Speed = NumberRange.new(10, 25);
			v213.Parent = v212;
			u13.ClawSlash(targetPoint(p90), v211, p92, Color3.fromRGB(15, 28, 255), Color3.fromRGB(15, 238, 255));
			v213:Emit(50);
			game.Debris:AddItem(v212, v213.Lifetime.Max);
			return true;
		end;	
		nightslash = function(p90, targets, p92)
			local target = targets[1];
			if not target then
				return;
			end;
			local v211 = targetPoint(target);
			local v212 = Instance.new("Attachment", workspace.Terrain);
			v212.WorldCFrame = CFrame.new(v211);
			local v213 = Particles.SparkV2:Clone();
			v213.Enabled = false;
			v213.Color = ColorSequence.new(Color3.fromRGB(0,0,0));
			v213.Acceleration = Vector3.new(0, 0, 0);
			v213.Size = NumberSequence.new(0.1, 0.01);
			v213.Speed = NumberRange.new(10, 25);
			v213.Parent = v212;
			u13.ClawSlash(targetPoint(p90), v211, p92, Color3.fromRGB(0,0,0), Color3.fromRGB(0,0,0));
			v213:Emit(50);
			game.Debris:AddItem(v212, v213.Lifetime.Max);
			return true;
		end;	
		flashcannon = function(p350, p351, p352) -- reflectionburst
			local v677 = p351[1];
			if not v677 then return end
			local v678 = p350.sprite or p350;
			local v679 = v678.part.CFrame * Vector3.new(0, v678.part.Size.Y * 0.15, v678.part.Size.Z * -0.5 - 0);
			local v680 = v677.sprite or v677;
			local u322 = v680.part.CFrame * Vector3.new(0, v680.part.Size.Y * 0.15, v680.part.Size.Z * -0.5 - 0);
			local cf105 = CFrame.new(v679, u322);
			local u323 = u322 - v679;
			local magnitude26 = u323.magnitude;
			local table82 = {};
			local Attachment108 = Instance.new("Attachment", workspace.Terrain);
			Attachment108.WorldCFrame = CFrame.new(v679);
			local ParticleEmitter = Instance.new("ParticleEmitter");
			ParticleEmitter.Texture = "rbxassetid://2464873424";
			ParticleEmitter.Size = NumberSequence.new(12, 1);
			ParticleEmitter.Transparency = NumberSequence.new(0, 1);
			ParticleEmitter.RotSpeed = NumberRange.new(135);
			ParticleEmitter.Enabled = false;
			ParticleEmitter.Lifetime = NumberRange.new(1);
			ParticleEmitter.Speed = NumberRange.new(0);
			ParticleEmitter.Parent = Attachment108;
			ParticleEmitter:Emit(1);
			u13.Tween(TweenInfo.new(1), true, function(p568)
				for _, val86 in pairs(table82) do
					val86.part.Transparency = 1 - (1 - val86.t) * p568;
				end
			end);
			local u324 = Utilities.Create("Part")({
				Anchored = true,
				Color = Color3.fromRGB(255, 255, 255),
				CanCollide = false,
				Material = "Neon",
				Shape = "Cylinder",
				Size = Vector3.new(1, 1, 1),
				CFrame = cf105 * CFrame.Angles(0, math.pi / 2, 0)
			});
			u324.Parent = p352.scene;
			local Clone_ret301 = u324:Clone();
			Clone_ret301.Color = Color3.fromRGB(187, 187, 187);
			u13.Tween(TweenInfo.new(0.1), true, function(p570)
				u324.Size = Vector3.new(magnitude26 * p570, math.sin(p570) + 2, math.sin(p570) + 2);
				Clone_ret301.Size = Vector3.new(magnitude26 * p570, 3.2, 3.2);
				u324.CFrame = (cf105 + u323 / 2 * p570) * CFrame.Angles(0, math.pi / 2, 0);
				Clone_ret301.CFrame = u324.CFrame;
			end);

			for index65 = 1, 12 do
				local u393 = index65 * 3;
				local Clone_ret302 = Misc.PowerRing:Clone();
				Clone_ret302.Color = Color3.fromRGB(255, 255, 255);
				Clone_ret302.Size = Vector3.new(index65, 0.2, index65);
				Clone_ret302.Transparency = 0;
				Clone_ret302.CFrame = (cf105 + u323) * CFrame.Angles((index65 - 1) * 2 * math.pi / 3, 0, Random_new_ret:NextNumber(-math.pi / 4, math.pi / 4));
				Clone_ret302.Parent = p352.scene;
				local CFrame68 = Clone_ret302.CFrame;
				u13.Tween(TweenInfo.new(1 - index65 * 0.5 / 12), false, function(p622)
					Clone_ret302.Transparency = p622;
					Clone_ret302.Size = Vector3.new(index65 + u393 * p622, 0.2, index65 + u393 * p622);
					Clone_ret302.CFrame = CFrame68 * CFrame.Angles(0, math.pi * 5 / 3 * p622, 0);
				end);
				game.Debris:AddItem(Clone_ret302, 1);
			end

			u9("Explosion",1);

			u13.Tween(TweenInfo.new(1), true, function(p570)
				u324.Transparency = p570 * 0.9 + 0.1; -- Gradually increase transparency
			end);
			return true;
		end,
		visegrip = function(p333, p334, p335) -- clamp
			local v642 = p334[1];
			if not v642 then return end
			local v643 = p333.sprite or p333;
			local v644 = v643.part.CFrame * Vector3.new(0, v643.part.Size.Y * 0.15, v643.part.Size.Z * -0.5 - 0);
			local v645 = v642.sprite or v642;
			local v646 = v645.part.CFrame * Vector3.new(0, v645.part.Size.Y * 0.15, v645.part.Size.Z * -0.5 - 0);
			local _ = v646 - v644;
			local u309 = CFrame.new(v644, v646) * CFrame.new(0, 0, -3);
			local Clone_ret284 = Misc.Crescent:Clone();
			Clone_ret284:ClearAllChildren();
			Clone_ret284.Size = Vector3.new(8, 1.5, 3);
			Clone_ret284.Color = Color3.fromRGB(163, 162, 165);
			Clone_ret284.Material = "Metal";
			local cf101 = CFrame.new(-Clone_ret284.Size.X / 2, 0, -Clone_ret284.Size.Z / 2);
			local cf102 = CFrame.new(-Clone_ret284.Size.X / 2, 0, -Clone_ret284.Size.Z / 2);
			Clone_ret284.CFrame = u309 * CFrame.Angles(0, -math.pi / 2, 0) * cf101;
			local Clone_ret285 = Clone_ret284:Clone();
			Clone_ret285.CFrame = u309 * CFrame.Angles(math.pi, math.pi / 2, 0) * cf102;
			Clone_ret284.Parent = p335.scene;
			Clone_ret285.Parent = p335.scene;
			local u310 = v646 - u309.p;
			u13.Tween(TweenInfo.new(0.75), true, function(p563)
				local _ = (u310 - u310.unit * Clone_ret284.Size.X) * p563;
				Clone_ret284.CFrame = u309 * CFrame.Angles(0, -math.pi / 2 - math.pi / 3 * p563, 0) * cf101;
				Clone_ret285.CFrame = u309 * CFrame.Angles(math.pi, math.pi / 2 - math.pi / 3 * p563, 0) * cf102;
			end);
			u13.Tween(TweenInfo.new(0.1), true, function(p564)
				local v888 = (u310 - u310.unit * Clone_ret284.Size.X) * p564;
				Clone_ret284.CFrame = u309 * CFrame.Angles(0, -math.pi / 2 - math.pi / 3 + math.pi / 3 * p564, 0) * cf101 + v888;
				Clone_ret285.CFrame = u309 * CFrame.Angles(math.pi, math.pi / 2 - math.pi / 3 + math.pi / 3 * p564, 0) * cf102 + v888;
			end);
			local Clone_ret286 = Misc.HitEffect1:Clone();
			Clone_ret286.Material = "SmoothPlastic";
			Clone_ret286.Color = Color3.fromRGB(163, 162, 165);
			Clone_ret286.Transparency = 0.5;
			Clone_ret286.Size = Vector3.new(10, 2, 10);
			local Clone_ret287 = Clone_ret286:Clone();
			Clone_ret286.CFrame = (u309 + u310) * CFrame.Angles(0, 0, math.pi / 2) * CFrame.new(0, Clone_ret286.Size.Y / 2, 0);
			Clone_ret287.CFrame = (u309 + u310) * CFrame.Angles(0, 0, -math.pi / 2) * CFrame.new(0, Clone_ret286.Size.Y / 2, 0);
			Clone_ret286.Parent = p335.scene;
			Clone_ret287.Parent = p335.scene;
			local Size40 = Clone_ret286.Size;
			local CFrame65 = Clone_ret286.CFrame;
			local CFrame66 = Clone_ret287.CFrame;
			spawn(function()
				u13.Tween(TweenInfo.new(0.25), true, function(p667)
					Clone_ret284.Transparency = p667;
					Clone_ret285.Transparency = p667;
					Clone_ret286.Size = Size40 + Vector3.new(p667 * 4, p667 * 10, p667 * 4);
					Clone_ret287.Size = Clone_ret286.Size;
					Clone_ret286.CFrame = CFrame65 * CFrame.new(0, p667 * 5, 0);
					Clone_ret287.CFrame = CFrame66 * CFrame.new(0, p667 * 5, 0);
					Clone_ret286.Transparency = p667 * 0.5 + 0.5;
					Clone_ret287.Transparency = Clone_ret286.Transparency;
				end);
				Clone_ret284:Destroy();
				Clone_ret285:Destroy();
				Clone_ret286:Destroy();
				Clone_ret287:Destroy();
			end);
			return true;
		end,
		mudshot = function(p29, p30, p31) -- mudspatter
			local v23 = p30[1];
			if not v23 then return end
			local v24 = p29.sprite or p29;
			local v25 = v24.part.CFrame * Vector3.new(0, v24.part.Size.Y * 0.15, v24.part.Size.Z * -0.5 - 0);
			local v26 = v23.sprite or v23;
			local u25 = v26.part.CFrame * Vector3.new(0, v26.part.Size.Y * 0.15, v26.part.Size.Z * -0.5 - 0);
			local v27 = u25 - v25;
			local v28 = (v27.Magnitude * 2 / Vector3.new(0, -workspace.Gravity, 0).Magnitude) ^ 0.5;
			for index4 = 1, 9 do
				local v735 = (CFrame.new(v25, u25) * CFrame.new(Random_new_ret:NextInteger(-5, 5), Random_new_ret:NextInteger(8, 18), Random_new_ret:NextInteger(-3, -10)) + v27).p - v25;
				local vec3_3 = Vector3.new(0, -workspace.Gravity, 0);
				local Magnitude2 = v735.Magnitude;
				local Magnitude3 = vec3_3.Magnitude;
				local v736 = (Magnitude2 * 2 / Magnitude3) ^ 0.5;
				local v737 = (Magnitude3 * v735 - Magnitude2 * vec3_3) / (Magnitude3 * 2 * Magnitude2) ^ 0.5;
				local v738 = math.sqrt(Magnitude3 * 2 * Magnitude2 / 2) * 2 / Magnitude3;
				local v739 = v737 / (v738 / v736);
				local Clone_ret8 = Misc.MudSpatter:Clone();
				Clone_ret8.Color = Color3.fromRGB(109, 92, 80);
				local v740 = Random_new_ret:NextNumber() * 2;
				Clone_ret8.Size = Vector3.new(2, 0.1, 2) + Vector3.new(v740, 0, v740);
				local cf2 = CFrame.new(Vector3.new(), v739.unit);
				Clone_ret8.Anchored = false;
				Clone_ret8.Material = "Sand";
				Clone_ret8.Velocity = v739;
				Clone_ret8.CFrame = cf2 + v25;
				Clone_ret8.Parent = p31.scene;
				game.Debris:AddItem(Clone_ret8, v738);
				delay(v736, function()
					local Attachment = Instance.new("Attachment", workspace.Terrain);
					Attachment.WorldCFrame = CFrame.new(u25);
					local Clone_ret9 = Particles.MudSpatter:Clone();
					Clone_ret9.Parent = Attachment;
					Clone_ret9:Emit(6);
					game.Debris:AddItem(Attachment, 1);
				end);
				task.wait();
			end
			task.wait(v28);
			return true;
		end,
		acid = function(p370, p371, p372) -- corrode
			for index77 = 1, #p371 do
				spawn(function()
					local v955 = p371[index77];
					if not v955 then return end
					local v956 = p370;
					local v957 = v956.sprite or v956;
					local v958 = v957.part.CFrame * Vector3.new(0, v957.part.Size.Y * 0.15, v957.part.Size.Z * -0.5 - 0);
					local Model25 = v955.sprite.part;
					local Full10 = Model25;
					local v959 = Model25.Position + Vector3.new(0, Model25.Size.Y / 2, 0);
					local Position14 = Full10.Position;
					local v960 = u13.MaxYFOV(Position14, v958);
					local v961 = CFrame.new(Position14) + Vector3.new(0, v960, 0);
					for index114 = 1, 15 do
						local Clone_ret333 = Misc.Drop:Clone();
						Clone_ret333.Color = Color3.fromRGB(0, 255, 0);
						Clone_ret333.Material = "Neon";
						Clone_ret333.Size = Clone_ret333.Size * (Random_new_ret:NextNumber() * 0.4 + 0.8);
						local v988 = v961 + Vector3.new(Random_new_ret:NextNumber(-5, 5), 1, Random_new_ret:NextNumber(-5, 5));
						local u435 = v988.Y - v959.Y;
						Clone_ret333.CFrame = v988;
						Clone_ret333.Transparency = 1;
						Clone_ret333.Parent = p372.scene;
						u13.Tween(TweenInfo.new(0.2), false, function(p737)
							Clone_ret333.Transparency = 1 - p737;
						end);
						local CFrame78 = Clone_ret333.CFrame;
						u13.Tween(TweenInfo.new(0.75, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), false, function(p742)
							Clone_ret333.CFrame = CFrame78 - Vector3.new(0, (u435 * p742)+2, 0);
						end).Completed:Connect(function()
							local Size43 = Clone_ret333.Size;
							local CFrame79 = Clone_ret333.CFrame;
							local Clone_ret334 = Particles.Gust:Clone();
							Clone_ret334.Enabled = true;
							Clone_ret334.SpreadAngle = Vector2.new(-30, 30);
							Clone_ret334.LightEmission = 0;
							Clone_ret334.Transparency = NumberSequence.new(0.75, 1);
							Clone_ret334.Rate = 10;
							Clone_ret334.Lifetime = NumberRange.new(0.75, 1.25);
							Clone_ret334.Speed = NumberRange.new(1, 3);
							Clone_ret334.Parent = Clone_ret333;
							u13.Tween(TweenInfo.new(0.75, Enum.EasingStyle.Cubic), true, function(p746)
								Clone_ret333.Size = Size43 + Vector3.new(p746 * 3, -(Size43.Y * 0.9 * p746), p746 * 3);
								Clone_ret333.CFrame = CFrame79 + Vector3.new(0, 0, 0);
							end);
							task.wait(0.5);
							Clone_ret334.Enabled = false;
							u13.Tween(TweenInfo.new(1), true, function(p747)
								Clone_ret333.Transparency = p747;
							end);
							Clone_ret333:Destroy();
						end);
						task.wait(0.1);
					end
				end);
			end
			task.wait(2.5);
			return true;
		end,
		knockoff = function(p125, p126, p127) -- slapdown
			local v232 = p126[1];
			if not v232 then return end
			local v233 = p125.sprite or p125;
			local v234 = v233.part.CFrame * Vector3.new(0, v233.part.Size.Y * 0.15, v233.part.Size.Z * -0.5 - 0);
			local v235 = v232.sprite or v232;
			local v236 = v235.part.CFrame * Vector3.new(0, v235.part.Size.Y * 0.15, v235.part.Size.Z * -0.5 - 0);
			local Clone_ret81 = Misc.Slap:Clone();
			Clone_ret81.Size = Vector3.new(4.5, 6.5, 1);
			local u107 = v236 - v234;
			Clone_ret81.Color = Color3.fromRGB(52, 39, 32);
			local cf32 = CFrame.new(v234, v236);
			local u108 = cf32 * CFrame.new(0, 0, -Clone_ret81.Size.Y / 2);
			Clone_ret81.CFrame = u108 * CFrame.Angles(0, -math.pi / 2, math.pi / 2);
			Clone_ret81.Parent = p127.scene;
			u13.Tween(TweenInfo.new(0.45, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), true, function(p454)
				Clone_ret81.CFrame = u108 * CFrame.Angles(0, -math.pi / 2 * p454, 0) * CFrame.new(Clone_ret81.Size.X / 2 * p454, 0, -Clone_ret81.Size.Y / 2 * p454) * CFrame.Angles(0, -math.pi / 2, math.pi / 2);
			end);
			task.wait(0.1);
			u13.Tween(TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), false, function(p455)
				Clone_ret81.CFrame = u108 * CFrame.Angles(0, math.pi / 2 * p455 - math.pi / 6, 0) * CFrame.new(0, 0, -u107.magnitude * p455) * CFrame.Angles(0, -math.pi / 2, math.pi / 2);
			end);
			local coroutine_wrap_ret11 = coroutine.wrap(function()
				u13.Tween(TweenInfo.new(0.5, Enum.EasingStyle.Linear), true, function(p675)
					Clone_ret81.Transparency = p675;
				end);
				Clone_ret81:Destroy();
			end);
			coroutine_wrap_ret11();
			local Clone_ret82 = Misc.HitEffect1:Clone();
			Clone_ret82.Transparency = 0.1;
			Clone_ret82.Color = Color3.fromRGB(81, 68, 59);
			Clone_ret82.Size = Vector3.new(15, 12, 15);
			local Clone_ret83 = Clone_ret82:Clone();
			Clone_ret83.Size = Vector3.new(7.5, 35, 7.5);
			Clone_ret83.Color = Color3.fromRGB(59, 50, 43);
			local u109 = (cf32 + u107) * CFrame.Angles(0, -math.pi / 2, -math.pi / 2) * CFrame.new(0, Clone_ret82.Size.Y / 2, 0);
			local u110 = (cf32 + u107) * CFrame.Angles(0, -math.pi / 2, -math.pi / 2) * CFrame.new(0, Clone_ret83.Size.Y / 2, 0);
			Clone_ret82.CFrame = u109;
			Clone_ret83.CFrame = u110;
			Clone_ret82.Parent = p127.scene;
			Clone_ret83.Parent = p127.scene;
			local Clone_ret84 = Misc.ThinRing:Clone();
			Clone_ret84.Color = Color3.fromRGB(59, 50, 43);
			Clone_ret84.CFrame = (cf32 + u107) * CFrame.Angles(math.pi / 2, 0, 0);
			Clone_ret84.Size = Vector3.new(15, 0.1, 15);
			Clone_ret84.Parent = p127.scene;
			local Size16 = Clone_ret82.Size;
			local Size17 = Clone_ret83.Size;
			local Size18 = Clone_ret84.Size;
			spawn(function()
				u13.Tween(TweenInfo.new(0.5, Enum.EasingStyle.Cubic), true, function(p637)
					Clone_ret82.Size = Size16 + Vector3.new(p637 * 5, p637 * -8, p637 * 5);
					Clone_ret82.CFrame = u109 * CFrame.new(0, p637 * -4, 0);
					Clone_ret83.Size = Size17 - Vector3.new(p637 * 5.5, p637 * 30, p637 * 5.5);
					Clone_ret83.CFrame = u110 * CFrame.new(0, p637 * -15, 0);
					Clone_ret84.Size = Size18 + Vector3.new(p637 * 25, 0, p637 * 25);
					Clone_ret84.Transparency = p637 * 0.9 + 0.1;
					Clone_ret83.Transparency = p637 * 0.9 + 0.1;
					Clone_ret82.Transparency = p637 * 0.9 + 0.1;
				end);
				Clone_ret82:Destroy();
				Clone_ret83:Destroy();
				Clone_ret84:Destroy();
			end);
			return true;
		end,
		payback = function(p150, p151, p152) -- rant
			local v282 = p151[1];
			if not v282 then return end
			local v283 = p150.sprite or p150;
			local v284 = v283.part.CFrame * Vector3.new(0, v283.part.Size.Y * 0.15, v283.part.Size.Z * -0.5 + 1);
			local v285 = v282.sprite or v282;
			local v286 = v285.part.CFrame * Vector3.new(0, v285.part.Size.Y * 0.15, v285.part.Size.Z * -0.5 - 0);
			local cf45 = CFrame.new(v284, v286);
			local u140 = v286 - v284;
			for index24 = 1, 9 do
				local Clone_ret108 = Misc.SpikyBomb:Clone();
				Clone_ret108.Color = Color3.fromRGB(0, 0, 0);
				Clone_ret108.Size = Vector3.new(0.6, 1.5, 0.6);
				Clone_ret108.Material = "SmoothPlastic";
				Clone_ret108.CFrame = cf45 * CFrame.Angles(-math.pi / 2, 0, 0);
				local Attachment40 = Instance.new("Attachment", Clone_ret108);
				local Attachment41 = Instance.new("Attachment", Clone_ret108);
				Attachment40.Position = Vector3.new(0, 0, 0.1);
				Attachment41.Position = Vector3.new(0, 0, -0.1);
				local v773 = Utilities.Create("Trail")({
					Color = ColorSequence.new(Color3.fromRGB(0, 0, 0)),
					Lifetime = 0.25,
					Transparency = NumberSequence.new(0.5, 1),
					LightInfluence = 0,
					Parent = Clone_ret108
				});
				v773.Attachment0 = Attachment40;
				v773.Attachment1 = Attachment41;
				Clone_ret108.Parent = p152.scene;
				local cf46 = CFrame.new(Random_new_ret:NextInteger(-1, 1), Random_new_ret:NextInteger(-1, 1), 0);
				local u364 = 0;
				spawn(function()
					local _ = u13.Tween(TweenInfo.new(0.45, Enum.EasingStyle.Circular, Enum.EasingDirection.In), true, function(p717)
						Clone_ret108.CFrame = (cf45 * cf46 + (u140 + u140.unit) * p717) * CFrame.Angles(math.pi / 2, 0, 0);
						u364 = u364 + 1;
						if u364 % 5 == 0 then
							local Clone_ret109 = Misc.ThinRing:Clone();
							Clone_ret109.Color = Color3.fromRGB(0, 0, 0);
							Clone_ret109.Material = "SmoothPlastic";
							Clone_ret109.Size = Vector3.new(0.2, 0.1, 0.2);
							Clone_ret109.CFrame = Clone_ret108.CFrame;
							Clone_ret109.Parent = p152.scene;
							u13.Tween(TweenInfo.new(0.25), false, function(p748)
								Clone_ret109.Size = Vector3.new(p748 + 0.2, 0.1, p748 + 0.2);
								Clone_ret109.Transparency = p748;
							end).Completed:Connect(function()
								Clone_ret109:Destroy();
							end);
						end
					end);
					local CFrame36 = Clone_ret108.CFrame;
					Clone_ret108.Transparency = 1;
					u13.ballExplosion(TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), CFrame36, 6, Color3.fromRGB(0, 0, 0), Color3.fromRGB(44, 36, 33), "SmoothPlastic", "SmoothPlastic");
					Clone_ret108:Destroy();
				end);
				task.wait(0.05);
			end
			task.wait(0.5);
			return true;
		end,
		bubble = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			local from = targetPoint(pokemon)
			local to = (pokemon.sprite.part.CFrame-pokemon.sprite.part.Position) + targetPoint(target)
			local ease = Utilities.Timing.easeOutCubic(.8)
			for i = 1, 6 do
				local st = tick()
				local dif = (to*Vector3.new((math.random()-.5)*3, (math.random()-.5)*3, (math.random()-.5)*.1))-from
				local size = .7+.3*math.random()

				_p.Particles:new {
					Image = 242218744,
					Color = Color3.fromHSV(math.random(190, 220)/360, 1, 1),
					Lifetime = 1.2,
					OnUpdate = function(a, gui)
						gui.CFrame = CFrame.new(from + dif*(a>.8 and 1 or ease(a))) + Vector3.new(0, math.sin(tick()-st)*.2, 0)
						local s = (.7+.4*a)*size
						if a > .95 then
							s = s + (a-.95)*4
							gui.BillboardGui.ImageLabel.ImageTransparency = (a-.95)*20
						end
						gui.BillboardGui.Size = UDim2.new(s, 0, s, 0)
					end
				}
				task.wait(.1)
			end
			task.wait(.5)
			return true
		end,
		bubblebeam = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			local from = targetPoint(pokemon)
			local to = (pokemon.sprite.part.CFrame-pokemon.sprite.part.Position) + targetPoint(target)
			local ease = Utilities.Timing.easeOutCubic(.8)
			for i = 1, 20 do
				local st = tick()
				local dif = (to*Vector3.new((math.random()-.5)*1.6, (math.random()-.5)*1.6, (math.random()-.5)*.1))-from
				local size = .7+.3*math.random()
				_p.Particles:new {
					Image = 242218744,
					Color = Color3.fromHSV(math.random(190, 220)/360, 1, 1),
					Lifetime = 1.2,
					OnUpdate = function(a, gui)
						gui.CFrame = CFrame.new(from + dif*(a>.8 and 1 or ease(a))) + Vector3.new(0, math.sin(tick()-st)*.2, 0)
						local s = (.7+.4*a)*size
						if a > .95 then
							s = s + (a-.95)*4
							gui.BillboardGui.ImageLabel.ImageTransparency = (a-.95)*20
						end
						gui.BillboardGui.Size = UDim2.new(s, 0, s, 0)
					end
				}
				task.wait(.05)
			end
			task.wait(.5)
			return true
		end,
		cursedbeam = function (pokemon, targets, move)
			local target = targets[1];
			if not target then
				return
			end
			local from = targetPoint(pokemon)
			local to = targetPoint(target)
			local pos = CFrame.new(from, to)
			local dif = to - from
			local missile = storage.Models.Misc.Missile:Clone()
			missile.Color = Color3.fromRGB(58, 36, 70);
			missile.Material = "Neon";
			missile.Anchored = true;
			missile.CanCollide = false;
			missile.Trail.Lifetime = 1;
			missile.Trail.Color = ColorSequence.new(Color3.fromRGB(58, 36, 70))
			missile.Trail.LightEmission = 0.75
			local Particles = storage.Models.Misc.Particles
			local fire = Particles.Beam:Clone()
			fire.LockedToPart = false
			fire.Parent = missile
			missile.CFrame = pos * CFrame.Angles(math.pi / 2, 0, 0)
			missile.Parent = move.scene;
			Tween((dif.magnitude / 50), 'easeOutCubic', function(a)
				if not fire.Parent then return false end
				missile.CFrame = (pos + dif * a) * CFrame.Angles(math.pi / 2, 0, 0);
			end)
			fire.Enabled = false
			missile.Transparency = 1
			local attach = Instance.new("Attachment", workspace.Terrain)
			attach.WorldCFrame = CFrame.new(to)
			local spark = Particles.Sparks:Clone()
			spark.Enabled = false
			spark.Speed = NumberRange.new(10, 15)
			spark.Parent = attach
			local sparkv2 = spark:Clone()
			sparkv2.Texture = "rbxassetid://6209248212"
			sparkv2.Size = NumberSequence.new(2.5, 0.5)
			sparkv2.Speed = NumberRange.new(6, 10)
			sparkv2.Parent = attach
			sparkv2:Emit(10)
			spark:Emit(30)
			task.wait(spark.Lifetime.Max)
			attach:Destroy()
			missile:Destroy()
			return true
		end,
		earthquake = function(pokemon, battle) --- Still EQ lol
			local v64 = pokemon.side.battle.CoordinateFrame1;
			local v65 = pokemon.side.battle.CoordinateFrame2;
			if pokemon.side.n == 2 then
				v64 = v65;
				v65 = v64;
			end;
			local Rock_66 = storage.Models.Misc.Rock;
			u9("Earthquake", 2);
			local v67 = Random.new();
			local v68 = v64 + 0.5 * (v65.Position - v64.Position);
			local Magnitude_69 = (v64.Position - v65.Position).Magnitude;
			for v70 = 0, Magnitude_69 + 1, Magnitude_69 / 5 do
				local v71 = Instance.new("Folder", workspace);
				local v72 = {};
				for v73 = -2, 2 do
					local v74 = Rock_66:Clone();
					local v75 = v67:NextNumber(0, 2);
					local v76 = Vector3.new(8, 4 + v70 * 0.25, 8);
					local v77 = 0.5 * v76.Y;
					v74.Size = v76;
					local v78 = v64 * CFrame.new(v73 * v76.X * 0.5, -v77, -v70) * CFrame.Angles(0, math.rad(v67:NextInteger(-45, 45)), 0, 0);
					v74.CFrame = v78;
					v74.Parent = v71;
					table.insert(v72, { v74, v78, v77 });
				end;
				coroutine.wrap(function()
					Tween(0.5, "easeOutCubic", function(p32)
						for v79, v80 in ipairs(v72) do
							v80[1].CFrame = v80[2] + Vector3.new(0, v80[3] * p32, 0);
						end;
					end);
					Tween(0.5, "easeInCubic", function(p33)
						local v81 = 1 - p33;
						for v82, v83 in ipairs(v72) do
							v83[1].CFrame = v83[2] + Vector3.new(0, v83[3] * v81, 0);
						end;
					end);
					v71:Destroy();
				end)();
				task.wait(0.075);
			end;
			task.wait(0.25);
			return true;
		end;
		aurorabeam = function (pokemon, targets, move)
			local target = targets[1];
			if not target then
				return
			end
			local from = targetPoint(pokemon)
			local to = targetPoint(target)
			local pos = CFrame.new(from, to)
			local dif = to - from
			local missile = storage.Models.Misc.Missile:Clone()
			missile.Color = Color3.new(.4, 1, 1)
			missile.Material = "Neon";
			missile.Anchored = true;
			missile.CanCollide = false;
			missile.Trail.Lifetime = 1;
			missile.Trail.Color = ColorSequence.new(Color3.new(.4, 1, 1))
			missile.Trail.LightEmission = 0.75
			local Particles = storage.Models.Misc.Particles
			local fire = Particles.Beam:Clone()
			fire.LockedToPart = false
			fire.Parent = missile
			missile.CFrame = pos * CFrame.Angles(math.pi / 2, 0, 0)
			missile.Parent = move.scene;
			Tween((dif.magnitude / 50), 'easeOutCubic', function(a)
				if not fire.Parent then return false end
				missile.CFrame = (pos + dif * a) * CFrame.Angles(math.pi / 2, 0, 0);
			end)
			fire.Enabled = false
			missile.Transparency = 1
			local attach = Instance.new("Attachment", workspace.Terrain)
			attach.WorldCFrame = CFrame.new(to)
			local spark = Particles.Sparks:Clone()
			spark.Enabled = false
			spark.Speed = NumberRange.new(10, 15)
			spark.Parent = attach
			local sparkv2 = spark:Clone()
			sparkv2.Texture = "rbxassetid://6209248212"
			sparkv2.Size = NumberSequence.new(2.5, 0.5)
			sparkv2.Speed = NumberRange.new(6, 10)
			sparkv2.Parent = attach
			sparkv2:Emit(10)
			spark:Emit(30)
			task.wait(spark.Lifetime.Max)
			attach:Destroy()
			missile:Destroy()
			return true
		end,				

		chargebeam = function (pokemon, targets, move)
			local target = targets[1];
			if not target then
				return
			end
			local from = targetPoint(pokemon)
			local to = targetPoint(target)
			local pos = CFrame.new(from, to)
			local dif = to - from
			local missile = storage.Models.Misc.Missile:Clone()
			missile.Color = Color3.new(1, 1, .4)
			missile.Material = "Neon";
			missile.Anchored = true;
			missile.CanCollide = false;
			missile.Trail.Lifetime = 1;
			missile.Trail.Color = ColorSequence.new(Color3.new(1, 1, .4))
			missile.Trail.LightEmission = 0.75
			local Particles = storage.Models.Misc.Particles
			local fire = Particles.Beam:Clone()
			fire.LockedToPart = false
			fire.Parent = missile
			missile.CFrame = pos * CFrame.Angles(math.pi / 2, 0, 0)
			missile.Parent = move.scene;
			Tween((dif.magnitude / 50), 'easeOutCubic', function(a)
				if not fire.Parent then return false end
				missile.CFrame = (pos + dif * a) * CFrame.Angles(math.pi / 2, 0, 0);
			end)
			fire.Enabled = false
			missile.Transparency = 1
			local attach = Instance.new("Attachment", workspace.Terrain)
			attach.WorldCFrame = CFrame.new(to)
			local spark = Particles.Sparks:Clone()
			spark.Enabled = false
			spark.Speed = NumberRange.new(10, 15)
			spark.Parent = attach
			local sparkv2 = spark:Clone()
			sparkv2.Texture = "rbxassetid://6209248212"
			sparkv2.Size = NumberSequence.new(2.5, 0.5)
			sparkv2.Speed = NumberRange.new(6, 10)
			sparkv2.Parent = attach
			sparkv2:Emit(10)
			spark:Emit(30)
			task.wait(spark.Lifetime.Max)
			attach:Destroy()
			missile:Destroy()
			return true
		end,										

		signalbeam = function (pokemon, targets, move)
			local target = targets[1];
			if not target then
				return
			end
			local from = targetPoint(pokemon)
			local to = targetPoint(target)
			local pos = CFrame.new(from, to)
			local dif = to - from
			local missile = storage.Models.Misc.Missile:Clone()
			missile.Color = Color3.new(.54, .69, .2)
			missile.Material = "Neon";
			missile.Anchored = true;
			missile.CanCollide = false;
			missile.Trail.Lifetime = 1;
			missile.Trail.Color = ColorSequence.new(Color3.new(.54, .69, .2))
			missile.Trail.LightEmission = 0.75
			local Particles = storage.Models.Misc.Particles
			local fire = Particles.Beam:Clone()
			fire.LockedToPart = false
			fire.Parent = missile
			missile.CFrame = pos * CFrame.Angles(math.pi / 2, 0, 0)
			missile.Parent = move.scene;
			Tween((dif.magnitude / 50), 'easeOutCubic', function(a)
				if not fire.Parent then return false end
				missile.CFrame = (pos + dif * a) * CFrame.Angles(math.pi / 2, 0, 0);
			end)
			fire.Enabled = false
			missile.Transparency = 1
			local attach = Instance.new("Attachment", workspace.Terrain)
			attach.WorldCFrame = CFrame.new(to)
			local spark = Particles.Sparks:Clone()
			spark.Enabled = false
			spark.Speed = NumberRange.new(10, 15)
			spark.Parent = attach
			local sparkv2 = spark:Clone()
			sparkv2.Texture = "rbxassetid://6209248212"
			sparkv2.Size = NumberSequence.new(2.5, 0.5)
			sparkv2.Speed = NumberRange.new(6, 10)
			sparkv2.Parent = attach
			sparkv2:Emit(10)
			spark:Emit(30)
			task.wait(spark.Lifetime.Max)
			attach:Destroy()
			missile:Destroy()
			return true
		end,			
		twinbeam = function(pokemon, targets, move)
			local target = targets[1]
			if not target then return end

			local from = targetPoint(pokemon)
			local to = targetPoint(target)
			local pos = CFrame.new(from, to)
			local dif = to - from

			for i = -1, 1, 2 do
				spawn(function()
					local missile = storage.Models.Misc.Missile:Clone()
					missile.Color = Color3.new(1, 0.6, 0.8) -- Pink color
					missile.Material = "Neon"
					missile.Anchored = true
					missile.CanCollide = false
					missile.Trail.Lifetime = 1
					missile.Trail.Color = ColorSequence.new(Color3.new(1, 0.6, 0.8)) -- Pink color
					missile.Trail.LightEmission = 0.75

					local Particles = storage.Models.Misc.Particles
					local fire = Particles.Beam:Clone()
					fire.LockedToPart = false
					fire.Parent = missile

					local offset = CFrame.new(i * 2, 0, 0) -- Calculate the x-axis offset

					missile.CFrame = pos * offset * CFrame.Angles(math.pi / 2, 0, 0)
					missile.Parent = move.scene

					Tween((dif.magnitude / 50), 'easeOutCubic', function(a)
						if not fire.Parent then return false end
						missile.CFrame = (pos + dif * a) * offset * CFrame.Angles(math.pi / 2, 0, 0)
					end)

					fire.Enabled = false
					missile.Transparency = 1

					local attach = Instance.new("Attachment", workspace.Terrain)
					attach.WorldCFrame = CFrame.new(to)

					local spark = Particles.Sparks:Clone()
					spark.Enabled = false
					spark.Speed = NumberRange.new(10, 15)
					spark.Parent = attach

					local sparkv2 = spark:Clone()
					sparkv2.Texture = "rbxassetid://6209248212"
					sparkv2.Size = NumberSequence.new(2.5, 0.5)
					sparkv2.Speed = NumberRange.new(6, 10)
					sparkv2.Parent = attach

					sparkv2:Emit(10)
					spark:Emit(30)

					task.wait(spark.Lifetime.Max)

					attach:Destroy()
					missile:Destroy()
				end)
			end

			task.wait(0.6)
			return true
		end,	

		poisonfang = function(p364, p365, p366) -- venomchomp
			local v704 = p365[1];
			if not v704 then return end
			local v705 = p364.sprite or p364;
			local v706 = v705.part.CFrame * Vector3.new(0, v705.part.Size.Y * 0.15, v705.part.Size.Z * -0.5 - 0);
			local v707 = v704.sprite or v704;
			local v708 = v707.part.CFrame * Vector3.new(0, v707.part.Size.Y * 0.15, v707.part.Size.Z * -0.5 - 0);
			local cf111 = CFrame.new(v706, v708);
			local Clone_ret327 = storage.Models.Misc.Bite:Clone();
			local Top8 = Clone_ret327.Top;
			local Bottom8 = Clone_ret327.Bottom;
			local Color3_fromRGB_ret23 = Color3.fromRGB(87, 30, 122);
			local Color3_fromRGB_ret24 = Color3.fromRGB(87, 30, 122);
			Top8.Color = Color3_fromRGB_ret23;
			Bottom8.Color = Color3_fromRGB_ret23;
			Top8.Transparency = 1;
			Bottom8.Transparency = 1;
			Top8.Material = "Neon";
			Bottom8.Material = "Neon";
			Clone_ret327.PrimaryPart = Clone_ret327.Main;
			Clone_ret327:PivotTo(cf111);
			local u335 = v708 - v706;
			Utilities.ScaleModel(Clone_ret327.Main, 3);
			Clone_ret327.Parent = p366.scene;
			local inverse_ret8 = Clone_ret327.Main.CFrame:inverse();
			local u336 = inverse_ret8 * Top8.CFrame;
			local u337 = inverse_ret8 * Bottom8.CFrame;
			local _ = Top8.Size.X;
			Clone_ret327:PivotTo(cf111);
			local CFrame77 = Clone_ret327.PrimaryPart.CFrame;
			u13.Tween(TweenInfo.new(0.35), true, function(p583)
				local v891 = 1 - p583;
				local cf112 = CFrame.new(0, 0, v891 * -1);
				local v892 = 0.4 - v891 * 0.4;
				Top8.CFrame = Clone_ret327.PrimaryPart.CFrame * cf112 * CFrame.Angles(v892, 0, 0) * u336;
				Bottom8.CFrame = Clone_ret327.PrimaryPart.CFrame * cf112 * CFrame.Angles(-v892, 0, 0) * u337;
				Top8.Transparency = 1 - p583;
				Bottom8.Transparency = 1 - p583;
			end);
			local table95 = {
				Color = ColorSequence.new(Color3.fromRGB(118, 41, 165)),
				Transparency = NumberSequence.new(0, 1),
				WidthScale = NumberSequence.new(0, 1),
				LightEmission = 1,
				Lifetime = 0.3
			};
			for index75 = 1, 9 do
				local u402 = cf111 * CFrame.new(math.cos(math.pi * 2 * index75 / 5) * 4, math.sin(math.pi * 2 * index75 / 5) * 4, 0);
				spawn(function()
					u13.makeSpiral(1, u402 * CFrame.Angles(-math.pi / 2, 0, 0), 0, u335.magnitude + 3, 0, 0.5, TweenInfo.new(0.25, Enum.EasingStyle.Linear), nil, table95);
				end);
			end
			spawn(function()
				for index107 = 1, 5 do
					local Clone_ret328 = Misc.ThinRing:Clone();
					Clone_ret328.Color = Color3_fromRGB_ret24:Lerp(Color3_fromRGB_ret23, index107 / 5);
					Clone_ret328.Material = "Neon";
					Clone_ret328.Size = Vector3.new(1, 0.1, 1);
					Clone_ret328.CFrame = cf111 * CFrame.new(0, 0, -u335.magnitude * index107 / 5) * CFrame.Angles(math.pi / 2, 0, 0);
					Clone_ret328.Parent = p366.scene;
					u13.Tween(TweenInfo.new(0.25), false, function(p704)
						Clone_ret328.Size = Vector3.new(p704 * 15 + 1, 0.1, p704 * 15 + 1);
						Clone_ret328.Transparency = p704;
					end);
					game.Debris:AddItem(Clone_ret328, 0.25);
					task.wait(0.05);
				end
			end);
			u13.Tween(TweenInfo.new(0.25), true, function(p584)
				local v893 = 1 - p584;
				local cf113 = CFrame.new(0, 0, v893 * -1);
				local v894 = v893 * 0.9;
				Clone_ret327:PivotTo(CFrame77 + (u335 - u335.unit * Top8.Size.X) * p584);
				Top8.CFrame = Clone_ret327.PrimaryPart.CFrame * cf113 * CFrame.Angles(v894, 0, 0) * u336;
				Bottom8.CFrame = Clone_ret327.PrimaryPart.CFrame * cf113 * CFrame.Angles(-v894, 0, 0) * u337;
			end);
			Top8.Transparency = 1;
			Bottom8.Transparency = 1;
			local Attachment115 = Instance.new("Attachment", workspace.Terrain);
			Attachment115.WorldCFrame = CFrame.new(v708);
			for index76 = 1, 12 do
				u13.trailSwirl(CFrame.new(v708) * CFrame.Angles(0, 0, math.pi * 2 * index76 / 12), 0.6, index76 * 9 / 12 + 4, 1, math.pi * 3, table95, false, true);
			end
			delay(3, function()
				Clone_ret327:Destroy();
			end);
			return true;
		end,

		closecombat = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			local sprite = pokemon.sprite
			local ep = (target.sprite.cf.p - sprite.cf.p)*Vector3.new(1,0,1)
			ep = ep.unit*(ep.magnitude-3)
			Tween(.4, nil, function(a)
				sprite.offset = ep*a + Vector3.new(0, math.sin(a*math.pi)*1.5, 0)
			end)
			local ts = target.sprite
			local cf = ts.part.CFrame
			local cfo = cf-cf.p
			local size = ts.part.Size
			local offset = ts.offset
			local back = ep.unit*2
			--		cf = cf-cf.p
			for i = 1, 5 do
				local x = math.random()-.5
				local y = math.random()*.5
				_p.Particles:new {
					Acceleration = false,
					Image = 644258078, -- 188x152
					Lifetime = .2,
					Color = Color3.fromRGB(194, 88, 61),
					Size = Vector2.new(1, .8),
					Position = cf * Vector3.new(x*size.X, y*size.Y, -.5),
					OnUpdate = function(a, gui)
						local img = gui.BillboardGui.ImageLabel
						if a < .25 and x < 0 then
							img.ImageRectSize = Vector2.new(-188, 152)
							img.ImageRectOffset = Vector2.new(188, 0)
						elseif a > .5 then
							img.ImageTransparency = (a-.5)*2
						end
					end
				}
				spawn(function()
					Tween(.23, nil, function(a)
						local s = math.sin(a*math.pi)
						ts.offset = offset + (cfo*Vector3.new(-x*size.X*.5*s,0,0)) + back*s
					end)
				end)
				if i < 5 then
					Tween(.23, nil, function(a)
						local s = math.sin(a*math.pi)
						sprite.offset = ep-back*s*.5
					end)
				end
			end
			spawn(function()
				Tween(.4, nil, function(a)
					sprite.offset = ep*(1-a) + Vector3.new(0, math.sin(a*math.pi)*1.5, 0)
				end)
			end)
			return true
		end,
		plasmafists = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			local sprite = pokemon.sprite
			local ep = (target.sprite.cf.p - sprite.cf.p)*Vector3.new(1,0,1)
			ep = ep.unit*(ep.magnitude-3)
			Tween(.4, nil, function(a)
				sprite.offset = ep*a + Vector3.new(0, math.sin(a*math.pi)*1.5, 0)
			end)
			local ts = target.sprite
			local cf = ts.part.CFrame
			local cfo = cf-cf.p
			local size = ts.part.Size
			local offset = ts.offset
			local back = ep.unit*2
			--		cf = cf-cf.p
			for i = 1, 5 do
				local x = math.random()-.5
				local y = math.random()*.5
				_p.Particles:new {
					Acceleration = false,
					Image = 644258078, -- 188x152
					Lifetime = .2,
					Color = Color3.fromRGB(234, 255, 21),
					Size = Vector2.new(1, .8),
					Position = cf * Vector3.new(x*size.X, y*size.Y, -.5),
					OnUpdate = function(a, gui)
						local img = gui.BillboardGui.ImageLabel
						if a < .25 and x < 0 then
							img.ImageRectSize = Vector2.new(-188, 152)
							img.ImageRectOffset = Vector2.new(188, 0)
						elseif a > .5 then
							img.ImageTransparency = (a-.5)*2
						end
					end
				}
				spawn(function()
					Tween(.23, nil, function(a)
						local s = math.sin(a*math.pi)
						ts.offset = offset + (cfo*Vector3.new(-x*size.X*.5*s,0,0)) + back*s
					end)
				end)
				if i < 5 then
					Tween(.23, nil, function(a)
						local s = math.sin(a*math.pi)
						sprite.offset = ep-back*s*.5
					end)
				end
			end
			spawn(function()
				Tween(.4, nil, function(a)
					sprite.offset = ep*(1-a) + Vector3.new(0, math.sin(a*math.pi)*1.5, 0)
				end)
			end)
			return true
		end,
		crosschop = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Brown', 2)
			return 'sound'
		end,
		ceaselessedge = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Black', 2)
			spikes(pokemon) 
			return 'sound' 
		end,
		stoneaxe = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Brown', 1) 
			stealthrock(pokemon)
			return 'sound' 
		end,
		crosspoison = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Magenta', 2)
			return 'sound'
		end,
		bite = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			Utilities.fastSpawn(function() bite(target, nil, nil, true) end)
			task.wait(.35)
			return 'sound'
		end,
		cut = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			cut(target)
			return 'sound'
		end,
		dig = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			local sprite = pokemon.sprite
			local sp = sprite.offset
			local ep = (target.sprite.cf.p - sprite.cf.p)*Vector3.new(.9,0,.9)
			Tween(.3, nil, function(a)
				sprite.offset = sp + (ep-sp)*a
			end)
			spawn(function()
				task.wait(.1)
				Tween(1, 'easeOutCubic', function(a)
					sprite.offset = ep*(1-a)
				end)
			end)
			return true -- perform usual hit anim
		end,
		dive = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			local sprite = pokemon.sprite
			local sp = sprite.offset
			local ep = (target.sprite.cf.p - sprite.cf.p)*Vector3.new(.9,0,.9)
			Tween(.3, nil, function(a)
				sprite.offset = sp + (ep-sp)*a
			end)
			spawn(function()
				task.wait(.1)
				Tween(1, 'easeOutCubic', function(a)
					sprite.offset = ep*(1-a)
				end)
			end)
			return true -- perform usual hit anim
		end,
		doubleteam = function(pokemon)
			local sprite = pokemon.sprite
			-- v = v0 + a*t
			-- p = p0 + v0*t + a*t*t/2
			Tween(2, nil, function(a)
				sprite.offset = Vector3.new(math.sin(15*a + 34*a*a), 0, 0)
			end)
			local left, right = Vector3.new(-1, 0, 0), Vector3.new(1, 0, 0)
			Tween(1, 'easeInCubic', function(a, t)
				if t%.07 < .035 then
					sprite.offset = right * (1-a)
				else
					sprite.offset = left * (1-a)
				end
			end)
			sprite.offset = nil
		end,
		drainingkiss = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			_p.Particles:new {
				Acceleration = false,
				Image = 644314963,-- 271x186
				Lifetime = .4,
				--			Size = Vector2.new(2, 1.34),
				Position = target.sprite.part.CFrame * Vector3.new(0, 0, -.5),
				OnUpdate = function(a, gui)
					local s = math.sin(.5+1.6*a)
					gui.BillboardGui.Size = UDim2.new(2*s, 0, 1.34*s, 0)
					if a > .5 then
						gui.BillboardGui.ImageLabel.ImageTransparency = (a-.5)*2
					end
				end
			}
			task.wait(.25)
			absorb(pokemon, target, 12, Color3.new(.92, .7, .92))
			return true
		end,
		dualchop = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Royal purple', 2)
			return 'sound'
		end,
		ember = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			local from = targetPoint(pokemon)
			local to = targetPoint(target)
			local dif = to-from
			for i = 1, 3 do
				_p.Particles:new {
					Image = 11601142,
					Lifetime = .7,
					OnUpdate = function(a, gui)
						gui.CFrame = CFrame.new(from + dif*a)
						local s = 1+1.5*a
						gui.BillboardGui.Size = UDim2.new(s, 0, s, 0)
					end
				}
				task.wait(.05)
			end
			task.wait(.6)
			return true
		end,
		energyball = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			local sprite = pokemon.sprite
			local centroid = targetPoint(pokemon, 2.5)
			local cf = CFrame.new(centroid, centroid + workspace.CurrentCamera.CFrame.lookVector)
			local function makeParticle(hue)
				local p = create 'Part' {
					Transparency = 1.0,
					Anchored = true,
					CanCollide = false,
					Size = Vector3.new(.2, .2, .2),
					Parent = workspace,
				}
				local bbg = create 'BillboardGui' {
					Adornee = p,
					Size = UDim2.new(.7, 0, .7, 0),
					Parent = p,
					create 'ImageLabel' {
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://6294357140',
						ImageTransparency = .15,
						ImageColor3 = Color3.fromHSV(hue/360, 1, .85),
						Size = UDim2.new(1.0, 0, 1.0, 0),
						ZIndex = 2
					}
				}
				return p, bbg
			end
			local main, mbg = makeParticle(100)
			main.CFrame = cf
			local allParticles = {main}
			delay(.3, function()
				local rand = math.random
				for i = 2, 11 do
					local theta = rand()*6.28
					local offset = Vector3.new(math.cos(theta), math.sin(theta), .5)
					local p, b = makeParticle(rand(66, 156))
					allParticles[i] = p
					local r = math.random()*.35+.2
					spawn(function()
						local st = tick()
						local function o(r)
							local et = (tick()-st)*7
							p.CFrame = cf * CFrame.new(offset*r+.125*Vector3.new(math.cos(et), math.sin(et)*math.cos(et), 0))
						end
						Tween(.2, 'easeOutCubic', function(a)
							if not p.Parent then return false end
							b.Size = UDim2.new(.5*a, 0, .5*a, 0)
							o(r+.6)
						end)
						Tween(.25, 'easeOutCubic', function(a)
							if not p.Parent then return false end
							o(r+.6*(1-a))
						end)
						while p.Parent do
							o(r)
							stepped:wait()
						end
					end)
					task.wait(.1)
				end
			end)
			Tween(1.5, nil, function(a)
				mbg.Size = UDim2.new(2.5*a, 0, 2.5*a, 0)
			end)
			task.wait(.3)
			local targPos = targetPoint(target)
			local dp = targPos - centroid
			local v = 30
			local scf = cf
			Tween(dp.magnitude/v, nil, function(a)
				cf = scf + dp*a
				main.CFrame = cf
			end)
			for _, p in pairs(allParticles) do
				p:Destroy()
			end
			return true -- perform usual hit anim
		end,



		pyroball = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			local sprite = pokemon.sprite
			local centroid = targetPoint(pokemon, 2.5)
			local cf = CFrame.new(centroid, centroid + workspace.CurrentCamera.CFrame.lookVector)
			local function makeParticle(hue)
				local p = create 'Part' {
					Transparency = 1.0,
					Anchored = true,
					CanCollide = false,
					Size = Vector3.new(.2, .2, .2),
					Parent = workspace,
				}
				local bbg = create 'BillboardGui' {
					Adornee = p,
					Size = UDim2.new(.7, 0, .7, 0),
					Parent = p,
					create 'ImageLabel' {
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://6294357140',
						ImageTransparency = .15,
						ImageColor3 = Color3.fromRGB(242,125,12),
						Size = UDim2.new(1.0, 0, 1.0, 0),
						ZIndex = 2
					}
				}
				return p, bbg
			end
			local main, mbg = makeParticle(100)
			main.CFrame = cf
			local allParticles = {main}
			delay(.3, function()
				local rand = math.random
				for i = 2, 11 do
					local theta = rand()*6.28
					local offset = Vector3.new(math.cos(theta), math.sin(theta), .5)
					local p, b = makeParticle(rand(66, 156))
					allParticles[i] = p
					local r = math.random()*.35+.2
					spawn(function()
						local st = tick()
						local function o(r)
							local et = (tick()-st)*7
							p.CFrame = cf * CFrame.new(offset*r+.125*Vector3.new(math.cos(et), math.sin(et)*math.cos(et), 0))
						end
						Tween(.2, 'easeOutCubic', function(a)
							if not p.Parent then return false end
							b.Size = UDim2.new(.5*a, 0, .5*a, 0)
							o(r+.6)
						end)
						Tween(.25, 'easeOutCubic', function(a)
							if not p.Parent then return false end
							o(r+.6*(1-a))
						end)
						while p.Parent do
							o(r)
							stepped:wait()
						end
					end)
					task.wait(.1)
				end
			end)
			Tween(1.5, nil, function(a)
				mbg.Size = UDim2.new(2.5*a, 0, 2.5*a, 0)
			end)
			task.wait(.3)
			local targPos = targetPoint(target)
			local dp = targPos - centroid
			local v = 30
			local scf = cf
			Tween(dp.magnitude/v, nil, function(a)
				cf = scf + dp*a
				main.CFrame = cf
			end)
			for _, p in pairs(allParticles) do
				p:Destroy()
			end
			return true -- perform usual hit anim
		end,


		explosion = function(pokemon, targets)
			pcall(function() pokemon.statbar:setHP(0, pokemon.maxhp) end)
			local e = create 'Explosion' {
				BlastPressure = 0,
				Position = pokemon.sprite.cf.p,
				Parent = workspace
			}
			delay(3, function() pcall(function() e:Destroy() end) end)
			task.wait(.5)
			return true -- perform usual hit anim
		end,
		--[[similar to explosion]]selfdestruct = function(pokemon, targets)
			pcall(function() pokemon.statbar:setHP(0, pokemon.maxhp) end)
			local e = create 'Explosion' {
				BlastPressure = 0,
				Position = pokemon.sprite.cf.p,
				Parent = workspace
			}
			delay(3, function() pcall(function() e:Destroy() end) end)
			task.wait(.5)
			return true -- perform usual hit anim
		end,
		electroweb = function (pokemon, targets, move)
			local target = targets[1];
			if not target then
				return
			end
			local from = targetPoint(pokemon)
			local to = targetPoint(target)
			local dif = to-from
			local pos = CFrame.new(from, to)
			local bolt = storage.Models.Misc.Bolt:Clone()
			bolt.Anchored = true
			bolt.CanCollide = false
			bolt.Trail.Lifetime = 1
			bolt.Trail.Color = ColorSequence.new(Color3.fromRGB(255, 250, 40))
			bolt.Trail.LightEmission = 0.75
			local Particles = storage.Models.Misc.Particles
			local beam = Particles.ThunderBeam:Clone()
			beam.LockedToPart = false
			beam.Parent = bolt
			bolt.CFrame = pos * CFrame.Angles(math.pi / 2, 0, 0)
			bolt.Parent = move.scene;
			Tween((dif.magnitude / 50), 'easeOutCubic', function(a)
				if not beam.Parent then return false end
				bolt.CFrame = (pos + dif * a) * CFrame.Angles(math.pi / 2, 0, 0);
			end)
			beam.Enabled = false
			bolt.Transparency = 1
			bolt:Destroy()
			local web = storage.Models.Misc.webshot:Clone()
			web.Color = Color3.fromRGB(255, 242, 49)
			web.Anchored = true
			web.CanCollide = false
			web.Size = Vector3.new(3, 0.25, 3)
			web.Parent = workspace
			Utilities.fastSpawn(function()
				web.CFrame = CFrame.new(to) * CFrame.Angles(0, math.rad(90), math.rad(-90))
			end)
			task.wait(1)
			web:Destroy()
			return true
		end,

		gust = function (pokemon, targets, move) --- also gust
			local target = targets[1];
			if not target then
				return
			end
			local from = targetPoint(pokemon)
			local to = targetPoint(target)
			local crescent = storage.Models.Misc.Crescent:Clone()
			crescent.Color = Color3.fromRGB(255, 255, 255)
			crescent.Transparency = 0.2
			crescent.Size = Vector3.new(9, 0.2, 4)
			crescent.Anchored = true
			local Particles = storage.Models.Misc.Particles
			local gust = Particles.Gust:Clone()
			gust.Enabled = true
			gust.Parent = crescent
			crescent.Parent = move.scene
			local pos = CFrame.new(from, to)
			local dif = to - from
			Utilities.fastSpawn(function()
				Tween(0.35, "easeOutQuad", function(a)
					crescent.CFrame = pos * CFrame.new(0, 0, -(dif.magnitude + 2) * a)
					crescent.Transparency = 0.2 + 0.8 * a
				end)
			end)
			gust.Enabled = false
			game.Debris:AddItem(crescent, gust.Lifetime.Max);
			return true
		end,
		falseswipe = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target)
			return 'sound'
		end,
		firefang = function(p159, p160, p161) -- blazechomp
			local v297 = p160[1];
			if not v297 then return end
			local v298 = p159.sprite or p159;
			local v299 = v298.part.CFrame * Vector3.new(0, v298.part.Size.Y * 0.15, v298.part.Size.Z * -0.5 - 0);
			local v300 = v297.sprite or v297;
			local v301 = v300.part.CFrame * Vector3.new(0, v300.part.Size.Y * 0.15, v300.part.Size.Z * -0.5 - 0);
			local cf48 = CFrame.new(v299, v301);
			local Clone_ret115 = storage.Models.Misc.Bite:Clone();
			local Top4 = Clone_ret115.Top;
			local Bottom4 = Clone_ret115.Bottom;
			local Clone_ret116 = Particles.FireBreath:Clone();
			Clone_ret116.Speed = NumberRange.new(-4, 4);
			Clone_ret116.Size = NumberSequence.new(1, 3.5);
			Clone_ret116.Lifetime = NumberRange.new(0.6, 0.9);
			Clone_ret116.RotSpeed = NumberRange.new(-90, 90);
			Clone_ret116.Rate = 50;
			Clone_ret116.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.2, 0),
				NumberSequenceKeypoint.new(0.8, 0),
				NumberSequenceKeypoint.new(1, 1)
			});
			Clone_ret116.LockedToPart = false;
			Clone_ret116.Enabled = true;
			local Clone_ret117 = Clone_ret116:Clone();
			Clone_ret116.Parent = Top4;
			Clone_ret117.Parent = Bottom4;
			local Color3_fromRGB_ret2 = Color3.fromRGB(255, 42, 23);
			local Color3_fromRGB_ret3 = Color3.fromRGB(255, 140, 8);
			Top4.Color = Color3_fromRGB_ret2;
			Bottom4.Color = Color3_fromRGB_ret2;
			Top4.Transparency = 1;
			Bottom4.Transparency = 1;
			Top4.Material = "Neon";
			Bottom4.Material = "Neon";
			Clone_ret115.PrimaryPart = Clone_ret115.Main;
			Clone_ret115:PivotTo(cf48);
			local u143 = v301 - v299;
			Utilities.ScaleModel(Clone_ret115.Main, 3);
			Clone_ret115.Parent = p161.scene;
			local inverse_ret4 = Clone_ret115.Main.CFrame:inverse();
			local u144 = inverse_ret4 * Top4.CFrame;
			local u145 = inverse_ret4 * Bottom4.CFrame;
			local _ = Top4.Size.X;
			Clone_ret115:PivotTo(cf48);
			local CFrame37 = Clone_ret115.PrimaryPart.CFrame;
			u13.Tween(TweenInfo.new(0.55), true, function(p476)
				local v852 = 1 - p476;
				local cf49 = CFrame.new(0, 0, v852 * -1);
				local v853 = 0.4 - v852 * 0.4;
				Top4.CFrame = Clone_ret115.PrimaryPart.CFrame * cf49 * CFrame.Angles(v853, 0, 0) * u144;
				Bottom4.CFrame = Clone_ret115.PrimaryPart.CFrame * cf49 * CFrame.Angles(-v853, 0, 0) * u145;
				Top4.Transparency = 1 - p476;
				Bottom4.Transparency = 1 - p476;
			end);
			local table40 = {
				Color = ColorSequence.new(Color3.fromRGB(218, 133, 65), Color3.fromRGB(255, 0, 0)),
				Transparency = NumberSequence.new(0, 1),
				WidthScale = NumberSequence.new(0, 1),
				LightEmission = 1,
				Lifetime = 0.3
			};
			for index25 = 1, 9 do
				local u365 = cf48 * CFrame.new(math.cos(math.pi * 2 * index25 / 5) * 4, math.sin(math.pi * 2 * index25 / 5) * 4, 0);
				spawn(function()
					u13.makeSpiral(1, u365 * CFrame.Angles(-math.pi / 2, 0, 0), 0, u143.magnitude + 3, 0, 0.5, TweenInfo.new(0.25, Enum.EasingStyle.Linear), nil, table40);
				end);
			end
			spawn(function()
				for index97 = 1, 5 do
					local Clone_ret118 = Misc.ThinRing:Clone();
					Clone_ret118.Color = Color3_fromRGB_ret3:Lerp(Color3_fromRGB_ret2, index97 / 5);
					Clone_ret118.Material = "Neon";
					Clone_ret118.Size = Vector3.new(1, 0.1, 1);
					Clone_ret118.CFrame = cf48 * CFrame.new(0, 0, -u143.magnitude * index97 / 5) * CFrame.Angles(math.pi / 2, 0, 0);
					Clone_ret118.Parent = p161.scene;
					u13.Tween(TweenInfo.new(0.25), false, function(p696)
						Clone_ret118.Size = Vector3.new(p696 * 15 + 1, 0.1, p696 * 15 + 1);
						Clone_ret118.Transparency = p696;
					end);
					game.Debris:AddItem(Clone_ret118, 0.25);
					task.wait(0.05);
				end
			end);
			u13.Tween(TweenInfo.new(0.25), true, function(p477)
				local v854 = 1 - p477;
				local cf50 = CFrame.new(0, 0, v854 * -1);
				local v855 = v854 * 0.9;
				Clone_ret115:PivotTo(CFrame37 + (u143 - u143.unit * Top4.Size.X) * p477);
				Top4.CFrame = Clone_ret115.PrimaryPart.CFrame * cf50 * CFrame.Angles(v855, 0, 0) * u144;
				Bottom4.CFrame = Clone_ret115.PrimaryPart.CFrame * cf50 * CFrame.Angles(-v855, 0, 0) * u145;
			end);
			Top4.Transparency = 1;
			Bottom4.Transparency = 1;
			Clone_ret116.Enabled = false;
			Clone_ret117.Enabled = false;
			local Attachment43 = Instance.new("Attachment", workspace.Terrain);
			Attachment43.WorldCFrame = CFrame.new(v301);
			local Clone_ret119 = Clone_ret116:Clone();
			Clone_ret119.SpreadAngle = Vector2.new(360, 360);
			Clone_ret119.Size = NumberSequence.new(4, 0.1);
			Clone_ret119.Transparency = NumberSequence.new(0, 1);
			Clone_ret119.Speed = NumberRange.new(15, 20);
			Clone_ret119.Acceleration = Vector3.new(0, 0, 0);
			Clone_ret119.Parent = Attachment43;
			Clone_ret119:Emit(30);
			for index26 = 1, 12 do
				u13.trailSwirl(CFrame.new(v301) * CFrame.Angles(0, 0, math.pi * 2 * index26 / 12), 0.6, index26 * 9 / 12 + 4, 1, math.pi * 3, table40, true, true);
			end
			game.Debris:AddItem(Attachment43, Clone_ret119.Lifetime.Max);
			delay(Clone_ret116.Lifetime.Max, function()
				Clone_ret115:Destroy();
			end);
			return true;
		end,

		flamethrower = function(p176, p177, _) -- firebreath
			local v327 = p177[1];
			if not v327 then return end
			local v328 = p176.sprite or p176;
			local v329 = v328.part.CFrame * Vector3.new(-3, v328.part.Size.Y * 0.15, v328.part.Size.Z * -0.5 - 0);
			local v330 = v327.sprite or v327;
			local v331 = v330.part.CFrame * Vector3.new(0, v330.part.Size.Y * 0.15, v330.part.Size.Z * -0.5 - 0);

			local Ambient_37 = Lighting.Ambient
			local OutdoorAmbient_38 = Lighting.OutdoorAmbient
			local ColorShift_Bottom_39 = Lighting.ColorShift_Bottom
			local ColorShift_Top_40 = Lighting.ColorShift_Top
			lightShift(Color3.fromRGB(192, 0, 0), Color3.fromRGB(128, 0, 0), Color3.fromRGB(255, 50, 50), Color3.fromRGB(255, 50, 50), 0.9)
			local Attachment51 = Instance.new("Attachment", workspace.Terrain);
			Attachment51.WorldCFrame = CFrame.new(v329, v331);
			local Clone_ret134 = Particles.FireBreath:Clone();
			local Clone_ret135 = Particles.FireBreath2:Clone();
			local v332 = v331 - v329;
			Clone_ret134.Parent = Attachment51;
			Clone_ret135.Parent = Attachment51;
			local v333 = v332.magnitude / (Clone_ret134.Speed.Min + (Clone_ret134.Speed.Max - Clone_ret134.Speed.Min) / 2);
			Clone_ret134.Lifetime = NumberRange.new(v333 - 0.1, v333 + 0.1);
			Clone_ret134.Enabled = true;
			Clone_ret135.Enabled = true;
			task.wait(2.5);
			Clone_ret134.Enabled = false;
			Clone_ret135.Enabled = false;
			game.Debris:AddItem(Attachment51, v333);
			lightRestore(0.5)
			return true;
		end,

		fly = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			local sprite = pokemon.sprite
			local sp = sprite.offset
			local ep = (target.sprite.cf.p - sprite.cf.p)*Vector3.new(.9,0,.9)+Vector3.new(0,(sprite.spriteData.inAir or 0)*-.75,0)
			--		local sp = ep+Vector3.new(0, 10, 0)--sprite.offset
			Tween(.3, nil, function(a)
				sprite.offset = sp + (ep-sp)*a
			end)
			spawn(function()
				task.wait(.1)
				Tween(1, 'easeOutCubic', function(a)
					sprite.offset = ep*(1-a)
				end)
			end)
			return true -- perform usual hit anim
		end,
		furycutter = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Medium green')
			return 'sound'
		end,
		furyswipes = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, nil, 3)
			return 'sound'
		end,
		gigadrain = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			absorb(pokemon, target, 20)
			return true
		end,
		hydrovortex = function (pokemon, targets, move)
			local target = targets[1];
			if not target then
				return;
			end;
			local sprite = pokemon.sprite
			local from = targetPoint(pokemon, 2)
			local to = targetPoint(target, 0.5)
			local pos1 = target.sprite.spriteData.inAir or 0
			local model = Instance.new("Model", workspace)
			_p.DataManager:preload("Image", 650846795)
			for ab, ba in pairs({ 165709404, 212966179, 1051557 }) do
				local part1 = create("Part")({
					Anchored = true, 
					CanCollide = false, 
					CFrame = move.CoordinateFrame2 + Vector3.new(0, -3, 0), 
					Parent = model,
					create("SpecialMesh")({
						MeshType = Enum.MeshType.FileMesh, 
						MeshId = "rbxassetid://" .. ba, 
						Scale = Vector3.new(0.2, 0.2, 0.2)
					})
				});
			end;
			local cfr = target.sprite.part.CFrame
			local clr = BrickColor.new("Pastel Blue").Color
			local dif = to - from
			local cfp = cfr - cfr.p
			local function gui(a1)
				local part2 = create("Part")({
					Transparency = 1,
					Anchored = true, 
					CanCollide = false, 
					Parent = workspace
				})
				local bill = create("BillboardGui")({
					Parent = part2
				})
				return part2, bill, create("ImageLabel")({
					BackgroundTransparency = 1, 
					Image = "rbxassetid://".. a1,
					ZIndex = 2, 
					Parent = bill
				})
			end
			spawn(function()
				for i = 1, 50 do
					spawn(function()
						local bc, cb = gui(650846795, 1, Color3.fromHSV((210 + math.random() * 20) / 360, 0.8, 0.75))
						Tween(0.4, nil, function(a)
							bc.CFrame = CFrame.new(from + dif * a)
							cb.Size = UDim2.new(1 + 2 * a, 0, 1 + 2 * a, 0)
						end)
						bc:Destroy()
						for n = 1, 2 do
							local rdom = math.random() * 360;
							_p.Particles:new({
								Color = clr, 
								Image = 650846795, 
								Lifetime = 0.5, 
								Size = 1, 
								Position = to, 
								Velocity = 5 * (cfp * Vector3.new(math.cos(math.rad(rdom)), math.sin(math.rad(rdom)), 0)), 
								Acceleration = false, 
								OnUpdate = function(ac, ca)
									ca.BillboardGui.ImageLabel.ImageTransparency = 0.3 + 0.7 * ac
								end
							})
						end
					end)
					task.wait(0.05)
				end
			end)
			task.wait(1.7)
			local part3 = create("Part")({
				BrickColor = BrickColor.new("Bright blue"), 
				Material = Enum.Material.Foil, 
				TopSurface = Enum.SurfaceType.Smooth, 
				BottomSurface = Enum.SurfaceType.Smooth, 
				CanCollide = false, 
				Anchored = true, 
				Size = Vector3.new(250, 50, 250), 
				Parent = workspace
			})
			local cfr2 = workspace.CurrentCamera.CFrame
			local cfr3 = CFrame.new((move.CoordinateFrame1.p + move.CoordinateFrame2.p) / 2) + Vector3.new(0, -10, 0)
			local v3c = Vector3.new(0, cfr2.y - cfr3.Y + 3, 0)
			local frame = create("Frame")({
				BorderSizePixel = 0, 
				BackgroundTransparency = 0.6, 
				BackgroundColor3 = part3.BrickColor.Color, 
				Size = UDim2.new(1, 0, 1, 60), 
				ZIndex = 10, 
				Parent = Utilities.frontGui
			});
			local view = cfr2.upVector.Y * 0.5 * math.tan(math.rad(workspace.CurrentCamera.FieldOfView) / 2)
			local v1 = cfr2.y + cfr2.lookVector.Y * 0.5 + view
			local v2 = view * 2
			Tween(1.6, nil, function(b)
				local camera = cfr3 + v3c * b
				part3.CFrame = camera + Vector3.new(0, -25, 0)
				local cam = math.max(0, (v1 - camera.y) / v2)
				frame.Position = UDim2.new(0, 0, cam, -36 * (1 - cam))
			end)
			if pos1 > 0 then
				Tween(1, nil, function(c)
					target.sprite.offset = Vector3.new(0, -pos1 * c, 0)
				end)
			end
			task.wait(0.5)
			local unt = dif * Vector3.new(1, 0, 1).unit
			local sp = sprite.spriteData.inAir or 0
			Tween(0.6, nil, function(c)
				sprite.offset = unt * -2 * c + Vector3.new(0, math.sin(c * math.pi) - sp * c, 0)
			end)
			local signal = Utilities.Signal()
			local y = sprite.part.Size.Y
			local part4 = create("Part")({
				BrickColor = BrickColor.new("Bright blue"), 
				Anchored = true, 
				CanCollide = false, 
				Size = Vector3.new(1, 1, 1), 
				Parent = workspace,
				create("SpecialMesh")({
					MeshType = Enum.MeshType.FileMesh, 
					MeshId = "rbxassetid://212966179", 
					Scale = Vector3.new(1.1, 1.8, 1.1) * y
				})
			})
			local part5 = create("Part")({
				BrickColor = BrickColor.new("Bright blue"), 
				Transparency = 0.5, 
				Anchored = true, 
				CanCollide = false, 
				Size = Vector3.new(1, 1, 1), 
				Parent = workspace,
				create("SpecialMesh")({
					MeshType = Enum.MeshType.FileMesh, 
					MeshId = "rbxassetid://165709404", 
					Scale = Vector3.new(2, 2, 2) * y
				})
			})
			local sf = sprite.cf.p + Vector3.new(0, y / 2, 0)
			local angle = CFrame.new(sf, sf + unt) * CFrame.Angles(-math.pi / 2, 0, 0)
			local an = angle * CFrame.new(0, -0.48 * y, 0) * CFrame.Angles(math.pi, 0, 0)
			local shift = false
			local magn = dif.magnitude
			local function storm()
				local part6 = create("Part")({
					BrickColor = BrickColor.new("Storm blue"), 
					Anchored = true, 
					CanCollide = false, 
					Size = Vector3.new(1, 1, 1), 
					Parent = workspace,
					create("SpecialMesh")({
						MeshType = Enum.MeshType.FileMesh, 
						MeshId = "rbxassetid://1051557", 
						Scale = Vector3.new(4, 4, 4)
					})
				})
				local part7 = part6:Clone()
				part7.Parent = workspace;
				local look = target.sprite.cf + Vector3.new(0, 3 - pos1, 0) + workspace.CurrentCamera.CFrame.lookVector * -0.3;
				Utilities.Tween(4, nil, function(o, p)
					if p < 0.7 then
						part6.Transparency = math.max(0, 1 - 2 * p);
						part7.Transparency = part6.Transparency;
					elseif p > 3 then
						part6.Transparency = p - 3;
						part7.Transparency = part6.Transparency;
					end;
					part6.CFrame = look * CFrame.Angles(0, -5 * p, 0);
					part7.CFrame = look * CFrame.Angles(0, -5 * p + 3.14, 0);
					target.sprite.offset = Vector3.new(0, 1 - math.cos(p * math.pi * 2) - pos1, 0);
					target.sprite.animation.spriteLabel.Rotation = 360 * p * 3;
				end)
				part6:Destroy()
				part7:Destroy()
				signal:fire()
			end;
			Tween(1, nil, function(q, r)
				local u1 = 70 * r * r - 2 + 5 * r
				local u2 = unt * u1 + Vector3.new(0, -sp, 0)
				sprite.offset = u2
				part4.CFrame = angle + u2
				part5.CFrame = an + u2
				local cal = math.min(1, r * 3)
				part4.Transparency = 1 - 0.2 * cal
				part5.Transparency = 1 - 0.5 * cal
				if not shift and magn <= u1 then
					shift = true
					spawn(storm)
				end
			end)
			part4:Destroy()
			part5:Destroy()
			signal:wait()
			model:Destroy()
			Tween(2, nil, function(f)
				local f1 = cfr3 + v3c * (1 - f)
				part3.CFrame = f1 + Vector3.new(0, -25, 0)
				local f2 = math.max(0, (v1 - f1.y) / v2)
				frame.Position = UDim2.new(0, 0, f2, -36 * (1 - f2))
				sprite.offset = Vector3.new(0, math.max(0, f1.y - sprite.cf.y), 0);
			end)
			part3:Destroy()
			frame:Destroy()
			if pos1 > 0 then
				spawn(function()
					Tween(0.5, nil, function(g)
						target.sprite.offset = Vector3.new(0, -pos1 * (1 - g), 0);
					end)
				end)
			end
			return true
		end,
		icebeam = function(p216, p217, p218) -- frostbeam
			local v415 = p217[1];
			if not v415 then return end
			local v416 = p216.sprite or p216;
			local v417 = v416.part.CFrame * Vector3.new(0, v416.part.Size.Y * 0.15, v416.part.Size.Z * -0.5 - 0);
			local v418 = v415.sprite or v415;
			local v419 = v418.part.CFrame * Vector3.new(0, v418.part.Size.Y * 0.15, v418.part.Size.Z * -0.5 - 0);
			local cf68 = CFrame.new(v417, v419);
			local u211 = v419 - cf68.p;
			local u212 = Utilities.Create("Part")({
				Shape = "Ball",
				Anchored = true,
				CanCollide = false,
				Size = Vector3.new(0.7, 0.7, 0.7),
				CFrame = cf68 * CFrame.new(0, 0, -2),
				Color = Color3.fromRGB(128, 187, 219),
				Material = "Neon",
				Transparency = 0.1
			});
			local bool12 = true;
			local u213 = u211.magnitude / 2;
			local u214 = 0.5;
			local table53 = {
				Color = ColorSequence.new(Color3.fromRGB(160, 255, 255)),
				Transparency = NumberSequence.new(0, 1),
				WidthScale = NumberSequence.new(1, 0.1),
				LightEmission = 0.5,
				Lifetime = u214 * 2
			};
			local math_pi3 = math.pi;
			local u215 = cf68 * CFrame.new(0, 0, -u213);
			local coroutine_wrap_ret19 = coroutine.wrap(function()
				while bool12 == true do
					local u428 = ({
						-1,
						1
					})[Random_new_ret:NextInteger(1, 2)];
					local u429 = Random_new_ret:NextNumber() * 2 * math.pi;
					spawn(function()
						u13.makeSpiral(1, u215 * CFrame.Angles(math.pi / 2, u429, 0) * CFrame.new(0, -u213 / 2, 0), math_pi3 * u428, u213, 10, 0.25, TweenInfo.new(u214, Enum.EasingStyle.Linear), "Shrink", table53);
					end);
					task.wait();
				end
			end);
			coroutine_wrap_ret19();
			u212.Parent = p218.scene;
			local Clone_ret169 = Particles.Gravity:Clone();
			Clone_ret169.Parent = u212;
			u13.Tween(TweenInfo.new(2), true, function(p508)
				Clone_ret169.Size = NumberSequence.new(p508 * 7.5 + 2.5, 0.5);
				local v866 = p508 * 4 + 1;
				u212.Size = Vector3.new(v866, v866, v866);
				Clone_ret169.Rate = p508 * 100 + 20;
				Clone_ret169.Lifetime = NumberRange.new(1 - p508 * 0.9);
				u214 = 0.5 - p508 * 0.35;
				u213 = u213 + u211.magnitude / 2 * p508;
			end);
			bool12 = false;
			Clone_ret169.Enabled = false;
			local u216 = Utilities.Create("Part")({
				Shape = "Cylinder",
				Anchored = true,
				CanCollide = false,
				Size = Vector3.new(1, 5, 5),
				CFrame = cf68 * CFrame.new(0, 0, -2.5) * CFrame.Angles(math.pi / 2, 0, math.pi / 2),
				Color = Color3.fromRGB(128, 187, 219),
				Material = "Neon",
				Transparency = 0.1
			});
			u216.Parent = p218.scene;
			local Attachment63 = Instance.new("Attachment", workspace.Terrain);
			Attachment63.WorldCFrame = cf68;
			local Clone_ret170 = Particles.Ice:Clone();
			Clone_ret170.Enabled = false;
			Clone_ret170.Parent = Attachment63;
			Clone_ret170.Size = NumberSequence.new(2, 4);
			Clone_ret170.SpreadAngle = Vector2.new(0, 360);
			Clone_ret170.Speed = NumberRange.new(45);
			Clone_ret170:Emit(20);
			u13.Tween(TweenInfo.new(0.1), true, function(p509)
				local v867 = 5 - p509 * 4.5;
				u212.Size = Vector3.new(v867, v867, v867);
			end);
			task.wait();
			u212.Size = Vector3.new(5, 5, 5);
			local u217 = v419 - cf68.p;
			u9("FastExplosion",1);
			u13.Tween(TweenInfo.new(0.35), false, function(p510)
				u216.Size = Vector3.new(u217.magnitude * p510 + 2.5, 5, 5);
				u216.CFrame = (cf68 + u217 / 2 * p510 + u217.unit * 5 / 2) * CFrame.Angles(math.pi / 2, 0, math.pi / 2);
			end);
			local Clone_ret171 = Misc.IceChunk:Clone();
			Clone_ret171.Material = "ForceField";
			Clone_ret171.Size = Vector3.new(3, 4, 4);
			Clone_ret171.Transparency = 0.1;
			Clone_ret171.CFrame = cf68 + u211;
			local Clone_ret172 = Clone_ret171:Clone();
			Clone_ret172.Material = "Neon";
			Clone_ret172.Transparency = 0.8;
			local CFrame49 = p217[1].sprite.part.CFrame or p217[1].sprite.part
			Clone_ret171.Parent = p218.scene;
			Clone_ret172.Parent = p218.scene;
			local Size26 = Clone_ret171.Size;
			spawn(function()
				u13.blast(cf68 + u211, 25, u211, 36, Color3.fromRGB(128, 187, 219), Color3.fromRGB(128, 187, 219), Color3.fromRGB(128, 187, 219));
			end);
			u13.Tween(TweenInfo.new(0.1, Enum.EasingStyle.Cubic), false, function(p511)
				Clone_ret171.Size = Size26 + Vector3.new(p511 * 16, p511 * 20, p511 * 20);
				Clone_ret172.Size = Clone_ret171.Size * 0.85;
				Clone_ret171.CFrame = CFrame49 + Vector3.new(0, Clone_ret171.Size.Y / 2 * p511 - 1, 0);
				Clone_ret172.CFrame = Clone_ret171.CFrame;
			end);
			spawn(function()
				u13.Tween(TweenInfo.new(1), true, function(p651)
					local v968 = p651 * 5 + 5;
					u216.Size = Vector3.new(u217.magnitude + 2.5, v968, v968);
					u212.Size = Vector3.new(v968, v968, v968);
					u216.Transparency = p651 * 0.9 + 0.1;
					u212.Transparency = p651 * 0.9 + 0.1;
				end);
				local _ = Clone_ret171.CFrame;
				u13.Tween(TweenInfo.new(1), true, function(p652)
					Clone_ret171.Transparency = p652 * 0.9 + 0.1;
					Clone_ret172.Transparency = p652 * 0.2 + 0.8;
				end);
				u212:Destroy();
				u216:Destroy();
				Attachment63:Destroy();
				Clone_ret171:Destroy();
				Clone_ret172:Destroy();
			end);
			return true;
		end,

		incinerate = function(p153, p154, p155) -- fireslam
			local v287 = p154[1];
			if not v287 then return end
			local v288 = p153.sprite or p153;
			local v289 = v288.part.CFrame * Vector3.new(0, v288.part.Size.Y * 0.15, v288.part.Size.Z * -0.5 - 0);
			local v290 = v287.sprite or v287;
			local v291 = v290.part.CFrame * Vector3.new(0, v290.part.Size.Y * 0.15, v290.part.Size.Z * -0.5 - 0);
			local cf47 = CFrame.new(v289, v291);
			local u141 = v291 - v289;
			local magnitude12 = u141.magnitude;
			local Clone_ret110 = Misc.HalfCircle:Clone();
			Clone_ret110.Anchored = true;
			Clone_ret110.Size = Vector3.new(3, 5, 3);
			Clone_ret110.Color = Color3.fromRGB(255, 0, 0);
			Clone_ret110.CanCollide = false;
			Clone_ret110.CFrame = cf47;
			local Clone_ret111 = Misc.blaze:Clone();
			Clone_ret111.Color = Color3.fromRGB(255, 0, 0);
			Clone_ret111.Transparency = 0.5;
			Clone_ret111.CFrame = cf47 * CFrame.Angles(math.pi / 2, 0, 0);
			Clone_ret111.Size = Vector3.new(2.8, 1, 2.8);
			local Clone_ret112 = Clone_ret111:Clone();
			Clone_ret112.Size = Clone_ret112.Size * 0.8;
			Clone_ret112.Color = Color3.fromRGB(245, 205, 48);
			local u142 = magnitude12 / 45;
			Clone_ret110.Parent = p155.scene;
			Clone_ret111.Parent = p155.scene;
			Clone_ret112.Parent = p155.scene;
			spawn(function()
				for index96 = 1, 2 do
					spawn(function()
						local Clone_ret113 = Misc.Frustum:Clone();
						Clone_ret113.Color = Color3.fromRGB(255, 0, 0);
						Clone_ret113.Material = "Neon";
						Clone_ret113.Anchored = true;
						Clone_ret113.CanCollide = false;
						Clone_ret113.CFrame = (cf47 + (u141 - u141.unit) * index96 / 3) * CFrame.Angles(-math.pi / 2, 0, 0);
						local v991 = 20 - (index96 - 1) * 5;
						local _ = Vector3.new(v991, 1, v991);
						Clone_ret113.Size = Vector3.new(v991 * 0.25, 1, v991 * 0.25);
						local Size20 = Clone_ret113.Size;
						local u436 = v991 - v991 * 0.25;
						Clone_ret113.Parent = p155.scene;
						u13.Tween(TweenInfo.new(u142, Enum.EasingStyle.Linear), true, function(p739)
							Clone_ret113.Size = Size20 + Vector3.new(u436 * p739, 0, u436 * p739);
							Clone_ret113.Transparency = p739;
						end);
						Clone_ret113:Destroy();
					end);
					task.wait(u142 / 3);
				end
			end);
			local _ = p153.sprite.part;
			--u13.Tween(TweenInfo.new(0.5), false, function(p474)
			--	p153.sprite:setOffset((Vector3.new(0, 0, math.sin(math.pi * p474) * 2)));
			--end);
			u13.Tween(TweenInfo.new(u142), true, function(p475)
				Clone_ret110.CFrame = cf47 * CFrame.new(0, 0, -(magnitude12 + 2.5) * p475) * CFrame.Angles(math.pi / 2, 0, 0);
				Clone_ret111.Size = Vector3.new(2.8, (magnitude12 - 2.5) * p475 + 1, 2.8);
				Clone_ret112.Size = Clone_ret111.Size - Vector3.new(0.2, 0, 0.2) * Clone_ret111.Size;
				Clone_ret111.CFrame = (cf47 + u141 / 2 * p475) * CFrame.Angles(math.pi / 2, math.pi * 2 * p475, 0);
				Clone_ret112.CFrame = (cf47 + u141 / 2 * p475) * CFrame.Angles(math.pi / 2, math.pi * -2 * p475, 0);
				Clone_ret111.Transparency = p475;
				Clone_ret112.Transparency = p475;
			end);
			Clone_ret110:Destroy();
			Clone_ret111:Destroy();
			Clone_ret112:Destroy();
			u13.ballExplosion(TweenInfo.new(1, Enum.EasingStyle.Cubic), CFrame.new(v289) + u141, 20, Color3.fromRGB(245, 205, 48), Color3.fromRGB(255, 0, 0), "Neon", "Neon");
			return true;
		end,
		wildcharge = function(p183, p184, p185) -- thundercrash
			local v347 = p184[1];
			if not v347 then return end
			local v348 = p183.sprite or p183;
			local _ = v348.part.CFrame * Vector3.new(0, v348.part.Size.Y * 0.15, v348.part.Size.Z * -0.5 - 0);
			local v349 = v347.sprite or v347;
			local v350 = v349.part.CFrame * Vector3.new(0, v349.part.Size.Y * 0.15, v349.part.Size.Z * -0.5 - 0);
			local Model15 = p183.sprite.part;
			local Base11 = Model15;
			local CFrame40 = Base11.CFrame;
			local Full4 = Model15;
			local CFrame41 = Base11.CFrame;
			local Size22 = Full4.Size;
			local math_max_ret = math.max(math.max(Size22.X, Size22.Y, Size22.Z), 8);
			local u170 = 0.1;
			local u171 = 0.1;
			local Clone_ret141 = Misc.Aura1:Clone();
			Clone_ret141.Transparency = 0.5;
			local u172 = math_max_ret / Clone_ret141.Size.X;
			local _ = Misc.StarEffect:Clone();
			local u173 = 0.25;
			local Clone_ret142 = Misc.StarEffect:Clone();
			Clone_ret142.Size = Vector3.new(Clone_ret141.Size.X / 2, Clone_ret142.Size.Y, Clone_ret142.Size.Z);
			Clone_ret142.CFrame = Full4.CFrame * CFrame.new(0, 0, -Clone_ret142.Size.X / 2);
			local function makeAura()
				local Clone_ret143 = Clone_ret141:Clone();
				local u408 = Clone_ret143.Size * u172 * u173;
				local u409 = Full4.CFrame * CFrame.new(0, 0, u408.Y / 2 - 1) * CFrame.Angles(math.pi / 2, math.pi * 2 * Random_new_ret:NextNumber(), 0);
				Clone_ret143.CFrame = u409;
				local NextNumber_ret2 = Random_new_ret:NextNumber(math.pi * -2, math.pi * 2);
				Clone_ret143.Parent = p185.scene;
				u13.Tween(TweenInfo.new(0.5), false, function(p697)
					Clone_ret143.CFrame = u409 * CFrame.Angles(0, NextNumber_ret2 * p697, 0) * CFrame.new(0, p697 * 1.5, 0);
					Clone_ret143.Size = u408 + u408 * 0.15 * p697;
					Clone_ret143.Transparency = p697 * 0.5 + 0.5;
				end).Completed:Connect(function()
					Clone_ret143:Destroy();
				end);
			end
			local bool7 = true;
			spawn(function()
				while bool7 == true do
					makeAura();
					task.wait(0.05);
				end
			end);
			local u175 = 0;
			Clone_ret142.Parent = p185.scene;
			RunService:BindToRenderStep("spinner", Enum.RenderPriority.Camera.Value + 1, function()
				Clone_ret142.CFrame = Full4.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0, math.pi / 2, 0) * CFrame.Angles(u170, 0, 0);
				u170 = u170 + u171;
			end);
			local Size23 = Clone_ret142.Size;
			local u176 = Size23 * u172 * 2;
			u13.Tween(TweenInfo.new(0.3), true, function(p489)
				u173 = p489 * 0.75 + 0.25;
				Clone_ret142.Size = Size23 + (u176 - Size23) * p489;
				if u175 % 5 == 0 then
					local v934 = math.pi * 2 * Random_new_ret:NextNumber();
					local v935 = v934 + Random_new_ret:NextNumber(-math.pi / 4, math.pi / 4);
					u13.BranchLightning((Full4.CFrame * CFrame.new(0, 0, -Size22.Z / 2) * CFrame.Angles(0, 0, v934) * CFrame.new(Clone_ret141.Size.X / 2, 0, 0)).p, (Full4.CFrame * CFrame.new(0, 0, Size22.Z) * CFrame.Angles(0, 0, v935) * CFrame.new(Clone_ret141.Size.X * 1.5, 0, 0)).p, 5, 2, 0.2, Color3.fromRGB(254, 255, 144), 0.1, 3);
				end
				u175 = u175 + 1;
			end);
			local u177 = v347.sprite.cf.p - Base11.Position;
			u175 = 0;
			u13.Tween(TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), true, function(p490)
				u171 = p490 * 0.25 + 0.1;
				if u175 % 3 == 0 then
					local v936 = math.pi * 2 * Random_new_ret:NextNumber();
					local v937 = v936 + Random_new_ret:NextNumber(-math.pi / 4, math.pi / 4);
					u13.BranchLightning((Full4.CFrame * CFrame.new(0, 0, -Size22.Z / 2) * CFrame.Angles(0, 0, v936) * CFrame.new(Clone_ret141.Size.X / 2, 0, 0)).p, (Full4.CFrame * CFrame.new(0, 0, Size22.Z) * CFrame.Angles(0, 0, v937) * CFrame.new(Clone_ret141.Size.X * 1.5, 0, 0)).p, 5, 2, 0.2, Color3.fromRGB(254, 255, 144), 0.4, 3);
					u13.BranchLightning(Full4.Position, (Full4.CFrame * CFrame.new(0, 0, 15)).p, 5, 2, 0.5, Color3.fromRGB(254, 255, 144), 0.4, 3);
				end
				u175 = u175 + 1;
			end);
			local v351, _ = u13.HitRing(CFrame.new(v350), Color3.fromRGB(254, 255, 144), 0.5, 30, NumberSequence.new(0, 1), NumberRange.new(0.5, 0.8));
			v351:Emit(1);
			local Attachment55 = Instance.new("Attachment", workspace.Terrain);
			Attachment55.WorldCFrame = CFrame.new(v350);
			local Clone_ret144 = Particles.SparkV2:Clone();
			Clone_ret144.Size = NumberSequence.new(0.1, 0);
			Clone_ret144.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(254, 255, 144));
			Clone_ret144.Acceleration = Vector3.new(0, -12, 0);
			Clone_ret144.SpreadAngle = Vector2.new(180, 180);
			Clone_ret144.Speed = NumberRange.new(10, 15);
			Clone_ret144.Enabled = false;
			Clone_ret144.Parent = Attachment55;
			Clone_ret144:Emit(36);
			game.Debris:AddItem(Attachment55, Clone_ret144.Lifetime.Max);
			u9("BigBump",1);
			bool7 = false;
			RunService:UnbindFromRenderStep("spinner");
			Clone_ret142:Destroy();
			for index33 = 1, 9 do
				u13.BranchLightning(v350, (Full4.CFrame * CFrame.Angles(0, 0, math.pi * 2 * index33 / 9) * CFrame.new(25, 0, 10)).p, 10, 2, 1, Color3.fromRGB(254, 255, 144), 1, 3);
			end
			local CFrame42 = Model15.CFrame;
			u13.ballExplosion(TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), CFrame.new(v350), 50, Color3.fromRGB(245, 238, 159), Color3.fromRGB(255, 255, 255), "Neon", "Neon");
			return true;
		end,
		lusterpurge = function(p243, p244, p245) -- gammapulse
			local v461 = p244[1];
			if not v461 then return end
			local v462 = p243.sprite or p243;
			local v463 = v462.part.CFrame * Vector3.new(0, v462.part.Size.Y * 0.15, v462.part.Size.Z * -0.5 - 0);
			local v464 = v461.sprite or v461;
			local v465 = v464.part.CFrame * Vector3.new(0, v464.part.Size.Y * 0.15, v464.part.Size.Z * -0.5 - 0);
			local u233 = CFrame.new(v463, v465) * CFrame.new(0, 0, -2);
			local u234 = v465 - u233.p;
			local Clone_ret189 = Particles.LightBlink:Clone();
			Clone_ret189.Size = NumberSequence.new(25, 0.5);
			Clone_ret189.LightEmission = 1;
			Clone_ret189.Enabled = false;
			Clone_ret189.Lifetime = NumberRange.new(1);
			Clone_ret189.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.5, 0),
				NumberSequenceKeypoint.new(1, 1)
			});
			local Attachment73 = Instance.new("Attachment", workspace.Terrain);
			Attachment73.WorldCFrame = u233;
			Clone_ret189.Parent = Attachment73;
			Clone_ret189:Emit(1);
			local Clone_ret190 = Misc.HitEffect1:Clone();
			Clone_ret190.Transparency = 1;
			Clone_ret190.Color = Color3.fromRGB(247, 253, 123);
			Clone_ret190.Size = Vector3.new(0.1, 0.1, 0.1);
			Clone_ret190.CFrame = u233 * CFrame.Angles(-math.pi / 2, 0, 0);
			task.wait(1);
			Clone_ret190.Parent = p245.scene;
			local u235 = Utilities.Create("Part")({
				Shape = "Cylinder",
				Anchored = true,
				Material = "Neon",
				CanCollide = false,
				Color = Color3.fromRGB(237, 241, 157),
				Size = Vector3.new(1, 10, 10),
				CFrame = u233,
				Parent = p245.scene
			});
			local Attachment74 = Instance.new("Attachment", workspace.Terrain);
			Attachment74.WorldCFrame = u233;
			local Clone_ret191 = Particles.Light:Clone();
			Clone_ret191.EmissionDirection = "Front";
			Clone_ret191.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 5, 2),
				NumberSequenceKeypoint.new(1, 0.2, 0.15)
			});
			Clone_ret191.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.8, 0),
				NumberSequenceKeypoint.new(1, 1)
			});
			Clone_ret191.SpreadAngle = Vector2.new(90, 90);
			Clone_ret191.Speed = NumberRange.new(25, 35);
			Clone_ret191.RotSpeed = NumberRange.new(0, 360);
			Clone_ret191.Lifetime = NumberRange.new(0.4, 1);
			Clone_ret191.Rate = 150;
			Clone_ret191.Enabled = true;
			Clone_ret191.Parent = Attachment74;
			local Attachment75 = Instance.new("Attachment", workspace.Terrain);
			Attachment75.WorldCFrame = u233 + u234;
			local Clone_ret192 = Particles.Piercing:Clone();
			Clone_ret192.Lifetime = NumberRange.new(1.5, 2);
			Clone_ret192.Size = NumberSequence.new(30, 40);
			Clone_ret192.Enabled = false;
			Clone_ret192.Parent = Attachment75;
			local u236 = 0.15;
			RunService:BindToRenderStep("spin", Enum.RenderPriority.Camera.Value, function()
				Clone_ret190.CFrame = Clone_ret190.CFrame * CFrame.Angles(0, u236, 0);
			end);
			Clone_ret191:Emit(50);
			u9("BigExplosion",1);
			u13.Tween(TweenInfo.new(0.1), true, function(p523)
				u236 = p523 * 0.05 + 0.1;
				Clone_ret190.Size = Vector3.new(p523 * 10, p523 * 3, p523 * 10);
				Clone_ret190.Transparency = 1 - p523;
				u235.Size = Vector3.new(u234.magnitude * p523, 10 - p523 * 5, 10 - p523 * 5);
				u235.CFrame = u233 * CFrame.new(0, 0, -u234.magnitude / 2 * p523) * CFrame.Angles(math.pi / 2, 0, math.pi / 2);
			end);
			Clone_ret192:Emit(25);
			spawn(function()
				u13.ballExplosion(TweenInfo.new(2, Enum.EasingStyle.Cubic), u233 + u234, 20, Color3.fromRGB(255, 255, 255), Color3.fromRGB(237, 241, 157), "Neon", "Neon");
			end);
			delay(0.5, function()
				Clone_ret191.Enabled = false;
			end);
			spawn(function()
				u13.Tween(TweenInfo.new(2), true, function(p655)
					u236 = p655 * 0.05 + 0.1;
					u235.Size = Vector3.new(u234.magnitude, p655 * 5 + 5, p655 * 5 + 5);
					Clone_ret190.Size = Vector3.new(p655 * 5 + 10, 3, p655 * 5 + 10);
					Clone_ret190.Transparency = p655;
					u235.Transparency = p655;
				end);
				u235:Destroy();
				Attachment74:Destroy();
				Attachment75:Destroy();
				Clone_ret190:Destroy();
				RunService:UnbindFromRenderStep("spin");
			end);
			return true;
		end,
		icefang = function(p219, p220, p221) -- chillychomp
			local v420 = p220[1];
			if not v420 then return end
			local v421 = p219.sprite or p219;
			local v422 = v421.part.CFrame * Vector3.new(0, v421.part.Size.Y * 0.15, v421.part.Size.Z * -0.5 - 0);
			local v423 = v420.sprite or v420;
			local v424 = v423.part.CFrame * Vector3.new(0, v423.part.Size.Y * 0.15, v423.part.Size.Z * -0.5 - 0);
			local cf69 = CFrame.new(v422, v424);
			local Clone_ret173 = storage.Models.Misc.Bite:Clone();
			local Top6 = Clone_ret173.Top;
			local Bottom6 = Clone_ret173.Bottom;
			local Color3_fromRGB_ret14 = Color3.fromRGB(85, 248, 248);
			local Color3_fromRGB_ret15 = Color3.fromRGB(156, 224, 255);
			Top6.Color = Color3_fromRGB_ret14;
			Bottom6.Color = Color3_fromRGB_ret14;
			Top6.Transparency = 1;
			Bottom6.Transparency = 1;
			Top6.Material = "Neon";
			Bottom6.Material = "Neon";
			Clone_ret173.PrimaryPart = Clone_ret173.Main;
			Clone_ret173:PivotTo(cf69);
			local u218 = v424 - v422;
			Utilities.ScaleModel(Clone_ret173.Main, 3);
			Clone_ret173.Parent = p221.scene;
			local inverse_ret6 = Clone_ret173.Main.CFrame:inverse();
			local u219 = inverse_ret6 * Top6.CFrame;
			local u220 = inverse_ret6 * Bottom6.CFrame;
			local _ = Top6.Size.X;
			Clone_ret173:PivotTo(cf69);
			local CFrame50 = Clone_ret173.PrimaryPart.CFrame;
			u13.Tween(TweenInfo.new(0.55), true, function(p512)
				local v868 = 1 - p512;
				local cf70 = CFrame.new(0, 0, v868 * -1);
				local v869 = 0.4 - v868 * 0.4;
				Top6.CFrame = Clone_ret173.PrimaryPart.CFrame * cf70 * CFrame.Angles(v869, 0, 0) * u219;
				Bottom6.CFrame = Clone_ret173.PrimaryPart.CFrame * cf70 * CFrame.Angles(-v869, 0, 0) * u220;
				Top6.Transparency = 1 - p512;
				Bottom6.Transparency = 1 - p512;
			end);
			local table54 = {
				Color = ColorSequence.new(Color3_fromRGB_ret14, Color3_fromRGB_ret15),
				Transparency = NumberSequence.new(0, 1),
				WidthScale = NumberSequence.new(0, 1),
				LightEmission = 1,
				Lifetime = 0.5
			};
			for index41 = 1, 9 do
				local u378 = cf69 * CFrame.new(math.cos(math.pi * 2 * index41 / 5) * 4, math.sin(math.pi * 2 * index41 / 5) * 4, 0);
				spawn(function()
					u13.makeSpiral(1, u378 * CFrame.Angles(-math.pi / 2, 0, 0), 0, u218.magnitude + 3, 0, 0.5, TweenInfo.new(0.25, Enum.EasingStyle.Linear), nil, table54);
				end);
			end
			spawn(function()
				for index99 = 1, 5 do
					local Clone_ret174 = Misc.ThinRing:Clone();
					Clone_ret174.Color = Color3_fromRGB_ret15:Lerp(Color3_fromRGB_ret14, index99 / 5);
					Clone_ret174.Material = "Neon";
					Clone_ret174.Size = Vector3.new(1, 0.1, 1);
					Clone_ret174.CFrame = cf69 * CFrame.new(0, 0, -u218.magnitude * index99 / 5) * CFrame.Angles(math.pi / 2, 0, 0);
					Clone_ret174.Parent = p221.scene;
					u13.Tween(TweenInfo.new(0.25), false, function(p699)
						Clone_ret174.Size = Vector3.new(p699 * 15 + 1, 0.1, p699 * 15 + 1);
						Clone_ret174.Transparency = p699;
					end);
					game.Debris:AddItem(Clone_ret174, 0.25);
					task.wait(0.05);
				end
			end);
			u13.Tween(TweenInfo.new(0.25), true, function(p513)
				local v870 = 1 - p513;
				local cf71 = CFrame.new(0, 0, v870 * -1);
				local v871 = v870 * 0.9;
				Clone_ret173:PivotTo(CFrame50 + (u218 - u218.unit * Top6.Size.X) * p513);
				Top6.CFrame = Clone_ret173.PrimaryPart.CFrame * cf71 * CFrame.Angles(v871, 0, 0) * u219;
				Bottom6.CFrame = Clone_ret173.PrimaryPart.CFrame * cf71 * CFrame.Angles(-v871, 0, 0) * u220;
			end);
			Top6.Transparency = 1;
			Bottom6.Transparency = 1;
			local Attachment64 = Instance.new("Attachment", workspace.Terrain);
			Attachment64.WorldCFrame = CFrame.new(v424);
			local Clone_ret175 = Particles.Ice:Clone();
			Clone_ret175.Enabled = false;
			Clone_ret175.SpreadAngle = Vector2.new(360, 360);
			Clone_ret175.Size = NumberSequence.new(3, 0.1);
			Clone_ret175.Transparency = NumberSequence.new(0, 1);
			Clone_ret175.Speed = NumberRange.new(15, 20);
			Clone_ret175.Acceleration = Vector3.new(0, 0, 0);
			Clone_ret175.Parent = Attachment64;
			Clone_ret175:Emit(30);
			for index42 = 1, 15 do
				u13.trailSwirl(CFrame.new(v424) * CFrame.Angles(0, math.pi * 2 * index42 / 15, 0), 2, index42 * 4 / 15 + 5, 0.5, math.pi * 3 + math.pi * index42 / 15, table54, false, true);
			end
			game.Debris:AddItem(Attachment64, Clone_ret175.Lifetime.Max);
			Clone_ret173:Destroy();
			return true;
		end,
		--	leafage = function(pokemon)
		--		
		--	end,
		lightscreen = function(pokemon)
			shield(pokemon, 'Pastel light blue')
		end,
		megadrain = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			absorb(pokemon, target, 12)
			return true
		end,
		metalclaw = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Smoky grey', 3)
			return 'sound'
		end,
		moonblast = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			local from = targetPoint(pokemon, 2)
			local to = targetPoint(target)
			local dif = to-from

			local moon = create 'Part' {
				BrickColor = BrickColor.new('Carnation pink'),
				Material = Enum.Material.Neon,
				Anchored = true,
				CanCollide = false,
				TopSurface = Enum.SurfaceType.Smooth,
				BottomSurface = Enum.SurfaceType.Smooth,
				Size = Vector3.new(4, 4, 4),
				Shape = Enum.PartType.Ball,
				CFrame = CFrame.new(pokemon.sprite.cf.p+Vector3.new(0, 7-(pokemon.sprite.spriteData.inAir or 0), 0)),
				Parent = workspace
			}
			Tween(1, nil, function(a)
				moon.Transparency = 1-a
			end)
			local blast = moon:Clone()
			blast.BrickColor = BrickColor.new('Pink')
			blast.Parent = workspace
			local twoPi = math.pi*2
			local r = 4
			for i = 1, 20 do
				delay(.075*i, function()
					local beam = create 'Part' {
						Material = Enum.Material.Neon,
						BrickColor = BrickColor.new('White'),
						Anchored = true,
						CanCollide = false,
						TopSurface = Enum.SurfaceType.Smooth,
						BottomSurface = Enum.SurfaceType.Smooth,
						Parent = workspace,
					}
					local transform = CFrame.Angles(twoPi*math.random(),twoPi*math.random(),twoPi*math.random()).lookVector * r
					local cf = CFrame.new(from)*transform
					Tween(.25, nil, function(a)
						beam.Size = Vector3.new(.2, .2, r*a)
						beam.CFrame = CFrame.new(cf + (from-cf)/2*a, cf)
					end)
					Tween(.25, nil, function(a)
						beam.Size = Vector3.new(.2, .2, r*(1-a))
						beam.CFrame = CFrame.new(cf + (from-cf)*(.5+.5*a), cf)
					end)
					beam:Destroy()
				end)
			end
			Tween(2, nil, function(a)
				blast.Size = Vector3.new(2.3,2.3,2.3)*a
				blast.CFrame = CFrame.new(from)
			end)
			task.wait(.2)
			Tween(.3, nil, function(a)
				blast.CFrame = CFrame.new(from+dif*a)
			end)
			blast:Destroy()
			spawn(function()
				Tween(1, nil, function(a)
					moon.Transparency = a
				end)
				moon:Destroy()
			end)
			return true
		end,
		protect = function(pokemon)
			shield(pokemon)
		end,

		psychocut = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Pink')
			return 'sound'
		end,
		razorleaf = function(pokemon, targets)
			local target = targets[1]; 
			if not target then 
				return 
			end
			local from = targetPoint(pokemon, 2)
			local leaf = storage.Models.Misc.Leaf
			local to = targetPoint(target)
			local part = pokemon.sprite.part
			local tp1 = part.CFrame * Vector3.new(part.Size * Vector3.new(-0.5, 25, -0.25) + Vector3.new(-1, 0, 0))
			local tp2 = part.CFrame * Vector3.new(part.Size * Vector3.new(-0.5, 25, -0.25) + Vector3.new(-1, 0, 0))
			local RightVector = part.CFrame.RightVector
			local LookVector = part.CFrame.LookVector
			local position
			for i = 1, 9 do
				if math.random(2) == 1 then
					position = tp1 - RightVector * math.random() + Vector3.new(0, 4 * (math.random() - 0.5), 0) + LookVector * 2 * (math.random() - 0.5)
				else
					position = tp2 + RightVector * math.random() + Vector3.new(0, 4 * (math.random() - 0.5), 0) + LookVector * 2 * (math.random() - 0.5)
				end
				local leafpart = leaf:Clone()
				leafpart.Parent = workspace;
				local spot = CFrame.new(position, to)
				Utilities.fastSpawn(function()
					Tween(0.065, "easeOutQuad", function(a)
						leafpart.CFrame = spot + Vector3.new(0, -0.2 * (1 - a), 0)
					end)
					task.wait(0.28)
					local ok = to - spot.Position
					local cool = ok + ok.Unit * 0.2
					Tween(0.5, nil, function(b)
						leafpart.CFrame = spot + cool * b
					end)
					leafpart:Destroy()
				end)
				task.wait(0.01)
			end
			task.wait(0.6)
			return true
		end,
--[[ razorleaf = function(pokemon, targets)
		local target = targets[1]; if not target then return end
		local orientation = pokemon.sprite.part.CFrame - pokemon.sprite.part.Position
		local from = orientation + targetPoint(pokemon, -.5)
		local to = orientation + targetPoint(target, .5)
		local psize = pokemon.sprite.part.Size
		local tsize = target.sprite.part.Size
		local p = _p.Particles
		local ease = Utilities.Timing.easeOutCubic(.3)
		local rot = target.sprite.siden==2 and 35 or 215
		for i = 1, 10 do -- 
			task.wait(.1)
			local x, y = math.random()-.5, math.random()-.5
			local thisfrom = from * CFrame.new(psize.X*x, psize.Y*y, 0)
			local thisto = to * CFrame.new(tsize.X*x, tsize.Y*y, 0)
			local dif = thisto.p - thisfrom.p
			p:new {
				Rotation = math.random(360),
				RotVelocity = 30,
				Acceleration = false,
				Lifetime = 1.45,
				Image = 29073832,
				Size = .6,
				OnUpdate = function(a, gui)
					local t = a*1.45
					if t < .3 then
						gui.CFrame = thisfrom + Vector3.new(0, ease(t), 0)
					elseif t < 1.1 then
						gui.CFrame = thisfrom + Vector3.new(0, 1-.5*(t-.3)/.8, 0)
					else
						gui.BillboardGui.ImageLabel.Rotation = rot
						local o = (t-1.1)/.35
						gui.CFrame = thisfrom + Vector3.new(0, .5*(1-o), 0) + dif*o
					end
				end,
			}
		end
		task.wait(1.7)
		return true
	end,]]
		reflect = function(pokemon)
			shield(pokemon, 'Carnation pink')
		end,
		rockslide = function(pokemon, targets)
			for _, target in pairs(targets) do
				spawn(function()
					local cf = target.sprite.part.CFrame
					cf = cf-cf.p
					local dir = targetPoint(target, 0)-targetPoint(target, 1)
					local pos = target.sprite.part.Position+Vector3.new(0, -target.sprite.part.Size.Y/2-(target.sprite.spriteData.inAir or 0), 0)
					local rockcf = CFrame.new(pos - dir + Vector3.new(0, .7, 0), pos + Vector3.new(0, .7, 0))

					for _ = 1, 4 do
						local rock = create 'Part' {
							Anchored = true,
							CanCollide = false,
							BrickColor = BrickColor.new('Dirt brown'),
							Size = Vector3.new(1.4, 1.4, 1.4),
							Parent = workspace,

							create 'SpecialMesh' {
								MeshType = Enum.MeshType.FileMesh,
								MeshId = 'rbxassetid://1290033',
								Scale = Vector3.new(.8, .8, .8)
							}
						}
						local xoffset = cf*Vector3.new((math.random()-.5)*3, 0, 0)
						local rot = CFrame.Angles(math.random()*6.3, math.random()*6.3, math.random()*6.3)
						spawn(function()
							Tween(.5, nil, function(a)
								rock.CFrame = (rockcf + xoffset + Vector3.new(0, 8*(1-a), 0)) * rot
							end)
							Tween(.4, nil, function(a)
								rock.CFrame = (rockcf + xoffset + dir*2*a + Vector3.new(0, math.sin(a*math.pi*5/4)-a, 0)) * CFrame.Angles(-6*a, 0, 0) * rot
							end)
							rock:Destroy()
						end)
						task.wait(.25)
					end
				end)
			end
			task.wait(1.3)
			return true
		end,
		sacredsword = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Brown')
			return 'sound'
		end,
		scald = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			local sprite = pokemon.sprite
			local s = targetPoint(pokemon, 2)
			local e = targetPoint(target, .5)
			local dp = e-s

			local tSprite = target.sprite
			local cf = tSprite.part.CFrame
			cf = cf-cf.p
			local tLabel; pcall(function() tLabel = tSprite.animation.spriteLabel end)
			delay(.7, function()
				Tween(.84, nil, function(a)
					local s = math.sin(a*math.pi)
					local m = (a*5)%1
					if m > .75 then
						m = m-1
					elseif m > .25 then
						m = .5-m
					end
					tSprite.offset = cf * Vector3.new(m*s, 0, 0)
					if tLabel then
						tLabel.ImageColor3 = Color3.new(1, 1-s, 1-s)
					end
				end)
			end)
			for n = 1, 15 do
				spawn(function()
					local p = cParticle(650846795, 1, Color3.fromHSV((210+math.random()*20)/360, .8, .75))
					Tween(.7, nil, function(a)
						p.CFrame = CFrame.new(s + dp*a + Vector3.new(0, math.sin(a*math.pi)*.8, 0))
					end)
					p:Destroy()
				end)
				task.wait(.06)
			end
			task.wait(.64)
			return true
		end,
		shadowball = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			local sprite = pokemon.sprite
			local centroid = targetPoint(pokemon, 2.5)
			local cf = CFrame.new(centroid, centroid + workspace.CurrentCamera.CFrame.lookVector)
			local function makeParticle(hue)
				local p = create 'Part' {
					Transparency = 1.0,
					Anchored = true,
					CanCollide = false,
					Size = Vector3.new(.2, .2, .2),
					Parent = workspace,
				}
				local bbg = create 'BillboardGui' {
					Adornee = p,
					Size = UDim2.new(.7, 0, .7, 0),
					Parent = p,
					create 'ImageLabel' {
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://6294357140',
						ImageTransparency = .15,
						ImageColor3 = Color3.fromHSV(hue/360, .5, .5),
						Size = UDim2.new(1.0, 0, 1.0, 0),
						ZIndex = 2

					}
				}
				return p, bbg
			end
			local main, mbg = makeParticle(260)
			main.CFrame = cf
			local allParticles = {main}
			delay(.3, function()
				local rand = math.random
				for i = 2, 11 do
					local theta = rand()*6.28
					local offset = Vector3.new(math.cos(theta), math.sin(theta), .5)
					local p, b = makeParticle(rand(248, 310))
					allParticles[i] = p
					local r = math.random()*.35+.2
					spawn(function()
						local st = tick()
						local function o(r)
							local et = (tick()-st)*7
							p.CFrame = cf * CFrame.new(offset*r+.125*Vector3.new(math.cos(et), math.sin(et)*math.cos(et), 0))
						end
						Tween(.2, 'easeOutCubic', function(a)
							if not p.Parent then return false end
							b.Size = UDim2.new(.5*a, 0, .5*a, 0)
							o(r+.6)
						end)
						Tween(.25, 'easeOutCubic', function(a)
							if not p.Parent then return false end
							o(r+.6*(1-a))
						end)
						while p.Parent do
							o(r)
							stepped:wait()
						end
					end)
					task.wait(.1)
				end
			end)
			Tween(1.5, nil, function(a)
				mbg.Size = UDim2.new(2.5*a, 0, 2.5*a, 0)
			end)
			task.wait(.3)
			local targPos = targetPoint(target)
			local dp = targPos - centroid
			local v = 30
			local scf = cf
			Tween(dp.magnitude/v, nil, function(a)
				cf = scf + dp*a
				main.CFrame = cf
			end)
			for _, p in pairs(allParticles) do
				p:Destroy()
			end
			return true -- perform usual hit anim
		end,



		scratch = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, nil, 3)
			return 'sound'
		end,
		secretsword = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Brown')
			return 'sound'
		end,

		shadowforce = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			local spriteLabel = pokemon.sprite.animation.spriteLabel
			spawn(function()
				Tween(.075, nil, function(a)
					spriteLabel.ImageTransparency = 1-a
				end)
			end)
			tackle(pokemon, target)
			return true -- perform usual hit anim
		end,
		shadowspatter = function (pokemon, targets, move)
			local target = targets[1]
			if not target then
				return
			end
			local from = targetPoint(pokemon)
			local to = targetPoint(target)
			local cpos = CFrame.new(from, to)
			local dif = to - from
			local obj = Random.new()
			for i = 1, 9 do
				local pos = (CFrame.new(from, to) * CFrame.new(obj:NextInteger(-5, 5), obj:NextInteger(8, 18), obj:NextInteger(-3, -10)) + dif).p - from
				local gty = Vector3.new(0, -workspace.Gravity, 0)
				local mag1 = pos.Magnitude
				local mag2 = gty.Magnitude
				local av1 = (2 * mag1 / mag2) ^ 0.5
				local av2 = 2 * math.sqrt(2 * mag2 * mag1 / 2) / mag2
				local av0 = (mag2 * pos - mag1 * gty) / (2 * mag2 * mag1) ^ 0.5 / (av2 / av1)
				local ss = storage.Models.Misc.ShadowSpatter:Clone()
				ss.Color = Color3.fromRGB(90, 76, 66)
				local n = obj:NextNumber() * 2
				ss.Size = Vector3.new(2, 0.1, 2) + Vector3.new(n, 0, n)
				ss.Anchored = false
				ss.Material = "Neon"
				ss.Color = Color3.fromRGB(26, 25, 44)
				ss.Trail.Color = ColorSequence.new(Color3.fromRGB(40, 28, 57))
				ss.Velocity = av0
				ss.CFrame = CFrame.new(Vector3.new(), av0.unit) + from
				ss.Parent = move.scene
				game.Debris:AddItem(ss, av2)
				delay(av1, function()
					local attach = Instance.new("Attachment", workspace.Terrain)
					attach.WorldCFrame = CFrame.new(to)
					local Particles = storage.Models.Misc.Particles
					local mudspat = Particles.ShadowSpatter:Clone()
					mudspat.Parent = attach
					mudspat.LightEmission = 0.2;
					mudspat.Texture = "http://www.roblox.com/asset/?id=6204022252"
					mudspat.Color = ColorSequence.new(Color3.fromRGB(42, 26, 65))
					mudspat:Emit(10)
					game.Debris:AddItem(attach, 1)
				end)
				task.wait()
			end
			task.wait((2 * dif.Magnitude / Vector3.new(0, -workspace.Gravity, 0).Magnitude) ^ 0.5)
			return true
		end,

		sludgebomb = function(poke, targets)
			local target = targets[1]
			if not target then
				return true
			end 
			local targ = targetPoint(poke)
			local targ2 = targetPoint(target)
			local cf = target.sprite.part.CFrame
			local CurrentCamera = workspace.CurrentCamera
			local part = create("Part")({
				BrickColor = BrickColor.new("Bright violet"), 
				Transparency = 0.1, 
				Reflectance = 0.1, 
				Anchored = true, 
				CanCollide = false, 
				TopSurface = Enum.SurfaceType.Smooth, 
				BottomSurface = Enum.SurfaceType.Smooth, 
				Shape = Enum.PartType.Ball, 
				Parent = workspace
			});
			Tween(0.3, nil, function(a)
				part.Size = Vector3.new(a, a, a) * 2
				part.CFrame = CFrame.new(targ)
			end);
			local cf2 = cf - cf.p
			delay(0.5, function()
				for i = 1, 5 do
					local color = Color3.fromHSV((281 + math.random() * 20) / 360, 0.6, 0.4)
					local num = math.random() * 0.5 + 0.75
					spawn(function()
						for i = 1, 2 do
							local num2 = math.random() * 360
							_p.Particles:new({
								Color = color, 
								Image = 243953162, 
								Lifetime = 0.4, 
								Size = 0.8 * num, 
								Position = targ2, 
								Velocity = 5 * (cf2 * Vector3.new(math.cos(math.rad(num2)), math.sin(math.rad(num2)), 0)), 
								Acceleration = false
							})
						end
					end)
					task.wait(0.06)
				end
			end)
			local pos = targ2 - targ
			Tween(0.7, nil, function(a)
				part.CFrame = CFrame.new(targ + pos * a + Vector3.new(0, 1.7 * math.sin(a * math.pi), 0))
			end)
			part:Destroy()
			return true
		end,

		synthesis = function(p299, p300, p301) -- photosynthesis
			local v573 = p299.sprite or p299;
			local v574 = v573.part.CFrame * Vector3.new(0, v573.part.Size.Y * 0.15, v573.part.Size.Z * -0.5 - 0);
			local cf91 = CFrame.new(p299.sprite.cf.p);
			local Attachment93 = Instance.new("Attachment", workspace.Terrain);
			Attachment93.WorldCFrame = cf91;
			local Clone_ret248 = Misc.sun:Clone();
			Clone_ret248.Transparency = 1;
			Clone_ret248.CFrame = CFrame.new(v574 + Vector3.new(0, 8, 0)) * CFrame.Angles(-math.pi / 2, 0, 0);
			local Beam = Clone_ret248.Beam;
			Clone_ret248.Parent = p301.scene;
			Beam.Attachment1 = Attachment93;
			Beam.Enabled = true;
			u13.Tween(TweenInfo.new(0.5), true, function(p543)
				Clone_ret248.Transparency = 1 - p543 * 0.8;
				Beam.Transparency = NumberSequence.new(1 - p543);
			end);
			local Clone_ret249 = Particles.Heal:Clone();
			Clone_ret249.Parent = p299.sprite.part;
			for index54 = 1, 20 do
				Clone_ret249:Emit(1);
				task.wait();
			end
			task.wait(Clone_ret249.Lifetime.Min);
			u13.Tween(TweenInfo.new(0.5), true, function(p544)
				Clone_ret248.Transparency = p544 * 0.8 + 0.2;
				Beam.Transparency = NumberSequence.new(p544);
			end);
		end,

		mudbomb = function(poke, targets)
			local target = targets[1]
			if not target then
				return true
			end 
			local targ = targetPoint(poke)
			local targ2 = targetPoint(target)
			local cf = target.sprite.part.CFrame
			local CurrentCamera = workspace.CurrentCamera
			local part = create("Part")({
				BrickColor = BrickColor.new("Brown"), 
				Transparency = 0.1, 
				Reflectance = 0.1, 
				Anchored = true, 
				CanCollide = false, 
				TopSurface = Enum.SurfaceType.Smooth, 
				BottomSurface = Enum.SurfaceType.Smooth, 
				Shape = Enum.PartType.Ball, 
				Parent = workspace
			});
			Tween(0.3, nil, function(a)
				part.Size = Vector3.new(a, a, a) * 2
				part.CFrame = CFrame.new(targ)
			end);
			local cf2 = cf - cf.p
			delay(0.5, function()
				for i = 1, 5 do
					local color = Color3.fromHSV((281 + math.random() * 20) / 360, 0.6, 0.4)
					local num = math.random() * 0.5 + 0.75
					spawn(function()
						for i = 1, 2 do
							local num2 = math.random() * 360
							_p.Particles:new({
								Color = Color3.new(0.5, 0.3, 0),  
								Image = 243953162, 
								Lifetime = 0.4, 
								Size = 0.8 * num, 
								Position = targ2, 
								Velocity = 5 * (cf2 * Vector3.new(math.cos(math.rad(num2)), math.sin(math.rad(num2)), 0)), 
								Acceleration = false
							})
						end
					end)
					task.wait(0.06)
				end
			end)
			local pos = targ2 - targ
			Tween(0.7, nil, function(a)
				part.CFrame = CFrame.new(targ + pos * a + Vector3.new(0, 1.7 * math.sin(a * math.pi), 0))
			end)
			part:Destroy()
			return true
		end,

		headbutt = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			tackle(pokemon, target)
			return true -- perform usual hit anim
		end,

		slam = function(poke, targets)
			local target = targets[1]; if not target then return end
			tackle(poke, target)
			return true -- perform usual hit anim
		end,

		hypnosis = function(poke, targets)
			local target = targets[1]; if not target then return end
			local targ = targetPoint(poke)
			local targ2 = targetPoint(target)
			local pos = targ2 - targ
			for i = 1, 3 do
				spawn(function()
					local part = create("Part")({
						BrickColor = BrickColor.new("Pink"), 
						Reflectance = 0.5, 
						Anchored = true, 
						CanCollide = false, 
						Size = Vector3.new(1, 1, 1), 
						Parent = workspace
					})
					local mesh = create("SpecialMesh")({
						MeshType = Enum.MeshType.FileMesh, 
						MeshId = "rbxassetid://3270017", 
						Parent = part
					})
					Tween(0.8, nil, function(a)
						part.CFrame = CFrame.new(targ, targ2) + pos * a
						local v482 = 1.3 + 0.3 * math.sin(a * 8)
						mesh.Scale = Vector3.new(v482, v482, v482)
					end)
					part:Destroy()
				end)
				task.wait(0.2)
			end
			task.wait(0.6)
			return true
		end,
		psybeam = function(poke, targets)
			local target = targets[1]
			if not target then return end

			local targ = targetPoint(poke)
			local targ2 = targetPoint(target)
			local pos = targ2 - targ

			for i = 1, 10 do
				spawn(function()
					local part = create("Part")({
						BrickColor = BrickColor.new("Pink"), 
						Transparency = 0,
						Reflectance = 0.5, 
						Anchored = true, 
						CanCollide = false, 
						Size = Vector3.new(1, 1, 1), 
						Parent = workspace
					})

					local mesh = create("SpecialMesh")({
						MeshType = Enum.MeshType.FileMesh, 
						MeshId = "rbxassetid://3270017", 
						Parent = part
					})

					local beamLength = pos.magnitude * 1.5
					local beamSpeed = 40
					local beamDuration = beamLength / beamSpeed

					Tween(beamDuration, nil, function(a)
						part.CFrame = CFrame.new(targ, targ2) + pos * a
						if a >= 1 then
							part.Transparency = 1  -- Fades out after reaching the target
						end
					end)

					task.wait(beamDuration)
					part:Destroy()
				end)
				task.wait(0.02)
			end

			task.wait(0.1)
			return true
		end,
		psychic = function(p272, p273, p274) -- flabbergast
			local v516 = p273[1];
			if not v516 then return end
			local v517 = p272.sprite or p272;
			local v518 = v517.part.CFrame * Vector3.new(0, v517.part.Size.Y * 0.15, v517.part.Size.Z * -0.5 - 0);
			local v519 = v516.sprite or v516;
			local v520 = v519.part.CFrame * Vector3.new(0, v519.part.Size.Y * 0.15, v519.part.Size.Z * -0.5 - 0);
			local _ = v520 - v518;
			local cf88 = CFrame.new(p273[1].sprite.cf.p);
			local v521 = cf88 + Vector3.new(0, (v518.Y - cf88.y) / 2, 0);
			local Attachment82 = Instance.new("Attachment", workspace.Terrain);
			Attachment82.WorldCFrame = CFrame.new(v520);
			local Clone_ret212 = Particles.HitParticleRed:Clone();
			Clone_ret212.Lifetime = NumberRange.new(1);
			Clone_ret212.Color = ColorSequence.new(Color3.fromRGB(255, 170, 255));
			Clone_ret212.Rate = 20;
			Clone_ret212.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.2, 0.5),
				NumberSequenceKeypoint.new(1, 0.5)
			});
			Clone_ret212.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 9),
				NumberSequenceKeypoint.new(1, 0)
			});
			Clone_ret212.Parent = Attachment82;
			Clone_ret212.Enabled = true;
			task.wait();
			local u257 = 0.025;
			task.wait(0.5);
			Clone_ret212.Enabled = false;
			u13.Tween(TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), true, function(p531)
				local v880 = 20 - p531 * 19;
				u257 = p531 * 0.075 + 0.025;
			end);
			local Part11 = Instance.new("Part");
			Part11.Color = Color3.fromRGB(212, 144, 189);
			Part11.Size = Vector3.new(4, 4, 4);
			Part11.Anchored = true;
			Part11.Material = "Neon";
			Part11.Shape = "Ball";
			Part11.CanCollide = false;
			Part11.Transparency = 0;
			Part11.CFrame = CFrame.new(v520);
			Part11.Parent = p274.scene;
			local Clone_ret213 = Clone_ret212:Clone();
			Clone_ret213.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 28)
			});
			Clone_ret213.Lifetime = NumberRange.new(0.75);
			Clone_ret213.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.2, 0.5),
				NumberSequenceKeypoint.new(1, 1)
			});
			Clone_ret213.Parent = Attachment82;
			Clone_ret213:Emit(1);
			spawn(function()
				u13.Tween(TweenInfo.new(0.75, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), true, function(p659)
					local v971 = p659 * 20 + 4;
					Part11.Size = Vector3.new(v971, v971, v971);
					Part11.Transparency = p659;
				end);
				Attachment82:Destroy();
				Part11:Destroy();
			end);
			return true;
		end,
		skydrop = function(pokemon, targets, _, _, tMeta)
			local target = targets[1]; if not target then return end
			local sprite = pokemon.sprite
			local tp = target.sprite.offset
			Tween(.5, 'easeOutQuart', function(a)
				target.sprite.offset = tp*(1-a)
			end)
			if tMeta then
				Utilities.sound(tMeta.soundId[target] or 201476240, .75, tMeta.effectiveness[target] == 1 and .5 or .6, 5)
				--			spawn(function()
				--				local sl = target.sprite.animation.spriteLabel
				--				for i = 1, 3 do
				--					task.wait(.03)
				--					sl.Visible = false
				--					task.wait(.03)
				--					sl.Visible = true
				--				end
				--			end)
			end
			spawn(function()
				Tween(1, 'easeOutCubic', function(a)
					sprite.offset = Vector3.new(0, 10*(1-a), 0)
				end)
			end)
		end,
		slash = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, nil, 3)
			return 'sound'
		end,
		solarbeam = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			local from = targetPoint(pokemon, 2)
			local to = targetPoint(target)
			local dif = to-from

			local sun = create 'Part' {
				BrickColor = BrickColor.new('New Yeller'),
				Material = Enum.Material.Neon,
				Anchored = true,
				CanCollide = false,
				TopSurface = Enum.SurfaceType.Smooth,
				BottomSurface = Enum.SurfaceType.Smooth,
				Size = Vector3.new(4, 4, 4),
				Shape = Enum.PartType.Ball,
				CFrame = CFrame.new(pokemon.sprite.cf.p+Vector3.new(0, 7-(pokemon.sprite.spriteData.inAir or 0), 0)),
				Parent = workspace
			}
			Tween(1, nil, function(a)
				sun.Transparency = 1-a
			end)
			local blast = sun:Clone()
			blast.BrickColor = BrickColor.new('Bright green')
			blast.Size = Vector3.new(1, 1, 1)
			blast.CFrame = CFrame.new(from)
			blast.Parent = workspace
			local bmesh = create 'SpecialMesh' {
				MeshType = Enum.MeshType.Sphere,
				Parent = blast
			}
			local twoPi = math.pi*2
			local r = 4
			for i = 1, 20 do
				delay(.075*i, function()
					local beam = create 'Part' {
						Material = Enum.Material.Neon,
						BrickColor = BrickColor.new('Br. yellowish green'),
						Anchored = true,
						CanCollide = false,
						TopSurface = Enum.SurfaceType.Smooth,
						BottomSurface = Enum.SurfaceType.Smooth,
						Parent = workspace,
					}
					local transform = CFrame.Angles(twoPi*math.random(),twoPi*math.random(),twoPi*math.random()).lookVector * r
					local cf = CFrame.new(from)*transform
					Tween(.25, nil, function(a)
						beam.Size = Vector3.new(.2, .2, r*a)
						beam.CFrame = CFrame.new(cf + (from-cf)/2*a, cf)
					end)
					Tween(.25, nil, function(a)
						beam.Size = Vector3.new(.2, .2, r*(1-a))
						beam.CFrame = CFrame.new(cf + (from-cf)*(.5+.5*a), cf)
					end)
					beam:Destroy()
				end)
			end
			Tween(2, nil, function(a)
				bmesh.Scale = Vector3.new(2.3,2.3,2.3)*a
			end)
			task.wait(.2)
			local sbeam = blast:Clone()
			sbeam.Shape = Enum.PartType.Block--Cylinder
			sbeam.Parent = workspace
			local smesh = Instance.new('CylinderMesh', sbeam)
			local len = dif.magnitude
			Tween(.3, nil, function(a)
				sbeam.Size = Vector3.new(.8, len*a, .8)
				sbeam.CFrame = CFrame.new(from+dif*.5*a, to) * CFrame.Angles(math.pi/2, 0, 0)
				local s = (2.3-1.5*a)
				bmesh.Scale = Vector3.new(s,s,s)
				--			blast.CFrame = CFrame.new(from)
			end)
			spawn(function()
				--			local ss, sc = sbeam.Size, sbeam.CFrame
				local bs, bc = blast.Size, blast.CFrame
				Tween(.4, 'easeOutQuad', function(a)
					local o = 1-a
					smesh.Scale = Vector3.new(o,1,o)
					--sbeam.Size = ss*Vector3.new(1,o,o)
					--sbeam.CFrame = sc
					bmesh.Scale = Vector3.new(o,o,o)
					--				blast.Size = bs*o
					--				blast.CFrame = bc
				end)
				sbeam:Destroy()
				blast:Destroy()
				task.wait(.2)
				Tween(1, nil, function(a)
					sun.Transparency = a
				end)
				sun:Destroy()
			end)
			return true
		end,
		spikes = function(pokemon, swap)
			spikes(pokemon, nil, nil, swap)
		end,
		surf = function (pokemon, targets, move)
			local target = targets[1];
			if not target then
				return
			end
			local from = targetPoint(pokemon)
			local to = targetPoint(target)
			local pos = CFrame.new(from, to)
			local dif = to - from
			local c1 = pos * CFrame.new(0, -13, 20)
			local c2 = pos + dif + dif.unit * 20
			local wave = storage.Models.Misc.WaveMesh:Clone()
			wave.Size = Vector3.new(12, 12, 20)
			wave.CFrame = c1 * CFrame.Angles(0, -math.pi / 2, 0)
			wave.Parent = move.scene
			local part = Instance.new("Part")
			part.Anchored = true
			part.Transparency = 1
			part.CanCollide = false
			part.CFrame = c1
			part.Size = Vector3.new(20, 2, 6)
			local Particles = storage.Models.Misc.Particles
			local splash = Particles.Splash:Clone()
			splash.Rate = 100
			splash.Speed = NumberRange.new(1, 4)
			splash.Acceleration = Vector3.new(0, -5, 0)
			splash.Parent = part
			part.Parent = move.scene
			local fun = 0
			local mag = dif.magnitude + 40
			spawn(function()
				local t = tick()
				local RunService = game:GetService('RunService')
				while tick() - t < 2.5 do
					local v = (tick() - t) / 2.5
					fun = math.sin(v * math.pi) * 13
					wave.CFrame = (c1 + dif.unit * mag * v + Vector3.new(0, fun, 0)) * CFrame.Angles(0, -math.pi / 2, 0)
					part.CFrame = (wave.CFrame + Vector3.new(0, -wave.Size.Y / 2 + part.Size.Y, 0)) * CFrame.Angles(0, math.pi / 2, 0) * CFrame.new(0, 0, -part.Size.Z / 2)
					RunService.Stepped:wait()		
				end
				splash.Enabled = false
				delay(splash.Lifetime.Max, function()
					part:Destroy()
				end)
				wave:Destroy()
			end)
			task.wait(1.25)
			return true
		end, 
		sludgewave = function(pokemon, targets, move)
			local target = targets[1];
			if not target then
				return
			end

			local from = targetPoint(pokemon)
			local to = targetPoint(target)
			local pos = CFrame.new(from, to)
			local dif = to - from
			local c1 = pos * CFrame.new(0, -13, 20)
			local c2 = pos + dif + dif.unit * 20

			-- Create purple WaveMesh
			local wave = storage.Models.Misc.WaveMesh:Clone()
			wave.Size = Vector3.new(12, 12, 20)
			wave.Color = Color3.fromRGB(128, 0, 128) -- Purple color
			wave.CFrame = c1 * CFrame.Angles(0, -math.pi / 2, 0)
			wave.Parent = move.scene

			local part = Instance.new("Part")
			part.Anchored = true
			part.Transparency = 1
			part.CanCollide = false
			part.CFrame = c1
			part.Size = Vector3.new(20, 2, 6)

			local Particles = storage.Models.Misc.Particles

			-- Create purple splash particle template
			local splash = Particles.Splash:Clone()
			splash.Color = ColorSequence.new(Color3.fromRGB(128, 0, 128)) -- Purple color
			splash.Rate = 100
			splash.Speed = NumberRange.new(1, 4)
			splash.Acceleration = Vector3.new(0, -5, 0)
			splash.Parent = part
			part.Parent = move.scene

			local fun = 0
			local mag = dif.magnitude + 40
			spawn(function()
				local t = tick()
				local RunService = game:GetService('RunService')
				while tick() - t < 2.5 do
					local v = (tick() - t) / 2.5
					fun = math.sin(v * math.pi) * 13
					wave.CFrame = (c1 + dif.unit * mag * v + Vector3.new(0, fun, 0)) * CFrame.Angles(0, -math.pi / 2, 0)
					part.CFrame = (wave.CFrame + Vector3.new(0, -wave.Size.Y / 2 + part.Size.Y, 0)) * CFrame.Angles(0, math.pi / 2, 0) * CFrame.new(0, 0, -part.Size.Z / 2)
					RunService.Stepped:wait()
				end
				splash.Enabled = false
				delay(splash.Lifetime.Max, function()
					part:Destroy()
				end)
				wave:Destroy()
			end)

			task.wait(1.25)
			return true
		end,
		muddywater = function (pokemon, targets, move)
			local target = targets[1];
			if not target then
				return
			end

			local from = targetPoint(pokemon)
			local to = targetPoint(target)
			local pos = CFrame.new(from, to)
			local dif = to - from
			local c1 = pos * CFrame.new(0, -13, 20)
			local c2 = pos + dif + dif.unit * 20

			-- Create brown WaveMesh
			local wave = storage.Models.Misc.WaveMesh:Clone()
			wave.Size = Vector3.new(12, 12, 20)
			wave.Color = Color3.fromRGB(128, 64, 0) -- Brown color
			wave.CFrame = c1 * CFrame.Angles(0, -math.pi / 2, 0)
			wave.Parent = move.scene

			local part = Instance.new("Part")
			part.Anchored = true
			part.Transparency = 1
			part.CanCollide = false
			part.CFrame = c1
			part.Size = Vector3.new(20, 2, 6)

			local Particles = storage.Models.Misc.Particles

			-- Create brown splash particle template
			local splash = Particles.Splash:Clone()
			splash.Color = ColorSequence.new(Color3.fromRGB(128, 64, 0)) -- Brown color
			splash.Rate = 100
			splash.Speed = NumberRange.new(1, 4)
			splash.Acceleration = Vector3.new(0, -5, 0)
			splash.Parent = part
			part.Parent = move.scene

			local fun = 0
			local mag = dif.magnitude + 40
			spawn(function()
				local t = tick()
				local RunService = game:GetService('RunService')
				while tick() - t < 2.5 do
					local v = (tick() - t) / 2.5
					fun = math.sin(v * math.pi) * 13
					wave.CFrame = (c1 + dif.unit * mag * v + Vector3.new(0, fun, 0)) * CFrame.Angles(0, -math.pi / 2, 0)
					part.CFrame = (wave.CFrame + Vector3.new(0, -wave.Size.Y / 2 + part.Size.Y, 0)) * CFrame.Angles(0, math.pi / 2, 0) * CFrame.new(0, 0, -part.Size.Z / 2)
					RunService.Stepped:wait()
				end
				splash.Enabled = false
				delay(splash.Lifetime.Max, function()
					part:Destroy()
				end)
				wave:Destroy()
			end)

			task.wait(1.25)
			return true
		end,
		tackle = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			tackle(pokemon, target)
			return true -- perform usual hit anim
		end,
		teleport = function(pokemon)
			pcall(function()
				local part = pokemon.sprite.part
				local cf = part.CFrame
				local x = part.Size.X
				local y = part.Size.Y
				Tween(.3, nil, function(a)
					part.Size = Vector3.new(x*math.cos(a*math.pi/2), y*(1+math.sin(a*math.pi/2)*1.5), .2)
					part.CFrame = cf
				end)
				--part:Destroy()
			end)
		end,
		thunderbolt = function(p186, p187, p188) -- electroburst
			local v352 = p187[1];
			if not v352 then return end
			local v353 = p186.sprite or p186;
			local u178 = v353.part.CFrame * Vector3.new(0, v353.part.Size.Y * 0.15, v353.part.Size.Z * -0.5 - 0);
			local v354 = v352.sprite or v352;
			local v355 = v354.part.CFrame * Vector3.new(0, v354.part.Size.Y * 0.15, v354.part.Size.Z * -0.5 - 0);
			local v356 = nil;
			for index34 = 0, math.pi * 11 / 6, math.pi * 2 / 3 do
				local u369 = CFrame.new(u178, v355) * CFrame.Angles(0, 0, index34 + math.pi) * CFrame.new(0, -30, 0);
				local magnitude14 = (v355 - u369.p).magnitude;
				local magnitude15 = (v355 - u178).magnitude;
				local u370 = magnitude14 / 50;
				v356 = u370;
				local u371 = 85.09035245341184 / u370;
				local u372 = Utilities.Create("Part")({
					Anchored = true,
					CanCollide = false,
					Shape = "Ball",
					Material = "Neon",
					Color = Color3.fromRGB(253, 234, 141),
					CFrame = u369,
					Size = Vector3.new(5, 5, 5)
				});
				local Clone_ret147 = Particles.Sparks:Clone();
				Clone_ret147.Enabled = true;
				Clone_ret147.Parent = u372;
				u372.Parent = p188.scene;
				local u373 = 4;
				local Color3_fromRGB_ret6 = Color3.fromRGB(245, 238, 159);
				local coroutine_wrap_ret16 = coroutine.wrap(function()
					u13.Tween(TweenInfo.new(u370, Enum.EasingStyle.Linear), true, function(p719, p720)
						u372.CFrame = u369 * CFrame.new(0, -(p720 * 42.54517622670592 - u371 * 0.5 * p720 ^ 2 + -30), -(p719 * magnitude15));
						u372.Size = Vector3.new(5 - p719 * 3, 5 - p719 * 3, 5 - p719 * 3);
						local _ = u372.Position + Vector3.new(Random_new_ret:NextInteger(-4, 4), Random_new_ret:NextInteger(-4, 4), Random_new_ret:NextInteger(-4, 4));
						if u373 % 4 == 0 then
							local v1002 = u178;
							local Position5 = u372.Position;
							u13.BranchLightning(v1002, Position5, 5, 1, 0.25, Color3_fromRGB_ret6, 0.1, 3);
						end
						u373 = u373 + 1;
					end);
					u372:Destroy();
				end);
				coroutine_wrap_ret16();
			end
			task.wait(v356);
			local u179 = Utilities.Create("Part")({
				Anchored = true,
				CanCollide = false,
				Shape = "Ball",
				Material = "Neon",
				Color = Color3.fromRGB(253, 234, 141),
				CFrame = CFrame.new(v355),
				Size = Vector3.new(3, 3, 3)
			});
			local Clone_ret145 = Particles.Sparks:Clone();
			Clone_ret145.Enabled = true;
			Clone_ret145.Parent = u179;
			u179.Parent = p188.scene;
			local Size24 = u179.Size;
			local Clone_ret146 = Misc.ThinRing:Clone();
			Clone_ret146.Color = Color3.fromRGB(255, 255, 255);
			Clone_ret146.Size = Vector3.new(6, 0.1, 6);
			Clone_ret146.CFrame = CFrame.new(v355);
			Clone_ret146.Parent = p188.scene;
			u9("Bump",1);
			spawn(function()
				u13.Tween(TweenInfo.new(1.25, Enum.EasingStyle.Exponential), true, function(p647)
					local v967 = p647 * 15;
					u179.Size = Size24 + Vector3.new(v967, v967, v967);
					Clone_ret146.Size = Vector3.new(p647 * 24 + 6, 0.1, p647 * 24 + 6);
					u179.Transparency = p647;
					Clone_ret146.Transparency = p647;
				end);
				task.wait();
				u179:Destroy();
				Clone_ret146:Destroy();
			end);
			return true;
		end,
		thundershock = function(p200, p201, p202) -- staticshock
			local v379 = p201[1];
			if not v379 then return end
			local v380 = p200.sprite or p200;
			local u195 = v380.part.CFrame * Vector3.new(0, v380.part.Size.Y * 0.15, v380.part.Size.Z * -0.5 - 0);
			local v381 = v379.sprite or v379;
			local v382 = v381.part.CFrame * Vector3.new(0, v381.part.Size.Y * 0.15, v381.part.Size.Z * -0.5 - 0);
			local _ = CFrame.new(u195, v382);
			local _ = (v382 - u195).magnitude;
			local u196 = CFrame.new(u195, v382) * CFrame.new(0, 0, -2);
			local u197 = v382 - u196.p;
			local u198 = Utilities.Create("Part")({
				Color = Color3.fromRGB(253, 234, 141),
				Anchored = true,
				CanCollide = false,
				CFrame = u196,
				Shape = "Ball",
				Size = Vector3.new(1, 1, 1)
			});
			u198.CFrame = u196;
			u198.Material = "Neon";
			u198.Parent = p202.scene;
			local Size25 = u198.Size;
			u13.Tween(TweenInfo.new(0.1), true, function(p499)
				u198.Size = Size25 + Size25 * 0.5 * p499;
			end);
			local bool10 = true;
			spawn(function()
				while bool10 == true do
					local Position8 = u198.Position;
					local v940 = u195;
					local Color3_fromRGB_ret11 = Color3.fromRGB(245, 238, 159);
					u13.BranchLightning(Position8, v940, 3, 0, 0.2, Color3_fromRGB_ret11, 0.25);
					task.wait(0.05);
				end
			end);
			u13.Tween(TweenInfo.new(0.25), true, function(p500)
				u198.CFrame = u196 + u197 * p500;
			end);
			bool10 = false;
			Size25 = u198.Size;
			local v383 = CFrame.new(u195, v382) + u197;
			for index37 = math.pi / 4, math.pi * 2, math.pi / 2 do
				local v783 = v383 * CFrame.new(math.cos(index37) * 10, math.sin(index37) * 10, 0);
				local p11 = v383.p;
				local p12 = v783.p;
				local Color3_fromRGB_ret12 = Color3.fromRGB(245, 238, 159);
				u13.BranchLightning(p11, p12, 3, 3, 0.2, Color3_fromRGB_ret12, 1);
			end
			local Attachment59 = Instance.new("Attachment", workspace.Terrain);
			Attachment59.WorldCFrame = CFrame.new(v382);
			local Clone_ret158 = Particles.SparkV2:Clone();
			Clone_ret158.Enabled = false;
			Clone_ret158.Acceleration = Vector3.new(0, -75, 0);
			Clone_ret158.Speed = NumberRange.new(20, 35);
			Clone_ret158.Color = ColorSequence.new(Color3.fromRGB(248, 217, 109));
			Clone_ret158.Parent = Attachment59;
			Clone_ret158:Emit(30);
			delay(Clone_ret158.Lifetime.Max, function()
				Attachment59:Destroy();
			end);
			u13.Tween(TweenInfo.new(0.5, Enum.EasingStyle.Cubic), false, function(p501)
				u198.Size = Size25 + Size25 * 2 * p501;
				u198.Transparency = p501;
			end);
			game.Debris:AddItem(u198, 0.5);
			return true;
		end,
		thunderfang = function(p189, p190, p191) -- thunderchomp
			local v357 = p190[1];
			if not v357 then return end
			local v358 = p189.sprite or p189;
			local v359 = v358.part.CFrame * Vector3.new(0, v358.part.Size.Y * 0.15, v358.part.Size.Z * -0.5 - 0);
			local v360 = v357.sprite or v357;
			local v361 = v360.part.CFrame * Vector3.new(0, v360.part.Size.Y * 0.15, v360.part.Size.Z * -0.5 - 0);
			local cf56 = CFrame.new(v359, v361);
			local Clone_ret148 = storage.Models.Misc.Bite:Clone();
			local Top5 = Clone_ret148.Top;
			local Bottom5 = Clone_ret148.Bottom;
			local Color3_fromRGB_ret7 = Color3.fromRGB(255, 250, 89);
			local Color3_fromRGB_ret8 = Color3.fromRGB(248, 255, 165);
			Top5.Color = Color3_fromRGB_ret7;
			Bottom5.Color = Color3_fromRGB_ret7;
			Top5.Transparency = 1;
			Bottom5.Transparency = 1;
			Top5.Material = "Neon";
			Bottom5.Material = "Neon";
			Clone_ret148.PrimaryPart = Clone_ret148.Main;
			Clone_ret148:PivotTo(cf56);
			local u180 = v361 - v359;
			Utilities.ScaleModel(Clone_ret148.Main, 3);
			Clone_ret148.Parent = p191.scene;
			local inverse_ret5 = Clone_ret148.Main.CFrame:inverse();
			local u181 = inverse_ret5 * Top5.CFrame;
			local u182 = inverse_ret5 * Bottom5.CFrame;
			local _ = Top5.Size.X;
			Clone_ret148:PivotTo(cf56);
			local CFrame43 = Clone_ret148.PrimaryPart.CFrame;
			u13.Tween(TweenInfo.new(0.55), true, function(p492)
				local v861 = 1 - p492;
				local cf57 = CFrame.new(0, 0, v861 * -1);
				local v862 = 0.4 - v861 * 0.4;
				Top5.CFrame = Clone_ret148.PrimaryPart.CFrame * cf57 * CFrame.Angles(v862, 0, 0) * u181;
				Bottom5.CFrame = Clone_ret148.PrimaryPart.CFrame * cf57 * CFrame.Angles(-v862, 0, 0) * u182;
				Top5.Transparency = 1 - p492;
				Bottom5.Transparency = 1 - p492;
			end);
			local table46 = {
				Color = ColorSequence.new(Color3_fromRGB_ret7, Color3_fromRGB_ret8),
				Transparency = NumberSequence.new(0, 1),
				WidthScale = NumberSequence.new(0, 1),
				LightEmission = 1,
				Lifetime = 0.3
			};
			for index35 = 1, 9 do
				local u374 = cf56 * CFrame.new(math.cos(math.pi * 2 * index35 / 5) * 4, math.sin(math.pi * 2 * index35 / 5) * 4, 0);
				spawn(function()
					u13.makeSpiral(1, u374 * CFrame.Angles(-math.pi / 2, 0, 0), 0, u180.magnitude + 3, 0, 0.5, TweenInfo.new(0.25, Enum.EasingStyle.Linear), nil, table46);
				end);
			end
			spawn(function()
				for index98 = 1, 5 do
					local Clone_ret149 = Misc.ThinRing:Clone();
					Clone_ret149.Color = Color3_fromRGB_ret8:Lerp(Color3_fromRGB_ret7, index98 / 5);
					Clone_ret149.Material = "Neon";
					Clone_ret149.Size = Vector3.new(1, 0.1, 1);
					Clone_ret149.CFrame = cf56 * CFrame.new(0, 0, -u180.magnitude * index98 / 5) * CFrame.Angles(math.pi / 2, 0, 0);
					Clone_ret149.Parent = p191.scene;
					u13.Tween(TweenInfo.new(0.25), false, function(p698)
						Clone_ret149.Size = Vector3.new(p698 * 15 + 1, 0.1, p698 * 15 + 1);
						Clone_ret149.Transparency = p698;
					end);
					game.Debris:AddItem(Clone_ret149, 0.25);
					task.wait(0.05);
				end
			end);
			local u183 = 0;
			u13.Tween(TweenInfo.new(0.25), true, function(p493)
				local v863 = 1 - p493;
				local cf58 = CFrame.new(0, 0, v863 * -1);
				local v864 = v863 * 0.9;
				Clone_ret148:PivotTo(CFrame43 + (u180 - u180.unit * Top5.Size.X) * p493);
				Top5.CFrame = Clone_ret148.PrimaryPart.CFrame * cf58 * CFrame.Angles(v864, 0, 0) * u181;
				Bottom5.CFrame = Clone_ret148.PrimaryPart.CFrame * cf58 * CFrame.Angles(-v864, 0, 0) * u182;
				u183 = u183 + 1;
				if u183 % 2 == 0 then
					local Position6 = Clone_ret148.PrimaryPart.Position;
					u13.BranchLightning(Position6, ((cf56 + u180 * p493) * CFrame.Angles(0, 0, math.pi * 2 * Random_new_ret:NextNumber()) * CFrame.new(Random_new_ret:NextNumber(4, 12), Random_new_ret:NextNumber(-5, 5), Random_new_ret:NextNumber(10, 15))).p, 4, 2, 0.15, Color3_fromRGB_ret8, 0.25);
				end
			end);
			Top5.Transparency = 1;
			Bottom5.Transparency = 1;
			local Attachment56 = Instance.new("Attachment", workspace.Terrain);
			Attachment56.WorldCFrame = CFrame.new(v361);
			local Clone_ret150 = Particles.SparkV2:Clone();
			Clone_ret150.Enabled = false;
			Clone_ret150.Color = ColorSequence.new(Color3_fromRGB_ret7, Color3_fromRGB_ret8);
			Clone_ret150.SpreadAngle = Vector2.new(360, 360);
			Clone_ret150.Size = NumberSequence.new(0.1, 0);
			Clone_ret150.Transparency = NumberSequence.new(0, 1);
			Clone_ret150.Speed = NumberRange.new(10, 15);
			Clone_ret150.Acceleration = Vector3.new(0, -20, 0);
			Clone_ret150.Parent = Attachment56;
			Clone_ret150:Emit(50);
			game.Debris:AddItem(Attachment56, Clone_ret150.Lifetime.Max);
			Clone_ret148:Destroy();
			return true;
		end,
		bugbite = function(p307, p308, p309)
			local u170 = nil;
			local v778 = p308[1];
			if not v778 then
				return;
			end;
			local v779 = targetPoint(p307);
			local v780 = targetPoint(v778);
			local v781 = CFrame.new(v779, v780);
			local v782 = storage.Models.Misc.Bite:Clone();
			local Top_783 = v782.Top;
			local Bottom_784 = v782.Bottom;
			--	v782.anchored = true
			Top_783.Color = Color3.fromRGB(42, 175, 42);
			Bottom_784.Color = Color3.fromRGB(42, 175, 42);
			Top_783.Transparency = 1;
			Bottom_784.Transparency = 1;
			Top_783.Material = "Neon";
			Bottom_784.Material = "Neon";
			v782.PrimaryPart = v782.Main;
			v782:PivotTo(v781);
			local v785 = v780 - v779;
			v782.Parent = p309.scene;
			local v786 = v782.Main.CFrame:inverse();
			local X_787 = Top_783.Size.X;
			v782:PivotTo(v781);
			local v788 = TweenInfo.new(0.6);
			local u171 = v786 * Top_783.CFrame;
			local u172 = v786 * Bottom_784.CFrame;
			u13.Tween(v788, true, function(p310)
				local v789 = 1 - p310;
				local v790 = CFrame.new(0, 0, -1 * v789);
				local v791 = 0.4 - 0.4 * v789;
				Top_783.CFrame = v782.PrimaryPart.CFrame * v790 * CFrame.Angles(v791, 0, 0) * u171;
				Bottom_784.CFrame = v782.PrimaryPart.CFrame * v790 * CFrame.Angles(-v791, 0, 0) * u172;
				Top_783.Transparency = 1 - p310;
				Bottom_784.Transparency = 1 - p310;
			end);
			for v792 = 1, 5 do
				local v793 = Misc.HalfCircle:Clone();
				v793.Color = Color3.fromRGB(0, 0, 0);
				v793.Material = "SmoothPlastic";
				v793.Transparency = 0.5;
				v793.Parent = p309.scene;
				local v794 = TweenInfo.new(0.15);
				u170 = v785;
				local u173 = v781 * CFrame.new(X_787 * math.cos(2 * math.pi * v792 / 5), X_787 * math.sin(2 * math.pi * v792 / 5), 0);
				u13.Tween(v794, false, function(p311)
					v793.Size = Vector3.new(0.1, 0.1 + u170.magnitude * p311, 0.1);
					v793.CFrame = u173 * CFrame.new(0, 0, -u170.magnitude * p311 / 2) * CFrame.Angles(math.pi / 2, 0, 0);
				end);
				game.Debris:AddItem(v793, 0.15);
			end;
			local CFrame_174 = v782.PrimaryPart.CFrame;
			u13.Tween(TweenInfo.new(0.15), true, function(p313)
				local v797 = 1 - p313;
				local v798 = CFrame.new(0, 0, -1 * v797);
				local v799 = 0.9 * v797;
				v782:PivotTo(CFrame_174 + (u170 - u170.unit * Top_783.Size.X) * p313);
				Top_783.CFrame = v782.PrimaryPart.CFrame * v798 * CFrame.Angles(v799, 0, 0) * u171;
				Bottom_784.CFrame = v782.PrimaryPart.CFrame * v798 * CFrame.Angles(-v799, 0, 0) * u172;
			end);
			v782:Destroy();
			local v800 = v781 + u170;
			local v801 = Utilities.Create("Part")({
				Shape = "Ball", 
				Material = "Neon", 
				Size = Vector3.new(10, 10, 10), 
				Color = Color3.fromRGB(0, 185, 0), 
				Anchored = true, 
				CanCollide = false, 
				CFrame = v800
			});
			local v802 = Utilities.Create("Part")({
				Shape = "Cylinder", 
				Size = Vector3.new(1, 10, 10), 
				Material = "Neon", 
				Color = Color3.fromRGB(0, 175, 0), 
				Anchored = true, 
				CanCollide = false, 
				CFrame = CFrame.new(v800.p) * CFrame.Angles(0, math.pi / 2, math.pi / 2)
			});
			v802.Parent = p309.scene;
			v801.Parent = p309.scene;
			--	local v803 = CFrame.new(5, 1.9, 9);
			local u175 = 5 * math.pi;
			local v804 = Misc.ThinRing:Clone();
			v804.Color = Color3.fromRGB(0, 0, 0);
			v804.Size = Vector3.new(1, 0.1, 1);
			v804.CFrame = CFrame.new(v780);
			local u176 = {
				Color = ColorSequence.new(Color3.fromRGB(0, 0, 0)), 
				Transparency = NumberSequence.new(0, 1), 
				WidthScale = NumberSequence.new(0, 1), 
				LightEmission = 0, 
				Lifetime = 0.7
			};
			v804.Parent = p309.scene;
			local v805 = Color3.fromRGB(0, 0, 0);
			u13.Tween(TweenInfo.new(0.7), false, function(p314)
				local v806 = 10 + 10 * p314;
				v801.Size = Vector3.new(v806, v806, v806);
				v801.Transparency = p314;
				v802.Transparency = p314;
				v802.Size = Vector3.new(1 + 30 * p314, 10 - 10 * p314, 10 - 10 * p314);
				v804.Size = Vector3.new(50 * p314, 0.1, 50 * p314);
				v804.Transparency = p314;
			end).Completed:Connect(function()
				v801:Destroy();
				v802:Destroy();
				v804:Destroy();
			end);
			return true;
		end;
		overheat = function(p165, p166, p167) -- pyrokinesis
			local v308 = p166[1];
			if not v308 then return end
			local v309 = p165.sprite or p165;
			local _ = v309.part.CFrame * Vector3.new(0, v309.part.Size.Y * 0.15, v309.part.Size.Z * -0.5 - 0);
			local v310 = v308.sprite or v308;
			local u147 = v310.part.CFrame * Vector3.new(0, v310.part.Size.Y * 0.15, v310.part.Size.Z * -0.5 - 0);
			local Base10 = p165.sprite.part;

			local Ambient_37 = Lighting.Ambient
			local OutdoorAmbient_38 = Lighting.OutdoorAmbient
			local ColorShift_Bottom_39 = Lighting.ColorShift_Bottom
			local ColorShift_Top_40 = Lighting.ColorShift_Top
			local FogEnd_41 = Lighting.FogEnd
			local FogStart_42 = Lighting.FogStart
			lightShift(Color3.fromRGB(192, 0, 0), Color3.fromRGB(128, 0, 0), Color3.fromRGB(255, 50, 50), Color3.fromRGB(255, 50, 50), 0.9)	
			local Attachment46 = Instance.new("Attachment", workspace.Terrain);
			Attachment46.WorldCFrame = CFrame.new(u147);
			local Color3_fromRGB_ret4 = Color3.fromRGB(124, 49, 3);
			local Color3_fromRGB_ret5 = Color3.fromRGB(234, 45, 7);
			local u148 = Utilities.Create("ParticleEmitter")({
				Color = ColorSequence.new(Color3.fromRGB(124, 49, 3)),
				LightEmission = 1,
				LightInfluence = 0,
				Size = NumberSequence.new(2, 0),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.15, 0),
					NumberSequenceKeypoint.new(0.85, 0),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Lifetime = NumberRange.new(0.6, 0.8),
				Rate = 30,
				Rotation = NumberRange.new(0, 360),
				RotSpeed = NumberRange.new(135),
				Speed = NumberRange.new(0),
				Texture = "rbxassetid://6253558472"
			});
			local Clone_ret122 = Particles.Gravity:Clone();
			Clone_ret122.Rate = 25;
			Clone_ret122.Color = ColorSequence.new(Color3.fromRGB(255, 127, 42), Color3.fromRGB(255, 59, 10));
			Clone_ret122.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 4),
				NumberSequenceKeypoint.new(0.33, 3),
				NumberSequenceKeypoint.new(1, 0)
			});
			Clone_ret122.Parent = Attachment46;
			u148.Parent = Attachment46;
			u13.Tween(TweenInfo.new(1.5), true, function(p479)
				u148.Size = NumberSequence.new(p479 * 10 + 2, 0);
				local Lerp_ret16 = Color3_fromRGB_ret4:Lerp(Color3_fromRGB_ret5, p479);
				u148.Color = ColorSequence.new(Lerp_ret16);
				Clone_ret122.Lifetime = NumberRange.new(1 - p479 * 0.4);
				Clone_ret122.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, p479 * 8 + 4),
					NumberSequenceKeypoint.new(0.33, p479 * 8 + 3),
					NumberSequenceKeypoint.new(1, 0)
				});
			end);
			Clone_ret122.Enabled = false;
			u148.Enabled = false;
			u148.Lifetime = NumberRange.new(0.15);
			u148.Size = NumberSequence.new(30, 0);
			u148:Emit(2);
			task.wait(0.5);
			u9("Explosion",1);
			for index28 = 1, 20 do
				local v774 = (Base10.CFrame - Base10.CFrame.p + u147) * CFrame.Angles(Random_new_ret:NextNumber() * math.pi / 2, Random_new_ret:NextNumber(-math.pi / 2, math.pi / 2), 0);
				local v775 = Random_new_ret:NextNumber() + 1;
				local u366 = Utilities.Create("Part")({
					Anchored = false,
					CanCollide = false,
					Size = Vector3.new(v775, v775, v775),
					Material = "Neon",
					Shape = "Ball",
					Color = Color3.fromRGB(255, 140, 24),
					Velocity = v774.LookVector * Random_new_ret:NextNumber(65, 105)
				});
				u366.CFrame = v774;
				local Attachment47 = Instance.new("Attachment", u366);
				local Clone_ret124 = Particles.SparkV2:Clone();
				Clone_ret124.Size = NumberSequence.new(v775 + 0.5, 0);
				Clone_ret124.Acceleration = Vector3.new(0, 0, 0);
				Clone_ret124.Lifetime = NumberRange.new(0.5);
				Clone_ret124.Speed = NumberRange.new(0);
				Clone_ret124.Rotation = NumberRange.new(0);
				Clone_ret124.RotSpeed = NumberRange.new(0);
				Clone_ret124.Transparency = NumberSequence.new(0, 1);
				Clone_ret124.SpreadAngle = Vector2.new(0, 0);
				Clone_ret124.Parent = Attachment47;
				u366.Parent = p167.scene;
				delay(1.5, function()
					u366.Anchored = true;
					task.wait(1);
					u366:Destroy();
				end);
			end
			local Clone_ret123 = Particles.Fire3:Clone();
			Clone_ret123.Size = NumberSequence.new(20, 4);
			Clone_ret123.Parent = Attachment46;
			Clone_ret123:Emit(25);
			local coroutine_wrap_ret14 = coroutine.wrap(function()
				u13.ballExplosion(TweenInfo.new(2, Enum.EasingStyle.Cubic), CFrame.new(u147), 30, Color3_fromRGB_ret4, Color3_fromRGB_ret5, "Neon", "Neon");
			end);
			coroutine_wrap_ret14();		
			lightRestore(0.5)
			return true;
		end,
		leechlife = function(p120, p121, _) -- parasitize
			local v222 = p121[1];
			if not v222 then return end
			local v223 = p120.sprite or p120;
			local u101 = v223.part.CFrame * Vector3.new(0, v223.part.Size.Y * 0.15, v223.part.Size.Z * -0.5 - 0);
			local v224 = v222.sprite or v222;
			local u102 = v224.part.CFrame * Vector3.new(0, v224.part.Size.Y * 0.15, v224.part.Size.Z * -0.5 - 0);
			local cf30 = CFrame.new(u101, u102);
			local u103 = u102 - u101;
			local Part5 = Instance.new("Part");
			Part5.Material = "Neon";
			Part5.Anchored = true;
			Part5.CanCollide = false;
			Part5.Color = Color3.fromRGB(148, 190, 129);
			Part5.Shape = "Cylinder";
			Part5.Size = Vector3.new(0.2, 0.2, 0.2);
			Part5.CFrame = cf30 * CFrame.Angles(math.pi / 2, 0, math.pi / 2);
			Part5.Parent = workspace;
			local Size14 = Part5.Size;
			u13.Tween(TweenInfo.new(0.2, Enum.EasingStyle.Exponential), true, function(p447)
				local v841 = math.sin(p447 * math.pi) * 1;
				Part5.Size = Size14 + Vector3.new(u103.magnitude * p447, v841, v841);
				Part5.CFrame = (cf30 + u103 / 2 * p447) * CFrame.Angles(math.pi / 2, 0, math.pi / 2);
			end);
			local v225 = cf30 + u103;
			local table28 = {};
			for index18 = math.pi / 3, math.pi * 2, math.pi / 3 do
				local Part6 = Instance.new("Part");
				Part6.Size = Vector3.new(1, 1, 1);
				Part6.Transparency = 1;
				Part6.Material = "Neon";
				Part6.Shape = "Ball";
				Part6.Color = Color3.fromRGB(148, 190, 129);
				Part6.Anchored = true;
				Part6.CanCollide = false;
				local Clone_ret75 = Particles.Heal:Clone();
				Clone_ret75.Lifetime = NumberRange.new(0.7, 1.2);
				Clone_ret75.Rate = 5;
				Clone_ret75.Parent = Part6;
				Part6.CFrame = v225;
				local table29 = {
					part = Part6,
					gcf = v225 * CFrame.new(math.cos(index18) * 4, math.sin(index18) * 4, 0),
					cf = CFrame.new(Part6.Position, u101),
					radius = 4,
					ang = index18
				};
				Part6.Parent = workspace;
				table.insert(table28, table29);
			end
			for _, val8 in pairs(table28) do
				val8.part.Heal.Enabled = true;
			end
			u13.Tween(TweenInfo.new(0.6), true, function(p448)
				for _, val57 in pairs(table28) do
					val57.part.Transparency = 1 - p448;
					local v929 = p448 * 0.8 + 0.2;
					val57.part.Size = Vector3.new(v929, v929, v929);
					val57.part.CFrame = val57.cf:Lerp(val57.gcf, p448);
				end
			end);
			Size14 = Part5.Size;
			for _, val9 in pairs(table28) do
				u13.Tween(TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.In), false, function(p607)
					local v930 = val9.radius - val9.radius * p607 * 0.9;
					val9.part.CFrame = CFrame.new(u102, u101) * CFrame.new(v930 * math.cos(val9.ang + math.pi * 4 * p607), v930 * math.sin(val9.ang + math.pi * 4 * p607), -u103.magnitude * p607);
					val9.part.Transparency = p607;
				end);
				task.wait(0.1);
			end
			task.wait(0.8);
			for _, val10 in pairs(table28) do
				val10.part.Heal.Enabled = false;
			end
			u13.Tween(TweenInfo.new(0.5), false, function(p449)
				Part5.Transparency = p449;
			end);
			delay(1, function()
				for _, val58 in pairs(table28) do
					val58.part:Destroy();
				end
				Part5:Destroy();
			end);
			return true;
		end,
		voltswitch = function(p194, p195, p196) -- thunderstrike
			local v369 = p195[1];
			if not v369 then return end
			local v370 = p194.sprite or p194;
			local v371 = v370.part.CFrame * Vector3.new(0, v370.part.Size.Y * 0.15, v370.part.Size.Z * -0.5 - 0);
			local v372 = v369.sprite or v369;
			local v373 = v372.part.CFrame * Vector3.new(0, v372.part.Size.Y * 0.15, v372.part.Size.Z * -0.5 - 0);
			local cf61 = CFrame.new(v371, v373);
			local u187 = v373 - v371;
			local _ = u187.magnitude;
			local Clone_ret152 = Misc.PowerRing:Clone();
			Clone_ret152.Size = Vector3.new(20, 0.1, 20);
			Clone_ret152.Color = Color3.fromRGB(248, 217, 109);
			Clone_ret152.CFrame = cf61 * CFrame.new(0, 0, -1) * CFrame.Angles(math.pi / 2, 0, 0);
			Clone_ret152.Parent = p196.scene;
			local bool8 = true;
			local u188 = u187.magnitude / 2;
			local table48 = {
				Color = ColorSequence.new(Color3.fromRGB(248, 217, 109)),
				Transparency = NumberSequence.new(0, 1),
				WidthScale = NumberSequence.new(0.1, 1),
				LightEmission = 1,
				Lifetime = 1
			};
			local u189 = 10;
			local u190 = math.pi * 3;
			local u191 = CFrame.new(Clone_ret152.Position, cf61.p) * CFrame.new(0, 0, 10) * CFrame.Angles(math.pi / 2, 0, 0);
			local coroutine_wrap_ret17 = coroutine.wrap(function()
				while bool8 == true do
					local u426 = ({
						-1,
						1
					})[Random_new_ret:NextInteger(1, 2)];
					local u427 = Random_new_ret:NextNumber() * 2;
					spawn(function()
						u13.makeSpiral(2, u191 * CFrame.Angles(0, u427 * math.pi / 6, 0), u190 * u426, -u188, u189, 0.75, TweenInfo.new(0.5, Enum.EasingStyle.Linear), "Shrink", table48);
					end);
					task.wait(0.05);
				end
			end);
			coroutine_wrap_ret17();
			local CFrame44 = Clone_ret152.CFrame;
			u13.Tween(TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), true, function(p496)
				Clone_ret152.Size = Vector3.new(20 - p496 * 18, 0.1, 20 - p496 * 18);
				u189 = 10 - p496 * 7;
				Clone_ret152.CFrame = CFrame44 * CFrame.Angles(0, math.pi * 6 * p496, 0);
			end);
			bool8 = false;
			local u192 = Utilities.Create("Part")({
				Anchored = true,
				CanCollide = false,
				Color = Color3.fromRGB(248, 217, 109),
				Shape = "Cylinder",
				Size = Vector3.new(0.2, 0.1, 0.1),
				Material = "Neon",
				CFrame = (cf61 + u187 / 2) * CFrame.Angles(math.pi / 2, 0, math.pi / 2),
				Parent = p196.scene
			});
			local Attachment57 = Instance.new("Attachment", workspace.Terrain);
			Attachment57.WorldCFrame = CFrame.new(v371);
			local Clone_ret153 = Particles.FlashLightning:Clone();
			Clone_ret153.Transparency = NumberSequence.new(0, 1);
			Clone_ret153.Size = NumberSequence.new(2, 15);
			Clone_ret153.Enabled = false;
			Clone_ret153.Lifetime = NumberRange.new(0.5);
			Clone_ret153.Parent = Attachment57;
			Clone_ret153:Emit(10);
			u13.Tween(TweenInfo.new(0.2, Enum.EasingStyle.Linear), true, function(p497)
				Clone_ret152.Size = Vector3.new(p497 * 17 + 3, u187.magnitude * 0.1 * p497, p497 * 17 + 3);
				Clone_ret152.CFrame = CFrame44 * CFrame.new(0, -u187.magnitude / 2 * p497, 0);
				u192.Transparency = p497;
				u192.Size = Vector3.new(u187.magnitude * p497, p497 * 5 + 0.1, p497 * 5 + 0.1);
				u192.CFrame = cf61 * CFrame.new(0, 0, -u187.magnitude / 2 * p497) * CFrame.Angles(math.pi / 2, 0, math.pi / 2);
				Clone_ret152.Transparency = p497;
			end);
			u13.ballExplosion(TweenInfo.new(1, Enum.EasingStyle.Cubic), cf61 + u187, 15, Color3.fromRGB(248, 217, 109), Color3.fromRGB(253, 234, 141), "Neon", "Neon");
			u9("Bump")
			delay(1, function()
				Attachment57:Destroy();
				u192:Destroy();
			end);
			return true;
		end,
		thunderpunch = function(p181, p182, _) -- electropunch
			local v341 = p182[1];
			if not v341 then return end
			local v342 = p181.sprite or p181;
			local v343 = v342.part.CFrame * Vector3.new(0, v342.part.Size.Y * 0.15, v342.part.Size.Z * -0.5 - 0);
			local v344 = v341.sprite or v341;
			local u167 = v344.part.CFrame * Vector3.new(0, v344.part.Size.Y * 0.15, v344.part.Size.Z * -0.5 - 0);
			local Clone_ret139 = Misc.Fist:Clone();
			local v345 = u167 - v343;
			Clone_ret139.Color = Color3.fromRGB(254, 255, 144);
			Clone_ret139.Material = "Neon";
			Clone_ret139.Transparency = 0.1;
			Clone_ret139.Trail.LightEmission = 0.5;
			Clone_ret139.Trail.Color = ColorSequence.new(Color3.fromRGB(254, 255, 144));
			local v346 = CFrame.new(v343, u167) * CFrame.new(15, 5, 0);
			local p8 = v346.p;
			local p9 = (v346 * CFrame.new(0, 0, -v345.magnitude / 3)).p;
			local p10 = (v346 * CFrame.new(0, 0, v345.magnitude * -2 / 3)).p;
			local u168 = CFrame.new(p8, p9) - p8;
			local u169 = CFrame.new(p10, u167) - p10;
			Clone_ret139.CFrame = v346;
			Clone_ret139.Size = Vector3.new(4, 5, 6);
			Clone_ret139.Parent = workspace;
			u13.Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic), true, function(p487, _)
				local v860 = u13.bezierCurve(p8, p9, p10, u167, p487);
				Clone_ret139.CFrame = u168:Lerp(u169, p487) + v860;
				local Position3 = Clone_ret139.Position;
				u13.BranchLightning(Position3, (Clone_ret139.CFrame * CFrame.new(0, 0, 15) * CFrame.Angles(Random_new_ret:NextNumber(-math.pi / 4, math.pi / 4), 0, 0)).p, 5, 2, 0.2, Color3.fromRGB(254, 255, 144), 0.1, 3);
			end);
			Clone_ret139.Transparency = 1;
			local CFrame39 = Clone_ret139.CFrame;
			local Attachment53 = Instance.new("Attachment", workspace.Terrain);
			Attachment53.WorldCFrame = Clone_ret139.CFrame;
			local Attachment54 = Instance.new("Attachment", workspace.Terrain);
			Attachment54.WorldCFrame = CFrame.new(u167);
			local Clone_ret140 = Particles.SparkV2:Clone();
			Clone_ret140.Size = NumberSequence.new(0.1, 0);
			Clone_ret140.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(254, 255, 144));
			Clone_ret140.Acceleration = Vector3.new(0, -12, 0);
			Clone_ret140.SpreadAngle = Vector2.new(180, 180);
			Clone_ret140.Speed = NumberRange.new(10, 15);
			Clone_ret140.Enabled = false;
			Clone_ret140.Parent = Attachment54;
			Clone_ret140:Emit(36);
			for index32 = 1, 15 do
				local Position4 = Clone_ret139.Position;
				u13.BranchLightning(Position4, (Clone_ret139.CFrame * CFrame.Angles(0, 0, math.pi * 2 * index32 / 15) * CFrame.new(15, 0, 0)).p, 5, 2, 0.2, Color3.fromRGB(254, 255, 144), 0.75, 3);
			end
			spawn(function()
				u13.blast(CFrame39, 12, 60, 60, Color3.fromRGB(254, 255, 144), Color3.fromRGB(255, 255, 255), Color3.fromRGB(254, 255, 144));
			end);
			delay(Clone_ret140.Lifetime.Max, function()
				Attachment53:Destroy();
				Clone_ret139:Destroy();
			end);
			return true;
		end,
		firepunch = function(p225, p226, _) -- frostpunch recolor
			local v431 = p226[1];
			if not v431 then return end
			local v432 = p225.sprite or p225;
			local v433 = v432.part.CFrame * Vector3.new(0, v432.part.Size.Y * 0.15, v432.part.Size.Z * -0.5 - 0);
			local v434 = v431.sprite or v431;
			local u222 = v434.part.CFrame * Vector3.new(0, v434.part.Size.Y * 0.15, v434.part.Size.Z * -0.5 - 0);
			local _ = workspace.CurrentCamera.CFrame;
			local Clone_ret178 = Misc.Fist:Clone();
			local v435 = u222 - v433;
			Clone_ret178.Color = Color3.fromRGB(255, 0, 0);
			Clone_ret178.Material = "Neon";
			Clone_ret178.Transparency = 0.1;
			Clone_ret178.Trail.LightEmission = 0.25;
			Clone_ret178.Trail.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0));
			local v436 = CFrame.new(v433, u222) * CFrame.new(15, 5, 0);
			local p13 = v436.p;
			local p14 = (v436 * CFrame.new(0, 0, -v435.magnitude / 3)).p;
			local p15 = (v436 * CFrame.new(0, 0, v435.magnitude * -2 / 3)).p;
			local u223 = CFrame.new(p13, p14) - p13;
			local u224 = CFrame.new(p15, u222) - p15;
			Clone_ret178.CFrame = v436;
			Clone_ret178.Size = Vector3.new(4, 5, 6);
			Clone_ret178.Parent = workspace;
			u13.Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic), true, function(p514, _)
				local v872 = u13.bezierCurve(p13, p14, p15, u222, p514);
				Clone_ret178.CFrame = u223:Lerp(u224, p514) + v872;
			end);
			Clone_ret178.Transparency = 1;
			local CFrame51 = Clone_ret178.CFrame;
			local Attachment66 = Instance.new("Attachment", workspace.Terrain);
			Attachment66.WorldCFrame = Clone_ret178.CFrame;
			local Clone_ret179 = Particles.Fire:Clone();
			Clone_ret179.Enabled = false;
			Clone_ret179.Parent = Attachment66;
			Clone_ret179.LightEmission = 0.1;
			Clone_ret179.Lifetime = NumberRange.new(1);
			Clone_ret179.Size = NumberSequence.new(1.5, 2.5);
			Clone_ret179.SpreadAngle = Vector2.new(0, 360);
			Clone_ret179.Transparency = NumberSequence.new(0, 1);
			Clone_ret179.Speed = NumberRange.new(30);
			Clone_ret179:Emit(24);
			spawn(function()
				u13.blast(CFrame51, 10, 60, 60, Color3.fromRGB(245, 205, 48), Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 0, 0));
			end);
			delay(Clone_ret179.Lifetime.Max, function()
				Attachment66:Destroy();
				Clone_ret178:Destroy();
			end);
			return true;
		end,
		icepunch = function(p225, p226, _) -- frostpunch
			local v431 = p226[1];
			if not v431 then return end
			local v432 = p225.sprite or p225;
			local v433 = v432.part.CFrame * Vector3.new(0, v432.part.Size.Y * 0.15, v432.part.Size.Z * -0.5 - 0);
			local v434 = v431.sprite or v431;
			local u222 = v434.part.CFrame * Vector3.new(0, v434.part.Size.Y * 0.15, v434.part.Size.Z * -0.5 - 0);
			local _ = workspace.CurrentCamera.CFrame;
			local Clone_ret178 = Misc.Fist:Clone();
			local v435 = u222 - v433;
			Clone_ret178.Color = Color3.fromRGB(128, 187, 219);
			Clone_ret178.Material = "Glass";
			Clone_ret178.Transparency = 0.1;
			Clone_ret178.Trail.LightEmission = 0.25;
			Clone_ret178.Trail.Color = ColorSequence.new(Color3.fromRGB(128, 187, 219));
			local v436 = CFrame.new(v433, u222) * CFrame.new(15, 5, 0);
			local p13 = v436.p;
			local p14 = (v436 * CFrame.new(0, 0, -v435.magnitude / 3)).p;
			local p15 = (v436 * CFrame.new(0, 0, v435.magnitude * -2 / 3)).p;
			local u223 = CFrame.new(p13, p14) - p13;
			local u224 = CFrame.new(p15, u222) - p15;
			Clone_ret178.CFrame = v436;
			Clone_ret178.Size = Vector3.new(4, 5, 6);
			Clone_ret178.Parent = workspace;
			u13.Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic), true, function(p514, _)
				local v872 = u13.bezierCurve(p13, p14, p15, u222, p514);
				Clone_ret178.CFrame = u223:Lerp(u224, p514) + v872;
			end);
			Clone_ret178.Transparency = 1;
			local CFrame51 = Clone_ret178.CFrame;
			local Attachment66 = Instance.new("Attachment", workspace.Terrain);
			Attachment66.WorldCFrame = Clone_ret178.CFrame;
			local Clone_ret179 = Particles.Ice:Clone();
			Clone_ret179.Enabled = false;
			Clone_ret179.Parent = Attachment66;
			Clone_ret179.LightEmission = 0.1;
			Clone_ret179.Lifetime = NumberRange.new(1);
			Clone_ret179.Size = NumberSequence.new(1.5, 2.5);
			Clone_ret179.SpreadAngle = Vector2.new(0, 360);
			Clone_ret179.Transparency = NumberSequence.new(0, 1);
			Clone_ret179.Speed = NumberRange.new(30);
			Clone_ret179:Emit(24);
			spawn(function()
				u13.blast(CFrame51, 10, 60, 60, Color3.fromRGB(128, 187, 219), Color3.fromRGB(128, 187, 219), Color3.fromRGB(128, 187, 219));
			end);
			delay(Clone_ret179.Lifetime.Max, function()
				Attachment66:Destroy();
				Clone_ret178:Destroy();
			end);
			return true;
		end,
		machpunch = function(p84, p85, p86) -- quickpunch
			local v155 = p85[1];
			if not v155 then return end
			local v156 = p84.sprite or p84;
			local v157 = v156.part.CFrame * Vector3.new(0, v156.part.Size.Y * 0.15, v156.part.Size.Z * -0.5 - 0);
			local v158 = v155.sprite or v155;
			local v159 = v158.part.CFrame * Vector3.new(0, v158.part.Size.Y * 0.15, v158.part.Size.Z * -0.5 - 0);
			local u72 = v159 - v157;
			local cf19 = CFrame.new(v157, v159);
			local Clone_ret51 = Misc.Fist:Clone();
			Clone_ret51.Color = Color3.fromRGB(148, 71, 36);
			Clone_ret51.Transparency = 0.25;
			Clone_ret51.Trail.Color = ColorSequence.new(Color3.fromRGB(197, 97, 48));
			Clone_ret51.Trail.Lifetime = 0.1;
			Clone_ret51.Material = "Neon";
			Clone_ret51.Size = Clone_ret51.Size * 0.8;
			Clone_ret51.CFrame = cf19;
			Clone_ret51.Parent = p86.scene;
			spawn(function()
				for index92 = 0, 3 do
					local Clone_ret52 = Misc.ThinRing:Clone();
					Clone_ret52.Size = Vector3.new(Clone_ret51.Size.Z, 0.1, Clone_ret51.Size.Z);
					Clone_ret52.Color = Color3.fromRGB(197, 97, 48);
					Clone_ret52.Material = "Neon";
					Clone_ret52.Transparency = 0.25;
					Clone_ret52.CFrame = (cf19 + u72 * index92 / 3) * CFrame.Angles(math.pi / 2, 0, 0);
					Clone_ret52.Parent = p86.scene;
					local Size8 = Clone_ret52.Size;
					u13.Tween(TweenInfo.new(0.2), false, function(p729)
						Clone_ret52.Size = Vector3.new(Size8.X + p729 * 4, 0.1, Size8.Z + p729 * 4);
						Clone_ret52.Transparency = p729 * 0.75 + 0.25;
					end).Completed:Connect(function()
						Clone_ret52:Destroy();
					end);
					task.wait(1 / 15);
				end
			end);
			u13.Tween(TweenInfo.new(0.1), true, function(p428)
				Clone_ret51.CFrame = cf19 + u72 * p428;
			end);
			spawn(function()
				u13.Tween(TweenInfo.new(0.1), false, function(p632)
					Clone_ret51.Transparency = p632 * 0.75 + 0.25;
				end);
				u13.blast(cf19 + u72, 3, u72.magnitude * 0.75, 12, Color3.fromRGB(197, 97, 48), Color3.fromRGB(197, 97, 48), Color3.fromRGB(255, 98, 46));
				Clone_ret51:Destroy();
			end);
			return true;
		end,
		suckerpunch = function(p84, p85, p86) -- quickpunch
			local v155 = p85[1];
			if not v155 then return end
			local v156 = p84.sprite or p84;
			local v157 = v156.part.CFrame * Vector3.new(0, v156.part.Size.Y * 0.15, v156.part.Size.Z * -0.5 - 0);
			local v158 = v155.sprite or v155;
			local v159 = v158.part.CFrame * Vector3.new(0, v158.part.Size.Y * 0.15, v158.part.Size.Z * -0.5 - 0);
			local u72 = v159 - v157;
			local cf19 = CFrame.new(v157, v159);
			local Clone_ret51 = Misc.Fist:Clone();
			Clone_ret51.Color = Color3.fromRGB(0, 0, 0);
			Clone_ret51.Transparency = 0.25;
			Clone_ret51.Trail.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0));
			Clone_ret51.Trail.Lifetime = 0.1;
			Clone_ret51.Material = "Neon";
			Clone_ret51.Size = Clone_ret51.Size * 0.8;
			Clone_ret51.CFrame = cf19;
			Clone_ret51.Parent = p86.scene;
			spawn(function()
				for index92 = 0, 3 do
					local Clone_ret52 = Misc.ThinRing:Clone();
					Clone_ret52.Size = Vector3.new(Clone_ret51.Size.Z, 0.1, Clone_ret51.Size.Z);
					Clone_ret52.Color = Color3.fromRGB(0, 0, 0);
					Clone_ret52.Material = "Neon";
					Clone_ret52.Transparency = 0.25;
					Clone_ret52.CFrame = (cf19 + u72 * index92 / 3) * CFrame.Angles(math.pi / 2, 0, 0);
					Clone_ret52.Parent = p86.scene;
					local Size8 = Clone_ret52.Size;
					u13.Tween(TweenInfo.new(0.2), false, function(p729)
						Clone_ret52.Size = Vector3.new(Size8.X + p729 * 4, 0.1, Size8.Z + p729 * 4);
						Clone_ret52.Transparency = p729 * 0.75 + 0.25;
					end).Completed:Connect(function()
						Clone_ret52:Destroy();
					end);
					task.wait(1 / 15);
				end
			end);
			u13.Tween(TweenInfo.new(0.1), true, function(p428)
				Clone_ret51.CFrame = cf19 + u72 * p428;
			end);
			spawn(function()
				u13.Tween(TweenInfo.new(0.1), false, function(p632)
					Clone_ret51.Transparency = p632 * 0.75 + 0.25;
				end);
				u13.blast(cf19 + u72, 3, u72.magnitude * 0.75, 12, Color3.fromRGB(0, 0, 48), Color3.fromRGB(0, 0, 48), Color3.fromRGB(0, 0, 46));
				Clone_ret51:Destroy();
			end);
			return true;
		end,
		megapunch = function(p87, p88, p89) -- punch
			local v160 = p88[1];
			if not v160 then return end
			local v161 = p87.sprite or p87;
			local v162 = v161.part.CFrame * Vector3.new(0, v161.part.Size.Y * 0.15, v161.part.Size.Z * -0.5 - 0);
			local v163 = v160.sprite or v160;
			local u73 = v163.part.CFrame * Vector3.new(0, v163.part.Size.Y * 0.15, v163.part.Size.Z * -0.5 - 0);
			local Clone_ret53 = Misc.Fist:Clone();
			local v164 = u73 - v162;
			local v165 = CFrame.new(v162, u73) * CFrame.new(15, 5, 0);
			local p4 = v165.p;
			local p5 = (v165 * CFrame.new(0, 0, -v164.magnitude / 3)).p;
			local p6 = (v165 * CFrame.new(0, 0, v164.magnitude * -2 / 3)).p;
			local u74 = CFrame.new(p4, p5) - p4;
			local u75 = CFrame.new(p6, u73) - p6;
			Clone_ret53.CFrame = v165;
			Clone_ret53.Size = Vector3.new(4, 5, 6);
			Clone_ret53.Parent = p89.scene;
			u13.Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic), true, function(p429, _)
				local v834 = u13.bezierCurve(p4, p5, p6, u73, p429);
				Clone_ret53.CFrame = u74:Lerp(u75, p429) + v834;
			end);
			Clone_ret53:Destroy();
			local Clone_ret54 = Misc.HitEffect1:Clone();
			Clone_ret54.Transparency = 0.1;
			Clone_ret54.Color = Color3.fromRGB(213, 115, 61);
			Clone_ret54.Size = Vector3.new(15, 12, 15);
			local Clone_ret55 = Clone_ret54:Clone();
			Clone_ret55.Size = Vector3.new(7.5, 35, 7.5);
			Clone_ret55.Color = Color3.fromRGB(226, 155, 64);
			local u76 = (u75 + u73) * CFrame.Angles(0, -math.pi / 2, -math.pi / 2) * CFrame.new(0, Clone_ret54.Size.Y / 2, 0);
			local u77 = (u75 + u73) * CFrame.Angles(0, -math.pi / 2, -math.pi / 2) * CFrame.new(0, Clone_ret55.Size.Y / 2, 0);
			Clone_ret54.CFrame = u76;
			Clone_ret55.CFrame = u77;
			Clone_ret54.Parent = p89.scene;
			Clone_ret55.Parent = p89.scene;
			local Clone_ret56 = Misc.ThinRing:Clone();
			Clone_ret56.Color = Color3.fromRGB(213, 115, 61);
			Clone_ret56.CFrame = (u75 + u73) * CFrame.Angles(math.pi / 2, 0, 0);
			Clone_ret56.Size = Vector3.new(15, 0.1, 15);
			local Clone_ret57 = Particles.HitParticleRed:Clone();
			Clone_ret57.Enabled = true;
			local Attachment22 = Instance.new("Attachment", Clone_ret56);
			Clone_ret57.Parent = Attachment22;
			Clone_ret56.Parent = p89.scene;
			local Size9 = Clone_ret54.Size;
			local Size10 = Clone_ret55.Size;
			local Size11 = Clone_ret56.Size;
			u9("Explosion",1);
			spawn(function()
				u13.Tween(TweenInfo.new(0.5, Enum.EasingStyle.Cubic), true, function(p633)
					Clone_ret54.Size = Size9 + Vector3.new(p633 * 5, p633 * -8, p633 * 5);
					Clone_ret54.CFrame = u76 * CFrame.new(0, p633 * -4, 0);
					Clone_ret55.Size = Size10 - Vector3.new(p633 * 5.5, p633 * 30, p633 * 5.5);
					Clone_ret55.CFrame = u77 * CFrame.new(0, p633 * -15, 0);
					Clone_ret56.Size = Size11 + Vector3.new(p633 * 25, 0, p633 * 25);
					Clone_ret56.Transparency = p633 * 0.9 + 0.1;
					Clone_ret55.Transparency = p633 * 0.9 + 0.1;
					Clone_ret54.Transparency = p633 * 0.9 + 0.1;
				end);
				Clone_ret54:Destroy();
				Clone_ret55:Destroy();
				Clone_ret56:Destroy();
			end);
			return true;
		end,
		dynamicpunch = function(p95, p96, p97) -- megapunch
			local v177 = p96[1];
			if not v177 then return end
			local v178 = p95.sprite or p95;
			local u81 = v178.part.CFrame * Vector3.new(0, v178.part.Size.Y * 0.15, v178.part.Size.Z * -0.5 - 0);
			local v179 = v177.sprite or v177;
			local u82 = v179.part.CFrame * Vector3.new(0, v179.part.Size.Y * 0.15, v179.part.Size.Z * -0.5 - 0);
			local cf21 = CFrame.new((CFrame.new(u81, u82) * CFrame.new(3, 0, 0)).Position, u82);
			local Clone_ret62 = Misc.Fist:Clone();
			Clone_ret62:ClearAllChildren();
			local u83 = Clone_ret62.Size * 0.3;
			Clone_ret62.Color = Color3.fromRGB(197, 97, 48);
			Clone_ret62.Size = Clone_ret62.Size * 0.3;
			Clone_ret62.Material = "Neon";
			Clone_ret62.CFrame = cf21;
			Clone_ret62.Parent = p97.scene;
			local u84 = Clone_ret62.Size * 1.7;
			local function makeEffect(p433, p434, p435, p436)
				local Clone_ret63 = Misc.HitEffect2:Clone();
				Clone_ret63.Size = Vector3.new(p435 * 2, p435 / 6 + 1, p435 * 2);
				Clone_ret63.Material = "Neon";
				Clone_ret63.Color = p434;
				Clone_ret63.CFrame = p433;
				Clone_ret63.Parent = p97.scene;
				local table20 = {
					Color = ColorSequence.new(p434),
					Transparency = NumberSequence.new(0.25, 1),
					WidthScale = NumberSequence.new(1, 0.1),
					LightEmission = 0,
					Lifetime = 1,
					FaceCamera = false
				};
				u13.trailSwirl(Clone_ret63.CFrame, 0.5, p435 * 0.75 + 6, 0.25, math.pi * 3, table20, false);
				local u404 = p435 * 2;
				local CFrame21 = Clone_ret63.CFrame;
				u13.Tween(TweenInfo.new(0.25), false, function(p692)
					Clone_ret63.Size = Vector3.new(u404 + p692 * 2, u404 * 0.75 + p692 * 2 + p436, u404 + p692 * 2);
					Clone_ret63.CFrame = CFrame21;
					Clone_ret63.Transparency = p692;
				end).Completed:Connect(function()
					Clone_ret63:Destroy();
				end);
			end
			local table21 = {
				Color3.fromRGB(255, 118, 49),
				Color3.fromRGB(255, 180, 29),
				Color3.fromRGB(255, 79, 10)
			};
			local bool3 = true;
			local u86 = 1;
			spawn(function()
				while bool3 == true do
					local v927 = table21[Random_new_ret:NextInteger(1, #table21)];
					makeEffect(Clone_ret62.CFrame * CFrame.new(0, 0, -u86 / 6) * CFrame.Angles(math.pi / 2, math.pi * 2 * Random_new_ret:NextNumber(), 0), v927, u86, 0);
					task.wait(0.1);
				end
			end);
			u13.Tween(TweenInfo.new(0.8, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), true, function(p437)
				u86 = p437 * 3 + 1;
				Clone_ret62.Size = u83 + u84 * p437;
				Clone_ret62.CFrame = cf21 * CFrame.new(0, p437, p437);
			end);
			task.wait(0.25);
			local _ = Clone_ret62.Size.X;
			bool3 = false;
			local u87 = u82 - Clone_ret62.Position;
			u13.Tween(TweenInfo.new(0.2), false, function(p438)
				Clone_ret62.CFrame = Clone_ret62.CFrame + u87 * p438;
				local _ = Clone_ret62.CFrame * CFrame.Angles(math.pi / 2, Random_new_ret:NextNumber() * 2 * math.pi, 0);
				local _ = table21[Random_new_ret:NextInteger(1, #table21)];
			end);
			local Attachment26 = Instance.new("Attachment", workspace.Terrain);
			Attachment26.WorldCFrame = CFrame.new(u82);
			local Clone_ret64 = Particles.HitParticleBlue:Clone();
			Clone_ret64.Color = ColorSequence.new(Color3.fromRGB(255, 118, 49));
			Clone_ret64.Size = NumberSequence.new(0.25, 25);
			Clone_ret64.Transparency = NumberSequence.new(0, 1);
			Clone_ret64.Lifetime = NumberRange.new(0.75, 1);
			Clone_ret64.Enabled = false;
			Clone_ret64.Parent = Attachment26;
			Clone_ret64:Emit(2);
			u9("Explosion",1);
			spawn(function()
				local v835 = u82 - u81;
				local v836 = CFrame.new(u81, u82) + v835;
				u13.Tween(TweenInfo.new(1), false, function(p635)
					Clone_ret62.Transparency = p635;
				end);
				for index93 = 1, 12 do
					local v928 = table21[Random_new_ret:NextInteger(1, #table21)];
					local table22 = {
						Color = ColorSequence.new(v928),
						Transparency = NumberSequence.new(0.25, 1),
						WidthScale = NumberSequence.new(1, 0.1),
						LightEmission = 0,
						Lifetime = 1,
						FaceCamera = false
					};
					u13.trailSwirl(v836, Random_new_ret:NextNumber() * 0.5 + 0.9, Random_new_ret:NextNumber() * 10 + 10, 0.5, math.pi * 2 + math.pi * 2 * Random_new_ret:NextNumber(), table22, true);
				end
				u13.blast(v836, 25, v835, 36, Color3.fromRGB(200, 100, 100), Color3.fromRGB(200, 100, 100), Color3.fromRGB(200, 100, 100),false,1);
				Clone_ret62:Destroy();
				Attachment26:Destroy();
			end);
			return true;
		end,
		karatechop = function(p79, p80, p81) -- chop
			local v143 = p80[1];
			if not v143 then return end
			local v144 = p79.sprite or p79;
			local v145 = v144.part.CFrame * Vector3.new(0, v144.part.Size.Y * 0.15, v144.part.Size.Z * -0.5 - 0);
			local v146 = v143.sprite or v143;
			local v147 = v146.part.CFrame * Vector3.new(0, v146.part.Size.Y * 0.15, v146.part.Size.Z * -0.5 - 0);
			local NextInteger_ret2 = Random_new_ret:NextInteger(-45, 45);
			local v148 = v147 - v145;
			local u68 = (CFrame.new(v145, v147) + v148) * CFrame.Angles(0, 0, (math.rad(NextInteger_ret2)));
			local Clone_ret49 = Misc.Crescent:Clone();
			Clone_ret49.Color = Color3.fromRGB(197, 97, 48);
			Clone_ret49.Size = Vector3.new(10, 0.5, 5);
			Clone_ret49.Trail1.Color = ColorSequence.new(Color3.fromRGB(197, 97, 48));
			Clone_ret49.Trail2.Color = ColorSequence.new(Color3.fromRGB(197, 97, 48));
			Clone_ret49.Trail1.Lifetime = 0.2;
			Clone_ret49.Trail2.Lifetime = 0.2;
			local v149 = u68 * CFrame.new(0, 25, 0);
			local cf17 = CFrame.new(v149.p, u68.p);
			Clone_ret49.CFrame = v149;
			Clone_ret49.Parent = p81.scene;
			delay(0.075, function()
				u13.slashEffect(u68 * CFrame.Angles(0, 0, math.pi / 2) * CFrame.new(12.5, 0, 0), Color3.fromRGB(197, 97, 48), Color3.fromRGB(255, 55, 37), -25, 8, 0.05);
			end);
			u13.Tween(TweenInfo.new(0.15), true, function(p425)
				Clone_ret49.CFrame = cf17 * CFrame.new(0, 0, p425 * -30);
			end);
			Clone_ret49:Destroy();
			return true;
		end,
		jumpkick = function(p82, p83, _) -- hopkick
			local v150 = p83[1];
			if not v150 then return end
			local v151 = p82.sprite or p82;
			local v152 = v151.part.CFrame * Vector3.new(0, v151.part.Size.Y * 0.15, v151.part.Size.Z * -0.5 - 0);
			local v153 = v150.sprite or v150;
			local v154 = v153.part.CFrame * Vector3.new(0, v153.part.Size.Y * 0.15, v153.part.Size.Z * -0.5 - 0);
			local u69 = v154 - v152;
			local u70 = u13.MaxYFOV(v154, v152);
			local u71 = CFrame.new(v152, v154) + u69;
			local Model6 = p82.sprite.part;
			local _ = p82.sprite.part.Position.Y - p82.sprite.cf.p.Y;
			local CFrame15 = Model6.CFrame;
			local Attachment21 = Instance.new("Attachment", workspace.Terrain);
			Attachment21.WorldCFrame = u71;
			local Clone_ret50 = Particles.HitParticleBlue:Clone();
			Clone_ret50.Color = ColorSequence.new(Color3.fromRGB(197, 97, 48));
			Clone_ret50.Size = NumberSequence.new(0.5, 15);
			Clone_ret50.Lifetime = NumberRange.new(0.5, 0.6);
			Clone_ret50.Enabled = false;
			Clone_ret50.Parent = Attachment21;
			local cf18 = CFrame.new(Model6.Position, v154);
			local magnitude6 = (v154 - cf18.p).magnitude;
			local CFrame16 = Model6.CFrame;
			spawn(function()
				u13.trailSlash(cf18 * CFrame.Angles(0, math.pi / 4, 0), 0.25, magnitude6 * 0.75, magnitude6 * 2, Color3.fromRGB(197, 97, 48), math.pi, true);
			end);
			task.wait(0.125);
			Clone_ret50:Emit(3);
			spawn(function()
				u13.blast(u71 * CFrame.Angles(0, math.pi / 4, 0), 6, u69.magnitude, 16, Color3.fromRGB(197, 97, 48), Color3.fromRGB(197, 97, 48), Color3.fromRGB(255, 98, 46));
			end);
			spawn(function()
				task.wait(0.125);
				CFrame16 = Model6.CFrame;
				u13.Tween(TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), true, function(p631)
					local Lerp_ret9 = CFrame16:Lerp(CFrame15, p631);
				end);
				Attachment21:Destroy();
			end);
			return true;
		end,
		avalanche = function(p214, p215, _) -- flurry
			local v406 = p215[1];
			if not v406 then return end
			local v407 = p214.sprite or p214;
			local v408 = v407.part.CFrame * Vector3.new(0, v407.part.Size.Y * 0.15, v407.part.Size.Z * -0.5 - 0);
			local v409 = v406.sprite or v406;
			local v410 = v409.part.CFrame * Vector3.new(0, v409.part.Size.Y * 0.15, v409.part.Size.Z * -0.5 - 0);
			local cf66 = CFrame.new(v408, v410);
			local v411 = v410 - v408;
			local _ = v411.magnitude;
			local v412 = cf66 + v411;
			local v413 = u13.MaxYFOV(v410, v408);
			local cf67 = CFrame.new((v412 + Vector3.new(0, v413, 0)).p, v410);
			local Attachment62 = Instance.new("Attachment", workspace.Terrain);
			Attachment62.WorldCFrame = cf67;
			local Clone_ret167 = Particles.Flurry:Clone();
			Clone_ret167.Parent = Attachment62;
			local v414 = v410 - cf67.p;
			local magnitude18 = v414.magnitude;
			Clone_ret167.Speed = NumberRange.new(magnitude18);
			local Clone_ret168 = Particles.SparkV2:Clone();
			Clone_ret168.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255));
			Clone_ret168.Size = NumberSequence.new(0.1);
			Clone_ret168.LightEmission = 0;
			Clone_ret168.Acceleration = Vector3.new(0, 0, 0);
			Clone_ret168.Speed = NumberRange.new(magnitude18 - 5, magnitude18 + 10);
			Clone_ret168.SpreadAngle = Vector2.new(30, 30);
			Clone_ret168.Enabled = false;
			Clone_ret168.Lifetime = NumberRange.new(1);
			Clone_ret168.EmissionDirection = "Front";
			Clone_ret168.Parent = Attachment62;
			Clone_ret167:Emit(3);
			Clone_ret168:Emit(20);
			Clone_ret167.Enabled = true;
			Clone_ret168.Enabled = true;
			local magnitude19 = v414.magnitude;
			local table52 = {
				Color = ColorSequence.new(Color3.fromRGB(160, 255, 255)),
				Transparency = NumberSequence.new(0, 1),
				WidthScale = NumberSequence.new(1, 0.1),
				LightEmission = 0.1,
				Lifetime = 1.5
			};
			local math_pi2 = math.pi;
			for index40 = 1, 5 do
				spawn(function()
					u13.makeSpiral(1, cf67 * CFrame.Angles(math.pi / 2, index40 * math.pi / 6, 0), math_pi2, -(magnitude19 + 1), 6, 0.25, TweenInfo.new(0.75, Enum.EasingStyle.Linear), "Grow", table52);
				end);
				task.wait();
			end
			task.wait(1.5);
			Clone_ret167.Enabled = false;
			Clone_ret168.Enabled = false;
			task.wait(1.5);
			Attachment62:Destroy();
			return true;
		end,
		shockwave = function(p236, p237, _) -- energysurge
			local v449 = p237[1];
			if not v449 then return end
			local v450 = p236.sprite or p236;
			local v451 = v450.part.CFrame * Vector3.new(0, v450.part.Size.Y * 0.15, v450.part.Size.Z * -0.5 - 0);
			local v452 = v449.sprite or v449;
			local _ = v452.part.CFrame * Vector3.new(0, v452.part.Size.Y * 0.15, v452.part.Size.Z * -0.5 - 0);
			local cf75 = CFrame.new(p236.sprite.cf.p);
			local u228 = cf75 + Vector3.new(0, (v451.Y - cf75.y) / 2, 0);
			local u229 = {};
			for index45 = math.pi / 6, math.pi * 2, math.pi / 3 do
				local Attachment71 = Instance.new("Attachment", workspace.Terrain);
				Attachment71.WorldCFrame = u228 * CFrame.Angles(0, index45 - math.pi / 6, 0);
				local Clone_ret185 = Attachment71:Clone();
				Attachment71.WorldCFrame = u228 * CFrame.Angles(0, index45 + math.pi / 6, 0);
				Clone_ret185.Parent = workspace.Terrain;
				local v793 = Utilities.Create("Trail")({
					Color = ColorSequence.new(Color3.fromRGB(253, 234, 141)),
					LightEmission = 0.25,
					Lifetime = 1.5,
					Transparency = NumberSequence.new(0, 1),
					Parent = workspace.Terrain
				});
				v793.Attachment0 = Attachment71;
				v793.Attachment1 = Clone_ret185;
				local table59 = {
					trail = v793,
					a0 = Attachment71,
					a1 = Clone_ret185,
					rot = index45
				};
				table.insert(u229, table59);
			end
			local Attachment70 = Instance.new("Attachment", workspace.Terrain);
			Attachment70.WorldCFrame = u228;
			local Clone_ret184 = Particles.HitParticleBlue:Clone();
			Clone_ret184.Color = ColorSequence.new(Color3.fromRGB(253, 234, 141), Color3.fromRGB(255, 255, 255));
			Clone_ret184.Size = NumberSequence.new(0.5, 15);
			Clone_ret184.Lifetime = NumberRange.new(0.375, 0.75);
			Clone_ret184.Enabled = false;
			Clone_ret184.Parent = Attachment70;
			Clone_ret184:Emit(5);
			u13.Tween(TweenInfo.new(0.75), true, function(p517)
				for _, val71 in pairs(u229) do
					local cf76 = CFrame.new(0, math.sin(math.pi * 9 * p517) * 0.5, p517 * -30);
					val71.a0.WorldCFrame = u228 * CFrame.Angles(0, val71.rot - math.pi / 6, 0) * cf76;
					val71.a1.WorldCFrame = u228 * CFrame.Angles(0, val71.rot + math.pi / 6, 0) * cf76;
				end
			end);
			task.wait(0.75);
			for _, val19 in pairs(u229) do
				val19.a0:Destroy();
				val19.a1:Destroy();
				val19.trail:Destroy();
			end
			u229 = nil;
			return true;
		end,
		paraboliccharge = function(p249, p250, _) -- lusterloot
			local v472 = p250[1];
			if not v472 then return end
			local v473 = p249.sprite or p249;
			local v474 = v473.cf * Vector3.new(0, v473.part.Size.Y * 0.15, v473.part.Size.Z * -0.5 + 1);
			local v475 = v472.sprite or v472;
			local v476 = v475.cf * Vector3.new(0, v475.part.Size.Y * 0.15, v475.part.Size.Z * -0.5 - 0);
			local cf79 = CFrame.new(v476, v474);
			local magnitude21 = (v474 - v476).magnitude;
			local table61 = {
				Color = ColorSequence.new(Color3.fromRGB(237, 241, 157)),
				Transparency = NumberSequence.new(0, 1),
				WidthScale = NumberSequence.new(0, 1),
				LightEmission = 1,
				Lifetime = 1.5
			};
			local Attachment76 = Instance.new("Attachment", workspace.Terrain);
			Attachment76.WorldCFrame = cf79;
			local Clone_ret194 = Particles.HitParticleRed:Clone();
			Clone_ret194.Color = ColorSequence.new(Color3.fromRGB(237, 241, 157), Color3.fromRGB(255, 255, 255));
			Clone_ret194.Lifetime = NumberRange.new(0.25, 0.5);
			Clone_ret194.Size = NumberSequence.new(10, 1);
			Clone_ret194.Enabled = false;
			Clone_ret194.Parent = Attachment76;
			local u239 = math.pi / 2;
			for index48 = 1, 12 do
				spawn(function()
					Clone_ret194:Emit(2);
					u13.makeSpiral(5, cf79 * CFrame.Angles(math.pi / 2, index48 * math.pi, 0), u239 * ({
						-1,
						1
					})[Random_new_ret:NextInteger(1, 2)], -magnitude21, 3, 1, TweenInfo.new(0.75, Enum.EasingStyle.Cubic), "Sphere", table61);
				end);
				task.wait(0.1);
			end
			return true;
		end,
		hurricane = function(p108, p109, _) -- mysticbreeze
			local v196 = p109[1];
			if not v196 then return end
			local v197 = p108.sprite or p108;
			local v198 = v197.part.CFrame * Vector3.new(0, v197.part.Size.Y * 0.15, v197.part.Size.Z * -0.5 - 0);
			local v199 = v196.sprite or v196;
			local v200 = v199.part.CFrame * Vector3.new(0, v199.part.Size.Y * 0.15, v199.part.Size.Z * -0.5 - 0);
			local vec3_9 = Vector3.new(v200.X, v198.Y, v200.Z);
			local u92 = u13.MaxYFOV(v200, v198);
			local cf26 = CFrame.new(v198, vec3_9);
			local u93 = vec3_9 - v198;
			local u94 = math.pi * 4;
			local u95 = 0.75;
			local table24 = {
				Color = ColorSequence.new(Color3.fromRGB(0, 200, 225)),
				Transparency = NumberSequence.new(0, 1),
				WidthScale = NumberSequence.new(1),
				LightEmission = 0.25,
				Lifetime = 0.2
			};
			local Attachment32 = Instance.new("Attachment", workspace.Terrain);
			Attachment32.WorldCFrame = cf26 + u93;
			local Clone_ret72 = Particles.Gust:Clone();
			Clone_ret72.Size = NumberSequence.new(5, 8);
			Clone_ret72.Color = ColorSequence.new(Color3.fromRGB(0, 200, 225));
			Clone_ret72.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.5, 0.5),
				NumberSequenceKeypoint.new(1, 1)
			});
			Clone_ret72.LightEmission = 0.2;
			Clone_ret72.Acceleration = Vector3.new(0, 30, 0);
			Clone_ret72.Lifetime = NumberRange.new(1.2, 1.5);
			Clone_ret72.Speed = NumberRange.new(7, 9);
			Clone_ret72.SpreadAngle = Vector2.new(360, 360);
			Clone_ret72.Enabled = false;
			Clone_ret72.Parent = Attachment32;
			for index15 = 1, 100 do
				spawn(function()
					u95 = index15 / 15 + 0.5;
					u13.makeSpiral(3, (cf26 + u93 - Vector3.new(0, u92 / 2, 0)) * CFrame.Angles(0, math.pi * 2 * Random_new_ret:NextNumber(), 0), u94 * ({
						-1,
						1
					})[Random_new_ret:NextInteger(1, 2)], u92, 8, u95, TweenInfo.new(0.75, Enum.EasingStyle.Cubic), "Grow", table24);
				end);
				if index15 % 2 == 0 then
					Clone_ret72:Emit(1);
				end
				u9("Shortquake",5)
				task.wait()
			end
			game.Debris:AddItem(Attachment32, Clone_ret72.Lifetime.Max);
			return true;
		end,
		peck = function(p72, p73, p74) -- peck
			local v120 = p73[1];
			if not v120 then return end
			local v121 = p72.sprite or p72;
			local v122 = v121.part.CFrame * Vector3.new(0, v121.part.Size.Y * 0.15, v121.part.Size.Z * -0.5 - 0);
			local v123 = v120.sprite or v120;
			local v124 = v123.part.CFrame * Vector3.new(0, v123.part.Size.Y * 0.15, v123.part.Size.Z * -0.5 - 0);
			local u61 = v124 - v122;
			local cf12 = CFrame.new(v122, v124);
			local Clone_ret45 = Misc.WavySpike:Clone();
			Clone_ret45.Color = Color3.fromRGB(170, 233, 255);
			Clone_ret45.Material = "Neon";
			Clone_ret45.Size = Vector3.new(1.4, 1.25, 2.8);
			Clone_ret45.Transparency = 0.5;
			Clone_ret45.CFrame = cf12;
			Clone_ret45.Parent = p74.scene;
			local table15 = {
				Color = ColorSequence.new(Color3.fromRGB(170, 233, 255)),
				Transparency = NumberSequence.new(0.25, 1),
				WidthScale = NumberSequence.new(1, 0.1),
				LightEmission = 0,
				Lifetime = 1,
				FaceCamera = true
			};
			local Clone_ret46 = Particles.SparkV2:Clone();
			Clone_ret46.SpreadAngle = Vector2.new(180, 180);
			Clone_ret46.Size = NumberSequence.new(0.1, 0);
			Clone_ret46.Color = ColorSequence.new(Color3.fromRGB(170, 233, 255));
			Clone_ret46.Transparency = NumberSequence.new(0, 1);
			Clone_ret46.Speed = NumberRange.new(6, 10);
			local Attachment19 = Instance.new("Attachment", workspace.Terrain);
			Attachment19.WorldCFrame = cf12 + u61;
			Clone_ret46.Acceleration = -u61.unit * 6;
			Clone_ret46.Enabled = false;
			Clone_ret46.Lifetime = NumberRange.new(0.9, 1.5);
			Clone_ret46.Parent = Attachment19;
			local Clone_ret47 = Particles.HitParticleBlue:Clone();
			Clone_ret47.Color = ColorSequence.new(Color3.fromRGB(170, 233, 255));
			Clone_ret47.Size = NumberSequence.new(0.25, 6);
			Clone_ret47.Transparency = NumberSequence.new(0, 1);
			Clone_ret47.Lifetime = NumberRange.new(0.25, 0.5);
			Clone_ret47.Enabled = false;
			Clone_ret47.Parent = Attachment19;
			game.Debris:AddItem(Attachment19, Clone_ret46.Lifetime.Max);
			u13.Tween(TweenInfo.new(0.25), true, function(p422)
				Clone_ret45.CFrame = cf12 + u61 * p422;
				u13.trailSwirl(Clone_ret45.CFrame, 0.25, 4, 0.2, math.pi * 3, table15);
			end);
			Clone_ret46:Emit(25);
			Clone_ret47:Emit(2);
			Clone_ret45:Destroy();
			return true;
		end,
		toxicspikes = function(pokemon, swap)
			spikes(pokemon, 'ToxicSpikes', 'Mulberry', swap)
		end,
		vinewhip = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Bright green')
			return 'sound'
		end,
		watergun = function(p251, p252, p253) -- spray
			local v477 = p252[1];
			if not v477 then return end
			local v478 = p251.sprite or p251;
			local v479 = v478.part.CFrame * Vector3.new(0, v478.part.Size.Y * 0.15, v478.part.Size.Z * -0.5 - 0);
			local v480 = v477.sprite or v477;
			local v481 = v480.part.CFrame * Vector3.new(0, v480.part.Size.Y * 0.15, v480.part.Size.Z * -0.5 - 0);
			local u240 = v481 - v479;
			local cf80 = CFrame.new(v479, v481);
			local Attachment77 = Instance.new("Attachment", workspace.Terrain);
			local Attachment78 = Instance.new("Attachment", workspace.Terrain);
			local u241 = Utilities.Create("Beam")({
				TextureSpeed = 3,
				Segments = 3,
				LightInfluence = 0,
				Transparency = NumberSequence.new(0.3),
				Color = ColorSequence.new(Color3.fromRGB(14, 191, 255)),
				Texture = "rbxassetid://1190623231",
				Width0 = 0.5,
				Width1 = 0.5,
				Attachment0 = Attachment77,
				Attachment1 = Attachment78,
				Parent = workspace.Terrain
			});
			Attachment77.WorldCFrame = cf80;
			Attachment78.WorldCFrame = cf80;
			spawn(function()
				for index100 = 1, 5 do
					local Clone_ret195 = Misc.ThinRing:Clone();
					Clone_ret195.Color = Color3.fromRGB(14, 191, 255);
					Clone_ret195.Transparency = 0.6;
					Clone_ret195.Material = "SmoothPlastic";
					Clone_ret195.CFrame = (cf80 + u240 * index100 / 5) * CFrame.Angles(math.pi / 2, 0, 0);
					Clone_ret195.Size = Vector3.new(2, 0.1, 2);
					Clone_ret195.Parent = p253.scene;
					u13.Tween(TweenInfo.new(0.25), false, function(p732)
						Clone_ret195.Size = Vector3.new(p732 * 3 + 2, 0.1, p732 * 3 + 2);
						Clone_ret195.Transparency = p732 * 0.4 + 0.6;
					end).Completed:Connect(function()
						Clone_ret195:Destroy();
					end);
					task.wait(0.05);
				end
			end);
			local Clone_ret196 = Particles.Splash:Clone();
			Clone_ret196.Speed = NumberRange.new(4, 6);
			Clone_ret196.Size = NumberSequence.new(0.8, 0.5);
			Clone_ret196.SpreadAngle = Vector2.new(45, 45);
			Clone_ret196.Lifetime = NumberRange.new(0.75, 1.2);
			Clone_ret196.EmissionDirection = "Back";
			Clone_ret196.Enabled = false;
			Clone_ret196.Parent = Attachment78;
			u13.Tween(TweenInfo.new(0.25), true, function(p524)
				Attachment78.WorldCFrame = cf80 + u240 * p524;
				u241.Width1 = p524 * 1.5 + 0.5;
				Clone_ret196:Emit(1);
			end);
			Clone_ret196:Emit(40);
			u13.Tween(TweenInfo.new(0.2), true, function(p525)
				Attachment77.WorldCFrame = cf80 + u240 * p525;
			end);
			local Clone_ret197 = Misc.ThinRing:Clone();
			Clone_ret197.Color = Color3.fromRGB(14, 191, 255);
			Clone_ret197.Transparency = 0.6;
			Clone_ret197.Material = "SmoothPlastic";
			Clone_ret197.CFrame = (cf80 + u240) * CFrame.Angles(math.pi / 2, 0, 0);
			Clone_ret197.Size = Vector3.new(4, 0.1, 4);
			Clone_ret197.Parent = p253.scene;
			u13.Tween(TweenInfo.new(0.25), false, function(p617)
				Clone_ret197.Size = Vector3.new(p617 * 9 + 4, 0.1, p617 * 9 + 4);
				Clone_ret197.Transparency = p617 * 0.4 + 0.6;
			end).Completed:Connect(function()
				Clone_ret197:Destroy();
			end);
			game.Debris:AddItem(Attachment78, Clone_ret196.Lifetime.Max);
			u241:Destroy();
			Attachment77:Destroy();
			return true;
		end,
		powdersnow = function(p222, p223, p224) -- sleetshot
			local v425 = p223[1];
			if not v425 then return end
			local v426 = p222.sprite or p222;
			local v427 = v426.part.CFrame * Vector3.new(0, v426.part.Size.Y * 0.15, v426.part.Size.Z * -0.5 - 0);
			local v428 = v425.sprite or v425;
			local u221 = v428.part.CFrame * Vector3.new(0, v428.part.Size.Y * 0.15, v428.part.Size.Z * -0.5 - 0);
			local _ = CFrame.new(v427, u221);
			local v429 = u221 - v427;
			local v430 = (v429.Magnitude * 2 / Vector3.new(0, -workspace.Gravity, 0).Magnitude) ^ 0.5;
			for index43 = 1, 9 do
				local v786 = (CFrame.new(v427, u221) * CFrame.new(Random_new_ret:NextInteger(-5, 5), Random_new_ret:NextInteger(8, 18), Random_new_ret:NextInteger(-3, -10)) + v429).p - v427;
				local vec3_15 = Vector3.new(0, -workspace.Gravity, 0);
				local Magnitude10 = v786.Magnitude;
				local Magnitude11 = vec3_15.Magnitude;
				local v787 = (Magnitude10 * 2 / Magnitude11) ^ 0.5;
				local v788 = (Magnitude11 * v786 - Magnitude10 * vec3_15) / (Magnitude11 * 2 * Magnitude10) ^ 0.5;
				local v789 = math.sqrt(Magnitude11 * 2 * Magnitude10 / 2) * 2 / Magnitude11;
				local v790 = v788 / (v789 / v787);
				local Clone_ret176 = Misc.MudSpatter:Clone();
				Clone_ret176.Color = Color3.fromRGB(90, 76, 66);
				local v791 = Random_new_ret:NextNumber() * 2;
				Clone_ret176.Size = Vector3.new(2, 0.1, 2) + Vector3.new(v791, 0, v791);
				local cf72 = CFrame.new(Vector3.new(), v790.unit);
				Clone_ret176.Anchored = false;
				Clone_ret176.Material = "Ice";
				Clone_ret176.Color = Color3.fromRGB(168, 255, 255);
				Clone_ret176.Trail.Color = ColorSequence.new(Color3.fromRGB(168, 255, 255));
				Clone_ret176.Velocity = v790;
				Clone_ret176.CFrame = cf72 + v427;
				Clone_ret176.Parent = p224.scene;
				game.Debris:AddItem(Clone_ret176, v789);
				delay(v787, function()
					local Attachment65 = Instance.new("Attachment", workspace.Terrain);
					Attachment65.WorldCFrame = CFrame.new(u221);
					local Clone_ret177 = Particles.MudSpatter:Clone();
					Clone_ret177.Parent = Attachment65;
					Clone_ret177.LightEmission = 0.2;
					Clone_ret177.Texture = "http://www.roblox.com/asset/?id=2464867803";
					Clone_ret177.Color = ColorSequence.new(Color3.fromRGB(168, 255, 255));
					Clone_ret177:Emit(10);
					game.Debris:AddItem(Attachment65, 1);
				end);
				task.wait();
			end
			task.wait(v430);
			return true;
		end,
		watershuriken = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			local s = create 'Part' {
				Anchored = true,
				CanCollide = false,
				BrickColor = BrickColor.new('Cyan'),
				Reflectance = .4,
				Transparency = .3,
				Size = Vector3.new(1, 1, 1),
				Parent = workspace,

				create 'SpecialMesh' {
					MeshType = Enum.MeshType.FileMesh,
					MeshId = 'rbxassetid://11376946',
					Scale = Vector3.new(1.6, 1.6, 1.6)
				}
			}
			local f = targetPoint(pokemon)
			local d = targetPoint(target)-f
			local cf = CFrame.new(f, f+d) * CFrame.Angles(0, 0, -.8)
			Tween(.5, nil, function(a)
				s.CFrame = (cf+d*a) * CFrame.Angles(0, -10*a, 0)
			end)
			s:Destroy()
			return true
		end,
		xscissor = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Br. yellowish green', 2)--'Moss'
			return 'sound'
		end,

		-- Z-Moves :
		bloomdoom = function(pokemon, targets, move)
			local pos1 = nil;
			local pos2 = nil;
			local target = targets[1];
			if not target then
				return;
			end;
			local sprite = pokemon.sprite;
			local from = targetPoint(pokemon, 2);
			local to = targetPoint(target, 0.5);
			local part1 = create("Part")({
				Anchored = true, 
				CanCollide = false, 
				CFrame = move.CoordinateFrame2 + Vector3.new(0, -3, 0), 
				Parent = workspace,
				create("SpecialMesh")({
					MeshType = Enum.MeshType.FileMesh, 
					MeshId = "rbxassetid://20329976", 
					Scale = Vector3.new(0.2, 0.2, 0.2)
				})
			});
			local posi = sprite.part.Position;
			local py = sprite.part.Size.Y / 2;
			local scene = {};
			for i = 1, 6 do
				local part2 = create("Part")({
					Transparency = 1, 
					Anchored = true, 
					CanCollide = false, 
					Size = Vector3.new(1, 1, 1), 
					CFrame = CFrame.new(posi + Vector3.new(1.5 * math.cos(math.pi / 3 * i), py * 0.5, 1.5 * math.sin(math.pi / 3 * i)), posi + Vector3.new(0, py * 0.5, 0)), 
					Parent = workspace
				});
				create("Trail")({
					Attachment0 = create("Attachment")({
						CFrame = CFrame.new(-0.3, 0.3, -0.3), 
						Parent = part2
					}), 
					Attachment1 = create("Attachment")({
						CFrame = CFrame.new(0.3, -0.3, 0.3), 
						Parent = part2
					}), 
					Color = ColorSequence.new(Color3.fromRGB(58, 173, 98), Color3.fromRGB(154, 212, 174)), 
					Transparency = NumberSequence.new(0.5, 1), 
					Lifetime = 1, 
					Parent = part2
				});
				scene[i] = part2;
			end;
			spawn(function()
				Tween(1, nil, function(a)
					for ab, ba in pairs(scene) do
						local z1 = math.pi / 3 * ab + 5 * a;
						local z2 = 1.5 + math.sin(a * math.pi);
						local z3 = posi + Vector3.new(z2 * math.cos(z1), py * (0.5 - a), z2 * math.sin(z1));
						ba.CFrame = CFrame.new(z3, Vector3.new(posi.x, z3.Y, posi.Z));
					end;
				end);
			end);
			task.wait(0.3);
			local model = Instance.new("Model", workspace);
			local v1 = sprite.cf + Vector3.new(0, -(sprite.spriteData.inAir or 0), 0);
			local v2 = target.sprite.cf + Vector3.new(0, -(target.sprite.spriteData.inAir or 0), 0);
			local v0 = CFrame.new(v1.p, v2.p);
			local clr = { "Alder", "Carnation pink", "Persimmon", "Daisy orange", "Pastel Blue" };
			local z3ro = 12 - 1; --1 -1
			while true do
				local n3ber = nil;
				for s = 1, 2 do
					pos1 = v0;
					n3ber = z3ro;
					pos2 = model;
					spawn(function()
						local flower = _p.storage.Models.Misc.Flower:Clone();
						local main = flower.Main;
						local clrc = BrickColor.new(clr[math.random(#clr)]);
						for bc, cb in pairs(flower:GetChildren()) do
							if cb:IsA("BasePart") and cb ~= main then
								cb.BrickColor = clrc;
							end;
						end;
						Utilities.MoveModel(main, pos1 * CFrame.Angles(0, -0.7 + 2.6 * math.random(), 0) * CFrame.new(0, 0, -n3ber * 1.2 + math.random()) * CFrame.Angles(0, math.random(), 0) + Vector3.new(0, 0.05, 0));
						flower.Parent = pos2;
						local int = 1;
						Tween(0.5, nil, function(b)
							local ps = 0.2 + 0.4 * b;
							Utilities.ScaleModel(main, ps / int);
							int = ps;
						end);
						flower:Destroy()
						main:Destroy()
					end);
				end;
				task.wait(0.1);
				if 0 <= 1 then
					if not (n3ber < 10) then
						break;
					end;
				elseif not (n3ber > 10) then
					break;
				end;			
			end;
			local part3 = create("Part")({
				BrickColor = BrickColor.new("Bright green"), 
				Material = Enum.Material.Neon, 
				Anchored = true, 
				CanCollide = false, 
				Shape = Enum.PartType.Cylinder, 
				Size = Vector3.new(15, 3, 3), 
				Parent = workspace
			});
			local _xy = CFrame.Angles(0, 0, math.pi / 2);
			Tween(1, nil, function(c)
				part3.CFrame = pos1 * _xy + Vector3.new(0, c * 30 - 15, 0);
			end);
			task.wait(1);
			part3.Size = Vector3.new(15, 6, 6);
			Tween(0.5, nil, function(d)
				part3.CFrame = v2 * _xy + Vector3.new(0, 22.5 - 15 * d, 0);
			end);
			local inner = _p.storage.Models.Misc.Mega.InnerEnergy:Clone();
			Utilities.ScaleModel(inner.Hinge, 0.35);
			local i_xy = inner.Hinge.CFrame * CFrame.Angles(0, 0, math.pi / 2):inverse() * inner.EnergyPart.CFrame;
			local outer = _p.storage.Models.Misc.Mega.OuterEnergy:Clone();
			Utilities.ScaleModel(outer.Hinge, 0.35);
			inner.EnergyPart.BrickColor = BrickColor.new("Medium green");
			outer.EnergyPart.BrickColor = BrickColor.new("Sand green");
			inner.Parent = workspace;
			outer.Parent = workspace;
			local cc = workspace.CurrentCamera;
			local cfr = cc.CFrame;
			local v3 = Vector3.new(0, -1.5, 0);
			local c_f = outer.Hinge.CFrame * CFrame.Angles(0, 0, math.pi / 2):inverse() * outer.EnergyPart.CFrame;
			spawn(function()
				Tween(3, nil, function(e)
					local r1 = math.random() * 0.5;
					local r2 = math.random() * math.pi * 2;
					cc.CFrame = cfr * CFrame.new(r1 * math.cos(r2), r1 * math.sin(r2), 0);
					inner.EnergyPart.CFrame = v2 * CFrame.Angles(0, 10 * e, 0) * i_xy + v3;
					outer.EnergyPart.CFrame = v2 * CFrame.Angles(0, -10 * e, 0) * c_f + v3;
				end);
			end);
			task.wait(2.5);
			Utilities.FadeOut(0.5, Color3.new(1, 1, 1));
			task.wait(0.3);
			cc.CFrame = cfr;
			pos2:Destroy();
			for cd, dc in pairs(scene) do
				dc:Destroy();
			end;
			part1:Destroy();
			inner:Destroy();
			outer:Destroy();
			part3:Destroy();
			Utilities.FadeIn(0.5);
			return true;
		end,

		devastatingdrake = function(pokemon, targets, move)
			local target = targets[1];
			if not target then
				return true;
			end;
			local dif = targetPoint(target) - targetPoint(pokemon)
			local cfr = target.sprite.part.CFrame
			local cfp = cfr - cfr.p
			local sprite = pokemon.sprite
			if sprite.spriteData.inAir then
			end
			local tair = target.sprite.spriteData.inAir or 0
			_p.DataManager:preload("Image", 148101819, 879747500)
			local model = Instance.new("Model", workspace)
			local scene = {}
			for ab, ba in pairs({ { 94257616, "Head" }, { 94257586, "Body" }, { 94257664, "RWing" }, { 94257635, "LWing" } }) do
				scene[ba[2]] = create("Part")({
					Anchored = true, 
					CanCollide = false, 
					CFrame = move.CoordinateFrame2 + Vector3.new(0, -4, 0), 
					Parent = model,
					create("SpecialMesh")({
						MeshType = Enum.MeshType.FileMesh, 
						MeshId = "rbxassetid://" .. ba[1], 
						TextureId = "rbxassetid://94257533", 
						Scale = Vector3.new(1.2, 1.2, 1.2), 
						VertexColor = Vector3.new(1, 0.5, 1)
					})
				})
			end
			local cf1 = CFrame.new(0, -0.272, 1, 1, 0, 0, 0, 0.928, 0.372, 0, -0.372, 0.928)
			local cf2 = CFrame.new(0, 0.686, -1.786, 1, 0, 0, 0, 0.931, -0.364, 0, 0.364, 0.931)
			local cf3 = CFrame.new(0.164, 0.427, -0.919, 1, 0, 0, 0, 0.941, -0.339, 0, 0.339, 0.941)
			local cf4 = CFrame.new(-0.164, 0.427, -0.919, 1, 0, 0, 0, 0.941, -0.339, 0, 0.339, 0.941)
			local cf5 = CFrame.new(1.314, 0.587, -0.25, 1, 0, 0, 0, 0.819, 0.574, 0, -0.574, 0.819)
			local cf6 = CFrame.new(-1.314, 0.587, -0.25, 1, 0, 0, 0, 0.819, 0.574, 0, -0.574, 0.819)
			local scene2 = {}
			for i = 1, 6 do
				local part1 = create("Part")({
					Transparency = 1, 
					Anchored = true, 
					CanCollide = false, 
					Size = Vector3.new(1, 1, 1), 
					Parent = workspace
				})
				create("Trail")({
					Attachment0 = create("Attachment")({
						CFrame = CFrame.new(-0.3, 0.3, -0.3), 
						Parent = part1
					}), 
					Attachment1 = create("Attachment")({
						CFrame = CFrame.new(0.3, -0.3, 0.3), 
						Parent = part1
					}), 
					Color = ColorSequence.new(Color3.fromRGB(174, 59, 197), Color3.fromRGB(252, 96, 255)), 
					Transparency = NumberSequence.new(0.5, 1), 
					Lifetime = 1, 
					Parent = part1
				})
				scene2[i] = part1
			end
			local Position = sprite.part.Position
			local y = sprite.part.Size.Y
			Tween(1, nil, function(a)
				for bc, cb in pairs(scene2) do
					local bca = math.pi / 3 * bc + 5 * a
					local npos = Position + Vector3.new(2 * math.cos(bca), y * (0.5 - a), 2 * math.sin(bca))
					cb.CFrame = CFrame.new(npos, Vector3.new(Position.x, npos.Y, Position.Z))
				end
			end)
			create("ParticleEmitter")({
				Texture = "rbxassetid://148101819", 
				Color = ColorSequence.new(Color3.fromRGB(194, 135, 216)), 
				Transparency = NumberSequence.new(0.5, 1), 
				Size = NumberSequence.new(0.25), 
				Acceleration = Vector3.new(), 
				LockedToPart = false, 
				Lifetime = NumberRange.new(1), 
				Rate = 50, 
				Rotation = NumberRange.new(0, 360), 
				Speed = NumberRange.new(0), 
				Parent = scene.Body
			})
			local cfn1 = CFrame.new()
			local cfn2 = CFrame.new()
			local cfn3 = CFrame.new()
			local unt = (sprite.part.Position - target.sprite.part.Position) * Vector3.new(1, 0, 1).unit
			local v3c = Vector3.new(0, -1, 0)
			local cros = unt:Cross(v3c)
			local ppo = sprite.part.Position
			local epic = CFrame.new(ppo.X, ppo.Y, ppo.Z, cros.X, unt.X, v3c.X, cros.Y, unt.Y, v3c.Y, cros.Z, unt.Z, v3c.Z)
			local function dragon()
				local cnf = cfn1 * cf1
				scene.Body.CFrame = cnf
				scene.Head.CFrame = cnf * cf2
				scene.RWing.CFrame = cnf * cf3 * cfn2 * cf5
				scene.LWing.CFrame = cnf * cf4 * cfn3 * cf6
			end
			Tween(0.7, nil, function(b)
				cfn1 = epic + Vector3.new(0, 10 * b, 0);
				dragon()
			end)
			task.wait(0.5)
			local ptpo = (sprite.part.Position + target.sprite.part.Position) / 2
			local ptpy = ptpo + Vector3.new(0, move.CoordinateFrame2.y + 2.5 - ptpo.Y, 0)
			local ang1 = CFrame.Angles(0, -1.4, 0) * CFrame.Angles(-1.1, 0, 0)
			local ang2 = CFrame.Angles(0, 1.4, 0) * CFrame.Angles(-1.1, 0, 0)
			cfn2 = ang1
			cfn3 = ang2
			local s1 = select(2, Utilities.lerpCFrame(ang1, CFrame.new()))
			local s2 = select(2, Utilities.lerpCFrame(ang2, CFrame.new()))
			local timing = Utilities.Timing.easeOutCubic(0.2)
			Tween(0.9, nil, function(c)
				local ch = math.pi * c
				local sch = math.sin(ch)
				local cch = math.cos(ch)
				local psch = ptpy - cros * (8 * cch - 4) + Vector3.new(0, 6 * (1 - sch), 0)
				local crch = cros * sch + Vector3.new(0, -cch, 0).unit
				local crcr = unt:Cross(crch)
				cfn1 = CFrame.new(psch.X, psch.Y, psch.Z, unt.X, crcr.X, -crch.X, unt.Y, crcr.Y, -crch.Y, unt.Z, crcr.Z, -crch.Z)
				if c > 0.3 then
					if c < 0.6 then
						local cx03 = (c - 0.3) / 0.3
						cfn2 = s1(cx03)
						cfn3 = s2(cx03)
					elseif c < 0.8 then
						local tc16 = 1 - timing(c - 0.6)
						cfn2 = s1(tc16)
						cfn3 = s2(tc16)
					else
						cfn2 = ang1
						cfn3 = ang2
					end
				end
				dragon()
			end)
			cfn2 = ang1
			cfn3 = ang2
			task.wait(0.5)
			local psti = target.sprite.part.Position
			epic = CFrame.new(psti.X, psti.Y, psti.Z, cros.X, -unt.X, -v3c.X, cros.Y, -unt.Y, -v3c.Y, cros.Z, -unt.Z, -v3c.Z)
			spawn(function()
				Tween(0.6, nil, function(d)
					cfn1 = epic * CFrame.Angles(0, 0, 7 * d) + Vector3.new(0, 10 - 16 * d, 0)
					dragon()
				end)
			end)
			task.wait(0.5)
			local part2 = create("Part")({
				BrickColor = BrickColor.new("Alder"), 
				Material = Enum.Material.Neon, 
				Anchored = true, 
				CanCollide = false, 
				TopSurface = Enum.SurfaceType.Smooth, 
				BottomSurface = Enum.SurfaceType.Smooth, 
				Shape = Enum.PartType.Ball, 
				Parent = workspace
			})
			local tvar = target.sprite.cf + Vector3.new(0, -tair, 0)
			spawn(function()
				local clr = BrickColor.new("Lilac").Color
				local val
				for n = 1, 10 do
					spawn(function()
						local r1 = math.random() * math.pi * 2
						local r2 = math.random() * math.pi / 2
						local image = {
							Color = clr, 
							Image = 879747500, 
							Lifetime = 0.7, 
							Size = 1, 
							Position = tvar.p + part2.Size.Y / 2 * Vector3.new(math.cos(r1) * math.cos(r2), math.sin(r2), math.sin(r1) * math.cos(r2)), 
							Rotation = math.random() * 360
						}
						if math.random(2) == 1 then
							val = 1
						else
							val = -1
						end;
						image.RotVelocity = 100 * val
						image.Acceleration = false
						function image.OnUpdate(df, fd)
							if df > 0.7 then
								fd.BillboardGui.ImageLabel.ImageTransparency = 0.4 + 2 * (df - 0.7)
							end
						end
						_p.Particles:new(image)
					end)
					task.wait(0.1)
				end
			end)
			local tsy = math.max(7, target.sprite.part.Size.Y * 2)
			Tween(0.5, "easeOutCubic", function(s)
				target.sprite.offset = Vector3.new(0, -tair * s, 0)
				local ts2y = tsy * s
				part2.Size = Vector3.new(ts2y, ts2y, ts2y)
				part2.CFrame = tvar
			end)
			spawn(function()
				Tween(0.5, nil, function(t)
					local ttsy = tsy + 0.5 * t
					part2.Size = Vector3.new(ttsy, ttsy, ttsy)
					part2.CFrame = tvar
				end)
				Tween(0.5, nil, function(q)
					local tsyq = tsy + 0.5 + 4 * q
					part2.Size = Vector3.new(tsyq, tsyq, tsyq)
					part2.CFrame = tvar
				end)
			end)
			local cc = workspace.CurrentCamera
			delay(0.5, function()
				Utilities.FadeOut(0.5, Color3.new(1, 1, 1))
			end)
			local cfcc = cc.CFrame
			Tween(1, nil, function(p)
				local rp1 = math.random() * p * 0.5
				local rp2 = math.random() * math.pi * 2
				cc.CFrame = cfcc * CFrame.new(rp1 * math.cos(rp2), rp1 * math.sin(rp2), 0)
			end)
			task.wait(0.3)
			part2:Destroy()
			cc.CFrame = cfcc
			model:Destroy()
			for xx, xy in pairs(scene2) do
				xy:Destroy()
			end
			Utilities.FadeIn(0.5)
			return true
		end, 

		infernooverdrive = function (pokemon, targets, move)
			local target = targets[1];
			if not target then
				return;
			end;
			local sprite = pokemon.sprite
			local from = targetPoint(pokemon, 2)
			local to = targetPoint(target, 0.5) - from
			local model = Instance.new("Model", workspace)
			_p.DataManager:preload("Image", 879747500)
			for ab, ba in pairs({ 165709404, 212966179 }) do
				local part1 = create("Part")({
					Anchored = true, 
					CanCollide = false, 
					CFrame = move.CoordinateFrame2 + Vector3.new(0, -3, 0), 
					Parent = model,
					create("SpecialMesh")({
						MeshType = Enum.MeshType.FileMesh, 
						MeshId = "rbxassetid://" .. ba, 
						Scale = Vector3.new(0.2, 0.2, 0.2)
					})
				})
			end
			local cfr = target.sprite.part.CFrame
			local cfrp = cfr - cfr.p
			local scene = {}
			for i = 1, 6 do
				local part2 = create("Part")({
					Transparency = 1, 
					Anchored = true, 
					CanCollide = false, 
					Size = Vector3.new(1, 1, 1), 
					CFrame = cfrp * CFrame.Angles(0, 0, math.pi / 3 * i) * CFrame.new(0, 3, 0) + from, 
					Parent = workspace
				})
				create("Trail")({
					Attachment0 = create("Attachment")({
						CFrame = CFrame.new(-0.3, 0.3, -0.3), 
						Parent = part2
					}), 
					Attachment1 = create("Attachment")({
						CFrame = CFrame.new(0.3, -0.3, 0.3), 
						Parent = part2
					}), 
					Color = ColorSequence.new(Color3.new(0.9, 0.1, 0), Color3.new(1, 1, 0)), 
					Transparency = NumberSequence.new(0.5, 1), 
					Lifetime = 1, 
					Parent = part2
				})
				scene[i] = part2;
			end
			local part3 = create("Part")({
				BrickColor = BrickColor.new("Bright orange"), 
				Material = Enum.Material.Neon, 
				Anchored = true, 
				CanCollide = false, 
				TopSurface = Enum.SurfaceType.Smooth, 
				BottomSurface = Enum.SurfaceType.Smooth, 
				Shape = Enum.PartType.Ball, 
				Parent = workspace
			})
			local y = sprite.part.Size.Y
			Tween(1, nil, function(a)
				part3.Size = Vector3.new(a, a, a) * y
				part3.CFrame = CFrame.new(from)
				for bc, cb in pairs(scene) do
					cb.CFrame = cfrp * CFrame.Angles(0, 0, math.pi / 3 * bc + 6 * a) * CFrame.new(0, 2 * (1 - a) + 1, 0) + from
				end
			end)
			local unt = to * Vector3.new(1, 0, 1).unit
			local air = sprite.spriteData.inAir or 0
			Tween(0.6, nil, function(b)
				sprite.offset = unt * -2 * b + Vector3.new(0, math.sin(b * math.pi) - air * b, 0)
			end)
			local air2 = target.sprite.spriteData.inAir or 0
			local y2 = target.sprite.part.Size.Y
			local signal = Utilities.Signal()
			local y3 = sprite.part.Size.Y
			local part4 = create("Part")({
				BrickColor = BrickColor.new("CGA brown"), 
				Anchored = true, 
				CanCollide = false, 
				Size = Vector3.new(1, 1, 1), 
				Parent = workspace,
				create("SpecialMesh")({
					MeshType = Enum.MeshType.FileMesh, 
					MeshId = "rbxassetid://212966179", 
					Scale = Vector3.new(1.1, 1.8, 1.1) * y3
				})
			})
			local part5 = create("Part")({
				BrickColor = BrickColor.new("CGA brown"), 
				Transparency = 0.5, 
				Anchored = true, 
				CanCollide = false, 
				Size = Vector3.new(1, 1, 1), 
				Parent = workspace,
				create("SpecialMesh")({
					MeshType = Enum.MeshType.FileMesh, 
					MeshId = "rbxassetid://165709404", 
					Scale = Vector3.new(2, 2, 2) * y3
				})
			})
			local v3c = sprite.cf.p + Vector3.new(0, y3 / 2, 0)
			local ang = CFrame.new(v3c, v3c + unt) * CFrame.Angles(-math.pi / 2, 0, 0)
			local pos = ang * CFrame.new(0, -0.48 * y3, 0) * CFrame.Angles(math.pi, 0, 0)
			local mve = false
			local magn = to.magnitude
			local function ball()
				local part6 = create("Part")({
					BrickColor = BrickColor.new("Bright orange"), 
					Material = Enum.Material.Neon, 
					Anchored = true, 
					CanCollide = false, 
					TopSurface = Enum.SurfaceType.Smooth, 
					BottomSurface = Enum.SurfaceType.Smooth, 
					Shape = Enum.PartType.Ball, 
					Parent = workspace
				})
				local npos = target.sprite.cf + Vector3.new(0, -air2, 0)
				spawn(function()
					local clr = BrickColor.new("Bright yellow").Color
					local o
					for n = 1, 10 do
						spawn(function()
							local pi1 = math.random() * math.pi * 2;
							local pi2 = math.random() * math.pi / 2;
							local fire = {
								Color = clr, 
								Image = 879747500, 
								Lifetime = 0.7, 
								Size = 1, 
								Position = npos.p + part6.Size.Y / 2 * Vector3.new(math.cos(pi1) * math.cos(pi2), math.sin(pi2), math.sin(pi1) * math.cos(pi2)), 
								Rotation = math.random() * 360
							}
							if math.random(2) == 1 then
								o = 1
							else
								o = -1
							end
							fire.RotVelocity = 100 * o
							fire.Acceleration = false
							function fire.OnUpdate(c, d)
								if c > 0.7 then
									d.BillboardGui.ImageLabel.ImageTransparency = 0.4 + 2 * (c - 0.7)
								end
							end
							_p.Particles:new(fire)
						end)
						task.wait(0.1)
					end
				end)
				local mx = math.max(7, y2 * 2)
				Tween(0.5, "easeOutCubic", function(e)
					target.sprite.offset = Vector3.new(0, -air2 * e, 0)
					local mxe = mx * e
					part6.Size = Vector3.new(mxe, mxe, mxe)
					part6.CFrame = npos
				end)
				spawn(function()
					Tween(0.5, nil, function(f)
						local mxf = mx + 0.5 * f
						part6.Size = Vector3.new(mxf, mxf, mxf)
						part6.CFrame = npos
					end)
					Tween(0.5, nil, function(g)
						local mxg = mx + 0.5 + 4 * g
						part6.Size = Vector3.new(mxg, mxg, mxg)
						part6.CFrame = npos
					end)
				end)
				local cc = workspace.CurrentCamera
				delay(0.5, function()
					Utilities.FadeOut(0.5, Color3.new(1, 1, 1))
				end)
				local cfcc = cc.CFrame
				Tween(1, nil, function(h)
					local r1 = math.random() * h * 0.5
					local r2 = math.random() * math.pi * 2
					cc.CFrame = cfcc * CFrame.new(r1 * math.cos(r2), r1 * math.sin(r2), 0)
				end)
				task.wait(0.3)
				part6:Destroy()
				cc.CFrame = cfcc
				signal:fire()
			end
			Tween(1, nil, function(qr, rq)
				local req = 70 * rq * rq - 2 + 5 * rq
				local ureq = unt * req + Vector3.new(0, -air, 0)
				sprite.offset = ureq
				part4.CFrame = ang + ureq
				part5.CFrame = pos + ureq
				local mrq = math.min(1, rq * 3)
				part4.Transparency = 1 - 0.2 * mrq
				part5.Transparency = 1 - 0.5 * mrq
				if req > 2 then
					part3.CFrame = CFrame.new(from + unt * (req - 2))
				end
				if not mve and magn <= req then
					mve = true
					spawn(ball)
				end
			end)
			model:Destroy()
			signal:wait()
			part3:Destroy()
			for dx, xd in pairs(scene) do
				xd:Destroy()
			end;
			sprite.offset = Vector3.new()
			target.offset = Vector3.new()
			Utilities.FadeIn(0.5)
			return true
		end,
		savagespinout = function(pokemon, targets, move)
			local scene = nil
			local target = targets[1];
			if not target then
				return true;
			end;
			local from = targetPoint(pokemon)
			local to = targetPoint(target)
			local dif = to - from
			local cfr = target.sprite.part.CFrame
			local cfp = cfr - cfr.p
			local sprite = pokemon.sprite
			local part1 = create("Part")({
				Anchored = true, 
				CanCollide = false, 
				CFrame = move.CoordinateFrame2 + Vector3.new(0, -3, 0), 
				Parent = workspace,
				create("SpecialMesh")({
					MeshType = Enum.MeshType.FileMesh, 
					MeshId = "rbxassetid://928522767", 
					TextureId = "rbxassetid://928525574", 
					Scale = Vector3.new(0.02, 0.02, 0.02)
				})
			})
			local part2 = create("Part")({
				Anchored = true, 
				CanCollide = false, 
				CFrame = part1.CFrame, 
				Parent = workspace,
				create("SpecialMesh")({
					MeshType = Enum.MeshType.FileMesh, 
					MeshId = "rbxassetid://1290033", 
					Scale = Vector3.new(0.2, 0.2, 0.2)
				})
			})
			local vn = Vector3.new()
			local tair = target.sprite.spriteData.inAir or 0
			spawn(function()
				Tween(0.78, nil, function(a)
					vn = Vector3.new(0, -tair * a, 0)
					target.sprite.offset = vn
				end)
			end)
			for i = 1, 15 do
				scene = from
				spawn(function()
					local tcp = to + cfp * Vector3.new((math.random() - 0.5) * target.sprite.part.Size.X, (math.random() - 0.5) * target.sprite.part.Size.Y, 0) + vn
					local magn = (tcp - scene).magnitude
					local part3 = create("Part")({
						Anchored = true, 
						CanCollide = false, 
						BrickColor = BrickColor.new("Pearl"), 
						TopSurface = Enum.SurfaceType.Smooth, 
						BottomSurface = Enum.SurfaceType.Smooth, 
						Parent = workspace
					})
					local sct = CFrame.new(scene, tcp)
					local nma = magn + 2.6
					Tween(0.5, nil, function(b)
						local nmb = nma * b
						if magn < nmb then
							part3.Size = Vector3.new(0.05, 0.05, nma - nmb)
							part3.CFrame = sct * CFrame.new(0, 0, -magn - (nma - nmb) / 2)
							return
						end
						if nmb < 2.6 then
							part3.Size = Vector3.new(0.05, 0.05, nmb)
							part3.CFrame = sct * CFrame.new(0, 0, nmb / -2)
							return
						end
						part3.Size = Vector3.new(0.05, 0.05, 2.6)
						part3.CFrame = sct * CFrame.new(0, 0, -nmb + 1)
					end)
					part3:Destroy()
				end)
				task.wait(0.06)
			end
			part1.CFrame = target.sprite.part.CFrame
			Tween(0.6, nil, function(c)
				local c3 = 0.05 * c
				part1.Mesh.Scale = Vector3.new(c3, c3, c3)
			end)
			local spriteLabel = target.sprite.animation.spriteLabel
			Tween(0.3, nil, function(d)
				local de = 1 - d * 0.55
				spriteLabel.Size = UDim2.new(de, 0, de, 0)
				spriteLabel.Position = UDim2.new(0.5 - de / 2, 0, 0.5 - de / 2, 0)
			end)
			spriteLabel.Visible = false
			local Position = part1.Position
			local ps = Position - scene
			local part4 = create("Part")({
				Anchored = true, 
				CanCollide = false, 
				BrickColor = BrickColor.new("Pearl"), 
				TopSurface = Enum.SurfaceType.Smooth, 
				BottomSurface = Enum.SurfaceType.Smooth, 
				Parent = workspace
			})
			local pmag = ps.magnitude
			local csp = CFrame.new(scene, Position)
			Tween(0.4, nil, function(e)
				part4.Size = Vector3.new(0.2, 0.2, pmag * e)
				part4.CFrame = csp + ps * e * 0.5
			end)
			local pcf = CFrame.new(Position, Position + ps):inverse() * part1.CFrame
			spawn(function()
				local scene2 = {}
				for n = 1, 5 do
					scene2[n] = part4:Clone()
					scene2[n].Parent = workspace
				end
				scene2[6] = part4
				local function bug(f)
					local posi = part1.Position
					local psc = (posi - scene).magnitude
					local show = scene
					local spcf = CFrame.new(scene, posi)
					local upVec = spcf.upVector;
					local lookVec = spcf.lookVector;
					for ab, ba in pairs(scene2) do
						local sVec = scene + lookVec * psc / 6 * ab + upVec * f * math.sin(math.pi / 6 * ab)
						ba.Size = Vector3.new(0.2, 0.2, (show - sVec).magnitude)
						ba.CFrame = CFrame.new((show + sVec) / 2, sVec)
						show = sVec
					end
				end
				Tween(0.5, nil, function(g)
					bug(g)
				end)
				Tween(0.7, nil, function(h)
					bug(1 - 2 * h)
				end)
				Tween(0.4, nil, function(t)
					bug(-1 + t)
				end)
				for bc, cb in pairs(scene2) do
					cb:Destroy()
				end
			end)
			task.wait(0.4)
			Tween(0.8, "easeInOutQuad", function(m)
				part1.CFrame = csp * CFrame.Angles(1.2 * m, 0, 0) * CFrame.new(0, 0, -pmag) * pcf
			end)
			Tween(0.4, "easeInQuad", function(n)
				part1.CFrame = csp * CFrame.Angles(1.2 * (1 - n), 0, 0) * CFrame.new(0, 0, -pmag) * pcf
			end)
			local model = create("Model")({
				Parent = workspace
			})
			for s = 1, 12 do
				local part5 = create("Part")({
					Anchored = true, 
					CanCollide = false, 
					BrickColor = BrickColor.new("Dirt brown"), 
					CFrame = move.CoordinateFrame2 * CFrame.Angles(math.random() * 6, math.random() * 6, math.random() * 6) + Vector3.new((1.2 + 0.3 * math.random()) * math.sin(0.53 * s), -0.3, (1.2 + 0.3 * math.random()) * math.cos(0.53 * s)), 
					Parent = model,
					create("SpecialMesh")({
						MeshType = Enum.MeshType.FileMesh, 
						MeshId = "rbxassetid://1290033", 
						Scale = Vector3.new(0.8, 0.8, 0.8)
					})
				})
			end
			spawn(function()
				local cc = workspace.CurrentCamera
				local cfc = cc.CFrame
				Tween(1, nil, function(z)
					local z1 = z * 10 % 1
					local z2 
					if z1 < 0.25 then
						z2 = -z1 * 4
					elseif z1 < 0.75 then
						z2 = -1 + (z1 - 0.25) * 4
					else
						z2 = 1 - (z1 - 0.75) * 4
					end
				end)
			end)
			local unt = dif * Vector3.new(1, 0, 1).unit
			local air = sprite.spriteData.inAir or 0
			Tween(0.6, nil, function(l)
				sprite.offset = unt * -2 * l + Vector3.new(0, math.sin(l * math.pi) - air * l, 0)
			end)
			local signal = Utilities.Signal()
			local mve = false
			local dmag = dif.magnitude
			local function pist()
				signal:fire()
				local crcf = CFrame.new(part1.Position, part1.Position + unt:Cross(Vector3.new(0, 1, 0)))
				local inv = crcf:inverse() * part1.CFrame
				Tween(0.6, nil, function(x)
					if not part1.Parent then
						return false
					end
					part1.CFrame = crcf * CFrame.Angles(0, 0, 10 * x) * inv + unt * x * 30 + Vector3.new(0, x * 12, 0)
				end)
			end
			spawn(function()
				Tween(1, nil, function(xx, xy)
					if not part1.Parent then
						return false
					end
					local v100 = 70 * xy * xy - 2 + 5 * xy
					sprite.offset = unt * v100 + Vector3.new(0, -air, 0)
					if not mve and dmag <= v100 then
						mve = true
						spawn(pist)
					end
				end)
			end)
			signal:wait()
			Utilities.FadeOut(0.5, Color3.new(1, 1, 1))
			model:Destroy()
			part1:Destroy()
			spriteLabel.Size = UDim2.new(1, 0, 1, 0)
			spriteLabel.Position = UDim2.new(0, 0, 0, 0)
			spriteLabel.Visible = true
			sprite.offset = Vector3.new()
			target.sprite.offset = Vector3.new()
			Utilities.FadeIn(0.5)
			return true
		end, 

		subzeroslammer = function(p37, p38, p39)
			local u36 = nil
			local v101 = p38[1]
			if not v101 then
				return true
			end
			local v102 = targetPoint(p37)
			local v103 = targetPoint(v101)
			local v104 = v103 - v102
			local CFrame_105 = v101.sprite.part.CFrame
			local v106 = CFrame_105 - CFrame_105.p
			local sprite_107 = p37.sprite
			local v108 = create("Part")({
				Anchored = true, 
				CanCollide = false, 
				CFrame = p39.CoordinateFrame2 + Vector3.new(0, -3, 0), 
				Parent = workspace,
				create("SpecialMesh")({
					MeshType = Enum.MeshType.FileMesh, 
					MeshId = "rbxassetid://818652045", 
					Scale = Vector3.new(0.05, 0.05, 0.05)
				})
			})
			local Ambient_37 = Lighting.Ambient
			local OutdoorAmbient_38 = Lighting.OutdoorAmbient
			local ColorShift_Bottom_39 = Lighting.ColorShift_Bottom
			local ColorShift_Top_40 = Lighting.ColorShift_Top
			local FogEnd_41 = Lighting.FogEnd
			local FogStart_42 = Lighting.FogStart
			spawn(function()
				local lerpColor3_110 = Utilities.lerpColor3
				Lighting.FogColor = Color3.fromRGB(85, 125, 139)

				local ambientInitial = Ambient_37
				local ambientTarget = Color3.fromRGB(34, 49, 84)
				local outdoorAmbientInitial = OutdoorAmbient_38
				local outdoorAmbientTarget = Color3.fromRGB(65, 87, 104)
				local colorShiftBottomInitial = ColorShift_Bottom_39
				local colorShiftBottomTarget = Color3.fromRGB(118, 167, 241)
				local colorShiftTopInitial = ColorShift_Top_40
				local colorShiftTopTarget = Color3.fromRGB(196, 225, 255)
				local fogEndInitial = FogEnd_41
				local fogStartInitial = FogStart_42
				local fogEndTarget = 200

				local tweenInfo = TweenInfo.new(
					0.9,
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.InOut, 
					0, 
					false, 
					0 
				)
				local tween = TweenService:Create(Lighting, tweenInfo, {
					Ambient = ambientTarget,
					OutdoorAmbient = outdoorAmbientTarget,
					ColorShift_Bottom = colorShiftBottomTarget,
					ColorShift_Top = colorShiftTopTarget,
				})
				tween:Play()
			end)
			lightShift(Color3.fromRGB(34, 49, 84), Color3.fromRGB(65, 87, 104), Color3.fromRGB(118, 167, 241), Color3.fromRGB(196, 225, 255), 0.9)
			local CurrentCamera_111 = workspace.CurrentCamera
			local v112 = CurrentCamera_111:WorldToScreenPoint(v102)
			local v113 = CurrentCamera_111:WorldToScreenPoint(v103)
			local v114 = math.deg(math.atan2(v113.Y - v112.Y, v113.X - v112.X)) + 90
			for v115 = 1, 30 do
				local v116 = math.random() * 0.5 + 0.75
				local v117 = Color3.fromHSV(0.55 + 0.08 * math.random(), 0.5 + math.random() * 0.25, 1)
				local v118 = {
					Color = v117, 
					Image = 644323665, 
					Lifetime = 0.4, 
					Rotation = v114
				}
				u36 = v104
				local u49 = v106 * (0.25 * Vector3.new(math.random() - 0.5, math.random() - 0.5, 0))
				function v118.OnUpdate(p41, p42)
					p42.CFrame = CFrame.new(v102 + u36 * p41 + u49)
					local v119 = (p41 < 0.2 and p41 * 5 or 1) * v116
					p42.BillboardGui.Size = UDim2.new(v119, 0, v119, 0)
				end
				_p.Particles:new(v118)
				delay(0.4, function()
					for v120 = 1, 2 do
						local v121 = math.random() * 360
						_p.Particles:new({
							Color = v117, 
							Image = 644161227, 
							Lifetime = 0.7, 
							Rotation = v121 + 90, 
							Size = 0.4 * v116, 
							Position = v103, 
							Velocity = 5 * (v106 * Vector3.new(math.cos(math.rad(v121)), math.sin(math.rad(v121)), 0)), 
							Acceleration = false
						})
					end
				end)
				task.wait(0.035)
			end
			local v122 = v101.sprite.cf + Vector3.new(0, (v101.sprite.spriteData.inAir), 0) - workspace.CurrentCamera.CFrame.lookVector * 0.2
			local v123 = create("Part")({
				Anchored = true, 
				CanCollide = false, 
				BrickColor = BrickColor.new("Electric blue"), 
				Reflectance = 0.5, 
				Transparency = 0.3, 
				Size = Vector3.new(5, 5, 5), 
				Parent = workspace
			})
			v123.CFrame = v122 * CFrame.Angles(0, 0, math.pi)
			local u50 = create("SpecialMesh")({
				MeshType = Enum.MeshType.FileMesh, 
				MeshId = "rbxassetid://818652045", 
				Parent = v123
			})
			Tween(0.5, nil, function(p43)
				local v124 = p43 * 0.15
				u50.Scale = Vector3.new(v124, v124, v124)
			end)
			pcall(function()
				v101.sprite.animation:Pause()
			end)
			local u51 = {}
			for v125 = 1, 6 do
				local v126 = v123:Clone()
				v126.Mesh.Scale = Vector3.new(0.1, 0.1, 0.1)
				u51[v126] = v122 * CFrame.Angles(0, math.pi / 3 * v125, 0) * CFrame.new(0, 0, -1) * CFrame.Angles(2.5, math.random() * 2 * math.pi, 0)
				v126.Parent = workspace
			end
			Tween(0.4, "easeOutQuad", function(p44)
				for v127, v128 in pairs(u51) do
					v127.CFrame = v128 * CFrame.new(0, 3 * (1 - p44), 0)
				end
			end)
			local u52 = u36 * Vector3.new(1, 0, 1).unit
			local u53 = sprite_107.spriteData.inAir
			Tween(0.6, nil, function(p45)
				sprite_107.offset = u52 * 2 + Vector3.new(0, math.sin(math.pi), 0)
			end)
			local u54 = false
			local u55 = Utilities.Signal()
			local magnitude_56 = u36.magnitude
			local function u57()
				u55:fire()
				local v129 = u52:Cross(Vector3.new(0, 1, 0))
				u51[v123] = true
				for v130, v131 in pairs(u51) do
					local CFrame_132 = v130.CFrame
					local v133 = CFrame.new(CFrame_132.p, CFrame_132.p + v129)
					u51[v130] = { v133, v133:inverse() * CFrame_132 }
				end
				Tween(0.4, nil, function(p46)
					if not v123.Parent then
						return false
					end
					v101.sprite.offset = u52 * p46 * 10 + Vector3.new(0, p46 * 4, 0)
					pcall(function()
						v101.sprite.animation.spriteLabel.Rotation = 500 * p46
					end)
					local v134 = CFrame.Angles(0, 0, p46 * 1.8)
					local v135 = u52 * p46 * 2 + Vector3.new(0, p46 * -5, 0)
					for v136, v137 in pairs(u51) do
						v136.CFrame = v137[1] * v134 * v137[2] + v135
					end
				end)
			end
			spawn(function()
				Tween(1, nil, function(p47, p48)
					if not v123.Parent then
						return false
					end
					local v138 = 70 * p48 * p48 - 2 + 5 * p48
					sprite_107.offset = u52 * v138 + Vector3.new(0, u53, 0)
					if not u54 and magnitude_56 <= v138 then
						u54 = true
						spawn(u57)
					end
				end)
			end)
			u55:wait()
			Utilities.FadeOut(0.35, Color3.new(1, 1, 1))
			v108:Destroy()
			sprite_107.offset = Vector3.new()
			v101.sprite.offset = Vector3.new()
			pcall(function()
				v101.sprite.animation.spriteLabel.Rotation = 0
			end)
			lightRestore(0.1)
			for v139, v140 in pairs(u51) do
				v139:Destroy()
			end
			pcall(function()
				v101.sprite.animation:Play()
			end)
			task.wait(0.1)
			Utilities.FadeIn(0.5)
			return true
		end, 
		breakneckblitz = function(p90, p91, p92)
			local v254 = p91[1];
			if not v254 then
				return;
			end;
			local sprite_255 = p90.sprite;
			local v256 = targetPoint(v254, 0.5) - targetPoint(p90, 2);
			if sprite_255.spriteData.inAir then

			end;
			if v254.sprite.spriteData.inAir then

			end;
			local v257 = targetPoint(p90, 2);
			local v258 = targetPoint(v254, 0.5);
			local v259 = Instance.new("Model", workspace);
			_p.DataManager:preload("Image", 879747500);
			for v260, v261 in pairs({ 165709404, 212966179 }) do
				local v262 = create("Part")({
					Anchored = true, 
					CanCollide = false, 
					CFrame = p92.CoordinateFrame2 + Vector3.new(0, -3, 0), 
					Parent = v259,
					create("SpecialMesh")({
						MeshType = Enum.MeshType.FileMesh, 
						MeshId = "rbxassetid://" .. v261, 
						Scale = Vector3.new(0.2, 0.2, 0.2)
					})
				});
			end;
			local Position_263 = sprite_255.part.Position;
			local v264 = sprite_255.part.Size.Y / 2;
			local v265 = {};
			for v266 = 1, 6 do
				local v267 = create("Part")({
					Transparency = 1, 
					Anchored = true, 
					CanCollide = false, 
					Size = Vector3.new(1, 1, 1), 
					CFrame = CFrame.new(Position_263 + Vector3.new(1.5 * math.cos(math.pi / 3 * v266), v264 * 0.5, 1.5 * math.sin(math.pi / 3 * v266)), Position_263 + Vector3.new(0, v264 * 0.5, 0)), 
					Parent = workspace
				});
				create("Trail")({
					Attachment0 = create("Attachment")({
						CFrame = CFrame.new(-0.3, 0.3, -0.3), 
						Parent = v267
					}), 
					Attachment1 = create("Attachment")({
						CFrame = CFrame.new(0.3, -0.3, 0.3), 
						Parent = v267
					}), 
					Color = ColorSequence.new(Color3.fromRGB(126, 126, 126), Color3.fromRGB(255, 255, 255)), 
					Transparency = NumberSequence.new(0.5, 1), 
					Lifetime = 1, 
					Parent = v267
				});
				v265[v266] = v267;
			end;
			spawn(function()
				Tween(1, nil, function(p93)
					for v268, v269 in pairs(v265) do
						local v270 = math.pi / 3 * v268 + 5 * p93;
						local v271 = 1.5 + math.sin(p93 * math.pi);
						local v272 = Position_263 + Vector3.new(v271 * math.cos(v270), v264 * (0.5 - p93), v271 * math.sin(v270));
						v269.CFrame = CFrame.new(v272, Vector3.new(Position_263.x, v272.Y, Position_263.Z));
					end;
				end);
			end);
			task.wait(1);
			local Y_273 = sprite_255.part.Size.Y;
			local Y_274 = v254.sprite.part.Size.Y;
			local u94 = v256 * Vector3.new(1, 0, 1).unit;
			local u95 = sprite_255.spriteData.inAir and 0;
			Tween(0.6, nil, function(p94)
				sprite_255.offset = u94 * -2 * p94 + Vector3.new(0, math.sin(p94 * math.pi) - 0 * p94, 0);
			end);
			local magnitude_275 = v256.magnitude;
			local v276 = Utilities.Signal();
			local Y_277 = sprite_255.part.Size.Y;
			local v278 = create("Part")({
				BrickColor = BrickColor.new("Gold"), 
				Anchored = true, 
				CanCollide = false, 
				Size = Vector3.new(1, 1, 1), 
				Parent = workspace,
				create("SpecialMesh")({
					MeshType = Enum.MeshType.FileMesh, 
					MeshId = "rbxassetid://212966179", 
					Scale = Vector3.new(1.1, 1.8, 1.1) * Y_277
				})
			});
			local v279 = create("Part")({
				BrickColor = BrickColor.new("Neon orange"), 
				Transparency = 0.5, 
				Anchored = true, 
				CanCollide = false, 
				Size = Vector3.new(1, 1, 1), 
				Parent = workspace,
				create("SpecialMesh")({
					MeshType = Enum.MeshType.FileMesh, 
					MeshId = "rbxassetid://165709404", 
					Scale = Vector3.new(2, 2, 2) * Y_277
				})
			});
			local v280 = sprite_255.cf.p + Vector3.new(0, Y_277 / 2, 0);
			local v281 = CFrame.new(v280, v280 + u94) * CFrame.Angles(-math.pi / 2, 0, 0);
			local v282 = v281 * CFrame.new(0, -0.48 * Y_277, 0) * CFrame.Angles(math.pi, 0, 0);
			spawn(function()
				local CurrentCamera_283 = workspace.CurrentCamera;
				local CFrame_96 = CurrentCamera_283.CFrame;
				Tween(1.5, nil, function(p95)
					local v284 = math.random() * 0.5;
					local v285 = math.random() * math.pi * 2;
					CurrentCamera_283.CFrame = CFrame_96 * CFrame.new(v284 * math.cos(v285), v284 * math.sin(v285), 0);
				end);
			end);
			delay(0.5, function()
				Utilities.FadeOut(0.5, Color3.new(1, 1, 1));
			end);
			Tween(1, nil, function(p96, p97)
				local v286 = u94 * (70 * p97 * p97 - 2 + 5 * p97) + Vector3.new(0, -0, 0);
				sprite_255.offset = v286;
				v278.CFrame = v281 + v286;
				v279.CFrame = v282 + v286;
				local v287 = math.min(1, p97 * 3);
				v278.Transparency = 1 - 0.2 * v287;
				v279.Transparency = 1 - 0.5 * v287;
			end);
			task.wait(0.5);
			v259:Destroy();
			for v288, v289 in pairs(v265) do
				v289:Destroy();
			end;
			sprite_255.offset = Vector3.new();
			v254.offset = Vector3.new();
			Utilities.FadeIn(0.5);
			return true;
		end;
		spectralthief = function(p998, p999)
			local v1854 = p999[1];
			if not v1854 then
				return;
			end;
			local sprite_1855 = p998.sprite;
			Utilities.fastSpawn(function()
				u138(p998, 15882079069, 12);
			end);
			local spriteLabe206 = p998.sprite.animation.spriteLabel;
			if not spriteLabe206 then
				return
			end
			Tween(0.5, "easeOutCubic", function(p1000)
				spriteLabe206.ImageTransparency = p1000;
			end);
			if not task.wait(0.9) then
				return;
			end;
			Utilities.fastSpawn(function()
				u138(v1854, 15882079069, 12);
			end);
			spawn(function()
				Tween(0.075, nil, function(p1001)
					spriteLabe206.ImageTransparency = 1 - p1001;
				end);
			end);
			u204(p998, v1854);
			return true;
		end;
		soulstealing7starstrike = function(pokemon, move)
			local camBefore = workspace.CurrentCamera.CFrame
			spawn(function() _p.MusicManager:fadeToVolume('top', .4, .5) end)
			local oldSkybox

			if game.Lighting:FindFirstChild('Sky') then
				oldSkybox = game.Lighting:FindFirstChild('Sky')
				oldSkybox.Parent = workspace
			elseif game.Lighting:FindFirstChild('White') then
				oldSkybox = game.Lighting:FindFirstChild('White')
				oldSkybox.Parent = workspace
			end

			local SkyFolder = game.Lighting.SkyFolder
			local sky = SkyFolder.SpaceSky:Clone()
			sky.Parent = game.Lighting
			local atmo = SkyFolder.SpaceAtm:Clone()
			atmo.Parent = game.Lighting
			Utilities.sound(6255933126)
			task.wait(1)
			Utilities.FadeOut(0.5, Color3.new(1, 1, 1))
			local nova = game.ReplicatedStorage.Models.Misc.Supernova:Clone()
			local formulas = nova.Formulas:Clone()
			formulas.Parent = game.Players.LocalPlayer.PlayerGui
			workspace.CurrentCamera.FieldOfView = 70
			nova.Parent = battle.scene
			game.Lighting.ColorCorrection.Enabled = false
			Utilities.sound(6255934214)
			spawn(function()
				Utilities.FadeIn(0.5) end)
			spawn(function()
				Utilities.Tween(0.2, nil, function(a)
					formulas.First.ImageTransparency = 1 - 1 * a
				end)
				task.wait()
				Utilities.Tween(0.5, nil, function(a)
					formulas.First.ImageTransparency = 0 + 1 * a
				end)
				Utilities.Tween(0.2, nil, function(a)
					formulas.Third.ImageTransparency = 1 - 1 * a
				end)
				task.wait()
				Utilities.Tween(0.5, nil, function(a)
					formulas.Third.ImageTransparency = 0 + 1 * a
				end)
				Utilities.Tween(0.2, nil, function(a)
					formulas.Second.ImageTransparency = 1 - 1 * a
				end)
				task.wait()
				Utilities.Tween(0.5, nil, function(a)
					formulas.Second.ImageTransparency = 0 + 1 * a
				end)
				Utilities.Tween(0.2, nil, function(a)
					formulas.Forth.ImageTransparency = 1 - 1 * a
				end)
				task.wait()
				Utilities.Tween(0.5, nil, function(a)
					formulas.Forth.ImageTransparency = 0 + 1 * a
				end)
				formulas:destroy()
			end)
			local cam = workspace.CurrentCamera
			spawn(function()
				game.Lighting.SunRays.Enabled = false end)
			local missile = nova.Missile
			local planet = nova.Planet
			--		cam.CameraType = Enum.CameraType.Scriptable
			local sCam = CFrame.new(-78.6099319, -360.574432, -994.993042, -0.495598733, -0.33024165, 0.803319693, 1.49011594e-08, 0.924895763, 0.380221099, -0.868551612, 0.188437104, -0.458377153)
			local sCam1 = CFrame.new(-72.7281265, -356.376221, -990.24176, -0.72100544, -0.105626032, 0.684831619, -0, 0.988313675, 0.152434036, -0.692929447, 0.109905772, -0.712579489)
			local sCam2 = CFrame.new(-67.1381836, -364.965851, -849.597534, -0.791943491, -0.052584745, 0.608325839, -3.72528985e-09, 0.996284723, 0.0861205831, -0.610594332, 0.0682026371, -0.789001286)
			local mis1 = CFrame.new(-84.6941757, -362.943512, -991.224243, 0.965925574, 0.257833987, -0.0225575641, -7.4505806e-09, 0.087155737, 0.99619472, 0.258819044, -0.962249875, 0.0841859952)
			local mis2 = CFrame.new(-178.411362, -394.622772, -641.466858, 0.965925574, 0.257833987, -0.0225575641, -7.4505806e-09, 0.087155737, 0.99619472, 0.258819044, -0.962249875, 0.0841859952)
			delay(0.7, function()
				planet.Rocks.Enabled = true
				task.wait(0.2)
				planet.Rocks.Enabled = false
			end)
			delay(0.6, function()
				--	Utilities.sound(5782801042)
				Utilities.sound(6255936389, 0.3)
				local expEf = Instance.new("Explosion")
				expEf.BlastPressure = 0
				expEf.BlastRadius = 0
				expEf.DestroyJointRadiusPercent = 0
				expEf.Name = "Explosion2"
				expEf.Position = Vector3.new(-98.535, -368.877, -934.049)
				expEf.Parent = nova.Planet
				expEf.Visible = true
				planet.Explosion.Enabled = true
				planet.Beam.Enabled = true

			end)
			delay(1.8, function()
				--	Utilities.sound(1577567682)
				nova.Sun.Biggest:destroy()
				nova.Sun.Biggest2:destroy()
				nova.Sun.Biggest3:destroy()
				nova.Sun.Lens:destroy()
				nova.Sun.Parent = game.Lighting
				nova.BlackBackground.Transparency = 0
				nova.BlackBackground2.Transparency = 0
				nova.BlackBackground3.Transparency = 0
				nova.BlackBackground4.Transparency = 0
				nova.X.Decal.Transparency = 0
				missile:destroy()
				task.wait(0.05)
				nova.X.Decal.Transparency = 1
				nova.Plus.Decal.Transparency = 0
				task.wait(0.05)
				nova.Plus.Decal.Transparency = 1
				nova.BlackBackground.Transparency = 1
				nova.BlackBackground2.Transparency = 1
				nova.BlackBackground3.Transparency = 1
				nova.BlackBackground4.Transparency = 1
				nova.BigGlow.Transparency = 0
				game.Lighting.Sun.Parent = nova
				nova.StartRing.Transparency = 0
				nova.Glow.Transparency = 0.8
				spawn(function()
					Utilities.Tween(0.2, "easeInCubic", function(a)
						nova.BigGlow.Transparency = 0 + 1 * a
					end)
				end)
				spawn(function()
					Utilities.Tween(0.2, "easeInCubic", function(a)
						nova.Shine2.Transparency = 1 -0.2 * a
					end)
					Utilities.Tween(0.2, "easeInCubic", function(a)
						nova.Shine2.Size = Vector3.new(328.696, 331.968, 0.05) - Vector3.new(328.696 * a, 331.968 * a, 0.05 * a)
					end)

				end)
				spawn(function()
					Utilities.Tween(0.3, "easeInCubic", function(a)
						nova.Glow.Size = Vector3.new(396.564, 53.489, 383.668) - Vector3.new(396.564 * a, 53.489 * a, 383.668 * a)
					end)
				end)
				nova.Sun:destroy()

				spawn(function()
					Utilities.Tween(0.3, "easeInCubic", function(a)
						nova.SunGlow.Size = Vector3.new(32.151, 32.151, 32.151) - Vector3.new(32.151 * a, 32.151 * a, 32.151 * a)
					end)
				end)
				Utilities.Tween(0.3, "easeInCubic", function(a)
					nova.StartRing.Size = Vector3.new(185.509, 0.05, 187.173) - Vector3.new(185.509 * a, 0.05 * a, 187.173 * a)
				end)
				task.wait(0.1)

				spawn(function()
					_p.CameraShaker:BeginEarthquake(function(cf)
						cam.CFrame = cam.CFrame * cf
					end, 0.3)
					task.wait(0.5)
					_p.CameraShaker:EndEarthquake(0.1)
				end)
				Utilities.sound(6255934893)
				spawn(function()
					Utilities.Tween(0.5, "easeInSine", function(a)
						nova.BlastRing.Size = Vector3.new(0, 0, 0) + Vector3.new(729.71 * a, 0.3 * a, 743.564 * a)
					end)
				end)
				spawn(function()
					Utilities.Tween(0.5, "easeInSine", function(a)
						nova.BlastRing.Transparency = 0 + 1 * a
					end)
				end)
				spawn(function()
					Utilities.Tween(3, "easeOutSine", function(a)
						nova.BlastRing2.Size = Vector3.new(0, 0, 0) + Vector3.new(549.694 * a, 0.921 * a, 503.598 * a)
					end)
				end)
				spawn(function()
					--Utilities.Tween(3, "easeOutCubic", function(a)
					--	nova.BlastRing2.Transparency = 0 + 1 * a
					--end)
				end)
				spawn(function()
					nova.Shine.Attachment.ShineParticles.Enabled = true
					nova.Effects.Glow1.Enabled = true
					nova.Effects.Glow2.Enabled = true
					nova.Effects.Glow3.Enabled = true
					task.wait(0.2)
					nova.Effect2.Glow1.Enabled = true
					nova.Effect2.Glow2.Enabled = true
				end)
				task.wait(1)
				cam.CFrame = CFrame.new(-5.09776592, -384.158295, -779.417603, 0.337045282, 0.00692439964, -0.941462994, -0, 0.999972999, 0.00735473633, 0.941488504, -0.00247887918, 0.337036133)
				spawn(function()
					delay(0.4, function()
						Utilities.sound(6255935707) end)

					Utilities.Tween(1, "easeInSine", function(a)
						nova.EarthDestroy.CFrame = nova.EarthDestroy.CFrame * CFrame.new(0, 0, 5 * a)
					end)
				end)
				spawn(function()

					Utilities.Tween(1, "easeInSine", function(a)
						nova.EarthDestroy2.CFrame = nova.EarthDestroy2.CFrame * CFrame.new(0, 0, 5 * a)
					end)
				end)
				delay(0.6, function()
					spawn(function()
						_p.CameraShaker:BeginEarthquake(function(cf)
							cam.CFrame = cam.CFrame * cf
						end, 0.5)
						task.wait(1)
						_p.CameraShaker:EndEarthquake(0.4)
					end)
					Utilities.Tween(0.7, nil, function(a)
						nova.DarkEarth.Transparency = 0.5 - 0.5 * a
					end)
					task.wait(0.3)
					local dPlanet = game.ReplicatedStorage.Models.Misc["Destroyed Planet"]:Clone()
					nova.DarkEarth:destroy()
					Utilities.sound(6255936389)
					dPlanet.Parent = nova
					delay(0, function()
						nova.Earth.Rocks.Enabled = true
						task.wait(0.2)
						nova.Earth.Rocks.Enabled = false
					end)
					Utilities.Tween(1, "easeOutCubic", function(a)
						Utilities.MoveModel(dPlanet.Main, dPlanet.Main.CFrame * CFrame.new(0, 0.02 * a, -0.02 * a))
					end)
					task.wait(0.5)
					spawn(function() _p.MusicManager:fadeToVolume('top', 1, .5) end)
					workspace.CurrentCamera.FieldOfView = 28
					cam.CFrame = camBefore
					game.Lighting.ColorCorrection.Enabled = true
					--	cam.CFrame = CFrame.new(-7.00124121, 4.68963575, -10.3212385, -0.707106233, 0.0458332114, -0.705620468, -3.72528985e-09, 0.997897267, 0.064817898, 0.707107425, 0.0458331443, -0.705619276)
					nova:destroy()
					sky:destroy()
					atmo:destroy()
					if oldSkybox then
						oldSkybox.Parent = game.Lighting
					end
					spawn(function()
						game.Lighting.SunRays.Enabled = true end)
				end)
				delay(1, function()
					Utilities.Tween(1, nil, function(a)
						nova.GlowBackground.Transparency = 1-1 * a
					end)
				end)
				delay(1, function()
					Utilities.Tween(1, nil, function(a)
						nova.Earth.Transparency = 0 + 1 * a
					end)
				end)


			end)

			spawn(function()
				Utilities.Tween(2, "easeInSine", function(a)
					missile.CFrame = mis1:Lerp(mis2, a)
				end)
			end)
			spawn(function()
				Utilities.Tween(1, nil, function(a)
					cam.CFrame = sCam:Lerp(sCam1, a)
				end)
				Utilities.Tween(1, nil, function(a)
					cam.CFrame = sCam1:Lerp(sCam2, a)
				end)
			end)
			spawn(function()
				Utilities.Tween(2, "easeInSine", function(a)
					missile.CFrame = mis1:Lerp(mis2, a)
				end)
			end)
			task.wait(5)

			return true
		end,		
	} end