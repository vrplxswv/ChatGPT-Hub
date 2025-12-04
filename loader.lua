--// vrplxswv HUB Loader
--// Clean, auto-updating, and sexy B)

local RAW = "https://raw.githubusercontent.com/vrplxswv/ChatGPT-Hub/main/main.lua"

--// Loading Screen UI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Label = Instance.new("TextLabel")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false

Frame.Parent = ScreenGui
Frame.AnchorPoint = Vector2.new(0.5,0.5)
Frame.Position = UDim2.new(0.5,0.5,0,0)
Frame.Size = UDim2.new(0,350,0,120)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.BorderSizePixel = 0
Frame.BackgroundTransparency = 0.15

Label.Parent = Frame
Label.Size = UDim2.new(1,0,1,0)
Label.BackgroundTransparency = 1
Label.Text = "🔄 Loading vrplxswv Hub..."
Label.TextColor3 = Color3.fromRGB(255,255,255)
Label.TextScaled = true
Label.Font = Enum.Font.GothamSemibold

--// Loader Animation
task.spawn(function()
    local dots = 0
    while true do
        dots = (dots + 1) % 4
        Label.Text = "🔄 Loading vrplxswv Hub" .. string.rep(".", dots)
        task.wait(0.3)
    end
end)

--// Load Main Script
local success, result = pcall(function()
    return game:HttpGet(RAW)
end)

if success then
    local ok, err = pcall(function()
        loadstring(result)()
    end)

    if not ok then
        Label.Text = "❌ Error loading main hub!"
        warn(err)
        task.wait(3)
    end
else
    Label.Text = "❌ Failed to download hub!"
    warn(result)
    task.wait(3)
end

ScreenGui:Destroy()
