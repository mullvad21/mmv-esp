local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local menuOpen = false
local espEnabled = true
local espColor = Color3.new(1, 0, 0)
local antiFlingEnabled = false
local lowGfxEnabled = false
local menuObjects = {}
local espObjects = {}
local playerList = {}

local function getCam()
    local ok, cam = pcall(function() return workspace.CurrentCamera end)
    return ok and cam or nil
end

local function getMouse()
    local ok, pos = pcall(function() return UIS:GetMouseLocation() end)
    return ok and pos or Vector2.new(0, 0)
end

local function clearMenu()
    for _, obj in pairs(menuObjects) do
        pcall(function() obj:Remove() end)
    end
    menuObjects = {}
end

local function makeText(text, pos, size, color, parent)
    local t = Drawing.new("Text")
    t.Text = text
    t.Position = pos
    t.Size = size or 14
    t.Color = color or Color3.new(1, 1, 1)
    t.Outline = true
    t.Visible = true
    table.insert(menuObjects, t)
    return t
end

local function makeRect(size, pos, color, filled, parent)
    local r = Drawing.new("Square")
    r.Size = size
    r.Position = pos
    r.Color = color or Color3.new(0.15, 0.15, 0.2)
    r.Filled = filled ~= false
    r.Thickness = 1
    r.Visible = true
    table.insert(menuObjects, r)
    return r
end

local menuX = 20
local menuY = 80
local menuW = 260
local menuH = 380
local buttons = {}

local function buildMenu()
    clearMenu()
    buttons = {}

    makeRect(Vector2.new(menuW, menuH), Vector2.new(menuX, menuY), Color3.fromRGB(20, 20, 28))
    makeRect(Vector2.new(menuW, 38), Vector2.new(menuX, menuY), Color3.fromRGB(30, 30, 42))
    makeText("MMV / MM2 Hub", Vector2.new(menuX + 15, menuY + 10), 18, Color3.fromRGB(100, 200, 255))
    makeText("[F1] Toggle Menu", Vector2.new(menuX + menuW - 120, menuY + 12), 12, Color3.fromRGB(120, 120, 120))

    local function addSection(text, y)
        makeText(text, Vector2.new(menuX + 15, menuY + y), 14, Color3.fromRGB(100, 200, 255))
        return y + 22
    end

    local function addButton(text, y, color)
        local btnRect = makeRect(Vector2.new(menuW - 20, 32), Vector2.new(menuX + 10, menuY + y), color or Color3.fromRGB(40, 40, 52))
        local btnText = makeText(text, Vector2.new(menuX + 20, menuY + y + 8), 14, Color3.new(1, 1, 1))
        table.insert(buttons, {
            rect = btnRect,
            text = btnText,
            x = menuX + 10,
            y = menuY + y,
            w = menuW - 20,
            h = 32,
            label = text,
        })
        return y + 38
    end

    local y = 48
    y = addSection("--- ESP ---", y)
    y = addButton(espEnabled and "ESP: ON" or "ESP: OFF", y, espEnabled and Color3.fromRGB(30, 100, 30) or Color3.fromRGB(100, 30, 30))

    y = addSection("--- Colors ---", y)
    y = addButton("Red", y, Color3.fromRGB(130, 30, 30))
    y = addButton("Green", y, Color3.fromRGB(30, 130, 30))
    y = addButton("Blue", y, Color3.fromRGB(30, 30, 130))
    y = addButton("White", y, Color3.fromRGB(130, 130, 130))

    y = addSection("--- Misc ---", y)
    y = addButton(lowGfxEnabled and "Low GFX: ON" or "Low GFX: OFF", y, lowGfxEnabled and Color3.fromRGB(30, 120, 30) or Color3.fromRGB(100, 60, 30))

    y = addSection("--- Anti Fling ---", y)
    y = addButton(antiFlingEnabled and "Anti-Fling: ON" or "Anti-Fling: OFF", y, antiFlingEnabled and Color3.fromRGB(30, 120, 30) or Color3.fromRGB(100, 60, 30))
end

local function handleClick(mx, my)
    for _, btn in pairs(buttons) do
        if mx >= btn.x and mx <= btn.x + btn.w and my >= btn.y and my <= btn.y + btn.h then
            local label = btn.label

            if label:find("ESP:") then
                espEnabled = not espEnabled
                buildMenu()
            elseif label == "Red" then
                espColor = Color3.new(1, 0, 0)
                buildMenu()
            elseif label == "Green" then
                espColor = Color3.new(0, 1, 0)
                buildMenu()
            elseif label == "Blue" then
                espColor = Color3.new(0, 0, 1)
                buildMenu()
            elseif label == "White" then
                espColor = Color3.new(1, 1, 1)
                buildMenu()
            elseif label:find("Low GFX") then
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
                buildMenu()
            elseif label:find("Anti-Fling") then
                antiFlingEnabled = not antiFlingEnabled
                buildMenu()
            end
            return true
        end
    end
    return false
end

local espDrawings = {}

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
                pcall(function()
                    player.CharacterRemoving:Connect(function()
                        if espDrawings[player] then hideESP(espDrawings[player]) end
                    end)
                end)
            end
        end
    end
end

local function removePlayerESP()
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
        if menuOpen then
            buildMenu()
        else
            clearMenu()
        end
    end
end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and menuOpen then
        local mouse = getMouse()
        handleClick(mouse.X, mouse.Y)
    end
end)

local scanTimer = 0

RunService.RenderStepped:Connect(function(dt)
    scanTimer = scanTimer + dt
    if scanTimer > 2 then
        scanTimer = 0
        scanPlayers()
        removePlayerESP()
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

print("[MMV Hub] Loaded! Press F1 to open menu")
