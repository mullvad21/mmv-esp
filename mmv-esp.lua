--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

--// MENU STATE
local menuOpen = true
local menuX, menuY = 20, 80
local dragging = false
local dragStart = Vector2.new(0, 0)
local menuDrawings = {}
local buttons = {}
local scrollOffset = 0
local maxScroll = 0

--// FEATURE TOGGLES
local espEnabled = true
local roleESP = true
local tracersEnabled = false
local showDistance = true
local showHealthBar = true
local boxStyle = "Full"
local boxStyles = {"Full", "Corner", "Full"}
local boxStyleIndex = 1
local lowGfxEnabled = false
local antiFlingEnabled = false
local fullbrightEnabled = false
local noFogEnabled = false
local noParticlesEnabled = false
local speedEnabled = false
local speedValue = 16
local jumpEnabled = false
local jumpValue = 50
local noclipEnabled = false
local crosshairEnabled = false
local espRange = 1000

--// DRAWING OBJECTS
local espDrawings = {}
local crosshairDrawings = {}

--// HELPERS
local function getCam()
    local ok, cam = pcall(function() return workspace.CurrentCamera end)
    return ok and cam or nil
end

local function getMouse()
    local ok, pos = pcall(function() return UIS:GetMouseLocation() end)
    return ok and pos or Vector2.new(0, 0)
end

--// MENU RENDERING
local function clearMenu()
    for _, obj in pairs(menuDrawings) do
        pcall(function() obj:Remove() end)
    end
    menuDrawings = {}
    buttons = {}
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

local function addToggle(text, x, y, w, h, state, callback)
    local color = state and Color3.fromRGB(30, 100, 30) or Color3.fromRGB(100, 30, 30)
    menuRect(Vector2.new(w, h), Vector2.new(x, y), color)
    local label = menuText(text .. (state and ": ON" or ": OFF"), Vector2.new(x + 10, y + 8), 14, Color3.new(1, 1, 1))
    table.insert(buttons, { x = x, y = y, w = w, h = h, callback = callback })
    return y + h + 6
end

local function addSlider(text, x, y, w, h, value, minVal, maxVal, callback)
    menuRect(Vector2.new(w, h), Vector2.new(x, y), Color3.fromRGB(40, 40, 52))
    menuText(text .. ": " .. value, Vector2.new(x + 10, y + 8), 14, Color3.new(1, 1, 1))
    local pct = (value - minVal) / (maxVal - minVal)
    menuRect(Vector2.new(w - 20, 6), Vector2.new(x + 10, y + h - 12), Color3.fromRGB(60, 60, 70))
    menuRect(Vector2.new((w - 20) * pct, 6), Vector2.new(x + 10, y + h - 12), Color3.fromRGB(100, 200, 255))
    table.insert(buttons, { x = x, y = y, w = w, h = h, callback = callback })
    return y + h + 6
end

local function addSection(text, x, y)
    menuRect(Vector2.new(270, 1), Vector2.new(x, y + 2), Color3.fromRGB(50, 50, 60))
    menuText(text, Vector2.new(x + 10, y + 8), 14, Color3.fromRGB(100, 200, 255))
    return y + 28
end

local function addButton(text, x, y, w, h, color, callback)
    menuRect(Vector2.new(w, h), Vector2.new(x, y), color or Color3.fromRGB(40, 40, 52))
    menuText(text, Vector2.new(x + 10, y + 8), 14, Color3.new(1, 1, 1))
    table.insert(buttons, { x = x, y = y, w = w, h = h, callback = callback })
    return y + h + 6
end

--// ROLE DETECTION
local function getRole(player)
    local role = "Innocent"
    pcall(function()
        local char = player.Character
        if not char then return end
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name:lower()
                if name:find("knife") or name:find("blade") or name:find("murder") or name:find("kill") then
                    role = "Murderer" return
                elseif name:find("gun") or name:find("shoot") or name:find("sheriff") or name:find("revolver") then
                    role = "Sheriff" return
                end
            end
        end
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    local name = tool.Name:lower()
                    if name:find("knife") or name:find("blade") or name:find("murder") or name:find("kill") then
                        role = "Murderer" return
                    elseif name:find("gun") or name:find("shoot") or name:find("sheriff") or name:find("revolver") then
                        role = "Sheriff" return
                    end
                end
            end
        end
        pcall(function()
            local ls = player:FindFirstChild("leaderstats")
            if ls then
                local r = ls:FindFirstChild("Role") or ls:FindFirstChild("role") or ls:FindFirstChild("Team")
                if r then
                    local v = tostring(r.Value):lower()
                    if v:find("murder") then role = "Murderer"
                    elseif v:find("sheriff") or v:find("hero") then role = "Sheriff"
                    end
                end
            end
        end)
        pcall(function()
            for k, v in pairs(player:GetAttributes()) do
                local s = tostring(v):lower()
                if k:lower():find("role") or k:lower():find("team") then
                    if s:find("murder") then role = "Murderer"
                    elseif s:find("sheriff") or s:find("hero") then role = "Sheriff"
                    end
                end
            end
        end)
    end)
    return role
end

local function getRoleColor(role)
    if role == "Murderer" then return Color3.new(1, 0, 0)
    elseif role == "Sheriff" then return Color3.new(0, 0.4, 1)
    else return Color3.new(0, 1, 0) end
end

--// MENU BUILDER
local function buildMenu()
    clearMenu()
    local x, y = menuX, menuY
    menuRect(Vector2.new(280, 400), Vector2.new(x, y), Color3.fromRGB(18, 18, 26))
    menuRect(Vector2.new(280, 40), Vector2.new(x, y), Color3.fromRGB(28, 28, 40))
    menuText("MMV / MM2 Hub v2", Vector2.new(x + 12, y + 8), 16, Color3.fromRGB(100, 200, 255))
    menuText("[F1] Close | [E+Mouse] Drag", Vector2.new(x + 12, y + 24), 10, Color3.fromRGB(80, 80, 100))
    y = y + 48

    y = addSection("ESP", x, y)
    y = addToggle("ESP Boxes", x + 5, y, 270, 30, espEnabled, function() espEnabled = not espEnabled buildMenu() end)
    y = addToggle("Role ESP", x + 5, y, 270, 30, roleESP, function() roleESP = not roleESP buildMenu() end)
    y = addToggle("Tracers", x + 5, y, 270, 30, tracersEnabled, function() tracersEnabled = not tracersEnabled buildMenu() end)
    y = addToggle("Distance", x + 5, y, 270, 30, showDistance, function() showDistance = not showDistance buildMenu() end)
    y = addToggle("Health Bar", x + 5, y, 270, 30, showHealthBar, function() showHealthBar = not showHealthBar buildMenu() end)
    y = addToggle("Crosshair", x + 5, y, 270, 30, crosshairEnabled, function() crosshairEnabled = not crosshairEnabled if not crosshairEnabled then for _, d in pairs(crosshairDrawings) do pcall(function() d:Remove() end) end crosshairDrawings = {} end buildMenu() end)

    y = addSection("World", x, y)
    y = addToggle("Fullbright", x + 5, y, 270, 30, fullbrightEnabled, function()
        fullbrightEnabled = not fullbrightEnabled
        if fullbrightEnabled then Lighting.Brightness = 2 Lighting.ClockTime = 14 Lighting.FogEnd = 100000 Lighting.GlobalShadows = false Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        else Lighting.Brightness = 1 Lighting.GlobalShadows = true Lighting.Ambient = Color3.new(0, 0, 0) end buildMenu()
    end)
    y = addToggle("No Fog", x + 5, y, 270, 30, noFogEnabled, function()
        noFogEnabled = not noFogEnabled
        if noFogEnabled then Lighting.FogEnd = 999999999 Lighting.FogStart = 0 Lighting.FogColor = Color3.new(1, 1, 1)
        else Lighting.FogEnd = 100000 end buildMenu()
    end)
    y = addToggle("No Particles", x + 5, y, 270, 30, noParticlesEnabled, function()
        noParticlesEnabled = not noParticlesEnabled
        pcall(function() for _, v in pairs(workspace:GetDescendants()) do if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then v.Enabled = not noParticlesEnabled end end end) buildMenu()
    end)
    y = addToggle("Low GFX", x + 5, y, 270, 30, lowGfxEnabled, function()
        lowGfxEnabled = not lowGfxEnabled
        if lowGfxEnabled then settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 pcall(function() for _, v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") then v.Material = Enum.Material.Plastic v.Reflectance = 0 elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end end end)
        else settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end buildMenu()
    end)

    y = addSection("Player", x, y)
    y = addSlider("WalkSpeed", x + 5, y, 270, 36, speedValue, 16, 200, function() speedValue = math.clamp(speedValue + 10, 16, 200) buildMenu() end)
    y = addSlider("JumpPower", x + 5, y, 270, 36, jumpValue, 50, 300, function() jumpValue = math.clamp(jumpValue + 20, 50, 300) buildMenu() end)
    y = addToggle("Speed Hack", x + 5, y, 270, 30, speedEnabled, function() speedEnabled = not speedEnabled if not speedEnabled then pcall(function() LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16 end) end buildMenu() end)
    y = addToggle("Jump Hack", x + 5, y, 270, 30, jumpEnabled, function() jumpEnabled = not jumpEnabled if not jumpEnabled then pcall(function() LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = 50 end) end buildMenu() end)
    y = addToggle("Noclip", x + 5, y, 270, 30, noclipEnabled, function() noclipEnabled = not noclipEnabled buildMenu() end)
    y = addToggle("Anti-Fling", x + 5, y, 270, 30, antiFlingEnabled, function() antiFlingEnabled = not antiFlingEnabled buildMenu() end)

    y = addSection("Misc", x, y)
    y = addButton("Reset Character [6]", x + 5, y, 270, 30, Color3.fromRGB(120, 40, 40), function() pcall(function() LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health = 0 end) end)
    y = addButton("Rejoin Server", x + 5, y, 270, 30, Color3.fromRGB(120, 80, 30), function() pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end) end)
    y = addButton("Server Hop", x + 5, y, 270, 30, Color3.fromRGB(80, 80, 120), function()
        pcall(function()
            local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            for _, server in pairs(servers.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    break
                end
            end
        end)
    end)
end

--// ESP DRAWING
local function createESP(player)
    if player == LocalPlayer then return end
    if espDrawings[player] then return end
    local nameText = Drawing.new("Text") nameText.Size = 14 nameText.Center = true nameText.Outline = true nameText.Color = Color3.new(1, 1, 1) nameText.Visible = false
    local roleText = Drawing.new("Text") roleText.Size = 12 roleText.Center = true roleText.Outline = true roleText.Visible = false
    local distText = Drawing.new("Text") distText.Size = 11 distText.Center = true distText.Outline = true distText.Color = Color3.fromRGB(200, 200, 200) distText.Visible = false
    local hpText = Drawing.new("Text") hpText.Size = 12 hpText.Center = true hpText.Outline = true hpText.Visible = false
    local boxOutline = Drawing.new("Square") boxOutline.Thickness = 3 boxOutline.Filled = false boxOutline.Color = Color3.new(0, 0, 0) boxOutline.Visible = false
    local box = Drawing.new("Square") box.Thickness = 1 box.Filled = false box.Visible = false
    local hpBarBg = Drawing.new("Square") hpBarBg.Size = Vector2.new(4, 50) hpBarBg.Filled = true hpBarBg.Color = Color3.new(0, 0, 0) hpBarBg.Visible = false
    local hpBar = Drawing.new("Square") hpBar.Size = Vector2.new(4, 50) hpBar.Filled = true hpBar.Visible = false
    local tracer = Drawing.new("Line") tracer.Thickness = 1 tracer.Visible = false
    espDrawings[player] = { name = nameText, role = roleText, dist = distText, hp = hpText, box = box, boxOutline = boxOutline, hpBarBg = hpBarBg, hpBar = hpBar, tracer = tracer }
end

local function removeESP(player)
    local d = espDrawings[player]
    if d then for _, v in pairs(d) do pcall(function() v:Remove() end) end espDrawings[player] = nil end
end

local function hideESP(d)
    for _, v in pairs(d) do pcall(function() v.Visible = false end) end
end

local function updateESP()
    local Camera = getCam()
    if not Camera then return end
    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    local viewportSize = Camera.ViewportSize
    for player, d in pairs(espDrawings) do
        pcall(function()
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")
            if not espEnabled or not hum or not root or not head or hum.Health <= 0 then hideESP(d) return end
            local dist = localRoot and (localRoot.Position - root.Position).Magnitude or 0
            if dist > espRange then hideESP(d) return end
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if not onScreen then hideESP(d) return end
            local topPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local botPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
            local h = math.abs(topPos.Y - botPos.Y)
            local w = h / 2
            local x, y = pos.X, pos.Y
            local boxColor = Color3.new(1, 1, 1)
            if roleESP then local role = getRole(player) boxColor = getRoleColor(role) d.role.Text = role d.role.Color = boxColor d.role.Position = Vector2.new(x, y - h / 2 - 38) d.role.Visible = true else d.role.Visible = false end
            d.box.Size = Vector2.new(w, h) d.box.Position = Vector2.new(x - w / 2, y - h / 2) d.box.Color = boxColor d.box.Visible = true
            d.boxOutline.Size = Vector2.new(w, h) d.boxOutline.Position = Vector2.new(x - w / 2, y - h / 2) d.boxOutline.Visible = true
            d.name.Position = Vector2.new(x, y - h / 2 - 24) d.name.Text = player.Name d.name.Color = boxColor d.name.Visible = true
            local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            if showDistance then d.dist.Text = "[" .. math.floor(dist) .. "m]" d.dist.Position = Vector2.new(x, y + h / 2 + 16) d.dist.Visible = true else d.dist.Visible = false end
            if showHealthBar then local barH = h local barY = y - barH / 2 d.hpBarBg.Size = Vector2.new(4, barH) d.hpBarBg.Position = Vector2.new(x - w / 2 - 8, barY) d.hpBarBg.Visible = true d.hpBar.Size = Vector2.new(4, barH * pct) d.hpBar.Position = Vector2.new(x - w / 2 - 8, barY + barH * (1 - pct)) d.hpBar.Color = Color3.new(1 - pct, pct, 0) d.hpBar.Visible = true else d.hpBarBg.Visible = false d.hpBar.Visible = false end
            d.hp.Text = math.floor(hum.Health) .. " HP" d.hp.Color = Color3.new(1 - pct, pct, 0) d.hp.Position = Vector2.new(x, y + h / 2 + 4) d.hp.Visible = true
            if tracersEnabled and localRoot then local lp, ls = Camera:WorldToViewportPoint(localRoot.Position) if ls then d.tracer.From = Vector2.new(viewportSize.X / 2, viewportSize.Y) d.tracer.To = Vector2.new(x, y) d.tracer.Color = boxColor d.tracer.Visible = true else d.tracer.Visible = false end else d.tracer.Visible = false end
        end)
    end
end

--// CROSSHAIR
local function updateCrosshair()
    if not crosshairEnabled then return end
    local Camera = getCam()
    if not Camera then return end
    local vs = Camera.ViewportSize
    local cx, cy = vs.X / 2, vs.Y / 2
    if #crosshairDrawings == 0 then for i = 1, 4 do local line = Drawing.new("Line") line.Thickness = 2 line.Color = Color3.new(1, 1, 1) line.Visible = true table.insert(crosshairDrawings, line) end end
    crosshairDrawings[1].From = Vector2.new(cx - 16, cy) crosshairDrawings[1].To = Vector2.new(cx - 6, cy)
    crosshairDrawings[2].From = Vector2.new(cx + 6, cy) crosshairDrawings[2].To = Vector2.new(cx + 16, cy)
    crosshairDrawings[3].From = Vector2.new(cx, cy - 16) crosshairDrawings[3].To = Vector2.new(cx, cy - 6)
    crosshairDrawings[4].From = Vector2.new(cx, cy + 6) crosshairDrawings[4].To = Vector2.new(cx, cy + 16)
end

--// PLAYER SCANNER
local function scanPlayers()
    local ok, children = pcall(function() return Players:GetChildren() end)
    if ok and children then
        for i = 1, #children do
            local player = children[i]
            if player ~= LocalPlayer and not espDrawings[player] then createESP(player) end
        end
    end
    for player, _ in pairs(espDrawings) do if not player.Parent then removeESP(player) end end
end

--// INPUT
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F1 then menuOpen = not menuOpen if menuOpen then buildMenu() else clearMenu() end
    elseif input.KeyCode == Enum.KeyCode.One then espEnabled = not espEnabled if menuOpen then buildMenu() end
    elseif input.KeyCode == Enum.KeyCode.Two then tracersEnabled = not tracersEnabled if menuOpen then buildMenu() end
    elseif input.KeyCode == Enum.KeyCode.Three then lowGfxEnabled = not lowGfxEnabled if lowGfxEnabled then settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 else settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end if menuOpen then buildMenu() end
    elseif input.KeyCode == Enum.KeyCode.Four then antiFlingEnabled = not antiFlingEnabled if menuOpen then buildMenu() end
    elseif input.KeyCode == Enum.KeyCode.Five then roleESP = not roleESP if menuOpen then buildMenu() end
    elseif input.KeyCode == Enum.KeyCode.Six then pcall(function() LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health = 0 end)
    elseif input.KeyCode == Enum.KeyCode.Seven then fullbrightEnabled = not fullbrightEnabled if fullbrightEnabled then Lighting.Brightness = 2 Lighting.ClockTime = 14 Lighting.FogEnd = 100000 Lighting.GlobalShadows = false Lighting.Ambient = Color3.fromRGB(178, 178, 178) else Lighting.Brightness = 1 Lighting.GlobalShadows = true Lighting.Ambient = Color3.new(0, 0, 0) end if menuOpen then buildMenu() end
    elseif input.KeyCode == Enum.KeyCode.Eight then noclipEnabled = not noclipEnabled if menuOpen then buildMenu() end
    elseif input.KeyCode == Enum.KeyCode.Nine then speedEnabled = not speedEnabled if not speedEnabled then pcall(function() LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16 end) end if menuOpen then buildMenu() end
    elseif input.KeyCode == Enum.KeyCode.Zero then jumpEnabled = not jumpEnabled if not jumpEnabled then pcall(function() LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = 50 end) end if menuOpen then buildMenu() end
    elseif input.KeyCode == Enum.KeyCode.P then speedValue = math.clamp(speedValue + 10, 16, 200) if menuOpen then buildMenu() end
    elseif input.KeyCode == Enum.KeyCode.O then speedValue = math.clamp(speedValue - 10, 16, 200) if menuOpen then buildMenu() end
    elseif input.KeyCode == Enum.KeyCode.L then jumpValue = math.clamp(jumpValue + 20, 50, 300) if menuOpen then buildMenu() end
    elseif input.KeyCode == Enum.KeyCode.K then jumpValue = math.clamp(jumpValue - 20, 50, 300) if menuOpen then buildMenu() end
    elseif input.KeyCode == Enum.KeyCode.E then dragging = true dragStart = getMouse()
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then dragging = false end
end)

--// MAIN LOOP
local scanTimer = 0
RunService.RenderStepped:Connect(function(dt)
    if dragging then local mouse = getMouse() menuX = menuX + (mouse.X - dragStart.X) menuY = menuY + (mouse.Y - dragStart.Y) dragStart = mouse if menuOpen then buildMenu() end end
    scanTimer = scanTimer + dt
    if scanTimer > 2 then scanTimer = 0 scanPlayers() end
    updateESP()
    updateCrosshair()
    if speedEnabled then pcall(function() local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if hum then hum.WalkSpeed = speedValue end end) end
    if jumpEnabled then pcall(function() local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if hum then hum.JumpPower = jumpValue end end) end
    if noclipEnabled then pcall(function() local char = LocalPlayer.Character if char then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end end) end
    if antiFlingEnabled then pcall(function() local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if root then root.AssemblyAngularVelocity = Vector3.new(0, 0, 0) root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, math.clamp(root.AssemblyLinearVelocity.Y, -50, 50), root.AssemblyLinearVelocity.Z) end end) end
end)

buildMenu()
print("[MMV Hub v2] Loaded!")
print("F1=Menu 1=ESP 2=Tracers 3=GFX 4=AntiFling 5=Role 6=Reset 7=Bright 8=Noclip 9=Speed 0=Jump P/O=Speed+/- L/K=Jump+/- E=Drag")
