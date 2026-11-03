--[[
    SpookingD - Violence District
    v30000.0 — The Absolute Truth (No Loop, No Stutter)
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

-- ==========================================
-- 99% BYPASS
-- ==========================================
pcall(function()
    local svc = game:GetService("RbxAnalyticsService")
    svc.GetHardwareIdentifier = function() return "ABSOLUTE_TRUTH_99" end
end)

-- ==========================================
-- CONFIG
-- ==========================================
local CFG = {
    auto_parry=false, auto_skillcheck=false, esp=false,
    keyMenu=Enum.KeyCode.RightShift
}

local espData = {}
local hiddenFolder = Instance.new("Folder")
hiddenFolder.Name = "GhostCarrier"
hiddenFolder.Parent = CAM

-- ==========================================
-- UI
-- ==========================================
local COL = {
    bg=Color3.fromRGB(18,18,20), panel=Color3.fromRGB(28,28,32), 
    sidebar=Color3.fromRGB(12,12,14), txt=Color3.fromRGB(255,255,255), 
    dim=Color3.fromRGB(140,140,150), acc=Color3.fromRGB(0, 200, 255), 
    red=Color3.fromRGB(255,60,60), off=Color3.fromRGB(50,50,55)
}

local gui = Instance.new("ScreenGui")
gui.Name="SG_Absolute"
gui.ResetOnSpawn=false
gui.DisplayOrder=999999
gui.Parent=LP:WaitForChild("PlayerGui")
getgenv().TGui=gui

local main = Instance.new("Frame")
main.Size=UDim2.new(0,500,0,320); main.Position=UDim2.new(0.5,-250,0.5,-160)
main.BackgroundColor3=COL.bg; main.BorderSizePixel=0; main.Active=true; main.ClipsDescendants=true; main.Parent=gui
local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 8); mc.Parent = main
local ms = Instance.new("UIStroke"); ms.Color=COL.acc; ms.Thickness=1.5; ms.Transparency=0.5; ms.Parent=main

local topBar = Instance.new("Frame")
topBar.Size=UDim2.new(1,0,0,40); topBar.BackgroundColor3=COL.bg; topBar.BorderSizePixel=0; topBar.Parent=main

local logo = Instance.new("TextLabel")
logo.Size=UDim2.new(0,200,1,0); logo.Position=UDim2.new(0,15,0,0); logo.BackgroundTransparency=1
logo.Text="ABSOLUTE TRUTH"; logo.TextColor3=COL.acc; logo.Font=Enum.Font.GothamBlack
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

local function addSwitch(label,key,yOffset)
    local row=Instance.new("TextButton")
    row.Size=UDim2.new(1,-20,0,30); row.Position=UDim2.new(0,10,0,yOffset)
    row.BackgroundTransparency=1; row.Text=""; row.Parent=main
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
        local targetColor = CFG[key] and COL.acc or COL.off
        local targetPos = CFG[key] and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
        Tween:Create(pill, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        Tween:Create(knob, TweenInfo.new(0.2), {Position = targetPos}):Play()
    end)
end

addSwitch("Auto Parry (Raycast)", "auto_parry", 50)
addSwitch("Auto Skillcheck (Hook)", "auto_skillcheck", 90)
addSwitch("Enable ESP", "esp", 130)

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
-- ENGINES (TRUTH)
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

-- 2. AUTO PARRY (Raycast + Tool detection)
local parryBusy = false
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
                            if dist < 18 then
                                local hasTool = char:FindFirstChildWhichIsA("Tool")
                                if hasTool then
                                    local params = RaycastParams.new()
                                    params.FilterDescendantsInstances = {myChar}
                                    params.FilterType = Enum.RaycastFilterType.Exclude
                                    local result = WS:Raycast(myHrp.Position, (tHrp.Position - myHrp.Position), params)
                                    
                                    if not result or dist < 10 then
                                        parryBusy = true
                                        if type(mouse2click) == "function" then mouse2click() else
                                            VIM:SendMouseButtonEvent(0, 0, 2, true, game, 1)
                                            task.wait(0.05)
                                            VIM:SendMouseButtonEvent(0, 0, 2, false, game, 1)
                                        end
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

-- 3. AUTO SKILLCHECK (Hook Detection + Math)
local function setupSkillcheck()
    local pg = LP:FindFirstChild("PlayerGui")
    if not pg then return end
    
    -- Listen to UI added
    pg.DescendantAdded:Connect(function(obj)
        if not CFG.auto_skillcheck then return end
        if obj:IsA("ImageLabel") or obj:IsA("Frame") then
            -- If it's a rotating needle
            obj:GetPropertyChangedSignal("Rotation"):Connect(function()
                if not CFG.auto_skillcheck then return end
                if obj.Rotation > 0 and obj.Visible and obj.AbsoluteSize.X > 20 then
                    local parent = obj.Parent
                    local zone = nil
                    for _, child in ipairs(parent:GetChildren()) do
                        if (child:IsA("Frame") or child:IsA("ImageLabel")) and child ~= obj and child.Visible and child.Rotation == 0 then
                            if child.AbsoluteSize.X > 5 and child.AbsoluteSize.X < obj.AbsoluteSize.X then
                                zone = child; break
                            end
                        end
                    end
                    
                    if zone then
                        local centerX = parent.AbsolutePosition.X + parent.AbsoluteSize.X / 2
                        local centerY = parent.AbsolutePosition.Y + parent.AbsoluteSize.Y / 2
                        local needleAngle = obj.Rotation
                        local zoneCenterX = zone.AbsolutePosition.X + zone.AbsoluteSize.X / 2
                        local zoneCenterY = zone.AbsolutePosition.Y + zone.AbsoluteSize.Y / 2
                        local zoneAngle = math.deg(math.atan2(zoneCenterY - centerY, zoneCenterX - centerX))
                        if zoneAngle < 0 then zoneAngle = zoneAngle + 360 end
                        
                        local diff = math.abs(needleAngle - zoneAngle)
                        if diff > 180 then diff = 360 - diff end
                        
                        if diff < 15 then
                            if type(keypress) == "function" then keypress(0x20) else
                                VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                                task.wait(0.05)
                                VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                            end
                        end
                    end
                end
            end)
        end
    end)
end
task.wait(2)
setupSkillcheck()

print("[SpookingD] v30000.0 loaded — Absolute Truth")
