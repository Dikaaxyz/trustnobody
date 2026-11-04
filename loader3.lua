-- Growblox_Blind_Duper.lua
-- Target: Blind Spam Click on Confirmation Popup + Hard Network Desync

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local isRunning = false
local loopConnection = nil
local CLICK_DELAY = 0.05
local FREEZE_CHANCE = 3 -- 1 in 3 chance to freeze the game

-- ==========================================
-- BLIND UI SCANNER
-- ==========================================
local function blindClick()
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return end
    
    -- Loop semua tombol di layar
    for _, obj in pairs(gui:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            -- Abaikan GUI script kita
            if obj:FindFirstAncestor("RootmanBlindDuper") then continue end
            
            -- Paksa klik tanpa peduli namanya apa
            pcall(function()
                obj:Click()
            end)
        end
    end
end

-- ==========================================
-- HARD NETWORK DESYNC
-- ==========================================
local function triggerHardFreeze()
    -- Freeze frame 0.5 detik. Bikin server mikir kita disconnect.
    local start = tick()
    while tick() - start < 0.5 do end
end

-- ==========================================
-- THE MAIN ENGINE
-- ==========================================
local function startEngine()
    isRunning = true
    print("[Rootman] Blind Duper Active. Mempersiapkan desync...")
    
    loopConnection = RunService.Heartbeat:Connect(function()
        if not isRunning then return end
        
        -- 1. Klik semua tombol yang ada (termasuk OK dan Cancel, kita paksa)
        blindClick()
        
        -- 2. Hard Freeze
        if math.random(1, FREEZE_CHANCE) == 1 then
            task.spawn(triggerHardFreeze)
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
-- UI
-- ==========================================
if LocalPlayer.PlayerGui:FindFirstChild("RootmanBlindDuper") then
    LocalPlayer.PlayerGui.RootmanBlindDuper:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RootmanBlindDuper"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 220, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 200, 40)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Text = "START BLIND DUPER"
ToggleBtn.Parent = ScreenGui

ToggleBtn.MouseButton1Click:Connect(function()
    if isRunning then
        stopEngine()
        ToggleBtn.Text = "START BLIND DUPER"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    else
        startEngine()
        ToggleBtn.Text = "STOP BLIND DUPER"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    end
end)
