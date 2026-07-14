local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function createESP(player)
    if player == LocalPlayer then return end
    if not player.Character then return end
    if player.Character:FindFirstChild("ESP_Highlight") then return end

    pcall(function()
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.FillColor = Color3.new(1, 0, 0)
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Adornee = player.Character
        highlight.Parent = player.Character
    end)

    pcall(function()
        local head = player.Character:FindFirstChild("Head")
        if not head then return end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_Name"
        billboard.Size = UDim2.new(0, 100, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = head
        billboard.Parent = head

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.Parent = billboard

        local healthLabel = Instance.new("TextLabel")
        healthLabel.Size = UDim2.new(1, 0, 0.5, 0)
        healthLabel.Position = UDim2.new(0, 0, 0.5, 0)
        healthLabel.BackgroundTransparency = 1
        healthLabel.Text = "100 HP"
        healthLabel.TextColor3 = Color3.new(0, 1, 0)
        healthLabel.TextStrokeTransparency = 0
        healthLabel.Font = Enum.Font.GothamBold
        healthLabel.TextSize = 14
        healthLabel.Parent = billboard
    end)
end

local function removeESP(player)
    pcall(function()
        if player.Character and player.Character:FindFirstChild("ESP_Highlight") then
            player.Character.ESP_Highlight:Destroy()
        end
    end)
    pcall(function()
        if player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            if head:FindFirstChild("ESP_Name") then
                head.ESP_Name:Destroy()
            end
        end
    end)
end

local function onPlayerAdded(player)
    if player == LocalPlayer then return end

    pcall(function()
        player.CharacterAdded:Connect(function(char)
            task.wait(1)
            createESP(player)
            pcall(function()
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.HealthChanged:Connect(function()
                        pcall(function()
                            local h = char:FindFirstChild("Head")
                            if h and h:FindFirstChild("ESP_Name") then
                                local labels = h.ESP_Name:GetDescendants()
                                for _, label in pairs(labels) do
                                    if label:IsA("TextLabel") and label.Text:find("HP") then
                                        label.Text = math.floor(hum.Health) .. " HP"
                                        local pct = hum.Health / hum.MaxHealth
                                        label.TextColor3 = Color3.new(1 - pct, pct, 0)
                                    end
                                end
                            end
                        end)
                    end)
                end
            end)
        end)
    end)

    pcall(function()
        player.CharacterRemoving:Connect(function()
            removeESP(player)
        end)
    end)

    createESP(player)
end

pcall(function()
    Players.PlayerAdded:Connect(onPlayerAdded)
end)

pcall(function()
    Players.PlayerRemoving:Connect(function(player)
        removeESP(player)
    end)
end)

pcall(function()
    for _, player in pairs(Players:GetPlayers()) do
        onPlayerAdded(player)
    end
end)

print("[MMV ESP] Loaded!")
