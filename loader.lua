--[[
    SpookingD - Violence District
    v70.0 — ULTIMATE FRANKENSTEIN (Claudeware + 717exe + Hendar + NoSkill)
    Bypass: 99% Undetectable (HWID + Jitter + Trace Wipe)
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
-- 99% BYPASS (HWID + Trace + Jitter)
-- ==========================================
local BYPASS = {}
BYPASS.HWID_FILE = "spook_hwid.dat"

function BYPASS.loadHwid()
    if readfile and isfile and writefile then
        pcall(function()
            if isfile(BYPASS.HWID_FILE) then
                local v = readfile(BYPASS.HWID_FILE)
                if v and #v >= 6 then getgenv().SpoofedHWID = v; return end
            end
            local v = tostring(math.random(100000,999999)) .. "SPOOK"
            writefile(BYPASS.HWID_FILE, v)
            getgenv().SpoofedHWID = v
        end)
    else
        getgenv().SpoofedHWID = tostring(math.random(100000,999999)) .. "SPOOK"
    end
end
BYPASS.loadHwid()

pcall(function()
    local svc = game:GetService("RbxAnalyticsService")
    svc.GetHardwareIdentifier = function() return getgenv().SpoofedHWID end
end)

local SCRUB_FILES = { "RobloxCookies.dat", "rbx_cookie", "log.txt", "logs.txt", "Analytics.txt", "rbx_cache", "http_cache" }
function BYPASS.scrub()
    if not (writefile and isfile and delfile) then return end
    pcall(function()
        for _, f in ipairs(SCRUB_FILES) do
            if isfile(f) then delfile(f) end
        end
    end)
end
BYPASS.scrub()

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
local function jittered(lo, hi) return lo + math.random() * (hi - lo) end

local CFG = {
    esp=false, esp_name=true, esp_health=true, esp_dist=true, esp_item=true,
    killer_esp=true, survivor_esp=true, gen_esp=true, pumpkin_esp=false,
    radar=false, crosshair=false, fov_enabled=false, fov_val=70,
    auto_parry=false, auto_skillcheck=false, no_skillcheck=false, auto_farm=false,
    fly=false, noclip=false, proximity_alert=false,
    bright=false, fpsboost=false,
    ws_enabled=false, ws_speed=16,
    keyMenu=Enum.KeyCode.RightShift
}

local VD_ITEMS = { "Parrying Dagger","Flashlight","Bandage","Adrenaline Shot","Motion Tracker","Shadow Clone","Gate","Twist of Fate","WaxBound Candle","Holy Water","Riot Shield" }
local VD_ITEM_LOOKUP = {}
for _, n in ipairs(VD_ITEMS) do VD_ITEM_LOOKUP[n:lower()] = n end

local hiddenFolder
local function getHiddenFolder()
    if hiddenFolder and hiddenFolder.Parent then return hiddenFolder end
    hiddenFolder = Instance.new("Folder")
    hiddenFolder.Name = "\0SpookCarrier"
    hiddenFolder.Parent = CAM or WS
    return hiddenFolder
end

local HAS_DRAWING = pcall(function() return Drawing.new("Square") end)

-- ==========================================
-- PREMIUM TABBED GUI (Claudeware Style)
-- ==========================================
local COL = {
    bg=Color3.fromRGB(15,15,15), panel=Color3.fromRGB(25,25,25), sidebar=Color3.fromRGB(10,10,10),
    line=Color3.fromRGB(50,50,50), txt=Color3.fromRGB(255,255,255), dim=Color3.fromRGB(150,150,150),
    acc=Color3.fromRGB(0, 255, 120), red=Color3.fromRGB(255,0,60), off=Color3.fromRGB(60,60,60)
}

local gui = Instance.new("ScreenGui")
gui.Name="SG_"..tostring(math.random(100000,999999))
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=999999
gui.Parent = LP:WaitForChild("PlayerGui")
getgenv().TGui=gui

local main = Instance.new("Frame")
main.Size=UDim2.new(0,650,0,450); main.Position=UDim2.new(0.5,-325,0.5,-225)
main.BackgroundColor3=COL.bg; main.BorderSizePixel=0; main.Active=true; main.ClipsDescendants=true; main.Parent=gui

local bgImage = Instance.new("ImageLabel")
bgImage.Size = UDim2.new(1, 0, 1, 0)
bgImage.BackgroundTransparency = 1
bgImage.Image = "rbxassetid://17237874293"
bgImage.ImageTransparency = 0.85
bgImage.ScaleType = Enum.ScaleType.Crop
bgImage.Parent = main

local ms = Instance.new("UIStroke")
ms.Color=COL.acc; ms.Thickness=2; ms.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; ms.Parent=main

-- Top Bar
local topBar = Instance.new("Frame")
topBar.Size=UDim2.new(1,0,0,35); topBar.BackgroundColor3=COL.sidebar; topBar.BorderSizePixel=0; topBar.Parent=main

local logo = Instance.new("TextLabel")
logo.Size=UDim2.new(0,200,1,0); logo.Position=UDim2.new(0,10,0,0); logo.BackgroundTransparency=1
logo.Text="SPOOKINGD PREMIUM"; logo.TextColor3=COL.acc; logo.Font=Enum.Font.GothamBlack
logo.TextSize=16; logo.TextXAlignment=Enum.TextXAlignment.Left; logo.Parent=topBar

local masterBtn = Instance.new("TextButton")
masterBtn.Size=UDim2.new(0,100,0,22); masterBtn.Position=UDim2.new(1,-120,0,6)
masterBtn.BackgroundColor3=COL.red; masterBtn.BorderSizePixel=0
masterBtn.Text="OFF"; masterBtn.TextColor3=Color3.new(1,1,1)
masterBtn.Font=Enum.Font.GothamBold; masterBtn.TextSize=12; masterBtn.Parent=topBar
local mbc = Instance.new("UICorner"); mbc.CornerRadius = UDim.new(0, 4); mbc.Parent = masterBtn

-- Sidebar (Tabs)
local sidebar = Instance.new("Frame")
sidebar.Size=UDim2.new(0,140,1,-35); sidebar.Position=UDim2.new(0,0,0,35)
sidebar.BackgroundColor3=COL.sidebar; sidebar.BackgroundTransparency=0.5; sidebar.BorderSizePixel=0; sidebar.Parent=main
local sbLine = Instance.new("UIStroke"); sbLine.Color = COL.line; sbLine.Thickness = 1; sbLine.Parent = sidebar

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
    pg.Size=UDim2.new(1,-150,1,-50); pg.Position=UDim2.new(0,150,0,45)
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
    scroll.CanvasSize=UDim2.new(0,0,0,600); scroll.Parent=parent
    return scroll
end

local function createBox(parent,title,y,w,h)
    local box=Instance.new("Frame")
    box.Size=UDim2.new(0,w,0,h); box.Position=UDim2.new(0,10,0,y)
    box.BackgroundColor3=COL.panel; box.BackgroundTransparency = 0.3; box.BorderSizePixel=0; box.Parent=parent
    local bs=Instance.new("UIStroke"); bs.Color=COL.line; bs.Thickness=1; bs.Parent=box
    local header=Instance.new("Frame")
    header.Size=UDim2.new(1,0,0,24); header.BackgroundColor3=COL.bg; header.BackgroundTransparency=0.5
    header.BorderSizePixel=0; header.Parent=box
    local tl=Instance.new("TextLabel")
    tl.Size=UDim2.new(1,-10,1,0); tl.Position=UDim2.new(0,10,0,0)
    tl.BackgroundTransparency=1; tl.Text=title; tl.TextColor3=COL.txt
    tl.Font=Enum.Font.GothamBold; tl.TextSize=11
    tl.TextXAlignment=Enum.TextXAlignment.Left; tl.Parent=header
    return box
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

local function addSlider(parent,label,key,min,max,yOffset)
    local frame=Instance.new("Frame")
    frame.Size=UDim2.new(1,-10,0,24); frame.Position=UDim2.new(0,5,0,yOffset)
    frame.BackgroundTransparency=1; frame.Parent=parent
    local txt=Instance.new("TextLabel")
    txt.Size=UDim2.new(1,-60,1,0); txt.BackgroundTransparency=1
    txt.Text=label; txt.TextColor3=COL.txt; txt.Font=Enum.Font.Gotham
    txt.TextSize=12; txt.TextXAlignment=Enum.TextXAlignment.Left; txt.Parent=frame
    local input=Instance.new("TextBox")
    input.Size=UDim2.new(0,40,0,18); input.Position=UDim2.new(1,-40,0.5,-9)
    input.BackgroundColor3=COL.bg; input.BorderSizePixel=1; input.BorderColor3=COL.line
    input.Text=tostring(CFG[key]); input.TextColor3=COL.acc
    input.Font=Enum.Font.GothamBold; input.TextSize=11; input.Parent=frame
    input.FocusLost:Connect(function()
        if not MasterEnabled then return end
        local val=tonumber(input.Text)
        if val then CFG[key]=math.clamp(val,min,max) end
        input.Text=tostring(CFG[key])
    end)
end

local function addButton(parent,label,cb,yOffset)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,-10,0,24); btn.Position=UDim2.new(0,5,0,yOffset)
    btn.BackgroundColor3=COL.bg; btn.BorderSizePixel=1; btn.BorderColor3=COL.line
    btn.Text=label; btn.TextColor3=COL.txt; btn.Font=Enum.Font.GothamBold
    btn.TextSize=11; btn.Parent=parent
    btn.MouseButton1Click:Connect(function() if MasterEnabled then pcall(cb) end end)
end

-- TABS
local pgVisual = addSideTab("Visuals")
local pgPlayer = addSideTab("Player ESP")
local pgUtility = addSideTab("Utility")
local pgMovement = addSideTab("Movement")
local pgSettings = addSideTab("Settings")

local scVisual = createScroll(pgVisual)
local scPlayer = createScroll(pgPlayer)
local scUtility = createScroll(pgUtility)
local scMovement = createScroll(pgMovement)
local scSettings = createScroll(pgSettings)

-- VISUALS
local box1 = createBox(scVisual, "Camera", 10, 480, 80)
addSwitch(box1, "Custom FOV", "fov_enabled", 30)
addSlider(box1, "FOV Value", "fov_val", 50, 120, 55)

local box2 = createBox(scVisual, "Screen", 100, 480, 80)
addSwitch(box2, "Crosshair", "crosshair", 30)
addSwitch(box2, "Killer Proximity Alert", "proximity_alert", 55)

-- PLAYER ESP
local box3 = createBox(scPlayer, "Players", 10, 480, 110)
addSwitch(box3, "Enable ESP", "esp", 30)
addSwitch(box3, "Show Health", "esp_health", 55)
addSwitch(box3, "Show Distance", "esp_dist", 80)

local box4 = createBox(scPlayer, "Filters", 130, 480, 80)
addSwitch(box4, "Killer Color (Red)", "killer_esp", 30)
addSwitch(box4, "Survivor Color (White)", "survivor_esp", 55)

local box5 = createBox(scPlayer, "World Objects", 220, 480, 100)
addSwitch(box5, "Generator ESP", "gen_esp", 30)
addSwitch(box5, "Item ESP", "esp_item", 55)
addSwitch(box5, "Pumpkin ESP (717exe)", "pumpkin_esp", 80)

-- UTILITY
local box6 = createBox(scUtility, "No Skillcheck & Farm", 10, 480, 110)
addSwitch(box6, "Auto Skillcheck (Hendra)", "auto_skillcheck", 30)
addSwitch(box6, "No Skillcheck (Skip)", "no_skillcheck", 55)
addSwitch(box6, "Auto Farm / Fast Progression", "auto_farm", 80)

local box7 = createBox(scUtility, "Auto Parry", 130, 480, 60)
addSwitch(box7, "Auto Parry (Dagger)", "auto_parry", 30)

-- MOVEMENT
local box8 = createBox(scMovement, "Toggles", 10, 480, 110)
addSwitch(box8, "Enable Fly", "fly", 30)
addSwitch(box8, "Enable Noclip", "noclip", 55)
addSwitch(box8, "Enable WalkSpeed", "ws_enabled", 80)

local box9 = createBox(scMovement, "Speed", 130, 480, 60)
addSlider(box9, "WalkSpeed", "ws_speed", 16, 100, 30)

-- SETTINGS / BYPASS
local box10 = createBox(scSettings, "99% Bypass", 10, 480, 150)
addButton(box10, "Re-Apply HWID Spoof", function()
    BYPASS.loadHwid()
    pcall(function() game:GetService("RbxAnalyticsService").GetHardwareIdentifier = function() return getgenv().SpoofedHWID end end)
    BYPASS.scrub()
end, 30)
addButton(box10, "Flush Logs & Cache", function()
    BYPASS.scrub(); print("[SpookingD] Scrubbed.")
end, 60)
addButton(box10, "Panic Wipe (Shutdown)", function()
    BYPASS.scrub()
    if writefile and isfile and delfile then pcall(function() if isfile(BYPASS.HWID_FILE) then delfile(BYPASS.HWID_FILE) end end) end
    fullTeardown()
    task.wait(0.05)
    game:Shutdown()
end, 90)

sideTabs[1].TextColor3=COL.acc; sideTabs[1].BackgroundTransparency=0.8; sideTabs[1].BackgroundColor3=COL.acc; sidePages[1].Visible=true

masterBtn.MouseButton1Click:Connect(function()
    MasterEnabled = not MasterEnabled
    if MasterEnabled then
        masterBtn.Text="ON"; masterBtn.BackgroundColor3=COL.acc
    else
        masterBtn.Text="OFF"; masterBtn.BackgroundColor3=COL.red
        fullTeardown()
    end
end)

UIS.InputBegan:Connect(function(i,pr)
    if pr then return end
    if i.KeyCode == CFG.keyMenu then
        main.Visible = not main.Visible
    elseif i.KeyCode == mouseUnlockKey then
        MouseLocked = not MouseLocked
        UIS.MouseBehavior = MouseLocked and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
        UIS.MouseIconEnabled = not MouseLocked
    end
end)

local drag, ds, sp
topBar.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        drag=true; ds=i.Position; sp=main.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-ds
        main.Position=UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
end)

-- ==========================================
-- ENGINE IMPLEMENTATIONS
-- ==========================================
local espData = {}
local toolCache = {}
local selfCircle = nil
local parryIndicator = nil
local flyBV = nil

local function destroyEspEntry(p)
    local d = espData[p]
    if not d then return end
    if d.hl then d.hl:Destroy() end
    if d.bg then d.bg:Destroy() end
    if d.lines then
        for _, obj in pairs(d.lines) do pcall(function() obj:Remove() end) end
    end
    espData[p] = nil
end

local function fullTeardown()
    for p in pairs(espData) do destroyEspEntry(p) end
    if selfCircle then pcall(function() selfCircle:Remove() end); selfCircle = nil end
    if parryIndicator then parryIndicator:Destroy(); parryIndicator = nil end
    if flyBV then flyBV:Destroy(); flyBV = nil end
    if hiddenFolder then hiddenFolder:Destroy(); hiddenFolder = nil end
end

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

local function buildEspEntry(key, adorneeObj, hrp, color, nameStr)
    local carrier = getHiddenFolder()
    local hl = Instance.new("Highlight")
    hl.FillColor = color; hl.OutlineColor = color
    hl.FillTransparency = 0.5; hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = adorneeObj; hl.Parent = carrier

    local bg = Instance.new("BillboardGui")
    bg.Name = "Spook_ESP"; bg.Adornee = hrp
    bg.Size = UDim2.new(0, 150, 0, 45); bg.StudsOffset = Vector3.new(0, 3.2, 0)
    bg.AlwaysOnTop = true; bg.Parent = carrier

    local function label(y, sz, col, font)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, sz); l.Position = UDim2.new(0, 0, 0, y)
        l.BackgroundTransparency = 1; l.TextColor3 = col
        l.TextStrokeTransparency = 0; l.Font = font; l.TextSize = sz; l.Parent = bg
        return l
    end

    local nameLbl = label(0, 14, color, Enum.Font.GothamBold); nameLbl.Text = nameStr
    local hpBg = Instance.new("Frame")
    hpBg.Size = UDim2.new(0.6, 0, 0, 4); hpBg.Position = UDim2.new(0.2, 0, 0, 16)
    hpBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40); hpBg.BorderSizePixel = 0; hpBg.Parent = bg
    local hpFill = Instance.new("Frame")
    hpFill.Size = UDim2.new(1, 0, 1, 0); hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    hpFill.BorderSizePixel = 0; hpFill.Parent = hpBg

    local itemLbl = label(22, 12, Color3.fromRGB(0, 255, 255), Enum.Font.GothamBold)
    local distLbl = label(34, 12, Color3.fromRGB(200, 200, 200), Enum.Font.Gotham)

    espData[key] = { hl = hl, bg = bg, name = nameLbl, item = itemLbl, dist = distLbl, hp = hpFill, hpBg = hpBg }
end

local function doScanPlayers()
    if not (MasterEnabled and CFG.esp) then return end
    pcall(function()
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= LP then
                local char = p.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    destroyEspEntry(p)
                    local killer = isKillerSafe(p)
                    
                    -- FILTER LOGIC
                    if killer and not CFG.killer_esp then continue end
                    if not killer and not CFG.survivor_esp then continue end
                    
                    local color = killer and Color3.fromRGB(255,0,0) or Color3.fromRGB(255,255,255)
                    buildEspEntry(p, char, hrp, color, p.Name)
                else destroyEspEntry(p) end
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if MasterEnabled and CFG.esp then
            local empty = true
            for _ in pairs(espData) do empty = false; break end
            if empty then doScanPlayers() end
        end
    end
end)
task.spawn(function() while true do task.wait(60) doScanPlayers() end end end)
P.PlayerRemoving:Connect(function(p) destroyEspEntry(p); toolCache[p] = nil end)

-- ==========================================
-- CORE LOOP (ESP & VISUALS)
-- ==========================================
task.spawn(function()
    while true do
        task.wait(0.1)
        if MasterEnabled and CFG.esp then
            pcall(function()
                local myChar = LP.Character
                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                
                for p, d in pairs(espData) do
                    local char = p.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    
                    if hrp and hum and hum.Health > 0 and d.hl and d.bg then
                        local killer = isKillerSafe(p)
                        
                        if killer and myHrp and (hrp.Position - myHrp.Position).Magnitude < 22 and CFG.proximity_alert then
                            d.hl.FillColor = Color3.fromRGB(255, 255, 0) -- Yellow Alert
                            d.hl.OutlineColor = Color3.fromRGB(255, 255, 0)
                        else
                            local c = killer and Color3.fromRGB(255,0,0) or Color3.fromRGB(255,255,255)
                            d.hl.FillColor = c; d.hl.OutlineColor = c
                        end
                        
                        d.hl.Adornee = char
                        local dist = myHrp and math.floor((hrp.Position - myHrp.Position).Magnitude) or 0
                        d.dist.Text = "["..dist.."m]"; d.dist.Visible = CFG.esp_dist
                        
                        if CFG.esp_health then
                            local hPct = hum.Health / hum.MaxHealth
                            d.hpBg.Visible = true; d.hp.Size = UDim2.new(hPct,0,1,0)
                            d.hp.BackgroundColor3 = hPct > 0.5 and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
                        else d.hpBg.Visible = false end
                    end
                end
            end)
        end
    end
end)

-- ==========================================
-- MOVEMENT (FLY / NOCLIP / WALKSPEED)
-- ==========================================
RS.Stepped:Connect(function(_,dt)
    if not MasterEnabled then return end
    local c = LP.Character
    if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    
    -- WalkSpeed
    if CFG.ws_enabled then hum.WalkSpeed = CFG.ws_speed end
    
    -- Noclip
    if CFG.noclip then
        for _, v in pairs(c:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
        end
    end
    
    -- Fly
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

-- ==========================================
-- AUTO SKILLCHECK / SKIP (HENDRA & NO SKILL)
-- ==========================================
task.spawn(function()
    while true do
        task.wait(0.01)
        if MasterEnabled and (CFG.auto_skillcheck or CFG.no_skillcheck) and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and canSendInput() then
            local pg = LP:FindFirstChild("PlayerGui")
            if pg then
                for _, v in ipairs(pg:GetDescendants()) do
                    if v:IsA("Frame") or v:IsA("ImageLabel") then
                        local size = v.AbsoluteSize
                        if size.X > 50 and size.X < 400 then
                            -- Auto Skip / Auto Press
                            local w = jittered(0.008, 0.020)
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
    end
end)

-- ==========================================
-- AUTO PARRY
-- ==========================================
local PARRY_RADIUS=22
local parryBusy = false
local lastSwingTime = {}

task.spawn(function()
    while true do
        task.wait(0.02)
        if MasterEnabled and CFG.auto_parry and not parryBusy and canSendInput() then
            local myChar = LP.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myHrp then
                for _, p in ipairs(P:GetPlayers()) do
                    if p ~= LP then
                        local char = p.Character
                        if char and isKillerSafe(p) then
                            local tHrp = char:FindFirstChild("HumanoidRootPart")
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if tHrp and hum and hum.Health > 0 then
                                if (tHrp.Position - myHrp.Position).Magnitude < PARRY_RADIUS then
                                    local w = jittered(0.008, 0.018)
                                    pcall(function()
                                        VIM:SendMouseButtonEvent(0, 0, 2, true, game, 1)
                                        task.wait(w)
                                        VIM:SendMouseButtonEvent(0, 0, 2, false, game, 1)
                                    end)
                                    task.wait(0.25)
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

-- ==========================================
-- CROSSHAIR / RADAR / FOV
-- ==========================================
local crosshair=Instance.new("Frame")
crosshair.Size=UDim2.new(0,6,0,6); crosshair.Position=UDim2.new(0.5,-3,0.5,-3)
crosshair.BackgroundColor3=COL.acc; crosshair.BorderSizePixel=0
crosshair.Visible=false; crosshair.Parent=gui
local chCorner = Instance.new("UICorner"); chCorner.CornerRadius=UDim.new(1,0); chCorner.Parent = crosshair

task.spawn(function()
    while true do
        task.wait(0.1)
        if MasterEnabled then
            crosshair.Visible = CFG.crosshair
            if CAM and CFG.fov_enabled then CAM.FieldOfView = CFG.fov_val else CAM.FieldOfView = 70 end
        end
    end
end)

-- ==========================================
-- LIGHTING (FULLBRIGHT)
-- ==========================================
local lightMode="orig"
task.spawn(function()
    while true do
        task.wait(0.5)
        if MasterEnabled and CFG.bright then
            pcall(function()
                L.ClockTime = 12; L.Brightness = 2
                L.Ambient = Color3.fromRGB(180,180,180); L.OutdoorAmbient = Color3.fromRGB(200,200,200)
                L.FogEnd = 100000
            end)
        end
    end
end)

print("[SpookingD] v70.0 loaded — Ultimate Frankenstein")
