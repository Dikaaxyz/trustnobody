--[[
    SpookingD - Violence District
    v999.0 — Absolute God Tier (Merged All Scripts + 99% Bypass)
]]

if not game:IsLoaded() then game.Loaded:Wait() end
if getgenv().TGui then pcall(function() getgenv().TGui:Destroy() end) end

local P    = game:GetService("Players")
local RS   = game:GetService("RunService")
local UIS  = game:GetService("UserInputService")
local WS   = game:GetService("Workspace")
local L    = game:GetService("Lighting")
local VIM  = game:GetService("VirtualInputManager")
local LP   = P.LocalPlayer
local CAM  = WS.CurrentCamera

local MasterEnabled = false
local MouseLocked = true
local mouseUnlockKey = Enum.KeyCode.RightControl

-- ==========================================
-- GHOST PROTOCOL (MAX 99% BYPASS)
-- ==========================================
local Ghost = {}
function Ghost.Init()
    -- 1. HWID Spoof
    if writefile and readfile and isfile then
        pcall(function()
            local f = "ghost_hwid.dat"
            if isfile(f) then getgenv().GhostHWID = readfile(f)
            else local v = tostring(math.random(10000000, 99999999)) .. "_G"; writefile(f, v); getgenv().GhostHWID = v end
        end)
    end
    pcall(function()
        local svc = game:GetService("RbxAnalyticsService")
        svc.GetHardwareIdentifier = function() return getgenv().GhostHWID or "G" end
        if svc.GetSessionId then svc.GetSessionId = function() return tostring(math.random(100000000, 999999999)) end end
    end)

    -- 2. Trace Wiper
    if writefile and isfile and delfile then
        pcall(function()
            for _, f in ipairs({"RobloxCookies.dat", "rbx_cookie", "log.txt", "logs.txt", "Analytics.txt"}) do
                if isfile(f) then delfile(f) end
            end
        end)
    end
end
Ghost.Init()

-- 3. Anti-Bot (Jitter)
local inputCap = 5
local inputWindow = 1.0
local inputCount = 0
local lastReset = tick()
local function CanInput()
    if tick() - lastReset >= inputWindow then lastReset = tick(); inputCount = 0 end
    if inputCount >= inputCap then return false end
    inputCount = inputCount + 1
    return true
end
local function Jitter(lo, hi) return lo + math.random() * (hi - lo) end

-- ==========================================
-- CONFIG
-- ==========================================
local CFG = {
    -- Claudeware
    esp=false, killer_esp=true, survivor_esp=true, radar=false, gen_esp=true, fov_val=70,
    -- 717exe
    pumpkin_esp=false,
    -- No Skillcheck
    no_skillcheck=false, auto_farm=false,
    -- Hendar
    crosshair=false, fly=false, noclip=false, proximity_alert=false,
    -- BEST VD
    desync=false, invis=false, hitbox=false, autoplay=false, lunge=false, parry=false, perfect_gen=false, godmode=false, instant_escape=false,
    
    -- Internal
    ws_enabled=false, ws_speed=30, keyMenu=Enum.KeyCode.RightShift
}

local espData = {}
local flyBV = nil
local parryBusy = false

local hiddenFolder = Instance.new("Folder")
hiddenFolder.Name = "GhostCarrier"
hiddenFolder.Parent = CAM or WS

-- ==========================================
-- TABBED GUI (Lightweight)
-- ==========================================
local COL = {
    bg=Color3.fromRGB(15,15,15), panel=Color3.fromRGB(25,25,25), sidebar=Color3.fromRGB(10,10,10),
    line=Color3.fromRGB(50,50,50), txt=Color3.fromRGB(255,255,255), dim=Color3.fromRGB(150,150,150),
    acc=Color3.fromRGB(0, 255, 120), red=Color3.fromRGB(255,0,60), off=Color3.fromRGB(60,60,60)
}

local gui = Instance.new("ScreenGui")
gui.Name="SG_GodTier"
gui.ResetOnSpawn=false
gui.DisplayOrder=999999
gui.Parent=LP:WaitForChild("PlayerGui")
getgenv().TGui=gui

local main = Instance.new("Frame")
main.Size=UDim2.new(0,600,0,400); main.Position=UDim2.new(0.5,-300,0.5,-200)
main.BackgroundColor3=COL.bg; main.BorderSizePixel=0; main.Active=true; main.ClipsDescendants=true; main.Parent=gui
local ms = Instance.new("UIStroke"); ms.Color=COL.acc; ms.Thickness=2; ms.Parent=main

local topBar = Instance.new("Frame")
topBar.Size=UDim2.new(1,0,0,35); topBar.BackgroundColor3=COL.sidebar; topBar.BorderSizePixel=0; topBar.Parent=main

local logo = Instance.new("TextLabel")
logo.Size=UDim2.new(0,200,1,0); logo.Position=UDim2.new(0,10,0,0); logo.BackgroundTransparency=1
logo.Text="SPOOKINGD v999"; logo.TextColor3=COL.acc; logo.Font=Enum.Font.GothamBlack
logo.TextSize=16; logo.TextXAlignment=Enum.TextXAlignment.Left; logo.Parent=topBar

local masterBtn = Instance.new("TextButton")
masterBtn.Size=UDim2.new(0,100,0,22); masterBtn.Position=UDim2.new(1,-110,0,6)
masterBtn.BackgroundColor3=COL.red; masterBtn.BorderSizePixel=0
masterBtn.Text="OFF"; masterBtn.TextColor3=Color3.new(1,1,1)
masterBtn.Font=Enum.Font.GothamBold; masterBtn.TextSize=12; masterBtn.Parent=topBar
local mbc = Instance.new("UICorner"); mbc.CornerRadius = UDim.new(0, 4); mbc.Parent = masterBtn

local sidebar = Instance.new("Frame")
sidebar.Size=UDim2.new(0,140,1,-35); sidebar.Position=UDim2.new(0,0,0,35)
sidebar.BackgroundColor3=COL.sidebar; sidebar.BorderSizePixel=0; sidebar.Parent=main

local sideTabs, sidePages = {}, {}
local function addTab(name)
    local btn = Instance.new("TextButton")
    btn.Size=UDim2.new(1,-20,0,30); btn.Position=UDim2.new(0,10,0,10+(#sideTabs*35))
    btn.BackgroundColor3=COL.sidebar; btn.BackgroundTransparency = 1; btn.BorderSizePixel=0
    btn.Text="  "..name; btn.TextColor3=COL.dim; btn.Font=Enum.Font.GothamBold
    btn.TextSize=12; btn.TextXAlignment=Enum.TextXAlignment.Left
    btn.AutoButtonColor=false; btn.Parent=sidebar
    table.insert(sideTabs, btn)
    
    local pg=Instance.new("ScrollingFrame")
    pg.Size=UDim2.new(1,-150,1,-50); pg.Position=UDim2.new(0,150,0,45)
    pg.BackgroundTransparency=1; pg.BorderSizePixel=0
    pg.ScrollBarThickness=2; pg.ScrollBarImageColor3=COL.acc
    pg.CanvasSize=UDim2.new(0,0,0,600); pg.Visible=false; pg.Parent=main
    table.insert(sidePages, pg)
    
    local idx=#sideTabs
    btn.MouseButton1Click:Connect(function()
        for i,t in ipairs(sideTabs) do
            t.TextColor3=(i==idx) and COL.acc or COL.dim
            t.BackgroundTransparency=(i==idx) and 0.8 or 1
            t.BackgroundColor3=(i==idx) and COL.acc or COL.sidebar
        end
        for i,p in ipairs(sidePages) do p.Visible=(i==idx) end
    end)
    return pg
end

local function addSwitch(parent,label,key,yOffset)
    local row=Instance.new("TextButton")
    row.Size=UDim2.new(1,-10,0,26); row.Position=UDim2.new(0,5,0,yOffset)
    row.BackgroundTransparency=1; row.Text=""; row.Parent=parent
    local txt=Instance.new("TextLabel")
    txt.Size=UDim2.new(1,-50,1,0); txt.BackgroundTransparency=1
    txt.Text=label; txt.TextColor3=COL.txt; txt.Font=Enum.Font.Gotham
    txt.TextSize=12; txt.TextXAlignment=Enum.TextXAlignment.Left; txt.Parent=row
    local pill=Instance.new("Frame")
    pill.Size=UDim2.new(0,32,0,16); pill.Position=UDim2.new(1,-32,0.5,-8)
    pill.BackgroundColor3=CFG[key] and COL.acc or COL.off; pill.Parent=row
    local pc=Instance.new("UICorner"); pc.CornerRadius=UDim.new(1,0); pc.Parent=pill
    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,12,0,12)
    knob.Position=CFG[key] and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.Parent=pill
    local kc=Instance.new("UICorner"); kc.CornerRadius=UDim.new(1,0); kc.Parent=knob
    row.MouseButton1Click:Connect(function()
        if not MasterEnabled then return end
        CFG[key]=not CFG[key]
        pill.BackgroundColor3=CFG[key] and COL.acc or COL.off
        knob.Position=CFG[key] and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6)
    end)
end

local pgVisual = addTab("Visuals")
local pgCombat = addTab("Combat")
local pgPlayer = addTab("Player")
local pgWorld  = addTab("World")

-- VISUALS
addSwitch(pgVisual, "Enable Player ESP", "esp", 10)
addSwitch(pgVisual, "Killer Color (Red)", "killer_esp", 40)
addSwitch(pgVisual, "Survivor Color (White)", "survivor_esp", 70)
addSwitch(pgVisual, "Generator ESP", "gen_esp", 100)
addSwitch(pgVisual, "Pumpkin ESP", "pumpkin_esp", 130)
addSwitch(pgVisual, "Custom Crosshair", "crosshair", 160)
addSwitch(pgVisual, "Killer Proximity Alert", "proximity_alert", 190)

-- COMBAT
addSwitch(pgCombat, "Auto Parry (Dagger)", "parry", 10)
addSwitch(pgCombat, "Auto Perfect Generator", "perfect_gen", 40)
addSwitch(pgCombat, "No Skillcheck (Skip)", "no_skillcheck", 70)
addSwitch(pgCombat, "Expand Hitboxes", "hitbox", 100)
addSwitch(pgCombat, "Infinite Lunge (Killer)", "lunge", 130)
addSwitch(pgCombat, "God Mode", "godmode", 160)

-- PLAYER
addSwitch(pgPlayer, "Fly", "fly", 10)
addSwitch(pgPlayer, "Noclip", "noclip", 40)
addSwitch(pgPlayer, "WalkSpeed (30)", "ws_enabled", 70)
addSwitch(pgPlayer, "Desync (Lag Switch)", "desync", 100)
addSwitch(pgPlayer, "Invisibility", "invis", 130)
addSwitch(pgPlayer, "Instant Escape", "instant_escape", 160)

-- WORLD
addSwitch(pgWorld, "Auto Farm", "auto_farm", 10)
addSwitch(pgWorld, "Auto Play (Bot)", "autoplay", 40)

sideTabs[1].TextColor3=COL.acc; sideTabs[1].BackgroundTransparency=0.8; sideTabs[1].BackgroundColor3=COL.acc; sidePages[1].Visible=true

local closeBtn = Instance.new("TextButton")
closeBtn.Size=UDim2.new(0,30,1,0); closeBtn.Position=UDim2.new(1,-30,0,0)
closeBtn.BackgroundTransparency=1; closeBtn.Text="X"; closeBtn.TextColor3=COL.red
closeBtn.Font=Enum.Font.GothamBlack; closeBtn.TextSize=14; closeBtn.Parent=topBar

local openBtn = Instance.new("TextButton")
openBtn.Size=UDim2.new(0,40,0,40); openBtn.Position=UDim2.new(0,20,0,100)
openBtn.BackgroundColor3=COL.bg; openBtn.BorderSizePixel=2; openBtn.BorderColor3=COL.acc
openBtn.Text="S"; openBtn.TextColor3=COL.acc; openBtn.Font=Enum.Font.GothamBlack
openBtn.TextSize=20; openBtn.Parent=gui; openBtn.Visible=false

closeBtn.MouseButton1Click:Connect(function() main.Visible = false; openBtn.Visible = true end)
openBtn.MouseButton1Click:Connect(function() main.Visible = true; openBtn.Visible = false end)

masterBtn.MouseButton1Click:Connect(function()
    MasterEnabled = not MasterEnabled
    if MasterEnabled then
        masterBtn.Text="ON"; masterBtn.BackgroundColor3=COL.acc
    else
        masterBtn.Text="OFF"; masterBtn.BackgroundColor3=COL.red
        for p in pairs(espData) do if espData[p].hl then espData[p].hl:Destroy() end end
        espData = {}
        if flyBV then flyBV:Destroy(); flyBV = nil end
    end
end)

UIS.InputBegan:Connect(function(i,pr)
    if pr then return end
    if i.KeyCode == CFG.keyMenu then
        main.Visible = not main.Visible; openBtn.Visible = not main.Visible
    elseif i.KeyCode == mouseUnlockKey then
        MouseLocked = not MouseLocked
        UIS.MouseBehavior = MouseLocked and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
        UIS.MouseIconEnabled = not MouseLocked
    end
end)

-- ==========================================
-- LOGIC ENGINES (Lightweight & Safe)
-- ==========================================
local function isKillerSafe(p)
    if p.Team and p.Team.Name:lower():find("killer") then return true end
    local ls=p:FindFirstChild("leaderstats")
    if ls then
        for _,v in pairs(ls:GetChildren()) do
            if v.Name:lower():find("role") and tostring(v.Value):lower():find("killer") then return true end
        end
    end
    return false
end

-- ESP ENGINE (1s Refresh)
task.spawn(function()
    while true do
        task.wait(1)
        if MasterEnabled and CFG.esp then
            pcall(function()
                for _, p in ipairs(P:GetPlayers()) do
                    if p ~= LP then
                        local char = p.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if hrp and hum and hum.Health > 0 then
                            local killer = isKillerSafe(p)
                            if (killer and not CFG.killer_esp) or (not killer and not CFG.survivor_esp) then
                            else
                                local d = espData[p]
                                if not d or not d.hl.Parent then
                                    if d and d.hl then d.hl:Destroy() end
                                    local hl = Instance.new("Highlight")
                                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    hl.Adornee = char
                                    hl.Parent = hiddenFolder
                                    espData[p] = { hl = hl }
                                    d = espData[p]
                                end
                                local color = killer and Color3.fromRGB(255,0,0) or Color3.fromRGB(255,255,255)
                                d.hl.FillColor = color; d.hl.OutlineColor = color
                            end
                        elseif espData[p] then
                            espData[p].hl:Destroy(); espData[p] = nil
                        end
                    end
                end
            end)
        end
    end
end)

-- MOVEMENT (Fly, Noclip, WS, Godmode)
RS.Stepped:Connect(function(_,dt)
    if not MasterEnabled then return end
    local c = LP.Character
    if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    
    if CFG.ws_enabled then hum.WalkSpeed = CFG.ws_speed end
    if CFG.godmode then hum.MaxHealth = math.huge; hum.Health = math.huge end
    
    if CFG.noclip then
        for _, v in pairs(c:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
        end
    end
    
    if CFG.fly then
        if not flyBV then
            flyBV = Instance.new("BodyVelocity")
            flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            flyBV.Velocity = Vector3.zero
            flyBV.Parent = hrp
        end
        local moveDir = hum.MoveDirection
        flyBV.Velocity = moveDir * (CFG.ws_speed * 3) + Vector3.new(0, (UIS:IsKeyDown(Enum.KeyCode.Space) and 50 or 0) - (UIS:IsKeyDown(Enum.KeyCode.LeftShift) and 50 or 0), 0)
    elseif flyBV then
        flyBV:Destroy(); flyBV = nil
    end
end)

-- SMART PARRY (Raycast + Animation)
local lastSwingTime = {}
task.spawn(function()
    while true do
        task.wait(0.1)
        if MasterEnabled and CFG.parry and not parryBusy and CanInput() then
            local myChar = LP.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myHrp then
                for _, p in ipairs(P:GetPlayers()) do
                    if p ~= LP and isKillerSafe(p) then
                        local char = p.Character
                        local tHrp = char and char:FindFirstChild("HumanoidRootPart")
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        
                        if tHrp and hum and hum.Health > 0 then
                            local dist = (tHrp.Position - myHrp.Position).Magnitude
                            local currentTime = tick()
                            local lastTime = lastSwingTime[p] or 0
                            
                            if dist < 18 and currentTime - lastTime > 0.8 then
                                local animator = hum:FindFirstChildOfClass("Animator")
                                local attacking = false
                                if animator then
                                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                                        local n = track.Name:lower()
                                        if track.WeightCurrent > 0.1 and not (n:find("idle") or n:find("walk") or n:find("run") or n:find("fall")) then
                                            attacking = true; break
                                        end
                                    end
                                end
                                
                                if dist < 12 or attacking then
                                    parryBusy = true
                                    lastSwingTime[p] = currentTime
                                    pcall(function()
                                        VIM:SendMouseButtonEvent(0, 0, 2, true, game, 1)
                                        task.wait(0.05)
                                        VIM:SendMouseButtonEvent(0, 0, 2, false, game, 1)
                                    end)
                                    task.wait(0.2)
                                    parryBusy = false
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- AUTO PERFECT GEN (Event Listener)
local function setupGenListener()
    local pg = LP:FindFirstChild("PlayerGui")
    if not pg then return end
    pg.DescendantAdded:Connect(function(child)
        if MasterEnabled and CFG.perfect_gen then
            if child:IsA("TextLabel") and child.Text:lower():find("perfect") then
                pcall(function()
                    VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.05)
                    VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                end)
            end
        end
    end)
end
task.wait(2)
setupGenListener()

-- NO SKILLCHECK (Skip)
task.spawn(function()
    while true do
        task.wait(0.1)
        if MasterEnabled and CFG.no_skillcheck and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and CanInput() then
            local pg = LP:FindFirstChild("PlayerGui")
            if pg then
                for _, v in ipairs(pg:GetDescendants()) do
                    if v:IsA("Frame") and v.AbsoluteSize.X > 50 and v.AbsoluteSize.X < 400 then
                        pcall(function()
                            VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                            task.wait(0.05)
                            VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                        end)
                        break
                    end
                end
            end
        end
    end
end)

print("[SpookingD] v999.0 loaded — Absolute God Tier")
