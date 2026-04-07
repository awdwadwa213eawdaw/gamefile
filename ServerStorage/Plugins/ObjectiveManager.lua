
return function(_p)
	local Utilities = _p.Utilities
	local ObjectiveManager = {
		notifPreference = 0, 
		enabled = false, 
		objectiveNewMark = 0, 
		disabledBy = {
			gameStart = true
		}
	}
	local disabledForFix = false
	function ObjectiveManager:SetNotificationPreference(notifPreference, set)
		if disabledForFix then return end
		ObjectiveManager.notifPreference = notifPreference
		if notifPreference == 0 then
			ObjectiveManager:DisplayObjective()
			return
		end
		ObjectiveManager:CloseObjective()
	end
	function ObjectiveManager:UpdateObjective(objective, mark)
		if disabledForFix then return end
		ObjectiveManager.objective = objective
		ObjectiveManager.objectiveNewMark = mark
		if not ObjectiveManager.enabled then
			ObjectiveManager:CloseObjective()
			return
		end
		if ObjectiveManager.notifPreference == 2 then
			return
		end
		ObjectiveManager:DisplayObjective()
	end
	local Create = Utilities.Create
	local TextService = game:GetService("TextService")
	function ObjectiveManager:DisplayObjective()
		if disabledForFix then return end
		if not ObjectiveManager.objective or _p.context ~= "adventure" then
			return
		end
		--ObjectiveManager.objectiveNewMark = (ObjectiveManager.objectiveNewMark or 1)
		local activeGui = ObjectiveManager.activeGui
		if not activeGui then
			local aGui = {}
			local BackRF = _p.RoundedFrame:new({
				Button = true, 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				AnchorPoint = Vector2.new(1, 0)
			})
			--BackRF.gui.Visible = false
			aGui.container = BackRF
			aGui.titleLabel = Create("TextLabel")({
				BackgroundTransparency = 1, 
				Font = Enum.Font.GothamBold, 
				TextYAlignment = Enum.TextYAlignment.Top, 
				ZIndex = 2, 
				Parent = BackRF.gui
			})
			aGui.objectiveLabel = Create("TextLabel")({
				BackgroundTransparency = 1, 
				Font = Enum.Font.Gotham, 
				TextWrapped = true, 
				TextXAlignment = Enum.TextXAlignment.Left, 
				TextYAlignment = Enum.TextYAlignment.Top, 
				TextColor3 = Color3.new(0, 0, 0), 
				ZIndex = 2, 
				Parent = BackRF.gui
			})
			if not _p.IsTenFootInterface and not Utilities.isTouchDevice() then
				local close = {
					BackgroundTransparency = 1, 
					Image = "", 
					AnchorPoint = Vector2.new(1, 0), 
					ZIndex = 3, 
					Parent = BackRF.gui,
					Create("TextLabel")({
						BackgroundTransparency = 1, 
						Size = UDim2.new(1.4, 0, 1.4, 0), 
						AnchorPoint = Vector2.new(0.5, 0.5), 
						Position = UDim2.new(0.5, 0, 0.5, 0), 
						Rotation = 45, 
						Font = Enum.Font.Gotham, 
						Text = "+", 
						TextScaled = true, 
						TextColor3 = Color3.new(0, 0, 0), 
						ZIndex = 4
					})
				}
				function close.MouseButton1Click()
					ObjectiveManager:CloseObjective()
				end
				aGui.closeButton = Create("ImageButton")(close)
			end
			local dragger_info = {
				gui = BackRF.gui, 
				clickEnabled = true
			}
			local cThreshold
			if Utilities.isPhone() then
				cThreshold = 2
			else
				cThreshold = 3
			end
			dragger_info.clickThresholdExact = cThreshold
			local Dragger = _p.Dragger:new(dragger_info)
			local Dragging = false
			local num = nil
			local num2 = nil
			local num3 = nil
			Dragger.onDragBegin:connect(function(p9)
				if Dragging then
					Dragger:endDrag()
					return
				end
				num = BackRF.gui.Position.X.Offset - 1 - BackRF.CornerRadius
				num2 = nil
				num3 = nil
				Dragging = true
			end)
			local num4 = nil
			Dragger.onDragMove:connect(function(pos)
				if not Dragging then
					return
				end
				BackRF.Position = UDim2.new(1, BackRF.CornerRadius + 1 + math.max(0, pos.X + num), 0, 0)
				local tic = tick()
				if num3 then
					num2 = (pos.X - num4) / (tic - num3)
				end
				num3 = tic
				num4 = pos.X
			end)
			Dragger.onDragEnd:connect(function()
				if not Dragging then
					return
				end
				if num2 and tick() - num3 < 0.041666666666666664 and num2 / Utilities.gui.AbsoluteSize.Y > 0.5 then
					if ObjectiveManager.activeGui == activeGui then
						ObjectiveManager.activeGui = nil
					end
					local x_offset = BackRF.Size.X.Offset + 1
					Utilities.pTween(BackRF.gui, "Position", UDim2.new(1, x_offset, 0, 0), math.abs(BackRF.Position.X.Offset - x_offset) / num2)
					ObjectiveManager:_DisposeGui(aGui)
					return
				end
				local rad = BackRF.CornerRadius + 1
				if num2 and num2 / Utilities.gui.AbsoluteSize.Y < -0.5 then
					Utilities.pTween(BackRF.gui, "Position", UDim2.new(1, rad, 0, 0), math.abs(BackRF.Position.X.Offset - rad) / num2)
				else
					Utilities.pTween(BackRF.gui, "Position", UDim2.new(1, rad, 0, 0), 0.6, "easeInOutQuad")
				end
				Dragging = false
			end)
			Dragger.onClick:connect(function()
				ObjectiveManager:ViewObjectiveDetails()
			end)
			aGui.dragger = Dragger
			ObjectiveManager.activeGui = aGui
			activeGui = aGui
		end
		local obj_2 = ObjectiveManager.objective[1]
		local nodisplay = true
		local objectiveNewMark = ObjectiveManager.objectiveNewMark
		local function Size(new)
			local size = nil
			local AbsoluteSize = Utilities.gui.AbsoluteSize
			local max_num = math.max(2, math.floor(AbsoluteSize.Y * 0.01 + 0.5))
			local max_num2 = math.max(8, math.floor(AbsoluteSize.Y * 0.02 + 0.5))
			local max_num3 = math.max(math.floor(0.25 * AbsoluteSize.Y + 0.5), math.floor(0.15 * AbsoluteSize.X + 0.5))
			local min_num = math.min(max_num3, math.floor(TextService:GetTextSize("Main Objective", max_num2, Enum.Font.GothamBold, Vector2.new(max_num3, max_num2)).X * 1.4 + 0.5))
			local TextSize = TextService:GetTextSize(obj_2, max_num2, Enum.Font.Gotham, Vector2.new(max_num3, max_num2 * 5))
			local clamp_num = math.clamp(TextSize.X, min_num, max_num3)
			local floor_num = math.floor(TextSize.Y / max_num2 + 0.5)
			if floor_num > 3 then
				local floor_num2 = math.floor(max_num3 * 1.2 + 0.5)
				local TextSize2 = TextService:GetTextSize(obj_2, max_num2, Enum.Font.Gotham, Vector2.new(floor_num2, max_num2 * 5))
				clamp_num = math.clamp(TextSize2.X, min_num, floor_num2)
				floor_num = math.floor(TextSize2.Y / max_num2 + 0.5)
				if floor_num > 3 then
					floor_num = 3
				end
			end

			local floor_num2 = math.floor(0.015 * AbsoluteSize.Y + 0.5)
			activeGui.container.CornerRadius = floor_num2
			local size2 = UDim2.new(0, clamp_num + 3 * max_num + floor_num2 + 1, 0, max_num2 * (floor_num + 1) + max_num * 2.5)
			if nodisplay or not new then
				Utilities.spTween(activeGui.container.gui, "Size", size2, 0.3, "easeOutQuad")
			else
				activeGui.container.Size = size2
			end
			activeGui.container.Position = UDim2.new(1, floor_num2 + 1, 0, 0)
			activeGui.titleLabel.Text = "Main Objective"
			activeGui.titleLabel.TextColor3 = Color3.new(0.9, 0, 0)
			if new then
				if objectiveNewMark > 0 then
					local texts = ({ "New Objective", "Objective Updated" })[objectiveNewMark]
					activeGui.titleLabel.Text = texts
					activeGui.titleLabel.TextColor3 = Color3.new(0.9, 0, 0)
					delay(10, function()
						if obj_2.activeGui == activeGui and activeGui.titleLabel.Parent and activeGui.titleLabel.Text == texts then
							if obj_2.notifPreference == 1 then
								obj_2:CloseObjective()
								return
							end
							Utilities.pTween(activeGui.titleLabel, "TextColor3", Color3.new(0.9, 0, 0), 0.3, "easeOutQuad")
							activeGui.titleLabel.Text = "Main Objective"
						end
					end)
				elseif ObjectiveManager.notifPreference == 1 then
					delay(10, function()
						if ObjectiveManager.activeGui == activeGui and obj_2.notifPreference == 1 then
							ObjectiveManager:CloseObjective()
						end
					end)
				end
			end
			activeGui.titleLabel.TextSize = max_num2
			activeGui.titleLabel.Size = UDim2.new(1, -floor_num2, 0, max_num2)
			activeGui.titleLabel.Position = UDim2.new(0, 0, 0, max_num)
			activeGui.objectiveLabel.Text = obj_2
			activeGui.objectiveLabel.TextSize = max_num2
			activeGui.objectiveLabel.Size = UDim2.new(0, clamp_num + 1, 0, max_num2 * floor_num + 1)
			activeGui.objectiveLabel.Position = UDim2.new(0, max_num * 1.5, 0, max_num * 1.5 + max_num2)
			if activeGui.closeButton then
				activeGui.closeButton.Size = UDim2.new(0, max_num2, 0, max_num2)
				activeGui.closeButton.Position = UDim2.new(1, -floor_num2 - max_num, 0, max_num)
			end
			size = (size2.Y.Offset + 10) / AbsoluteSize.Y
			local notif = _p.NotificationManager:ReserveSlot(0, size, -99)
			notif.gui.Parent = Utilities.backGui
			activeGui.container.Parent = notif.gui
			activeGui.notif = notif
		end
		Size(true)
		if activeGui.sizeCn then
			activeGui.sizeCn:Disconnect()
		end
		local oldsize = Utilities.gui.AbsoluteSize
		activeGui.sizeCn = Utilities.guiSizeChanged:Connect(function()
			local currentsize = Utilities.gui.AbsoluteSize
			wait(0.6)
			if oldsize == currentsize then
				Size(false)
			else
				oldsize = currentsize
			end
		end)
		--if not nodisplay then
		--	Utilities.spTween(activeGui.container.gui, "AnchorPoint", Vector2.new(1, 0), 0.3, "easeOutQuad")
		--end
	end
	function ObjectiveManager:CloseObjective()
		if disabledForFix then return end
		local activeGui = ObjectiveManager.activeGui
		if activeGui then
			if not activeGui.container.gui.Visible then
				ObjectiveManager:_DisposeGui(activeGui)
				return
			end
		else
			return
		end
		Utilities.spTween(activeGui.container.gui, "AnchorPoint", Vector2.new(0, 0), 0.3, "easeOutQuad", nil, function()
			ObjectiveManager:_DisposeGui(activeGui)
		end)
	end
	function ObjectiveManager:ClearObjective()
		if disabledForFix then return end
		ObjectiveManager.objective = nil
		ObjectiveManager.objectiveNewMark = 0
		ObjectiveManager:CloseObjective()
	end
	function ObjectiveManager:ViewObjectiveDetails()
		if disabledForFix then return end
		local objective = nil
		pcall(function()
			objective = ObjectiveManager.objective[2] or ObjectiveManager.objective[1]
		end)
		if not objective then
			return
		end
		local simulatedCoreGui = Utilities.simulatedCoreGui
		local AbsoluteSize = simulatedCoreGui.AbsoluteSize
		local num_max = math.max(2, math.floor(AbsoluteSize.Y * 0.02 + 0.5))
		local num_floor = math.floor(AbsoluteSize.Y * 0.035 + 0.5)
		local num2_floor = math.floor(num_floor * 1.2 + 0.5)
		local num3_floor = math.floor(AbsoluteSize.Y * 0.8)
		local TextSize = TextService:GetTextSize(objective, num_floor, Enum.Font.Gotham, Vector2.new(num3_floor, num_floor * 8))
		local Objective_background = _p.RoundedFrame:new({
			--CornerRadiusConstraint = _p.RoundedFrame.CORNER_RADIUS_CONSTRAINT.SCREEN, 
			CornerRadius = Utilities.gui.AbsoluteSize.Y * .03, 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			SizeConstraint = Enum.SizeConstraint.RelativeYY, 
			Size = UDim2.new(0, 2 * num_max + num3_floor, 0, 2.5 * num_max + TextSize.Y + num2_floor), 
			AnchorPoint = Vector2.new(0.5, 0.5), 
			Position = UDim2.new(0.5, 0, 0.5, 0), 
			ZIndex = 12, 
			Parent = simulatedCoreGui
		})
		local img = Create("ImageButton")({
			BorderSizePixel = 0, 
			AutoButtonColor = false, 
			Image = "", 
			BackgroundColor3 = Color3.new(0, 0, 0), 
			Size = UDim2.new(1, 0, 1, 0), 
			ZIndex = 11, 
			Parent = Utilities.getOutsetContainer(simulatedCoreGui)
		})
		local title = Create("TextLabel")({
			BackgroundTransparency = 1, 
			Size = UDim2.new(1, 0, 0, num2_floor), 
			Position = UDim2.new(0, num_max, 0, num_max), 
			Font = Enum.Font.SourceSansSemibold, 
			Text = "Main Objective", 
			TextSize = num2_floor, 
			TextColor3 = Color3.new(0.9, 0, 0), 
			ZIndex = 13, 
			Parent = Objective_background.gui
		})
		local objective_holder = Create("TextLabel")({
			BackgroundTransparency = 1, 
			Size = UDim2.new(0, TextSize.X + 1, 0, TextSize.Y + 1), 
			Position = UDim2.new(0, num_max, 0, num_max * 1.5 + num2_floor), 
			Font = Enum.Font.Gotham, 
			Text = objective, 
			TextSize = num_floor, 
			TextColor3 = Color3.new(0, 0, 0), 
			TextWrapped = true, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			TextYAlignment = Enum.TextYAlignment.Top, 
			ZIndex = 13, 
			Parent = Objective_background.gui
		})
		Utilities.Tween(0.5, "easeOutCubic", function(a)
			img.BackgroundTransparency = 1 - 0.3 * a
			Objective_background.BackgroundTransparency = 1 - a
			title.TextTransparency = 1 - a
			objective_holder.TextTransparency = 1 - a
		end)
		local closing = false
		img.MouseButton1Click:Connect(function()
			if closing then
				return
			end
			closing = true
			Utilities.Tween(0.5, "easeOutCubic", function(a)
				img.BackgroundTransparency = 0.7 + 0.3 * a
				Objective_background.BackgroundTransparency = a
				title.TextTransparency = a
				objective_holder.TextTransparency = a
			end)
			Objective_background:Destroy()
			img:Destroy()
		end)
	end
	function ObjectiveManager:_DisposeGui(active)
		if disabledForFix then return end
		--local active = ObjectiveManager.activeGui
		--local active = yes.activeGui
		if active.container then
			active.container:Destroy()
			active.container = nil
		end
		if active.notif then
			active.notif:Destroy()
			active.notif = nil
		end
		if active.sizeCn then
			active.sizeCn:Disconnect()
			active.sizeCn = nil
		end
		ObjectiveManager.activeGui = nil
	end
	function ObjectiveManager:_Enable()
		if disabledForFix then return end
		if ObjectiveManager.enabled then
			return
		end
		ObjectiveManager.enabled = true
		if ObjectiveManager.activeGui then
			ObjectiveManager.activeGui.container.gui.Visible = true
			return
		end
		if ObjectiveManager.objective and ObjectiveManager.notifPreference < 2 then
			ObjectiveManager:DisplayObjective()
		end
	end
	function ObjectiveManager:_Disable()
		if disabledForFix then return end
		if not ObjectiveManager.enabled then
			return
		end
		ObjectiveManager.enabled = false
		if ObjectiveManager.activeGui then
			ObjectiveManager.activeGui.container.gui.Visible = false
		end
	end
	function ObjectiveManager:SetEnabled(value--[[reason, remove_reason]])
		if disabledForFix then return end
		if ObjectiveManager.objective == nil then return end
		if value == 'Toggle' then
			if ObjectiveManager.enabled then
				ObjectiveManager:_Disable()
			else
				ObjectiveManager:_Enable()
			end
		else
			if value then
				ObjectiveManager:_Enable()
			else
				ObjectiveManager:_Disable()
			end
		end

		--if remove_reason then
		--	ObjectiveManager.disabledBy[reason] = nil
		--else
		--	ObjectiveManager.disabledBy[reason] = true
		--end
		--local v39 = next(ObjectiveManager.disabledBy)
		--if v39 then
		--	if ObjectiveManager.enabled then
		--		ObjectiveManager:_Disable()
		--	end
		--elseif not ObjectiveManager.enabled then
		--	ObjectiveManager:_Enable()
		--end
		--if v39 and (v39 ~= "subcontext" or not (not next(ObjectiveManager.disabledBy, v39))) then
		--	_p.Menu.boosts:setTimersVisible(false)
		--	return
		--end
		--_p.Menu.boosts:setTimersVisible(true)
	end
	local RunName = 'ObjManagerToggler'
	local RunService = game:GetService("RunService")
	local noObjective = {chunkplaceholder=true,chunkcress=true,gym1=true,gym2=true,gym3=true,gym4=true,gym5=true,gym6=true,gym7=true}
	function ObjectiveManager:EnableToggler()
		if disabledForFix then return end
		RunService:BindToRenderStep(RunName, Enum.RenderPriority.Character.Value, function()
			if _p.DataManager.currentChunk and noObjective[_p.DataManager.currentChunk.id] then
				_p.ObjectiveManager:SetEnabled(false)
			else
				_p.ObjectiveManager:SetEnabled(_p.MasterControl.WalkEnabled)
			end
		end)
	end

	function ObjectiveManager:DisableToggler()
		if disabledForFix then return end
		RunService:UnbindFromRenderStep(RunName)
	end

	_p.Network:bindEvent("newObjective", function(objective, mark)
		if disabledForFix then return end
		if not objective then
			ObjectiveManager:ClearObjective()
			return
		end
		if not mark then mark = 0 end
		ObjectiveManager:UpdateObjective(objective, mark)
	end)
	ObjectiveManager:EnableToggler()
	return ObjectiveManager
end