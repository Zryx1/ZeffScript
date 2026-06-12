-- ============================================
-- ZEFF VORTEX - ESP ONLY MENU
-- FITUR: BOX ESP (KOTAK UNGU NEON)
-- ============================================

local minimized = false
local currentMenu = nil
local espEnabled = false
local espObjects = {}

-- Warna ungu neon
local NeonPurple = Color3.fromRGB(155, 0, 255)
local NeonPink = Color3.fromRGB(212, 0, 255)

-- ============================================
-- BOX ESP FUNCTION
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function CreateBoxESP(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = NeonPurple
    box.Thickness = 2
    box.Filled = false
    box.Transparency = 0.6
    
    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Color = NeonPink
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
        player = player
    }
end

local function UpdateESP()
    if not espEnabled then return end
    
    for _, esp in pairs(espObjects) do
        local player = esp.player
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if not character or not humanoid or not rootPart or humanoid.Health <= 0 then
            esp.box.Visible = false
            esp.nameTag.Visible = false
            esp.healthText.Visible = false
        else
            local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            
            if onScreen then
                local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
                local boxSize = math.clamp(300 / distance, 30, 150)
                
                local boxX = vector.X - boxSize / 2
                local boxY = vector.Y - boxSize / 1.5
                
                esp.box.Size = Vector2.new(boxSize, boxSize)
                esp.box.Position = Vector2.new(boxX, boxY)
                esp.box.Visible = true
                
                esp.nameTag.Text = player.Name
                esp.nameTag.Position = Vector2.new(vector.X, boxY - 15)
                esp.nameTag.Visible = true
                
                local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                local healthColor = healthPercent > 70 and Color3.fromRGB(0, 255, 0) or (healthPercent > 30 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 0, 0))
                esp.healthText.Color = healthColor
                esp.healthText.Text = "❤️ " .. healthPercent .. "%"
                esp.healthText.Position = Vector2.new(vector.X, boxY + boxSize + 12)
                esp.healthText.Visible = true
                
                if healthPercent < 30 then
                    esp.box.Color = Color3.fromRGB(255, 0, 0)
                else
                    esp.box.Color = NeonPurple
                end
            else
                esp.box.Visible = false
                esp.nameTag.Visible = false
                esp.healthText.Visible = false
            end
        end
    end
end

local function AddPlayer(player)
    if player == LocalPlayer then return end
    if espObjects[player] then return end
    espObjects[player] = CreateBoxESP(player)
end

local function RemovePlayer(player)
    if espObjects[player] then
        espObjects[player].box:Remove()
        espObjects[player].nameTag:Remove()
        espObjects[player].healthText:Remove()
        espObjects[player] = nil
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
        esp.box.Visible = false
        esp.nameTag.Visible = false
        esp.healthText.Visible = false
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

-- ============================================
-- MENU UTAMA (Cuma ESP doang)
-- ============================================

local function CreateMainMenu()
    if currentMenu then
        currentMenu:Destroy()
        currentMenu = nil
    end
    
    local UserInputService = game:GetService("UserInputService")
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
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 380)
    mainFrame.Position = UDim2.new(0.5, -140, 0.5, -190)
    mainFrame.BackgroundColor3 = Color3.fromRGB(18, 19, 24)
    mainFrame.BackgroundTransparency = 0.08
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = mainFrame
    
    local border = Instance.new("UIStroke")
    border.Thickness = 1.2
    border.Color = NeonPurple
    border.Transparency = 0.5
    border.Parent = mainFrame
    
    -- Header (buat drag)
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = NeonPurple
    header.BackgroundTransparency = 0.2
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 16)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.7, 0, 1, 0)
    title.Position = UDim2.new(0.05, 0, 0, 0)
    title.Text = "🔮 ZEFF VORTEX"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(0.7, 0, 1, 0)
    subtitle.Position = UDim2.new(0.05, 0, 0, 28)
    subtitle.Text = "ESP Only"
    subtitle.TextColor3 = Color3.fromRGB(200, 200, 255)
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 10
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = header
    
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 35, 0, 35)
    minBtn.Position = UDim2.new(1, -80, 0, 8)
    minBtn.Text = "─"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.BackgroundTransparency = 1
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 20
    minBtn.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -40, 0, 8)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.Parent = header
    
    -- Content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -24, 1, -70)
    content.Position = UDim2.new(0, 12, 0, 62)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    -- Tombol ESP (BESAR)
    local espBtn = Instance.new("TextButton")
    espBtn.Size = UDim2.new(1, 0, 0, 120)
    espBtn.Position = UDim2.new(0, 0, 0, 20)
    espBtn.Text = ""
    espBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
    espBtn.BackgroundTransparency = 0.3
    espBtn.AutoButtonColor = false
    espBtn.Parent = content
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 14)
    btnCorner.Parent = espBtn
    
    -- Icon besar
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 60, 1, 0)
    icon.Text = "🎮"
    icon.TextColor3 = NeonPurple
    icon.BackgroundTransparency = 1
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 40
    icon.Parent = espBtn
    
    -- Nama fitur
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.6, 0, 0.4, 0)
    nameLabel.Position = UDim2.new(0, 65, 0, 20)
    nameLabel.Text = "BOX ESP"
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 22
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = espBtn
    
    -- Deskripsi
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.6, 0, 0.3, 0)
    descLabel.Position = UDim2.new(0, 65, 0, 50)
    descLabel.Text = "Lihat player lewat tembok\nKotak ungu neon + kesehatan"
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 11
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = espBtn
    
    -- Status toggle
    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 20, 0, 20)
    statusDot.Position = UDim2.new(1, -35, 0.5, -10)
    statusDot.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    statusDot.BorderSizePixel = 0
    statusDot.Parent = espBtn
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = statusDot
    
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(0, 40, 0, 20)
    statusText.Position = UDim2.new(1, -80, 0.5, -10)
    statusText.Text = "OFF"
    statusText.TextColor3 = Color3.fromRGB(150, 150, 170)
    statusText.BackgroundTransparency = 1
    statusText.Font = Enum.Font.GothamBold
    statusText.TextSize = 12
    statusText.Parent = espBtn
    
    -- Fungsi toggle ESP
    local function UpdateButtonState()
        if espEnabled then
            statusDot.BackgroundColor3 = NeonPurple
            statusText.Text = "ON"
            statusText.TextColor3 = NeonPurple
            espBtn.BackgroundColor3 = Color3.fromRGB(55, 35, 75)
        else
            statusDot.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
            statusText.Text = "OFF"
            statusText.TextColor3 = Color3.fromRGB(150, 150, 170)
            espBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
        end
    end
    
    espBtn.MouseButton1Click:Connect(function()
        ToggleESP()
        UpdateButtonState()
    end)
    
    -- Hover effect
    espBtn.MouseEnter:Connect(function()
        espBtn.BackgroundTransparency = 0.15
    end)
    espBtn.MouseLeave:Connect(function()
        espBtn.BackgroundTransparency = 0.3
    end)
    
    -- ========== DRAG FUNCTION ==========
    local dragStarted = false
    local dragStartPos = nil
    local menuStartPos = nil
    
    local function updateDrag(input)
        local delta = input.Position - dragStartPos
        local newPos = UDim2.new(
            menuStartPos.X.Scale, menuStartPos.X.Offset + delta.X,
            menuStartPos.Y.Scale, menuStartPos.Y.Offset + delta.Y
        )
        mainFrame.Position = newPos
    end
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStarted = true
            dragStartPos = input.Position
            menuStartPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragStarted = false
                end
            end)
        end
    end)
    
    header.InputChanged:Connect(function(input)
        if dragStarted and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            updateDrag(input)
        end
    end)
    
    -- ========== MINIMIZE FUNCTION ==========
    local function ToggleMinimize()
        if minimized then
            mainFrame:TweenSize(UDim2.new(0, 280, 0, 380), "Out", "Quad", 0.2, true)
            content.Visible = true
            minBtn.Text = "─"
            minimized = false
        else
            mainFrame:TweenSize(UDim2.new(0, 280, 0, 50), "Out", "Quad", 0.2, true)
            content.Visible = false
            minBtn.Text = "□"
            minimized = true
        end
    end
    
    minBtn.MouseButton1Click:Connect(ToggleMinimize)
    
    -- ========== CLOSE FUNCTION (matiin ESP juga) ==========
    closeBtn.MouseButton1Click:Connect(function()
        if espEnabled then
            StopESP()
        end
        screenGui:Destroy()
        currentMenu = nil
    end)
    
    return screenGui
end

-- ========== PANGGIL MENU ==========
CreateMainMenu()    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = frame
    
    textBox.Size = UDim2.new(0.8, 0, 0, 45)
    textBox.Position = UDim2.new(0.1, 0, 0.45, 0)
    textBox.PlaceholderText = "Masukkan password..."
    textBox.Text = ""
    textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 16
    textBox.Parent = frame
    
    local textCorner = Instance.new("UICorner")
    textCorner.CornerRadius = UDim.new(0, 8)
    textCorner.Parent = textBox
    
    confirmBtn.Size = UDim2.new(0.5, 0, 0, 40)
    confirmBtn.Position = UDim2.new(0.25, 0, 0.8, 0)
    confirmBtn.Text = "MASUK"
    confirmBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
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
            LoadMainMenu()
        else
            textBox.Text = ""
            textBox.PlaceholderText = "❌ PASSWORD SALAH!"
            wait(1)
            textBox.PlaceholderText = "Masukkan password..."
        end
    end)
end

-- ============================================
-- MENU MOBILE BISA DIGESER, DIKECILIN, DITUTUP
-- ============================================

local minimized = false

local function CreateMainMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ZeffMenu"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 280, 0, 380)
    mainFrame.Position = UDim2.new(0.5, -140, 0.5, -190)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BackgroundTransparency = 0.92
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = mainFrame
    
    local shadow = Instance.new("UIStroke")
    shadow.Thickness = 1
    shadow.Color = Color3.fromRGB(255, 100, 0)
    shadow.Transparency = 0.4
    shadow.Parent = mainFrame
    
    -- Header (buat drag & minimize)
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    header.BackgroundTransparency = 0.15
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 16)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.7, 0, 1, 0)
    title.Position = UDim2.new(0.05, 0, 0, 0)
    title.Text = "⚡ ZEFF VORTEX"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 35, 0, 35)
    minBtn.Position = UDim2.new(1, -80, 0, 5)
    minBtn.Text = "─"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.BackgroundTransparency = 1
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 20
    minBtn.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -40, 0, 5)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.Parent = header
    
    -- Content (fitur-fitur KOSONG)
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, 0, 1, -45)
    content.Position = UDim2.new(0, 0, 0, 45)
    content.BackgroundTransparency = 1
    content.CanvasSize = UDim2.new(0, 0, 0, 300)
    content.ScrollBarThickness = 3
    content.Parent = mainFrame
    
    -- Fitur kosong (lo isi nanti)
    local features = {
        {name = "🎮 FITUR 1", desc = "Kosong - siap diisi"},
        {name = "🎮 FITUR 2", desc = "Kosong - siap diisi"},
        {name = "🎮 FITUR 3", desc = "Kosong - siap diisi"},
        {name = "🎮 FITUR 4", desc = "Kosong - siap diisi"},
        {name = "🎮 FITUR 5", desc = "Kosong - siap diisi"},
    }
    
    local yOffset = 10
    for _, feat in ipairs(features) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 55)
        btn.Position = UDim2.new(0.05, 0, 0, yOffset)
        btn.Text = feat.name .. "\n" .. feat.desc
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        btn.BackgroundTransparency = 0.5
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.TextWrapped = true
        btn.Parent = content
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = btn
        
        btn.MouseEnter:Connect(function()
            btn.BackgroundTransparency = 0.3
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundTransparency = 0.5
        end)
        
        btn.MouseButton1Click:Connect(function()
            print("🔧 " .. feat.name .. " ditekan - belum ada fungsi")
        end)
        
        yOffset = yOffset + 65
    end
    
    content.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
    
    -- DRAG FUNCTION
    local dragStarted = false
    local dragStartPos = nil
    local menuStartPos = nil
    
    local function updateDrag(input)
        local delta = input.Position - dragStartPos
        local newPos = UDim2.new(
            menuStartPos.X.Scale, menuStartPos.X.Offset + delta.X,
            menuStartPos.Y.Scale, menuStartPos.Y.Offset + delta.Y
        )
        mainFrame.Position = newPos
    end
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStarted = true
            dragStartPos = input.Position
            menuStartPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragStarted = false
                end
            end)
        end
    end)
    
    header.InputChanged:Connect(function(input)
        if dragStarted and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            updateDrag(input)
        end
    end)
    
    -- MINIMIZE FUNCTION
    local function ToggleMinimize()
        if minimized then
            mainFrame:TweenSize(UDim2.new(0, 280, 0, 380), "Out", "Quad", 0.2, true)
            content.Visible = true
            minBtn.Text = "─"
            minimized = false
        else
            mainFrame:TweenSize(UDim2.new(0, 280, 0, 45), "Out", "Quad", 0.2, true)
            content.Visible = false
            minBtn.Text = "□"
            minimized = true
        end
    end
    
    minBtn.MouseButton1Click:Connect(ToggleMinimize)
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    return screenGui
end

function LoadMainMenu()
    CreateMainMenu()
end

-- START
AskPassword()
