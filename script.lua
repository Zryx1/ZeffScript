-- ========================================
-- VORTEX FULL BRUTAL - KILL + BAN + ESP + AUTO HIT
-- 5 METODE KILL | BAN ALL | LENGKAP
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

-- AUTO HIT
local autoHit = false
local hitRange = 100
local hitDamage = 999

-- SPEED JUMP
local speedBoost = false
local speedValue = 200
local jumpBoost = false
local jumpValue = 200

-- LOOP KILL
local loopKillActive = false
local loopKillConnection = nil

-- STORAGE
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

-- ========== FUNGSI AUTO HIT ==========
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
        pcall(function()
            h.Health = h.Health - hitDamage
        end)
    end
end

local function ManualAttack()
    local targets = GetAllTargets()
    if #targets > 0 then
        for _, h in ipairs(targets) do
            pcall(function()
                h.Health = h.Health - 999
            end)
        end
        statusText.Text = "⚔️ "..#targets.." TARGET DISERANG!"
        statusText.TextColor3 = Color3.fromRGB(0,255,0)
        task.wait(0.5)
        statusText.Text = "✅ SIAP"
        statusText.TextColor3 = Color3.fromRGB(0,255,0)
    else
        statusText.Text = "❌ TIDAK ADA TARGET"
        statusText.TextColor3 = Color3.fromRGB(255,0,0)
        task.wait(0.5)
        statusText.Text = "✅ SIAP"
        statusText.TextColor3 = Color3.fromRGB(0,255,0)
    end
end

-- ========== 5 METODE KILL ==========
-- Method 1: Destroy Character
local function KillMethod1()
    local killed = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local char = p.Character
            if char then
                pcall(function()
                    char:Destroy()
                    killed = killed + 1
                end)
            end
        end
    end
    statusText.Text = "💀 "..killed.." KARAKTER DIHANCURKAN!"
    statusText.TextColor3 = Color3.fromRGB(255,0,0)
    task.wait(0.8)
    statusText.Text = "✅ SIAP"
    statusText.TextColor3 = Color3.fromRGB(0,255,0)
end

-- Method 2: Explode All
local function KillMethod2()
    local killed = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local char = p.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
                if root then
                    pcall(function()
                        local explosion = Instance.new("Explosion")
                        explosion.Position = root.Position
                        explosion.BlastRadius = 15
                        explosion.BlastPressure = 1000000
                        explosion.Parent = workspace
                        killed = killed + 1
                    end)
                end
            end
        end
    end
    statusText.Text = "💥 "..killed.." PLAYER MELEDAK!"
    statusText.TextColor3 = Color3.fromRGB(255,100,0)
    task.wait(0.8)
    statusText.Text = "✅ SIAP"
    statusText.TextColor3 = Color3.fromRGB(0,255,0)
end

-- Method 3: Break Joints + Teleport to Void
local function KillMethod3()
    local killed = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local char = p.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                pcall(function()
                    if hum then
                        hum.BreakJointsOnDeath = true
                        hum.Health = 0
                        for _, part in pairs(char:GetChildren()) do
                            if part:IsA("BasePart") then
                                part:Destroy()
                            end
                        end
                    end
                    if root then
                        root.CFrame = CFrame.new(0, -1000, 0)
                    end
                    killed = killed + 1
                end)
            end
        end
    end
    statusText.Text = "🗡️ "..killed.." PLAYER DIMUSNAHKAN!"
    statusText.TextColor3 = Color3.fromRGB(200,0,200)
    task.wait(0.8)
    statusText.Text = "✅ SIAP"
    statusText.TextColor3 = Color3.fromRGB(0,255,0)
end

-- Method 4: Rapid Attack (100x)
local function KillMethod4()
    local targets = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local char = p.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    table.insert(targets, hum)
                end
            end
        end
    end
    
    for i = 1, 100 do
        for _, h in ipairs(targets) do
            pcall(function()
                h.Health = h.Health - 999
            end)
        end
        task.wait()
    end
    statusText.Text = "⚡ RAPID 100x KE "..#targets.." TARGET!"
    statusText.TextColor3 = Color3.fromRGB(0,200,255)
    task.wait(0.8)
    statusText.Text = "✅ SIAP"
    statusText.TextColor3 = Color3.fromRGB(0,255,0)
end

-- Method 5: Loop Kill (Toggle ON/OFF)
local function StartLoopKill()
    if loopKillConnection then return end
    loopKillActive = true
    loopKillConnection = RunService.Stepped:Connect(function()
        if not loopKillActive then return end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local char = p.Character
                if char then
                    pcall(function()
                        local hum = char:FindFirstChild("Humanoid")
                        if hum then
                            hum.Health = 0
                            hum.BreakJointsOnDeath = true
                        end
                        for _, part in pairs(char:GetChildren()) do
                            if part:IsA("BasePart") then
                                part:Destroy()
                            end
                        end
                    end)
                end
            end
        end
    end)
    statusText.Text = "🔄 LOOP KILL AKTIF!"
    statusText.TextColor3 = Color3.fromRGB(255,0,0)
    task.wait(0.5)
    statusText.Text = "✅ SIAP"
    statusText.TextColor3 = Color3.fromRGB(0,255,0)
end

local function StopLoopKill()
    loopKillActive = false
    if loopKillConnection then
        loopKillConnection:Disconnect()
        loopKillConnection = nil
    end
    statusText.Text = "⏹️ LOOP KILL BERHENTI"
    statusText.TextColor3 = Color3.fromRGB(255,200,0)
    task.wait(0.5)
    statusText.Text = "✅ SIAP"
    statusText.TextColor3 = Color3.fromRGB(0,255,0)
end

local function ToggleLoopKill()
    if loopKillActive then
        StopLoopKill()
        loopKillBtn.Text = "🔄 LOOP KILL (OFF)"
        loopKillBtn.BackgroundColor3 = Color3.fromRGB(80,0,80)
    else
        StartLoopKill()
        loopKillBtn.Text = "🔄 LOOP KILL (ON) 🔥"
        loopKillBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
    end
end

-- ========== BAN ALL ==========
local function BanAll()
    local kicked = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            pcall(function()
                p:Kick("🚫 ANDA DI BAN OLEH VORTEX! 🚫\n\nJangan coba-coba balik lagi!")
                kicked = kicked + 1
            end)
        end
    end
    statusText.Text = "🚫 "..kicked.." PLAYER DI BAN!"
    statusText.TextColor3 = Color3.fromRGB(255,255,0)
    task.wait(0.8)
    statusText.Text = "✅ SIAP"
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

-- ========== BUAT GUI FULL ==========
local gui = Instance.new("ScreenGui")
gui.Name = "VortexFullBrutal"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 190, 0, 540)
frame.Position = UDim2.new(0.5, -95, 0.01, 0)
frame.BackgroundColor3 = Color3.fromRGB(8, 8, 18)
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 0
frame.Parent = gui

local fCorner = Instance.new("UICorner")
fCorner.CornerRadius = UDim.new(0, 10)
fCorner.Parent = frame

-- HEADER
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 35)
header.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
header.BackgroundTransparency = 0
header.BorderSizePixel = 0
header.Parent = frame

local hCorner = Instance.new("UICorner")
hCorner.CornerRadius = UDim.new(0, 10)
hCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.5, 0, 1, 0)
title.Position = UDim2.new(0.05, 0, 0, 0)
title.Text = "💀 VORTEX"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 25, 0, 25)
minBtn.Position = UDim2.new(1, -55, 0.5, -12.5)
minBtn.Text = "─"
minBtn.TextColor3 = Color3.fromRGB(255,255,255)
minBtn.BackgroundTransparency = 1
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -28, 0.5, -12.5)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.Parent = header

-- SCROLL
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -8, 1, -43)
scroll.Position = UDim2.new(0, 4, 0, 39)
scroll.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
scroll.BackgroundTransparency = 0
scroll.BorderSizePixel = 0
scroll.CanvasSize = UDim2.new(0, 0, 0, 820)
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(155, 0, 255)
scroll.Parent = frame

local y = 5

-- ===== ESP SECTION =====
local espTitle = Instance.new("TextLabel")
espTitle.Size = UDim2.new(1, -6, 0, 18)
espTitle.Position = UDim2.new(0, 3, 0, y)
espTitle.Text = "🎮 ESP MENU"
espTitle.TextColor3 = Color3.fromRGB(155, 0, 255)
espTitle.BackgroundTransparency = 1
espTitle.Font = Enum.Font.GothamBold
espTitle.TextSize = 10
espTitle.Parent = scroll
y = y + 20

local masterBtn = CreateButton(scroll, "MASTER ESP", y, masterESP)
y = y + 32

local boxBtn = CreateButton(scroll, "BOX ESP", y, espBox)
y = y + 30

local tracerBtn = CreateButton(scroll, "TRACER ESP", y, espTracer)
y = y + 30

local nameBtn = CreateButton(scroll, "NAME ESP", y, espName)
y = y + 30

local thickFrame = CreateSlider(scroll, "TEBAL", y, espThick, 1, 5)
local thickMinus = thickFrame.minus
local thickPlus = thickFrame.plus
local thickVal = thickFrame.value
y = y + 34

-- ===== AUTO HIT SECTION =====
local hitTitle = Instance.new("TextLabel")
hitTitle.Size = UDim2.new(1, -6, 0, 18)
hitTitle.Position = UDim2.new(0, 3, 0, y)
hitTitle.Text = "⚔️ AUTO HIT"
hitTitle.TextColor3 = Color3.fromRGB(155, 0, 255)
hitTitle.BackgroundTransparency = 1
hitTitle.Font = Enum.Font.GothamBold
hitTitle.TextSize = 10
hitTitle.Parent = scroll
y = y + 20

local attackBtn = Instance.new("TextButton")
attackBtn.Size = UDim2.new(1, -6, 0, 38)
attackBtn.Position = UDim2.new(0, 3, 0, y)
attackBtn.Text = "⚔️ SERANG SEMUA! ⚔️"
attackBtn.TextColor3 = Color3.fromRGB(255,255,255)
attackBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
attackBtn.Font = Enum.Font.GothamBold
attackBtn.TextSize = 11
attackBtn.Parent = scroll
local aCorner = Instance.new("UICorner")
aCorner.CornerRadius = UDim.new(0, 6)
aCorner.Parent = attackBtn
y = y + 42

local autoBtn = CreateButton(scroll, "AUTO HIT", y, autoHit)
y = y + 32

local autoStatus = Instance.new("TextLabel")
autoStatus.Size = UDim2.new(1, -6, 0, 16)
autoStatus.Position = UDim2.new(0, 3, 0, y)
autoStatus.Text = "● MATI"
autoStatus.TextColor3 = Color3.fromRGB(255,100,100)
autoStatus.BackgroundTransparency = 1
autoStatus.Font = Enum.Font.GothamBold
autoStatus.TextSize = 9
autoStatus.Parent = scroll
y = y + 18

local radiusFrame = CreateSlider(scroll, "RADIUS (M)", y, hitRange, 30, 100)
local radiusMinus = radiusFrame.minus
local radiusPlus = radiusFrame.plus
local radiusVal = radiusFrame.value
y = y + 34

local damageFrame = CreateSlider(scroll, "DAMAGE", y, hitDamage, 100, 999)
local damageMinus = damageFrame.minus
local damagePlus = damageFrame.plus
local damageVal = damageFrame.value
y = y + 34

-- ===== KILL METHODS SECTION =====
local killTitle = Instance.new("TextLabel")
killTitle.Size = UDim2.new(1, -6, 0, 18)
killTitle.Position = UDim2.new(0, 3, 0, y)
killTitle.Text = "💀 KILL METHODS"
killTitle.TextColor3 = Color3.fromRGB(255, 0, 0)
killTitle.BackgroundTransparency = 1
killTitle.Font = Enum.Font.GothamBold
killTitle.TextSize = 10
killTitle.Parent = scroll
y = y + 20

local method1Btn = Instance.new("TextButton")
method1Btn.Size = UDim2.new(1, -6, 0, 32)
method1Btn.Position = UDim2.new(0, 3, 0, y)
method1Btn.Text = "1️⃣ HANCURKAN KARAKTER"
method1Btn.TextColor3 = Color3.fromRGB(255,255,255)
method1Btn.BackgroundColor3 = Color3.fromRGB(139,0,0)
method1Btn.Font = Enum.Font.GothamBold
method1Btn.TextSize = 10
method1Btn.Parent = scroll
local m1Corner = Instance.new("UICorner")
m1Corner.CornerRadius = UDim.new(0, 5)
m1Corner.Parent = method1Btn
y = y + 36

local method2Btn = Instance.new("TextButton")
method2Btn.Size = UDim2.new(1, -6, 0, 32)
method2Btn.Position = UDim2.new(0, 3, 0, y)
method2Btn.Text = "2️⃣ LEDAKKAN SEMUA"
method2Btn.TextColor3 = Color3.fromRGB(255,255,255)
method2Btn.BackgroundColor3 = Color3.fromRGB(200,100,0)
method2Btn.Font = Enum.Font.GothamBold
method2Btn.TextSize = 10
method2Btn.Parent = scroll
local m2Corner = Instance.new("UICorner")
m2Corner.CornerRadius = UDim.new(0, 5)
m2Corner.Parent = method2Btn
y = y + 36

local method3Btn = Instance.new("TextButton")
method3Btn.Size = UDim2.new(1, -6, 0, 32)
method3Btn.Position = UDim2.new(0, 3, 0, y)
method3Btn.Text = "3️⃣ HANCUR + LEMPAR"
method3Btn.TextColor3 = Color3.fromRGB(255,255,255)
method3Btn.BackgroundColor3 = Color3.fromRGB(100,0,100)
method3Btn.Font = Enum.Font.GothamBold
method3Btn.TextSize = 10
method3Btn.Parent = scroll
local m3Corner = Instance.new("UICorner")
m3Corner.CornerRadius = UDim.new(0, 5)
m3Corner.Parent = method3Btn
y = y + 36

local method4Btn = Instance.new("TextButton")
method4Btn.Size = UDim2.new(1, -6, 0, 32)
method4Btn.Position = UDim2.new(0, 3, 0, y)
method4Btn.Text = "4️⃣ RAPID ATTACK (100x)"
method4Btn.TextColor3 = Color3.fromRGB(255,255,255)
method4Btn.BackgroundColor3 = Color3.fromRGB(0,100,200)
method4Btn.Font = Enum.Font.GothamBold
method4Btn.TextSize = 10
method4Btn.Parent = scroll
local m4Corner = Instance.new("UICorner")
m4Corner.CornerRadius = UDim.new(0, 5)
m4Corner.Parent = method4Btn
y = y + 36

local loopKillBtn = Instance.new("TextButton")
loopKillBtn.Size = UDim2.new(1, -6, 0, 32)
loopKillBtn.Position = UDim2.new(0, 3, 0, y)
loopKillBtn.Text = "5️⃣ LOOP KILL (OFF)"
loopKillBtn.TextColor3 = Color3.fromRGB(255,255,255)
loopKillBtn.BackgroundColor3 = Color3.fromRGB(80,0,80)
loopKillBtn.Font = Enum.Font.GothamBold
loopKillBtn.TextSize = 10
loopKillBtn.Parent = scroll
local m5Corner = Instance.new("UICorner")
m5Corner.CornerRadius = UDim.new(0, 5)
m5Corner.Parent = loopKillBtn
y = y + 36

-- ===== BAN SECTION =====
local banTitle = Instance.new("TextLabel")
banTitle.Size = UDim2.new(1, -6, 0, 18)
banTitle.Position = UDim2.new(0, 3, 0, y)
banTitle.Text = "🚫 BAN MENU"
banTitle.TextColor3 = Color3.fromRGB(255, 255, 0)
banTitle.BackgroundTransparency = 1
banTitle.Font = Enum.Font.GothamBold
banTitle.TextSize = 10
banTitle.Parent = scroll
y = y + 20

local banBtn = Instance.new("TextButton")
banBtn.Size = UDim2.new(1, -6, 0, 38)
banBtn.Position = UDim2.new(0, 3, 0, y)
banBtn.Text = "🚫 BAN ALL PLAYER 🚫"
banBtn.TextColor3 = Color3.fromRGB(255,255,255)
banBtn.BackgroundColor3 = Color3.fromRGB(100,0,100)
banBtn.Font = Enum.Font.GothamBold
banBtn.TextSize = 11
banBtn.Parent = scroll
local banCorner = Instance.new("UICorner")
banCorner.CornerRadius = UDim.new(0, 6)
banCorner.Parent = banBtn
y = y + 44

-- ===== BOOST SECTION =====
local boostTitle = Instance.new("TextLabel")
boostTitle.Size = UDim2.new(1, -6, 0, 18)
boostTitle.Position = UDim2.new(0, 3, 0, y)
boostTitle.Text = "🏃 BOOST MENU"
boostTitle.TextColor3 = Color3.fromRGB(155, 0, 255)
boostTitle.BackgroundTransparency = 1
boostTitle.Font = Enum.Font.GothamBold
boostTitle.TextSize = 10
boostTitle.Parent = scroll
y = y + 20

local speedBtn = CreateButton(scroll, "SPEED BOOST", y, speedBoost)
y = y + 32

local speedSFrame = CreateSlider(scroll, "SPEED VAL", y, speedValue, 25, 999)
local speedSMinus = speedSFrame.minus
local speedSPlus = speedSFrame.plus
local speedSVal = speedSFrame.value
y = y + 34

local jumpBtn = CreateButton(scroll, "JUMP BOOST", y, jumpBoost)
y = y + 32

local jumpSFrame = CreateSlider(scroll, "JUMP VAL", y, jumpValue, 50, 999)
local jumpSMinus = jumpSFrame.minus
local jumpSPlus = jumpSFrame.plus
local jumpSVal = jumpSFrame.value
y = y + 34

-- STATUS
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -6, 0, 28)
statusText.Position = UDim2.new(0, 3, 0, y)
statusText.Text = "✅ VORTEX SIAP"
statusText.TextColor3 = Color3.fromRGB(0,255,0)
statusText.BackgroundColor3 = Color3.fromRGB(20,20,30)
statusText.BackgroundTransparency = 0
statusText.Font = Enum.Font.GothamBold
statusText.TextSize = 9
statusText.Parent = scroll
local stCorner = Instance.new("UICorner")
stCorner.CornerRadius = UDim.new(0, 5)
stCorner.Parent = statusText
y = y + 34

scroll.CanvasSize = UDim2.new(0, 0, 0, y + 10)

-- ========== FUNGSI UI ==========
function CreateButton(parent, text, yPos, state)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 28)
    btn.Position = UDim2.new(0, 3, 0, yPos)
    btn.Text = state and text .. " ✅" or text .. " ❌"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundColor3 = state and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn
    return btn
end

function CreateSlider(parent, label, yPos, value, minVal, maxVal)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -6, 0, 28)
    frame.Position = UDim2.new(0, 3, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,42)
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.Parent = parent
    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0, 5)
    fCorner.Parent = frame
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.4, 0, 1, 0)
    lbl.Position = UDim2.new(0, 5, 0, 0)
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200,200,220)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local valTxt = Instance.new("TextLabel")
    valTxt.Size = UDim2.new(0.2, 0, 1, 0)
    valTxt.Position = UDim2.new(0.45, 0, 0, 0)
    valTxt.Text = tostring(value)
    valTxt.TextColor3 = Color3.fromRGB(155,0,255)
    valTxt.BackgroundTransparency = 1
    valTxt.Font = Enum.Font.GothamBold
    valTxt.TextSize = 9
    valTxt.Parent = frame
    
    local minus = Instance.new("TextButton")
    minus.Size = UDim2.new(0, 22, 0, 22)
    minus.Position = UDim2.new(1, -48, 0.5, -11)
    minus.Text = "-"
    minus.TextColor3 = Color3.fromRGB(255,255,255)
    minus.BackgroundColor3 = Color3.fromRGB(55,55,75)
    minus.Font = Enum.Font.GothamBold
    minus.TextSize = 14
    minus.Parent = frame
    local mCorner = Instance.new("UICorner")
    mCorner.CornerRadius = UDim.new(0, 4)
    mCorner.Parent = minus
    
    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0, 22, 0, 22)
    plus.Position = UDim2.new(1, -24, 0.5, -11)
    plus.Text = "+"
    plus.TextColor3 = Color3.fromRGB(255,255,255)
    plus.BackgroundColor3 = Color3.fromRGB(55,55,75)
    plus.Font = Enum.Font.GothamBold
    plus.TextSize = 14
    plus.Parent = frame
    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(0, 4)
    pCorner.Parent = plus
    
    return {frame=frame, value=valTxt, minus=minus, plus=plus}
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
    autoStatus.Text = autoHit and "● HIDUP - SERANG SEMUA" or "● MATI"
    autoStatus.TextColor3 = autoHit and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,100,100)
    attackBtn.BackgroundColor3 = autoHit and Color3.fromRGB(0,120,0) or Color3.fromRGB(200,0,0)
end

local function UpdateSpeed()
    speedBoost = not speedBoost
    speedBtn.Text = speedBoost and "SPEED BOOST ✅" or "SPEED BOOST ❌"
    speedBtn.BackgroundColor3 = speedBoost and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
    ApplySpeed()
end

local function UpdateJump()
    jumpBoost = not jumpBoost
    jumpBtn.Text = jumpBoost and "JUMP BOOST ✅" or "JUMP BOOST ❌"
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

-- Kill Methods
method1Btn.MouseButton1Click:Connect(KillMethod1)
method2Btn.MouseButton1Click:Connect(KillMethod2)
method3Btn.MouseButton1Click:Connect(KillMethod3)
method4Btn.MouseButton1Click:Connect(KillMethod4)
loopKillBtn.MouseButton1Click:Connect(ToggleLoopKill)
banBtn.MouseButton1Click:Connect(BanAll)

-- Sliders
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

radiusMinus.MouseButton1Click:Connect(function()
    hitRange = math.max(30, hitRange - 10)
    radiusVal.Text = tostring(hitRange)
end)
radiusPlus.MouseButton1Click:Connect(function()
    hitRange = math.min(100, hitRange + 10)
    radiusVal.Text = tostring(hitRange)
end)

damageMinus.MouseButton1Click:Connect(function()
    hitDamage = math.max(100, hitDamage - 50)
    damageVal.Text = tostring(hitDamage)
end)
damagePlus.MouseButton1Click:Connect(function()
    hitDamage = math.min(999, hitDamage + 50)
    damageVal.Text = tostring(hitDamage)
end)

speedSMinus.MouseButton1Click:Connect(function()
    speedValue = math.max(25, speedValue - 25)
    speedSVal.Text = tostring(speedValue)
    ApplySpeed()
end)
speedSPlus.MouseButton1Click:Connect(function()
    speedValue = math.min(999, speedValue + 25)
    speedSVal.Text = tostring(speedValue)
    ApplySpeed()
end)

jumpSMinus.MouseButton1Click:Connect(function()
    jumpValue = math.max(50, jumpValue - 25)
    jumpSVal.Text = tostring(jumpValue)
    ApplyJump()
end)
jumpSPlus.MouseButton1Click:Connect(function()
    jumpValue = math.min(999, jumpValue + 25)
    jumpSVal.Text = tostring(jumpValue)
    ApplyJump()
end)

-- ========== DRAG MENU ==========
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
        frame.Size = UDim2.new(0, 190, 0, 540)
        scroll.Visible = true
        minBtn.Text = "─"
        min = false
    else
        frame.Size = UDim2.new(0, 100, 0, 35)
        scroll.Visible = false
        minBtn.Text = "□"
        min = true
    end
end)

-- ========== CLOSE ==========
closeBtn.MouseButton1Click:Connect(function()
    StopLoopKill()
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
print("💀 VORTEX FULL BRUTAL 💀")
print("")
print("5 METODE KILL:")
print("1. Hancurkan Karakter")
print("2. Ledakkan Semua")
print("3. Hancur + Lempar")
print("4. Rapid Attack 100x")
print("5. Loop Kill (ON/OFF)")
print("")
print("🚫 BAN ALL PLAYER")
print("⚔️ AUTO HIT + RADIUS")
print("🎮 ESP LENGKAP")
print("🏃 SPEED/JUMP BOOST")
print("========================")
