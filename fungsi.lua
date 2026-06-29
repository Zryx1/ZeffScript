-- ========================================
-- VORTEX FUNGSI - SEMUA FITUR
-- ESP, WALLHACK, FLY, HITBOX, DLL
-- ========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ========== GLOBAL TABLE ==========
_G.VortexFungsi = _G.VortexFungsi or {}

local V = _G.VortexFungsi

-- ========== VARIABEL ==========
-- ESP PLAYER
V.masterESP = false
V.espBox = false
V.espLine = false
V.espName = false
V.espDistance = false
V.espThick = 2
V.espColor = Color3.fromRGB(155, 0, 255)
V.colorIndex = 1
V.colors = {
    Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(155, 0, 255)
}
V.colorNames = {"Biru", "Merah", "Hijau", "Kuning", "Ungu"}

-- ESP ENTITY
V.espEntity = false
V.espEntityBox = false
V.espEntityName = false
V.espEntityDistance = false
V.espEntityColor = Color3.fromRGB(255, 100, 0)
V.espEntityThick = 2

-- WALLHACK
V.noclipEnabled = false
V.noclipConnection = nil

-- FLY
V.flying = false
V.flySpeed = 2.0
V.upForce = 0
V.downForce = 0
V.flyBodyVelocity = nil
V.flyBodyGyro = nil
V.flyLoop = nil

-- HITBOX
V.espHitbox = false
V.hitboxThick = 2
V.hitboxExpander = 0
V.hitboxExpanderEnabled = false
V.hitboxColor = Color3.fromRGB(255, 0, 0)

-- MULTI PENDAPATAN
V.multiIncomeEnabled = false
V.incomeMultiplier = 10
V.multiIncomeConnection = nil
V.remoteConnections = {}
V.valueConnections = {}

-- SPEED JUMP
V.speedBoost = false
V.speedValue = 200
V.jumpBoost = false
V.jumpValue = 200

-- ESP STORAGE
V.espObjects = {}
V.espConnections = {}
V.entityEspObjects = {}
V.origSpeed = 16
V.origJump = 50

-- ========== FUNGSI ESP PLAYER ==========
function V.CreateESP(player)
    if player == LocalPlayer or V.espObjects[player] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = V.espColor
    box.Thickness = V.espThick
    box.Transparency = 0.5
    box.Filled = false
    
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = V.espColor
    line.Thickness = V.espThick
    
    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Color = V.espColor
    nameTag.Size = 12
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.fromRGB(0,0,0)
    
    local distanceTag = Drawing.new("Text")
    distanceTag.Visible = false
    distanceTag.Color = V.espColor
    distanceTag.Size = 10
    distanceTag.Center = true
    distanceTag.Outline = true
    distanceTag.OutlineColor = Color3.fromRGB(0,0,0)
    
    local hitbox = Drawing.new("Square")
    hitbox.Visible = false
    hitbox.Color = V.hitboxColor
    hitbox.Thickness = V.hitboxThick
    hitbox.Transparency = 0.3
    hitbox.Filled = false
    
    V.espObjects[player] = {
        box = box,
        line = line,
        nameTag = nameTag,
        distanceTag = distanceTag,
        hitbox = hitbox,
        player = player
    }
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        -- HITBOX
        if V.espHitbox then
            local char = player.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            if char and hum and root and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local dist = (root.Position - Camera.CFrame.Position).Magnitude
                    local baseSize = math.clamp(200 / dist, 30, 100)
                    local expandSize = baseSize + (baseSize * V.hitboxExpander / 100)
                    
                    hitbox.Size = Vector2.new(expandSize, expandSize)
                    hitbox.Position = Vector2.new(pos.X - expandSize / 2, pos.Y - expandSize / 1.2)
                    hitbox.Visible = true
                    hitbox.Color = V.hitboxColor
                    hitbox.Thickness = V.hitboxThick
                else
                    hitbox.Visible = false
                end
            else
                hitbox.Visible = false
            end
        else
            hitbox.Visible = false
        end
        
        -- ESP PLAYER
        if not V.masterESP then
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
        
        if V.espBox and box and onScreen then
            local top = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
            local bottom = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, -3.5, 0))
            local sizeY = math.abs(top.Y - bottom.Y)
            local sizeX = sizeY * 0.6
            
            box.Size = Vector2.new(sizeX, sizeY)
            box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
            box.Visible = true
            box.Color = V.espColor
            box.Thickness = V.espThick
        elseif box then
            box.Visible = false
        end
        
        if V.espLine and line and onScreen then
            line.From = center
            line.To = Vector2.new(pos.X, pos.Y)
            line.Visible = true
            line.Color = V.espColor
            line.Thickness = V.espThick
        elseif line then
            line.Visible = false
        end
        
        local nameYOffset = 35
        if V.espDistance then nameYOffset = 50 end
        
        if V.espName and nameTag and onScreen then
            nameTag.Text = player.Name
            nameTag.Position = Vector2.new(pos.X, pos.Y - nameYOffset)
            nameTag.Visible = true
            nameTag.Color = V.espColor
        elseif nameTag then
            nameTag.Visible = false
        end
        
        if V.espDistance and distanceTag and onScreen then
            distanceTag.Text = distText
            distanceTag.Position = Vector2.new(pos.X, pos.Y - 20)
            distanceTag.Visible = true
            distanceTag.Color = V.espColor
        elseif distanceTag then
            distanceTag.Visible = false
        end
    end)
    
    V.espConnections[player] = connection
    
    player.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if box then box:Remove() end
            if line then line:Remove() end
            if nameTag then nameTag:Remove() end
            if distanceTag then distanceTag:Remove() end
            if hitbox then hitbox:Remove() end
            if V.espConnections[player] then V.espConnections[player]:Disconnect() end
            V.espObjects[player] = nil
            V.espConnections[player] = nil
        end
    end)
end

function V.RemoveESP(player)
    local esp = V.espObjects[player]
    if esp then
        if esp.box then esp.box:Remove() end
        if esp.line then esp.line:Remove() end
        if esp.nameTag then esp.nameTag:Remove() end
        if esp.distanceTag then esp.distanceTag:Remove() end
        if esp.hitbox then esp.hitbox:Remove() end
        V.espObjects[player] = nil
    end
    if V.espConnections[player] then
        V.espConnections[player]:Disconnect()
        V.espConnections[player] = nil
    end
end

function V.RefreshESP()
    for _, esp in pairs(V.espObjects) do
        if esp.box then
            esp.box.Color = V.espColor
            esp.box.Thickness = V.espThick
        end
        if esp.line then
            esp.line.Color = V.espColor
            esp.line.Thickness = V.espThick
        end
        if esp.nameTag then
            esp.nameTag.Color = V.espColor
        end
        if esp.distanceTag then
            esp.distanceTag.Color = V.espColor
        end
        if esp.hitbox then
            esp.hitbox.Color = V.hitboxColor
            esp.hitbox.Thickness = V.hitboxThick
        end
    end
    for _, esp in pairs(V.entityEspObjects) do
        if esp.box then
            esp.box.Color = V.espEntityColor
            esp.box.Thickness = V.espEntityThick
        end
        if esp.nameTag then
            esp.nameTag.Color = V.espEntityColor
        end
        if esp.distanceTag then
            esp.distanceTag.Color = V.espEntityColor
        end
    end
end

-- ========== TOGGLE ESP PLAYER ==========
function V.ToggleMaster()
    V.masterESP = not V.masterESP
end

function V.ToggleBox()
    V.espBox = not V.espBox
end

function V.ToggleLine()
    V.espLine = not V.espLine
end

function V.ToggleName()
    V.espName = not V.espName
end

function V.ToggleDistance()
    V.espDistance = not V.espDistance
end

function V.UpdateThick(val)
    V.espThick = val
    V.RefreshESP()
end

function V.NextColor()
    V.colorIndex = V.colorIndex % #V.colors + 1
    V.espColor = V.colors[V.colorIndex]
    V.RefreshESP()
end

function V.PrevColor()
    V.colorIndex = V.colorIndex - 1
    if V.colorIndex < 1 then V.colorIndex = #V.colors end
    V.espColor = V.colors[V.colorIndex]
    V.RefreshESP()
end

function V.GetColorName()
    return V.colorNames[V.colorIndex]
end

-- ========== FUNGSI ESP ENTITY ==========
function V.CreateEntityESP(entity)
    if entity == LocalPlayer.Character then return end
    if entity:FindFirstChild("Humanoid") == nil then return end
    if V.entityEspObjects[entity] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = V.espEntityColor
    box.Thickness = V.espEntityThick
    box.Transparency = 0.5
    box.Filled = false
    
    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Color = V.espEntityColor
    nameTag.Size = 10
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.fromRGB(0,0,0)
    
    local distanceTag = Drawing.new("Text")
    distanceTag.Visible = false
    distanceTag.Color = V.espEntityColor
    distanceTag.Size = 10
    distanceTag.Center = true
    distanceTag.Outline = true
    distanceTag.OutlineColor = Color3.fromRGB(0,0,0)
    
    V.entityEspObjects[entity] = {
        box = box,
        nameTag = nameTag,
        distanceTag = distanceTag,
        entity = entity
    }
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not V.espEntity then
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
        
        if V.espEntityBox and box and onScreen then
            local top = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 2.5, 0))
            local bottom = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, -3, 0))
            local sizeY = math.abs(top.Y - bottom.Y)
            local sizeX = sizeY * 0.6
            
            box.Size = Vector2.new(sizeX, sizeY)
            box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
            box.Visible = true
            box.Color = V.espEntityColor
            box.Thickness = V.espEntityThick
        elseif box then
            box.Visible = false
        end
        
        if V.espEntityName and nameTag and onScreen then
            nameTag.Text = entity.Name or "Entity"
            nameTag.Position = Vector2.new(pos.X, pos.Y - 25)
            nameTag.Visible = true
            nameTag.Color = V.espEntityColor
        elseif nameTag then
            nameTag.Visible = false
        end
        
        if V.espEntityDistance and distanceTag and onScreen then
            distanceTag.Text = distText
            distanceTag.Position = Vector2.new(pos.X, pos.Y - 12)
            distanceTag.Visible = true
            distanceTag.Color = V.espEntityColor
        elseif distanceTag then
            distanceTag.Visible = false
        end
    end)
    
    entity:AncestryChanged:Connect(function(_, parent)
        if not parent then
            if box then box:Remove() end
            if nameTag then nameTag:Remove() end
            if distanceTag then distanceTag:Remove() end
            V.entityEspObjects[entity] = nil
            connection:Disconnect()
        end
    end)
end

function V.ScanEntities()
    for _, esp in pairs(V.entityEspObjects) do
        if esp.box then esp.box:Remove() end
        if esp.nameTag then esp.nameTag:Remove() end
        if esp.distanceTag then esp.distanceTag:Remove() end
    end
    V.entityEspObjects = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= LocalPlayer.Character then
            local hum = obj:FindFirstChild("Humanoid")
            if hum then
                V.CreateEntityESP(obj)
            end
        end
    end
end

function V.ToggleEntityESP()
    V.espEntity = not V.espEntity
    if V.espEntity then
        V.ScanEntities()
    else
        for _, esp in pairs(V.entityEspObjects) do
            if esp.box then esp.box:Remove() end
            if esp.nameTag then esp.nameTag:Remove() end
            if esp.distanceTag then esp.distanceTag:Remove() end
        end
        V.entityEspObjects = {}
    end
end

function V.ToggleEntityBox()
    V.espEntityBox = not V.espEntityBox
end

function V.ToggleEntityName()
    V.espEntityName = not V.espEntityName
end

function V.ToggleEntityDistance()
    V.espEntityDistance = not V.espEntityDistance
end

-- ========== WALLHACK ==========
function V.EnableNoclip()
    if V.noclipConnection then V.noclipConnection:Disconnect() end
    V.noclipConnection = RunService.Stepped:Connect(function()
        if not V.noclipEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

function V.DisableNoclip()
    if V.noclipConnection then
        V.noclipConnection:Disconnect()
        V.noclipConnection = nil
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

function V.ToggleWallhack()
    V.noclipEnabled = not V.noclipEnabled
    if V.noclipEnabled then
        V.EnableNoclip()
    else
        V.DisableNoclip()
    end
end

-- ========== FLY ==========
function V.StartFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return end
    
    if V.flyBodyVelocity then V.flyBodyVelocity:Destroy() end
    if V.flyBodyGyro then V.flyBodyGyro:Destroy() end
    if V.flyLoop then V.flyLoop:Disconnect() end
    
    V.flyBodyVelocity = Instance.new("BodyVelocity", root)
    V.flyBodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    
    V.flyBodyGyro = Instance.new("BodyGyro", root)
    V.flyBodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    V.flyBodyGyro.P = 10000
    
    V.flyLoop = RunService.Stepped:Connect(function()
        if not V.flying or not char or not root then return end
        
        local moveDir = hum.MoveDirection
        local localMove = Camera.CFrame:VectorToObjectSpace(moveDir)
        local vertical = Vector3.new(0, V.upForce + V.downForce, 0)
        local finalDir = (Camera.CFrame.LookVector * -localMove.Z) + (Camera.CFrame.RightVector * localMove.X) + vertical
        
        V.flyBodyVelocity.Velocity = finalDir * (V.flySpeed * 20)
        V.flyBodyGyro.CFrame = Camera.CFrame
        hum:ChangeState(Enum.HumanoidStateType.Swimming)
    end)
end

function V.StopFly()
    if V.flyBodyVelocity then
        V.flyBodyVelocity:Destroy()
        V.flyBodyVelocity = nil
    end
    if V.flyBodyGyro then
        V.flyBodyGyro:Destroy()
        V.flyBodyGyro = nil
    end
    if V.flyLoop then
        V.flyLoop:Disconnect()
        V.flyLoop = nil
    end
    
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end

function V.ToggleFly()
    V.flying = not V.flying
    if V.flying then
        V.StartFly()
    else
        V.StopFly()
    end
end

function V.FlyUp()
    V.upForce = 1
end

function V.FlyUpRelease()
    V.upForce = 0
end

function V.FlyDown()
    V.downForce = -1
end

function V.FlyDownRelease()
    V.downForce = 0
end

function V.UpdateFlySpeed(val)
    V.flySpeed = val
end

-- ========== SPEED JUMP ==========
function V.ApplySpeed()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = V.speedBoost and V.speedValue or V.origSpeed
    end
end

function V.ApplyJump()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = V.jumpBoost and V.jumpValue or V.origJump
    end
end

function V.ToggleSpeed()
    V.speedBoost = not V.speedBoost
    V.ApplySpeed()
end

function V.ToggleJump()
    V.jumpBoost = not V.jumpBoost
    V.ApplyJump()
end

function V.UpdateSpeedVal(val)
    V.speedValue = val
    V.ApplySpeed()
end

function V.UpdateJumpVal(val)
    V.jumpValue = val
    V.ApplyJump()
end

-- ========== HITBOX ==========
function V.ExpandHitbox()
    if not V.hitboxExpanderEnabled then return end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum then
                local scale = 1 + (V.hitboxExpander / 100)
                p.Character.Scale = scale
            end
        end
    end
end

function V.ResetHitbox()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            p.Character.Scale = 1
        end
    end
end

function V.ToggleHitboxExpander()
    V.hitboxExpanderEnabled = not V.hitboxExpanderEnabled
    if V.hitboxExpanderEnabled then
        V.ExpandHitbox()
    else
        V.ResetHitbox()
    end
end

function V.UpdateHitboxExpand(val)
    V.hitboxExpander = math.max(0, math.min(100, val))
    if V.hitboxExpanderEnabled then
        V.ExpandHitbox()
    end
end

function V.ToggleHitboxESP()
    V.espHitbox = not V.espHitbox
end

function V.UpdateHitboxThick(val)
    V.hitboxThick = val
    V.RefreshESP()
end

-- ========== MULTI PENDAPATAN ==========
function V.HookRemoteEvent(remote)
    pcall(function()
        local oldFunction = remote.OnClientEvent
        remote.OnClientEvent = function(...)
            local args = {...}
            for i, arg in ipairs(args) do
                if type(arg) == "number" and arg > 0 then
                    args[i] = arg * V.incomeMultiplier
                end
            end
            if oldFunction then
                oldFunction(unpack(args))
            end
        end
    end)
end

function V.HookValue(value)
    pcall(function()
        local oldGet = value.GetValue
        value.GetValue = function()
            local original = oldGet(value)
            if type(original) == "number" and original > 0 then
                return original * V.incomeMultiplier
            end
            return original
        end
    end)
end

function V.ScanAndHook()
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            if not V.remoteConnections[obj] then
                V.HookRemoteEvent(obj)
                V.remoteConnections[obj] = true
            end
        end
        
        if obj:IsA("NumberValue") or obj:IsA("IntValue") or obj:IsA("DoubleValue") then
            local name = string.lower(obj.Name)
            if name:match("exp") or name:match("gold") or name:match("money") or 
               name:match("gem") or name:match("coin") or name:match("level") or
               name:match("point") or name:match("reward") then
                if not V.valueConnections[obj] then
                    V.HookValue(obj)
                    V.valueConnections[obj] = true
                end
            end
        end
    end
end

function V.EnableMultiIncome()
    V.ScanAndHook()
    if V.multiIncomeConnection then V.multiIncomeConnection:Disconnect() end
    V.multiIncomeConnection = game.DescendantAdded:Connect(function(desc)
        if V.multiIncomeEnabled then
            if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then
                V.HookRemoteEvent(desc)
            end
            if desc:IsA("NumberValue") or desc:IsA("IntValue") or desc:IsA("DoubleValue") then
                local name = string.lower(desc.Name)
                if name:match("exp") or name:match("gold") or name:match("money") or 
                   name:match("gem") or name:match("coin") or name:match("level") then
                    V.HookValue(desc)
                end
            end
        end
    end)
end

function V.DisableMultiIncome()
    if V.multiIncomeConnection then
        V.multiIncomeConnection:Disconnect()
        V.multiIncomeConnection = nil
    end
end

function V.ToggleMultiIncome()
    V.multiIncomeEnabled = not V.multiIncomeEnabled
    if V.multiIncomeEnabled then
        V.EnableMultiIncome()
    else
        V.DisableMultiIncome()
    end
end

function V.UpdateMultiplier(val)
    V.incomeMultiplier = val
end

-- ========== CLEANUP ==========
function V.Cleanup()
    V.DisableNoclip()
    V.DisableMultiIncome()
    V.StopFly()
    V.ResetHitbox()
    for _, esp in pairs(V.espObjects) do
        if esp.box then esp.box:Remove() end
        if esp.line then esp.line:Remove() end
        if esp.nameTag then esp.nameTag:Remove() end
        if esp.distanceTag then esp.distanceTag:Remove() end
        if esp.hitbox then esp.hitbox:Remove() end
    end
    for _, conn in pairs(V.espConnections) do
        if conn then conn:Disconnect() end
    end
    for _, esp in pairs(V.entityEspObjects) do
        if esp.box then esp.box:Remove() end
        if esp.nameTag then esp.nameTag:Remove() end
        if esp.distanceTag then esp.distanceTag:Remove() end
    end
end

-- ========== INIT ==========
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then V.CreateESP(p) end
end
Players.PlayerAdded:Connect(V.CreateESP)
Players.PlayerRemoving:Connect(V.RemoveESP)

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.5)
    V.origSpeed = char.Humanoid.WalkSpeed
    V.origJump = char.Humanoid.JumpPower
    V.ApplySpeed()
    V.ApplyJump()
    if V.noclipEnabled then V.EnableNoclip() end
end)

workspace.DescendantAdded:Connect(function(desc)
    if V.espEntity then
        if desc:IsA("Model") and desc ~= LocalPlayer.Character then
            local hum = desc:FindFirstChild("Humanoid")
            if hum then
                V.CreateEntityESP(desc)
            end
        end
    end
end)

workspace.DescendantRemoving:Connect(function(desc)
    if V.entityEspObjects[desc] then
        local esp = V.entityEspObjects[desc]
        if esp.box then esp.box:Remove() end
        if esp.nameTag then esp.nameTag:Remove() end
        if esp.distanceTag then esp.distanceTag:Remove() end
        V.entityEspObjects[desc] = nil
    end
end)

print("VORTEX FUNGSI - LOADED")
print("Semua fitur siap digunakan")
