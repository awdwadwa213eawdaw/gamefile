local efx = {}

efx.Twilight = function(letters, speech)

	local center = 128
	local width = 127
	local phase = 0
	local frequency = math.pi * 2 / speech
	for i, v in next, letters do
		do
			spawn(function()
				while 1 do
					local red = math.sin(frequency * i + 2 + phase) * width + center
					local green = math.sin(frequency * i + 0 + phase) * width + center
					local blue = math.sin(frequency * i + 4 + phase) * width + center
					letters[i].ImageColor3 = Color3.new(red / 255, red / 255, red / 255)
					phase = phase + 0.01
					wait()
				end
			end
			)
		end
	end
end

efx.Calculus2 = function(letters, speech)

	local center = 128
	local width = 127
	local phase = 0
	local frequency = math.pi * 2 / speech
	for i, v in next, letters do
		do
			spawn(function()
				while 1 do
					local red = math.sin(frequency * i + 5 + phase) * width + center
					local green = math.sin(frequency * i + 7 + phase) * width + center
					local blue = math.sin(frequency * i + 2 + phase) * width + center
					letters[i].ImageColor3 = Color3.new(0, green / 255, 0)
					phase = phase + 0.0086666
					wait()
				end
			end
			)
		end
	end
end

efx.Phaser = function(letters, speech)

	local center = 128
	local width = 127
	local phase = 0
	local frequency = math.pi * 2 / speech
	for i, v in next, letters do
		do
			spawn(function()
				while 1 do
					local red = math.sin(frequency * i + 2 + phase) * width + center
					local green = math.sin(frequency * i + 0 + phase) * width + center
					local blue = math.sin(frequency * i + 6 + phase) * width + center
					letters[i].ImageColor3 = Color3.new(0, 0, blue/255)
					phase = phase + 0.01
					wait()
				end
			end
			)
		end
	end
end

efx.Burn = function(letters, speech)

	local center = 128
	local width = 127
	local phase = 0
	local frequency = math.pi * 2 / speech
	for i, v in next, letters do
		do
			spawn(function()
				while 1 do
					local red = math.sin(frequency * i + 2 + phase) * width + center
					local green = math.sin(frequency * i + 0 + phase) * width + center
					local blue = math.sin(frequency * i + 4 + phase) * width + center
					letters[i].ImageColor3 = Color3.new((red/255)/2, 0, 0)
					phase = phase + 0.01
					wait()
				end
			end
			)
		end
	end
end


efx.Burn2 = function(person, letters, speech)

	local center = 128
	local width = 127
	local phase = 0
	local frequency = math.pi * 2 / speech:len()
	for i = 1, #letters:GetChildren() do
		do
			spawn(function()

				letters[person..'_'..i].TextStrokeTransparency = 0.75
				while 1 do
					if letters.Parent == nil then
						break
					end
					local red = math.sin(frequency * i + 4 + phase) * width + center
					local green = math.sin(frequency * i + 0 + phase) * width + center
					local blue = math.sin(frequency * i + 4 + phase) * width + center
					letters[person..'_'..i].TextColor3 = Color3.new(red/255, 0, 0)
					phase = phase + 0.01
					game:GetService("RunService").RenderStepped:wait()
				end
			end
			)
		end
	end
end
efx.Gradient = function(person, letters, speech)

	local phase = 0
	local col = Color3.new(1,0.1,0.1)
	local frequency = math.pi / speech:len()
	local widthr = math.floor(col.r * 255)
	local widthg = math.floor(col.g * 255)
	local widthb = math.floor(col.b * 255)
	for i = 1, #letters:GetChildren() do
		do
			spawn(function()

				while 1 do
					if letters.Parent == nil then
						break
					end
					local red = math.sin(frequency * (i + phase)) * (255 - widthr) + 255
					local green = math.sin(frequency * (i + phase)) * (255 - widthg) + 255
					local blue = math.sin(frequency * (i + phase)) * (255 - widthb) + 255
					letters[person..'_'..i].TextColor3 = Color3.new(red / 255, green / 255, blue / 255)
					phase = phase + 0.05
					game:GetService("RunService").RenderStepped:wait()
				end
			end
			)
		end
	end
end

efx.Ugly = function(letters, speech) --fixed

	local center = 128
	local width = 127
	local phase = 0
	local frequency = math.pi * 2 / speech
	for i, v in next, letters do
		do
			spawn(function()
				while 1 do
					local red = math.sin(frequency * i + 2 + phase) * width + center
					local green = math.sin(frequency * i + 0 + phase) * width + center
					local blue = math.sin(frequency * i + 4 + phase) * width + center
					letters[i].ImageColor3 = Color3.new(red / 255, green/255, blue / 255)
					phase = phase + 0.01
					wait()
				end
			end
			)
		end
	end
end


efx.Ugly2 = function(person, letters, speech)

	local center = 128
	local width = 127
	local phase = 0
	local frequency = math.pi * 2 / speech:len()
	for i = 1, #letters:GetChildren() do
		do
			spawn(function()

				letters[person..'_'..i].TextStrokeTransparency = 0.75
				while 1 do
					if letters.Parent == nil then
						break
					end
					local red = math.sin(frequency * i + 2 + phase) * width + center
					local green = math.sin(frequency * i + 0 + phase) * width + center
					local blue = math.sin(frequency * i + 4 + phase) * width + center
					letters[person..'_'..i].TextStrokeColor3 = Color3.new(red / 255, green/255, blue / 255)
					phase = phase + 0.01
					game:GetService("RunService").RenderStepped:wait()
				end
			end
			)
		end
	end
end
efx.Pink = function(person, letters, speech)

	local center = 128
	local width = 127
	local phase = 0
	local frequency = math.pi * 2 / speech:len()
	for i = 1, #letters:GetChildren() do
		do
			spawn(function()

				letters[i].TextStrokeTransparency = 0.75
				while 1 do
					if letters.Parent == nil then
						break
					end
					local red = math.sin(frequency * i + 3 + phase) * width + center
					local green = math.sin(frequency * i + 0 + phase) * width + center
					local blue = math.sin(frequency * i + 3 + phase) * width + center
					letters[i].TextColor3 = Color3.new(red / 255, 0, blue / 255)
					phase = phase + 0.01
					game:GetService("RunService").RenderStepped:wait()
				end
			end
			)
		end
	end
end
efx.Kool = function(person, letters, speech)

	local center = 128
	local width = 127
	local phase = 0
	local frequency = math.pi * 2 / speech:len()
	for i = 1, #letters:GetChildren() do
		do
			spawn(function()

				letters[i].TextStrokeTransparency = 0.75
				while 1 do
					if letters.Parent == nil then
						break
					end
					local red = math.sin(frequency * i + 3 + phase) * width + center
					local green = math.sin(frequency * i + 0 + phase) * width + center
					local blue = math.sin(frequency * i + 3 + phase) * width + center
					letters[i].TextColor3 = Color3.new((red/2) / 255, green /255, (blue/2)/ 255)
					phase = phase + 0.01
					game:GetService("RunService").RenderStepped:wait()
				end
			end
			)
		end
	end
end

return efx 