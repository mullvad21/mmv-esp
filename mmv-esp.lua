--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

--// STATE
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
local menuOpen = true

--// GUI
local espCache = {}
local crosshairLines = {}

--// CREATE REAL GUI
local gui = Instance.new("ScreenGui")
gui.Name = "MMVHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "Menu"
frame.Size = UDim2.new(0, 280, 0, 600)
frame.Position = UDim2.new(0, 20, 0, 80)
frame.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(60, 60, 90)
stroke.Thickness = 1
stroke.Parent = frame

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Scroll"
scroll.Size = UDim2.new(1, -10, 1, -10)
scroll.Position = UDim2.new(0, 5, 0, 5)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 160, 255)
scroll.BorderSizePixel = 0
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 4)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

--// GUI HELPERS
local function addTitle(text)
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, 0, 0, 28)
	t.BackgroundColor3 = Color3.fromRGB(24, 24, 36)
	t.Text = text
	t.TextColor3 = Color3.fromRGB(80, 180, 255)
	t.TextSize = 15
	t.Font = Enum.Font.GothamBold
	t.BorderSizePixel = 0
	t.Parent = scroll
	return t
end

local function addSep(text)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, 24)
	f.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	f.BorderSizePixel = 0
	f.Parent = scroll
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -10, 1, 0)
	l.Position = UDim2.new(0, 8, 0, 0)
	l.BackgroundTransparency = 1
	l.Text = ">> " .. text
	l.TextColor3 = Color3.fromRGB(80, 180, 255)
	l.TextSize = 12
	l.Font = Enum.Font.GothamBold
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = f
	return f
end

local function addToggle(text, default, callback)
	local val = default
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.BackgroundColor3 = val and Color3.fromRGB(25, 80, 25) or Color3.fromRGB(80, 25, 25)
	btn.Text = text .. (val and "  [ON]" or "  [OFF]")
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextSize = 13
	btn.Font = Enum.Font.Gotham
	btn.BorderSizePixel = 0
	btn.Parent = scroll
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 4) c.Parent = btn
	btn.MouseButton1Click:Connect(function()
		val = not val
		btn.BackgroundColor3 = val and Color3.fromRGB(25, 80, 25) or Color3.fromRGB(80, 25, 25)
		btn.Text = text .. (val and "  [ON]" or "  [OFF]")
		callback(val)
	end)
	return btn
end

local function addAction(text, color, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.BackgroundColor3 = color or Color3.fromRGB(40, 40, 55)
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextSize = 13
	btn.Font = Enum.Font.Gotham
	btn.BorderSizePixel = 0
	btn.Parent = scroll
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 4) c.Parent = btn
	btn.MouseButton1Click:Connect(callback)
	return btn
end

--// BUILD MENU
addTitle("MMV / MM2 Hub v4")

addSep("ESP")
addToggle("ESP Boxes", true, function(v) espEnabled = v end)
addToggle("Role Colors", true, function(v) roleESP = v end)
addToggle("Tracers", false, function(v) tracersEnabled = v end)
addToggle("Distance", true, function(v) showDistance = v end)
addToggle("Health Bar", true, function(v) showHealthBar = v end)
addToggle("Crosshair", false, function(v)
	crosshairEnabled = v
	if not v then for _, l in pairs(crosshairLines) do pcall(function() l:Remove() end) end crosshairLines = {} end
end)

addSep("WORLD")
addToggle("Fullbright", false, function(v)
	fullbrightEnabled = v
	if v then Lighting.Brightness = 2 Lighting.ClockTime = 14 Lighting.FogEnd = 999999 Lighting.GlobalShadows = false Lighting.Ambient = Color3.fromRGB(178, 178, 178)
	else Lighting.Brightness = 1 Lighting.GlobalShadows = true Lighting.Ambient = Color3.new(0, 0, 0) Lighting.FogEnd = 100000 end
end)
addToggle("No Fog", false, function(v)
	noFogEnabled = v
	Lighting.FogEnd = v and 999999999 or 100000
end)
addToggle("No Particles", false, function(v)
	noParticlesEnabled = v
	pcall(function()
		for _, x in pairs(workspace:GetDescendants()) do
			if x:IsA("ParticleEmitter") or x:IsA("Trail") or x:IsA("Beam") then x.Enabled = not v end
		end
	end)
end)
addToggle("Low GFX", false, function(v)
	lowGfxEnabled = v
	if v then settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	else settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end
end)

addSep("PLAYER")
addToggle("Speed Hack [" .. speedValue .. "]", false, function(v)
	speedEnabled = v
	if not v then pcall(function() LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16 end) end
end)
addToggle("Jump Hack [" .. jumpValue .. "]", false, function(v)
	jumpEnabled = v
	if not v then pcall(function() LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = 50 end) end
end)
addAction("Speed +10", Color3.fromRGB(40, 50, 70), function()
	speedValue = math.clamp(speedValue + 10, 16, 200)
end)
addAction("Speed -10", Color3.fromRGB(40, 50, 70), function()
	speedValue = math.clamp(speedValue - 10, 16, 200)
end)
addAction("Jump +20", Color3.fromRGB(40, 50, 70), function()
	jumpValue = math.clamp(jumpValue + 20, 50, 300)
end)
addAction("Jump -20", Color3.fromRGB(40, 50, 70), function()
	jumpValue = math.clamp(jumpValue - 20, 50, 300)
end)
addToggle("Noclip", false, function(v) noclipEnabled = v end)
addToggle("Anti-Fling", false, function(v) antiFlingEnabled = v end)

addSep("MISC")
addAction("Reset Character", Color3.fromRGB(100, 30, 30), function()
	pcall(function() LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health = 0 end)
end)
addAction("Rejoin Server", Color3.fromRGB(90, 60, 20), function()
	pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end)
end)
addAction("Server Hop", Color3.fromRGB(50, 50, 90), function()
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

--// TOGGLE MENU WITH RightMouseButton or Button1 on title
frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		menuOpen = not menuOpen
		frame.Visible = menuOpen
	end
end)

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

--// ESP DRAWING (Drawing library works for overlays)
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

--// MAIN LOOP
local scanCD = 0
RunService.RenderStepped:Connect(function(dt)
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

print("[Hub v4] Loaded! Real clickable buttons via ScreenGui. Right-click title to hide/show menu.")
