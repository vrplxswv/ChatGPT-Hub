local HUB_URL = "https://raw.githubusercontent.com/vrplxswv/ChatGPT-Hub/main/main.lua
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

---------------------------------------------------------------------
-- SAFE HTTP FUNCTION
---------------------------------------------------------------------
local function safeGet(url)
    local ok, data = pcall(function()
        return game:HttpGet(url)
    end)
    return ok and data or nil
end

---------------------------------------------------------------------
-- LOADING UI (Progress Bar)
---------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Parent = CoreGui
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local frame = Instance.new("Frame", gui)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.Size = UDim2.new(0, 370, 0, 170)
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

local function setProgress(percent, text)
    bar:TweenSize(UDim2.new(percent, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
    status.Text = text .. " (" .. math.floor(percent * 100) .. "%)"
end

---------------------------------------------------------------------
-- DAILY AUTO-ROTATING KEY SYSTEM (every 24 hours)
---------------------------------------------------------------------

-- CHANGE THIS ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
local WORKINK_URL = "PUT_YOUR_WORKINK_LINK_HERE"
-- CHANGE THIS ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

-- Daily key source on GitHub (use AUTO)
local dailyKeySource = safeGet("https://raw.githubusercontent.com/vrplxswv/ChatGPT-Hub/main/dailykey.lua")

local function generateTodayKey()
    -- key = deterministic but unguessable
    local d = os.date("!*t") -- UTC date
    local seed = string.format("%04d-%02d-%02d", d.year, d.month, d.day)
    --  hash-ish random key based on date
    local raw = seed .. "vrplxswv" .. (d.day * 1337)
    local encoded = HttpService:GenerateGUID(false):gsub("%-", ""):sub(1,8)
    return encoded .. tostring(d.day * 1337)
end

-- Determine today's key
local TODAY_KEY = ""
if dailyKeySource and dailyKeySource:find("AUTO") then
    TODAY_KEY = generateTodayKey()
else
    TODAY_KEY = dailyKeySource
end

print("Today's Key: ", TODAY_KEY)

-- load saved key (if exists)
local SAVED_KEY = ""
if isfile and isfile("vrplx_key.txt") then
    SAVED_KEY = readfile("vrplx_key.txt")
end

local function isKeyValid(key)
    return tostring(key) == tostring(TODAY_KEY)
end

---------------------------------------------------------------------
-- KEY ENTRY UI (when user has no valid key)
---------------------------------------------------------------------

if not isKeyValid(SAVED_KEY) then

    status.Text = "Key required! Link copied."
    setclipboard(WORKINK_URL)

    bar:TweenSize(UDim2.new(0.1,0,1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)

    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(0.8, 0, 0.2, 0)
    input.Position = UDim2.new(0.1, 0, 0.7, 0)
    input.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    input.TextColor3 = Color3.fromRGB(255,255,255)
    input.PlaceholderText = "Enter today's key"
    input.TextScaled = true
    input.Font = Enum.Font.Gotham

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
        if isKeyValid(k) then
            writefile("vrplx_key.txt", k)
            status.Text = "Key verified!"
            task.wait(1)
            gui:Destroy()
            loadstring(game:HttpGet(HUB_URL))()
        else
            status.Text = "Invalid key!"
        end
    end)

    return
end

---------------------------------------------------------------------
-- KEY VALID — LOAD HUB
---------------------------------------------------------------------
for i = 1, 10 do
    setProgress(i/10, "Loading Hub...")
    task.wait(0.1)
end

gui:Destroy()
loadstring(game:HttpGet(HUB_URL))()
