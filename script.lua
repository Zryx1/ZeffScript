-- ============================================
-- ZEFF VORTEX - FINAL FIX BOX ESP
-- MASTER TOGGLE (ON/OFF SEMUA ESP)
-- 3 ESP: BOX, TRACER, NAME
-- ============================================

-- ============================================
-- VARIABEL ESP
-- ============================================
local masterEnabled = false
local espBoxEnabled = false
local espTracerEnabled = false
local espNameEnabled = false
local espColor = Color3.fromRGB(155, 0, 255)
local espThickness = 2

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Storage untuk semua ESP
local espList = {}

-- ============================================
-- FUNGSI MEMBUAT ESP UNTUK 1 PLAYER
-- ============================================
local function CreateESP(player)
    if player == LocalPlayer then return end
    if espList[player] then return end
    
    local esp = {}
    
    -- BOX
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = espColor
    box.Thickness = espThickness
    box.Filled = false
    box.Transparency = 0.5
    esp.box = box
    
    -- TRACER
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = espColor
    tracer.Thickness = espThickness
    tracer.Transparency = 0.5
    esp.tracer = tracer
    
    -- NAME
    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Color = espColor
    nameTag.Size = 14
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.nameTag = nameTag
    
    esp.player = player
    espList[player] = esp
end

-- ============================================
-- FUNGSI HAPUS ESP
-- ============================================
local function RemoveESP(player)
    local esp = espList[player]
    if esp then
        if esp.box then esp.box:Remove() end
        if esp.tracer then esp.tracer:Remove() end
        if esp.nameTag then esp.nameTag:Remove() end
        espList[player] = nil
    end
end

-- ============================================
-- UPDATE BOX (HITUNG POSISI & UKURAN)
-- ============================================
local function UpdateBox(box, rootPart)
    if not box or not rootPart then return end
    
    local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen then
        box.Visible = false
        return
    end
    
    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
    local boxSize = math.clamp(200 / distance, 30, 120)
    
    local boxX = vector.X - boxSize / 2
    local boxY = vector.Y - boxSize / 1.2
    
    box.Size = Vector2.new(boxSize, boxSize)
    box.Position = Vector2.new(boxX, boxY)
    box.Visible = true
end

-- ============================================
-- UPDATE TRACER
-- ============================================
local function UpdateTracer(tracer, rootPart, center)
    if not tracer or not rootPart then return end
    
    local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen then
        tracer.Visible = false
        return
    end
    
    tracer.From = center
    tracer.To = Vector2.new(vector.X, vector.Y)
    tracer.Visible = true
end

-- ============================================
-- UPDATE NAME
-- ============================================
local function UpdateName(nameTag, player, rootPart)
    if not nameTag or not rootPart then return end
    
    local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen then
        nameTag.Visible = false
        return
    end
    
    nameTag.Text = player.Name
    nameTag.Position = Vector2.new(vector.X, vector.Y - 25)
    nameTag.Visible = true
end

-- ============================================
-- UPDATE SEMUA ESP (PER FRAME)
-- ============================================
local function UpdateAllESP()
    if not masterEnabled then
        -- Sembunyikan semua
        for _, esp in pairs(espList) do
            if esp.box then esp.box.Visible = false end
            if esp.tracer then esp.tracer.Visible = false end
            if esp.nameTag then esp.nameTag.Visible = false end
        end
        return
    end
    
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, esp in pairs(espList) do
        local character = esp.player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        local isValid = character and humanoid and rootPart and humanoid.Health > 0
        
        if not isValid then
            if esp.box then esp.box.Visible = false end
            if esp.tracer then esp.tracer.Visible = false end
            if esp.nameTag then esp.nameTag.Visible = false end
        else
            -- Update BOX
            if espBoxEnabled and esp.box then
                UpdateBox(esp.box, rootPart)
            elseif esp.box then
                esp.box.Visible = false
            end
            
            -- Update TRACER
            if espTracerEnabled and esp.tracer then
                UpdateTracer(esp.tracer, rootPart, center)
            elseif esp.tracer then
                esp.tracer.Visible = false
            end
            
            -- Update NAME
            if espNameEnabled and esp.nameTag then
                UpdateName(esp.nameTag, esp.player, rootPart)
            elseif esp.nameTag then
                esp.nameTag.Visible = false
            end
        end
    end
end

-- ============================================
-- REFRESH WARNA & KETEBALAN
-- ============================================
local function RefreshStyle()
    for _, esp in pairs(espList) do
        if esp.box then
            esp.box.Color = espColor
            esp.box.Thickness = espThickness
        end
        if esp.tracer then
            esp.tracer.Color = espColor
            esp.tracer.Thickness = espThickness
        end
        if esp.nameTag then
            esp.nameTag.Color = espColor
        end
    end
end

-- ============================================
-- INITIAL PLAYERS
-- ============================================
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end)

Players.PlayerRemoving:Connect(RemoveESP)

-- ============================================
-- LOOP UPDATE
-- ============================================
RunService.RenderStepped:Connect(UpdateAllESP)

-- ============================================
-- MENU UTAMA
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
    
    local success = pcall(function()
        screenGui.Parent = (gethui and gethui()) or CoreGui
    end)
    if not success then
        screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    currentMenu = screenGui
    
    -- MAIN FRAME
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 340)
    mainFrame.Position = UDim2.new(0.5, -140, 0.5, -170)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    mainFrame.BackgroundTransparency = 0
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame
    
    local border = Instance.new("UIStroke")
    border.Thickness = 1
    border.Color = Color3.fromRGB(155, 0, 255)
    border.Transparency = 0.3
    border.Parent = mainFrame
    
    -- HEADER
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
    header.BackgroundTransparency = 0.15
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0.03, 0, 0, 0)
    title.Text = "🔮 ZEFF VORTEX"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 28, 0, 28)
    minBtn.Position = UDim2.new(1, -62, 0.5, -14)
    minBtn.Text = "─"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.BackgroundTransparency = 1
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 16
    minBtn.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -32, 0.5, -14)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = header
    
    -- CONTENT
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -16, 1, -54)
    content.Position = UDim2.new(0, 8, 0, 48)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    local yOffset = 0
    
    -- MASTER TOGGLE
    local masterBtn = Instance.new("TextButton")
    masterBtn.Size = UDim2.new(1, 0, 0, 45)
    masterBtn.Position = UDim2.new(0, 0, 0, yOffset)
    masterBtn.Text = "🔘 MASTER ESP"
    masterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    masterBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 120)
    masterBtn.Font = Enum.Font.GothamBold
    masterBtn.TextSize = 14
    masterBtn.Parent = content
    
    local masterCorner = Instance.new("UICorner")
    masterCorner.CornerRadius = UDim.new(0, 8)
    masterCorner.Parent = masterBtn
    
    local masterStatus = Instance.new("TextLabel")
    masterStatus.Size = UDim2.new(0.35, 0, 1, 0)
    masterStatus.Position = UDim2.new(0.65, 0, 0, 0)
    masterStatus.Text = "OFF"
    masterStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
    masterStatus.BackgroundTransparency = 1
    masterStatus.Font = Enum.Font.GothamBold
    masterStatus.TextSize = 13
    masterStatus.TextXAlignment = Enum.TextXAlignment.Right
    masterStatus.Parent = masterBtn
    
    yOffset = yOffset + 53
    
    -- BOX ESP
    local boxBtn = Instance.new("TextButton")
    boxBtn.Size = UDim2.new(1, 0, 0, 40)
    boxBtn.Position = UDim2.new(0, 0, 0, yOffset)
    boxBtn.Text = "📦 BOX ESP"
    boxBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    boxBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    boxBtn.Font = Enum.Font.GothamBold
    boxBtn.TextSize = 13
    boxBtn.Parent = content
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 8)
    boxCorner.Parent = boxBtn
    
    local boxStatus = Instance.new("TextLabel")
    boxStatus.Size = UDim2.new(0.35, 0, 1, 0)
    boxStatus.Position = UDim2.new(0.65, 0, 0, 0)
    boxStatus.Text = "OFF"
    boxStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
    boxStatus.BackgroundTransparency = 1
    boxStatus.Font = Enum.Font.GothamBold
    boxStatus.TextSize = 12
    boxStatus.TextXAlignment = Enum.TextXAlignment.Right
    boxStatus.Parent = boxBtn
    
    yOffset = yOffset + 48
    
    -- TRACER ESP
    local tracerBtn = Instance.new("TextButton")
    tracerBtn.Size = UDim2.new(1, 0, 0, 40)
    tracerBtn.Position = UDim2.new(0, 0, 0, yOffset)
    tracerBtn.Text = "📏 TRACER ESP"
    tracerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tracerBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    tracerBtn.Font = Enum.Font.GothamBold
    tracerBtn.TextSize = 13
    tracerBtn.Parent = content
    
    local tracerCorner = Instance.new("UICorner")
    tracerCorner.CornerRadius = UDim.new(0, 8)
    tracerCorner.Parent = tracerBtn
    
    local tracerStatus = Instance.new("TextLabel")
    tracerStatus.Size = UDim2.new(0.35, 0, 1, 0)
    tracerStatus.Position = UDim2.new(0.65, 0, 0, 0)
    tracerStatus.Text = "OFF"
    tracerStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
    tracerStatus.BackgroundTransparency = 1
    tracerStatus.Font = Enum.Font.GothamBold
    tracerStatus.TextSize = 12
    tracerStatus.TextXAlignment = Enum.TextXAlignment.Right
    tracerStatus.Parent = tracerBtn
    
    yOffset = yOffset + 48
    
    -- NAME ESP
    local nameBtn = Instance.new("TextButton")
    nameBtn.Size = UDim2.new(1, 0, 0, 40)
    nameBtn.Position = UDim2.new(0, 0, 0, yOffset)
    nameBtn.Text = "🏷️ NAME ESP"
    nameBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    nameBtn.Font = Enum.Font.GothamBold
    nameBtn.TextSize = 13
    nameBtn.Parent = content
    
    local nameCorner = Instance.new("UICorner")
    nameCorner.CornerRadius = UDim.new(0, 8)
    nameCorner.Parent = nameBtn
    
    local nameStatus = Instance.new("TextLabel")
    nameStatus.Size = UDim2.new(0.35, 0, 1, 0)
    nameStatus.Position = UDim2.new(0.65, 0, 0, 0)
    nameStatus.Text = "OFF"
    nameStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
    nameStatus.BackgroundTransparency = 1
    nameStatus.Font = Enum.Font.GothamBold
    nameStatus.TextSize = 12
    nameStatus.TextXAlignment = Enum.TextXAlignment.Right
    nameStatus.Parent = nameBtn
    
    yOffset = yOffset + 48
    
    -- KETEBALAN
    local thickFrame = Instance.new("Frame")
    thickFrame.Size = UDim2.new(1, 0, 0, 45)
    thickFrame.Position = UDim2.new(0, 0, 0, yOffset)
    thickFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    thickFrame.BackgroundTransparency = 0
    thickFrame.BorderSizePixel = 0
    thickFrame.Parent = content
    
    local thickCorner = Instance.new("UICorner")
    thickCorner.CornerRadius = UDim.new(0, 8)
    thickCorner.Parent = thickFrame
    
    local thickLabel = Instance.new("TextLabel")
    thickLabel.Size = UDim2.new(0.45, 0, 1, 0)
    thickLabel.Position = UDim2.new(0, 10, 0, 0)
    thickLabel.Text = "📏 KETEBALAN"
    thickLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    thickLabel.BackgroundTransparency = 1
    thickLabel.Font = Enum.Font.GothamBold
    thickLabel.TextSize = 12
    thickLabel.TextXAlignment = Enum.TextXAlignment.Left
    thickLabel.Parent = thickFrame
    
    local thickValue = Instance.new("TextLabel")
    thickValue.Size = UDim2.new(0.2, 0, 1, 0)
    thickValue.Position = UDim2.new(0.5, 0, 0, 0)
    thickValue.Text = tostring(espThickness)
    thickValue.TextColor3 = Color3.fromRGB(155, 0, 255)
    thickValue.BackgroundTransparency = 1
    thickValue.Font = Enum.Font.GothamBold
    thickValue.TextSize = 13
    thickValue.TextXAlignment = Enum.TextXAlignment.Center
    thickValue.Parent = thickFrame
    
    local minusBtn = Instance.new("TextButton")
    minusBtn.Size = UDim2.new(0, 30, 0, 30)
    minusBtn.Position = UDim2.new(1, -70, 0.5, -15)
    minusBtn.Text = "-"
    minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minusBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.TextSize = 16
    minusBtn.Parent = thickFrame
    
    local plusBtn = Instance.new("TextButton")
    plusBtn.Size = UDim2.new(0, 30, 0, 30)
    plusBtn.Position = UDim2.new(1, -35, 0.5, -15)
    plusBtn.Text = "+"
    plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    plusBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.TextSize = 16
    plusBtn.Parent = thickFrame
    
    local minusCorner = Instance.new("UICorner")
    minusCorner.CornerRadius = UDim.new(0, 6)
    minusCorner.Parent = minusBtn
    
    local plusCorner = Instance.new("UICorner")
    plusCorner.CornerRadius = UDim.new(0, 6)
    plusCorner.Parent = plusBtn
    
    -- UPDATE BUTTONS
    local function UpdateButtons()
        -- MASTER
        if masterEnabled then
            masterStatus.Text = "ON ✅"
            masterStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
            masterBtn.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
        else
            masterStatus.Text = "OFF"
            masterStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
            masterBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 120)
        end
        
        -- BOX (hanya warna, tidak mati karena master)
        boxStatus.Text = espBoxEnabled and "ON ✅" or "OFF"
        boxStatus.TextColor3 = espBoxEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        boxBtn.BackgroundColor3 = espBoxEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
        
        -- TRACER
        tracerStatus.Text = espTracerEnabled and "ON ✅" or "OFF"
        tracerStatus.TextColor3 = espTracerEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        tracerBtn.BackgroundColor3 = espTracerEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
        
        -- NAME
        nameStatus.Text = espNameEnabled and "ON ✅" or "OFF"
        nameStatus.TextColor3 = espNameEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        nameBtn.BackgroundColor3 = espNameEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
    end
    
    -- MASTER BUTTON (ON/OFF semua ESP, bukan matiin fitur)
    masterBtn.MouseButton1Click:Connect(function()
        masterEnabled = not masterEnabled
        UpdateButtons()
    end)
    
    -- BOX BUTTON
    boxBtn.MouseButton1Click:Connect(function()
        espBoxEnabled = not espBoxEnabled
        UpdateButtons()
    end)
    
    -- TRACER BUTTON
    tracerBtn.MouseButton1Click:Connect(function()
        espTracerEnabled = not espTracerEnabled
        UpdateButtons()
    end)
    
    -- NAME BUTTON
    nameBtn.MouseButton1Click:Connect(function()
        espNameEnabled = not espNameEnabled
        UpdateButtons()
    end)
    
    -- KETEBALAN
    minusBtn.MouseButton1Click:Connect(function()
        espThickness = math.max(1, espThickness - 1)
        thickValue.Text = tostring(espThickness)
        RefreshStyle()
    end)
    
    plusBtn.MouseButton1Click:Connect(function()
        espThickness = math.min(5, espThickness + 1)
        thickValue.Text = tostring(espThickness)
        RefreshStyle()
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
            mainFrame:TweenSize(UDim2.new(0, 280, 0, 340), "Out", "Quad", 0.2, true)
            content.Visible = true
            minBtn.Text = "─"
            minimized = false
        else
            mainFrame:TweenSize(UDim2.new(0, 180, 0, 40), "Out", "Quad", 0.2, true)
            content.Visible = false
            minBtn.Text = "□"
            minimized = true
        end
    end
    
    minBtn.MouseButton1Click:Connect(ToggleMinimize)
    
    -- CLOSE
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        currentMenu = nil
    end)
    
    UpdateButtons()
end

-- ============================================
-- START
-- ============================================
CreateMainMenu()
