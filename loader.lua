--[[
    SpookingD - Violence District
    v62.0 — Zero-Lag ESP + Absolute Parry/Skillcheck
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

local MasterEnabled = false

local CFG = {
    esp=false, esp_name=true, esp_health=true, esp_dist=true, esp_item=true,
    zombie_esp=true, 
    bright=false, fpsboost=false,
    crosshair=false, fov_enabled=false, fov_val=70,
    auto_parry=false, auto_skillcheck=false,
    parry_cooldown=0.1, -- Very fast cooldown
    ws_enabled=false, ws_speed=16,
    keyMenu=Enum.KeyCode.RightShift
}

local VD_ITEMS = {
    "Parrying Dagger","Flashlight","Bandage","Adrenaline Shot",
    "Motion Tracker","Shadow Clone","Gate","Twist of Fate",
    "WaxBound Candle","Holy Water","Riot Shield"
}
local VD_ITEM_LOOKUP = {}
for _, n in ipairs(VD_ITEMS) do VD_ITEM_LOOKUP[n:lower()] = n end

-- ==========================================
-- SAFE BYPASS (No file writes causing lag)
-- ==========================================
pcall(function()
    game:GetService("RbxAnalyticsService").GetHardwareIdentifier = function() return "SPOOK_991" end
end)

-- ==========================================
-- GUI
-- ==========================================
local COL = {
    bg=Color3.fromRGB(15,15,15), panel=Color3.fromRGB(25,25,25), sidebar=Color3.fromRGB(10,10,10),
    line=Color3.fromRGB(50,50,50), txt=Color3.fromRGB(255,255,255), dim=Color3.fromRGB(130,130,130),
    acc=Color3.fromRGB(255,0,60), off=Color3.fromRGB(60,60,60)
}

local gui = Instance.new("ScreenGui")
gui.Name="SG_"..tostring(math.random(100000,999999))
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=999999
gui.Parent = LP:WaitForChild("PlayerGui")
getgenv().TGui=gui

local main = Instance.new("Frame")
main.Size=UDim2.new(0,600,0,420); main.Position=UDim2.new(0.5,-300,0.5,-210)
main.BackgroundColor3=COL.bg; main.BorderSizePixel=0; main.Active=true; main.Parent=gui

local ms = Instance.new("UIStroke")
ms.Color=COL.acc; ms.Thickness=1; ms.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; ms.Parent=main

local sidebar = Instance.new("Frame")
sidebar.Size=UDim2.new(0,130,1,0); sidebar.BackgroundColor3=COL.sidebar
sidebar.BorderSizePixel=0; sidebar.Parent=main

local logo = Instance.new("TextLabel")
logo.Size=UDim2.new(1,0,0,50); logo.BackgroundTransparency=1
logo.Text="SpookingD"; logo.TextColor3=COL.acc; logo.Font=Enum.Font.GothamBlack
logo.TextSize=22; logo.Parent=sidebar

local masterBtn = Instance.new("TextButton")
masterBtn.Size=UDim2.new(1,-20,0,30); masterBtn.Position=UDim2.new(0,10,0,55)
masterBtn.BackgroundColor3=COL.panel; masterBtn.BorderSizePixel=0
masterBtn.Text="ENABLE SCRIPT"; masterBtn.TextColor3=COL.dim
masterBtn.Font=Enum.Font.GothamBold; masterBtn.TextSize=10; masterBtn.Parent=sidebar

local masterStroke = Instance.new("UIStroke")
masterStroke.Color=COL.line; masterStroke.Thickness=1; masterStroke.Parent=masterBtn

local hiddenFolder
local function getHiddenFolder()
    if hiddenFolder and hiddenFolder.Parent then return hiddenFolder end
    hiddenFolder = Instance.new("Folder")
    hiddenFolder.Name = "\0SpookCarrier"
    hiddenFolder.Parent = CAM or WS
    return hiddenFolder
end

local espData = {}
local toolCache = {}

local function destroyEspEntry(p)
    local d = espData[p]
    if not d then return end
    if d.hl then d.hl:Destroy() end
    if d.bg then d.bg:Destroy() end
    espData[p] = nil
end

local function fullTeardown()
    for p in pairs(espData) do destroyEspEntry(p) end
    if hiddenFolder then hiddenFolder:Destroy(); hiddenFolder = nil end
end

masterBtn.MouseButton1Click:Connect(function()
    MasterEnabled = not MasterEnabled
    if MasterEnabled then
        masterBtn.Text="SCRIPT: ON"; masterBtn.TextColor3=COL.acc; masterStroke.Color=COL.acc
    else
        masterBtn.Text="ENABLE SCRIPT"; masterBtn.TextColor3=COL.dim; masterStroke.Color=COL.line
        fullTeardown()
    end
end)

local sideTabs, sidePages = {}, {}
local function addSideTab(name)
    local btn = Instance.new("TextButton")
    btn.Size=UDim2.new(1,-20,0,30); btn.Position=UDim2.new(0,10,0,90+(#sideTabs*32))
    btn.BackgroundColor3=COL.sidebar; btn.BorderSizePixel=0
    btn.Text="  "..name; btn.TextColor3=COL.dim; btn.Font=Enum.Font.GothamBold
    btn.TextSize=11; btn.TextXAlignment=Enum.TextXAlignment.Left
    btn.AutoButtonColor=false; btn.Parent=sidebar
    table.insert(sideTabs, btn)
    local pg=Instance.new("Frame")
    pg.Size=UDim2.new(1,-130,1,0); pg.Position=UDim2.new(0,130,0,0)
    pg.BackgroundTransparency=1; pg.Visible=false; pg.Parent=main
    table.insert(sidePages, pg)
    local idx=#sideTabs
    btn.MouseButton1Click:Connect(function()
        for i,t in ipairs(sideTabs) do
            t.TextColor3=(i==idx) and COL.txt or COL.dim
            t.BackgroundColor3=(i==idx) and COL.panel or COL.sidebar
        end
        for i,p in ipairs(sidePages) do p.Visible=(i==idx) end
    end)
    return pg
end

local function createBox(parent,title,x,y,w,h)
    local box=Instance.new("Frame")
    box.Size=UDim2.new(0,w,0,h); box.Position=UDim2.new(0,x,0,y)
    box.BackgroundColor3=COL.panel; box.BorderSizePixel=0; box.Parent=parent
    local bs=Instance.new("UIStroke"); bs.Color=COL.line; bs.Thickness=1; bs.Parent=box
    local header=Instance.new("Frame")
    header.Size=UDim2.new(1,0,0,24); header.BackgroundColor3=COL.sidebar
    header.BorderSizePixel=0; header.Parent=box
    local tl=Instance.new("TextLabel")
    tl.Size=UDim2.new(1,-10,1,0); tl.Position=UDim2.new(0,10,0,0)
    tl.BackgroundTransparency=1; tl.Text=title; tl.TextColor3=COL.txt
    tl.Font=Enum.Font.GothamBold; tl.TextSize=11
    tl.TextXAlignment=Enum.TextXAlignment.Left; tl.Parent=header
    return box
end

local function addSwitch(parent,label,key,yOffset)
    local row=Instance.new("TextButton")
    row.Size=UDim2.new(1,-10,0,28); row.Position=UDim2.new(0,5,0,yOffset)
    row.BackgroundTransparency=1; row.Text=""; row.ZIndex=2; row.Parent=parent
    local txt=Instance.new("TextLabel")
    txt.Size=UDim2.new(1,-60,1,0); txt.BackgroundTransparency=1
    txt.Text=label; txt.TextColor3=COL.txt; txt.Font=Enum.Font.Gotham
    txt.TextSize=11; txt.TextXAlignment=Enum.TextXAlignment.Left; txt.ZIndex=2; txt.Parent=row
    local pill=Instance.new("Frame")
    pill.Size=UDim2.new(0,36,0,18); pill.Position=UDim2.new(1,-36,0.5,-9)
    pill.BackgroundColor3=CFG[key] and COL.acc or COL.off; pill.ZIndex=2; pill.Parent=row
    local pc=Instance.new("UICorner"); pc.CornerRadius=UDim.new(1,0); pc.Parent=pill
    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,12,0,12)
    knob.Position=CFG[key] and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.ZIndex=3; knob.Parent=pill
    local kc=Instance.new("UICorner"); kc.CornerRadius=UDim.new(1,0); kc.Parent=knob
    row.MouseButton1Click:Connect(function()
        if not MasterEnabled then return end
        CFG[key]=not CFG[key]
        pill.BackgroundColor3=CFG[key] and COL.acc or COL.off
        knob.Position=CFG[key] and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6)
    end)
end

local function addButton(parent,label,cb,yOffset)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,-10,0,24); btn.Position=UDim2.new(0,5,0,yOffset)
    btn.BackgroundColor3=COL.bg; btn.BorderSizePixel=0
    btn.Text=label; btn.TextColor3=COL.txt; btn.Font=Enum.Font.GothamBold
    btn.TextSize=11; btn.Parent=parent
    local bs=Instance.new("UIStroke"); bs.Color=COL.line; bs.Thickness=1; bs.Parent=btn
    btn.MouseButton1Click:Connect(function() if MasterEnabled then pcall(cb) end end)
end

local pgVisual   = addSideTab("Visuals")
local pgWorld    = addSideTab("World")
local pgSurvivor = addSideTab("Survivor")

local boxESP = createBox(pgVisual, "Player ESP", 10, 10, 440, 220)
addSwitch(boxESP, "Enable ESP", "esp", 30)
addSwitch(boxESP, "Show Name", "esp_name", 60)
addSwitch(boxESP, "Show Health", "esp_health", 90)
addSwitch(boxESP, "Show Distance", "esp_dist", 120)
addSwitch(boxESP, "Show Item", "esp_item", 150)
addSwitch(boxESP, "Zombie ESP (SCP)", "zombie_esp", 180)

local boxSafe = createBox(pgSurvivor, "Survivor Utility", 10, 10, 440, 120)
addSwitch(boxSafe, "Auto Parry (Spam Mode)", "auto_parry", 30)
addSwitch(boxSafe, "Auto Skillcheck (Spam Mode)", "auto_skillcheck", 60)

sideTabs[1].TextColor3=COL.txt; sideTabs[1].BackgroundColor3=COL.panel; sidePages[1].Visible=true

local closeBtn=Instance.new("TextButton")
closeBtn.Size=UDim2.new(0,20,0,20); closeBtn.Position=UDim2.new(1,-25,0,5)
closeBtn.BackgroundTransparency=1; closeBtn.Text="×"; closeBtn.TextColor3=COL.txt
closeBtn.Font=Enum.Font.GothamBold; closeBtn.TextSize=16; closeBtn.Parent=main

local openBtn=Instance.new("TextButton")
openBtn.Size=UDim2.new(0,40,0,40); openBtn.Position=UDim2.new(0,20,0,100)
openBtn.BackgroundColor3=COL.bg; openBtn.BorderSizePixel=2; openBtn.BorderColor3=COL.acc
openBtn.Text="S"; openBtn.TextColor3=COL.acc; openBtn.Font=Enum.Font.GothamBlack
openBtn.TextSize=22; openBtn.Parent=gui; openBtn.Visible=false

closeBtn.MouseButton1Click:Connect(function() main.Visible=false; openBtn.Visible=true end)
openBtn.MouseButton1Click:Connect(function() main.Visible=true; openBtn.Visible=false end)
UIS.InputBegan:Connect(function(i,pr)
    if pr then return end
    if i.KeyCode == CFG.keyMenu then
        main.Visible = not main.Visible; openBtn.Visible = not main.Visible
    end
end)

-- ==========================================
-- ESP ENGINE (Zero-Lag Data Caching)
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

local function getSurvivorItem(p)
    local char=p.Character; if not char then return nil end
    local tool=char:FindFirstChildWhichIsA("Tool")
    local cached=toolCache[p]
    if tool and cached and cached.tool==tool then return cached.name end
    if tool then
        local low=tool.Name:lower()
        for k,orig in pairs(VD_ITEM_LOOKUP) do
            if low:find(k,1,true) then
                toolCache[p]={tool=tool,name=orig}
                return orig
            end
        end
    end
    toolCache[p]=nil; return nil
end

local function buildEspEntry(key, adorneeObj, hrp, color, nameStr)
    local carrier = getHiddenFolder()
    
    local hl = Instance.new("Highlight")
    hl.FillColor = color
    hl.OutlineColor = color
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = adorneeObj
    hl.Parent = carrier

    local bg = Instance.new("BillboardGui")
    bg.Name = "Spook_ESP"
    bg.Adornee = hrp
    bg.Size = UDim2.new(0, 150, 0, 45)
    bg.StudsOffset = Vector3.new(0, 3.2, 0)
    bg.AlwaysOnTop = true
    bg.Parent = carrier

    local function label(y, sz, col, font)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, sz)
        l.Position = UDim2.new(0, 0, 0, y)
        l.BackgroundTransparency = 1
        l.TextColor3 = col
        l.TextStrokeTransparency = 0
        l.Font = font
        l.TextSize = sz
        l.Parent = bg
        return l
    end

    local nameLbl = label(0, 14, color, Enum.Font.GothamBold)
    nameLbl.Text = nameStr

    local hpBg = Instance.new("Frame")
    hpBg.Size = UDim2.new(0.6, 0, 0, 4)
    hpBg.Position = UDim2.new(0.2, 0, 0, 16)
    hpBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    hpBg.BorderSizePixel = 0
    hpBg.Parent = bg

    local hpFill = Instance.new("Frame")
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    hpFill.BorderSizePixel = 0
    hpFill.Parent = hpBg

    local itemLbl = label(22, 12, Color3.fromRGB(0, 255, 255), Enum.Font.GothamBold)
    local distLbl = label(34, 12, Color3.fromRGB(200, 200, 200), Enum.Font.Gotham)

    espData[key] = { hl = hl, bg = bg, name = nameLbl, item = itemLbl, dist = distLbl, hp = hpFill, hpBg = hpBg }
end

task.spawn(function()
    while true do
        task.wait(0.5) -- Refresh rate
        if MasterEnabled and CFG.esp then
            pcall(function()
                local myChar = LP.Character
                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                
                for _, p in ipairs(P:GetPlayers()) do
                    if p ~= LP then
                        local char = p.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        
                        local d = espData[p]
                        
                        if hrp and hum and hum.Health > 0 then
                            if not d or not d.hl or not d.hl.Parent or not d.bg or not d.bg.Parent then
                                destroyEspEntry(p)
                                buildEspEntry(p, char, hrp, Color3.new(1,1,1), p.Name)
                                d = espData[p]
                            end
                            
                            local killer = isKillerSafe(p)
                            local color = killer and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 255)
                            
                            if d.lastColor ~= color then
                                d.hl.FillColor = color
                                d.hl.OutlineColor = color
                                d.name.TextColor3 = color
                                d.lastColor = color
                            end
                            
                            d.hl.Adornee = char
                            
                            local itemName = (not killer and CFG.esp_item) and getSurvivorItem(p) or nil
                            if itemName then
                                d.item.Text = "[" .. itemName .. "]"
                                d.item.Visible = true
                            else
                                d.item.Visible = false
                            end
                            
                            if CFG.esp_health then
                                local hPct = hum.Health / hum.MaxHealth
                                d.hpBg.Visible = true
                                d.hp.Size = UDim2.new(hPct, 0, 1, 0)
                                d.hp.BackgroundColor3 = hPct > 0.5 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                            else
                                d.hpBg.Visible = false
                            end
                            
                            if myHrp then
                                local dist = math.floor((hrp.Position - myHrp.Position).Magnitude)
                                d.dist.Text = "[" .. dist .. "m]"
                                d.dist.Visible = CFG.esp_dist
                            else
                                d.dist.Visible = false
                            end
                        else
                            destroyEspEntry(p)
                        end
                    end
                end
            end)
        else
            for k in pairs(espData) do destroyEspEntry(k) end
        end
    end
end)

P.PlayerRemoving:Connect(function(p) destroyEspEntry(p); toolCache[p] = nil end)

-- ==========================================
-- AUTO PARRY (Spam Proximity)
-- ==========================================
local PARRY_MOUSE_BUTTON=2
local lastParryTime=0

task.spawn(function()
    while true do
        task.wait(0.05)
        if MasterEnabled and CFG.auto_parry then
            local myChar = LP.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myHrp then
                local shouldParry = false
                for _, p in ipairs(P:GetPlayers()) do
                    if p ~= LP and isKillerSafe(p) then
                        local char = p.Character
                        if char then
                            local tHrp = char:FindFirstChild("HumanoidRootPart")
                            if tHrp then
                                local dist = (tHrp.Position - myHrp.Position).Magnitude
                                -- If killer is within 15 studs, click parry
                                if dist < 15 then
                                    shouldParry = true
                                    break
                                end
                            end
                        end
                    end
                end
                
                if shouldParry and tick() - lastParryTime > CFG.parry_cooldown then
                    lastParryTime = tick()
                    pcall(function()
                        VIM:SendMouseButtonEvent(0,0,PARRY_MOUSE_BUTTON,true,game,1)
                        task.wait(0.01)
                        VIM:SendMouseButtonEvent(0,0,PARRY_MOUSE_BUTTON,false,game,1)
                    end)
                end
            end
        end
    end
end)

-- ==========================================
-- AUTO SKILLCHECK (Spam Space)
-- ==========================================
local lastSkillCheck=0
task.spawn(function()
    while true do
        task.wait(0.05)
        if MasterEnabled and CFG.auto_skillcheck then
            if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                if tick() - lastSkillCheck > 0.1 then
                    lastSkillCheck = tick()
                    pcall(function()
                        VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                        task.wait(0.01)
                        VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                    end)
                end
            end
        end
    end
end)

print("[SpookingD] v62.0 loaded — Zero-Lag Active. Let's ride.")
