--// ZEDUX V11.3 - FULL (Logs + Webhook + Preview + Color Picker + Auth)
local P = game:GetService("Players")
local U = game:GetService("UserInputService")
local R = game:GetService("RunService")
local T = game:GetService("TweenService")
local LP = P.LocalPlayer
local C = workspace.CurrentCamera
local D = Drawing
local VU = game:GetService("VirtualUser")
local HS = game:GetService("HttpService")

-- ===================== CONFIGURAÇÕES DE LOG =====================
local WEBHOOK = "COLOQUE_SEU_WEBHOOK_AQUI"
local logs = {}
local logUIList = nil

local function reg(action)
    local time = os.date("%H:%M:%S")
    table.insert(logs, "["..time.."] "..action)
    
    if logUIList then
        local l = Instance.new("TextLabel", logUIList.Parent)
        l.Size = UDim2.new(1, 0, 0, 18)
        l.BackgroundTransparency = 1
        l.Text = "["..time.."] "..action
        l.TextColor3 = Color3.fromRGB(150, 150, 150)
        l.TextSize = 10
        l.Font = Enum.Font.Code
        l.TextXAlignment = Enum.TextXAlignment.Left
    end
    
    if WEBHOOK ~= "" and WEBHOOK ~= "COLOQUE_SEU_WEBHOOK_AQUI" then
        local httpReq = (syn and syn.request) or (http and http.request) or http_request or request
        if httpReq then
            task.spawn(function()
                pcall(function()
                    httpReq({Url = WEBHOOK, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HS:JSONEncode({content = "**[ZEDUX]** "..LP.Name.." → "..action})})
                end)
            end)
        end
    end
end

-- ===================== SISTEMA DE AUTH =====================
local OID = 4197733654
local WL = {"eduardo92301"}
local KEYFILE = "zedux_keys.txt"
local TEMPOFILE = "zedux_tempo.txt"

local KEYS_VALIDAS = { ["ZEDUX-HUB-2026"] = true, ["ZEDUX-HUB-VIP"] = true, ["ZEDUX-HUB-PRO"] = true, ["eduardo92301"] = true }
pcall(function()
    local d = readfile(KEYFILE)
    if d and d ~= "" then for l in d:gmatch("[^\n]+") do KEYS_VALIDAS[l] = true end end
end)

local isVipOuSuperior = (LP.UserId == OID)
for _, n in ipairs(WL) do if LP.Name:lower() == n:lower() then isVipOuSuperior = true end end

local function ChecarTempoKey(key)
    local tempoAgora = os.time() local chaveSalva = ""
    pcall(function() chaveSalva = readfile(TEMPOFILE) end)
    if chaveSalva ~= "" then
        local dados = string.split(chaveSalva, "|")
        if dados[1] == key then local expiracao = tonumber(dados[2]) if tempoAgora < expiracao then return true end end
    end
    local segundos = 0
    if string.find(key, "ZEDUX-DIA-") then segundos = 86400 
    elseif string.find(key, "ZEDUX-SEM-") then segundos = 86400 * 7 
    elseif string.find(key, "ZEDUX-MEN-") then segundos = 86400 * 30 
    elseif string.find(key, "ZEDUX-ANO-") then segundos = 86400 * 365 
    elseif string.find(key, "ZEDUX-PERM-") then pcall(function() writefile(TEMPOFILE, key .. "|" .. tostring(math.huge)) end) return true 
    else return false end
    local expiracao = tempoAgora + segundos
    pcall(function() writefile(TEMPOFILE, key .. "|" .. tostring(expiracao)) end)
    return true
end

local function IniciarIntro()
    local introGui = Instance.new("ScreenGui")
    introGui.Name = "ZeduxLoader"; introGui.ResetOnSpawn = false; introGui.IgnoreGuiInset = true
    introGui.DisplayOrder = 999999; introGui.Parent = game:GetService("CoreGui")

    local main = Instance.new("Frame", introGui)
    main.Size = UDim2.new(0, 450, 0, 300); main.Position = UDim2.new(0.5, -225, 0.5, -150)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 20); main.BorderSizePixel = 0
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", main).Color = Color3.fromRGB(170, 0, 255)

    local title = Instance.new("TextLabel", main) title.Size = UDim2.new(1, 0, 0, 40); title.Position = UDim2.new(0, 0, 0, 20) title.BackgroundTransparency = 1 title.Text = "ZEDUX SUPREME" title.TextColor3 = Color3.fromRGB(255, 255, 255) title.TextSize = 22 title.Font = Enum.Font.GothamBold

    local keyBox = Instance.new("TextBox", main) keyBox.Size = UDim2.new(0.8, 0, 0, 45); keyBox.Position = UDim2.new(0.1, 0, 0, 80) keyBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30) keyBox.TextColor3 = Color3.fromRGB(255, 255, 255) keyBox.PlaceholderText = "Insira sua Key..." keyBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100) keyBox.TextSize = 14 keyBox.Font = Enum.Font.Gotham keyBox.ClearTextOnFocus = false Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 6)

    local btn = Instance.new("TextButton", main) btn.Size = UDim2.new(0.8, 0, 0, 40); btn.Position = UDim2.new(0.1, 0, 0, 140) btn.BackgroundColor3 = Color3.fromRGB(170, 0, 255) btn.Text = "REDEEM" btn.TextColor3 = Color3.fromRGB(255, 255, 255) btn.Font = Enum.Font.GothamBold btn.TextSize = 14 Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local status = Instance.new("TextLabel", main) status.Size = UDim2.new(0.8, 0, 0, 20); status.Position = UDim2.new(0.1, 0, 0, 190) status.BackgroundTransparency = 1 status.Text = "" status.TextColor3 = Color3.fromRGB(0, 200, 100) status.TextSize = 12 status.Font = Enum.Font.Gotham

    local dscBtn = Instance.new("TextButton", main) dscBtn.Size = UDim2.new(0.8, 0, 0, 35); dscBtn.Position = UDim2.new(0.1, 0, 0, 230) dscBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35) dscBtn.Text = "💬 Discord" dscBtn.TextColor3 = Color3.fromRGB(200, 200, 200) dscBtn.Font = Enum.Font.GothamBold dscBtn.TextSize = 12 Instance.new("UICorner", dscBtn).CornerRadius = UDim.new(0, 6)

    dscBtn.MouseButton1Click:Connect(function() pcall(function() setclipboard("https://discord.gg/s6GSy4TuJ") end) status.TextColor3 = Color3.fromRGB(200, 200, 200) status.Text = "🔗 Discord copiado!" end)

    btn.MouseButton1Click:Connect(function()
        local keyDigitada = keyBox.Text:gsub("%s+", "")
        if KEYS_VALIDAS[keyDigitada] or ChecarTempoKey(keyDigitada) then
            status.TextColor3 = Color3.fromRGB(0, 200, 100) status.Text = "✅ Válida! Carregando..." task.wait(1) introGui:Destroy()
        else
            status.TextColor3 = Color3.fromRGB(255, 80, 80) status.Text = "❌ Key inválida." keyBox.Text = ""
        end
    end)

    if isVipOuSuperior then
        title.Text = "BEM-VINDO VIP" keyBox.Visible = false btn.Visible = false dscBtn.Visible = false status.Text = "✅ Autenticado." task.wait(1) introGui:Destroy()
    else repeat task.wait() until not introGui.Parent end
end
IniciarIntro()

-- ===================== CONFIGURAÇÕES =====================
local CFG = {
    Aim = { On = false, Key = Enum.KeyCode.E, FOV = 150, Smooth = 0.3, Silent = false, Predict = 0.16, Part = "Head", AutoFire = false, Holding = false },
    Hitbox = { On = false, X = 20, Y = 20, Z = 20, Part = "Head" },
    Vis = { Box = true, Fill = false, Skel = true, Chams = true, Name = true, Dist = true, Rainbow = false, Color = Color3.fromRGB(170, 0, 255) },
    Rage = { Spin = false, InfJump = false },
    Cross = { On = true, Dot = true, Size = 6, Gap = 3, Color = Color3.fromRGB(170, 0, 255) }
}
local ACCENT = Color3.fromRGB(170, 0, 255)
local BG = Color3.fromRGB(15, 15, 20)
local CARD = Color3.fromRGB(25, 25, 30)
local TEXT = Color3.fromRGB(200, 200, 205)

local executor = "Unknown" pcall(function() executor = getexecutorname() or identifyexecutor() end) if type(executor) == "table" then executor = executor[1] end
local hwid = "Unknown" pcall(function() hwid = gethwid() end)

-- ===================== UI BASE =====================
local gui = Instance.new("ScreenGui")
gui.Name = "ZeduxSupreme"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 999999; gui.Parent = game:GetService("CoreGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 750, 0, 450); main.Position = UDim2.new(0.5, -375, 0.5, -225)
main.BackgroundColor3 = BG; main.BorderSizePixel = 0; main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", main).Color = Color3.fromRGB(40,40,45)

local top = Instance.new("Frame", main)
top.Size = UDim2.new(1, 0, 0, 40); top.BackgroundTransparency = 1

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1, -100, 1, 0); title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1; title.Text = "ZEDUX | MAIN"; title.TextColor3 = ACCENT; title.TextSize = 16; title.Font = Enum.Font.GothamBold; title.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", top)
minBtn.Size = UDim2.new(0, 30, 0, 30); minBtn.Position = UDim2.new(1, -70, 0, 5)
minBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30); minBtn.Text = "—"; minBtn.TextColor3 = Color3.fromRGB(255, 255, 255); minBtn.TextSize = 14; minBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)

local closeBtn = Instance.new("TextButton", top)
closeBtn.Size = UDim2.new(0, 30, 0, 30); closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30); closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80); closeBtn.TextSize = 14; closeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

local side = Instance.new("Frame", main)
side.Size = UDim2.new(0, 160, 1, -40); side.Position = UDim2.new(0, 0, 0, 40)
side.BackgroundColor3 = Color3.fromRGB(10, 10, 12); side.BorderSizePixel = 0
Instance.new("UICorner", side).CornerRadius = UDim.new(0, 8)

local profile = Instance.new("Frame", side)
profile.Size = UDim2.new(1, -20, 0, 60); profile.Position = UDim2.new(0, 10, 1, -70)
profile.BackgroundColor3 = Color3.fromRGB(20, 20, 22); profile.BorderSizePixel = 0
Instance.new("UICorner", profile).CornerRadius = UDim.new(0, 6)

local pAvatar = Instance.new("ImageLabel", profile) pAvatar.Size = UDim2.new(0, 40, 0, 40); pAvatar.Position = UDim2.new(0, 10, 0.5, -20) pAvatar.BackgroundColor3 = Color3.fromRGB(0,0,0); pAvatar.Image = "rbxthumb://type=AvatarHeadShot&id="..LP.UserId.."&w=150&h=150" Instance.new("UICorner", pAvatar).CornerRadius = UDim.new(1, 0)
local pName = Instance.new("TextLabel", profile) pName.Size = UDim2.new(1, -60, 0, 15); pName.Position = UDim2.new(0, 60, 0, 15) pName.BackgroundTransparency = 1 pName.Text = LP.Name pName.TextColor3 = Color3.fromRGB(255, 255, 255); pName.TextSize = 11; pName.Font = Enum.Font.GothamBold; pName.TextXAlignment = Enum.TextXAlignment.Left
local pRole = Instance.new("TextLabel", profile) pRole.Size = UDim2.new(1, -60, 0, 15); pRole.Position = UDim2.new(0, 60, 0, 30) pRole.BackgroundTransparency = 1 pRole.Text = isVipOuSuperior and "VIP" or "PLAYER" pRole.TextColor3 = isVipOuSuperior and ACCENT or TEXT; pRole.TextSize = 10; pRole.Font = Enum.Font.GothamBold; pRole.TextXAlignment = Enum.TextXAlignment.Left

local content = Instance.new("ScrollingFrame", main)
content.Size = UDim2.new(1, -360, 1, -60); content.Position = UDim2.new(0, 170, 0, 50)
content.BackgroundTransparency = 1; content.BorderSizePixel = 0; content.ScrollBarThickness = 2; content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", content).Padding = UDim.new(0, 8)

local viewFrame = Instance.new("Frame", main)
viewFrame.Size = UDim2.new(0, 180, 1, -60); viewFrame.Position = UDim2.new(1, -190, 0, 50)
viewFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12); viewFrame.BorderSizePixel = 0
Instance.new("UICorner", viewFrame).CornerRadius = UDim.new(0, 8)

local viewport = Instance.new("ViewportFrame", viewFrame) viewport.Size = UDim2.new(1, 0, 1, 0); viewport.BackgroundTransparency = 1 viewport.Ambient = Color3.fromRGB(255, 255, 255); viewport.LightColor = Color3.fromRGB(255, 255, 255) Instance.new("UICorner", viewport).CornerRadius = UDim.new(0, 8)
local cam = Instance.new("Camera", viewport) viewport.CurrentCamera = cam; cam.FieldOfView = 40 cam.CFrame = CFrame.new(Vector3.new(0, 0, 4), Vector3.new(0, 0, 0))
local cloneModel = nil
local function updatePreview() if cloneModel then cloneModel:Destroy() end if not LP.Character then return end cloneModel = LP.Character:Clone(); cloneModel.Parent = viewport for _, v in ipairs(cloneModel:GetDescendants()) do if v:IsA("Humanoid") or v:IsA("Script") or v:IsA("LocalScript") then v:Destroy() elseif v:IsA("BasePart") then v.Anchored = true; v.CanCollide = false; v.CanQuery = false; v.CanTouch = false end end local hrp = cloneModel:FindFirstChild("HumanoidRootPart") if hrp then cloneModel:PivotTo(CFrame.new(0, -1.5, 0)) end end
task.spawn(function() task.wait(1) updatePreview() end) LP.CharacterAdded:Connect(function() task.wait(1) updatePreview() end) local light = Instance.new("PointLight", cam) light.Brightness = 2 light.Range = 10
R.RenderStepped:Connect(function() if cloneModel and cloneModel:FindFirstChild("HumanoidRootPart") then cloneModel:PivotTo(cloneModel:GetPivot() * CFrame.Angles(0, math.rad(1), 0)) end end)

-- ===================== DRAG & MINIMIZE =====================
local dragging, dragStart, startPos
top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = main.Position
    end
end)
U.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
U.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        main.Size = UDim2.new(0, 750, 0, 40)
        side.Visible = false; content.Visible = false; viewFrame.Visible = false
        minBtn.Text = "□"
    else
        main.Size = UDim2.new(0, 750, 0, 450)
        side.Visible = true; content.Visible = true; viewFrame.Visible = true
        minBtn.Text = "—"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
    for _, obj in pairs(drawEsp) do for _, v in pairs(obj) do if typeof(v) == "table" then for _, l in pairs(v) do l:Remove() end else v:Remove() end end end
    fovCircle:Remove(); for _, l in ipairs(crossLines) do l:Remove() end; crossDot:Remove()
end)

-- ===================== UI LIBRARY =====================
local function makeGroup(name)
    local f = Instance.new("Frame", content) f.Size = UDim2.new(1, 0, 0, 0); f.AutomaticSize = Enum.AutomaticSize.Y f.BackgroundColor3 = CARD; f.BorderSizePixel = 0 Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    local pd = Instance.new("UIPadding", f) pd.PaddingTop = UDim.new(0,10); pd.PaddingBottom = UDim.new(0,10); pd.PaddingLeft = UDim.new(0,10); pd.PaddingRight = UDim.new(0,10)
    local t = Instance.new("TextLabel", f) t.Size = UDim2.new(1, 0, 0, 15) t.BackgroundTransparency = 1 t.Text = name t.TextColor3 = ACCENT t.TextSize = 11 t.Font = Enum.Font.GothamBold t.TextXAlignment = Enum.TextXAlignment.Left
    local l = Instance.new("Frame", f) l.Size = UDim2.new(1, 0, 0, 0) l.Position = UDim2.new(0, 0, 0, 20) l.BackgroundTransparency = 1 l.AutomaticSize = Enum.AutomaticSize.Y Instance.new("UIListLayout", l).Padding = UDim.new(0, 6)
    return l
end

local function makeToggle(p, text, default, cb)
    local f = Instance.new("Frame", p) f.Size = UDim2.new(1, 0, 0, 20) f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f) l.Size = UDim2.new(1, -30, 1, 0) l.BackgroundTransparency = 1 l.Text = text l.TextColor3 = TEXT l.TextSize = 11 l.Font = Enum.Font.Gotham l.TextXAlignment = Enum.TextXAlignment.Left
    local sw = Instance.new("Frame", f) sw.Size = UDim2.new(0, 24, 0, 12) sw.Position = UDim2.new(1, -24, 0.5, -6) sw.BackgroundColor3 = default and ACCENT or Color3.fromRGB(40,40,40) Instance.new("UICorner", sw).CornerRadius = UDim.new(1,0)
    local btn = Instance.new("TextButton", f) btn.Size = UDim2.new(1,0,1,0) btn.BackgroundTransparency = 1 btn.Text = ""
    local active = default
    btn.MouseButton1Click:Connect(function() active = not active sw.BackgroundColor3 = active and ACCENT or Color3.fromRGB(40,40,40) reg(text..": "..tostring(active)) cb(active) end)
end

local function makeSlider(p, text, min, max, def, cb)
    local f = Instance.new("Frame", p) f.Size = UDim2.new(1, 0, 0, 25) f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f) l.Size = UDim2.new(1, -40, 0, 12) l.BackgroundTransparency = 1 l.Text = text l.TextColor3 = TEXT l.TextSize = 11 l.Font = Enum.Font.Gotham l.TextXAlignment = Enum.TextXAlignment.Left
    local v = Instance.new("TextLabel", f) v.Size = UDim2.new(0, 40, 0, 12) v.Position = UDim2.new(1, -40, 0, 0) v.BackgroundTransparency = 1 v.Text = tostring(def) v.TextColor3 = Color3.fromRGB(150,150,150) v.TextSize = 10 v.TextXAlignment = Enum.TextXAlignment.Right
    local bg = Instance.new("Frame", f) bg.Size = UDim2.new(1, 0, 0, 3) bg.Position = UDim2.new(0, 0, 0, 18) bg.BackgroundColor3 = Color3.fromRGB(40,40,40) Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)
    local fill = Instance.new("Frame", bg) fill.Size = UDim2.new((def-min)/(max-min), 0, 1, 0) fill.BackgroundColor3 = ACCENT Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
    local active = false
    local function upd(x) local pct = math.clamp((x-bg.AbsolutePosition.X)/bg.AbsoluteSize.X, 0, 1) local val = math.floor(min+(max-min)*pct) fill.Size = UDim2.new(pct,0,1,0) v.Text = tostring(val) cb(val) end
    bg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = true upd(i.Position.X) end end)
    U.InputChanged:Connect(function(i) if active and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i.Position.X) end end)
    U.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = false reg(text.." alterado") end end)
end

local function makeButton(p, text, cb)
    local b = Instance.new("TextButton", p) b.Size = UDim2.new(1, 0, 0, 24) b.BackgroundColor3 = Color3.fromRGB(35,35,40) b.Text = text b.TextColor3 = TEXT b.TextSize = 11 b.Font = Enum.Font.GothamBold Instance.new("UICorner", b).CornerRadius = UDim.new(0,4)
    b.MouseButton1Click:Connect(function() reg("Clicou: "..text) cb() b.Text = "✅ Feito!" task.wait(1) b.Text = text end)
end

local function makeCycle(p, text, list, def, cb)
    local b = Instance.new("TextButton", p) b.Size = UDim2.new(1, 0, 0, 24) b.BackgroundColor3 = Color3.fromRGB(35,35,40) b.Text = "  "..text..": "..def b.TextColor3 = TEXT b.TextSize = 11 b.Font = Enum.Font.Gotham b.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,4)
    local idx = 1 for i, v in ipairs(list) do if v == def then idx = i end end
    b.MouseButton1Click:Connect(function() idx = (idx % #list) + 1 b.Text = "  "..text..": "..list[idx] reg(text..": "..list[idx]) cb(list[idx]) end)
end

local function makeColorPicker(parent, titleText, initialColor, callback)
    local g = makeGroup(titleText)
    local swatch = Instance.new("Frame", g) swatch.Size = UDim2.new(1, 0, 0, 24) swatch.BackgroundColor3 = initialColor Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, 4)
    local r, gVal, b = math.floor(initialColor.R*255), math.floor(initialColor.G*255), math.floor(initialColor.B*255)
    local function updateColor() local c = Color3.fromRGB(r, gVal, b) swatch.BackgroundColor3 = c callback(c) end
    makeSlider(g, "Red (R)", 0, 255, r, function(v) r = v updateColor() end)
    makeSlider(g, "Green (G)", 0, 255, gVal, function(v) gVal = v updateColor() end)
    makeSlider(g, "Blue (B)", 0, 255, b, function(v) b = v updateColor() end)
end

-- ===================== VISUALS =====================
local drawEsp = {} local highlights = {}
local function getPart(char, name) return char:FindFirstChild(name) or char:FindFirstChild("Torso") end

local function updVisuals()
    local color = CFG.Vis.Rainbow and Color3.fromHSV((tick() % 5) / 5, 1, 1) or CFG.Vis.Color
    for _, p in ipairs(P:GetPlayers()) do
        if p ~= LP and p.Character then
            local char = p.Character local hrp = char:FindFirstChild("HumanoidRootPart") local head = char:FindFirstChild("Head") local hum = char:FindFirstChildOfClass("Humanoid")
            if hrp and head and hum and hum.Health > 0 then
                local sp, on = C:WorldToViewportPoint(head.Position) local bot, botOn = C:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
                if CFG.Vis.Chams then
                    if not highlights[p] then local h = Instance.new("Highlight", gui) h.Adornee = char h.FillColor = color h.FillTransparency = 0.5 h.OutlineTransparency = 1 highlights[p] = h end
                    highlights[p].FillColor = color highlights[p].Enabled = true
                elseif highlights[p] then highlights[p].Enabled = false end
                if on and botOn then
                    if not drawEsp[p] then drawEsp[p] = { Box = D.new("Square"), Name = D.new("Text"), Dist = D.new("Text"), Skeleton = {Head=D.new("Line"), Torso=D.new("Line"), L_Arm=D.new("Line"), R_Arm=D.new("Line"), L_Leg=D.new("Line"), R_Leg=D.new("Line")} } end
                    local d = drawEsp[p] local h = math.abs(bot.Y - sp.Y) local w = h * 0.55
                    d.Box.Visible = CFG.Vis.Box d.Box.Size = Vector2.new(w, h) d.Box.Position = Vector2.new(sp.X - w/2, sp.Y) d.Box.Color = color d.Box.Filled = CFG.Vis.Fill d.Box.Transparency = CFG.Vis.Fill and 0.5 or 1
                    d.Name.Visible = CFG.Vis.Name d.Name.Text = p.Name d.Name.Position = Vector2.new(sp.X, sp.Y - 15) d.Name.Size = 12 d.Name.Center = true d.Name.Outline = true d.Name.Color = color
                    d.Dist.Visible = CFG.Vis.Dist d.Dist.Text = math.floor((hrp.Position - C.CFrame.Position).Magnitude).."m" d.Dist.Position = Vector2.new(sp.X, sp.Y + h + 5) d.Dist.Size = 10 d.Dist.Center = true d.Dist.Outline = true d.Dist.Color = color
                    if CFG.Vis.Skel then
                        local function drawL(line, p1, p2) local s1, on1 = C:WorldToViewportPoint(p1) local s2, on2 = C:WorldToViewportPoint(p2) line.Visible = on1 and on2 if line.Visible then line.From = Vector2.new(s1.X, s1.Y) line.To = Vector2.new(s2.X, s2.Y) line.Color = color line.Thickness = 1 end end
                        local uT = getPart(char, "UpperTorso") or getPart(char, "Torso") local lT = getPart(char, "LowerTorso")
                        if uT and lT then
                            drawL(d.Skeleton.Head, head.Position, uT.Position) drawL(d.Skeleton.Torso, uT.Position, lT.Position)
                            local la = getPart(char, "LeftHand") or getPart(char, "Left Arm") local ra = getPart(char, "RightHand") or getPart(char, "Right Arm") local ll = getPart(char, "LeftFoot") or getPart(char, "Left Leg") local rl = getPart(char, "RightFoot") or getPart(char, "Right Leg")
                            if la then drawL(d.Skeleton.L_Arm, uT.Position, la.Position) end if ra then drawL(d.Skeleton.R_Arm, uT.Position, ra.Position) end if ll then drawL(d.Skeleton.L_Leg, lT.Position, ll.Position) end if rl then drawL(d.Skeleton.R_Leg, lT.Position, rl.Position) end
                        end
                    else for _, l in pairs(d.Skeleton) do l.Visible = false end end
                else
                    if drawEsp[p] then drawEsp[p].Box.Visible = false drawEsp[p].Name.Visible = false drawEsp[p].Dist.Visible = false for _, l in pairs(drawEsp[p].Skeleton) do l.Visible = false end end
                end
            end
        end
    end
    if cloneModel and CFG.Vis.Chams then
        local h = cloneModel:FindFirstChildOfClass("Highlight") if not h then h = Instance.new("Highlight", cloneModel) end h.FillColor = color h.FillTransparency = 0.5 h.OutlineTransparency = 1
    elseif cloneModel then local h = cloneModel:FindFirstChildOfClass("Highlight") if h then h:Destroy() end end
end

-- ===================== AIMBOT =====================
local fovCircle = D.new("Circle") fovCircle.Thickness = 1 fovCircle.NumSides = 64 fovCircle.Visible = false
local oldHitboxSizes = {}
local function resetHitboxes() for part, size in pairs(oldHitboxSizes) do if part and part.Parent then part.Size = size end end oldHitboxSizes = {} end
local function getTarget()
    local center = Vector2.new(C.ViewportSize.X / 2, C.ViewportSize.Y / 2) local best, bestDist = nil, math.huge
    for _, p in ipairs(P:GetPlayers()) do
        if p ~= LP and p.Character then local part = p.Character:FindFirstChild(CFG.Aim.Part) if part then local sp, on = C:WorldToViewportPoint(part.Position) if on then local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude if dist < CFG.Aim.FOV and dist < bestDist then bestDist = dist best = part end end end end
    end
    return best
end
local silentPos = nil
if hookmetamethod then
    local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        if CFG.Aim.On and CFG.Aim.Silent and silentPos and getnamecallmethod() == "FindPartOnRay" then
            local args = {...} if typeof(args[1]) == "Ray" then args[1] = Ray.new(args[1].Origin, (silentPos - args[1].Origin).Unit * args[1].Direction.Magnitude) return oldNamecall(self, unpack(args)) end
        end
        return oldNamecall(self, ...)
    end)
end
U.InputBegan:Connect(function(i, gp) if gp then return end if i.KeyCode == CFG.Aim.Key then CFG.Aim.Holding = true end end)
U.InputEnded:Connect(function(i) if i.KeyCode == CFG.Aim.Key then CFG.Aim.Holding = false silentPos = nil end end)

local crossLines = {D.new("Line"), D.new("Line"), D.new("Line"), D.new("Line")} local crossDot = D.new("Square")
R.RenderStepped:Connect(function()
    if CFG.Hitbox.On then
        for _, p in ipairs(P:GetPlayers()) do if p ~= LP and p.Character then local part = p.Character:FindFirstChild(CFG.Hitbox.Part) if part then if not oldHitboxSizes[part] then oldHitboxSizes[part] = part.Size end part.Size = Vector3.new(CFG.Hitbox.X, CFG.Hitbox.Y, CFG.Hitbox.Z) part.Transparency = 0.5 part.Color = ACCENT part.CanCollide = false end end end
    else resetHitboxes() end
    if CFG.Aim.On then
        fovCircle.Visible = true fovCircle.Position = Vector2.new(C.ViewportSize.X / 2, C.ViewportSize.Y / 2) fovCircle.Radius = CFG.Aim.FOV fovCircle.Color = CFG.Vis.Color
        if CFG.Aim.Holding then
            local target = getTarget()
            if target then
                local predPos = target.Position + (target.Velocity * CFG.Aim.Predict) if CFG.Aim.Silent then silentPos = predPos end
                local want = CFrame.lookAt(C.CFrame.Position, predPos) C.CFrame = C.CFrame:Lerp(want, 1 - CFG.Aim.Smooth)
                if CFG.Aim.AutoFire then pcall(function() VU:CaptureController() VU:ClickButton1(Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)) end) end
            else silentPos = nil end
        else silentPos = nil end
    else fovCircle.Visible = false end
    if CFG.Rage.Spin and LP.Character then local hrp = LP.Character:FindFirstChild("HumanoidRootPart") if hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(45), 0) end end
    local center = Vector2.new(C.ViewportSize.X / 2, C.ViewportSize.Y / 2)
    if CFG.Cross.On then
        crossDot.Visible = CFG.Cross.Dot crossDot.Size = Vector2.new(2, 2) crossDot.Position = center - Vector2.new(1,1) crossDot.Color = CFG.Cross.Color crossDot.Filled = true
        local lines = { {center - Vector2.new(0, CFG.Cross.Gap), center - Vector2.new(0, CFG.Cross.Gap + CFG.Cross.Size)}, {center + Vector2.new(0, CFG.Cross.Gap), center + Vector2.new(0, CFG.Cross.Gap + CFG.Cross.Size)}, {center - Vector2.new(CFG.Cross.Gap, 0), center - Vector2.new(CFG.Cross.Gap + CFG.Cross.Size, 0)}, {center + Vector2.new(CFG.Cross.Gap, 0), center + Vector2.new(CFG.Cross.Gap + CFG.Cross.Size, 0)} }
        for i, l in ipairs(crossLines) do l.Visible = true l.From = lines[i][1] l.To = lines[i][2] l.Color = CFG.Cross.Color l.Thickness = 1 end
    else crossDot.Visible = false for _, l in ipairs(crossLines) do l.Visible = false end end
end)

-- ===================== UI BUILDERS =====================
local function cleanUI() for _, v in ipairs(content:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end end

local function buildMain()
    cleanUI()
    local g = makeGroup("DASHBOARD")
    local infoLbl = Instance.new("TextLabel", g) infoLbl.Size = UDim2.new(1,0,0,20) infoLbl.BackgroundTransparency = 1 infoLbl.Text = "Bem-vindo, "..LP.DisplayName infoLbl.TextColor3 = Color3.fromRGB(255,255,255) infoLbl.TextSize = 14 infoLbl.Font = Enum.Font.GothamBold infoLbl.TextXAlignment = Enum.TextXAlignment.Left
    local infoLbl2 = Instance.new("TextLabel", g) infoLbl2.Size = UDim2.new(1,0,0,14) infoLbl2.BackgroundTransparency = 1 infoLbl2.Text = "Executor: "..executor infoLbl2.TextColor3 = TEXT infoLbl2.TextSize = 11 infoLbl2.Font = Enum.Font.Gotham infoLbl2.TextXAlignment = Enum.TextXAlignment.Left
    makeButton(g, "📋 Copiar HWID", function() pcall(function() setclipboard(hwid) end) end)
    makeButton(g, "💬 Entrar no Discord", function() pcall(function() setclipboard("https://discord.gg/s6GSy4TuJ") end) end)

    local g2 = makeGroup("INFORMAÇÕES")
    local infoLbl3 = Instance.new("TextLabel", g2) infoLbl3.Size = UDim2.new(1,0,0,14) infoLbl3.BackgroundTransparency = 1 infoLbl3.Text = "Status: Online" infoLbl3.TextColor3 = TEXT infoLbl3.TextSize = 11 infoLbl3.Font = Enum.Font.Gotham infoLbl3.TextXAlignment = Enum.TextXAlignment.Left
    local infoLbl4 = Instance.new("TextLabel", g2) infoLbl4.Size = UDim2.new(1,0,0,14) infoLbl4.BackgroundTransparency = 1 infoLbl4.Text = "Versão: V11.3 Logs" infoLbl4.TextColor3 = TEXT infoLbl4.TextSize = 11 infoLbl4.Font = Enum.Font.Gotham infoLbl4.TextXAlignment = Enum.TextXAlignment.Left
end

local function buildVisuals()
    cleanUI()
    local g = makeGroup("VISUALS (VAC EXTERNAL)")
    makeToggle(g, "ESP Box", true, function(v) CFG.Vis.Box = v end)
    makeToggle(g, "Box Filled", false, function(v) CFG.Vis.Fill = v end)
    makeToggle(g, "Skeleton", true, function(v) CFG.Vis.Skel = v end)
    makeToggle(g, "Chams (Glow)", true, function(v) CFG.Vis.Chams = v end)
    makeToggle(g, "Rainbow Mode", false, function(v) CFG.Vis.Rainbow = v end)
    makeToggle(g, "Show Name", true, function(v) CFG.Vis.Name = v end)
    makeToggle(g, "Show Distance", true, function(v) CFG.Vis.Dist = v end)
    
    makeColorPicker(g, "ESP COLOR", CFG.Vis.Color, function(c) CFG.Vis.Color = c end)

    local c = makeGroup("CROSSHAIR")
    makeToggle(c, "Enabled", true, function(v) CFG.Cross.On = v end)
    makeToggle(c, "Dot", true, function(v) CFG.Cross.Dot = v end)
    makeSlider(c, "Size", 0, 20, 6, function(v) CFG.Cross.Size = v end)
    makeSlider(c, "Gap", 0, 20, 3, function(v) CFG.Cross.Gap = v end)
    
    makeColorPicker(c, "CROSSHAIR COLOR", CFG.Cross.Color, function(c) CFG.Cross.Color = c end)
end

local function buildAimbot()
    cleanUI()
    local g = makeGroup("AIMBOT (WINTER)")
    makeToggle(g, "Enabled (Hold E)", false, function(v) CFG.Aim.On = v end)
    makeToggle(g, "Magic Bullet (Silent)", false, function(v) CFG.Aim.Silent = v end)
    makeToggle(g, "Auto Fire", false, function(v) CFG.Aim.AutoFire = v end)
    makeSlider(g, "FOV", 10, 500, 150, function(v) CFG.Aim.FOV = v end)
    makeSlider(g, "Smooth", 1, 99, 30, function(v) CFG.Aim.Smooth = v / 100 end)
    makeSlider(g, "Prediction", 0, 50, 16, function(v) CFG.Aim.Predict = v / 100 end)
    makeCycle(g, "Part", {"Head", "HumanoidRootPart", "UpperTorso"}, "Head", function(v) CFG.Aim.Part = v end)
    
    local h = makeGroup("HITBOX EXPANDER")
    makeToggle(h, "Enabled", false, function(v) CFG.Hitbox.On = v end)
    makeCycle(h, "Part", {"Head", "HumanoidRootPart"}, "Head", function(v) CFG.Hitbox.Part = v end)
    makeSlider(h, "Size X", 1, 50, 20, function(v) CFG.Hitbox.X = v end)
    makeSlider(h, "Size Y", 1, 50, 20, function(v) CFG.Hitbox.Y = v end)
    makeSlider(h, "Size Z", 1, 50, 20, function(v) CFG.Hitbox.Z = v end)
end

local function buildRage()
    cleanUI()
    local g = makeGroup("RAGE")
    makeToggle(g, "Spinbot (Anti-Aim)", false, function(v) CFG.Rage.Spin = v end)
    makeToggle(g, "Infinite Jump", false, function(v) CFG.Rage.InfJump = v end)
    U.JumpRequest:Connect(function() if CFG.Rage.InfJump and LP.Character then local h = LP.Character:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end)
end

local function buildLogs()
    cleanUI()
    local c1 = makeGroup("SYSTEM LOGS")
    local sf = Instance.new("ScrollingFrame", c1)
    sf.Size = UDim2.new(1, 0, 0, 250)
    sf.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    sf.BorderSizePixel = 0; sf.ScrollBarThickness = 2; sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UICorner", sf).CornerRadius = UDim.new(0, 4)
    
    logUIList = Instance.new("Frame", sf)
    logUIList.Size = UDim2.new(1, 0, 0, 0); logUIList.AutomaticSize = Enum.AutomaticSize.Y
    logUIList.BackgroundTransparency = 1
    Instance.new("UIListLayout", logUIList).Padding = UDim.new(0, 2)
    
    for _, txt in ipairs(logs) do
        local l = Instance.new("TextLabel", logUIList)
        l.Size = UDim2.new(1, 0, 0, 18); l.BackgroundTransparency = 1
        l.Text = txt; l.TextColor3 = TEXT; l.TextSize = 10; l.Font = Enum.Font.Code; l.TextXAlignment = Enum.TextXAlignment.Left
    end
    
    makeButton(c1, "🗑️ Limpar Logs", function() logs = {}; cleanUI(); buildLogs() end)
end

local tabs = { {N="Main", F=buildMain}, {N="Visuals", F=buildVisuals}, {N="Aimbot", F=buildAimbot}, {N="Rage", F=buildRage}, {N="Logs", F=buildLogs} }
for i, t in ipairs(tabs) do
    local b = Instance.new("TextButton", side)
    b.Size = UDim2.new(1, -20, 0, 30) b.Position = UDim2.new(0, 10, 0, 20 + (i*35))
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 22) b.Text = t.N b.TextColor3 = TEXT b.TextSize = 12 b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.MouseButton1Click:Connect(function()
        for _, btn in ipairs(side:GetChildren()) do if btn:IsA("TextButton") then btn.TextColor3 = TEXT btn.BackgroundColor3 = Color3.fromRGB(20,20,22) end end
        b.TextColor3 = ACCENT b.BackgroundColor3 = Color3.fromRGB(35,35,40)
        title.Text = "ZEDUX | " .. string.upper(t.N)
        t.F()
    end)
end

buildMain()
R.RenderStepped:Connect(function() pcall(updVisuals) end)
reg("Menu carregado.")
