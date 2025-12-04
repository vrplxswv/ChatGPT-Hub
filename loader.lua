--[[ 
    vrplxswv HUB • Ultimate Loader v2
    Features:
    ✔ Animated loading screen
    ✔ Anti-crash wrapper
    ✔ Auto-update (always pulls latest version)
    ✔ Game detector support
    ✔ Smooth UI fade-in/out
    ✔ Error fallback message
]]--

local HUB_URL = "https://raw.githubusercontent.com/vrplxswv/ChatGPT-Hub/main/main.lua"

--// SAFE HTTP GET
local function safeGet(url)
    local ok, data = pcall(function()
        return game:HttpGet(url)
    end)
    return ok and data or nil
end

--// CREATE LOADING UI
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
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0

local label = Instance.new("TextLabel", frame)
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextScaled = true
label.Font = Enum.Font.GothamSemibold
label.Text = "Loading vrplxswv Hub..."

--// LOADING DOTS ANIMATION
local running = true
task.spawn(function()
    local dots = 0
    while running do
        dots = (dots + 1) % 4
        label.Text = "Loading vrplxswv Hub" .. string.rep(".", dots)
        task.wait(0.25)
    end
end)

--// GET MAIN SCRIPT
local scriptText = safeGet(HUB_URL)

if scriptText then
    local fn, loadErr = loadstring(scriptText)

    if fn then
        -- Run safely
        local ok, runErr = pcall(fn)
        if not ok then
            label.Text = "❌ Hub crashed while loading!"
            warn("Hub runtime error:", runErr)
            task.wait(3)
        end
    else
        label.Text = "❌ Code error in main.lua!"
        warn("Loadstring error:", loadErr)
        task.wait(3)
    end
else
    label.Text = "❌ Failed to download Hub!"
    warn("HTTP error: Could not fetch main.lua")
    task.wait(3)
end

--// FADE OUT LOADING UI
running = false
for i = 0, 1, 0.1 do
    frame.BackgroundTransparency = 0.15 + i
    label.TextTransparency = i
    task.wait(0.03)
end

gui:Destroy()
