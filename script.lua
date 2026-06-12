-- ============================================
-- ZEFF VORTEX - SCRIPT
-- BOX ESP + TRACER ESP + KETEBALAN
-- TANPA PASSWORD, LANGSUNG MUNCUL MENU
-- ============================================

-- ============================================
-- VARIABEL ESP
-- ============================================
local espEnabled = false
local espMode = "box"  -- "box" or "tracer"
local espColor = Color3.fromRGB(155, 0, 255)  -- UNGU NEON
local espThickness = 2

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
    box.Transparency = 0.5
    
    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Color = espColor
    nameTag.Size = 14
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.fromRGB(0, 0, 0)
    
    return {
        box = box,
        nameTag = nameTag,
        player = player,
        type = "box"
    }
end

-- ============================================
-- TRACER ESP
-- ============================================
local function CreateTracerESP(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = espColor
    line.Thickness = espThickness
    line.Transparency = 0.5
    
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
                    
                    esp.nameTag.Text = player.Name
                    esp.nameTag.Position = Vector2.new(vector.X, boxY - 15)
                    esp.nameTag.Visible = true
                    esp.nameTag.Color = espColor
                    
                else -- tracer
                    esp.line.From = center
                    esp.line.To = Vector2.new(vector.X, vector.Y)
                    esp.line.Visible = true
                    esp.line.Color = espColor
                    esp.line.Thickness = espThickness
                    
                    esp.nameTag.Text = player.Name
                    esp.nameTag.Position = Vector2.new(vector.X, vector.Y - 15)
                    esp.nameTag.Visible = true
                    esp.nameTag.Color = espColor
                end
            else
                if esp.type == "box" then
                    esp.box.Visible = false
                    esp.nameTag.Visible = false
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
        espObjects[player] = nil
    end
end

local function RefreshESP()
    for _, esp in pairs(espObjects) do
        if esp.type == "box" and esp.box then
            esp.box.Color = espColor
            esp.box.Thickness = espThickness
            esp.nameTag.Color = espColor
        elseif esp.type == "tracer" and esp.line then
            esp.line.Color = espColor
            esp.line.Thickness = espThickness
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
    local wasEnabled = espEnabled
    if wasEnabled then
        StopESP()
    end
    
    for _, esp in pairs(espObjects) do
        if esp.box then esp.box:Remove() end
        if esp.line then esp.line:Remove() end
        if esp.nameTag then esp.nameTag:Remove() end
    end
    espObjects = {}
    
    if wasEnabled then
        StartESP()
    end
end

-- ============================================
-- MENU UTAMA (LANGSUNG MUNCUL)
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
    
    local success, err = pcall(function()
        screenGui.Parent = (gethui and gethui()) or CoreGui
    end)
    if not success then
        screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    currentMenu = screenGui
    
    -- MAIN FRAME
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 280)
    mainFrame.Position = UDim2.new(0.5, -140, 0.5, -140)
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
    
    -- HEADER (Drag)
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
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0.03, 0, 0, 0)
    title.Text = "🔮 ZEFF VORTEX"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
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
    
    -- CONTENT
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20, 1, -60)
    content.Position = UDim2.new(0, 10, 0, 55)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    local yOffset = 10
    
    -- Tombol BOX ESP
    local boxBtn = Instance.new("TextButton")
    boxBtn.Size = UDim2.new(1, 0, 0, 55)
    boxBtn.Position = UDim2.new(0, 0, 0, yOffset)
    boxBtn.Text = "📦 BOX ESP"
    boxBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    boxBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    boxBtn.Font = Enum.Font.GothamBold
    boxBtn.TextSize = 16
    boxBtn.Parent = content
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 10)
    boxCorner.Parent = boxBtn
    
    local boxStatus = Instance.new("TextLabel")
    boxStatus.Size = UDim2.new(0.3, 0, 1, 0)
    boxStatus.Position = UDim2.new(0.7, 0, 0, 0)
    boxStatus.Text = "OFF"
    boxStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
    boxStatus.BackgroundTransparency = 1
    boxStatus.Font = Enum.Font.GothamBold
    boxStatus.TextSize = 14
    boxStatus.TextXAlignment = Enum.TextXAlignment.Right
    boxStatus.Parent = boxBtn
    
    yOffset = yOffset + 65
    
    -- Tombol TRACER ESP
    local tracerBtn = Instance.new("TextButton")
    tracerBtn.Size = UDim2.new(1, 0, 0, 55)
    tracerBtn.Position = UDim2.new(0, 0, 0, yOffset)
    tracerBtn.Text = "📏 TRACER ESP"
    tracerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tracerBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    tracerBtn.Font = Enum.Font.GothamBold
    tracerBtn.TextSize = 16
    tracerBtn.Parent = content
    
    local tracerCorner = Instance.new("UICorner")
    tracerCorner.CornerRadius = UDim.new(0, 10)
    tracerCorner.Parent = tracerBtn
    
    local tracerStatus = Instance.new("TextLabel")
    tracerStatus.Size = UDim2.new(0.3, 0, 1, 0)
    tracerStatus.Position = UDim2.new(0.7, 0, 0, 0)
    tracerStatus.Text = "OFF"
    tracerStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
    tracerStatus.BackgroundTransparency = 1
    tracerStatus.Font = Enum.Font.GothamBold
    tracerStatus.TextSize = 14
    tracerStatus.TextXAlignment = Enum.TextXAlignment.Right
    tracerStatus.Parent = tracerBtn
    
    yOffset = yOffset + 65
    
    -- Setting KETEBALAN
    local thickFrame = Instance.new("Frame")
    thickFrame.Size = UDim2.new(1, 0, 0, 50)
    thickFrame.Position = UDim2.new(0, 0, 0, yOffset)
    thickFrame.BackgroundColor3 = Color3.fromRGB(34, 37, 48)
    thickFrame.BackgroundTransparency = 0.5
    thickFrame.BorderSizePixel = 0
    thickFrame.Parent = content
    
    local thickCorner = Instance.new("UICorner")
    thickCorner.CornerRadius = UDim.new(0, 10)
    thickCorner.Parent = thickFrame
    
    local thickLabel = Instance.new("TextLabel")
    thickLabel.Size = UDim2.new(0.5, 0, 1, 0)
    thickLabel.Position = UDim2.new(0, 12, 0, 0)
    thickLabel.Text = "📏 KETEBALAN"
    thickLabel.TextColor3 = Color3.fromRGB(240, 242, 250)
    thickLabel.BackgroundTransparency = 1
    thickLabel.Font = Enum.Font.GothamBold
    thickLabel.TextSize = 14
    thickLabel.TextXAlignment = Enum.TextXAlignment.Left
    thickLabel.Parent = thickFrame
    
    local thickValue = Instance.new("TextLabel")
    thickValue.Size = UDim2.new(0.3, 0, 1, 0)
    thickValue.Position = UDim2.new(0.55, 0, 0, 0)
    thickValue.Text = tostring(espThickness)
    thickValue.TextColor3 = Color3.fromRGB(155, 0, 255)
    thickValue.BackgroundTransparency = 1
    thickValue.Font = Enum.Font.GothamBold
    thickValue.TextSize = 14
    thickValue.TextXAlignment = Enum.TextXAlignment.Right
    thickValue.Parent = thickFrame
    
    local minusBtn = Instance.new("TextButton")
    minusBtn.Size = UDim2.new(0, 35, 0, 35)
    minusBtn.Position = UDim2.new(1, -80, 0.5, -17)
    minusBtn.Text = "-"
    minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.TextSize = 18
    minusBtn.Parent = thickFrame
    
    local plusBtn = Instance.new("TextButton")
    plusBtn.Size = UDim2.new(0, 35, 0, 35)
    plusBtn.Position = UDim2.new(1, -38, 0.5, -17)
    plusBtn.Text = "+"
    plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    plusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.TextSize = 18
    plusBtn.Parent = thickFrame
    
    local minusCorner = Instance.new("UICorner")
    minusCorner.CornerRadius = UDim.new(0, 8)
    minusCorner.Parent = minusBtn
    
    local plusCorner = Instance.new("UICorner")
    plusCorner.CornerRadius = UDim.new(0, 8)
    plusCorner.Parent = plusBtn
    
    -- Variabel buat tau mode mana yang aktif
    local activeMode = "box"
    local boxActive = false
    local tracerActive = false
    
    -- Fungsi update semua status tombol
    local function UpdateButtonStatus()
        if activeMode == "box" then
            if boxActive then
                boxBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 120)
                boxStatus.Text = "ON ✅"
                boxStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
            else
                boxBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                boxStatus.Text = "OFF"
                boxStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
            tracerBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            tracerStatus.Text = "OFF"
            tracerStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
        else -- tracer mode
            if tracerActive then
                tracerBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 120)
                tracerStatus.Text = "ON ✅"
                tracerStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
            else
                tracerBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                tracerStatus.Text = "OFF"
                tracerStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
            boxBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            boxStatus.Text = "OFF"
            boxStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
    
    -- Tombol BOX ESP
    boxBtn.MouseButton1Click:Connect(function()
        if activeMode == "box" then
            boxActive = not boxActive
            if boxActive then
                SwitchMode("box")
                ToggleESP()
            else
                StopESP()
                espEnabled = false
            end
        else
            activeMode = "box"
            tracerActive = false
            StopESP()
            espEnabled = false
            boxActive = true
            SwitchMode("box")
            ToggleESP()
        end
        UpdateButtonStatus()
    end)
    
    -- Tombol TRACER ESP
    tracerBtn.MouseButton1Click:Connect(function()
        if activeMode == "tracer" then
            tracerActive = not tracerActive
            if tracerActive then
                SwitchMode("tracer")
                ToggleESP()
            else
                StopESP()
                espEnabled = false
            end
        else
            activeMode = "tracer"
            boxActive = false
            StopESP()
            espEnabled = false
            tracerActive = true
            SwitchMode("tracer")
            ToggleESP()
        end
        UpdateButtonStatus()
    end)
    
    -- Ketebalan
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
    
    -- DRAG
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
    
    -- MINIMIZE
    local function ToggleMinimize()
        if minimized then
            mainFrame:TweenSize(UDim2.new(0, 280, 0, 280), "Out", "Quad", 0.2, true)
            content.Visible = true
            minBtn.Text = "─"
            minimized = false
        else
            mainFrame:TweenSize(UDim2.new(0, 160, 0, 42), "Out", "Quad", 0.2, true)
            content.Visible = false
            minBtn.Text = "□"
            minimized = true
        end
    end
    
    minBtn.MouseButton1Click:Connect(ToggleMinimize)
    
    -- CLOSE
    closeBtn.MouseButton1Click:Connect(function()
        StopESP()
        screenGui:Destroy()
        currentMenu = nil
    end)
    
    UpdateButtonStatus()
end

-- ========== LANGSUNG JALANKAN MENU ==========
CreateMainMenu()
