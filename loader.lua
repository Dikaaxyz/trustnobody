--[[
    SpookingD - Violence District
    v8000.0 — The Real Fix (Executor Native)
]]

if not game:IsLoaded() then game.Loaded:Wait() end
if getgenv().TGui then pcall(function() getgenv().TGui:Destroy() end) end

task.wait(1)

local P    = game:GetService("Players")
local RS   = game:GetService("RunService")
local UIS  = game:GetService("UserInputService")
local WS   = game:GetService("Workspace")
local VIM  = game:GetService("VirtualInputManager")
local Tween = game:GetService("TweenService")
local LP   = P.LocalPlayer
local CAM  = WS.CurrentCamera

local MouseLocked = true
local mouseUnlockKey = Enum.KeyCode.RightControl
local HAS_DRAWING = pcall(function() return Drawing.new("Circle") end)

-- ==========================================
-- EXECUTOR NATIVE INPUTS (Bypass VIM Block)
-- ==========================================
local function RightClick()
    if type(mouse2click) == "function" then
        mouse2click()
    else
        VIM:SendMouseButtonEvent(0, 0, 2, true, game, 1)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(0, 0, 2, false, game, 1)
    end
end

local function PressSpace()
    if type(keypress) == "function" then
        keypress(0x20)
    else
        VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end
end

-- ==========================================
-- GHOST BYPASS
-- ==========================================
pcall(function()
    local f = "vd_ghost_v8.dat"
    local v = tostring(math.random(10000000, 99999999)) .. "_G"
    if writefile and isfile then writefile(f, v) end
    getgenv().GhostHWID = v
    local svc = game:GetService("RbxAnalyticsService")
    svc.GetHardwareIdentifier = function() return getgenv().GhostHWID end
end)

-- ==========================================
-- CONFIG
-- ==========================================
local CFG = {
    smart_parry=false, safe_parry=true, show_smart_range=false, smart_range=15, facing_tol=0.3,
    classic_parry=false, show_classic_range=false, classic_range=15,
    auto_skillcheck=false, hit_method="Space",
    esp=false, anti_afk=false,
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
    bg=Color3.fromRGB(15,15,17), panel=Color3.fromRGB(25,25,30), 
    sidebar=Color3.fromRGB(10,10,12), txt=Color3.fromRGB(255,255,255), 
    dim=Color3.fromRGB(150,150,160), acc=Color3.fromRGB(255, 50, 50), 
    red=Color3.fromRGB(255,60,60), off=Color3.fromRGB(40,40,45)
}

local gui = Instance.new("ScreenGui")
gui.Name="SG_RealFix"
gui.ResetOnSpawn=false
gui.DisplayOrder=999999
gui.Parent=LP:WaitForChild("PlayerGui")
getgenv().TGui=gui

local main = Instance.new("Frame")
main.Size=UDim2.new(0,600,0,400); main.Position=UDim2.new(0.5,-300,0.5,-200)
main.BackgroundColor3=COL.bg; main.BorderSizePixel=0; main.Active=true; main.ClipsDescendants=true; main.Parent=gui
local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 8); mc.Parent = main
local ms = Instance.new("UIStroke"); ms.Color=COL.acc; ms.Thickness=1; ms.Transparency=0.5; ms.Parent=main

local topBar = Instance.new("Frame")
topBar.Size=UDim2.new(1,0,0,40); topBar.BackgroundColor3=COL.bg; topBar.BorderSizePixel=0; topBar.Parent=main

local logo = Instance.new("TextLabel")
logo.Size=UDim2.new(0,200,1,0); logo.Position=UDim2.new(0,15,0,0); logo.BackgroundTransparency=1
logo.Text="SPOOKINGD FIX"; logo.TextColor3=COL.txt; logo.Font=Enum.Font.GothamBold
logo.TextSize=16; logo.TextXAlignment=Enum.TextXAlignment.Left; logo.Parent=topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size=UDim2.new(0,30,1,0); closeBtn.Position=UDim2.new(1,-35,0,0)
closeBtn.BackgroundTransparency=1; closeBtn.Text="X"; closeBtn.TextColor3=COL.dim
closeBtn.Font=Enum.Font.GothamBold; closeBtn.TextSize=14; closeBtn.Parent=topBar

local openBtn = Instance.new("TextButton")
openBtn.Size=UDim2.new(0,40,0,40); openBtn.Position=UDim2.new(0,20,0,100)
openBtn.BackgroundColor3=COL.bg; openBtn.BorderSizePixel=0
openBtn.Text="S"; openBtn.TextColor3=COL.acc; openBtn.Font=Enum.Font.GothamBlack
openBtn.TextSize=18; openBtn.Parent=gui; openBtn.Visible=false
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
    btn.TextSize=12; btn.TextXAlignment=Enum.TextXAlignment.Left
    btn.AutoButtonColor=false; btn.Parent=sidebar
    table.insert(sideTabs, btn)
    
    local pg=Instance.new("ScrollingFrame")
    pg.Size=UDim2.new(1,-140,1,-55); pg.Position=UDim2.new(0,140,0,45)
    pg.BackgroundTransparency=1; pg.BorderSizePixel=0
    pg.ScrollBarThickness=2; pg.ScrollBarImageColor3=COL.acc
    pg.CanvasSize=UDim2.new(0,0,0,800); pg.Visible=false; pg.Parent=main
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
    txt.TextSize=12; txt.TextXAlignment=Enum.TextXAlignment.Left; txt.Parent=row
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
        local targetColor = CFG[key] and COL.acc or COL.off
        local targetPos = CFG[key] and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
        Tween:Create(pill, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        Tween:Create(knob, TweenInfo.new(0.2), {Position = targetPos}):Play()
    end)
end

local function addSlider(parent,label,key,min,max,yOffset)
    local frame=Instance.new("Frame")
    frame.Size=UDim2.new(1,-10,0,28); frame.Position=UDim2.new(0,5,0,yOffset)
    frame.BackgroundTransparency=1; frame.Parent=parent
    local txt=Instance.new("TextLabel")
    txt.Size=UDim2.new(1,-60,1,0); txt.BackgroundTransparency=1
    txt.Text=label; txt.TextColor3=COL.txt; txt.Font=Enum.Font.Gotham
    txt.TextSize=12; txt.TextXAlignment=Enum.TextXAlignment.Left; txt.Parent=frame
    local input=Instance.new("TextBox")
    input.Size=UDim2.new(0,40,0,20); input.Position=UDim2.new(1,-40,0.5,-10)
    input.BackgroundColor3=COL.bg; input.BorderSizePixel=1; input.BorderColor3=COL.off
    input.Text=tostring(CFG[key]); input.TextColor3=COL.acc
    input.Font=Enum.Font.GothamBold; input.TextSize=11; input.Parent=frame
    local ic = Instance.new("UICorner"); ic.CornerRadius = UDim.new(0, 4); ic.Parent = input
    input.FocusLost:Connect(function()
        local val=tonumber(input.Text)
        if val then CFG[key]=math.clamp(val,min,max) end
        input.Text=tostring(CFG[key])
    end)
end

local scParry = addTab("Parry")
local scSkill = addTab("Skillcheck")
local scMisc = addTab("Misc")

addSwitch(scParry, "Smart Auto Parry", "smart_parry", 10)
addSwitch(scParry, "Safe Parry", "safe_parry", 40)
addSwitch(scParry, "Show Smart Range", "show_smart_range", 70)
addSlider(scParry, "Smart Range", "smart_range", 5, 30, 100)
addSwitch(scParry, "Classic Auto Parry", "classic_parry", 140)
addSwitch(scParry, "Show Classic Range", "show_classic_range", 170)
addSlider(scParry, "Classic Range", "classic_range", 5, 30, 200)

addSwitch(scSkill, "Auto Hit Skill Checks", "auto_skillcheck", 10)
addSwitch(scMisc, "Enable ESP", "esp", 10)
addSwitch(scMisc, "Anti-AFK", "anti_afk", 40)

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

local smartCircle, classicCircle
if HAS_DRAWING then
    smartCircle = Drawing.new("Circle"); smartCircle.Thickness = 1.5; smartCircle.Filled = false; smartCircle.Color = Color3.fromRGB(0, 255, 255)
    classicCircle = Drawing.new("Circle"); classicCircle.Thickness = 1.5; classicCircle.Filled = false; classicCircle.Color = Color3.fromRGB(255, 0, 0)
end

RS.RenderStepped:Connect(function()
    if not HAS_DRAWING then return end
    local myChar = LP.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local cam = WS.CurrentCamera
    if not myHrp or not cam then return end

    local footPos, onScreen = cam:WorldToViewportPoint(myHrp.Position - Vector3.new(0, 3, 0))
    if onScreen then
        if CFG.show_smart_range and CFG.smart_parry then
            local edge, onScreenEdge = cam:WorldToViewportPoint(myHrp.Position - Vector3.new(0, 3, 0) + Vector3.new(CFG.smart_range, 0, 0))
            if onScreenEdge then
                smartCircle.Visible = true
                smartCircle.Position = Vector2.new(footPos.X, footPos.Y)
                smartCircle.Radius = (edge - footPos).Magnitude
            else smartCircle.Visible = false end
        else smartCircle.Visible = false end
        if CFG.show_classic_range and CFG.classic_parry then
            local edge, onScreenEdge = cam:WorldToViewportPoint(myHrp.Position - Vector3.new(0, 3, 0) + Vector3.new(CFG.classic_range, 0, 0))
            if onScreenEdge then
                classicCircle.Visible = true
                classicCircle.Position = Vector2.new(footPos.X, footPos.Y)
                classicCircle.Radius = (edge - footPos).Magnitude
            else classicCircle.Visible = false end
        else classicCircle.Visible = false end
    else
        if smartCircle then smartCircle.Visible = false end
        if classicCircle then classicCircle.Visible = false end
    end
end)

-- SMART PARRY (Detect Attack)
local smartBusy = false
task.spawn(function()
    while true do
        task.wait(0.05)
        if CFG.smart_parry and not smartBusy then
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
                            if dist < CFG.smart_range then
                                local dir = (myHrp.Position - tHrp.Position).Unit
                                local facingUs = tHrp.CFrame.LookVector:Dot(dir) > CFG.facing_tol
                                local attacking = true
                                if CFG.safe_parry then
                                    attacking = false
                                    local animator = hum:FindFirstChildOfClass("Animator")
                                    if animator then
                                        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                                            local n = track.Name:lower()
                                            if track.WeightCurrent > 0.1 and not (n:find("idle") or n:find("walk") or n:find("run") or n:find("fall")) then
                                                attacking = true; break
                                            end
                                        end
                                    end
                                end
                                if facingUs and attacking then
                                    smartBusy = true
                                    RightClick()
                                    task.wait(0.3)
                                    smartBusy = false
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

-- CLASSIC PARRY (Spam Click)
local classicBusy = false
task.spawn(function()
    while true do
        task.wait(0.1)
        if CFG.classic_parry and not classicBusy then
            local myChar = LP.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myHrp then
                for _, p in ipairs(P:GetPlayers()) do
                    if p ~= LP and isKillerSafe(p) then
                        local char = p.Character
                        local tHrp = char and char:FindFirstChild("HumanoidRootPart")
                        if tHrp and (tHrp.Position - myHrp.Position).Magnitude < CFG.classic_range then
                            classicBusy = true
                            RightClick()
                            task.wait(0.3)
                            classicBusy = false
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- AUTO SKILLCHECK (Broad Scanner)
task.spawn(function()
    while true do
        task.wait(0.01)
        if CFG.auto_skillcheck then
            local pg = LP:FindFirstChild("PlayerGui")
            if pg then
                -- Scan all rotating UI elements
                local rotatingUI = {}
                for _, obj in ipairs(pg:GetDescendants()) do
                    if obj:IsA("ImageLabel") or obj:IsA("Frame") then
                        if obj.Rotation > 0 and obj.Rotation < 360 and obj.Visible and obj.AbsoluteSize.X > 10 then
                            table.insert(rotatingUI, obj)
                        end
                    end
                end
                
                -- If we find a rotating UI (the needle), check if there's a zone
                for _, needle in ipairs(rotatingUI) do
                    local parent = needle.Parent
                    local zone = nil
                    for _, child in ipairs(parent:GetChildren()) do
                        if child ~= needle and (child:IsA("Frame") or child:IsA("ImageLabel")) and child.Visible then
                            -- Zone is usually a stationary small block inside the circle
                            if child.AbsoluteSize.X < needle.AbsoluteSize.X and child.AbsoluteSize.X > 10 then
                                zone = child
                                break
                            end
                        end
                    end
                    
                    if zone then
                        local centerX, centerY = parent.AbsolutePosition.X + parent.AbsoluteSize.X/2, parent.AbsolutePosition.Y + parent.AbsoluteSize.Y/2
                        local needleAngle = math.rad(needle.Rotation)
                        local radius = needle.AbsoluteSize.Y / 2
                        local needleEndX = centerX + math.cos(needleAngle) * radius
                        local needleEndY = centerY + math.sin(needleAngle) * radius
                        
                        local zoneX = zone.AbsolutePosition.X + zone.AbsoluteSize.X/2
                        local zoneY = zone.AbsolutePosition.Y + zone.AbsoluteSize.Y/2
                        
                        -- Check distance between needle tip and zone center
                        local dist = math.sqrt((needleEndX - zoneX)^2 + (needleEndY - zoneY)^2)
                        
                        if dist < 20 then -- Tolerance
                            PressSpace()
                            task.wait(0.2)
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- ESP
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
                            local color = isKillerSafe(p) and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,255)
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

-- Anti-AFK
task.spawn(function()
    while true do
        task.wait(60)
        if CFG.anti_afk then
            if type(keypress) == "function" then keypress(0x41) else VIM:SendKeyEvent(true, Enum.KeyCode.A, false, game) end
            task.wait(0.1)
            if type(keyrelease) == "function" then keyrelease(0x41) else VIM:SendKeyEvent(false, Enum.KeyCode.A, false, game) end
        end
    end
end)

print("[SpookingD] v8000.0 loaded — Executor Native Active")
