--========================================================
-- 🤖 HUMAN LANGUAGE ROBLOX COPILOT
-- ONE FILE VERSION
-- สำหรับเกม Roblox ของคุณเอง
--========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--========================================================
-- CLEAN OLD GUI
--========================================================

local old = PlayerGui:FindFirstChild("HumanLanguageCopilot")
if old then
	old:Destroy()
end

--========================================================
-- STATE
--========================================================

local State = {
	Speed = 16,
	Jump = 50,
	FOV = 70,
	History = {},
	LastResult = "",
}

--========================================================
-- HELPERS
--========================================================

local function character()
	return Player.Character or Player.CharacterAdded:Wait()
end

local function humanoid()
	local c = character()
	return c:FindFirstChildOfClass("Humanoid")
end

local function root()
	local c = character()
	return c:FindFirstChild("HumanoidRootPart")
end

local function numberAfter(text, words, default)
	for _, word in ipairs(words) do
		local n = string.match(text, word .. "%s*(%d+%.?%d*)")
		if n then
			return tonumber(n)
		end
	end

	local n = string.match(text, "(%d+%.?%d*)")
	return n and tonumber(n) or default
end

local function contains(text, list)
	for _, word in ipairs(list) do
		if string.find(text, word, 1, true) then
			return true
		end
	end
	return false
end

local function addHistory(text)
	table.insert(State.History, text)

	if #State.History > 30 then
		table.remove(State.History, 1)
	end
end

--========================================================
-- GUI
--========================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "HumanLanguageCopilot"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 370, 0, 560)
Main.Position = UDim2.new(.5, -185, .5, -280)
Main.BackgroundColor3 = Color3.fromRGB(18,18,24)
Main.BorderSizePixel = 0
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0,14)

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(70,70,85)
Stroke.Parent = Main

--========================================================
-- TITLE
--========================================================

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,50)
TitleBar.BackgroundColor3 = Color3.fromRGB(30,30,40)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0,14)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-55,1,0)
Title.Position = UDim2.new(0,15,0,0)
Title.BackgroundTransparency = 1
Title.Text = "🤖 Human Language Copilot"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0,38,0,38)
Close.Position = UDim2.new(1,-43,0,6)
Close.BackgroundColor3 = Color3.fromRGB(170,55,55)
Close.Text = "×"
Close.TextColor3 = Color3.new(1,1,1)
Close.TextSize = 25
Close.Font = Enum.Font.GothamBold
Close.Parent = TitleBar

Instance.new("UICorner", Close).CornerRadius = UDim.new(0,9)

Close.MouseButton1Click:Connect(function()
	Main.Visible = false
end)

--========================================================
-- STATUS
--========================================================

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1,-30,0,28)
Status.Position = UDim2.new(0,15,0,58)
Status.BackgroundTransparency = 1
Status.Text = "🟢 พร้อมรับคำสั่ง"
Status.TextColor3 = Color3.fromRGB(100,255,130)
Status.TextSize = 13
Status.Font = Enum.Font.Gotham
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

--========================================================
-- INPUT
--========================================================

local Input = Instance.new("TextBox")
Input.Size = UDim2.new(1,-30,0,75)
Input.Position = UDim2.new(0,15,0,88)
Input.BackgroundColor3 = Color3.fromRGB(27,27,35)
Input.BorderSizePixel = 0
Input.ClearTextOnFocus = false
Input.MultiLine = true
Input.TextWrapped = true
Input.Text = ""
Input.PlaceholderText = "พิมพ์ภาษาคนได้เลย เช่น ทำให้วิ่งเร็ว 50"
Input.PlaceholderColor3 = Color3.fromRGB(130,130,140)
Input.TextColor3 = Color3.new(1,1,1)
Input.TextSize = 14
Input.Font = Enum.Font.Gotham
Input.TextXAlignment = Enum.TextXAlignment.Left
Input.TextYAlignment = Enum.TextYAlignment.Top
Input.Parent = Main

Instance.new("UICorner", Input).CornerRadius = UDim.new(0,10)

--========================================================
-- OUTPUT
--========================================================

local Output = Instance.new("TextBox")
Output.Size = UDim2.new(1,-30,0,190)
Output.Position = UDim2.new(0,15,0,173)
Output.BackgroundColor3 = Color3.fromRGB(10,10,14)
Output.BorderSizePixel = 0
Output.ClearTextOnFocus = false
Output.MultiLine = true
Output.TextWrapped = true
Output.Text = "🤖 สวัสดีครับ\n\nพิมพ์คำสั่งภาษามนุษย์ได้เลย"
Output.TextColor3 = Color3.fromRGB(225,225,225)
Output.TextSize = 13
Output.Font = Enum.Font.Code
Output.TextXAlignment = Enum.TextXAlignment.Left
Output.TextYAlignment = Enum.TextYAlignment.Top
Output.Parent = Main

Instance.new("UICorner", Output).CornerRadius = UDim.new(0,10)

--========================================================
-- BUTTON
--========================================================

local function Button(text,x,y,w)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(w, -20, 0, 38)
	b.Position = UDim2.new(x, 10, 0, y)
	b.BackgroundColor3 = Color3.fromRGB(45,45,58)
	b.BorderSizePixel = 0
	b.Text = text
	b.TextColor3 = Color3.new(1,1,1)
	b.TextSize = 12
	b.Font = Enum.Font.GothamBold
	b.Parent = Main

	Instance.new("UICorner", b).CornerRadius = UDim.new(0,9)

	return b
end

local Send = Button("🤖 สั่งงาน",0,375,.5)
local Help = Button("❓ คำสั่ง",.5,375,.5)

local Copy = Button("📋 Copy",0,420,.5)
local Clear = Button("🗑 ล้าง",.5,420,.5)

local History = Button("📜 ประวัติ",0,465,.5)
local Hide = Button("👁 ซ่อน GUI",.5,465,.5)

--========================================================
-- COMMAND ENGINE
--========================================================

local function ExecuteCommand(message)

	message = string.lower(message)

	-- remove common polite words
	message = string.gsub(message,"ครับ","")
	message = string.gsub(message,"ค่ะ","")
	message = string.gsub(message,"หน่อย","")
	message = string.gsub(message,"ที","")
	message = string.gsub(message,"ให้","")

	--------------------------------------------------------
	-- SPEED
	--------------------------------------------------------

	if contains(message,{
		"speed",
		"สปีด",
		"วิ่งเร็ว",
		"วิ่งไว",
		"ความเร็ว",
		"เดินเร็ว"
	}) then

		local value = numberAfter(message,{
			"speed",
			"สปีด",
			"ความเร็ว",
			"วิ่งเร็ว"
		},32)

		local h = humanoid()

		if h then
			h.WalkSpeed = value
			State.Speed = value

			return "✅ ตั้งความเร็วเป็น "..value
		end
	end

	--------------------------------------------------------
	-- NORMAL SPEED
	--------------------------------------------------------

	if contains(message,{
		"คืนสปีด",
		"สปีดปกติ",
		"ความเร็วปกติ",
		"วิ่งปกติ",
		"reset speed"
	}) then

		local h = humanoid()

		if h then
			h.WalkSpeed = 16
			State.Speed = 16

			return "✅ คืนความเร็วเป็น 16"
		end
	end

	--------------------------------------------------------
	-- JUMP
	--------------------------------------------------------

	if contains(message,{
		"jump",
		"กระโดดสูง",
		"กระโดดไกล",
		"พลังกระโดด",
		"กระโดด"
	}) then

		local value = numberAfter(message,{
			"jump",
			"กระโดด",
			"พลัง"
		},80)

		local h = humanoid()

		if h then
			h.UseJumpPower = true
			h.JumpPower = value
			State.Jump = value

			return "✅ ตั้งพลังกระโดดเป็น "..value
		end
	end

	--------------------------------------------------------
	-- NORMAL JUMP
	--------------------------------------------------------

	if contains(message,{
		"กระโดดปกติ",
		"คืนกระโดด",
		"reset jump"
	}) then

		local h = humanoid()

		if h then
			h.UseJumpPower = true
			h.JumpPower = 50
			State.Jump = 50

			return "✅ คืนค่ากระโดดเป็น 50"
		end
	end

	--------------------------------------------------------
	-- HEAL
	--------------------------------------------------------

	if contains(message,{
		"heal",
		"ฮีล",
		"รักษา",
		"เติมเลือด",
		"เลือดเต็ม"
	}) then

		local h = humanoid()

		if h then
			h.Health = h.MaxHealth

			return "❤️ เติมเลือดเต็มแล้ว"
		end
	end

	--------------------------------------------------------
	-- FOV
	--------------------------------------------------------

	if contains(message,{
		"fov",
		"มุมมอง",
		"มุมกล้อง"
	}) then

		local value = numberAfter(message,{
			"fov",
			"มุมมอง",
			"มุมกล้อง"
		},80)

		workspace.CurrentCamera.FieldOfView = value
		State.FOV = value

		return "🎥 ตั้ง FOV เป็น "..value
	end

	--------------------------------------------------------
	-- DAY
	--------------------------------------------------------

	if contains(message,{
		"กลางวัน",
		"day",
		"ตอนกลางวัน"
	}) then

		Lighting.ClockTime = 12

		return "☀️ เปลี่ยนเป็นกลางวันแล้ว"
	end

	--------------------------------------------------------
	-- NIGHT
	--------------------------------------------------------

	if contains(message,{
		"กลางคืน",
		"night",
		"ตอนกลางคืน"
	}) then

		Lighting.ClockTime = 0

		return "🌙 เปลี่ยนเป็นกลางคืนแล้ว"
	end

	--------------------------------------------------------
	-- FULLBRIGHT
	--------------------------------------------------------

	if contains(message,{
		"สว่าง",
		"เพิ่มแสง",
		"fullbright"
	}) then

		Lighting.Brightness = 3
		Lighting.ClockTime = 14

		return "💡 เพิ่มความสว่างแล้ว"
	end

	--------------------------------------------------------
	-- RESET CHARACTER
	--------------------------------------------------------

	if contains(message,{
		"รีตัว",
		"reset ตัว",
		"เกิดใหม่",
		"รีสปอว์น",
		"respawn"
	}) then

		local h = humanoid()

		if h then
			h.Health = 0

			return "🔄 กำลังเกิดใหม่"
		end
	end

	--------------------------------------------------------
	-- SIMPLE GUI
	--------------------------------------------------------

	if contains(message,{
		"สร้าง gui",
		"สร้างหน้าต่าง",
		"ทำ gui",
		"ทำหน้าต่าง"
	}) then

		local demo = Instance.new("ScreenGui")
		demo.Name = "CopilotCreatedGUI"
		demo.ResetOnSpawn = false
		demo.Parent = PlayerGui

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(0,280,0,150)
		frame.Position = UDim2.new(.5,-140,.5,-75)
		frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
		frame.Parent = demo

		Instance.new("UICorner",frame).CornerRadius = UDim.new(0,12)

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1,-20,1,-20)
		label.Position = UDim2.new(0,10,0,10)
		label.BackgroundTransparency = 1
		label.Text = "🤖 GUI ที่ Copilot สร้าง"
		label.TextColor3 = Color3.new(1,1,1)
		label.TextSize = 18
		label.Font = Enum.Font.GothamBold
		label.Parent = frame

		return "🎨 สร้าง GUI ตัวอย่างแล้ว"
	end

	--------------------------------------------------------
	-- DELETE GENERATED GUI
	--------------------------------------------------------

	if contains(message,{
		"ลบ gui",
		"ลบหน้าต่าง",
		"ปิด gui ที่สร้าง"
	}) then

		local g = PlayerGui:FindFirstChild("CopilotCreatedGUI")

		if g then
			g:Destroy()

			return "🗑 ลบ GUI แล้ว"
		end

		return "ไม่มี GUI ที่ Copilot สร้างไว้"
	end

	--------------------------------------------------------
	-- INFO
	--------------------------------------------------------

	if contains(message,{
		"สถานะ",
		"ตอนนี้เป็นอะไร",
		"ค่าปัจจุบัน",
		"ค่าตอนนี้"
	}) then

		return
			"📊 สถานะปัจจุบัน\n\n"
			.."Speed: "..State.Speed.."\n"
			.."Jump: "..State.Jump.."\n"
			.."FOV: "..State.FOV
	end

	--------------------------------------------------------
	-- HELP
	--------------------------------------------------------

	if contains(message,{
		"ช่วยอะไรได้",
		"help",
		"คำสั่ง",
		"ทำอะไรได้"
	}) then

		return
			"🤖 สิ่งที่ลองสั่งได้\n\n"
			.."🏃 วิ่งเร็ว 50\n"
			.."🦘 กระโดดสูง 100\n"
			.."❤️ เติมเลือด\n"
			.."🎥 FOV 90\n"
			.."☀️ กลางวัน\n"
			.."🌙 กลางคืน\n"
			.."💡 ทำให้สว่าง\n"
			.."🔄 เกิดใหม่\n"
			.."🎨 สร้าง GUI\n"
			.."🗑 ลบ GUI\n"
			.."📊 ดูสถานะ"
	end

	--------------------------------------------------------
	-- CHAT / UNKNOWN
	--------------------------------------------------------

	return
		"🤖 ผมอ่านข้อความแล้ว แต่ยังไม่มีระบบรองรับคำสั่งนี้\n\n"
		.."ข้อความของคุณ:\n"
		..message
		.."\n\n"
		.."ลองพิมพ์ 'ช่วยอะไรได้' เพื่อดูคำสั่งที่รองรับ"
end

--========================================================
-- SEND
--========================================================

Send.MouseButton1Click:Connect(function()

	local text = Input.Text

	if text == "" then
		Status.Text = "🔴 กรุณาพิมพ์ข้อความ"
		return
	end

	Status.Text = "🟡 กำลังวิเคราะห์..."

	task.wait(.15)

	local result = ExecuteCommand(text)

	State.LastResult = result

	addHistory(text)

	Output.Text = result

	Status.Text = "🟢 ทำงานเสร็จแล้ว"

end)

--========================================================
-- HELP
--========================================================

Help.MouseButton1Click:Connect(function()

	Output.Text =
		"🤖 ตัวอย่างภาษาที่ใช้ได้\n\n"
		.."• ทำให้ผมวิ่งเร็ว 50\n"
		.."• เพิ่มสปีดเป็น 100\n"
		.."• ขอกระโดดสูง 120\n"
		.."• เติมเลือดให้หน่อย\n"
		.."• ตั้ง FOV 90\n"
		.."• เปลี่ยนเป็นกลางวัน\n"
		.."• ทำให้สว่าง\n"
		.."• เกิดใหม่\n"
		.."• สร้าง GUI\n"
		.."• ลบ GUI\n"
		.."• ดูสถานะ\n\n"
		.."หมายเหตุ: คำสั่งใหม่ต้องเพิ่มความสามารถให้ระบบก่อน"
end)

--========================================================
-- COPY
--========================================================

Copy.MouseButton1Click:Connect(function()

	if State.LastResult == "" then
		Status.Text = "🔴 ยังไม่มีข้อความ"
		return
	end

	if setclipboard then
		setclipboard(State.LastResult)
		Status.Text = "🟢 Copy แล้ว"
	else
		Status.Text = "🔴 ระบบนี้ไม่มี Clipboard API"
	end

end)

--========================================================
-- CLEAR
--========================================================

Clear.MouseButton1Click:Connect(function()

	Input.Text = ""
	Output.Text = "🤖 พร้อมรับคำสั่งใหม่"

	State.LastResult = ""

	Status.Text = "🟢 พร้อมทำงาน"

end)

--========================================================
-- HISTORY
--========================================================

History.MouseButton1Click:Connect(function()

	if #State.History == 0 then
		Output.Text = "📜 ยังไม่มีประวัติ"
		return
	end

	local text = "📜 ประวัติคำสั่ง\n\n"

	for i, command in ipairs(State.History) do
		text = text .. i .. ". " .. command .. "\n"
	end

	Output.Text = text

end)

--========================================================
-- HIDE
--========================================================

Hide.MouseButton1Click:Connect(function()
	Main.Visible = false
end)

--========================================================
-- OPEN BUTTON
--========================================================

local Open = Instance.new("TextButton")
Open.Size = UDim2.new(0,55,0,55)
Open.Position = UDim2.new(0,15,.5,-27)
Open.BackgroundColor3 = Color3.fromRGB(35,35,45)
Open.Text = "🤖"
Open.TextSize = 25
Open.Parent = Gui

Instance.new("UICorner",Open).CornerRadius = UDim.new(1,0)

Open.MouseButton1Click:Connect(function()
	Main.Visible = not Main.Visible
end)

--========================================================
-- DRAG SUPPORT
--========================================================

local dragging = false
local dragStart
local startPosition

TitleBar.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPosition = Main.Position

	end
end)

TitleBar.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then

		dragging = false

	end
end)

UserInputService.InputChanged:Connect(function(input)

	if not dragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
	or input.UserInputType == Enum.UserInputType.Touch then

		local delta = input.Position - dragStart

		Main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)

	end
end)

--========================================================
-- START ANIMATION
--========================================================

Main.Position = UDim2.new(.5,-185,1.2,0)

TweenService:Create(
	Main,
	TweenInfo.new(.45,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
	{
		Position = UDim2.new(.5,-185,.5,-280)
	}
):Play()

print("🤖 Human Language Copilot loaded")
