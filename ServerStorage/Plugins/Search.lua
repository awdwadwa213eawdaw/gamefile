return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local write = Utilities.Write

	local Search = Utilities.class({}, function(config)
		local parent = config.parent
		local position = config.position or UDim2.new(0.35, 0, 0.14, 0)
		local size = config.size or UDim2.new(0.6, 0, 0.05, 0)
		local placeholder = config.placeholder or "Search"
		local zIndex = config.zIndex or 4
		local backgroundColor = config.backgroundColor or Color3.new(.4, .4, .4)

		local self = {
			searchText = "",
			placeholder = placeholder,
			gui = nil,
			searchBox = nil,
			searchPlaceholder = nil,
			searchIcon = nil,
			changed = Utilities.Signal(),
			cleared = Utilities.Signal(),
			focused = Utilities.Signal(),
			unfocused = Utilities.Signal(),
			Enabled = true,
			_debounceTime = config.debounceTime or 0, 
			_debounceThread = nil
		}

		local searchFrame = _p.RoundedFrame:new {
			BackgroundColor3 = backgroundColor,
			Size = size,
			Position = position,
			ZIndex = zIndex,
			Parent = parent,
		}

		local searchIcon = create 'ImageLabel' {
			Name = 'SearchIcon',
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://11496279085',
			ImageColor3 = Color3.new(1, 1, 1),
			ScaleType = Enum.ScaleType.Fit,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(0.8, 0, 0.8, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0.05, 0, 0.5, 0),
			ZIndex = zIndex + 2,
			Parent = searchFrame.gui,
		}

		local searchPlaceholder = create 'Frame' {
			Name = 'SearchPlaceholder',
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.8, 0),
			Position = UDim2.new(0.5, 0, 0.15, 0),
			ZIndex = zIndex + 2,
			Parent = searchFrame.gui,
		}

		write(placeholder) {
			Frame = searchPlaceholder,
			Scaled = true,
			Color = Color3.new(0.8, 0.8, 0.8),
			TextXAlignment = Enum.TextXAlignment.Center,
		}

		local searchBox = create 'TextBox' {
			Name = 'SearchBox',
			BackgroundTransparency = 1.0,
			BorderSizePixel = 0,
			Size = UDim2.new(0.9, 0, 1.0, 0),
			Position = UDim2.new(0.05, 0, 0.0, 0),
			ZIndex = zIndex + 1,
			Parent = searchFrame.gui,
			Font = Enum.Font.GothamBold,
			FontSize = (Utilities.isPhone() and Enum.FontSize.Size8 or Enum.FontSize.Size14),
			TextScaled = true,
			TextColor3 = Color3.new(1, 1, 1),
			Text = "",
			TextXAlignment = Enum.TextXAlignment.Center,
			ClearTextOnFocus = false,
		}

		self.gui = searchFrame
		self.searchBox = searchBox
		self.searchPlaceholder = searchPlaceholder
		self.searchIcon = searchIcon

		searchBox.Changed:Connect(function(property)
			if property == "Text" then
				self.searchText = searchBox.Text

				if searchBox.Text == "" then
					searchPlaceholder.Visible = true
					self.cleared:fire()
				else
					searchPlaceholder.Visible = false
				end

				if self._debounceTime > 0 then
					if self._debounceThread then
						task.cancel(self._debounceThread)
					end
					self._debounceThread = task.delay(self._debounceTime, function()
						self.changed:fire(searchBox.Text)
						self._debounceThread = nil
					end)
				else
					self.changed:fire(searchBox.Text)
				end
			end
		end)

		searchBox.Focused:Connect(function()
			if searchBox.Text == "" then
				searchPlaceholder.Visible = false
			end
			self.focused:fire()
		end)

		searchBox.FocusLost:Connect(function()
			if searchBox.Text == "" then
				searchPlaceholder.Visible = true
			end
			self.unfocused:fire()
		end)

		function self:getText()
			return self.searchText
		end

		function self:setText(text)
			self.searchBox.Text = text
			self.searchText = text
			if text == "" then
				self.searchPlaceholder.Visible = true
			else
				self.searchPlaceholder.Visible = false
			end
		end

		function self:clear()
			self:setText("")
		end

		function self:setPlaceholder(newPlaceholder)
			self.placeholder = newPlaceholder
			self.searchPlaceholder:ClearAllChildren()
			write(newPlaceholder) {
				Frame = self.searchPlaceholder,
				Scaled = true,
				Color = Color3.new(0.8, 0.8, 0.8),
				TextXAlignment = Enum.TextXAlignment.Center,
			}
		end

		function self:destroy()
			if self._debounceThread then
				task.cancel(self._debounceThread)
			end
			self.gui:destroy()
		end

		function self:setEnabled(enabled)
			self.Enabled = enabled
			self.searchBox.TextEditable = enabled
			self.gui.gui.Visible = enabled
		end

		function self:setVisible(visible)
			self.gui.gui.Visible = visible
		end

		function self:focus()
			self.searchBox:CaptureFocus()
		end

		function self:releaseFocus()
			self.searchBox:ReleaseFocus()
		end

		return self
	end)

	return Search
end