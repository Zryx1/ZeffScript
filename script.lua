-- ========================================
-- VORTEX ULTIMATE - SCROLL VERSION
-- GESER KE BAWAH BUAT LIAT SEMUA FITUR
-- ========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ========== VARIABEL ==========
local masterESP = false
local espBox = false
local espTracer = false
local espName = false
local espThick = 2

local autoHit = false
local hitRange = 100
local hitDamage = 999
local hitDelay = 0.01

local speedBoost = false
local speedVal = 999
local jumpBoost = false
local jumpVal = 999

local espObjects = {}
local origSpeed = 16
local origJump = 50

-- ========== FUNGSI ESP ==========
local function CreateESP(player)
    if player == LocalPlayer or espObjects[player] then return end
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(155,0,255)
    box.Thickness = espThick
    box.Filled = false
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = Color3.fromRGB(155,0,255)
    tracer.Thickness = espThick
    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Color = Color3.fromRGB(155,0,255)
    nameTag.Size = 12
    nameTag.Center = true
    nameTag.Outline = true
    espObjects[player] = {box=box, tracer=tracer, nameTag=nameTag, player=player}
end

local function RemoveESP(player)
    local esp = espObjects[player]
    if esp then
        if esp.box then esp.box:Remove() end
        if esp.tracer then esp.tracer:Remove() end
        if esp.nameTag then esp.nameTag:Remove() end
        espObjects[player] = nil
    end
end

local function UpdateESP()
    if not masterESP then
        for _, esp in pairs(espObjects) do
            if esp.box then esp.box.Visible = false end
            if esp.tracer then esp.tracer.Visible = false end
            if esp.nameTag then esp.nameTag.Visible = false end
        end
        return
    end
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, esp in pairs(espObjects) do
        local char = esp.player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not char or not hum or not root or hum.Health <= 0 then
            if esp.box then esp.box.Visible = false end
            if esp.tracer then esp.tracer.Visible = false end
            if esp.nameTag then esp.nameTag.Visible = false end
        else
            local pos, on = Camera:WorldToViewportPoint(root.Position)
            if espBox and esp.box and on then
                local dist = (root.Position - Camera.CFrame.Position).Magnitude
                local size = math.clamp(180/dist, 30, 90)
                esp.box.Size = Vector2.new(size, size)
                esp.box.Position = Vector2.new(pos.X - size/2, pos.Y - size/1.2)
                esp.box.Visible = true
            elseif esp.box then esp.box.Visible = false end
            if espTracer and esp.tracer and on then
                esp.tracer.From = center
                esp.tracer.To = Vector2.new(pos.X, pos.Y)
                esp.tracer.Visible = true
            elseif esp.tracer then esp.tracer.Visible = false end
            if espName and esp.nameTag and on then
                esp.nameTag.Text = esp.player.Name
                esp.nameTag.Position = Vector2.new(pos.X, pos.Y - 25)
                esp.nameTag.Visible = true
            elseif esp.nameTag then esp.nameTag.Visible = false end
        end
    end
end

local function RefreshESP()
    for _, esp in pairs(espObjects) do
        if esp.box then esp.box.Color = Color3.fromRGB(155,0,255) esp.box.Thickness = espThick end
        if esp.tracer then esp.tracer.Color = Color3.fromRGB(155,0,255) esp.tracer.Thickness = espThick end
        if esp.nameTag then esp.nameTag.Color = Color3.fromRGB(155,0,255) end
    end
end

-- ========== FUNGSI MULTI HIT ==========
local function GetAllTargets()
    local targets = {}
    local char = LocalPlayer.Character
    if not char then return targets end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return targets end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local c = p.Character
            if c then
                local r = c:FindFirstChild("HumanoidRootPart")
                local h = c:FindFirstChild("Humanoid")
                if r and h and h.Health > 0 then
                    local dist = (root.Position - r.Position).Magnitude
                    if dist <= hitRange then
                        table.insert(targets, h)
                    end
                end
            end
        end
    end
    return targets
end

local function DoAutoHit()
    if not autoHit then return end
    local targets = GetAllTargets()
    for _, h in ipairs(targets) do
        h.Health = h.Health - hitDamage
    end
end

local function ManualAttack()
    local targets = GetAllTargets()
    if #targets > 0 then
        for _, h in ipairs(targets) do
            h.Health = h.Health - 999
        end
        statusText.Text = "⚔️ DAMAGE 999 KE " .. #targets .. " TARGET!"
        statusText.TextColor3 = Color3.fromRGB(0,255,0)
        task.wait(0.5)
        statusText.Text = "✅ READY"
        statusText.TextColor3 = Color3.fromRGB(0,255,0)
    else
        statusText.Text = "❌ TIDAK ADA TARGET!"
        statusText.TextColor3 = Color3.fromRGB(255,0,0)
        task.wait(0.5)
        statusText.Text = "✅ READY"
        statusText.TextColor3 = Color3.fromRGB(0,255,0)
    end
end

-- ========== SPEED JUMP ==========
local function ApplySpeed()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = speedBoost and speedVal or origSpeed
    end
end

local function ApplyJump()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = jumpBoost and jumpVal or origJump
    end
end

-- ========== BUAT GUI DENGAN SCROLL YANG BENER ==========
local gui = Instance.new("ScreenGui")
gui.Name = "VortexScroll"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- FRAME UTAMA (UKURAN HP FRIENDLY)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 480)
mainFrame.Position = UDim2.new(0.5, -150, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui

local mCorner = Instance.new("UICorner")
mCorner.CornerRadius = UDim.new(0, 12)
mCorner.Parent = mainFrame

-- HEADER (BUAT DRAG)
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 42)
header.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
header.BackgroundTransparency = 0
header.BorderSizePixel = 0
header.Parent = mainFrame

local hCorner = Instance.new("UICorner")
hCorner.CornerRadius = UDim.new(0, 12)
hCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.6, 0, 1, 0)
title.Position = UDim2.new(0.05, 0, 0, 0)
title.Text = "⚔️ VORTEX ULTIMATE"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 35, 0, 35)
minBtn.Position = UDim2.new(1, -70, 0.5, -17.5)
minBtn.Text = "─"
minBtn.TextColor3 = Color3.fromRGB(255,255,255)
minBtn.BackgroundTransparency = 1
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 20
minBtn.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -35, 0.5, -17.5)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = header

-- SCROLLING FRAME (INI YANG BUAT GESER KE BAWAH)
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -12, 1, -52)
scroll.Position = UDim2.new(0, 6, 0, 48)
scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
scroll.BackgroundTransparency = 0
scroll.BorderSizePixel = 0
scroll.CanvasSize = UDim2.new(0, 0, 0, 620)
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(155, 0, 255)
scroll.Parent = mainFrame

local sCorner = Instance.new("UICorner")
sCorner.CornerRadius = UDim.new(0, 8)
sCorner.Parent = scroll

-- ========== ISI DALAM SCROLL ==========
local y = 8

-- ESP SECTION
local espTitle = Instance.new("TextLabel")
espTitle.Size = UDim2.new(1, -16, 0, 28)
espTitle.Position = UDim2.new(0, 8, 0, y)
espTitle.Text = "━━━━ 🎮 ESP MENU 🎮 ━━━━"
espTitle.TextColor3 = Color3.fromRGB(155, 0, 255)
espTitle.BackgroundTransparency = 1
espTitle.Font = Enum.Font.GothamBold
espTitle.TextSize = 12
espTitle.Parent = scroll
y = y + 32

local masterBtn = CreateButton(scroll, "MASTER ESP", y, masterESP)
y = y + 44
local boxBtn = CreateButton(scroll, "BOX ESP", y, espBox)
y = y + 42
local tracerBtn = CreateButton(scroll, "TRACER ESP", y, espTracer)
y = y + 42
local nameBtn = CreateButton(scroll, "NAME ESP", y, espName)
y = y + 42

-- Ketebalan slider
local thickFrame = CreateSliderFrame(scroll, "KETEBALAN", y, espThick, 1, 5)
local thickLabel = thickFrame.label
local thickMinus = thickFrame.minus
local thickPlus = thickFrame.plus
local thickVal = thickFrame.value
y = y + 48

-- HIT SECTION
local hitTitle = Instance.new("TextLabel")
hitTitle.Size = UDim2.new(1, -16, 0, 28)
hitTitle.Position = UDim2.new(0, 8, 0, y)
hitTitle.Text = "━━━━ ⚔️ MULTI HIT ⚔️ ━━━━"
hitTitle.TextColor3 = Color3.fromRGB(155, 0, 255)
hitTitle.BackgroundTransparency = 1
hitTitle.Font = Enum.Font.GothamBold
hitTitle.TextSize = 12
hitTitle.Parent = scroll
y = y + 32

local attackBtn = Instance.new("TextButton")
attackBtn.Size = UDim2.new(1, -16, 0, 52)
attackBtn.Position = UDim2.new(0, 8, 0, y)
attackBtn.Text = "⚔️ SERANG SEMUA! ⚔️"
attackBtn.TextColor3 = Color3.fromRGB(255,255,255)
attackBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
attackBtn.Font = Enum.Font.GothamBold
attackBtn.TextSize = 16
attackBtn.Parent = scroll
local aCorner = Instance.new("UICorner")
aCorner.CornerRadius = UDim.new(0, 8)
aCorner.Parent = attackBtn
y = y + 58

local autoBtn = CreateButton(scroll, "AUTO HIT", y, autoHit)
y = y + 44

local autoStatus = Instance.new("TextLabel")
autoStatus.Size = UDim2.new(1, -16, 0, 28)
autoStatus.Position = UDim2.new(0, 8, 0, y)
autoStatus.Text = "📌 STATUS: MATI"
autoStatus.TextColor3 = Color3.fromRGB(255,100,100)
autoStatus.BackgroundColor3 = Color3.fromRGB(30,30,42)
autoStatus.BackgroundTransparency = 0
autoStatus.Font = Enum.Font.GothamBold
autoStatus.TextSize = 11
autoStatus.Parent = scroll
local asCorner = Instance.new("UICorner")
asCorner.CornerRadius = UDim.new(0, 6)
asCorner.Parent = autoStatus
y = y + 34

local rangeInfo = Instance.new("TextLabel")
rangeInfo.Size = UDim2.new(1, -16, 0, 24)
rangeInfo.Position = UDim2.new(0, 8, 0, y)
rangeInfo.Text = "📍 RADIUS: 100 METER (MAX)"
rangeInfo.TextColor3 = Color3.fromRGB(0,255,0)
rangeInfo.BackgroundTransparency = 1
rangeInfo.Font = Enum.Font.GothamBold
rangeInfo.TextSize = 11
rangeInfo.Parent = scroll
y = y + 28

local damageInfo = Instance.new("TextLabel")
damageInfo.Size = UDim2.new(1, -16, 0, 24)
damageInfo.Position = UDim2.new(0, 8, 0, y)
damageInfo.Text = "💥 DAMAGE: 999 (MAX)"
damageInfo.TextColor3 = Color3.fromRGB(0,255,0)
damageInfo.BackgroundTransparency = 1
damageInfo.Font = Enum.Font.GothamBold
damageInfo.TextSize = 11
damageInfo.Parent = scroll
y = y + 28

local hitInfo = Instance.new("TextLabel")
hitInfo.Size = UDim2.new(1, -16, 0, 24)
hitInfo.Position = UDim2.new(0, 8, 0, y)
hitInfo.Text = "⚡ 100 HIT PER DETIK (MAX)"
hitInfo.TextColor3 = Color3.fromRGB(0,255,0)
hitInfo.BackgroundTransparency = 1
hitInfo.Font = Enum.Font.GothamBold
hitInfo.TextSize = 11
hitInfo.Parent = scroll
y = y + 32

-- BOOST SECTION
local boostTitle = Instance.new("TextLabel")
boostTitle.Size = UDim2.new(1, -16, 0, 28)
boostTitle.Position = UDim2.new(0, 8, 0, y)
boostTitle.Text = "━━━━ 🏃 BOOST MENU 🏃 ━━━━"
boostTitle.TextColor3 = Color3.fromRGB(155, 0, 255)
boostTitle.BackgroundTransparency = 1
boostTitle.Font = Enum.Font.GothamBold
boostTitle.TextSize = 12
boostTitle.Parent = scroll
y = y + 32

local speedBtn = CreateButton(scroll, "SPEED BOOST (999)", y, speedBoost)
y = y + 44
local jumpBtn = CreateButton(scroll, "JUMP BOOST (999)", y, jumpBoost)
y = y + 44

-- Status
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -16, 0, 34)
statusText.Position = UDim2.new(0, 8, 0, y)
statusText.Text = "✅ VORTEX READY"
statusText.TextColor3 = Color3.fromRGB(0,255,0)
statusText.BackgroundColor3 = Color3.fromRGB(25,25,35)
statusText.BackgroundTransparency = 0
statusText.Font = Enum.Font.GothamBold
statusText.TextSize = 12
statusText.Parent = scroll
local stCorner = Instance.new("UICorner")
stCorner.CornerRadius = UDim.new(0, 6)
stCorner.Parent = statusText
y = y + 42

scroll.CanvasSize = UDim2.new(0, 0, 0, y + 10)

-- ========== FUNGSI UI ==========
function CreateButton(parent, text, yPos, state)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 40)
    btn.Position = UDim2.new(0, 8, 0, yPos)
    btn.Text = state and text .. " ✅" or text .. " ❌"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundColor3 = state and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    return btn
end

function CreateSliderFrame(parent, label, yPos, value, minVal, maxVal)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -16, 0, 42)
    frame.Position = UDim2.new(0, 8, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,42)
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.Parent = parent
    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0, 6)
    fCorner.Parent = frame
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200,200,220)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local valTxt = Instance.new("TextLabel")
    valTxt.Size = UDim2.new(0.2, 0, 1, 0)
    valTxt.Position = UDim2.new(0.5, 0, 0, 0)
    valTxt.Text = tostring(value)
    valTxt.TextColor3 = Color3.fromRGB(155,0,255)
    valTxt.BackgroundTransparency = 1
    valTxt.Font = Enum.Font.GothamBold
    valTxt.TextSize = 12
    valTxt.Parent = frame
    
    local minus = Instance.new("TextButton")
    minus.Size = UDim2.new(0, 35, 0, 32)
    minus.Position = UDim2.new(1, -75, 0.5, -16)
    minus.Text = "-"
    minus.TextColor3 = Color3.fromRGB(255,255,255)
    minus.BackgroundColor3 = Color3.fromRGB(55,55,75)
    minus.Font = Enum.Font.GothamBold
    minus.TextSize = 18
    minus.Parent = frame
    local mCorner = Instance.new("UICorner")
    mCorner.CornerRadius = UDim.new(0, 5)
    mCorner.Parent = minus
    
    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0, 35, 0, 32)
    plus.Position = UDim2.new(1, -35, 0.5, -16)
    plus.Text = "+"
    plus.TextColor3 = Color3.fromRGB(255,255,255)
    plus.BackgroundColor3 = Color3.fromRGB(55,55,75)
    plus.Font = Enum.Font.GothamBold
    plus.TextSize = 18
    plus.Parent = frame
    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(0, 5)
    pCorner.Parent = plus
    
    return {frame=frame, label=lbl, value=valTxt, minus=minus, plus=plus}
end

-- ========== UPDATE FUNGSI ==========
local function UpdateMaster()
    masterESP = not masterESP
    masterBtn.Text = masterESP and "MASTER ESP ✅" or "MASTER ESP ❌"
    masterBtn.BackgroundColor3 = masterESP and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
end

local function UpdateBox()
    espBox = not espBox
    boxBtn.Text = espBox and "BOX ESP ✅" or "BOX ESP ❌"
    boxBtn.BackgroundColor3 = espBox and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
end

local function UpdateTracer()
    espTracer = not espTracer
    tracerBtn.Text = espTracer and "TRACER ESP ✅" or "TRACER ESP ❌"
    tracerBtn.BackgroundColor3 = espTracer and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
end

local function UpdateName()
    espName = not espName
    nameBtn.Text = espName and "NAME ESP ✅" or "NAME ESP ❌"
    nameBtn.BackgroundColor3 = espName and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
end

local function UpdateAuto()
    autoHit = not autoHit
    autoBtn.Text = autoHit and "AUTO HIT ✅" or "AUTO HIT ❌"
    autoBtn.BackgroundColor3 = autoHit and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
    autoStatus.Text = autoHit and "📌 STATUS: HIDUP - SERANG SEMUA TARGET" or "📌 STATUS: MATI"
    autoStatus.TextColor3 = autoHit and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,100,100)
    attackBtn.BackgroundColor3 = autoHit and Color3.fromRGB(0,120,0) or Color3.fromRGB(200,0,0)
end

local function UpdateSpeed()
    speedBoost = not speedBoost
    speedBtn.Text = speedBoost and "SPEED BOOST (999) ✅" or "SPEED BOOST (999) ❌"
    speedBtn.BackgroundColor3 = speedBoost and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
    ApplySpeed()
end

local function UpdateJump()
    jumpBoost = not jumpBoost
    jumpBtn.Text = jumpBoost and "JUMP BOOST (999) ✅" or "JUMP BOOST (999) ❌"
    jumpBtn.BackgroundColor3 = jumpBoost and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
    ApplyJump()
end

-- ========== CONNECT ==========
masterBtn.MouseButton1Click:Connect(UpdateMaster)
boxBtn.MouseButton1Click:Connect(UpdateBox)
tracerBtn.MouseButton1Click:Connect(UpdateTracer)
nameBtn.MouseButton1Click:Connect(UpdateName)
attackBtn.MouseButton1Click:Connect(ManualAttack)
autoBtn.MouseButton1Click:Connect(UpdateAuto)
speedBtn.MouseButton1Click:Connect(UpdateSpeed)
jumpBtn.MouseButton1Click:Connect(UpdateJump)

thickMinus.MouseButton1Click:Connect(function()
    espThick = math.max(1, espThick - 1)
    thickVal.Text = tostring(espThick)
    RefreshESP()
end)
thickPlus.MouseButton1Click:Connect(function()
    espThick = math.min(5, espThick + 1)
    thickVal.Text = tostring(espThick)
    RefreshESP()
end)

-- ========== DRAG MENU ==========
local dragActive = false
local dragStart, frameStart

header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragActive = true
        dragStart = i.Position
        frameStart = mainFrame.Position
    end
end)

header.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragActive = false
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if not dragActive then return end
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - dragStart
        mainFrame.Position = UDim2.new(
            frameStart.X.Scale, frameStart.X.Offset + delta.X,
            frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
        )
    end
end)

-- ========== MINIMIZE ==========
local isMin = false
minBtn.MouseButton1Click:Connect(function()
    if isMin then
        mainFrame.Size = UDim2.new(0, 300, 0, 480)
        scroll.Visible = true
        minBtn.Text = "─"
        isMin = false
    else
        mainFrame.Size = UDim2.new(0, 130, 0, 42)
        scroll.Visible = false
        minBtn.Text = "□"
        isMin = true
    end
end)

-- ========== CLOSE ==========
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
    for _, esp in pairs(espObjects) do
        if esp.box then esp.box:Remove() end
        if esp.tracer then esp.tracer:Remove() end
        if esp.nameTag then esp.nameTag:Remove() end
    end
end)

-- ========== INIT ==========
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then CreateESP(p) end end)
Players.PlayerRemoving:Connect(RemoveESP)

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.5)
    origSpeed = char.Humanoid.WalkSpeed
    origJump = char.Humanoid.JumpPower
    ApplySpeed()
    ApplyJump()
end)
if LocalPlayer.Character then
    origSpeed = LocalPlayer.Character.Humanoid.WalkSpeed
    origJump = LocalPlayer.Character.Humanoid.JumpPower
end

coroutine.wrap(function()
    while true do
        if autoHit then DoAutoHit() end
        task.wait(hitDelay)
    end
end)()

RunService.RenderStepped:Connect(UpdateESP)

print("========================================")
print("⚔️ VORTEX ULTIMATE - SCROLL VERSION ⚔️")
print("")
print("📱 GESER KE BAWAH buat liat semua menu!")
print("")
print("🔥 FITUR:")
print("- ESP (Box, Tracer, Name)")
print("- AUTO HIT (100 meter, 999 damage)")
print("- SPEED & JUMP BOOST (999)")
print("")
print("🎮 Cara:")
print("- Geser layar ke bawah")
print("- Drag header ungu buat mindahin")
print("- Tekan ─ buat minimize")
print("- Tekan ✕ buat close")
print("========================================")
