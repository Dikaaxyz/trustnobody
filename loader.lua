--[[
    SpookingD - Violence District
    v70.5 — Interactive GUI Fix (Clickable)
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
-- FAILSAFE GUI PARENTING (Untuk Klik)
-- ==========================================
local guiParent
if typeof(gethui) == "function" then
    local ok, h = pcall(gethui)
    if ok and h then guiParent = h end
end
if not guiParent then
    local ok, h = pcall(function() return game:GetService("CoreGui") end)
    if ok and h then guiParent = h end
end
if not guiParent then
    guiParent = LP:WaitForChild("PlayerGui", 5)
end

-- ==========================================
-- 99% BYPASS
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
pcall(function() game:GetService("RbxAnalyticsService").GetHardwareIdentifier = function() return getgenv().SpoofedHWID end end)
local function scrub()
    if not (writefile and isfile and delfile) then return end
    pcall(function() for _, f in ipairs({"RobloxCookies.dat", "rbx_cookie", "log.txt"}) do if isfile(f) then delfile(f) end end end)
end
scrub()

-- ==========================================
-- 2D SCREEN GUI (Biar Bisa Di-klik)
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
gui.Parent=guiParent
getgenv().TGui=gui

local main = Instance.new("Frame")
main.Size=UDim2.new(0,650,0,450); main.Position=UDim2.new(0.5,-325,0.5,-225)
main.BackgroundColor3=COL.bg; main.BorderSizePixel=0; main.Active=true; main.ClipsDescendants=true; main.Parent=gui

local ms = Instance.new("UIStroke")
ms.Color=COL.acc; ms.Thickness=2; ms.Parent=main

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

local CFG = {
    esp=false, esp_name=true, esp_health=true, esp_dist=true, esp_item=true,
    auto_parry=false, auto_skillcheck=false, no_skillcheck=false, auto_farm=false,
    fly=false, noclip=false, proximity_alert=false,
    bright=false, fpsboost=false,
    ws_enabled=false, ws_speed=16,
    keyMenu=Enum.KeyCode.RightShift
}

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

local function addButton(parent,label,cb,yOffset)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,-10,0,24); btn.Position=UDim2.new(0,5,0,yOffset)
    btn.BackgroundColor3=COL.bg; btn.BorderSizePixel=1; btn.BorderColor3=COL.line
    btn.Text=label; btn.TextColor3=COL.txt; btn.Font=Enum.Font.GothamBold
    btn.TextSize=11; btn.Parent=parent
    btn.MouseButton1Click:Connect(function() if MasterEnabled then pcall(cb) end end)
end

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

local box1 = createBox(scVisual, "Camera", 10, 480, 80)
addSwitch(box1, "Enable ESP", "esp", 30)

local box3 = createBox(scPlayer, "Players", 10, 480, 110)
addSwitch(box3, "Enable ESP", "esp", 30)

local box6 = createBox(scUtility, "No Skillcheck & Farm", 10, 480, 110)
addSwitch(box6, "Auto Skillcheck", "auto_skillcheck", 30)
addSwitch(box6, "No Skillcheck (Skip)", "no_skillcheck", 55)

local box7 = createBox(scUtility, "Auto Parry", 130, 480, 60)
addSwitch(box7, "Auto Parry (Dagger)", "auto_parry", 30)

local box8 = createBox(scMovement, "Toggles", 10, 480, 110)
addSwitch(box8, "Enable Noclip", "noclip", 55)
addSwitch(box8, "Enable WalkSpeed", "ws_enabled", 80)

local box10 = createBox(scSettings, "99% Bypass", 10, 480, 150)
addButton(box10, "Re-Apply HWID Spoof", function()
    BYPASS.loadHwid()
    pcall(function() game:GetService("RbxAnalyticsService").GetHardwareIdentifier = function() return getgenv().SpoofedHWID end end)
    scrub()
end, 30)

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

-- ==========================================
-- ENGINE IMPLEMENTATIONS (SIMPEL)
-- ==========================================
local hiddenFolder = Instance.new("Folder")
hiddenFolder.Name = "SpookCarrier"
hiddenFolder.Parent = CAM or WS
local espData = {}

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
                            local d = espData[p]
                            if not d or not d.hl.Parent then
                                destroyEspEntry(p)
                                local hl = Instance.new("Highlight")
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                hl.Adornee = char
                                hl.Parent = hiddenFolder
                                
                                local bg = Instance.new("BillboardGui")
                                bg.Adornee = hrp; bg.Size = UDim2.new(0, 100, 0, 20)
                                bg.StudsOffset = Vector3.new(0, 3, 0); bg.AlwaysOnTop = true
                                bg.Parent = hiddenFolder
                                
                                local txt = Instance.new("TextLabel")
                                txt.Size = UDim2.new(1,0,1,0); txt.BackgroundTransparency = 1
                                txt.TextColor3 = Color3.new(1,1,1); txt.TextStrokeTransparency = 0
                                txt.Font = Enum.Font.GothamBold; txt.TextSize = 12; txt.Parent = bg
                                
                                espData[p] = { hl = hl, bg = bg, txt = txt }
                                d = espData[p]
                            end
                            
                            local killer = isKillerSafe(p)
                            local color = killer and Color3.fromRGB(255,0,0) or Color3.fromRGB(255,255,255)
                            
                            d.hl.FillColor = color; d.hl.OutlineColor = color
                            d.txt.Text = p.Name
                        else
                            destroyEspEntry(p)
                        end
                    end
                end
            end)
        else
            for p in pairs(espData) do destroyEspEntry(p) end
        end
    end
end)

local parryBusy = false
task.spawn(function()
    while true do
        task.wait(0.1)
        if MasterEnabled and CFG.auto_parry and not parryBusy then
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
        if MasterEnabled and CFG.auto_skillcheck and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
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

print("[SpookingD] v70.5 loaded — UI Interactive")
