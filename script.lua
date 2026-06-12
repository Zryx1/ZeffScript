-- ============================================
-- ZEFF VORTEX - FULL SCRIPT
-- MENU ESP (YANG UDAH JALAN) + KATEGORI DI ATAS
-- FITUR: ESP + MULTI HIT + SPEED/JUMP BOOST
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

-- ============================================
-- VARIABEL MULTI HIT
-- ============================================
local multiHitEnabled = false
local mhRange = 20
local mhDamage = 10
local mhTargets = 10
local mhHitsPerSec = 5
local mhMode = "players"  -- "players" or "all"

-- ============================================
-- VARIABEL SPEED & JUMP
-- ============================================
local speedEnabled = false
local speedMult = 1
local jumpEnabled = false
local jumpMult = 1
local originalWalkSpeed = 16
local originalJumpPower = 50

-- ============================================
-- VARIABEL UI
-- ============================================
local minimized = false
local currentMenu = nil
local currentTab = "esp"

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
-- UPDATE BOX
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
-- UPDATE SEMUA ESP
-- ============================================
local function UpdateAllESP()
    if not masterEnabled then
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
            if espBoxEnabled and esp.box then
                UpdateBox(esp.box, rootPart)
            elseif esp.box then
                esp.box.Visible = false
            end
            
            if espTracerEnabled and esp.tracer then
                UpdateTracer(esp.tracer, rootPart, center)
            elseif esp.tracer then
                esp.tracer.Visible = false
            end
            
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
-- SPEED & JUMP FUNCTIONS
-- ============================================
local function ApplySpeed()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        if speedEnabled then
            char.Humanoid.WalkSpeed = originalWalkSpeed * speedMult
        else
            char.Humanoid.WalkSpeed = originalWalkSpeed
        end
    end
end

local function ApplyJump()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        if jumpEnabled then
            char.Humanoid.JumpPower = originalJumpPower * jumpMult
        else
            char.Humanoid.JumpPower = originalJumpPower
        end
    end
end

-- ============================================
-- MULTI HIT FUNCTIONS
-- ============================================
local function GetTargets()
    local targets = {}
    local char = LocalPlayer.Character
    if not char then return targets end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return targets end
    
    if mhMode == "players" then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local c = p.Character
                if c then
                    local r = c:FindFirstChild("HumanoidRootPart")
                    if r and (root.Position - r.Position).Magnitude <= mhRange then
                        local h = c:FindFirstChild("Humanoid")
                        if h and h.Health > 0 then
                            table.insert(targets, h)
                        end
                    end
                end
            end
        end
    else
        local function scan(inst)
            for _, child in ipairs(inst:GetChildren()) do
                if child:IsA("Model") and child ~= char then
                    local h = child:FindFirstChild("Humanoid")
                    local r = child:FindFirstChild("HumanoidRootPart") or child:FindFirstChild("Head")
                    if h and r and h.Health > 0 and (root.Position - r.Position).Magnitude <= mhRange then
                        table.insert(targets, h)
                    end
                end
                scan(child)
            end
        end
        scan(workspace)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local c = p.Character
                if c then
                    local r = c:FindFirstChild("HumanoidRootPart")
                    if r and (root.Position - r.Position).Magnitude <= mhRange then
                        local h = c:FindFirstChild("Humanoid")
                        if h and h.Health > 0 then
                            table.insert(targets, h)
                        end
                    end
                end
            end
        end
    end
    
    if #targets > mhTargets then
        local limited = {}
        for i = 1, mhTargets do limited[i] = targets[i] end
        return limited
    end
    return targets
end

local function DoMultiHit()
    if not multiHitEnabled then return end
    for _, h in ipairs(GetTargets()) do
        h.Health = h.Health - mhDamage
    end
end

-- ============================================
-- TOMBOL PEDANG (ON/OFF MULTI HIT, BISA DIGESER)
-- ============================================
local swordBtn = nil
local screenGui = nil

local function CreateSwordButton()
    local CoreGui = game:GetService("CoreGui")
    if not screenGui then return end
    
    swordBtn = Instance.new("TextButton")
    swordBtn.Size = UDim2.new(0, 50, 0, 50)
    swordBtn.Position = UDim2.new(1, -65, 1, -180)
    swordBtn.Text = "⚔️"
    swordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    swordBtn.TextSize = 26
    swordBtn.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
    swordBtn.BackgroundTransparency = 0.2
    swordBtn.BorderSizePixel = 0
    swordBtn.Parent = screenGui
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 25)
    btnCorner.Parent = swordBtn
    
    local led = Instance.new("Frame")
    led.Size = UDim2.new(0, 10, 0, 10)
    led.Position = UDim2.new(1, -12, 1, -12)
    led.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    led.BorderSizePixel = 0
    led.Parent = swordBtn
    local ledCorner = Instance.new("UICorner")
    ledCorner.CornerRadius = UDim.new(1, 0)
    ledCorner.Parent = led
    
    -- DRAG TOMBOL PEDANG
    local dragStart, startPos, isDragging = nil, nil, false
    swordBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = swordBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then isDragging = false end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if not isDragging then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newX = math.clamp(startPos.X.Offset + delta.X, 0, UDim2.new(1, -55, 0, 0).X.Offset)
            local newY = math.clamp(startPos.Y.Offset + delta.Y, 0, UDim2.new(0, 0, 1, -55).Y.Offset)
            swordBtn.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
        end
    end)
    
    -- KLIK = ON/OFF MULTI HIT
    swordBtn.MouseButton1Click:Connect(function()
        multiHitEnabled = not multiHitEnabled
        led.BackgroundColor3 = multiHitEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)
end

-- ============================================
-- MENU UTAMA (DENGAN KATEGORI DI ATAS)
-- ============================================
local function CreateMainMenu()
    if currentMenu then
        currentMenu:Destroy()
        currentMenu = nil
    end
    
    local CoreGui = game:GetService("CoreGui")
    
    screenGui = Instance.new("ScreenGui")
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
    mainFrame.Size = UDim2.new(0, 320, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
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
    header.Size = UDim2.new(1, 0, 0, 42)
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
    title.Text = "⚔️ ZEFF VORTEX"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
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
    
    -- ========== KATEGORI DI ATAS ==========
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, -20, 0, 38)
    tabBar.Position = UDim2.new(0, 10, 0, 50)
    tabBar.BackgroundTransparency = 1
    tabBar.Parent = mainFrame
    
    local espTab = Instance.new("TextButton")
    espTab.Size = UDim2.new(0.3, -4, 1, 0)
    espTab.Position = UDim2.new(0, 0, 0, 0)
    espTab.Text = "🎮 ESP"
    espTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    espTab.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
    espTab.Font = Enum.Font.GothamBold
    espTab.TextSize = 12
    espTab.Parent = tabBar
    
    local multiTab = Instance.new("TextButton")
    multiTab.Size = UDim2.new(0.33, -4, 1, 0)
    multiTab.Position = UDim2.new(0.32, 4, 0, 0)
    multiTab.Text = "⚔️ MULTI HIT"
    multiTab.TextColor3 = Color3.fromRGB(200, 200, 220)
    multiTab.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    multiTab.Font = Enum.Font.GothamBold
    multiTab.TextSize = 12
    multiTab.Parent = tabBar
    
    local boostTab = Instance.new("TextButton")
    boostTab.Size = UDim2.new(0.33, -4, 1, 0)
    boostTab.Position = UDim2.new(0.64, 8, 0, 0)
    boostTab.Text = "🏃 BOOST"
    boostTab.TextColor3 = Color3.fromRGB(200, 200, 220)
    boostTab.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    boostTab.Font = Enum.Font.GothamBold
    boostTab.TextSize = 12
    boostTab.Parent = tabBar
    
    -- ========== CONTENT (BEDA BEDA PER TAB) ==========
    local contentContainer = Instance.new("ScrollingFrame")
    contentContainer.Size = UDim2.new(1, -16, 1, -140)
    contentContainer.Position = UDim2.new(0, 8, 0, 98)
    contentContainer.BackgroundTransparency = 1
    contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentContainer.ScrollBarThickness = 3
    contentContainer.ScrollBarImageColor3 = Color3.fromRGB(155, 0, 255)
    contentContainer.Parent = mainFrame
    
    -- ========== TAB 1: ESP CONTENT ==========
    local espContent = Instance.new("Frame")
    espContent.Size = UDim2.new(1, 0, 1, 0)
    espContent.BackgroundTransparency = 1
    espContent.Visible = true
    espContent.Parent = contentContainer
    
    local yEsp = 0
    
    local masterBtn = CreateToggleButton(espContent, "🔘 MASTER ESP", yEsp, masterEnabled)
    yEsp = yEsp + 48
    local boxBtn = CreateToggleButton(espContent, "📦 BOX ESP", yEsp, espBoxEnabled)
    yEsp = yEsp + 43
    local tracerBtn = CreateToggleButton(espContent, "📏 TRACER ESP", yEsp, espTracerEnabled)
    yEsp = yEsp + 43
    local nameBtn = CreateToggleButton(espContent, "🏷️ NAME ESP", yEsp, espNameEnabled)
    yEsp = yEsp + 43
    local thickControl = CreateSliderControl(espContent, "📏 KETEBALAN", yEsp, espThickness, 1, 5)
    yEsp = yEsp + 50
    espContent.CanvasSize = UDim2.new(0, 0, 0, yEsp + 10)
    
    -- ========== TAB 2: MULTI HIT CONTENT ==========
    local multiContent = Instance.new("Frame")
    multiContent.Size = UDim2.new(1, 0, 1, 0)
    multiContent.BackgroundTransparency = 1
    multiContent.Visible = false
    multiContent.Parent = contentContainer
    
    local yMulti = 0
    
    -- Status Multi Hit
    local mhStatusFrame = CreateInfoBox(multiContent, "⚔️ MULTI HIT STATUS", yMulti, multiHitEnabled)
    yMulti = yMulti + 50
    
    local rangeControl = CreateSliderControl(multiContent, "📏 RADIUS (M)", yMulti, mhRange, 5, 20)
    yMulti = yMulti + 50
    local damageControl = CreateSliderControl(multiContent, "💥 DAMAGE", yMulti, mhDamage, 1, 25)
    yMulti = yMulti + 50
    local targetControl = CreateSliderControl(multiContent, "🎯 TARGET", yMulti, mhTargets, 1, 20)
    yMulti = yMulti + 50
    local hitsControl = CreateSliderControl(multiContent, "⚡ HIT/DETIK", yMulti, mhHitsPerSec, 1, 10)
    yMulti = yMulti + 50
    
    -- Mode Toggle
    local modeBtn = CreateModeToggle(multiContent, "🎯 TARGET MODE", yMulti, mhMode)
    yMulti = yMulti + 48
    multiContent.CanvasSize = UDim2.new(0, 0, 0, yMulti + 10)
    
    -- ========== TAB 3: BOOST CONTENT ==========
    local boostContent = Instance.new("Frame")
    boostContent.Size = UDim2.new(1, 0, 1, 0)
    boostContent.BackgroundTransparency = 1
    boostContent.Visible = false
    boostContent.Parent = contentContainer
    
    local yBoost = 0
    
    local speedBtn = CreateToggleButton(boostContent, "⚡ SPEED BOOST", yBoost, speedEnabled)
    yBoost = yBoost + 48
    local speedControl = CreateSliderControl(boostContent, "🏃 SPEED (x)", yBoost, speedMult, 1, 100)
    yBoost = yBoost + 50
    
    local jumpBtn = CreateToggleButton(boostContent, "🦘 JUMP BOOST", yBoost, jumpEnabled)
    yBoost = yBoost + 48
    local jumpControl = CreateSliderControl(boostContent, "📈 JUMP (x)", yBoost, jumpMult, 1, 100)
    yBoost = yBoost + 50
    boostContent.CanvasSize = UDim2.new(0, 0, 0, yBoost + 10)
    
    -- ========== FUNGSI CREATE UI ==========
    function CreateInfoBox(parent, text, yPos, state)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 40)
        frame.Position = UDim2.new(0, 0, 0, yPos)
        frame.BackgroundColor3 = state and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
        frame.BackgroundTransparency = 0
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(0.35, 0, 1, 0)
        status.Position = UDim2.new(0.65, 0, 0, 0)
        status.Text = state and "✅ ACTIVE" or "❌ INACTIVE"
        status.TextColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        status.BackgroundTransparency = 1
        status.Font = Enum.Font.GothamBold
        status.TextSize = 11
        status.TextXAlignment = Enum.TextXAlignment.Right
        status.Parent = frame
        
        return {frame = frame, status = status}
    end
    
    function CreateToggleButton(parent, text, yPos, state)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 38)
        btn.Position = UDim2.new(0, 0, 0, yPos)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundColor3 = state and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = parent
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 12)
        pad.Parent = btn
        
        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(0.35, 0, 1, 0)
        status.Position = UDim2.new(0.65, 0, 0, 0)
        status.Text = state and "✅ ON" or "❌ OFF"
        status.TextColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        status.BackgroundTransparency = 1
        status.Font = Enum.Font.GothamBold
        status.TextSize = 12
        status.TextXAlignment = Enum.TextXAlignment.Right
        status.Parent = btn
        
        return btn, status
    end
    
    function CreateSliderControl(parent, label, yPos, value, minVal, maxVal)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 44)
        frame.Position = UDim2.new(0, 0, 0, yPos)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
        frame.BackgroundTransparency = 0
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame
        
        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(0.45, 0, 1, 0)
        labelText.Position = UDim2.new(0, 10, 0, 0)
        labelText.Text = label
        labelText.TextColor3 = Color3.fromRGB(200, 200, 220)
        labelText.BackgroundTransparency = 1
        labelText.Font = Enum.Font.GothamBold
        labelText.TextSize = 11
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = frame
        
        local valueText = Instance.new("TextLabel")
        valueText.Size = UDim2.new(0.2, 0, 1, 0)
        valueText.Position = UDim2.new(0.5, 0, 0, 0)
        valueText.Text = tostring(value)
        valueText.TextColor3 = Color3.fromRGB(155, 0, 255)
        valueText.BackgroundTransparency = 1
        valueText.Font = Enum.Font.GothamBold
        valueText.TextSize = 12
        valueText.TextXAlignment = Enum.TextXAlignment.Center
        valueText.Parent = frame
        
        local minus = Instance.new("TextButton")
        minus.Size = UDim2.new(0, 28, 0, 28)
        minus.Position = UDim2.new(1, -65, 0.5, -14)
        minus.Text = "-"
        minus.TextColor3 = Color3.fromRGB(255, 255, 255)
        minus.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        minus.Font = Enum.Font.GothamBold
        minus.TextSize = 16
        minus.Parent = frame
        
        local plus = Instance.new("TextButton")
        plus.Size = UDim2.new(0, 28, 0, 28)
        plus.Position = UDim2.new(1, -33, 0.5, -14)
        plus.Text = "+"
        plus.TextColor3 = Color3.fromRGB(255, 255, 255)
        plus.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        plus.Font = Enum.Font.GothamBold
        plus.TextSize = 16
        plus.Parent = frame
        
        local btnCorner1 = Instance.new("UICorner")
        btnCorner1.CornerRadius = UDim.new(0, 6)
        btnCorner1.Parent = minus
        
        local btnCorner2 = Instance.new("UICorner")
        btnCorner2.CornerRadius = UDim.new(0, 6)
        btnCorner2.Parent = plus
        
        return {frame = frame, valueText = valueText, minus = minus, plus = plus}
    end
    
    function CreateModeToggle(parent, label, yPos, mode)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 40)
        frame.Position = UDim2.new(0, 0, 0, yPos)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
        frame.BackgroundTransparency = 0
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame
        
        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(0.5, 0, 1, 0)
        labelText.Position = UDim2.new(0, 10, 0, 0)
        labelText.Text = label
        labelText.TextColor3 = Color3.fromRGB(200, 200, 220)
        labelText.BackgroundTransparency = 1
        labelText.Font = Enum.Font.GothamBold
        labelText.TextSize = 11
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = frame
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.4, 0, 0.7, 0)
        btn.Position = UDim2.new(0.55, 0, 0.15, 0)
        btn.Text = (mode == "players") and "👤 PLAYERS" or "👾 ALL ENTITY"
        btn.TextColor3 = Color3.fromRGB(155, 0, 255)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10
        btn.Parent = frame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        return btn
    end
    
    -- ========== TAB SWITCH ==========
    local function SwitchTab(tab)
        currentTab = tab
        espTab.BackgroundColor3 = tab == "esp" and Color3.fromRGB(155, 0, 255) or Color3.fromRGB(35, 35, 50)
        espTab.TextColor3 = tab == "esp" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 220)
        multiTab.BackgroundColor3 = tab == "multi" and Color3.fromRGB(155, 0, 255) or Color3.fromRGB(35, 35, 50)
        multiTab.TextColor3 = tab == "multi" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 220)
        boostTab.BackgroundColor3 = tab == "boost" and Color3.fromRGB(155, 0, 255) or Color3.fromRGB(35, 35, 50)
        boostTab.TextColor3 = tab == "boost" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 220)
        
        espContent.Visible = (tab == "esp")
        multiContent.Visible = (tab == "multi")
        boostContent.Visible = (tab == "boost")
    end
    
    espTab.MouseButton1Click:Connect(function() SwitchTab("esp") end)
    multiTab.MouseButton1Click:Connect(function() SwitchTab("multi") end)
    boostTab.MouseButton1Click:Connect(function() SwitchTab("boost") end)
    
    -- ========== BUTTON ACTIONS ==========
    -- ESP Actions
    masterBtn.MouseButton1Click:Connect(function()
        masterEnabled = not masterEnabled
        masterStatus.Text = masterEnabled and "✅ ON" or "❌ OFF"
        masterStatus.TextColor3 = masterEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        masterBtn.BackgroundColor3 = masterEnabled and Color3.fromRGB(155, 0, 255) or Color3.fromRGB(80, 0, 120)
    end)
    
    boxBtn.MouseButton1Click:Connect(function()
        espBoxEnabled = not espBoxEnabled
        boxStatus.Text = espBoxEnabled and "✅ ON" or "❌ OFF"
        boxStatus.TextColor3 = espBoxEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        boxBtn.BackgroundColor3 = espBoxEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
    end)
    
    tracerBtn.MouseButton1Click:Connect(function()
        espTracerEnabled = not espTracerEnabled
        tracerStatus.Text = espTracerEnabled and "✅ ON" or "❌ OFF"
        tracerStatus.TextColor3 = espTracerEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        tracerBtn.BackgroundColor3 = espTracerEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
    end)
    
    nameBtn.MouseButton1Click:Connect(function()
        espNameEnabled = not espNameEnabled
        nameStatus.Text = espNameEnabled and "✅ ON" or "❌ OFF"
        nameStatus.TextColor3 = espNameEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        nameBtn.BackgroundColor3 = espNameEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
    end)
    
    thickControl.minus.MouseButton1Click:Connect(function()
        espThickness = math.max(1, espThickness - 1)
        thickControl.valueText.Text = tostring(espThickness)
        RefreshStyle()
    end)
    thickControl.plus.MouseButton1Click:Connect(function()
        espThickness = math.min(5, espThickness + 1)
        thickControl.valueText.Text = tostring(espThickness)
        RefreshStyle()
    end)
    
    -- Multi Hit Actions
    rangeControl.minus.MouseButton1Click:Connect(function()
        mhRange = math.max(5, mhRange - 1)
        rangeControl.valueText.Text = tostring(mhRange)
    end)
    rangeControl.plus.MouseButton1Click:Connect(function()
        mhRange = math.min(20, mhRange + 1)
        rangeControl.valueText.Text = tostring(mhRange)
    end)
    
    damageControl.minus.MouseButton1Click:Connect(function()
        mhDamage = math.max(1, mhDamage - 1)
        damageControl.valueText.Text = tostring(mhDamage)
    end)
    damageControl.plus.MouseButton1Click:Connect(function()
        mhDamage = math.min(25, mhDamage + 1)
        damageControl.valueText.Text = tostring(mhDamage)
    end)
    
    targetControl.minus.MouseButton1Click:Connect(function()
        mhTargets = math.max(1, mhTargets - 1)
        targetControl.valueText.Text = tostring(mhTargets)
    end)
    targetControl.plus.MouseButton1Click:Connect(function()
        mhTargets = math.min(20, mhTargets + 1)
        targetControl.valueText.Text = tostring(mhTargets)
    end)
    
    hitsControl.minus.MouseButton1Click:Connect(function()
        mhHitsPerSec = math.max(1, mhHitsPerSec - 1)
        hitsControl.valueText.Text = tostring(mhHitsPerSec)
    end)
    hitsControl.plus.MouseButton1Click:Connect(function()
        mhHitsPerSec = math.min(10, mhHitsPerSec + 1)
        hitsControl.valueText.Text = tostring(mhHitsPerSec)
    end)
    
    modeBtn.MouseButton1Click:Connect(function()
        mhMode = (mhMode == "players") and "all" or "players"
        modeBtn.Text = (mhMode == "players") and "👤 PLAYERS" or "👾 ALL ENTITY"
    end)
    
    -- Boost Actions
    speedBtn.MouseButton1Click:Connect(function()
        speedEnabled = not speedEnabled
        speedStatus.Text = speedEnabled and "✅ ON" or "❌ OFF"
        speedStatus.TextColor3 = speedEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        speedBtn.BackgroundColor3 = speedEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
        ApplySpeed()
    end)
    
    speedControl.minus.MouseButton1Click:Connect(function()
        speedMult = math.max(1, speedMult - 1)
        speedControl.valueText.Text = speedMult .. "x"
        ApplySpeed()
    end)
    speedControl.plus.MouseButton1Click:Connect(function()
        speedMult = math.min(100, speedMult + 1)
        speedControl.valueText.Text = speedMult .. "x"
        ApplySpeed()
    end)
    
    jumpBtn.MouseButton1Click:Connect(function()
        jumpEnabled = not jumpEnabled
        jumpStatus.Text = jumpEnabled and "✅ ON" or "❌ OFF"
        jumpStatus.TextColor3 = jumpEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        jumpBtn.BackgroundColor3 = jumpEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
        ApplyJump()
    end)
    
    jumpControl.minus.MouseButton1Click:Connect(function()
        jumpMult = math.max(1, jumpMult - 1)
        jumpControl.valueText.Text = jumpMult .. "x"
        ApplyJump()
    end)
    jumpControl.plus.MouseButton1Click:Connect(function()
        jumpMult = math.min(100, jumpMult + 1)
        jumpControl.valueText.Text = jumpMult .. "x"
        ApplyJump()
    end)
    
    -- ========== DRAG MENU ==========
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
    
    -- ========== MINIMIZE ==========
    local function ToggleMinimize()
        if minimized then
            mainFrame:TweenSize(UDim2.new(0, 320, 0, 450), "Out", "Quad", 0.2, true)
            tabBar.Visible = true
            contentContainer.Visible = true
            minBtn.Text = "─"
            minimized = false
        else
            mainFrame:TweenSize(UDim2.new(0, 180, 0, 42), "Out", "Quad", 0.2, true)
            tabBar.Visible = false
            contentContainer.Visible = false
            minBtn.Text = "□"
            minimized = true
        end
    end
    
    minBtn.MouseButton1Click:Connect(ToggleMinimize)
    
    -- CLOSE
    closeBtn.MouseButton1Click:Connect(function()
        if screenGui then screenGui:Destroy() end
        currentMenu = nil
    end)
end

-- ============================================
-- INITIAL PLAYERS & LOOP
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

RunService.RenderStepped:Connect(UpdateAllESP)

-- Speed & Jump Character Added
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    wait(0.5)
    originalWalkSpeed = char.Humanoid.WalkSpeed
    originalJumpPower = char.Humanoid.JumpPower
    ApplySpeed()
    ApplyJump()
end)

-- Multi Hit Loop
local lastHit = 0
coroutine.wrap(function()
    while true do
        if multiHitEnabled then
            local now = tick()
            if now - lastHit >= (1 / mhHitsPerSec) then
                DoMultiHit()
                lastHit = now
            end
        end
        wait(0.01)
    end
end)()

-- ============================================
-- START
-- ============================================
CreateMainMenu()
CreateSwordButton()

print("==========================================")
print("ZEFF VORTEX - FULL SCRIPT LOADED")
print("MENU: 3 TAB (ESP | MULTI HIT | BOOST)")
print("MENU: Bisa digeser & diperkecil")
print("TOMBOL PEDANG: ON/OFF Multi Hit (bisa digeser)")
print("==========================================")
