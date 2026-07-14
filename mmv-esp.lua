
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local menuOpen = true
local espEnabled = true
local lowGfxEnabled = false
local antiFlingEnabled = false
local roleESP = true
local menuDrawings = {}
local espDrawings = {}

local menuX, menuY = 20, 80
local dragging = false
local dragStart = Vector2.new(0, 0)

local function getCam()
    local ok, cam = pcall(function() return workspace.CurrentCamera end)
    return ok and cam or nil
end

local function getMouse()
    local ok, pos = pcall(function() return UIS:GetMouseLocation() end)
    return ok and pos or Vector2.new(0, 0)
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

local function getRole(player)
    local role = "Innocent"
    pcall(function()
        local char = player.Character
        if not char then return end
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name:lower()
                if name:find("knife") or name:find("blade") or name:find("murder") or name:find("kill") then
                    role = "Murderer"
                    return
                elseif name:find("gun") or name:find("shoot") or name:find("sheriff") or name:find("revolver") then
                    role = "Sheriff"
                    return
                end
            end
        end
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    local name = tool.Name:lower()
                    if name:find("knife") or name:find("blade") or name:find("murder") or name:find("kill") then
                        role = "Murderer"
                        return
                    elseif name:find("gun") or name:find("shoot") or name:find("sheriff") or name:find("revolver") then
                        role = "Sheriff"
                        return
                    end
                end
            end
        end
        pcall(function()
            local leaderstats = player:FindFirstChild("leaderstats")
            if leaderstats then
                local roleStat = leaderstats:FindFirstChild("Role") or leaderstats:FindFirstChild("role") or leaderstats:FindFirstChild("Team")
                if roleStat then
                    local val = tostring(roleStat.Value):lower()
                    if val:find("murder") then
                        role = "Murderer"
                    elseif val:find("sheriff") or val:find("hero") then
                        role = "Sheriff"
                    end
                end
            end
        end)
        pcall(function()
            local attributes = player:GetAttributes()
            for key, val in pairs(attributes) do
                local str = tostring(val):lower()
                local k = key:lower()
                if k:find("role") or k:find("team") then
                    if str:find("murder") then
                        role = "Murderer"
                    elseif str:find("sheriff") or str:find("hero") then
                        role = "Sheriff"
                    end
                end
            end
        end)
    end)
    return role
end

local function getRoleColor(role)
    if role == "Murderer" then
        return Color3.new(1, 0, 0)
    elseif role == "Sheriff" then
        return Color3.new(0, 0.4, 1)
    else
        return Color3.new(0, 1, 0)
    end
end

local function buildMenu()
    clearMenu()
    local x, y = menuX, menuY
    menuRect(Vector2.new(260, 360), Vector2.new(x, y), Color3.fromRGB(20, 20, 28))
    menuRect(Vector2.new(260, 36), Vector2.new(x, y), Color3.fromRGB(30, 30, 42))
    menuText("MMV / MM2 Hub", Vector2.new(x + 12, y + 10), 16, Color3.fromRGB(100, 200, 255))
    menuText("Drag: Hold E + Move Mouse", Vector2.new(x + 12, y + 22), 10, Color3.fromRGB(80, 80, 100))
    y = y + 44
    menuText("--- ESP (Press 1) ---", Vector2.new(x + 12, y), 13, Color3.fromRGB(100, 200, 255))
    y = y + 18
    menuText("Status: " .. (espEnabled and "ON" or "OFF"), Vector2.new(x + 12, y), 14, espEnabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0))
    y = y + 24
    menuText("--- Role ESP (Press 5) ---", Vector2.new(x + 12, y), 13, Color3.fromRGB(100, 200, 255))
    y = y + 18
    menuText("Status: " .. (roleESP and "ON" or "OFF"), Vector2.new(x + 12, y), 14, roleESP and Color3.new(0, 1, 0) or Color3.new(1, 0, 0))
    y = y + 14
    menuText("Innocent=Green Sheriff=Blue Murderer=Red", Vector2.new(x + 12, y), 10, Color3.fromRGB(100, 100, 100))
    y = y + 22
    menuText("--- Low GFX (Press 3) ---", Vector2.new(x + 12, y), 13, Color3.fromRGB(100, 200, 255))
    y = y + 18
    menuText("Status: " .. (lowGfxEnabled and "ON" or "OFF"), Vector2.new(x + 12, y), 14, lowGfxEnabled and Color3.new(0, 1, 0) or Color3.new(1, 0.5, 0))
    y = y + 24
    menuText("--- Anti-Fling (Press 4) ---", Vector2.new(x + 12, y), 13, Color3.fromRGB(100, 200, 255))
    y = y + 18
    menuText("Status: " .. (antiFlingEnabled and "ON" or "OFF"), Vector2.new(x + 12, y), 14, antiFlingEnabled and Color3.new(0, 1, 0) or Color3.new(1, 0.5, 0))
    y = y + 24
    menuText("--- Reset (Press 6) ---", Vector2.new(x + 12, y), 13, Color3.fromRGB(100, 200, 255))
    y = y + 14
    menuText("[F1] Close | [E+Mouse] Drag", Vector2.new(x + 12, y), 11, Color3.fromRGB(80, 80, 100))
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
    local roleText = Drawing.new("Text")
    roleText.Size = 12
    roleText.Center = true
    roleText.Outline = true
    roleText.Color = Color3.new(0, 1, 0)
    roleText.Visible = false
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
        role = roleText,
        hp = hpText,
        box = box,
        boxOutline = boxOutline,
    }
end

local function removeESP(player)
    local d = espDrawings[player]
    if d then
        pcall(function() d.name:Remove() end)
        pcall(function() d.role:Remove() end)
        pcall(function() d.hp:Remove() end)
        pcall(function() d.box:Remove() end)
        pcall(function() d.boxOutline:Remove() end)
        espDrawings[player] = nil
    end
end

local function hideESP(d)
    d.name.Visible = false
    d.role.Visible = false
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
            local boxColor = Color3.new(1, 1, 1)
            if roleESP then
                local role = getRole(player)
                boxColor = getRoleColor(role)
                d.role.Text = role
                d.role.Color = boxColor
                d.role.Position = Vector2.new(x, y - h / 2 - 28)
                d.role.Visible = true
            else
                d.role.Visible = false
            end
            d.box.Size = Vector2.new(w, h)
            d.box.Position = Vector2.new(x - w / 2, y - h / 2)
            d.box.Color = boxColor
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
    for player, _ in
