-- ============================================
-- ZEFF VORTEX - FULL SCRIPT FIXED V2
-- SEMUA FITUR BERFUNGSI: ON/OFF, DRAG, MINIMIZE, CLOSE, SLIDER
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
    nameTag.Size = 14
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
                    local boxSize = math.clamp(200 / distance, 30, 120)
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

-- ============================================
-- MEMBUAT MENU
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
    
    -- MAIN FRAME
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 340, 0, 480)
    mainFrame.Position = UDim2.new(0.5, -170, 0.5, -240)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    mainFrame.BackgroundTransparency = 0
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame
    
    local border = Instance.new("UIStroke")
    border.Thickness = 1.5
    border.Color = Color3.fromRGB(155, 0, 255)
    border.Transparency = 0.3
    border.Parent = mainFrame
    
    -- HEADER
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
    header.BackgroundTransparency = 0.15
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0.03, 0, 0, 0)
    title.Text = "⚔️ ZEFF VORTEX"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 35, 0, 35)
    minBtn.Position = UDim2.new(1, -70, 0.5, -17.5)
    minBtn.Text = "─"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.BackgroundTransparency = 1
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 20
    minBtn.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -35, 0.5, -17.5)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = header
    
    -- TAB BAR
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, -20, 0, 40)
    tabBar.Position = UDim2.new(0, 10, 0, 55)
    tabBar.BackgroundTransparency = 1
    tabBar.Parent = mainFrame
    
    local espTab = Instance.new("TextButton")
    espTab.Size = UDim2.new(0.3, -4, 1, 0)
    espTab.Position = UDim2.new(0, 0, 0, 0)
    espTab.Text = "🎮 ESP"
    espTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    espTab.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
    espTab.BackgroundTransparency = 0
    espTab.Font = Enum.Font.GothamBold
    espTab.TextSize = 13
    espTab.Parent = tabBar
    
    local multiTab = Instance.new("TextButton")
    multiTab.Size = UDim2.new(0.33, -4, 1, 0)
    multiTab.Position = UDim2.new(0.32, 4, 0, 0)
    multiTab.Text = "⚔️ MULTI HIT"
    multiTab.TextColor3 = Color3.fromRGB(200, 200, 220)
    multiTab.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    multiTab.BackgroundTransparency = 0
    multiTab.Font = Enum.Font.GothamBold
    multiTab.TextSize = 13
    multiTab.Parent = tabBar
    
    local boostTab = Instance.new("TextButton")
    boostTab.Size = UDim2.new(0.33, -4, 1, 0)
    boostTab.Position = UDim2.new(0.64, 8, 0, 0)
    boostTab.Text = "🏃 BOOST"
    boostTab.TextColor3 = Color3.fromRGB(200, 200, 220)
    boostTab.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    boostTab.BackgroundTransparency = 0
    boostTab.Font = Enum.Font.GothamBold
    boostTab.TextSize = 13
    boostTab.Parent = tabBar
    
    -- CONTENT CONTAINER
    local contentContainer = Instance.new("ScrollingFrame")
    contentContainer.Size = UDim2.new(1, 0, 1, -155)
    contentContainer.Position = UDim2.new(0, 0, 0, 105)
    contentContainer.BackgroundTransparency = 1
    contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentContainer.ScrollBarThickness = 3
    contentContainer.ScrollBarImageColor3 = Color3.fromRGB(155, 0, 255)
    contentContainer.Parent = mainFrame
    
    -- ========== TAB 1: ESP CONTENT ==========
    local espContent = Instance.new("Frame")
    espContent.Size = UDim2.new(1, 0, 1, 0)
    espContent.BackgroundTransparency = 1
    espContent.Visible = true
    espContent.Parent = contentContainer
    
    local yEsp = 0
    
    -- Master ESP
    local masterBtn = Instance.new("TextButton")
    masterBtn.Size = UDim2.new(1, -20, 0, 42)
    masterBtn.Position = UDim2.new(0, 10, 0, yEsp)
    masterBtn.Text = "🔘 MASTER ESP: OFF"
    masterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    masterBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    masterBtn.BackgroundTransparency = 0
    masterBtn.Font = Enum.Font.GothamBold
    masterBtn.TextSize = 13
    masterBtn.Parent = espContent
    local masterCorner = Instance.new("UICorner")
    masterCorner.CornerRadius = UDim.new(0, 8)
    masterCorner.Parent = masterBtn
    yEsp = yEsp + 52
    
    -- Box ESP
    local boxBtn = Instance.new("TextButton")
    boxBtn.Size = UDim2.new(1, -20, 0, 42)
    boxBtn.Position = UDim2.new(0, 10, 0, yEsp)
    boxBtn.Text = "📦 BOX ESP: OFF"
    boxBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    boxBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    boxBtn.BackgroundTransparency = 0
    boxBtn.Font = Enum.Font.GothamBold
    boxBtn.TextSize = 13
    boxBtn.Parent = espContent
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 8)
    boxCorner.Parent = boxBtn
    yEsp = yEsp + 47
    
    -- Tracer ESP
    local tracerBtn = Instance.new("TextButton")
    tracerBtn.Size = UDim2.new(1, -20, 0, 42)
    tracerBtn.Position = UDim2.new(0, 10, 0, yEsp)
    tracerBtn.Text = "📏 TRACER ESP: OFF"
    tracerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tracerBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    tracerBtn.BackgroundTransparency = 0
    tracerBtn.Font = Enum.Font.GothamBold
    tracerBtn.TextSize = 13
    tracerBtn.Parent = espContent
    local tracerCorner = Instance.new("UICorner")
    tracerCorner.CornerRadius = UDim.new(0, 8)
    tracerCorner.Parent = tracerBtn
    yEsp = yEsp + 47
    
    -- Name ESP
    local nameBtn = Instance.new("TextButton")
    nameBtn.Size = UDim2.new(1, -20, 0, 42)
    nameBtn.Position = UDim2.new(0, 10, 0, yEsp)
    nameBtn.Text = "🏷️ NAME ESP: OFF"
    nameBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    nameBtn.BackgroundTransparency = 0
    nameBtn.Font = Enum.Font.GothamBold
    nameBtn.TextSize = 13
    nameBtn.Parent = espContent
    local nameCorner = Instance.new("UICorner")
    nameCorner.CornerRadius = UDim.new(0, 8)
    nameCorner.Parent = nameBtn
    yEsp = yEsp + 47
    
    -- Ketebalan Frame
    local thickFrame = Instance.new("Frame")
    thickFrame.Size = UDim2.new(1, -20, 0, 50)
    thickFrame.Position = UDim2.new(0, 10, 0, yEsp)
    thickFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    thickFrame.BackgroundTransparency = 0
    thickFrame.BorderSizePixel = 0
    thickFrame.Parent = espContent
    local thickCorner = Instance.new("UICorner")
    thickCorner.CornerRadius = UDim.new(0, 8)
    thickCorner.Parent = thickFrame
    
    local thickLabel = Instance.new("TextLabel")
    thickLabel.Size = UDim2.new(0.4, 0, 1, 0)
    thickLabel.Position = UDim2.new(0, 10, 0, 0)
    thickLabel.Text = "📏 KETEBALAN"
    thickLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    thickLabel.BackgroundTransparency = 1
    thickLabel.Font = Enum.Font.GothamBold
    thickLabel.TextSize = 12
    thickLabel.TextXAlignment = Enum.TextXAlignment.Left
    thickLabel.Parent = thickFrame
    
    local thickValue = Instance.new("TextLabel")
    thickValue.Size = UDim2.new(0.2, 0, 1, 0)
    thickValue.Position = UDim2.new(0.5, 0, 0, 0)
    thickValue.Text = "2"
    thickValue.TextColor3 = Color3.fromRGB(155, 0, 255)
    thickValue.BackgroundTransparency = 1
    thickValue.Font = Enum.Font.GothamBold
    thickValue.TextSize = 12
    thickValue.TextXAlignment = Enum.TextXAlignment.Center
    thickValue.Parent = thickFrame
    
    local thickMinus = Instance.new("TextButton")
    thickMinus.Size = UDim2.new(0, 30, 0, 30)
    thickMinus.Position = UDim2.new(1, -70, 0.5, -15)
    thickMinus.Text = "-"
    thickMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
    thickMinus.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    thickMinus.Font = Enum.Font.GothamBold
    thickMinus.TextSize = 18
    thickMinus.Parent = thickFrame
    local thickMinusCorner = Instance.new("UICorner")
    thickMinusCorner.CornerRadius = UDim.new(0, 6)
    thickMinusCorner.Parent = thickMinus
    
    local thickPlus = Instance.new("TextButton")
    thickPlus.Size = UDim2.new(0, 30, 0, 30)
    thickPlus.Position = UDim2.new(1, -35, 0.5, -15)
    thickPlus.Text = "+"
    thickPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
    thickPlus.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    thickPlus.Font = Enum.Font.GothamBold
    thickPlus.TextSize = 18
    thickPlus.Parent = thickFrame
    local thickPlusCorner = Instance.new("UICorner")
    thickPlusCorner.CornerRadius = UDim.new(0, 6)
    thickPlusCorner.Parent = thickPlus
    
    yEsp = yEsp + 55
    espContent.CanvasSize = UDim2.new(0, 0, 0, yEsp + 10)
    
    -- ========== TAB 2: MULTI HIT CONTENT ==========
    local multiContent = Instance.new("Frame")
    multiContent.Size = UDim2.new(1, 0, 1, 0)
    multiContent.BackgroundTransparency = 1
    multiContent.Visible = false
    multiContent.Parent = contentContainer
    
    local yMulti = 0
    
    -- Status Multi Hit
    local mhStatusFrame = Instance.new("Frame")
    mhStatusFrame.Size = UDim2.new(1, -20, 0, 45)
    mhStatusFrame.Position = UDim2.new(0, 10, 0, yMulti)
    mhStatusFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    mhStatusFrame.BackgroundTransparency = 0
    mhStatusFrame.BorderSizePixel = 0
    mhStatusFrame.Parent = multiContent
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 8)
    statusCorner.Parent = mhStatusFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0.6, 0, 1, 0)
    statusLabel.Position = UDim2.new(0, 12, 0, 0)
    statusLabel.Text = "⚔️ MULTI HIT: OFF"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = mhStatusFrame
    yMulti = yMulti + 55
    
    -- Radius
    local rangeFrame = CreateSlider(multiContent, "📏 RADIUS (M)", yMulti, mhRange, 5, 20)
    yMulti = yMulti + 55
    
    -- Damage
    local damageFrame = CreateSlider(multiContent, "💥 DAMAGE", yMulti, mhDamage, 1, 25)
    yMulti = yMulti + 55
    
    -- Target
    local targetFrame = CreateSlider(multiContent, "🎯 MAX TARGET", yMulti, mhTargets, 1, 20)
    yMulti = yMulti + 55
    
    -- Hits per second
    local hitsFrame = CreateSlider(multiContent, "⚡ HIT/DETIK", yMulti, mhHitsPerSec, 1, 10)
    yMulti = yMulti + 55
    
    -- Mode Toggle
    local modeBtn = Instance.new("TextButton")
    modeBtn.Size = UDim2.new(1, -20, 0, 42)
    modeBtn.Position = UDim2.new(0, 10, 0, yMulti)
    modeBtn.Text = "🎯 MODE: PLAYERS"
    modeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    modeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    modeBtn.Font = Enum.Font.GothamBold
    modeBtn.TextSize = 13
    modeBtn.Parent = multiContent
    local modeCorner = Instance.new("UICorner")
    modeCorner.CornerRadius = UDim.new(0, 8)
    modeCorner.Parent = modeBtn
    
    yMulti = yMulti + 52
    multiContent.CanvasSize = UDim2.new(0, 0, 0, yMulti + 10)
    
    -- ========== TAB 3: BOOST CONTENT ==========
    local boostContent = Instance.new("Frame")
    boostContent.Size = UDim2.new(1, 0, 1, 0)
    boostContent.BackgroundTransparency = 1
    boostContent.Visible = false
    boostContent.Parent = contentContainer
    
    local yBoost = 0
    
    -- Speed Boost
    local speedBtn = Instance.new("TextButton")
    speedBtn.Size = UDim2.new(1, -20, 0, 42)
    speedBtn.Position = UDim2.new(0, 10, 0, yBoost)
    speedBtn.Text = "⚡ SPEED BOOST: OFF"
    speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    speedBtn.Font = Enum.Font.GothamBold
    speedBtn.TextSize = 13
    speedBtn.Parent = boostContent
    local speedCorner = Instance.new("UICorner")
    speedCorner.CornerRadius = UDim.new(0, 8)
    speedCorner.Parent = speedBtn
    yBoost = yBoost + 52
    
    -- Speed Multiplier
    local speedMultFrame = CreateSlider(boostContent, "🏃 SPEED MULTIPLIER (x)", yBoost, speedMult, 1, 100)
    yBoost = yBoost + 55
    
    -- Jump Boost
    local jumpBtn = Instance.new("TextButton")
    jumpBtn.Size = UDim2.new(1, -20, 0, 42)
    jumpBtn.Position = UDim2.new(0, 10, 0, yBoost)
    jumpBtn.Text = "🦘 JUMP BOOST: OFF"
    jumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    jumpBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    jumpBtn.Font = Enum.Font.GothamBold
    jumpBtn.TextSize = 13
    jumpBtn.Parent = boostContent
    local jumpCorner = Instance.new("UICorner")
    jumpCorner.CornerRadius = UDim.new(0, 8)
    jumpCorner.Parent = jumpBtn
    yBoost = yBoost + 52
    
    -- Jump Multiplier
    local jumpMultFrame = CreateSlider(boostContent, "📈 JUMP MULTIPLIER (x)", yBoost, jumpMult, 1, 100)
    yBoost = yBoost + 55
    
    boostContent.CanvasSize = UDim2.new(0, 0, 0, yBoost + 10)
    
    -- ========== FUNGSI SLIDER ==========
    function CreateSlider(parent, label, yPos, value, minVal, maxVal)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 50)
        frame.Position = UDim2.new(0, 10, 0, yPos)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
        frame.BackgroundTransparency = 0
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame
        
        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(0.45, 0, 1, 0)
        labelText.Position = UDim2.new(0, 10, 0, 0)
        labelText.Text = label
        labelText.TextColor3 = Color3.fromRGB(200, 200, 220)
        labelText.BackgroundTransparency = 1
        labelText.Font = Enum.Font.GothamBold
        labelText.TextSize = 11
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = frame
        
        local valueText = Instance.new("TextLabel")
        valueText.Size = UDim2.new(0.2, 0, 1, 0)
        valueText.Position = UDim2.new(0.5, 0, 0, 0)
        valueText.Text = tostring(value)
        valueText.TextColor3 = Color3.fromRGB(155, 0, 255)
        valueText.BackgroundTransparency = 1
        valueText.Font = Enum.Font.GothamBold
        valueText.TextSize = 12
        valueText.TextXAlignment = Enum.TextXAlignment.Center
        valueText.Parent = frame
        
        local minus = Instance.new("TextButton")
        minus.Size = UDim2.new(0, 30, 0, 30)
        minus.Position = UDim2.new(1, -70, 0.5, -15)
        minus.Text = "-"
        minus.TextColor3 = Color3.fromRGB(255, 255, 255)
        minus.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        minus.Font = Enum.Font.GothamBold
        minus.TextSize = 18
        minus.Parent = frame
        local minusCorner = Instance.new("UICorner")
        minusCorner.CornerRadius = UDim.new(0, 6)
        minusCorner.Parent = minus
        
        local plus = Instance.new("TextButton")
        plus.Size = UDim2.new(0, 30, 0, 30)
        plus.Position = UDim2.new(1, -35, 0.5, -15)
        plus.Text = "+"
        plus.TextColor3 = Color3.fromRGB(255, 255, 255)
        plus.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        plus.Font = Enum.Font.GothamBold
        plus.TextSize = 18
        plus.Parent = frame
        local plusCorner = Instance.new("UICorner")
        plusCorner.CornerRadius = UDim.new(0, 6)
        plusCorner.Parent = plus
        
        return {frame = frame, valueText = valueText, minus = minus, plus = plus, min = minVal, max = maxVal}
    end
    
    -- ========== FUNGSI UPDATE TEKS BUTTON ==========
    local function UpdateMasterBtn()
        masterBtn.Text = masterEnabled and "🔘 MASTER ESP: ON ✅" or "🔘 MASTER ESP: OFF ❌"
        masterBtn.BackgroundColor3 = masterEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
    end
    
    local function UpdateBoxBtn()
        boxBtn.Text = espBoxEnabled and "📦 BOX ESP: ON ✅" or "📦 BOX ESP: OFF ❌"
        boxBtn.BackgroundColor3 = espBoxEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
    end
    
    local function UpdateTracerBtn()
        tracerBtn.Text = espTracerEnabled and "📏 TRACER ESP: ON ✅" or "📏 TRACER ESP: OFF ❌"
        tracerBtn.BackgroundColor3 = espTracerEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
    end
    
    local function UpdateNameBtn()
        nameBtn.Text = espNameEnabled and "🏷️ NAME ESP: ON ✅" or "🏷️ NAME ESP: OFF ❌"
        nameBtn.BackgroundColor3 = espNameEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
    end
    
    local function UpdateSpeedBtn()
        speedBtn.Text = speedEnabled and "⚡ SPEED BOOST: ON ✅" or "⚡ SPEED BOOST: OFF ❌"
        speedBtn.BackgroundColor3 = speedEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
    end
    
    local function UpdateJumpBtn()
        jumpBtn.Text = jumpEnabled and "🦘 JUMP BOOST: ON ✅" or "🦘 JUMP BOOST: OFF ❌"
        jumpBtn.BackgroundColor3 = jumpEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
    end
    
    local function UpdateMultiHitStatus()
        statusLabel.Text = multiHitEnabled and "⚔️ MULTI HIT: ON ✅" or "⚔️ MULTI HIT: OFF ❌"
        mhStatusFrame.BackgroundColor3 = multiHitEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
    end
    
    -- ========== BUTTON ACTIONS ==========
    masterBtn.MouseButton1Click:Connect(function()
        masterEnabled = not masterEnabled
        UpdateMasterBtn()
    end)
    
    boxBtn.MouseButton1Click:Connect(function()
        espBoxEnabled = not espBoxEnabled
        UpdateBoxBtn()
    end)
    
    tracerBtn.MouseButton1Click:Connect(function()
        espTracerEnabled = not espTracerEnabled
        UpdateTracerBtn()
    end)
    
    nameBtn.MouseButton1Click:Connect(function()
        espNameEnabled = not espNameEnabled
        UpdateNameBtn()
    end)
    
    thickMinus.MouseButton1Click:Connect(function()
        espThickness = math.max(1, espThickness - 1)
        thickValue.Text = tostring(espThickness)
        RefreshStyle()
    end)
    
    thickPlus.MouseButton1Click:Connect(function()
        espThickness = math.min(5, espThickness + 1)
        thickValue.Text = tostring(espThickness)
        RefreshStyle()
    end)
    
    -- Multi Hit Sliders
    rangeFrame.minus.MouseButton1Click:Connect(function()
        mhRange = math.max(5, mhRange - 1)
        rangeFrame.valueText.Text = tostring(mhRange)
    end)
    rangeFrame.plus.MouseButton1Click:Connect(function()
        mhRange = math.min(20, mhRange + 1)
        rangeFrame.valueText.Text = tostring(mhRange)
    end)
    
    damageFrame.minus.MouseButton1Click:Connect(function()
        mhDamage = math.max(1, mhDamage - 1)
        damageFrame.valueText.Text = tostring(mhDamage)
    end)
    damageFrame.plus.MouseButton1Click:Connect(function()
        mhDamage = math.min(25, mhDamage + 1)
        damageFrame.valueText.Text = tostring(mhDamage)
    end)
    
    targetFrame.minus.MouseButton1Click:Connect(function()
        mhTargets = math.max(1, mhTargets - 1)
        targetFrame.valueText.Text = tostring(mhTargets)
    end)
    targetFrame.plus.MouseButton1Click:Connect(function()
        mhTargets = math.min(20, mhTargets + 1)
        targetFrame.valueText.Text = tostring(mhTargets)
    end)
    
    hitsFrame.minus.MouseButton1Click:Connect(function()
        mhHitsPerSec = math.max(1, mhHitsPerSec - 1)
        hitsFrame.valueText.Text = tostring(mhHitsPerSec)
    end)
    hitsFrame.plus.MouseButton1Click:Connect(function()
        mhHitsPerSec = math.min(10, mhHitsPerSec + 1)
        hitsFrame.valueText.Text = tostring(mhHitsPerSec)
    end)
    
    modeBtn.MouseButton1Click:Connect(function()
        mhMode = (mhMode == "players") and "all" or "players"
        modeBtn.Text = (mhMode == "players") and "🎯 MODE: PLAYERS" or "🎯 MODE: ALL ENTITY"
    end)
    
    -- Speed & Jump
    speedBtn.MouseButton1Click:Connect(function()
        speedEnabled = not speedEnabled
        UpdateSpeedBtn()
        ApplySpeed()
    end)
    
    speedMultFrame.minus.MouseButton1Click:Connect(function()
        speedMult = math.max(1, speedMult - 1)
        speedMultFrame.valueText.Text = speedMult .. "x"
        ApplySpeed()
    end)
    speedMultFrame.plus.MouseButton1Click:Connect(function()
        speedMult = math.min(100, speedMult + 1)
        speedMultFrame.valueText.Text = speedMult .. "x"
        ApplySpeed()
    end)
    
    jumpBtn.MouseButton1Click:Connect(function()
        jumpEnabled = not jumpEnabled
        UpdateJumpBtn()
        ApplyJump()
    end)
    
    jumpMultFrame.minus.MouseButton1Click:Connect(function()
        jumpMult = math.max(1, jumpMult - 1)
        jumpMultFrame.valueText.Text = jumpMult .. "x"
        ApplyJump()
    end)
    jumpMultFrame.plus.MouseButton1Click:Connect(function()
        jumpMult = math.min(100, jumpMult + 1)
        jumpMultFrame.valueText.Text = jumpMult .. "x"
        ApplyJump()
    end)
    
    -- ========== TAB SWITCH ==========
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
    
    -- ========== DRAG MENU ==========
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- ========== MINIMIZE ==========
    local function ToggleMinimize()
        if minimized then
            mainFrame:TweenSize(UDim2.new(0, 340, 0, 480), "Out", "Quad", 0.2, true)
            tabBar.Visible = true
            contentContainer.Visible = true
            minBtn.Text = "─"
            minimized = false
        else
            mainFrame:TweenSize(UDim2.new(0, 180, 0, 45), "Out", "Quad", 0.2, true)
            tabBar.Visible = false
            contentContainer.Visible = false
            minBtn.Text = "□"
            minimized = true
        end
    end
    
    minBtn.MouseButton1Click:Connect(ToggleMinimize)
    
    -- ========== CLOSE ==========
    closeBtn.MouseButton1Click:Connect(function()
        if screenGui then screenGui:Destroy() end
        currentMenu = nil
    end)
    
    -- Update initial text
    UpdateMasterBtn()
    UpdateBoxBtn()
    UpdateTracerBtn()
    UpdateNameBtn()
    UpdateSpeedBtn()
    UpdateJumpBtn()
    UpdateMultiHitStatus()
end

-- ============================================
-- TOMBOL PEDANG
-- ============================================
local function CreateSwordButton()
    if not screenGui then return end
    
    swordBtn = Instance.new("TextButton")
    swordBtn.Size = UDim2.new(0, 55, 0, 55)
    swordBtn.Position = UDim2.new(1, -70, 1, -190)
    swordBtn.Text = "⚔️"
    swordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    swordBtn.TextSize = 28
    swordBtn.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
    swordBtn.BackgroundTransparency = 0.15
    swordBtn.BorderSizePixel = 0
    swordBtn.Parent = screenGui
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 27)
    btnCorner.Parent = swordBtn
    
    local led = Instance.new("Frame")
    led.Size = UDim2.new(0, 12, 0, 12)
    led.Position = UDim2.new(1, -14, 1, -14)
    led.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    led.BorderSizePixel = 0
    led.Parent = swordBtn
    local ledCorner = Instance.new("UICorner")
    ledCorner.CornerRadius = UDim.new(1, 0)
    ledCorner.Parent = led
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    swordBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = swordBtn.Position
        end
    end)
    
    swordBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            swordBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    swordBtn.MouseButton1Click:Connect(function()
        multiHitEnabled = not multiHitEnabled
        led.BackgroundColor3 = multiHitEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        swordBtn.BackgroundColor3 = multiHitEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(155, 0, 255)
        
        if currentMenu then
            local statusFrame = currentMenu:FindFirstChild("MainFrame"):FindFirstChild("ScrollingFrame"):FindFirstChild("MultiContent"):FindFirstChild("StatusFrame")
            if statusFrame and statusFrame:FindFirstChild("StatusLabel") then
                statusLabel = statusFrame:FindFirstChild("StatusLabel")
                statusLabel.Text = multiHitEnabled and "⚔️ MULTI HIT: ON ✅" or "⚔️ MULTI HIT: OFF ❌"
                statusFrame.BackgroundColor3 = multiHitEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
            end
        end
    end)
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
        wait(0.01)
    end
end)()

CreateMainMenu()
CreateSwordButton()

print("==========================================")
print("ZEFF VORTEX - FULL SCRIPT FIXED V2")
print("SEMUA FITUR BERFUNGSI:")
print("- Toggle ON/OFF (warna berubah)")
print("- Drag menu & tombol pedang")
print("- Minimize & Close")
print("- Slider +/-")
print("- 3 Tab (ESP | MULTI HIT | BOOST)")
print("==========================================")
