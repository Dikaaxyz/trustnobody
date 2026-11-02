--[[
    SpookingD - Violence District
    v56.0 — Visual Skillcheck (Blind Scan)
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

local MasterEnabled = false

local CFG = {
    esp=false, esp_name=true, esp_health=true, esp_dist=true, esp_item=true,
    gen_esp=false, killer_esp=false, item_esp=false, exit_esp=false,
    bright=false, fpsboost=false,
    crosshair=false, fov_enabled=false, fov_val=70, hitbox_expand=false,
    auto_parry=false, auto_skillcheck=false,
    look_lock=false, ws_enabled=false, ws_speed=16,
    keyMenu=Enum.KeyCode.RightShift
}

local VD_ITEMS = {
    "Parrying Dagger", "Flashlight", "Bandage", "Adrenaline Shot", 
    "Motion Tracker", "Shadow Clone", "Gate", "Twist of Fate", 
    "WaxBound Candle", "Holy Water", "Riot Shield"
}

pcall(function()
    getgenv().SpoofedHWID = tostring(math.random(100000,999999)) .. "SPOOK"
    game:GetService("RbxAnalyticsService").GetHardwareIdentifier = function() return getgenv().SpoofedHWID end
    if writefile and isfile and delfile then pcall(function() if isfile("RobloxCookies.dat") then delfile("RobloxCookies.dat") end end) end
end)

local function getHui() if typeof(gethui) == "function" then local ok, h = pcall(gethui) if ok and h then return h end end return CG end

local COL = { bg=Color3.fromRGB(15, 15, 15), panel=Color3.fromRGB(25, 25, 25), sidebar=Color3.fromRGB(10, 10, 10), line=Color3.fromRGB(50, 50, 50), txt=Color3.fromRGB(255, 255, 255), dim=Color3.fromRGB(130, 130, 130), acc=Color3.fromRGB(255, 0, 60), off=Color3.fromRGB(60, 60, 60) }

local gui = Instance.new("ScreenGui"); gui.Name="SpookingD"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true; gui.DisplayOrder=999999; gui.Parent=getHui(); getgenv().TGui=gui
local main = Instance.new("Frame"); main.Size=UDim2.new(0, 600, 0, 420); main.Position=UDim2.new(0.5, -300, 0.5, -210); main.BackgroundColor3=COL.bg; main.BorderSizePixel=0; main.Active=true; main.Parent=gui
local ms = Instance.new("UIStroke"); ms.Color=COL.acc; ms.Thickness=1; ms.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; ms.Parent=main

local sidebar = Instance.new("Frame"); sidebar.Size=UDim2.new(0, 130, 1, 0); sidebar.BackgroundColor3=COL.sidebar; sidebar.BorderSizePixel=0; sidebar.Parent=main
local logo = Instance.new("TextLabel"); logo.Size=UDim2.new(1, 0, 0, 50); logo.BackgroundTransparency=1; logo.Text="SpookingD"; logo.TextColor3=COL.acc; logo.Font=Enum.Font.GothamBlack; logo.TextSize=22; logo.Parent=sidebar

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

local boxESP = createBox(pgVisual, "Player ESP", 10, 10, 440, 220)
addSwitch(boxESP, "Enable ESP", "esp", 30); addSwitch(boxESP, "Show Name", "esp_name", 60); addSwitch(boxESP, "Show Health", "esp_health", 90); addSwitch(boxESP, "Show Distance", "esp_dist", 120); addSwitch(boxESP, "Show Item", "esp_item", 150)

local boxVisual = createBox(pgVisual, "Screen", 10, 240, 440, 100)
addSwitch(boxVisual, "Custom Crosshair", "crosshair", 30); addSwitch(boxVisual, "Hitbox Visualizer", "hitbox_expand", 60)

local boxWorld = createBox(pgWorld, "World ESP", 10, 10, 440, 160)
addSwitch(boxWorld, "Generator ESP", "gen_esp", 30); addSwitch(boxWorld, "Killer Skill ESP", "killer_esp", 60); addSwitch(boxWorld, "Item ESP", "item_esp", 90); addSwitch(boxWorld, "Exit / Spike ESP", "exit_esp", 120)

local boxEnv = createBox(pgMisc, "Environment", 10, 10, 440, 100)
addSwitch(boxEnv, "TRUE Fullbright", "bright", 30); addSwitch(boxEnv, "FPS Booster", "fpsboost", 60)

local boxSafe = createBox(pgSurvivor, "Survivor Utility", 10, 10, 440, 120)
addSwitch(boxSafe, "Auto Parry (God-Tier)", "auto_parry", 30); addSwitch(boxSafe, "Auto Skillcheck (Space)", "auto_skillcheck", 60)

local boxKiller = createBox(pgKiller, "Killer Utility", 10, 10, 440, 80)
addSwitch(boxKiller, "Look Lock (Aim Assist)", "look_lock", 30)

local boxFOV = createBox(pgMisc, "Camera FOV", 10, 120, 440, 100)
addSwitch(boxFOV, "Enable Custom FOV", "fov_enabled", 30)
addSlider(boxFOV, "FOV Value", "fov_val", 50, 120, 60)

local boxMisc = createBox(pgMisc, "Movement", 10, 230, 440, 100)
addSwitch(boxMisc, "Enable WalkSpeed", "ws_enabled", 30); addSlider(boxMisc, "WalkSpeed (Safe)", "ws_speed", 16, 28, 60)

local boxBypass = createBox(pgMisc, "SpookingD Bypass", 10, 340, 440, 150)
addButton(boxBypass, "Re-Apply HWID Bypass", function() getgenv().SpoofedHWID = tostring(math.random(100000,999999)); pcall(function() game:GetService("RbxAnalyticsService").GetHardwareIdentifier = function() return getgenv().SpoofedHWID end end); if writefile and isfile and delfile then pcall(function() if isfile("RobloxCookies.dat") then delfile("RobloxCookies.dat") end end) end end, 30)
addButton(boxBypass, "FLUSH LOGS & CACHE", function() 
    if writefile and isfile and delfile then 
        pcall(function() 
            if isfile("RobloxCookies.dat") then delfile("RobloxCookies.dat") end 
            if isfile("rbx_cookie") then delfile("rbx_cookie") end
            if isfile("log.txt") then delfile("log.txt") end
        end) 
        print("[SpookingD] Logs & Cache Flushed.")
    end
end, 60)
addButton(boxBypass, "Panic Wipe (Log Out)", function() if writefile and delfile then pcall(function() if isfile("RobloxCookies.dat") then delfile("RobloxCookies.dat") end end) end; game:Shutdown() end, 90)

sideTabs[1].TextColor3 = COL.txt; sideTabs[1].BackgroundColor3 = COL.panel; sidePages[1].Visible = true
local closeBtn = Instance.new("TextButton"); closeBtn.Size=UDim2.new(0, 20, 0, 20); closeBtn.Position=UDim2.new(1, -25, 0, 5); closeBtn.BackgroundTransparency=1; closeBtn.Text="×"; closeBtn.TextColor3=COL.txt; closeBtn.Font=Enum.Font.GothamBold; closeBtn.TextSize=16; closeBtn.Parent=main
local openBtn = Instance.new("TextButton"); openBtn.Size=UDim2.new(0, 40, 0, 40); openBtn.Position=UDim2.new(0, 20, 0, 100); openBtn.BackgroundColor3=COL.bg; openBtn.BorderSizePixel=2; openBtn.BorderColor3=COL.acc; openBtn.Text="S"; openBtn.TextColor3=COL.acc; openBtn.Font=Enum.Font.GothamBlack; openBtn.TextSize=22; openBtn.Parent=gui; openBtn.Visible = false
closeBtn.MouseButton1Click:Connect(function() main.Visible = false; openBtn.Visible = true end)
openBtn.MouseButton1Click:Connect(function() main.Visible = true; openBtn.Visible = false end)
UIS.InputBegan:Connect(function(i, pr) if pr then return end; if i.KeyCode == CFG.keyMenu then main.Visible = not main.Visible; openBtn.Visible = not main.Visible end end)
local drag, ds, sp
logo.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; ds = i.Position; sp = main.Position end end)
UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - ds; main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)

-- ==========================================
-- ENGINE: ESP (Auto-Refresh 60s)
-- ==========================================
local crosshair = Instance.new("Frame"); crosshair.Size = UDim2.new(0, 4, 0, 4); crosshair.Position = UDim2.new(0.5, -2, 0.5, -2); crosshair.BackgroundColor3 = COL.acc; crosshair.BorderSizePixel = 0; crosshair.Visible = false; crosshair.Parent = gui
local espData = {}

local function isKiller(p)
    if p.Team and p.Team.Name:lower():find("killer") then return true end
    local ls = p:FindFirstChild("leaderstats")
    if ls then for _, v in pairs(ls:GetChildren()) do if v.Name:lower():find("role") and tostring(v.Value):lower():find("killer") then return true end end end
    return false
end

local function getSurvivorItem(p)
    local char = p.Character
    if not char then return nil end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if tool then
        local toolName = tool.Name:lower()
        for _, itemName in ipairs(VD_ITEMS) do
            if toolName:find(itemName:lower()) then return itemName end
        end
    end
    return nil
end

local function clearAllESP()
    for p, data in pairs(espData) do
        if data.hl then data.hl:Destroy() end
        if data.bg then data.bg:Destroy() end
        espData[p] = nil
    end
end

task.spawn(function()
    while true do
        task.wait(60)
        if MasterEnabled and CFG.esp then
            clearAllESP()
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if MasterEnabled and CFG.esp then
            pcall(function()
                for _, p in ipairs(P:GetPlayers()) do
                    if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
                        local hrp = p.Character.HumanoidRootPart
                        local hum = p.Character.Humanoid
                        local killer = isKiller(p)
                        local color = killer and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 255)
                        local itemName = nil
                        if not killer and CFG.esp_item then itemName = getSurvivorItem(p) end

                        if not espData[p] or not espData[p].bg or not espData[p].bg.Parent then
                            if espData[p] and espData[p].hl then espData[p].hl:Destroy() end
                            if espData[p] and espData[p].bg then espData[p].bg:Destroy() end

                            local hl = Instance.new("Highlight")
                            hl.FillColor = color
                            hl.OutlineColor = color
                            hl.FillTransparency = 0.7
                            hl.Parent = p.Character

                            local bg = Instance.new("BillboardGui")
                            bg.Name = "Spook_ESP"
                            bg.Adornee = hrp
                            bg.Size = UDim2.new(0, 150, 0, 65)
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
                            
                            local itemLbl = Instance.new("TextLabel")
                            itemLbl.Size = UDim2.new(1, 0, 0, 12)
                            itemLbl.Position = UDim2.new(0, 0, 0, 14)
                            itemLbl.BackgroundTransparency = 1
                            itemLbl.TextColor3 = Color3.fromRGB(0, 255, 255)
                            itemLbl.TextStrokeTransparency = 0
                            itemLbl.Font = Enum.Font.GothamBold
                            itemLbl.TextSize = 11
                            itemLbl.Parent = bg

                            local distLbl = Instance.new("TextLabel")
                            distLbl.Size = UDim2.new(1, 0, 0, 12)
                            distLbl.Position = UDim2.new(0, 0, 0, 26)
                            distLbl.BackgroundTransparency = 1
                            distLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
                            distLbl.TextStrokeTransparency = 0
                            distLbl.Font = Enum.Font.Gotham
                            distLbl.TextSize = 11
                            distLbl.Parent = bg

                            local hpBg = Instance.new("Frame")
                            hpBg.Size = UDim2.new(0.6, 0, 0, 4)
                            hpBg.Position = UDim2.new(0.2, 0, 0, 42)
                            hpBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                            hpBg.BorderSizePixel = 0
                            hpBg.Parent = bg

                            local hpFill = Instance.new("Frame")
                            hpFill.Size = UDim2.new(1, 0, 1, 0)
                            hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                            hpFill.BorderSizePixel = 0
                            hpFill.Parent = hpBg
                            
                            espData[p] = {hl = hl, bg = bg, name = nameLbl, item = itemLbl, dist = distLbl, hp = hpFill, hpBg = hpBg}
                        end

                        local data = espData[p]
                        local dist = math.floor((hrp.Position - LP.Character.HumanoidRootPart.Position).Magnitude)
                        local hPercent = hum.Health / hum.MaxHealth

                        data.hl.Enabled = CFG.esp
                        data.hl.FillColor = color
                        data.hl.OutlineColor = color
                        data.bg.Enabled = CFG.esp
                        data.name.Text = p.Name
                        data.name.TextColor3 = color
                        data.name.Visible = CFG.esp_name
                        
                        if itemName then
                            data.item.Text = "[" .. itemName .. "]"
                            data.item.Visible = CFG.esp_item
                        else
                            data.item.Visible = false
                        end
                        
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
        end
    end
end)
P.PlayerRemoving:Connect(function(p) if espData[p] then if espData[p].hl then espData[p].hl:Destroy() end; if espData[p].bg then espData[p].bg:Destroy() end; espData[p] = nil end end)

-- ==========================================
-- ENGINE: BLIND VISUAL SKILLCHECK (No Lag)
-- ==========================================
task.spawn(function()
    while task.wait(0.1) do 
        if not MasterEnabled then continue end
        if CFG.auto_skillcheck then
            local isHoldingMouse = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
            if isHoldingMouse then
                local pg = LP:FindFirstChild("PlayerGui")
                if pg then
                    -- Blind Scan: Cek semua ImageLabel yang ada di layar
                    for _, g in ipairs(pg:GetDescendants()) do
                        if g:IsA("ImageLabel") then
                            -- Kalo ukurannya kecil (kaya jarum) dan posisinya di tengah
                            local sx = g.Position.X.Scale
                            local sy = g.Position.Y.Scale
                            if sx > 0.35 and sx < 0.65 and sy > 0.35 and sy < 0.65 then
                                -- Tembak Spasi
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
        end
    end
end)

-- AUTO PARRY
task.spawn(function()
    while task.wait(0.1) do
        if not MasterEnabled then continue end
        if CFG.auto_parry and LP.Character then
            local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, p in ipairs(P:GetPlayers()) do
                    if p ~= LP and p.Character and isKiller(p) then
                        local targetHrp = p.Character:FindFirstChild("HumanoidRootPart")
                        local hum = p.Character:FindFirstChildOfClass("Humanoid")
                        if targetHrp and hum and hum.Health > 0 and (targetHrp.Position - hrp.Position).Magnitude < 18 then
                            pcall(function() VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0); task.wait(0.01); VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0); VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game); task.wait(0.01); VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game) end)
                        end
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- ENGINE: FOV LOCK
-- ==========================================
RS.RenderStepped:Connect(function()
    if not MasterEnabled then return end
    if CAM and CFG.fov_enabled then
        CAM.FieldOfView = CFG.fov_val
    end
end)

-- ==========================================
-- ENGINE: SOFT LIGHTING & FPS
-- ==========================================
local origFogEnd, origBrightness, origClock = L.FogEnd, L.Brightness, L.ClockTime
local origQuality = settings().Rendering.QualityLevel

for _, v in pairs(L:GetChildren()) do
    if v:IsA("Atmosphere") or v:IsA("ColorCorrectionEffect") or v:IsA("BlurEffect") then v:Destroy() end
end

RS.RenderStepped:Connect(function()
    if not MasterEnabled then return end
    
    if CFG.bright then 
        L.Brightness = 1.5
        L.ClockTime = 14.5
        L.Ambient = Color3.fromRGB(130, 130, 130)
        L.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
        L.ExposureCompensation = 0.1
        L.FogEnd = 5000
        L.GlobalShadows = false
        L.ShadowSoftness = 0.5
        
        for _, v in pairs(L:GetChildren()) do
            if v:IsA("Atmosphere") or v:IsA("ColorCorrectionEffect") or v:IsA("BlurEffect") then 
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

RS.Stepped:Connect(function()
    if not MasterEnabled then return end
    local c = LP.Character
    if c then local hum = c:FindFirstChildOfClass("Humanoid"); if hum then if CFG.ws_enabled then hum.WalkSpeed = CFG.ws_speed else hum.WalkSpeed = 16 end end end
end)

print("[SpookingD] Script Loaded — v56.0 Blind Scan")
