return function(_p)
	local gym8 = {
		gym = nil,
		canFlip = true,
		currentlyOnRotLock = false,
	}
	local tween = game:GetService("TweenService")
	local UserInputService = game:GetService("UserInputService")
	local Utilities = _p.Utilities
	local player = _p.player
	local mouse = player:GetMouse()
	local char = player.Character
	local battleService = _p.Battle
	local camera = workspace.Camera

	local arrowColors = {
		{Color3.fromRGB(152, 246, 208), Color3.fromRGB(44, 71, 60)},
		{Color3.fromRGB(246, 152, 152), Color3.fromRGB(95, 46, 46)}
	}
	local arrows = {}
	local walls = {}
	local flippableArrows = {}
	local canInteract = true
	local canDrag = false
	local doneFirstRotate = false
	local selected = nil
	local savedPlayerPos = nil
	local gymGui
	local savedPrompt = nil
	local unmovableIndex = nil
	local selectedIndex = nil
	local currentRoom = 'Room3'
	local humanoidRoot = char:WaitForChild("HumanoidRootPart")

	local buttonDownConnection = nil
	local buttonUpConnection = nil

	local namedPuzzleArray = {
		"-", "6",
		"5", "4", "3", "2",
		"1", "-"
	}

	local magnitudePuzzleArray = {
		{5},
		{2, 4, 6, 7, 8, 3},
		{1}
	}
	local groupedIndexes = {
		{{1}, {2, 3}},
		{{2}, {1, 4}},
		{{3}, {1, 4}},
		{{4}, {2, 3, 5}},
		{{5}, {4, 6, 7}},
		{{6}, {5, 8}},
		{{7}, {5, 8}},
		{{8}, {6, 7}}
	}

	local solvedIndexes = {
		{{
			0, 1,
			1, 1, 1, 1,
			1, 0
		},{
				0, 2,
				3, 4, 5, 6,
				7, 0
			}},
		{{
			0, 1,
			1, 1, 1, 1,
			0, 1
		},{
				0, 2,
				3, 4, 5, 6,
				0, 7
			}},
		{{
			0, 1,
			1, 1, 1, 0,
			1, 1
		},{
				0, 2,
				3, 4, 5, 0,
				7, 6
			}},
		{{
			1, 0,
			1, 1, 1, 1,
			0, 1
		},{
				2, 0,
				3, 4, 5, 6,
				0, 7
			}},
		{{
			1, 0,
			1, 1, 1, 1,
			1, 0
		},{
				2, 0,
				3, 4, 5, 6,
				7, 0
			}},
		{{
			1, 0,
			1, 1, 1, 0,
			1, 1
		},{
				2, 0,
				3, 4, 5, 0,
				7, 6
			}},
		{{
			1, 1,
			0, 1, 1, 1,
			0, 1
		},{
				3, 2,
				0, 4, 5, 6,
				0, 7
			}},
		{{
			1, 1,
			0, 1, 1, 1,
			1, 0
		},{
				3, 2,
				0, 4, 5, 6,
				7, 0
			}},
		{{
			1, 1,
			0, 1, 1, 0,
			1, 1
		},{
				3, 2,
				0, 4, 5, 0,
				7, 6
			}}
	}

	local tweenToObjs = {}
	local animDrag = TweenInfo.new(1, Enum.EasingStyle.Quad)
	local anim1 = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local camAnim1 = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local camAnim2 = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

	function gym8:setupGym(gym)
		self.gym = gym
		for i, part in gym8.gym:GetChildren() do
			if string.match(part.Name, "Room") then
				table.insert(walls, part)
			end
		end
		for i, wall in walls do
			for i2, arrowFind in wall:GetChildren() do
				if string.match(arrowFind.Name, "ArrowPad") then
					table.insert(arrows, arrowFind)
				end
			end
		end
	end
	function gym8:desetupGym()
		self.gym = nil	

		-- Disconnect buttons
		buttonUpConnection:Disconnect()
		buttonDownConnection:Disconnect()

		mouse.TargetFilter = nil
		--mouse.Button1Down:disconnect()
		--mouse.Button1Up:disconnect()
		table.clear(walls)
		table.clear(arrows)
		table.clear(flippableArrows)
	end

	local function checkMagTile(centerTime, roomParam)
		local using = nil
		local dataToReturn = nil
		for i, roomToCheck in namedPuzzleArray do
			if roomToCheck == roomParam then
				using = i
			end
		end
		for index, rangeGet in magnitudePuzzleArray do
			for i, filteredIndex in rangeGet do
				if using == filteredIndex then
					dataToReturn = centerTime * index / 2
				end
			end
		end
		return dataToReturn
	end

	function gym8:updateRoom()
		for i, arrow in arrows do
			arrow.IsConnected.Value = false
			if arrow:FindFirstChild('rotateLock') then
				arrow.rotateLock:Destroy()
			end
			table.clear(flippableArrows)
		end

		for i, arrow in arrows do
			local tempArray = arrow:FindFirstChild("Link"):GetTouchingParts()
			local foundWeld = false
			for i2, arrowChild in tempArray do
				if arrowChild:FindFirstChild("ArrowCollide") then
					local found = false
					foundWeld = true
					if arrow.IsConnected.Value == true or arrowChild.Parent.IsConnected.Value == true then
						found = true
					end

					if arrow.IsConnected.Value == false then
						arrow.Main.Color = Color3.fromRGB(58, 52, 52)
						for i3, thing in arrow.L:GetChildren() do
							thing.Color = arrowColors[2][1]
						end
						for i3, thing in arrow.M:GetChildren() do
							thing.Color = arrowColors[2][2]
						end
						arrowChild.Parent.Main.Color = Color3.fromRGB(58, 52, 52)
						for i3, thing in arrowChild.Parent.L:GetChildren() do
							thing.Color = arrowColors[2][1]
						end
						for i3, thing in arrowChild.Parent.M:GetChildren() do
							thing.Color = arrowColors[2][2]
						end
					end

					arrow.IsConnected.Value = true
					arrowChild.Parent.IsConnected.Value = true

					local cf1 = arrow:GetModelCFrame()
					local cf2 = arrowChild.Parent:GetModelCFrame()
					local orientation, size = arrow:GetBoundingBox()
					local orientation2, size2 =arrowChild.Parent:GetBoundingBox()

					local part = Utilities.Create("Part")({
						Anchored = true,
						CanCollide = false,
						Size = Vector3.new(3, 3, 3),
						Transparency = 1,
						Name = 'rotateLock',
						Parent = arrow,
					})

					part.CFrame = arrow.Main.CFrame * CFrame.new(0,2.1,0)

					local gonnaInsert = {arrow, arrowChild.Parent}
					if found == false then
						table.insert(flippableArrows, gonnaInsert)
						arrow.Main.Color = Color3.fromRGB(52, 58, 56)
						for i3, thing in arrow.L:GetChildren() do
							thing.Color = arrowColors[1][1]
						end
						for i3, thing in arrow.M:GetChildren() do
							thing.Color = arrowColors[1][2]
						end
						arrowChild.Parent.Main.Color = Color3.fromRGB(52, 58, 56)
						for i3, thing in arrowChild.Parent.L:GetChildren() do
							thing.Color = arrowColors[1][1]
						end
						for i3, thing in arrowChild.Parent.M:GetChildren() do
							thing.Color = arrowColors[1][2]
						end

					end
				end
			end
			if not foundWeld then
				for i3, thing in arrow.L:GetChildren() do
					thing.Color = arrowColors[2][1]
				end
				for i3, thing in arrow.M:GetChildren() do
					thing.Color = arrowColors[2][2]
				end
			end
		end
	end

	local function tweenModel(model, cf, info)
		local CFrameValue = Instance.new("CFrameValue")
		CFrameValue.Value = model:GetPivot()
		local oriCF = model:GetPivot()
		local oriGoToCF = cf
		CFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
			model:PivotTo(CFrameValue.Value)
		end)

		local tween = tween:Create(CFrameValue, info, {Value = cf})
		tween:Play()

		tween.Completed:Connect(function()
			CFrameValue:Destroy()
			model:PivotTo(oriGoToCF)
		end)
	end

	local function findTileFromIndex(indexToLookFor)
		local tempSelectedName = nil
		local roomFound = nil
		for i, roomTemp in namedPuzzleArray do
			if i == indexToLookFor then
				tempSelectedName = roomTemp
			end
		end
		for i, room in walls do
			if string.match(room.Name, tostring(tempSelectedName)) then
				roomFound = room
			end
		end
		if roomFound then
			return roomFound
		else
			return nil
		end
	end

	function gym8:createDone(pedestal)
		local create = Utilities.Create
		local write = Utilities.Write

		gymGui = _p.RoundedFrame:new {
			Button = true,
			BackgroundColor3 = Color3.fromRGB(121, 66, 145),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(0.3, 0,0.085, 0),
			Position = UDim2.new(0.65, 0,0.015, 0),
			ZIndex = 3, Parent = Utilities.gui,
			CornerRadius = Utilities.gui.AbsoluteSize.Y * .025,
			MouseButton1Click = function()
				Utilities.FadeOut(0.5)
				local fold = gym8:foldRoom(0.0001, pedestal)

				if fold == 'continueWithFold' then
					gymGui:Destroy()

					--[[
					spawn(function()
						local npc = _p.DataManager.currentChunk.npcs.CaptainNPC

						for _, v in pairs(npc.model:GetChildren()) do
							if v:IsA('BasePart') then
								v.Transparency = 0
							end
						end

						npc.model.Head.face.Transparency = 0
						npc.model.HumanoidRootPart.Transparency = 0
					end)
					]]

					Utilities.FadeIn(0.5)
					_p.MasterControl.WalkEnabled = true
					_p.Menu:enable()
					gym8:updateRoom()
				else
					Utilities.FadeIn(0.5)
					_p.NPCChat:say('Impossible cube formation, try again.')
				end

			end,
		}
		write 'Done' {
			Frame = create 'Frame' {
				Name = 'ButtonText',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.8, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5,0.5),
				Position = UDim2.new(0.5,0,0.5,0),
				ZIndex = 4, Parent = gymGui.gui,
			}, Scaled = true
		}
	end

	local function confirmArrow(p)
		if p.Name == 'rotateLock' then
			if gym8.currentlyOnRotLock == false then
				gym8.currentlyOnRotLock = true
			end

			local found = false
			local arrowIs = p.Parent
			local gravchangeVal = nil
			local otherGrav
			local padCFrame
			local pad
			local roomToo
			local roomFrom
			local otherPad
			local lock
			for i, part in flippableArrows do
				if part[1] == arrowIs or part[2] == arrowIs then
					found = true
					otherPad = part[1]
					pad = part[2]
					if arrowIs ~= part[1] then
						gravchangeVal = part[1].Parent:FindFirstChild("GravityChange")
						otherGrav = part[2].Parent:FindFirstChild("GravityChange")
						padCFrame = part[2].Main
						roomFrom = part[2].Parent.Name
						roomToo = part[1].Parent.Name
						--print(roomFrom)
					else
						gravchangeVal = part[2].Parent:FindFirstChild("GravityChange")
						otherGrav = part[1].Parent:FindFirstChild("GravityChange")
						padCFrame = part[1].Main
						roomFrom = part[1].Parent.Name
						roomToo = part[2].Parent.Name
						--print(roomFrom)
					end
				end
			end
			if gravchangeVal and found then
				if gym8.canFlip == true then
					if roomFrom == currentRoom  then 
						gym8.canFlip = false
						gym8:rotateMap(gym8.gym, nil,nil,pad,otherPad, gravchangeVal, otherGrav, currentRoom, roomToo,roomFrom )
					else
						--print('not the current room ur in')
					end
				end

			end
		end
	end

	local function compareArrays(arr1, arr2)
		local counter1 = 0
		if #arr1 == #arr2 then
			for i = 1, #arr1 do
				if arr1[i] == arr2[i] then
					counter1 += 1

				end
			end
		end
		if counter1 == #arr1 then
			return true
		else
			return false
		end
	end

	local function selectDrag(targetToGet)
		local target = targetToGet
		local strRoom = nil
		local tempSelectedIndex = nil
		local found = false
		if target ~= nil then
			if target:FindFirstChild("PlrIndexTarget") then
				local indexBox = target
				for i, roomN in namedPuzzleArray do
					if i == indexBox.ActIndex.Value then
						if roomN	 ~= "-" then
							strRoom = roomN
							tempSelectedIndex = i
							found = true

						end
					end
				end
			end
		end

		if found then
			if gym8.gym:FindFirstChild("Room"..tostring(strRoom)).RoomTag.Value ~= tostring(unmovableIndex) then
				if strRoom ~= nil then
					for i, room in walls do
						if string.match(room.Name, strRoom) then
							selected = room
							selectedIndex = tempSelectedIndex
						end
					end
				end
				if selected ~= nil then
				end
			else
				gym8:doLockedTile(unmovableIndex)
			end
		end
	end

	function  gym8:deSelectDrag()
		selected = nil
		selectedIndex = nil

		for i, room in walls do
		end
	end

	function gym8:rotateMap(map, rotateAngle,rotateDegrees, pad,otherpad, flipDir,otherFlip, currRoom, roomToo)
		if not map then map = self.gym end
		--print('rotazting')
		--print()
		humanoidRoot.Anchored = true

		local m = map.Main
		local mcf = map.Main.CFrame
		local hrp = humanoidRoot

		char.Humanoid:ChangeState(Enum.HumanoidStateType.Running)
		local hrpcf = humanoidRoot.CFrame
		local cameraPart = Utilities.Create("Part")({
			Anchored = false,
			CanCollide = false,
			Size = Vector3.new(3, 3, 3),
			Transparency = 1,
			CFrame = camera.CFrame,
			Name = 'cameraRootPart',
			Parent = hrp,
		})
		local weld = Utilities.Create("WeldConstraint")({
			Parent = hrp,
			Part0 = hrp,
			Part1 = cameraPart
		})

		map.Room2['Pirate Mary'].HumanoidRootPart.Anchored = true
		map.Room3['Pirate Smitty'].HumanoidRootPart.Anchored = true
		map.Room5['Pirate Peterson'].HumanoidRootPart.Anchored = true

		if currentRoom == 'Room2' then
			map.Room2['Pirate Mary'].CanBattle.Value = false
		elseif currentRoom == 'Room3' then 	
			map.Room3['Pirate Smitty'].CanBattle.Value = false
		elseif currentRoom == 'Room5' then
			map.Room5['Pirate Peterson'].CanBattle.Value = false
		end

		local room2HRP = map.Room2['Pirate Mary'].HumanoidRootPart
		local room3HRP = map.Room3['Pirate Smitty'].HumanoidRootPart
		local room5HRP = map.Room5['Pirate Peterson'].HumanoidRootPart

		doneFirstRotate = true
		if tostring(flipDir.Value) == '0, 0, 1' then
			if tostring(otherFlip.Value) == '0, 1, 0' then
				Utilities.Tween(1, 'linear', function(a)
					Utilities.MoveModel(m, mcf * CFrame.Angles(0,0 ,  -math.rad(90 * a)), true)
					Utilities.MoveModel(hrp, otherpad.rotateLock.CFrame * CFrame.new(0,0.2 * a,0) * CFrame.Angles(0,math.rad(-90 * a),0))
					local hrpcfz = humanoidRoot.CFrame
					Utilities.MoveModel(hrp, hrpcfz * CFrame.Angles(math.rad(-90 * a),0,0))
					camera.CFrame = cameraPart.CFrame:Lerp(cameraPart.CFrame, a)
					map.CaptainNPC.HumanoidRootPart.CFrame = map.Room6.capnTP.CFrame
					room2HRP.CFrame = map.Room2.trainerTP.CFrame
					room5HRP.CFrame = map.Room5.trainerTP.CFrame
					room3HRP.CFrame = map.Room3.trainerTP.CFrame
				end)
			elseif tostring(otherFlip.Value) == '0, -1, 0' then
				Utilities.Tween(1, 'linear', function(a)
					Utilities.MoveModel(m, mcf * CFrame.Angles(0,0 ,  math.rad(90 * a)), true)
					Utilities.MoveModel(hrp, otherpad.rotateLock.CFrame * CFrame.new(0,0.2 * a,0) * CFrame.Angles(0,math.rad(-90 * a),0))
					local hrpcfz = humanoidRoot.CFrame
					Utilities.MoveModel(hrp, hrpcfz * CFrame.Angles(math.rad(-90 * a),0,0))
					camera.CFrame = cameraPart.CFrame:Lerp(cameraPart.CFrame, a)
					room2HRP.CFrame = map.Room2.trainerTP.CFrame
					room5HRP.CFrame = map.Room5.trainerTP.CFrame
					room3HRP.CFrame = map.Room3.trainerTP.CFrame
					map.CaptainNPC.HumanoidRootPart.CFrame = map.Room6.capnTP.CFrame
				end)
			end

		elseif tostring(flipDir.Value) == '0, 1, 0' then
			if tostring(otherFlip.Value) == '0, 0, 1' then
				Utilities.Tween(1, 'linear', function(a)
					Utilities.MoveModel(m, mcf * CFrame.Angles(0,0 ,  math.rad(90 * a)), true)
					Utilities.MoveModel(hrp, pad.rotateLock.CFrame * CFrame.new(0,0.2 * a,0) * CFrame.Angles(0,-math.rad(90 * a),0))
					local hrpcfz = humanoidRoot.CFrame
					Utilities.MoveModel(hrp, hrpcfz * CFrame.Angles(math.rad(-90 * a),0,0))
					camera.CFrame = cameraPart.CFrame:Lerp(cameraPart.CFrame, a)
					room2HRP.CFrame = map.Room2.trainerTP.CFrame
					room5HRP.CFrame = map.Room5.trainerTP.CFrame
					room3HRP.CFrame = map.Room3.trainerTP.CFrame
					map.CaptainNPC.HumanoidRootPart.CFrame = map.Room6.capnTP.CFrame

				end)
			else
				if tostring(otherFlip.Value) == '1, 0, 0' then
					Utilities.Tween(1, 'linear', function(a)
						Utilities.MoveModel(m, mcf * CFrame.Angles(math.rad(90 * a),0 , 0), true)
						Utilities.MoveModel(hrp, pad.rotateLock.CFrame * CFrame.new(0,0.2 * a,0) * CFrame.Angles(0,-math.rad(90 * a),0))
						local hrpcfz = humanoidRoot.CFrame
						Utilities.MoveModel(hrp, hrpcfz * CFrame.Angles(math.rad(-90 * a),0,0))
						camera.CFrame = cameraPart.CFrame:Lerp(cameraPart.CFrame, a)
						room2HRP.CFrame = map.Room2.trainerTP.CFrame
						room5HRP.CFrame = map.Room5.trainerTP.CFrame
						room3HRP.CFrame = map.Room3.trainerTP.CFrame
						map.CaptainNPC.HumanoidRootPart.CFrame = map.Room6.capnTP.CFrame
					end)
				end
			end
		elseif tostring(flipDir.Value) == '1, 0, 0' then
			if tostring(otherFlip.Value) == '0, 1, 0' then
				Utilities.Tween(1, 'linear', function(a)
					Utilities.MoveModel(m, mcf * CFrame.Angles(math.rad(-90 * a),0 , 0), true)
					Utilities.MoveModel(hrp, otherpad.rotateLock.CFrame * CFrame.new(0,0.2 * a,0) * CFrame.Angles(0,-math.rad(90 * a),0))
					local hrpcfz = humanoidRoot.CFrame
					Utilities.MoveModel(hrp, hrpcfz * CFrame.Angles(math.rad(-90 * a),0,0))
					camera.CFrame = cameraPart.CFrame:Lerp(cameraPart.CFrame, a)
					room2HRP.CFrame = map.Room2.trainerTP.CFrame
					room5HRP.CFrame = map.Room5.trainerTP.CFrame
					room3HRP.CFrame = map.Room3.trainerTP.CFrame
					map.CaptainNPC.HumanoidRootPart.CFrame = map.Room6.capnTP.CFrame
				end)
			elseif tostring(otherFlip.Value) == '0, 0, -1' then
				Utilities.Tween(1, 'linear', function(a)
					Utilities.MoveModel(m, mcf * CFrame.Angles(0,math.rad(90 * a) ,  0), true)
					Utilities.MoveModel(hrp, pad.rotateLock.CFrame * CFrame.new(0,0.2 * a,0) * CFrame.Angles(0,math.rad(-90 * a),0))
					local hrpcfz = humanoidRoot.CFrame
					Utilities.MoveModel(hrp, hrpcfz * CFrame.Angles(math.rad(-90 * a),0,0))
					camera.CFrame = cameraPart.CFrame:Lerp(cameraPart.CFrame, a)
					room2HRP.CFrame = map.Room2.trainerTP.CFrame
					room5HRP.CFrame = map.Room5.trainerTP.CFrame
					room3HRP.CFrame = map.Room3.trainerTP.CFrame
					map.CaptainNPC.HumanoidRootPart.CFrame = map.Room6.capnTP.CFrame
				end)
			end
		elseif tostring(flipDir.Value) == '0, 0, -1' then
			if tostring(otherFlip.Value) == '1, 0, 0' then
				Utilities.Tween(1, 'linear', function(a)
					Utilities.MoveModel(m, mcf * CFrame.Angles(0,math.rad(-90 * a) ,  0), true)
					Utilities.MoveModel(hrp, otherpad.rotateLock.CFrame * CFrame.new(0,0.2 * a,0) * CFrame.Angles(0,math.rad(-90 * a),0))
					local hrpcfz = humanoidRoot.CFrame
					Utilities.MoveModel(hrp, hrpcfz * CFrame.Angles(math.rad(-90 * a),0,0))
					camera.CFrame = cameraPart.CFrame:Lerp(cameraPart.CFrame, a)
					room2HRP.CFrame = map.Room2.trainerTP.CFrame
					room5HRP.CFrame = map.Room5.trainerTP.CFrame
					room3HRP.CFrame = map.Room3.trainerTP.CFrame
					map.CaptainNPC.HumanoidRootPart.CFrame = map.Room6.capnTP.CFrame
				end)
			elseif tostring(otherFlip.Value) == '0, -1, 0' then
				Utilities.Tween(1, 'linear', function(a)
					Utilities.MoveModel(m, mcf * CFrame.Angles(0,0 , math.rad(-90 * a)), true)
					Utilities.MoveModel(hrp, otherpad.rotateLock.CFrame * CFrame.new(0,0.2 * a,0) * CFrame.Angles(0,-math.rad(90 * a),0))
					local hrpcfz = humanoidRoot.CFrame
					Utilities.MoveModel(hrp, hrpcfz * CFrame.Angles(math.rad(90 * a),0,0))
					camera.CFrame = cameraPart.CFrame:Lerp(cameraPart.CFrame, a)
					room2HRP.CFrame = map.Room2.trainerTP.CFrame
					room5HRP.CFrame = map.Room5.trainerTP.CFrame
					room3HRP.CFrame = map.Room3.trainerTP.CFrame
					map.CaptainNPC.HumanoidRootPart.CFrame = map.Room6.capnTP.CFrame
				end)
			end
		elseif tostring(flipDir.Value) == '0, -1, 0' then
			if tostring(otherFlip.Value) == '0, 0, -1' then
				Utilities.Tween(1, 'linear', function(a)
					Utilities.MoveModel(m, mcf * CFrame.Angles(0,0 , math.rad(90 * a)), true)
					Utilities.MoveModel(hrp, otherpad.rotateLock.CFrame * CFrame.new(0,0.2 * a,0) * CFrame.Angles(0,-math.rad(90 * a),0))
					local hrpcfz = humanoidRoot.CFrame
					Utilities.MoveModel(hrp, hrpcfz * CFrame.Angles(math.rad(-90 * a),0,0))
					camera.CFrame = cameraPart.CFrame:Lerp(cameraPart.CFrame, a)
					room2HRP.CFrame = map.Room2.trainerTP.CFrame
					room5HRP.CFrame = map.Room5.trainerTP.CFrame
					map.CaptainNPC.HumanoidRootPart.CFrame = map.Room6.capnTP.CFrame
					room3HRP.CFrame = map.Room3.trainerTP.CFrame
				end)
			elseif tostring(otherFlip.Value) == '0, 0, 1' then
				Utilities.Tween(1, 'linear', function(a)
					Utilities.MoveModel(m, mcf * CFrame.Angles(0,0 ,  -math.rad(90 * a)), true)
					Utilities.MoveModel(hrp, pad.rotateLock.CFrame * CFrame.new(0,0.2 * a,0) * CFrame.Angles(0,math.rad(90 * a),0))
					local hrpcfz = humanoidRoot.CFrame
					Utilities.MoveModel(hrp, hrpcfz * CFrame.Angles(math.rad(90 * a),math.rad(180* a),0))
					camera.CFrame = cameraPart.CFrame:Lerp(cameraPart.CFrame, a)
					room2HRP.CFrame = map.Room2.trainerTP.CFrame
					room5HRP.CFrame = map.Room5.trainerTP.CFrame
					room3HRP.CFrame = map.Room3.trainerTP.CFrame
					map.CaptainNPC.HumanoidRootPart.CFrame = map.Room6.capnTP.CFrame
				end)
			end
		elseif tostring(flipDir.Value) == '-1, 0, 0' then
			if tostring(otherFlip.Value) == '0, 0, 1' then
				Utilities.Tween(1, 'linear', function(a)
					Utilities.MoveModel(m, mcf * CFrame.Angles(0,math.rad(90 * a) , 0), true)
					Utilities.MoveModel(hrp, otherpad.rotateLock.CFrame * CFrame.new(0,0.2 * a,0) * CFrame.Angles(0,-math.rad(90 * a),0))
					local hrpcfz = humanoidRoot.CFrame
					Utilities.MoveModel(hrp, hrpcfz * CFrame.Angles(math.rad(-90 * a),0,0))
					camera.CFrame = cameraPart.CFrame:Lerp(cameraPart.CFrame, a)
					room2HRP.CFrame = map.Room2.trainerTP.CFrame
					room5HRP.CFrame = map.Room5.trainerTP.CFrame
					map.CaptainNPC.HumanoidRootPart.CFrame = map.Room6.capnTP.CFrame
					room3HRP.CFrame = map.Room3.trainerTP.CFrame
				end)
			end
		end

		cameraPart:Destroy()
		currentRoom = roomToo
		--print('ur going to', roomToo)
		humanoidRoot.Anchored = false

		if roomToo == 'Room2' then
			map.Room2['Pirate Mary'].HumanoidRootPart.Anchored = false
			map.Room2['Pirate Mary'].CanBattle.Value = true
		elseif roomToo == 'Room3' then 	
			map.Room3['Pirate Smitty'].HumanoidRootPart.Anchored = false	
			map.Room3['Pirate Smitty'].CanBattle.Value = true
		elseif roomToo == 'Room5' then
			map.Room5['Pirate Peterson'].HumanoidRootPart.Anchored = false
			map.Room5['Pirate Peterson'].CanBattle.Value = true
		end

		map.Room3['Pirate Smitty'].HumanoidRootPart.CFrame = map.Room3.trainerTP.CFrame
		map.Room5['Pirate Peterson'].HumanoidRootPart.CFrame = map.Room5.trainerTP.CFrame
		map.Room2['Pirate Mary'].HumanoidRootPart.CFrame = map.Room2.trainerTP.CFrame

		if not battleService.currentBattle then
			if gym8.currentlyOnRotLock == false then
				task.wait(1)
				gym8.canFlip = true
			else
				repeat task.wait() until gym8.currentlyOnRotLock == false
				task.wait(1)
				gym8.canFlip = true
			end
		else
			repeat task.wait() until not battleService.currentBattle
			if gym8.currentlyOnRotLock == false then
				task.wait(1)
				gym8.canFlip = true
			else
				repeat task.wait() until gym8.currentlyOnRotLock == false
				task.wait(1)
				gym8.canFlip = true
			end
		end
	end

	function gym8:foldRoom(timeToMove, pedestal)
		local binaryRoomArray = {}
		local canFinish = false
		local savedCheckingArray = nil
		for i, part in namedPuzzleArray do
			if part == "-" then
				table.insert(binaryRoomArray, 0)
			else
				table.insert(binaryRoomArray, 1)
			end
		end

		for i, checkingArray in solvedIndexes do
			if compareArrays(checkingArray[1], binaryRoomArray) then
				canFinish = true
				savedCheckingArray = checkingArray
			end
		end
		if canFinish then
			gym8:deSelectDrag()
			for i, room in namedPuzzleArray do
				local canTween = false
				local tweenToPart = nil
				for i2, partBoxIndex in savedCheckingArray[2] do
					if i2 == i then
						if room ~= "-" then
							canTween = true
							tweenToPart = self.gym.BoxIndexes:FindFirstChild(tostring(partBoxIndex))
						end
					end
				end
				if canTween then
					local oriTTPCFrame = tweenToPart.CFrame
					if pedestal == 1 then
						if room ~= "-" then
							if i == 1 and namedPuzzleArray[2] ~= "-" then
								tweenToPart.Rotation = Vector3.new(90, 0, 90)
								--print('0, 90, -180 db for index 1 [1]')
							elseif i == 1 and namedPuzzleArray[3] ~= "-" then
								tweenToPart.Rotation = Vector3.new(0, -90, 90)
								--print('90,0,90 db for index 1 [2]')
							end

							if i == 8 and namedPuzzleArray[6] ~= "-" then
								tweenToPart.Rotation = Vector3.new(90, -180, 0)
								--print('3')
							elseif i == 8 and namedPuzzleArray[7] ~= "-" then
								tweenToPart.Rotation = Vector3.new(0, 0, -180)
								--print('2')
							end
						end
					elseif pedestal == 2 then
						if room ~= "-" then
							if i == 1 and namedPuzzleArray[2] ~= "-" then
								tweenToPart.Rotation = Vector3.new(0, 90, -90)
								--print('0, 90, -180 db for index 1 [1]')
							elseif i == 1 and namedPuzzleArray[3] ~= "-" then
								tweenToPart.Rotation = Vector3.new(0, -90, 0)
								--print('90,0,90 db for index 1 [2]')
							end

							if i == 8 and namedPuzzleArray[6] ~= "-" then
								tweenToPart.Rotation = Vector3.new(90, 180,90)
								--print('3')
							elseif i == 8 and namedPuzzleArray[7] ~= "-" then
								tweenToPart.Rotation = Vector3.new(90, 180,90)
								--print('2')
							end
						end
					end
					self.gym:FindFirstChild("Room"..tostring(room)).GravityChange.Value = tweenToPart.GravityChange.Value
					tweenModel(self.gym:FindFirstChild("Room"..tostring(room)), tweenToPart.CFrame, TweenInfo.new(checkMagTile(timeToMove, room), Enum.EasingStyle.Linear, Enum.EasingDirection.InOut))
					tweenToPart.CFrame = oriTTPCFrame
				end
			end
			unmovableIndex = nil
			canDrag = false
			canInteract = true
			camera.CameraType = Enum.CameraType.Custom
			gym8:updateRoom()
			char.Parent = workspace
			char:PivotTo(savedPlayerPos)
			savedPlayerPos = nil
			humanoidRoot.Anchored = false
			gym8:updateRoom()
			return 'continueWithFold'
		end
	end

	function gym8:unfoldRoom(timeToMove, pedestal)
		if pedestal == 1 then
			unmovableIndex = 4
			humanoidRoot.Anchored = true
			savedPlayerPos = char:GetPivot()
			char.Parent = gym8.gym:FindFirstChild("Room"..tostring(unmovableIndex))
			canInteract = false

			camera.CameraType = Enum.CameraType.Scriptable
			camera.CFrame = gym8.gym.CameraPart.CFrame
			gym8:unfoldRoom(0.0001)
			task.wait(0.1)
			gym8:updateRoom()
			gym8:createDone(1)
			canDrag = true
		elseif pedestal == 2 then
			unmovableIndex = 2
			humanoidRoot.Anchored = true
			savedPlayerPos = char:GetPivot()
			char.Parent = gym8.gym:FindFirstChild("Room"..tostring(unmovableIndex))
			canInteract = false
			camera.CameraType = Enum.CameraType.Scriptable
			camera.CFrame = gym8.gym.CameraPart.CFrame
			gym8:unfoldRoom(0.0001)
			task.wait(2.5)
			gym8:updateRoom()
			gym8:createDone(2)
			canDrag = true
		end
		for roomIndex, roomParam in namedPuzzleArray do
			if roomParam ~= "-" then
				local selected = nil
				local tweenTo = nil
				for i, room in gym8.gym:GetChildren() do
					if string.match(room.Name, "Room") then
						if string.match(room.Name, roomParam) then
							selected = room
						end
					end
				end
				for i, gotoPart in gym8.gym.Indexes:GetChildren() do
					if string.match(gotoPart.Name, tostring(roomIndex)) then
						tweenTo = gotoPart
					end
				end
				if selected ~= nil and tweenTo ~= nil then
					tweenModel(selected, tweenTo.CFrame, TweenInfo.new(checkMagTile(timeToMove, roomParam), Enum.EasingStyle.Linear, Enum.EasingDirection.InOut))
				else
					warn("Goofy ahh room won't fold.")
				end
			end
		end
	end

	function gym8:doLockedTile(tile)
		if tile == 4 then
			local room = gym8.gym.Room4
			local roomIco = room.Main.LockedUI.Lock
			roomIco.ImageTransparency = 0.5
			roomIco.Size = UDim2.new(0.75,0,0.75,0)
			task.spawn(function()
				Utilities.pTween(roomIco, 'ImageTransparency', 1 ,.35, 'linear')
			end)
			task.spawn(function()
				Utilities.pTween(roomIco, 'Size', UDim2.new(1,0,1,0) ,.35, 'linear')
			end)
		elseif tile == 2 then
			local room = gym8.gym.Room2
			local roomIco = room.Main.LockedUI.Lock
			roomIco.ImageTransparency = 0.5
			roomIco.Size = UDim2.new(0.75,0,0.75,0)
			task.spawn(function()
				Utilities.pTween(roomIco, 'ImageTransparency', 1 ,.35, 'linear')
			end)
			task.spawn(function()
				Utilities.pTween(roomIco, 'Size', UDim2.new(1,0,1,0) ,.35, 'linear')
			end)
		end
	end

	local mouseIsDown = false

	buttonDownConnection = UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		mouse.TargetFilter = gym8.gym.PBase
		local target = mouse.Target
		if canDrag then
			gym8:updateRoom()
			if selected ~= nil then
				gym8:updateRoom()
				if target:FindFirstChild("ActIndex") then
					if target:FindFirstChild("ActIndex").Value == selectedIndex then
						gym8:deSelectDrag()

						gym8:updateRoom()
					else
						gym8:updateRoom()
						local savedTargetTilePos = target.CFrame
						if not findTileFromIndex(target.ActIndex.Value) then

							gym8:updateRoom()
							local selectedIndexMain = nil
							local canContinue = false
							for i, roomTemp in namedPuzzleArray do
								if roomTemp == selected.RoomTag.Value then
									selectedIndexMain = i
								end
							end

							if tonumber(selected.RoomTag.Value) ~= unmovableIndex then
								for i, sector in groupedIndexes do
									local selectedIndex = sector[1][1]
									local allowedIndexes = sector[2]
									if selectedIndex == selectedIndexMain then
										for i2, ind in allowedIndexes do
											if target.ActIndex.Value == ind then
												canContinue = true
											end
										end
									end
								end

								gym8:updateRoom()

								if canContinue then
									tweenModel(selected, savedTargetTilePos, animDrag)
									gym8:updateRoom()
									namedPuzzleArray[selectedIndexMain] = "-"
									namedPuzzleArray[target.ActIndex.Value] = selected.RoomTag.Value
									gym8:deSelectDrag()
									--print(namedPuzzleArray)
									task.wait(animDrag.Time)
									gym8:updateRoom()
								end
							end
						end
					end
				end
			else
				if target:FindFirstChild("ActIndex") then
					gym8:deSelectDrag()
					selectDrag(target)
				end
			end
		end
	end)
	buttonUpConnection = UserInputService.InputEnded:Connect(function(input, processed)
		if processed then return end
		local target = mouse.Target
		if canDrag then
			gym8:updateRoom()
			if selected ~= nil then
				gym8:updateRoom()

				if target:FindFirstChild("ActIndex") then
					if target:FindFirstChild("ActIndex").Value == selectedIndex then
						gym8:deSelectDrag()
						gym8:updateRoom()
					else
						gym8:updateRoom()
						local savedTargetTilePos = target.CFrame
						if not findTileFromIndex(target.ActIndex.Value) then
							gym8:updateRoom()
							local selectedIndexMain = nil
							local canContinue = false
							for i, roomTemp in namedPuzzleArray do
								if roomTemp == selected.RoomTag.Value then
									selectedIndexMain = i
								end
							end
							if tonumber(selected.RoomTag.Value) ~= unmovableIndex then
								for i, sector in groupedIndexes do
									local selectedIndex = sector[1][1]
									local allowedIndexes = sector[2]
									if selectedIndex == selectedIndexMain then
										for i2, ind in allowedIndexes do
											if target.ActIndex.Value == ind then
												canContinue = true
											end
										end
									end
								end

								gym8:updateRoom()

								if canContinue then
									tweenModel(selected, savedTargetTilePos, animDrag)
									gym8:updateRoom()
									namedPuzzleArray[selectedIndexMain] = "-"
									namedPuzzleArray[target.ActIndex.Value] = selected.RoomTag.Value
									gym8:deSelectDrag()
									--print(namedPuzzleArray)
									task.wait(animDrag.Time)
									gym8:updateRoom()
								end
							end
						end
					end
				end
			else
				if target:FindFirstChild("ActIndex") then
					gym8:deSelectDrag()
					selectDrag(target)
				end
			end
		end
	end)

	for i, bodyPart in char:GetChildren() do
		if string.match(bodyPart.Name, "Foot") or string.match(bodyPart.Name, "Leg") then
			bodyPart.Touched:Connect(function(part)
				if canInteract then
					confirmArrow(part)
				end
				bodyPart.TouchEnded:Connect(function(p)
					if p.Name == 'rotateLock' then
						if gym8.currentlyOnRotLock == true then
							gym8.currentlyOnRotLock = false
						end
					end
				end)
			end)
		end
	end

	return gym8
end