local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local oldGui = PlayerGui:FindFirstChild("GrowbloxUI")
if oldGui then oldGui:Destroy() end

local State = {
    Spam = false, PutBreak = false, Collect = false, Drop = false, Geiger = false, Ghost = false, Fishing = false,
    AutoFarm = false, AutoClear = false, AutoCollect = false, FastDrop = false, AutoAvoid = false, SpoofName = false, SpoofSkin = false,
    Delay = 500, SelectedBlocks = {15}, BreakHit = 3
}
_G.GrowbloxState = State -- Simpen state biar bisa diakses script logic

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GrowbloxUI"
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
    end)
end
Slots[15].BackgroundColor3 = Color3.fromRGB(255, 20, 20)

print("GUI Loaded.")
