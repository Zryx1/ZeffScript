-- ========================================
-- VORTEX ULTIMATE - DELTA HP READY
-- RADIUS 100M | DAMAGE 999 | SPEED 999 | JUMP 999
-- ========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ========== VARIABEL ==========
-- ESP
local masterESP = false
local espBox = false
local espTracer = false
local espName = false
local espThick = 2

-- MULTI HIT (SEMUA TARGET)
local autoHit = false
local hitRange = 100  -- MAX 100 METER
local hitDamage = 999  -- DAMAGE 999
local hitDelay = 0.01  -- 100 HIT PER DETIK

-- SPEED JUMP (MAX 999)
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

-- ========== FUNGSI MULTI HIT (SEMUA TARGET DALAM RADIUS) ==========
local function GetAllTargetsInRange()
    local targets = {}
    local char = LocalPlayer.Character
    if not char then return targets end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return targets end
    
    -- SERANG SEMUA PLAYER LAIN
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
    
    -- SERANG NPC / ENTITY LAIN (OPTIONAL)
    local function scan(inst)
        for _, child in ipairs(inst:GetChildren()) do
            if child:IsA("Model") and child ~= char then
                local h = child:FindFirstChild("Humanoid")
                local r = child:FindFirstChild("HumanoidRootPart") or child:FindFirstChild("Head")
                if r and h and h.Health > 0 then
                    local dist = (root.Position - r.Position).Magnitude
                    if dist <= hitRange then
                        table.insert(targets, h)
                    end
                end
            end
            scan(child)
        end
    end
    scan(workspace)
    
    return targets
end

local function DoAutoHit()
    if not autoHit then return end
    local targets = GetAllTargetsInRange()
    for _, h in ipairs(targets) do
        h.Health = h.Health - hitDamage
    end
end

local function ManualAttack()
    local targets = GetAllTargetsInRange()
    if #targets > 0 then
        for _, h in ipairs(targets) do
            h.Health = h.Health - 999
        end
        statusLabel.Text = "⚔️ DAMAGE 999 to " .. #targets .. " targets! ⚔️"
        statusLabel.TextColor3 = Color3.fromRGB(0,255,0)
        task.wait(0.5)
        statusLabel.Text = "✅ VORTEX READY"
        statusLabel.TextColor3 = Color3.fromRGB(0,255,0)
    else
        statusLabel.Text = "❌ TIDAK ADA TARGET"
        statusLabel.TextColor3 = Color3.fromRGB(255,0,0)
        task.wait(0.5)
        statusLabel.Text = "✅ VORTEX READY"
        statusLabel.TextColor3 = Color3.fromRGB(0,255,0)
    end
end

-- ========== SPEED JUMP MAX ==========
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

-- ========== BUAT GUI ==========
local gui = Instance.new("ScreenGui")
gui.Name = "VortexUltimate"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- FRAME UTAMA
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 480)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -240)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = mainFrame

-- HEADER
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
header.BackgroundTransparency = 0
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.6, 0, 1, 0)
title.Position = UDim2.new(0.05, 0, 0, 0)
title.Text = "⚔️ VORTEX ULTIMATE"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 32, 0, 32)
minBtn.Position = UDim2.new(1, -70, 0.5, -16)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255,255,255)
minBtn.BackgroundTransparency = 1
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 20
minBtn.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -34, 0.5, -16)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = header

-- SCROLLING FRAME
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -16, 1, -55)
scroll.Position = UDim2.new(0, 8, 0, 48)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 520)
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(155, 0, 255)
scroll.Parent = mainFrame

local y = 5

-- ========== SECTION ESP ==========
local espTitle = Instance.new("TextLabel")
espTitle.Size = UDim2.new(1, 0, 0, 28)
espTitle.Position = UDim2.new(0, 0, 0, y)
espTitle.Text = "--- 🎮 ESP MENU 🎮 ---"
espTitle.TextColor3 = Color3.fromRGB(155, 0, 255)
espTitle.BackgroundTransparency = 1
espTitle.Font = Enum.Font.GothamBold
espTitle.TextSize = 12
espTitle.Parent = scroll
y = y + 30

local masterBtn = CreateSimpleButton(scroll, "MASTER ESP", y)
y = y + 42
local boxBtn = CreateSimpleButton(scroll, "BOX ESP", y)
y = y + 40
local tracerBtn = CreateSimpleButton(scroll, "TRACER ESP", y)
y = y + 40
local nameBtn = CreateSimpleButton(scroll, "NAME ESP", y)
y = y + 40

-- Ketebalan
local thickLabel = Instance.new("TextLabel")
thickLabel.Size = UDim2.new(0.5, 0, 0, 30)
thickLabel.Position = UDim2.new(0, 0, 0, y)
thickLabel.Text = "KETEBALAN: 2"
thickLabel.TextColor3 = Color3.fromRGB(200,200,220)
thickLabel.BackgroundTransparency = 1
thickLabel.Font = Enum.Font.GothamBold
thickLabel.TextSize = 12
thickLabel.TextXAlignment = Enum.TextXAlignment.Left
thickLabel.Parent = scroll

local thickMinus = CreateMinusButton(scroll, y)
local thickPlus = CreatePlusButton(scroll, y)
y = y + 40

-- ========== SECTION MULTI HIT ==========
local hitTitle = Instance.new("TextLabel")
hitTitle.Size = UDim2.new(1, 0, 0, 28)
hitTitle.Position = UDim2.new(0, 0, 0, y)
hitTitle.Text = "--- ⚔️ MULTI HIT ⚔️ ---"
hitTitle.TextColor3 = Color3.fromRGB(155, 0, 255)
hitTitle.BackgroundTransparency = 1
hitTitle.Font = Enum.Font.GothamBold
hitTitle.TextSize = 12
hitTitle.Parent = scroll
y = y + 30

-- Attack Manual
local attackBtn = Instance.new("TextButton")
attackBtn.Size = UDim2.new(1, 0, 0, 50)
attackBtn.Position = UDim2.new(0, 0, 0, y)
attackBtn.Text = "⚔️ SERANG SEMUA! ⚔️"
attackBtn.TextColor3 = Color3.fromRGB(255,255,255)
attackBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
attackBtn.Font = Enum.Font.GothamBold
attackBtn.TextSize = 14
attackBtn.Parent = scroll
local aCorner = Instance.new("UICorner")
aCorner.CornerRadius = UDim.new(0, 8)
aCorner.Parent = attackBtn
y = y + 56

-- Auto Hit Toggle
local autoBtn = CreateSimpleButton(scroll, "AUTO HIT (ON/OFF)", y)
y = y + 42

-- Status Auto Hit
local autoStatus = Instance.new("TextLabel")
autoStatus.Size = UDim2.new(1, 0, 0, 30)
autoStatus.Position = UDim2.new(0, 0, 0, y)
autoStatus.Text = "STATUS: MATI"
autoStatus.TextColor3 = Color3.fromRGB(255,100,100)
autoStatus.BackgroundColor3 = Color3.fromRGB(30,30,42)
autoStatus.BackgroundTransparency = 0
autoStatus.Font = Enum.Font.GothamBold
autoStatus.TextSize = 11
autoStatus.Parent = scroll
local asCorner = Instance.new("UICorner")
asCorner.CornerRadius = UDim.new(0, 6)
asCorner.Parent = autoStatus
y = y + 38

-- Info Radius
local rangeLabel = Instance.new("TextLabel")
rangeLabel.Size = UDim2.new(1, 0, 0, 28)
rangeLabel.Position = UDim2.new(0, 0, 0, y)
rangeLabel.Text = "📡 RADIUS: 100 METER (MAX)"
rangeLabel.TextColor3 = Color3.fromRGB(0,255,0)
rangeLabel.BackgroundTransparency = 1
rangeLabel.Font = Enum.Font.GothamBold
rangeLabel.TextSize = 11
rangeLabel.Parent = scroll
y = y + 30

-- Info Damage
local damageLabel = Instance.new("TextLabel")
damageLabel.Size = UDim2.new(1, 0, 0, 28)
damageLabel.Position = UDim2.new(0, 0, 0, y)
damageLabel.Text = "💥 DAMAGE: 999 (MAX)"
damageLabel.TextColor3 = Color3.fromRGB(0,255,0)
damageLabel.BackgroundTransparency = 1
damageLabel.Font = Enum.Font.GothamBold
damageLabel.TextSize = 11
damageLabel.Parent = scroll
y = y + 30

-- Info Hit Speed
local delayLabel = Instance.new("TextLabel")
delayLabel.Size = UDim2.new(1, 0, 0, 28)
delayLabel.Position = UDim2.new(0, 0, 0, y)
delayLabel.Text = "⚡ 100 HIT PER DETIK (MAX)"
delayLabel.TextColor3 = Color3.fromRGB(0,255,0)
delayLabel.BackgroundTransparency = 1
delayLabel.Font = Enum.Font.GothamBold
delayLabel.TextSize = 11
delayLabel.Parent = scroll
y = y + 35

-- ========== SECTION BOOST ==========
local boostTitle = Instance.new("TextLabel")
boostTitle.Size = UDim2.new(1, 0, 0, 28)
boostTitle.Position = UDim2.new(0, 0, 0, y)
boostTitle.Text = "--- 🏃 BOOST MENU 🏃 ---"
boostTitle.TextColor3 = Color3.fromRGB(155, 0, 255)
boostTitle.BackgroundTransparency = 1
boostTitle.Font = Enum.Font.GothamBold
boostTitle.TextSize = 12
boostTitle.Parent = scroll
y = y + 30

local speedBtn = CreateSimpleButton(scroll, "SPEED BOOST (999)", y)
y = y + 42
local jumpBtn = CreateSimpleButton(scroll, "JUMP BOOST (999)", y)
y = y + 42

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 32)
statusLabel.Position = UDim2.new(0, 0, 0, y)
statusLabel.Text = "✅ VORTEX READY"
statusLabel.TextColor3 = Color3.fromRGB(0,255,0)
statusLabel.BackgroundColor3 = Color3.fromRGB(25,25,35)
statusLabel.BackgroundTransparency = 0
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 11
statusLabel.Parent = scroll
local stCorner = Instance.new("UICorner")
stCorner.CornerRadius = UDim.new(0, 6)
stCorner.Parent = statusLabel
y = y + 40

scroll.CanvasSize = UDim2.new(0, 0, 0, y + 10)

-- ========== FUNGSI UI ==========
function CreateSimpleButton(parent, text, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,55)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    return btn
end

function CreateMinusButton(parent, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 30)
    btn.Position = UDim2.new(0.7, 0, 0, yPos)
    btn.Text = "-"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundColor3 = Color3.fromRGB(55,55,75)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    return btn
end

function CreatePlusButton(parent, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 30)
    btn.Position = UDim2.new(0.85, 0, 0, yPos)
    btn.Text = "+"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundColor3 = Color3.fromRGB(55,55,75)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    return btn
end

-- ========== UPDATE FUNGSI ==========
local function UpdateMaster()
    masterESP = not masterESP
    masterBtn.Text = masterESP and "MASTER ESP: ON ✅" or "MASTER ESP: OFF ❌"
    masterBtn.BackgroundColor3 = masterESP and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
end

local function UpdateBox()
    espBox = not espBox
    boxBtn.Text = espBox and "BOX ESP: ON ✅" or "BOX ESP: OFF ❌"
    boxBtn.BackgroundColor3 = espBox and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
end

local function UpdateTracer()
    espTracer = not espTracer
    tracerBtn.Text = espTracer and "TRACER ESP: ON ✅" or "TRACER ESP: OFF ❌"
    tracerBtn.BackgroundColor3 = espTracer and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
end

local function UpdateName()
    espName = not espName
    nameBtn.Text = espName and "NAME ESP: ON ✅" or "NAME ESP: OFF ❌"
    nameBtn.BackgroundColor3 = espName and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
end

local function UpdateAuto()
    autoHit = not autoHit
    autoBtn.Text = autoHit and "AUTO HIT: ON ✅" or "AUTO HIT: OFF ❌"
    autoBtn.BackgroundColor3 = autoHit and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
    autoStatus.Text = autoHit and "STATUS: HIDUP - SERANG SEMUA TARGET" or "STATUS: MATI"
    autoStatus.TextColor3 = autoHit and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,100,100)
    attackBtn.BackgroundColor3 = autoHit and Color3.fromRGB(0,120,0) or Color3.fromRGB(200,0,0)
end

local function UpdateSpeed()
    speedBoost = not speedBoost
    speedBtn.Text = speedBoost and "SPEED BOOST: ON ✅ (999)" or "SPEED BOOST: OFF ❌"
    speedBtn.BackgroundColor3 = speedBoost and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
    ApplySpeed()
    if speedBoost then
        statusLabel.Text = "🏃 SPEED 999 ACTIVE!"
        task.wait(0.5)
        statusLabel.Text = "✅ VORTEX READY"
    end
end

local function UpdateJump()
    jumpBoost = not jumpBoost
    jumpBtn.Text = jumpBoost and "JUMP BOOST: ON ✅ (999)" or "JUMP BOOST: OFF ❌"
    jumpBtn.BackgroundColor3 = jumpBoost and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
    ApplyJump()
    if jumpBoost then
        statusLabel.Text = "🦘 JUMP 999 ACTIVE!"
        task.wait(0.5)
        statusLabel.Text = "✅ VORTEX READY"
    end
end

-- ========== CONNECT TOMBOL ==========
masterBtn.MouseButton1Click:Connect(UpdateMaster)
boxBtn.MouseButton1Click:Connect(UpdateBox)
tracerBtn.MouseButton1Click:Connect(UpdateTracer)
nameBtn.MouseButton1Click:Connect(UpdateName)
attackBtn.MouseButton1Click:Connect(ManualAttack)
autoBtn.MouseButton1Click:Connect(UpdateAuto)
speedBtn.MouseButton1Click:Connect(UpdateSpeed)
jumpBtn.MouseButton1Click:Connect(UpdateJump)

-- Slider ESP
thickMinus.MouseButton1Click:Connect(function()
    espThick = math.max(1, espThick - 1)
    thickLabel.Text = "KETEBALAN: " .. espThick
    RefreshESP()
end)
thickPlus.MouseButton1Click:Connect(function()
    espThick = math.min(5, espThick + 1)
    thickLabel.Text = "KETEBALAN: " .. espThick
    RefreshESP()
end)

-- ========== DRAG MENU ==========
local dragActive = false
local dragStartPos = nil
local startFramePos = nil

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragActive = true
        dragStartPos = input.Position
        startFramePos = mainFrame.Position
    end
end)

header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragActive = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragActive then return end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartPos
        mainFrame.Position = UDim2.new(
            startFramePos.X.Scale, startFramePos.X.Offset + delta.X,
            startFramePos.Y.Scale, startFramePos.Y.Offset + delta.Y
        )
    end
end)

-- ========== MINIMIZE ==========
local minActive = false
minBtn.MouseButton1Click:Connect(function()
    if minActive then
        mainFrame.Size = UDim2.new(0, 280, 0, 480)
        scroll.Visible = true
        minBtn.Text = "-"
        minActive = false
    else
        mainFrame.Size = UDim2.new(0, 120, 0, 40)
        scroll.Visible = false
        minBtn.Text = "+"
        minActive = true
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

-- ========== INIT ESP ==========
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then CreateESP(p) end end)
Players.PlayerRemoving:Connect(RemoveESP)

-- ========== CHARACTER SPAWN ==========
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

-- ========== AUTO HIT LOOP (100 HIT PER DETIK) ==========
coroutine.wrap(function()
    while true do
        if autoHit then
            DoAutoHit()
        end
        task.wait(hitDelay) -- 0.01 detik = 100 hit per detik
    end
end)()

-- ========== ESP LOOP ==========
RunService.RenderStepped:Connect(UpdateESP)

print("========================================")
print("⚔️ VORTEX ULTIMATE - LOADED! ⚔️")
print("")
print("🔥 FITUR MAXED OUT:")
print("- RADIUS: 100 METER")
print("- DAMAGE: 999")
print("- 100 HIT PER DETIK")
print("- SPEED BOOST: 999")
print("- JUMP BOOST: 999")
print("")
print("📌 CARA PAKAI:")
print("- TEKAN AUTO HIT buat nyalakan/matikan")
print("- SERANG SEMUA! buat manual attack")
print("- GESER HEADER buat mindahin menu")
print("- TEKAN - buat minimize, X buat close")
print("========================================")
