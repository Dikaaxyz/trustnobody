-- Growblox 67 — Universal Executor Build
-- Works on: Xeno, Delta, Solara, Wave, Codex, Fluxus, AWP, Synapse
-- Feature-detects everything, no Xeno-fatal calls.

--[[ 1. COMPAT SHIM ]]
local function getExecutor()
    if syn and syn.request then return "Synapse" end
    if http and http.request then return "Wave/Codex" end
    if fluxus then return "Fluxus" end
    if KRNL_LOADED then return "Krnl" end
    if identifyexecutor then return identifyexecutor() end
    return "Unknown"
end

local EXEC = getExecutor()
print("[Growblox67] executor detected: " .. EXEC)

-- Universal HTTP
local function httpGet(url)
    local ok, res
    if syn and syn.request then
        ok, res = pcall(function() return syn.request({Url = url, Method = "GET"}).Body end)
        if ok then return res end
    end
    if http and http.request then
        ok, res = pcall(function() return http.request({Url = url, Method = "GET"}).Body end)
        if ok then return res end
    end
    if request then
        ok, res = pcall(function() return request({Url = url, Method = "GET"}).Body end)
        if ok then return res end
    end
    -- fallback: game.HttpGet (works in Xeno with ContentProvider)
    ok, res = pcall(function() return game:HttpGet(url) end)
    if ok then return res end
    return nil
end

-- Universal loadstring (no closures, direct eval)
local function eval(src, chunk)
    if not src then return nil end
    if loadstring then
        local ok, fn = pcall(loadstring, src, chunk or "chunk")
        if ok and fn then
            local eok, err = pcall(fn)
            if not eok then warn("[Growblox] eval error: " .. tostring(err)) end
            return true
        end
    end
    warn("[Growblox] no loadstring available")
    return false
end

-- Universal getgenv
local genv = getgenv and getgenv() or _G

--[[ 2. SERVICES ]]
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local RS         = game:GetService("ReplicatedStorage")
local VS         = game:GetService("VirtualUser")
local WS         = game:GetService("Workspace")
local LP         = Players.LocalPlayer
local cam        = WS.CurrentCamera

--[[ 3. CONFIG ]]
local Config = {
    Reach        = 24,
    MaxFlySpeed  = 80,
    MaxWalkSpeed = 64,
    MaxJumpPower = 120,
    FarmDelay    = 0.4,
    CleanDelay   = 0.25,
    JitterFactor = 0.35,
    ClampFloor   = 0.1,
}

--[[ 4. JITTER ]]
local mr, msq, mlog, mcos, mpi = math.random, math.sqrt, math.log, math.cos, math.pi
local function gauss()
    local u1 = mr() + 1e-9
    local u2 = mr()
    return msq(-2 * mlog(u1)) * mcos(2 * mpi * u2)
end
local function jitterWait(base)
    local dev = gauss() * (base * Config.JitterFactor)
    task.wait(math.max(Config.ClampFloor, base + dev))
end

--[[ 5. REMOTE RESOLVER — Xeno-safe, scan once ]]
local remoteCache = {}
local scanned = false

local function scanRemotes()
    if scanned then return end
    scanned = true
    local containers = {RS, WS}
    for _, container in ipairs(containers) do
        for _, obj in ipairs(container:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local key = obj.Name:lower()
                if not remoteCache[key] then
                    remoteCache[key] = obj
                end
            end
        end
    end
    -- dump to console
    print("=== GROWBLOX REMOTE DUMP ===")
    for name, obj in pairs(remoteCache) do
        if name:find("break") or name:find("place") or name:find("hit")
           or name:find("clean") or name:find("dig") or name:find("collect") then
            print("[TARGET] " .. obj:GetFullName())
        end
    end
    print("=== END DUMP ===")
end

local function resolve(kind)
    scanRemotes()
    for key, obj in pairs(remoteCache) do
        if key:find(kind) then return obj end
    end
    return nil
end

--[[ 6. FIRE — Xeno-safe, no table.pack ]]
local function fireSpoofed(kind, ...)
    local r = resolve(kind)
    if not r then return false end
    local argc = select("#", ...)
    local args = {...}
    local ok = pcall(function()
        -- Xeno rejects tables with `n` field; use varargs directly
        if argc >= 2 then
            r:FireServer(args[1], args[2], LP)
        elseif argc == 1 then
            r:FireServer(args[1], LP)
        else
            r:FireServer(LP)
        end
    end)
    return ok
end

--[[ 7. CHARACTER CACHE — universal, waits for HRP ]]
local char, hum, hrp
local function rebind()
    char = LP.Character
    if char then
        hum = char:FindFirstChildOfClass("Humanoid")
        hrp = char:FindFirstChild("HumanoidRootPart")
    end
end

LP.CharacterAdded:Connect(function(c)
    char = c
    hum = c:WaitForChild("Humanoid", 10)
    hrp = c:WaitForChild("HumanoidRootPart", 10)
end)
rebind()
if not char then
    pcall(function() LP.CharacterAdded:Wait() end)
    rebind()
end

--[[ 8. FLAGS ]]
local F = setmetatable({}, {__index = function() return false end})
local Fset = function(k, v) F[k] = v end

--[[ 9. VELOCITY CLAMP ]]
local function clampVelocity()
    if not hrp then return end
    local v = hrp.AssemblyLinearVelocity
    local speed = v.Magnitude
    if speed > Config.MaxWalkSpeed * 2 then
        hrp.AssemblyLinearVelocity = v * ((Config.MaxWalkSpeed * 2) / speed)
    end
end

--[[ 10. TRACKERS ]]
local trackers = {
    items  = setmetatable({}, {__mode = "k"}),
    blocks = setmetatable({}, {__mode = "k"}),
    dirt   = setmetatable({}, {__mode = "k"}),
    cave   = setmetatable({}, {__mode = "k"}),
}

local function classify(obj)
    if not obj:IsA("BasePart") then return end
    local n = obj.Name:lower()
    if n:find("dirt") then
        trackers.dirt[obj] = true
    elseif n:find("cave") then
        trackers.cave[obj] = true
    elseif n:find("item") or n:find("drop") or n:find("seed") then
        trackers.items[obj] = true
    elseif n:find("block") then
        trackers.blocks[obj] = true
    end
end
for _, v in ipairs(WS:GetDescendants()) do classify(v) end
WS.DescendantAdded:Connect(classify)
WS.DescendantRemoving:Connect(function(obj)
    trackers.items[obj]  = nil
    trackers.blocks[obj] = nil
    trackers.dirt[obj]   = nil
    trackers.cave[obj]   = nil
end)

--[[ 11. MOVEMENT ]]
local flyVel = Vector3.zero
RunService.RenderStepped:Connect(function(dt)
    if not hrp or not hum then return end
    if F.Fly then
        hum.PlatformStand = true
        local d = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then d += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then d -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then d -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then d += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then d += Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d -= Vector3.yAxis end
        if d.Magnitude > 0 then d = d.Unit end
        flyVel = flyVel:Lerp(d * math.min(F.FlySpeed or 60, Config.MaxFlySpeed), 0.3)
        hrp.CFrame += flyVel * dt
    elseif hum.PlatformStand and not F.Fly then
        hum.PlatformStand = false
        flyVel = Vector3.zero
    end
    if F.SuperSpeed then
        hum.WalkSpeed = math.min(F.SpeedValue or 16, Config.MaxWalkSpeed)
    else
        hum.WalkSpeed = 16
    end
    clampVelocity()
end)

--[[ 12. AUTOMATION + CLEAN ]]
local function getNearest(tracker, maxDist)
    local best, bestDist = nil, maxDist or math.huge
    if not hrp then return nil end
    for obj in pairs(tracker) do
        if obj.Parent then
            local d = (obj.Position - hrp.Position).Magnitude
            if d < bestDist then best, bestDist = obj, d end
        end
    end
    return best
end

task.spawn(function()
    while true do
        if F.AutoFarmLoop and hrp then
            local best = getNearest(trackers.blocks, F.FarmRadius or 16)
            if best then
                fireSpoofed("break", best)
                hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(best.Position + Vector3.new(mr(-2,2), 4, mr(-2,2))), 0.2)
            end
            jitterWait(Config.FarmDelay)
        elseif F.AutoCleanDirt and hrp then
            local best = getNearest(trackers.dirt, F.CleanRadius or 32)
            if best then
                fireSpoofed("break", best)
                jitterWait(Config.CleanDelay)
            else
                jitterWait(0.5)
            end
        elseif F.AutoCleanCave and hrp then
            local best = getNearest(trackers.cave, F.CleanRadius or 32)
            if best then
                fireSpoofed("break", best)
                jitterWait(Config.CleanDelay)
            else
                jitterWait(0.5)
            end
        else
            jitterWait(0.3)
        end
    end
end)

--[[ 13. COLLECT ]]
task.spawn(function()
    while true do
        if F.AutoCollect and hrp then
            local best = getNearest(trackers.items, 60)
            if best then
                hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(best.Position + Vector3.new(0,3,0)), 0.22)
            end
            jitterWait(0.12)
        else
            jitterWait(0.4)
        end
    end
end)

--[[ 14. NOCLIP + ANTI-VOID ]]
local ncConn
local function setNoClip(on)
    if ncConn then ncConn:Disconnect() ncConn = nil end
    if not on or not char then return end
    ncConn = RunService.Stepped:Connect(function()
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end

task.spawn(function()
    while true do
        setNoClip(F.NoClip)
        if F.AntiVoid and hrp and hrp.Position.Y < -50 then hrp.CFrame = CFrame.new(0, 60, 0) end
        if F.AntiFall and hrp and hrp.AssemblyLinearVelocity.Y < -100 then
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
        end
        jitterWait(0.15)
    end
end)

--[[ 15. ESP ]]
local espPool, espActive = {}, {}
local function releaseAll()
    for parent, hl in pairs(espActive) do
        hl.Parent = nil
        espPool[#espPool + 1] = hl
        espActive[parent] = nil
    end
end

task.spawn(function()
    local hue = 0
    while task.wait(0.25) do
        if F.ItemESP or F.DirtESP or F.CaveESP then
            hue = (hue + 0.03) % 1
            local col = Color3.fromHSV(hue, 1, 1)
            if F.ItemESP then
                for it in pairs(trackers.items) do
                    if it.Parent and not espActive[it] then
                        local hl = Instance.new("Highlight"); hl.FillColor = col; hl.Parent = it; espActive[it] = hl
                    end
                end
            end
            if F.DirtESP then
                for it in pairs(trackers.dirt) do
                    if it.Parent and not espActive[it] then
                        local hl = Instance.new("Highlight"); hl.FillColor = Color3.fromRGB(139,69,19); hl.Parent = it; espActive[it] = hl
                    end
                end
            end
            if F.CaveESP then
                for it in pairs(trackers.cave) do
                    if it.Parent and not espActive[it] then
                        local hl = Instance.new("Highlight"); hl.FillColor = Color3.fromRGB(50,50,50); hl.Parent = it; espActive[it] = hl
                    end
                end
            end
        else
            releaseAll()
        end
    end
end)

--[[ 16. UI — Deferred, Xeno-safe ]]
-- Xeno's Rayfield load requires character to be spawned. Wait for it.
if not char then
    pcall(function() LP.CharacterAdded:Wait() end)
end

local rayfieldSrc = httpGet("https://sirius.menu/rayfield")
if not rayfieldSrc then
    warn("[Growblox67] Rayfield fetch failed — executing headless mode")
else
    local Rayfield
    local ok, err = pcall(function()
        local fn = loadstring(rayfieldSrc)
        if fn then Rayfield = fn() end
    end)
    if not ok or not Rayfield then
        warn("[Growblox67] Rayfield load failed: " .. tostring(err))
    else
        local Window = Rayfield:CreateWindow({
            Name = "🟢 UnrealDK | Growblox 67",
            LoadingTitle = "Menginisialisasi...",
            LoadingSubtitle = "Universal executor build",
            ConfigurationSaving = { Enabled = true, FolderName = "UnrealDK_Growblox", FileName = "MainConfig" },
            KeySystem = false,
        })

        local T = {
            Farm = Window:CreateTab("🌾 Farming", 4483362458),
            Move = Window:CreateTab("🏃 Movement", 4483362458),
            Vis  = Window:CreateTab("👁️ Visuals", 4483362458),
            Cmb  = Window:CreateTab("⚔️ Combat", 4483362458),
            Cfg  = Window:CreateTab("⚙️ Config", 4483362458),
        }

        local function Toggle(tab, name, flag)
            tab:CreateToggle({Name = name, CurrentValue = false, Flag = flag, Callback = function(v) Fset(flag, v) end})
        end

        T.Farm:CreateSection("Automation")
        Toggle(T.Farm, "Auto Farm Loop", "AutoFarmLoop")
        Toggle(T.Farm, "Auto Collect", "AutoCollect")
        Toggle(T.Farm, "Auto Sell", "AutoSell")
        Toggle(T.Farm, "Auto Buy", "AutoBuy")
        Toggle(T.Farm, "Auto Replant", "AutoReplant")
        T.Farm:CreateSlider({Name = "Farm Radius", Range = {4, 64}, Increment = 1, CurrentValue = 16, Flag = "FarmRadius", Callback = function(v) Fset("FarmRadius", v) end})
        T.Farm:CreateSection("Auto Clean World")
        Toggle(T.Farm, "Auto Clean Dirt", "AutoCleanDirt")
        Toggle(T.Farm, "Auto Clean Cave", "AutoCleanCave")
        T.Farm:CreateSlider({Name = "Clean Radius", Range = {8, 64}, Increment = 1, CurrentValue = 32, Flag = "CleanRadius", Callback = function(v) Fset("CleanRadius", v) end})

        T.Move:CreateSection("Speed")
        T.Move:CreateSlider({Name = "Walkspeed", Range = {16, 64}, Increment = 1, CurrentValue = 16, Flag = "WalkSpeed", Callback = function(v) Fset("SpeedValue", v); Fset("SuperSpeed", v > 16) end})
        Toggle(T.Move, "Fly", "Fly")
        T.Move:CreateSlider({Name = "Fly Speed", Range = {10, 80}, Increment = 5, CurrentValue = 40, Flag = "FlySpeed", Callback = function(v) Fset("FlySpeed", v) end})
        Toggle(T.Move, "NoClip", "NoClip")
        Toggle(T.Move, "Anti-Void", "AntiVoid")
        Toggle(T.Move, "Anti-Fall", "AntiFall")

        T.Vis:CreateSection("ESP")
        Toggle(T.Vis, "Item ESP", "ItemESP")
        Toggle(T.Vis, "Dirt ESP", "DirtESP")
        Toggle(T.Vis, "Cave ESP", "CaveESP")
        Toggle(T.Vis, "Fullbright", "Fullbright")

        T.Cmb:CreateSection("Combat")
        Toggle(T.Cmb, "Kill Aura", "KillAura")
        T.Cmb:CreateSlider({Name = "Reach", Range = {7, 50}, Increment = 1, CurrentValue = 24, Flag = "Reach", Callback = function(v) Fset("Reach", v) end})

        T.Cfg:CreateSection("Safety")
        T.Cfg:CreateButton({Name = "PANIC (kill all + destroy)", Callback = function()
            for k in pairs(F) do if type(F[k]) == "boolean" then F[k] = false end end
            setNoClip(false)
            Rayfield:Destroy()
        end})
    end
end

--[[ 17. FINAL TICKS ]]
task.spawn(function()
    while task.wait(0.1) do
        if F.KillAura and hrp and char then
            local reach = math.min(Config.Reach, F.Reach or 7)
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LP and pl.Character then
                    local ph = pl.Character:FindFirstChild("HumanoidRootPart")
                    if ph and (ph.Position - hrp.Position).Magnitude <= reach then
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then pcall(function() tool:Activate() end) end
                    end
                end
            end
        end
        if F.Fullbright then
            pcall(function() game.Lighting.Ambient = Color3.new(1,1,1) end)
        else
            pcall(function() game.Lighting.Ambient = Color3.new(0.5,0.5,0.5) end)
        end
    end
end)

print("[Growblox67] Universal build loaded on " .. EXEC .. ". Check console for remote dump.")
