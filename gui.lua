--[[
    Growblox God Mode v24 | Full Tabbed UI + Logic
    Target: Growblox (Roblox) / Xeno Executor
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("GrowbloxV24")
if old then old:Destroy() end

-- ============================================================
-- 1. STATE
-- ============================================================
local State = {
    SelectedBlocks = {15},
    Spam = { Enabled = false },
    PutBreak = { Enabled = false, Delay = 500, Hit = 3 },
    Collect = { Enabled = false, Radius = 25 },
    Drop = { Enabled = false },
    Geiger = { Enabled = false },
    Ghost = { Enabled = false },
    Fishing = { Enabled = false },
    AutoFarm = { Enabled = false, Delay = 500, Hit = 3 },
    AutoClear = { Enabled = false },
    AutoCollect = { Enabled = false, Radius = 25 },
    FastDrop = { Enabled = false },
    AutoAvoid = { Enabled = true },
    SpoofName = { Enabled = false },
    SpoofSkin = { Enabled = false },
}

-- ============================================================
-- 2. REMOTES
-- ============================================================
local Remotes = {}
for _, v in pairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA("RemoteEvent") then Remotes[string.lower(v.Name)] = v end
end
local function R(k) for key, v in pairs(Remotes) do if string.find(key, k) then return v end end end
local R_Place = R("place") or R("build")
local R_Punch = R("punch") or R("break")
local R_Collect = R("collect") or R("pickup")
local R_Drop = R("drop")
local R_Leave = R("leave") or R("exit")
local R_Warp = R("warp") or R("join")

local function Fire(remote, ...)
    if remote then pcall(function() remote:FireServer(...) end) end
end

-- ============================================================
-- 3. GUI CREATION (CENTERED)
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GrowbloxV24"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 700, 0, 480)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0) -- Benerin posisi biar ke tengah
Main.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 4)

-- LEFT PANEL (TABS)
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

local LeftButtons = {}
local Tabs = {
    {Name = "Spam", Key = "Spam"},
    {Name = "Put & Break", Key = "PutBreak"},
    {Name = "Collect", Key = "Collect"},
    {Name = "Drop", Key = "Drop"},
    {Name = "Geiger", Key = "Geiger"},
    {Name = "Ghost", Key = "Ghost"},
    {Name = "Fishing", Key = "Fishing"},
    {Name = "Auto Farm", Key = "AutoFarm"},
    {Name = "Auto Clear", Key = "AutoClear"},
    {Name = "Auto Collect", Key = "AutoCollect"},
    {Name = "Fast Drop", Key = "FastDrop"},
    {Name = "Auto-Avoid Mod", Key = "AutoAvoid"},
    {Name = "Spoof Name", Key = "SpoofName"},
    {Name = "Spoof Skin", Key = "SpoofSkin"},
}

-- MIDDLE PANEL
local MidPanel = Instance.new("Frame")
MidPanel.Size = UDim2.new(0, 320, 1, 0)
MidPanel.Position = UDim2.new(0, 151, 0, 0)
MidPanel.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
MidPanel.Parent = Main

-- RIGHT PANEL (GRID)
local RightPanel = Instance.new("Frame")
RightPanel.Size = UDim2.new(0, 228, 1, 0)
RightPanel.Position = UDim2.new(0, 472, 0, 0)
RightPanel.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
RightPanel.Parent = Main

local GridFrame = Instance.new("Frame")
GridFrame.Size = UDim2.new(0, 180, 0, 200)
GridFrame.Position = UDim2.new(0, 25, 0, 20)
GridFrame.BackgroundTransparency = 1
GridFrame.Parent = RightPanel

local Grid = Instance.new("UIGridLayout")
Grid.CellSize = UDim2.new(0, 30, 0, 30)
Grid.CellPadding = UDim2.new(0, 4, 0, 4)
Grid.Parent = GridFrame

local Slots = {}
for i = 1, 25 do
    local Slot = Instance.new("Frame")
    Slot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Slot.BorderSizePixel = 0
    Slot.LayoutOrder = i
    Slot.Parent = GridFrame
    Instance.new("UICorner", Slot).CornerRadius = UDim.new(0, 2)
    Slots[i] = Slot
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.Parent = Slot
    Btn.MouseButton1Click:Connect(function()
        local found = false
        for idx, val in ipairs(State.SelectedBlocks) do
            if val == i then table.remove(State.SelectedBlocks, idx); found = true; break end
        end
        if not found then table.insert(State.SelectedBlocks, i) end
        Slot.BackgroundColor3 = found and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 20, 20)
    end)
end
Slots[15].BackgroundColor3 = Color3.fromRGB(255, 20, 20)

-- SEPARATORS
local Sep1 = Instance.new("Frame", Main)
Sep1.Size = UDim2.new(0, 1, 1, 0)
Sep1.Position = UDim2.new(0, 150, 0, 0)
Sep1.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
local Sep2 = Instance.new("Frame", Main)
Sep2.Size = UDim2.new(0, 1, 1, 0)
Sep2.Position = UDim2.new(0, 471, 0, 0)
Sep2.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

-- ============================================================
-- 4. TAB MANAGER & UI LOGIC
-- ============================================================
local function ClearMiddle()
    for _, child in ipairs(MidPanel:GetChildren()) do
        if not child:IsA("UIListLayout") then child:Destroy() end
    end
end

local function AddToggle(text, obj, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 180, 0, 30)
    btn.Position = UDim2.new(0, 15, 0, 55)
    btn.BackgroundColor3 = obj.Enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 30, 30)
    btn.Text = text .. ": " .. (obj.Enabled and "ON" or "OFF")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        obj.Enabled = not obj.Enabled
        btn.BackgroundColor3 = obj.Enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 30, 30)
        btn.Text = text .. ": " .. (obj.Enabled and "ON" or "OFF")
    end)
end

local function AddSlider(labelText, obj, key, min, max, yPos, parent)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 200, 0, 20)
    lbl.Position = UDim2.new(0, 15, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText .. ": " .. tostring(obj[key])
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.Parent = parent
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 200, 0, 20)
    bar.Position = UDim2.new(0, 15, 0, yPos + 20)
    bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    bar.Parent = parent
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((obj[key]-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)
    
    local dragging = false
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    bar.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local pct = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + pct * (max-min))
            obj[key] = val
            fill.Size = UDim2.new(pct, 0, 1, 0)
            lbl.Text = labelText .. ": " .. tostring(val)
        end
    end)
end

local currentTab = nil
local function SwitchTab(tabKey)
    if currentTab == tabKey then return end
    currentTab = tabKey
    
    for key, btn in pairs(LeftButtons) do
        if key == tabKey then
            btn.BackgroundColor3 = Color3.fromRGB(255, 20, 20)
            btn.TextColor3 = Color3.fromRGB(255,255,255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            btn.TextColor3 = Color3.fromRGB(200,200,200)
        end
    end
    
    ClearMiddle()
    
    -- STOP Button
    local StopBtn = Instance.new("TextButton")
    StopBtn.Size = UDim2.new(0, 65, 0, 28)
    StopBtn.Position = UDim2.new(0, 15, 0, 15)
    StopBtn.BackgroundColor3 = Color3.fromRGB(255, 20, 20)
    StopBtn.Text = "STOP"
    StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    StopBtn.Font = Enum.Font.GothamBold
    StopBtn.TextSize = 13
    StopBtn.Parent = MidPanel
    Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 4)
    StopBtn.MouseButton1Click:Connect(function()
        for k, v in pairs(State) do if type(v) == "table" and v.Enabled ~= nil then v.Enabled = false end end
        SwitchTab(currentTab) -- Refresh UI
    end)
    
    -- Warning Text
    local Warn = Instance.new("TextLabel")
    Warn.Size = UDim2.new(0, 230, 0, 28)
    Warn.Position = UDim2.new(0, 85, 0, 15)
    Warn.BackgroundTransparency = 1
    Warn.Text = "Bellow 200 Ez ban if you have po"
    Warn.TextColor3 = Color3.fromRGB(220, 200, 0)
    Warn.TextSize = 13
    Warn.Font = Enum.Font.Gotham
    Warn.TextXAlignment = Enum.TextXAlignment.Left
    Warn.Parent = MidPanel
    
    local obj = State[tabKey]
    if not obj then return end
    
    if tabKey == "PutBreak" then
        AddToggle("Put & Break", obj, MidPanel)
        AddSlider("Delay (ms)", obj, "Delay", 100, 1000, 100, MidPanel)
        AddSlider("Break Hit", obj, "Hit", 1, 10, 160, MidPanel)
    elseif tabKey == "AutoFarm" then
        AddToggle("Auto Farm", obj, MidPanel)
        AddSlider("Delay (ms)", obj, "Delay", 100, 1000, 100, MidPanel)
        AddSlider("Break Hit", obj, "Hit", 1, 10, 160, MidPanel)
    elseif tabKey == "Collect" or tabKey == "AutoCollect" then
        AddToggle(tabKey, obj, MidPanel)
        AddSlider("Radius", obj, "Radius", 5, 100, 100, MidPanel)
    else
        AddToggle(tabKey, obj, MidPanel)
    end
end

-- Build Left Buttons
for i, tab in ipairs(Tabs) do
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    Btn.Text = "  " .. tab.Name
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.Gotham
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.LayoutOrder = i
    Btn.Parent = LeftScroll
    Btn.MouseButton1Click:Connect(function() SwitchTab(tab.Key) end)
    LeftButtons[tab.Key] = Btn
end

SwitchTab("PutBreak") -- Start di tab Put & Break

-- ============================================================
-- 5. LOGIC LOOP
-- ============================================================
task.spawn(function()
    while task.wait(0.2) do
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        
        if not hrp or not hum then continue end
        
        if State.PutBreak.Enabled or State.AutoFarm.Enabled then
            local pos = hrp.Position
            local tx, tz = math.floor(pos.X / 3), math.floor(pos.Z / 3)
            local targetPos = Vector3.new(tx * 3, pos.Y, tz * 3)
            
            hum:MoveTo(targetPos)
            task.wait(0.3)
            
            for _, blockID in ipairs(State.SelectedBlocks) do
                if R_Place then Fire(R_Place, tx, tz, blockID) end
                local hits = State.PutBreak.Enabled and State.PutBreak.Hit or State.AutoFarm.Hit
                for i=1, hits do
                    if R_Punch then Fire(R_Punch, tx, tz) end
                end
            end
            
            local delay = State.PutBreak.Enabled and State.PutBreak.Delay or State.AutoFarm.Delay
            task.wait(delay / 1000)
        end
        
        if State.Collect.Enabled or State.AutoCollect.Enabled then
            if R_Collect then Fire(R_Collect, math.floor(hrp.Position.X/3), math.floor(hrp.Position.Z/3)) end
        end
        
        if State.AutoClear.Enabled then
            local tx, tz = math.floor(hrp.Position.X / 3), math.floor(hrp.Position.Z / 3)
            for x=-2,2 do for z=-2,2 do
                if R_Punch then Fire(R_Punch, tx+x, tz+z) end
            end end
        end

        if State.Drop.Enabled or State.FastDrop.Enabled then
            if R_Drop then for i=1,3 do Fire(R_Drop) end end
        end
        
        if State.Ghost.Enabled then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
            end
        end
        
        if State.AutoAvoid.Enabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    local name = p.Name:lower()
                    if name:find("admin") or name:find("mod") or name:find("staff") then
                        if R_Leave then Fire(R_Leave) end
                        if R_Warp then Fire(R_Warp, "STORAGE_WORLD") end
                        break
                    end
                end
            end
        end
    end
end)

print("[Growblox V24] Tabbed UI + Legit Logic Loaded.")
