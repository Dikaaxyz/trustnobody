-- GRAYS ON TOP — Xeno Light Edition
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
    noclip=false, speed=false, ws=16, jp=50,
    fly=false, flySpeed=60,
    farm=false, farmTool="Marshmallow Bag", farmPrompt="Craft", farmInt=0.6, farmDist=20,
    keyMenu=Enum.KeyCode.RightShift,
}

local gui = Instance.new("ScreenGui")
gui.Name="GOT"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=999999
gui.Parent=CG
getgenv().GOTGui=gui

local COL = {bg=Color3.fromRGB(8,8,8), panel=Color3.fromRGB(16,16,16), txt=Color3.fromRGB(232,232,232), acc=Color3.fromRGB(255,255,255), red=Color3.fromRGB(220,40,40)}

local main=Instance.new("Frame")
main.Size=UDim2.new(0,300,0,300)
main.Position=UDim2.new(0,40,0,40)
main.BackgroundColor3=COL.bg
main.BorderSizePixel=0
main.Active=true
main.Parent=gui

local wm=Instance.new("TextLabel")
wm.Size=UDim2.new(1,-24,0,30)
wm.Position=UDim2.new(0,16,0,12)
wm.BackgroundTransparency=1
wm.Text="GRAYS ON TOP"
wm.TextColor3=COL.txt
wm.Font=Enum.Font.GothamBlack
wm.TextSize=22
wm.TextXAlignment=Enum.TextXAlignment.Left
wm.Parent=main

local content=Instance.new("Frame")
content.Size=UDim2.new(1,0,1,-50)
content.Position=UDim2.new(0,0,0,50)
content.BackgroundColor3=COL.bg
content.Parent=main

local list=Instance.new("UIListLayout")
list.Padding=UDim.new(0,4)
list.Parent=content
local pad=Instance.new("UIPadding")
pad.PaddingLeft=UDim.new(0,10)
pad.PaddingRight=UDim.new(0,10)
pad.Parent=content

local function toggle(label,key)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,0,32)
    btn.BackgroundColor3=COL.panel
    btn.BorderSizePixel=0
    btn.Text="  "..label..": OFF"
    btn.TextColor3=COL.txt
    btn.Font=Enum.Font.GothamBold
    btn.TextSize=12
    btn.TextXAlignment=Enum.TextXAlignment.Left
    btn.Parent=content
    btn.MouseButton1Click:Connect(function()
        CFG[key]=not CFG[key]
        btn.Text="  "..label..": "..(CFG[key] and "ON" or "OFF")
        if CFG[key] then btn.TextColor3=COL.acc else btn.TextColor3=COL.txt end
    end)
end

local function slider(label,key,mn,mx)
    local h=Instance.new("Frame")
    h.Size=UDim2.new(1,0,0,40)
    h.BackgroundColor3=COL.panel
    h.Parent=content
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-10,0,20)
    lbl.Position=UDim2.new(0,5,0,5)
    lbl.BackgroundTransparency=1
    lbl.Text=label..": "..tostring(CFG[key])
    lbl.TextColor3=COL.txt
    lbl.TextSize=12
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.Parent=h
    local bar=Instance.new("Frame")
    bar.Size=UDim2.new(1,-20,0,4)
    bar.Position=UDim2.new(0,10,1,-10)
    bar.BackgroundColor3=COL.bg
    bar.Parent=h
    local dragging=false
    local bBtn=Instance.new("TextButton")
    bBtn.Size=UDim2.new(1,0,1,0)
    bBtn.BackgroundTransparency=1
    bBtn.Text=""
    bBtn.Parent=bar
    bBtn.MouseButton1Down:Connect(function() dragging=true end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)
    RS.RenderStepped:Connect(function()
        if not dragging then return end
        local aw=bar.AbsoluteSize.X
        if aw<=0 then return end
        local f=math.clamp((UIS:GetMouseLocation().X-bar.AbsolutePosition.X)/aw,0,1)
        CFG[key]=math.floor(mn+f*(mx-mn)+0.5)
        lbl.Text=label..": "..tostring(CFG[key])
    end)
end

toggle("Noclip","noclip")
toggle("Speed","speed")
slider("WalkSpeed","ws",16,150)
toggle("Fly","fly")
slider("Fly Speed","flySpeed",10,150)
toggle("Auto-Farm","farm")

-- MOBILE TOGGLE
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
if isMobile then
    local mBtn = Instance.new("TextButton")
    mBtn.Size = UDim2.new(0, 50, 0, 50)
    mBtn.Position = UDim2.new(0, 20, 0, 100)
    mBtn.BackgroundColor3 = COL.bg
    mBtn.BorderSizePixel = 0
    mBtn.Text = "X"
    mBtn.TextColor3 = COL.txt
    mBtn.Font = Enum.Font.GothamBlack
    mBtn.ZIndex = 100
    mBtn.Parent = gui
    local stroke = Instance.new("UIStroke")
    stroke.Color = COL.red
    stroke.Thickness = 2
    stroke.Parent = mBtn
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = mBtn
    mBtn.MouseButton1Click:Connect(function()
        main.Visible = not main.Visible
        mBtn.Text = main.Visible and "X" or "GOT"
    end)
end

UIS.InputBegan:Connect(function(i,pr)
    if pr then return end
    if i.KeyCode==CFG.keyMenu then
        main.Visible=not main.Visible
        if isMobile and mBtn then mBtn.Text = main.Visible and "X" or "GOT" end
    end
end)

-- ENGINE: NOCLIP / SPEED
RS.Stepped:Connect(function()
    local c=LP.Character
    if not c then return end
    if CFG.noclip then
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide=false end
        end
    end
    local hum=c:FindFirstChildOfClass("Humanoid")
    if hum then
        if CFG.speed then hum.WalkSpeed=CFG.ws end
        hum.JumpPower=CFG.jp
    end
end)

-- ENGINE: FLY
local flyBV, flyBG, flyConn
task.spawn(function()
    local was=false
    while true do
        task.wait(0.1)
        if CFG.fly and not was then
            local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                flyBV=Instance.new("BodyVelocity")
                flyBV.MaxForce=Vector3.new(1e5,1e5,1e5)
                flyBV.Parent=hrp
                flyConn=RS.RenderStepped:Connect(function()
                    local h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    if not h or not flyBV then return end
                    local mv=Vector3.new(0,0,0)
                    if UIS:IsKeyDown(Enum.KeyCode.W) then mv=mv+CAM.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then mv=mv-CAM.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.Space) then mv=mv+Vector3.new(0,1,0) end
                    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then mv=mv-Vector3.new(0,1,0) end
                    if mv.Magnitude>0 then flyBV.Velocity=mv.Unit*CFG.flySpeed else flyBV.Velocity=Vector3.new(0,0,0) end
                end)
            end
        elseif not CFG.fly and was then
            if flyConn then flyConn:Disconnect() flyConn=nil end
            if flyBV then flyBV:Destroy() flyBV=nil end
        end
        was=CFG.fly
    end
end)

-- ENGINE: FARM
task.spawn(function()
    while true do
        if CFG.farm then
            pcall(function()
                local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _,d in ipairs(WS:GetDescendants()) do
                        if d:IsA("ProximityPrompt") and d.Parent:IsA("BasePart") then
                            if (d.Parent.Position-hrp.Position).Magnitude<CFG.farmDist then
                                if d.ActionText==CFG.farmPrompt or d.Parent.Name:find(CFG.farmTool,1,true) then
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

print("[GRAYS ON TOP] Xeno-Light loaded.")
