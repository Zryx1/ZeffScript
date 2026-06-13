-- ========================================
-- VORTEX EVIL - ULTIMATE FIXED
-- SEMUA TOMBOL BERUBAH WARNA
-- UKURAN KECIL (160x450)
-- SCROLL PANJANG 1300
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
local espColor = Color3.fromRGB(155, 0, 255)

-- WALLHACK
local noclipEnabled = false
local noclipConnection = nil

-- GOD MODE
local godModeEnabled = false
local godModeConnection = nil

-- AUTO HIT
local autoHit = false
local hitRange = 100
local hitDamage = 999

-- SPEED JUMP
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
    box.Color = espColor
    box.Thickness = espThick
    box.Filled = false
    box.Transparency = 0.5
    
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = espColor
    tracer.Thickness = espThick
    
    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Color = espColor
    nameTag.Size = 12
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.fromRGB(0,0,0)
    
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
    
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, esp in pairs(espObjects) do
        local char = esp.player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if not char or not hum or not root or hum.Health <= 0 then
            if esp.box then esp.box.Visible = false end
            if esp.tracer then esp.tracer.Visible = false end
            if esp.nameTag then esp.nameTag.Visible = false end
        else
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            if espBox and esp.box and onScreen then
                local distance = (root.Position - Camera.CFrame.Position).Magnitude
                local boxSize = math.clamp(200 / distance, 30, 100)
                esp.box.Size = Vector2.new(boxSize, boxSize)
                esp.box.Position = Vector2.new(pos.X - boxSize/2, pos.Y - boxSize/1.2)
                esp.box.Visible = true
            elseif esp.box then
                esp.box.Visible = false
            end
            
            if espTracer and esp.tracer and onScreen then
                esp.tracer.From = center
                esp.tracer.To = Vector2.new(pos.X, pos.Y)
                esp.tracer.Visible = true
            elseif esp.tracer then
                esp.tracer.Visible = false
            end
            
            if espName and esp.nameTag and onScreen then
                esp.nameTag.Text = esp.player.Name
                esp.nameTag.Position = Vector2.new(pos.X, pos.Y - 30)
                esp.nameTag.Visible = true
            elseif esp.nameTag then
                esp.nameTag.Visible = false
            end
        end
    end
end

local function RefreshESP()
    for _, esp in pairs(espObjects) do
        if esp.box then
            esp.box.Color = espColor
            esp.box.Thickness = espThick
        end
        if esp.tracer then
            esp.tracer.Color = espColor
            esp.tracer.Thickness = espThick
        end
        if esp.nameTag then
            esp.nameTag.Color = espColor
        end
    end
end

-- ========== WALLHACK ==========
local function EnableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    noclipConnection = RunService.Stepped:Connect(function()
        if not noclipEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function DisableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

local function ToggleNoclip()
    noclipEnabled = not noclipEnabled
    
    if noclipEnabled then
        EnableNoclip()
        noclipBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        noclipBtn.Text = "WALLHACK: ON"
    else
        DisableNoclip()
        noclipBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        noclipBtn.Text = "WALLHACK: OFF"
    end
end

-- ========== GOD MODE ==========
local function EnableGodMode()
    if godModeConnection then
        godModeConnection:Disconnect()
        godModeConnection = nil
    end
    
    godModeConnection = RunService.Stepped:Connect(function()
        if not godModeEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            if hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
            if hum.Health <= 0 then
                hum.Health = hum.MaxHealth
            end
            hum.BreakJointsOnDeath = false
            if hum:GetState() == Enum.HumanoidStateType.Dead then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    end)
end

local function DisableGodMode()
    if godModeConnection then
        godModeConnection:Disconnect()
        godModeConnection = nil
    end
    
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.BreakJointsOnDeath = true
        end
    end
end

local function ToggleGodMode()
    godModeEnabled = not godModeEnabled
    
    if godModeEnabled then
        EnableGodMode()
        godModeBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        godModeBtn.Text = "GOD MODE: ON"
    else
        DisableGodMode()
        godModeBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        godModeBtn.Text = "GOD MODE: OFF"
    end
end

-- ========== AUTO HIT ==========
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
        pcall(function() h.Health = h.Health - hitDamage end)
    end
end

local function ManualAttack()
    local targets = GetAllTargets()
    if #targets > 0 then
        for _, h in ipairs(targets) do
            pcall(function() h.Health = h.Health - 999 end)
        end
        statusText.Text = "⚔️ "..#targets.." TARGETS HIT!"
        statusText.TextColor3 = Color3.fromRGB(0,255,0)
        task.wait(0.5)
        statusText.Text = "✓ READY"
    else
        statusText.Text = "❌ NO TARGET"
        statusText.TextColor3 = Color3.fromRGB(255,0,0)
        task.wait(0.5)
        statusText.Text = "✓ READY"
    end
    statusText.TextColor3 = Color3.fromRGB(0,255,0)
end

local function ToggleAutoHit()
    autoHit = not autoHit
    
    if autoHit then
        autoBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        autoBtn.Text = "AUTO HIT: ON"
        autoStatus.Text = "● ACTIVE"
        autoStatus.TextColor3 = Color3.fromRGB(0,255,0)
        attackBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
    else
        autoBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        autoBtn.Text = "AUTO HIT: OFF"
        autoStatus.Text = "○ INACTIVE"
        autoStatus.TextColor3 = Color3.fromRGB(255,100,100)
        attackBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
    end
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

local function ToggleSpeed()
    speedBoost = not speedBoost
    
    if speedBoost then
        speedBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        speedBtn.Text = "SPEED: ON"
    else
        speedBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        speedBtn.Text = "SPEED: OFF"
    end
    ApplySpeed()
end

local function ToggleJump()
    jumpBoost = not jumpBoost
    
    if jumpBoost then
        jumpBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        jumpBtn.Text = "JUMP: ON"
    else
        jumpBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        jumpBtn.Text = "JUMP: OFF"
    end
    ApplyJump()
end

-- ========== UPDATE ESP ==========
local function UpdateMaster()
    masterESP = not masterESP
    
    if masterESP then
        masterBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        masterBtn.Text = "MASTER ESP: ON"
    else
        masterBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        masterBtn.Text = "MASTER ESP: OFF"
    end
end

local function UpdateBox()
    espBox = not espBox
    
    if espBox then
        boxBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        boxBtn.Text = "BOX ESP: ON"
    else
        boxBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        boxBtn.Text = "BOX ESP: OFF"
    end
end

local function UpdateTracer()
    espTracer = not espTracer
    
    if espTracer then
        tracerBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        tracerBtn.Text = "TRACER ESP: ON"
    else
        tracerBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        tracerBtn.Text = "TRACER ESP: OFF"
    end
end

local function UpdateName()
    espName = not espName
    
    if espName then
        nameBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        nameBtn.Text = "NAME ESP: ON"
    else
        nameBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        nameBtn.Text = "NAME ESP: OFF"
    end
end

-- ========== BUAT GUI ==========
local gui = Instance.new("ScreenGui")
gui.Name = "VortexFinal"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- FRAME UKURAN KECIL (160 x 450)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 450)
frame.Position = UDim2.new(0.5, -80, 0.02, 0)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 0
frame.Parent = gui

local fCorner = Instance.new("UICorner")
fCorner.CornerRadius = UDim.new(0, 8)
fCorner.Parent = frame

-- HEADER
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
title.Text = "⚔️ VORTEX"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 11
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

-- SCROLL
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -6, 1, -36)
scroll.Position = UDim2.new(0, 3, 0, 32)
scroll.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
scroll.BackgroundTransparency = 0
scroll.BorderSizePixel = 0
scroll.CanvasSize = UDim2.new(0, 0, 0, 1300)
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(155, 0, 255)
scroll.Parent = frame

local y = 3

-- ===== ESP SECTION =====
local espTitle = Instance.new("TextLabel")
espTitle.Size = UDim2.new(1, -6, 0, 16)
espTitle.Position = UDim2.new(0, 3, 0, y)
espTitle.Text = "🎮 ESP MENU"
espTitle.TextColor3 = Color3.fromRGB(155, 0, 255)
espTitle.BackgroundTransparency = 1
espTitle.Font = Enum.Font.GothamBold
espTitle.TextSize = 9
espTitle.Parent = scroll
y = y + 18

local masterBtn = Instance.new("TextButton")
masterBtn.Size = UDim2.new(1, -6, 0, 24)
masterBtn.Position = UDim2.new(0, 3, 0, y)
masterBtn.Text = "MASTER ESP: OFF"
masterBtn.TextColor3 = Color3.fromRGB(255,255,255)
masterBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
masterBtn.Font = Enum.Font.GothamBold
masterBtn.TextSize = 8
masterBtn.Parent = scroll
local mCorner = Instance.new("UICorner")
mCorner.CornerRadius = UDim.new(0, 4)
mCorner.Parent = masterBtn
y = y + 28

local boxBtn = Instance.new("TextButton")
boxBtn.Size = UDim2.new(1, -6, 0, 24)
boxBtn.Position = UDim2.new(0, 3, 0, y)
boxBtn.Text = "BOX ESP: OFF"
boxBtn.TextColor3 = Color3.fromRGB(255,255,255)
boxBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
boxBtn.Font = Enum.Font.GothamBold
boxBtn.TextSize = 8
boxBtn.Parent = scroll
local bCorner = Instance.new("UICorner")
bCorner.CornerRadius = UDim.new(0, 4)
bCorner.Parent = boxBtn
y = y + 28

local tracerBtn = Instance.new("TextButton")
tracerBtn.Size = UDim2.new(1, -6, 0, 24)
tracerBtn.Position = UDim2.new(0, 3, 0, y)
tracerBtn.Text = "TRACER ESP: OFF"
tracerBtn.TextColor3 = Color3.fromRGB(255,255,255)
tracerBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
tracerBtn.Font = Enum.Font.GothamBold
tracerBtn.TextSize = 8
tracerBtn.Parent = scroll
local tCorner = Instance.new("UICorner")
tCorner.CornerRadius = UDim.new(0, 4)
tCorner.Parent = tracerBtn
y = y + 28

local nameBtn = Instance.new("TextButton")
nameBtn.Size = UDim2.new(1, -6, 0, 24)
nameBtn.Position = UDim2.new(0, 3, 0, y)
nameBtn.Text = "NAME ESP: OFF"
nameBtn.TextColor3 = Color3.fromRGB(255,255,255)
nameBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
nameBtn.Font = Enum.Font.GothamBold
nameBtn.TextSize = 8
nameBtn.Parent = scroll
local nCorner = Instance.new("UICorner")
nCorner.CornerRadius = UDim.new(0, 4)
nCorner.Parent = nameBtn
y = y + 28

-- Ketebalan
local thickLabel = Instance.new("TextLabel")
thickLabel.Size = UDim2.new(0.5, 0, 0, 22)
thickLabel.Position = UDim2.new(0, 3, 0, y)
thickLabel.Text = "TEBAL: 2"
thickLabel.TextColor3 = Color3.fromRGB(200,200,220)
thickLabel.BackgroundTransparency = 1
thickLabel.Font = Enum.Font.GothamBold
thickLabel.TextSize = 8
thickLabel.Parent = scroll

local thickMinus = Instance.new("TextButton")
thickMinus.Size = UDim2.new(0, 18, 0, 18)
thickMinus.Position = UDim2.new(1, -40, 0, y)
thickMinus.Text = "-"
thickMinus.TextColor3 = Color3.fromRGB(255,255,255)
thickMinus.BackgroundColor3 = Color3.fromRGB(55,55,75)
thickMinus.Font = Enum.Font.GothamBold
thickMinus.TextSize = 12
thickMinus.Parent = scroll
local tmCorner = Instance.new("UICorner")
tmCorner.CornerRadius = UDim.new(0, 3)
tmCorner.Parent = thickMinus

local thickPlus = Instance.new("TextButton")
thickPlus.Size = UDim2.new(0, 18, 0, 18)
thickPlus.Position = UDim2.new(1, -20, 0, y)
thickPlus.Text = "+"
thickPlus.TextColor3 = Color3.fromRGB(255,255,255)
thickPlus.BackgroundColor3 = Color3.fromRGB(55,55,75)
thickPlus.Font = Enum.Font.GothamBold
thickPlus.TextSize = 12
thickPlus.Parent = scroll
local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(0, 3)
tpCorner.Parent = thickPlus
y = y + 26

-- ===== WALLHACK =====
local wallTitle = Instance.new("TextLabel")
wallTitle.Size = UDim2.new(1, -6, 0, 16)
wallTitle.Position = UDim2.new(0, 3, 0, y)
wallTitle.Text = "🪄 WALLHACK"
wallTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
wallTitle.BackgroundTransparency = 1
wallTitle.Font = Enum.Font.GothamBold
wallTitle.TextSize = 9
wallTitle.Parent = scroll
y = y + 18

local noclipBtn = Instance.new("TextButton")
noclipBtn.Size = UDim2.new(1, -6, 0, 28)
noclipBtn.Position = UDim2.new(0, 3, 0, y)
noclipBtn.Text = "WALLHACK: OFF"
noclipBtn.TextColor3 = Color3.fromRGB(255,255,255)
noclipBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
noclipBtn.Font = Enum.Font.GothamBold
noclipBtn.TextSize = 8
noclipBtn.Parent = scroll
local wCorner = Instance.new("UICorner")
wCorner.CornerRadius = UDim.new(0, 5)
wCorner.Parent = noclipBtn
y = y + 32

-- ===== GOD MODE =====
local godTitle = Instance.new("TextLabel")
godTitle.Size = UDim2.new(1, -6, 0, 16)
godTitle.Position = UDim2.new(0, 3, 0, y)
godTitle.Text = "🛡️ GOD MODE"
godTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
godTitle.BackgroundTransparency = 1
godTitle.Font = Enum.Font.GothamBold
godTitle.TextSize = 9
godTitle.Parent = scroll
y = y + 18

local godModeBtn = Instance.new("TextButton")
godModeBtn.Size = UDim2.new(1, -6, 0, 28)
godModeBtn.Position = UDim2.new(0, 3, 0, y)
godModeBtn.Text = "GOD MODE: OFF"
godModeBtn.TextColor3 = Color3.fromRGB(255,255,255)
godModeBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
godModeBtn.Font = Enum.Font.GothamBold
godModeBtn.TextSize = 8
godModeBtn.Parent = scroll
local gCorner = Instance.new("UICorner")
gCorner.CornerRadius = UDim.new(0, 5)
gCorner.Parent = godModeBtn
y = y + 32

-- ===== AUTO HIT =====
local hitTitle = Instance.new("TextLabel")
hitTitle.Size = UDim2.new(1, -6, 0, 16)
hitTitle.Position = UDim2.new(0, 3, 0, y)
hitTitle.Text = "⚔️ AUTO HIT"
hitTitle.TextColor3 = Color3.fromRGB(155, 0, 255)
hitTitle.BackgroundTransparency = 1
hitTitle.Font = Enum.Font.GothamBold
hitTitle.TextSize = 9
hitTitle.Parent = scroll
y = y + 18

local attackBtn = Instance.new("TextButton")
attackBtn.Size = UDim2.new(1, -6, 0, 32)
attackBtn.Position = UDim2.new(0, 3, 0, y)
attackBtn.Text = "⚔️ SERANG ⚔️"
attackBtn.TextColor3 = Color3.fromRGB(255,255,255)
attackBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
attackBtn.Font = Enum.Font.GothamBold
attackBtn.TextSize = 10
attackBtn.Parent = scroll
local aCorner = Instance.new("UICorner")
aCorner.CornerRadius = UDim.new(0, 5)
aCorner.Parent = attackBtn
y = y + 36

local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(1, -6, 0, 24)
autoBtn.Position = UDim2.new(0, 3, 0, y)
autoBtn.Text = "AUTO HIT: OFF"
autoBtn.TextColor3 = Color3.fromRGB(255,255,255)
autoBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
autoBtn.Font = Enum.Font.GothamBold
autoBtn.TextSize = 8
autoBtn.Parent = scroll
local auCorner = Instance.new("UICorner")
auCorner.CornerRadius = UDim.new(0, 4)
auCorner.Parent = autoBtn
y = y + 28

local autoStatus = Instance.new("TextLabel")
autoStatus.Size = UDim2.new(1, -6, 0, 14)
autoStatus.Position = UDim2.new(0, 3, 0, y)
autoStatus.Text = "○ INACTIVE"
autoStatus.TextColor3 = Color3.fromRGB(255,100,100)
autoStatus.BackgroundTransparency = 1
autoStatus.Font = Enum.Font.GothamBold
autoStatus.TextSize = 7
autoStatus.Parent = scroll
y = y + 16

-- Radius
local radiusLabel = Instance.new("TextLabel")
radiusLabel.Size = UDim2.new(0.5, 0, 0, 22)
radiusLabel.Position = UDim2.new(0, 3, 0, y)
radiusLabel.Text = "RADIUS: "..hitRange
radiusLabel.TextColor3 = Color3.fromRGB(200,200,220)
radiusLabel.BackgroundTransparency = 1
radiusLabel.Font = Enum.Font.GothamBold
radiusLabel.TextSize = 8
radiusLabel.Parent = scroll

local radiusMinus = Instance.new("TextButton")
radiusMinus.Size = UDim2.new(0, 18, 0, 18)
radiusMinus.Position = UDim2.new(1, -40, 0, y)
radiusMinus.Text = "-"
radiusMinus.TextColor3 = Color3.fromRGB(255,255,255)
radiusMinus.BackgroundColor3 = Color3.fromRGB(55,55,75)
radiusMinus.Font = Enum.Font.GothamBold
radiusMinus.TextSize = 12
radiusMinus.Parent = scroll
local rmCorner = Instance.new("UICorner")
rmCorner.CornerRadius = UDim.new(0, 3)
rmCorner.Parent = radiusMinus

local radiusPlus = Instance.new("TextButton")
radiusPlus.Size = UDim2.new(0, 18, 0, 18)
radiusPlus.Position = UDim2.new(1, -20, 0, y)
radiusPlus.Text = "+"
radiusPlus.TextColor3 = Color3.fromRGB(255,255,255)
radiusPlus.BackgroundColor3 = Color3.fromRGB(55,55,75)
radiusPlus.Font = Enum.Font.GothamBold
radiusPlus.TextSize = 12
radiusPlus.Parent = scroll
local rpCorner = Instance.new("UICorner")
rpCorner.CornerRadius = UDim.new(0, 3)
rpCorner.Parent = radiusPlus
y = y + 26

-- Damage
local damageLabel = Instance.new("TextLabel")
damageLabel.Size = UDim2.new(0.5, 0, 0, 22)
damageLabel.Position = UDim2.new(0, 3, 0, y)
damageLabel.Text = "DAMAGE: "..hitDamage
damageLabel.TextColor3 = Color3.fromRGB(200,200,220)
damageLabel.BackgroundTransparency = 1
damageLabel.Font = Enum.Font.GothamBold
damageLabel.TextSize = 8
damageLabel.Parent = scroll

local damageMinus = Instance.new("TextButton")
damageMinus.Size = UDim2.new(0, 18, 0, 18)
damageMinus.Position = UDim2.new(1, -40, 0, y)
damageMinus.Text = "-"
damageMinus.TextColor3 = Color3.fromRGB(255,255,255)
damageMinus.BackgroundColor3 = Color3.fromRGB(55,55,75)
damageMinus.Font = Enum.Font.GothamBold
damageMinus.TextSize = 12
damageMinus.Parent = scroll
local dmCorner = Instance.new("UICorner")
dmCorner.CornerRadius = UDim.new(0, 3)
dmCorner.Parent = damageMinus

local damagePlus = Instance.new("TextButton")
damagePlus.Size = UDim2.new(0, 18, 0, 18)
damagePlus.Position = UDim2.new(1, -20, 0, y)
damagePlus.Text = "+"
damagePlus.TextColor3 = Color3.fromRGB(255,255,255)
damagePlus.BackgroundColor3 = Color3.fromRGB(55,55,75)
damagePlus.Font = Enum.Font.GothamBold
damagePlus.TextSize = 12
damagePlus.Parent = scroll
local dpCorner = Instance.new("UICorner")
dpCorner.CornerRadius = UDim.new(0, 3)
dpCorner.Parent = damagePlus
y = y + 26

-- ===== BOOST =====
local boostTitle = Instance.new("TextLabel")
boostTitle.Size = UDim2.new(1, -6, 0, 16)
boostTitle.Position = UDim2.new(0, 3, 0, y)
boostTitle.Text = "🏃 BOOST MENU"
boostTitle.TextColor3 = Color3.fromRGB(155, 0, 255)
boostTitle.BackgroundTransparency = 1
boostTitle.Font = Enum.Font.GothamBold
boostTitle.TextSize = 9
boostTitle.Parent = scroll
y = y + 18

local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(1, -6, 0, 24)
speedBtn.Position = UDim2.new(0, 3, 0, y)
speedBtn.Text = "SPEED: OFF"
speedBtn.TextColor3 = Color3.fromRGB(255,255,255)
speedBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
speedBtn.Font = Enum.Font.GothamBold
speedBtn.TextSize = 8
speedBtn.Parent = scroll
local spCorner = Instance.new("UICorner")
spCorner.CornerRadius = UDim.new(0, 4)
spCorner.Parent = speedBtn
y = y + 28

local speedValLabel = Instance.new("TextLabel")
speedValLabel.Size = UDim2.new(0.5, 0, 0, 22)
speedValLabel.Position = UDim2.new(0, 3, 0, y)
speedValLabel.Text = "SPEED: "..speedValue
speedValLabel.TextColor3 = Color3.fromRGB(200,200,220)
speedValLabel.BackgroundTransparency = 1
speedValLabel.Font = Enum.Font.GothamBold
speedValLabel.TextSize = 8
speedValLabel.Parent = scroll

local speedValMinus = Instance.new("TextButton")
speedValMinus.Size = UDim2.new(0, 18, 0, 18)
speedValMinus.Position = UDim2.new(1, -40, 0, y)
speedValMinus.Text = "-"
speedValMinus.TextColor3 = Color3.fromRGB(255,255,255)
speedValMinus.BackgroundColor3 = Color3.fromRGB(55,55,75)
speedValMinus.Font = Enum.Font.GothamBold
speedValMinus.TextSize = 12
speedValMinus.Parent = scroll
local svmCorner = Instance.new("UICorner")
svmCorner.CornerRadius = UDim.new(0, 3)
svmCorner.Parent = speedValMinus

local speedValPlus = Instance.new("TextButton")
speedValPlus.Size = UDim2.new(0, 18, 0, 18)
speedValPlus.Position = UDim2.new(1, -20, 0, y)
speedValPlus.Text = "+"
speedValPlus.TextColor3 = Color3.fromRGB(255,255,255)
speedValPlus.BackgroundColor3 = Color3.fromRGB(55,55,75)
speedValPlus.Font = Enum.Font.GothamBold
speedValPlus.TextSize = 12
speedValPlus.Parent = scroll
local svpCorner = Instance.new("UICorner")
svpCorner.CornerRadius = UDim.new(0, 3)
svpCorner.Parent = speedValPlus
y = y + 26

local jumpBtn = Instance.new("TextButton")
jumpBtn.Size = UDim2.new(1, -6, 0, 24)
jumpBtn.Position = UDim2.new(0, 3, 0, y)
jumpBtn.Text = "JUMP: OFF"
jumpBtn.TextColor3 = Color3.fromRGB(255,255,255)
jumpBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
jumpBtn.Font = Enum.Font.GothamBold
jumpBtn.TextSize = 8
jumpBtn.Parent = scroll
local jpCorner = Instance.new("UICorner")
jpCorner.CornerRadius = UDim.new(0, 4)
jpCorner.Parent = jumpBtn
y = y + 28

local jumpValLabel = Instance.new("TextLabel")
jumpValLabel.Size = UDim2.new(0.5, 0, 0, 22)
jumpValLabel.Position = UDim2.new(0, 3, 0, y)
jumpValLabel.Text = "JUMP: "..jumpValue
jumpValLabel.TextColor3 = Color3.fromRGB(200,200,220)
jumpValLabel.BackgroundTransparency = 1
jumpValLabel.Font = Enum.Font.GothamBold
jumpValLabel.TextSize = 8
jumpValLabel.Parent = scroll

local jumpValMinus = Instance.new("TextButton")
jumpValMinus.Size = UDim2.new(0, 18, 0, 18)
jumpValMinus.Position = UDim2.new(1, -40, 0, y)
jumpValMinus.Text = "-"
jumpValMinus.TextColor3 = Color3.fromRGB(255,255,255)
jumpValMinus.BackgroundColor3 = Color3.fromRGB(55,55,75)
jumpValMinus.Font = Enum.Font.GothamBold
jumpValMinus.TextSize = 12
jumpValMinus.Parent = scroll
local jvmCorner = Instance.new("UICorner")
jvmCorner.CornerRadius = UDim.new(0, 3)
jvmCorner.Parent = jumpValMinus

local jumpValPlus = Instance.new("TextButton")
jumpValPlus.Size = UDim2.new(0, 18, 0, 18)
jumpValPlus.Position = UDim2.new(1, -20, 0, y)
jumpValPlus.Text = "+"
jumpValPlus.TextColor3 = Color3.fromRGB(255,255,255)
jumpValPlus.BackgroundColor3 = Color3.fromRGB(55,55,75)
jumpValPlus.Font = Enum.Font.GothamBold
jumpValPlus.TextSize = 12
jumpValPlus.Parent = scroll
local jvpCorner = Instance.new("UICorner")
jvpCorner.CornerRadius = UDim.new(0, 3)
jvpCorner.Parent = jumpValPlus
y = y + 26

-- STATUS
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -6, 0, 22)
statusText.Position = UDim2.new(0, 3, 0, y)
statusText.Text = "✓ VORTEX READY"
statusText.TextColor3 = Color3.fromRGB(0,255,0)
statusText.BackgroundColor3 = Color3.fromRGB(25,25,35)
statusText.BackgroundTransparency = 0
statusText.Font = Enum.Font.GothamBold
statusText.TextSize = 8
statusText.Parent = scroll
local stCorner = Instance.new("UICorner")
stCorner.CornerRadius = UDim.new(0, 4)
stCorner.Parent = statusText
y = y + 26

scroll.CanvasSize = UDim2.new(0, 0, 0, y + 50)

-- ========== CONNECT ==========
masterBtn.MouseButton1Click:Connect(UpdateMaster)
boxBtn.MouseButton1Click:Connect(UpdateBox)
tracerBtn.MouseButton1Click:Connect(UpdateTracer)
nameBtn.MouseButton1Click:Connect(UpdateName)
attackBtn.MouseButton1Click:Connect(ManualAttack)
autoBtn.MouseButton1Click:Connect(ToggleAutoHit)
speedBtn.MouseButton1Click:Connect(ToggleSpeed)
jumpBtn.MouseButton1Click:Connect(ToggleJump)
noclipBtn.MouseButton1Click:Connect(ToggleNoclip)
godModeBtn.MouseButton1Click:Connect(ToggleGodMode)

-- Sliders
thickMinus.MouseButton1Click:Connect(function()
    espThick = math.max(1, espThick - 1)
    thickLabel.Text = "TEBAL: "..espThick
    RefreshESP()
end)
thickPlus.MouseButton1Click:Connect(function()
    espThick = math.min(5, espThick + 1)
    thickLabel.Text = "TEBAL: "..espThick
    RefreshESP()
end)

radiusMinus.MouseButton1Click:Connect(function()
    hitRange = math.max(30, hitRange - 10)
    radiusLabel.Text = "RADIUS: "..hitRange
end)
radiusPlus.MouseButton1Click:Connect(function()
    hitRange = math.min(100, hitRange + 10)
    radiusLabel.Text = "RADIUS: "..hitRange
end)

damageMinus.MouseButton1Click:Connect(function()
    hitDamage = math.max(100, hitDamage - 50)
    damageLabel.Text = "DAMAGE: "..hitDamage
end)
damagePlus.MouseButton1Click:Connect(function()
    hitDamage = math.min(999, hitDamage + 50)
    damageLabel.Text = "DAMAGE: "..hitDamage
end)

speedValMinus.MouseButton1Click:Connect(function()
    speedValue = math.max(25, speedValue - 25)
    speedValLabel.Text = "SPEED: "..speedValue
    ApplySpeed()
end)
speedValPlus.MouseButton1Click:Connect(function()
    speedValue = math.min(999, speedValue + 25)
    speedValLabel.Text = "SPEED: "..speedValue
    ApplySpeed()
end)

jumpValMinus.MouseButton1Click:Connect(function()
    jumpValue = math.max(50, jumpValue - 25)
    jumpValLabel.Text = "JUMP: "..jumpValue
    ApplyJump()
end)
jumpValPlus.MouseButton1Click:Connect(function()
    jumpValue = math.min(999, jumpValue + 25)
    jumpValLabel.Text = "JUMP: "..jumpValue
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
        frame.Size = UDim2.new(0, 160, 0, 450)
        scroll.Visible = true
        minBtn.Text = "-"
        min = false
    else
        frame.Size = UDim2.new(0, 100, 0, 28)
        scroll.Visible = false
        minBtn.Text = "+"
        min = true
    end
end)

-- ========== CLOSE ==========
closeBtn.MouseButton1Click:Connect(function()
    DisableNoclip()
    DisableGodMode()
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
    
    if noclipEnabled then
        EnableNoclip()
    end
    if godModeEnabled then
        EnableGodMode()
    end
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
print("🔥 VORTEX ULTIMATE FIXED 🔥")
print("✅ UKURAN: 160x450 (KECIL)")
print("✅ MINIMIZE: 100x28 (BESARAN)")
print("✅ SEMUA TOMBOL BERUBAH WARNA")
print("✅ SCROLL 1300 - SAMPE BAWAH")
print("========================")
