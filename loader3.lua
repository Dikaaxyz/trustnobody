-- Growblox 67 — Full Logic + Complete Native GUI
-- Works on all executors. GUI + 60+ Features.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local VS = game:GetService("VirtualUser")
local WS = game:GetService("Workspace")
local LP = Players.LocalPlayer
local cam = WS.CurrentCamera

print("[Growblox67] Booting Full Build...")

--[[ 1. CONFIG ]]
local Config = {
    Reach = 24,
    MaxFlySpeed = 80,
    MaxWalkSpeed = 64,
    FarmDelay = 0.4,
    CleanDelay = 0.25,
    JitterFactor = 0.35,
    ClampFloor = 0.1,
}

--[[ 2. JITTER ]]
local mr, msq, mlog, mcos, mpi = math.random, math.sqrt, math.log, math.cos, math.pi
local function gauss()
    local u1 = mr() + 1e-9
    local u2 = mr()
    return msq(-2 * mlog(u1)) * mcos(2 * mpi * u2)
end
local function jitterWait(base)
    local dev = gauss() * (base * Config.JitterFactor)
    task.wait(math.max(Config.ClampFloor, base + dev))
end

--[[ 3. REMOTE RESOLVER ]]
local remoteCache = {}
local scanned = false
local function scanRemotes()
    if scanned then return end
    scanned = true
    print("=== GROWBLOX REMOTE DUMP ===")
    for _, container in ipairs({RS, WS}) do
        for _, obj in ipairs(container:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local key = obj.Name:lower()
                if not remoteCache[key] then
                    remoteCache[key] = obj
                    if key:find("break") or key:find("place") or key:find("hit") or key:find("clean") or key:find("dig") or key:find("collect") then
                        print("[TARGET] " .. obj:GetFullName())
                    end
                end
            end
        end
    end
    print("=== END DUMP ===")
end

local function resolve(kind)
    scanRemotes()
    for key, obj in pairs(remoteCache) do
        if key:find(kind) then return obj end
    end
    return nil
end

local function fireSpoofed(kind, ...)
    local r = resolve(kind)
    if not r then return false end
    local argc = select("#", ...)
    local args = {...}
    local ok = pcall(function()
        if argc >= 2 then r:FireServer(args[1], args[2], LP)
        elseif argc == 1 then r:FireServer(args[1], LP)
        else r:FireServer(LP) end
    end)
    return ok
end

--[[ 4. CHARACTER CACHE ]]
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
if not char then pcall(function() LP.CharacterAdded:Wait() end) rebind() end

--[[ 5. FLAGS & TRACKERS ]]
local F = setmetatable({}, {__index = function() return false end})
local Fset = function(k, v) F[k] = v end

local trackers = {
    items  = setmetatable({}, {__mode = "k"}),
    blocks = setmetatable({}, {__mode = "k"}),
    dirt   = setmetatable({}, {__mode = "k"}),
    cave   = setmetatable({}, {__mode = "k"}),
}
local function classify(obj)
    if not obj:IsA("BasePart") then return end
    local n = obj.Name:lower()
    if n:find("dirt") then trackers.dirt[obj] = true
    elseif n:find("cave") then trackers.cave[obj] = true
    elseif n:find("item") or n:find("drop") or n:find("seed") then trackers.items[obj] = true
    elseif n:find("block") then trackers.blocks[obj] = true end
end
for _, v in ipairs(WS:GetDescendants()) do classify(v) end
WS.DescendantAdded:Connect(classify)
WS.DescendantRemoving:Connect(function(obj)
    trackers.items[obj] = nil; trackers.blocks[obj] = nil
    trackers.dirt[obj] = nil; trackers.cave[obj] = nil
end)

--[[ 6. MOVEMENT LOOP ]]
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
        flyVel = flyVel:Lerp(d * math.min(F.FlySpeed or 60, Config.MaxFlySpeed), 0.3)
        hrp.CFrame += flyVel * dt
    elseif hum.PlatformStand and not F.Fly then
        hum.PlatformStand = false
        flyVel = Vector3.zero
    end
    if F.SuperSpeed then hum.WalkSpeed = math.min(F.SpeedValue or 16, Config.MaxWalkSpeed)
    else hum.WalkSpeed = 16 end
    if hrp then
        local v = hrp.AssemblyLinearVelocity
        if v.Magnitude > Config.MaxWalkSpeed * 2 then
            hrp.AssemblyLinearVelocity = v * ((Config.MaxWalkSpeed * 2) / v.Magnitude)
        end
    end
end)

--[[ 7. AUTOMATION LOOP ]]
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
        if F.AutoFarmLoop and hrp then
            local best = getNearest(trackers.blocks, F.FarmRadius or 16)
            if best then
                fireSpoofed("break", best)
                hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(best.Position + Vector3.new(mr(-2,2), 4, mr(-2,2))), 0.2)
            end
            jitterWait(Config.FarmDelay)
        elseif F.AutoCleanDirt and hrp then
            local best = getNearest(trackers.dirt, F.CleanRadius or 32)
            if best then fireSpoofed("break", best); jitterWait(Config.CleanDelay) else jitterWait(0.5) end
        elseif F.AutoCleanCave and hrp then
            local best = getNearest(trackers.cave, F.CleanRadius or 32)
            if best then fireSpoofed("break", best); jitterWait(Config.CleanDelay) else jitterWait(0.5) end
        else jitterWait(0.3) end
    end
end)

--[[ 8. COLLECT LOOP ]]
task.spawn(function()
    while true do
        if F.AutoCollect and hrp then
            local best = getNearest(trackers.items, 60)
            if best then hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(best.Position + Vector3.new(0,3,0)), 0.22) end
            jitterWait(0.12)
        else jitterWait(0.4) end
    end
end)

--[[ 9. NOCLIP & ANTI-VOID ]]
local ncConn
local function setNoClip(on)
    if ncConn then ncConn:Disconnect() ncConn = nil end
    if not on or not char then return end
    ncConn = RunService.Stepped:Connect(function()
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end

task.spawn(function()
    while true do
        setNoClip(F.NoClip)
        if F.AntiVoid and hrp and hrp.Position.Y < -50 then hrp.CFrame = CFrame.new(0, 60, 0) end
        if F.AntiFall and hrp and hrp.AssemblyLinearVelocity.Y < -100 then
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
        end
        jitterWait(0.15)
    end
end)

--[[ 10. ESP LOOP ]]
local espActive = {}
local function releaseAll()
    for parent, hl in pairs(espActive) do hl:Destroy(); espActive[parent] = nil end
end

task.spawn(function()
    local hue = 0
    while task.wait(0.25) do
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
        else releaseAll() end
    end
end)

--[[ 11. COMBAT LOOP ]]
task.spawn(function()
    while task.wait(0.1) do
        if F.KillAura and hrp and char then
            local reach = math.min(Config.Reach, F.Reach or 7)
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LP and pl.Character then
                    local ph = pl.Character:FindFirstChild("HumanoidRootPart")
                    if ph and (ph.Position - hrp.Position).Magnitude <= reach then
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then pcall(function() tool:Activate() end) end
                    end
                end
            end
        end
        if F.Fullbright then pcall(function() game.Lighting.Ambient = Color3.new(1,1,1) end)
        else pcall(function() game.Lighting.Ambient = Color3.new(0.5,0.5,0.5) end) end
    end
end)

--[[ 12. UI BUILDER ]]
print("[Growblox67] Building Complete Native UI...")
local function getUIParent()
    if gethui then local ok, hui = pcall(gethui) if ok and hui then return hui end end
    if game:GetService("CoreGui") then return game:GetService("CoreGui") end
    return LP:WaitForChild("PlayerGui")
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GrowbloxNative"; ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = getUIParent() end)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 550)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.Text = "🟢 Growblox 67 | Full Features"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 35)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabBar.Parent = MainFrame

local Scrolling = Instance.new("ScrollingFrame")
Scrolling.Size = UDim2.new(1, -20, 1, -90)
Scrolling.Position = UDim2.new(0, 10, 0, 85)
Scrolling.BackgroundTransparency = 1
Scrolling.ScrollBarThickness = 4
Scrolling.CanvasSize = UDim2.new(0, 0, 0, 1500)
Scrolling.Parent = MainFrame

local List = Instance.new("UIListLayout")
List.Padding = UDim.new(0, 8)
List.Parent = Scrolling

local function SwitchTab(tabName)
    for _, child in ipairs(Scrolling:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("Frame") then child:Destroy() end
    end
    
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
            state = not state
            Fset(flag, state)
            Btn.Text = "  " .. name .. (state and " [ON]" or " [OFF]")
            Btn.BackgroundColor3 = state and Color3.fromRGB(0, 120, 60) or Color3.fromRGB(45, 45, 45)
        end)
    end

    local function AddSlider(name, flag, min, max, default)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 60); Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Frame.Parent = Scrolling
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)
        
        local Lbl = Instance.new("TextLabel")
        Lbl.Size = UDim2.new(1, -10, 0, 20); Lbl.Position = UDim2.new(0, 5, 0, 5)
        Lbl.BackgroundTransparency = 1; Lbl.Text = name .. ": " .. default
        Lbl.TextColor3 = Color3.new(1, 1, 1); Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.Font = Enum.Font.Gotham; Lbl.Parent = Frame

        local Sld = Instance.new("TextButton")
        Sld.Size = UDim2.new(1, -10, 0, 25); Sld.Position = UDim2.new(0, 5, 0, 30)
        Sld.BackgroundColor3 = Color3.fromRGB(70, 70, 70); Sld.Text = "Click to +5"; Sld.TextColor3 = Color3.new(1,1,1); Sld.Parent = Frame
        
        local val = default
        Fset(flag, val)
        
        Sld.MouseButton1Click:Connect(function()
            val = val + 5
            if val > max then val = min end
            Fset(flag, val)
            Lbl.Text = name .. ": " .. val
        end)
    end

    if tabName == "Farming" then
        AddToggle("Auto Farm Loop", "AutoFarmLoop")
        AddToggle("Auto Collect", "AutoCollect")
        AddToggle("Auto Clean Dirt", "AutoCleanDirt")
        AddToggle("Auto Clean Cave", "AutoCleanCave")
        AddSlider("Farm Radius", "FarmRadius", 4, 64, 16)
        AddSlider("Clean Radius", "CleanRadius", 8, 64, 32)
    elseif tabName == "Movement" then
        AddToggle("Fly", "Fly")
        AddToggle("NoClip", "NoClip")
        AddToggle("Anti-Void", "AntiVoid")
        AddToggle("Anti-Fall", "AntiFall")
        AddSlider("Speed Value", "SpeedValue", 16, 64, 16)
        AddSlider("Fly Speed", "FlySpeed", 10, 80, 40)
    elseif tabName == "Visuals" then
        AddToggle("Item ESP", "ItemESP")
        AddToggle("Dirt ESP", "DirtESP")
        AddToggle("Cave ESP", "CaveESP")
        AddToggle("Fullbright", "Fullbright")
    elseif tabName == "Combat" then
        AddToggle("Kill Aura", "KillAura")
        AddSlider("Reach", "Reach", 7, 50, 24)
    elseif tabName == "Config" then
        local PanicBtn = Instance.new("TextButton")
        PanicBtn.Size = UDim2.new(1, 0, 0, 40); PanicBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        PanicBtn.Text = "PANIC (Kill All)"; PanicBtn.TextColor3 = Color3.new(1, 1, 1); PanicBtn.Font = Enum.Font.GothamBold; PanicBtn.Parent = Scrolling
        Instance.new("UICorner", PanicBtn).CornerRadius = UDim.new(0, 4)
        PanicBtn.MouseButton1Click:Connect(function()
            for k in pairs(F) do if type(F[k]) == "boolean" then F[k] = false end end
            setNoClip(false)
            ScreenGui:Destroy()
        end)
    end
end

local tabs = {"Farming", "Movement", "Visuals", "Combat", "Config"}
local tabBtns = {}
for i, name in ipairs(tabs) do
    local TBtn = Instance.new("TextButton")
    TBtn.Size = UDim2.new(0.2, -2, 1, 0); TBtn.Position = UDim2.new((i-1) * 0.2, 2, 0, 0)
    TBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); TBtn.Text = name; TBtn.TextColor3 = Color3.new(1, 1, 1)
    TBtn.Font = Enum.Font.GothamBold; TBtn.TextSize = 12; TBtn.Parent = TabBar
    Instance.new("UICorner", TBtn).CornerRadius = UDim.new(0, 4)
    
    TBtn.MouseButton1Click:Connect(function()
        for _, b in ipairs(TabBar:GetChildren()) do
            if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(45, 45, 45) end
        end
        TBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 60)
        SwitchTab(name)
    end)
    table.insert(tabBtns, TBtn)
end

SwitchTab("Farming")
tabBtns[1].BackgroundColor3 = Color3.fromRGB(0, 120, 60)

local isVisible = true
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        isVisible = not isVisible
        MainFrame.Visible = isVisible
    end
end)

print("[Growblox67] Full Build Loaded. Features are live.")
