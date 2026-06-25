-- ========================================
-- VORTEX - DUAL PANEL MENU (FINAL)
-- HITBOX EXPANDER + ESP HITBOX (TERSENDIRI)
-- TELEPORT DIHAPUS, SPECIAL MENU NORMAL
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
local espLine = false
local espName = false
local espDistance = false
local espThick = 2
local espColor = Color3.fromRGB(155, 0, 255)
local colorIndex = 1
local colors = {
    Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(155, 0, 255)
}
local colorNames = {"Biru", "Merah", "Hijau", "Kuning", "Ungu"}

-- HITBOX (TERSENDIRI)
local espHitbox = false
local hitboxThick = 2
local hitboxExpander = 0
local hitboxExpanderEnabled = false
local hitboxColor = Color3.fromRGB(255, 0, 0)

-- WALLHACK
local noclipEnabled = false
local noclipConnection = nil

-- FLY
local flying = false
local flySpeed = 2.0
local upForce = 0
local downForce = 0
local flyBodyVelocity = nil
local flyBodyGyro = nil
local flyLoop = nil

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

-- ========== FUNGSI ESP ==========
local function CreateESP(player)
    if player == LocalPlayer or espObjects[player] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = espColor
    box.Thickness = espThick
    box.Transparency = 0.5
    box.Filled = false
    
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = espColor
    line.Thickness = espThick
    
    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Color = espColor
    nameTag.Size = 12
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.fromRGB(0,0,0)
    
    local distanceTag = Drawing.new("Text")
    distanceTag.Visible = false
    distanceTag.Color = espColor
    distanceTag.Size = 10
    distanceTag.Center = true
    distanceTag.Outline = true
    distanceTag.OutlineColor = Color3.fromRGB(0,0,0)
    
    -- HITBOX ESP (terpisah, gak perlu Master ESP)
    local hitbox = Drawing.new("Square")
    hitbox.Visible = false
    hitbox.Color = hitboxColor
    hitbox.Thickness = hitboxThick
    hitbox.Transparency = 0.3
    hitbox.Filled = false
    
    espObjects[player] = {
        box = box,
        line = line,
        nameTag = nameTag,
        distanceTag = distanceTag,
        hitbox = hitbox,
        player = player
    }
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        -- HITBOX ESP TIDAK TERGANTUNG MASTER ESP
        if espHitbox then
            local char = player.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            if char and hum and root and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local dist = (root.Position - Camera.CFrame.Position).Magnitude
                    local baseSize = math.clamp(200 / dist, 30, 100)
                    local expandSize = baseSize + (baseSize * hitboxExpander / 100)
                    
                    hitbox.Size = Vector2.new(expandSize, expandSize)
                    hitbox.Position = Vector2.new(pos.X - expandSize / 2, pos.Y - expandSize / 1.2)
                    hitbox.Visible = true
                    hitbox.Color = hitboxColor
                    hitbox.Thickness = hitboxThick
                else
                    hitbox.Visible = false
                end
            else
                hitbox.Visible = false
            end
        else
            hitbox.Visible = false
        end
        
        -- ESP REGULER (TERGANTUNG MASTER ESP)
        if not masterESP then
            if box then box.Visible = false end
            if line then line.Visible = false end
            if nameTag then nameTag.Visible = false end
            if distanceTag then distanceTag.Visible = false end
            return
        end
        
        local char = player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if not char or not hum or not root or hum.Health <= 0 then
            if box then box.Visible = false end
            if line then line.Visible = false end
            if nameTag then nameTag.Visible = false end
            if distanceTag then distanceTag.Visible = false end
            return
        end
        
        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local dist = (root.Position - Camera.CFrame.Position).Magnitude
        local distText = string.format("%.1f m", dist)
        
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
        
        if espLine and line and onScreen then
            line.From = center
            line.To = Vector2.new(pos.X, pos.Y)
            line.Visible = true
            line.Color = espColor
            line.Thickness = espThick
        elseif line then
            line.Visible = false
        end
        
        local nameYOffset = 35
        if espDistance then nameYOffset = 50 end
        
        if espName and nameTag and onScreen then
            nameTag.Text = player.Name
            nameTag.Position = Vector2.new(pos.X, pos.Y - nameYOffset)
            nameTag.Visible = true
            nameTag.Color = espColor
        elseif nameTag then
            nameTag.Visible = false
        end
        
        if espDistance and distanceTag and onScreen then
            distanceTag.Text = distText
            distanceTag.Position = Vector2.new(pos.X, pos.Y - 20)
            distanceTag.Visible = true
            distanceTag.Color = espColor
        elseif distanceTag then
            distanceTag.Visible = false
        end
    end)
    
    espConnections[player] = connection
    
    player.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if box then box:Remove() end
            if line then line:Remove() end
            if nameTag then nameTag:Remove() end
            if distanceTag then distanceTag:Remove() end
            if hitbox then hitbox:Remove() end
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
        if esp.line then esp.line:Remove() end
        if esp.nameTag then esp.nameTag:Remove() end
        if esp.distanceTag then esp.distanceTag:Remove() end
        if esp.hitbox then esp.hitbox:Remove() end
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
        if esp.line then
            esp.line.Color = espColor
            esp.line.Thickness = espThick
        end
        if esp.nameTag then
            esp.nameTag.Color = espColor
        end
        if esp.distanceTag then
            esp.distanceTag.Color = espColor
        end
        if esp.hitbox then
            esp.hitbox.Color = hitboxColor
            esp.hitbox.Thickness = hitboxThick
        end
    end
end

-- ========== HITBOX EXPANDER ==========
local function ExpandHitbox()
    if not hitboxExpanderEnabled then return end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum then
                local scale = 1 + (hitboxExpander / 100)
                p.Character.Scale = scale
            end
        end
    end
end

local function ResetHitbox()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            p.Character.Scale = 1
        end
    end
end

local function ToggleHitboxExpander()
    hitboxExpanderEnabled = not hitboxExpanderEnabled
    if hitboxExpanderEnabled then
        hitboxExpanderBtn.Text = "Hitbox Expander [ON]"
        hitboxExpanderBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
        ExpandHitbox()
    else
        hitboxExpanderBtn.Text = "Hitbox Expander [OFF]"
        hitboxExpanderBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
        ResetHitbox()
    end
end

local function UpdateHitboxExpand(val)
    hitboxExpander = math.max(0, math.min(100, hitboxExpander + val))
    expanderLabel.Text = "Expand: "..hitboxExpander.."%"
    if hitboxExpanderEnabled then
        ExpandHitbox()
    end
end

local function ToggleHitboxESP()
    espHitbox = not espHitbox
    if espHitbox then
        hitboxBtn.Text = "Hitbox ESP [ON]"
        hitboxBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
    else
        hitboxBtn.Text = "Hitbox ESP [OFF]"
        hitboxBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
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

local function ToggleWallhack()
    noclipEnabled = not noclipEnabled
    if noclipEnabled then
        EnableNoclip()
        wallhackBtn.Text = "Wallhack [ON]"
        wallhackBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
    else
        DisableNoclip()
        wallhackBtn.Text = "Wallhack [OFF]"
        wallhackBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
    end
end

-- ========== FLY ==========
local function StartFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return end
    
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    if flyBodyGyro then flyBodyGyro:Destroy() end
    if flyLoop then flyLoop:Disconnect() end
    
    flyBodyVelocity = Instance.new("BodyVelocity", root)
    flyBodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    
    flyBodyGyro = Instance.new("BodyGyro", root)
    flyBodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    flyBodyGyro.P = 10000
    
    flyLoop = RunService.Stepped:Connect(function()
        if not flying or not char or not root then return end
        
        local moveDir = hum.MoveDirection
        local localMove = Camera.CFrame:VectorToObjectSpace(moveDir)
        local vertical = Vector3.new(0, upForce + downForce, 0)
        local finalDir = (Camera.CFrame.LookVector * -localMove.Z) + (Camera.CFrame.RightVector * localMove.X) + vertical
        
        flyBodyVelocity.Velocity = finalDir * (flySpeed * 20)
        flyBodyGyro.CFrame = Camera.CFrame
        hum:ChangeState(Enum.HumanoidStateType.Swimming)
    end)
end

local function StopFly()
    if flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
    if flyBodyGyro then
        flyBodyGyro:Destroy()
        flyBodyGyro = nil
    end
    if flyLoop then
        flyLoop:Disconnect()
        flyLoop = nil
    end
    
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end

local function ToggleFly()
    flying = not flying
    if flying then
        flyBtn.Text = "Fly [ON]"
        flyBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
        StartFly()
    else
        flyBtn.Text = "Fly [OFF]"
        flyBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
        StopFly()
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

local function ToggleMultiIncome()
    multiIncomeEnabled = not multiIncomeEnabled
    if multiIncomeEnabled then
        EnableMultiIncome()
        multiIncomeBtn.Text = "Multi Pendapatan [ON]"
        multiIncomeBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
        statusText.Text = "Multi Pendapatan "..incomeMultiplier.."x Aktif"
    else
        DisableMultiIncome()
        multiIncomeBtn.Text = "Multi Pendapatan [OFF]"
        multiIncomeBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
        statusText.Text = "Multi Pendapatan Mati"
    end
    statusText.TextColor3 = Color3.fromRGB(0,255,0)
    task.wait(0.5)
    statusText.Text = "Ready"
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
    speedBtn.Text = speedBoost and "Speed Boost [ON]" or "Speed Boost [OFF]"
    speedBtn.BackgroundColor3 = speedBoost and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
    ApplySpeed()
end

local function ToggleJump()
    jumpBoost = not jumpBoost
    jumpBtn.Text = jumpBoost and "Jump Boost [ON]" or "Jump Boost [OFF]"
    jumpBtn.BackgroundColor3 = jumpBoost and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
    ApplyJump()
end

-- ========== SLIDER ==========
local function UpdateThick(val)
    espThick = math.max(1, math.min(5, espThick + val))
    thickVal.Text = tostring(espThick)
    RefreshESP()
end

local function UpdateMultiplier(val)
    local newVal = incomeMultiplier + val
    if newVal >= 1 and newVal <= 999 then
        incomeMultiplier = newVal
        multiVal.Text = tostring(incomeMultiplier) .. "x"
        if multiIncomeEnabled then
            statusText.Text = "Multiplier: "..incomeMultiplier.."x"
            task.wait(0.5)
            statusText.Text = "Ready"
        end
    end
end

local function UpdateSpeedVal(val)
    speedValue = math.max(25, math.min(999, speedValue + val))
    speedVal.Text = tostring(speedValue)
    ApplySpeed()
end

local function UpdateJumpVal(val)
    jumpValue = math.max(50, math.min(999, jumpValue + val))
    jumpVal.Text = tostring(jumpValue)
    ApplyJump()
end

local function UpdateFlySpeed(val)
    flySpeed = math.max(0.5, math.min(10, flySpeed + val))
    flySpeedVal.Text = string.format("%.1f", flySpeed)
end

-- ========== FLY UP/DOWN ==========
local function FlyUp()
    upForce = 1
end

local function FlyUpRelease()
    upForce = 0
end

local function FlyDown()
    downForce = -1
end

local function FlyDownRelease()
    downForce = 0
end

-- ========== GUI ==========
local gui = Instance.new("ScreenGui")
gui.Name = "VortexDual"
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
rightScroll.CanvasSize = UDim2.new(0, 0, 0, 1300)
rightScroll.ScrollBarThickness = 2
rightScroll.ScrollBarImageColor3 = Color3.fromRGB(155, 0, 255)
rightScroll.Parent = frame

-- ===== KIRI: ISI KATEGORI =====
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

-- ===== KANAN: ISI MENU =====
local ry = 5
local currentCategory = "ESP MENU"

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
    AddSeparator("ESP MENU")
    masterBtn = AddToggle("Master ESP", masterESP, function() 
        masterESP = not masterESP
        masterBtn.Text = masterESP and "Master ESP [ON]" or "Master ESP [OFF]"
        masterBtn.BackgroundColor3 = masterESP and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
    end)
    nameBtn = AddToggle("Name ESP", espName, function() 
        espName = not espName
        nameBtn.Text = espName and "Name ESP [ON]" or "Name ESP [OFF]"
        nameBtn.BackgroundColor3 = espName and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
    end)
    lineBtn = AddToggle("Line ESP", espLine, function() 
        espLine = not espLine
        lineBtn.Text = espLine and "Line ESP [ON]" or "Line ESP [OFF]"
        lineBtn.BackgroundColor3 = espLine and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
    end)
    boxBtn = AddToggle("Box ESP", espBox, function() 
        espBox = not espBox
        boxBtn.Text = espBox and "Box ESP [ON]" or "Box ESP [OFF]"
        boxBtn.BackgroundColor3 = espBox and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
    end)
    distBtn = AddToggle("Distance ESP", espDistance, function() 
        espDistance = not espDistance
        distBtn.Text = espDistance and "Distance ESP [ON]" or "Distance ESP [OFF]"
        distBtn.BackgroundColor3 = espDistance and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
    end)
    
    AddSeparator("WARNA & KETEBALAN")
    
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
    
    colorLabel = Instance.new("TextLabel")
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
        colorIndex = colorIndex - 1
        if colorIndex < 1 then colorIndex = #colors end
        espColor = colors[colorIndex]
        colorLabel.Text = "Warna: " .. colorNames[colorIndex]
        RefreshESP()
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
        colorIndex = colorIndex % #colors + 1
        espColor = colors[colorIndex]
        colorLabel.Text = "Warna: " .. colorNames[colorIndex]
        RefreshESP()
    end)
    ry = ry + 32
    
    thickVal = AddSlider("Ketebalan", espThick, 1, 5, function(val)
        espThick = val
        RefreshESP()
    end)
    ry = ry + 5
    
    rightScroll.CanvasSize = UDim2.new(0, 0, 0, ry + 30)
end

local function BuildSpecialContent()
    ry = 5
    AddSeparator("SPECIAL MENU")
    
    -- WALLHACK
    wallhackBtn = AddToggle("Wallhack", noclipEnabled, function() 
        noclipEnabled = not noclipEnabled
        if noclipEnabled then
            EnableNoclip()
            wallhackBtn.Text = "Wallhack [ON]"
            wallhackBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
        else
            DisableNoclip()
            wallhackBtn.Text = "Wallhack [OFF]"
            wallhackBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
        end
    end)
    
    AddSeparator("FLY")
    flyBtn = AddToggle("Fly", flying, function() 
        flying = not flying
        if flying then
            flyBtn.Text = "Fly [ON]"
            flyBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
            StartFly()
        else
            flyBtn.Text = "Fly [OFF]"
            flyBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
            StopFly()
        end
    end)
    
    local upBtn = Instance.new("TextButton")
    upBtn.Size = UDim2.new(0.45, -4, 0, 24)
    upBtn.Position = UDim2.new(0, 3, 0, ry)
    upBtn.Text = "UP"
    upBtn.TextColor3 = Color3.fromRGB(255,255,255)
    upBtn.BackgroundColor3 = Color3.fromRGB(0,100,200)
    upBtn.Font = Enum.Font.GothamBold
    upBtn.TextSize = 10
    upBtn.Parent = rightScroll
    upBtn.MouseButton1Down:Connect(function() upForce = 1 end)
    upBtn.MouseButton1Up:Connect(function() upForce = 0 end)
    upBtn.InputEnded:Connect(function() upForce = 0 end)
    
    local dnBtn = Instance.new("TextButton")
    dnBtn.Size = UDim2.new(0.45, -4, 0, 24)
    dnBtn.Position = UDim2.new(0.55, 0, 0, ry)
    dnBtn.Text = "DN"
    dnBtn.TextColor3 = Color3.fromRGB(255,255,255)
    dnBtn.BackgroundColor3 = Color3.fromRGB(200,100,0)
    dnBtn.Font = Enum.Font.GothamBold
    dnBtn.TextSize = 10
    dnBtn.Parent = rightScroll
    dnBtn.MouseButton1Down:Connect(function() downForce = -1 end)
    dnBtn.MouseButton1Up:Connect(function() downForce = 0 end)
    dnBtn.InputEnded:Connect(function() downForce = 0 end)
    ry = ry + 28
    
    flySpeedVal = AddSlider("Kecepatan Fly", flySpeed, 0.5, 10, function(val)
        flySpeed = val
    end)
    ry = ry + 5
    
    rightScroll.CanvasSize = UDim2.new(0, 0, 0, ry + 30)
end

local function BuildPlayerContent()
    ry = 5
    AddSeparator("PLAYER MENU")
    
    speedBtn = AddToggle("Speed Boost", speedBoost, function() 
        speedBoost = not speedBoost
        speedBtn.Text = speedBoost and "Speed Boost [ON]" or "Speed Boost [OFF]"
        speedBtn.BackgroundColor3 = speedBoost and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
        ApplySpeed()
    end)
    speedVal = AddSlider("Speed Value", speedValue, 25, 999, function(val)
        speedValue = val
        ApplySpeed()
    end)
    ry = ry + 5
    
    jumpBtn = AddToggle("Jump Boost", jumpBoost, function() 
        jumpBoost = not jumpBoost
        jumpBtn.Text = jumpBoost and "Jump Boost [ON]" or "Jump Boost [OFF]"
        jumpBtn.BackgroundColor3 = jumpBoost and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
        ApplyJump()
    end)
    jumpVal = AddSlider("Jump Value", jumpValue, 50, 999, function(val)
        jumpValue = val
        ApplyJump()
    end)
    ry = ry + 5
    
    AddSeparator("HITBOX EXPANDER")
    
    -- Hitbox Expander Toggle
    hitboxExpanderBtn = AddToggle("Hitbox Expander", hitboxExpanderEnabled, function() 
        hitboxExpanderEnabled = not hitboxExpanderEnabled
        if hitboxExpanderEnabled then
            hitboxExpanderBtn.Text = "Hitbox Expander [ON]"
            hitboxExpanderBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
            ExpandHitbox()
        else
            hitboxExpanderBtn.Text = "Hitbox Expander [OFF]"
            hitboxExpanderBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
            ResetHitbox()
        end
    end)
    
    -- Expander Slider (0-100%)
    expanderLabel = Instance.new("TextLabel")
    expanderLabel.Size = UDim2.new(0.5, 0, 0, 20)
    expanderLabel.Position = UDim2.new(0, 3, 0, ry)
    expanderLabel.Text = "Expand: 0%"
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
        hitboxExpander = math.max(0, hitboxExpander - 5)
        expanderLabel.Text = "Expand: "..hitboxExpander.."%"
        if hitboxExpanderEnabled then ExpandHitbox() end
    end)
    expanderPlus.MouseButton1Click:Connect(function() 
        hitboxExpander = math.min(100, hitboxExpander + 5)
        expanderLabel.Text = "Expand: "..hitboxExpander.."%"
        if hitboxExpanderEnabled then ExpandHitbox() end
    end)
    ry = ry + 24
    
    AddSeparator("HITBOX ESP")
    
    -- Hitbox ESP Toggle (terpisah dari Box ESP, gak perlu Master ESP)
    hitboxBtn = AddToggle("Hitbox ESP", espHitbox, function() 
        espHitbox = not espHitbox
        if espHitbox then
            hitboxBtn.Text = "Hitbox ESP [ON]"
            hitboxBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
        else
            hitboxBtn.Text = "Hitbox ESP [OFF]"
            hitboxBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
        end
    end)
    
    -- Hitbox Ketebalan
    hitboxThickVal = AddSlider("Hitbox Tebal", hitboxThick, 1, 5, function(val)
        hitboxThick = val
        RefreshESP()
    end)
    ry = ry + 5
    
    rightScroll.CanvasSize = UDim2.new(0, 0, 0, ry + 30)
end

local function BuildBetaContent()
    ry = 5
    AddSeparator("BETA TEST")
    multiIncomeBtn = AddToggle("Multi Pendapatan", multiIncomeEnabled, function() 
        multiIncomeEnabled = not multiIncomeEnabled
        if multiIncomeEnabled then
            EnableMultiIncome()
            multiIncomeBtn.Text = "Multi Pendapatan [ON]"
            multiIncomeBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
            statusText.Text = "Multi Pendapatan "..incomeMultiplier.."x Aktif"
        else
            DisableMultiIncome()
            multiIncomeBtn.Text = "Multi Pendapatan [OFF]"
            multiIncomeBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
            statusText.Text = "Multi Pendapatan Mati"
        end
        statusText.TextColor3 = Color3.fromRGB(0,255,0)
        task.wait(0.5)
        statusText.Text = "Ready"
    end)
    multiVal = AddSlider("Multiplier", incomeMultiplier, 1, 999, function(val)
        incomeMultiplier = val
        if multiIncomeEnabled then
            statusText.Text = "Multiplier: "..incomeMultiplier.."x"
            task.wait(0.5)
            statusText.Text = "Ready"
        end
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
    statusText.Text = "Kategori: " .. cat
    statusText.TextColor3 = Color3.fromRGB(0,255,255)
    task.wait(0.3)
    statusText.Text = "Ready"
    statusText.TextColor3 = Color3.fromRGB(0,255,0)
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

-- ========== CLOSE ==========
closeBtn.MouseButton1Click:Connect(function()
    DisableNoclip()
    DisableMultiIncome()
    StopFly()
    ResetHitbox()
    gui:Destroy()
    for _, esp in pairs(espObjects) do
        if esp.box then esp.box:Remove() end
        if esp.line then esp.line:Remove() end
        if esp.nameTag then esp.nameTag:Remove() end
        if esp.distanceTag then esp.distanceTag:Remove() end
        if esp.hitbox then esp.hitbox:Remove() end
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
end)
if LocalPlayer.Character then
    origSpeed = LocalPlayer.Character.Humanoid.WalkSpeed
    origJump = LocalPlayer.Character.Humanoid.JumpPower
end

task.wait(0.1)
SwitchCategory("ESP MENU")

print("========================")
print("VORTEX - HITBOX EXPANDER + ESP HITBOX")
print("HITBOX ESP TERSENDIRI (GAK PERLU MASTER ESP)")
print("========================")
