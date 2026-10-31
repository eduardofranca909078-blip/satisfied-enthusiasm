--// ZEDUX HUB v8.0 - PARTE 1 (LOADER E DESIGN)
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
local URL_SITE = "COLOQUE_O_LINK_DO_SEU_SITE_AQUI" 
local URL_DISCORD = "https://discord.gg/s6GSy4TuJ"

local KEYS_VALIDAS = {["ZEDUX-HUB-2026"] = true, ["ZEDUX-HUB-VIP"] = true, ["ZEDUX-HUB-PRO"] = true, ["eduardo92301"] = true}
pcall(function()
    local d = readfile(KEYFILE)
    if d and d ~= "" then for l in d:gmatch("[^\n]+") do KEYS_VALIDAS[l] = true end end
end)

local OID = 4197733654
local WL = {"eduardo92301"}
local ADM = {[OID] = "PROPRIETÁRIO"}
local CG = ADM[LP.UserId] or "JOGADOR"
local AD = (CG == "PROPRIETÁRIO" or CG == "ADMIN")
local isVipOuSuperior = (LP.UserId == OID)
if getgenv().LH_CARGOS and getgenv().LH_CARGOS[LP.Name] then
    local cg = getgenv().LH_CARGOS[LP.Name]
    if cg == "VIP" or cg == "MOD" or cg == "ADMIN" or cg == "PROPRIETÁRIO" then isVipOuSuperior = true end
end
for _, n in ipairs(WL) do if LP.Name:lower() == n:lower() then isVipOuSuperior = true end end

local function ChecarTempoKey(key)
    local tempoAgora = os.time()
    local chaveSalva = ""
    pcall(function() chaveSalva = readfile(TEMPOFILE) end)
    if chaveSalva ~= "" then
        local dados = string.split(chaveSalva, "|")
        if dados[1] == key then
            local expiracao = tonumber(dados[2])
            if tempoAgora < expiracao then return true end
        end
    end
    local segundos = 0
    if string.find(key, "ZEDUX-DIA-") then segundos = 86400 
    elseif string.find(key, "ZEDUX-SEM-") then segundos = 86400 * 7 
    elseif string.find(key, "ZEDUX-MEN-") then segundos = 86400 * 30 
    elseif string.find(key, "ZEDUX-ANO-") then segundos = 86400 * 365 
    elseif string.find(key, "ZEDUX-PERM-") then 
        pcall(function() writefile(TEMPOFILE, key .. "|" .. tostring(253402300799)) end)
        return true 
    else return false end
    local expiracao = tempoAgora + segundos
    pcall(function() writefile(TEMPOFILE, key .. "|" .. tostring(expiracao)) end)
    return true
end

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
    
    local topBar = Instance.new("Frame", leftPanel)
    topBar.Size = UDim2.new(1, 0, 0, 35)
    topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

    local avatarFrame = Instance.new("Frame", leftPanel)
    avatarFrame.Size = UDim2.new(0, 80, 0, 80)
    avatarFrame.Position = UDim2.new(0.5, -40, 0, 50)
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
    nameLabel.Position = UDim2.new(0, 0, 0, 140)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = LP.DisplayName
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold

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

    local keyBox = Instance.new("TextBox", rightPanel)
    keyBox.Size = UDim2.new(0.8, 0, 0, 45)
    keyBox.Position = UDim2.new(0.1, 0, 0, 135)
    keyBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.PlaceholderText = "Waiting for key..."
    keyBox.TextSize = 14
    keyBox.Font = Enum.Font.Gotham
    Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)

    local redeemBtn = Instance.new("TextButton", rightPanel)
    redeemBtn.Size = UDim2.new(0.8, 0, 0, 40)
    redeemBtn.Position = UDim2.new(0.1, 0, 0, 195)
    redeemBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    redeemBtn.Text = "🛡️ Redeem"
    redeemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    redeemBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", redeemBtn).CornerRadius = UDim.new(0, 8)

    local statusLog = Instance.new("TextLabel", rightPanel)
    statusLog.Size = UDim2.new(0.8, 0, 0, 20)
    statusLog.Position = UDim2.new(0.1, 0, 0, 260)
    statusLog.BackgroundTransparency = 1
    statusLog.Text = ""
    statusLog.Font = Enum.Font.Gotham

    redeemBtn.MouseButton1Click:Connect(function()
        local keyDigitada = keyBox.Text:gsub("%s+", "")
        if KEYS_VALIDAS[keyDigitada] or ChecarTempoKey(keyDigitada) then
            statusLog.TextColor3 = Color3.fromRGB(0, 200, 100)
            statusLog.Text = "✅ Key válida! Iniciando painel..."
            task.wait(1)
            introGui:Destroy()
        else
            statusLog.TextColor3 = Color3.fromRGB(255, 80, 80)
            statusLog.Text = "❌ Key inválida."
        end
    end)

    if isVipOuSuperior then
        statusLog.TextColor3 = Color3.fromRGB(0, 200, 100)
        statusLog.Text = "✅ Autenticado via VIP."
        task.wait(1)
        introGui:Destroy()
    else
        repeat task.wait() until not introGui.Parent
    end
end
IniciarIntro()

local function reg(a)
    local h = os.date("%d/%m/%Y %H:%M:%S")
    table.insert(lg, {h = h, j = LP.Name, a = a})
    pcall(function() appendfile(LOGFILE, h .. "|" .. LP.Name .. "|" .. a .. "\n") end)
end

local gui = Instance.new("ScreenGui")
gui.Name = "ZeduxHub"
gui.ResetOnSpawn = false
gui.DisplayOrder = 99999
gui.Parent = game:GetService("CoreGui")

local flt = Instance.new("TextButton", gui)
flt.Size = UDim2.new(0, 50, 0, 50)
flt.Position = UDim2.new(0, 20, 0.5, -25)
flt.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
flt.Text = "👻"
flt.TextColor3 = Color3.fromRGB(255, 255, 255)
flt.TextSize = 22
flt.Visible = false
Instance.new("UICorner", flt).CornerRadius = UDim.new(0, 14)

local w = Instance.new("Frame", gui)
w.Size = UDim2.new(0, 700, 0, 440)
w.Position = UDim2.new(0.5, -350, 0.5, -220)
w.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
w.Visible = false
w.ClipsDescendants = true
Instance.new("UICorner", w).CornerRadius = UDim.new(0, 10)

local starfield = Instance.new("Frame", w)
starfield.Size = UDim2.new(1, 0, 1, 0)
starfield.BackgroundTransparency = 1
for i = 1, 150 do
    local star = Instance.new("Frame", starfield)
    star.Size = UDim2.new(0, math.random(1, 3), 0, math.random(1, 3))
    star.Position = UDim2.new(math.random(), 0, math.random(), 0)
    star.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", star).CornerRadius = UDim.new(1, 0)
    task.spawn(function()
        while star.Parent do
            T:Create(star, TweenInfo.new(math.random(10, 30) / 10), {BackgroundTransparency = math.random(0, 8) / 10}):Play()
            task.wait(1)
        end
    end)
end

local sb = Instance.new("Frame", w)
sb.Size = UDim2.new(0, 200, 1, 0)
sb.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
sb.BackgroundTransparency = 0.2
sb.ZIndex = 2
Instance.new("UICorner", sb).CornerRadius = UDim.new(0, 10)

local mn = Instance.new("Frame", w)
mn.Size = UDim2.new(1, -200, 1, 0)
mn.Position = UDim2.new(0, 200, 0, 0)
mn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
mn.BackgroundTransparency = 0.4
mn.ZIndex = 2
Instance.new("UICorner", mn).CornerRadius = UDim.new(0, 10)

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
Instance.new("UIListLayout", mnu).Padding = UDim.new(0, 3)

local CC = {Main = Color3.fromRGB(255,255,255), MOVIMENTO = Color3.fromRGB(200,200,200), ESP = Color3.fromRGB(220,220,220), COMBATE = Color3.fromRGB(255,255,255), TELECINESE = Color3.fromRGB(180,180,180), TROLL = Color3.fromRGB(230,230,230), PERSONALIZAÇÃO = Color3.fromRGB(180,180,180), ["CUSTOMIZAÇÃO AVANÇADA"] = Color3.fromRGB(0,255,100), CONFIGURAÇÕES = Color3.fromRGB(150,150,150), ADMINISTRAÇÃO = Color3.fromRGB(255,255,255)}
local mB = {}
local cs = {}

local function cat(n)
    local b = Instance.new("TextButton", mnu)
    b.Size = UDim2.new(1, 0, 0, 28)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    b.Text = "  ◆  " .. n
    b.TextColor3 = CC[n] or Color3.fromRGB(200,200,200)
    b.TextSize = 10
    b.Font = Enum.Font.GothamBold
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.AutoButtonColor = false
    b.ZIndex = 3
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    mB[n] = b
    table.insert(cs, n)
end

cat("Main"); cat("MOVIMENTO"); cat("ESP"); cat("COMBATE"); cat("TELECINESE"); cat("TROLL"); cat("PERSONALIZAÇÃO"); cat("CUSTOMIZAÇÃO AVANÇADA"); cat("CONFIGURAÇÕES")
if AD then cat("ADMINISTRAÇÃO") end--// ZEDUX HUB v8.0 - PARTE 2 (COMPONENTES YOX)
local function bt(p, tx, cb, tr)
    local b = Instance.new("TextButton", p)
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    b.Text = "  " .. tx
    b.TextColor3 = Color3.fromRGB(220, 220, 220)
    b.TextSize = 10
    b.Font = Enum.Font.GothamBold
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.ZIndex = 4
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function()
        reg(tx)
        task.wait(0.1)
        cb()
    end)
    return b
end

local function btT(p, tx, cb)
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

local function createSlider(parent, title, minVal, maxVal, defaultVal, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, 46)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    container.ZIndex = 4
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
    local titleLabel = Instance.new("TextLabel", container)
    titleLabel.Size = UDim2.new(0.7, 0, 0, 15)
    titleLabel.Position = UDim2.new(0, 12, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    titleLabel.TextSize = 10
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 5
    local valueLabel = Instance.new("TextLabel", container)
    valueLabel.Size = UDim2.new(0.2, 0, 0, 15)
    valueLabel.Position = UDim2.new(0.8, -10, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultVal)
    valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    valueLabel.TextSize = 10
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 5
    local bar = Instance.new("Frame", container)
    bar.Size = UDim2.new(1, -24, 0, 6)
    bar.Position = UDim2.new(0, 12, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    bar.ZIndex = 5
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
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
        val = maxVal == math.floor(maxVal) and math.floor(val) or math.floor(val * 10) / 10
        fill.Size = UDim2.new(relX, 0, 1, 0)
        knob.Position = UDim2.new(relX, -6, 0.5, -6)
        valueLabel.Text = tostring(val)
        if callback then callback(val) end
    end
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true update(i) end
    end)
    U.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update(i) end
    end)
    U.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    return container
end

local function createDropdown(parent, title, opts, default, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, 34)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    container.ZIndex = 4
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
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
    titleL.TextSize = 10
    titleL.Font = Enum.Font.GothamBold
    titleL.TextXAlignment = Enum.TextXAlignment.Left
    titleL.ZIndex = 5
    local curL = Instance.new("TextLabel", container)
    curL.Size = UDim2.new(0.5, -30, 1, 0)
    curL.Position = UDim2.new(0.5, 0, 0, 0)
    curL.BackgroundTransparency = 1
    curL.Text = default
    curL.TextColor3 = Color3.fromRGB(200, 200, 200)
    curL.TextSize = 10
    curL.Font = Enum.Font.Gotham
    curL.TextXAlignment = Enum.TextXAlignment.Right
    curL.ZIndex = 5
    local arrow = Instance.new("TextLabel", container)
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -25, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
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
        ob.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        ob.Text = "  " .. opt
        ob.TextColor3 = Color3.fromRGB(220, 220, 220)
        ob.TextSize = 10
        ob.Font = Enum.Font.Gotham
        ob.TextXAlignment = Enum.TextXAlignment.Left
        ob.ZIndex = 11
        Instance.new("UICorner", ob).CornerRadius = UDim.new(0, 4)
        ob.MouseButton1Click:Connect(function()
            curL.Text = opt
            list.Visible = false
            arrow.Text = "▼"
            if callback then callback(opt) end
        end)
    end
    local aberto = false
    btn.MouseButton1Click:Connect(function()
        aberto = not aberto
        list.Visible = aberto
        arrow.Text = aberto and "▲" or "▼"
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
            b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            b.TextColor3 = cr
        end
    end
    for nn, s in pairs(sec) do s.Visible = (nn == n) end
end

for n, b in pairs(mB) do b.MouseButton1Click:Connect(function() sel(n) end) end
sel("Main")--// ZEDUX HUB v8.0 - PARTE 3 (CONTROLES, MAIN, COMBATE E MOVIMENTO)

-- ═══════════════════════════════════════════════
-- CONTROLES DO PAINEL (AUMENTAR, MINIMIZAR, FECHAR)
-- ═══════════════════════════════════════════════
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
local ctnB = hB(-104, "📍")
local hB2 = hB(-70, "👁️")
local cB2 = hB(-36, "□")

pB.MouseButton1Click:Connect(function()
    local tamAtual = w.Size.X.Offset
    local novoTam = math.min(1200, tamAtual + 50)
    if novoTam == tamAtual then return end
    local proporcao = novoTam / tamAtual
    T:Create(w, TweenInfo.new(0.2), {Size = UDim2.new(0, novoTam, 0, w.Size.Y.Offset * proporcao)}):Play()
    reg("Tamanho: " .. novoTam)
end)

mB2.MouseButton1Click:Connect(function()
    local tamAtual = w.Size.X.Offset
    local novoTam = math.max(400, tamAtual - 50)
    if novoTam == tamAtual then return end
    local proporcao = novoTam / tamAtual
    T:Create(w, TweenInfo.new(0.2), {Size = UDim2.new(0, novoTam, 0, w.Size.Y.Offset * proporcao)}):Play()
    reg("Tamanho: " .. novoTam)
end)

ctnB.MouseButton1Click:Connect(function()
    local vp = workspace.CurrentCamera.ViewportSize
    T:Create(w, TweenInfo.new(0.2), {Position = UDim2.new(0, (vp.X / 2) - (w.Size.X.Offset / 2), 0, (vp.Y / 2) - (w.Size.Y.Offset / 2))}):Play()
    reg("Centralizado")
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
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
mh.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
U.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        w.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ═══════════════════════════════════════════════
-- VISUAL GLOBAL (FOV CIRCLE + CROSSHAIR)
-- ═══════════════════════════════════════════════
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
local function attFov()
    fovCircle.Size = UDim2.new(0, aimFov * 2.5, 0, aimFov * 2.5)
end

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

-- ═══════════════════════════════════════════════
-- ABA MAIN (DASHBOARD)
-- ═══════════════════════════════════════════════
local cMain = Instance.new("Frame", sec["Main"])
cMain.Size = UDim2.new(1, 0, 0, 80)
cMain.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
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
welcome.ZIndex = 5

local statusTxt = Instance.new("TextLabel", cMain)
statusTxt.Size = UDim2.new(1, -20, 0, 20)
statusTxt.Position = UDim2.new(0, 10, 0, 40)
statusTxt.BackgroundTransparency = 1
statusTxt.Text = "Status: Online | Cargo: " .. CG
statusTxt.TextColor3 = Color3.fromRGB(200, 200, 200)
statusTxt.TextSize = 11
statusTxt.Font = Enum.Font.Gotham
statusTxt.TextXAlignment = Enum.TextXAlignment.Left
statusTxt.ZIndex = 5

-- ═══════════════════════════════════════════════
-- ABA COMBATE (AIMBOT COM SLIDER, FOV E CROSSHAIR)
-- ═══════════════════════════════════════════════
local cCb = Instance.new("Frame", sec["COMBATE"])
cCb.Size = UDim2.new(1, 0, 0, 0)
cCb.AutomaticSize = Enum.AutomaticSize.Y
cCb.BackgroundTransparency = 1
Instance.new("UIListLayout", cCb).Padding = UDim.new(0, 6)

local aimAtivo = false
local aimPart = "Head"
local aimSuave = 1

btT(cCb, "🎯 Aimbot", function(v)
    aimAtivo = v
    if v then
        task.spawn(function()
            while aimAtivo do
                pcall(function()
                    local melhor = nil
                    local menorDist = math.huge
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
                                            menorDist = d
                                            melhor = targetPart
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
    end
end)

createSlider(cCb, "FOV Size", 50, 800, 150, function(valor)
    aimFov = valor
    attFov()
end)

createDropdown(cCb, "Lock Part", {"Head", "HumanoidRootPart", "UpperTorso", "Torso"}, "Head", function(escolha)
    aimPart = escolha
end)

createSlider(cCb, "Smoothing", 1, 10, 1, function(valor)
    aimSuave = valor
end)

btT(cCb, "👁️ Mostrar FOV Circle", function(v)
    fovCircle.Visible = v
    if v then attFov() end
end)

btT(cCb, "🎯 Crosshair Customizada", function(v)
    cross.Visible = v
end)

createSlider(cCb, "Gap da Mira", 5, 30, 15, function(valor)
    local gap = valor / 2
    cima.Parent.Position = UDim2.new(0.5, -1, 0, -gap - 10)
    baixo.Parent.Position = UDim2.new(0.5, -1, 0, gap)
    esq.Parent.Position = UDim2.new(0, -gap - 10, 0.5, -1)
    dir.Parent.Position = UDim2.new(0, gap, 0.5, -1)
end)

-- ═══════════════════════════════════════════════
-- ABA MOVIMENTO (SLIDERS DE SPEED E JUMP)
-- ═══════════════════════════════════════════════
local cM = Instance.new("Frame", sec["MOVIMENTO"])
cM.Size = UDim2.new(1, 0, 0, 0)
cM.AutomaticSize = Enum.AutomaticSize.Y
cM.BackgroundTransparency = 1
Instance.new("UIListLayout", cM).Padding = UDim.new(0, 6)

local spdAtivo = false
local spdValor = 16

createSlider(cM, "Walk Speed", 16, 250, 16, function(valor)
    spdValor = valor
    if LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum and spdAtivo then hum.WalkSpeed = valor end
    end
end)

btT(cM, "⚡ Ativar Speed", function(v)
    spdAtivo = v
    if v and LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = spdValor end
    elseif not v and LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end)

local jmpValor = 50
createSlider(cM, "Jump Power", 50, 300, 50, function(valor)
    jmpValor = valor
    if LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = valor end
    end
end)

local flyAtivo = false
local flyBV, flyBG
btT(cM, "🕊️ Fly", function(v)
    flyAtivo = v
    if v and LP.Character then
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
    else
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
    end
end)

local ncA = false
btT(cM, "👻 Noclip", function(v)
    ncA = v
    if v then
        task.spawn(function()
            while ncA do
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

print("[ZEDUX HUB] Parte 3 carregada!")--// ZEDUX HUB v8.0 - PARTE 4 (ESP, TROLL, CUSTOM E TELECINESE)

-- ═══════════════════════════════════════════════
-- ABA ESP
-- ═══════════════════════════════════════════════
local cE = Instance.new("Frame", sec["ESP"])
cE.Size = UDim2.new(1, 0, 0, 0)
cE.AutomaticSize = Enum.AutomaticSize.Y
cE.BackgroundTransparency = 1
Instance.new("UIListLayout", cE).Padding = UDim.new(0, 6)

local eF = Instance.new("Folder", gui)
eF.Name = "ZeduxEsp"
local eA = false

local function limE() 
    for _, c in ipairs(eF:GetChildren()) do c:Destroy() end 
end

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
    n.TextColor3 = Color3.fromRGB(255, 255, 255)
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
            if u then hp.Text = "❤ " .. math.floor(u.Health) else hp.Text = "💀" end
            if h and h.Parent then
                local d = math.floor((h.Position - C.CFrame.Position).Magnitude)
                n.Text = p.Name .. " [" .. d .. "m]"
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
        limE()
        reg("ESP OFF")
    end
end)

P.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        if eA then
            task.wait(1)
            local ex = eF:FindFirstChild("P_" .. p.Name)
            if ex then ex:Destroy() end
            cP(p)
        end
    end)
end)

LP.CharacterAdded:Connect(function()
    if eA then
        task.wait(1.5)
        limE()
        for _, p in ipairs(P:GetPlayers()) do if p ~= LP then cP(p) end end
    end
end)

-- ═══════════════════════════════════════════════
-- ABA TROLL (COMPLETO)
-- ═══════════════════════════════════════════════
local cTr = Instance.new("Frame", sec["TROLL"])
cTr.Size = UDim2.new(1, 0, 0, 0)
cTr.AutomaticSize = Enum.AutomaticSize.Y
cTr.BackgroundTransparency = 1
Instance.new("UIListLayout", cTr).Padding = UDim.new(0, 6)

bt(cTr, "🔥 Matar Todos", function()
    for _, p in ipairs(P:GetPlayers()) do
        if p ~= LP and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
        end
    end
    reg("Matou todos")
end, true)

local iyFlingAtivo = false
btT(cTr, "🌀 Fling IY (Girar)", function(v)
    iyFlingAtivo = v
    if v and LP.Character then
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart") if not hrp then return end
        local spin = Instance.new("BodyAngularVelocity", hrp) 
        spin.Name = "ZEDUX_IYSpin" 
        spin.AngularVelocity = Vector3.new(0, 1000, 0) 
        spin.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        task.spawn(function()
            while iyFlingAtivo do
                if not LP.Character then break end
                local meuHrp = LP.Character:FindFirstChild("HumanoidRootPart") if not meuHrp then break end
                for _, p in ipairs(P:GetPlayers()) do
                    if p ~= LP and p.Character then
                        local alvoHrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if alvoHrp then
                            local dist = (meuHrp.Position - alvoHrp.Position).Magnitude
                            if dist < 8 then
                                pcall(function()
                                    alvoHrp:SetNetworkOwner(LP)
                                    local bv = Instance.new("BodyVelocity", alvoHrp) 
                                    bv.Name = "ZEDUX_IYFling" 
                                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge) 
                                    bv.Velocity = Vector3.new(math.random(-5000, 5000), 5000, math.random(-5000, 5000))
                                    task.delay(0.5, function() if bv then bv:Destroy() end end)
                                end)
                            end
                        end
                    end
                end
                R.Heartbeat:Wait()
            end
            if LP.Character then
                local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local spin = hrp:FindFirstChild("ZEDUX_IYSpin") if spin then spin:Destroy() end
                end
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════
-- ABA CUSTOMIZAÇÃO AVANÇADA (HEADLESS E KORBLOX)
-- ═══════════════════════════════════════════════
local cCust = Instance.new("Frame", sec["CUSTOMIZAÇÃO AVANÇADA"])
cCust.Size = UDim2.new(1, 0, 0, 0)
cCust.AutomaticSize = Enum.AutomaticSize.Y
cCust.BackgroundTransparency = 1
Instance.new("UIListLayout", cCust).Padding = UDim.new(0, 6)

local isHeadless = false
local isKorblox = false
local originalParts = {}

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

btT(cCust, "💀 Headless (Invisível)", function(v)
    isHeadless = v
    updateChar()
end)

btT(cCust, "🦴 Korblox (Preto)", function(v)
    isKorblox = v
    updateChar()
end)

-- ═══════════════════════════════════════════════
-- ABA TELECINESE
-- ═══════════════════════════════════════════════
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

print("[ZEDUX HUB] Parte 4 carregada!")--// ZEDUX HUB v8.0 - PARTE 5 (TROLL RESTANTE, PERSONALIZAÇÃO, CONFIG, ADMIN E FINALIZAÇÃO)

-- ═══════════════════════════════════════════════
-- TROLL (RESTANTE)
-- ═══════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════
-- PERSONALIZAÇÃO (TEMAS)
-- ═══════════════════════════════════════════════
local cPer = Instance.new("Frame", sec["PERSONALIZAÇÃO"])
cPer.Size = UDim2.new(1, 0, 0, 0)
cPer.AutomaticSize = Enum.AutomaticSize.Y
cPer.BackgroundTransparency = 1
Instance.new("UIListLayout", cPer).Padding = UDim.new(0, 6)

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

-- ═══════════════════════════════════════════════
-- CONFIGURAÇÕES (ANTI-LAG, FPS, TAMANHO)
-- ═══════════════════════════════════════════════
local cConf = Instance.new("Frame", sec["CONFIGURAÇÕES"])
cConf.Size = UDim2.new(1, 0, 0, 0)
cConf.AutomaticSize = Enum.AutomaticSize.Y
cConf.BackgroundTransparency = 1
Instance.new("UIListLayout", cConf).Padding = UDim.new(0, 6)

local aA = false
btT(cConf, "⚡ Anti-Lag", function(v)
    aA = v
    if v then
        task.spawn(function()
            while aA do
                for _, o in ipairs(workspace:GetDescendants()) do
                    if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Smoke") or o:IsA("Fire") or o:IsA("Sparkles") or o:IsA("Beam") then o.Enabled = false end
                    if o:IsA("BasePart") then pcall(function() o.CastShadow = false end) end
                end
                task.wait(3)
            end
        end)
    end
end)

bt(cConf, "📊 FPS", function() fL.Visible = not fL.Visible reg("FPS " .. (fL.Visible and "ON" or "OFF")) end)

local tms = {{n = "Pequeno", w = 500, h = 320}, {n = "Médio", w = 700, h = 440}, {n = "Grande", w = 1000, h = 600}}
local tI = 2
bt(cConf, "📐 Tamanho", function()
    tI = tI % 3 + 1
    local t = tms[tI]
    T:Create(w, TweenInfo.new(0.2), {Size = UDim2.new(0, t.w, 0, t.h)}):Play()
    reg("Tam: " .. t.n)
end)

bt(cConf, "📌 Centralizar", function()
    local vp = workspace.CurrentCamera.ViewportSize
    T:Create(w, TweenInfo.new(0.2), {Position = UDim2.new(0, vp.X / 2 - w.Size.X.Offset / 2, 0, vp.Y / 2 - w.Size.Y.Offset / 2)}):Play()
    reg("Central")
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

bt(cConf, "🗑️ Fechar", function()
    reg("🚪 Painel FECHADO por " .. LP.Name)
    task.wait(0.1)
    gui:Destroy()
end)

-- ═══════════════════════════════════════════════
-- ADMINISTRAÇÃO COMPLETA
-- ═══════════════════════════════════════════════
if AD then
    local cA = Instance.new("Frame", sec["ADMINISTRAÇÃO"])
    cA.Size = UDim2.new(1, 0, 0, 0)
    cA.AutomaticSize = Enum.AutomaticSize.Y
    cA.BackgroundTransparency = 1
    Instance.new("UIListLayout", cA).Padding = UDim.new(0, 6)

    local iA = Instance.new("TextBox", cA)
    iA.Size = UDim2.new(1, 0, 0, 34)
    iA.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    iA.TextColor3 = Color3.fromRGB(255, 255, 255)
    iA.PlaceholderText = "nick do player..."
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

    local selCargo = Instance.new("TextLabel", cA)
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
        if not S.sel then reg("❌ Cargo: nenhum selecionado") return end
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
        local btn = Instance.new("TextButton", cA)
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

    local iK = Instance.new("TextBox", cA)
    iK.Size = UDim2.new(1, 0, 0, 34)
    iK.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    iK.TextColor3 = Color3.fromRGB(255, 255, 255)
    iK.PlaceholderText = "Ex: ZEDUX-HUB-VIP-001"
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

    bt(cA, "🔑 GERAR KEY", function()
        local k = iK.Text:gsub("%s+", "")
        if k == "" then reg("❌ Digite uma key!") return end
        if KEYS_VALIDAS[k] then reg("❌ Key já existe") return end
        KEYS_VALIDAS[k] = true
        salvarKeys()
        reg("🔑 Key GERADA: " .. k)
        iK.Text = ""
    end)

    bt(cA, "🗑️ REMOVER KEY", function()
        local k = iK.Text:gsub("%s+", "")
        if k == "" then reg("❌ Digite uma key!") return end
        if not KEYS_VALIDAS[k] then reg("❌ Key não existe") return end
        KEYS_VALIDAS[k] = nil
        salvarKeys()
        reg("🗑️ Key REMOVIDA: " .. k)
        iK.Text = ""
    end)
end

sel("Main")
reg("🟢 Painel carregado - " .. LP.Name)
print("[ZEDUX HUB] Script 100% carregado com sucesso!")
