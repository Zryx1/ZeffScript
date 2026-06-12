-- ============================================
-- ZEFF VORTEX - FINAL SCRIPT
-- 3 ESP: BOX, TRACER, NAME (Bisa Barengan)
-- MENU KECIL, PERKECIL JADI BAR
-- ============================================

-- ============================================
-- VARIABEL ESP
-- ============================================
local espBoxEnabled = false
local espTracerEnabled = false
local espNameEnabled = false
local espColor = Color3.fromRGB(155, 0, 255)  -- UNGU NEON
local espThickness = 2

local espObjects = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ============================================
-- CREATE BOX ESP
-- ============================================
local function CreateBoxESP(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = espColor
    box.Thickness = espThickness
    box.Filled = false
    box.Transparency = 0.5
    
    return {
        box = box,
        player = player,
        type = "box"
    }
end

-- ============================================
-- CREATE TRACER ESP (GARIS)
-- ============================================
local function CreateTracerESP(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = espColor
    line.Thickness = espThickness
    line.Transparency = 0.5
    
    return {
        line = line,
        player = player,
        type = "tracer"
    }
end

-- ============================================
-- CREATE NAME ESP
-- ============================================
local function CreateNameESP(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Color = espColor
    nameTag.Size = 14
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.fromRGB(0, 0, 0)
    
    return {
        nameTag = nameTag,
        player = player,
        type = "name"
    }
end

-- ============================================
-- UPDATE ESP
-- ============================================
local function UpdateESP()
    local viewportSize = Camera.ViewportSize
    local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    
    for _, esp in pairs(espObjects) do
        local player = esp.player
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        local isAlive = character and humanoid and rootPart and humanoid.Health > 0
        
        if not isAlive then
            if esp.type == "box" and esp.box then
                esp.box.Visible = false
            elseif esp.type == "tracer" and esp.line then
                esp.line.Visible = false
            elseif esp.type == "name" and esp.nameTag then
                esp.nameTag.Visible = false
            end
        else
            local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            
            if onScreen then
                if esp.type == "box" and espBoxEnabled and esp.box then
                    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
                    local boxSize = math.clamp(250 / distance, 30, 130)
                    
                    local boxX = vector.X - boxSize / 2
                    local boxY = vector.Y - boxSize / 1.3
                    
                    esp.box.Size = Vector2.new(boxSize, boxSize)
                    esp.box.Position = Vector2.new(boxX, boxY)
                    esp.box.Visible = true
                    esp.box.Color = espColor
                    esp.box.Thickness = espThickness
                elseif esp.type == "box" and not espBoxEnabled and esp.box then
                    esp.box.Visible = false
                end
                
                if esp.type == "tracer" and espTracerEnabled and esp.line then
                    esp.line.From = center
                    esp.line.To = Vector2.new(vector.X, vector.Y)
                    esp.line.Visible = true
                    esp.line.Color = espColor
                    esp.line.Thickness = espThickness
                elseif esp.type == "tracer" and not espTracerEnabled and esp.line then
                    esp.line.Visible = false
                end
                
                if esp.type == "name" and espNameEnabled and esp.nameTag then
                    esp.nameTag.Text = player.Name
                    esp.nameTag.Position = Vector2.new(vector.X, vector.Y - 20)
                    esp.nameTag.Visible = true
                    esp.nameTag.Color = espColor
                elseif esp.type == "name" and not espNameEnabled and esp.nameTag then
                    esp.nameTag.Visible = false
                end
            else
                if esp.type == "box" and esp.box then
                    esp.box.Visible = false
                elseif esp.type == "tracer" and esp.line then
                    esp.line.Visible = false
                elseif esp.type == "name" and esp.nameTag then
                    esp.nameTag.Visible = false
                end
            end
        end
    end
end

-- ============================================
-- MANAJEMEN PLAYER
-- ============================================
local function AddPlayer(player)
    if player == LocalPlayer then return end
    if espObjects[player] then return end
    
    espObjects[player] = {
        box = CreateBoxESP(player),
        tracer = CreateTracerESP(player),
        name = CreateNameESP(player)
    }
end

local function RemovePlayer(player)
    if espObjects[player] then
        if espObjects[player].box and espObjects[player].box.box then
            espObjects[player].box.box:Remove()
        end
        if espObjects[player].tracer and espObjects[player].tracer.line then
            espObjects[player].tracer.line:Remove()
        end
        if espObjects[player].name and espObjects[player].name.nameTag then
            espObjects[player].name.nameTag:Remove()
        end
        espObjects[player] = nil
    end
end

local function RefreshESP()
    for _, espData in pairs(espObjects) do
        if espData.box and espData.box.box then
            espData.box.box.Color = espColor
            espData.box.box.Thickness = espThickness
        end
        if espData.tracer and espData.tracer.line then
            espData.tracer.line.Color = espColor
            espData.tracer.line.Thickness = espThickness
        end
        if espData.name and espData.name.nameTag then
            espData.name.nameTag.Color = espColor
        end
    end
end

local function StartLoop()
    RunService.RenderStepped:Connect(UpdateESP)
end

-- ============================================
-- MENU UTAMA
-- ============================================
local minimized = false
local currentMenu = nil

local function CreateMainMenu()
    if currentMenu then
        currentMenu:Destroy()
        currentMenu = nil
    end
    
    local CoreGui = game:GetService("CoreGui")
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ZeffVortexMenu"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local success, err = pcall(function()
        screenGui.Parent = (gethui and gethui()) or CoreGui
    end)
    if not success then
        screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    currentMenu = screenGui
    
    -- MAIN FRAME (UKURAN KECIL: 260x260)
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 260, 0, 260)
    mainFrame.Position = UDim2.new(0.5, -130, 0.5, -130)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    mainFrame.BackgroundTransparency = 0  -- GAK TEMBUS
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
    
    -- HEADER (Drag)
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 38)
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
    title.Text = "🔮 ZEFF VORTEX"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
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
    
    -- CONTENT
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -16, 1, -52)
    content.Position = UDim2.new(0, 8, 0, 46)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    local yOffset = 0
    
    -- Tombol BOX ESP
    local boxBtn = Instance.new("TextButton")
    boxBtn.Size = UDim2.new(1, 0, 0, 45)
    boxBtn.Position = UDim2.new(0, 0, 0, yOffset)
    boxBtn.Text = "📦 BOX ESP"
    boxBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    boxBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    boxBtn.Font = Enum.Font.GothamBold
    boxBtn.TextSize = 13
    boxBtn.Parent = content
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 8)
    boxCorner.Parent = boxBtn
    
    local boxStatus = Instance.new("TextLabel")
    boxStatus.Size = UDim2.new(0.35, 0, 1, 0)
    boxStatus.Position = UDim2.new(0.65, 0, 0, 0)
    boxStatus.Text = "OFF"
    boxStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
    boxStatus.BackgroundTransparency = 1
    boxStatus.Font = Enum.Font.GothamBold
    boxStatus.TextSize = 12
    boxStatus.TextXAlignment = Enum.TextXAlignment.Right
    boxStatus.Parent = boxBtn
    
    yOffset = yOffset + 53
    
    -- Tombol TRACER ESP
    local tracerBtn = Instance.new("TextButton")
    tracerBtn.Size = UDim2.new(1, 0, 0, 45)
    tracerBtn.Position = UDim2.new(0, 0, 0, yOffset)
    tracerBtn.Text = "📏 TRACER ESP"
    tracerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tracerBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    tracerBtn.Font = Enum.Font.GothamBold
    tracerBtn.TextSize = 13
    tracerBtn.Parent = content
    
    local tracerCorner = Instance.new("UICorner")
    tracerCorner.CornerRadius = UDim.new(0, 8)
    tracerCorner.Parent = tracerBtn
    
    local tracerStatus = Instance.new("TextLabel")
    tracerStatus.Size = UDim2.new(0.35, 0, 1, 0)
    tracerStatus.Position = UDim2.new(0.65, 0, 0, 0)
    tracerStatus.Text = "OFF"
    tracerStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
    tracerStatus.BackgroundTransparency = 1
    tracerStatus.Font = Enum.Font.GothamBold
    tracerStatus.TextSize = 12
    tracerStatus.TextXAlignment = Enum.TextXAlignment.Right
    tracerStatus.Parent = tracerBtn
    
    yOffset = yOffset + 53
    
    -- Tombol NAME ESP
    local nameBtn = Instance.new("TextButton")
    nameBtn.Size = UDim2.new(1, 0, 0, 45)
    nameBtn.Position = UDim2.new(0, 0, 0, yOffset)
    nameBtn.Text = "🏷️ NAME ESP"
    nameBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    nameBtn.Font = Enum.Font.GothamBold
    nameBtn.TextSize = 13
    nameBtn.Parent = content
    
    local nameCorner = Instance.new("UICorner")
    nameCorner.CornerRadius = UDim.new(0, 8)
    nameCorner.Parent = nameBtn
    
    local nameStatus = Instance.new("TextLabel")
    nameStatus.Size = UDim2.new(0.35, 0, 1, 0)
    nameStatus.Position = UDim2.new(0.65, 0, 0, 0)
    nameStatus.Text = "OFF"
    nameStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
    nameStatus.BackgroundTransparency = 1
    nameStatus.Font = Enum.Font.GothamBold
    nameStatus.TextSize = 12
    nameStatus.TextXAlignment = Enum.TextXAlignment.Right
    nameStatus.Parent = nameBtn
    
    yOffset = yOffset + 53
    
    -- Setting KETEBALAN
    local thickFrame = Instance.new("Frame")
    thickFrame.Size = UDim2.new(1, 0, 0, 45)
    thickFrame.Position = UDim2.new(0, 0, 0, yOffset)
    thickFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    thickFrame.BackgroundTransparency = 0
    thickFrame.BorderSizePixel = 0
    thickFrame.Parent = content
    
    local thickCorner = Instance.new("UICorner")
    thickCorner.CornerRadius = UDim.new(0, 8)
    thickCorner.Parent = thickFrame
    
    local thickLabel = Instance.new("TextLabel")
    thickLabel.Size = UDim2.new(0.5, 0, 1, 0)
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
    
    -- UPDATE STATUS FUNCTION
    local function UpdateAllStatus()
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
    
    -- BOX BUTTON
    boxBtn.MouseButton1Click:Connect(function()
        espBoxEnabled = not espBoxEnabled
        UpdateAllStatus()
    end)
    
    -- TRACER BUTTON
    tracerBtn.MouseButton1Click:Connect(function()
        espTracerEnabled = not espTracerEnabled
        UpdateAllStatus()
    end)
    
    -- NAME BUTTON
    nameBtn.MouseButton1Click:Connect(function()
        espNameEnabled = not espNameEnabled
        UpdateAllStatus()
    end)
    
    -- THICKNESS
    minusBtn.MouseButton1Click:Connect(function()
        espThickness = math.max(1, espThickness - 1)
        thickValue.Text = tostring(espThickness)
        RefreshESP()
    end)
    
    plusBtn.MouseButton1Click:Connect(function()
        espThickness = math.min(5, espThickness + 1)
        thickValue.Text = tostring(espThickness)
        RefreshESP()
    end)
    
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
    
    -- MINIMIZE (JADI BAR KECIL)
    local function ToggleMinimize()
        if minimized then
            mainFrame:TweenSize(UDim2.new(0, 260, 0, 260), "Out", "Quad", 0.2, true)
            content.Visible = true
            minBtn.Text = "─"
            minimized = false
        else
            mainFrame:TweenSize(UDim2.new(0, 200, 0, 38), "Out", "Quad", 0.2, true)
            content.Visible = false
            minBtn.Text = "□"
            minimized = true
        end
    end
    
    minBtn.MouseButton1Click:Connect(ToggleMinimize)
    
    -- CLOSE
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        currentMenu = nil
    end)
    
    -- INITIAL UPDATE
    UpdateAllStatus()
end

-- ============================================
-- INITIALIZE PLAYERS & LOOP
-- ============================================
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        AddPlayer(player)
    end
end

Players.PlayerAdded:Connect(AddPlayer)
Players.PlayerRemoving:Connect(RemovePlayer)

StartLoop()

-- ========== LANGSUNG JALANKAN MENU ==========
CreateMainMenu()
