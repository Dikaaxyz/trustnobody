--[[
    Growblox God Mode v10 | Floating Toggle Edition
    Target: Growblox (Roblox) / Xeno Executor
    Features: All Bypasses + All V7/V9 Features + Clean UI + Floating Logo
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
    Spam = false, PutBreak = false, Collect = false, Drop = false,
    Geiger = false, Ghost = false, Fishing = false,
    AutoAvoid = true, AutoFarm = false, AutoClear = false,
    AutoCollect = false, FastDrop = false, SpoofName = false, SpoofSkin = false,
    Delay = 339, BlockName = "Dirt", BlockID = 2, BreakHit = 3,
    TileSize = 3, CollectRadius = 25, CustomName = "GrowbloxGod", SafeWorld = "STORAGE_WORLD",
}

-- ============================================================
-- 3. REMOTES
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
-- 4. QUEUE & BYPASS LOGIC
-- ============================================================
local TaskQueue, isProcessing = {}, false
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

local function IsStaff(player)
    local name, dName = player.Name:lower(), player.DisplayName:lower()
    if name:find("admin") or name:find("mod") or name:find("staff") then return true end
    if dName:find("admin") or dName:find("mod") or dName:find("staff") then return true end
    return false
end

local function RunAway()
    if R_Leave then QueueRemote(R_Leave) end
    if R_Warp then QueueRemote(R_Warp, State.SafeWorld) end
end

-- ============================================================
-- 5. GUI CREATION
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GrowbloxV10"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- MAIN FRAME
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 700, 0, 380)
Main.Position = UDim2.new(0.5, -350, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(50, 50, 50)
Stroke.Thickness = 2

-- LEFT PANEL
local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0, 170, 1, 0)
LeftPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LeftPanel.Parent = Main
Instance.new("UIListLayout", LeftPanel).Padding = UDim.new(0, 0)

local function CreateLeftBtn(text, varName, defaultState, order)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 30)
    Btn.BackgroundColor3 = defaultState and Color3.fromRGB(255, 20, 20) or Color3.fromRGB(25, 25, 25)
    Btn.Text = "  " .. text
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.TextSize = 14
    Btn.Font = Enum.Font.Gotham
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.LayoutOrder = order
    Btn.Parent = LeftPanel
    
    Btn.MouseButton1Click:Connect(function()
        State[varName] = not State[varName]
        Btn.BackgroundColor3 = State[varName] and Color3.fromRGB(255, 20, 20) or Color3.fromRGB(25, 25, 25)
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
CreateLeftBtn("Auto Clear World", "AutoClear", false, 9)
CreateLeftBtn("Auto Collect", "AutoCollect", false, 10)
CreateLeftBtn("Fast Drop", "FastDrop", false, 11)
CreateLeftBtn("Auto-Avoid Mod", "AutoAvoid", true, 12)
CreateLeftBtn("Spoof Name", "SpoofName", false, 13)
CreateLeftBtn("Spoof Skin", "SpoofSkin", false, 14)

-- MIDDLE PANEL
local MidPanel = Instance.new("Frame")
MidPanel.Size = UDim2.new(0, 320, 1, 0)
MidPanel.Position = UDim2.new(0, 170, 0, 0)
MidPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MidPanel.Parent = Main

local Sep1 = Instance.new("Frame", MidPanel)
Sep1.Size = UDim2.new(0, 1, 1, 0)
Sep1.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local StopBtn = Instance.new("TextButton", MidPanel)
StopBtn.Size = UDim2.new(0, 60, 0, 30)
StopBtn.Position = UDim2.new(0, 15, 0, 15)
StopBtn.BackgroundColor3 = Color3.fromRGB(255, 20, 20)
StopBtn.Text = "STOP"
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 4)
StopBtn.MouseButton1Click:Connect(function()
    for k, v in pairs(State) do if type(v) == "boolean" then State[k] = false end end
    TaskQueue = {}
    for _, child in pairs(LeftPanel:GetChildren()) do
        if child:IsA("TextButton") then child.BackgroundColor3 = Color3.fromRGB(25, 25, 25) end
    end
end)

local Warn = Instance.new("TextLabel", MidPanel)
Warn.Size = UDim2.new(0, 230, 0, 30)
Warn.Position = UDim2.new(0, 85, 0, 15)
Warn.BackgroundTransparency = 1
Warn.Text = "Bellow 200 Ez ban if you have po"
Warn.TextColor3 = Color3.fromRGB(220, 180, 0)
Warn.TextSize = 13
Warn.Font = Enum.Font.Gotham
Warn.TextXAlignment = Enum.TextXAlignment.Left

local SliderBg = Instance.new("Frame", MidPanel)
SliderBg.Size = UDim2.new(0, 180, 0, 30)
SliderBg.Position = UDim2.new(0, 15, 0, 55)
SliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(0, 4)

local SliderFill = Instance.new("Frame", SliderBg)
SliderFill.Size = UDim2.new(0.6, 0, 1, 0) 
SliderFill.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 4)

local SliderNum = Instance.new("TextLabel", SliderBg)
SliderNum.Size = UDim2.new(1, 0, 1, 0)
SliderNum.BackgroundTransparency = 1
SliderNum.Text = "339"
SliderNum.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderNum.Font = Enum.Font.Gotham

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
NameBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
NameBox.Text = "Dirt"
NameBox.TextColor3 = Color3.fromRGB(200, 200, 200)
NameBox.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", NameBox).CornerRadius = UDim.new(0, 4)
Instance.new("UIPadding", NameBox).PaddingLeft = UDim.new(0, 10)

local IDBox = Instance.new("TextBox", MidPanel)
IDBox.Size = UDim2.new(0, 110, 0, 30)
IDBox.Position = UDim2.new(0, 205, 0, 95)
IDBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
IDBox.Text = ""
Instance.new("UICorner", IDBox).CornerRadius = UDim.new(0, 4)

local BreakFrame = Instance.new("Frame", MidPanel)
BreakFrame.Size = UDim2.new(0, 180, 0, 30)
BreakFrame.Position = UDim2.new(0, 15, 0, 135)
BreakFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Instance.new("UICorner", BreakFrame).CornerRadius = UDim.new(0, 4)

local BreakNum = Instance.new("TextLabel", BreakFrame)
BreakNum.Size = UDim2.new(1, 0, 1, 0)
BreakNum.BackgroundTransparency = 1
BreakNum.Text = "3"
BreakNum.TextColor3 = Color3.fromRGB(200, 200, 200)

local MinusBtn = Instance.new("TextButton", BreakFrame)
MinusBtn.Size = UDim2.new(0, 30, 1, 0)
MinusBtn.Position = UDim2.new(0.5, -30, 0, 0)
MinusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinusBtn.Text = "-"
Instance.new("UICorner", MinusBtn).CornerRadius = UDim.new(0, 4)

local PlusBtn = Instance.new("TextButton", BreakFrame)
PlusBtn.Size = UDim2.new(0, 30, 1, 0)
PlusBtn.Position = UDim2.new(1, -30, 0, 0)
PlusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
PlusBtn.Text = "+"
Instance.new("UICorner", PlusBtn).CornerRadius = UDim.new(0, 4)

local BreakLabel = Instance.new("TextLabel", MidPanel)
BreakLabel.Size = UDim2.new(0, 100, 0, 30)
BreakLabel.Position = UDim2.new(0, 205, 0, 135)
BreakLabel.BackgroundTransparency = 1
BreakLabel.Text = "Break Hit"
BreakLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
BreakLabel.TextXAlignment = Enum.TextXAlignment.Left

local HotkeyFrame = Instance.new("Frame", MidPanel)
HotkeyFrame.Size = UDim2.new(0, 180, 0, 15)
HotkeyFrame.Position = UDim2.new(0, 25, 0, 165)
HotkeyFrame.BackgroundTransparency = 1
local hkX = 0
for _, key in ipairs({"Q", "1", "2", "3"}) do
    local txt = Instance.new("TextLabel", HotkeyFrame)
    txt.Size = UDim2.new(0, 20, 1, 0)
    txt.Position = UDim2.new(0, hkX, 0, 0)
    txt.BackgroundTransparency = 1
    txt.Text = key
    txt.TextColor3 = Color3.fromRGB(150, 150, 150)
    txt.TextSize = 12
    hkX = hkX + 45
end

-- RIGHT PANEL
local RightPanel = Instance.new("Frame", Main)
RightPanel.Size = UDim2.new(0, 210, 1, 0)
RightPanel.Position = UDim2.new(0, 490, 0, 0)
RightPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
local Sep2 = Instance.new("Frame", RightPanel)
Sep2.Size = UDim2.new(0, 1, 1, 0)
Sep2.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local GridFrame = Instance.new("Frame", RightPanel)
GridFrame.Size = UDim2.new(0, 160, 0, 200)
GridFrame.Position = UDim2.new(0, 25, 0, 20)
GridFrame.BackgroundTransparency = 1

local Grid = Instance.new("UIGridLayout", GridFrame)
Grid.CellSize = UDim2.new(0, 28, 0, 28)
Grid.CellPadding = UDim2.new(0, 4, 0, 4)

for i = 1, 25 do
    local Slot = Instance.new("Frame", GridFrame)
    Slot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Slot.BorderSizePixel = 0
    Slot.LayoutOrder = i
    Instance.new("UICorner", Slot).CornerRadius = UDim.new(0, 2)
    
    if i == 13 then Slot.BackgroundColor3 = Color3.fromRGB(255, 20, 20) end
    
    local Btn = Instance.new("TextButton", Slot)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    
    Btn.MouseButton1Click:Connect(function()
        State.BlockID = i
        IDBox.Text = tostring(i)
        for _, child in pairs(GridFrame:GetChildren()) do
            if child:IsA("Frame") then child.BackgroundColor3 = Color3.fromRGB(255, 255, 255) end
        end
        Slot.BackgroundColor3 = Color3.fromRGB(255, 20, 20)
    end)
end

-- ============================================================
-- 6. FLOATING LOGO (MINIMIZE/MAXIMIZE)
-- ============================================================
local LogoBtn = Instance.new("TextButton")
LogoBtn.Name = "FloatingLogo"
LogoBtn.Size = UDim2.new(0, 45, 0, 45)
LogoBtn.Position = UDim2.new(0, 20, 0.5, -22) -- Posisi awal di kiri tengah
LogoBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LogoBtn.Text = "DS" -- Inisial DeepShit
LogoBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
LogoBtn.TextSize = 18
LogoBtn.Font = Enum.Font.GothamBlack
LogoBtn.Parent = ScreenGui
Instance.new("UICorner", LogoBtn).CornerRadius = UDim.new(1, 0)
local LogoStroke = Instance.new("UIStroke", LogoBtn)
LogoStroke.Color = Color3.fromRGB(0, 255, 150)
LogoStroke.Thickness = 2

-- Logic Klik Toggle
LogoBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    if Main.Visible then
        -- Kalau munculin, warnain Logo hijau
        LogoBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        LogoStroke.Color = Color3.fromRGB(0, 255, 150)
    else
        -- Kalau minimize, warnain Logo abu-abu gelap
        LogoBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        LogoStroke.Color = Color3.fromRGB(50, 50, 50)
    end
end)

-- Logic Drag Logo
local draggingLogo = false
local logoStartPos, logoStartMouse = nil, nil

LogoBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingLogo = true
        logoStartMouse = input.Position
        logoStartPos = LogoBtn.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingLogo and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - logoStartMouse
        LogoBtn.Position = UDim2.new(
            logoStartPos.X.Scale, logoStartPos.X.Offset + delta.X,
            logoStartPos.Y.Scale, logoStartPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingLogo = false
    end
end)

-- ============================================================
-- 7. UI LOGIC (SLIDER & BOXES)
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
MinusBtn.MouseButton1Click:Connect(function() State.BreakHit = math.max(1, State.BreakHit - 1); BreakNum.Text = tostring(State.BreakHit) end)
PlusBtn.MouseButton1Click:Connect(function() State.BreakHit = math.min(10, State.BreakHit + 1); BreakNum.Text = tostring(State.BreakHit) end)

-- ============================================================
-- 8. MAIN LOOP
-- ============================================================
local function GetPos()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    return hrp and hrp.Position or Vector3.new(0,0,0)
end

task.spawn(function()
    while task.wait(0.2) do
        if State.PutBreak or State.AutoFarm then
            local pos = GetPos()
            local tx, tz = math.floor(pos.X/State.TileSize), math.floor(pos.Z/State.TileSize)
            if R_Place then QueueRemote(R_Place, tx, tz, State.BlockID) end
            task.wait(State.Delay / 1000)
            for i=1, State.BreakHit do
                if R_Punch then QueueRemote(R_Punch, tx, tz) end
                task.wait(0.05)
            end
        end
        
        if State.Collect or State.AutoCollect then
            if R_Collect then QueueRemote(R_Collect, math.floor(GetPos().X/3), math.floor(GetPos().Z/3)) end
        end
        
        if State.AutoClear then
            local pos = GetPos()
            local tx, tz = math.floor(pos.X/State.TileSize), math.floor(pos.Z/State.TileSize)
            for x=-2,2 do for z=-2,2 do
                if R_Punch then QueueRemote(R_Punch, tx+x, tz+z) end
            end end
        end

        if State.Drop or State.FastDrop then
            if R_Drop then for i=1,3 do QueueRemote(R_Drop) end end
        end
        
        if State.AutoAvoid then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and IsStaff(p) then RunAway(); break end
            end
        end
    end
end)

print("[Growblox V10] Floating Logo Loaded. Bypass: " .. tostring(bypass_success))
