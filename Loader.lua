local HUB_URL = "https://raw.githubusercontent.com/vrplxswv/ChatGPT-Hub/main/main.lua"
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- YOUR LuaArmor Details (Put yours here!)
local APP_ID = "YOUR_APP_ID"
local APP_SECRET = "YOUR_SECRET"

-- Where users get the key:
local WORKINK_URL = "YOUR_WORKINK_URL"

-- Path where the key is saved locally
local KEY_FILE = "vrplx_key.txt"

-- Safely downloads URLs
local function safeGet(url)
    local ok, data = pcall(function()
        return game:HttpGet(url)
    end)
    return ok and data or nil
end

-- Verifies a key with LuaArmor
local function verifyKey(key)
    local url = string.format(
        "https://luarmor.net/api/validate?app=%s&key=%s&secret=%s",
        APP_ID,
        key,
        APP_SECRET
    )

    local result = safeGet(url)
    if not result then return false end

    local decoded = HttpService:JSONDecode(result)
    return decoded.success == true
end

---------------------------------------------------------------------
-- UI: Progress Bar Loader
---------------------------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Parent = CoreGui
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false

-- Main box
local frame = Instance.new("Frame", gui)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0.5, 0, 0)
frame.Size = UDim2.new(0, 360, 0, 160)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0.25, 0)
title.Position = UDim2.new(0, 0, 0.05, 0)
title.BackgroundTransparency = 1
title.Text = "vrplxswv Hub"
title.TextScaled = true
title.Font = Enum.Font.GothamSemibold
title.TextColor3 = Color3.fromRGB(255, 255, 255)

local barBG = Instance.new("Frame", frame)
barBG.AnchorPoint = Vector2.new(0.5, 0)
barBG.Position = UDim2.new(0.5, 0, 0.55, 0)
barBG.Size = UDim2.new(0.8, 0, 0, 18)
barBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
barBG.BorderSizePixel = 0

local bar = Instance.new("Frame", barBG)
bar.Size = UDim2.new(0, 0, 1, 0)
bar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
bar.BorderSizePixel = 0

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, 0, 0.25, 0)
status.Position = UDim2.new(0, 0, 0.3, 0)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(255, 255, 255)
status.Font = Enum.Font.Gotham
status.TextScaled = true
status.Text = "Checking key..."

local function setProgress(pct, text)
    bar:TweenSize(UDim2.new(pct, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
    status.Text = text .. " (" .. math.floor(pct * 100) .. "%)"
end

---------------------------------------------------------------------
-- KEY SYSTEM
---------------------------------------------------------------------

local storedKey = ""
if isfile and isfile(KEY_FILE) then
    storedKey = readfile(KEY_FILE)
end

-- Check if stored key is valid
if storedKey == "" or not verifyKey(storedKey) then

    -- invalidate old key
    storedKey = ""

    status.Text = "Key required!"
    setclipboard(WORKINK_URL)

    status.Text = "Key required! Link copied!"
    bar:TweenSize(UDim2.new(0.1,0,1,0), "Out", "Quad", 0.2, true)

    -- Key input box
    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(0.8, 0, 0.2, 0)
    input.Position = UDim2.new(0.1, 0, 0.7, 0)
    input.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    input.TextColor3 = Color3.fromRGB(255,255,255)
    input.TextScaled = true
    input.PlaceholderText = "Enter key..."
    input.Font = Enum.Font.Gotham

    -- Submit button
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.8, 0, 0.2, 0)
    btn.Position = UDim2.new(0.1, 0, 0.9, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0,170,255)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = "Submit Key"

    btn.MouseButton1Click:Connect(function()
        local k = input.Text
        status.Text = "Verifying key..."

        if verifyKey(k) then
            writefile(KEY_FILE, k)
            status.Text = "Key verified!"
            task.wait(1)

            gui:Destroy()
            loadstring(game:HttpGet(HUB_URL))()
        else
            status.Text = "Invalid key!"
        end
    end)

    return -- stop loader here until key is valid
end

---------------------------------------------------------------------
-- KEY IS VALID — LOAD HUB
---------------------------------------------------------------------

for i = 1, 10 do
    setProgress(i/10, "Loading Hub...")
    task.wait(0.1)
end

gui:Destroy()
loadstring(game:HttpGet(HUB_URL))()
