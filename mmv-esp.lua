local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local InsertService = game:GetService("InsertService")

local MM2_ID = 952302020
local MMV_ID = 121330469999373
local currentGame = game.PlaceId
local isMM2 = currentGame == MM2_ID
local isMMV = currentGame == MMV_ID

if not isMM2 and not isMMV then
    pcall(function()
        local gui = Instance.new("ScreenGui", CoreGui)
        gui.Name = "ErrorGui"
        local frame = Instance.new("Frame", gui)
        frame.Size = UDim2.new(0, 400, 0, 200)
        frame.Position = UDim2.new(0.5, -200, 0.5, -100)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        frame.BorderSizePixel = 0
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
        local title = Instance.new("TextLabel", frame)
        title.Size = UDim2.new(1, 0, 0, 50)
        title.BackgroundTransparency = 1
        title.Text = "MMV / MM2 Hub"
        title.TextColor3 = Color3.fromRGB(255, 70, 70)
        title.TextSize = 24
        title.Font = Enum.Font.GothamBold
        local msg = Instance.new("TextLabel", frame)
        msg.Size = UDim2.new(1, -40, 0, 80)
        msg.Position = UDim2.new(0, 20, 0, 60)
        msg.BackgroundTransparency = 1
        msg.Text = "This script only works in MM2 or MMV!\nYour game ID: " .. game.PlaceId
        msg.TextColor3 = Color3.fromRGB(200, 200, 200)
        msg.TextSize = 16
        msg.Font = Enum.Font.Gotham
        msg.TextWrapped = true
        local closeBtn = Instance.new("TextButton", frame)
        closeBtn.Size = UDim2.new(0, 120, 0, 35)
        closeBtn.Position = UDim2.new(0.5, -60, 1, -50)
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        closeBtn.Text = "Close"
        closeBtn.TextColor3 = Color3.new(1, 1, 1)
        closeBtn.TextSize = 16
        closeBtn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
        closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
    end)
    return
end

local gameName = isMM2 and "MM2" or "MMV"
local espEnabled = true
local espColor = Color3.new(1, 0, 0)
local espObjects = {}
local antiFlingEnabled = false
local lowGfxEnabled = false

local espFolder = Instance.new("Folder")
espFolder.Name = "MMV_ESP"
espFolder.Parent = CoreGui

local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "ESP_Menu"
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 280, 0, 400)
mainFrame.Position = UDim2.new(0, 20, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
mainFrame.BorderSizePixel = 0
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = gameName .. " Hub"
title.TextColor3 = Color3.fromRGB(100, 200, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left

local minimizeBtn = Instance.new("TextButton", header)
minimizeBtn.Size = UDim2.new(0, 28, 0, 28)
minimizeBtn.Position = UDim2.new(1, -38, 0, 6)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.TextSize = 20
minimizeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)

local scrolling = Instance.new("ScrollingFrame", mainFrame)
scrolling.Size = UDim2.new(1, -20, 1, -50)
scrolling.Position = UDim2.new(0, 10, 0, 45)
scrolling.BackgroundTransparency = 1
scrolling.ScrollBarThickness = 4
scrolling.ScrollBarImageColor3 = Color3.fromRGB(100, 200, 255)
scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
scrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", scrolling)
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local function sectionLabel(text, order)
    local label = Instance.new("TextLabel", scrolling)
    label.Size = UDim2.new(1, 0, 0, 22)
    label.BackgroundTransparency = 1
    label.Text = "  " .. text
    label.TextColor3 = Color3.fromRGB(100, 200, 255)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = order
    return label
end

local function makeButton(text, color, order)
    local btn = Instance.new("TextButton", scrolling)
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = color or Color3.fromRGB(40, 40, 52)
    btn.Text = "  " .. text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = order
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local function makeTextBox(placeholder, order)
    local box = Instance.new("TextBox", scrolling)
    box.Size = UDim2.new(1, 0, 0, 34)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
    box.Text = ""
    box.PlaceholderText = placeholder
    box.TextColor3 = Color3.new(1, 1, 1)
    box.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    box.TextSize = 14
    box.Font = Enum.Font.Gotham
    box.LayoutOrder = order
    box.ClearTextOnFocus = false
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)
    return box
end

local function makeInfo(text, order)
    local label = Instance.new("TextLabel", scrolling)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "  " .. text
    label.TextColor3 = Color3.fromRGB(140, 140, 140)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = order
    return label
end

sectionLabel("--- ESP ---", 0)
local statusLabel = makeInfo("Status: ON", 1)
local toggleBtn = makeButton("ESP: ON", Color3.fromRGB(30, 100, 30), 2)

sectionLabel("--- ESP Colors ---", 10)
local redBtn = makeButton("> Red", Color3.fromRGB(130, 30, 30), 11)
local greenBtn = makeButton("Green", Color3.fromRGB(30, 130, 30), 12)
local blueBtn = makeButton("Blue", Color3.fromRGB(30, 30, 130), 13)
local whiteBtn = makeButton("White", Color3.fromRGB(130, 130, 130), 14)

sectionLabel("--- Player Info ---", 20)
local playerLabel = makeInfo("Players: 0", 21)

sectionLabel("--- Misc ---", 30)
local gfxBtn = makeButton("Low GFX: OFF", Color3.fromRGB(100, 60, 30), 31)
makeInfo("Lowers graphics for better FPS", 32)

sectionLabel("--- Anti Fling ---", 40)
local flingBtn = makeButton("Anti-Fling: OFF", Color3.fromRGB(100, 60, 30), 41)
makeInfo("Prevents being flung by other players", 42)

sectionLabel("--- Item Giver ---", 50)
makeInfo("Enter catalog asset ID to equip item", 51)
local assetBox = makeTextBox("Asset ID (e.g. 1374269)", 52)
local hatBtn = makeButton("Equip Item", Color3.fromRGB(50, 80, 120), 53)
local removeHatBtn = makeButton("Remove Added Items", Color3.fromRGB(120, 50, 50), 54)
makeInfo("Visible only to you", 55)

local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    scrolling.Visible = not minimized
    minimizeBtn.Text = minimized and "+" or "-"
    mainFrame.Size = minimized and UDim2.new(0, 280, 0, 40) or UDim2.new(0, 280, 0, 400)
end)

toggleBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        toggleBtn.Text = "  ESP: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
        statusLabel.Text = "  Status: ON"
    else
        toggleBtn.Text = "  ESP: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
        statusLabel.Text = "  Status: OFF"
    end
end)

local function setColor(color, name)
    espColor = color
    redBtn.Text = name == "Red" and "> Red" or "  Red"
    greenBtn.Text = name == "Green" and "> Green" or "  Green"
    blueBtn.Text = name == "Blue" and "> Blue" or "  Blue"
    whiteBtn.Text = name == "White" and "> White" or "  White"
    for _, esp in pairs(espObjects) do
        if esp.highlight then esp.highlight.FillColor = color end
    end
end

redBtn.MouseButton1Click:Connect(function() setColor(Color3.new(1, 0, 0), "Red") end)
greenBtn.MouseButton1Click:Connect(function() setColor(Color3.new(0, 1, 0), "Green") end)
blueBtn.MouseButton1Click:Connect(function() setColor(Color3.new(0, 0, 1), "Blue") end)
whiteBtn.MouseButton1Click:Connect(function() setColor(Color3.new(1, 1, 1), "White") end)

gfxBtn.MouseButton1Click:Connect(function()
    lowGfxEnabled = not lowGfxEnabled
    if lowGfxEnabled then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.Plastic
                    v.Reflectance = 0
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Enabled = false
                end
            end
        end)
        gfxBtn.Text = "  Low GFX: ON"
        gfxBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
    else
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        gfxBtn.Text = "  Low GFX: OFF"
        gfxBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 30)
    end
end)

flingBtn.MouseButton1Click:Connect(function()
    antiFlingEnabled = not antiFlingEnabled
    if antiFlingEnabled then
        flingBtn.Text = "  Anti-Fling: ON"
        flingBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
    else
        flingBtn.Text = "  Anti-Fling: OFF"
        flingBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 30)
    end
end)

local addedItems = {}

hatBtn.MouseButton1Click:Connect(function()
    local id = tonumber(assetBox.Text)
    if not id then return end
    pcall(function()
        local model = InsertService:LoadAsset(id)
        if model then
            for _, item in pairs(model:GetChildren()) do
                if item:IsA("Accessory") or item:IsA("Hat") then
                    local char = LocalPlayer.Character
                    if char then
                        item.Parent = char
                        table.insert(addedItems, item)
                    end
                end
            end
        end
    end)
end)

removeHatBtn.MouseButton1Click:Connect(function()
    for _, item in pairs(addedItems) do
        pcall(function() item:Destroy() end)
    end
    addedItems = {}
end)

local function createESP(player)
    if player == LocalPlayer then return end
    if espObjects[player] then return end

    local highlight = nil
    local billboard = nil
    local humanoid = nil

    pcall(function()
        if player.Character then
            highlight = Instance.new("Highlight")
            highlight.Name = "ESP_High"
            highlight.FillColor = espColor
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Adornee = player.Character
            highlight.Parent = player.Character
        end
    end)

    pcall(function()
        local char = player.Character
        if char then
            humanoid = char:FindFirstChildOfClass("Humanoid")
            local head = char:FindFirstChild("Head")
            if head then
                billboard = Instance.new("BillboardGui")
                billboard.Name = "ESP_Name"
                billboard.Size = UDim2.new(0, 100, 0, 40)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                billboard.Adornee = head
                billboard.Parent = head

                local nameLabel = Instance.new("TextLabel", billboard)
                nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = player.Name
                nameLabel.TextColor3 = Color3.new(1, 1, 1)
                nameLabel.TextStrokeTransparency = 0
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextSize = 14

                local healthLabel = Instance.new("TextLabel", billboard)
                healthLabel.Size = UDim2.new(1, 0, 0.5, 0)
                healthLabel.Position = UDim2.new(0, 0, 0.5, 0)
                healthLabel.BackgroundTransparency = 1
                healthLabel.Text = "100 HP"
                healthLabel.TextColor3 = Color3.new(0, 1, 0)
                healthLabel.TextStrokeTransparency = 0
                healthLabel.Font = Enum.Font.GothamBold
                healthLabel.TextSize = 14
            end
        end
    end)

    espObjects[player] = {
        highlight = highlight,
        billboard = billboard,
        humanoid = humanoid,
    }

    if not espEnabled then
        if highlight then highlight.Enabled = false end
        if billboard then billboard.Enabled = false end
    end
end

local function removeESP(player)
    local esp = espObjects[player]
    if esp then
        pcall(function() if esp.highlight then esp.highlight:Destroy() end end)
        pcall(function() if esp.billboard then esp.billboard:Destroy() end end)
        espObjects[player] = nil
    end
end

pcall(function()
    Players.PlayerAdded:Connect(function(player)
        task.wait(2)
        createESP(player)
    end)
end)

pcall(function()
    Players.PlayerRemoving:Connect(removeESP)
end)

pcall(function()
    for _, player in pairs(Players:GetPlayers()) do
        createESP(player)
    end
end)

RunService.RenderStepped:Connect(function()
    if espEnabled then
        for player, esp in pairs(espObjects) do
            pcall(function()
                local char = player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum and esp.billboard then
                    local head = char:FindFirstChild("Head")
                    if head then
                        esp.billboard.Adornee = head
                        esp.billboard.Enabled = true
                        local pct = hum.Health / hum.MaxHealth
                        for _, l in pairs(esp.billboard:GetDescendants()) do
                            if l:IsA("TextLabel") then
                                l.Text = math.floor(hum.Health) .. " HP"
                                l.TextColor3 = Color3.new(1 - pct, pct, 0)
                            end
                        end
                    end
                end
                if char and esp.highlight then
                    esp.highlight.Adornee = char
                    esp.highlight.Enabled = true
                end
                esp.humanoid = hum
            end)
        end
    else
        for _, esp in pairs(espObjects) do
            pcall(function()
                if esp.highlight then esp.highlight.Enabled = false end
                if esp.billboard then esp.billboard.Enabled = false end
            end)
        end
    end

    if antiFlingEnabled then
        pcall(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                root.AssemblyLinearVelocity = Vector3.new(
                    root.AssemblyLinearVelocity.X,
                    math.clamp(root.AssemblyLinearVelocity.Y, -50, 50),
                    root.AssemblyLinearVelocity.Z
                )
            end
        end)
    end

    pcall(function()
        local total = 0
        local alive = 0
        for _, esp in pairs(espObjects) do
            total = total + 1
            if esp.humanoid and esp.humanoid.Health > 0 then
                alive = alive + 1
            end
        end
        playerLabel.Text = "  Players: " .. alive .. " alive / " .. total
    end)
end)

print("[" .. gameName .. " Hub] Loaded!")
