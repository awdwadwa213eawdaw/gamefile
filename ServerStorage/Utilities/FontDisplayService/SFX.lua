local sfx = {}

local function forAllLetters(letters, fn, sw)
	for i, letter in pairs(letters) do
		if sw then
			spawn(function()
				while wait() do
					fn(letter, i)
				end
			end)	
		else
			fn(letter, i)
		end
	end
end

local function getProp(letter, Type)
	local props = {
		ImageLabel = {
			Color = "ImageColor3",
			Transparency = "ImageTransparency"
		},
		TextLabel = {
			Color = "TextColor3",
			Transparency = "TextTransparency"
		}
	}
	
	if props[letter.ClassName] and props[letter.ClassName][Type] then
		return props[letter.ClassName][Type]
	end
end

function sfx:Gradient(letters, color)
	local phase = 0
	local frequency = math.pi / #letters
	local widthr = math.floor(color.r * 255)
	local widthg = math.floor(color.g * 255)
	local widthb = math.floor(color.b * 255)
	
	forAllLetters(letters, function(letter, i)
		local red = math.sin(frequency * (i + phase)) * (255 - widthr) + 255
		local green = math.sin(frequency * (i + phase)) * (255 - widthg) + 255
		local blue = math.sin(frequency * (i + phase)) * (255 - widthb) + 255
		local prop = getProp(letter, "Color")

		letter[prop] = Color3.new(red / 255, green / 255, blue / 255)
		phase = phase - 0.05
	end, true)
end

function sfx:Rainbow(letters)
	local center = 128
	local width = 127
	local phase = 0
	local frequency = math.pi * 2 / #letters
	
	forAllLetters(letters, function(letter, i)
		local red = math.sin(frequency * i + 2 + phase) * width + center
		local green = math.sin(frequency * i + 0 + phase) * width + center
		local blue = math.sin(frequency * i + 4 + phase) * width + center
		local prop = getProp(letter, "Color")
		
		letter[prop] = Color3.new(red / 255, green/255, blue / 255)
		phase = phase - 0.02
	end, true)
end

return sfx
