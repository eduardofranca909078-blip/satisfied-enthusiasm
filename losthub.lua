--========================================================
-- ZEDUX HUB v44.1 - VERSÃO CORRIGIDA
-- Correções: Card auto-size, Slider clamp, tema dinâmico,
-- UIScale, HTTP timeout, gethui fallback, Unload, etc.
--========================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer

--========================================================
-- CONFIGURACAO
--========================================================
local CONFIG = {
    API = "https://zedux.enzonic.dev",
    BOTKEY = "",
    VERSION = "44.1",
    OPEN_KEY = Enum.KeyCode.K,
    THEME = "Violet",
    SCALE = 1,
    WATERMARK = true,
    CONSOLE_LOGS = true,
    HTTP_TIMEOUT = 10,
    EXPLORER_LIMIT = 100
}

--========================================================
-- TEMAS
--========================================================
local Themes = {
    Violet = {
        Main   = Color3.fromRGB(16, 14, 25),
        Card   = Color3.fromRGB(25, 22, 38),
        Accent = Color3.fromRGB(151, 91, 255),
        Text   = Color3.fromRGB(245, 242, 255),
        Muted  = Color3.fromRGB(155, 148, 175)
    },
    Crimson = {
        Main   = Color3.fromRGB(22, 13, 16),
        Card   = Color3.fromRGB(36, 21, 25),
        Accent = Color3.fromRGB(255, 75, 100),
        Text   = Color3.fromRGB(255, 240, 243),
        Muted  = Color3.fromRGB(180, 145, 153)
    },
    Cyan = {
        Main   = Color3.fromRGB(10, 20, 25),
        Card   = Color3.fromRGB(19, 34, 42),
        Accent = Color3.fromRGB(40, 205, 230),
        Text   = Color3.fromRGB(235, 250, 255),
        Muted  = Color3.fromRGB(145, 175, 185)
    },
    Emerald = {
        Main   = Color3.fromRGB(12, 22, 18),
        Card   = Color3.fromRGB(22, 37, 30),
        Accent = Color3.fromRGB(50, 210, 130),
        Text   = Color3.fromRGB(235, 255, 245),
        Muted  = Color3.fromRGB(145, 180, 160)
    },
    Amber = {
        Main   = Color3.fromRGB(24, 19, 12),
        Card   = Color3.fromRGB(40, 32, 19),
        Accent = Color3.fromRGB(255, 180, 55),
        Text   = Color3.fromRGB(255, 249, 235),
        Muted  = Color3.fromRGB(185, 165, 130)
    },
    Monochrome = {
        Main   = Color3.fromRGB(15, 15, 15),
        Card   = Color3.fromRGB(30, 30, 30),
        Accent = Color3.fromRGB(220, 220, 220),
        Text   = Color3.fromRGB(245, 245, 245),
        Muted  = Color3.fromRGB(160, 160, 160)
    }
}

local Theme = Themes[CONFIG.THEME]

--========================================================
-- ESTADO, LOGS E REGISTRO DE TEMA
--========================================================
local Logs = {}
local Authenticated = false
local Minimized = false
local Connections = {}
local ThemeListeners = {}

local function TrackConn(conn)
    table.insert(Connections, conn)
    return conn
end

local function RegisterThemeListener(fn)
    table.insert(ThemeListeners, fn)
end

local function NotifyTheme()
    for _, fn in ipairs(ThemeListeners) do
        pcall(fn, Theme)
    end
end

local function Timestamp()
    if os and os.date then
        local ok, result = pcall(os.date, "%H:%M:%S")
        if ok and result then return result end
    end
    local t = DateTime.now()
    return string.format("%02d:%02d:%02d", t.Hour, t.Minute, t.Second)
end

local function Log(message)
    local entry = Timestamp() .. " | " .. tostring(message)
    table.insert(Logs, 1, entry)
    if #Logs > 100 then table.remove(Logs) end
    if CONFIG.CONSOLE_LOGS then
        print("[ZEDUX] " .. entry)
    end
end

--========================================================
-- HELPERS
--========================================================
local function Create(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local function Corner(object, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 10)
    }, object)
end

local function Stroke(object, transparency, role)
    role = role or "Accent"
    local stroke = Create("UIStroke", {
        Color = Theme[role] or Theme.Accent,
        Thickness = 1,
        Transparency = transparency or 0.5
    }, object)
    RegisterThemeListener(function(t)
        stroke.Color = t[role] or t.Accent
    end)
    return stroke
end

local function Tween(object, properties, duration)
    local animation = TweenService:Create(
        object,
        TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quart),
        properties
    )
    animation:Play()
    return animation
end

local function CreateLabel(parent, text, size, position, textSize, colorRole)
    colorRole = colorRole or "Text"
    local label = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme[colorRole] or Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = textSize or 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = size or UDim2.new(1, 0, 0, 20),
        Position = position or UDim2.new(0, 0, 0, 0)
    }, parent)
    RegisterThemeListener(function(t)
        label.TextColor3 = t[colorRole] or t.Text
    end)
    return label
end

--========================================================
-- BOTOES COM ESTADO (usa atributos para evitar conflito)
--========================================================
local function RefreshButton(button)
    if not button.Parent then return end
    local hovered = button:GetAttribute("Hovered") == true
    local active  = button:GetAttribute("Active") == true
    if active or hovered then
        button.BackgroundColor3 = Theme.Accent
    else
        button.BackgroundColor3 = Theme.Card
    end
end

local function SetButtonActive(button, active)
    button:SetAttribute("Active", active and true or false)
    RefreshButton(button)
end

local function CreateButton(parent, text, size, position)
    local button = Create("TextButton", {
        BackgroundColor3 = Theme.Card,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        Size = size,
        Position = position or UDim2.new(0, 0, 0, 0),
        AutoButtonColor = false
    }, parent)
    Corner(button, 8)
    Stroke(button, 0.75)

    button:SetAttribute("Active", false)
    button:SetAttribute("Hovered", false)

    TrackConn(button.MouseEnter:Connect(function()
        button:SetAttribute("Hovered", true)
        RefreshButton(button)
    end))

    TrackConn(button.MouseLeave:Connect(function()
        button:SetAttribute("Hovered", false)
        RefreshButton(button)
    end))

    RegisterThemeListener(function(t)
        button.TextColor3 = t.Text
        RefreshButton(button)
    end)

    return button
end

--========================================================
-- GUI PRINCIPAL
--========================================================
local guiParent = (gethui and gethui()) or game:GetService("CoreGui")

local ScreenGui = Create("ScreenGui", {
    Name = "ZEDUX_HUB_V44",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, guiParent)

local Main = Create("Frame", {
    Name = "Main",
    Size = UDim2.new(0, 780, 0, 500),
    Position = UDim2.new(0.5, -390, 0.5, -250),
    BackgroundColor3 = Theme.Main,
    Visible = false,
    ClipsDescendants = true
}, ScreenGui)
Corner(Main, 15)
Stroke(Main, 0.25)
RegisterThemeListener(function(t) Main.BackgroundColor3 = t.Main end)

local UIScaleInst = Create("UIScale", { Scale = 1 }, Main)

--========================================================
-- LOADER
--========================================================
local Loader = Create("Frame", {
    Name = "Loader",
    Size = UDim2.new(0, 390, 0, 280),
    Position = UDim2.new(0.5, -195, 0.5, -140),
    BackgroundColor3 = Theme.Main
}, ScreenGui)
Corner(Loader, 16)
Stroke(Loader, 0.2)
RegisterThemeListener(function(t) Loader.BackgroundColor3 = t.Main end)

CreateLabel(Loader, "ZEDUX HUB", UDim2.new(1, -30, 0, 40), UDim2.new(0, 20, 0, 20), 25)
CreateLabel(Loader, "VERSION " .. CONFIG.VERSION .. "  |  ACCESS SYSTEM",
    UDim2.new(1, -30, 0, 22), UDim2.new(0, 20, 0, 60), 10, "Muted")

local KeyInput = Create("TextBox", {
    PlaceholderText = "Insira sua BOTKEY aqui",
    Text = "",
    ClearTextOnFocus = false,
    BackgroundColor3 = Theme.Card,
    TextColor3 = Theme.Text,
    PlaceholderColor3 = Theme.Muted,
    Font = Enum.Font.Gotham,
    TextSize = 13,
    Size = UDim2.new(1, -40, 0, 42),
    Position = UDim2.new(0, 20, 0, 105)
}, Loader)
Corner(KeyInput, 8)
Stroke(KeyInput, 0.6)
RegisterThemeListener(function(t)
    KeyInput.BackgroundColor3 = t.Card
    KeyInput.TextColor3 = t.Text
    KeyInput.PlaceholderColor3 = t.Muted
end)

local ValidateButton = CreateButton(Loader, "VALIDAR BOTKEY",
    UDim2.new(1, -40, 0, 42), UDim2.new(0, 20, 0, 160))

local LoaderStatus = CreateLabel(Loader, "Aguardando autenticação...",
    UDim2.new(1, -40, 0, 25), UDim2.new(0, 20, 0, 215), 11, "Muted")

--========================================================
-- TOPBAR
--========================================================
local Topbar = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = Theme.Card
}, Main)
RegisterThemeListener(function(t) Topbar.BackgroundColor3 = t.Card end)

CreateLabel(Topbar, "ZEDUX HUB  v" .. CONFIG.VERSION,
    UDim2.new(0, 260, 1, 0), UDim2.new(0, 16, 0, 0), 16)

local MinimizeButton = CreateButton(Topbar, "—", UDim2.new(0, 35, 0, 30), UDim2.new(1, -82, 0, 9))
local CloseButton    = CreateButton(Topbar, "X", UDim2.new(0, 35, 0, 30), UDim2.new(1, -42, 0, 9))

--========================================================
-- SIDEBAR E NAVEGACAO
--========================================================
local Sidebar = Create("Frame", {
    Size = UDim2.new(0, 175, 1, -48),
    Position = UDim2.new(0, 0, 0, 48),
    BackgroundColor3 = Theme.Card
}, Main)
RegisterThemeListener(function(t) Sidebar.BackgroundColor3 = t.Card end)

local Navigation = Create("ScrollingFrame", {
    Size = UDim2.new(1, -12, 1, -15),
    Position = UDim2.new(0, 6, 0, 8),
    BackgroundTransparency = 1,
    ScrollBarThickness = 2,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y
}, Sidebar)

Create("UIListLayout", {
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder
}, Navigation)

--========================================================
-- PAGINAS
--========================================================
local Content = Create("Frame", {
    Size = UDim2.new(1, -185, 1, -58),
    Position = UDim2.new(0, 180, 0, 53),
    BackgroundTransparency = 1
}, Main)

local Pages = {}
local NavigationButtons = {}

local PageNames = {
    "Dashboard", "Jogadores", "Explorer", "Ambiente",
    "Themes", "Chat IA", "Settings", "Registros"
}

local function CreatePage(name)
    local page = Create("ScrollingFrame", {
        Name = name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false
    }, Content)

    Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, page)

    Create("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5)
    }, page)

    Pages[name] = page
    return page
end

for index, name in ipairs(PageNames) do
    CreatePage(name)
    local button = CreateButton(Navigation, name, UDim2.new(1, -5, 0, 38), UDim2.new(0, 0, 0, 0))
    button.LayoutOrder = index
    NavigationButtons[name] = button
end

local function ShowPage(name)
    for pageName, page in pairs(Pages) do
        page.Visible = pageName == name
    end
    for buttonName, button in pairs(NavigationButtons) do
        SetButtonActive(button, buttonName == name)
    end
    Log("Página aberta: " .. name)
end

for name, button in pairs(NavigationButtons) do
    TrackConn(button.MouseButton1Click:Connect(function()
        ShowPage(name)
    end))
end

--========================================================
-- CONTROLES DA JANELA
--========================================================
TrackConn(MinimizeButton.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    local targetHeight = Minimized and 48 or 500
    Tween(Main, { Size = UDim2.new(0, 780, 0, targetHeight) }, 0.2)
end))

TrackConn(CloseButton.MouseButton1Click:Connect(function()
    Main.Visible = false
    Loader.Visible = true
end))

TrackConn(UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == CONFIG.OPEN_KEY and Authenticated then
        if Loader.Visible then return end
        Main.Visible = not Main.Visible
    end
end))

--========================================================
-- ARRASTAR JANELA (dragInput local!)
--========================================================
local dragging = false
local dragInput
local dragStart
local startPosition

TrackConn(Topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end))

TrackConn(Topbar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end))

TrackConn(UserInputService.InputChanged:Connect(function(input)
    if dragging and dragInput == input then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end))

TrackConn(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        dragInput = nil
    end
end))

--========================================================
-- COMPONENTES
--========================================================
local function Header(parent, title, description)
    local frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 65),
        BackgroundTransparency = 1
    }, parent)

    CreateLabel(frame, title, UDim2.new(1, 0, 0, 30), UDim2.new(0, 5, 0, 0), 21)
    CreateLabel(frame, description or "", UDim2.new(1, 0, 0, 22),
        UDim2.new(0, 5, 0, 32), 11, "Muted")
    return frame
end

-- Card com auto-size (corrige corte de conteúdo)
local function Card(parent, title, description)
    local frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Card
    }, parent)
    Corner(frame, 10)
    Stroke(frame, 0.8)
    RegisterThemeListener(function(t) frame.BackgroundColor3 = t.Card end)

    Create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12)
    }, frame)

    Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, frame)

    local titleLabel = CreateLabel(frame, title, UDim2.new(1, 0, 0, 25), nil, 14)
    titleLabel.LayoutOrder = 1

    if description and description ~= "" then
        local desc = CreateLabel(frame, description, UDim2.new(1, 0, 0, 22), nil, 11, "Muted")
        desc.TextWrapped = true
        desc.LayoutOrder = 2
    end

    return frame
end

local function ActionButton(parent, text, callback)
    local button = CreateButton(parent, text, UDim2.new(1, 0, 0, 36), UDim2.new(0, 0, 0, 0))
    TrackConn(button.MouseButton1Click:Connect(function()
        if callback then
            local success, err = pcall(callback)
            if not success then
                Log("Erro: " .. tostring(err))
            end
        end
    end))
    return button
end

local function Toggle(parent, title, defaultValue, callback)
    local holder = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = Theme.Card
    }, parent)
    Corner(holder, 8)
    RegisterThemeListener(function(t) holder.BackgroundColor3 = t.Card end)

    CreateLabel(holder, title, UDim2.new(0.75, 0, 1, 0), UDim2.new(0, 12, 0, 0), 12)

    local enabled = defaultValue == true
    local button = CreateButton(holder, enabled and "ON" or "OFF",
        UDim2.new(0, 55, 0, 28), UDim2.new(1, -65, 0, 8))
    SetButtonActive(button, enabled)

    TrackConn(button.MouseButton1Click:Connect(function()
        enabled = not enabled
        button.Text = enabled and "ON" or "OFF"
        SetButtonActive(button, enabled)
        if callback then callback(enabled) end
    end))

    return holder
end

local function Slider(parent, title, minimum, maximum, defaultValue, callback)
    local holder = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundColor3 = Theme.Card
    }, parent)
    Corner(holder, 8)
    RegisterThemeListener(function(t) holder.BackgroundColor3 = t.Card end)

    -- CLAMP: corrige knob fora da barra (ex: FogEnd 100000)
    local safeDefault = math.clamp(defaultValue, minimum, maximum)
    local value = safeDefault

    local label = CreateLabel(holder, title .. ": " .. tostring(value),
        UDim2.new(1, -20, 0, 25), UDim2.new(0, 10, 0, 5), 12)

    local bar = Create("Frame", {
        Size = UDim2.new(1, -24, 0, 8),
        Position = UDim2.new(0, 12, 0, 43),
        BackgroundColor3 = Theme.Main
    }, holder)
    Corner(bar, 5)
    RegisterThemeListener(function(t) bar.BackgroundColor3 = t.Main end)

    local fill = Create("Frame", {
        Size = UDim2.new((safeDefault - minimum) / (maximum - minimum), 0, 1, 0),
        BackgroundColor3 = Theme.Accent
    }, bar)
    Corner(fill, 5)
    RegisterThemeListener(function(t) fill.BackgroundColor3 = t.Accent end)

    local knob = Create("TextButton", {
        Size = UDim2.new(0, 18, 0, 18),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((safeDefault - minimum) / (maximum - minimum), 0, 0.5, 0),
        BackgroundColor3 = Theme.Text,
        Text = ""
    }, bar)
    Corner(knob, 20)
    RegisterThemeListener(function(t) knob.BackgroundColor3 = t.Text end)

    local active = false

    local function SetValue(inputX)
        local relative = math.clamp(
            (inputX - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1
        )
        value = math.floor(minimum + (maximum - minimum) * relative)
        fill.Size = UDim2.new(relative, 0, 1, 0)
        knob.Position = UDim2.new(relative, 0, 0.5, 0)
        label.Text = title .. ": " .. tostring(value)
        if callback then callback(value) end
    end

    TrackConn(knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            active = true
        end
    end))

    TrackConn(bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            active = true
            SetValue(input.Position.X)
        end
    end))

    TrackConn(UserInputService.InputChanged:Connect(function(input)
        if active and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            if not bar.Parent then active = false; return end
            SetValue(input.Position.X)
        end
    end))

    TrackConn(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            active = false
        end
    end))

    return holder
end

--========================================================
-- DASHBOARD
--========================================================
local dashboard = Pages["Dashboard"]

Header(dashboard, "Dashboard", "Bem-vindo ao ZEDUX HUB v" .. CONFIG.VERSION)
Card(dashboard, "Sistema",
    "ZEDUX HUB está carregado. Utilize a navegação lateral para acessar as ferramentas.")

local playerCard = Card(dashboard, "Jogador", "Nome: " .. LocalPlayer.Name)
local playerInfo = CreateLabel(playerCard, "UserId: " .. tostring(LocalPlayer.UserId),
    UDim2.new(1, 0, 0, 20), nil, 10, "Muted")
playerInfo.LayoutOrder = 3

local serverCard = Card(dashboard, "Servidor",
    "Jogadores conectados: " .. tostring(#Players:GetPlayers()))
local serverInfo = CreateLabel(serverCard, "PlaceId: " .. tostring(game.PlaceId),
    UDim2.new(1, 0, 0, 20), nil, 10, "Muted")
serverInfo.LayoutOrder = 3

ActionButton(dashboard, "ATUALIZAR DASHBOARD", function()
    playerInfo.Text = "UserId: " .. tostring(LocalPlayer.UserId)
    serverInfo.Text = "PlaceId: " .. tostring(game.PlaceId)
        .. " | Jogadores: " .. tostring(#Players:GetPlayers())
    Log("Dashboard atualizado")
end)

--========================================================
-- JOGADORES
--========================================================
local playersPage = Pages["Jogadores"]

Header(playersPage, "Jogadores", "Visualize os jogadores presentes no servidor")

local playerListCard = Card(playersPage, "Lista de jogadores",
    "Atualize para consultar os jogadores conectados.")

local playerList = Create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 0, 220),
    BackgroundColor3 = Theme.Main,
    ScrollBarThickness = 3,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y
}, playerListCard)
playerList.LayoutOrder = 3
Corner(playerList, 8)
RegisterThemeListener(function(t) playerList.BackgroundColor3 = t.Main end)

Create("UIListLayout", {
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.Name
}, playerList)

local function RefreshPlayers()
    for _, child in ipairs(playerList:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        local entry = Create("TextButton", {
            Size = UDim2.new(1, -10, 0, 34),
            BackgroundColor3 = Theme.Card,
            Text = player.Name .. "  |  " .. player.DisplayName,
            TextColor3 = Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 11
        }, playerList)
        Corner(entry, 6)
        RegisterThemeListener(function(t)
            if entry.Parent then
                entry.BackgroundColor3 = t.Card
                entry.TextColor3 = t.Text
            end
        end)
        TrackConn(entry.MouseButton1Click:Connect(function()
            Log("Jogador selecionado: " .. player.Name)
        end))
    end

    Log("Lista de jogadores atualizada")
end

ActionButton(playersPage, "ATUALIZAR JOGADORES", RefreshPlayers)
TrackConn(Players.PlayerAdded:Connect(RefreshPlayers))
TrackConn(Players.PlayerRemoving:Connect(RefreshPlayers))
RefreshPlayers()

--========================================================
-- EXPLORER (somente leitura, com limite)
--========================================================
local explorerPage = Pages["Explorer"]

Header(explorerPage, "Explorer", "Visualizador somente leitura do Workspace")

local explorerCard = Card(explorerPage, "Workspace",
    "Visualize objetos e seus nomes sem alterar o jogo.")

local explorerList = Create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 0, 250),
    BackgroundColor3 = Theme.Main,
    ScrollBarThickness = 3,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y
}, explorerCard)
explorerList.LayoutOrder = 3
Corner(explorerList, 8)
RegisterThemeListener(function(t) explorerList.BackgroundColor3 = t.Main end)

Create("UIListLayout", { Padding = UDim.new(0, 4) }, explorerList)

local function RefreshExplorer()
    for _, child in ipairs(explorerList:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end

    local children = workspace:GetChildren()
    local total = #children
    local count = 0

    for _, object in ipairs(children) do
        if count >= CONFIG.EXPLORER_LIMIT then break end
        count = count + 1

        local item = Create("TextLabel", {
            Size = UDim2.new(1, -8, 0, 27),
            BackgroundColor3 = Theme.Card,
            Text = "  " .. object.Name .. "  [" .. object.ClassName .. "]",
            TextColor3 = Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left
        }, explorerList)
        Corner(item, 5)
        RegisterThemeListener(function(t)
            if item.Parent then
                item.BackgroundColor3 = t.Card
                item.TextColor3 = t.Text
            end
        end)
    end

    if total > CONFIG.EXPLORER_LIMIT then
        local more = Create("TextLabel", {
            Size = UDim2.new(1, -8, 0, 27),
            BackgroundColor3 = Theme.Card,
            Text = "  ... (" .. tostring(total - CONFIG.EXPLORER_LIMIT) .. " itens omitidos)",
            TextColor3 = Theme.Muted,
            Font = Enum.Font.Gotham,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left
        }, explorerList)
        Corner(more, 5)
    end

    Log("Explorer atualizado")
end

ActionButton(explorerPage, "ATUALIZAR EXPLORER", RefreshExplorer)
RefreshExplorer()

--========================================================
-- AMBIENTE
--========================================================
local environmentPage = Pages["Ambiente"]

Header(environmentPage, "Ambiente", "Ajustes visuais locais de iluminação")

local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime  = Lighting.ClockTime,
    FogEnd     = Lighting.FogEnd,
    FogStart   = Lighting.FogStart
}

Card(environmentPage, "Iluminação",
    "Esses ajustes alteram somente propriedades visuais locais disponíveis.")

Slider(environmentPage, "Brilho", 0, 10, math.floor(Lighting.Brightness), function(value)
    Lighting.Brightness = value
end)

Slider(environmentPage, "Horário", 0, 24, math.floor(Lighting.ClockTime), function(value)
    Lighting.ClockTime = value
end)

Slider(environmentPage, "Distância da neblina", 100, 10000, math.floor(Lighting.FogEnd), function(value)
    Lighting.FogEnd = value
end)

ActionButton(environmentPage, "RESTAURAR ILUMINAÇÃO", function()
    Lighting.Brightness = originalLighting.Brightness
    Lighting.ClockTime  = originalLighting.ClockTime
    Lighting.FogEnd     = originalLighting.FogEnd
    Lighting.FogStart   = originalLighting.FogStart
    Log("Iluminação restaurada")
end)

--========================================================
-- THEMES (agora com NotifyTheme)
--========================================================
local themesPage = Pages["Themes"]

Header(themesPage, "Themes", "Personalize as cores do ZEDUX HUB")

local function ApplyTheme(themeName)
    local selected = Themes[themeName]
    if not selected then return end
    Theme = selected
    CONFIG.THEME = themeName
    NotifyTheme()
    Log("Tema aplicado: " .. themeName)
end

for themeName in pairs(Themes) do
    ActionButton(themesPage, "APLICAR " .. string.upper(themeName), function()
        ApplyTheme(themeName)
    end)
end

--========================================================
-- SETTINGS
--========================================================
local settingsPage = Pages["Settings"]

Header(settingsPage, "Settings", "Configurações gerais do menu")

Toggle(settingsPage, "Watermark", CONFIG.WATERMARK, function(value)
    CONFIG.WATERMARK = value
    Log("Watermark: " .. tostring(value))
end)

Toggle(settingsPage, "Console Logs", CONFIG.CONSOLE_LOGS, function(value)
    CONFIG.CONSOLE_LOGS = value
    Log("Console Logs: " .. tostring(value))
end)

-- UIScale (escala de verdade, não corta conteúdo)
Slider(settingsPage, "Escala da interface", 80, 120, 100, function(value)
    CONFIG.SCALE = value / 100
    UIScaleInst.Scale = CONFIG.SCALE
end)

ActionButton(settingsPage, "RESTAURAR TAMANHO", function()
    CONFIG.SCALE = 1
    UIScaleInst.Scale = 1
    Log("Tamanho restaurado")
end)

ActionButton(settingsPage, "RESTAURAR TEMA PADRÃO", function()
    ApplyTheme("Violet")
end)

--========================================================
-- REGISTROS
--========================================================
local logsPage = Pages["Registros"]

Header(logsPage, "Registros", "Histórico de eventos do ZEDUX HUB")

local logsCard = Card(logsPage, "System Logs", "Eventos recentes do sistema.")

local logList = Create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 0, 260),
    BackgroundColor3 = Theme.Main,
    ScrollBarThickness = 3,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y
}, logsCard)
logList.LayoutOrder = 3
Corner(logList, 8)
RegisterThemeListener(function(t) logList.BackgroundColor3 = t.Main end)

Create("UIListLayout", {
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder
}, logList)

local function RefreshLogs()
    for _, child in ipairs(logList:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end

    for index, entry in ipairs(Logs) do
        local line = Create("TextLabel", {
            Size = UDim2.new(1, -8, 0, 25),
            BackgroundColor3 = Theme.Card,
            Text = "  " .. entry,
            TextColor3 = Theme.Text,
            Font = Enum.Font.Code,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = index
        }, logList)
        Corner(line, 4)
        RegisterThemeListener(function(t)
            if line.Parent then
                line.BackgroundColor3 = t.Card
                line.TextColor3 = t.Text
            end
        end)
    end
end

ActionButton(logsPage, "ATUALIZAR REGISTROS", RefreshLogs)

ActionButton(logsPage, "LIMPAR REGISTROS", function()
    table.clear(Logs)
    RefreshLogs()
    Log("Registros limpos")
end)

--========================================================
-- HTTP (detecção ampliada + timeout)
--========================================================
local function GetRequestFunction()
    if typeof(request) == "function" then return request end
    if typeof(http_request) == "function" then return http_request end
    if typeof(http) == "table" and typeof(http.request) == "function" then return http.request end
    if typeof(syn) == "table" and typeof(syn.request) == "function" then return syn.request end
    if typeof(fluxus) == "table" and typeof(fluxus.request) == "function" then return fluxus.request end
    return nil
end

local function PostJSON(endpoint, payload)
    local requestFunction = GetRequestFunction()
    if not requestFunction then
        return false, "Seu executor não disponibiliza uma função HTTP compatível."
    end

    local result, done = nil, false

    task.spawn(function()
        local success, response = pcall(function()
            return requestFunction({
                Url = CONFIG.API .. endpoint,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["Accept"] = "application/json"
                },
                Body = HttpService:JSONEncode(payload)
            })
        end)
        result = { success = success, response = response }
        done = true
    end)

    local waited = 0
    while not done and waited < CONFIG.HTTP_TIMEOUT do
        task.wait(0.1)
        waited = waited + 0.1
    end

    if not done then
        return false, "Timeout: o servidor não respondeu em " .. CONFIG.HTTP_TIMEOUT .. "s"
    end

    if not result.success then
        return false, "Falha na conexão: " .. tostring(result.response)
    end

    local response = result.response
    if not response then
        return false, "O servidor não retornou resposta."
    end

    local statusCode = tonumber(response.StatusCode or response.Status or 0)
    local body = response.Body or ""

    if statusCode < 200 or statusCode >= 300 then
        return false, "Erro HTTP " .. tostring(statusCode) .. ": " .. tostring(body)
    end

    local decodeSuccess, data = pcall(function()
        return HttpService:JSONDecode(body)
    end)

    if not decodeSuccess then
        return false, "Resposta JSON inválida do servidor."
    end

    return true, data
end

--========================================================
-- VALIDACAO BOTKEY
--========================================================
local function ValidateBOTKEY(key)
    key = tostring(key or ""):gsub("^%s+", ""):gsub("%s+$", "")

    if key == "" or key == "COLOQUE_SUA_BOTKEY" then
        return false, "Insira uma BOTKEY válida."
    end

    LoaderStatus.Text = "Conectando ao servidor..."
    LoaderStatus.TextColor3 = Theme.Muted

    local success, data = PostJSON("/api/validate", { key = key })

    if not success then
        return false, data
    end

    if data.valid == true then
        CONFIG.BOTKEY = key
        Authenticated = true
        return true, "BOTKEY validada com sucesso!"
    end

    return false, data.message or "BOTKEY inválida ou expirada."
end

--========================================================
-- CHAT IA
--========================================================
local function BuildState()
    return {
        version = CONFIG.VERSION,
        player = LocalPlayer.Name,
        displayName = LocalPlayer.DisplayName,
        placeId = game.PlaceId,
        jobId = game.JobId,
        theme = CONFIG.THEME,
        page = "Chat IA"
    }
end

local chatPage = Pages["Chat IA"]

Header(chatPage, "Chat IA",
    "Assistente inteligente conectado ao backend do ZEDUX HUB")

local chatCard = Card(chatPage, "ZEDUX AI",
    "Envie uma mensagem para conversar com a inteligência artificial.")

local ChatHistory = Create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 0, 270),
    BackgroundColor3 = Theme.Main,
    ScrollBarThickness = 3,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y
}, chatCard)
ChatHistory.LayoutOrder = 3
Corner(ChatHistory, 8)
RegisterThemeListener(function(t) ChatHistory.BackgroundColor3 = t.Main end)

Create("UIListLayout", {
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder
}, ChatHistory)

local chatMessageCount = 0

local function ChatMessage(sender, message)
    chatMessageCount = chatMessageCount + 1
    local isUser = sender == "Você"

    -- Contraste corrigido: IA usa Accent com transparência (não Theme.Main)
    local messageFrame = Create("Frame", {
        Size = UDim2.new(1, -10, 0, 65),
        BackgroundColor3 = isUser and Theme.Card or Theme.Accent,
        BackgroundTransparency = isUser and 0 or 0.85,
        LayoutOrder = chatMessageCount
    }, ChatHistory)
    Corner(messageFrame, 8)
    RegisterThemeListener(function(t)
        if messageFrame.Parent then
            messageFrame.BackgroundColor3 = isUser and t.Card or t.Accent
            messageFrame.BackgroundTransparency = isUser and 0 or 0.85
        end
    end)

    local senderLabel = CreateLabel(messageFrame, sender,
        UDim2.new(1, -16, 0, 18), UDim2.new(0, 8, 0, 5), 10,
        isUser and "Accent" or "Muted")

    local messageLabel = CreateLabel(messageFrame, tostring(message),
        UDim2.new(1, -16, 1, -27), UDim2.new(0, 8, 0, 24), 11)
    messageLabel.TextWrapped = true
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top

    task.defer(function()
        local textBounds = TextService:GetTextSize(
            tostring(message), 11, Enum.Font.Gotham,
            Vector2.new(math.max(100, ChatHistory.AbsoluteSize.X - 40), 1000)
        )
        if messageFrame.Parent then
            messageFrame.Size = UDim2.new(1, -10, 0, math.max(65, textBounds.Y + 38))
            ChatHistory.CanvasPosition = Vector2.new(0, math.max(0, ChatHistory.AbsoluteCanvasSize.Y))
        end
    end)
end

-- Linha de input dentro do card (agora não é cortada!)
local inputRow = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundTransparency = 1
}, chatCard)
inputRow.LayoutOrder = 4

local ChatInput = Create("TextBox", {
    PlaceholderText = "Digite sua mensagem...",
    Text = "",
    ClearTextOnFocus = false,
    MultiLine = false,
    BackgroundColor3 = Theme.Card,
    TextColor3 = Theme.Text,
    PlaceholderColor3 = Theme.Muted,
    Font = Enum.Font.Gotham,
    TextSize = 12,
    Size = UDim2.new(1, -85, 1, 0),
    Position = UDim2.new(0, 0, 0, 0)
}, inputRow)
Corner(ChatInput, 8)
Stroke(ChatInput, 0.8)
RegisterThemeListener(function(t)
    ChatInput.BackgroundColor3 = t.Card
    ChatInput.TextColor3 = t.Text
    ChatInput.PlaceholderColor3 = t.Muted
end)

local SendButton = CreateButton(inputRow, "ENVIAR",
    UDim2.new(0, 75, 1, 0), UDim2.new(1, -75, 0, 0))

local chatBusy = false

local function SendAI()
    if chatBusy then return end
    if not Authenticated then
        ChatMessage("Sistema", "Você precisa validar sua BOTKEY.")
        return
    end

    local prompt = ChatInput.Text
    if not prompt or prompt:gsub("%s+", "") == "" then return end

    ChatInput.Text = ""
    ChatMessage("Você", prompt)

    chatBusy = true
    SendButton.Text = "..."

    task.spawn(function()
        local success, data = PostJSON("/api/chat", {
            key = CONFIG.BOTKEY,
            prompt = prompt,
            state = BuildState()
        })

        if success then
            local answer = data.response or data.message
            if answer then
                ChatMessage("ZEDUX AI", tostring(answer))
            else
                ChatMessage("Sistema", "O servidor não retornou o campo response.")
            end
        else
            ChatMessage("Sistema", tostring(data))
        end

        chatBusy = false
        SendButton.Text = "ENVIAR"
    end)
end

TrackConn(SendButton.MouseButton1Click:Connect(SendAI))
TrackConn(ChatInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then SendAI() end
end))

ChatMessage("ZEDUX AI", "Olá! Sou o assistente do ZEDUX HUB. Como posso ajudar?")

--========================================================
-- VALIDACAO DO LOADER
--========================================================
local validating = false

TrackConn(ValidateButton.MouseButton1Click:Connect(function()
    if validating then return end
    if Authenticated then
        LoaderStatus.Text = "BOTKEY já validada."
        return
    end

    validating = true
    local key = KeyInput.Text
    ValidateButton.Text = "VALIDANDO..."

    task.spawn(function()
        local success, message = ValidateBOTKEY(key)

        if success then
            LoaderStatus.Text = message
            LoaderStatus.TextColor3 = Color3.fromRGB(70, 220, 130)
            Log("BOTKEY validada")
            task.wait(0.7)
            Loader.Visible = false
            Main.Visible = true
            ShowPage("Dashboard")
            Log("ZEDUX HUB iniciado")
        else
            LoaderStatus.Text = tostring(message)
            LoaderStatus.TextColor3 = Color3.fromRGB(255, 85, 95)
            Log("Falha na validação BOTKEY: " .. tostring(message))
        end

        ValidateButton.Text = "VALIDAR BOTKEY"
        validating = false
    end)
end))

--========================================================
-- INICIALIZACAO
--========================================================
ShowPage("Dashboard")
Loader.Visible = true
Main.Visible = false

Log("ZEDUX HUB v" .. CONFIG.VERSION .. " carregado")
Log("Aguardando autenticação BOTKEY")

print("======================================")
print(" ZEDUX HUB v" .. CONFIG.VERSION)
print(" Loader iniciado")
print(" Aguardando BOTKEY")
print("======================================")

--========================================================
-- UNLOAD
--========================================================
local function Unload()
    for _, conn in ipairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(Connections)
    table.clear(ThemeListeners)
    if ScreenGui then
        ScreenGui:Destroy()
    end
    print("[ZEDUX] Hub descarregado")
end

if getgenv then
    pcall(function() getgenv().ZEDUX_Unload = Unload end)
end
if _G then
    pcall(function() _G.ZEDUX_Unload = Unload end)
end

--========================================================
-- FIM DO ZEDUX HUB v44.1
--========================================================
