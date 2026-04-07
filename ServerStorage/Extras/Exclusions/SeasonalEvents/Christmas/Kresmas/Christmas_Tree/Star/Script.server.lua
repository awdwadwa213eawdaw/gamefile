while true do
	for i=3,360,3 do
		x = math.rad(i)
		script.Parent.CFrame = script.Parent.CFrame*CFrame.Angles(0,math.pi/60,0)
		script.Parent.Mesh.VertexColor = Vector3.new(math.sin(x)/2+1.5,math.sin(x)/2+1.5,math.cos(x)*.9+1.1)
		wait()
	end
end
