-- EggMaster V9 — Crash Fix & Safe Execute
-- Aman di Xeno, aman pas loading screen.

pcall(function()
    for _, g in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if g.Name:find("EggMaster") or g.Name:find("EngineCore") then g:Destroy() end
    end
end)

local CONFIG = {
    esp_enabled=false, esp_eggs=false, esp_players=false, esp_max_dist=500,
    color_egg={255,200,40}, color_player={50,180,255},
    auto_steal=false, target_eggs = "", 
    steal_dist=100, grab_dist=5,
    speed_enabled=false, speed_value=35,
}

local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local CoreGui=game:GetService("CoreGui")
local Workspace=game:GetService("Workspace")
local LP=Players.LocalPlayer
local is_mobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local function rgb(c) return Color3.fromRGB(c[1],c[2],c[3]) end
local function dist(a,b) return (a-b).Magnitude end

local function is_target_egg(egg_name)
    if CONFIG.target_eggs == "" or CONFIG.target_eggs == nil then return true end
    local name_lower = egg_name:lower()
    for target in string.gmatch(CONFIG.target_eggs, '([^,]+)') do
        local clean_target = target:gsub("^%s*(.-)%s*$", "%1"):lower()
        if clean_target ~= "" and name_lower:find(clean_target) then return true end
    end
    return false
end

-- ============================================================
-- ESP
-- ============================================================
local esp_cache = {}
local function create_esp(obj, color, text_str)
    local bg = Instance.new("BillboardGui")
    bg.Name = "EggMaster_ESP"
    bg.AlwaysOnTop = true
    bg.Size = UDim2.new(0, 100, 0, 30)
    bg.StudsOffset = Vector3.new(0, 2, 0)
    bg.Parent = obj
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = rgb(color)
    text.TextStrokeTransparency = 0
    text.Font = Enum.Font.GothamBold
    text.TextSize = 12
    text.Text = text_str
    text.Parent = bg
    return { gui = bg, text = text }
end

local function update_esp()
    if not CONFIG.esp_enabled then
        for _, c in pairs(esp_cache) do if c.gui then c.gui.Enabled = false end end
        return
    end
    
    -- Cek karakter dulu (Anti Crash)
    local char = LP.Character
    if not char then return end
    local my_hrp = char:FindFirstChild("HumanoidRootPart")
    if not my_hrp then return end
    
    if CONFIG.esp_eggs then
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                local n = obj.Name:lower()
                if n:find("egg") and is_target_egg(n) then
                    local pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                    local d = dist(my_hrp.Position, pos)
                    if d <= CONFIG.esp_max_dist then
                        if not esp_cache[obj] then esp_cache[obj] = create_esp(obj, CONFIG.color_egg, obj.Name) end
                        local c = esp_cache[obj]
                        if c and c.gui then
                            c.gui.Enabled = true
                            c.text.Text = string.format("%s [%dm]", obj.Name, math.floor(d))
                        end
                    else
                        if esp_cache[obj] and esp_cache[obj].gui then esp_cache[obj].gui.Enabled = false end
                    end
                end
            end
        end
    end
end

-- ============================================================
-- AUTO STEAL (SAFE TELEPORT)
-- ============================================================
local is_stealing = false

local function auto_steal()
    if not CONFIG.auto_steal then return end
    if is_stealing then return end
    
    -- Cek karakter dulu (Anti Crash)
    local char = LP.Character
    if not char then return end
    local my_hrp = char:FindFirstChild("HumanoidRootPart")
    if not my_hrp then return end

    local nearest, nd = nil, math.huge
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("egg") and is_target_egg(n) then
                local pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                local d = dist(my_hrp.Position, pos)
                if d < nd and d <= CONFIG.steal_dist then nearest, nd = obj, pos end
            end
        end
    end

    if nearest then
        if nd > CONFIG.grab_dist then
            is_stealing = true
            pcall(function()
                my_hrp.CFrame = CFrame.new(nearest + Vector3.new(0, 3, 0))
            end)
            task.wait(0.1)
            
            pcall(function()
                local prompt = nearest:FindFirstChildOfClass("ProximityPrompt")
                if prompt and fireproximityprompt then fireproximityprompt(prompt) end
                
                local bp = LP:FindFirstChild("Backpack")
                if bp then
                    for _, tool in ipairs(bp:GetChildren()) do
                        if tool:IsA("Tool") and tool.Name:lower():find("grab") then
                            tool.Parent = char 
                            task.wait(0.1) 
                            tool:Activate()
                            break
                        end
                    end
                end
            end)
            is_stealing = false
        end
    end
end

local function apply_speed()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = CONFIG.speed_enabled and CONFIG.speed_value or 16 end
end

-- ============================================================
-- UI
-- ============================================================
local COLORS = { bg = Color3.fromRGB(20,20,24), sidebar = Color3.fromRGB(14,14,18), card = Color3.fromRGB(30,30,36), accent = Color3.fromRGB(0,150,255), text = Color3.fromRGB(255,255,255), subtext = Color3.fromRGB(150,150,160), stroke = Color3.fromRGB(40,40,48) }
local FONT = Enum.Font.Gotham
local FONT_BOLD = Enum.Font.GothamBold

local gui = Instance.new("ScreenGui") gui.Name = "EggMaster" gui.ResetOnSpawn = false gui.IgnoreGuiInset = true gui.Parent = CoreGui
local W = is_mobile and 320 or 520
local H = is_mobile and 380 or 360

local main = Instance.new("Frame") main.Size = UDim2.new(0, W, 0, H) main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2) main.BackgroundColor3 = COLORS.bg main.BorderSizePixel = 0 main.Active = true main.Parent = gui
local mainCorner = Instance.new("UICorner") mainCorner.CornerRadius = UDim.new(0, 8) mainCorner.Parent = main
local mainStroke = Instance.new("UIStroke") mainStroke.Color = COLORS.stroke mainStroke.Thickness = 1 mainStroke.Parent = main

local header = Instance.new("Frame") header.Size = UDim2.new(1, 0, 0, 40) header.BackgroundColor3 = COLORS.sidebar header.BorderSizePixel = 0 header.Parent = main
local headerCorner = Instance.new("UICorner") headerCorner.CornerRadius = UDim.new(0, 8) headerCorner.Parent = header
local headerFix = Instance.new("Frame") headerFix.Size = UDim2.new(1, 0, 0, 10) headerFix.Position = UDim2.new(0, 0, 1, -10) headerFix.BackgroundColor3 = COLORS.sidebar headerFix.BorderSizePixel = 0 headerFix.Parent = header
local title = Instance.new("TextLabel") title.Size = UDim2.new(1, 0, 1, 0) title.BackgroundTransparency = 1 title.Text = "EGGMASTER V9" title.TextColor3 = COLORS.accent title.Font = FONT_BOLD title.TextSize = 14 title.Parent = header

local dragging, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = input.Position startPos = main.Position end
end)
header.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

local body = Instance.new("Frame") body.Size = UDim2.new(1, 0, 1, -40) body.Position = UDim2.new(0, 0, 0, 40) body.BackgroundTransparency = 1 body.Parent = main
local sidebar = Instance.new("Frame") sidebar.Size = UDim2.new(0, is_mobile and 90 or 120, 1, 0) sidebar.BackgroundColor3 = COLORS.sidebar sidebar.BorderSizePixel = 0 sidebar.Parent = body
local panel = Instance.new("ScrollingFrame") panel.Size = UDim2.new(1, -(is_mobile and 90 or 120), 1, 0) panel.Position = UDim2.new(0, is_mobile and 90 or 120, 0, 0) panel.BackgroundColor3 = COLORS.bg panel.BorderSizePixel = 0 panel.ScrollBarThickness = 2 panel.ScrollBarImageColor3 = COLORS.stroke panel.CanvasSize = UDim2.new(0, 0, 0, 0) panel.AutomaticCanvasSize = Enum.AutomaticSize.Y panel.Parent = body

local tabs = {"Main", "Visuals", "Auto"}
local pages = {}
local tabButtons = {}
local function switch_tab(name)
    for n, p in pairs(pages) do p.Visible = (n == name) end
    for _, b in pairs(tabButtons) do
        b.BackgroundColor3 = (b:GetAttribute("TabName") == name) and COLORS.card or COLORS.sidebar
        b.TextColor3 = (b:GetAttribute("TabName") == name) and COLORS.text or COLORS.subtext
    end
end

for i, name in ipairs(tabs) do
    local b = Instance.new("TextButton") b.Size = UDim2.new(1, -8, 0, 32) b.Position = UDim2.new(0, 4, 0, 8 + (i-1)*36) b.BackgroundColor3 = COLORS.sidebar b.BorderSizePixel = 0 b.Text = "  " .. name b.TextColor3 = COLORS.subtext b.Font = FONT b.TextSize = 12 b.TextXAlignment = Enum.TextXAlignment.Left b.Parent = sidebar
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = b
    b:SetAttribute("TabName", name) b.MouseButton1Click:Connect(function() switch_tab(name) end) tabButtons[name] = b
    local p = Instance.new("Frame") p.Size = UDim2.new(1, 0, 1, 0) p.BackgroundTransparency = 1 p.Visible = false p.Parent = panel
    local layout = Instance.new("UIListLayout") layout.Padding = UDim.new(0, 8) layout.SortOrder = Enum.SortOrder.LayoutOrder layout.Parent = p
    local pad = Instance.new("UIPadding") pad.PaddingTop = UDim.new(0, 12) pad.PaddingLeft = UDim.new(0, 8) pad.PaddingRight = UDim.new(0, 8) pad.Parent = p
    pages[name] = p
end

local function make_card(parent, title, desc, get, set)
    local card = Instance.new("Frame") card.Size = UDim2.new(1, 0, 0, desc and 64 or 44) card.BackgroundColor3 = COLORS.card card.BorderSizePixel = 0 card.Parent = parent
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = card
    local t = Instance.new("TextLabel") t.Size = UDim2.new(1, -60, 0, desc and 22 or 44) t.Position = UDim2.new(0, 12, 0, desc and 8 or 0) t.BackgroundTransparency = 1 t.Text = title t.TextColor3 = COLORS.text t.Font = FONT_BOLD t.TextSize = 12 t.TextXAlignment = Enum.TextXAlignment.Left t.Parent = card
    if desc then
        local d = Instance.new("TextLabel") d.Size = UDim2.new(1, -60, 0, 30) d.Position = UDim2.new(0, 12, 0, 26) d.BackgroundTransparency = 1 d.Text = desc d.TextColor3 = COLORS.subtext d.Font = FONT d.TextSize = 10 d.TextXAlignment = Enum.TextXAlignment.Left d.TextWrapped = true d.Parent = card
    end
    local sw = Instance.new("Frame") sw.Size = UDim2.new(0, 36, 0, 20) sw.Position = UDim2.new(1, -48, 0.5, -10) sw.BackgroundColor3 = get() and COLORS.accent or Color3.fromRGB(60,60,70) sw.BorderSizePixel = 0 sw.Parent = card
    local swCorner = Instance.new("UICorner") swCorner.CornerRadius = UDim.new(1, 0) swCorner.Parent = sw
    local knob = Instance.new("Frame") knob.Size = UDim2.new(0, 16, 0, 16) knob.Position = get() and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) knob.BackgroundColor3 = Color3.new(1,1,1) knob.BorderSizePixel = 0 knob.Parent = sw
    local knobCorner = Instance.new("UICorner") knobCorner.CornerRadius = UDim.new(1, 0) knobCorner.Parent = knob
    local click = Instance.new("TextButton") click.Size = UDim2.new(1, 0, 1, 0) click.BackgroundTransparency = 1 click.Text = "" click.Parent = card
    click.MouseButton1Click:Connect(function()
        local is_now_on = not get()
        set(is_now_on)
        if is_now_on then
            sw.BackgroundColor3 = COLORS.accent
            knob.Position = UDim2.new(1, -18, 0.5, -8)
        else
            sw.BackgroundColor3 = Color3.fromRGB(60,60,70)
            knob.Position = UDim2.new(0, 2, 0.5, -8)
        end
    end)
end

local function make_textbox(parent, title, placeholder, get, set)
    local card = Instance.new("Frame") card.Size = UDim2.new(1, 0, 0, 64) card.BackgroundColor3 = COLORS.card card.BorderSizePixel = 0 card.Parent = parent
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = card
    local t = Instance.new("TextLabel") t.Size = UDim2.new(1, 0, 0, 22) t.Position = UDim2.new(0, 12, 0, 8) t.BackgroundTransparency = 1 t.Text = title t.TextColor3 = COLORS.text t.Font = FONT_BOLD t.TextSize = 12 t.TextXAlignment = Enum.TextXAlignment.Left t.Parent = card
    local box = Instance.new("TextBox") box.Size = UDim2.new(1, -24, 0, 24) box.Position = UDim2.new(0, 12, 0, 30) box.BackgroundColor3 = COLORS.bg box.TextColor3 = COLORS.text box.PlaceholderText = placeholder box.PlaceholderColor3 = COLORS.subtext box.Text = get() box.Font = FONT box.TextSize = 11 box.TextXAlignment = Enum.TextXAlignment.Left box.Parent = card
    local boxCorner = Instance.new("UICorner") boxCorner.CornerRadius = UDim.new(0, 4) boxCorner.Parent = box
    local boxPad = Instance.new("UIPadding") boxPad.PaddingLeft = UDim.new(0, 6) boxPad.Parent = box
    box.FocusLost:Connect(function() set(box.Text) end)
end

make_card(pages["Main"], "Auto Steal", "Teleport & Ambil telur (Aman).", function() return CONFIG.auto_steal end, function(v) CONFIG.auto_steal=v end)
make_card(pages["Main"], "Speed Hack", "Jalan lebih cepat", function() return CONFIG.speed_enabled end, function(v) CONFIG.speed_enabled=v apply_speed() end)
make_textbox(pages["Main"], "Target Eggs", "Contoh: Secret, Legendary", function() return CONFIG.target_eggs end, function(v) CONFIG.target_eggs=v end)

make_card(pages["Visuals"], "ESP Eggs", "Lihat lokasi telur", function() return CONFIG.esp_eggs end, function(v) CONFIG.esp_eggs=v end)
make_card(pages["Visuals"], "ESP Players", "Lihat posisi pemain", function() return CONFIG.esp_players end, function(v) CONFIG.esp_players=v end)

switch_tab("Main")

RunService.RenderStepped:Connect(function()
    pcall(update_esp)
    pcall(auto_steal)
end)

print("[EggMaster] V9 Loaded — Safe Execute.")
