-- vrplxswv Hub Loader (clean + working)

local HUB_URL = "https://raw.githubusercontent.com/vrplxswv/ChatGPT-Hub/main/main.lua"
local KEY_URL = "https://vrplxswv.github.io/ChatGPT-Hub/dailykey.txt"
local OWNER_URL = "https://vrplxswv.github.io/ChatGPT-Hub/owner.txt"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

---------------------------------------------------------------------
-- SAFE HTTP GET
---------------------------------------------------------------------
local function safeGet(url)
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)
    return ok and result or nil
end

---------------------------------------------------------------------
-- LOAD KEY + OWNER LIST
---------------------------------------------------------------------
local DAILY_KEY = safeGet(KEY_URL)
local OWNER_LIST = safeGet(OWNER_URL)

local isOwner = false
if OWNER_LIST then
    local ids = string.split(OWNER_LIST, "\n")
    for _, id in ipairs(ids) do
        if tostring(LocalPlayer.UserId) == id then
            isOwner = true
        end
    end
end

---------------------------------------------------------------------
-- Base64 decode for Work.ink
---------------------------------------------------------------------
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function b64decode(data)
	local t = {}
	data = data:gsub("[^%w%+%/%=]", "")
	local i = 1
	
	while i <= #data do
		local a = b:find(data:sub(i, i)) or 0
		local b1 = b:find(data:sub(i+1, i+1)) or 0
		local c1 = b:find(data:sub(i+2, i+2)) or 0
		local d = b:find(data:sub(i+3, i+3)) or 0

		a, b1, c1, d = a-1, b1-1, c1-1, d-1

		local byte1 = bit32.bor(bit32.lshift(a,2), bit32.rshift(b1,4))
		local byte2 = bit32.bor(bit32.lshift(bit32.band(b1,15),4), bit32.rshift(c1,2))
		local byte3 = bit32.bor(bit32.lshift(bit32.band(c1,3),6), d)

		table.insert(t, string.char(byte1))
		if data:sub(i+2,i+2) ~= "=" then table.insert(t, string.char(byte2)) end
		if data:sub(i+3,i+3) ~= "=" then table.insert(t, string.char(byte3)) end

		i += 4
	end

	return table.concat(t)
end

local WORKINK = b64decode("aHR0cHM6Ly93b3JrLmluay8yOW5RL2NoYXRncHQtSHVi")
setclipboard(WORKINK)

---------------------------------------------------------------------
-- CREATE UI
---------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local frame = Instance.new("Frame", gui)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5,0,0.5,0)
frame.Size = UDim2.new(0,350,0,200)
frame.BackgroundColor3 = Color3.fromRGB(18,18,18)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0.25,0)
title.BackgroundTransparency = 1
title.Text = "vrplxswv Hub"
title.Font = Enum.Font.GothamSemibold
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)

local info = Instance.new("TextLabel", frame)
info.Size = UDim2.new(1,0,0.2,0)
info.Position = UDim2.new(0,0,0.25,0)
info.Text = "Complete Work.ink, paste key"
info.Font = Enum.Font.Gotham
info.TextScaled = true
info.BackgroundTransparency = 1
info.TextColor3 = Color3.new(1,1,1)

local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(0.8,0,0.2,0)
input.Position = UDim2.new(0.1,0,0.48,0)
input.PlaceholderText = "Enter key"
input.BackgroundColor3 = Color3.fromRGB(35,35,35)
input.TextColor3 = Color3.new(1,1,1)
input.Font = Enum.Font.Gotham
input.TextScaled = true

local submit = Instance.new("TextButton", frame)
submit.Size = UDim2.new(0.8,0,0.2,0)
submit.Position = UDim2.new(0.1,0,0.73,0)
submit.Text = "Submit Key"
submit.Font = Enum.Font.GothamSemibold
submit.TextColor3 = Color3.new(1,1,1)
submit.BackgroundColor3 = Color3.fromRGB(0,170,255)
submit.TextScaled = true

---------------------------------------------------------------------
-- KEY CHECK
---------------------------------------------------------------------
submit.MouseButton1Click:Connect(function()
	if isOwner then
		info.Text = "Owner bypass!"
		task.wait(0.5)
		gui:Destroy()
		loadstring(game:HttpGet(HUB_URL))()
		return
	end

	if input.Text == DAILY_KEY then
		info.Text = "Key accepted!"
		task.wait(0.5)
		gui:Destroy()
		loadstring(game:HttpGet(HUB_URL))()
	else
		info.Text = "Invalid key!"
		info.TextColor3 = Color3.fromRGB(255,70,70)
	end
end)
