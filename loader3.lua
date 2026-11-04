--[[
  Growblox Hub v7 — Brute Force Interaction
  If ProximityPrompts aren't working, it's because this game uses ClickDetectors or RemoteEvents.
--]]

-- ============================================================
-- 0. CACHE BUSTER & CLEANUP
-- ============================================================
if getgenv().GrowbloxHubLoaded then pcall(function() getgenv().GrowbloxHubLoaded:Destroy() end) end
for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
    if gui.Name:find("GrowbloxHub") or gui.Name:find("GrowbloxV") then pcall(function() gui:Destroy() end) end
end
for _, gui in pairs(game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
    if gui.Name:find("GrowbloxHub") or gui.Name:find("GrowbloxV") then pcall(function() gui:Destroy() end) end
end

-- ============================================================
-- 1. EXECUTOR PRIMITIVES
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local function getGuiParent()
    if gethui then local ok, hui = pcall(gethui) if ok and hui then return hui end end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- ============================================================
-- 2. CONFIG & FEATURE FLAGS
-- ============================================================
local CFG = {
    FarmRadius = 100, -- Tightened for safety and speed
    LoopDelay = 0.1,
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
-- 3. THE REAL INTERACTION BRUTE-FORCE
-- ============================================================
local function bruteForceInteract(part)
    if not part then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    -- Layer 1: Fire all ClickDetectors
    local clickDetector = part:FindFirstChildWhichIsA("ClickDetector")
    if clickDetector then
        pcall(function() fireclickdetector(clickDetector) end)
        return -- If we found a click detector, assume it's the right one
    end

    -- Layer 2: Fire all ProximityPrompts
    for _, child in ipairs(part:GetChildren()) do
        if child:IsA("ProximityPrompt") then
            pcall(function()
                if fireproximityprompt then fireproximityprompt(child) else
                    child:InputHoldBegin() task.wait(0.05) child:InputHoldEnd()
                end
            end)
        end
    end

    -- Layer 3: Force-Fire RemoteEvents related to this part
    local name = part.Name:lower()
    if name:find("seed") or name:find("plant") or name:find("tree") or name:find("crop") or name:find("dirt") or name:find("tile") then
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local rName = remote.Name:lower()
                if rName:find("click") or rName:find("interact") or rName:find("place") or rName:find("harvest") or rName:find("water") or rName:find("plant") then
                    pcall(function() remote:FireServer(part.Position, part, 1) end)
                end
            end
        end
    end
end

-- ============================================================
-- 4. FARM LOOP (DIRECT PART SCAN)
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
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                -- Distance check
                if (part.Position - root.Position).Magnitude <= CFG.FarmRadius then
                    local name = part.Name:lower()
                    
                    -- Check if the part name matches common Growtopia clone items
                    local isTarget = false
                    if F.AutoFarm then isTarget = true end
                    if F.AutoHarvest and (name:find("tree") or name:find("crop") or name:find("fruit") or name:find("ready")) then isTarget = true end
                    if F.AutoWater and (name:find("water") or name:find("dirt") or name:find("soil")) then isTarget = true end
                    if F.AutoCollect and (name:find("drop") or name:find("gem") or name:find("item") or name:find("loot")) then isTarget = true end

                    if isTarget then
                        bruteForceInteract(part)
                    end
                end
            end
        end
    end

    -- Auto Plant (Spam Place Remote)
    if F.AutoPlant then
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") and remote.Name:lower():find("place") then
                pcall(function() remote:FireServer(1) end)
            end
        end
    end

    -- Auto Sell (Spam Sell Remote)
    if F.AutoSell then
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") and remote.Name:lower():find("sell") then
                pcall(function() remote:FireServer() end)
            end
        end
    end
end)

-- ============================================================
-- 5. MOVEMENT & ANTI-AFK
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
LocalPlayer.Idled:Connect(function()
    if F.AntiAFK then VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end
end)

-- ============================================================
-- 6. UI SYSTEM (TAILWIND LAYOUT)
-- ============================================================
local Theme = {
    Bg = Color3.fromRGB(10, 15, 13), Panel = Color3.fromRGB(16, 24, 20), Border = Color3.fromRGB(27, 46, 35),
    Accent = Color3.fromRGB(0, 255, 102), Text = Color3.fromRGB(220, 220, 220), Muted = Color3.fromRGB(107, 114, 128),
}

local function Create(className, props, children)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do inst[k] = v end
    for _, child in ipairs(children or {}) do child.Parent = inst end
    return inst
end

local gui = Create("ScreenGui", { Name = "GrowbloxHub_v7_"..tostring(math.random(1,99999)), ResetOnSpawn = false, Parent = getGuiParent() })
getgenv().GrowbloxHubLoaded = gui

local main = Create("Frame", { Name = "Main", Size = UDim2.new(0, 960, 0, 640), Position = UDim2.new(0.5, -480, 0.5, -320), BackgroundColor3 = Theme.Panel, BorderSizePixel = 0, Active = true, Draggable = true, Parent = gui })
Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = main })
Create("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = main })
Create("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Theme.Panel), ColorSequenceKeypoint.new(1, Theme.Bg) }), Rotation = 45, Parent = main })

local titleBar = Create("Frame", { Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = Color3.fromRGB(13, 21, 17), Parent = main })
Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = titleBar })
Create("Frame", { Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 1, -12), BackgroundColor3 = Color3.fromRGB(13, 21, 17), BorderSizePixel = 0, Parent = titleBar })
Create("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = Theme.Border, BorderSizePixel = 0, Parent = titleBar })
Create("Frame", { Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 16, 0.5, -6), BackgroundColor3 = Theme.Accent, Parent = titleBar }, { Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = _ }) })
Create("TextLabel", { Size = UDim2.new(0, 200, 1, 0), Position = UDim2.new(0, 36, 0, 0), BackgroundTransparency = 1, Text = "GROWBLOX HUB V7", TextColor3 = Color3.fromRGB(255, 255, 255), TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamBold, TextSize = 14, Parent = titleBar })

local sidebar = Create("Frame", { Size = UDim2.new(0, 224, 1, -48), Position = UDim2.new(0, 0, 0, 48), BackgroundColor3 = Color3.fromRGB(12, 18, 15), Parent = main })
Create("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BackgroundColor3 = Theme.Border, BorderSizePixel = 0, Parent = sidebar })
local navList = Create("Frame", { Size = UDim2.new(1, -24, 1, -24), Position = UDim2.new(0, 12, 0, 12), BackgroundTransparency = 1, Parent = sidebar })
Create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = navList })

local contentArea = Create("Frame", { Size = UDim2.new(1, -224, 1, -48), Position = UDim2.new(0, 224, 0, 48), BackgroundTransparency = 1, Parent = main })
local Pages = {}
local NavButtons = {}

local function createPage(name, layoutOrder)
    local page = Create("ScrollingFrame", { Size = UDim2.new(1, -32, 1, -32), Position = UDim2.new(0, 16, 0, 16), BackgroundTransparency = 1, ScrollBarThickness = 4, ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(0, 0, 0, 0), Visible = false, LayoutOrder = layoutOrder, Parent = contentArea })
    Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page })
    Pages[name] = page
end

local function createNavBtn(text, iconText, layoutOrder)
    local btn = Create("TextButton", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Color3.fromRGB(16, 24, 20), Text = "", AutoButtonColor = false, LayoutOrder = layoutOrder, Parent = navList })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
    local stroke = Create("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = btn })
    Create("TextLabel", { Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(0, 8, 0.5, -12), BackgroundTransparency = 1, Text = iconText, TextColor3 = Theme.Muted, Font = Enum.Font.GothamBold, TextSize = 14, Parent = btn })
    local label = Create("TextLabel", { Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 36, 0, 0), BackgroundTransparency = 1, Text = text, TextColor3 = Theme.Muted, TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamMedium, TextSize = 13, Parent = btn })
    return btn, label, stroke
end

local function switchPage(pageName)
    for name, page in pairs(Pages) do
        page.Visible = (name == pageName)
        local btn = NavButtons[name]
        if btn then
            if name == pageName then
                btn.Btn.BackgroundColor3 = Color3.fromRGB(0, 255, 102, 0.1)
                btn.UIStroke.Color = Theme.Accent
                btn.TextLabel.TextColor3 = Theme.Accent
            else
                btn.Btn.BackgroundColor3 = Color3.fromRGB(16, 24, 20)
                btn.UIStroke.Color = Theme.Border
                btn.TextLabel.TextColor3 = Theme.Muted
            end
        end
    end
end

local navLayout = { Farm = "🌱", Move = "🏃", Visual = "👁️", Auto = "🤖", Info = "ℹ️", Misc = "⚙️" }
local order = 1
for name, icon in pairs(navLayout) do
    createPage(name, order)
    local btn, label, stroke = createNavBtn(name, icon, order)
    btn.MouseButton1Click:Connect(function() switchPage(name) end)
    NavButtons[name] = { Btn = btn, TextLabel = label, UIStroke = stroke }
    order = order + 1
end

local function addToggle(page, label, flag)
    local container = Create("Frame", { Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = Color3.fromRGB(16, 24, 20), Parent = page })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = container })
    Create("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = container })
    Create("UIPadding", { PaddingTop = UDim.new(0,12), PaddingBottom = UDim.new(0,12), PaddingLeft = UDim.new(0,12), PaddingRight = UDim.new(0,12), Parent = container })
    Create("TextLabel", { Size = UDim2.new(1, -40, 0, 18), BackgroundTransparency = 1, Text = label, TextColor3 = Color3.fromRGB(255, 255, 255), TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamBold, TextSize = 13, Parent = container })
    Create("TextLabel", { Size = UDim2.new(1, -40, 0, 14), Position = UDim2.new(0, 0, 0, 18), BackgroundTransparency = 1, Text = "Feature toggle", TextColor3 = Theme.Muted, TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Gotham, TextSize = 11, Parent = container })

    local toggleBtn = Create("TextButton", { Size = UDim2.new(0, 32, 0, 18), Position = UDim2.new(1, -32, 0.5, -9), BackgroundColor3 = F[flag] and Theme.Accent or Theme.Border, Text = "", AutoButtonColor = false, Parent = container })
    Create("UICorner", { CornerRadius = UDim.new(0, 9), Parent = toggleBtn })
    local knob = Create("Frame", { Size = UDim2.new(0, 14, 0, 14), Position = F[flag] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = toggleBtn })
    Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = knob })

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
