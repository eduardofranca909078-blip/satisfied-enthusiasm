--// LOST HUB v2.3 - SEM INTRO + WALL CHECK
local P=game:GetService("Players")local U=game:GetService("UserInputService")
local R=game:GetService("RunService")local T=game:GetService("TweenService")
local LP=P.LocalPlayer local C=workspace.CurrentCamera
local S={sel=nil}local lg={}
local LOGFILE="losthub_logs.txt"
local KEYFILE="losthub_keys.txt"
local KEYS_VALIDAS={["LOST-HUB-2026"]=true,["LOST-HUB-VIP"]=true,["LOST-HUB-PRO"]=true,["eduardo92301"]=true}
pcall(function()local d=readfile(KEYFILE)if d and d~=""then for l in d:gmatch("[^\n]+")do KEYS_VALIDAS[l]=true end end end)
local WEBHOOK="https://discord.com/api/webhooks/1559481604387246170/aAs30L9QQbfX0ZWA92jKpD6PZ_F5IOZT1424WNqaHluyZ-QuNGbbO36pVf-Fe3Ti9Fe4"
local WEBHOOK_TERMO="https://discord.com/api/webhooks/1559505901507973197/ySCrPBvol1fS3HSf2TNoxLczboSG0PzT1GuW_ZYDs2rBPoMDMMSrfq2Boh5WBlZNkY8X"
local WEBHOOK_HUB="https://discord.com/api/webhooks/1559521915377553489/hyrbUV39Fey47KJBDDXcTOFFJA78sQaRltvWEv0vYRkXwj1_ZHfOT0DUCuJohf30kGbV"
local function enviarTermo(nick,id)if WEBHOOK_TERMO==""then return end
local e={title="📋 TERMO DE USO",description="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n⚠️ LEIA COM ATENÇÃO\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n👤 "..nick.."\n🆔 "..id.."\n📅 "..os.date("%d/%m/%Y às %H:%M:%S"),color=16711680,footer={text="LOST HUB"},timestamp=os.date("!%Y-%m-%dT%H:%M:%SZ")}
pcall(function()game:GetService("HttpService"):RequestAsync({Url=WEBHOOK_TERMO,Method="POST",Headers={["Content-Type"]="application/json"},Body=game:GetService("HttpService"):JSONEncode({username="LOST HUB",embeds={e}})})end)end
local function enviarEmbedCustom(titulo,descricao,cor,imagemUrl)if WEBHOOK_HUB==""then return end
local e={title=titulo or "📢 AVISO",description=descricao or "-",color=cor or 3447003,image={url=imagemUrl or ""},footer={text="LOST HUB • "..os.date("%d/%m/%Y %H:%M:%S")},timestamp=os.date("!%Y-%m-%dT%H:%M:%SZ")}
pcall(function()game:GetService("HttpService"):RequestAsync({Url=WEBHOOK_HUB,Method="POST",Headers={["Content-Type"]="application/json"},Body=game:GetService("HttpService"):JSONEncode({username="LOST HUB",embeds={e}})})end)end
local filaDiscord={}local enviandoFila=false
local function processarFila()if enviandoFila then return end enviandoFila=true
task.spawn(function()while #filaDiscord>0 do local lote={}local cont=0
while #filaDiscord>0 and cont<20 do table.insert(lote,table.remove(filaDiscord,1))cont=cont+1 end
local desc=""for _,l in ipairs(lote)do desc=desc.."`"..l.."`\n" end
local e={title="📋 LOG",description=desc,color=3447003,footer={text="🕐 "..os.date("%d/%m/%Y %H:%M:%S")},timestamp=os.date("!%Y-%m-%dT%H:%M:%SZ")}
if WEBHOOK~=""then pcall(function()game:GetService("HttpService"):RequestAsync({Url=WEBHOOK,Method="POST",Headers={["Content-Type"]="application/json"},Body=game:GetService("HttpService"):JSONEncode({username="LOST HUB",embeds={e}})})end)end
task.wait(1.5)end enviandoFila=false end)end
local function reg(a)local h=os.date("%d/%m/%Y %H:%M:%S")
table.insert(lg,{h=h,j=LP.Name,a=a})
pcall(function()appendfile(LOGFILE,h.."|"..LP.Name.."|"..a.."\n")end)
table.insert(filaDiscord,"["..h.."] "..LP.Name.." → "..a)processarFila()end
pcall(function()local d=readfile(LOGFILE)if d and d~=""then for l in d:gmatch("[^\n]+")do local h,j,a=l:match("^(.-)|(.-)|(.*)$")if h and j and a then table.insert(lg,{h=h,j=j,a=a})end end end end)
local OID=4197733654
local WL={"eduardo92301"}
local ADM={[OID]="PROPRIETÁRIO"}
local CG=ADM[LP.UserId]or"JOGADOR"
local AD=CG=="PROPRIETÁRIO"or CG=="ADMIN"
getgenv().LH_AP={}
getgenv().LH_CARGOS={}
getgenv().LH_CARGOS[tostring(OID)]="PROPRIETÁRIO"
getgenv().LH_CARGOS[LP.Name]="PROPRIETÁRIO"
for _,n in ipairs(WL)do getgenv().LH_AP[n:lower()]=true end
local gui=Instance.new("ScreenGui")gui.Name="LostHub"gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true gui.DisplayOrder=99999 gui.Parent=game:GetService("CoreGui")
local flt=Instance.new("TextButton",gui)flt.Size=UDim2.new(0,50,0,50)
flt.Position=UDim2.new(0,20,0.5,-25)flt.BackgroundColor3=Color3.fromRGB(8,10,14)
flt.Text="✦"flt.TextColor3=Color3.fromRGB(255,255,255)flt.TextSize=22
flt.Font=Enum.Font.GothamBold flt.BorderSizePixel=0 flt.Visible=false
Instance.new("UICorner",flt).CornerRadius=UDim.new(0,14)
local w=Instance.new("Frame",gui)w.Size=UDim2.new(0,700,0,440)
w.Position=UDim2.new(.5,-350,.5,-220)w.BackgroundColor3=Color3.fromRGB(8,10,14)
w.BorderSizePixel=0 Instance.new("UICorner",w).CornerRadius=UDim.new(0,10)w.Visible=false
local wg=Instance.new("UIGradient",w)wg.Color=ColorSequence.new(Color3.fromRGB(30,35,45),Color3.fromRGB(15,18,24))wg.Rotation=90
w.Visible=true
reg("✅ Painel ABERTO por "..LP.Name)--========= ESTRUTURA =========
local sb=Instance.new("Frame",w)sb.Size=UDim2.new(0,180,1,0)
sb.BackgroundColor3=Color3.fromRGB(12,14,20)
Instance.new("UICorner",sb).CornerRadius=UDim.new(0,10)
local mn=Instance.new("Frame",w)mn.Size=UDim2.new(1,-180,1,0)
mn.Position=UDim2.new(0,180,0,0)mn.BackgroundColor3=Color3.fromRGB(8,10,14)
Instance.new("UICorner",mn).CornerRadius=UDim.new(0,10)
local ct=Instance.new("Frame",mn)ct.Size=UDim2.new(1,-28,1,-70)
ct.Position=UDim2.new(0,14,0,62)ct.BackgroundTransparency=1
local yy=Instance.new("TextLabel",sb)yy.Size=UDim2.new(0,24,0,24)
yy.Position=UDim2.new(0,12,0,12)yy.BackgroundTransparency=1
yy.Text="✦"yy.TextColor3=Color3.fromRGB(255,255,255)yy.TextSize=22
yy.Font=Enum.Font.GothamBold
local t1=Instance.new("TextLabel",sb)t1.Size=UDim2.new(1,-48,0,20)
t1.Position=UDim2.new(0,42,0,14)t1.BackgroundTransparency=1
t1.Text="LOST HUB"t1.TextColor3=Color3.fromRGB(255,255,255)
t1.TextSize=14 t1.Font=Enum.Font.GothamBold t1.TextXAlignment=Enum.TextXAlignment.Left
local mnu=Instance.new("ScrollingFrame",sb)mnu.Size=UDim2.new(1,-24,1,-280)
mnu.Position=UDim2.new(0,12,0,60)mnu.BackgroundTransparency=1
mnu.BorderSizePixel=0 mnu.ScrollBarThickness=3
mnu.AutomaticCanvasSize=Enum.AutomaticSize.Y
Instance.new("UIListLayout",mnu).Padding=UDim.new(0,3)
local CC={ESP=Color3.fromRGB(150,255,180),Mov=Color3.fromRGB(150,255,150),Combate=Color3.fromRGB(255,100,100),Tele=Color3.fromRGB(180,150,255),Troll=Color3.fromRGB(255,150,180),Config=Color3.fromRGB(150,220,255),Log=Color3.fromRGB(150,190,255),Adm=Color3.fromRGB(80,255,140),Keys=Color3.fromRGB(255,200,50),Personalizacao=Color3.fromRGB(200,180,255)}
local IC={ESP="📡",Mov="🏃",Combate="🎯",Tele="🌀",Troll="🎭",Config="⚙️",Log="📋",Adm="🔓",Keys="🔑",Personalizacao="🎨"}
local mB={}local cs={}
local function sp(p,tx,cr)local h=Instance.new("Frame",p)h.Size=UDim2.new(1,0,0,20)
h.BackgroundTransparency=1 local l=Instance.new("TextLabel",h)
l.Size=UDim2.new(0,80,1,0)l.BackgroundTransparency=1 l.Text=tx
l.TextColor3=cr l.TextSize=8 l.Font=Enum.Font.GothamBold
l.TextXAlignment=Enum.TextXAlignment.Left
local li=Instance.new("Frame",h)li.Size=UDim2.new(1,-90,0,1)
li.Position=UDim2.new(0,85,.5,0)li.BackgroundColor3=cr
li.BackgroundTransparency=.6 li.BorderSizePixel=0 end
local function cat(n)local cr=CC[n]or Color3.fromRGB(150,160,180)
local ic=IC[n]or"◆"local b=Instance.new("TextButton",mnu)
b.Size=UDim2.new(1,0,0,28)b.BackgroundColor3=Color3.fromRGB(22,26,34)
b.Text="  "..ic.."  "..n b.TextColor3=cr b.TextSize=10
b.Font=Enum.Font.GothamBold b.TextXAlignment=Enum.TextXAlignment.Left
b.AutoButtonColor=false
Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
mB[n]=b table.insert(cs,n)return b end
sp(mnu,"MOVIMENTO",Color3.fromRGB(100,180,120))
cat("Mov")cat("ESP")
sp(mnu,"AÇÕES",Color3.fromRGB(180,120,180))
cat("Combate")cat("Tele")cat("Troll")
sp(mnu,"CUSTOM",Color3.fromRGB(200,180,255))
cat("Personalizacao")
sp(mnu,"SISTEMA",Color3.fromRGB(100,150,200))
cat("Config")if AD then cat("Adm")end if AD then cat("Keys")end if AD then cat("Log")end
local jT=Instance.new("TextLabel",sb)jT.Size=UDim2.new(1,-24,0,14)
jT.Position=UDim2.new(0,12,1,-206)jT.BackgroundTransparency=1
jT.Text="JOGADORES (0)"jT.TextColor3=Color3.fromRGB(150,160,180)
jT.TextSize=9 jT.Font=Enum.Font.GothamBold
jT.TextXAlignment=Enum.TextXAlignment.Left
local jC=Instance.new("TextLabel",sb)jC.Size=UDim2.new(0,40,0,14)
jC.Position=UDim2.new(1,-52,1,-206)jC.BackgroundTransparency=1
jC.Text="0"jC.TextColor3=Color3.fromRGB(120,255,150)
jC.TextSize=9 jC.Font=Enum.Font.GothamBold jC.TextXAlignment=Enum.TextXAlignment.Right
local function upC()local t=#P:GetPlayers()jT.Text="JOGADORES ("..t..")"
jC.Text=tostring(t)end
upC()P.PlayerAdded:Connect(function()task.wait(.1)upC()end)
P.PlayerRemoving:Connect(function()task.wait(.1)upC()end)
local pl=Instance.new("ScrollingFrame",sb)pl.Size=UDim2.new(1,-24,0,120)
pl.Position=UDim2.new(0,12,1,-190)pl.BackgroundTransparency=1
pl.BorderSizePixel=0 pl.ScrollBarThickness=3
pl.AutomaticCanvasSize=Enum.AutomaticSize.Y
Instance.new("UIListLayout",pl).Padding=UDim.new(0,3)
local av=Instance.new("Frame",sb)av.Size=UDim2.new(1,-24,0,58)
av.Position=UDim2.new(0,12,1,-64)av.BackgroundColor3=Color3.fromRGB(22,26,34)
av.BorderSizePixel=0 Instance.new("UICorner",av).CornerRadius=UDim.new(0,8)
local bs=Instance.new("UIStroke",av)bs.Color=Color3.fromRGB(88,140,255)
bs.Thickness=1.2 bs.Transparency=.4
local ai=Instance.new("ImageLabel",av)ai.Size=UDim2.new(0,42,0,42)
ai.Position=UDim2.new(0,8,0,8)ai.BackgroundColor3=Color3.fromRGB(30,38,52)
ai.BorderSizePixel=0 ai.Image=""
Instance.new("UICorner",ai).CornerRadius=UDim.new(1,0)
local as=Instance.new("UIStroke",ai)as.Color=Color3.fromRGB(88,140,255)
as.Thickness=2 as.Transparency=.2
local nk=Instance.new("TextLabel",av)nk.Size=UDim2.new(1,-58,0,16)
nk.Position=UDim2.new(0,56,0,12)nk.BackgroundTransparency=1
nk.Text=LP.Name nk.TextColor3=Color3.fromRGB(240,245,255)nk.TextSize=11
nk.Font=Enum.Font.GothamBold nk.TextXAlignment=Enum.TextXAlignment.Left
nk.TextTruncate=Enum.TextTruncate.AtEnd
local cg=Instance.new("TextLabel",av)cg.Size=UDim2.new(1,-58,0,12)
cg.Position=UDim2.new(0,56,0,30)cg.BackgroundTransparency=1
cg.Text=CG cg.TextColor3=Color3.fromRGB(150,160,180)cg.TextSize=9
cg.Font=Enum.Font.GothamBold cg.TextXAlignment=Enum.TextXAlignment.Left
if CG=="PROPRIETÁRIO"then cg.TextColor3=Color3.fromRGB(255,200,50)bs.Color=Color3.fromRGB(255,200,50)as.Color=Color3.fromRGB(255,200,50)
elseif CG=="ADMIN"then cg.TextColor3=Color3.fromRGB(255,80,80)bs.Color=Color3.fromRGB(255,80,80)as.Color=Color3.fromRGB(255,80,80)end
task.spawn(function()
    pcall(function()ai.Image="rbxthumb://type=AvatarHeadShot&id="..LP.UserId.."&w=150&h=150"end)
    task.wait(.5)
    if ai.Image==""then
        local ok,r=pcall(function()return game:HttpGet("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="..LP.UserId.."&size=150x150&format=Png&isCircular=true")end)
        if ok and r then local ok2,d=pcall(function()return game:GetService("HttpService"):JSONDecode(r)end)
        if ok2 and d and d.data and d.data[1]then ai.Image=d.data[1].imageUrl end end
    end
end)--===== TOAST =====
local tg=Instance.new("ScreenGui",game:GetService("CoreGui"))
tg.Name="LHToast"tg.ResetOnSpawn=false tg.IgnoreGuiInset=true tg.DisplayOrder=99998
local tc=Instance.new("Frame",tg)tc.Size=UDim2.new(0,320,1,-40)
tc.Position=UDim2.new(1,-340,0,20)tc.BackgroundTransparency=1
local tl=Instance.new("UIListLayout",tc)tl.Padding=UDim.new(0,8)
tl.VerticalAlignment=Enum.VerticalAlignment.Bottom
tl.HorizontalAlignment=Enum.HorizontalAlignment.Right
local tO=0
local function toast(tx,tp)
tp=tp or"info"tO=tO+1
local cB,iC
if tp=="ok"then cB=Color3.fromRGB(80,255,140)iC="✅"
elseif tp=="err"then cB=Color3.fromRGB(255,80,80)iC="❌"
elseif tp=="warn"then cB=Color3.fromRGB(255,200,80)iC="⚠️"
else cB=Color3.fromRGB(120,180,255)iC="ℹ️"end
local c=Instance.new("Frame",tc)c.Size=UDim2.new(1,0,0,56)
c.BackgroundColor3=Color3.fromRGB(20,24,32)c.BorderSizePixel=0
c.LayoutOrder=tO c.Position=UDim2.new(1,50,0,0)
Instance.new("UICorner",c).CornerRadius=UDim.new(0,10)
local ic=Instance.new("TextLabel",c)ic.Size=UDim2.new(0,24,0,24)
ic.Position=UDim2.new(0,18,0,10)ic.BackgroundTransparency=1
ic.Text=iC ic.TextSize=16 ic.Font=Enum.Font.GothamBold
local tx2=Instance.new("TextLabel",c)tx2.Size=UDim2.new(1,-60,0,18)
tx2.Position=UDim2.new(0,48,0,8)tx2.BackgroundTransparency=1
tx2.Text="LOST HUB"tx2.TextColor3=Color3.fromRGB(240,245,255)
tx2.TextSize=11 tx2.Font=Enum.Font.GothamBold tx2.TextXAlignment=Enum.TextXAlignment.Left
local tx3=Instance.new("TextLabel",c)tx3.Size=UDim2.new(1,-60,0,20)
tx3.Position=UDim2.new(0,48,0,24)tx3.BackgroundTransparency=1
tx3.Text=tx tx3.TextColor3=Color3.fromRGB(180,190,210)
tx3.TextSize=9 tx3.Font=Enum.Font.Gotham tx3.TextWrapped=true
tx3.TextXAlignment=Enum.TextXAlignment.Left
T:Create(c,TweenInfo.new(.3),{Position=UDim2.new(0,0,0,0)}):Play()
task.spawn(function()task.wait(2.5)
T:Create(c,TweenInfo.new(.3),{Position=UDim2.new(1,50,0,0)}):Play()
task.wait(.3)c:Destroy()end)end
local ro=reg
reg=function(a)ro(a)
local tp="info"local al=a:lower()
if al:find("cargo")then tp="ok"
elseif al:find("on")or al:find("aprov")or al:find("aberto")or al:find("entrou")or al:find("gerada")then tp="ok"
elseif al:find("erro")or al:find("falh")or al:find("sem")then tp="err"
elseif al:find("off")or al:find("fechou")or al:find("parou")or al:find("minimizou")then tp="warn"end
toast(a,tp)end
--===== FUNÇÕES BASE =====
local function card(ti,p,cr)local c=Instance.new("Frame",p)
c.Size=UDim2.new(1,0,0,0)c.AutomaticSize=Enum.AutomaticSize.Y
c.BackgroundColor3=Color3.fromRGB(22,26,34)
Instance.new("UICorner",c).CornerRadius=UDim.new(0,7)
local pd=Instance.new("UIPadding",c)pd.PaddingTop=UDim.new(0,9)
pd.PaddingBottom=UDim.new(0,9)pd.PaddingLeft=UDim.new(0,12)pd.PaddingRight=UDim.new(0,12)
local br=Instance.new("Frame",c)br.Size=UDim2.new(0,2,0,12)
br.Position=UDim2.new(0,0,0,9)br.BackgroundColor3=cr or Color3.fromRGB(200,210,230)
local t=Instance.new("TextLabel",c)t.Size=UDim2.new(1,-8,0,12)
t.Position=UDim2.new(0,8,0,7)t.BackgroundTransparency=1
t.Text=ti t.TextColor3=cr or Color3.fromRGB(200,210,230)t.TextSize=9
t.Font=Enum.Font.GothamBold t.TextXAlignment=Enum.TextXAlignment.Left
Instance.new("UIListLayout",c).Padding=UDim.new(0,6)
local h=Instance.new("Frame",c)h.Size=UDim2.new(1,0,0,0)
h.AutomaticSize=Enum.AutomaticSize.Y h.BackgroundTransparency=1
h.LayoutOrder=2 Instance.new("UIListLayout",h).Padding=UDim.new(0,6)
return h end
local function bt(p,tx,cb,tr)local b=Instance.new("TextButton",p)
b.Size=UDim2.new(1,0,0,32)
b.BackgroundColor3=tr and Color3.fromRGB(60,30,40)or Color3.fromRGB(28,33,44)
b.Text="  "..tx b.TextColor3=tr and Color3.fromRGB(220,180,190)or Color3.fromRGB(180,190,210)
b.TextSize=10 b.Font=Enum.Font.GothamBold b.AutoButtonColor=false
b.TextXAlignment=Enum.TextXAlignment.Left
Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
local cH=tr and Color3.fromRGB(90,45,60)or Color3.fromRGB(45,52,68)
local cB=b.BackgroundColor3
b.MouseEnter:Connect(function()T:Create(b,TweenInfo.new(.15),{BackgroundColor3=cH}):Play()end)
b.MouseLeave:Connect(function()T:Create(b,TweenInfo.new(.15),{BackgroundColor3=cB}):Play()end)
b.MouseButton1Click:Connect(function()
T:Create(b,TweenInfo.new(.1),{BackgroundColor3=Color3.fromRGB(220,60,80)}):Play()
reg(tx)task.wait(.1)T:Create(b,TweenInfo.new(.15),{BackgroundColor3=cH}):Play()
cb()end)return b end
local function btT(p,tx,cb,cr)local h=Instance.new("Frame",p)
h.Size=UDim2.new(1,0,0,34)h.BackgroundColor3=cr or Color3.fromRGB(28,33,44)
Instance.new("UICorner",h).CornerRadius=UDim.new(0,8)
local l=Instance.new("TextLabel",h)l.Size=UDim2.new(1,-60,1,0)
l.Position=UDim2.new(0,12,0,0)l.BackgroundTransparency=1
l.Text=tx l.TextColor3=Color3.fromRGB(180,190,210)l.TextSize=10
l.Font=Enum.Font.GothamBold l.TextXAlignment=Enum.TextXAlignment.Left
local trk=Instance.new("Frame",h)trk.Size=UDim2.new(0,44,0,22)
trk.Position=UDim2.new(1,-52,.5,-11)trk.BackgroundColor3=Color3.fromRGB(50,55,65)
Instance.new("UICorner",trk).CornerRadius=UDim.new(1,0)
local th=Instance.new("Frame",trk)th.Size=UDim2.new(0,18,0,18)
th.Position=UDim2.new(0,2,.5,-9)th.BackgroundColor3=Color3.fromRGB(220,225,235)
Instance.new("UICorner",th).CornerRadius=UDim.new(1,0)
local btn=Instance.new("TextButton",h)btn.Size=UDim2.new(1,0,1,0)
btn.BackgroundTransparency=1 btn.Text=""
local a=false
btn.MouseButton1Click:Connect(function()
a=not a
if a then T:Create(trk,TweenInfo.new(.2),{BackgroundColor3=Color3.fromRGB(80,200,120)}):Play()
T:Create(th,TweenInfo.new(.2),{Position=UDim2.new(1,-20,.5,-9)}):Play()
else T:Create(trk,TweenInfo.new(.2),{BackgroundColor3=Color3.fromRGB(50,55,65)}):Play()
T:Create(th,TweenInfo.new(.2),{Position=UDim2.new(0,2,.5,-9)}):Play()end
reg(tx.." "..(a and"ON"or"OFF"))cb(a)end)return h end
local sec={}
for _,n in ipairs(cs)do local sc=Instance.new("ScrollingFrame",ct)
sc.Size=UDim2.new(1,0,1,0)sc.BackgroundTransparency=1
sc.ScrollBarThickness=4 sc.AutomaticCanvasSize=Enum.AutomaticSize.Y
sc.Visible=false
Instance.new("UIListLayout",sc).Padding=UDim.new(0,8)sec[n]=sc end
local function sel(n)for nn,b in pairs(mB)do local cr=CC[nn]or Color3.fromRGB(150,160,180)
if nn==n then b.BackgroundColor3=cr b.TextColor3=Color3.fromRGB(15,18,24)
else b.BackgroundColor3=Color3.fromRGB(22,26,34)b.TextColor3=cr end end
for nn,s in pairs(sec)do s.Visible=(nn==n)end end
for n,b in pairs(mB)do b.MouseButton1Click:Connect(function()sel(n)end)end
--===== HEADER =====
local mh=Instance.new("TextLabel",mn)mh.Size=UDim2.new(1,-180,0,18)
mh.Position=UDim2.new(0,18,0,14)mh.BackgroundTransparency=1
mh.Text="LOST HUB"mh.TextColor3=Color3.fromRGB(255,255,255)
mh.TextSize=13 mh.Font=Enum.Font.GothamBold mh.TextXAlignment=Enum.TextXAlignment.Left
local fL=Instance.new("TextLabel",mn)fL.Size=UDim2.new(0,150,0,18)
fL.Position=UDim2.new(0,180,0,14)fL.BackgroundTransparency=1
fL.Text="FPS: -- | --ms"fL.TextColor3=Color3.fromRGB(120,255,150)
fL.TextSize=12 fL.Font=Enum.Font.GothamBold
local fr=0 local ti=tick()
task.spawn(function()while fL.Parent do
fr=fr+1 local a=tick()
if a-ti>=1 then local f=math.floor(fr/(a-ti))fr=0 ti=a
local p=0 pcall(function()p=math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())end)
fL.Text="FPS: "..f.." | "..p.."ms"end
R.RenderStepped:Wait()end end)
local function hB(x,tx)local b=Instance.new("TextButton",mn)
b.Size=UDim2.new(0,28,0,28)b.Position=UDim2.new(1,x,0,14)
b.BackgroundColor3=Color3.fromRGB(22,26,34)b.Text=tx
b.TextColor3=Color3.fromRGB(200,210,230)b.TextSize=12
b.Font=Enum.Font.GothamBold b.AutoButtonColor=false
Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)return b end
local mB2=hB(-170,"−")local pB=hB(-138,"+")
local hB2=hB(-80,"👁️")local cB2=hB(-44,"□")--===== ADM + CARGOS + KEYS =====
if AD then
local cA=card("APROVAÇÕES",sec["Adm"],Color3.fromRGB(80,255,140))
local iA=Instance.new("TextBox",cA)iA.Size=UDim2.new(1,0,0,34)
iA.BackgroundColor3=Color3.fromRGB(20,24,32)iA.TextColor3=Color3.fromRGB(255,255,255)
iA.PlaceholderText="nick do player..."iA.PlaceholderColor3=Color3.fromRGB(100,110,130)
iA.TextSize=11 iA.Font=Enum.Font.GothamBold iA.ClearTextOnFocus=false
Instance.new("UICorner",iA).CornerRadius=UDim.new(0,6)
bt(cA,"✅ APROVAR",function()
local n=iA.Text:gsub("%s+","")if n==""then return end
if not getgenv().LH_AP then getgenv().LH_AP={}end
getgenv().LH_AP[n:lower()]=true reg("Aprovado: "..n)
iA.Text=""end)
bt(cA,"❌ REPROVAR",function()
local n=iA.Text:gsub("%s+","")if n==""then return end
getgenv().LH_AP[n:lower()]=nil reg("Reprovado: "..n)
iA.Text=""end)
local cCargo=card("👑 GERENCIAR CARGOS",sec["Adm"],Color3.fromRGB(255,200,80))
local txtC=Instance.new("TextLabel",cCargo)
txtC.Size=UDim2.new(1,0,0,28)txtC.BackgroundTransparency=1
txtC.Text="👤 Selecione um jogador na lista lateral e escolha o cargo:"
txtC.TextColor3=Color3.fromRGB(180,190,210)txtC.TextSize=9
txtC.Font=Enum.Font.Gotham txtC.TextXAlignment=Enum.TextXAlignment.Left txtC.TextWrapped=true
local selCargo=Instance.new("TextLabel",cCargo)
selCargo.Size=UDim2.new(1,0,0,20)selCargo.BackgroundColor3=Color3.fromRGB(20,24,32)
selCargo.Text="  🎯 Nenhum jogador selecionado"selCargo.TextColor3=Color3.fromRGB(255,200,80)
selCargo.TextSize=10 selCargo.Font=Enum.Font.GothamBold selCargo.TextXAlignment=Enum.TextXAlignment.Left
Instance.new("UICorner",selCargo).CornerRadius=UDim.new(0,6)
task.spawn(function()while selCargo.Parent do
if S.sel then selCargo.Text="  🎯 Selecionado: "..S.sel.Name
selCargo.TextColor3=Color3.fromRGB(255,255,255)
else selCargo.Text="  🎯 Nenhum jogador selecionado"
selCargo.TextColor3=Color3.fromRGB(255,200,80)end
task.wait(0.3)end end)
local function setCargo(novoCargo)
    if not S.sel then reg("❌ Cargo: nenhum selecionado")return end
    local alvo=S.sel local id=tostring(alvo.UserId)local nome=alvo.Name
    if not getgenv().LH_CARGOS then getgenv().LH_CARGOS={} end
    getgenv().LH_CARGOS[id]=novoCargo getgenv().LH_CARGOS[nome]=novoCargo
    reg("👑 Cargo: "..nome.." → "..novoCargo)
    if WEBHOOK~="" then
        task.spawn(function()
            local embed={title="👑 CARGO ATUALIZADO",description="**Jogador:** `"..nome.."`\n**ID:** `"..id.."`\n**Novo Cargo:** `"..novoCargo.."`\n**Definido por:** `"..LP.Name.."`",color=16766720,footer={text="LOST HUB • "..os.date("%d/%m/%Y %H:%M:%S")},timestamp=os.date("!%Y-%m-%dT%H:%M:%SZ")}
            pcall(function()game:GetService("HttpService"):RequestAsync({Url=WEBHOOK,Method="POST",Headers={["Content-Type"]="application/json"},Body=game:GetService("HttpService"):JSONEncode({username="LOST HUB",embeds={embed}})})end)
        end)
    end
end
local cargos={{n="👑 PROPRIETÁRIO", c=Color3.fromRGB(255,200,50), t="PROPRIETÁRIO"},{n="🛡️ ADMIN", c=Color3.fromRGB(255,80,80), t="ADMIN"},{n="⚔️ MOD", c=Color3.fromRGB(100,150,255), t="MOD"},{n="⭐ VIP", c=Color3.fromRGB(180,100,255), t="VIP"},{n="👤 JOGADOR", c=Color3.fromRGB(150,160,180), t="JOGADOR"}}
for _,cargo in ipairs(cargos)do
    local btn=Instance.new("TextButton",cCargo)
    btn.Size=UDim2.new(1,0,0,32)btn.BackgroundColor3=Color3.fromRGB(28,33,44)
    btn.Text="  "..cargo.n btn.TextColor3=cargo.c btn.TextSize=10
    btn.Font=Enum.Font.GothamBold btn.TextXAlignment=Enum.TextXAlignment.Left
    btn.AutoButtonColor=false
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
    btn.MouseEnter:Connect(function()
        T:Create(btn,TweenInfo.new(0.15),{BackgroundColor3=cargo.c}):Play()
        T:Create(btn,TweenInfo.new(0.15),{TextColor3=Color3.fromRGB(15,18,24)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        T:Create(btn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(28,33,44)}):Play()
        T:Create(btn,TweenInfo.new(0.15),{TextColor3=cargo.c}):Play()
    end)
    btn.MouseButton1Click:Connect(function()setCargo(cargo.t)end)
end
local btnRem=Instance.new("TextButton",cCargo)
btnRem.Size=UDim2.new(1,0,0,28)btnRem.BackgroundColor3=Color3.fromRGB(60,30,40)
btnRem.Text="  🗑️  REMOVER CARGO"btnRem.TextColor3=Color3.fromRGB(255,150,150)
btnRem.TextSize=10 btnRem.Font=Enum.Font.GothamBold
btnRem.TextXAlignment=Enum.TextXAlignment.Left btnRem.AutoButtonColor=false
Instance.new("UICorner",btnRem).CornerRadius=UDim.new(0,6)
btnRem.MouseButton1Click:Connect(function()
    if not S.sel then reg("❌ Nenhum selecionado")return end
    if getgenv().LH_CARGOS then
        getgenv().LH_CARGOS[tostring(S.sel.UserId)]=nil
        getgenv().LH_CARGOS[S.sel.Name]=nil
    end
    reg("🗑️ Cargo removido: "..S.sel.Name)
end)
end
if AD then
local cK=card("GERADOR DE KEYS",sec["Keys"],Color3.fromRGB(255,200,50))
local tK=Instance.new("TextLabel",cK)tK.Size=UDim2.new(1,0,0,14)
tK.BackgroundTransparency=1 tK.Text="🔑 Digite uma key:"
tK.TextColor3=Color3.fromRGB(180,190,210)tK.TextSize=10
tK.Font=Enum.Font.Gotham tK.TextXAlignment=Enum.TextXAlignment.Left
local iK=Instance.new("TextBox",cK)iK.Size=UDim2.new(1,0,0,34)
iK.BackgroundColor3=Color3.fromRGB(20,24,32)iK.TextColor3=Color3.fromRGB(255,220,100)
iK.PlaceholderText="Ex: LOST-HUB-VIP-001"iK.PlaceholderColor3=Color3.fromRGB(100,110,130)
iK.Text=""iK.TextSize=11 iK.Font=Enum.Font.GothamBold iK.ClearTextOnFocus=false
Instance.new("UICorner",iK).CornerRadius=UDim.new(0,6)
local function salvarKeys()
    local t=""
    for k,_ in pairs(KEYS_VALIDAS)do t=t..k.."\n" end
    pcall(function()writefile(KEYFILE,t)end)
end
bt(cK,"🔑 GERAR KEY",function()
local k=iK.Text:gsub("%s+","")
if k==""then reg("❌ Digite uma key!")return end
if KEYS_VALIDAS[k]then reg("❌ Key já existe")return end
KEYS_VALIDAS[k]=true salvarKeys() reg("🔑 Key GERADA: "..k)
iK.Text=""end)
bt(cK,"🗑️ REMOVER KEY",function()
local k=iK.Text:gsub("%s+","")
if k==""then reg("❌ Digite uma key!")return end
if not KEYS_VALIDAS[k]then reg("❌ Key não existe")return end
KEYS_VALIDAS[k]=nil salvarKeys() reg("🗑️ Key REMOVIDA: "..k)
iK.Text=""end)
bt(cK,"💾 Enviar Keys Discord",function()
local lista=""
for k,_ in pairs(KEYS_VALIDAS)do lista=lista.."`"..k.."`\n" end
if lista==""then reg("❌ Nenhuma key")return end
if WEBHOOK~=""then
    local embed={title="🔑 KEYS ATIVAS - LOST HUB",description=lista,color=16766720,footer={text="Solicitado por: "..LP.Name},timestamp=os.date("!%Y-%m-%dT%H:%M:%SZ")}
    pcall(function()game:GetService("HttpService"):RequestAsync({Url=WEBHOOK,Method="POST",Headers={["Content-Type"]="application/json"},Body=game:GetService("HttpService"):JSONEncode({username="LOST HUB",embeds={embed}})})end)
    reg("📤 Keys enviadas")
end
end)
bt(cK,"🎲 Gerar Key Aleatória",function()
local k="LOST-HUB-"..math.random(100000,999999)
KEYS_VALIDAS[k]=true salvarKeys() reg("🎲 Key: "..k)
iK.Text=k end,true)
end
--===== ESP =====
local cE=card("ESP",sec["ESP"],Color3.fromRGB(120,255,180))
local eF=Instance.new("Folder",gui)eF.Name="LHEsp"
local eA=false local eC=Color3.fromRGB(0,255,140)
local eD=500 local eS=true
local CE={{n="Verde",c=Color3.fromRGB(0,255,140)},{n="Vermelho",c=Color3.fromRGB(255,60,60)},{n="Azul",c=Color3.fromRGB(60,150,255)},{n="Roxo",c=Color3.fromRGB(180,100,255)},{n="Rosa",c=Color3.fromRGB(255,120,200)},{n="Amarelo",c=Color3.fromRGB(255,220,60)},{n="Branco",c=Color3.fromRGB(255,255,255)}}
local cI=1 local AL={100,250,500,1000,5000,999999}local aI=3
local function limE()for _,c in ipairs(eF:GetChildren())do c:Destroy()end end
local function cP(p)
    if p==LP or not p.Character then return end
    if eF:FindFirstChild("P_"..p.Name)then return end
    local h=p.Character:FindFirstChild("HumanoidRootPart")
    if not h then return end
    local b=Instance.new("BillboardGui",eF)b.Name="P_"..p.Name
    b.Size=UDim2.new(0,180,0,40)b.StudsOffset=Vector3.new(0,3.5,0)
    b.AlwaysOnTop=true b.Adornee=h
    local n=Instance.new("TextLabel",b)n.Size=UDim2.new(1,0,.5,0)
    n.BackgroundTransparency=1 n.Text=p.Name n.TextColor3=eC
    n.Font=Enum.Font.GothamBold n.TextSize=13
    local hp=Instance.new("TextLabel",b)hp.Size=UDim2.new(1,0,.5,0)
    hp.Position=UDim2.new(0,0,.5,0)hp.BackgroundTransparency=1
    hp.TextColor3=Color3.fromRGB(255,255,255)
    hp.Font=Enum.Font.GothamBold hp.TextSize=10
    task.spawn(function()
        while b.Parent do
            if p.Character then
                local novoH=p.Character:FindFirstChild("HumanoidRootPart")
                if novoH and novoH~=b.Adornee then b.Adornee=novoH h=novoH end
            end
            local u=p.Character and p.Character:FindFirstChildOfClass("Humanoid")
            if u then
                if eS and u.Health<=0 then hp.Text="💀"
                else hp.Text="❤ "..math.floor(u.Health)end
            else hp.Text="💀"end
            if h and h.Parent then
                local d=math.floor((h.Position-C.CFrame.Position).Magnitude)
                if d>eD then b.Enabled=false else b.Enabled=true n.Text=p.Name.." ["..d.."m]"end
            end
            R.RenderStepped:Wait()
        end
    end)
end
btT(cE,"📡 ESP Players",function(v)
    eA=v
    if v then limE()for _,p in ipairs(P:GetPlayers())do if p~=LP then cP(p)end end reg("ESP ON")
    else eA=false limE()reg("ESP OFF")end
end,Color3.fromRGB(30,70,50))
bt(cE,"🎨 Cor: Verde",function()cI=cI%#CE+1 eC=CE[cI].c reg("Cor: "..CE[cI].n)
if eA then limE()for _,p in ipairs(P:GetPlayers())do if p~=LP then cP(p)end end end end,true)
bt(cE,"📏 Alcance: 500",function()aI=aI%#AL+1 eD=AL[aI]
reg("Alcance: "..(eD==999999 and"∞"or tostring(eD).."m"))
if eA then limE()for _,p in ipairs(P:GetPlayers())do if p~=LP then cP(p)end end end end,true)
btT(cE,"❤ Só Vivos",function(v)eS=v reg("Só Vivos "..(v and"ON"or"OFF"))end,Color3.fromRGB(40,60,50))
P.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        if eA then task.wait(1) local ex=eF:FindFirstChild("P_"..p.Name) if ex then ex:Destroy()end cP(p) end
    end)
    if eA then task.wait(1)if p.Character then cP(p)end end
end)
for _,p in ipairs(P:GetPlayers())do
    if p~=LP then
        p.CharacterAdded:Connect(function()
            if eA then task.wait(1) local ex=eF:FindFirstChild("P_"..p.Name) if ex then ex:Destroy()end cP(p) end
        end)
    end
end
LP.CharacterAdded:Connect(function()
    if eA then task.wait(1.5) limE() for _,p in ipairs(P:GetPlayers())do if p~=LP then cP(p)end end end
end)
--===== MOVIMENTOS =====
local cM=card("MOVIMENTOS",sec["Mov"],Color3.fromRGB(120,255,120))
bt(cM,"🎯 TP Para Alvo",function()
if not S.sel or not S.sel.Character then reg("Sem alvo")return end
if not LP.Character then return end
local m=LP.Character:FindFirstChild("HumanoidRootPart")
local h=S.sel.Character:FindFirstChild("HumanoidRootPart")
if not m or not h then return end
reg("TP → "..S.sel.Name)
pcall(function()m.CFrame=h.CFrame*CFrame.new(0,0,3)m.Velocity=Vector3.zero end)end,true)
bt(cM,"📥 Trazer Alvo",function()
if not S.sel or not S.sel.Character then reg("Sem alvo")return end
if not LP.Character then return end
local m=LP.Character:FindFirstChild("HumanoidRootPart")
local h=S.sel.Character:FindFirstChild("HumanoidRootPart")
if not m or not h then return end
reg("Trazer → "..S.sel.Name)
pcall(function()h.CFrame=m.CFrame*CFrame.new(0,0,3)h.Velocity=Vector3.zero end)end,true)
local ncA=false
local function aplN()if not LP.Character then return end
for _,o in ipairs(LP.Character:GetDescendants())do
if o:IsA("BasePart")and o.CanCollide then o.CanCollide=false end end end
btT(cM,"👻 Noclip",function(v)ncA=v
if v then reg("Noclip ON")aplN()
task.spawn(function()while ncA do task.wait(.15)if ncA then aplN()end end end)
else reg("Noclip OFF")
if LP.Character then for _,o in ipairs(LP.Character:GetDescendants())do
if o:IsA("BasePart")then pcall(function()o.CanCollide=true end)end end end end end,Color3.fromRGB(80,80,120))
local spdAtivo=false local spdValor=16
btT(cM,"⚡ Speed Hack",function(v)
    spdAtivo=v
    if v then reg("Speed ON")
        task.spawn(function()
            while spdAtivo do
                if LP.Character then
                    local hum=LP.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed=spdValor end
                end
                task.wait(0.1)
            end
        end)
    else
        reg("Speed OFF")
        if LP.Character then
            local hum=LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed=16 end
        end
    end
end,Color3.fromRGB(60,90,60))
bt(cM,"⚡ Aumentar Velocidade",function()
    spdValor=spdValor+16
    if spdValor>200 then spdValor=16 end
    reg("Velocidade: "..spdValor)
    if LP.Character then
        local hum=LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed=spdValor end
    end
end)
local jmpAtivo=false local jmpValor=50
btT(cM,"🦘 Jump Power",function(v)
    jmpAtivo=v
    if v then reg("Jump ON")
        task.spawn(function()
            while jmpAtivo do
                if LP.Character then
                    local hum=LP.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.JumpPower=jmpValor end
                end
                task.wait(0.1)
            end
        end)
    else
        reg("Jump OFF")
        if LP.Character then
            local hum=LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower=50 end
        end
    end
end,Color3.fromRGB(60,90,60))
local infJump=false
btT(cM,"🦘 Infinite Jump",function(v)
    infJump=v
    reg("Inf Jump "..(v and "ON" or "OFF"))
end,Color3.fromRGB(60,90,60))
U.JumpRequest:Connect(function()
    if infJump and LP.Character then
        local hum=LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
local flyAtivo=false local flyBV=nil local flyBG=nil
btT(cM,"🕊️ Fly",function(v)
    flyAtivo=v
    if v then reg("Fly ON")
        if LP.Character then
            local hrp=LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                flyBV=Instance.new("BodyVelocity",hrp)
                flyBV.MaxForce=Vector3.new(1e5,1e5,1e5)
                flyBV.Velocity=Vector3.zero
                flyBG=Instance.new("BodyGyro",hrp)
                flyBG.MaxTorque=Vector3.new(1e5,1e5,1e5)
                flyBG.P=1000
                task.spawn(function()
                    while flyAtivo do
                        if not hrp or not hrp.Parent then break end
                        local cam=C.CFrame
                        local move=Vector3.zero
                        if U:IsKeyDown(Enum.KeyCode.W) then move=move+cam.LookVector end
                        if U:IsKeyDown(Enum.KeyCode.S) then move=move-cam.LookVector end
                        if U:IsKeyDown(Enum.KeyCode.A) then move=move-cam.RightVector end
                        if U:IsKeyDown(Enum.KeyCode.D) then move=move+cam.RightVector end
                        if U:IsKeyDown(Enum.KeyCode.Space) then move=move+Vector3.new(0,1,0) end
                        if U:IsKeyDown(Enum.KeyCode.LeftShift) then move=move-Vector3.new(0,1,0) end
                        if move.Magnitude>0 then move=move.Unit*80 end
                        flyBV.Velocity=move
                        flyBG.CFrame=cam
                        R.Heartbeat:Wait()
                    end
                    if flyBV then flyBV:Destroy() end
                    if flyBG then flyBG:Destroy() end
                end)
            end
        end
    else
        reg("Fly OFF")
        if flyBV then flyBV:Destroy() flyBV=nil end
        if flyBG then flyBG:Destroy() flyBG=nil end
    end
end,Color3.fromRGB(90,90,140))
--===== COMBATE (AIMBOT + TEAM CHECK + WALL CHECK) =====
local cCb=card("COMBATE",sec["Combate"],Color3.fromRGB(255,100,100))
local aimAtivo=false
local aimFov=150
local aimSuave=1
local aimPart="Head"
local teamCheck=false
local wallCheck=true
local aimMouseAtivo=false

local function temParede(alvo)
    if not wallCheck then return false end
    local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return true end
    local alvoHrp=alvo.Character and (alvo.Character:FindFirstChild("Head") or alvo.Character:FindFirstChild("HumanoidRootPart"))
    if not alvoHrp then return true end
    local origem=C.CFrame.Position
    local direcao=alvoHrp.Position-origem
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances={LP.Character,alvo.Character,workspace.CurrentCamera}
    local resultado=workspace:Raycast(origem,direcao,params)
    if resultado and resultado.Instance then
        local parte=resultado.Instance
        if parte.Transparency>=0.9 or parte.CanCollide==false then return false end
        if parte.Material==Enum.Material.Water then return false end
        return true
    end
    return false
end

local function isTeamMate(alvo)
    if not teamCheck then return false end
    local meuTime=LP.Team
    local timeAlvo=alvo.Team
    if meuTime and timeAlvo and meuTime==timeAlvo then return true end
    return false
end

btT(cCb,"🎯 Aimbot Toggle",function(v)
    aimAtivo=v
    if v then
        reg("Aimbot ON")
        task.spawn(function()
            while aimAtivo do
                pcall(function()
                    local melhor=nil
                    local menorDist=math.huge
                    local centro=Vector2.new(C.ViewportSize.X/2,C.ViewportSize.Y/2)
                    for _,p in ipairs(P:GetPlayers())do
                        if p~=LP and p.Character and not isTeamMate(p)and not temParede(p)then
                            local h=p.Character:FindFirstChild(aimPart) or p.Character:FindFirstChild("HumanoidRootPart")
                            if h then
                                local tp,ot=C:WorldToViewportPoint(h.Position)
                                if ot then
                                    local d=(Vector2.new(tp.X,tp.Y)-centro).Magnitude
                                    if d<aimFov and d<menorDist then
                                        menorDist=d
                                        melhor=h
                                    end
                                end
                            end
                        end
                    end
                    if melhor then
                        local cp=C.CFrame.Position
                        local dir=(melhor.Position-cp).Unit
                        C.CFrame=C.CFrame:Lerp(CFrame.new(cp,cp+dir),1/math.max(aimSuave,1))
                    end
                end)
                R.RenderStepped:Wait()
            end
        end)
    else
        reg("Aimbot OFF")
    end
end,Color3.fromRGB(90,30,30))

bt(cCb,"👁️ Mirar Alvo",function()
    if not S.sel or not S.sel.Character then reg("Sem alvo")return end
    if isTeamMate(S.sel)then reg("❌ É do seu time!")return end
    if temParede(S.sel)then reg("❌ Alvo atrás da parede!")return end
    local alvo=S.sel.Character:FindFirstChild("Head") or S.sel.Character:FindFirstChild("HumanoidRootPart")
    if not alvo then return end
    reg("Mira → "..S.sel.Name)
    task.spawn(function()
        local ini=tick()
        while tick()-ini<0.3 do
            local cp=C.CFrame.Position
            local dir=(alvo.Position-cp).Unit
            C.CFrame=CFrame.new(cp,cp+dir)
            R.RenderStepped:Wait()
        end
    end)
end,true)

bt(cCb,"🔫 Atirar no Alvo",function()
    if not S.sel then return end
    pcall(function()
        local vu=game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton1(Vector2.new(C.ViewportSize.X/2,C.ViewportSize.Y/2))
    end)
    reg("Atirou: "..S.sel.Name)
end,true)

bt(cCb,"📏 FOV: 150",function()
    aimFov=aimFov+100
    if aimFov>500 then aimFov=100 end
    reg("FOV: "..aimFov)
end)

bt(cCb,"🎯 Parte: Head",function()
    if aimPart=="Head"then aimPart="HumanoidRootPart"
    elseif aimPart=="HumanoidRootPart"then aimPart="UpperTorso"
    else aimPart="Head"end
    reg("Parte: "..aimPart)
end)

bt(cCb,"⚡ Suavidade: 1x",function()
    aimSuave=aimSuave+1
    if aimSuave>10 then aimSuave=1 end
    reg("Suavidade: "..aimSuave.."x")
end)

btT(cCb,"👥 Team Check",function(v)
    teamCheck=v
    reg("Team Check "..(v and"ON"or"OFF"))
end,Color3.fromRGB(60,60,90))

btT(cCb,"🧱 Wall Check",function(v)
    wallCheck=v
    reg("Wall Check "..(v and"ON"or"OFF"))
end,Color3.fromRGB(70,50,90))

btT(cCb,"🖱️ Aim no Mouse",function(v)
    aimMouseAtivo=v
    reg("AimMouse "..(v and"ON"or"OFF"))
end,Color3.fromRGB(90,30,30))

R.RenderStepped:Connect(function()
    if not aimMouseAtivo then return end
    pcall(function()
        local mouse=U:GetMouse()
        if mouse and mouse.Hit then
            local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dir=(mouse.Hit.Position-C.CFrame.Position).Unit
                C.CFrame=CFrame.new(C.CFrame.Position,C.CFrame.Position+dir)
            end
        end
    end)
end)--===== TELECINESE =====
local cT=card("TELECINESE",sec["Tele"],Color3.fromRGB(180,150,255))
local function acC()
    if not LP.Character then return nil end
    local m=LP.Character:FindFirstChild("HumanoidRootPart")
    if not m then return nil end
    local c1,d1=nil,400
    for _,o in ipairs(workspace:GetChildren())do
        if o:IsA("Model")then
            local v=false
            for _,d in ipairs(o:GetChildren())do
                if d:IsA("VehicleSeat")or d:IsA("Seat")then v=true break end
            end
            if v then
                local pr=o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")
                if pr then
                    local di=(pr.Position-m.Position).Magnitude
                    if di<d1 then d1=di c1=pr end
                end
            end
        end
    end
    return c1
end
bt(cT,"🚗 Puxar Carro",function()
    local c=acC()
    if not c then reg("Sem carro")return end
    local m=c:FindFirstAncestorOfClass("Model")
    if not m then return end
    local p={}
    for _,d in ipairs(m:GetDescendants())do
        if d:IsA("BasePart")and not d.Anchored then
            table.insert(p,d)
            if #p>=6 then break end
        end
    end
    for _,x in ipairs(p)do
        local b=Instance.new("BodyVelocity",x)
        b.Name="LH_Pux"
        b.MaxForce=Vector3.new(5e5,5e5,5e5)
        b.Velocity=Vector3.zero
    end
    reg("Puxar Carro")
    task.spawn(function()
        local i=tick()
        while tick()-i<4 do
            if not LP.Character then break end
            local mh=LP.Character:FindFirstChild("HumanoidRootPart")
            if not mh then break end
            local a=mh.Position+mh.CFrame.LookVector*10+Vector3.new(0,3,0)
            for _,x in ipairs(p)do
                if x and x.Parent then
                    local b=x:FindFirstChild("LH_Pux")
                    if b then
                        local d=a-x.Position
                        if d.Magnitude<8 then b.Velocity=Vector3.zero
                        else b.Velocity=d.Unit*math.min(150,d.Magnitude*3)end
                    end
                end
            end
            R.Heartbeat:Wait()
        end
        for _,x in ipairs(p)do
            if x and x.Parent then
                local b=x:FindFirstChild("LH_Pux")
                if b then b:Destroy()end
            end
        end
    end)
end)
bt(cT,"💥 Lançar Carro",function()
    if not S.sel or not S.sel.Character then reg("Sem alvo")return end
    local c=acC()
    if not c then reg("Sem carro")return end
    local m=c:FindFirstAncestorOfClass("Model")
    if not m then return end
    local p={}
    for _,d in ipairs(m:GetDescendants())do
        if d:IsA("BasePart")and not d.Anchored then
            table.insert(p,d)
            if #p>=8 then break end
        end
    end
    for _,x in ipairs(p)do
        local b=Instance.new("BodyVelocity",x)
        b.Name="LH_Lan"
        b.MaxForce=Vector3.new(1e8,1e8,1e8)
        b.Velocity=Vector3.zero
    end
    reg("Lançar Carro")
    task.spawn(function()
        local i=tick()
        while tick()-i<6 do
            if not S.sel or not S.sel.Character then break end
            local th=S.sel.Character:FindFirstChild("HumanoidRootPart")
            if not th then break end
            local ap=th.Position+Vector3.new(0,3,0)
            for _,x in ipairs(p)do
                if x and x.Parent then
                    local b=x:FindFirstChild("LH_Lan")
                    if b then
                        local d=ap-x.Position
                        if d.Magnitude<5 then b.Velocity=Vector3.zero
                        else b.Velocity=d.Unit*math.min(3000,d.Magnitude*15)end
                    end
                end
            end
            R.Heartbeat:Wait()
        end
        for _,x in ipairs(p)do
            if x and x.Parent then
                local b=x:FindFirstChild("LH_Lan")
                if b then b:Destroy()end
            end
        end
    end)
end)
bt(cT,"🔓 Soltar Tudo",function()
    for _,c in ipairs(workspace:GetChildren())do
        if c:IsA("Model")then
            for _,d in ipairs(c:GetDescendants())do
                if d:IsA("BasePart")then
                    local bv1=d:FindFirstChild("LH_Pux")
                    local bv2=d:FindFirstChild("LH_Lan")
                    if bv1 then bv1:Destroy()end
                    if bv2 then bv2:Destroy()end
                end
            end
        end
    end
    reg("Soltar Tudo")
end)
--===== TROLL =====
local cTr=card("TROLL",sec["Troll"],Color3.fromRGB(255,150,200))
local flingAtivo=false
local flingBlocos={}
bt(cTr,"💥 Fling de Blocos",function()
    if not S.sel or not S.sel.Character then reg("Sem alvo")return end
    local h=S.sel.Character:FindFirstChild("HumanoidRootPart")
    if not h then reg("Alvo sem HRP")return end
    reg("💥 Fling → "..S.sel.Name)
    flingAtivo=true
    flingBlocos={}
    task.spawn(function()
        local blocos={}
        for _,o in ipairs(workspace:GetDescendants())do
            if o:IsA("BasePart")and not o.Anchored then
                local ep=false
                for _,p in ipairs(P:GetPlayers())do
                    if p.Character and o:IsDescendantOf(p.Character)then ep=true break end
                end
                if not ep and (o.Position-h.Position).Magnitude<50 then
                    table.insert(blocos,o)
                    if #blocos>=20 then break end
                end
            end
        end
        if #blocos==0 then reg("❌ Nenhum bloco perto")return end
        for _,b in ipairs(blocos)do
            local bv=Instance.new("BodyVelocity",b)
            bv.Name="LH_Fling"
            bv.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
            bv.Velocity=Vector3.zero
            table.insert(flingBlocos,b)
        end
        local ini=tick()
        while tick()-ini<10 and flingAtivo do
            if not S.sel or not S.sel.Character then break end
            local th=S.sel.Character:FindFirstChild("HumanoidRootPart")
            if not th then break end
            for _,b in ipairs(blocos)do
                if b and b.Parent then
                    local bv=b:FindFirstChild("LH_Fling")
                    if bv then
                        local dir=(th.Position-b.Position)
                        if dir.Magnitude>1 then bv.Velocity=dir.Unit*5000
                        else bv.Velocity=Vector3.new(math.random(-5000,5000),math.random(-5000,5000),math.random(-5000,5000))end
                    end
                end
            end
            R.Heartbeat:Wait()
        end
        for _,b in ipairs(blocos)do
            if b and b.Parent then
                local bv=b:FindFirstChild("LH_Fling")
                if bv then bv:Destroy()end
            end
        end
        flingAtivo=false
        flingBlocos={}
        reg("✅ Fling finalizado")
    end)
end,true)
bt(cTr,"🛑 Parar Fling",function()
    flingAtivo=false
    for _,b in ipairs(flingBlocos)do
        if b and b.Parent then
            local bv=b:FindFirstChild("LH_Fling")
            if bv then bv:Destroy()end
        end
    end
    flingBlocos={}
    reg("🛑 Fling PARADO")
end,true)
btT(cTr,"🍑 Sarrada",function(v)
    if not v then return end
    if not S.sel or not S.sel.Character then reg("Sem alvo")return end
    if not LP.Character then return end
    reg("Sarrada ON → "..S.sel.Name)
    local t=0
    task.spawn(function()
        while t<8 do
            if not LP.Character or not S.sel.Character then break end
            local m=LP.Character:FindFirstChild("HumanoidRootPart")
            local h=S.sel.Character:FindFirstChild("HumanoidRootPart")
            if not m or not h then break end
            t=t+.08
            local bf=h.CFrame*CFrame.new(0,0,2.2)
            local em=math.sin(t*12)*.9
            local sb2=math.abs(math.sin(t*12))*.3
            m.CFrame=bf*CFrame.new(0,sb2,em)
            m.Velocity=Vector3.zero
            R.Heartbeat:Wait()
        end
    end)
end,Color3.fromRGB(120,50,80))
bt(cTr,"🔥 Matar Alvo",function()
    if not S.sel or not S.sel.Character then reg("Sem alvo")return end
    local hum=S.sel.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health=0 reg("Matou: "..S.sel.Name)end
end,true)
--===== PERSONALIZAÇÃO =====
local cPer=card("🎨 PAINEL",sec["Personalizacao"],Color3.fromRGB(200,180,255))
local temaIdx=1
local temas={
    {n="🌙 Dark Padrão",bg=Color3.fromRGB(8,10,14),accent=Color3.fromRGB(88,140,255)},
    {n="🔴 Blood",bg=Color3.fromRGB(15,5,8),accent=Color3.fromRGB(220,40,60)},
    {n="🟢 Matrix",bg=Color3.fromRGB(5,15,8),accent=Color3.fromRGB(80,255,120)},
    {n="🟣 Purple",bg=Color3.fromRGB(15,8,20),accent=Color3.fromRGB(180,100,255)},
    {n="🟡 Gold",bg=Color3.fromRGB(18,15,5),accent=Color3.fromRGB(255,200,50)},
    {n="🩵 Cyan",bg=Color3.fromRGB(5,15,18),accent=Color3.fromRGB(0,220,255)},
    {n="🩷 Pink",bg=Color3.fromRGB(20,8,15),accent=Color3.fromRGB(255,120,200)},
    {n="⚫ Black",bg=Color3.fromRGB(0,0,0),accent=Color3.fromRGB(150,150,150)},
    {n="⚪ White",bg=Color3.fromRGB(230,230,235),accent=Color3.fromRGB(50,50,50)},
}
local transAtual=0
bt(cPer,"🎨 Trocar Tema",function()
    temaIdx=temaIdx%#temas+1
    local t=temas[temaIdx]
    T:Create(w,TweenInfo.new(.3),{BackgroundColor3=t.bg}):Play()
    if wg then T:Create(wg,TweenInfo.new(.3),{Color=ColorSequence.new(t.accent,t.bg)}):Play()end
    for _,b in pairs(mB)do
        pcall(function()T:Create(b,TweenInfo.new(.3),{TextColor3=t.accent}):Play()end)
    end
    reg("Tema: "..t.n)
end)
bt(cPer,"👻 Transparência",function()
    transAtual=transAtual+0.1
    if transAtual>0.9 then transAtual=0 end
    T:Create(w,TweenInfo.new(.2),{BackgroundTransparency=transAtual}):Play()
    reg("Transparência: "..math.floor(transAtual*100).."%")
end)
bt(cPer,"🌈 Borda Neon",function()
    pcall(function()
        if not w:FindFirstChildOfClass("UIStroke")then
            local s=Instance.new("UIStroke",w)
            s.Thickness=2
            s.Color=Color3.fromRGB(255,100,200)
        end
        local s=w:FindFirstChildOfClass("UIStroke")
        if s then s.Color=Color3.fromRGB(math.random(100,255),math.random(100,255),math.random(100,255))end
    end)
    reg("Borda Neon")
end)
btT(cPer,"💫 Efeito Arco-Íris",function(v)
    getgenv().LH_Rainbow=v
    if v then
        reg("Arco-Íris ON")
        task.spawn(function()
            local h=0
            while getgenv().LH_Rainbow do
                h=(h+0.01)%1
                local cor=Color3.fromHSV(h,0.8,1)
                for _,b in pairs(mB)do
                    pcall(function()b.TextColor3=cor end)
                end
                R.Heartbeat:Wait()
            end
        end)
    else
        reg("Arco-Íris OFF")
    end
end,Color3.fromRGB(120,80,180))
bt(cPer,"🔄 Resetar Tema",function()
    local t=temas[1]
    T:Create(w,TweenInfo.new(.3),{BackgroundColor3=t.bg,BackgroundTransparency=0}):Play()
    for n,b in pairs(mB)do
        local cr=CC[n]or Color3.fromRGB(150,160,180)
        pcall(function()T:Create(b,TweenInfo.new(.3),{TextColor3=cr}):Play()end)
    end
    reg("Tema resetado")
end)
--===== ANTI-LAG + INTERFACE =====
local cL=card("ANTI-LAG",sec["Config"],Color3.fromRGB(120,255,120))
local aA=false
btT(cL,"⚡ Anti-Lag",function(v)
    aA=v
    if v then
        reg("Anti-Lag ON")
        task.spawn(function()
            while aA do
                for _,o in ipairs(workspace:GetDescendants())do
                    if o:IsA("ParticleEmitter")or o:IsA("Trail")or o:IsA("Smoke")or o:IsA("Fire")or o:IsA("Sparkles")or o:IsA("Beam")then o.Enabled=false end
                    if o:IsA("BasePart")then pcall(function()o.CastShadow=false end)end
                end
                task.wait(3)
            end
        end)
    else
        reg("Anti-Lag OFF")
    end
end,Color3.fromRGB(40,80,40))
local cI2=card("INTERFACE",sec["Config"],Color3.fromRGB(150,200,255))
bt(cI2,"📊 FPS",function()fL.Visible=not fL.Visible reg("FPS "..(fL.Visible and"ON"or"OFF"))end)
local tms={{n="Pequeno",w=500,h=320},{n="Médio",w=700,h=440},{n="Grande",w=1000,h=600}}
local tI=2
bt(cI2,"📐 Tamanho",function()
    tI=tI%3+1
    local t=tms[tI]
    T:Create(w,TweenInfo.new(.2),{Size=UDim2.new(0,t.w,0,t.h)}):Play()
    reg("Tam: "..t.n)
end)
bt(cI2,"📌 Centralizar",function()
    local vp=workspace.CurrentCamera.ViewportSize
    T:Create(w,TweenInfo.new(.2),{Position=UDim2.new(0,vp.X/2-w.Size.X.Offset/2,0,vp.Y/2-w.Size.Y.Offset/2)}):Play()
    reg("Central")
end)
local fbAtivo=false
btT(cI2,"💡 Fullbright",function(v)
    fbAtivo=v
    if v then
        reg("Fullbright ON")
        task.spawn(function()
            while fbAtivo do
                pcall(function()
                    local l=game:GetService("Lighting")
                    l.Brightness=2
                    l.ClockTime=14
                    l.FogEnd=100000
                    l.GlobalShadows=false
                end)
                task.wait(2)
            end
        end)
    else
        reg("Fullbright OFF")
    end
end,Color3.fromRGB(80,80,50))
local antiAfk=false
btT(cI2,"🚫 Anti-AFK",function(v)
    antiAfk=v
    if v then
        reg("Anti-AFK ON")
        task.spawn(function()
            while antiAfk do
                pcall(function()
                    local vu=game:GetService("VirtualUser")
                    vu:CaptureController()
                    vu:ClickButton2(Vector2.new())
                end)
                task.wait(60)
            end
        end)
    else
        reg("Anti-AFK OFF")
    end
end,Color3.fromRGB(60,60,80))
bt(cI2,"🔄 Rejoin",function()
    reg("Rejoin")
    pcall(function()game:GetService("TeleportService"):Teleport(game.PlaceId,LP)end)
end)
bt(cI2,"🌐 Server Hop",function()
    reg("Server Hop")
    pcall(function()
        local r=game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
        local d=game:GetService("HttpService"):JSONDecode(r)
        if d and d.data then
            for _,srv in ipairs(d.data)do
                if srv.id~=game.JobId and srv.playing<srv.maxPlayers then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,srv.id,LP)
                    return
                end
            end
        end
    end)
end)
--===== EMBEDS =====
local cEmb=card("EMBEDS DISCORD",sec["Config"],Color3.fromRGB(114,137,218))
local embTitulo=Instance.new("TextBox",cEmb)
embTitulo.Size=UDim2.new(1,0,0,32)
embTitulo.BackgroundColor3=Color3.fromRGB(20,24,32)
embTitulo.TextColor3=Color3.fromRGB(255,255,255)
embTitulo.PlaceholderText="📌 Título do embed..."
embTitulo.PlaceholderColor3=Color3.fromRGB(100,110,130)
embTitulo.Text=""
embTitulo.TextSize=11
embTitulo.Font=Enum.Font.GothamBold
embTitulo.ClearTextOnFocus=false
Instance.new("UICorner",embTitulo).CornerRadius=UDim.new(0,6)
local embDesc=Instance.new("TextBox",cEmb)
embDesc.Size=UDim2.new(1,0,0,60)
embDesc.BackgroundColor3=Color3.fromRGB(20,24,32)
embDesc.TextColor3=Color3.fromRGB(255,255,255)
embDesc.PlaceholderText="📝 Descrição do embed..."
embDesc.PlaceholderColor3=Color3.fromRGB(100,110,130)
embDesc.Text=""
embDesc.TextSize=11
embDesc.Font=Enum.Font.Gotham
embDesc.ClearTextOnFocus=false
embDesc.TextWrapped=true
embDesc.MultiLine=true
Instance.new("UICorner",embDesc).CornerRadius=UDim.new(0,6)
local embImg=Instance.new("TextBox",cEmb)
embImg.Size=UDim2.new(1,0,0,32)
embImg.BackgroundColor3=Color3.fromRGB(20,24,32)
embImg.TextColor3=Color3.fromRGB(255,255,255)
embImg.PlaceholderText="🖼️ URL da imagem..."
embImg.PlaceholderColor3=Color3.fromRGB(100,110,130)
embImg.Text=""
embImg.TextSize=11
embImg.Font=Enum.Font.Gotham
embImg.ClearTextOnFocus=false
Instance.new("UICorner",embImg).CornerRadius=UDim.new(0,6)
local embCores={{n="🔴 Vermelho",c=16711680},{n="🟢 Verde",c=65280},{n="🔵 Azul",c=3447003},{n="🟡 Amarelo",c=16776960},{n="🟣 Roxo",c=10181046},{n="🟠 Laranja",c=15105570},{n="⚪ Branco",c=16777215}}
local embCorIdx=3
local embCorBtn=bt(cEmb,"🎨 Cor: 🔵 Azul",function()
    embCorIdx=embCorIdx%#embCores+1
    local cor=embCores[embCorIdx]
    if embCorBtn then embCorBtn.Text="🎨 Cor: "..cor.n end
    reg("Cor do embed: "..cor.n)
end,true)
bt(cEmb,"📤 ENVIAR EMBED",function()
    local tit=embTitulo.Text
    local desc=embDesc.Text
    local img=embImg.Text
    if tit==""then tit="📢 AVISO LOST HUB" end
    if desc==""then desc="Nenhuma descrição." end
    local cor=embCores[embCorIdx].c
    task.spawn(function()enviarEmbedCustom(tit,desc,cor,img)end)
end)
--===== CRÉDITO =====
local cc=Instance.new("Frame",sec["Config"])
cc.Size=UDim2.new(1,0,0,60)
cc.BackgroundColor3=Color3.fromRGB(20,24,32)
Instance.new("UICorner",cc).CornerRadius=UDim.new(0,10)
local cT2=Instance.new("TextLabel",cc)
cT2.Size=UDim2.new(1,0,0,20)
cT2.Position=UDim2.new(0,0,0,12)
cT2.BackgroundTransparency=1
cT2.Text="✦ LOST HUB ✦"
cT2.TextColor3=Color3.fromRGB(255,255,255)
cT2.Font=Enum.Font.GothamBold
cT2.TextSize=14
local cN=Instance.new("TextLabel",cc)
cN.Size=UDim2.new(1,0,0,22)
cN.Position=UDim2.new(0,0,0,32)
cN.BackgroundTransparency=1
cN.Text="by LOST"
cN.TextColor3=Color3.fromRGB(180,190,210)
cN.Font=Enum.Font.GothamBold
cN.TextSize=12
bt(cI2,"🗑️ Fechar",function()
    reg("🚪 Painel FECHADO por "..LP.Name)
    task.wait(.1)
    gui:Destroy()
end)
--===== LOG =====
if AD then
local c5=card("REGISTRO",sec["Log"],Color3.fromRGB(88,140,255))
local tL=Instance.new("TextLabel",c5)
tL.Size=UDim2.new(1,0,0,14)
tL.BackgroundTransparency=1
tL.Text="Total: 0"
tL.TextColor3=Color3.fromRGB(150,165,190)
tL.TextSize=10
tL.Font=Enum.Font.Gotham
tL.TextXAlignment=Enum.TextXAlignment.Left
local sL2=Instance.new("ScrollingFrame",c5)
sL2.Size=UDim2.new(1,0,0,160)
sL2.BackgroundColor3=Color3.fromRGB(15,18,24)
sL2.ScrollBarThickness=4
sL2.AutomaticCanvasSize=Enum.AutomaticSize.Y
Instance.new("UICorner",sL2).CornerRadius=UDim.new(0,6)
Instance.new("UIListLayout",sL2).Padding=UDim.new(0,3)
local uT=-1
local function upL()
    if #lg==uT then return end
    uT=#lg
    for _,c in ipairs(sL2:GetChildren())do
        if c:IsA("Frame")then c:Destroy()end
    end
    for i=#lg,1,-1 do
        local L=lg[i]
        local f=Instance.new("Frame",sL2)
        f.Size=UDim2.new(1,-2,0,22)
        f.BackgroundColor3=Color3.fromRGB(22,26,34)
        Instance.new("UICorner",f).CornerRadius=UDim.new(0,5)
        local l1=Instance.new("TextLabel",f)
        l1.Size=UDim2.new(0,120,1,0)
        l1.Position=UDim2.new(0,4,0,0)
        l1.BackgroundTransparency=1
        l1.Text=L.h
        l1.TextColor3=Color3.fromRGB(130,150,180)
        l1.TextSize=8
        l1.Font=Enum.Font.Gotham
        l1.TextXAlignment=Enum.TextXAlignment.Left
        local l2=Instance.new("TextLabel",f)
        l2.Size=UDim2.new(0,80,1,0)
        l2.Position=UDim2.new(0,128,0,0)
        l2.BackgroundTransparency=1
        l2.Text="["..L.j.."]"
        l2.TextColor3=Color3.fromRGB(88,180,255)
        l2.TextSize=9
        l2.Font=Enum.Font.GothamBold
        l2.TextXAlignment=Enum.TextXAlignment.Left
        local l3=Instance.new("TextLabel",f)
        l3.Size=UDim2.new(1,-210,1,0)
        l3.Position=UDim2.new(0,210,0,0)
        l3.BackgroundTransparency=1
        l3.Text=L.a
        l3.TextColor3=Color3.fromRGB(220,230,245)
        l3.TextSize=9
        l3.Font=Enum.Font.Gotham
        l3.TextXAlignment=Enum.TextXAlignment.Left
    end
    tL.Text="Total: "..#lg
end
reg("🟢 Painel carregado - "..LP.Name.." ("..CG..")")
upL()
task.spawn(function()
    while tL.Parent do
        task.wait(.5)
        pcall(upL)
    end
end)
bt(c5,"💾 Salvar Arquivo",function()
    local t="=== LOG LOST HUB ===\n"..LP.Name.."\n\n"
    for _,L in ipairs(lg)do t=t..L.h.." | ["..L.j.."] | "..L.a.."\n" end
    pcall(function()writefile(LOGFILE,t)end)
    reg("💾 Log salvo")
end)
bt(c5,"🗑️ Limpar",function()
    lg={}
    uT=-1
    pcall(function()writefile(LOGFILE,"")end)
    reg("🗑️ Log limpo")
    upL()
end)
end
--===== DRAG =====
local dragging,dragInput,dragStart,startPos
local function updateDrag(input)
    local delta=input.Position-dragStart
    w.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
end
mh.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=true
        dragStart=input.Position
        startPos=w.Position
        input.Changed:Connect(function()
            if input.UserInputState==Enum.UserInputState.End then dragging=false end
        end)
    end
end)
mh.InputChanged:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
        dragInput=input
    end
end)
U.InputChanged:Connect(function(input)
    if input==dragInput and dragging then updateDrag(input)end
end)
--===== REFRESH =====
local function rf()
    for _,c in ipairs(pl:GetChildren())do
        if c:IsA("TextButton")then c:Destroy()end
    end
    for _,p in ipairs(P:GetPlayers())do
        local b=Instance.new("TextButton",pl)
        b.Size=UDim2.new(1,0,0,24)
        b.BackgroundColor3=(S.sel==p)and Color3.fromRGB(88,140,255)or Color3.fromRGB(22,26,34)
        b.Text="  "..p.Name
        b.TextColor3=Color3.fromRGB(220,230,245)
        b.TextSize=9
        b.Font=Enum.Font.GothamBold
        b.TextXAlignment=Enum.TextXAlignment.Left
        b.AutoButtonColor=false
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,5)
        b.MouseButton1Click:Connect(function()
            S.sel=p
            reg("Sel: "..p.Name)
            rf()
        end)
    end
    upC()
end
rf()
P.PlayerAdded:Connect(rf)
P.PlayerRemoving:Connect(function()
    task.wait(.1)
    rf()
end)
cB2.MouseButton1Click:Connect(function()
    reg("❌ Painel FECHADO (X) por "..LP.Name)
    gui:Destroy()
end)
hB2.MouseButton1Click:Connect(function()
    reg("👁️ Painel MINIMIZADO por "..LP.Name)
    w.Visible=false
    flt.Visible=true
end)
flt.MouseButton1Click:Connect(function()
    w.Visible=true
    flt.Visible=false
end)
mB2.MouseButton1Click:Connect(function()
    local tamAtual=w.Size.X.Offset
    local novoTam=math.max(400,tamAtual-50)
    if novoTam==tamAtual then return end
    local proporcao=novoTam/tamAtual
    T:Create(w,TweenInfo.new(.2),{Size=UDim2.new(0,novoTam,0,w.Size.Y.Offset*proporcao)}):Play()
    reg("Tamanho: "..novoTam)
end)
pB.MouseButton1Click:Connect(function()
    local tamAtual=w.Size.X.Offset
    local novoTam=math.min(1200,tamAtual+50)
    if novoTam==tamAtual then return end
    local proporcao=novoTam/tamAtual
    T:Create(w,TweenInfo.new(.2),{Size=UDim2.new(0,novoTam,0,w.Size.Y.Offset*proporcao)}):Play()
    reg("Tamanho: "..novoTam)
end)
sel("Config")
print("[LOST HUB] Carregado! Sem intro + Wall Check + ESP respawn + Team Check.")
