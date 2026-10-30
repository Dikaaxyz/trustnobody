-- GRAYS ON TOP — GUI Test (Zero Loops)
if not game:IsLoaded() then game.Loaded:Wait() end
if getgenv().GOTGui then pcall(function() getgenv().GOTGui:Destroy() end) end

local P = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LP = P.LocalPlayer
local CG = game:GetService("CoreGui")

local gui = Instance.new("ScreenGui")
gui.Name="GOT"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=999999
gui.Parent=CG
getgenv().GOTGui=gui

local main=Instance.new("Frame")
main.Size=UDim2.new(0,380,0,300)
main.Position=UDim2.new(0,40,0,40)
main.BackgroundColor3=Color3.fromRGB(8,8,8)
main.BorderSizePixel=0
main.Active=true
main.Parent=gui

local wm=Instance.new("TextLabel")
wm.Size=UDim2.new(1,-24,0,30)
wm.Position=UDim2.new(0,16,0,12)
wm.BackgroundTransparency=1
wm.Text="GRAYS ON TOP (LITE)"
wm.TextColor3=Color3.fromRGB(232,232,232)
wm.Font=Enum.Font.GothamBlack
wm.TextSize=22
wm.TextXAlignment=Enum.TextXAlignment.Left
wm.Parent=main

local lbl=Instance.new("TextLabel")
lbl.Size=UDim2.new(1,-32,1,-60)
lbl.Position=UDim2.new(0,16,0,50)
lbl.BackgroundTransparency=1
lbl.Text="GUI loaded successfully.\n\nIf you see this, memory is fine and the loops were the problem.\n\nPress RShift to hide."
lbl.TextColor3=Color3.fromRGB(140,140,140)
lbl.Font=Enum.Font.Gotham
lbl.TextSize=14
lbl.TextXAlignment=Enum.TextXAlignment.Left
lbl.TextYAlignment=Enum.TextYAlignment.Top
lbl.Parent=main

UIS.InputBegan:Connect(function(i,pr)
    if pr then return end
    if i.KeyCode==Enum.KeyCode.RightShift then main.Visible=not main.Visible end
end)

local drag,ds,sp
wm.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        drag=true
        ds=i.Position
        sp=main.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-ds
        main.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
end)

print("[GRAYS ON TOP] Lite GUI loaded.")
