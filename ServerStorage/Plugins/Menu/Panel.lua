return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local write = Utilities.Write

	local panel = {
		isOpenPanel = false,
		isOpenSpawner = false,
		isOpenUtilities = false,
		isOpenShowdown = false
	}
	local gui1, gui2, gui, gui3, bg, close

	-- Helper function to format names (remove spaces, hyphens, lowercase)
	local function formatName(name)
		if not name then return "" end
		return string.lower(name:gsub("%s+", ""):gsub("-", ""):gsub("'", ""):gsub(":", ""))
	end

	-- Pokemon name mappings for special cases
	local pokemonNameMappings = {
		["tinglu"] = "TingLu",
		["chienpao"] = "ChienPao",
		["wochien"] = "WoChien",
		["chiyu"] = "ChiYu",
		["tapukoko"] = "TapuKoko",
		["tapulele"] = "TapuLele",
		["tapubulu"] = "TapuBulu",
		["tapufini"] = "TapuFini",
		["typenull"] = "TypeNull",
		["mimejr"] = "MimeJr",
		["mrmime"] = "MrMime",
		["mrrime"] = "MrRime",
		["porygonz"] = "PorygonZ",
		["porygon2"] = "Porygon2",
		["hooh"] = "HoOh",
		["kommoo"] = "Kommoo",
		["hakamoo"] = "Hakamoo",
		["jangmoo"] = "Jangmoo",
		["nidoranf"] = "NidoranF",
		["nidoranm"] = "NidoranM",
		["greattusk"] = "GreatTusk",
		["screamtail"] = "ScreamTail",
		["brutebonnet"] = "BruteBonnet",
		["fluttermane"] = "FlutterMane",
		["slitherwing"] = "SlitherWing",
		["sandyshocks"] = "SandyShocks",
		["irontreads"] = "IronTreads",
		["ironbundle"] = "IronBundle",
		["ironhands"] = "IronHands",
		["ironjugulis"] = "IronJugulis",
		["ironmoth"] = "IronMoth",
		["ironthorns"] = "IronThorns",
		["roaringmoon"] = "RoaringMoon",
		["ironvaliant"] = "IronValiant",
		["walkingwake"] = "WalkingWake",
		["ironleaves"] = "IronLeaves",
		["gougingfire"] = "GougingFire",
		["ragingbolt"] = "RagingBolt",
		["ironboulder"] = "IronBoulder",
		["ironcrown"] = "IronCrown",
	}

	-- Form mappings
	local formMappings = {
		["alola"] = "Alolan",
		["alolan"] = "Alolan",
		["galar"] = "Galarian",
		["galarian"] = "Galarian",
		["hisui"] = "Hisuian",
		["hisuian"] = "Hisuian",
		["paldea"] = "Paldean",
		["paldean"] = "Paldean",
		["mega"] = "Mega",
		["megax"] = "MegaX",
		["megay"] = "MegaY",
		["gmax"] = "Gmax",
		["primal"] = "Primal",
		["origin"] = "Origin",
		["therian"] = "Therian",
		["black"] = "Black",
		["white"] = "White",
		["dawn"] = "Dawn",
		["dusk"] = "Dusk",
		["midnight"] = "Midnight",
		["midday"] = "Midday",
		["crowned"] = "Crowned",
		["ice"] = "Ice",
		["shadow"] = "Shadow",
		["blade"] = "Blade",
		["shield"] = "Shield",
		["heat"] = "Heat",
		["wash"] = "Wash",
		["frost"] = "Frost",
		["fan"] = "Fan",
		["mow"] = "Mow",
		["sky"] = "Sky",
		["zen"] = "Zen",
		["unbound"] = "Unbound",
		["10"] = "10",
		["50"] = "50",
		["complete"] = "Complete",
		["sensu"] = "Sensu",
		["pompom"] = "PomPom",
		["pau"] = "Pau",
		["baile"] = "Baile",
	}

	-- Natures list
	local natures = {'Hardy', 'Lonely', 'Brave', 'Adamant', 'Naughty', 'Bold', 'Docile', 'Relaxed', 'Impish', 'Lax', 'Timid', 'Hasty', 'Serious', 'Jolly', 'Naive', 'Modest', 'Mild','Quiet','Bashful','Rash','Calm','Gentle','Sassy','Careful','Quirky'} 

	local function GetNatureNumber(nature)
		if not nature then return 1 end
		for i = 1, #natures do
			if string.lower(natures[i]) == string.lower(nature) then
				return i
			end
		end
		return 1
	end

	-- Parse Pokemon Showdown format
	local function parseShowdownFormat(data)
		local pokemon = {}
		local currentPoke = nil

		local function processPokemonName(rawName)
			local name = rawName
			local forme = ""

			if name:find("-") then
				local parts = {}
				for part in name:gmatch("[^-]+") do
					table.insert(parts, part)
				end

				if #parts >= 2 then
					local baseName = parts[1]
					local formPart = table.concat(parts, "", 2)
					local formKey = string.lower(formPart)

					if formMappings[formKey] then
						forme = formMappings[formKey]
						name = baseName
					else
						name = table.concat(parts, "")
					end
				end
			end

			local lowerName = string.lower(name:gsub("-", ""):gsub(" ", ""))
			if pokemonNameMappings[lowerName] then
				name = pokemonNameMappings[lowerName]
			end

			return name, forme
		end

		for line in data:gmatch("[^\r\n]+") do
			line = line:match("^%s*(.-)%s*$")

			if line ~= "" then
				local nickname, pokeName, item

				nickname, pokeName, item = line:match("^(.-)%s*%((.-)%)%s*@%s*(.+)")
				if not pokeName then
					nickname, pokeName = line:match("^(.-)%s*%((.-)%)")
					if not pokeName then
						pokeName, item = line:match("^([^@%(]+)@%s*(.+)")
						if pokeName then
							pokeName = pokeName:match("^%s*(.-)%s*$")
						end
					end
				end

				if not pokeName and not line:match("^%-") and not line:match(":") and not line:match("Nature") and not line:match("EVs") and not line:match("IVs") then
					local testName = line:match("^%s*([%a%-%s]+)%s*$")
					if testName and #testName > 2 then
						pokeName = testName
					end
				end

				if pokeName then
					if currentPoke then
						table.insert(pokemon, currentPoke)
					end

					local processedName, detectedForme = processPokemonName(pokeName)

					currentPoke = {
						name = processedName,
						nickname = nickname and nickname:match("^%s*(.-)%s*$") or "",
						item = item and formatName(item) or "",
						evs = {0, 0, 0, 0, 0, 0},
						ivs = {31, 31, 31, 31, 31, 31},
						natureNum = 1,
						natureName = "Hardy",
						moves = {},
						shiny = false,
						hiddenAbility = false,
						egg = false,
						forme = detectedForme,
						ability = "",
						gender = "",
						teraType = "",
						level = 100,
						happiness = 255,
					}
				elseif currentPoke then
					local evStr = line:match("EVs:%s*(.+)")
					if evStr then
						for value, stat in evStr:gmatch("(%d+)%s*(%a+)") do
							local v = tonumber(value)
							stat = stat:lower()
							if stat == "hp" then currentPoke.evs[1] = v
							elseif stat == "atk" then currentPoke.evs[2] = v
							elseif stat == "def" then currentPoke.evs[3] = v
							elseif stat == "spa" then currentPoke.evs[4] = v
							elseif stat == "spd" then currentPoke.evs[5] = v
							elseif stat == "spe" then currentPoke.evs[6] = v
							end
						end
					end

					local ivStr = line:match("IVs:%s*(.+)")
					if ivStr then
						for value, stat in ivStr:gmatch("(%d+)%s*(%a+)") do
							local v = tonumber(value)
							stat = stat:lower()
							if stat == "hp" then currentPoke.ivs[1] = v
							elseif stat == "atk" then currentPoke.ivs[2] = v
							elseif stat == "def" then currentPoke.ivs[3] = v
							elseif stat == "spa" then currentPoke.ivs[4] = v
							elseif stat == "spd" then currentPoke.ivs[5] = v
							elseif stat == "spe" then currentPoke.ivs[6] = v
							end
						end
					end

					local nature = line:match("(%a+)%s+Nature")
					if nature then
						currentPoke.natureNum = GetNatureNumber(nature)
						currentPoke.natureName = nature
					end

					local ability = line:match("Ability:%s*(.+)")
					if ability then
						currentPoke.ability = ability:match("^%s*(.-)%s*$")
					end

					local level = line:match("Level:%s*(%d+)")
					if level then
						currentPoke.level = tonumber(level)
					end

					local teraType = line:match("Tera Type:%s*(%a+)")
					if teraType then
						currentPoke.teraType = teraType
					end

					local happiness = line:match("Happiness:%s*(%d+)")
					if happiness then
						currentPoke.happiness = tonumber(happiness)
					end

					if line:match("Shiny:%s*Yes") then
						currentPoke.shiny = true
					end

					local gender = line:match("Gender:%s*(%a+)")
					if gender then
						currentPoke.gender = gender
					end

					local move = line:match("^%-%s*(.+)")
					if move then
						table.insert(currentPoke.moves, {id = formatName(move), displayName = move:match("^%s*(.-)%s*$")})
					end
				end
			end
		end

		if currentPoke then
			table.insert(pokemon, currentPoke)
		end

		return pokemon
	end

	-- =====================
	-- MAIN PANEL
	-- =====================
	function panel:openPanel()
		if self.isOpenPanel then return end
		self.isOpenPanel = true

		spawn(function() _p.Menu:disable() end)

		if not gui1 then
			bg = create 'Frame' {
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(0, 0, 0),
				Size = UDim2.new(1.0, 0, 1.0, 36),
				Position = UDim2.new(0.0, 0, 0.0, -36),
			}
			gui1 = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://11106811143',
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.9, 0, 0.9, 0),
				ZIndex = 2,
			}

			close = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(28, 18, 29),
				Size = UDim2.new(.31, 0, .08, 0),
				Position = UDim2.new(.65, 0, -.03, 0),
				ZIndex = 3, Parent = gui1,
			}
			close.gui.MouseButton1Click:connect(function()
				self:closePanel()
			end)
			write 'Close' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.6, 0),
					Position = UDim2.new(0.0, 0, 0.2, 0),
					Parent = close.gui,
					ZIndex = 4,
				}, Scaled = true,
			}	

			local spawnerb = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.1, 0),
				ZIndex = 3, Parent = gui1,
			}
			spawnerb.gui.MouseButton1Click:connect(function()
				self:fastClosePanel()
				self:openSpawner()
			end)
			write 'Spawner' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.6, 0),
					Position = UDim2.new(0.0, 0, 0.2, 0),
					Parent = spawnerb.gui,
					ZIndex = 4,
				}, Scaled = true,
			}	

			local utilitiesb = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.55, 0, 0.1, 0),
				ZIndex = 3, Parent = gui1,
			}
			utilitiesb.gui.MouseButton1Click:connect(function()
				self:fastClosePanel()
				self:openUtilities()
			end)
			write 'Utilities' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.6, 0),
					Position = UDim2.new(0.0, 0, 0.2, 0),
					Parent = utilitiesb.gui,
					ZIndex = 4,
				}, Scaled = true,
			}

			local showdownb = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(80, 120, 200),
				Size = UDim2.new(0.9, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.22, 0),
				ZIndex = 3, Parent = gui1,
			}
			showdownb.gui.MouseButton1Click:connect(function()
				self:fastClosePanel()
				self:openShowdown()
			end)
			write 'Showdown Import' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.6, 0),
					Position = UDim2.new(0.0, 0, 0.2, 0),
					Parent = showdownb.gui,
					ZIndex = 4,
				}, Scaled = true,
			}
		end
		bg.Parent = Utilities.gui
		gui1.Parent = Utilities.gui
		close.CornerRadius = Utilities.gui.AbsoluteSize.Y*.015

		Utilities.Tween(.8, 'easeOutCubic', function(a)
			if not self.isOpenPanel then return false end
			bg.BackgroundTransparency = 1-.3*a
			gui1.Position = UDim2.new(1-.5*a, -gui1.AbsoluteSize.X/2*a, 0.05, 0)
		end)
	end

	function panel:closePanel()
		if not self.isOpenPanel then return end
		self.isOpenPanel = false

		spawn(function() _p.Menu:enable() end)

		Utilities.Tween(.8, 'easeOutCubic', function(a)
			if self.isOpenPanel then return false end
			bg.BackgroundTransparency = .7+.3*a
			gui1.Position = UDim2.new(.5+.5*a, -gui1.AbsoluteSize.X/2*(1-a), 0.05, 0)
		end)

		bg.Parent = nil
		gui1.Parent = nil

		_p.MasterControl.WalkEnabled = true
	end

	function panel:fastClosePanel(enableWalk)
		if not self.isOpenPanel then return end
		self.isOpenPanel = false

		bg.BackgroundTransparency = 1.0
		gui1.Position = UDim2.new(1.0, 0, 0.05, 0)
		bg.Parent = nil
		gui1.Parent = nil

		if enableWalk then
			_p.MasterControl.WalkEnabled = true
		end
	end

	-- =====================
	-- UTILITIES PANEL
	-- =====================
	function panel:openUtilities()
		if self.isOpenUtilities then return end
		self.isOpenUtilities = true

		if not gui2 then
			bg = create 'Frame' {
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(0, 0, 0),
				Size = UDim2.new(1.0, 0, 1.0, 36),
				Position = UDim2.new(0.0, 0, 0.0, -36),
			}
			gui2 = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://11106811143',
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.9, 0, 0.9, 0),
				ZIndex = 2,
			}

			close = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(28, 18, 29),
				Size = UDim2.new(.31, 0, .08, 0),
				Position = UDim2.new(.65, 0, -.03, 0),
				ZIndex = 3, Parent = gui2,
			}
			close.gui.MouseButton1Click:connect(function()
				self:fastCloseUtilities()
				self:openPanel()
			end)
			write 'Close' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.6, 0),
					Position = UDim2.new(0.0, 0, 0.2, 0),
					Parent = close.gui,
					ZIndex = 4,
				}, Scaled = true,
			}	

			local openables = {"PC", "Shop", "BP Shop", "Furniture"}
			local c = 1			
			local opening = {
				["PC"] = function() 
					_p.Menu.pc:bootUp()
				end, 
				["Shop"] = function()
					_p.Menu.shop:open()
				end, 
				["BP Shop"] = function()
					_p.Menu.battleShop:open()
				end,
				["Furniture"] = function()
					_p.Menu.FurnitureStore:open(maingui)
				end,
			}

			local ToOpnButton = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.1, 0),
				ZIndex = 3, Parent = gui2,
			}

			local ToOpen = create 'TextLabel' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(.8, .8, .8),
				TextScaled = true,
				Text = openables[c],
				Name = "ToOpen",
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.1, 0),
				ZIndex = 4, Parent = gui2
			}

			ToOpnButton.gui.MouseButton1Click:connect(function()
				if c >= #openables then
					c = 1
				else
					c = c + 1
				end
				ToOpen.Text = openables[c]
			end)

			local OpnButton = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.55, 0, 0.1, 0),
				ZIndex = 3, Parent = gui2,
			}
			OpnButton.gui.MouseButton1Click:connect(function()
				self:fastCloseUtilities(true)
				wait(.1)
				opening[openables[c]]()
			end)
			write 'Open' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.4, 0, 0.05, 0),
					Position = UDim2.new(0.55, 0, 0.125, 0),
					ZIndex = 4, Parent = gui2,
				}, Scaled = true, Color = Color3.new(.8, .8, .8),
			}

			local healb = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.55, 0, 0.22, 0),
				ZIndex = 3, Parent = gui2,
			}
			healb.gui.MouseButton1Click:connect(function()
				_p.Network:get('PDS', 'getHealing')
				_p.NPCChat:say('Party successfully healed!')
			end)
			write 'Heal Party' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.4, 0, 0.05, 0),
					Position = UDim2.new(0.55, 0, 0.245, 0),
					ZIndex = 3, Parent = gui2,
				}, Scaled = true,
			}

			local perms = _p.Network:get('PDS', 'GetPerms')

			local playerInput = { Text = '' }

			if perms and perms[2] then
				local playerback = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.05, 0, 0.22, 0),
					ZIndex = 3, Parent = gui2,
				}
				playerInput = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					ClearTextOnFocus = false,
					Text = '',
					PlaceholderText = 'Player',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.05, 0, 0.22, 0),
					ZIndex = 4, Parent = gui2
				}

				local unixback = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.05, 0, 0.7, 0),
					ZIndex = 3, Parent = gui2,
				}
				local uinx = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					ClearTextOnFocus = false,
					Text = '',
					PlaceholderText = 'Unix Time',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.05, 0, 0.7, 0),
					ZIndex = 4, Parent = gui2
				}

				local reasonback = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.55, 0, 0.7, 0),
					ZIndex = 3, Parent = gui2,
				}
				local reason = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					ClearTextOnFocus = false,
					Text = '',
					PlaceholderText = 'Reason',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.55, 0, 0.7, 0),
					ZIndex = 4, Parent = gui2
				}

				local shutdownbutton = _p.RoundedFrame:new {
					Button = true,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.9, 0, 0.1, 0),
					Position = UDim2.new(0.05, 0, 0.82, 0),
					ZIndex = 3, Parent = gui2,
				}
				shutdownbutton.gui.MouseButton1Click:connect(function()
					if _p.NPCChat:say('[y/n]Are you sure?') then
						local cancel = false
						local msg = 'Initiating Shutdown...'

						if tostring(uinx.Text) == 'Cancel' then
							cancel = true
							msg = 'Canceling Shutdown...'
						end
						if tostring(reason.Text) == '' and not cancel then
							reason.Text = 'Bug Fixes'
						end
						if not tonumber(uinx.Text) and not cancel then
							uinx.Text = tostring(os.time() + 600)
						end

						local dat = {
							ts = os.time(),
							id = math.random(1, 1000000),
							kind = 'ShutDown',
						}
						if not cancel then
							dat['shutdownTime'] = tonumber(uinx.Text) or os.time() + 600
							dat['reason'] = tostring(reason.Text)
						else
							dat['cancel'] = true
						end

						pcall(function() return _p.Network:get('PDS', 'ShutdownServers', dat) end)
						_p.NPCChat:say(msg)
					end
				end)
				write 'Shutdown All Servers' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.9, 0, 0.05, 0),
						Position = UDim2.new(0.05, 0, 0.845, 0),
						ZIndex = 3, Parent = gui2,
					}, Scaled = true, Color = Color3.fromRGB(255, 100, 100)
				}
			end

			local itemidback = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.34, 0),
				ZIndex = 3, Parent = gui2,
			}
			local itemid = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				ClearTextOnFocus = false,
				Text = '',
				PlaceholderText = 'Item Id',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.34, 0),
				ZIndex = 4, Parent = gui2
			}

			local itemqback = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.55, 0, 0.34, 0),
				ZIndex = 3, Parent = gui2,
			}
			local itemq = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				ClearTextOnFocus = false,
				Text = '',
				PlaceholderText = 'Item Quantity',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.55, 0, 0.34, 0),
				ZIndex = 4, Parent = gui2
			}

			local openables1 = {"Money", "BP", "Tix", 'Stamp'}
			local c1 = 1

			local currencyback = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.46, 0),
				ZIndex = 3, Parent = gui2,
			}

			local currency = create 'TextLabel' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(.8, .8, .8),
				TextScaled = true,
				Text = openables1[c1],
				Name = "currency",
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.46, 0),
				ZIndex = 4, Parent = gui2
			}

			currencyback.gui.MouseButton1Click:connect(function()
				if c1 >= #openables1 then
					c1 = 1
				else
					c1 = c1 + 1
				end
				currency.Text = openables1[c1]
			end)

			local currencyqback = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.55, 0, 0.46, 0),
				ZIndex = 3, Parent = gui2,
			}
			local currencyq = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				ClearTextOnFocus = false,
				Text = '',
				PlaceholderText = 'Currency Quantity',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.55, 0, 0.46, 0),
				ZIndex = 4, Parent = gui2
			}

			local itembutton = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.58, 0),
				ZIndex = 3, Parent = gui2,
			}
			itembutton.gui.MouseButton1Click:connect(function()
				if itemid.Text == '' then
					_p.NPCChat:say("Please Enter a Item Id.")
					return
				end
				local playerTarget = playerInput.Text
				if playerTarget == _p.player.Name then
					playerTarget = ''
				end
				local msg = "Spawned "..tostring(tonumber(itemq.Text) or 1)..' '..itemid.Text..'!'
				if playerTarget ~= '' then
					msg = "Spawned "..tostring(tonumber(itemq.Text) or 1)..' '..itemid.Text..' for '..playerTarget..'!'
				end
				local dat = {
					itemid = itemid.Text,
					quantity = tonumber(itemq.Text) or 1
				}
				local s,r = pcall(function() return _p.Network:get('PDS', 'SpawnItem', dat, playerTarget) end)
				if not s and r then
					msg = 'Could not spawn in '..itemid.Text..' because "'..r..'".'
				elseif not s and not r then
					msg = 'Could not spawn in '..itemid.Text..'.'
				elseif s and r then
					msg = r
				end
				_p.NPCChat:say(msg)
			end)
			write 'Spawn Item' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.4, 0, 0.05, 0),
					Position = UDim2.new(0.05, 0, 0.605, 0),
					ZIndex = 3, Parent = gui2,
				}, Scaled = true,
			}

			local currencybutton = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.55, 0, 0.58, 0),
				ZIndex = 3, Parent = gui2,
			}
			currencybutton.gui.MouseButton1Click:connect(function()
				local playerTarget = playerInput.Text
				if playerTarget == _p.player.Name then
					playerTarget = ''
				end
				local msg = "Spawned "..tostring(tonumber(currencyq.Text) or 1)..' '..currency.Text..'!'
				if playerTarget ~= '' then
					msg = "Spawned "..tostring(tonumber(currencyq.Text) or 1)..' '..currency.Text..' for '..playerTarget..'!'
				end
				local dat = {
					currency = currency.Text,
					quantity = tonumber(currencyq.Text) or 1
				}
				local s,r = pcall(function() return _p.Network:get('PDS', 'SpawnCurrency', dat, playerTarget) end)
				if not s and r then
					msg = 'Could not spawn in '..currency.Text..' because "'..r..'".'
				elseif not s and not r then
					msg = 'Could not spawn in '..currency.Text..'.'
				elseif s and r then
					msg = r
				end
				_p.NPCChat:say(msg)
			end)
			write 'Spawn Currency' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.4, 0, 0.05, 0),
					Position = UDim2.new(0.55, 0, 0.605, 0),
					ZIndex = 3, Parent = gui2,
				}, Scaled = true
			}
		end

		bg.Parent = Utilities.gui
		gui2.Parent = Utilities.gui
		close.CornerRadius = Utilities.gui.AbsoluteSize.Y*.015

		Utilities.Tween(.8, 'easeOutCubic', function(a)
			if not self.isOpenUtilities then return false end
			bg.BackgroundTransparency = 1-.3*a
			gui2.Position = UDim2.new(1-.5*a, -gui2.AbsoluteSize.X/2*a, 0.05, 0)
		end)
	end

	function panel:fastCloseUtilities(enableWalk)
		if not self.isOpenUtilities then return end
		self.isOpenUtilities = false

		bg.BackgroundTransparency = 1.0
		gui2.Position = UDim2.new(1.0, 0, 0.05, 0)
		bg.Parent = nil
		gui2.Parent = nil

		if enableWalk then
			spawn(function() _p.Menu:enable() end)
			_p.MasterControl.WalkEnabled = true
		end
	end

	-- =====================
	-- SPAWNER PANEL (FULL FEATURES)
	-- =====================
	function panel:openSpawner()
		if self.isOpenSpawner then return end
		self.isOpenSpawner = true

		if not gui then
			bg = create 'Frame' {
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(0, 0, 0),
				Size = UDim2.new(1.0, 0, 1.0, 36),
				Position = UDim2.new(0.0, 0, 0.0, -36),
			}
			gui = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://11106811143',
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.9, 0, 0.9, 0),
				ZIndex = 2,
			}

			-- Extended panels for IVs and EVs
			create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://11106811143',
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.55, 0, 1.0, 0),
				Position = UDim2.new(-0.55, 0, 0, 0),
				ZIndex = 2, Parent = gui,
			}

			create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://11106811143',
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.55, 0, 1.0, 0),
				Position = UDim2.new(1.0, 0, 0, 0),
				ZIndex = 2, Parent = gui,
			}

			close = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(35, 22, 34),
				Size = UDim2.new(.31, 0, .08, 0),
				Position = UDim2.new(.65, 0, -.03, 0),
				ZIndex = 3, Parent = gui,
			}
			close.gui.MouseButton1Click:connect(function()
				self:fastCloseSpawner()
				self:openPanel()
			end)
			write 'Close' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.6, 0),
					Position = UDim2.new(0.0, 0, 0.2, 0),
					Parent = close.gui,
					ZIndex = 4,
				}, Scaled = true,
			}

			-- =====================
			-- POKEMON INFO SECTION
			-- =====================
			write 'Pokemon Info:' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.035, 0),
					Position = UDim2.new(0.05, 0, 0.06, 0),
					ZIndex = 3, Parent = gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}

			-- Pokemon Name
			local PokeBack = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.35, 0, 0.07, 0),
				Position = UDim2.new(0.05, 0, 0.10, 0),
				ZIndex = 3, Parent = gui,
			}
			local poke = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				Text = '',
				PlaceholderText = 'Pokemon',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.35, 0, 0.07, 0),
				Position = UDim2.new(0.05, 0, 0.10, 0),
				ZIndex = 4, Parent = gui
			}

			-- Level
			local LvlBack = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.15, 0, 0.07, 0),
				Position = UDim2.new(0.42, 0, 0.10, 0),
				ZIndex = 3, Parent = gui,
			}
			local lvl = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				ClearTextOnFocus = false,
				Text = '100',
				PlaceholderText = 'Lvl',
				TextXAlignment = Enum.TextXAlignment.Center,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.15, 0, 0.07, 0),
				Position = UDim2.new(0.42, 0, 0.10, 0),
				ZIndex = 4, Parent = gui
			}

			-- Nickname
			local NicknameBack = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.35, 0, 0.07, 0),
				Position = UDim2.new(0.59, 0, 0.10, 0),
				ZIndex = 3, Parent = gui,
			}
			local nickname = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				Text = '',
				PlaceholderText = 'Nickname',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.35, 0, 0.07, 0),
				Position = UDim2.new(0.59, 0, 0.10, 0),
				ZIndex = 4, Parent = gui
			}

			-- Toggles Row 1
			local shin = false
			local Shiny = _p.ToggleButton:new {
				Size = UDim2.new(0.0, 0, 0.05, 0),
				Position = UDim2.new(0.28, 0, 0.185, 0),
				Value = false,
				ZIndex = 3, Parent = gui,
			}
			Shiny.ValueChanged:connect(function()
				shin = Shiny.Value
			end)				
			write 'Shiny' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.028, 0),
					Position = UDim2.new(0.05, 0, 0.195, 0),
					ZIndex = 3, Parent = gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}

			local AH = false
			local HA = _p.ToggleButton:new {
				Size = UDim2.new(0.0, 0, 0.05, 0),
				Position = UDim2.new(0.55, 0, 0.185, 0),
				Value = false,
				ZIndex = 3, Parent = gui,
			}
			HA.ValueChanged:connect(function()
				AH = HA.Value
			end)
			write 'HA' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.03, 0),
					Position = UDim2.new(0.35, 0, 0.195, 0),
					ZIndex = 3, Parent = gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}

			local egg = false
			local Egg = _p.ToggleButton:new {
				Size = UDim2.new(0.0, 0, 0.05, 0),
				Position = UDim2.new(0.80, 0, 0.185, 0),
				Value = false,
				ZIndex = 3, Parent = gui,
			}
			Egg.ValueChanged:connect(function()
				egg = Egg.Value
			end)
			write 'Egg' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.03, 0),
					Position = UDim2.new(0.62, 0, 0.195, 0),
					ZIndex = 3, Parent = gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}

			-- Toggles Row 2
			local pokerus = false
			local Pokerus = _p.ToggleButton:new {
				Size = UDim2.new(0.0, 0, 0.05, 0),
				Position = UDim2.new(0.28, 0, 0.24, 0),
				Value = false,
				ZIndex = 3, Parent = gui,
			}
			Pokerus.ValueChanged:connect(function()
				pokerus = Pokerus.Value
			end)
			write 'Pokerus' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.028, 0),
					Position = UDim2.new(0.05, 0, 0.25, 0),
					ZIndex = 3, Parent = gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}

			-- Nature
			local NatureBack = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.28, 0, 0.07, 0),
				Position = UDim2.new(0.05, 0, 0.30, 0),
				ZIndex = 3, Parent = gui,
			}				
			local nature = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				Text = natures[math.random(#natures)],
				PlaceholderText = 'Nature',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.28, 0, 0.07, 0),
				Position = UDim2.new(0.05, 0, 0.30, 0),
				ZIndex = 4, Parent = gui
			}

			-- Random Nature Button
			local randomNatureBtn = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(100, 100, 150),
				Size = UDim2.new(0.06, 0, 0.07, 0),
				Position = UDim2.new(0.34, 0, 0.30, 0),
				ZIndex = 3, Parent = gui,
			}
			randomNatureBtn.gui.MouseButton1Click:connect(function()
				nature.Text = natures[math.random(#natures)]
			end)
			write '?' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.06, 0, 0.04, 0),
					Position = UDim2.new(0.34, 0, 0.315, 0),
					ZIndex = 4, Parent = gui,
				}, Scaled = true,
			}

			-- Forme
			local FormeBack = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.25, 0, 0.07, 0),
				Position = UDim2.new(0.42, 0, 0.30, 0),
				ZIndex = 3, Parent = gui,
			}
			local POKEFORME = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				Text = '',
				PlaceholderText = 'Form',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.25, 0, 0.07, 0),
				Position = UDim2.new(0.42, 0, 0.30, 0),
				ZIndex = 4, Parent = gui
			}

			-- Happiness
			local HappinessBack = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.25, 0, 0.07, 0),
				Position = UDim2.new(0.69, 0, 0.30, 0),
				ZIndex = 3, Parent = gui,
			}
			local happiness = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				Text = '255',
				PlaceholderText = 'Happy',
				TextXAlignment = Enum.TextXAlignment.Center,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.25, 0, 0.07, 0),
				Position = UDim2.new(0.69, 0, 0.30, 0),
				ZIndex = 4, Parent = gui
			}

			-- Item
			local pokemonitemback = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.43, 0, 0.07, 0),
				Position = UDim2.new(0.05, 0, 0.39, 0),
				ZIndex = 3, Parent = gui,
			}
			local pokemonitem = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				Text = '',
				PlaceholderText = 'Held Item',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.43, 0, 0.07, 0),
				Position = UDim2.new(0.05, 0, 0.39, 0),
				ZIndex = 4, Parent = gui
			}

			-- Ball Type
			local ballTypes = {"pokeball", "greatball", "ultraball", "masterball", "premierball", "luxuryball", "healball", "quickball", "duskball", "timerball", "nestball", "netball", "diveball", "repeatball", "friendball", "levelball", "lureball", "heavyball", "loveball", "fastball", "moonball", "dreamball", "beastball"}
			local currentBallIndex = 1

			local BallBack = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.23, 0, 0.07, 0),
				Position = UDim2.new(0.50, 0, 0.39, 0),
				ZIndex = 3, Parent = gui,
			}
			local ballTypeLabel = create 'TextLabel' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(.9, .9, .9),
				TextScaled = true, 
				Text = ballTypes[currentBallIndex],
				Name = "BallType",
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.23, 0, 0.07, 0),
				Position = UDim2.new(0.50, 0, 0.39, 0),
				ZIndex = 4, Parent = gui
			}
			BallBack.gui.MouseButton1Click:connect(function()
				currentBallIndex = currentBallIndex + 1
				if currentBallIndex > #ballTypes then
					currentBallIndex = 1
				end
				ballTypeLabel.Text = ballTypes[currentBallIndex]
			end)

			-- Gender
			local genders = {"Random", "Male", "Female", "Genderless"}
			local currentGenderIndex = 1

			local GenderBack = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.20, 0, 0.07, 0),
				Position = UDim2.new(0.75, 0, 0.39, 0),
				ZIndex = 3, Parent = gui,
			}
			local genderLabel = create 'TextLabel' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(.9, .9, .9),
				TextScaled = true, 
				Text = genders[currentGenderIndex],
				Name = "GenderType",
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.20, 0, 0.07, 0),
				Position = UDim2.new(0.75, 0, 0.39, 0),
				ZIndex = 4, Parent = gui
			}
			GenderBack.gui.MouseButton1Click:connect(function()
				currentGenderIndex = currentGenderIndex + 1
				if currentGenderIndex > #genders then
					currentGenderIndex = 1
				end
				genderLabel.Text = genders[currentGenderIndex]
			end)

			-- =====================
			-- MOVES SECTION
			-- =====================
			write 'Moves:' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.03, 0),
					Position = UDim2.new(0.05, 0, 0.48, 0),
					ZIndex = 4, Parent = gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}

			local moves1Back = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.43, 0, 0.055, 0),
				Position = UDim2.new(0.05, 0, 0.52, 0),
				ZIndex = 3, Parent = gui,
			}
			local moves1 = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				Text = '',
				PlaceholderText = 'Move 1',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.43, 0, 0.055, 0),
				Position = UDim2.new(0.05, 0, 0.52, 0),
				ZIndex = 4, Parent = gui
			}

			local moves2Back = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.43, 0, 0.055, 0),
				Position = UDim2.new(0.52, 0, 0.52, 0),
				ZIndex = 3, Parent = gui,
			}
			local moves2 = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				Text = '',
				PlaceholderText = 'Move 2',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.43, 0, 0.055, 0),
				Position = UDim2.new(0.52, 0, 0.52, 0),
				ZIndex = 4, Parent = gui
			}

			local moves3Back = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.43, 0, 0.055, 0),
				Position = UDim2.new(0.05, 0, 0.585, 0),
				ZIndex = 3, Parent = gui,
			}
			local moves3 = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				Text = '',
				PlaceholderText = 'Move 3',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.43, 0, 0.055, 0),
				Position = UDim2.new(0.05, 0, 0.585, 0),
				ZIndex = 4, Parent = gui
			}

			local moves4Back = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.43, 0, 0.055, 0),
				Position = UDim2.new(0.52, 0, 0.585, 0),
				ZIndex = 3, Parent = gui,
			}
			local moves4 = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				Text = '',
				PlaceholderText = 'Move 4',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.43, 0, 0.055, 0),
				Position = UDim2.new(0.52, 0, 0.585, 0),
				ZIndex = 4, Parent = gui
			}

			-- =====================
			-- IV SECTION (Left Panel)
			-- =====================
			write 'IVs (0-31):' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.5, 0, 0.035, 0),
					Position = UDim2.new(-0.52, 0, 0.02, 0),
					ZIndex = 3, Parent = gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}

			local ivLabels = {"HP", "Atk", "Def", "SpA", "SpD", "Spe"}
			local ivInputs = {}

			for i, label in ipairs(ivLabels) do
				local yPos = 0.07 + (i-1) * 0.085

				write(label) {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.12, 0, 0.03, 0),
						Position = UDim2.new(-0.52, 0, yPos + 0.02, 0),
						ZIndex = 3, Parent = gui,
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
				}

				local ivBack = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.30, 0, 0.065, 0),
					Position = UDim2.new(-0.35, 0, yPos, 0),
					ZIndex = 3, Parent = gui,
				}

				ivInputs[i] = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true, 
					ClearTextOnFocus = false,
					Text = '',
					PlaceholderText = '31',
					TextXAlignment = Enum.TextXAlignment.Center,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.30, 0, 0.065, 0),
					Position = UDim2.new(-0.35, 0, yPos, 0),
					ZIndex = 4, Parent = gui
				}
			end

			-- IV Buttons
			local perfectIVs = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(80, 150, 80),
				Size = UDim2.new(0.23, 0, 0.06, 0),
				Position = UDim2.new(-0.52, 0, 0.60, 0),
				ZIndex = 3, Parent = gui,
			}
			perfectIVs.gui.MouseButton1Click:connect(function()
				for i = 1, 6 do ivInputs[i].Text = '31' end
			end)
			write 'All 31' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.23, 0, 0.035, 0),
					Position = UDim2.new(-0.52, 0, 0.612, 0),
					ZIndex = 4, Parent = gui,
				}, Scaled = true, Color = Color3.new(1, 1, 1),
			}

			local zeroIVs = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(150, 80, 80),
				Size = UDim2.new(0.23, 0, 0.06, 0),
				Position = UDim2.new(-0.27, 0, 0.60, 0),
				ZIndex = 3, Parent = gui,
			}
			zeroIVs.gui.MouseButton1Click:connect(function()
				for i = 1, 6 do ivInputs[i].Text = '0' end
			end)
			write 'All 0' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.23, 0, 0.035, 0),
					Position = UDim2.new(-0.27, 0, 0.612, 0),
					ZIndex = 4, Parent = gui,
				}, Scaled = true, Color = Color3.new(1, 1, 1),
			}

			local randomIVs = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(100, 100, 150),
				Size = UDim2.new(0.48, 0, 0.06, 0),
				Position = UDim2.new(-0.52, 0, 0.68, 0),
				ZIndex = 3, Parent = gui,
			}
			randomIVs.gui.MouseButton1Click:connect(function()
				for i = 1, 6 do ivInputs[i].Text = tostring(math.random(0, 31)) end
			end)
			write 'Random IVs' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.48, 0, 0.035, 0),
					Position = UDim2.new(-0.52, 0, 0.692, 0),
					ZIndex = 4, Parent = gui,
				}, Scaled = true, Color = Color3.new(1, 1, 1),
			}

			-- Special IV Presets
			local specialAtkIV = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(130, 100, 150),
				Size = UDim2.new(0.23, 0, 0.06, 0),
				Position = UDim2.new(-0.52, 0, 0.76, 0),
				ZIndex = 3, Parent = gui,
			}
			specialAtkIV.gui.MouseButton1Click:connect(function()
				ivInputs[1].Text = '31'; ivInputs[2].Text = '0'; ivInputs[3].Text = '31'
				ivInputs[4].Text = '31'; ivInputs[5].Text = '31'; ivInputs[6].Text = '31'
			end)
			write 'Sp.Atk' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.23, 0, 0.035, 0),
					Position = UDim2.new(-0.52, 0, 0.772, 0),
					ZIndex = 4, Parent = gui,
				}, Scaled = true, Color = Color3.new(1, 1, 1),
			}

			local trickRoomIV = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(150, 100, 130),
				Size = UDim2.new(0.23, 0, 0.06, 0),
				Position = UDim2.new(-0.27, 0, 0.76, 0),
				ZIndex = 3, Parent = gui,
			}
			trickRoomIV.gui.MouseButton1Click:connect(function()
				ivInputs[1].Text = '31'; ivInputs[2].Text = '31'; ivInputs[3].Text = '31'
				ivInputs[4].Text = '31'; ivInputs[5].Text = '31'; ivInputs[6].Text = '0'
			end)
			write 'Trick Room' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.23, 0, 0.035, 0),
					Position = UDim2.new(-0.27, 0, 0.772, 0),
					ZIndex = 4, Parent = gui,
				}, Scaled = true, Color = Color3.new(1, 1, 1),
			}

			-- =====================
			-- EV SECTION (Right Panel)
			-- =====================
			write 'EVs (0-252):' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.5, 0, 0.035, 0),
					Position = UDim2.new(1.02, 0, 0.02, 0),
					ZIndex = 3, Parent = gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}

			local evInputs = {}

			for i, label in ipairs(ivLabels) do
				local yPos = 0.07 + (i-1) * 0.085

				write(label) {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.12, 0, 0.03, 0),
						Position = UDim2.new(1.02, 0, yPos + 0.02, 0),
						ZIndex = 3, Parent = gui,
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
				}

				local evBack = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.30, 0, 0.065, 0),
					Position = UDim2.new(1.19, 0, yPos, 0),
					ZIndex = 3, Parent = gui,
				}

				evInputs[i] = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true, 
					ClearTextOnFocus = false,
					Text = '',
					PlaceholderText = '0',
					TextXAlignment = Enum.TextXAlignment.Center,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.30, 0, 0.065, 0),
					Position = UDim2.new(1.19, 0, yPos, 0),
					ZIndex = 4, Parent = gui
				}
			end

			-- EV Total
			local evTotalLabel = create 'TextLabel' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(0.8, 0.8, 0.8),
				TextScaled = true,
				Text = 'Total: 0/510',
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.48, 0, 0.03, 0),
				Position = UDim2.new(1.02, 0, 0.59, 0),
				ZIndex = 4, Parent = gui
			}

			local function updateEVTotal()
				local total = 0
				for i = 1, 6 do total = total + (tonumber(evInputs[i].Text) or 0) end
				evTotalLabel.Text = 'Total: ' .. total .. '/510'
				evTotalLabel.TextColor3 = total > 510 and Color3.fromRGB(255, 100, 100) or Color3.new(0.8, 0.8, 0.8)
			end

			for i = 1, 6 do
				evInputs[i]:GetPropertyChangedSignal("Text"):Connect(updateEVTotal)
			end

			-- EV Buttons
			local physicalEV = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(180, 100, 80),
				Size = UDim2.new(0.23, 0, 0.06, 0),
				Position = UDim2.new(1.02, 0, 0.64, 0),
				ZIndex = 3, Parent = gui,
			}
			physicalEV.gui.MouseButton1Click:connect(function()
				evInputs[1].Text = '0'; evInputs[2].Text = '252'; evInputs[3].Text = '4'
				evInputs[4].Text = '0'; evInputs[5].Text = '0'; evInputs[6].Text = '252'
				updateEVTotal()
			end)
			write 'Physical' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.23, 0, 0.035, 0),
					Position = UDim2.new(1.02, 0, 0.652, 0),
					ZIndex = 4, Parent = gui,
				}, Scaled = true, Color = Color3.new(1, 1, 1),
			}

			local specialEV = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(80, 100, 180),
				Size = UDim2.new(0.23, 0, 0.06, 0),
				Position = UDim2.new(1.27, 0, 0.64, 0),
				ZIndex = 3, Parent = gui,
			}
			specialEV.gui.MouseButton1Click:connect(function()
				evInputs[1].Text = '0'; evInputs[2].Text = '0'; evInputs[3].Text = '0'
				evInputs[4].Text = '252'; evInputs[5].Text = '4'; evInputs[6].Text = '252'
				updateEVTotal()
			end)
			write 'Special' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.23, 0, 0.035, 0),
					Position = UDim2.new(1.27, 0, 0.652, 0),
					ZIndex = 4, Parent = gui,
				}, Scaled = true, Color = Color3.new(1, 1, 1),
			}

			local bulkyEV = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(80, 150, 80),
				Size = UDim2.new(0.23, 0, 0.06, 0),
				Position = UDim2.new(1.02, 0, 0.72, 0),
				ZIndex = 3, Parent = gui,
			}
			bulkyEV.gui.MouseButton1Click:connect(function()
				evInputs[1].Text = '252'; evInputs[2].Text = '0'; evInputs[3].Text = '252'
				evInputs[4].Text = '0'; evInputs[5].Text = '4'; evInputs[6].Text = '0'
				updateEVTotal()
			end)
			write 'Bulky' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.23, 0, 0.035, 0),
					Position = UDim2.new(1.02, 0, 0.732, 0),
					ZIndex = 4, Parent = gui,
				}, Scaled = true, Color = Color3.new(1, 1, 1),
			}

			local clearEV = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(150, 80, 80),
				Size = UDim2.new(0.23, 0, 0.06, 0),
				Position = UDim2.new(1.27, 0, 0.72, 0),
				ZIndex = 3, Parent = gui,
			}
			clearEV.gui.MouseButton1Click:connect(function()
				for i = 1, 6 do evInputs[i].Text = '0' end
				updateEVTotal()
			end)
			write 'Clear' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.23, 0, 0.035, 0),
					Position = UDim2.new(1.27, 0, 0.732, 0),
					ZIndex = 4, Parent = gui,
				}, Scaled = true, Color = Color3.new(1, 1, 1),
			}

			-- =====================
			-- SPAWN OPTIONS
			-- =====================
			local spawnCountBack = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.12, 0, 0.055, 0),
				Position = UDim2.new(0.05, 0, 0.66, 0),
				ZIndex = 3, Parent = gui,
			}
			local spawnCount = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				ClearTextOnFocus = false,
				Text = '1',
				PlaceholderText = 'Qty',
				TextXAlignment = Enum.TextXAlignment.Center,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.12, 0, 0.055, 0),
				Position = UDim2.new(0.05, 0, 0.66, 0),
				ZIndex = 4, Parent = gui
			}

			-- Admin Options
			local perms = _p.Network:get('PDS', 'GetPerms')
			local playerInput = { Text = '' }
			local UT = true

			if perms and perms[2] then
				local PlayerBack = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.30, 0, 0.055, 0),
					Position = UDim2.new(0.19, 0, 0.66, 0),
					ZIndex = 3, Parent = gui,
				}
				playerInput = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					ClearTextOnFocus = false,
					Text = '',
					PlaceholderText = 'Player',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.30, 0, 0.055, 0),
					Position = UDim2.new(0.19, 0, 0.66, 0),
					ZIndex = 4, Parent = gui
				}

				local UTb = _p.ToggleButton:new {
					Size = UDim2.new(0.0, 0, 0.04, 0),
					Position = UDim2.new(0.70, 0, 0.665, 0),
					Value = true,
					ZIndex = 3, Parent = gui,
				}
				write 'UT' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.025, 0),
						Position = UDim2.new(0.52, 0, 0.67, 0),
						ZIndex = 3, Parent = gui,
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
				}
				UTb.ValueChanged:connect(function()
					UT = UTb.Value
				end)
			end

			-- Status
			local statusLabel = create 'TextLabel' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(0.8, 0.8, 0.8),
				TextScaled = true,
				Text = '',
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.9, 0, 0.03, 0),
				Position = UDim2.new(0.05, 0, 0.96, 0),
				ZIndex = 4, Parent = gui
			}

			-- Spawn Button
			local spawnButton = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(50, 150, 50),
				Size = UDim2.new(0.9, 0, 0.08, 0),
				Position = UDim2.new(0.05, 0, 0.73, 0),
				ZIndex = 3, Parent = gui,
			}
			spawnButton.gui.MouseButton1Click:connect(function()
				if poke.Text == '' then
					statusLabel.Text = "Please enter a Pokemon name."
					return
				end

				local playerName = playerInput.Text
				if playerName == _p.player.Name then playerName = '' end

				local moves = {}
				if moves1.Text ~= '' then table.insert(moves, {id = formatName(moves1.Text)}) end
				if moves2.Text ~= '' then table.insert(moves, {id = formatName(moves2.Text)}) end
				if moves3.Text ~= '' then table.insert(moves, {id = formatName(moves3.Text)}) end
				if moves4.Text ~= '' then table.insert(moves, {id = formatName(moves4.Text)}) end

				if #moves == 0 then
					moves = {{id = "tackle"}, {id = "growl"}, {id = "quickattack"}, {id = "leer"}}
				end

				local ivs, evs = {}, {}
				for i = 1, 6 do
					ivs[i] = tonumber(ivInputs[i].Text) or math.random(0, 31)
					evs[i] = tonumber(evInputs[i].Text) or 0
				end

				local count = tonumber(spawnCount.Text) or 1
				local successCount = 0

				for c = 1, count do
					statusLabel.Text = "Spawning " .. c .. "/" .. count .. "..."

					local dat = {
						name = poke.Text,
						level = tonumber(lvl.Text) or 100,
						item = formatName(pokemonitem.Text),
						ivs = ivs,
						evs = evs,
						nature = GetNatureNumber(nature.Text),
						moves = moves,
						egg = egg,
						untradable = UT,
						shiny = shin,
						hiddenAbility = AH,
						happiness = tonumber(happiness.Text) or 255,
						pokerus = pokerus,
						ball = ballTypes[currentBallIndex],
					}

					if nickname.Text ~= '' then dat['nickname'] = nickname.Text end
					if POKEFORME.Text ~= '' then dat['forme'] = POKEFORME.Text end
					if genders[currentGenderIndex] ~= "Random" then dat['gender'] = genders[currentGenderIndex] end

					local playerr = game:GetService('Players').LocalPlayer
					dat['ot'] = playerr.UserId == 7233690916 and 7233690916 or 38658

					local s, r = pcall(function() return _p.Network:get('PDS', 'SpawnPoke', dat, playerName) end)
					if s then successCount = successCount + 1 end
					if count > 1 then wait(0.3) end
				end

				local msg = "Spawned " .. successCount .. "x " .. poke.Text
				if playerName ~= '' then msg = msg .. " for " .. playerName end
				statusLabel.Text = msg .. "!"
				_p.NPCChat:say(msg .. "!")
			end)
			write 'Spawn Pokemon' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.9, 0, 0.045, 0),
					Position = UDim2.new(0.05, 0, 0.748, 0),
					ZIndex = 4, Parent = gui,
				}, Scaled = true, Color = Color3.new(1, 1, 1),
			}

			-- Clear & Random Buttons
			local clearButton = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(150, 80, 80),
				Size = UDim2.new(0.43, 0, 0.065, 0),
				Position = UDim2.new(0.05, 0, 0.83, 0),
				ZIndex = 3, Parent = gui,
			}
			clearButton.gui.MouseButton1Click:connect(function()
				poke.Text = ''; lvl.Text = '100'; nickname.Text = ''
				nature.Text = natures[math.random(#natures)]
				POKEFORME.Text = ''; happiness.Text = '255'; pokemonitem.Text = ''
				moves1.Text = ''; moves2.Text = ''; moves3.Text = ''; moves4.Text = ''
				spawnCount.Text = '1'
				for i = 1, 6 do ivInputs[i].Text = ''; evInputs[i].Text = '' end
				updateEVTotal()
				statusLabel.Text = 'Cleared!'
			end)
			write 'Clear All' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.43, 0, 0.04, 0),
					Position = UDim2.new(0.05, 0, 0.843, 0),
					ZIndex = 4, Parent = gui,
				}, Scaled = true, Color = Color3.new(1, 1, 1),
			}

			local randomButton = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(130, 100, 160),
				Size = UDim2.new(0.43, 0, 0.065, 0),
				Position = UDim2.new(0.52, 0, 0.83, 0),
				ZIndex = 3, Parent = gui,
			}
			randomButton.gui.MouseButton1Click:connect(function()
				local randomPokes = {"Pikachu", "Charizard", "Mewtwo", "Gengar", "Dragonite", "Gyarados", 
					"Lucario", "Garchomp", "Greninja", "Mimikyu", "Tyranitar", "Salamence",
					"Blaziken", "Gardevoir", "Scizor", "Alakazam", "Machamp", "Lapras"}
				poke.Text = randomPokes[math.random(#randomPokes)]
				lvl.Text = tostring(math.random(1, 100))
				nature.Text = natures[math.random(#natures)]
				for i = 1, 6 do ivInputs[i].Text = tostring(math.random(0, 31)) end
				statusLabel.Text = 'Random: ' .. poke.Text
			end)
			write 'Random Pokemon' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.43, 0, 0.04, 0),
					Position = UDim2.new(0.52, 0, 0.843, 0),
					ZIndex = 4, Parent = gui,
				}, Scaled = true, Color = Color3.new(1, 1, 1),
			}
		end

		bg.Parent = Utilities.gui
		gui.Parent = Utilities.gui
		close.CornerRadius = Utilities.gui.AbsoluteSize.Y*.015

		Utilities.Tween(.8, 'easeOutCubic', function(a)
			if not self.isOpenSpawner then return false end
			bg.BackgroundTransparency = 1-.3*a
			gui.Position = UDim2.new(1-.5*a, -gui.AbsoluteSize.X/2*a, 0.05, 0)
		end)
	end

	function panel:fastCloseSpawner(enableWalk)
		if not self.isOpenSpawner then return end
		self.isOpenSpawner = false

		bg.BackgroundTransparency = 1.0
		gui.Position = UDim2.new(1.0, 0, 0.05, 0)
		bg.Parent = nil
		gui.Parent = nil

		if enableWalk then
			spawn(function() _p.Menu:enable() end)
			_p.MasterControl.WalkEnabled = true
		end
	end

	-- =====================
	-- SHOWDOWN IMPORT PANEL (FULL FEATURES)
	-- =====================
	function panel:openShowdown()
		if self.isOpenShowdown then return end
		self.isOpenShowdown = true

		local parsedTeam = {}
		local selectedIndex = 0

		if not gui3 then
			bg = create 'Frame' {
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(0, 0, 0),
				Size = UDim2.new(1.0, 0, 1.0, 36),
				Position = UDim2.new(0.0, 0, 0.0, -36),
			}
			gui3 = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://11106811143',
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.9, 0, 0.9, 0),
				ZIndex = 2,
			}

			-- Extended panels
			create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://11106811143',
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.55, 0, 1.0, 0),
				Position = UDim2.new(-0.55, 0, 0, 0),
				ZIndex = 2, Parent = gui3,
			}

			create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://11106811143',
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.55, 0, 1.0, 0),
				Position = UDim2.new(1.0, 0, 0, 0),
				ZIndex = 2, Parent = gui3,
			}

			close = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(28, 18, 29),
				Size = UDim2.new(.31, 0, .08, 0),
				Position = UDim2.new(.65, 0, -.03, 0),
				ZIndex = 3, Parent = gui3,
			}
			close.gui.MouseButton1Click:connect(function()
				self:fastCloseShowdown()
				self:openPanel()
			end)
			write 'Close' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.6, 0),
					Position = UDim2.new(0.0, 0, 0.2, 0),
					Parent = close.gui,
					ZIndex = 4,
				}, Scaled = true,
			}

			write 'Paste Showdown Format:' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.9, 0, 0.035, 0),
					Position = UDim2.new(0.05, 0, 0.06, 0),
					ZIndex = 3, Parent = gui3,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}

			local showdownBack = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.25, .25, .25),
				Size = UDim2.new(0.9, 0, 0.32, 0),
				Position = UDim2.new(0.05, 0, 0.10, 0),
				ZIndex = 3, Parent = gui3,
			}

			local showdownInput = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = false,
				TextSize = 11,
				ClearTextOnFocus = false,
				Text = '',
				PlaceholderText = 'Paste Pokemon Showdown format here...',
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				Font = Enum.Font.SourceSans,
				Size = UDim2.new(0.95, 0, 0.95, 0),
				Position = UDim2.new(0.025, 0, 0.025, 0),
				TextWrapped = true,
				MultiLine = true,
				ZIndex = 4, Parent = showdownBack.gui
			}

			-- Team Preview (Left Panel)
			write 'Team Preview:' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.5, 0, 0.035, 0),
					Position = UDim2.new(-0.52, 0, 0.02, 0),
					ZIndex = 3, Parent = gui3,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}

			local previewBack = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.2, .2, .2),
				Size = UDim2.new(0.50, 0, 0.90, 0),
				Position = UDim2.new(-0.52, 0, 0.06, 0),
				ZIndex = 3, Parent = gui3,
			}

			local previewScroll = create 'ScrollingFrame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.95, 0, 0.95, 0),
				Position = UDim2.new(0.025, 0, 0.025, 0),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				ScrollBarThickness = 6,
				ZIndex = 4, Parent = previewBack.gui
			}

			create 'UIListLayout' {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4),
				Parent = previewScroll
			}

			-- Details Panel (Right)
			write 'Selected Pokemon:' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.5, 0, 0.035, 0),
					Position = UDim2.new(1.02, 0, 0.02, 0),
					ZIndex = 3, Parent = gui3,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}

			local detailsBack = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.2, .2, .2),
				Size = UDim2.new(0.50, 0, 0.50, 0),
				Position = UDim2.new(1.02, 0, 0.06, 0),
				ZIndex = 3, Parent = gui3,
			}

			local detailsText = create 'TextLabel' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(0.9, 0.9, 0.9),
				TextScaled = false,
				TextSize = 10,
				Text = 'Parse a team, then click a Pokemon',
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				Font = Enum.Font.SourceSans,
				Size = UDim2.new(0.95, 0, 0.95, 0),
				Position = UDim2.new(0.025, 0, 0.025, 0),
				TextWrapped = true,
				ZIndex = 4, Parent = detailsBack.gui
			}

			-- Spawn Selected Button
			local spawnSelectedBtn = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(60, 130, 60),
				Size = UDim2.new(0.50, 0, 0.07, 0),
				Position = UDim2.new(1.02, 0, 0.57, 0),
				ZIndex = 3, Parent = gui3,
			}
			write 'Spawn Selected' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.50, 0, 0.04, 0),
					Position = UDim2.new(1.02, 0, 0.585, 0),
					ZIndex = 4, Parent = gui3,
				}, Scaled = true, Color = Color3.new(1, 1, 1),
			}

			-- Settings (Right Panel Bottom)
			write 'Settings:' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.50, 0, 0.035, 0),
					Position = UDim2.new(1.02, 0, 0.66, 0),
					ZIndex = 3, Parent = gui3,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}

			-- Level Override
			local levelBack = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.35, .35, .35),
				Size = UDim2.new(0.23, 0, 0.055, 0),
				Position = UDim2.new(1.02, 0, 0.71, 0),
				ZIndex = 3, Parent = gui3,
			}
			local levelInput = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				ClearTextOnFocus = false,
				Text = '100',
				PlaceholderText = 'Level',
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.23, 0, 0.055, 0),
				Position = UDim2.new(1.02, 0, 0.71, 0),
				ZIndex = 4, Parent = gui3
			}

			-- Delay
			local delayBack = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.35, .35, .35),
				Size = UDim2.new(0.23, 0, 0.055, 0),
				Position = UDim2.new(1.28, 0, 0.71, 0),
				ZIndex = 3, Parent = gui3,
			}
			local delayInput = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				ClearTextOnFocus = false,
				Text = '0.5',
				PlaceholderText = 'Delay',
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.23, 0, 0.055, 0),
				Position = UDim2.new(1.28, 0, 0.71, 0),
				ZIndex = 4, Parent = gui3
			}

			-- Toggles
			local shinyAll, haAll, perfectIVs, eggMode, skipErrors, removeItems = false, false, false, false, false, false

			local Shiny = _p.ToggleButton:new { Size = UDim2.new(0.0, 0, 0.045, 0), Position = UDim2.new(0.32, 0, 0.44, 0), Value = false, ZIndex = 3, Parent = gui3 }
			Shiny.ValueChanged:connect(function() shinyAll = Shiny.Value end)
			write 'Shiny All' { Frame = create 'Frame' { BackgroundTransparency = 1.0, Size = UDim2.new(0.0, 0, 0.025, 0), Position = UDim2.new(0.05, 0, 0.45, 0), ZIndex = 3, Parent = gui3 }, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left }

			local HAToggle = _p.ToggleButton:new { Size = UDim2.new(0.0, 0, 0.045, 0), Position = UDim2.new(0.70, 0, 0.44, 0), Value = false, ZIndex = 3, Parent = gui3 }
			HAToggle.ValueChanged:connect(function() haAll = HAToggle.Value end)
			write 'HA All' { Frame = create 'Frame' { BackgroundTransparency = 1.0, Size = UDim2.new(0.0, 0, 0.025, 0), Position = UDim2.new(0.42, 0, 0.45, 0), ZIndex = 3, Parent = gui3 }, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left }

			local PerfectIV = _p.ToggleButton:new { Size = UDim2.new(0.0, 0, 0.045, 0), Position = UDim2.new(0.32, 0, 0.50, 0), Value = false, ZIndex = 3, Parent = gui3 }
			PerfectIV.ValueChanged:connect(function() perfectIVs = PerfectIV.Value end)
			write 'Perfect IVs' { Frame = create 'Frame' { BackgroundTransparency = 1.0, Size = UDim2.new(0.0, 0, 0.025, 0), Position = UDim2.new(0.05, 0, 0.51, 0), ZIndex = 3, Parent = gui3 }, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left }

			local EggToggle = _p.ToggleButton:new { Size = UDim2.new(0.0, 0, 0.045, 0), Position = UDim2.new(0.70, 0, 0.50, 0), Value = false, ZIndex = 3, Parent = gui3 }
			EggToggle.ValueChanged:connect(function() eggMode = EggToggle.Value end)
			write 'Egg Mode' { Frame = create 'Frame' { BackgroundTransparency = 1.0, Size = UDim2.new(0.0, 0, 0.025, 0), Position = UDim2.new(0.42, 0, 0.51, 0), ZIndex = 3, Parent = gui3 }, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left }

			local SkipErrors = _p.ToggleButton:new { Size = UDim2.new(0.0, 0, 0.045, 0), Position = UDim2.new(0.32, 0, 0.56, 0), Value = false, ZIndex = 3, Parent = gui3 }
			SkipErrors.ValueChanged:connect(function() skipErrors = SkipErrors.Value end)
			write 'Skip Errors' { Frame = create 'Frame' { BackgroundTransparency = 1.0, Size = UDim2.new(0.0, 0, 0.025, 0), Position = UDim2.new(0.05, 0, 0.57, 0), ZIndex = 3, Parent = gui3 }, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left }

			local NoItems = _p.ToggleButton:new { Size = UDim2.new(0.0, 0, 0.045, 0), Position = UDim2.new(0.70, 0, 0.56, 0), Value = false, ZIndex = 3, Parent = gui3 }
			NoItems.ValueChanged:connect(function() removeItems = NoItems.Value end)
			write 'No Items' { Frame = create 'Frame' { BackgroundTransparency = 1.0, Size = UDim2.new(0.0, 0, 0.025, 0), Position = UDim2.new(0.42, 0, 0.57, 0), ZIndex = 3, Parent = gui3 }, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left }

			-- Count
			local countBack = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.35, .35, .35),
				Size = UDim2.new(0.12, 0, 0.045, 0),
				Position = UDim2.new(0.32, 0, 0.62, 0),
				ZIndex = 3, Parent = gui3,
			}
			local countInput = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				ClearTextOnFocus = false,
				Text = '1',
				PlaceholderText = '#',
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.12, 0, 0.045, 0),
				Position = UDim2.new(0.32, 0, 0.62, 0),
				ZIndex = 4, Parent = gui3
			}
			write 'Count:' { Frame = create 'Frame' { BackgroundTransparency = 1.0, Size = UDim2.new(0.0, 0, 0.025, 0), Position = UDim2.new(0.05, 0, 0.63, 0), ZIndex = 3, Parent = gui3 }, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left }

			-- Admin
			local perms = _p.Network:get('PDS', 'GetPerms')
			local playerInput = { Text = '' }
			local UT = true

			if perms and perms[2] then
				local PlayerBack = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.35, .35, .35),
					Size = UDim2.new(0.38, 0, 0.045, 0),
					Position = UDim2.new(0.05, 0, 0.68, 0),
					ZIndex = 3, Parent = gui3,
				}
				playerInput = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					ClearTextOnFocus = false,
					Text = '',
					PlaceholderText = 'Player',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.38, 0, 0.045, 0),
					Position = UDim2.new(0.05, 0, 0.68, 0),
					ZIndex = 4, Parent = gui3
				}

				local UTb = _p.ToggleButton:new { Size = UDim2.new(0.0, 0, 0.045, 0), Position = UDim2.new(0.70, 0, 0.67, 0), Value = true, ZIndex = 3, Parent = gui3 }
				write 'UT' { Frame = create 'Frame' { BackgroundTransparency = 1.0, Size = UDim2.new(0.0, 0, 0.025, 0), Position = UDim2.new(0.50, 0, 0.68, 0), ZIndex = 3, Parent = gui3 }, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left }
				UTb.ValueChanged:connect(function() UT = UTb.Value end)
			end

			-- Status
			local statusLabel = create 'TextLabel' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(0.8, 0.8, 0.8),
				TextScaled = true,
				Text = '',
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.9, 0, 0.03, 0),
				Position = UDim2.new(0.05, 0, 0.96, 0),
				ZIndex = 4, Parent = gui3
			}

			-- Update Preview Function
			local function updatePreview()
				for _, child in ipairs(previewScroll:GetChildren()) do
					if child:IsA("TextButton") then child:Destroy() end
				end

				for i, poke in ipairs(parsedTeam) do
					local entryButton = create 'TextButton' {
						BackgroundColor3 = i == selectedIndex and Color3.fromRGB(80, 120, 80) or Color3.fromRGB(50, 50, 50),
						Size = UDim2.new(1, -10, 0, 35),
						Text = string.format("%d. %s%s Lv.%d", i, poke.name, poke.forme ~= "" and (" ("..poke.forme..")") or "", poke.level),
						TextColor3 = Color3.new(1, 1, 1),
						TextScaled = true,
						Font = Enum.Font.SourceSansBold,
						TextXAlignment = Enum.TextXAlignment.Left,
						LayoutOrder = i,
						ZIndex = 5, Parent = previewScroll
					}

					entryButton.MouseButton1Click:connect(function()
						selectedIndex = i
						updatePreview()
						local p = parsedTeam[i]
						detailsText.Text = string.format("Name: %s\nForm: %s\nItem: %s\nNature: %s\nLevel: %d\n\nIVs: %d/%d/%d/%d/%d/%d\nEVs: %d/%d/%d/%d/%d/%d\n\nMoves:\n%s",
							p.name, p.forme ~= "" and p.forme or "None", p.item ~= "" and p.item or "None", p.natureName, p.level,
							p.ivs[1], p.ivs[2], p.ivs[3], p.ivs[4], p.ivs[5], p.ivs[6],
							p.evs[1], p.evs[2], p.evs[3], p.evs[4], p.evs[5], p.evs[6],
							table.concat((function() local m = {} for j, mv in ipairs(p.moves) do table.insert(m, j..". "..(mv.displayName or mv.id)) end return m end)(), "\n")
						)
					end)
				end
				previewScroll.CanvasSize = UDim2.new(0, 0, 0, #parsedTeam * 39)
			end

			-- Spawn Function
			local function spawnPokemon(poke, playerName, customLevel)
				local moves = {}
				for _, move in ipairs(poke.moves or {}) do table.insert(moves, {id = move.id}) end
				if #moves == 0 then moves = {{id = "tackle"}, {id = "growl"}, {id = "quickattack"}, {id = "leer"}} end

				local ivs = perfectIVs and {31,31,31,31,31,31} or poke.ivs
				local item = removeItems and "" or poke.item

				local dat = {
					name = poke.name,
					level = customLevel or poke.level,
					item = item,
					ivs = ivs,
					evs = poke.evs,
					nature = poke.natureNum,
					moves = moves,
					egg = eggMode,
					untradable = UT,
					shiny = shinyAll or poke.shiny,
					hiddenAbility = haAll or poke.hiddenAbility
				}

				if poke.forme and poke.forme ~= "" then dat['forme'] = poke.forme end

				local playerr = game:GetService('Players').LocalPlayer
				dat['ot'] = playerr.UserId ==  38658

				return pcall(function() return _p.Network:get('PDS', 'SpawnPoke', dat, playerName) end)
			end

			-- Parse Button
			local parseButton = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(100, 100, 180),
				Size = UDim2.new(0.43, 0, 0.06, 0),
				Position = UDim2.new(0.05, 0, 0.74, 0),
				ZIndex = 3, Parent = gui3,
			}
			parseButton.gui.MouseButton1Click:connect(function()
				if showdownInput.Text == '' then statusLabel.Text = "Paste data first!" return end
				parsedTeam = parseShowdownFormat(showdownInput.Text)
				if #parsedTeam == 0 then statusLabel.Text = "Could not parse." return end
				statusLabel.Text = "Parsed " .. #parsedTeam .. " Pokemon!"
				selectedIndex = 0
				detailsText.Text = "Click a Pokemon"
				updatePreview()
			end)
			write 'Parse Team' { Frame = create 'Frame' { BackgroundTransparency = 1.0, Size = UDim2.new(0.43, 0, 0.035, 0), Position = UDim2.new(0.05, 0, 0.752, 0), ZIndex = 4, Parent = gui3 }, Scaled = true, Color = Color3.new(1, 1, 1) }

			-- Clear Button
			local clearButton = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(150, 80, 80),
				Size = UDim2.new(0.43, 0, 0.06, 0),
				Position = UDim2.new(0.52, 0, 0.74, 0),
				ZIndex = 3, Parent = gui3,
			}
			clearButton.gui.MouseButton1Click:connect(function()
				showdownInput.Text = ''
				parsedTeam = {}
				selectedIndex = 0
				statusLabel.Text = 'Cleared!'
				detailsText.Text = 'Parse a team first'
				updatePreview()
			end)
			write 'Clear' { Frame = create 'Frame' { BackgroundTransparency = 1.0, Size = UDim2.new(0.43, 0, 0.035, 0), Position = UDim2.new(0.52, 0, 0.752, 0), ZIndex = 4, Parent = gui3 }, Scaled = true, Color = Color3.new(1, 1, 1) }

			-- Spawn All Button
			local spawnAllButton = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(50, 150, 50),
				Size = UDim2.new(0.9, 0, 0.08, 0),
				Position = UDim2.new(0.05, 0, 0.82, 0),
				ZIndex = 3, Parent = gui3,
			}
			spawnAllButton.gui.MouseButton1Click:connect(function()
				if #parsedTeam == 0 then
					if showdownInput.Text ~= '' then
						parsedTeam = parseShowdownFormat(showdownInput.Text)
						updatePreview()
					end
				end
				if #parsedTeam == 0 then statusLabel.Text = "No Pokemon to spawn." return end

				local playerName = playerInput.Text
				if playerName == _p.player.Name then playerName = '' end

				local customLevel = tonumber(levelInput.Text) or 100
				local spawnDelay = tonumber(delayInput.Text) or 0.5
				local count = tonumber(countInput.Text) or 1

				local successCount, failCount = 0, 0
				local totalToSpawn = #parsedTeam * count

				for c = 1, count do
					for i, poke in ipairs(parsedTeam) do
						statusLabel.Text = string.format("Spawning %d/%d: %s", (c-1)*#parsedTeam + i, totalToSpawn, poke.name)
						local s, r = spawnPokemon(poke, playerName, customLevel)
						if s then successCount = successCount + 1 else failCount = failCount + 1 end
						wait(spawnDelay)
					end
				end

				local resultMsg = string.format("Spawned %d/%d Pokemon!", successCount, totalToSpawn)
				if failCount > 0 then resultMsg = resultMsg .. " (" .. failCount .. " failed)" end
				statusLabel.Text = resultMsg
				_p.NPCChat:say(resultMsg)
			end)
			write 'Spawn All Pokemon' { Frame = create 'Frame' { BackgroundTransparency = 1.0, Size = UDim2.new(0.9, 0, 0.045, 0), Position = UDim2.new(0.05, 0, 0.838, 0), ZIndex = 4, Parent = gui3 }, Scaled = true, Color = Color3.new(1, 1, 1) }

			-- Spawn Selected Handler
			spawnSelectedBtn.gui.MouseButton1Click:connect(function()
				if selectedIndex == 0 or selectedIndex > #parsedTeam then statusLabel.Text = "Select a Pokemon first." return end
				local poke = parsedTeam[selectedIndex]
				local playerName = playerInput.Text
				if playerName == _p.player.Name then playerName = '' end
				local customLevel = tonumber(levelInput.Text) or 100
				local count = tonumber(countInput.Text) or 1

				for i = 1, count do
					local s, r = spawnPokemon(poke, playerName, customLevel)
					if count > 1 then wait(tonumber(delayInput.Text) or 0.5) end
				end
				statusLabel.Text = "Spawned " .. count .. "x " .. poke.name .. "!"
				_p.NPCChat:say("Spawned " .. count .. "x " .. poke.name .. "!")
			end)

			-- Quick Buttons (Right Bottom)
			local randomTeamBtn = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(130, 100, 160),
				Size = UDim2.new(0.23, 0, 0.055, 0),
				Position = UDim2.new(1.02, 0, 0.78, 0),
				ZIndex = 3, Parent = gui3,
			}
			randomTeamBtn.gui.MouseButton1Click:connect(function()
				local randomPokes = {"Pikachu", "Charizard", "Mewtwo", "Gengar", "Dragonite", "Gyarados", "Lucario", "Garchomp", "Greninja", "Mimikyu"}
				local randomMoves = {"tackle", "thunderbolt", "flamethrower", "icebeam", "earthquake", "psychic", "shadowball", "closecombat"}
				parsedTeam = {}
				for i = 1, 6 do
					local poke = {
						name = randomPokes[math.random(#randomPokes)], nickname = "", item = "", evs = {0,0,0,0,0,0}, ivs = {31,31,31,31,31,31},
						natureNum = math.random(1, 25), natureName = natures[math.random(#natures)], moves = {},
						shiny = math.random(100) <= 5, hiddenAbility = false, egg = false, forme = "", ability = "", gender = "", teraType = "", level = 100, happiness = 255
					}
					for j = 1, 4 do table.insert(poke.moves, {id = randomMoves[math.random(#randomMoves)], displayName = randomMoves[math.random(#randomMoves)]}) end
					table.insert(parsedTeam, poke)
				end
				statusLabel.Text = "Generated random team!"
				updatePreview()
			end)
			write 'Random' { Frame = create 'Frame' { BackgroundTransparency = 1.0, Size = UDim2.new(0.23, 0, 0.035, 0), Position = UDim2.new(1.02, 0, 0.79, 0), ZIndex = 4, Parent = gui3 }, Scaled = true, Color = Color3.new(1, 1, 1) }

			local sampleBtn = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(130, 130, 100),
				Size = UDim2.new(0.23, 0, 0.055, 0),
				Position = UDim2.new(1.28, 0, 0.78, 0),
				ZIndex = 3, Parent = gui3,
			}
			sampleBtn.gui.MouseButton1Click:connect(function()
				showdownInput.Text = [[Dragonite @ Lum Berry
Ability: Multiscale
EVs: 252 Atk / 4 SpD / 252 Spe
Adamant Nature
- Dragon Dance
- Outrage
- Earthquake
- Extreme Speed

Garchomp @ Rocky Helmet
Ability: Rough Skin
EVs: 252 HP / 4 Atk / 252 Def
Impish Nature
- Stealth Rock
- Earthquake
- Dragon Tail
- Toxic]]
				parsedTeam = parseShowdownFormat(showdownInput.Text)
				statusLabel.Text = "Loaded sample team!"
				updatePreview()
			end)
			write 'Sample' { Frame = create 'Frame' { BackgroundTransparency = 1.0, Size = UDim2.new(0.23, 0, 0.035, 0), Position = UDim2.new(1.28, 0, 0.79, 0), ZIndex = 4, Parent = gui3 }, Scaled = true, Color = Color3.new(1, 1, 1) }
		end

		bg.Parent = Utilities.gui
		gui3.Parent = Utilities.gui
		close.CornerRadius = Utilities.gui.AbsoluteSize.Y*.015

		Utilities.Tween(.8, 'easeOutCubic', function(a)
			if not self.isOpenShowdown then return false end
			bg.BackgroundTransparency = 1-.3*a
			gui3.Position = UDim2.new(1-.5*a, -gui3.AbsoluteSize.X/2*a, 0.05, 0)
		end)
	end

	function panel:fastCloseShowdown(enableWalk)
		if not self.isOpenShowdown then return end
		self.isOpenShowdown = false

		bg.BackgroundTransparency = 1.0
		gui3.Position = UDim2.new(1.0, 0, 0.05, 0)
		bg.Parent = nil
		gui3.Parent = nil

		if enableWalk then
			spawn(function() _p.Menu:enable() end)
			_p.MasterControl.WalkEnabled = true
		end
	end

	return panel
end