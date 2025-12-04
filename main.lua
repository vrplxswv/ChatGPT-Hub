-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- CHEATS
local cheats = { lockOn = false, esp = false }
local lockedTarget = nil
local boxAdornments = {}

-- THEMES
local themes = {
    Black = { bg = Color3.fromRGB(0,0,0), btn = Color3.fromRGB(50,50,50), text = Color3.fromRGB(255,255,255) },
    White = { bg = Color3.fromRGB(255,255,255), btn = Color3.fromRGB(200,200,200), text = Color3.fromRGB(0,0,0) }
}
local currentTheme = themes.Black

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AimbotGPT"
gui.Parent = localPlayer:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

-- HIT SOUND
local hitSound = Instance.new("Sound", gui)
hitSound.SoundId = "rbxassetid://188"
hitSound.Volume = 1
hitSound.Looped = false

-- MAIN FRAME
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0,450,0,320)
mainFrame.Position = UDim2.new(0.5,-225,0.25,0)
mainFrame.BackgroundColor3 = currentTheme.bg
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui
local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0,12)

-- TITLE
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, -20, 0, 40)
title.Position = UDim2.new(0, 10, 0, 10)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.TextColor3 = currentTheme.text
title.Text = "AimbotGPT.  Powered by ChatGPT"
title.TextXAlignment = Enum.TextXAlignment.Center
title.TextYAlignment = Enum.TextYAlignment.Center
title.TextStrokeTransparency = 0.7
local gradient = Instance.new("UIGradient", title)
gradient.Rotation = 45
TweenService:Create(gradient, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {Rotation=405}):Play()

-- CLOSE BUTTON
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0,30,0,30)
closeBtn.Position = UDim2.new(1,-35,0,5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Text = "X"
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0,5)
closeBtn.MouseButton1Click:Connect(function()
    hitSound:Stop()
    gui:Destroy()
end)

-- BUTTON CREATOR
local function createButton(name, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.75,0,0,50)
    btn.Position = UDim2.new(0,10,0,y)
    btn.BackgroundColor3 = currentTheme.btn
    btn.TextColor3 = currentTheme.text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.BorderSizePixel = 0
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0,8)
    btn.Text = name  -- set button text
    btn.Parent = mainFrame
    return btn
end

-- AIMBOT BUTTON (Lock-On)
local lockBtn = createButton("Aimbot [Z]: OFF", 60)
lockBtn.MouseButton1Click:Connect(function()
    cheats.lockOn = not cheats.lockOn
    lockBtn.Text = "Aimbot [Z]: "..(cheats.lockOn and "ON" or "OFF")
end)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Z then
        cheats.lockOn = not cheats.lockOn
        lockBtn.Text = "Aimbot [Z]: "..(cheats.lockOn and "ON" or "OFF")
    end
end)

-- ESP BUTTON
local espBtn = createButton("ESP [U]: OFF", 140)
espBtn.MouseButton1Click:Connect(function()
    cheats.esp = not cheats.esp
    espBtn.Text = "ESP [U]: "..(cheats.esp and "ON" or "OFF")
end)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.U then
        cheats.esp = not cheats.esp
        espBtn.Text = "ESP [U]: "..(cheats.esp and "ON" or "OFF")
    end
end)

-- THEME BUTTON
local themeBtn = Instance.new("TextButton", mainFrame)
themeBtn.Size = UDim2.new(0.4,0,0,30)
themeBtn.Position = UDim2.new(0,10,1,-60)
themeBtn.BackgroundColor3 = currentTheme.btn
themeBtn.TextColor3 = currentTheme.text
themeBtn.Font = Enum.Font.GothamBold
themeBtn.TextSize = 16
themeBtn.Text = "Theme: Black"
local themeCorner = Instance.new("UICorner", themeBtn)
themeCorner.CornerRadius = UDim.new(0,5)
themeBtn.MouseButton1Click:Connect(function()
    if currentTheme == themes.Black then
        currentTheme = themes.White
        themeBtn.Text = "Theme: White"
    else
        currentTheme = themes.Black
        themeBtn.Text = "Theme: Black"
    end
    mainFrame.BackgroundColor3 = currentTheme.bg
    lockBtn.BackgroundColor3 = currentTheme.btn
    lockBtn.TextColor3 = currentTheme.text
    espBtn.BackgroundColor3 = currentTheme.btn
    espBtn.TextColor3 = currentTheme.text
    themeBtn.BackgroundColor3 = currentTheme.btn
    themeBtn.TextColor3 = currentTheme.text
    title.TextColor3 = currentTheme.text
end)

-- TARGET BILLBOARD
local targetBillboard = Instance.new("BillboardGui")
targetBillboard.Size = UDim2.new(0,100,0,25)
targetBillboard.AlwaysOnTop = true
local indicator = Instance.new("TextLabel", targetBillboard)
indicator.Size = UDim2.new(1,0,1,0)
indicator.BackgroundTransparency = 1
indicator.TextColor3 = Color3.new(1,0,0)
indicator.TextScaled = true
indicator.Font = Enum.Font.SourceSansBold
indicator.Text = "LOCKED"

-- GET CLOSEST TARGET
local function getClosestTarget()
    local closest, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local pos, vis = camera:WorldToViewportPoint(p.Character.Head.Position)
            if vis then
                local d = (Vector2.new(pos.X,pos.Y) - Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y/2)).Magnitude
                if d < dist then dist = d closest = p end
            end
        end
    end
    return closest
end

-- UPDATE ESP
local function updateESP()
    for _, ad in ipairs(boxAdornments) do ad:Destroy() end
    boxAdornments = {}
    if not cheats.esp then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local box = Instance.new("BoxHandleAdornment", hrp)
            box.Adornee = hrp
            box.Size = Vector3.new(2,5,1)
            box.AlwaysOnTop = true
            box.ZIndex = 10
            box.Color3 = Color3.new(1,0,0)
            box.Transparency = 0.5
            table.insert(boxAdornments, box)
        end
    end
end

-- LEFT CLICK HIT SOUND WHEN LOCKED
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if cheats.lockOn and lockedTarget and lockedTarget.Character then
            hitSound:Play()
        end
    end
end)

-- RENDER LOOP
RunService.RenderStepped:Connect(function()
    updateESP()
    if cheats.lockOn then
        if not lockedTarget or not lockedTarget.Character or not lockedTarget.Character:FindFirstChild("Head") then
            lockedTarget = getClosestTarget()
            if lockedTarget and lockedTarget.Character then
                targetBillboard.Adornee = lockedTarget.Character.Head
                targetBillboard.Parent = lockedTarget.Character.Head
            end
        end
        if lockedTarget and lockedTarget.Character then
            camera.CFrame = CFrame.new(camera.CFrame.Position, lockedTarget.Character.Head.Position)
        end
    else
        lockedTarget = nil
        targetBillboard.Parent = nil
    end
end)

-- STARTUP ANIMATION
mainFrame.Size = UDim2.new(0,0,0,0)
TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.new(0,450,0,320)}):Play()
