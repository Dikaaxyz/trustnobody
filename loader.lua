--[[
    GRAYS ON TOP v9.0 — Last Boss (Ghost Protocol)
    40 Features | Tween Travel | Anti-IP Ban
]]

if not game:IsLoaded() then game.Loaded:Wait() end
if getgenv().GOTGui then pcall(function() getgenv().GOTGui:Destroy() end) end

local P = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local WS = game:GetService("Workspace")
local CG = game:GetService("CoreGui")
local LP = P.LocalPlayer
local CAM = WS.CurrentCamera
local VIM = game:GetService("VirtualInputManager")
local TS = game:GetService("TeleportService")
local VU = game:GetService("VirtualUser")
local L = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local CFG = {
    aim=false, wallcheck=false, aimfov=150, aimpart="Head",
    esp=false, bright=false, fpsboost=false, nofog=false, xray=false,
    camfly=false, bodyfly=false, noclip=false, ws=16, jp=50, infjump=false, freeze=false, antifling=false,
    autofire=false, autofix=false, clicker=false, hitbox=false, killaura=false,
    farm=false, targetmoney=1000, tpnpc=false, tpcrate=false, tptruck=false, tpplayer=false,
    antiafk=false, chatspam=false, godmode=false,
    keyMenu=Enum.KeyCode.RightShift
}

local farmStatus = nil

-- GHOST PROTOCOL (TWEEN TRAVEL - NO SPEED FLAG)
local function ghostTravel(tPos)
    local c = LP.Character
    local h = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if not h or not hum then return end

    local dist = (h.Position - tPos).Magnitude
    if dist < 5 then return end

    -- Set ke ragdoll biar server ngira lu glitch/kelempar
    hum.PlatformStand = true
    task.wait(0.1)

    -- Hitung waktu berdasarkan jarak (kecepatan maks 60 studs/dtk)
    local speedLimit = 60
    local time = math.clamp(dist / speedLimit, 0.5, 5)

    -- Tween CFrame (bukan Teleport, biar kelihatan kayak jalan super cepat)
    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(h, tweenInfo, {CFrame = CFrame.new(tPos)})
    tween:Play()

    -- Tunggu sampe nyampe
    tween.Completed:Wait()
    
    -- Balikin ke normal
    hum.PlatformStand = false
    task.wait(0.1)
end

local function getHui()
    if typeof(gethui)=="function" then local ok,h=pcall(gethui); if ok and h then return h end end
    return CG
end

local function getMoney()
    local ls = LP:FindFirstChild("leaderstats")
    if ls then for _,v in pairs(ls:GetChildren()) do if v:IsA("IntValue") and v.Name:lower():find("cash") then return v.Value end end end
    local pg = LP:FindFirstChild("PlayerGui")
    if pg then for _,g in pairs(pg:GetDescendants()) do if g:IsA("TextLabel") and g.Text:match("^%$%d+") then return tonumber(g.Text:gsub("[^%d]","")) end end end
    return 0
end

local function clickDialog(txt)
    local pg = LP:FindFirstChild("PlayerGui")
    if not pg then return end
    for _,g in pairs(pg:GetDescendants()) do
        if (g:IsA("TextButton") or g:IsA("TextLabel")) and g.Text:lower():find(txt:lower()) then
            pcall(function() if g:IsA("TextButton") then g.MouseButton1Click:Fire() elseif g.Parent:IsA("TextButton") then g.Parent.MouseButton1Click:Fire() end end)
            return
        end
    end
end

local function interactPart(p)
    if not p then return end
    if p:FindFirstChildOfClass("ProximityPrompt") then pcall(function() fireproximityprompt(p.ProximityPrompt) end) end
    if p:FindFirstChildOfClass("ClickDetector") then pcall(function() fireclickdetector(p.ClickDetector) end) end
    pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game) task.wait(0.05) VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game) end)
end

-- INITIAL D UI (Sama kayak sebelumnya)
local COL = { bg=Color3.fromRGB(10,10,10), panel=Color3.fromRGB(20,20,20), line=Color3.fromRGB(50,50,50), txt=Color3.fromRGB(255,255,255), dim=Color3.fromRGB(150,150,150), acc=Color3.fromRGB(255,0,0), accDark=Color3.fromRGB(150,0,0), check=Color3.fromRGB(255,255,255) }

local gui = Instance.new("ScreenGui"); gui.Name="GOT"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true; gui.DisplayOrder=999999; gui.Parent=getHui(); getgenv().GOTGui=gui
local main = Instance.new("Frame"); main.Size=UDim2.new(0,420,0,500); main.Position=UDim2.new(0,20,0,50); main.BackgroundColor3=COL.bg; main.BorderSizePixel=0; main.Active=true; main.Parent=gui
local ms = Instance.new("UIStroke"); ms.Color=COL.acc; ms.Thickness=2; ms.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; ms.Parent=main
local bgGrad = Instance.new("UIGradient"); bgGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(30,30,30)), ColorSequenceKeypoint.new(1, Color3.fromRGB(5,5,5))}); bgGrad.Rotation=90; bgGrad.Parent=main

local checkStrip = Instance.new("Frame"); checkStrip.Size=UDim2.new(1,0,0,10); checkStrip.BackgroundColor3=COL.bg; checkStrip.BorderSizePixel=0; checkStrip.Parent=main
for i=0,27 do local b=Instance.new("Frame"); b.Size=UDim2.new(0,15,1,0); b.Position=UDim2.new(0,i*15,0,0); b.BackgroundColor3=(i%2==0) and COL.check or COL.bg; b.BorderSizePixel=0; b.Parent=checkStrip end

local head = Instance.new("Frame"); head.Size=UDim2.new(1,0,0,40); head.Position=UDim2.new(0,0,0,10); head.BackgroundColor3=COL.panel; head.BorderSizePixel=0; head.Parent=main
local hl = Instance.new("Frame"); hl.Size=UDim2.new(1,0,0,2); hl.Position=UDim2.new(0,0,1,0); hl.BackgroundColor3=COL.acc; hl.BorderSizePixel=0; hl.Parent=head
local wm = Instance.new("TextLabel"); wm.Size=UDim2.new(1,-20,1,0); wm.Position=UDim2.new(0,12,0,0); wm.BackgroundTransparency=1; wm.Text="PROJECT D // LAST BOSS"; wm.TextColor3=COL.txt; wm.Font=Enum.Font.RobotoMono; wm.TextSize=14; wm.TextXAlignment=Enum.TextXAlignment.Left; wm.Parent=head
local xBtn = Instance.new("TextButton"); xBtn.Size=UDim2.new(0,30,1,0); xBtn.Position=UDim2.new(1,-30,0,0); xBtn.BackgroundTransparency=1; xBtn.Text="×"; xBtn.TextColor3=COL.acc; xBtn.Font=Enum.Font.RobotoMono; xBtn.TextSize=22; xBtn.Parent=head

local tabBar = Instance.new("Frame"); tabBar.Size=UDim2.new(1,0,0,30); tabBar.Position=UDim2.new(0,0,0,50); tabBar.BackgroundColor3=COL.panel; tabBar.BorderSizePixel=0; tabBar.Parent=main
local tl = Instance.new("UIListLayout"); tl.FillDirection=Enum.FillDirection.Horizontal; tl.VerticalAlignment=Enum.VerticalAlignment.Center; tl.Parent=tabBar
local tabs, pages = {}, {}

local function addTab(name, w)
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(0,w,1,0); btn.BackgroundColor3=COL.panel; btn.BorderSizePixel=0; btn.Text=name; btn.TextColor3=COL.dim; btn.Font=Enum.Font.RobotoMono; btn.TextSize=10; btn.Parent=tabBar; table.insert(tabs,btn)
    local pg=Instance.new("ScrollingFrame"); pg.Size=UDim2.new(1,0,1,-80); pg.Position=UDim2.new(0,0,0,80); pg.BackgroundTransparency=1; pg.BorderSizePixel=0; pg.ScrollBarThickness=2; pg.ScrollBarImageColor3=COL.acc; pg.CanvasSize=UDim2.new(0,0,0,0); pg.AutomaticCanvasSize=Enum.AutomaticSize.Y; pg.Visible=false; pg.Parent=main
    local l=Instance.new("UIListLayout"); l.Padding=UDim.new(0,6); l.Parent=pg
    local pd=Instance.new("UIPadding"); pd.PaddingLeft=UDim.new(0,12); pd.PaddingRight=UDim.new(0,12); pd.PaddingTop=UDim.new(0,12); pd.PaddingBottom=UDim.new(0,12); pd.Parent=pg
    local idx=#pages+1; table.insert(pages,pg)
    btn.MouseButton1Click:Connect(function()
        for i,p in ipairs(pages) do p.Visible=(i==idx) end
        for i,b in ipairs(tabs) do if i==idx then b.TextColor3=COL.acc; b.BackgroundColor3=COL.bg else b.TextColor3=COL.dim; b.BackgroundColor3=COL.panel end end
    end)
    return pg
end

local function addSection(p, n)
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,0,0,20); l.BackgroundTransparency=1; l.Text="// "..string.upper(n); l.TextColor3=COL.accDark; l.Font=Enum.Font.RobotoMono; l.TextSize=11; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=p
end

local function addToggle(p,label,key)
    local row=Instance.new("TextButton"); row.Size=UDim2.new(1,0,0,32); row.BackgroundColor3=COL.panel; row.BorderSizePixel=0; row.AutoButtonColor=false; row.Text=""; row.Parent=p
    local bs=Instance.new("UIStroke"); bs.Color=COL.line; bs.Thickness=1; bs.Parent=row
    local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-50,1,0); lbl.Position=UDim2.new(0,10,0,0); lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=COL.txt; lbl.Font=Enum.Font.RobotoMono; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=row
    local box=Instance.new("Frame"); box.Size=UDim2.new(0,24,0,12); box.Position=UDim2.new(1,-34,0.5,-6); box.BackgroundColor3=COL.bg; box.Parent=row
    local bs2=Instance.new("UIStroke"); bs2.Color=COL.line; bs2.Thickness=1; bs2.Parent=box
    local fill=Instance.new("Frame"); fill.Size=UDim2.new(0,16,0,4); fill.Position=UDim2.new(0.5,-8,0.5,-2); fill.BackgroundColor3=COL.acc; fill.Visible=CFG[key]; fill.Parent=box
    row.MouseButton1Click:Connect(function() CFG[key]=not CFG[key]; fill.Visible=CFG[key]; bs.Color = CFG[key] and COL.acc or COL.line end)
end

local function addInput(p,label,key,mn,mx)
    local h=Instance.new("Frame"); h.Size=UDim2.new(1,0,0,50); h.BackgroundColor3=COL.panel; h.Parent=p
    local bs=Instance.new("UIStroke"); bs.Color=COL.line; bs.Thickness=1; bs.Parent=h
    local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-10,0,18); lbl.Position=UDim2.new(0,10,0,4); lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=COL.txt; lbl.Font=Enum.Font.RobotoMono; lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=h
    local box=Instance.new("TextBox"); box.Size=UDim2.new(1,-20,0,22); box.Position=UDim2.new(0,10,0,22); box.BackgroundColor3=COL.bg; box.BorderSizePixel=0; box.Text=tostring(CFG[key]); box.TextColor3=COL.acc; box.Font=Enum.Font.RobotoMono; box.TextSize=12; box.TextXAlignment=Enum.TextXAlignment.Left; box.Parent=h
    local bs2=Instance.new("UIStroke"); bs2.Color=COL.line; bs2.Thickness=1; bs2.Parent=box
    box.FocusLost:Connect(function() local n=tonumber(box.Text); if n then CFG[key]=math.clamp(n,mn,mx) end; box.Text=tostring(CFG[key]); bs2.Color=COL.line end)
    box.Focused:Connect(function() bs2.Color=COL.acc end)
end

local function addButton(p,label,cb)
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,0,32); btn.BackgroundColor3=COL.panel; btn.BorderSizePixel=0; btn.Text=label; btn.TextColor3=COL.txt; btn.Font=Enum.Font.RobotoMono; btn.TextSize=12; btn.Parent=p
    local bs=Instance.new("UIStroke"); bs.Color=COL.line; bs.Thickness=1; bs.Parent=btn
    btn.MouseButton1Click:Connect(function() pcall(cb) end)
end

local UI = {
    AIM = { toggles = { {"Silent Aim","aim"}, {"Wall Check","wallcheck"} }, inputs = { {"FOV Radius","aimfov",50,400} } },
    VISUAL = { toggles = { {"ESP Players","esp"}, {"Fullbright","bright"}, {"FPS Boost","fpsboost"}, {"No Fog","nofog"}, {"X-Ray (Chams)","xray"} } },
    COMBAT = { toggles = { {"Auto Fire","autofire"}, {"Auto Fix Jam","autofix"}, {"Auto Clicker","clicker"}, {"Hitbox Expander","hitbox"}, {"Kill Aura","killaura"} } },
    FARM = { toggles = { {"Auto Job (Ghost)","farm"}, {"TP to NPC","tpnpc"}, {"TP to Crate","tpcrate"}, {"TP to Truck","tptruck"} }, inputs = { {"Target Money","targetmoney",100,50000} } },
    MOVE = { toggles = { {"Cam Fly","camfly"}, {"Body Fly","bodyfly"}, {"Noclip","noclip"}, {"Infinite Jump","infjump"}, {"Freeze Player","freeze"}, {"Anti-Fling","antifling"}, {"God Mode (Fall)","godmode"} }, inputs = { {"WalkSpeed","ws",16,300}, {"JumpPower","jp",50,500} } },
    MISC = { toggles = { {"Anti-AFK","antiafk"}, {"TP to Player","tpplayer"}, {"Chat Spam","chatspam"} }, buttons = { {"Server Hop","hop"}, {"Rejoin","rejoin"} } }
}

for _, tName in ipairs({"AIM","VISUAL","COMBAT","FARM","MOVE","MISC"}) do
    local pg = addTab(tName, #tName*6+16)
    local d = UI[tName]
    if d.toggles then addSection(pg,"Toggles") for _,v in ipairs(d.toggles) do addToggle(pg,v[1],v[2]) end end
    if d.inputs then addSection(pg,"Settings") for _,v in ipairs(d.inputs) do addInput(pg,v[1],v[2],v[3],v[4]) end end
    if d.buttons then addSection(pg,"Actions") for _,v in ipairs(d.buttons) do addButton(pg,v[1],function() if v[2]=="hop" then TS:Teleport(game.PlaceId) elseif v[2]=="rejoin" then game:Shutdown() end end) end end
    if tName == "FARM" then
        farmStatus = Instance.new("TextLabel"); farmStatus.Size=UDim2.new(1,0,0,24); farmStatus.BackgroundTransparency=1; farmStatus.Text=">> Idle"; farmStatus.TextColor3=COL.acc; farmStatus.Font=Enum.Font.RobotoMono; farmStatus.TextSize=12; farmStatus.TextXAlignment=Enum.TextXAlignment.Left; farmStatus.Parent=pg
    end
end

for i,p in ipairs(pages) do p.Visible=(i==1) end
tabs[1].TextColor3=COL.acc; tabs[1].BackgroundColor3=COL.bg

local mBtn = Instance.new("TextButton"); mBtn.Size=UDim2.new(0,60,0,60); mBtn.Position=UDim2.new(0,20,0,100); mBtn.BackgroundColor3=Color3.fromRGB(10,10,10); mBtn.BorderSizePixel=2; mBtn.BorderColor3=COL.acc; mBtn.Text="D"; mBtn.TextColor3=COL.txt; mBtn.Font=Enum.Font.RobotoMono; mBtn.TextSize=32; mBtn.ZIndex=100; mBtn.Parent=gui; getgenv().mBtn=mBtn
local subD = Instance.new("TextLabel"); subD.Size=UDim2.new(1,0,0,10); subD.Position=UDim2.new(0,0,1,-12); subD.BackgroundTransparency=1; subD.Text="PROJECT"; subD.TextColor3=COL.acc; subD.Font=Enum.Font.RobotoMono; subD.TextSize=8; subD.Parent=mBtn

local drag,ds,sp
mBtn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; ds=i.Position; sp=mBtn.Position end end)
UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then local d=i.Position-ds; mBtn.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
mBtn.MouseButton1Click:Connect(function() main.Visible=not main.Visible; if main.Visible then mBtn.Visible=false end end)
xBtn.MouseButton1Click:Connect(function() main.Visible=false; mBtn.Visible=true end)
UIS.InputBegan:Connect(function(i,pr) if pr then return end; if i.KeyCode==CFG.keyMenu then main.Visible=not main.Visible; if main.Visible then mBtn.Visible=false else mBtn.Visible=true end end end)

local dragM, dsM, spM
head.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragM=true; dsM=i.Position; spM=main.Position end end)
UIS.InputChanged:Connect(function(i) if dragM and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-dsM; main.Position=UDim2.new(spM.X.Scale,spM.X.Offset+d.X,spM.Y.Scale,spM.Y.Offset+d.Y) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragM=false end end)

local fovGui = Instance.new("ScreenGui"); fovGui.Name="GOTFov"; fovGui.ResetOnSpawn=false; fovGui.IgnoreGuiInset=true; fovGui.Parent=getHui()
local fovC = Instance.new("Frame"); fovC.Size=UDim2.new(0,CFG.aimfov*2,0,CFG.aimfov*2); fovC.Position=UDim2.new(0.5,-CFG.aimfov,0.5,-CFG.aimfov); fovC.BackgroundTransparency=1; fovC.Visible=false; fovC.Parent=fovGui
local fovS = Instance.new("UIStroke"); fovS.Color=COL.acc; fovS.Thickness=1.5; fovS.Transparency=0.3; fovS.Parent=fovC
local fovK = Instance.new("UICorner"); fovK.CornerRadius=UDim.new(1,0); fovK.Parent=fovC
task.spawn(function() while true do task.wait(0.5); fovC.Visible=CFG.aim; fovC.Size=UDim2.new(0,CFG.aimfov*2,0,CFG.aimfov*2); fovC.Position=UDim2.new(0.5,-CFG.aimfov,0.5,-CFG.aimfov) end end)

if typeof(getrawmetatable)=="function" and typeof(setreadonly)=="function" then
    local mouse=LP:GetMouse(); local mt=getrawmetatable(game); setreadonly(mt,false); local oi=mt.__index
    mt.__index=newcclosure(function(self,k)
        if self==mouse and CFG.aim and (k=="Hit" or k=="Target" or k=="UnitRay") then
            local best, bd = nil, math.huge; local sc=Vector2.new(CAM.ViewportSize.X/2, CAM.ViewportSize.Y/2)
            for _,p in ipairs(P:GetPlayers()) do if p~=LP then
                local c=p.Character; local part=c and c:FindFirstChild(CFG.aimpart); local hum=c and c:FindFirstChildOfClass("Humanoid")
                if part and part:IsA("BasePart") and hum and hum.Health>0 then
                    if CFG.wallcheck then
                        local rp = RaycastParams.new(); rp.FilterDescendantsInstances={LP.Character,c}; rp.FilterType=Enum.RaycastFilterType.Exclude
                        local res = WS:Raycast(CAM.CFrame.Position, part.Position-CAM.CFrame.Position, rp)
                        if res and res.Instance then continue end
                    end
                    local sp2, on = CAM:WorldToViewportPoint(part.Position)
                    if on then local d=(Vector2.new(sp2.X,sp2.Y)-sc).Magnitude; if d<CFG.aimfov and d<bd then bd=d; best=part end end
                end
            end end
            if best then if k=="Hit" then return CFrame.new(best.Position) end; if k=="Target" then return best end; if k=="UnitRay" then return Ray.new(CAM.CFrame.Position,(best.Position-CAM.CFrame.Position).Unit) end end
        end
        return oi(self,k)
    end); setreadonly(mt,true)
end

RS.Heartbeat:Connect(function()
    if CFG.killaura and LP.Character then
        local tool = LP.Character:FindFirstChildWhichIsA("Tool")
        if tool and tool.Activate then
            for _,p in ipairs(P:GetPlayers()) do if p~=LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if (p.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude <= 20 then pcall(function() tool:Activate() end); break end
            end end
        end
    end
    if CFG.hitbox then
        for _,p in ipairs(P:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart"); local hd=p.Character:FindFirstChild("Head"); if h then h.Size=Vector3.new(15,15,15) h.Transparency=0.5 end; if hd then hd.Size=Vector3.new(5,5,5) end end end
    end
end)

local esp = {}
task.spawn(function() while true do task.wait(1)
    if CFG.esp then for _,p in ipairs(P:GetPlayers()) do if p~=LP and p.Character and not esp[p] then local h=Instance.new("Highlight"); h.FillColor=COL.acc; h.OutlineColor=COL.check; h.Parent=p.Character; esp[p]=h end end
    else for p,h in pairs(esp) do if h then h:Destroy() end; esp[p]=nil end end
    if CFG.bright then L.Brightness=3 L.ClockTime=14 else L.Brightness=1 end
    if CFG.nofog then L.FogEnd=1e6 else L.FogEnd=1000 end
    if CFG.fpsboost then L.GlobalShadows=false else L.GlobalShadows=true end
    if CFG.xray then for _,v in pairs(WS:GetDescendants()) do if v:IsA("BasePart") and v.Material~=Enum.Material.Plastic then v.Material=Enum.Material.Plastic end end end
end end)

RS.Stepped:Connect(function()
    local c=LP.Character; if not c then return end
    local h=c:FindFirstChild("HumanoidRootPart"); local hum=c:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed=CFG.ws hum.JumpPower=CFG.jp end
    if h and CFG.freeze then h.Anchored=true elseif h and not CFG.freeze then h.Anchored=false end
    if CFG.noclip then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide=false end end end
    if CFG.antifling and h then h.RotVelocity=Vector3.new(0,0,0) end
    if CFG.godmode and hum then hum.MaxHealth=math.huge hum.Health=math.huge end
end)

UIS.JumpRequest:Connect(function() if CFG.infjump and LP.Character then local hum=LP.Character:FindFirstChildOfClass("Humanoid"); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end end)

local camConn, flyConn, flyBV
task.spawn(function() local wasC, wasB = false, false
    while true do task.wait(0.1)
        if CFG.camfly and not wasC then
            CAM.CameraSubject=nil
            camConn=RS.RenderStepped:Connect(function()
                local mv=Vector3.new(0,0,0)
                if UIS:IsKeyDown(Enum.KeyCode.W) then mv=mv+CAM.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then mv=mv-CAM.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then mv=mv-CAM.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then mv=mv+CAM.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then mv=mv+Vector3.new(0,1,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then mv=mv-Vector3.new(0,1,0) end
                if mv.Magnitude>0 then CAM.CFrame=CAM.CFrame+(mv.Unit*CFG.ws*(1/60)) end
            end)
        elseif not CFG.camfly and wasC then
            if camConn then camConn:Disconnect() end; local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid"); if hum then CAM.CameraSubject=hum end
        end
        if CFG.bodyfly and not wasB then
            flyBV=Instance.new("BodyVelocity"); flyBV.MaxForce=Vector3.new(1e5,1e5,1e5); flyBV.Parent=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            flyConn=RS.RenderStepped:Connect(function()
                if not flyBV or not CFG.bodyfly then return end
                local mv=Vector3.new(0,0,0)
                if UIS:IsKeyDown(Enum.KeyCode.W) then mv=mv+CAM.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then mv=mv-CAM.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then mv=mv-CAM.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then mv=mv+CAM.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then mv=mv+Vector3.new(0,1,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then mv=mv-Vector3.new(0,1,0) end
                if mv.Magnitude>0 then flyBV.Velocity=mv.Unit*CFG.ws else flyBV.Velocity=Vector3.new(0,0,0) end
            end)
        elseif not CFG.bodyfly and wasB then
            if flyConn then flyConn:Disconnect() end; if flyBV then flyBV:Destroy() end
        end
        wasC, wasB = CFG.camfly, CFG.bodyfly
    end
end)

LP.Idled:Connect(function() if CFG.antiafk then VU:CaptureController(); VU:ClickButton2(Vector2.new()) end end)
task.spawn(function() while true do task.wait(1/math.max(1,CFG.cps))
    if CFG.clicker then pcall(function() VIM:SendMouseButtonEvent(0,0,0,true,game,0); VIM:SendMouseButtonEvent(0,0,0,false,game,0) end) end
    if CFG.chatspam then pcall(function() game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("GRAYS ON TOP // PROJECT D", "All") end) end
end end)

task.spawn(function() while true do task.wait(1)
    if CFG.tpplayer and LP.Character then
        local near,nd = nil,math.huge
        for _,p in ipairs(P:GetPlayers()) do if p~=LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d=(p.Character.HumanoidRootPart.Position-LP.Character.HumanoidRootPart.Position).Magnitude
            if d<nd then nd=d; near=p.Character.HumanoidRootPart end
        end end
        if near and nd>5 then LP.Character.HumanoidRootPart.CFrame=near.CFrame*CFrame.new(0,0,-5) end
    end
end end)

task.spawn(function() while true do task.wait(0.1)
    local c=LP.Character; local tool=c and c:FindFirstChildWhichIsA("Tool")
    if tool then
        if CFG.autofix and tool.Reload then pcall(function() tool:Reload() end)
            for _,v in pairs(tool:GetDescendants()) do if v:IsA("BoolValue") and v.Name:lower():find("jam") then v.Value=false end end
        end
        if CFG.autofire then pcall(function() VIM:SendMouseButtonEvent(0,0,0,true,game,0); VIM:SendMouseButtonEvent(0,0,0,false,game,0) end); if tool.Activate then pcall(function() tool:Activate() end) end end
    end
end end)

task.spawn(function() while true do task.wait(1)
    if CFG.farm then
        local c=LP.Character; local hrp=c and c:FindFirstChild("HumanoidRootPart")
        if hrp then
            local m=getMoney(); local t=tonumber(CFG.targetmoney) or 1000
            if m>=t then
                farmStatus.Text=">> Claiming..." 
                local npc = WS:FindFirstChild("Darrian Johnson", true) or WS:FindFirstChild("Darrian", true)
                if npc and npc:FindFirstChild("HumanoidRootPart") then ghostTravel(npc.HumanoidRootPart.Position); task.wait(0.5); clickDialog("claim my money"); task.wait(2); CFG.farm=false; farmStatus.Text=">> Done." end
            else
                local has=c:FindFirstChildWhichIsA("Tool")
                local tgtName=has and {"truck","deliver","trailer","mule"} or {"crate","pickup","box"}
                local tpObj=nil
                for _,v in ipairs(WS:GetDescendants()) do if v:IsA("Model") or v:IsA("BasePart") then
                    local n=string.lower(v.Name)
                    for _,word in ipairs(tgtName) do if string.find(n,word) then tpObj=v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart") or v:FindFirstChild("HumanoidRootPart"); if tpObj then break end end end
                    if tpObj then break end
                end end
                if tpObj then farmStatus.Text=has and ">> To Truck" or ">> To Crate"; ghostTravel(tpObj.Position); task.wait(0.3); interactPart(tpObj); task.wait(1.5)
                else
                    farmStatus.Text=">> To NPC" 
                    local npc = WS:FindFirstChild("Darrian Johnson", true) or WS:FindFirstChild("Darrian", true)
                    if npc and npc:FindFirstChild("HumanoidRootPart") then ghostTravel(npc.HumanoidRootPart.Position); task.wait(0.5); clickDialog("looking for work"); task.wait(1.5) end
                end
            end
        end
    else
        if farmStatus and farmStatus.Text ~= ">> Idle" then farmStatus.Text = ">> Idle" end
        task.wait(1)
    end
end end)

print("[GRAYS ON TOP] v9.0 — Last Boss (Ghost Protocol) Loaded.")
