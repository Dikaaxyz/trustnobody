--[[
    SpookingD - Violence District
    v70.7 — Clickable & Unlocked (Final Fix)
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
-- 99% BYPASS
-- ==========================================
pcall(function()
    game:GetService("RbxAnalyticsService").GetHardwareIdentifier = function() return "SPOOK_CLICK" end
end)

-- ==========================================
-- 2D SCREEN GUI
-- ==========================================
task.wait(1)

local COL = {
    bg=Color3.fromRGB(15,15,15), panel=Color3.fromRGB(25,25,25), sidebar=Color3.fromRGB(10,10,10),
    line=Color3.fromRGB(50,50,50), txt=Color3.fromRGB(255,255,255), dim=Color3.fromRGB(150,150,150),
    acc=Color3.fromRGB(0, 255, 120), red=Color3.fromRGB(255,0,60), off=Color3.fromRGB(60,60,60)
}

local gui = Instance.new("ScreenGui")
gui.Name="SG_Final"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=999999
gui.Parent = LP:WaitForChild("PlayerGui")
getgenv().TGui=gui

local main = Instance.new("Frame")
main.Size=UDim2.new(0,450,0,350); main.Position=UDim2.new(0.5,-225,0.5,-175)
main.BackgroundColor3=COL.bg; main.BorderSizePixel=0; main.Active=true; main.ClipsDescendants=true; main.Parent=gui

local ms = Instance.new("UIStroke")
ms.Color=COL.acc; ms.Thickness=2; ms.Parent=main

local topBar = Instance.new("Frame")
topBar.Size=UDim2.new(1,0,0,35); topBar.BackgroundColor3=COL.sidebar; topBar.BorderSizePixel=0; topBar.Parent=main

local logo = Instance.new("TextLabel")
logo.Size=UDim2.new(1,0,0,35); logo.Position=UDim2.new(0,10,0,0); logo.BackgroundTransparency=1
logo.Text="SPOOKINGD FINAL"; logo.TextColor3=COL.acc; logo.Font=Enum.Font.GothamBlack
logo.TextSize=16; logo.TextXAlignment=Enum.TextXAlignment.Left; logo.Parent=topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size=UDim2.new(0,30,0,30); closeBtn.Position=UDim2.new(1,-35,0,2)
closeBtn.BackgroundTransparency=1; closeBtn.Text="X"; closeBtn.TextColor3=COL.red
closeBtn.Font=Enum.Font.GothamBlack; closeBtn.TextSize=16; closeBtn.Parent=topBar

local openBtn = Instance.new("TextButton")
openBtn.Size=UDim2.new(0,40,0,40); openBtn.Position=UDim2.new(0,20,0,100)
openBtn.BackgroundColor3=COL.bg; openBtn.BorderSizePixel=2; openBtn.BorderColor3=COL.acc
openBtn.Text="S"; openBtn.TextColor3=COL.acc; openBtn.Font=Enum.Font.GothamBlack
openBtn.TextSize=22; openBtn.Parent=gui; openBtn.Visible=false
local obc = Instance.new("UICorner"); obc.CornerRadius = UDim.new(0, 8); obc.Parent = openBtn

closeBtn.MouseButton1Click:Connect(function() main.Visible=false; openBtn.Visible=true end)
openBtn.MouseButton1Click:Connect(function() main.Visible=true; openBtn.Visible=false end)

local masterBtn = Instance.new("TextButton")
masterBtn.Size=UDim2.new(1,-20,0,30); masterBtn.Position=UDim2.new(0,10,0,45)
masterBtn.BackgroundColor3=COL.red; masterBtn.BorderSizePixel=0
masterBtn.Text="ENABLE SCRIPT"; masterBtn.TextColor3=Color3.new(1,1,1)
masterBtn.Font=Enum.Font.GothamBold; masterBtn.TextSize=12; masterBtn.Parent=main
local mbc = Instance.new("UICorner"); mbc.CornerRadius = UDim.new(0, 4); mbc.Parent = masterBtn

local CFG = { esp=false, auto_parry=false, auto_skillcheck=false }

local function addSwitch(parent,label,key,yOffset)
    local row=Instance.new("TextButton")
    row.Size=UDim2.new(1,-20,0,30); row.Position=UDim2.new(0,10,0,yOffset)
    row.BackgroundTransparency=1; row.Text=""; row.Parent=parent
    local txt=Instance.new("TextLabel")
    txt.Size=UDim2.new(1,-50,1,0); txt.BackgroundTransparency=1
    txt.Text=label; txt.TextColor3=COL.txt; txt.Font=Enum.Font.Gotham
    txt.TextSize=13; txt.TextXAlignment=Enum.TextXAlignment.Left; txt.Parent=row
    local pill=Instance.new("Frame")
    pill.Size=UDim2.new(0,40,0,20); pill.Position=UDim2.new(1,-40,0.5,-10)
    pill.BackgroundColor3=CFG[key] and COL.acc or COL.off; pill.Parent=row
    local pc=Instance.new("UICorner"); pc.CornerRadius=UDim.new(1,0); pc.Parent=pill
    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,16,0,16)
    knob.Position=CFG[key] and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.Parent=pill
    local kc=Instance.new("UICorner"); kc.CornerRadius=UDim.new(1,0); kc.Parent=knob
    row.MouseButton1Click:Connect(function()
        if not MasterEnabled then return end
        CFG[key]=not CFG[key]
        pill.BackgroundColor3=CFG[key] and COL.acc or COL.off
        knob.Position=CFG[key] and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
    end)
end

addSwitch(main, "Enable ESP (Highlight)", "esp", 90)
addSwitch(main, "Auto Parry (Dagger)", "auto_parry", 125)
addSwitch(main, "Auto Skillcheck (Spam)", "auto_skillcheck", 160)

masterBtn.MouseButton1Click:Connect(function()
    MasterEnabled = not MasterEnabled
    if MasterEnabled then
        masterBtn.Text="SCRIPT: ON"; masterBtn.BackgroundColor3=COL.acc
    else
        masterBtn.Text="ENABLE SCRIPT"; masterBtn.BackgroundColor3=COL.red
    end
end)

-- BUKA GUI & UNLOCK MOUSE
UIS.InputBegan:Connect(function(i,pr)
    if pr then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
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
-- ESP & AUTOMATION
-- ==========================================
local hiddenFolder = Instance.new("Folder")
hiddenFolder.Name = "SpookCarrier"
hiddenFolder.Parent = CAM or WS
local espData = {}
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

print("[SpookingD] v70.7 loaded — Clickable & Unlocked")
