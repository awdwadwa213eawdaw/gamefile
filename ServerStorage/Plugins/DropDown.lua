--SynapseX Decompiler

return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local write = Utilities.Write
	local ContextActionService = game:GetService("ContextActionService")
	local dropdown
	dropdown = Utilities.class({}, function(parent, options, hue)
		local self = {
			busy = false,
			Enabled = true,
			options = options,
			value = options[1],
			valueIndex = 1,
			changed = Utilities.Signal()
		}
		local guiContainer = Utilities.simulatedCoreGui
		self.mainButton = create("ImageButton")({
			AutoButtonColor = false,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromHSV(hue, 0.821, 0.725),
			ZIndex = 5,
			Parent = parent,
			Activated = function(inputObject)
				if not self.Enabled then return end
				if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
					self.busy = true
					do
						local mouseTrap = create("ImageButton")({
							AutoButtonColor = false,
							BorderSizePixel = 0,
							BackgroundColor3 = Color3.new(0, 0, 0),
							BackgroundTransparency = 0.6,
							Size = UDim2.new(1, 0, 1, 36),
							Position = UDim2.new(0, 0, 0, -36),
							ZIndex = 13,
							Parent = guiContainer
						})
						local sbw = Utilities.gui.AbsoluteSize.Y * 0.03
						local mainSize = self.mainButton.AbsoluteSize
						local mainPosition = self.mainButton.AbsolutePosition
						local list = create("ScrollingFrame")({
							BorderColor3 = Color3.fromHSV(hue, 0.491, 0.208),
							BorderSizePixel = 2,
							Name = "Scroller",
							BackgroundColor3 = Color3.fromHSV(hue, 0.822, 0.73),
							TopImage = "rbxassetid://1028868491",
							MidImage = "rbxassetid://1028874299",
							BottomImage = "rbxassetid://1028873474",
							ScrollBarThickness = sbw,
							Size = UDim2.new(0, mainSize.X, 0.3, 0),
							Position = UDim2.new(0, mainPosition.X, 0, mainPosition.Y),
							ZIndex = 14,
							Parent = guiContainer
						})
						self.list = list
						local container = create("Frame")({
							BackgroundTransparency = 1,
							Name = "Container",
							SizeConstraint = Enum.SizeConstraint.RelativeXX,
							Size = UDim2.new(1, -sbw, 1, -sbw),
							Parent = list
						})
						list.CanvasSize = UDim2.new(0, mainSize.X - 1, 0, mainSize.Y * #self.options)
						if mainSize.Y * #self.options < list.AbsoluteSize.Y then
							list.Size = list.CanvasSize
						end
						if list.AbsolutePosition.Y + list.AbsoluteSize.Y > Utilities.gui.AbsoluteSize.Y then
							list.Position = UDim2.new(0, mainPosition.X, 0, Utilities.gui.AbsoluteSize.Y - list.AbsoluteSize.Y)
						end
						local closeFunction
						local selectable = {}
						for i, value in pairs(self.options) do
							do
								local isCurrent = self.value == value
								local button = create("ImageButton")({
									AutoButtonColor = false,
									BorderSizePixel = 0,
									Name = tostring(i),
									BackgroundColor3 = isCurrent and Color3.fromHSV(hue, 0.9, 0.5) or Color3.fromHSV(hue, 0.822, 0.73),
									Size = UDim2.new(1, 0, 0, mainSize.Y),
									Position = UDim2.new(0, 0, 0, mainSize.Y * (i - 1)),
									ZIndex = 15,
									Parent = container,
									Activated = function(inputObject)
										if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
											closeFunction()
											self.value = value
											self.valueIndex = i
											self:setValueText(value)
											self.changed:fire(value, i)
										end
									end
								})
								write(value)({
									Frame = create("Frame")({
										BackgroundTransparency = 1,
										Size = UDim2.new(1, 0, 0.5, 0),
										Position = UDim2.new(0, 0, 0.25, 0),
										ZIndex = 16,
										Parent = button
									}),
									Scaled = true
								})
								if isCurrent then
									table.insert(selectable, 1, button)
								else
									selectable[i] = button
								end
							end
						end
						self.buttons = selectable
						local selectionAdornment = {}
						function selectionAdornment:Show()
							self:Select(game:GetService("GuiService").SelectedObject)
						end
						function selectionAdornment:Hide()
						end
						function selectionAdornment:Select(button)
							for _, otherButton in pairs(selectable) do
								otherButton.BackgroundColor3 = Color3.fromHSV(hue, 0.822, 0.73)
							end
							button.BackgroundColor3 = Color3.fromHSV(hue, 0.9, 0.5)
						end
						function selectionAdornment:Destroy()
						end
						function closeFunction()
							list:Destroy()
							mouseTrap:Destroy()
							self.busy = false
						end
						mouseTrap.MouseButton1Click:Connect(closeFunction)
					end
				end
			end
		})
		self.valueContainer = create("Frame")({
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0.5, 0),
			Position = UDim2.new(0, 0, 0.25, 0),
			ZIndex = 6,
			Parent = self.mainButton
		})
		dropdown.setValueText(self, self.value)
		return self
	end)
	function dropdown:setValueText(text)
		self.valueContainer:ClearAllChildren()
		write(text)({
			Frame = self.valueContainer,
			Scaled = true
		})
	end
	function dropdown:setSize(size)
		self.mainButton.Size = size
	end
	function dropdown:setPosition(position)
		self.mainButton.Position = position
	end
	function dropdown:setValue(index)
		self.value = self.options[index]
		self.valueIndex = index
		self:setValueText(self.value)
	end
	function dropdown:setOptions(newOptions, selectedIndex)
		self.options = newOptions
		self.value = newOptions[selectedIndex]
		self.valueIndex = selectedIndex
		self:setValueText(self.value)
	end
	function dropdown:SetHue(hue)
		for i=1, self.buttons do
			self.buttons[i].BackgroundColor3 = self.value == tonumber(self.buttons[i]) and Color3.fromHSV(hue, 0.9, 0.5) or Color3.fromHSV(hue, 0.822, 0.73)
		end
		self.list.BorderColor3 = Color3.fromHSV(hue, 0.491, 0.208)
		self.list.BackgroundColor3 = Color3.fromHSV(hue, 0.822, 0.73)
	end
	function dropdown:destroy()
		self.mainButton:Destroy()
	end
	return dropdown
end