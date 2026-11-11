--// ZEDUX HUB v8.0 - YOX ENGINE EDITION
local P = game:GetService("Players")
local U = game:GetService("UserInputService")
local R = game:GetService("RunService")
local T = game:GetService("TweenService")
local LP = P.LocalPlayer
local C = workspace.CurrentCamera

local gui = Instance.new("ScreenGui")
gui.Name = "ZeduxYoxEngine"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 99999
gui.Parent = game:GetService("CoreGui")

-- =======================================================
-- MOTOR DO MENU (ESTILO YOX / FLOW)
-- =======================================================
local MainFrame = Instance.new("Frame", gui)
MainFrame.Size = UDim2.new(0, 700, 0, 480)
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(40, 40, 40)
UIStroke.Thickness = 1.5

-- Barra Lateral (Sidebar)
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 180, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

-- Header do Menu (Topo)
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, -180, 0, 50)
Header.Position = UDim2.new(0, 180, 0, 0)
Header.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Header.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Auto Destruição"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

local SubTitle = Instance.new("TextLabel", Header)
SubTitle.Size = UDim2.new(1, -20, 0, 15)
SubTitle.Position = UDim2.new(0, 15, 0, 25)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Configurações do sistema"
SubTitle.TextColor3 = Color3.fromRGB(120, 120, 120)
SubTitle.TextSize = 10
SubTitle.Font = Enum.Font.Gotham

-- Área de Conteúdo (Onde ficam as abas)
local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size = UDim2.new(1, -180, 1, -50)
ContentArea.Position = UDim2.new(0, 180, 0, 50)
ContentArea.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ContentArea.BorderSizePixel = 0

-- =======================================================
-- BOTÕES DA SIDEBAR (ABAS)
-- =======================================================
local Tabs = {}
local Paginas = {}
local AbaAtual = nil

local function CriarAba(Nome, Icone)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    btn.Text = "  " .. Icone .. "  " .. Nome
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local layout = Instance.new("UIListLayout", Sidebar)
    layout.Padding = UDim.new(0, 2)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local page = Instance.new("ScrollingFrame", ContentArea)
    page.Size = UDim2.new(1, -20, 1, -20)
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 2
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    Instance.new("UIListLayout", page).Padding = UDim.new(0, 10)
    
    Tabs[Nome] = btn
    Paginas[Nome] = page
    
    btn.MouseButton1Click:Connect(function()
        for n, b in pairs(Tabs) do
            b.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            b.TextColor3 = Color3.fromRGB(180, 180, 180)
            Paginas[n].Visible = false
        end
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        page.Visible = true
        AbaAtual = Nome
    end)
    return page
end

-- Criando as Abas (Igual Yox Menu)
local AbaDashboard = CriarAba("Dashboard", "🏠")
local AbaAimbot = CriarAba("Aimbot", "🎯")
local AbaTriggerbot = CriarAba("Triggerbot", "⚡")
local AbaVisuals = CriarAba("Visuals", "👁️")
local AbaRage = CriarAba("Rage", "🔥")
local AbaExplorer = CriarAba("Explorer", "📁")
local AbaPlayers = CriarAba("Players", "👥")
local AbaSettings = CriarAba("Settings", "⚙️")

-- =======================================================
-- COMPONENTES DO MENU (CARDS E BOTÕES)
-- =======================================================

-- Função para criar Cards (Blocos com título, igual foto)
local function CreateCard(Parent, Title, Icon)
    local Card = Instance.new("Frame", Parent)
    Card.Size = UDim2.new(1, -10, 0, 0)
    Card.AutomaticSize = Enum.AutomaticSize.Y
    Card.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Card.BorderSizePixel = 0
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
    
    local TitleLabel = Instance.new("TextLabel", Card)
    TitleLabel.Size = UDim2.new(1, -20, 0, 30)
    TitleLabel.Position = UDim2.new(0, 10, 0, 5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Icon .. " " .. Title
    TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    TitleLabel.TextSize = 10
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local Content = Instance.new("Frame", Card)
    Content.Size = UDim2.new(1, -20, 0, 0)
    Content.Position = UDim2.new(0, 10, 0, 30)
    Content.AutomaticSize = Enum.AutomaticSize.Y
    Content.BackgroundTransparency = 1
    Instance.new("UIListLayout", Content).Padding = UDim.new(0, 5)
    
    return Content
end

-- Função para criar Toggle (Switch igual foto)
local function CreateToggle(Parent, Text, Callback)
    local Frame = Instance.new("Frame", Parent)
    Frame.Size = UDim2.new(1, 0, 0, 30)
    Frame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 11
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Switch = Instance.new("Frame", Frame)
    Switch.Size = UDim2.new(0, 36, 0, 18)
    Switch.Position = UDim2.new(1, -36, 0.5, -9)
    Switch.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
    
    local Circle = Instance.new("Frame", Switch)
    Circle.Size = UDim2.new(0, 14, 0, 14)
    Circle.Position = UDim2.new(0, 2, 0.5, -7)
    Circle.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
    
    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    
    local State = false
    Btn.MouseButton1Click:Connect(function()
        State = not State
        if State then
            T:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play()
            T:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = Color3.fromRGB(0, 0, 0)}):Play()
        else
            T:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
            T:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(150, 150, 150)}):Play()
        end
        if Callback then Callback(State) end
    end)
end

-- Função para criar Slider (Barra igual foto)
local function CreateSlider(Parent, Text, Min, Max, Default, Callback)
    local Frame = Instance.new("Frame", Parent)
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -40, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 11
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local ValueLabel = Instance.new("TextLabel", Frame)
    ValueLabel.Size = UDim2.new(0, 40, 0, 20)
    ValueLabel.Position = UDim2.new(1, -40, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(Default)
    ValueLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    ValueLabel.TextSize = 10
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local BarBG = Instance.new("Frame", Frame)
    BarBG.Size = UDim2.new(1, 0, 0, 4)
    BarBG.Position = UDim2.new(0, 0, 0, 28)
    BarBG.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1, 0)
    
    local Fill = Instance.new("Frame", BarBG)
    Fill.Size = UDim2.new((Default-Min)/(Max-Min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    
    local Dragging = false
    local Btn = Instance.new("TextButton", BarBG)
    Btn.Size = UDim2.new(1, 0, 2, 0)
    Btn.Position = UDim2.new(0, 0, 0, -4)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    
    local function Update(input)
        local x = math.clamp(input.Position.X - BarBG.AbsolutePosition.X, 0, BarBG.AbsoluteSize.X)
        local percent = x / BarBG.AbsoluteSize.X
        local val = math.floor(Min + (Max - Min) * percent)
        Fill.Size = UDim2.new(percent, 0, 1, 0)
        ValueLabel.Text = tostring(val)
        if Callback then Callback(val) end
    end
    
    Btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            Update(input)
        end
    end)
    
    U.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            Update(input)
        end
    end)
    
    U.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
    end)
end

-- =======================================================
-- ADICIONANDO FUNÇÕES (COMO NAS FOTOS)
-- =======================================================

-- 1. ABA RAGE (Foto 8)
local RageCard = CreateCard(AbaRage, "Movement", "🏃")
CreateSlider(RageCard, "WalkSpeed", 16, 200, 16, function(v)
    if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = v
    end
end)
CreateSlider(RageCard, "JumpPower", 50, 300, 50, function(v)
    if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        LP.Character.Humanoid.JumpPower = v
    end
end)
CreateToggle(RageCard, "Infinite Jump", function(v)
    U.JumpRequest:Connect(function()
        if v and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end)

-- 2. ABA VISUALS (Foto 9)
local VisualCard = CreateCard(AbaVisuals, "ESP Players", "👁️")
CreateToggle(VisualCard, "Box ESP", function(v)
    -- Lógica do Box ESP
end)
CreateToggle(VisualCard, "Name ESP", function(v)
    -- Lógica do Name ESP
end)
CreateToggle(VisualCard, "Healthbar", function(v)
    -- Lógica do Healthbar
end)

local LightCard = CreateCard(AbaVisuals, "Lighting", "💡")
CreateToggle(LightCard, "Fullbright", function(v)
    local l = game:GetService("Lighting")
    if v then l.Brightness = 2 l.ClockTime = 14 else l.Brightness = 1 end
end)
CreateSlider(LightCard, "Time of Day", 0, 24, 14, function(v)
    game:GetService("Lighting").ClockTime = v
end)

-- 3. ABA AIMBOT (Foto 13)
local AimCard = CreateCard(AbaAimbot, "Aimbot", "🎯")
CreateToggle(AimCard, "Enabled", function(v)
    -- Lógica do Aimbot
end)
CreateSlider(AimCard, "FOV Radius", 10, 500, 150, function(v)
    -- Lógica do FOV
end)
CreateToggle(AimCard, "Team Check", function(v)
    -- Team check logic
end)
CreateToggle(AimCard, "Wall Check", function(v)
    -- Wall check logic
end)

-- 4. ABA SETTINGS (Foto 2)
local SettingsCard = CreateCard(AbaSettings, "Interface", "🖥️")
CreateToggle(SettingsCard, "Marca d'água", function(v) end)
CreateSlider(SettingsCard, "UI Scale", 0.5, 1.5, 1.0, function(v)
    MainFrame.Size = UDim2.new(0, 700 * v, 0, 480 * v)
end)

-- Ativa a primeira aba ao abrir
Tabs["Rage"].MouseButton1Click:Fire() -- Simula o clique na aba Rage para abrir por padrão

-- =======================================================
-- SISTEMA DE ARRASTAR O MENU
-- =======================================================
local dragging, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
U.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("Yox Engine Carregada no ZEDUX HUB!")
