-- ============================================
-- ZEFF VORTEX - PRIVATE SCRIPT
-- PASSWORD: zeffproject
-- FITUR: BOX ESP + TRACER ESP
-- LAYOUT: KIRI KATEGORI | KANAN SETTING
-- ============================================

local Password = "zeffproject"

-- ============================================
-- VARIABEL ESP
-- ============================================
local espEnabled = false
local espMode = "box"  -- "box" or "tracer"
local espColor = Color3.fromRGB(155, 0, 255)  -- UNGU NEON
local espThickness = 2
local espTransparency = 0.5

local espObjects = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ============================================
-- BOX ESP
-- ============================================
local function CreateBoxESP(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = espColor
    box.Thickness = espThickness
    box.Filled = false
    box.Transparency = espTransparency
    
    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Color = espColor
    nameTag.Size = 14
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.fromRGB(0, 0, 0)
    
    local healthText = Drawing.new("Text")
    healthText.Visible = false
    healthText.Color = Color3.fromRGB(255, 255, 255)
    healthText.Size = 11
    healthText.Center = true
    healthText.Outline = true
    healthText.OutlineColor = Color3.fromRGB(0, 0, 0)
    
    return {
        box = box,
        nameTag = nameTag,
        healthText = healthText,
        player = player,
        type = "box"
    }
end

-- ============================================
-- TRACER ESP (garis ke player)
-- ============================================
local function CreateTracerESP(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = espColor
    line.Thickness = espThickness
    line.Transparency = espTransparency
    
    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Color = espColor
    nameTag.Size = 12
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.fromRGB(0, 0, 0)
    
    return {
        line = line,
        nameTag = nameTag,
        player = player,
        type = "tracer"
    }
end

-- ============================================
-- UPDATE ESP
-- ============================================
local function UpdateESP()
    if not espEnabled then return end
    
    local viewportSize = Camera.ViewportSize
    local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    
    for _, esp in pairs(espObjects) do
        local player = esp.player
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if not character or not humanoid or not rootPart or humanoid.Health <= 0 then
            if esp.type == "box" then
                esp.box.Visible = false
                esp.nameTag.Visible = false
                if esp.healthText then esp.healthText.Visible = false end
            else
                esp.line.Visible = false
                esp.nameTag.Visible = false
            end
        else
            local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            
            if onScreen then
                if esp.type == "box" then
                    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
                    local boxSize = math.clamp(300 / distance, 30, 150)
                    
                    local boxX = vector.X - boxSize / 2
                    local boxY = vector.Y - boxSize / 1.5
                    
                    esp.box.Size = Vector2.new(boxSize, boxSize)
                    esp.box.Position = Vector2.new(boxX, boxY)
                    esp.box.Visible = true
                    esp.box.Color = espColor
                    esp.box.Thickness = espThickness
                    esp.box.Transparency = espTransparency
                    
                    esp.nameTag.Text = player.Name
                    esp.nameTag.Position = Vector2.new(vector.X, boxY - 15)
                    esp.nameTag.Visible = true
                    esp.nameTag.Color = espColor
                    
                    local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                    esp.healthText.Text = "❤️ " .. healthPercent .. "%"
                    esp.healthText.Position = Vector2.new(vector.X, boxY + boxSize + 12)
                    esp.healthText.Visible = true
                    
                else -- tracer
                    esp.line.From = center
                    esp.line.To = Vector2.new(vector.X, vector.Y)
                    esp.line.Visible = true
                    esp.line.Color = espColor
                    esp.line.Thickness = espThickness
                    esp.line.Transparency = espTransparency
                    
                    esp.nameTag.Text = player.Name
                    esp.nameTag.Position = Vector2.new(vector.X, vector.Y - 15)
                    esp.nameTag.Visible = true
                    esp.nameTag.Color = espColor
                end
            else
                if esp.type == "box" then
                    esp.box.Visible = false
                    esp.nameTag.Visible = false
                    if esp.healthText then esp.healthText.Visible = false end
                else
                    esp.line.Visible = false
                    esp.nameTag.Visible = false
                end
            end
        end
    end
end

-- ============================================
-- MANAJEMEN PLAYER
-- ============================================
local function AddPlayer(player)
    if player == LocalPlayer then return end
    if espObjects[player] then return end
    
    if espMode == "box" then
        espObjects[player] = CreateBoxESP(player)
    else
        espObjects[player] = CreateTracerESP(player)
    end
end

local function RemovePlayer(player)
    if espObjects[player] then
        if espObjects[player].box then
            espObjects[player].box:Remove()
        end
        if espObjects[player].line then
            espObjects[player].line:Remove()
        end
        if espObjects[player].nameTag then
            espObjects[player].nameTag:Remove()
        end
        if espObjects[player].healthText then
            espObjects[player].healthText:Remove()
        end
        espObjects[player] = nil
    end
end

local function RefreshESP()
    for _, esp in pairs(espObjects) do
        if esp.type == "box" and esp.box then
            esp.box.Color = espColor
            esp.box.Thickness = espThickness
            esp.box.Transparency = espTransparency
            esp.nameTag.Color = espColor
        elseif esp.type == "tracer" and esp.line then
            esp.line.Color = espColor
            esp.line.Thickness = espThickness
            esp.line.Transparency = espTransparency
            esp.nameTag.Color = espColor
        end
    end
end

local function StartESP()
    if espEnabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            AddPlayer(player)
        end
    end
    
    Players.PlayerAdded:Connect(AddPlayer)
    Players.PlayerRemoving:Connect(RemovePlayer)
    RunService.RenderStepped:Connect(UpdateESP)
    
    espEnabled = true
end

local function StopESP()
    espEnabled = false
    for _, esp in pairs(espObjects) do
        if esp.type == "box" then
            esp.box.Visible = false
            esp.nameTag.Visible = false
            if esp.healthText then esp.healthText.Visible = false end
        else
            esp.line.Visible = false
            esp.nameTag.Visible = false
        end
    end
end

local function ToggleESP()
    if espEnabled then
        StopESP()
    else
        StartESP()
    end
    return espEnabled
end

local function SwitchMode(mode)
    espMode = mode
    -- Re-create semua ESP dengan mode baru
    local wasEnabled = espEnabled
    if wasEnabled then
        StopESP()
    end
    
    for _, esp in pairs(espObjects) do
        if esp.box then esp.box:Remove() end
        if esp.line then esp.line:Remove() end
        if esp.nameTag then esp.nameTag:Remove() end
        if esp.healthText then esp.healthText:Remove() end
    end
    espObjects = {}
    
    if wasEnabled then
        StartESP()
    end
end

-- ============================================
-- DIALOG PASSWORD
-- ============================================
local function AskPassword()
    local CoreGui = game:GetService("CoreGui")
    
    local dialog = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local textBox = Instance.new("TextBox")
    local confirmBtn = Instance.new("TextButton")
    
    dialog.Name = "PasswordDialog"
    dialog.Parent = (gethui and gethui()) or CoreGui
    
    frame.Size = UDim2.new(0, 280, 0, 160)
    frame.Position = UDim2.new(0.5, -140, 0.5, -80)
    frame.BackgroundColor3 = Color3.fromRGB(18, 19, 24)
    frame.BorderSizePixel = 0
    frame.Parent = dialog
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local border = Instance.new("UIStroke")
    border.Thickness = 1.2
    border.Color = Color3.fromRGB(155, 0, 255)
    border.Transparency = 0.5
    border.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.Text = "🔮 ZEFF VORTEX"
    title.TextColor3 = Color3.fromRGB(155, 0, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = frame
    
    textBox.Size = UDim2.new(0.8, 0, 0, 45)
    textBox.Position = UDim2.new(0.1, 0, 0.45, 0)
    textBox.PlaceholderText = "Masukkan password..."
    textBox.Text = ""
    textBox.BackgroundColor3 = Color3.fromRGB(34, 37, 48)
    textBox.TextColor3 = Color3.fromRGB(240, 242, 250)
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 16
    textBox.Parent = frame
    
    local textCorner = Instance.new("UICorner")
    textCorner.CornerRadius = UDim.new(0, 8)
    textCorner.Parent = textBox
    
    confirmBtn.Size = UDim2.new(0.5, 0, 0, 40)
    confirmBtn.Position = UDim2.new(0.25, 0, 0.8, 0)
    confirmBtn.Text = "MASUK"
    confirmBtn.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
    confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmBtn.Font = Enum.Font.GothamBold
    confirmBtn.TextSize = 14
    confirmBtn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = confirmBtn
    
    confirmBtn.MouseButton1Click:Connect(function()
        if textBox.Text == Password then
            dialog:Destroy()
            CreateMainMenu()
        else
            textBox.Text = ""
            textBox.PlaceholderText = "❌ PASSWORD SALAH!"
            wait(1)
            textBox.PlaceholderText = "Masukkan password..."
        end
    end)
end

-- ============================================
-- MENU UTAMA (Layout KIRI KATEGORI | KANAN SETTING)
-- ============================================
local minimized = false
local currentMenu = nil

local function CreateMainMenu()
    if currentMenu then
        currentMenu:Destroy()
        currentMenu = nil
    end
    
    local CoreGui = game:GetService("CoreGui")
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ZeffVortexMenu"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local ok = pcall(function()
        screenGui.Parent = (gethui and gethui()) or CoreGui
    end)
    if not ok then
        screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    currentMenu = screenGui
    
    -- MAIN FRAME (Ukuran lebih kecil)
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 520, 0, 340)
    mainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
    mainFrame.BackgroundColor3 = Color3.fromRGB(18, 19, 24)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 14)
    mainCorner.Parent = mainFrame
    
    local border = Instance.new("UIStroke")
    border.Thickness = 1
    border.Color = Color3.fromRGB(155, 0, 255)
    border.Transparency = 0.4
    border.Parent = mainFrame
    
    -- ========== HEADER (Drag) ==========
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 42)
    header.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
    header.BackgroundTransparency = 0.2
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 14)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.Position = UDim2.new(0.02, 0, 0, 0)
    title.Text = "🔮 ZEFF VORTEX"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -68, 0.5, -15)
    minBtn.Text = "─"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.BackgroundTransparency = 1
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 18
    minBtn.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -36, 0.5, -15)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = header
    
    -- ========== LAYOUT: KIRI (KATEGORI) + KANAN (SETTING) ==========
    local leftPanel = Instance.new("Frame")
    leftPanel.Size = UDim2.new(0, 140, 1, -50)
    leftPanel.Position = UDim2.new(0, 0, 0, 50)
    leftPanel.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
    leftPanel.BackgroundTransparency = 0.5
    leftPanel.BorderSizePixel = 0
    leftPanel.Parent = mainFrame
    
    local leftCorner = Instance.new("UICorner")
    leftCorner.CornerRadius = UDim.new(0, 0)
    leftCorner.Parent = leftPanel
    
    local rightPanel = Instance.new("Frame")
    rightPanel.Size = UDim2.new(1, -150, 1, -50)
    rightPanel.Position = UDim2.new(0, 145, 0, 50)
    rightPanel.BackgroundTransparency = 1
    rightPanel.BorderSizePixel = 0
    rightPanel.Parent = mainFrame
    
    -- ========== KATEGORI (KIRI) ==========
    local categories = {
        {id = "esp", name = "🎮 ESP", icon = "🎮"},
        {id = "color", name = "🎨 WARNA", icon = "🎨"},
        {id = "settings", name = "⚙ SETTING", icon = "⚙"},
    }
    
    local activeCategory = "esp"
    local categoryButtons = {}
    
    local function updateRightPanel()
        -- Bersihkan rightPanel
        for _, child in ipairs(rightPanel:GetChildren()) do
            child:Destroy()
        end
        
        if activeCategory == "esp" then
            -- ========== ESP SETTINGS ==========
            local espFrame = Instance.new("Frame")
            espFrame.Size = UDim2.new(1, -20, 1, -20)
            espFrame.Position = UDim2.new(0, 10, 0, 10)
            espFrame.BackgroundTransparency = 1
            espFrame.Parent = rightPanel
            
            -- Title
            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, 0, 0, 30)
            titleLabel.Text = "⚡ PENGATURAN ESP"
            titleLabel.TextColor3 = Color3.fromRGB(155, 0, 255)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.TextSize = 14
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = espFrame
            
            -- Toggle ESP (ON/OFF)
            local espToggleFrame = Instance.new("Frame")
            espToggleFrame.Size = UDim2.new(1, 0, 0, 40)
            espToggleFrame.Position = UDim2.new(0, 0, 0, 40)
            espToggleFrame.BackgroundColor3 = Color3.fromRGB(34, 37, 48)
            espToggleFrame.BackgroundTransparency = 0.5
            espToggleFrame.BorderSizePixel = 0
            espToggleFrame.Parent = espFrame
            
            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 8)
            toggleCorner.Parent = espToggleFrame
            
            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Size = UDim2.new(0.6, 0, 1, 0)
            toggleLabel.Position = UDim2.new(0, 12, 0, 0)
            toggleLabel.Text = "🔘 STATUS ESP"
            toggleLabel.TextColor3 = Color3.fromRGB(240, 242, 250)
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.Font = Enum.Font.Gotham
            toggleLabel.TextSize = 13
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            toggleLabel.Parent = espToggleFrame
            
            local toggleStatus = Instance.new("TextLabel")
            toggleStatus.Size = UDim2.new(0.3, 0, 1, 0)
            toggleStatus.Position = UDim2.new(0.7, 0, 0, 0)
            toggleStatus.Text = espEnabled and "ON ✅" or "OFF ❌"
            toggleStatus.TextColor3 = espEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
            toggleStatus.BackgroundTransparency = 1
            toggleStatus.Font = Enum.Font.GothamBold
            toggleStatus.TextSize = 13
            toggleStatus.TextXAlignment = Enum.TextXAlignment.Right
            toggleStatus.Parent = espToggleFrame
            
            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Size = UDim2.new(1, 0, 1, 0)
            toggleBtn.Text = ""
            toggleBtn.BackgroundTransparency = 1
            toggleBtn.Parent = espToggleFrame
            
            toggleBtn.MouseButton1Click:Connect(function()
                ToggleESP()
                toggleStatus.Text = espEnabled and "ON ✅" or "OFF ❌"
                toggleStatus.TextColor3 = espEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
            end)
            
            -- Mode ESP (Box / Tracer)
            local modeFrame = Instance.new("Frame")
            modeFrame.Size = UDim2.new(1, 0, 0, 40)
            modeFrame.Position = UDim2.new(0, 0, 0, 90)
            modeFrame.BackgroundColor3 = Color3.fromRGB(34, 37, 48)
            modeFrame.BackgroundTransparency = 0.5
            modeFrame.BorderSizePixel = 0
            modeFrame.Parent = espFrame
            
            local modeCorner = Instance.new("UICorner")
            modeCorner.CornerRadius = UDim.new(0, 8)
            modeCorner.Parent = modeFrame
            
            local modeLabel = Instance.new("TextLabel")
            modeLabel.Size = UDim2.new(0.5, 0, 1, 0)
            modeLabel.Position = UDim2.new(0, 12, 0, 0)
            modeLabel.Text = "📐 MODE ESP"
            modeLabel.TextColor3 = Color3.fromRGB(240, 242, 250)
            modeLabel.BackgroundTransparency = 1
            modeLabel.Font = Enum.Font.Gotham
            modeLabel.TextSize = 13
            modeLabel.TextXAlignment = Enum.TextXAlignment.Left
            modeLabel.Parent = modeFrame
            
            local modeValue = Instance.new("TextLabel")
            modeValue.Size = UDim2.new(0.4, 0, 1, 0)
            modeValue.Position = UDim2.new(0.55, 0, 0, 0)
            modeValue.Text = espMode == "box" and "📦 BOX" or "📏 TRACER"
            modeValue.TextColor3 = Color3.fromRGB(155, 0, 255)
            modeValue.BackgroundTransparency = 1
            modeValue.Font = Enum.Font.GothamBold
            modeValue.TextSize = 13
            modeValue.TextXAlignment = Enum.TextXAlignment.Right
            modeValue.Parent = modeFrame
            
            local modeBtn = Instance.new("TextButton")
            modeBtn.Size = UDim2.new(1, 0, 1, 0)
            modeBtn.Text = ""
            modeBtn.BackgroundTransparency = 1
            modeBtn.Parent = modeFrame
            
            modeBtn.MouseButton1Click:Connect(function()
                if espMode == "box" then
                    SwitchMode("tracer")
                    modeValue.Text = "📏 TRACER"
                else
                    SwitchMode("box")
                    modeValue.Text = "📦 BOX"
                end
            end)
            
            -- Ketebalan garis
            local thickFrame = Instance.new("Frame")
            thickFrame.Size = UDim2.new(1, 0, 0, 40)
            thickFrame.Position = UDim2.new(0, 0, 0, 140)
            thickFrame.BackgroundColor3 = Color3.fromRGB(34, 37, 48)
            thickFrame.BackgroundTransparency = 0.5
            thickFrame.BorderSizePixel = 0
            thickFrame.Parent = espFrame
            
            local thickCorner = Instance.new("UICorner")
            thickCorner.CornerRadius = UDim.new(0, 8)
            thickCorner.Parent = thickFrame
            
            local thickLabel = Instance.new("TextLabel")
            thickLabel.Size = UDim2.new(0.5, 0, 1, 0)
            thickLabel.Position = UDim2.new(0, 12, 0, 0)
            thickLabel.Text = "📏 KETEBALAN"
            thickLabel.TextColor3 = Color3.fromRGB(240, 242, 250)
            thickLabel.BackgroundTransparency = 1
            thickLabel.Font = Enum.Font.Gotham
            thickLabel.TextSize = 13
            thickLabel.TextXAlignment = Enum.TextXAlignment.Left
            thickLabel.Parent = thickFrame
            
            local thickValue = Instance.new("TextLabel")
            thickValue.Size = UDim2.new(0.3, 0, 1, 0)
            thickValue.Position = UDim2.new(0.6, 0, 0, 0)
            thickValue.Text = tostring(espThickness)
            thickValue.TextColor3 = Color3.fromRGB(155, 0, 255)
            thickValue.BackgroundTransparency = 1
            thickValue.Font = Enum.Font.GothamBold
            thickValue.TextSize = 13
            thickValue.TextXAlignment = Enum.TextXAlignment.Right
            thickValue.Parent = thickFrame
            
            local minusBtn = Instance.new("TextButton")
            minusBtn.Size = UDim2.new(0, 30, 0, 30)
            minusBtn.Position = UDim2.new(1, -70, 0.5, -15)
            minusBtn.Text = "-"
            minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            minusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            minusBtn.Font = Enum.Font.GothamBold
            minusBtn.TextSize = 16
            minusBtn.Parent = thickFrame
            
            local plusBtn = Instance.new("TextButton")
            plusBtn.Size = UDim2.new(0, 30, 0, 30)
            plusBtn.Position = UDim2.new(1, -35, 0.5, -15)
            plusBtn.Text = "+"
            plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            plusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            plusBtn.Font = Enum.Font.GothamBold
            plusBtn.TextSize = 16
            plusBtn.Parent = thickFrame
            
            local thickCorner2 = Instance.new("UICorner")
            thickCorner2.CornerRadius = UDim.new(0, 6)
            thickCorner2.Parent = minusBtn
            
            local thickCorner3 = Instance.new("UICorner")
            thickCorner3.CornerRadius = UDim.new(0, 6)
            thickCorner3.Parent = plusBtn
            
            minusBtn.MouseButton1Click:Connect(function()
                espThickness = math.max(1, espThickness - 1)
                thickValue.Text = tostring(espThickness)
                RefreshESP()
            end)
            
            plusBtn.MouseButton1Click:Connect(function()
                espThickness = math.min(5, espThickness + 1)
                thickValue.Text = tostring(espThickness)
                RefreshESP()
            end)
            
        elseif activeCategory == "color" then
            -- ========== WARNA SETTINGS ==========
            local colorFrame = Instance.new("Frame")
            colorFrame.Size = UDim2.new(1, -20, 1, -20)
            colorFrame.Position = UDim2.new(0, 10, 0, 10)
            colorFrame.BackgroundTransparency = 1
            colorFrame.Parent = rightPanel
            
            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, 0, 0, 30)
            titleLabel.Text = "🎨 PENGATURAN WARNA"
            titleLabel.TextColor3 = Color3.fromRGB(155, 0, 255)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.TextSize = 14
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = colorFrame
            
            -- Pilihan warna preset
            local colors = {
                {name = "UNGU NEON", color = Color3.fromRGB(155, 0, 255), rgb = "155,0,255"},
                {name = "MERAH", color = Color3.fromRGB(255, 0, 0), rgb = "255,0,0"},
                {name = "HIJAU", color = Color3.fromRGB(0, 255, 0), rgb = "0,255,0"},
                {name = "BIRU", color = Color3.fromRGB(0, 100, 255), rgb = "0,100,255"},
                {name = "KUNING", color = Color3.fromRGB(255, 200, 0), rgb = "255,200,0"},
                {name = "PUTIH", color = Color3.fromRGB(255, 255, 255), rgb = "255,255,255"},
            }
            
            local yOffset = 45
            for _, col in ipairs(colors) do
                local colorBtn = Instance.new("TextButton")
                colorBtn.Size = UDim2.new(1, 0, 0, 38)
                colorBtn.Position = UDim2.new(0, 0, 0, yOffset)
                colorBtn.Text = "🎨 " .. col.name
                colorBtn.TextColor3 = Color3.fromRGB(240, 242, 250)
                colorBtn.BackgroundColor3 = col.color
                colorBtn.BackgroundTransparency = 0.7
                colorBtn.Font = Enum.Font.Gotham
                colorBtn.TextSize = 13
                colorBtn.TextXAlignment = Enum.TextXAlignment.Left
                colorBtn.Parent = colorFrame
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 8)
                btnCorner.Parent = colorBtn
                
                colorBtn.MouseButton1Click:Connect(function()
                    espColor = col.color
                    RefreshESP()
                    -- Update indicator
                    for _, child in ipairs(colorFrame:GetChildren()) do
                        if child:IsA("TextButton") then
                            child.BackgroundTransparency = 0.7
                        end
                    end
                    colorBtn.BackgroundTransparency = 0.3
                end)
                
                yOffset = yOffset + 45
            end
            
        elseif activeCategory == "settings" then
            -- ========== SETTINGS UMUM ==========
            local settingFrame = Instance.new("Frame")
            settingFrame.Size = UDim2.new(1, -20, 1, -20)
            settingFrame.Position = UDim2.new(0, 10, 0, 10)
            settingFrame.BackgroundTransparency = 1
            settingFrame.Parent = rightPanel
            
            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, 0, 0, 30)
            titleLabel.Text = "⚙ PENGATURAN UMUM"
            titleLabel.TextColor3 = Color3.fromRGB(155, 0, 255)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.TextSize = 14
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = settingFrame
            
            -- Transparansi slider
            local transFrame = Instance.new("Frame")
            transFrame.Size = UDim2.new(1, 0, 0, 50)
            transFrame.Position = UDim2.new(0, 0, 0, 45)
            transFrame.BackgroundColor3 = Color3.fromRGB(34, 37, 48)
            transFrame.BackgroundTransparency = 0.5
            transFrame.BorderSizePixel = 0
            transFrame.Parent = settingFrame
            
            local transCorner = Instance.new("UICorner")
            transCorner.CornerRadius = UDim.new(0, 8)
            transCorner.Parent = transFrame
            
            local transLabel = Instance.new("TextLabel")
            transLabel.Size = UDim2.new(0.6, 0, 0.5, 0)
            transLabel.Position = UDim2.new(0, 12, 0, 5)
            transLabel.Text = "🔮 TRANSPARANSI"
            transLabel.TextColor3 = Color3.fromRGB(240, 242, 250)
            transLabel.BackgroundTransparency = 1
            transLabel.Font = Enum.Font.GothamBold
            transLabel.TextSize = 12
            transLabel.TextXAlignment = Enum.TextXAlignment.Left
            transLabel.Parent = transFrame
            
            local transValue = Instance.new("TextLabel")
            transValue.Size = UDim2.new(0.3, 0, 0.5, 0)
            transValue.Position = UDim2.new(0.6, 0, 0, 5)
            transValue.Text = math.floor(espTransparency * 100) .. "%"
            transValue.TextColor3 = Color3.fromRGB(155, 0, 255)
            transValue.BackgroundTransparency = 1
            transValue.Font = Enum.Font.GothamBold
            transValue.TextSize = 12
            transValue.TextXAlignment = Enum.TextXAlignment.Right
            transValue.Parent = transFrame
            
            local slider = Instance.new("Frame")
            slider.Size = UDim2.new(0.8, 0, 0, 4)
            slider.Position = UDim2.new(0.1, 0, 0.7, 0)
            slider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            slider.BorderSizePixel = 0
            slider.Parent = transFrame
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Size = UDim2.new(espTransparency, 0, 1, 0)
            sliderFill.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = slider
            
            local sliderCorner = Instance.new("UICorner")
            sliderCorner.CornerRadius = UDim.new(1, 0)
            sliderCorner.Parent = slider
            
            local sliderFillCorner = Instance.new("UICorner")
            sliderFillCorner.CornerRadius = UDim.new(1, 0)
            sliderFillCorner.Parent = sliderFill
            
            -- Slider drag (sederhana)
            local sliderBtn = Instance.new("TextButton")
            sliderBtn.Size = UDim2.new(0, 0, 1, 0)
            sliderBtn.Text = ""
            sliderBtn.BackgroundTransparency = 1
            sliderBtn.Parent = transFrame
            
            local function updateTransparency(value)
                espTransparency = math.clamp(value, 0, 1)
                transValue.Text = math.floor(espTransparency * 100) .. "%"
                sliderFill.Size = UDim2.new(espTransparency, 0, 1, 0)
                RefreshESP()
            end
            
            -- Info
            local infoLabel = Instance.new("TextLabel")
            infoLabel.Size = UDim2.new(1, 0, 0, 30)
            infoLabel.Position = UDim2.new(0, 0, 0, 110)
            infoLabel.Text = "💡 ZEFF VORTEX | Private Script"
            infoLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
            infoLabel.BackgroundTransparency = 1
            infoLabel.Font = Enum.Font.Gotham
            infoLabel.TextSize = 10
            infoLabel.TextXAlignment = Enum.TextXAlignment.Center
            infoLabel.Parent = settingFrame
        end
    end
    
    -- Buat tombol kategori di kiri
    local yOffset = 10
    for _, cat in ipairs(categories) do
        local catBtn = Instance.new("TextButton")
        catBtn.Size = UDim2.new(0.9, 0, 0, 45)
        catBtn.Position = UDim2.new(0.05, 0, 0, yOffset)
        catBtn.Text = cat.name
        catBtn.TextColor3 = Color3.fromRGB(240, 242, 250)
        catBtn.BackgroundColor3 = cat.id == activeCategory and Color3.fromRGB(155, 0, 255) or Color3.fromRGB(34, 37, 48)
        catBtn.BackgroundTransparency = cat.id == activeCategory and 0.2 or 0.5
        catBtn.Font = Enum.Font.Gotham
        catBtn.TextSize = 13
        catBtn.Parent = leftPanel
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = catBtn
        
        categoryButtons[cat.id] = catBtn
        
        catBtn.MouseButton1Click:Connect(function()
            activeCategory = cat.id
            for id, btn in pairs(categoryButtons) do
                if id == activeCategory then
                    btn.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
                    btn.BackgroundTransparency = 0.2
                else
                    btn.BackgroundColor3 = Color3.fromRGB(34, 37, 48)
                    btn.BackgroundTransparency = 0.5
                end
            end
            updateRightPanel()
        end)
        
        yOffset = yOffset + 55
    end
    
    -- Initial load
    updateRightPanel()
    
    -- ========== DRAG FUNCTION ==========
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- ========== MINIMIZE (ukuran lebih kecil) ==========
    local function ToggleMinimize()
        if minimized then
            mainFrame:TweenSize(UDim2.new(0, 520, 0, 340), "Out", "Quad", 0.2, true)
            leftPanel.Visible = true
            rightPanel.Visible = true
            minBtn.Text = "─"
            minimized = false
        else
            mainFrame:TweenSize(UDim2.new(0, 200, 0, 42), "Out", "Quad", 0.2, true)
            leftPanel.Visible = false
            rightPanel.Visible = false
            minBtn.Text = "□"
            minimized = true
        end
    end
    
    minBtn.MouseButton1Click:Connect(ToggleMinimize)
    
    closeBtn.MouseButton1Click:Connect(function()
        if espEnabled then
            StopESP()
        end
        screenGui:Destroy()
        currentMenu = nil
    end)
end

-- ========== START ==========
AskPassword()
