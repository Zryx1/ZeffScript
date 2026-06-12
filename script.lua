-- ========================================
-- VORTEX EVIL - KILL ALL & BAN ALL
-- UKURAN KECIL, GESER KE BAWAH
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

local speedBoost = false
local speedValue = 200
local jumpBoost = false
local jumpValue = 200

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
    nameTag.Size = 10
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
                local size = math.clamp(150/dist, 25, 70)
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
                esp.nameTag.Position = Vector2.new(pos.X, pos.Y - 20)
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
        statusText.Text = "🔥"..#targets
        statusText.TextColor3 = Color3.fromRGB(0,255,0)
        task.wait(0.3)
        statusText.Text = "✓"
        statusText.TextColor3 = Color3.fromRGB(0,255,0)
    else
        statusText.Text = "✗"
        statusText.TextColor3 = Color3.fromRGB(255,0,0)
        task.wait(0.3)
        statusText.Text = "✓"
        statusText.TextColor3 = Color3.fromRGB(0,255,0)
    end
end

-- ========== FITUR JAHAT ==========
-- KILL ALL - Bunuh semua player
local function KillAll()
    local killed = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local char = p.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    hum.Health = 0
                    killed = killed + 1
                end
            end
        end
    end
    statusText.Text = "💀"..killed
    statusText.TextColor3 = Color3.fromRGB(255,0,0)
    task.wait(0.5)
    statusText.Text = "✓"
    statusText.TextColor3 = Color3.fromRGB(0,255,0)
end

-- BAN ALL - Kick semua player (effect kayak ban)
local function BanAll()
    local kicked = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            p:Kick("🚫 ANDA DI BAN OLEH VORTEX 🚫\n\nJangan coba-coba balik lagi!")
            kicked = kicked + 1
        end
    end
    statusText.Text = "🚫"..kicked
    statusText.TextColor3 = Color3.fromRGB(255,255,0)
    task.wait(0.5)
    statusText.Text = "✓"
    statusText.TextColor3 = Color3.fromRGB(0,255,0)
end

-- ========== SPEED JUMP ==========
local function ApplySpeed()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = speedBoost and speedValue or origSpeed
    end
end

local function ApplyJump()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = jumpBoost and jumpValue or origJump
    end
end

-- ========== BUAT GUI ==========
local gui = Instance.new("ScreenGui")
gui.Name = "VortexEvil"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- FRAME UKURAN 160x360 (ditambah dikit buat tombol baru)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 380)
frame.Position = UDim2.new(0.5, -80, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 0
frame.Parent = gui

local fCorner = Instance.new("UICorner")
fCorner.CornerRadius = UDim.new(0, 8)
fCorner.Parent = frame

-- HEADER DRAG
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 28)
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
title.Text = "V"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 20, 0, 20)
minBtn.Position = UDim2.new(1, -45, 0.5, -10)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255,255,255)
minBtn.BackgroundTransparency = 1
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 12
minBtn.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(1, -22, 0.5, -10)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 10
closeBtn.Parent = header

-- SCROLLING FRAME
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -6, 1, -36)
scroll.Position = UDim2.new(0, 3, 0, 32)
scroll.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
scroll.BackgroundTransparency = 0
scroll.BorderSizePixel = 0
scroll.CanvasSize = UDim2.new(0, 0, 0, 680)
scroll.ScrollBarThickness = 2
scroll.ScrollBarImageColor3 = Color3.fromRGB(155, 0, 255)
scroll.Parent = frame

-- ========== ISI ==========
local y = 3

-- ===== ESP SECTION =====
local espTitle = Instance.new("TextLabel")
espTitle.Size = UDim2.new(1, -6, 0, 14)
espTitle.Position = UDim2.new(0, 3, 0, y)
espTitle.Text = "ESP"
espTitle.TextColor3 = Color3.fromRGB(155, 0, 255)
espTitle.BackgroundTransparency = 1
espTitle.Font = Enum.Font.GothamBold
espTitle.TextSize = 9
espTitle.Parent = scroll
y = y + 16

local masterBtn = Instance.new("TextButton")
masterBtn.Size = UDim2.new(1, -6, 0, 22)
masterBtn.Position = UDim2.new(0, 3, 0, y)
masterBtn.Text = "M:OFF"
masterBtn.TextColor3 = Color3.fromRGB(255,255,255)
masterBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
masterBtn.Font = Enum.Font.GothamBold
masterBtn.TextSize = 9
masterBtn.Parent = scroll
local mCorner = Instance.new("UICorner")
mCorner.CornerRadius = UDim.new(0, 4)
mCorner.Parent = masterBtn
y = y + 25

local boxBtn = Instance.new("TextButton")
boxBtn.Size = UDim2.new(1, -6, 0, 22)
boxBtn.Position = UDim2.new(0, 3, 0, y)
boxBtn.Text = "B:OFF"
boxBtn.TextColor3 = Color3.fromRGB(255,255,255)
boxBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
boxBtn.Font = Enum.Font.GothamBold
boxBtn.TextSize = 9
boxBtn.Parent = scroll
local bCorner = Instance.new("UICorner")
bCorner.CornerRadius = UDim.new(0, 4)
bCorner.Parent = boxBtn
y = y + 25

local tracerBtn = Instance.new("TextButton")
tracerBtn.Size = UDim2.new(1, -6, 0, 22)
tracerBtn.Position = UDim2.new(0, 3, 0, y)
tracerBtn.Text = "T:OFF"
tracerBtn.TextColor3 = Color3.fromRGB(255,255,255)
tracerBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
tracerBtn.Font = Enum.Font.GothamBold
tracerBtn.TextSize = 9
tracerBtn.Parent = scroll
local tCorner = Instance.new("UICorner")
tCorner.CornerRadius = UDim.new(0, 4)
tCorner.Parent = tracerBtn
y = y + 25

local nameBtn = Instance.new("TextButton")
nameBtn.Size = UDim2.new(1, -6, 0, 22)
nameBtn.Position = UDim2.new(0, 3, 0, y)
nameBtn.Text = "N:OFF"
nameBtn.TextColor3 = Color3.fromRGB(255,255,255)
nameBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
nameBtn.Font = Enum.Font.GothamBold
nameBtn.TextSize = 9
nameBtn.Parent = scroll
local nCorner = Instance.new("UICorner")
nCorner.CornerRadius = UDim.new(0, 4)
nCorner.Parent = nameBtn
y = y + 25

-- Ketebalan
local thickFrame = Instance.new("Frame")
thickFrame.Size = UDim2.new(1, -6, 0, 24)
thickFrame.Position = UDim2.new(0, 3, 0, y)
thickFrame.BackgroundColor3 = Color3.fromRGB(30,30,42)
thickFrame.BackgroundTransparency = 0
thickFrame.BorderSizePixel = 0
thickFrame.Parent = scroll
local tkCorner = Instance.new("UICorner")
tkCorner.CornerRadius = UDim.new(0, 4)
tkCorner.Parent = thickFrame

local thickLabel = Instance.new("TextLabel")
thickLabel.Size = UDim2.new(0.4, 0, 1, 0)
thickLabel.Position = UDim2.new(0, 4, 0, 0)
thickLabel.Text = "T:2"
thickLabel.TextColor3 = Color3.fromRGB(200,200,220)
thickLabel.BackgroundTransparency = 1
thickLabel.Font = Enum.Font.GothamBold
thickLabel.TextSize = 9
thickLabel.TextXAlignment = Enum.TextXAlignment.Left
thickLabel.Parent = thickFrame

local thickMinus = Instance.new("TextButton")
thickMinus.Size = UDim2.new(0, 20, 0, 18)
thickMinus.Position = UDim2.new(1, -45, 0.5, -9)
thickMinus.Text = "-"
thickMinus.TextColor3 = Color3.fromRGB(255,255,255)
thickMinus.BackgroundColor3 = Color3.fromRGB(55,55,75)
thickMinus.Font = Enum.Font.GothamBold
thickMinus.TextSize = 12
thickMinus.Parent = thickFrame
local tmCorner = Instance.new("UICorner")
tmCorner.CornerRadius = UDim.new(0, 4)
tmCorner.Parent = thickMinus

local thickPlus = Instance.new("TextButton")
thickPlus.Size = UDim2.new(0, 20, 0, 18)
thickPlus.Position = UDim2.new(1, -22, 0.5, -9)
thickPlus.Text = "+"
thickPlus.TextColor3 = Color3.fromRGB(255,255,255)
thickPlus.BackgroundColor3 = Color3.fromRGB(55,55,75)
thickPlus.Font = Enum.Font.GothamBold
thickPlus.TextSize = 12
thickPlus.Parent = thickFrame
local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(0, 4)
tpCorner.Parent = thickPlus
y = y + 28

-- ===== MULTI HIT SECTION =====
local hitTitle = Instance.new("TextLabel")
hitTitle.Size = UDim2.new(1, -6, 0, 14)
hitTitle.Position = UDim2.new(0, 3, 0, y)
hitTitle.Text = "HIT"
hitTitle.TextColor3 = Color3.fromRGB(155, 0, 255)
hitTitle.BackgroundTransparency = 1
hitTitle.Font = Enum.Font.GothamBold
hitTitle.TextSize = 9
hitTitle.Parent = scroll
y = y + 16

local attackBtn = Instance.new("TextButton")
attackBtn.Size = UDim2.new(1, -6, 0, 32)
attackBtn.Position = UDim2.new(0, 3, 0, y)
attackBtn.Text = "⚔️"
attackBtn.TextColor3 = Color3.fromRGB(255,255,255)
attackBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
attackBtn.Font = Enum.Font.GothamBold
attackBtn.TextSize = 14
attackBtn.Parent = scroll
local aCorner = Instance.new("UICorner")
aCorner.CornerRadius = UDim.new(0, 6)
aCorner.Parent = attackBtn
y = y + 36

local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(1, -6, 0, 22)
autoBtn.Position = UDim2.new(0, 3, 0, y)
autoBtn.Text = "AUTO:OFF"
autoBtn.TextColor3 = Color3.fromRGB(255,255,255)
autoBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
autoBtn.Font = Enum.Font.GothamBold
autoBtn.TextSize = 9
autoBtn.Parent = scroll
local auCorner = Instance.new("UICorner")
auCorner.CornerRadius = UDim.new(0, 4)
auCorner.Parent = autoBtn
y = y + 25

local autoStatus = Instance.new("TextLabel")
autoStatus.Size = UDim2.new(1, -6, 0, 14)
autoStatus.Position = UDim2.new(0, 3, 0, y)
autoStatus.Text = "●"
autoStatus.TextColor3 = Color3.fromRGB(255,100,100)
autoStatus.BackgroundTransparency = 1
autoStatus.Font = Enum.Font.GothamBold
autoStatus.TextSize = 10
autoStatus.Parent = scroll
y = y + 16

-- Radius Slider
local radiusFrame = Instance.new("Frame")
radiusFrame.Size = UDim2.new(1, -6, 0, 24)
radiusFrame.Position = UDim2.new(0, 3, 0, y)
radiusFrame.BackgroundColor3 = Color3.fromRGB(30,30,42)
radiusFrame.BackgroundTransparency = 0
radiusFrame.BorderSizePixel = 0
radiusFrame.Parent = scroll
local rrCorner = Instance.new("UICorner")
rrCorner.CornerRadius = UDim.new(0, 4)
rrCorner.Parent = radiusFrame

local radiusLabel = Instance.new("TextLabel")
radiusLabel.Size = UDim2.new(0.4, 0, 1, 0)
radiusLabel.Position = UDim2.new(0, 4, 0, 0)
radiusLabel.Text = "R:"..hitRange
radiusLabel.TextColor3 = Color3.fromRGB(200,200,220)
radiusLabel.BackgroundTransparency = 1
radiusLabel.Font = Enum.Font.GothamBold
radiusLabel.TextSize = 9
radiusLabel.TextXAlignment = Enum.TextXAlignment.Left
radiusLabel.Parent = radiusFrame

local radiusMinus = Instance.new("TextButton")
radiusMinus.Size = UDim2.new(0, 20, 0, 18)
radiusMinus.Position = UDim2.new(1, -45, 0.5, -9)
radiusMinus.Text = "-"
radiusMinus.TextColor3 = Color3.fromRGB(255,255,255)
radiusMinus.BackgroundColor3 = Color3.fromRGB(55,55,75)
radiusMinus.Font = Enum.Font.GothamBold
radiusMinus.TextSize = 12
radiusMinus.Parent = radiusFrame
local rmCorner = Instance.new("UICorner")
rmCorner.CornerRadius = UDim.new(0, 4)
rmCorner.Parent = radiusMinus

local radiusPlus = Instance.new("TextButton")
radiusPlus.Size = UDim2.new(0, 20, 0, 18)
radiusPlus.Position = UDim2.new(1, -22, 0.5, -9)
radiusPlus.Text = "+"
radiusPlus.TextColor3 = Color3.fromRGB(255,255,255)
radiusPlus.BackgroundColor3 = Color3.fromRGB(55,55,75)
radiusPlus.Font = Enum.Font.GothamBold
radiusPlus.TextSize = 12
radiusPlus.Parent = radiusFrame
local rpCorner = Instance.new("UICorner")
rpCorner.CornerRadius = UDim.new(0, 4)
rpCorner.Parent = radiusPlus
y = y + 28

-- Damage Slider
local damageFrame = Instance.new("Frame")
damageFrame.Size = UDim2.new(1, -6, 0, 24)
damageFrame.Position = UDim2.new(0, 3, 0, y)
damageFrame.BackgroundColor3 = Color3.fromRGB(30,30,42)
damageFrame.BackgroundTransparency = 0
damageFrame.BorderSizePixel = 0
damageFrame.Parent = scroll
local dgCorner = Instance.new("UICorner")
dgCorner.CornerRadius = UDim.new(0, 4)
dgCorner.Parent = damageFrame

local damageLabel = Instance.new("TextLabel")
damageLabel.Size = UDim2.new(0.4, 0, 1, 0)
damageLabel.Position = UDim2.new(0, 4, 0, 0)
damageLabel.Text = "D:"..hitDamage
damageLabel.TextColor3 = Color3.fromRGB(200,200,220)
damageLabel.BackgroundTransparency = 1
damageLabel.Font = Enum.Font.GothamBold
damageLabel.TextSize = 9
damageLabel.TextXAlignment = Enum.TextXAlignment.Left
damageLabel.Parent = damageFrame

local damageMinus = Instance.new("TextButton")
damageMinus.Size = UDim2.new(0, 20, 0, 18)
damageMinus.Position = UDim2.new(1, -45, 0.5, -9)
damageMinus.Text = "-"
damageMinus.TextColor3 = Color3.fromRGB(255,255,255)
damageMinus.BackgroundColor3 = Color3.fromRGB(55,55,75)
damageMinus.Font = Enum.Font.GothamBold
damageMinus.TextSize = 12
damageMinus.Parent = damageFrame
local dmCorner = Instance.new("UICorner")
dmCorner.CornerRadius = UDim.new(0, 4)
dmCorner.Parent = damageMinus

local damagePlus = Instance.new("TextButton")
damagePlus.Size = UDim2.new(0, 20, 0, 18)
damagePlus.Position = UDim2.new(1, -22, 0.5, -9)
damagePlus.Text = "+"
damagePlus.TextColor3 = Color3.fromRGB(255,255,255)
damagePlus.BackgroundColor3 = Color3.fromRGB(55,55,75)
damagePlus.Font = Enum.Font.GothamBold
damagePlus.TextSize = 12
damagePlus.Parent = damageFrame
local dpCorner = Instance.new("UICorner")
dpCorner.CornerRadius = UDim.new(0, 4)
dpCorner.Parent = damagePlus
y = y + 28

-- ===== FITUR JAHAT =====
local evilTitle = Instance.new("TextLabel")
evilTitle.Size = UDim2.new(1, -6, 0, 14)
evilTitle.Position = UDim2.new(0, 3, 0, y)
evilTitle.Text = "🔥 EVIL 🔥"
evilTitle.TextColor3 = Color3.fromRGB(255, 0, 0)
evilTitle.BackgroundTransparency = 1
evilTitle.Font = Enum.Font.GothamBold
evilTitle.TextSize = 9
evilTitle.Parent = scroll
y = y + 16

-- Kill All Button
local killBtn = Instance.new("TextButton")
killBtn.Size = UDim2.new(1, -6, 0, 32)
killBtn.Position = UDim2.new(0, 3, 0, y)
killBtn.Text = "⛔ KILL ALL ⛔"
killBtn.TextColor3 = Color3.fromRGB(255,255,255)
killBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
killBtn.Font = Enum.Font.GothamBold
killBtn.TextSize = 10
killBtn.Parent = scroll
local kCorner = Instance.new("UICorner")
kCorner.CornerRadius = UDim.new(0, 6)
kCorner.Parent = killBtn
y = y + 36

-- Ban All Button
local banBtn = Instance.new("TextButton")
banBtn.Size = UDim2.new(1, -6, 0, 32)
banBtn.Position = UDim2.new(0, 3, 0, y)
banBtn.Text = "🚫 BAN ALL 🚫"
banBtn.TextColor3 = Color3.fromRGB(255,255,255)
banBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 100)
banBtn.Font = Enum.Font.GothamBold
banBtn.TextSize = 10
banBtn.Parent = scroll
local bCorner2 = Instance.new("UICorner")
bCorner2.CornerRadius = UDim.new(0, 6)
bCorner2.Parent = banBtn
y = y + 36

-- ===== BOOST SECTION =====
local boostTitle = Instance.new("TextLabel")
boostTitle.Size = UDim2.new(1, -6, 0, 14)
boostTitle.Position = UDim2.new(0, 3, 0, y)
boostTitle.Text = "BST"
boostTitle.TextColor3 = Color3.fromRGB(155, 0, 255)
boostTitle.BackgroundTransparency = 1
boostTitle.Font = Enum.Font.GothamBold
boostTitle.TextSize = 9
boostTitle.Parent = scroll
y = y + 16

local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(1, -6, 0, 22)
speedBtn.Position = UDim2.new(0, 3, 0, y)
speedBtn.Text = "S:OFF"
speedBtn.TextColor3 = Color3.fromRGB(255,255,255)
speedBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
speedBtn.Font = Enum.Font.GothamBold
speedBtn.TextSize = 9
speedBtn.Parent = scroll
local spCorner = Instance.new("UICorner")
spCorner.CornerRadius = UDim.new(0, 4)
spCorner.Parent = speedBtn
y = y + 25

local speedSFrame = Instance.new("Frame")
speedSFrame.Size = UDim2.new(1, -6, 0, 24)
speedSFrame.Position = UDim2.new(0, 3, 0, y)
speedSFrame.BackgroundColor3 = Color3.fromRGB(30,30,42)
speedSFrame.BackgroundTransparency = 0
speedSFrame.BorderSizePixel = 0
speedSFrame.Parent = scroll
local ssCorner = Instance.new("UICorner")
ssCorner.CornerRadius = UDim.new(0, 4)
ssCorner.Parent = speedSFrame

local speedSLabel = Instance.new("TextLabel")
speedSLabel.Size = UDim2.new(0.4, 0, 1, 0)
speedSLabel.Position = UDim2.new(0, 4, 0, 0)
speedSLabel.Text = speedValue
speedSLabel.TextColor3 = Color3.fromRGB(200,200,220)
speedSLabel.BackgroundTransparency = 1
speedSLabel.Font = Enum.Font.GothamBold
speedSLabel.TextSize = 9
speedSLabel.TextXAlignment = Enum.TextXAlignment.Left
speedSLabel.Parent = speedSFrame

local speedSMinus = Instance.new("TextButton")
speedSMinus.Size = UDim2.new(0, 20, 0, 18)
speedSMinus.Position = UDim2.new(1, -45, 0.5, -9)
speedSMinus.Text = "-"
speedSMinus.TextColor3 = Color3.fromRGB(255,255,255)
speedSMinus.BackgroundColor3 = Color3.fromRGB(55,55,75)
speedSMinus.Font = Enum.Font.GothamBold
speedSMinus.TextSize = 12
speedSMinus.Parent = speedSFrame
local smCorner = Instance.new("UICorner")
smCorner.CornerRadius = UDim.new(0, 4)
smCorner.Parent = speedSMinus

local speedSPlus = Instance.new("TextButton")
speedSPlus.Size = UDim2.new(0, 20, 0, 18)
speedSPlus.Position = UDim2.new(1, -22, 0.5, -9)
speedSPlus.Text = "+"
speedSPlus.TextColor3 = Color3.fromRGB(255,255,255)
speedSPlus.BackgroundColor3 = Color3.fromRGB(55,55,75)
speedSPlus.Font = Enum.Font.GothamBold
speedSPlus.TextSize = 12
speedSPlus.Parent = speedSFrame
local spCorner2 = Instance.new("UICorner")
spCorner2.CornerRadius = UDim.new(0, 4)
spCorner2.Parent = speedSPlus
y = y + 28

local jumpBtn = Instance.new("TextButton")
jumpBtn.Size = UDim2.new(1, -6, 0, 22)
jumpBtn.Position = UDim2.new(0, 3, 0, y)
jumpBtn.Text = "J:OFF"
jumpBtn.TextColor3 = Color3.fromRGB(255,255,255)
jumpBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
jumpBtn.Font = Enum.Font.GothamBold
jumpBtn.TextSize = 9
jumpBtn.Parent = scroll
local jpCorner = Instance.new("UICorner")
jpCorner.CornerRadius = UDim.new(0, 4)
jpCorner.Parent = jumpBtn
y = y + 25

local jumpSFrame = Instance.new("Frame")
jumpSFrame.Size = UDim2.new(1, -6, 0, 24)
jumpSFrame.Position = UDim2.new(0, 3, 0, y)
jumpSFrame.BackgroundColor3 = Color3.fromRGB(30,30,42)
jumpSFrame.BackgroundTransparency = 0
jumpSFrame.BorderSizePixel = 0
jumpSFrame.Parent = scroll
local jsCorner = Instance.new("UICorner")
jsCorner.CornerRadius = UDim.new(0, 4)
jsCorner.Parent = jumpSFrame

local jumpSLabel = Instance.new("TextLabel")
jumpSLabel.Size = UDim2.new(0.4, 0, 1, 0)
jumpSLabel.Position = UDim2.new(0, 4, 0, 0)
jumpSLabel.Text = jumpValue
jumpSLabel.TextColor3 = Color3.fromRGB(200,200,220)
jumpSLabel.BackgroundTransparency = 1
jumpSLabel.Font = Enum.Font.GothamBold
jumpSLabel.TextSize = 9
jumpSLabel.TextXAlignment = Enum.TextXAlignment.Left
jumpSLabel.Parent = jumpSFrame

local jumpSMinus = Instance.new("TextButton")
jumpSMinus.Size = UDim2.new(0, 20, 0, 18)
jumpSMinus.Position = UDim2.new(1, -45, 0.5, -9)
jumpSMinus.Text = "-"
jumpSMinus.TextColor3 = Color3.fromRGB(255,255,255)
jumpSMinus.BackgroundColor3 = Color3.fromRGB(55,55,75)
jumpSMinus.Font = Enum.Font.GothamBold
jumpSMinus.TextSize = 12
jumpSMinus.Parent = jumpSFrame
local jmCorner = Instance.new("UICorner")
jmCorner.CornerRadius = UDim.new(0, 4)
jmCorner.Parent = jumpSMinus

local jumpSPlus = Instance.new("TextButton")
jumpSPlus.Size = UDim2.new(0, 20, 0, 18)
jumpSPlus.Position = UDim2.new(1, -22, 0.5, -9)
jumpSPlus.Text = "+"
jumpSPlus.TextColor3 = Color3.fromRGB(255,255,255)
jumpSPlus.BackgroundColor3 = Color3.fromRGB(55,55,75)
jumpSPlus.Font = Enum.Font.GothamBold
jumpSPlus.TextSize = 12
jumpSPlus.Parent = jumpSFrame
local jpCorner2 = Instance.new("UICorner")
jpCorner2.CornerRadius = UDim.new(0, 4)
jpCorner2.Parent = jumpSPlus
y = y + 28

-- Status Text
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -6, 0, 18)
statusText.Position = UDim2.new(0, 3, 0, y)
statusText.Text = "✓"
statusText.TextColor3 = Color3.fromRGB(0,255,0)
statusText.BackgroundColor3 = Color3.fromRGB(25,25,35)
statusText.BackgroundTransparency = 0
statusText.Font = Enum.Font.GothamBold
statusText.TextSize = 10
statusText.Parent = scroll
local stCorner = Instance.new("UICorner")
stCorner.CornerRadius = UDim.new(0, 4)
stCorner.Parent = statusText
y = y + 22

scroll.CanvasSize = UDim2.new(0, 0, 0, y + 5)

-- ========== UPDATE FUNGSI ==========
local function UpdateMaster()
    masterESP = not masterESP
    masterBtn.Text = masterESP and "M:ON" or "M:OFF"
    masterBtn.BackgroundColor3 = masterESP and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
end

local function UpdateBox()
    espBox = not espBox
    boxBtn.Text = espBox and "B:ON" or "B:OFF"
    boxBtn.BackgroundColor3 = espBox and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
end

local function UpdateTracer()
    espTracer = not espTracer
    tracerBtn.Text = espTracer and "T:ON" or "T:OFF"
    tracerBtn.BackgroundColor3 = espTracer and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
end

local function UpdateName()
    espName = not espName
    nameBtn.Text = espName and "N:ON" or "N:OFF"
    nameBtn.BackgroundColor3 = espName and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
end

local function UpdateAuto()
    autoHit = not autoHit
    autoBtn.Text = autoHit and "AUTO:ON" or "AUTO:OFF"
    autoBtn.BackgroundColor3 = autoHit and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
    autoStatus.Text = autoHit and "●" or "○"
    autoStatus.TextColor3 = autoHit and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,100,100)
    attackBtn.BackgroundColor3 = autoHit and Color3.fromRGB(0,120,0) or Color3.fromRGB(200,0,0)
end

local function UpdateSpeed()
    speedBoost = not speedBoost
    speedBtn.Text = speedBoost and "S:ON" or "S:OFF"
    speedBtn.BackgroundColor3 = speedBoost and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
    ApplySpeed()
end

local function UpdateJump()
    jumpBoost = not jumpBoost
    jumpBtn.Text = jumpBoost and "J:ON" or "J:OFF"
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

-- Tombol JAHAT
killBtn.MouseButton1Click:Connect(KillAll)
banBtn.MouseButton1Click:Connect(BanAll)

-- Thick Slider
thickMinus.MouseButton1Click:Connect(function()
    espThick = math.max(1, espThick - 1)
    thickLabel.Text = "T:"..espThick
    RefreshESP()
end)
thickPlus.MouseButton1Click:Connect(function()
    espThick = math.min(5, espThick + 1)
    thickLabel.Text = "T:"..espThick
    RefreshESP()
end)

-- Radius Slider
radiusMinus.MouseButton1Click:Connect(function()
    hitRange = math.max(30, hitRange - 10)
    radiusLabel.Text = "R:"..hitRange
end)
radiusPlus.MouseButton1Click:Connect(function()
    hitRange = math.min(100, hitRange + 10)
    radiusLabel.Text = "R:"..hitRange
end)

-- Damage Slider
damageMinus.MouseButton1Click:Connect(function()
    hitDamage = math.max(100, hitDamage - 50)
    damageLabel.Text = "D:"..hitDamage
end)
damagePlus.MouseButton1Click:Connect(function()
    hitDamage = math.min(999, hitDamage + 50)
    damageLabel.Text = "D:"..hitDamage
end)

-- Speed Slider
speedSMinus.MouseButton1Click:Connect(function()
    speedValue = math.max(25, speedValue - 25)
    speedSLabel.Text = speedValue
    ApplySpeed()
end)
speedSPlus.MouseButton1Click:Connect(function()
    speedValue = math.min(999, speedValue + 25)
    speedSLabel.Text = speedValue
    ApplySpeed()
end)

-- Jump Slider
jumpSMinus.MouseButton1Click:Connect(function()
    jumpValue = math.max(50, jumpValue - 25)
    jumpSLabel.Text = jumpValue
    ApplyJump()
end)
jumpSPlus.MouseButton1Click:Connect(function()
    jumpValue = math.min(999, jumpValue + 25)
    jumpSLabel.Text = jumpValue
    ApplyJump()
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
        frame.Size = UDim2.new(0, 160, 0, 380)
        scroll.Visible = true
        minBtn.Text = "-"
        min = false
    else
        frame.Size = UDim2.new(0, 80, 0, 28)
        scroll.Visible = false
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
        task.wait(0.01)
    end
end)()

RunService.RenderStepped:Connect(UpdateESP)

print("========================")
print("VORTEX EVIL - LOADED!")
print("🔥 KILL ALL ⛔")
print("🚫 BAN ALL 🚫")
print("========================")
