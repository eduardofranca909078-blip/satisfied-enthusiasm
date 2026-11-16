--========================================================
-- ZEDUX HUB - YOX MENU EDITION (COMPLETO)
--========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- TEMA PADRÃO YOX (Roxo/Roxo Escuro)
local Theme = {
    Main = Color3.fromRGB(20, 18, 25),
    Sidebar = Color3.fromRGB(12, 11, 15),
    Element = Color3.fromRGB(30, 28, 38),
    Accent = Color3.fromRGB(150, 100, 255), 
    Text = Color3.fromRGB(255, 255, 255),
    Muted = Color3.fromRGB(140, 140, 160),
    Border = Color3.fromRGB(45, 42, 55)
}

local Config = {
    ESP = { Enabled = false, Name = false, Box = false, Bone = false, Chams = false },
    Aimbot = { Enabled = false, FOV = 150, Silent = false },
    Triggerbot = { Enabled = false },
    Visuals = { Fullbright = false, NoFog = false }
}

local SelectedPlayer = nil
local ESPObjects = {}
local ChamsTable = {}

-- ==========================================
-- FUNÇÕES BASE
-- ==========================================
local function Create(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quart), props):Play()
end

if CoreGui:FindFirstChild("ZeduxYox") then CoreGui:FindFirstChild("ZeduxYox"):Destroy() end

-- UI PRINCIPAL
local ScreenGui = Create("ScreenGui", {Name = "ZeduxYox", Parent = CoreGui, ResetOnSpawn = false, IgnoreGuiInset = true})
local Main = Create("Frame", {Size = UDim2.new(0, 720, 0, 480), Position = UDim2.new(0.5, -360, 0.5, -240), BackgroundColor3 = Theme.Main, BorderSizePixel = 0, Parent = ScreenGui})
Create("UICorner", {CornerRadius = UDim.new(0, 10)}, Main)
local MainStroke = Create("UIStroke", {Color = Theme.Border, Thickness = 1}, Main)

-- SIDEBAR
local Sidebar = Create("Frame", {Size = UDim2.new(0, 200, 1, 0), BackgroundColor3 = Theme.Sidebar, Parent = Main})
Create("UICorner", {CornerRadius = UDim.new(0, 10)}, Sidebar)

-- PERFIL (EMBAIXO DA SIDEBAR)
local Profile = Create("Frame", {Size = UDim2.new(1, -20, 0, 50), Position = UDim2.new(0, 10, 1, -60), BackgroundColor3 = Theme.Element, Parent = Sidebar})
Create("UICorner", {CornerRadius = UDim.new(0, 6)}, Profile)
local avatar = Create("ImageLabel", {Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0, 10, 0.5, -15), BackgroundColor3 = Theme.Main, Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150", Parent = Profile})
Create("UICorner", {CornerRadius = UDim.new(1, 0)}, avatar)
Create("TextLabel", {Size = UDim2.new(1, -50, 0, 15), Position = UDim2.new(0, 50, 0, 10), BackgroundTransparency = 1, Text = LocalPlayer.Name, TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = Profile})
Create("TextLabel", {Size = UDim2.new(1, -50, 0, 15), Position = UDim2.new(0, 50, 0, 25), BackgroundTransparency = 1, Text = "Basic User", TextColor3 = Theme.Muted, Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, Parent = Profile})

-- NAVEGAÇÃO
local NavScroll = Create("ScrollingFrame", {Size = UDim2.new(1, -20, 1, -80), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1, ScrollBarThickness = 0, Parent = Sidebar, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0,0,0,0)})
Create("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder}, NavScroll)

-- ÁREA DE CONTEÚDO
local ContentArea = Create("Frame", {Size = UDim2.new(1, -200, 1, 0), Position = UDim2.new(0, 200, 0, 0), BackgroundTransparency = 1, Parent = Main})
Create("UIPadding", {PaddingTop = UDim.new(0, 15), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingBottom = UDim.new(0, 15)}, ContentArea)

-- TOPBAR (Pesquisa do YOX)
local TopBar = Create("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = ContentArea})
Create("Frame", {Size = UDim2.new(0, 250, 1, 0), Position = UDim2.new(1, -250, 0, 0), BackgroundColor3 = Theme.Element, Parent = TopBar})
Create("UICorner", {CornerRadius = UDim.new(0, 6)}, TopBar:GetChildren()[1])
Create("TextLabel", {Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = "🔍 Search settings...", TextColor3 = Theme.Muted, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = TopBar:GetChildren()[1]})

local PagesFolder = Create("Frame", {Size = UDim2.new(1, 0, 1, -40), Position = UDim2.new(0, 0, 0, 40), BackgroundTransparency = 1, Parent = ContentArea})
local Pages = {}

-- ==========================================
-- COMPONENTES (YOX STYLE)
-- ==========================================
local function AddPage(name, icon)
    local Page = Create("ScrollingFrame", {Name = name, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Border, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0,0,0,0), Parent = PagesFolder})
    Create("UIListLayout", {Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder}, Page)
    
    local Btn = Create("TextButton", {Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Theme.Sidebar, BackgroundTransparency = 1, Text = "", Parent = NavScroll})
    Create("UICorner", {CornerRadius = UDim.new(0, 6)}, Btn)
    local Label = Create("TextLabel", {Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = icon .. "   " .. name, TextColor3 = Theme.Muted, Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = Btn})
    
    Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Theme.Element, BackgroundTransparency = 0}) end)
    Btn.MouseLeave:Connect(function() if not Page.Visible then Tween(Btn, {BackgroundTransparency = 1}) end end)
    
    Btn.MouseButton1Click:Connect(function()
        for pName, pFrame in pairs(Pages) do pFrame.Visible = (pName == name) end
        for _, child in pairs(NavScroll:GetChildren()) do
            if child:IsA("TextButton") then
                Tween(child, {BackgroundTransparency = 1})
                child:FindFirstChildOfClass("TextLabel").TextColor3 = Theme.Muted
            end
        end
        Tween(Btn, {BackgroundColor3 = Theme.Element, BackgroundTransparency = 0})
        Label.TextColor3 = Theme.Text
    end)
    Pages[name] = Page
    return Page
end

local function AddHeader(page, title, desc)
    local H = Create("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, LayoutOrder = 1, Parent = page})
    Create("TextLabel", {Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = title, TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, Parent = H})
    if desc then Create("TextLabel", {Size = UDim2.new(1, 0, 0, 15), Position = UDim2.new(0, 0, 0, 20), BackgroundTransparency = 1, Text = desc, TextColor3 = Theme.Muted, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = H}) end
    Create("Frame", {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Border, Parent = H})
end

local function AddSection(page, title)
    local S = Create("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.Element, LayoutOrder = #page:GetChildren(), Parent = page})
    Create("UICorner", {CornerRadius = UDim.new(0, 8)}, S)
    Create("UIStroke", {Color = Theme.Border, Thickness = 1}, S)
    Create("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, S)
    Create("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, S)
    Create("TextLabel", {Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1, Text = title, TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = S})
    local Content = Create("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 2, Parent = S})
    Create("UIListLayout", {Padding = UDim.new(0, 8)}, Content)
    return Content
end

local function AddToggle(parent, icon, title, desc, default, callback)
    local F = Create("Frame", {Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, LayoutOrder = #parent:GetChildren(), Parent = parent})
    Create("TextLabel", {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, Text = icon, TextColor3 = Theme.Muted, Font = Enum.Font.GothamBold, TextSize = 14, Parent = F})
    Create("TextLabel", {Size = UDim2.new(1, -80, 0, 15), Position = UDim2.new(0, 25, 0, 2), BackgroundTransparency = 1, Text = title, TextColor3 = Theme.Text, Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = F})
    if desc then Create("TextLabel", {Size = UDim2.new(1, -80, 0, 15), Position = UDim2.new(0, 25, 0, 18), BackgroundTransparency = 1, Text = desc, TextColor3 = Theme.Muted, Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, Parent = F}) end
    
    local Switch = Create("Frame", {Size = UDim2.new(0, 36, 0, 20), Position = UDim2.new(1, -36, 0.5, -10), BackgroundColor3 = Theme.Main, Parent = F})
    Create("UICorner", {CornerRadius = UDim.new(1, 0)}, Switch)
    local Circle = Create("Frame", {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Theme.Muted, Parent = Switch})
    Create("UICorner", {CornerRadius = UDim.new(1, 0)}, Circle)
    
    local state = default
    local Click = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = F})
    if state then Tween(Switch, {BackgroundColor3 = Theme.Accent}); Tween(Circle, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Theme.Text}) end
    
    Click.MouseButton1Click:Connect(function()
        state = not state
        if state then Tween(Switch, {BackgroundColor3 = Theme.Accent}); Tween(Circle, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Theme.Text})
        else Tween(Switch, {BackgroundColor3 = Theme.Main}); Tween(Circle, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Theme.Muted}) end
        if callback then callback(state) end
    end)
end

-- ==========================================
-- CRIAÇÃO DAS PÁGINAS
-- ==========================================
AddPage("Triggerbot", "⏱")
local CombatPage = AddPage("Rage", "⚡")
local ESPPage = AddPage("Visuals", "👁")
AddPage("Explorer", "📁")
AddPage("Players", "👥")
local SoundPage = AddPage("Sound", "🎵")
local ThemesPage = AddPage("Themes", "🎨")
local SettingsPage = AddPage("Settings", "⚙")
local SelfDestructPage = AddPage("Self Destruct", "⚠")

-- ==========================================
-- LÓGICA: TRIGGERBOT & RAGE (AIMBOT)
-- ==========================================
AddHeader(Pages["Triggerbot"], "Triggerbot", "Auto-shoot when crosshair is on target")
local trigSec = AddSection(Pages["Triggerbot"], "Config")
AddToggle(trigSec, "¤", "Enable Triggerbot", "Shoots automatically", false, function(v) Config.Triggerbot.Enabled = v end)

AddHeader(CombatPage, "Rage", "Aimbot & Silent Aim")
local aimSec = AddSection(CombatPage, "Aimbot")
AddToggle(aimSec, "†", "Enable Aimbot", "Locks camera to target", false, function(v) Config.Aimbot.Enabled = v end)
AddToggle(aimSec, "◉", "Silent Aim", "Hits through walls", false, function(v) Config.Aimbot.Silent = v end)

RunService.RenderStepped:Connect(function()
    if Config.Aimbot.Enabled and not Config.Aimbot.Silent then
        local closest, dist = nil, Config.Aimbot.FOV
        local center = Camera.ViewportSize / 2
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if d < dist then dist = d; closest = p.Character.Head end
                end
            end
        end
        if closest then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closest.Position), 0.2) end
    end
    if Config.Triggerbot.Enabled then
        local target = Mouse.Target
        if target and target.Parent then
            local char = target.Parent:FindFirstChildOfClass("Humanoid") and target.Parent or target.Parent.Parent
            if char and char:FindFirstChildOfClass("Humanoid") and char ~= LocalPlayer.Character then
                VirtualUser:CaptureController(); VirtualUser:ClickButton1(Vector2.new(0,0)); task.wait(0.1)
            end
        end
    end
end)

-- ==========================================
-- LÓGICA: VISUALS (ESP COMPLETO)
-- ==========================================
AddHeader(ESPPage, "Visuals", "Player ESP & World")
local espSec = AddSection(ESPPage, "Player ESP")
AddToggle(espSec, "¤", "Enable ESP", "Master switch", false, function(v) Config.ESP.Enabled = v end)
AddToggle(espSec, "♙", "Name ESP", "Show names", false, function(v) Config.ESP.Name = v end)
AddToggle(espSec, "□", "Box ESP", "2D Box", false, function(v) Config.ESP.Box = v end)
AddToggle(espSec, "†", "Bone ESP", "Skeleton", false, function(v) Config.ESP.Bone = v end)
AddToggle(espSec, "◉", "Chams", "Highlight", false, function(v) Config.ESP.Chams = v end)

local worldSec = AddSection(ESPPage, "World")
AddToggle(worldSec, "☀", "Fullbright", "Max brightness", false, function(v) Lighting.Brightness = v and 5 or 1 end)
AddToggle(worldSec, "☁", "Remove Fog", "Clear fog", false, function(v) Lighting.FogEnd = v and 100000 or 1000 end)

-- Lógica do ESP (simplificada para caber)
local Bones = {R15 = {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"}}, R6 = {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}}
RunService.RenderStepped:Connect(function()
    if not Config.ESP.Enabled then
        for _, obj in pairs(ESPObjects) do if obj.Remove then obj:Remove() end end
        table.clear(ESPObjects)
        for _, hl in pairs(ChamsTable) do if hl then hl:Destroy() end end
        table.clear(ChamsTable)
        return
    end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp, head = player.Character.HumanoidRootPart, player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                if Config.ESP.Name then
                    if not ESPObjects["Name_"..player.Name] then ESPObjects["Name_"..player.Name] = Drawing.new("Text"); ESPObjects["Name_"..player.Name].Size = 14; ESPObjects["Name_"..player.Name].Center = true; ESPObjects["Name_"..player.Name].Outline = true end
                    ESPObjects["Name_"..player.Name].Text = player.Name; ESPObjects["Name_"..player.Name].Position = Vector2.new(screenPos.X, screenPos.Y - 40); ESPObjects["Name_"..player.Name].Color = Theme.Accent; ESPObjects["Name_"..player.Name].Visible = true
                elseif ESPObjects["Name_"..player.Name] then ESPObjects["Name_"..player.Name].Visible = false end
                if Config.ESP.Box then
                    if not ESPObjects["Box_"..player.Name] then ESPObjects["Box_"..player.Name] = Drawing.new("Square"); ESPObjects["Box_"..player.Name].Thickness = 1; ESPObjects["Box_"..player.Name].Filled = false end
                    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    local h = math.abs(headPos.Y - legPos.Y)
                    ESPObjects["Box_"..player.Name].Size = Vector2.new(h/2, h); ESPObjects["Box_"..player.Name].Position = Vector2.new(screenPos.X - h/4, headPos.Y); ESPObjects["Box_"..player.Name].Color = Theme.Accent; ESPObjects["Box_"..player.Name].Visible = true
                elseif ESPObjects["Box_"..player.Name] then ESPObjects["Box_"..player.Name].Visible = false end
                if Config.ESP.Bone then
                    local isR15 = player.Character:FindFirstChild("UpperTorso") ~= nil
                    local bonesList = isR15 and Bones.R15 or Bones.R6
                    for i, bp in ipairs(bonesList) do
                        local p1, p2 = player.Character:FindFirstChild(bp[1]), player.Character:FindFirstChild(bp[2])
                        local key = "Bone_"..player.Name.."_"..i
                        if p1 and p2 then
                            if not ESPObjects[key] then ESPObjects[key] = Drawing.new("Line"); ESPObjects[key].Thickness = 1 end
                            local sp1, on1 = Camera:WorldToViewportPoint(p1.Position)
                            local sp2, on2 = Camera:WorldToViewportPoint(p2.Position)
                            if on1 and on2 then ESPObjects[key].From = Vector2.new(sp1.X, sp1.Y); ESPObjects[key].To = Vector2.new(sp2.X, sp2.Y); ESPObjects[key].Color = Theme.Accent; ESPObjects[key].Visible = true else ESPObjects[key].Visible = false end
                        end
                    end
                else for key, obj in pairs(ESPObjects) do if string.find(key, "Bone_"..player.Name) then obj.Visible = false end end end
            else for key, obj in pairs(ESPObjects) do if string.find(key, player.Name) then obj.Visible = false end end end
            if Config.ESP.Chams then
                if not ChamsTable[player.Name] and player.Character then
                    local hl = Instance.new("Highlight"); hl.Adornee = player.Character; hl.FillColor = Theme.Accent; hl.OutlineColor = Color3.new(1,1,1); hl.FillTransparency = 0.5; hl.Parent = CoreGui; ChamsTable[player.Name] = hl
                end
            elseif ChamsTable[player.Name] then ChamsTable[player.Name]:Destroy(); ChamsTable[player.Name] = nil end
        end
    end
end)

-- ==========================================
-- LÓGICA: EXPLORER & PLAYERS
-- ==========================================
AddHeader(Pages["Explorer"], "Explorer", "Workspace Objects")
local ExpScroll = Create("ScrollingFrame", {Size = UDim2.new(1, 0, 0, 300), BackgroundTransparency = 1, ScrollBarThickness = 2, Parent = Pages["Explorer"]})
Create("UIListLayout", {Padding = UDim.new(0, 4)}, ExpScroll)
for _, v in pairs(workspace:GetChildren()) do
    local lbl = Create("TextLabel", {Size = UDim2.new(1, 0, 0, 25), BackgroundColor3 = Theme.Element, Text = " " .. v.Name .. " [" .. v.ClassName .. "]", TextColor3 = Theme.Muted, Font = Enum.Font.Code, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = ExpScroll})
    Create("UICorner", {CornerRadius = UDim.new(0, 4)}, lbl)
end

AddHeader(Pages["Players"], "Players", "Select a target")
local PlayerList = Create("ScrollingFrame", {Size = UDim2.new(1, 0, 0, 300), BackgroundTransparency = 1, ScrollBarThickness = 2, Parent = Pages["Players"]})
Create("UIListLayout", {Padding = UDim.new(0, 5)}, PlayerList)
local function RefreshPlayers()
    for _, v in pairs(PlayerList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        local b = Create("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = (p == SelectedPlayer) and Theme.Accent or Theme.Element, Text = "  " .. p.Name, TextColor3 = (p == SelectedPlayer) and Theme.Main or Theme.Text, Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = PlayerList})
        Create("UICorner", {CornerRadius = UDim.new(0, 4)}, b)
        b.MouseButton1Click:Connect(function() SelectedPlayer = p; RefreshPlayers() end)
    end
end
RefreshPlayers()

-- ==========================================
-- LÓGICA: SOUND (MOCK SPOTIFY)
-- ==========================================
AddHeader(SoundPage, "Sound", "Now playing from Spotify")
local spotifySec = AddSection(SoundPage, "Player")
local musicBox = Create("Frame", {Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = Theme.Main, Parent = spotifySec})
Create("UICorner", {CornerRadius = UDim.new(0, 6)}, musicBox)
Create("ImageLabel", {Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0, 10, 0.5, -20), BackgroundColor3 = Theme.Element, Parent = musicBox})
Create("TextLabel", {Size = UDim2.new(1, -60, 0, 15), Position = UDim2.new(0, 60, 0, 10), BackgroundTransparency = 1, Text = "Na Loja Subi de Patente", TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = musicBox})
Create("TextLabel", {Size = UDim2.new(1, -60, 0, 15), Position = UDim2.new(0, 60, 0, 25), BackgroundTransparency = 1, Text = "MC Vitin LC", TextColor3 = Theme.Muted, Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, Parent = musicBox})

local equalizer = Create("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Theme.Main, Parent = spotifySec})
Create("UICorner", {CornerRadius = UDim.new(0, 6)}, equalizer)
for i = 1, 15 do
    local bar = Create("Frame", {Size = UDim2.new(0, 4, math.random(30, 100)/100, 0), Position = UDim2.new(0, i*8 + 5, 1, -2), AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Theme.Accent, Parent = equalizer})
    Create("UICorner", {CornerRadius = UDim.new(1, 0)}, bar)
    task.spawn(function()
        while bar.Parent do
            Tween(bar, {Size = UDim2.new(0, 4, math.random(20, 100)/100, 0)}, 0.2)
            task.wait(0.25)
        end
    end)
end

-- ==========================================
-- LÓGICA: THEMES (CORES YOX)
-- ==========================================
AddHeader(ThemesPage, "Themes", "Global color themes for the interface")
local appSec = AddSection(ThemesPage, "Appearance")
local themeGrid = Create("Frame", {Size = UDim2.new(1, 0, 0, 70), BackgroundTransparency = 1, Parent = appSec})
Create("UIGridLayout", {CellSize = UDim2.new(0.48, 0, 0, 30), CellPadding = UDim2.new(0, 5, 0, 5)}, themeGrid)

local colorsList = {
    {Name = "Violet", Color = Color3.fromRGB(150, 100, 255)},
    {Name = "Crimson", Color = Color3.fromRGB(255, 75, 100)},
    {Name = "Cyber Cyan", Color = Color3.fromRGB(0, 255, 200)},
    {Name = "Emerald", Color = Color3.fromRGB(50, 210, 130)},
    {Name = "Amber", Color = Color3.fromRGB(255, 180, 55)},
    {Name = "Monochrome", Color = Color3.fromRGB(200, 200, 200)}
}

for _, t in ipairs(colorsList) do
    local b = Create("TextButton", {BackgroundColor3 = Theme.Element, Text = "", Parent = themeGrid})
    Create("UICorner", {CornerRadius = UDim.new(0, 4)}, b)
    Create("TextLabel", {Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = t.Name, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = b})
    Create("Frame", {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(1, -15, 0.5, -5), BackgroundColor3 = t.Color, Parent = b})
    
    b.MouseButton1Click:Connect(function()
        Theme.Accent = t.Color
        MainStroke.Color = t.Color
        -- Atualiza as cores do menu dinamicamente
        for _, child in pairs(NavScroll:GetChildren()) do
            if child:IsA("TextButton") and child.BackgroundTransparency == 0 then child.BackgroundColor3 = t.Color end
        end
    end)
end

-- ==========================================
-- LÓGICA: SETTINGS (FPS E CUSTOM)
-- ==========================================
AddHeader(SettingsPage, "Settings", "Interface & Performance")
local perfSec = AddSection(SettingsPage, "Performance")
local fpsRow = Create("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = perfSec})
Create("UIListLayout", {Padding = UDim.new(0, 5), FillDirection = Enum.FillDirection.Horizontal}, fpsRow)

local function AddFPSBtn(text, value, parent)
    local b = Create("TextButton", {Size = UDim2.new(0.24, -3, 1, 0), BackgroundColor3 = Theme.Main, Text = text, TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 11, Parent = parent})
    Create("UICorner", {CornerRadius = UDim.new(0, 4)}, b)
    b.MouseButton1Click:Connect(function() if setfpscap then pcall(setfpscap, value) end end)
end
AddFPSBtn("30", 30, fpsRow)
AddFPSBtn("60", 60, fpsRow)
AddFPSBtn("120", 120, fpsRow)
AddFPSBtn("240", 240, fpsRow)

local fpsInputFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = perfSec})
local fpsBox = Create("TextBox", {Size = UDim2.new(0.7, -5, 1, 0), BackgroundColor3 = Theme.Main, TextColor3 = Theme.Text, PlaceholderText = "Custom FPS (1-240)", PlaceholderColor3 = Theme.Muted, Font = Enum.Font.Gotham, TextSize = 11, Text = "", Parent = fpsInputFrame})
Create("UICorner", {CornerRadius = UDim.new(0, 4)}, fpsBox)
local fpsApplyBtn = Create("TextButton", {Size = UDim2.new(0.3, -5, 1, 0), Position = UDim2.new(0.7, 5, 0, 0), BackgroundColor3 = Theme.Accent, Text = "Apply", TextColor3 = Theme.Main, Font = Enum.Font.GothamBold, TextSize = 11, Parent = fpsInputFrame})
Create("UICorner", {CornerRadius = UDim.new(0, 4)}, fpsApplyBtn)
fpsApplyBtn.MouseButton1Click:Connect(function()
    local num = tonumber(fpsBox.Text)
    if num and num > 0 and num <= 240 then if setfpscap then pcall(setfpscap, num) end else fpsBox.Text = "1-240!" end
end)

-- ==========================================
-- LÓGICA: SELF DESTRUCT (CÍRCULO LARANJA)
-- ==========================================
AddHeader(SelfDestructPage, "Auto Destruição", "Apaga todos os rastros do sistema")
local sdSec = AddSection(SelfDestructPage, "Destruir")
local ringFrame = Create("Frame", {Size = UDim2.new(0, 120, 0, 120), Position = UDim2.new(0.5, -60, 0, 10), BackgroundTransparency = 1, Parent = sdSec})
local ring = Create("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0.5, BackgroundColor3 = Theme.Accent, Parent = ringFrame})
Create("UICorner", {CornerRadius = UDim.new(1, 0)}, ring)
local innerRing = Create("Frame", {Size = UDim2.new(0.9, 0, 0.9, 0), Position = UDim2.new(0.05, 0, 0.05, 0), BackgroundColor3 = Theme.Element, Parent = ring})
Create("UICorner", {CornerRadius = UDim.new(1, 0)}, innerRing)

RunService.RenderStepped:Connect(function()
    if SelfDestructPage.Visible then ring.Rotation = tick() * 50; innerRing.Rotation = -tick() * 50 end
end)

local confirmBtn = Create("TextButton", {Size = UDim2.new(1, 0, 0, 35), Position = UDim2.new(0, 0, 0, 140), BackgroundColor3 = Color3.fromRGB(200, 50, 50), Text = "CONFIRMAR DESTRUIÇÃO", TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 12, Parent = sdSec})
Create("UICorner", {CornerRadius = UDim.new(0, 6)}, confirmBtn)
confirmBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- ==========================================
-- DRAG
-- ==========================================
local dragging, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = Main.Position end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

Pages["Visuals"].Visible = true
print("[ZEDUX] YOX Menu carregado com sucesso.")
