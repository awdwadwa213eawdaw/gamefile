return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local stepped = game:GetService("RunService").RenderStepped
	local lighting = game:GetService("Lighting")
	local player = _p.player
	local camera = game.Workspace.CurrentCamera
	local BloodMoon = {
		enabled=false,
	}
	local MoonTextures = {
		blood='http://www.roblox.com/asset/?id=1055904136',
		norm='rbxasset://sky/moon.jpg',
	}

	--[[
	NOTES
	Blood Moon is purely visual so it doesn't force time of day
	]]

	function BloodMoon:enableBloodMoon()
		if not self.skyBox then
			self.skyBox = game.Lighting:WaitForChild('Sky')
		end
		self.skyBox.MoonTextureId = MoonTextures.blood
		local particles = {}
		particles.Wisp = game:GetService("ReplicatedStorage").Models.Misc.Precip.BloodMoon:Clone()
		--Todo fog
		--_p.Overworld.Weather.Fog:enableFog(2.5, nil, 'bloodmoon')
		self.UID = Utilities.uid()
		_p.CameraEffect:ParticleFollow(particles, 'Above', {150, 0}, self.UID)

		--delay(4, function() _p.Overworld.Weather.Fog:pulsateFog(nil, {timing=15}) end)
	end
	function BloodMoon:disableBloodMoon()
		if not self.skyBox then
			self.skyBox = game.Lighting:WaitForChild('Sky')
		end
		self.skyBox.MoonTextureId = MoonTextures.norm
		local particles = {}
		--Todo fog
		_p.Overworld.Weather.Fog:disableFog(2.5)
		_p.CameraEffect:ParticleUnfollow(self.UID)
		self.UID = nil
	end
	return BloodMoon
end	