--[[
	OPTIMIZATION NOTES:
	- Fixed memory leak in drag handler (connections now properly disconnected).
	- Reuse event list table each cycle to reduce GC pressure.
	- Predefined constant Color3 values and format strings to avoid recreation.
	- Replace tonumber with type check (attributes are expected to be numbers).
	- Minor code cleanup: moved draggable logic into a cleaner pattern.
--]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Destroy previous GUI if it exists
if CoreGui:FindFirstChild("MutationTimeExtractor") then
	CoreGui.MutationTimeExtractor:Destroy()
end

-- GUI construction
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MutationTimeExtractor"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 180)
MainFrame.Position = UDim2.new(0.5, -130, 0.4, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 32, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 10)
MainUICorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 44, 62)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleUICorner = Instance.new("UICorner")
TitleUICorner.CornerRadius = UDim.new(0, 10)
TitleUICorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -70, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "⏳ EVENT TIMERS"
TitleText.TextColor3 = Color3.fromRGB(240, 240, 240)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 13
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local DestroyButton = Instance.new("TextButton")
DestroyButton.Name = "DestroyButton"
DestroyButton.Size = UDim2.new(0, 30, 0, 30)
DestroyButton.Position = UDim2.new(1, -65, 0, 2)
DestroyButton.BackgroundTransparency = 1
DestroyButton.Text = "⌫"
DestroyButton.TextColor3 = Color3.fromRGB(255, 95, 95)
DestroyButton.Font = Enum.Font.GothamBold
DestroyButton.TextSize = 14
DestroyButton.Parent = TitleBar

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 30, 0, 30)
ToggleButton.Position = UDim2.new(1, -35, 0, 2)
ToggleButton.BackgroundTransparency = 1
ToggleButton.Text = "➖"
ToggleButton.TextColor3 = Color3.fromRGB(180, 180, 180)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.Parent = TitleBar

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 0, 85)
ContentFrame.Position = UDim2.new(0, 10, 0, 45)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = ContentFrame

local ManualRefreshButton = Instance.new("TextButton")
ManualRefreshButton.Name = "ManualRefreshButton"
ManualRefreshButton.Size = UDim2.new(1, -20, 0, 30)
ManualRefreshButton.Position = UDim2.new(0, 10, 1, -40)
ManualRefreshButton.BackgroundColor3 = Color3.fromRGB(48, 54, 78)
ManualRefreshButton.Text = "🔄 Refresh Data"
ManualRefreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ManualRefreshButton.Font = Enum.Font.GothamBold
ManualRefreshButton.TextSize = 12
ManualRefreshButton.Parent = MainFrame

local RefreshCorner = Instance.new("UICorner")
RefreshCorner.CornerRadius = UDim.new(0, 6)
RefreshCorner.Parent = ManualRefreshButton

-- Static label pool (prevents per-update Instance.new)
local labelPool = {}
for i = 1, 3 do
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 22)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamSemibold
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Visible = false
	label.LayoutOrder = i
	label.Parent = ContentFrame
	labelPool[i] = label
end

-- ======================
-- DRAG SYSTEM (OPTIMIZED)
-- ======================
local dragging = false
local dragStart = nil
local startPos = nil
local dragConnection = nil

local function stopDrag()
	dragging = false
	if dragConnection then
		dragConnection:Disconnect()
		dragConnection = nil
	end
end

TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		-- Clean up any existing drag
		stopDrag()

		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position

		dragConnection = UserInputService.InputChanged:Connect(function(changedInput)
			if not dragging then return end
			if changedInput.UserInputType == Enum.UserInputType.MouseMovement or changedInput.UserInputType == Enum.UserInputType.Touch then
				local delta = changedInput.Position - dragStart
				MainFrame.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			end
		end)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and dragging then
		stopDrag()
	end
end)

DestroyButton.MouseButton1Click:Connect(function()
	stopDrag() -- prevent cleanup errors on destroy
	ScreenGui:Destroy()
end)

-- ======================
-- MINIMIZE / RESTORE
-- ======================
local minimized = false
ToggleButton.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		ContentFrame.Visible = false
		ManualRefreshButton.Visible = false
		DestroyButton.Visible = false

		MainFrame.Size = UDim2.new(0, 45, 0, 45)
		TitleBar.Size = UDim2.new(1, 0, 1, 0)
		MainUICorner.CornerRadius = UDim.new(1, 0)
		TitleUICorner.CornerRadius = UDim.new(1, 0)

		TitleText.Text = "⏳"
		TitleText.Size = UDim2.new(1, 0, 1, 0)
		TitleText.TextXAlignment = Enum.TextXAlignment.Center

		ToggleButton.Position = UDim2.new(0, 0, 0, 0)
		ToggleButton.Size = UDim2.new(1, 0, 1, 0)
		ToggleButton.Text = ""
	else
		MainFrame.Size = UDim2.new(0, 260, 0, 180)
		TitleBar.Size = UDim2.new(1, 0, 0, 35)
		MainUICorner.CornerRadius = UDim.new(0, 10)
		TitleUICorner.CornerRadius = UDim.new(0, 10)

		TitleText.Text = "⏳ EVENT TIMERS"
		TitleText.Size = UDim2.new(1, -70, 1, 0)
		TitleText.TextXAlignment = Enum.TextXAlignment.Left

		ToggleButton.Size = UDim2.new(0, 30, 0, 30)
		ToggleButton.Position = UDim2.new(1, -35, 0, 2)
		ToggleButton.Text = "➖"

		ContentFrame.Visible = true
		ManualRefreshButton.Visible = true
		DestroyButton.Visible = true
	end
end)

-- ======================
-- DATA PROCESSING ENGINE
-- ======================
local PUBLIC_EVENTS = {"Nen", "Dragonborn", "Beast", "Arrancar", "Titan", "Buhara"}

-- Constant colours to avoid per-frame Color3.fromRGB
local COLOR_ACTIVE = Color3.fromRGB(85, 255, 127)
local COLOR_INACTIVE = Color3.fromRGB(220, 220, 225)
local COLOR_NO_DATA = Color3.fromRGB(220, 220, 225)

-- Reusable table to avoid creating new tables every update
local eventList = {}

local function updateUIStrings()
	-- If minimised, hide all labels and exit
	if minimized then
		for i = 1, 3 do
			labelPool[i].Visible = false
		end
		return
	end

	local currentActive = Workspace:GetAttribute("MutationEvent")
	local curTime = os.time()

	-- Clear and reuse table
	table.clear(eventList)

	for i = 1, #PUBLIC_EVENTS do
		local name = PUBLIC_EVENTS[i]
		local rawValue = Workspace:GetAttribute(name)

		-- Expect a number directly, skip if not
		if type(rawValue) == "number" then
			local secondsLeft = rawValue
			if rawValue > 1000000000 then
				secondsLeft = rawValue - curTime
			end
			local minutesLeft = math.floor(secondsLeft / 60)
			if minutesLeft < 0 then
				minutesLeft = 0
			end
			-- Insert into reusable table
			eventList[#eventList + 1] = {
				Name = name,
				Minutes = minutesLeft,
				IsActive = (name == currentActive)
			}
		end
	end

	-- Sort chronologically
	table.sort(eventList, function(a, b)
		return a.Minutes < b.Minutes
	end)

	-- Map to static labels
	for i = 1, 3 do
		local data = eventList[i]
		local label = labelPool[i]

		if data then
			local displayName
			if data.Name == "Nen" or data.Name == "Buhara" then
				displayName = "Buhara / Nen Event"
			else
				displayName = data.Name .. " Mutation"
			end

			if data.IsActive then
				label.Text = string.format("0 Minutes = %s (ACTIVE NOW)", displayName)
				label.TextColor3 = COLOR_ACTIVE
			else
				label.Text = string.format("%d Minutes = %s", data.Minutes, displayName)
				label.TextColor3 = COLOR_INACTIVE
			end
			label.Visible = true
		else
			if i == 1 and #eventList == 0 then
				label.Text = "No active event timers found."
				label.TextColor3 = COLOR_NO_DATA
				label.Visible = true
			else
				label.Visible = false
			end
		end
	end
end

ManualRefreshButton.MouseButton1Click:Connect(updateUIStrings)

-- Main loop (protected against errors)
task.spawn(function()
	while true do
		local success, err = pcall(updateUIStrings)
		if not success then
			warn("Time Extractor Loop Warning: " .. tostring(err))
		end
		task.wait(1)
	end
end)
