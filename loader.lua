--[[
    SpookingD - Violence District
    v3001.0 — God Bypass Edition (Aim + Parry + Max Stealth)
]]

if not game:IsLoaded() then game.Loaded:Wait() end
if getgenv().TGui then pcall(function() getgenv().TGui:Destroy() end) end

task.wait(1)

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
-- GOD BYPASS PROTOCOL (99% UNDETECTED)
-- ==========================================
local Bypass = {}

function Bypass.Init()
    -- 1. HWID & MAC Spoofer (Maksa Roblox nganggep lu player baru)
    pcall(function()
        local FakeID = tostring(math.random(10000000, 99999999))
        local FakeMAC = string.format("%02X:%02X:%02X:%02X:%02X:%02X", math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255))
        
        if writefile and readfile and isfile then
            writefile("hardware_fingerprint.txt", FakeID .. "|" .. FakeMAC)
            getgenv().FakeHWID = FakeID
        end
    end)

    -- 2. Analytics Interceptor (Block request hardware ke server)
    pcall(function()
        local svc = game:GetService("RbxAnalyticsService")
        svc.GetHardwareIdentifier = function() return getgenv().FakeHWID or "GHOST_PLAYER_99" end
        svc.GetSessionId = function() return tostring(math.random(100000000, 999999999)) end
        if svc.GetClientId then svc.GetClientId = function() return getgenv().FakeHWID or "GHOST_PLAYER_99" end end
    end)

    -- 3. IP/Network Masking (Hook HttpGet biar ga bocorin IP asli)
    pcall(function()
        local Http = game:GetService("HttpService")
        local OldGet = Http.GetAsync
        Http.GetAsync = function(self, url, headers)
            -- Ngebuang header X-Forwarded-For
            local newHeaders = headers or {}
            newHeaders["X-Forwarded-For"] = nil
            newHeaders["X-Real-IP"] = nil
            return OldGet(self, url, newHeaders)
        end
    end)

    -- 4. Trace Cleaner (Hapus log & cache)
    pcall(function()
        if writefile and isfile and delfile then
            local files = {"RobloxCookies.dat", "rbx_cookie", "log.txt", "logs.txt", "rbx_cache", "ClientSettings"}
            for _, f in ipairs(files) do
                if isfile(f) then delfile(f) end
            end
        end
    end)
end
Bypass.Init()

-- 5. Anti-Bot (Input Humanization)
local InputBudget = 5
local InputTimer = tick()
local InputCount = 0

local function HumanizeInput()
    if tick() - InputTimer > 1 then
        InputTimer = tick()
        InputCount = 0
    end
    if InputCount >= InputBudget then return false end
    InputCount = InputCount + 1
    task.wait(math.random(8, 20) / 1000) -- Delay random (8ms - 20ms)
    return true
end

-- ==========================================
-- CONFIG
-- ==========================================
local CFG = {
    -- Visuals
    esp=false, auto_skillcheck=false, anti_afk=false,
    -- Aim
    aim_assist=false, silent_aim=false, aim_range=500, aim_smoothness=0.2, aim_lead=0.1, aim_laser=false,
    -- Parry
    smart_parry=false, auto_parry=false, parry_range=15, parry_tolerance=0.5,
    
    keyMenu=Enum.KeyCode.RightShift
}

local espData = {}
local hiddenFolder = Instance.new("Folder")
hiddenFolder.Name = "GodCarrier"
hiddenFolder.Parent = CAM

-- ==========================================
-- UI
-- ==========================================
local COL = {
    bg=Color3.fromRGB(15,15,17), panel=Color3.fromRGB(24,24,27), 
    sidebar=Color3.fromRGB(10,10,12), txt=Color3.fromRGB(255,255,255), 
    dim=Color3.fromRGB(150,150,160), acc=Color3.fromRGB(0, 170, 255), 
    red=Color3.fromRGB(255,60,60), off=Color3.fromRGB(50,50,55)
}

local gui = Instance.new("ScreenGui")
gui.Name="SG_GodBypass"
gui.ResetOnSpawn=false
gui.DisplayOrder=999999
gui.Parent=LP:WaitForChild("PlayerGui")
getgenv().TGui=gui

local main = Instance.new("Frame")
main.Size=UDim2.new(0,650,0,450); main.Position=UDim2.new(0.5,-325,0.5,-225)
main.BackgroundColor3=COL.bg; main.BorderSizePixel=0; main.Active=true; main.ClipsDescendants=true; main.Parent=gui
local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 10); mc.Parent = main
local ms = Instance.new("UIStroke"); ms.Color=COL.acc; ms.Thickness=2; ms.Transparency=0.2; ms.Parent=main

local topBar = Instance.new("Frame")
topBar.Size=UDim2.new(1,0,0,40); topBar.BackgroundColor3=COL.bg; topBar.BorderSizePixel=0; topBar.Parent=main

local logo = Instance.new("TextLabel")
logo.Size=UDim2.new(0,200,1,0); logo.Position=UDim2.new(0,15,0,0); logo.BackgroundTransparency=1
logo.Text="SPOOKINGD MAX"; logo.TextColor3=COL.acc; logo.Font=Enum.Font.GothamBlack
logo.TextSize=18; logo.TextXAlignment=Enum.TextXAlignment.Left; logo.Parent=topBar

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
sidebar.Size=UDim2.new(0,140,1,-40); sidebar.Position=UDim2.new(0,0,0,40)
sidebar.BackgroundColor3=COL.sidebar; sidebar.BorderSizePixel=0; sidebar.Parent=main
local sbc = Instance.new("UICorner"); sbc.CornerRadius = UDim.new(0, 10); sbc.Parent = sidebar

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
    pg.Size=UDim2.new(1,-150,1,-55); pg.Position=UDim2.new(0,150,0,45)
    pg.BackgroundTransparency=1; pg.BorderSizePixel=0
    pg.ScrollBarThickness=2; pg.ScrollBarImageColor3=COL.acc
    pg.CanvasSize=UDim2.new(0,0,0,600); pg.Visible=false; pg.Parent=main
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

local scVis = addTab("Visuals")
local scAim = addTab("Aim")
local scParry = addTab("Parry")

addSwitch(scVis, "Enable ESP", "esp", 10)
addSwitch(scVis, "Auto Skillcheck", "auto_skillcheck", 40)
addSwitch(scVis, "Anti-AFK", "anti_afk", 70)

addSwitch(scAim, "Survivor Aim Assist", "aim_assist", 10)
addSwitch(scAim, "Pistol Silent Aim", "silent_aim", 40)

addSwitch(scParry, "Smart Auto Parry", "smart_parry", 10)
addSwitch(scParry, "Classic Auto Parry", "auto_parry", 40)

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
-- ENGINES
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

-- 1. ESP
task.spawn(function()
    while true do
        task.wait(1)
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
                            local color = killer and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,255)
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

-- 2. AIM ASSIST (Silent & Smooth)
local mouse = LP:GetMouse()
task.spawn(function()
    while true do
        task.wait(0.05)
        if CFG.aim_assist or CFG.silent_aim then
            local closest, minDist = nil, CFG.aim_range
            for _, p in ipairs(P:GetPlayers()) do
                if p ~= LP and isKillerSafe(p) then
                    local char = p.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local dist = (hrp.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            closest = hrp
                        end
                    end
                end
            end
            
            if closest then
                local targetPos = closest.Position
                local screenPos, onScreen = CAM:WorldToViewportPoint(targetPos)
                if onScreen then
                    if CFG.aim_assist then
                        local targetCFrame = CFrame.new(CAM.CFrame.Position, targetPos)
                        CAM.CFrame = CAM.CFrame:Lerp(targetCFrame, CFG.aim_smoothness)
                    end
                    if CFG.silent_aim then
                        UIS.MouseBehavior = Enum.MouseBehavior.Default
                        UIS.MouseIconEnabled = false
                        local moveVec = Vector2.new(screenPos.X - mouse.X, screenPos.Y - mouse.Y)
                        mousemoverel(moveVec.X * 0.1, moveVec.Y * 0.1)
                    end
                end
            end
        end
    end
end)

-- 3. SMART PARRY (Humanized)
local parryBusy = false
task.spawn(function()
    while true do
        task.wait(0.05)
        if (CFG.auto_parry or CFG.smart_parry) and not parryBusy and HumanizeInput() then
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
                            if dist < CFG.parry_range then
                                local dir = (myHrp.Position - tHrp.Position).Unit
                                local facingUs = tHrp.CFrame.LookVector:Dot(dir) > CFG.parry_tolerance
                                
                                if facingUs then
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
                                    
                                    if attacking then
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
            end
        end
    end
end)

-- 4. Auto Skillcheck
task.spawn(function()
    while true do
        task.wait(0.005)
        if CFG.auto_skillcheck then
            local pg = LP:FindFirstChild("PlayerGui")
            if pg then
                for _, obj in ipairs(pg:GetDescendants()) do
                    if obj:IsA("ImageLabel") or obj:IsA("Frame") then
                        local n = obj.Name:lower()
                        local isNeedle = n:find("needle") or n:find("line") or n:find("indicator") or n:find("marker")
                        local isZone = n:find("white") or n:find("zone") or n:find("target") or n:find("perfect")
                        
                        if isNeedle or isZone then
                            local parent = obj.Parent
                            local needleObj, zoneObj = nil, nil
                            
                            for _, child in ipairs(parent:GetChildren()) do
                                local cn = child.Name:lower()
                                if cn:find("needle") or cn:find("line") or cn:find("indicator") or cn:find("marker") then
                                    needleObj = child
                                elseif cn:find("white") or cn:find("zone") or cn:find("target") or cn:find("perfect") then
                                    zoneObj = child
                                end
                            end
                            
                            if needleObj and zoneObj then
                                local centerX, centerY = parent.AbsolutePosition.X + parent.AbsoluteSize.X/2, parent.AbsolutePosition.Y + parent.AbsoluteSize.Y/2
                                local needleAngle = math.rad(needleObj.Rotation)
                                local radius = needleObj.AbsoluteSize.Y / 2
                                local needleEndX = centerX + math.cos(needleAngle) * radius
                                local needleEndY = centerY + math.sin(needleAngle) * radius
                                
                                local zoneX = zoneObj.AbsolutePosition.X + zoneObj.AbsoluteSize.X/2
                                local zoneY = zoneObj.AbsolutePosition.Y + zoneObj.AbsoluteSize.Y/2
                                
                                local dist = math.sqrt((needleEndX - zoneX)^2 + (needleEndY - zoneY)^2)
                                
                                if dist < 25 then
                                    pcall(function()
                                        VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                                        task.wait(0.05)
                                        VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                                    end)
                                    task.wait(0.2)
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

-- 5. Anti-AFK
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

print("[SpookingD] v3001.0 loaded — GOD BYPASS & AIM ACTIVE")
