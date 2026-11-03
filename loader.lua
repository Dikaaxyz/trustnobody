-- SpookenD V5 — Violence District (ESP Fix + Floating Logo)
-- Isi REMOTES dari ReplicatedStorage dulu sebelum execute.

pcall(function()
    for _, g in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if g.Name:find("SpookenD") or g.Name:find("VD_UI") then g:Destroy() end
    end
    if getgenv().SpookenD_DRAWINGS then
        for _, d in ipairs(getgenv().SpookenD_DRAWINGS) do
            pcall(function() d:Remove() end)
        end
    end
end)

local CONFIG = {
    esp_enabled=true, esp_killer=true, esp_survivor=true, esp_generator=true,
    esp_max_dist=300, -- Jarak render maksimal
    color_killer={255,50,50}, color_survivor={50,180,255}, color_generator={255,200,40},
    auto_parry=false, silent_aim=false, kill_aura=false, auto_skill_check=false,
    auto_generator=false, auto_heal=false, auto_unhook=false, auto_escape=false,
    speed_enabled=false, speed_value=35, noclip_enabled=false, fly_enabled=false, fly_speed=50,
    fullbright_medium=false, fps_boost=false, anti_lag=false, no_fog_enabled=false,
    unlock_mouse_enabled=false, hitbox_survivor=false, hitbox_size=10,
}
local REMOTES = { parry=nil, attack=nil, generator=nil, heal=nil, unhook=nil, escape=nil }

local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local Lighting=game:GetService("Lighting")
local Workspace=game:GetService("Workspace")
local CoreGui=game:GetService("CoreGui")
local LP=Players.LocalPlayer
local Camera=Workspace.CurrentCamera
local Drawing=Drawing or (syn and syn.drawing)
local is_mobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

getgenv().SpookenD_CONNS = getgenv().SpookenD_CONNS or {}
getgenv().SpookenD_DRAWINGS = getgenv().SpookenD_DRAWINGS or {}

local function rgb(c) return Color3.fromRGB(c[1],c[2],c[3]) end
local function new_d(c,p) 
    if not Drawing then return nil end 
    local d=Drawing.new(c) 
    for k,v in pairs(p) do d[k]=v end 
    table.insert(getgenv().SpookenD_DRAWINGS, d) 
    return d 
end
local function dist(a,b) return (a-b).Magnitude end

local function get_role(plr)
    if plr==LP then return "LocalPlayer" end
    local ok,t=pcall(function() return plr.Team end)
    if ok and t then
        local n=t.Name:lower()
        if n:find("killer") then return "Killer" end
        if n:find("survivor") then return "Survivor" end
    end
    local ok2,r=pcall(function() return plr:GetAttribute("Role") end)
    if ok2 and type(r)=="string" then
        local rl=r:lower()
        if rl:find("killer") then return "Killer" end
        if rl:find("survivor") then return "Survivor" end
    end
    return nil
end

-- ============================================================
-- ESP (Fix Update Loop, No Throttle Bug)
-- ============================================================
local esp_cache = {}
local esp_accum = 0

local function update_esp(dt)
    esp_accum = esp_accum + dt
    -- Render 30 FPS aja biar gak berat, tapi pake logic yang bener
    if esp_accum < 1/30 then return end
    esp_accum = 0

    if not CONFIG.esp_enabled then
        for _, c in pairs(esp_cache) do 
            if c.text then c.text.Visible = false end
            if c.tracer then c.tracer.Visible = false end
        end
        return 
    end

    local mc = LP.Character
    local mh = mc and mc:FindFirstChild("HumanoidRootPart")
    if not mh then return end
    local mp = mh.Position
    local vp = Camera.ViewportSize

    -- PLAYER ESP
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local role = get_role(plr)
            local want = (role == "Killer" and CONFIG.esp_killer) or (role == "Survivor" and CONFIG.esp_survivor)
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")
            
            if want and hrp and head then
                local d = dist(mp, hrp.Position)
                if d <= CONFIG.esp_max_dist then
                    local color = role == "Killer" and CONFIG.color_killer or CONFIG.color_survivor
                    if not esp_cache[plr] then
                        esp_cache[plr] = {
                            text = new_d("Text", {Size=13, Center=true, Outline=true, Visible=false, Color=rgb(color)}),
                            tracer = new_d("Line", {Thickness=1, Visible=false, Color=rgb(color)})
                        }
                    end
                    local c = esp_cache[plr]
                    -- Pake WorldToViewportPoint langsung, lebih stabil
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    
                    if onScreen then
                        c.text.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
                        c.text.Text = string.format("%s [%s] %dm", plr.Name, role, math.floor(d))
                        c.text.Visible = true
                        c.tracer.From = Vector2.new(vp.X / 2, vp.Y)
                        c.tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                        c.tracer.Visible = true
                    else
                        c.text.Visible = false
                        c.tracer.Visible = false
                    end
                else
                    if esp_cache[plr] then 
                        esp_cache[plr].text.Visible = false 
                        esp_cache[plr].tracer.Visible = false 
                    end
                end
            else
                if esp_cache[plr] then 
                    esp_cache[plr].text.Visible = false 
                    esp_cache[plr].tracer.Visible = false 
                end
            end
        end
    end

    -- GENERATOR ESP
    if CONFIG.esp_generator then
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                local name = obj.Name:lower()
                if name:find("generator") or name:find("gen") then
                    local pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                    local d = dist(mp, pos)
                    if d <= CONFIG.esp_max_dist then
                        if not esp_cache[obj] then
                            esp_cache[obj] = {
                                text = new_d("Text", {Size=13, Center=true, Outline=true, Visible=false, Color=rgb(CONFIG.color_generator)})
                            }
                        end
                        local c = esp_cache[obj]
                        local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
                        if onScreen then
                            c.text.Position = Vector2.new(screenPos.X, screenPos.Y - 10)
                            c.text.Text = string.format("[Generator] %dm", math.floor(d))
                            c.text.Visible = true
                        else
                            c.text.Visible = false
                        end
                    else
                        if esp_cache[obj] then esp_cache[obj].text.Visible = false end
                    end
                end
            end
        end
    end
end

-- ============================================================
-- FITUR LAIN
-- ============================================================
local function apply_fullbright_medium()
    if CONFIG.fullbright_medium then
        pcall(function()
            Lighting.Ambient = Color3.fromRGB(150,150,150)
            Lighting.OutdoorAmbient = Color3.fromRGB(150,150,150)
            Lighting.Brightness = 2
        end)
    end
end

local function apply_fps_boost()
    if not CONFIG.fps_boost then return end
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
end

local function apply_misc() apply_fullbright_medium() end
if CONFIG.fps_boost then apply_fps_boost() end

local function update_auto(dt)
    if CONFIG.auto_heal then
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health < hum.MaxHealth * 0.8 then
            if REMOTES.heal then pcall(function() REMOTES.heal:FireServer() end) end
        end
    end
    if CONFIG.auto_parry and REMOTES.parry then
        local mh = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if mh then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and get_role(p) == "Killer" then
                    local kh = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    if kh and dist(mh.Position, kh.Position) <= 12 then
                        pcall(function() REMOTES.parry:FireServer() end)
                    end
                end
            end
        end
    end
end

-- ============================================================
-- UI & FLOATING LOGO
-- ============================================================
local COLORS = {
    bg = Color3.fromRGB(22,22,28), sidebar = Color3.fromRGB(16,16,22),
    card = Color3.fromRGB(36,36,46), accent = Color3.fromRGB(0,160,255),
    green = Color3.fromRGB(40,200,100), text = Color3.fromRGB(255,255,255),
    subtext = Color3.fromRGB(160,160,170), stroke = Color3.fromRGB(45,45,55),
}
local FONT = Enum.Font.Gotham
local FONT_BOLD = Enum.Font.GothamBold

local gui = Instance.new("ScreenGui")
gui.Name = "VD_UI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = CoreGui

local W = is_mobile and 330 or 560
local H = is_mobile and 400 or 380

local main = Instance.new("Frame")
main.Size = UDim2.new(0, W, 0, H)
main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
main.BackgroundColor3 = COLORS.bg
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui
local mainCorner = Instance.new("UICorner") mainCorner.CornerRadius = UDim.new(0, 8) mainCorner.Parent = main
local mainStroke = Instance.new("UIStroke") mainStroke.Color = COLORS.stroke mainStroke.Thickness = 1 mainStroke.Parent = main

-- FLOATING LOGO
local floatingLogo = Instance.new("TextButton")
floatingLogo.Size = UDim2.new(0, 40, 0, 40)
floatingLogo.Position = UDim2.new(0, 20, 0, 20)
floatingLogo.BackgroundColor3 = COLORS.accent
floatingLogo.BorderSizePixel = 0
floatingLogo.Text = "🛡"
floatingLogo.TextColor3 = COLORS.text
floatingLogo.Font = Enum.Font.GothamBold
floatingLogo.TextSize = 20
floatingLogo.Visible = false
floatingLogo.Active = true
floatingLogo.Parent = gui
local flCorner = Instance.new("UICorner") flCorner.CornerRadius = UDim.new(1, 0) flCorner.Parent = floatingLogo

local dragging, dragStart, startPos
floatingLogo.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = floatingLogo.Position
    end
end)
floatingLogo.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        floatingLogo.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
floatingLogo.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
floatingLogo.MouseButton1Click:Connect(function()
    main.Visible = true
    floatingLogo.Visible = false
end)

-- HEADER
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = COLORS.sidebar
header.BorderSizePixel = 0
header.Parent = main
local headerCorner = Instance.new("UICorner") headerCorner.CornerRadius = UDim.new(0, 8) headerCorner.Parent = header
local headerFix = Instance.new("Frame") headerFix.Size = UDim2.new(1, 0, 0, 10) headerFix.Position = UDim2.new(0, 0, 1, -10) headerFix.BackgroundColor3 = COLORS.sidebar headerFix.BorderSizePixel = 0 headerFix.Parent = header

local icon = Instance.new("ImageLabel")
icon.Size = UDim2.new(0, 20, 0, 20)
icon.Position = UDim2.new(0, 16, 0.5, -10)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://7733960981"
icon.ImageColor3 = COLORS.accent
icon.Parent = header

local title = Instance.new("TextLabel") title.Size = UDim2.new(0, 160, 0, 16) title.Position = UDim2.new(0, 44, 0, 10) title.BackgroundTransparency = 1 title.Text = "VIOLENCE DISTRICT" title.TextColor3 = COLORS.text title.Font = FONT_BOLD title.TextSize = 12 title.TextXAlignment = Enum.TextXAlignment.Left title.Parent = header
local subtitle = Instance.new("TextLabel") subtitle.Size = UDim2.new(0, 200, 0, 14) subtitle.Position = UDim2.new(0, 44, 0, 24) subtitle.BackgroundTransparency = 1 subtitle.Text = "Welcome, " .. LP.Name subtitle.TextColor3 = COLORS.subtext subtitle.Font = FONT subtitle.TextSize = 10 subtitle.TextXAlignment = Enum.TextXAlignment.Left subtitle.Parent = header

local userBadge = Instance.new("Frame") userBadge.Size = UDim2.new(0, 90, 0, 22) userBadge.Position = UDim2.new(1, -200, 0.5, -11) userBadge.BackgroundColor3 = COLORS.accent userBadge.BorderSizePixel = 0 userBadge.Parent = header
local userBadgeCorner = Instance.new("UICorner") userBadgeCorner.CornerRadius = UDim.new(0, 4) userBadgeCorner.Parent = userBadge
local userText = Instance.new("TextLabel") userText.Size = UDim2.new(1, 0, 1, 0) userText.BackgroundTransparency = 1 userText.Text = "@" .. LP.Name userText.TextColor3 = COLORS.text userText.Font = FONT_BOLD userText.TextSize = 9 userText.Parent = userBadge

local unlockedBadge = Instance.new("Frame") unlockedBadge.Size = UDim2.new(0, 80, 0, 22) unlockedBadge.Position = UDim2.new(1, -105, 0.5, -11) unlockedBadge.BackgroundColor3 = COLORS.green unlockedBadge.BorderSizePixel = 0 unlockedBadge.Parent = header
local unlockedCorner = Instance.new("UICorner") unlockedCorner.CornerRadius = UDim.new(0, 4) unlockedCorner.Parent = unlockedBadge
local unlockedText = Instance.new("TextLabel") unlockedText.Size = UDim2.new(1, 0, 1, 0) unlockedText.BackgroundTransparency = 1 unlockedText.Text = "UNLOCKED" unlockedText.TextColor3 = COLORS.bg unlockedText.Font = FONT_BOLD unlockedText.TextSize = 9 unlockedText.Parent = unlockedBadge

local closeBtn = Instance.new("TextButton") closeBtn.Size = UDim2.new(0, 22, 0, 22) closeBtn.Position = UDim2.new(1, -32, 0.5, -11) closeBtn.BackgroundColor3 = Color3.fromRGB(50,20,20) closeBtn.BorderSizePixel = 0 closeBtn.Text = "×" closeBtn.TextColor3 = COLORS.text closeBtn.Font = FONT_BOLD closeBtn.TextSize = 14 closeBtn.Parent = header
local closeCorner = Instance.new("UICorner") closeCorner.CornerRadius = UDim.new(0, 4) closeCorner.Parent = closeBtn
closeBtn.MouseButton1Click:Connect(function() main.Visible = false floatingLogo.Visible = true end)

-- BODY
local body = Instance.new("Frame") body.Size = UDim2.new(1, 0, 1, -48) body.Position = UDim2.new(0, 0, 0, 48) body.BackgroundTransparency = 1 body.Parent = main
local sidebar = Instance.new("Frame") sidebar.Size = UDim2.new(0, is_mobile and 90 or 140, 1, 0) sidebar.BackgroundColor3 = COLORS.sidebar sidebar.BorderSizePixel = 0 sidebar.Parent = body
local panel = Instance.new("ScrollingFrame") panel.Size = UDim2.new(1, -(is_mobile and 90 or 140), 1, 0) panel.Position = UDim2.new(0, is_mobile and 90 or 140, 0, 0) panel.BackgroundColor3 = COLORS.bg panel.BorderSizePixel = 0 panel.ScrollBarThickness = 2 panel.ScrollBarImageColor3 = COLORS.stroke panel.CanvasSize = UDim2.new(0, 0, 0, 0) panel.AutomaticCanvasSize = Enum.AutomaticSize.Y panel.Parent = body

local tabs = {"Main", "Teleport", "Auto", "Killer", "Settings"}
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
        set(not get())
        sw.BackgroundColor3 = get() and COLORS.accent or Color3.fromRGB(60,60,70)
        knob.Position = get() and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    end)
end

make_card(pages["Main"], "ESP Enabled", "Tampilkan semua ESP", function() return CONFIG.esp_enabled end, function(v) CONFIG.esp_enabled=v end)
make_card(pages["Main"], "Killer ESP", "Highlight Killer", function() return CONFIG.esp_killer end, function(v) CONFIG.esp_killer=v end)
make_card(pages["Main"], "Survivor ESP", "Highlight Survivor", function() return CONFIG.esp_survivor end, function(v) CONFIG.esp_survivor=v end)
make_card(pages["Main"], "Generator ESP", "Highlight Generator", function() return CONFIG.esp_generator end, function(v) CONFIG.esp_generator=v end)

make_card(pages["Teleport"], "Auto Teleport Survive", "Teleport ke survivor terdekat", function() return false end, function(v) end)

make_card(pages["Auto"], "Auto Generator", "Selesaikan generator otomatis", function() return CONFIG.auto_generator end, function(v) CONFIG.auto_generator=v end)
make_card(pages["Auto"], "Auto Heal", "Heal diri sendiri saat HP turun", function() return CONFIG.auto_heal end, function(v) CONFIG.auto_heal=v end)
make_card(pages["Auto"], "Auto Unhook", "Lepas diri dari hook", function() return CONFIG.auto_unhook end, function(v) CONFIG.auto_unhook=v end)
make_card(pages["Auto"], "Auto Escape", "Pergi ke exit gate otomatis", function() return CONFIG.auto_escape end, function(v) CONFIG.auto_escape=v end)
make_card(pages["Auto"], "Auto Skill Check", "Selesaikan skill check otomatis", function() return CONFIG.auto_skill_check end, function(v) CONFIG.auto_skill_check=v end)

make_card(pages["Killer"], "Hitbox for Survivor Players", "Increase hitbox size to 10 studs for survivor", function() return CONFIG.hitbox_survivor end, function(v) CONFIG.hitbox_survivor=v end)
make_card(pages["Killer"], "Auto Parry", "Parry otomatis saat killer dekat", function() return CONFIG.auto_parry end, function(v) CONFIG.auto_parry=v end)
make_card(pages["Killer"], "Silent Aim", "Aim otomatis ke target", function() return CONFIG.silent_aim end, function(v) CONFIG.silent_aim=v end)
make_card(pages["Killer"], "Kill Aura", "Serang survivor di sekitar", function() return CONFIG.kill_aura end, function(v) CONFIG.kill_aura=v end)

make_card(pages["Settings"], "Fullbright Medium", "Terang tapi tidak menyilaukan", function() return CONFIG.fullbright_medium end, function(v) CONFIG.fullbright_medium=v apply_misc() end)
make_card(pages["Settings"], "FPS Boost", "Matikan efek berat", function() return CONFIG.fps_boost end, function(v) CONFIG.fps_boost=v apply_fps_boost() end)
make_card(pages["Settings"], "No Fog", "Hilangkan kabut", function() return CONFIG.no_fog_enabled end, function(v) CONFIG.no_fog_enabled=v end)
make_card(pages["Settings"], "Speed", "Jalan lebih cepat", function() return CONFIG.speed_enabled end, function(v) CONFIG.speed_enabled=v end)
make_card(pages["Settings"], "Noclip", "Tembus dinding", function() return CONFIG.noclip_enabled end, function(v) CONFIG.noclip_enabled=v end)
make_card(pages["Settings"], "Unlock Mouse", "Bebaskan mouse", function() return CONFIG.unlock_mouse_enabled end, function(v) CONFIG.unlock_mouse_enabled=v end)

local footer = Instance.new("Frame") footer.Size = UDim2.new(1, 0, 0, 56) footer.Position = UDim2.new(0, 0, 1, -56) footer.BackgroundColor3 = COLORS.sidebar footer.BorderSizePixel = 0 footer.Parent = sidebar
local avatar = Instance.new("ImageLabel") avatar.Size = UDim2.new(0, 26, 0, 26) avatar.Position = UDim2.new(0, 10, 0.5, -13) avatar.BackgroundColor3 = COLORS.card avatar.BorderSizePixel = 0 avatar.Image = "rbxthumb://type=Avatar&id="..LP.UserId.."&w=48&h=48" avatar.Parent = footer
local avCorner = Instance.new("UICorner") avCorner.CornerRadius = UDim.new(1,0) avCorner.Parent = avatar
local uname = Instance.new("TextLabel") uname.Size = UDim2.new(1, -44, 0, 14) uname.Position = UDim2.new(0, 42, 0, 14) uname.BackgroundTransparency = 1 uname.Text = LP.DisplayName uname.TextColor3 = COLORS.text uname.Font = FONT_BOLD uname.TextSize = 10 uname.TextXAlignment = Enum.TextXAlignment.Left uname.Parent = footer
local uid = Instance.new("TextLabel") uid.Size = UDim2.new(1, -44, 0, 12) uid.Position = UDim2.new(0, 42, 0, 28) uid.BackgroundTransparency = 1 uid.Text = "@" .. LP.Name uid.TextColor3 = COLORS.subtext uid.Font = FONT uid.TextSize = 9 uid.TextXAlignment = Enum.TextXAlignment.Left uid.Parent = footer

switch_tab("Main")
apply_misc()

RunService.RenderStepped:Connect(function(dt)
    pcall(update_esp, dt)
    pcall(update_auto, dt)
end)

print("[SpookenD] V5 Loaded — ESP Root Cause Fixed.")
