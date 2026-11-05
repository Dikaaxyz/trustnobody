local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local old = PG:FindFirstChild("GrowV26")
if old then old:Destroy() end

task.wait(1)

local S = {
    Tabs = {
        Spam = {On=false}, PutBreak = {On=false}, Collect = {On=false}, Drop = {On=false},
        Geiger = {On=false}, Ghost = {On=false}, Fishing = {On=false}, AutoFarm = {On=false},
        AutoClear = {On=false}, AutoCollect = {On=false}, FastDrop = {On=false}, AutoAvoid = {On=true},
        SpoofName = {On=false}, SpoofSkin = {On=false}
    },
    Blocks = {15}
}

local R = {}
for _,v in pairs(RS:GetDescendants()) do if v:IsA("RemoteEvent") then R[string.lower(v.Name)] = v end end
local function Get(k) for n,v in pairs(R) do if n:find(k) then return v end end end
local RPlace = Get("place") or Get("build")
local RPunch = Get("punch") or Get("break")
local RCollect = Get("collect") or Get("pickup")
local RDrop = Get("drop")
local RLeave = Get("leave") or Get("exit")
local RWarp = Get("warp") or Get("join")

local function Fire(r, ...)
    if r then pcall(function() r:FireServer(...) end) end
end

local SG = Instance.new("ScreenGui")
SG.Name = "GrowV26"; SG.ResetOnSpawn = false; SG.Parent = PG

task.wait() -- Jeda anti crash

local Main = Instance.new("Frame", SG)
Main.Size = UDim2.new(0, 700, 0, 480)
Main.Position = UDim2.new(0.5, -350, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 4)

local L = Instance.new("Frame", Main)
L.Size = UDim2.new(0, 150, 1, 0); L.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
local LScroll = Instance.new("ScrollingFrame", L)
LScroll.Size = UDim2.new(1, 0, 1, 0); LScroll.BackgroundTransparency = 1; LScroll.ScrollBarThickness = 2
Instance.new("UIListLayout", LScroll)

local M = Instance.new("Frame", Main)
M.Size = UDim2.new(0, 320, 1, 0); M.Position = UDim2.new(0, 150, 0, 0); M.BackgroundColor3 = Color3.fromRGB(28, 28, 28)

local RPanel = Instance.new("Frame", Main)
RPanel.Size = UDim2.new(0, 230, 1, 0); RPanel.Position = UDim2.new(0, 470, 0, 0); RPanel.BackgroundColor3 = Color3.fromRGB(28, 28, 28)

local Grid = Instance.new("UIGridLayout", RPanel)
Grid.CellSize = UDim2.new(0, 30, 0, 30); Grid.CellPadding = UDim2.new(0, 4, 0, 4)
Instance.new("UIPadding", RPanel).PaddingLeft = UDim.new(0, 25)
Instance.new("UIPadding", RPanel).PaddingTop = UDim.new(0, 25)

task.wait() -- Jeda anti crash

local Slots = {}
for i=1,25 do
    local Slt = Instance.new("Frame", RPanel)
    Slt.BackgroundColor3 = Color3.fromRGB(255,255,255); Slt.LayoutOrder = i; Slots[i] = Slt
    Instance.new("UICorner", Slt).CornerRadius = UDim.new(0, 2)
    local B = Instance.new("TextButton", Slt)
    B.Size = UDim2.new(1,0,1,0); B.BackgroundTransparency = 1; B.Text = ""
    B.MouseButton1Click:Connect(function()
        local f = false
        for idx, v in ipairs(S.Blocks) do if v==i then table.remove(S.Blocks, idx); f=true; break end end
        if not f then table.insert(S.Blocks, i) end
        Slt.BackgroundColor3 = f and Color3.fromRGB(255,255,255) or Color3.fromRGB(255,20,20)
    end)
    if i % 5 == 0 then task.wait() end -- Jeda tiap 5 kotak
end
Slots[15].BackgroundColor3 = Color3.fromRGB(255,20,20)

local Pages = {}
local Btns = {}

local function CreatePage(name)
    local P = Instance.new("Frame", M)
    P.Size = UDim2.new(1,0,1,0); P.BackgroundTransparency = 1; P.Visible = false
    Pages[name] = P
    
    local Stop = Instance.new("TextButton", P)
    Stop.Size = UDim2.new(0, 65, 0, 28); Stop.Position = UDim2.new(0, 15, 0, 15)
    Stop.BackgroundColor3 = Color3.fromRGB(255,20,20); Stop.Text = "STOP"; Stop.Font = Enum.Font.GothamBold
    Stop.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", Stop).CornerRadius = UDim.new(0, 4)
    Stop.MouseButton1Click:Connect(function()
        for k,v in pairs(S.Tabs) do if v.On then v.On = false end end
        for _, b in pairs(Btns) do b.BackgroundColor3 = Color3.fromRGB(28,28,28) end
    end)
    
    local T = Instance.new("TextButton", P)
    T.Size = UDim2.new(0, 200, 0, 30); T.Position = UDim2.new(0, 15, 0, 55)
    T.BackgroundColor3 = S.Tabs[name].On and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,30,30)
    T.Text = name .. ": " .. (S.Tabs[name].On and "ON" or "OFF")
    T.TextColor3 = Color3.new(1,1,1); T.Font = Enum.Font.Gotham
    Instance.new("UICorner", T).CornerRadius = UDim.new(0, 4)
    T.MouseButton1Click:Connect(function()
        S.Tabs[name].On = not S.Tabs[name].On
        T.BackgroundColor3 = S.Tabs[name].On and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,30,30)
        T.Text = name .. ": " .. (S.Tabs[name].On and "ON" or "OFF")
    end)
    
    task.wait() -- Jeda tiap bikin tab
end

for name, _ in pairs(S.Tabs) do
    local B = Instance.new("TextButton", LScroll)
    B.Size = UDim2.new(1,0,0,30); B.BackgroundColor3 = Color3.fromRGB(28,28,28)
    B.Text = "  "..name; B.TextColor3 = Color3.fromRGB(200,200,200); B.TextXAlignment = Enum.TextXAlignment.Left
    B.Font = Enum.Font.Gotham; B.TextSize = 13
    Btns[name] = B
    
    CreatePage(name)
    
    B.MouseButton1Click:Connect(function()
        for n, btn in pairs(Btns) do
            btn.BackgroundColor3 = n==name and Color3.fromRGB(255,20,20) or Color3.fromRGB(28,28,28)
            Pages[n].Visible = n==name
        end
    end)
end
Btns["PutBreak"].BackgroundColor3 = Color3.fromRGB(255,20,20)
Pages["PutBreak"].Visible = true

task.spawn(function()
    while task.wait(0.5) do
        local c = LP.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChild("Humanoid")
        if not h or not hum then continue end
        
        if S.Tabs.PutBreak.On or S.Tabs.AutoFarm.On then
            local tx, tz = math.floor(h.Position.X/3), math.floor(h.Position.Z/3)
            hum:MoveTo(Vector3.new(tx*3, h.Position.Y, tz*3))
            task.wait(0.3)
            for _, id in ipairs(S.Blocks) do
                if RPlace then Fire(RPlace, tx, tz, id) end
                for i=1, 3 do if RPunch then Fire(RPunch, tx, tz) end end
            end
            task.wait(0.5)
        end
        
        if S.Tabs.Collect.On and RCollect then Fire(RCollect, math.floor(h.Position.X/3), math.floor(h.Position.Z/3)) end
        if S.Tabs.Drop.On and RDrop then Fire(RDrop) end
    end
end)

print("Loaded perfectly.")
