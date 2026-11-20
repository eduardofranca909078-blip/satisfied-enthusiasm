-- ============================================================
--  olliE panel v7-L  ·  ESP + AIMBOT  ·  Roblox (MOBILE FIX)
-- ============================================================
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")
local UIS        = game:GetService("UserInputService")
local Camera     = Workspace.CurrentCamera
local LP         = Players.LocalPlayer
local Mouse      = LP:GetMouse()
local D          = Drawing

local cfg = {
    enabled=true, showBox=true, showName=true, showDist=true,
    showHealth=true, showTracer=false,
    maxDist=500, thickness=1, textSize=14,
    keybind=Enum.KeyCode.RightShift,
    boxR=0, boxG=255, boxB=140,
    nameR=240, nameG=240, nameB=250,
    tracerR=255, tracerG=70, tracerB=70,
    aimEnabled=true, silent=false,
    teamCheck=true, wallCheck=true, fovCheck=true, showFov=true,
    fov=120, aimDist=600, smooth=35,
    aimPart="Head", aimKey=Enum.KeyCode.E,
    silentKey=Enum.KeyCode.RightAlt,
    fovR=0, fovG=255, fovB=140,
}

local AIM_PARTS = {"Head","UpperTorso","HumanoidRootPart","LowerTorso","Random"}

local C = {
    panelBg=Color3.fromRGB(16,17,22), panelEdge=Color3.fromRGB(38,40,52),
    rowBg=Color3.fromRGB(24,26,34), rowHover=Color3.fromRGB(34,37,48),
    subBg=Color3.fromRGB(20,21,28),
    accent=Color3.fromRGB(0,255,140), accentDim=Color3.fromRGB(0,140,80),
    text=Color3.fromRGB(228,230,240), textDim=Color3.fromRGB(130,134,150),
    closeHover=Color3.fromRGB(200,60,60),
}

local SAVE_PATH = "ollie_esp_v7_" .. tostring(game.PlaceId) .. ".json"
local function hasFS() return writefile and readfile and isfile end

local function serialize(t, indent)
    indent = indent or ""; local ni = indent .. "  "
    local parts = {}
    for k, v in pairs(t) do
        local key = type(k)=="string" and string.format("[%q]",k) or "["..tostring(k).."]"
        local val
        if type(v)=="table" then val = serialize(v, ni)
        elseif type(v)=="string" then val = string.format("%q", v)
        elseif type(v)=="Color3" then
            val = string.format('{["__c3"]={%d,%d,%d}}',
                math.floor(v.R*255), math.floor(v.G*255), math.floor(v.B*255))
        elseif type(v)=="EnumItem" then val = string.format('[%q]', "__enum__"..tostring(v))
        elseif type(v)=="boolean" or type(v)=="number" then val = tostring(v)
        else val = "nil" end
        parts[#parts+1] = ni..key.."="..val
    end
    return "{\n"..table.concat(parts,",\n").."\n"..indent.."}"
end

local function deserialize(src)
    if type(src)~="string" or src=="" then return nil end
    src = src:gsub('"__enum__(Enum%.[%w_]+%.[%w_]+)"', "%1")
    src = src:gsub('{%["__c3"%]={(%d+),(%d+),(%d+)}}', "Color3.fromRGB(%1,%2,%3)")
    local ls = loadstring or load
    if not ls then return nil end
    local fn, err = ls("return "..src)
    if not fn then return nil end
    local ok, data = pcall(fn)
    if not ok or type(data)~="table" then return nil end
    return data
end

local function mk(k) local o=D.new(k); o.Visible=false; return o end
local function sq(f,c) local s=mk("Square"); s.Filled=f; s.Color=c or C.panelBg; return s end
local function tx(s,c) local t=mk("Text"); t.Size=s; t.Center=true; t.Outline=true; t.Color=c or C.text; return t end
local function ln(c) local l=mk("Line"); l.Thickness=1; l.Color=c or C.accent; return l end
local function rgb(r,g,b) return Color3.fromRGB(r,g,b) end

-- ============ ESP STATE ============
local esp={}
local function ensureEsp(p)
    if esp[p] then return esp[p] end
    esp[p]={box=sq(false), hpBg=sq(true,rgb(30,30,40)), hpFg=sq(true),
        name=tx(cfg.textSize,C.text), dist=tx(cfg.textSize-2,C.textDim), tracer=ln()}
    return esp[p]
end
local function clearEsp(p)
    local e=esp[p]; if not e then return end
    for _,v in pairs(e) do pcall(function() v:Remove() end) end
    esp[p]=nil
end
local function w2s(pos)
    local sp,on=Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X,sp.Y),(on and sp.Z>0)
end
local function charData(p)
    local c=p.Character; if not c then return end
    local hrp=c:FindFirstChild("HumanoidRootPart")
    local hum=c:FindFirstChildOfClass("Humanoid")
    local head=c:FindFirstChild("Head")
    if not(hrp and hum and head) or hum.Health<=0 then return end
    return c,hrp,hum,head
end

local function updateESP()
    local camPos=Camera.CFrame.Position
    local boxCol=rgb(cfg.boxR,cfg.boxG,cfg.boxB)
    local nameCol=rgb(cfg.nameR,cfg.nameG,cfg.nameB)
    local traceCol=rgb(cfg.tracerR,cfg.tracerG,cfg.tracerB)
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then
            local e=ensureEsp(p)
            local c,hrp,hum,head=charData(p)
            local ok=false
            if c and cfg.enabled then
                local dist=(hrp.Position-camPos).Magnitude
                if dist<=cfg.maxDist then
                    local top,topOn=w2s(head.Position+Vector3.new(0,0.5,0))
                    local bot,botOn=w2s(hrp.Position-Vector3.new(0,3,0))
                    if topOn and botOn then
                        ok=true
                        local h=math.abs(bot.Y-top.Y); local w=h*0.55
                        local pos=Vector2.new(top.X-w/2,top.Y)
                        e.box.Visible=cfg.showBox
                        e.box.Position=pos; e.box.Size=Vector2.new(w,h)
                        e.box.Color=boxCol; e.box.Thickness=cfg.thickness
                        local showText = h > 30
                        e.name.Visible=cfg.showName and showText
                        e.name.Text=p.Name
                        e.name.Position=Vector2.new(pos.X+w/2,pos.Y-cfg.textSize-3)
                        e.name.Size=cfg.textSize; e.name.Color=nameCol
                        e.dist.Visible=cfg.showDist and showText
                        e.dist.Text=string.format("%d studs",math.floor(dist))
                        e.dist.Position=Vector2.new(pos.X+w/2,pos.Y+h+5)
                        e.dist.Size=cfg.textSize-2; e.dist.Color=C.textDim
                        local pct=math.clamp(hum.Health/hum.MaxHealth,0,1)
                        local bw=3
                        e.hpBg.Visible=cfg.showHealth
                        e.hpBg.Position=Vector2.new(pos.X-bw-3,pos.Y)
                        e.hpBg.Size=Vector2.new(bw,h)
                        e.hpFg.Visible=cfg.showHealth
                        e.hpFg.Position=Vector2.new(pos.X-bw-3,pos.Y+h*(1-pct))
                        e.hpFg.Size=Vector2.new(bw,h*pct)
                        e.hpFg.Color=rgb(math.floor(255*(1-pct)),math.floor(255*pct),70)
                        e.tracer.Visible=cfg.showTracer
                        if cfg.showTracer then
                            e.tracer.From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y)
                            e.tracer.To=Vector2.new(pos.X+w/2,pos.Y+h)
                            e.tracer.Color=traceCol
                        end
                    end
                end
            end
            if not ok then for _,v in pairs(e) do v.Visible=false end end
        end
    end
end

-- ============ AIMBOT ============
local fovCircle=mk("Circle")
fovCircle.Thickness=1.5; fovCircle.NumSides=64

local aiming=false
local currentTarget, silentPos
local oldIndex

local function screenCenter() return Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2) end
local function isFriendly(p)
    if not cfg.teamCheck then return false end
    if p.Team==nil then return false end
    return p.Team==LP.Team
end
local function hasLOS(targetPart)
    if not cfg.wallCheck then return true end
    local origin=Camera.CFrame.Position
    local dir=targetPart.Position-origin
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances={LP.Character,targetPart.Parent}
    local hit=Workspace:Raycast(origin,dir,params)
    return hit==nil or hit.Instance:IsDescendantOf(targetPart.Parent)
end
local function aimPartOf(char)
    if cfg.aimPart=="Random" then
        local list={"Head","UpperTorso","HumanoidRootPart","LowerTorso"}
        return char:FindFirstChild(list[math.random(#list)])
    end
    return char:FindFirstChild(cfg.aimPart)
end
local function findBestTarget()
    local center=screenCenter()
    local best, bestDist = nil, math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and not isFriendly(p) then
            local c,hum=charData(p)
            if c then
                local part=aimPartOf(c)
                if part then
                    local sp,on=w2s(part.Position)
                    if on then
                        local d3=(part.Position-Camera.CFrame.Position).Magnitude
                        local sd=(sp-center).Magnitude
                        if d3<=cfg.aimDist and (not cfg.fovCheck or sd<=cfg.fov)
                        and hasLOS(part) and sd<bestDist then
                            bestDist=sd
                            best={player=p,part=part,screenPos=sp,worldPos=part.Position}
                        end
                    end
                end
            end
        end
    end
    return best
end

if hookmetamethod then
    oldIndex = hookmetamethod(game,"__index",function(self,key)
        if self==Mouse and silentPos then
            if key=="Hit" then return CFrame.lookAt(Camera.CFrame.Position,silentPos)
            elseif key=="Target" then return currentTarget and currentTarget.part
            elseif key=="UnitRay" then
                local o=Camera.CFrame.Position
                return Ray.new(o,(silentPos-o))
            end
        end
        return oldIndex(self,key)
    end)
end

local function updateAimbot()
    if cfg.showFov and cfg.aimEnabled then
        fovCircle.Visible=true
        fovCircle.Position=screenCenter()
        fovCircle.Radius=cfg.fov
        fovCircle.Color=rgb(cfg.fovR,cfg.fovG,cfg.fovB)
    else
        fovCircle.Visible=false
    end

    if not cfg.aimEnabled or not aiming then
        currentTarget=nil; silentPos=nil; return
    end
    local t=findBestTarget()
    currentTarget=t
    if not t then silentPos=nil; return end
    if cfg.silent then silentPos=t.worldPos end

    local alpha=1-cfg.smooth/100
    if alpha>0 then
        local want=CFrame.lookAt(Camera.CFrame.Position,t.worldPos)
        Camera.CFrame=Camera.CFrame:Lerp(want,alpha)
    end
end

-- ============ MOBILE TOGGLE BUTTON ============
local mobileBtn  = mk("Square")
local mobileTxt  = mk("Text")
mobileBtn.Filled = true
mobileBtn.Color  = C.panelBg
mobileBtn.Size   = Vector2.new(90, 32)
mobileBtn.Position = Vector2.new(20, 100)
mobileBtn.Visible = true

mobileTxt.Text   = "MENU"
mobileTxt.Size   = 14
mobileTxt.Center = true
mobileTxt.Outline= true
mobileTxt.Color  = C.accent
mobileTxt.Position = Vector2.new(20 + 45, 100 + 16)
mobileTxt.Visible  = true

-- ============ PANEL ============
local panel={open=false, minimized=true, x=40,y=160,w=270,pad=10,headH=46,rowH=26,
    items={},elems={},openGroups={}}

local function addElem(o) table.insert(panel.elems,o); return o end

local bg       = addElem(sq(true,C.panelBg))
local edge     = addElem(sq(false,C.panelEdge))
local accent   = addElem(sq(true,C.accent))
local title    = addElem(tx(15,C.text))
local subtitle = addElem(tx(9,C.textDim))
local hint     = addElem(tx(9,C.textDim))
local btnMin   = addElem(sq(true,C.subBg))
local btnMinL  = addElem(tx(12,C.textDim))
local btnClose = addElem(sq(true,C.subBg))
local btnCloseL= addElem(tx(12,C.textDim))

title.Text="PANEL"; subtitle.Text="ROBLOX · v7-M"; hint.Text="MOBILE"
btnMinL.Text="–"; btnMinL.Center=true; btnMinL.Outline=false
btnCloseL.Text="×"; btnCloseL.Center=true; btnCloseL.Outline=false

local function saveState()
    if not hasFS() then return end
    local snap={cfg={}, ui={x=panel.x,y=panel.y,minimized=panel.minimized,open=panel.open,groups={}}}
    for k,v in pairs(cfg) do snap.cfg[k]=v end
    for gk,gv in pairs(panel.openGroups) do if gv then snap.ui.groups[gk]=true end end
    pcall(writefile,SAVE_PATH,serialize(snap))
end
local saveTimer=nil
function scheduleSave()
    if not hasFS() then return end
    if saveTimer then pcall(function() task.cancel(saveTimer) end) end
    saveTimer=task.delay(1.5,function() saveState(); saveTimer=nil end)
end
local function loadState()
    if not hasFS() or not isfile(SAVE_PATH) then return false end
    local ok,raw=pcall(readfile,SAVE_PATH)
    if not ok or not raw or raw=="" then return false end
    local data=deserialize(raw)
    if type(data)~="table" then return false end
    if type(data.cfg)=="table" then
        for k,v in pairs(data.cfg) do if cfg[k]~=nil then cfg[k]=v end end
    end
    if type(data.ui)=="table" then
        panel.x=data.ui.x or panel.x
        panel.y=data.ui.y or panel.y
        panel.minimized=data.ui.minimized and true or false
        panel.open=data.ui.open and true or false
        if type(data.ui.groups)=="table" then
            for gk,gv in pairs(data.ui.groups) do if gv then panel.openGroups[gk]=true end end
        end
    end
    return true
end

local function newToggle(label,key,indent)
    local it={kind="toggle",key=key,indent=indent or 0,anim=cfg[key] and 1 or 0}
    it.bg=addElem(sq(true,C.rowBg)); it.acc=addElem(sq(true,C.accentDim))
    it.dotBg=addElem(sq(true,rgb(40,42,54))); it.dot=addElem(sq(true,C.accent))
    it.lbl=addElem(tx(11,C.text)); it.lbl.Center=false; it.lbl.Outline=false; it.lbl.Text=label
    panel.items[#panel.items+1]=it; return it
end
local function newSlider(label,key,min,max,indent)
    local it={kind="slider",key=key,min=min,max=max,indent=indent or 0,anim=(cfg[key]-min)/(max-min)}
    it.bg=addElem(sq(true,C.rowBg)); it.track=addElem(sq(true,rgb(30,32,42)))
    it.fill=addElem(sq(true,C.accent))
    it.lbl=addElem(tx(10,C.text)); it.lbl.Center=false; it.lbl.Outline=false; it.lbl.Text=label
    panel.items[#panel.items+1]=it; return it
end
local function newCycle(label,key,list,indent)
    local it={kind="cycle",key=key,list=list,indent=indent or 0}
    it.bg=addElem(sq(true,C.rowBg))
    it.val=addElem(tx(9,C.accent)); it.val.Center=false; it.val.Outline=false
    it.lbl=addElem(tx(11,C.text)); it.lbl.Center=false; it.lbl.Outline=false
    it.lbl.Text=label; it.val.Text=tostring(cfg[key])
    panel.items[#panel.items+1]=it; return it
end
local function newGroup(label,key)
    local g={kind="group",key=key,open=false,body={}}
    g.bg=addElem(sq(true,C.subBg)); g.chev=addElem(ln(C.textDim))
    g.lbl=addElem(tx(11,C.text)); g.lbl.Center=false; g.lbl.Outline=false; g.lbl.Text=label
    panel.items[#panel.items+1]=g; return g
end
local function childToggle(g,label,key)
    local it=newToggle(label,key,1); it.parent=g; g.body[#g.body+1]=it; return it
end
local function childSlider(g,label,key,min,max)
    local it=newSlider(label,key,min,max,1); it.parent=g; g.body[#g.body+1]=it; return it
end
local function childCycle(g,label,key,list)
    local it=newCycle(label,key,list,1); it.parent=g; g.body[#g.body+1]=it; return it
end
local function addSwatch(g,label,rK,gK,bK)
    local it={kind="swatch",rKey=rK,gKey=gK,bKey=bK,parent=g,indent=1}
    it.bg=addElem(sq(true,C.subBg))
    it.lbl=addElem(tx(10,C.textDim)); it.lbl.Center=false; it.lbl.Outline=false; it.lbl.Text=label
    it.obj=addElem(sq(true,rgb(cfg[rK],cfg[gK],cfg[bK])))
    g.body[#g.body+1]=it
    childSlider(g,label.." R",rK,0,255)
    childSlider(g,label.." G",gK,0,255)
    childSlider(g,label.." B",bK,0,255)
end

newToggle("ESP Enabled","enabled")
local gVis = newGroup("VISUAL","grp_visual")
childToggle(gVis,"Box","showBox"); childToggle(gVis,"Name","showName")
childToggle(gVis,"Distance","showDist"); childToggle(gVis,"Health","showHealth")
childToggle(gVis,"Tracer","showTracer")

local gCol = newGroup("ESP COLORS","grp_colors")
addSwatch(gCol,"Box","boxR","boxG","boxB")
addSwatch(gCol,"Name","nameR","nameG","nameB")
addSwatch(gCol,"Tracer","tracerR","tracerG","tracerB")

local gEspT = newGroup("ESP TARGET","grp_esptarget")
childSlider(gEspT,"Max Dist","maxDist",50,2000)
childSlider(gEspT,"Thickness","thickness",1,4)

newToggle("Aimbot Enabled","aimEnabled")
local gAim = newGroup("AIMBOT","grp_aim")
childToggle(gAim,"Silent Aim","silent"); childToggle(gAim,"Team Check","teamCheck")
childToggle(gAim,"Wall Check","wallCheck"); childToggle(gAim,"FOV Check","fovCheck")
childToggle(gAim,"Show FOV","showFov")
childSlider(gAim,"FOV","fov",20,500); childSlider(gAim,"Smooth","smooth",1,99)
childSlider(gAim,"Max Dist","aimDist",50,2000)
childCycle(gAim,"Aim Part","aimPart",AIM_PARTS)

local gFovCol = newGroup("FOV COLOR","grp_fovcol")
addSwatch(gFovCol,"FOV","fovR","fovG","fovB")

local function itemVisible(it) return (not it.parent) or it.parent.open end

local function layout()
    local x,y=panel.x,panel.y
    local w=panel.w
    local totalH=panel.headH + (panel.minimized and 0 or panel.pad)
    if not panel.minimized then
        for _,it in ipairs(panel.items) do if itemVisible(it) then totalH=totalH+panel.rowH end end
    end
    bg.Position=Vector2.new(x,y); bg.Size=Vector2.new(w,totalH)
    edge.Position=bg.Position; edge.Size=bg.Size
    accent.Position=Vector2.new(x,y); accent.Size=Vector2.new(4,totalH)
    title.Position=Vector2.new(x+16,y+18)
    subtitle.Position=Vector2.new(x+w-70,y+16)
    hint.Position=Vector2.new(x+w-70,y+32)
    btnMin.Position=Vector2.new(x+w-52,y+13); btnMin.Size=Vector2.new(20,20)
    btnMinL.Position=Vector2.new(x+w-42,y+23)
    btnClose.Position=Vector2.new(x+w-28,y+13); btnClose.Size=Vector2.new(20,20)
    btnCloseL.Position=Vector2.new(x+w-18,y+23)
    btnMin.Visible=panel.open; btnMinL.Visible=panel.open
    btnClose.Visible=panel.open; btnCloseL.Visible=panel.open

    if panel.minimized then
        for _,it in ipairs(panel.items) do
            for _,k in ipairs({"bg","acc","dotBg","dot","lbl","track","fill","obj","val","chev"}) do
                if it[k] then it[k].Visible=false end
            end
        end
        return
    end

    local ry=y+panel.headH
    for _,it in ipairs(panel.items) do
        local vis=itemVisible(it) and panel.open
        local indent=(it.indent or 0)*14
        local rx,rw,rh = x+8+indent, w-16-indent, panel.rowH-4
        if it.kind=="group" then
            it.bg.Visible=vis; it.chev.Visible=vis; it.lbl.Visible=vis
            if vis then
                it.bg.Position=Vector2.new(x+8,ry); it.bg.Size=Vector2.new(w-16,rh)
                it.lbl.Position=Vector2.new(x+18,ry+rh/2); it.lbl.Size=11
                local cxp,cyp=x+w-24,ry+rh/2
                it.chev.From=Vector2.new(cxp-3,cyp-3); it.chev.To=Vector2.new(cxp+3,cyp+3)
                it.chev.Color=it.open and C.accent or C.textDim
            end
        elseif it.kind=="toggle" then
            it.bg.Visible=vis; it.acc.Visible=vis; it.dotBg.Visible=vis; it.dot.Visible=vis; it.lbl.Visible=vis
            if vis then
                it.bg.Position=Vector2.new(rx,ry); it.bg.Size=Vector2.new(rw,rh)
                it.acc.Position=Vector2.new(rx,ry); it.acc.Size=Vector2.new(2,rh)
                it.dotBg.Position=Vector2.new(rx+rw-26,ry+(rh-12)/2); it.dotBg.Size=Vector2.new(22,12)
                it.dot.Size=Vector2.new(10,10)
                it.lbl.Position=Vector2.new(rx+12,ry+rh/2); it.lbl.Size=11
            end
        elseif it.kind=="slider" then
            it.bg.Visible=vis; it.track.Visible=vis; it.fill.Visible=vis; it.lbl.Visible=vis
            if vis then
                it.bg.Position=Vector2.new(rx,ry); it.bg.Size=Vector2.new(rw,rh)
                it.track.Position=Vector2.new(rx+rw-70,ry+rh/2-1); it.track.Size=Vector2.new(60,2)
                it.fill.Position=it.track.Position; it.fill.Size=Vector2.new(60*it.anim,2)
                it.lbl.Position=Vector2.new(rx+12,ry+rh/2); it.lbl.Size=10
            end
        elseif it.kind=="cycle" then
            it.bg.Visible=vis; it.lbl.Visible=vis; it.val.Visible=vis
            if vis then
                it.bg.Position=Vector2.new(rx,ry); it.bg.Size=Vector2.new(rw,rh)
                it.lbl.Position=Vector2.new(rx+12,ry+rh/2); it.lbl.Size=11
                it.val.Position=Vector2.new(rx+rw-78,ry+rh/2); it.val.Size=9
            end
        elseif it.kind=="swatch" then
            it.bg.Visible=vis; it.lbl.Visible=vis; it.obj.Visible=vis
            if vis then
                it.bg.Position=Vector2.new(rx,ry); it.bg.Size=Vector2.new(rw,rh)
                it.lbl.Position=Vector2.new(rx+12,ry+rh/2)
                it.obj.Position=Vector2.new(rx+rw-26,ry+(rh-14)/2); it.obj.Size=Vector2.new(14,14)
            end
        end
        if itemVisible(it) then ry=ry+panel.rowH end
    end
end

local function setVisible(v)
    for _,e in ipairs(panel.elems) do e.Visible=v end
    if v then layout() end
end

local dragging=false; local dragStart; local dragOrigin
local sliderDrag=nil; local lastHeaderClick=0

local function hit(pt,pos,size)
    return pt.X>=pos.X and pt.X<=pos.X+size.X and pt.Y>=pos.Y and pt.Y<=pos.Y+size.Y
end

local function applySlider(it,m)
    local pct=math.clamp((m.X-it.track.Position.X)/it.track.Size.X,0,1)
    cfg[it.key]=math.floor(it.min+(it.max-it.min)*pct+0.5)
    it.anim=pct
    it.lbl.Text=string.format("%s  %d",it.key:gsub("(%u)"," %1"):gsub("^%s",""),cfg[it.key])
    scheduleSave()
end

local function toggleGroup(g)
    g.open=not g.open
    if g.open then panel.openGroups[g.key]=true else panel.openGroups[g.key]=nil end
    layout(); scheduleSave()
end

-- INPUT (aceita Touch e Mouse)
local function isInput(input, expected)
    return input.UserInputType == expected
end

UIS.InputBegan:Connect(function(input,gp)
    if gp then return end
    local isTouch = (input.UserInputType==Enum.UserInputType.Touch)
    local isMouse = (input.UserInputType==Enum.UserInputType.MouseButton1)
    
    -- Botão MENU mobile
    if isTouch or isMouse then
        local m = isTouch and Vector2.new(input.Position.X, input.Position.Y) or UIS:GetMouseLocation()
        if hit(m, mobileBtn.Position, mobileBtn.Size) then
            panel.open = not panel.open
            setVisible(panel.open)
            scheduleSave()
            return
        end
    end

    -- Teclado (PC)
    if input.KeyCode==cfg.keybind then
        panel.open=not panel.open
        setVisible(panel.open); scheduleSave(); return
    end

    if not (isTouch or isMouse) or not panel.open then return end
    local m = isTouch and Vector2.new(input.Position.X, input.Position.Y) or UIS:GetMouseLocation()
    
    if not hit(m,bg.Position,bg.Size) then return end

    if hit(m,btnClose.Position,btnClose.Size) then
        panel.open=false; panel.minimized=false; setVisible(false); scheduleSave(); return
    end
    if hit(m,btnMin.Position,btnMin.Size) then
        panel.minimized=not panel.minimized; layout(); scheduleSave(); return
    end
    if hit(m,bg.Position,Vector2.new(bg.Size.X,panel.headH)) then
        local now=tick()
        if now-lastHeaderClick<0.3 then
            panel.minimized=not panel.minimized; layout(); scheduleSave(); lastHeaderClick=0; return
        end
        lastHeaderClick=now; dragging=true; dragStart=m; dragOrigin={x=panel.x,y=panel.y}; return
    end
    if panel.minimized then return end

    for _,it in ipairs(panel.items) do
        if itemVisible(it) and it.bg and it.bg.Visible then
            if it.kind=="group" and hit(m,it.bg.Position,it.bg.Size) then toggleGroup(it); return end
            if it.kind=="toggle" and hit(m,it.bg.Position,it.bg.Size) then cfg[it.key]=not cfg[it.key]; scheduleSave(); return end
            if it.kind=="cycle" and hit(m,it.bg.Position,it.bg.Size) then
                local idx=1
                for i,v in ipairs(it.list) do if v==cfg[it.key] then idx=i end end
                idx=(idx % #it.list)+1
                cfg[it.key]=it.list[idx]; it.val.Text=tostring(cfg[it.key]); scheduleSave(); return
            end
            if it.kind=="slider" and hit(m,Vector2.new(it.track.Position.X-8,it.track.Position.Y-10),Vector2.new(it.track.Size.X+16,24)) then
                sliderDrag=it; applySlider(it,m); return
            end
        end
    end
end)

UIS.InputChanged:Connect(function(input)
    local isTouch = (input.UserInputType==Enum.UserInputType.Touch)
    local isMouse = (input.UserInputType==Enum.UserInputType.MouseButton1)
    if not (isTouch or isMouse) then return end
    
    local m = isTouch and Vector2.new(input.Position.X, input.Position.Y) or UIS:GetMouseLocation()
    if dragging then
        panel.x=dragOrigin.x+(m.X-dragStart.X)
        panel.y=dragOrigin.y+(m.Y-dragStart.Y)
        layout(); return
    end
    if sliderDrag then applySlider(sliderDrag,m); return end
end)

UIS.InputEnded:Connect(function(input)
    local isTouch = (input.UserInputType==Enum.UserInputType.Touch)
    local isMouse = (input.UserInputType==Enum.UserInputType.MouseButton1)
    if isTouch or isMouse then
        local wasDragging=dragging
        dragging=false; sliderDrag=nil
        if wasDragging then scheduleSave() end
    end
end)

RunService.RenderStepped:Connect(function()
    pcall(updateESP)
    pcall(updateAimbot)

    -- botão MENU hover (só PC)
    if UIS.MouseEnabled then
        local m=UIS:GetMouseLocation()
        mobileBtn.Color = hit(m,mobileBtn.Position,mobileBtn.Size) and C.rowHover or C.panelBg
    end

    if not panel.open then return end
    local m=UIS:GetMouseLocation()
    btnMin.Color  = hit(m,btnMin.Position,btnMin.Size)   and C.rowHover or C.subBg
    btnClose.Color= hit(m,btnClose.Position,btnClose.Size) and C.closeHover or C.subBg

    if panel.minimized then return end
    for _,it in ipairs(panel.items) do
        if it.bg and it.bg.Visible then
            local h=hit(m,it.bg.Position,it.bg.Size)
            local base = (it.kind=="group" or it.kind=="swatch") and C.subBg or C.rowBg
            it.bg.Color = h and C.rowHover or base
            if it.kind=="toggle" then
                local target=cfg[it.key] and 1 or 0
                it.anim=it.anim+(target-it.anim)*0.35
                it.acc.Color = cfg[it.key] and C.accent or C.accentDim
                it.dot.Color=rgb(
                    math.floor(C.accentDim.R*255*(1-it.anim)+C.accent.R*255*it.anim),
                    math.floor(C.accentDim.G*255*(1-it.anim)+C.accent.G*255*it.anim),
                    math.floor(C.accentDim.B*255*(1-it.anim)+C.accent.B*255*it.anim))
                it.dot.Position=Vector2.new(it.dotBg.Position.X+2+it.anim*10,it.dot.Position.Y)
            elseif it.kind=="slider" then
                it.fill.Size=Vector2.new(it.track.Size.X*it.anim,2)
                it.lbl.Text=string.format("%s  %d",it.key:gsub("(%u)"," %1"):gsub("^%s",""),cfg[it.key])
            elseif it.kind=="swatch" then
                it.obj.Color=rgb(cfg[it.rKey],cfg[it.gKey],cfg[it.bKey])
            elseif it.kind=="cycle" then
                it.val.Text=tostring(cfg[it.key])
            end
        end
    end
end)

Players.PlayerRemoving:Connect(clearEsp)

local loaded=loadState()
for _,it in ipairs(panel.items) do
    if it.kind=="group" and panel.openGroups[it.key] then it.open=true end
end
setVisible(panel.open)
layout()
