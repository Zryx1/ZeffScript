-- ============================================
-- ZEFF PROJECT - VORTEX PRIVATE SCRIPT
-- PASSWORD: zeffproject
-- ============================================

local Password = "zeffproject"  -- Password aja, username gak perlu

-- ============================================
-- DIALOG PASSWORD (TANPA USERNAME)
-- ============================================

local function AskPassword()
    local dialog = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local textBox = Instance.new("TextBox")
    local confirmBtn = Instance.new("TextButton")
    
    dialog.Name = "PasswordDialog"
    dialog.Parent = game:GetService("CoreGui")
    
    frame.Size = UDim2.new(0, 280, 0, 160)
    frame.Position = UDim2.new(0.5, -140, 0.5, -80)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BorderSizePixel = 0
    frame.Parent = dialog
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.Text = "🔐 ZEFF VORTEX"
    title.TextColor3 = Color3.fromRGB(255, 100, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = frame
    
    textBox.Size = UDim2.new(0.8, 0, 0, 45)
    textBox.Position = UDim2.new(0.1, 0, 0.45, 0)
    textBox.PlaceholderText = "Masukkan password..."
    textBox.Text = ""
    textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 16
    textBox.Parent = frame
    
    local textCorner = Instance.new("UICorner")
    textCorner.CornerRadius = UDim.new(0, 8)
    textCorner.Parent = textBox
    
    confirmBtn.Size = UDim2.new(0.5, 0, 0, 40)
    confirmBtn.Position = UDim2.new(0.25, 0, 0.8, 0)
    confirmBtn.Text = "MASUK"
    confirmBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmBtn.Font = Enum.Font.GothamBold
    confirmBtn.TextSize = 14
    confirmBtn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = confirmBtn
    
    confirmBtn.MouseButton1Click:Connect(function()
        if textBox.Text == Password then
            dialog:Destroy()
            LoadMainMenu()
        else
            textBox.Text = ""
            textBox.PlaceholderText = "❌ PASSWORD SALAH!"
            wait(1)
            textBox.PlaceholderText = "Masukkan password..."
        end
    end)
end

-- ============================================
-- MENU MOBILE BISA DIGESER, DIKECILIN, DITUTUP
-- ============================================

local minimized = false

local function CreateMainMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ZeffMenu"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 280, 0, 380)
    mainFrame.Position = UDim2.new(0.5, -140, 0.5, -190)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BackgroundTransparency = 0.92
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = mainFrame
    
    local shadow = Instance.new("UIStroke")
    shadow.Thickness = 1
    shadow.Color = Color3.fromRGB(255, 100, 0)
    shadow.Transparency = 0.4
    shadow.Parent = mainFrame
    
    -- Header (buat drag & minimize)
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    header.BackgroundTransparency = 0.15
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 16)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.7, 0, 1, 0)
    title.Position = UDim2.new(0.05, 0, 0, 0)
    title.Text = "⚡ ZEFF VORTEX"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 35, 0, 35)
    minBtn.Position = UDim2.new(1, -80, 0, 5)
    minBtn.Text = "─"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.BackgroundTransparency = 1
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 20
    minBtn.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -40, 0, 5)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.Parent = header
    
    -- Content (fitur-fitur KOSONG)
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, 0, 1, -45)
    content.Position = UDim2.new(0, 0, 0, 45)
    content.BackgroundTransparency = 1
    content.CanvasSize = UDim2.new(0, 0, 0, 300)
    content.ScrollBarThickness = 3
    content.Parent = mainFrame
    
    -- Fitur kosong (lo isi nanti)
    local features = {
        {name = "🎮 FITUR 1", desc = "Kosong - siap diisi"},
        {name = "🎮 FITUR 2", desc = "Kosong - siap diisi"},
        {name = "🎮 FITUR 3", desc = "Kosong - siap diisi"},
        {name = "🎮 FITUR 4", desc = "Kosong - siap diisi"},
        {name = "🎮 FITUR 5", desc = "Kosong - siap diisi"},
    }
    
    local yOffset = 10
    for _, feat in ipairs(features) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 55)
        btn.Position = UDim2.new(0.05, 0, 0, yOffset)
        btn.Text = feat.name .. "\n" .. feat.desc
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        btn.BackgroundTransparency = 0.5
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.TextWrapped = true
        btn.Parent = content
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = btn
        
        btn.MouseEnter:Connect(function()
            btn.BackgroundTransparency = 0.3
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundTransparency = 0.5
        end)
        
        btn.MouseButton1Click:Connect(function()
            print("🔧 " .. feat.name .. " ditekan - belum ada fungsi")
        end)
        
        yOffset = yOffset + 65
    end
    
    content.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
    
    -- DRAG FUNCTION
    local dragStarted = false
    local dragStartPos = nil
    local menuStartPos = nil
    
    local function updateDrag(input)
        local delta = input.Position - dragStartPos
        local newPos = UDim2.new(
            menuStartPos.X.Scale, menuStartPos.X.Offset + delta.X,
            menuStartPos.Y.Scale, menuStartPos.Y.Offset + delta.Y
        )
        mainFrame.Position = newPos
    end
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStarted = true
            dragStartPos = input.Position
            menuStartPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragStarted = false
                end
            end)
        end
    end)
    
    header.InputChanged:Connect(function(input)
        if dragStarted and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            updateDrag(input)
        end
    end)
    
    -- MINIMIZE FUNCTION
    local function ToggleMinimize()
        if minimized then
            mainFrame:TweenSize(UDim2.new(0, 280, 0, 380), "Out", "Quad", 0.2, true)
            content.Visible = true
            minBtn.Text = "─"
            minimized = false
        else
            mainFrame:TweenSize(UDim2.new(0, 280, 0, 45), "Out", "Quad", 0.2, true)
            content.Visible = false
            minBtn.Text = "□"
            minimized = true
        end
    end
    
    minBtn.MouseButton1Click:Connect(ToggleMinimize)
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    return screenGui
end

function LoadMainMenu()
    CreateMainMenu()
end

-- START
AskPassword()
