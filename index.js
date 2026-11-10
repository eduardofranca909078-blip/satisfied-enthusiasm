--// ZEDUX HUB v12.0 - FULL SCRIPT (FORMATADO E UNIFICADO)
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
local CARGOFILE = "zedux_cargos.txt"

local URL_SITE = "COLOQUE_O_LINK_DO_SEU_SITE_AQUI" 
local URL_DISCORD = "https://discord.gg/s6GSy4TuJ"
local WEBHOOK = "" 

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

getgenv().LH_CARGOS = {}
pcall(function()
    local d = readfile(CARGOFILE)
    if d and d ~= "" then
        for l in d:gmatch("[^\n]+") do
            local nome, cargo = l:match("^(.-)|(.*)$")
            if nome and cargo then
                getgenv().LH_CARGOS[nome] = cargo
            end
        end
    end
end)

getgenv().LH_CARGOS[tostring(OID)] = "PROPRIETÁRIO"
getgenv().LH_CARGOS[LP.Name] = "PROPRIETÁRIO"

local isVipOuSuperior = (LP.UserId == OID)
local cargoSalvo = getgenv().LH_CARGOS[LP.Name] or getgenv().LH_CARGOS[tostring(LP.UserId)]

if cargoSalvo and (cargoSalvo == "VIP" or cargoSalvo == "MOD" or cargoSalvo == "ADMIN" or cargoSalvo == "PROPRIETÁRIO") then
    isVipOuSuperior = true
    CG = cargoSalvo
end

for _, n in ipairs(WL) do
    if LP.Name:lower() == n:lower() then
        isVipOuSuperior = true
    end
end

local function ChecarTempoKey(key)
    local tempoAgora = os.time()
    local chaveSalva = ""
    
    pcall(function() 
        chaveSalva = readfile(TEMPOFILE) 
    end)
    
    if chaveSalva ~= "" then
        local dados = string.split(chaveSalva, "|")
        if dados[1] == key then
            local expiracao = tonumber(dados[2])
            if expiracao and tempoAgora < expiracao then
                return true
            end
        end
    end
    
    local segundos = 0
    if string.find(key, "ZEDUX-DIA-") then
        segundos = 86400
    elseif string.find(key, "ZEDUX-SEM-") then
        segundos = 86400 * 7
    elseif string.find(key, "ZEDUX-MEN-") then
        segundos = 86400 * 30
    elseif string.find(key, "ZEDUX-ANO-") then
        segundos = 86400 * 365
    elseif string.find(key, "ZEDUX-PERM-") then
        pcall(function() 
            writefile(TEMPOFILE, key .. "|" .. tostring(253402300799)) 
        end)
        return true
    else
        return false
    end
    
    pcall(function() 
        writefile(TEMPOFILE, key .. "|" .. tostring(tempoAgora + segundos)) 
    end)
    return true
end

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
            for _, l in ipairs(lote) do
                desc = desc .. "`" .. l .. "`\n"
            end
            
            local e = {
                title = "LOG", 
                description = desc, 
                color = 3447003, 
                footer = {text = os.date("%d/%m/%Y %H:%M:%S")}, 
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
            
            if WEBHOOK ~= "" then
                pcall(function()
                    game:GetService("HttpService"):RequestAsync({
                        Url = WEBHOOK, 
                        Method = "POST", 
                        Headers = {["Content-Type"] = "application/json"}, 
                        Body = game:GetService("HttpService"):JSONEncode({
                            username = "ZEDUX HUB", 
                            embeds = {e}
                        })
                    })
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
    table.insert(filaDiscord, "[" .. h .. "] " .. LP.Name .. " -> " .. a)
    processarFila()
end

pcall(function()
    local d = readfile(LOGFILE)
    if d and d ~= "" then
        for l in d:gmatch("[^\n]+") do
            local h, j, a = l:match("^(.-)|(.-)|(.*)$")
            if h and j and a then
                table.insert(lg, {h = h, j = j, a = a})
            end
        end
    end
end)

getgenv().LH_AP = {}
for _, n in ipairs(WL) do
    getgenv().LH_AP[n:lower()] = true
end

local gui = Instance.new("ScreenGui")
gui.Name = "ZeduxHubModern"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 99999
gui.Parent = game:GetService("CoreGui")

local flt = Instance.new("TextButton", gui)
flt.Size = UDim2.new(0, 50, 0, 50)
flt.Position = UDim2.new(0, 20, 0.5, -25)
flt.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
flt.Text = "Z"
flt.TextColor3 = Color3.fromRGB(255, 255, 255)
flt.TextSize = 22
flt.Visible = false
Instance.new("UICorner", flt).CornerRadius = UDim.new(0, 14)

local w = Instance.new("Frame", gui)
w.Size = UDim2.new(0, 700, 0, 440)
w.Position = UDim2.new(0.5, -350, 0.5, -220)
w.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
w.Visible = false
w.ClipsDescendants = true
Instance.new("UICorner", w).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", w).Color = Color3.fromRGB(50, 50, 60)

local sb = Instance.new("Frame", w)
sb.Size = UDim2.new(0, 160, 1, 0)
sb.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
sb.BackgroundTransparency = 0.2
sb.ZIndex = 2
Instance.new("UICorner", sb).CornerRadius = UDim.new(0, 8)

local mn = Instance.new("Frame", w)
mn.Size = UDim2.new(1, -160, 1, 0)
mn.Position = UDim2.new(0, 160, 0, 0)
mn.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
mn.BackgroundTransparency = 0.4
mn.ZIndex = 2
Instance.new("UICorner", mn).CornerRadius = UDim.new(0, 8)

local ct = Instance.new("Frame", mn)
ct.Size = UDim2.new(1, -28, 1, -70)
ct.Position = UDim2.new(0, 14, 0, 62)
ct.BackgroundTransparency = 1
ct.ZIndex = 3

local mnu = Instance.new("ScrollingFrame", sb)
mnu.Size = UDim2.new(1, -24, 1, -280)
mnu.Position = UDim2.new(0, 12, 0, 60)
mnu.BackgroundTransparency = 1
mnu.ScrollBarThickness = 3
mnu.AutomaticCanvasSize = Enum.AutomaticSize.Y
mnu.ZIndex = 3
Instance.new("UIListLayout", mnu).Padding = UDim.new(0, 5)

local CC = {
    Main = Color3.fromRGB(255,255,255), 
    MOVIMENTO = Color3.fromRGB(200,200,200), 
    ESP = Color3.fromRGB(220,220,220), 
    COMBATE = Color3.fromRGB(255,255,255), 
    TELECINESE = Color3.fromRGB(180,180,180), 
    TROLL = Color3.fromRGB(230,230,230), 
    PERSONALIZAÇÃO = Color3.fromRGB(180,180,180), 
    ["CUSTOMIZAÇÃO AVANÇADA"] = Color3.fromRGB(0,255,100), 
    CONFIGURAÇÕES = Color3.fromRGB(150,150,150), 
    ADMINISTRAÇÃO = Color3.fromRGB(255,255,255), 
    ["GERADOR DE KEYS"] = Color3.fromRGB(230,230,230), 
    REGISTROS = Color3.fromRGB(200,200,200)
}
local mB = {}
local cs = {}

local function sp(p, tx, cr)
    local h = Instance.new("Frame", p)
    h.Size = UDim2.new(1, 0, 0, 20)
    h.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", h)
    l.Size = UDim2.new(0, 80, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = tx
    l.TextColor3 = cr
    l.TextSize = 8
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
end

local function cat(n)
    local b = Instance.new("TextButton", mnu)
    b.Size = UDim2.new(1, 0, 0, 30)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    b.Text = "  >  " .. n
    b.TextColor3 = CC[n] or Color3.fromRGB(200,200,200)
    b.TextSize = 11
    b.Font = Enum.Font.GothamBold
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.AutoButtonColor = false
    b.ZIndex = 3
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    mB[n] = b
    table.insert(cs, n)
end

sp(mnu, "DASHBOARD", Color3.fromRGB(255,255,255))
cat("Main")
sp(mnu, "MOVIMENTO", Color3.fromRGB(200,200,200))
cat("MOVIMENTO")
cat("ESP")
sp(mnu, "AÇÕES", Color3.fromRGB(200,200,200))
cat("COMBATE")
cat("TELECINESE")
cat("TROLL")
sp(mnu, "CUSTOM", Color3.fromRGB(200,200,200))
cat("PERSONALIZAÇÃO")
cat("CUSTOMIZAÇÃO AVANÇADA")
sp(mnu, "SISTEMA", Color3.fromRGB(150,150,150))
cat("CONFIGURAÇÕES")

if AD then
    cat("ADMINISTRAÇÃO")
    cat("GERADOR DE KEYS")
    cat("REGISTROS")
end

local mh = Instance.new("TextLabel", mn)
mh.Size = UDim2.new(1, -180, 0, 18)
mh.Position = UDim2.new(0, 18, 0, 14)
mh.BackgroundTransparency = 1
mh.Text = "ZEDUX HUB"
mh.TextColor3 = Color3.fromRGB(255, 255, 255)
mh.TextSize = 14
mh.Font = Enum.Font.GothamBold
mh.TextXAlignment = Enum.TextXAlignment.Left

local fL = Instance.new("TextLabel", mn)
fL.Size = UDim2.new(0, 150, 0, 18)
fL.Position = UDim2.new(0, 180, 0, 14)
fL.BackgroundTransparency = 1
fL.Text = "FPS: -- | --ms"
fL.TextColor3 = Color3.fromRGB(200, 200, 200)
fL.TextSize = 12
fL.Font = Enum.Font.GothamBold

local function hB(x, tx)
    local b = Instance.new("TextButton", mn)
    b.Size = UDim2.new(0, 28, 0, 28)
    b.Position = UDim2.new(1, x, 0, 14)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    b.Text = tx
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local mB2 = hB(-170, "-")
local pB = hB(-138, "+")
local hB2 = hB(-80, "M")
local cB2 = hB(-44, "X")

local function IniciarIntro()
    local executor = "Unknown"
    pcall(function() 
        executor = getexecutorname() or identifyexecutor() 
    end)
    if type(executor) == "table" then executor = executor[1] end
    
    local hwid = "Not Available"
    pcall(function() 
        hwid = gethwid() 
    end)
    if hwid == "Not Available" then hwid = LP.UserId .. "-" .. math.random(1000, 9999) end
    
    local device = "PC"
    if U.TouchEnabled and not U.KeyboardEnabled then device = "Mobile" end
    if U.GamepadEnabled then device = "Console" end

    local introGui = Instance.new("ScreenGui")
    introGui.Name = "ZeduxLoader"
    introGui.ResetOnSpawn = false
    introGui.DisplayOrder = 999999
    introGui.Parent = game:GetService("CoreGui")

    local main = Instance.new("Frame", introGui)
    main.Size = UDim2.new(0, 700, 0, 420)
    main.Position = UDim2.new(0.5, -350, 0.5, -210)
    main.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", main).Color = Color3.fromRGB(200, 200, 200)

    local leftPanel = Instance.new("Frame", main)
    leftPanel.Size = UDim2.new(0, 240, 1, 0)
    leftPanel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Instance.new("UICorner", leftPanel).CornerRadius = UDim.new(0, 12)
    
    local avatarFrame = Instance.new("Frame", leftPanel)
    avatarFrame.Size = UDim2.new(0, 80, 0, 80)
    avatarFrame.Position = UDim2.new(0.5, -40, 0, 40)
    avatarFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    Instance.new("UICorner", avatarFrame).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", avatarFrame).Color = Color3.fromRGB(200, 200, 200)
    
    local avatar = Instance.new("ImageLabel", avatarFrame)
    avatar.Size = UDim2.new(1, -6, 1, -6)
    avatar.Position = UDim2.new(0, 3, 0, 3)
    avatar.BackgroundTransparency = 1
    avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=150&h=150"
    Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

    local nameLabel = Instance.new("TextLabel", leftPanel)
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 130)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = LP.DisplayName
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold

    local function addInfoRow(posY, labelTxt, valueTxt)
        local row = Instance.new("Frame", leftPanel)
        row.Size = UDim2.new(1, -20, 0, 22)
        row.Position = UDim2.new(0, 10, 0, posY)
        row.BackgroundTransparency = 1
        
        local l = Instance.new("TextLabel", row)
        l.Size = UDim2.new(0.4, 0, 1, 0)
        l.BackgroundTransparency = 1
        l.Text = labelTxt
        l.TextColor3 = Color3.fromRGB(150, 150, 150)
        l.TextSize = 10
        l.TextXAlignment = Enum.TextXAlignment.Left
        
        local v = Instance.new("TextLabel", row)
        v.Size = UDim2.new(0.6, 0, 1, 0)
        v.Position = UDim2.new(0.4, 0, 0, 0)
        v.BackgroundTransparency = 1
        v.Text = valueTxt
        v.TextColor3 = Color3.fromRGB(220, 220, 220)
        v.TextSize = 10
        v.TextXAlignment = Enum.TextXAlignment.Right
    end
    
    addInfoRow(160, "Executor:", executor)
    addInfoRow(185, "Device:", device)
    addInfoRow(210, "Discord:", LP.Name)
    addInfoRow(235, "HWID:", string.sub(hwid, 1, 12) .. "...")

    local rightPanel = Instance.new("Frame", main)
    rightPanel.Size = UDim2.new(1, -240, 1, 0)
    rightPanel.Position = UDim2.new(0, 240, 0, 0)
    rightPanel.BackgroundTransparency = 1
    
    local hTitle = Instance.new("TextLabel", rightPanel)
    hTitle.Size = UDim2.new(1, 0, 0, 30)
    hTitle.Position = UDim2.new(0, 0, 0, 40)
    hTitle.BackgroundTransparency = 1
    hTitle.Text = "ZEDUX HUB"
    hTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    hTitle.TextSize = 24
    hTitle.Font = Enum.Font.GothamBold
    hTitle.TextXAlignment = Enum.TextXAlignment.Center

    local keyBox = Instance.new("TextBox", rightPanel)
    keyBox.Size = UDim2.new(0.8, 0, 0, 45)
    keyBox.Position = UDim2.new(0.1, 0, 0, 150)
    keyBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.PlaceholderText = "Waiting for key..."
    keyBox.TextSize = 14
    Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)

    local redeemBtn = Instance.new("TextButton", rightPanel)
    redeemBtn.Size = UDim2.new(0.8, 0, 0, 40)
    redeemBtn.Position = UDim2.new(0.1, 0, 0, 210)
    redeemBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    redeemBtn.Text = "Redeem"
    redeemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    redeemBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", redeemBtn).CornerRadius = UDim.new(0, 8)

    local statusLog = Instance.new("TextLabel", rightPanel)
    statusLog.Size = UDim2.new(0.8, 0, 0, 20)
    statusLog.Position = UDim2.new(0.1, 0, 0, 270)
    statusLog.BackgroundTransparency = 1
    statusLog.Text = ""
    statusLog.Font = Enum.Font.Gotham

    local function fecharIntro()
        if introGui and introGui.Parent then
            introGui:Destroy()
            w.Visible = true
        end
    end

    redeemBtn.MouseButton1Click:Connect(function()
        local keyDigitada = keyBox.Text:gsub("%s+", "")
        if KEYS_VALIDAS[keyDigitada] or ChecarTempoKey(keyDigitada) then
            statusLog.TextColor3 = Color3.fromRGB(0, 200, 100)
            statusLog.Text = "Key valida! Iniciando painel..."
            task.wait(1)
            fecharIntro()
        else
            statusLog.TextColor3 = Color3.fromRGB(255, 80, 80)
            statusLog.Text = "Key invalida."
        end
    end)

    if isVipOuSuperior then
        statusLog.TextColor3 = Color3.fromRGB(0, 200, 100)
        statusLog.Text = "Autenticado via Cargo VIP."
        task.wait(2)
        fecharIntro()
    else
        task.delay(5, fecharIntro)
    end
end

IniciarIntro()

local function bt(p, tx, cb, tr)
    local b = Instance.new("TextButton", p)
    b.Size = UDim2.new(1, 0, 0, 35)
    b.BackgroundColor3 = tr and Color3.fromRGB(50, 20, 20) or Color3.fromRGB(20, 20, 25)
    b.Text = "  " .. tx
    b.TextColor3 = tr and Color3.fromRGB(220, 180, 190) or Color3.fromRGB(220, 220, 220)
    b.TextSize = 11
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.ZIndex = 4
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    
    local cH = tr and Color3.fromRGB(80, 30, 30) or Color3.fromRGB(35, 35, 45)
    local cB = b.BackgroundColor3
    
    b.MouseEnter:Connect(function() T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = cH}):Play() end)
    b.MouseLeave:Connect(function() T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = cB}):Play() end)
    b.MouseButton1Click:Connect(function()
        reg(tx)
        task.wait(0.1)
        cb()
    end)
    return b
end

local function btT(p, tx, cb, cr)
    local h = Instance.new("Frame", p)
    h.Size = UDim2.new(1, 0, 0, 35)
    h.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    h.ZIndex = 4
    Instance.new("UICorner", h).CornerRadius = UDim.new(0, 6)
    
    local l = Instance.new("TextLabel", h)
    l.Size = UDim2.new(1, -60, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = tx
    l.TextColor3 = Color3.fromRGB(220, 220, 220)
    l.TextSize = 11
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 5
    
    local trk = Instance.new("Frame", h)
    trk.Size = UDim2.new(0, 40, 0, 20)
    trk.Position = UDim2.new(1, -50, 0.5, -10)
    trk.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    trk.ZIndex = 5
    Instance.new("UICorner", trk).CornerRadius = UDim.new(1, 0)
    
    local th = Instance.new("Frame", trk)
    th.Size = UDim2.new(0, 16, 0, 16)
    th.Position = UDim2.new(0, 2, 0.5, -8)
    th.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
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
            T:Create(trk, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 255, 200)}):Play()
            T:Create(th, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Color3.fromRGB(15,15,18)}):Play()
        else
            T:Create(trk, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}):Play()
            T:Create(th, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Color3.fromRGB(150, 150, 150)}):Play()
        end
        reg(tx .. " " .. (a and "ON" or "OFF"))
        cb(a)
    end)
    return h
end

local function createSlider(parent, title, minVal, maxVal, defaultVal, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    container.ZIndex = 4
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
    
    local titleLabel = Instance.new("TextLabel", container)
    titleLabel.Size = UDim2.new(0.7, 0, 0, 15)
    titleLabel.Position = UDim2.new(0, 12, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    titleLabel.TextSize = 11
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 5
    
    local valueLabel = Instance.new("TextLabel", container)
    valueLabel.Size = UDim2.new(0.2, 0, 0, 15)
    valueLabel.Position = UDim2.new(0.8, -10, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultVal)
    valueLabel.TextColor3 = Color3.fromRGB(100, 255, 200)
    valueLabel.TextSize = 11
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 5
    
    local bar = Instance.new("Frame", container)
    bar.Size = UDim2.new(1, -24, 0, 4)
    bar.Position = UDim2.new(0, 12, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    bar.ZIndex = 5
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 255, 200)
    fill.ZIndex = 6
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame", bar)
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.ZIndex = 7
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    local function update(input)
        local relX = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = minVal + (maxVal - minVal) * relX
        val = math.floor(val)
        fill.Size = UDim2.new(relX, 0, 1, 0)
        knob.Position = UDim2.new(relX, -6, 0.5, -6)
        valueLabel.Text = tostring(val)
        if callback then callback(val) end
    end
    
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(i)
        end
    end)
    
    U.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i)
        end
    end)
    
    U.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return container
end

local function createDropdown(parent, title, opts, default, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    container.ZIndex = 4
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
    
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 6
    
    local titleL = Instance.new("TextLabel", container)
    titleL.Size = UDim2.new(0.5, 0, 1, 0)
    titleL.Position = UDim2.new(0, 12, 0, 0)
    titleL.BackgroundTransparency = 1
    titleL.Text = title
    titleL.TextColor3 = Color3.fromRGB(220, 220, 220)
    titleL.TextSize = 11
    titleL.Font = Enum.Font.GothamBold
    titleL.TextXAlignment = Enum.TextXAlignment.Left
    titleL.ZIndex = 5
    
    local curL = Instance.new("TextLabel", container)
    curL.Size = UDim2.new(0.5, -30, 1, 0)
    curL.Position = UDim2.new(0.5, 0, 0, 0)
    curL.BackgroundTransparency = 1
    curL.Text = default
    curL.TextColor3 = Color3.fromRGB(100, 255, 200)
    curL.TextSize = 11
    curL.Font = Enum.Font.GothamBold
    curL.TextXAlignment = Enum.TextXAlignment.Right
    curL.ZIndex = 5
    
    local arrow = Instance.new("TextLabel", container)
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -25, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "v"
    arrow.TextColor3 = Color3.fromRGB(150, 150, 150)
    arrow.TextSize = 10
    arrow.ZIndex = 5
    
    local list = Instance.new("ScrollingFrame", parent)
    list.Size = UDim2.new(1, 0, 0, 0)
    list.Position = UDim2.new(0, 0, 0, 38)
    list.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    list.BorderSizePixel = 0
    list.ZIndex = 10
    list.Visible = false
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.ScrollBarThickness = 2
    Instance.new("UICorner", list).CornerRadius = UDim.new(0, 6)
    Instance.new("UIListLayout", list).Padding = UDim.new(0, 2)
    
    for _, opt in ipairs(opts) do
        local ob = Instance.new("TextButton", list)
        ob.Size = UDim2.new(1, -10, 0, 26)
        ob.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        ob.Text = "  " .. opt
        ob.TextColor3 = Color3.fromRGB(220, 220, 220)
        ob.TextSize = 11
        ob.Font = Enum.Font.Gotham
        ob.TextXAlignment = Enum.TextXAlignment.Left
        ob.ZIndex = 11
        Instance.new("UICorner", ob).CornerRadius = UDim.new(0, 4)
        
        ob.MouseButton1Click:Connect(function()
            curL.Text = opt
            list.Visible = false
            arrow.Text = "v"
            if callback then callback(opt) end
        end)
    end
    
    local aberto = false
    btn.MouseButton1Click:Connect(function()
        aberto = not aberto
        list.Visible = aberto
        arrow.Text = aberto and "^" or "v"
        list.Size = UDim2.new(1, 0, 0, math.min(#opts, 5) * 28 + 4)
    end)
    return container
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
            b.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            b.TextColor3 = cr
        end
    end
    for nn, s in pairs(sec) do
        s.Visible = (nn == n)
    end
end

for n, b in pairs(mB) do
    b.MouseButton1Click:Connect(function() sel(n) end)
end

pB.MouseButton1Click:Connect(function()
    local tam = w.Size.X.Offset
    local nv = math.min(1200, tam + 50)
    if nv == tam then return end
    T:Create(w, TweenInfo.new(0.2), {Size = UDim2.new(0, nv, 0, w.Size.Y.Offset * (nv/tam))}):Play()
end)

mB2.MouseButton1Click:Connect(function()
    local tam = w.Size.X.Offset
    local nv = math.max(400, tam - 50)
    if nv == tam then return end
    T:Create(w, TweenInfo.new(0.2), {Size = UDim2.new(0, nv, 0, w.Size.Y.Offset * (nv/tam))}):Play()
end)

hB2.MouseButton1Click:Connect(function()
    w.Visible = false
    flt.Visible = true
end)

cB2.MouseButton1Click:Connect(function()
    reg("Painel FECHADO")
    gui:Destroy()
end)

flt.MouseButton1Click:Connect(function()
    w.Visible = true
    flt.Visible = false
end)

local dragging, dragInput, dragStart, startPos
mh.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = w.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mh.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

U.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        w.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (input.Position - dragStart).X, startPos.Y.Scale, startPos.Y.Offset + (input.Position - dragStart).Y)
    end
end)

local visualGui = Instance.new("ScreenGui")
visualGui.Name = "ZeduxVisuals"
visualGui.ResetOnSpawn = false
visualGui.IgnoreGuiInset = true
visualGui.DisplayOrder = 10
visualGui.Parent = game:GetService("CoreGui")

local fovCircle = Instance.new("Frame", visualGui)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false

local fovImg = Instance.new("ImageLabel", fovCircle)
fovImg.Size = UDim2.new(1, 0, 1, 0)
fovImg.BackgroundTransparency = 1
fovImg.Image = "rbxassetid://4965945816"
fovImg.ImageColor3 = Color3.fromRGB(200, 200, 200)
fovImg.ScaleType = Enum.ScaleType.Fit

local aimFov = 150
local cross = Instance.new("Frame", visualGui)
cross.AnchorPoint = Vector2.new(0.5, 0.5)
cross.Position = UDim2.new(0.5, 0, 0.5, 0)
cross.BackgroundTransparency = 1
cross.Visible = false

local function makeLine(size, pos)
    local o = Instance.new("Frame", cross)
    o.Size = size
    o.Position = pos
    o.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    o.ZIndex = 11
    local l = Instance.new("Frame", o)
    l.Size = UDim2.new(1, -2, 1, -2)
    l.Position = UDim2.new(0, 1, 0, 1)
    l.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    l.ZIndex = 12
    return l
end

local cima = makeLine(UDim2.new(0, 2, 0, 10), UDim2.new(0.5, -1, 0, -15))
local baixo = makeLine(UDim2.new(0, 2, 0, 10), UDim2.new(0.5, -1, 0, 5))
local esq = makeLine(UDim2.new(0, 10, 0, 2), UDim2.new(0, -15, 0.5, -1))
local dir = makeLine(UDim2.new(0, 10, 0, 2), UDim2.new(0, 5, 0.5, -1))

-- ABA MAIN
local cMain = Instance.new("Frame", sec["Main"])
cMain.Size = UDim2.new(1, 0, 0, 80)
cMain.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
cMain.ZIndex = 4
Instance.new("UICorner", cMain).CornerRadius = UDim.new(0, 8)

local welcome = Instance.new("TextLabel", cMain)
welcome.Size = UDim2.new(1, -20, 0, 30)
welcome.Position = UDim2.new(0, 10, 0, 10)
welcome.BackgroundTransparency = 1
welcome.Text = "Bem-vindo, " .. LP.DisplayName
welcome.TextColor3 = Color3.fromRGB(255, 255, 255)
welcome.TextSize = 16
welcome.Font = Enum.Font.GothamBold
welcome.TextXAlignment = Enum.TextXAlignment.Left

local statusTxt = Instance.new("TextLabel", cMain)
statusTxt.Size = UDim2.new(1, -20, 0, 20)
statusTxt.Position = UDim2.new(0, 10, 0, 40)
statusTxt.BackgroundTransparency = 1
statusTxt.Text = "Status: Online | Cargo: " .. CG
statusTxt.TextColor3 = Color3.fromRGB(100, 255, 200)
statusTxt.TextSize = 11
statusTxt.Font = Enum.Font.GothamBold
statusTxt.TextXAlignment = Enum.TextXAlignment.Left

-- ABA COMBATE
local cCb = Instance.new("Frame", sec["COMBATE"])
cCb.Size = UDim2.new(1, 0, 0, 0)
cCb.AutomaticSize = Enum.AutomaticSize.Y
cCb.BackgroundTransparency = 1
Instance.new("UIListLayout", cCb).Padding = UDim.new(0, 6)

local aimAtivo, aimPart, aimSuave, silentChance, silentAtivo, triggerAtivo, hitboxAtivo, hitboxTamanho, hitboxMostrar, hitboxPart, silentPart = false, "Head", 1, 100, false, false, false, 2, false, "Head", "Head"

btT(cCb, "Aimbot", function(v)
    aimAtivo = v
    if v then
        task.spawn(function()
            while aimAtivo do
                pcall(function()
                    local melhor, menorDist = nil, math.huge
                    local centro = Vector2.new(C.ViewportSize.X / 2, C.ViewportSize.Y / 2)
                    for _, p in ipairs(P:GetPlayers()) do
                        if p ~= LP and p.Character then
                            local hum = p.Character:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 then
                                local targetPart = p.Character:FindFirstChild(aimPart) or p.Character:FindFirstChild("HumanoidRootPart")
                                if targetPart then
                                    local tp, ot = C:WorldToViewportPoint(targetPart.Position)
                                    if ot then
                                        local d = (Vector2.new(tp.X, tp.Y) - centro).Magnitude
                                        if d < aimFov and d < menorDist then
                                            menorDist, melhor = d, targetPart
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if melhor then
                        local cp = C.CFrame.Position
                        C.CFrame = C.CFrame:Lerp(CFrame.new(cp, cp + (melhor.Position - cp).Unit), 1 / math.max(aimSuave, 1))
                    end
                end)
                R.RenderStepped:Wait()
            end
        end)
    end
end)

createSlider(cCb, "FOV Size", 50, 800, 150, function(valor)
    aimFov = valor
    if fovCircle.Visible then
        fovCircle.Size = UDim2.new(0, aimFov * 2.5, 0, aimFov * 2.5)
    end
end)

createSlider(cCb, "Smoothing", 1, 10, 1, function(valor) aimSuave = valor end)
createDropdown(cCb, "Lock Part", {"Head", "HumanoidRootPart", "UpperTorso", "Torso"}, "Head", function(escolha) aimPart = escolha end)

btT(cCb, "Mostrar FOV Circle", function(v)
    fovCircle.Visible = v
    if v then
        fovCircle.Size = UDim2.new(0, aimFov * 2.5, 0, aimFov * 2.5)
    end
end)

btT(cCb, "Crosshair Customizada", function(v) cross.Visible = v end)

createSlider(cCb, "Crosshair Gap", 0, 30, 15, function(valor)
    local gap = valor / 2
    cima.Parent.Position = UDim2.new(0.5, -1, 0, -gap - 10)
    baixo.Parent.Position = UDim2.new(0.5, -1, 0, gap)
    esq.Parent.Position = UDim2.new(0, -gap - 10, 0.5, -1)
    dir.Parent.Position = UDim2.new(0, gap, 0.5, -1)
end)

createSlider(cCb, "Hitbox Size", 1, 10, 2, function(valor) hitboxTamanho = valor end)
createDropdown(cCb, "Hitbox Part", {"Head", "HumanoidRootPart", "UpperTorso", "Torso"}, "Head", function(escolha) hitboxPart = escolha end)

btT(cCb, "Hitbox Expander", function(v)
    hitboxAtivo = v
    if v then
        task.spawn(function()
            while hitboxAtivo do
                for _, p in ipairs(P:GetPlayers()) do
                    if p ~= LP and p.Character then
                        local target = p.Character:FindFirstChild(hitboxPart)
                        if target then
                            target.Size = Vector3.new(hitboxTamanho, hitboxTamanho, hitboxTamanho)
                            target.Transparency = hitboxMostrar and 0.5 or 0
                            target.CanCollide = false
                        end
                    end
                end
                task.wait(0.2)
            end
        end)
    else
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= LP and p.Character then
                local target = p.Character:FindFirstChild(hitboxPart)
                if target then
                    target.Size = Vector3.new(2, 1, 1)
                    target.Transparency = 0
                    target.CanCollide = true
                end
            end
        end
    end
end)

btT(cCb, "Mostrar Hitbox", function(v) hitboxMostrar = v end)

btT(cCb, "Triggerbot", function(v)
    triggerAtivo = v
    if v then
        task.spawn(function()
            while triggerAtivo do
                pcall(function()
                    local mouse = U:GetMouse()
                    if mouse and mouse.Target and mouse.Target.Parent:FindFirstChildOfClass("Humanoid") and mouse.Target.Parent.Name ~= LP.Name then
                        local vu = game:GetService("VirtualUser")
                        vu:CaptureController()
                        vu:ClickButton1(Vector2.new(C.ViewportSize.X / 2, C.ViewportSize.Y / 2))
                    end
                end)
                task.wait(0.05)
            end
        end)
    end
end)

if hookmetamethod and getnamecallmethod then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if silentAtivo and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist") then
            local args = {...}
            local ray = args[1]
            if ray and typeof(ray) == "Ray" and math.random(1, 100) <= silentChance then
                local melhor, menorDist = nil, 400
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                    for _, p in ipairs(P:GetPlayers()) do
                        if p ~= LP and p.Character then
                            local targetPart = p.Character:FindFirstChild(silentPart)
                            if targetPart then
                                local dist = (targetPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                                if dist < menorDist then
                                    menorDist, melhor = dist, targetPart
                                end
                            end
                        end
                    end
                end
                if melhor then
                    args[1] = Ray.new(ray.Origin, (melhor.Position - ray.Origin).Unit * ray.Direction.Magnitude)
                    return oldNamecall(self, unpack(args))
                end
            end
        end
        return oldNamecall(self, ...)
    end)
end

btT(cCb, "Magic Bullet (Silent)", function(v) silentAtivo = v end)
createSlider(cCb, "Hit Chance (%)", 0, 100, 100, function(valor) silentChance = valor end)

-- ABA MOVIMENTO
local cM = Instance.new("Frame", sec["MOVIMENTO"])
cM.Size = UDim2.new(1, 0, 0, 0)
cM.AutomaticSize = Enum.AutomaticSize.Y
cM.BackgroundTransparency = 1
Instance.new("UIListLayout", cM).Padding = UDim.new(0, 6)

local spdAtivo, spdValor, flyAtivo, ncA, infJump = false, 16, false, false, false

createSlider(cM, "Walk Speed", 16, 250, 16, function(valor)
    spdValor = valor
    if LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum and spdAtivo then hum.WalkSpeed = valor end
    end
end)

btT(cM, "Ativar Speed", function(v)
    spdAtivo = v
    if LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v and spdValor or 16 end
    end
end)

btT(cM, "Fly", function(v)
    flyAtivo = v
    if v and LP.Character then
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = Instance.new("BodyVelocity", hrp)
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Velocity = Vector3.zero
            local bg = Instance.new("BodyGyro", hrp)
            bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            bg.P = 1000
            task.spawn(function()
                while flyAtivo and hrp.Parent do
                    local move = Vector3.zero
                    if U:IsKeyDown(Enum.KeyCode.W) then move = move + C.CFrame.LookVector end
                    if U:IsKeyDown(Enum.KeyCode.S) then move = move - C.CFrame.LookVector end
                    if U:IsKeyDown(Enum.KeyCode.A) then move = move - C.CFrame.RightVector end
                    if U:IsKeyDown(Enum.KeyCode.D) then move = move + C.CFrame.RightVector end
                    if U:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
                    if U:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
                    bv.Velocity = move.Magnitude > 0 and move.Unit * 80 or Vector3.zero
                    bg.CFrame = C.CFrame
                    R.Heartbeat:Wait()
                end
                bv:Destroy()
                bg:Destroy()
            end)
        end
    end
end)

btT(cM, "Noclip", function(v)
    ncA = v
    if v then
        task.spawn(function()
            while ncA do
                if LP.Character then
                    for _, o in ipairs(LP.Character:GetDescendants()) do
                        if o:IsA("BasePart") then o.CanCollide = false end
                    end
                end
                task.wait(0.2)
            end
        end)
    end
end)

btT(cM, "Infinite Jump", function(v) infJump = v end)

U.JumpRequest:Connect(function()
    if infJump and LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

bt(cM, "TP Para Alvo", function()
    if not S.sel or not S.sel.Character then reg("Sem alvo") return end
    local m = LP.Character:FindFirstChild("HumanoidRootPart")
    local h = S.sel.Character:FindFirstChild("HumanoidRootPart")
    if m and h then
        m.CFrame = h.CFrame * CFrame.new(0, 0, 3)
        m.Velocity = Vector3.zero
    end
end, true)

bt(cM, "Trazer Alvo", function()
    if not S.sel or not S.sel.Character then reg("Sem alvo") return end
    local m = LP.Character:FindFirstChild("HumanoidRootPart")
    local h = S.sel.Character:FindFirstChild("HumanoidRootPart")
    if m and h then
        h.CFrame = m.CFrame * CFrame.new(0, 0, 3)
        h.Velocity = Vector3.zero
    end
end, true)

-- ABA ESP
local cE = Instance.new("Frame", sec["ESP"])
cE.Size = UDim2.new(1, 0, 0, 0)
cE.AutomaticSize = Enum.AutomaticSize.Y
cE.BackgroundTransparency = 1
Instance.new("UIListLayout", cE).Padding = UDim.new(0, 6)

local previewFrame = Instance.new("Frame", cE)
previewFrame.Size = UDim2.new(1, 0, 0, 240)
previewFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Instance.new("UICorner", previewFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", previewFrame).Color = Color3.fromRGB(40, 40, 50)

local previewTitle = Instance.new("TextLabel", previewFrame)
previewTitle.Size = UDim2.new(1, 0, 0, 20)
previewTitle.Position = UDim2.new(0, 10, 0, 5)
previewTitle.BackgroundTransparency = 1
previewTitle.Text = "ESP PREVIEW"
previewTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
previewTitle.TextSize = 10
previewTitle.Font = Enum.Font.GothamBold
previewTitle.TextXAlignment = Enum.TextXAlignment.Left

local viewport = Instance.new("ViewportFrame", previewFrame)
viewport.Size = UDim2.new(1, -20, 1, -30)
viewport.Position = UDim2.new(0, 10, 0, 25)
viewport.BackgroundTransparency = 1
viewport.Ambient = Color3.fromRGB(150, 150, 150)
viewport.LightColor = Color3.fromRGB(255, 255, 255)

local world = Instance.new("WorldModel", viewport)
local dummy = Instance.new("Model", world)

local function createPart(name, size, pos, color)
    local p = Instance.new("Part", dummy)
    p.Name = name
    p.Size = size
    p.Position = pos
    p.Anchored = true
    p.CanCollide = false
    p.Color = color or Color3.fromRGB(255, 50, 100)
    p.Transparency = 0.5
    p.Material = Enum.Material.SmoothPlastic
    return p
end

local corCorpo = Color3.fromRGB(255, 50, 100)
local head = createPart("Head", Vector3.new(1, 1, 1), Vector3.new(0, 2.5, 0), corCorpo)
local upperTorso = createPart("UpperTorso", Vector3.new(2, 2, 1), Vector3.new(0, 1, 0), corCorpo)
local lowerTorso = createPart("LowerTorso", Vector3.new(2, 1.5, 1), Vector3.new(0, -0.75, 0), corCorpo)
local leftArm = createPart("LeftArm", Vector3.new(1, 2, 1), Vector3.new(-1.5, 1, 0), corCorpo)
local rightArm = createPart("RightArm", Vector3.new(1, 2, 1), Vector3.new(1.5, 1, 0), corCorpo)
local leftLeg = createPart("LeftLeg", Vector3.new(1, 2, 1), Vector3.new(-0.5, -2.5, 0), corCorpo)
local rightLeg = createPart("RightLeg", Vector3.new(1, 2, 1), Vector3.new(0.5, -2.5, 0), corCorpo)

local highlight = Instance.new("Highlight", dummy)
highlight.FillColor = corCorpo
highlight.FillTransparency = 0.5
highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
highlight.OutlineTransparency = 0

local function createBone(p1, p2)
    local bone = Instance.new("Part", dummy)
    bone.Anchored = true
    bone.CanCollide = false
    bone.Material = Enum.Material.Neon
    bone.Color = Color3.fromRGB(255, 255, 255)
    bone.Size = Vector3.new(0.1, (p1.Position - p2.Position).Magnitude, 0.1)
    bone.CFrame = CFrame.lookAt((p1.Position + p2.Position) / 2, p2.Position) * CFrame.Angles(math.rad(90), 0, 0)
end

createBone(head, upperTorso)
createBone(upperTorso, lowerTorso)
createBone(upperTorso, leftArm)
createBone(upperTorso, rightArm)
createBone(lowerTorso, leftLeg)
createBone(lowerTorso, rightLeg)

local cam = Instance.new("Camera", viewport)
viewport.CurrentCamera = cam

task.spawn(function()
    local angle = 0
    while viewport.Parent do
        angle = angle + 0.015
        cam.CFrame = CFrame.lookAt(Vector3.new(math.sin(angle) * 9, 0, math.cos(angle) * 9), Vector3.new(0, 0, 0))
        R.RenderStepped:Wait()
    end
end)

local eF = Instance.new("Folder", gui)
eF.Name = "ZeduxEsp"
local eA, espBox, espTracer, espHeadDot, skeletonAtivo, chinaAtivo = false, false, false, false, false, false
local skeletonConexoes = {}

local function limparSkeleton()
    for _, l in pairs(skeletonConexoes) do
        if typeof(l) == "Drawing" then l:Remove() end
    end
    skeletonConexoes = {}
end

local function limE()
    for _, c in ipairs(eF:GetChildren()) do c:Destroy() end
    limparSkeleton()
end

local function cP(p)
    if p == LP or not p.Character then return end
    if eF:FindFirstChild("P_" .. p.Name) then return end
    local h = p.Character:FindFirstChild("HumanoidRootPart")
    if not h then return end
    
    local b = Instance.new("BillboardGui", eF)
    b.Name = "P_" .. p.Name
    b.Size = UDim2.new(0, 100, 0, 100)
    b.AlwaysOnTop = true
    b.Adornee = h
    
    local box = Instance.new("Frame", b)
    box.Size = UDim2.new(1, 0, 1, 0)
    box.BackgroundTransparency = 1
    Instance.new("UIStroke", box).Color = Color3.fromRGB(0, 255, 0)
    box.Visible = espBox
    
    local dot = Instance.new("Frame", b)
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(0.5, -3, 0, -3)
    dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    dot.Visible = espHeadDot
    
    local n = Instance.new("TextLabel", b)
    n.Size = UDim2.new(1, 0, 0, 15)
    n.Position = UDim2.new(0, 0, 1, 0)
    n.BackgroundTransparency = 1
    n.Text = p.Name
    n.TextColor3 = Color3.fromRGB(255,255,255)
    n.Font = Enum.Font.GothamBold
    n.TextSize = 10
    n.TextStrokeTransparency = 0
    
    local hp = Instance.new("TextLabel", b)
    hp.Size = UDim2.new(1, 0, 0, 15)
    hp.Position = UDim2.new(0, 0, 1, 15)
    hp.BackgroundTransparency = 1
    hp.TextColor3 = Color3.fromRGB(255,255,255)
    hp.Font = Enum.Font.GothamBold
    hp.TextSize = 9
    
    local tracer = Instance.new("Frame", gui)
    tracer.Name = "Tracer_" .. p.Name
    tracer.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    tracer.BorderSizePixel = 0
    tracer.Visible = espTracer
    tracer.ZIndex = 1
    
    task.spawn(function()
        while b.Parent do
            if p.Character then
                local novoH = p.Character:FindFirstChild("HumanoidRootPart")
                if novoH and novoH ~= b.Adornee then
                    b.Adornee = novoH
                    h = novoH
                end
            end
            
            local u = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
            if u then
                hp.Text = "HP: " .. math.floor(u.Health)
            else
                hp.Text = "DEAD"
            end
            
            if h and h.Parent and espTracer then
                local vp = C:WorldToViewportPoint(h.Position)
                if vp.Z > 0 then
                    local center = Vector2.new(C.ViewportSize.X / 2, C.ViewportSize.Y)
                    local targetPos = Vector2.new(vp.X, vp.Y)
                    local dist = (center - targetPos).Magnitude
                    local angle = math.atan2(center.Y - targetPos.Y, center.X - targetPos.X)
                    tracer.Visible = true
                    tracer.Position = UDim2.new(0, targetPos.X, 0, targetPos.Y)
                    tracer.Size = UDim2.new(0, dist, 0, 1)
                    tracer.Rotation = math.deg(angle)
                else
                    tracer.Visible = false
                end
            else
                if tracer then tracer.Visible = false end
            end
            R.RenderStepped:Wait()
        end
        if tracer then tracer:Destroy() end
    end)
end

btT(cE, "ESP Players", function(v)
    eA = v
    limE()
    if v then
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= LP then cP(p) end
        end
    end
end)

btT(cE, "ESP Box", function(v)
    espBox = v
    for _, b in ipairs(eF:GetChildren()) do
        local bx = b:FindFirstChildOfClass("Frame")
        if bx then bx.Visible = v end
    end
end)

btT(cE, "ESP Tracers", function(v)
    espTracer = v
    for _, t in ipairs(gui:GetChildren()) do
        if t.Name:find("Tracer_") then t.Visible = v end
    end
end)

btT(cE, "ESP Head Dot", function(v)
    espHeadDot = v
    for _, b in ipairs(eF:GetChildren()) do
        local d = b:FindFirstChildOfClass("Frame")
        if d and d.Size == UDim2.new(0, 6, 0, 6) then
            d.Visible = v
        end
    end
end)

btT(cE, "Skeleton ESP", function(v)
    skeletonAtivo = v
    if not v then limparSkeleton() end
    if v and Drawing then
        task.spawn(function()
            while skeletonAtivo do
                for _, p in ipairs(P:GetPlayers()) do
                    if p ~= LP and p.Character then
                        local parts = {
                            UpperTorso = p.Character:FindFirstChild("UpperTorso"),
                            LowerTorso = p.Character:FindFirstChild("LowerTorso") or p.Character:FindFirstChild("Torso"),
                            Head = p.Character:FindFirstChild("Head"),
                            LeftHand = p.Character:FindFirstChild("LeftHand") or p.Character:FindFirstChild("Left Arm"),
                            RightHand = p.Character:FindFirstChild("RightHand") or p.Character:FindFirstChild("Right Arm"),
                            LeftFoot = p.Character:FindFirstChild("LeftFoot") or p.Character:FindFirstChild("Left Leg"),
                            RightFoot = p.Character:FindFirstChild("RightFoot") or p.Character:FindFirstChild("Right Leg")
                        }
                        
                        if parts.UpperTorso and parts.Head and parts.LeftHand and parts.RightHand and parts.LeftFoot and parts.RightFoot then
                            local function pos(pt)
                                local vp, vis = C:WorldToViewportPoint(pt.Position)
                                return Vector2.new(vp.X, vp.Y), vis
                            end
                            
                            local p1, v1 = pos(parts.UpperTorso)
                            local p2, v2 = pos(parts.LowerTorso)
                            local p3, v3 = pos(parts.Head)
                            local p4, v4 = pos(parts.LeftHand)
                            local p5, v5 = pos(parts.RightHand)
                            local p6, v6 = pos(parts.LeftFoot)
                            local p7, v7 = pos(parts.RightFoot)
                            
                            if v1 or v2 or v3 or v4 or v5 or v6 or v7 then
                                local function drawLine(a, b)
                                    local line = Drawing.new("Line")
                                    line.Visible = true
                                    line.Color = Color3.fromRGB(255, 255, 255)
                                    line.Thickness = 1
                                    line.From = a
                                    line.To = b
                                    table.insert(skeletonConexoes, line)
                                end
                                
                                if v1 and v2 then drawLine(p1, p2) end
                                if v1 and v3 then drawLine(p1, p3) end
                                if v1 and v4 then drawLine(p1, p4) end
                                if v1 and v5 then drawLine(p1, p5) end
                                if v2 and v6 then drawLine(p2, p6) end
                                if v2 and v7 then drawLine(p2, p7) end
                            end
                        end
                    end
                end
                task.wait(0.1)
                limparSkeleton()
            end
        end)
    end
end)

btT(cE, "China Hat", function(v)
    chinaAtivo = v
    if v then
        task.spawn(function()
            while chinaAtivo do
                for _, p in ipairs(P:GetPlayers()) do
                    if p ~= LP and p.Character then
                        local h = p.Character:FindFirstChild("Head")
                        if h and not h:FindFirstChild("ZeduxChinaHat") then
                            local hat = Instance.new("Part")
                            hat.Name = "ZeduxChinaHat"
                            hat.Size = Vector3.new(3, 1, 3)
                            hat.CanCollide = false
                            hat.Transparency = 0.3
                            hat.Color = Color3.fromRGB(255, 0, 0)
                            hat.Material = Enum.Material.Neon
                            hat.Parent = h
                            Instance.new("SpecialMesh", hat).MeshType = Enum.MeshType.Cylinder
                            local weld = Instance.new("WeldConstraint", hat)
                            weld.Part0 = h
                            weld.Part1 = hat
                            hat.CFrame = h.CFrame * CFrame.new(0, 1.2, 0)
                        end
                    end
                end
                task.wait(1)
            end
        end)
    else
        for _, p in ipairs(P:GetPlayers()) do
            if p.Character then
                local h = p.Character:FindFirstChild("Head")
                if h and h:FindFirstChild("ZeduxChinaHat") then
                    h.ZeduxChinaHat:Destroy()
                end
            end
        end
    end
end)

P.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        if eA then
            task.wait(1)
            cP(p)
        end
    end)
end)

LP.CharacterAdded:Connect(function()
    if eA then
        task.wait(1.5)
        limE()
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= LP then cP(p) end
        end
    end
end)

-- ABA TELECINESE
local cT = Instance.new("Frame", sec["TELECINESE"])
cT.Size = UDim2.new(1, 0, 0, 0)
cT.AutomaticSize = Enum.AutomaticSize.Y
cT.BackgroundTransparency = 1
Instance.new("UIListLayout", cT).Padding = UDim.new(0, 6)

local function acC()
    if not LP.Character then return nil end
    local m = LP.Character:FindFirstChild("HumanoidRootPart")
    if not m then return nil end
    local c1, d1 = nil, 400
    for _, o in ipairs(workspace:GetChildren()) do
        if o:IsA("Model") then
            local v = false
            for _, d in ipairs(o:GetChildren()) do
                if d:IsA("VehicleSeat") or d:IsA("Seat") then
                    v = true
                    break
                end
            end
            if v then
                local pr = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")
                if pr then
                    local di = (pr.Position - m.Position).Magnitude
                    if di < d1 then
                        d1 = di
                        c1 = pr
                    end
                end
            end
        end
    end
    return c1
end

bt(cT, "Puxar Carro", function()
    local c = acC()
    if not c then reg("Sem carro") return end
    local m = c:FindFirstAncestorOfClass("Model")
    if not m then return end
    local p = {}
    for _, d in ipairs(m:GetDescendants()) do
        if d:IsA("BasePart") and not d.Anchored then
            table.insert(p, d)
            if #p >= 6 then break end
        end
    end
    for _, x in ipairs(p) do
        local b = Instance.new("BodyVelocity", x)
        b.Name = "ZEDUX_Pux"
        b.MaxForce = Vector3.new(5e5, 5e5, 5e5)
        b.Velocity = Vector3.zero
    end
    task.spawn(function()
        local i = tick()
        while tick() - i < 4 do
            if not LP.Character then break end
            local mh = LP.Character:FindFirstChild("HumanoidRootPart")
            if not mh then break end
            local a = mh.Position + mh.CFrame.LookVector * 10 + Vector3.new(0, 3, 0)
            for _, x in ipairs(p) do
                if x and x.Parent then
                    local b = x:FindFirstChild("ZEDUX_Pux")
                    if b then
                        local d = a - x.Position
                        if d.Magnitude < 8 then
                            b.Velocity = Vector3.zero
                        else
                            b.Velocity = d.Unit * math.min(150, d.Magnitude * 3)
                        end
                    end
                end
            end
            R.Heartbeat:Wait()
        end
    end)
end)

bt(cT, "Lancar Carro", function()
    if not S.sel or not S.sel.Character then reg("Sem alvo") return end
    local c = acC()
    if not c then reg("Sem carro") return end
    local m = c:FindFirstAncestorOfClass("Model")
    if not m then return end
    local p = {}
    for _, d in ipairs(m:GetDescendants()) do
        if d:IsA("BasePart") and not d.Anchored then
            table.insert(p, d)
            if #p >= 8 then break end
        end
    end
    for _, x in ipairs(p) do
        local b = Instance.new("BodyVelocity", x)
        b.Name = "ZEDUX_Lan"
        b.MaxForce = Vector3.new(1e8, 1e8, 1e8)
        b.Velocity = Vector3.zero
    end
    task.spawn(function()
        local i = tick()
        while tick() - i < 6 do
            if not S.sel or not S.sel.Character then break end
            local th = S.sel.Character:FindFirstChild("HumanoidRootPart")
            if not th then break end
            local ap = th.Position + Vector3.new(0, 3, 0)
            for _, x in ipairs(p) do
                if x and x.Parent then
                    local b = x:FindFirstChild("ZEDUX_Lan")
                    if b then
                        local d = ap - x.Position
                        if d.Magnitude < 5 then
                            b.Velocity = Vector3.zero
                        else
                            b.Velocity = d.Unit * math.min(3000, d.Magnitude * 15)
                        end
                    end
                end
            end
            R.Heartbeat:Wait()
        end
    end)
end)

bt(cT, "Soltar Tudo", function()
    for _, c in ipairs(workspace:GetChildren()) do
        if c:IsA("Model") then
            for _, d in ipairs(c:GetDescendants()) do
                if d:IsA("BasePart") then
                    local b1 = d:FindFirstChild("ZEDUX_Pux")
                    local b2 = d:FindFirstChild("ZEDUX_Lan")
                    if b1 then b1:Destroy() end
                    if b2 then b2:Destroy() end
                end
            end
        end
    end
    reg("Soltar Tudo")
end)

-- ABA TROLL
local cTr = Instance.new("Frame", sec["TROLL"])
cTr.Size = UDim2.new(1, 0, 0, 0)
cTr.AutomaticSize = Enum.AutomaticSize.Y
cTr.BackgroundTransparency = 1
Instance.new("UIListLayout", cTr).Padding = UDim.new(0, 6)

bt(cTr, "Matar Todos", function()
    for _, p in ipairs(P:GetPlayers()) do
        if p ~= LP and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
        end
    end
    reg("Matou todos")
end, true)

bt(cTr, "Matar Alvo", function()
    if not S.sel or not S.sel.Character then reg("Sem alvo") return end
    local hum = S.sel.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Health = 0
        reg("Matou: " .. S.sel.Name)
    end
end, true)

local flingAtivo, flingBlocos = false, {}

bt(cTr, "Fling de Blocos", function()
    if not S.sel or not S.sel.Character then reg("Sem alvo") return end
    local h = S.sel.Character:FindFirstChild("HumanoidRootPart")
    if not h then return end
    flingAtivo = true
    flingBlocos = {}
    
    task.spawn(function()
        local pasta = Instance.new("Folder", workspace)
        pasta.Name = "ZEDUX_Fling"
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
            bv.Name = "Fling"
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = Vector3.zero
            
            local bav = Instance.new("BodyAngularVelocity", bloco)
            bav.AngularVelocity = Vector3.new(math.random(-500, 500), math.random(-500, 500), math.random(-500, 500))
            bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        end
        
        local ini = tick()
        while tick() - ini < 5 and flingAtivo do
            if not S.sel or not S.sel.Character then break end
            local th = S.sel.Character:FindFirstChild("HumanoidRootPart")
            if not th then break end
            for _, b in ipairs(flingBlocos) do
                if b and b.Parent then
                    local bv = b:FindFirstChild("Fling")
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
    end)
end, true)

bt(cTr, "Parar Fling", function()
    flingAtivo = false
    for _, b in ipairs(flingBlocos) do
        if b and b.Parent then
            local bv = b:FindFirstChild("Fling")
            if bv then bv:Destroy() end
        end
    end
    flingBlocos = {}
end, true)

btT(cTr, "Sarrada", function(v)
    if not v then return end
    if not S.sel or not S.sel.Character or not LP.Character then reg("Sem alvo") return end
    local t = 0
    task.spawn(function()
        while t < 8 do
            if not LP.Character or not S.sel.Character then break end
            local m = LP.Character:FindFirstChild("HumanoidRootPart")
            local h = S.sel.Character:FindFirstChild("HumanoidRootPart")
            if not m or not h then break end
            t = t + 0.08
            m.CFrame = h.CFrame * CFrame.new(0, math.abs(math.sin(t * 12)) * 0.3, math.sin(t * 12) * 0.9)
            m.Velocity = Vector3.zero
            R.Heartbeat:Wait()
        end
    end)
end, Color3.fromRGB(120, 50, 80))

local iyFlingAtivo = false

btT(cTr, "Fling IY", function(v)
    iyFlingAtivo = v
    if v and LP.Character then
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local spin = Instance.new("BodyAngularVelocity", hrp)
        spin.AngularVelocity = Vector3.new(0, 1000, 0)
        spin.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        task.spawn(function()
            while iyFlingAtivo do
                if not LP.Character then break end
                local meuHrp = LP.Character:FindFirstChild("HumanoidRootPart")
                if not meuHrp then break end
                for _, p in ipairs(P:GetPlayers()) do
                    if p ~= LP and p.Character then
                        local alvoHrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if alvoHrp and (meuHrp.Position - alvoHrp.Position).Magnitude < 8 then
                            pcall(function()
                                alvoHrp:SetNetworkOwner(LP)
                                local bv = Instance.new("BodyVelocity", alvoHrp)
                                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                bv.Velocity = Vector3.new(math.random(-50000, 50000), 50000, math.random(-50000, 50000))
                                task.delay(0.5, function() if bv then bv:Destroy() end end)
                            end)
                        end
                    end
                end
                R.Heartbeat:Wait()
            end
            if LP.Character then
                local h = LP.Character:FindFirstChild("HumanoidRootPart")
                if h then
                    local s = h:FindFirstChildOfClass("BodyAngularVelocity")
                    if s then s:Destroy() end
                end
            end
        end)
    end
end, Color3.fromRGB(100, 50, 120))

bt(cTr, "Puxar TUDO", function()
    if not LP.Character then return end
    local myHrp = LP.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    local objetos = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if #objetos >= 80 then break end
        if obj:IsA("BasePart") and not obj.Anchored then
            local isPlayer = false
            for _, p in ipairs(P:GetPlayers()) do
                if p ~= LP and p.Character and obj:IsDescendantOf(p.Character) then
                    isPlayer = true
                    break
                end
            end
            if not isPlayer and obj.Size.X * obj.Size.Y * obj.Size.Z > 1 then
                table.insert(objetos, obj)
            end
        end
    end
    if #objetos == 0 then reg("Nenhum objeto") return end
    task.spawn(function()
        local bvs = {}
        for _, obj in ipairs(objetos) do
            pcall(function()
                obj:SetNetworkOwner(LP)
                local bv = Instance.new("BodyVelocity", obj)
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.zero
                bv.P = 1250
                table.insert(bvs, {obj = obj, bv = bv})
            end)
        end
        local ini = tick()
        local conn = R.Heartbeat:Connect(function()
            if tick() - ini > 4 or not LP.Character then
                conn:Disconnect()
                return
            end
            local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local alvo = hrp.Position + hrp.CFrame.LookVector * 5 + Vector3.new(0, 3, 0)
            for _, item in ipairs(bvs) do
                if item.obj and item.obj.Parent and item.bv and item.bv.Parent then
                    local d = (alvo - item.obj.Position).Magnitude
                    item.bv.Velocity = d < 8 and Vector3.zero or (alvo - item.obj.Position).Unit * math.min(250, d * 5)
                end
            end
        end)
        task.wait(4)
        if conn then conn:Disconnect() end
        for _, item in ipairs(bvs) do
            if item.bv then item.bv:Destroy() end
        end
    end)
end, true)

local lagAtivo, pastaLagAlvo, pastaDeLag = false, nil, nil

bt(cTr, "Lag no Alvo", function()
    if not S.sel or not S.sel.Character then reg("Selecione um jogador") return end
    local alvo = S.sel
    local hrp = alvo.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    lagAtivo = true
    if not pastaLagAlvo then pastaLagAlvo = Instance.new("Folder", workspace) end
    task.spawn(function()
        for i = 1, 200 do
            if not lagAtivo or not alvo.Character then break end
            local b = Instance.new("Part")
            b.Size = Vector3.new(4, 4, 4)
            b.Transparency = 1
            b.CanCollide = false
            b.Anchored = false
            b.Position = hrp.Position + Vector3.new(math.random(-15, 15), math.random(5, 15), math.random(-15, 15))
            b.Parent = pastaLagAlvo
            pcall(function()
                b:SetNetworkOwner(alvo)
                local bv = Instance.new("BodyVelocity", b)
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.new(math.random(-1000, 1000), math.random(-1000, 1000), math.random(-1000, 1000))
            end)
            task.wait(0.02)
        end
    end)
end, true)

bt(cTr, "Lag Server", function()
    lagAtivo = true
    if pastaDeLag then pastaDeLag:Destroy() end
    pastaDeLag = Instance.new("Folder", workspace)
    pastaDeLag.Name = "ZEDUX_Lag"
    task.spawn(function()
        for i = 1, 500 do
            if not lagAtivo then break end
            local b = Instance.new("Part")
            b.Size = Vector3.new(10, 10, 10)
            b.Transparency = 1
            b.CanCollide = false
            b.Anchored = false
            b.Position = Vector3.new(math.random(-5000, 5000), 5000, math.random(-5000, 5000))
            b.Parent = pastaDeLag
            pcall(function()
                local players = P:GetPlayers()
                local rp = players[math.random(1, #players)]
                if rp and rp.Character then b:SetNetworkOwner(rp) end
                local bv = Instance.new("BodyVelocity", b)
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.new(math.random(-5000, 5000), math.random(-5000, 5000), math.random(-5000, 5000))
            end)
            if i % 10 == 0 then task.wait(0.05) end
        end
    end)
end, true)

bt(cTr, "Parar Lag / Limpar", function()
    lagAtivo = false
    if pastaLagAlvo then
        pastaLagAlvo:Destroy()
        pastaLagAlvo = nil
    end
    if pastaDeLag then
        pastaDeLag:Destroy()
        pastaDeLag = nil
    end
    reg("Limpeza concluida")
end, true)

-- ABA CUSTOMIZACAO AVANCADA
local cCust = Instance.new("Frame", sec["CUSTOMIZAÇÃO AVANÇADA"])
cCust.Size = UDim2.new(1, 0, 0, 0)
cCust.AutomaticSize = Enum.AutomaticSize.Y
cCust.BackgroundTransparency = 1
Instance.new("UIListLayout", cCust).Padding = UDim.new(0, 6)

local isHeadless, isKorblox, originalParts = false, false, {}

local function updateChar()
    local char = LP.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if head then
        for _, v in ipairs(head:GetChildren()) do
            if v:IsA("Decal") or v:IsA("Mesh") or v:IsA("SpecialMesh") then
                v.Transparency = isHeadless and 1 or 0
            end
        end
        head.Transparency = isHeadless and 1 or 0
    end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and (part.Name:find("Leg") or part.Name:find("Arm") or part.Name:find("Hand") or part.Name:find("Foot")) then
            if isKorblox then
                if not originalParts[part] then originalParts[part] = part.Color end
                part.Color = Color3.fromRGB(20, 20, 20)
                part.Material = Enum.Material.SmoothPlastic
            else
                if originalParts[part] then part.Color = originalParts[part] end
            end
        end
    end
end

LP.CharacterAdded:Connect(function()
    originalParts = {}
    task.wait(1)
    if isHeadless or isKorblox then updateChar() end
end)

btT(cCust, "Headless", function(v)
    isHeadless = v
    updateChar()
end)

btT(cCust, "Korblox", function(v)
    isKorblox = v
    updateChar()
end)

-- ABA CONFIGURACOES
local cConf = Instance.new("Frame", sec["CONFIGURAÇÕES"])
cConf.Size = UDim2.new(1, 0, 0, 0)
cConf.AutomaticSize = Enum.AutomaticSize.Y
cConf.BackgroundTransparency = 1
Instance.new("UIListLayout", cConf).Padding = UDim.new(0, 6)

local aA, fbAtivo, antiAfk = false, false, false

btT(cConf, "Anti-Lag", function(v)
    aA = v
    if v then
        task.spawn(function()
            while aA do
                for _, o in ipairs(workspace:GetDescendants()) do
                    if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Smoke") then o.Enabled = false end
                end
                task.wait(3)
            end
        end)
    end
end)

bt(cConf, "FPS", function() fL.Visible = not fL.Visible end)

local tms = {{n="Pequeno",w=500,h=320},{n="Medio",w=700,h=440},{n="Grande",w=1000,h=600}}
local tI = 2

bt(cConf, "Tamanho", function()
    tI = tI % 3 + 1
    local t = tms[tI]
    T:Create(w, TweenInfo.new(0.2), {Size = UDim2.new(0, t.w, 0, t.h)}):Play()
end)

bt(cConf, "Centralizar", function()
    local vp = workspace.CurrentCamera.ViewportSize
    T:Create(w, TweenInfo.new(0.2), {Position = UDim2.new(0, vp.X/2 - w.Size.X.Offset/2, 0, vp.Y/2 - w.Size.Y.Offset/2)}):Play()
end)

btT(cConf, "Fullbright", function(v)
    fbAtivo = v
    if v then
        task.spawn(function()
            while fbAtivo do
                local l = game:GetService("Lighting")
                l.Brightness = 2
                l.ClockTime = 14
                l.FogEnd = 100000
                task.wait(2)
            end
        end)
    end
end)

btT(cConf, "Anti-AFK", function(v)
    antiAfk = v
    if v then
        task.spawn(function()
            while antiAfk do
                game:GetService("VirtualUser"):CaptureController()
                game:GetService("VirtualUser"):ClickButton2(Vector2.new())
                task.wait(60)
            end
        end)
    end
end)

bt(cConf, "Rejoin", function()
    pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LP) end)
end)

bt(cConf, "Server Hop", function()
    pcall(function()
        local r = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
        local d = game:GetService("HttpService"):JSONDecode(r)
        if d and d.data then
            for _, s in ipairs(d.data) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, LP)
                    return
                end
            end
        end
    end)
end)

bt(cConf, "Fechar", function() gui:Destroy() end)

-- ABA PERSONALIZACAO
local cPer = Instance.new("Frame", sec["PERSONALIZAÇÃO"])
cPer.Size = UDim2.new(1, 0, 0, 0)
cPer.AutomaticSize = Enum.AutomaticSize.Y
cPer.BackgroundTransparency = 1
Instance.new("UIListLayout", cPer).Padding = UDim.new(0, 6)

local temaIdx = 1
local temas = {
    {n="Black",bg=Color3.fromRGB(5,5,5),accent=Color3.fromRGB(200,200,200)},
    {n="Dark",bg=Color3.fromRGB(15,8,25),accent=Color3.fromRGB(168,85,247)},
    {n="Blood",bg=Color3.fromRGB(15,5,8),accent=Color3.fromRGB(220,40,60)},
    {n="Matrix",bg=Color3.fromRGB(5,15,8),accent=Color3.fromRGB(80,255,120)},
    {n="Purple",bg=Color3.fromRGB(15,8,20),accent=Color3.fromRGB(180,100,255)},
    {n="Gold",bg=Color3.fromRGB(18,15,5),accent=Color3.fromRGB(255,200,50)}
}

bt(cPer, "Trocar Tema", function()
    temaIdx = temaIdx % #temas + 1
    local t = temas[temaIdx]
    T:Create(w, TweenInfo.new(0.3), {BackgroundColor3 = t.bg}):Play()
    for _, b in pairs(mB) do
        pcall(function() T:Create(b, TweenInfo.new(0.3), {TextColor3 = t.accent}):Play() end)
    end
end)

bt(cPer, "Transparencia", function()
    local ta = w.BackgroundTransparency
    local nt = ta + 0.1
    if nt > 0.9 then nt = 0 end
    T:Create(w, TweenInfo.new(0.2), {BackgroundTransparency = nt}):Play()
end)

bt(cPer, "Borda Neon", function()
    pcall(function()
        if not w:FindFirstChildOfClass("UIStroke") then
            Instance.new("UIStroke", w).Thickness = 2
        end
        local s = w:FindFirstChildOfClass("UIStroke")
        if s then s.Color = Color3.fromRGB(math.random(100,255), math.random(100,255), math.random(100,255)) end
    end)
end)

-- ABA ADMINISTRACAO
if AD then
    local cAdm = Instance.new("Frame", sec["ADMINISTRAÇÃO"])
    cAdm.Size = UDim2.new(1, 0, 0, 0)
    cAdm.AutomaticSize = Enum.AutomaticSize.Y
    cAdm.BackgroundTransparency = 1
    Instance.new("UIListLayout", cAdm).Padding = UDim.new(0, 6)
    
    local iA = Instance.new("TextBox", cAdm)
    iA.Size = UDim2.new(1,0,0,35)
    iA.BackgroundColor3 = Color3.fromRGB(20,20,25)
    iA.TextColor3 = Color3.fromRGB(255,255,255)
    iA.PlaceholderText = "Nick do jogador..."
    iA.PlaceholderColor3 = Color3.fromRGB(100,100,100)
    iA.TextSize = 11
    iA.Font = Enum.Font.GothamBold
    iA.ClearTextOnFocus = false
    iA.ZIndex = 5
    Instance.new("UICorner", iA).CornerRadius = UDim.new(0,6)
    
    bt(cAdm, "Aprovar Jogador", function()
        local n = iA.Text:gsub("%s+","")
        if n == "" then return end
        if not getgenv().LH_AP then getgenv().LH_AP = {} end
        getgenv().LH_AP[n:lower()] = true
        reg("Aprovado: "..n)
        iA.Text = ""
    end)
    
    bt(cAdm, "Reprovar Jogador", function()
        local n = iA.Text:gsub("%s+","")
        if n == "" then return end
        getgenv().LH_AP[n:lower()] = nil
        reg("Reprovado: "..n)
        iA.Text = ""
    end)
    
    local selCargo = Instance.new("TextLabel", cAdm)
    selCargo.Size = UDim2.new(1,0,0,25)
    selCargo.BackgroundColor3 = Color3.fromRGB(20,20,25)
    selCargo.Text = "  Nenhum selecionado"
    selCargo.TextColor3 = Color3.fromRGB(200,200,200)
    selCargo.TextSize = 11
    selCargo.Font = Enum.Font.GothamBold
    selCargo.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", selCargo).CornerRadius = UDim.new(0,6)
    
    task.spawn(function()
        while selCargo.Parent do
            if S.sel then
                selCargo.Text = "  Selecionado: "..S.sel.Name
                selCargo.TextColor3 = Color3.fromRGB(255,255,255)
            else
                selCargo.Text = "  Nenhum selecionado"
                selCargo.TextColor3 = Color3.fromRGB(200,200,200)
            end
            task.wait(0.3)
        end
    end)
    
    local function salvarCargos()
        local t = ""
        for nome, cargo in pairs(getgenv().LH_CARGOS) do
            t = t .. nome .. "|" .. cargo .. "\n"
        end
        pcall(function() writefile(CARGOFILE, t) end)
    end
    
    local function setCargo(novoCargo)
        if not S.sel then reg("Cargo: nenhum selecionado") return end
        local alvo = S.sel
        local id = tostring(alvo.UserId)
        local nome = alvo.Name
        local nomeMin = alvo.Name:lower()
        if not getgenv().LH_CARGOS then getgenv().LH_CARGOS = {} end
        getgenv().LH_CARGOS[id] = novoCargo
        getgenv().LH_CARGOS[nome] = novoCargo
        getgenv().LH_CARGOS[nomeMin] = novoCargo
        salvarCargos()
        reg("Cargo: " .. nome .. " -> " .. novoCargo)
    end
    
    local cargos = {
        {n="PROPRIETARIO",c=Color3.fromRGB(255,255,255),t="PROPRIETARIO"},
        {n="ADMIN",c=Color3.fromRGB(220,220,220),t="ADMIN"},
        {n="MOD",c=Color3.fromRGB(200,200,200),t="MOD"},
        {n="VIP",c=Color3.fromRGB(180,180,180),t="VIP"},
        {n="JOGADOR",c=Color3.fromRGB(150,150,150),t="JOGADOR"}
    }
    
    for _, cargo in ipairs(cargos) do
        local btn = Instance.new("TextButton", cAdm)
        btn.Size = UDim2.new(1,0,0,35)
        btn.BackgroundColor3 = Color3.fromRGB(20,20,25)
        btn.Text = "  "..cargo.n
        btn.TextColor3 = cargo.c
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamBold
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
        btn.MouseButton1Click:Connect(function() setCargo(cargo.t) end)
    end
end

-- ABA GERADOR DE KEYS
if AD then
    local cK = Instance.new("Frame", sec["GERADOR DE KEYS"])
    cK.Size = UDim2.new(1,0,0,0)
    cK.AutomaticSize = Enum.AutomaticSize.Y
    cK.BackgroundTransparency = 1
    Instance.new("UIListLayout", cK).Padding = UDim.new(0,6)
    
    local iK = Instance.new("TextBox", cK)
    iK.Size = UDim2.new(1,0,0,35)
    iK.BackgroundColor3 = Color3.fromRGB(20,20,25)
    iK.TextColor3 = Color3.fromRGB(255,255,255)
    iK.PlaceholderText = "Ex: ZEDUX-VIP-123"
    iK.PlaceholderColor3 = Color3.fromRGB(100,100,100)
    iK.TextSize = 11
    iK.Font = Enum.Font.GothamBold
    iK.ClearTextOnFocus = false
    Instance.new("UICorner", iK).CornerRadius = UDim.new(0,6)
    
    local function salvarKeys()
        local t = ""
        for k, _ in pairs(KEYS_VALIDAS) do t = t .. k .. "\n" end
        pcall(function() writefile(KEYFILE, t) end)
    end
    
    bt(cK, "Gerar Key", function()
        local k = iK.Text:gsub("%s+","")
        if k == "" then reg("Digite uma key") return end
        if KEYS_VALIDAS[k] then reg("Key ja existe") return end
        KEYS_VALIDAS[k] = true
        salvarKeys()
        reg("Key GERADA: "..k)
        iK.Text = ""
    end)
    
    bt(cK, "Remover Key", function()
        local k = iK.Text:gsub("%s+","")
        if k == "" then reg("Digite uma key") return end
        if not KEYS_VALIDAS[k] then reg("Key nao existe") return end
        KEYS_VALIDAS[k] = nil
        salvarKeys()
        reg("Key REMOVIDA: "..k)
        iK.Text = ""
    end)
end

-- ABA REGISTROS
if AD then
    local c5 = Instance.new("Frame", sec["REGISTROS"])
    c5.Size = UDim2.new(1,0,0,0)
    c5.AutomaticSize = Enum.AutomaticSize.Y
    c5.BackgroundTransparency = 1
    Instance.new("UIListLayout", c5).Padding = UDim.new(0,6)
    
    local tL = Instance.new("TextLabel", c5)
    tL.Size = UDim2.new(1,0,0,15)
    tL.BackgroundTransparency = 1
    tL.Text = "Total: 0"
    tL.TextColor3 = Color3.fromRGB(150,150,150)
    tL.TextSize = 11
    tL.Font = Enum.Font.Gotham
    tL.TextXAlignment = Enum.TextXAlignment.Left
    
    local sL2 = Instance.new("ScrollingFrame", c5)
    sL2.Size = UDim2.new(1,0,0,200)
    sL2.BackgroundColor3 = Color3.fromRGB(20,20,25)
    sL2.ScrollBarThickness = 4
    sL2.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UICorner", sL2).CornerRadius = UDim.new(0,6)
    Instance.new("UIListLayout", sL2).Padding = UDim.new(0,3)
    
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
            f.Size = UDim2.new(1,-2,0,25)
            f.BackgroundColor3 = Color3.fromRGB(25,25,30)
            Instance.new("UICorner", f).CornerRadius = UDim.new(0,5)
            
            local l1 = Instance.new("TextLabel", f)
            l1.Size = UDim2.new(0,120,1,0)
            l1.BackgroundTransparency = 1
            l1.Text = L.h
            l1.TextColor3 = Color3.fromRGB(150,150,150)
            l1.TextSize = 9
            l1.Font = Enum.Font.Gotham
            l1.TextXAlignment = Enum.TextXAlignment.Left
            
            local l2 = Instance.new("TextLabel", f)
            l2.Size = UDim2.new(0,80,1,0)
            l2.Position = UDim2.new(0,128,0,0)
            l2.BackgroundTransparency = 1
            l2.Text = "["..L.j.."]"
            l2.TextColor3 = Color3.fromRGB(200,200,200)
            l2.TextSize = 10
            l2.Font = Enum.Font.GothamBold
            l2.TextXAlignment = Enum.TextXAlignment.Left
            
            local l3 = Instance.new("TextLabel", f)
            l3.Size = UDim2.new(1,-210,1,0)
            l3.Position = UDim2.new(0,210,0,0)
            l3.BackgroundTransparency = 1
            l3.Text = L.a
            l3.TextColor3 = Color3.fromRGB(220,220,220)
            l3.TextSize = 10
            l3.Font = Enum.Font.Gotham
            l3.TextXAlignment = Enum.TextXAlignment.Left
        end
        tL.Text = "Total: " .. #lg
    end
    
    reg("Painel carregado - " .. LP.Name .. " (" .. CG .. ")")
    upL()
    
    task.spawn(function()
        while tL.Parent do
            task.wait(0.5)
            pcall(upL)
        end
    end)
    
    bt(c5, "Salvar Arquivo", function()
        local t = "=== LOG ===\n"..LP.Name.."\n\n"
        for _, L in ipairs(lg) do
            t = t .. L.h .. " | [" .. L.j .. "] | " .. L.a .. "\n"
        end
        pcall(function() writefile(LOGFILE, t) end)
        reg("Log salvo")
    end)
    
    bt(c5, "Limpar", function()
        lg = {}
        uT = -1
        pcall(function() writefile(LOGFILE, "") end)
        reg("Log limpo")
        upL()
    end)
end

-- LISTA DE JOGADORES (SIDEBAR)
local pl = Instance.new("ScrollingFrame", sb)
pl.Size = UDim2.new(1,-24,0,120)
pl.Position = UDim2.new(0,12,1,-190)
pl.BackgroundTransparency = 1
pl.BorderSizePixel = 0
pl.ScrollBarThickness = 3
pl.AutomaticCanvasSize = Enum.AutomaticSize.Y
pl.ZIndex = 3
Instance.new("UIListLayout", pl).Padding = UDim.new(0,3)

local function rf()
    for _, c in ipairs(pl:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for _, p in ipairs(P:GetPlayers()) do
        local b = Instance.new("TextButton", pl)
        b.Size = UDim2.new(1,0,0,25)
        b.BackgroundColor3 = (S.sel == p) and Color3.fromRGB(100,255,200) or Color3.fromRGB(20,20,25)
        b.Text = "  "..p.Name
        b.TextColor3 = (S.sel == p) and Color3.fromRGB(0,0,0) or Color3.fromRGB(220,220,220)
        b.TextSize = 10
        b.Font = Enum.Font.GothamBold
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.AutoButtonColor = false
        b.ZIndex = 4
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,5)
        b.MouseButton1Click:Connect(function()
            S.sel = p
            reg("Sel: "..p.Name)
            rf()
        end)
    end
end

rf()
P.PlayerAdded:Connect(rf)
P.PlayerRemoving:Connect(function()
    task.wait(0.1)
    rf()
end)

-- FPS COUNTER
local fr, t0 = 0, tick()
task.spawn(function()
    while fL.Parent do
        fr = fr + 1
        local now = tick()
        if now - t0 >= 1 then
            local p = 0
            pcall(function() p = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            fL.Text = "FPS: "..math.floor(fr/(now-t0)).." | "..p.."ms"
            fr, t0 = 0, now
        end
        R.RenderStepped:Wait()
    end
end)

-- FINALIZAÇÃO
sel("Main")
reg("ZEDUX HUB v12.0 carregado com sucesso!")
print("[ZEDUX HUB] Carregado - Unificado e Formatado.")
