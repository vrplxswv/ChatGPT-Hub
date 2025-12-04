-- vrplxswv HUB Loader v2 (fixed)

local HUB_URL = "https://raw.githubusercontent.com/vrplxswv/ChatGPT-Hub/main/main.lua"

-- SAFE HTTP GET
local function safeGet(url)
    local ok, data = pcall(function()
        return game:HttpGet(url)
    end)
    return ok and data or nil
end

-- LOADING UI
local CoreGui = game:GetService("CoreGui")

local gui = Instance.new("ScreenGui")
gui.Parent = CoreGui
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0.5, 0, 0)
frame.Size = UDim2.new(0, 360, 0, 140)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0

local label = Instance.new("TextLabel", frame)
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextScaled = true
label.Font = Enum.Font.GothamSemibold
label.Text = "Loading vrplxswv Hub..."

local running = true
task.spawn(function()
    local dots = 0
    while running do
        dots = (dots + 1) % 4
        label.Text = "Loading vrplxswv Hub" .. string.rep(".", dots)
        task.wait(0.25)
    end
end)

-- FETCH MAIN SCRIPT
local scriptText = safeGet(HUB_URL)

if scriptText then
    local fn, loadErr = loadstring(scriptText)
    if fn then
        local ok, runtimeErr = pcall(fn)
        if not ok then
            label.Text = "❌ Hub crashed!"
            warn(runtimeErr)
            task.wait(3)
        end
    else
        label.Text = "❌ Code error in main.lua!"
        warn(loadErr)
        task.wait(3)
    end
else
    label.Text = "❌ Failed to download Hub!"
    task.wait(3)
end

running = false
for i = 0, 1, 0.1 do
    frame.BackgroundTransparency = i
    label.TextTransparency = i
    task.wait(0.03)
end

gui:Destroy()
