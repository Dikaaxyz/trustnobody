--[[
    Growblox God Mode v8 | Clean UI Edition
    Target: Growblox (Roblox) / Xeno Executor
    UI: Replicated from reference image
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- 1. TOTAL BYPASS LAYER
-- ============================================================
local bypass_success = pcall(function()
    local mt = getrawmetatable(game)
    local old_namecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" and self == LocalPlayer then return nil end
        if method == "FireServer" and (self.Name:lower():find("anticheat") or self.Name:lower():find("report") or self.Name:lower():find("log")) then return nil end
        if method == "GetNetworkPing" then return 0.03 end
        return old_namecall(self, ...)
    end)
    setreadonly(mt, true)
    
    if getidentity and hookfunction then
        hookfunction(getidentity, function(...) return 8 end)
        hookfunction(trustcheck, function(...) return true end)
    end
end)

-- ============================================================
-- 2. STATE CONFIGURATION
-- ============================================================
local State = {
    Spam = false,
    PutBreak = false,
    Collect = false,
    Drop = false,
    Geiger = false,
    Ghost = false,
    Fishing = false,
    
    Delay = 191,
    BlockName = "Dirt",
    BlockID = 2,
    BreakHit = 3,
    TileSize = 3,
}

-- ============================================================
-- 3. REMOTES
-- ============================================================
local Remotes = {}
for _, v in pairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        Remotes[string.lower(v.Name)] = v
    end
end

local function R(keyword)
    for k, v in pairs(Remotes) do
        if string.find(k, keyword) then return v end
    end
    return nil
end

local R_Place = R("place") or R("build") or R("set")
local R_Punch = R("punch") or R("break") or R("hit")
local R_Collect = R("collect") or R("pickup") or R("grab")
local R_Drop = R("drop") or R("trash")

-- ============================================================
-- 4. QUEUE SYSTEM
-- ============================================================
local TaskQueue = {}
local isProcessing = false

local function QueueRemote(remote, ...)
    if not remote then return end
    table.insert(TaskQueue, {remote = remote, args = {...}})
    if not isProcessing then
        task.spawn(function()
            isProcessing = true
            while #TaskQueue > 0 do
                local taskData = table.remove(TaskQueue, 1)
                task.wait(math.random(45, 120) / 1000) 
                pcall(function() taskData.remote:FireServer(unpack(taskData.args)) end)
            end
            isProcessing = false
        end)
    end
end

-- ============================================================
-- 5. GUI CREATION (Replicated from Image)
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GrowbloxUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 620, 0, 300)
Main.Position = UDim2.new(0.5, -310, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

-- Stroke border luar
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(60, 60, 60)
Stroke.Thickness = 2

-- ============================================================
-- LEFT PANEL (Menu List)
-- ============================================================
local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0, 140, 1, 0)
LeftPanel.Position = UDim2.new(0, 0, 0, 0)
LeftPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
LeftPanel.BorderSizePixel = 0
LeftPanel.Parent = Main
Instance.new("UICorner", LeftPanel).CornerRadius = UDim.new(0, 6)

local LeftLayout = Instance.new("UIListLayout")
LeftLayout.Padding = UDim.new(0, 0)
LeftLayout.Parent = LeftPanel

local function CreateLeftButton(text, order, toggleState)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 28)
    Btn.BackgroundColor3 = toggleState and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(35, 35, 35)
    Btn.Text = "   " .. text
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.TextSize = 14
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.LayoutOrder = order
    Btn.Parent = LeftPanel
    
    Btn.MouseButton1Click:Connect(function()
        State[text:gsub(" ", "")] = not State[text:gsub(" ", "")]
        Btn.BackgroundColor3 = State[text:gsub(" ", "")] and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(35, 35, 35)
    end)
end

CreateLeftButton("Spam", 1, false)
CreateLeftButton("Put & Break", 2, true)
CreateLeftButton("Collect", 3, false)
CreateLeftButton("Drop", 4, false)
CreateLeftButton("Geiger", 5, false)
CreateLeftButton("Ghost", 6, false)
CreateLeftButton("Fishing", 7, false)

-- ============================================================
-- MIDDLE PANEL (Controls)
-- ============================================================
local MidPanel = Instance.new("Frame")
MidPanel.Size = UDim2.new(0, 290, 1, 0)
MidPanel.Position = UDim2.new(0, 150, 0, 0)
MidPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MidPanel.BorderSizePixel = 0
MidPanel.Parent = Main

-- Garis pemisah kiri
local Sep1 = Instance.new("Frame", MidPanel)
Sep1.Size = UDim2.new(0, 1, 1, 0)
Sep1.Position = UDim2.new(0, 0, 0, 0)
Sep1.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Sep1.BorderSizePixel = 0

-- STOP Button
local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(0, 60, 0, 30)
StopBtn.Position = UDim2.new(0, 10, 0, 10)
StopBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
StopBtn.Text = "STOP"
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.TextSize = 14
StopBtn.Font = Enum.Font.GothamBold
StopBtn.Parent = MidPanel
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 4)

StopBtn.MouseButton1Click:Connect(function()
    for k, v in pairs(State) do
        if type(v) == "boolean" then State[k] = false end
    end
    TaskQueue = {}
    for _, child in pairs(LeftPanel:GetChildren()) do
        if child:IsA("TextButton") then
            child.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        end
    end
end)

-- Warning Text
local Warn = Instance.new("TextLabel")
Warn.Size = UDim2.new(0, 220, 0, 30)
Warn.Position = UDim2.new(0, 75, 0, 10)
Warn.BackgroundTransparency = 1
Warn.Text = "Bellow 200 Ez ban if you have po"
Warn.TextColor3 = Color3.fromRGB(220, 200, 0)
Warn.TextSize = 13
Warn.Font = Enum.Font.Gotham
Warn.TextXAlignment = Enum.TextXAlignment.Left
Warn.Parent = MidPanel

-- Delay Slider Background
local SliderBg = Instance.new("Frame")
SliderBg.Size = UDim2.new(0, 180, 0, 30)
SliderBg.Position = UDim2.new(0, 10, 0, 45)
SliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SliderBg.Parent = MidPanel
Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(0, 4)

-- Slider Fill
local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.38, 0, 1, 0) -- ~191/500
SliderFill.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
SliderFill.Parent = SliderBg
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 4)

-- Slider Text (Number)
local SliderNum = Instance.new("TextLabel")
SliderNum.Size = UDim2.new(1, 0, 1, 0)
SliderNum.BackgroundTransparency = 1
SliderNum.Text = "191"
SliderNum.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderNum.TextSize = 14
SliderNum.Font = Enum.Font.Gotham
SliderNum.Parent = SliderBg

-- "Delay" Label
local DelayLabel = Instance.new("TextLabel")
DelayLabel.Size = UDim2.new(0, 100, 0, 30)
DelayLabel.Position = UDim2.new(0, 195, 0, 45)
DelayLabel.BackgroundTransparency = 1
DelayLabel.Text = "Delay"
DelayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
DelayLabel.TextSize = 14
DelayLabel.Font = Enum.Font.Gotham
DelayLabel.TextXAlignment = Enum.TextXAlignment.Left
DelayLabel.Parent = MidPanel

-- Block Name Box
local NameBox = Instance.new("TextBox")
NameBox.Size = UDim2.new(0, 180, 0, 30)
NameBox.Position = UDim2.new(0, 10, 0, 85)
NameBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
NameBox.Text = "Dirt"
NameBox.TextColor3 = Color3.fromRGB(200, 200, 200)
NameBox.TextSize = 14
NameBox.Font = Enum.Font.Gotham
NameBox.TextXAlignment = Enum.TextXAlignment.Left
NameBox.Parent = MidPanel
Instance.new("UICorner", NameBox).CornerRadius = UDim.new(0, 4)
Instance.new("UIPadding", NameBox).PaddingLeft = UDim.new(0, 10)

-- Block ID Box
local IDBox = Instance.new("TextBox")
IDBox.Size = UDim2.new(0, 80, 0, 30)
IDBox.Position = UDim2.new(0, 200, 0, 85)
IDBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
IDBox.Text = "ID: 2"
IDBox.TextColor3 = Color3.fromRGB(200, 200, 200)
IDBox.TextSize = 14
IDBox.Font = Enum.Font.Gotham
IDBox.Parent = MidPanel
Instance.new("UICorner", IDBox).CornerRadius = UDim.new(0, 4)

-- Break Hit Frame
local BreakFrame = Instance.new("Frame")
BreakFrame.Size = UDim2.new(0, 180, 0, 30)
BreakFrame.Position = UDim2.new(0, 10, 0, 125)
BreakFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
BreakFrame.Parent = MidPanel
Instance.new("UICorner", BreakFrame).CornerRadius = UDim.new(0, 4)

local BreakNum = Instance.new("TextLabel")
BreakNum.Size = UDim2.new(1, 0, 1, 0)
BreakNum.BackgroundTransparency = 1
BreakNum.Text = "3"
BreakNum.TextColor3 = Color3.fromRGB(200, 200, 200)
BreakNum.TextSize = 14
BreakNum.Font = Enum.Font.Gotham
BreakNum.Parent = BreakFrame

-- "-" Button
local MinusBtn = Instance.new("TextButton")
MinusBtn.Size = UDim2.new(0, 30, 1, 0)
MinusBtn.Position = UDim2.new(0.5, -30, 0, 0)
MinusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinusBtn.Text = "-"
MinusBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinusBtn.TextSize = 16
MinusBtn.Font = Enum.Font.GothamBold
MinusBtn.Parent = BreakFrame
Instance.new("UICorner", MinusBtn).CornerRadius = UDim.new(0, 4)

-- "+" Button
local PlusBtn = Instance.new("TextButton")
PlusBtn.Size = UDim2.new(0, 30, 1, 0)
PlusBtn.Position = UDim2.new(1, -30, 0, 0)
PlusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
PlusBtn.Text = "+"
PlusBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
PlusBtn.TextSize = 16
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.Parent = BreakFrame
Instance.new("UICorner", PlusBtn).CornerRadius = UDim.new(0, 4)

-- Break Hit Label
local BreakLabel = Instance.new("TextLabel")
BreakLabel.Size = UDim2.new(0, 100, 0, 30)
BreakLabel.Position = UDim2.new(0, 195, 0, 125)
BreakLabel.BackgroundTransparency = 1
BreakLabel.Text = "Break Hit"
BreakLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
BreakLabel.TextSize = 14
BreakLabel.Font = Enum.Font.Gotham
BreakLabel.TextXAlignment = Enum.TextXAlignment.Left
BreakLabel.Parent = MidPanel

-- ============================================================
-- RIGHT PANEL (Grid)
-- ============================================================
local RightPanel = Instance.new("Frame")
RightPanel.Size = UDim2.new(0, 170, 1, 0)
RightPanel.Position = UDim2.new(0, 450, 0, 0)
RightPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
RightPanel.BorderSizePixel = 0
RightPanel.Parent = Main

-- Garis pemisah kanan
local Sep2 = Instance.new("Frame", RightPanel)
Sep2.Size = UDim2.new(0, 1, 1, 0)
Sep2.Position = UDim2.new(0, 0, 0, 0)
Sep2.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Sep2.BorderSizePixel = 0

-- Grid Container
local GridFrame = Instance.new("Frame")
GridFrame.Size = UDim2.new(1, -20, 1, -20)
GridFrame.Position = UDim2.new(0, 10, 0, 10)
GridFrame.BackgroundTransparency = 1
GridFrame.Parent = RightPanel

local Grid = Instance.new("UIGridLayout")
Grid.CellSize = UDim2.new(0, 22, 0, 22)
Grid.CellPadding = UDim2.new(0, 4, 0, 4)
Grid.SortOrder = Enum.SortOrder.LayoutOrder
Grid.Parent = GridFrame

for i = 1, 25 do
    local Slot = Instance.new("Frame")
    Slot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Slot.BorderSizePixel = 0
    Slot.LayoutOrder = i
    Slot.Parent = GridFrame
    Instance.new("UICorner", Slot).CornerRadius = UDim.new(0, 2)
    
    -- Default 3 red blocks in the middle row
    if i == 13 or i == 14 or i == 15 then
        Slot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
    
    -- Click to select ID
    local SlotBtn = Instance.new("TextButton")
    SlotBtn.Size = UDim2.new(1, 0, 1, 0)
    SlotBtn.BackgroundTransparency = 1
    SlotBtn.Text = ""
    SlotBtn.Parent = Slot
    
    SlotBtn.MouseButton1Click:Connect(function()
        State.BlockID = i
        IDBox.Text = "ID: " .. tostring(i)
        
        -- Reset semua warna
        for _, child in pairs(GridFrame:GetChildren()) do
            if child:IsA("Frame") then
                child.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            end
        end
        
        -- Warnain yang dipilih
        Slot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end)
end

-- Hotkeys Text (Q, 1, 2, 3, W)
local HotkeyFrame = Instance.new("Frame")
HotkeyFrame.Size = UDim2.new(0, 180, 0, 15)
HotkeyFrame.Position = UDim2.new(0, 10, 0, 155)
HotkeyFrame.BackgroundTransparency = 1
HotkeyFrame.Parent = MidPanel

local Hotkeys = {"Q", "1", "2", "3"}
local xPos = 0
for _, key in ipairs(Hotkeys) do
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(0, 20, 1, 0)
    txt.Position = UDim2.new(0, xPos, 0, 0)
    txt.BackgroundTransparency = 1
    txt.Text = key
    txt.TextColor3 = Color3.fromRGB(150, 150, 150)
    txt.TextSize = 11
    txt.Font = Enum.Font.GothamBold
    txt.Parent = HotkeyFrame
    xPos = xPos + 45
end

-- ============================================================
-- 6. UI LOGIC
-- ============================================================
local dragging = false
local function updateDelay(input)
    local pos = math.clamp(input.Position.X - SliderBg.AbsolutePosition.X, 0, SliderBg.AbsoluteSize.X)
    local pct = pos / SliderBg.AbsoluteSize.X
    State.Delay = math.floor(pct * 500)
    SliderFill.Size = UDim2.new(pct, 0, 1, 0)
    SliderNum.Text = tostring(State.Delay)
end

SliderBg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
SliderBg.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateDelay(input) end end)

NameBox.FocusLost:Connect(function() State.BlockName = NameBox.Text end)
IDBox.FocusLost:Connect(function() 
    local num = tonumber(IDBox.Text:match("%d+"))
    if num then State.BlockID = num end
end)

MinusBtn.MouseButton1Click:Connect(function()
    State.BreakHit = math.max(1, State.BreakHit - 1)
    BreakNum.Text = tostring(State.BreakHit)
end)
PlusBtn.MouseButton1Click:Connect(function()
    State.BreakHit = math.min(10, State.BreakHit + 1)
    BreakNum.Text = tostring(State.BreakHit)
end)

-- ============================================================
-- 7. MAIN LOOP (Punch & Place)
-- ============================================================
local function GetPos()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    return hrp and hrp.Position or Vector3.new(0,0,0)
end

task.spawn(function()
    while task.wait(0.1) do
        if State.PutBreak then
            local pos = GetPos()
            local tx, tz = math.floor(pos.X/State.TileSize), math.floor(pos.Z/State.TileSize)
            if R_Place then QueueRemote(R_Place, tx, tz, State.BlockID) end
            task.wait(State.Delay / 1000)
            for i=1, State.BreakHit do
                if R_Punch then QueueRemote(R_Punch, tx, tz) end
                task.wait(0.05)
            end
        end
        
        if State.Collect and R_Collect then
            local pos = GetPos()
            if R_Collect then QueueRemote(R_Collect, math.floor(pos.X/State.TileSize), math.floor(pos.Z/State.TileSize)) end
            task.wait(0.2)
        end

        if State.Drop and R_Drop then
            for i = 1, 3 do QueueRemote(R_Drop) end
            task.wait(0.5)
        end
    end
end)

print("[Growblox V8] Clean UI Loaded. Bypass: " .. tostring(bypass_success))
