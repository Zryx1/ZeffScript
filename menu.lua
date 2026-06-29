-- ========================================
-- VORTEX MENU - HANYA UI
-- TANPA FUNGSI, CUMA TAMPILAN
-- ========================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Panggil fungsi dari script fungsi.lua
local VortexFungsi = _G.VortexFungsi or {}

-- ========== BUAT GUI ==========
local gui = Instance.new("ScreenGui")
gui.Name = "VortexMenu"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 340, 0, 520)
frame.Position = UDim2.new(0.5, -170, 0.05, 0)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 0
frame.Parent = gui

local fCorner = Instance.new("UICorner")
fCorner.CornerRadius = UDim.new(0, 8)
fCorner.Parent = frame

-- HEADER
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
header.BackgroundTransparency = 0
header.BorderSizePixel = 0
header.Parent = frame

local hCorner = Instance.new("UICorner")
hCorner.CornerRadius = UDim.new(0, 8)
hCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.5, 0, 1, 0)
title.Position = UDim2.new(0.05, 0, 0, 0)
title.Text = "VORTEX"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 25, 0, 25)
minBtn.Position = UDim2.new(1, -50, 0.5, -12.5)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255,255,255)
minBtn.BackgroundTransparency = 1
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -25, 0.5, -12.5)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.Parent = header

-- DIVIDER
local divider = Instance.new("Frame")
divider.Size = UDim2.new(0, 1, 1, -42)
divider.Position = UDim2.new(0.3, 0, 0, 35)
divider.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
divider.BackgroundTransparency = 0.3
divider.BorderSizePixel = 0
divider.Parent = frame

-- ===== KIRI: KATEGORI =====
local leftScroll = Instance.new("ScrollingFrame")
leftScroll.Size = UDim2.new(0.3, -6, 1, -42)
leftScroll.Position = UDim2.new(0, 3, 0, 35)
leftScroll.BackgroundTransparency = 1
leftScroll.CanvasSize = UDim2.new(0, 0, 0, 350)
leftScroll.ScrollBarThickness = 2
leftScroll.ScrollBarImageColor3 = Color3.fromRGB(155, 0, 255)
leftScroll.Parent = frame

-- ===== KANAN: ISI =====
local rightScroll = Instance.new("ScrollingFrame")
rightScroll.Size = UDim2.new(0.7, -8, 1, -42)
rightScroll.Position = UDim2.new(0.3, 5, 0, 35)
rightScroll.BackgroundTransparency = 1
rightScroll.CanvasSize = UDim2.new(0, 0, 0, 1600)
rightScroll.ScrollBarThickness = 2
rightScroll.ScrollBarImageColor3 = Color3.fromRGB(155, 0, 255)
rightScroll.Parent = frame

-- ===== KIRI: KATEGORI =====
local ly = 5
local categories = {"ESP MENU", "SPECIAL MENU", "PLAYER MENU", "BETA TEST"}
local categoryBtns = {}

for _, cat in ipairs(categories) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 28)
    btn.Position = UDim2.new(0, 3, 0, ly)
    btn.Text = cat
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,55)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.Parent = leftScroll
    
    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 4)
    bCorner.Parent = btn
    
    categoryBtns[cat] = btn
    ly = ly + 32
end

leftScroll.CanvasSize = UDim2.new(0, 0, 0, ly + 10)

-- ===== KANAN: BUILD KONTEN =====
local ry = 5
local currentCategory = "ESP MENU"
local statusText = nil

local function AddSeparator(text)
    local sep = Instance.new("TextLabel")
    sep.Size = UDim2.new(1, -6, 0, 18)
    sep.Position = UDim2.new(0, 3, 0, ry)
    sep.Text = "--- " .. text .. " ---"
    sep.TextColor3 = Color3.fromRGB(155, 0, 255)
    sep.BackgroundTransparency = 1
    sep.Font = Enum.Font.GothamBold
    sep.TextSize = 9
    sep.Parent = rightScroll
    ry = ry + 20
end

local function AddToggle(label, state, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 26)
    btn.Position = UDim2.new(0, 3, 0, ry)
    btn.Text = state and (label .. " [ON]") or (label .. " [OFF]")
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundColor3 = state and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.Parent = rightScroll
    
    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 4)
    bCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        callback()
        local newState = (btn.BackgroundColor3 == Color3.fromRGB(0,180,0))
        btn.Text = newState and (label .. " [ON]") or (label .. " [OFF]")
    end)
    
    ry = ry + 30
    return btn
end

local function AddSlider(label, value, minVal, maxVal, callback)
    local frameSlider = Instance.new("Frame")
    frameSlider.Size = UDim2.new(1, -6, 0, 28)
    frameSlider.Position = UDim2.new(0, 3, 0, ry)
    frameSlider.BackgroundColor3 = Color3.fromRGB(30,30,42)
    frameSlider.BackgroundTransparency = 0
    frameSlider.BorderSizePixel = 0
    frameSlider.Parent = rightScroll
    
    local sCorner = Instance.new("UICorner")
    sCorner.CornerRadius = UDim.new(0, 4)
    sCorner.Parent = frameSlider
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.35, 0, 1, 0)
    lbl.Position = UDim2.new(0, 6, 0, 0)
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200,200,220)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 8
    lbl.Parent = frameSlider
    
    local valTxt = Instance.new("TextLabel")
    valTxt.Size = UDim2.new(0.2, 0, 1, 0)
    valTxt.Position = UDim2.new(0.45, 0, 0, 0)
    valTxt.Text = tostring(value)
    valTxt.TextColor3 = Color3.fromRGB(155,0,255)
    valTxt.BackgroundTransparency = 1
    valTxt.Font = Enum.Font.GothamBold
    valTxt.TextSize = 8
    valTxt.Parent = frameSlider
    
    local minus = Instance.new("TextButton")
    minus.Size = UDim2.new(0, 18, 0, 18)
    minus.Position = UDim2.new(1, -40, 0.5, -9)
    minus.Text = "-"
    minus.TextColor3 = Color3.fromRGB(255,255,255)
    minus.BackgroundColor3 = Color3.fromRGB(55,55,75)
    minus.Font = Enum.Font.GothamBold
    minus.TextSize = 12
    minus.Parent = frameSlider
    
    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0, 18, 0, 18)
    plus.Position = UDim2.new(1, -20, 0.5, -9)
    plus.Text = "+"
    plus.TextColor3 = Color3.fromRGB(255,255,255)
    plus.BackgroundColor3 = Color3.fromRGB(55,55,75)
    plus.Font = Enum.Font.GothamBold
    plus.TextSize = 12
    plus.Parent = frameSlider
    
    local mCorner = Instance.new("UICorner")
    mCorner.CornerRadius = UDim.new(0, 3)
    mCorner.Parent = minus
    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(0, 3)
    pCorner.Parent = plus
    
    local val = value
    minus.MouseButton1Click:Connect(function()
        val = math.max(minVal, val - 1)
        valTxt.Text = tostring(val)
        callback(val)
    end)
    plus.MouseButton1Click:Connect(function()
        val = math.min(maxVal, val + 1)
        valTxt.Text = tostring(val)
        callback(val)
    end)
    
    ry = ry + 32
    return {frame = frameSlider, value = valTxt, minus = minus, plus = plus}
end

-- ===== BUILD KONTEN =====
local function BuildESPContent()
    ry = 5
    AddSeparator("ESP PLAYER")
    local masterBtn = AddToggle("Master ESP", _G.VortexFungsi.masterESP or false, function()
        _G.VortexFungsi.ToggleMaster()
    end)
    local nameBtn = AddToggle("Name ESP", _G.VortexFungsi.espName or false, function()
        _G.VortexFungsi.ToggleName()
    end)
    local lineBtn = AddToggle("Line ESP", _G.VortexFungsi.espLine or false, function()
        _G.VortexFungsi.ToggleLine()
    end)
    local boxBtn = AddToggle("Box ESP", _G.VortexFungsi.espBox or false, function()
        _G.VortexFungsi.ToggleBox()
    end)
    local distBtn = AddToggle("Distance ESP", _G.VortexFungsi.espDistance or false, function()
        _G.VortexFungsi.ToggleDistance()
    end)
    
    AddSeparator("WARNA & KETEBALAN")
    
    -- Warna
    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(1, -6, 0, 28)
    colorFrame.Position = UDim2.new(0, 3, 0, ry)
    colorFrame.BackgroundColor3 = Color3.fromRGB(30,30,42)
    colorFrame.BackgroundTransparency = 0
    colorFrame.BorderSizePixel = 0
    colorFrame.Parent = rightScroll
    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 4)
    cCorner.Parent = colorFrame
    
    local colorLabel = Instance.new("TextLabel")
    colorLabel.Size = UDim2.new(0.5, 0, 1, 0)
    colorLabel.Position = UDim2.new(0, 6, 0, 0)
    colorLabel.Text = "Warna: Ungu"
    colorLabel.TextColor3 = Color3.fromRGB(200,200,220)
    colorLabel.BackgroundTransparency = 1
    colorLabel.Font = Enum.Font.GothamBold
    colorLabel.TextSize = 8
    colorLabel.Parent = colorFrame
    
    local colorLeft = Instance.new("TextButton")
    colorLeft.Size = UDim2.new(0, 18, 0, 18)
    colorLeft.Position = UDim2.new(1, -40, 0.5, -9)
    colorLeft.Text = "<"
    colorLeft.TextColor3 = Color3.fromRGB(255,255,255)
    colorLeft.BackgroundColor3 = Color3.fromRGB(55,55,75)
    colorLeft.Font = Enum.Font.GothamBold
    colorLeft.TextSize = 10
    colorLeft.Parent = colorFrame
    colorLeft.MouseButton1Click:Connect(function()
        _G.VortexFungsi.PrevColor()
        colorLabel.Text = "Warna: " .. _G.VortexFungsi.GetColorName()
    end)
    
    local colorRight = Instance.new("TextButton")
    colorRight.Size = UDim2.new(0, 18, 0, 18)
    colorRight.Position = UDim2.new(1, -20, 0.5, -9)
    colorRight.Text = ">"
    colorRight.TextColor3 = Color3.fromRGB(255,255,255)
    colorRight.BackgroundColor3 = Color3.fromRGB(55,55,75)
    colorRight.Font = Enum.Font.GothamBold
    colorRight.TextSize = 10
    colorRight.Parent = colorFrame
    colorRight.MouseButton1Click:Connect(function()
        _G.VortexFungsi.NextColor()
        colorLabel.Text = "Warna: " .. _G.VortexFungsi.GetColorName()
    end)
    ry = ry + 32
    
    AddSlider("Ketebalan", _G.VortexFungsi.espThick or 2, 1, 5, function(val)
        _G.VortexFungsi.UpdateThick(val)
    end)
    ry = ry + 5
    
    AddSeparator("ESP ENTITY")
    local entityBtn = AddToggle("Entity ESP", _G.VortexFungsi.espEntity or false, function()
        _G.VortexFungsi.ToggleEntityESP()
    end)
    local entityBoxBtn = AddToggle("Entity Box", _G.VortexFungsi.espEntityBox or false, function()
        _G.VortexFungsi.ToggleEntityBox()
    end)
    local entityNameBtn = AddToggle("Entity Name", _G.VortexFungsi.espEntityName or false, function()
        _G.VortexFungsi.ToggleEntityName()
    end)
    local entityDistBtn = AddToggle("Entity Dist", _G.VortexFungsi.espEntityDistance or false, function()
        _G.VortexFungsi.ToggleEntityDistance()
    end)
    
    rightScroll.CanvasSize = UDim2.new(0, 0, 0, ry + 30)
end

local function BuildSpecialContent()
    ry = 5
    AddSeparator("SPECIAL MENU")
    
    AddToggle("Wallhack", _G.VortexFungsi.noclipEnabled or false, function()
        _G.VortexFungsi.ToggleWallhack()
    end)
    
    AddSeparator("FLY")
    AddToggle("Fly", _G.VortexFungsi.flying or false, function()
        _G.VortexFungsi.ToggleFly()
    end)
    
    -- UP/DN Buttons
    local upBtn = Instance.new("TextButton")
    upBtn.Size = UDim2.new(0.45, -4, 0, 24)
    upBtn.Position = UDim2.new(0, 3, 0, ry)
    upBtn.Text = "UP"
    upBtn.TextColor3 = Color3.fromRGB(255,255,255)
    upBtn.BackgroundColor3 = Color3.fromRGB(0,100,200)
    upBtn.Font = Enum.Font.GothamBold
    upBtn.TextSize = 10
    upBtn.Parent = rightScroll
    upBtn.MouseButton1Down:Connect(function() _G.VortexFungsi.FlyUp() end)
    upBtn.MouseButton1Up:Connect(function() _G.VortexFungsi.FlyUpRelease() end)
    upBtn.InputEnded:Connect(function() _G.VortexFungsi.FlyUpRelease() end)
    
    local dnBtn = Instance.new("TextButton")
    dnBtn.Size = UDim2.new(0.45, -4, 0, 24)
    dnBtn.Position = UDim2.new(0.55, 0, 0, ry)
    dnBtn.Text = "DN"
    dnBtn.TextColor3 = Color3.fromRGB(255,255,255)
    dnBtn.BackgroundColor3 = Color3.fromRGB(200,100,0)
    dnBtn.Font = Enum.Font.GothamBold
    dnBtn.TextSize = 10
    dnBtn.Parent = rightScroll
    dnBtn.MouseButton1Down:Connect(function() _G.VortexFungsi.FlyDown() end)
    dnBtn.MouseButton1Up:Connect(function() _G.VortexFungsi.FlyDownRelease() end)
    dnBtn.InputEnded:Connect(function() _G.VortexFungsi.FlyDownRelease() end)
    ry = ry + 28
    
    AddSlider("Kecepatan Fly", _G.VortexFungsi.flySpeed or 2.0, 0.5, 10, function(val)
        _G.VortexFungsi.UpdateFlySpeed(val)
    end)
    ry = ry + 5
    
    rightScroll.CanvasSize = UDim2.new(0, 0, 0, ry + 30)
end

local function BuildPlayerContent()
    ry = 5
    AddSeparator("PLAYER MENU")
    
    AddToggle("Speed Boost", _G.VortexFungsi.speedBoost or false, function()
        _G.VortexFungsi.ToggleSpeed()
    end)
    AddSlider("Speed Value", _G.VortexFungsi.speedValue or 200, 25, 999, function(val)
        _G.VortexFungsi.UpdateSpeedVal(val)
    end)
    ry = ry + 5
    
    AddToggle("Jump Boost", _G.VortexFungsi.jumpBoost or false, function()
        _G.VortexFungsi.ToggleJump()
    end)
    AddSlider("Jump Value", _G.VortexFungsi.jumpValue or 200, 50, 999, function(val)
        _G.VortexFungsi.UpdateJumpVal(val)
    end)
    ry = ry + 5
    
    AddSeparator("HITBOX EXPANDER")
    
    AddToggle("Hitbox Expander", _G.VortexFungsi.hitboxExpanderEnabled or false, function()
        _G.VortexFungsi.ToggleHitboxExpander()
    end)
    
    -- Expander Slider
    local expanderLabel = Instance.new("TextLabel")
    expanderLabel.Size = UDim2.new(0.5, 0, 0, 20)
    expanderLabel.Position = UDim2.new(0, 3, 0, ry)
    expanderLabel.Text = "Expand: " .. (_G.VortexFungsi.hitboxExpander or 0) .. "%"
    expanderLabel.TextColor3 = Color3.fromRGB(200,200,220)
    expanderLabel.BackgroundTransparency = 1
    expanderLabel.Font = Enum.Font.GothamBold
    expanderLabel.TextSize = 8
    expanderLabel.Parent = rightScroll
    
    local expanderMinus = Instance.new("TextButton")
    expanderMinus.Size = UDim2.new(0, 18, 0, 18)
    expanderMinus.Position = UDim2.new(1, -40, 0, ry)
    expanderMinus.Text = "-"
    expanderMinus.TextColor3 = Color3.fromRGB(255,255,255)
    expanderMinus.BackgroundColor3 = Color3.fromRGB(55,55,75)
    expanderMinus.Font = Enum.Font.GothamBold
    expanderMinus.TextSize = 12
    expanderMinus.Parent = rightScroll
    
    local expanderPlus = Instance.new("TextButton")
    expanderPlus.Size = UDim2.new(0, 18, 0, 18)
    expanderPlus.Position = UDim2.new(1, -20, 0, ry)
    expanderPlus.Text = "+"
    expanderPlus.TextColor3 = Color3.fromRGB(255,255,255)
    expanderPlus.BackgroundColor3 = Color3.fromRGB(55,55,75)
    expanderPlus.Font = Enum.Font.GothamBold
    expanderPlus.TextSize = 12
    expanderPlus.Parent = rightScroll
    
    expanderMinus.MouseButton1Click:Connect(function()
        _G.VortexFungsi.UpdateHitboxExpand(-5)
        expanderLabel.Text = "Expand: " .. _G.VortexFungsi.hitboxExpander .. "%"
    end)
    expanderPlus.MouseButton1Click:Connect(function()
        _G.VortexFungsi.UpdateHitboxExpand(5)
        expanderLabel.Text = "Expand: " .. _G.VortexFungsi.hitboxExpander .. "%"
    end)
    ry = ry + 24
    
    AddSeparator("HITBOX ESP")
    AddToggle("Hitbox ESP", _G.VortexFungsi.espHitbox or false, function()
        _G.VortexFungsi.ToggleHitboxESP()
    end)
    AddSlider("Hitbox Tebal", _G.VortexFungsi.hitboxThick or 2, 1, 5, function(val)
        _G.VortexFungsi.UpdateHitboxThick(val)
    end)
    ry = ry + 5
    
    rightScroll.CanvasSize = UDim2.new(0, 0, 0, ry + 30)
end

local function BuildBetaContent()
    ry = 5
    AddSeparator("BETA TEST")
    
    AddToggle("Multi Pendapatan", _G.VortexFungsi.multiIncomeEnabled or false, function()
        _G.VortexFungsi.ToggleMultiIncome()
    end)
    AddSlider("Multiplier", _G.VortexFungsi.incomeMultiplier or 10, 1, 999, function(val)
        _G.VortexFungsi.UpdateMultiplier(val)
    end)
    ry = ry + 5
    
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -6, 0, 40)
    info.Position = UDim2.new(0, 3, 0, ry)
    info.Text = "Kali semua pendapatan:\nEXP, Gold, Money, Gems, dll"
    info.TextColor3 = Color3.fromRGB(100, 200, 255)
    info.BackgroundColor3 = Color3.fromRGB(25,25,35)
    info.BackgroundTransparency = 0
    info.Font = Enum.Font.Gotham
    info.TextSize = 7
    info.Parent = rightScroll
    ry = ry + 44
    
    rightScroll.CanvasSize = UDim2.new(0, 0, 0, ry + 30)
end

-- ===== FUNGSI SWITCH KATEGORI =====
local function SwitchCategory(cat)
    currentCategory = cat
    
    for _, child in pairs(rightScroll:GetChildren()) do
        child:Destroy()
    end
    
    ry = 5
    
    if cat == "ESP MENU" then
        BuildESPContent()
    elseif cat == "SPECIAL MENU" then
        BuildSpecialContent()
    elseif cat == "PLAYER MENU" then
        BuildPlayerContent()
    elseif cat == "BETA TEST" then
        BuildBetaContent()
    end
    
    for name, btn in pairs(categoryBtns) do
        if name == cat then
            btn.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        end
    end
    
    rightScroll.CanvasPosition = Vector2.new(0, 0)
end

for name, btn in pairs(categoryBtns) do
    btn.MouseButton1Click:Connect(function()
        SwitchCategory(name)
    end)
end

-- ===== STATUS =====
statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -8, 0, 24)
statusText.Position = UDim2.new(0, 4, 1, -28)
statusText.Text = "Ready"
statusText.TextColor3 = Color3.fromRGB(0,255,0)
statusText.BackgroundColor3 = Color3.fromRGB(20,20,30)
statusText.BackgroundTransparency = 0
statusText.Font = Enum.Font.GothamBold
statusText.TextSize = 8
statusText.Parent = frame
local stCorner = Instance.new("UICorner")
stCorner.CornerRadius = UDim.new(0, 4)
stCorner.Parent = statusText

-- ===== DRAG =====
local drag = false
local dragStart, frameStart

header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = true
        dragStart = i.Position
        frameStart = frame.Position
    end
end)

header.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = false
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if not drag then return end
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - dragStart
        frame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
    end
end)

-- ===== MINIMIZE =====
local min = false
minBtn.MouseButton1Click:Connect(function()
    if min then
        frame.Size = UDim2.new(0, 340, 0, 520)
        leftScroll.Visible = true
        rightScroll.Visible = true
        divider.Visible = true
        statusText.Visible = true
        minBtn.Text = "-"
        min = false
    else
        frame.Size = UDim2.new(0, 100, 0, 30)
        leftScroll.Visible = false
        rightScroll.Visible = false
        divider.Visible = false
        statusText.Visible = false
        minBtn.Text = "+"
        min = true
    end
end)

-- ===== CLOSE =====
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
    _G.VortexFungsi.Cleanup()
end)

-- ===== INIT =====
SwitchCategory("ESP MENU")

print("VORTEX MENU - LOADED")
print("Menunggu fungsi dari script kedua...")
