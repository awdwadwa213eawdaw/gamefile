return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local stepped = game:GetService("RunService").RenderStepped
	local lighting = game:GetService("Lighting")
	local RunService = game:GetService("RunService")

	local DEFAULT_LIGHTING_BRIGHTNESS = lighting.Brightness
	local DEFAULT_LIGHTING_EXPOSURE_COMPENSATION = lighting.ExposureCompensation
	local DEFAULT_LIGHTING_OUTDOOR_AMBIENT = lighting.OutdoorAmbient
	local DEFAULT_LIGHTING_FOG_END = lighting.FogEnd
	local DEFAULT_LIGHTING_FOG_COLOR = lighting.FogColor

	local function getLightingBrightness()
		return (_p.Constants and _p.Constants.LIGHTING_BRIGHTNESS) or DEFAULT_LIGHTING_BRIGHTNESS
	end

	local function getLightingExposure()
		return (_p.Constants and _p.Constants.LIGHTING_EXPOSURE_COMPENSATION) or DEFAULT_LIGHTING_EXPOSURE_COMPENSATION
	end

	local function getLightingOutdoorAmbient()
		return (_p.Constants and _p.Constants.LIGHTING_OUTDOOR_AMBIENT) or DEFAULT_LIGHTING_OUTDOOR_AMBIENT
	end

	local fog = {
		enabled = false,
		testing = true
	}

	function fog:pulsateFog(object, data)
		if not object then
			object = self.Atmosphere
		end
		if not object then
			return
		end

		local savedDensity = object.Density

		if self.pulsateEnabled then
			RunService:UnbindFromRenderStep("Pulsate")
		else
			RunService:BindToRenderStep("Pulsate", Enum.RenderPriority.Camera.Value, function()
				Utilities.Tween(data.timing / 2, "easeOutCubic", function(a)
					if object then
						object.Density = object.Density - (object.Density * a)
					end
				end)
				Utilities.Tween(data.timing / 2, "easeOutCubic", function(a)
					if object then
						object.Density = savedDensity * a
					end
				end)
			end)
		end
	end

	function fog:enableFog(tweenTime, FOV, variant)
		if self.enabled then
			return
		end
		self.enabled = true

		if not FOV then
			FOV = 230
		end

		local def = {}
		if variant == "smog" then
			def = {
				AtmoCD = Color3.fromRGB(63, 48, 65),
				FogColor = Color3.fromRGB(95, 67, 91),
				OutdoorAmbient = Color3.fromRGB(150, 115, 131),
			}
		elseif variant == "bloodmoon" then
			def = {
				AtmoCD = Color3.fromRGB(75, 28, 0),
				FogColor = Color3.fromRGB(95, 39, 0),
				OutdoorAmbient = Color3.fromRGB(150, 51, 0),
				Density = 0.604
			}
		elseif variant == "snow" then
			def = {
				AtmoCD = Color3.fromRGB(191, 191, 191),
				FogColor = Color3.fromRGB(102, 102, 102),
				OutdoorAmbient = Color3.fromRGB(153, 153, 153),
			}
		elseif variant == "sandstorm" then
			def = {
				AtmoCD = Color3.fromRGB(157, 134, 0),
				FogColor = Color3.fromRGB(123, 114, 0),
				OutdoorAmbient = Color3.fromRGB(213, 206, 85),
				Density = 0.704
			}
		else
			def = {
				AtmoCD = Color3.fromRGB(191, 191, 191),
				FogColor = Color3.fromRGB(102, 102, 102),
				OutdoorAmbient = Color3.fromRGB(153, 153, 153),
			}
		end

		local sky = lighting:FindFirstChildOfClass("Sky")
		if sky then
			sky.CelestialBodiesShown = false
			sky.StarCount = 0
		end

		self.Atmosphere = create("Atmosphere")({
			Density = 0,
			Offset = 0,
			Color = def.AtmoCD,
			Decay = def.AtmoCD,
			Glare = 0,
			Haze = 0,
			Parent = lighting
		})

		lighting.FogColor = def.FogColor

		if tweenTime then
			Utilities.spTween(lighting, "Brightness", 0, tweenTime)
			Utilities.spTween(lighting, "ExposureCompensation", 0, tweenTime)
			Utilities.spTween(lighting, "OutdoorAmbient", def.OutdoorAmbient, tweenTime)
			Utilities.spTween(lighting, "FogEnd", FOV, tweenTime)

			if self.Atmosphere then
				Utilities.spTween(self.Atmosphere, "Density", def.Density or 0.506, tweenTime)
				Utilities.spTween(self.Atmosphere, "Haze", def.Haze or 2.21, tweenTime)
			end
		else
			lighting.Brightness = 0
			lighting.ExposureCompensation = 0
			lighting.OutdoorAmbient = def.OutdoorAmbient
			lighting.FogEnd = FOV

			if self.Atmosphere then
				self.Atmosphere.Density = def.Density or 0.506
				self.Atmosphere.Haze = def.Haze or 2.21
			end
		end
	end

	function fog:disableFog(fadeTime)
		if not self.enabled then
			return
		end
		self.enabled = false

		local sky = lighting:FindFirstChildOfClass("Sky")
		if sky then
			sky.CelestialBodiesShown = true
			sky.StarCount = 3000
		end

		local atmo = self.Atmosphere

		if fadeTime then
			Utilities.spTween(lighting, "Brightness", getLightingBrightness(), fadeTime)
			Utilities.spTween(lighting, "ExposureCompensation", getLightingExposure(), fadeTime)
			Utilities.spTween(lighting, "OutdoorAmbient", getLightingOutdoorAmbient(), fadeTime)
			Utilities.spTween(lighting, "FogEnd", DEFAULT_LIGHTING_FOG_END, fadeTime)

			if atmo then
				Utilities.spTween(atmo, "Density", 0, fadeTime)
				Utilities.spTween(atmo, "Haze", 0, fadeTime)
			end
		else
			lighting.Brightness = getLightingBrightness()
			lighting.ExposureCompensation = getLightingExposure()
			lighting.FogColor = DEFAULT_LIGHTING_FOG_COLOR
			lighting.OutdoorAmbient = getLightingOutdoorAmbient()
			lighting.FogEnd = DEFAULT_LIGHTING_FOG_END
		end

		if atmo then
			atmo:Destroy()
			self.Atmosphere = nil
		end
	end

	return fog
end