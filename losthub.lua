--// ZEDUX HUB v34.0 - PARTE 1: BASE E VISUAL
local P = game:GetService("Players")
local U = game:GetService("UserInputService")
local R = game:GetService("RunService")
local T = game:GetService("TweenService")
local LP = P.LocalPlayer
local C = workspace.CurrentCamera
local S = {sel = nil}
local lg = {}

local URL_DISCORD = "https://discord.gg/s6GSy4TuJ"
local KEYFILE, TEMPOFILE, LOGFILE = "zedux_keys.txt", "zedux_tempo.txt", "zedux_logs.txt"

local executor, device, hwid = "Desconhecido", "PC", "N/A"
pcall(function() executor = getexecutorname() or identifyexecutor() end)
if type(executor) == "table" then executor = executor[1] end
if U.TouchEnabled and not U.KeyboardEnabled then device = "Mobile" end
if U.GamepadEnabled then device = "Console" end
pcall(function() hwid = gethwid() end)

local OID = 4197733654
local CG = (LP.UserId == OID) and "PROPRIETÁRIO" or "JOGADOR"
local isVipOuSuperior = (LP.UserId == OID)

local function reg(a) 
    local h = os.date("%d/%m/%Y %H:%M:%S") 
    table.insert(lg, {h = h, j = LP.Name, a = a}) 
    pcall(function() appendfile(LOGFILE, h .. "|" .. LP.Name .. "|" .. a .. "\n") end) 
end

local function IniciarIntro()
    local introGui = Instance.new("ScreenGui", game:GetService("CoreGui")) 
    introGui.ResetOnSpawn = false 
    introGui.DisplayOrder = 999999
    
    local main = Instance.new("Frame", introGui) 
    main.Size = UDim2.new(0, 400, 0, 300) 
    main.Position = UDim2.new(0.5, -200, 0.5, -150) 
    main.BackgroundColor3 = Color3.fromRGB(10, 10, 12) 
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12) 
    Instance.new("UIStroke", main).Color = Color3.fromRGB(60, 60, 70)
    
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
    keyBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25) 
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255) 
    keyBox.PlaceholderText = "Digite sua key..." 
    keyBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100) 
    Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8) 
    Instance.new("UIStroke", keyBox).Color = Color3.fromRGB(150, 150, 150)
    
    local redeemBtn = Instance.new("TextButton", main) 
    redeemBtn.Size = UDim2.new(0.8, 0, 0, 40) 
    redeemBtn.Position = UDim2.new(0.1, 0, 0, 165) 
    redeemBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35) 
    redeemBtn.Text = "Validar Key" 
    redeemBtn.TextColor3 = Color3.fromRGB(255, 255, 255) 
    redeemBtn.Font = Enum.Font.GothamBold 
    Instance.new("UICorner", redeemBtn).CornerRadius = UDim.new(0, 8)
    
    local discordBtn = Instance.new("TextButton", main) 
    discordBtn.Size = UDim2.new(0.8, 0, 0, 30) 
    discordBtn.Position = UDim2.new(0.1, 0, 0, 220) 
    discordBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 150) 
    discordBtn.Text = "Entrar no Discord" 
    discordBtn.TextColor3 = Color3.fromRGB(255, 255, 255) 
    discordBtn.Font = Enum.Font.GothamBold 
    Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0, 8)
    discordBtn.MouseButton1Click:Connect(function() pcall(function() game:GetService("GuiService"):OpenBrowserWindow(URL_DISCORD) end) end)
    
    local statusLog = Instance.new("TextLabel", main) 
    statusLog.Size = UDim2.new(0.8, 0, 0, 20) 
    statusLog.Position = UDim2.new(0.1, 0, 0, 260) 
    statusLog.BackgroundTransparency = 1 
    statusLog.TextColor3 = Color3.fromRGB(80, 255, 120) 
    statusLog.TextSize = 10 
    statusLog.Font = Enum.Font.Gotham
    
    redeemBtn.MouseButton1Click:Connect(function() 
        if keyBox.Text:gsub("%s+", "") ~= "" then 
            statusLog.Text = "Key válida!" 
            task.wait(1) 
            introGui:Destroy() 
        else 
            statusLog.TextColor3 = Color3.fromRGB(255, 80, 80) 
            statusLog.Text = "Key inválida." 
        end 
    end)
    
    if isVipOuSuperior then task.wait(0.5) introGui:Destroy() else repeat task.wait() until not introGui.Parent end
end
IniciarIntro()

local gui = Instance.new("ScreenGui", game:GetService("CoreGui")) 
gui.ResetOnSpawn = false 
gui.IgnoreGuiInset = true 
gui.DisplayOrder = 99999

local w = Instance.new("Frame", gui) 
w.Size = UDim2.new(0, 700, 0, 480) 
w.Position = UDim2.new(0.5, -350, 0.5, -240) 
w.BackgroundColor3 = Color3.fromRGB(15, 15, 18) 
Instance.new("UICorner", w).CornerRadius = UDim.new(0, 8) 
Instance.new("UIStroke", w).Color = Color3.fromRGB(60, 60, 70) 
w.ClipsDescendants = true

local starLayer = Instance.new("Frame", w) 
starLayer.Size = UDim2.new(1, 0, 1, 0) 
starLayer.BackgroundTransparency = 1 
starLayer.ZIndex = 1 
starLayer.ClipsDescendants = true
for i = 1, 100 do
    local star = Instance.new("Frame", starLayer) 
    local size = math.random(1, 3) 
    star.Size = UDim2.new(0, size, 0, size) 
    star.Position = UDim2.new(math.random(), 0, math.random(), 0) 
    star.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
    star.BackgroundTransparency = math.random(3, 8) / 10 
    star.BorderSizePixel = 0 
    star.ZIndex = 1 
    Instance.new("UICorner", star).CornerRadius = UDim.new(1, 0)
    task.spawn(function() 
        while star.Parent do 
            local tempoPiscar = math.random(10, 30) / 10 
            local transAlvo = math.random(0, 8) / 10 
            T:Create(star, TweenInfo.new(tempoPiscar, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = transAlvo}):Play() 
            task.wait(tempoPiscar) 
            local posAtual = star.Position 
            T:Create(star, TweenInfo.new(3, Enum.EasingStyle.Linear), {Position = UDim2.new(posAtual.X.Scale, 0, posAtual.Y.Scale + 0.05, 0)}):Play() 
            task.wait(3) 
            if star.Position.Y.Scale > 1 then star.Position = UDim2.new(math.random(), 0, -0.05, 0) end 
        end 
    end)
end

local topBar = Instance.new("Frame", w) 
topBar.Size = UDim2.new(1, 0, 0, 50) 
topBar.BackgroundTransparency = 1 
topBar.ZIndex = 50
local dragging, dragInput, dragStart, startPos
local function updateDrag(input) 
    local delta = input.Position - dragStart 
    w.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) 
end
topBar.InputBegan:Connect(function(input) 
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
        dragging = true 
        dragStart = input.Position 
        startPos = w.Position 
        input.Changed:Connect(function() 
            if input.UserInputState == Enum.UserInputState.End then dragging = false end 
        end) 
    end 
end)
topBar.InputChanged:Connect(function(input) 
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then 
        dragInput = input 
    end 
end)
U.InputChanged:Connect(function(input) 
    if input == dragInput and dragging then updateDrag(input) end 
end)

local gengarGif = Instance.new("ImageLabel", w) 
gengarGif.Size = UDim2.new(0, 45, 0, 45) 
gengarGif.Position = UDim2.new(0, 10, 0, 2) 
gengarGif.BackgroundTransparency = 1 
gengarGif.Image = "rbxassetid://8031522141" 
gengarGif.ZIndex = 51
task.spawn(function() 
    local tempo = 0 
    while gengarGif.Parent do 
        tempo = tempo + 0.05 
        gengarGif.Size = UDim2.new(0, 45 * (1 + math.sin(tempo) * 0.05), 0, 45 * (1 + math.sin(tempo) * 0.05)) 
        gengarGif.Rotation = math.sin(tempo * 2) * 3 
        task.wait(0.05) 
    end 
end)

local btnDiminuir = Instance.new("TextButton", w) 
btnDiminuir.Size = UDim2.new(0, 25, 0, 25) 
btnDiminuir.Position = UDim2.new(1, -95, 0, 12) 
btnDiminuir.BackgroundColor3 = Color3.fromRGB(30, 30, 35) 
btnDiminuir.Text = "-" 
btnDiminuir.TextColor3 = Color3.fromRGB(255, 255, 255) 
btnDiminuir.Font = Enum.Font.GothamBold 
Instance.new("UICorner", btnDiminuir).CornerRadius = UDim.new(0, 4) 
btnDiminuir.ZIndex = 51

local btnAumentar = Instance.new("TextButton", w) 
btnAumentar.Size = UDim2.new(0, 25, 0, 25) 
btnAumentar.Position = UDim2.new(1, -65, 0, 12) 
btnAumentar.BackgroundColor3 = Color3.fromRGB(30, 30, 35) 
btnAumentar.Text = "+" 
btnAumentar.TextColor3 = Color3.fromRGB(255, 255, 255) 
btnAumentar.Font = Enum.Font.GothamBold 
Instance.new("UICorner", btnAumentar).CornerRadius = UDim.new(0, 4) 
btnAumentar.ZIndex = 51

local btnFechar = Instance.new("TextButton", w) 
btnFechar.Size = UDim2.new(0, 25, 0, 25) 
btnFechar.Position = UDim2.new(1, -35, 0, 12) 
btnFechar.BackgroundColor3 = Color3.fromRGB(60, 20, 20) 
btnFechar.Text = "X" 
btnFechar.TextColor3 = Color3.fromRGB(255, 255, 255) 
btnFechar.Font = Enum.Font.GothamBold 
Instance.new("UICorner", btnFechar).CornerRadius = UDim.new(0, 4) 
btnFechar.ZIndex = 51

btnDiminuir.MouseButton1Click:Connect(function() 
    local tam = w.Size 
    T:Create(w, TweenInfo.new(0.2), {Size = UDim2.new(0, math.max(400, tam.X.Offset - 50), 0, math.max(300, tam.Y.Offset - 30))}):Play() 
end)
btnAumentar.MouseButton1Click:Connect(function() 
    local tam = w.Size 
    T:Create(w, TweenInfo.new(0.2), {Size = UDim2.new(0, math.min(1000, tam.X.Offset + 50), 0, math.min(600, tam.Y.Offset + 30))}):Play() 
end)
btnFechar.MouseButton1Click:Connect(function() gui:Destroy() end)
U.InputBegan:Connect(function(input, gp) 
    if gp then return end 
    if input.KeyCode == Enum.KeyCode.K then w.Visible = not w.Visible end 
end)

local sb = Instance.new("Frame", w) 
sb.Size = UDim2.new(0, 180, 1, 0) 
sb.BackgroundColor3 = Color3.fromRGB(20, 20, 24) 
sb.BorderSizePixel = 0 
Instance.new("UICorner", sb).CornerRadius = UDim.new(0, 8) 
sb.ZIndex = 10

local sbScroll = Instance.new("ScrollingFrame", sb) 
sbScroll.Size = UDim2.new(1, 0, 1, -60) 
sbScroll.BackgroundTransparency = 1 
sbScroll.ScrollBarThickness = 2 
sbScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90) 
sbScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y 
sbScroll.CanvasSize = UDim2.new(0, 0, 0, 0) 
Instance.new("UIPadding", sbScroll).PaddingTop = UDim.new(0, 10) 
sbScroll.ZIndex = 11

local layoutSidebar = Instance.new("UIListLayout", sbScroll) 
layoutSidebar.Padding = UDim.new(0, 4) 
layoutSidebar.HorizontalAlignment = Enum.HorizontalAlignment.Center 
layoutSidebar.SortOrder = Enum.SortOrder.LayoutOrder

local profileFrame = Instance.new("Frame", sb) 
profileFrame.Size = UDim2.new(1, -20, 0, 50) 
profileFrame.Position = UDim2.new(0, 10, 1, -58) 
profileFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 36) 
profileFrame.BorderSizePixel = 0 
profileFrame.ZIndex = 12 
Instance.new("UICorner", profileFrame).CornerRadius = UDim.new(0, 6) 
Instance.new("UIStroke", profileFrame).Color = Color3.fromRGB(70, 70, 80)

local avatar = Instance.new("ImageLabel", profileFrame) 
avatar.Size = UDim2.new(0, 36, 0, 36) 
avatar.Position = UDim2.new(0, 7, 0.5, -18) 
avatar.BackgroundColor3 = Color3.fromRGB(10, 10, 10) 
avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=150&h=150" 
avatar.ZIndex = 13 
Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0) 
Instance.new("UIStroke", avatar).Color = Color3.fromRGB(120, 120, 130)

local nick = Instance.new("TextLabel", profileFrame) 
nick.Size = UDim2.new(1, -50, 0, 15) 
nick.Position = UDim2.new(0, 50, 0, 10) 
nick.BackgroundTransparency = 1 
nick.Text = LP.DisplayName 
nick.TextColor3 = Color3.fromRGB(255, 255, 255) 
nick.TextSize = 11 
nick.Font = Enum.Font.GothamBold 
nick.TextXAlignment = Enum.TextXAlignment.Left 
nick.TextTruncate = Enum.TextTruncate.AtEnd 
nick.ZIndex = 13

local cargo = Instance.new("TextLabel", profileFrame) 
cargo.Size = UDim2.new(1, -50, 0, 12) 
cargo.Position = UDim2.new(0, 50, 0, 26) 
cargo.BackgroundTransparency = 1 
cargo.Text = CG 
cargo.TextColor3 = Color3.fromRGB(160, 160, 160) 
cargo.TextSize = 9 
cargo.Font = Enum.Font.GothamBold 
cargo.TextXAlignment = Enum.TextXAlignment.Left 
cargo.ZIndex = 13

local onlineDot = Instance.new("Frame", profileFrame) 
onlineDot.Size = UDim2.new(0, 6, 0, 6) 
onlineDot.Position = UDim2.new(1, -12, 0, 8) 
onlineDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100) 
onlineDot.ZIndex = 14 
Instance.new("UICorner", onlineDot).CornerRadius = UDim.new(1, 0)

local mn = Instance.new("Frame", w) 
mn.Size = UDim2.new(1, -180, 1, 0) 
mn.Position = UDim2.new(0, 180, 0, 0) 
mn.BackgroundTransparency = 1 
mn.ClipsDescendants = true 
mn.ZIndex = 10

local ct = Instance.new("Frame", mn) 
ct.Size = UDim2.new(1, -20, 1, -20) 
ct.Position = UDim2.new(0, 10, 0, 10) 
ct.BackgroundTransparency = 1 
ct.ZIndex = 11

local function yoxCard(parent, title, symbol)
    local cf = Instance.new("Frame", parent) 
    cf.Size = UDim2.new(1, 0, 0, 0) 
    cf.AutomaticSize = Enum.AutomaticSize.Y 
    cf.BackgroundColor3 = Color3.fromRGB(35, 35, 42) 
    cf.ZIndex = 20 
    Instance.new("UICorner", cf).CornerRadius = UDim.new(0, 6) 
    Instance.new("UIStroke", cf).Color = Color3.fromRGB(70, 70, 80)
    
    local tl = Instance.new("TextLabel", cf) 
    tl.Size = UDim2.new(1, -20, 0, 25) 
    tl.Position = UDim2.new(0, 10, 0, 5) 
    tl.BackgroundTransparency = 1 
    tl.Text = symbol .. "  " .. title 
    tl.TextColor3 = Color3.fromRGB(255, 255, 255) 
    tl.TextSize = 11 
    tl.Font = Enum.Font.GothamBold 
    tl.TextXAlignment = Enum.TextXAlignment.Left 
    tl.ZIndex = 21
    
    local c = Instance.new("Frame", cf) 
    c.Size = UDim2.new(1, -20, 0, 0) 
    c.Position = UDim2.new(0, 10, 0, 25) 
    c.AutomaticSize = Enum.AutomaticSize.Y 
    c.BackgroundTransparency = 1 
    c.ZIndex = 21 
    Instance.new("UIListLayout", c).Padding = UDim.new(0, 5) 
    return c
end

local function yoxToggle(parent, text, callback)
    local f = Instance.new("Frame", parent) 
    f.Size = UDim2.new(1, 0, 0, 25) 
    f.BackgroundTransparency = 1 
    f.ZIndex = 22
    local l = Instance.new("TextLabel", f) 
    l.Size = UDim2.new(1, -40, 1, 0) 
    l.BackgroundTransparency = 1 
    l.Text = text 
    l.TextColor3 = Color3.fromRGB(220, 220, 220) 
    l.TextSize = 10 
    l.Font = Enum.Font.Gotham 
    l.TextXAlignment = Enum.TextXAlignment.Left 
    l.ZIndex = 23
    
    local s = Instance.new("Frame", f) 
    s.Size = UDim2.new(0, 30, 0, 15) 
    s.Position = UDim2.new(1, -30, 0.5, -7.5) 
    s.BackgroundColor3 = Color3.fromRGB(60, 60, 60) 
    s.ZIndex = 23 
    Instance.new("UICorner", s).CornerRadius = UDim.new(1, 0)
    
    local c = Instance.new("Frame", s) 
    c.Size = UDim2.new(0, 11, 0, 11) 
    c.Position = UDim2.new(0, 2, 0.5, -5.5) 
    c.BackgroundColor3 = Color3.fromRGB(200, 200, 200) 
    c.ZIndex = 24 
    Instance.new("UICorner", c).CornerRadius = UDim.new(1, 0)
    
    local b = Instance.new("TextButton", f) 
    b.Size = UDim2.new(1, 0, 1, 0) 
    b.BackgroundTransparency = 1 
    b.Text = "" 
    b.ZIndex = 25
    
    local st = false
    b.MouseButton1Click:Connect(function() 
        st = not st 
        if st then 
            T:Create(s, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play() 
            T:Create(c, TweenInfo.new(0.2), {Position = UDim2.new(1, -13, 0.5, -5.5), BackgroundColor3 = Color3.fromRGB(0, 0, 0)}):Play() 
        else 
            T:Create(s, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play() 
            T:Create(c, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -5.5), BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play() 
        end 
        if callback then callback(st) end 
    end)
end

local function yoxSlider(parent, text, min, max, default, callback)
    local f = Instance.new("Frame", parent) 
    f.Size = UDim2.new(1, 0, 0, 35) 
    f.BackgroundTransparency = 1 
    f.ZIndex = 22
    
    local l = Instance.new("TextLabel", f) 
    l.Size = UDim2.new(1, -30, 0, 15) 
    l.BackgroundTransparency = 1 
    l.Text = text 
    l.TextColor3 = Color3.fromRGB(220, 220, 220) 
    l.TextSize = 10 
    l.Font = Enum.Font.Gotham 
    l.TextXAlignment = Enum.TextXAlignment.Left 
    l.ZIndex = 23
    
    local v = Instance.new("TextLabel", f) 
    v.Size = UDim2.new(0, 30, 0, 15) 
    v.Position = UDim2.new(1, -30, 0, 0) 
    v.BackgroundTransparency = 1 
    v.Text = tostring(default) 
    v.TextColor3 = Color3.fromRGB(160, 160, 160) 
    v.TextSize = 9 
    v.Font = Enum.Font.GothamBold 
    v.TextXAlignment = Enum.TextXAlignment.Right 
    v.ZIndex = 23
    
    local bg = Instance.new("Frame", f) 
    bg.Size = UDim2.new(1, 0, 0, 4) 
    bg.Position = UDim2.new(0, 0, 0, 25) 
    bg.BackgroundColor3 = Color3.fromRGB(60, 60, 60) 
    bg.ZIndex = 23 
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    
    local fi = Instance.new("Frame", bg) 
    fi.Size = UDim2.new((default - min) / (max - min), 0, 1, 0) 
    fi.BackgroundColor3 = Color3.fromRGB(200, 200, 200) 
    fi.ZIndex = 24 
    Instance.new("UICorner", fi).CornerRadius = UDim.new(1, 0)
    
    local dr = false 
    local b = Instance.new("TextButton", bg) 
    b.Size = UDim2.new(1, 0, 2, 0) 
    b.Position = UDim2.new(0, 0, 0, -4) 
    b.BackgroundTransparency = 1 
    b.Text = "" 
    b.ZIndex = 25
    
    local function update(input) 
        local x = math.clamp(input.Position.X - bg.AbsolutePosition.X, 0, bg.AbsoluteSize.X) 
        local p = x / bg.AbsoluteSize.X 
        local val = math.floor(min + (max - min) * p) 
        fi.Size = UDim2.new(p, 0, 1, 0) 
        v.Text = tostring(val) 
        if callback then callback(val) end 
    end
    
    b.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dr = true 
            update(input) 
        end 
    end)
    U.InputChanged:Connect(function(input) 
        if dr and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then 
            update(input) 
        end 
    end)
    U.InputEnded:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dr = false 
        end 
    end)
end

local tabs = {"⌂ Main", "⛹ Rage", "◈ Aimbot", "▣ Visuals", "◍ Players", "◎ Telecinese", "▤ Explorer", "⌨ Chat", "☾ Ambiente", "◐ Settings", "≡ Registros"}
local pages, btns = {}, {}
for i, name in ipairs(tabs) do
    local b = Instance.new("TextButton", sbScroll) 
    b.Size = UDim2.new(1, -20, 0, 32) 
    b.LayoutOrder = i 
    b.BackgroundColor3 = Color3.fromRGB(25, 25, 30) 
    b.Text = "  " .. name 
    b.TextColor3 = Color3.fromRGB(190, 190, 190) 
    b.TextXAlignment = Enum.TextXAlignment.Left 
    b.Font = Enum.Font.GothamBold 
    b.TextSize = 11 
    b.AutoButtonColor = false 
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4) 
    b.ZIndex = 12
    
    local p = Instance.new("ScrollingFrame", ct) 
    p.Size = UDim2.new(1, 0, 1, 0) 
    p.BackgroundTransparency = 1 
    p.ScrollBarThickness = 3 
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y 
    p.Visible = false 
    Instance.new("UIListLayout", p).Padding = UDim.new(0, 8) 
    p.ZIndex = 12
    
    pages[name] = p 
    btns[name] = b
    
    b.MouseButton1Click:Connect(function() 
        for n, bt in pairs(btns) do 
            bt.BackgroundColor3 = Color3.fromRGB(25, 25, 30) 
            bt.TextColor3 = Color3.fromRGB(190, 190, 190) 
            pages[n].Visible = false 
        end 
        b.BackgroundColor3 = Color3.fromRGB(45, 45, 55) 
        b.TextColor3 = Color3.fromRGB(255, 255, 255) 
        p.Visible = true 
    end)
end
btns["⌂ Main"].BackgroundColor3 = Color3.fromRGB(45, 45, 55) 
btns["⌂ Main"].TextColor3 = Color3.fromRGB(255, 255, 255) 
pages["⌂ Main"].Visible = true--// ZEDUX HUB v34.0 - PARTE 2: DASHBOARD, RAGE, AIMBOT E VISUALS

-- DASHBOARD (MAIN)
local mainCard = yoxCard(pages["⌂ Main"], "Dashboard", "⌂")
local welcomeCard = Instance.new("Frame", mainCard) 
welcomeCard.Size = UDim2.new(1, 0, 0, 80) 
welcomeCard.BackgroundColor3 = Color3.fromRGB(45, 45, 52) 
Instance.new("UICorner", welcomeCard).CornerRadius = UDim.new(0, 6)

local avatarBall = Instance.new("ImageLabel", welcomeCard) 
avatarBall.Size = UDim2.new(0, 60, 0, 60) 
avatarBall.Position = UDim2.new(0, 10, 0.5, -30) 
avatarBall.BackgroundColor3 = Color3.fromRGB(20, 20, 20) 
avatarBall.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=150&h=150" 
Instance.new("UICorner", avatarBall).CornerRadius = UDim.new(1, 0) 
Instance.new("UIStroke", avatarBall).Color = Color3.fromRGB(200, 200, 200)

local welcomeText = Instance.new("TextLabel", welcomeCard) 
welcomeText.Size = UDim2.new(1, -90, 0, 20) 
welcomeText.Position = UDim2.new(0, 80, 0, 20) 
welcomeText.BackgroundTransparency = 1 
welcomeText.Text = "Bem-vindo de volta," 
welcomeText.TextColor3 = Color3.fromRGB(200, 200, 200) 
welcomeText.TextSize = 11 
welcomeText.Font = Enum.Font.Gotham 
welcomeText.TextXAlignment = Enum.TextXAlignment.Left

local nameText = Instance.new("TextLabel", welcomeCard) 
nameText.Size = UDim2.new(1, -90, 0, 25) 
nameText.Position = UDim2.new(0, 80, 0, 38) 
nameText.BackgroundTransparency = 1 
nameText.Text = LP.DisplayName 
nameText.TextColor3 = Color3.fromRGB(255, 255, 255) 
nameText.TextSize = 18 
nameText.Font = Enum.Font.GothamBold 
nameText.TextXAlignment = Enum.TextXAlignment.Left

local sysCard = yoxCard(pages["⌂ Main"], "System Info", "▦")
local function addInfoLinha(texto, valor, cor) 
    local row = Instance.new("Frame", sysCard) 
    row.Size = UDim2.new(1, 0, 0, 20) 
    row.BackgroundTransparency = 1 
    local l = Instance.new("TextLabel", row) 
    l.Size = UDim2.new(0.5, 0, 1, 0) 
    l.BackgroundTransparency = 1 
    l.Text = texto 
    l.TextColor3 = Color3.fromRGB(150, 150, 150) 
    l.TextSize = 10 
    l.Font = Enum.Font.Gotham 
    l.TextXAlignment = Enum.TextXAlignment.Left 
    local v = Instance.new("TextLabel", row) 
    v.Size = UDim2.new(0.5, 0, 1, 0) 
    v.Position = UDim2.new(0.5, 0, 0, 0) 
    v.BackgroundTransparency = 1 
    v.Text = valor 
    v.TextColor3 = cor or Color3.fromRGB(255, 255, 255) 
    v.TextSize = 10 
    v.Font = Enum.Font.GothamBold 
    v.TextXAlignment = Enum.TextXAlignment.Right 
end
addInfoLinha("Executor:", executor, Color3.fromRGB(80, 255, 120)) 
addInfoLinha("Dispositivo:", device, Color3.fromRGB(80, 255, 120)) 
addInfoLinha("Cargo:", CG, Color3.fromRGB(255, 200, 50)) 
addInfoLinha("HWID:", string.sub(hwid, 1, 15) .. "...", Color3.fromRGB(150, 150, 150))

-- RAGE
local rageMov = yoxCard(pages["⛹ Rage"], "Movement", "⛹") 
yoxSlider(rageMov, "WalkSpeed", 16, 200, 16, function(v) 
    if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then LP.Character.Humanoid.WalkSpeed = v end 
end) 
yoxSlider(rageMov, "JumpPower", 50, 300, 50, function(v) 
    if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then LP.Character.Humanoid.JumpPower = v end 
end)

local rageFly = yoxCard(pages["⛹ Rage"], "Fly", "✈") 
local flyBV, flyBG
yoxToggle(rageFly, "Enable Fly", function(v) 
    if v and LP.Character then 
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart") 
        if hrp then 
            flyBV = Instance.new("BodyVelocity", hrp) 
            flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5) 
            flyBG = Instance.new("BodyGyro", hrp) 
            flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5) 
            task.spawn(function() 
                while flyBV and flyBV.Parent do 
                    local move = Vector3.zero 
                    if U:IsKeyDown(Enum.KeyCode.W) then move = move + C.CFrame.LookVector end 
                    if U:IsKeyDown(Enum.KeyCode.S) then move = move - C.CFrame.LookVector end 
                    if U:IsKeyDown(Enum.KeyCode.A) then move = move - C.CFrame.RightVector end 
                    if U:IsKeyDown(Enum.KeyCode.D) then move = move + C.CFrame.RightVector end 
                    if move.Magnitude > 0 then move = move.Unit * 80 end 
                    flyBV.Velocity = move 
                    flyBG.CFrame = C.CFrame 
                    R.Heartbeat:Wait() 
                end 
            end) 
        end 
    else 
        if flyBV then flyBV:Destroy() end 
        if flyBG then flyBG:Destroy() end 
    end 
end)

local rageInf = yoxCard(pages["⛹ Rage"], "Infinite jump", "△") 
yoxToggle(rageInf, "Infinite jump", function(v) 
    U.JumpRequest:Connect(function() 
        if v and LP.Character then LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end 
    end) 
end)

-- AIMBOT
local aimEnabled, triggerEnabled = false, false 
local aimFov, aimSmooth, aimPart = 150, 5, "Head" 
local fovFollowMouse = true 
local fovCircleObj = nil
local Cores = {{n="White",c=Color3.fromRGB(255,255,255)},{n="Red",c=Color3.fromRGB(255,50,50)},{n="Green",c=Color3.fromRGB(50,255,50)},{n="Blue",c=Color3.fromRGB(50,100,255)},{n="Purple",c=Color3.fromRGB(180,50,255)},{n="Pink",c=Color3.fromRGB(255,100,200)},{n="Yellow",c=Color3.fromRGB(255,255,50)}} 
local corAtualFov = 1

local function temParede(p) 
    local m, a = LP.Character, p.Character 
    if not m or not a then return true end 
    local op = m:FindFirstChild("Head") or m:FindFirstChild("HumanoidRootPart") 
    local ap = a:FindFirstChild(aimPart) or a:FindFirstChild("HumanoidRootPart") 
    if not op or not ap then return true end 
    local pr = RaycastParams.new() 
    pr.FilterType = Enum.RaycastFilterType.Exclude 
    pr.FilterDescendantsInstances = {m, a} 
    return workspace:Raycast(op.Position, ap.Position - op.Position, pr) ~= nil 
end

local function isTeamMate(p) 
    return LP.Team and p.Team and LP.Team == p.Team 
end

local function atualizarFov() 
    if fovCircleObj then fovCircleObj:Destroy() end 
    if aimEnabled then 
        fovCircleObj = Instance.new("Frame", gui) 
        fovCircleObj.Size = UDim2.new(0, aimFov*2, 0, aimFov*2) 
        fovCircleObj.BackgroundTransparency = 1 
        Instance.new("UICorner", fovCircleObj).CornerRadius = UDim.new(1,0) 
        local s = Instance.new("UIStroke", fovCircleObj) 
        s.Color = Color3.fromRGB(255, 50, 50) 
        s.Thickness = 2 
    end 
end

local aimCard = yoxCard(pages["◈ Aimbot"], "Camera Aimbot", "◈")
yoxToggle(aimCard, "Enabled", function(v) 
    aimEnabled = v 
    atualizarFov() 
    if v then 
        task.spawn(function() 
            while aimEnabled do 
                pcall(function() 
                    local t, md = nil, math.huge 
                    local cx, cy = C.ViewportSize.X / 2, C.ViewportSize.Y / 2 
                    local mx, my = U:GetMouse().X, U:GetMouse().Y 
                    local refX = fovFollowMouse and mx or cx 
                    local refY = fovFollowMouse and my or cy 
                    for _, p in ipairs(P:GetPlayers()) do 
                        if p ~= LP and p.Character and not isTeamMate(p) then 
                            local pt = p.Character:FindFirstChild(aimPart) or p.Character:FindFirstChild("HumanoidRootPart") 
                            if pt and not temParede(p) then 
                                local sp, os = C:WorldToViewportPoint(pt.Position) 
                                if os then 
                                    local d = (Vector2.new(sp.X, sp.Y) - Vector2.new(refX, refY)).Magnitude 
                                    if d < aimFov and d < md then 
                                        md = d 
                                        t = pt 
                                    end 
                                end 
                            end 
                        end 
                    end 
                    if t then 
                        local cp = C.CFrame.Position 
                        local dir = (t.Position - cp).Unit 
                        C.CFrame = C.CFrame:Lerp(CFrame.new(cp, cp + dir), 1 / math.max(aimSmooth, 1)) 
                        if triggerEnabled then 
                            pcall(function() 
                                local vu = game:GetService("VirtualUser") 
                                vu:CaptureController() 
                                vu:ClickButton1(Vector2.new(cx, cy)) 
                            end) 
                        end 
                    end 
                end) 
                R.RenderStepped:Wait() 
            end 
        end) 
    end 
end)

yoxToggle(aimCard, "Triggerbot", function(v) triggerEnabled = v end)
yoxToggle(aimCard, "Team check", function(v) end)

local aimFovCard = yoxCard(pages["◈ Aimbot"], "FOV Circle", "◎")
yoxToggle(aimFovCard, "FOV Follow Mouse", function(v) fovFollowMouse = v end)
yoxSlider(aimFovCard, "Radius", 50, 500, 150, function(v) aimFov = v atualizarFov() end)

R.RenderStepped:Connect(function() 
    if fovFollowMouse and fovCircleObj then 
        local m = U:GetMouse() 
        fovCircleObj.Position = UDim2.new(0, m.X - aimFov, 0, m.Y - aimFov) 
    end 
end)

-- VISUALS
local espCard = yoxCard(pages["▣ Visuals"], "ESP Visuals", "▣") 
local espFolder = Instance.new("Folder", gui) 
local espAtivo, espSkeletonAtivo, espNameAtivo = false, false, false

local function atualizarESP() 
    espFolder:ClearAllChildren() 
    if not espAtivo then return end 
    for _, p in ipairs(P:GetPlayers()) do 
        if p ~= LP and p.Character then 
            local char = p.Character 
            local hrp = char:FindFirstChild("HumanoidRootPart") 
            local hum = char:FindFirstChildOfClass("Humanoid") 
            if hrp and hum then 
                if espAtivo then 
                    local box = Instance.new("BoxHandleAdornment", espFolder) 
                    box.Adornee = hrp 
                    box.Size = Vector3.new(4, 5.5, 2) 
                    box.Color3 = Color3.fromRGB(255,255,255) 
                    box.Transparency = 0.7 
                    box.AlwaysOnTop = true 
                end 
                if espSkeletonAtivo then 
                    local bones = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"} 
                    for _, boneName in ipairs(bones) do 
                        local bone = char:FindFirstChild(boneName) 
                        if bone then 
                            local line = Instance.new("BoxHandleAdornment", espFolder) 
                            line.Adornee = bone 
                            line.Size = bone.Size 
                            line.Color3 = Color3.fromRGB(0,255,0) 
                            line.Transparency = 0.7 
                            line.AlwaysOnTop = true 
                        end 
                    end 
                end 
                local bill = Instance.new("BillboardGui", espFolder) 
                bill.Adornee = hrp 
                bill.Size = UDim2.new(0, 150, 0, 50) 
                bill.StudsOffset = Vector3.new(0, 3.5, 0) 
                bill.AlwaysOnTop = true 
                if espNameAtivo then 
                    local nameLbl = Instance.new("TextLabel", bill) 
                    nameLbl.Size = UDim2.new(1, 0, 0, 15) 
                    nameLbl.BackgroundTransparency = 1 
                    nameLbl.Text = p.Name 
                    nameLbl.TextColor3 = Color3.fromRGB(255,255,255) 
                    nameLbl.TextSize = 12 
                    nameLbl.Font = Enum.Font.GothamBold 
                    nameLbl.TextStrokeTransparency = 0 
                end 
            end 
        end 
    end 
end

yoxToggle(espCard, "3D Box ESP", function(v) espAtivo = v atualizarESP() end) 
yoxToggle(espCard, "Skeleton ESP", function(v) espSkeletonAtivo = v atualizarESP() end) 
yoxToggle(espCard, "Name ESP", function(v) espNameAtivo = v atualizarESP() end)

R.RenderStepped:Connect(function() 
    if espAtivo or espSkeletonAtivo or espNameAtivo then atualizarESP() end 
end)--// ZEDUX HUB v34.0 - PARTE 3: PLAYERS, EXTRAS E SETTINGS

-- TARGET TRACKER
local trackerGui = Instance.new("ScreenGui", game:GetService("CoreGui")) 
trackerGui.ResetOnSpawn = false 
trackerGui.IgnoreGuiInset = true 
trackerGui.DisplayOrder = 99998

local trackerFrame = Instance.new("Frame", trackerGui) 
trackerFrame.Size = UDim2.new(0, 250, 0, 40) 
trackerFrame.Position = UDim2.new(0.5, -125, 1, -60) 
trackerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25) 
trackerFrame.BackgroundTransparency = 0.2 
trackerFrame.Visible = false 
Instance.new("UICorner", trackerFrame).CornerRadius = UDim.new(0, 8) 
Instance.new("UIStroke", trackerFrame).Color = Color3.fromRGB(200, 200, 200)

local trackerName = Instance.new("TextLabel", trackerFrame) 
trackerName.Size = UDim2.new(1, -20, 1, 0) 
trackerName.Position = UDim2.new(0, 10, 0, 0) 
trackerName.BackgroundTransparency = 1 
trackerName.Text = "ALVO: Nenhum" 
trackerName.TextColor3 = Color3.fromRGB(255, 255, 255) 
trackerName.TextSize = 12 
trackerName.Font = Enum.Font.GothamBold 
trackerName.TextXAlignment = Enum.TextXAlignment.Left

task.spawn(function() 
    while trackerGui.Parent do 
        if S.sel and S.sel.Character and S.sel.Character:FindFirstChild("HumanoidRootPart") then 
            trackerFrame.Visible = true 
            local dist = math.floor((S.sel.Character.HumanoidRootPart.Position - C.CFrame.Position).Magnitude) 
            trackerName.Text = "ALVO: " .. S.sel.Name .. " [" .. dist .. "m]" 
        else 
            trackerFrame.Visible = false 
        end 
        task.wait(0.1) 
    end 
end)

-- PLAYERS
local pCard = yoxCard(pages["◍ Players"], "Players List", "◍") 
local pList = Instance.new("ScrollingFrame", pCard) 
pList.Size = UDim2.new(1, 0, 0, 120) 
pList.BackgroundTransparency = 1 
Instance.new("UIListLayout", pList).Padding = UDim.new(0, 2)

local previewCard = yoxCard(pages["◍ Players"], "Preview Player", "◉") 
local vp = Instance.new("ViewportFrame", previewCard) 
vp.Size = UDim2.new(1, 0, 0, 150) 
vp.BackgroundColor3 = Color3.fromRGB(20, 20, 25) 
vp.Ambient = Color3.fromRGB(255, 255, 255) 
local cam = Instance.new("Camera", vp) 
vp.CurrentCamera = cam

local light = Instance.new("PointLight", vp) 
light.Brightness = 2 
light.Range = 20 
light.Position = Vector3.new(0, 5, 5)

local function atualizarPreview(player) 
    for _, obj in ipairs(vp:GetChildren()) do 
        if obj:IsA("Model") then obj:Destroy() end 
    end 
    if not player or not player.Character then return end 
    local charClone = player.Character:Clone() 
    charClone.Parent = vp 
    local hrp = charClone:FindFirstChild("HumanoidRootPart") 
    if hrp then hrp.CFrame = CFrame.new(0, 0, 0) end 
    cam.CFrame = CFrame.new(Vector3.new(0, 1.5, -5), Vector3.new(0, 0.5, 0)) 
end

local function refreshP() 
    pList:ClearAllChildren() 
    for _, p in ipairs(P:GetPlayers()) do 
        local b = Instance.new("TextButton", pList) 
        b.Size = UDim2.new(1, -2, 0, 22) 
        b.BackgroundColor3 = Color3.fromRGB(50, 50, 60) 
        b.Text = "  " .. p.Name 
        b.TextColor3 = Color3.fromRGB(255, 255, 255) 
        b.TextXAlignment = Enum.TextXAlignment.Left 
        b.Font = Enum.Font.GothamBold 
        b.TextSize = 10 
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4) 
        b.MouseButton1Click:Connect(function() 
            S.sel = p 
            atualizarPreview(p) 
        end) 
    end 
end
refreshP() 
P.PlayerAdded:Connect(refreshP) 
P.PlayerRemoving:Connect(refreshP)

local btnGrid = Instance.new("Frame", previewCard) 
btnGrid.Size = UDim2.new(1, 0, 0, 45) 
btnGrid.BackgroundTransparency = 1 
local grid = Instance.new("UIGridLayout", btnGrid) 
grid.CellSize = UDim2.new(0.31, 0, 0, 20) 
grid.CellPadding = UDim2.new(0, 2, 0, 2)

local function makeBtn(text, cb) 
    local b = Instance.new("TextButton", btnGrid) 
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 60) 
    b.Text = text 
    b.TextColor3 = Color3.fromRGB(220, 220, 220) 
    b.TextSize = 9 
    b.Font = Enum.Font.GothamBold 
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4) 
    b.MouseButton1Click:Connect(cb) 
end
makeBtn("friend", function() end) 
makeBtn("spectate", function() if S.sel and S.sel.Character then C.CameraSubject = S.sel.Character:FindFirstChildOfClass("Humanoid") end end) 
makeBtn("teleport", function() if S.sel and S.sel.Character and LP.Character then local h = S.sel.Character:FindFirstChild("HumanoidRootPart") local m = LP.Character:FindFirstChild("HumanoidRootPart") if h and m then m.CFrame = h.CFrame * CFrame.new(0,0,3) end end end) 
makeBtn("target", function() end) 
makeBtn("copy id", function() if S.sel then pcall(function() setclipboard(tostring(S.sel.UserId)) end) end end) 
makeBtn("refresh", refreshP)

-- TELECINESE
local teleCard = yoxCard(pages["◎ Telecinese"], "Telecinese", "◎") 
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

local function makeBtnTele(text, cb) 
    local b = Instance.new("TextButton", teleCard) 
    b.Size = UDim2.new(1, 0, 0, 30) 
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 60) 
    b.Text = text 
    b.TextColor3 = Color3.fromRGB(255, 255, 255) 
    b.TextSize = 10 
    b.Font = Enum.Font.GothamBold 
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4) 
    b.MouseButton1Click:Connect(cb) 
end

makeBtnTele("Puxar Carro", function() 
    local c = acC() 
    if not c then return end 
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
                        if d.Magnitude < 8 then b.Velocity = Vector3.zero else b.Velocity = d.Unit * math.min(150, d.Magnitude * 3) end 
                    end 
                end 
            end 
            R.Heartbeat:Wait() 
        end 
        for _, x in ipairs(p) do 
            if x and x.Parent then 
                local b = x:FindFirstChild("ZEDUX_Pux") 
                if b then b:Destroy() end 
            end 
        end 
    end) 
end)

makeBtnTele("Soltar Tudo", function() 
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
end)

-- EXPLORER
local expCard = yoxCard(pages["▤ Explorer"], "Explorer", "▤") 
local expList = Instance.new("ScrollingFrame", expCard) 
expList.Size = UDim2.new(1, 0, 0, 120) 
expList.BackgroundColor3 = Color3.fromRGB(20, 20, 25) 
expList.ScrollBarThickness = 3 
Instance.new("UICorner", expList).CornerRadius = UDim.new(0, 4) 
Instance.new("UIListLayout", expList).Padding = UDim.new(0, 2)

local function refreshExp() 
    expList:ClearAllChildren() 
    for _, obj in ipairs(workspace:GetChildren()) do 
        local b = Instance.new("TextButton", expList) 
        b.Size = UDim2.new(1, -2, 0, 20) 
        b.BackgroundColor3 = Color3.fromRGB(50, 50, 60) 
        b.Text = "  " .. obj.Name .. " (" .. obj.ClassName .. ")" 
        b.TextColor3 = Color3.fromRGB(200, 200, 200) 
        b.TextSize = 8 
        b.Font = Enum.Font.Gotham 
        b.TextXAlignment = Enum.TextXAlignment.Left 
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3) 
    end 
end
refreshExp() 

local btnRefreshExp = Instance.new("TextButton", expCard) 
btnRefreshExp.Size = UDim2.new(1, 0, 0, 25) 
btnRefreshExp.BackgroundColor3 = Color3.fromRGB(50, 50, 60) 
btnRefreshExp.Text = "Atualizar" 
btnRefreshExp.TextColor3 = Color3.fromRGB(200, 200, 200) 
btnRefreshExp.TextSize = 10 
btnRefreshExp.Font = Enum.Font.GothamBold 
Instance.new("UICorner", btnRefreshExp).CornerRadius = UDim.new(0, 4) 
btnRefreshExp.MouseButton1Click:Connect(refreshExp)

-- CHAT
local chatCard = yoxCard(pages["⌨ Chat"], "Chat", "⌨") 
local chatHistory = Instance.new("ScrollingFrame", chatCard) 
chatHistory.Size = UDim2.new(1, 0, 0, 150) 
chatHistory.BackgroundColor3 = Color3.fromRGB(20, 20, 25) 
chatHistory.ScrollBarThickness = 3 
chatHistory.AutomaticCanvasSize = Enum.AutomaticSize.Y 
Instance.new("UICorner", chatHistory).CornerRadius = UDim.new(0, 4) 
Instance.new("UIListLayout", chatHistory).Padding = UDim.new(0, 3)

local chatInput = Instance.new("TextBox", chatCard) 
chatInput.Size = UDim2.new(1, 0, 0, 30) 
chatInput.BackgroundColor3 = Color3.fromRGB(50, 50, 60) 
chatInput.TextColor3 = Color3.fromRGB(255, 255, 255) 
chatInput.PlaceholderText = "Digite sua mensagem..." 
chatInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100) 
chatInput.TextSize = 10 
chatInput.Font = Enum.Font.Gotham 
chatInput.ClearTextOnFocus = false 
Instance.new("UICorner", chatInput).CornerRadius = UDim.new(0, 4)

local chatSend = Instance.new("TextButton", chatCard) 
chatSend.Size = UDim2.new(1, 0, 0, 25) 
chatSend.BackgroundColor3 = Color3.fromRGB(80, 255, 120) 
chatSend.Text = "Enviar" 
chatSend.TextColor3 = Color3.fromRGB(0, 0, 0) 
chatSend.TextSize = 10 
chatSend.Font = Enum.Font.GothamBold 
Instance.new("UICorner", chatSend).CornerRadius = UDim.new(0, 4)

chatSend.MouseButton1Click:Connect(function() 
    local m = chatInput.Text 
    if m == "" then return end 
    chatInput.Text = "" 
end)

-- AMBIENTE
local ambCard = yoxCard(pages["☾ Ambiente"], "Sky / Aurora", "☾") 
local currentSky = nil 
local function clearSky() 
    if currentSky then currentSky:Destroy() end 
    for _, obj in ipairs(game:GetService("Lighting"):GetChildren()) do 
        if obj.Name == "ZeduxSkyObject" then obj:Destroy() end 
    end 
end
local function setSky(assetId, name, cor) 
    clearSky() 
    local skyObj = Instance.new("Sky") 
    skyObj.Name = "ZeduxSkyObject" 
    skyObj.SkyboxBk = "rbxassetid://" .. assetId 
    skyObj.SkyboxDn = "rbxassetid://" .. assetId 
    skyObj.SkyboxFt = "rbxassetid://" .. assetId 
    skyObj.SkyboxLf = "rbxassetid://" .. assetId 
    skyObj.SkyboxRt = "rbxassetid://" .. assetId 
    skyObj.SkyboxUp = "rbxassetid://" .. assetId 
    skyObj.Parent = game:GetService("Lighting") 
    game:GetService("Lighting").Ambient = cor 
    game:GetService("Lighting").OutdoorAmbient = cor 
end

local ceus = {
    {n = "Aurora Boreal", id = "6903759368", c = Color3.fromRGB(30, 50, 80)},
    {n = "Noite Estrelada", id = "6903759368", c = Color3.fromRGB(0, 0, 20)},
    {n = "Pôr do Sol", id = "6903759368", c = Color3.fromRGB(255, 120, 50)},
    {n = "Céu Roxo", id = "6903759368", c = Color3.fromRGB(80, 20, 120)},
    {n = "Céu Normal", id = "0", c = Color3.fromRGB(255, 255, 255)}
}
for _, ceu in ipairs(ceus) do 
    local b = Instance.new("TextButton", ambCard) 
    b.Size = UDim2.new(1, 0, 0, 30) 
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 60) 
    b.Text = ceu.n 
    b.TextColor3 = Color3.fromRGB(200, 200, 200) 
    b.TextSize = 10 
    b.Font = Enum.Font.GothamBold 
    b.TextXAlignment = Enum.TextXAlignment.Left 
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4) 
    b.MouseButton1Click:Connect(function() 
        if ceu.n == "Céu Normal" then 
            clearSky() 
            game:GetService("Lighting").Ambient = Color3.fromRGB(70, 70, 70) 
            game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128) 
        else 
            setSky(ceu.id, ceu.n, ceu.c) 
        end 
    end) 
end

-- SETTINGS E REGISTROS
local fpsCard = yoxCard(pages["◐ Settings"], "FPS & Performance", "▦") 
local fpsCapped, fpsLimit = false, 60 
local function aplicarFpsCap(valor) 
    pcall(function() if setfpscap then setfpscap(valor) end end) 
end
yoxToggle(fpsCard, "Enable FPS Cap", function(v) 
    fpsCapped = v 
    if v then aplicarFpsCap(fpsLimit) else aplicarFpsCap(9999) end 
end)
yoxSlider(fpsCard, "Max FPS", 30, 240, 60, function(v) 
    fpsLimit = v 
    if fpsCapped then aplicarFpsCap(fpsLimit) end 
end)

local themeCard = yoxCard(pages["◐ Settings"], "Themes", "◐") 
local temas = {
    {n = "Black/White", c = Color3.fromRGB(255, 255, 255)},
    {n = "Cyan", c = Color3.fromRGB(0, 220, 255)},
    {n = "Crimson", c = Color3.fromRGB(255, 50, 50)},
    {n = "Violet", c = Color3.fromRGB(168, 85, 247)},
    {n = "Emerald", c = Color3.fromRGB(0, 255, 120)},
    {n = "Amber", c = Color3.fromRGB(255, 200, 0)}
}
local themeGrid = Instance.new("Frame", themeCard) 
themeGrid.Size = UDim2.new(1, 0, 0, 100) 
themeGrid.BackgroundTransparency = 1 
local gridLayout = Instance.new("UIGridLayout", themeGrid) 
gridLayout.CellSize = UDim2.new(0.31, 0, 0, 30) 
gridLayout.CellPadding = UDim.new(0, 5, 0, 5)

for _, tema in ipairs(temas) do 
    local btn = Instance.new("TextButton", themeGrid) 
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60) 
    btn.Text = tema.n 
    btn.TextColor3 = tema.c 
    btn.TextSize = 9 
    btn.Font = Enum.Font.GothamBold 
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4) 
    btn.MouseButton1Click:Connect(function() 
        local s = w:FindFirstChildOfClass("UIStroke") 
        if s then T:Create(s, TweenInfo.new(0.3), {Color = tema.c}):Play() end 
        for _, b in pairs(btns) do 
            T:Create(b, TweenInfo.new(0.3), {TextColor3 = tema.c}):Play() 
        end 
    end) 
end

local unloadBtn = Instance.new("TextButton", pages["◐ Settings"]) 
unloadBtn.Size = UDim2.new(1, 0, 0, 35) 
unloadBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40) 
unloadBtn.Text = "Hold to unload" 
unloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255) 
unloadBtn.Font = Enum.Font.GothamBold 
Instance.new("UICorner", unloadBtn).CornerRadius = UDim.new(0, 6) 
unloadBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

local logsCard = yoxCard(pages["≡ Registros"], "Logs do Sistema", "≡") 
local tL = Instance.new("TextLabel", logsCard) 
tL.Size = UDim2.new(1, 0, 0, 15) 
tL.BackgroundTransparency = 1 
tL.Text = "Total: " .. #lg 
tL.TextColor3 = Color3.fromRGB(150, 150, 150) 
tL.TextSize = 9 
tL.Font = Enum.Font.Gotham 
tL.TextXAlignment = Enum.TextXAlignment.Left

print("[ZEDUX] v34.0 Carregado com Sucesso!")
