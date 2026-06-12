-- ============================================
-- ZEFF VORTEX - MOBILE FRIENDLY FIXED
-- UKURAN DIPERKECIL UNTUK HP + SEMUA FUNGSI BERJALAN
-- ============================================

-- ============================================
-- VARIABEL ESP
-- ============================================
local masterEnabled = false
local espBoxEnabled = false
local espTracerEnabled = false
local espNameEnabled = false
local espColor = Color3.fromRGB(155, 0, 255)
local espThickness = 2

-- ============================================
-- VARIABEL MULTI HIT
-- ============================================
local multiHitEnabled = false
local mhRange = 20
local mhDamage = 10
local mhTargets = 10
local mhHitsPerSec = 5
local mhMode = "players"
local singleHitDamage = 50

-- ============================================
-- VARIABEL SPEED & JUMP
-- ============================================
local speedEnabled = false
local speedMult = 1
local jumpEnabled = false
local jumpMult = 1
local originalWalkSpeed = 16
local originalJumpPower = 50

-- ============================================
-- VARIABEL UI
-- ============================================
local minimized = false
local currentMenu = nil
local currentTab = "esp"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local espList = {}

-- ============================================
-- FUNGSI ESP
-- ============================================
local function CreateESP(player)
    if player == LocalPlayer then return end
    if espList[player] then return end
    
    local esp = {}
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = espColor
    box.Thickness = espThickness
    box.Filled = false
    box.Transparency = 0.5
    esp.box = box
    
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = espColor
    tracer.Thickness = espThickness
    tracer.Transparency = 0.5
    esp.tracer = tracer
    
    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Color = espColor
    nameTag.Size = 12
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.nameTag = nameTag
    
    esp.player = player
    espList[player] = esp
end

local function RemoveESP(player)
    local esp = espList[player]
    if esp then
        if esp.box then esp.box:Remove() end
        if esp.tracer then esp.tracer:Remove() end
        if esp.nameTag then esp.nameTag:Remove() end
        espList[player] = nil
    end
end

local function UpdateAllESP()
    if not masterEnabled then
        for _, esp in pairs(espList) do
            if esp.box then esp.box.Visible = false end
            if esp.tracer then esp.tracer.Visible = false end
            if esp.nameTag then esp.nameTag.Visible = false end
        end
        return
    end
    
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, esp in pairs(espList) do
        local character = esp.player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        local isValid = character and humanoid and rootPart and humanoid.Health > 0
        
        if not isValid then
            if esp.box then esp.box.Visible = false end
            if esp.tracer then esp.tracer.Visible = false end
            if esp.nameTag then esp.nameTag.Visible = false end
        else
            if espBoxEnabled and esp.box then
                local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
                    local boxSize = math.clamp(200 / distance, 30, 100)
                    esp.box.Size = Vector2.new(boxSize, boxSize)
                    esp.box.Position = Vector2.new(vector.X - boxSize/2, vector.Y - boxSize/1.2)
                    esp.box.Visible = true
                else
                    esp.box.Visible = false
                end
            elseif esp.box then
                esp.box.Visible = false
            end
            
            if espTracerEnabled and esp.tracer then
                local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    esp.tracer.From = center
                    esp.tracer.To = Vector2.new(vector.X, vector.Y)
                    esp.tracer.Visible = true
                else
                    esp.tracer.Visible = false
                end
            elseif esp.tracer then
                esp.tracer.Visible = false
            end
            
            if espNameEnabled and esp.nameTag then
                local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    esp.nameTag.Text = esp.player.Name
                    esp.nameTag.Position = Vector2.new(vector.X, vector.Y - 25)
                    esp.nameTag.Visible = true
                else
                    esp.nameTag.Visible = false
                end
            elseif esp.nameTag then
                esp.nameTag.Visible = false
            end
        end
    end
end

local function RefreshStyle()
    for _, esp in pairs(espList) do
        if esp.box then
            esp.box.Color = espColor
            esp.box.Thickness = espThickness
        end
        if esp.tracer then
            esp.tracer.Color = espColor
            esp.tracer.Thickness = espThickness
        end
        if esp.nameTag then
            esp.nameTag.Color = espColor
        end
    end
end

-- ============================================
-- SPEED & JUMP
-- ============================================
local function ApplySpeed()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        if speedEnabled then
            char.Humanoid.WalkSpeed = originalWalkSpeed * speedMult
        else
            char.Humanoid.WalkSpeed = originalWalkSpeed
        end
    end
end

local function ApplyJump()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        if jumpEnabled then
            char.Humanoid.JumpPower = originalJumpPower * jumpMult
        else
            char.Humanoid.JumpPower = originalJumpPower
        end
    end
end

-- ============================================
-- MULTI HIT
-- ============================================
local function GetTargets()
    local targets = {}
    local char = LocalPlayer.Character
    if not char then return targets end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return targets end
    
    if mhMode == "players" then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local c = p.Character
                if c then
                    local r = c:FindFirstChild("HumanoidRootPart")
                    if r and (root.Position - r.Position).Magnitude <= mhRange then
                        local h = c:FindFirstChild("Humanoid")
                        if h and h.Health > 0 then
                            table.insert(targets, h)
                        end
                    end
                end
            end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local c = p.Character
                if c then
                    local r = c:FindFirstChild("HumanoidRootPart")
                    if r and (root.Position - r.Position).Magnitude <= mhRange then
                        local h = c:FindFirstChild("Humanoid")
                        if h and h.Health > 0 then
                            table.insert(targets, h)
                        end
                    end
                end
            end
        end
        local function scan(inst)
            for _, child in ipairs(inst:GetChildren()) do
                if child:IsA("Model") and child ~= char and not child:FindFirstChild("HumanoidRootPart") then
                    local h = child:FindFirstChild("Humanoid")
                    local r = child:FindFirstChild("Head")
                    if h and r and h.Health > 0 and (root.Position - r.Position).Magnitude <= mhRange then
                        table.insert(targets, h)
                    end
                end
                scan(child)
            end
        end
        scan(workspace)
    end
    
    if #targets > mhTargets then
        local limited = {}
        for i = 1, mhTargets do limited[i] = targets[i] end
        return limited
    end
    return targets
end

local function DoMultiHit()
    if not multiHitEnabled then return end
    for _, h in ipairs(GetTargets()) do
        h.Health = h.Health - mhDamage
    end
end

local function DoSingleHit()
    local targets = GetTargets()
    if #targets > 0 then
        targets[1].Health = targets[1].Health - singleHitDamage
    end
end

-- ============================================
-- MEMBUAT MENU (UKURAN KECIL UNTUK HP)
-- ============================================
local screenGui = nil
local swordBtn = nil

local function CreateMainMenu()
    if currentMenu then
        currentMenu:Destroy()
        currentMenu = nil
    end
    
    local CoreGui = game:GetService("CoreGui")
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ZeffVortexMenu"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    
    pcall(function()
        screenGui.Parent = (gethui and gethui()) or CoreGui
    end)
    if not screenGui.Parent then
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    currentMenu = screenGui
    
    -- MAIN FRAME (UKURAN HP)
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -140, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
    mainFrame.BackgroundTransparency = 0
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    mainFrame.Active = true
    mainFrame.Draggable = false
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = mainFrame
    
    local border = Instance.new("UIStroke")
    border.Thickness = 1
    border.Color = Color3.fromRGB(155, 0, 255)
    border.Transparency = 0.3
    border.Parent = mainFrame
    
    -- HEADER (BISA DI-DRAG)
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
    header.BackgroundTransparency = 0.2
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0.03, 0, 0, 0)
    title.Text = "⚔️ VORTEX"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -65, 0.5, -15)
    minBtn.Text = "─"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.BackgroundTransparency = 1
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 18
    minBtn.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -32, 0.5, -15)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = header
    
    -- TAB BAR
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, -16, 0, 35)
    tabBar.Position = UDim2.new(0, 8, 0, 48)
    tabBar.BackgroundTransparency = 1
    tabBar.Parent = mainFrame
    
    local espTab = Instance.new("TextButton")
    espTab.Size = UDim2.new(0.3, -4, 1, 0)
    espTab.Position = UDim2.new(0, 0, 0, 0)
    espTab.Text = "ESP"
    espTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    espTab.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
    espTab.BackgroundTransparency = 0
    espTab.Font = Enum.Font.GothamBold
    espTab.TextSize = 11
    espTab.Parent = tabBar
    
    local multiTab = Instance.new("TextButton")
    multiTab.Size = UDim2.new(0.33, -4, 1, 0)
    multiTab.Position = UDim2.new(0.32, 4, 0, 0)
    multiTab.Text = "HIT"
    multiTab.TextColor3 = Color3.fromRGB(200, 200, 220)
    multiTab.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    multiTab.BackgroundTransparency = 0
    multiTab.Font = Enum.Font.GothamBold
    multiTab.TextSize = 11
    multiTab.Parent = tabBar
    
    local boostTab = Instance.new("TextButton")
    boostTab.Size = UDim2.new(0.33, -4, 1, 0)
    boostTab.Position = UDim2.new(0.64, 8, 0, 0)
    boostTab.Text = "BOOST"
    boostTab.TextColor3 = Color3.fromRGB(200, 200, 220)
    boostTab.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    boostTab.BackgroundTransparency = 0
    boostTab.Font = Enum.Font.GothamBold
    boostTab.TextSize = 11
    boostTab.Parent = tabBar
    
    -- CONTENT CONTAINER
    local contentContainer = Instance.new("ScrollingFrame")
    contentContainer.Size = UDim2.new(1, 0, 1, -135)
    contentContainer.Position = UDim2.new(0, 0, 0, 92)
    contentContainer.BackgroundTransparency = 1
    contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentContainer.ScrollBarThickness = 2
    contentContainer.ScrollBarImageColor3 = Color3.fromRGB(155, 0, 255)
    contentContainer.Parent = mainFrame
    
    -- ========== TAB 1: ESP CONTENT ==========
    local espContent = Instance.new("Frame")
    espContent.Size = UDim2.new(1, 0, 1, 0)
    espContent.BackgroundTransparency = 1
    espContent.Visible = true
    espContent.Parent = contentContainer
    
    local yEsp = 5
    
    local masterBtn = CreateButton(espContent, "MASTER ESP", yEsp, masterEnabled)
    yEsp = yEsp + 40
    
    local boxBtn = CreateButton(espContent, "BOX ESP", yEsp, espBoxEnabled)
    yEsp = yEsp + 35
    
    local tracerBtn = CreateButton(espContent, "TRACER ESP", yEsp, espTracerEnabled)
    yEsp = yEsp + 35
    
    local nameBtn = CreateButton(espContent, "NAME ESP", yEsp, espNameEnabled)
    yEsp = yEsp + 35
    
    local thickFrame = CreateSliderControl(espContent, "TEBAL", yEsp, espThickness, 1, 5)
    yEsp = yEsp + 45
    
    espContent.CanvasSize = UDim2.new(0, 0, 0, yEsp + 10)
    
    -- ========== TAB 2: MULTI HIT CONTENT ==========
    local multiContent = Instance.new("Frame")
    multiContent.Size = UDim2.new(1, 0, 1, 0)
    multiContent.BackgroundTransparency = 1
    multiContent.Visible = false
    multiContent.Parent = contentContainer
    
    local yMulti = 5
    
    -- ATTACK BUTTON MANUAL
    local attackBtn = Instance.new("TextButton")
    attackBtn.Size = UDim2.new(1, -16, 0, 50)
    attackBtn.Position = UDim2.new(0, 8, 0, yMulti)
    attackBtn.Text = "⚔️ ATTACK! ⚔️"
    attackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    attackBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    attackBtn.Font = Enum.Font.GothamBold
    attackBtn.TextSize = 16
    attackBtn.Parent = multiContent
    local attackCorner = Instance.new("UICorner")
    attackCorner.CornerRadius = UDim.new(0, 8)
    attackCorner.Parent = attackBtn
    yMulti = yMulti + 58
    
    -- Auto Multi Hit Toggle
    local autoBtn = CreateButton(multiContent, "AUTO MULTI HIT", yMulti, multiHitEnabled)
    yMulti = yMulti + 40
    
    -- Status Label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -16, 0, 30)
    statusLabel.Position = UDim2.new(0, 8, 0, yMulti)
    statusLabel.Text = multiHitEnabled and "✅ ACTIVE" or "❌ INACTIVE"
    statusLabel.TextColor3 = multiHitEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
    statusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    statusLabel.BackgroundTransparency = 0
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 11
    statusLabel.Parent = multiContent
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 6)
    statusCorner.Parent = statusLabel
    yMulti = yMulti + 38
    
    local rangeFrame = CreateSliderControl(multiContent, "RADIUS", yMulti, mhRange, 5, 20)
    yMulti = yMulti + 45
    local damageFrame = CreateSliderControl(multiContent, "DAMAGE", yMulti, mhDamage, 1, 25)
    yMulti = yMulti + 45
    local targetFrame = CreateSliderControl(multiContent, "TARGET", yMulti, mhTargets, 1, 15)
    yMulti = yMulti + 45
    local hitsFrame = CreateSliderControl(multiContent, "HIT/DETIK", yMulti, mhHitsPerSec, 1, 10)
    yMulti = yMulti + 45
    
    local modeBtn = CreateButton(multiContent, "MODE: PLAYERS", yMulti, false)
    yMulti = yMulti + 40
    
    multiContent.CanvasSize = UDim2.new(0, 0, 0, yMulti + 10)
    
    -- ========== TAB 3: BOOST CONTENT ==========
    local boostContent = Instance.new("Frame")
    boostContent.Size = UDim2.new(1, 0, 1, 0)
    boostContent.BackgroundTransparency = 1
    boostContent.Visible = false
    boostContent.Parent = contentContainer
    
    local yBoost = 5
    
    local speedBtn = CreateButton(boostContent, "SPEED BOOST", yBoost, speedEnabled)
    yBoost = yBoost + 40
    local speedMultFrame = CreateSliderControl(boostContent, "SPEED x", yBoost, speedMult, 1, 50)
    yBoost = yBoost + 45
    local jumpBtn = CreateButton(boostContent, "JUMP BOOST", yBoost, jumpEnabled)
    yBoost = yBoost + 40
    local jumpMultFrame = CreateSliderControl(boostContent, "JUMP x", yBoost, jumpMult, 1, 50)
    yBoost = yBoost + 45
    
    boostContent.CanvasSize = UDim2.new(0, 0, 0, yBoost + 10)
    
    -- ========== FUNGSI ==========
    function CreateButton(parent, text, yPos, state)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -16, 0, 35)
        btn.Position = UDim2.new(0, 8, 0, yPos)
        btn.Text = state and text .. " ✅" or text .. " ❌"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundColor3 = state and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
        btn.BackgroundTransparency = 0
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn
        
        return btn
    end
    
    function CreateSliderControl(parent, label, yPos, value, minVal, maxVal)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -16, 0, 38)
        frame.Position = UDim2.new(0, 8, 0, yPos)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
        frame.BackgroundTransparency = 0
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = frame
        
        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(0.4, 0, 1, 0)
        labelText.Position = UDim2.new(0, 8, 0, 0)
        labelText.Text = label
        labelText.TextColor3 = Color3.fromRGB(200, 200, 220)
        labelText.BackgroundTransparency = 1
        labelText.Font = Enum.Font.GothamBold
        labelText.TextSize = 11
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = frame
        
        local valueText = Instance.new("TextLabel")
        valueText.Size = UDim2.new(0.2, 0, 1, 0)
        valueText.Position = UDim2.new(0.45, 0, 0, 0)
        valueText.Text = tostring(value)
        valueText.TextColor3 = Color3.fromRGB(155, 0, 255)
        valueText.BackgroundTransparency = 1
        valueText.Font = Enum.Font.GothamBold
        valueText.TextSize = 11
        valueText.TextXAlignment = Enum.TextXAlignment.Center
        valueText.Parent = frame
        
        local minus = Instance.new("TextButton")
        minus.Size = UDim2.new(0, 28, 0, 28)
        minus.Position = UDim2.new(1, -62, 0.5, -14)
        minus.Text = "-"
        minus.TextColor3 = Color3.fromRGB(255, 255, 255)
        minus.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        minus.Font = Enum.Font.GothamBold
        minus.TextSize = 16
        minus.Parent = frame
        
        local plus = Instance.new("TextButton")
        plus.Size = UDim2.new(0, 28, 0, 28)
        plus.Position = UDim2.new(1, -30, 0.5, -14)
        plus.Text = "+"
        plus.TextColor3 = Color3.fromRGB(255, 255, 255)
        plus.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        plus.Font = Enum.Font.GothamBold
        plus.TextSize = 16
        plus.Parent = frame
        
        local minusCorner = Instance.new("UICorner")
        minusCorner.CornerRadius = UDim.new(0, 5)
        minusCorner.Parent = minus
        local plusCorner = Instance.new("UICorner")
        plusCorner.CornerRadius = UDim.new(0, 5)
        plusCorner.Parent = plus
        
        return {frame = frame, valueText = valueText, minus = minus, plus = plus, min = minVal, max = maxVal}
    end
    
    -- Update Functions
    local function UpdateMasterBtn() masterBtn.Text = masterEnabled and "MASTER ESP ✅" or "MASTER ESP ❌" masterBtn.BackgroundColor3 = masterEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50) end
    local function UpdateBoxBtn() boxBtn.Text = espBoxEnabled and "BOX ESP ✅" or "BOX ESP ❌" boxBtn.BackgroundColor3 = espBoxEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50) end
    local function UpdateTracerBtn() tracerBtn.Text = espTracerEnabled and "TRACER ESP ✅" or "TRACER ESP ❌" tracerBtn.BackgroundColor3 = espTracerEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50) end
    local function UpdateNameBtn() nameBtn.Text = espNameEnabled and "NAME ESP ✅" or "NAME ESP ❌" nameBtn.BackgroundColor3 = espNameEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50) end
    local function UpdateSpeedBtn() speedBtn.Text = speedEnabled and "SPEED BOOST ✅" or "SPEED BOOST ❌" speedBtn.BackgroundColor3 = speedEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50) end
    local function UpdateJumpBtn() jumpBtn.Text = jumpEnabled and "JUMP BOOST ✅" or "JUMP BOOST ❌" jumpBtn.BackgroundColor3 = jumpEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50) end
    local function UpdateAutoBtn() autoBtn.Text = multiHitEnabled and "AUTO MULTI HIT ✅" or "AUTO MULTI HIT ❌" autoBtn.BackgroundColor3 = multiHitEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50) statusLabel.Text = multiHitEnabled and "✅ ACTIVE" or "❌ INACTIVE" statusLabel.TextColor3 = multiHitEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100) end
    local function UpdateModeBtn() modeBtn.Text = (mhMode == "players") and "MODE: PLAYERS" or "MODE: ALL ENTITY" end
    
    -- Button Actions
    masterBtn.MouseButton1Click:Connect(function() masterEnabled = not masterEnabled UpdateMasterBtn() end)
    boxBtn.MouseButton1Click:Connect(function() espBoxEnabled = not espBoxEnabled UpdateBoxBtn() end)
    tracerBtn.MouseButton1Click:Connect(function() espTracerEnabled = not espTracerEnabled UpdateTracerBtn() end)
    nameBtn.MouseButton1Click:Connect(function() espNameEnabled = not espNameEnabled UpdateNameBtn() end)
    
    thickFrame.minus.MouseButton1Click:Connect(function() espThickness = math.max(1, espThickness - 1) thickFrame.valueText.Text = tostring(espThickness) RefreshStyle() end)
    thickFrame.plus.MouseButton1Click:Connect(function() espThickness = math.min(5, espThickness + 1) thickFrame.valueText.Text = tostring(espThickness) RefreshStyle() end)
    
    attackBtn.MouseButton1Click:Connect(function() DoSingleHit() end)
    
    autoBtn.MouseButton1Click:Connect(function() 
        multiHitEnabled = not multiHitEnabled 
        UpdateAutoBtn()
        if multiHitEnabled then
            attackBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        else
            attackBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        end
    end)
    
    rangeFrame.minus.MouseButton1Click:Connect(function() mhRange = math.max(5, mhRange - 1) rangeFrame.valueText.Text = tostring(mhRange) end)
    rangeFrame.plus.MouseButton1Click:Connect(function() mhRange = math.min(20, mhRange + 1) rangeFrame.valueText.Text = tostring(mhRange) end)
    damageFrame.minus.MouseButton1Click:Connect(function() mhDamage = math.max(1, mhDamage - 1) damageFrame.valueText.Text = tostring(mhDamage) end)
    damageFrame.plus.MouseButton1Click:Connect(function() mhDamage = math.min(25, mhDamage + 1) damageFrame.valueText.Text = tostring(mhDamage) end)
    targetFrame.minus.MouseButton1Click:Connect(function() mhTargets = math.max(1, mhTargets - 1) targetFrame.valueText.Text = tostring(mhTargets) end)
    targetFrame.plus.MouseButton1Click:Connect(function() mhTargets = math.min(15, mhTargets + 1) targetFrame.valueText.Text = tostring(mhTargets) end)
    hitsFrame.minus.MouseButton1Click:Connect(function() mhHitsPerSec = math.max(1, mhHitsPerSec - 1) hitsFrame.valueText.Text = tostring(mhHitsPerSec) end)
    hitsFrame.plus.MouseButton1Click:Connect(function() mhHitsPerSec = math.min(10, mhHitsPerSec + 1) hitsFrame.valueText.Text = tostring(mhHitsPerSec) end)
    
    modeBtn.MouseButton1Click:Connect(function() 
        mhMode = (mhMode == "players") and "all" or "players" 
        UpdateModeBtn()
    end)
    
    speedBtn.MouseButton1Click:Connect(function() speedEnabled = not speedEnabled UpdateSpeedBtn() ApplySpeed() end)
    speedMultFrame.minus.MouseButton1Click:Connect(function() speedMult = math.max(1, speedMult - 1) speedMultFrame.valueText.Text = speedMult .. "x" ApplySpeed() end)
    speedMultFrame.plus.MouseButton1Click:Connect(function() speedMult = math.min(50, speedMult + 1) speedMultFrame.valueText.Text = speedMult .. "x" ApplySpeed() end)
    
    jumpBtn.MouseButton1Click:Connect(function() jumpEnabled = not jumpEnabled UpdateJumpBtn() ApplyJump() end)
    jumpMultFrame.minus.MouseButton1Click:Connect(function() jumpMult = math.max(1, jumpMult - 1) jumpMultFrame.valueText.Text = jumpMult .. "x" ApplyJump() end)
    jumpMultFrame.plus.MouseButton1Click:Connect(function() jumpMult = math.min(50, jumpMult + 1) jumpMultFrame.valueText.Text = jumpMult .. "x" ApplyJump() end)
    
    -- Tab Switch
    local function SwitchTab(tab)
        currentTab = tab
        espTab.BackgroundColor3 = tab == "esp" and Color3.fromRGB(155, 0, 255) or Color3.fromRGB(35, 35, 50)
        espTab.TextColor3 = tab == "esp" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 220)
        multiTab.BackgroundColor3 = tab == "multi" and Color3.fromRGB(155, 0, 255) or Color3.fromRGB(35, 35, 50)
        multiTab.TextColor3 = tab == "multi" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 220)
        boostTab.BackgroundColor3 = tab == "boost" and Color3.fromRGB(155, 0, 255) or Color3.fromRGB(35, 35, 50)
        boostTab.TextColor3 = tab == "boost" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 220)
        
        espContent.Visible = (tab == "esp")
        multiContent.Visible = (tab == "multi")
        boostContent.Visible = (tab == "boost")
        contentContainer.CanvasPosition = Vector2.new(0, 0)
    end
    
    espTab.MouseButton1Click:Connect(function() SwitchTab("esp") end)
    multiTab.MouseButton1Click:Connect(function() SwitchTab("multi") end)
    boostTab.MouseButton1Click:Connect(function() SwitchTab("boost") end)
    
    -- DRAG MENU (PAKE TOUCH)
    local dragStartPos = nil
    local dragStartMouse = nil
    local isDragging = false
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStartMouse = input.Position
            dragStartPos = mainFrame.Position
        end
    end)
    
    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if not isDragging then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStartMouse
            mainFrame.Position = UDim2.new(
                dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X,
                dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Minimize
    local function ToggleMinimize()
        if minimized then
            mainFrame:TweenSize(UDim2.new(0, 280, 0, 400), "Out", "Quad", 0.2, true)
            tabBar.Visible = true
            contentContainer.Visible = true
            minBtn.Text = "─"
            minimized = false
        else
            mainFrame:TweenSize(UDim2.new(0, 120, 0, 40), "Out", "Quad", 0.2, true)
            tabBar.Visible = false
            contentContainer.Visible = false
            minBtn.Text = "□"
            minimized = true
        end
    end
    
    minBtn.MouseButton1Click:Connect(ToggleMinimize)
    
    closeBtn.MouseButton1Click:Connect(function()
        if screenGui then screenGui:Destroy() end
        currentMenu = nil
    end)
    
    UpdateMasterBtn()
    UpdateBoxBtn()
    UpdateTracerBtn()
    UpdateNameBtn()
    UpdateSpeedBtn()
    UpdateJumpBtn()
    UpdateAutoBtn()
    UpdateModeBtn()
end

-- ============================================
-- INITIALIZATION
-- ============================================
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end)

Players.PlayerRemoving:Connect(RemoveESP)

RunService.RenderStepped:Connect(UpdateAllESP)

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    wait(0.5)
    originalWalkSpeed = char.Humanoid.WalkSpeed
    originalJumpPower = char.Humanoid.JumpPower
    ApplySpeed()
    ApplyJump()
end)

local lastHit = 0
coroutine.wrap(function()
    while true do
        if multiHitEnabled then
            local now = tick()
            if now - lastHit >= (1 / mhHitsPerSec) then
                DoMultiHit()
                lastHit = now
            end
        end
        wait(0.05)
    end
end)()

CreateMainMenu()

print("==========================================")
print("ZEFF VORTEX - MOBILE FRIENDLY")
print("UKURAN DIPERKECIL UNTUK HP")
print("- Semua tombol bisa ditekan (Touch)")
print("- Menu bisa digeser (Drag header)")
print("- ATTACK: Tombol merah buat serang manual")
print("- AUTO MULTI HIT: Nyala terus sampai dimatiin")
print("==========================================")
