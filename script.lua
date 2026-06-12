-- ============================================
-- ZEFF VORTEX - FULL SCRIPT
-- KATEGORI: ESP + COMBAT
-- FITUR COMBAT: MULTI DAMAGE (2x-10x) & MULTI HIT (1-10 target)
-- UNIVERSAL UNTUK SEMUA GAME
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
-- VARIABEL COMBAT
-- ============================================
local multiDamageEnabled = false
local multiDamageValue = 5  -- default 5x
local multiHitEnabled = false
local multiHitValue = 5     -- default 5 target

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local espList = {}

-- ============================================
-- FUNGSI COMBAT (UNIVERSAL)
-- ============================================

-- Multi Damage: Gandakan damage yang keluar
local function OnDamageDealt(damage, target)
    if multiDamageEnabled then
        return damage * multiDamageValue
    end
    return damage
end

-- Hook ke fungsi damage (universal untuk semua game)
local function SetupCombatHooks()
    -- Method 1: Hook ke Humanoid:TakeDamage
    local oldTakeDamage
    oldTakeDamage = hookfunction(Instance.new("Humanoid").TakeDamage, function(self, amount)
        if multiDamageEnabled and self and self.Parent and self.Parent:FindFirstChild("Humanoid") then
            local newAmount = amount * multiDamageValue
            return oldTakeDamage(self, newAmount)
        end
        return oldTakeDamage(self, amount)
    end)
    
    -- Method 2: Hook ke Damageable (untuk game tertentu)
    local oldDamageFunction
    if game:GetService("ReplicatedStorage"):FindFirstChild("Damage") then
        -- Contoh untuk game yang pake RemoteEvent
        -- Bisa disesuaikan
    end
end

-- Multi Hit: Menyerang banyak target sekaligus
local function GetNearbyTargets(radius)
    local targets = {}
    local character = LocalPlayer.Character
    if not character then return targets end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return targets end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local targetChar = player.Character
            if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                local targetRoot = targetChar.HumanoidRootPart
                local distance = (rootPart.Position - targetRoot.Position).Magnitude
                if distance <= (radius or 30) then
                    table.insert(targets, player)
                end
            end
        end
    end
    
    -- Juga bisa target NPC/怪物
    for _, npc in ipairs(workspace:GetChildren()) do
        if npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
            if npc ~= character then
                local distance = (rootPart.Position - npc.HumanoidRootPart.Position).Magnitude
                if distance <= (radius or 30) then
                    table.insert(targets, npc)
                end
            end
        end
    end
    
    return targets
end

-- Fungsi untuk serangan multi target (panggil manual atau auto)
local function AttackMultiTargets()
    if not multiHitEnabled then return end
    
    local targets = GetNearbyTargets(40)
    local hitCount = math.min(multiHitValue, #targets)
    
    for i = 1, hitCount do
        local target = targets[i]
        if target then
            -- Coba berbagai metode serangan
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChild("Humanoid")
            local targetHumanoid = target:FindFirstChild("Humanoid") or (target.Character and target.Character:FindFirstChild("Humanoid"))
            
            if targetHumanoid then
                -- Method 1: Langsung damage
                local damage = 10 * (multiDamageEnabled and multiDamageValue or 1)
                targetHumanoid:TakeDamage(damage)
                
                -- Method 2: Trigger remote (untuk game online)
                pcall(function()
                    local replicatedStorage = game:GetService("ReplicatedStorage")
                    for _, remote in ipairs(replicatedStorage:GetDescendants()) do
                        if remote:IsA("RemoteEvent") and remote.Name:lower():find("damage") or remote.Name:lower():find("attack") then
                            remote:FireServer(target, damage)
                        elseif remote:IsA("RemoteFunction") then
                            pcall(function() remote:InvokeServer(target, damage) end)
                        end
                    end
                end)
            end
        end
    end
end

-- Auto attack loop (opsional)
local autoAttackEnabled = false
local autoAttackConnection = nil

local function StartAutoAttack()
    if autoAttackConnection then autoAttackConnection:Disconnect() end
    autoAttackConnection = RunService.RenderStepped:Connect(function()
        if autoAttackEnabled and multiHitEnabled then
            AttackMultiTargets()
        end
    end)
end

local function StopAutoAttack()
    if autoAttackConnection then
        autoAttackConnection:Disconnect()
        autoAttackConnection = nil
    end
end

-- ============================================
-- FUNGSI ESP (SAMA SEPERTI SEBELUMNYA)
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

local function UpdateBox(box, rootPart)
    if not box or not rootPart then return end
    local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen then box.Visible = false return end
    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
    local boxSize = math.clamp(200 / distance, 30, 120)
    local boxX = vector.X - boxSize / 2
    local boxY = vector.Y - boxSize / 1.2
    box.Size = Vector2.new(boxSize, boxSize)
    box.Position = Vector2.new(boxX, boxY)
    box.Visible = true
end

local function UpdateTracer(tracer, rootPart, center)
    if not tracer or not rootPart then return end
    local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen then tracer.Visible = false return end
    tracer.From = center
    tracer.To = Vector2.new(vector.X, vector.Y)
    tracer.Visible = true
end

local function UpdateName(nameTag, player, rootPart)
    if not nameTag or not rootPart then return end
    local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen then nameTag.Visible = false return end
    nameTag.Text = player.Name
    nameTag.Position = Vector2.new(vector.X, vector.Y - 25)
    nameTag.Visible = true
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
            if espBoxEnabled and esp.box then UpdateBox(esp.box, rootPart)
            elseif esp.box then esp.box.Visible = false end
            
            if espTracerEnabled and esp.tracer then UpdateTracer(esp.tracer, rootPart, center)
            elseif esp.tracer then esp.tracer.Visible = false end
            
            if espNameEnabled and esp.nameTag then UpdateName(esp.nameTag, esp.player, rootPart)
            elseif esp.nameTag then esp.nameTag.Visible = false end
        end
    end
end

local function RefreshStyle()
    for _, esp in pairs(espList) do
        if esp.box then esp.box.Color = espColor; esp.box.Thickness = espThickness end
        if esp.tracer then esp.tracer.Color = espColor; esp.tracer.Thickness = espThickness end
        if esp.nameTag then esp.nameTag.Color = espColor end
    end
end

-- INIT PLAYERS ESP
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then CreateESP(player) end
end
Players.PlayerAdded:Connect(function(player) if player ~= LocalPlayer then CreateESP(player) end end)
Players.PlayerRemoving:Connect(RemoveESP)
RunService.RenderStepped:Connect(UpdateAllESP)

-- Setup Combat Hooks
SetupCombatHooks()

-- ============================================
-- MENU DENGAN 3 KATEGORI
-- ============================================
local minimized = false
local currentMenu = nil
local currentCategory = "ESP"

local function CreateMainMenu()
    if currentMenu then currentMenu:Destroy() currentMenu = nil end
    
    local CoreGui = game:GetService("CoreGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ZeffVortexMenu"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local success = pcall(function() screenGui.Parent = (gethui and gethui()) or CoreGui end)
    if not success then screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
    currentMenu = screenGui
    
    -- MAIN FRAME
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    mainFrame.BackgroundTransparency = 0
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame
    
    local border = Instance.new("UIStroke")
    border.Thickness = 1
    border.Color = Color3.fromRGB(155, 0, 255)
    border.Transparency = 0.3
    border.Parent = mainFrame
    
    -- HEADER
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
    header.BackgroundTransparency = 0.15
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.Position = UDim2.new(0.03, 0, 0, 0)
    title.Text = "🔮 ZEFF VORTEX"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 28, 0, 28)
    minBtn.Position = UDim2.new(1, -62, 0.5, -14)
    minBtn.Text = "─"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.BackgroundTransparency = 1
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 16
    minBtn.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -32, 0.5, -14)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = header
    
    -- KATEGORI TAB (3 tabs: ESP, COMBAT, OTHER)
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, -16, 0, 36)
    tabBar.Position = UDim2.new(0, 8, 0, 48)
    tabBar.BackgroundTransparency = 1
    tabBar.Parent = mainFrame
    
    local espTab = Instance.new("TextButton")
    espTab.Size = UDim2.new(0.32, -4, 1, 0)
    espTab.Position = UDim2.new(0, 0, 0, 0)
    espTab.Text = "🎮 ESP"
    espTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    espTab.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
    espTab.BackgroundTransparency = 0.2
    espTab.Font = Enum.Font.GothamBold
    espTab.TextSize = 12
    espTab.Parent = tabBar
    local espTabCorner = Instance.new("UICorner")
    espTabCorner.CornerRadius = UDim.new(0, 8)
    espTabCorner.Parent = espTab
    
    local combatTab = Instance.new("TextButton")
    combatTab.Size = UDim2.new(0.32, -4, 1, 0)
    combatTab.Position = UDim2.new(0.34, 0, 0, 0)
    combatTab.Text = "⚔️ COMBAT"
    combatTab.TextColor3 = Color3.fromRGB(200, 200, 220)
    combatTab.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    combatTab.BackgroundTransparency = 0
    combatTab.Font = Enum.Font.GothamBold
    combatTab.TextSize = 12
    combatTab.Parent = tabBar
    local combatTabCorner = Instance.new("UICorner")
    combatTabCorner.CornerRadius = UDim.new(0, 8)
    combatTabCorner.Parent = combatTab
    
    local otherTab = Instance.new("TextButton")
    otherTab.Size = UDim2.new(0.32, -4, 1, 0)
    otherTab.Position = UDim2.new(0.68, 0, 0, 0)
    otherTab.Text = "⚙ OTHER"
    otherTab.TextColor3 = Color3.fromRGB(200, 200, 220)
    otherTab.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    otherTab.BackgroundTransparency = 0
    otherTab.Font = Enum.Font.GothamBold
    otherTab.TextSize = 12
    otherTab.Parent = tabBar
    local otherTabCorner = Instance.new("UICorner")
    otherTabCorner.CornerRadius = UDim.new(0, 8)
    otherTabCorner.Parent = otherTab
    
    -- CONTENT AREA
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -16, 1, -110)
    content.Position = UDim2.new(0, 8, 0, 92)
    content.BackgroundTransparency = 1
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.ScrollBarThickness = 2
    content.ScrollBarImageColor3 = Color3.fromRGB(155, 0, 255)
    content.Parent = mainFrame
    
    local contentList = Instance.new("UIListLayout")
    contentList.Padding = UDim.new(0, 8)
    contentList.SortOrder = Enum.SortOrder.LayoutOrder
    contentList.Parent = content
    
    -- ========== KONTEN ESP ==========
    local function BuildESPTab()
        -- MASTER ESP
        local masterBtn = Instance.new("TextButton")
        masterBtn.Size = UDim2.new(1, 0, 0, 45)
        masterBtn.Text = "🔘 MASTER ESP"
        masterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        masterBtn.BackgroundColor3 = masterEnabled and Color3.fromRGB(155, 0, 255) or Color3.fromRGB(80, 0, 120)
        masterBtn.Font = Enum.Font.GothamBold
        masterBtn.TextSize = 14
        masterBtn.Parent = content
        local masterCorner = Instance.new("UICorner")
        masterCorner.CornerRadius = UDim.new(0, 8)
        masterCorner.Parent = masterBtn
        local masterStatus = Instance.new("TextLabel")
        masterStatus.Size = UDim2.new(0.35, 0, 1, 0)
        masterStatus.Position = UDim2.new(0.65, 0, 0, 0)
        masterStatus.Text = masterEnabled and "ON ✅" or "OFF"
        masterStatus.TextColor3 = masterEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        masterStatus.BackgroundTransparency = 1
        masterStatus.Font = Enum.Font.GothamBold
        masterStatus.TextSize = 12
        masterStatus.TextXAlignment = Enum.TextXAlignment.Right
        masterStatus.Parent = masterBtn
        
        -- BOX ESP
        local boxBtn = Instance.new("TextButton")
        boxBtn.Size = UDim2.new(1, 0, 0, 40)
        boxBtn.Text = "📦 BOX ESP"
        boxBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        boxBtn.BackgroundColor3 = espBoxEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
        boxBtn.Font = Enum.Font.GothamBold
        boxBtn.TextSize = 13
        boxBtn.Parent = content
        local boxCorner = Instance.new("UICorner")
        boxCorner.CornerRadius = UDim.new(0, 8)
        boxCorner.Parent = boxBtn
        local boxStatus = Instance.new("TextLabel")
        boxStatus.Size = UDim2.new(0.35, 0, 1, 0)
        boxStatus.Position = UDim2.new(0.65, 0, 0, 0)
        boxStatus.Text = espBoxEnabled and "ON ✅" or "OFF"
        boxStatus.TextColor3 = espBoxEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        boxStatus.BackgroundTransparency = 1
        boxStatus.Font = Enum.Font.GothamBold
        boxStatus.TextSize = 12
        boxStatus.TextXAlignment = Enum.TextXAlignment.Right
        boxStatus.Parent = boxBtn
        
        -- TRACER ESP
        local tracerBtn = Instance.new("TextButton")
        tracerBtn.Size = UDim2.new(1, 0, 0, 40)
        tracerBtn.Text = "📏 TRACER ESP"
        tracerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tracerBtn.BackgroundColor3 = espTracerEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
        tracerBtn.Font = Enum.Font.GothamBold
        tracerBtn.TextSize = 13
        tracerBtn.Parent = content
        local tracerCorner = Instance.new("UICorner")
        tracerCorner.CornerRadius = UDim.new(0, 8)
        tracerCorner.Parent = tracerBtn
        local tracerStatus = Instance.new("TextLabel")
        tracerStatus.Size = UDim2.new(0.35, 0, 1, 0)
        tracerStatus.Position = UDim2.new(0.65, 0, 0, 0)
        tracerStatus.Text = espTracerEnabled and "ON ✅" or "OFF"
        tracerStatus.TextColor3 = espTracerEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        tracerStatus.BackgroundTransparency = 1
        tracerStatus.Font = Enum.Font.GothamBold
        tracerStatus.TextSize = 12
        tracerStatus.TextXAlignment = Enum.TextXAlignment.Right
        tracerStatus.Parent = tracerBtn
        
        -- NAME ESP
        local nameBtn = Instance.new("TextButton")
        nameBtn.Size = UDim2.new(1, 0, 0, 40)
        nameBtn.Text = "🏷️ NAME ESP"
        nameBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameBtn.BackgroundColor3 = espNameEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
        nameBtn.Font = Enum.Font.GothamBold
        nameBtn.TextSize = 13
        nameBtn.Parent = content
        local nameCorner = Instance.new("UICorner")
        nameCorner.CornerRadius = UDim.new(0, 8)
        nameCorner.Parent = nameBtn
        local nameStatus = Instance.new("TextLabel")
        nameStatus.Size = UDim2.new(0.35, 0, 1, 0)
        nameStatus.Position = UDim2.new(0.65, 0, 0, 0)
        nameStatus.Text = espNameEnabled and "ON ✅" or "OFF"
        nameStatus.TextColor3 = espNameEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        nameStatus.BackgroundTransparency = 1
        nameStatus.Font = Enum.Font.GothamBold
        nameStatus.TextSize = 12
        nameStatus.TextXAlignment = Enum.TextXAlignment.Right
        nameStatus.Parent = nameBtn
        
        -- KETEBALAN
        local thickFrame = Instance.new("Frame")
        thickFrame.Size = UDim2.new(1, 0, 0, 45)
        thickFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
        thickFrame.BackgroundTransparency = 0
        thickFrame.BorderSizePixel = 0
        thickFrame.Parent = content
        local thickCorner = Instance.new("UICorner")
        thickCorner.CornerRadius = UDim.new(0, 8)
        thickCorner.Parent = thickFrame
        local thickLabel = Instance.new("TextLabel")
        thickLabel.Size = UDim2.new(0.45, 0, 1, 0)
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
        thickValue.Text = tostring(espThickness)
        thickValue.TextColor3 = Color3.fromRGB(155, 0, 255)
        thickValue.BackgroundTransparency = 1
        thickValue.Font = Enum.Font.GothamBold
        thickValue.TextSize = 13
        thickValue.TextXAlignment = Enum.TextXAlignment.Center
        thickValue.Parent = thickFrame
        local minusBtn = Instance.new("TextButton")
        minusBtn.Size = UDim2.new(0, 30, 0, 30)
        minusBtn.Position = UDim2.new(1, -70, 0.5, -15)
        minusBtn.Text = "-"
        minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        minusBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        minusBtn.Font = Enum.Font.GothamBold
        minusBtn.TextSize = 16
        minusBtn.Parent = thickFrame
        local plusBtn = Instance.new("TextButton")
        plusBtn.Size = UDim2.new(0, 30, 0, 30)
        plusBtn.Position = UDim2.new(1, -35, 0.5, -15)
        plusBtn.Text = "+"
        plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        plusBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        plusBtn.Font = Enum.Font.GothamBold
        plusBtn.TextSize = 16
        plusBtn.Parent = thickFrame
        local minusCorner = Instance.new("UICorner")
        minusCorner.CornerRadius = UDim.new(0, 6)
        minusCorner.Parent = minusBtn
        local plusCorner = Instance.new("UICorner")
        plusCorner.CornerRadius = UDim.new(0, 6)
        plusCorner.Parent = plusBtn
        
        -- UPDATE FUNCTIONS
        local function UpdateESPButtons()
            masterStatus.Text = masterEnabled and "ON ✅" or "OFF"
            masterStatus.TextColor3 = masterEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
            masterBtn.BackgroundColor3 = masterEnabled and Color3.fromRGB(155, 0, 255) or Color3.fromRGB(80, 0, 120)
            boxStatus.Text = espBoxEnabled and "ON ✅" or "OFF"
            boxStatus.TextColor3 = espBoxEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
            boxBtn.BackgroundColor3 = espBoxEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
            tracerStatus.Text = espTracerEnabled and "ON ✅" or "OFF"
            tracerStatus.TextColor3 = espTracerEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
            tracerBtn.BackgroundColor3 = espTracerEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
            nameStatus.Text = espNameEnabled and "ON ✅" or "OFF"
            nameStatus.TextColor3 = espNameEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
            nameBtn.BackgroundColor3 = espNameEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(35, 35, 50)
        end
        
        masterBtn.MouseButton1Click:Connect(function()
            masterEnabled = not masterEnabled
            UpdateESPButtons()
        end)
        boxBtn.MouseButton1Click:Connect(function()
            espBoxEnabled = not espBoxEnabled
            UpdateESPButtons()
        end)
        tracerBtn.MouseButton1Click:Connect(function()
            espTracerEnabled = not espTracerEnabled
            UpdateESPButtons()
        end)
        nameBtn.MouseButton1Click:Connect(function()
            espNameEnabled = not espNameEnabled
            UpdateESPButtons()
        end)
        minusBtn.MouseButton1Click:Connect(function()
            espThickness = math.max(1, espThickness - 1)
            thickValue.Text = tostring(espThickness)
            RefreshStyle()
        end)
        plusBtn.MouseButton1Click:Connect(function()
            espThickness = math.min(5, espThickness + 1)
            thickValue.Text = tostring(espThickness)
            RefreshStyle()
        end)
    end
    
    -- ========== KONTEN COMBAT (MULTI DAMAGE + MULTI HIT) ==========
    local function BuildCombatTab()
        -- Title
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, 0, 0, 30)
        titleLabel.Text = "⚔️ COMBAT MODE"
        titleLabel.TextColor3 = Color3.fromRGB(155, 0, 255)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 14
        titleLabel.TextXAlignment = Enum.TextXAlignment.Center
        titleLabel.Parent = content
        
        -- MULTI DAMAGE
        local damageFrame = Instance.new("Frame")
        damageFrame.Size = UDim2.new(1, 0, 0, 75)
        damageFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
        damageFrame.BackgroundTransparency = 0
        damageFrame.BorderSizePixel = 0
        damageFrame.Parent = content
        local damageCorner = Instance.new("UICorner")
        damageCorner.CornerRadius = UDim.new(0, 8)
        damageCorner.Parent = damageFrame
        
        local damageToggle = Instance.new("TextButton")
        damageToggle.Size = UDim2.new(0.5, -5, 0, 35)
        damageToggle.Position = UDim2.new(0, 5, 0, 8)
        damageToggle.Text = multiDamageEnabled and "🔘 MULTI DAMAGE: ON" or "⚪ MULTI DAMAGE: OFF"
        damageToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        damageToggle.BackgroundColor3 = multiDamageEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(45, 45, 60)
        damageToggle.Font = Enum.Font.GothamBold
        damageToggle.TextSize = 12
        damageToggle.Parent = damageFrame
        local damageToggleCorner = Instance.new("UICorner")
        damageToggleCorner.CornerRadius = UDim.new(0, 6)
        damageToggleCorner.Parent = damageToggle
        
        local damageValueLabel = Instance.new("TextLabel")
        damageValueLabel.Size = UDim2.new(0.25, 0, 0, 35)
        damageValueLabel.Position = UDim2.new(0.52, 0, 0, 8)
        damageValueLabel.Text = multiDamageValue .. "x"
        damageValueLabel.TextColor3 = Color3.fromRGB(155, 0, 255)
        damageValueLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        damageValueLabel.Font = Enum.Font.GothamBold
        damageValueLabel.TextSize = 16
        damageValueLabel.Parent = damageFrame
        local damageValueCorner = Instance.new("UICorner")
        damageValueCorner.CornerRadius = UDim.new(0, 6)
        damageValueCorner.Parent = damageValueLabel
        
        local damageMinus = Instance.new("TextButton")
        damageMinus.Size = UDim2.new(0, 30, 0, 30)
        damageMinus.Position = UDim2.new(1, -70, 0, 10)
        damageMinus.Text = "-"
        damageMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
        damageMinus.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        damageMinus.Font = Enum.Font.GothamBold
        damageMinus.TextSize = 16
        damageMinus.Parent = damageFrame
        local damageMinusCorner = Instance.new("UICorner")
        damageMinusCorner.CornerRadius = UDim.new(0, 6)
        damageMinusCorner.Parent = damageMinus
        
        local damagePlus = Instance.new("TextButton")
        damagePlus.Size = UDim2.new(0, 30, 0, 30)
        damagePlus.Position = UDim2.new(1, -35, 0, 10)
        damagePlus.Text = "+"
        damagePlus.TextColor3 = Color3.fromRGB(255, 255, 255)
        damagePlus.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        damagePlus.Font = Enum.Font.GothamBold
        damagePlus.TextSize = 16
        damagePlus.Parent = damageFrame
        local damagePlusCorner = Instance.new("UICorner")
        damagePlusCorner.CornerRadius = UDim.new(0, 6)
        damagePlusCorner.Parent = damagePlus
        
        local damageDesc = Instance.new("TextLabel")
        damageDesc.Size = UDim2.new(0.9, 0, 0, 18)
        damageDesc.Position = UDim2.new(0.05, 0, 0, 50)
        damageDesc.Text = "Gandakan damage keluar (2x - 10x)"
        damageDesc.TextColor3 = Color3.fromRGB(150, 150, 180)
        damageDesc.BackgroundTransparency = 1
        damageDesc.Font = Enum.Font.Gotham
        damageDesc.TextSize = 10
        damageDesc.TextXAlignment = Enum.TextXAlignment.Left
        damageDesc.Parent = damageFrame
        
        -- MULTI HIT
        local hitFrame = Instance.new("Frame")
        hitFrame.Size = UDim2.new(1, 0, 0, 75)
        hitFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
        hitFrame.BackgroundTransparency = 0
        hitFrame.BorderSizePixel = 0
        hitFrame.Parent = content
        local hitCorner = Instance.new("UICorner")
        hitCorner.CornerRadius = UDim.new(0, 8)
        hitCorner.Parent = hitFrame
        
        local hitToggle = Instance.new("TextButton")
        hitToggle.Size = UDim2.new(0.5, -5, 0, 35)
        hitToggle.Position = UDim2.new(0, 5, 0, 8)
        hitToggle.Text = multiHitEnabled and "🔘 MULTI HIT: ON" or "⚪ MULTI HIT: OFF"
        hitToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        hitToggle.BackgroundColor3 = multiHitEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(45, 45, 60)
        hitToggle.Font = Enum.Font.GothamBold
        hitToggle.TextSize = 12
        hitToggle.Parent = hitFrame
        local hitToggleCorner = Instance.new("UICorner")
        hitToggleCorner.CornerRadius = UDim.new(0, 6)
        hitToggleCorner.Parent = hitToggle
        
        local hitValueLabel = Instance.new("TextLabel")
        hitValueLabel.Size = UDim2.new(0.25, 0, 0, 35)
        hitValueLabel.Position = UDim2.new(0.52, 0, 0, 8)
        hitValueLabel.Text = multiHitValue .. " target"
        hitValueLabel.TextColor3 = Color3.fromRGB(155, 0, 255)
        hitValueLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        hitValueLabel.Font = Enum.Font.GothamBold
        hitValueLabel.TextSize = 14
        hitValueLabel.Parent = hitFrame
        local hitValueCorner = Instance.new("UICorner")
        hitValueCorner.CornerRadius = UDim.new(0, 6)
        hitValueCorner.Parent = hitValueLabel
        
        local hitMinus = Instance.new("TextButton")
        hitMinus.Size = UDim2.new(0, 30, 0, 30)
        hitMinus.Position = UDim2.new(1, -70, 0, 10)
        hitMinus.Text = "-"
        hitMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
        hitMinus.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        hitMinus.Font = Enum.Font.GothamBold
        hitMinus.TextSize = 16
        hitMinus.Parent = hitFrame
        local hitMinusCorner = Instance.new("UICorner")
        hitMinusCorner.CornerRadius = UDim.new(0, 6)
        hitMinusCorner.Parent = hitMinus
        
        local hitPlus = Instance.new("TextButton")
        hitPlus.Size = UDim2.new(0, 30, 0, 30)
        hitPlus.Position = UDim2.new(1, -35, 0, 10)
        hitPlus.Text = "+"
        hitPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
        hitPlus.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        hitPlus.Font = Enum.Font.GothamBold
        hitPlus.TextSize = 16
        hitPlus.Parent = hitFrame
        local hitPlusCorner = Instance.new("UICorner")
        hitPlusCorner.CornerRadius = UDim.new(0, 6)
        hitPlusCorner.Parent = hitPlus
        
        local hitDesc = Instance.new("TextLabel")
        hitDesc.Size = UDim2.new(0.9, 0, 0, 18)
        hitDesc.Position = UDim2.new(0.05, 0, 0, 50)
        hitDesc.Text = "Serang banyak target sekaligus (1 - 10 target)"
        hitDesc.TextColor3 = Color3.fromRGB(150, 150, 180)
        hitDesc.BackgroundTransparency = 1
        hitDesc.Font = Enum.Font.Gotham
        hitDesc.TextSize = 10
        hitDesc.TextXAlignment = Enum.TextXAlignment.Left
        hitDesc.Parent = hitFrame
        
        -- Attack Now Button
        local attackNow = Instance.new("TextButton")
        attackNow.Size = UDim2.new(1, 0, 0, 40)
        attackNow.Text = "💥 ATTACK NOW"
        attackNow.TextColor3 = Color3.fromRGB(255, 255, 255)
        attackNow.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
        attackNow.Font = Enum.Font.GothamBold
        attackNow.TextSize = 14
        attackNow.Parent = content
        local attackCorner = Instance.new("UICorner")
        attackCorner.CornerRadius = UDim.new(0, 8)
        attackCorner.Parent = attackNow
        
        -- Auto Attack Toggle
        local autoAttackBtn = Instance.new("TextButton")
        autoAttackBtn.Size = UDim2.new(1, 0, 0, 40)
        autoAttackBtn.Text = autoAttackEnabled and "🔄 AUTO ATTACK: ON" or "⏹️ AUTO ATTACK: OFF"
        autoAttackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        autoAttackBtn.BackgroundColor3 = autoAttackEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(45, 45, 60)
        autoAttackBtn.Font = Enum.Font.GothamBold
        autoAttackBtn.TextSize = 13
        autoAttackBtn.Parent = content
        local autoCorner = Instance.new("UICorner")
        autoCorner.CornerRadius = UDim.new(0, 8)
        autoCorner.Parent = autoAttackBtn
        
        -- UPDATE FUNCTIONS
        local function UpdateCombatUI()
            damageToggle.Text = multiDamageEnabled and "🔘 MULTI DAMAGE: ON" or "⚪ MULTI DAMAGE: OFF"
            damageToggle.BackgroundColor3 = multiDamageEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(45, 45, 60)
            damageValueLabel.Text = multiDamageValue .. "x"
            
            hitToggle.Text = multiHitEnabled and "🔘 MULTI HIT: ON" or "⚪ MULTI HIT: OFF"
            hitToggle.BackgroundColor3 = multiHitEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(45, 45, 60)
            hitValueLabel.Text = multiHitValue .. " target"
            
            autoAttackBtn.Text = autoAttackEnabled and "🔄 AUTO ATTACK: ON" or "⏹️ AUTO ATTACK: OFF"
            autoAttackBtn.BackgroundColor3 = autoAttackEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(45, 45, 60)
        end
        
        damageToggle.MouseButton1Click:Connect(function()
            multiDamageEnabled = not multiDamageEnabled
            UpdateCombatUI()
        end)
        
        damageMinus.MouseButton1Click:Connect(function()
            multiDamageValue = math.max(2, multiDamageValue - 1)
            UpdateCombatUI()
        end)
        
        damagePlus.MouseButton1Click:Connect(function()
            multiDamageValue = math.min(10, multiDamageValue + 1)
            UpdateCombatUI()
        end)
        
        hitToggle.MouseButton1Click:Connect(function()
            multiHitEnabled = not multiHitEnabled
            if not multiHitEnabled then
                autoAttackEnabled = false
                StopAutoAttack()
            end
            UpdateCombatUI()
        end)
        
        hitMinus.MouseButton1Click:Connect(function()
            multiHitValue = math.max(1, multiHitValue - 1)
            UpdateCombatUI()
        end)
        
        hitPlus.MouseButton1Click:Connect(function()
            multiHitValue = math.min(10, multiHitValue + 1)
            UpdateCombatUI()
        end)
        
        attackNow.MouseButton1Click:Connect(function()
            if multiHitEnabled then
                AttackMultiTargets()
            end
        end)
        
        autoAttackBtn.MouseButton1Click:Connect(function()
            if multiHitEnabled then
                autoAttackEnabled = not autoAttackEnabled
                if autoAttackEnabled then
                    StartAutoAttack()
                else
                    StopAutoAttack()
                end
                UpdateCombatUI()
            end
        end)
    end
    
    -- ========== KONTEN OTHER (KOSONG) ==========
    local function BuildOtherTab()
        local placeholder = Instance.new("TextButton")
        placeholder.Size = UDim2.new(1, 0, 0, 100)
        placeholder.Text = "⚙ FITUR LAIN\n\nKosong - siap diisi"
        placeholder.TextColor3 = Color3.fromRGB(150, 150, 180)
        placeholder.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        placeholder.Font = Enum.Font.Gotham
        placeholder.TextSize = 12
        placeholder.Parent = content
        local placeholderCorner = Instance.new("UICorner")
        placeholderCorner.CornerRadius = UDim.new(0, 8)
        placeholderCorner.Parent = placeholder
    end
    
    -- ========== SWITCH KATEGORI ==========
    local function ClearContent()
        for _, child in ipairs(content:GetChildren()) do
            if child ~= contentList then
                child:Destroy()
            end
        end
    end
    
    local function SwitchToESP()
        currentCategory = "ESP"
        espTab.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
        espTab.BackgroundTransparency = 0.2
        espTab.TextColor3 = Color3.fromRGB(255, 255, 255)
        combatTab.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        combatTab.BackgroundTransparency = 0
        combatTab.TextColor3 = Color3.fromRGB(200, 200, 220)
        otherTab.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        otherTab.BackgroundTransparency = 0
        otherTab.TextColor3 = Color3.fromRGB(200, 200, 220)
        ClearContent()
        BuildESPTab()
        content.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 10)
    end
    
    local function SwitchToCombat()
        currentCategory = "COMBAT"
        combatTab.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
        combatTab.BackgroundTransparency = 0.2
        combatTab.TextColor3 = Color3.fromRGB(255, 255, 255)
        espTab.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        espTab.BackgroundTransparency = 0
        espTab.TextColor3 = Color3.fromRGB(200, 200, 220)
        otherTab.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        otherTab.BackgroundTransparency = 0
        otherTab.TextColor3 = Color3.fromRGB(200, 200, 220)
        ClearContent()
        BuildCombatTab()
        content.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 10)
    end
    
    local function SwitchToOther()
        currentCategory = "OTHER"
        otherTab.BackgroundColor3 = Color3.fromRGB(155, 0, 255)
        otherTab.BackgroundTransparency = 0.2
        otherTab.TextColor3 = Color3.fromRGB(255, 255, 255)
        espTab.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        espTab.BackgroundTransparency = 0
        espTab.TextColor3 = Color3.fromRGB(200, 200, 220)
        combatTab.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        combatTab.BackgroundTransparency = 0
        combatTab.TextColor3 = Color3.fromRGB(200, 200, 220)
        ClearContent()
        BuildOtherTab()
        content.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 10)
    end
    
    espTab.MouseButton1Click:Connect(SwitchToESP)
    combatTab.MouseButton1Click:Connect(SwitchToCombat)
    otherTab.MouseButton1Click:Connect(SwitchToOther)
    
    -- DEFAULT KE ESP
    SwitchToESP()
    
    -- DRAG
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
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
    
    -- MINIMIZE
    local function ToggleMinimize()
        if minimized then
            mainFrame:TweenSize(UDim2.new(0, 300, 0, 450), "Out", "Quad", 0.2, true)
            tabBar.Visible = true
            content.Visible = true
            minBtn.Text = "─"
            minimized = false
        else
            mainFrame:TweenSize(UDim2.new(0, 180, 0, 40), "Out", "Quad", 0.2, true)
            tabBar.Visible = false
            content.Visible = false
            minBtn.Text = "□"
            minimized = true
        end
    end
    
    minBtn.MouseButton1Click:Connect(ToggleMinimize)
    
    closeBtn.MouseButton1Click:Connect(function()
        StopAutoAttack()
        screenGui:Destroy()
        currentMenu = nil
    end)
end

-- START
CreateMainMenu()
