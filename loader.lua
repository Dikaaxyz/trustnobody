-- GRAYS ON TOP body — GUI + engines
local GOT = getgenv().GOT
local Players, RunService, UserInputService = GOT.Players, GOT.RunService, GOT.UIS
local Workspace, Lighting, CoreGui = GOT.WS, GOT.Lighting, GOT.CoreGui or game:GetService("CoreGui")
local HttpService, VirtualInputManager = GOT.Http, GOT.VIM
local localPlayer, camera = GOT.localPlayer, GOT.camera
local CAP, CFG = GOT.CAP, GOT.CFG

local guiParent = (CAP.gethui and gethui()) or CoreGui
local gui = Instance.new("ScreenGui")
gui.Name = "GraysOnTop"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999999
gui.Parent = guiParent
getgenv().GraysOnTopGui = gui

local COL = {
    bg=Color3.fromRGB(8,8,8), panel=Color3.fromRGB(16,16,16),
    panelHi=Color3.fromRGB(26,26,26), border=Color3.fromRGB(38,38,38),
    textDim=Color3.fromRGB(140,140,140), text=Color3.fromRGB(232,232,232),
    accent=Color3.fromRGB(255,255,255), danger=Color3.fromRGB(220,40,40),
    good=Color3.fromRGB(0,200,110),
}

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 380, 0, 520)
main.Position = UDim2.new(0, 40, 0, 40)
main.BackgroundColor3 = COL.bg
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
main.Parent = gui

local ms = Instance.new("UIStroke")
ms.Color, ms.Thickness = COL.border, 1
ms.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ms.Parent = main

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 64)
header.BackgroundColor3 = COL.bg
header.BorderSizePixel = 0
header.Parent = main

local hs = Instance.new("Frame")
hs.Size = UDim2.new(1, 0, 0, 1)
hs.Position = UDim2.new(0, 0, 1, -1)
hs.BackgroundColor3 = COL.border
hs.BorderSizePixel = 0
hs.Parent = header

local wordmark = Instance.new("TextLabel")
wordmark.Size = UDim2.new(1, -24, 0, 30)
wordmark.Position = UDim2.new(0, 16, 0, 12)
wordmark.BackgroundTransparency = 1
wordmark.Text = "GRAYS ON TOP"
wordmark.TextColor3 = COL.text
wordmark.Font = Enum.Font.GothamBlack
wordmark.TextSize = 22
wordmark.TextXAlignment = Enum.TextXAlignment.Left
wordmark.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -24, 0, 14)
subtitle.Position = UDim2.new(0, 16, 0, 42)
subtitle.BackgroundTransparency = 1
subtitle.Text = "S O U T H   B R O N X   T R E N C H E S"
subtitle.TextColor3 = COL.textDim
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 10
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 8, 0, 8)
dot.Position = UDim2.new(1, -24, 0, 20)
dot.BackgroundColor3 = COL.good
dot.BorderSizePixel = 0
dot.Parent = header
local dc = Instance.new("UICorner")
dc.CornerRadius = UDim.new(1, 0)
dc.Parent = dot

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 36)
tabBar.Position = UDim2.new(0, 0, 0, 64)
tabBar.BackgroundColor3 = COL.panel
tabBar.BorderSizePixel = 0
tabBar.Parent = main

local tabL = Instance.new("UIListLayout")
tabL.FillDirection = Enum.FillDirection.Horizontal
tabL.Padding = UDim.new(0, 0)
tabL.VerticalAlignment = Enum.VerticalAlignment.Center
tabL.Parent = tabBar

local tp = Instance.new("UIPadding")
tp.PaddingLeft = UDim.new(0, 8)
tp.Parent = tabBar

local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -100)
content.Position = UDim2.new(0, 0, 0, 100)
content.BackgroundColor3 = COL.bg
content.BorderSizePixel = 0
content.Parent = main

local pages, tabBtns = {}, {}
local function setTab(i)
    for j, p in ipairs(pages) do p.Visible = (j == i) end
    for j, b in ipairs(tabBtns) do
        if j == i then b.TextColor3, b.BackgroundColor3, b.Font = COL.accent, COL.bg, Enum.Font.GothamBold
        else b.TextColor3, b.BackgroundColor3, b.Font = COL.textDim, COL.panel, Enum.Font.Gotham end
    end
end

local function makeTab(name, w)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, w or 62, 1, 0)
    b.BackgroundColor3 = COL.panel
    b.BorderSizePixel = 0
    b.Text = name
    b.TextColor3 = COL.textDim
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.Parent = tabBar
    table.insert(tabBtns, b)

    local pg = Instance.new("ScrollingFrame")
    pg.Size = UDim2.new(1, 0, 1, 0)
    pg.BackgroundTransparency = 1
    pg.BorderSizePixel = 0
    pg.ScrollBarThickness = 3
    pg.ScrollBarImageColor3 = COL.border
    pg.CanvasSize = UDim2.new(0, 0, 0, 0)
    pg.Visible = false
    pg.Parent = content

    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, 1)
    l.Parent = pg

    local pd = Instance.new("UIPadding")
    pd.PaddingLeft, pd.PaddingRight = UDim.new(0, 14), UDim.new(0, 14)
    pd.PaddingTop, pd.PaddingBottom = UDim.new(0, 12), UDim.new(0, 12)
    pd.Parent = pg

    local idx = #pages + 1
    table.insert(pages, pg)
    b.MouseButton1Click:Connect(function() setTab(idx) end)

    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        pg.CanvasSize = UDim2.new(0, 0, 0, l.AbsoluteContentSize.Y + 24)
    end)
    return pg
end

local function addSection(p, name)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 26)
    l.BackgroundTransparency = 1
    l.Text = string.upper(name)
    l.TextColor3 = COL.danger
    l.Font = Enum.Font.GothamBold
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Bottom
    l.Parent = p
end

local function addToggle(p, label, key, cb)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 32)
    row.BackgroundColor3 = COL.panel
    row.BorderSizePixel = 0
    row.Text = ""
    row.AutoButtonColor = false
    row.Parent = p

    local rs = Instance.new("Frame")
    rs.Size = UDim2.new(1, 0, 0, 1)
    rs.Position = UDim2.new(0, 0, 1, -1)
    rs.BackgroundColor3 = COL.border
    rs.BorderSizePixel = 0
    rs.Parent = row

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

    local ps = Instance.new("UIStroke")
    ps.Color, ps.Thickness = COL.border, 1
    ps.Parent = pill

    local pc = Instance.new("UICorner")
    pc.CornerRadius = UDim.new(1, 0)
    pc.Parent = pill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 10, 0, 10)
    knob.Position = UDim2.new(0, 3, 0.5, -5)
    knob.BackgroundColor3 = COL.textDim
    knob.BorderSizePixel = 0
    knob.Parent = pill

    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1, 0)
    kc.Parent = knob

    local function refresh()
        if CFG[key] then
            knob.Position = UDim2.new(1, -13, 0.5, -5)
            knob.BackgroundColor3, pill.BackgroundColor3, ps.Color = COL.accent, COL.accent, COL.accent
            lbl.TextColor3 = COL.accent
        else
            knob.Position = UDim2.new(0, 3, 0.5, -5)
            knob.BackgroundColor3, pill.BackgroundColor3, ps.Color = COL.textDim, COL.bg, COL.border
            lbl.TextColor3 = COL.text
        end
    end
    refresh()

    row.MouseButton1Click:Connect(function()
        CFG[key] = not CFG[key]
        refresh()
        if cb then pcall(cb, CFG[key]) end
    end)
    return row
end

local function addSlider(p, label, key, mn, mx, st, cb)
    local h = Instance.new("Frame")
    h.Size = UDim2.new(1, 0, 0, 50)
    h.BackgroundColor3 = COL.panel
    h.BorderSizePixel = 0
    h.Parent = p

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -80, 0, 22)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = COL.text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = h

    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(0, 70, 0, 22)
    vl.Position = UDim2.new(1, -80, 0, 4)
    vl.BackgroundTransparency = 1
    vl.Text = string.format("%.2f", CFG[key])
    vl.TextColor3 = COL.accent
    vl.Font = Enum.Font.Code
    vl.TextSize = 12
    vl.TextXAlignment = Enum.TextXAlignment.Right
    vl.Parent = h

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 4)
    bar.Position = UDim2.new(0, 10, 1, -14)
    bar.BackgroundColor3 = COL.bg
    bar.BorderSizePixel = 0
    bar.Parent = h

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(math.clamp((CFG[key] - mn) / (mx - mn), 0, 1), 0, 1, 0)
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
        local aw = bar.AbsoluteSize.X
        if aw <= 0 then return end
        local f = math.clamp((UserInputService:GetMouseLocation().X - bar.AbsolutePosition.X) / aw, 0, 1)
        local v = math.clamp(math.floor((mn + f * (mx - mn)) / st + 0.5) * st, mn, mx)
        CFG[key] = v
        fill.Size = UDim2.new(f, 0, 1, 0)
        vl.Text = string.format("%.2f", v)
        if cb then pcall(cb, v) end
    end)
end

local function addTextBox(p, label, key, ph)
    local h = Instance.new("Frame")
    h.Size = UDim2.new(1, 0, 0, 56)
    h.BackgroundColor3 = COL.panel
    h.BorderSizePixel = 0
    h.Parent = p

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 18)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = COL.text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = h

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -20, 0, 24)
    box.Position = UDim2.new(0, 10, 0, 24)
    box.BackgroundColor3 = COL.bg
    box.BorderSizePixel = 0
    box.Text = tostring(CFG[key] or "")
    box.PlaceholderText = ph or ""
    box.PlaceholderColor3 = COL.textDim
    box.TextColor3 = COL.text
    box.Font = Enum.Font.Code
    box.TextSize = 12
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.ClearTextOnFocus = false
    box.Parent = h

    local bs = Instance.new("UIStroke")
    bs.Color, bs.Thickness = COL.border, 1
    bs.Parent = box

    box.FocusLost:Connect(function() CFG[key] = box.Text end)
end

local function addButton(p, label, cb)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = COL.panel
    btn.BorderSizePixel = 0
    btn.Text = label
    btn.TextColor3 = COL.text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.Parent = p

    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = COL.panelHi end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = COL.panel end)
    btn.MouseButton1Click:Connect(function() pcall(cb) end)
end

-- FOV circle (declared before tabs so slider onChanged can reach it)
local fovGui = Instance.new("ScreenGui")
fovGui.Name = "GraysOnTopFov"
fovGui.ResetOnSpawn = false
fovGui.IgnoreGuiInset = true
fovGui.Parent = guiParent

local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, CFG.silentAimFov * 2, 0, CFG.silentAimFov * 2)
fovCircle.Position = UDim2.new(0.5, -CFG.silentAimFov, 0.5, -CFG.silentAimFov)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 0
fovCircle.Visible = false
fovCircle.Parent = fovGui

local fs = Instance.new("UIStroke")
fs.Color, fs.Thickness, fs.Transparency = COL.danger, 1, 0.5
fs.Parent = fovCircle

local fc = Instance.new("UICorner")
fc.CornerRadius = UDim.new(1, 0)
fc.Parent = fovCircle

local combat = makeTab("COMBAT", 74)
local espPage = makeTab("ESP", 54)
local movePage = makeTab("MOVE", 58)
local farmPage = makeTab("FARM", 56)
local miscPage = makeTab("MISC", 54)
local bindPage = makeTab("KEYS", 52)
local cfgPage = makeTab("CFG", 46)
setTab(1)

addSection(combat, "SILENT AIM")
addToggle(combat, "Silent Aim", "silentAim")
addToggle(combat, "Visible Only", "aimbotVisibleOnly")
addSlider(combat, "FOV Radius", "silentAimFov", 50, 600, 10, function(v)
    fovCircle.Size = UDim2.new(0, v * 2, 0, v * 2)
    fovCircle.Position = UDim2.new(0.5, -v, 0.5, -v)
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
aimBtn.Parent = combat
aimBtn.MouseEnter:Connect(function() aimBtn.BackgroundColor3 = COL.panelHi end)
aimBtn.MouseLeave:Connect(function() aimBtn.BackgroundColor3 = COL.panel end)
aimBtn.MouseButton1Click:Connect(function()
    aimIdx = aimIdx % #aimParts + 1
    CFG.silentAimPart = aimParts[aimIdx]
    aimBtn.Text = "  Aim Part: " .. CFG.silentAimPart
end)

addSection(combat, "HUMANIZER")
addToggle(combat, "Humanize Aim", "humanizer")
addSlider(combat, "Jitter (±deg)", "aimJitterDeg", 0, 8, 0.5)
addSlider(combat, "Reaction Min (ms)", "reactionMinMs", 40, 400, 10)
addSlider(combat, "Reaction Max (ms)", "reactionMaxMs", 40, 600, 10)
addSlider(combat, "Headshot Rate", "headshotChance", 0, 1, 0.05)
addSlider(combat, "Headshots/sec Cap", "maxHeadshotsPerSec", 1, 6, 1)

addSection(combat, "CAMERA-LOCK")
addToggle(combat, "Lock On", "aimbotLock")
addSlider(combat, "Smoothing", "aimbotLockSmooth", 0.05, 1.0, 0.05)

addSection(espPage, "ESP")
addToggle(espPage, "ESP Master", "espEnabled")
addToggle(espPage, "Box", "espBox")
addToggle(espPage, "Name", "espName")
addToggle(espPage, "Health", "espHealth")
addToggle(espPage, "Distance", "espDistance")
addToggle(espPage, "Tracer", "espTracer")
addSlider(espPage, "Max Distance", "espMaxDist", 100, 3000, 50)

addSection(movePage, "MOVEMENT")
addToggle(movePage, "Noclip", "noclip")
addToggle(movePage, "Speed", "speedHack")
addSlider(movePage, "WalkSpeed", "walkSpeed", 16, 300, 1)
addSlider(movePage, "JumpPower", "jumpPower", 50, 500, 5)

addSection(movePage, "FLY")
addToggle(movePage, "Fly", "flyEnabled")
addSlider(movePage, "Fly Speed", "flySpeed", 10, 300, 5)

addSection(farmPage, "AUTO-FARM")
addToggle(farmPage, "Farm Enabled", "farmEnabled")
addTextBox(farmPage, "Tool Name", "farmToolName", "Marshmallow Bag")
addTextBox(farmPage, "Prompt Text", "farmPromptText", "Craft")
addSlider(farmPage, "Farm Interval (s)", "farmInterval", 0.2, 3.0, 0.1)
addSlider(farmPage, "Proximity (studs)", "farmProximityDist", 5, 100, 1)

addSection(miscPage, "AUTO-CLICKER")
addToggle(miscPage, "Auto Clicker", "autoClicker")
addSlider(miscPage, "Clicks Per Second", "autoClickerCps", 1, 30, 1)

addSection(miscPage, "TELEPORT")
local pl = Instance.new("ScrollingFrame")
pl.Size = UDim2.new(1, 0, 0, 150)
pl.BackgroundColor3 = COL.panel
pl.BorderSizePixel = 0
pl.ScrollBarThickness = 3
pl.ScrollBarImageColor3 = COL.border
pl.Parent = miscPage
local pll = Instance.new("UIListLayout")
pll.Padding = UDim.new(0, 1)
pll.Parent = pl

local function refreshPL()
    for _, c in ipairs(pl:GetChildren()) do
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
            b.Parent = pl
            b.MouseEnter:Connect(function() b.BackgroundColor3 = COL.panelHi end)
            b.MouseLeave:Connect(function() b.BackgroundColor3 = COL.bg end)
            b.MouseButton1Click:Connect(function()
                local c = p.Character
                local hrp = c and c:FindFirstChild("HumanoidRootPart")
                local my = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and my then my.CFrame = hrp.CFrame * CFrame.new(0, 0, CFG.teleportOffset) end
            end)
        end
    end
    pl.CanvasSize = UDim2.new(0, 0, 0, pll.AbsoluteContentSize.Y + 4)
end
task.spawn(function()
    while true do pcall(refreshPL) task.wait(2) end
end)

addSection(miscPage, "VISUAL")
addToggle(miscPage, "Fullbright", "fullbright")

addSection(bindPage, "KEYBINDS")
local listening = nil
local menuBtn = Instance.new("TextButton")
menuBtn.Size = UDim2.new(1, 0, 0, 34)
menuBtn.BackgroundColor3 = COL.panel
menuBtn.BorderSizePixel = 0
menuBtn.Text = "Menu: " .. CFG.keyMenu.Name
menuBtn.TextColor3 = COL.accent
menuBtn.Font = Enum.Font.Code
menuBtn.TextSize = 12
menuBtn.Parent = bindPage
menuBtn.MouseButton1Click:Connect(function()
    listening = "keyMenu"
    menuBtn.Text = "Press a key..."
end)

UserInputService.InputBegan:Connect(function(i, p)
    if p then return end
    if listening then
        if i.UserInputType == Enum.UserInputType.Keyboard then
            CFG[listening] = i.KeyCode
            menuBtn.Text = "Menu: " .. CFG[listening].Name
            listening = nil
        end
        return
    end
    if i.KeyCode == CFG.keyMenu then main.Visible = not main.Visible end
end)

addSection(cfgPage, "CONFIG")
addButton(cfgPage, "Save Config", GOT.saveConfig)
addButton(cfgPage, "Load Config", GOT.loadConfig)
addButton(cfgPage, "Reset", function()
    if CAP.isfile and CAP.delfile and isfile(CONFIG_PATH) then delfile(CONFIG_PATH) end
end)

-- drag
local drag, dStart, sPos
wordmark.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = true
        dStart = i.Position
        sPos = main.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dStart
        main.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
end)

-- engines: noclip, speed, fly, clicker, farm, camera lock, fullbright, silent aim, ESP
local mouse = localPlayer:GetMouse()
local headTimes, pendingHit = {}, nil
local flyBV, flyBG, flyConn

local function bindChar(c)
    local hum = c:WaitForChild("Humanoid", 5)
    if not hum then return end
    hum.WalkSpeed, hum.JumpPower, hum.UseJumpPower = CFG.walkSpeed, CFG.jumpPower, true
end
if localPlayer.Character then bindChar(localPlayer.Character) end
localPlayer.CharacterAdded:Connect(bindChar)

RunService.Stepped:Connect(function()
    local c = localPlayer.Character
    if CFG.noclip and c then
        for _, p
