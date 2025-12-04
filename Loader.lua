local HUB_URL = "https://raw.githubusercontent.com/vrplxswv/ChatGPT-Hub/main/main.lua"
local KEY_URL = "https://vrplxswv.github.io/ChatGPT-Hub/dailykey.txt"
local OWNER_URL = "https://vrplxswv.github.io/ChatGPT-Hub/owner.txt"

local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

---------------------------------------------------------------------
-- SHA1 (Deterministic for auto daily key)
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

    for chunk = 1, #msg, 64 do
        local w = {}
        for i = 0, 15 do
            local s = chunk + i*4
            w[i] = bit.bor(
                bit.lshift(string.byte(msg, s), 24),
                bit.lshift(string.byte(msg, s+1), 16),
                bit.lshift(string.byte(msg, s+2), 8),
                string.byte(msg, s+3)
            )
        end

        for i = 16, 79 do
            w[i] = leftrotate(bit.bxor(w[i-3], w[i-8], w[i-14], w[i-16]), 1)
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
                f = bit.bor(bit.band(b, c), bit.band(b, d), bit.band(c, d))
                k = 0x8F1BBCDC
            else
                f = bit.bxor(b, c, d)
                k = 0xCA62C1D6
            end

            local temp = bit.band((leftrotate(a, 5) + f + e + k + w[i]), 0xFFFFFFFF)
            e, d, c, b, a = d, c, leftrotate(b, 30), a, temp
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
-- Automatic daily key (SHA1)
---------------------------------------------------------------------
local function generateDailyKey()
    local date = os.date("!*t")
    return sha1("vrplxswv" .. date.year .. date.month .. date.day):sub(1, 12)
end

---------------------------------------------------------------------
-- Load current key mode from GitHub
---------------------------------------------------------------------
local keyMode = "AUTO"
local function getKeyMode()
    local ok, res = pcall(function()
        return game:HttpGet(KEY_URL)
    end)
    if ok and res then
        keyMode = res:gsub("%s+", "")
    end
end
getKeyMode()

local TODAY_KEY = generateDailyKey()

---------------------------------------------------------------------
-- Owner bypass
---------------------------------------------------------------------
local function isOwner()
    local uid = game.Players.LocalPlayer.UserId
    local ok, res = pcall(function()
        return game:HttpGet(OWNER_URL)
    end)
    if not ok then return false end
    for line in res:gmatch("[^\r\n]+") do
        if tonumber(line) == uid then
            return true
        end
    end
    return false
end

---------------------------------------------------------------------
-- If owner: skip key instantly
---------------------------------------------------------------------
if isOwner() then
    warn("OWNER BYPASS ACTIVE")
    loadstring(game:HttpGet(HUB_URL))()
    return
end

---------------------------------------------------------------------
-- Key UI
---------------------------------------------------------------------
local gui = Instance.new("ScreenGui", CoreGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.Size = UDim2.new(0, 350, 0, 220)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

local title = Instance.new("TextLabel", frame)
title.Text = "vrplxswv Hub"
title.Size = UDim2.new(1, 0, 0.25, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamSemibold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true

local info = Instance.new("TextLabel", frame)
info.Text = "Complete Work.ink → paste key"
info.Size = UDim2.new(1, 0, 0.15, 0)
info.Position = UDim2.new(0, 0, 0.25, 0)
info.BackgroundTransparency = 1
info.Font = Enum.Font.Gotham
info.TextColor3 = Color3.fromRGB(200, 200, 200)
info.TextScaled = true

local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(0.8, 0, 0.2, 0)
box.Position = UDim2.new(0.1, 0, 0.45, 0)
box.PlaceholderText = "Enter key"
box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
box.TextColor3 = Color3.new(1, 1, 1)
box.Font = Enum.Font.Gotham
box.TextScaled = true

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0.8, 0, 0.2, 0)
btn.Position = UDim2.new(0.1, 0, 0.7, 0)
btn.Text = "Submit Key"
btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Font = Enum.Font.GothamSemibold
btn.TextScaled = true

btn.MouseButton1Click:Connect(function()
    if box.Text == TODAY_KEY then
        info.Text = "Correct key!"
        info.TextColor3 = Color3.fromRGB(0, 255, 0)
        task.wait(0.4)
        gui:Destroy()
        loadstring(game:HttpGet(HUB_URL))()
    else
        info.Text = "Invalid key!"
        info.TextColor3 = Color3.fromRGB(255, 70, 70)
    end
end)
