return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local stepped = game:GetService("RunService").RenderStepped
	local lighting = game:GetService("Lighting")
	local player = _p.player
	local camera = game.Workspace.CurrentCamera

	local Sandstorm = {
		enabled=false,
	}
	local pSounds = {
		{145695098, .5},
		{3067632105, .4},
		{583577857, .6},
		{144722304, .65},
		{5155169190, .5},
	}
	local function makeSound(id, vol)
		if not vol then vol = .8 end
		Utilities.sound(id, vol, nil, 40)
	end

	function Sandstorm:setupRanAmbience()
		while self.enabled do
			task.wait(math.random(25, 220))
			local sound = pSounds[math.random(1, #pSounds)]
			makeSound(sound[1], sound[2])
		end
	end
	function Sandstorm:enableStorm() 
		if self.enabled then
			return 
		end
		self.enabled = true
		_p.Overworld.Weather.Fog:enableFog(2, nil, 'sandstorm')
		local particles = {}
		particles.Sand1 = create('ParticleEmitter')(
			_p.Overworld.SFXData['sandstorm']
		)
		particles.Sand2 = create('ParticleEmitter')(
			_p.Overworld.SFXData['sandstorm']
		)
		particles.Sand3 = create('ParticleEmitter')(
			_p.Overworld.SFXData['sandstorm']
		)
		--spawn(function() self:setupRanAmbience() end)
		self.UID = Utilities.uid()
		_p.CameraEffect:ParticleFollow(particles, 'Above', {150, 0}, self.UID)
	end    

	function Sandstorm:disableStorm() 
		if not self.enabled then
			return
		end
		self.enabled = false
		_p.Overworld.Weather.Fog:disableFog(2)
		_p.CameraEffect:ParticleUnfollow(self.UID)
		self.UID = nil
	end
	return Sandstorm
end