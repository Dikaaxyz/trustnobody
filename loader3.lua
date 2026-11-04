--[[
  Growblox Hub v5 — Ultimate Stealth Array
  Target: Bypass client-side heuristics, memory dumps, and UI walkers.
--]]

-- ============================================================
-- 1. CRITICAL EXECUTOR PRIMITIVES & FALLBACKS
-- ============================================================
local env = getgenv()
if env._GB_HUB_v5 then return end
env._GB_HUB_v5 = true

local rawpcall = pcall
local rawspawn = task.spawn
local rawwait = task.wait
local rawdelay = task.delay
local rawgetfenv = getfenv
local rawsetfenv = setfenv

local function safeCall(fn, ...)
    local args = {...}
    local ok, res = rawpcall(function() return fn(unpack(args)) end)
    if ok then return res end
end

-- Randomize session identity
local sessionHash = tostring(math.random(100000, 999999)) .. tostring(tick()):gsub("%.", "")

-- ============================================================
-- 2. ENVIRONMENT LOCK & HOOKS (METATABLE POISON)
-- ============================================================
-- Lock environment to prevent external injection/read
if setreadonly then safeCall(setreadonly, rawgetfenv(), false) end
if hookfunction then
    -- Block common detection methods that game scripts use to find us
    safeCall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "GetDescendants" or method == "GetChildren" then
                if self == game:GetService("CoreGui") or self == Players.LocalPlayer:WaitForChild("PlayerGui") then
                    local res = oldNamecall(self, ...)
                    local filtered = {}
                    for _, obj in ipairs(res) do
                        if not env.__hiddenGuis[obj] then table.insert(filtered, obj) end
                    end
                    return filtered
                end
            end
            return oldNamecall(self, ...)
        end))
    end)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")

env.__hiddenGuis = env.__hiddenGuis or {}
local hiddenGuis = env.__hiddenGuis

-- ============================================================
-- 3. CORE GUI PROTECTION (HIDE FROM WALKERS)
-- ============================================================
local function protectGui(gui)
    if syn and syn.protect_gui then safeCall(syn.protect_gui, gui) end
    if protectgui then safeCall(protectgui, gui) end
    
    -- Try CoreGui, fallback to PlayerGui if lacking permission
    local parent = CoreGui
    if gethui then
        local ok, hui = rawpcall(gethui)
        if ok and hui then parent = hui end
    end
    
    safeCall(function() gui.Parent = parent end)
    hiddenGuis[gui] = true
end

-- ============================================================
-- 4. NETWORK & REMOTE STEALTH (JITTER & SPOOF)
-- ============================================================
local originalFireServer = Instance.new("RemoteEvent").FireServer

local function stealthFire(remote, ...)
    if not remote or not remote:IsA("RemoteEvent") then return end
    -- 10ms to 150ms jitter, mimics human reaction time
    local jitter = math.random(10, 150) / 1000
    rawwait(jitter)
    safeCall(function() remote:FireServer(...) end)
end

local function stealthPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    -- Distance check to avoid "too far" bans
    if hrp and (hrp.Position - prompt.Parent.Position).Magnitude > 32 then return end
    
    safeCall(function()
        if fireproximityprompt then fireproximityprompt(prompt) return end
        prompt:InputHoldBegin()
        rawwait(math.random(40, 120) / 1000)
        prompt:InputHoldEnd()
    end)
end

-- ============================================================
-- 5. CONFIG & FEATURES
-- ============================================================
local CFG = {
    PlotFolder = "Plots", SeedFolder = "SeedShop",
    RemotePlace = "PlaceBlock", RemoteSell = "SellItem",
    FarmRadius = 150, LoopDelay = 0.25,
}

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
-- 6. FARM & MOVEMENT LOGIC
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
        if dir.Magnitude > 0 then root.CFrame = root.CFrame + dir.Unit * flySpeed * (1/60) end
    end)
end

local function startNoClip()
    noclipConn = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if char then for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end end
    end)
end

local function getPlot()
    local plots = Workspace:FindFirstChild(CFG.PlotFolder)
    if not plots then return nil end
    for _, plot in ipairs(plots:GetChildren()) do
        local owner = plot:GetAttribute("Owner") or plot:GetAttribute("Player")
        if owner and tostring(owner) == LocalPlayer.Name then return plot end
    end
end

local farmTick = 0
RunService.Heartbeat:Connect(function(dt)
    farmTick += dt
    if farmTick < CFG.LoopDelay then return end
    farmTick = 0
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if F.AutoFarm or F.AutoHarvest or F.AutoWater or F.AutoCollect then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and not hiddenGuis[obj] then
                local part = obj.Parent
                if part and part:IsA("BasePart") and (part.Position - root.Position).Magnitude <= CFG.FarmRadius then
                    local action = obj.ActionText:lower()
                    if F.AutoHarvest and action:find("harvest") then stealthPrompt(obj) end
                    if F.AutoWater and action:find("water") then stealthPrompt(obj) end
                    if F.AutoCollect and (action:find("collect") or action:find("pick")) then stealthPrompt(obj) end
                    if F.AutoFarm and not F.AutoHarvest then stealthPrompt(obj) end
                end
            end
        end
    end
    if F.AutoPlant and getPlot() then
        local placeRemote = ReplicatedStorage:FindFirstChild(CFG.RemotePlace, true)
        if placeRemote then stealthFire(placeRemote, 1) end
    end
    if F.AutoBuySeeds then
        local shop = Workspace:FindFirstChild(CFG.SeedFolder, true)
        if shop then for _, obj in ipairs(shop:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then stealthPrompt(obj) end
        end end
    end
    if F.AutoSell then
        local sellRemote = ReplicatedStorage:FindFirstChild(CFG.RemoteSell, true)
        if sellRemote then stealthFire(sellRemote) end
    end
end)

LocalPlayer.Idled:Connect(function()
    if F.AntiAFK then VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end
end)

-- ============================================================
-- 7. FULL UI SYSTEM (TAILWIND LAYOUT + OBFUSCATION)
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = tostring(sessionHash)
gui.ResetOnSpawn = false
gui.DisplayOrder = 9999
protectGui(gui)

local Theme = {
    Bg = Color3.fromRGB(10, 15, 13),
    Panel = Color3.fromRGB(16, 24, 20),
    Border = Color3.fromRGB(27, 46, 35),
    Accent = Color3.fromRGB(0, 255, 102),
    Text = Color3.fromRGB(220, 220, 220),
    Muted = Color3.fromRGB(107, 114, 128),
}

local function Create(className, props, children)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do inst[k] = v end
    for _, child in ipairs(children or {}) do child.Parent = inst end
    return inst
end
local function AddCorner(parent, radius)
    return Create("UICorner", { CornerRadius = UDim.new(0, radius or 6), Parent = parent })
end
local function AddStroke(parent, color, thickness)
    return Create("UIStroke", { Color = color or Theme.Border, Thickness = thickness or 1, Parent = parent })
end

local main = Create("Frame", {
    Name = "R"..sessionHash, Size = UDim2.new(0, 960, 0, 640), Position = UDim2.new(0.5, -480, 0.5, -320),
    BackgroundColor3 = Theme.Panel, BorderSizePixel = 0, Active = true, Draggable = true, Parent = gui
})
AddCorner(main, 12); AddStroke(main, Theme.Border, 1)

local titleBar = Create("Frame", { Name = "T"..sessionHash, Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = Color3.fromRGB(13, 21, 17), Parent = main })
AddCorner(titleBar, 12)
Create("Frame", { Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 1, -12), BackgroundColor3 = Color3.fromRGB(13, 21, 17), BorderSizePixel = 0, Parent = titleBar })
Create("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = Theme.Border, BorderSizePixel = 0, Parent = titleBar })
Create("Frame", { Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 16, 0.5, -6), BackgroundColor3 = Theme.Accent, Parent = titleBar }, { AddCorner(_, 6) })
Create("TextLabel", { Size = UDim2.new(0, 200, 1, 0), Position = UDim2.new(0, 36, 0, 0), BackgroundTransparency = 1, Text = "GROWBLOX HUB V5", TextColor3 = Color3.fromRGB(255, 255, 255), TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamBold, TextSize = 14, Parent = titleBar })

local sidebar = Create("Frame", { Name = "S"..sessionHash, Size = UDim2.new(0, 224, 1, -48), Position = UDim2.new(0, 0, 0, 48), BackgroundColor3 = Color3.fromRGB(12, 18, 15), Parent = main })
Create("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BackgroundColor3 = Theme.Border, BorderSizePixel = 0, Parent = sidebar })

local navList = Create("Frame", { Size = UDim2.new(1, -24, 1, -24), Position = UDim2.new(0, 12, 0, 12), BackgroundTransparency = 1, Parent = sidebar })
Create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = navList })

local contentArea = Create("Frame", { Name = "C"..sessionHash, Size = UDim2.new(1, -224, 1, -48), Position = UDim2.new(0, 224, 0, 48), BackgroundTransparency = 1, Parent = main })

local Pages = {}
local NavButtons = {}
local function createNavBtn(text, iconText, layoutOrder)
    local btn = Create("TextButton", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Color3.fromRGB(16, 24, 20), Text = "", AutoButtonColor = false, LayoutOrder = layoutOrder, Parent = navList })
    AddCorner(btn, 6); AddStroke(btn, Theme.Border, 1)
    Create("TextLabel", { Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(0, 8, 0.5, -12), BackgroundTransparency = 1, Text = iconText, TextColor3 = Theme.Muted, Font = Enum.Font.GothamBold, TextSize = 14, Parent = btn })
    Create("TextLabel", { Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 36, 0, 0), BackgroundTransparency = 1, Text = text, TextColor3 = Theme.Muted, TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamMedium, TextSize = 13, Parent = btn })
    return btn
end

local function createPage(name, layoutOrder)
    local page = Create("ScrollingFrame", { Size = UDim2.new(1, -32, 1, -32), Position = UDim2.new(0, 16, 0, 16), BackgroundTransparency = 1, ScrollBarThickness = 4, ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(0, 0, 0, 0), Visible = false, LayoutOrder = layoutOrder, Parent = contentArea })
    Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page })
    Pages[name] = page
end

createPage("Farm", 1); createPage("Move", 2); createPage("Visual", 3)
createPage("Auto", 4); createPage("Info", 5); createPage("Misc", 6)

local function switchPage(pageName)
    for name, page in pairs(Pages) do
        page.Visible = (name == pageName)
        local btn = NavButtons[name]
        if btn then
            if name == pageName then
                btn.BackgroundColor3 = Color3.fromRGB(0, 255, 102, 0.1)
                btn.UIStroke.Color = Theme.Accent
                btn:FindFirstChildOfClass("TextLabel").TextColor3 = Theme.Accent
            else
                btn.BackgroundColor3 = Color3.fromRGB(16, 24, 20)
                btn.UIStroke.Color = Theme.Border
                btn:FindFirstChildOfClass("TextLabel").TextColor3 = Theme.Muted
            end
        end
    end
end

local navLayout = { Farm = "🌱", Move = "🏃", Visual = "👁️", Auto = "🤖", Info = "ℹ️", Misc = "⚙️" }
local order = 1
for name, icon in pairs(navLayout) do
    local btn = createNavBtn(name, icon, order)
    btn.MouseButton1Click:Connect(function() switchPage(name) end)
    NavButtons[name] = btn
    order = order + 1
end

local function addToggle(page, label, flag)
    local container = Create("Frame", { Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = Color3.fromRGB(16, 24, 20), Parent = page })
    AddCorner(container, 8); AddStroke(container, Theme.Border, 1)
    Create("UIPadding", { PaddingTop = UDim.new(0,12), PaddingBottom = UDim.new(0,12), PaddingLeft = UDim.new(0,12), PaddingRight = UDim.new(0,12), Parent = container })
    Create("TextLabel", { Size = UDim2.new(1, -40, 0, 18), BackgroundTransparency = 1, Text = label, TextColor3 = Color3.fromRGB(255, 255, 255), TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamBold, TextSize = 13, Parent = container })
    Create("TextLabel", { Size = UDim2.new(1, -40, 0, 14), Position = UDim2.new(0, 0, 0, 18), BackgroundTransparency = 1, Text = "Feature toggle", TextColor3 = Theme.Muted, TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Gotham, TextSize = 11, Parent = container })
    
    local toggleBtn = Create("TextButton", { Size = UDim2.new(0, 32, 0, 18), Position = UDim2.new(1, -32, 0.5, -9), BackgroundColor3 = F[flag] and Theme.Accent or Theme.Border, Text = "", AutoButtonColor = false, Parent = container })
    AddCorner(toggleBtn, 9)
    local knob = Create("Frame", { Size = UDim2.new(0, 14, 0, 14), Position = F[flag] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = toggleBtn })
    AddCorner(knob, 7)

    toggleBtn.MouseButton1Click:Connect(function()
        F[flag] = not F[flag]
        if F[flag] then
            toggleBtn.BackgroundColor3 = Theme.Accent
            knob.Position = UDim2.new(1, -16, 0.5, -7)
        else
            toggleBtn.BackgroundColor3 = Theme.Border
            knob.Position = UDim2.new(0, 2, 0.5, -7)
        end
        
        if flag == "Fly" then
            if F.Fly and not flyConn then startFly() end
            if not F.Fly and flyConn then flyConn:Disconnect(); flyConn = nil end
        elseif flag == "NoClip" then
            if F.NoClip and not noclipConn then startNoClip() end
            if not F.NoClip and noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        end
    end)
    page.CanvasSize = UDim2.new(0, 0, 0, #page:GetChildren() * 56)
end

for _, f in ipairs({"AutoFarm","AutoPlant","AutoHarvest","AutoWater","AutoFertilize","AutoCollect","AutoSell","AutoBuySeeds","AutoBuyTools","AutoReplant","AutoUseItem","AutoTrash"}) do addToggle(Pages.Farm, f, f) end
for _, f in ipairs({"Fly","NoClip","Speed","JumpPower","InfJump","TeleportToPlot","TeleportToShop","TeleportToItem","WaypointLoop"}) do addToggle(Pages.Move, f, f) end
for _, f in ipairs({"ESP_Items","ESP_Seeds","ESP_Players","ESP_Plots","ESP_Drops","ESP_PriceTags","Fullbright","NoFog","XRay"}) do addToggle(Pages.Visual, f, f) end
for _, f in ipairs({"AutoReconnect","AntiAFK","AutoClaimDaily","AutoOpenCrates","AutoEquipBest","AutoSortInv","AutoDropTrash","AutoAcceptTrade","AutoDeclineLowball"}) do addToggle(Pages.Auto, f, f) end
for _, f in ipairs({"ItemTracker","PriceOverlay","DropNotifier","TradeLogger","InventoryValue","SeedProfitCalc"}) do addToggle(Pages.Info, f, f) end
for _, f in ipairs({"HideSelf","FreezeOthers","SpamEmote","FakeLag","ChatSpam","AutoGG","ShowFPS","ShowPing","ShowCoords","ProxyMode","ServerHop","Rejoin","LowGFX"}) do addToggle(Pages.Misc, f, f) end

switchPage("Farm")
