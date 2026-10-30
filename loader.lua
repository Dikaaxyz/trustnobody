-- GRAYS ON TOP — South Bronx: The Trenches cheat
-- Default toggle: RIGHT SHIFT
if not game:IsLoaded() then game.Loaded:Wait() end
if getgenv().GOTGui then pcall(function() getgenv().GOTGui:Destroy() end) end

local P = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local WS = game:GetService("Workspace")
local CG = game:GetService("CoreGui")
local LP = P.LocalPlayer
local CAM = WS.CurrentCamera

local CFG = {
    aim=false, aimPart="Head", aimFov=250,
    esp=false, espBox=true, espName=true, espHealth=true, espDist=true, espTracer=false, espMax=2000,
    noclip=false, speed=false, ws=16, jp=50,
    fly=false, flySpeed=60,
    bright=false,
    farm=false, farmTool="Marshmallow Bag", farmPrompt="Craft", farmInt=0.6, farmDist=20,
    click=false, cps=10,
    tpOff=4, keyMenu=Enum.KeyCode.RightShift,
    hum=true, jitter=2.5, reactMin=90, reactMax=220, hsRate=0.35, hsCap=2,
}

local function getHui()
    if typeof(gethui)=="function" then local ok,h=pcall(gethui); if ok and h then return h end end
    return CG
end

local gui = Instance.new("ScreenGui")
gui.Name="GOT"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=999999
gui.Parent=getHui()
getgenv().GOTGui=gui

local COL = {
    bg=Color3.fromRGB(8,8,8), panel=Color3.fromRGB(16,16,16), hi=Color3.fromRGB(26,26,26),
    line=Color3.fromRGB(38,38,38), dim=Color3.fromRGB(140,140,140), txt=Color3.fromRGB(232,232,232),
    acc=Color3.fromRGB(255,255,255), red=Color3.fromRGB(220,40,40), grn=Color3.fromRGB(0,200,110),
}

local main=Instance.new("Frame")
main.Size=UDim2.new(0,380,0,520)
main.Position=UDim2.new(0,40,0,40)
main.BackgroundColor3=COL.bg
main.BorderSizePixel=0
main.Active=true
main.ClipsDescendants=true
main.Parent=gui

local mStroke=Instance.new("UIStroke")
mStroke.Color=COL.line
mStroke.Thickness=1
mStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
mStroke.Parent=main

local header=Instance.new("Frame")
header.Size=UDim2.new(1,0,0,64)
header.BackgroundColor3=COL.bg
header.BorderSizePixel=0
header.Parent=main

local hLine=Instance.new("Frame")
hLine.Size=UDim2.new(1,0,0,1)
hLine.Position=UDim2.new(0,0,1,-1)
hLine.BackgroundColor3=COL.line
hLine.BorderSizePixel=0
hLine.Parent=header

local wm=Instance.new("TextLabel")
wm.Size=UDim2.new(1,-24,0,30)
wm.Position=UDim2.new(0,16,0,12)
wm.BackgroundTransparency=1
wm.Text="GRAYS ON TOP"
wm.TextColor3=COL.txt
wm.Font=Enum.Font.GothamBlack
wm.TextSize=22
wm.TextXAlignment=Enum.TextXAlignment.Left
wm.Parent=header

local sub=Instance.new("TextLabel")
sub.Size=UDim2.new(1,-24,0,14)
sub.Position=UDim2.new(0,16,0,42)
sub.BackgroundTransparency=1
sub.Text="S O U T H   B R O N X   T R E N C H E S"
sub.TextColor3=COL.dim
sub.Font=Enum.Font.Gotham
sub.TextSize=10
sub.TextXAlignment=Enum.TextXAlignment.Left
sub.Parent=header

local dot=Instance.new("Frame")
dot.Size=UDim2.new(0,8,0,8)
dot.Position=UDim2.new(1,-24,0,20)
dot.BackgroundColor3=COL.grn
dot.BorderSizePixel=0
dot.Parent=header
local dc=Instance.new("UICorner")
dc.CornerRadius=UDim.new(1,0)
dc.Parent=dot

local tabBar=Instance.new("Frame")
tabBar.Size=UDim2.new(1,0,0,36)
tabBar.Position=UDim2.new(0,0,0,64)
tabBar.BackgroundColor3=COL.panel
tabBar.BorderSizePixel=0
tabBar.Parent=main

local tabL=Instance.new("UIListLayout")
tabL.FillDirection=Enum.FillDirection.Horizontal
tabL.VerticalAlignment=Enum.VerticalAlignment.Center
tabL.Parent=tabBar

local tabPad=Instance.new("UIPadding")
tabPad.PaddingLeft=UDim.new(0,8)
tabPad.Parent=tabBar

local content=Instance.new("Frame")
content.Size=UDim2.new(1,0,1,-100)
content.Position=UDim2.new(0,0,0,100)
content.BackgroundColor3=COL.bg
content.BorderSizePixel=0
content.Parent=main

local pages={}
local tabs={}

local function setTab(i)
    for j,pg in ipairs(pages) do pg.Visible=(j==i) end
    for j,b in ipairs(tabs) do
        if j==i then
            b.TextColor3=COL.acc
            b.BackgroundColor3=COL.bg
            b.Font=Enum.Font.GothamBold
        else
            b.TextColor3=COL.dim
            b.BackgroundColor3=COL.panel
            b.Font=Enum.Font.Gotham
        end
    end
end

local function makeTab(n,w)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0,w or 62,1,0)
    b.BackgroundColor3=COL.panel
    b.BorderSizePixel=0
    b.Text=n
    b.TextColor3=COL.dim
    b.Font=Enum.Font.Gotham
    b.TextSize=12
    b.Parent=tabBar
    table.insert(tabs,b)
    local pg=Instance.new("ScrollingFrame")
    pg.Size=UDim2.new(1,0,1,0)
    pg.BackgroundTransparency=1
    pg.BorderSizePixel=0
    pg.ScrollBarThickness=3
    pg.ScrollBarImageColor3=COL.line
    pg.CanvasSize=UDim2.new(0,0,0,0)
    pg.Visible=false
    pg.Parent=content
    local l=Instance.new("UIListLayout")
    l.Padding=UDim.new(0,1)
    l.Parent=pg
    local pd=Instance.new("UIPadding")
    pd.PaddingLeft=UDim.new(0,14)
    pd.PaddingRight=UDim.new(0,14)
    pd.PaddingTop=UDim.new(0,12)
    pd.PaddingBottom=UDim.new(0,12)
    pd.Parent=pg
    local idx=#pages+1
    table.insert(pages,pg)
    b.MouseButton1Click:Connect(function() setTab(idx) end)
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        pg.CanvasSize=UDim2.new(0,0,0,l.AbsoluteContentSize.Y+24)
    end)
    return pg
end

local function section(p,n)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,0,0,26)
    l.BackgroundTransparency=1
    l.Text=string.upper(n)
    l.TextColor3=COL.red
    l.Font=Enum.Font.GothamBold
    l.TextSize=10
    l.TextXAlignment=Enum.TextXAlignment.Left
    l.TextYAlignment=Enum.TextYAlignment.Bottom
    l.Parent=p
end

local function toggle(p,label,key,cb)
    local row=Instance.new("TextButton")
    row.Size=UDim2.new(1,0,0,32)
    row.BackgroundColor3=COL.panel
    row.BorderSizePixel=0
    row.Text=""
    row.AutoButtonColor=false
    row.Parent=p
    local l=Instance.new("Frame")
    l.Size=UDim2.new(1,0,0,1)
    l.Position=UDim2.new(0,0,1,-1)
    l.BackgroundColor3=COL.line
    l.BorderSizePixel=0
    l.Parent=row
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-60,1,0)
    lbl.Position=UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency=1
    lbl.Text=label
    lbl.TextColor3=COL.txt
    lbl.Font=Enum.Font.Gotham
    lbl.TextSize=12
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.Parent=row
    local pill=Instance.new("Frame")
    pill.Size=UDim2.new(0,34,0,16)
    pill.Position=UDim2.new(1,-44,0.5,-8)
    pill.BackgroundColor3=COL.bg
    pill.BorderSizePixel=0
    pill.Parent=row
    local ps=Instance.new("UIStroke")
    ps.Color=COL.line
    ps.Thickness=1
    ps.Parent=pill
    local pc=Instance.new("UICorner")
    pc.CornerRadius=UDim.new(1,0)
    pc.Parent=pill
    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,10,0,10)
    knob.Position=UDim2.new(0,3,0.5,-5)
    knob.BackgroundColor3=COL.dim
    knob.BorderSizePixel=0
    knob.Parent=pill
    local kc=Instance.new("UICorner")
    kc.CornerRadius=UDim.new(1,0)
    kc.Parent=knob
    local function refresh()
        if CFG[key] then
            knob.Position=UDim2.new(1,-13,0.5,-5)
            knob.BackgroundColor3=COL.acc
            pill.BackgroundColor3=COL.acc
            ps.Color=COL.acc
            lbl.TextColor3=COL.acc
        else
            knob.Position=UDim2.new(0,3,0.5,-5)
            knob.BackgroundColor3=COL.dim
            pill.BackgroundColor3=COL.bg
            ps.Color=COL.line
            lbl.TextColor3=COL.txt
        end
    end
    refresh()
    row.MouseButton1Click:Connect(function()
        CFG[key]=not CFG[key]
        refresh()
        if cb then pcall(cb,CFG[key]) end
    end)
end

local function slider(p,label,key,mn,mx,st,cb)
    local h=Instance.new("Frame")
    h.Size=UDim2.new(1,0,0,50)
    h.BackgroundColor3=COL.panel
    h.BorderSizePixel=0
    h.Parent=p
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-80,0,22)
    lbl.Position=UDim2.new(0,10,0,4)
    lbl.BackgroundTransparency=1
    lbl.Text=label
    lbl.TextColor3=COL.txt
    lbl.Font=Enum.Font.Gotham
    lbl.TextSize=12
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.Parent=h
    local vl=Instance.new("TextLabel")
    vl.Size=UDim2.new(0,70,0,22)
    vl.Position=UDim2.new(1,-80,0,4)
    vl.BackgroundTransparency=1
    vl.Text=string.format("%.2f",CFG[key])
    vl.TextColor3=COL.acc
    vl.Font=Enum.Font.Code
    vl.TextSize=12
    vl.TextXAlignment=Enum.TextXAlignment.Right
    vl.Parent=h
    local bar=Instance.new("Frame")
    bar.Size=UDim2.new(1,-20,0,4)
    bar.Position=UDim2.new(0,10,1,-14)
    bar.BackgroundColor3=COL.bg
    bar.BorderSizePixel=0
    bar.Parent=h
    local fill=Instance.new("Frame")
    fill.Size=UDim2.new(math.clamp((CFG[key]-mn)/(mx-mn),0,1),0,1,0)
    fill.BackgroundColor3=COL.acc
    fill.BorderSizePixel=0
    fill.Parent=bar
    local dragging=false
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,1,0)
    btn.BackgroundTransparency=1
    btn.Text=""
    btn.Parent=bar
    btn.MouseButton1Down:Connect(function() dragging=true end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)
    RS.RenderStepped:Connect(function()
        if not dragging then return end
        local aw=bar.AbsoluteSize.X
        if aw<=0 then return end
        local f=math.clamp((UIS:GetMouseLocation().X-bar.AbsolutePosition.X)/aw,0,1)
        local v=math.clamp(math.floor((mn+f*(mx-mn))/st+0.5)*st,mn,mx)
        CFG[key]=v
        fill.Size=UDim2.new(f,0,1,0)
        vl.Text=string.format("%.2f",v)
        if cb then pcall(cb,v) end
    end)
end

local function textBox(p,label,key,ph)
    local h=Instance.new("Frame")
    h.Size=UDim2.new(1,0,0,56)
    h.BackgroundColor3=COL.panel
    h.BorderSizePixel=0
    h.Parent=p
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-20,0,18)
    lbl.Position=UDim2.new(0,10,0,4)
    lbl.BackgroundTransparency=1
    lbl.Text=label
    lbl.TextColor3=COL.txt
    lbl.Font=Enum.Font.Gotham
    lbl.TextSize=12
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.Parent=h
    local box=Instance.new("TextBox")
    box.Size=UDim2.new(1,-20,0,24)
    box.Position=UDim2.new(0,10,0,24)
    box.BackgroundColor3=COL.bg
    box.BorderSizePixel=0
    box.Text=tostring(CFG[key] or "")
    box.PlaceholderText=ph or ""
    box.PlaceholderColor3=COL.dim
    box.TextColor3=COL.txt
    box.Font=Enum.Font.Code
    box.TextSize=12
    box.TextXAlignment=Enum.TextXAlignment.Left
    box.ClearTextOnFocus=false
    box.Parent=h
    local bs=Instance.new("UIStroke")
    bs.Color=COL.line
    bs.Thickness=1
    bs.Parent=box
    box.FocusLost:Connect(function() CFG[key]=box.Text end)
end

local fovGui=Instance.new("ScreenGui")
fovGui.Name="GOTFov"
fovGui.ResetOnSpawn=false
fovGui.IgnoreGuiInset=true
fovGui.Parent=getHui()

local fovC=Instance.new("Frame")
fovC.Size=UDim2.new(0,CFG.aimFov*2,0,CFG.aimFov*2)
fovC.Position=UDim2.new(0.5,-CFG.aimFov,0.5,-CFG.aimFov)
fovC.BackgroundTransparency=1
fovC.BorderSizePixel=0
fovC.Visible=false
fovC.Parent=fovGui
local fovS=Instance.new("UIStroke")
fovS.Color=COL.red
fovS.Thickness=1
fovS.Transparency=0.5
fovS.Parent=fovC
local fovK=Instance.new("UICorner")
fovK.CornerRadius=UDim.new(1,0)
fovK.Parent=fovC

local cTab=makeTab("COMBAT",74)
local eTab=makeTab("ESP",54)
local mTab=makeTab("MOVE",58)
local fTab=makeTab("FARM",56)
local xTab=makeTab("MISC",54)
local kTab=makeTab("KEYS",52)
setTab(1)

section(cTab,"SILENT AIM")
toggle(cTab,"Silent Aim","aim")
slider(cTab,"FOV Radius","aimFov",50,600,10,function(v)
    fovC.Size=UDim2.new(0,v*2,0,v*2)
    fovC.Position=UDim2.new(0.5,-v,0.5,-v)
end)

section(cTab,"HUMANIZER")
toggle(cTab,"Humanize","hum")
slider(cTab,"Jitter (deg)","jitter",0,8,0.5)
slider(cTab,"React Min (ms)","reactMin",40,400,10)
slider(cTab,"React Max (ms)","reactMax",40,600,10)
slider(cTab,"Headshot Rate","hsRate",0,1,0.05)
slider(cTab,"HS/sec Cap","hsCap",1,6,1)

section(eTab,"ESP")
toggle(eTab,"ESP Master","esp")
toggle(eTab,"Box","espBox")
toggle(eTab,"Name","espName")
toggle(eTab,"Health","espHealth")
toggle(eTab,"Distance","espDist")
toggle(eTab,"Tracer","espTracer")
slider(eTab,"Max Distance","espMax",100,3000,50)

section(mTab,"MOVEMENT")
toggle(mTab,"Noclip","noclip")
toggle(mTab,"Speed","speed")
slider(mTab,"WalkSpeed","ws",16,300,1)
slider(mTab,"JumpPower","jp",50,500,5)
section(mTab,"FLY")
toggle(mTab,"Fly","fly")
slider(mTab,"Fly Speed","flySpeed",10,300,5)

section(fTab,"AUTO-FARM")
toggle(fTab,"Farm Enabled","farm")
textBox(fTab,"Tool Name","farmTool","Marshmallow Bag")
textBox(fTab,"Prompt Text","farmPrompt","Craft")
slider(fTab,"Interval (s)","farmInt",0.2,3.0,0.1)
slider(fTab,"Proximity","farmDist",5,100,1)

section(xTab,"AUTO-CLICKER")
toggle(xTab,"Auto Clicker","click")
slider(xTab,"CPS","cps",1,30,1)

section(xTab,"TELEPORT")
local plList=Instance.new("ScrollingFrame")
plList.Size=UDim2.new(1,0,0,150)
plList.BackgroundColor3=COL.panel
plList.BorderSizePixel=0
plList.ScrollBarThickness=3
plList.ScrollBarImageColor3=COL.line
plList.Parent=xTab
local plL=Instance.new("UIListLayout")
plL.Padding=UDim.new(0,1)
plL.Parent=plList

task.spawn(function()
    while true do
        pcall(function()
            for _,c in ipairs(plList:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            for _,p in ipairs(P:GetPlayers()) do
                if p~=LP then
                    local b=Instance.new("TextButton")
                    b.Size=UDim2.new(1,0,0,26)
                    b.BackgroundColor3=COL.bg
                    b.BorderSizePixel=0
                    b.Text="  "..p.Name
                    b.TextColor3=COL.txt
                    b.Font=Enum.Font.Gotham
                    b.TextSize=12
                    b.TextXAlignment=Enum.TextXAlignment.Left
                    b.AutoButtonColor=false
                    b.Parent=plList
                    b.MouseEnter:Connect(function() b.BackgroundColor3=COL.hi end)
                    b.MouseLeave:Connect(function() b.BackgroundColor3=COL.bg end)
                    b.MouseButton1Click:Connect(function()
                        local c=p.Character
                        local hrp=c and c:FindFirstChild("HumanoidRootPart")
                        local my=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and my then
                            my.CFrame=hrp.CFrame*CFrame.new(0,0,CFG.tpOff)
                        end
                    end)
                end
            end
            plList.CanvasSize=UDim2.new(0,0,0,plL.AbsoluteContentSize.Y+4)
        end)
        task.wait(2)
    end
end)

section(xTab,"VISUAL")
toggle(xTab,"Fullbright","bright")

section(kTab,"KEYBINDS")
local listening=nil
local mBtn=Instance.new("TextButton")
mBtn.Size=UDim2.new(1,0,0,34)
mBtn.BackgroundColor3=COL.panel
mBtn.BorderSizePixel=0
mBtn.Text="Menu: "..CFG.keyMenu.Name
mBtn.TextColor3=COL.acc
mBtn.Font=Enum.Font.Code
mBtn.TextSize=12
mBtn.Parent=kTab
mBtn.MouseButton1Click:Connect(function()
    listening="keyMenu"
    mBtn.Text="Press a key..."
end)

UIS.InputBegan:Connect(function(i,pr)
    if pr then return end
    if listening then
        if i.UserInputType==Enum.UserInputType.Keyboard then
            CFG[listening]=i.KeyCode
            mBtn.Text="Menu: "..CFG[listening].Name
            listening=nil
        end
        return
    end
    if i.KeyCode==CFG.keyMenu then main.Visible=not main.Visible end
end)

local drag,ds,sp
wm.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        drag=true
        ds=i.Position
        sp=main.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-ds
        main.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
end)

-- ENGINES
local flyBV, flyBG, flyConn

local function bindChar(c)
    local hum=c:WaitForChild("Humanoid",5)
    if not hum then return end
    hum.WalkSpeed=CFG.ws
    hum.JumpPower=CFG.jp
    hum.UseJumpPower=true
end
if LP.Character then bindChar(LP.Character) end
LP.CharacterAdded:Connect(bindChar)

RS.Stepped:Connect(function()
    local c=LP.Character
    if not c then return end
    if CFG.noclip then
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                p.CanCollide=false
            end
        end
    end
    local hum=c:FindFirstChildOfClass("Humanoid")
    if hum then
        if CFG.speed then hum.WalkSpeed=CFG.ws end
        hum.JumpPower=CFG.jp
        hum.UseJumpPower=true
    end
end)

local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn=nil end
    if flyBV then flyBV:Destroy() flyBV=nil end
    if flyBG then flyBG:Destroy() flyBG=nil end
end

local function startFly()
    local c=LP.Character
    if not c then return end
    local hrp=c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    stopFly()
    flyBV=Instance.new("BodyVelocity")
    flyBV.MaxForce=Vector3.new(1e5,1e5,1e5)
    flyBV.Velocity=Vector3.new(0,0,0)
    flyBV.Parent=hrp
    flyBG=Instance.new("BodyGyro")
    flyBG.MaxTorque=Vector3.new(1e5,1e5,1e5)
    flyBG.P=1e4
    flyBG.CFrame=hrp.CFrame
    flyBG.Parent=hrp
    flyConn=RS.RenderStepped:Connect(function()
        local c2=LP.Character
        local hrp2=c2 and c2:FindFirstChild("HumanoidRootPart")
        if not hrp2 or not flyBV or not flyBG then return end
        local mv=Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then mv=mv+CAM.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then mv=mv-CAM.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then mv=mv-CAM.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then mv=mv+CAM.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then mv=mv+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then mv=mv-Vector3.new(0,1,0) end
        if mv.Magnitude>0 then
            flyBV.Velocity=mv.Unit*CFG.flySpeed
        else
            flyBV.Velocity=Vector3.new(0,0,0)
        end
        flyBG.CFrame=CAM.CFrame
    end)
end

task.spawn(function()
    local was=false
    while true do
        task.wait(0.1)
        if CFG.fly and not was then startFly() end
        if not CFG.fly and was then stopFly() end
        was=CFG.fly
    end
end)

-- AUTO CLICKER
task.spawn(function()
    local m1=getgenv and getgenv().mouse1click
    local VIM=game:GetService("VirtualInputManager")
    while true do
        if CFG.click then
            local d=1/math.max(1,CFG.cps)
            if m1 then pcall(m1)
            else
                pcall(function()
                    VIM:SendMouseButtonEvent(0,0,0,true,game,0)
                    VIM:SendMouseButtonEvent(0,0,0,false,game,0)
                end)
            end
            task.wait(d)
        else
            task.wait(0.1)
        end
    end
end)

-- FARM
task.spawn(function()
    while true do
        if CFG.farm then
            pcall(function()
                local c=LP.Character
                local hrp=c and c:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _,d in ipairs(WS:GetDescendants()) do
                        if d:IsA("ProximityPrompt") then
                            local pp=d.Parent
                            if pp and pp:IsA("BasePart") then
                                local dist=(pp.Position-hrp.Position).Magnitude
                                if dist<CFG.farmDist then
                                    if d.ActionText==CFG.farmPrompt
                                    or (d.ObjectText and d.ObjectText:find(CFG.farmTool,1,true))
                                    or pp.Name:find(CFG.farmTool,1,true) then
                                        d:InputHoldBegin()
                                        task.wait(0.1)
                                        d:InputHoldEnd()
                                    end
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

-- FULLBRIGHT
task.spawn(function()
    local Lighting=game:GetService("Lighting")
    local ob, oc, of = Lighting.Brightness, Lighting.ClockTime, Lighting.FogEnd
    local on=false
    while true do
        task.wait(0.2)
        if CFG.bright and not on then
            ob=Lighting.Brightness
            oc=Lighting.ClockTime
            of=Lighting.FogEnd
            Lighting.Brightness=3
            Lighting.ClockTime=14
            Lighting.FogEnd=100000
            on=true
        elseif not CFG.bright and on then
            Lighting.Brightness=ob
            Lighting.ClockTime=oc
            Lighting.FogEnd=of
            on=false
        end
    end
end)

-- CAMERA LOCK
task.spawn(function()
    while true do
        task.wait()
        local target=nil
        if CFG.aim then
            local best, bd = nil, math.huge
            local sc=Vector2.new(CAM.ViewportSize.X/2, CAM.ViewportSize.Y/2)
            for _,p in ipairs(P:GetPlayers()) do
                if p~=LP then
                    local c=p.Character
                    local part=c and c:FindFirstChild(CFG.aimPart)
                    local hum=c and c:FindFirstChildOfClass("Humanoid")
                    if part and part:IsA("BasePart") and hum and hum.Health>0 then
                        local sp, on = CAM:WorldToViewportPoint(part.Position)
                        if on then
                            local d=(Vector2.new(sp.X,sp.Y)-sc).Magnitude
                            if d<CFG.aimFov and d<bd then
                                bd=d
                                best=part
                            end
                        end
                    end
                end
            end
            target=best
        end
        if target then
            local cur=CAM.CFrame
            CAM.CFrame=cur:Lerp(CFrame.lookAt(cur.Position,target.Position),0.25)
        end
    end
end)

-- SILENT AIM + ESP
local headT={}
local function jit(pos)
    if not CFG.hum then return pos end
    local j=(math.random()-0.5)*2*CFG.jitter
    local ax=Vector3.new(math.random()-0.5,math.random()-0.5,0)
    if ax.Magnitude<1e-3 then return pos end
    ax=ax.Unit
    local cf=CFrame.fromAxisAngle(ax,math.rad(j))
    local rel=pos-CAM.CFrame.Position
    return (cf*rel)+CAM.CFrame.Position
end

local function okHS(part)
    if not CFG.hum then return true end
    if part.Name~="Head" then return false end
    local now=os.clock()
    for i=#headT,1,-1 do
        if now-headT[i]>1 then table.remove(headT,i) end
    end
    if #headT>=CFG.hsCap then return false end
    if math.random()>CFG.hsRate then return false end
    table.insert(headT,now)
    return true
end

local mouse=LP:GetMouse()
local mFields={"Hit","Target","UnitRay","Origin"}

if typeof(getrawmetatable)=="function" and typeof(setreadonly)=="function" and typeof(newcclosure)=="function" then
    local mt=getrawmetatable(game)
    setreadonly(mt,false)
    local oldIdx=mt.__index
    mt.__index=newcclosure(function(self,k)
        if self==mouse and CFG.aim and table.find(mFields,k) then
            local best, bd = nil, math.huge
            local sc=Vector2.new(CAM.ViewportSize.X/2, CAM.ViewportSize.Y/2)
            for _,p in ipairs(P:GetPlayers()) do
                if p~=LP then
                    local c=p.Character
                    local part=c and c:FindFirstChild(CFG.aimPart)
                    local hum=c and c:FindFirstChildOfClass("Humanoid")
                    if part and part:IsA("BasePart") and hum and hum.Health>0 then
                        local sp, on = CAM:WorldToViewportPoint(part.Position)
                        if on then
                            local d=(Vector2.new(sp.X,sp.Y)-sc).Magnitude
                            if d<CFG.aimFov and d<bd then
                                bd=d
                                best=part
                            end
                        end
                    end
                end
            end
            if best then
                if not okHS(best) and best.Name=="Head" then
                    local t=best.Parent and best.Parent:FindFirstChild("UpperTorso")
                    if t then best=t end
                end
                local pos=jit(best.Position)
                if k=="Hit" then return CFrame.new(pos) end
                if k=="Target" then return best end
                if k=="Origin" then return CAM.CFrame.Position end
                if k=="UnitRay" then return Ray.new(CAM.CFrame.Position,(pos-CAM.CFrame.Position).Unit) end
            end
        end
        return oldIdx(self,k)
    end)
    setreadonly(mt,true)
end

local espFolder=Instance.new("Folder")
espFolder.Name="GOTESP"
espFolder.Parent=gui
local espData={}

local function makeESP(p)
    if p==LP or espData[p] then return end
    local e={}
    local box=Instance.new("Frame")
    box.BackgroundTransparency=1
    box.BorderSizePixel=2
    box.BorderColor3=COL.red
    box.Visible=false
    box.Parent=espFolder
    e.box=box
    local nm=Instance.new("TextLabel")
    nm.Size=UDim2.new(1,0,0,14)
    nm.Position=UDim2.new(0,0,0,-16)
    nm.BackgroundTransparency=1
    nm.TextColor3=Color3.fromRGB(255,255,
