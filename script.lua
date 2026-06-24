-- ========================================
-- VORTEX EVIL - FINAL ULTIMATE
-- ESP BOX WHITE (WORK ALL GAME)
-- WALLHACK | GOD MODE | AUTO HIT | MULTI PENDAPATAN
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
local espThick = 1
local espColor = Color3.fromRGB(255, 255, 255) -- PUTIH

-- WALLHACK
local noclipEnabled = false
local noclipConnection = nil

-- GOD MODE
local godModeEnabled = false
local godModeConnection = nil

-- AUTO HIT
local autoHit = false
local hitDamage = 999999
local killLoop = nil

-- MULTI PENDAPATAN
local multiIncomeEnabled = false
local incomeMultiplier = 10
local multiIncomeConnection = nil
local remoteConnections = {}
local valueConnections = {}

-- SPEED JUMP
local speedBoost = false
local speedValue = 200
local jumpBoost = false
local jumpValue = 200

-- ESP STORAGE
local espObjects = {}
local espConnections = {}
local origSpeed = 16
local origJump = 50

-- ========== ESP BOX (WHITE - WORK ALL GAME) ==========
local function CreateESP(player)
    if player == LocalPlayer or espObjects[player] then return end
    
    -- BOX
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = espColor
    box.Thickness = espThick
    box.Transparency = 0.5
    box.Filled = false
    
    -- TRACER
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = espColor
    tracer.Thickness = espThick
    
    -- NAME
    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Color = espColor
    nameTag.Size = 12
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.fromRGB(0,0,0)
    
    espObjects[player] = {box=box, tracer=tracer, nameTag=nameTag, player=player}
    
    -- UPDATE LOOP
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not masterESP then
            if box then box.Visible = false end
            if tracer then tracer.Visible = false end
            if nameTag then nameTag.Visible = false end
            return
        end
        
        local char = player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if not char or not hum or not root or hum.Health <= 0 then
            if box then box.Visible = false end
            if tracer then tracer.Visible = false end
            if nameTag then nameTag.Visible = false end
            return
        end
        
        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        -- BOX ESP (Method yang work all game)
        if espBox and box and onScreen then
            local top = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
            local bottom = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, -3.5, 0))
            local sizeY = math.abs(top.Y - bottom.Y)
            local sizeX = sizeY * 0.6
            
            box.Size = Vector2.new(sizeX, sizeY)
            box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
            box.Visible = true
            box.Color = espColor
            box.Thickness = espThick
        elseif box then
            box.Visible = false
        end
        
        -- TRACER ESP
        if espTracer and tracer and onScreen then
            tracer.From = center
            tracer.To = Vector2.new(pos.X, pos.Y)
            tracer.Visible = true
            tracer.Color = espColor
            tracer.Thickness = espThick
        elseif tracer then
            tracer.Visible = false
        end
        
        -- NAME ESP
        if espName and nameTag and onScreen then
            nameTag.Text = player.Name
            nameTag.Position = Vector2.new(pos.X, pos.Y - 35)
            nameTag.Visible = true
            nameTag.Color = espColor
        elseif nameTag then
            nameTag.Visible = false
        end
    end)
    
    espConnections[player] = connection
    
    -- CLEANUP
    player.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if box then box:Remove() end
            if tracer then tracer:Remove() end
            if nameTag then nameTag:Remove() end
            if espConnections[player] then espConnections[player]:Disconnect() end
            espObjects[player] = nil
            espConnections[player] = nil
        end
    end)
end

local function RemoveESP(player)
    local esp = espObjects[player]
    if esp then
        if esp.box then esp.box:Remove() end
        if esp.tracer then esp.tracer:Remove() end
        if esp.nameTag then esp.nameTag:Remove() end
        espObjects[player] = nil
    end
    if espConnections[player] then
        espConnections[player]:Disconnect()
        espConnections[player] = nil
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
    if noclipConnection then noclipConnection:Disconnect() end
    noclipConnection = RunService.Stepped:Connect(function()
        if not noclipEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
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
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

-- ========== GOD MODE ==========
local function EnableGodMode()
    if godModeConnection then godModeConnection:Disconnect() end
    godModeConnection = RunService.Stepped:Connect(function()
        if not godModeEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
            if hum.Health <= 0 then hum.Health = hum.MaxHealth end
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
end

-- ========== KILL FUNCTION ==========
local function KillPlayer(target)
    if target == LocalPlayer then return end
    
    pcall(function()
        local char = target.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum.Health = 0
                hum.BreakJointsOnDeath = true
            end
        end
    end)
    
    pcall(function()
        if target.Character then target.Character:Destroy() end
    end)
    
    pcall(function()
        local char = target.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
            if root then
                local exp = Instance.new("Explosion")
                exp.Position = root.Position
                exp.BlastRadius = 50
                exp.BlastPressure = 999999999
                exp.Parent = workspace
            end
        end
    end)
    
    pcall(function()
        local char = target.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = CFrame.new(0, -10000, 0)
            end
        end
    end)
end

local function KillAllPlayers()
    local killed = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            KillPlayer(p)
            killed = killed + 1
        end
    end
    return killed
end

-- ========== AUTO HIT ==========
local function StartAutoHit()
    if killLoop then killLoop:Disconnect() end
    killLoop = RunService.Stepped:Connect(function()
        if not autoHit then return end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                KillPlayer(p)
            end
        end
    end)
end

local function StopAutoHit()
    if killLoop then
        killLoop:Disconnect()
        killLoop = nil
    end
end

-- ========== MULTI PENDAPATAN ==========
local function HookRemoteEvent(remote)
    pcall(function()
        local oldFunction = remote.OnClientEvent
        remote.OnClientEvent = function(...)
            local args = {...}
            for i, arg in ipairs(args) do
                if type(arg) == "number" and arg > 0 then
                    args[i] = arg * incomeMultiplier
                end
            end
            if oldFunction then
                oldFunction(unpack(args))
            end
        end
    end)
end

local function HookValue(value)
    pcall(function()
        local oldGet = value.GetValue
        value.GetValue = function()
            local original = oldGet(value)
            if type(original) == "number" and original > 0 then
                return original * incomeMultiplier
            end
            return original
        end
    end)
end

local function ScanAndHook()
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            if not remoteConnections[obj] then
                HookRemoteEvent(obj)
                remoteConnections[obj] = true
            end
        end
        
        if obj:IsA("NumberValue") or obj:IsA("IntValue") or obj:IsA("DoubleValue") then
            local name = string.lower(obj.Name)
            if name:match("exp") or name:match("gold") or name:match("money") or 
               name:match("gem") or name:match("coin") or name:match("level") or
               name:match("point") or name:match("reward") then
                if not valueConnections[obj] then
                    HookValue(obj)
                    valueConnections[obj] = true
                end
            end
        end
    end
end

local function EnableMultiIncome()
    ScanAndHook()
    if multiIncomeConnection then multiIncomeConnection:Disconnect() end
    multiIncomeConnection = game.DescendantAdded:Connect(function(desc)
        if multiIncomeEnabled then
            if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then
                HookRemoteEvent(desc)
            end
            if desc:IsA("NumberValue") or desc:IsA("IntValue") or desc:IsA("DoubleValue") then
                local name = string.lower(desc.Name)
                if name:match("exp") or name:match("gold") or name:match("money") or 
                   name:match("gem") or name:match("coin") or name:match("level") then
                    HookValue(desc)
                end
            end
        end
    end)
end

local function DisableMultiIncome()
    if multiIncomeConnection then
        multiIncomeConnection:Disconnect()
        multiIncomeConnection = nil
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

-- ========== TOGGLE FUNGSI ==========
local function ToggleMaster()
    masterESP = not masterESP
    masterBtn.BackgroundColor3 = masterESP and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
end

local function ToggleBox()
    espBox = not espBox
    boxBtn.BackgroundColor3 = espBox and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
end

local function ToggleTracer()
    espTracer = not espTracer
    tracerBtn.BackgroundColor3 = espTracer and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
end

local function ToggleName()
    espName = not espName
    nameBtn.BackgroundColor3 = espName and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
end

local function ToggleNoclip()
    noclipEnabled = not noclipEnabled
    if noclipEnabled then
        EnableNoclip()
        noclipBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
    else
        DisableNoclip()
        noclipBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
    end
end

local function ToggleGod()
    godModeEnabled = not godModeEnabled
    if godModeEnabled then
        EnableGodMode()
        godModeBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
    else
        DisableGodMode()
        godModeBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
    end
end

local function ToggleAuto()
    autoHit = not autoHit
    if autoHit then
        StartAutoHit()
        autoBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
        autoStatus.Text = "● ACTIVE"
        autoStatus.TextColor3 = Color3.fromRGB(0,255,0)
        attackBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
    else
        StopAutoHit()
        autoBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
        autoStatus.Text = "○ INACTIVE"
        autoStatus.TextColor3 = Color3.fromRGB(255,100,100)
        attackBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
    end
end

local function ManualAttack()
    local killed = KillAllPlayers()
    if killed > 0 then
        statusText.Text = "💀 "..killed.." PLAYERS KILLED!"
        statusText.TextColor3 = Color3.fromRGB(255,0,0)
    else
        statusText.Text = "❌ NO TARGET"
        statusText.TextColor3 = Color3.fromRGB(255,0,0)
    end
    task.wait(1)
    statusText.Text = "✓ READY"
    statusText.TextColor3 = Color3.fromRGB(0,255,0)
end

local function ToggleMultiIncome()
    multiIncomeEnabled = not multiIncomeEnabled
    if multiIncomeEnabled then
        EnableMultiIncome()
        multiIncomeBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
        statusText.Text = "💰 MULTI PENDAPATAN "..incomeMultiplier.."x AKTIF!"
    else
        DisableMultiIncome()
        multiIncomeBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
        statusText.Text = "💰 MULTI PENDAPATAN OFF"
    end
    statusText.TextColor3 = Color3.fromRGB(0,255,0)
    task.wait(0.5)
    statusText.Text = "✓ READY"
end

local function ToggleSpeed()
    speedBoost = not speedBoost
    speedBtn.BackgroundColor3 = speedBoost and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
    ApplySpeed()
end

local function ToggleJump()
    jumpBoost = not jumpBoost
    jumpBtn.BackgroundColor3 = jumpBoost and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
    ApplyJump()
end

-- ========== SLIDER FUNGSI ==========
local function UpdateThick(val)
    espThick = math.max(1, math.min(5, espThick + val))
    thickLabel.Text = "TEBAL: "..espThick
    RefreshESP()
end

local function UpdateMultiplier(val)
    local newVal = incomeMultiplier + val
    if newVal >= 1 and newVal <= 999 then
        incomeMultiplier = newVal
        multiplierLabel.Text = "MULTI: "..incomeMultiplier.."x"
        if multiIncomeEnabled then
            statusText.Text = "💰 MULTIPLIER: "..incomeMultiplier.."x"
            task.wait(0.5)
            statusText.Text = "✓ READY"
        end
    end
end

local function UpdateSpeedVal(val)
    speedValue = math.max(25, math.min(999, speedValue + val))
    speedValLabel.Text = "SPEED: "..speedValue
    ApplySpeed()
end

local function UpdateJumpVal(val)
    jumpValue = math.max(50, math.min(999, jumpValue + val))
    jumpValLabel.Text = "JUMP: "..jumpValue
    ApplyJump()
end

-- ========== BUAT GUI ==========
local gui = Instance.new("ScreenGui")
gui.Name = "VortexFinal"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 170, 0, 520)
frame.Position = UDim2.new(0.5, -85, 0.01, 0)
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
title.Text = "💀 VORTEX"
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

-- ESP SECTION
local espTitle = Instance.new("TextLabel")
espTitle.Size = UDim2.new(1, -6, 0, 16)
espTitle.Position = UDim2.new(0, 3, 0, y)
espTitle.Text = "🎮 ESP MENU (WHITE)"
espTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
espTitle.BackgroundTransparency = 1
espTitle.Font = Enum.Font.GothamBold
espTitle.TextSize = 9
espTitle.Parent = scroll
y = y + 18

masterBtn = Instance.new("TextButton")
masterBtn.Size = UDim2.new(1, -6, 0, 22)
masterBtn.Position = UDim2.new(0, 3, 0, y)
masterBtn.Text = "MASTER ESP"
masterBtn.TextColor3 = Color3.fromRGB(255,255,255)
masterBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
masterBtn.Font = Enum.Font.GothamBold
masterBtn.TextSize = 8
masterBtn.Parent = scroll
y = y + 26

boxBtn = Instance.new("TextButton")
boxBtn.Size = UDim2.new(1, -6, 0, 22)
boxBtn.Position = UDim2.new(0, 3, 0, y)
boxBtn.Text = "BOX ESP"
boxBtn.TextColor3 = Color3.fromRGB(255,255,255)
boxBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
boxBtn.Font = Enum.Font.GothamBold
boxBtn.TextSize = 8
boxBtn.Parent = scroll
y = y + 26

tracerBtn = Instance.new("TextButton")
tracerBtn.Size = UDim2.new(1, -6, 0, 22)
tracerBtn.Position = UDim2.new(0, 3, 0, y)
tracerBtn.Text = "TRACER ESP"
tracerBtn.TextColor3 = Color3.fromRGB(255,255,255)
tracerBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
tracerBtn.Font = Enum.Font.GothamBold
tracerBtn.TextSize = 8
tracerBtn.Parent = scroll
y = y + 26

nameBtn = Instance.new("TextButton")
nameBtn.Size = UDim2.new(1, -6, 0, 22)
nameBtn.Position = UDim2.new(0, 3, 0, y)
nameBtn.Text = "NAME ESP"
nameBtn.TextColor3 = Color3.fromRGB(255,255,255)
nameBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
nameBtn.Font = Enum.Font.GothamBold
nameBtn.TextSize = 8
nameBtn.Parent = scroll
y = y + 26

thickLabel = Instance.new("TextLabel")
thickLabel.Size = UDim2.new(0.5, 0, 0, 20)
thickLabel.Position = UDim2.new(0, 3, 0, y)
thickLabel.Text = "TEBAL: 1"
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

local thickPlus = Instance.new("TextButton")
thickPlus.Size = UDim2.new(0, 18, 0, 18)
thickPlus.Position = UDim2.new(1, -20, 0, y)
thickPlus.Text = "+"
thickPlus.TextColor3 = Color3.fromRGB(255,255,255)
thickPlus.BackgroundColor3 = Color3.fromRGB(55,55,75)
thickPlus.Font = Enum.Font.GothamBold
thickPlus.TextSize = 12
thickPlus.Parent = scroll
y = y + 24

-- WALLHACK
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

noclipBtn = Instance.new("TextButton")
noclipBtn.Size = UDim2.new(1, -6, 0, 26)
noclipBtn.Position = UDim2.new(0, 3, 0, y)
noclipBtn.Text = "WALLHACK"
noclipBtn.TextColor3 = Color3.fromRGB(255,255,255)
noclipBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
noclipBtn.Font = Enum.Font.GothamBold
noclipBtn.TextSize = 8
noclipBtn.Parent = scroll
y = y + 30

-- GOD MODE
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

godModeBtn = Instance.new("TextButton")
godModeBtn.Size = UDim2.new(1, -6, 0, 26)
godModeBtn.Position = UDim2.new(0, 3, 0, y)
godModeBtn.Text = "GOD MODE"
godModeBtn.TextColor3 = Color3.fromRGB(255,255,255)
godModeBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
godModeBtn.Font = Enum.Font.GothamBold
godModeBtn.TextSize = 8
godModeBtn.Parent = scroll
y = y + 30

-- SUPER BRUTAL
local hitTitle = Instance.new("TextLabel")
hitTitle.Size = UDim2.new(1, -6, 0, 16)
hitTitle.Position = UDim2.new(0, 3, 0, y)
hitTitle.Text = "💀 SUPER BRUTAL"
hitTitle.TextColor3 = Color3.fromRGB(255, 0, 0)
hitTitle.BackgroundTransparency = 1
hitTitle.Font = Enum.Font.GothamBold
hitTitle.TextSize = 9
hitTitle.Parent = scroll
y = y + 18

attackBtn = Instance.new("TextButton")
attackBtn.Size = UDim2.new(1, -6, 0, 34)
attackBtn.Position = UDim2.new(0, 3, 0, y)
attackBtn.Text = "⚔️ SERANG SEMUA ⚔️"
attackBtn.TextColor3 = Color3.fromRGB(255,255,255)
attackBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
attackBtn.Font = Enum.Font.GothamBold
attackBtn.TextSize = 9
attackBtn.Parent = scroll
y = y + 38

autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(1, -6, 0, 24)
autoBtn.Position = UDim2.new(0, 3, 0, y)
autoBtn.Text = "AUTO HIT"
autoBtn.TextColor3 = Color3.fromRGB(255,255,255)
autoBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
autoBtn.Font = Enum.Font.GothamBold
autoBtn.TextSize = 8
autoBtn.Parent = scroll
y = y + 28

autoStatus = Instance.new("TextLabel")
autoStatus.Size = UDim2.new(1, -6, 0, 14)
autoStatus.Position = UDim2.new(0, 3, 0, y)
autoStatus.Text = "○ INACTIVE"
autoStatus.TextColor3 = Color3.fromRGB(255,100,100)
autoStatus.BackgroundTransparency = 1
autoStatus.Font = Enum.Font.GothamBold
autoStatus.TextSize = 7
autoStatus.Parent = scroll
y = y + 16

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -6, 0, 28)
infoLabel.Position = UDim2.new(0, 3, 0, y)
infoLabel.Text = "⚡ DAMAGE: 999999\n🌍 RADIUS: INFINITY"
infoLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
infoLabel.BackgroundColor3 = Color3.fromRGB(25,25,35)
infoLabel.BackgroundTransparency = 0
infoLabel.Font = Enum.Font.GothamBold
infoLabel.TextSize = 7
infoLabel.Parent = scroll
y = y + 32

-- MULTI PENDAPATAN
local multiTitle = Instance.new("TextLabel")
multiTitle.Size = UDim2.new(1, -6, 0, 16)
multiTitle.Position = UDim2.new(0, 3, 0, y)
multiTitle.Text = "💰 MULTI PENDAPATAN"
multiTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
multiTitle.BackgroundTransparency = 1
multiTitle.Font = Enum.Font.GothamBold
multiTitle.TextSize = 9
multiTitle.Parent = scroll
y = y + 18

multiIncomeBtn = Instance.new("TextButton")
multiIncomeBtn.Size = UDim2.new(1, -6, 0, 26)
multiIncomeBtn.Position = UDim2.new(0, 3, 0, y)
multiIncomeBtn.Text = "MULTI PENDAPATAN"
multiIncomeBtn.TextColor3 = Color3.fromRGB(255,255,255)
multiIncomeBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
multiIncomeBtn.Font = Enum.Font.GothamBold
multiIncomeBtn.TextSize = 8
multiIncomeBtn.Parent = scroll
y = y + 30

multiplierLabel = Instance.new("TextLabel")
multiplierLabel.Size = UDim2.new(0.5, 0, 0, 22)
multiplierLabel.Position = UDim2.new(0, 3, 0, y)
multiplierLabel.Text = "MULTI: 10x"
multiplierLabel.TextColor3 = Color3.fromRGB(200,200,220)
multiplierLabel.BackgroundTransparency = 1
multiplierLabel.Font = Enum.Font.GothamBold
multiplierLabel.TextSize = 8
multiplierLabel.Parent = scroll

local multiMinus = Instance.new("TextButton")
multiMinus.Size = UDim2.new(0, 18, 0, 18)
multiMinus.Position = UDim2.new(1, -40, 0, y)
multiMinus.Text = "-"
multiMinus.TextColor3 = Color3.fromRGB(255,255,255)
multiMinus.BackgroundColor3 = Color3.fromRGB(55,55,75)
multiMinus.Font = Enum.Font.GothamBold
multiMinus.TextSize = 12
multiMinus.Parent = scroll

local multiPlus = Instance.new("TextButton")
multiPlus.Size = UDim2.new(0, 18, 0, 18)
multiPlus.Position = UDim2.new(1, -20, 0, y)
multiPlus.Text = "+"
multiPlus.TextColor3 = Color3.fromRGB(255,255,255)
multiPlus.BackgroundColor3 = Color3.fromRGB(55,55,75)
multiPlus.Font = Enum.Font.GothamBold
multiPlus.TextSize = 12
multiPlus.Parent = scroll
y = y + 26

local multiInfo = Instance.new("TextLabel")
multiInfo.Size = UDim2.new(1, -6, 0, 28)
multiInfo.Position = UDim2.new(0, 3, 0, y)
multiInfo.Text = "🎯 EXP, GOLD, MONEY, GEMS\n💰 SEMUA PENDAPATAN DI KALI"
multiInfo.TextColor3 = Color3.fromRGB(100, 200, 255)
multiInfo.BackgroundColor3 = Color3.fromRGB(25,25,35)
multiInfo.BackgroundTransparency = 0
multiInfo.Font = Enum.Font.Gotham
multiInfo.TextSize = 7
multiInfo.Parent = scroll
y = y + 32

-- BOOST MENU
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

speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(1, -6, 0, 22)
speedBtn.Position = UDim2.new(0, 3, 0, y)
speedBtn.Text = "SPEED BOOST"
speedBtn.TextColor3 = Color3.fromRGB(255,255,255)
speedBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
speedBtn.Font = Enum.Font.GothamBold
speedBtn.TextSize = 8
speedBtn.Parent = scroll
y = y + 26

speedValLabel = Instance.new("TextLabel")
speedValLabel.Size = UDim2.new(0.5, 0, 0, 20)
speedValLabel.Position = UDim2.new(0, 3, 0, y)
speedValLabel.Text = "SPEED: 200"
speedValLabel.TextColor3 = Color3.fromRGB(200,200,220)
speedValLabel.BackgroundTransparency = 1
speedValLabel.Font = Enum.Font.GothamBold
speedValLabel.TextSize = 8
speedValLabel.Parent = scroll

local speedMinus = Instance.new("TextButton")
speedMinus.Size = UDim2.new(0, 18, 0, 18)
speedMinus.Position = UDim2.new(1, -40, 0, y)
speedMinus.Text = "-"
speedMinus.TextColor3 = Color3.fromRGB(255,255,255)
speedMinus.BackgroundColor3 = Color3.fromRGB(55,55,75)
speedMinus.Font = Enum.Font.GothamBold
speedMinus.TextSize = 12
speedMinus.Parent = scroll

local speedPlus = Instance.new("TextButton")
speedPlus.Size = UDim2.new(0, 18, 0, 18)
speedPlus.Position = UDim2.new(1, -20, 0, y)
speedPlus.Text = "+"
speedPlus.TextColor3 = Color3.fromRGB(255,255,255)
speedPlus.BackgroundColor3 = Color3.fromRGB(55,55,75)
speedPlus.Font = Enum.Font.GothamBold
speedPlus.TextSize = 12
speedPlus.Parent = scroll
y = y + 24

jumpBtn = Instance.new("TextButton")
jumpBtn.Size = UDim2.new(1, -6, 0, 22)
jumpBtn.Position = UDim2.new(0, 3, 0, y)
jumpBtn.Text = "JUMP BOOST"
jumpBtn.TextColor3 = Color3.fromRGB(255,255,255)
jumpBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
jumpBtn.Font = Enum.Font.GothamBold
jumpBtn.TextSize = 8
jumpBtn.Parent = scroll
y = y + 26

jumpValLabel = Instance.new("TextLabel")
jumpValLabel.Size = UDim2.new(0.5, 0, 0, 20)
jumpValLabel.Position = UDim2.new(0, 3, 0, y)
jumpValLabel.Text = "JUMP: 200"
jumpValLabel.TextColor3 = Color3.fromRGB(200,200,220)
jumpValLabel.BackgroundTransparency = 1
jumpValLabel.Font = Enum.Font.GothamBold
jumpValLabel.TextSize = 8
jumpValLabel.Parent = scroll

local jumpMinus = Instance.new("TextButton")
jumpMinus.Size = UDim2.new(0, 18, 0, 18)
jumpMinus.Position = UDim2.new(1, -40, 0, y)
jumpMinus.Text = "-"
jumpMinus.TextColor3 = Color3.fromRGB(255,255,255)
jumpMinus.BackgroundColor3 = Color3.fromRGB(55,55,75)
jumpMinus.Font = Enum.Font.GothamBold
jumpMinus.TextSize = 12
jumpMinus.Parent = scroll

local jumpPlus = Instance.new("TextButton")
jumpPlus.Size = UDim2.new(0, 18, 0, 18)
jumpPlus.Position = UDim2.new(1, -20, 0, y)
jumpPlus.Text = "+"
jumpPlus.TextColor3 = Color3.fromRGB(255,255,255)
jumpPlus.BackgroundColor3 = Color3.fromRGB(55,55,75)
jumpPlus.Font = Enum.Font.GothamBold
jumpPlus.TextSize = 12
jumpPlus.Parent = scroll
y = y + 24

statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -6, 0, 22)
statusText.Position = UDim2.new(0, 3, 0, y)
statusText.Text = "✓ VORTEX READY"
statusText.TextColor3 = Color3.fromRGB(0,255,0)
statusText.BackgroundColor3 = Color3.fromRGB(25,25,35)
statusText.BackgroundTransparency = 0
statusText.Font = Enum.Font.GothamBold
statusText.TextSize = 8
statusText.Parent = scroll
y = y + 26

scroll.CanvasSize = UDim2.new(0, 0, 0, y + 30)

-- ========== CONNECT ==========
masterBtn.MouseButton1Click:Connect(ToggleMaster)
boxBtn.MouseButton1Click:Connect(ToggleBox)
tracerBtn.MouseButton1Click:Connect(ToggleTracer)
nameBtn.MouseButton1Click:Connect(ToggleName)
attackBtn.MouseButton1Click:Connect(ManualAttack)
autoBtn.MouseButton1Click:Connect(ToggleAuto)
speedBtn.MouseButton1Click:Connect(ToggleSpeed)
jumpBtn.MouseButton1Click:Connect(ToggleJump)
noclipBtn.MouseButton1Click:Connect(ToggleNoclip)
godModeBtn.MouseButton1Click:Connect(ToggleGod)
multiIncomeBtn.MouseButton1Click:Connect(ToggleMultiIncome)

thickMinus.MouseButton1Click:Connect(function() UpdateThick(-1) end)
thickPlus.MouseButton1Click:Connect(function() UpdateThick(1) end)
speedMinus.MouseButton1Click:Connect(function() UpdateSpeedVal(-25) end)
speedPlus.MouseButton1Click:Connect(function() UpdateSpeedVal(25) end)
jumpMinus.MouseButton1Click:Connect(function() UpdateJumpVal(-25) end)
jumpPlus.MouseButton1Click:Connect(function() UpdateJumpVal(25) end)
multiMinus.MouseButton1Click:Connect(function() UpdateMultiplier(-1) end)
multiPlus.MouseButton1Click:Connect(function() UpdateMultiplier(1) end)

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
        frame.Size = UDim2.new(0, 170, 0, 520)
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
    StopAutoHit()
    DisableNoclip()
    DisableGodMode()
    DisableMultiIncome()
    gui:Destroy()
    for _, esp in pairs(espObjects) do
        if esp.box then esp.box:Remove() end
        if esp.tracer then esp.tracer:Remove() end
        if esp.nameTag then esp.nameTag:Remove() end
    end
    for _, conn in pairs(espConnections) do
        if conn then conn:Disconnect() end
    end
end)

-- ========== INIT ==========
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.5)
    origSpeed = char.Humanoid.WalkSpeed
    origJump = char.Humanoid.JumpPower
    ApplySpeed()
    ApplyJump()
    if noclipEnabled then EnableNoclip() end
    if godModeEnabled then EnableGodMode() end
    if autoHit then StartAutoHit() end
end)
if LocalPlayer.Character then
    origSpeed = LocalPlayer.Character.Humanoid.WalkSpeed
    origJump = LocalPlayer.Character.Humanoid.JumpPower
end

RunService.RenderStepped:Connect(function()
    -- Update ESP sudah jalan dari masing-masing connection
end)

print("========================")
print("💀 VORTEX FINAL ULTIMATE 💀")
print("✅ ESP BOX WHITE - WORK ALL GAME")
print("✅ KETEBALAN ESP BISA DIATUR (1-5)")
print("✅ WALLHACK + GOD MODE")
print("✅ AUTO HIT (999999 DAMAGE)")
print("💰 MULTI PENDAPATAN (1x-999x)")
print("✅ SCROLL PANJANG")
print("========================")
