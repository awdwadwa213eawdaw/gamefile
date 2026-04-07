local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local url = "https://raw.githubusercontent.com/awdwadwa213eawdaw/game-uploader/refs/heads/main/Baba/productrandomizer.json"

local t = tick()
local lastnum = 0
local servermade = true

local ok, r = pcall(function()
	return HttpService:GetAsync(url)
end)

if ok and r and r ~= '' then
	local ok, decode = pcall(function()
		return HttpService:JSONDecode(r)
	end)
	
	if ok and typeof(decode) == "table" then
		RunService.Heartbeat:Connect(function()
			if math.round(tick() - t) >= 1600 or servermade then
				if servermade then servermade = false end
				local rand = math.random(1, #decode)
				
				while rand == lastnum and #decode > 1 do
					rand = math.random(1, #decode)
				end
				
				local function randomizeId(directory)
					local ids = directory

					for i, obj in ipairs(ids) do
						if obj.Name ~= "RoPowers" then
							local val = decode[rand][obj.Name]

							if val then
								obj.Value = val
							end
						else
							local ro = decode[rand].RoPowers

							for i, indexnum in ipairs(obj:GetChildren()) do
								local index = tonumber(indexnum.Name)
								local set = ro[index]

								if set then
									for innerindex, numval in ipairs(indexnum:GetChildren()) do
										local id = set[innerindex]

										if id then
											numval.Value = id
										end
									end
								end
							end
						end
					end
				end
				
				randomizeId(ServerStorage:WaitForChild("src"):WaitForChild("Assets"):WaitForChild("IDs"):GetChildren())
				
				lastnum = rand
				t = tick()
			end
		end)
	else
		warn("Failed to decode JSON in " .. script.Name .. ". Heartbeat will not be ran.")
	end
else
	warn("Failed to get response from HTTP in " .. script.Name)
end