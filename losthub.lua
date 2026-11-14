--========================================================
-- ZEDUX HUB v45.2
-- Sistema de Cargos: Dono / Admin / Mod / Jogador
-- Gerador de Keys restrito a Staff (Admin + Mod)
-- Features: ESP, Aimbot, Silent Aim, Fly, Noclip, Speed,
--           Jump, Telecinese, Fling, Headless, Korblox,
--           Logs Discord, HWID no loader
--========================================================

local Players  = game:GetService("Players")
local TweenSvc = game:GetService("TweenService")
local UIS      = game:GetService("UserInputService")
local HttpSvc  = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TextSvc  = game:GetService("TextService")
local RunSvc   = game:GetService("RunService")
local TPS      = game:GetService("TeleportService")

local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera

--========================================================
-- CONFIG
--========================================================
local CONFIG = {
    VERSION      = "45.2",
    OPEN_KEY     = Enum.KeyCode.K,
    THEME        = "Violet",
    SCALE        = 1,
    WATERMARK    = true,
    CONSOLE_LOGS = true,
    EXPLORER_LIMIT = 100,
    API          = "https://zedux.enzonic.dev/api/chat",
    WEBHOOK      = "https://discord.com/api/webhooks/1559481604387246170/aAs30L9QQbfX0ZWA92jKpD6PZ_F5IOZT1424WNqaHluyZ-QuNGbbO36pVf-Fe3Ti9Fe4",
    URL_SITE     = "COLOQUE_O_LINK_DO_SEU_SITE_AQUI",
    URL_DISCORD  = "https://discord.gg/s6GSy4TuJ"
}

--========================================================
-- SISTEMA DE CARGOS
--========================================================
local OWNER_ID = 4197733654

local ADMINS = {
    -- [UserId] = true,
}

local MODS = {
    -- [UserId] = true,
}

local ADMIN_NAMES = {
    ["eduardo92301"] = true,
}

local MOD_NAMES = {
    -- ["nome"] = true,
}

local LH_CARGOS = {}
if getgenv then
    getgenv().LH_CARGOS = getgenv().LH_CARGOS or {}
    LH_CARGOS = getgenv().LH_CARGOS
end

local function GetCargo(player)
    if player.UserId == OWNER_ID then return "DONO" end
    if ADMINS[player.UserId] or ADMIN_NAMES[player.Name:lower()] then return "ADMIN" end
    if MODS[player.UserId] or MOD_NAMES[player.Name:lower()] then return "MOD" end

    local cg = LH_CARGOS[tostring(player.UserId)] or LH_CARGOS[player.Name]
    if cg == "DONO" or cg == "ADMIN" or cg == "MOD" then return cg end
    return "JOGADOR"
end

local Cargo = GetCargo(LP)
local IsOwner = (Cargo == "DONO")
local IsAdmin = (Cargo == "DONO" or Cargo == "ADMIN")
local IsMod   = (Cargo == "DONO" or Cargo == "ADMIN" or Cargo == "MOD")
local IsStaff = IsAdmin or IsMod

local CARGO_COR = {
    DONO    = Color3.fromRGB(255, 215, 0),
    ADMIN   = Color3.fromRGB(255, 85, 95),
    MOD     = Color3.fromRGB(70, 170, 255),
    JOGADOR = Color3.fromRGB(160, 160, 160)
}

--========================================================
-- TEMAS
--========================================================
local Themes = {
    Violet     = { Main=Color3.fromRGB(16,14,25), Card=Color3.fromRGB(25,22,38), Accent=Color3.fromRGB(151,91,255), Text=Color3.fromRGB(245,242,255), Muted=Color3.fromRGB(155,148,175) },
    Crimson    = { Main=Color3.fromRGB(22,13,16), Card=Color3.fromRGB(36,21,25), Accent=Color3.fromRGB(255,75,100), Text=Color3.fromRGB(255,240,243), Muted=Color3.fromRGB(180,145,153) },
    Cyan       = { Main=Color3.fromRGB(10,20,25), Card=Color3.fromRGB(19,34,42), Accent=Color3.fromRGB(40,205,230), Text=Color3.fromRGB(235,250,255), Muted=Color3.fromRGB(145,175,185) },
    Emerald    = { Main=Color3.fromRGB(12,22,18), Card=Color3.fromRGB(22,37,30), Accent=Color3.fromRGB(50,210,130), Text=Color3.fromRGB(235,255,245), Muted=Color3.fromRGB(145,180,160) },
    Amber      = { Main=Color3.fromRGB(24,19,12), Card=Color3.fromRGB(40,32,19), Accent=Color3.fromRGB(255,180,55), Text=Color3.fromRGB(255,249,235), Muted=Color3.fromRGB(185,165,130) },
    Monochrome = { Main=Color3.fromRGB(15,15,15), Card=Color3.fromRGB(30,30,30), Accent=Color3.fromRGB(220,220,220), Text=Color3.fromRGB(245,245,245), Muted=Color3.fromRGB(160,160,160) }
}

local Theme = Themes[CONFIG.THEME]

--========================================================
-- ESTADO / LOGS
--========================================================
local Logs, Connections, ThemeListeners = {}, {}, {}
local Authenticated = false
local SESSION_KEY   = ""

local LOGFILE, KEYFILE, TEMPOFILE = "zedux_logs.txt", "zedux_keys.txt", "zedux_tempo.txt"

local function Timestamp()
    if os and os.date then
        local ok, r = pcall(os.date, "%H:%M:%S")
        if ok and r then return r end
    end
    local t = DateTime.now()
    return string.format("%02d:%02d:%02d", t.Hour, t.Minute, t.Second)
end

local function TrackConn(c) table.insert(Connections, c); return c end
local function RegisterThemeListener(fn) table.insert(ThemeListeners, fn) end
local function NotifyTheme()
    for _, fn in ipairs(ThemeListeners) do pcall(fn, Theme) end
end

--========================================================
-- SISTEMA DE KEYS
--========================================================
local KEYS_VALIDAS = {
    ["ZEDUX-HUB-2026"] = true,
    ["ZEDUX-HUB-VIP"]  = true,
    ["ZEDUX-HUB-PRO"]  = true,
    ["eduardo92301"]   = true
}

pcall(function()
    local d = readfile and readfile(KEYFILE)
    if d and d ~= "" then
        for l in d:gmatch("[^\n]+") do KEYS_VALIDAS[l] = true end
    end
end)

local function SalvarKeys()
    if not writefile then return end
    local t = ""
    for k in pairs(KEYS_VALIDAS) do t = t .. k .. "\n" end
    pcall(writefile, KEYFILE, t)
end

local function ChecarTempoKey(key)
    local agora = os.time()
    local salvo = ""
    if readfile then pcall(function() salvo = readfile(TEMPOFILE) end) end

    if salvo ~= "" then
        local dados = string.split(salvo, "|")
        if dados[1] == key then
            local exp = tonumber(dados[2])
            if exp and agora < exp then return true end
        end
    end

    local segs = 0
    if string.find(key, "ZEDUX-DIA-") then segs = 86400
    elseif string.find(key, "ZEDUX-SEM-") then segs = 86400 * 7
    elseif string.find(key, "ZEDUX-MEN-") then segs = 86400 * 30
    elseif string.find(key, "ZEDUX-ANO-") then segs = 86400 * 365
    elseif string.find(key, "ZEDUX-PERM-") then
        if writefile then pcall(writefile, TEMPOFILE, key .. "|" .. tostring(math.huge)) end
        return true
    else
        return false
    end

    local exp = agora + segs
    if writefile then pcall(writefile, TEMPOFILE, key .. "|" .. tostring(exp)) end
    return true
end

local function ValidarKey(key)
    key = tostring(key or ""):gsub("^%s+",""):gsub("%s+$","")
    if key == "" then return false, "Digite uma key." end
    if KEYS_VALIDAS[key] or ChecarTempoKey(key) then
        SESSION_KEY = key
        return true, "Key validada com sucesso!"
    end
    return false, "Key inválida ou expirada."
end

--========================================================
-- DISCORD WEBHOOK
--========================================================
local filaDiscord, enviandoFila = {}, false

local function ProcessarFila()
    if enviandoFila or CONFIG.WEBHOOK == "" then return end
    enviandoFila = true
    task.spawn(function()
        while #filaDiscord > 0 do
            local lote = {}
            for _ = 1, math.min(20, #filaDiscord) do
                table.insert(lote, table.remove(filaDiscord, 1))
            end
            local desc = ""
            for _, l in ipairs(lote) do desc = desc .. "`" .. l .. "`\n" end
            pcall(function()
                HttpSvc:RequestAsync({
                    Url = CONFIG.WEBHOOK, Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpSvc:JSONEncode({
                        username = "ZEDUX HUB",
                        embeds = {{
                            title = "📋 LOG", description = desc,
                            color = 3447003,
                            footer = {text = "🕐 " .. os.date("%d/%m/%Y %H:%M:%S")},
                            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
                        }}
                    })
                })
            end)
            task.wait(1.5)
        end
        enviandoFila = false
    end)
end

local function Log(message)
    local entry = "[" .. (Cargo or "?") .. "] " .. Timestamp() .. " | " .. tostring(message)
    table.insert(Logs, 1, entry)
    if #Logs > 100 then table.remove(Logs) end
    if CONFIG.CONSOLE_LOGS then print("[ZEDUX] " .. entry) end
    table.insert(filaDiscord, entry)
    ProcessarFila()
end

--========================================================
-- HELPERS UI
--========================================================
local function Create(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function Corner(obj, r)
    return Create("UICorner", {CornerRadius = UDim.new(0, r or 10)}, obj)
end

local function Stroke(obj, trans, role)
    role = role or "Accent"
    local s = Create("UIStroke", {
        Color = Theme[role] or Theme.Accent, Thickness = 1,
        Transparency = trans or 0.5
    }, obj)
    RegisterThemeListener(function(t) s.Color = t[role] or t.Accent end)
    return s
end

local function Tween(obj, props, dur)
    local a = TweenSvc:Create(obj, TweenInfo.new(dur or 0.25, Enum.EasingStyle.Quart), props)
    a:Play(); return a
end

local function Label(parent, text, size, pos, ts, colorRole)
    colorRole = colorRole or "Text"
    local l = Create("TextLabel", {
        BackgroundTransparency = 1, Text = text,
        TextColor3 = Theme[colorRole] or Theme.Text,
        Font = Enum.Font.Gotham, TextSize = ts or 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = size or UDim2.new(1,0,0,20),
        Position = pos or UDim2.new(0,0,0,0)
    }, parent)
    RegisterThemeListener(function(t) l.TextColor3 = t[colorRole] or t.Text end)
    return l
end

local function RefreshButton(b)
    if not b.Parent then return end
    local hov = b:GetAttribute("Hovered") == true
    local act = b:GetAttribute("Active") == true
    b.BackgroundColor3 = (act or hov) and Theme.Accent or Theme.Card
end

local function SetButtonActive(b, on)
    b:SetAttribute("Active", on and true or false)
    RefreshButton(b)
end

local function Button(parent, text, size, pos)
    local b = Create("TextButton", {
        BackgroundColor3 = Theme.Card, Text = text,
        TextColor3 = Theme.Text, Font = Enum.Font.GothamSemibold,
        TextSize = 13, Size = size,
        Position = pos or UDim2.new(0,0,0,0),
        AutoButtonColor = false
    }, parent)
    Corner(b, 8); Stroke(b, 0.75)
    b:SetAttribute("Active", false); b:SetAttribute("Hovered", false)
    TrackConn(b.MouseEnter:Connect(function() b:SetAttribute("Hovered",true); RefreshButton(b) end))
    TrackConn(b.MouseLeave:Connect(function() b:SetAttribute("Hovered",false); RefreshButton(b) end))
    RegisterThemeListener(function(t) b.TextColor3 = t.Text; RefreshButton(b) end)
    return b
end

--========================================================
-- GUI
--========================================================
local guiParent = (gethui and gethui()) or game:GetService("CoreGui")

local ScreenGui = Create("ScreenGui", {
    Name = "ZEDUX_HUB_V45", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, guiParent)

local Main = Create("Frame", {
    Name = "Main", Size = UDim2.new(0, 800, 0, 520),
    Position = UDim2.new(0.5,-400,0.5,-260),
    BackgroundColor3 = Theme.Main, Visible = false, ClipsDescendants = true
}, ScreenGui)
Corner(Main, 15); Stroke(Main, 0.25)
RegisterThemeListener(function(t) Main.BackgroundColor3 = t.Main end)
local UIScaleInst = Create("UIScale", {Scale = 1}, Main)

--========================================================
-- LOADER
--========================================================
local Loader = Create("Frame", {
    Name = "Loader", Size = UDim2.new(0, 420, 0, 400),
    Position = UDim2.new(0.5,-210,0.5,-200),
    BackgroundColor3 = Theme.Main
}, ScreenGui)
Corner(Loader, 16); Stroke(Loader, 0.2)
RegisterThemeListener(function(t) Loader.BackgroundColor3 = t.Main end)

local function GetExecutor()
    local e = "Unknown"
    pcall(function() e = getexecutorname and getexecutorname() or (identifyexecutor and identifyexecutor()) or "Unknown" end)
    if type(e) == "table" then e = e[1] end
    return e
end

local function GetHWID()
    local h = "Unknown"
    pcall(function() h = gethwid and gethwid() or "Unknown" end)
    if h == "Unknown" then h = LP.UserId .. "-" .. math.random(1000,9999) end
    return h
end

local device = "PC"
if UIS.TouchEnabled and not UIS.KeyboardEnabled then device = "Mobile" end
if UIS.GamepadEnabled then device = "Console" end

local HWID = GetHWID()

Label(Loader, "ZEDUX HUB", UDim2.new(1,-30,0,36), UDim2.new(0,20,0,18), 24)
Label(Loader, "VERSION "..CONFIG.VERSION.."  |  "..Cargo, UDim2.new(1,-30,0,20), UDim2.new(0,20,0,58), 10, "Muted")

local cargoBadge = Create("TextLabel", {
    Size = UDim2.new(0, 90, 0, 22),
    Position = UDim2.new(1, -110, 0, 20),
    BackgroundColor3 = CARGO_COR[Cargo],
    Text = "🏅 "..Cargo, TextColor3 = Color3.new(0,0,0),
    Font = Enum.Font.GothamBold, TextSize = 11
}, Loader)
Corner(cargoBadge, 6)

local infoBox = Create("Frame", {
    Size = UDim2.new(1,-40,0,72), Position = UDim2.new(0,20,0,88),
    BackgroundColor3 = Theme.Card
}, Loader)
Corner(infoBox, 8); Stroke(infoBox, 0.7)
RegisterThemeListener(function(t) infoBox.BackgroundColor3 = t.Card end)

local infoRows = {
    {"🖥️", "Executor: "..GetExecutor()},
    {"💻", "Device: "..device},
    {"🛡️", "HWID: "..string.sub(HWID,1,14).."..."},
    {"🎮", "Place: "..tostring(game.PlaceId)}
}
for i, r in ipairs(infoRows) do
    local row = Create("Frame", {
        Size = UDim2.new(1,-12,0,16), Position = UDim2.new(0,8,0,(i-1)*17+2),
        BackgroundTransparency = 1
    }, infoBox)
    Create("TextLabel", {Size=UDim2.new(0,16,1,0), BackgroundTransparency=1,
        Text=r[1], TextSize=11, Font=Enum.Font.Gotham}, row)
    Create("TextLabel", {Size=UDim2.new(1,-20,1,0), Position=UDim2.new(0,20,0,0),
        BackgroundTransparency=1, Text=r[2], TextColor3=Theme.Muted,
        TextSize=10, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left}, row)
end

local KeyInput = Create("TextBox", {
    PlaceholderText = "Digite sua key",
    Text = "", ClearTextOnFocus = false,
    BackgroundColor3 = Theme.Card, TextColor3 = Theme.Text,
    PlaceholderColor3 = Theme.Muted, Font = Enum.Font.Gotham, TextSize = 13,
    Size = UDim2.new(1,-40,0,42), Position = UDim2.new(0,20,0,172)
}, Loader)
Corner(KeyInput, 8); Stroke(KeyInput, 0.6)
RegisterThemeListener(function(t)
    KeyInput.BackgroundColor3 = t.Card; KeyInput.TextColor3 = t.Text
    KeyInput.PlaceholderColor3 = t.Muted
end)

local btnRow = Create("Frame", {
    Size = UDim2.new(1,-40,0,38), Position = UDim2.new(0,20,0,222),
    BackgroundTransparency = 1
}, Loader)

local ValidateButton = Button(btnRow, "VALIDAR KEY", UDim2.new(0.48,0,1,0), UDim2.new(0,0,0,0))
local GetKeyButton   = Button(btnRow, "🔑 GET KEY",  UDim2.new(0.48,0,1,0), UDim2.new(0.52,0,0,0))
TrackConn(GetKeyButton.MouseButton1Click:Connect(function()
    pcall(function() game:GetService("GuiService"):OpenBrowserWindow(CONFIG.URL_SITE) end)
end))

local DiscordButton = Button(Loader, "💬 Entrar no Discord", UDim2.new(1,-40,0,32), UDim2.new(0,20,0,268))
TrackConn(DiscordButton.MouseButton1Click:Connect(function()
    pcall(function() game:GetService("GuiService"):OpenBrowserWindow(CONFIG.URL_DISCORD) end)
end))

local LoaderStatus = Label(Loader, "Digite sua key para continuar...",
    UDim2.new(1,-40,0,24), UDim2.new(0,20,0,312), 11, "Muted")
local CopyHwidBtn = Button(Loader, "📋 Copiar HWID", UDim2.new(1,-40,0,28), UDim2.new(0,20,0,340))
TrackConn(CopyHwidBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(HWID) end)
    LoaderStatus.Text = "✅ HWID copiado!"
end))

--========================================================
-- TOPBAR / SIDEBAR / PÁGINAS
--========================================================
local Topbar = Create("Frame", {Size=UDim2.new(1,0,0,48), BackgroundColor3=Theme.Card}, Main)
RegisterThemeListener(function(t) Topbar.BackgroundColor3 = t.Card end)
Label(Topbar, "ZEDUX HUB  v"..CONFIG.VERSION, UDim2.new(0,260,1,0), UDim2.new(0,16,0,0), 16)

local cargoTop = Create("TextLabel", {
    Size = UDim2.new(0, 80, 0, 24),
    Position = UDim2.new(1, -230, 0, 12),
    BackgroundColor3 = CARGO_COR[Cargo], BackgroundTransparency = 0.2,
    Text = Cargo, TextColor3 = Color3.new(0,0,0),
    Font = Enum.Font.GothamBold, TextSize = 11
}, Topbar)
Corner(cargoTop, 6)

local MinimizeButton = Button(Topbar, "—", UDim2.new(0,35,0,30), UDim2.new(1,-82,0,9))
local CloseButton    = Button(Topbar, "X", UDim2.new(0,35,0,30), UDim2.new(1,-42,0,9))

local Sidebar = Create("Frame", {Size=UDim2.new(0,185,1,-48), Position=UDim2.new(0,0,0,48), BackgroundColor3=Theme.Card}, Main)
RegisterThemeListener(function(t) Sidebar.BackgroundColor3 = t.Card end)
local Navigation = Create("ScrollingFrame", {
    Size=UDim2.new(1,-12,1,-15), Position=UDim2.new(0,6,0,8),
    BackgroundTransparency=1, ScrollBarThickness=2,
    CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y
}, Sidebar)
Create("UIListLayout", {Padding=UDim.new(0,7), SortOrder=Enum.SortOrder.LayoutOrder}, Navigation)

local Content = Create("Frame", {Size=UDim2.new(1,-195,1,-58), Position=UDim2.new(0,190,0,53), BackgroundTransparency=1}, Main)

local Pages, NavButtons = {}, {}

local PageNames = {
    "Dashboard", "Jogadores", "Explorer", "Ambiente",
    "Movimento", "ESP", "Combate", "Telecinese", "Troll",
    "Customização", "Themes", "Chat IA", "Settings", "Registros"
}

if IsStaff then
    table.insert(PageNames, "Administração")
    table.insert(PageNames, "Gerador de Keys")
end

for idx, name in ipairs(PageNames) do
    local page = Create("ScrollingFrame", {
        Name=name, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        ScrollBarThickness=3, CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y, Visible=false
    }, Content)
    Create("UIListLayout", {Padding=UDim.new(0,10), SortOrder=Enum.SortOrder.LayoutOrder}, page)
    Create("UIPadding", {
        PaddingTop=UDim.new(0,5), PaddingBottom=UDim.new(0,5),
        PaddingLeft=UDim.new(0,5), PaddingRight=UDim.new(0,5)
    }, page)
    Pages[name] = page

    local b = Button(Navigation, name, UDim2.new(1,-5,0,36), UDim2.new(0,0,0,0))
    b.LayoutOrder = idx
    NavButtons[name] = b
end

local function ShowPage(name)
    for n, p in pairs(Pages) do p.Visible = (n == name) end
    for n, b in pairs(NavButtons) do SetButtonActive(b, n == name) end
    Log("Página: "..name)
end

for n, b in pairs(NavButtons) do
    TrackConn(b.MouseButton1Click:Connect(function() ShowPage(n) end))
end

--========================================================
-- CONTROLES DE JANELA
--========================================================
TrackConn(MinimizeButton.MouseButton1Click:Connect(function()
    Tween(Main, {Size=UDim2.new(0,800,0, Main.Size.Y.Offset == 520 and 48 or 520)}, 0.2)
end))

TrackConn(CloseButton.MouseButton1Click:Connect(function()
    Main.Visible = false; Loader.Visible = true
end))

TrackConn(UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == CONFIG.OPEN_KEY and Authenticated and not Loader.Visible then
        Main.Visible = not Main.Visible
    end
end))

local dragging, dragInput, dragStart, startPos
TrackConn(Topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = Main.Position
    end
end))
TrackConn(Topbar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end))
TrackConn(UIS.InputChanged:Connect(function(input)
    if dragging and dragInput == input then
        local d = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
    end
end))
TrackConn(UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then dragging = false; dragInput = nil end
end))

--========================================================
-- COMPONENTES
--========================================================
local function Header(parent, title, desc)
    local f = Create("Frame", {Size=UDim2.new(1,0,0,65), BackgroundTransparency=1}, parent)
    Label(f, title, UDim2.new(1,0,0,30), UDim2.new(0,5,0,0), 21)
    Label(f, desc or "", UDim2.new(1,0,0,22), UDim2.new(0,5,0,32), 11, "Muted")
    return f
end

local function Card(parent, title, desc)
    local f = Create("Frame", {
        Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundColor3=Theme.Card
    }, parent)
    Corner(f, 10); Stroke(f, 0.8)
    RegisterThemeListener(function(t) f.BackgroundColor3 = t.Card end)
    Create("UIPadding", {PaddingTop=UDim.new(0,10), PaddingBottom=UDim.new(0,10), PaddingLeft=UDim.new(0,12), PaddingRight=UDim.new(0,12)}, f)
    Create("UIListLayout", {Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder}, f)
    local tl = Label(f, title, UDim2.new(1,0,0,25), nil, 14)
    tl.LayoutOrder = 1
    if desc and desc ~= "" then
        local d = Label(f, desc, UDim2.new(1,0,0,22), nil, 11, "Muted")
        d.TextWrapped = true; d.LayoutOrder = 2
    end
    return f
end

local function ActionButton(parent, text, cb)
    local b = Button(parent, text, UDim2.new(1,0,0,36), UDim2.new(0,0,0,0))
    TrackConn(b.MouseButton1Click:Connect(function()
        if cb then
            local ok, err = pcall(cb)
            if not ok then Log("Erro: "..tostring(err)) end
        end
    end))
    return b
end

local function Toggle(parent, title, def, cb)
    local h = Create("Frame", {Size=UDim2.new(1,0,0,42), BackgroundColor3=Theme.Card}, parent)
    Corner(h, 8)
    RegisterThemeListener(function(t) h.BackgroundColor3 = t.Card end)
    Label(h, title, UDim2.new(0.75,0,1,0), UDim2.new(0,12,0,0), 12)
    local on = def == true
    local b = Button(h, on and "ON" or "OFF", UDim2.new(0,55,0,28), UDim2.new(1,-65,0,7))
    SetButtonActive(b, on)
    TrackConn(b.MouseButton1Click:Connect(function()
        on = not on
        b.Text = on and "ON" or "OFF"
        SetButtonActive(b, on)
        if cb then pcall(cb, on) end
    end))
    return h
end

local function Slider(parent, title, min, max, def, cb)
    local h = Create("Frame", {Size=UDim2.new(1,0,0,66), BackgroundColor3=Theme.Card}, parent)
    Corner(h, 8)
    RegisterThemeListener(function(t) h.BackgroundColor3 = t.Card end)
    local safe = math.clamp(def, min, max)
    local val = safe
    local label = Label(h, title..": "..tostring(val), UDim2.new(1,-20,0,24), UDim2.new(0,10,0,4), 12)
    local bar = Create("Frame", {Size=UDim2.new(1,-24,0,8), Position=UDim2.new(0,12,0,42), BackgroundColor3=Theme.Main}, h)
    Corner(bar, 5)
    RegisterThemeListener(function(t) bar.BackgroundColor3 = t.Main end)
    local fill = Create("Frame", {Size=UDim2.new((safe-min)/(max-min),0,1,0), BackgroundColor3=Theme.Accent}, bar)
    Corner(fill, 5)
    RegisterThemeListener(function(t) fill.BackgroundColor3 = t.Accent end)
    local knob = Create("TextButton", {
        Size=UDim2.new(0,16,0,16), AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new((safe-min)/(max-min),0,0.5,0),
        BackgroundColor3=Theme.Text, Text=""
    }, bar)
    Corner(knob, 20)
    RegisterThemeListener(function(t) knob.BackgroundColor3 = t.Text end)
    local active = false
    local function setV(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        val = math.floor(min + (max-min) * rel)
        fill.Size = UDim2.new(rel,0,1,0)
        knob.Position = UDim2.new(rel,0,0.5,0)
        label.Text = title..": "..tostring(val)
        if cb then pcall(cb, val) end
    end
    TrackConn(knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = true end
    end))
    TrackConn(bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            active = true; setV(i.Position.X)
        end
    end))
    TrackConn(UIS.InputChanged:Connect(function(i)
        if active and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            if not bar.Parent then active = false; return end
            setV(i.Position.X)
        end
    end))
    TrackConn(UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = false end
    end))
    return h
end

--========================================================
-- DASHBOARD
--========================================================
local dash = Pages["Dashboard"]
Header(dash, "Dashboard", "Bem-vindo ao ZEDUX HUB v"..CONFIG.VERSION)

local cargoCard = Card(dash, "Seu cargo", "Nível de acesso atual")
local cargoLabel = Label(cargoCard, "🏅 "..Cargo, UDim2.new(1,0,0,24), nil, 18)
cargoLabel.TextColor3 = CARGO_COR[Cargo]
cargoLabel.LayoutOrder = 3
local staffLabel = Label(cargoCard, IsStaff and "✅ Acesso Staff liberado" or "⚠️ Acesso limitado (jogador comum)",
    UDim2.new(1,0,0,18), nil, 11, "Muted")
staffLabel.LayoutOrder = 4

Card(dash, "Sistema", "ZEDUX HUB carregado. Navegue pela lateral.")

local pCard = Card(dash, "Jogador", "Nome: "..LP.Name)
local pInfo = Label(pCard, "UserId: "..LP.UserId, UDim2.new(1,0,0,20), nil, 10, "Muted")
pInfo.LayoutOrder = 3

local sCard = Card(dash, "Servidor", "Jogadores: "..#Players:GetPlayers())
local sInfo = Label(sCard, "PlaceId: "..game.PlaceId, UDim2.new(1,0,0,20), nil, 10, "Muted")
sInfo.LayoutOrder = 3

ActionButton(dash, "ATUALIZAR DASHBOARD", function()
    pInfo.Text = "UserId: "..LP.UserId
    sInfo.Text = "PlaceId: "..game.PlaceId.." | Jogadores: "..#Players:GetPlayers()
    Log("Dashboard atualizado")
end)

--========================================================
-- JOGADORES
--========================================================
local jPage = Pages["Jogadores"]
Header(jPage, "Jogadores", "Selecione um alvo para as features")
local jCard = Card(jPage, "Lista", "Clique para selecionar como alvo.")
local SelectedPlayer = nil

local jList = Create("ScrollingFrame", {
    Size=UDim2.new(1,0,0,240), BackgroundColor3=Theme.Main,
    ScrollBarThickness=3, CanvasSize=UDim2.new(0,0,0,0),
    AutomaticCanvasSize=Enum.AutomaticSize.Y
}, jCard)
jList.LayoutOrder = 3; Corner(jList, 8)
RegisterThemeListener(function(t) jList.BackgroundColor3 = t.Main end)
Create("UIListLayout", {Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.Name}, jList)

local function RefreshPlayers()
    for _, c in ipairs(jList:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        local cg = GetCargo(p)
        local b = Create("TextButton", {
            Size=UDim2.new(1,-8,0,32),
            BackgroundColor3 = (SelectedPlayer == p) and Theme.Accent or Theme.Card,
            Text="  ["..cg.."] "..p.Name.." | "..p.DisplayName,
            TextColor3 = (SelectedPlayer == p) and Color3.new(0,0,0) or Theme.Text,
            Font=Enum.Font.Gotham, TextSize=11,
            TextXAlignment=Enum.TextXAlignment.Left
        }, jList)
        Corner(b, 6)
        TrackConn(b.MouseButton1Click:Connect(function()
            SelectedPlayer = p
            Log("Alvo: "..p.Name.." ("..cg..")")
            RefreshPlayers()
        end))
    end
end
ActionButton(jPage, "ATUALIZAR", RefreshPlayers)
TrackConn(Players.PlayerAdded:Connect(RefreshPlayers))
TrackConn(Players.PlayerRemoving:Connect(function() task.wait(0.1); RefreshPlayers() end))
RefreshPlayers()

--========================================================
-- EXPLORER
--========================================================
local ePage = Pages["Explorer"]
Header(ePage, "Explorer", "Visualizador somente leitura")
local eCard = Card(ePage, "Workspace", "Objetos do Workspace.")
local eList = Create("ScrollingFrame", {
    Size=UDim2.new(1,0,0,240), BackgroundColor3=Theme.Main,
    ScrollBarThickness=3, CanvasSize=UDim2.new(0,0,0,0),
    AutomaticCanvasSize=Enum.AutomaticSize.Y
}, eCard)
eList.LayoutOrder = 3; Corner(eList, 8)
RegisterThemeListener(function(t) eList.BackgroundColor3 = t.Main end)
Create("UIListLayout", {Padding=UDim.new(0,3)}, eList)

local function RefreshExplorer()
    for _, c in ipairs(eList:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
    local n = 0
    for _, o in ipairs(workspace:GetChildren()) do
        if n >= CONFIG.EXPLORER_LIMIT then break end
        n = n + 1
        local t = Create("TextLabel", {
            Size=UDim2.new(1,-8,0,24), BackgroundColor3=Theme.Card,
            Text="  "..o.Name.."  ["..o.ClassName.."]",
            TextColor3=Theme.Text, Font=Enum.Font.Gotham, TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left
        }, eList)
        Corner(t, 5)
        RegisterThemeListener(function(th) if t.Parent then t.BackgroundColor3=th.Card; t.TextColor3=th.Text end end)
    end
    Log("Explorer atualizado")
end
ActionButton(ePage, "ATUALIZAR", RefreshExplorer)
RefreshExplorer()

--========================================================
-- AMBIENTE
--========================================================
local aPage = Pages["Ambiente"]
Header(aPage, "Ambiente", "Ajustes visuais locais")
local origLight = {B=Lighting.Brightness, C=Lighting.ClockTime, FE=Lighting.FogEnd, FS=Lighting.FogStart}
Slider(aPage, "Brilho", 0, 10, math.floor(Lighting.Brightness), function(v) Lighting.Brightness = v end)
Slider(aPage, "Horário", 0, 24, math.floor(Lighting.ClockTime), function(v) Lighting.ClockTime = v end)
Slider(aPage, "Neblina", 100, 10000, math.floor(Lighting.FogEnd), function(v) Lighting.FogEnd = v end)
ActionButton(aPage, "RESTAURAR", function()
    Lighting.Brightness = origLight.B; Lighting.ClockTime = origLight.C
    Lighting.FogEnd = origLight.FE; Lighting.FogStart = origLight.FS
    Log("Iluminação restaurada")
end)

--========================================================
-- MOVIMENTO
--========================================================
local mPage = Pages["Movimento"]
Header(mPage, "Movimento", "TP, Speed, Jump, Fly, Noclip")
local mCard = Card(mPage, "Alvo", "Ações no jogador selecionado")

ActionButton(mCard, "🎯 TP PARA ALVO", function()
    if not SelectedPlayer or not SelectedPlayer.Character or not LP.Character then return end
    local m = LP.Character:FindFirstChild("HumanoidRootPart")
    local h = SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not m or not h then return end
    pcall(function() m.CFrame = h.CFrame * CFrame.new(0,0,3); m.Velocity = Vector3.zero end)
    Log("TP → "..SelectedPlayer.Name)
end)

ActionButton(mCard, "📥 TRAZER ALVO", function()
    if not SelectedPlayer or not SelectedPlayer.Character or not LP.Character then return end
    local m = LP.Character:FindFirstChild("HumanoidRootPart")
    local h = SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not m or not h then return end
    pcall(function() h.CFrame = m.CFrame * CFrame.new(0,0,3); h.Velocity = Vector3.zero end)
    Log("Trazer → "..SelectedPlayer.Name)
end)

local mCard2 = Card(mPage, "Auto", "Aplicado a você")
Toggle(mCard2, "👻 Noclip", false, function(v)
    if v then
        Log("Noclip ON")
        task.spawn(function()
            while v do
                if LP.Character then
                    for _, o in ipairs(LP.Character:GetDescendants()) do
                        if o:IsA("BasePart") and o.CanCollide then o.CanCollide = false end
                    end
                end
                task.wait(0.2)
            end
        end)
    end
end)

local speedVal, speedOn = 16, false
Toggle(mCard2, "⚡ Speed Hack", false, function(v)
    speedOn = v
    task.spawn(function()
        while speedOn do
            if LP.Character then
                local h = LP.Character:FindFirstChildOfClass("Humanoid")
                if h then h.WalkSpeed = speedVal end
            end
            task.wait(0.2)
        end
        if not speedOn and LP.Character then
            local h = LP.Character:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = 16 end
        end
    end)
end)
Slider(mCard2, "Velocidade", 16, 200, 16, function(v) speedVal = v end)

local jumpOn, jumpVal = false, 50
Toggle(mCard2, "🦘 Jump Power", false, function(v)
    jumpOn = v
    task.spawn(function()
        while jumpOn do
            if LP.Character then
                local h = LP.Character:FindFirstChildOfClass("Humanoid")
                if h then h.JumpPower = jumpVal end
            end
            task.wait(0.2)
        end
        if not jumpOn and LP.Character then
            local h = LP.Character:FindFirstChildOfClass("Humanoid")
            if h then h.JumpPower = 50 end
        end
    end)
end)
Slider(mCard2, "Jump Power", 50, 500, 50, function(v) jumpVal = v end)

local infJump = false
Toggle(mCard2, "🦘 Infinite Jump", false, function(v) infJump = v end)
TrackConn(UIS.JumpRequest:Connect(function()
    if infJump and LP.Character then
        local h = LP.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

local flyOn, flyBV, flyBG = false, nil, nil
Toggle(mCard2, "🕊️ Fly", false, function(v)
    flyOn = v
    if v and LP.Character then
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            flyBV = Instance.new("BodyVelocity", hrp)
            flyBV.MaxForce = Vector3.new(1e5,1e5,1e5); flyBV.Velocity = Vector3.zero
            flyBG = Instance.new("BodyGyro", hrp)
            flyBG.MaxTorque = Vector3.new(1e5,1e5,1e5); flyBG.P = 1000
            task.spawn(function()
                while flyOn do
                    if not hrp.Parent then break end
                    local cam = Cam.CFrame
                    local move = Vector3.zero
                    if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
                    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
                    if move.Magnitude > 0 then move = move.Unit * 80 end
                    if flyBV then flyBV.Velocity = move end
                    if flyBG then flyBG.CFrame = cam end
                    RunSvc.Heartbeat:Wait()
                end
                if flyBV then flyBV:Destroy() end
                if flyBG then flyBG:Destroy() end
            end)
        end
    else
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
    end
end)

--========================================================
-- ESP
--========================================================
local espPage = Pages["ESP"]
Header(espPage, "ESP", "Visualização de jogadores")
local EspFolder = Instance.new("Folder", ScreenGui)
EspFolder.Name = "ZEDUX_ESP"

local espOn, espColor, espDistance = false, Color3.fromRGB(220,220,220), 500
local espColors = {
    {n="Prata",c=Color3.fromRGB(220,220,220)},
    {n="Vermelho",c=Color3.fromRGB(255,60,60)},
    {n="Azul",c=Color3.fromRGB(60,150,255)},
    {n="Branco",c=Color3.fromRGB(255,255,255)}
}
local espColorIdx = 1
local espDistances = {100, 250, 500, 1000, 5000, 999999}
local espDistIdx = 3
local espCard = Card(espPage, "Controles", "ESP básico com nome e HP")

local function ClearEsp()
    for _, c in ipairs(EspFolder:GetChildren()) do c:Destroy() end
end

local function CreateEsp(p)
    if p == LP or not p.Character then return end
    if EspFolder:FindFirstChild("P_"..p.Name) then return end
    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local bb = Instance.new("BillboardGui", EspFolder)
    bb.Name = "P_"..p.Name
    bb.Size = UDim2.new(0,200,0,44)
    bb.StudsOffset = Vector3.new(0,3.5,0)
    bb.AlwaysOnTop = true; bb.Adornee = hrp
    local n = Instance.new("TextLabel", bb)
    n.Size = UDim2.new(1,0,0.5,0); n.BackgroundTransparency = 1
    n.Text = p.Name; n.TextColor3 = espColor
    n.Font = Enum.Font.GothamBold; n.TextSize = 13
    local hp = Instance.new("TextLabel", bb)
    hp.Size = UDim2.new(1,0,0.5,0); hp.Position = UDim2.new(0,0,0.5,0)
    hp.BackgroundTransparency = 1; hp.TextColor3 = Color3.new(1,1,1)
    hp.Font = Enum.Font.GothamBold; hp.TextSize = 10
    task.spawn(function()
        while bb.Parent do
            if p.Character then
                local novoH = p.Character:FindFirstChild("HumanoidRootPart")
                if novoH and novoH ~= bb.Adornee then bb.Adornee = novoH; hrp = novoH end
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                hp.Text = hum and ("❤ "..math.floor(hum.Health)) or "💀"
                if hrp and hrp.Parent then
                    local d = math.floor((hrp.Position - Cam.CFrame.Position).Magnitude)
                    bb.Enabled = d <= espDistance
                    n.Text = p.Name.." ["..d.."m]"
                end
            end
            RunSvc.RenderStepped:Wait()
        end
    end)
end

Toggle(espCard, "📡 ESP Players", false, function(v)
    espOn = v
    if v then
        ClearEsp()
        for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then CreateEsp(p) end end
        Log("ESP ON")
    else
        ClearEsp(); Log("ESP OFF")
    end
end)

ActionButton(espCard, "🎨 Trocar Cor", function()
    espColorIdx = espColorIdx % #espColors + 1
    espColor = espColors[espColorIdx].c
    Log("Cor: "..espColors[espColorIdx].n)
    if espOn then
        ClearEsp()
        for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then CreateEsp(p) end end
    end
end)

ActionButton(espCard, "📏 Alcance", function()
    espDistIdx = espDistIdx % #espDistances + 1
    espDistance = espDistances[espDistIdx]
    Log("Alcance: "..tostring(espDistance))
end)

TrackConn(Players.PlayerAdded:Connect(function(p)
    TrackConn(p.CharacterAdded:Connect(function()
        if espOn then task.wait(1); CreateEsp(p) end
    end))
end))

--========================================================
-- COMBATE
--========================================================
local cbPage = Pages["Combate"]
Header(cbPage, "Combate", "Aimbot e Silent Aim")
local cbCard = Card(cbPage, "Aimbot", "Mira automática no jogador mais próximo")
local aimOn, aimFOV, aimPart = false, 150, "Head"

Toggle(cbCard, "🎯 Aimbot", false, function(v)
    aimOn = v
    if v then
        Log("Aimbot ON")
        task.spawn(function()
            while aimOn do
                pcall(function()
                    local best, bestDist = nil, aimFOV
                    local center = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LP and p.Character then
                            local h = p.Character:FindFirstChild(aimPart) or p.Character:FindFirstChild("HumanoidRootPart")
                            if h then
                                local sp, onScreen = Cam:WorldToViewportPoint(h.Position)
                                if onScreen then
                                    local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                                    if d < bestDist then bestDist = d; best = h end
                                end
                            end
                        end
                    end
                    if best then
                        local cp = Cam.CFrame.Position
                        Cam.CFrame = CFrame.new(cp, cp + (best.Position - cp).Unit)
                    end
                end)
                RunSvc.RenderStepped:Wait()
            end
        end)
    else
        Log("Aimbot OFF")
    end
end)

Slider(cbCard, "FOV do Aimbot", 50, 500, 150, function(v) aimFOV = v end)
ActionButton(cbCard, "🎯 Parte do Aimbot: "..aimPart, function()
    if aimPart == "Head" then aimPart = "HumanoidRootPart"
    elseif aimPart == "HumanoidRootPart" then aimPart = "UpperTorso"
    else aimPart = "Head" end
    Log("Aimbot parte: "..aimPart)
end)

local silentAtivo, silentPart, silentTeamCheck = false, "Head", false
local function isTeamMate(alvo)
    if not silentTeamCheck then return false end
    if LP.Team and alvo.Team and LP.Team == alvo.Team then return true end
    return false
end

local silentCard = Card(cbPage, "Silent Aim", "Redireciona o raycast (requer hookmetamethod)")
local silentHookOK = false

local function InstalarSilentHook()
    if silentHookOK then return end
    if not (hookmetamethod and getnamecallmethod) then
        Log("❌ Silent Aim: hookmetamethod indisponível")
        return
    end
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if silentAtivo and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist") then
            local args = {...}
            local ray = args[1]
            if ray and typeof(ray) == "Ray" then
                local melhor, menorDist = nil, 400
                local myChar = LP.Character
                if myChar then
                    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
                    if myHrp then
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= LP and p.Character and not isTeamMate(p) then
                                local targetPart = p.Character:FindFirstChild(silentPart) or p.Character:FindFirstChild("HumanoidRootPart")
                                if targetPart then
                                    local dist = (targetPart.Position - myHrp.Position).Magnitude
                                    if dist < menorDist then menorDist = dist; melhor = targetPart end
                                end
                            end
                        end
                    end
                end
                if melhor then
                    local novaDir = (melhor.Position - ray.Origin).Unit * ray.Direction.Magnitude
                    args[1] = Ray.new(ray.Origin, novaDir)
                    return oldNamecall(self, unpack(args))
                end
            end
        end
        return oldNamecall(self, ...)
    end)
    silentHookOK = true
    Log("✅ Silent Aim hook instalado")
end

Toggle(silentCard, "🎯 Silent Aim", false, function(v)
    if v and not silentHookOK then InstalarSilentHook() end
    if not silentHookOK and v then Log("❌ Silent Aim sem hook"); return end
    silentAtivo = v
    Log("Silent Aim "..(v and "ON" or "OFF"))
end)

ActionButton(silentCard, "🎯 Parte do Silent: "..silentPart, function()
    if silentPart == "Head" then silentPart = "HumanoidRootPart"
    elseif silentPart == "HumanoidRootPart" then silentPart = "UpperTorso"
    else silentPart = "Head" end
    Log("Silent parte: "..silentPart)
end)

Toggle(silentCard, "👥 Silent Team Check", false, function(v)
    silentTeamCheck = v
    Log("Silent Team Check "..(v and "ON" or "OFF"))
end)

--========================================================
-- TELECINESE
--========================================================
local tPage = Pages["Telecinese"]
Header(tPage, "Telecinese", "Manipulação de objetos próximos")
local tCard = Card(tPage, "Carros", "Puxar/Lançar veículos próximos")

local function FindCar()
    if not LP.Character then return nil end
    local m = LP.Character:FindFirstChild("HumanoidRootPart")
    if not m then return nil end
    local best, bestD = nil, 400
    for _, o in ipairs(workspace:GetChildren()) do
        if o:IsA("Model") then
            for _, d in ipairs(o:GetChildren()) do
                if d:IsA("VehicleSeat") or d:IsA("Seat") then
                    local pr = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")
                    if pr then
                        local dist = (pr.Position - m.Position).Magnitude
                        if dist < bestD then bestD = dist; best = pr end
                    end
                    break
                end
            end
        end
    end
    return best
end

ActionButton(tCard, "🚗 Puxar Carro", function()
    local c = FindCar(); if not c then Log("Sem carro"); return end
    local model = c:FindFirstAncestorOfClass("Model")
    if not model then return end
    local parts = {}
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") and not d.Anchored then table.insert(parts, d); if #parts >= 6 then break end end
    end
    for _, x in ipairs(parts) do
        local bv = Instance.new("BodyVelocity", x)
        bv.Name = "ZEDUX_Pux"; bv.MaxForce = Vector3.new(5e5,5e5,5e5); bv.Velocity = Vector3.zero
    end
    Log("Puxar Carro")
    task.spawn(function()
        local t = tick()
        while tick() - t < 4 do
            if not LP.Character then break end
            local mh = LP.Character:FindFirstChild("HumanoidRootPart"); if not mh then break end
            local target = mh.Position + mh.CFrame.LookVector * 10 + Vector3.new(0,3,0)
            for _, x in ipairs(parts) do
                if x.Parent then
                    local bv = x:FindFirstChild("ZEDUX_Pux")
                    if bv then
                        local d = target - x.Position
                        bv.Velocity = d.Magnitude < 8 and Vector3.zero or d.Unit * math.min(150, d.Magnitude*3)
                    end
                end
            end
            RunSvc.Heartbeat:Wait()
        end
        for _, x in ipairs(parts) do
            if x.Parent then local bv = x:FindFirstChild("ZEDUX_Pux"); if bv then bv:Destroy() end end
        end
    end)
end)

ActionButton(tCard, "💥 Lançar Carro", function()
    if not SelectedPlayer or not SelectedPlayer.Character then Log("Sem alvo"); return end
    local targetHrp = SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetHrp then Log("Alvo sem HRP"); return end
    local c = FindCar()
    if not c then Log("Sem carro"); return end
    local model = c:FindFirstAncestorOfClass("Model")
    if not model then return end
    local parts = {}
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") and not d.Anchored then
            table.insert(parts, d); if #parts >= 8 then break end
        end
    end
    for _, x in ipairs(parts) do
        pcall(function() x:SetNetworkOwner(LP) end)
        local bv = Instance.new("BodyVelocity", x)
        bv.Name = "ZEDUX_Lan"; bv.MaxForce = Vector3.new(1e8,1e8,1e8); bv.Velocity = Vector3.zero; bv.P = 5000
    end
    Log("💥 Lançar Carro → "..SelectedPlayer.Name)
    task.spawn(function()
        local ini = tick()
        while tick() - ini < 6 do
            if not SelectedPlayer or not SelectedPlayer.Character then break end
            local th = SelectedPlayer.Character:FindFirstChild("HumanoidRootPart"); if not th then break end
            local ap = th.Position + Vector3.new(0,3,0)
            for _, x in ipairs(parts) do
                if x and x.Parent then
                    local bv = x:FindFirstChild("ZEDUX_Lan")
                    if bv then
                        local d = ap - x.Position
                        bv.Velocity = d.Magnitude < 5 and Vector3.zero or d.Unit * math.min(3000, d.Magnitude * 15)
                    end
                end
            end
            RunSvc.Heartbeat:Wait()
        end
        for _, x in ipairs(parts) do
            if x and x.Parent then local bv = x:FindFirstChild("ZEDUX_Lan"); if bv then bv:Destroy() end end
        end
        Log("✅ Lançar Carro finalizado")
    end)
end)

ActionButton(tCard, "🔓 Soltar Tudo", function()
    for _, c in ipairs(workspace:GetChildren()) do
        if c:IsA("Model") then
            for _, d in ipairs(c:GetDescendants()) do
                if d:IsA("BasePart") then
                    local b = d:FindFirstChild("ZEDUX_Pux"); if b then b:Destroy() end
                    local b2 = d:FindFirstChild("ZEDUX_Lan"); if b2 then b2:Destroy() end
                end
            end
        end
    end
    Log("Soltar Tudo")
end)

--========================================================
-- TROLL
--========================================================
local trPage = Pages["Troll"]
Header(trPage, "Troll", "Fling no alvo selecionado")
local trCard = Card(trPage, "Fling", "Arremessa o alvo com blocos físicos")

ActionButton(trCard, "💥 Fling de Blocos", function()
    if not SelectedPlayer or not SelectedPlayer.Character then Log("Sem alvo"); return end
    local h = SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not h then Log("Alvo sem HRP"); return end
    Log("💥 Fling → "..SelectedPlayer.Name)
    task.spawn(function()
        local folder = Instance.new("Folder", workspace)
        folder.Name = "ZEDUX_FlingBlocks"
        for _ = 1, 15 do
            local bloco = Instance.new("Part")
            bloco.Size = Vector3.new(5,5,5)
            bloco.Position = h.Position + Vector3.new(math.random(-10,10), math.random(5,15), math.random(-10,10))
            bloco.Anchored = false; bloco.CanCollide = true
            bloco.Transparency = 0.3; bloco.Material = Enum.Material.Neon
            bloco.Color = Color3.fromRGB(200,200,200); bloco.Parent = folder
            pcall(function() bloco:SetNetworkOwner(LP) end)
            local bv = Instance.new("BodyVelocity", bloco)
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bv.Velocity = Vector3.zero
            local bav = Instance.new("BodyAngularVelocity", bloco)
            bav.AngularVelocity = Vector3.new(math.random(-500,500), math.random(-500,500), math.random(-500,500))
            bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        end
        local ini = tick()
        while tick() - ini < 4 do
            if not SelectedPlayer or not SelectedPlayer.Character then break end
            local th = SelectedPlayer.Character:FindFirstChild("HumanoidRootPart"); if not th then break end
            for _, b in ipairs(folder:GetChildren()) do
                if b:IsA("BasePart") then
                    local bv = b:FindFirstChildOfClass("BodyVelocity")
                    if bv then
                        local dir = th.Position - b.Position
                        bv.Velocity = dir.Magnitude > 3 and dir.Unit * 2500 or Vector3.new(math.random(-2500,2500), math.random(-2500,2500), math.random(-2500,2500))
                    end
                end
            end
            RunSvc.Heartbeat:Wait()
        end
        folder:Destroy()
        Log("✅ Fling finalizado")
    end)
end)

--========================================================
-- CUSTOMIZAÇÃO
--========================================================
local cPage = Pages["Customização"]
Header(cPage, "Customização", "Headless, Korblox, sem cabelo")
local customCard = Card(cPage, "Aparência", "Aplica no seu personagem (visual local)")

local isHeadless, isKorblox, isNoHair = false, false, false
local origColors = {}

local function UpdateChar()
    local char = LP.Character; if not char then return end
    local head = char:FindFirstChild("Head")
    if head then
        for _, v in ipairs(head:GetChildren()) do
            if v:IsA("Decal") or v:IsA("Mesh") or v:IsA("SpecialMesh") then
                v.Transparency = isHeadless and 1 or 0
            end
        end
    end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            local n = part.Name
            if n:find("Leg") or n:find("Arm") or n:find("Hand") or n:find("Foot") then
                if isKorblox then
                    if not origColors[part] then origColors[part] = part.Color end
                    part.Color = Color3.fromRGB(20,20,20); part.Material = Enum.Material.SmoothPlastic
                elseif origColors[part] then
                    part.Color = origColors[part]
                end
            end
        end
    end
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Accessory") and v.AccessoryType == Enum.AccessoryType.Hair and v:FindFirstChild("Handle") then
            v.Handle.Transparency = isNoHair and 1 or 0
        end
    end
end

local headBtn, korbBtn, hairBtn
headBtn = ActionButton(customCard, "HEADLESS: OFF", function()
    isHeadless = not isHeadless
    headBtn.Text = "HEADLESS: "..(isHeadless and "ON" or "OFF")
    UpdateChar(); Log("Headless "..(isHeadless and "ON" or "OFF"))
end)
korbBtn = ActionButton(customCard, "KORBLOX: OFF", function()
    isKorblox = not isKorblox
    korbBtn.Text = "KORBLOX: "..(isKorblox and "ON" or "OFF")
    UpdateChar(); Log("Korblox "..(isKorblox and "ON" or "OFF"))
end)
hairBtn = ActionButton(customCard, "SEM CABELO: OFF", function()
    isNoHair = not isNoHair
    hairBtn.Text = "SEM CABELO: "..(isNoHair and "ON" or "OFF")
    UpdateChar(); Log("Sem cabelo "..(isNoHair and "ON" or "OFF"))
end)
TrackConn(LP.CharacterAdded:Connect(function() task.wait(1.5); UpdateChar() end))

--========================================================
-- THEMES
--========================================================
local thPage = Pages["Themes"]
Header(thPage, "Themes", "Personalize as cores do ZEDUX")

local function ApplyTheme(name)
    local t = Themes[name]; if not t then return end
    Theme = t; CONFIG.THEME = name
    NotifyTheme(); Log("Tema: "..name)
end

for tName in pairs(Themes) do
    ActionButton(thPage, "APLICAR "..string.upper(tName), function() ApplyTheme(tName) end)
end

--========================================================
-- CHAT IA
--========================================================
local chatPage = Pages["Chat IA"]
Header(chatPage, "Chat IA", "Assistente conectado ao backend")
local chatCard = Card(chatPage, "ZEDUX AI", "Envie uma mensagem para a IA.")

local chatHist = Create("ScrollingFrame", {
    Size=UDim2.new(1,0,0,220), BackgroundColor3=Theme.Main,
    ScrollBarThickness=3, CanvasSize=UDim2.new(0,0,0,0),
    AutomaticCanvasSize=Enum.AutomaticSize.Y
}, chatCard)
chatHist.LayoutOrder = 3; Corner(chatHist, 8)
RegisterThemeListener(function(t) chatHist.BackgroundColor3 = t.Main end)
Create("UIListLayout", {Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder}, chatHist)

local chatCount = 0
local function ChatMsg(sender, msg)
    chatCount = chatCount + 1
    local isUser = sender == "Você"
    local f = Create("Frame", {
        Size=UDim2.new(1,-8,0,60),
        BackgroundColor3 = isUser and Theme.Card or Theme.Accent,
        BackgroundTransparency = isUser and 0 or 0.85,
        LayoutOrder = chatCount
    }, chatHist)
    Corner(f, 8)
    Label(f, sender, UDim2.new(1,-16,0,16), UDim2.new(0,8,0,4), 10, isUser and "Accent" or "Muted")
    local m = Label(f, msg, UDim2.new(1,-16,1,-24), UDim2.new(0,8,0,22), 11)
    m.TextWrapped = true
    task.defer(function()
        local bounds = TextSvc:GetTextSize(msg, 11, Enum.Font.Gotham, Vector2.new(math.max(100, chatHist.AbsoluteSize.X-40), 1000))
        if f.Parent then
            f.Size = UDim2.new(1,-8,0,math.max(60, bounds.Y+30))
            chatHist.CanvasPosition = Vector2.new(0, math.max(0, chatHist.AbsoluteCanvasSize.Y))
        end
    end)
end

local chatRow = Create("Frame", {Size=UDim2.new(1,0,0,36), BackgroundTransparency=1}, chatCard)
chatRow.LayoutOrder = 4
local chatInput = Create("TextBox", {
    PlaceholderText = "Digite...", Text="", ClearTextOnFocus=false,
    BackgroundColor3=Theme.Card, TextColor3=Theme.Text,
    PlaceholderColor3=Theme.Muted, Font=Enum.Font.Gotham, TextSize=12,
    Size=UDim2.new(1,-80,1,0)
}, chatRow)
Corner(chatInput, 8); Stroke(chatInput, 0.8)
RegisterThemeListener(function(t)
    chatInput.BackgroundColor3=t.Card; chatInput.TextColor3=t.Text; chatInput.PlaceholderColor3=t.Muted
end)
local sendBtn = Button(chatRow, "ENVIAR", UDim2.new(0,70,1,0), UDim2.new(1,-70,0,0))

local function GetRequestFn()
    if typeof(request) == "function" then return request end
    if typeof(http_request) == "function" then return http_request end
    if typeof(http) == "table" and typeof(http.request) == "function" then return http.request end
    if typeof(syn) == "table" and typeof(syn.request) == "function" then return syn.request end
    if typeof(fluxus) == "table" and typeof(fluxus.request) == "function" then return fluxus.request end
    return nil
end

local function PostJSON(endpoint, payload)
    local fn = GetRequestFn(); if not fn then return false, "HTTP indisponível." end
    if CONFIG.API == "" then return false, "API não configurada." end
    local ok, resp = pcall(function()
        return fn({
            Url = CONFIG.API..endpoint, Method = "POST",
            Headers = {["Content-Type"]="application/json"},
            Body = HttpSvc:JSONEncode(payload)
        })
    end)
    if not ok or not resp then return false, "Falha de conexão." end
    local sc = tonumber(resp.StatusCode or resp.Status or 0)
    if sc < 200 or sc >= 300 then return false, "HTTP "..sc end
    local ok2, data = pcall(HttpSvc.JSONDecode, HttpSvc, resp.Body or "")
    if not ok2 then return false, "JSON inválido." end
    return true, data
end

local chatBusy = false
local function SendAI()
    if chatBusy or CONFIG.API == "" then return end
    local prompt = chatInput.Text
    if not prompt or prompt:gsub("%s+","") == "" then return end
    chatInput.Text = ""; ChatMsg("Você", prompt)
    chatBusy = true; sendBtn.Text = "..."
    task.spawn(function()
        local ok, data = PostJSON("/api/chat", {
            key = SESSION_KEY, prompt = prompt,
            state = {version=CONFIG.VERSION, player=LP.Name, placeId=game.PlaceId, theme=CONFIG.THEME, cargo=Cargo}
        })
        if ok then ChatMsg("ZEDUX AI", tostring(data.response or data.message or "sem resposta"))
        else ChatMsg("Sistema", tostring(data)) end
        chatBusy = false; sendBtn.Text = "ENVIAR"
    end)
end
TrackConn(sendBtn.MouseButton1Click:Connect(SendAI))
TrackConn(chatInput.FocusLost:Connect(function(e) if e then SendAI() end end))
ChatMsg("ZEDUX AI", "Olá! Sou o assistente do ZEDUX HUB.")

--========================================================
-- SETTINGS
--========================================================
local setPage = Pages["Settings"]
Header(setPage, "Settings", "Configurações gerais")

Toggle(setPage, "Watermark", CONFIG.WATERMARK, function(v) CONFIG.WATERMARK = v; Log("Watermark "..tostring(v)) end)
Toggle(setPage, "Console Logs", CONFIG.CONSOLE_LOGS, function(v) CONFIG.CONSOLE_LOGS = v end)
Slider(setPage, "Escala da interface", 80, 120, 100, function(v)
    CONFIG.SCALE = v / 100; UIScaleInst.Scale = CONFIG.SCALE
end)
ActionButton(setPage, "RESTAURAR TAMANHO", function() UIScaleInst.Scale = 1; CONFIG.SCALE = 1 end)
ActionButton(setPage, "RESTAURAR TEMA PADRÃO", function() ApplyTheme("Violet") end)
ActionButton(setPage, "🔄 Rejoin", function() pcall(function() TPS:Teleport(game.PlaceId, LP) end) end)

--========================================================
-- REGISTROS
--========================================================
local lPage = Pages["Registros"]
Header(lPage, "Registros", "Histórico de eventos")
local lCard = Card(lPage, "System Logs", "Eventos do ZEDUX HUB.")
local lList = Create("ScrollingFrame", {
    Size=UDim2.new(1,0,0,280), BackgroundColor3=Theme.Main,
    ScrollBarThickness=3, CanvasSize=UDim2.new(0,0,0,0),
    AutomaticCanvasSize=Enum.AutomaticSize.Y
}, lCard)
lList.LayoutOrder = 3; Corner(lList, 8)
RegisterThemeListener(function(t) lList.BackgroundColor3 = t.Main end)
Create("UIListLayout", {Padding=UDim.new(0,3), SortOrder=Enum.SortOrder.LayoutOrder}, lList)

local function RefreshLogs()
    for _, c in ipairs(lList:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
    for i, entry in ipairs(Logs) do
        local l = Create("TextLabel", {
            Size=UDim2.new(1,-8,0,22), BackgroundColor3=Theme.Card,
            Text="  "..entry, TextColor3=Theme.Text,
            Font=Enum.Font.Code, TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left, LayoutOrder=i
        }, lList)
        Corner(l, 4)
        RegisterThemeListener(function(t) if l.Parent then l.BackgroundColor3=t.Card; l.TextColor3=t.Text end end)
    end
end
ActionButton(lPage, "ATUALIZAR", RefreshLogs)
ActionButton(lPage, "LIMPAR", function() table.clear(Logs); RefreshLogs(); Log("Logs limpos") end)

--========================================================
-- ADMINISTRAÇÃO (só Staff)
--========================================================
if IsStaff then
    local admPage = Pages["Administração"]
    Header(admPage, "Administração", "Ferramentas restritas a "..Cargo)

    if IsOwner then
        local cargoCard2 = Card(admPage, "👑 Gerenciar Cargos", "Só o Dono pode promover/despromover")
        local cargoTargetLabel = Label(cargoCard2, "🎯 Nenhum alvo selecionado", UDim2.new(1,0,0,20), nil, 11, "Muted")
        cargoTargetLabel.LayoutOrder = 3

        local function setCargoPlayer(novoCargo)
            if not SelectedPlayer then Log("❌ Selecione um jogador primeiro"); return end
            if SelectedPlayer.UserId == OWNER_ID then Log("❌ Não pode mudar cargo do Dono"); return end
            LH_CARGOS[tostring(SelectedPlayer.UserId)] = novoCargo
            LH_CARGOS[SelectedPlayer.Name] = novoCargo
            Log("👑 "..SelectedPlayer.Name.." → "..novoCargo)
        end

        local cargosBtns = {
            {n = "👑 Dono",     c = "DONO"},
            {n = "🛡️ Admin",   c = "ADMIN"},
            {n = "⚔️ Mod",     c = "MOD"},
            {n = "👤 Jogador", c = "JOGADOR"},
        }
        for _, cg in ipairs(cargosBtns) do
            local b = ActionButton(cargoCard2, cg.n, function() setCargoPlayer(cg.c) end)
            b.LayoutOrder = 4
        end

        local removeBtn = ActionButton(cargoCard2, "🗑️ Remover Cargo (volta a Jogador)", function()
            if not SelectedPlayer then Log("❌ Selecione um jogador"); return end
            LH_CARGOS[tostring(SelectedPlayer.UserId)] = nil
            LH_CARGOS[SelectedPlayer.Name] = nil
            Log("🗑️ Cargo removido: "..SelectedPlayer.Name)
        end)
        removeBtn.LayoutOrder = 5

        task.spawn(function()
            while cargoTargetLabel.Parent do
                if SelectedPlayer then
                    cargoTargetLabel.Text = "🎯 "..SelectedPlayer.Name.." ("..GetCargo(SelectedPlayer)..")"
                    cargoTargetLabel.TextColor3 = Theme.Text
                else
                    cargoTargetLabel.Text = "🎯 Nenhum alvo selecionado"
                    cargoTargetLabel.TextColor3 = Theme.Muted
                end
                task.wait(0.5)
            end
        end)
    end

    local gkCard = Card(admPage, "🔑 Gerador de Keys", "Gere keys aleatórias ou com prefixo de tempo")

    local prefixoAtual = ""
    local prefixoLabel = Label(gkCard, "Prefixo: (nenhum — key aleatória)", UDim2.new(1,0,0,18), nil, 10, "Muted")
    prefixoLabel.LayoutOrder = 3

    local prefixos = {
        {n = "Aleatória",        p = ""},
        {n = "DIA (1 dia)",      p = "ZEDUX-DIA-"},
        {n = "SEM (7 dias)",     p = "ZEDUX-SEM-"},
        {n = "MEN (30 dias)",    p = "ZEDUX-MEN-"},
        {n = "ANO (365 dias)",   p = "ZEDUX-ANO-"},
        {n = "PERM (permanente)",p = "ZEDUX-PERM-"},
    }
    for _, pf in ipairs(prefixos) do
        local b = ActionButton(gkCard, "📅 "..pf.n, function()
            prefixoAtual = pf.p
            prefixoLabel.Text = "Prefixo: "..(pf.p == "" and "(nenhum — key aleatória)" or pf.p)
            Log("Prefixo: "..pf.n)
        end)
        b.LayoutOrder = 4
    end

    local gerarBtn = ActionButton(gkCard, "🔑 GERAR KEY", function()
        local novaKey
        if prefixoAtual == "" then
            novaKey = "ZEDUX-HUB-"..tostring(math.random(100000, 999999))
        else
            novaKey = prefixoAtual..tostring(math.random(1000, 9999))
        end

        if KEYS_VALIDAS[novaKey] then
            Log("❌ Colisão — gere novamente")
            return
        end

        KEYS_VALIDAS[novaKey] = true
        SalvarKeys()

        if setclipboard then pcall(setclipboard, novaKey) end

        Log("🔑 Key GERADA: "..novaKey)
        Log("📋 Copiada para o clipboard")

        local toast = Instance.new("Frame", ScreenGui)
        toast.Size = UDim2.new(0, 320, 0, 60)
        toast.Position = UDim2.new(0.5, -160, 0, 20)
        toast.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 10)
        Instance.new("UIStroke", toast).Color = Theme.Accent

        Create("TextLabel", {
            Size = UDim2.new(1,-20,0,24), Position = UDim2.new(0,10,0,8),
            BackgroundTransparency = 1, Text = "🔑 Key gerada!",
            TextColor3 = Color3.fromRGB(70,220,130), Font = Enum.Font.GothamBold,
            TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
        }, toast)
        Create("TextLabel", {
            Size = UDim2.new(1,-20,0,20), Position = UDim2.new(0,10,0,32),
            BackgroundTransparency = 1, Text = novaKey,
            TextColor3 = Color3.new(1,1,1), Font = Enum.Font.Code,
            TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left
        }, toast)

        task.delay(4, function() pcall(function() toast:Destroy() end) end)
    end)
    gerarBtn.LayoutOrder = 5

    if IsAdmin then
        local verCard = Card(admPage, "📋 Keys Ativas", "Lista de keys ativas (Admin+)")
        local verBtn = ActionButton(verCard, "👁️ Mostrar Keys", function()
            local antigo = verCard:FindFirstChild("KeyList")
            if antigo then antigo:Destroy() end

            local keysList = Create("ScrollingFrame", {
                Name = "KeyList",
                Size = UDim2.new(1, 0, 0, 150),
                BackgroundColor3 = Theme.Main,
                ScrollBarThickness = 3,
                CanvasSize = UDim2.new(0,0,0,0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y
            }, verCard)
            keysList.LayoutOrder = 4
            Corner(keysList, 6)
            Create("UIListLayout", {Padding=UDim.new(0,2)}, keysList)

            local count = 0
            for k in pairs(KEYS_VALIDAS) do
                count = count + 1
                local l = Create("TextLabel", {
                    Size = UDim2.new(1,-8,0,20), BackgroundColor3 = Theme.Card,
                    Text = "  "..k, TextColor3 = Theme.Text,
                    Font = Enum.Font.Code, TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, keysList)
                Corner(l, 4)
            end
            Log("📋 "..count.." keys listadas")
        end)
        verBtn.LayoutOrder = 3

        local remCard = Card(admPage, "🗑️ Remover Key", "Remove uma key específica (Admin+)")
        local remInput = Create("TextBox", {
            PlaceholderText="Digite a key para remover",
            Text="", ClearTextOnFocus=false,
            BackgroundColor3=Theme.Card, TextColor3=Theme.Text,
            PlaceholderColor3=Theme.Muted, Font=Enum.Font.Gotham, TextSize=11,
            Size=UDim2.new(1,0,0,32)
        }, remCard)
        remInput.LayoutOrder = 3
        Corner(remInput, 6); Stroke(remInput, 0.8)

        local remBtn = ActionButton(remCard, "🗑️ REMOVER", function()
            local k = remInput.Text:gsub("%s+","")
            if k == "" then Log("Digite uma key"); return end
            if not KEYS_VALIDAS[k] then Log("❌ Key não existe"); return end
            KEYS_VALIDAS[k] = nil
            SalvarKeys()
            Log("🗑️ Key removida: "..k)
            remInput.Text = ""
        end)
        remBtn.LayoutOrder = 4
    end
end

--========================================================
-- VALIDAÇÃO / BOOT
--========================================================
local validating = false

local function StartHub()
    Loader.Visible = false
    Main.Visible = true
    ShowPage("Dashboard")
    Log("ZEDUX HUB iniciado como "..Cargo)
end

TrackConn(ValidateButton.MouseButton1Click:Connect(function()
    if validating then return end
    if Authenticated then LoaderStatus.Text = "Key já validada."; return end
    validating = true
    ValidateButton.Text = "VALIDANDO..."
    task.spawn(function()
        local ok, msg = ValidarKey(KeyInput.Text)
        if ok then
            Authenticated = true
            LoaderStatus.Text = msg
            LoaderStatus.TextColor3 = Color3.fromRGB(70,220,130)
            Log("Key validada")
            task.wait(0.6)
            StartHub()
        else
            LoaderStatus.Text = tostring(msg)
            LoaderStatus.TextColor3 = Color3.fromRGB(255,85,95)
            Log("Falha: "..tostring(msg))
        end
        ValidateButton.Text = "VALIDAR KEY"
        validating = false
    end)
end))

if IsStaff then
    LoaderStatus.Text = "✅ Acesso "..Cargo.." liberado"
    LoaderStatus.TextColor3 = Color3.fromRGB(70,220,130)
    Authenticated = true
    task.wait(1)
    StartHub()
else
    Loader.Visible = true
    Main.Visible = false
end

ShowPage("Dashboard")
Log("ZEDUX HUB v"..CONFIG.VERSION.." carregado | Cargo: "..Cargo)
print("======================================")
print(" ZEDUX HUB v"..CONFIG.VERSION)
print(" Cargo: "..Cargo)
print(" Staff: "..tostring(IsStaff))
print("======================================")

--========================================================
-- UNLOAD
--========================================================
local function Unload()
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    table.clear(Connections); table.clear(ThemeListeners)
    if ScreenGui then ScreenGui:Destroy() end
    print("[ZEDUX] Descarregado")
end

pcall(function() if getgenv then getgenv().ZEDUX_Unload = Unload end end)
pcall(function() _G.ZEDUX_Unload = Unload end)

--========================================================
-- FIM
--========================================================
