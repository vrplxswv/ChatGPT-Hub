local HUB_URL = "https://raw.githubusercontent.com/vrplxswv/ChatGPT-Hub/main/main.lua"
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

---------------------------------------------------------------------
-- Daily Key Generator
---------------------------------------------------------------------
local function generateTodayKey()
    local d = os.date("!*t") -- UTC
    local day = d.day

    -- random 8-char hex prefix
    local hex = "abcdef0123456789"
    local prefix = ""
    for i = 1, 8 do
        prefix ..= hex:sub(math.random(1, #hex), math.random(1, #hex))
    end

    return prefix .. tostring(day * 1337)
end

local TODAY_KEY = generateTodayKey()


---------------------------------------------------------------------
-- Work.ink Link (Base64 Hidden)
---------------------------------------------------------------------
local encodedURL = "aHR0cHM6Ly93b3JrLmluay8yOW5RL2NoYXRncHQtSHVi"
local WORKINK_URL = HttpService:Base64Decode(encodedURL)

-- Copy link to clipboard
setclipboard(WORKINK_URL)
print("Work.ink link copied:", WORKINK_URL)


---------------------------------------------------------------------
-- UI
---------------------------------------------------------------------
local gui = Instance.new("ScreenGui", CoreGui)
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 370, 0, 210)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0.2,0)
title.Position = UDim2.new(0,0,0.05,0)
title.Text = "vrplxswv Hub"
title.TextScaled = true
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamSemibold
title.TextColor3 = Color3.fromRGB(255,255,255)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,0,0.18,0)
status.Position = UDim2.new(0,0,0.27,0)
status.Text = "Complete Work.ink → paste key"
status.TextScaled = true
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.TextColor3 = Color3.fromRGB(255,255,255)

local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(0.8,0,0.2,0)
input.Position = UDim2.new(0.1,0,0.47,0)
input.PlaceholderText = "Enter Key Here"
input.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
input.TextColor3 = Color3.fromRGB(255,255,255)
input.Font = Enum.Font.Gotham
input.TextScaled = true

local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(0.8,0,0.2,0)
button.Position = UDim2.new(0.1,0,0.7,0)
button.Text = "Submit Key"
button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
button.TextScaled = true
button.Font = Enum.Font.GothamSemibold
button.TextColor3 = Color3.fromRGB(255,255,255)


---------------------------------------------------------------------
-- Key Check
---------------------------------------------------------------------
button.MouseButton1Click:Connect(function()
    local key = input.Text

    if key == TODAY_KEY then
        status.Text = "Key Correct!"
        button.Text = "Loading…"

        task.wait(0.8)
        gui:Destroy()

        -- Load actual hub now
        loadstring(game:HttpGet(HUB_URL))()
    else
        status.Text = "Invalid key! Get it from Work.ink"
        status.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

