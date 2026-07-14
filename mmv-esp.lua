--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

--// FEATURE TOGGLES
local espEnabled = true
local roleESP = true
local tracersEnabled = false
local showDistance = true
local showHealthBar = true
local crosshairEnabled = false
local fullbrightEnabled = false
local noFogEnabled = false
local noParticlesEnabled = false
local lowGfxEnabled = false
local speedEnabled = false
local speedValue = 16
local jumpEnabled = false
local jumpValue = 50
local noclipEnabled = false
local antiFlingEnabled = false

--// MENU STATE
local menuOpen = true
local menuX, menuY = 20, 80
local menuW = 280
local menuItems = {}
local menuDrawings = {}
local espCache = {}
local crosshairLines = {}

--// INPUT STATE
local prevMouse = false
local prevKeys = {}
local prevF1 = false

local function isDown(k)
    local ok, v = pcall(function() return UIS:IsKeyDown(k) end)
    return ok and v
end

local function isMouse1()
    local ok, v = pcall(function() return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) end)
    return ok and v
end

local function mousePos()
    local ok, v = pcall(function() return UIS:GetMouseLocation() end)
    return ok and v or Vector2.new(0, 0)
end

--// DRAW HELPERS
local function dRect(x, y, w, h, color, filled)
    local s = Drawing.new("Square")
    s.Position = Vector2.new(x, y)
    s.Size = Vector2.new(w, h)
    s.Color = color or Color3.fromRGB(20, 20, 28)
    s.Filled = filled ~= false
    s.Thickness = 1
    s.Visible = true
    table.insert(menuDrawings, s)
    return s
end

local function dText(x, y, text, size, color)
    local t = Drawing.new("Text")
    t.Position = Vector2.new(x, y)
    t.Text = text
    t.Size = size or 13
    t.Color = color or Color3.new(1, 1, 1)
    t.Outline = true
    t.Visible = true
    table.insert(menuDrawings, t)
    return t
end

local function clearMenu()
    for i = #menuDrawings, 1, -1 do
        pcall(function() menuDrawings[i]:Remove() end)
        menuDrawings[i] = nil
    end
    menuItems = {}
end

--// MENU BUILDERS
local function addToggle(x, y, w, text, val, callback)
    local col = val and Color3.fromRGB(25, 80, 25) or Color3.fromRGB(80, 25, 25)
    dRect(x, y, w, 28, col)
    dText(x + 10, y + 7, text .. (val and "  [ON]" or "  [OFF]"), 13, Color3.new(1, 1, 1))
    table.insert(menuItems, { x = x, y = y, w = w, h = 28, cb = callback })
    return y + 32
end

local function addAction(x, y, w, text, color, callback)
    dRect(x, y, w, 28, color or Color3.fromRGB(40, 40, 55))
    dText(x + 10, y + 7, text, 13, Color3.new(1, 1, 1))
    table.insert(menuItems, { x = x, y = y, w = w, h = 28, cb = callback })
    return y + 32
end

local function addLabel(x, y, text, color)
    dRect(x, y, menuW - 10, 1, Color3.fromRGB(40, 40, 60))
    dText(x + 4, y + 6, ">> " .. text, 12, color or Color3.fromRGB(80, 180, 255))
    return y + 20
end

local function buildMenu()
    clearMenu()
    local x, y = menuX + 5, menuY
    dRect(menuX, menuY, menuW, 32, Color3.fromRGB(22, 22, 32))
    dText(menuX + 8, menuY + 8, "MMV / MM2 Hub v5", 15, Color3.fromRGB(80, 180, 255))
    dText(menuX + 8, menuY + 22, "Click buttons | E+Mouse=Drag", 9, Color3.fromRGB(100, 100, 120))
    y = y + 38

    y = addLabel(x, y, "ESP")
    y = addToggle(x, y, menuW - 10, "ESP Boxes", espEnabled, function() espEnabled = not espEnabled end)
    y = addToggle(x, y, menuW - 10, "Role Colors", roleESP, function() roleESP = not roleESP end)
    y = addToggle(x, y, menuW - 10, "Tracers", tracersEnabled, function() tracersEnabled = not tracersEnabled end)
    y = addToggle(x, y, menuW - 10, "Distance", showDistance, function() showDistance = not showDistance end)
    y = addToggle(x, y, menuW - 10, "Health Bar", showHealthBar, function() showHealthBar = not showHealthBar end)
    y = addToggle(x, y, menuW - 10, "Crosshair", crosshairEnabled, function()
        crosshairEnabled = not crosshairEnabled
        if not crosshairEnabled then for _, l in pairs(crosshairLines) do pcall(function() l:Remove() end) end crosshairLines = {} end
    end)

    y = addLabel(x, y, "WORLD")
    y = addToggle(x, y, menuW - 10, "Fullbright", fullbrightEnabled, function()
        fullbrightEnabled = not fullbrightEnabled
        if fullbrightEnabled then Lighting.Brightness = 2 Lighting.ClockTime = 14 Lighting.FogEnd = 999999 Lighting.GlobalShadows = false Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        else Lighting.Brightness = 1 Lighting.GlobalShadows = true Lighting.Ambient = Color3.new(0, 0, 0) Lighting.FogEnd = 100000 end
    end)
    y = addToggle(x, y, menuW - 10, "No Fog", noFogEnabled, function()
        noFogEnabled = not noFogEnabled
        Lighting.FogEnd = noFogEnabled and 999999999 or 100000
    end)
    y = addToggle(x, y, menuW - 10, "No Particles", noParticlesEnabled, function()
        noParticlesEnabled = not noParticlesEnabled
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then v.Enabled = not noParticlesEnabled end
            end
        end)
    end)
    y = addToggle(x, y, menuW - 10, "Low GFX", lowGfxEnabled, function()
        lowGfxEnabled = not lowGfxEnabled
        if lowGfxEnabled then settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        else settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end
    end)

    y = addLabel(x, y, "PLAYER")
    y = addToggle(x, y, menuW - 10, "Speed [" .. speedValue .. "]", speedEnabled, function()
        speedEnabled = not speedEnabled
        if not speedEnabled then pcall(function() LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16 end) end
    end)
    y = addToggle(x, y, menuW - 10, "Jump [" .. jumpValue .. "]", jumpEnabled, function()
        jumpEnabled = not jumpEnabled
        if not jumpEnabled then pcall(function() LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = 50 end) end
    end)
    y = addAction(x, y, menuW - 10, "Speed +10", Color3.fromRGB(40, 50, 70), function() speedValue = math.clamp(speedValue + 10, 16, 200) end)
    y = addAction(x, y, menuW - 10, "Speed -10", Color3.fromRGB(40, 50, 70), function() speedValue = math.clamp(speedValue - 10, 16, 200) end)
    y = addAction(x, y, menuW - 10, "Jump +20", Color3.fromRGB(40, 50, 70), function() jumpValue = math.clamp(jumpValue + 20, 50, 300) end)
    y = addAction(x, y, menuW - 10, "Jump -20", Color3.fromRGB(40, 50, 70), function() jumpValue = math.clamp(jumpValue - 20, 50, 300) end)
    y = addToggle(x, y, menuW - 10, "Noclip", noclipEnabled, function() noclipEnabled = not noclipEnabled end)
    y = addToggle(x, y, menuW - 10, "Anti-Fling", antiFlingEnabled, function() antiFlingEnabled = not antiFlingEnabled end)

    y = addLabel(x, y, "MISC")
    y = addAction(x, y, menuW - 10, "Reset Character", Color3.fromRGB(100, 30, 30), function() pcall(function() LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health = 0 end) end)
    y = addAction(x, y, menuW - 10, "Rejoin Server", Color3.fromRGB(90, 60, 20), function() pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end) end)
    y = addAction(x, y, menuW - 10, "Server Hop", Color3.fromRGB(50, 50, 90), function()
        pcall(function()
            local data = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            for _, s in pairs(data.data) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                    break
                end
            end
        end)
    end)
end

--// ROLE DETECTION
local function getRole(plr)
    local role = "Innocent"
    pcall(function()
        local char = plr.Character
        if not char then return end
        local checkTools = function(container)
            for _, t in pairs(container:GetChildren()) do
                if t:IsA("Tool") then
                    local n = t.Name:lower()
                    if n:find("knife") or n:find("blade") or n:find("murder") or n:find("kill") or n:find("tactical") then role = "Murderer" return true end
                    if n:find("gun") or n:find("shoot") or n:find("sheriff") or n:find("revolver") or n:find("deagle") then role = "Sheriff" return true end
                end
            end
        end
        if checkTools(char) then return end
        local bp = plr:FindFirstChild("Backpack")
        if bp and checkTools(bp) then return end
        pcall(function()
            local ls = plr:FindFirstChild("leaderstats")
            if ls then
                for _, name in pairs({"Role", "role", "Team", "team"}) do
                    local v = ls:FindFirstChild(name)
                    if v then
                        local s = tostring(v.Value):lower()
                        if s:find("murder") then role = "Murderer" return end
                        if s:find("sheriff") or s:find("hero") then role = "Sheriff" return end
                    end
                end
            end
        end)
        pcall(function()
            for k, v in pairs(plr:GetAttributes()) do
                local s = tostring(v):lower()
                local kl = k:lower()
                if kl:find("role") or kl:find("team") then
                    if s:find("murder") then role = "Murderer" return end
                    if s:find("sheriff") or s:find("hero") then role = "Sheriff" return end
                end
            end
        end)
    end)
    return role
end

local function roleColor(role)
    if role == "Murderer" then return Color3.new(1, 0.1, 0.1) end
    if role == "Sheriff" then return Color3.new(0.2, 0.5, 1) end
    return Color3.new(0.1, 1, 0.1)
end

--// ESP
local function createPlayerESP(plr)
    if plr == LocalPlayer or espCache[plr] then return end
    espCache[plr] = {
        box = Drawing.new("Square"),
        boxO = Drawing.new("Square"),
        name = Drawing.new("Text"),
        role = Drawing.new("Text"),
        dist = Drawing.new("Text"),
        hp = Drawing.new("Text"),
        hpBg = Drawing.new("Square"),
        hpBar = Drawing.new("Square"),
        tracer = Drawing.new("Line"),
    }
    local d = espCache[plr]
    d.box.Thickness = 1 d.box.Filled = false d.box.Visible = false
    d.boxO.Thickness = 4 d.boxO.Filled = false d.boxO.Color = Color3.new(0, 0, 0) d.boxO.Visible = false
    d.name.Size = 14 d.name.Center = true d.name.Outline = true d.name.Visible = false
    d.role.Size = 12 d.role.Center = true d.role.Outline = true d.role.Visible = false
    d.dist.Size = 11 d.dist.Center = true d.dist.Outline = true d.dist.Visible = false
    d.hp.Size = 11 d.hp.Center = true d.hp.Outline = true d.hp.Visible = false
    d.hpBg.Filled = true d.hpBg.Color = Color3.new(0, 0, 0) d.hpBg.Visible = false
    d.hpBar.Filled = true d.hpBar.Visible = false
    d.tracer.Thickness = 1 d.tracer.Visible = false
end

local function hideESP(d)
    d.box.Visible = false d.boxO.Visible = false d.name.Visible = false
    d.role.Visible = false d.dist.Visible = false
    d.hp.Visible = false d.hpBg.Visible = false d.hpBar.Visible = false
    d.tracer.Visible = false
end

local function updateESP()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local lRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local vs = cam.ViewportSize

    for plr, d in pairs(espCache) do
        pcall(function()
            if not plr.Parent then for _, o in pairs(d) do pcall(function() o:Remove() end) end espCache[plr] = nil return end
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")
            if not espEnabled or not hum or not root or not head or hum.Health <= 0 then hideESP(d) return end
            local dist = lRoot and (lRoot.Position - root.Position).Magnitude or 0
            local pos, onScr = cam:WorldToViewportPoint(root.Position)
            if not onScr then hideESP(d) return end
            local topP = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local botP = cam:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
            local bh = math.abs(topP.Y - botP.Y)
            local bw = bh / 2
            local cx, cy = pos.X, pos.Y
            local col = roleESP and roleColor(getRole(plr)) or Color3.new(1, 1, 1)

            d.box.Size = Vector2.new(bw, bh) d.box.Position = Vector2.new(cx - bw/2, cy - bh/2) d.box.Color = col d.box.Visible = true
            d.boxO.Size = Vector2.new(bw, bh) d.boxO.Position = Vector2.new(cx - bw/2, cy - bh/2) d.boxO.Visible = true
            d.name.Text = plr.Name d.name.Position = Vector2.new(cx, cy - bh/2 - 20) d.name.Color = col d.name.Visible = true

            if roleESP then
                local r = getRole(plr)
                d.role.Text = r d.role.Position = Vector2.new(cx, cy - bh/2 - 34) d.role.Color = roleColor(r) d.role.Visible = true
            else d.role.Visible = false end

            if showDistance then
                d.dist.Text = math.floor(dist) .. "m"
                d.dist.Position = Vector2.new(cx, cy + bh/2 + 14)
                d.dist.Visible = true
            else d.dist.Visible = false end

            local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            if showHealthBar then
                d.hpBg.Size = Vector2.new(3, bh) d.hpBg.Position = Vector2.new(cx - bw/2 - 7, cy - bh/2) d.hpBg.Visible = true
                d.hpBar.Size = Vector2.new(3, bh * pct) d.hpBar.Position = Vector2.new(cx - bw/2 - 7, cy - bh/2 + bh * (1 - pct)) d.hpBar.Color = Color3.new(1 - pct, pct, 0) d.hpBar.Visible = true
                d.hp.Text = math.floor(hum.Health) d.hp.Position = Vector2.new(cx - bw/2 - 7, cy + bh/2 + 4) d.hp.Color = Color3.new(1 - pct, pct, 0) d.hp.Visible = true
            else d.hpBg.Visible = false d.hpBar.Visible = false d.hp.Visible = false end

            if tracersEnabled and lRoot then
                local _, ls = cam:WorldToViewportPoint(lRoot.Position)
                if ls then d.tracer.From = Vector2.new(vs.X / 2, vs.Y) d.tracer.To = Vector2.new(cx, cy) d.tracer.Color = col d.tracer.Visible = true
                else d.tracer.Visible = false end
            else d.tracer.Visible = false end
        end)
    end
end

local function updateCrosshair()
    if not crosshairEnabled then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vs = cam.ViewportSize
    local cx, cy = vs.X / 2, vs.Y / 2
    if #crosshairLines == 0 then
        for i = 1, 4 do
            local l = Drawing.new("Line")
            l.Thickness = 1.5 l.Color = Color3.new(1, 1, 1) l.Visible = true
            crosshairLines[i] = l
        end
    end
    crosshairLines[1].From = Vector2.new(cx - 15, cy) crosshairLines[1].To = Vector2.new(cx - 5, cy)
    crosshairLines[2].From = Vector2.new(cx + 5, cy) crosshairLines[2].To = Vector2.new(cx + 15, cy)
    crosshairLines[3].From = Vector2.new(cx, cy - 15) crosshairLines[3].To = Vector2.new(cx, cy - 5)
    crosshairLines[4].From = Vector2.new(cx, cy + 5) crosshairLines[4].To = Vector2.new(cx, cy + 15)
end

local function scanPlayers()
    pcall(function()
        for _, plr in pairs(Players:GetChildren()) do
            if plr ~= LocalPlayer and not espCache[plr] then createPlayerESP(plr) end
        end
        for plr, _ in pairs(espCache) do
            if not plr.Parent then
                for _, o in pairs(espCache[plr]) do pcall(function() o:Remove() end) end
                espCache[plr] = nil
            end
        end
    end)
end

--// KEYBOARD SHORTCUTS
local function keyTapped(code)
    local down = isDown(code)
    local tapped = down and not prevKeys[code]
    prevKeys[code] = down
    return tapped
end

--// MAIN LOOP
local scanCD = 0
RunService.RenderStepped:Connect(function(dt)
    local mp = mousePos()

    local f1 = isDown(Enum.KeyCode.F1)
    if f1 and not prevF1 then menuOpen = not menuOpen if menuOpen then buildMenu() else clearMenu() end end
    prevF1 = f1

    if isDown(Enum.KeyCode.E) and menuOpen then
        menuX = menuX + (mp.X - (prevKeys._mx or mp.X))
        menuY = menuY + (mp.Y - (prevKeys._my or mp.Y))
        buildMenu()
    end
    prevKeys._mx = mp.X
    prevKeys._my = mp.Y

    local m1 = isMouse1()
    if m1 and not prevMouse and menuOpen then
        for _, btn in pairs(menuItems) do
            if mp.X >= btn.x and mp.X <= btn.x + btn.w and mp.Y >= btn.y and mp.Y <= btn.y + btn.h then
                pcall(function() btn.cb() end)
                buildMenu()
                break
            end
        end
    end
    prevMouse = m1

    if keyTapped(Enum.KeyCode.One) then espEnabled = not espEnabled if menuOpen then buildMenu() end end
    if keyTapped(Enum.KeyCode.Two) then tracersEnabled = not tracersEnabled if menuOpen then buildMenu() end end
    if keyTapped(Enum.KeyCode.Three) then
        lowGfxEnabled = not lowGfxEnabled
        if lowGfxEnabled then settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        else settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end
        if menuOpen then buildMenu() end
    end
    if keyTapped(Enum.KeyCode.Four) then antiFlingEnabled = not antiFlingEnabled if menuOpen then buildMenu() end end
    if keyTapped(Enum.KeyCode.Five) then roleESP = not roleESP if menuOpen then buildMenu() end end
    if keyTapped(Enum.KeyCode.Six) then pcall(function() LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health = 0 end) end
    if keyTapped(Enum.KeyCode.Seven) then
        fullbrightEnabled = not fullbrightEnabled
        if fullbrightEnabled then Lighting.Brightness = 2 Lighting.ClockTime = 14 Lighting.FogEnd = 999999 Lighting.GlobalShadows = false Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        else Lighting.Brightness = 1 Lighting.GlobalShadows = true Lighting.Ambient = Color3.new(0, 0, 0) Lighting.FogEnd = 100000 end
        if menuOpen then buildMenu() end
    end
    if keyTapped(Enum.KeyCode.Eight) then noclipEnabled = not noclipEnabled if menuOpen then buildMenu() end end
    if keyTapped(Enum.KeyCode.Nine) then
        speedEnabled = not speedEnabled
        if not speedEnabled then pcall(function() LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16 end) end
        if menuOpen then buildMenu() end
    end
    if keyTapped(Enum.KeyCode.Zero) then
        jumpEnabled = not jumpEnabled
        if not jumpEnabled then pcall(function() LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = 50 end) end
        if menuOpen then buildMenu() end
    end
    if keyTapped(Enum.KeyCode.P) then speedValue = math.clamp(speedValue + 10, 16, 200) if menuOpen then buildMenu() end end
    if keyTapped(Enum.KeyCode.O) then speedValue = math.clamp(speedValue - 10, 16, 200) if menuOpen then buildMenu() end end
    if keyTapped(Enum.KeyCode.L) then jumpValue = math.clamp(jumpValue + 20, 50, 300) if menuOpen then buildMenu() end end
    if keyTapped(Enum.KeyCode.K) then jumpValue = math.clamp(jumpValue - 20, 50, 300) if menuOpen then buildMenu() end end

    scanCD = scanCD + dt
    if scanCD > 1.5 then scanCD = 0 scanPlayers() end
    updateESP()
    updateCrosshair()
    if speedEnabled then pcall(function() local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed = speedValue end end) end
    if jumpEnabled then pcall(function() local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if h then h.JumpPower = jumpValue end end) end
    if noclipEnabled then pcall(function()
        local c = LocalPlayer.Character
        if c then for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
    end) end
    if antiFlingEnabled then pcall(function()
        local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if r then r.AssemblyAngularVelocity = Vector3.new(0, 0, 0) r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, math.clamp(r.AssemblyLinearVelocity.Y, -50, 50), r.AssemblyLinearVelocity.Z) end
    end) end
end)

buildMenu()
print("[Hub v5] Loaded! F1=Menu, 1-9=Shortcuts, Click buttons, E+Mouse=Drag")
