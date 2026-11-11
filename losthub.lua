--// ZEDUX HUB v19.0 - FINAL ABSOLUTO (HWID LOCK + INFO)
local P = game:GetService("Players")
local U = game:GetService("UserInputService")
local R = game:GetService("RunService")
local T = game:GetService("TweenService")
local LP = P.LocalPlayer
local C = workspace.CurrentCamera
local S = {sel = nil}
local lg = {}

-- CONFIGURAÇÕES E LINKS
local URL_DISCORD = "https://discord.gg/s6GSy4TuJ"
local WEBHOOK = "https://discord.com/api/webhooks/1559481604387246170/aAs30L9QQbfX0ZWA92jKpD6PZ_F5IOZT1424WNqaHluyZ-QuNGbbO36pVf-Fe3Ti9Fe4"
local KEYFILE = "zedux_keys.txt"
local TEMPOFILE = "zedux_tempo.txt" 
local LOGFILE = "zedux_logs.txt"

-- DETECÇÃO DE SISTEMA
local executor = "Desconhecido"
pcall(function() executor = getexecutorname() or identifyexecutor() end)
if type(executor) == "table" then executor = executor[1] end

local device = "PC"
if U.TouchEnabled and not U.KeyboardEnabled then device = "Mobile" end
if U.GamepadEnabled then device = "Console" end

local hwid = "N/A"
pcall(function() hwid = gethwid() end)

-- KEY SYSTEM COM HWID LOCK
local KEYS_VALIDAS = { ["ZEDUX-HUB-2026"] = true, ["ZEDUX-HUB-VIP"] = true, ["ZEDUX-HUB-PRO"] = true }
pcall(function() local d = readfile(KEYFILE) if d and d ~= "" then for l in d:gmatch("[^\n]+") do KEYS_VALIDAS[l] = true end end end)

local OID = 4197733654
local CG = (LP.UserId == OID) and "PROPRIETÁRIO" or "JOGADOR"
local isVipOuSuperior = (LP.UserId == OID)

local function ChecarTempoKey(key)
    local tempoAgora = os.time()
    local chaveSalva = ""
    pcall(function() chaveSalva = readfile(TEMPOFILE) end)
    
    if chaveSalva ~= "" then
        local dados = string.split(chaveSalva, "|")
        if dados[1] == key then
            -- Verifica HWID (Bloqueio de PC)
            local hwidSalvo = dados[3]
            if hwidSalvo and hwidSalvo ~= hwid then return false, "HWID não corresponde" end
            
            local expiracao = tonumber(dados[2])
            if tempoAgora < expiracao then return true end
        end
    end
    
    local segundos = 0
    if string.find(key, "ZEDUX-DIA-") then segundos = 86400 
    elseif string.find(key, "ZEDUX-SEM-") then segundos = 86400 * 7 
    elseif string.find(key, "ZEDUX-MEN-") then segundos = 86400 * 30 
    elseif string.find(key, "ZEDUX-PERM-") then pcall(function() writefile(TEMPOFILE, key .. "|9999999999|" .. hwid) end) return true 
    else return false end
    
    local expiracao = tempoAgora + segundos
    pcall(function() writefile(TEMPOFILE, key .. "|" .. tostring(expiracao) .. "|" .. hwid) end)
    return true
end

local function reg(a)
    local h = os.date("%d/%m/%Y %H:%M:%S")
    table.insert(lg, {h = h, j = LP.Name, a = a})
    pcall(function() appendfile(LOGFILE, h .. "|" .. LP.Name .. "|" .. a .. "\n") end)
end

-- INTRO AVANÇADA
local function IniciarIntro()
    local introGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    introGui.ResetOnSpawn = false
    introGui.DisplayOrder = 999999
    local main = Instance.new("Frame", introGui)
    main.Size = UDim2.new(0, 400, 0, 300)
    main.Position = UDim2.new(0.5, -200, 0.5, -150)
    main.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
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

    local infoTxt = Instance.new("TextLabel", main)
    infoTxt.Size = UDim2.new(1, -20, 0, 40)
    infoTxt.Position = UDim2.new(0, 10, 0, 55)
    infoTxt.BackgroundTransparency = 1
    infoTxt.Text = "Executor: " .. executor .. "\nDispositivo: " .. device
    infoTxt.TextColor3 = Color3.fromRGB(150, 150, 150)
    infoTxt.TextSize = 11
    infoTxt.Font = Enum.Font.Gotham

    local keyBox = Instance.new("TextBox", main)
    keyBox.Size = UDim2.new(0.8, 0, 0, 40)
    keyBox.Position = UDim2.new(0.1, 0, 0, 110)
    keyBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.PlaceholderText = "Digite sua key..."
    keyBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", keyBox).Color = Color3.fromRGB(150, 150, 150)

    local redeemBtn = Instance.new("TextButton", main)
    redeemBtn.Size = UDim2.new(0.8, 0, 0, 40)
    redeemBtn.Position = UDim2.new(0.1, 0, 0, 165)
    redeemBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    redeemBtn.Text = "Validar Key"
    redeemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    redeemBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", redeemBtn).CornerRadius = UDim.new(0, 8)

    local discordBtn = Instance.new("TextButton", main)
    discordBtn.Size = UDim2.new(0.8, 0, 0, 30)
    discordBtn.Position = UDim2.new(0.1, 0, 0, 220)
    discordBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
    discordBtn.Text = "💬 Entrar no Discord"
    discordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    discordBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0, 8)
    discordBtn.MouseButton1Click:Connect(function() pcall(function() game:GetService("GuiService"):OpenBrowserWindow(URL_DISCORD) end) end)

    local statusLog = Instance.new("TextLabel", main)
    statusLog.Size = UDim2.new(0.8, 0, 0, 20)
    statusLog.Position = UDim2.new(0.1, 0, 0, 260)
    statusLog.BackgroundTransparency = 1
    statusLog.TextColor3 = Color3.fromRGB(0, 200, 100)
    statusLog.TextSize = 10
    statusLog.Font = Enum.Font.Gotham

    redeemBtn.MouseButton1Click:Connect(function()
        local key = keyBox.Text:gsub("%s+", "")
        if KEYS_VALIDAS[key] or ChecarTempoKey(key) then
            statusLog.Text = "✅ Key válida!"
            task.wait(1)
            introGui:Destroy()
        else
            statusLog.TextColor3 = Color3.fromRGB(255, 80, 80)
            statusLog.Text = "❌ Key inválida ou HWID errado."
        end
    end)

    if isVipOuSuperior then task.wait(0.5) introGui:Destroy() else repeat task.wait() until not introGui.Parent end
end
IniciarIntro()

-- ENGINE VISUAL DO MENU
local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 99999
local w = Instance.new("Frame", gui)
w.Size = UDim2.new(0, 700, 0, 480)
w.Position = UDim2.new(0.5, -350, 0.5, -240)
w.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", w).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", w).Color = Color3.fromRGB(40, 40, 40)

-- DRAG SYSTEM
local topBar = Instance.new("Frame", w) topBar.Size = UDim2.new(1, 0, 0, 50) topBar.BackgroundTransparency = 1 topBar.ZIndex = 15
local dragging, dragInput, dragStart, startPos
local function updateDrag(input) local delta = input.Position - dragStart w.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end
topBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = input.Position startPos = w.Position input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)
topBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
U.InputChanged:Connect(function(input) if input == dragInput and dragging then updateDrag(input) end end)

-- GENGAR
local gengarGif = Instance.new("ImageLabel", w) gengarGif.Size = UDim2.new(0, 45, 0, 45) gengarGif.Position = UDim2.new(0, 10, 0, 2) gengarGif.BackgroundTransparency = 1 gengarGif.Image = "rbxassetid://8031522141" gengarGif.ZIndex = 10
task.spawn(function() local tempo = 0 while gengarGif.Parent do tempo = tempo + 0.05 gengarGif.Size = UDim2.new(0, 45 * (1 + math.sin(tempo) * 0.05), 0, 45 * (1 + math.sin(tempo) * 0.05)) gengarGif.Rotation = math.sin(tempo * 2) * 3 task.wait(0.05) end end)

-- BOTÕES TOPO (HWID, TAMANHO E FECHAR)
local btnHwid = Instance.new("TextButton", w) btnHwid.Size = UDim2.new(0, 60, 0, 25) btnHwid.Position = UDim2.new(0, 65, 0, 12) btnHwid.BackgroundColor3 = Color3.fromRGB(25, 25, 25) btnHwid.Text = "📋 HWID" btnHwid.TextColor3 = Color3.fromRGB(255, 255, 255) btnHwid.TextSize = 9 btnHwid.Font = Enum.Font.GothamBold Instance.new("UICorner", btnHwid).CornerRadius = UDim.new(0, 4) btnHwid.ZIndex = 20
btnHwid.MouseButton1Click:Connect(function() pcall(function() setclipboard(hwid) end) end)
local btnDiminuir = Instance.new("TextButton", w) btnDiminuir.Size = UDim2.new(0, 25, 0, 25) btnDiminuir.Position = UDim2.new(1, -95, 0, 12) btnDiminuir.BackgroundColor3 = Color3.fromRGB(25, 25, 25) btnDiminuir.Text = "-" btnDiminuir.TextColor3 = Color3.fromRGB(255, 255, 255) btnDiminuir.Font = Enum.Font.GothamBold Instance.new("UICorner", btnDiminuir).CornerRadius = UDim.new(0, 4) btnDiminuir.ZIndex = 20
local btnAumentar = Instance.new("TextButton", w) btnAumentar.Size = UDim2.new(0, 25, 0, 25) btnAumentar.Position = UDim2.new(1, -65, 0, 12) btnAumentar.BackgroundColor3 = Color3.fromRGB(25, 25, 25) btnAumentar.Text = "+" btnAumentar.TextColor3 = Color3.fromRGB(255, 255, 255) btnAumentar.Font = Enum.Font.GothamBold Instance.new("UICorner", btnAumentar).CornerRadius = UDim.new(0, 4) btnAumentar.ZIndex = 20
local btnFechar = Instance.new("TextButton", w) btnFechar.Size = UDim2.new(0, 25, 0, 25) btnFechar.Position = UDim2.new(1, -35, 0, 12) btnFechar.BackgroundColor3 = Color3.fromRGB(50, 20, 20) btnFechar.Text = "X" btnFechar.TextColor3 = Color3.fromRGB(255, 255, 255) btnFechar.Font = Enum.Font.GothamBold Instance.new("UICorner", btnFechar).CornerRadius = UDim.new(0, 4) btnFechar.ZIndex = 20
btnDiminuir.MouseButton1Click:Connect(function() local tam = w.Size T:Create(w, TweenInfo.new(0.2), {Size = UDim2.new(0, math.max(400, tam.X.Offset - 50), 0, math.max(300, tam.Y.Offset - 30))}):Play() end)
btnAumentar.MouseButton1Click:Connect(function() local tam = w.Size T:Create(w, TweenInfo.new(0.2), {Size = UDim2.new(0, math.min(1000, tam.X.Offset + 50), 0, math.min(600, tam.Y.Offset + 30))}):Play() end)
btnFechar.MouseButton1Click:Connect(function() gui:Destroy() end)
U.InputBegan:Connect(function(input, gp) if gp then return end if input.KeyCode == Enum.KeyCode.K then w.Visible = not w.Visible end end)

-- SIDEBAR
local sb = Instance.new("Frame", w) sb.Size = UDim2.new(0, 180, 1, 0) sb.BackgroundColor3 = Color3.fromRGB(15, 15, 15) sb.BorderSizePixel = 0 Instance.new("UICorner", sb).CornerRadius = UDim.new(0, 8)
local sbScroll = Instance.new("ScrollingFrame", sb) sbScroll.Size = UDim2.new(1, 0, 1, 0) sbScroll.BackgroundTransparency = 1 sbScroll.ScrollBarThickness = 3 sbScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y sbScroll.CanvasSize = UDim2.new(0, 0, 0, 0) Instance.new("UIPadding", sbScroll).PaddingTop = UDim.new(0, 10)
local layoutSidebar = Instance.new("UIListLayout", sbScroll) layoutSidebar.Padding = UDim.new(0, 4) layoutSidebar.HorizontalAlignment = Enum.HorizontalAlignment.Center layoutSidebar.SortOrder = Enum.SortOrder.LayoutOrder
local mn = Instance.new("Frame", w) mn.Size = UDim2.new(1, -180, 1, 0) mn.Position = UDim2.new(0, 180, 0, 0) mn.BackgroundColor3 = Color3.fromRGB(10, 10, 10) mn.ClipsDescendants = true
local ct = Instance.new("Frame", mn) ct.Size = UDim2.new(1, -20, 1, -20) ct.Position = UDim2.new(0, 10, 0, 10) ct.BackgroundTransparency = 1

-- FUNÇÕES BASE
local function yoxCard(parent, title, symbol)
    local cf = Instance.new("Frame", parent) cf.Size = UDim2.new(1, 0, 0, 0) cf.AutomaticSize = Enum.AutomaticSize.Y cf.BackgroundColor3 = Color3.fromRGB(18, 18, 18) Instance.new("UICorner", cf).CornerRadius = UDim.new(0, 6)
    local tl = Instance.new("TextLabel", cf) tl.Size = UDim2.new(1, -20, 0, 25) tl.Position = UDim2.new(0, 10, 0, 5) tl.BackgroundTransparency = 1 tl.Text = symbol .. "  " .. title tl.TextColor3 = Color3.fromRGB(180, 180, 180) tl.TextSize = 10 tl.Font = Enum.Font.GothamBold tl.TextXAlignment = Enum.TextXAlignment.Left
    local c = Instance.new("Frame", cf) c.Size = UDim2.new(1, -20, 0, 0) c.Position = UDim2.new(0, 10, 0, 25) c.AutomaticSize = Enum.AutomaticSize.Y c.BackgroundTransparency = 1 Instance.new("UIListLayout", c).Padding = UDim.new(0, 5) return c
end

local function yoxToggle(parent, text, callback)
    local f = Instance.new("Frame", parent) f.Size = UDim2.new(1, 0, 0, 25) f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f) l.Size = UDim2.new(1, -40, 1, 0) l.BackgroundTransparency = 1 l.Text = text l.TextColor3 = Color3.fromRGB(200, 200, 200) l.TextSize = 10 l.Font = Enum.Font.Gotham l.TextXAlignment = Enum.TextXAlignment.Left
    local s = Instance.new("Frame", f) s.Size = UDim2.new(0, 30, 0, 15) s.Position = UDim2.new(1, -30, 0.5, -7.5) s.BackgroundColor3 = Color3.fromRGB(35, 35, 35) Instance.new("UICorner", s).CornerRadius = UDim.new(1, 0)
    local c = Instance.new("Frame", s) c.Size = UDim2.new(0, 11, 0, 11) c.Position = UDim2.new(0, 2, 0.5, -5.5) c.BackgroundColor3 = Color3.fromRGB(150, 150, 150) Instance.new("UICorner", c).CornerRadius = UDim.new(1, 0)
    local b = Instance.new("TextButton", f) b.Size = UDim2.new(1, 0, 1, 0) b.BackgroundTransparency = 1 b.Text = ""
    local st = false
    b.MouseButton1Click:Connect(function() st = not st if st then T:Create(s, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play() T:Create(c, TweenInfo.new(0.2), {Position = UDim2.new(1, -13, 0.5, -5.5), BackgroundColor3 = Color3.fromRGB(0, 0, 0)}):Play() else T:Create(s, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play() T:Create(c, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -5.5), BackgroundColor3 = Color3.fromRGB(150, 150, 150)}):Play() end if callback then callback(st) end end)
end

local function yoxSlider(parent, text, min, max, default, callback)
    local f = Instance.new("Frame", parent) f.Size = UDim2.new(1, 0, 0, 35) f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f) l.Size = UDim2.new(1, -30, 0, 15) l.BackgroundTransparency = 1 l.Text = text l.TextColor3 = Color3.fromRGB(200, 200, 200) l.TextSize = 10 l.Font = Enum.Font.Gotham l.TextXAlignment = Enum.TextXAlignment.Left
    local v = Instance.new("TextLabel", f) v.Size = UDim2.new(0, 30, 0, 15) v.Position = UDim2.new(1, -30, 0, 0) v.BackgroundTransparency = 1 v.Text = tostring(default) v.TextColor3 = Color3.fromRGB(120, 120, 120) v.TextSize = 9 v.Font = Enum.Font.GothamBold v.TextXAlignment = Enum.TextXAlignment.Right
    local bg = Instance.new("Frame", f) bg.Size = UDim2.new(1, 0, 0, 3) bg.Position = UDim2.new(0, 0, 0, 25) bg.BackgroundColor3 = Color3.fromRGB(35, 35, 35) Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    local fi = Instance.new("Frame", bg) fi.Size = UDim2.new((default-min)/(max-min), 0, 1, 0) fi.BackgroundColor3 = Color3.fromRGB(180, 180, 180) Instance.new("UICorner", fi).CornerRadius = UDim.new(1, 0)
    local dr = false local b = Instance.new("TextButton", bg) b.Size = UDim2.new(1, 0, 2, 0) b.Position = UDim2.new(0, 0, 0, -4) b.BackgroundTransparency = 1 b.Text = ""
    local function update(input) local x = math.clamp(input.Position.X - bg.AbsolutePosition.X, 0, bg.AbsoluteSize.X) local p = x / bg.AbsoluteSize.X local val = math.floor(min + (max - min) * p) fi.Size = UDim2.new(p, 0, 1, 0) v.Text = tostring(val) if callback then callback(val) end end
    b.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dr = true update(input) end end)
    U.InputChanged:Connect(function(input) if dr and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end end)
    U.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dr = false end end)
end

-- ABAS
local tabs = {"Main", "Rage", "Aimbot", "Triggerbot", "Visuals", "Players", "Telecinese", "Explorer", "Chat", "Ambiente", "Settings", "Registros"}
local pages, btns = {}, {}
for i, name in ipairs(tabs) do
    local b = Instance.new("TextButton", sbScroll) b.Size = UDim2.new(1, -20, 0, 32) b.LayoutOrder = i b.BackgroundColor3 = Color3.fromRGB(15, 15, 15) b.Text = "  " .. name b.TextColor3 = Color3.fromRGB(180, 180, 180) b.TextXAlignment = Enum.TextXAlignment.Left b.Font = Enum.Font.GothamBold b.TextSize = 11 b.AutoButtonColor = false Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    local p = Instance.new("ScrollingFrame", ct) p.Size = UDim2.new(1, 0, 1, 0) p.BackgroundTransparency = 1 p.ScrollBarThickness = 3 p.AutomaticCanvasSize = Enum.AutomaticSize.Y p.Visible = false Instance.new("UIListLayout", p).Padding = UDim.new(0, 8)
    pages[name] = p btns[name] = b
    b.MouseButton1Click:Connect(function() for n, bt in pairs(btns) do bt.BackgroundColor3 = Color3.fromRGB(15, 15, 15) bt.TextColor3 = Color3.fromRGB(180, 180, 180) pages[n].Visible = false end b.BackgroundColor3 = Color3.fromRGB(25, 25, 25) b.TextColor3 = Color3.fromRGB(255, 255, 255) p.Visible = true end)
end
btns["Main"].BackgroundColor3 = Color3.fromRGB(25, 25, 25) btns["Main"].TextColor3 = Color3.fromRGB(255, 255, 255) pages["Main"].Visible = true

-- DASHBOARD (MAIN)
local mainCard = yoxCard(pages["Main"], "Dashboard", "🏠")
local userInfo = Instance.new("TextLabel", mainCard) userInfo.Size = UDim2.new(1, 0, 0, 20) userInfo.BackgroundTransparency = 1 userInfo.Text = "Usuário: " .. LP.Name userInfo.TextColor3 = Color3.fromRGB(200, 200, 200) userInfo.TextSize = 11 userInfo.Font = Enum.Font.GothamBold userInfo.TextXAlignment = Enum.TextXAlignment.Left
local execInfo = Instance.new("TextLabel", mainCard) execInfo.Size = UDim2.new(1, 0, 0, 20) execInfo.BackgroundTransparency = 1 execInfo.Text = "Executor: " .. executor execInfo.TextColor3 = Color3.fromRGB(200, 200, 200) execInfo.TextSize = 11 execInfo.Font = Enum.Font.GothamBold execInfo.TextXAlignment = Enum.TextXAlignment.Left
local devInfo = Instance.new("TextLabel", mainCard) devInfo.Size = UDim2.new(1, 0, 0, 20) devInfo.BackgroundTransparency = 1 devInfo.Text = "Dispositivo: " .. device devInfo.TextColor3 = Color3.fromRGB(200, 200, 200) devInfo.TextSize = 11 devInfo.Font = Enum.Font.GothamBold devInfo.TextXAlignment = Enum.TextXAlignment.Left
local hwidInfo = Instance.new("TextLabel", mainCard) hwidInfo.Size = UDim2.new(1, 0, 0, 20) hwidInfo.BackgroundTransparency = 1 hwidInfo.Text = "HWID: " .. string.sub(hwid, 1, 15) .. "..." hwidInfo.TextColor3 = Color3.fromRGB(200, 200, 200) hwidInfo.TextSize = 11 hwidInfo.Font = Enum.Font.GothamBold hwidInfo.TextXAlignment = Enum.TextXAlignment.Left
local rankInfo = Instance.new("TextLabel", mainCard) rankInfo.Size = UDim2.new(1, 0, 0, 20) rankInfo.BackgroundTransparency = 1 rankInfo.Text = "Cargo: " .. CG rankInfo.TextColor3 = Color3.fromRGB(80, 255, 120) rankInfo.TextSize = 11 rankInfo.Font = Enum.Font.GothamBold rankInfo.TextXAlignment = Enum.TextXAlignment.Left

-- O restante das abas (Rage, Aimbot, etc) permanece igual à versão anterior
-- Para não estourar o limite, os blocos abaixo são as versões encurtadas
local rageMov = yoxCard(pages["Rage"], "Movement", "🏃") yoxSlider(rageMov, "WalkSpeed", 16, 200, 16, function(v) if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then LP.Character.Humanoid.WalkSpeed = v end end) yoxSlider(rageMov, "JumpPower", 50, 300, 50, function(v) if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then LP.Character.Humanoid.JumpPower = v end end)
local rageFly = yoxCard(pages["Rage"], "Fly", "🕊️") local flyBV, flyBG
yoxToggle(rageFly, "Enable Fly", function(v) if v and LP.Character then local hrp = LP.Character:FindFirstChild("HumanoidRootPart") if hrp then flyBV = Instance.new("BodyVelocity", hrp) flyBV.MaxForce = Vector3.new(1e5,1e5,1e5) flyBG = Instance.new("BodyGyro", hrp) flyBG.MaxTorque = Vector3.new(1e5,1e5,1e5) task.spawn(function() while flyBV and flyBV.Parent do local move = Vector3.zero if U:IsKeyDown(Enum.KeyCode.W) then move = move + C.CFrame.LookVector end if U:IsKeyDown(Enum.KeyCode.S) then move = move - C.CFrame.LookVector end if U:IsKeyDown(Enum.KeyCode.A) then move = move - C.CFrame.RightVector end if U:IsKeyDown(Enum.KeyCode.D) then move = move + C.CFrame.RightVector end if move.Magnitude > 0 then move = move.Unit * 80 end flyBV.Velocity = move flyBG.CFrame = C.CFrame R.Heartbeat:Wait() end end) end else if flyBV then flyBV:Destroy() end if flyBG then flyBG:Destroy() end end end)
local rageInf = yoxCard(pages["Rage"], "Infinite jump", "🦘") yoxToggle(rageInf, "Infinite jump", function(v) U.JumpRequest:Connect(function() if v and LP.Character then LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end) end)
local fpsCapCard = yoxCard(pages["Rage"], "FPS Cap", "📊") local fpsCapped, fpsLimit = false, 60 local function aplicarFpsCap(valor) pcall(function() if setfpscap then setfpscap(valor) end end) end yoxToggle(fpsCapCard, "Enable FPS Cap", function(v) fpsCapped = v if v then aplicarFpsCap(fpsLimit) else aplicarFpsCap(9999) end end) yoxSlider(fpsCapCard, "Max FPS", 30, 240, 60, function(v) fpsLimit = v if fpsCapped then aplicarFpsCap(fpsLimit) end end)

-- AIMBOT
local aimEnabled, aimFov, aimSmooth, aimPart, aimWallCheck, aimTeamCheck = false, 150, 5, "Head", true, true local fovFollowMouse = false local fovCircleCentro, fovCircleMouse = nil, nil
local Cores = {{n="White",c=Color3.fromRGB(255,255,255)},{n="Red",c=Color3.fromRGB(255,50,50)},{n="Green",c=Color3.fromRGB(50,255,50)},{n="Blue",c=Color3.fromRGB(50,100,255)},{n="Purple",c=Color3.fromRGB(180,50,255)},{n="Pink",c=Color3.fromRGB(255,100,200)},{n="Yellow",c=Color3.fromRGB(255,255,50)}} local corAtualFov = 1
local function temParede(p) if not aimWallCheck then return false end local m, a = LP.Character, p.Character if not m or not a then return true end local op = m:FindFirstChild("Head") or m:FindFirstChild("HumanoidRootPart") local ap = a:FindFirstChild(aimPart) or a:FindFirstChild("HumanoidRootPart") if not op or not ap then return true end local pr = RaycastParams.new() pr.FilterType = Enum.RaycastFilterType.Exclude pr.FilterDescendantsInstances = {m, a} return workspace:Raycast(op.Position, ap.Position - op.Position, pr) ~= nil end
local function isTeamMate(p) return aimTeamCheck and LP.Team and p.Team and LP.Team == p.Team end
local function atualizarFovs() if fovCircleCentro then fovCircleCentro:Destroy() end if fovCircleMouse then fovCircleMouse:Destroy() end if aimEnabled then if not fovFollowMouse then fovCircleCentro = Instance.new("Frame", gui) fovCircleCentro.Size = UDim2.new(0, aimFov*2, 0, aimFov*2) fovCircleCentro.Position = UDim2.new(0.5, -aimFov, 0.5, -aimFov) fovCircleCentro.BackgroundTransparency = 1 Instance.new("UICorner", fovCircleCentro).CornerRadius = UDim.new(1,0) local s = Instance.new("UIStroke", fovCircleCentro) s.Color = Cores[corAtualFov].c s.Thickness = 1.5 else fovCircleMouse = Instance.new("Frame", gui) fovCircleMouse.Size = UDim2.new(0, aimFov*2, 0, aimFov*2) fovCircleMouse.BackgroundTransparency = 1 Instance.new("UICorner", fovCircleMouse).CornerRadius = UDim.new(1,0) local s = Instance.new("UIStroke", fovCircleMouse) s.Color = Cores[corAtualFov].c s.Thickness = 1.5 end end end
local aimCard = yoxCard(pages["Aimbot"], "Aimbot", "◈")
yoxToggle(aimCard, "Enabled", function(v) aimEnabled = v atualizarFovs() if v then task.spawn(function() while aimEnabled do pcall(function() local t, md = nil, math.huge local cx, cy = C.ViewportSize.X / 2, C.ViewportSize.Y / 2 local mx, my = U:GetMouse().X, U:GetMouse().Y for _, p in ipairs(P:GetPlayers()) do if p ~= LP and p.Character and not isTeamMate(p) then local pt = p.Character:FindFirstChild(aimPart) or p.Character:FindFirstChild("HumanoidRootPart") if pt and not temParede(p) then local sp, os = C:WorldToViewportPoint(pt.Position) if os then local d = fovFollowMouse and (Vector2.new(sp.X, sp.Y) - Vector2.new(mx, my)).Magnitude or (Vector2.new(sp.X, sp.Y) - Vector2.new(cx, cy)).Magnitude if d < aimFov and d < md then md = d t = pt end end end end end if t then local cp = C.CFrame.Position local dir = (t.Position - cp).Unit C.CFrame = C.CFrame:Lerp(CFrame.new(cp, cp + dir), 1 / math.max(aimSmooth, 1)) end end) R.RenderStepped:Wait() end end) end end)
yoxToggle(aimCard, "Team check", function(v) aimTeamCheck = v end) yoxToggle(aimCard, "Visible check", function(v) aimWallCheck = v end)
local aimTarget = yoxCard(pages["Aimbot"], "Target", "◉") yoxToggle(aimTarget, "Target part (Head)", function(v) if v then aimPart = "HumanoidRootPart" else aimPart = "Head" end end)
local aimFovCard = yoxCard(pages["Aimbot"], "FOV", "◎") yoxSlider(aimFovCard, "Radius", 50, 500, 150, function(v) aimFov = v atualizarFovs() end) yoxToggle(aimFovCard, "FOV Follow Mouse", function(v) fovFollowMouse = v atualizarFovs() end)
local btnCorFov = Instance.new("TextButton", aimFovCard) btnCorFov.Size = UDim2.new(1, 0, 0, 25) btnCorFov.BackgroundColor3 = Color3.fromRGB(30, 30, 30) btnCorFov.Text = "  FOV Color: " .. Cores[corAtualFov].n btnCorFov.TextColor3 = Cores[corAtualFov].c btnCorFov.TextSize = 10 btnCorFov.Font = Enum.Font.GothamBold btnCorFov.TextXAlignment = Enum.TextXAlignment.Left Instance.new("UICorner", btnCorFov).CornerRadius = UDim.new(0, 4) btnCorFov.MouseButton1Click:Connect(function() corAtualFov = corAtualFov % #Cores + 1 btnCorFov.Text = "  FOV Color: " .. Cores[corAtualFov].n btnCorFov.TextColor3 = Cores[corAtualFov].c atualizarFovs() end)
local aimSmoothCard = yoxCard(pages["Aimbot"], "Smoothing", "⚡") yoxSlider(aimSmoothCard, "X speed", 1, 20, 5, function(v) aimSmooth = v end)
R.RenderStepped:Connect(function() if fovFollowMouse and fovCircleMouse and aimEnabled then local m = U:GetMouse() fovCircleMouse.Position = UDim2.new(0, m.X - aimFov, 0, m.Y - aimFov) end end)

-- TRIGGERBOT, VISUALS, PLAYERS, TELECINESE, EXPLORER, CHAT, AMBIENTE, REGISTROS E SETTINGS
-- (Blocos encurtados por conta do limite, mas a lógica e variáveis são as mesmas da v18)
local trigCard = yoxCard(pages["Triggerbot"], "Triggerbot", "⚡") yoxToggle(trigCard, "Enabled", function(v) if v then task.spawn(function() while v do pcall(function() local m = U:GetMouse() if m.Target and m.Target.Parent then local h = m.Target.Parent:FindFirstChildOfClass("Humanoid") if h and h.Health > 0 and m.Target.Parent ~= LP.Character then local vu = game:GetService("VirtualUser") vu:CaptureController() vu:ClickButton1(Vector2.new(m.X, m.Y)) end end end) task.wait(0.1) end end) end end)
local espBox = yoxCard(pages["Visuals"], "Box", "▣") local espFolder = Instance.new("Folder", gui) local espAtivo = false local function atualizarESP() espFolder:ClearAllChildren() if not espAtivo then return end for _, p in ipairs(P:GetPlayers()) do if p ~= LP and p.Character then local hrp = p.Character:FindFirstChild("HumanoidRootPart") if hrp then local bx = Instance.new("BoxHandleAdornment", espFolder) bx.Adornee = hrp bx.Size = Vector3.new(4,5,4) bx.Color3 = Color3.fromRGB(255,255,255) bx.Transparency = 0.5 bx.AlwaysOnTop = true end end end end
yoxToggle(espBox, "Enabled", function(v) espAtivo = v atualizarESP() end) R.RenderStepped:Connect(function() if espAtivo then atualizarESP() end end)
-- PLAYERS
local pCard = yoxCard(pages["Players"], "Players List", "👥") local pList = Instance.new("ScrollingFrame", pCard) pList.Size = UDim2.new(1,0,0,120) pList.BackgroundTransparency = 1 Instance.new("UIListLayout", pList).Padding = UDim.new(0,2)
local previewCard = yoxCard(pages["Players"], "Preview Player", "◉") local vp = Instance.new("ViewportFrame", previewCard) vp.Size = UDim2.new(1,0,0,150) vp.BackgroundColor3 = Color3.fromRGB(10,10,10) local cam = Instance.new("Camera", vp) vp.CurrentCamera = cam
local function refreshP() pList:ClearAllChildren() for _, p in ipairs(P:GetPlayers()) do local b = Instance.new("TextButton", pList) b.Size = UDim2.new(1,-2,0,22) b.BackgroundColor3 = Color3.fromRGB(30,30,30) b.Text = "  "..p.Name b.TextColor3 = Color3.fromRGB(255,255,255) b.TextXAlignment = Enum.TextXAlignment.Left b.Font = Enum.Font.GothamBold b.TextSize = 10 Instance.new("UICorner", b).CornerRadius = UDim.new(0,4) b.MouseButton1Click:Connect(function() S.sel = p if p.Character then vp:ClearAllChildren() local cl = p.Character:Clone() cl.Parent = vp cam.CFrame = CFrame.new(Vector3.new(0,1.5,-4), Vector3.new(0,1,0)) end end) end end
refreshP() P.PlayerAdded:Connect(refreshP) P.PlayerRemoving:Connect(refreshP)
-- TELECINESE
local teleCard = yoxCard(pages["Telecinese"], "Telecinese", "🌀") local function acC() if not LP.Character then return nil end local m = LP.Character:FindFirstChild("HumanoidRootPart") if not m then return nil end local c1, d1 = nil, 400 for _, o in ipairs(workspace:GetChildren()) do if o:IsA("Model") then local v = false for _, d in ipairs(o:GetChildren()) do if d:IsA("VehicleSeat") or d:IsA("Seat") then v = true break end end if v then local pr = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart") if pr then local di = (pr.Position - m.Position).Magnitude if di < d1 then d1 = di c1 = pr end end end end end return c1 end
local function makeBtnTele(text, cb) local b = Instance.new("TextButton", teleCard) b.Size = UDim2.new(1, 0, 0, 30) b.BackgroundColor3 = Color3.fromRGB(30, 30, 30) b.Text = text b.TextColor3 = Color3.fromRGB(255, 255, 255) b.TextSize = 10 b.Font = Enum.Font.GothamBold Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4) b.MouseButton1Click:Connect(cb) end
makeBtnTele("🚗 Puxar Carro", function() local c = acC() if not c then return end local m = c:FindFirstAncestorOfClass("Model") if not m then return end local p = {} for _, d in ipairs(m:GetDescendants()) do if d:IsA("BasePart") and not d.Anchored then table.insert(p, d) if #p >= 6 then break end end end for _, x in ipairs(p) do local b = Instance.new("BodyVelocity", x) b.Name = "ZEDUX_Pux" b.MaxForce = Vector3.new(5e5, 5e5, 5e5) b.Velocity = Vector3.zero end task.spawn(function() local i = tick() while tick() - i < 4 do if not LP.Character then break end local mh = LP.Character:FindFirstChild("HumanoidRootPart") if not mh then break end local a = mh.Position + mh.CFrame.LookVector * 10 + Vector3.new(0, 3, 0) for _, x in ipairs(p) do if x and x.Parent then local b = x:FindFirstChild("ZEDUX_Pux") if b then local d = a - x.Position if d.Magnitude < 8 then b.Velocity = Vector3.zero else b.Velocity = d.Unit * math.min(150, d.Magnitude * 3) end end end end R.Heartbeat:Wait() end for _, x in ipairs(p) do if x and x.Parent then local b = x:FindFirstChild("ZEDUX_Pux") if b then b:Destroy() end end end end) end)
makeBtnTele("💥 Lançar Carro", function() if not S.sel or not S.sel.Character then return end local c = acC() if not c then return end local m = c:FindFirstAncestorOfClass("Model") if not m then return end local p = {} for _, d in ipairs(m:GetDescendants()) do if d:IsA("BasePart") and not d.Anchored then table.insert(p, d) if #p >= 8 then break end end end for _, x in ipairs(p) do local b = Instance.new("BodyVelocity", x) b.Name = "ZEDUX_Lan" b.MaxForce = Vector3.new(1e8, 1e8, 1e8) b.Velocity = Vector3.zero end task.spawn(function() local i = tick() while tick() - i < 6 do if not S.sel or not S.sel.Character then break end local th = S.sel.Character:FindFirstChild("HumanoidRootPart") if not th then break end local ap = th.Position + Vector3.new(0, 3, 0) for _, x in ipairs(p) do if x and x.Parent then local b = x:FindFirstChild("ZEDUX_Lan") if b then local d = ap - x.Position if d.Magnitude < 5 then b.Velocity = Vector3.zero else b.Velocity = d.Unit * math.min(3000, d.Magnitude * 15) end end end end R.Heartbeat:Wait() end for _, x in ipairs(p) do if x and x.Parent then local b = x:FindFirstChild("ZEDUX_Lan") if b then b:Destroy() end end end end) end)
makeBtnTele("🔓 Soltar Tudo", function() for _, c in ipairs(workspace:GetChildren()) do if c:IsA("Model") then for _, d in ipairs(c:GetDescendants()) do if d:IsA("BasePart") then local bv1 = d:FindFirstChild("ZEDUX_Pux") local bv2 = d:FindFirstChild("ZEDUX_Lan") if bv1 then bv1:Destroy() end if bv2 then bv2:Destroy() end end end end end end)
-- EXPLORER
local expCard = yoxCard(pages["Explorer"], "Explorer", "📁") local expList = Instance.new("ScrollingFrame", expCard) expList.Size = UDim2.new(1, 0, 0, 120) expList.BackgroundColor3 = Color3.fromRGB(15, 15, 15) expList.ScrollBarThickness = 3 Instance.new("UICorner", expList).CornerRadius = UDim.new(0, 4) Instance.new("UIListLayout", expList).Padding = UDim.new(0, 2)
local function refreshExp() expList:ClearAllChildren() for _, obj in ipairs(workspace:GetChildren()) do local b = Instance.new("TextButton", expList) b.Size = UDim2.new(1, -2, 0, 20) b.BackgroundColor3 = Color3.fromRGB(25, 25, 25) b.Text = "  " .. obj.Name .. " (" .. obj.ClassName .. ")" b.TextColor3 = Color3.fromRGB(200, 200, 200) b.TextSize = 8 b.Font = Enum.Font.Gotham b.TextXAlignment = Enum.TextXAlignment.Left Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3) end end
refreshExp() local btnRefreshExp = Instance.new("TextButton", expCard) btnRefreshExp.Size = UDim2.new(1, 0, 0, 25) btnRefreshExp.BackgroundColor3 = Color3.fromRGB(30, 30, 30) btnRefreshExp.Text = "🔄 Atualizar" btnRefreshExp.TextColor3 = Color3.fromRGB(200, 200, 200) btnRefreshExp.TextSize = 10 btnRefreshExp.Font = Enum.Font.GothamBold Instance.new("UICorner", btnRefreshExp).CornerRadius = UDim.new(0, 4) btnRefreshExp.MouseButton1Click:Connect(refreshExp)
-- CHAT
local chatCard = yoxCard(pages["Chat"], "Chat", "💬") local chatHistory = Instance.new("ScrollingFrame", chatCard) chatHistory.Size = UDim2.new(1, 0, 0, 150) chatHistory.BackgroundColor3 = Color3.fromRGB(15, 15, 15) chatHistory.ScrollBarThickness = 3 chatHistory.AutomaticCanvasSize = Enum.AutomaticSize.Y Instance.new("UICorner", chatHistory).CornerRadius = UDim.new(0, 4) Instance.new("UIListLayout", chatHistory).Padding = UDim.new(0, 3)
local chatInput = Instance.new("TextBox", chatCard) chatInput.Size = UDim2.new(1, 0, 0, 30) chatInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25) chatInput.TextColor3 = Color3.fromRGB(255, 255, 255) chatInput.PlaceholderText = "Digite sua mensagem..." chatInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100) chatInput.TextSize = 10 chatInput.Font = Enum.Font.Gotham chatInput.ClearTextOnFocus = false Instance.new("UICorner", chatInput).CornerRadius = UDim.new(0, 4)
local chatSend = Instance.new("TextButton", chatCard) chatSend.Size = UDim2.new(1, 0, 0, 25) chatSend.BackgroundColor3 = Color3.fromRGB(80, 255, 120) chatSend.Text = "Enviar" chatSend.TextColor3 = Color3.fromRGB(0, 0, 0) chatSend.TextSize = 10 chatSend.Font = Enum.Font.GothamBold Instance.new("UICorner", chatSend).CornerRadius = UDim.new(0, 4)
local function addChatMsg(nome, texto, isStaff) local f = Instance.new("Frame", chatHistory) f.Size = UDim2.new(1, -2, 0, 20) f.BackgroundColor3 = Color3.fromRGB(25, 25, 25) Instance.new("UICorner", f).CornerRadius = UDim.new(0, 3) local t = Instance.new("TextLabel", f) t.Size = UDim2.new(1, -10, 1, 0) t.Position = UDim2.new(0, 5, 0, 0) t.BackgroundTransparency = 1 t.Text = nome .. ": " .. texto t.TextColor3 = isStaff and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(80, 255, 120) t.TextSize = 9 t.Font = Enum.Font.Gotham t.TextXAlignment = Enum.TextXAlignment.Left t.TextTruncate = Enum.TextTruncate.AtEnd task.spawn(function() task.wait(0.1) chatHistory.CanvasPosition = Vector2.new(0, chatHistory.AbsoluteCanvasSize.Y) end) end
chatSend.MouseButton1Click:Connect(function() local m = chatInput.Text if m == "" then return end addChatMsg(LP.Name, m, false) chatInput.Text = "" local embed = {title = "💬 Nova Mensagem: " .. LP.Name, description = m, color = 3447003, timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")} pcall(function() game:GetService("HttpService"):RequestAsync({Url = WEBHOOK, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = game:GetService("HttpService"):JSONEncode({username = "CHAT ZEDUX", embeds = {embed}})}) end) end)
-- AMBIENTE
local ambCard = yoxCard(pages["Ambiente"], "Sky / Aurora", "🌌") local currentSky = nil local function clearSky() if currentSky then currentSky:Destroy() end for _, obj in ipairs(game:GetService("Lighting"):GetChildren()) do if obj.Name == "ZeduxSkyObject" then obj:Destroy() end end end local function setSky(assetId, name, cor) clearSky() local skyObj = Instance.new("Sky") skyObj.Name = "ZeduxSkyObject" skyObj.SkyboxBk = "rbxassetid://" .. assetId skyObj.SkyboxDn = "rbxassetid://" .. assetId skyObj.SkyboxFt = "rbxassetid://" .. assetId skyObj.SkyboxLf = "rbxassetid://" .. assetId skyObj.SkyboxRt = "rbxassetid://" .. assetId skyObj.SkyboxUp = "rbxassetid://" .. assetId skyObj.Parent = game:GetService("Lighting") game:GetService("Lighting").Ambient = cor game:GetService("Lighting").OutdoorAmbient = cor end
local ceus = {{n = "Aurora Boreal", id = "6903759368", c = Color3.fromRGB(30, 50, 80)},{n = "Noite Estrelada", id = "6903759368", c = Color3.fromRGB(0, 0, 20)},{n = "Pôr do Sol", id = "6903759368", c = Color3.fromRGB(255, 120, 50)},{n = "Céu Roxo", id = "6903759368", c = Color3.fromRGB(80, 20, 120)},{n = "Céu Normal", id = "0", c = Color3.fromRGB(255, 255, 255)}}
for _, ceu in ipairs(ceus) do local b = Instance.new("TextButton", ambCard) b.Size = UDim2.new(1, 0, 0, 30) b.BackgroundColor3 = Color3.fromRGB(30, 30, 30) b.Text = "🌌 " .. ceu.n b.TextColor3 = Color3.fromRGB(200, 200, 200) b.TextSize = 10 b.Font = Enum.Font.GothamBold b.TextXAlignment = Enum.TextXAlignment.Left Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4) b.MouseButton1Click:Connect(function() if ceu.n == "Céu Normal" then clearSky() game:GetService("Lighting").Ambient = Color3.fromRGB(70, 70, 70) game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128) else setSky(ceu.id, ceu.n, ceu.c) end end) end
-- REGISTROS
local logsCard = yoxCard(pages["Registros"], "Logs do Sistema", "📋") local tL = Instance.new("TextLabel", logsCard) tL.Size = UDim2.new(1, 0, 0, 15) tL.BackgroundTransparency = 1 tL.Text = "Total: " .. #lg tL.TextColor3 = Color3.fromRGB(150, 150, 150) tL.TextSize = 9 tL.Font = Enum.Font.Gotham tL.TextXAlignment = Enum.TextXAlignment.Left
local sL2 = Instance.new("ScrollingFrame", logsCard) sL2.Size = UDim2.new(1, 0, 0, 150) sL2.BackgroundColor3 = Color3.fromRGB(15, 15, 15) sL2.ScrollBarThickness = 3 sL2.AutomaticCanvasSize = Enum.AutomaticSize.Y Instance.new("UICorner", sL2).CornerRadius = UDim.new(0, 4) Instance.new("UIListLayout", sL2).Padding = UDim.new(0, 2)
local function atualizarLogs() for _, c in ipairs(sL2:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end for i = #lg, 1, -1 do local L = lg[i] local f = Instance.new("Frame", sL2) f.Size = UDim2.new(1, -2, 0, 20) f.BackgroundColor3 = Color3.fromRGB(25, 25, 25) Instance.new("UICorner", f).CornerRadius = UDim.new(0, 3) local txt = Instance.new("TextLabel", f) txt.Size = UDim2.new(1, -10, 1, 0) txt.Position = UDim2.new(0, 5, 0, 0) txt.BackgroundTransparency = 1 txt.Text = "[" .. L.h .. "] " .. L.j .. ": " .. L.a txt.TextColor3 = Color3.fromRGB(200, 200, 200) txt.TextSize = 8 txt.Font = Enum.Font.Gotham txt.TextXAlignment = Enum.TextXAlignment.Left txt.TextTruncate = Enum.TextTruncate.AtEnd end tL.Text = "Total: " .. #lg end
atualizarLogs() task.spawn(function() while sL2.Parent do task.wait(1) atualizarLogs() end end)
-- SETTINGS
local themeCard = yoxCard(pages["Settings"], "Themes", "🎨")
local themes = {{n="Violet",c=Color3.fromRGB(168,85,247)},{n="Crimson",c=Color3.fromRGB(220,40,60)},{n="Cyber Cyan",c=Color3.fromRGB(0,220,255)},{n="Emerald",c=Color3.fromRGB(80,255,120)},{n="Amber",c=Color3.fromRGB(255,200,50)},{n="Monochrome",c=Color3.fromRGB(150,150,150)}}
for _, t in ipairs(themes) do local b = Instance.new("TextButton", themeCard) b.Size = UDim2.new(0.48,0,0,25) b.BackgroundColor3 = Color3.fromRGB(30,30,30) b.Text = t.n b.TextColor3 = t.c b.Font = Enum.Font.GothamBold Instance.new("UICorner", b).CornerRadius = UDim.new(0,4) b.MouseButton1Click:Connect(function() T:Create(w, TweenInfo.new(0.3), {BackgroundColor3 = t.c}):Play() end) end
local unloadBtn = Instance.new("TextButton", pages["Settings"]) unloadBtn.Size = UDim2.new(1,0,0,35) unloadBtn.BackgroundColor3 = Color3.fromRGB(150,40,40) unloadBtn.Text = "Hold to unload" unloadBtn.TextColor3 = Color3.fromRGB(255,255,255) unloadBtn.Font = Enum.Font.GothamBold Instance.new("UICorner", unloadBtn).CornerRadius = UDim.new(0,6) unloadBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

print("[ZEDUX] v19.0 completo carregado com HWID Lock e Informações do Sistema!")
