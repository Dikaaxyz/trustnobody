--[[
    GRAYS ON TOP v3.7 — No Speedhack
    Silent Aim | ESP (Highlight) | Split Farm | Safe TP | Anti-Detect Fly
]]

if not game:IsLoaded() then game.Loaded:Wait() end
if getgenv().GOTGui then pcall(function() getgenv().GOTGui:Destroy() end) end

local P = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local WS = game:GetService("Workspace")
local CG = game:GetService("CoreGui")
local TS = game:GetService("TweenService")
local LP = P.LocalPlayer
local CAM = WS.CurrentCamera
local VIM = game:GetService("VirtualInputManager")

local CFG = {
    aim=false, aimFov=150, esp=false,
    farmMarsh=false, farmBox=false, farmInt=0.6, farmDist=30,
    tpSafe=false, tpDist=5,
    noclip=false, fly=false, flySpeed=60,
    autoFire=false, autoFix=false,
    keyMenu=Enum.KeyCode.RightShift,
}

local function getHui()
    if typeof(gethui)=="function" then local ok,h=pcall(gethui); if ok and h then return h end end
    return CG
end

local COL = {
    bg=Color3.fromRGB(10,10,10), panel=Color3.fromRGB(18,18,18), line=Color3.fromRGB(35,35,35),
    txt=Color3.fromRGB(240,240,240), dim=Color3.fromRGB(120,120,120), acc=Color3.fromRGB(255,40,40), 
}

local gui = Instance.new("ScreenGui")
gui.Name="GOT"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=999999
gui.Parent=getHui()
getgenv().GOTGui=gui

-- MAIN WINDOW
local main=Instance.new("Frame")
main.Size=UDim2.new(0,360,0,440)
main.Position=UDim2.new(0,20,0,50)
main.BackgroundColor3=COL.bg
main.BorderSizePixel=0
main.Active=true
main.Parent=gui
local ms=Instance.new("UIStroke"); ms.Color=COL.line; ms.Thickness=1; ms.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; ms.Parent=main

local head=Instance.new("Frame")
head.Size=UDim2.new(1,0,0,40); head.BackgroundColor3=COL.panel; head.BorderSizePixel=0; head.Parent=main
local hl=Instance.new("Frame"); hl.Size=UDim2.new(1,0,0,1); hl.Position=UDim2.new(0,0,1,0); hl.BackgroundColor3=COL.acc; hl.BorderSizePixel=0; hl.Parent=head

local wm=Instance.new("TextLabel")
wm.Size=UDim2.new(1,-20,1,0); wm.Position=UDim2.new(0,12,0,0); wm.BackgroundTransparency=1
wm.Text="GRAYS ON TOP"; wm.TextColor3=COL.txt; wm.Font=Enum.Font.GothamBlack; wm.TextSize=14; wm.TextXAlignment=Enum.TextXAlignment.Left; wm.Parent=head

local xBtn=Instance.new("TextButton")
xBtn.Size=UDim2.new(0,30,1,0); xBtn.Position=UDim2.new(1,-30,0,0); xBtn.BackgroundTransparency=1; xBtn.Text="×"; xBtn.TextColor3=COL.dim; xBtn.Font=Enum.Font.GothamBold; xBtn.TextSize=20; xBtn.Parent=head
xBtn.MouseButton1Click:Connect(function() main.Visible=false; if getgenv().mBtn then getgenv().mBtn.Text="GOT" end end)

local tabBar=Instance.new("Frame")
tabBar.Size=UDim2.new(1,0,0,30); tabBar.Position=UDim2.new(0,0,0,40); tabBar.BackgroundColor3=COL.panel; tabBar.BorderSizePixel=0; tabBar.Parent=main
local tl=Instance.new("UIListLayout"); tl.FillDirection=Enum.FillDirection.Horizontal; tl.VerticalAlignment=Enum.VerticalAlignment.Center; tl.Parent=tabBar

local tabs, pages = {}, {}

local function addTab(name, width)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(0,width,1,0); btn.BackgroundColor3=COL.panel; btn.BorderSizePixel=0; btn.Text=name
    btn.TextColor3=COL.dim; btn.Font=Enum.Font.GothamBold; btn.TextSize=11; btn.Parent=tabBar
    table.insert(tabs,btn)

    local pg=Instance.new("ScrollingFrame")
    pg.Size=UDim2.new(1,0,1,-70); pg.Position=UDim2.new(0,0,0,70); pg.BackgroundTransparency=1
    pg.BorderSizePixel=0; pg.ScrollBarThickness=2; pg.ScrollBarImageColor3=COL.line; pg.CanvasSize=UDim2.new(0,0,0,0); pg.Visible=false; pg.Parent=main

    local l=Instance.new("UIListLayout"); l.Padding=UDim.new(0,8); l.Parent=pg
    local pd=Instance.new("UIPadding"); pd.PaddingLeft=UDim.new(0,12); pd.PaddingRight=UDim.new(0,12); pd.PaddingTop=UDim.new(0,12); pd.Parent=pg

    local idx=#pages+1; table.insert(pages,pg)
    btn.MouseButton1Click:Connect(function()
        for i,p in ipairs(pages) do p.Visible=(i==idx) end
        for i,b in ipairs(tabs) do
            if i==idx then b.TextColor3=COL.acc; b.BackgroundColor3=COL.bg; b.Font=Enum.Font.GothamBold
            else b.TextColor3=COL.dim; b.BackgroundColor3=COL.panel; b.Font=Enum.Font.GothamBold end
        end
    end)
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() pg.CanvasSize=UDim2.new(0,0,0,l.AbsoluteContentSize.Y+24) end)
    return pg
end

local function addSection(p, n)
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,0,0,16); l.BackgroundTransparency=1
    l.Text=string.upper(n); l.TextColor3=COL.dim; l.Font=Enum.Font.GothamBold; l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=p
end

local function addToggle(p,label,key)
    local row=Instance.new("TextButton"); row.Size=UDim2.new(1,0,0,32); row.BackgroundColor3=COL.panel; row.BorderSizePixel=0; row.AutoButtonColor=false; row.Text=""; row.Parent=p
    local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-40,1,0); lbl.Position=UDim2.new(0,10,0,0); lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=COL.txt; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=row
    local box=Instance.new("Frame"); box.Size=UDim2.new(0,14,0,14); box.Position=UDim2.new(1,-24,0.5,-7); box.BackgroundColor3=COL.bg; box.BorderSizePixel=0; box.Parent=row
    local bs=Instance.new("UIStroke"); bs.Color=COL.line; bs.Thickness=1; bs.Parent=box
    local fill=Instance.new("Frame"); fill.Size=UDim2.new(0,8,0,8); fill.Position=UDim2.new(0.5,-4,0.5,-4); fill.BackgroundColor3=COL.acc; fill.BorderSizePixel=0; fill.Visible=CFG[key]; fill.Parent=box
    row.MouseButton1Click:Connect(function() CFG[key]=not CFG[key]; fill.Visible=CFG[key] end)
end

local function addSlider(p,label,key,mn,mx)
    local h=Instance.new("Frame"); h.Size=UDim2.new(1,0,0,36); h.BackgroundColor3=COL.panel; h.Parent=p
    local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-10,0,16); lbl.Position=UDim2.new(0,10,0,4); lbl.BackgroundTransparency=1; lbl.Text=label..": "..tostring(CFG[key]); lbl.TextColor3=COL.txt; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=h
    local bar=Instance.new("Frame"); bar.Size=UDim2.new(1,-20,0,4); bar.Position=UDim2.new(0,10,1,-10); bar.BackgroundColor3=COL.bg; bar.Parent=h
    local f=Instance.new("Frame"); f.Size=UDim2.new((CFG[key]-mn)/(mx-mn),0,1,0); f.BackgroundColor3=COL.acc; f.Parent=bar
    local drag=false
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.Parent=bar
    btn.MouseButton1Down:Connect(function() drag=true end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
    RS.RenderStepped:Connect(function()
        if not drag then return end
        local mxPos=UIS:GetMouseLocation().X
        local fw=math.clamp((mxPos-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
        CFG[key]=math.floor(mn+fw*(mx-mn))
        f.Size=UDim2.new(fw,0,1,0); lbl.Text=label..": "..tostring(CFG[key])
    end)
end

-- BUILD TABS
local pgAim = addTab("AIM", 50)
addSection(pgAim, "True Silent Aim")
addToggle(pgAim, "Silent Aim", "aim")
addSlider(pgAim, "FOV Radius", "aimFov", 50, 400)

local pgEsp = addTab("ESP", 50)
addSection(pgEsp, "Player ESP")
addToggle(pgEsp, "ESP Master", "esp")

local pgCombat = addTab("COMBAT", 60)
addSection(pgCombat, "Weapon")
addToggle(pgCombat, "Auto Fire (Equip)", "autoFire")
addToggle(pgCombat, "Auto Fix Jam", "autoFix")

local pgFarm = addTab("FARM", 50)
addSection(pgFarm, "Marshmallow")
addToggle(pgFarm, "Auto Farm Marshmallow", "farmMarsh")
addSection(pgFarm, "Box")
addToggle(pgFarm, "Auto Farm Box", "farmBox")
addSlider(pgFarm, "Radius", "farmDist", 5, 100)

local pgTp = addTab("TP", 40)
addSection(pgTp, "Safe Teleport")
addToggle(pgTp, "Teleport Nearest", "tpSafe")

local pgMove = addTab("MOVE", 50)
addSection(pgMove, "Movement")
addToggle(pgMove, "Noclip", "noclip")
addToggle(pgMove, "Fly", "fly")
addSlider(pgMove, "Fly Speed", "flySpeed", 10, 200)

for i,p in ipairs(pages) do p.Visible=(i==1) end
tabs[1].TextColor3=COL.acc; tabs[1].BackgroundColor3=COL.bg

-- MOBILE LOGO TOGGLE
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
if isMobile then
    local mBtn = Instance.new("TextButton"); mBtn.Size = UDim2.new(0, 54, 0, 54); mBtn.Position = UDim2.new(0, 20, 0, 100); mBtn.BackgroundColor3 = COL.bg; mBtn.BorderSizePixel = 0; mBtn.Text = "GOT"; mBtn.TextColor3 = COL.txt; mBtn.Font = Enum.Font.GothamBlack; mBtn.TextSize = 14; mBtn.ZIndex = 100; mBtn.Parent = gui
    local stroke = Instance.new("UIStroke"); stroke.Color = COL.acc; stroke.Thickness = 2; stroke.Parent = mBtn
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = mBtn
    local drag,ds,sp
    mBtn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then drag=true; ds=i.Position; sp=mBtn.Position end end)
    UIS.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.Touch then local d=i.Position-ds; mBtn.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
    mBtn.MouseButton1Click:Connect(function() main.Visible = not main.Visible; mBtn.Text = main.Visible and "X" or "GOT" end)
    getgenv().mBtn = mBtn
end

UIS.InputBegan:Connect(function(i,pr)
    if pr then return end
    if i.KeyCode==CFG.keyMenu then
        main.Visible=not main.Visible
        if isMobile and getgenv().mBtn then getgenv().mBtn.Text = main.Visible and "X" or "GOT" end
    end
end)

-- DRAG WINDOW
local drag,ds,sp
head.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true; ds=i.Position; sp=main.Position end end)
UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-ds; main.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)

-- FOV CIRCLE UI
local fovGui = Instance.new("ScreenGui")
fovGui.Name = "GOTFov"; fovGui.ResetOnSpawn = false; fovGui.IgnoreGuiInset = true; fovGui.Parent = getHui()
local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, CFG.aimFov*2, 0, CFG.aimFov*2)
fovCircle.Position = UDim2.new(0.5, -CFG.aimFov, 0.5, -CFG.aimFov)
fovCircle.BackgroundTransparency = 1; fovCircle.Visible = false; fovCircle.Parent = fovGui
local fovStroke = Instance.new("UIStroke"); fovStroke.Color = Color3.fromRGB(255,255,255); fovStroke.Thickness = 1; fovStroke.Transparency = 0.5; fovStroke.Parent = fovCircle
local fovCorner = Instance.new("UICorner"); fovCorner.CornerRadius = UDim.new(1, 0); fovCorner.Parent = fovCircle
task.spawn(function()
    while true do
        task.wait(0.5)
        if fovCircle then
            fovCircle.Visible = CFG.aim
            fovCircle.Size = UDim2.new(0, CFG.aimFov*2, 0, CFG.aimFov*2)
            fovCircle.Position = UDim2.new(0.5, -CFG.aimFov, 0.5, -CFG.aimFov)
        end
    end
end)

-- ENGINE: SILENT AIM
if typeof(getrawmetatable)=="function" and typeof(setreadonly)=="function" and typeof(newcclosure)=="function" then
    local mouse=LP:GetMouse()
    local mt=getrawmetatable(game)
    setreadonly(mt,false)
    local oi=mt.__index
    mt.__index=newcclosure(function(self,k)
        if self==mouse and CFG.aim and (k=="Hit" or k=="Target" or k=="UnitRay") then
            local best, bd = nil, math.huge
            local sc=Vector2.new(CAM.ViewportSize.X/2, CAM.ViewportSize.Y/2)
            for _,p in ipairs(P:GetPlayers()) do
                if p~=LP then
                    local c=p.Character
                    local part=c and c:FindFirstChild("Head")
                    local hum=c and c:FindFirstChildOfClass("Humanoid")
                    if part and part:IsA("BasePart") and hum and hum.Health>0 then
                        local sp2, on = CAM:WorldToViewportPoint(part.Position)
                        if on then
                            local d=(Vector2.new(sp2.X,sp2.Y)-sc).Magnitude
                            if d<CFG.aimFov and d<bd then
                                bd=d; best=part
                            end
                        end
                    end
                end
            end
            if best then
                if k=="Hit" then return CFrame.new(best.Position) end
                if k=="Target" then return best end
                if k=="UnitRay" then return Ray.new(CAM.CFrame.Position,(best.Position-CAM.CFrame.Position).Unit) end
            end
        end
        return oi(self,k)
    end)
    setreadonly(mt,true)
end

-- ENGINE: ESP (Highlight Method)
local espHighlights = {}
local function updateESP()
    if CFG.esp then
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= LP and p.Character then
                if not espHighlights[p] then
                    local h = Instance.new("Highlight")
                    h.FillColor = Color3.fromRGB(255, 0, 0)
                    h.OutlineColor = Color3.fromRGB(255, 255, 255)
                    h.FillTransparency = 0.5
                    h.OutlineTransparency = 0
                    h.Parent = p.Character
                    espHighlights[p] = h
                end
            end
        end
    else
        for p, h in pairs(espHighlights) do
            if h then h:Destroy() end
            espHighlights[p] = nil
        end
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        pcall(updateESP)
    end
end)

P.PlayerRemoving:Connect(function(p)
    if espHighlights[p] then espHighlights[p]:Destroy(); espHighlights[p] = nil end
end)

-- ENGINE: FARM
task.spawn(function()
    while true do
        if CFG.farmMarsh or CFG.farmBox then
            pcall(function()
                local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _,d in ipairs(WS:GetDescendants()) do
                        if d:IsA("ProximityPrompt") and d.Parent:IsA("BasePart") then
                            if (d.Parent.Position-hrp.Position).Magnitude<CFG.farmDist then
                                local pName = d.Parent.Name:lower(); local aText = d.ActionText:lower()
                                if (CFG.farmMarsh and (pName:find("marsh") or aText:find("marsh") or pName:find("craft"))) 
                                or (CFG.farmBox and (pName:find("box") or aText:find("box") or pName:find("crate") or pName:find("loot"))) then
                                    if fireproximityprompt then fireproximityprompt(d) end
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(CFG.farmInt)
        else
            task.wait(0.2)
        end
    end
end)

-- ENGINE: SAFE TELEPORT
local tpConn = nil
local function startSafeTP()
    if tpConn then return end
    tpConn = task.spawn(function()
        while CFG.tpSafe do
            task.wait(1)
            local myChar = LP.Character; local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myHrp then
                local nearest, nd = nil, math.huge
                for _,p in ipairs(P:GetPlayers()) do
                    if p~=LP then
                        local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local d=(hrp.Position-myHrp.Position).Magnitude
                            if d<nd then nd=d; nearest=hrp end
                        end
                    end
                end
                if nearest and nd > CFG.tpDist then
                    local targetPos = nearest.CFrame * CFrame.new(0, 0, CFG.tpDist)
                    local dist = (myHrp.Position - targetPos.Position).Magnitude
                    local time = math.clamp(dist / 100, 0.5, 2)
                    local tween = TS:Create(myHrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = targetPos})
                    tween:Play()
                end
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if CFG.tpSafe and not tpConn then startSafeTP()
        elseif not CFG.tpSafe and tpConn then tpConn = nil end
    end
end)

-- ENGINE: AUTO-FIRE & AUTO-FIX
local autoFireConn = nil
local function fixJam(tool)
    if not tool then return end
    if tool.Reload and typeof(tool.Reload) == "function" then pcall(function() tool:Reload() end) end
    for _, v in pairs(tool:GetDescendants()) do
        if v:IsA("BoolValue") and (v.Name:lower():find("jam") or v.Name:lower():find("overheat") or v.Name:lower():find("broken")) then v.Value = false end
        if v:IsA("NumberValue") and v.Name:lower():find("heat") then v.Value = 0 end
    end
end
local function startAutoFire()
    if autoFireConn then return end
    autoFireConn = RS.RenderStepped:Connect(function()
        local char = LP.Character; if not char then return end
        local tool = char:FindFirstChildWhichIsA("Tool")
        if tool then
            if CFG.autoFix then fixJam(tool) end
            if CFG.autoFire then
                pcall(function() VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0); VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0) end)
                if tool.Activate and typeof(tool.Activate) == "function" then pcall(function() tool:Activate() end) end
            end
        end
        task.wait(0.1)
    end)
end
local function stopAutoFire() if autoFireConn then autoFireConn:Disconnect(); autoFireConn = nil end end
local function setupToolEvents(char)
    char.ChildAdded:Connect(function(child) if child:IsA("Tool") and (CFG.autoFire or CFG.autoFix) then startAutoFire() end end)
    char.ChildRemoved:Connect(function(child) if child:IsA("Tool") then stopAutoFire() end end)
    if char:FindFirstChildWhichIsA("Tool") and (CFG.autoFire or CFG.autoFix) then startAutoFire() end
end
if LP.Character then setupToolEvents(LP.Character) end
LP.CharacterAdded:Connect(setupToolEvents)

-- ENGINE: NOCLIP
local noclipConn = nil
local function updateNoclip()
    if CFG.noclip then
        if not noclipConn then
            noclipConn = LP.CharacterAdded:Connect(function() task.wait(0.1); if CFG.noclip and LP.Character then for _, p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end end end end)
        end
        if LP.Character then for _, p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end end end
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        if LP.Character then for _, p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.CanCollide = true end end end
    end
end
task.spawn(function() while true do updateNoclip(); task.wait(1) end end)

-- ENGINE: FLY (Anti-Detect)
local currentStopFly = nil
local function startSecureFly()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local oldGrav = WS.Gravity
    WS.Gravity = 0

    local bv = Instance.new("BodyVelocity")
    bv.Name = "GOT_Fly"
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Parent = hrp

    hum.PlatformStand = true
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)

    local conn
    conn = RS.RenderStepped:Connect(function()
        local c = LP.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        if not h or not bv then return end

        local mv = Vector3.new(0, 0, 0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then mv = mv + CAM.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then mv = mv - CAM.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then mv = mv - CAM.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then mv = mv + CAM.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then mv = mv - Vector3.new(0, 1, 0) end

        if mv.Magnitude > 0 then
            bv.Velocity = mv.Unit * CFG.flySpeed
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end
    end)

    return function()
        if conn then conn:Disconnect() end
        if bv then bv:Destroy() end
        WS.Gravity = oldGrav
        if hum then
            hum.PlatformStand = false
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
        end
    end
end

task.spawn(function()
    local was = false
    while true do
        task.wait(0.1)
        if CFG.fly and not was then
            currentStopFly = startSecureFly()
        elseif not CFG.fly and was then
            if currentStopFly then
                pcall(currentStopFly)
                currentStopFly = nil
            end
        end
        was = CFG.fly
    end
end)

print("[GRAYS ON TOP] v3.7 loaded.")
