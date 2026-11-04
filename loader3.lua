--[[
  Growblox Hub v10 — Absolute Fix
  Engine: Roblox Luau
  Features: Highlight ESP, ContextActionService RightShift Minimize, ClickDetector Farm.
--]]

-- ============================================================
-- 0. NUCLEAR CACHE BUSTER
-- ============================================================
local function destroyOldHubs()
    local CoreGui = game:GetService("CoreGui")
    local PlayerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    for _, parent in ipairs({CoreGui, PlayerGui}) do
        if parent then
            for _, gui in ipairs(parent:GetChildren()) do
                if gui.Name:find("GrowbloxHub") or gui.Name:find("GrowbloxV") or gui.Name:find("Growblox") then
                    pcall(function() gui:Destroy() end)
                end
            end
        end
    end
end
destroyOldHubs()

-- ============================================================
-- 1. EXECUTOR PRIMITIVES
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local ContextActionService = game:GetService("ContextActionService")
local LocalPlayer = Players.LocalPlayer

local function getGuiParent()
    if gethui then local ok, hui = pcall(gethui) if ok and hui then return hui end end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- ============================================================
-- 2. FEATURE FLAGS
-- ============================================================
local F = {
    AutoFarm=false, AutoPlant=false, AutoCollect=false, AutoSell=false,
    ESP_Blocks=false, ESP_Drops=false, ESP_Players=false,
    AntiAFK=false, Fullbright=false,
}

-- ============================================================
-- 3. THE REAL FARM LOGIC (CLICKDETECTOR & TOOLS)
-- ============================================================
local function equipTool(keyword)
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not char then return nil end
    
    local equipped = char:FindFirstChildWhichIsA("Tool")
    if equipped and equipped.Name:lower():find(keyword) then return equipped end
    
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find(keyword) then
                tool.Parent = char
                task.wait(0.1)
                return tool
            end
        end
    end
    return equipped or (char and char:FindFirstChildWhichIsA("Tool"))
end

local function interactPart(part)
    if not part then return end
    -- 1. Fire ClickDetector
    local cd = part:FindFirstChildWhichIsA("ClickDetector")
    if cd then
        pcall(function() fireclickdetector(cd) end)
        return
    end
    -- 2. Fire ProximityPrompt
    local prompt = part:FindFirstChildWhichIsA("ProximityPrompt")
    if prompt then
        pcall(function()
            if fireproximityprompt then fireproximityprompt(prompt) else
                prompt:InputHoldBegin() task.wait(0.05) prompt:InputHoldEnd()
            end
        end)
        return
    end
end

-- ============================================================
-- 4. REAL ESP (HIGHLIGHT & BILLBOARD)
-- ============================================================
local espCache = {}

local function addHighlight(part, color, name)
    if espCache[part] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "GrowESP"
    highlight.Adornee = part
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = part

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.Adornee = part
    billboard.Parent = part
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = billboard

    espCache[part] = {highlight = highlight, billboard = billboard}
end

local function clearESP()
    for part, data in pairs(espCache) do
        if data.highlight then data.highlight:Destroy() end
        if data.billboard then data.billboard:Destroy() end
    end
    espCache = {}
end

-- ============================================================
-- 5. MAIN LOOPS (ESP & FARM)
-- ============================================================
RunService.RenderStepped:Connect(function()
    if not (F.ESP_Blocks or F.ESP_Drops or F.ESP_Players) then
        if next(espCache) then clearESP() end
        return
    end

    if F.ESP_Blocks or F.ESP_Drops then
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and not espCache[part] then
                local n = part.Name:lower()
                if F.ESP_Blocks and (n:find("tree") or n:find("block") or n:find("dirt") or n:find("rock") or n:find("crop")) then
                    addHighlight(part, Color3.fromRGB(0, 255, 102), part.Name)
                elseif F.ESP_Drops and (n:find("drop") or n:find("gem") or n:find("seed") or n:find("item")) then
                    addHighlight(part, Color3.fromRGB(255, 200, 50), part.Name)
                end
            end
        end
    end

    if F.ESP_Players then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp and not espCache[hrp] then
                    addHighlight(hrp, Color3.fromRGB(255, 50, 50), player.Name)
                end
            end
        end
    end
end)

local farmTick = 0
RunService.Heartbeat:Connect(function(dt)
    farmTick += dt
    if farmTick < 0.15 then return end
    farmTick = 0
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if F.AutoFarm then
        equipTool("pick") 
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and (part.Position - root.Position).Magnitude <= 80 then
                local n = part.Name:lower()
                if n:find("block") or n:find("tree") or n:find("rock") then
                    interactPart(part)
                end
            end
        end
    end

    if F.AutoPlant then
        equipTool("seed")
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and (part.Position - root.Position).Magnitude <= 80 then
                local n = part.Name:lower()
                if n:find("dirt") or n:find("soil") or n:find("plot") then
                    interactPart(part)
                end
            end
        end
    end

    if F.AutoCollect then
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and (part.Position - root.Position).Magnitude <= 150 then
                local n = part.Name:lower()
                if n:find("drop") or n:find("gem") or n:find("collectable") then
                    root.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                end
            end
        end
    end
end)

-- ============================================================
-- 6. UI SYSTEM
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

local gui = Create("ScreenGui", { Name = "GrowbloxHub_v10_"..tostring(math.random(1,99999)), ResetOnSpawn = false, Parent = getGuiParent() })

local main = Create("Frame", { Name = "Main", Size = UDim2.new(0, 960, 0, 640), Position = UDim2.new(0.5, -480, 0.5, -320), BackgroundColor3 = Theme.Panel, BorderSizePixel = 0, Active = true, Draggable = true, Parent = gui })
Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = main })
Create("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = main })

local titleBar = Create("Frame", { Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = Color3.fromRGB(13, 21, 17), Parent = main })
Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = titleBar })
Create("Frame", { Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 1, -12), BackgroundColor3 = Color3.fromRGB(13, 21, 17), BorderSizePixel = 0, Parent = titleBar })
Create("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = Theme.Border, BorderSizePixel = 0, Parent = titleBar })
Create("Frame", { Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 16, 0.5, -6), BackgroundColor3 = Theme.Accent, Parent = titleBar }, { Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = _ }) })
Create("TextLabel", { Size = UDim2.new(0, 200, 1, 0), Position = UDim2.new(0, 36, 0, 0), BackgroundTransparency = 1, Text = "GROWBLOX HUB V10", TextColor3 = Color3.fromRGB(255, 255, 255), TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamBold, TextSize = 14, Parent = titleBar })

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

local navLayout = { Farm = "🌱", Visual = "👁️", Misc = "⚙️" }
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
    end)
    page.CanvasSize = UDim2.new(0, 0, 0, #page:GetChildren() * 56)
end

for _, f in ipairs({"AutoFarm","AutoPlant","AutoCollect","AutoSell"}) do addToggle(Pages.Farm, f, f) end
for _, f in ipairs({"ESP_Blocks","ESP_Drops","ESP_Players"}) do addToggle(Pages.Visual, f, f) end
for _, f in ipairs({"AntiAFK","Fullbright"}) do addToggle(Pages.Misc, f, f) end

switchPage("Farm")

-- ============================================================
-- 7. RIGHT SHIFT MINIMIZE (CONTEXT ACTION SERVICE)
-- ============================================================
local isMinimized = false
local minBtn

local function toggleMinimize()
    isMinimized = not isMinimized
    if isMinimized then
        main.Visible = false
        minBtn = Create("TextButton", { Name = "MinBtn", Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0, 20, 0.5, -20), BackgroundColor3 = Theme.Accent, Text = "V10", TextColor3 = Theme.Bg, Font = Enum.Font.GothamBold, TextSize = 14, Parent = gui })
        Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = minBtn })
        minBtn.MouseButton1Click:Connect(function()
            main.Visible = true
            if minBtn then minBtn:Destroy() end
            isMinimized = false
        end)
    else
        main.Visible = true
        if minBtn then minBtn:Destroy() end
    end
end

ContextActionService:BindAction("GrowbloxMinimize", function(_, state)
    if state == Enum.UserInputState.Begin then
        toggleMinimize()
    end
end, false, Enum.KeyCode.RightShift)
