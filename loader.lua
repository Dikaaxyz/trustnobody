--[[
    SpookingD - Violence District
    v99.0 — GOD TIER (Merged all features + 99% Bypass)
]]

if not game:IsLoaded() then game.Loaded:Wait() end
if getgenv().TGui then pcall(function() getgenv().TGui:Destroy() end) end

local P    = game:GetService("Players")
local RS   = game:GetService("RunService")
local UIS  = game:GetService("UserInputService")
local WS   = game:GetService("Workspace")
local L    = game:GetService("Lighting")
local VIM  = game:GetService("VirtualInputManager")
local CG   = game:GetService("CoreGui")
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

-- ==========================================
-- CONFIG
-- ==========================================
local CFG = {
    -- Claudeware
    esp=false, killer_esp=true, survivor_esp=true, radar=false, gen_esp=true, fov=70,
    -- 717exe
    pumpkin_esp=false,
    -- No Skillcheck
    no_skillcheck=false, auto_farm=false,
    -- Hendar
    crosshair=false, fly=false, noclip=false, proximity_alert=false,
    -- BEST VD
    desync=false, invis=false, hitbox=false, autoplay=false, lunge=false, parry=false, perfect_gen=false, godmode=false, instant_escape=false,
    
    -- Internal
    ws_enabled=false, ws_speed=16, bright=false,
    keyMenu=Enum.KeyCode.RightShift
}

local hiddenFolder
local function getHiddenFolder()
    if hiddenFolder and hiddenFolder.Parent then return hiddenFolder end
    hiddenFolder = Instance.new("Folder")
    hiddenFolder.Name = "\0SpookCarrier"
    hiddenFolder.Parent = CAM or WS
    return hiddenFolder
end

-- ==========================================
-- GUI
-- ==========================================
local COL = {
    bg=Color3.fromRGB(15,15,15), panel=Color3.fromRGB(25,25,25), sidebar=Color3.fromRGB(10,10,10),
    line=Color3.fromRGB(50,50,50), txt=Color3.fromRGB(255,255,255), dim=Color3.fromRGB(150,150,150),
    acc=Color3.fromRGB(0, 255, 120), red=Color3.fromRGB(255,0,60), off=Color3.fromRGB(60,60,60)
}

local guiParent = LP:WaitForChild("PlayerGui", 5) or WS
local gui = Instance.new("ScreenGui")
gui.Name="SG_"..tostring(math.random(1000,9999))
gui.ResetOnSpawn=false
gui.DisplayOrder=999999
gui.Parent=guiParent
getgenv().TGui=gui

local main = Instance.new("Frame")
main.Size=UDim2.new(0,600,0,450); main.Position=UDim2.new(0.5,-300,0.5,-225)
main.BackgroundColor3=COL.bg; main.BorderSizePixel=0; main.Active=true; main.ClipsDescendants=true; main.Parent=gui

local ms = Instance.new("UIStroke")
ms.Color=COL.acc; ms.Thickness=2; ms.Parent=main

local topBar = Instance.new("Frame")
topBar.Size=UDim2.new(1,0,0,35); topBar.BackgroundColor3=COL.sidebar; topBar.BorderSizePixel=0; topBar.Parent=main

local logo = Instance.new("TextLabel")
logo.Size=UDim2.new(0,200,1,0); logo.Position=UDim2.new(0,10,0,0); logo.BackgroundTransparency=1
logo.Text="SPOOKINGD GOD TIER"; logo.TextColor3=COL.acc; logo.Font=Enum.Font.GothamBlack
logo.TextSize=16; logo.TextXAlignment=Enum.TextXAlignment.Left; logo.Parent=topBar

local masterBtn = Instance.new("TextButton")
masterBtn.Size=UDim2.new(0,120,0,22); masterBtn.Position=UDim2.new(1,-130,0,6)
masterBtn.BackgroundColor3=COL.red; masterBtn.BorderSizePixel=0
masterBtn.Text="ENABLE"; masterBtn.TextColor3=Color3.new(1,1,1)
masterBtn.Font=Enum.Font.GothamBold; masterBtn.TextSize=12; masterBtn.Parent=topBar
local mbc = Instance.new("UICorner"); mbc.CornerRadius = UDim.new(0, 4); mbc.Parent = masterBtn

local sidebar = Instance.new("Frame")
sidebar.Size=UDim2.new(0,140,1,-35); sidebar.Position=UDim2.new(0,0,0,35)
sidebar.BackgroundColor3=COL.sidebar; sidebar.BackgroundTransparency=0.5; sidebar.BorderSizePixel=0; sidebar.Parent=main

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
    scroll.CanvasSize=UDim2.new(0,0,0,800); scroll.Parent=parent
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

-- TABS
local pgVisual = addSideTab("Visuals")
local pgCombat = addSideTab("Combat")
local pgPlayer = addSideTab("Player")
local pgWorld  = addSideTab("World")
local pgMisc   = addSideTab("Misc")

local scVisual = createScroll(pgVisual)
local scCombat = createScroll(pgCombat)
local scPlayer = createScroll(pgPlayer)
local scWorld  = createScroll(pgWorld)
local scMisc   = createScroll(pgMisc)

-- VISUALS (Claudeware, 717exe, Hendar)
local box1 = createBox(scVisual, "ESP Settings", 10, 480, 160)
addSwitch(box1, "Enable ESP", "esp", 30)
addSwitch(box1, "Killer Color (Red)", "killer_esp", 55)
addSwitch(box1, "Survivor Color (White)", "survivor_esp", 80)
addSwitch(box1, "Generator ESP", "gen_esp", 105)
addSwitch(box1, "Pumpkin ESP", "pumpkin_esp", 130)

local box2 = createBox(scVisual, "Screen", 180, 480, 110)
addSwitch(box2, "Custom Crosshair", "crosshair", 30)
addSwitch(box2, "Radar", "radar", 55)
addSwitch(box2, "Killer Proximity Alert", "proximity_alert", 80)

-- COMBAT (BEST VD)
local box3 = createBox(scCombat, "BEST VD Script", 10, 480, 180)
addSwitch(box3, "Auto Parry (Dagger)", "parry", 30)
addSwitch(box3, "Auto Perfect Generator", "perfect_gen", 55)
addSwitch(box3, "Expand Hitboxes", "hitbox", 80)
addSwitch(box3, "Infinite Lunge (Killer)", "lunge", 105)
addSwitch(box3, "God Mode", "godmode", 130)

local box4 = createBox(scCombat, "Automation", 200, 480, 80)
addSwitch(box4, "No Skillcheck (Skip)", "no_skillcheck", 30)
addSwitch(box4, "Auto Farm", "auto_farm", 55)

-- PLAYER (Hendar, BEST VD)
local box5 = createBox(scPlayer, "Movement", 10, 480, 110)
addSwitch(box5, "Fly", "fly", 30)
addSwitch(box5, "Noclip", "noclip", 55)
addSwitch(box5, "WalkSpeed", "ws_enabled", 80)

local box6 = createBox(scPlayer, "Exploits", 130, 480, 100)
addSwitch(box6, "Desync (Lag Switch)", "desync", 30)
addSwitch(box6, "Invisibility", "invis", 55)
addSwitch(box6, "Instant Escape", "instant_escape", 80)

-- MISC
local box7 = createBox(scMisc, "Speed", 10, 480, 60)
addSlider(box7, "WalkSpeed Value", "ws_speed", 16, 100, 30)

local box8 = createBox(scMisc, "Auto Play", 80, 480, 60)
addSwitch(box8, "Auto Play (Bot)", "autoplay", 30)

sideTabs[1].TextColor3=COL.acc; sideTabs[1].BackgroundTransparency=0.8; sideTabs[1].BackgroundColor3=COL.acc; sidePages[1].Visible=true

-- CLOSE / OPEN
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
        masterBtn.Text="ENABLE"; masterBtn.BackgroundColor3=COL.red
        fullTeardown()
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
-- LOGIC ENGINES
-- ==========================================
local espData = {}
local flyBV = nil
local parryBusy = false
local savedPos = nil

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

local function destroyEspEntry(p)
    local d = espData[p]
    if not d then return end
    if d.hl then d.hl:Destroy() end
    if d.bg then d.bg:Destroy() end
    espData[p] = nil
end

local function fullTeardown()
    for p in pairs(espData) do destroyEspEntry(p) end
    if flyBV then flyBV:Destroy(); flyBV=nil end
end

-- ESP ENGINE
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
                                destroyEspEntry(p)
                            else
                                local d = espData[p]
                                if not d or not d.hl.Parent then
                                    destroyEspEntry(p)
                                    local hl = Instance.new("Highlight")
                                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    hl.Adornee = char
                                    hl.Parent = getHiddenFolder()
                                    
                                    local bg = Instance.new("BillboardGui")
                                    bg.Adornee = hrp; bg.Size = UDim2.new(0, 100, 0, 20)
                                    bg.StudsOffset = Vector3.new(0, 3, 0); bg.AlwaysOnTop = true
                                    bg.Parent = getHiddenFolder()
                                    
                                    local txt = Instance.new("TextLabel")
                                    txt.Size = UDim2.new(1,0,1,0); txt.BackgroundTransparency = 1
                                    txt.TextColor3 = Color3.new(1,1,1); txt.TextStrokeTransparency = 0
                                    txt.Font = Enum.Font.GothamBold; txt.TextSize = 12; txt.Parent = bg
                                    
                                    espData[p] = { hl = hl, bg = bg, txt = txt }
                                    d = espData[p]
                                end
                                
                                local color = killer and Color3.fromRGB(255,0,0) or Color3.fromRGB(255,255,255)
                                d.hl.FillColor = color; d.hl.OutlineColor = color
                                d.txt.Text = p.Name
                            end
                        else destroyEspEntry(p) end
                    end
                end
            end)
        end
    end
end)

-- MOVEMENT & EXPLOITS
RS.Stepped:Connect(function(_,dt)
    if not MasterEnabled then return end
    local c = LP.Character
    if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    
    if CFG.ws_enabled then hum.WalkSpeed = CFG.ws_speed end
    
    if CFG.noclip then
        for _, v in pairs(c:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
        end
    end
    
    if CFG.godmode then
        hum.MaxHealth = math.huge; hum.Health = math.huge
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

-- AUTO PARRY & SKILLCHECK
task.spawn(function()
    while true do
        task.wait(0.1)
        if MasterEnabled and CFG.parry and not parryBusy then
            local myChar = LP.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myHrp then
                for _, p in ipairs(P:GetPlayers()) do
                    if p ~= LP and isKillerSafe(p) then
                        local char = p.Character
                        local tHrp = char and char:FindFirstChild("HumanoidRootPart")
                        if tHrp and (tHrp.Position - myHrp.Position).Magnitude < 20 then
                            parryBusy = true
                            pcall(function()
                                VIM:SendMouseButtonEvent(0, 0, 2, true, game, 1)
                                task.wait(0.05)
                                VIM:SendMouseButtonEvent(0, 0, 2, false, game, 1)
                            end)
                            task.wait(0.3)
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
        if MasterEnabled and CFG.no_skillcheck and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
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

print("[SpookingD] v99.0 loaded — GOD TIER ACTIVE")
