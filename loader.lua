--[[
    SpookingD - Violence District
    v60.5 — full assembled: outline ESP, aimed skillcheck, right-click parry, hardened bypass
]]

if not game:IsLoaded() then game.Loaded:Wait() end
if getgenv().TGui then pcall(function() getgenv().TGui:Destroy() end) end

local P    = game:GetService("Players")
local RS   = game:GetService("RunService")
local UIS  = game:GetService("UserInputService")
local WS   = game:GetService("Workspace")
local CG   = game:GetService("CoreGui")
local L    = game:GetService("Lighting")
local VIM  = game:GetService("VirtualInputManager")
local LP   = P.LocalPlayer
local CAM  = WS.CurrentCamera

local MasterEnabled = false

local CFG = {
    esp=false, esp_name=true, esp_health=true, esp_dist=true, esp_item=true,
    gen_esp=false, killer_esp=false, item_esp=false, exit_esp=false,
    bright=false, fpsboost=false,
    crosshair=false, fov_enabled=false, fov_val=70, hitbox_expand=false,
    auto_parry=false, auto_skillcheck=false,
    skillcheck_window=4.5, parry_cooldown=0.35,
    look_lock=false, ws_enabled=false, ws_speed=16,
    keyMenu=Enum.KeyCode.RightShift
}

local VD_ITEMS = {
    "Parrying Dagger","Flashlight","Bandage","Adrenaline Shot",
    "Motion Tracker","Shadow Clone","Gate","Twist of Fate",
    "WaxBound Candle","Holy Water","Riot Shield"
}
local VD_ITEM_LOOKUP = {}
for _, n in ipairs(VD_ITEMS) do VD_ITEM_LOOKUP[n:lower()] = n end

-- ==========================================
-- BYPASS
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

local SCRUB_FILES = { "RobloxCookies.dat", "rbx_cookie", "log.txt", "logs.txt", "Analytics.txt" }
function BYPASS.scrub()
    if not (writefile and isfile and delfile) then return end
    pcall(function()
        for _, f in ipairs(SCRUB_FILES) do
            if isfile(f) then delfile(f) end
        end
    end)
end
BYPASS.scrub()

local inputBudget = { windowStart = tick(), count = 0, cap = 6, window = 1.0 }
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

-- ==========================================
-- GUI
-- ==========================================
local function getHui()
    if typeof(gethui) == "function" then
        local ok, h = pcall(gethui); if ok and h then return h end
    end
    return CG
end

local COL = {
    bg=Color3.fromRGB(15,15,15), panel=Color3.fromRGB(25,25,25), sidebar=Color3.fromRGB(10,10,10),
    line=Color3.fromRGB(50,50,50), txt=Color3.fromRGB(255,255,255), dim=Color3.fromRGB(130,130,130),
    acc=Color3.fromRGB(255,0,60), off=Color3.fromRGB(60,60,60)
}

local gui = Instance.new("ScreenGui")
gui.Name="SG_"..tostring(math.random(100000,999999)); gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true
gui.DisplayOrder=10000; gui.Parent=getHui(); getgenv().TGui=gui

local main = Instance.new("Frame")
main.Size=UDim2.new(0,600,0,420); main.Position=UDim2.new(0.5,-300,0.5,-210)
main.BackgroundColor3=COL.bg; main.BorderSizePixel=0; main.Active=true; main.Parent=gui

local ms = Instance.new("UIStroke")
ms.Color=COL.acc; ms.Thickness=1; ms.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; ms.Parent=main

local sidebar = Instance.new("Frame")
sidebar.Size=UDim2.new(0,130,1,0); sidebar.BackgroundColor3=COL.sidebar
sidebar.BorderSizePixel=0; sidebar.Parent=main

local logo = Instance.new("TextLabel")
logo.Size=UDim2.new(1,0,0,50); logo.BackgroundTransparency=1
logo.Text="SpookingD"; logo.TextColor3=COL.acc; logo.Font=Enum.Font.GothamBlack
logo.TextSize=22; logo.Parent=sidebar

local masterBtn = Instance.new("TextButton")
masterBtn.Size=UDim2.new(1,-20,0,30); masterBtn.Position=UDim2.new(0,10,0,55)
masterBtn.BackgroundColor3=COL.panel; masterBtn.BorderSizePixel=0
masterBtn.Text="ENABLE SCRIPT"; masterBtn.TextColor3=COL.dim
masterBtn.Font=Enum.Font.GothamBold; masterBtn.TextSize=10; masterBtn.Parent=sidebar

local masterStroke = Instance.new("UIStroke")
masterStroke.Color=COL.line; masterStroke.Thickness=1; masterStroke.Parent=masterBtn

local hiddenFolder
local function getHiddenFolder()
    if hiddenFolder and hiddenFolder.Parent then return hiddenFolder end
    hiddenFolder = Instance.new("Folder")
    hiddenFolder.Name = "\0SpookCarrier"
    hiddenFolder.Parent = CAM
    return hiddenFolder
end

local espData = {}
local toolCache = {}
local parryIndicator = nil

local function destroyEspEntry(p)
    local d = espData[p]
    if not d then return end
    if d.hl then d.hl:Destroy() end
    if d.bg then d.bg:Destroy() end
    espData[p] = nil
end

local function fullTeardown()
    for p in pairs(espData) do destroyEspEntry(p) end
    if parryIndicator then parryIndicator:Destroy(); parryIndicator = nil end
    if hiddenFolder then hiddenFolder:Destroy(); hiddenFolder = nil end
end

masterBtn.MouseButton1Click:Connect(function()
    MasterEnabled = not MasterEnabled
    if MasterEnabled then
        masterBtn.Text="SCRIPT: ON"; masterBtn.TextColor3=COL.acc; masterStroke.Color=COL.acc
    else
        masterBtn.Text="ENABLE SCRIPT"; masterBtn.TextColor3=COL.dim; masterStroke.Color=COL.line
        fullTeardown()
    end
end)

local sideTabs, sidePages = {}, {}
local function addSideTab(name)
    local btn = Instance.new("TextButton")
    btn.Size=UDim2.new(1,-20,0,30); btn.Position=UDim2.new(0,10,0,90+(#sideTabs*32))
    btn.BackgroundColor3=COL.sidebar; btn.BorderSizePixel=0
    btn.Text="  "..name; btn.TextColor3=COL.dim; btn.Font=Enum.Font.GothamBold
    btn.TextSize=11; btn.TextXAlignment=Enum.TextXAlignment.Left
    btn.AutoButtonColor=false; btn.Parent=sidebar
    table.insert(sideTabs, btn)
    local pg=Instance.new("Frame")
    pg.Size=UDim2.new(1,-130,1,0); pg.Position=UDim2.new(0,130,0,0)
    pg.BackgroundTransparency=1; pg.Visible=false; pg.Parent=main
    table.insert(sidePages, pg)
    local idx=#sideTabs
    btn.MouseButton1Click:Connect(function()
        for i,t in ipairs(sideTabs) do
            t.TextColor3=(i==idx) and COL.txt or COL.dim
            t.BackgroundColor3=(i==idx) and COL.panel or COL.sidebar
        end
        for i,p in ipairs(sidePages) do p.Visible=(i==idx) end
    end)
    return pg
end

local function createBox(parent,title,x,y,w,h)
    local box=Instance.new("Frame")
    box.Size=UDim2.new(0,w,0,h); box.Position=UDim2.new(0,x,0,y)
    box.BackgroundColor3=COL.panel; box.BorderSizePixel=0; box.Parent=parent
    local bs=Instance.new("UIStroke"); bs.Color=COL.line; bs.Thickness=1; bs.Parent=box
    local header=Instance.new("Frame")
    header.Size=UDim2.new(1,0,0,24); header.BackgroundColor3=COL.sidebar
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
    row.Size=UDim2.new(1,-10,0,28); row.Position=UDim2.new(0,5,0,yOffset)
    row.BackgroundTransparency=1; row.Text=""; row.ZIndex=2; row.Parent=parent
    local txt=Instance.new("TextLabel")
    txt.Size=UDim2.new(1,-60,1,0); txt.BackgroundTransparency=1
    txt.Text=label; txt.TextColor3=COL.txt; txt.Font=Enum.Font.Gotham
    txt.TextSize=11; txt.TextXAlignment=Enum.TextXAlignment.Left; txt.ZIndex=2; txt.Parent=row
    local pill=Instance.new("Frame")
    pill.Size=UDim2.new(0,36,0,18); pill.Position=UDim2.new(1,-36,0.5,-9)
    pill.BackgroundColor3=CFG[key] and COL.acc or COL.off; pill.ZIndex=2; pill.Parent=row
    local pc=Instance.new("UICorner"); pc.CornerRadius=UDim.new(1,0); pc.Parent=pill
    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,12,0,12)
    knob.Position=CFG[key] and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.ZIndex=3; knob.Parent=pill
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
    txt.TextSize=11; txt.TextXAlignment=Enum.TextXAlignment.Left; txt.Parent=frame
    local input=Instance.new("TextBox")
    input.Size=UDim2.new(0,40,0,18); input.Position=UDim2.new(1,-40,0.5,-9)
    input.BackgroundColor3=COL.bg; input.BorderSizePixel=0
    input.Text=tostring(CFG[key]); input.TextColor3=COL.acc
    input.Font=Enum.Font.GothamBold; input.TextSize=10; input.Parent=frame
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
    btn.BackgroundColor3=COL.bg; btn.BorderSizePixel=0
    btn.Text=label; btn.TextColor3=COL.txt; btn.Font=Enum.Font.GothamBold
    btn.TextSize=11; btn.Parent=parent
    local bs=Instance.new("UIStroke"); bs.Color=COL.line; bs.Thickness=1; bs.Parent=btn
    btn.MouseButton1Click:Connect(function() if MasterEnabled then pcall(cb) end end)
end

local pgVisual   = addSideTab("Visuals")
local pgWorld    = addSideTab("World")
local pgSurvivor = addSideTab("Survivor")
local pgKiller   = addSideTab("Killer")
local pgMisc     = addSideTab("Misc")

local boxESP = createBox(pgVisual, "Player ESP", 10, 10, 440, 220)
addSwitch(boxESP, "Enable ESP", "esp", 30)
addSwitch(boxESP, "Show Name", "esp_name", 60)
addSwitch(boxESP, "Show Health", "esp_health", 90)
addSwitch(boxESP, "Show Distance", "esp_dist", 120)
addSwitch(boxESP, "Show Item", "esp_item", 150)

local boxVisual = createBox(pgVisual, "Screen", 10, 240, 440, 100)
addSwitch(boxVisual, "Custom Crosshair", "crosshair", 30)
addSwitch(boxVisual, "Hitbox Visualizer", "hitbox_expand", 60)

local boxWorld = createBox(pgWorld, "World ESP", 10, 10, 440, 160)
addSwitch(boxWorld, "Generator ESP", "gen_esp", 30)
addSwitch(boxWorld, "Killer Skill ESP", "killer_esp", 60)
addSwitch(boxWorld, "Item ESP", "item_esp", 90)
addSwitch(boxWorld, "Exit / Spike ESP", "exit_esp", 120)

local boxEnv = createBox(pgMisc, "Environment", 10, 10, 440, 100)
addSwitch(boxEnv, "TRUE Fullbright", "bright", 30)
addSwitch(boxEnv, "FPS Booster", "fpsboost", 60)

local boxSafe = createBox(pgSurvivor, "Survivor Utility", 10, 10, 440, 120)
addSwitch(boxSafe, "Auto Parry (Prediction)", "auto_parry", 30)
addSwitch(boxSafe, "Auto Skillcheck (Space)", "auto_skillcheck", 60)

local boxKiller = createBox(pgKiller, "Killer Utility", 10, 10, 440, 80)
addSwitch(boxKiller, "Look Lock (Aim Assist)", "look_lock", 30)

local boxFOV = createBox(pgMisc, "Camera FOV", 10, 120, 440, 100)
addSwitch(boxFOV, "Enable Custom FOV", "fov_enabled", 30)
addSlider(boxFOV, "FOV Value", "fov_val", 50, 120, 60)

local boxMisc = createBox(pgMisc, "Movement", 10, 230, 440, 100)
addSwitch(boxMisc, "Enable WalkSpeed", "ws_enabled", 30)
addSlider(boxMisc, "WalkSpeed (Safe)", "ws_speed", 16, 28, 60)

local boxBypass = createBox(pgMisc, "SpookingD Bypass", 10, 340, 440, 150)
addButton(boxBypass, "Re-Apply HWID Bypass", function()
    BYPASS.loadHwid()
    pcall(function()
        game:GetService("RbxAnalyticsService").GetHardwareIdentifier = function() return getgenv().SpoofedHWID end
    end)
    BYPASS.scrub()
end, 30)
addButton(boxBypass, "FLUSH LOGS & CACHE", function()
    BYPASS.scrub(); print("[SpookingD] Logs & Cache Flushed.")
end, 60)
addButton(boxBypass, "Panic Wipe (Log Out)", function()
    BYPASS.scrub()
    if writefile and isfile and delfile then
        pcall(function() if isfile(BYPASS.HWID_FILE) then delfile(BYPASS.HWID_FILE) end end)
    end
    fullTeardown()
    task.wait(0.05)
    game:Shutdown()
end, 90)

sideTabs[1].TextColor3=COL.txt; sideTabs[1].BackgroundColor3=COL.panel; sidePages[1].Visible=true

local closeBtn=Instance.new("TextButton")
closeBtn.Size=UDim2.new(0,20,0,20); closeBtn.Position=UDim2.new(1,-25,0,5)
closeBtn.BackgroundTransparency=1; closeBtn.Text="×"; closeBtn.TextColor3=COL.txt
closeBtn.Font=Enum.Font.GothamBold; closeBtn.TextSize=16; closeBtn.Parent=main

local openBtn=Instance.new("TextButton")
openBtn.Size=UDim2.new(0,40,0,40); openBtn.Position=UDim2.new(0,20,0,100)
openBtn.BackgroundColor3=COL.bg; openBtn.BorderSizePixel=2; openBtn.BorderColor3=COL.acc
openBtn.Text="S"; openBtn.TextColor3=COL.acc; openBtn.Font=Enum.Font.GothamBlack
openBtn.TextSize=22; openBtn.Parent=gui; openBtn.Visible=false

closeBtn.MouseButton1Click:Connect(function() main.Visible=false; openBtn.Visible=true end)
openBtn.MouseButton1Click:Connect(function() main.Visible=true; openBtn.Visible=false end)
UIS.InputBegan:Connect(function(i,pr)
    if pr then return end
    if i.KeyCode == CFG.keyMenu then
        main.Visible = not main.Visible; openBtn.Visible = not main.Visible
    end
end)

local drag, ds, sp
logo.InputBegan:Connect(function(i)
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
-- ESP + OUTLINE (the garis)
-- ==========================================
local crosshair=Instance.new("Frame")
crosshair.Size=UDim2.new(0,4,0,4); crosshair.Position=UDim2.new(0.5,-2,0.5,-2)
crosshair.BackgroundColor3=COL.acc; crosshair.BorderSizePixel=0
crosshair.Visible=false; crosshair.Parent=gui

local function isKiller(p)
    if p.Team and p.Team.Name:lower():find("killer") then return true end
    local ls=p:FindFirstChild("leaderstats")
    if ls then
        for _,v in pairs(ls:GetChildren()) do
            if v.Name:lower():find("role") and tostring(v.Value):lower():find("killer") then return true end
        end
    end
    return false
end

local function getSurvivorItem(p)
    local char=p.Character; if not char then return nil end
    local tool=char:FindFirstChildWhichIsA("Tool")
    local cached=toolCache[p]
    if tool and cached and cached.tool==tool then return cached.name end
    if tool then
        local low=tool.Name:lower()
        for k,orig in pairs(VD_ITEM_LOOKUP) do
            if low:find(k,1,true) then
                toolCache[p]={tool=tool,name=orig}
                return orig
            end
        end
    end
    toolCache[p]=nil; return nil
end

local function buildEspEntry(p, hrp, color)
    local carrier = getHiddenFolder()
    local hl=Instance.new("Highlight")
    hl.FillColor=color; hl.OutlineColor=color
    hl.FillTransparency=1
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent=carrier
    hl.Adornee=p.Character

    local bg=Instance.new("BillboardGui")
    bg.Name="Spook_ESP"; bg.Adornee=hrp
    bg.Size=UDim2.new(0,150,0,65); bg.StudsOffset=Vector3.new(0,3,0)
    bg.AlwaysOnTop=true; bg.Parent=carrier

    local function label(y,sz,col,font)
        local l=Instance.new("TextLabel")
        l.Size=UDim2.new(1,0,0,sz); l.Position=UDim2.new(0,0,0,y)
        l.BackgroundTransparency=1; l.TextColor3=col; l.TextStrokeTransparency=0
        l.Font=font; l.TextSize=sz-1; l.Parent=bg
        return l
    end
    local nameLbl=label(0,14,color,Enum.Font.GothamBold)
    local itemLbl=label(14,12,Color3.fromRGB(0,255,255),Enum.Font.GothamBold)
    local distLbl=label(26,12,Color3.fromRGB(200,200,200),Enum.Font.Gotham)

    local hpBg=Instance.new("Frame")
    hpBg.Size=UDim2.new(0.6,0,0,4); hpBg.Position=UDim2.new(0.2,0,0,42)
    hpBg.BackgroundColor3=Color3.fromRGB(40,40,40); hpBg.BorderSizePixel=0; hpBg.Parent=bg
    local hpFill=Instance.new("Frame")
    hpFill.Size=UDim2.new(1,0,1,0); hpFill.BackgroundColor3=Color3.fromRGB(0,255,0)
    hpFill.BorderSizePixel=0; hpFill.Parent=hpBg

    espData[p]={hl=hl,bg=bg,name=nameLbl,item=itemLbl,dist=distLbl,hp=hpFill,hpBg=hpBg}
end

task.spawn(function()
    while true do
        task.wait(1)
        if not (MasterEnabled and CFG.esp) then
            for p in pairs(espData) do destroyEspEntry(p) end
            continue
        end
        pcall(function()
            local myChar=LP.Character
            local myHrp=myChar and myChar:FindFirstChild("HumanoidRootPart")
            for _,p in ipairs(P:GetPlayers()) do
                if p==LP then continue end
                local char=p.Character
                local hrp=char and char:FindFirstChild("HumanoidRootPart")
                local hum=char and char:FindFirstChildOfClass("Humanoid")
                if not (hrp and hum) then destroyEspEntry(p); continue end
                local killer=isKiller(p)
                local color=killer and Color3.fromRGB(255,0,0) or Color3.fromRGB(255,255,255)
                local itemName=(not killer and CFG.esp_item) and getSurvivorItem(p) or nil

                local d=espData[p]
                if not d or not d.hl or not d.hl.Parent or not d.bg or not d.bg.Parent then
                    destroyEspEntry(p)
                    buildEspEntry(p,hrp,color)
                    d=espData[p]
                end

                d.hl.Enabled = true
                d.hl.Adornee = char
                d.hl.FillColor = color
                d.hl.OutlineColor = color
                d.name.Text=p.Name; d.name.TextColor3=color
                d.name.Visible=CFG.esp_name
                if itemName then
                    d.item.Text="["..itemName.."]"; d.item.Visible=true
                else
                    d.item.Visible=false
                end
                if myHrp then
                    d.dist.Text="["..math.floor((hrp.Position-myHrp.Position).Magnitude).."m]"
                else d.dist.Text="[--]" end
                d.dist.Visible=CFG.esp_dist
                local hPct=(hum.MaxHealth>0) and (hum.Health/hum.MaxHealth) or 0
                d.hpBg.Visible=CFG.esp_health
                d.hp.Size=UDim2.new(hPct,0,1,0)
                d.hp.BackgroundColor3=hPct>0.5 and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
            end
        end)
    end
end)

P.PlayerRemoving:Connect(function(p) destroyEspEntry(p); toolCache[p]=nil end)

-- ==========================================
-- PARRY SPHERE
-- ==========================================
local PARRY_RADIUS=18
local function ensureParrySphere()
    if parryIndicator and parryIndicator.Parent then return parryIndicator end
    local carrier=getHiddenFolder()
    local sphere=Instance.new("Part")
    sphere.Name="SpookReach"
    sphere.Shape=Enum.PartType.Ball
    sphere.Size=Vector3.new(PARRY_RADIUS*2,PARRY_RADIUS*2,PARRY_RADIUS*2)
    sphere.Anchored=true; sphere.CanCollide=false
    sphere.CanQuery=false; sphere.CanTouch=false
    sphere.Massless=true; sphere.Transparency=1
    sphere.Parent=carrier
    parryIndicator=sphere
    return sphere
end

RS.RenderStepped:Connect(function()
    if not MasterEnabled then return end
    if CFG.auto_parry and LP.Character then
        local hrp=LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then local s=ensureParrySphere(); if s then s.Position=hrp.Position end end
    else
        if parryIndicator then parryIndicator:Destroy(); parryIndicator=nil end
    end
end)

-- ==========================================
-- SKILLCHECK — aimed at the white zone, single-fire
-- ==========================================
local SKILL = {
    scanInterval = 0.015,
    zoneTolerance = 4.5,
    pressWidthLo = 0.008,
    pressWidthHi = 0.024,
    cooldown = 0.12,
}
local firedThisCheck = {}
local lastFireAt = 0

local function norm360(d) d=d%360; if d<0 then d=d+360 end; return d end
local function angDist(a,b)
    local d=norm360(b)-norm360(a)
    if d>180 then d=d-360 elseif d<-180 then d=d+360 end
    return math.abs(d)
end

local function findSkillcheckRoot()
    local pg=LP:FindFirstChild("PlayerGui"); if not pg then return nil end
    for _,g in ipairs(pg:GetDescendants()) do
        if g:IsA("Frame") or g:IsA("ImageLabel") then
            local needle, zone = nil, nil
            for _,c in ipairs(g:GetDescendants()) do
                if c:IsA("ImageLabel") or c:IsA("Frame") then
                    local n=c.Name:lower()
                    if not needle and (n:find("needle") or n:find("indicator") or n:find("marker") or n:find("dial")) then
                        needle=c
                    elseif not zone and (n:find("zone") or n:find("target") or n:find("hit") or n:find("sweet") or n:find("white") or n:find("perfect")) then
                        zone=c
                    end
                end
            end
            if needle and zone then return g, needle, zone end
        end
    end
    return nil
end

local function angleOf(inst, root)
    if inst.Rotation and math.abs(inst.Rotation) > 0 then
        return norm360(inst.Rotation)
    end
    local rootAbs=root.AbsolutePosition; local rootSize=root.AbsoluteSize
    local cx=rootAbs.X+rootSize.X*0.5; local cy=rootAbs.Y+rootSize.Y*0.5
    local ip=inst.AbsolutePosition; local isz=inst.AbsoluteSize
    local ix=ip.X+isz.X*0.5; local iy=ip.Y+isz.Y*0.5
    local deg=math.deg(math.atan(iy-cy, ix-cx))
    return norm360(deg)
end

task.spawn(function()
    while true do
        task.wait(SKILL.scanInterval)
        if not (MasterEnabled and CFG.auto_skillcheck) then
            firedThisCheck={}; continue
        end
        if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            firedThisCheck={}; continue
        end
        if not canSendInput() then continue end
        if tick()-lastFireAt < SKILL.cooldown then continue end
        local root,needle,zone=findSkillcheckRoot()
        if not (root and needle and zone) then continue end
        if firedThisCheck[needle] then continue end
        local nAng=angleOf(needle,root); local zAng=angleOf(zone,root)
        if angDist(nAng,zAng) <= SKILL.zoneTolerance then
            firedThisCheck[needle]=true; lastFireAt=tick()
            local w=jittered(SKILL.pressWidthLo,SKILL.pressWidthHi)
            pcall(function()
                VIM:SendKeyEvent(true,Enum.KeyCode.Space,false,game)
                task.wait(w)
                VIM:SendKeyEvent(false,Enum.KeyCode.Space,false,game)
            end)
        end
    end
end)

-- ==========================================
-- PREDICTIVE PARRY — right-click
-- ==========================================
local PARRY_MOUSE_BUTTON=2
local parryBusy=false

local function killerIsAttacking(char,hrp,myHrp)
    local dir=myHrp.Position-hrp.Position
    if dir.Magnitude<0.1 then return false end
    if hrp.CFrame.LookVector:Dot(dir.Unit)<0.7 then return false end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if hum then
        local animator=hum:FindFirstChildOfClass("Animator")
        if animator then
            for _,track in ipairs(animator:GetPlayingAnimationTracks()) do
                local n=(track.Name or ""):lower()
                if n:find("attack") or n:find("slash") or n:find("swing") or n:find("hit") then return true end
            end
        end
    end
    return true
end

task.spawn(function()
    while true do
        task.wait(0.05)
        if not (MasterEnabled and CFG.auto_parry) then continue end
        if parryBusy then continue end
        if not canSendInput() then continue end
        local myChar=LP.Character
        local myHrp=myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then continue end
        for _,p in ipairs(P:GetPlayers()) do
            if p==LP then continue end
            local char=p.Character
            if not char or not isKiller(p) then continue end
            local tHrp=char:FindFirstChild("HumanoidRootPart")
            local hum=char:FindFirstChildOfClass("Humanoid")
            if not (tHrp and hum and hum.Health>0) then continue end
            if (tHrp.Position-myHrp.Position).Magnitude>=PARRY_RADIUS then continue end
            if not killerIsAttacking(char,tHrp,myHrp) then continue end
            parryBusy=true
            local w=jittered(0.008,0.020)
            pcall(function()
                VIM:SendMouseButtonEvent(0,0,PARRY_MOUSE_BUTTON,true,game,1)
                task.wait(w)
                VIM:SendMouseButtonEvent(0,0,PARRY_MOUSE_BUTTON,false,game,1)
            end)
            task.wait(CFG.parry_cooldown+jittered(0,0.06))
            parryBusy=false
            break
        end
    end
end)

-- ==========================================
-- FOV — set on change
-- ==========================================
local lastFovSet=nil
RS.RenderStepped:Connect(function()
    if not MasterEnabled then return end
    if CAM and CFG.fov_enabled then
        local target=CFG.fov_val
        if lastFovSet~=target then CAM.FieldOfView=target; lastFovSet=target end
    elseif lastFovSet and CAM then
        CAM.FieldOfView=70; lastFovSet=nil
    end
end)

-- ==========================================
-- LIGHTING — fullbright state machine
-- ==========================================
local LIGHT_ORIG = {
    Brightness=L.Brightness, ClockTime=L.ClockTime,
    Ambient=L.Ambient, OutdoorAmbient=L.OutdoorAmbient,
    ExposureCompensation=L.ExposureCompensation, FogEnd=L.FogEnd,
    GlobalShadows=L.GlobalShadows, ShadowSoftness=L.ShadowSoftness,
    EnvironmentDiffuseScale=L.EnvironmentDiffuseScale,
    EnvironmentSpecularScale=L.EnvironmentSpecularScale,
    QualityLevel=settings().Rendering.QualityLevel,
}
local atmosBackup={}
local lightMode="orig"

local function destroyAtmos()
    atmosBackup={}
    for _,v in ipairs(L:GetChildren()) do
        if v:IsA("Atmosphere") or v:IsA("ColorCorrectionEffect")
           or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") then
            atmosBackup[v]=v.Parent; v.Parent=nil
        end
    end
end

local function restoreAtmos()
    for inst,parent in pairs(atmosBackup) do
        if inst and inst.Parent==nil and parent then inst.Parent=parent end
    end
    atmosBackup={}
end

local function applyBright()
    if lightMode=="bright" then return end
    if lightMode=="orig" then destroyAtmos() end
    lightMode="bright"
    L.Brightness=2; L.ClockTime=12
    L.Ambient=Color3.fromRGB(180,180,180); L.OutdoorAmbient=Color3.fromRGB(200,200,200)
    L.ExposureCompensation=0.2; L.FogEnd=100000
    L.GlobalShadows=false; L.ShadowSoftness=0
    L.EnvironmentDiffuseScale=0; L.EnvironmentSpecularScale=0
end

local function applyOrig()
    if lightMode=="orig" then return end
    restoreAtmos(); lightMode="orig"
    L.Brightness=LIGHT_ORIG.Brightness; L.ClockTime=LIGHT_ORIG.ClockTime
    L.Ambient=LIGHT_ORIG.Ambient; L.OutdoorAmbient=LIGHT_ORIG.OutdoorAmbient
    L.ExposureCompensation=LIGHT_ORIG.ExposureCompensation; L.FogEnd=LIGHT_ORIG.FogEnd
    L.GlobalShadows=LIGHT_ORIG.GlobalShadows; L.ShadowSoftness=LIGHT_ORIG.ShadowSoftness
    L.EnvironmentDiffuseScale=LIGHT_ORIG.EnvironmentDiffuseScale
    L.EnvironmentSpecularScale=LIGHT_ORIG.EnvironmentSpecularScale
    settings().Rendering.QualityLevel=LIGHT_ORIG.QualityLevel
end

local function applyFps()
    if lightMode=="fps" then return end
    lightMode="fps"
    settings().Rendering.QualityLevel=1
    L.EnvironmentDiffuseScale=0; L.EnvironmentSpecularScale=0
end

RS.RenderStepped:Connect(function()
    if not MasterEnabled then
        if lightMode~="orig" then applyOrig() end
        return
    end
    if CFG.bright then applyBright()
    elseif CFG.fpsboost then applyFps()
    else applyOrig() end
end)

-- ==========================================
-- WALKSPEED — lerp + clamp
-- ==========================================
local WS_MAX_SAFE=22
local lastAppliedWs=nil
RS.Stepped:Connect(function(_,dt)
    if not MasterEnabled then return end
    local c=LP.Character; if not c then return end
    local hum=c:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local target=CFG.ws_enabled and math.clamp(CFG.ws_speed,16,WS_MAX_SAFE) or 16
    if lastAppliedWs and math.abs(hum.WalkSpeed-target)<0.05 then return end
    local step=math.min(dt*30,math.abs(target-hum.WalkSpeed))*(target>hum.WalkSpeed and 1 or -1)
    hum.WalkSpeed=hum.WalkSpeed+step
    lastAppliedWs=hum.WalkSpeed
end)

print("[SpookingD] v60.5 loaded")
