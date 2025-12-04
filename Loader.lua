local HUB_URL = "https://raw.githubusercontent.com/vrplxswv/ChatGPT-Hub/main/main.lua"
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

---------------------------------------------------------------------
-- SHA1 (Deterministic, same result on all executors)
---------------------------------------------------------------------
local function sha1(str)
    local bit = bit32
    local function leftrotate(x, n)
        return bit.bor(bit.lshift(x, n), bit.rshift(x, 32 - n))
    end

    local h0, h1, h2, h3, h4 = 
        0x67452301, 0xEFCDAB89, 0x98BADCFE,
        0x10325476, 0xC3D2E1F0

    local msg = str .. string.char(0x80)
    while (#msg % 64) ~= 56 do msg = msg .. string.char(0) end

    local ml = #str * 8
    for i = 7, 0, -1 do
        msg = msg .. string.char(bit.band(bit.rshift(ml, i * 8), 0xFF))
    end

    for chunkStart = 1, #msg, 64 do
        local w = {}
        for i = 0, 15 do
            local start = chunkStart + i * 4
            w[i] = bit.bor(
                bit.lshift(string.byte(msg, start), 24),
                bit.lshift(string.byte(msg, start + 1), 16),
                bit.lshift(string.byte(msg, start + 2), 8),
                string.byte(msg, start + 3)
            )
        end

        for i = 16, 79 do
            w[i] = leftrotate(
                bit.bxor(w[i-3], w[i-8], w[i-14], w[i-16]),
            1)
        end

        local a, b, c, d, e = h0, h1, h2, h3, h4

        for i = 0, 79 do
            local f, k
            if i < 20 then
                f = bit.bor(bit.band(b, c), bit.band(bit.bnot(b), d))
                k = 0x5A827999
            elseif i < 40 then
                f = bit.bxor(b, c, d)
                k = 0x6ED9EBA1
            elseif i < 60 then
                f = bit.bor(
                    bit.band(b, c),
                    bit.band(b, d),
                    bit.band(c, d)
                )
                k = 0x8F1BBCDC
            else
                f = bit.bxor(b, c, d)
                k = 0xCA62C1D6
            end

            local temp = bit.band(
                leftrotate(a, 5)
                + f + e + k + w[i],
                0xFFFFFFFF
            )
            e = d
            d = c
            c = leftrotate(b, 30)
            b = a
            a = temp
        end

        h0 = bit.band(h0 + a, 0xFFFFFFFF)
        h1 = bit.band(h1 + b, 0xFFFFFFFF)
        h2 = bit.band(h2 + c, 0xFFFFFFFF)
        h3 = bit.band(h3 + d, 0xFFFFFFFF)
        h4 = bit.band(h4 + e, 0xFFFFFFFF)
    end

    return string.format("%08x%08x%08x%08x%08x", h0, h1, h2, h3, h4)
end

---------------------------------------------------------------------
-- Get UTC Date
---------------------------------------------------------------------
local date = os.date("!*t")
local KEY = sha1("vrplxswv" .. date.year .. date.month .. date.day):sub(1, 12)

---------------------------------------------------------------------
-- Work.ink (encoded)
---------------------------------------------------------------------
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function b64decode(d)
    d=d:gsub("[^"..b.."=]","")
    return (d:gsub(".", function(x)
        if x=="=" then return "" end
        local r,f="",(b:find(x)-1)
        for i=6,1,-1 do r=r..((f>> (i-1))&1) end
        return r
    end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
        if #x~=8 then return "" end
        return string.char(tonumber(x,2))
    end))
end

local WORK = b64decode("aHR0cHM6Ly93b3JrLmluay8yOW5RL2NoYXRncHQtSHVi")
setclipboard(WORK)
print("Work.ink copied:", WORK)

---------------------------------------------------------------------
-- UI
---------------------------------------------------------------------
local gui = Instance.new("ScreenGui", CoreGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.Size = UDim2.new(0, 350, 0, 220)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0.2,0)
title.Position = UDim2.new(0,0,0.05,0)
title.Text = "vrplxswv Hub"
title.Font = Enum.Font.GothamSemibold
title.BackgroundTransparency = 1
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255,255,255)

local msg = Instance.new("TextLabel", frame)
msg.Size = UDim2.new(1,0,0.15,0)
msg.Position = UDim2.new(0,0,0.28,0)
msg.Text = "Complete Work.ink → paste key"
msg.BackgroundTransparency = 1
msg.TextColor3 = Color3.fromRGB(255,255,255)
msg.TextScaled = true
msg.Font = Enum.Font.Gotham

local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(0.8,0,0.18,0)
input.Position = UDim2.new(0.1,0,0.48,0)
input.PlaceholderText = "Enter key"
input.BackgroundColor3 = Color3.fromRGB(35,35,35)
input.TextColor3 = Color3.fromRGB(255,255,255)
input.Font = Enum.Font.Gotham
input.TextScaled = true

local submit = Instance.new("TextButton", frame)
submit.Size = UDim2.new(0.8,0,0.18,0)
submit.Position = UDim2.new(0.1,0,0.72,0)
submit.Text = "Submit Key"
submit.Font = Enum.Font.GothamSemibold
submit.TextColor3 = Color3.fromRGB(255,255,255)
submit.BackgroundColor3 = Color3.fromRGB(0,170,255)
submit.TextScaled = true

submit.MouseButton1Click:Connect(function()
    if input.Text == KEY then
        msg.Text = "Key correct!"
        task.wait(0.5)
        gui:Destroy()
        loadstring(game:HttpGet(HUB_URL))()
    else
        msg.Text = "Invalid key!"
        msg.TextColor3 = Color3.fromRGB(255,70,70)
    end
end)
