--// ZEDUX HUB v8.0 - TEMAS (BLACK/SILVER/AURORA...) + ESP/AIMBOT AVANÇADOS + CONFIG SALVA + KEY CORRIGIDA
if getgenv().ZEDUX_UNLOAD then pcall(getgenv().ZEDUX_UNLOAD) end
local P = game:GetService("Players")
local U = game:GetService("UserInputService")
local R = game:GetService("RunService")
local T = game:GetService("TweenService")
local LP = P.LocalPlayer
local C = workspace.CurrentCamera
local S = {sel = nil}
local lg = {}
-- Estado global do hub (uma tabela só para não estourar o limite de 200 locals do Luau)
local Z = {ALIVE = true, Conns = {}, Hooks = {}, TOASTS = true, autosave = true}
function Z.track(c) Z.Conns[#Z.Conns + 1] = c return c end
function Z.onUnload(f) Z.Hooks[#Z.Hooks + 1] = f end
local LOGFILE = "zedux_logs.txt"
local KEYFILE = "zedux_keys.txt"
local TEMPOFILE = "zedux_tempo.txt" 

-- ⚠️ COLOQUE OS LINKS AQUI
local URL_SITE = "COLOQUE_O_LINK_DO_SEU_SITE_AQUI" 
local URL_DISCORD = "https://discord.gg/s6GSy4TuJ"

local KEYS_VALIDAS = {
    ["ZEDUX-HUB-2026"] = true,
    ["ZEDUX-HUB-VIP"] = true,
    ["ZEDUX-HUB-PRO"] = true,
    ["eduardo92301"] = true
}

pcall(function()
    local d = readfile(KEYFILE)
    if d and d ~= "" then
        for l in d:gmatch("[^\n]+") do
            KEYS_VALIDAS[(l:gsub("%s+", ""))] = true
        end
    end
end)

local OID = 4197733654
local WL = {"eduardo92301"}
local ADM = {[OID] = "PROPRIETÁRIO"}
local CG = ADM[LP.UserId] or "JOGADOR"
local AD = (CG == "PROPRIETÁRIO" or CG == "ADMIN")

local isVipOuSuperior = (LP.UserId == OID)
for _, n in ipairs(WL) do
    if LP.Name:lower() == n:lower() then
        isVipOuSuperior = true
    end
end

-- =======================================================
-- SISTEMA DE VALIDAÇÃO DE TEMPO DA KEY
-- =======================================================
local ChecarTempoKey
do
    -- Opcional: URL de um servidor seu que responde JSON {"valid": true}. Vazio = validação local.
    local KEY_API_URL = ""
    local TIMED = {
        {p = "ZEDUX-DIA-", s = 86400},
        {p = "ZEDUX-SEM-", s = 86400 * 7},
        {p = "ZEDUX-MEN-", s = 86400 * 30},
        {p = "ZEDUX-ANO-", s = 86400 * 365},
        {p = "ZEDUX-PERM-", s = 0},
    }

    local function tipoDaKey(key)
        for _, t in ipairs(TIMED) do
            if key:sub(1, #t.p) == t.p then return t end
        end
        return nil
    end

    local function lerAtivacoes()
        local m = {}
        pcall(function()
            for l in readfile(TEMPOFILE):gmatch("[^\n]+") do
                local k, e = l:match("^(.-)|(%d+)$")
                if k then m[k] = tonumber(e) end
            end
        end)
        return m
    end

    local function salvarAtivacoes(m)
        local t = {}
        for k, e in pairs(m) do t[#t + 1] = k .. "|" .. string.format("%d", e) end
        pcall(function() writefile(TEMPOFILE, table.concat(t, "\n")) end)
    end

    local function validarOnline(key, hwid)
        local ok, res = pcall(function()
            local hs = game:GetService("HttpService")
            return hs:JSONDecode(game:HttpGet(KEY_API_URL .. "?key=" .. hs:UrlEncode(key) .. "&hwid=" .. hs:UrlEncode(hwid)))
        end)
        return ok and type(res) == "table" and res.valid == true
    end

    -- A key precisa existir em KEYS_VALIDAS. Keys com prefixo de tempo começam a contar no primeiro uso
    -- e depois de expirar não renovam (0 = permanente).
    ChecarTempoKey = function(key, hwid)
        if key == "" or #key > 64 then return false end
        if KEY_API_URL ~= "" then return validarOnline(key, hwid or "") end
        if not KEYS_VALIDAS[key] then return false end
        local tipo = tipoDaKey(key)
        if not tipo then return true end
        local ativ = lerAtivacoes()
        local agora = os.time()
        local exp = ativ[key]
        if exp == nil then
            ativ[key] = (tipo.s == 0) and 0 or (agora + tipo.s)
            salvarAtivacoes(ativ)
            return true
        end
        return exp == 0 or agora < exp
    end
end

-- =======================================================
-- 1. INTRO (LOADER DE LOGIN) - ESTILO BLACK/SILVER
-- =======================================================
local function IniciarIntro()
    local executor = "Unknown"
    -- cada função em seu próprio pcall: se uma não existir, a outra ainda é tentada
    for _, getter in ipairs({"identifyexecutor", "getexecutorname"}) do
        local fn = getgenv()[getter]
        if type(fn) == "function" then
            local ok, name = pcall(fn)
            if ok and name then
                if type(name) == "table" then name = name[1] end
                executor = tostring(name)
                break
            end
        end
    end

    -- HWID: usa gethwid se existir; senão gera um id aleatório uma única vez e guarda em arquivo,
    -- para não mudar a cada execução
    local hwid
    do
        local fn = getgenv().gethwid
        if type(fn) == "function" then
            local ok, v = pcall(fn)
            if ok and type(v) == "string" and v ~= "" then hwid = v end
        end
        if not hwid then
            local ok, saved = pcall(readfile, "zedux_hwid.txt")
            saved = ok and type(saved) == "string" and saved:gsub("%s+", "") or ""
            if saved ~= "" then
                hwid = saved
            else
                hwid = LP.UserId .. "-" .. string.format("%08x%08x", math.random(0, 0x7fffffff), math.random(0, 0x7fffffff))
                pcall(writefile, "zedux_hwid.txt", hwid)
            end
        end
    end
    
    local device = "PC"
    if U.TouchEnabled and not U.KeyboardEnabled then device = "Mobile" end
    if U.GamepadEnabled then device = "Console" end

    local introGui = Instance.new("ScreenGui")
    introGui.Name = "ZeduxLoader"
    introGui.ResetOnSpawn = false
    introGui.IgnoreGuiInset = true
    introGui.DisplayOrder = 999999
    introGui.Parent = game:GetService("CoreGui")

    local main = Instance.new("Frame", introGui)
    main.Size = UDim2.new(0, 700, 0, 420)
    main.Position = UDim2.new(0.5, -350, 0.5, -210)
    main.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    main.BorderSizePixel = 0
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(200, 200, 200)
    stroke.Thickness = 2

    local leftPanel = Instance.new("Frame", main)
    leftPanel.Size = UDim2.new(0, 240, 1, 0)
    leftPanel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    leftPanel.BorderSizePixel = 0
    Instance.new("UICorner", leftPanel).CornerRadius = UDim.new(0, 12)
    
    local topBar = Instance.new("Frame", leftPanel)
    topBar.Size = UDim2.new(1, 0, 0, 35)
    topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    topBar.BorderSizePixel = 0
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)
    
    local fixCorner = Instance.new("Frame", topBar)
    fixCorner.Size = UDim2.new(1, 0, 0, 15)
    fixCorner.Position = UDim2.new(0, 0, 1, -15)
    fixCorner.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    fixCorner.BorderSizePixel = 0
    
    local icon = Instance.new("TextLabel", topBar)
    icon.Size = UDim2.new(0, 30, 1, 0)
    icon.Position = UDim2.new(0, 10, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "👤"
    icon.TextColor3 = Color3.fromRGB(200, 200, 200)
    icon.TextSize = 16
    
    local titleInfo = Instance.new("TextLabel", topBar)
    titleInfo.Size = UDim2.new(1, -40, 1, 0)
    titleInfo.Position = UDim2.new(0, 35, 0, 0)
    titleInfo.BackgroundTransparency = 1
    titleInfo.Text = "User Info"
    titleInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
    titleInfo.TextSize = 14
    titleInfo.Font = Enum.Font.GothamBold
    titleInfo.TextXAlignment = Enum.TextXAlignment.Left

    local avatarFrame = Instance.new("Frame", leftPanel)
    avatarFrame.Size = UDim2.new(0, 80, 0, 80)
    avatarFrame.Position = UDim2.new(0.5, -40, 0, 50)
    avatarFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    avatarFrame.BackgroundTransparency = 0.5
    Instance.new("UICorner", avatarFrame).CornerRadius = UDim.new(1, 0)
    
    local avStroke = Instance.new("UIStroke", avatarFrame)
    avStroke.Color = Color3.fromRGB(200, 200, 200)
    avStroke.Thickness = 2
    
    local avatar = Instance.new("ImageLabel", avatarFrame)
    avatar.Size = UDim2.new(1, -6, 1, -6)
    avatar.Position = UDim2.new(0, 3, 0, 3)
    avatar.BackgroundTransparency = 1
    avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=150&h=150"
    Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

    local nameLabel = Instance.new("TextLabel", leftPanel)
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 140)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = LP.DisplayName
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.GothamBold
    
    local userLabel = Instance.new("TextLabel", leftPanel)
    userLabel.Size = UDim2.new(1, 0, 0, 15)
    userLabel.Position = UDim2.new(0, 0, 0, 160)
    userLabel.BackgroundTransparency = 1
    userLabel.Text = "@" .. LP.Name
    userLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    userLabel.TextSize = 12
    userLabel.Font = Enum.Font.Gotham

    local function addInfoRow(posY, emoji, labelTxt, valueTxt)
        local row = Instance.new("Frame", leftPanel)
        row.Size = UDim2.new(1, -20, 0, 30)
        row.Position = UDim2.new(0, 10, 0, posY)
        row.BackgroundTransparency = 1
        
        local e = Instance.new("TextLabel", row)
        e.Size = UDim2.new(0, 20, 1, 0)
        e.BackgroundTransparency = 1
        e.Text = emoji
        e.TextSize = 14
        
        local l = Instance.new("TextLabel", row)
        l.Size = UDim2.new(0.5, 0, 1, 0)
        l.Position = UDim2.new(0, 25, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = labelTxt
        l.TextColor3 = Color3.fromRGB(150, 150, 150)
        l.TextSize = 11
        l.Font = Enum.Font.GothamBold
        l.TextXAlignment = Enum.TextXAlignment.Left
        
        local v = Instance.new("TextLabel", row)
        v.Size = UDim2.new(0.5, -25, 1, 0)
        v.Position = UDim2.new(0.5, 0, 0, 0)
        v.BackgroundTransparency = 1
        v.Text = valueTxt
        v.TextColor3 = Color3.fromRGB(220, 220, 220)
        v.TextSize = 11
        v.Font = Enum.Font.Gotham
        v.TextXAlignment = Enum.TextXAlignment.Right
    end
    
    addInfoRow(190, "🖥️", "Executor", executor)
    addInfoRow(220, "💻", "Device", device)
    addInfoRow(250, "🛡️", "HWID", string.sub(hwid, 1, 10) .. "...")
    local gameName = "Unknown"
    pcall(function() gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
    addInfoRow(280, "🎮", "Game", string.sub(gameName, 1, 15))
    
    local pingLabel = Instance.new("TextLabel", leftPanel)
    pingLabel.Size = UDim2.new(0.5, -10, 0, 30)
    pingLabel.Position = UDim2.new(0.5, 0, 1, -40)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Text = "📶 Ping: -- ms"
    pingLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    pingLabel.TextSize = 11
    pingLabel.Font = Enum.Font.Gotham
    
    task.spawn(function()
        while pingLabel.Parent do
            pcall(function()
                local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                pingLabel.Text = "📶 Ping: " .. ping .. " ms"
            end)
            task.wait(1)
        end
    end)

    local connectedFrame = Instance.new("Frame", leftPanel)
    connectedFrame.Size = UDim2.new(1, -20, 0, 40)
    connectedFrame.Position = UDim2.new(0, 10, 1, -80)
    connectedFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    connectedFrame.BorderSizePixel = 0
    Instance.new("UICorner", connectedFrame).CornerRadius = UDim.new(0, 6)
    
    local connDot = Instance.new("TextLabel", connectedFrame)
    connDot.Size = UDim2.new(0, 20, 1, 0)
    connDot.Position = UDim2.new(0, 5, 0, 0)
    connDot.BackgroundTransparency = 1
    connDot.Text = "🟢"
    connDot.TextSize = 14
    
    local connText = Instance.new("TextLabel", connectedFrame)
    connText.Size = UDim2.new(1, -30, 1, 0)
    connText.Position = UDim2.new(0, 25, 0, 0)
    connText.BackgroundTransparency = 1
    connText.Text = "Connected to Zedux Hub"
    connText.TextColor3 = Color3.fromRGB(200, 200, 200)
    connText.TextSize = 11
    connText.Font = Enum.Font.GothamBold
    connText.TextXAlignment = Enum.TextXAlignment.Left

    local rightPanel = Instance.new("Frame", main)
    rightPanel.Size = UDim2.new(1, -240, 1, 0)
    rightPanel.Position = UDim2.new(0, 240, 0, 0)
    rightPanel.BackgroundTransparency = 1
    
    local hTitle = Instance.new("TextLabel", rightPanel)
    hTitle.Size = UDim2.new(1, 0, 0, 30)
    hTitle.Position = UDim2.new(0, 0, 0, 20)
    hTitle.BackgroundTransparency = 1
    hTitle.Text = "ZEDUX HUB"
    hTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    hTitle.TextSize = 24
    hTitle.Font = Enum.Font.GothamBold
    hTitle.TextXAlignment = Enum.TextXAlignment.Center
    
    local hSub = Instance.new("TextLabel", rightPanel)
    hSub.Size = UDim2.new(1, 0, 0, 20)
    hSub.Position = UDim2.new(0, 0, 0, 50)
    hSub.BackgroundTransparency = 1
    hSub.Text = "Secure FlowAuth Loader"
    hSub.TextColor3 = Color3.fromRGB(120, 120, 120)
    hSub.TextSize = 12
    hSub.Font = Enum.Font.Gotham
    hSub.TextXAlignment = Enum.TextXAlignment.Center

    local accessTitle = Instance.new("TextLabel", rightPanel)
    accessTitle.Size = UDim2.new(0.8, 0, 0, 20)
    accessTitle.Position = UDim2.new(0.1, 0, 0, 110)
    accessTitle.BackgroundTransparency = 1
    accessTitle.Text = "SECURE ACCESS"
    accessTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    accessTitle.TextSize = 11
    accessTitle.Font = Enum.Font.GothamBold
    accessTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local keyBox = Instance.new("TextBox", rightPanel)
    keyBox.Size = UDim2.new(0.8, 0, 0, 45)
    keyBox.Position = UDim2.new(0.1, 0, 0, 135)
    keyBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.PlaceholderText = "Waiting for key..."
    keyBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    keyBox.TextSize = 14
    keyBox.Font = Enum.Font.Gotham
    keyBox.TextXAlignment = Enum.TextXAlignment.Left
    keyBox.ClearTextOnFocus = false
    Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)
    
    local keyStroke = Instance.new("UIStroke", keyBox)
    keyStroke.Color = Color3.fromRGB(150, 150, 150)
    
    local padding = Instance.new("UIPadding", keyBox)
    padding.PaddingLeft = UDim.new(0, 15)

    local getKeyBtn = Instance.new("TextButton", rightPanel)
    getKeyBtn.Size = UDim2.new(0.38, 0, 0, 40)
    getKeyBtn.Position = UDim2.new(0.1, 0, 0, 195)
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    getKeyBtn.Text = "🔑 Get Key"
    getKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    getKeyBtn.Font = Enum.Font.GothamBold
    getKeyBtn.TextSize = 13
    Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 8)
    
    getKeyBtn.MouseButton1Click:Connect(function()
        pcall(function() game:GetService("GuiService"):OpenBrowserWindow(URL_SITE) end)
    end)

    local redeemBtn = Instance.new("TextButton", rightPanel)
    redeemBtn.Size = UDim2.new(0.38, 0, 0, 40)
    redeemBtn.Position = UDim2.new(0.52, 0, 0, 195)
    redeemBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    redeemBtn.Text = "🛡️ Redeem"
    redeemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    redeemBtn.Font = Enum.Font.GothamBold
    redeemBtn.TextSize = 13
    Instance.new("UICorner", redeemBtn).CornerRadius = UDim.new(0, 8)
    
    local redStroke = Instance.new("UIStroke", redeemBtn)
    redStroke.Color = Color3.fromRGB(200, 200, 200)

    local discordBtn = Instance.new("TextButton", rightPanel)
    discordBtn.Size = UDim2.new(0.38, 0, 0, 35)
    discordBtn.Position = UDim2.new(0.1, 0, 0, 250)
    discordBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    discordBtn.Text = "💬 Discord"
    discordBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    discordBtn.Font = Enum.Font.Gotham
    discordBtn.TextSize = 12
    Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0, 8)
    
    discordBtn.MouseButton1Click:Connect(function()
        pcall(function() game:GetService("GuiService"):OpenBrowserWindow(URL_DISCORD) end)
    end)
    
    local copyBtn = Instance.new("TextButton", rightPanel)
    copyBtn.Size = UDim2.new(0.38, 0, 0, 35)
    copyBtn.Position = UDim2.new(0.52, 0, 0, 250)
    copyBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    copyBtn.Text = "📋 Copy HWID"
    copyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    copyBtn.Font = Enum.Font.Gotham
    copyBtn.TextSize = 12
    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 8)
    
    local statusLog = Instance.new("TextLabel", rightPanel)
    statusLog.Size = UDim2.new(0.8, 0, 0, 20)
    statusLog.Position = UDim2.new(0.1, 0, 0, 300)
    statusLog.BackgroundTransparency = 1
    statusLog.Text = ""
    statusLog.TextColor3 = Color3.fromRGB(0, 200, 100)
    statusLog.TextSize = 11
    statusLog.Font = Enum.Font.Gotham
    statusLog.TextXAlignment = Enum.TextXAlignment.Left

    copyBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard(hwid) end)
        statusLog.Text = "✅ HWID copiado!"
    end)

    redeemBtn.MouseButton1Click:Connect(function()
        local keyDigitada = keyBox.Text:gsub("%s+", "")
        
        if ChecarTempoKey(keyDigitada, hwid) then
            statusLog.TextColor3 = Color3.fromRGB(0, 200, 100)
            statusLog.Text = "✅ Key válida! Iniciando painel..."
            task.wait(1)
            introGui:Destroy()
        else
            statusLog.TextColor3 = Color3.fromRGB(255, 80, 80)
            statusLog.Text = "❌ Key inválida ou expirada."
            keyBox.Text = ""
            task.wait(2)
            statusLog.Text = ""
        end
    end)

    if isVipOuSuperior then
        hTitle.Text = "BEM-VINDO VIP"
        hSub.Text = "Acesso liberado automaticamente..."
        keyBox.Visible = false
        getKeyBtn.Visible = false
        redeemBtn.Visible = false
        discordBtn.Visible = false
        copyBtn.Visible = false
        statusLog.TextColor3 = Color3.fromRGB(0, 200, 100)
        statusLog.Text = "✅ Autenticado via VIP."
        task.wait(1.5)
        introGui:Destroy()
    else
        repeat task.wait() until not introGui.Parent
    end
end
IniciarIntro()

-- =======================================================
-- 2. SISTEMA DO PAINEL E WEBHOOKS
-- =======================================================
local WEBHOOK = ""
pcall(function()
    local u = readfile("zedux_webhook.txt"):gsub("%s+", "")
    if u:find("^https://discord.com/api/webhooks/") or u:find("^https://discordapp.com/api/webhooks/") then WEBHOOK = u end
end)
local filaDiscord = {}
local enviandoFila = false

local function processarFila()
    if enviandoFila then return end
    enviandoFila = true
    task.spawn(function()
        while #filaDiscord > 0 do
            local lote = {}
            local cont = 0
            while #filaDiscord > 0 and cont < 20 do
                table.insert(lote, table.remove(filaDiscord, 1))
                cont = cont + 1
            end
            local desc = ""
            for _, l in ipairs(lote) do desc = desc .. "`" .. l .. "`\n" end
            local e = {title = "📋 LOG", description = desc, color = 3447003, footer = {text = "🕐 " .. os.date("%d/%m/%Y %H:%M:%S")}, timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")}
            if WEBHOOK ~= "" then
                pcall(function()
                    game:GetService("HttpService"):RequestAsync({Url = WEBHOOK, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = game:GetService("HttpService"):JSONEncode({username = "ZEDUX HUB", embeds = {e}})})
                end)
            end
            task.wait(1.5)
        end
        enviandoFila = false
    end)
end

local function reg(a)
    local h = os.date("%d/%m/%Y %H:%M:%S")
    table.insert(lg, {h = h, j = LP.Name, a = a})
    pcall(function() appendfile(LOGFILE, h .. "|" .. LP.Name .. "|" .. a .. "\n") end)
    table.insert(filaDiscord, "[" .. h .. "] " .. LP.Name .. " → " .. a)
    processarFila()
end

pcall(function()
    local d = readfile(LOGFILE)
    if d and d ~= "" then
        for l in d:gmatch("[^\n]+") do
            local h, j, a = l:match("^(.-)|(.-)|(.*)$")
            if h and j and a then table.insert(lg, {h = h, j = j, a = a}) end
        end
    end
end)

getgenv().LH_AP = {}
getgenv().LH_CARGOS = {}
getgenv().LH_CARGOS[tostring(OID)] = "PROPRIETÁRIO"
if LP.UserId == OID then getgenv().LH_CARGOS[LP.Name] = "PROPRIETÁRIO" end
for _, n in ipairs(WL) do getgenv().LH_AP[n:lower()] = true end

local gui = Instance.new("ScreenGui")
gui.Name = "ZeduxHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 99999
gui.Parent = game:GetService("CoreGui")

local flt = Instance.new("TextButton", gui)
flt.Size = UDim2.new(0, 50, 0, 50)
flt.Position = UDim2.new(0, 20, 0.5, -25)
flt.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
flt.Text = "👻"
flt.TextColor3 = Color3.fromRGB(255, 255, 255)
flt.TextSize = 22
flt.Font = Enum.Font.GothamBold
flt.BorderSizePixel = 0
flt.Visible = false
Instance.new("UICorner", flt).CornerRadius = UDim.new(0, 14)

local w = Instance.new("Frame", gui)
w.Size = UDim2.new(0, 700, 0, 440)
w.Position = UDim2.new(0.5, -350, 0.5, -220)
w.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
w.BorderSizePixel = 0
Instance.new("UICorner", w).CornerRadius = UDim.new(0, 10)
w.Visible = false
w.ClipsDescendants = true

-- =======================================================
-- 🌌 FUNDO ANIMADO: CÉU ESTRELADO (STARFIELD)
-- =======================================================
local starfield = Instance.new("Frame", w)
starfield.Name = "Starfield"
starfield.Size = UDim2.new(1, 0, 1, 0)
starfield.BackgroundTransparency = 1
starfield.ClipsDescendants = true
starfield.ZIndex = 1

do
    local stars = {}
    for i = 1, 70 do
        local star = Instance.new("Frame", starfield)
        local size = math.random(1, 3)
        star.Size = UDim2.new(0, size, 0, size)
        star.Position = UDim2.new(math.random(), 0, math.random(), 0)
        star.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        star.BorderSizePixel = 0
        star.ZIndex = 1
        Instance.new("UICorner", star).CornerRadius = UDim.new(1, 0)
        stars[i] = star
    end

    -- um único loop pisca algumas estrelas por vez (antes eram 150 loops)
    task.spawn(function()
        while Z.ALIVE and starfield.Parent do
            if starfield.Visible then
                for _ = 1, 10 do
                    local star = stars[math.random(#stars)]
                    T:Create(star, TweenInfo.new(math.random(10, 30) / 10, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = math.random(0, 8) / 10}):Play()
                end
            end
            task.wait(0.35)
        end
    end)

    task.spawn(function()
        while Z.ALIVE and starfield.Parent do
            T:Create(starfield, TweenInfo.new(20, Enum.EasingStyle.Linear), {Position = UDim2.new(0, 0, -0.2, 0)}):Play()
            task.wait(20)
            starfield.Position = UDim2.new(0, 0, 0, 0)
        end
    end)
end

local wStroke = Instance.new("UIStroke", w)
wStroke.Color = Color3.fromRGB(200, 200, 200)
wStroke.Thickness = 1.5
wStroke.Transparency = 0.3

w.Visible = true
reg("✅ Painel ABERTO por " .. LP.Name)

local sb = Instance.new("Frame", w)
sb.Size = UDim2.new(0, 200, 1, 0)
sb.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
sb.BackgroundTransparency = 0.2 
sb.BorderSizePixel = 0
sb.ZIndex = 2
Instance.new("UICorner", sb).CornerRadius = UDim.new(0, 10)

local mn = Instance.new("Frame", w)
mn.Size = UDim2.new(1, -200, 1, 0)
mn.Position = UDim2.new(0, 200, 0, 0)
mn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
mn.BackgroundTransparency = 0.4 
mn.BorderSizePixel = 0
mn.ZIndex = 2
Instance.new("UICorner", mn).CornerRadius = UDim.new(0, 10)

local gengarPanel = Instance.new("ImageLabel", sb)
gengarPanel.Size = UDim2.new(0, 40, 0, 40)
gengarPanel.Position = UDim2.new(0, 10, 0, 8)
gengarPanel.BackgroundTransparency = 1
gengarPanel.Image = "rbxassetid://8031522141"
gengarPanel.ZIndex = 3

local ct = Instance.new("Frame", mn)
ct.Size = UDim2.new(1, -28, 1, -70)
ct.Position = UDim2.new(0, 14, 0, 62)
ct.BackgroundTransparency = 1
ct.ZIndex = 3

local t1 = Instance.new("TextLabel", sb)
t1.Size = UDim2.new(1, -48, 0, 20)
t1.Position = UDim2.new(0, 55, 0, 16)
t1.BackgroundTransparency = 1
t1.Text = "ZEDUX HUB"
t1.TextColor3 = Color3.fromRGB(255, 255, 255)
t1.TextSize = 14
t1.Font = Enum.Font.GothamBold
t1.TextXAlignment = Enum.TextXAlignment.Left
t1.ZIndex = 3

local mnu = Instance.new("ScrollingFrame", sb)
mnu.Size = UDim2.new(1, -24, 1, -280)
mnu.Position = UDim2.new(0, 12, 0, 60)
mnu.BackgroundTransparency = 1
mnu.BorderSizePixel = 0
mnu.ScrollBarThickness = 3
mnu.AutomaticCanvasSize = Enum.AutomaticSize.Y
mnu.ZIndex = 3
Instance.new("UIListLayout", mnu).Padding = UDim.new(0, 3)

local CC = {ESP = Color3.fromRGB(220, 220, 220), Mov = Color3.fromRGB(200, 200, 200), Combate = Color3.fromRGB(255, 255, 255), Tele = Color3.fromRGB(180, 180, 180), Troll = Color3.fromRGB(230, 230, 230), Config = Color3.fromRGB(150, 150, 150), Log = Color3.fromRGB(200, 200, 200), Adm = Color3.fromRGB(255, 255, 255), Keys = Color3.fromRGB(230, 230, 230), Personalizacao = Color3.fromRGB(180, 180, 180), Main = Color3.fromRGB(255, 255, 255), Custom = Color3.fromRGB(0, 255, 100)}
local IC = {ESP = "📡", Mov = "🏃", Combate = "🎯", Tele = "🌀", Troll = "🎭", Config = "⚙️", Log = "📋", Adm = "🔓", Keys = "🔑", Personalizacao = "🎨", Main = "🏠", Custom = "👕"}
for a, b in pairs({MOVIMENTO = "Mov", COMBATE = "Combate", TELECINESE = "Tele", TROLL = "Troll", ["PERSONALIZAÇÃO"] = "Personalizacao", ["CONFIGURAÇÕES"] = "Config", ["ADMINISTRAÇÃO"] = "Adm", ["GERADOR DE KEYS"] = "Keys", REGISTROS = "Log", ["CUSTOMIZAÇÃO AVANÇADA"] = "Custom"}) do
    CC[a] = CC[b]
    IC[a] = IC[b]
end
CC["PLAYERS"] = CC.Main
IC["PLAYERS"] = "👥"
local mB = {}
local cs = {}

local function sp(p, tx, cr)
    local h = Instance.new("Frame", p)
    h.Size = UDim2.new(1, 0, 0, 20)
    h.BackgroundTransparency = 1
    h.ZIndex = 3
    local l = Instance.new("TextLabel", h)
    l.Size = UDim2.new(0, 80, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = tx
    l.TextColor3 = cr
    l.TextSize = 8
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 3
end

local function cat(n)
    local cr = CC[n] or Color3.fromRGB(200, 200, 200)
    local ic = IC[n] or "◆"
    local b = Instance.new("TextButton", mnu)
    b.Size = UDim2.new(1, 0, 0, 28)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    b.Text = "  " .. ic .. "  " .. n
    b.TextColor3 = cr    b.TextSize = 10
    b.Font = Enum.Font.GothamBold
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.AutoButtonColor = false
    b.ZIndex = 3
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    mB[n] = b
    table.insert(cs, n)
    return b
end

sp(mnu, "DASHBOARD", Color3.fromRGB(255, 255, 255))
cat("Main")
sp(mnu, "MOVIMENTO", Color3.fromRGB(200, 200, 200))
cat("MOVIMENTO")
cat("ESP")
cat("PLAYERS")
sp(mnu, "AÇÕES", Color3.fromRGB(200, 200, 200))
cat("COMBATE")
cat("TELECINESE")
cat("TROLL")
sp(mnu, "CUSTOM", Color3.fromRGB(200, 200, 200))
cat("PERSONALIZAÇÃO")
cat("CUSTOMIZAÇÃO AVANÇADA") -- NOVA ABA ADICIONADA
sp(mnu, "SISTEMA", Color3.fromRGB(150, 150, 150))
cat("CONFIGURAÇÕES")
if AD then cat("ADMINISTRAÇÃO") end
if AD then cat("GERADOR DE KEYS") end
if AD then cat("REGISTROS") end

local jT = Instance.new("TextLabel", sb)
jT.Size = UDim2.new(1, -24, 0, 14)
jT.Position = UDim2.new(0, 12, 1, -206)
jT.BackgroundTransparency = 1
jT.Text = "JOGADORES (0)"
jT.TextColor3 = Color3.fromRGB(180, 180, 180)
jT.TextSize = 9
jT.Font = Enum.Font.GothamBold
jT.TextXAlignment = Enum.TextXAlignment.Left
jT.ZIndex = 3

local jC = Instance.new("TextLabel", sb)
jC.Size = UDim2.new(0, 40, 0, 14)
jC.Position = UDim2.new(1, -52, 1, -206)
jC.BackgroundTransparency = 1
jC.Text = "0"
jC.TextColor3 = Color3.fromRGB(255, 255, 255)
jC.TextSize = 9
jC.Font = Enum.Font.GothamBold
jC.TextXAlignment = Enum.TextXAlignment.Right
jC.ZIndex = 3

local function upC()
    local t = #P:GetPlayers()
    jT.Text = "JOGADORES (" .. t .. ")"
    jC.Text = tostring(t)
end
upC()
Z.track(P.PlayerAdded:Connect(function() task.wait(0.1) upC() end))
Z.track(P.PlayerRemoving:Connect(function() task.wait(0.1) upC() end))

local pl = Instance.new("ScrollingFrame", sb)
pl.Size = UDim2.new(1, -24, 0, 120)
pl.Position = UDim2.new(0, 12, 1, -190)
pl.BackgroundTransparency = 1
pl.BorderSizePixel = 0
pl.ScrollBarThickness = 3
pl.AutomaticCanvasSize = Enum.AutomaticSize.Y
pl.ZIndex = 3
Instance.new("UIListLayout", pl).Padding = UDim.new(0, 3)

local av = Instance.new("Frame", sb)
av.Size = UDim2.new(1, -24, 0, 58)
av.Position = UDim2.new(0, 12, 1, -64)
av.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
av.BorderSizePixel = 0
av.ZIndex = 3
Instance.new("UICorner", av).CornerRadius = UDim.new(0, 8)

local bs = Instance.new("UIStroke", av)
bs.Color = Color3.fromRGB(150, 150, 150)
bs.Thickness = 1.2
bs.Transparency = 0.4

local ai = Instance.new("ImageLabel", av)
ai.Size = UDim2.new(0, 42, 0, 42)
ai.Position = UDim2.new(0, 8, 0, 8)
ai.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ai.BorderSizePixel = 0
ai.Image = ""
ai.ZIndex = 4
Instance.new("UICorner", ai).CornerRadius = UDim.new(1, 0)

local as = Instance.new("UIStroke", ai)
as.Color = Color3.fromRGB(150, 150, 150)
as.Thickness = 2
as.Transparency = 0.2

local nk = Instance.new("TextLabel", av)
nk.Size = UDim2.new(1, -58, 0, 16)
nk.Position = UDim2.new(0, 56, 0, 12)
nk.BackgroundTransparency = 1
nk.Text = LP.Name
nk.TextColor3 = Color3.fromRGB(255, 255, 255)
nk.TextSize = 11
nk.Font = Enum.Font.GothamBold
nk.TextXAlignment = Enum.TextXAlignment.Left
nk.TextTruncate = Enum.TextTruncate.AtEnd
nk.ZIndex = 4

local cg = Instance.new("TextLabel", av)
cg.Size = UDim2.new(1, -58, 0, 12)
cg.Position = UDim2.new(0, 56, 0, 30)
cg.BackgroundTransparency = 1
cg.Text = CG
cg.TextColor3 = Color3.fromRGB(200, 200, 200)
cg.TextSize = 9
cg.Font = Enum.Font.GothamBold
cg.TextXAlignment = Enum.TextXAlignment.Left
cg.ZIndex = 4

if CG == "PROPRIETÁRIO" then
    cg.TextColor3 = Color3.fromRGB(255, 255, 255)
    bs.Color = Color3.fromRGB(255, 255, 255)
    as.Color = Color3.fromRGB(255, 255, 255)
end

task.spawn(function()
    pcall(function() ai.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=150&h=150" end)
end)

local tg = Instance.new("ScreenGui", game:GetService("CoreGui"))
tg.Name = "ZeduxToast"
tg.ResetOnSpawn = false
tg.IgnoreGuiInset = true
tg.DisplayOrder = 99998

local tc = Instance.new("Frame", tg)
tc.Size = UDim2.new(0, 320, 1, -40)
tc.Position = UDim2.new(1, -340, 0, 20)
tc.BackgroundTransparency = 1

local tl = Instance.new("UIListLayout", tc)
tl.Padding = UDim.new(0, 8)
tl.VerticalAlignment = Enum.VerticalAlignment.Bottom
tl.HorizontalAlignment = Enum.HorizontalAlignment.Right

local tO = 0
local function toast(tx, tp)
    if not Z.TOASTS then return end
    tp = tp or "info"
    tO = tO + 1
    local cB, iC
    if tp == "ok" then cB = Color3.fromRGB(80, 255, 140) iC = "✅"
    elseif tp == "err" then cB = Color3.fromRGB(255, 80, 80) iC = "❌"
    elseif tp == "warn" then cB = Color3.fromRGB(255, 200, 80) iC = "⚠️"
    else cB = Color3.fromRGB(200, 200, 200) iC = "ℹ️" end
    
    local c = Instance.new("Frame", tc)
    c.Size = UDim2.new(1, 0, 0, 56)
    c.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    c.BorderSizePixel = 0
    c.LayoutOrder = tO
    c.Position = UDim2.new(1, 50, 0, 0)
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 10)
    
    local ic = Instance.new("TextLabel", c)
    ic.Size = UDim2.new(0, 24, 0, 24)
    ic.Position = UDim2.new(0, 18, 0, 10)
    ic.BackgroundTransparency = 1
    ic.Text = iC
    ic.TextSize = 16
    ic.Font = Enum.Font.GothamBold
    
    local tx2 = Instance.new("TextLabel", c)
    tx2.Size = UDim2.new(1, -60, 0, 18)
    tx2.Position = UDim2.new(0, 48, 0, 8)
    tx2.BackgroundTransparency = 1
    tx2.Text = "ZEDUX HUB"
    tx2.TextColor3 = cB
    tx2.TextSize = 11
    tx2.Font = Enum.Font.GothamBold
    tx2.TextXAlignment = Enum.TextXAlignment.Left
    
    local tx3 = Instance.new("TextLabel", c)
    tx3.Size = UDim2.new(1, -60, 0, 20)
    tx3.Position = UDim2.new(0, 48, 0, 24)
    tx3.BackgroundTransparency = 1
    tx3.Text = tx
    tx3.TextColor3 = Color3.fromRGB(200, 200, 200)
    tx3.TextSize = 9
    tx3.Font = Enum.Font.Gotham
    tx3.TextWrapped = true
    tx3.TextXAlignment = Enum.TextXAlignment.Left
    
    T:Create(c, TweenInfo.new(0.3), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    task.spawn(function()
        task.wait(2.5)
        T:Create(c, TweenInfo.new(0.3), {Position = UDim2.new(1, 50, 0, 0)}):Play()
        task.wait(0.3)
        c:Destroy()
    end)
end

local ro = reg
reg = function(a)
    ro(a)
    local al = a:lower()
    local tp = "info"
    if a:find("❌", 1, true) or al:find("erro", 1, true) or al:find("falh", 1, true) then tp = "err"
    elseif al:sub(-4) == " off" or al:find("fechad", 1, true) or al:find("minimizad", 1, true) or al:find("removid", 1, true) or al:find("limp", 1, true) or al:find("apagad", 1, true) then tp = "warn"
    elseif al:sub(-3) == " on" or al:find("aprov", 1, true) or al:find("aberto", 1, true) or al:find("gerada", 1, true) or al:find("salv", 1, true) or al:find("copiad", 1, true) or al:find("carregad", 1, true) or al:find("cargo", 1, true) then tp = "ok" end
    toast(a, tp)
end

local function card(ti, p, cr)
    local c = Instance.new("Frame", p)
    c.Size = UDim2.new(1, 0, 0, 0)
    c.AutomaticSize = Enum.AutomaticSize.Y
    c.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    c.ZIndex = 3
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 7)
    
    local pd = Instance.new("UIPadding", c)
    pd.PaddingTop = UDim.new(0, 9)
    pd.PaddingBottom = UDim.new(0, 9)
    pd.PaddingLeft = UDim.new(0, 12)
    pd.PaddingRight = UDim.new(0, 12)
    
    local br = Instance.new("Frame", c)
    br.Size = UDim2.new(0, 2, 0, 12)
    br.Position = UDim2.new(0, 0, 0, 9)
    br.BackgroundColor3 = cr or Color3.fromRGB(200, 200, 200)
    
    local t = Instance.new("TextLabel", c)
    t.Size = UDim2.new(1, -8, 0, 12)
    t.Position = UDim2.new(0, 8, 0, 7)
    t.BackgroundTransparency = 1
    t.Text = ti
    t.TextColor3 = cr or Color3.fromRGB(200, 200, 200)
    t.TextSize = 9
    t.Font = Enum.Font.GothamBold
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 4
    
    Instance.new("UIListLayout", c).Padding = UDim.new(0, 6)
    
    local h = Instance.new("Frame", c)
    h.Size = UDim2.new(1, 0, 0, 0)
    h.AutomaticSize = Enum.AutomaticSize.Y
    h.BackgroundTransparency = 1
    h.LayoutOrder = 2
    h.ZIndex = 4
    Instance.new("UIListLayout", h).Padding = UDim.new(0, 6)
    return h
end

local function bt(p, tx, cb, tr)
    local b = Instance.new("TextButton", p)
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = tr and Color3.fromRGB(50, 20, 20) or Color3.fromRGB(25, 25, 25)
    b.Text = "  " .. tx
    b.TextColor3 = tr and Color3.fromRGB(220, 180, 190) or Color3.fromRGB(220, 220, 220)
    b.TextSize = 10
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.ZIndex = 4
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    
    local bs = Instance.new("UIStroke", b)
    bs.Color = Color3.fromRGB(100, 100, 100)
    bs.Thickness = 1
    
    local cH = tr and Color3.fromRGB(80, 30, 30) or Color3.fromRGB(45, 45, 45)
    local cB = b.BackgroundColor3
    local cT = b.TextColor3
    
    b.MouseEnter:Connect(function() T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = cH}):Play() end)
    b.MouseLeave:Connect(function() T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = cB}):Play() end)
    
    b.MouseButton1Click:Connect(function()
        T:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(200, 200, 200), TextColor3 = Color3.fromRGB(0,0,0)}):Play()
        reg(tx)
        task.wait(0.1)
        T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = cH, TextColor3 = cT}):Play()
        cb()
    end)
    return b
end

local function btT(p, tx, cb, cr)
    local h = Instance.new("Frame", p)
    h.Size = UDim2.new(1, 0, 0, 34)
    h.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    h.ZIndex = 4
    Instance.new("UICorner", h).CornerRadius = UDim.new(0, 8)
    
    local l = Instance.new("TextLabel", h)
    l.Size = UDim2.new(1, -60, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = tx
    l.TextColor3 = Color3.fromRGB(220, 220, 220)
    l.TextSize = 10
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 5
    
    local trk = Instance.new("Frame", h)
    trk.Size = UDim2.new(0, 44, 0, 22)
    trk.Position = UDim2.new(1, -52, 0.5, -11)
    trk.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    trk.ZIndex = 5
    Instance.new("UICorner", trk).CornerRadius = UDim.new(1, 0)
    
    local th = Instance.new("Frame", trk)
    th.Size = UDim2.new(0, 18, 0, 18)
    th.Position = UDim2.new(0, 2, 0.5, -9)
    th.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    th.ZIndex = 5
    Instance.new("UICorner", th).CornerRadius = UDim.new(1, 0)
    
    local btn = Instance.new("TextButton", h)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 6
    
    local a = false
    btn.MouseButton1Click:Connect(function()
        a = not a
        if a then
            T:Create(trk, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play()
            T:Create(th, TweenInfo.new(0.2), {Position = UDim2.new(1, -20, 0.5, -9), BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
        else
            T:Create(trk, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
            T:Create(th, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -9), BackgroundColor3 = Color3.fromRGB(220, 220, 220)}):Play()
        end
        reg(tx .. " " .. (a and "ON" or "OFF"))
        cb(a)
    end)
    return h
end

-- =======================================================
-- 2.9 HELPERS NOVOS: TOGGLE COM ESTADO, SLIDER, SELETOR, CONFIG, UNLOAD
-- =======================================================
do
    local Linked = {}
    local CFG = {}
    local clamp = function(v, a, b) return math.max(a, math.min(b, v)) end
    Z.clamp = clamp
    Z.CONFIGFILE = "zedux_config.json"


    local function cfgReg(key, get, set)
        if not CFG[key] then CFG[key] = {get = get, set = set} end
    end

    -- Toggle com estado. Toggles com a mesma key ficam sincronizados (ex.: atalho do dashboard e aba Config).
    function Z.tg2(p, tx, key, def, cb)
        local h = Instance.new("Frame", p)
        h.Size = UDim2.new(1, 0, 0, 34)
        h.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        h.ZIndex = 4
        Instance.new("UICorner", h).CornerRadius = UDim.new(0, 8)

        local l = Instance.new("TextLabel", h)
        l.Size = UDim2.new(1, -60, 1, 0)
        l.Position = UDim2.new(0, 12, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = tx
        l.TextColor3 = Color3.fromRGB(220, 220, 220)
        l.TextSize = 10
        l.Font = Enum.Font.GothamBold
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.ZIndex = 5

        local trk = Instance.new("Frame", h)
        trk.Size = UDim2.new(0, 44, 0, 22)
        trk.Position = UDim2.new(1, -52, 0.5, -11)
        trk.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        trk.ZIndex = 5
        Instance.new("UICorner", trk).CornerRadius = UDim.new(1, 0)

        local th = Instance.new("Frame", trk)
        th.Size = UDim2.new(0, 18, 0, 18)
        th.Position = UDim2.new(0, 2, 0.5, -9)
        th.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
        th.ZIndex = 5
        Instance.new("UICorner", th).CornerRadius = UDim.new(1, 0)

        local btn = Instance.new("TextButton", h)
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 6

        local state = false
        local api = {frame = h}
        local peers = Linked[key]
        if not peers then
            peers = {}
            Linked[key] = peers
        end
        peers[#peers + 1] = api
        local first = (peers[1] == api)

        local function paint()
            local info = TweenInfo.new(0.2)
            if state then
                T:Create(trk, info, {BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play()
                T:Create(th, info, {Position = UDim2.new(1, -20, 0.5, -9), BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
            else
                T:Create(trk, info, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
                T:Create(th, info, {Position = UDim2.new(0, 2, 0.5, -9), BackgroundColor3 = Color3.fromRGB(220, 220, 220)}):Play()
            end
        end

        function api.get() return state end
        function api.set(v, fromPeer)
            v = v and true or false
            if fromPeer and state == v then return end
            state = v
            paint()
            if fromPeer then return end
            for _, o in ipairs(peers) do
                if o ~= api then o.set(v, true) end
            end
            cb(state)
        end

        btn.MouseButton1Click:Connect(function()
            api.set(not state)
            reg(tx .. " " .. (state and "ON" or "OFF"))
        end)

        cfgReg(key, function() return state end, function(v) api.set(v == true) end)
        if first then
            state = def and true or false
        else
            state = peers[1].get()
        end
        paint()
        if first and state then cb(state) end
        return api
    end

    -- Slider arrastavel (mouse e toque). fmt(valor) -> texto exibido.
    function Z.sl(p, tx, key, mn, mx, def, step, cb, fmt)
        local h = Instance.new("Frame", p)
        h.Size = UDim2.new(1, 0, 0, 44)
        h.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        h.ZIndex = 4
        Instance.new("UICorner", h).CornerRadius = UDim.new(0, 8)

        local l = Instance.new("TextLabel", h)
        l.Size = UDim2.new(1, -100, 0, 16)
        l.Position = UDim2.new(0, 12, 0, 5)
        l.BackgroundTransparency = 1
        l.Text = tx
        l.TextColor3 = Color3.fromRGB(220, 220, 220)
        l.TextSize = 10
        l.Font = Enum.Font.GothamBold
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.ZIndex = 5

        local vl = Instance.new("TextLabel", h)
        vl.Size = UDim2.new(0, 80, 0, 16)
        vl.Position = UDim2.new(1, -92, 0, 5)
        vl.BackgroundTransparency = 1
        vl.TextColor3 = Color3.fromRGB(200, 200, 200)
        vl.TextSize = 10
        vl.Font = Enum.Font.GothamBold
        vl.TextXAlignment = Enum.TextXAlignment.Right
        vl.ZIndex = 5

        local trk = Instance.new("Frame", h)
        trk.Size = UDim2.new(1, -24, 0, 6)
        trk.Position = UDim2.new(0, 12, 0, 29)
        trk.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        trk.ZIndex = 5
        Instance.new("UICorner", trk).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame", trk)
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        fill.ZIndex = 5
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame", trk)
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new(0, 0, 0.5, 0)
        knob.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
        knob.ZIndex = 6
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local value = def
        local api = {frame = h}
        local function setVal(x)
            x = clamp(tonumber(x) or def, mn, mx)
            if step and step > 0 then x = mn + math.floor((x - mn) / step + 0.5) * step end
            x = clamp(math.floor(x * 1000 + 0.5) / 1000, mn, mx)
            value = x
            local f = (mx == mn) and 0 or (x - mn) / (mx - mn)
            fill.Size = UDim2.new(f, 0, 1, 0)
            knob.Position = UDim2.new(f, 0, 0.5, 0)
            vl.Text = fmt and fmt(x) or tostring(x)
            cb(x)
        end
        function api.set(x) setVal(x) end
        function api.get() return value end

        local dragging = false
        local scroller = nil
        local function fromX(px)
            local a = trk.AbsolutePosition.X
            local wd = trk.AbsoluteSize.X
            if wd <= 0 then return end
            setVal(mn + clamp((px - a) / wd, 0, 1) * (mx - mn))
        end
        h.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                scroller = h:FindFirstAncestorOfClass("ScrollingFrame")
                if scroller then scroller.ScrollingEnabled = false end
                fromX(i.Position.X)
            end
        end)
        Z.track(U.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                fromX(i.Position.X)
            end
        end))
        Z.track(U.InputEnded:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
                dragging = false
                if scroller then scroller.ScrollingEnabled = true end
            end
        end))

        cfgReg(key, api.get, api.set)
        setVal(def)
        return api
    end

    -- Seletor que alterna entre opcoes ao clicar. cb(indice, nome)
    function Z.dd(p, tx, key, options, def, cb)
        local idx = clamp(def, 1, #options)
        local b
        b = bt(p, tx, function()
            idx = idx % #options + 1
            b.Text = "  " .. tx .. ": " .. options[idx]
            cb(idx, options[idx])
        end)
        b.Text = "  " .. tx .. ": " .. options[idx]
        cfgReg(key, function() return idx end, function(v)
            v = math.floor(tonumber(v) or def)
            if v < 1 or v > #options then return end
            idx = v
            b.Text = "  " .. tx .. ": " .. options[idx]
            cb(idx, options[idx])
        end)
        cb(idx, options[idx])
        return b
    end

    function Z.saveConfig()
        local out = {}
        for k, e in pairs(CFG) do
            local ok, v = pcall(e.get)
            if ok and v ~= nil then out[k] = v end
        end
        return (pcall(function()
            writefile(Z.CONFIGFILE, game:GetService("HttpService"):JSONEncode(out))
        end))
    end

    function Z.loadConfig()
        local data
        local ok = pcall(function()
            data = game:GetService("HttpService"):JSONDecode(readfile(Z.CONFIGFILE))
        end)
        if not ok or type(data) ~= "table" or next(data) == nil then return false end
        for k, v in pairs(data) do
            local e = CFG[k]
            if e then pcall(e.set, v) end
        end
        return true
    end

    -- Anti-AFK por evento (Idled), sem loop.
    local afkConn = nil
    function Z.setAntiAfk(v)
        if v then
            if afkConn then return end
            afkConn = LP.Idled:Connect(function()
                pcall(function()
                    local vu = game:GetService("VirtualUser")
                    vu:CaptureController()
                    vu:ClickButton2(Vector2.new())
                end)
            end)
        elseif afkConn then
            afkConn:Disconnect()
            afkConn = nil
        end
    end
    Z.onUnload(function() Z.setAntiAfk(false) end)

    -- Fullbright que guarda e restaura a iluminacao original.
    local fbOrig = nil
    local fbToken = 0
    function Z.setFullbright(v)
        local l = game:GetService("Lighting")
        fbToken = fbToken + 1
        local my = fbToken
        if v then
            if not fbOrig then
                fbOrig = {Brightness = l.Brightness, ClockTime = l.ClockTime, FogEnd = l.FogEnd, GlobalShadows = l.GlobalShadows, Ambient = l.Ambient}
            end
            task.spawn(function()
                while Z.ALIVE and fbToken == my do
                    pcall(function()
                        l.Brightness = 2
                        l.ClockTime = 14
                        l.FogEnd = 100000
                        l.GlobalShadows = false
                        l.Ambient = Color3.fromRGB(178, 178, 178)
                    end)
                    task.wait(1)
                end
            end)
        elseif fbOrig then
            local o = fbOrig
            fbOrig = nil
            pcall(function()
                l.Brightness = o.Brightness
                l.ClockTime = o.ClockTime
                l.FogEnd = o.FogEnd
                l.GlobalShadows = o.GlobalShadows
                l.Ambient = o.Ambient
            end)
        end
    end
    Z.onUnload(function() Z.setFullbright(false) end)

    -- Fechamento limpo: para loops, desconecta eventos e destroi as GUIs.
    function Z.Unload()
        if not Z.ALIVE then return end
        if Z.autosave then pcall(Z.saveConfig) end
        Z.ALIVE = false
        for _, f in ipairs(Z.Hooks) do pcall(f) end
        for _, c in ipairs(Z.Conns) do pcall(function() c:Disconnect() end) end
        pcall(function() gui:Destroy() end)
        pcall(function() tg:Destroy() end)
        if getgenv().ZEDUX_UNLOAD == Z.Unload then getgenv().ZEDUX_UNLOAD = nil end
    end
    getgenv().ZEDUX_UNLOAD = Z.Unload
end

local sec = {}
for _, n in ipairs(cs) do
    local sc = Instance.new("ScrollingFrame", ct)
    sc.Size = UDim2.new(1, 0, 1, 0)
    sc.BackgroundTransparency = 1
    sc.ScrollBarThickness = 4
    sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sc.Visible = false
    sc.ZIndex = 3
    Instance.new("UIListLayout", sc).Padding = UDim.new(0, 8)
    sec[n] = sc
end

local function sel(n)
    for nn, b in pairs(mB) do
        local cr = CC[nn] or Color3.fromRGB(200, 200, 200)
        if nn == n then
            b.BackgroundColor3 = cr
            b.TextColor3 = Color3.fromRGB(0, 0, 0)
        else
            b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            b.TextColor3 = cr
        end
    end
    for nn, s in pairs(sec) do s.Visible = (nn == n) end
end

for n, b in pairs(mB) do
    b.MouseButton1Click:Connect(function() sel(n) end)
end

local mh = Instance.new("TextLabel", mn)
mh.Size = UDim2.new(1, -180, 0, 18)
mh.Position = UDim2.new(0, 18, 0, 14)
mh.BackgroundTransparency = 1
mh.Text = "ZEDUX HUB 👻"
mh.TextColor3 = Color3.fromRGB(255, 255, 255)
mh.TextSize = 13
mh.Font = Enum.Font.GothamBold
mh.TextXAlignment = Enum.TextXAlignment.Left
mh.ZIndex = 3

local fL = Instance.new("TextLabel", mn)
fL.Size = UDim2.new(0, 150, 0, 18)
fL.Position = UDim2.new(0, 180, 0, 14)
fL.BackgroundTransparency = 1
fL.Text = "FPS: -- | --ms"
fL.TextColor3 = Color3.fromRGB(200, 200, 200)
fL.TextSize = 12
fL.Font = Enum.Font.GothamBold
fL.ZIndex = 3

local fr = 0
local ti = tick()
task.spawn(function()
    while fL.Parent do
        fr = fr + 1
        local a = tick()
        if a - ti >= 1 then
            local f = math.floor(fr / (a - ti))
            fr = 0
            ti = a
            local p = 0
            pcall(function() p = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            fL.Text = "FPS: " .. f .. " | " .. p .. "ms"
        end
        R.RenderStepped:Wait()
    end
end)

local function hB(x, tx)
    local b = Instance.new("TextButton", mn)
    b.Size = UDim2.new(0, 28, 0, 28)
    b.Position = UDim2.new(1, x, 0, 14)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    b.Text = tx
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false
    b.ZIndex = 3
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local mB2 = hB(-170, "−")
local pB = hB(-138, "+")
local hB2 = hB(-80, "👁️")
local cB2 = hB(-44, "□")

-- =======================================================
-- 3. CONTEÚDO DA ABA MAIN (DASHBOARD)
-- =======================================================
local cMain = Instance.new("Frame", sec["Main"])
cMain.Size = UDim2.new(1, 0, 0, 0)
cMain.AutomaticSize = Enum.AutomaticSize.Y
cMain.BackgroundTransparency = 1
cMain.ZIndex = 3

local welcomeCard = Instance.new("Frame", cMain)
welcomeCard.Size = UDim2.new(1, 0, 0, 80)
welcomeCard.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
welcomeCard.BorderSizePixel = 0
welcomeCard.ZIndex = 4
Instance.new("UICorner", welcomeCard).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", welcomeCard).Color = Color3.fromRGB(150, 150, 150)

local avatarBall = Instance.new("ImageLabel", welcomeCard)
avatarBall.Size = UDim2.new(0, 60, 0, 60)
avatarBall.Position = UDim2.new(0, 10, 0.5, -30)
avatarBall.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
avatarBall.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=150&h=150"
Instance.new("UICorner", avatarBall).CornerRadius = UDim.new(1, 0)
local avStroke = Instance.new("UIStroke", avatarBall)
avStroke.Color = Color3.fromRGB(200, 200, 200)
avStroke.Thickness = 2
avatarBall.ZIndex = 5

local welcomeText = Instance.new("TextLabel", welcomeCard)
welcomeText.Size = UDim2.new(1, -90, 0, 20)
welcomeText.Position = UDim2.new(0, 80, 0, 20)
welcomeText.BackgroundTransparency = 1
welcomeText.Text = "Bem-vindo de volta,"
welcomeText.TextColor3 = Color3.fromRGB(200, 200, 200)
welcomeText.TextSize = 12
welcomeText.Font = Enum.Font.Gotham
welcomeText.TextXAlignment = Enum.TextXAlignment.Left
welcomeText.ZIndex = 5

local nameText = Instance.new("TextLabel", welcomeCard)
nameText.Size = UDim2.new(1, -90, 0, 25)
nameText.Position = UDim2.new(0, 80, 0, 38)
nameText.BackgroundTransparency = 1
nameText.Text = LP.DisplayName
nameText.TextColor3 = Color3.fromRGB(255, 255, 255)
nameText.TextSize = 18
nameText.Font = Enum.Font.GothamBold
nameText.TextXAlignment = Enum.TextXAlignment.Left
nameText.ZIndex = 5

local statsGrid = Instance.new("Frame", cMain)
statsGrid.Size = UDim2.new(1, 0, 0, 70)
statsGrid.Position = UDim2.new(0, 0, 0, 90)
statsGrid.BackgroundTransparency = 1
statsGrid.ZIndex = 4
local gridLayout = Instance.new("UIGridLayout", statsGrid)
gridLayout.CellSize = UDim2.new(0.32, 0, 1, 0)
gridLayout.CellPadding = UDim2.new(0, 5, 0, 0)

local function createStatCard(parent, title, value, color)
    local cardFrame = Instance.new("Frame", parent)
    cardFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    cardFrame.BorderSizePixel = 0
    cardFrame.ZIndex = 5
    Instance.new("UICorner", cardFrame).CornerRadius = UDim.new(0, 8)
    
    local t = Instance.new("TextLabel", cardFrame)
    t.Size = UDim2.new(1, 0, 0, 20)
    t.Position = UDim2.new(0, 0, 0, 10)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = Color3.fromRGB(180, 180, 180)
    t.TextSize = 10
    t.Font = Enum.Font.GothamBold
    t.ZIndex = 6
    
    local v = Instance.new("TextLabel", cardFrame)
    v.Size = UDim2.new(1, 0, 0, 25)
    v.Position = UDim2.new(0, 0, 0, 30)
    v.BackgroundTransparency = 1
    v.Text = value
    v.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    v.TextSize = 18
    v.Font = Enum.Font.GothamBold
    v.ZIndex = 6
    return v
end

local statPlayers = createStatCard(statsGrid, "Jogadores", tostring(#P:GetPlayers()), Color3.fromRGB(255, 255, 255))
local statPing = createStatCard(statsGrid, "Ping", "...", Color3.fromRGB(200, 200, 200))
local statStatus = createStatCard(statsGrid, "Status", "Online", Color3.fromRGB(150, 150, 150))

task.spawn(function()
    while statPing.Parent do
        pcall(function()
            statPlayers.Text = tostring(#P:GetPlayers())
            local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            statPing.Text = ping .. "ms"
        end)
        task.wait(1)
    end
end)

local quickCard = Instance.new("Frame", cMain)
quickCard.Size = UDim2.new(1, 0, 0, 110)
quickCard.Position = UDim2.new(0, 0, 0, 170)
quickCard.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
quickCard.BorderSizePixel = 0
quickCard.ZIndex = 4
Instance.new("UICorner", quickCard).CornerRadius = UDim.new(0, 8)

local quickTitle = Instance.new("TextLabel", quickCard)
quickTitle.Size = UDim2.new(1, 0, 0, 20)
quickTitle.Position = UDim2.new(0, 10, 0, 10)
quickTitle.BackgroundTransparency = 1
quickTitle.Text = "Atalhos Rápidos"
quickTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
quickTitle.TextSize = 11
quickTitle.Font = Enum.Font.GothamBold
quickTitle.TextXAlignment = Enum.TextXAlignment.Left
quickTitle.ZIndex = 5

local afkBtn = Z.tg2(quickCard, "🚫 Anti-AFK", "antiafk", false, Z.setAntiAfk).frame
afkBtn.Position = UDim2.new(0, 10, 0, 35)
afkBtn.Size = UDim2.new(1, -20, 0, 32)

local fbBtn = Z.tg2(quickCard, "💡 Fullbright", "fullbright", false, Z.setFullbright).frame
fbBtn.Position = UDim2.new(0, 10, 0, 70)
fbBtn.Size = UDim2.new(1, -20, 0, 32)

local actionCard = Instance.new("Frame", cMain)
actionCard.Size = UDim2.new(1, 0, 0, 45)
actionCard.Position = UDim2.new(0, 0, 0, 290)
actionCard.BackgroundTransparency = 1
actionCard.ZIndex = 4
do
    local lay = Instance.new("UIListLayout", actionCard)
    lay.FillDirection = Enum.FillDirection.Horizontal
    lay.Padding = UDim.new(0, 10)
end

local getHwid = "Unknown"
pcall(function() getHwid = gethwid() end)

local btnDiscord = bt(actionCard, "💬 Entrar no Discord", function() 
    pcall(function() game:GetService("GuiService"):OpenBrowserWindow(URL_DISCORD) end) 
end)
btnDiscord.Size = UDim2.new(0.48, 0, 1, 0)

local btnHwid = bt(actionCard, "📋 Copiar HWID", function() 
    pcall(function() setclipboard(getHwid) end) 
    reg("HWID copiado!") 
end)
btnHwid.Size = UDim2.new(0.48, 0, 1, 0)

-- =======================================================
-- 3.1 NOVA ABA: CUSTOMIZAÇÃO AVANÇADA (HEADLESS & KORBLOX)
-- =======================================================
local cCustom = Instance.new("Frame", sec["CUSTOMIZAÇÃO AVANÇADA"])
cCustom.Size = UDim2.new(1, 0, 0, 0)
cCustom.AutomaticSize = Enum.AutomaticSize.Y
cCustom.BackgroundTransparency = 1
cCustom.ZIndex = 3

local visualCard = card("HEADLESS & KORBLOX HUB", cCustom, Color3.fromRGB(0, 255, 100))

-- Variáveis de Controle do Personagem
local isHeadless = false
local isKorblox = false
local isNoHair = false
local originalParts = setmetatable({}, {__mode = "k"}) -- cor e material originais por peça

local function updateCharacter()
    local char = LP.Character
    if not char then return end

    -- 1. Headless: esconde a cabeça e o decal do rosto
    local head = char:FindFirstChild("Head")
    if head then
        pcall(function() head.Transparency = isHeadless and 1 or 0 end)
        for _, v in ipairs(head:GetChildren()) do
            if v:IsA("Decal") then
                pcall(function() v.Transparency = isHeadless and 1 or 0 end)
            end
        end
    end

    -- 2. Korblox: escurece pernas e braços e restaura cor e material ao desligar
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and (part.Name:find("Leg") or part.Name:find("Arm") or part.Name:find("Hand") or part.Name:find("Foot")) then
            if isKorblox then
                if not originalParts[part] then
                    originalParts[part] = {color = part.Color, material = part.Material}
                end
                part.Color = Color3.fromRGB(20, 20, 20)
                part.Material = Enum.Material.SmoothPlastic
            else
                local o = originalParts[part]
                if o then
                    part.Color = o.color
                    part.Material = o.material
                    originalParts[part] = nil
                end
            end
        end
    end

    -- 3. Remover cabelo
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Accessory") and v.AccessoryType == Enum.AccessoryType.Hair then
            local hd = v:FindFirstChild("Handle")
            if hd then hd.Transparency = isNoHair and 1 or 0 end
        end
    end
end

-- Reaplica a customização quando o jogador respawna
Z.track(LP.CharacterAdded:Connect(function()
    task.wait(1.5)
    if Z.ALIVE and (isHeadless or isKorblox or isNoHair) then
        pcall(updateCharacter)
    end
end))

-- Toggles com estado próprio (o texto e a cor refletem o estado real, e entram na config salva)
Z.tg2(visualCard, "HEADLESS", "cust_headless", false, function(v)
    isHeadless = v
    pcall(updateCharacter)
end)
Z.tg2(visualCard, "KORBLOX", "cust_korblox", false, function(v)
    isKorblox = v
    pcall(updateCharacter)
end)
Z.tg2(visualCard, "WITHOUT HAIR", "cust_nohair", false, function(v)
    isNoHair = v
    pcall(updateCharacter)
end)

-- Ao descarregar, devolve o personagem ao normal
Z.onUnload(function()
    isHeadless, isKorblox, isNoHair = false, false, false
    pcall(updateCharacter)
end)

-- =======================================================
-- 4. ADMINISTRAÇÃO
-- =======================================================
if AD then
local cA = card("APROVAÇÕES", sec["ADMINISTRAÇÃO"], Color3.fromRGB(200, 200, 200))
local iA = Instance.new("TextBox", cA)
iA.Size = UDim2.new(1, 0, 0, 34)
iA.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
iA.TextColor3 = Color3.fromRGB(255, 255, 255)
iA.PlaceholderText = "nick do player..."
iA.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
iA.TextSize = 11
iA.Font = Enum.Font.GothamBold
iA.ClearTextOnFocus = false
iA.ZIndex = 5
Instance.new("UICorner", iA).CornerRadius = UDim.new(0, 6)

bt(cA, "✅ APROVAR", function()
    local n = iA.Text:gsub("%s+", "")
    if n == "" then return end
    if not getgenv().LH_AP then getgenv().LH_AP = {} end
    getgenv().LH_AP[n:lower()] = true
    reg("Aprovado: " .. n)
    iA.Text = ""
end)

bt(cA, "❌ REPROVAR", function()
    local n = iA.Text:gsub("%s+", "")
    if n == "" then return end
    getgenv().LH_AP[n:lower()] = nil
    reg("Reprovado: " .. n)
    iA.Text = ""
end)

local cCargo = card("👑 GERENCIAR CARGOS", sec["ADMINISTRAÇÃO"], Color3.fromRGB(200, 200, 200))
local selCargo = Instance.new("TextLabel", cCargo)
selCargo.Size = UDim2.new(1, 0, 0, 20)
selCargo.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
selCargo.Text = "  🎯 Nenhum jogador selecionado"
selCargo.TextColor3 = Color3.fromRGB(200, 200, 200)
selCargo.TextSize = 10
selCargo.Font = Enum.Font.GothamBold
selCargo.TextXAlignment = Enum.TextXAlignment.Left
selCargo.ZIndex = 5
Instance.new("UICorner", selCargo).CornerRadius = UDim.new(0, 6)

task.spawn(function()
    while selCargo.Parent do
        if S.sel then
            selCargo.Text = "  🎯 Selecionado: " .. S.sel.Name
            selCargo.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            selCargo.Text = "  🎯 Nenhum jogador selecionado"
            selCargo.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        task.wait(0.3)
    end
end)

local function setCargo(novoCargo)
    if not S.sel then
        reg("❌ Cargo: nenhum selecionado")
        return
    end
    local alvo = S.sel
    local id = tostring(alvo.UserId)
    local nome = alvo.Name
    if not getgenv().LH_CARGOS then getgenv().LH_CARGOS = {} end
    getgenv().LH_CARGOS[id] = novoCargo
    getgenv().LH_CARGOS[nome] = novoCargo
    reg("👑 Cargo: " .. nome .. " → " .. novoCargo)
end

local cargos = {
    {n = "👑 PROPRIETÁRIO", c = Color3.fromRGB(255, 255, 255), t = "PROPRIETÁRIO"},
    {n = "🛡️ ADMIN", c = Color3.fromRGB(220, 220, 220), t = "ADMIN"},
    {n = "⚔️ MOD", c = Color3.fromRGB(200, 200, 200), t = "MOD"},
    {n = "⭐ VIP", c = Color3.fromRGB(180, 180, 180), t = "VIP"},
    {n = "👤 JOGADOR", c = Color3.fromRGB(150, 150, 150), t = "JOGADOR"}
}

for _, cargo in ipairs(cargos) do
    local btn = Instance.new("TextButton", cCargo)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Text = "  " .. cargo.n
    btn.TextColor3 = cargo.c
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.ZIndex = 5
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function() setCargo(cargo.t) end)
end

local btnRem = Instance.new("TextButton", cCargo)
btnRem.Size = UDim2.new(1, 0, 0, 28)
btnRem.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
btnRem.Text = "  🗑️  REMOVER CARGO"
btnRem.TextColor3 = Color3.fromRGB(255, 150, 150)
btnRem.TextSize = 10
btnRem.Font = Enum.Font.GothamBold
btnRem.TextXAlignment = Enum.TextXAlignment.Left
btnRem.AutoButtonColor = false
btnRem.ZIndex = 5
Instance.new("UICorner", btnRem).CornerRadius = UDim.new(0, 6)

btnRem.MouseButton1Click:Connect(function()
    if not S.sel then
        reg("❌ Nenhum selecionado")
        return
    end
    if getgenv().LH_CARGOS then
        getgenv().LH_CARGOS[tostring(S.sel.UserId)] = nil
        getgenv().LH_CARGOS[S.sel.Name] = nil
    end
    reg("🗑️ Cargo removido: " .. S.sel.Name)
end)
end

-- =======================================================
-- 5. GERADOR DE KEYS
-- =======================================================
if AD then
local cK = card("GERADOR DE KEYS", sec["GERADOR DE KEYS"], Color3.fromRGB(200, 200, 200))
local iK = Instance.new("TextBox", cK)
iK.Size = UDim2.new(1, 0, 0, 34)
iK.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
iK.TextColor3 = Color3.fromRGB(255, 255, 255)
iK.PlaceholderText = "Ex: ZEDUX-HUB-VIP-001"
iK.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
iK.Text = ""
iK.TextSize = 11
iK.Font = Enum.Font.GothamBold
iK.ClearTextOnFocus = false
iK.ZIndex = 5
Instance.new("UICorner", iK).CornerRadius = UDim.new(0, 6)

local function salvarKeys()
    local t = ""
    for k, _ in pairs(KEYS_VALIDAS) do t = t .. k .. "\n" end
    pcall(function() writefile(KEYFILE, t) end)
end

bt(cK, "🔑 GERAR KEY", function()
    local k = iK.Text:gsub("%s+", "")
    if k == "" then reg("❌ Digite uma key!") return end
    if KEYS_VALIDAS[k] then reg("❌ Key já existe") return end
    KEYS_VALIDAS[k] = true
    salvarKeys()
    reg("🔑 Key GERADA: " .. k)
    iK.Text = ""
end)

bt(cK, "🗑️ REMOVER KEY", function()
    local k = iK.Text:gsub("%s+", "")
    if k == "" then reg("❌ Digite uma key!") return end
    if not KEYS_VALIDAS[k] then reg("❌ Key não existe") return end
    KEYS_VALIDAS[k] = nil
    salvarKeys()
    reg("🗑️ Key REMOVIDA: " .. k)
    iK.Text = ""
end)

bt(cK, "💾 Enviar Keys Discord", function()
    local lista = ""
    for k, _ in pairs(KEYS_VALIDAS) do lista = lista .. "`" .. k .. "`\n" end
    if lista == "" then reg("❌ Nenhuma key") return end
    if WEBHOOK ~= "" then
        local embed = {title = "🔑 KEYS ATIVAS", description = lista, color = 16777215, footer = {text = "Solicitado por: " .. LP.Name}, timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")}
        pcall(function() game:GetService("HttpService"):RequestAsync({Url = WEBHOOK, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = game:GetService("HttpService"):JSONEncode({username = "ZEDUX HUB", embeds = {embed}})}) end)
        reg("📤 Keys enviadas")
    end
end)

local TIPOS = {"Fixa", "Dia (24h)", "Semana", "Mês", "Ano", "Permanente"}
local PREFIXOS = {"ZEDUX-HUB-", "ZEDUX-DIA-", "ZEDUX-SEM-", "ZEDUX-MEN-", "ZEDUX-ANO-", "ZEDUX-PERM-"}
local tipoIdx = 1
Z.dd(cK, "Tipo da key", "keygen_tipo", TIPOS, 1, function(i) tipoIdx = i end)

bt(cK, "🎲 Gerar Key Aleatória", function()
    local chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
    local s = ""
    for _ = 1, 8 do
        local n = math.random(#chars)
        s = s .. chars:sub(n, n)
    end
    local k = PREFIXOS[tipoIdx] .. s
    KEYS_VALIDAS[k] = true
    salvarKeys()
    reg("🎲 Key: " .. k)
    iK.Text = k
end, true)
end

-- =======================================================
-- 6. ESP (v8: loop unico, caixa, vida, nome, distancia, ferramenta, chams, tracers, filtros)
-- =======================================================
do
    local tg2, sl, dd = Z.tg2, Z.sl, Z.dd
    local clamp = Z.clamp

    local espGui = Instance.new("ScreenGui")
    espGui.Name = "ZeduxEspLayer"
    espGui.ResetOnSpawn = false
    espGui.IgnoreGuiInset = true
    espGui.DisplayOrder = 99990
    espGui.Parent = game:GetService("CoreGui")
    Z.espGui = espGui
    Z.onUnload(function() espGui:Destroy() end)

    local COLORS = {
        {n = "Prata", c = Color3.fromRGB(220, 220, 220)}, {n = "Vermelho", c = Color3.fromRGB(255, 60, 60)},
        {n = "Azul", c = Color3.fromRGB(60, 150, 255)}, {n = "Branco", c = Color3.fromRGB(255, 255, 255)},
        {n = "Verde", c = Color3.fromRGB(70, 255, 120)}, {n = "Amarelo", c = Color3.fromRGB(255, 225, 70)},
        {n = "Roxo", c = Color3.fromRGB(180, 100, 255)}, {n = "Rosa", c = Color3.fromRGB(255, 120, 200)},
        {n = "Ciano", c = Color3.fromRGB(0, 220, 255)}, {n = "Laranja", c = Color3.fromRGB(255, 150, 50)},
    }
    local COLORNAMES = {}
    for i, c in ipairs(COLORS) do COLORNAMES[i] = c.n end
    Z.COLORS = COLORS
    Z.COLORNAMES = COLORNAMES

    local E = {
        on = false, box = true, name = true, dist = true, hp = true, tool = false, chams = false,
        tracers = false, tracerFrom = 1, teamCheck = false, teamColor = false, visCheck = false,
        rainbow = false, aliveOnly = true, maxDist = 1000, textSize = 12, fill = 0.6, thick = 1.5,
        color = 1, colorHidden = 2, displayName = false, objs = {},
        boxStyle = 1, skel = false, skelThick = 1.5, skelDist = 300, headDot = false,
        look = false, lookLen = 8, arrows = false, arrowR = 220, teamTag = false, speed = false,
        hlSel = false, selColor = 6,
    }

    local cE = card("ESP — GERAL", sec["ESP"], Color3.fromRGB(220, 220, 220))
    local cE2 = card("ESP — ELEMENTOS", sec["ESP"], Color3.fromRGB(220, 220, 220))
    local cE3 = card("ESP — CORES E FILTROS", sec["ESP"], Color3.fromRGB(220, 220, 220))
    local cE4 = card("ESP — SKELETON E EXTRAS", sec["ESP"], Color3.fromRGB(220, 220, 220))

    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.IgnoreWater = true

    -- Skeleton: cada osso liga um ponto de uma peça a um ponto de outra (offset no espaço local da peça).
    -- R15 usa o centro das peças. R6 assume as medidas padrão do avatar (torso 2x2x1, braços e pernas 1x2x1);
    -- personagens com escala customizada ficam com os ossos deslocados.
    local ZERO = Vector3.zero
    local TOP, BOT = Vector3.new(0, 1, 0), Vector3.new(0, -1, 0)
    local function bone(a, ao, b, bo) return {a = a, ao = ao or ZERO, b = b, bo = bo or ZERO} end
    local R15_SPEC = {
        bone("Head", nil, "UpperTorso"), bone("UpperTorso", nil, "LowerTorso"),
        bone("UpperTorso", nil, "LeftUpperArm"), bone("LeftUpperArm", nil, "LeftLowerArm"), bone("LeftLowerArm", nil, "LeftHand"),
        bone("UpperTorso", nil, "RightUpperArm"), bone("RightUpperArm", nil, "RightLowerArm"), bone("RightLowerArm", nil, "RightHand"),
        bone("LowerTorso", nil, "LeftUpperLeg"), bone("LeftUpperLeg", nil, "LeftLowerLeg"), bone("LeftLowerLeg", nil, "LeftFoot"),
        bone("LowerTorso", nil, "RightUpperLeg"), bone("RightUpperLeg", nil, "RightLowerLeg"), bone("RightLowerLeg", nil, "RightFoot"),
    }
    local R6_SPEC = {
        bone("Head", nil, "Torso", TOP), bone("Torso", TOP, "Torso", BOT),
        bone("Torso", TOP, "Left Arm", TOP), bone("Left Arm", TOP, "Left Arm", BOT),
        bone("Torso", TOP, "Right Arm", TOP), bone("Right Arm", TOP, "Right Arm", BOT),
        bone("Torso", BOT, "Left Leg", TOP), bone("Left Leg", TOP, "Left Leg", BOT),
        bone("Torso", BOT, "Right Leg", TOP), bone("Right Leg", TOP, "Right Leg", BOT),
    }
    local MAX_BONES = 14

    local function newLine()
        local f = Instance.new("Frame")
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.BorderSizePixel = 0
        f.Visible = false
        f.Parent = espGui
        return f
    end

    -- Coordenadas de viewport (espGui usa IgnoreGuiInset, igual ao WorldToViewportPoint).
    local function placeLine(f, a, b, col, th)
        local d = b - a
        local len = d.Magnitude
        if len < 0.5 then f.Visible = false return end
        f.Position = UDim2.fromOffset((a.X + b.X) / 2, (a.Y + b.Y) / 2)
        f.Size = UDim2.fromOffset(len, th)
        f.Rotation = math.deg(math.atan2(d.Y, d.X))
        f.BackgroundColor3 = col
        f.Visible = true
    end

    -- Devolve a posição em pixels e a profundidade; profundidade <= 0 significa atrás da câmera.
    local function project(cam, pos)
        local v = cam:WorldToViewportPoint(pos)
        return Vector2.new(v.X, v.Y), v.Z
    end

    -- Pixels por stud na profundidade dada (FieldOfView da câmera é vertical).
    local function pxPerStud(cam, depth)
        return cam.ViewportSize.Y / (2 * math.max(depth, 0.1) * math.tan(math.rad(cam.FieldOfView) / 2))
    end

    local function destroyOne(p)
        local o = E.objs[p]
        if not o then return end
        E.objs[p] = nil
        for _, k in ipairs({"box", "info", "hl", "line", "dot", "look", "arrow"}) do
            local inst = o[k]
            if inst then pcall(function() inst:Destroy() end) end
        end
        if o.bones then
            for _, f in ipairs(o.bones) do pcall(function() f:Destroy() end) end
        end
    end

    local function buildOne(p)
        if p == LP or E.objs[p] or not E.on then return end
        local char = p.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local o = {char = char, hrp = hrp, vis = true, visT = 0}

        local box = Instance.new("BillboardGui")
        box.Name = "ZB_" .. p.UserId
        box.AlwaysOnTop = true
        box.Size = UDim2.new(4, 0, 6, 0)
        box.StudsOffset = Vector3.new(0, -0.1, 0)
        box.Adornee = hrp
        box.Parent = espGui
        local frame = Instance.new("Frame", box)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        local stroke = Instance.new("UIStroke", frame)
        stroke.Thickness = E.thick
        local hpBack = Instance.new("Frame", frame)
        hpBack.Size = UDim2.new(0.07, 0, 1, 0)
        hpBack.Position = UDim2.new(-0.11, 0, 0, 0)
        hpBack.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        hpBack.BackgroundTransparency = 0.3
        hpBack.BorderSizePixel = 0
        local hpFill = Instance.new("Frame", hpBack)
        hpFill.AnchorPoint = Vector2.new(0, 1)
        hpFill.Position = UDim2.new(0, 0, 1, 0)
        hpFill.Size = UDim2.new(1, 0, 1, 0)
        hpFill.BorderSizePixel = 0

        local info = Instance.new("BillboardGui")
        info.Name = "ZI_" .. p.UserId
        info.AlwaysOnTop = true
        info.Size = UDim2.new(0, 300, 0, 44)
        info.StudsOffset = Vector3.new(0, 3.9, 0)
        info.Adornee = hrp
        info.Parent = espGui
        local nameL = Instance.new("TextLabel", info)
        nameL.Size = UDim2.new(1, 0, 0.5, 0)
        nameL.BackgroundTransparency = 1
        nameL.Font = Enum.Font.GothamBold
        nameL.TextStrokeTransparency = 0.4
        local subL = Instance.new("TextLabel", info)
        subL.Size = UDim2.new(1, 0, 0.5, 0)
        subL.Position = UDim2.new(0, 0, 0.5, 0)
        subL.BackgroundTransparency = 1
        subL.Font = Enum.Font.GothamBold
        subL.TextStrokeTransparency = 0.5

        local hl = Instance.new("Highlight")
        hl.Name = "ZH_" .. p.UserId
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Enabled = false
        hl.Adornee = char
        hl.Parent = espGui

        local line = Instance.new("Frame", espGui)
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.BorderSizePixel = 0
        line.Size = UDim2.new(0, 0, 0, 1.5)
        line.Visible = false

        o.box, o.frame, o.stroke, o.hpBack, o.hpFill = box, frame, stroke, hpBack, hpFill
        o.info, o.nameL, o.subL, o.hl, o.line = info, nameL, subL, hl, line
        E.objs[p] = o
    end

    -- Elementos extras são criados só na primeira vez que a opção é usada.
    local function ensureCorners(o)
        if o.corners then return o.corners end
        local list = {}
        for _, anchor in ipairs({Vector2.new(0, 0), Vector2.new(1, 0), Vector2.new(0, 1), Vector2.new(1, 1)}) do
            for k = 1, 2 do
                local f = Instance.new("Frame")
                f.AnchorPoint = anchor
                f.Position = UDim2.new(anchor.X, 0, anchor.Y, 0)
                f.BorderSizePixel = 0
                f.Visible = false
                f.Parent = o.frame
                list[#list + 1] = f -- índice ímpar = traço horizontal, par = vertical
            end
        end
        o.corners = list
        return list
    end

    local function ensureBones(o)
        if o.bones then return end
        o.bones, o.bl, o.blT = {}, {}, 0
        for i = 1, MAX_BONES do o.bones[i] = newLine() end
    end

    local function resolveBones(o)
        o.blT = tick()
        local char = o.char
        local spec = char:FindFirstChild("UpperTorso") and R15_SPEC or R6_SPEC
        local out = {}
        for _, e in ipairs(spec) do
            local a, b = char:FindFirstChild(e.a), char:FindFirstChild(e.b)
            if a and b and a:IsA("BasePart") and b:IsA("BasePart") then
                out[#out + 1] = {a = a, ao = e.ao, b = b, bo = e.bo}
            end
        end
        o.bl = out
    end

    local function ensureDot(o)
        if o.dot then return end
        local d = Instance.new("Frame")
        d.AnchorPoint = Vector2.new(0.5, 0.5)
        d.BackgroundTransparency = 1
        d.BorderSizePixel = 0
        d.Visible = false
        Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
        o.dotStroke = Instance.new("UIStroke", d)
        o.dotStroke.Thickness = 1.5
        d.Parent = espGui
        o.dot = d
    end

    local function ensureArrow(o)
        if o.arrow then return end
        local a = Instance.new("TextLabel")
        a.AnchorPoint = Vector2.new(0.5, 0.5)
        a.Size = UDim2.fromOffset(24, 24)
        a.BackgroundTransparency = 1
        a.Text = "▲"
        a.TextSize = 22
        a.Font = Enum.Font.GothamBold
        a.TextStrokeTransparency = 0.4
        a.Visible = false
        a.Parent = espGui
        o.arrow = a
    end

    local function rebuildAll()
        for p in pairs(E.objs) do destroyOne(p) end
        if not E.on then return end
        for _, p in ipairs(P:GetPlayers()) do buildOne(p) end
    end

    local function hideExtras(o)
        if o.bones then for _, f in ipairs(o.bones) do f.Visible = false end end
        if o.dot then o.dot.Visible = false end
        if o.look then o.look.Visible = false end
        if o.arrow then o.arrow.Visible = false end
    end

    local function hide(o)
        o.box.Enabled = false
        o.info.Enabled = false
        o.hl.Enabled = false
        o.line.Visible = false
        hideExtras(o)
    end

    local function isVisible(o, camPos)
        local now = tick()
        if now - o.visT < 0.12 then return o.vis end
        o.visT = now
        local my = LP.Character
        rp.FilterDescendantsInstances = my and {my} or {}
        local r = workspace:Raycast(camPos, o.hrp.Position - camPos, rp)
        o.vis = (r == nil) or r.Instance:IsDescendantOf(o.char)
        return o.vis
    end

    local function pickColor(p, visible)
        if E.rainbow then return Color3.fromHSV((tick() * 0.2) % 1, 0.8, 1) end
        if E.teamColor and p.Team then return p.TeamColor.Color end
        if E.visCheck and not visible then return COLORS[E.colorHidden].c end
        return COLORS[E.color].c
    end

    local function step()
        local cam = workspace.CurrentCamera
        if not cam then return end
        local camPos = cam.CFrame.Position
        local vp = cam.ViewportSize
        local now = tick()
        for p, o in pairs(E.objs) do
            local char = p.Character
            if char ~= o.char or not o.hrp.Parent then
                destroyOne(p)
                task.defer(buildOne, p)
            else
                local hum = char:FindFirstChildOfClass("Humanoid")
                local alive = hum ~= nil and hum.Health > 0
                local dist = (o.hrp.Position - camPos).Magnitude
                local show = dist <= E.maxDist
                if show and E.aliveOnly and not alive then show = false end
                if show and E.teamCheck and p.Team ~= nil and p.Team == LP.Team then show = false end
                if not show then
                    hide(o)
                else
                    local vis = true
                    if E.visCheck then vis = isVisible(o, camPos) end
                    local col = pickColor(p, vis)
                    if E.hlSel and S.sel == p then col = COLORS[E.selColor].c end

                    o.box.Enabled = E.box or E.hp
                    o.stroke.Enabled = E.box and E.boxStyle == 1
                    o.stroke.Color = col
                    o.stroke.Thickness = E.thick
                    if E.box and E.boxStyle == 2 then
                        local th = math.max(1, math.floor(E.thick + 0.5))
                        for i, f in ipairs(ensureCorners(o)) do
                            if i % 2 == 1 then
                                f.Size = UDim2.new(0.28, 0, 0, th)
                            else
                                f.Size = UDim2.new(0, th, 0.18, 0)
                            end
                            f.BackgroundColor3 = col
                            f.Visible = true
                        end
                    elseif o.corners then
                        for _, f in ipairs(o.corners) do f.Visible = false end
                    end
                    o.hpBack.Visible = E.hp and hum ~= nil
                    if E.hp and hum then
                        local f = clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                        o.hpFill.Size = UDim2.new(1, 0, f, 0)
                        o.hpFill.BackgroundColor3 = Color3.fromHSV(f * 0.33, 1, 1)
                    end

                    o.info.Enabled = E.name or E.dist or E.tool or E.hp or E.teamTag or E.speed
                    o.nameL.Visible = E.name
                    o.nameL.Text = E.displayName and p.DisplayName or p.Name
                    o.nameL.TextColor3 = col
                    o.nameL.TextSize = E.textSize
                    local parts = {}
                    if E.hp and hum then parts[#parts + 1] = "❤ " .. math.floor(hum.Health) end
                    if E.dist then parts[#parts + 1] = math.floor(dist) .. "m" end
                    if E.teamTag and p.Team then parts[#parts + 1] = "[" .. p.Team.Name .. "]" end
                    if E.speed then
                        local vel = o.hrp.AssemblyLinearVelocity
                        parts[#parts + 1] = math.floor(Vector3.new(vel.X, 0, vel.Z).Magnitude) .. " st/s"
                    end
                    if E.tool then
                        local t = char:FindFirstChildOfClass("Tool")
                        if t then parts[#parts + 1] = "🗡 " .. t.Name end
                    end
                    o.subL.Text = table.concat(parts, " · ")
                    o.subL.TextColor3 = Color3.fromRGB(235, 235, 235)
                    o.subL.TextSize = math.max(E.textSize - 2, 8)

                    o.hl.Enabled = E.chams
                    if E.chams then
                        o.hl.FillColor = col
                        o.hl.OutlineColor = col
                        o.hl.FillTransparency = E.fill
                    end

                    if E.tracers then
                        local v, on = cam:WorldToViewportPoint(o.hrp.Position)
                        if on then
                            local from
                            if E.tracerFrom == 1 then from = Vector2.new(vp.X / 2, vp.Y)
                            elseif E.tracerFrom == 2 then from = Vector2.new(vp.X / 2, vp.Y / 2)
                            else from = Vector2.new(vp.X / 2, 0) end
                            local to = Vector2.new(v.X, v.Y)
                            local d = to - from
                            o.line.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
                            o.line.Size = UDim2.fromOffset(d.Magnitude, 1.5)
                            o.line.Rotation = math.deg(math.atan2(d.Y, d.X))
                            o.line.BackgroundColor3 = col
                            o.line.Visible = true
                        else
                            o.line.Visible = false
                        end
                    else
                        o.line.Visible = false
                    end

                    -- Skeleton
                    if E.skel and dist <= E.skelDist then
                        ensureBones(o)
                        if now - o.blT > 2 then resolveBones(o) end
                        local used = 0
                        for i, bn in ipairs(o.bl) do
                            local f = o.bones[i]
                            if bn.a.Parent and bn.b.Parent then
                                local pa, za = project(cam, bn.a.CFrame:PointToWorldSpace(bn.ao))
                                local pb, zb = project(cam, bn.b.CFrame:PointToWorldSpace(bn.bo))
                                if za > 0 and zb > 0 then
                                    placeLine(f, pa, pb, col, E.skelThick)
                                else
                                    f.Visible = false
                                end
                            else
                                f.Visible = false
                            end
                            used = i
                        end
                        for i = used + 1, #o.bones do o.bones[i].Visible = false end
                    elseif o.bones then
                        for _, f in ipairs(o.bones) do f.Visible = false end
                    end

                    -- Ponto na cabeça e linha de direção (orientação da peça Head, não a mira exata)
                    local head = char:FindFirstChild("Head")
                    if E.headDot and head and head:IsA("BasePart") then
                        ensureDot(o)
                        local hp2, hz = project(cam, head.Position)
                        if hz > 0 then
                            local dia = clamp(pxPerStud(cam, hz) * head.Size.Y * 0.9, 4, 90)
                            o.dot.Size = UDim2.fromOffset(dia, dia)
                            o.dot.Position = UDim2.fromOffset(hp2.X, hp2.Y)
                            o.dotStroke.Color = col
                            o.dot.Visible = true
                        else
                            o.dot.Visible = false
                        end
                    elseif o.dot then
                        o.dot.Visible = false
                    end

                    if E.look and head and head:IsA("BasePart") then
                        if not o.look then o.look = newLine() end
                        local a2, za = project(cam, head.Position)
                        local b2, zb = project(cam, head.Position + head.CFrame.LookVector * E.lookLen)
                        if za > 0 and zb > 0 then
                            placeLine(o.look, a2, b2, col, 1.5)
                        else
                            o.look.Visible = false
                        end
                    elseif o.look then
                        o.look.Visible = false
                    end

                    -- Seta apontando para jogadores fora da tela (usa o espaço da câmera, funciona atrás de você)
                    if E.arrows then
                        local _, onScreen = cam:WorldToViewportPoint(o.hrp.Position)
                        if onScreen then
                            if o.arrow then o.arrow.Visible = false end
                        else
                            ensureArrow(o)
                            local rel = cam.CFrame:PointToObjectSpace(o.hrp.Position)
                            local s = Vector2.new(rel.X, -rel.Y)
                            if s.Magnitude < 1e-3 then s = Vector2.new(0, 1) end
                            s = s.Unit
                            local radius = math.min(E.arrowR, math.min(vp.X, vp.Y) / 2 - 24)
                            o.arrow.Position = UDim2.fromOffset(vp.X / 2 + s.X * radius, vp.Y / 2 + s.Y * radius)
                            o.arrow.Rotation = math.deg(math.atan2(s.X, -s.Y))
                            o.arrow.TextColor3 = col
                            o.arrow.Visible = true
                        end
                    elseif o.arrow then
                        o.arrow.Visible = false
                    end
                end
            end
        end
    end

    Z.track(R.RenderStepped:Connect(function()
        if E.on then pcall(step) end
    end))

    local function hookPlayer(p)
        if p == LP then return end
        Z.track(p.CharacterAdded:Connect(function()
            if not E.on then return end
            destroyOne(p)
            for _ = 1, 20 do
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then break end
                task.wait(0.25)
            end
            if E.on and p.Parent then buildOne(p) end
        end))
        if E.on and p.Character then task.defer(buildOne, p) end
    end
    for _, p in ipairs(P:GetPlayers()) do hookPlayer(p) end
    Z.track(P.PlayerAdded:Connect(hookPlayer))
    Z.track(P.PlayerRemoving:Connect(destroyOne))

    tg2(cE, "📡 ESP Players", "esp_on", false, function(v) E.on = v rebuildAll() end)
    tg2(cE, "❤ Só jogadores vivos", "esp_alive", true, function(v) E.aliveOnly = v end)
    tg2(cE, "👥 Ocultar meu time", "esp_team", false, function(v) E.teamCheck = v end)
    sl(cE, "📏 Distância máxima", "esp_maxd", 50, 5000, 1000, 50, function(v)
        E.maxDist = (v >= 5000) and math.huge or v
    end, function(v) return v >= 5000 and "∞" or (v .. "m") end)

    tg2(cE2, "▭ Caixa", "esp_box", true, function(v) E.box = v end)
    tg2(cE2, "🏷 Nome", "esp_name", true, function(v) E.name = v end)
    tg2(cE2, "🪪 Usar DisplayName", "esp_display", false, function(v) E.displayName = v end)
    tg2(cE2, "📍 Distância", "esp_dist", true, function(v) E.dist = v end)
    tg2(cE2, "❤ Vida (barra e número)", "esp_hp", true, function(v) E.hp = v end)
    tg2(cE2, "🗡 Ferramenta na mão", "esp_tool", false, function(v) E.tool = v end)
    tg2(cE2, "🧊 Chams (limite do jogo: 31)", "esp_chams", false, function(v) E.chams = v end)
    tg2(cE2, "📐 Tracers", "esp_tracers", false, function(v) E.tracers = v end)
    dd(cE2, "📐 Origem do tracer", "esp_tfrom", {"Baixo", "Centro", "Topo"}, 1, function(i) E.tracerFrom = i end)
    dd(cE2, "▭ Estilo da caixa", "esp_boxstyle", {"Completa", "Cantos"}, 1, function(i) E.boxStyle = i end)

    dd(cE3, "🎨 Cor", "esp_color", COLORNAMES, 1, function(i) E.color = i end)
    tg2(cE3, "🧱 Cor diferente atrás de parede", "esp_vis", false, function(v) E.visCheck = v end)
    dd(cE3, "🎨 Cor atrás de parede", "esp_color2", COLORNAMES, 2, function(i) E.colorHidden = i end)
    tg2(cE3, "👥 Usar cor do time", "esp_teamcolor", false, function(v) E.teamColor = v end)
    tg2(cE3, "🌈 Cor arco-íris", "esp_rainbow", false, function(v) E.rainbow = v end)
    sl(cE3, "🔠 Tamanho do texto", "esp_txt", 9, 20, 12, 1, function(v) E.textSize = v end)
    sl(cE3, "▭ Espessura da caixa", "esp_thick", 1, 4, 1.5, 0.5, function(v) E.thick = v end)
    sl(cE3, "🧊 Transparência do chams", "esp_fill", 0, 1, 0.6, 0.05, function(v) E.fill = v end)

    tg2(cE4, "🦴 Skeleton", "esp_skel", false, function(v) E.skel = v end)
    sl(cE4, "🦴 Espessura do skeleton", "esp_skel_thick", 1, 4, 1.5, 0.5, function(v) E.skelThick = v end)
    sl(cE4, "🦴 Distância do skeleton", "esp_skel_dist", 50, 1000, 300, 25, function(v)
        E.skelDist = (v >= 1000) and math.huge or v
    end, function(v) return v >= 1000 and "∞" or (v .. "m") end)
    tg2(cE4, "⚪ Ponto na cabeça", "esp_headdot", false, function(v) E.headDot = v end)
    tg2(cE4, "👁 Linha de direção da cabeça", "esp_look", false, function(v) E.look = v end)
    sl(cE4, "👁 Comprimento da linha", "esp_looklen", 2, 20, 8, 1, function(v) E.lookLen = v end, function(v) return v .. " st" end)
    tg2(cE4, "🧭 Setas para jogadores fora da tela", "esp_arrows", false, function(v) E.arrows = v end)
    sl(cE4, "🧭 Raio das setas", "esp_arrowr", 80, 450, 220, 10, function(v) E.arrowR = v end, function(v) return v .. "px" end)
    tg2(cE4, "🏳 Nome do time", "esp_teamtag", false, function(v) E.teamTag = v end)
    tg2(cE4, "💨 Velocidade (st/s)", "esp_speed", false, function(v) E.speed = v end)
    tg2(cE4, "🎯 Destacar jogador selecionado", "esp_hlsel", false, function(v) E.hlSel = v end)
    dd(cE4, "🎨 Cor do selecionado", "esp_selcolor", COLORNAMES, 6, function(i) E.selColor = i end)
end

-- =======================================================
-- 6.1 PLAYERS (todos os jogadores do servidor, com a foto do avatar)
-- =======================================================
do
    local clamp = Z.clamp
    local tab = sec["PLAYERS"]
    local entries = {}
    local spectating = nil

    local hdr = card("JOGADORES NO SERVIDOR", tab, Color3.fromRGB(220, 220, 220))
    local countL = Instance.new("TextLabel", hdr)
    countL.Name = "A1_count"
    countL.Size = UDim2.new(1, 0, 0, 16)
    countL.BackgroundTransparency = 1
    countL.Text = "Total: 0"
    countL.TextColor3 = Color3.fromRGB(200, 200, 200)
    countL.TextSize = 10
    countL.Font = Enum.Font.GothamBold
    countL.TextXAlignment = Enum.TextXAlignment.Left
    countL.ZIndex = 5

    local search = Instance.new("TextBox", hdr)
    search.Name = "A2_search"
    search.Size = UDim2.new(1, 0, 0, 30)
    search.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    search.TextColor3 = Color3.fromRGB(255, 255, 255)
    search.PlaceholderText = "🔎 filtrar por nome..."
    search.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    search.Text = ""
    search.TextSize = 11
    search.Font = Enum.Font.GothamBold
    search.ClearTextOnFocus = false
    search.ZIndex = 5
    Instance.new("UICorner", search).CornerRadius = UDim.new(0, 6)

    local listHolder = Instance.new("Frame", tab)
    listHolder.Name = "PlayersList"
    listHolder.Size = UDim2.new(1, 0, 0, 0)
    listHolder.AutomaticSize = Enum.AutomaticSize.Y
    listHolder.BackgroundTransparency = 1
    listHolder.ZIndex = 3
    local ll = Instance.new("UIListLayout", listHolder)
    ll.Padding = UDim.new(0, 6)
    ll.SortOrder = Enum.SortOrder.LayoutOrder

    local function stopSpectate(quiet)
        local was = spectating
        spectating = nil
        local cam = workspace.CurrentCamera
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if cam and hum then cam.CameraSubject = hum end
        if was and not quiet then reg("Observar OFF") end
    end

    local function setSpectate(p)
        local cam = workspace.CurrentCamera
        local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
        if not cam or not hum then reg("❌ Observar: jogador sem personagem") return end
        spectating = p
        cam.CameraSubject = hum
        reg("👁 Observando: " .. p.Name)
    end

    local function keepSpectate()
        local p = spectating
        if not p then return end
        if not p.Parent then stopSpectate() return end
        local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
        local cam = workspace.CurrentCamera
        if hum and cam and cam.CameraSubject ~= hum then cam.CameraSubject = hum end
    end
    Z.onUnload(function() stopSpectate(true) end)

    local function relayout()
        local list = {}
        for p in pairs(entries) do list[#list + 1] = p end
        table.sort(list, function(a, b)
            if (a == LP) ~= (b == LP) then return a == LP end
            return a.Name:lower() < b.Name:lower()
        end)
        for i, p in ipairs(list) do entries[p].card.LayoutOrder = i end
    end

    local function applyFilter()
        local q = search.Text:lower()
        local shown, total = 0, 0
        for p, e in pairs(entries) do
            total = total + 1
            local ok = q == "" or p.Name:lower():find(q, 1, true) ~= nil or p.DisplayName:lower():find(q, 1, true) ~= nil
            e.card.Visible = ok
            if ok then shown = shown + 1 end
        end
        countL.Text = (q == "") and ("Total: " .. total) or ("Mostrando " .. shown .. " de " .. total)
    end
    search:GetPropertyChangedSignal("Text"):Connect(applyFilter)

    local function refreshEntry(p, e, myHrp)
        local char = p.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local l3 = {}
        if p.Team then l3[#l3 + 1] = p.Team.Name end
        if hum then
            l3[#l3 + 1] = "❤ " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
        else
            l3[#l3 + 1] = "sem personagem"
        end
        if p ~= LP and hrp and myHrp then
            l3[#l3 + 1] = math.floor((hrp.Position - myHrp.Position).Magnitude) .. "m"
        end
        e.infoL.Text = table.concat(l3, " · ")
        local l4 = {}
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool then l4[#l4 + 1] = "🗡 " .. tool.Name end
        l4[#l4 + 1] = "conta " .. p.AccountAge .. "d"
        e.infoL2.Text = table.concat(l4, " · ")
        local f = hum and clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1) or 0
        e.hpFill.Size = UDim2.new(f, 0, 1, 0)
        e.hpFill.BackgroundColor3 = Color3.fromHSV(f * 0.33, 1, 1)
        local selected = S.sel == p
        e.stroke.Color = selected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(70, 70, 70)
        e.stroke.Thickness = selected and 2 or 1
        if e.btnSel then e.btnSel.Text = selected and "✔ Selecionado" or "🎯 Selecionar" end
        if e.btnSpec then e.btnSpec.Text = (spectating == p) and "⏹ Parar" or "👁 Observar" end
    end

    local function refreshAll()
        local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        for p, e in pairs(entries) do
            pcall(refreshEntry, p, e, myHrp)
        end
    end

    local function mkButton(parent, text, y)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(0, 100, 0, 20)
        b.Position = UDim2.new(1, -108, 0, y)
        b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        b.Text = text
        b.TextColor3 = Color3.fromRGB(220, 220, 220)
        b.TextSize = 9
        b.Font = Enum.Font.GothamBold
        b.ZIndex = 6
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
        return b
    end

    local function mkLabel(parent, y, h, size, font, color)
        local l = Instance.new("TextLabel", parent)
        l.Size = UDim2.new(1, -196, 0, h)
        l.Position = UDim2.new(0, 76, 0, y)
        l.BackgroundTransparency = 1
        l.TextColor3 = color
        l.TextSize = size
        l.Font = font
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextTruncate = Enum.TextTruncate.AtEnd
        l.ZIndex = 5
        return l
    end

    local function addEntry(p)
        if entries[p] then return end
        local c = Instance.new("Frame")
        c.Name = "PlayerCard"
        c.Size = UDim2.new(1, 0, 0, 80)
        c.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        c.ZIndex = 4
        c.Parent = listHolder
        Instance.new("UICorner", c).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", c)
        stroke.Color = Color3.fromRGB(70, 70, 70)
        stroke.Thickness = 1
        stroke.Transparency = 0.4

        local img = Instance.new("ImageLabel", c)
        img.Size = UDim2.new(0, 58, 0, 58)
        img.Position = UDim2.new(0, 10, 0.5, -29)
        img.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        img.BorderSizePixel = 0
        img.Image = "rbxthumb://type=AvatarHeadShot&id=" .. p.UserId .. "&w=150&h=150"
        img.ZIndex = 5
        Instance.new("UICorner", img).CornerRadius = UDim.new(1, 0)
        local imgStroke = Instance.new("UIStroke", img)
        imgStroke.Color = Color3.fromRGB(150, 150, 150)
        imgStroke.Thickness = 2

        local nameL = mkLabel(c, 6, 16, 12, Enum.Font.GothamBold, Color3.fromRGB(255, 255, 255))
        nameL.Text = p.DisplayName .. (p == LP and "  (você)" or "")
        local userL = mkLabel(c, 22, 14, 9, Enum.Font.Gotham, Color3.fromRGB(150, 150, 150))
        userL.Text = "@" .. p.Name .. " · ID " .. p.UserId
        local infoL = mkLabel(c, 37, 13, 9, Enum.Font.GothamBold, Color3.fromRGB(210, 210, 210))
        local infoL2 = mkLabel(c, 50, 13, 9, Enum.Font.Gotham, Color3.fromRGB(170, 170, 170))

        local hpBack = Instance.new("Frame", c)
        hpBack.Size = UDim2.new(1, -196, 0, 6)
        hpBack.Position = UDim2.new(0, 76, 0, 67)
        hpBack.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        hpBack.BorderSizePixel = 0
        hpBack.ZIndex = 5
        Instance.new("UICorner", hpBack).CornerRadius = UDim.new(1, 0)
        local hpFill = Instance.new("Frame", hpBack)
        hpFill.Size = UDim2.new(1, 0, 1, 0)
        hpFill.BorderSizePixel = 0
        hpFill.ZIndex = 6
        Instance.new("UICorner", hpFill).CornerRadius = UDim.new(1, 0)

        local e = {card = c, stroke = stroke, infoL = infoL, infoL2 = infoL2, hpFill = hpFill}
        entries[p] = e

        if p ~= LP then
            e.btnSel = mkButton(c, "🎯 Selecionar", 6)
            e.btnSel.MouseButton1Click:Connect(function()
                S.sel = p
                reg("Sel: " .. p.Name)
                if Z.rf then Z.rf() end
                refreshAll()
            end)
            e.btnSpec = mkButton(c, "👁 Observar", 30)
            e.btnSpec.MouseButton1Click:Connect(function()
                if spectating == p then stopSpectate() else setSpectate(p) end
                refreshAll()
            end)
        end
        local btnId = mkButton(c, "📋 Copiar ID", 54)
        btnId.MouseButton1Click:Connect(function()
            local copy = getgenv().setclipboard
            if type(copy) == "function" then
                pcall(copy, tostring(p.UserId))
                reg("ID copiado: " .. p.UserId)
            else
                reg("❌ Executor sem setclipboard")
            end
        end)
    end

    local function removeEntry(p)
        local e = entries[p]
        if e then
            entries[p] = nil
            e.card:Destroy()
        end
        if spectating == p then stopSpectate() end
        relayout()
        applyFilter()
    end

    for _, p in ipairs(P:GetPlayers()) do addEntry(p) end
    Z.track(P.PlayerAdded:Connect(function(p)
        addEntry(p)
        relayout()
        applyFilter()
    end))
    Z.track(P.PlayerRemoving:Connect(removeEntry))
    relayout()
    applyFilter()
    refreshAll()

    task.spawn(function()
        while Z.ALIVE and tab.Parent do
            task.wait(0.5)
            pcall(keepSpectate)
            if tab.Visible then pcall(refreshAll) end
        end
    end)
end

-- =======================================================
-- 7. MOVIMENTO
-- =======================================================
local cM = card("MOVIMENTO", sec["MOVIMENTO"], Color3.fromRGB(200, 200, 200))

bt(cM, "🎯 TP Para Alvo", function()
    if not S.sel or not S.sel.Character then reg("Sem alvo") return end
    if not LP.Character then return end
    local m = LP.Character:FindFirstChild("HumanoidRootPart")
    local h = S.sel.Character:FindFirstChild("HumanoidRootPart")
    if not m or not h then return end
    reg("TP → " .. S.sel.Name)
    pcall(function() m.CFrame = h.CFrame * CFrame.new(0, 0, 3) m.Velocity = Vector3.zero end)
end, true)

bt(cM, "📥 Trazer Alvo", function()
    if not S.sel or not S.sel.Character then reg("Sem alvo") return end
    if not LP.Character then return end
    local m = LP.Character:FindFirstChild("HumanoidRootPart")
    local h = S.sel.Character:FindFirstChild("HumanoidRootPart")
    if not m or not h then return end
    reg("Trazer → " .. S.sel.Name)
    pcall(function() h.CFrame = m.CFrame * CFrame.new(0, 0, 3) h.Velocity = Vector3.zero end)
end, true)

local ncA = false
local function aplN()
    if not LP.Character then return end
    for _, o in ipairs(LP.Character:GetDescendants()) do
        if o:IsA("BasePart") and o.CanCollide then o.CanCollide = false end
    end
end

btT(cM, "👻 Noclip", function(v)
    ncA = v
    if v then
        reg("Noclip ON")
        aplN()
        task.spawn(function() while ncA and Z.ALIVE do task.wait(0.15) if ncA then aplN() end end end)
    else
        reg("Noclip OFF")
        if LP.Character then
            for _, o in ipairs(LP.Character:GetDescendants()) do
                if o:IsA("BasePart") then pcall(function() o.CanCollide = true end) end
            end
        end
    end
end, Color3.fromRGB(80, 80, 120))

local spdAtivo = false
local spdValor = 16
btT(cM, "⚡ Speed Hack", function(v)
    spdAtivo = v
    if v then
        reg("Speed ON")
        task.spawn(function()
            while spdAtivo and Z.ALIVE do
                if LP.Character then
                    local hum = LP.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = spdValor end
                end
                task.wait(0.1)
            end
        end)
    else
        reg("Speed OFF")
        if LP.Character then
            local hum = LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end
end, Color3.fromRGB(60, 90, 60))

bt(cM, "⚡ Aumentar Velocidade", function()
    spdValor = spdValor + 16
    if spdValor > 200 then spdValor = 16 end
    reg("Velocidade: " .. spdValor)
    if LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = spdValor end
    end
end)

local jmpAtivo = false
local jmpValor = 50
btT(cM, "🦘 Jump Power", function(v)
    jmpAtivo = v
    if v then
        reg("Jump ON")
        task.spawn(function()
            while jmpAtivo and Z.ALIVE do
                if LP.Character then
                    local hum = LP.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.JumpPower = jmpValor end
                end
                task.wait(0.1)
            end
        end)
    else
        reg("Jump OFF")
        if LP.Character then
            local hum = LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = 50 end
        end
    end
end, Color3.fromRGB(60, 90, 60))

local infJump = false
btT(cM, "🦘 Infinite Jump", function(v) infJump = v reg("Inf Jump " .. (v and "ON" or "OFF")) end, Color3.fromRGB(60, 90, 60))

Z.track(U.JumpRequest:Connect(function()
    if Z.ALIVE and infJump and LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

local flyAtivo = false
local flyBV = nil
local flyBG = nil
btT(cM, "🕊️ Fly", function(v)
    flyAtivo = v
    if v then
        reg("Fly ON")
        if LP.Character then
            local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                flyBV = Instance.new("BodyVelocity", hrp)
                flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                flyBV.Velocity = Vector3.zero
                flyBG = Instance.new("BodyGyro", hrp)
                flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                flyBG.P = 1000
                task.spawn(function()
                    while flyAtivo and Z.ALIVE do
                        if not hrp or not hrp.Parent or not flyBV or not flyBG then break end
                        local cam = workspace.CurrentCamera.CFrame
                        local move = Vector3.zero
                        if U:IsKeyDown(Enum.KeyCode.W) then move = move + cam.LookVector end
                        if U:IsKeyDown(Enum.KeyCode.S) then move = move - cam.LookVector end
                        if U:IsKeyDown(Enum.KeyCode.A) then move = move - cam.RightVector end
                        if U:IsKeyDown(Enum.KeyCode.D) then move = move + cam.RightVector end
                        if U:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
                        if U:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
                        if move.Magnitude > 0 then move = move.Unit * 80 end
                        flyBV.Velocity = move
                        flyBG.CFrame = cam
                        R.Heartbeat:Wait()
                    end
                    if flyBV then flyBV:Destroy() end
                    if flyBG then flyBG:Destroy() end
                end)
            end
        end
    else
        reg("Fly OFF")
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
    end
end, Color3.fromRGB(90, 90, 140))

-- Descarregar: para os loops de movimento e devolve os valores padrão do personagem
Z.onUnload(function()
    local wasNc, wasSpd, wasJmp = ncA, spdAtivo, jmpAtivo
    ncA, spdAtivo, jmpAtivo, infJump, flyAtivo = false, false, false, false, false
    if flyBV then pcall(function() flyBV:Destroy() end) flyBV = nil end
    if flyBG then pcall(function() flyBG:Destroy() end) flyBG = nil end
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and wasSpd then pcall(function() hum.WalkSpeed = 16 end) end
    if hum and wasJmp then pcall(function() hum.JumpPower = 50 end) end
    if wasNc then
        for _, o in ipairs(char:GetDescendants()) do
            if o:IsA("BasePart") then pcall(function() o.CanCollide = true end) end
        end
    end
end)

-- =======================================================
-- 8. COMBATE
-- =======================================================
do
    local tg2, sl, dd = Z.tg2, Z.sl, Z.dd
    local clamp = Z.clamp
    local espGui = Z.espGui

    local cA1 = card("AIMBOT", sec["COMBATE"], Color3.fromRGB(220, 220, 220))
    local cA2 = card("AIMBOT — AJUSTES", sec["COMBATE"], Color3.fromRGB(220, 220, 220))
    local cA3 = card("AIMBOT — FILTROS", sec["COMBATE"], Color3.fromRGB(220, 220, 220))
    local cA4 = card("SILENT AIM E AÇÕES", sec["COMBATE"], Color3.fromRGB(220, 220, 220))

    local A = {
        on = false, mode = 1, fov = 150, smooth = 5, part = 1, prio = 1, sticky = true,
        predict = false, predStrength = 0.12, maxDist = 600, team = false, wall = true,
        ff = true, drawFov = true, silent = false, silentDist = 400, mouse = false,
        fovColor = 4, target = nil, targetPlayer = nil, lastSel = 0,
    }

    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.IgnoreWater = true

    -- Raio da camera ate a parte; ignora partes transparentes ou sem colisao.
    local function blocked(part, char)
        local cam = workspace.CurrentCamera
        local origin = cam.CFrame.Position
        local ign = {}
        if LP.Character then ign[#ign + 1] = LP.Character end
        ign[#ign + 1] = char
        for _ = 1, 5 do
            rp.FilterDescendantsInstances = ign
            local r = workspace:Raycast(origin, part.Position - origin, rp)
            if not r then return false end
            local inst = r.Instance
            if inst.Transparency >= 0.9 or not inst.CanCollide then
                ign[#ign + 1] = inst
            else
                return true
            end
        end
        return true
    end

    local function isEnemy(p)
        if p == LP then return false end
        if A.team and p.Team ~= nil and p.Team == LP.Team then return false end
        return true
    end

    local function aliveChar(p)
        local c = p.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return nil end
        if A.ff and c:FindFirstChildOfClass("ForceField") then return nil end
        return c, hum
    end

    local function candidates(char)
        local out = {}
        local head = char:FindFirstChild("Head")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or hrp
        if A.part == 1 then
            out[1] = head or hrp
        elseif A.part == 2 then
            if head then out[#out + 1] = head end
            if torso then out[#out + 1] = torso end
            if hrp and hrp ~= torso then out[#out + 1] = hrp end
        elseif A.part == 3 then
            out[1] = torso
        else
            out[1] = hrp
        end
        return out
    end

    local function selectTarget()
        local cam = workspace.CurrentCamera
        if not cam then return nil, nil end
        local vp = cam.ViewportSize
        local center = Vector2.new(vp.X / 2, vp.Y / 2)
        local camPos = cam.CFrame.Position
        local best, bestPlayer, bestScore = nil, nil, math.huge
        for _, p in ipairs(P:GetPlayers()) do
            if isEnemy(p) then
                local char, hum = aliveChar(p)
                if char then
                    local sticky = A.sticky and p == A.targetPlayer
                    local limit = sticky and (A.fov * 1.4) or A.fov
                    for _, part in ipairs(candidates(char)) do
                        local dist = (part.Position - camPos).Magnitude
                        if dist <= A.maxDist then
                            local sp, on = cam:WorldToViewportPoint(part.Position)
                            if on then
                                local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                                if d <= limit and (not A.wall or not blocked(part, char)) then
                                    local score = d
                                    if A.prio == 2 then score = dist elseif A.prio == 3 then score = hum.Health end
                                    if sticky then score = score - 1e6 end
                                    if score < bestScore then
                                        bestScore, best, bestPlayer = score, part, p
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return best, bestPlayer
    end

    -- Circulo de FOV e rotulo do alvo (GUI comum, funciona no mobile sem Drawing)
    local circle = Instance.new("Frame", espGui)
    circle.AnchorPoint = Vector2.new(0.5, 0.5)
    circle.Position = UDim2.new(0.5, 0, 0.5, 0)
    circle.BackgroundTransparency = 1
    circle.Visible = false
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    local cStroke = Instance.new("UIStroke", circle)
    cStroke.Thickness = 1.5
    cStroke.Transparency = 0.35
    local tlabel = Instance.new("TextLabel", espGui)
    tlabel.AnchorPoint = Vector2.new(0.5, 0)
    tlabel.Size = UDim2.new(0, 220, 0, 16)
    tlabel.BackgroundTransparency = 1
    tlabel.Font = Enum.Font.GothamBold
    tlabel.TextSize = 12
    tlabel.TextStrokeTransparency = 0.4
    tlabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    tlabel.Visible = false

    local function holding()
        if A.mode == 1 then return true end
        if A.mode == 2 then return U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
        return U:IsKeyDown(Enum.KeyCode.Q)
    end

    local mouseObj = nil
    local function aimStep(dt)
        local cam = workspace.CurrentCamera
        circle.Visible = A.on and A.drawFov
        if circle.Visible then
            circle.Size = UDim2.fromOffset(A.fov * 2, A.fov * 2)
            cStroke.Color = Z.COLORS[A.fovColor].c
        end

        if A.mouse and cam then
            pcall(function()
                mouseObj = mouseObj or LP:GetMouse()
                if mouseObj and mouseObj.Hit then
                    local cp = cam.CFrame.Position
                    cam.CFrame = CFrame.new(cp, mouseObj.Hit.Position)
                end
            end)
        end

        if not A.on or not cam then
            A.target, A.targetPlayer = nil, nil
            tlabel.Visible = false
            return
        end

        local now = tick()
        if now - A.lastSel >= 0.033 then
            A.lastSel = now
            local ok, part, plr = pcall(selectTarget)
            if ok then A.target, A.targetPlayer = part, plr end
        end

        local part = A.target
        if part and part.Parent and holding() then
            local pos = part.Position
            if A.predict then pos = pos + part.AssemblyLinearVelocity * A.predStrength end
            local cp = cam.CFrame.Position
            local alpha = clamp(1 / math.max(A.smooth, 1), 0.02, 1)
            alpha = 1 - (1 - alpha) ^ (math.min(dt, 0.1) * 60)
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cp, pos), alpha)
            if A.targetPlayer then
                tlabel.Text = "🎯 " .. A.targetPlayer.Name .. " [" .. math.floor((part.Position - cp).Magnitude) .. "m]"
                tlabel.Position = UDim2.new(0.5, 0, 0.5, A.fov + 8)
                tlabel.Visible = true
            end
        else
            tlabel.Visible = false
        end
    end

    -- Prioridade logo acima da camera padrao para nao ser sobrescrito
    R:BindToRenderStep("ZeduxAim", Enum.RenderPriority.Camera.Value + 1, function(dt)
        local ok = pcall(aimStep, dt)
        if not ok then tlabel.Visible = false end
    end)
    Z.onUnload(function()
        pcall(function() R:UnbindFromRenderStep("ZeduxAim") end)
        circle:Destroy()
        tlabel:Destroy()
    end)

    -- Silent aim: so redireciona FindPartOnRay* quando ligado (hook instalado na 1a vez que for ligado)
    local function silentTarget()
        local my = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not my then return nil end
        local best, bd = nil, A.silentDist
        for _, p in ipairs(P:GetPlayers()) do
            if isEnemy(p) then
                local c = aliveChar(p)
                if c then
                    local part = candidates(c)[1]
                    if part then
                        local d = (part.Position - my.Position).Magnitude
                        if d < bd then bd, best = d, part end
                    end
                end
            end
        end
        return best
    end

    local hooked = false
    local function ensureHook()
        if hooked then return end
        if not (hookmetamethod and getnamecallmethod) then
            reg("❌ Silent Aim: executor sem hookmetamethod")
            return
        end
        hooked = true
        local old
        old = hookmetamethod(game, "__namecall", function(self, ...)
            if Z.ALIVE and A.silent then
                local method = getnamecallmethod()
                if method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" then
                    local args = table.pack(...)
                    local ray = args[1]
                    if typeof(ray) == "Ray" then
                        local part = silentTarget()
                        if part then
                            args[1] = Ray.new(ray.Origin, (part.Position - ray.Origin).Unit * ray.Direction.Magnitude)
                            return old(self, table.unpack(args, 1, args.n))
                        end
                    end
                end
            end
            return old(self, ...)
        end)
    end

    tg2(cA1, "🎯 Aimbot", "aim_on", false, function(v) A.on = v end)
    dd(cA1, "🕹 Modo", "aim_mode", {"Sempre ligado", "Segurar botão direito", "Segurar tecla Q"}, 1, function(i) A.mode = i end)
    tg2(cA1, "🖱️ Aim no mouse (camera segue o cursor)", "aim_mouse", false, function(v) A.mouse = v end)
    tg2(cA1, "⭕ Desenhar círculo de FOV", "aim_drawfov", true, function(v) A.drawFov = v end)
    dd(cA1, "🎨 Cor do círculo", "aim_fovcolor", Z.COLORNAMES, 4, function(i) A.fovColor = i end)

    sl(cA2, "📏 FOV (pixels)", "aim_fov", 20, 600, 150, 5, function(v) A.fov = v end)
    sl(cA2, "⚡ Suavidade (1 = trava)", "aim_smooth", 1, 30, 5, 0.5, function(v) A.smooth = v end, function(v) return v .. "x" end)
    dd(cA2, "🎯 Parte", "aim_part", {"Cabeça", "Automático (mais perto da mira)", "Tronco", "HumanoidRootPart"}, 1, function(i) A.part = i end)
    dd(cA2, "📌 Prioridade", "aim_prio", {"Mais perto da mira", "Mais perto de mim", "Menor vida"}, 1, function(i) A.prio = i end)
    tg2(cA2, "🔒 Travar no alvo atual", "aim_sticky", true, function(v) A.sticky = v end)
    tg2(cA2, "🧭 Prever movimento", "aim_predict", false, function(v) A.predict = v end)
    sl(cA2, "🧭 Força da previsão (segundos)", "aim_predstr", 0, 0.5, 0.12, 0.01, function(v) A.predStrength = v end)
    sl(cA2, "📏 Distância máxima", "aim_maxd", 50, 2000, 600, 50, function(v) A.maxDist = v end, function(v) return v .. "m" end)

    tg2(cA3, "👥 Ignorar meu time", "aim_team", false, function(v) A.team = v end)
    tg2(cA3, "🧱 Não mirar atrás de parede", "aim_wall", true, function(v) A.wall = v end)
    tg2(cA3, "🛡 Ignorar ForceField", "aim_ff", true, function(v) A.ff = v end)

    tg2(cA4, "🎯 Silent Aim (FindPartOnRay)", "aim_silent", false, function(v)
        A.silent = v
        if v then ensureHook() end
    end)
    sl(cA4, "📏 Silent: distância máxima", "aim_silentd", 50, 1000, 400, 25, function(v) A.silentDist = v end, function(v) return v .. "m" end)

    bt(cA4, "👁️ Mirar Alvo", function()
        local p = S.sel
        if not p or not p.Character then reg("❌ Sem alvo") return end
        if not isEnemy(p) then reg("❌ Alvo inválido ou do seu time") return end
        local part = candidates(p.Character)[1]
        if not part then reg("❌ Alvo sem parte válida") return end
        if A.wall and blocked(part, p.Character) then reg("❌ Alvo atrás da parede!") return end
        reg("Mira → " .. p.Name)
        task.spawn(function()
            local ini = tick()
            while Z.ALIVE and tick() - ini < 0.3 and part.Parent do
                local cam = workspace.CurrentCamera
                cam.CFrame = CFrame.new(cam.CFrame.Position, part.Position)
                R.RenderStepped:Wait()
            end
        end)
    end, true)

    bt(cA4, "🔫 Atirar no Alvo", function()
        if not S.sel then return end
        pcall(function()
            local vu = game:GetService("VirtualUser")
            local cam = workspace.CurrentCamera
            vu:CaptureController()
            vu:ClickButton1(Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2))
        end)
        reg("Atirou: " .. S.sel.Name)
    end, true)
end

-- =======================================================
-- 9. TELECINESE
-- =======================================================
local cT = card("TELECINESE", sec["TELECINESE"], Color3.fromRGB(200, 200, 200))
local function acC()
    if not LP.Character then return nil end
    local m = LP.Character:FindFirstChild("HumanoidRootPart")
    if not m then return nil end
    local c1, d1 = nil, 400
    for _, o in ipairs(workspace:GetChildren()) do
        if o:IsA("Model") then
            local v = false
            for _, d in ipairs(o:GetChildren()) do
                if d:IsA("VehicleSeat") or d:IsA("Seat") then v = true break end
            end
            if v then
                local pr = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")
                if pr then
                    local di = (pr.Position - m.Position).Magnitude
                    if di < d1 then d1 = di c1 = pr end
                end
            end
        end
    end
    return c1
end

bt(cT, "🚗 Puxar Carro", function()
    local c = acC() if not c then reg("Sem carro") return end
    local m = c:FindFirstAncestorOfClass("Model") if not m then return end
    local p = {}
    for _, d in ipairs(m:GetDescendants()) do
        if d:IsA("BasePart") and not d.Anchored then
            table.insert(p, d)
            if #p >= 6 then break end
        end
    end
    for _, x in ipairs(p) do
        local b = Instance.new("BodyVelocity", x)
        b.Name = "ZEDUX_Pux" b.MaxForce = Vector3.new(5e5, 5e5, 5e5) b.Velocity = Vector3.zero
    end
    reg("Puxar Carro")
    task.spawn(function()
        local i = tick()
        while tick() - i < 4 do
            if not LP.Character then break end
            local mh = LP.Character:FindFirstChild("HumanoidRootPart") if not mh then break end
            local a = mh.Position + mh.CFrame.LookVector * 10 + Vector3.new(0, 3, 0)
            for _, x in ipairs(p) do
                if x and x.Parent then
                    local b = x:FindFirstChild("ZEDUX_Pux")
                    if b then
                        local d = a - x.Position
                        if d.Magnitude < 8 then b.Velocity = Vector3.zero else b.Velocity = d.Unit * math.min(150, d.Magnitude * 3) end
                    end
                end
            end
            R.Heartbeat:Wait()
        end
        for _, x in ipairs(p) do
            if x and x.Parent then
                local b = x:FindFirstChild("ZEDUX_Pux") if b then b:Destroy() end
            end
        end
    end)
end)

bt(cT, "💥 Lançar Carro", function()
    if not S.sel or not S.sel.Character then reg("Sem alvo") return end
    local c = acC() if not c then reg("Sem carro") return end
    local m = c:FindFirstAncestorOfClass("Model") if not m then return end
    local p = {}
    for _, d in ipairs(m:GetDescendants()) do
        if d:IsA("BasePart") and not d.Anchored then
            table.insert(p, d) if #p >= 8 then break end
        end
    end
    for _, x in ipairs(p) do
        local b = Instance.new("BodyVelocity", x)
        b.Name = "ZEDUX_Lan" b.MaxForce = Vector3.new(1e8, 1e8, 1e8) b.Velocity = Vector3.zero
    end
    reg("Lançar Carro")
    task.spawn(function()
        local i = tick()
        while tick() - i < 6 do
            if not S.sel or not S.sel.Character then break end
            local th = S.sel.Character:FindFirstChild("HumanoidRootPart") if not th then break end
            local ap = th.Position + Vector3.new(0, 3, 0)
            for _, x in ipairs(p) do
                if x and x.Parent then
                    local b = x:FindFirstChild("ZEDUX_Lan")
                    if b then
                        local d = ap - x.Position
                        if d.Magnitude < 5 then b.Velocity = Vector3.zero else b.Velocity = d.Unit * math.min(3000, d.Magnitude * 15) end
                    end
                end
            end
            R.Heartbeat:Wait()
        end
        for _, x in ipairs(p) do
            if x and x.Parent then
                local b = x:FindFirstChild("ZEDUX_Lan") if b then b:Destroy() end
            end
        end
    end)
end)

bt(cT, "🔓 Soltar Tudo", function()
    for _, c in ipairs(workspace:GetChildren()) do
        if c:IsA("Model") then
            for _, d in ipairs(c:GetDescendants()) do
                if d:IsA("BasePart") then
                    local bv1 = d:FindFirstChild("ZEDUX_Pux")
                    local bv2 = d:FindFirstChild("ZEDUX_Lan")
                    if bv1 then bv1:Destroy() end
                    if bv2 then bv2:Destroy() end
                end
            end
        end
    end
    reg("Soltar Tudo")
end)

-- =======================================================
-- 10. TROLL (FLING DE BLOCOS RESTAURADO)
-- =======================================================
local cTr = card("TROLL", sec["TROLL"], Color3.fromRGB(200, 200, 200))
local flingAtivo = false
local flingBlocos = {}

bt(cTr, "💥 Fling de Blocos", function()
    if not S.sel or not S.sel.Character then reg("Sem alvo") return end
    local h = S.sel.Character:FindFirstChild("HumanoidRootPart") if not h then reg("Alvo sem HRP") return end
    reg("💥 Fling de Blocos → " .. S.sel.Name)
    flingAtivo = true 
    flingBlocos = {}
    
    task.spawn(function()
        local pasta = Instance.new("Folder", workspace)
        pasta.Name = "ZEDUX_FlingBlocks"
        
        for i = 1, 25 do
            if not flingAtivo then break end
            local bloco = Instance.new("Part")
            bloco.Size = Vector3.new(6, 6, 6)
            bloco.Position = h.Position + Vector3.new(math.random(-10, 10), math.random(5, 15), math.random(-10, 10))
            bloco.Anchored = false
            bloco.CanCollide = true
            bloco.Transparency = 0.3
            bloco.Material = Enum.Material.Neon
            bloco.Color = Color3.fromRGB(200, 200, 200)
            bloco.Parent = pasta
            
            pcall(function() bloco:SetNetworkOwner(LP) end)
            table.insert(flingBlocos, bloco)
            
            local bv = Instance.new("BodyVelocity", bloco)
            bv.Name = "ZEDUX_Fling"
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = Vector3.zero
            
            local bav = Instance.new("BodyAngularVelocity", bloco)
            bav.AngularVelocity = Vector3.new(math.random(-500, 500), math.random(-500, 500), math.random(-500, 500))
            bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        end
        
        local ini = tick()
        while tick() - ini < 5 and flingAtivo do
            if not S.sel or not S.sel.Character then break end
            local th = S.sel.Character:FindFirstChild("HumanoidRootPart") if not th then break end
            for _, b in ipairs(flingBlocos) do
                if b and b.Parent then
                    local bv = b:FindFirstChild("ZEDUX_Fling")
                    if bv then
                        local dir = (th.Position - b.Position)
                        if dir.Magnitude > 3 then 
                            bv.Velocity = dir.Unit * 2500 
                        else 
                            bv.Velocity = Vector3.new(math.random(-2500, 2500), math.random(-2500, 2500), math.random(-2500, 2500)) 
                        end
                    end
                end
            end
            R.Heartbeat:Wait()
        end
        
        pasta:Destroy()
        flingAtivo = false 
        flingBlocos = {} 
        reg("✅ Fling finalizado")
    end)
end, true)

bt(cTr, "🛑 Parar Fling", function()
    flingAtivo = false
    for _, b in ipairs(flingBlocos) do
        if b and b.Parent then
            local bv = b:FindFirstChild("ZEDUX_Fling") if bv then bv:Destroy() end
        end
    end
    flingBlocos = {} reg("🛑 Fling PARADO")
end, true)

btT(cTr, "🍑 Sarrada", function(v)
    if not v then return end
    if not S.sel or not S.sel.Character then reg("Sem alvo") return end
    if not LP.Character then return end
    reg("Sarrada ON → " .. S.sel.Name)
    local t = 0
    task.spawn(function()
        while t < 8 do
            if not LP.Character or not S.sel.Character then break end
            local m = LP.Character:FindFirstChild("HumanoidRootPart")
            local h = S.sel.Character:FindFirstChild("HumanoidRootPart")
            if not m or not h then break end
            t = t + 0.08
            local bf = h.CFrame * CFrame.new(0, 0, 2.2)
            local em = math.sin(t * 12) * 0.9
            local sb2 = math.abs(math.sin(t * 12)) * 0.3
            m.CFrame = bf * CFrame.new(0, sb2, em)
            m.Velocity = Vector3.zero
            R.Heartbeat:Wait()
        end
    end)
end, Color3.fromRGB(120, 50, 80))

bt(cTr, "🔥 Matar Alvo", function()
    if not S.sel or not S.sel.Character then reg("Sem alvo") return end
    local hum = S.sel.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 reg("Matou: " .. S.sel.Name) end
end, true)

bt(cTr, "🌪️ Puxar TUDO (Físico)", function()
    if not LP.Character then return end
    local myHrp = LP.Character:FindFirstChild("HumanoidRootPart") if not myHrp then return end
    local objetos = {} local maxObjetos = 80
    local function isPlayerPart(part)
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= LP and p.Character and part:IsDescendantOf(p.Character) then return true end
        end
        return false
    end
    for _, obj in ipairs(workspace:GetChildren()) do
        if #objetos >= maxObjetos then break end
        if obj:IsA("Model") then
            local isVehicle = false
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("VehicleSeat") or child:IsA("Seat") then isVehicle = true break end
            end
            if isVehicle then
                for _, part in ipairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") and not part.Anchored then
                        table.insert(objetos, part) if #objetos >= maxObjetos then break end
                    end
                end
            end
        end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if #objetos >= maxObjetos then break end
        if obj:IsA("BasePart") and not obj.Anchored and not isPlayerPart(obj) then
            local volume = obj.Size.X * obj.Size.Y * obj.Size.Z
            if volume > 1 then table.insert(objetos, obj) end
        end
    end
    if #objetos == 0 then reg("❌ Nenhum objeto válido encontrado.") return end
    reg("🌪️ Puxando " .. #objetos .. " objetos...")
    task.spawn(function()
        local bodyVelocities = {} local connection
        for _, obj in ipairs(objetos) do
            pcall(function()
                obj:SetNetworkOwner(LP)
                local bv = Instance.new("BodyVelocity", obj)
                bv.Name = "ZEDUX_SuperPull" bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge) bv.Velocity = Vector3.zero bv.P = 1250
                table.insert(bodyVelocities, {obj = obj, bv = bv})
            end)
        end
        local inicio = tick()
        connection = R.Heartbeat:Connect(function()
            if tick() - inicio > 4 or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then
                connection:Disconnect() return
            end
            local hrpAtual = LP.Character.HumanoidRootPart
            local alvoPos = hrpAtual.Position + hrpAtual.CFrame.LookVector * 5 + Vector3.new(0, 3, 0)
            for _, item in ipairs(bodyVelocities) do
                if item.obj and item.obj.Parent and item.bv and item.bv.Parent then
                    local dist = (alvoPos - item.obj.Position).Magnitude
                    if dist < 8 then item.bv.Velocity = Vector3.zero else item.bv.Velocity = (alvoPos - item.obj.Position).Unit * math.min(250, dist * 5) end
                end
            end
        end)
        task.wait(4) if connection then connection:Disconnect() end
        for _, item in ipairs(bodyVelocities) do
            if item.bv and item.bv.Parent then item.bv:Destroy() end
        end
        reg("✅ Puxada finalizada.")
    end)
end, true)

local lagAtivo = false
local pastaDeLag = nil
local pastaLagAlvo = nil

bt(cTr, "🌐 Lag no Alvo (Selecionado)", function()
    if not S.sel or not S.sel.Character then reg("❌ Selecione um jogador!") return end
    local alvo = S.sel
    local hrpAlvo = alvo.Character:FindFirstChild("HumanoidRootPart") if not hrpAlvo then reg("❌ Alvo sem HRP") return end
    reg("🌐 Enviando Lag para: " .. alvo.Name)
    lagAtivo = true
    if not pastaLagAlvo then pastaLagAlvo = Instance.new("Folder", workspace) pastaLagAlvo.Name = "ZEDUX_TargetLag" end
    task.spawn(function()
        local total = 200
        for i = 1, total do
            if not lagAtivo or not alvo.Character then break end
            local b = Instance.new("Part") b.Size = Vector3.new(4, 4, 4) b.Transparency = 1 b.CanCollide = false b.Anchored = false
            b.Position = hrpAlvo.Position + Vector3.new(math.random(-15, 15), math.random(5, 15), math.random(-15, 15)) b.Parent = pastaLagAlvo
            pcall(function()
                b:SetNetworkOwner(alvo)
                local bv = Instance.new("BodyVelocity", b) bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge) bv.Velocity = Vector3.new(math.random(-1000, 1000), math.random(-1000, 1000), math.random(-1000, 1000))
            end)
            task.wait(0.02)
        end
        reg("✅ Lag no alvo enviado!")
    end)
end, true)

bt(cTr, "💀 Lag Server Inteiro", function()
    reg("💀 Iniciando Lag no SERVIDOR...")
    lagAtivo = true
    if pastaDeLag then pastaDeLag:Destroy() end
    pastaDeLag = Instance.new("Folder", workspace) pastaDeLag.Name = "ZEDUX_ServerLag"
    task.spawn(function()
        local total = 500
        for i = 1, total do
            if not lagAtivo then break end
            local b = Instance.new("Part") b.Size = Vector3.new(10, 10, 10) b.Transparency = 1 b.CanCollide = false b.Anchored = false
            b.Position = Vector3.new(math.random(-5000, 5000), 5000, math.random(-5000, 5000)) b.Parent = pastaDeLag
            pcall(function()
                local players = P:GetPlayers()
                local randomPlayer = players[math.random(1, #players)]
                if randomPlayer and randomPlayer.Character then b:SetNetworkOwner(randomPlayer) end
                local bv = Instance.new("BodyVelocity", b) bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge) bv.Velocity = Vector3.new(math.random(-5000, 5000), math.random(-5000, 5000), math.random(-5000, 5000))
            end)
            if i % 10 == 0 then task.wait(0.05) end
        end
        reg("💀 Servidor lagado!")
    end)
end, true)

bt(cTr, "🛑 Parar Lag / Limpar", function()
    lagAtivo = false reg("🛑 Limpando lag...")
    if pastaLagAlvo then pastaLagAlvo:Destroy() pastaLagAlvo = nil end
    if pastaDeLag then pastaDeLag:Destroy() pastaDeLag = nil end
    reg("✅ Limpeza concluída.")
end, true)

local iyFlingAtivo = false
local iyFlingConnection = nil

btT(cTr, "🌀 Fling IY (Girar e Arremessar)", function(v)
    iyFlingAtivo = v
    if v then
        reg("🌀 IY Fling ATIVADO! Encoste em alguém.")
        if not LP.Character then return end
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart") if not hrp then return end
        local spin = Instance.new("BodyAngularVelocity", hrp) spin.Name = "ZEDUX_IYSpin" spin.AngularVelocity = Vector3.new(0, 1000, 0) spin.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        iyFlingConnection = R.Heartbeat:Connect(function()
            if not iyFlingAtivo or not LP.Character then return end
            local meuHrp = LP.Character:FindFirstChild("HumanoidRootPart") if not meuHrp then return end
            for _, p in ipairs(P:GetPlayers()) do
                if p ~= LP and p.Character then
                    local alvoHrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if alvoHrp then
                        local dist = (meuHrp.Position - alvoHrp.Position).Magnitude
                        if dist < 8 then
                            pcall(function()
                                alvoHrp:SetNetworkOwner(LP)
                                local bv = Instance.new("BodyVelocity", alvoHrp) bv.Name = "ZEDUX_IYFling" bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge) bv.Velocity = Vector3.new(math.random(-50000, 50000), 50000, math.random(-50000, 50000))
                                task.delay(0.5, function() if bv then bv:Destroy() end end)
                            end)
                        end
                    end
                end
            end
        end)
    else
        reg("🛑 IY Fling DESATIVADO.")
        if iyFlingConnection then iyFlingConnection:Disconnect() iyFlingConnection = nil end
        if LP.Character then
            local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local spin = hrp:FindFirstChild("ZEDUX_IYSpin") if spin then spin:Destroy() end
            end
        end
    end
end, Color3.fromRGB(100, 50, 120))

-- =======================================================
-- 11. PERSONALIZAÇÃO (v8: temas Black, Silver, Aurora e outros, cor personalizada, efeitos)
-- =======================================================
do
    local tg2, sl = Z.tg2, Z.sl
    local clamp = Z.clamp
    local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end

    local cTh = card("TEMAS DO PAINEL", sec["PERSONALIZAÇÃO"], Color3.fromRGB(200, 200, 200))
    local cTc = card("COR PERSONALIZADA", sec["PERSONALIZAÇÃO"], Color3.fromRGB(200, 200, 200))
    local cTx = card("EFEITOS", sec["PERSONALIZAÇÃO"], Color3.fromRGB(200, 200, 200))

    local THEMES = {
        {n = "⚫ Black", identity = true, accent = rgb(200, 200, 200)},
        {n = "⚪ Silver", bg = rgb(26, 28, 32), panel = rgb(54, 58, 66), accent = rgb(226, 230, 238)},
        {n = "🌌 Aurora", aurora = true, bg = rgb(5, 16, 24), panel = rgb(14, 36, 46), accent = rgb(110, 255, 200)},
        {n = "🌊 Midnight", bg = rgb(4, 8, 22), panel = rgb(16, 24, 52), accent = rgb(110, 160, 255)},
        {n = "🔴 Crimson", bg = rgb(14, 3, 5), panel = rgb(40, 11, 15), accent = rgb(255, 90, 100)},
        {n = "🟢 Emerald", bg = rgb(3, 14, 8), panel = rgb(10, 36, 22), accent = rgb(80, 230, 130)},
        {n = "🟣 Purple", bg = rgb(10, 4, 20), panel = rgb(30, 15, 54), accent = rgb(190, 120, 255)},
        {n = "🟡 Gold", bg = rgb(14, 10, 2), panel = rgb(40, 29, 8), accent = rgb(255, 205, 90)},
        {n = "🩵 Ciano", bg = rgb(3, 14, 18), panel = rgb(10, 38, 46), accent = rgb(0, 220, 255)},
        {n = "🩷 Rosa", bg = rgb(20, 6, 14), panel = rgb(52, 16, 38), accent = rgb(255, 120, 200)},
    }
    local TS = {idx = 1, custom = false, r = 120, g = 200, b = 255, opacity = 0, speed = 1, rainbowStroke = false, active = false}

    local function current()
        if TS.custom then
            local a = rgb(TS.r, TS.g, TS.b)
            local k = Color3.new(0, 0, 0)
            return {n = "Custom", bg = a:Lerp(k, 0.94), panel = a:Lerp(k, 0.82), accent = a}
        end
        return THEMES[TS.idx]
    end

    -- Cinzas escuros viram o fundo do tema, cinzas medios/claros viram o destaque.
    -- Cores com matiz (verde/vermelho de status) nao sao alteradas.
    local function mapColor(c, t)
        if t.identity then return c end
        local r, g, b = c.R, c.G, c.B
        local mx, mn = math.max(r, g, b), math.min(r, g, b)
        if mx - mn > 0.04 then return c end
        local v = mx * 255
        local out
        if v <= 60 then
            out = t.bg:Lerp(t.panel, v / 60)
        elseif v <= 215 then
            out = t.panel:Lerp(t.accent, (v - 60) / 155)
        else
            out = t.accent:Lerp(Color3.new(1, 1, 1), (v - 215) / 40)
        end
        return rgb(math.floor(out.R * 255 + 0.5), math.floor(out.G * 255 + 0.5), math.floor(out.B * 255 + 0.5))
    end

    local function same(a, b)
        return math.abs(a.R - b.R) < 0.004 and math.abs(a.G - b.G) < 0.004 and math.abs(a.B - b.B) < 0.004
    end

    local P_BG = {"BackgroundColor3"}
    local P_TXT = {"BackgroundColor3", "TextColor3"}
    local P_BOX = {"BackgroundColor3", "TextColor3", "PlaceholderColor3"}
    local P_STROKE = {"Color"}
    local function propsFor(o)
        if o:IsA("TextBox") then return P_BOX end
        if o:IsA("TextLabel") or o:IsA("TextButton") then return P_TXT end
        if o:IsA("GuiObject") then return P_BG end
        if o:IsA("UIStroke") then return P_STROKE end
        return nil
    end

    local applied = setmetatable({}, {__mode = "k"})
    local skip = {[w] = true, [wStroke] = true}

    local function themeObj(o)
        if skip[o] then return end
        local props = propsFor(o)
        if not props then return end
        if o:GetAttribute("ZxNoTheme") then return end
        local rec = applied[o]
        if not rec then
            rec = {}
            applied[o] = rec
        end
        local t = TS.cur or current()
        for _, pr in ipairs(props) do
            local cur = o[pr]
            local r = rec[pr]
            if not r then
                r = {orig = cur, mapped = cur}
                rec[pr] = r
            elseif not same(cur, r.mapped) then
                r.orig = cur -- o script mudou a cor (hover, selecao): vira a nova cor original
            end
            local m = mapColor(r.orig, t)
            r.mapped = m
            if not same(cur, m) then o[pr] = m end
        end
    end

    local function sweep()
        for _, d in ipairs(w:GetDescendants()) do themeObj(d) end
        for _, d in ipairs(tc:GetDescendants()) do themeObj(d) end
        themeObj(flt)
    end

    -- Aurora: gradiente animado atras dos paineis translucidos
    local aurora = Instance.new("UIGradient")
    aurora.Enabled = false
    aurora.Rotation = 20
    aurora.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, rgb(3, 20, 34)),
        ColorSequenceKeypoint.new(0.3, rgb(6, 72, 66)),
        ColorSequenceKeypoint.new(0.55, rgb(44, 22, 96)),
        ColorSequenceKeypoint.new(0.8, rgb(6, 54, 72)),
        ColorSequenceKeypoint.new(1, rgb(3, 20, 34)),
    })
    aurora.Parent = w

    local auroraConn = nil
    local function auroraStop()
        if auroraConn then
            auroraConn:Disconnect()
            auroraConn = nil
        end
    end
    local function auroraStart()
        if auroraConn then return end
        auroraConn = Z.track(R.Heartbeat:Connect(function()
            local t = tick() * TS.speed
            aurora.Rotation = (t * 14) % 360
            aurora.Offset = Vector2.new(math.sin(t * 0.5) * 0.3, math.cos(t * 0.37) * 0.3)
            if not TS.rainbowStroke then
                wStroke.Color = rgb(110, 255, 200):Lerp(rgb(190, 120, 255), (math.sin(t * 0.8) + 1) / 2)
            end
        end))
    end

    local swatches = {}
    local function applyOpacity()
        sb.BackgroundTransparency = clamp(0.2 + TS.opacity, 0, 0.95)
        mn.BackgroundTransparency = clamp(0.4 + TS.opacity, 0, 0.95)
    end

    local function applyTheme()
        local t = current()
        TS.cur = t
        if t.aurora then
            aurora.Enabled = true
            w.BackgroundColor3 = Color3.new(1, 1, 1)
            auroraStart()
        else
            aurora.Enabled = false
            auroraStop()
            w.BackgroundColor3 = t.identity and rgb(5, 5, 5) or t.bg
            if not TS.rainbowStroke then wStroke.Color = t.identity and rgb(200, 200, 200) or t.accent end
        end
        TS.active = true
        sweep()
        if t.identity then TS.active = false end
        for i, s in ipairs(swatches) do s.Enabled = (i == TS.idx and not TS.custom) end
        applyOpacity()
    end

    task.spawn(function()
        while Z.ALIVE do
            task.wait(1.5)
            if TS.active and w.Visible then pcall(sweep) end
        end
    end)
    local function onAdded(d)
        task.defer(function()
            if TS.active then pcall(themeObj, d) end
        end)
    end
    Z.track(w.DescendantAdded:Connect(onAdded))
    Z.track(tc.DescendantAdded:Connect(onAdded))

    -- Grade de amostras
    local grid = Instance.new("Frame", cTh)
    grid.Size = UDim2.new(1, 0, 0, 0)
    grid.AutomaticSize = Enum.AutomaticSize.Y
    grid.BackgroundTransparency = 1
    grid.ZIndex = 4
    local gl = Instance.new("UIGridLayout", grid)
    gl.CellSize = UDim2.new(0.31, 0, 0, 36)
    gl.CellPadding = UDim2.new(0.03, 0, 0, 6)
    gl.SortOrder = Enum.SortOrder.LayoutOrder

    for i, t in ipairs(THEMES) do
        local b = Instance.new("TextButton", grid)
        b.LayoutOrder = i
        b.AutoButtonColor = false
        b.Text = t.n
        b.TextSize = 9
        b.Font = Enum.Font.GothamBold
        b.TextWrapped = true
        b.BackgroundColor3 = t.accent
        b.TextColor3 = t.aurora and rgb(255, 255, 255) or rgb(8, 8, 8)
        b.ZIndex = 5
        b:SetAttribute("ZxNoTheme", true)
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        if t.aurora then
            local g = Instance.new("UIGradient", b)
            g.Color = aurora.Color
            g.Rotation = 35
        end
        local st = Instance.new("UIStroke", b)
        st.Thickness = 2
        st.Color = rgb(255, 255, 255)
        st.Enabled = false
        st:SetAttribute("ZxNoTheme", true)
        swatches[i] = st
        b.MouseButton1Click:Connect(function()
            TS.idx = i
            TS.custom = false
            applyTheme()
            reg("Tema: " .. t.n)
        end)
    end

    local customApi
    customApi = tg2(cTc, "🎨 Usar cor personalizada", "theme_custom", false, function(v)
        TS.custom = v
        applyTheme()
    end)
    sl(cTc, "🔴 Vermelho", "theme_r", 0, 255, 120, 1, function(v) TS.r = v if TS.custom then applyTheme() end end)
    sl(cTc, "🟢 Verde", "theme_g", 0, 255, 200, 1, function(v) TS.g = v if TS.custom then applyTheme() end end)
    sl(cTc, "🔵 Azul", "theme_b", 0, 255, 255, 1, function(v) TS.b = v if TS.custom then applyTheme() end end)

    sl(cTx, "👻 Transparência do painel", "theme_opacity", 0, 70, 0, 1, function(v)
        TS.opacity = v / 100
        applyOpacity()
    end, function(v) return v .. "%" end)
    sl(cTx, "🌌 Velocidade da Aurora", "theme_speed", 0.2, 3, 1, 0.1, function(v) TS.speed = v end, function(v) return v .. "x" end)

    local rbConn = nil
    tg2(cTx, "🌈 Borda arco-íris", "theme_rbstroke", false, function(v)
        TS.rainbowStroke = v
        if rbConn then
            rbConn:Disconnect()
            rbConn = nil
        end
        if v then
            rbConn = Z.track(R.Heartbeat:Connect(function()
                wStroke.Color = Color3.fromHSV((tick() * 0.15) % 1, 0.8, 1)
            end))
        else
            applyTheme()
        end
    end)
    tg2(cTx, "✨ Estrelas de fundo", "fx_stars", true, function(v) starfield.Visible = v end)

    bt(cTx, "🔄 Resetar tema", function()
        customApi.set(false)
        TS.custom = false
        TS.idx = 1
        TS.opacity = 0
        applyTheme()
        reg("Tema resetado")
    end)

    applyTheme()
end

-- =======================================================
-- 12. CONFIGURAÇÕES
-- =======================================================
local cL = card("ANTI-LAG", sec["CONFIGURAÇÕES"], Color3.fromRGB(200, 200, 200))
local aA = false

btT(cL, "⚡ Anti-Lag", function(v)
    aA = v
    if v then
        reg("Anti-Lag ON")
        task.spawn(function()
            while aA and Z.ALIVE do
                for _, o in ipairs(workspace:GetDescendants()) do
                    if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Smoke") or o:IsA("Fire") or o:IsA("Sparkles") or o:IsA("Beam") then o.Enabled = false end
                    if o:IsA("BasePart") then pcall(function() o.CastShadow = false end) end
                end
                task.wait(3)
            end
        end)
    else
        reg("Anti-Lag OFF")
    end
end, Color3.fromRGB(40, 80, 40))

do
    local tg2, sl, dd = Z.tg2, Z.sl, Z.dd
    local cCfg = card("CONFIGURAÇÃO (SALVAR E CARREGAR)", sec["CONFIGURAÇÕES"], Color3.fromRGB(200, 200, 200))
    bt(cCfg, "💾 Salvar configuração", function()
        reg(Z.saveConfig() and "💾 Configuração salva" or "❌ Falha ao salvar configuração")
    end)
    bt(cCfg, "📂 Carregar configuração", function()
        reg(Z.loadConfig() and "📂 Configuração carregada" or "❌ Nenhuma configuração salva")
    end)
    bt(cCfg, "🗑️ Apagar configuração salva", function()
        pcall(function() writefile(Z.CONFIGFILE, "{}") end)
        reg("🗑️ Configuração apagada")
    end, true)
    tg2(cCfg, "💾 Salvar ao fechar", "cfg_autosave", true, function(v) Z.autosave = v end)

    local cUi = card("PAINEL", sec["CONFIGURAÇÕES"], Color3.fromRGB(200, 200, 200))
    local scale = Instance.new("UIScale", w)
    sl(cUi, "📐 Escala do painel", "ui_scale", 0.6, 1.3, 1, 0.05, function(v) scale.Scale = v end, function(v) return v .. "x" end)
    tg2(cUi, "🔔 Notificações (toasts)", "ui_toasts", true, function(v) Z.TOASTS = v end)

    local keyNames = {"RightShift", "RightControl", "Insert", "Delete", "M"}
    local menuKey = Enum.KeyCode.RightShift
    dd(cUi, "⌨️ Tecla do menu", "ui_menukey", keyNames, 1, function(_, n) menuKey = Enum.KeyCode[n] end)
    Z.track(U.InputBegan:Connect(function(input, gp)
        if gp or input.KeyCode ~= menuKey then return end
        local mostrar = not w.Visible
        w.Visible = mostrar
        flt.Visible = not mostrar
    end))
end
local cI2 = card("INTERFACE", sec["CONFIGURAÇÕES"], Color3.fromRGB(200, 200, 200))
bt(cI2, "📊 FPS", function() fL.Visible = not fL.Visible reg("FPS " .. (fL.Visible and "ON" or "OFF")) end)

local tms = {{n = "Pequeno", w = 500, h = 320}, {n = "Médio", w = 700, h = 440}, {n = "Grande", w = 1000, h = 600}}
local tI = 2
bt(cI2, "📐 Tamanho", function()
    tI = tI % 3 + 1
    local t = tms[tI]
    T:Create(w, TweenInfo.new(0.2), {Size = UDim2.new(0, t.w, 0, t.h)}):Play()
    reg("Tam: " .. t.n)
end)

bt(cI2, "📌 Centralizar", function()
    local vp = workspace.CurrentCamera.ViewportSize
    T:Create(w, TweenInfo.new(0.2), {Position = UDim2.new(0, vp.X / 2 - w.Size.X.Offset / 2, 0, vp.Y / 2 - w.Size.Y.Offset / 2)}):Play()
    reg("Central")
end)

Z.tg2(cI2, "💡 Fullbright", "fullbright", false, Z.setFullbright)
Z.tg2(cI2, "🚫 Anti-AFK", "antiafk", false, Z.setAntiAfk)

bt(cI2, "🔄 Rejoin", function()
    reg("Rejoin")
    pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LP) end)
end)

bt(cI2, "🌐 Server Hop", function()
    reg("Server Hop")
    pcall(function()
        local r = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        local d = game:GetService("HttpService"):JSONDecode(r)
        if d and d.data then
            for _, srv in ipairs(d.data) do
                if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, srv.id, LP)
                    return
                end
            end
        end
    end)
end)

local cc = Instance.new("Frame", sec["CONFIGURAÇÕES"])
cc.Size = UDim2.new(1, 0, 0, 60)
cc.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
cc.ZIndex = 4
Instance.new("UICorner", cc).CornerRadius = UDim.new(0, 10)

local cT2 = Instance.new("TextLabel", cc)
cT2.Size = UDim2.new(1, 0, 0, 20)
cT2.Position = UDim2.new(0, 0, 0, 12)
cT2.BackgroundTransparency = 1
cT2.Text = "✦ ZEDUX HUB ✦"
cT2.TextColor3 = Color3.fromRGB(255, 255, 255)
cT2.Font = Enum.Font.GothamBold
cT2.TextSize = 14
cT2.ZIndex = 5

local cN = Instance.new("TextLabel", cc)
cN.Size = UDim2.new(1, 0, 0, 22)
cN.Position = UDim2.new(0, 0, 0, 32)
cN.BackgroundTransparency = 1
cN.Text = "by ZEDUX"
cN.TextColor3 = Color3.fromRGB(200, 200, 200)
cN.Font = Enum.Font.GothamBold
cN.TextSize = 12
cN.ZIndex = 5

bt(cI2, "🗑️ Fechar", function()
    reg("🚪 Painel FECHADO por " .. LP.Name)
    task.wait(0.1)
    Z.Unload()
end)

-- =======================================================
-- 13. REGISTROS (LOGS)
-- =======================================================
if AD then
local c5 = card("REGISTRO", sec["REGISTROS"], Color3.fromRGB(200, 200, 200))
local tL = Instance.new("TextLabel", c5)
tL.Size = UDim2.new(1, 0, 0, 14)
tL.BackgroundTransparency = 1
tL.Text = "Total: 0"
tL.TextColor3 = Color3.fromRGB(150, 150, 150)
tL.TextSize = 10
tL.Font = Enum.Font.Gotham
tL.TextXAlignment = Enum.TextXAlignment.Left
tL.ZIndex = 5

local sL2 = Instance.new("ScrollingFrame", c5)
sL2.Size = UDim2.new(1, 0, 0, 160)
sL2.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
sL2.ScrollBarThickness = 4
sL2.AutomaticCanvasSize = Enum.AutomaticSize.Y
sL2.ZIndex = 4
Instance.new("UICorner", sL2).CornerRadius = UDim.new(0, 6)
Instance.new("UIListLayout", sL2).Padding = UDim.new(0, 3)

local uT = -1
local function upL()
    if #lg == uT then return end
    uT = #lg
    for _, c in ipairs(sL2:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    for i = #lg, 1, -1 do
        local L = lg[i]
        local f = Instance.new("Frame", sL2)
        f.Size = UDim2.new(1, -2, 0, 22)
        f.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        f.ZIndex = 5
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 5)
        
        local l1 = Instance.new("TextLabel", f)
        l1.Size = UDim2.new(0, 120, 1, 0)
        l1.Position = UDim2.new(0, 4, 0, 0)
        l1.BackgroundTransparency = 1
        l1.Text = L.h
        l1.TextColor3 = Color3.fromRGB(150, 150, 150)
        l1.TextSize = 8
        l1.Font = Enum.Font.Gotham
        l1.TextXAlignment = Enum.TextXAlignment.Left
        l1.ZIndex = 6
        
        local l2 = Instance.new("TextLabel", f)
        l2.Size = UDim2.new(0, 80, 1, 0)
        l2.Position = UDim2.new(0, 128, 0, 0)
        l2.BackgroundTransparency = 1
        l2.Text = "[" .. L.j .. "]"
        l2.TextColor3 = Color3.fromRGB(200, 200, 200)
        l2.TextSize = 9
        l2.Font = Enum.Font.GothamBold
        l2.TextXAlignment = Enum.TextXAlignment.Left
        l2.ZIndex = 6
        
        local l3 = Instance.new("TextLabel", f)
        l3.Size = UDim2.new(1, -210, 1, 0)
        l3.Position = UDim2.new(0, 210, 0, 0)
        l3.BackgroundTransparency = 1
        l3.Text = L.a
        l3.TextColor3 = Color3.fromRGB(220, 220, 220)
        l3.TextSize = 9
        l3.Font = Enum.Font.Gotham
        l3.TextXAlignment = Enum.TextXAlignment.Left
        l3.ZIndex = 6
    end
    tL.Text = "Total: " .. #lg
end

reg("🟢 Painel carregado - " .. LP.Name .. " (" .. CG .. ")")
upL()
task.spawn(function()
    while tL.Parent do
        task.wait(0.5)
        pcall(upL)
    end
end)

bt(c5, "💾 Salvar Arquivo", function()
    local t = "=== LOG ZEDUX HUB ===\n" .. LP.Name .. "\n\n"
    for _, L in ipairs(lg) do t = t .. L.h .. " | [" .. L.j .. "] | " .. L.a .. "\n" end
    pcall(function() writefile(LOGFILE, t) end)
    reg("💾 Log salvo")
end)

bt(c5, "🗑️ Limpar", function()
    lg = {}
    uT = -1
    pcall(function() writefile(LOGFILE, "") end)
    reg("🗑️ Log limpo")
    upL()
end)
end

-- =======================================================
-- 14. FINALIZAÇÃO (DRAG, MINIMIZAR E REFRESH)
-- =======================================================
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    w.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

mh.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = w.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

mh.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

Z.track(U.InputChanged:Connect(function(input)
    if input == dragInput and dragging then updateDrag(input) end
end))

cB2.MouseButton1Click:Connect(function()
    reg("❌ Painel FECHADO (X) por " .. LP.Name)
    task.wait(0.1)
    Z.Unload()
end)

hB2.MouseButton1Click:Connect(function()
    reg("👁️ Painel MINIMIZADO por " .. LP.Name)
    w.Visible = false
    flt.Visible = true
end)

flt.MouseButton1Click:Connect(function()
    w.Visible = true
    flt.Visible = false
end)

mB2.MouseButton1Click:Connect(function()
    local tamAtual = w.Size.X.Offset
    local novoTam = math.max(400, tamAtual - 50)
    if novoTam == tamAtual then return end
    local proporcao = novoTam / tamAtual
    T:Create(w, TweenInfo.new(0.2), {Size = UDim2.new(0, novoTam, 0, w.Size.Y.Offset * proporcao)}):Play()
    reg("Tamanho: " .. novoTam)
end)

pB.MouseButton1Click:Connect(function()
    local tamAtual = w.Size.X.Offset
    local novoTam = math.min(1200, tamAtual + 50)
    if novoTam == tamAtual then return end
    local proporcao = novoTam / tamAtual
    T:Create(w, TweenInfo.new(0.2), {Size = UDim2.new(0, novoTam, 0, w.Size.Y.Offset * proporcao)}):Play()
    reg("Tamanho: " .. novoTam)
end)

local function rf()
    for _, c in ipairs(pl:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for _, p in ipairs(P:GetPlayers()) do
        local b = Instance.new("TextButton", pl)
        b.Size = UDim2.new(1, 0, 0, 24)
        b.BackgroundColor3 = (S.sel == p) and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(25, 25, 25)
        b.Text = "  " .. p.Name
        b.TextColor3 = (S.sel == p) and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(220, 220, 220)
        b.TextSize = 9
        b.Font = Enum.Font.GothamBold
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.AutoButtonColor = false
        b.ZIndex = 4
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
        b.MouseButton1Click:Connect(function()
            S.sel = p
            reg("Sel: " .. p.Name)
            rf()
        end)
    end
    upC()
end

Z.rf = rf
rf()
Z.track(P.PlayerAdded:Connect(rf))
Z.track(P.PlayerRemoving:Connect(function()
    task.wait(0.1)
    rf()
end))

pcall(Z.loadConfig)
sel("Main")
print("[ZEDUX HUB] Carregado com Customização Headless e Korblox!")
