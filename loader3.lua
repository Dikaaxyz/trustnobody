-- Growblox_AutoFlow_Duper.lua
-- Target: Automated Drop + Confirm Spam (Desync)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local isRunning = false
local loopConnection = nil
local CLICK_DELAY = 0.01 -- Very fast
local LAG_HITCH_CHANCE = 15

-- ==========================================
-- UNIVERSAL UI FINDER
-- ==========================================
local function findButton(textToFind)
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return nil end
    
    textToFind = textToFind:upper()
    for _, obj in pairs(gui:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            local text = obj.Text and obj.Text:upper() or ""
            local name = obj.Name:upper() or ""
            
            if obj:FindFirstAncestor("RootmanAutoFlow") then continue end
            
            -- Cek teks atau nama
            if text == textToFind or name == textToFind then
                return obj
            end
            -- Fallback buat tombol yang tulisannya "OK" tapi namanya beda
            if textToFind == "OK" and (text:find("OK") or name:find("OK")) then
                return obj
            end
        end
    end
    return nil
end

-- ==========================================
-- LAG HITCH
-- ==========================================
local function triggerLagHitch()
    local start = tick()
    while tick() - start < 0.1 do end -- Freeze 100ms
end

-- ==========================================
-- MAIN ENGINE (Auto Flow)
-- ==========================================
local function startEngine()
    isRunning = true
    print("[Rootman] AutoFlow Engine Active...")
    
    loopConnection = RunService.Heartbeat:Connect(function()
        if not isRunning then return end
        
        -- Step 1: Cek apakah popup "OK" atau "CONFIRM" lagi kebuka
        local confirmBtn = findButton("OK") or findButton("CONFIRM") or findButton("YES")
        
        if confirmBtn then
            -- Kalau popup kebuka, spam tombolnya!
            pcall(function()
                confirmBtn:Click()
            end)
            
            -- Lag hack sesekali
            if math.random(1, LAG_HITCH_CHANCE) == 1 then
                task.spawn(triggerLagHitch)
            end
            
        else
            -- Step 2: Kalau popup nggak ada, coba klik tombol DROP di kanan
            local dropBtn = findButton("DROP")
            if dropBtn then
                pcall(function()
                    dropBtn:Click()
                end)
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
-- UI TOGGLE
-- ==========================================
if LocalPlayer.PlayerGui:FindFirstChild("RootmanAutoFlow") then
    LocalPlayer.PlayerGui.RootmanAutoFlow:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RootmanAutoFlow"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 220, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 200, 40)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Text = "START AUTO-DUPER"
ToggleBtn.Parent = ScreenGui

ToggleBtn.MouseButton1Click:Connect(function()
    if isRunning then
        stopEngine()
        ToggleBtn.Text = "START AUTO-DUPER"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    else
        startEngine()
        ToggleBtn.Text = "STOP AUTO-DUPER"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
    end
end)
