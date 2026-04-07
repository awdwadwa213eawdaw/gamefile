return function(_p)--local _p = require(script.Parent.Parent)--game:GetService('ReplicatedStorage').Plugins)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local write = Utilities.Write
	local MasterControl = _p.MasterControl

	local pokedex = {}
	local N_MAX_DEX = 1032--721 --738

	local function color(r, g, b)
		return Color3.new(r/255, g/255, b/255)
	end

	local BACKGROUND_COLOR = color(90, 170, 221)
	local GRID_COLOR = color(72, 94, 150)
	local ENTRY_THEME_COLOR = Color3.new(.7, .8, .9)
	local ENTRY_TEXT_COLOR = GRID_COLOR

	local background, gui, iconContainer, entryContainer, rightTray, leftTray, topTray, backButton
	local routesContainerFrame, tabRoutesFrame, routesTitleFrame, routesScrollFrame, routesGridContainer, routesSidebar, routesListContainer, searchBox
	local squares = Vector2.new(6, 4)
	local currentPage
	local zoom = 2
	local busy = false
	local entryThread	
	local allRouteEncounters = {}
	local selectedRouteName = "Route 1"

	local regionNames = _p.Network:get("PDS", "getAllRegionNames")

	function pokedex:showPokemonEntry(num, limited)
		if busy then return end
		busy = true
		local thisThread = {}
		entryThread = thisThread
		local f = create 'Frame' {
			BorderSizePixel = 0,
			BackgroundColor3 = BACKGROUND_COLOR,
			Size = iconContainer.Size,
			Position = iconContainer.Position,
			ZIndex = 5, Parent = entryContainer,
		}
		local content = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			Parent = entryContainer,
		}
		local idContainer = _p.RoundedFrame:new {
			CornerRadius = gui.CornerRadius,
			BackgroundColor3 = ENTRY_THEME_COLOR,
			Size = UDim2.new(0.5, 0, 0.2, 0),
			Position = UDim2.new(0.475, 0, 0.05, 0),
			ZIndex = 6, Parent = content,
		}
		if not limited then
			create 'ImageLabel' {
				Name = 'OwnedIcon',
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://6142797841',
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.4, 0, 0.4, 0),
				Position = UDim2.new(0.025, 0, 0.05, 0),
				ZIndex = 7, Parent = idContainer.gui,
			}
		end
		local dimContainer = _p.RoundedFrame:new {
			CornerRadius = gui.CornerRadius,
			BackgroundColor3 = ENTRY_THEME_COLOR,
			Size = UDim2.new(0.3, 0, 0.2, 0),
			Position = UDim2.new(0.65, 0, 0.3, 0),
			ZIndex = 6, Parent = content,
		}
		write 'Height:' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.22, 0),
				Position = UDim2.new(0.05, 0, 0.125, 0),
				ZIndex = 7, Parent = dimContainer.gui,
			},
			Scaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			Color = ENTRY_TEXT_COLOR,
		}
		write 'Weight:' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.22, 0),
				Position = UDim2.new(0.05, 0, 0.625, 0),
				ZIndex = 7, Parent = dimContainer.gui,
			},
			Scaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			Color = ENTRY_TEXT_COLOR,
		}
		if limited then
			write '??? pokemon' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.25, 0),
					Position = UDim2.new(0.025, 0, 0.66, 0),
					ZIndex = 7, Parent = idContainer.gui,
				},
				Scaled = true,
				Color = ENTRY_TEXT_COLOR,
				TextXAlignment = Enum.TextXAlignment.Left,
			}
			write '???' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.22, 0),
					Position = UDim2.new(0.6, 0, 0.125, 0),
					ZIndex = 7, Parent = dimContainer.gui,
				},
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				Color = ENTRY_TEXT_COLOR,
			}
			write '???' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.22, 0),
					Position = UDim2.new(0.6, 0, 0.625, 0),
					ZIndex = 7, Parent = dimContainer.gui,
				},
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				Color = ENTRY_TEXT_COLOR,
			}
		end
		local descContainer = _p.RoundedFrame:new {
			CornerRadius = gui.CornerRadius,
			BackgroundColor3 = ENTRY_THEME_COLOR,
			Size = UDim2.new(0.975, 0, 0.325, 0),
			Position = UDim2.new(0.0125, 0, 0.65, 0),
			ZIndex = 6, Parent = content,
		}
		local rframes = {idContainer, dimContainer, descContainer}
		local animation
		Utilities.fastSpawn(function()
			local pdata = _p.DataManager:getData('Pokedex', num)
			if entryThread ~= thisThread then return end
			local ns = tostring(num)
			ns = string.rep('0', 3-ns:len())..ns
			write(ns..' '..pdata.species) {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.25, 0),
					Position = UDim2.new(0.15, 0, 0.16, 0),
					ZIndex = 7, Parent = idContainer.gui,
				},
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				Color = ENTRY_TEXT_COLOR,
			}
			Utilities.fastSpawn(function()
				local sd = _p.DataManager:getSprite('_FRONT', pdata.species)
				if entryThread ~= thisThread then return end
				animation = _p.AnimatedSprite:new(sd)
				local container = create 'Frame' {
					BackgroundTransparency = 1.0,
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.new(0.65, 0, 0.6, 0),
					Position = UDim2.new(.05, 0, .025, 0),
					Parent = content,
				}
				local sprite = animation.spriteLabel
				sprite.Parent = container
				sprite.ZIndex = 6
				local x = sd.fWidth/110
				local y = sd.fHeight/110
				sprite.Size = UDim2.new(x, 0, y, 0)
				sprite.Position = UDim2.new(0.5-x/2, 0, 1-y, 0)
				animation:Play()
			end)
			if not limited then
				Utilities.fastSpawn(function()
					local xd = _p.DataManager:getData('PokedexExtended', Utilities.rc4(pdata.id))
					if entryThread ~= thisThread then return end
					write(xd.class .. ' pokemon') {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.25, 0),
							Position = UDim2.new(0.025, 0, 0.66, 0),
							ZIndex = 7, Parent = idContainer.gui,
						},
						Scaled = true,
						Color = ENTRY_TEXT_COLOR,
						TextXAlignment = Enum.TextXAlignment.Left,
					}
					local df = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.975, 0, 0.13, 0),
						Position = UDim2.new(0.0125, 0, 0.05, 0),
						ZIndex = 7, Parent = descContainer.gui,
					}
					local dt = write(xd.desc) {
						Frame = df,
						Wraps = true,
						Color = ENTRY_TEXT_COLOR,
					}
					if dt.MaxBounds.Y > descContainer.gui.AbsoluteSize.Y then
						df:ClearAllChildren()
						df.Size = UDim2.new(0.975, 0, 0.12, 0)
						write(xd.desc) {
							Frame = df,
							Wraps = true,
							Color = ENTRY_TEXT_COLOR,
						}
					end
				end)
				write(string.format('%.1fm', pdata.heightm)) {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.22, 0),
						Position = UDim2.new(0.6, 0, 0.125, 0),
						ZIndex = 7, Parent = dimContainer.gui,
					},
					Scaled = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					Color = ENTRY_TEXT_COLOR,
				}
				write(string.format('%.1fkg', pdata.weightkg)) {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.22, 0),
						Position = UDim2.new(0.6, 0, 0.625, 0),
						ZIndex = 7, Parent = dimContainer.gui,
					},
					Scaled = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					Color = ENTRY_TEXT_COLOR,
				}
				for i, t in pairs(_p.Pokemon:getTypes(pdata.types)) do
					local rf = _p.RoundedFrame:new {
						BackgroundColor3 = _p.BattleGui.typeColors[t],
						Size = UDim2.new(0.2, 0, 0.075, 0),
						Position = UDim2.new(0.525+0.225*(i-1), 0, 0.55, 0),
						ZIndex = 6, Style = 'HorizontalBar', Parent = content,
					}
					write (t) {
						Frame = create 'Frame' {
							Parent = rf.gui, ZIndex = 4, BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.6, 0),
							Position = UDim2.new(0.5, 0, 0.2, 0), 
							ZIndex = 7, Parent = rf.gui,
						}, Scaled = true,
					}
					table.insert(rframes, rf)
				end
			end
		end)
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			f.BackgroundTransparency = 1-a
			content.Position = UDim2.new(0.0, 0, a-1, 0)
			leftTray.Position = UDim2.new(0.05-.2*a, 0, 0.1, 0)
			rightTray.Position = UDim2.new(.85-.2*a, 0, 0.1, 0)
		end)
		backButton.MouseButton1Click:wait()
		entryThread = nil
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			f.BackgroundTransparency = a
			content.Position = UDim2.new(0.0, 0, -a, 0)
			leftTray.Position = UDim2.new(-.15+.2*a, 0, 0.1, 0)
			rightTray.Position = UDim2.new(.65+.2*a, 0, 0.1, 0)
		end)
		for _, rf in pairs(rframes) do
			rf:Destroy()
		end
		content:Destroy()
		f:Destroy()
		busy = false
		if self.currentView then
			self.currentView.Visible = true
		end
	end

	local getIcon; do
		local skip = { 4,   8,   9,  13,  70, 100, 122, 135, 139, 152, 161, 162, 194,
			215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228,
			229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241,
			253, 256, 272, 292, 302, 328, 350, 354, 357, 360, 402, 403, 404,
			408, 414, 436, 438, 444, 445, 446, 473, 474, 476, 477, 486, 488, 490,
			513, 517, 530, 550, 551, 552, 553, 554, 563, 569, 599, 629, 635,
			666, 667, 668, 670, 671, 672, 679, 681, 730, 732, 736, 738, 739, 741, 743,
			762, 763, 764, 765, 766, 767, 768, 769, 770, 771,
			772, 773, 774, 775, 776, 777, 778, 779, 780,
			783, 785, 786, 787, 788, 790, 791, 792, 793, 794, 796, 797, 798, 799,
			805, 806, 807, 808, 809, 810, 811, 812, 813,
			816, 820, 856,
			862, 863, 864, 865, 866, 867, 868, 869, 870, 871, 872, 873, 874, 875, 876, 877,
			878, 879, 880, 881, 882, 883, 884, 885, 886, 887, 888, 889, 890, 891, 892, 893, 894,915,916,917,922,924,953,954,955,956,957,958,959,987, 989,990, 991,992,
			993, 994,995,996,997,998,999,1000,1001,1002,1003,1004,1012,1019,1020,1021,1022,
			1023,1024,1025,1104,1105,1106,1107,1108,1109,1110,1111,1112,1113,1114,1115,1116,1117,1118,1119,1120,1121,1122,1123,1124,1125,1126,1127,1128,1129,1130,1131,1132,1135,1136,1137,
			1138,1139,1140,1141,1142,1143,1144,1145,1146,1147,1151, 1152, 1153, 1154, 1155, 1156, 1157, 1158, 1159, 1160, 1161, 1162,
			1163, 1164, 1165, 1166, 1167, 1168, 1169, 1170, 1171, 1172, 1173, 1174, 1175, 1176,
			1177, 1178, 1179, 1180, 1181, 1182, 1183, 1184, 1185, 1186, 1187, 1188, 1189, 1190,
			1191, 1192, 1193, 1194, 1195, 1196, 1197, 1198, 1199, 1200, 1201, 1202, 1203,
			1204, 1205, 1206, 1207, 1208, 1209, 1210, 1211, 1212, 1213, 1214, 1215, 1216, 1217,
			1218, 1223, 1227, 1228, 1229, 1230, 1231, 1232, 1233, 1234, 1235, 1236, 1237, 1238, 1239,
			1240, 1241, 1242, 1243, 1244, 1245, 1246, 1247, 1250, 1260, 1270, 1271, 1277, 1278, 1279,
			1292, 1313, 1316, 1331, 1332, 1334, 1338, 1355, 1356, 1367, 1368, 1369, 1370, 1373,
			1374, 1375, 1376, 1377, 1378, 1379, 1380, 1381, 1382, 1390, 1391, 1392, 1393, 1394,
			1395, 1396, 1397, 1398, 1399, 1400, 1401, 1402, 1403, 1404, 1413, 1414
		}
		getIconNumbers = function(lowerBound, upperBound)
			local iconNumbers = {}
			local n, i, s = 1, 1, 1
			for goal = lowerBound, upperBound do
				while skip[s] and skip[s] <= goal+i-n do
					local d = (skip[s] - (skip[s-1] or 0) - 1)
					n = n + d
					i = i + d + 1
					s = s + 1
				end
				i = i + (goal-n)
				n = goal
				table.insert(iconNumbers, i)
			end
			return iconNumbers
		end
	end

	function pokedex:viewPage(p)
		local dex = self.dexData
		if not dex then return end

		currentPage = p
		iconContainer:ClearAllChildren()
		local x, y = squares.X, squares.Y
		local a = x*y

		local iconNumbers = getIconNumbers((p-1)*a+1, p*a)
		for i = 0, a-1 do
			local n = (p-1)*a+i+1
			if n > N_MAX_DEX then break end
			local f = create 'ImageButton' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1/x, 0, 1/y, 0),
				Position = UDim2.new((i%x)/x, 0, math.floor(i/x)/y, 0),
				Parent = iconContainer,
			}
			if zoom <= 5 then
				local ns = tostring(n)
				ns = string.rep('0', 3-ns:len())..ns
				write(ns) {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.19, 0),
						Position = UDim2.new(0.95, 0, 0.05, 0),
						ZIndex = 4, Parent = f,
					},
					Scaled = true,
					Color = GRID_COLOR,
					TextXAlignment = Enum.TextXAlignment.Right,
				}
			end
			if dex[n*2-1] == 1 then
				local icon = _p.Pokemon:getIcon(iconNumbers[i+1]-1)
				icon.SizeConstraint = Enum.SizeConstraint.RelativeXX
				icon.Size = UDim2.new(1.0, 0, -3/4, 0)
				icon.Position = UDim2.new(0.0, 0, 1.0, 0)
				icon.ZIndex = 4
				icon.Parent = f
				if dex[n*2] == 1 then
					create 'ImageLabel' {
						Name = 'OwnedIcon',
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://7824188301',
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Size = UDim2.new(0.2, 0, 0.2, 0),
						Position = UDim2.new(0.1, 0, 0.05, 0),
						ZIndex = 4, Parent = f,
					}
					f.MouseButton1Click:connect(function()
						self:showPokemonEntry(n)
					end)
				else
					icon.ImageTransparency = .5
					f.MouseButton1Click:connect(function()
						self:showPokemonEntry(n, true)
					end)
				end
			end
		end
	end

	local function zoomIn()
		if zoom <= 1 then return end
		zoom = zoom - 1
		squares = Vector2.new(zoom*3, zoom*2)
		pokedex:redrawGrid()
		pokedex:viewPage(currentPage)
	end

	local function zoomOut()
		if zoom >= 11 then return end
		zoom = zoom + 1
		squares = Vector2.new(zoom*3, zoom*2)
		pokedex:redrawGrid()
		pokedex:viewPage(math.min(currentPage, math.floor(N_MAX_DEX/(squares.X*squares.Y))+1))
	end

	function pokedex:read(data)
		local buffer = _p.BitBuffer.Create()
		buffer:FromBase64(data)
		self.dexData = buffer:GetData()
	end

	function pokedex:open()
		spawn(function() _p.Menu:disable() end)
		MasterControl.WalkEnabled = false
		MasterControl:Stop()

		local dex
		Utilities.fastSpawn(function() dex = _p.Network:get('PDS', 'getDex') end)

		if not gui then
			background = create 'ImageButton' {
				AutoButtonColor = false,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(0, 0, 0),
				Size = UDim2.new(1.0, 0, 1.0, 36),
				Position = UDim2.new(0.0, 0, 0.0, -36),
				Parent = Utilities.gui,
			}
			local aspectRatio = 1.5
			gui = _p.RoundedFrame:new {
				BackgroundColor3 = BACKGROUND_COLOR,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.7*aspectRatio, 0, 0.7, 0),
				Position = UDim2.new(0.0, 0, 0.15, 0),
				ZIndex = 3, Parent = Utilities.gui,
			}
			local outerSize = .05
			local outerBorder = _p.RoundedFrame:new {
				BackgroundColor3 = color(237, 52, 57),
				Size = UDim2.new(1+outerSize/aspectRatio*2, 0, 1+outerSize*2, 0),
				Position = UDim2.new(-outerSize/aspectRatio, 0, -outerSize, 0),
				Parent = gui.gui,
			}
			local innerSize = .025
			local innerBorder = _p.RoundedFrame:new {
				BackgroundColor3 = color(147, 20, 37),
				Size = UDim2.new(1+innerSize/aspectRatio*2, 0, 1+innerSize*2, 0),
				Position = UDim2.new(-innerSize/aspectRatio, 0, -innerSize, 0),
				ZIndex = 2, Parent = gui.gui,
			}
			local grid = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, 1.0, 0),
				Parent = gui.gui,
			}
			iconContainer = create 'Frame' {
				BackgroundTransparency = 1.0,
				Parent = gui.gui,
			}
			entryContainer = create 'Frame' {
				ClipsDescendants = true,
				BackgroundTransparency = 1.0,
				Parent = gui.gui,
			}
			routesContainerFrame = create("Frame")({
				["Visible"] = false,
				["BackgroundTransparency"] = 1,
				["Parent"] = gui.gui
			})
			leftTray = _p.RoundedFrame:new {
				BackgroundColor3 = outerBorder.BackgroundColor3,
				Size = UDim2.new(0.3, 0, 0.8/5, 0),
				Position = UDim2.new(0.15, 0, 0.1, 0),
				Parent = gui.gui,
			}
			do
				backButton = create 'ImageButton' {
					BackgroundTransparency = 1.0,
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.new(.75, 0, .75, 0),
					Position = UDim2.new(0.05, 0, 0.125, 0),
					Rotation = 90,
					Parent = leftTray.gui,
				}
				write 'v' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(1.0, 0, 1.0, 0),
						Position = UDim2.new(0.135, 0, 0.0, 0),
						Parent = backButton,
					}, Scale = true,
				}
			end
			rightTray = _p.RoundedFrame:new {
				BackgroundColor3 = outerBorder.BackgroundColor3,
				Size = UDim2.new(0.3, 0, 0.8, 0),
				Parent = gui.gui,
			}
			write 'X' {
				Frame = create 'ImageButton' {
					BackgroundTransparency = 1.0,
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.new(-.15, 0, .15, 0),
					Position = UDim2.new(0.95, 0, 0.025, 0),
					Parent = rightTray.gui,
					MouseButton1Click = function()
						if busy then return end
						self:close()
					end,
				}, Scale = true, Color = innerBorder.BackgroundColor3,
			}
			write '+' {
				Frame = create 'ImageButton' {
					BackgroundTransparency = 1.0,
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.new(-.15, 0, .15, 0),
					Position = UDim2.new(0.95, 0, 0.425, 0),
					Parent = rightTray.gui,
					MouseButton1Click = function()
						if busy then return end
						zoomIn()
					end,
				}, Scale = true, Color = color(61, 149, 77),
			}
			do
				local b = create 'ImageButton' {
					BackgroundTransparency = 1.0,
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.new(-.15, 0, .15, 0),
					Position = UDim2.new(0.95, 0, 0.625, 0),
					Parent = rightTray.gui,
					MouseButton1Click = function()
						if busy then return end
						zoomOut()
					end,
				}
				write '-' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(1.0, 0, 1.0, 0),
						Position = UDim2.new(0.2, 0, 0.0, 0),
						Parent = b,
					}, Scale = true, Color = color(61, 149, 77),
				}
			end
			do
				local b = create 'ImageButton' {
					BackgroundTransparency = 1.0,
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.new(-.15, 0, .15, 0),
					Position = UDim2.new(0.95, 0, 0.225, 0),
					Rotation = 180,
					Parent = rightTray.gui,
					MouseButton1Click = function()
						if busy then return end
						local p = math.max(currentPage - 1, 1)
						if p ~= currentPage then
							self:viewPage(p)
						end
					end,
				}
				write 'v' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(1.0, 0, 1.0, 0),
						Position = UDim2.new(0.225, 0, 0.0, 0),
						Parent = b,
					}, Scale = true, Color = GRID_COLOR,
				}
			end
			write 'v' {
				Frame = create 'ImageButton' {
					BackgroundTransparency = 1.0,
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.new(-.15, 0, .15, 0),
					Position = UDim2.new(0.95, 0, 0.825, 0),
					Parent = rightTray.gui,
					MouseButton1Click = function()
						if busy then return end
						local p = math.min(currentPage + 1, math.floor(N_MAX_DEX/(squares.X*squares.Y))+1)
						if p ~= currentPage then
							self:viewPage(p)
						end
					end,
				}, Scale = true, Color = GRID_COLOR,
			}
			topTray = _p.RoundedFrame:new {
				BackgroundColor3 = outerBorder.BackgroundColor3,
				Size = UDim2.new(0.3, 0, 0.3, 0),
				Button = true,
				MouseButton1Click = function()
					self:switchTabs(topTray)
				end,
				Parent = gui.gui,
			}
			write 'Pok[e\']dex' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.22, 0),
					Position = UDim2.new(0.5, 0, 0.17, 0),
					Parent = topTray.gui,
				}, Scaled = true, Color = innerBorder.BackgroundColor3,
			}

			tabRoutesFrame = _p.RoundedFrame:new({
				["BackgroundColor3"] = Color3.new(0.8156862745098039, 0.17647058823529413, 0.20784313725490197),
				["Size"] = UDim2.new(0.3, 0, 0.3, 0),
				["Button"] = true,
				["MouseButton1Click"] = function()
					self:switchTabs(tabRoutesFrame)
				end,
				["Parent"] = gui.gui
			})
			write "Routes" {
				["Frame"] = create "Frame" {
					["BackgroundTransparency"] = 1,
					["Size"] = UDim2.new(0, 0, 0.22, 0),
					["Position"] = UDim2.new(0.5, 0, 0.17, 0),
					["Parent"] = tabRoutesFrame.gui
				},
				["Scaled"] = true,
				["Color"] = innerBorder.BackgroundColor3
			}

			routesTitleFrame = _p.RoundedFrame:new({
				["BackgroundColor3"] = Color3.new(0.9333333333333333, 0.20392156862745098, 0.22745098039215686),
				["Size"] = UDim2.new(0.45, 0, 0.15, 0),
				["ZIndex"] = 7,
				["Parent"] = routesContainerFrame
			})
			local defaultRouteText = write("Route 1")
			defaultRouteText({
				["Frame"] = create("Frame")({
					["Name"] = "TextContainer",
					["AnchorPoint"] = Vector2.new(0.5, 0.5),
					["BackgroundTransparency"] = 1,
					["Size"] = UDim2.new(0, 0, 0.5, 0),
					["Position"] = UDim2.new(0.5, 0, 0.5, 0),
					["ZIndex"] = 7,
					["Parent"] = routesTitleFrame.gui
				}),
				["Scaled"] = true,
				["Color"] = innerBorder.BackgroundColor3
			})

			routesSidebar = _p.RoundedFrame:new({
				["BackgroundColor3"] = Color3.new(0.8156862745098039, 0.17647058823529413, 0.20784313725490197),
				["Position"] = UDim2.fromScale(0.5, 0),
				["Size"] = UDim2.fromScale(0.5, 1),
				["ZIndex"] = 7,
				["Parent"] = routesContainerFrame
			})

			routesScrollFrame = create("ScrollingFrame")({
				Name = "RouteScroll",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.05, 0.05),
				Size = UDim2.fromScale(0.9, 0.9),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarImageColor3 = Color3.new(1, 1, 1),
				ScrollBarThickness = 7,
				ZIndex = 7,
				Parent = routesSidebar.gui
			})

			create("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0.01, 0),
				Parent = routesScrollFrame
			})

			local searchHeader = _p.RoundedFrame:new({
				["Name"] = "SearchFrame",
				["BackgroundColor3"] = Color3.fromRGB(255, 48, 58),
				["Position"] = UDim2.fromScale(0, 0),
				["Size"] = UDim2.fromScale(0.45, 0.19),
				["ZIndex"] = 7,
				["Parent"] = routesContainerFrame
			})

			create("TextLabel")({
				Name = "SearchTitle",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -20, 0.34, 0),
				Position = UDim2.new(0, 10, 0, 4),
				Text = "Search",
				Font = Enum.Font.GothamBlack,
				TextSize = 18,
				TextColor3 = Color3.fromRGB(140, 20, 30),
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				ZIndex = 8,
				Parent = searchHeader.gui
			})

			local searchBarShell = _p.RoundedFrame:new({
				["Name"] = "SearchBoxHolder",
				["BackgroundColor3"] = Color3.fromRGB(245, 245, 245),
				["Position"] = UDim2.fromScale(0.06, 0.52),
				["Size"] = UDim2.fromScale(0.88, 0.28),
				["ZIndex"] = 8,
				["Parent"] = searchHeader.gui
			})

			searchBox = create("TextBox")({
				Name = "SearchBox",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ClearTextOnFocus = false,
				Font = Enum.Font.GothamSemibold,
				PlaceholderText = "Search Pokemon",
				PlaceholderColor3 = Color3.fromRGB(170, 170, 170),
				Text = "",
				TextColor3 = Color3.fromRGB(80, 30, 35),
				TextSize = 14,
				TextScaled = false,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				Size = UDim2.new(1, -16, 1, 0),
				Position = UDim2.new(0, 8, 0, 0),
				ZIndex = 9,
				Parent = searchBarShell.gui
			})

			routesListContainer = _p.RoundedFrame:new({
				["BackgroundColor3"] = Color3.new(0.8156862745098039, 0.17647058823529413, 0.20784313725490197),
				["Position"] = UDim2.fromScale(0, 0.2),
				["Size"] = UDim2.fromScale(0.45, 0.8),
				["ZIndex"] = 7,
				["Parent"] = routesContainerFrame
			})

			routesGridContainer = create("ScrollingFrame")({
				Name = "RouteGrid",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.05, 0.05),
				Size = UDim2.fromScale(0.9, 0.9),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.None,
				ScrollBarImageColor3 = Color3.new(1, 1, 1),
				ScrollBarThickness = 7,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				Active = true,
				ScrollingEnabled = true,
				ZIndex = 7,
				Parent = routesListContainer.gui
			})


			task.spawn(function()
				allRouteEncounters = self:getRoutesWithEncounters()
				regionNames = _p.Network:get("PDS", "getAllRegionNames")

				for _, routeName in ipairs(regionNames) do
					local encountersForRoute = allRouteEncounters[routeName]
					if encountersForRoute then
						if routeName == selectedRouteName then
							self:updateRoutesTitle(routeName)
							self:loadRouteSummary(routeName, encountersForRoute)
						end

						local routeButton = _p.RoundedFrame:new({
							Name = routeName,
							["BackgroundColor3"] = Color3.new(0.9333333333333333, 0.20392156862745098, 0.22745098039215686),
							["Size"] = UDim2.fromScale(0.9, 0.07),
							["ZIndex"] = 7,
							["Button"] = true,
							["MouseButton1Click"] = function()
								selectedRouteName = routeName
								self:updateRoutesTitle(routeName)
								self:loadRouteSummary(routeName, encountersForRoute)
							end,
							["Parent"] = routesScrollFrame
						})

						local routeLabel = write(tostring(routeName))
						routeLabel({
							["Frame"] = create("Frame")({
								Name = routeName,
								["AnchorPoint"] = Vector2.new(0.5, 0.5),
								["BackgroundTransparency"] = 1,
								["Size"] = UDim2.new(0, 0, 0.5, 0),
								["Position"] = UDim2.new(0.5, 0, 0.5, 0),
								["ZIndex"] = 7,
								["Parent"] = routeButton.gui
							}),
							["Scaled"] = true,
							["Color"] = innerBorder.BackgroundColor3
						})
					end
				end

				if searchBox then
					searchBox:GetPropertyChangedSignal("Text"):Connect(function()
						self:loadSearchResults(searchBox.Text)
					end)
				end
			end)

			local function update(prop)
				if prop ~= 'AbsoluteSize' then return end
				gui.Position = UDim2.new(0.5, -gui.gui.AbsoluteSize.X/2, gui.Position.Y.Scale, 0)
				local c = Utilities.gui.AbsoluteSize.Y*.02
				gui.CornerRadius = c
				local gh = gui.AbsoluteSize.Y
				outerBorder.CornerRadius = c+(outerBorder.gui.AbsoluteSize.Y-gh)/2
				innerBorder.CornerRadius = c+(innerBorder.gui.AbsoluteSize.Y-gh)/2
				rightTray.CornerRadius = c
				leftTray.CornerRadius = c
				topTray.CornerRadius = c
				tabRoutesFrame.CornerRadius = c
				grid:ClearAllChildren()
				local gw = math.max(1, math.floor(gh*.02/zoom))
				local mx = squares.X+.5
				for x = 1, squares.X+1 do
					create 'Frame' {
						BorderSizePixel = 0,
						BackgroundColor3 = GRID_COLOR,
						Size = UDim2.new(0.0, gw, 1.0, -gw*2),
						Position = UDim2.new((x-.75)/mx, -math.floor(gw/2), 0.0, gw),
						ZIndex = 6, Parent = grid,
					}
				end
				local my = squares.Y+.5
				for y = 1, squares.Y+1 do
					create 'Frame' {
						BorderSizePixel = 0,
						BackgroundColor3 = GRID_COLOR,
						Size = UDim2.new(1.0, -gw*2, 0.0, gw),
						Position = UDim2.new(0.0, gw, (y-.75)/my, -math.floor(gw/2)),
						ZIndex = 6, Parent = grid,
					}
				end
				iconContainer.Size = UDim2.new(squares.X/(squares.X+.5), 0, squares.Y/(squares.Y+.5), 0)
				iconContainer.Position = UDim2.new(.25/(squares.X+.5), 0, .25/(squares.Y+.5), 0)
				routesContainerFrame.Size = UDim2.new(squares.X / (squares.X + 0.5), 0, squares.Y / (squares.Y + 0.5), 0)
				routesContainerFrame.Position = UDim2.new(0.25 / (squares.X + 0.5), 0, 0.25 / (squares.Y + 0.5), 0)
				entryContainer.Size = UDim2.new(1.0, -gw*2, 1.0, -gw*2)
				entryContainer.Position = UDim2.new(0.0, gw, 0.0, gw)
			end
			Utilities.gui.Changed:connect(update)
			update('AbsoluteSize')
			function pokedex:redrawGrid()
				update('AbsoluteSize')
			end
		end
		busy = true
		background.Parent = Utilities.gui
		gui.Parent = Utilities.gui
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			background.BackgroundTransparency = 1-.5*a
			gui.Position = UDim2.new(0.5, -gui.gui.AbsoluteSize.X/2, 1.15-a, 0)
		end)
		while not dex do wait() end
		self:read(dex)
		self:viewPage(1)
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			rightTray.Position = UDim2.new(.65+.2*a, 0, 0.1, 0)
			topTray.Position = UDim2.new(0.2, 0, -.2*a, 0)
			tabRoutesFrame.Position = UDim2.new(0.52, 0, -0.2 * a, 0)
		end)
		busy = false
	end

	function pokedex:close()
		if not gui or busy then return end
		busy = true

		_p.DataManager:dumpCache('PokedexExtended')

		spawn(function()
			Utilities.Tween(.5, 'easeOutCubic', function(a)
				rightTray.Position = UDim2.new(.85-.2*a, 0, 0.1, 0)
				topTray.Position = UDim2.new(0.2, 0, -.2+.2*a, 0)
				tabRoutesFrame.Position = UDim2.new(0.52, 0, -0.2 + 0.2 * a, 0)
			end)
		end)
		wait(.25)
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			background.BackgroundTransparency = .5+.5*a
			gui.Position = UDim2.new(0.5, -gui.gui.AbsoluteSize.X/2, .15+a, 0)
		end)
		gui.Parent = nil
		background.Parent = nil
		self.dexData = nil
		busy = false

		spawn(function() _p.Menu:enable() end)
		MasterControl.WalkEnabled = true
	end

	function pokedex:switchTabs(newTab)
		if not self.currentTab then
			self.currentTab = topTray
			self.currentView = iconContainer
		end

		if self.currentTab == newTab then
			return
		else
			self.currentTab.BackgroundColor3 = Color3.new(0.8156862745098039, 0.17647058823529413, 0.20784313725490197)
			newTab.BackgroundColor3 = Color3.new(0.9333333333333333, 0.20392156862745098, 0.22745098039215686)
			self.currentTab = newTab

			if newTab == topTray then
				routesContainerFrame.Visible = false
				iconContainer.Visible = true
				self.currentView = iconContainer
			elseif newTab == tabRoutesFrame then
				routesContainerFrame.Visible = true
				iconContainer.Visible = false
				self.currentView = routesContainerFrame
			end
		end
	end

	local formatHeldItems

	local function looksLikeHeldItem(value)
		if type(value) ~= "string" then return false end
		if value == "" then return false end

		local lower = value:lower()

		if lower == "m" or lower == "f" then return false end
		if lower == "male" or lower == "female" then return false end
		if lower == "grass" or lower == "oldrod" or lower == "goodrod" or lower == "surf" then return false end
		if tonumber(value) then return false end

		return true
	end

	local function getHeldItemFromEncounter(enc)
		for i, value in ipairs(enc) do
			if i ~= 1 and i ~= 4 and i ~= 7 then
				if looksLikeHeldItem(value) then
					return value
				end
			end
		end
		return ""
	end

	function pokedex:getRoutesWithEncounters()
		local encounterTypes = {
			"Grass",
			"OldRod",
			"GoodRod",
			"Surf",
			"PalmTree",
			"PineTree",
			"MiscEncounter",
			"InsideEnc"
		}
		local regionsWithEncounters = {}
		local allChunks = _p.Network:get("PDS", "getChunkData")

		for chunkName, chunk in pairs(allChunks) do
			if chunkName == "encounterLists" then continue end
			if type(chunk) ~= "table" then continue end
			if chunk.regions then
				for regionName, regionData in pairs(chunk.regions) do
					if type(regionData) ~= "table" then continue end
					local foundEncounters = {}

					for _, encType in ipairs(encounterTypes) do
						local encBucket = regionData[encType]
						if not encBucket or type(encBucket) ~= "table" then continue end

						local encList = allChunks.encounterLists[encBucket.id]
						if encList and encList.list then
							local totalWeight = 0
							for _, encounter in ipairs(encList.list) do
								totalWeight = totalWeight + (encounter[4] or 0)
							end

							for _, enc in ipairs(encList.list) do
								local weight = enc[4]
								if weight and weight > 0 and totalWeight > 0 then
									local rawChance = (weight / totalWeight) * 100

									-- hide ultra-rare entries that round to 0%
									if rawChance >= 1 then
										local chance = math.floor(rawChance + 0.5) .. "%"
										local display = encType
										if encType == "OldRod" then
											display = "Old Rod"
										elseif encType == "GoodRod" then
											display = "Good Rod"
										end

										local heldItem = formatHeldItems(enc)

										table.insert(foundEncounters, {
											enc[1],        -- species
											enc[7] or '',  -- form
											chance,        -- chance
											display,       -- encounter type
											heldItem       -- held item
										})
									end
								end
							end
						end
					end

					if #foundEncounters > 0 then
						regionsWithEncounters[regionName] = foundEncounters
					end
				end
			end
		end

		return regionsWithEncounters
	end
	local infoCache = {}
	local function getInfoCached(species, form)
		local cacheKey = species:lower() .. ":" .. form:lower()
		if not infoCache[cacheKey] then
			infoCache[cacheKey] = _p.Network:get("PDS", "getInfoOf", species:lower(), form:lower())
		end
		return infoCache[cacheKey]
	end

	formatHeldItems = function(encounterData)
		local heldItems = {}
		local i = 8

		while i <= #encounterData do
			local itemName = encounterData[i]
			local itemChance = encounterData[i + 1]

			if type(itemName) == "string" and itemName ~= "" and looksLikeHeldItem(itemName) then
				local displayName = itemName
				if type(itemChance) == "number" and itemChance > 0 then
					displayName = string.format("%s %g%%", itemName, itemChance)
				end
				table.insert(heldItems, displayName)
				i = i + 2
			else
				i = i + 1
			end
		end

		if #heldItems == 0 then
			return "None"
		end

		return table.concat(heldItems, ", ")
	end

	function pokedex:updateRoutesTitle(titleText)
		selectedRouteName = titleText or selectedRouteName
		if routesTitleFrame.gui:FindFirstChild("TextContainer") then
			routesTitleFrame.gui.TextContainer:Destroy()
		end

		local titleFunc = write(tostring(titleText or ""))
		titleFunc({
			["Frame"] = create("Frame")({
				["Name"] = "TextContainer",
				["AnchorPoint"] = Vector2.new(0.5, 0.5),
				["BackgroundTransparency"] = 1,
				["Size"] = UDim2.new(0.6, 0, #(tostring(titleText or "")) > 9 and 0.3 or 0.5, 0),
				["Position"] = UDim2.new(0.5, 0, 0.5, 0),
				["ZIndex"] = 7,
				["Parent"] = routesTitleFrame.gui
			}),
			["Scaled"] = true,
			["Color"] = Color3.new(0.5764705882352941, 0.07450980392156863, 0.13725490196078433)
		})
	end

	function pokedex:loadSearchResults(searchText)
		for _, child in ipairs(routesGridContainer:GetChildren()) do
			if child:IsA("GuiObject") then
				child:Destroy()
			end
		end

		routesGridContainer.CanvasPosition = Vector2.new(0, 0)
		routesGridContainer.AutomaticCanvasSize = Enum.AutomaticSize.None

		local query = string.lower((searchText or ""):gsub("^%s+", ""):gsub("%s+$", ""))
		if query == "" then
			local encounters = allRouteEncounters[selectedRouteName]
			if encounters then
				self:updateRoutesTitle(selectedRouteName)
				self:loadRouteSummary(selectedRouteName, encounters)
			end
			return
		end

		self:updateRoutesTitle("Search")

		local results = {}
		for routeName, encounters in pairs(allRouteEncounters) do
			for _, encounter in ipairs(encounters) do
				local speciesName = tostring(encounter[1] or "")
				local form = tostring(encounter[2] or "")
				local chance = tostring(encounter[3] or "0%")
				local encounterType = tostring(encounter[4] or "")
				local heldItem = tostring(encounter[5] or "")
				local haystack = string.lower(speciesName .. " " .. form)
				if string.find(haystack, query, 1, true) then
					table.insert(results, {
						routeName = routeName,
						speciesName = speciesName,
						form = form,
						chance = chance,
						encounterType = encounterType,
						heldItem = heldItem,
					})
				end
			end
		end

		table.sort(results, function(a, b)
			if a.speciesName == b.speciesName then
				return a.routeName < b.routeName
			end
			return a.speciesName < b.speciesName
		end)

		local function createText(parent, textValue, size, position, textSize, color, font, xAlign, zIndex, transparency)
			return create("TextLabel")({
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = size,
				Position = position,
				Text = tostring(textValue or ""),
				Font = font or Enum.Font.GothamBold,
				TextSize = textSize or 18,
				TextColor3 = color or Color3.new(1, 1, 1),
				TextXAlignment = xAlign or Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				TextTransparency = transparency or 0,
				TextWrapped = false,
				TextScaled = false,
				ClipsDescendants = true,
				ZIndex = zIndex or 10,
				Parent = parent
			})
		end

		local currentY = 0
		local rowHeight = 70
		local rowGap = 6

		for _, result in ipairs(results) do
			local dexCheck = getInfoCached(result.speciesName, result.form or "")
			if dexCheck then
				local dexNumber, iconIndex, hasSeen = dexCheck.number, dexCheck.icon, dexCheck.hasSeen
				local itemText = (result.heldItem ~= "" and result.heldItem ~= "None") and result.heldItem or "No held items"
				local row = _p.RoundedFrame:new({
					Name = result.speciesName .. "_" .. result.routeName .. "_SearchEntry",
					BackgroundColor3 = Color3.fromRGB(236, 92, 112),
					Size = UDim2.new(1, -6, 0, rowHeight),
					Position = UDim2.new(0, 0, 0, currentY),
					ZIndex = 8,
					Button = true,
					MouseButton1Click = function()
						if searchBox then
							searchBox.Text = result.speciesName
						end
						routesContainerFrame.Visible = false
						if hasSeen then
							self:showPokemonEntry(dexNumber)
						else
							self:showPokemonEntry(dexNumber, true)
						end
					end,
					Parent = routesGridContainer
				})

				local iconShell = _p.RoundedFrame:new({
					Name = "IconShell",
					BackgroundColor3 = Color3.fromRGB(187, 34, 61),
					Size = UDim2.new(0, 38, 0, 38),
					Position = UDim2.new(0, 8, 0.5, -19),
					ZIndex = 9,
					Parent = row.gui
				})

				local chanceBadge = _p.RoundedFrame:new({
					Name = "ChanceBadge",
					BackgroundColor3 = Color3.fromRGB(154, 17, 43),
					Size = UDim2.new(0, 56, 0, 24),
					Position = UDim2.new(1, -64, 0.5, -12),
					ZIndex = 9,
					Parent = row.gui
				})

				local iconImage = _p.Pokemon:getIcon(iconIndex - 1)
				iconImage.SizeConstraint = Enum.SizeConstraint.RelativeYY
				iconImage.Size = UDim2.new(0, 30, 0, 30)
				iconImage.Position = UDim2.new(0.5, -15, 0.5, -15)
				iconImage.BackgroundTransparency = 1
				iconImage.ZIndex = 10
				if not hasSeen then
					iconImage.ImageColor3 = Color3.new(0, 0, 0)
				end
				iconImage.Parent = iconShell.gui

				createText(row.gui, result.speciesName, UDim2.new(1, -130, 0, 22), UDim2.new(0, 54, 0, 6), 15, Color3.fromRGB(255, 248, 249), Enum.Font.GothamBold, Enum.TextXAlignment.Left, 10)
				createText(row.gui, result.routeName .. " • " .. result.encounterType, UDim2.new(1, -130, 0, 18), UDim2.new(0, 54, 0, 28), 11, Color3.fromRGB(255, 235, 239), Enum.Font.GothamBold, Enum.TextXAlignment.Left, 10)
				createText(chanceBadge.gui, result.chance, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 13, Color3.fromRGB(255, 244, 246), Enum.Font.GothamBlack, Enum.TextXAlignment.Center, 10)

				local subLine = itemText
				if result.form ~= "" and result.form ~= nil then
					subLine = tostring(result.form) .. " - " .. subLine
				end
				local subLabel = createText(row.gui, subLine, UDim2.new(1, -130, 0, 20), UDim2.new(0, 54, 0, 46), 10, Color3.fromRGB(255, 224, 229), Enum.Font.GothamMedium, Enum.TextXAlignment.Left, 10)
				subLabel.TextWrapped = true
				subLabel.TextYAlignment = Enum.TextYAlignment.Top

				currentY = currentY + rowHeight + rowGap
			end
		end

		if #results == 0 then
			createText(routesGridContainer, "No Pokémon found", UDim2.new(1, -12, 0, 32), UDim2.new(0, 0, 0, 4), 18, Color3.fromRGB(255, 235, 239), Enum.Font.GothamBold, Enum.TextXAlignment.Center, 10)
			currentY = 40
		end

		routesGridContainer.CanvasSize = UDim2.new(0, 0, 0, math.max(currentY, routesGridContainer.AbsoluteSize.Y + 1))
	end

	function pokedex:loadRouteSummary(regionName, encounters)
		for _, child in ipairs(routesGridContainer:GetChildren()) do
			if child:IsA("GuiObject") and child.Name ~= "UIListLayout" then
				child:Destroy()
			end
		end

		routesGridContainer.CanvasPosition = Vector2.new(0, 0)
		routesGridContainer.AutomaticCanvasSize = Enum.AutomaticSize.None

		local orderMap = {
			Grass = 1,
			Surf = 2,
			["Old Rod"] = 3,
			["Good Rod"] = 4,
			PalmTree = 5,
			PineTree = 6,
			MiscEncounter = 7,
		}

		local function createText(parent, textValue, size, position, textSize, color, font, xAlign, zIndex, transparency)
			return create("TextLabel")({
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = size,
				Position = position,
				Text = tostring(textValue or ""),
				Font = font or Enum.Font.GothamBold,
				TextSize = textSize or 18,
				TextColor3 = color or Color3.new(1, 1, 1),
				TextXAlignment = xAlign or Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				TextTransparency = transparency or 0,
				TextWrapped = false,
				TextScaled = false,
				ClipsDescendants = true,
				ZIndex = zIndex or 10,
				Parent = parent
			})
		end

		local groupedEncounters = {}
		for _, encounter in ipairs(encounters) do
			local encType = encounter[4] or "Other"
			groupedEncounters[encType] = groupedEncounters[encType] or {}
			table.insert(groupedEncounters[encType], encounter)
		end

		local sectionOrder = {}
		for encType in pairs(groupedEncounters) do
			table.insert(sectionOrder, encType)
		end
		table.sort(sectionOrder, function(a, b)
			return (orderMap[a] or 99) < (orderMap[b] or 99)
		end)

		local currentY = 0
		local sectionGap = 8
		local headerHeight = 34
		local rowHeight = 70
		local rowGap = 6

		for _, encType in ipairs(sectionOrder) do
			local typeEncounters = groupedEncounters[encType]
			local sectionHeight = 8 + headerHeight + 6 + (#typeEncounters * rowHeight) + (math.max(#typeEncounters - 1, 0) * rowGap) + 8

			local section = _p.RoundedFrame:new({
				Name = tostring(encType) .. "_Section",
				BackgroundColor3 = Color3.fromRGB(214, 39, 62),
				Size = UDim2.new(1, -6, 0, sectionHeight),
				Position = UDim2.new(0, 0, 0, currentY),
				ZIndex = 7,
				Parent = routesGridContainer
			})

			local header = _p.RoundedFrame:new({
				Name = tostring(encType) .. "_Header",
				BackgroundColor3 = Color3.fromRGB(168, 18, 45),
				Size = UDim2.new(1, -16, 0, headerHeight),
				Position = UDim2.new(0, 8, 0, 8),
				ZIndex = 8,
				Parent = section.gui
			})

			createText(header.gui, encType, UDim2.new(1, -20, 1, 0), UDim2.new(0, 10, 0, 0), 18, Color3.fromRGB(255, 245, 246), Enum.Font.GothamBlack, Enum.TextXAlignment.Left, 9)

			for i, encounter in ipairs(typeEncounters) do
				local speciesName = encounter[1]
				local form = encounter[2]
				local chance = tostring(encounter[3] or "0%")
				local heldItem = encounter[5] or ""

				local dexCheck = getInfoCached(speciesName, form or "")
				if dexCheck then
					local dexNumber, iconIndex, hasSeen = dexCheck.number, dexCheck.icon, dexCheck.hasSeen
					local itemText = (heldItem ~= "" and heldItem ~= "None") and heldItem or "No held items"
					local rowY = 8 + headerHeight + 6 + ((i - 1) * (rowHeight + rowGap))

					local row = _p.RoundedFrame:new({
						Name = speciesName .. "_" .. tostring(encType) .. "_Entry",
						BackgroundColor3 = Color3.fromRGB(236, 92, 112),
						Size = UDim2.new(1, -16, 0, rowHeight),
						Position = UDim2.new(0, 8, 0, rowY),
						ZIndex = 8,
						Button = true,
						MouseButton1Click = function()
							routesContainerFrame.Visible = false
							if hasSeen then
								self:showPokemonEntry(dexNumber)
							else
								self:showPokemonEntry(dexNumber, true)
							end
						end,
						Parent = section.gui
					})

					local iconShell = _p.RoundedFrame:new({
						Name = "IconShell",
						BackgroundColor3 = Color3.fromRGB(187, 34, 61),
						Size = UDim2.new(0, 38, 0, 38),
						Position = UDim2.new(0, 8, 0.5, -19),
						ZIndex = 9,
						Parent = row.gui
					})

					local chanceBadge = _p.RoundedFrame:new({
						Name = "ChanceBadge",
						BackgroundColor3 = Color3.fromRGB(154, 17, 43),
						Size = UDim2.new(0, 56, 0, 24),
						Position = UDim2.new(1, -64, 0.5, -12),
						ZIndex = 9,
						Parent = row.gui
					})

					local iconImage = _p.Pokemon:getIcon(iconIndex - 1)
					iconImage.SizeConstraint = Enum.SizeConstraint.RelativeYY
					iconImage.Size = UDim2.new(0, 30, 0, 30)
					iconImage.Position = UDim2.new(0.5, -15, 0.5, -15)
					iconImage.BackgroundTransparency = 1
					iconImage.ZIndex = 10
					if not hasSeen then
						iconImage.ImageColor3 = Color3.new(0, 0, 0)
					end
					iconImage.Parent = iconShell.gui

					createText(row.gui, speciesName, UDim2.new(1, -126, 0, 20), UDim2.new(0, 54, 0, 8), 15, Color3.fromRGB(255, 248, 249), Enum.Font.GothamBold, Enum.TextXAlignment.Left, 10)
					createText(chanceBadge.gui, chance, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 13, Color3.fromRGB(255, 244, 246), Enum.Font.GothamBlack, Enum.TextXAlignment.Center, 10)

					local subLine = itemText
					if form ~= "" and form ~= nil then
						subLine = tostring(form) .. " - " .. subLine
					end
					do
						local subLabel = createText(row.gui, subLine, UDim2.new(1, -122, 0, 26), UDim2.new(0, 54, 0, 30), 10, Color3.fromRGB(255, 224, 229), Enum.Font.GothamMedium, Enum.TextXAlignment.Left, 10)
						subLabel.TextWrapped = true
						subLabel.TextYAlignment = Enum.TextYAlignment.Top
					end
				end
			end

			currentY = currentY + sectionHeight + sectionGap
		end

		routesGridContainer.CanvasSize = UDim2.new(0, 0, 0, math.max(currentY, routesGridContainer.AbsoluteSize.Y + 1))
	end

	return pokedex
end