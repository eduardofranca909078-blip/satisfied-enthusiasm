--// ZEDUX YOX HUB - PARTE 1 (VISUAL E INTERFACE)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "YoxMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local colors = {
    bg = Color3.fromRGB(10, 10, 14),
    panel = Color3.fromRGB(18, 18, 24),
    card = Color3.fromRGB(25, 25, 32),
    stroke = Color3.fromRGB(45, 45, 55),
    accent = Color3.fromRGB(145, 65, 255),
    text = Color3.fromRGB(255, 255, 255),
    muted = Color3.fromRGB(150, 150, 160)
}

local function create(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function corner(parent, radius)
    create("UICorner", {CornerRadius = UDim.new(0, radius)}, parent)
end

local function stroke(parent, color, thickness)
    create("UIStroke", {Color = color or colors.stroke, Thickness = thickness or 1, Transparency = 0.2}, parent)
end

local main = create("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(750, 500),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = colors.bg,
    BorderSizePixel = 0
}, gui)
corner(main, 12)
stroke(main, colors.stroke, 1.5)

local topBar = create("Frame", {
    Size = UDim2.new(1, 0, 0, 50),
    BackgroundColor3 = colors.panel,
    BorderSizePixel = 0
}, main)
corner(topBar, 12)

create("TextLabel", {
    Size = UDim2.new(1, -100, 1, 0),
    Position = UDim2.fromOffset(20, 0),
    BackgroundTransparency = 1,
    Text = "YOX MENU",
    TextColor3 = colors.text,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, topBar)

local closeBtn = create("TextButton", {
    Size = UDim2.fromOffset(30, 30),
    Position = UDim2.new(1, -40, 0.5, -15),
    BackgroundColor3 = colors.card,
    Text = "X",
    TextColor3 = colors.text,
    TextSize = 14,
    Font = Enum.Font.GothamBold
}, topBar)
corner(closeBtn, 6)

local sidebar = create("Frame", {
    Size = UDim2.new(0, 170, 1, -60),
    Position = UDim2.fromOffset(10, 55),
    BackgroundColor3 = colors.panel,
    BorderSizePixel = 0
}, main)
corner(sidebar, 10)

create("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder}, sidebar)
create("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, sidebar)

local content = create("Frame", {
    Size = UDim2.new(1, -190, 1, -60),
    Position = UDim2.fromOffset(180, 55),
    BackgroundColor3 = colors.panel,
    BorderSizePixel = 0
}, main)
corner(content, 10)

local pagesContainer = create("Frame", {
    Size = UDim2.new(1, -20, 1, -20),
    Position = UDim2.fromOffset(10, 10),
    BackgroundTransparency = 1
}, content)

local pages = {}
local function createPage(name)
    local page = create("ScrollingFrame", {
        Name = name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = colors.accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false
    }, pagesContainer)
    create("UIListLayout", {Padding = UDim.new(0, 10)}, page)
    pages[name] = page
    return page
end

createPage("Dashboard")
createPage("Aimbot")
createPage("Visuals")
createPage("Rage")
createPage("Players")
createPage("Themes")
createPage("Settings")

local function switchPage(name)
    for pageName, pageObj in pairs(pages) do
        pageObj.Visible = (pageName == name)
    end
end

local function addTabButton(name, displayName)
    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = colors.card,
        Text = "  " .. displayName,
        TextColor3 = colors.muted,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    }, sidebar)
    corner(btn, 6)
    
    btn.MouseButton1Click:Connect(function()
        for _, child in ipairs(sidebar:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = colors.card
                child.TextColor3 = colors.muted
            end
        end
        btn.BackgroundColor3 = colors.accent
        btn.TextColor3 = colors.text
        switchPage(name)
    end)
end

addTabButton("Dashboard", "Dashboard")
addTabButton("Aimbot", "Aimbot")
addTabButton("Visuals", "Visuals")
addTabButton("Rage", "Rage")
addTabButton("Players", "Players")
addTabButton("Themes", "Temas")
addTabButton("Settings", "Configurações")

closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

switchPage("Dashboard")

-- =======================================================
-- COMPONENTES (CARDS, TOGGLES, SLIDERS)
-- =======================================================
local function createCard(parentPage, title)
    local card = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = colors.panel,
        BorderSizePixel = 0
    }, parentPage)
    corner(card, 8)
    stroke(card, colors.stroke, 1)
    
    local pad = create("UIPadding", {PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)}, card)
    
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 15),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = colors.muted,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    }, card)
    
    local cf = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 2
    }, card)
    create("UIListLayout", {Padding = UDim.new(0, 10)}, cf)
    return cf
end

local function createToggle(parentCard, text, default, callback)
    local frame = create("Frame", {Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1}, parentCard)
    create("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0), BackgroundTransparency = 1,
        Text = text, TextColor3 = colors.text, TextSize = 11,
        Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left
    }, frame)
    
    local bg = create("Frame", {
        Size = UDim2.fromOffset(32, 16), Position = UDim2.new(1, -32, 0.5, -8),
        BackgroundColor3 = default and colors.accent or colors.stroke
    }, frame)
    corner(bg, 10)
    
    local knob = create("Frame", {
        Size = UDim2.fromOffset(12, 12),
        Position = default and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
        BackgroundColor3 = colors.text
    }, bg)
    corner(knob, 10)
    
    local active = default
    local btn = create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""}, frame)
    btn.MouseButton1Click:Connect(function()
        active = not active
        bg.BackgroundColor3 = active and colors.accent or colors.stroke
        knob.Position = active and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        callback(active)
    end)
end

local function createSlider(parentCard, text, min, max, default, callback)
    local frame = create("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1}, parentCard)
    create("TextLabel", {
        Size = UDim2.new(1, -50, 0, 15), BackgroundTransparency = 1,
        Text = text, TextColor3 = colors.text, TextSize = 11,
        Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left
    }, frame)
    
    local valLabel = create("TextLabel", {
        Size = UDim2.fromOffset(40, 15), Position = UDim2.new(1, -40, 0, 0),
        BackgroundTransparency = 1, Text = tostring(default),
        TextColor3 = colors.accent, TextSize = 11, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right
    }, frame)
    
    local barBg = create("Frame", {
        Size = UDim2.new(1, 0, 0, 4), Position = UDim2.fromOffset(0, 22),
        BackgroundColor3 = colors.stroke
    }, frame)
    corner(barBg, 2)
    
    local pct = (default - min) / (max - min)
    local barFill = create("Frame", {Size = UDim2.new(pct, 0, 1, 0), BackgroundColor3 = colors.accent}, barBg)
    corner(barFill, 2)
    
    local btn = create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""}, barBg)
    local isDragging = false
    local function update(input)
        local relX = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        barFill.Size = UDim2.new(relX, 0, 1, 0)
        local val = math.floor(min + (max - min) * relX)
        valLabel.Text = tostring(val)
        callback(val)
    end
    btn.MouseButton1Down:Connect(function(input) isDragging = true; update(input) end)
    UserInputService.InputChanged:Connect(function(input) if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = false end end)
end--// ZEDUX YOX HUB - PARTE 2 (FUNÇÕES E CONTEÚDO)

-- CONFIGURAÇÕES DO YOX
local espAtivo = false
local aimAtivo = false
local flyAtivo = false
local noclipAtivo = false
local speedValue = 16
local aimFov = 150
local aimSmooth = 5
local aimPart = "Head"
local wallCheck = true

local function limparEsp()
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Name == "YOX_ESP" then v:Destroy() end
    end
end

-- ABA DASHBOARD (BONECO 3D + INFO)
local dCard = createCard(pages["Dashboard"], "ESP PREVIEW")
local vp = create("ViewportFrame", {Size = UDim2.new(1, 0, 0, 200), BackgroundColor3 = colors.bg}, dCard)
corner(vp, 6)

local world = Instance.new("WorldModel", vp)
local dummy = Instance.new("Model", world)
local function dummyPart(name, size, pos, color)
    local p = Instance.new("Part", dummy)
    p.Name = name p.Size = size p.Position = pos
    p.Anchored = true p.CanCollide = false p.Color = color
    p.Material = Enum.Material.SmoothPlastic
    return p
end
dummyPart("Head", Vector3.new(1.5, 1.5, 1.5), Vector3.new(0, 2.5, 0), colors.accent)
dummyPart("Torso", Vector3.new(2, 2, 1), Vector3.new(0, 1, 0), colors.accent)
dummyPart("LA", Vector3.new(1, 2, 1), Vector3.new(-1.5, 1, 0), colors.accent)
dummyPart("RA", Vector3.new(1, 2, 1), Vector3.new(1.5, 1, 0), colors.accent)
dummyPart("LL", Vector3.new(1, 2, 1), Vector3.new(-0.5, -1.5, 0), colors.accent)
dummyPart("RL", Vector3.new(1, 2, 1), Vector3.new(0.5, -1.5, 0), colors.accent)
local hl = Instance.new("Highlight", dummy) hl.FillColor = colors.accent hl.FillTransparency = 0.5
local cam = Instance.new("Camera", vp) vp.CurrentCamera = cam
task.spawn(function() local a = 0 while vp.Parent do a = a + 0.02 cam.CFrame = CFrame.lookAt(Vector3.new(math.sin(a)*7, 1, math.cos(a)*7), Vector3.new(0,1,0)) RunService.RenderStepped:Wait() end end)

local infoCard = createCard(pages["Dashboard"], "INFORMAÇÕES")
createToggle(infoCard, "Boneco 3D Ligado", true, function(v) vp.Visible = v end)
createToggle(infoCard, "Mostrar Nome", false, function(v) end)

-- ABA VISUALS (ESP)
local visCard = createCard(pages["Visuals"], "JOGADORES")
createToggle(visCard, "ESP Ativado", false, function(v) espAtivo = v limparEsp() end)
createToggle(visCard, "Bounding Box", false, function(v) end)
createToggle(visCard, "Skeleton", false, function(v) end)
createToggle(visCard, "Health Bar", false, function(v) end)
createToggle(visCard, "Chams (Highlight)", false, function(v) end)
createSlider(visCard, "Distância Máxima", 50, 2000, 500, function(v) end)

local visCard2 = createCard(pages["Visuals"], "MUNDO")
createToggle(visCard2, "Fullbright", false, function(v)
    if v then game:GetService("Lighting").Brightness = 2 game:GetService("Lighting").ClockTime = 14 else game:GetService("Lighting").Brightness = 1 end
end)
createToggle(visCard2, "Remover Névoa", false, function(v) game:GetService("Lighting").FogEnd = v and 1e6 or 100000 end)

-- ABA RAGE (AIMBOT E MOVIMENTO)
local rageCard = createCard(pages["Rage"], "AIMBOT")
createToggle(rageCard, "Aimbot Ativado", false, function(v) aimAtivo = v end)
createSlider(rageCard, "FOV", 20, 500, 150, function(v) aimFov = v end)
createSlider(rageCard, "Smoothness", 1, 20, 5, function(v) aimSmooth = v end)
createToggle(rageCard, "Wall Check (Paredes)", true, function(v) wallCheck = v end)

local moveCard = createCard(pages["Rage"], "MOVIMENTO")
createToggle(moveCard, "Fly", false, function(v) flyAtivo = v end)
createToggle(moveCard, "Noclip", false, function(v) noclipAtivo = v end)
createSlider(moveCard, "Velocidade", 16, 200, 16, function(v) speedValue = v end)

-- ABA PLAYERS (LISTA DE JOGADORES)
local pCard = createCard(pages["Players"], "JOGADORES CONECTADOS")
local pList = create("ScrollingFrame", {Size = UDim2.new(1, 0, 0, 250), BackgroundTransparency = 1, ScrollBarThickness = 3, AutomaticCanvasSize = Enum.AutomaticSize.Y}, pCard)
create("UIListLayout", {Padding = UDim.new(0, 4)}, pList)

local selectedPlayer = nil
task.spawn(function()
    while gui.Parent do
        for _, c in ipairs(pList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                local b = create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = (selectedPlayer == p) and colors.accent or colors.card,
                    Text = "  " .. p.Name, TextColor3 = colors.text, TextSize = 11,
                    Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left
                }, pList)
                corner(b, 5)
                b.MouseButton1Click:Connect(function() selectedPlayer = p end)
            end
        end
        task.wait(1)
    end
end)

-- ABA THEMES
local tCard = createCard(pages["Themes"], "COR DO MENU")
local temas = {
    {n = "Violet", c = Color3.fromRGB(145, 65, 255)},
    {n = "Crimson", c = Color3.fromRGB(210, 45, 65)},
    {n = "Cyber Cyan", c = Color3.fromRGB(20, 190, 220)},
    {n = "Emerald", c = Color3.fromRGB(30, 170, 100)},
    {n = "Amber", c = Color3.fromRGB(220, 150, 30)}
}
for _, tema in ipairs(temas) do
    local b = create("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = colors.card, Text = "  " .. tema.n, TextColor3 = colors.text, TextSize = 11, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left}, tCard)
    corner(b, 6)
    b.MouseButton1Click:Connect(function()
        colors.accent = tema.c
        stroke(main, tema.c, 1.5)
        -- (Aqui atualizaria os botões em tempo real)
    end)
end

-- ABA SETTINGS
local sCard = createCard(pages["Settings"], "SISTEMA")
createToggle(sCard, "Anti-AFK", true, function(v)
    if v then
        task.spawn(function() while true do game:GetService("VirtualUser"):CaptureController() task.wait(60) end end)
    end
end)

-- LOOPS DE FUNÇÕES (AIMBOT, FLY, NOCLIP)
RunService.RenderStepped:Connect(function()
    -- Aimbot
    if aimAtivo then
        local melhor, menorDist = nil, aimFov
        local centro = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local h = p.Character:FindFirstChild(aimPart)
                if h then
                    local vp, on = workspace.CurrentCamera:WorldToViewportPoint(h.Position)
                    if on then
                        local d = (Vector2.new(vp.X, vp.Y) - centro).Magnitude
                        if d < menorDist then menorDist = d melhor = h end
                    end
                end
            end
        end
        if melhor then
            workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(CFrame.new(workspace.CurrentCamera.CFrame.Position, workspace.CurrentCamera.CFrame.Position + (melhor.Position - workspace.CurrentCamera.CFrame.Position).Unit), 1/math.max(aimSmooth,1))
        end
    end
    
    -- Fly / Noclip
    if player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if flyAtivo and hrp then
            if not hrp:FindFirstChild("YOX_Fly") then
                local bv = Instance.new("BodyVelocity", hrp) bv.Name = "YOX_Fly" bv.MaxForce = Vector3.new(1e5,1e5,1e5)
                local bg = Instance.new("BodyGyro", hrp) bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
            end
            local bv = hrp:FindFirstChild("YOX_Fly")
            local bg = hrp:FindFirstChildOfClass("BodyGyro")
            if bv and bg then
                local move = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + workspace.CurrentCamera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.yAxis end
                bv.Velocity = move * 80
                bg.CFrame = workspace.CurrentCamera.CFrame
            end
        elseif not flyAtivo and hrp then
            local bv = hrp:FindFirstChild("YOX_Fly") if bv then bv:Destroy() end
            local bg = hrp:FindFirstChildOfClass("BodyGyro") if bg then bg:Destroy() end
        end
        
        if noclipAtivo then
            for _, o in ipairs(player.Character:GetDescendants()) do
                if o:IsA("BasePart") then o.CanCollide = false end
            end
        end
        
        if hum and not flyAtivo then hum.WalkSpeed = speedValue end
    end
end)
