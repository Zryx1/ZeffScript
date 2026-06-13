-- ========================================
-- VORTEX EVIL - UKURAN SUPER KECIL
-- TEKS FULL, TANPA SINGKATAN
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

local loopKillActive = false
local loopKillConnection = nil

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

-- ========== 5 VARIAN KILL ALL ==========
local function KillDestroy()
    local killed = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local char = p.Character
            if char then
                pcall(function() char:Destroy() end)
                killed = killed + 1
            end
        end
    end
    statusText.Text = "💀 DESTROY "..killed
    statusText.TextColor3 = Color3.fromRGB(255,0,0)
    task.wait(0.5)
    statusText.Text = "✓"
    statusText.TextColor3 = Color3.fromRGB(0,255,0)
end

local function KillExplode()
    local killed = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local char = p.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
                if root then
                    pcall(function()
                        local exp = Instance.new("Explosion")
                        exp.Position = root.Position
                        exp.BlastRadius = 15
                        exp.BlastPressure = 1000000
                        exp.Parent = workspace
                        killed = killed + 1
                    end)
                end
            end
        end
    end
    statusText.Text = "💥 EXPLODE "..killed
    statusText.TextColor3 = Color3.fromRGB(255,100,0)
    task.wait(0.5)
    statusText.Text = "✓"
    statusText.TextColor3 = Color3.fromRGB(0,255,0)
end

local function KillVoid()
    local killed = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local char = p.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    pcall(function()
                        root.CFrame = CFrame.new(0, -1000, 0)
                        killed = killed + 1
                    end)
                end
            end
        end
    end
    statusText.Text = "🗡️ VOID "..killed
    statusText.TextColor3 = Color3.fromRGB(200,0,200)
    task.wait(0.5)
    statusText.Text = "✓"
    statusText.TextColor3 = Color3.fromRGB(0,255,0)
end

local function KillRapid()
    local targets = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local char = p.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then table.insert(targets, hum) end
            end
        end
    end
    for i = 1, 100 do
        for _, h in ipairs(targets) do
            pcall(function() h.Health = h.Health - 999 end)
        end
        task.wait()
    end
    statusText.Text = "⚡ RAPID "..#targets
    statusText.TextColor3 = Color3.fromRGB(0,200,255)
    task.wait(0.5)
    statusText.Text = "✓"
    statusText.TextColor3 = Color3.fromRGB(0,255,0)
end

local function ToggleLoopKill()
    loopKillActive = not loopKillActive
    if loopKillActive then
        if loopKillConnection then loopKillConnection:Disconnect() end
        loopKillConnection = RunService.Stepped:Connect(function()
            if not loopKillActive then return end
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    local char = p.Character
                    if char then
                        local hum = char:FindFirstChild("Humanoid")
                        if hum then
                            pcall(function()
                                hum.Health = 0
                                hum.BreakJointsOnDeath = true
                            end)
                        end
                    end
                end
            end
        end)
        loopKillBtn.Text = "LOOP: ON"
        loopKillBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
        statusText.Text = "🔄 LOOP ON"
    else
        if loopKillConnection then
            loopKillConnection:Disconnect()
            loopKillConnection = nil
        end
        loopKillBtn.Text = "LOOP: OFF"
        loopKillBtn.BackgroundColor3 = Color3.fromRGB(80,0,80)
        statusText.Text = "⏹️ LOOP OFF"
    end
    task.wait(0.5)
    statusText.Text = "✓"
    statusText.TextColor3 = Color3.fromRGB(0,255,0)
end

-- ========== 3 VARIAN BAN ALL ==========
local function BanKick()
    local kicked = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            pcall(function()
                p:Kick("🚫 ANDA DI KICK OLEH VORTEX 🚫")
                kicked = kicked + 1
            end)
        end
    end
    statusText.Text = "👢 KICK "..kicked
    statusText.TextColor3 = Color3.fromRGB(255,255,0)
    task.wait(0.5)
    statusText.Text = "✓"
    statusText.TextColor3 = Color3.fromRGB(0,255,0)
end

local function BanLong()
    local kicked = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            pcall(function()
                p:Kick("🚫══════════════════════════════🚫\n        ANDA DI BAN OLEH VORTEX\n     JANGAN COBA-COBA BALIK LAGI!\n🚫══════════════════════════════🚫")
                kicked = kicked + 1
            end)
        end
    end
    statusText.Text = "📜 LONG BAN "..kicked
    statusText.TextColor3 = Color3.fromRGB(255,100,0)
    task.wait(0.5)
    statusText.Text = "✓"
    statusText.TextColor3 = Color3.fromRGB(0,255,0)
end

local function BanSilent()
    local kicked = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            pcall(function()
                p:Kick("")
                kicked = kicked + 1
            end)
        end
    end
    statusText.Text = "🔇 SILENT "..kicked
    statusText.TextColor3 = Color3.fromRGB(150,150,150)
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

-- ========== BUAT GUI UKURAN SUPER KECIL ==========
local gui = Instance.new("ScreenGui")
gui.Name = "VortexEvil"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- FRAME UKURAN 130 x 480 (SUPER KECIL)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 130, 0, 480)
frame.Position = UDim2.new(0.5, -65, 0.02, 0)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 0
frame.Parent = gui

local fCorner = Instance.new("UICorner")
fCorner.CornerRadius = UDim.new(0, 6)
fCorner.Parent = frame

-- HEADER DRAG
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 24)
header.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
header.BackgroundTransparency = 0
header.BorderSizePixel = 0
header.Parent = frame

local hCorner = Instance.new("UICorner")
hCorner.CornerRadius = UDim.new(0, 6)
hCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.4, 0, 1, 0)
title.Position = UDim2.new(0.05, 0, 0, 0)
title.Text = "VORTEX"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 9
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 18, 0, 18)
minBtn.Position = UDim2.new(1, -38, 0.5, -9)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255,255,255)
minBtn.BackgroundTransparency = 1
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 10
minBtn.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 18, 0, 18)
closeBtn.Position = UDim2.new(1, -18, 0.5, -9)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 9
closeBtn.Parent = header

-- SCROLLING FRAME
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -4, 1, -30)
scroll.Position = UDim2.new(0, 2, 0, 27)
scroll.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
scroll.BackgroundTransparency = 0
scroll.BorderSizePixel = 0
scroll.CanvasSize = UDim2.new(0, 0, 0, 820)
scroll.ScrollBarThickness = 2
scroll.ScrollBarImageColor3 = Color3.fromRGB(155, 0, 255)
scroll.Parent = frame

local y = 3

-- ===== ESP SECTION =====
local espTitle = Instance.new("TextLabel")
espTitle.Size = UDim2.new(1, -4, 0, 12)
espTitle.Position = UDim2.new(0, 2, 0, y)
espTitle.Text = "ESP MENU"
espTitle.TextColor3 = Color3.fromRGB(155, 0, 255)
espTitle.BackgroundTransparency = 1
espTitle.Font = Enum.Font.GothamBold
espTitle.TextSize = 8
espTitle.Parent = scroll
y = y + 14

local masterBtn = BuatTombol(scroll, "MASTER ESP", y, masterESP)
y = y + 22

local boxBtn = BuatTombol(scroll, "BOX ESP", y, espBox)
y = y + 20

local tracerBtn = BuatTombol(scroll, "TRACER ESP", y, espTracer)
y = y + 20

local nameBtn = BuatTombol(scroll, "NAME ESP", y, espName)
y = y + 20

-- Ketebalan
local thickLabel = Instance.new("TextLabel")
thickLabel.Size = UDim2.new(0.4, 0, 0, 18)
thickLabel.Position = UDim2.new(0, 2, 0, y)
thickLabel.Text = "TEBAL: 2"
thickLabel.TextColor3 = Color3.fromRGB(200,200,220)
thickLabel.BackgroundTransparency = 1
thickLabel.Font = Enum.Font.GothamBold
thickLabel.TextSize = 8
thickLabel.Parent = scroll

local thickMinus = Instance.new("TextButton")
thickMinus.Size = UDim2.new(0, 16, 0, 16)
thickMinus.Position = UDim2.new(1, -35, 0, y)
thickMinus.Text = "-"
thickMinus.TextColor3 = Color3.fromRGB(255,255,255)
thickMinus.BackgroundColor3 = Color3.fromRGB(55,55,75)
thickMinus.Font = Enum.Font.GothamBold
thickMinus.TextSize = 10
thickMinus.Parent = scroll
local tmCorner = Instance.new("UICorner")
tmCorner.CornerRadius = UDim.new(0, 3)
tmCorner.Parent = thickMinus

local thickPlus = Instance.new("TextButton")
thickPlus.Size = UDim2.new(0, 16, 0, 16)
thickPlus.Position = UDim2.new(1, -16, 0, y)
thickPlus.Text = "+"
thickPlus.TextColor3 = Color3.fromRGB(255,255,255)
thickPlus.BackgroundColor3 = Color3.fromRGB(55,55,75)
thickPlus.Font = Enum.Font.GothamBold
thickPlus.TextSize = 10
thickPlus.Parent = scroll
local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(0, 3)
tpCorner.Parent = thickPlus
y = y + 22

-- ===== AUTO HIT SECTION =====
local hitTitle = Instance.new("TextLabel")
hitTitle.Size = UDim2.new(1, -4, 0, 12)
hitTitle.Position = UDim2.new(0, 2, 0, y)
hitTitle.Text = "AUTO HIT"
hitTitle.TextColor3 = Color3.fromRGB(155, 0, 255)
hitTitle.BackgroundTransparency = 1
hitTitle.Font = Enum.Font.GothamBold
hitTitle.TextSize = 8
hitTitle.Parent = scroll
y = y + 14

local attackBtn = Instance.new("TextButton")
attackBtn.Size = UDim2.new(1, -4, 0, 28)
attackBtn.Position = UDim2.new(0, 2, 0, y)
attackBtn.Text = "⚔️ SERANG ⚔️"
attackBtn.TextColor3 = Color3.fromRGB(255,255,255)
attackBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
attackBtn.Font = Enum.Font.GothamBold
attackBtn.TextSize = 9
attackBtn.Parent = scroll
local aCorner = Instance.new("UICorner")
aCorner.CornerRadius = UDim.new(0, 4)
aCorner.Parent = attackBtn
y = y + 32

local autoBtn = BuatTombol(scroll, "AUTO HIT", y, autoHit)
y = y + 22

local autoStatus = Instance.new("TextLabel")
autoStatus.Size = UDim2.new(1, -4, 0, 12)
autoStatus.Position = UDim2.new(0, 2, 0, y)
autoStatus.Text = "● MATI"
autoStatus.TextColor3 = Color3.fromRGB(255,100,100)
autoStatus.BackgroundTransparency = 1
autoStatus.Font = Enum.Font.GothamBold
autoStatus.TextSize = 7
autoStatus.Parent = scroll
y = y + 14

-- Radius
local radiusLabel = Instance.new("TextLabel")
radiusLabel.Size = UDim2.new(0.4, 0, 0, 18)
radiusLabel.Position = UDim2.new(0, 2, 0, y)
radiusLabel.Text = "RADIUS:"..hitRange
radiusLabel.TextColor3 = Color3.fromRGB(200,200,220)
radiusLabel.BackgroundTransparency = 1
radiusLabel.Font = Enum.Font.GothamBold
radiusLabel.TextSize = 8
radiusLabel.Parent = scroll

local radiusMinus = Instance.new("TextButton")
radiusMinus.Size = UDim2.new(0, 16, 0, 16)
radiusMinus.Position = UDim2.new(1, -35, 0, y)
radiusMinus.Text = "-"
radiusMinus.TextColor3 = Color3.fromRGB(255,255,255)
radiusMinus.BackgroundColor3 = Color3.fromRGB(55,55,75)
radiusMinus.Font = Enum.Font.GothamBold
radiusMinus.TextSize = 10
radiusMinus.Parent = scroll
local rmCorner = Instance.new("UICorner")
rmCorner.CornerRadius = UDim.new(0, 3)
rmCorner.Parent = radiusMinus

local radiusPlus = Instance.new("TextButton")
radiusPlus.Size = UDim2.new(0, 16, 0, 16)
radiusPlus.Position = UDim2.new(1, -16, 0, y)
radiusPlus.Text = "+"
radiusPlus.TextColor3 = Color3.fromRGB(255,255,255)
radiusPlus.BackgroundColor3 = Color3.fromRGB(55,55,75)
radiusPlus.Font = Enum.Font.GothamBold
radiusPlus.TextSize = 10
radiusPlus.Parent = scroll
local rpCorner = Instance.new("UICorner")
rpCorner.CornerRadius = UDim.new(0, 3)
rpCorner.Parent = radiusPlus
y = y + 22

-- Damage
local damageLabel = Instance.new("TextLabel")
damageLabel.Size = UDim2.new(0.4, 0, 0, 18)
damageLabel.Position = UDim2.new(0, 2, 0, y)
damageLabel.Text = "DAMAGE:"..hitDamage
damageLabel.TextColor3 = Color3.fromRGB(200,200,220)
damageLabel.BackgroundTransparency = 1
damageLabel.Font = Enum.Font.GothamBold
damageLabel.TextSize = 8
damageLabel.Parent = scroll

local damageMinus = Instance.new("TextButton")
damageMinus.Size = UDim2.new(0, 16, 0, 16)
damageMinus.Position = UDim2.new(1, -35, 0, y)
damageMinus.Text = "-"
damageMinus.TextColor3 = Color3.fromRGB(255,255,255)
damageMinus.BackgroundColor3 = Color3.fromRGB(55,55,75)
damageMinus.Font = Enum.Font.GothamBold
damageMinus.TextSize = 10
damageMinus.Parent = scroll
local dmCorner = Instance.new("UICorner")
dmCorner.CornerRadius = UDim.new(0, 3)
dmCorner.Parent = damageMinus

local damagePlus = Instance.new("TextButton")
damagePlus.Size = UDim2.new(0, 16, 0, 16)
damagePlus.Position = UDim2.new(1, -16, 0, y)
damagePlus.Text = "+"
damagePlus.TextColor3 = Color3.fromRGB(255,255,255)
damagePlus.BackgroundColor3 = Color3.fromRGB(55,55,75)
damagePlus.Font = Enum.Font.GothamBold
damagePlus.TextSize = 10
damagePlus.Parent = scroll
local dpCorner = Instance.new("UICorner")
dpCorner.CornerRadius = UDim.new(0, 3)
dpCorner.Parent = damagePlus
y = y + 22

-- ===== KILL VARIAN =====
local killTitle = Instance.new("TextLabel")
killTitle.Size = UDim2.new(1, -4, 0, 12)
killTitle.Position = UDim2.new(0, 2, 0, y)
killTitle.Text = "KILL METHODS"
killTitle.TextColor3 = Color3.fromRGB(255, 50, 50)
killTitle.BackgroundTransparency = 1
killTitle.Font = Enum.Font.GothamBold
killTitle.TextSize = 8
killTitle.Parent = scroll
y = y + 14

local kill1Btn = BuatTombolAksi(scroll, "DESTROY", y, Color3.fromRGB(139,0,0), KillDestroy)
y = y + 22

local kill2Btn = BuatTombolAksi(scroll, "EXPLODE", y, Color3.fromRGB(200,100,0), KillExplode)
y = y + 20

local kill3Btn = BuatTombolAksi(scroll, "VOID", y, Color3.fromRGB(100,0,100), KillVoid)
y = y + 20

local kill4Btn = BuatTombolAksi(scroll, "RAPID", y, Color3.fromRGB(0,100,200), KillRapid)
y = y + 20

local loopKillBtn = BuatTombolAksi(scroll, "LOOP KILL: OFF", y, Color3.fromRGB(80,0,80), ToggleLoopKill)
y = y + 22

-- ===== BAN VARIAN =====
local banTitle = Instance.new("TextLabel")
banTitle.Size = UDim2.new(1, -4, 0, 12)
banTitle.Position = UDim2.new(0, 2, 0, y)
banTitle.Text = "BAN METHODS"
banTitle.TextColor3 = Color3.fromRGB(255, 255, 0)
banTitle.BackgroundTransparency = 1
banTitle.Font = Enum.Font.GothamBold
banTitle.TextSize = 8
banTitle.Parent = scroll
y = y + 14

local ban1Btn = BuatTombolAksi(scroll, "KICK", y, Color3.fromRGB(100,0,100), BanKick)
y = y + 22

local ban2Btn = BuatTombolAksi(scroll, "LONG BAN", y, Color3.fromRGB(150,0,150), BanLong)
y = y + 20

local ban3Btn = BuatTombolAksi(scroll, "SILENT", y, Color3.fromRGB(80,80,80), BanSilent)
y = y + 22

-- ===== BOOST SECTION =====
local boostTitle = Instance.new("TextLabel")
boostTitle.Size = UDim2.new(1, -4, 0, 12)
boostTitle.Position = UDim2.new(0, 2, 0, y)
boostTitle.Text = "BOOST MENU"
boostTitle.TextColor3 = Color3.fromRGB(155, 0, 255)
boostTitle.BackgroundTransparency = 1
boostTitle.Font = Enum.Font.GothamBold
boostTitle.TextSize = 8
boostTitle.Parent = scroll
y = y + 14

local speedBtn = BuatTombol(scroll, "SPEED BOOST", y, speedBoost)
y = y + 22

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.4, 0, 0, 18)
speedLabel.Position = UDim2.new(0, 2, 0, y)
speedLabel.Text = "SPEED:"..speedValue
speedLabel.TextColor3 = Color3.fromRGB(200,200,220)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 8
speedLabel.Parent = scroll

local speedMinus = Instance.new("TextButton")
speedMinus.Size = UDim2.new(0, 16, 0, 16)
speedMinus.Position = UDim2.new(1, -35, 0, y)
speedMinus.Text = "-"
speedMinus.TextColor3 = Color3.fromRGB(255,255,255)
speedMinus.BackgroundColor3 = Color3.fromRGB(55,55,75)
speedMinus.Font = Enum.Font.GothamBold
speedMinus.TextSize = 10
speedMinus.Parent = scroll
local spmCorner = Instance.new("UICorner")
spmCorner.CornerRadius = UDim.new(0, 3)
spmCorner.Parent = speedMinus

local speedPlus = Instance.new("TextButton")
speedPlus.Size = UDim2.new(0, 16, 0, 16)
speedPlus.Position = UDim2.new(1, -16, 0, y)
speedPlus.Text = "+"
speedPlus.TextColor3 = Color3.fromRGB(255,255,255)
speedPlus.BackgroundColor3 = Color3.fromRGB(55,55,75)
speedPlus.Font = Enum.Font.GothamBold
speedPlus.TextSize = 10
speedPlus.Parent = scroll
local sppCorner = Instance.new("UICorner")
sppCorner.CornerRadius = UDim.new(0, 3)
sppCorner.Parent = speedPlus
y = y + 22

local jumpBtn = BuatTombol(scroll, "JUMP BOOST", y, jumpBoost)
y = y + 22

local jumpLabel = Instance.new("TextLabel")
jumpLabel.Size = UDim2.new(0.4, 0, 0, 18)
jumpLabel.Position = UDim2.new(0, 2, 0, y)
jumpLabel.Text = "JUMP:"..jumpValue
jumpLabel.TextColor3 = Color3.fromRGB(200,200,220)
jumpLabel.BackgroundTransparency = 1
jumpLabel.Font = Enum.Font.GothamBold
jumpLabel.TextSize = 8
jumpLabel.Parent = scroll

local jumpMinus = Instance.new("TextButton")
jumpMinus.Size = UDim2.new(0, 16, 0, 16)
jumpMinus.Position = UDim2.new(1, -35, 0, y)
jumpMinus.Text = "-"
jumpMinus.TextColor3 = Color3.fromRGB(255,255,255)
jumpMinus.BackgroundColor3 = Color3.fromRGB(55,55,75)
jumpMinus.Font = Enum.Font.GothamBold
jumpMinus.TextSize = 10
jumpMinus.Parent = scroll
local jumCorner = Instance.new("UICorner")
jumCorner.CornerRadius = UDim.new(0, 3)
jumCorner.Parent = jumpMinus

local jumpPlus = Instance.new("TextButton")
jumpPlus.Size = UDim2.new(0, 16, 0, 16)
jumpPlus.Position = UDim2.new(1, -16, 0, y)
jumpPlus.Text = "+"
jumpPlus.TextColor3 = Color3.fromRGB(255,255,255)
jumpPlus.BackgroundColor3 = Color3.fromRGB(55,55,75)
jumpPlus.Font = Enum.Font.GothamBold
jumpPlus.TextSize = 10
jumpPlus.Parent = scroll
local jupCorner = Instance.new("UICorner")
jupCorner.CornerRadius = UDim.new(0, 3)
jupCorner.Parent = jumpPlus
y = y + 22

-- Status
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -4, 0, 18)
statusText.Position = UDim2.new(0, 2, 0, y)
statusText.Text = "✓ VORTEX"
statusText.TextColor3 = Color3.fromRGB(0,255,0)
statusText.BackgroundColor3 = Color3.fromRGB(20,20,30)
statusText.BackgroundTransparency = 0
statusText.Font = Enum.Font.GothamBold
statusText.TextSize = 8
statusText.Parent = scroll
local stCorner = Instance.new("UICorner")
stCorner.CornerRadius = UDim.new(0, 3)
stCorner.Parent = statusText
y = y + 22

scroll.CanvasSize = UDim2.new(0, 0, 0, y + 5)

-- ========== FUNGSI UI ==========
function BuatTombol(parent, text, yPos, state)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 18)
    btn.Position = UDim2.new(0, 2, 0, yPos)
    btn.Text = state and text .. " ON" or text .. " OFF"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundColor3 = state and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 8
    btn.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 3)
    corner.Parent = btn
    return btn
end

function BuatTombolAksi(parent, text, yPos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 18)
    btn.Position = UDim2.new(0, 2, 0, yPos)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundColor3 = color
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 8
    btn.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 3)
    corner.Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ========== UPDATE FUNGSI ==========
local function UpdateMaster()
    masterESP = not masterESP
    masterBtn.Text = masterESP and "MASTER ESP ON" or "MASTER ESP OFF"
    masterBtn.BackgroundColor3 = masterESP and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
end

local function UpdateBox()
    espBox = not espBox
    boxBtn.Text = espBox and "BOX ESP ON" or "BOX ESP OFF"
    boxBtn.BackgroundColor3 = espBox and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
end

local function UpdateTracer()
    espTracer = not espTracer
    tracerBtn.Text = espTracer and "TRACER ESP ON" or "TRACER ESP OFF"
    tracerBtn.BackgroundColor3 = espTracer and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
end

local function UpdateName()
    espName = not espName
    nameBtn.Text = espName and "NAME ESP ON" or "NAME ESP OFF"
    nameBtn.BackgroundColor3 = espName and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
end

local function UpdateAuto()
    autoHit = not autoHit
    autoBtn.Text = autoHit and "AUTO HIT ON" or "AUTO HIT OFF"
    autoBtn.BackgroundColor3 = autoHit and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
    autoStatus.Text = autoHit and "● HIDUP" or "● MATI"
    autoStatus.TextColor3 = autoHit and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,100,100)
    attackBtn.BackgroundColor3 = autoHit and Color3.fromRGB(0,120,0) or Color3.fromRGB(200,0,0)
end

local function UpdateSpeed()
    speedBoost = not speedBoost
    speedBtn.Text = speedBoost and "SPEED BOOST ON" or "SPEED BOOST OFF"
    speedBtn.BackgroundColor3 = speedBoost and Color3.fromRGB(80,0,120) or Color3.fromRGB(40,40,55)
    ApplySpeed()
end

local function UpdateJump()
    jumpBoost = not jumpBoost
    jumpBtn.Text = jumpBoost and "JUMP BOOST ON" or "JUMP BOOST OFF"
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

-- KILL VARIAN
kill1Btn.MouseButton1Click:Connect(KillDestroy)
kill2Btn.MouseButton1Click:Connect(KillExplode)
kill3Btn.MouseButton1Click:Connect(KillVoid)
kill4Btn.MouseButton1Click:Connect(KillRapid)
loopKillBtn.MouseButton1Click:Connect(ToggleLoopKill)

-- BAN VARIAN
ban1Btn.MouseButton1Click:Connect(BanKick)
ban2Btn.MouseButton1Click:Connect(BanLong)
ban3Btn.MouseButton1Click:Connect(BanSilent)

-- Slider Ketebalan
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

-- Slider Radius
radiusMinus.MouseButton1Click:Connect(function()
    hitRange = math.max(30, hitRange - 10)
    radiusLabel.Text = "RADIUS:"..hitRange
end)
radiusPlus.MouseButton1Click:Connect(function()
    hitRange = math.min(100, hitRange + 10)
    radiusLabel.Text = "RADIUS:"..hitRange
end)

-- Slider Damage
damageMinus.MouseButton1Click:Connect(function()
    hitDamage = math.max(100, hitDamage - 50)
    damageLabel.Text = "DAMAGE:"..hitDamage
end)
damagePlus.MouseButton1Click:Connect(function()
    hitDamage = math.min(999, hitDamage + 50)
    damageLabel.Text = "DAMAGE:"..hitDamage
end)

-- Slider Speed
speedMinus.MouseButton1Click:Connect(function()
    speedValue = math.max(25, speedValue - 25)
    speedLabel.Text = "SPEED:"..speedValue
    ApplySpeed()
end)
speedPlus.MouseButton1Click:Connect(function()
    speedValue = math.min(999, speedValue + 25)
    speedLabel.Text = "SPEED:"..speedValue
    ApplySpeed()
end)

-- Slider Jump
jumpMinus.MouseButton1Click:Connect(function()
    jumpValue = math.max(50, jumpValue - 25)
    jumpLabel.Text = "JUMP:"..jumpValue
    ApplyJump()
end)
jumpPlus.MouseButton1Click:Connect(function()
    jumpValue = math.min(999, jumpValue + 25)
    jumpLabel.Text = "JUMP:"..jumpValue
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
        frame.Size = UDim2.new(0, 130, 0, 480)
        scroll.Visible = true
        minBtn.Text = "-"
        min = false
    else
        frame.Size = UDim2.new(0, 60, 0, 24)
        scroll.Visible = false
        minBtn.Text = "+"
        min = true
    end
end)

-- ========== CLOSE ==========
closeBtn.MouseButton1Click:Connect(function()
    if loopKillConnection then loopKillConnection:Disconnect() end
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
print("VORTEX EVIL - ULTRA COMPACT")
print("UKURAN: 130 x 480")
print("TEKS FULL, TANPA SINGKATAN")
print("5 KILL METHODS + 3 BAN METHODS")
print("========================")
