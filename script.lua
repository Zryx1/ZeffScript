-- ========================================
-- VORTEX BASIC - PASTI MUNCUL DI DELTA
-- TANPA SCROLL, TANPA RIBET
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
        statusText.Text = "DAMAGE 999 KE " .. #targets .. " TARGET!"
        statusText.TextColor3 = Color3.fromRGB(0,255,0)
        wait(0.5)
        statusText.Text = "READY"
        statusText.TextColor3 = Color3.fromRGB(0,255,0)
    else
        statusText.Text = "TIDAK ADA TARGET!"
        statusText.TextColor3 = Color3.fromRGB(255,0,0)
        wait(0.5)
        statusText.Text = "READY"
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

-- ========== BUAT GUI (MANUAL SEMUA, TANPA SCROLL) ==========
local gui = Instance.new("ScreenGui")
gui.Name = "VortexBasic"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- FRAME (LEBIH PANJANG BIAR SEMUA TOMBOL KELIHATAN)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 550)
frame.Position = UDim2.new(0.5, -130, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 0
frame.Parent = gui

local fCorner = Instance.new("UICorner")
fCorner.CornerRadius = UDim.new(0, 12)
fCorner.Parent = frame

-- HEADER DRAG
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
header.BackgroundTransparency = 0
header.BorderSizePixel = 0
header.Parent = frame

local hCorner = Instance.new("UICorner")
hCorner.CornerRadius = UDim.new(0, 12)
hCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.6, 0, 1, 0)
title.Position = UDim2.new(0.05, 0, 0, 0)
title.Text = "VORTEX ULTIMATE"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 14
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

-- ISI (LANGSUNG SEMUA, TANPA SCROLL)
local y = 55

-- TITLE ESP
local espTitle = Instance.new("TextLabel")
espTitle.Size = UDim2.new(1, -16, 0, 25)
espTitle.Position = UDim2.new(0, 8, 0, y)
espTitle.Text = "--- ESP MENU ---"
espTitle.TextColor3 = Color3.fromRGB(155, 0, 255)
espTitle.BackgroundTransparency = 1
espTitle.Font = Enum.Font.GothamBold
espTitle.TextSize = 12
espTitle.Parent = frame
y = y + 28

-- MASTER ESP
local masterBtn = Instance.new("TextButton")
masterBtn.Size = UDim2.new(1, -16, 0, 38)
masterBtn.Position = UDim2.new(0, 8, 0, y)
masterBtn.Text = "MASTER ESP: OFF"
masterBtn.TextColor3 = Color3.fromRGB(255,255,255)
masterBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
masterBtn.Font = Enum.Font.GothamBold
masterBtn.TextSize = 13
masterBtn.Parent = frame
local mCorner = Instance.new("UICorner")
mCorner.CornerRadius = UDim.new(0, 6)
mCorner.Parent = masterBtn
y = y + 42

-- BOX ESP
local boxBtn = Instance.new("TextButton")
boxBtn.Size = UDim2.new(1, -16, 0, 38)
boxBtn.Position = UDim2.new(0, 8, 0, y)
boxBtn.Text = "BOX ESP: OFF"
boxBtn.TextColor3 = Color3.fromRGB(255,255,255)
boxBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
boxBtn.Font = Enum.Font.GothamBold
boxBtn.TextSize = 13
boxBtn.Parent = frame
local bCorner = Instance.new("UICorner")
bCorner.CornerRadius = UDim.new(0, 6)
bCorner.Parent = boxBtn
y = y + 42

-- TRACER ESP
local tracerBtn = Instance.new("TextButton")
tracerBtn.Size = UDim2.new(1, -16, 0, 38)
tracerBtn.Position = UDim2.new(0, 8, 0, y)
tracerBtn.Text = "TRACER ESP: OFF"
tracerBtn.TextColor3 = Color3.fromRGB(255,255,255)
tracerBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
tracerBtn.Font = Enum.Font.GothamBold
tracerBtn.TextSize = 13
tracerBtn.Parent = frame
local tCorner = Instance.new("UICorner")
tCorner.CornerRadius = UDim.new(0, 6)
tCorner.Parent = tracerBtn
y = y + 42

-- NAME ESP
local nameBtn = Instance.new("TextButton")
nameBtn.Size = UDim2.new(1, -16, 0, 38)
nameBtn.Position = UDim2.new(0, 8, 0, y)
nameBtn.Text = "NAME ESP: OFF"
nameBtn.TextColor3 = Color3.fromRGB(255,255,255)
nameBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
nameBtn.Font = Enum.Font.GothamBold
nameBtn.TextSize = 13
nameBtn.Parent = frame
local nCorner = Instance.new("UICorner")
nCorner.CornerRadius = UDim.new(0, 6)
nCorner.Parent = nameBtn
y = y + 42

-- KETEBALAN
local thickFrame = Instance.new("Frame")
thickFrame.Size = UDim2.new(1, -16, 0, 35)
thickFrame.Position = UDim2.new(0, 8, 0, y)
thickFrame.BackgroundColor3 = Color3.fromRGB(30,30,42)
thickFrame.BackgroundTransparency = 0
thickFrame.BorderSizePixel = 0
thickFrame.Parent = frame
local tkCorner = Instance.new("UICorner")
tkCorner.CornerRadius = UDim.new(0, 6)
tkCorner.Parent = thickFrame

local thickLabel = Instance.new("TextLabel")
thickLabel.Size = UDim2.new(0.5, 0, 1, 0)
thickLabel.Position = UDim2.new(0, 8, 0, 0)
thickLabel.Text = "KETEBALAN: 2"
thickLabel.TextColor3 = Color3.fromRGB(200,200,220)
thickLabel.BackgroundTransparency = 1
thickLabel.Font = Enum.Font.GothamBold
thickLabel.TextSize = 12
thickLabel.TextXAlignment = Enum.TextXAlignment.Left
thickLabel.Parent = thickFrame

local thickMinus = Instance.new("TextButton")
thickMinus.Size = UDim2.new(0, 35, 0, 28)
thickMinus.Position = UDim2.new(1, -78, 0.5, -14)
thickMinus.Text = "-"
thickMinus.TextColor3 = Color3.fromRGB(255,255,255)
thickMinus.BackgroundColor3 = Color3.fromRGB(55,55,75)
thickMinus.Font = Enum.Font.GothamBold
thickMinus.TextSize = 18
thickMinus.Parent = thickFrame
local tmCorner = Instance.new("UICorner")
tmCorner.CornerRadius = UDim.new(0, 5)
tmCorner.Parent = thickMinus

local thickPlus = Instance.new("TextButton")
thickPlus.Size = UDim2.new(0, 35, 0, 28)
thickPlus.Position = UDim2.new(1, -38, 0.5, -14)
thickPlus.Text = "+"
thickPlus.TextColor3 = Color3.fromRGB(255,255,255)
thickPlus.BackgroundColor3 = Color3.fromRGB(55,55,75)
thickPlus.Font = Enum.Font.GothamBold
thickPlus.TextSize = 18
thickPlus.Parent = thickFrame
local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(0, 5)
tpCorner.Parent = thickPlus
y = y + 42

-- TITLE HIT
local hitTitle = Instance.new("TextLabel")
hitTitle.Size = UDim2.new(1, -16, 0, 25)
hitTitle.Position = UDim2.new(0, 8, 0, y)
hitTitle.Text = "--- MULTI HIT ---"
hitTitle.TextColor3 = Color3.fromRGB(155, 0, 255)
hitTitle.BackgroundTransparency = 1
hitTitle.Font = Enum.Font.GothamBold
hitTitle.TextSize = 12
hitTitle.Parent = frame
y = y + 28

-- ATTACK BUTTON
local attackBtn = Instance.new("TextButton")
attackBtn.Size = UDim2.new(1, -16, 0, 48)
attackBtn.Position = UDim2.new(0, 8, 0, y)
attackBtn.Text = "SERANG SEMUA!"
attackBtn.TextColor3 = Color3.fromRGB(255,255,255)
attackBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
attackBtn.Font = Enum.Font.GothamBold
attackBtn.TextSize = 16
attackBtn.Parent = frame
local aCorner = Instance.new("UICorner")
aCorner.CornerRadius = UDim.new(0, 8)
aCorner.Parent = attackBtn
y = y + 54

-- AUTO HIT BUTTON
local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(1, -16, 0, 38)
autoBtn.Position = UDim2.new(0, 8, 0, y)
autoBtn.Text = "AUTO HIT: OFF"
autoBtn.TextColor3 = Color3.fromRGB(255,255,255)
autoBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
autoBtn.Font = Enum.Font.GothamBold
autoBtn.TextSize = 13
autoBtn.Parent = frame
local auCorner = Instance.new("UICorner")
auCorner.CornerRadius = UDim.new(0, 6)
auCorner.Parent = autoBtn
y = y + 45

-- STATUS AUTO
local autoStatus = Instance.new("TextLabel")
autoStatus.Size = UDim2.new(1, -16, 0, 28)
autoStatus.Position = UDim2.new(0, 8, 0, y)
autoStatus.Text = "STATUS: MATI"
autoStatus.TextColor3 = Color3.fromRGB(255,100,100)
autoStatus.BackgroundColor3 = Color3.fromRGB(30,30,42)
autoStatus.BackgroundTransparency = 0
autoStatus.Font = Enum.Font.GothamBold
autoStatus.TextSize = 11
autoStatus.Parent = frame
local asCorner = Instance.new("UICorner")
asCorner.CornerRadius = UDim.new(0, 6)
asCorner.Parent = autoStatus
y = y + 35

-- INFO RADIUS
local radText = Instance.new("TextLabel")
radText.Size = UDim2.new(1, -16, 0, 22)
radText.Position = UDim2.new(0, 8, 0, y)
radText.Text = "RADIUS: 100 METER (MAX)"
radText.TextColor3 = Color3.fromRGB(0,255,0)
radText.BackgroundTransparency = 1
radText.Font = Enum.Font.GothamBold
radText.TextSize = 11
radText.Parent = frame
y = y + 25

-- INFO DAMAGE
local dmgText = Instance.new("TextLabel")
dmgText.Size = UDim2.new(1, -16, 0, 22)
dmgText.Position = UDim2.new(0, 8, 0, y)
dmgText.Text = "DAMAGE: 999 (MAX)"
dmgText.TextColor3 = Color3.fromRGB(0,255,0)
dmgText.BackgroundTransparency = 1
dmgText.Font = Enum.Font.GothamBold
dmgText.TextSize = 11
dmgText.Parent = frame
y = y + 25

-- INFO HIT SPEED
local hitSpdText = Instance.new("TextLabel")
hitSpdText.Size = UDim2.new(1, -16, 0, 22)
hitSpdText.Position = UDim2.new(0, 8, 0, y)
hitSpdText.Text = "100 HIT PER DETIK (MAX)"
hitSpdText.TextColor3 = Color3.fromRGB(0,255,0)
hitSpdText.BackgroundTransparency = 1
hitSpdText.Font = Enum.Font.GothamBold
hitSpdText.TextSize = 11
hitSpdText.Parent = frame
y = y + 30

-- TITLE BOOST
local boostTitle = Instance.new("TextLabel")
boostTitle.Size = UDim2.new(1, -16, 0, 25)
boostTitle.Position = UDim2.new(0, 8, 0, y)
boostTitle.Text = "--- BOOST MENU ---"
boostTitle.TextColor3 = Color3.fromRGB(155, 0, 255)
boostTitle.BackgroundTransparency = 1
boostTitle.Font = Enum.Font.GothamBold
boostTitle.TextSize = 12
boostTitle.Parent = frame
y = y + 28

-- SPEED BUTTON
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(1, -16, 0, 38)
speedBtn.Position = UDim2.new(0, 8, 0, y)
speedBtn.Text = "SPEED BOOST (999): OFF"
speedBtn.TextColor3 = Color3.fromRGB(255,255,255)
speedBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
speedBtn.Font = Enum.Font.GothamBold
speedBtn.TextSize = 12
speedBtn.Parent = frame
local spCorner = Instance.new("UICorner")
spCorner.CornerRadius = UDim.new(0, 6)
spCorner.Parent = speedBtn
y = y + 42

-- JUMP BUTTON
local jumpBtn = Instance.new("TextButton")
jumpBtn.Size = UDim2.new(1, -16, 0, 38)
jumpBtn.Position = UDim2.new(0, 8, 0, y)
jumpBtn.Text = "JUMP BOOST (999): OFF"
jumpBtn.TextColor3 = Color3.fromRGB(255,255,255)
jumpBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
jumpBtn.Font = Enum.Font.GothamBold
jumpBtn.TextSize = 12
jumpBtn.Parent = frame
local jpCorner = Instance.new("UICorner")
jpCorner.CornerRadius = UDim.new(0, 6)
jpCorner.Parent = jumpBtn
y = y + 42

-- STATUS TEXT
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -16, 0, 32)
statusText.Position = UDim2.new(0, 8, 0, y)
statusText.Text = "READY"
statusText.TextColor3 = Color3.fromRGB(0,255,0)
statusText.BackgroundColor3 = Color3.fromRGB(25,25,35)
statusText.BackgroundTransparency = 0
statusText.Font = Enum.Font.GothamBold
statusText.TextSize = 12
statusText.Parent = frame
local stCorner = Instance.new("UICorner")
stCorner.CornerRadius = UDim.new(0, 6)
stCorner.Parent = statusText
y = y + 42

-- ========== UPDATE FUNGSI ==========
local function UpdateMaster()
    masterESP = not masterESP
    masterBtn.Text = masterESP and "MASTER ESP: ON" or "MASTER ESP: OFF"
    masterBtn.BackgroundColor3 = masterESP and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
end

local function UpdateBox()
    espBox = not espBox
    boxBtn.Text = espBox and "BOX ESP: ON" or "BOX ESP: OFF"
    boxBtn.BackgroundColor3 = espBox and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
end

local function UpdateTracer()
    espTracer = not espTracer
    tracerBtn.Text = espTracer and "TRACER ESP: ON" or "TRACER ESP: OFF"
    tracerBtn.BackgroundColor3 = espTracer and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
end

local function UpdateName()
    espName = not espName
    nameBtn.Text = espName and "NAME ESP: ON" or "NAME ESP: OFF"
    nameBtn.BackgroundColor3 = espName and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
end

local function UpdateAuto()
    autoHit = not autoHit
    autoBtn.Text = autoHit and "AUTO HIT: ON" or "AUTO HIT: OFF"
    autoBtn.BackgroundColor3 = autoHit and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
    autoStatus.Text = autoHit and "STATUS: HIDUP - SERANG SEMUA" or "STATUS: MATI"
    autoStatus.TextColor3 = autoHit and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,100,100)
    attackBtn.BackgroundColor3 = autoHit and Color3.fromRGB(0,120,0) or Color3.fromRGB(200,0,0)
end

local function UpdateSpeed()
    speedBoost = not speedBoost
    speedBtn.Text = speedBoost and "SPEED BOOST (999): ON" or "SPEED BOOST (999): OFF"
    speedBtn.BackgroundColor3 = speedBoost and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
    ApplySpeed()
end

local function UpdateJump()
    jumpBoost = not jumpBoost
    jumpBtn.Text = jumpBoost and "JUMP BOOST (999): ON" or "JUMP BOOST (999): OFF"
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
    thickLabel.Text = "KETEBALAN: " .. espThick
    RefreshESP()
end)
thickPlus.MouseButton1Click:Connect(function()
    espThick = math.min(5, espThick + 1)
    thickLabel.Text = "KETEBALAN: " .. espThick
    RefreshESP()
end)

-- ========== DRAG ==========
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

-- ========== MINIMIZE ==========
local min = false
minBtn.MouseButton1Click:Connect(function()
    if min then
        frame.Size = UDim2.new(0, 260, 0, 550)
        for _, v in pairs(frame:GetChildren()) do
            if v:IsA("TextButton") or v:IsA("TextLabel") or (v:IsA("Frame") and v ~= header) then
                v.Visible = true
            end
        end
        minBtn.Text = "-"
        min = false
    else
        frame.Size = UDim2.new(0, 120, 0, 40)
        for _, v in pairs(frame:GetChildren()) do
            if v:IsA("TextButton") or v:IsA("TextLabel") or (v:IsA("Frame") and v ~= header) then
                v.Visible = false
            end
        end
        minBtn.Text = "+"
        min = true
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
    wait(0.5)
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
        wait(hitDelay)
    end
end)()

RunService.RenderStepped:Connect(UpdateESP)

print("========================================")
print("VORTEX ULTIMATE - LOADED!")
print("SEMUA TOMBOL LANGSUNG KELIHATAN")
print("GESER HEADER UNTUK MOVE")
print("========================================")
