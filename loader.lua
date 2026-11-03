--[[
    SpookingD - Violence District
    v999.9 — Premium Clone (100% Mechanism)
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

local MouseLocked = true
local mouseUnlockKey = Enum.KeyCode.RightControl

-- ==========================================
-- GHOST PROTOCOL (99% BYPASS)
-- ==========================================
local function GhostInit()
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
end
GhostInit()

-- ==========================================
-- CONFIG
-- ==========================================
local CFG = {
    esp=false, killer_esp=true, survivor_esp=true, gen_esp=true,
    crosshair=false, fly=false, noclip=false, godmode=false,
    parry=false, perfect_gen=false, no_skillcheck=false, 
    ws_enabled=false, ws_speed=30, keyMenu=Enum.KeyCode.RightShift
}

local espData = {}
local flyBV = nil
local hiddenFolder = Instance.new("Folder")
hiddenFolder.Name = "GhostCarrier"
hiddenFolder.Parent = CAM or WS

-- ==========================================
-- PREMIUM UI (Tabs)
-- ==========================================
local COL = {
    bg=Color3.fromRGB(15,15,15), panel=Color3.fromRGB(25,25,25), sidebar=Color3.fromRGB(10,10,10),
    line=Color3.fromRGB(50,50,50), txt=Color3.fromRGB(255,255,255), dim=Color3.fromRGB(150,150,150),
    acc=Color3.fromRGB(0, 255, 120), red=Color3.fromRGB(255,0,60), off=Color3.fromRGB(60,60,60)
}

local gui = Instance.new("ScreenGui")
gui.Name="SG_Premium"
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
logo.Text="SPOOKINGD PREMIUM"; logo.TextColor3=COL.acc; logo.Font=Enum.Font.GothamBlack
logo.TextSize=16; logo.TextXAlignment=Enum.TextXAlignment.Left; logo.Parent=topBar

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
    pg.CanvasSize=UDim2.new(0,0,0,400); pg.Visible=false; pg.Parent=main
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
        CFG[key]=not CFG[key]
        pill.BackgroundColor3=CFG[key] and COL.acc or COL.off
        knob.Position=CFG[key] and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6)
    end)
end

local scV = addTab("Visuals")
local scC = addTab("Combat")
local scP = addTab("Player")

addSwitch(scV, "Enable ESP", "esp", 10)
addSwitch(scV, "Killer (Red)", "killer_esp", 40)
addSwitch(scV, "Survivor (White)", "survivor_esp", 70)

addSwitch(scC, "Auto Parry", "parry", 10)
addSwitch(scC, "Auto Perfect Gen", "perfect_gen", 40)
addSwitch(scC, "No Skillcheck", "no_skillcheck", 70)
addSwitch(scC, "God Mode", "godmode", 100)

addSwitch(scP, "Noclip", "noclip", 10)
addSwitch(scP, "Fly", "fly", 40)
addSwitch(scP, "WalkSpeed", "ws_enabled", 70)

sideTabs[1].TextColor3=COL.acc; sideTabs[1].BackgroundTransparency=0.8; sideTabs[1].BackgroundColor3=COL.acc; sidePages[1].Visible=true

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

-- 1. ESP (Billboard Method, Anti-Lag)
task.spawn(function()
    while true do
        task.wait(0.5)
        if CFG.esp then
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
                                if not d or not d.bg.Parent then
                                    if d and d.bg then d.bg:Destroy() end
                                    local bg = Instance.new("BillboardGui")
                                    bg.Adornee = hrp; bg.Size = UDim2.new(0, 150, 0, 30)
                                    bg.StudsOffset = Vector3.new(0, 3, 0); bg.AlwaysOnTop = true
                                    bg.Parent = hiddenFolder
                                    
                                    local txt = Instance.new("TextLabel")
                                    txt.Size = UDim2.new(1,0,1,0); txt.BackgroundTransparency = 1
                                    txt.TextColor3 = Color3.new(1,1,1); txt.TextStrokeTransparency = 0
                                    txt.Font = Enum.Font.GothamBold; txt.TextSize = 12; txt.Parent = bg
                                    
                                    espData[p] = { bg = bg, txt = txt }
                                    d = espData[p]
                                end
                                local color = killer and Color3.fromRGB(255,0,0) or Color3.fromRGB(255,255,255)
                                d.txt.Text = p.Name
                                d.txt.TextColor3 = color
                            end
                        elseif espData[p] then
                            espData[p].bg:Destroy(); espData[p] = nil
                        end
                    end
                end
            end)
        end
    end
end)

-- 2. Movement (Fly, Noclip, WS, Godmode)
RS.Stepped:Connect(function(_,dt)
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

-- 3. Auto Parry (Raycast Method - Anti-Lag)
local parryBusy = false
task.spawn(function()
    while true do
        task.wait(0.1)
        if CFG.parry and not parryBusy then
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
                            if dist < 18 then
                                local params = RaycastParams.new()
                                params.FilterDescendantsInstances = {myChar}
                                params.FilterType = Enum.RaycastFilterType.Exclude
                                local result = WS:Raycast(myHrp.Position, (tHrp.Position - myHrp.Position), params)
                                
                                if not result or dist < 10 then
                                    parryBusy = true
                                    pcall(function()
                                        VIM:SendMouseButtonEvent(0, 0, 2, true, game, 1)
                                        task.wait(0.05)
                                        VIM:SendMouseButtonEvent(0, 0, 2, false, game, 1)
                                    end)
                                    task.wait(0.4) -- Cooldown
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

-- 4. Auto Perfect Gen (Event Listener - Zero Stutter)
local function setupGenListener()
    local pg = LP:FindFirstChild("PlayerGui")
    if not pg then return end
    
    pg.DescendantAdded:Connect(function(child)
        if CFG.perfect_gen then
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

-- 5. No Skillcheck (Skip)
task.spawn(function()
    while true do
        task.wait(0.1)
        if CFG.no_skillcheck and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
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

print("[SpookingD] v999.9 loaded — Premium Clone Active")
