-- SpookenD V2 — Violence District
-- UI mirip referensi, mobile friendly, anti-lag, FPS boost, fullbright medium.
-- Isi REMOTES dari ReplicatedStorage dulu.

-- ============================================================
-- CLEANUP
-- ============================================================
pcall(function()
    for _, g in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if g.Name:find("SpookenD") or g.Name:find("VD_Mobile") then g:Destroy() end
    end
    if getgenv().SpookenD_CONNS then
        for _, c in ipairs(getgenv().SpookenD_CONNS) do pcall(function() c:Disconnect() end) end
    end
end)

-- ============================================================
-- CONFIG
-- ============================================================
local CONFIG = {
    -- ESP
    esp_enabled=true, esp_killer=true, esp_survivor=true, esp_generator=true,
    esp_hook=false, esp_pallet=false, esp_window=false, esp_gate=false,
    esp_max_dist=500,
    color_killer={255,50,50}, color_survivor={50,180,255},
    color_generator={255,200,40}, color_hook={200,100,255},
    color_pallet={180,180,180}, color_window={100,255,200}, color_gate={255,100,100},
    -- Combat
    auto_parry=false, parry_range=12,
    silent_aim=false, aim_fov=120, aim_target="Killer",
    kill_aura=false, aura_range=15, aura_rate=0.1,
    auto_skill_check=false, skill_check_cd=0.5,
    -- Hitbox
    hitbox_survivor=false, hitbox_size=10,
    -- Auto
    auto_generator=false, auto_heal=false, auto_unhook=false, auto_escape=false,
    auto_teleport_survive=false, auto_teleport_range=100,
    -- Movement
    speed_enabled=false, speed_value=35,
    noclip_enabled=false, fly_enabled=false, fly_speed=50,
    moonwalk=false,
    -- Misc
    fullbright_medium=false,
    fps_boost=false,
    anti_lag=false,
    no_fog_enabled=false, anti_afk=true,
    unlock_mouse_enabled=false,
    -- Guard
    guard_enabled=true, max_actions_sec=3, burst_window=1.0,
    min_delay=0.05, max_delay=0.25, jitter=0.03,
    miss_rate=0.08, pause_rate=0.05,
    -- Session
    main_userid=0, alt_userids={},
}
local REMOTES = { parry=nil, attack=nil, skill_check=nil, generator=nil, heal=nil, unhook=nil, escape=nil, hitbox=nil }

-- ============================================================
-- SERVICES & HELPERS
-- ============================================================
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local Lighting=game:GetService("Lighting")
local Workspace=game:GetService("Workspace")
local CoreGui=game:GetService("CoreGui")
local TweenService=game:GetService("TweenService")
local LP=Players.LocalPlayer
local Camera=Workspace.CurrentCamera
local Drawing=Drawing or (syn and syn.drawing)
local rng=Random.new(os.time()+math.floor(tick()*1000))
local function rand(a,b) return rng:NextNumber(a,b) end
local function chance(p) return rng:NextNumber()<p end
local function rgb(c) return Color3.fromRGB(c[1],c[2],c[3]) end
local function dist(a,b) return (a-b).Magnitude end
local function new_d(c,p)
    if not Drawing or not Drawing.new then return nil end
    local ok,d=pcall(Drawing.new,c)
    if not ok then return nil end
    for k,v in pairs(p or {}) do pcall(function() d[k]=v end) end
    return d
end
local function w2s(p)
    local ok,s=pcall(function() return Camera:WorldToViewportPoint(p) end)
    if not ok then return 0,0,false,0 end
    return s.X,s.Y,s.Z>0,s.Z
end
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
getgenv().SpookenD_CONFIG=CONFIG
getgenv().SpookenD_CONNS={}
getgenv().SpookenD_DRAWINGS={}
local function add_conn(c) if c then table.insert(getgenv().SpookenD_CONNS,c) end return c end
local function add_drawing(d) if d then table.insert(getgenv().SpookenD_DRAWINGS,d) end return d end

-- SESSION GUARD
if CONFIG.main_userid ~= 0 and LP.UserId == CONFIG.main_userid then
    local gui=Instance.new("ScreenGui") gui.Name="SpookenD_Blocked" gui.ResetOnSpawn=false gui.Parent=CoreGui
    local f=Instance.new("Frame") f.Size=UDim2.new(0,500,0,100) f.Position=UDim2.new(0.5,-250,0.3,0) f.BackgroundColor3=Color3.fromRGB(180,30,30) f.BorderSizePixel=0 f.Parent=gui
    local t=Instance.new("TextLabel") t.Size=UDim2.new(1,-20,1,-20) t.Position=UDim2.new(0,10,0,10) t.BackgroundTransparency=1 t.Text="⚠ AKUN UTAMA — SpookenD tidak di-load." t.TextColor3=Color3.new(1,1,1) t.Font=Enum.Font.Gotham t.TextSize=16 t.TextWrapped=true t.Parent=f
    return
end

-- GUARD
local buckets={}
local function can_fire(m)
    if not CONFIG.guard_enabled then return true end
    local b=buckets[m]; if not b then b={count=0,reset=tick()} buckets[m]=b end
    if tick()-b.reset>CONFIG.burst_window then b.count=0 b.reset=tick() end
    if b.count>=CONFIG.max_actions_sec then return false end
    b.count=b.count+1; return true
end
pcall(function()
    if hookfunction and getrawmetatable and newcclosure then
        local mt=getrawmetatable(game)
        if setreadonly then setreadonly(mt,false) end
        local old=mt.__namecall
        mt.__namecall=newcclosure(function(self,...)
            local ok,m=pcall(getnamecallmethod)
            if ok and (m=="FireServer" or m=="InvokeServer" or m=="Fire") then
                if not can_fire(m) then return nil end
                if chance(CONFIG.miss_rate) then return nil end
                if chance(CONFIG.pause_rate) then task.wait(rand(0.5,2.0)) end
                task.wait(rand(CONFIG.min_delay,CONFIG.max_delay)+rand(-CONFIG.jitter,CONFIG.jitter))
            end
            return old(self,...)
        end)
        if setreadonly then setreadonly(mt,true) end
    end
end)

-- ============================================================
-- ESP
-- ============================================================
local esp_cache={}
local function get_or_create_esp(obj,color)
    local c=esp_cache[obj]; if c then return c end
    local box=new_d("Square",{Thickness=1,Filled=false,Visible=false,Color=rgb(color)})
    local text=new_d("Text",{Size=14,Center=true,Outline=true,Visible=false,Color=rgb(color)})
    if not box or not text then return nil end
    add_drawing(box); add_drawing(text)
    c={box=box,text=text,color=color}; esp_cache[obj]=c; return c
end
local function hide_esp(c)
    if not c then return end
    pcall(function() if c.box then c.box.Visible=false end end)
    pcall(function() if c.text then c.text.Visible=false end end)
end
local esp_accum=0
local function update_esp(dt)
    esp_accum=esp_accum+dt; if esp_accum<1/30 then return end; esp_accum=0
    if not CONFIG.esp_enabled then for _,c in pairs(esp_cache) do hide_esp(c) end; return end
    local mc=LP.Character; local mh=mc and mc:FindFirstChild("HumanoidRootPart"); if not mh then return end
    local mp=mh.Position
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP then
            local role=get_role(plr)
            local want=(role=="Killer" and CONFIG.esp_killer) or (role=="Survivor" and CONFIG.esp_survivor)
            local char=plr.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); local head=char and char:FindFirstChild("Head")
            if want and hrp and head then
                local d=dist(mp,hrp.Position)
                if d<=CONFIG.esp_max_dist then
                    local color=role=="Killer" and CONFIG.color_killer or CONFIG.color_survivor
                    local c=get_or_create_esp(plr,color)
                    if c then
                        local hx,hy,hon=w2s(head.Position); local rx,ry,ron=w2s(hrp.Position)
                        if hon and ron then
                            local top,bot=math.min(hy,ry),math.max(hy,ry); local h=bot-top; local w=h*0.6; local cx=(hx+rx)/2
                            pcall(function()
                                c.box.Size=Vector2.new(w,h); c.box.Position=Vector2.new(cx-w/2,top); c.box.Visible=true
                                c.text.Position=Vector2.new(cx,top-14); c.text.Text=string.format("%s [%s] %dm",plr.Name,role or "?",math.floor(d)); c.text.Visible=true
                            end)
                        else hide_esp(c) end
                    end
                else hide_esp(esp_cache[plr]) end
            else hide_esp(esp_cache[plr]) end
        end
    end
    local want_names={}
    if CONFIG.esp_generator then want_names.generator=CONFIG.color_generator end
    if CONFIG.esp_hook then want_names.hook=CONFIG.color_hook end
    if CONFIG.esp_pallet then want_names.pallet=CONFIG.color_pallet end
    if CONFIG.esp_window then want_names.window=CONFIG.color_window end
    if CONFIG.esp_gate then want_names.gate=CONFIG.color_gate end
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local nl=obj.Name:lower()
            for key,color in pairs(want_names) do
                if nl:find(key) then
                    local d=dist(mp,obj.Position)
                    if d<=CONFIG.esp_max_dist then
                        local c=get_or_create_esp(obj,color)
                        if c then
                            local x,y,on=w2s(obj.Position)
                            if on then pcall(function()
                                c.box.Size=Vector2.new(20,20); c.box.Position=Vector2.new(x-10,y-10); c.box.Visible=true
                                c.text.Position=Vector2.new(x,y-24); c.text.Text=string.format("%s %dm",obj.Name,math.floor(d)); c.text.Visible=true
                            end) else hide_esp(c) end
                        end
                    end
                    break
                end
            end
        end
    end
end

-- ============================================================
-- COMBAT & HITBOX
-- ============================================================
local function update_parry()
    if not CONFIG.auto_parry or not REMOTES.parry then return end
    local mc=LP.Character; local mh=mc and mc:FindFirstChild("HumanoidRootPart"); if not mh then return end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP and get_role(plr)=="Killer" then
            local kh=plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if kh and dist(mh.Position,kh.Position)<=CONFIG.parry_range then pcall(function() REMOTES.parry:FireServer() end) end
        end
    end
end

local function find_aim_target()
    local vp=Camera.ViewportSize; local center=Vector2.new(vp.X/2,vp.Y/2); local best,bd=nil,math.huge
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP and get_role(plr)==CONFIG.aim_target then
            local char=plr.Character; local part=char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
            if part then
                local sx,sy,on=w2s(part.Position)
                if on then local d=(Vector2.new(sx,sy)-center).Magnitude if d<=CONFIG.aim_fov and d<bd then best,bd={plr=plr,part=part},d end end
            end
        end
    end
    return best
end
local function update_silent_aim()
    if not CONFIG.silent_aim or not REMOTES.attack then return end
    local t=find_aim_target(); if t then pcall(function() REMOTES.attack:FireServer(t.part) end) end
end

local aura_accum=0
local function update_kill_aura(dt)
    if not CONFIG.kill_aura or not REMOTES.attack then return end
    aura_accum=aura_accum+dt; if aura_accum<CONFIG.aura_rate then return end; aura_accum=0
    local mc=LP.Character; local mh=mc and mc:FindFirstChild("HumanoidRootPart"); if not mh then return end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP and get_role(plr)=="Survivor" then
            local sh=plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if sh and dist(mh.Position,sh.Position)<=CONFIG.aura_range then pcall(function() REMOTES.attack:FireServer(sh) end) end
        end
    end
end

local skill_cd=0
local function update_skill_check(dt)
    if not CONFIG.auto_skill_check then return end
    skill_cd=skill_cd+dt; if skill_cd<CONFIG.skill_check_cd then return end; skill_cd=0
    local pg=LP:FindFirstChild("PlayerGui"); if not pg then return end
    for _,g in ipairs(pg:GetDescendants()) do
        if g:IsA("GuiObject") and g.Visible then
            local n=g.Name:lower()
            if n:find("skill") or n:find("check") then
                if g:IsA("TextButton") or g:IsA("ImageButton") then pcall(function() g:Activate() end) end
            end
        end
    end
end

local function apply_hitbox()
    if not CONFIG.hitbox_survivor then return end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP and get_role(plr)=="Survivor" then
            local char=plr.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                pcall(function()
                    hrp.Size=Vector3.new(CONFIG.hitbox_size,CONFIG.hitbox_size,CONFIG.hitbox_size)
                    hrp.Transparency=0.7
                    hrp.CanCollide=false
                end)
            end
        end
    end
end
local function reset_hitbox()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP then
            local char=plr.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then pcall(function() hrp.Size=Vector3.new(2,2,1) hrp.Transparency=1 hrp.CanCollide=true end) end
        end
    end
end

-- ============================================================
-- AUTO SURVIVOR & TELEPORT
-- ============================================================
local gen_accum=0
local function auto_gen(dt)
    if not CONFIG.auto_generator then return end
    gen_accum=gen_accum+dt; if gen_accum<0.5 then return end; gen_accum=0
    local mc=LP.Character; local mh=mc and mc:FindFirstChild("HumanoidRootPart"); if not mh then return end
    local nearest,nd=nil,math.huge
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("generator") then
            local d=(mh.Position-obj.Position).Magnitude if d<nd and d<15 then nearest,nd=obj,d end
        end
    end
    if not nearest then return end
    local prompt=nearest:FindFirstChildOfClass("ProximityPrompt")
    if prompt and fireproximityprompt then pcall(fireproximityprompt,prompt) return end
    if REMOTES.generator then pcall(function() REMOTES.generator:FireServer(nearest) end) return end
end

local heal_accum=0
local function auto_heal(dt)
    if not CONFIG.auto_heal then return end
    heal_accum=heal_accum+dt; if heal_accum<1 then return end; heal_accum=0
    local mc=LP.Character; local hum=mc and mc:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if hum.Health>=hum.MaxHealth*0.8 then return end
    local bp=LP:FindFirstChild("Backpack")
    if bp then for _,tool in ipairs(bp:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("heal") or tool.Name:lower():find("med")) then
            pcall(function() tool.Parent=mc task.wait(0.1) tool:Activate() end); return
        end
    end end
    if REMOTES.heal then pcall(function() REMOTES.heal:FireServer() end) end
end

local function auto_unhook()
    if not CONFIG.auto_unhook then return end
    local mc=LP.Character; local mh=mc and mc:FindFirstChild("HumanoidRootPart"); if not mh then return end
    local hooked=false
    pcall(function() hooked=mh.Anchored end)
    local ok,attr=pcall(function() return LP:GetAttribute("Hooked") end) if ok and attr==true then hooked=true end
    local hum=mc:FindFirstChildOfClass("Humanoid") if hum and hum:GetState()==Enum.HumanoidStateType.Physics then hooked=true end
    if hooked and REMOTES.unhook then pcall(function() REMOTES.unhook:FireServer() end) end
end

local esc_accum=0
local function auto_escape(dt)
    if not CONFIG.auto_escape then return end
    esc_accum=esc_accum+dt; if esc_accum<0.5 then return end; esc_accum=0
    local mc=LP.Character; local mh=mc and mc:FindFirstChild("HumanoidRootPart"); if not mh then return end
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("exit") or obj.Name:lower():find("gate")) then
            if (mh.Position-obj.Position).Magnitude<20 then
                local prompt=obj:FindFirstChildOfClass("ProximityPrompt")
                if prompt and fireproximityprompt then pcall(fireproximityprompt,prompt) return end
                if REMOTES.escape then pcall(function() REMOTES.escape:FireServer(obj) end) return end
            end
        end
    end
end

local function auto_teleport_survive()
    if not CONFIG.auto_teleport_survive then return end
    local mc=LP.Character; local mh=mc and mc:FindFirstChild("HumanoidRootPart"); if not mh then return end
    local target=nil
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP and get_role(plr)=="Survivor" then
            local sh=plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if sh and (mh.Position-sh.Position).Magnitude<=CONFIG.auto_teleport_range then target=sh end
        end
    end
    if target then pcall(function() mh.CFrame=target.CFrame*CFrame.new(0,0,3) end) end
end

-- ============================================================
-- MOVEMENT & MISC
-- ============================================================
local function apply_movement()
    local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid"); if not hum then return end
    pcall(function() hum.WalkSpeed = CONFIG.speed_enabled and CONFIG.speed_value or 16 end)
end
local function update_noclip()
    if not CONFIG.noclip_enabled then return end
    local char=LP.Character
    if char then for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then pcall(function() p.CanCollide=false end) end end end
end

local fly_conn=nil
local function toggle_fly()
    if fly_conn then pcall(function() fly_conn:Disconnect() end); fly_conn=nil end
    if not CONFIG.fly_enabled then
        local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.PlatformStand=false end) end; return
    end
    local char=LP.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); local hum=char and char:FindFirstChildOfClass("Humanoid")
    if hrp and hum then
        pcall(function() hum.PlatformStand=true end)
        fly_conn=RunService.RenderStepped:Connect(function(dt)
            pcall(function()
                local move=Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move=move+Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move=move-Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move=move-Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move=move+Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move=move+Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move=move-Vector3.new(0,1,0) end
                if move.Magnitude>0 and hrp.Parent then hrp.CFrame=hrp.CFrame+move.Unit*CONFIG.fly_speed*dt end
            end)
        end)
        add_conn(fly_conn)
    end
end

local moon_conn=nil
local function toggle_moon()
    if moon_conn then pcall(function() moon_conn:Disconnect() end); moon_conn=nil end
    if not CONFIG.moonwalk then return end
    moon_conn=RunService.RenderStepped:Connect(function()
        pcall(function()
            local mc=LP.Character; local hum=mc and mc:FindFirstChildOfClass("Humanoid"); if not hum then return end
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                local hrp=mc:FindFirstChild("HumanoidRootPart")
                if hrp then local spd=math.clamp(hum.WalkSpeed,0,100) hrp.CFrame=hrp.CFrame-Camera.CFrame.LookVector*spd*0.016 end
            end
        end)
    end)
    add_conn(moon_conn)
end

-- FULLBRIGHT MEDIUM: ambient 0.6, outdoor 0.6, brightness 2 (bukan 3)
local function apply_fullbright_medium()
    if CONFIG.fullbright_medium then
        pcall(function()
            Lighting.Ambient=Color3.fromRGB(150,150,150)
            Lighting.OutdoorAmbient=Color3.fromRGB(150,150,150)
            Lighting.Brightness=2
            Lighting.ClockTime=14
        end)
    else
        pcall(function()
            Lighting.Ambient=Color3.fromRGB(70,70,70)
            Lighting.OutdoorAmbient=Color3.fromRGB(128,128,128)
            Lighting.Brightness=1
            Lighting.ClockTime=14.5
        end)
    end
end
local function apply_misc()
    apply_fullbright_medium()
    if CONFIG.no_fog_enabled then pcall(function() Lighting.FogEnd=100000 Lighting.FogStart=100000 end) end
end

-- FPS BOOST + ANTI LAG: matiin effects berat, kurangi particle, texture quality
local function apply_fps_boost()
    if not CONFIG.fps_boost then return end
    pcall(function()
        settings().Rendering.QualityLevel=Enum.QualityLevel.Level01
        for _,v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                v.Enabled=false
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency=1
            elseif v:IsA("BasePart") and v.Material~=Enum.Material.SmoothPlastic then
                v.Material=Enum.Material.SmoothPlastic
            end
        end
    end)
end
local function apply_anti_lag()
    if not CONFIG.anti_lag then return end
    pcall(function()
        for _,v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") then v.Enabled=false end
        end
        local terrain=Workspace:FindFirstChildOfClass("Terrain")
        if terrain then terrain.WaterWaveSize=0 terrain.WaterWaveSpeed=0 end
    end)
end

if CONFIG.anti_afk then
    local c=LP.Idled:Connect(function()
        pcall(function()
            local vu=game:GetService("VirtualUser"); vu:CaptureController(); vu:ClickButton2(Vector2.new())
        end)
    end)
    add_conn(c)
end

local unlock_conn=nil
local function toggle_unlock_mouse()
    if unlock_conn then pcall(function() unlock_conn:Disconnect() end); unlock_conn=nil; pcall(function() UserInputService.MouseBehavior=Enum.MouseBehavior.Default end) end
    if not CONFIG.unlock_mouse_enabled then return end
    unlock_conn=RunService.RenderStepped:Connect(function()
        pcall(function()
            UserInputService.MouseBehavior=Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled=true
        end)
    end)
    add_conn(unlock_conn)
end

-- ============================================================
-- UI — MIRIP REFERENSI (Sidebar kiri, panel kanan, header badge)
-- ============================================================
local COLORS = {
    bg        = Color3.fromRGB(20,20,24),
    sidebar   = Color3.fromRGB(16,16,20),
    panel     = Color3.fromRGB(28,28,34),
    card      = Color3.fromRGB(38,38,46),
    accent    = Color3.fromRGB(0,180,255),
    green     = Color3.fromRGB(50,210,120),
    text      = Color3.fromRGB(230,230,235),
    subtext   = Color3.fromRGB(140,140,150),
    border    = Color3.fromRGB(45,45,55),
}
local FONT = Enum.Font.Gotham
local FONT_BOLD = Enum.Font.GothamBold

local function make_round(parent, radius)
    local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,radius or 6); c.Parent=parent; return c
end
local function make_stroke(parent, color, thick)
    local s=Instance.new("UIStroke"); s.Color=color or COLORS.border; s.Thickness=thick or 1; s.Parent=parent; return s
end
local function make_pad(parent, all)
    local p=Instance.new("UIPadding")
    p.PaddingTop=UDim.new(0,all or 8); p.PaddingBottom=UDim.new(0,all or 8)
    p.PaddingLeft=UDim.new(0,all or 8); p.PaddingRight=UDim.new(0,all or 8)
    p.Parent=parent; return p
end

local is_mobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local BASE_W = is_mobile and 320 or 580
local BASE_H = is_mobile and 380 or 400

-- ScreenGui dengan Scale (biar pas di HP)
local gui = Instance.new("ScreenGui")
gui.Name = "VD_Mobile_"..tostring(math.random(1000,9999))
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = CoreGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, BASE_W, 0, BASE_H)
main.Position = UDim2.new(0.5, -BASE_W/2, 0.5, -BASE_H/2)
main.BackgroundColor3 = COLORS.bg
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
main.Parent = gui
make_round(main, 10)
make_stroke(main, COLORS.border, 1)

-- Drag (mouse + touch)
do
    local dragging, dragStart, startPos
    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    main.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    main.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- HEADER (badge profile + close)
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = COLORS.sidebar
header.BorderSizePixel = 0
header.Parent = main
make_round(header, 10)

local logoIcon = Instance.new("TextLabel")
logoIcon.Size = UDim2.new(0, 24, 0, 24)
logoIcon.Position = UDim2.new(0, 14, 0.5, -12)
logoIcon.BackgroundTransparency = 1
logoIcon.Text = "🛡"
logoIcon.TextColor3 = COLORS.text
logoIcon.TextSize = 18
logoIcon.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 160, 0, 16)
title.Position = UDim2.new(0, 46, 0, 10)
title.BackgroundTransparency = 1
title.Text = "VIOLENCE DISTRICT"
title.TextColor3 = COLORS.text
title.Font = FONT_BOLD
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(0, 200, 0, 14)
subtitle.Position = UDim2.new(0, 46, 0, 26)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Welcome, " .. LP.Name
subtitle.TextColor3 = COLORS.subtext
subtitle.Font = FONT
subtitle.TextSize = 10
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

-- Badge "UNLOCKED" hijau
local badge = Instance.new("Frame")
badge.Size = UDim2.new(0, 80, 0, 20)
badge.Position = UDim2.new(1, -110, 0.5, -10)
badge.BackgroundColor3 = COLORS.green
badge.BorderSizePixel = 0
badge.Parent = header
make_round(badge, 4)
local badgeText = Instance.new("TextLabel")
badgeText.Size = UDim2.new(1, 0, 1, 0)
badgeText.BackgroundTransparency = 1
badgeText.Text = "UNLOCKED"
badgeText.TextColor3 = Color3.fromRGB(20,40,25)
badgeText.Font = FONT_BOLD
badgeText.TextSize = 10
badgeText.Parent = badge

-- Badge "@username" biru
local userBadge = Instance.new("Frame")
userBadge.Size = UDim2.new(0, 90, 0, 20)
userBadge.Position = UDim2.new(1, -200, 0.5, -10)
userBadge.BackgroundColor3 = COLORS.accent
userBadge.BorderSizePixel = 0
userBadge.Parent = header
make_round(userBadge, 4)
local userText = Instance.new("TextLabel")
userText.Size = UDim2.new(1, 0, 1, 0)
userText.BackgroundTransparency = 1
userText.Text = "@" .. LP.Name
userText.TextColor3 = Color3.new(1,1,1)
userText.Font = FONT_BOLD
userText.TextSize = 9
userText.Parent = userBadge

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -34, 0.5, -12)
closeBtn.BackgroundColor3 = Color3.fromRGB(60,30,30)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "×"
closeBtn.TextColor3 = COLORS.text
closeBtn.Font = FONT_BOLD
closeBtn.TextSize = 14
closeBtn.Parent = header
make_round(closeBtn, 4)
closeBtn.MouseButton1Click:Connect(function() gui.Enabled = not gui.Enabled end)

-- BODY: sidebar + panel
local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -48)
body.Position = UDim2.new(0, 0, 0, 48)
body.BackgroundTransparency = 1
body.Parent = main

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, is_mobile and 100 or 150, 1, 0)
sidebar.BackgroundColor3 = COLORS.sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = body

local panel = Instance.new("ScrollingFrame")
panel.Size = UDim2.new(1, -(is_mobile and 100 or 150), 1, 0)
panel.Position = UDim2.new(0, is_mobile and 100 or 150, 0, 0)
panel.BackgroundColor3 = COLORS.panel
panel.BorderSizePixel = 0
panel.ScrollBarThickness = 3
panel.ScrollBarImageColor3 = COLORS.accent
panel.CanvasSize = UDim2.new(0, 0, 0, 0)
panel.Parent = body

-- Sidebar tabs
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
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -8, 0, 32)
    b.Position = UDim2.new(0, 4, 0, 8 + (i-1)*36)
    b.BackgroundColor3 = COLORS.sidebar
    b.BorderSizePixel = 0
    b.Text = "  " .. name
    b.TextColor3 = COLORS.subtext
    b.Font = FONT
    b.TextSize = 12
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Parent = sidebar
    make_round(b, 6)
    b:SetAttribute("TabName", name)
    b.MouseButton1Click:Connect(function() switch_tab(name) end)
    tabButtons[name] = b

    local p = Instance.new("ScrollingFrame")
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 0
    p.CanvasSize = UDim2.new(0, 0, 0, 0)
    p.Visible = false
    p.Parent = panel
    pages[name] = p
end

-- Helper: card + toggle
local function make_card(parent, title, desc, get, set)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -16, 0, desc and 56 or 44)
    card.Position = UDim2.new(0, 8, 0, parent:GetAttribute("y") or 8)
    card.BackgroundColor3 = COLORS.card
    card.BorderSizePixel = 0
    card.Parent = parent
    make_round(card, 6)
    parent:SetAttribute("y", card.Position.Y.Offset + card.Size.Y.Offset + 6)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -60, 0, desc and 22 or 44)
    t.Position = UDim2.new(0, 10, 0, desc and 4 or 0)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = COLORS.text
    t.Font = FONT_BOLD
    t.TextSize = 12
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = card

    if desc then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, -60, 0, 24)
        d.Position = UDim2.new(0, 10, 0, 24)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = COLORS.subtext
        d.Font = FONT
        d.TextSize = 10
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.TextWrapped = true
        d.Parent = card
    end

    -- toggle switch biru
    local sw = Instance.new("Frame")
    sw.Size = UDim2.new(0, 32, 0, 18)
    sw.Position = UDim2.new(1, -44, 0.5, -9)
    sw.BackgroundColor3 = get() and COLORS.accent or Color3.fromRGB(60,60,70)
    sw.BorderSizePixel = 0
    sw.Parent = card
    make_round(sw, 9)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = get() and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.BorderSizePixel = 0
    knob.Parent = sw
    make_round(knob, 7)

    local click = Instance.new("TextButton")
    click.Size = UDim2.new(1, 0, 1, 0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.Parent = card
    click.MouseButton1Click:Connect(function()
        pcall(function()
            set(not get())
            sw.BackgroundColor3 = get() and COLORS.accent or Color3.fromRGB(60,60,70)
            knob.Position = get() and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        end)
    end)
    return card
end

local function make_action(parent, title, desc, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -16, 0, desc and 56 or 44)
    card.Position = UDim2.new(0, 8, 0, parent:GetAttribute("y") or 8)
    card.BackgroundColor3 = COLORS.card
    card.BorderSizePixel = 0
    card.Parent = parent
    make_round(card, 6)
    parent:SetAttribute("y", card.Position.Y.Offset + card.Size.Y.Offset + 6)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -60, 0, desc and 22 or 44)
    t.Position = UDim2.new(0, 10, 0, desc and 4 or 0)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = COLORS.text
    t.Font = FONT_BOLD
    t.TextSize = 12
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = card

    if desc then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, -60, 0, 24)
        d.Position = UDim2.new(0, 10, 0, 24)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = COLORS.subtext
        d.Font = FONT
        d.TextSize = 10
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.TextWrapped = true
        d.Parent = card
    end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 32, 0, 32)
    btn.Position = UDim2.new(1, -44, 0.5, -16)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,60)
    btn.BorderSizePixel = 0
    btn.Text = "⚡"
    btn.TextColor3 = COLORS.text
    btn.Font = FONT
    btn.TextSize = 14
    btn.Parent = card
    make_round(btn, 6)
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
    return card
end

-- MAIN PAGE
local mainPage = pages["Main"]
mainPage:SetAttribute("y", 8)
make_card(mainPage, "ESP Enabled", "Tampilkan semua ESP", function() return CONFIG.esp_enabled end, function(v) CONFIG.esp_enabled=v end)
make_card(mainPage, "Killer ESP", "Highlight Killer", function() return CONFIG.esp_killer end, function(v) CONFIG.esp_killer=v end)
make_card(mainPage, "Survivor ESP", "Highlight Survivor", function() return CONFIG.esp_survivor end, function(v) CONFIG.esp_survivor=v end)
make_card(mainPage, "Generator ESP", "Highlight Generator", function() return CONFIG.esp_generator end, function(v) CONFIG.esp_generator=v end)

-- TELEPORT PAGE
local tpPage = pages["Teleport"]
tpPage:SetAttribute("y", 8)
make_card(tpPage, "Auto Teleport Survive", "Teleport ke survivor terdekat", function() return CONFIG.auto_teleport_survive end, function(v) CONFIG.auto_teleport_survive=v end)

-- AUTO PAGE
local autoPage = pages["Auto"]
autoPage:SetAttribute("y", 8)
make_card(autoPage, "Auto Generator", "Selesaikan generator otomatis", function() return CONFIG.auto_generator end, function(v) CONFIG.auto_generator=v end)
make_card(autoPage, "Auto Heal", "Heal diri sendiri saat HP turun", function() return CONFIG.auto_heal end, function(v) CONFIG.auto_heal=v end)
make_card(autoPage, "Auto Unhook", "Lepas diri dari hook", function() return CONFIG.auto_unhook end, function(v) CONFIG.auto_unhook=v end)
make_card(autoPage, "Auto Escape", "Pergi ke exit gate otomatis", function() return CONFIG.auto_escape end, function(v) CONFIG.auto_escape=v end)
make_card(autoPage, "Auto Skill Check", "Selesaikan skill check otomatis", function() return CONFIG.auto_skill_check end, function(v) CONFIG.auto_skill_check=v end)

-- KILLER PAGE
local killerPage = pages["Killer"]
killerPage:SetAttribute("y", 8)
make_card(killerPage, "Hitbox for Survivor Players", "Perbesar hitbox survivor ke 10 studs", function() return CONFIG.hitbox_survivor end, function(v) CONFIG.hitbox_survivor=v apply_hitbox() end)
make_action(killerPage, "Apply Hitbox Now", "Paksa hitbox survivor jadi 10 studs", function() CONFIG.hitbox_survivor=true apply_hitbox() end)
make_action(killerPage, "Reset All Hitboxes", "Kembalikan hitbox survivor ke normal", function() CONFIG.hitbox_survivor=false reset_hitbox() end)
make_card(killerPage, "Auto Parry", "Parry otomatis saat killer dekat", function() return CONFIG.auto_parry end, function(v) CONFIG.auto_parry=v end)
make_card(killerPage, "Silent Aim", "Aim otomatis ke target", function() return CONFIG.silent_aim end, function(v) CONFIG.silent_aim=v end)
make_card(killerPage, "Kill Aura", "Serang survivor di sekitar", function() return CONFIG.kill_aura end, function(v) CONFIG.kill_aura=v end)

-- SETTINGS PAGE
local settingsPage = pages["Settings"]
settingsPage:SetAttribute("y", 8)
make_card(settingsPage, "Fullbright Medium", "Terang tapi tidak menyilaukan", function() return CONFIG.fullbright_medium end, function(v) CONFIG.fullbright_medium=v apply_fullbright_medium() end)
make_card(settingsPage, "FPS Boost", "Matikan efek berat buat naikin FPS", function() return CONFIG.fps_boost end, function(v) CONFIG.fps_boost=v apply_fps_boost() end)
make_card(settingsPage, "Anti Lag", "Kurangi particle & efek air", function() return CONFIG.anti_lag end, function(v) CONFIG.anti_lag=v apply_anti_lag() end)
make_card(settingsPage, "No Fog", "Hilangkan kabut", function() return CONFIG.no_fog_enabled end, function(v) CONFIG.no_fog_enabled=v apply_misc() end)
make_card(settingsPage, "Speed", "Jalan lebih cepat", function() return CONFIG.speed_enabled end, function(v) CONFIG.speed_enabled=v apply_movement() end)
make_card(settingsPage, "Noclip", "Tembus dinding", function() return CONFIG.noclip_enabled end, function(v) CONFIG.noclip_enabled=v end)
make_card(settingsPage, "Fly", "Terbang", function() return CONFIG.fly_enabled end, function(v) CONFIG.fly_enabled=v toggle_fly() end)
make_card(settingsPage, "Moonwalk", "Jalan mundur", function() return CONFIG.moonwalk end, function(v) CONFIG.moonwalk=v toggle_moon() end)
make_card(settingsPage, "Unlock Mouse", "Bebaskan mouse dari lock", function() return CONFIG.unlock_mouse_enabled end, function(v) CONFIG.unlock_mouse_enabled=v toggle_unlock_mouse() end)

-- Footer profile (sidebar bottom)
local footer = Instance.new("Frame")
footer.Size = UDim2.new(1, 0, 0, 56)
footer.Position = UDim2.new(0, 0, 1, -56)
footer.BackgroundColor3 = COLORS.sidebar
footer.BorderSizePixel = 0
footer.Parent = sidebar

local avatar = Instance.new("ImageLabel")
avatar.Size = UDim2.new(0, 28, 0, 28)
avatar.Position = UDim2.new(0, 8, 0.5, -14)
avatar.BackgroundColor3 = COLORS.card
avatar.BorderSizePixel = 0
avatar.Image = "rbxthumb://type=Avatar&id="..LP.UserId.."&w=48&h=48"
avatar.Parent = footer
make_round(avatar, 14)

local uname = Instance.new("TextLabel")
uname.Size = UDim2.new(1, -44, 0, 14)
uname.Position = UDim2.new(0, 42, 0, 14)
uname.BackgroundTransparency = 1
uname.Text = LP.DisplayName
uname.TextColor3 = COLORS.text
uname.Font = FONT_BOLD
uname.TextSize = 10
uname.TextXAlignment = Enum.TextXAlignment.Left
uname.Parent = footer

local uid = Instance.new("TextLabel")
uid.Size = UDim2.new(1, -44, 0, 12)
uid.Position = UDim2.new(0, 42, 0, 28)
uid.BackgroundTransparency = 1
uid.Text = "@" .. LP.Name
uid.TextColor3 = COLORS.subtext
uid.Font = FONT
uid.TextSize = 9
uid.TextXAlignment = Enum.TextXAlignment.Left
uid.Parent = footer

-- Set default tab
switch_tab("Main")
pages["Main"]:SetAttribute("y", 8)

-- ============================================================
-- MAIN LOOP
-- ============================================================
apply_movement()
apply_misc()
apply_fps_boost()
apply_anti_lag()

RunService.RenderStepped:Connect(function(dt)
    pcall(update_esp, dt)
    pcall(update_parry)
    pcall(update_silent_aim)
    pcall(update_kill_aura, dt)
    pcall(update_skill_check, dt)
    pcall(update_noclip)
    pcall(auto_gen, dt)
    pcall(auto_heal, dt)
    pcall(auto_unhook)
    pcall(auto_escape, dt)
    pcall(auto_teleport_survive)
end)

print("[SpookenD] V2 loaded. Mobile friendly, anti-lag, FPS boost, fullbright medium.")
