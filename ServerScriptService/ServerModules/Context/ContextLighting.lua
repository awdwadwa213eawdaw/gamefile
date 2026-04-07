local Lighting = game:GetService("Lighting")

return function(context)
	for i, instance in pairs(script[context:sub(1, 1):upper()..context:sub(2).."Lighting"]:GetChildren()) do
		instance.Parent = Lighting
	end
end