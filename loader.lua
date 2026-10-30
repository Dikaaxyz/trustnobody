-- GRAYS ON TOP — Xeno-Stable Build
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
    esp=false, espBox=true, espName=true, espHealth=true,
    noclip=false, speed=false, ws=16, jp=50,
    fly=false, flySpeed=60,
    bright=false,
    farm=false, farmTool="Marshmallow Bag", farmPrompt="Craft", farmInt=0.6, farmDist=20,
    click=false, cps=10,
    keyMenu=Enum.KeyCode.RightShift,
    lock=false,
}

local gui = Instance.new("ScreenGui")
gui.Name="GOT"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=999999
gui.Parent=CG
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

local header=Instance.new("Frame")
header.Size=UDim2.new(1,0,0,64)
header.BackgroundColor3=COL.bg
header.BorderSizePixel=0
header.Parent=main

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
        else
            b.TextColor3=COL.dim
            b.BackgroundColor3=COL.panel
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
    b.Font=Enum.Font.GothamBold
    b.TextSize=12
    b.Parent=tabBar
    table.insert(tabs,b)
    local pg=Instance.new("ScrollingFrame")
    pg.Size=UDim2.new(1,0,1,0)
    pg.BackgroundTransparency=1
    pg.BorderSizePixel=0
    pg.ScrollBarThickness=3
    pg.CanvasSize=UDim2.new(0,0,0,0)
    pg.Visible=false
    pg.Parent=content
    local l=Instance.new("UIListLayout")
    l.Padding=UDim.new(0,1)
    l.Parent=pg
    local pd=Instance.new("UIPadding")
    pd.PaddingLeft=UDim.new(0,14)
    pd.PaddingTop=UDim.new(0,12)
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
    l.Parent=p
end

local function toggle(p,label,key,cb)
    local row=Instance.new("TextButton")
    row.Size=UDim2.new(1,0,0,32)
    row.BackgroundColor3=COL.panel
    row.BorderSizePixel=0
    row.Text=""
    row.Parent=p
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
    pill.Parent=row
    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,10,0,10)
    knob.Position=UDim2.new(0,3,0.5,-5)
    knob.BackgroundColor3=COL.dim
    knob.Parent=pill
    local kc=Instance.new("UICorner")
    kc.CornerRadius=UDim.new(1,0)
    kc.Parent=knob
    local function refresh()
        if CFG[key] then
            knob.Position=UDim2.new(1,-13,0.5,-5)
            knob.BackgroundColor3=COL.acc
            pill.BackgroundColor3=COL.acc
            lbl.TextColor3=COL.acc
        else
            knob.Position=UDim2.new(0,3,0.5,-5)
            knob.BackgroundColor3=COL.dim
            pill.BackgroundColor3=COL.bg
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
    vl.Text=tostring(CFG[key])
    vl.TextColor3=COL.acc
    vl.Font=Enum.Font.Code
    vl.TextSize=12
    vl.TextXAlignment=Enum.TextXAlignment.Right
    vl.Parent=h
    local bar=Instance.new("Frame")
    bar.Size=UDim2.new(1,-20,0,4)
    bar.Position=UDim2.new(0,10,1,-14)
    bar.BackgroundColor3=COL.bg
    bar.Parent=h
    local fill=Instance.new("Frame")
    fill.Size=UDim2.new(math.clamp((CFG[key]-mn)/(mx-mn),0,1),0,1,0)
    fill.BackgroundColor3=COL.acc
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
        vl.Text=tostring(v)
        if cb then pcall(cb,v) end
    end)
end

local cTab=makeTab("COMBAT",74)
local eTab=makeTab("ESP",54)
local mTab=makeTab("MOVE",58)
local fTab=makeTab("FARM",56)
local xTab=makeTab("MISC",54)
setTab(1)

section(cTab,"CAMERA LOCK")
toggle(cTab,"Lock Aim","lock")
slider(cTab,"FOV Radius","aimFov",50,600,10)

section(eTab,"ESP")
toggle(eTab,"ESP Master","esp")
toggle(eTab,"Box","espBox")
toggle(eTab,"Name","espName")
toggle(eTab,"Health","espHealth")

section(mTab,"MOVEMENT")
toggle(mTab,"Noclip","noclip")
toggle(mTab,"Speed","speed")
slider(mTab,"WalkSpeed","ws",16,300,1)
toggle(mTab,"Fly","fly")
slider(mTab,"Fly Speed","flySpeed",10,300,5)

section(fTab,"AUTO-FARM")
toggle(fTab,"Farm","farm")
slider(fTab,"Interval (s)","farmInt",0.2,3.0,0.1)
slider(fTab,"Proximity","farmDist",5,100,1)

section(xTab,"MISC")
toggle(xTab,"Auto Clicker","click")
slider(xTab,"CPS","cps",1,30,1)
toggle(xTab,"Fullbright","bright")

-- CAMERA LOCK
task.spawn(function()
    while true do
        task.wait()
        if CFG.lock then
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
                local cur=CAM.CFrame
                CAM.CFrame=cur:Lerp(CFrame.lookAt(cur.Position,best.Position),0.25)
            end
        end
    end
end)

-- NOCLIP / SPEED
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

-- FLY
local flyBV, flyBG, flyConn
local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn=nil end
    if flyBV then flyBV:Destroy() flyBV=nil end
    if flyBG then flyBG:Destroy() flyBG=nil end
end

task.spawn(function()
    local was=false
    while true do
        task.wait(0.1)
        if CFG.fly and not was then
            local c=LP.Character
            local hrp=c and c:FindFirstChild("HumanoidRootPart")
            if hrp then
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
                    local h2=c and c:FindFirstChild("HumanoidRootPart")
                    if not h2 or not flyBV or not flyBG then return end
                    local mv=Vector3.new(0,0,0)
                    if UIS:IsKeyDown(Enum.KeyCode.W) then mv=mv+CAM.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then mv=mv-CAM.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then mv=mv-CAM.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then mv=mv+CAM.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.Space) then mv=mv+Vector3.new(0,1,0) end
                    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then mv=mv-Vector3.new(0,1,0) end
                    if mv.Magnitude>0 then flyBV.Velocity=mv.Unit*CFG.flySpeed else flyBV.Velocity=Vector3.new(0,0,0) end
                    flyBG.CFrame=CAM.CFrame
                end)
            end
        elseif not CFG.fly and was then
            stopFly()
        end
        was=CFG.fly
    end
end)

-- CLICKER
task.spawn(function()
    local m1=getgenv and getgenv().mouse1click
    local VIM=game:GetService("VirtualInputManager")
    while true do
        if CFG.click then
            local d=1/math.max(1,CFG.cps)
            if m1 then pcall(m1) else
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

-- FARM (Xeno Safe)
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
                                        if fireproximityprompt then
                                            fireproximityprompt(d)
                                        end
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
local Lighting=game:GetService("Lighting")
local ob, oc, of = Lighting.Brightness, Lighting.ClockTime, Lighting.FogEnd
local bOn=false
task.spawn(function()
    while true do
        task.wait(0.2)
        if CFG.bright and not bOn then
            ob=Lighting.Brightness
            oc=Lighting.ClockTime
            of=Lighting.FogEnd
            Lighting.Brightness=3
            Lighting.ClockTime=14
            Lighting.FogEnd=100000
            bOn=true
        elseif not CFG.bright and bOn then
            Lighting.Brightness=ob
            Lighting.ClockTime=oc
            Lighting.FogEnd=of
            bOn=false
        end
    end
end)

UIS.InputBegan:Connect(function(i,pr)
    if pr then return end
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

print("[GRAYS ON TOP] Xeno-stable build loaded.")
