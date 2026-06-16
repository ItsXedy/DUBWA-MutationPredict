local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Prevent duplicate GUI frames
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

-- Main Frame Container
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 245)
MainFrame.Position = UDim2.new(0.5, -130, 0.4, -122)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 32, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 10)
MainUICorner.Parent = MainFrame

-- Header Drag/Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 44, 62)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleUICorner = Instance.new("UICorner")
TitleUICorner.CornerRadius = UDim.new(0, 10)
TitleUICorner.Parent = TitleBar

-- Title Text Label
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

-- Destroy/Close Button
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

-- Minimize/Toggle Button
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

-- Text Listings Body Area
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -85)
ContentFrame.Position = UDim2.new(0, 10, 0, 42)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = ContentFrame

-- Manual Refresh Trigger Button
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

-- ==========================================
-- INTERACTIVE WINDOW STATE HANDLERS
-- ==========================================

-- Destroy Interface Action
DestroyButton.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- Structural Minimize to Circle Toggle
local minimized = false
ToggleButton.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		-- Hide operational assets
		ContentFrame.Visible = false
		ManualRefreshButton.Visible = false
		DestroyButton.Visible = false
		
		-- Collapse layout style to standalone circle
		MainFrame.Size = UDim2.new(0, 35, 0, 35)
		TitleBar.Size = UDim2.new(1, 0, 1, 0)
		MainUICorner.CornerRadius = UDim.new(1, 0)
		TitleUICorner.CornerRadius = UDim.new(1, 0)
		
		-- Center absolute icon state inside the bubble
		TitleText.Text = "⏳"
		TitleText.Size = UDim2.new(1, 0, 1, 0)
		TitleText.TextXAlignment = Enum.TextXAlignment.Center
		
		-- Offset button to toggle layout expansion back out
		ToggleButton.Position = UDim2.new(0, 0, 0, 0)
		ToggleButton.Size = UDim2.new(1, 0, 1, 0)
		ToggleButton.Text = ""
	else
		-- Re-expand structures to menu panel metrics
		MainFrame.Size = UDim2.new(0, 260, 0, 245)
		TitleBar.Size = UDim2.new(1, 0, 0, 35)
		MainUICorner.CornerRadius = UDim.new(0, 10)
		TitleUICorner.CornerRadius = UDim.new(0, 10)
		
		TitleText.Text = "⏳ EVENT TIMERS"
		TitleText.Size = UDim2.new(1, -70, 1, 0)
		TitleText.TextXAlignment = Enum.TextXAlignment.Left
		
		ToggleButton.Size = UDim2.new(0, 30, 0, 30)
		ToggleButton.Position = UDim2.new(1, -35, 0, 2)
		ToggleButton.Text = "➖"
		
		-- Unhide operational frame layers
		ContentFrame.Visible = true
		ManualRefreshButton.Visible = true
		DestroyButton.Visible = true
	end
end)

-- ==========================================
-- STRING DATA MATRICES & RENDER HANDLERS
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
		label.TextColor3 = Color3.fromRGB(85, 255, 127) -- Vibrant green
	else
		label.TextColor3 = Color3.fromRGB(220, 220, 225) -- Neutral off-white
	end
	
	label.Parent = ContentFrame
end

local function updateUIStrings()
	-- Only rebuild if layout is structural panel view
	if minimized then return end
	
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

-- Wire manual refresh input trigger
ManualRefreshButton.MouseButton1Click:Connect(updateUIStrings)

-- Live running automation task pipeline loop
task.spawn(function()
	while true do
		pcall(updateUIStrings)
		task.wait(1)
	end
end)
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
