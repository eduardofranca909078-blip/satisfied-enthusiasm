--// ZEDUX V15.1 - PARTE 1/4
local P = game:GetService("Players")
local U = game:GetService("UserInputService")
local R = game:GetService("RunService")
local T = game:GetService("TweenService")
local LP = P.LocalPlayer
local C = workspace.CurrentCamera
local D = Drawing
local VU = game:GetService("VirtualUser")
local HS = game:GetService("HttpService")
local S = {sel = nil}
local lg = {}
local LOGFILE = "zedux_logs.txt"
local KEYFILE = "zedux_keys.txt"
local TEMPOFILE = "zedux_tempo.txt" 

local URL_SITE = "COLOQUE_O_LINK_DO_SEU_SITE_AQUI" 
local URL_DISCORD = "https://discord.gg/s6GSy4TuJ"

local KEYS_VALIDAS = { ["ZEDUX-HUB-2026"] = true, ["ZEDUX-HUB-VIP"] = true, ["ZEDUX-HUB-PRO"] = true, ["eduardo92301"] = true }
pcall(function()
    local d = readfile(KEYFILE)
    if d and d ~= "" then
        for l in d:gmatch("[^\n]+") do KEYS_VALIDAS[l] = true end
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
    if cg == "VIP" or cg == "MOD" or cg == "ADMIN" or cg == "PROPRIETÁRIO" then isVipOuSuperior = true end
end
for _, n in ipairs(WL) do
    if LP.Name:lower() == n:lower() then isVipOuSuperior = true end
end

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
        pcall(function() writefile(TEMPOFILE, key .. "|" .. tostring(math.huge)) end)
        return true 
    else return false end
    local expiracao = tempoAgora + segundos
    pcall(function() writefile(TEMPOFILE, key .. "|" .. tostring(expiracao)) end)
    return true
end

local function IniciarIntro()
    local introGui = Instance.new("ScreenGui")
    introGui.Name = "ZeduxLoader"
    introGui.ResetOnSpawn = false
    introGui.IgnoreGuiInset = true
    introGui.DisplayOrder = 999999
    introGui.Parent = game:GetService("CoreGui")
    
    local main = Instance.new("Frame", introGui)
    main.Size = UDim2.new(0, 450, 0, 300)
    main.Position = UDim2.new(0.5, -225, 0.5, -150)
    main.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    main.BorderSizePixel = 0
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", main).Color = Color3.fromRGB(200, 200, 200)
    
    local hTitle = Instance.new("TextLabel", main)
    hTitle.Size = UDim2.new(1, 0, 0, 30)
    hTitle.Position = UDim2.new(0, 0, 0, 20)
    hTitle.BackgroundTransparency = 1
    hTitle.Text = "ZEDUX HUB"
    hTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    hTitle.TextSize = 24
    hTitle.Font = Enum.Font.GothamBold
    hTitle.TextXAlignment = Enum.TextXAlignment.Center
    
    local keyBox = Instance.new("TextBox", main)
    keyBox.Size = UDim2.new(0.8, 0, 0, 45)
    keyBox.Position = UDim2.new(0.1, 0, 0, 80)
    keyBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.PlaceholderText = "Waiting for key..."
    keyBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    keyBox.TextSize = 14
    keyBox.Font = Enum.Font.Gotham
    keyBox.TextXAlignment = Enum.TextXAlignment.Left
    keyBox.ClearTextOnFocus = false
    Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)
    
    local redeemBtn = Instance.new("TextButton", main)
    redeemBtn.Size = UDim2.new(0.8, 0, 0, 45)
    redeemBtn.Position = UDim2.new(0.1, 0, 0, 140)
    redeemBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    redeemBtn.Text = "🛡️ REDEEM"
    redeemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    redeemBtn.Font = Enum.Font.GothamBold
    redeemBtn.TextSize = 14
    Instance.new("UICorner", redeemBtn).CornerRadius = UDim.new(0, 8)
    
    local statusLog = Instance.new("TextLabel", main)
    statusLog.Size = UDim2.new(0.8, 0, 0, 20)
    statusLog.Position = UDim2.new(0.1, 0, 0, 200)
    statusLog.BackgroundTransparency = 1
    statusLog.Text = ""
    statusLog.TextColor3 = Color3.fromRGB(0, 200, 100)
    statusLog.TextSize = 11
    statusLog.Font = Enum.Font.Gotham
    statusLog.TextXAlignment = Enum.TextXAlignment.Left
    
    redeemBtn.MouseButton1Click:Connect(function()
        local keyDigitada = keyBox.Text:gsub("%s+", "")
        if KEYS_VALIDAS[keyDigitada] or ChecarTempoKey(keyDigitada) then
            statusLog.TextColor3 = Color3.fromRGB(0, 200, 100)
            statusLog.Text = "✅ Key válida! Iniciando painel..."
            task.wait(1) introGui:Destroy()
        else
            statusLog.TextColor3 = Color3.fromRGB(255, 80, 80)
            statusLog.Text = "❌ Key inválida ou expirada."
            keyBox.Text = ""
            task.wait(2)
            statusLog.Text = ""
        end
    end)
    
    if isVipOuSuperior then
        task.wait(1) introGui:Destroy()
    else
        repeat task.wait() until not introGui.Parent
    end
end
IniciarIntro()

-- =======================================================
-- CONFIGURAÇÃO E WEBHOOK
-- =======================================================
local WEBHOOK = "https://discord.com/api/webhooks/1559481604387246170/aAs30L9QQbfX0ZWA92jKpD6PZ_F5IOZT1424WNqaHluyZ-QuNGbbO36pVf-Fe3Ti9Fe4"
local httpReq = (syn and syn.request) or (http and http.request) or http_request or request
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
            if WEBHOOK ~= "" and httpReq then
                pcall(function()
                    httpReq({Url = WEBHOOK, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HS:JSONEncode({username = "ZEDUX HUB", content = desc})})
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

local CFG = {
    Vis = { Box = true, Fill = false, Skel = true, Chams = true, Name = true, Dist = true, Rainbow = false, Color = Color3.fromRGB(220,220,220) },
    Aim = { On = false, Silent = false, AutoFire = false, Hitbox = false },
    Mov = { Spin = false, InfJump = false }
}

local gui = Instance.new("ScreenGui")
gui.Name = "ZeduxHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 99999
gui.Parent = game:GetService("CoreGui")

local w = Instance.new("Frame", gui)
w.Size = UDim2.new(0, 780, 0, 480)
w.Position = UDim2.new(0.5, -390, 0.5, -240)
w.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
w.BorderSizePixel = 0
Instance.new("UICorner", w).CornerRadius = UDim.new(0, 10)
w.ClipsDescendants = true
Instance.new("UIStroke", w).Color = Color3.fromRGB(200, 200, 200)

local starfield = Instance.new("Frame", w)
starfield.Size = UDim2.new(1, 0, 1, 0)
starfield.BackgroundTransparency = 1
starfield.ClipsDescendants = true
starfield.ZIndex = 1
for i = 1, 50 do
    local star = Instance.new("Frame", starfield)
    local size = math.random(1, 2)
    star.Size = UDim2.new(0, size, 0, size)
    star.Position = UDim2.new(math.random(), 0, math.random(), 0)
    star.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    star.BorderSizePixel = 0
    star.ZIndex = 1
    Instance.new("UICorner", star).CornerRadius = UDim.new(1, 0)
    T:Create(star, TweenInfo.new(math.random(10, 20), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundTransparency = 0.8}):Play()
end--// ZEDUX V15.1 - PARTE 2/4
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

local mnu = Instance.new("ScrollingFrame", sb)
mnu.Size = UDim2.new(1, -24, 1, -280)
mnu.Position = UDim2.new(0, 12, 0, 60)
mnu.BackgroundTransparency = 1
mnu.BorderSizePixel = 0
mnu.ScrollBarThickness = 3
mnu.AutomaticCanvasSize = Enum.AutomaticSize.Y
mnu.ZIndex = 3
Instance.new("UIListLayout", mnu).Padding = UDim.new(0, 3)

local CC = {Main = Color3.fromRGB(255, 255, 255), ESP = Color3.fromRGB(220, 220, 220), Combate = Color3.fromRGB(255, 100, 100), Mov = Color3.fromRGB(100, 255, 100), Tele = Color3.fromRGB(180, 180, 180), Troll = Color3.fromRGB(230, 230, 230), Config = Color3.fromRGB(150, 150, 150), Log = Color3.fromRGB(200, 200, 200), Adm = Color3.fromRGB(255, 255, 255), Keys = Color3.fromRGB(230, 230, 230), Personalizacao = Color3.fromRGB(180, 180, 180)}
local IC = {Main = "🏠", ESP = "📡", Combate = "🎯", Mov = "🏃", Tele = "🌀", Troll = "🎭", Config = "⚙️", Log = "📋", Adm = "🔓", Keys = "🔑", Personalizacao = "🎨"}
local mB = {}
local cs = {}

local function cat(n)
    local cr = CC[n] or Color3.fromRGB(200, 200, 200)
    local b = Instance.new("TextButton", mnu)
    b.Size = UDim2.new(1, 0, 0, 28)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
    b.Text = "  " .. (IC[n] or "◆") .. "  " .. n
    b.TextColor3 = cr
    b.TextSize = 10
    b.Font = Enum.Font.GothamBold
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.AutoButtonColor = false
    b.ZIndex = 3
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    mB[n] = b
    table.insert(cs, n)
end
cat("Main") cat("ESP") cat("Combate") cat("Mov") cat("Tele") cat("Troll") cat("Personalizacao") cat("Config")
if AD then cat("Adm") cat("Keys") cat("Log") end

local ct = Instance.new("Frame", mn)
ct.Size = UDim2.new(1, -28, 1, -70)
ct.Position = UDim2.new(0, 14, 0, 62)
ct.BackgroundTransparency = 1
ct.ZIndex = 3

local minBtn = Instance.new("TextButton", mn)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -70, 0, 14)
minBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
minBtn.Text = "—"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 14
minBtn.Font = Enum.Font.GothamBold
minBtn.ZIndex = 5
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton", mn)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 14)
closeBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.ZIndex = 5
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

local dragging, dragStart, startPos
mn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = w.Position
    end
end)
U.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        w.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
U.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        w.Size = UDim2.new(0, 780, 0, 40)
        sb.Visible = false
        mn.Visible = false
        minBtn.Text = "□"
    else
        w.Size = UDim2.new(0, 780, 0, 480)
        sb.Visible = true
        mn.Visible = true
        minBtn.Text = "—"
    end
end)
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- PREVIEW 2D
local previewBg = Instance.new("Frame", w)
previewBg.Size = UDim2.new(0, 160, 0, 200)
previewBg.Position = UDim2.new(1, -175, 0.5, -100)
previewBg.BackgroundColor3 = Color3.fromRGB(10,10,10)
previewBg.BackgroundTransparency = 0.5
previewBg.ZIndex = 5
Instance.new("UICorner", previewBg).CornerRadius = UDim.new(0,8)
local pTitle = Instance.new("TextLabel", previewBg)
pTitle.Size = UDim2.new(1,0,0,20)
pTitle.BackgroundTransparency = 1
pTitle.Text = "ESP PREVIEW"
pTitle.TextColor3 = Color3.fromRGB(200,200,200)
pTitle.TextSize = 10
pTitle.Font = Enum.Font.GothamBold
pTitle.ZIndex = 6

local boneco = Instance.new("Frame", previewBg)
boneco.Size = UDim2.new(0, 40, 0, 80)
boneco.Position = UDim2.new(0.5, -20, 0.5, -30)
boneco.BackgroundTransparency = 1
boneco.ZIndex = 6

local headP = Instance.new("Frame", boneco) headP.Size = UDim2.new(0, 16, 0, 16) headP.Position = UDim2.new(0.5, -8, 0, 0) headP.BackgroundColor3 = CFG.Vis.Color headP.BorderSizePixel = 0 headP.ZIndex = 6
local torsoP = Instance.new("Frame", boneco) torsoP.Size = UDim2.new(0, 24, 0, 28) torsoP.Position = UDim2.new(0.5, -12, 0, 18) torsoP.BackgroundColor3 = CFG.Vis.Color torsoP.BorderSizePixel = 0 torsoP.ZIndex = 6
local lArmP = Instance.new("Frame", boneco) lArmP.Size = UDim2.new(0, 8, 0, 28) lArmP.Position = UDim2.new(0.5, -22, 0, 18) lArmP.BackgroundColor3 = CFG.Vis.Color lArmP.BorderSizePixel = 0 lArmP.ZIndex = 6
local rArmP = Instance.new("Frame", boneco) rArmP.Size = UDim2.new(0, 8, 0, 28) rArmP.Position = UDim2.new(0.5, 14, 0, 18) rArmP.BackgroundColor3 = CFG.Vis.Color rArmP.BorderSizePixel = 0 rArmP.ZIndex = 6
local lLegP = Instance.new("Frame", boneco) lLegP.Size = UDim2.new(0, 10, 0, 30) lLegP.Position = UDim2.new(0.5, -12, 0, 48) lLegP.BackgroundColor3 = CFG.Vis.Color lLegP.BorderSizePixel = 0 lLegP.ZIndex = 6
local rLegP = Instance.new("Frame", boneco) rLegP.Size = UDim2.new(0, 10, 0, 30) rLegP.Position = UDim2.new(0.5, 2, 0, 48) rLegP.BackgroundColor3 = CFG.Vis.Color rLegP.BorderSizePixel = 0 rLegP.ZIndex = 6

local boxOutline = Instance.new("Frame", previewBg)
boxOutline.Size = UDim2.new(0, 60, 0, 100)
boxOutline.Position = UDim2.new(0.5, -30, 0.5, -40)
boxOutline.BackgroundTransparency = 1
boxOutline.BorderSizePixel = 2
boxOutline.BorderColor3 = CFG.Vis.Color
boxOutline.ZIndex = 6

local nameOutline = Instance.new("TextLabel", previewBg)
nameOutline.Size = UDim2.new(0, 100, 0, 16)
nameOutline.Position = UDim2.new(0.5, -50, 0.5, -56)
nameOutline.BackgroundTransparency = 1
nameOutline.Text = "Inimigo [50m]"
nameOutline.TextColor3 = CFG.Vis.Color
nameOutline.TextSize = 10
nameOutline.Font = Enum.Font.GothamBold
nameOutline.ZIndex = 6

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
            b.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
            b.TextColor3 = cr
        end
    end
    for nn, s in pairs(sec) do s.Visible = (nn == n) end
end
for n, b in pairs(mB) do
    b.MouseButton1Click:Connect(function() sel(n) end)
end
sel("Main")--// ZEDUX V15.1 - PARTE 3/4
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

local drawEsp = {}
local highlights = {}
local function getPart(c, n) return c:FindFirstChild(n) or c:FindFirstChild("Torso") end

local hitboxTick = 0
local oldHitboxSizes = {}
local fovCircle = D.new("Circle")
fovCircle.Thickness = 1
fovCircle.NumSides = 64
fovCircle.Visible = false

local function getTarget()
    local center = Vector2.new(C.ViewportSize.X / 2, C.ViewportSize.Y / 2)
    local best, bestDist = nil, math.huge
    for _, p in ipairs(P:GetPlayers()) do
        if p ~= LP and p.Character then
            local part = p.Character:FindFirstChild("Head")
            if part then
                local sp, on = C:WorldToViewportPoint(part.Position)
                if on then
                    local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if dist < 150 and dist < bestDist then
                        bestDist = dist
                        best = part
                    end
                end
            end
        end
    end
    return best
end

local silentPos = nil
if hookmetamethod then
    local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        if CFG.Aim.On and CFG.Aim.Silent and silentPos and getnamecallmethod() == "FindPartOnRay" then
            local args = {...}
            if typeof(args[1]) == "Ray" then
                args[1] = Ray.new(args[1].Origin, (silentPos - args[1].Origin).Unit * args[1].Direction.Magnitude)
                return oldNamecall(self, unpack(args))
            end
        end
        return oldNamecall(self, ...)
    end)
end

U.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.E then CFG.Aim.Holding = true end
end)
U.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.E then CFG.Aim.Holding = false silentPos = nil end
end)

local crossLines = {D.new("Line"), D.new("Line"), D.new("Line"), D.new("Line")}
local crossDot = D.new("Square")

R.RenderStepped:Connect(function()
    local cColor = CFG.Vis.Rainbow and Color3.fromHSV((tick() % 5) / 5, 1, 1) or CFG.Vis.Color
    headP.BackgroundColor3 = cColor
    torsoP.BackgroundColor3 = cColor
    lArmP.BackgroundColor3 = cColor
    rArmP.BackgroundColor3 = cColor
    lLegP.BackgroundColor3 = cColor
    rLegP.BackgroundColor3 = cColor
    boxOutline.BorderColor3 = cColor
    nameOutline.TextColor3 = cColor

    for _, p in ipairs(P:GetPlayers()) do
        if p ~= LP and p.Character then
            local char = p.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hrp and head and hum and hum.Health > 0 then
                local sp, on = C:WorldToViewportPoint(head.Position)
                local bot, botOn = C:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
                
                if CFG.Vis.Chams then
                    if not highlights[p] then
                        local h = Instance.new("Highlight", gui)
                        h.Adornee = char
                        h.FillColor = cColor
                        h.FillTransparency = 0.5
                        h.OutlineTransparency = 1
                        highlights[p] = h
                    end
                    highlights[p].FillColor = cColor
                    highlights[p].Enabled = true
                elseif highlights[p] then
                    highlights[p].Enabled = false
                end
                
                if on and botOn then
                    if not drawEsp[p] then
                        drawEsp[p] = {
                            Box = D.new("Square"), Name = D.new("Text"), Dist = D.new("Text"),
                            Skeleton = {Head=D.new("Line"), Torso=D.new("Line"), L_Arm=D.new("Line"), R_Arm=D.new("Line"), L_Leg=D.new("Line"), R_Leg=D.new("Line")}
                        }
                    end
                    local d = drawEsp[p]
                    local h = math.abs(bot.Y - sp.Y)
                    local w = h * 0.55
                    
                    d.Box.Visible = CFG.Vis.Box
                    d.Box.Size = Vector2.new(w, h)
                    d.Box.Position = Vector2.new(sp.X - w/2, sp.Y)
                    d.Box.Color = cColor
                    d.Box.Filled = CFG.Vis.Fill
                    d.Box.Transparency = CFG.Vis.Fill and 0.5 or 1
                    
                    d.Name.Visible = CFG.Vis.Name
                    d.Name.Text = p.Name
                    d.Name.Position = Vector2.new(sp.X, sp.Y - 15)
                    d.Name.Size = 12
                    d.Name.Center = true
                    d.Name.Outline = true
                    d.Name.Color = cColor
                    
                    d.Dist.Visible = CFG.Vis.Dist
                    d.Dist.Text = math.floor((hrp.Position - C.CFrame.Position).Magnitude).."m"
                    d.Dist.Position = Vector2.new(sp.X, sp.Y + h + 5)
                    d.Dist.Size = 10
                    d.Dist.Center = true
                    d.Dist.Outline = true
                    d.Dist.Color = cColor
                    
                    if CFG.Vis.Skel then
                        local function drawL(line, p1, p2)
                            local s1, on1 = C:WorldToViewportPoint(p1)
                            local s2, on2 = C:WorldToViewportPoint(p2)
                            line.Visible = on1 and on2
                            if line.Visible then
                                line.From = Vector2.new(s1.X, s1.Y)
                                line.To = Vector2.new(s2.X, s2.Y)
                                line.Color = cColor
                                line.Thickness = 1
                            end
                        end
                        local uT = getPart(char, "UpperTorso") or getPart(char, "Torso")
                        local lT = getPart(char, "LowerTorso")
                        if uT and lT then
                            drawL(d.Skeleton.Head, head.Position, uT.Position)
                            drawL(d.Skeleton.Torso, uT.Position, lT.Position)
                            local la = getPart(char, "LeftHand") or getPart(char, "Left Arm")
                            local ra = getPart(char, "RightHand") or getPart(char, "Right Arm")
                            local ll = getPart(char, "LeftFoot") or getPart(char, "Left Leg")
                            local rl = getPart(char, "RightFoot") or getPart(char, "Right Leg")
                            if la then drawL(d.Skeleton.L_Arm, uT.Position, la.Position) end
                            if ra then drawL(d.Skeleton.R_Arm, uT.Position, ra.Position) end
                            if ll then drawL(d.Skeleton.L_Leg, lT.Position, ll.Position) end
                            if rl then drawL(d.Skeleton.R_Leg, lT.Position, rl.Position) end
                        end
                    else
                        for _, l in pairs(d.Skeleton) do l.Visible = false end
                    end
                else
                    if drawEsp[p] then
                        drawEsp[p].Box.Visible = false
                        drawEsp[p].Name.Visible = false
                        drawEsp[p].Dist.Visible = false
                        for _, l in pairs(drawEsp[p].Skeleton) do l.Visible = false end
                    end
                end
            end
        end
    end

    if tick() - hitboxTick > 0.5 then
        hitboxTick = tick()
        if CFG.Aim.Hitbox then
            for _, p in ipairs(P:GetPlayers()) do
                if p ~= LP and p.Character then
                    local part = p.Character:FindFirstChild("Head")
                    if part then
                        if not oldHitboxSizes[part] then oldHitboxSizes[part] = part.Size end
                        part.Size = Vector3.new(20, 20, 20)
                        part.Transparency = 0.5
                        part.Color = Color3.fromRGB(255,0,0)
                        part.CanCollide = false
                    end
                end
            end
        else
            for p, s in pairs(oldHitboxSizes) do
                if p and p.Parent then p.Size = s end
            end
            oldHitboxSizes = {}
        end
    end

    if CFG.Aim.On then
        fovCircle.Visible = true
        fovCircle.Position = Vector2.new(C.ViewportSize.X / 2, C.ViewportSize.Y / 2)
        fovCircle.Radius = 150
        fovCircle.Color = cColor
        if CFG.Aim.Holding then
            local target = getTarget()
            if target then
                local predPos = target.Position + (target.Velocity * 0.16)
                if CFG.Aim.Silent then silentPos = predPos end
                local want = CFrame.lookAt(C.CFrame.Position, predPos)
                C.CFrame = C.CFrame:Lerp(want, 0.3)
                if CFG.Aim.AutoFire then
                    pcall(function()
                        VU:CaptureController()
                        VU:ClickButton1(Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2))
                    end)
                end
            else
                silentPos = nil
            end
        else
            silentPos = nil
        end
    else
        fovCircle.Visible = false
    end

    if CFG.Mov.Spin and LP.Character then
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(45), 0) end
    end

    local center = Vector2.new(C.ViewportSize.X / 2, C.ViewportSize.Y / 2)
    crossDot.Visible = true
    crossDot.Size = Vector2.new(2, 2)
    crossDot.Position = center - Vector2.new(1,1)
    crossDot.Color = cColor
    crossDot.Filled = true
    local lines = {
        {center - Vector2.new(0, 3), center - Vector2.new(0, 9)},
        {center + Vector2.new(0, 3), center + Vector2.new(0, 9)},
        {center - Vector2.new(3, 0), center - Vector2.new(9, 0)},
        {center + Vector2.new(3, 0), center + Vector2.new(9, 0)}
    }
    for i, l in ipairs(crossLines) do
        l.Visible = true
        l.From = lines[i][1]
        l.To = lines[i][2]
        l.Color = cColor
        l.Thickness = 1
    end
end)--// ZEDUX V15.1 - PARTE 4/4
local cMain = Instance.new("Frame", sec["Main"])
cMain.Size = UDim2.new(1, 0, 0, 0)
cMain.AutomaticSize = Enum.AutomaticSize.Y
cMain.BackgroundTransparency = 1

local wc = Instance.new("Frame", cMain)
wc.Size = UDim2.new(1, 0, 0, 80)
wc.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
wc.ZIndex = 4
Instance.new("UICorner", wc).CornerRadius = UDim.new(0, 8)
local ab = Instance.new("ImageLabel", wc)
ab.Size = UDim2.new(0, 60, 0, 60)
ab.Position = UDim2.new(0, 10, 0.5, -30)
ab.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ab.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=150&h=150"
Instance.new("UICorner", ab).CornerRadius = UDim.new(1, 0)
local wt = Instance.new("TextLabel", wc)
wt.Size = UDim2.new(1, -90, 0, 20)
wt.Position = UDim2.new(0, 80, 0, 20)
wt.BackgroundTransparency = 1
wt.Text = "Bem-vindo de volta,"
wt.TextColor3 = Color3.fromRGB(200, 200, 200)
wt.TextSize = 12
wt.Font = Enum.Font.Gotham
wt.TextXAlignment = Enum.TextXAlignment.Left
wt.ZIndex = 5
local nt = Instance.new("TextLabel", wc)
nt.Size = UDim2.new(1, -90, 0, 25)
nt.Position = UDim2.new(0, 80, 0, 38)
nt.BackgroundTransparency = 1
nt.Text = LP.DisplayName
nt.TextColor3 = Color3.fromRGB(255, 255, 255)
nt.TextSize = 18
nt.Font = Enum.Font.GothamBold
nt.TextXAlignment = Enum.TextXAlignment.Left
nt.ZIndex = 5

local cEsp = card("VISUAL (DRAWING)", sec["ESP"], Color3.fromRGB(220,220,220))
btT(cEsp, "ESP Box", function(v) CFG.Vis.Box = v end)
btT(cEsp, "Box Filled", function(v) CFG.Vis.Fill = v end)
btT(cEsp, "Skeleton", function(v) CFG.Vis.Skel = v end)
btT(cEsp, "Chams (Glow)", function(v) CFG.Vis.Chams = v end)
btT(cEsp, "Rainbow Mode", function(v) CFG.Vis.Rainbow = v end)
btT(cEsp, "Show Name", function(v) CFG.Vis.Name = v end)
btT(cEsp, "Show Distance", function(v) CFG.Vis.Dist = v end)

local cCb = card("AIMBOT PRO", sec["Combate"], Color3.fromRGB(255,100,100))
btT(cCb, "Aimbot (Hold E)", function(v) CFG.Aim.On = v end)
btT(cCb, "Silent Aim (Magic)", function(v) CFG.Aim.Silent = v end)
btT(cCb, "Auto Fire", function(v) CFG.Aim.AutoFire = v end)
btT(cCb, "Hitbox Expander", function(v) CFG.Aim.Hitbox = v end)

local cM = card("MOVIMENTO", sec["Mov"], Color3.fromRGB(100,255,100))
btT(cM, "Spinbot (Anti-Aim)", function(v) CFG.Mov.Spin = v end)
btT(cM, "Infinite Jump", function(v) CFG.Mov.InfJump = v end)
U.JumpRequest:Connect(function()
    if CFG.Mov.InfJump and LP.Character then
        local h = LP.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local cTele = card("TELECINESE", sec["Tele"], Color3.fromRGB(180,180,180))
bt(cTele, "🚗 Puxar Carro", function()
    local m = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not m then return end
    local c = nil
    for _, o in ipairs(workspace:GetChildren()) do
        if o:IsA("Model") then
            local v = false
            for _, d in ipairs(o:GetChildren()) do
                if d:IsA("VehicleSeat") then v = true break end
            end
            if v then
                local pr = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")
                if pr then c = pr break end
            end
        end
    end
    if not c then reg("Sem carro") return end
    local mod = c:FindFirstAncestorOfClass("Model")
    if not mod then return end
    for _, d in ipairs(mod:GetDescendants()) do
        if d:IsA("BasePart") and not d.Anchored then
            local b = Instance.new("BodyVelocity", d)
            b.Name = "ZEDUX_Pux"
            b.MaxForce = Vector3.new(5e5, 5e5, 5e5)
            task.spawn(function()
                while b.Parent do
                    local mh = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    if not mh then break end
                    local a = mh.Position + mh.CFrame.LookVector * 10 + Vector3.new(0, 3, 0)
                    local di = a - d.Position
                    b.Velocity = di.Magnitude < 8 and Vector3.zero or di.Unit * math.min(150, di.Magnitude * 3)
                    R.Heartbeat:Wait()
                end
            end)
            break
        end
    end
end)
bt(cTele, "🔓 Soltar Tudo", function()
    for _, o in ipairs(workspace:GetDescendants()) do
        local b1 = o:FindFirstChild("ZEDUX_Pux")
        local b2 = o:FindFirstChild("ZEDUX_Lan")
        if b1 then b1:Destroy() end
        if b2 then b2:Destroy() end
    end
end)

local cTr = card("TROLL", sec["Troll"], Color3.fromRGB(230,230,230))
bt(cTr, "💥 Fling de Blocos", function()
    local h = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not h then return end
    local pasta = Instance.new("Folder", workspace)
    pasta.Name = "ZEDUX_Fling"
    for i=1, 25 do
        local b = Instance.new("Part", pasta)
        b.Size = Vector3.new(6,6,6)
        b.Position = h.Position + Vector3.new(math.random(-10,10), 5, math.random(-10,10))
        b.Transparency = 0.5
        b.Material = Enum.Material.Neon
        pcall(function() b:SetNetworkOwner(LP) end)
        local bv = Instance.new("BodyVelocity", b)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Name = "ZEDUX_FL"
    end
    task.spawn(function()
        local t = tick()
        while tick() - t < 5 do
            for _, b in ipairs(pasta:GetChildren()) do
                local bv = b:FindFirstChild("ZEDUX_FL")
                if bv then
                    local dir = (h.Position + Vector3.new(0,0,0) - b.Position)
                    bv.Velocity = dir.Magnitude > 3 and dir.Unit * 2500 or Vector3.new(math.random(-2000,2000),2000,math.random(-2000,2000))
                end
            end
            R.Heartbeat:Wait()
        end
        pasta:Destroy()
    end)
end, true)
bt(cTr, "🌪️ Puxar TUDO", function()
    if not LP.Character then return end
    local mh = LP.Character:FindFirstChild("HumanoidRootPart")
    if not mh then return end
    local obj = {}
    for _, p in ipairs(workspace:GetDescendants()) do
        if #obj >= 50 then break end
        if p:IsA("BasePart") and not p.Anchored and not p:IsDescendantOf(LP.Character) then
            table.insert(obj, p)
        end
    end
    for _, p in ipairs(obj) do
        pcall(function()
            p:SetNetworkOwner(LP)
            local bv = Instance.new("BodyVelocity", p)
            bv.Name = "ZEDUX_Pull"
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            task.spawn(function()
                while bv.Parent do
                    local aim = mh.Position + mh.CFrame.LookVector * 5
                    bv.Velocity = (aim - p.Position).Unit * 150
                    R.Heartbeat:Wait()
                end
            end)
        end)
    end
    task.delay(4, function()
        for _, p in ipairs(obj) do
            local b = p:FindFirstChild("ZEDUX_Pull")
            if b then b:Destroy() end
        end
    end)
end)

local cPer = card("PERSONALIZAÇÃO", sec["Personalizacao"], Color3.fromRGB(180,180,180))
bt(cPer, "👻 Transparência", function()
    local t = w.BackgroundTransparency + 0.1
    if t > 0.9 then t = 0 end
    w.BackgroundTransparency = t
end)

local cCfg = card("INTERFACE", sec["Config"], Color3.fromRGB(150,150,150))
bt(cCfg, "🔄 Rejoin", function() game:GetService("TeleportService"):Teleport(game.PlaceId, LP) end)
bt(cCfg, "🗑️ Fechar Painel", function() gui:Destroy() end, true)

if AD then
    local cAdm = card("ADMIN", sec["Adm"], Color3.fromRGB(255,255,255))
    bt(cAdm, "Aprovar Player", function() reg("Aprovado") end)
    local cKeys = card("KEYS", sec["Keys"], Color3.fromRGB(230,230,230))
    bt(cKeys, "Gerar Key VIP", function()
        local k = "ZEDUX-HUB-"..math.random(1000,9999)
        KEYS_VALIDAS[k] = true
        reg("Key: "..k)
    end)
    local cLog = card("LOGS", sec["Log"], Color3.fromRGB(200,200,200))
    local sf = Instance.new("ScrollingFrame", cLog)
    sf.Size = UDim2.new(1, 0, 0, 150)
    sf.BackgroundColor3 = Color3.fromRGB(15,15,15)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UICorner", sf).CornerRadius = UDim.new(0,4)
    for _, txt in ipairs(lg) do
        local l = Instance.new("TextLabel", sf)
        l.Size = UDim2.new(1,0,0,18)
        l.BackgroundTransparency = 1
        l.Text = "["..txt.h.."] "..txt.a
        l.TextColor3 = Color3.fromRGB(200,200,200)
        l.TextSize = 9
        l.Font = Enum.Font.Code
        l.TextXAlignment = Enum.TextXAlignment.Left
    end
    end
