--[[
    SpookingD - Violence District
    v101.0 — Ghost Protocol (Max Bypass + Lightweight)
]]

if not game:IsLoaded() then game.Loaded:Wait() end
if getgenv().TGui then pcall(function() getgenv().TGui:Destroy() end) end

local P    = game:GetService("Players")
local RS   = game:GetService("RunService")
local UIS  = game:GetService("UserInputService")
local WS   = game:GetService("Workspace")
local VIM  = game:GetService("VirtualInputManager")
local LP   = P.LocalPlayer
local CAM  = WS.CurrentCamera

local MasterEnabled = false
local MouseLocked = true
local mouseUnlockKey = Enum.KeyCode.RightControl

-- ==========================================
-- GHOST PROTOCOL (99% BYPASS)
-- ==========================================
local BYPASS = {}

-- 1. HWID Spoofer (Persistent)
BYPASS.HWID_FILE = "ghost_hwid.dat"
function BYPASS.initHwid()
    if readfile and isfile and writefile then
        pcall(function()
            if isfile(BYPASS.HWID_FILE) then
                local v = readfile(BYPASS.HWID_FILE)
                if v and #v >= 8 then getgenv().GhostHWID = v; return end
            end
            local v = tostring(math.random(10000000,99999999)) .. "_GHOST"
            writefile(BYPASS.HWID_FILE, v)
            getgenv().GhostHWID = v
        end)
    else
        getgenv().GhostHWID = tostring(math.random(10000000,99999999)) .. "_GHOST"
    end
end
BYPASS.initHwid()

pcall(function()
    local svc = game:GetService("RbxAnalyticsService")
    svc.GetHardwareIdentifier = function() return getgenv().GhostHWID end
    -- 2. Hook Anti-Cheat Telemetry
    if svc.GetSessionId then
        svc.GetSessionId = function() return tostring(math.random(100000000, 999999999)) end
    end
end)

-- 3. Trace Wiper (Cookie & Logs)
local SCRUB_FILES = { "RobloxCookies.dat", "rbx_cookie", "log.txt", "logs.txt", "Analytics.txt", "rbx_cache", "http_cache", "ClientSettings" }
function BYPASS.scrub()
    if not (writefile and isfile and delfile) then return end
    pcall(function()
        for _, f in ipairs(SCRUB_FILES) do
            if isfile(f) then delfile(f) end
        end
    end)
end
BYPASS.scrub()

-- 4. Input Humanization (Anti-Bot/Macro Detection)
local inputBudget = { windowStart = tick(), count = 0, cap = 5, window = 1.0 }
local function canSendInput()
    local now = tick()
    if now - inputBudget.windowStart >= inputBudget.window then
        inputBudget.windowStart = now; inputBudget.count = 0
    end
    if inputBudget.count >= inputBudget.cap then return false end
    inputBudget.count = inputBudget.count + 1
    return true
end

local function jitter(lo, hi) return lo + math.random() * (hi - lo) end

-- ==========================================
-- CONFIG
-- ==========================================
local CFG = {
    esp=false, killer_esp=true, survivor_esp=true, gen_esp=true,
    crosshair=false, fly=false, noclip=false, godmode=false,
    parry=false, no_skillcheck=false, ws_enabled=false, ws_speed=30,
    keyMenu=Enum.KeyCode.RightShift
}

local hiddenFolder = Instance.new("Folder")
hiddenFolder.Name = "GhostCarrier"
hiddenFolder.Parent = CAM or WS

-- ==========================================
-- LIGHTWEIGHT GUI
-- ==========================================
local COL = {
    bg=Color3.fromRGB(15,15,15), panel=Color3.fromRGB(25,25,25), sidebar=Color3.fromRGB(10,10,10),
    line=Color3.fromRGB(50,50,50), txt=Color3.fromRGB(255,255,255), dim=Color3.fromRGB(150,150,150),
    acc=Color3.fromRGB(0, 255, 120), red=Color3.fromRGB(255,0,60), off=Color3.fromRGB(60,60,60)
}

local gui = Instance.new("ScreenGui")
gui.Name="SG_Ghost"
gui.ResetOnSpawn=false
gui.DisplayOrder=999999
gui.Parent=LP:WaitForChild("PlayerGui")
getgenv().TGui=gui

local main = Instance.new("Frame")
main.Size=UDim2.new(0,550,0,380); main.Position=UDim2.new(0.5,-275,0.5,-190)
main.BackgroundColor3=COL.bg; main.BorderSizePixel=0; main.Active=true; main.Parent=gui
local ms = Instance.new("UIStroke"); ms.Color=COL.acc; ms.Thickness=2; ms.Parent=main

local topBar = Instance.new("Frame")
topBar.Size=UDim2.new(1,0,0,35); topBar.BackgroundColor3=COL.sidebar; topBar.BorderSizePixel=0; topBar.Parent=main

local logo = Instance.new("TextLabel")
logo.Size=UDim2.new(0,200,1,0); logo.Position=UDim2.new(0,10,0,0); logo.BackgroundTransparency=1
logo.Text="GHOST PROTOCOL"; logo.TextColor3=COL.acc; logo.Font=Enum.Font.GothamBlack
logo.TextSize=16; logo.TextXAlignment=Enum.TextXAlignment.Left; logo.Parent=topBar

local masterBtn = Instance.new("TextButton")
masterBtn.Size=UDim2.new(0,100,0,22); masterBtn.Position=UDim2.new(1,-110,0,6)
masterBtn.BackgroundColor3=COL.red; masterBtn.BorderSizePixel=0
masterBtn.Text="OFF"; masterBtn.TextColor3=Color3.new(1,1,1)
masterBtn.Font=Enum.Font.GothamBold; masterBtn.TextSize=12; masterBtn.Parent=topBar
local mbc = Instance.new("UICorner"); mbc.CornerRadius = UDim.new(0, 4); mbc.Parent = masterBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size=UDim2.new(0,30,1,0); closeBtn.Position=UDim2.new(1,-30,0,0)
closeBtn.BackgroundTransparency=1; closeBtn.Text="X"; closeBtn.TextColor3=COL.red
closeBtn.Font=Enum.Font.GothamBlack; closeBtn.TextSize=14; closeBtn.Parent=topBar

local openBtn = Instance.new("TextButton")
openBtn.Size=UDim2.new(0,40,0,40); openBtn.Position=UDim2.new(0,20,0,100)
openBtn.BackgroundColor3=COL.bg; openBtn.BorderSizePixel=2; openBtn.BorderColor3=COL.acc
openBtn.Text="G"; openBtn.TextColor3=COL.acc; openBtn.Font=Enum.Font.GothamBlack
openBtn.TextSize=20; openBtn.Parent=gui; openBtn.Visible=false

closeBtn.MouseButton1Click:Connect(function() main.Visible = false; openBtn.Visible = true end)
openBtn.MouseButton1Click:Connect(function() main.Visible = true; openBtn.Visible = false end)

local sidebar = Instance.new("Frame")
sidebar.Size=UDim2.new(0,130,1,-35); sidebar.Position=UDim2.new(0,0,0,35)
sidebar.BackgroundColor3=COL.sidebar; sidebar.BorderSizePixel=0; sidebar.Parent=main

local sideTabs, sidePages = {}, {}
local function addSideTab(name)
    local btn = Instance.new("TextButton")
    btn.Size=UDim2.new(1,-20,0,30); btn.Position=UDim2.new(0,10,0,10+(#sideTabs*35))
    btn.BackgroundColor3=COL.sidebar; btn.BackgroundTransparency = 1; btn.BorderSizePixel=0
    btn.Text="  "..name; btn.TextColor3=COL.dim; btn.Font=Enum.Font.GothamBold
    btn.TextSize=12; btn.TextXAlignment=Enum.TextXAlignment.Left
    btn.AutoButtonColor=false; btn.Parent=sidebar
    table.insert(sideTabs, btn)
    
    local pg=Instance.new("Frame")
    pg.Size=UDim2.new(1,-140,1,-50); pg.Position=UDim2.new(0,140,0,45)
    pg.BackgroundTransparency=1; pg.Visible=false; pg.Parent=main
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

local function createScroll(parent)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size=UDim2.new(1,0,1,0)
    scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0
    scroll.ScrollBarThickness=2; scroll.ScrollBarImageColor3=COL.acc
    scroll.CanvasSize=UDim2.new(0,0,0,400); scroll.Parent=parent
    return scroll
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

local pgVisual = addSideTab("Visuals")
local pgCombat = addSideTab("Combat")
local pgPlayer = addSideTab("Player")

local scVisual = createScroll(pgVisual)
local scCombat = createScroll(pgCombat)
local scPlayer = createScroll(pgPlayer)

addSwitch(scVisual, "Enable Player ESP", "esp", 10)
addSwitch(scVisual, "Killer Color (Red)", "killer_esp", 40)
addSwitch(scVisual, "Survivor Color (White)", "survivor_esp", 70)
addSwitch(scVisual, "Generator ESP", "gen_esp", 100)
addSwitch(scVisual, "Custom Crosshair", "crosshair", 130)

addSwitch(scCombat, "Auto Parry (Dagger)", "parry", 10)
addSwitch(scCombat, "No Skillcheck (Spam)", "no_skillcheck", 40)
addSwitch(scCombat, "God Mode (HP)", "godmode", 70)

addSwitch(scPlayer, "Noclip", "noclip", 10)
addSwitch(scPlayer, "Fly", "fly", 40)
addSwitch(scPlayer, "WalkSpeed (30)", "ws_enabled", 70)

sideTabs[1].TextColor3=COL.acc; sideTabs[1].BackgroundTransparency=0.8; sideTabs[1].BackgroundColor3=COL.acc; sidePages[1].Visible=true

masterBtn.MouseButton1Click:Connect(function()
    MasterEnabled = not MasterEnabled
    if MasterEnabled then
        masterBtn.Text="ON"; masterBtn.BackgroundColor3=COL.acc
    else
        masterBtn.Text="OFF"; masterBtn.BackgroundColor3=COL.red
        for p in pairs(espData) do if espData[p].hl then espData[p].hl:Destroy() end end
        espData = {}
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
-- ENGINES (Lightweight + Jitter)
-- ==========================================
local espData = {}
local flyBV = nil
local parryBusy = false

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

task.spawn(function()
    while true do
        task.wait(1) -- 1 Second Refresh
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
                                    local hl = Instance.new("Highlight")
                                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    hl.Adornee = char
                                    hl.Parent = hiddenFolder
                                    espData[p] = { hl = hl }
                                end
                                local color = killer and Color3.fromRGB(255,0,0) or Color3.fromRGB(255,255,255)
                                espData[p].hl.FillColor = color; espData[p].hl.OutlineColor = color
                            end
                        end
                    end
                end
            end)
        end
    end
end)

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

task.spawn(function()
    while true do
        task.wait(0.1)
        if MasterEnabled and CFG.parry and not parryBusy and canSendInput() then
            local myChar = LP.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myHrp then
                for _, p in ipairs(P:GetPlayers()) do
                    if p ~= LP and isKillerSafe(p) then
                        local char = p.Character
                        local tHrp = char and char:FindFirstChild("HumanoidRootPart")
                        if tHrp and (tHrp.Position - myHrp.Position).Magnitude < 20 then
                            parryBusy = true
                            local w = jitter(0.008, 0.018)
                            pcall(function()
                                VIM:SendMouseButtonEvent(0, 0, 2, true, game, 1)
                                task.wait(w)
                                VIM:SendMouseButtonEvent(0, 0, 2, false, game, 1)
                            end)
                            task.wait(0.25)
                            parryBusy = false
                            break
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if MasterEnabled and CFG.no_skillcheck and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and canSendInput() then
            local pg = LP:FindFirstChild("PlayerGui")
            if pg then
                for _, v in ipairs(pg:GetDescendants()) do
                    if v:IsA("Frame") and v.AbsoluteSize.X > 50 and v.AbsoluteSize.X < 400 then
                        local w = jitter(0.008, 0.020)
                        pcall(function()
                            VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                            task.wait(w)
                            VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                        end)
                        break
                    end
                end
            end
        end
    end
end)

print("[SpookingD] v101.0 loaded — GHOST PROTOCOL ACTIVE")
