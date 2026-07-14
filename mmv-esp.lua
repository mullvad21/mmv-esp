local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local menuOpen = true
local espEnabled = true
local espColor = Color3.new(1, 0, 0)
local colorIndex = 1
local colors = {
    Color3.new(1, 0, 0),
    Color3.new(0, 1, 0),
    Color3.new(0, 0, 1),
    Color3.new(1, 1, 1),
}
local colorNames = {"Red", "Green", "Blue", "White"}
local lowGfxEnabled = false
local antiFlingEnabled = false
local menuDrawings = {}
local espDrawings = {}

local function getCam()
    local ok, cam = pcall(function() return workspace.CurrentCamera end)
    return ok and cam or nil
end

local function clearMenu()
    for _, obj in pairs(menuDrawings) do
        pcall(function() obj:Remove() end)
    end
    menuDrawings = {}
end

local function menuText(text, pos, size, color)
    local t = Drawing.new("Text")
    t.Text = text
    t.Position = pos
    t.Size = size or 14
    t.Color = color or Color3.new(1, 1, 1)
    t.Outline = true
    t.Visible = true
    table.insert(menuDrawings, t)
    return t
end

local function menuRect(size, pos, color)
    local r = Drawing.new("Square")
    r.Size = size
    r.Position = pos
    r.Color = color or Color3.new(0.15, 0.15, 0.2)
    r.Filled = true
    r.Thickness = 1
    r.Visible = true
    table.insert(menuDrawings, r)
    return r
end

local function buildMenu()
    clearMenu()
    local x, y = 20, 80

    menuRect(Vector2.new(260, 300), Vector2.new(x, y), Color3.fromRGB(20, 20, 28))
    menuRect(Vector2.new(260, 36), Vector2.new(x, y), Color3.fromRGB(30, 30, 42))

    menuText("MMV / MM2 Hub", Vector2.new(x + 12, y + 10), 16, Color3.fromRGB(100, 200, 255))

    y = y + 46
    menuText("--- ESP (Press 1) ---", Vector2.new(x + 12, y), 13, Color3.fromRGB(100, 200, 255))
    y = y + 20
    menuText("Status: " .. (espEnabled and "ON" or "OFF"), Vector2.new(x + 12, y), 14, espEnabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0))

    y = y + 28
    menuText("--- Color (Press 2) ---", Vector2.new(x + 12, y), 13, Color3.fromRGB(100, 200, 255))
    y = y + 20
    menuText("Color: " .. colorNames[colorIndex], Vector2.new(x + 12, y), 14, espColor)

    y = y + 28
    menuText("--- Low GFX (Press 3) ---", Vector2.new(x + 12, y), 13, Color3.fromRGB(100, 200, 255))
    y = y + 20
    menuText("Status: " .. (lowGfxEnabled and "ON" or "OFF"), Vector2.new(x + 12, y), 14, lowGfxEnabled and Color3.new(0, 1, 0) or Color3.new(1, 0.5, 0))

    y = y + 28
    menuText("--- Anti-Fling (Press 4) ---", Vector2.new(x + 12, y), 13, Color3.fromRGB(100, 200, 255))
    y = y + 20
    menuText("Status: " .. (antiFlingEnabled and "ON" or "OFF"), Vector2.new(x + 12, y), 14, antiFlingEnabled and Color3.new(0, 1, 0) or Color3.new(1, 0.5, 0))

    y = y + 32
    menuText("[F1] Close Menu", Vector2.new(x + 12, y), 12, Color3.fromRGB(120, 120, 120))
end

local function createESP(player)
    if player == LocalPlayer then return end
    if espDrawings[player] then return end

    local nameText = Drawing.new("Text")
    nameText.Size = 14
    nameText.Center = true
    nameText.Outline = true
    nameText.Color = Color3.new(1, 1, 1)
    nameText.Visible = false

    local hpText = Drawing.new("Text")
    hpText.Size = 12
    hpText.Center = true
    hpText.Outline = true
    hpText.Color = Color3.new(0, 1, 0)
    hpText.Visible = false

    local boxOutline = Drawing.new("Square")
    boxOutline.Thickness = 3
    boxOutline.Filled = false
    boxOutline.Color = Color3.new(0, 0, 0)
    boxOutline.Visible = false

    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Visible = false

    espDrawings[player] = {
        name = nameText,
        hp = hpText,
        box = box,
        boxOutline = boxOutline,
    }
end

local function removeESP(player)
    local d = espDrawings[player]
    if d then
        pcall(function() d.name:Remove() end)
        pcall(function() d.hp:Remove() end)
        pcall(function() d.box:Remove() end)
        pcall(function() d.boxOutline:Remove() end)
        espDrawings[player] = nil
    end
end

local function hideESP(d)
    d.name.Visible = false
    d.hp.Visible = false
    d.box.Visible = false
    d.boxOutline.Visible = false
end

local function updateESP()
    local Camera = getCam()
    if not Camera then return end

    for player, d in pairs(espDrawings) do
        pcall(function()
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")

            if not espEnabled or not hum or not root or not head or hum.Health <= 0 then
                hideESP(d)
                return
            end

            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)

            if not onScreen then
                hideESP(d)
                return
            end

            local top = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local bot = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
            local h = math.abs(top.Y - bot.Y)
            local w = h / 2
            local x, y = pos.X, pos.Y

            d.box.Size = Vector2.new(w, h)
            d.box.Position = Vector2.new(x - w / 2, y - h / 2)
            d.box.Color = espColor
            d.box.Visible = true

            d.boxOutline.Size = Vector2.new(w, h)
            d.boxOutline.Position = Vector2.new(x - w / 2, y - h / 2)
            d.boxOutline.Visible = true

            d.name.Position = Vector2.new(x, y - h / 2 - 16)
            d.name.Text = player.Name
            d.name.Visible = true

            local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            d.hp.Position = Vector2.new(x, y + h / 2 + 2)
            d.hp.Text = math.floor(hum.Health) .. " HP"
            d.hp.Color = Color3.new(1 - pct, pct, 0)
            d.hp.Visible = true
        end)
    end
end

local function scanPlayers()
    local ok, children = pcall(function() return Players:GetChildren() end)
    if ok and children then
        for i = 1, #children do
            local player = children[i]
            if player ~= LocalPlayer and not espDrawings[player] then
                createESP(player)
            end
        end
    end
    for player, _ in pairs(espDrawings) do
        if not player.Parent then
            removeESP(player)
        end
    end
end

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        menuOpen = not menuOpen
        if menuOpen then buildMenu() else clearMenu() end
    elseif input.KeyCode == Enum.KeyCode.One then
        espEnabled = not espEnabled
        if menuOpen then buildMenu() end
    elseif input.KeyCode == Enum.KeyCode.Two then
        colorIndex = colorIndex + 1
        if colorIndex > #colors then colorIndex = 1 end
        espColor = colors[colorIndex]
        if menuOpen then buildMenu() end
    elseif input.KeyCode == Enum.KeyCode.Three then
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
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end
        if menuOpen then buildMenu() end
    elseif input.KeyCode == Enum.KeyCode.Four then
        antiFlingEnabled = not antiFlingEnabled
        if menuOpen then buildMenu() end
    end
end)

local scanTimer = 0

RunService.RenderStepped:Connect(function(dt)
    scanTimer = scanTimer + dt
    if scanTimer > 2 then
        scanTimer = 0
        scanPlayers()
    end

    updateESP()

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
end)

buildMenu()
print("[MMV Hub] Loaded! F1=Menu 1=ESP 2=Color 3=GFX 4=AntiFling")
