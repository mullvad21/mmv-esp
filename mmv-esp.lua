print("PlaceId:", game.PlaceId)

pcall(function()
    local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    print("GameName:", info.Name)
end)

local Camera = workspace.CurrentCamera
print("Camera:", Camera)
print("Camera.CFrame tostring:", tostring(Camera.CFrame))
print("ViewportSize:", Camera.ViewportSize)
print("FOV:", Camera.FieldOfView)

local ok1, r1 = pcall(function() return Camera:WorldToViewportPoint(Vector3.new(0,10,0)) end)
print("WorldToViewport:", ok1, tostring(r1))

local ok2, r2 = pcall(function() return Camera.CFrame.Position end)
print("CFrame.Position:", ok2, tostring(r2))

local box = Drawing.new("Square")
box.Size = Vector2.new(200, 200)
box.Position = Vector2.new(300, 300)
box.Thickness = 2
box.Color = Color3.new(0, 255, 0)
box.Visible = true
print("Green square drawn")
task.wait(3)
box:Remove()

local t = Drawing.new("Text")
t.Text = "MMV HUB LOADED"
t.Position = Vector2.new(100, 100)
t.Size = 24
t.Color = Color3.new(0, 255, 0)
t.Visible = true
task.wait(3)
t:Remove()

print("Done!")
