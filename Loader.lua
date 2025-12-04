local HUB_URL = "https://raw.githubusercontent.com/vrplxswv/ChatGPT-Hub/main/main.lua"
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

---------------------------------------------------------------------
-- Custom Base64 Decoder
---------------------------------------------------------------------
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' 
local function base64Decode(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i - f%2^(i-1) > 0 and '1' or '0') end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c = 0
        for i = 1, 8 do c = c + (x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

---------------------------------------------------------------------
-- Work.ink Link
---------------------------------------------------------------------
local encodedURL = "aHR0cHM6Ly93b3JrLmluay8yOW5RL2NoYXRncHQtSHVi"
local WORKINK_URL = base64Decode(encodedURL)

setclipboard(WORKINK_URL)
print("Work.ink link copied:", WORKINK_URL)

---------------------------------------------------------------------
-- Daily Key
---------------------------------------------------------------------
local function generateTodayKey()
    local d = os.date("!*t")
    local day = d.day

    local hex = "abcdef0123456789"
    local prefix = ""
    for i = 1, 8 do
        prefix = prefix .. string.sub(hex, math.random(1, #hex), math.random(1, #hex))
    end

    return prefix .. tostring(day * 1337)
end

local TODAY_KEY = generateTodayKey()

---------------------------------------------------------------------
-- UI
---------------------------------------------------------------------
local gui = Instance.new("ScreenGui", CoreGui)
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 370, 0, 220)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Text = "vrplxswv Hub"
title.Size = UDim2.new(1,0,0.22,0)
title.Position = UDim2.new(0,0,0.05,0)
title.TextScaled = true
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamSemibold
title.TextColor3 = Color3.fromRGB(255,255,255)

local info = Instance.new("TextLabel", frame)
info.Size = UDim2.new(1,0,0.2,0)
info.Position = UDim2.new(0,0,0.27,0)
info.Text = "Complete Work.ink → paste key"
info.TextScaled = true
info.Font = Enum.Font.Gotham
info.BackgroundTransparency = 1
info.TextColor3 = Color3.fromRGB(255,255,255)

local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(0.8,0,0.2,0)
input.Position = UDim2.new(0.1,0,0.52,0)
input.PlaceholderText = "Enter Key Here"
input.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
input.TextColor3 = Color3.fromRGB(255,255,255)
input.Font = Enum.Font.Gotham
input.TextScaled = true

local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(0.8,0,0.18,0)
button.Position = UDim2.new(0.1,0,0.76,0)
button.Text = "Submit Key"
button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
button.TextColor3 = Color3.fromRGB(255,255,255)
button.Font = Enum.Font.GothamSemibold
button.TextScaled = true

---------------------------------------------------------------------
-- Key Check
---------------------------------------------------------------------
button.MouseButton1Click:Connect(function()
    local key = input.Text
    
    if key == TODAY_KEY then
        info.Text = "Key Correct!"
        task.wait(0.5)
        gui:Destroy()
        loadstring(game:HttpGet(HUB_URL))()
    else
        info.Text = "Invalid key! Use Work.ink"
        info.TextColor3 = Color3.fromRGB(255, 70, 70)
    end
end)
