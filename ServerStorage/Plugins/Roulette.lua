local RunService = game:GetService("RunService")

return function(_p)
	local ui = script.Roulette
	local pgui = _p.player:WaitForChild("PlayerGui")
	local RouletteSpinner
	local isopen 
	
	local m = ui.Main
	local button = m.Button
	
	local buttonGradient = button.UIStroke.UIGradient
	local textGradient = button.RouletteText.UIGradient

	task.spawn(function()
		while task.wait() do
			pcall(function()
				button.Visible = pgui.MainGui.Menu.Visible				
			end)
		end
	end)
	
	task.spawn(function()
		RunService.RenderStepped:Connect(function()
			buttonGradient.Rotation += 0.5
			textGradient.Rotation += 0.5
		end)
	end)

	ui.Main.Button.MouseButton1Down:Connect(function()
		if isopen then return end
		
		if _p.PlayerData.completedEvents.ChooseFirstPokemon then
			isopen = true
			spawn(function() _p.Menu:disable() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()

			if not RouletteSpinner then
				RouletteSpinner = _p.DataManager:loadModule("RouletteSpinner")
			end
			RouletteSpinner:openSpinner()
		else
			_p.NPCChat:say("You must obtain a starter before using the Roulette System.")
		end
		
		spawn(function() _p.Menu:enable() end)
		_p.MasterControl.WalkEnabled = true
		isopen = false
	end)

	ui.Parent = pgui
end