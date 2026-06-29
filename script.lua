-- ========================================
-- VORTEX FINAL - ALL IN ONE
-- FITUR: ESP PLAYER + ENTITY, WALLHACK, FLY, SPEED, JUMP
-- TANPA MULTI PENDAPATAN & HITBOX EXPANDER
-- ========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ========== VARIABEL ==========
-- ESP PLAYER
local masterESP = false
local espBox = false
local espTracer = false
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

-- ESP ENTITY (NPC, MONSTER, PET)
local espEntity = false
local espEntityBox = false
local espEntityName = false
local espEntityDistance = false
local espEntityColor = Color3.fromRGB(255, 100, 0)
local espEntityThick = 2
local entityColors = {
    Color3.fromRGB(255, 100, 0),
    Color3.fromRGB(0, 255, 255),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(255, 0, 255)
}
local entityColorNames = {"Orange", "Cyan", "Kuning", "Hijau", "Pink"}
local eColorIndex = 1

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

-- SPEED JUMP
local speedBoost = false
local speedValue = 200
local jumpBoost = false
local jumpValue = 200

-- STORAGE
local espObjects = {}
local espConnections = {}
local entityEspObjects = {}
local origSpeed = 16
local origJump = 50

-- ========== FUNGSI ESP PLAYER ==========
local function CreateESP(player)
    if player == LocalPlayer or espObjects[player] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = espColor
    box.Thickness = espThick
    box.Transparency = 0.5
    box.Filled = false
    
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
    
    local distanceTag = Drawing.new("Text")
    distanceTag.Visible = false
    distanceTag.Color = espColor
    distanceTag.Size = 10
    distanceTag.Center = true
    distanceTag.Outline = true
    distanceTag.OutlineColor = Color3.fromRGB(0,0,0)
    
    espObjects[player] = {
        box = box,
        tracer = tracer,
        nameTag = nameTag,
        distanceTag = distanceTag,
        player = player
    }
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not masterESP then
            if box then box.Visible = false end
            if tracer then tracer.Visible = false end
            if nameTag then nameTag.Visible = false end
            if distanceTag then distanceTag.Visible = false end
            return
        end
        
        local char = player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if not char or not hum or not root or hum.Health <= 0 then
            if box then box.Visible = false end
            if tracer then tracer.Visible = false end
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
        
        if espTracer and tracer and onScreen then
            tracer.From = center
            tracer.To = Vector2.new(pos.X, pos.Y)
            tracer.Visible = true
            tracer.Color = espColor
            tracer.Thickness = espThick
        elseif tracer then
            tracer.Visible = false
        end
        
        if espName and nameTag and onScreen then
            nameTag.Text = player.Name
            nameTag.Position = Vector2.new(pos.X, pos.Y - 35)
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
            if tracer then tracer:Remove() end
            if nameTag then nameTag:Remove() end
            if distanceTag then distanceTag:Remove() end
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
        if esp.distanceTag then esp.distanceTag:Remove() end
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
        if esp.distanceTag then
            esp.distanceTag.Color = espColor
        end
    end
    for _, esp in pairs(entityEspObjects) do
        if esp.box then
            esp.box.Color = espEntityColor
            esp.box.Thickness = espEntityThick
        end
        if esp.nameTag then
            esp.nameTag.Color = espEntityColor
        end
        if esp.distanceTag then
            esp.distanceTag.Color = espEntityColor
        end
    end
end

-- ========== FUNGSI ESP ENTITY ==========
local function CreateEntityESP(entity)
    if entity == LocalPlayer.Character then return end
    if entity:FindFirstChild("Humanoid") == nil then return end
    if entityEspObjects[entity] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = espEntityColor
    box.Thickness = espEntityThick
    box.Transparency = 0.5
    box.Filled = false
    
    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Color = espEntityColor
    nameTag.Size = 10
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.fromRGB(0,0,0)
    
    local distanceTag = Drawing.new("Text")
    distanceTag.Visible = false
    distanceTag.Color = espEntityColor
    distanceTag.Size = 10
    distanceTag.Center = true
    distanceTag.Outline = true
    distanceTag.OutlineColor = Color3.fromRGB(0,0,0)
    
    entityEspObjects[entity] = {
        box = box,
        nameTag = nameTag,
        distanceTag = distanceTag,
        entity = entity
    }
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not espEntity then
            if box then box.Visible = false end
            if nameTag then nameTag.Visible = false end
            if distanceTag then distanceTag.Visible = false end
            return
        end
        
        local hum = entity:FindFirstChild("Humanoid")
        local root = entity:FindFirstChild("HumanoidRootPart") or entity:FindFirstChild("Head")
        
        if not hum or not root or hum.Health <= 0 then
            if box then box.Visible = false end
            if nameTag then nameTag.Visible = false end
            if distanceTag then distanceTag.Visible = false end
            return
        end
        
        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
        local dist = (root.Position - Camera.CFrame.Position).Magnitude
        local distText = string.format("%.1f m", dist)
        
        if espEntityBox and box and onScreen then
            local top = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 2.5, 0))
            local bottom = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, -3, 0))
            local sizeY = math.abs(top.Y - bottom.Y)
            local sizeX = sizeY * 0.6
            
            box.Size = Vector2.new(sizeX, sizeY)
            box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
            box.Visible = true
            box.Color = espEntityColor
            box.Thickness = espEntityThick
        elseif box then
            box.Visible = false
        end
        
        if espEntityName and nameTag and onScreen then
            nameTag.Text = entity.Name or "Entity"
            nameTag.Position = Vector2.new(pos.X, pos.Y - 25)
            nameTag.Visible = true
            nameTag.Color = espEntityColor
        elseif nameTag then
            nameTag.Visible = false
        end
        
        if espEntityDistance and distanceTag and onScreen then
            distanceTag.Text = distText
            distanceTag.Position = Vector2.new(pos.X, pos.Y - 12)
            distanceTag.Visible = true
            distanceTag.Color = espEntityColor
        elseif distanceTag then
            distanceTag.Visible = false
        end
    end)
    
    entity:AncestryChanged:Connect(function(_, parent)
        if not parent then
            if box then box:Remove() end
            if nameTag then nameTag:Remove() end
            if distanceTag then distanceTag:Remove() end
            entityEspObjects[entity] = nil
            connection:Disconnect()
        end
    end)
end

local function ScanEntities()
    for _, esp in pairs(entityEspObjects) do
        if esp.box then esp.box:Remove() end
        if esp.nameTag then esp.nameTag:Remove() end
        if esp.distanceTag then esp.distanceTag:Remove() end
    end
    entityEspObjects = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= LocalPlayer.Character then
            local hum = obj:FindFirstChild("Humanoid")
            if hum then
                CreateEntityESP(obj)
            end
        end
    end
end

-- Auto scan entity baru
workspace.DescendantAdded:Connect(function(desc)
    if espEntity then
        if desc:IsA("Model") and desc ~= LocalPlayer.Character then
            local hum = desc:FindFirstChild("Humanoid")
            if hum then
                CreateEntityESP(desc)
            end
        end
    end
end)

workspace.DescendantRemoving:Connect(function(desc)
    if entityEspObjects[desc] then
        local esp = entityEspObjects[desc]
        if esp.box then esp.box:Remove() end
        if esp.nameTag then esp.nameTag:Remove() end
        if esp.distanceTag then esp.distanceTag:Remove() end
        entityEspObjects[desc] = nil
    end
end)

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
    masterBtn.Text = masterESP and "Master ESP [ON]" or "Master ESP [OFF]"
    masterBtn.BackgroundColor3 = masterESP and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
end

local function ToggleBox()
    espBox = not espBox
    boxBtn.Text = espBox and "Box ESP [ON]" or "Box ESP [OFF]"
    boxBtn.BackgroundColor3 = espBox and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
end

local function ToggleTracer()
    espTracer = not espTracer
    tracerBtn.Text = espTracer and "Tracer ESP [ON]" or "Tracer ESP [OFF]"
    tracerBtn.BackgroundColor3 = espTracer and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
end

local function ToggleName()
    espName = not espName
    nameBtn.Text = espName and "Name ESP [ON]" or "Name ESP [OFF]"
    nameBtn.BackgroundColor3 = espName and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
end

local function ToggleDistance()
    espDistance = not espDistance
    distBtn.Text = espDistance and "Distance ESP [ON]" or "Distance ESP [OFF]"
    distBtn.BackgroundColor3 = espDistance and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
end

local function ToggleEntityESP()
    espEntity = not espEntity
    if espEntity then
        entityBtn.Text = "Entity ESP [ON]"
        entityBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
        ScanEntities()
    else
        entityBtn.Text = "Entity ESP [OFF]"
        entityBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
        for _, esp in pairs(entityEspObjects) do
            if esp.box then esp.box:Remove() end
            if esp.nameTag then esp.nameTag:Remove() end
            if esp.distanceTag then esp.distanceTag:Remove() end
        end
        entityEspObjects = {}
    end
end

local function ToggleEntityBox()
    espEntityBox = not espEntityBox
    entityBoxBtn.Text = espEntityBox and "Entity Box [ON]" or "Entity Box [OFF]"
    entityBoxBtn.BackgroundColor3 = espEntityBox and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
end

local function ToggleEntityName()
    espEntityName = not espEntityName
    entityNameBtn.Text = espEntityName and "Entity Name [ON]" or "Entity Name [OFF]"
    entityNameBtn.BackgroundColor3 = espEntityName and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
end

local function ToggleEntityDistance()
    espEntityDistance = not espEntityDistance
    entityDistBtn.Text = espEntityDistance and "Entity Dist [ON]" or "Entity Dist [OFF]"
    entityDistBtn.BackgroundColor3 = espEntityDistance and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
end

local function UpdateThick(val)
    espThick = math.max(1, math.min(5, espThick + val))
    thickVal.Text = tostring(espThick)
    RefreshESP()
end

local function UpdateEntityThick(val)
    espEntityThick = math.max(1, math.min(5, espEntityThick + val))
    entityThickVal.Text = tostring(espEntityThick)
    RefreshESP()
end

local function NextColor()
    colorIndex = colorIndex % #colors + 1
    espColor = colors[colorIndex]
    colorLabel.Text = "Warna: " .. colorNames[colorIndex]
    RefreshESP()
end

local function PrevColor()
    colorIndex = colorIndex - 1
    if colorIndex < 1 then colorIndex = #colors end
    espColor = colors[colorIndex]
    colorLabel.Text = "Warna: " .. colorNames[colorIndex]
    RefreshESP()
end

local function NextEntityColor()
    eColorIndex = eColorIndex % #entityColors + 1
    espEntityColor = entityColors[eColorIndex]
    eColorLabel.Text = "Warna Entity: " .. entityColorNames[eColorIndex]
    RefreshESP()
end

local function PrevEntityColor()
    eColorIndex = eColorIndex - 1
    if eColorIndex < 1 then eColorIndex = #entityColors end
    espEntityColor = entityColors[eColorIndex]
    eColorLabel.Text = "Warna Entity: " .. entityColorNames[eColorIndex]
    RefreshESP()
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

local function UpdateFlySpeed(val)
    flySpeed = math.max(0.5, math.min(10, flySpeed + val))
    flySpeedVal.Text = string.format("%.1f", flySpeed)
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

local function UpdateSpeedVal(val)
    speedValue = math.max(25, math.min(999, speedValue + val))
    speedValLabel.Text = "Speed: "..speedValue
    ApplySpeed()
end

local function UpdateJumpVal(val)
    jumpValue = math.max(50, math.min(999, jumpValue + val))
    jumpValLabel.Text = "Jump: "..jumpValue
    ApplyJump()
end

-- ========== BUAT GUI ==========
local gui = Instance.new("ScreenGui")
gui.Name = "Vortex"
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

-- KIRI: KATEGORI
local leftScroll = Instance.new("ScrollingFrame")
leftScroll.Size = UDim2.new(0.3, -6, 1, -42)
leftScroll.Position = UDim2.new(0, 3, 0, 35)
leftScroll.BackgroundTransparency = 1
leftScroll.CanvasSize = UDim2.new(0, 0, 0, 350)
leftScroll.ScrollBarThickness = 2
leftScroll.ScrollBarImageColor3 = Color3.fromRGB(155, 0, 255)
leftScroll.Parent = frame

-- KANAN: ISI
local rightScroll = Instance.new("ScrollingFrame")
rightScroll.Size = UDim2.new(0.7, -8, 1, -42)
rightScroll.Position = UDim2.new(0.3, 5, 0, 35)
rightScroll.BackgroundTransparency = 1
rightScroll.CanvasSize = UDim2.new(0, 0, 0, 1500)
rightScroll.ScrollBarThickness = 2
rightScroll.ScrollBarImageColor3 = Color3.fromRGB(155, 0, 255)
rightScroll.Parent = frame

-- KATEGORI
local ly = 5
local categories = {"ESP MENU", "SPECIAL MENU", "PLAYER MENU"}
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

-- ===== BUILD MENU =====
local ry = 5
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
    masterBtn = AddToggle("Master ESP", masterESP, ToggleMaster)
    boxBtn = AddToggle("Box ESP", espBox, ToggleBox)
    tracerBtn = AddToggle("Tracer ESP", espTracer, ToggleTracer)
    nameBtn = AddToggle("Name ESP", espName, ToggleName)
    distBtn = AddToggle("Distance ESP", espDistance, ToggleDistance)
    
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
    colorLeft.MouseButton1Click:Connect(PrevColor)
    
    local colorRight = Instance.new("TextButton")
    colorRight.Size = UDim2.new(0, 18, 0, 18)
    colorRight.Position = UDim2.new(1, -20, 0.5, -9)
    colorRight.Text = ">"
    colorRight.TextColor3 = Color3.fromRGB(255,255,255)
    colorRight.BackgroundColor3 = Color3.fromRGB(55,55,75)
    colorRight.Font = Enum.Font.GothamBold
    colorRight.TextSize = 10
    colorRight.Parent = colorFrame
    colorRight.MouseButton1Click:Connect(NextColor)
    ry = ry + 32
    
    thickVal = AddSlider("Ketebalan", espThick, 1, 5, UpdateThick)
    ry = ry + 5
    
    AddSeparator("ESP ENTITY (NPC, MONSTER, PET)")
    entityBtn = AddToggle("Entity ESP", espEntity, ToggleEntityESP)
    entityBoxBtn = AddToggle("Entity Box", espEntityBox, ToggleEntityBox)
    entityNameBtn = AddToggle("Entity Name", espEntityName, ToggleEntityName)
    entityDistBtn = AddToggle("Entity Dist", espEntityDistance, ToggleEntityDistance)
    
    AddSeparator("ENTITY WARNA & KETEBALAN")
    
    local eColorFrame = Instance.new("Frame")
    eColorFrame.Size = UDim2.new(1, -6, 0, 28)
    eColorFrame.Position = UDim2.new(0, 3, 0, ry)
    eColorFrame.BackgroundColor3 = Color3.fromRGB(30,30,42)
    eColorFrame.BackgroundTransparency = 0
    eColorFrame.BorderSizePixel = 0
    eColorFrame.Parent = rightScroll
    local ecCorner = Instance.new("UICorner")
    ecCorner.CornerRadius = UDim.new(0, 4)
    ecCorner.Parent = eColorFrame
    
    eColorLabel = Instance.new("TextLabel")
    eColorLabel.Size = UDim2.new(0.5, 0, 1, 0)
    eColorLabel.Position = UDim2.new(0, 6, 0, 0)
    eColorLabel.Text = "Warna Entity: Orange"
    eColorLabel.TextColor3 = Color3.fromRGB(200,200,220)
    eColorLabel.BackgroundTransparency = 1
    eColorLabel.Font = Enum.Font.GothamBold
    eColorLabel.TextSize = 8
    eColorLabel.Parent = eColorFrame
    
    local eColorLeft = Instance.new("TextButton")
    eColorLeft.Size = UDim2.new(0, 18, 0, 18)
    eColorLeft.Position = UDim2.new(1, -40, 0.5, -9)
    eColorLeft.Text = "<"
    eColorLeft.TextColor3 = Color3.fromRGB(255,255,255)
    eColorLeft.BackgroundColor3 = Color3.fromRGB(55,55,75)
    eColorLeft.Font = Enum.Font.GothamBold
    eColorLeft.TextSize = 10
    eColorLeft.Parent = eColorFrame
    eColorLeft.MouseButton1Click:Connect(PrevEntityColor)
    
    local eColorRight = Instance.new("TextButton")
    eColorRight.Size = UDim2.new(0, 18, 0, 18)
    eColorRight.Position = UDim2.new(1, -20, 0.5, -9)
    eColorRight.Text = ">"
    eColorRight.TextColor3 = Color3.fromRGB(255,255,255)
    eColorRight.BackgroundColor3 = Color3.fromRGB(55,55,75)
    eColorRight.Font = Enum.Font.GothamBold
    eColorRight.TextSize = 10
    eColorRight.Parent = eColorFrame
    eColorRight.MouseButton1Click:Connect(NextEntityColor)
    ry = ry + 32
    
    entityThickVal = AddSlider("Entity Tebal", espEntityThick, 1, 5, UpdateEntityThick)
    ry = ry + 5
    
    rightScroll.CanvasSize = UDim2.new(0, 0, 0, ry + 30)
end

local function BuildSpecialContent()
    ry = 5
    AddSeparator("SPECIAL MENU")
    wallhackBtn = AddToggle("Wallhack", noclipEnabled, ToggleWallhack)
    
    AddSeparator("FLY")
    flyBtn = AddToggle("Fly", flying, ToggleFly)
    
    local upBtn = Instance.new("TextButton")
    upBtn.Size = UDim2.new(0.45, -4, 0, 24)
    upBtn.Position = UDim2.new(0, 3, 0, ry)
    upBtn.Text = "UP"
    upBtn.TextColor3 = Color3.fromRGB(255,255,255)
    upBtn.BackgroundColor3 = Color3.fromRGB(0,100,200)
    upBtn.Font = Enum.Font.GothamBold
    upBtn.TextSize = 10
    upBtn.Parent = rightScroll
    upBtn.MouseButton1Down:Connect(FlyUp)
    upBtn.MouseButton1Up:Connect(FlyUpRelease)
    upBtn.InputEnded:Connect(FlyUpRelease)
    
    local dnBtn = Instance.new("TextButton")
    dnBtn.Size = UDim2.new(0.45, -4, 0, 24)
    dnBtn.Position = UDim2.new(0.55, 0, 0, ry)
    dnBtn.Text = "DN"
    dnBtn.TextColor3 = Color3.fromRGB(255,255,255)
    dnBtn.BackgroundColor3 = Color3.fromRGB(200,100,0)
    dnBtn.Font = Enum.Font.GothamBold
    dnBtn.TextSize = 10
    dnBtn.Parent = rightScroll
    dnBtn.MouseButton1Down:Connect(FlyDown)
    dnBtn.MouseButton1Up:Connect(FlyDownRelease)
    dnBtn.InputEnded:Connect(FlyDownRelease)
    ry = ry + 28
    
    flySpeedVal = AddSlider("Kecepatan Fly", flySpeed, 0.5, 10, UpdateFlySpeed)
    ry = ry + 5
    
    rightScroll.CanvasSize = UDim2.new(0, 0, 0, ry + 30)
end

local function BuildPlayerContent()
    ry = 5
    AddSeparator("PLAYER MENU")
    speedBtn = AddToggle("Speed Boost", speedBoost, ToggleSpeed)
    speedValLabel = AddSlider("Speed Value", speedValue, 25, 999, UpdateSpeedVal)
    ry = ry + 5
    
    jumpBtn = AddToggle("Jump Boost", jumpBoost, ToggleJump)
    jumpValLabel = AddSlider("Jump Value", jumpValue, 50, 999, UpdateJumpVal)
    ry = ry + 5
    
    rightScroll.CanvasSize = UDim2.new(0, 0, 0, ry + 30)
end

-- ===== SWITCH KATEGORI =====
local function SwitchCategory(cat)
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
    DisableNoclip()
    StopFly()
    gui:Destroy()
    for _, esp in pairs(espObjects) do
        if esp.box then esp.box:Remove() end
        if esp.tracer then esp.tracer:Remove() end
        if esp.nameTag then esp.nameTag:Remove() end
        if esp.distanceTag then esp.distanceTag:Remove() end
    end
    for _, conn in pairs(espConnections) do
        if conn then conn:Disconnect() end
    end
    for _, esp in pairs(entityEspObjects) do
        if esp.box then esp.box:Remove() end
        if esp.nameTag then esp.nameTag:Remove() end
        if esp.distanceTag then esp.distanceTag:Remove() end
    end
end)

-- ===== INIT =====
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)
ScanEntities()

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.5)
    origSpeed = char.Humanoid.WalkSpeed
    origJump = char.Humanoid.JumpPower
    ApplySpeed()
    ApplyJump()
    if noclipEnabled then EnableNoclip() end
end)

SwitchCategory("ESP MENU")

print("========================")
print("VORTEX FINAL - LOADED!")
print("FITUR: ESP PLAYER + ENTITY, WALLHACK, FLY, SPEED, JUMP")
print("========================")
