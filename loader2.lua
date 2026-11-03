-- EggMaster V10 — Ultra Stable (Anti-Crash)
-- Cuma ada 3 fitur inti. Ringan buat Xeno.

-- 1. Tunggu game bener-bener loaded
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- 2. Bungkus semua dalam pcall biar kalau error gak bikin game crash
local success, err = pcall(function()
    
    -- Hapus script lama kalau ada
    for _, v in pairs(game.CoreGui:GetChildren()) do
        if v.Name == "EggMaster_Simple" then
            v:Destroy()
        end
    end

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local CoreGui = game:GetService("CoreGui")
    local LP = Players.LocalPlayer

    local AutoSteal = false
    local SpeedHack = false
    local ESP = false

    -- ==========================================
    -- UI SIMPEL
    -- ==========================================
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "EggMaster_Simple"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 150, 0, 150)
    Frame.Position = UDim2.new(0, 20, 0, 100)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Frame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Title.BorderSizePixel = 0
    Title.Text = "EggMaster"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.Parent = Frame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = Title

    local function MakeButton(text, yPos, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 30)
        btn.Position = UDim2.new(0, 10, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        btn.BorderSizePixel = 0
        btn.Text = text .. ": OFF"
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Parent = Frame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            local isOn = callback()
            if isOn then
                btn.Text = text .. ": ON"
                btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            else
                btn.Text = text .. ": OFF"
                btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            end
        end)
    end

    MakeButton("Auto Steal", 40, function()
        AutoSteal = not AutoSteal
        return AutoSteal
    end)

    MakeButton("Speed Hack", 75, function()
        SpeedHack = not SpeedHack
        local char = LP.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = SpeedHack and 35 or 16
        end
        return SpeedHack
    end)

    MakeButton("ESP Eggs", 110, function()
        ESP = not ESP
        return ESP
    end)

    -- ==========================================
    -- LOGIKA (Dibungkus pcall semua)
    -- ==========================================
    local esp_cache = {}

    RunService.Heartbeat:Connect(function()
        pcall(function()
            local char = LP.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            -- FITUR ESP
            if ESP then
                for _, obj in pairs(Workspace:GetChildren()) do
                    if obj.Name:lower():find("egg") and (obj:IsA("Model") or obj:IsA("BasePart")) then
                        if not esp_cache[obj] then
                            local bg = Instance.new("BillboardGui")
                            bg.AlwaysOnTop = true
                            bg.Size = UDim2.new(0, 100, 0, 30)
                            bg.StudsOffset = Vector3.new(0, 2, 0)
                            bg.Parent = obj
                            
                            local txt = Instance.new("TextLabel")
                            txt.Size = UDim2.new(1,0,1,0)
                            txt.BackgroundTransparency = 1
                            txt.TextColor3 = Color3.fromRGB(255, 200, 40)
                            txt.TextStrokeTransparency = 0
                            txt.Font = Enum.Font.GothamBold
                            txt.TextSize = 12
                            txt.Text = obj.Name
                            txt.Parent = bg
                            
                            esp_cache[obj] = bg
                        end
                        esp_cache[obj].Enabled = true
                    end
                end
            else
                for _, bg in pairs(esp_cache) do
                    if bg and bg.Parent then bg.Enabled = false end
                end
            end

            -- FITUR AUTO STEAL
            if AutoSteal then
                local nearest, nd = nil, 100
                for _, obj in pairs(Workspace:GetChildren()) do
                    if obj.Name:lower():find("egg") and (obj:IsA("Model") or obj:IsA("BasePart")) then
                        local pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                        local d = (hrp.Position - pos).Magnitude
                        if d < nd then
                            nearest, nd = obj, d
                        end
                    end
                end
                
                if nearest then
                    local pos = nearest:IsA("Model") and nearest:GetPivot().Position or nearest.Position
                    if nd > 5 then
                        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                        task.wait(0.2)
                    end
                    
                    local prompt = nearest:FindFirstChildOfClass("ProximityPrompt")
                    if prompt and fireproximityprompt then
                        fireproximityprompt(prompt)
                    end
                end
            end
        end)
    end)
end)

if not success then
    print("[EggMaster] Terjadi error, tapi game lu aman: " .. tostring(err))
end
