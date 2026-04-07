return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local stepped = game:GetService("RunService").RenderStepped
	local lighting = game:GetService("Lighting")
	local player = _p.player
	local camera = game.Workspace.CurrentCamera
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local RunService = game:GetService("RunService")
	local Tween = Utilities.Tween
	local Hail = {
		enabled=false,
	}
	
	function Hail:enableHail(Scene) 
		if self.enabled then
			return 
		end
		self.enabled = true
		_p.Overworld.Weather.Fog:enableFog(2, nil, 'Hail')
		
		--[[NEWWWWWWW]]
		local nHailParts = 0
		local hailParts = {}
		local v3 = Vector3.new
		local cf = CFrame.new
		local xzPlane = Vector3.new(1, 0, 1)
		local random = math.random
		local twoPi = math.pi * 2
		local sin, cos = math.sin, math.cos
		local down = Vector3.new(0, -150, 0)
		local crashOffset = Vector3.new(0, 0.6, 0)

		spawn(function()
			local hailDrop = create("Part")({
				Anchored = true,
				CanCollide = false,
				CanTouch = false,
				CanQuery = true,
				Material = Enum.Material.SmoothPlastic,
				Color = Color3.fromRGB(175, 221, 255),
				Transparency = 1,
				Size = Vector3.new(0.55, 0.55, 0.55),
				TopSurface = Enum.SurfaceType.Smooth,
				BottomSurface = Enum.SurfaceType.Smooth,
				create("BillboardGui")({
					Size = UDim2.new(1, 0, 1, 0),
					create("ImageLabel")({
						Image = "rbxassetid://99851851",--15881914954 6452688833
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 1, 0),
						ImageColor3 = Color3.fromRGB(175, 221, 255),
						--Face = Enum.NormalId.Back
					})
				})
				--create("Decal")({
				--	Texture = "rbxassetid://99851851",
				--	Face = Enum.NormalId.Back
				--})
			})
			local crashLocation = create("Attachment")({
				Parent = workspace.Terrain
			})
			local camera = workspace.CurrentCamera
			local thisThread = {}
			self.hailThread = thisThread
			while self.enabled and self.hailThread == thisThread do
				local now = tick()
				local camPos = camera.CFrame.Position
				for i = nHailParts, 1, -1 do
					local hail = hailParts[i]
					local l = (now - hail[3]) * 75--100
					if l >= hail[4] then
						hailParts[i] = hailParts[nHailParts]
						nHailParts = nHailParts - 1
						spawn(function()
							for i = 1, 2 do--2
								
								local axis = math.random(1, 4)
								local negative = math.random(1,3)
								local bounce = Utilities.Timing.easeOutBounce(.5)
								local dir = math.random() < 0.5 and 1 or -1
								local x = dir * 0.15 / hail[1].BillboardGui.Size.X.Scale
								local y = -0.3 / hail[1].BillboardGui.Size.Y.Scale
								Tween(.5, nil, function(a)
									--hail[1].CFrame += Vector3.new(axis == (1 or 3) and (i/4)*math.sin(a*math.pi) or axis == 2 and -(i/4)*math.sin(a*math.pi) or 0, (.2)*a--[[(i/4)*math.sin(a*math.pi)]], axis == (2 or 3) and (i/4)*math.sin(a*math.pi) or axis == 1 and -(i/4)*math.sin(a*math.pi) or 0)			
									hail[1].CFrame -= Vector3.new(x * (1 - a), y * (1 - bounce(a)), x * (1 - a))--Vector3.new(0, 2*i*math.sin(a*math.pi), 0)
									hail[1].BillboardGui.Size -= UDim2.new((i/8)*a, (i/8)*a, (i/8)*a)
								end)
							end
							hail[1]:Destroy()
						end) 
						if (camPos - hail[5]).Magnitude < 40 then
							crashLocation.Position = hail[5]			
						end
					else
						local pos = hail[2] + v3(0, -0.7 - l, 0)--.7
						hail[1].CFrame = cf(pos, pos + (pos - camPos) * xzPlane)
					end
				end
				if nHailParts < (_p.Menu.options.reduceGraphics and 50 or 200) then
					local chunkModel = _p.DataManager.currentChunk and _p.DataManager.currentChunk.map
					if chunkModel then
						do
							local hailFocus = self.hailFocus
							if not self.hailFocus then
								if self.useCameraPosition then
									hailFocus = camPos
								else
									pcall(function()
										local head = player.Character.Head
										hailFocus = head.Position + 1.5 * head.Velocity
									end)
								end
							end
							if hailFocus then
								for i = 1, 4 do
									local r = random() ^ 1.2 * 120 + 4
									local t = random() * twoPi
									local p = hailFocus + v3(r * sin(t), 100, r * cos(t))
									local ray = Ray.new(p, down)
									local hit, pos = workspace:FindPartOnRayWithWhitelist(ray, {Scene, chunkModel}, true)
									if hit then
										local drop = hailDrop:Clone()
										drop.Parent = camera
										drop.CFrame = cf(p)
										nHailParts = nHailParts + 1
										hailParts[nHailParts] = {
											drop,
											p,
											now,
											p.Y - pos.Y,
											pos + crashOffset
										}
									end
								end
							end
						end
					end
				end
				stepped:Wait()
			end
			for i = 1, nHailParts do
				hailParts[i][1]:Destroy()
			end
			hailParts = nil
		end)
	end
	
	function Hail:disableHail()
		if not self.enabled then return end
		self.enabled = false
		self.hailThread = nil
		_p.Overworld.Weather.Fog:disableFog(2)
	end
	
	return Hail
end	