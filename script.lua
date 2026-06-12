-- ============================================
-- ZEFF VORTEX - FULL SCRIPT
-- TOMBOL PEDANG BISA DIGESER
-- MENU LANGSUNG MUNCUL
-- ============================================

-- ============================================
-- VARIABEL UTAMA
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variabel UI
local mainGui = nil
local swordBtn = nil
local menuFrame = nil
local isMenuOpen = false

-- Variabel ESP
local masterEnabled = false
local espBoxEnabled = false
local espTracerEnabled = false
local espNameEnabled = false
local espColor = Color3.fromRGB(155, 0, 255)
local espThickness = 2
local espList = {}

-- Variabel Combat
local multiHitEnabled = false
local multiHitRange = 25
local multiHitTargets = 25
local multiDamageEnabled = false
local multiDamageMultiplier = 1

-- Variabel Move
local speedEnabled = false
local speedValue = 16
local jumpEnabled = false
local jumpValue = 50
local originalWalkSpeed = 16
local originalJumpPower = 50

-- Tab aktif
local activeTab = "esp"

-- ============================================
-- FUNGSI CREATE UI
-- ============================================
local function CreateUI()
    if mainGui then mainGui:Destroy() end
    
    local CoreGui = game:GetService("CoreGui")
    mainGui = Instance.new("ScreenGui")
    mainGui.Name = "ZeffVortex"
    mainGui.ResetOnSpawn = false
    
    local success, err = pcall(function()
        mainGui.Parent = (gethui and gethui()) or CoreGui
    end)
    if not success then
        mainGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    print("✅ ZEFF VORTEX - UI Created")
    
    -- ========== TOMBOL PEDANG ==========
    swordBtn = Instance.new("TextButton")
    swordBtn.Size = UDim2.new(0, 50, 0, 50)
    swordBtn.Position = UDim2.new(1, -65, 1, -180)
    swordBtn.Text = "⚔️"
    swordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    swordBtn.TextSize = 26
    swordBtn.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
    swordBtn.BackgroundTransparency = 0.2
    swordBtn.BorderSizePixel = 0
    swordBtn.Parent = mainGui
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 25)
    btnCorner.Parent = swordBtn
    
    -- Indicator LED
    local led = Instance.new("Frame")
    led.Size = UDim2.new(0, 10, 0, 10)
    led.Position = UDim2.new(1, -12, 1, -12)
    led.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    led.BorderSizePixel = 0
    led.Parent = swordBtn
    
    local ledCorner = Instance.new("UICorner")
    ledCorner.CornerRadius = UDim.new(1, 0)
    ledCorner.Parent = led
    
    -- ========== MENU FRAME ==========
    menuFrame = Instance.new("Frame")
    menuFrame.Size = UDim2.new(0, 320, 0, 430)
    menuFrame.Position = UDim2.new(0.5, -160, 0.5, -215)
    menuFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    menuFrame.BackgroundTransparency = 0
    menuFrame.BorderSizePixel = 0
    menuFrame.Visible = false
    menuFrame.Parent = mainGui
    
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 12)
    menuCorner.Parent = menuFrame
    
    local menuBorder = Instance.new("UIStroke")
    menuBorder.Thickness = 1
    menuBorder.Color = Color3.fromRGB(155, 0, 255)
    menuBorder.Transparency = 0.3
    menuBorder.Parent = menuFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 42)
    header.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
    header.BackgroundTransparency = 0.15
    header.BorderSizePixel = 0
    header.Parent = menuFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0.04, 0, 0, 0)
    title.Text = "⚔️ ZEFF VORTEX"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local closeMenu = Instance.new("TextButton")
    closeMenu.Size = UDim2.new(0, 30, 0, 30)
    closeMenu.Position = UDim2.new(1, -38, 0.5, -15)
    closeMenu.Text = "✕"
    closeMenu.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeMenu.BackgroundTransparency = 1
    closeMenu.Font = Enum.Font.GothamBold
    closeMenu.TextSize = 16
    closeMenu.Parent = header
    
    -- ========== TAB BAR ==========
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, -20, 0, 36)
    tabBar.Position = UDim2.new(0, 10, 0, 50)
    tabBar.BackgroundTransparency = 1
    tabBar.Parent = menuFrame
    
    local espTab = Instance.new("TextButton")
    espTab.Size = UDim2.new(0.3, -4, 1, 0)
    espTab.Position = UDim2.new(0, 0, 0, 0)
    espTab.Text = "🎮 ESP"
    espTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    espTab.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
    espTab.Font = Enum.Font.GothamBold
    espTab.TextSize = 12
    espTab.Parent = tabBar
    
    local combatTab = Instance.new("TextButton")
    combatTab.Size = UDim2.new(0.33, -4, 1, 0)
    combatTab.Position = UDim2.new(0.32, 4, 0, 0)
    combatTab.Text = "⚔️ COMBAT"
    combatTab.TextColor3 = Color3.fromRGB(200, 200, 220)
    combatTab.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    combatTab.Font = Enum.Font.GothamBold
    combatTab.TextSize = 12
    combatTab.Parent = tabBar
    
    local moveTab = Instance.new("TextButton")
    moveTab.Size = UDim2.new(0.33, -4, 1, 0)
    moveTab.Position = UDim2.new(0.64, 8, 0, 0)
    moveTab.Text = "🏃 MOVE"
    moveTab.TextColor3 = Color3.fromRGB(200, 200, 220)
    moveTab.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    moveTab.Font = Enum.Font.GothamBold
    moveTab.TextSize = 12
    moveTab.Parent = tabBar
    
    -- ========== CONTENT AREA ==========
    local contentArea = Instance.new("ScrollingFrame")
    contentArea.Size = UDim2.new(1, -20, 1, -140)
    contentArea.Position = UDim2.new(0, 10, 0, 95)
    contentArea.BackgroundTransparency = 1
    contentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentArea.ScrollBarThickness = 3
    contentArea.ScrollBarImageColor3 = Color3.fromRGB(155, 0, 255)
    contentArea.Parent = menuFrame
    
    -- ========== TAB 1: ESP ==========
    local espContent = Instance.new("Frame")
    espContent.Size = UDim2.new(1, 0, 1, 0)
    espContent.BackgroundTransparency = 1
    espContent.Visible = true
    espContent.Parent = contentArea
    
    local y = 5
    
    -- Master ESP
    local masterBtn, masterStatus = CreateToggle(espContent, "🔘 MASTER ESP", y, masterEnabled)
    y = y + 48
    
    local boxBtn, boxStatus = CreateToggle(espContent, "📦 BOX ESP", y, espBoxEnabled)
    y = y + 43
    
    local tracerBtn, tracerStatus = CreateToggle(espContent, "📏 TRACER ESP", y, espTracerEnabled)
    y = y + 43
    
    local nameBtn, nameStatus = CreateToggle(espContent, "🏷️ NAME ESP", y, espNameEnabled)
    y = y + 43
    
    local thickControl = CreateSlider(espContent, "📏 KETEBALAN", y, espThickness, 1, 5)
    y = y + 55
    
    espContent.CanvasSize = UDim2.new(0, 0, 0, y + 10)
    
    -- ========== TAB 2: COMBAT ==========
    local combatContent = Instance.new("Frame")
    combatContent.Size = UDim2.new(1, 0, 1, 0)
    combatContent.BackgroundTransparency = 1
    combatContent.Visible = false
    combatContent.Parent = contentArea
    
    y = 5
    
    local mhBtn, mhStatus = CreateToggle(combatContent, "⚔️ MULTI HIT", y, multiHitEnabled)
    y = y + 48
    
    local rangeControl = CreateSlider(combatContent, "📏 JARAK (M)", y, multiHitRange, 5, 25)
    y = y + 55
    
    local targetControl = CreateSlider(combatContent, "🎯 TARGET", y, multiHitTargets, 1, 25)
    y = y + 55
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0, y)
    line.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    line.Parent = combatContent
    y = y + 15
    
    local mdBtn, mdStatus = CreateToggle(combatContent, "💥 MULTI DAMAGE", y, multiDamageEnabled)
    y = y + 48
    
    local damageControl = CreateSlider(combatContent, "✖️ DAMAGE (x)", y, multiDamageMultiplier, 1, 50)
    y = y + 55
    
    combatContent.CanvasSize = UDim2.new(0, 0, 0, y + 10)
    
    -- ========== TAB 3: MOVE ==========
    local moveContent = Instance.new("Frame")
    moveContent.Size = UDim2.new(1, 0, 1, 0)
    moveContent.BackgroundTransparency = 1
    moveContent.Visible = false
    moveContent.Parent = contentArea
    
    y = 5
    
    local speedBtn, speedStatus = CreateToggle(moveContent, "⚡ SPEED HACK", y, speedEnabled)
    y = y + 48
    
    local speedControl = CreateSlider(moveContent, "🏃 KECEPATAN", y, speedValue, 16, 100)
    y = y + 55
    
    local line2 = Instance.new("Frame")
    line2.Size = UDim2.new(1, 0, 0, 1)
    line2.Position = UDim2.new(0, 0, 0, y)
    line2.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    line2.Parent = moveContent
    y = y + 15
    
    local jumpBtn, jumpStatus = CreateToggle(moveContent, "🦘 JUMP HACK", y, jumpEnabled)
    y = y + 48
    
    local jumpControl = CreateSlider(moveContent, "📈 KETINGGIAN", y, jumpValue, 50, 100)
    y = y + 55
    
    moveContent.CanvasSize = UDim2.new(0, 0, 0, y + 10)
    
    -- ========== FUNGSI CREATE UI ELEMENT ==========
    function CreateToggle(parent, text, yPos, state)
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
    
    function CreateSlider(parent, label, yPos, value, minVal, maxVal)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 45)
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
        minus.Size = UDim2.new(0, 30, 0, 30)
        minus.Position = UDim2.new(1, -70, 0.5, -15)
        minus.Text = "-"
        minus.TextColor3 = Color3.fromRGB(255, 255, 255)
        minus.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        minus.Font = Enum.Font.GothamBold
        minus.TextSize = 16
        minus.Parent = frame
        
        local plus = Instance.new("TextButton")
        plus.Size = UDim2.new(0, 30, 0, 30)
        plus.Position = UDim2.new(1, -35, 0.5, -15)
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
        
        return {frame = frame, valueText = valueText, minus = minus, plus = plus, min = minVal, max = maxVal, value = value}
    end
    
    -- ========== TAB SWITCH ==========
    local function SwitchTab(tab)
        activeTab = tab
        espTab.BackgroundColor3 = tab == "esp" and Color3.fromRGB(155, 0, 255) or Color3.fromRGB(35, 35, 50)
        espTab.TextColor3 = tab == "esp" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 220)
        combatTab.BackgroundColor3 = tab == "combat" and Color3.fromRGB(155, 0, 255) or Color3.fromRGB(35, 35, 50)
        combatTab.TextColor3 = tab == "combat" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 220)
        moveTab.BackgroundColor3 = tab == "move" and Color3.fromRGB(155, 0, 255) or Color3.fromRGB(35, 35, 50)
        moveTab.TextColor3 = tab == "move" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 220)
        
        espContent.Visible = (tab == "esp")
        combatContent.Visible = (tab == "combat")
        moveContent.Visible = (tab == "move")
    end
    
    espTab.MouseButton1Click:Connect(function() SwitchTab("esp") end)
    combatTab.MouseButton1Click:Connect(function() SwitchTab("combat") end)
    moveTab.MouseButton1Click:Connect(function() SwitchTab("move") end)
    
    -- ========== BUTTON ACTIONS ==========
    masterBtn.MouseButton1Click:Connect(function()
        masterEnabled = not masterEnabled
        masterStatus.Text = masterEnabled and "✅ ON" or "❌ OFF"
        masterStatus.TextColor3 = masterEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        masterBtn.BackgroundColor3 = masterEnabled and Color3.fromRGB(155, 0, 255) or Color3.fromRGB(35, 35, 50)
        led.BackgroundColor3 = masterEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
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
    
    mhBtn.MouseButton1Click:Connect(function()
        multiHitEnabled = not multiHitEnabled
        mhStatus.Text = multiHitEnabled and "✅ ON" or "❌ OFF"
        mhStatus.TextColor3 = multiHitEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        mhBtn.BackgroundColor3 = multiHitEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
    end)
    
    mdBtn.MouseButton1Click:Connect(function()
        multiDamageEnabled = not multiDamageEnabled
        mdStatus.Text = multiDamageEnabled and "✅ ON" or "❌ OFF"
        mdStatus.TextColor3 = multiDamageEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        mdBtn.BackgroundColor3 = multiDamageEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
    end)
    
    speedBtn.MouseButton1Click:Connect(function()
        speedEnabled = not speedEnabled
        speedStatus.Text = speedEnabled and "✅ ON" or "❌ OFF"
        speedStatus.TextColor3 = speedEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        speedBtn.BackgroundColor3 = speedEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
        ApplySpeed()
    end)
    
    jumpBtn.MouseButton1Click:Connect(function()
        jumpEnabled = not jumpEnabled
        jumpStatus.Text = jumpEnabled and "✅ ON" or "❌ OFF"
        jumpStatus.TextColor3 = jumpEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        jumpBtn.BackgroundColor3 = jumpEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
        ApplyJump()
    end)
    
    -- Slider Actions
    thickControl.minus.MouseButton1Click:Connect(function()
        espThickness = math.max(1, espThickness - 1)
        thickControl.valueText.Text = tostring(espThickness)
        RefreshESP()
    end)
    thickControl.plus.MouseButton1Click:Connect(function()
        espThickness = math.min(5, espThickness + 1)
        thickControl.valueText.Text = tostring(espThickness)
        RefreshESP()
    end)
    
    rangeControl.minus.MouseButton1Click:Connect(function()
        multiHitRange = math.max(5, multiHitRange - 1)
        rangeControl.valueText.Text = tostring(multiHitRange)
    end)
    rangeControl.plus.MouseButton1Click:Connect(function()
        multiHitRange = math.min(25, multiHitRange + 1)
        rangeControl.valueText.Text = tostring(multiHitRange)
    end)
    
    targetControl.minus.MouseButton1Click:Connect(function()
        multiHitTargets = math.max(1, multiHitTargets - 1)
        targetControl.valueText.Text = tostring(multiHitTargets)
    end)
    targetControl.plus.MouseButton1Click:Connect(function()
        multiHitTargets = math.min(25, multiHitTargets + 1)
        targetControl.valueText.Text = tostring(multiHitTargets)
    end)
    
    damageControl.minus.MouseButton1Click:Connect(function()
        multiDamageMultiplier = math.max(1, multiDamageMultiplier - 1)
        damageControl.valueText.Text = tostring(multiDamageMultiplier)
    end)
    damageControl.plus.MouseButton1Click:Connect(function()
        multiDamageMultiplier = math.min(50, multiDamageMultiplier + 1)
        damageControl.valueText.Text = tostring(multiDamageMultiplier)
    end)
    
    speedControl.minus.MouseButton1Click:Connect(function()
        speedValue = math.max(16, speedValue - 1)
        speedControl.valueText.Text = tostring(speedValue)
        ApplySpeed()
    end)
    speedControl.plus.MouseButton1Click:Connect(function()
        speedValue = math.min(100, speedValue + 1)
        speedControl.valueText.Text = tostring(speedValue)
        ApplySpeed()
    end)
    
    jumpControl.minus.MouseButton1Click:Connect(function()
        jumpValue = math.max(50, jumpValue - 1)
        jumpControl.valueText.Text = tostring(jumpValue)
        ApplyJump()
    end)
    jumpControl.plus.MouseButton1Click:Connect(function()
        jumpValue = math.min(100, jumpValue + 1)
        jumpControl.valueText.Text = tostring(jumpValue)
        ApplyJump()
    end)
    
    -- ========== DRAG TOMBOL PEDANG ==========
    local dragStart = nil
    local startPos = nil
    local isDragging = false
    
    swordBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = swordBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
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
    
    -- ========== DRAG MENU ==========
    local menuDragStart = nil
    local menuStartPos = nil
    local isMenuDragging = false
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isMenuDragging = true
            menuDragStart = input.Position
            menuStartPos = menuFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isMenuDragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if not isMenuDragging then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - menuDragStart
            menuFrame.Position = UDim2.new(
                menuStartPos.X.Scale, menuStartPos.X.Offset + delta.X,
                menuStartPos.Y.Scale, menuStartPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- ========== TOGGLE MENU ==========
    local pressTime = 0
    local isHolding = false
    
    swordBtn.MouseButton1Down:Connect(function()
        pressTime = tick()
        isHolding = true
    end)
    
    swordBtn.MouseButton1Up:Connect(function()
        local duration = tick() - pressTime
        if duration < 0.3 then
            -- Tap pendek: toggle menu
            isMenuOpen = not isMenuOpen
            menuFrame.Visible = isMenuOpen
        else
            -- Tap panjang: toggle master ESP
            masterEnabled = not masterEnabled
            masterStatus.Text = masterEnabled and "✅ ON" or "❌ OFF"
            masterStatus.TextColor3 = masterEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
            masterBtn.BackgroundColor3 = masterEnabled and Color3.fromRGB(155, 0, 255) or Color3.fromRGB(35, 35, 50)
            led.BackgroundColor3 = masterEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        end
        isHolding = false
    end)
    
    closeMenu.MouseButton1Click:Connect(function()
        isMenuOpen = false
        menuFrame.Visible = false
    end)
    
    return true
end

-- ============================================
-- ESP FUNCTIONS
-- ============================================
local function CreateESP(player)
    if player == LocalPlayer then return end
    if espList[player] then return end
    
    local esp = {}
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = espColor
    box.Thickness = espThickness
    box.Filled = false
    box.Transparency = 0.5
    esp.box = box
    
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = espColor
    tracer.Thickness = espThickness
    tracer.Transparency = 0.5
    esp.tracer = tracer
    
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

local function RemoveESP(player)
    local esp = espList[player]
    if esp then
        if esp.box then esp.box:Remove() end
        if esp.tracer then esp.tracer:Remove() end
        if esp.nameTag then esp.nameTag:Remove() end
        espList[player] = nil
    end
end

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
            local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            
            if onScreen then
                if espBoxEnabled and esp.box then
                    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
                    local boxSize = math.clamp(200 / distance, 30, 120)
                    local boxX = vector.X - boxSize / 2
                    local boxY = vector.Y - boxSize / 1.2
                    esp.box.Size = Vector2.new(boxSize, boxSize)
                    esp.box.Position = Vector2.new(boxX, boxY)
                    esp.box.Visible = true
                    esp.box.Color = espColor
                    esp.box.Thickness = espThickness
                elseif esp.box then
                    esp.box.Visible = false
                end
                
                if espTracerEnabled and esp.tracer then
                    esp.tracer.From = center
                    esp.tracer.To = Vector2.new(vector.X, vector.Y)
                    esp.tracer.Visible = true
                    esp.tracer.Color = espColor
                    esp.tracer.Thickness = espThickness
                elseif esp.tracer then
                    esp.tracer.Visible = false
                end
                
                if espNameEnabled and esp.nameTag then
                    esp.nameTag.Text = esp.player.Name
                    esp.nameTag.Position = Vector2.new(vector.X, vector.Y - 25)
                    esp.nameTag.Visible = true
                    esp.nameTag.Color = espColor
                elseif esp.nameTag then
                    esp.nameTag.Visible = false
                end
            else
                if esp.box then esp.box.Visible = false end
                if esp.tracer then esp.tracer.Visible = false end
                if esp.nameTag then esp.nameTag.Visible = false end
            end
        end
    end
end

local function RefreshESP()
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
            char.Humanoid.WalkSpeed = speedValue
        else
            char.Humanoid.WalkSpeed = originalWalkSpeed
        end
    end
end

local function ApplyJump()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        if jumpEnabled then
            char.Humanoid.JumpPower = jumpValue
        else
            char.Humanoid.JumpPower = originalJumpPower
        end
    end
end

-- ============================================
-- INITIALIZE
-- ============================================

-- ESP Init
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

-- Speed & Jump Init
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    wait(0.5)
    originalWalkSpeed = char.Humanoid.WalkSpeed
    originalJumpPower = char.Humanoid.JumpPower
    ApplySpeed()
    ApplyJump()
end)

-- Create UI
CreateUI()

print("==========================================")
print("ZEFF VORTEX - SCRIPT LOADED SUCCESSFULLY")
print("Tombol pedang ada di kanan bawah")
print("Tap = Buka menu | Hold = ON/OFF ESP")
print("==========================================")
