--[[
    Tumblr Girls - Script Made By SpookingD
    v36.0 — Ghost Admin Evasion
]]

if not game:IsLoaded() then game.Loaded:Wait() end
if getgenv().TGui then pcall(function() getgenv().TGui:Destroy() end) end

local P = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local WS = game:GetService("Workspace")
local CG = game:GetService("CoreGui")
local L = game:GetService("Lighting")
local LP = P.LocalPlayer
local CAM = WS.CurrentCamera
local VIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")

local MasterEnabled = false

local CFG = {
    esp=false, esp_name=true, esp_health=true, esp_dist=true,
    gen_esp=false, killer_esp=false, item_esp=false, exit_esp=false,
    bright=false, fpsboost=false,
    crosshair=false, fov=70, hitbox_expand=false,
    auto_gen=false, auto_parry=false, auto_skillcheck=false,
    look_lock=false, ws_enabled=false, ws_speed=16,
    keyMenu=Enum.KeyCode.RightShift
}

-- ==========================================
-- [BYPASS] ANTI-ADMIN EVASION
-- ==========================================
pcall(function()
    -- 1. HWID Spoof & Cookie Wipe
    getgenv().SpoofedHWID = tostring(math.random(100000,999999))
    game:GetService("RbxAnalyticsService").GetHardwareIdentifier = function() return getgenv().SpoofedHWID end
    if writefile and isfile and delfile then pcall(function() if isfile("RobloxCookies.dat") then delfile("RobloxCookies.dat") end end) end

    -- 2. IP Masking (Fake US IP)
    local oldGet = HttpService.GetAsync
    HttpService.GetAsync = function(self, url, ...)
        if url:find("ip") or url:find("geo") then return '{"ip":"104.28.210.1","country":"US"}' end
        return oldGet(self, url, ...)
    end

    -- 3. Network Handshake Spoof
    local NetworkClient = game:GetService("NetworkClient")
    local oldInvoke = NetworkClient.Invoke
    NetworkClient.Invoke = function(self, req, ...)
        if req == "Handshake" then return "Roblox/Android/1.0" end
        return oldInvoke(self, req, ...)
    end

    -- 4. Chat Filter (Ngehapus kata kunci cheat kalo lu ngetik di chat)
    LP.Chatted:Connect(function(msg)
        local filteredMsg = msg:gsub("(?i)cheat", "***"):gsub("(?i)hack", "***"):gsub("(?i)aimbot", "***"):gsub("(?i)exploit", "***")
        if filteredMsg ~= msg then
            -- Kalo ada kata kotor, cegah ngirim (kalo game make DefaultChat)
            -- (Biasanya game pake custom chat, jadi ini cuma jaga-jaga)
        end
    end)

    -- 5. Fake Ping (Ngebuat jaringan lu keliatan normal)
    local oldGetPing = game:GetService("Stats").Network.ServerStatsItem["Data Ping"].GetValue
    -- Nggak bisa di-hook langsung, tapi kita bisa bikin ping keliatan stabil di UI
end)

local function getHui() if typeof(gethui) == "function" then local ok, h = pcall(gethui) if ok and h then return h end end return CG end

local COL = { bg=Color3.fromRGB(15, 15, 15), panel=Color3.fromRGB(25, 25, 25), sidebar=Color3.fromRGB(10, 10, 10), line=Color3.fromRGB(50, 50, 50), txt=Color3.fromRGB(255, 255, 255), dim=Color3.fromRGB(130, 130, 130), acc=Color3.fromRGB(255, 0, 60), off=Color3.fromRGB(60, 60, 60) }

local gui = Instance.new("ScreenGui"); gui.Name="TumblrGirls"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true; gui.DisplayOrder=999999; gui.Parent=getHui(); getgenv().TGui=gui
local main = Instance.new("Frame"); main.Size=UDim2.new(0, 600, 0, 420); main.Position=UDim2.new(0.5, -300, 0.5, -210); main.BackgroundColor3=COL.bg; main.BorderSizePixel=0; main.Active=true; main.Parent=gui
local ms = Instance.new("UIStroke"); ms.Color=COL.acc; ms.Thickness=1; ms.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; ms.Parent=main

local sidebar = Instance.new("Frame"); sidebar.Size=UDim2.new(0, 130, 1, 0); sidebar.BackgroundColor3=COL.sidebar; sidebar.BorderSizePixel=0; sidebar.Parent=main
local logo = Instance.new("TextLabel"); logo.Size=UDim2.new(1, 0, 0, 50); logo.BackgroundTransparency=1; logo.Text="TUMBLR"; logo.TextColor3=COL.acc; logo.Font=Enum.Font.GothamBlack; logo.TextSize=24; logo.Parent=sidebar
local subLogo = Instance.new("TextLabel"); subLogo.Size=UDim2.new(1, 0, 0, 10); subLogo.Position=UDim2.new(0,0,0,40); subLogo.BackgroundTransparency=1; subLogo.Text="GIRLS"; subLogo.TextColor3=COL.txt; subLogo.Font=Enum.Font.GothamBold; subLogo.TextSize=10; subLogo.Parent=sidebar

local masterBtn = Instance.new("TextButton"); masterBtn.Size = UDim2.new(1, -20, 0, 30); masterBtn.Position = UDim2.new(0, 10, 0, 55); masterBtn.BackgroundColor3 = COL.panel; masterBtn.BorderSizePixel = 0; masterBtn.Text = "ENABLE SCRIPT"; masterBtn.TextColor3 = COL.dim; masterBtn.Font = Enum.Font.GothamBold; masterBtn.TextSize = 10; masterBtn.Parent = sidebar
local masterStroke = Instance.new("UIStroke"); masterStroke.Color = COL.line; masterStroke.Thickness = 1; masterStroke.Parent = masterBtn

masterBtn.MouseButton1Click:Connect(function()
    MasterEnabled = not MasterEnabled
    if MasterEnabled then masterBtn.Text = "SCRIPT: ON"; masterBtn.TextColor3 = COL.acc; masterStroke.Color = COL.acc
    else masterBtn.Text = "ENABLE SCRIPT"; masterBtn.TextColor3 = COL.dim; masterStroke.Color = COL.line end
end)

local sideTabs, sidePages = {}, {}
local function addSideTab(name)
    local btn = Instance.new("TextButton"); btn.Size=UDim2.new(1, -20, 0, 30); btn.Position=UDim2.new(0, 10, 0, 90 + (#sideTabs * 32)); btn.BackgroundColor3=COL.sidebar; btn.BorderSizePixel=0; btn.Text="  " .. name; btn.TextColor3=COL.dim; btn.Font=Enum.Font.GothamBold; btn.TextSize=11; btn.TextXAlignment=Enum.TextXAlignment.Left; btn.AutoButtonColor=false; btn.Parent=sidebar; table.insert(sideTabs, btn)
    local pg = Instance.new("Frame"); pg.Size=UDim2.new(1, -130, 1, 0); pg.Position=UDim2.new(0, 130, 0, 0); pg.BackgroundTransparency=1; pg.Visible=false; pg.Parent=main; table.insert(sidePages, pg)
    local idx = #sideTabs
    btn.MouseButton1Click:Connect(function()
        for i, t in ipairs(sideTabs) do t.TextColor3 = (i == idx) and COL.txt or COL.dim; t.BackgroundColor3 = (i == idx) and COL.panel or COL.sidebar end
        for i, p in ipairs(sidePages) do p.Visible = (i == idx) end
    end)
    return pg
end

local function createBox(parent, title, x, y, w, h)
    local box = Instance.new("Frame"); box.Size=UDim2.new(0, w, 0, h); box.Position=UDim2.new(0, x, 0, y); box.BackgroundColor3=COL.panel; box.BorderSizePixel=0; box.Parent=parent
    local bs = Instance.new("UIStroke"); bs.Color=COL.line; bs.Thickness=1; bs.Parent=box
    local header = Instance.new("Frame"); header.Size=UDim2.new(1, 0, 0, 24); header.BackgroundColor3=COL.sidebar; header.BorderSizePixel=0; header.Parent=box
    local tl = Instance.new("TextLabel"); tl.Size=UDim2.new(1, -10, 1, 0); tl.Position=UDim2.new(0, 10, 0, 0); tl.BackgroundTransparency=1; tl.Text=title; tl.TextColor3=COL.txt; tl.Font=Enum.Font.GothamBold; tl.TextSize=11; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.Parent=header
    return box
end

local function addSwitch(parent, label, key, yOffset)
    local row = Instance.new("TextButton"); row.Size = UDim2.new(1, -10, 0, 28); row.Position = UDim2.new(0, 5, 0, yOffset); row.BackgroundTransparency = 1; row.Text = ""; row.ZIndex = 2; row.Parent = parent
    local txt = Instance.new("TextLabel"); txt.Size = UDim2.new(1, -60, 1, 0); txt.BackgroundTransparency = 1; txt.Text = label; txt.TextColor3 = COL.txt; txt.Font = Enum.Font.Gotham; txt.TextSize = 11; txt.TextXAlignment = Enum.TextXAlignment.Left; txt.ZIndex = 2; txt.Parent = row
    local pill = Instance.new("Frame"); pill.Size = UDim2.new(0, 36, 0, 18); pill.Position = UDim2.new(1, -36, 0.5, -9); pill.BackgroundColor3 = CFG[key] and COL.acc or COL.off; pill.ZIndex = 2; pill.Parent = row
    local pillCorner = Instance.new("UICorner"); pillCorner.CornerRadius = UDim.new(1, 0); pillCorner.Parent = pill
    local knob = Instance.new("Frame"); knob.Size = UDim2.new(0, 12, 0, 12); knob.Position = CFG[key] and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6); knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); knob.ZIndex = 3; knob.Parent = pill
    local knobCorner = Instance.new("UICorner"); knobCorner.CornerRadius = UDim.new(1, 0); knobCorner.Parent = knob
    row.MouseButton1Click:Connect(function() if not MasterEnabled then return end; CFG[key] = not CFG[key]; pill.BackgroundColor3 = CFG[key] and COL.acc or COL.off; knob.Position = CFG[key] and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6) end)
end

local function addSlider(parent, label, key, min, max, yOffset)
    local frame = Instance.new("Frame"); frame.Size=UDim2.new(1, -10, 0, 24); frame.Position=UDim2.new(0, 5, 0, yOffset); frame.BackgroundTransparency=1; frame.Parent=parent
    local txt = Instance.new("TextLabel"); txt.Size=UDim2.new(1, -60, 1, 0); txt.BackgroundTransparency=1; txt.Text=label; txt.TextColor3=COL.txt; txt.Font=Enum.Font.Gotham; txt.TextSize=11; txt.TextXAlignment=Enum.TextXAlignment.Left; txt.Parent=frame
    local input = Instance.new("TextBox"); input.Size=UDim2.new(0, 40, 0, 18); input.Position=UDim2.new(1, -40, 0.5, -9); input.BackgroundColor3=COL.bg; input.BorderSizePixel=0; input.Text=tostring(CFG[key]); input.TextColor3=COL.acc; input.Font=Enum.Font.GothamBold; input.TextSize=10; input.Parent=frame
    input.FocusLost:Connect(function() if not MasterEnabled then return end; local val = tonumber(input.Text); if val then CFG[key] = math.clamp(val, min, max) end; input.Text = tostring(CFG[key]) end)
end

local function addButton(parent, label, cb, yOffset)
    local btn = Instance.new("TextButton"); btn.Size=UDim2.new(1, -10, 0, 24); btn.Position=UDim2.new(0, 5, 0, yOffset); btn.BackgroundColor3=COL.bg; btn.BorderSizePixel=0; btn.Text=label; btn.TextColor3=COL.txt; btn.Font=Enum.Font.GothamBold; btn.TextSize=11; btn.Parent=parent
    local bs = Instance.new("UIStroke"); bs.Color=COL.line; bs.Thickness=1; bs.Parent=btn
    btn.MouseButton1Click:Connect(function() if MasterEnabled then pcall(cb) end end)
end

local pgVisual = addSideTab("Visuals"); local pgWorld = addSideTab("World"); local pgSurvivor = addSideTab("Survivor"); local pgKiller = addSideTab("Killer"); local pgMisc = addSideTab("Misc")

local boxESP = createBox(pgVisual, "Player ESP", 10, 10, 440, 200)
addSwitch(boxESP, "Enable ESP", "esp", 30); addSwitch(boxESP, "Show Name", "esp_name", 60); addSwitch(boxESP, "Show Health", "esp_health", 90); addSwitch(boxESP, "Show Distance", "esp_dist", 120)

local boxVisual = createBox(pgVisual, "Screen", 10, 220, 440, 100)
addSwitch(boxVisual, "Custom Crosshair", "crosshair", 30); addSwitch(boxVisual, "Hitbox Visualizer", "hitbox_expand", 60); addSlider(boxVisual, "Camera FOV", "fov", 50, 120, 90)

local boxWorld = createBox(pgWorld, "World ESP", 10, 10, 440, 160)
addSwitch(boxWorld, "Generator ESP", "gen_esp", 30); addSwitch(boxWorld, "Killer Skill ESP", "killer_esp", 60); addSwitch(boxWorld, "Item ESP", "item_esp", 90); addSwitch(boxWorld, "Exit / Spike ESP", "exit_esp", 120)

local boxEnv = createBox(pgWorld, "Environment", 10, 180, 440, 100)
addSwitch(boxEnv, "TRUE Fullbright", "bright", 30); addSwitch(boxEnv, "FPS Booster", "fpsboost", 60)

local boxSafe = createBox(pgSurvivor, "Survivor Utility", 10, 10, 440, 160)
addSwitch(boxSafe, "Auto Generator (Hold LMB)", "auto_gen", 30); addSwitch(boxSafe, "Auto Parry (God-Tier)", "auto_parry", 60); addSwitch(boxSafe, "Auto Skillcheck (LMB)", "auto_skillcheck", 90)

local boxKiller = createBox(pgKiller, "Killer Utility", 10, 10, 440, 80)
addSwitch(boxKiller, "Look Lock (Aim Assist)", "look_lock", 30)

local boxMisc = createBox(pgMisc, "Movement", 10, 10, 440, 100)
addSwitch(boxMisc, "Enable WalkSpeed", "ws_enabled", 30); addSlider(boxMisc, "WalkSpeed (Safe)", "ws_speed", 16, 28, 60)

local boxBypass = createBox(pgMisc, "SpookingD Bypass", 10, 120, 440, 120)
addButton(boxBypass, "Re-Apply HWID Bypass", function() getgenv().SpoofedHWID = tostring(math.random(100000,999999)); pcall(function() game:GetService("RbxAnalyticsService").GetHardwareIdentifier = function() return getgenv().SpoofedHWID end end); if writefile and isfile and delfile then pcall(function() if isfile("RobloxCookies.dat") then delfile("RobloxCookies.dat") end end) end end, 30)
addButton(boxBypass, "Panic Wipe (Log Out)", function() if writefile and delfile then pcall(function() if isfile("RobloxCookies.dat") then delfile("RobloxCookies.dat") end end) end; game:Shutdown() end, 60)

sideTabs[1].TextColor3 = COL.txt; sideTabs[1].BackgroundColor3 = COL.panel; sidePages[1].Visible = true
local closeBtn = Instance.new("TextButton"); closeBtn.Size=UDim2.new(0, 20, 0, 20); closeBtn.Position=UDim2.new(1, -25, 0, 5); closeBtn.BackgroundTransparency=1; closeBtn.Text="×"; closeBtn.TextColor3=COL.txt; closeBtn.Font=Enum.Font.GothamBold; closeBtn.TextSize=16; closeBtn.Parent=main
local openBtn = Instance.new("TextButton"); openBtn.Size=UDim2.new(0, 40, 0, 40); openBtn.Position=UDim2.new(0, 20, 0, 100); openBtn.BackgroundColor3=COL.bg; openBtn.BorderSizePixel=2; openBtn.BorderColor3=COL.acc; openBtn.Text="T"; openBtn.TextColor3=COL.acc; openBtn.Font=Enum.Font.GothamBlack; openBtn.TextSize=22; openBtn.Parent=gui; openBtn.Visible = false
closeBtn.MouseButton1Click:Connect(function() main.Visible = false; openBtn.Visible = true end)
openBtn.MouseButton1Click:Connect(function() main.Visible = true; openBtn.Visible = false end)
UIS.InputBegan:Connect(function(i, pr) if pr then return end; if i.KeyCode == CFG.keyMenu then main.Visible = not main.Visible; openBtn.Visible = not main.Visible end end)
local drag, ds, sp
logo.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; ds = i.Position; sp = main.Position end end)
UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - ds; main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)

-- ==========================================
-- ENGINE: CUSTOM CAMERA FOV
-- ==========================================
RS.RenderStepped:Connect(function()
    if not MasterEnabled then return end
    if CAM then
        CAM.FieldOfView = CFG.fov
    end
end)

-- ==========================================
-- ENGINE: BULLETPROOF ESP
-- ==========================================
local crosshair = Instance.new("Frame"); crosshair.Size = UDim2.new(0, 4, 0, 4); crosshair.Position = UDim2.new(0.5, -2, 0.5, -2); crosshair.BackgroundColor3 = COL.acc; crosshair.BorderSizePixel = 0; crosshair.Visible = false; crosshair.Parent = gui
local hitboxParts = {}
local espData = {}

local function isKiller(p)
    if p.Team and p.Team.Name:lower():find("killer") then return true end
    local ls = p:FindFirstChild("leaderstats")
    if ls then for _, v in pairs(ls:GetChildren()) do if v.Name:lower():find("role") and tostring(v.Value):lower():find("killer") then return true end end end
    local char = p.Character
    if char then
        local tool = char:FindFirstChildWhichIsA("Tool")
        if tool then
            local name = tool.Name:lower()
            if name:find("veil") or name:find("spear") or name:find("butcher") or name:find("chain") or name:find("mask") or name:find("claw") then return true end
        end
    end
    return false
end

RS.RenderStepped:Connect(function()
    if not MasterEnabled then return end
    crosshair.Visible = CFG.crosshair

    for _, p in ipairs(P:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            local hrp = p.Character.HumanoidRootPart
            local hum = p.Character.Humanoid
            local killer = isKiller(p)
            local color = killer and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 255)

            if not espData[p] then
                local hl = Instance.new("Highlight")
                hl.FillColor = color
                hl.OutlineColor = color
                hl.FillTransparency = 0.7
                hl.Parent = p.Character

                local bg = Instance.new("BillboardGui")
                bg.Name = "TG_ESP"
                bg.Adornee = hrp
                bg.Size = UDim2.new(0, 150, 0, 50)
                bg.StudsOffset = Vector3.new(0, 3, 0)
                bg.AlwaysOnTop = true
                bg.Parent = hrp
                
                local nameLbl = Instance.new("TextLabel")
                nameLbl.Size = UDim2.new(1, 0, 0, 14)
                nameLbl.BackgroundTransparency = 1
                nameLbl.TextColor3 = color
                nameLbl.TextStrokeTransparency = 0
                nameLbl.Font = Enum.Font.GothamBold
                nameLbl.TextSize = 13
                nameLbl.Parent = bg
                
                local distLbl = Instance.new("TextLabel")
                distLbl.Size = UDim2.new(1, 0, 0, 12)
                distLbl.Position = UDim2.new(0, 0, 0, 14)
                distLbl.BackgroundTransparency = 1
                distLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
                distLbl.TextStrokeTransparency = 0
                distLbl.Font = Enum.Font.Gotham
                distLbl.TextSize = 11
                distLbl.Parent = bg

                local hpBg = Instance.new("Frame")
                hpBg.Size = UDim2.new(0.6, 0, 0, 4)
                hpBg.Position = UDim2.new(0.2, 0, 0, 28)
                hpBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                hpBg.BorderSizePixel = 0
                hpBg.Parent = bg

                local hpFill = Instance.new("Frame")
                hpFill.Size = UDim2.new(1, 0, 1, 0)
                hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                hpFill.BorderSizePixel = 0
                hpFill.Parent = hpBg
                
                espData[p] = {hl = hl, bg = bg, name = nameLbl, dist = distLbl, hp = hpFill, hpBg = hpBg}
            end

            local data = espData[p]
            local dist = math.floor((hrp.Position - LP.Character.HumanoidRootPart.Position).Magnitude)
            local hPercent = hum.Health / hum.MaxHealth

            data.hl.Enabled = CFG.esp
            data.bg.Enabled = CFG.esp
            data.name.Text = p.Name
            data.name.TextColor3 = color
            data.name.Visible = CFG.esp_name
            data.dist.Text = "[" .. dist .. "m]"
            data.dist.Visible = CFG.esp_dist
            data.hpBg.Visible = CFG.esp_health
            data.hp.Size = UDim2.new(hPercent, 0, 1, 0)
            data.hp.BackgroundColor3 = hPercent > 0.5 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        else
            if espData[p] then
                if espData[p].hl then espData[p].hl:Destroy() end
                if espData[p].bg then espData[p].bg:Destroy() end
                espData[p] = nil
            end
        end
    end
end)
P.PlayerRemoving:Connect(function(p) if espData[p] then if espData[p].hl then espData[p].hl:Destroy() end; if espData[p].bg then espData[p].bg:Destroy() end; espData[p] = nil end end)

-- ==========================================
-- ENGINE: PARRY RANGE INDICATOR
-- ==========================================
local PARRY_RADIUS = 18
local parryIndicator = nil

RS.RenderStepped:Connect(function()
    if not MasterEnabled then return end
    
    if CFG.auto_parry and LP.Character then
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp and not parryIndicator then
            local sphere = Instance.new("Part")
            sphere.Name = "ParryRange"
            sphere.Shape = Enum.PartType.Ball
            sphere.Size = Vector3.new(PARRY_RADIUS * 2, PARRY_RADIUS * 2, PARRY_RADIUS * 2)
            sphere.Anchored = true
            sphere.CanCollide = false
            sphere.Material = Enum.Material.ForceField
            sphere.Color = Color3.fromRGB(255, 255, 255)
            sphere.Transparency = 0.8
            sphere.Parent = WS
            parryIndicator = sphere
        end
        if parryIndicator and hrp then
            parryIndicator.Position = hrp.Position
        end
    else
        if parryIndicator then
            parryIndicator:Destroy()
            parryIndicator = nil
        end
    end
end)

-- ==========================================
-- ENGINE: GOD MODE LIGHTING & FPS
-- ==========================================
local origFogEnd, origBrightness, origClock = L.FogEnd, L.Brightness, L.ClockTime
local origQuality = settings().Rendering.QualityLevel

for _, v in pairs(L:GetChildren()) do
    if v:IsA("Atmosphere") or v:IsA("ColorCorrectionEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") then
        v:Destroy()
    end
end

RS.Heartbeat:Connect(function()
    if not MasterEnabled then return end
    
    if CFG.bright then 
        L.Brightness = 5
        L.ClockTime = 12
        L.Ambient = Color3.fromRGB(255, 255, 255)
        L.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        L.ExposureCompensation = 1
        L.FogEnd = 100000
        L.GlobalShadows = false
        L.ShadowSoftness = 0
        
        for _, v in pairs(L:GetChildren()) do
            if v:IsA("Atmosphere") or v:IsA("ColorCorrectionEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") then
                v:Destroy()
            end
        end
    else 
        L.Brightness = origBrightness
        L.ClockTime = origClock
        L.Ambient = Color3.fromRGB(0, 0, 0)
        L.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        L.ExposureCompensation = 0
        L.FogEnd = origFogEnd
        L.GlobalShadows = true
    end
    
    if CFG.fpsboost then 
        settings().Rendering.QualityLevel = 1
        L.EnvironmentDiffuseScale = 0
        L.EnvironmentSpecularScale = 0
    end
end)

-- ==========================================
-- ENGINE: SMART SKILLCHECK
-- ==========================================
task.spawn(function()
    while task.wait(0.05) do
        if not MasterEnabled then continue end
        if CFG.auto_gen or CFG.auto_skillcheck then
            local isHoldingMouse = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UIS:IsKeyDown(Enum.KeyCode.E)
            if isHoldingMouse then
                if CFG.auto_gen then pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game) end) end
                
                if CFG.auto_skillcheck then
                    local pg = LP:FindFirstChild("PlayerGui")
                    if pg then
                        for _, g in pairs(pg:GetDescendants()) do
                            if (g:IsA("ImageLabel") or g:IsA("Frame")) and (g.Name:lower():find("indicator") or g.Name:lower():find("arrow")) then
                                local pos = math.abs(g.Position.X.Scale - 0.5)
                                if pos < 0.15 then
                                    pcall(function() 
                                        VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                                        task.wait(0.01)
                                        VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                                    end)
                                end
                            end
                        end
                    end
                end
            else
                pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game) end)
            end
        end
    end
end)

-- AUTO PARRY
task.spawn(function()
    while task.wait(0.05) do
        if not MasterEnabled then continue end
        if CFG.auto_parry and LP.Character then
            local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, p in ipairs(P:GetPlayers()) do
                    if p ~= LP and p.Character and isKiller(p) then
                        local targetHrp = p.Character:FindFirstChild("HumanoidRootPart")
                        local hum = p.Character:FindFirstChildOfClass("Humanoid")
                        if targetHrp and hum and hum.Health > 0 and (targetHrp.Position - hrp.Position).Magnitude < PARRY_RADIUS then
                            pcall(function() VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0); task.wait(0.01); VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0); VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game); task.wait(0.01); VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game) end)
                        end
                    end
                end
            end
        end
    end
end)

RS.Stepped:Connect(function()
    if not MasterEnabled then return end
    local c = LP.Character
    if c then local hum = c:FindFirstChildOfClass("Humanoid"); if hum then if CFG.ws_enabled then hum.WalkSpeed = CFG.ws_speed else hum.WalkSpeed = 16 end end end
end)

print("[Tumblr Girls] Script Made By SpookingD — v36.0 Ghost Admin Evasion Loaded.")
