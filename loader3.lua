--[[
    Growblox Ultimate Proxy Edition v5 (Fixed)
    Target: Growblox (Roblox) / Xeno Executor
    Fitur: Auto Farm, Auto Clear, Auto Collect, Bypass, Spoof, Warp, Auto-Avoid.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- 1. STATE CONFIGURATION
-- ============================================================
local State = {
    AutoFarm = false,
    AutoClear = false,
    AutoCollect = false,
    FastDrop = false,
    Ghost = false,
    Spam = false,
    SpoofName = false,
    SpoofSkin = false,
    AutoAvoid = true,
    Delay = 150,
    BlockID = 2,
    BreakHit = 3,
    CustomName = "GrowbloxGod",
    SafeWorld = "YOUR_STORAGE_WORLD",
    CollectRadius = 30,
    TileSize = 3, -- Sesuaikan sama grid game
}

-- ============================================================
-- 2. REMOTES RESOLVER
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
local R_Warp = R("warp") or R("join") or R("world") or R("travel")
local R_Drop = R("drop") or R("trash")
local R_Collect = R("collect") or R("pickup") or R("grab")
local R_Leave = R("leave") or R("exit")

-- ============================================================
-- 3. CORE FUNCTIONS (Dideklarasi sebelum dipakai)
-- ============================================================
local function SpoofName()
    LocalPlayer.DisplayName = State.CustomName
    local char = LocalPlayer.Character
    if char then
        local head = char:FindFirstChild("Head")
        if head then
            local oldTag = head:FindFirstChild("SpoofedTag")
            if oldTag then oldTag:Destroy() end
            
            local billboard = Instance.new("BillboardGui", head)
            billboard.Name = "SpoofedTag"
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 2.5, 0)
            billboard.AlwaysOnTop = true
            
            local text = Instance.new("TextLabel", billboard)
            text.Size = UDim2.new(1, 0, 1, 0)
            text.BackgroundTransparency = 1
            text.Text = State.CustomName
            text.TextColor3 = Color3.fromRGB(255, 100, 100)
            text.TextStrokeTransparency = 0
            text.TextSize = 14
            text.Font = Enum.Font.GothamBold
        end
    end
end

local function SpoofSkin()
    local char = LocalPlayer.Character
    if char then
        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        if torso and not torso:FindFirstChild("SpoofHighlight") then
            local highlight = Instance.new("Highlight", torso)
            highlight.Name = "SpoofHighlight"
            highlight.FillColor = Color3.fromRGB(0, 255, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
        end
    end
end

local function DoFastDrop()
    if R_Drop then
        for i = 1, 5 do -- Kurangi jadi 5 biar nggak kena rate limit
            pcall(function() R_Drop:FireServer() end)
        end
    end
end

local function DoWarp(worldName)
    if R_Warp then
        pcall(function() R_Warp:FireServer(worldName) end)
        print("[Growblox] Warping to: " .. tostring(worldName))
    else
        warn("[Growblox] Remote Warp tidak ditemukan.")
    end
end

local function IsTrash(name)
    local trashList = {"dirt", "cave", "rock", "stone", "background", "bedrock", "grass", "lava"}
    local pName = name:lower()
    for _, trash in ipairs(trashList) do
        if pName:find(trash) then return true end
    end
    return false
end

local function ClearWorldArea()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not R_Punch then return end
    
    local px, pz = math.floor(hrp.Position.X / State.TileSize), math.floor(hrp.Position.Z / State.TileSize)
    for x = -2, 2 do
        for z = -2, 2 do
            pcall(function() R_Punch:FireServer(px + x, pz + z) end)
        end
    end
end

local function AutoCollect()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not R_Collect then return end
    
    local playerPos = hrp.Position
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("gem") or obj.Name:lower():find("seed") or obj.Name:lower():find("item")) then
            if (obj.Position - playerPos).Magnitude <= State.CollectRadius then
                local ox, oz = math.floor(obj.Position.X / State.TileSize), math.floor(obj.Position.Z / State.TileSize)
                pcall(function() R_Collect:FireServer(ox, oz) end)
            end
        end
    end
end

local function IsStaff(player)
    local name = player.Name:lower()
    local dName = player.DisplayName:lower()
    if name:find("admin") or name:find("mod") or name:find("staff") or name:find("owner") then return true end
    if dName:find("admin") or dName:find("mod") or dName:find("staff") then return true end
    return false
end

local function RunAway()
    print("[Growblox] ADMIN DETECTED! Warping...")
    if R_Leave then pcall(function() R_Leave:FireServer() end) end
    DoWarp(State.SafeWorld)
end

-- ============================================================
-- 4. EVENTS & ANTI-DETECT
-- ============================================================
local bypass_success = pcall(function()
    local mt = getrawmetatable(game)
    local old_namecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" and self == LocalPlayer then return nil end
        if method == "FireServer" and (self.Name:lower():find("anticheat") or self.Name:lower():find("log")) then return nil end
        if method == "GetNetworkPing" then return 0.05 end
        return old_namecall(self, ...)
    end)
    setreadonly(mt, true)
end)

Players.PlayerAdded:Connect(function(p)
    if State.AutoAvoid and IsStaff(p) then
        task.wait(1)
        RunAway()
    end
end)

LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ============================================================
-- 5. GUI CREATION
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GrowbloxProxyV5"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 680, 0, 500)
Main.Position = UDim2.new(0.5, -340, 0.5, -250)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(0, 200, 255)
Stroke.Thickness = 2

local TitleBar = Instance.new("Frame", Main)
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size = UDim2.new(1, -10, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Growblox Proxy V5 | Fixed & Cleaned"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 14
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- Left Panel
local LeftPanel = Instance.new("Frame", Main)
LeftPanel.Size = UDim2.new(0, 170, 1, -45)
LeftPanel.Position = UDim2.new(0, 10, 0, 40)
LeftPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
LeftPanel.BorderSizePixel = 0
Instance.new("UICorner", LeftPanel).CornerRadius = UDim.new(0, 6)
Instance.new("UIListLayout", LeftPanel).Padding = UDim.new(0, 3)

local function createToggle(name, text, order)
    local Btn = Instance.new("TextButton", LeftPanel)
    Btn.Size = UDim2.new(1, 0, 0, 28)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.Gotham
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.LayoutOrder = order
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    Instance.new("UIPadding", Btn).PaddingLeft = UDim.new(0, 10)
    
    Btn.MouseButton1Click:Connect(function()
        State[name] = not State[name]
        Btn.BackgroundColor3 = State[name] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(35, 35, 40)
        Btn.TextColor3 = State[name] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        
        if name == "SpoofName" and State.SpoofName then SpoofName() end
        if name == "SpoofSkin" and State.SpoofSkin then SpoofSkin() end
    end)
end

createToggle("AutoAvoid", "Auto-Avoid Mod", 1)
createToggle("AutoFarm", "Auto Farm", 2)
createToggle("AutoClear", "Auto Clear World", 3)
createToggle("AutoCollect", "Auto Collect (No TP)", 4)
createToggle("FastDrop", "Fast Drop", 5)
createToggle("Ghost", "Ghost / Noclip", 6)
createToggle("Spam", "Spam", 7)
createToggle("SpoofName", "Spoof Name", 8)
createToggle("SpoofSkin", "Spoof Skin", 9)

-- Middle Panel
local MidPanel = Instance.new("Frame", Main)
MidPanel.Size = UDim2.new(0, 280, 1, -45)
MidPanel.Position = UDim2.new(0, 190, 0, 40)
MidPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MidPanel.BorderSizePixel = 0
Instance.new("UICorner", MidPanel).CornerRadius = UDim.new(0, 6)

-- Stop Button
local StopBtn = Instance.new("TextButton", MidPanel)
StopBtn.Size = UDim2.new(0, 70, 0, 25)
StopBtn.Position = UDim2.new(0, 10, 0, 10)
StopBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
StopBtn.Text = "STOP"
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.TextSize = 14
StopBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 4)

StopBtn.MouseButton1Click:Connect(function()
    for k, _ in pairs(State) do if type(State[k]) == "boolean" then State[k] = false end end
    for _, child in pairs(LeftPanel:GetChildren()) do
        if child:IsA("TextButton") then
            child.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            child.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
end)

-- Safe World Input
local SafeWorldFrame = Instance.new("Frame", MidPanel)
SafeWorldFrame.Size = UDim2.new(0, 260, 0, 30)
SafeWorldFrame.Position = UDim2.new(0, 10, 0, 45)
SafeWorldFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
Instance.new("UICorner", SafeWorldFrame).CornerRadius = UDim.new(0, 4)

local SafeWorldBox = Instance.new("TextBox", SafeWorldFrame)
SafeWorldBox.Size = UDim2.new(1, -10, 1, 0)
SafeWorldBox.Position = UDim2.new(0, 10, 0, 0)
SafeWorldBox.BackgroundTransparency = 1
SafeWorldBox.Text = "YOUR_STORAGE_WORLD"
SafeWorldBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SafeWorldBox.TextSize = 13
SafeWorldBox.Font = Enum.Font.Gotham
SafeWorldBox.TextXAlignment = Enum.TextXAlignment.Left
SafeWorldBox.FocusLost:Connect(function() State.SafeWorld = SafeWorldBox.Text end)

-- Delay Slider
local DelayFrame = Instance.new("Frame", MidPanel)
DelayFrame.Size = UDim2.new(0, 260, 0, 30)
DelayFrame.Position = UDim2.new(0, 10, 0, 85)
DelayFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
Instance.new("UICorner", DelayFrame).CornerRadius = UDim.new(0, 4)

local DelayFill = Instance.new("Frame", DelayFrame)
DelayFill.Size = UDim2.new(0.3, 0, 1, 0)
DelayFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
Instance.new("UICorner", DelayFill).CornerRadius = UDim.new(0, 4)

local DelayText = Instance.new("TextLabel", DelayFrame)
DelayText.Size = UDim2.new(1, 0, 1, 0)
DelayText.BackgroundTransparency = 1
DelayText.Text = "Delay: 150ms"
DelayText.TextColor3 = Color3.fromRGB(255, 255, 255)
DelayText.TextSize = 13
DelayText.Font = Enum.Font.Gotham

local dragging = false
local function updateDelay(input)
    local pos = math.clamp(input.Position.X - DelayFrame.AbsolutePosition.X, 0, DelayFrame.AbsoluteSize.X)
    local pct = pos / DelayFrame.AbsoluteSize.X
    State.Delay = math.floor(pct * 500)
    DelayFill.Size = UDim2.new(pct, 0, 1, 0)
    DelayText.Text = "Delay: " .. tostring(State.Delay) .. "ms"
end
DelayFrame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
DelayFrame.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateDelay(input) end end)

-- ============================================================
-- 6. MAIN LOOPS (Satu Loop Utama)
-- ============================================================
local function GetPos()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    return hrp and hrp.Position or Vector3.new(0,0,0)
end

task.spawn(function()
    while task.wait(0.1) do
        if State.AutoFarm then
            local pos = GetPos()
            local tx, tz = math.floor(pos.X/State.TileSize), math.floor(pos.Z/State.TileSize)
            if R_Place then pcall(function() R_Place:FireServer(tx, tz, State.BlockID) end) end
            task.wait(State.Delay / 1000)
            for i=1, State.BreakHit do
                if R_Punch then pcall(function() R_Punch:FireServer(tx, tz) end) end
                task.wait(0.01)
            end
        end
        
        if State.AutoClear then
            ClearWorldArea()
            task.wait(0.2)
        end
        
        if State.AutoCollect then
            AutoCollect()
            task.wait(0.2)
        end
        
        if State.FastDrop then
            DoFastDrop()
            task.wait(0.5)
        end
        
        if State.AutoAvoid then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and IsStaff(p) then
                    RunAway()
                    break
                end
            end
        end
    end
end)

RunService.Stepped:Connect(function()
    if State.Ghost then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if State.Spam then
            local chat = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if chat and chat:FindFirstChild("SayMessageRequest") then
                pcall(function() chat.SayMessageRequest:FireServer("Auto Farm on Top", "All") end)
            end
        end
    end
end)

print("[Growblox V5] Loaded. Bypass: " .. tostring(bypass_success))
