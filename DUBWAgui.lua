local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Remove any old versions of this GUI to prevent duplication
if CoreGui:FindFirstChild("MutationTimeExtractor") then
	CoreGui.MutationTimeExtractor:Destroy()
end

-- ==========================================
-- UI CONSTRUCTION
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MutationTimeExtractor"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Main Window Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 210)
MainFrame.Position = UDim2.new(0.5, -130, 0.4, -105)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 32, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 10)
MainUICorner.Parent = MainFrame

-- Top Drag/Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 44, 62)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleUICorner = Instance.new("UICorner")
TitleUICorner.CornerRadius = UDim.new(0, 10)
TitleUICorner.Parent = TitleBar

-- Title Text
local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -10, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "⏳ EVENT TIME STRINGS"
TitleText.TextColor3 = Color3.fromRGB(240, 240, 240)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 13
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Minimize/Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 30, 0, 30)
ToggleButton.Position = UDim2.new(1, -35, 0, 2)
ToggleButton.BackgroundTransparency = 1
ToggleButton.Text = "✖"
ToggleButton.TextColor3 = Color3.fromRGB(180, 180, 180)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.Parent = TitleBar

-- Text Output Display Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -50)
ContentFrame.Position = UDim2.new(0, 10, 0, 42)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = ContentFrame

-- ==========================================
-- DRAGGABLE ENGINE (Mobile & PC Friendly)
-- ==========================================
local dragging, dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

TitleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- Minimize Functionality
local minimized = false
ToggleButton.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		ContentFrame.Visible = false
		MainFrame.Size = UDim2.new(0, 260, 0, 35)
		ToggleButton.Text = "➕"
	else
		ContentFrame.Visible = true
		MainFrame.Size = UDim2.new(0, 260, 0, 210)
		ToggleButton.Text = "✖"
	end
end)

-- ==========================================
-- DATA EXTRACTOR & AUTO-REFRESH LOGIC
-- ==========================================
local PUBLIC_EVENTS = {
	"Nen",
	"Dragonborn",
	"Beast",
	"Arrancar",
	"Titan",
	"Buhara"
}

local function clearLabels()
	for _, child in ipairs(ContentFrame:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
end

local function createTextLine(text, isActive, layoutOrder)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 22)
	label.BackgroundTransparency = 1
	label.Text = text
	label.Font = Enum.Font.GothamSemibold
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.LayoutOrder = layoutOrder
	
	if isActive then
		label.TextColor3 = Color3.fromRGB(85, 255, 127) -- Vibrant Green for active
	else
		label.TextColor3 = Color3.fromRGB(220, 220, 225) -- Muted white/grey for waiting
	end
	
	label.Parent = ContentFrame
end

local function updateUIStrings()
	clearLabels()
	
	local currentActive = Workspace:GetAttribute("MutationEvent")
	local eventList = {}

	for _, name in ipairs(PUBLIC_EVENTS) do
		local rawValue = Workspace:GetAttribute(name)
		local numTime = tonumber(rawValue)

		if numTime then
			local secondsLeft = numTime
			if numTime > 1000000000 then 
				secondsLeft = numTime - os.time()
			end

			local minutesLeft = math.floor(secondsLeft / 60)
			if minutesLeft < 0 then minutesLeft = 0 end

			table.insert(eventList, {
				Name = name,
				Minutes = minutesLeft,
				IsActive = (name == currentActive)
			})
		end
	end

	-- Always keep sorted chronologically
	table.sort(eventList, function(a, b)
		return a.Minutes < b.Minutes
	end)

	if #eventList == 0 then
		createTextLine("No active event timers found.", false, 1)
		return
	end

	for idx, event in ipairs(eventList) do
		local displayName = event.Name
		
		if displayName == "Nen" or displayName == "Buhara" then
			displayName = "Buhara / Nen Event"
		else
			displayName = displayName .. " Mutation"
		end

		local formattedString = ""
		if event.IsActive then
			formattedString = string.format("0 Minutes = %s (ACTIVE NOW)", displayName)
		else
			formattedString = string.format("%d Minutes = %s", event.Minutes, displayName)
		end
		
		createTextLine(formattedString, event.IsActive, idx)
	end
end

-- Fast auto-refresh loop that runs every second to check for exact changes or countdown updates
task.spawn(function()
	while true do
		pcall(updateUIStrings)
		task.wait(1)
	end
end)
