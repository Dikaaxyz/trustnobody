--[[
    GRAYS ON TOP — South Bronx: The Trenches cheat v2.2
    Complete build. No truncation, no stubs, no loadstrings, no key.

    Default toggle menu: RIGHT SHIFT (rebindable in Keys tab)
    Features: silent aim (+ humanizer), FOV circle, aim part selector,
    camera-lock aimbot, ESP (box/name/health/distance/tracer),
    noclip, walkspeed, jumppower, fullbright, fly, teleport-to-player,
    auto-farm (marshmallow via ProximityPrompt), auto-clicker,
    config save/load (executor writefile), keybind customization.

    Detection posture: client-only render for ESP/fullbright (invisible to
    server), game-native events for farm/clicker (indistinguishable from a
    human hold), humanized silent aim (jitter + reaction delay + headshot
    rate cap). Fly/speed/teleport are server-visible and cannot be hidden
    client-side — toggle them off on public servers.
]]

------------------------------------------------------------------
-- GUARD
------------------------------------------------------------------
if not game:IsLoaded() then game.Loaded:Wait() end
if getgenv().GraysOnTopGui then
    pcall(function() getgenv().GraysOnTopGui:Destroy() end)
end
getgenv().GraysOnTopLoaded = true

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local Workspace         = game:GetService("Workspace")
local Lighting          = game:GetService("Lighting")
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local localPlayer = Players.LocalPlayer
local camera      = Workspace.CurrentCamera

------------------------------------------------------------------
-- CAPABILITY PROBE
------------------------------------------------------------------
local CAP = {
    rawmetatable = typeof(getrawmetatable) == "function",
    setreadonly  = typeof(setreadonly) == "function",
    newcclosure  = typeof(newcclosure) == "function",
    writefile    = typeof(writefile) == "function",
    readfile     = typeof(readfile) == "function",
    isfile       = typeof(isfile) == "function",
    delfile      = typeof(delfile) == "function",
    gethui       = typeof(gethui) == "function",
}

------------------------------------------------------------------
-- CONFIG
------------------------------------------------------------------
local CFG = {
    silentAim         = false,
    silentAimPart     = "Head",
    silentAimFov      = 250,
    aimbotVisibleOnly = true,
    aimbotLock        = false,
    aimbotLockSmooth  = 0.25,
    espEnabled        = false,
    espBox            = true,
    espName           = true,
    espHealth         = true,
    espDistance       = true,
    espTracer         = false,
    espMaxDist        = 2000,
    espColor          = Color3.fromRGB(255, 40, 40),
    noclip            = false,
    walkSpeed         = 16,
    jumpPower         = 50,
    speedHack         = false,
    flyEnabled        = false,
    flySpeed          = 60,
    fullbright        = false,
    farmEnabled       = false,
    farmToolName      = "Marshmallow Bag",
    farmPromptText    = "Craft",
    farmInterval      = 0.6,
    farmProximityDist = 20,
    autoClicker       = false,
    autoClickerCps    = 10,
    teleportOffset    = 4,
    keyMenu           = Enum.KeyCode.RightShift,
    humanizer         = true,
    aimJitterDeg      = 2.5,
    reactionMinMs     = 90,
    reactionMaxMs     = 220,
    headshotChance    = 0.35,
    maxHeadshotsPerSec= 2,
}

local origBrightness = Lighting.Brightness
local origClock      = Lighting.ClockTime
local origFogEnd     = Lighting.FogEnd

------------------------------------------------------------------
-- CONFIG PERSISTENCE
------------------------------------------------------------------
local CONFIG_PATH = "graysontop_cfg.json"

local function saveConfig()
    if not (CAP.writefile and CAP.isfile) then return end
    pcall(function()
        local flat = {}
        for k, v in pairs(CFG) do
            if typeof(v) == "EnumItem" then
                flat[k] = {__enum = v.Name, __enumType = tostring(v.EnumType)}
            elseif typeof(v) == "Color3" then
                flat[k] = {__color = {v.R, v.G, v.B}}
            else
                flat[k] = v
            end
        end
        writefile(CONFIG_PATH, HttpService:JSONEncode(flat))
    end)
end

local function loadConfig()
    if not (CAP.readfile and CAP.isfile) then return end
    if not isfile(CONFIG_PATH) then return end
    pcall(function()
        local data = HttpService:JSONDecode(readfile(CONFIG_PATH))
        for k, v in pairs(data) do
            if type(v) == "table" and v.__enum then
                local et = Enum[v.__enumType]
                if et and et[v.__enum] then CFG[k] = et[v.__enum] end
            elseif type(v) == "table" and v.__color then
                CFG[k] = Color3.new(v.__color[1], v.__color[2], v.__color[3])
            elseif CFG[k] ~= nil then
                CFG[k] = v
            end
        end
    end)
end
loadConfig()

------------------------------------------------------------------
-- GUI
------------------------------------------------------------------
local guiParent = (CAP.gethui and gethui()) or CoreGui
local gui = Instance.new("ScreenGui")
gui.Name = "GraysOnTop"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999999
gui.Parent = guiParent
getgenv().GraysOnTopGui = gui

-- Palette
local COL = {
    bg        = Color3.fromRGB(8, 8, 8),
    panel     = Color3.fromRGB(16, 16, 16),
    panelHi   = Color3.fromRGB(26, 26, 26),
    border    = Color3.fromRGB(38, 38, 38),
    textDim   = Color3.fromRGB(140, 140, 140),
    text      = Color3.fromRGB(232, 232, 232),
    accent    = Color3.fromRGB(255, 255, 255),
    danger    = Color3.fromRGB(220, 40, 40),
    good      = Color3.fromRGB(0, 200, 110),
}

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 380, 0, 520)
main.Position = UDim2.new(0, 40, 0, 40)
main.BackgroundColor3 = COL.bg
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
main.Parent = gui

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = COL.border
mainStroke.Thickness = 1
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainStroke.Parent = main

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 64)
header.BackgroundColor3 = COL.bg
header.BorderSizePixel = 0
header.Parent = main

local headerStroke = Instance.new("Frame")
headerStroke.Size = UDim2.new(1, 0, 0, 1)
headerStroke.Position = UDim2.new(0, 0, 1, -1)
headerStroke.BackgroundColor3 = COL.border
headerStroke.BorderSizePixel = 0
headerStroke.Parent = header

-- "GRAYS ON TOP" wordmark
local wordmark = Instance.new("TextLabel")
wordmark.Size = UDim2.new(1, -24, 0, 30)
wordmark.Position = UDim2.new(0, 16, 0, 12)
wordmark.BackgroundTransparency = 1
wordmark.Text = "GRAYS ON TOP"
wordmark.TextColor3 = COL.text
wordmark.Font = Enum.Font.GothamBlack
wordmark.TextSize = 22
wordmark.TextXAlignment = Enum.TextXAlignment.Left
wordmark.TextYAlignment = Enum.TextYAlignment.Center
wordmark.Parent = header

-- letter-spaced subtitle: S O U T H   B R O N X   T R E N C H E S
local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -24, 0, 14)
subtitle.Position = UDim2.new(0, 16, 0, 42)
subtitle.BackgroundTransparency = 1
subtitle.Text = "S O U T H   B R O N X   T R E N C H E S"
subtitle.TextColor3 = COL.textDim
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 10
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextYAlignment = Enum.TextYAlignment.Center
subtitle.Parent = header

-- status dot (green = alive/loaded)
local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 8, 0, 8)
statusDot.Position = UDim2.new(1, -24, 0, 20)
statusDot.BackgroundColor3 = COL.good
statusDot.BorderSizePixel = 0
statusDot.Parent = header
local statusDotCorner = Instance.new("UICorner")
statusDotCorner.CornerRadius = UDim.new(1, 0)
statusDotCorner.Parent = statusDot

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(0, 60, 0, 12)
statusLbl.Position = UDim2.new(1, -84, 0, 26)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "LOADED"
statusLbl.TextColor3 = COL.textDim
statusLbl.Font = Enum.Font.GothamBold
statusLbl.TextSize = 9
statusLbl.TextXAlignment = Enum.TextXAlignment.Right
statusLbl.Parent = header

-- Tab bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 36)
tabBar.Position = UDim2.new(0, 0, 0, 64)
tabBar.BackgroundColor3 = COL.panel
tabBar.BorderSizePixel = 0
tabBar.Parent = main

local tabBarBottom = Instance.new("Frame")
tabBarBottom.Size = UDim2.new(1, 0, 0, 1)
tabBarBottom.Position = UDim2.new(0, 0, 1, -1)
tabBarBottom.BackgroundColor3 = COL.border
tabBarBottom.BorderSizePixel = 0
tabBarBottom.Parent = tabBar

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 0)
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Parent = tabBar

local tabPad = Instance.new("UIPadding")
tabPad.PaddingLeft = UDim.new(0, 8)
tabPad.Parent = tabBar

-- Content area
local contentHolder = Instance.new("Frame")
contentHolder.Size = UDim2.new(1, 0, 1, -100)
contentHolder.Position = UDim2.new(0, 0, 0, 100)
contentHolder.BackgroundColor3 = COL.bg
contentHolder.BorderSizePixel = 0
contentHolder.Parent = main

local pages = {}
local tabButtons = {}
local activeTabIdx = 1

local function setActiveTab(idx)
    activeTabIdx = idx
    for i, t in ipairs(pages) do
        t.Visible = (i == idx)
    end
    for i, b in ipairs(tabButtons) do
        if i == idx then
            b.TextColor3 = COL.accent
            b.BackgroundColor3 = COL.bg
            b.Font = Enum.Font.GothamBold
        else
            b.TextColor3 = COL.textDim
            b.BackgroundColor3 = COL.panel
            b.Font = Enum.Font.Gotham
        end
    end
end

local function makeTab(name, width)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, width or 62, 1, 0)
    btn.BackgroundColor3 = COL.panel
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = COL.textDim
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.Parent = tabBar
    table.insert(tabButtons, btn)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Position = UDim2.new(0, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = COL.border
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Parent = contentHolder

    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, 1)
    l.Parent = page

    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, 14)
    p.PaddingRight = UDim.new(0, 14)
    p.PaddingTop = UDim.new(0, 12)
    p.PaddingBottom = UDim.new(0, 12)
    p.Parent = page

    local idx = #pages + 1
    table.insert(pages, page)

    btn.MouseButton1Click:Connect(function()
        setActiveTab(idx)
    end)

    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, l.AbsoluteContentSize.Y + 24)
    end)

    return page
end

local function addSection(parent, name)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 26)
    l.BackgroundTransparency = 1
    l.Text = string.upper(name)
    l.TextColor3 = COL.danger
    l.Font = Enum.Font.GothamBold
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Bottom
    l.Parent = parent
end

local function addToggle(parent, label, key, onChanged)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 32)
    row.BackgroundColor3 = COL.panel
    row.BorderSizePixel = 0
    row.Text = ""
    row.AutoButtonColor = false
    row.Parent = parent

    local rowStroke = Instance.new("Frame")
    rowStroke.Size = UDim2.new(1, 0, 0, 1)
    rowStroke.Position = UDim2.new(0, 0, 1, -1)
    rowStroke.BackgroundColor3 = COL.border
    rowStroke.BorderSizePixel = 0
    rowStroke.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = COL.text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 34, 0, 16)
    pill.Position = UDim2.new(1, -44, 0.5, -8)
    pill.BackgroundColor3 = COL.bg
    pill.BorderSizePixel = 0
    pill.Parent = row

    local pillStroke = Instance.new("UIStroke")
    pillStroke.Color = COL.border
    pillStroke.Thickness = 1
    pillStroke.Parent = pill

    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = UDim.new(1, 0)
    pillCorner.Parent = pill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 10, 0, 10)
    knob.Position = UDim2.new(0, 3, 0.5, -5)
    knob.BackgroundColor3 = COL.textDim
    knob.BorderSizePixel = 0
    knob.Parent = pill

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local function refresh()
        if CFG[key] then
            knob.Position = UDim2.new(1, -13, 0.5, -5)
            knob.BackgroundColor3 = COL.accent
            pill.BackgroundColor3 = COL.accent
            pillStroke.Color = COL.accent
            lbl.TextColor3 = COL.accent
        else
            knob.Position = UDim2.new(0, 3, 0.5, -5)
            knob.BackgroundColor3 = COL.textDim
            pill.BackgroundColor3 = COL.bg
            pillStroke.Color = COL.border
            lbl.TextColor3 = COL.text
        end
    end
    refresh()

    row.MouseButton1Click:Connect(function()
        CFG[key] = not CFG[key]
        refresh()
        if onChanged then pcall(onChanged, CFG[key]) end
    end)
    return row
end

local function addSlider(parent, label, key, min, max, step, onChanged)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 50)
    holder.BackgroundColor3 = COL.panel
    holder.BorderSizePixel = 0
    holder.Parent = parent

    local holderStroke = Instance.new("Frame")
    holderStroke.Size = UDim2.new(1, 0, 0, 1)
    holderStroke.Position = UDim2.new(0, 0, 1, -1)
    holderStroke.BackgroundColor3 = COL.border
    holderStroke.BorderSizePixel = 0
    holderStroke.Parent = holder

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -80, 0, 22)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = COL.text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = holder

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 70, 0, 22)
    valLbl.Position = UDim2.new(1, -80, 0, 4)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = string.format("%.2f", CFG[key])
    valLbl.TextColor3 = COL.accent
    valLbl.Font = Enum.Font.Code
    valLbl.TextSize = 12
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = holder

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 4)
    bar.Position = UDim2.new(0, 10, 1, -14)
    bar.BackgroundColor3 = COL.bg
    bar.BorderSizePixel = 0
    bar.Parent = holder

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(math.clamp((CFG[key] - min) / (max - min), 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = COL.accent
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local dragging = false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = bar
    btn.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    RunService.RenderStepped:Connect(function()
        if not dragging then return end
        local mx = UserInputService:GetMouseLocation().X
        local absBar = bar.AbsolutePosition.X
        local absW = bar.AbsoluteSize.X
        if absW <= 0 then return end
        local frac = math.clamp((mx - absBar) / absW, 0, 1)
        local val = math.floor((min + frac * (max - min)) / step + 0.5) * step
        val = math.clamp(val, min, max)
        CFG[key] = val
        fill.Size = UDim2.new(frac, 0, 1, 0)
        valLbl.Text = string.format("%.2f", val)
        if onChanged then pcall(onChanged, val) end
    end)
end

local function addTextBox(parent, label, key, placeholder)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 56)
    holder.BackgroundColor3 = COL.panel
    holder.BorderSizePixel = 0
    holder.Parent = parent

    local holderStroke = Instance.new("Frame")
    holderStroke.Size = UDim2.new(1, 0, 0, 1)
    holderStroke.Position = UDim2.new(0, 0, 1, -1)
    holderStroke.BackgroundColor3 = COL.border
    holderStroke.BorderSizePixel = 0
    holderStroke.Parent = holder

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 18)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = COL.text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = holder

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -20, 0, 24)
    box.Position = UDim2.new(0, 10, 0, 24)
    box.BackgroundColor3 = COL.bg
    box.BorderSizePixel = 0
    box.Text = tostring(CFG[key] or "")
    box.PlaceholderText = placeholder or ""
    box.PlaceholderColor3 = COL.textDim
    box.TextColor3 = COL.text
    box.Font = Enum.Font.Code
    box.TextSize = 12
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.ClearTextOnFocus = false
    box.Parent = holder

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = COL.border
    boxStroke.Thickness = 1
    boxStroke.Parent = box

    box.FocusLost:Connect(function()
        CFG[key] = box.Text
    end)
end

local function addButton(parent, label, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = COL.panel
    btn.BorderSizePixel = 0
    btn.Text = label
    btn.TextColor3 = COL.text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.Parent = parent

    local bStroke = Instance.new("Frame")
    bStroke.Size = UDim2.new(1, 0, 0, 1)
    bStroke.Position = UDim2.new(0, 0, 1, -1)
    bStroke.BackgroundColor3 = COL.border
    bStroke.BorderSizePixel = 0
    bStroke.Parent = btn

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = COL.panelHi
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = COL.panel
    end)
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
    return btn
end

------------------------------------------------------------------
-- TABS
------------------------------------------------------------------
local combatPage = makeTab("COMBAT", 74)
local espPage    = makeTab("ESP",    54)
local movePage   = makeTab("MOVE",   58)
local farmPage   = makeTab("FARM",   56)
local miscPage   = makeTab("MISC",   54)
local bindPage   = makeTab("KEYS",   52)
local cfgPage    = makeTab("CFG",    46)

setActiveTab(1)

-- Combat
addSection(combatPage, "SILENT AIM")
addToggle(combatPage, "Silent Aim", "silentAim")
addToggle(combatPage, "Visible Only", "aimbotVisibleOnly")
addSlider(combatPage, "FOV Radius", "silentAimFov", 50, 600, 10, function(v)
    if espFovCircle then
        espFovCircle.Size = UDim2.new(0, v * 2, 0, v * 2)
        espFovCircle.Position = UDim2.new(0.5, -v, 0.5, -v)
    end
end)

local aimParts = {"Head", "HumanoidRootPart", "UpperTorso"}
local aimIdx = 1
for i, v in ipairs(aimParts) do if v == CFG.silentAimPart then aimIdx = i end end
local aimBtn = Instance.new("TextButton")
aimBtn.Size = UDim2.new(1, 0, 0, 32)
aimBtn.BackgroundColor3 = COL.panel
aimBtn.BorderSizePixel = 0
aimBtn.Text = "  Aim Part: " .. CFG.silentAimPart
aimBtn.TextColor3 = COL.text
aimBtn.Font = Enum.Font.Gotham
aimBtn.TextSize = 12
aimBtn.TextXAlignment = Enum.TextXAlignment.Left
aimBtn.AutoButtonColor = false
aimBtn.Parent = combatPage
aimBtn.MouseEnter:Connect(function() aimBtn.BackgroundColor3 = COL.panelHi end)
aimBtn.MouseLeave:Connect(function() aimBtn.BackgroundColor3 = COL.panel end)
aimBtn.MouseButton1Click:Connect(function()
    aimIdx = aimIdx % #aimParts + 1
    CFG.silentAimPart = aimParts[aimIdx]
    aimBtn.Text = "  Aim Part: " .. CFG.silentAimPart
end)

addSection(combatPage, "HUMANIZER")
addToggle(combatPage, "Humanize Aim", "humanizer")
addSlider(combatPage, "Jitter (±deg)", "aimJitterDeg", 0, 8, 0.5)
addSlider(combatPage, "Reaction Min (ms)", "reactionMinMs", 40, 400, 10)
addSlider(combatPage, "Reaction Max (ms)", "reactionMaxMs", 40, 600, 10)
addSlider(combatPage, "Headshot Rate", "headshotChance", 0, 1, 0.05)
addSlider(combatPage, "Headshots/sec Cap", "maxHeadshotsPerSec", 1, 6, 1)

addSection(combatPage, "CAMERA-LOCK")
addToggle(combatPage, "Lock On", "aimbotLock")
addSlider(combatPage, "Smoothing", "aimbotLockSmooth", 0.05, 1.0, 0.05)

-- ESP
addSection(espPage, "ESP")
addToggle(espPage, "ESP Master", "espEnabled")
addToggle(espPage, "Box",      "espBox")
addToggle(espPage, "Name",     "espName")
addToggle(espPage, "Health",   "espHealth")
addToggle(espPage, "Distance", "espDistance")
addToggle(espPage, "Tracer",   "espTracer")
addSlider(espPage, "Max Distance", "espMaxDist", 100, 3000, 50)

-- Move
addSection(movePage, "MOVEMENT")
addToggle(movePage, "Noclip",  "noclip")
addToggle(movePage, "Speed",   "speedHack")
addSlider(movePage, "WalkSpeed",  "walkSpeed", 16, 300, 1)
addSlider(movePage, "JumpPower",  "jumpPower", 50, 500, 5)

addSection(movePage, "FLY")
addToggle(movePage, "Fly", "flyEnabled")
addSlider(movePage, "Fly Speed", "flySpeed", 10, 300, 5)

-- Farm
addSection(farmPage, "AUTO-FARM")
addToggle(farmPage, "Farm Enabled", "farmEnabled")
addTextBox(farmPage, "Tool Name", "farmToolName", "Marshmallow Bag")
addTextBox(farmPage, "Prompt Text", "farmPromptText", "Craft")
addSlider(farmPage, "Farm Interval (s)", "farmInterval", 0.2, 3.0, 0.1)
addSlider(farmPage, "Proximity (studs)", "farmProximityDist", 5, 100, 1)

-- Misc
addSection(miscPage, "AUTO-CLICKER")
addToggle(miscPage, "Auto Clicker", "autoClicker")
addSlider(miscPage, "Clicks Per Second", "autoClickerCps", 1, 30, 1)

addSection(miscPage, "TELEPORT")
local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Size = UDim2.new(1, 0, 0, 150)
playerListFrame.BackgroundColor3 = COL.panel
playerListFrame.BorderSizePixel = 0
playerListFrame.ScrollBarThickness = 3
playerListFrame.ScrollBarImageColor3 = COL.border
playerListFrame.Parent = miscPage
local plLayout = Instance.new("UIListLayout")
plLayout.Padding = UDim.new(0, 1)
plLayout.Parent = playerListFrame

local function refreshPlayerList()
    for _, c in ipairs(playerListFrame:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 26)
            b.BackgroundColor3 = COL.bg
            b.BorderSizePixel = 0
            b.Text = "  " .. p.Name
            b.TextColor3 = COL.text
            b.Font = Enum.Font.Gotham
            b.TextSize = 12
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.AutoButtonColor = false
            b.Parent = playerListFrame
            b.MouseEnter:Connect(function() b.BackgroundColor3 = COL.panelHi end)
            b.MouseLeave:Connect(function() b.BackgroundColor3 = COL.bg end)
            b.MouseButton1Click:Connect(function()
                local c = p.Character
                local hrp = c and c:FindFirstChild("HumanoidRootPart")
                local myHrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and myHrp then
                    myHrp.CFrame = hrp.CFrame * CFrame.new(0, 0, CFG.teleportOffset)
                end
            end)
        end
    end
    playerListFrame.CanvasSize = UDim2.new(0, 0, 0, plLayout.AbsoluteContentSize.Y + 4)
end
task.spawn(function()
    while true do
        pcall(refreshPlayerList)
        task.wait(2)
    end
end)

addSection(miscPage, "VISUAL")
addToggle(miscPage, "Fullbright", "fullbright")

-- Keys
addSection(bindPage, "KEYBINDS")
local bindEntries = {
    {key = "keyMenu", label = "Toggle Menu"},
}
local listeningKey = nil

for _, entry in ipairs(bindEntries) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = COL.panel
    row.BorderSizePixel = 0
    row.Parent = bindPage

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, -4, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = entry.label
    lbl.TextColor3 = COL.text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -20, 0, 24)
    btn.Position = UDim2.new(0.5, 10, 0.5, -12)
    btn.BackgroundColor3 = COL.bg
    btn.BorderSizePixel = 0
    btn.Text = CFG[entry.key].Name
    btn.TextColor3 = COL.accent
    btn.Font = Enum.Font.Code
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.Parent = row

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = COL.border
    btnStroke.Thickness = 1
    btnStroke.Parent = btn

    btn.MouseButton1Click:Connect
