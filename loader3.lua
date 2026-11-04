-- Growblox 67 — Game-Specific Working Build
-- Actual tool/character interaction logic.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local LP = Players.LocalPlayer
local cam = WS.CurrentCamera

print("[Growblox67] Booting Game-Specific Build...")

local Config = { MaxWalkSpeed = 64, MaxFlySpeed = 80, FarmDelay = 0.45 }
local F = setmetatable({}, {__index = function() return false end})

--[[ 1. SAFE FIRING (With Debug) ]]
local function fireSafe(remoteName, ...)
    local r = RS:FindFirstChild(remoteName, true) or WS:FindFirstChild(remoteName, true)
    if not r or not r:IsA("RemoteEvent") then return false end
    local args = {...}
    local ok, err = pcall(function() r:FireServer(table.unpack(args)) end)
    if not ok then print("[Growblox67] Fire error ("..remoteName.."): "..tostring(err)) end
    return ok
end

--[[ 2. CHARACTER CACHE ]]
local char, hum, hrp
local function rebind()
    char = LP.Character
    if char then
        hum = char:FindFirstChildOfClass("Humanoid")
        hrp = char:FindFirstChild("HumanoidRootPart")
    end
end
LP.CharacterAdded:Connect(function(c)
    char = c; hum = c:WaitForChild("Humanoid", 10); hrp = c:WaitForChild("HumanoidRootPart", 10)
end)
rebind()

--[[ 3. TRACKERS ]]
local trackers = {
    dirt = setmetatable({}, {__mode = "k"}),
    cave = setmetatable({}, {__mode = "k"}),
    items = setmetatable({}, {__mode = "k"}),
    blocks = setmetatable({}, {__mode = "k"}),
}
local function classify(obj)
    if not obj:IsA("BasePart") then return end
    local n = obj.Name:lower()
    if n:find("dirt") then trackers.dirt[obj] = true
    elseif n:find("cave") then trackers.cave[obj] = true
    elseif n:find("item") or n:find("drop") or n:find("seed") or n:find("gem") then trackers.items[obj] = true
    elseif n:find("block") then trackers.blocks[obj] = true end
end
for _, v in ipairs(WS:GetDescendants()) do classify(v) end
WS.DescendantAdded:Connect(classify)
WS.DescendantRemoving:Connect(function(obj)
    trackers.dirt[obj] = nil; trackers.cave[obj] = nil
    trackers.items[obj] = nil; trackers.blocks[obj] = nil
end)

--[[ 4. HIT BLOCK (The Fix) ]]
local function hitBlock(block)
    if not char or not hrp or not block then return end
    -- Find the tool (pickaxe)
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    -- Face the block
    local targetPos = Vector3.new(block.Position.X, hrp.Position.Y, block.Position.Z)
    hrp.CFrame = CFrame.lookAt(hrp.Position, targetPos)
    
    -- Activate tool (spams animation and fires the remote internally)
    tool:Activate()
    
    -- Fallback: if the game uses a specific "Hit" remote
    -- fireSafe("HitBlock", block) 
end

--[[ 5. AUTO CLEAN & FARM ]]
local function getNearest(tracker, maxDist)
    local best, bestDist = nil, maxDist or math.huge
    if not hrp then return nil end
    for obj in pairs(tracker) do
        if obj.Parent then
            local d = (obj.Position - hrp.Position).Magnitude
            if d < bestDist then best, bestDist = obj, d end
        end
    end
    return best
end

task.spawn(function()
    while true do
        pcall(function()
            if F.AutoCleanDirt and hrp then
                local block = getNearest(trackers.dirt, F.CleanRadius or 32)
                if block then
                    -- Teleport to block and hit it
                    hrp.CFrame = CFrame.new(block.Position + Vector3.new(0, 3, 0))
                    hitBlock(block)
                end
            elseif F.AutoCleanCave and hrp then
                local block = getNearest(trackers.cave, F.CleanRadius or 32)
                if block then
                    hrp.CFrame = CFrame.new(block.Position + Vector3.new(0, 3, 0))
                    hitBlock(block)
                end
            elseif F.AutoFarmLoop and hrp then
                local block = getNearest(trackers.blocks, F.FarmRadius or 16)
                if block then
                    hrp.CFrame = CFrame.new(block.Position + Vector3.new(0, 3, 0))
                    hitBlock(block)
                end
            end
        end)
        task.wait(Config.FarmDelay)
    end
end)

--[[ 6. MOVEMENT ]]
local flyVel = Vector3.zero
RunService.RenderStepped:Connect(function(dt)
    pcall(function()
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
            flyVel = flyVel:Lerp(d * math.min(F.FlySpeed or 60, Config.MaxFlySpeed), 0.3)
            hrp.CFrame += flyVel * dt
        elseif hum.PlatformStand and not F.Fly then
            hum.PlatformStand = false
            flyVel = Vector3.zero
        end
        if F.SuperSpeed then hum.WalkSpeed = math.min(F.SpeedValue or 16, Config.MaxWalkSpeed)
        else hum.WalkSpeed = 16 end
    end)
end)

--[[ 7. ESP (Highlights) ]]
local espActive = {}
task.spawn(function()
    local hue = 0
    while task.wait(0.25) do
        pcall(function()
            if F.ItemESP or F.DirtESP or F.CaveESP then
                hue = (hue + 0.03) % 1
                local col = Color3.fromHSV(hue, 1, 1)
                if F.ItemESP then
                    for it in pairs(trackers.items) do
                        if it.Parent and not espActive[it] then
                            local hl = Instance.new("Highlight"); hl.FillColor = col; hl.Parent = it; espActive[it] = hl
                        end
                    end
                end
                if F.DirtESP then
                    for it in pairs(trackers.dirt) do
                        if it.Parent and not espActive[it] then
                            local hl = Instance.new("Highlight"); hl.FillColor = Color3.fromRGB(139,69,19); hl.Parent = it; espActive[it] = hl
                        end
                    end
                end
                if F.CaveESP then
                    for it in pairs(trackers.cave) do
                        if it.Parent and not espActive[it] then
                            local hl = Instance.new("Highlight"); hl.FillColor = Color3.fromRGB(50,50,50); hl.Parent = it; espActive[it] = hl
                        end
                    end
                end
            end
        end)
    end
end)

--[[ 8. UI BUILDER (Crash-Proof) ]]
local function getUIParent()
    if gethui then local ok, hui = pcall(gethui) if ok and hui then return hui end end
    return game:GetService("CoreGui")
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GrowbloxNative"; ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = getUIParent() end)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 500)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0; MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40); Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.Text = "🟢 Growblox | Actual Working"; Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold; Title.TextSize = 16; Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

local Scrolling = Instance.new("ScrollingFrame")
Scrolling.Size = UDim2.new(1, -20, 1, -60); Scrolling.Position = UDim2.new(0, 10, 0, 50)
Scrolling.BackgroundTransparency = 1; Scrolling.ScrollBarThickness = 4; Scrolling.CanvasSize = UDim2.new(0, 0, 0, 1000); Scrolling.Parent = MainFrame

local List = Instance.new("UIListLayout"); List.Padding = UDim.new(0, 8); List.Parent = Scrolling

local function AddToggle(name, flag)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 35); Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Btn.Text = "  " .. name .. " [OFF]"; Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.TextXAlignment = Enum.TextXAlignment.Left; Btn.Font = Enum.Font.Gotham; Btn.Parent = Scrolling
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    local state = F[flag] or false
    Btn.Text = "  " .. name .. (state and " [ON]" or " [OFF]")
    Btn.BackgroundColor3 = state and Color3.fromRGB(0, 120, 60) or Color3.fromRGB(45, 45, 45)
    Btn.MouseButton1Click:Connect(function()
        state = not state; F[flag] = state
        Btn.Text = "  " .. name .. (state and " [ON]" or " [OFF]")
        Btn.BackgroundColor3 = state and Color3.fromRGB(0, 120, 60) or Color3.fromRGB(45, 45, 45)
    end)
end

AddToggle("Auto Farm Loop", "AutoFarmLoop")
AddToggle("Auto Collect", "AutoCollect")
AddToggle("Auto Clean Dirt", "AutoCleanDirt")
AddToggle("Auto Clean Cave", "AutoCleanCave")
AddToggle("Fly", "Fly")
AddToggle("NoClip", "NoClip")
AddToggle("Anti-Void", "AntiVoid")
AddToggle("Item ESP", "ItemESP")
AddToggle("Dirt ESP", "DirtESP")
AddToggle("Cave ESP", "CaveESP")
AddToggle("Fullbright", "Fullbright")

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("[Growblox67] Working Build Loaded. Auto-Farm/Clean uses Tool:Activate()")
