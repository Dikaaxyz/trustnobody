-- Growblox_Confirm_Dupe.lua
-- Target: Drop Confirmation Dialog Desync (Server Rollback Exploit)
-- Executor: Xeno / Solara

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local isDuping = false
local toggleKey = Enum.KeyCode.Z
local loopConnection = nil

-- Settings
local CLICK_DELAY = 0.02  
local LAG_HITCH_CHANCE = 8 -- 1 in X chance to hang the thread

-- ==========================================
-- UI SCANNER (Targets the "OK" button)
-- ==========================================
local function findOKButton()
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return nil end
    
    -- Cari TextButton yang tulisannya "OK"
    for _, obj in pairs(gui:GetDescendants()) do
        if obj:IsA("TextButton") then
            local text = obj.Text and obj.Text:upper() or ""
            if text == "OK" then
                return obj
            end
        end
    end
    return nil
end

-- ==========================================
-- NETWORK CHOKE (Desync the inventory state)
-- ==========================================
local function triggerLagHitch()
    -- Nge-hang Lua thread selama 150ms (bikin server timeout / desync)
    local start = tick()
    while tick() - start < 0.15 do end
end

-- ==========================================
-- THE MAIN SPAM LOOP
-- ==========================================
local function startDupe()
    isDuping = true
    print("[Rootman] Confirm Dialog Dupe Active...")
    
    loopConnection = RunService.Heartbeat:Connect(function()
        if not isDuping then return end
        
        local okBtn = findOKButton()
        if okBtn then
            -- 1. Spam klik "OK"
            okBtn:Click()
            
            -- 2. Lag choke pas nge-klik
            if math.random(1, LAG_HITCH_CHANCE) == 1 then
                task.spawn(triggerLagHitch)
            end
        end
        
        task.wait(CLICK_DELAY)
    end)
end

local function stopDupe()
    isDuping = false
    if loopConnection then
        loopConnection:Disconnect()
        loopConnection = nil
    end
    print("[Rootman] Dupe Stopped.")
end

-- ==========================================
-- UI TOGGLE
-- ==========================================
if LocalPlayer.PlayerGui:FindFirstChild("RootmanConfirmDupe") then
    LocalPlayer.PlayerGui.RootmanConfirmDupe:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RootmanConfirmDupe"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 220, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 200, 40)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Text = "START CONFIRM DUPE"
ToggleBtn.Parent = ScreenGui

ToggleBtn.MouseButton1Click:Connect(function()
    if isDuping then
        stopDupe()
        ToggleBtn.Text = "START CONFIRM DUPE"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    else
        startDupe()
        ToggleBtn.Text = "STOP CONFIRM DUPE"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == toggleKey then
        if isDuping then
            stopDupe()
            ToggleBtn.Text = "START CONFIRM DUPE"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        else
            startDupe()
            ToggleBtn.Text = "STOP CONFIRM DUPE"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
        end
    end
end)
