-- Growblox_Universal_Duper.lua
-- Context: Roblox LocalScript (Xeno / Solara)
-- Target: Race Condition via UI Spam & Lag Desync
-- Fitur: Mode Drop (OK Spam) & Mode Recycle (Server Rollback)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local isRunning = false
local currentMode = "DROP" -- "DROP" or "RECYCLE"
local loopConnection = nil
local CLICK_DELAY = 0.015
local LAG_CHANCE = 10

-- ==========================================
-- UI SCANNER (Universal)
-- ==========================================
local function findButton(textToFind)
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return nil end
    
    textToFind = textToFind:upper()
    for _, obj in pairs(gui:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            local text = obj.Text and obj.Text:upper() or ""
            local name = obj.Name:upper() or ""
            
            -- Abaikan tombol GUI kita sendiri
            if obj:FindFirstAncestor("RootmanUniversalDuper") then continue end
            
            if text == textToFind or name == textToFind then
                return obj
            end
        end
    end
    return nil
end

-- ==========================================
-- NETWORK CHOKE
-- ==========================================
local function triggerLagHitch()
    local start = tick()
    while tick() - start < 0.15 do end -- Hang 150ms
end

-- ==========================================
-- MAIN ENGINE
-- ==========================================
local function startEngine()
    isRunning = true
    print("[Rootman] Engine Active. Mode: " .. currentMode)
    
    loopConnection = RunService.Heartbeat:Connect(function()
        if not isRunning then return end
        
        local targetBtn = nil
        local fallbackBtn = nil

        if currentMode == "DROP" then
            targetBtn = findButton("OK") 
            fallbackBtn = findButton("DROP")
        elseif currentMode == "RECYCLE" then
            targetBtn = findButton("RECYCLE")
            fallbackBtn = findButton("CONFIRM") -- Beberapa game pakai "Confirm"
            if not fallbackBtn then fallbackBtn = findButton("YES") end
        end

        -- Logika: Kalau popup konfirmasi (OK/Confirm/Yes) muncul, klik itu.
        -- Kalau nggak ada, klik tombol utamanya (Drop/Recycle).
        local clickTarget = targetBtn or fallbackBtn
        
        if clickTarget then
            pcall(function()
                clickTarget:Click()
            end)
            
            if math.random(1, LAG_CHANCE) == 1 then
                task.spawn(triggerLagHitch)
            end
        end
        
        task.wait(CLICK_DELAY)
    end)
end

local function stopEngine()
    isRunning = false
    if loopConnection then
        loopConnection:Disconnect()
        loopConnection = nil
    end
    print("[Rootman] Engine Stopped.")
end

-- ==========================================
-- UI CREATION
-- ==========================================
if LocalPlayer.PlayerGui:FindFirstChild("RootmanUniversalDuper") then
    LocalPlayer.PlayerGui.RootmanUniversalDuper:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RootmanUniversalDuper"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 200)
MainFrame.Position = UDim2.new(0, 20, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.TextColor3 = Color3.fromRGB(255, 200, 40)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Text = "Universal Dupe Engine"
Title.Parent = MainFrame

-- Mode Selector
local DropModeBtn = Instance.new("TextButton")
DropModeBtn.Size = UDim2.new(0.5, -15, 0, 30)
DropModeBtn.Position = UDim2.new(0, 10, 0, 40)
DropModeBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
DropModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DropModeBtn.Font = Enum.Font.GothamBold
DropModeBtn.TextSize = 12
DropModeBtn.Text = "MODE: DROP"
DropModeBtn.Parent = MainFrame

local RecModeBtn = Instance.new("TextButton")
RecModeBtn.Size = UDim2.new(0.5, -15, 0, 30)
RecModeBtn.Position = UDim2.new(0.5, 5, 0, 40)
RecModeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
RecModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RecModeBtn.Font = Enum.Font.GothamBold
RecModeBtn.TextSize = 12
RecModeBtn.Text = "MODE: RECYCLE"
RecModeBtn.Parent = MainFrame

-- Start Button
local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(1, -20, 0, 50)
StartBtn.Position = UDim2.new(0, 10, 0, 80)
StartBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextSize = 14
StartBtn.Text = "START ENGINE"
StartBtn.Parent = MainFrame

-- Status
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 40)
StatusLabel.Position = UDim2.new(0, 10, 0, 140)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11
StatusLabel.TextWrap = true
StatusLabel.Text = "Pilih mode, lalu tekan START.\nKlik item di inventory sebelum/sesudah start."
StatusLabel.Parent = MainFrame

-- ==========================================
-- UI LOGIC
-- ==========================================
DropModeBtn.MouseButton1Click:Connect(function()
    currentMode = "DROP"
    DropModeBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    RecModeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    StatusLabel.Text = "Mode: DROP (Spam OK)\nPastikan popup Drop terbuka."
end)

RecModeBtn.MouseButton1Click:Connect(function()
    currentMode = "RECYCLE"
    RecModeBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    DropModeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    StatusLabel.Text = "Mode: RECYCLE (Spam Recycle)\nKlik item, lalu biarkan script spam."
end)

StartBtn.MouseButton1Click:Connect(function()
    if isRunning then
        stopEngine()
        StartBtn.Text = "START ENGINE"
        StartBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    else
        startEngine()
        StartBtn.Text = "STOP ENGINE"
        StartBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    end
end)
