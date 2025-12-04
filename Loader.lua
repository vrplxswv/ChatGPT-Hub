--========================================================--
-- vrplxswv HUB LOADER V4 (FINAL + FIXED)
--========================================================--

local HUB_URL  = "https://raw.githubusercontent.com/vrplxswv/ChatGPT-Hub/main/main.lua"
local OWNER_URL = "https://vrplxswv.github.io/ChatGPT-Hub/owner.txt"
local KEY_PAGE = "https://vrplxswv.github.io/ChatGPT-Hub/"
local WORKINK = "https://work.ink/29nQ/chatgpt-hub"

local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

---------------------------------------------------------------------
-- SAFE BASE64 DECODER (UNIVERSAL)
---------------------------------------------------------------------
local base64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function b64decode(data)
	data = data:gsub("[^" .. base64chars .. "=]", "")
	return (data:gsub(".", function(x)
		if x == "=" then return "" end
		local r, f = "", (base64chars:find(x) - 1)
		for i = 6, 1, -1 do r = r .. ((f >> (i - 1)) & 1) end
		return r
	end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(bits)
		if #bits ~= 8 then return "" end
		return string.char(tonumber(bits, 2))
	end))
end

---------------------------------------------------------------------
-- OBFUSCATED WEBHOOK (NOW UNIVERSAL)
---------------------------------------------------------------------
local wb_a = "aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3Mv"
local wb_b = "MTQ0NTk2MDIyNzA0MzE1MTk5NC81d2w3Mk5ZSEt5N09xeGc="

local WEBHOOK = b64decode(wb_a .. wb_b)

---------------------------------------------------------------------
-- SHA1 FUNCTION
---------------------------------------------------------------------
local function sha1(str)
	local bit = bit32
	local function leftrotate(x,n)
		return bit.bor(bit.lshift(x,n), bit.rshift(x, 32-n))
	end

	local h0,h1,h2,h3,h4 =
		0x67452301,0xEFCDAB89,0x98BADCFE,
		0x10325476,0xC3D2E1F0

	str = str .. string.char(0x80)
	while (#str % 64) ~= 56 do str = str .. string.char(0) end

	local ml = (#str - 1) * 8
	for i = 7, 0, -1 do
		str = str .. string.char((ml >> (i*8)) & 0xFF)
	end

	for chunkStart = 1, #str, 64 do
		local w = {}
		for i = 0, 15 do
			local s = chunkStart + i*4
			w[i] = bit.lshift(str:byte(s),24)
				| bit.lshift(str:byte(s+1),16)
				| bit.lshift(str:byte(s+2),8)
				| str:byte(s+3)
		end

		for i = 16, 79 do
			w[i] = leftrotate(bit.bxor(w[i-3], w[i-8], w[i-14], w[i-16]), 1)
		end

		local a,b,c,d,e = h0,h1,h2,h3,h4

		for i=0,79 do
			local f,k
			if i<20 then
				f = bit.bor(bit.band(b,c), bit.band(bit.bnot(b), d))
				k = 0x5A827999
			elseif i<40 then
				f = bit.bxor(b,c,d)
				k = 0x6ED9EBA1
			elseif i<60 then
				f = bit.bor(bit.band(b,c), bit.band(b,d), bit.band(c,d))
				k = 0x8F1BBCDC
			else
				f = bit.bxor(b,c,d)
				k = 0xCA62C1D6
			end

			local temp = (leftrotate(a,5) + f + e + k + w[i]) & 0xffffffff
			e,d,c,b,a = d,c,leftrotate(b,30),a,temp
		end

		h0 = (h0 + a) & 0xffffffff
		h1 = (h1 + b) & 0xffffffff
		h2 = (h2 + c) & 0xffffffff
		h3 = (h3 + d) & 0xffffffff
		h4 = (h4 + e) & 0xffffffff
	end

	return string.format("%08x%08x%08x%08x%08x", h0,h1,h2,h3,h4)
end

---------------------------------------------------------------------
-- DAILY KEY
---------------------------------------------------------------------
local t = os.date("!*t")
local RAW = "vrplxswv" .. t.year .. string.format("%02d",t.month) .. string.format("%02d",t.day)
local DAILY_KEY = sha1(RAW):sub(1, 12)

---------------------------------------------------------------------
-- OWNER BYPASS
---------------------------------------------------------------------
local function getOwnerId()
	local raw = game:HttpGet(OWNER_URL)
	return tonumber(raw:match("%d+"))
end

local function isOwner()
	return game.Players.LocalPlayer.UserId == getOwnerId()
end

---------------------------------------------------------------------
-- COUNTRY LOOKUP
---------------------------------------------------------------------
local function getCountry()
	local ok,res = pcall(function()
		return game:HttpGet("https://ipinfo.io/json")
	end)
	if not ok then return "Unknown" end

	local d = HttpService:JSONDecode(res)
	return d.country or "Unknown"
end

---------------------------------------------------------------------
-- COUNTER
---------------------------------------------------------------------
local counter = 0
local lastDay = t.day

local function incrementCounter()
	local now = os.date("!*t")
	if now.day ~= lastDay then
		counter = 0
		lastDay = now.day
	end
	counter += 1
	return counter
end

---------------------------------------------------------------------
-- DISCORD LOGGER
---------------------------------------------------------------------
local function sendLog(result, enteredKey)
	local country = getCountry()
	local user = game.Players.LocalPlayer
	local exec = identifyexecutor and identifyexecutor() or "Unknown"

	local data = {
		username = "vrplxswv Hub Logger",
		embeds = {{
			title = "vrplxswv Hub – Key Check",
			color = result=="PASS" and 65280 or (result=="OWNER" and 16776960 or 16711680),
			fields = {
				{ name="User", value=user.Name.." ("..user.UserId..")", inline=true },
				{ name="Game", value=game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name, inline=true },
				{ name="Executor", value=exec, inline=true },
				{ name="Entered Key", value=enteredKey, inline=true },
				{ name="Expected Key", value=DAILY_KEY, inline=true },
				{ name="Result", value=result, inline=true },
				{ name="Country", value=country, inline=true },
				{ name="Redeems Today", value=tostring(counter), inline=true },
			},
			footer = { text="vrplxswv Hub Logger" },
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
		}}
	}

	local body = HttpService:JSONEncode(data)

	pcall(function()
		local req = request or http_request or syn.request
		req({
			Url = WEBHOOK,
			Method = "POST",
			Headers={["Content-Type"]="application/json"},
			Body = body
		})
	end)
end

---------------------------------------------------------------------
-- UI SETUP
---------------------------------------------------------------------
local gui = Instance.new("ScreenGui", CoreGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.Position = UDim2.new(0.5,0,0.5,0)
frame.Size = UDim2.new(0,350,0,260)
frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0.2,0)
title.Position = UDim2.new(0,0,0.05,0)
title.Text = "vrplxswv Hub"
title.Font = Enum.Font.GothamSemibold
title.BackgroundTransparency = 1
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255,255,255)

local msg = Instance.new("TextLabel", frame)
msg.Size = UDim2.new(1,0,0.13,0)
msg.Position = UDim2.new(0,0,0.28,0)
msg.Text = "Complete Work.ink → paste key"
msg.BackgroundTransparency = 1
msg.TextColor3 = Color3.fromRGB(255,255,255)
msg.TextScaled = true
msg.Font = Enum.Font.Gotham

local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(0.8,0,0.15,0)
input.Position = UDim2.new(0.1,0,0.45,0)
input.PlaceholderText = "Enter key"
input.BackgroundColor3 = Color3.fromRGB(35,35,35)
input.TextColor3 = Color3.fromRGB(255,255,255)
input.Font = Enum.Font.Gotham
input.TextScaled = true
input.BorderSizePixel = 0

---------------------------------------------------------------------
-- COPY WORK.INK BUTTON
---------------------------------------------------------------------
local copy = Instance.new("TextButton", frame)
copy.Size = UDim2.new(0.8,0,0.12,0)
copy.Position = UDim2.new(0.1,0,0.63,0)
copy.Text = "Copy Work.ink Link"
copy.Font = Enum.Font.GothamSemibold
copy.TextColor3 = Color3.fromRGB(255,255,255)
copy.BackgroundColor3 = Color3.fromRGB(0,140,255)
copy.TextScaled = true
copy.BorderSizePixel = 0

local copied = Instance.new("TextLabel", frame)
copied.Size = UDim2.new(0.8,0,0.08,0)
copied.Position = UDim2.new(0.1,0,0.75,0)
copied.BackgroundTransparency = 1
copied.TextScaled = true
copied.Font = Enum.Font.Gotham
copied.TextColor3 = Color3.fromRGB(0,255,0)
copied.Text = ""
copied.Visible = false

copy.MouseButton1Click:Connect(function()
	if setclipboard then setclipboard(WORKINK)
	elseif toclipboard then toclipboard(WORKINK) end

	copied.Text = "Copied!"
	copied.Visible = true
	task.delay(1.5, function()
		copied.Visible = false
	end)
end)

---------------------------------------------------------------------
-- SUBMIT BUTTON
---------------------------------------------------------------------
local submit = Instance.new("TextButton", frame)
submit.Size = UDim2.new(0.8,0,0.15,0)
submit.Position = UDim2.new(0.1,0,0.85,0)
submit.Text = "Submit Key"
submit.Font = Enum.Font.GothamSemibold
submit.TextColor3 = Color3.fromRGB(255,255,255)
submit.BackgroundColor3 = Color3.fromRGB(0,170,255)
submit.TextScaled = true
submit.BorderSizePixel = 0

submit.MouseButton1Click:Connect(function()
	local typed = input.Text

	-- OWNER BYPASS
	if isOwner() then
		incrementCounter()
		sendLog("OWNER", typed)
		msg.Text = "Owner bypass ✓"
		task.wait(0.35)
		gui:Destroy()
		return loadstring(game:HttpGet(HUB_URL))()
	end

	-- NORMAL KEY CHECK
	if typed == DAILY_KEY then
		incrementCounter()
		sendLog("PASS", typed)
		msg.Text = "Key correct ✓"
		task.wait(0.35)
		gui:Destroy()
		loadstring(game:HttpGet(HUB_URL))()
	else
		sendLog("FAIL", typed)
		msg.Text = "Invalid key!"
		msg.TextColor3 = Color3.fromRGB(255,60,60)
	end
end)
