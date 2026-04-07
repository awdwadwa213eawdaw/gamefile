return function(_p)--local _p = require(script.Parent)
	local Utilities = _p.Utilities
	local Create = Utilities.Create
	local Tween = Utilities.Tween
	local storage = game:GetService('ReplicatedStorage')
	local TweenService = game:GetService("TweenService")
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local write = Utilities.Write
	local roundedFrame = _p.RoundedFrame
	local battleOutcome = storage.Models.Win.Value
	local MaxRaid = {
		isOpen = false,
		debugEnabled = false,
		generatedData = {
			--Stores raid keys with data
		}
	}
	local chat = _p.NPCChat
	local create = Utilities.Create

	local raidData = {
		beams = {
			{6297011462, Color3.fromRGB(255, 0, 116), 10, 1},
			{6297011462, Color3.fromRGB(255, 0, 116), 10, 1},
			{0, Color3.fromRGB(255, 0, 116), 1.5, 1},
			{0, Color3.fromRGB(255, 0, 116), 1.5, 1},
			{0, Color3.fromRGB(40, 0, 65), 1.5, 0},
			{0, Color3.fromRGB(40, 0, 65), 1.5, 0},
		},
		tips = {
			"All Pokemon have a 5x HP Multiplier.",
			"Learn the weaknesses of the Raid Boss and choose Pokemon that have type advantages against it. This can significantly increase your damage output.",
			"Dynamaxing or Gigantamaxing your Pokémon during raids can give you a significant advantage. It increases their HP and unlocks powerful Max Moves.",
			"Held items can make a big difference. Berries that heal status conditions or items that boost specific stats can turn the tide of a battle.",
			"Moves that inflict status conditions or debuffs can be incredibly helpful. Use moves like Thunder Wave, Will-O-Wisp, or moves that decrease the raid boss's stats.",
			"Always carry healing items like Max Potions, Full Restores, and Revives. They can save your team from fainting and give you an edge in tough raid battles.",
		}
	}
	local function intable(tbl, val)
		for _, v in pairs(tbl) do
			if v == val then
				return true
			end			
		end
		return
	end
	local function getTime()
		local date = os.date("*t")
		return ("%02d:%02d"):format(((date.hour % 24) - 1) % 12 + 1, date.min)
	end

	function MaxRaid:maxRaidBeam(targ)
		if targ:FindFirstChild('SFXFolder') then
			for _, item in pairs(targ.SFXFolder:GetChildren()) do
				item:Destroy()
			end
			targ.GlowingDen.Transparency = 1
			targ.Den.Transparency = 0
		else
			Create("Folder")({
				Name = 'SFXFolder',
				Parent = targ
			})
			Create("Attachment")({
				Name = 'Attachment1',
				CFrame = CFrame.new(0, 0, 4.5), 
				Parent = targ.Den
			})
			Create("Attachment")({
				Name = 'Attachment2',
				CFrame = CFrame.new(0, 0, 1886.5), 
				Parent = targ.Den
			})
		end

		if targ.Key.Value == '' then
			return
		end

		targ.GlowingDen.Transparency = 0
		targ.Den.Transparency = 1	
		local data = raidData.beams[tonumber(self.generatedData[targ.Key.Value].displayData.Tier)]
		local Beam = Create("Beam")({
			Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0), -- (time, value)
				NumberSequenceKeypoint.new(.915, .75),
				NumberSequenceKeypoint.new(1, 1)
			},
			LightEmission = data[4],
			LightInfluence = data[4],
			TextureLength = 6,
			TextureSpeed = 3,
			Color = ColorSequence.new(data[2]),
			Texture = (data[1] ~= 0 and 'rbxassetid://'..data[1] or ''),
			FaceCamera = true,
			TextureMode = Enum.TextureMode.Stretch,
			CurveSize0 = 0,
			CurveSize1 = 0,
			Segments = 1,
			Width0 = data[3],
			Width1 = data[3],
			Parent = targ.SFXFolder,
			Attachment0 = targ.Den.Attachment1,
			Attachment1 = targ.Den.Attachment2
		})
	end

	function MaxRaid:generateMaxInterface(denData, model, encData)
		local tips = raidData.tips[math.random(1, #raidData.tips)]
		local displayData = denData.displayData

		local guiOpen = false
		self.isOpen = true
		task.spawn(_p.Menu.disable, _p.Menu)

		local holderScreenGui = Create("ScreenGui")({
			ClipToDeviceSafeArea = true,
			SafeAreaCompatibility = Enum.SafeAreaCompatibility.FullscreenExtension,
			ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			IgnoreGuiInset = true,
			--Parent = Utilities.gui
		})

		local holderFrame = Create("Frame")({
			BorderSizePixel = 0,
			BackgroundTransparency = 0,
			Size = UDim2.new(0.938, 0, 1, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Position = UDim2.new(0.164, 0, 0, 0),
			Style = Enum.FrameStyle.Custom,
			SizeConstraint = Enum.SizeConstraint.RelativeXY,
			Parent = holderScreenGui
		})


		-- Stars
		local starFrame = Create("Frame")({
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Size = UDim2.new(0.359, 0, 0.129, 0),
			Position = UDim2.new(-0.157, 0, 0.051, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			ZIndex = 3,
			Parent = holderFrame,

			Create("UIListLayout")({
				Padding = UDim.new(0.026, 0),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center
			}),
		})

		-- Buttons
		local buttonFrame = Create("Frame")({
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.new(0, 0, 0),
			Size = UDim2.new(0.408, 0, 0.318, 0),
			Position = UDim2.new(0.445, 0, 0.669, 0),
			Parent = holderFrame,

			Create("UIListLayout")({
				Padding = UDim.new(0.08, 0),
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Top
			}),

			-- Quit
			Create("ImageButton")({
				LayoutOrder = 3,
				BorderSizePixel = 0,
				Name = "quitButton",
				BackgroundColor3 = Color3.fromRGB(239, 240, 242),
				BackgroundTransparency = 0,
				Size = UDim2.new(1.002, 0, 0.193, 0),
				SizeConstraint = Enum.SizeConstraint.RelativeXY,
				Style = Enum.ButtonStyle.Custom,
				ImageColor3 = Color3.new(1, 1, 1),
				ImageTransparency = 0,
				MouseButton1Click = function()
					if guiOpen then
						return
					end
					guiOpen = true

					Tween(.3, "easeInOutQuad", function(a)
						holderFrame.Position = UDim2.new(-1.05*a, 0, 0, 0)
					end)

					holderFrame:Destroy()
					task.spawn(_p.Menu.enable, _p.Menu)
					_p.MasterControl.WalkEnabled = true

					self.isOpen = false
					guiOpen = false
				end,

				Create("UICorner")({
					CornerRadius = UDim.new(1, 0)
				}),

				Create("TextLabel")({
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.new(1, 1, 1),
					BackgroundTransparency = 1,
					Position = UDim2.new(0.02, 0, 0.123, 0),
					Size = UDim2.new(0.98, 0, 0.741, 0),
					FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
					LineHeight = 1,
					MaxVisibleGraphemes = -1,
					Text = "Quit",
					TextColor3 = Color3.new(0, 0, 0),
					TextDirection = Enum.TextDirection.Auto,
					TextScaled = true,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextTruncate = Enum.TextTruncate.None,

					Create("UITextSizeConstraint")({
						MaxTextSize = 50,
						MinTextSize = 1
					})
				})
			}),

			-- Ready
			Create("ImageButton")({
				LayoutOrder = 1,
				BorderSizePixel = 0,
				Name = "readyButton",
				BackgroundColor3 = Color3.fromRGB(239, 240, 242),
				BackgroundTransparency = 0,
				Size = UDim2.new(1.002, 0, 0.193, 0),
				SizeConstraint = Enum.SizeConstraint.RelativeXY,
				Style = Enum.ButtonStyle.Custom,
				ImageColor3 = Color3.new(1, 1, 1),
				ImageTransparency = 0,
				MouseButton1Click = function()
					if guiOpen then
						return
					end
					guiOpen = true

					Tween(.3, "easeInOutQuad", function(a)
						holderFrame.Position = UDim2.new(-1.05*a, 0, 0, 0)
					end)

					holderFrame:Destroy()
					task.spawn(_p.Menu.enable, _p.Menu)

					self:Raid(encData, model.Key.Value, denData.displayData.Tier, displayData.iconData.Name, displayData.iconData.Formes, displayData.iconData.Typing)
					self:UpdateRaidDen(model, true)
					self.isOpen = false
					guiOpen = false
					return
				end,

				Create("UICorner")({
					CornerRadius = UDim.new(1, 0)
				}),

				Create("TextLabel")({
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.new(1, 1, 1),
					BackgroundTransparency = 1,
					Position = UDim2.new(0.02, 0, 0.123, 0),
					Size = UDim2.new(0.98, 0, 0.741, 0),
					FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
					LineHeight = 1,
					MaxVisibleGraphemes = -1,
					Text = "Ready to Battle!",
					TextColor3 = Color3.new(0, 0, 0),
					TextDirection = Enum.TextDirection.Auto,
					TextScaled = true,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextTruncate = Enum.TextTruncate.None,

					Create("UITextSizeConstraint")({
						MaxTextSize = 50,
						MinTextSize = 1
					})
				})
			}),

			-- Switch
			Create("ImageButton")({
				LayoutOrder = 2,
				BorderSizePixel = 0,
				Name = "switchButton",
				BackgroundColor3 = Color3.fromRGB(239, 240, 242),
				BackgroundTransparency = 0,
				Size = UDim2.new(1.002, 0, 0.193, 0),
				SizeConstraint = Enum.SizeConstraint.RelativeXY,
				Style = Enum.ButtonStyle.Custom,
				ImageColor3 = Color3.new(1, 1, 1),
				ImageTransparency = 0,
				MouseButton1Click = function()
					if guiOpen then
						return
					end
					guiOpen = true

					holderFrame:Destroy()

					local slot = _p.BattleGui:chooseRaid("Choose")
					_p.Network:get("PDS", "RaidParty", slot or nil, slot and true or false)
					self:generateMaxInterface(denData, model, encData)
					guiOpen = false
				end,

				Create("UICorner")({
					CornerRadius = UDim.new(1, 0)
				}),

				Create("TextLabel")({
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.new(1, 1, 1),
					BackgroundTransparency = 1,
					Position = UDim2.new(0.02, 0, 0.123, 0),
					Size = UDim2.new(0.98, 0, 0.741, 0),
					FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
					LineHeight = 1,
					MaxVisibleGraphemes = -1,
					Text = "Switch Pokémon",
					TextColor3 = Color3.new(0, 0, 0),
					TextDirection = Enum.TextDirection.Auto,
					TextScaled = true,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextTruncate = Enum.TextTruncate.None,

					Create("UITextSizeConstraint")({
						MaxTextSize = 50,
						MinTextSize = 1
					})
				})
			}),

			-- Arrow
			Create("ImageLabel")({
				Name = "pointArrow",
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 1,
				Rotation = 89,
				Size = UDim2.new(0, 52, 0, 51),
				Visible = false,
				ZIndex = 9,
				Image = "rbxassetid://14449623790",
				ImageColor3 = Color3.new(1, 1, 1),
				ImageTransparency = 0
			})
		})

		-- Types
		local typeFrame = Create("Frame")({
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Size = UDim2.new(0.309, 0, 0.061, 0),
			Position = UDim2.new(-0.157, 0, 0.16, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			ZIndex = 3,
			Parent = holderFrame,

			Create("UIListLayout")({
				Padding = UDim.new(0.026, 0),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center
			})
		})

		-- Player
		local playerFrame = Create("Frame")({
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.new(0, 0, 0),
			Position = UDim2.new(0.453, 0, 0.246, 0),
			Size = UDim2.new(0.402, 0, 0.336, 0),
			Parent = holderFrame,

			Create("UIListLayout")({
				Padding = UDim.new(0, 10),
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center
			}),

			-- Player
			Create("Frame")({
				BorderSizePixel = 0,
				Name = "localPlayerFrame",
				BackgroundTransparency = 1,
				BackgroundColor3 = Color3.fromRGB(255, 0, 0),
				Size = UDim2.new(0.991, 0, 0.272, 0),

				-- User Image
				Create("ImageLabel")({
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
					BackgroundColor3 = Color3.new(1, 1, 1),
					Position = UDim2.new(-0.021, 0, 0.058, 0),
					Size = UDim2.new(0.097, 0, 0.678, 0),
					Image = Players:GetUserThumbnailAsync(_p.userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48),

					Create("UICorner")({
						CornerRadius = UDim.new(1, 0)
					})
				}),

				-- Username
				Create("TextLabel")({
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.new(1, 1, 1),
					BackgroundTransparency = 1,
					Position = UDim2.new(0.094, 0, 0.18, 0),
					Size = UDim2.new(0.331, 0, 0.419, 0),
					FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
					LineHeight = 1,
					MaxVisibleGraphemes = -1,
					Text = _p.player.Name or "Username",
					TextColor3 = Color3.new(0, 0, 0),
					TextDirection = Enum.TextDirection.Auto,
					TextScaled = true,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextTruncate = Enum.TextTruncate.None,

					Create("UITextSizeConstraint")({
						MaxTextSize = 50,
						MinTextSize = 1
					})
				})
			}),

			-- Other Player
			Create("Frame")({
				BorderSizePixel = 0,
				Name = "otherPlayerFrame",
				BackgroundTransparency = 1,
				BackgroundColor3 = Color3.fromRGB(255, 0, 0),
				Size = UDim2.new(0.991, 0, 0.272, 0),

				-- Image
				Create("ImageLabel")({
					BorderSizePixel = 0,
					Name = "otherPlayerImage",
					BackgroundColor3 = Color3.new(1, 1, 1),
					BackgroundTransparency = 1,
					Size = UDim2.new(0.061, 0, 0.419, 0),
					Position = UDim2.new(-0.002, 0, 0.167, 0),
					Rotation = -25,
					ZIndex = 5,
					Image = "rbxassetid://14527407361",

					Create("UIAspectRatioConstraint")({
						AspectRatio = 1,
						AspectType = Enum.AspectType.FitWithinMaxSize,
						DominantAxis = Enum.DominantAxis.Width
					}),

					Create("UICorner")({
						CornerRadius = UDim.new(1, 0)
					})
				}),

				-- Text
				Create("TextLabel")({
					BorderSizePixel = 0,
					Name = "otherPlayerText",
					BackgroundColor3 = Color3.new(1, 1, 1),
					BackgroundTransparency = 1,
					Position = UDim2.new(0.094, 0, 0.18, 0),
					Size = UDim2.new(0.331, 0, 0.419, 0),
					FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
					LineHeight = 1,
					MaxVisibleGraphemes = -1,
					Text = "Searching...",
					TextColor3 = Color3.new(0, 0, 0),
					TextDirection = Enum.TextDirection.Auto,
					TextScaled = true,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextTruncate = Enum.TextTruncate.None,

					Create("UITextSizeConstraint")({
						MaxTextSize = 50,
						MinTextSize = 1
					})
				})
			})
		})

		-- Background Image
		Create("ImageLabel")({
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.new(1, 1, 1),
			Position = UDim2.new(-0.522, 0, -0.366, 0),
			Rotation = -5.3,
			Size = UDim2.new(1.078, 0, 1.558, 0),
			ImageColor3 = Color3.fromRGB(255, 52, 100),
			Image = "rbxassetid://15016910576",
			Parent = holderFrame,
		})

		-- Background Emblem
		Create("ImageLabel")({
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.new(1, 1, 1),
			Position = UDim2.new(-0.421, 0, 0.123, 0),
			Rotation = 20,
			Size = UDim2.new(0.785, 0, 1.067, 0),
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			Image = "rbxassetid://14598421251",
			ZIndex = 2,
			Parent = holderFrame,

			Create("UIGradient")({
				Rotation = -90,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(186, 30, 65)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 52, 100))
				})
			})
		})

		-- Time
		local timeRemaining = Create("TextLabel")({
			BorderSizePixel = 0,
			Parent = holderFrame,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			ZIndex = 2,
			Position = UDim2.new(0.681, 0, 0.168, 0),
			Size = UDim2.new(0.173, 0, 0.044, 0),
			FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			LineHeight = 1,
			MaxVisibleGraphemes = -1,
			Text = "5:00",
			TextColor3 = Color3.new(0, 0, 0),
			TextDirection = Enum.TextDirection.Auto,
			TextScaled = true,
			TextSize = 50,
			RichText = true,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Bottom,
			TextTruncate = Enum.TextTruncate.None,
		})

		Create("TextLabel")({
			BorderSizePixel = 0,
			Parent = holderFrame,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			ZIndex = 2,
			Position = UDim2.new(0.445, 0, 0.168, 0),
			Size = UDim2.new(0.248, 0, 0.044, 0),
			FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			LineHeight = 1,
			MaxVisibleGraphemes = -1,
			Text = "Time Remaining",
			RichText = true,
			TextColor3 = Color3.new(0, 0, 0),
			TextDirection = Enum.TextDirection.Auto,
			TextScaled = true,
			TextSize = 50,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextTruncate = Enum.TextTruncate.None,
		})

		-- Tips
		Create("ImageLabel")({
			Parent = holderFrame,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(1, 1, 1),
			Position = UDim2.new(-0.175, 0, 0.761, 0),
			Size = UDim2.new(0.267, 0, 0.049, 0),
			ZIndex = 3,
			Image = "rbxassetid://17673924894",
			ImageColor3 = Color3.fromRGB(115, 33, 48)
		})

		Create("TextLabel")({
			Parent = holderFrame,
			ZIndex = 4,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(-0.157, 0, 0.768, 0),
			Size = UDim2.new(0.203, 0, 0.041, 0),
			FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			LineHeight = 1,
			MaxVisibleGraphemes = -1,
			Text = tips,
			RichText = true,
			TextColor3 = Color3.new(1, 1, 1),
			TextDirection = Enum.TextDirection.Auto,
			TextScaled = true,
			TextSize = 50,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextTruncate = Enum.TextTruncate.None,

			Create("UITextSizeConstraint")({
				MaxTextSize = 50,
				MinTextSize = 1
			})
		})

		-- Weather
		local WeatherData = _p.Overworld.Weather.Icons
		local Weather = _p.Network:get('PDS', 'weatherUpdate')
		local WeatherVariantData = WeatherData[Weather[1][3]]--3 is non upper
		if Weather[1][1] ~= "Clear" or (WeatherVariantData ~= "" and WeatherVariantData ~= nil) then
			Create("ImageLabel")({
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				BackgroundColor3 = Color3.new(1, 1, 1),
				Image = "rbxassetid://14844978001",
				ImageRectSize = Vector2.new(100, 100),
				ImageRectOffset = WeatherVariantData.iconOffset or Vector2.new(101, 1),
				Position = UDim2.new(-0.158, 0, 0.704, 0),
				Size = UDim2.new(0, 43, 0, 43),
				ZIndex = 1001,
				Parent = holderFrame
			})
		end

		-- Pokemon Animated
		local raidPoke = displayData.iconData.Formes and _p.AnimatedSprite:new((_p.DataManager:getSprite("_FRONT", `{displayData.iconData.Name}-{displayData.iconData.Formes}`))) or _p.AnimatedSprite:new((_p.DataManager:getSprite("_FRONT", displayData.iconData.Name)))
		raidPoke.spriteLabel.Parent = holderFrame
		raidPoke.spriteLabel.Size = UDim2.new(0.355, 0, 0.482, 0)
		raidPoke.spriteLabel.Position = UDim2.new(-0.139, 0, 0.247, 0)
		raidPoke.spriteLabel.ZIndex = 1002
		--raidPoke.spriteLabel.SizeConstraint = Enum.SizeConstraint.RelativeYY
		raidPoke.spriteLabel.ImageColor3 = Color3.new(0, 0, 0)
		raidPoke:Play()

		-- Animate Arrow
		local pointArrow = buttonFrame.pointArrow
		if pointArrow then
			local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)

			pointArrow.Position = UDim2.new(-0.064, 0, 0, 0)
			TweenService:Create(pointArrow, tweenInfo, {Position = UDim2.new(-0.053, 0, 0, 0)}):Play()
		end

		for _, button in buttonFrame:GetChildren() do
			if not button:IsA("ImageButton") then
				continue
			end

			local function onMouseEnter()
				if pointArrow then
					pointArrow.Parent = button
					pointArrow.Visible = true
				end

				TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {BackgroundColor3 = Color3.fromRGB(0, 0, 0)}):Play()
				TweenService:Create(button.TextLabel, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			end

			local function onMouseLeave()
				if pointArrow then
					pointArrow.Visible = false
				end

				TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {BackgroundColor3 = Color3.fromRGB(239, 240, 242)}):Play()
				TweenService:Create(button.TextLabel, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {TextColor3 = Color3.fromRGB(0, 0, 0)}):Play()
			end

			-- Connections
			button.MouseEnter:Connect(onMouseEnter)
			button.MouseLeave:Connect(onMouseLeave)
		end


		-- Create Star
		local denTier = denData.displayData.Tier
		for stars = 1, denTier >= 6 and 5 or denTier do
			Create("ImageLabel")({
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				BackgroundColor3 = Color3.new(1, 1, 1),
				Size = UDim2.new(0.15, 0, 0.63, 0),
				Image = "rbxassetid://10002492897",
				ImageColor3 = Color3.new(1, 1, 1),
				ImageTransparency = 0,
				ResampleMode = Enum.ResamplerMode.Pixelated,
				ZIndex = 3,
				Parent = starFrame
			})
		end

		-- Create Types
		local raidPokemonTyping = displayData.iconData.Typing
		local raidPokemonName = displayData.iconData.Name
		for _, pokeType in _p.Pokemon:getTypes(raidPokemonTyping) do
			Create("ImageLabel")({
				BorderSizePixel = 0,
				BackgroundTransparency = 0,
				BackgroundColor3 = _p.BattleGui.typeColors[pokeType],
				Size = UDim2.new(0.355, 0, 0.598, 0),
				ImageColor3 = Color3.new(1, 1, 1),
				ZIndex = 6,
				Parent = typeFrame,

				Create("UICorner")({
					CornerRadius = UDim.new(1, 0)
				}),

				Create("TextLabel")({
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
					BackgroundColor3 = Color3.new(1, 1, 1),
					Position = UDim2.new(0.074, 0, 0.076, 0),
					Size = UDim2.new(0.845, 0, 1.0, 0),
					ZIndex = 99,
					FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
					LineHeight = 1,
					MaxVisibleGraphemes = -1,
					Text = pokeType or "Type",
					TextColor3 = Color3.new(1, 1, 1),
					TextDirection = Enum.TextDirection.Auto,
					TextScaled = true,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextTruncate = Enum.TextTruncate.None,

					Create("UITextSizeConstraint")({
						MaxTextSize = 50,
						MinTextSize = 1
					})
				})
			})
		end

		-- Create Pokemon

		-- Pokemon Icon
		local pokemon = _p.Network:get('PDS', 'getParty', 'bag')[1]
		local icon = _p.Pokemon:getIcon(pokemon.icon, pokemon.shiny)
		--icon.Size = UDim2.new(0.13, 0, 0.914, 0)
		icon.Position = UDim2.new(0.495, 0, -0.068, 0)
		icon.ScaleType = Enum.ScaleType.Fit
		icon.Parent = playerFrame.localPlayerFrame

		Create("UIAspectRatioConstraint")({
			AspectRatio = 1,
			AspectType = Enum.AspectType.FitWithinMaxSize,
			DominantAxis = Enum.DominantAxis.Width,
			Parent = icon
		})

		-- Pokemon Name
		Create("TextLabel")({
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.675, 0, 0.18, 0),
			Size = UDim2.new(0.331, 0, 0.419, 0),
			FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			LineHeight = 1,
			MaxVisibleGraphemes = -1,
			Text = pokemon.name or "Pokemon",
			TextColor3 = Color3.new(0, 0, 0),
			TextDirection = Enum.TextDirection.Auto,
			TextScaled = true,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextTruncate = Enum.TextTruncate.None,
			Parent = playerFrame.localPlayerFrame,

			Create("UITextSizeConstraint")({
				MaxTextSize = 50,
				MinTextSize = 1
			})
		})

		-- Other Player
		local isTweenPlaying = false
		local imageToTween = playerFrame.otherPlayerFrame.otherPlayerImage

		local rotationTween = TweenService:Create(imageToTween, TweenInfo.new(unpack{
			1.5,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.Out,
			-1, 
			false 
		}), {Rotation = imageToTween.Rotation + 360})

		local function startTween()
			if not isTweenPlaying then
				rotationTween:Play()
				isTweenPlaying = true
			end
		end

		RunService.RenderStepped:Connect(startTween)

		Tween(.3, "easeInOutQuad", function(a)
			holderFrame.Position = UDim2.new(-1.00+(1.164*a), 0, 0, 0)
			holderScreenGui.Parent = Utilities.gui
		end)

		-- Text Search
		task.spawn(function()
			local textToAnimate = playerFrame.otherPlayerFrame.otherPlayerText
			while true do
				for i = 1, 3 do
					textToAnimate.Text = `Searching{string.rep(".", i)}`
					task.wait(0.5)
				end
			end
		end)

		-- Time Text Handler
		task.spawn(function()
			local totalTime = 5 * 60
			while totalTime >= 0 do
				local minutes = math.floor(totalTime / 60)
				local seconds = totalTime % 60
				timeRemaining.Text = string.format("%02d:%02d", minutes, seconds)
				task.wait(1)
				totalTime = totalTime - 1

				if totalTime <= 1 then
					if guiOpen then
						return
					end
					guiOpen = true

					Tween(.3, "easeInOutQuad", function(a)
						holderFrame.Position = UDim2.new(-1.05*a, 0, 0, 0)
					end)

					holderFrame:Destroy()
					task.spawn(_p.Menu.enable, _p.Menu)
					_p.MasterControl.WalkEnabled = true

					self.isOpen = false
					guiOpen = false
				end
			end
		end)
	end

	function MaxRaid:init()

	end
	function MaxRaid:Update()

	end


	function MaxRaid:GenerateRaidDen(targ)
		local maxRaidData = _p.Network:get('PDS', 'getRaidDenData', nil, nil, targ.DenID.Value)
		if maxRaidData and maxRaidData == 'disabled' then 
			maxRaidData = {
				displayData={
					iconData = {
						Typing = '',
						IconId = '',
					},
					Tier='',
					DenName=''
				},
				Key=''
			}
		end
		Create 'StringValue' {
			Value = getTime(),
			Name = 'GenerateTime',
			Parent = targ,
		}
		Create 'StringValue' {
			Value = maxRaidData.Key,
			Name = 'Key',
			Parent = targ,
		}
		self.generatedData[maxRaidData.Key] = maxRaidData
		if maxRaidData.displayData.Tier ~= '' then
			self:maxRaidBeam(targ, maxRaidData.displayData.Tier)
		end	
	end
	function MaxRaid:UpdateRaidDen(targ, clr)
		self.generatedData[targ.Key.Value] = nil
		_p.Network:get('PDS', 'getRaidDenData', true, targ.Key.Value)
		targ.Key.Value = ''
		self:maxRaidBeam(targ)
		--_p.Network:get('PDS', 'SaveID', tonumber(targ.DenID.Value)) --// I made it into a number cuz thats what its supposed to be
		--Clears existing KeyData
		if not clr then
			local maxRaidData = _p.Network:get('PDS', 'getRaidDenData', nil, nil, targ.DenID.Value) --Need to show it's forced
			targ.Key.Value = maxRaidData.Key
			targ.GenerateTime.Value = getTime() 
			self.generatedData[maxRaidData.Key] = maxRaidData

			self:maxRaidBeam(targ)	
		end
	end

	function MaxRaid:maxRaidRewards(Tier, Caught, Pokemon, Forme, data)
		if storage.Models.Win.Value ~= 'Win' then
			return
		end
		_p.MasterControl.WalkEnabled = false		
		_p.MasterControl:Stop()
		local outcome 
		if Caught == true then
			outcome = 'Caught'
		else
			outcome = 'Defeated'
		end	
		local Itemtable,amount,icons = _p.Network:get('PDS', 'getRaidDenRewards',Tier)	
		local bg = Create 'Frame' {
			BackgroundTransparency = 0,
			BackgroundColor3 = Color3.new(0.909804, 0.164706, 0.27451),
			SizeConstraint = Enum.SizeConstraint.RelativeXY,
			Size = UDim2.new(0.745, 0, 0.847, 0),
			Position = UDim2.new(0.077, 0, 0.073, 0),
			Parent = Utilities.gui,
		}	
		local one = Create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://15016910576',
			ImageColor3 = Color3.new(0, 0, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeXY,
			Size = UDim2.new(0.384, 0, 0.142, 0),
			Position = UDim2.new(.72, 0, -0.05, 0),
			Parent = bg,
		}
		local two = Create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://15016910576',
			ImageColor3 = Color3.new(0, 0, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeXY,
			Size = UDim2.new(0.384, 0, 0.142, 0),
			Position = UDim2.new(.692, 0, -0.05, 0),
			Parent = bg,
		}
		local three = Create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://15016910576',
			ImageColor3 = Color3.new(0, 0, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeXY,
			Size = UDim2.new(0.384, 0, 0.142, 0),
			Position = UDim2.new(.54, 0, -0.05, 0),
			Parent = bg,
		}
		local Textbox = create 'TextLabel' {
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			Text = 'You '..outcome..' '..Pokemon..'!',
			TextXAlignment = Enum.TextXAlignment.Left,
			Font = Enum.Font.SourceSansBold,
			Size = UDim2.new(0.323, 0, 0.085, 0),
			Position = UDim2.new(0.663, 0, -0.015, 0),
			ZIndex = 4, Parent = bg
		}
		local X = 0.55
		for stars = 1, Tier do
			local Star = Create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://344501516',
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(.1, 0, .1, 0),
				Position = UDim2.new(X, 0, .13, 0),

				Parent = bg,
			}
			X += .08
		end
		--[[local DynamaxIcon = Create 'Frame' {
			BackgroundTransparency = 1,
			Size = UDim2.new(0.536, 0, 0.776, 0),
			Position = UDim2.new(0.463, 0, 0.211, 0),
			Parent = bg,
		}	
		Create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://14598421251',
			SizeConstraint = Enum.SizeConstraint.RelativeXY,
			ImageColor3 = Color3.new(1, 0.180392, 0.301961),
			Size = UDim2.new(0.974, 0, 0.94, 0),
			Position = UDim2.new(.068, 0, .1, 0),
			Parent = DynamaxIcon,
		}]]
		local raidPoke 
		if Forme then 
			raidPoke =_p.AnimatedSprite:new((_p.DataManager:getSprite("_FRONT", Pokemon..'-'..Forme)))
		else
			raidPoke =_p.AnimatedSprite:new((_p.DataManager:getSprite("_FRONT", Pokemon)))
		end
		raidPoke.spriteLabel.Parent = bg
		raidPoke.spriteLabel.Size = UDim2.new(.7, 0, 0.7, 0)
		raidPoke.spriteLabel.Position = UDim2.new(.035, 0, .1, 0)
		raidPoke.spriteLabel.SizeConstraint = Enum.SizeConstraint.RelativeYY
		raidPoke:Play()
		local ScrollingFrame = create 'ScrollingFrame' {
			Size = UDim2.new(.4, 0, .6, 0),
			Position = UDim2.new(.55, 0, .3, 0),
			BorderSizePixel = 0,
			BackgroundTransparency = 1.0,
			Parent = bg,
		}
		create 'UIGridLayout' {
			CellPadding = UDim2.new(0, 0, 0, 11),
			CellSize = UDim2.new(1, 0, 0, 36),
			Parent = ScrollingFrame,
		}

		spawn(function()
			for i = 1, #Itemtable do
				local UICorner = Instance.new("UICorner")
				local itemBox = create 'Frame' {
					Parent = ScrollingFrame,
					Size = UDim2.new(0.998, 0,0.141, 0),
					SizeConstraint = Enum.SizeConstraint.RelativeXX,
					BackgroundTransparency = 0.75,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				}
				UICorner.Parent = itemBox
				UICorner.CornerRadius = UDim.new(1, 0)
				ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, i*32)
				local icon = _p.Menu.bag:getItemIcon(icons[i])
				icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
				icon.Size = UDim2.new(1, 0, 1, 0)
				icon.Position = UDim2.new(0.0, 0, 0, 0)
				icon.Parent = itemBox
				Utilities.Write(Itemtable[i]) {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, .6, 0),
						Position = UDim2.new(0.12, 0, .2, 0),
						Parent = itemBox,
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
				}

				Utilities.Write('x'..amount[i]) {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, .6, 0),
						Position = UDim2.new(.95, 0, .2, 0),
						ZIndex = 5,
						Parent = itemBox,
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right,
				}				      
			end
		end)
		local UICorner = Instance.new("UICorner")
		local Done = create 'ImageButton' {
			Parent = bg,
			SizeConstraint = Enum.SizeConstraint.RelativeXY,
			Size = UDim2.new(0.266, 0, 0.072, 0),
			Position = UDim2.new(0.637, 0, 0.91, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		}
		UICorner.Parent = Done
		UICorner.CornerRadius = UDim.new(1, 0)
		local Textbox2 = create 'TextLabel' {
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(0, 0, 0),
			TextScaled = true,
			Text = 'Next!',
			TextXAlignment = Enum.TextXAlignment.Left,
			Font = Enum.Font.SourceSansBold,
			Size = UDim2.new(0.1, 0, 0.08, 0),
			Position = UDim2.new(0.73, 0, 0.905, 0),
			ZIndex = 4, Parent = bg
		}
		Done.MouseButton1Click:Connect(function ()
			Tween(.3, nil, function(a)
				bg.Position = UDim2.new(0.077, 0, -1.05*a, 0)
			end)
			bg:Destroy()
			spawn(function() _p.Menu:enable() end)
			_p.MasterControl.WalkEnabled = true
			self.isOpen = false
		end)
	end	
	function MaxRaid:Raid(encData, maxRaid, Tier, Pokemon, Forme)
		local didWin = _p.Battle:doWildBattle(encData, {
			cantRun = true,
			cantUseBalls = true,
			cantSwap = true,
			battleSceneType = 'DmaxV1',
			musicId = 86487458479915,
			genEncounter = maxRaid,
			isRaid = true
		})

		if not didWin then
			storage.Models.Win.Value = 'Lose'
			chat:say('You lost the raid battle!')
			return
		end

		storage.Models.Win.Value = 'Win'
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()

		local opt = chat:choose('Capture', 'Run')
		if opt == 1 then
			_p.Battle:doWildBattle(encData, {
				cantRun = true,
				battleSceneType = 'DmaxV1',
				genEncounter = maxRaid
			})
			self:maxRaidRewards(Tier, true, Pokemon, Forme)
		elseif opt == 2 then
			chat:say('You successfully fled!')
			_p.Network:get("PDS", "keepRaidTraits", {shiny = false, HA = false, gmax = false})
			self:maxRaidRewards(Tier, false, Pokemon, Forme)
		end
	end




	function MaxRaid:OnDenClicked(pos, targ, encData)
		if self.isOpen then
			return
		end
		self.isOpen = true
		_p.MasterControl.WalkEnabled = false		
		_p.MasterControl:Stop()
		_p.Hoverboard:unequip(true)
		spawn(function() _p.MasterControl:LookAt(pos) end)

		local denData = self.generatedData[targ.Key.Value]
		local options = {}
		local datacheck = _p.Network:get('PDS', 'getRaidDenData', nil, nil, targ.DenID.Value)
		table.insert(options, 'View')
		if self.debugEnabled then 
			table.insert(options, 'Debug')
		elseif targ.Key.Value == '' and _p.Network:get('PDS', 'hasBagItem', 'wishingpiece', 1) then
			table.insert(options, 'Wishing Piece')
		end
		table.insert(options, 'Back')

		--Generate Buttons
		local opt = options[_p.NPCChat:choose(unpack(options))] 
		if opt == 'View' then
			if targ.Key.Value == '' or not denData then
				chat:say('There\'s nothing in this den.')
				_p.MasterControl.WalkEnabled = true
				self.isOpen = false
			else
				self.isOpen = true
				self:generateMaxInterface(denData, targ, encData)--generateMaxInterface(denData, targ)
			end
		elseif opt == 'Back' then
			self.isOpen = false
		elseif opt == 'Wishing Piece' or opt == 'Debug' then
			if chat:say('There doesn\'t seem to be anything in the den...', '[y/n]Want to throw the Wishing Piece in?') and datacheck.Key then
				chat:say('You threw in a Wishing Piece.')
				_p.Network:get("PDS", "removeItem", "Wishing Piece")
				self:UpdateRaidDen(targ)			
				self.isOpen = false
			end
		end
		_p.MasterControl.WalkEnabled = true
	end
	return MaxRaid end