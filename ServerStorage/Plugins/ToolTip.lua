-- Decompiled with the Synapse X Luau decompiler.

return function(_p)
	local Utilities = _p.Utilities
	local Create = Utilities.Create
	local TextService = game:GetService("TextService")
	local GuiInset = select(1, game:GetService("GuiService"):GetGuiInset())
	local tooltip = {}
	local ContextActionService = game:GetService("ContextActionService")
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local hintBox = Create("ImageButton")({
		BackgroundTransparency = 1, 
		Size = UDim2.new(1, 0, 1, GuiInset.Y), 
		Position = UDim2.fromOffset(0, -GuiInset.Y), 
		ZIndex = 99
	})
	function tooltip.createToolTipFromButton(tooltip, btn, txt)

		local madeUi = false
		local gui = nil
		local txtLabel = nil
		local UiCorner = nil
		local Fns = nil
		local function HookFn(Fn)
			if Fns then
				for i, v in ipairs(Fns) do
					v:Disconnect()
				end
			end
			Fns = Fn
		end
		local showingTip = false
		local function DoGui(position)
			if madeUi then
				return
			end
			madeUi = true
			if not gui then
				gui = Create("Frame")({
					BackgroundTransparency = 1, 
					BorderSizePixel = 0, 
					BackgroundColor3 = Color3.new(0, 0, 0), 
					ZIndex = 98
				})
				txtLabel = Create("TextLabel")({
					BackgroundTransparency = 1, 
					TextColor3 = Color3.new(1, 1, 1), 
					TextXAlignment = Enum.TextXAlignment.Left, 
					TextYAlignment = Enum.TextYAlignment.Top, 
					Font = Enum.Font.GothamSemibold, 
					RichText = true, 
					TextWrap = true, 
					Text = txt, 
					TextTransparency = 1, 
					ZIndex = 99, 
					Parent = gui
				})
				UiCorner = Create("UICorner")({
					Parent = gui
				})
			end
			local AbsoluteSize = Utilities.frontGui.AbsoluteSize
			local scale
			if Utilities.isPhone() then
				scale = 32
			else
				scale = 48
			end
			local txtSize = math.floor(AbsoluteSize.Y / scale)
			local pos = math.ceil(txtSize * 0.7)
			txtLabel.TextSize = txtSize
			gui.Parent = Utilities.frontGui
			txtLabel.Size = UDim2.fromOffset(math.floor(AbsoluteSize.X * 0.4), AbsoluteSize.Y)
			local TextBounds = txtLabel.TextBounds
			local X = TextBounds.X + 1
			local Y = TextBounds.Y + 1
			txtLabel.Size = UDim2.fromOffset(X, Y)
			txtLabel.Position = UDim2.fromOffset(pos, pos)
			local d = X + 2 * pos
			local d2 = Y + 2 * pos
			local X2 = position.X
			local Y2 = position.Y
			if AbsoluteSize.X < X2 + d then
				X2 = AbsoluteSize.X - d - 4
			end
			if AbsoluteSize.Y < Y2 + d2 then
				Y2 = AbsoluteSize.Y - d2 - 4
			end
			gui.Size = UDim2.fromOffset(d, d2)
			gui.Position = UDim2.fromOffset(X2, Y2)
			UiCorner.CornerRadius = UDim.new(0, math.ceil(0.5 * pos))
			Utilities.spTween(gui, "BackgroundTransparency", 0.15, 0.5, "easeOutQuad")
			Utilities.spTween(txtLabel, "TextTransparency", 0, 0.5, "easeOutQuad")
		end
		local function unshow()
			if not gui or not madeUi then
				return
			end
			madeUi = false
			HookFn(nil)
			if showingTip then
				showingTip = false
				ContextActionService:UnbindAction("loomToolTipAbsorbGamepad")
			end
			Utilities.spTween(gui, "BackgroundTransparency", 1, 0.5, "easeOutQuad", nil, function()
				gui.Parent = nil
			end)
			Utilities.spTween(txtLabel, "TextTransparency", 1, 0.5, "easeOutQuad")
		end
		btn.InputBegan:Connect(function(Input)
			if Input.UserInputType ~= Enum.UserInputType.MouseMovement then
				return
			end
			DoGui(Vector2.new(Input.Position.X, Input.Position.Y))
			if not Fns then
				HookFn({ 
					RunService.RenderStepped:Connect(function()
						local AbsoluteSize = btn.AbsoluteSize
						local AbsolutePosition = btn.AbsolutePosition
						local MousePos = UserInputService:GetMouseLocation() - GuiInset
						if MousePos.X < AbsolutePosition.X or MousePos.Y < AbsolutePosition.Y or AbsolutePosition.X + AbsoluteSize.X < MousePos.X or AbsolutePosition.Y + AbsoluteSize.Y < MousePos.Y then
							unshow()
						end
					end) 
				})
			end
		end)
		btn.Activated:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.Touch or Input.UserInputType == _p.activeGamepad then
				if Input.KeyCode == Enum.KeyCode.ButtonA and madeUi then
					unshow()
					return
				end
				hintBox.Parent = Utilities.simulatedCoreGui
				DoGui(btn.AbsolutePosition)
				HookFn({ 
					UserInputService.InputBegan:Connect(function(input)
						local UserInputType = input.UserInputType
						if UserInputType == Enum.UserInputType.Touch or (UserInputType == Enum.UserInputType.Keyboard or UserInputType == Enum.UserInputType.MouseButton1 or UserInputType == Enum.UserInputType.MouseButton2) then
							hintBox.Parent = nil
							unshow()
						end
					end) 
				})
				if not showingTip then
					showingTip = true
				end
			end
		end)
	end
	tooltip.create = tooltip.createToolTipFromButton
	return tooltip
end
