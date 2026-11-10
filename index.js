--// ZEDUX HUB v7.0 - FULL SCRIPT (TEMPO DE KEY + DASHBOARD + ALL FEATURES + BLACK/SILVER + STARFIELD + FLING + CUSTOMIZAÇÃO)
local P = game:GetService("Players")
local U = game:GetService("UserInputService")
local R = game:GetService("RunService")
local T = game:GetService("TweenService")
local LP = P.LocalPlayer
local C = workspace.CurrentCamera
local S = {sel = nil}
local lg = {}
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
            KEYS_VALIDAS[l] = true
        end
    end
end)

local OID = 4197733654
local WL = {"eduardo92301"}
local ADM = {[OID] = "PROPRIETÁRIO"}
local CG = ADM[LP.UserId] or "JOGADOR"
local AD = (CG == "PROPRIETÁRIO" or CG == "ADMIN")

local isVipOuSuperior = (LP.UserId == OID)
if getgenv().LH_CARGOS and getgenv().LH_CARGOS[LP.Name] then
    local cg = getgenv().LH_CARGOS[LP.Name]
    if cg == "VIP" or cg == "MOD" or cg == "ADMIN" or cg == "PROPRIETÁRIO" then
        isVipOuSuperior = true
    end
end
for _, n in ipairs(WL) do
    if LP.Name:lower() == n:lower() then
        isVipOuSuperior = true
    end
end

-- =======================================================
-- SISTEMA DE VALIDAÇÃO DE TEMPO DA KEY
-- =======================================================
local function ChecarTempoKey(key)
    local tempoAgora = os.time()
    local chaveSalva = ""
    
    pcall(function() chaveSalva = readfile(TEMPOFILE) end)
    
    if chaveSalva ~= "" then
        local dados = string.split(chaveSalva, "|")
        if dados[1] == key then
            local expiracao = tonumber(dados[2])
            if tempoAgora < expiracao then
                return true
            end
        end
    end
    
    local segundos = 0
    if string.find(key, "ZEDUX-DIA-") then segundos = 86400 
    elseif string.find(key, "ZEDUX-SEM-") then segundos = 86400 * 7 
    elseif string.find(key, "ZEDUX-MEN-") then segundos = 86400 * 30 
    elseif string.find(key, "ZEDUX-ANO-") then segundos = 86400 * 365 
    elseif string.find(key, "ZEDUX-PERM-") then 
        pcall(function() writefile(TEMPOFILE, key .. "|" .. tostring(math.huge)) end)
        return true 
    else
        return false 
    end
    
    local expiracao = tempoAgora + segundos
    pcall(function() writefile(TEMPOFILE, key .. "|" .. tostring(expiracao)) end)
    return true
end

-- =======================================================
-- 1. INTRO (LOADER DE LOGIN) - ESTILO BLACK/SILVER
-- =======================================================
local function IniciarIntro()
    local executor = "Unknown"
    pcall(function() executor = getexecutorname() or identifyexecutor() end)
    if type(executor) == "table" then executor = executor[1] end
    
    local hwid = "Not Available"
    pcall(function() hwid = gethwid() end)
    if hwid == "Not Available" then hwid = LP.UserId .. "-" .. math.random(1000, 9999) end
    
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
    addInfoRow(280, "🎮", "Game", string.sub(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name, 1, 15))
    
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
        
        if KEYS_VALIDAS[keyDigitada] or ChecarTempoKey(keyDigitada) then
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
local WEBHOOK = "https://discord.com/api/webhooks/1559481604387246170/aAs30L9QQbfX0ZWA92jKpD6PZ_F5IOZT1424WNqaHluyZ-QuNGbbO36pVf-Fe3Ti9Fe4"
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
getgenv().LH_CARGOS[LP.Name] = "PROPRIETÁRIO"
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

for i = 1, 150 do
    local star = Instance.new("Frame", starfield)
    local size = math.random(1, 3)
    star.Size = UDim2.new(0, size, 0, size)
    star.Position = UDim2.new(math.random(), 0, math.random(), 0)
    star.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    star.BorderSizePixel = 0
    star.ZIndex = 1
    Instance.new("UICorner", star).CornerRadius = UDim.new(1, 0)

    task.spawn(function()
        while star.Parent do
            local tempoAnim = math.random(10, 30) / 10
            local transAlvo = math.random(0, 8) / 10
            T:Create(star, TweenInfo.new(tempoAnim, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = transAlvo}):Play()
            task.wait(tempoAnim)
        end
    end)
end

task.spawn(function()
    while starfield.Parent do
        T:Create(starfield, TweenInfo.new(20, Enum.EasingStyle.Linear), {Position = UDim2.new(0, 0, -0.2, 0)}):Play()
        task.wait(20)
        starfield.Position = UDim2.new(0, 0, 0, 0)
    end
end)

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
P.PlayerAdded:Connect(function() task.wait(0.1) upC() end)
P.PlayerRemoving:Connect(function() task.wait(0.1) upC() end)

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
    local tp = "info"
    local al = a:lower()
    if al:find("cargo") then tp = "ok"
    elseif al:find("on") or al:find("aprov") or al:find("aberto") or al:find("entrou") or al:find("gerada") then tp = "ok"
    elseif al:find("erro") or al:find("falh") or al:find("sem") then tp = "err"
    elseif al:find("off") or al:find("fechou") or al:find("parou") or al:find("minimizou") then tp = "warn" end
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
    
    b.MouseEnter:Connect(function() T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = cH}):Play() end)
    b.MouseLeave:Connect(function() T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = cB}):Play() end)
    
    b.MouseButton1Click:Connect(function()
        T:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(200, 200, 200), TextColor3 = Color3.fromRGB(0,0,0)}):Play()
        reg(tx)
        task.wait(0.1)
        T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = cH, TextColor3 = b.TextColor3}):Play()
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

local afkBtn = btT(quickCard, "🚫 Anti-AFK", function(v) end, Color3.fromRGB(25, 25, 25))
afkBtn.Position = UDim2.new(0, 10, 0, 35)
afkBtn.Size = UDim2.new(1, -20, 0, 32)

local fbBtn = btT(quickCard, "💡 Fullbright", function(v) end, Color3.fromRGB(25, 25, 25))
fbBtn.Position = UDim2.new(0, 10, 0, 70)
fbBtn.Size = UDim2.new(1, -20, 0, 32)

local actionCard = Instance.new("Frame", cMain)
actionCard.Size = UDim2.new(1, 0, 0, 45)
actionCard.Position = UDim2.new(0, 0, 0, 290)
actionCard.BackgroundTransparency = 1
actionCard.ZIndex = 4
Instance.new("UIListLayout", actionCard).FillDirection = Enum.FillDirection.Horizontal
Instance.new("UIListLayout", actionCard).Padding = UDim.new(0, 10)

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
local originalParts = {} -- Guarda as cores originais

local function updateCharacter()
    local char = LP.Character
    if not char then return end
    
    local head = char:FindFirstChild("Head")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    
    -- 1. Headless (Remove os olhos, boca e o mesh da cabeça)
    if head then
        for _, v in ipairs(head:GetChildren()) do
            if v:IsA("Mesh") or v:IsA("Decal") or v:IsA("SpecialMesh") or v.Name == "face" then
                if v.Name == "face" or v.Name == "Mesh" or v.Name == "SpecialMesh" then
                    v.Transparency = isHeadless and 1 or 0
                end
            end
        end
    end
    
    -- 2. Korblox (Altera a cor e textura das pernas e braços)
    if humanoid then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and (part.Name:find("Leg") or part.Name:find("Arm") or part.Name:find("Hand") or part.Name:find("Foot")) then
                if isKorblox then
                    if not originalParts[part] then
                        originalParts[part] = part.Color
                    end
                    part.Color = Color3.fromRGB(20, 20, 20) -- Cor escura do Korblox
                    part.Material = Enum.Material.SmoothPlastic
                else
                    if originalParts[part] then
                        part.Color = originalParts[part]
                    end
                end
            end
        end
    end
    
    -- 3. Remover Cabelo
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Accessory") and v.AccessoryType == Enum.AccessoryType.Hair then
            if isNoHair then
                v.Handle.Transparency = 1
            else
                v.Handle.Transparency = 0
            end
        end
    end
end

-- Recria a customização quando o jogador respawna
LP.CharacterAdded:Connect(function()
    task.wait(1.5)
    if isHeadless or isKorblox or isNoHair then
        updateCharacter()
    end
end)

-- Botão: Headless (Igual da Foto)
local btnHeadless = bt(visualCard, "HEADLESS: OFF", function()
    isHeadless = not isHeadless
    btnHeadless.Text = "HEADLESS: " .. (isHeadless and "ON" or "OFF")
    btnHeadless.BackgroundColor3 = isHeadless and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(25, 25, 25)
    updateCharacter()
    reg("Headless: " .. (isHeadless and "ON" or "OFF"))
end)
btnHeadless.Size = UDim2.new(1, 0, 0, 40)
btnHeadless.TextSize = 12

-- Botão: Korblox (Pernas e Braços)
local btnKorblox = bt(visualCard, "KORBLOX: OFF", function()
    isKorblox = not isKorblox
    btnKorblox.Text = "KORBLOX: " .. (isKorblox and "ON" or "OFF")
    btnKorblox.BackgroundColor3 = isKorblox and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(25, 25, 25)
    updateCharacter()
    reg("Korblox: " .. (isKorblox and "ON" or "OFF"))
end)
btnKorblox.Size = UDim2.new(1, 0, 0, 40)
btnKorblox.TextSize = 12

-- Botão: Sem Cabelo
local btnNoHair = bt(visualCard, "WITHOUT HAIR: OFF", function()
    isNoHair = not isNoHair
    btnNoHair.Text = "WITHOUT HAIR: " .. (isNoHair and "ON" or "OFF")
    btnNoHair.BackgroundColor3 = isNoHair and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(25, 25, 25)
    updateCharacter()
    reg("Sem Cabelo: " .. (isNoHair and "ON" or "OFF"))
end)
btnNoHair.Size = UDim2.new(1, 0, 0, 40)
btnNoHair.TextSize = 12

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

bt(cK, "🎲 Gerar Key Aleatória", function()
    local k = "ZEDUX-HUB-" .. math.random(100000, 999999)
    KEYS_VALIDAS[k] = true
    salvarKeys()
    reg("🎲 Key: " .. k)
    iK.Text = k
end, true)
end

-- =======================================================
-- 6. ESP
-- =======================================================
local cE = card("ESP", sec["ESP"], Color3.fromRGB(220, 220, 220))
local eF = Instance.new("Folder", gui)
eF.Name = "ZeduxEsp"
local eA = false
local eC = Color3.fromRGB(220, 220, 220)
local eD = 500
local eS = true
local CE = {{n = "Prata", c = Color3.fromRGB(220, 220, 220)}, {n = "Vermelho", c = Color3.fromRGB(255, 60, 60)}, {n = "Azul", c = Color3.fromRGB(60, 150, 255)}, {n = "Branco", c = Color3.fromRGB(255, 255, 255)}, {n = "Preto", c = Color3.fromRGB(50, 50, 50)}}
local cI = 1
local AL = {100, 250, 500, 1000, 5000, 999999}
local aI = 3

local function limE() for _, c in ipairs(eF:GetChildren()) do c:Destroy() end end

local function cP(p)
    if p == LP or not p.Character then return end
    if eF:FindFirstChild("P_" .. p.Name) then return end
    local h = p.Character:FindFirstChild("HumanoidRootPart")
    if not h then return end
    
    local b = Instance.new("BillboardGui", eF)
    b.Name = "P_" .. p.Name
    b.Size = UDim2.new(0, 180, 0, 40)
    b.StudsOffset = Vector3.new(0, 3.5, 0)
    b.AlwaysOnTop = true
    b.Adornee = h
    
    local n = Instance.new("TextLabel", b)
    n.Size = UDim2.new(1, 0, 0.5, 0)
    n.BackgroundTransparency = 1
    n.Text = p.Name
    n.TextColor3 = eC
    n.Font = Enum.Font.GothamBold
    n.TextSize = 13
    
    local hp = Instance.new("TextLabel", b)
    hp.Size = UDim2.new(1, 0, 0.5, 0)
    hp.Position = UDim2.new(0, 0, 0.5, 0)
    hp.BackgroundTransparency = 1
    hp.TextColor3 = Color3.fromRGB(255, 255, 255)
    hp.Font = Enum.Font.GothamBold
    hp.TextSize = 10
    
    task.spawn(function()
        while b.Parent do
            if p.Character then
                local novoH = p.Character:FindFirstChild("HumanoidRootPart")
                if novoH and novoH ~= b.Adornee then b.Adornee = novoH h = novoH end
            end
            local u = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
            if u then
                if eS and u.Health <= 0 then hp.Text = "💀" else hp.Text = "❤ " .. math.floor(u.Health) end
            else
                hp.Text = "💀"
            end
            if h and h.Parent then
                local d = math.floor((h.Position - C.CFrame.Position).Magnitude)
                if d > eD then b.Enabled = false else b.Enabled = true n.Text = p.Name .. " [" .. d .. "m]" end
            end
            R.RenderStepped:Wait()
        end
    end)
end

btT(cE, "📡 ESP Players", function(v)
    eA = v
    if v then
        limE()
        for _, p in ipairs(P:GetPlayers()) do if p ~= LP then cP(p) end end
        reg("ESP ON")
    else
        eA = false
        limE()
        reg("ESP OFF")
    end
end, Color3.fromRGB(30, 70, 50))

bt(cE, "🎨 Cor: Prata", function()
    cI = cI % #CE + 1
    eC = CE[cI].c
    reg("Cor: " .. CE[cI].n)
    if eA then
        limE()
        for _, p in ipairs(P:GetPlayers()) do if p ~= LP then cP(p) end end
    end
end, true)

bt(cE, "📏 Alcance: 500", function()
    aI = aI % #AL + 1
    eD = AL[aI]
    reg("Alcance: " .. (eD == 999999 and "∞" or tostring(eD) .. "m"))
    if eA then
        limE()
        for _, p in ipairs(P:GetPlayers()) do if p ~= LP then cP(p) end end
    end
end, true)

btT(cE, "❤ Só Vivos", function(v) eS = v reg("Só Vivos " .. (v and "ON" or "OFF")) end, Color3.fromRGB(40, 60, 50))

P.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        if eA then
            task.wait(1)
            local ex = eF:FindFirstChild("P_" .. p.Name)
            if ex then ex:Destroy() end
            cP(p)
        end
    end)
    if eA then task.wait(1) if p.Character then cP(p) end end
end)

for _, p in ipairs(P:GetPlayers()) do
    if p ~= LP then
        p.CharacterAdded:Connect(function()
            if eA then
                task.wait(1)
                local ex = eF:FindFirstChild("P_" .. p.Name)
                if ex then ex:Destroy() end
                cP(p)
            end
        end)
    end
end

LP.CharacterAdded:Connect(function()
    if eA then
        task.wait(1.5)
        limE()
        for _, p in ipairs(P:GetPlayers()) do if p ~= LP then cP(p) end end
    end
end)

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
        task.spawn(function() while ncA do task.wait(0.15) if ncA then aplN() end end end)
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
            while spdAtivo do
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
            while jmpAtivo do
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

U.JumpRequest:Connect(function()
    if infJump and LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

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
                    while flyAtivo do
                        if not hrp or not hrp.Parent then break end
                        local cam = C.CFrame
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

-- =======================================================
-- 8. COMBATE
-- =======================================================
local cCb = card("COMBATE", sec["COMBATE"], Color3.fromRGB(220, 220, 220))
local aimAtivo = false
local aimFov = 150
local aimSuave = 1
local aimPart = "Head"
local teamCheck = false
local wallCheck = true
local aimMouseAtivo = false
local silentAtivo = false

local function temParede(alvo)
    if not wallCheck then return false end
    local minhaChar = LP.Character
    local alvoChar = alvo.Character
    if not minhaChar or not alvoChar then return true end
    local origemPart = minhaChar:FindFirstChild("Head") or minhaChar:FindFirstChild("HumanoidRootPart")
    local alvoPart = alvoChar:FindFirstChild("Head") or alvoChar:FindFirstChild("HumanoidRootPart")
    if not origemPart or not alvoPart then return true end
    local origem = origemPart.Position
    local destino = alvoPart.Position
    local direcao = destino - origem
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    params.FilterDescendantsInstances = {minhaChar, alvoChar}
    local resultado = workspace:Raycast(origem, direcao, params)
    if resultado and resultado.Instance then
        local parte = resultado.Instance
        local parent = parte.Parent
        if parent and (parent == minhaChar or parent == alvoChar) then return false end
        if parte.Transparency >= 0.9 then return false end
        if parte.CanCollide == false then return false end
        if parte:IsA("Accessory") or parte:IsA("Hat") then return false end
        return true
    end
    return false
end

local function isTeamMate(alvo)
    if not teamCheck then return false end
    local meuTime = LP.Team
    local timeAlvo = alvo.Team
    if meuTime and timeAlvo and meuTime == timeAlvo then return true end
    return false
end

if hookmetamethod and getnamecallmethod then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if silentAtivo and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist") then
            local args = {...}
            local ray = args[1]
            if ray and typeof(ray) == "Ray" then
                local melhor = nil
                local menorDist = 400
                local myChar = LP.Character
                if myChar then
                    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
                    if myHrp then
                        for _, p in ipairs(P:GetPlayers()) do
                            if p ~= LP and p.Character then
                                if not isTeamMate(p) then
                                    local targetPart = p.Character:FindFirstChild(aimPart) or p.Character:FindFirstChild("HumanoidRootPart")
                                    if targetPart then
                                        local dist = (targetPart.Position - myHrp.Position).Magnitude
                                        if dist < menorDist then
                                            menorDist = dist
                                            melhor = targetPart
                                        end
                                    end
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
end

btT(cCb, "🎯 Aimbot Toggle", function(v)
    aimAtivo = v
    if v then
        reg("Aimbot ON")
        task.spawn(function()
            while aimAtivo do
                pcall(function()
                    local melhor = nil
                    local menorDist = math.huge
                    local centro = Vector2.new(C.ViewportSize.X / 2, C.ViewportSize.Y / 2)
                    for _, p in ipairs(P:GetPlayers()) do
                        if p ~= LP and p.Character then
                            if not isTeamMate(p) then
                                if not temParede(p) then
                                    local h = p.Character:FindFirstChild(aimPart) or p.Character:FindFirstChild("HumanoidRootPart")
                                    if h then
                                        local tp, ot = C:WorldToViewportPoint(h.Position)
                                        if ot then
                                            local d = (Vector2.new(tp.X, tp.Y) - centro).Magnitude
                                            if d < aimFov and d < menorDist then
                                                menorDist = d
                                                melhor = h
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if melhor then
                        local cp = C.CFrame.Position
                        local dir = (melhor.Position - cp).Unit
                        C.CFrame = C.CFrame:Lerp(CFrame.new(cp, cp + dir), 1 / math.max(aimSuave, 1))
                    end
                end)
                R.RenderStepped:Wait()
            end
        end)
    else
        reg("Aimbot OFF")
    end
end, Color3.fromRGB(90, 30, 30))

btT(cCb, "🎯 Silent Aim (Faca)", function(v) silentAtivo = v reg("Silent Aim " .. (v and "ON" or "OFF")) end, Color3.fromRGB(90, 30, 30))

bt(cCb, "👁️ Mirar Alvo", function()
    if not S.sel or not S.sel.Character then reg("Sem alvo") return end
    if isTeamMate(S.sel) then reg("❌ É do seu time!") return end
    if temParede(S.sel) then reg("❌ Alvo atrás da parede!") return end
    local alvo = S.sel.Character:FindFirstChild("Head") or S.sel.Character:FindFirstChild("HumanoidRootPart")
    if not alvo then return end
    reg("Mira → " .. S.sel.Name)
    task.spawn(function()
        local ini = tick()
        while tick() - ini < 0.3 do
            local cp = C.CFrame.Position
            local dir = (alvo.Position - cp).Unit
            C.CFrame = CFrame.new(cp, cp + dir)
            R.RenderStepped:Wait()
        end
    end)
end, true)

bt(cCb, "🔫 Atirar no Alvo", function()
    if not S.sel then return end
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton1(Vector2.new(C.ViewportSize.X / 2, C.ViewportSize.Y / 2))
    end)
    reg("Atirou: " .. S.sel.Name)
end, true)

bt(cCb, "📏 FOV: 150", function() aimFov = aimFov + 100 if aimFov > 500 then aimFov = 100 end reg("FOV: " .. aimFov) end)
bt(cCb, "🎯 Parte: Head", function() if aimPart == "Head" then aimPart = "HumanoidRootPart" elseif aimPart == "HumanoidRootPart" then aimPart = "UpperTorso" else aimPart = "Head" end reg("Parte: " .. aimPart) end)
bt(cCb, "⚡ Suavidade: 1x", function() aimSuave = aimSuave + 1 if aimSuave > 10 then aimSuave = 1 end reg("Suavidade: " .. aimSuave .. "x") end)
btT(cCb, "👥 Team Check", function(v) teamCheck = v reg("Team Check " .. (v and "ON" or "OFF")) end, Color3.fromRGB(60, 60, 90))
btT(cCb, "🧱 Wall Check", function(v) wallCheck = v reg("Wall Check " .. (v and "ON" or "OFF")) end, Color3.fromRGB(70, 50, 90))
btT(cCb, "🖱️ Aim no Mouse", function(v) aimMouseAtivo = v reg("AimMouse " .. (v and "ON" or "OFF")) end, Color3.fromRGB(90, 30, 30))

R.RenderStepped:Connect(function()
    if not aimMouseAtivo then return end
    pcall(function()
        local mouse = U:GetMouse()
        if mouse and mouse.Hit then
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dir = (mouse.Hit.Position - C.CFrame.Position).Unit
                C.CFrame = CFrame.new(C.CFrame.Position, C.CFrame.Position + dir)
            end
        end
    end)
end)

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
-- 11. PERSONALIZAÇÃO
-- =======================================================
local cPer = card("PAINEL", sec["PERSONALIZAÇÃO"], Color3.fromRGB(200, 200, 200))
local temaIdx = 1
local temas = {
    {n = "⚫ Black & Silver", bg = Color3.fromRGB(5, 5, 5), accent = Color3.fromRGB(200, 200, 200)},
    {n = "🌙 Dark Padrão", bg = Color3.fromRGB(15, 8, 25), accent = Color3.fromRGB(168, 85, 247)},
    {n = "🔴 Blood", bg = Color3.fromRGB(15, 5, 8), accent = Color3.fromRGB(220, 40, 60)},
    {n = "🟢 Matrix", bg = Color3.fromRGB(5, 15, 8), accent = Color3.fromRGB(80, 255, 120)},
    {n = "🟣 Purple", bg = Color3.fromRGB(15, 8, 20), accent = Color3.fromRGB(180, 100, 255)},
    {n = "🟡 Gold", bg = Color3.fromRGB(18, 15, 5), accent = Color3.fromRGB(255, 200, 50)},
    {n = "🩵 Cyan", bg = Color3.fromRGB(5, 15, 18), accent = Color3.fromRGB(0, 220, 255)},
    {n = "🩷 Pink", bg = Color3.fromRGB(20, 8, 15), accent = Color3.fromRGB(255, 120, 200)},
}

bt(cPer, "🎨 Trocar Tema", function()
    temaIdx = temaIdx % #temas + 1
    local t = temas[temaIdx]
    T:Create(w, TweenInfo.new(0.3), {BackgroundColor3 = t.bg}):Play()
    for _, b in pairs(mB) do pcall(function() T:Create(b, TweenInfo.new(0.3), {TextColor3 = t.accent}):Play() end) end
    reg("Tema: " .. t.n)
end)

bt(cPer, "👻 Transparência", function()
    local transAtual = w.BackgroundTransparency
    local novoTrans = transAtual + 0.1
    if novoTrans > 0.9 then novoTrans = 0 end
    T:Create(w, TweenInfo.new(0.2), {BackgroundTransparency = novoTrans}):Play()
    reg("Transparência: " .. math.floor(novoTrans * 100) .. "%")
end)

bt(cPer, "🌈 Borda Neon", function()
    pcall(function()
        if not w:FindFirstChildOfClass("UIStroke") then
            local s = Instance.new("UIStroke", w) s.Thickness = 2 s.Color = Color3.fromRGB(200, 200, 200)
        end
        local s = w:FindFirstChildOfClass("UIStroke")
        if s then s.Color = Color3.fromRGB(math.random(100, 255), math.random(100, 255), math.random(100, 255)) end
    end)
    reg("Borda Neon")
end)

btT(cPer, "💫 Efeito Arco-Íris", function(v)
    getgenv().LH_Rainbow = v
    if v then
        reg("Arco-Íris ON")
        task.spawn(function()
            local h = 0
            while getgenv().LH_Rainbow do
                h = (h + 0.01) % 1
                local cor = Color3.fromHSV(h, 0.8, 1)
                for _, b in pairs(mB) do pcall(function() b.TextColor3 = cor end) end
                R.Heartbeat:Wait()
            end
        end)
    else
        reg("Arco-Íris OFF")
    end
end, Color3.fromRGB(120, 80, 180))

bt(cPer, "🔄 Resetar Tema", function()
    local t = temas[1]
    T:Create(w, TweenInfo.new(0.3), {BackgroundColor3 = t.bg, BackgroundTransparency = 0}):Play()
    for n, b in pairs(mB) do
        local cr = CC[n] or Color3.fromRGB(150, 160, 180)
        pcall(function() T:Create(b, TweenInfo.new(0.3), {TextColor3 = cr}):Play() end)
    end
    reg("Tema resetado")
end)

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
            while aA do
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

local fbAtivo = false
btT(cI2, "💡 Fullbright", function(v)
    fbAtivo = v
    if v then
        reg("Fullbright ON")
        task.spawn(function()
            while fbAtivo do
                pcall(function()
                    local l = game:GetService("Lighting")
                    l.Brightness = 2 l.ClockTime = 14 l.FogEnd = 100000 l.GlobalShadows = false
                end)
                task.wait(2)
            end
        end)
    else
        reg("Fullbright OFF")
    end
end, Color3.fromRGB(80, 80, 50))

local antiAfk = false
btT(cI2, "🚫 Anti-AFK", function(v)
    antiAfk = v
    if v then
        reg("Anti-AFK ON")
        task.spawn(function()
            while antiAfk do
                pcall(function()
                    local vu = game:GetService("VirtualUser")
                    vu:CaptureController() vu:ClickButton2(Vector2.new())
                end)
                task.wait(60)
            end
        end)
    else
        reg("Anti-AFK OFF")
    end
end, Color3.fromRGB(60, 60, 80))

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
    gui:Destroy()
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

U.InputChanged:Connect(function(input)
    if input == dragInput and dragging then updateDrag(input) end
end)

cB2.MouseButton1Click:Connect(function()
    reg("❌ Painel FECHADO (X) por " .. LP.Name)
    task.wait(0.1)
    gui:Destroy()
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

rf()
P.PlayerAdded:Connect(rf)
P.PlayerRemoving:Connect(function()
    task.wait(0.1)
    rf()
end)

sel("Main")
print("[ZEDUX HUB] Carregado com Customização Headless e Korblox!")
