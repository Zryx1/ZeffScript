-- ============================================
-- ZEFF VORTEX - FINAL SCRIPT
-- TOMBOL PEDANG = ON/OFF MULTI HIT SAJA
-- MENU = TOMBOL TERPISAH UNTUK BUKA MENU
-- FITUR: ESP + MULTI HIT (HITS PER SECOND) + BOOST
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ============================================
-- VARIABEL ESP
-- ============================================
local masterEnabled = false
local espBoxEnabled = false
local espTracerEnabled = false
local espNameEnabled = false
local espColor = Color3.fromRGB(155, 0, 255)
local espThickness = 2
local espList = {}

-- ============================================
-- VARIABEL MULTI HIT
-- ============================================
local multiHitEnabled = false
local multiHitRange = 20
local multiHitDamage = 10
local multiHitTargets = 10
local multiHitHitsPerSec = 5  -- 1-10x per detik
local targetMode = "players"

-- ============================================
-- VARIABEL SPEED & JUMP
-- ============================================
local speedEnabled = false
local speedMultiplier = 1
local jumpEnabled = false
local jumpMultiplier = 1
local originalWalkSpeed = 16
local originalJumpPower = 50

-- ============================================
-- CREATE GUI
-- ============================================
local mainGui = nil
local swordBtn = nil
local menuBtn = nil
local menuFrame = nil
local isMenuOpen = false
local activeTab = "esp"

local function CreateUI()
    if mainGui then mainGui:Destroy() end
    
    local CoreGui = game:GetService("CoreGui")
    mainGui = Instance.new("ScreenGui")
    mainGui.Name = "ZeffVortex"
    mainGui.ResetOnSpawn = false
    
    pcall(function()
        mainGui.Parent = (gethui and gethui()) or CoreGui
    end)
    if not mainGui.Parent then
        mainGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- ========== TOMBOL PEDANG (ON/OFF MULTI HIT) ==========
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
    
    -- LED indicator (hijau = ON, merah = OFF)
    local led = Instance.new("Frame")
    led.Size = UDim2.new(0, 10, 0, 10)
    led.Position = UDim2.new(1, -12, 1, -12)
    led.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    led.BorderSizePixel = 0
    led.Parent = swordBtn
    
    local ledCorner = Instance.new("UICorner")
    ledCorner.CornerRadius = UDim.new(1, 0)
    ledCorner.Parent = led
    
    -- ========== TOMBOL MENU (BUKA MENU) ==========
    menuBtn = Instance.new("TextButton")
    menuBtn.Size = UDim2.new(0, 40, 0, 40)
    menuBtn.Position = UDim2.new(1, -115, 1, -180)
    menuBtn.Text = "📋"
    menuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    menuBtn.TextSize = 20
    menuBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    menuBtn.BackgroundTransparency = 0.2
    menuBtn.BorderSizePixel = 0
    menuBtn.Parent = mainGui
    
    local menuBtnCorner = Instance.new("UICorner")
    menuBtnCorner.CornerRadius = UDim.new(0, 20)
    menuBtnCorner.Parent = menuBtn
    
    -- ========== MENU FRAME ==========
    menuFrame = Instance.new("Frame")
    menuFrame.Size = UDim2.new(0, 320, 0, 450)
    menuFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
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
    
    -- Header (drag)
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
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -38, 0.5, -15)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = header
    
    -- ========== TAB BAR ==========
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, -20, 0, 38)
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
    combatTab.Text = "⚔️ MULTI HIT"
    combatTab.TextColor3 = Color3.fromRGB(200, 200, 220)
    combatTab.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    combatTab.Font = Enum.Font.GothamBold
    combatTab.TextSize = 12
    combatTab.Parent = tabBar
    
    local moveTab = Instance.new("TextButton")
    moveTab.Size = UDim2.new(0.33, -4, 1, 0)
    moveTab.Position = UDim2.new(0.64, 8, 0, 0)
    moveTab.Text = "🏃 BOOST"
    moveTab.TextColor3 = Color3.fromRGB(200, 200, 220)
    moveTab.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    moveTab.Font = Enum.Font.GothamBold
    moveTab.TextSize = 12
    moveTab.Parent = tabBar
    
    -- ========== CONTENT AREA ==========
    local contentArea = Instance.new("ScrollingFrame")
    contentArea.Size = UDim2.new(1, -20, 1, -140)
    contentArea.Position = UDim2.new(0, 10, 0, 98)
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
    
    local masterBtn, masterStatus = CreateToggle(espContent, "🔘 ENABLE ESP", y, masterEnabled)
    y = y + 48
    
    local boxBtn, boxStatus = CreateToggle(espContent, "📦 BOX ESP", y, espBoxEnabled)
    y = y + 43
    
    local tracerBtn, tracerStatus = CreateToggle(espContent, "📏 LINE ESP", y, espTracerEnabled)
    y = y + 43
    
    local nameBtn, nameStatus = CreateToggle(espContent, "🏷️ NAME ESP", y, espNameEnabled)
    y = y + 43
    
    local thickControl = CreateSlider(espContent, "📏 KETEBALAN", y, espThickness, 1, 5, "int")
    y = y + 55
    
    espContent.CanvasSize = UDim2.new(0, 0, 0, y + 10)
    
    -- ========== TAB 2: MULTI HIT ==========
    local combatContent = Instance.new("Frame")
    combatContent.Size = UDim2.new(1, 0, 1, 0)
    combatContent.BackgroundTransparency = 1
    combatContent.Visible = false
    combatContent.Parent = contentArea
    
    y = 5
    
    local mhStatusLabel = CreateInfoBox(combatContent, "⚔️ MULTI HIT STATUS", y, multiHitEnabled)
    y = y + 55
    
    local radiusControl = CreateSlider(combatContent, "📏 RADIUS (M)", y, multiHitRange, 5, 20, "int")
    y = y + 55
    
    local damageControl = CreateSlider(combatContent, "💥 DAMAGE", y, multiHitDamage, 1, 25, "int")
    y = y + 55
    
    local targetControl = CreateSlider(combatContent, "🎯 JUMLAH TARGET", y, multiHitTargets, 1, 20, "int")
    y = y + 55
    
    local hitsControl = CreateSlider(combatContent, "⚡ SERANGAN/DETIK", y, multiHitHitsPerSec, 1, 10, "int")
    y = y + 55
    
    -- Target Mode
    local modeFrame = Instance.new("Frame")
    modeFrame.Size = UDim2.new(1, 0, 0, 40)
    modeFrame.Position = UDim2.new(0, 0, 0, y)
    modeFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    modeFrame.BackgroundTransparency = 0
    modeFrame.BorderSizePixel = 0
    modeFrame.Parent = combatContent
    
    local modeCorner = Instance.new("UICorner")
    modeCorner.CornerRadius = UDim.new(0, 8)
    modeCorner.Parent = modeFrame
    
    local modeLabel = Instance.new("TextLabel")
    modeLabel.Size = UDim2.new(0.5, 0, 1, 0)
    modeLabel.Position = UDim2.new(0, 10, 0, 0)
    modeLabel.Text = "🎯 TARGET MODE"
    modeLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    modeLabel.BackgroundTransparency = 1
    modeLabel.Font = Enum.Font.GothamBold
    modeLabel.TextSize = 11
    modeLabel.TextXAlignment = Enum.TextXAlignment.Left
    modeLabel.Parent = modeFrame
    
    local modeValue = Instance.new("TextButton")
    modeValue.Size = UDim2.new(0.45, 0, 0.7, 0)
    modeValue.Position = UDim2.new(0.52, 0, 0.15, 0)
    modeValue.Text = targetMode == "players" and "👤 PLAYERS" or "👾 ALL ENTITY"
    modeValue.TextColor3 = Color3.fromRGB(155, 0, 255)
    modeValue.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    modeValue.Font = Enum.Font.GothamBold
    modeValue.TextSize = 10
    modeValue.Parent = modeFrame
    
    local modeValueCorner = Instance.new("UICorner")
    modeValueCorner.CornerRadius = UDim.new(0, 6)
    modeValueCorner.Parent = modeValue
    
    y = y + 55
    
    combatContent.CanvasSize = UDim2.new(0, 0, 0, y + 10)
    
    -- ========== TAB 3: SPEED & JUMP BOOST ==========
    local moveContent = Instance.new("Frame")
    moveContent.Size = UDim2.new(1, 0, 1, 0)
    moveContent.BackgroundTransparency = 1
    moveContent.Visible = false
    moveContent.Parent = contentArea
    
    y = 5
    
    local speedBtn, speedStatus = CreateToggle(moveContent, "⚡ SPEED BOOST", y, speedEnabled)
    y = y + 48
    
    local speedControl = CreateSlider(moveContent, "🏃 SPEED (x)", y, speedMultiplier, 1, 100, "multiplier")
    y = y + 55
    
    local line1 = Instance.new("Frame")
    line1.Size = UDim2.new(1, 0, 0, 1)
    line1.Position = UDim2.new(0, 0, 0, y)
    line1.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    line1.Parent = moveContent
    y = y + 15
    
    local jumpBtn, jumpStatus = CreateToggle(moveContent, "🦘 JUMP BOOST", y, jumpEnabled)
    y = y + 48
    
    local jumpControl = CreateSlider(moveContent, "📈 JUMP (x)", y, jumpMultiplier, 1, 100, "multiplier")
    y = y + 55
    
    moveContent.CanvasSize = UDim2.new(0, 0, 0, y + 10)
    
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
    
    function CreateSlider(parent, label, yPos, value, minVal, maxVal, type)
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
        
        local displayText = (type == "multiplier") and (value .. "x") or tostring(value)
        local valueText = Instance.new("TextLabel")
        valueText.Size = UDim2.new(0.2, 0, 1, 0)
        valueText.Position = UDim2.new(0.5, 0, 0, 0)
        valueText.Text = displayText
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
        
        return {frame = frame, valueText = valueText, minus = minus, plus = plus, min = minVal, max = maxVal, type = type}
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
        RefreshESP()
    end)
    thickControl.plus.MouseButton1Click:Connect(function()
        espThickness = math.min(5, espThickness + 1)
        thickControl.valueText.Text = tostring(espThickness)
        RefreshESP()
    end)
    
    -- Multi Hit Sliders
    radiusControl.minus.MouseButton1Click:Connect(function()
        multiHitRange = math.max(5, multiHitRange - 1)
        radiusControl.valueText.Text = tostring(multiHitRange)
    end)
    radiusControl.plus.MouseButton1Click:Connect(function()
        multiHitRange = math.min(20, multiHitRange + 1)
        radiusControl.valueText.Text = tostring(multiHitRange)
    end)
    
    damageControl.minus.MouseButton1Click:Connect(function()
        multiHitDamage = math.max(1, multiHitDamage - 1)
        damageControl.valueText.Text = tostring(multiHitDamage)
    end)
    damageControl.plus.MouseButton1Click:Connect(function()
        multiHitDamage = math.min(25, multiHitDamage + 1)
        damageControl.valueText.Text = tostring(multiHitDamage)
    end)
    
    targetControl.minus.MouseButton1Click:Connect(function()
        multiHitTargets = math.max(1, multiHitTargets - 1)
        targetControl.valueText.Text = tostring(multiHitTargets)
    end)
    targetControl.plus.MouseButton1Click:Connect(function()
        multiHitTargets = math.min(20, multiHitTargets + 1)
        targetControl.valueText.Text = tostring(multiHitTargets)
    end)
    
    hitsControl.minus.MouseButton1Click:Connect(function()
        multiHitHitsPerSec = math.max(1, multiHitHitsPerSec - 1)
        hitsControl.valueText.Text = tostring(multiHitHitsPerSec)
    end)
    hitsControl.plus.MouseButton1Click:Connect(function()
        multiHitHitsPerSec = math.min(10, multiHitHitsPerSec + 1)
        hitsControl.valueText.Text = tostring(multiHitHitsPerSec)
    end)
    
    modeValue.MouseButton1Click:Connect(function()
        if targetMode == "players" then
            targetMode = "all"
            modeValue.Text = "👾 ALL ENTITY"
        else
            targetMode = "players"
            modeValue.Text = "👤 PLAYERS"
        end
    end)
    
    -- Speed & Jump Actions
    speedBtn.MouseButton1Click:Connect(function()
        speedEnabled = not speedEnabled
        speedStatus.Text = speedEnabled and "✅ ON" or "❌ OFF"
        speedStatus.TextColor3 = speedEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        speedBtn.BackgroundColor3 = speedEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
        ApplySpeed()
    end)
    
    speedControl.minus.MouseButton1Click:Connect(function()
        speedMultiplier = math.max(1, speedMultiplier - 1)
        speedControl.valueText.Text = speedMultiplier .. "x"
        ApplySpeed()
    end)
    speedControl.plus.MouseButton1Click:Connect(function()
        speedMultiplier = math.min(100, speedMultiplier + 1)
        speedControl.valueText.Text = speedMultiplier .. "x"
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
        jumpMultiplier = math.max(1, jumpMultiplier - 1)
        jumpControl.valueText.Text = jumpMultiplier .. "x"
        ApplyJump()
    end)
    jumpControl.plus.MouseButton1Click:Connect(function()
        jumpMultiplier = math.min(100, jumpMultiplier + 1)
        jumpControl.valueText.Text = jumpMultiplier .. "x"
        ApplyJump()
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
    
    -- ========== DRAG TOMBOL MENU ==========
    local menuBtnDragStart = nil
    local menuBtnStartPos = nil
    local isMenuBtnDragging = false
    
    menuBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isMenuBtnDragging = true
            menuBtnDragStart = input.Position
            menuBtnStartPos = menuBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isMenuBtnDragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if not isMenuBtnDragging then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - menuBtnDragStart
            local newX = math.clamp(menuBtnStartPos.X.Offset + delta.X, 0, UDim2.new(1, -55, 0, 0).X.Offset)
            local newY = math.clamp(menuBtnStartPos.Y.Offset + delta.Y, 0, UDim2.new(0, 0, 1, -55).Y.Offset)
            menuBtn.Position = UDim2.new(menuBtnStartPos.X.Scale, newX, menuBtnStartPos.Y.Scale, newY)
        end
    end)
    
    -- ========== TOMBOL MENU BUKA MENU ==========
    menuBtn.MouseButton1Click:Connect(function()
        isMenuOpen = not isMenuOpen
        menuFrame.Visible = isMenuOpen
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        isMenuOpen = false
        menuFrame.Visible = false
    end)
    
    -- ========== TOMBOL PEDANG ON/OFF MULTI HIT ==========
    swordBtn.MouseButton1Click:Connect(function()
        multiHitEnabled = not multiHitEnabled
        led.BackgroundColor3 = multiHitEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        
        if mhStatusLabel and mhStatusLabel.status then
            mhStatusLabel.status.Text = multiHitEnabled and "✅ ACTIVE" or "❌ INACTIVE"
            mhStatusLabel.status.TextColor3 = multiHitEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
            mhStatusLabel.frame.BackgroundColor3 = multiHitEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
        end
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
            char.Humanoid.WalkSpeed = originalWalkSpeed * speedMultiplier
        else
            char.Humanoid.WalkSpeed = originalWalkSpeed
        end
    end
end

local function ApplyJump()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        if jumpEnabled then
            char.Humanoid.JumpPower = originalJumpPower * jumpMultiplier
        else
            char.Humanoid.JumpPower = originalJumpPower
        end
    end
end

-- ============================================
-- MULTI HIT FUNCTION (Dengan Hits Per Second)
-- ============================================
local function GetTargets()
    local targets = {}
    local char = LocalPlayer.Character
    if not char then return targets end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return targets end
    
    if targetMode == "players" then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local targetChar = player.Character
                if targetChar then
                    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        local dist = (rootPart.Position - targetRoot.Position).Magnitude
                        if dist <= multiHitRange then
                            local humanoid = targetChar:FindFirstChild("Humanoid")
                            if humanoid and humanoid.Health > 0 then
                                table.insert(targets, {
                                    target = targetChar,
                                    humanoid = humanoid,
                                    distance = dist
                                })
                            end
                        end
                    end
                end
            end
        end
    else
        local function ScanDescendants(instance)
            for _, child in ipairs(instance:GetChildren()) do
                if child:IsA("Model") and child ~= char then
                    local humanoid = child:FindFirstChild("Humanoid")
                    local targetRoot = child:FindFirstChild("HumanoidRootPart") or child:FindFirstChild("Head")
                    if humanoid and targetRoot and humanoid.Health > 0 then
                        local dist = (rootPart.Position - targetRoot.Position).Magnitude
                        if dist <= multiHitRange then
                            table.insert(targets, {
                                target = child,
                                humanoid = humanoid,
                                distance = dist
                            })
                        end
                    end
                end
                ScanDescendants(child)
            end
        end
        ScanDescendants(workspace)
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local targetChar = player.Character
                if targetChar then
                    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        local dist = (rootPart.Position - targetRoot.Position).Magnitude
                        if dist <= multiHitRange then
                            local humanoid = targetChar:FindFirstChild("Humanoid")
                            if humanoid and humanoid.Health > 0 then
                                table.insert(targets, {
                                    target = targetChar,
                                    humanoid = humanoid,
                                    distance = dist
                                })
                            end
                        end
                    end
                end
            end
        end
    end
    
    table.sort(targets, function(a, b) return a.distance < b.distance end)
    
    if #targets > multiHitTargets then
        local limited = {}
        for i = 1, multiHitTargets do
            limited[i] = targets[i]
        end
        return limited
    end
    
    return targets
end

local function DoMultiHit()
    if not multiHitEnabled then return end
    
    local targets = GetTargets()
    if #targets == 0 then return end
    
    for _, target in ipairs(targets) do
        if target.humanoid then
            target.humanoid.Health = target.humanoid.Health - multiHitDamage
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

-- Multi Hit Loop dengan Hits Per Second
local lastHitTime = 0
local function MultiHitLoop()
    while true do
        if multiHitEnabled then
            local now = tick()
            local interval = 1 / multiHitHitsPerSec
            if now - lastHitTime >= interval then
                DoMultiHit()
                lastHitTime = now
            end
        end
        wait(0.01)
    end
end

coroutine.wrap(MultiHitLoop)()

-- Create UI
CreateUI()

print("==========================================")
print("ZEFF VORTEX - FULL SCRIPT LOADED")
print("Tombol pedang = ON/OFF MULTI HIT")
print("Tombol 📋 = BUKA MENU")
print("3 TAB: ESP | MULTI HIT | BOOST")
print("==========================================")
