return function(_p)
	local Utilities = _p.Utilities
	local Create = Utilities.Create
	local MasterControl = _p.MasterControl
	
	local ultraWormhole = {
		isDoingCutscene = false,
		isInWormhole = false,
	}
	
	function ultraWormhole:setupCutscene()
		--Audio
		_p.DataManager:preload()
		--Decals
		_p.DataManager:preload()

	end
	
	function ultraWormhole:setupControls()
		
	end
	
	return ultraWormhole
end