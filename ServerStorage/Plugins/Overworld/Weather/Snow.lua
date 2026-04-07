return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local stepped = game:GetService("RunService").RenderStepped
	local lighting = game:GetService("Lighting")
	local player = _p.player
	local camera = game.Workspace.CurrentCamera
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local RunService = game:GetService("RunService")
	local Snow = {
		enabled=false,
	}

	function Snow:enableSnow() 
		if self.enabled then
			return 
		end
		self.enabled = true
		_p.Overworld.Weather.Fog:enableFog(2, nil, 'snow')
		local particles = {}
		particles.Snow = create('ParticleEmitter')(
			_p.Overworld.SFXData['snow']
		)
		particles.Wind = create('ParticleEmitter')(
			_p.Overworld.SFXData['snowwind']
		)
		self.UID = Utilities.uid()
		_p.CameraEffect:ParticleFollow(particles, 'Above', nil, self.UID)
	end
	
	function Snow:disableSnow()
		if not self.enabled then return end
		self.enabled = false
		_p.Overworld.Weather.Fog:disableFog(2)
		_p.CameraEffect:ParticleUnfollow(self.UID)
		self.UID = nil
	end
	return Snow
end	