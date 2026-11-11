--// ZEDUX HUB v10.0 - YOX FULL FEATURES
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

local KEYS_VALIDAS = {
    ["ZEDUX-HUB-2026"] = true,
    ["ZEDUX-HUB-VIP"] = true,
    ["ZEDUX-HUB-PRO"] = true,
    ["eduardo92301"] = true
}

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
for _, n in ipairs(WL) do if LP.Name:lower() == n:lower() then isVipOuSuperior = true end end

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
            if tempoAgora < expiracao then return true end
        end
    end
    local segundos = 0
    if string.find(key, "ZEDUX-DIA-") then segundos = 86400 
    elseif string.find(key, "ZEDUX-SEM-") then segundos = 86400 * 7 
    elseif string.find(key, "ZEDUX-MEN-") then segundos = 86400 * 30 
    elseif string.find(key, "ZEDUX-ANO-") then segundos = 86400 * 365 
    elseif string.find(key, "ZEDUX-PERM-") then 
        pcall(function() writefile(TEMPOFILE, key .. "|9999999999") end) return true 
    else return false end
    local expiracao = tempoAgora + segundos
    pcall(function() writefile(TEMPOFILE, key .. "|" .. tostring(expiracao)) end)
    return true
end

-- =======================================================
-- INTRO (LOADER DE LOGIN)
-- =======================================================
local function IniciarIntro()
    local executor = "Unknown"
    pcall(function() executor = getexecutorname() or identifyexecutor() end)
    if type(executor) == "table" then executor = executor[1] end
    
    local hwid = "Not Available"
    pcall(function() hwid = gethwid() end)
    if hwid == "Not Available" then hwid = LP.UserId .. "-" .. math.random(1000, 9999) end

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
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", main).Color = Color3.fromRGB(200, 200, 200)

    local rightPanel = Instance.new("Frame", main)
    rightPanel.Size = UDim2.new(1, 0, 1, 0)
    rightPanel.BackgroundTransparency = 1
    
    local hTitle = Instance.new("TextLabel", rightPanel)
    hTitle.Size = UDim2.new(1, 0, 0, 30)
    hTitle.Position = UDim2.new(0, 0, 0, 20)
    hTitle.BackgroundTransparency = 1
    hTitle.Text = "ZEDUX HUB"
    hTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    hTitle.TextSize = 24
    hTitle.Font = Enum.Font.GothamBold

    local keyBox = Instance.new("TextBox", rightPanel)
    keyBox.Size = UDim2.new(0.8, 0, 0, 45)
    keyBox.Position = UDim2.new(0.1, 0, 0, 135)
    keyBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.PlaceholderText = "Waiting for key..."
    keyBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", keyBox).Color = Color3.fromRGB(150, 150, 150)

    local redeemBtn = Instance.new("TextButton", rightPanel)
    redeemBtn.Size = UDim2.new(0.8, 0, 0, 40)
    redeemBtn.Position = UDim2.new(0.1, 0, 0, 195)
    redeemBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    redeemBtn.Text = "Redeem Key"
    redeemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", redeemBtn).CornerRadius = UDim.new(0, 8)

    local statusLog = Instance.new("TextLabel", rightPanel)
    statusLog.Size = UDim2.new(0.8, 0, 0, 20)
    statusLog.Position = UDim2.new(0.1, 0, 0, 250)
    statusLog.BackgroundTransparency = 1
    statusLog.Text = ""
    statusLog.TextColor3 = Color3.fromRGB(0, 200, 100)
    statusLog.TextSize = 11
    statusLog.Font = Enum.Font.Gotham

    redeemBtn.MouseButton1Click:Connect(function()
        local keyDigitada = keyBox.Text:gsub("%s+", "")
        if KEYS_VALIDAS[keyDigitada] or ChecarTempoKey(keyDigitada) then
            statusLog.Text = "✅ Key válida! Iniciando..."
            task.wait(1)
            introGui:Destroy()
        else
            statusLog.TextColor3 = Color3.fromRGB(255, 80, 80)
            statusLog.Text = "❌ Key inválida ou expirada."
            keyBox.Text = ""
        end
    end)

    if isVipOuSuperior then
        task.wait(1)
        introGui:Destroy()
    else
        repeat task.wait() until not introGui.Parent
    end
end
IniciarIntro()

-- =======================================================
-- SISTEMA DO PAINEL E WEBHOOKS
-- =======================================================
local WEBHOOK = "https://discord.com/api/webhooks/1559481604387246170/aAs30L9QQbfX0ZWA92jKpD6PZ_F5IOZT1424WNqaHluyZ-QuNGbbO36pVf-Fe3Ti9Fe4"
local function reg(a)
    local h = os.date("%d/%m/%Y %H:%M:%S")
    table.insert(lg, {h = h, j = LP.Name, a = a})
    pcall(function() appendfile(LOGFILE, h .. "|" .. LP.Name .. "|" .. a .. "\n") end)
    if WEBHOOK ~= "" then
        pcall(function()
            game:GetService("HttpService"):RequestAsync({Url = WEBHOOK, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = game:GetService("HttpService"):JSONEncode({username = "ZEDUX HUB", content = "[" .. h .. "] " .. LP.Name .. " → " .. a})})
        end)
    end
end

-- =======================================================
-- YOX UI ENGINE
-- =======================================================
local gui = Instance.new("ScreenGui")
gui.Name = "ZeduxYox"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 99999
gui.Parent = game:GetService("CoreGui")

local w = Instance.new("Frame", gui)
w.Size = UDim2.new(0, 700, 0, 480)
w.Position = UDim2.new(0.5, -350, 0.5, -240)
w.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
w.BorderSizePixel = 0
Instance.new("UICorner", w).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", w).Color = Color3.fromRGB(40, 40, 40)

local sb = Instance.new("Frame", w)
sb.Size = UDim2.new(0, 180, 1, 0)
sb.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
sb.BorderSizePixel = 0
Instance.new("UICorner", sb).CornerRadius = UDim.new(0, 8)

local mn = Instance.new("Frame", w)
mn.Size = UDim2.new(1, -180, 1, 0)
mn.Position = UDim2.new(0, 180, 0, 0)
mn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
mn.BorderSizePixel = 0
mn.ClipsDescendants = true

local ct = Instance.new("Frame", mn)
ct.Size = UDim2.new(1, -20, 1, -20)
ct.Position = UDim2.new(0, 10, 0, 10)
ct.BackgroundTransparency = 1

-- COMPONENTES (Card, Toggle, Slider)
local function card(ti, p, cr)
    local c = Instance.new("Frame", p)
    c.Size = UDim2.new(1, 0, 0, 0)
    c.AutomaticSize = Enum.AutomaticSize.Y
    c.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 6)
    
    local title = Instance.new("TextLabel", c)
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "  " .. ti
    title.TextColor3 = cr or Color3.fromRGB(200, 200, 200)
    title.TextSize = 10
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local content = Instance.new("Frame", c)
    content.Size = UDim2.new(1, -20, 0, 0)
    content.Position = UDim2.new(0, 10, 0, 30)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundTransparency = 1
    Instance.new("UIListLayout", content).Padding = UDim.new(0, 5)
    return content
end

local function CreateToggle(parent, text, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -50, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local switch = Instance.new("Frame", frame)
    switch.Size = UDim2.new(0, 36, 0, 18)
    switch.Position = UDim2.new(1, -36, 0.5, -9)
    switch.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame", switch)
    circle.Size = UDim2.new(0, 14, 0, 14)
    circle.Position = UDim2.new(0, 2, 0.5, -7)
    circle.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            T:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play()
            T:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = Color3.fromRGB(0, 0, 0)}):Play()
        else
            T:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
            T:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(150, 150, 150)}):Play()
        end
        reg(text .. " " .. (state and "ON" or "OFF"))
        callback(state)
    end)
end

local function CreateSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -40, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local valLabel = Instance.new("TextLabel", frame)
    valLabel.Size = UDim2.new(0, 40, 0, 20)
    valLabel.Position = UDim2.new(1, -40, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(default)
    valLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    valLabel.TextSize = 10
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local bg = Instance.new("Frame", frame)
    bg.Size = UDim2.new(1, 0, 0, 4)
    bg.Position = UDim2.new(0, 0, 0, 28)
    bg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame", bg)
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    local btn = Instance.new("TextButton", bg)
    btn.Size = UDim2.new(1, 0, 2, 0)
    btn.Position = UDim2.new(0, 0, 0, -4)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    
    local function update(input)
        local x = math.clamp(input.Position.X - bg.AbsolutePosition.X, 0, bg.AbsoluteSize.X)
        local percent = x / bg.AbsoluteSize.X
        local val = math.floor(min + (max - min) * percent)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        valLabel.Text = tostring(val)
        callback(val)
    end
    
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; update(input)
        end
    end)
    U.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end
    end)
    U.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

-- =======================================================
-- SISTEMA DE ABAS
-- =======================================================
local tabs = {"Rage", "Aimbot", "Triggerbot", "Visuals", "Players", "Settings"}
local pages = {}
local btns = {}

for i, name in ipairs(tabs) do
    local btn = Instance.new("TextButton", sb)
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, 20 + (i-1)*35)
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local page = Instance.new("ScrollingFrame", ct)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    Instance.new("UIListLayout", page).Padding = UDim.new(0, 8)
    
    pages[name] = page
    btns[name] = btn
    
    btn.MouseButton1Click:Connect(function()
        for n, b in pairs(btns) do
            b.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            b.TextColor3 = Color3.fromRGB(180, 180, 180)
            pages[n].Visible = false
        end
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        page.Visible = true
    end)
end
btns["Rage"].BackgroundColor3 = Color3.fromRGB(25, 25, 25)
btns["Rage"].TextColor3 = Color3.fromRGB(255, 255, 255)
pages["Rage"].Visible = true

-- =======================================================
-- ABA RAGE (FOTO 5)
-- =======================================================
local rageMov = card("Movement", pages["Rage"], Color3.fromRGB(200, 200, 200))
CreateSlider(rageMov, "WalkSpeed", 16, 200, 16, function(v)
    if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then LP.Character.Humanoid.WalkSpeed = v end
end)
CreateSlider(rageMov, "JumpPower", 50, 300, 50, function(v)
    if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then LP.Character.Humanoid.JumpPower = v end
end)
CreateToggle(rageMov, "Infinite Jump", function(v)
    U.JumpRequest:Connect(function()
        if v and LP.Character then LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end)

local rageFly = card("Fly", pages["Rage"], Color3.fromRGB(200, 200, 200))
local flyBV, flyBG
CreateToggle(rageFly, "Enable Fly", function(v)
    if v and LP.Character then
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            flyBV = Instance.new("BodyVelocity", hrp) flyBV.MaxForce = Vector3.new(1e5,1e5,1e5)
            flyBG = Instance.new("BodyGyro", hrp) flyBG.MaxTorque = Vector3.new(1e5,1e5,1e5)
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

-- =======================================================
-- ABA AIMBOT (FOTO 1, 3)
-- =======================================================
local aimCard = card("Aimbot", pages["Aimbot"], Color3.fromRGB(220, 220, 220))
local aimEnabled = false
local aimFov = 150
local aimSmooth = 1

CreateToggle(aimCard, "Enabled", function(v)
    aimEnabled = v
    if v then
        task.spawn(function()
            while aimEnabled do
                pcall(function()
                    local target = nil
                    local dist = math.huge
                    for _, p in ipairs(P:GetPlayers()) do
                        if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
                            local screenPos, onScreen = C:WorldToViewportPoint(p.Character.Head.Position)
                            if onScreen then
                                local mousePos = U:GetMouse().X
                                local d = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos, U:GetMouse().Y)).Magnitude
                                if d < aimFov and d < dist then
                                    dist = d
                                    target = p.Character.Head
                                end
                            end
                        end
                    end
                    if target then
                        C.CFrame = C.CFrame:Lerp(CFrame.new(C.CFrame.Position, target.Position), 1/(aimSmooth*10))
                    end
                end)
                R.RenderStepped:Wait()
            end
        end)
    end
end)

local aimFovCard = card("FOV", pages["Aimbot"], Color3.fromRGB(220, 220, 220))
CreateSlider(aimFovCard, "Radius", 50, 500, 150, function(v) aimFov = v end)
CreateToggle(aimFovCard, "Draw FOV", function(v)
    if v then
        local fovCircle = Instance.new("Frame", gui)
        fovCircle.Size = UDim2.new(0, aimFov*2, 0, aimFov*2)
        fovCircle.Position = UDim2.new(0.5, -aimFov, 0.5, -aimFov)
        fovCircle.BackgroundTransparency = 1
        Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1,0)
        local stroke = Instance.new("UIStroke", fovCircle)
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Thickness = 1
    end
end)

-- =======================================================
-- ABA TRIGGERBOT (FOTO 2)
-- =======================================================
local trigCard = card("Triggerbot", pages["Triggerbot"], Color3.fromRGB(220, 220, 220))
CreateToggle(trigCard, "Enabled", function(v)
    if v then
        task.spawn(function()
            while v do
                pcall(function()
                    local mouse = U:GetMouse()
                    if mouse.Target and mouse.Target.Parent then
                        local hum = mouse.Target.Parent:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 and mouse.Target.Parent ~= LP.Character then
                            local vu = game:GetService("VirtualUser")
                            vu:CaptureController()
                            vu:ClickButton1(Vector2.new(mouse.X, mouse.Y))
                        end
                    end
                end)
                task.wait(0.1)
            end
        end)
    end
end)

-- =======================================================
-- ABA VISUALS (FOTO 4, 6)
-- =======================================================
local espCard = card("Box ESP", pages["Visuals"], Color3.fromRGB(220, 220, 220))
local espFolder = Instance.new("Folder", gui)
CreateToggle(espCard, "Enabled", function(v)
    if v then
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= LP and p.Character then
                local box = Instance.new("BoxHandleAdornment", espFolder)
                box.Adornee = p.Character.HumanoidRootPart
                box.Size = Vector3.new(4,5,4)
                box.Color3 = Color3.fromRGB(255,255,255)
                box.Transparency = 0.5
                box.AlwaysOnTop = true
            end
        end
    else
        espFolder:ClearAllChildren()
    end
end)
CreateToggle(espCard, "Show Names", function(v)
    if v then
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= LP and p.Character then
                local gui = Instance.new("BillboardGui", espFolder)
                gui.Adornee = p.Character.Head
                gui.Size = UDim2.new(0,100,0,20)
                gui.AlwaysOnTop = true
                local txt = Instance.new("TextLabel", gui)
                txt.Size = UDim2.new(1,0,1,0)
                txt.BackgroundTransparency = 1
                txt.Text = p.Name
                txt.TextColor3 = Color3.fromRGB(255,255,255)
                txt.TextStrokeTransparency = 0
            end
        end
    else
        espFolder:ClearAllChildren()
    end
end)

local lightCard = card("Lighting", pages["Visuals"], Color3.fromRGB(220, 220, 220))
CreateToggle(lightCard, "Fullbright", function(v)
    local l = game:GetService("Lighting")
    if v then l.Brightness = 2 l.ClockTime = 14 else l.Brightness = 1 end
end)

-- =======================================================
-- ABA PLAYERS (FOTO 8) - BONECO 3D
-- =======================================================
local pCard = card("Players List", pages["Players"], Color3.fromRGB(255, 200, 50))
local pList = Instance.new("ScrollingFrame", pCard)
pList.Size = UDim2.new(1,0,0,150)
pList.BackgroundTransparency = 1
Instance.new("UIListLayout", pList).Padding = UDim.new(0,2)

local previewCard = card("Preview", pages["Players"], Color3.fromRGB(255, 200, 50))
local vp = Instance.new("ViewportFrame", previewCard)
vp.Size = UDim2.new(1,0,0,200)
vp.BackgroundColor3 = Color3.fromRGB(10,10,10)
local cam = Instance.new("Camera", vp)
vp.CurrentCamera = cam

local function refreshP()
    pList:ClearAllChildren()
    for _, p in ipairs(P:GetPlayers()) do
        local btn = Instance.new("TextButton", pList)
        btn.Size = UDim2.new(1,-2,0,25)
        btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
        btn.Text = " "..p.Name
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)
        
        btn.MouseButton1Click:Connect(function()
            S.sel = p
            if p.Character then
                vp:ClearAllChildren()
                local clone = p.Character:Clone()
                clone.Parent = vp
                cam.CFrame = CFrame.new(Vector3.new(0,2,-5), Vector3.new(0,1,0))
            end
        end)
    end
end
refreshP()
P.PlayerAdded:Connect(refreshP)
P.PlayerRemoving:Connect(refreshP)

-- =======================================================
-- ABA SETTINGS (FOTO 12)
-- =======================================================
local themeCard = card("Appearance (Themes)", pages["Settings"], Color3.fromRGB(200, 200, 200))
local themes = {
    {n="Violet", c=Color3.fromRGB(168,85,247)},
    {n="Crimson", c=Color3.fromRGB(220,40,60)},
    {n="Cyber Cyan", c=Color3.fromRGB(0,220,255)},
    {n="Emerald", c=Color3.fromRGB(80,255,120)},
    {n="Amber", c=Color3.fromRGB(255,200,50)},
    {n="Monochrome", c=Color3.fromRGB(150,150,150)}
}
for _, t in ipairs(themes) do
    local btn = Instance.new("TextButton", themeCard)
    btn.Size = UDim2.new(0.48,0,0,25)
    btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    btn.Text = t.n
    btn.TextColor3 = t.c
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)
    btn.MouseButton1Click:Connect(function()
        T:Create(w, TweenInfo.new(0.3), {BackgroundColor3 = t.c}):Play()
    end)
end

local unloadBtn = Instance.new("TextButton", pages["Settings"])
unloadBtn.Size = UDim2.new(1,0,0,35)
unloadBtn.BackgroundColor3 = Color3.fromRGB(150,40,40)
unloadBtn.Text = "Hold to unload"
unloadBtn.TextColor3 = Color3.fromRGB(255,255,255)
unloadBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", unloadBtn).CornerRadius = UDim.new(0,6)
unloadBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

print("[ZEDUX] Yox Menu carregado com sucesso!")
