--SynapseX Decompiler

return function(_p)
	local Utilities = _p.Utilities
	local mouse = _p.player:GetMouse()
	local UserInputService = game:GetService("UserInputService")
	local currentlyDragging
	local dragger = Utilities.class({
		clickEnabled = false,
		dragging = false,
		className = "Dragger"
	}, function(self)
		if type(self) == "userdata" then
			self = {gui = self}
		end
		local guiObject = self.gui
		self.onDragBegin = Utilities.Signal()
		self.onDragMove = Utilities.Signal()
		self.onDragEnd = Utilities.Signal()
		self.onClick = Utilities.Signal()
		if guiObject:IsA("GuiObject") then
			guiObject.InputBegan:Connect(function(inputObject)
				if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch and inputObject.UserInputState == Enum.UserInputState.Begin then
					self:beginDrag()
				end
			end)
		end
		return self
	end)
	function dragger:beginDrag()
		if currentlyDragging then
			currentlyDragging:endDrag()
		end
		currentlyDragging = self
		self.endCn = UserInputService.InputEnded:Connect(function(inputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
				self:endDrag()
			end
		end)
		self.dragging = true
		local mouseStartX, mouseStartY = mouse.X, mouse.Y
		self.dragStartPosition = Vector2.new(mouseStartX, mouseStartY)
		local threshold
		local brokenThreshold = false
		local clickEnabled = self.clickEnabled or false
		if clickEnabled then
			self.brokenThreshold = false
			threshold = self.clickThresholdExact or Utilities.gui.AbsoluteSize.Y * (self.clickThreshold or 0.03)
		end
		self.moveCn = mouse.Move:Connect(function()
			local offset = Vector2.new(mouse.X - mouseStartX, mouse.Y - mouseStartY)
			if clickEnabled and not brokenThreshold then
				if offset.magnitude < threshold then
					return
				end
				brokenThreshold = true
				self.brokenThreshold = true
				self.onDragBegin:fire(offset)
				return
			end
			self.onDragMove:fire(offset)
		end)
		if not clickEnabled then
			self.brokenThreshold = true
			self.onDragBegin:fire(Vector2.new())
		end
	end
	function dragger:endDrag()
		if self.endCn then
			self.endCn:Disconnect()
			self.endCn = nil
		end
		if self.moveCn then
			self.moveCn:Disconnect()
			self.moveCn = nil
		end
		if currentlyDragging == self then
			currentlyDragging = nil
		end
		if not self.dragging then
			return
		end
		if self.clickEnabled and not self.brokenThreshold then
			self.onClick:fire()
		end
		self.dragging = false
		self.onDragEnd:fire()
	end
	return dragger
end
