--// ZEDUX V12.0 - FULL MERGE (Tua Base + V11)
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

local KEYS_VALIDAS = {
    ["ZEDUX-HUB-2026"] = true,
    ["ZEDUX-HUB-VIP"] = true,
    ["ZEDUX-HUB-PRO"] = true,
    ["eduardo92301"] = true
}

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
        pcall(function() writefile(TEMPOFILE, key .. "|" .. tostring(math.huge)) end)
        return true 
    else return false end
    local expiracao = tempoAgora + segundos
    pcall(function() writefile(TEMPOFILE, key .. "|" .. tostring(expiracao)) end)
    return true
end

local function IniciarIntro()
    local executor = "Unknown" pcall(function() executor = getexecutorname() or identifyexecutor() end) if type(executor) == "table" then executor = executor[1] end
    local hwid = "Not Available" pcall(function() hwid = gethwid() end) if hwid == "Not Available" then hwid = LP.UserId .. "-" .. math.random(1000, 9999) end
    local device = "PC" if U.TouchEnabled and not U.KeyboardEnabled then device = "Mobile" end if U.GamepadEnabled then device = "Console" end

    local introGui = Instance.new("ScreenGui")
    introGui.Name = "ZeduxLoader" introGui.ResetOnSpawn = false introGui.IgnoreGuiInset = true introGui.DisplayOrder = 999999 introGui.Parent = game:GetService("CoreGui")

    local main = Instance.new("Frame", introGui) main.Size = UDim2.new(0, 700, 0, 420) main.Position = UDim2.new(0.5, -350, 0.5, -210) main.BackgroundColor3 = Color3.fromRGB(5, 5, 5) main.BorderSizePixel = 0 Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", main).Color = Color3.fromRGB(200, 200, 200)

    local leftPanel = Instance.new("Frame", main) leftPanel.Size = UDim2.new(0, 240, 1, 0) leftPanel.BackgroundColor3 = Color3.fromRGB(10, 10, 10) leftPanel.BorderSizePixel = 0 Instance.new("UICorner", leftPanel).CornerRadius = UDim.new(0, 12)
    local topBar = Instance.new("Frame", leftPanel) topBar.Size = UDim2.new(1, 0, 0, 35) topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20) topBar.BorderSizePixel = 0 Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)
    
    local titleInfo = Instance.new("TextLabel", topBar) titleInfo.Size = UDim2.new(1, -40, 1, 0) titleInfo.Position = UDim2.new(0, 35, 0, 0) titleInfo.BackgroundTransparency = 1 titleInfo.Text = "User Info" titleInfo.TextColor3 = Color3.fromRGB(200, 200, 200) titleInfo.TextSize = 14 titleInfo.Font = Enum.Font.GothamBold titleInfo.TextXAlignment = Enum.TextXAlignment.Left

    local avatarFrame = Instance.new("Frame", leftPanel) avatarFrame.Size = UDim2.new(0, 80, 0, 80) avatarFrame.Position = UDim2.new(0.5, -40, 0, 50) avatarFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5) avatarFrame.BackgroundTransparency = 0.5 Instance.new("UICorner", avatarFrame).CornerRadius = UDim.new(1, 0) Instance.new("UIStroke", avatarFrame).Color = Color3.fromRGB(200, 200, 200)
    local avatar = Instance.new("ImageLabel", avatarFrame) avatar.Size = UDim2.new(1, -6, 1, -6) avatar.Position = UDim2.new(0, 3, 0, 3) avatar.BackgroundTransparency = 1 avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=150&h=150" Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

    local nameLabel = Instance.new("TextLabel", leftPanel) nameLabel.Size = UDim2.new(1, 0, 0, 20) nameLabel.Position = UDim2.new(0, 0, 0, 140) nameLabel.BackgroundTransparency = 1 nameLabel.Text = LP.DisplayName nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255) nameLabel.TextSize = 16 nameLabel.Font = Enum.Font.GothamBold
    local userLabel = Instance.new("TextLabel", leftPanel) userLabel.Size = UDim2.new(1, 0, 0, 15) userLabel.Position = UDim2.new(0, 0, 0, 160) userLabel.BackgroundTransparency = 1 userLabel.Text = "@" .. LP.Name userLabel.TextColor3 = Color3.fromRGB(150, 150, 150) userLabel.TextSize = 12 userLabel.Font = Enum.Font.Gotham

    local function addInfoRow(posY, emoji, labelTxt, valueTxt)
        local row = Instance.new("Frame", leftPanel) row.Size = UDim2.new(1, -20, 0, 30) row.Position = UDim2.new(0, 10, 0, posY) row.BackgroundTransparency = 1
        local e = Instance.new("TextLabel", row) e.Size = UDim2.new(0, 20, 1, 0) e.BackgroundTransparency = 1 e.Text = emoji e.TextSize = 14
        local l = Instance.new("TextLabel", row) l.Size = UDim2.new(0.5, 0, 1, 0) l.Position = UDim2.new(0, 25, 0, 0) l.BackgroundTransparency = 1 l.Text = labelTxt l.TextColor3 = Color3.fromRGB(150, 150, 150) l.TextSize = 11 l.Font = Enum.Font.GothamBold l.TextXAlignment = Enum.TextXAlignment.Left
        local v = Instance.new("TextLabel", row) v.Size = UDim2.new(0.5, -25, 1, 0) v.Position = UDim2.new(0.5, 0, 0, 0) v.BackgroundTransparency = 1 v.Text = valueTxt v.TextColor3 = Color3.fromRGB(220, 220, 220) v.TextSize = 11 v.Font = Enum.Font.Gotham v.TextXAlignment = Enum.TextXAlignment.Right
    end
    
    addInfoRow(190, "🖥️", "Executor", executor) addInfoRow(220, "💻", "Device", device) addInfoRow(250, "🛡️", "HWID", string.sub(hwid, 1, 10) .. "...")
    pcall(function() addInfoRow(280, "🎮", "Game", string.sub(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name, 1, 15)) end)

    local pingLabel = Instance.new("TextLabel", leftPanel) pingLabel.Size = UDim2.new(0.5, -10, 0, 30) pingLabel.Position = UDim2.new(0.5, 0, 1, -40) pingLabel.BackgroundTransparency = 1 pingLabel.Text = "📶 Ping: -- ms" pingLabel.TextColor3 = Color3.fromRGB(200, 200, 200) pingLabel.TextSize = 11 pingLabel.Font = Enum.Font.Gotham
    task.spawn(function() while pingLabel.Parent do pcall(function() local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) pingLabel.Text = "📶 Ping: " .. ping .. " ms" end) task.wait(1) end end)

    local connectedFrame = Instance.new("Frame", leftPanel) connectedFrame.Size = UDim2.new(1, -20, 0, 40) connectedFrame.Position = UDim2.new(0, 10, 1, -80) connectedFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) connectedFrame.BorderSizePixel = 0 Instance.new("UICorner", connectedFrame).CornerRadius = UDim.new(0, 6)
    local connDot = Instance.new("TextLabel", connectedFrame) connDot.Size = UDim2.new(0, 20, 1, 0) connDot.Position = UDim2.new(0, 5, 0, 0) connDot.BackgroundTransparency = 1 connDot.Text = "🟢" connDot.TextSize = 14
    local connText = Instance.new("TextLabel", connectedFrame) connText.Size = UDim2.new(1, -30, 1, 0) connText.Position = UDim2.new(0, 25, 0, 0) connText.BackgroundTransparency = 1 connText.Text = "Connected to Zedux Hub" connText.TextColor3 = Color3.fromRGB(200, 200, 200) connText.TextSize = 11 connText.Font = Enum.Font.GothamBold connText.TextXAlignment = Enum.TextXAlignment.Left

    local rightPanel = Instance.new("Frame", main) rightPanel.Size = UDim2.new(1, -240, 1, 0) rightPanel.Position = UDim2.new(0, 240, 0, 0) rightPanel.BackgroundTransparency = 1
    local hTitle = Instance.new("TextLabel", rightPanel) hTitle.Size = UDim2.new(1, 0, 0, 30) hTitle.Position = UDim2.new(0, 0, 0, 20) hTitle.BackgroundTransparency = 1 hTitle.Text = "ZEDUX HUB" hTitle.TextColor3 = Color3.fromRGB(255, 255, 255) hTitle.TextSize = 24 hTitle.Font = Enum.Font.GothamBold hTitle.TextXAlignment = Enum.TextXAlignment.Center
    local hSub = Instance.new("TextLabel", rightPanel) hSub.Size = UDim2.new(1, 0, 0, 20) hSub.Position = UDim2.new(0, 0, 0, 50) hSub.BackgroundTransparency = 1 hSub.Text = "Secure FlowAuth Loader" hSub.TextColor3 = Color3.fromRGB(120, 120, 120) hSub.TextSize = 12 hSub.Font = Enum.Font.Gotham hSub.TextXAlignment = Enum.TextXAlignment.Center

    local accessTitle = Instance.new("TextLabel", rightPanel) accessTitle.Size = UDim2.new(0.8, 0, 0, 20) accessTitle.Position = UDim2.new(0.1, 0, 0, 110) accessTitle.BackgroundTransparency = 1 accessTitle.Text = "SECURE ACCESS" accessTitle.TextColor3 = Color3.fromRGB(200, 200, 200) accessTitle.TextSize = 11 accessTitle.Font = Enum.Font.GothamBold accessTitle.TextXAlignment = Enum.TextXAlignment.Left
    local keyBox = Instance.new("TextBox", rightPanel) keyBox.Size = UDim2.new(0.8, 0, 0, 45) keyBox.Position = UDim2.new(0.1, 0, 0, 135) keyBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15) keyBox.TextColor3 = Color3.fromRGB(255, 255, 255) keyBox.PlaceholderText = "Waiting for key..." keyBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100) keyBox.TextSize = 14 keyBox.Font = Enum.Font.Gotham keyBox.TextXAlignment = Enum.TextXAlignment.Left keyBox.ClearTextOnFocus = false Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8) local padding = Instance.new("UIPadding", keyBox) padding.PaddingLeft = UDim.new(0, 15)

    local getKeyBtn = Instance.new("TextButton", rightPanel) getKeyBtn.Size = UDim2.new(0.38, 0, 0, 40) getKeyBtn.Position = UDim2.new(0.1, 0, 0, 195) getKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) getKeyBtn.Text = "🔑 Get Key" getKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255) getKeyBtn.Font = Enum.Font.GothamBold getKeyBtn.TextSize = 13 Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 8)
    local redeemBtn = Instance.new("TextButton", rightPanel) redeemBtn.Size = UDim2.new(0.38, 0, 0, 40) redeemBtn.Position = UDim2.new(0.52, 0, 0, 195) redeemBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20) redeemBtn.Text = "🛡️ Redeem" redeemBtn.TextColor3 = Color3.fromRGB(255, 255, 255) redeemBtn.Font = Enum.Font.GothamBold redeemBtn.TextSize = 13 Instance.new("UICorner", redeemBtn).CornerRadius = UDim.new(0, 8)

    local discordBtn = Instance.new("TextButton", rightPanel) discordBtn.Size = UDim2.new(0.38, 0, 0, 35) discordBtn.Position = UDim2.new(0.1, 0, 0, 250) discordBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20) discordBtn.Text = "💬 Discord" discordBtn.TextColor3 = Color3.fromRGB(200, 200, 200) discordBtn.Font = Enum.Font.Gotham discordBtn.TextSize = 12 Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0, 8)
    local copyBtn = Instance.new("TextButton", rightPanel) copyBtn.Size = UDim2.new(0.38, 0, 0, 35) copyBtn.Position = UDim2.new(0.52, 0, 0, 250) copyBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20) copyBtn.Text = "📋 Copy HWID" copyBtn.TextColor3 = Color3.fromRGB(200, 200, 200) copyBtn.Font = Enum.Font.Gotham copyBtn.TextSize = 12 Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 8)
    
    local statusLog = Instance.new("TextLabel", rightPanel) statusLog.Size = UDim2.new(0.8, 0, 0, 20) statusLog.Position = UDim2.new(0.1, 0, 0, 300) statusLog.BackgroundTransparency = 1 statusLog.Text = "" statusLog.TextColor3 = Color3.fromRGB(0, 200, 100) statusLog.TextSize = 11 statusLog.Font = Enum.Font.Gotham statusLog.TextXAlignment = Enum.TextXAlignment.Left

    getKeyBtn.MouseButton1Click:Connect(function() pcall(function() setclipboard(URL_SITE) end) statusLog.Text = "🔗 Link copiado!" end)
    discordBtn.MouseButton1Click:Connect(function() pcall(function() setclipboard(URL_DISCORD) end) statusLog.Text = "🔗 Discord copiado!" end)
    copyBtn.MouseButton1Click:Connect(function() pcall(function() setclipboard(hwid) end) statusLog.Text = "✅ HWID copiado!" end)

    redeemBtn.MouseButton1Click:Connect(function()
        local keyDigitada = keyBox.Text:gsub("%s+", "")
        if KEYS_VALIDAS[keyDigitada] or ChecarTempoKey(keyDigitada) then
            statusLog.TextColor3 = Color3.fromRGB(0, 200, 100) statusLog.Text = "✅ Key válida! Iniciando painel..." task.wait(1) introGui:Destroy()
        else
            statusLog.TextColor3 = Color3.fromRGB(255, 80, 80) statusLog.Text = "❌ Key inválida ou expirada." keyBox.Text = "" task.wait(2) statusLog.Text = ""
        end
    end)

    if isVipOuSuperior then
        hTitle.Text = "BEM-VINDO VIP" hSub.Text = "Acesso liberado automaticamente..." keyBox.Visible = false getKeyBtn.Visible = false redeemBtn.Visible = false discordBtn.Visible = false copyBtn.Visible = false statusLog.Text = "✅ Autenticado via VIP." task.wait(1.5) introGui:Destroy()
    else repeat task.wait() until not introGui.Parent end
end
IniciarIntro()

-- =======================================================
-- WEBHOOK E LOGS
-- =======================================================
local WEBHOOK = "https://discord.com/api/webhooks/1559481604387246170/aAs30L9QQbfX0ZWA92jKpD6PZ_F5IOZT1424WNqaHluyZ-QuNGbbO36pVf-Fe3Ti9Fe4"
local httpReq = (syn and syn.request) or (http and http.request) or http_request or request
local filaDiscord = {} local enviandoFila = false

local function processarFila()
    if enviandoFila then return end enviandoFila = true
    task.spawn(function()
        while #filaDiscord > 0 do
            local lote = {} local cont = 0
            while #filaDiscord > 0 and cont < 20 do table.insert(lote, table.remove(filaDiscord, 1)) cont = cont + 1 end
            local desc = "" for _, l in ipairs(lote) do desc = desc .. "`" .. l .. "`\n" end
            local e = {title = "📋 LOG", description = desc, color = 3447003, footer = {text = "🕐 " .. os.date("%d/%m/%Y %H:%M:%S")}, timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")}
            if WEBHOOK ~= "" and httpReq then pcall(function() httpReq({Url = WEBHOOK, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HS:JSONEncode({username = "ZEDUX HUB", embeds = {e}})}) end) end
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
    if d and d ~= "" then for l in d:gmatch("[^\n]+") do local h, j, a = l:match("^(.-)|(.-)|(.*)$") if h and j and a then table.insert(lg, {h = h, j = j, a = a}) end end end
end)

getgenv().LH_AP = {} getgenv().LH_CARGOS = {} getgenv().LH_CARGOS[tostring(OID)] = "PROPRIETÁRIO" getgenv().LH_CARGOS[LP.Name] = "PROPRIETÁRIO" for _, n in ipairs(WL) do getgenv().LH_AP[n:lower()] = true end

-- =======================================================
-- UI PRINCIPAL (COM DRAWING E VIEWPORT)
-- =======================================================
local ACCENT = Color3.fromRGB(170, 0, 255)
local BG = Color3.fromRGB(15, 15, 20)
local CARD = Color3.fromRGB(25, 25, 30)
local TEXT = Color3.fromRGB(200, 200, 205)
local CFG = {
    Aim = { On = false, Key = Enum.KeyCode.E, FOV = 150, Smooth = 0.3, Silent = false, Predict = 0.16, Part = "Head", AutoFire = false, Holding = false },
    Hitbox = { On = false, X = 20, Y = 20, Z = 20, Part = "Head" },
    Vis = { Box = true, Fill = false, Skel = true, Chams = true, Name = true, Dist = true, Rainbow = false, Color = Color3.fromRGB(170, 0, 255) },
    Rage = { Spin = false, InfJump = false },
    Cross = { On = true, Dot = true, Size = 6, Gap = 3, Color = Color3.fromRGB(170, 0, 255) }
}

local gui = Instance.new("ScreenGui") gui.Name = "ZeduxHub" gui.ResetOnSpawn = false gui.IgnoreGuiInset = true gui.DisplayOrder = 99999 gui.Parent = game:GetService("CoreGui")
local w = Instance.new("Frame", gui) w.Size = UDim2.new(0, 780, 0, 480) w.Position = UDim2.new(0.5, -390, 0.5, -240) w.BackgroundColor3 = BG w.BorderSizePixel = 0 Instance.new("UICorner", w).CornerRadius = UDim.new(0, 8) Instance.new("UIStroke", w).Color = Color3.fromRGB(40,40,45) w.ClipsDescendants = true
w.Visible = true reg("✅ Painel ABERTO")

-- TOPBAR E BOTÕES
local top = Instance.new("Frame", w) top.Size = UDim2.new(1, 0, 0, 40) top.BackgroundTransparency = 1
local title = Instance.new("TextLabel", top) title.Size = UDim2.new(1, -100, 1, 0) title.Position = UDim2.new(0, 20, 0, 0) title.BackgroundTransparency = 1 title.Text = "ZEDUX | MAIN" title.TextColor3 = ACCENT title.TextSize = 16 title.Font = Enum.Font.GothamBold title.TextXAlignment = Enum.TextXAlignment.Left
local minBtn = Instance.new("TextButton", top) minBtn.Size = UDim2.new(0, 30, 0, 30) minBtn.Position = UDim2.new(1, -70, 0, 5) minBtn.BackgroundColor3 = CARD minBtn.Text = "—" minBtn.TextColor3 = Color3.fromRGB(255, 255, 255) minBtn.TextSize = 14 minBtn.Font = Enum.Font.GothamBold Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)
local closeBtn = Instance.new("TextButton", top) closeBtn.Size = UDim2.new(0, 30, 0, 30) closeBtn.Position = UDim2.new(1, -35, 0, 5) closeBtn.BackgroundColor3 = CARD closeBtn.Text = "X" closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80) closeBtn.TextSize = 14 closeBtn.Font = Enum.Font.GothamBold Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

-- SIDEBAR
local sb = Instance.new("Frame", w) sb.Size = UDim2.new(0, 200, 1, -40) sb.Position = UDim2.new(0, 0, 0, 40) sb.BackgroundColor3 = Color3.fromRGB(10, 10, 12) sb.BorderSizePixel = 0 Instance.new("UICorner", sb).CornerRadius = UDim.new(0, 8)
local mnu = Instance.new("ScrollingFrame", sb) mnu.Size = UDim2.new(1, -24, 1, -280) mnu.Position = UDim2.new(0, 12, 0, 60) mnu.BackgroundTransparency = 1 mnu.BorderSizePixel = 0 mnu.ScrollBarThickness = 3 mnu.AutomaticCanvasSize = Enum.AutomaticSize.Y mnu.ZIndex = 3 Instance.new("UIListLayout", mnu).Padding = UDim.new(0, 3)

-- PERFIL EMBAIXO
local av = Instance.new("Frame", sb) av.Size = UDim2.new(1, -24, 0, 58) av.Position = UDim2.new(0, 12, 1, -64) av.BackgroundColor3 = CARD av.BorderSizePixel = 0 av.ZIndex = 3 Instance.new("UICorner", av).CornerRadius = UDim.new(0, 8)
local ai = Instance.new("ImageLabel", av) ai.Size = UDim2.new(0, 42, 0, 42) ai.Position = UDim2.new(0, 8, 0, 8) ai.BackgroundColor3 = Color3.fromRGB(10, 10, 10) ai.BorderSizePixel = 0 ai.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=150&h=150" ai.ZIndex = 4 Instance.new("UICorner", ai).CornerRadius = UDim.new(1, 0) Instance.new("UIStroke", ai).Color = Color3.fromRGB(150, 150, 150)
local nk = Instance.new("TextLabel", av) nk.Size = UDim2.new(1, -58, 0, 16) nk.Position = UDim2.new(0, 56, 0, 12) nk.BackgroundTransparency = 1 nk.Text = LP.Name nk.TextColor3 = Color3.fromRGB(255, 255, 255) nk.TextSize = 11 nk.Font = Enum.Font.GothamBold nk.TextXAlignment = Enum.TextXAlignment.Left nk.ZIndex = 4
local cg = Instance.new("TextLabel", av) cg.Size = UDim2.new(1, -58, 0, 12) cg.Position = UDim2.new(0, 56, 0, 30) cg.BackgroundTransparency = 1 cg.Text = CG cg.TextColor3 = Color3.fromRGB(200, 200, 200) cg.TextSize = 9 cg.Font = Enum.Font.GothamBold cg.TextXAlignment = Enum.TextXAlignment.Left cg.ZIndex = 4

-- CONTENT E VIEWPORT
local ct = Instance.new("Frame", w) ct.Size = UDim2.new(1, -380, 1, -60) ct.Position = UDim2.new(0, 210, 0, 50) ct.BackgroundTransparency = 1 ct.ZIndex = 3
local content = Instance.new("ScrollingFrame", ct) content.Size = UDim2.new(1, 0, 1, 0) content.BackgroundTransparency = 1 content.BorderSizePixel = 0 content.ScrollBarThickness = 2 content.AutomaticCanvasSize = Enum.AutomaticSize.Y Instance.new("UIListLayout", content).Padding = UDim.new(0, 8)

local viewFrame = Instance.new("Frame", w) viewFrame.Size = UDim2.new(0, 160, 1, -60) viewFrame.Position = UDim2.new(1, -170, 0, 50) viewFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12) viewFrame.BorderSizePixel = 0 Instance.new("UICorner", viewFrame).CornerRadius = UDim.new(0, 8)
local viewport = Instance.new("ViewportFrame", viewFrame) viewport.Size = UDim2.new(1, 0, 1, 0) viewport.BackgroundTransparency = 1 viewport.Ambient = Color3.fromRGB(255, 255, 255) viewport.LightColor = Color3.fromRGB(255, 255, 255) Instance.new("UICorner", viewport).CornerRadius = UDim.new(0, 8)
local cam = Instance.new("Camera", viewport) viewport.CurrentCamera = cam cam.FieldOfView = 40 cam.CFrame = CFrame.new(Vector3.new(0, 0, 4), Vector3.new(0, 0, 0))
local cloneModel = nil
local function updatePreview() if cloneModel then cloneModel:Destroy() end if not LP.Character then return end cloneModel = LP.Character:Clone() cloneModel.Parent = viewport for _, v in ipairs(cloneModel:GetDescendants()) do if v:IsA("Humanoid") or v:IsA("Script") or v:IsA("LocalScript") then v:Destroy() elseif v:IsA("BasePart") then v.Anchored = true v.CanCollide = false v.CanQuery = false v.CanTouch = false end end local hrp = cloneModel:FindFirstChild("HumanoidRootPart") if hrp then cloneModel:PivotTo(CFrame.new(0, -1.5, 0)) end end
task.spawn(function() task.wait(1) updatePreview() end) LP.CharacterAdded:Connect(function() task.wait(1) updatePreview() end) local light = Instance.new("PointLight", cam) light.Brightness = 2 light.Range = 10
R.RenderStepped:Connect(function() if cloneModel and cloneModel:FindFirstChild("HumanoidRootPart") then cloneModel:PivotTo(cloneModel:GetPivot() * CFrame.Angles(0, math.rad(1), 0)) end end)

-- DRAG & MINIMIZE
local dragging, dragStart, startPos
top.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = input.Position startPos = w.Position end end)
U.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart w.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
U.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
local minimized = false
minBtn.MouseButton1Click:Connect(function() minimized = not minimized if minimized then w.Size = UDim2.new(0, 780, 0, 40) sb.Visible = false ct.Visible = false viewFrame.Visible = false minBtn.Text = "□" else w.Size = UDim2.new(0, 780, 0, 480) sb.Visible = true ct.Visible = true viewFrame.Visible = true minBtn.Text = "—" end end)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() for _, obj in pairs(drawEsp) do for _, v in pairs(obj) do if typeof(v) == "table" then for _, l in pairs(v) do l:Remove() end else v:Remove() end end end fovCircle:Remove() for _, l in ipairs(crossLines) do l:Remove() end crossDot:Remove() end)

-- CATEGORIAS
local CC = {Main = Color3.fromRGB(255, 255, 255), ESP = Color3.fromRGB(220, 220, 220), Combate = Color3.fromRGB(255, 100, 100), Mov = Color3.fromRGB(100, 255, 100), Tele = Color3.fromRGB(180, 180, 180), Troll = Color3.fromRGB(230, 230, 230), Config = Color3.fromRGB(150, 150, 150), Log = Color3.fromRGB(200, 200, 200), Adm = Color3.fromRGB(255, 255, 255), Keys = Color3.fromRGB(230, 230, 230), Personalizacao = Color3.fromRGB(180, 180, 180)}
local IC = {Main = "🏠", ESP = "📡", Combate = "🎯", Mov = "🏃", Tele = "🌀", Troll = "🎭", Config = "⚙️", Log = "📋", Adm = "🔓", Keys = "🔑", Personalizacao = "🎨"}
local mB = {} local cs = {}

local function cat(n)
    local cr = CC[n] or Color3.fromRGB(200, 200, 200)
    local b = Instance.new("TextButton", mnu) b.Size = UDim2.new(1, 0, 0, 28) b.BackgroundColor3 = Color3.fromRGB(20, 20, 22) b.Text = "  " .. (IC[n] or "◆") .. "  " .. n b.TextColor3 = cr b.TextSize = 10 b.Font = Enum.Font.GothamBold b.TextXAlignment = Enum.TextXAlignment.Left b.AutoButtonColor = false b.ZIndex = 3 Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    mB[n] = b table.insert(cs, n)
end
cat("Main") cat("ESP") cat("Combate") cat("Mov") cat("Tele") cat("Troll") cat("Personalizacao") cat("Config") if AD then cat("Adm") cat("Keys") cat("Log") end

local sec = {}
for _, n in ipairs(cs) do
    local sc = Instance.new("ScrollingFrame", ct) sc.Size = UDim2.new(1, 0, 1, 0) sc.BackgroundTransparency = 1 sc.ScrollBarThickness = 4 sc.AutomaticCanvasSize = Enum.AutomaticSize.Y sc.Visible = false sc.ZIndex = 3 Instance.new("UIListLayout", sc).Padding = UDim.new(0, 8)
    sec[n] = sc
end

local function sel(n)
    for nn, b in pairs(mB) do local cr = CC[nn] or Color3.fromRGB(200, 200, 200) if nn == n then b.BackgroundColor3 = cr b.TextColor3 = Color3.fromRGB(0, 0, 0) else b.BackgroundColor3 = Color3.fromRGB(20, 20, 22) b.TextColor3 = cr end end
    for nn, s in pairs(sec) do s.Visible = (nn == n) end
end
for n, b in pairs(mB) do b.MouseButton1Click:Connect(function() sel(n) end) end
sel("Main")

-- =======================================================
-- UI LIBRARY
-- =======================================================
local function card(ti, p, cr)
    local c = Instance.new("Frame", p) c.Size = UDim2.new(1, 0, 0, 0) c.AutomaticSize = Enum.AutomaticSize.Y c.BackgroundColor3 = CARD c.ZIndex = 3 Instance.new("UICorner", c).CornerRadius = UDim.new(0, 7)
    local pd = Instance.new("UIPadding", c) pd.PaddingTop = UDim.new(0, 9) pd.PaddingBottom = UDim.new(0, 9) pd.PaddingLeft = UDim.new(0, 12) pd.PaddingRight = UDim.new(0, 12)
    local t = Instance.new("TextLabel", c) t.Size = UDim2.new(1, -8, 0, 12) t.Position = UDim2.new(0, 8, 0, 7) t.BackgroundTransparency = 1 t.Text = ti t.TextColor3 = cr or Color3.fromRGB(200, 200, 200) t.TextSize = 9 t.Font = Enum.Font.GothamBold t.TextXAlignment = Enum.TextXAlignment.Left t.ZIndex = 4
    Instance.new("UIListLayout", c).Padding = UDim.new(0, 6)
    local h = Instance.new("Frame", c) h.Size = UDim2.new(1, 0, 0, 0) h.AutomaticSize = Enum.AutomaticSize.Y h.BackgroundTransparency = 1 h.LayoutOrder = 2 h.ZIndex = 4 Instance.new("UIListLayout", h).Padding = UDim.new(0, 6)
    return h
end

local function bt(p, tx, cb, tr)
    local b = Instance.new("TextButton", p) b.Size = UDim2.new(1, 0, 0, 32) b.BackgroundColor3 = tr and Color3.fromRGB(50, 20, 20) or Color3.fromRGB(25, 25, 25) b.Text = "  " .. tx b.TextColor3 = tr and Color3.fromRGB(220, 180, 190) or Color3.fromRGB(220, 220, 220) b.TextSize = 10 b.Font = Enum.Font.GothamBold b.AutoButtonColor = false b.TextXAlignment = Enum.TextXAlignment.Left b.ZIndex = 4 Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    local bs = Instance.new("UIStroke", b) bs.Color = Color3.fromRGB(100, 100, 100) bs.Thickness = 1
    local cH = tr and Color3.fromRGB(80, 30, 30) or Color3.fromRGB(45, 45, 45) local cB = b.BackgroundColor3
    b.MouseEnter:Connect(function() T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = cH}):Play() end)
    b.MouseLeave:Connect(function() T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = cB}):Play() end)
    b.MouseButton1Click:Connect(function() T:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(200, 200, 200), TextColor3 = Color3.fromRGB(0,0,0)}):Play() reg(tx) task.wait(0.1) T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = cH, TextColor3 = b.TextColor3}):Play() cb() end)
    return b
end

local function btT(p, tx, cb, cr)
    local h = Instance.new("Frame", p) h.Size = UDim2.new(1, 0, 0, 34) h.BackgroundColor3 = Color3.fromRGB(25, 25, 25) h.ZIndex = 4 Instance.new("UICorner", h).CornerRadius = UDim.new(0, 8)
    local l = Instance.new("TextLabel", h) l.Size = UDim2.new(1, -60, 1, 0) l.Position = UDim2.new(0, 12, 0, 0) l.BackgroundTransparency = 1 l.Text = tx l.TextColor3 = Color3.fromRGB(220, 220, 220) l.TextSize = 10 l.Font = Enum.Font.GothamBold l.TextXAlignment = Enum.TextXAlignment.Left l.ZIndex = 5
    local trk = Instance.new("Frame", h) trk.Size = UDim2.new(0, 44, 0, 22) trk.Position = UDim2.new(1, -52, 0.5, -11) trk.BackgroundColor3 = Color3.fromRGB(50, 50, 50) trk.ZIndex = 5 Instance.new("UICorner", trk).CornerRadius = UDim.new(1, 0)
    local th = Instance.new("Frame", trk) th.Size = UDim2.new(0, 18, 0, 18) th.Position = UDim2.new(0, 2, 0.5, -9) th.BackgroundColor3 = Color3.fromRGB(220, 220, 220) th.ZIndex = 5 Instance.new("UICorner", th).CornerRadius = UDim.new(1, 0)
    local btn = Instance.new("TextButton", h) btn.Size = UDim2.new(1, 0, 1, 0) btn.BackgroundTransparency = 1 btn.Text = "" btn.ZIndex = 6
    local a = false
    btn.MouseButton1Click:Connect(function() a = not a if a then T:Create(trk, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play() T:Create(th, TweenInfo.new(0.2), {Position = UDim2.new(1, -20, 0.5, -9), BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play() else T:Create(trk, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play() T:Create(th, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -9), BackgroundColor3 = Color3.fromRGB(220, 220, 220)}):Play() end reg(tx .. " " .. (a and "ON" or "OFF")) cb(a) end)
    return h
end

local function sl(p, tx, min, max, def, cb)
    local f = Instance.new("Frame", p) f.Size = UDim2.new(1, 0, 0, 25) f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f) l.Size = UDim2.new(1, -40, 0, 12) l.BackgroundTransparency = 1 l.Text = tx l.TextColor3 = Color3.fromRGB(200, 200, 200) l.TextSize = 11 l.Font = Enum.Font.Gotham l.TextXAlignment = Enum.TextXAlignment.Left
    local v = Instance.new("TextLabel", f) v.Size = UDim2.new(0, 40, 0, 12) v.Position = UDim2.new(1, -40, 0, 0) v.BackgroundTransparency = 1 v.Text = tostring(def) v.TextColor3 = Color3.fromRGB(150,150,150) v.TextSize = 10 v.TextXAlignment = Enum.TextXAlignment.Right
    local bg = Instance.new("Frame", f) bg.Size = UDim2.new(1, 0, 0, 3) bg.Position = UDim2.new(0, 0, 0, 18) bg.BackgroundColor3 = Color3.fromRGB(40,40,40) Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)
    local fill = Instance.new("Frame", bg) fill.Size = UDim2.new((def-min)/(max-min), 0, 1, 0) fill.BackgroundColor3 = ACCENT Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
    local active = false
    local function upd(x) local pct = math.clamp((x-bg.AbsolutePosition.X)/bg.AbsoluteSize.X, 0, 1) local val = math.floor(min+(max-min)*pct) fill.Size = UDim2.new(pct,0,1,0) v.Text = tostring(val) cb(val) end
    bg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = true upd(i.Position.X) end end)
    U.InputChanged:Connect(function(i) if active and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i.Position.X) end end)
    U.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = false reg(tx.." alterado") end end)
end

local function colorPicker(p, tx, initC, cb)
    local g = card(tx, p, ACCENT)
    local sw = Instance.new("Frame", g) sw.Size = UDim2.new(1, 0, 0, 24) sw.BackgroundColor3 = initC Instance.new("UICorner", sw).CornerRadius = UDim.new(0, 4)
    local r, gv, b = math.floor(initC.R*255), math.floor(initC.G*255), math.floor(initC.B*255)
    local function upd() local c = Color3.fromRGB(r, gv, b) sw.BackgroundColor3 = c cb(c) end
    sl(g, "Red (R)", 0, 255, r, function(v) r = v upd() end)
    sl(g, "Green (G)", 0, 255, gv, function(v) gv = v upd() end)
    sl(g, "Blue (B)", 0, 255, b, function(v) b = v upd() end)
end

-- =======================================================
-- LOGICA VISUALS / AIMBOT
-- =======================================================
local drawEsp = {} local highlights = {}
local function getPart(c, n) return c:FindFirstChild(n) or c:FindFirstChild("Torso") end
local function updVisuals()
    local color = CFG.Vis.Rainbow and Color3.fromHSV((tick() % 5) / 5, 1, 1) or CFG.Vis.Color
    for _, p in ipairs(P:GetPlayers()) do
        if p ~= LP and p.Character then
            local char = p.Character local hrp = char:FindFirstChild("HumanoidRootPart") local head = char:FindFirstChild("Head") local hum = char:FindFirstChildOfClass("Humanoid")
            if hrp and head and hum and hum.Health > 0 then
                local sp, on = C:WorldToViewportPoint(head.Position) local bot, botOn = C:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
                if CFG.Vis.Chams then if not highlights[p] then local h = Instance.new("Highlight", gui) h.Adornee = char h.FillColor = color h.FillTransparency = 0.5 h.OutlineTransparency = 1 highlights[p] = h end highlights[p].FillColor = color highlights[p].Enabled = true elseif highlights[p] then highlights[p].Enabled = false end
                if on and botOn then
                    if not drawEsp[p] then drawEsp[p] = { Box = D.new("Square"), Name = D.new("Text"), Dist = D.new("Text"), Skeleton = {Head=D.new("Line"), Torso=D.new("Line"), L_Arm=D.new("Line"), R_Arm=D.new("Line"), L_Leg=D.new("Line"), R_Leg=D.new("Line")} } end
                    local d = drawEsp[p] local h = math.abs(bot.Y - sp.Y) local w = h * 0.55
                    d.Box.Visible = CFG.Vis.Box d.Box.Size = Vector2.new(w, h) d.Box.Position = Vector2.new(sp.X - w/2, sp.Y) d.Box.Color = color d.Box.Filled = CFG.Vis.Fill d.Box.Transparency = CFG.Vis.Fill and 0.5 or 1
                    d.Name.Visible = CFG.Vis.Name d.Name.Text = p.Name d.Name.Position = Vector2.new(sp.X, sp.Y - 15) d.Name.Size = 12 d.Name.Center = true d.Name.Outline = true d.Name.Color = color
                    d.Dist.Visible = CFG.Vis.Dist d.Dist.Text = math.floor((hrp.Position - C.CFrame.Position).Magnitude).."m" d.Dist.Position = Vector2.new(sp.X, sp.Y + h + 5) d.Dist.Size = 10 d.Dist.Center = true d.Dist.Outline = true d.Dist.Color = color
                    if CFG.Vis.Skel then
                        local function drawL(l, p1, p2) local s1, o1 = C:WorldToViewportPoint(p1) local s2, o2 = C:WorldToViewportPoint(p2) l.Visible = o1 and o2 if l.Visible then l.From = Vector2.new(s1.X, s1.Y) l.To = Vector2.new(s2.X, s2.Y) l.Color = color l.Thickness = 1 end end
                        local uT = getPart(char, "UpperTorso") or getPart(char, "Torso") local lT = getPart(char, "LowerTorso")
                        if uT and lT then drawL(d.Skeleton.Head, head.Position, uT.Position) drawL(d.Skeleton.Torso, uT.Position, lT.Position) local la = getPart(char, "LeftHand") or getPart(char, "Left Arm") local ra = getPart(char, "RightHand") or getPart(char, "Right Arm") local ll = getPart(char, "LeftFoot") or getPart(char, "Left Leg") local rl = getPart(char, "RightFoot") or getPart(char, "Right Leg") if la then drawL(d.Skeleton.L_Arm, uT.Position, la.Position) end if ra then drawL(d.Skeleton.R_Arm, uT.Position, ra.Position) end if ll then drawL(d.Skeleton.L_Leg, lT.Position, ll.Position) end if rl then drawL(d.Skeleton.R_Leg, lT.Position, rl.Position) end end
                    else for _, l in pairs(d.Skeleton) do l.Visible = false end end
                else if drawEsp[p] then drawEsp[p].Box.Visible = false drawEsp[p].Name.Visible = false drawEsp[p].Dist.Visible = false for _, l in pairs(drawEsp[p].Skeleton) do l.Visible = false end end end
            end
        end
    end
    if cloneModel and CFG.Vis.Chams then local h = cloneModel:FindFirstChildOfClass("Highlight") if not h then h = Instance.new("Highlight", cloneModel) end h.FillColor = color h.FillTransparency = 0.5 h.OutlineTransparency = 1 elseif cloneModel then local h = cloneModel:FindFirstChildOfClass("Highlight") if h then h:Destroy() end end
end

local fovCircle = D.new("Circle") fovCircle.Thickness = 1 fovCircle.NumSides = 64 fovCircle.Visible = false
local oldHitboxSizes = {}
local function resetHitboxes() for p, s in pairs(oldHitboxSizes) do if p and p.Parent then p.Size = s end end oldHitboxSizes = {} end
local function getTarget()
    local center = Vector2.new(C.ViewportSize.X / 2, C.ViewportSize.Y / 2) local best, bestDist = nil, math.huge
    for _, p in ipairs(P:GetPlayers()) do if p ~= LP and p.Character then local part = p.Character:FindFirstChild(CFG.Aim.Part) if part then local sp, on = C:WorldToViewportPoint(part.Position) if on then local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude if dist < CFG.Aim.FOV and dist < bestDist then bestDist = dist best = part end end end end end
    return best
end
local silentPos = nil
if hookmetamethod then
    local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        if CFG.Aim.On and CFG.Aim.Silent and silentPos and getnamecallmethod() == "FindPartOnRay" then local args = {...} if typeof(args[1]) == "Ray" then args[1] = Ray.new(args[1].Origin, (silentPos - args[1].Origin).Unit * args[1].Direction.Magnitude) return oldNamecall(self, unpack(args)) end end
        return oldNamecall(self, ...)
    end)
end
U.InputBegan:Connect(function(i, gp) if gp then return end if i.KeyCode == CFG.Aim.Key then CFG.Aim.Holding = true end end)
U.InputEnded:Connect(function(i) if i.KeyCode == CFG.Aim.Key then CFG.Aim.Holding = false silentPos = nil end end)

local crossLines = {D.new("Line"), D.new("Line"), D.new("Line"), D.new("Line")} local crossDot = D.new("Square")
R.RenderStepped:Connect(function()
    if CFG.Hitbox.On then for _, p in ipairs(P:GetPlayers()) do if p ~= LP and p.Character then local part = p.Character:FindFirstChild(CFG.Hitbox.Part) if part then if not oldHitboxSizes[part] then oldHitboxSizes[part] = part.Size end part.Size = Vector3.new(CFG.Hitbox.X, CFG.Hitbox.Y, CFG.Hitbox.Z) part.Transparency = 0.5 part.Color = ACCENT part.CanCollide = false end end end else resetHitboxes() end
    if CFG.Aim.On then
        fovCircle.Visible = true fovCircle.Position = Vector2.new(C.ViewportSize.X / 2, C.ViewportSize.Y / 2) fovCircle.Radius = CFG.Aim.FOV fovCircle.Color = CFG.Vis.Color
        if CFG.Aim.Holding then local target = getTarget() if target then local predPos = target.Position + (target.Velocity * CFG.Aim.Predict) if CFG.Aim.Silent then silentPos = predPos end local want = CFrame.lookAt(C.CFrame.Position, predPos) C.CFrame = C.CFrame:Lerp(want, 1 - CFG.Aim.Smooth) if CFG.Aim.AutoFire then pcall(function() VU:CaptureController() VU:ClickButton1(Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)) end) end else silentPos = nil end else silentPos = nil end
    else fovCircle.Visible = false end
    if CFG.Rage.Spin and LP.Character then local hrp = LP.Character:FindFirstChild("HumanoidRootPart") if hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(45), 0) end end
    local center = Vector2.new(C.ViewportSize.X / 2, C.ViewportSize.Y / 2)
    if CFG.Cross.On then
        crossDot.Visible = CFG.Cross.Dot crossDot.Size = Vector2.new(2, 2) crossDot.Position = center - Vector2.new(1,1) crossDot.Color = CFG.Cross.Color crossDot.Filled = true
        local lines = { {center - Vector2.new(0, CFG.Cross.Gap), center - Vector2.new(0, CFG.Cross.Gap + CFG.Cross.Size)}, {center + Vector2.new(0, CFG.Cross.Gap), center + Vector2.new(0, CFG.Cross.Gap + CFG.Cross.Size)}, {center - Vector2.new(CFG.Cross.Gap, 0), center - Vector2.new(CFG.Cross.Gap + CFG.Cross.Size, 0)}, {center + Vector2.new(CFG.Cross.Gap, 0), center + Vector2.new(CFG.Cross.Gap + CFG.Cross.Size, 0)} }
        for i, l in ipairs(crossLines) do l.Visible = true l.From = lines[i][1] l.To = lines[i][2] l.Color = CFG.Cross.Color l.Thickness = 1 end
    else crossDot.Visible = false for _, l in ipairs(crossLines) do l.Visible = false end end
end)

-- =======================================================
-- CONSTRUÇÃO DAS ABAS (AS FUNÇÕES ORIGINAIS)
-- =======================================================
local function buildMain()
    local g = card("DASHBOARD", sec["Main"], ACCENT)
    local infoLbl = Instance.new("TextLabel", g) infoLbl.Size = UDim2.new(1,0,0,20) infoLbl.BackgroundTransparency = 1 infoLbl.Text = "Bem-vindo, "..LP.DisplayName infoLbl.TextColor3 = Color3.fromRGB(255,255,255) infoLbl.TextSize = 14 infoLbl.Font = Enum.Font.GothamBold infoLbl.TextXAlignment = Enum.TextXAlignment.Left
    local infoLbl2 = Instance.new("TextLabel", g) infoLbl2.Size = UDim2.new(1,0,0,14) infoLbl2.BackgroundTransparency = 1 infoLbl2.Text = "Executor: "..executor infoLbl2.TextColor3 = TEXT infoLbl2.TextSize = 11 infoLbl2.Font = Enum.Font.Gotham infoLbl2.TextXAlignment = Enum.TextXAlignment.Left
    bt(g, "📋 Copiar HWID", function() pcall(function() setclipboard(hwid) end) end)
    bt(g, "💬 Entrar no Discord", function() pcall(function() setclipboard(URL_DISCORD) end) end)
end

local function buildESP()
    local g = card("ESP (VAC EXTERNAL)", sec["ESP"], Color3.fromRGB(220,220,220))
    btT(g, "ESP Box", true, function(v) CFG.Vis.Box = v end)
    btT(g, "Box Filled", false, function(v) CFG.Vis.Fill = v end)
    btT(g, "Skeleton", true, function(v) CFG.Vis.Skel = v end)
    btT(g, "Chams (Glow)", true, function(v) CFG.Vis.Chams = v end)
    btT(g, "Rainbow Mode", false, function(v) CFG.Vis.Rainbow = v end)
    btT(g, "Show Name", true, function(v) CFG.Vis.Name = v end)
    btT(g, "Show Distance", true, function(v) CFG.Vis.Dist = v end)
    colorPicker(g, "ESP COLOR", CFG.Vis.Color, function(c) CFG.Vis.Color = c end)
end

local function buildCombate()
    local g = card("AIMBOT PRO", sec["Combate"], Color3.fromRGB(255,100,100))
    btT(g, "Aimbot Toggle (Hold E)", false, function(v) CFG.Aim.On = v end)
    btT(g, "Silent Aim (Magic)", false, function(v) CFG.Aim.Silent = v end)
    btT(g, "Auto Fire", false, function(v) CFG.Aim.AutoFire = v end)
    sl(g, "FOV", 10, 500, 150, function(v) CFG.Aim.FOV = v end)
    sl(g, "Smooth", 1, 99, 30, function(v) CFG.Aim.Smooth = v / 100 end)
    sl(g, "Prediction", 0, 50, 16, function(v) CFG.Aim.Predict = v / 100 end)
    
    local h = card("HITBOX EXPANDER", sec["Combate"], Color3.fromRGB(255,100,100))
    btT(h, "Hitbox Enabled", false, function(v) CFG.Hitbox.On = v end)
    sl(h, "Size X", 1, 50, 20, function(v) CFG.Hitbox.X = v end)
    sl(h, "Size Y", 1, 50, 20, function(v) CFG.Hitbox.Y = v end)
    sl(h, "Size Z", 1, 50, 20, function(v) CFG.Hitbox.Z = v end)
end

local function buildMov()
    local g = card("MOVIMENTO", sec["Mov"], Color3.fromRGB(100,255,100))
    local spd = 16
    btT(g, "Speed Hack", false, function(v) task.spawn(function() while v do if LP.Character then local hu = LP.Character:FindFirstChildOfClass("Humanoid") if hu then hu.WalkSpeed = spd end end task.wait(0.1) end end) end)
    bt(g, "Aumentar Velocidade", function() spd = spd + 16 if spd > 200 then spd = 16 end if LP.Character then local hu = LP.Character:FindFirstChildOfClass("Humanoid") if hu then hu.WalkSpeed = spd end end end)
    btT(g, "Infinite Jump", false, function(v) CFG.Rage.InfJump = v end)
    U.JumpRequest:Connect(function() if CFG.Rage.InfJump and LP.Character then local h = LP.Character:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end)
end

local function buildTele()
    local g = card("TELECINESE", sec["Tele"], Color3.fromRGB(180,180,180))
    bt(g, "🚗 Puxar Carro", function()
        local m = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") if not m then return end
        local c = nil for _, o in ipairs(workspace:GetChildren()) do if o:IsA("Model") then local v = false for _, d in ipairs(o:GetChildren()) do if d:IsA("VehicleSeat") then v = true break end end if v then local pr = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart") if pr then c = pr break end end end end
        if not c then reg("Sem carro") return end
        local mod = c:FindFirstAncestorOfClass("Model") if not mod then return end
        for _, d in ipairs(mod:GetDescendants()) do if d:IsA("BasePart") and not d.Anchored then local b = Instance.new("BodyVelocity", d) b.Name = "ZEDUX_Pux" b.MaxForce = Vector3.new(5e5, 5e5, 5e5) task.spawn(function() while b.Parent do local mh = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") if not mh then break end local a = mh.Position + mh.CFrame.LookVector * 10 + Vector3.new(0, 3, 0) local di = a - d.Position b.Velocity = di.Magnitude < 8 and Vector3.zero or di.Unit * math.min(150, di.Magnitude * 3) R.Heartbeat:Wait() end end) break end end
    end)
    bt(g, "🔓 Soltar Tudo", function()
        for _, o in ipairs(workspace:GetDescendants()) do local b1 = o:FindFirstChild("ZEDUX_Pux") local b2 = o:FindFirstChild("ZEDUX_Lan") if b1 then b1:Destroy() end if b2 then b2:Destroy() end end
    end)
end

local function buildTroll()
    local g = card("TROLL", sec["Troll"], Color3.fromRGB(230,230,230))
    bt(g, "💥 Fling de Blocos", function()
        local h = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") if not h then return end
        local pasta = Instance.new("Folder", workspace) pasta.Name = "ZEDUX_Fling"
        for i=1, 25 do local b = Instance.new("Part", pasta) b.Size = Vector3.new(6,6,6) b.Position = h.Position + Vector3.new(math.random(-10,10), 5, math.random(-10,10)) b.Transparency = 0.5 b.Material = Enum.Material.Neon pcall(function() b:SetNetworkOwner(LP) end) local bv = Instance.new("BodyVelocity", b) bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge) bv.Name = "ZEDUX_FL" end
        task.spawn(function() local t = tick() while tick() - t < 5 do for _, b in ipairs(pasta:GetChildren()) do local bv = b:FindFirstChild("ZEDUX_FL") if bv then local dir = (h.Position + Vector3.new(0,0,0) - b.Position) bv.Velocity = dir.Magnitude > 3 and dir.Unit * 2500 or Vector3.new(math.random(-2000,2000),2000,math.random(-2000,2000)) end end R.Heartbeat:Wait() end pasta:Destroy() end)
    end, true)
    bt(g, "🌪️ Puxar TUDO", function()
        if not LP.Character then return end
        local mh = LP.Character:FindFirstChild("HumanoidRootPart") if not mh then return end
        local obj = {}
        for _, p in ipairs(workspace:GetDescendants()) do if #obj >= 50 then break end if p:IsA("BasePart") and not p.Anchored and not p:IsDescendantOf(LP.Character) then table.insert(obj, p) end end
        for _, p in ipairs(obj) do pcall(function() p:SetNetworkOwner(LP) local bv = Instance.new("BodyVelocity", p) bv.Name = "ZEDUX_Pull" bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge) task.spawn(function() while bv.Parent do local aim = mh.Position + mh.CFrame.LookVector * 5 bv.Velocity = (aim - p.Position).Unit * 150 R.Heartbeat:Wait() end end) end) end
        task.delay(4, function() for _, p in ipairs(obj) do local b = p:FindFirstChild("ZEDUX_Pull") if b then b:Destroy() end end end)
    end)
end

local function buildPer()
    local g = card("PERSONALIZAÇÃO", sec["Personalizacao"], Color3.fromRGB(180,180,180))
    bt(g, "👻 Transparência", function() local t = w.BackgroundTransparency + 0.1 if t > 0.9 then t = 0 end w.BackgroundTransparency = t end)
end

local function buildConfig()
    local g = card("INTERFACE", sec["Config"], Color3.fromRGB(150,150,150))
    local tms = {{n="Pequeno", w=500, h=320}, {n="Médio", w=780, h=480}, {n="Grande", w=1000, h=600}} local tI = 2
    bt(g, "📐 Tamanho", function() tI = tI % 3 + 1 local t = tms[tI] w.Size = UDim2.new(0, t.w, 0, t.h) end)
    bt(g, "🔄 Rejoin", function() game:GetService("TeleportService"):Teleport(game.PlaceId, LP) end)
    bt(g, "🗑️ Fechar Painel", function() gui:Destroy() end, true)
end

local function buildAdm()
    local g = card("ADMIN", sec["Adm"], Color3.fromRGB(255,255,255))
    bt(g, "Aprovar Player", function() reg("Aprovado") end)
end
local function buildKeys()
    local g = card("KEYS", sec["Keys"], Color3.fromRGB(230,230,230))
    bt(g, "Gerar Key VIP", function() local k = "ZEDUX-HUB-"..math.random(1000,9999) KEYS_VALIDAS[k] = true reg("Key: "..k) end)
end
local function buildLog()
    local g = card("LOGS", sec["Log"], Color3.fromRGB(200,200,200))
    local sf = Instance.new("ScrollingFrame", g) sf.Size = UDim2.new(1, 0, 0, 150) sf.BackgroundColor3 = Color3.fromRGB(15,15,15) sf.AutomaticCanvasSize = Enum.AutomaticSize.Y Instance.new("UICorner", sf).CornerRadius = UDim.new(0,4)
    local ll = Instance.new("UIListLayout", sf) ll.Padding = UDim.new(0,2)
    for _, txt in ipairs(lg) do local l = Instance.new("TextLabel", sf) l.Size = UDim2.new(1,0,0,18) l.BackgroundTransparency = 1 l.Text = "["..txt.h.."] "..txt.a l.TextColor3 = TEXT l.TextSize = 9 l.Font = Enum.Font.Code l.TextXAlignment = Enum.TextXAlignment.Left end
end

-- Constrói todas
buildMain() buildESP() buildCombate() buildMov() buildTele() buildTroll() buildPer() buildConfig()
if AD then buildAdm() buildKeys() buildLog() end

R.RenderStepped:Connect(function() pcall(updVisuals) end)
