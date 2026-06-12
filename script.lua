-- ============================================
-- ZEFF VORTEX - SIMPLE & POWERFUL
-- TOMBOL PEDANG = MULTI HIT (ON/OFF, BISA DIGESER)
-- MENU = MODAL LAMA (BISA DIGESER, DIPERKECIL)
-- FITUR: ESP (BOX, LINE, NAME) + MULTI HIT + SPEED/JUMP
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ============================================
-- VARIABEL ESP
-- ============================================
local masterEsp = false
local boxEsp = false
local lineEsp = false
local nameEsp = false
local espColor = Color3.fromRGB(155, 0, 255)
local espThick = 2
local espList = {}

-- ============================================
-- VARIABEL MULTI HIT (Tombol Pedang)
-- ============================================
local multiHit = false
local mhRange = 20
local mhDamage = 10
local mhTargets = 10
local mhHitsPerSec = 5
local mhMode = "players" -- players / all

-- ============================================
-- VARIABEL SPEED & JUMP
-- ============================================
local speedBoost = false
local speedMult = 1
local jumpBoost = false
local jumpMult = 1
local origSpeed = 16
local origJump = 50

-- ============================================
-- CREATE MENU (MODAL LAMA, BISA DIGESER & DIPERKECIL)
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZeffVortex"
screenGui.ResetOnSpawn = false
pcall(function()
    screenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not screenGui.Parent then
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- FRAME UTAMA (BISA DI-GESER & DI-PERKECIL)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local mainBorder = Instance.new("UIStroke")
mainBorder.Thickness = 1
mainBorder.Color = Color3.fromRGB(155, 0, 255)
mainBorder.Transparency = 0.3
mainBorder.Parent = mainFrame

-- HEADER (BUAT DRAG)
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
header.BackgroundTransparency = 0.2
header.BorderSizePixel = 0
header.Parent = mainFrame

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

-- TOMBOL MINIMIZE (PERKECIL)
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -70, 0.5, -15)
minBtn.Text = "─"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.BackgroundTransparency = 1
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.Parent = header

-- TOMBOL CLOSE
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -38, 0.5, -15)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = header

-- CONTENT AREA
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -16, 1, -55)
content.Position = UDim2.new(0, 8, 0, 48)
content.BackgroundTransparency = 1
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.ScrollBarThickness = 3
content.ScrollBarImageColor3 = Color3.fromRGB(155, 0, 255)
content.Parent = mainFrame

local y = 5

-- ========== ESP SECTION ==========
local espLabel = Instance.new("TextLabel")
espLabel.Size = UDim2.new(1, 0, 0, 25)
espLabel.Position = UDim2.new(0, 0, 0, y)
espLabel.Text = "🎮 ESP SETTINGS"
espLabel.TextColor3 = Color3.fromRGB(155, 0, 255)
espLabel.BackgroundTransparency = 1
espLabel.Font = Enum.Font.GothamBold
espLabel.TextSize = 12
espLabel.Parent = content
y = y + 30

local masterBtn, masterStatus = createToggle(content, "🔘 MASTER ESP", y, masterEsp)
y = y + 40
local boxBtn, boxStatus = createToggle(content, "📦 BOX ESP", y, boxEsp)
y = y + 40
local lineBtn, lineStatus = createToggle(content, "📏 LINE ESP", y, lineEsp)
y = y + 40
local nameBtn, nameStatus = createToggle(content, "🏷️ NAME ESP", y, nameEsp)
y = y + 40
local thickControl = createSlider(content, "📏 KETEBALAN", y, espThick, 1, 5)
y = y + 50

-- ========== MULTI HIT SECTION ==========
local mhLabel = Instance.new("TextLabel")
mhLabel.Size = UDim2.new(1, 0, 0, 25)
mhLabel.Position = UDim2.new(0, 0, 0, y)
mhLabel.Text = "⚔️ MULTI HIT SETTINGS"
mhLabel.TextColor3 = Color3.fromRGB(155, 0, 255)
mhLabel.BackgroundTransparency = 1
mhLabel.Font = Enum.Font.GothamBold
mhLabel.TextSize = 12
mhLabel.Parent = content
y = y + 30

local rangeControl = createSlider(content, "📏 RADIUS (M)", y, mhRange, 5, 20)
y = y + 50
local damageControl = createSlider(content, "💥 DAMAGE", y, mhDamage, 1, 25)
y = y + 50
local targetControl = createSlider(content, "🎯 TARGET", y, mhTargets, 1, 20)
y = y + 50
local hitsControl = createSlider(content, "⚡ HIT/DETIK", y, mhHitsPerSec, 1, 10)
y = y + 50

-- Target Mode Toggle
local modeFrame = Instance.new("Frame")
modeFrame.Size = UDim2.new(1, 0, 0, 35)
modeFrame.Position = UDim2.new(0, 0, 0, y)
modeFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
modeFrame.BackgroundTransparency = 0
modeFrame.BorderSizePixel = 0
modeFrame.Parent = content
local modeCorner = Instance.new("UICorner")
modeCorner.CornerRadius = UDim.new(0, 8)
modeCorner.Parent = modeFrame

local modeText = Instance.new("TextLabel")
modeText.Size = UDim2.new(0.5, 0, 1, 0)
modeText.Position = UDim2.new(0, 10, 0, 0)
modeText.Text = "🎯 TARGET MODE"
modeText.TextColor3 = Color3.fromRGB(200, 200, 220)
modeText.BackgroundTransparency = 1
modeText.Font = Enum.Font.GothamBold
modeText.TextSize = 11
modeText.TextXAlignment = Enum.TextXAlignment.Left
modeText.Parent = modeFrame

local modeBtn = Instance.new("TextButton")
modeBtn.Size = UDim2.new(0.4, 0, 0.7, 0)
modeBtn.Position = UDim2.new(0.55, 0, 0.15, 0)
modeBtn.Text = "👤 PLAYERS"
modeBtn.TextColor3 = Color3.fromRGB(155, 0, 255)
modeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
modeBtn.Font = Enum.Font.GothamBold
modeBtn.TextSize = 10
modeBtn.Parent = modeFrame
local modeCorner2 = Instance.new("UICorner")
modeCorner2.CornerRadius = UDim.new(0, 6)
modeCorner2.Parent = modeBtn
y = y + 45

-- ========== BOOST SECTION ==========
local boostLabel = Instance.new("TextLabel")
boostLabel.Size = UDim2.new(1, 0, 0, 25)
boostLabel.Position = UDim2.new(0, 0, 0, y)
boostLabel.Text = "🏃 BOOST SETTINGS"
boostLabel.TextColor3 = Color3.fromRGB(155, 0, 255)
boostLabel.BackgroundTransparency = 1
boostLabel.Font = Enum.Font.GothamBold
boostLabel.TextSize = 12
boostLabel.Parent = content
y = y + 30

local speedBtn, speedStatus = createToggle(content, "⚡ SPEED BOOST", y, speedBoost)
y = y + 40
local speedControl = createSlider(content, "🏃 SPEED (x)", y, speedMult, 1, 100)
y = y + 50
local jumpBtn, jumpStatus = createToggle(content, "🦘 JUMP BOOST", y, jumpBoost)
y = y + 40
local jumpControl = createSlider(content, "📈 JUMP (x)", y, jumpMult, 1, 100)
y = y + 50

content.CanvasSize = UDim2.new(0, 0, 0, y + 20)

-- ========== FUNGSI CREATE UI ==========
function createToggle(parent, text, yPos, state)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = state and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
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
    status.TextSize = 11
    status.TextXAlignment = Enum.TextXAlignment.Right
    status.Parent = btn
    
    return btn, status
end

function createSlider(parent, label, yPos, value, minVal, maxVal)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.45, 0, 1, 0)
    labelText.Position = UDim2.new(0, 10, 0, 0)
    labelText.Text = label
    labelText.TextColor3 = Color3.fromRGB(200, 200, 220)
    labelText.BackgroundTransparency = 1
    labelText.Font = Enum.Font.GothamBold
    labelText.TextSize = 10
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = frame
    
    local valueText = Instance.new("TextLabel")
    valueText.Size = UDim2.new(0.2, 0, 1, 0)
    valueText.Position = UDim2.new(0.5, 0, 0, 0)
    valueText.Text = tostring(value)
    valueText.TextColor3 = Color3.fromRGB(155, 0, 255)
    valueText.BackgroundTransparency = 1
    valueText.Font = Enum.Font.GothamBold
    valueText.TextSize = 11
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
    
    return {frame = frame, valueText = valueText, minus = minus, plus = plus, min = minVal, max = maxVal}
end

-- ========== TOMBOL PEDANG (MULTI HIT, BISA DIGESER) ==========
local swordBtn = Instance.new("TextButton")
swordBtn.Size = UDim2.new(0, 50, 0, 50)
swordBtn.Position = UDim2.new(1, -65, 1, -180)
swordBtn.Text = "⚔️"
swordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
swordBtn.TextSize = 26
swordBtn.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
swordBtn.BackgroundTransparency = 0.2
swordBtn.BorderSizePixel = 0
swordBtn.Parent = screenGui

local swordCorner = Instance.new("UICorner")
swordCorner.CornerRadius = UDim.new(0, 25)
swordCorner.Parent = swordBtn

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

-- ON/OFF MULTI HIT (KLIK PEDANG)
swordBtn.MouseButton1Click:Connect(function()
    multiHit = not multiHit
    led.BackgroundColor3 = multiHit and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

-- ========== BUTTON ACTIONS ==========
masterBtn.MouseButton1Click:Connect(function()
    masterEsp = not masterEsp
    masterStatus.Text = masterEsp and "✅ ON" or "❌ OFF"
    masterStatus.TextColor3 = masterEsp and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
    masterBtn.BackgroundColor3 = masterEsp and Color3.fromRGB(155, 0, 255) or Color3.fromRGB(35, 35, 50)
end)

boxBtn.MouseButton1Click:Connect(function()
    boxEsp = not boxEsp
    boxStatus.Text = boxEsp and "✅ ON" or "❌ OFF"
    boxStatus.TextColor3 = boxEsp and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
    boxBtn.BackgroundColor3 = boxEsp and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
end)

lineBtn.MouseButton1Click:Connect(function()
    lineEsp = not lineEsp
    lineStatus.Text = lineEsp and "✅ ON" or "❌ OFF"
    lineStatus.TextColor3 = lineEsp and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
    lineBtn.BackgroundColor3 = lineEsp and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
end)

nameBtn.MouseButton1Click:Connect(function()
    nameEsp = not nameEsp
    nameStatus.Text = nameEsp and "✅ ON" or "❌ OFF"
    nameStatus.TextColor3 = nameEsp and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
    nameBtn.BackgroundColor3 = nameEsp and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
end)

thickControl.minus.MouseButton1Click:Connect(function()
    espThick = math.max(1, espThick - 1)
    thickControl.valueText.Text = tostring(espThick)
    refreshESP()
end)
thickControl.plus.MouseButton1Click:Connect(function()
    espThick = math.min(5, espThick + 1)
    thickControl.valueText.Text = tostring(espThick)
    refreshESP()
end)

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
    if mhMode == "players" then
        mhMode = "all"
        modeBtn.Text = "👾 ALL ENTITY"
    else
        mhMode = "players"
        modeBtn.Text = "👤 PLAYERS"
    end
end)

speedBtn.MouseButton1Click:Connect(function()
    speedBoost = not speedBoost
    speedStatus.Text = speedBoost and "✅ ON" or "❌ OFF"
    speedStatus.TextColor3 = speedBoost and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
    speedBtn.BackgroundColor3 = speedBoost and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
    applySpeed()
end)

speedControl.minus.MouseButton1Click:Connect(function()
    speedMult = math.max(1, speedMult - 1)
    speedControl.valueText.Text = speedMult .. "x"
    applySpeed()
end)
speedControl.plus.MouseButton1Click:Connect(function()
    speedMult = math.min(100, speedMult + 1)
    speedControl.valueText.Text = speedMult .. "x"
    applySpeed()
end)

jumpBtn.MouseButton1Click:Connect(function()
    jumpBoost = not jumpBoost
    jumpStatus.Text = jumpBoost and "✅ ON" or "❌ OFF"
    jumpStatus.TextColor3 = jumpBoost and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
    jumpBtn.BackgroundColor3 = jumpBoost and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
    applyJump()
end)

jumpControl.minus.MouseButton1Click:Connect(function()
    jumpMult = math.max(1, jumpMult - 1)
    jumpControl.valueText.Text = jumpMult .. "x"
    applyJump()
end)
jumpControl.plus.MouseButton1Click:Connect(function()
    jumpMult = math.min(100, jumpMult + 1)
    jumpControl.valueText.Text = jumpMult .. "x"
    applyJump()
end)

-- ========== DRAG MENU ==========
local menuDragStart, menuStartPos, isMenuDragging = nil, nil, false
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isMenuDragging = true
        menuDragStart = input.Position
        menuStartPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then isMenuDragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not isMenuDragging then return end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - menuDragStart
        mainFrame.Position = UDim2.new(menuStartPos.X.Scale, menuStartPos.X.Offset + delta.X, menuStartPos.Y.Scale, menuStartPos.Y.Offset + delta.Y)
    end
end)

-- ========== MINIMIZE (PERKECIL MENU) ==========
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    if minimized then
        mainFrame:TweenSize(UDim2.new(0, 300, 0, 400), "Out", "Quad", 0.2, true)
        content.Visible = true
        minBtn.Text = "─"
        minimized = false
    else
        mainFrame:TweenSize(UDim2.new(0, 200, 0, 40), "Out", "Quad", 0.2, true)
        content.Visible = false
        minBtn.Text = "□"
        minimized = true
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ============================================
-- ESP FUNCTIONS
-- ============================================
local function createESP(player)
    if player == LocalPlayer or espList[player] then return end
    local esp = {}
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = espColor
    box.Thickness = espThick
    box.Filled = false
    box.Transparency = 0.5
    esp.box = box
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = espColor
    line.Thickness = espThick
    line.Transparency = 0.5
    esp.line = line
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

local function removeESP(player)
    local esp = espList[player]
    if esp then
        if esp.box then esp.box:Remove() end
        if esp.line then esp.line:Remove() end
        if esp.nameTag then esp.nameTag:Remove() end
        espList[player] = nil
    end
end

local function refreshESP()
    for _, esp in pairs(espList) do
        if esp.box then
            esp.box.Color = espColor
            esp.box.Thickness = espThick
        end
        if esp.line then
            esp.line.Color = espColor
            esp.line.Thickness = espThick
        end
        if esp.nameTag then
            esp.nameTag.Color = espColor
        end
    end
end

local function updateESP()
    if not masterEsp then
        for _, esp in pairs(espList) do
            if esp.box then esp.box.Visible = false end
            if esp.line then esp.line.Visible = false end
            if esp.nameTag then esp.nameTag.Visible = false end
        end
        return
    end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, esp in pairs(espList) do
        local char = esp.player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not char or not hum or not root or hum.Health <= 0 then
            if esp.box then esp.box.Visible = false end
            if esp.line then esp.line.Visible = false end
            if esp.nameTag then esp.nameTag.Visible = false end
        else
            local vec, on = Camera:WorldToViewportPoint(root.Position)
            if on then
                if boxEsp and esp.box then
                    local dist = (root.Position - Camera.CFrame.Position).Magnitude
                    local size = math.clamp(200 / dist, 30, 120)
                    local x = vec.X - size / 2
                    local y = vec.Y - size / 1.2
                    esp.box.Size = Vector2.new(size, size)
                    esp.box.Position = Vector2.new(x, y)
                    esp.box.Visible = true
                elseif esp.box then esp.box.Visible = false end
                if lineEsp and esp.line then
                    esp.line.From = center
                    esp.line.To = Vector2.new(vec.X, vec.Y)
                    esp.line.Visible = true
                elseif esp.line then esp.line.Visible = false end
                if nameEsp and esp.nameTag then
                    esp.nameTag.Text = esp.player.Name
                    esp.nameTag.Position = Vector2.new(vec.X, vec.Y - 25)
                    esp.nameTag.Visible = true
                elseif esp.nameTag then esp.nameTag.Visible = false end
            else
                if esp.box then esp.box.Visible = false end
                if esp.line then esp.line.Visible = false end
                if esp.nameTag then esp.nameTag.Visible = false end
            end
        end
    end
end

-- ============================================
-- SPEED & JUMP
-- ============================================
local function applySpeed()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = speedBoost and (origSpeed * speedMult) or origSpeed
    end
end

local function applyJump()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = jumpBoost and (origJump * jumpMult) or origJump
    end
end

-- ============================================
-- MULTI HIT
-- ============================================
local function getTargets()
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

local function doMultiHit()
    if not multiHit then return end
    local targets = getTargets()
    for _, h in ipairs(targets) do
        h.Health = h.Health - mhDamage
    end
end

-- ============================================
-- INIT
-- ============================================
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then createESP(p) end
end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then createESP(p) end end)
Players.PlayerRemoving:Connect(removeESP)
RunService.RenderStepped:Connect(updateESP)

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    wait(0.5)
    origSpeed = char.Humanoid.WalkSpeed
    origJump = char.Humanoid.JumpPower
    applySpeed()
    applyJump()
end)

local lastHit = 0
coroutine.wrap(function()
    while true do
        if multiHit then
            local now = tick()
            if now - lastHit >= (1 / mhHitsPerSec) then
                doMultiHit()
                lastHit = now
            end
        end
        wait(0.01)
    end
end)()

print("==========================================")
print("ZEFF VORTEX - READY")
print("MENU: Bisa digeser & diperkecil")
print("TOMBOL PEDANG: ON/OFF Multi Hit (bisa digeser)")
print("==========================================")
