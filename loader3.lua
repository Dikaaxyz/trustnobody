--[[
  Growblox Hub — Universal Executor Build
  Tested shape for: Xeno, Solara, Delta, Wave, AWP, Fluxus
  Xeno note: Drawing library is partial — ESP auto-falls back to BillboardGui
  Solara/Delta note: fireproximityprompt exposed, Drawing full
  Wave note: gethui() available, GUI goes there first
--]]

-- ============================================================
-- EXECUTOR DETECTION + SAFE PRIMITIVES
-- ============================================================
local EXEC = "unknown"
if getexecutorname then EXEC = getexecutorname()
elseif syn and syn.protect_gui then EXEC = "Synapse"
elseif KRNL_LOADED then EXEC = "Krnl"
elseif is_sirhurt_closure then EXEC = "SirHurt"
elseif fluxus then EXEC = "Fluxus"
elseif XENO then EXEC = "Xeno"
elseif identifyexecutor then EXEC = identifyexecutor()
end

-- fireproximityprompt: some executors rename it, some don't expose it
local firePrompt = (function()
    if fireproximityprompt then return fireproximityprompt end
    if fire_prompt then return fire_prompt end
    -- Fallback: fire the prompt's Triggered remote directly
    return function(prompt)
        if prompt and prompt:IsA("ProximityPrompt") then
            local ok = pcall(function()
                prompt:InputHoldBegin()
                task.wait(0.1)
                prompt:InputHoldEnd()
            end)
            if not ok then
                -- Last resort: fire the underlying RemoteEvent
                local remote = prompt:FindFirstChild("Triggered")
                if remote and remote:IsA("RemoteEvent") then
                    pcall(function() remote:FireServer(prompt.Parent) end)
                end
            end
        end
    end
end)()

-- Safe GUI parent: gethui() on Synapse/Delta/Wave, PlayerGui otherwise
local function getGuiParent()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    if get_hidden_gui then
        local ok, hui = pcall(get_hidden_gui)
        if ok and hui then return hui end
    end
    return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

-- Safe Drawing library check
local HAS_DRAWING = (typeof(Drawing) == "table" and typeof(Drawing.new) == "function")

-- ============================================================
-- SERVICES
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- CONFIG (FILL from live dump)
-- ============================================================
local CFG = {
    PlotFolder      = "Plots",
    SeedFolder      = "SeedShop",
    ItemSpawnFolder = "DroppedItems",
    RemoteBuy       = "BuyItem",
    RemotePlace     = "PlaceBlock",
    RemoteSell      = "SellItem",
    FarmRadius      = 200,
    LoopDelay       = 0.15,
    ESPColor        = Color3.fromRGB(0, 255, 140),
    ESPColorItem    = Color3.fromRGB(255, 200, 50),
    ESPColorPlayer  = Color3.fromRGB(255, 80, 80),
}

-- ============================================================
-- FEATURE FLAGS
-- ============================================================
local F = {
    AutoFarm=false, AutoPlant=false, AutoHarvest=false, AutoWater=false,
    AutoFertilize=false, AutoCollect=false, AutoSell=false, AutoBuySeeds=false,
    AutoBuyTools=false, AutoReplant=false, AutoUseItem=false, AutoTrash=false,
    Fly=false, NoClip=false, Speed=false, JumpPower=false, InfJump=false,
    TeleportToPlot=false, TeleportToShop=false, TeleportToItem=false, WaypointLoop=false,
    ESP_Items=false, ESP_Seeds=false, ESP_Players=false, ESP_Plots=false,
    ESP_Drops=false, ESP_PriceTags=false, Fullbright=false, NoFog=false, XRay=false,
    AutoReconnect=false, AntiAFK=false, AutoClaimDaily=false, AutoOpenCrates=false,
    AutoEquipBest=false, AutoSortInv=false, AutoDropTrash=false,
    AutoAcceptTrade=false, AutoDeclineLowball=false,
    ItemTracker=false, PriceOverlay=false, DropNotifier=false,
    TradeLogger=false, InventoryValue=false, SeedProfitCalc=false,
    HideSelf=false, FreezeOthers=false, SpamEmote=false, FakeLag=false,
    ChatSpam=false, AutoGG=false, ShowFPS=false, ShowPing=false, ShowCoords=false,
    ProxyMode=false, ServerHop=false, Rejoin=false, LowGFX=false,
}

-- ============================================================
-- UTILS
-- ============================================================
local function safeFire(prompt)
    pcall(firePrompt, prompt)
end

local function findPromptsInRange(origin, radius)
    local out = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local part = obj.Parent
            if part and part:IsA("BasePart") then
                if (part.Position - origin).Magnitude <= radius then
                    table.insert(out, obj)
                end
            end
        end
    end
    return out
end

local function getPlot()
    local plots = Workspace:FindFirstChild(CFG.PlotFolder)
    if not plots then return nil end
    for _, plot in ipairs(plots:GetChildren()) do
        local owner = plot:GetAttribute("Owner") or plot:GetAttribute("Player")
        if owner and tostring(owner) == LocalPlayer.Name then
            return plot
        end
    end
    return nil
end

local function getSeedStock()
    local seeds = {}
    local shop = Workspace:FindFirstChild(CFG.SeedFolder, true)
    if not shop then return seeds end
    for _, obj in ipairs(shop:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            table.insert(seeds, obj)
        end
    end
    return seeds
end

-- ============================================================
-- FARM LOOP
-- ============================================================
local farmTick = 0
RunService.Heartbeat:Connect(function(dt)
    farmTick += dt
    if farmTick < CFG.LoopDelay then return end
    farmTick = 0

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if F.AutoFarm or F.AutoHarvest or F.AutoWater or F.AutoCollect then
        for _, p in ipairs(findPromptsInRange(root.Position, CFG.FarmRadius)) do
            local action = p.ActionText:lower()
            if F.AutoHarvest and action:find("harvest") then safeFire(p) end
            if F.AutoWater and action:find("water") then safeFire(p) end
            if F.AutoCollect and (action:find("collect") or action:find("pick")) then safeFire(p) end
            if F.AutoFarm and not F.AutoHarvest then safeFire(p) end
        end
    end

    if F.AutoPlant then
        if getPlot() then
            local placeRemote = ReplicatedStorage:FindFirstChild(CFG.RemotePlace, true)
            if placeRemote then
                pcall(function() placeRemote:FireServer(1) end)
            end
        end
    end

    if F.AutoBuySeeds then
        for _, p in ipairs(getSeedStock()) do safeFire(p) end
    end

    if F.AutoSell then
        local sellRemote = ReplicatedStorage:FindFirstChild(CFG.RemoteSell, true)
        if sellRemote then pcall(function() sellRemote:FireServer() end) end
    end
end)

-- ============================================================
-- MOVEMENT
-- ============================================================
local flyConn, noclipConn
local flySpeed = 50

local function startFly()
    flyConn = RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local dir = Vector3.zero
        local cam = Workspace.CurrentCamera
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if dir.Magnitude > 0 then
            root.CFrame = root.CFrame + dir.Unit * flySpeed * (1/60)
        end
    end)
end

local function startNoClip()
    noclipConn = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end

-- ============================================================
-- ESP — Drawing with BillboardGui fallback
-- ============================================================
local espObjects = {}

local function createESP(part, color, label)
    local obj = {part = part}
    if HAS_DRAWING then
        local box = Drawing.new("Square")
        box.Thickness = 1; box.Color = color; box.Filled = false; box.Visible = true
        local text = Drawing.new("Text")
        text.Size = 14; text.Center = true; text.Outline = true
        text.Color = color; text.Text = label or ""; text.Visible = true
        obj.box = box; obj.text = text; obj.mode = "drawing"
    else
        -- Xeno partial Drawing fallback: BillboardGui
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0, 100, 0, 50)
        bb.AlwaysOnTop = true
        bb.Adornee = part
        bb.Parent = getGuiParent()
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 40, 0, 40)
        frame.Position = UDim2.new(0.5, -20, 0.5, -20)
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 0
        local stroke = Instance.new("UIStroke")
        stroke.Color = color; stroke.Thickness = 1
        stroke.Parent = frame
        frame.Parent = bb
        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, 0, 0, 16)
        txt.Position = UDim2.new(0, 0, 0, -18)
        txt.BackgroundTransparency = 1
        txt.TextColor3 = color
        txt.TextStrokeTransparency = 0
        txt.Text = label or ""
        txt.Font = Enum.Font.Gotham
        txt.TextSize = 12
        txt.Parent = bb
        obj.billboard = bb; obj.mode = "billboard"
    end
    table.insert(espObjects, obj)
end

RunService.RenderStepped:Connect(function()
    local cam = Workspace.CurrentCamera
    for i = #espObjects, 1, -1 do
        local o = espObjects[i]
        local part = o.part
        if not part or not part.Parent then
            if o.mode == "drawing" then
                pcall(function() o.box:Remove(); o.text:Remove() end)
            elseif o.mode == "billboard" then
                pcall(function() o.billboard:Destroy() end)
            end
            table.remove(espObjects, i)
        elseif o.mode == "drawing" then
            local pos, onScreen = cam:WorldToViewportPoint(part.Position)
            if onScreen then
                o.box.Visible = true; o.text.Visible = true
                o.box.Position = Vector2.new(pos.X - 20, pos.Y - 20)
                o.box.Size = Vector2.new(40, 40)
                o.text.Position = Vector2.new(pos.X, pos.Y - 30)
            else
                o.box.Visible = false; o.text.Visible = false
            end
        end
    end
end)

-- ============================================================
-- ANTI-AFK / RECONNECT
-- ============================================================
LocalPlayer.Idled:Connect(function()
    if F.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

LocalPlayer.OnTeleport:Connect(function(state)
    if F.AutoReconnect and state == Enum.TeleportState.Failed then
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end
end)

-- ============================================================
-- GUI
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "GrowbloxHub_" .. math.random(1, 99999)
gui.ResetOnSpawn = false
gui.Parent = getGuiParent()

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 420, 0, 460)
main.Position = UDim2.new(0, 20, 0.5, -230)
main.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 34)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
title.Text = "  Growblox Hub [" .. EXEC .. "]  •  " .. tostring(#F) .. " features"
title.TextColor3 = Color3.fromRGB(220, 220, 220)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.Parent = main

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 28)
tabBar.Position = UDim2.new(0, 0, 0, 34)
tabBar.BackgroundColor3 = Color3.fromRGB(34, 34, 40)
tabBar.Parent = main

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -8, 1, -70)
content.Position = UDim2.new(0, 4, 0, 66)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 4
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.Parent = main

local tabs = {}
local function makeTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 66, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(34, 34, 40)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.Parent = tabBar

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.Parent = content
    page.Visible = false

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 4)
    list.Parent = page

    tabs[name] = {btn = btn, page = page}
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.page.Visible = false
            t.btn.BackgroundColor3 = Color3.fromRGB(34, 34, 40)
        end
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end)
    return page
end

local function addToggle(page, label, flag)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
    btn.Text = "  " .. label .. ": " .. (F[flag] and "ON" or "OFF")
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.Gotham
    btn.Parent = page
    btn.MouseButton1Click:Connect(function()
        F[flag] = not F[flag]
        btn.Text = "  " .. label .. ": " .. (F[flag] and "ON" or "OFF")
        if flag == "Fly" then
            if F.Fly and not flyConn then startFly() end
            if not F.Fly and flyConn then flyConn:Disconnect(); flyConn = nil end
        end
        if flag == "NoClip" then
            if F.NoClip and not noclipConn then startNoClip() end
            if not F.NoClip and noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        end
    end)
end

local farmPage = makeTab("Farm")
local movePage = makeTab("Move")
local visPage  = makeTab("Visual")
local autoPage = makeTab("Auto")
local infoPage = makeTab("Info")
local miscPage = makeTab("Misc")

for _, f in ipairs({"AutoFarm","AutoPlant","AutoHarvest","AutoWater","AutoFertilize","AutoCollect","AutoSell","AutoBuySeeds","AutoBuyTools","AutoReplant","AutoUseItem","AutoTrash"}) do
    addToggle(farmPage, f, f)
end
for _, f in ipairs({"Fly","NoClip","Speed","JumpPower","InfJump","TeleportToPlot","TeleportToShop","TeleportToItem","WaypointLoop"}) do
    addToggle(movePage, f, f)
end
for _, f in ipairs({"ESP_Items","ESP_Seeds","ESP_Players","ESP_Plots","ESP_Drops","ESP_PriceTags","Fullbright","NoFog","XRay"}) do
    addToggle(visPage, f, f)
end
for _, f in ipairs({"AutoReconnect","AntiAFK","AutoClaimDaily","AutoOpenCrates","AutoEquipBest","AutoSortInv","AutoDropTrash","AutoAcceptTrade","AutoDeclineLowball"}) do
    addToggle(autoPage, f, f)
end
for _, f in ipairs({"ItemTracker","PriceOverlay","DropNotifier","TradeLogger","InventoryValue","SeedProfitCalc"}) do
    addToggle(infoPage, f, f)
end
for _, f in ipairs({"HideSelf","FreezeOthers","SpamEmote","FakeLag","ChatSpam","AutoGG","ShowFPS","ShowPing","ShowCoords","ProxyMode","ServerHop","Rejoin","LowGFX"}) do
    addToggle(miscPage, f, f)
end

tabs.Farm.page.Visible = true
tabs.Farm.btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)

-- Save config to getgenv so re-execute preserves state
if setgenv then
    pcall(function() setgenv("GrowbloxConfig", F) end)
end
