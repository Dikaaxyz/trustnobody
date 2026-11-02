--[[
    Tumblr Girls - Script Made By SpookingD
    v17.0 — Shadow UI (Total Rework)
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
local TS = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local MasterEnabled = false

local CFG = {
    -- Visuals
    esp=false, esp_box=true, esp_name=true, esp_health=true, esp_dist=true, esp_tracer=false,
    gen_esp=false, killer_esp=false, item_esp=false, exit_esp=false,
    bright=false, fpsboost=false,
    -- Utility
    crosshair=false, fov=70, hitbox_expand=false,
    -- Survivor
    auto_gen=false, auto_parry=false, auto_skillcheck=false,
    -- Killer
    look_lock=false,
    -- Movement
    ws_speed=16,
    keyMenu=Enum.KeyCode.RightShift
}

-- ==========================================
-- [ULTIMATE STEALTH BYPASS]
-- ==========================================
pcall(function()
    local mt = getrawmetatable(game)
    local registry = debug.getregistry()
    for i = 1, 100 do
        if registry[i] == mt then
            table.remove(registry, i)
            break
        end
    end

    local NetworkClient = game:GetService("NetworkClient")
    local oldInvoke = NetworkClient.Invoke
    NetworkClient.Invoke = function(self, req, ...)
        if req == "Handshake" then return "Roblox/WinInet/10.0" end
        return oldInvoke(self, req, ...)
    end

    local oldGet = HttpService.GetAsync
    HttpService.GetAsync = function(self, url, ...)
        if url:find("ip") or url:find("geo") or url:find("location") then 
            return '{"ip":"104.28.210.1","country":"US","city":"Los Angeles"}' 
        end
        return oldGet(self, url, ...)
    end

    local oldIndex = getrawmetatable(game).__index
    getrawmetatable(game).__index = newcclosure(function(self, k)
        if self == LP and k == "WalkSpeed" then
            if CFG.ws_speed > 28 then return 28 end
        end
        return oldIndex(self, k)
    end)
    
    getgenv().SpoofedHWID = tostring(math.random(100000,999999))
    game:GetService("RbxAnalyticsService").GetHardwareIdentifier = function() return getgenv().SpoofedHWID end
    
    if writefile and isfile and delfile then 
        pcall(function() 
            if isfile("RobloxCookies.dat") then delfile("RobloxCookies.dat") end 
        end) 
    end
end)

local function getHui()
    if typeof(gethui) == "function" then 
        local ok, h = pcall(gethui)
        if ok and h then return h end 
    end
    return CG
end

-- === TUMBLR GIRLS UI ===
local COL = { 
    bg=Color3.fromRGB(12, 12, 12), panel=Color3.fromRGB(20, 20, 20), sidebar=Color3.fromRGB(16, 16, 16), 
    line=Color3.fromRGB(45, 45, 45), txt=Color3.fromRGB(255, 255, 255), dim=Color3.fromRGB(120, 120, 120), 
    acc=Color3.fromRGB(255, 0, 60), off=Color3.fromRGB(60, 60, 60) 
}

local gui = Instance.new("ScreenGui"); gui.Name="TumblrGirls"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true; gui.DisplayOrder=999999; gui.Parent=getHui(); getgenv().TGui=gui
local main = Instance.new("Frame"); main.Size=UDim2.new(0, 600, 0, 420); main.Position=UDim2.new(0.5, -300, 0.5, -210); main.BackgroundColor3=COL.bg; main.BorderSizePixel=0; main.Active=true; main.Parent=gui
local ms = Instance.new("UIStroke"); ms.Color=COL.acc; ms.Thickness=1; ms.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; ms.Parent=main

local sidebar = Instance.new("Frame"); sidebar.Size=UDim2.new(0, 130, 1, 0); sidebar.BackgroundColor3=COL.sidebar; sidebar.BorderSizePixel=0; sidebar.Parent=main
local logo = Instance.new("TextLabel"); logo.Size=UDim2.new(1, 0, 0, 50); logo.BackgroundTransparency=1; logo.Text="TUMBLR"; logo.TextColor3=COL.acc; logo.Font=Enum.Font.GothamBlack; logo.TextSize=24; logo.Parent=sidebar
local subLogo = Instance.new("TextLabel"); subLogo.Size=UDim2.new(1, 0, 0, 10); subLogo.Position=UDim2.new(0,0,0,40); subLogo.BackgroundTransparency=1; subLogo.Text="GIRLS"; subLogo.TextColor3=COL.txt; subLogo.Font=Enum.Font.GothamBold; subLogo.TextSize=10; subLogo.Parent=sidebar

local masterBtn = Instance.new("TextButton")
masterBtn.Size = UDim2.new(1, -20, 0, 30); masterBtn.Position = UDim2.new(0, 10, 0, 55)
masterBtn.BackgroundColor3 = COL.panel; masterBtn.BorderSizePixel = 0
masterBtn.Text = "ENABLE SCRIPT"; masterBtn.TextColor3 = COL.dim; masterBtn.Font = Enum.Font.GothamBold; masterBtn.TextSize = 10; masterBtn.Parent = sidebar
local masterStroke = Instance.new("UIStroke"); masterStroke.Color = COL.line; masterStroke.Thickness = 1; masterStroke.Parent = masterBtn

masterBtn.MouseButton1Click:Connect(function()
    MasterEnabled = not MasterEnabled
    if MasterEnabled then
        masterBtn.Text = "SCRIPT: ON"; masterBtn.TextColor3 = COL.acc; masterStroke.Color = COL.acc
    else
        masterBtn.Text = "ENABLE SCRIPT"; masterBtn.TextColor3 = COL.dim; masterStroke.Color = COL.line
    end
end)

local sideTabs, sidePages = {}, {}
local function addSideTab(name)
    local btn = Instance.new("TextButton"); btn.Size=UDim2.new(1, -20, 0, 30); btn.Position=UDim2.new(0, 10, 0, 90 + (#sideTabs * 32)); btn.BackgroundColor3=COL.sidebar; btn.BorderSizePixel=0; btn.Text="  " .. name; btn.TextColor3=COL.dim; btn.Font=Enum.Font.GothamBold; btn.TextSize=11; btn.TextXAlignment=Enum.TextXAlignment.Left; btn.AutoButtonColor=false; btn.Parent=sidebar; table.insert(sideTabs, btn)
    
    local pg = Instance.new("ScrollingFrame") -- Changed from Frame to ScrollingFrame
    pg.Size=UDim2.new(1, -130, 1, 0); pg.Position=UDim2.new(0, 130, 0, 0); pg.BackgroundTransparency=1
    pg.BorderSizePixel=0; pg.ScrollBarThickness=2; pg.ScrollBarImageColor3=COL.acc
    pg.CanvasSize=UDim2.new(0,0,0,0); pg.AutomaticCanvasSize=Enum.AutomaticSize.Y; pg.Visible=false; pg.Parent=main
    table.insert(sidePages, pg)
    
    local pgLayout = Instance.new("UIListLayout")
    pgLayout.Padding = UDim.new(0, 10)
    pgLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pgLayout.Parent = pg

    local pgPad = Instance.new("UIPadding")
    pgPad.PaddingTop = UDim.new(0, 15)
    pgPad.PaddingLeft = UDim.new(0, 15)
    pgPad.Parent = pg
    
    local idx = #sideTabs
    btn.MouseButton1Click:Connect(function()
        for i, t in ipairs(sideTabs) do 
            t.TextColor3 = (i == idx) and COL.txt or COL.dim
            t.BackgroundColor3 = (i == idx) and COL.panel or COL.sidebar 
        end
        for i, p in ipairs(sidePages) do 
            p.Visible = (i == idx) 
        end
    end)
    return pg
end

-- FIXED BOX BUILDER (Tanpa UIListLayout di dalem, biar digabung sama parent scroll)
local function createBox(parent, title, w, h)
    local box = Instance.new("Frame"); box.Size=UDim2.new(0, w, 0, h); box.BackgroundColor3=COL.panel; box.BorderSizePixel=0; box.Parent=parent
    local bs = Instance.new("UIStroke"); bs.Color=COL.line; bs.Thickness=1; bs.Parent=box
    
    local header = Instance.new("Frame"); header.Size=UDim2.new(1, 0, 0, 24); header.BackgroundColor3=COL.sidebar; header.BorderSizePixel=0; header.Parent=box
    local tl = Instance.new("TextLabel"); tl.Size=UDim2.new(1, -10, 1, 0); tl.Position=UDim2.new(0, 10, 0, 0); tl.BackgroundTransparency=1; tl.Text=title; tl.TextColor3=COL.txt; tl.Font=Enum.Font.GothamBold; tl.TextSize=11; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.Parent=header
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -10, 1, -30)
    contentFrame.Position = UDim2.new(0, 5, 0, 28)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = box

    local list = Instance.new("UIListLayout"); list.Padding=UDim.new(0, 2); list.Parent=contentFrame
    
    return box, contentFrame
end

local function addToggle(parent, label, key)
    local btn = Instance.new("TextButton"); btn.Size=UDim2.new(1, 0, 0, 24); btn.BackgroundTransparency=1; btn.Text=""; btn.AutoButtonColor=false; btn.Parent=parent
    local txt = Instance.new("TextLabel"); txt.Size=UDim2.new(1, -60, 1, 0); txt.BackgroundTransparency=1; txt.Text=label; txt.TextColor3=COL.txt; txt.Font=Enum.Font.Gotham; txt.TextSize=11; txt.TextXAlignment=Enum.TextXAlignment.Left; txt.Parent=btn
    local stateBtn = Instance.new("TextButton"); stateBtn.Size=UDim2.new(0, 36, 0, 16); stateBtn.Position=UDim2.new(1, -36, 0.5, -8); stateBtn.BackgroundColor3=CFG[key] and COL.acc or COL.off; stateBtn.BorderSizePixel=0; stateBtn.Text=CFG[key] and "ON" or "OFF"; stateBtn.TextColor3=COL.txt; stateBtn.Font=Enum.Font.GothamBold; stateBtn.TextSize=9; stateBtn.Parent=btn
    
    btn.MouseButton1Click:Connect(function() 
        if not MasterEnabled then return end
        CFG[key] = not CFG[key]
        stateBtn.BackgroundColor3 = CFG[key] and COL.acc or COL.off
        stateBtn.Text = CFG[key] and "ON" or "OFF"
    end)
end

local function addSlider(parent, label, key, min, max)
    local frame = Instance.new("Frame"); frame.Size=UDim2.new(1, 0, 0, 24); frame.BackgroundTransparency=1; frame.Parent=parent
    local txt = Instance.new("TextLabel"); txt.Size=UDim2.new(1, -60, 1, 0); txt.BackgroundTransparency=1; txt.Text=label; txt.TextColor3=COL.txt; txt.Font=Enum.Font.Gotham; txt.TextSize=11; txt.TextXAlignment=Enum.TextXAlignment.Left; txt.Parent=frame
    local input = Instance.new("TextBox"); input.Size=UDim2.new(0, 40, 0, 18); input.Position=UDim2.new(1, -40, 0.5, -9); input.BackgroundColor3=COL.bg; input.BorderSizePixel=0; input.Text=tostring(CFG[key]); input.TextColor3=COL.acc; input.Font=Enum.Font.GothamBold; input.TextSize=10; input.Parent=frame
    input.FocusLost:Connect(function() 
        if not MasterEnabled then return end
        local val = tonumber(input.Text); if val then CFG[key] = math.clamp(val, min, max) end; input.Text = tostring(CFG[key]) 
    end)
end

local function addButton(parent, label, cb)
    local btn = Instance.new("TextButton"); btn.Size=UDim2.new(1, 0, 0, 24); btn.BackgroundColor3=COL.bg; btn.BorderSizePixel=0; btn.Text=label; btn.TextColor3=COL.txt; btn.Font=Enum.Font.GothamBold; btn.TextSize=11; btn.Parent=parent
    local bs = Instance.new("UIStroke"); bs.Color=COL.line; bs.Thickness=1; bs.Parent=btn
    btn.MouseButton1Click:Connect(function() if MasterEnabled then pcall(cb) end end)
end

local pgVisual = addSideTab("Visuals"); local pgWorld = addSideTab("World"); local pgSurvivor = addSideTab("Survivor"); local pgKiller = addSideTab("Killer"); local pgMisc = addSideTab("Misc")

-- Mounting dengan size yang explicit (biar gak ilang)
local boxESP, listESP = createBox(pgVisual, "Player ESP", 420, 175)
addToggle(listESP, "Enable ESP", "esp"); addToggle(listESP, "Show Box", "esp_box"); addToggle(listESP, "Show Name", "esp_name"); addToggle(listESP, "Show Health", "esp_health"); addToggle(listESP, "Show Distance", "esp_dist")

local boxVisual, listVisual = createBox(pgVisual, "Screen", 420, 110)
addToggle(listVisual, "Custom Crosshair", "crosshair"); addToggle(listVisual, "Hitbox Visualizer", "hitbox_expand"); addSlider(listVisual, "Camera FOV", "fov", 50, 120)

local boxWorld, listWorld = createBox(pgWorld, "World ESP", 420, 150)
addToggle(listWorld, "Generator ESP", "gen_esp"); addToggle(listWorld, "Killer ESP", "killer_esp"); addToggle(listWorld, "Item ESP", "item_esp"); addToggle(listWorld, "Exit / Spike ESP", "exit_esp")

local boxEnv, listEnv = createBox(pgWorld, "Environment", 420, 90)
addToggle(listEnv, "Soft Fullbright", "bright"); addToggle(listEnv, "FPS Booster", "fpsboost")

local boxSafe, listSafe = createBox(pgSurvivor, "Survivor Utility", 420, 150)
addToggle(listSafe, "Auto Generator (Hold E)", "auto_gen"); addToggle(listSafe, "Auto Parry (God-Tier)", "auto_parry"); addToggle(listSafe, "Auto Skillcheck", "auto_skillcheck")

local boxKiller, listKiller = createBox(pgKiller, "Killer Utility", 420, 60)
addToggle(listKiller, "Look Lock (Aim Assist)", "look_lock")

local boxMisc, listMisc = createBox(pgMisc, "Movement", 420, 60)
addSlider(listMisc, "WalkSpeed (Safe)", "ws_speed", 16, 28)

local boxBypass, listBypass = createBox(pgMisc, "SpookingD Bypass", 420, 100)
addButton(listBypass, "Re-Apply HWID Bypass", function()
    getgenv().SpoofedHWID = tostring(math.random(100000,999999))
    pcall(function() game:GetService("RbxAnalyticsService").GetHardwareIdentifier = function() return getgenv().SpoofedHWID end end)
    if writefile and isfile and delfile then pcall(function() if isfile("RobloxCookies.dat") then delfile("RobloxCookies.dat") end end) end
    print("[Tumblr Girls] Bypass Applied.")
end)
addButton(listBypass, "Panic Wipe (Log Out)", function()
    if writefile and delfile then pcall(function() if isfile("RobloxCookies.dat") then delfile("RobloxCookies.dat") end end) end
    game:Shutdown()
end)

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
-- ENGINE: CROSSHAIR & HITBOX (Billboard 2D)
-- ==========================================
local crosshair = Instance.new("Frame"); crosshair.Size = UDim2.new(0, 4, 0, 4); crosshair.Position = UDim2.new(0.5, -2, 0.5, -2); crosshair.BackgroundColor3 = COL.acc; crosshair.BorderSizePixel = 0; crosshair.Visible = false; crosshair.Parent = gui
local hitboxParts = {}
local espHighlight = {}

local function isKiller(p)
    if p.Team and p.Team.Name:lower():find("killer") then return true end
    local ls = p:FindFirstChild("leaderstats")
    if ls then
        for _, v in pairs(ls:GetChildren()) do
            if v.Name:lower():find("role") and tostring(v.Value):lower():find("killer") then return true end
        end
    end
    local char = p.Character
    if char then
        local tool = char:FindFirstChildWhichIsA("Tool")
        if tool then
            local name = tool.Name:lower()
            if name:find("veil") or name:find("spear") or name:find("butcher") or name:find("chain") or name:find("mask") or name:find("claw") then
                return true
            end
        end
    end
    return false
end

RS.RenderStepped:Connect(function()
    if not MasterEnabled then return end
    crosshair.Visible = CFG.crosshair
    if CFG.hitbox_expand then
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local tool = p.Character:FindFirstChildWhichIsA("Tool")
                if tool and isKiller(p) then
                    if not hitboxParts[p] then
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "TG_Hitbox"
                        bb.Size = UDim2.new(0, 100, 0, 100)
                        bb.AlwaysOnTop = true
                        bb.Parent = p.Character.HumanoidRootPart
                        
                        local line = Instance.new("Frame")
                        line.Size = UDim2.new(1, 0, 0, 2)
                        line.Position = UDim2.new(0, 0, 0.5, -1)
                        line.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                        line.BorderSizePixel = 0
                        line.Parent = bb
                        
                        hitboxParts[p] = bb
                    end
                else
                    if hitboxParts[p] then hitboxParts[p]:Destroy(); hitboxParts[p] = nil end
                end
            end
        end
    else
        for p, bb in pairs(hitboxParts) do if bb then bb:Destroy() end; hitboxParts[p] = nil end
    end
end)
P.PlayerRemoving:Connect(function(p) if hitboxParts[p] then hitboxParts[p]:Destroy(); hitboxParts[p] = nil end end)

task.spawn(function()
    while true do
        task.wait(1)
        if not MasterEnabled then continue end
        if CFG.esp then 
            for _, p in ipairs(P:GetPlayers()) do 
                if p ~= LP and p.Character then 
                    local killer = isKiller(p)
                    local color = killer and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 255)
                    
                    if not espHighlight[p] then 
                        local h = Instance.new("Highlight")
                        h.FillTransparency = 0.5
                        h.Parent = p.Character
                        espHighlight[p] = h 
                    end
                    
                    espHighlight[p].FillColor = color
                    espHighlight[p].OutlineColor = Color3.fromRGB(0, 0, 0) 
                end 
            end
        else 
            for p, h in pairs(espHighlight) do 
                if h then h:Destroy() end
                espHighlight[p] = nil 
            end 
        end
    end
end)
P.PlayerRemoving:Connect(function(p) if espHighlight[p] then espHighlight[p]:Destroy() espHighlight[p] = nil end end)

-- ==========================================
-- ENGINE: WORLD & FPS BOOSTER
-- ==========================================
local fpsBoostActive = false
local origFogEnd, origBrightness, origClock = L.FogEnd, L.Brightness, L.ClockTime
local origQuality = settings().Rendering.QualityLevel

task.spawn(function()
    while task.wait(1) do
        if not MasterEnabled then continue end
        if CFG.fpsboost then
            if not fpsBoostActive then
                settings().Rendering.QualityLevel = 1; L.GlobalShadows = false; L.EnvironmentDiffuseScale = 0; L.EnvironmentSpecularScale = 0
                for _, v in ipairs(WS:GetDescendants()) do if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") then v.Enabled = false end end
                fpsBoostActive = true
            end
        else
            if fpsBoostActive then
                settings().Rendering.QualityLevel = origQuality; L.GlobalShadows = true; L.EnvironmentDiffuseScale = 0.5; L.EnvironmentSpecularScale = 0.5
                for _, v in ipairs(WS:GetDescendants()) do if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") then v.Enabled = true end end
                fpsBoostActive = false
            end
        end

        if CFG.bright then
            L.Brightness = 1.5; L.ClockTime = 14.5; L.Ambient = Color3.fromRGB(130, 130, 130); L.OutdoorAmbient = Color3.fromRGB(150, 150, 150); L.FogEnd = 5000
        else
            L.Brightness = origBrightness; L.ClockTime = origClock; L.Ambient = Color3.fromRGB(0, 0, 0); L.OutdoorAmbient = Color3.fromRGB(128, 128, 128); L.FogEnd = origFogEnd
        end
    end
end)

-- ==========================================
-- ENGINE: AUTO UTILITY (VIM)
-- ==========================================
task.spawn(function()
    while task.wait(0.1) do
        if not MasterEnabled then continue end
        if CFG.auto_gen then
            local ray = CAM:ViewportPointToRay(CAM.ViewportSize.X/2, CAM.ViewportSize.Y/2)
            local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances = {LP.Character}
            local res = WS:Raycast(ray.Origin, ray.Direction * 15, params)
            if res and res.Instance then
                local name = res.Instance.Name:lower()
                if name:find("gen") or name:find("fuse") or name:find("generator") then pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game); task.wait(0.1); VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game) end) end
            end
        end
    end
end)

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
                        
                        if targetHrp and hum and hum.Health > 0 and (targetHrp.Position - hrp.Position).Magnitude < 18 then
                            pcall(function() 
                                VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                                task.wait(0.01)
                                VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                                VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                                task.wait(0.01)
                                VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                            end)
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
    if c then local hum = c:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = CFG.ws_speed end end
end)

print("[Tumblr Girls] Script Made By SpookingD — Shadow UI Loaded.")
