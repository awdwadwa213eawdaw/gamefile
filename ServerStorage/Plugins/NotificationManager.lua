
return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local NotificationManager = {}
	local activeSlots = {}
	local function sortSlots()
		table.sort(activeSlots, function(a, b)
			if a.priority ~= b.priority then
				return a.priority < b.priority
			end
			return a.createdAt < b.createdAt
		end)
		local posY = 0.99
		for _, slot in ipairs(activeSlots) do
			local position = UDim2.new(1, 0, posY, 0)
			posY = posY - slot.height - 0.01
			if slot.placed then
				Utilities.spTween(slot.gui, "Position", position, 0.3, "easeOutCubic")
			else
				slot.gui.Position = position
				slot.placed = true
			end
		end
	end
	local NotificationSlot = Utilities.class({priority = 99, placed = false}, function(self)
		self.createdAt = tick()
		self.gui = create("Frame")({
			BackgroundTransparency = 1,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(self.width, 0, self.height, 0),
			AnchorPoint = Vector2.new(1, 1),
			Parent = Utilities.frontGui
		})
		return self
	end)
	function NotificationSlot:Destroy()
		if self.gui then
			self.gui:Destroy()
			self.gui = nil
		end
		for i = 1, #activeSlots do
			if activeSlots[i] == self then
				table.remove(activeSlots, i)
				break
			end
		end
		sortSlots()
	end
	function NotificationManager:ReserveSlot(width, height, priority)
		local slot = NotificationSlot:new({
			width = width,
			height = height,
			priority = priority
		})
		activeSlots[#activeSlots + 1] = slot
		sortSlots()
		return slot
	end
	return NotificationManager
end
