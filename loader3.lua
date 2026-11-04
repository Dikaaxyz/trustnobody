-- Growblox_BruteForce_Duper.lua
-- Target: Spam Clicking Confirmation Popup & Drop Button
-- Executor: Xeno / Solara

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local isRunning = false
local loopConnection = nil
local CLICK_DELAY = 0.01
local LAG_HITCH_CHANCE = 10

-- ==========================================
-- BRUTE FORCE SCANNER (Nembak semua tombol)
-- ==========================================
local function findTargetButtons()
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return end
    
    local dropBtn = nil
    local okBtn = nil
    
    for _, obj in pairs(gui:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            local text = obj.Text and obj.Text:upper() or ""
            local name = obj.Name:upper() or ""
            
            -- Skip our own GUI
            if obj:FindFirstAncestor("RootmanBruteForce") then continue end
            
            -- Cari tombol OK (Popup)
            if text == "OK" or name == "OK" or text:find("CONFIRM") then
                okBtn = obj
            end
            
            -- Cari tombol DROP (Inventory)
            if text == "DROP" or name == "DROP" then
                dropBtn = obj
            end
        end
    end
    
    return dropBtn, okBtn
end

-- ==========================================
-- LAG HITCH
-- ==========================================
local function triggerLagHitch()
    local start = tick()
    while tick() - start < 0.15 do end
end

-- ==========================================
-- THE BRUTE FORCE LOOP
-- ==========================================
local function startEngine()
    isRunning = true
    print("[Rootman] BruteForce Engine Active. Menunggu popup...")
    
    loopConnection = RunService.Heartbeat:Connect(function()
        if not isRunning then return end
        
        local dropBtn, okBtn = findTargetButtons()
        
        -- Prioritas 1: Kalo popup muncul (ada tombol OK), spam OK sampai hancur
        if okBtn then
            pcall(function()
                okBtn:Click()
            end)
            
            -- Trigger lag biar inventory gagal ke-save
            if math.random(1, LAG_HITCH_CHANCE) == 1 then
                task.spawn(triggerLagHitch)
            end
        -- Prioritas 2: Kalo nggak ada popup, spam tombol Drop
        elseif dropBtn then
            pcall(function()
                dropBtn:Click()
            end)
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
if LocalPlayer.PlayerGui:FindFirstChild("RootmanBruteForce") then
    LocalPlayer.PlayerGui.RootmanBruteForce:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RootmanBruteForce"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 220, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 200, 40)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Text = "START BRUTE-FORCE"
ToggleBtn.Parent = ScreenGui

ToggleBtn.MouseButton1Click:Connect(function()
    if isRunning then
        stopEngine()
        ToggleBtn.Text = "START BRUTE-FORCE"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    else
        startEngine()
        ToggleBtn.Text = "STOP BRUTE-FORCE"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    end
end)
