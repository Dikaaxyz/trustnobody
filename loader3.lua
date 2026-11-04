-- Growblox 67 — Bulletproof Build
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local WS = game:GetService("Workspace")
local LP = Players.LocalPlayer
local cam = WS.CurrentCamera

print("[Growblox67] Injecting...")

-- 1. SAFE PARENTING
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GrowbloxUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
-- Try CoreGui, fallback to PlayerGui. No gethui() crashes.
local success = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not success then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 500)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.Text = "🟢 Growblox 67 | Bulletproof"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

local Scrolling = Instance.new("ScrollingFrame")
Scrolling.Size = UDim2.new(1, -20, 1, -60)
Scrolling.Position = UDim2.new(0, 10, 0, 50)
Scrolling.BackgroundTransparency = 1
Scrolling.ScrollBarThickness = 4
Scrolling.CanvasSize = UDim2.new(0, 0, 0, 1500)
Scrolling.Parent = MainFrame
Instance.new("UIListLayout", Scrolling).Padding = UDim.new(0, 8)

-- 2. FLAGS & STATE
local F = setmetatable({}, {__index = function() return false end})

local function AddToggle(name, flag)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Btn.Text = "  " .. name .. " [OFF]"
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Font = Enum.Font.Gotham
    Btn.Parent = Scrolling
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    
    local state = false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        F[flag] = state
        Btn.Text = "  " .. name .. (state and " [ON]" or " [OFF]")
        Btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(45, 45, 45)
    end)
end

-- 3. BUILD MENU
AddToggle("Auto Clean Dirt", "AutoCleanDirt")
AddToggle("Auto Clean Cave", "AutoCleanCave")
AddToggle("Auto Collect Gems/Seeds", "AutoCollect")
AddToggle("Fly", "Fly")
AddToggle("NoClip", "NoClip")
AddToggle("Speed Hack (64)", "SpeedHack")

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- 4. CHARACTER CACHE (No yielding)
local char, hum, hrp
local function updateChar()
    char = LP.Character
    if char then
        hum = char:FindFirstChildOfClass("Humanoid")
        hrp = char:FindFirstChild("HumanoidRootPart")
    end
end
LP.CharacterAdded:Connect(function(c)
    char = c
    task.wait(0.5)
    updateChar()
end)
updateChar()

-- 5. MOVEMENT LOOP
local flyVel = Vector3.zero
RunService.RenderStepped:Connect(function(dt)
    if not hrp or not hum then return end
    
    if F.Fly then
        hum.PlatformStand = true
        local d = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then d += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then d -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then d -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then d += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then d += Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d -= Vector3.yAxis end
        if d.Magnitude > 0 then d = d.Unit end
        flyVel = flyVel:Lerp(d * 60, 0.3)
        hrp.CFrame += flyVel * dt
    elseif hum.PlatformStand and not F.Fly then
        hum.PlatformStand = false
        flyVel = Vector3.zero
    end
    
    if F.SpeedHack then hum.WalkSpeed = 64 else hum.WalkSpeed = 16 end
end)

-- 6. NOCLIP
RunService.Stepped:Connect(function()
    if F.NoClip and char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- 7. AUTOMATION (Lightweight Scan)
-- Instead of scanning the whole Workspace at boot, we scan on-demand.
local function getNearest(keyword, maxDist)
    if not hrp then return nil end
    local best, bestDist = nil, maxDist
    -- Only scan what's around us, not the whole map
    for _, obj in ipairs(WS:GetChildren()) do
        if obj:IsA("Model") then
            local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if primary and obj.Name:lower():find(keyword) then
                local d = (primary.Position - hrp.Position).Magnitude
                if d < bestDist then best, bestDist = primary, d end
            end
        elseif obj:IsA("BasePart") and obj.Name:lower():find(keyword) then
            local d = (obj.Position - hrp.Position).Magnitude
            if d < bestDist then best, bestDist = obj, d end
        end
    end
    return best
end

task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            if not hrp or not char then return end
            
            -- Auto Clean
            if F.AutoCleanDirt then
                local block = getNearest("dirt", 32)
                if block then
                    hrp.CFrame = CFrame.new(block.Position + Vector3.new(0, 3, 0))
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end
            elseif F.AutoCleanCave then
                local block = getNearest("cave", 32)
                if block then
                    hrp.CFrame = CFrame.new(block.Position + Vector3.new(0, 3, 0))
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end
            end
            
            -- Auto Collect
            if F.AutoCollect then
                local item = getNearest("seed", 40) or getNearest("gem", 40) or getNearest("drop", 40)
                if item then
                    hrp.CFrame = CFrame.new(item.Position + Vector3.new(0, 3, 0))
                end
            end
        end)
    end
end)

print("[Growblox67] Fully Loaded. No crashes.")
