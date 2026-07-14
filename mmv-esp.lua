print("Step 1: Script running")
print("PlaceId:", game.PlaceId)

local ok1, Players = pcall(function() return game:GetService("Players") end)
print("Step 2: Players:", ok1, Players)

local ok2, LocalPlayer = pcall(function() return Players.LocalPlayer end)
print("Step 3: LocalPlayer:", ok2, LocalPlayer)

local ok3, CoreGui = pcall(function() return game:GetService("CoreGui") end)
print("Step 4: CoreGui:", ok3, CoreGui)

local ok4, RS = pcall(function() return game:GetService("RunService") end)
print("Step 5: RunService:", ok4, RS)

local ok5, IS = pcall(function() return game:GetService("InsertService") end)
print("Step 6: InsertService:", ok5, IS)

print("Step 7: MM2 check:", game.PlaceId == 952302020)
print("Step 8: MMV check:", game.PlaceId == 121330469999373)

local ok6, gui = pcall(function()
    local g = Instance.new("ScreenGui")
    g.Name = "TestGUI"
    g.Parent = CoreGui
    return g
end)
print("Step 9: ScreenGui:", ok6, gui)

if ok6 and gui then
    local ok7, frame = pcall(function()
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0, 200, 0, 100)
        f.Position = UDim2.new(0.5, -100, 0.5, -50)
        f.BackgroundColor3 = Color3.new(0, 0, 0)
        f.Parent = gui
        return f
    end)
    print("Step 10: Frame:", ok7, frame)

    local ok8, label = pcall(function()
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 1, 0)
        l.BackgroundTransparency = 1
        l.Text = "IT WORKS!"
        l.TextColor3 = Color3.new(1, 1, 1)
        l.TextSize = 30
        l.Font = Enum.Font.GothamBold
        l.Parent = frame
        return l
    end)
    print("Step 11: Label:", ok8, label)
end

print("Step 12: Done!")
