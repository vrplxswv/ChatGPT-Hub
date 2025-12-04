--========================================================--
-- vrplxswv HUB LOADER V5 (STABLE FINAL)
--========================================================--

local HUB_URL  = "https://raw.githubusercontent.com/vrplxswv/ChatGPT-Hub/main/main.lua"
local OWNER_URL = "https://vrplxswv.github.io/ChatGPT-Hub/owner.txt"
local WORKINK = "https://work.ink/29nQ/chatgpt-hub"

local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

---------------------------------------------------------------------
-- UNIVERSAL BASE64 DECODER
---------------------------------------------------------------------
local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function b64decode(data)
	data = data:gsub("[^" .. b64chars .. "=]", "")
	return (data:gsub(".", function(x)
		if x == "=" then return "" end
		local bits, f = "", (b64chars:find(x) - 1)
		for i = 6, 1, -1 do bits = bits .. ((f >> (i - 1)) & 1) end
		return bits
	end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(b)
		if #b ~= 8 then return "" end
		return string.char(tonumber(b, 2))
	end))
end

---------------------------------------------------------------------
-- DISCORD WEBHOOK (your NEW webhook encoded)
---------------------------------------------------------------------
local wb_a = "aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3Mv"
local wb_b = "MTQ0NTk2NTQ1MzcyNDc0OTk0NS9temI0YTd tUXFsc0RX TGlzYXY3dDZ HYnNyRkNfeG p s X0dUeDhFaW FCdT FjUnE4Z3Fy T25Qdmlz bm9VUzAxbUhZ M3Iw"

-- Remove accidental spaces from API cut
wb_b = wb_b:gsub("%s+", "")

local WEBHOOK = b64decode(wb_a .. wb_b)

---------------------------------------------------------------------
-- SHA-1 (works on every executor)
---------------------------------------------------------------------
local function sha1(str)
	local bit = bit32
	local function R(x,n)
		return bit.bor(bit.lshift(x,n), bit.rshift(x,32-n))
	end

	local h0=0x67452301 local h1=0xEFCDAB89 local h2=0x98BADCFE
	local h3=0x10325476 local h4=0xC3D2E1F0

	str = str .. string.char(0x80)
	while (#str % 64) ~= 56 do str = str .. string.char(0) end

	local ml = (#str - 1) * 8
	for i=7,0,-1 do str = str .. string.char((ml >> (i*8)) & 0xFF) end

	for chunk = 1, #str, 64 do
		local w = {}
		for i=0,15 do
			local s = chunk + i*4
			w[i] = bit.lshift(str:byte(s),24)
				| bit.lshift(str:byte(s+1),16)
				| bit.lshift(str:byte(s+2),8)
				| str:byte(s+3)
		end
		for i=16,79 do w[i] = R(bit.bxor(w[i-3],w[i-8],w[i-14],w[i-16]),1) end

		local a,b,c,d,e = h0,h1,h2,h3,h4
		for i=0,79 do
			local f,k
			if i<20 then f = bit.bor(bit.band(b,c), bit.band(bit.bnot(b),d)) k=0x5A827999
			elseif i<40 then f = bit.bxor(b,c,d) k=0x6ED9EBA1
			elseif i<60 then f = bit.bor(bit.band(b,c), bit.band(b,d), bit.band(c,d)) k=0x8F1BBCDC
			else f = bit.bxor(b,c,d) k=0xCA62C1D6 end

			local temp = (R(a,5) + f + e + k + w[i]) & 0xffffffff
			e,d,c,b,a = d,c,R(b,30),a,temp
		end

		h0=(h0+a)&0xffffffff h1=(h1+b)&0xffffffff
		h2=(h2+c)&0xffffffff h3=(h3+d)&0xffffffff h4=(h4+e)&0xffffffff
	end

	return string.format("%08x%08x%08x%08x%08x",h0,h1,h2,h3,h4)
end

---------------------------------------------------------------------
-- DAILY KEY GENERATION
---------------------------------------------------------------------
local dt = os.date("!*t")
local rawKey = "vrplxswv" .. dt.year .. string.format("%02d",dt.month) .. string.format("%02d",dt.day)
local DAILY_KEY = sha1(rawKey):sub(1,12)

---------------------------------------------------------------------
-- OWNER CHECK
---------------------------------------------------------------------
local function getOwner()
	local raw = game:HttpGet(OWNER_URL)
	return tonumber(raw:match("%d+"))
end

local function isOwner()
	return game.Players.LocalPlayer.UserId == getOwner()
end

---------------------------------------------------------------------
-- COUNTRY LOOKUP
---------------------------------------------------------------------
local function getCountry()
	local ok, res = pcall(function()
		return game:HttpGet("https://ipinfo.io/json")
	end)
	if not ok then return "Unknown" end
	local data = HttpService:JSONDecode(res)
	return data.country or "Unknown"
end

---------------------------------------------------------------------
-- DISCORD LOGGER
---------------------------------------------------------------------
local counter = 0
local lastDay = dt.day

local function count()
	local now = os.date("!*t")
	if now.day ~= lastDay then counter = 0 lastDay = now.day end
	counter += 1
	return counter
end

local function log(result, key)
	pcall(function()
		local user = game.Players.LocalPlayer
		local country = getCountry()
		local exec = identifyexecutor and identifyexecutor() or "Unknown"

		local embed = {
			username = "vrplxswv Hub Logger",
			embeds = {{
				title = "Key Check",
				color = result=="PASS" and 65280 or (result=="OWNER" and 16776960 or 16711680),
				fields = {
					{ name="User", value=user.Name .. " ("..user.UserId..")", inline=true },
					{ name="Entered", value=key, inline=true },
					{ name="Expected", value=DAILY_KEY, inline=true },
					{ name="Result", value=result, inline=true },
					{ name="Country", value=country, inline=true },
					{ name="Redeems Today", value=tostring(counter), inline=true }
				},
				timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
			}}
		}

		local req = request or http_request or syn.request
		req({
			Url = WEBHOOK,
			Method = "POST",
			Headers = {["Content-Type"]="application/json"},
			Body = HttpService:JSONEncode(embed)
		})
	end)
end

---------------------------------------------------------------------
-- UI
---------------------------------------------------------------------
local gui = Instance.new("ScreenGui", CoreGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.Position = UDim2.new(0.5,0,0.5,0)
frame.Size = UDim2.new(0,350,0,240)
frame.BackgroundColor3 = Color3.fromRGB(18,18,18)

local title = Instance.new("TextLabel", frame)
title.Text = "vrplxswv Hub"
title.Font = Enum.Font.GothamSemibold
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextScaled = true
title.Size = UDim2.new(1,0,0.2,0)
title.BackgroundTransparency = 1

local msg = Instance.new("TextLabel", frame)
msg.Text = "Enter Work.ink key"
msg.Font = Enum.Font.Gotham
msg.TextColor3 = Color3.fromRGB(255,255,255)
msg.TextScaled = true
msg.Size = UDim2.new(1,0,0.13,0)
msg.Position = UDim2.new(0,0,0.22,0)
msg.BackgroundTransparency = 1

local input = Instance.new("TextBox", frame)
input.PlaceholderText = "Enter key"
input.Size = UDim2.new(0.8,0,0.15,0)
input.Position = UDim2.new(0.1,0,0.40,0)
input.BackgroundColor3 = Color3.fromRGB(40,40,40)
input.TextColor3 = Color3.fromRGB(255,255,255)
input.TextScaled = true
input.BorderSizePixel = 0

-- Copy Work.ink button
local copy = Instance.new("TextButton", frame)
copy.Text = "Copy Work.ink Link"
copy.Size = UDim2.new(0.8,0,0.12,0)
copy.Position = UDim2.new(0.1,0,0.60,0)
copy.BackgroundColor3 = Color3.fromRGB(0,140,255)
copy.TextScaled = true
copy.Font = Enum.Font.GothamSemibold

local copied = Instance.new("TextLabel", frame)
copied.Text = "Copied!"
copied.Visible = false
copied.TextColor3 = Color3.fromRGB(0,255,0)
copied.BackgroundTransparency = 1
copied.Size = UDim2.new(1,0,0.1,0)
copied.Position = UDim2.new(0,0,0.73,0)
copied.TextScaled = true

copy.MouseButton1Click:Connect(function()
	if setclipboard then setclipboard(WORKINK)
	elseif toclipboard then toclipboard(WORKINK) end
	copied.Visible = true
	task.delay(1.2,function() copied.Visible = false end)
end)

-- Submit button
local submit = Instance.new("TextButton", frame)
submit.Text = "Submit Key"
submit.Size = UDim2.new(0.8,0,0.15,0)
submit.Position = UDim2.new(0.1,0,0.82,0)
submit.BackgroundColor3 = Color3.fromRGB(0,170,255)
submit.TextColor3 = Color3.fromRGB(255,255,255)
submit.Font = Enum.Font.GothamSemibold
submit.TextScaled = true

submit.MouseButton1Click:Connect(function()
	local key = input.Text

	if isOwner() then
		count()
		log("OWNER", key)
		msg.Text = "Owner ✓"
		task.wait(0.3)
		gui:Destroy()
		return loadstring(game:HttpGet(HUB_URL))()
	end

	if key == DAILY_KEY then
		count()
		log("PASS", key)
		msg.Text = "Correct ✓"
		task.wait(0.3)
		gui:Destroy()
		loadstring(game:HttpGet(HUB_URL))()
	else
		log("FAIL", key)
		msg.Text = "Invalid key!"
		msg.TextColor3 = Color3.fromRGB(255,70,70)
	end
end)
