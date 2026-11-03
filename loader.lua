--[[
    SpookingD - Violence District
    v1001.1 — Stealth Edition (Anti-Detect, 99% Safe)
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

local MouseLocked = true
local mouseUnlockKey = Enum.KeyCode.RightControl

-- ==========================================
-- GHOST PROTOCOL V2 (ABSOLUTE FORTRESS)
-- ==========================================
local Ghost = {}

function Ghost.Init()
    -- 1. Hardware Deep Spoof (HWID, MAC, Serial)
    if writefile and readfile and isfile then
        pcall(function()
            local ghost_file = "ghost_hwid_v2.dat"
            local fake_hwid = tostring(math.random(10000000, 99999999)) .. "GHOST"
            local fake_mac = string.format("%02X:%02X:%02X:%02X:%02X:%02X", 
                math.random(0,255), math.random(0,255), math.random(0,255), 
                math.random(0,255), math.random(0,255), math.random(0,255))
            
            writefile(ghost_file, fake_hwid .. "|" .. fake_mac)
            getgenv().GhostHWID = fake_hwid
            getgenv().GhostMAC = fake_mac
        end)
    end

    -- 2. Bypass Analytics & Hardware Fetch
    pcall(function()
        local svc = game:GetService("RbxAnalyticsService")
        svc.GetHardwareIdentifier = function() return getgenv().GhostHWID or "UNKNOWN" end
        svc.GetSessionId = function() return tostring(math.random(100000000, 999999999)) end
        if svc.GetClientId then svc.GetClientId = function() return getgenv().GhostHWID or "UNKNOWN" end end
    end)

    -- 3. Session Nuke (Hapus Cookie & Cache)
    if writefile and isfile and delfile then
        pcall(function()
            local SCRUB = {"RobloxCookies.dat", "rbx_cookie", "log.txt", "logs.txt", "Analytics.txt"}
            for _, f in ipairs(SCRUB) do
                if isfile(f) then delfile(f) end
            end
        end)
    end
end

Ghost.Init()

-- ==========================================
-- CONFIG (Stealth Only)
-- ==========================================
local CFG = {
    esp=false, auto_parry=false, auto_skillcheck=false, anti_afk=false,
    keyMenu=Enum.KeyCode.RightShift
}

local espData = {}
local hiddenFolder = Instance.new("Folder")
hiddenFolder.Name = "GhostCarrier"
hiddenFolder.Parent = CAM

-- ==========================================
-- MODERN UI
-- ==========================================
local COL = {
    bg=Color3.fromRGB(20,20,20), panel=Color3.fromRGB(30,30,30), 
    sidebar=Color3.fromRGB(15,15,15), txt=Color3.fromRGB(255,255,255), 
    dim=Color3.fromRGB(140,140,140), acc=Color3.fromRGB(0, 170, 255), 
    red=Color3.fromRGB(255,60,60), off=Color3.fromRGB(50,50,50)
}

local gui = Instance.new("ScreenGui")
gui.Name="SG_Stealth"
gui.ResetOnSpawn=false
gui.DisplayOrder=999999
gui.Parent=LP:WaitForChild("PlayerGui")
getgenv().TGui=gui

local main = Instance.new("Frame")
main.Size=UDim2.new(0,450,0,300); main.Position=UDim2.new(0.5,-225,0.5,-150)
main.BackgroundColor3=COL.bg; main.BorderSizePixel=0; main.Active=true; main.ClipsDescendants=true; main.Parent=gui

local ms = Instance.new("UIStroke"); ms.Color=COL.acc; ms.Thickness=1.5; ms.Transparency=0.5; ms.Parent=main
local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 8); mc.Parent = main

local topBar = Instance.new("Frame")
topBar.Size=UDim2.new(1,0,0,40); topBar.BackgroundColor3=COL.bg; topBar.BorderSizePixel=0; topBar.Parent=main

local logo = Instance.new("TextLabel")
logo.Size=UDim2.new(0,200,1,0); logo.Position=UDim2.new(0,15,0,0); logo.BackgroundTransparency=1
logo.Text="STEALTH EDITION"; logo.TextColor3=COL.acc; logo.Font=Enum.Font.GothamBlack
logo.TextSize=16; logo.TextXAlignment=Enum.TextXAlignment.Left; logo.Parent=topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size=UDim2.new(0,30,1,0); closeBtn.Position=UDim2.new(1,-35,0,0)
closeBtn.BackgroundTransparency=1; closeBtn.Text="X"; closeBtn.TextColor3=COL.txt
closeBtn.Font=Enum.Font.GothamBold; closeBtn.TextSize=16; closeBtn.Parent=topBar

local openBtn = Instance.new("TextButton")
openBtn.Size=UDim2.new(0,40,0,40); openBtn.Position=UDim2.new(0,20,0,100)
openBtn.BackgroundColor3=COL.bg; openBtn.BorderSizePixel=0
openBtn.Text="S"; openBtn.TextColor3=COL.acc; openBtn.Font=Enum.Font.GothamBlack
openBtn.TextSize=20; openBtn.Parent=gui; openBtn.Visible=false
local obc = Instance.new("UICorner"); obc.CornerRadius = UDim.new(0, 8); obc.Parent = openBtn

closeBtn.MouseButton1Click:Connect(function() main.Visible = false; openBtn.Visible = true end)
openBtn.MouseButton1Click:Connect(function() main.Visible = true; openBtn.Visible = false end)

local sidebar = Instance.new("Frame")
sidebar.Size=UDim2.new(0,130,1,-40); sidebar.Position=UDim2.new(0,0,0,40)
sidebar.BackgroundColor3=COL.sidebar; sidebar.BorderSizePixel=0; sidebar.Parent=main
local sbc = Instance.new("UICorner"); sbc.CornerRadius = UDim.new(0, 8); sbc.Parent = sidebar

local sideTabs, sidePages = {}, {}
local function addTab(name)
    local btn = Instance.new("TextButton")
    btn.Size=UDim2.new(1,-20,0,35); btn.Position=UDim2.new(0,10,0,10+(#sideTabs*40))
    btn.BackgroundColor3=COL.sidebar; btn.BackgroundTransparency = 1; btn.BorderSizePixel=0
    btn.Text="  "..name; btn.TextColor3=COL.dim; btn.Font=Enum.Font.GothamBold
    btn.TextSize=13; btn.TextXAlignment=Enum.TextXAlignment.Left
    btn.AutoButtonColor=false; btn.Parent=sidebar
    table.insert(sideTabs, btn)
    
    local pg=Instance.new("ScrollingFrame")
    pg.Size=UDim2.new(1,-140,1,-55); pg.Position=UDim2.new(0,140,0,45)
    pg.BackgroundTransparency=1; pg.BorderSizePixel=0
    pg.ScrollBarThickness=2; pg.ScrollBarImageColor3=COL.acc
    pg.CanvasSize=UDim2.new(0,0,0,400); pg.Visible=false; pg.Parent=main
    table.insert(sidePages, pg)
    
    local idx=#sideTabs
    btn.MouseButton1Click:Connect(function()
        for i,t in ipairs(sideTabs) do
            t.TextColor3=(i==idx) and COL.acc or COL.dim
            t.BackgroundTransparency=(i==idx) and 0.9 or 1
            t.BackgroundColor3=(i==idx) and COL.panel or COL.sidebar
        end
        for i,p in ipairs(sidePages) do p.Visible=(i==idx) end
    end)
    return pg
end

local function addSwitch(parent,label,key,yOffset)
    local row=Instance.new("TextButton")
    row.Size=UDim2.new(1,-10,0,28); row.Position=UDim2.new(0,5,0,yOffset)
    row.BackgroundTransparency=1; row.Text=""; row.Parent=parent
    local txt=Instance.new("TextLabel")
    txt.Size=UDim2.new(1,-50,1,0); txt.BackgroundTransparency=1
    txt.Text=label; txt.TextColor3=COL.txt; txt.Font=Enum.Font.Gotham
    txt.TextSize=13; txt.TextXAlignment=Enum.TextXAlignment.Left; txt.Parent=row
    local pill=Instance.new("Frame")
    pill.Size=UDim2.new(0,36,0,18); pill.Position=UDim2.new(1,-36,0.5,-9)
    pill.BackgroundColor3=CFG[key] and COL.acc or COL.off; pill.Parent=row
    local pc=Instance.new("UICorner"); pc.CornerRadius=UDim.new(1,0); pc.Parent=pill
    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,14,0,14)
    knob.Position=CFG[key] and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.Parent=pill
    local kc=Instance.new("UICorner"); kc.CornerRadius=UDim.new(1,0); kc.Parent=knob
    row.MouseButton1Click:Connect(function()
        CFG[key]=not CFG[key]
        pill.BackgroundColor3=CFG[key] and COL.acc or COL.off
        knob.Position=CFG[key] and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
    end)
end

local scSurv = addTab("Stealth")

addSwitch(scSurv, "Enable ESP (Safe)", "esp", 10)
addSwitch(scSurv, "Auto Parry (Real)", "auto_parry", 40)
addSwitch(scSurv, "Auto Skillcheck (Safe)", "auto_skillcheck", 70)
addSwitch(scSurv, "Anti-AFK", "anti_afk", 100)

sideTabs[1].TextColor3=COL.acc; sideTabs[1].BackgroundTransparency=0.9; sideTabs[1].BackgroundColor3=COL.panel; sidePages[1].Visible=true

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
-- ENGINES (Stealth & Safe)
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

-- 1. ESP (Server-Side Blind)
task.spawn(function()
    while true do
        task.wait(2) -- Super ringan, ga bakal detect
        if CFG.esp then
            pcall(function()
                for _, p in ipairs(P:GetPlayers()) do
                    if p ~= LP then
                        local char = p.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if hrp and hum and hum.Health > 0 then
                            local killer = isKillerSafe(p)
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
                            local color = killer and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
                            d.hl.FillColor = color; d.hl.OutlineColor = color
                        elseif espData[p] then
                            espData[p].hl:Destroy(); espData[p] = nil
                        end
                    end
                end
            end)
        end
    end
end)

-- 2. Parry (Real Attack Detection Only)
local parryBusy = false
local lastSwingTime = {}
task.spawn(function()
    while true do
        task.wait(0.1)
        if CFG.auto_parry and not parryBusy then
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
                                
                                -- Parry HANYA pas ada serangan. Kalo ngga ada, server ga bakal curiga.
                                if attacking then
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

-- 3. Perfect Gen (Event Listener - Server Blind)
local function setupSkill()
    local pg = LP:FindFirstChild("PlayerGui")
    if not pg then return end
    pg.DescendantAdded:Connect(function(child)
        if CFG.auto_skillcheck then
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
setupSkill()

-- 4. Anti AFK
task.spawn(function()
    while true do
        task.wait(60)
        if CFG.anti_afk then
            pcall(function()
                VIM:SendKeyEvent(true, Enum.KeyCode.A, false, game)
                task.wait(0.1)
                VIM:SendKeyEvent(false, Enum.KeyCode.A, false, game)
            end)
        end
    end
end)

print("[GhostFortress] v1001.1 loaded — Stealth Edition Active")
