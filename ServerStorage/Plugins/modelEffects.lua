return function(_p)
	local Utilities = _p.Utilities
	local Create = Utilities.Create
	local RunService = game:GetService("RunService")
	local Terrain = workspace.Terrain
	local IsDescendantOf = Terrain.IsDescendantOf
	local PIx2 = 2 * math.pi

	local jewelData = {}

	local modelEffects = {

	}
	local function genJewel(Color, startCFrame, negOrPos, range)
		local misc = game.ReplicatedStorage.Models.Misc
		local jewelShard = misc:FindFirstChild('JewelShard')
		if not jewelShard then
			warn('Jewel Shard Model not found in directory')
			return 
		end
		local clonedJewel = jewelShard:Clone()
		clonedJewel.Color = Color
		clonedJewel.CFrame = startCFrame
		local Attachment0 =  Create("Attachment")({
			Parent = clonedJewel,
			Position = Vector3.new(0.15, 0, 0)
		})
		local Attachment1 = Create("Attachment")({
			Parent = clonedJewel,
			Position = Vector3.new(-0.15, 0, 0)
		})
		local Trail = Create("Trail")({
			Lifetime = 1.25, 
			Color = ColorSequence.new(Color), 
			Transparency = NumberSequence.new(0, 1), 
			LightEmission = 0.75, 
			LightInfluence = 0, 
			Attachment0 = Attachment0, 
			Attachment1 = Attachment1, 
			MaxLength = 3, 
			FaceCamera = true, 
			WidthScale = NumberSequence.new(1, 0), 
			Parent = clonedJewel
		})
		clonedJewel.Parent = workspace

		Utilities.Tween(3, nil, function(a)
			local gemSize = Vector3.new(0.3, 0.8, 0.3)
			local changeYa = (0.5 + 0.5 * a) ^ 3
			local changeXa = 1 - changeYa
			clonedJewel.Transparency = math.max(0, math.cos(a * PIx2))
			clonedJewel.Size = gemSize * changeXa
			local cframeChangeXY = negOrPos * changeYa
			local changeXZa = 3 * math.sin(changeYa * math.pi)
			clonedJewel.CFrame = startCFrame * CFrame.new(changeXZa * math.cos(cframeChangeXY), range * changeYa, changeXZa * math.sin(cframeChangeXY))
			Attachment0.Position = Vector3.new(0.15 * changeXa, 0, 0)
			Attachment1.Position = Vector3.new(-0.15 * changeXa, 0, 0)
		end)
		delay(1.25, function()
			clonedJewel:Destroy()
		end)
	end

	local alreadyActive = false
	local function unbindFunc(p23)
		jewelData[p23] = nil
		if alreadyActive and not next(jewelData) then
			alreadyActive = false
			RunService:UnbindFromRenderStep("renderJewel")
		end
	end
	local function doJewel()
		local osClock = os.clock()
		local randomNew = Random.new()
		for _, data in pairs(jewelData) do
			if osClock - data.lastParticle > 0.4 and IsDescendantOf(data.mainPart, workspace) then --.8
				data.lastParticle = osClock
				local size = data.size
				local range = -1
				if randomNew:NextInteger(1, 2) == 1 then
					range = 1
				end
				coroutine.wrap(genJewel)(data.colors[randomNew:NextInteger(1, #data.colors)], data.mainPart.CFrame * CFrame.new(size.X * randomNew:NextNumber(-0.5, 0.5), size.Y * randomNew:NextNumber(-0.5, 0.5), size.Z * randomNew:NextNumber(-0.5, 0.5)) * CFrame.Angles(0, PIx2 * randomNew:NextNumber(), 0), range * randomNew:NextNumber(3, 5), 4 + randomNew:NextNumber(1, 2))
			end
		end
	end
	function modelEffects:animJewel(Part, Colors)
		jewelData[#jewelData+1] = {
			mainPart = Part, 
			size = Part.Size, 
			colors = Colors, 
			lastParticle = 0
		}
		if not alreadyActive then
			alreadyActive = true
			RunService:BindToRenderStep("renderJewel", Enum.RenderPriority.First.Value, doJewel)
		end
	end
	function modelEffects:disableJewel()
		RunService:UnbindFromRenderStep("renderJewel")
		alreadyActive = false
		jewelData = {}
	end

	return modelEffects
end