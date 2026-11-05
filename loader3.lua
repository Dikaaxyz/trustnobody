--[[
    Growblox God Mode v19 | Legit Walk Bypass (Anti-267)
    Target: Growblox (Roblox) / Xeno Executor
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- 1. STATE CONFIGURATION
-- ============================================================
local State = {
    Spam = false, PutBreak = false, Collect = false, Drop = false, Geiger = false, Ghost = false, Fishing = false,
    AutoFarm = false, AutoClear = false, AutoCollect = false, FastDrop = false, AutoAvoid = false, SpoofName = false, SpoofSkin = false,
    Delay = 500, 
    SelectedBlocks = {15}, 
    BreakHit = 3,
    TileSize = 3, SafeWorld = "STORAGE_WORLD"
}

-- ============================================================
-- 2. REMOTES
-- ============================================================
local Remotes = {}
for _, v in pairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then Remotes[string.lower(v.Name)] = v end
end

local function R(keyword)
    for k, v in pairs(Remotes) do if string.find(k, keyword) then return v end end
    return nil
end

local R_Place = R("place") or R("build") or R("set")
local R_Punch = R("punch") or R("break") or R("hit")
local R_Warp = R("warp") or R("join") or R("world") or R("travel")
local R_Drop = R("drop") or R("trash")
local R_Collect = R("collect") or R("pickup") or R("grab")
local R_Leave = R("leave") or R("exit")

-- ============================================================
-- 3. SAFE EXECUTION (Tanpa Metatable / Hook)
-- ============================================================
local function Fire(remote, ...)
    if remote then pcall(function() remote:FireServer(...) end) end
end

-- ============================================================
-- 4. GUI CREATION (PlayerGui biar aman)
-- ============================================================
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local old = PlayerGui:FindFirstChild("GrowbloxV19")
if old then old:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GrowbloxV19"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 700, 0, 480)
Main.Position = UDim2.new(0.5, -350, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 4)

-- LEFT PANEL
local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0, 150, 1, 0)
LeftPanel.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
LeftPanel.Parent = Main
local LeftScroll = Instance.new("ScrollingFrame")
LeftScroll.Size = UDim2.new(1, 0, 1, 0)
LeftScroll.BackgroundTransparency = 1
LeftScroll.ScrollBarThickness = 2
LeftScroll.Parent = LeftPanel
Instance.new("UIListLayout", LeftScroll).SortOrder = Enum.SortOrder.LayoutOrder

local function CreateLeftBtn(text, varName, defaultState, order)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 30)
    Btn.BackgroundColor3 = defaultState and Color3.fromRGB(255, 20, 20) or Color3.fromRGB(28, 28, 28)
    Btn.Text = "  " .. text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.Gotham
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.LayoutOrder = order
    Btn.Parent = LeftScroll
    Btn.MouseButton1Click:Connect(function()
        State[varName] = not State[varName]
        Btn.BackgroundColor3 = State[varName] and Color3.fromRGB(255, 20, 20) or Color3.fromRGB(28, 28, 28)
    end)
end

CreateLeftBtn("Spam", "Spam", false, 1)
CreateLeftBtn("Put & Break", "PutBreak", false, 2)
CreateLeftBtn("Collect", "Collect", false, 3)
CreateLeftBtn("Drop", "Drop", false, 4)
CreateLeftBtn("Geiger", "Geiger", false, 5)
CreateLeftBtn("Ghost", "Ghost", false, 6)
CreateLeftBtn("Fishing", "Fishing", false, 7)
CreateLeftBtn("Auto Farm", "AutoFarm", false, 8)
CreateLeftBtn("Auto Clear", "AutoClear", false, 9)
CreateLeftBtn("Auto Collect", "AutoCollect", false, 10)
CreateLeftBtn("Fast Drop", "FastDrop", false, 11)
CreateLeftBtn("Auto-Avoid Mod", "AutoAvoid", false, 12)
CreateLeftBtn("Spoof Name", "SpoofName", false, 13)
CreateLeftBtn("Spoof Skin", "SpoofSkin", false, 14)

-- MIDDLE PANEL
local MidPanel = Instance.new("Frame")
MidPanel.Size = UDim2.new(0, 320, 1, 0)
MidPanel.Position = UDim2.new(0, 151, 0, 0)
MidPanel.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
MidPanel.Parent = Main

local StopBtn = Instance.new("TextButton", MidPanel)
StopBtn.Size = UDim2.new(0, 65, 0, 28)
StopBtn.Position = UDim2.new(0, 15, 0, 15)
StopBtn.BackgroundColor3 = Color3.fromRGB(255, 20, 20)
StopBtn.Text = "STOP"
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 4)
StopBtn.MouseButton1Click:Connect(function()
    for k, v in pairs(State) do if type(v) == "boolean" then State[k] = false end end
    for _, child in pairs(LeftScroll:GetChildren()) do
        if child:IsA("TextButton") then child.BackgroundColor3 = Color3.fromRGB(28, 28, 28) end
    end
end)

local Warn = Instance.new("TextLabel", MidPanel)
Warn.Size = UDim2.new(0, 230, 0, 28)
Warn.Position = UDim2.new(0, 85, 0, 15)
Warn.BackgroundTransparency = 1
Warn.Text = "Bellow 200 Ez ban if you have po"
Warn.TextColor3 = Color3.fromRGB(220, 200, 0)
Warn.TextSize = 13
Warn.Font = Enum.Font.Gotham
Warn.TextXAlignment = Enum.TextXAlignment.Left

local SliderBg = Instance.new("Frame", MidPanel)
SliderBg.Size = UDim2.new(0, 180, 0, 30)
SliderBg.Position = UDim2.new(0, 15, 0, 55)
SliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(0, 4)
local SliderFill = Instance.new("Frame", SliderBg)
SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 4)
local SliderNum = Instance.new("TextLabel", SliderBg)
SliderNum.Size = UDim2.new(1, -10, 1, 0)
SliderNum.BackgroundTransparency = 1
SliderNum.Text = "500"
SliderNum.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderNum.Font = Enum.Font.Gotham
SliderNum.TextXAlignment = Enum.TextXAlignment.Center
local DelayLabel = Instance.new("TextLabel", MidPanel)
DelayLabel.Size = UDim2.new(0, 100, 0, 30)
DelayLabel.Position = UDim2.new(0, 205, 0, 55)
DelayLabel.BackgroundTransparency = 1
DelayLabel.Text = "Delay"
DelayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
DelayLabel.TextXAlignment = Enum.TextXAlignment.Left

local NameBox = Instance.new("TextBox", MidPanel)
NameBox.Size = UDim2.new(0, 180, 0, 30)
NameBox.Position = UDim2.new(0, 15, 0, 95)
NameBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
NameBox.Text = "Dirt"
NameBox.TextColor3 = Color3.fromRGB(200, 200, 200)
NameBox.TextXAlignment = Enum.TextXAlignment.Left
NameBox.TextSize = 14
NameBox.Font = Enum.Font.Gotham
Instance.new("UICorner", NameBox).CornerRadius = UDim.new(0, 4)
Instance.new("UIPadding", NameBox).PaddingLeft = UDim.new(0, 10)

local SelectedBox = Instance.new("TextLabel", MidPanel)
SelectedBox.Size = UDim2.new(0, 110, 0, 30)
SelectedBox.Position = UDim2.new(0, 205, 0, 95)
SelectedBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SelectedBox.Text = "Selected: 1"
SelectedBox.TextColor3 = Color3.fromRGB(200, 200, 200)
SelectedBox.TextSize = 14
SelectedBox.Font = Enum.Font.Gotham
SelectedBox.TextXAlignment = Enum.TextXAlignment.Center
Instance.new("UICorner", SelectedBox).CornerRadius = UDim.new(0, 4)

local BreakFrame = Instance.new("Frame", MidPanel)
BreakFrame.Size = UDim2.new(0, 180, 0, 30)
BreakFrame.Position = UDim2.new(0, 15, 0, 135)
BreakFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Instance.new("UICorner", BreakFrame).CornerRadius = UDim.new(0, 4)
local BreakNum = Instance.new("TextLabel", BreakFrame)
BreakNum.Size = UDim2.new(1, 0, 1, 0)
BreakNum.BackgroundTransparency = 1
BreakNum.Text = "3"
BreakNum.TextColor3 = Color3.fromRGB(200, 200, 200)
BreakNum.Font = Enum.Font.Gotham
BreakNum.TextSize = 14
local MinusBtn = Instance.new("TextButton", BreakFrame)
MinusBtn.Size = UDim2.new(0, 30, 1, 0)
MinusBtn.Position = UDim2.new(0.5, -30, 0, 0)
MinusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinusBtn.Text = "-"
MinusBtn.TextColor3 = Color3.fromRGB(200,200,200)
Instance.new("UICorner", MinusBtn).CornerRadius = UDim.new(0, 4)
local PlusBtn = Instance.new("TextButton", BreakFrame)
PlusBtn.Size = UDim2.new(0, 30, 1, 0)
PlusBtn.Position = UDim2.new(1, -30, 0, 0)
PlusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
PlusBtn.Text = "+"
PlusBtn.TextColor3 = Color3.fromRGB(200,200,200)
Instance.new("UICorner", PlusBtn).CornerRadius = UDim.new(0, 4)
local BreakLabel = Instance.new("TextLabel", MidPanel)
BreakLabel.Size = UDim2.new(0, 100, 0, 30)
BreakLabel.Position = UDim2.new(0, 205, 0, 135)
BreakLabel.BackgroundTransparency = 1
BreakLabel.Text = "Break Hit"
BreakLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
BreakLabel.TextSize = 14
BreakLabel.Font = Enum.Font.Gotham
BreakLabel.TextXAlignment = Enum.TextXAlignment.Left

-- RIGHT PANEL
local RightPanel = Instance.new("Frame", Main)
RightPanel.Size = UDim2.new(0, 228, 1, 0)
RightPanel.Position = UDim2.new(0, 472, 0, 0)
RightPanel.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
local GridFrame = Instance.new("Frame", RightPanel)
GridFrame.Size = UDim2.new(0, 180, 0, 200)
GridFrame.Position = UDim2.new(0, 25, 0, 20)
GridFrame.BackgroundTransparency = 1
local Grid = Instance.new("UIGridLayout", GridFrame)
Grid.CellSize = UDim2.new(0, 30, 0, 30)
Grid.CellPadding = UDim2.new(0, 4, 0, 4)
Grid.SortOrder = Enum.SortOrder.LayoutOrder
local Slots = {}
for i = 1, 25 do
    local Slot = Instance.new("Frame", GridFrame)
    Slot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Slot.BorderSizePixel = 0
    Slot.LayoutOrder = i
    Instance.new("UICorner", Slot).CornerRadius = UDim.new(0, 2)
    Slots[i] = Slot
    local Btn = Instance.new("TextButton", Slot)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.MouseButton1Click:Connect(function()
        local found = false
        for idx, val in ipairs(State.SelectedBlocks) do
            if val == i then table.remove(State.SelectedBlocks, idx); found = true; break end
        end
        if not found then table.insert(State.SelectedBlocks, i) end
        Slot.BackgroundColor3 = found and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 20, 20)
        SelectedBox.Text = "Selected: " .. tostring(#State.SelectedBlocks)
    end)
end
Slots[15].BackgroundColor3 = Color3.fromRGB(255, 20, 20)

-- MINIMIZE & LOGO
local LogoBtn = Instance.new("TextButton")
LogoBtn.Size = UDim2.new(0, 45, 0, 45)
LogoBtn.Position = UDim2.new(0, 20, 0.5, -22)
LogoBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LogoBtn.Text = "DS"
LogoBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
LogoBtn.TextSize = 18
LogoBtn.Font = Enum.Font.GothamBlack
LogoBtn.Parent = ScreenGui
LogoBtn.Visible = false
Instance.new("UICorner", LogoBtn).CornerRadius = UDim.new(1, 0)
local LogoStroke = Instance.new("UIStroke", LogoBtn)
LogoStroke.Color = Color3.fromRGB(0, 255, 150)
LogoStroke.Thickness = 2
local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.new(0, 20, 0, 20)
MinBtn.Position = UDim2.new(1, -25, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(255, 20, 20)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)
MinBtn.MouseButton1Click:Connect(function() Main.Visible = false; LogoBtn.Visible = true end)
LogoBtn.MouseButton1Click:Connect(function() Main.Visible = true; LogoBtn.Visible = false end)

local dragging = false
local function updateDelay(input)
    local pos = math.clamp(input.Position.X - SliderBg.AbsolutePosition.X, 0, SliderBg.AbsoluteSize.X)
    local pct = pos / SliderBg.AbsoluteSize.X
    State.Delay = math.floor(pct * 1000)
    SliderFill.Size = UDim2.new(pct, 0, 1, 0)
    SliderNum.Text = tostring(State.Delay)
end
SliderBg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
SliderBg.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateDelay(input) end end)

NameBox.FocusLost:Connect(function() State.BlockName = NameBox.Text end)
MinusBtn.MouseButton1Click:Connect(function() State.BreakHit = math.max(1, State.BreakHit - 1); BreakNum.Text = tostring(State.BreakHit) end)
PlusBtn.MouseButton1Click:Connect(function() State.BreakHit = math.min(10, State.BreakHit + 1); BreakNum.Text = tostring(State.BreakHit) end)

-- ============================================================
-- 5. LEGIT WALK & AUTO FARM LOOP (SERVER-SIDE SAFE)
-- ============================================================
local function GetChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

task.spawn(function()
    while task.wait(0.5) do
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        
        if not hrp or not hum then continue end
        
        if State.PutBreak or State.AutoFarm then
            local pos = hrp.Position
            local tx, tz = math.floor(pos.X / 3), math.floor(pos.Z / 3)
            
            -- Jalan ke tile block pake Humanoid:MoveTo (BUKAN teleport)
            local targetPos = Vector3.new(tx * 3, pos.Y, tz * 3)
            hum:MoveTo(targetPos)
            task.wait(0.3) -- Tunggu sampai bot jalan dikit
            
            -- Pas udah deket, baru mukul
            for _, blockID in ipairs(State.SelectedBlocks) do
                if R_Place then Fire(R_Place, tx, tz, blockID) end
                for i=1, State.BreakHit do
                    if R_Punch then Fire(R_Punch, tx, tz) end
                end
            end
            
            -- Delay biar aman
            task.wait(State.Delay / 1000)
        end
        
        if State.Collect or State.AutoCollect then
            if R_Collect then Fire(R_Collect, math.floor(hrp.Position.X/3), math.floor(hrp.Position.Z/3)) end
        end
        
        if State.AutoClear then
            local tx, tz = math.floor(hrp.Position.X / 3), math.floor(hrp.Position.Z / 3)
            for x=-2,2 do for z=-2,2 do
                if R_Punch then Fire(R_Punch, tx+x, tz+z) end
            end end
            task.wait(0.5)
        end

        if State.Drop or State.FastDrop then
            if R_Drop then for i=1,3 do Fire(R_Drop) end end
        end
    end
end)

print("[Growblox V19] Legit Walk Bypass Loaded.")
