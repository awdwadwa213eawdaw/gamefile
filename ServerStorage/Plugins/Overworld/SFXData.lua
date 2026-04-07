return function(_p)
	--NumberSequenceKeypoint.new(.188, 1, .1), --Pos, val, envelope
	local SFXData = {
		snow = {
			Texture='rbxassetid://512526828',
			Size = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 1),
			},
			LightEmission = 0,
			LightInfluence = 0,
			Orientation = Enum.ParticleOrientation.FacingCamera,
			Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 0)
			},
			EmissionDirection = Enum.NormalId.Bottom,
			Lifetime = NumberRange.new(20, 20),
			Rate = 800,
			Rotation = NumberRange.new(0, 0),
			RotSpeed = NumberRange.new(0, 0),
			Speed = NumberRange.new(75, 75),
			SpreadAngle = Vector2.new(0,50),
			Drag = 0,
		},
		snowwind = {
			Texture='rbxassetid://304589877',
			Size = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 50),
				NumberSequenceKeypoint.new(1, 50),
			},
			LightEmission = 0,
			LightInfluence = 0,
			Orientation = Enum.ParticleOrientation.FacingCamera,
			Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(.3, .7),
				NumberSequenceKeypoint.new(1, 0),

			},
			EmissionDirection = Enum.NormalId.Bottom,
			Lifetime = NumberRange.new(1.5, 1.5),
			Rate = 30,
			Rotation = NumberRange.new(0, 360),
			RotSpeed = NumberRange.new(0, 0),
			Speed = NumberRange.new(65, 65),
			SpreadAngle = Vector2.new(0,50),
			Drag = 0,
			Acceleration = Vector3.new(0, -35, 0)
		},
		fallleaf = {
			Texture='rbxassetid://534371181',
			Size = NumberSequence.new{
				NumberSequenceKeypoint.new(0, .5),
				NumberSequenceKeypoint.new(1, .5),
			},
			LightEmission = 0.7,
			LightInfluence = 1,
			Color = ColorSequence.new(Color3.fromRGB(255, 170, 0)),
			Orientation = Enum.ParticleOrientation.FacingCamera,
			Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(.12, .45),
				NumberSequenceKeypoint.new(1, .5),

			},
			EmissionDirection = Enum.NormalId.Top,
			Lifetime = NumberRange.new(6, 6),
			Rate = .3,
			Rotation = NumberRange.new(-95, -95),
			RotSpeed = NumberRange.new(0, 0),
			Speed = NumberRange.new(1, 1),
			SpreadAngle = Vector2.new(0,0),
			Drag = -1,
			Acceleration = Vector3.new(0, -2, 0)
		},
		lightning = {
			Texture='rbxassetid://4865265046',
			Size = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, .5),
			},
			LightEmission = 1,
			LightInfluence = 0,
			Color = ColorSequence.new(Color3.fromRGB(255, 255, 126)),
			Orientation = Enum.ParticleOrientation.FacingCamera,
			Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(.7, .25),
				NumberSequenceKeypoint.new(1, 1),

			},
			EmissionDirection = Enum.NormalId.Top,
			Lifetime = NumberRange.new(.25, .25),
			Rate = 30,
			Rotation = NumberRange.new(0, 360),
			RotSpeed = NumberRange.new(0, 360),
			Speed = NumberRange.new(0, 0),
			SpreadAngle = Vector2.new(0,0),
			Drag = 0,
			Acceleration = Vector3.new(0, 0, 0)
		},
		sandstorm = {
			Texture='rbxasset://textures/particles/smoke_main.dds',
			Size = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 30),
				NumberSequenceKeypoint.new(1, 30),
			},
			LightEmission = 0,
			LightInfluence = 0,
			Color = ColorSequence.new(Color3.fromRGB(159, 144, 108)),
			Brightness = 1,
			Orientation = Enum.ParticleOrientation.FacingCamera,
			Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(.1, .6, .2),
				NumberSequenceKeypoint.new(.5, .65),
				NumberSequenceKeypoint.new(.9, .55),
				NumberSequenceKeypoint.new(1, 1),
			},
			EmissionDirection = Enum.NormalId.Left,
			Lifetime = NumberRange.new(5, 5),
			Rate = 100,
			Rotation = NumberRange.new(0, 0),
			RotSpeed = NumberRange.new(0, 0),
			Speed = NumberRange.new(100, 100),
			SpreadAngle = Vector2.new(20,20),
			Shape = Enum.ParticleEmitterShape.Disc,
			ShapeInOut = Enum.ParticleEmitterShapeInOut.Inward,
			ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface,
			Drag = 0,
			Acceleration = Vector3.new(0, 0, 0)
		}
	}
	return SFXData
end