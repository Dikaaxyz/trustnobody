-- Growblox 67 — Zero-Fail UI (gethui + CoreGui + PlayerGui Bypass)
-- This will show up. If it doesn't, the executor is sandboxing UI creation entirely.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

print("[Growblox67] Building UI...")

--[[ 1. UI PARENT HUNTER ]]
local function getUIParent()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    if game:GetService("CoreGui") then
        return game:GetService("CoreGui")
    end
    return LP:WaitForChild("PlayerGui")
end

local parent = getUIParent()
print("[Growblox67] UI Parent: " .. tostring(parent))

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GrowbloxNative"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success = pcall(function()
    ScreenGui.Parent = parent
end)

if not success then
    warn("[Growblox67] Failed to parent to CoreGui. Trying PlayerGui...")
    pcall(function() ScreenGui.Parent = LP.PlayerGui end)
end

--[[ 2. MAIN FRAME ]]
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 550)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.Text = "🟢 Growblox 67 | Native GUI"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- [[ 3. TABS ]] --
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 35)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabBar.Parent = MainFrame

local Scrolling = Instance.new("ScrollingFrame")
Scrolling.Size = UDim2.new(1, -20, 1, -90)
Scrolling.Position = UDim2.new(0, 10, 0, 85)
Scrolling.BackgroundTransparency = 1
Scrolling.ScrollBarThickness = 4
Scrolling.CanvasSize = UDim2.new(0, 0, 0, 1200)
Scrolling.Parent = MainFrame

local List = Instance.new("UIListLayout")
List.Padding = UDim.new(0, 8)
List.Parent = Scrolling

-- [[ 4. FLAGS ]] --
local F = setmetatable({}, {__index = function() return false end})
local Fset = function(k, v) F[k] = v end

-- [[ 5. DYNAMIC BUTTONS ]] --
local function SwitchTab(tabName)
    for _, child in ipairs(Scrolling:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("Frame") then child:Destroy() end
    end
    
    local function AddToggle(name, flag)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 35)
        Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        Btn.Text = "  " .. name .. " [OFF]"
        Btn.TextColor3 = Color3.new(1, 1, 1)
        Btn.TextXAlignment = Enum.TextXAlignment.Left
        Btn.Font = Enum.Font.Gotham
        Btn.Parent = Scrolling
        local Cnr = Instance.new("UICorner"); Cnr.CornerRadius = UDim.new(0, 4); Cnr.Parent = Btn
        
        local state = F[flag] or false
        Btn.Text = "  " .. name .. (state and " [ON]" or " [OFF]")
        Btn.BackgroundColor3 = state and Color3.fromRGB(0, 120, 60) or Color3.fromRGB(45, 45, 45)

        Btn.MouseButton1Click:Connect(function()
            state = not state
            Fset(flag, state)
            Btn.Text = "  " .. name .. (state and " [ON]" or " [OFF]")
            Btn.BackgroundColor3 = state and Color3.fromRGB(0, 120, 60) or Color3.fromRGB(45, 45, 45)
            print("[Growblox67] Toggle: " .. name .. " -> " .. tostring(state))
        end)
    end

    if tabName == "Farming" then
        AddToggle("Auto Farm Loop", "AutoFarmLoop")
        AddToggle("Auto Collect", "AutoCollect")
        AddToggle("Auto Clean Dirt", "AutoCleanDirt")
        AddToggle("Auto Clean Cave", "AutoCleanCave")
    elseif tabName == "Movement" then
        AddToggle("Fly", "Fly")
        AddToggle("NoClip", "NoClip")
        AddToggle("Anti-Void", "AntiVoid")
        AddToggle("Anti-Fall", "AntiFall")
    elseif tabName == "Visuals" then
        AddToggle("Item ESP", "ItemESP")
        AddToggle("Dirt ESP", "DirtESP")
        AddToggle("Cave ESP", "CaveESP")
        AddToggle("Fullbright", "Fullbright")
    elseif tabName == "Combat" then
        AddToggle("Kill Aura", "KillAura")
    end
end

local tabs = {"Farming", "Movement", "Visuals", "Combat"}
local tabBtns = {}
for i, name in ipairs(tabs) do
    local TBtn = Instance.new("TextButton")
    TBtn.Size = UDim2.new(0.25, -2, 1, 0)
    TBtn.Position = UDim2.new((i-1) * 0.25, 2, 0, 0)
    TBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    TBtn.Text = name
    TBtn.TextColor3 = Color3.new(1, 1, 1)
    TBtn.Font = Enum.Font.GothamBold
    TBtn.TextSize = 12
    TBtn.Parent = TabBar
    
    local TCnr = Instance.new("UICorner"); TCnr.CornerRadius = UDim.new(0, 4); TCnr.Parent = TBtn
    
    TBtn.MouseButton1Click:Connect(function()
        for _, b in ipairs(TabBar:GetChildren()) do
            if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(45, 45, 45) end
        end
        TBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 60)
        SwitchTab(name)
    end)
    table.insert(tabBtns, TBtn)
end

SwitchTab("Farming")
tabBtns[1].BackgroundColor3 = Color3.fromRGB(0, 120, 60)

-- [[ 6. TOGGLE GUI ]]
local isVisible = true
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        isVisible = not isVisible
        MainFrame.Visible = isVisible
    end
end)

print("[Growblox67] Native UI Built. Check your screen. Press RightShift to toggle.")
