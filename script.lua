-- ============================================
-- ZEFF VORTEX - FULL SCRIPT
-- FITUR: ESP + MULTI HIT + MULTI DAMAGE + SPEED + JUMP
-- ============================================

-- ============================================
-- VARIABEL UTAMA
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Tab aktif
local activeTab = "esp"

-- ============================================
-- ESP VARIABEL (DARI SEBELUMNYA)
-- ============================================
local masterEnabled = false
local espBoxEnabled = false
local espTracerEnabled = false
local espNameEnabled = false
local espColor = Color3.fromRGB(155, 0, 255)
local espThickness = 2
local espList = {}

-- ============================================
-- MULTI HIT VARIABEL
-- ============================================
local multiHitEnabled = false
local multiHitRange = 25  -- meter, max 25
local multiHitTargets = 25  -- max 25 target

-- ============================================
-- MULTI DAMAGE VARIABEL
-- ============================================
local multiDamageEnabled = false
local multiDamageMultiplier = 1  -- max 50x

-- ============================================
-- SPEED & JUMP VARIABEL
-- ============================================
local speedEnabled = false
local speedValue = 16  -- default 16, max 100
local jumpEnabled = false
local jumpValue = 50  -- default 50, max 100

local originalWalkSpeed = 16
local originalJumpPower = 50

-- ============================================
-- UI PEDANG MELAYANG
-- ============================================
local swordGui = nil
local swordOpen = true

local function CreateSwordUI()
    if swordGui then swordGui:Destroy() end
    
    local CoreGui = game:GetService("CoreGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ZeffSwordUI"
    screenGui.Parent = (gethui and gethui()) or CoreGui
    
    -- Frame berbentuk pedang (posisi kanan bawah)
    local swordFrame = Instance.new("Frame")
    swordFrame.Size = UDim2.new(0, 60, 0, 60)
    swordFrame.Position = UDim2.new(1, -75, 1, -160)
    swordFrame.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
    swordFrame.BackgroundTransparency = 0.15
    swordFrame.BorderSizePixel = 0
    swordFrame.Parent = screenGui
    
    local swordCorner = Instance.new("UICorner")
    swordCorner.CornerRadius = UDim.new(0, 30)
    swordCorner.Parent = swordFrame
    
    -- Icon pedang
    local swordIcon = Instance.new("TextLabel")
    swordIcon.Size = UDim2.new(1, 0, 1, 0)
    swordIcon.Text = "⚔️"
    swordIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    swordIcon.BackgroundTransparency = 1
    swordIcon.Font = Enum.Font.GothamBold
    swordIcon.TextSize = 35
    swordIcon.Parent = swordFrame
    
    -- Menu yang muncul saat pedang diklik
    local menuFrame = Instance.new("Frame")
    menuFrame.Size = UDim2.new(0, 320, 0, 450)
    menuFrame.Position = UDim2.new(1, -340, 0.5, -225)
    menuFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    menuFrame.BackgroundTransparency = 0
    menuFrame.BorderSizePixel = 0
    menuFrame.Visible = false
    menuFrame.Parent = screenGui
    
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 12)
    menuCorner.Parent = menuFrame
    
    local menuBorder = Instance.new("UIStroke")
    menuBorder.Thickness = 1
    menuBorder.Color = Color3.fromRGB(155, 0, 255)
    menuBorder.Transparency = 0.3
    menuBorder.Parent = menuFrame
    
    -- Header menu
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
    header.BackgroundTransparency = 0.15
    header.BorderSizePixel = 0
    header.Parent = menuFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.7, 0, 1, 0)
    title.Position = UDim2.new(0.03, 0, 0, 0)
    title.Text = "⚔️ ZEFF VORTEX"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local closeMenuBtn = Instance.new("TextButton")
    closeMenuBtn.Size = UDim2.new(0, 28, 0, 28)
    closeMenuBtn.Position = UDim2.new(1, -36, 0.5, -14)
    closeMenuBtn.Text = "✕"
    closeMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeMenuBtn.BackgroundTransparency = 1
    closeMenuBtn.Font = Enum.Font.GothamBold
    closeMenuBtn.TextSize = 14
    closeMenuBtn.Parent = header
    
    -- TAB BUTTONS (3 kategori)
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, -20, 0, 35)
    tabBar.Position = UDim2.new(0, 10, 0, 48)
    tabBar.BackgroundTransparency = 1
    tabBar.Parent = menuFrame
    
    local espTab = Instance.new("TextButton")
    espTab.Size = UDim2.new(0.3, -5, 1, 0)
    espTab.Position = UDim2.new(0, 0, 0, 0)
    espTab.Text = "🎮 ESP"
    espTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    espTab.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
    espTab.Font = Enum.Font.GothamBold
    espTab.TextSize = 12
    espTab.Parent = tabBar
    
    local combatTab = Instance.new("TextButton")
    combatTab.Size = UDim2.new(0.3, -5, 1, 0)
    combatTab.Position = UDim2.new(0.33, 5, 0, 0)
    combatTab.Text = "⚔️ COMBAT"
    combatTab.TextColor3 = Color3.fromRGB(200, 200, 220)
    combatTab.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    combatTab.Font = Enum.Font.GothamBold
    combatTab.TextSize = 12
    combatTab.Parent = tabBar
    
    local moveTab = Instance.new("TextButton")
    moveTab.Size = UDim2.new(0.3, -5, 1, 0)
    moveTab.Position = UDim2.new(0.66, 10, 0, 0)
    moveTab.Text = "🏃 MOVE"
    moveTab.TextColor3 = Color3.fromRGB(200, 200, 220)
    moveTab.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    moveTab.Font = Enum.Font.GothamBold
    moveTab.TextSize = 12
    moveTab.Parent = tabBar
    
    -- CONTENT AREA
    local contentArea = Instance.new("ScrollingFrame")
    contentArea.Size = UDim2.new(1, -20, 1, -140)
    contentArea.Position = UDim2.new(0, 10, 0, 95)
    contentArea.BackgroundTransparency = 1
    contentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentArea.ScrollBarThickness = 3
    contentArea.ScrollBarImageColor3 = Color3.fromRGB(155, 0, 255)
    contentArea.Parent = menuFrame
    
    -- ============================================
    -- TAB 1: ESP (dari script sebelumnya)
    -- ============================================
    local espContent = Instance.new("Frame")
    espContent.Size = UDim2.new(1, 0, 1, 0)
    espContent.BackgroundTransparency = 1
    espContent.Visible = true
    espContent.Parent = contentArea
    
    local yEsp = 0
    
    -- Master ESP
    local masterBtn = CreateButton(espContent, "🔘 MASTER ESP", yEsp, masterEnabled)
    local masterStatus = CreateStatus(espContent, yEsp, masterEnabled)
    yEsp = yEsp + 48
    
    -- Box ESP
    local boxBtn = CreateButton(espContent, "📦 BOX ESP", yEsp, espBoxEnabled)
    local boxStatus = CreateStatus(espContent, yEsp, espBoxEnabled)
    yEsp = yEsp + 43
    
    -- Tracer ESP
    local tracerBtn = CreateButton(espContent, "📏 TRACER ESP", yEsp, espTracerEnabled)
    local tracerStatus = CreateStatus(espContent, yEsp, espTracerEnabled)
    yEsp = yEsp + 43
    
    -- Name ESP
    local nameBtn = CreateButton(espContent, "🏷️ NAME ESP", yEsp, espNameEnabled)
    local nameStatus = CreateStatus(espContent, yEsp, espNameEnabled)
    yEsp = yEsp + 43
    
    -- Ketebalan
    local thickFrame = CreateThicknessControl(espContent, yEsp, espThickness)
    yEsp = yEsp + 55
    
    espContent.CanvasSize = UDim2.new(0, 0, 0, yEsp + 10)
    
    -- ============================================
    -- TAB 2: COMBAT (Multi Hit + Multi Damage)
    -- ============================================
    local combatContent = Instance.new("Frame")
    combatContent.Size = UDim2.new(1, 0, 1, 0)
    combatContent.BackgroundTransparency = 1
    combatContent.Visible = false
    combatContent.Parent = contentArea
    
    local yCombat = 0
    
    -- Multi Hit Toggle
    local mhBtn = CreateButton(combatContent, "⚔️ MULTI HIT", yCombat, multiHitEnabled)
    local mhStatus = CreateStatus(combatContent, yCombat, multiHitEnabled)
    yCombat = yCombat + 48
    
    -- Range slider
    local rangeFrame = CreateSliderControl(combatContent, "📏 JARAK (M)", yCombat, multiHitRange, 5, 25)
    yCombat = yCombat + 55
    
    -- Targets slider
    local targetFrame = CreateSliderControl(combatContent, "🎯 TARGET", yCombat, multiHitTargets, 1, 25)
    yCombat = yCombat + 55
    
    -- Separator
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0, yCombat)
    line.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    line.Parent = combatContent
    yCombat = yCombat + 15
    
    -- Multi Damage Toggle
    local mdBtn = CreateButton(combatContent, "💥 MULTI DAMAGE", yCombat, multiDamageEnabled)
    local mdStatus = CreateStatus(combatContent, yCombat, multiDamageEnabled)
    yCombat = yCombat + 48
    
    -- Damage multiplier slider
    local damageFrame = CreateSliderControl(combatContent, "✖️ DAMAGE (x)", yCombat, multiDamageMultiplier, 1, 50)
    yCombat = yCombat + 55
    
    combatContent.CanvasSize = UDim2.new(0, 0, 0, yCombat + 10)
    
    -- ============================================
    -- TAB 3: MOVE (Speed + Jump)
    -- ============================================
    local moveContent = Instance.new("Frame")
    moveContent.Size = UDim2.new(1, 0, 1, 0)
    moveContent.BackgroundTransparency = 1
    moveContent.Visible = false
    moveContent.Parent = contentArea
    
    local yMove = 0
    
    -- Speed Toggle
    local speedBtn = CreateButton(moveContent, "⚡ SPEED HACK", yMove, speedEnabled)
    local speedStatus = CreateStatus(moveContent, yMove, speedEnabled)
    yMove = yMove + 48
    
    -- Speed slider
    local speedSlider = CreateSliderControl(moveContent, "🏃 KECEPATAN", yMove, speedValue, 16, 100)
    yMove = yMove + 55
    
    -- Separator
    local line2 = Instance.new("Frame")
    line2.Size = UDim2.new(1, 0, 0, 1)
    line2.Position = UDim2.new(0, 0, 0, yMove)
    line2.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    line2.Parent = moveContent
    yMove = yMove + 15
    
    -- Jump Toggle
    local jumpBtn = CreateButton(moveContent, "🦘 JUMP HACK", yMove, jumpEnabled)
    local jumpStatus = CreateStatus(moveContent, yMove, jumpEnabled)
    yMove = yMove + 48
    
    -- Jump slider
    local jumpSlider = CreateSliderControl(moveContent, "📈 KETINGGIAN", yMove, jumpValue, 50, 100)
    yMove = yMove + 55
    
    moveContent.CanvasSize = UDim2.new(0, 0, 0, yMove + 10)
    
    -- ============================================
    -- FUNGSI CREATE UI
    -- ============================================
    
    function CreateButton(parent, text, yPos, state)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 38)
        btn.Position = UDim2.new(0, 0, 0, yPos)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundColor3 = state and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = parent
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        -- Padding kiri
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 12)
        padding.Parent = btn
        
        return btn
    end
    
    function CreateStatus(parent, yPos, state)
        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(0.35, 0, 0, 38)
        status.Position = UDim2.new(0.65, 0, 0, yPos)
        status.Text = state and "✅ ON" or "❌ OFF"
        status.TextColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        status.BackgroundTransparency = 1
        status.Font = Enum.Font.GothamBold
        status.TextSize = 12
        status.TextXAlignment = Enum.TextXAlignment.Right
        status.Parent = parent
        return status
    end
    
    function CreateSliderControl(parent, label, yPos, value, minVal, maxVal)
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
        labelText.Size = UDim2.new(0.5, 0, 1, 0)
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
        
        return {frame = frame, valueText = valueText, minus = minus, plus = plus, min = minVal, max = maxVal, var = nil}
    end
    
    function CreateThicknessControl(parent, yPos, value)
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
        labelText.Size = UDim2.new(0.5, 0, 1, 0)
        labelText.Position = UDim2.new(0, 10, 0, 0)
        labelText.Text = "📏 KETEBALAN"
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
        
        return {frame = frame, valueText = valueText, minus = minus, plus = plus}
    end
    
    -- SWITCH TAB FUNCTION
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
    
    -- BUTTON ACTIONS
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
    
    -- Multi Hit
    mhBtn.MouseButton1Click:Connect(function()
        multiHitEnabled = not multiHitEnabled
        mhStatus.Text = multiHitEnabled and "✅ ON" or "❌ OFF"
        mhStatus.TextColor3 = multiHitEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        mhBtn.BackgroundColor3 = multiHitEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
    end)
    
    -- Multi Damage
    mdBtn.MouseButton1Click:Connect(function()
        multiDamageEnabled = not multiDamageEnabled
        mdStatus.Text = multiDamageEnabled and "✅ ON" or "❌ OFF"
        mdStatus.TextColor3 = multiDamageEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        mdBtn.BackgroundColor3 = multiDamageEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
    end)
    
    -- Speed
    speedBtn.MouseButton1Click:Connect(function()
        speedEnabled = not speedEnabled
        speedStatus.Text = speedEnabled and "✅ ON" or "❌ OFF"
        speedStatus.TextColor3 = speedEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        speedBtn.BackgroundColor3 = speedEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
        ApplySpeed()
    end)
    
    -- Jump
    jumpBtn.MouseButton1Click:Connect(function()
        jumpEnabled = not jumpEnabled
        jumpStatus.Text = jumpEnabled and "✅ ON" or "❌ OFF"
        jumpStatus.TextColor3 = jumpEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        jumpBtn.BackgroundColor3 = jumpEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
        ApplyJump()
    end)
    
    -- SLIDER ACTIONS
    -- Range slider
    rangeFrame.minus.MouseButton1Click:Connect(function()
        multiHitRange = math.max(5, multiHitRange - 1)
        rangeFrame.valueText.Text = tostring(multiHitRange)
    end)
    rangeFrame.plus.MouseButton1Click:Connect(function()
        multiHitRange = math.min(25, multiHitRange + 1)
        rangeFrame.valueText.Text = tostring(multiHitRange)
    end)
    
    -- Target slider
    targetFrame.minus.MouseButton1Click:Connect(function()
        multiHitTargets = math.max(1, multiHitTargets - 1)
        targetFrame.valueText.Text = tostring(multiHitTargets)
    end)
    targetFrame.plus.MouseButton1Click:Connect(function()
        multiHitTargets = math.min(25, multiHitTargets + 1)
        targetFrame.valueText.Text = tostring(multiHitTargets)
    end)
    
    -- Damage slider
    damageFrame.minus.MouseButton1Click:Connect(function()
        multiDamageMultiplier = math.max(1, multiDamageMultiplier - 1)
        damageFrame.valueText.Text = tostring(multiDamageMultiplier)
    end)
    damageFrame.plus.MouseButton1Click:Connect(function()
        multiDamageMultiplier = math.min(50, multiDamageMultiplier + 1)
        damageFrame.valueText.Text = tostring(multiDamageMultiplier)
    end)
    
    -- Speed slider
    speedSlider.minus.MouseButton1Click:Connect(function()
        speedValue = math.max(16, speedValue - 1)
        speedSlider.valueText.Text = tostring(speedValue)
        ApplySpeed()
    end)
    speedSlider.plus.MouseButton1Click:Connect(function()
        speedValue = math.min(100, speedValue + 1)
        speedSlider.valueText.Text = tostring(speedValue)
        ApplySpeed()
    end)
    
    -- Jump slider
    jumpSlider.minus.MouseButton1Click:Connect(function()
        jumpValue = math.max(50, jumpValue - 1)
        jumpSlider.valueText.Text = tostring(jumpValue)
        ApplyJump()
    end)
    jumpSlider.plus.MouseButton1Click:Connect(function()
        jumpValue = math.min(100, jumpValue + 1)
        jumpSlider.valueText.Text = tostring(jumpValue)
        ApplyJump()
    end)
    
    -- Thickness slider
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
    
    -- TOGGLE MENU
    local menuVisible = false
    swordIcon.MouseButton1Click:Connect(function()
        menuVisible = not menuVisible
        menuFrame.Visible = menuVisible
        if menuVisible then
            menuFrame:TweenSize(UDim2.new(0, 320, 0, 450), "Out", "Quad", 0.2, true)
        end
    end)
    
    closeMenuBtn.MouseButton1Click:Connect(function()
        menuVisible = false
        menuFrame.Visible = false
    end)
    
    -- DRAG MENU
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = menuFrame.Position
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
            menuFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    return screenGui
end

-- ============================================
-- ESP FUNCTIONS (dari sebelumnya)
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
    if speedEnabled then
        LocalPlayer.Character.Humanoid.WalkSpeed = speedValue
    else
        LocalPlayer.Character.Humanoid.WalkSpeed = originalWalkSpeed
    end
end

local function ApplyJump()
    if jumpEnabled then
        LocalPlayer.Character.Humanoid.JumpPower = jumpValue
    else
        LocalPlayer.Character.Humanoid.JumpPower = originalJumpPower
    end
end

-- ============================================
-- MULTI HIT FUNCTION
-- ============================================
local function GetNearestTarget()
    local closest = nil
    local closestDist = multiHitRange
    local char = LocalPlayer.Character
    if not char then return nil end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local targetChar = player.Character
            if targetChar then
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    local dist = (rootPart.Position - targetRoot.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

-- ============================================
-- MULTI DAMAGE FUNCTION (Hook ke damage)
-- ============================================
local function SetupDamageHook()
    -- Hook ke damage event (contoh untuk game tertentu)
    -- Generic approach: coba hook ke humanoid
    local oldHealth = {}
    
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(char)
            local humanoid = char:WaitForChild("Humanoid")
            oldHealth[player] = humanoid.Health
            
            humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                if multiDamageEnabled and multiDamageMultiplier > 1 then
                    local damage = oldHealth[player] - humanoid.Health
                    if damage > 0 then
                        -- Apply multiplier ke damage
                        local newHealth = humanoid.Health - (damage * (multiDamageMultiplier - 1))
                        humanoid.Health = newHealth
                    end
                end
                oldHealth[player] = humanoid.Health
            end)
        end)
    end)
end

-- ============================================
-- MULTI HIT LOOP
-- ============================================
local function MultiHitLoop()
    while true do
        wait(0.1)
        if multiHitEnabled then
            -- Ini adalah framework untuk multi hit
            -- Implementasi spesifik tergantung game
            -- Contoh: mencari tool dan mengaktifkannya ke multiple target
        end
    end
end

-- ============================================
-- INITIALIZE
-- ============================================

-- ESP INIT
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

-- Speed & Jump character added
LocalPlayer.CharacterAdded:Connect(function(char)
    wait(0.5)
    originalWalkSpeed = char.Humanoid.WalkSpeed
    originalJumpPower = char.Humanoid.JumpPower
    if speedEnabled then ApplySpeed() end
    if jumpEnabled then ApplyJump() end
end)

-- Setup damage hook
SetupDamageHook()

-- Start multi hit loop
coroutine.wrap(MultiHitLoop)()

-- ============================================
-- CREATE UI
-- ============================================
CreateSwordUI()
