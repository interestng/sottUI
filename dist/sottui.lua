local a={cache={}}do do local function __modImpl()local b={}local c=(getfenv)()
local d=c.cloneref or function(d)return d end local e={}function b.service(f)
local g=e[f]if g==nil then g=d((game):GetService(f))e[f]=g end return g end
function b.global(f)return c[f]end function b.guiParent()local f=c.gethui if
type(f)=='function'then local g,h=pcall(f)if g and h then return h end end local
g,h=pcall(b.service,'CoreGui')if g and h then local i=Instance.new('Folder')if
pcall(function()i.Parent=h end)then i:Destroy()return h end i:Destroy()end
return b.service('Players').LocalPlayer:WaitForChild('PlayerGui')end function b.
protect(f)local g=c.protectgui or(c.syn and c.syn.protect_gui)if type(g)==
'function'then pcall(g,f)end end function b.files()local f,g,h=c.readfile,c.
writefile,c.isfile if type(f)~='function'or type(g)~='function'or type(h)~=
'function'then return nil end local i,j,k=c.isfolder,c.makefolder,c.
getcustomasset return{read=function(l)local m,n=pcall(function()return if h(l)
then f(l)else nil end)return if m then n else nil end,write=function(l,m)return(
pcall(g,l,m))end,exists=function(l)local m,n=pcall(h,l)return m and n==true end,
folder=function(l)if type(j)~='function'or type(i)~='function'then return end
local m=''for n in string.gmatch(l,'[^/]+')do m=if m==''then n else m..'/'..n
pcall(function()if not i(m)then j(m)end end)end end,asset=function(l)if type(k)
~='function'then return nil end local m,n=pcall(k,l)return if m and type(n)==
'string'then n else nil end}end function b.fetch(f)local g,h=pcall(function()
return(game):HttpGet(f)end)return if g and type(h)=='string'and h~=''then h else
nil end return b end function a.a()local b=a.cache.a if not b then b={c=
__modImpl()}a.cache.a=b end return b.c end end do local function __modImpl()
local b={}local c=0.002 local d=1/20 local e={}local f=0 local g=nil local h=nil
local i=1 local j={number={encode=function(j)return{j}end,decode=function(j)
return j[1]end},Color3={encode=function(j)return{j.R,j.G,j.B}end,decode=function
(j)return Color3.new(math.clamp(j[1],0,1),math.clamp(j[2],0,1),math.clamp(j[3],0
,1))end},UDim2={encode=function(j)return{j.X.Scale,j.X.Offset,j.Y.Scale,j.Y.
Offset}end,decode=function(j)return UDim2.new(j[1],j[2],j[3],j[4])end},Vector2={
encode=function(j)return{j.X,j.Y}end,decode=function(j)return Vector2.new(j[1],j
[2])end}}local function stopLoop()if g then g:Disconnect()g=nil end end local 
function advance(k,l)local m=k.speed*i local n=math.exp(-m*l)local o,p,q=k.x,k.v
,k.g local r=true for s=1,k.n do local t=o[s]-q[s]local u=(p[s]+m*t)*l local v=q
[s]+(t+u)*n local w=(p[s]-m*u)*n o[s]=v p[s]=w if math.abs(v-q[s])>c or math.
abs(w)>c then r=false end end if r then for s=1,k.n do o[s]=q[s]p[s]=0 end end
return r end function b.step(k)k=math.min(k,d)local l=1 while l<=f do local m=e[
l]local n=true if not m.dead then n=advance(m,k)local o,p=pcall(m.write,m.x)if
not o then warn('sottUI: motion write failed: '..tostring(p))m.dead=true end end
if n or m.dead then m.live=false e[l]=e[f]e[f]=nil f-=1 local o=m.done m.done=
nil if o and not m.dead then local p,q=pcall(o)if not p then warn(
'sottUI: motion callback failed: '..tostring(q))end end else l+=1 end end if f==
0 then stopLoop()end end local function wake(k)if k.live or k.dead then return
end k.live=true f+=1 e[f]=k if g==nil and h then g=h(b.step)end end local k={}k.
__index=k function k.snap(l,m)if l.dead then return end l.target=m local n=l.
encode(m)for o=1,l.n do l.g[o]=n[o]l.x[o]=n[o]l.v[o]=0 end l.write(l.x)local o=l
.done l.done=nil if o then o()end end function k.to(l,m,n)if l.dead then return
end l.target=m l.done=n if i<=0 then l:snap(m)return end local o=l.encode(m)
local p=not l.live for q=1,l.n do if o[q]~=l.x[q]then p=false end l.g[q]=o[q]end
if p then l.done=nil if n then n()end return end wake(l)end function k.moving(l)
return l.live end function k.destroy(l)l.dead=true l.done=nil end function b.new
(l,m,n)local o=j[typeof(l)]assert(o,'motion: cannot animate '..typeof(l))local p
=o.encode(l)local q={}for r=1,#p do q[r]=0 end local r=o.decode local s={x=p,v=q
,g=table.clone(p),n=#p,speed=m,encode=o.encode,write=function(s)n(r(s))end,live=
false,dead=false,target=l}return((setmetatable(s,k)))end function b.prop(l,m,n)
return b.new(l[m],n,function(o)l[m]=o end)end function b.setAttach(l)h=l end
function b.setSpeedScale(l)i=l end function b.activeCount()return f end function
b.running()return g~=nil end function b.reset()table.clear(e)f=0 stopLoop()end
return b end function a.b()local b=a.cache.b if not b then b={c=__modImpl()}a.
cache.b=b end return b.c end end do local function __modImpl()local b=a.a()local
c={}local d={text={name='SottUIText',faces={{name='Regular',weight=400,file=
'text-400.ttf'},{name='Medium',weight=500,file='text-500.ttf'}}},display={name=
'SottUIDisplay',faces={{name='ExtraBold',weight=800,file='display-800.ttf'}}}}
local e=10000 local function family(f,g,h,i,j)local k={}for l,m in h.faces do
local n=g..'/'..m.file local o=f.read(n)if o==nil or#o<e then local p=b.fetch(i
..m.file)if p==nil or#p<e then return nil end if not f.write(n,p)then return nil
end end local p=f.asset(n)if p==nil then return nil end table.insert(k,{name=m.
name,weight=m.weight,style='normal',assetId=p})end local l=g..'/'..h.name..
'.json'if not f.write(l,j({name=h.name,faces=k}))then return nil end return f.
asset(l)end function c.load(f,g,h)local i=b.files()if i==nil or b.global(
'getcustomasset')==nil then return{}end i.folder(f)local j={}local k,l=pcall(
function()j.text=family(i,f,d.text,g,h)j.display=family(i,f,d.display,g,h)end)if
not k then warn('sottUI: fonts unavailable: '..tostring(l))end return j end
return c end function a.c()local b=a.cache.c if not b then b={c=__modImpl()}a.
cache.c=b end return b.c end end do local function __modImpl()local b={Frame={
BackgroundTransparency=1,BorderSizePixel=0},TextLabel={BackgroundTransparency=1,
BorderSizePixel=0,TextXAlignment=Enum.TextXAlignment.Left},TextButton={
BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,Text=''},
TextBox={BackgroundTransparency=1,BorderSizePixel=0,ClearTextOnFocus=false,
TextXAlignment=Enum.TextXAlignment.Left},ScrollingFrame={BackgroundTransparency=
1,BorderSizePixel=0,ScrollBarThickness=0,CanvasSize=UDim2.new(),
ScrollingDirection=Enum.ScrollingDirection.Y}}local function make(c,d,e)local f=
Instance.new(c)local g=b[c]if g then for h,i in g do f[h]=i end end local h=nil
if d then for i,j in d do if i=='Parent'then h=j else f[i]=j end end end if e
then for i,j in e do j.Parent=f end end if h then f.Parent=h end return f end
return make end function a.d()local b=a.cache.d if not b then b={c=__modImpl()}a
.cache.d=b end return b.c end end do local function __modImpl()local b=a.d()
local c={}local function stroke(d,e,f,g,h,i,j)local k=b('Frame',{AnchorPoint=
Vector2.new(0.5,0.5),Position=UDim2.fromOffset(i,j),Size=UDim2.fromOffset(g,2),
Rotation=h,BackgroundTransparency=0,Parent=d})e:paint(k,'BackgroundColor3',f)
return k end function c.new(d)local e={}function e.chevron(f,g)local h=b('Frame'
,{Size=UDim2.fromOffset(12,12),Parent=f})stroke(h,d,g,7,45,3.6,6)stroke(h,d,g,7,
-45,8.4,6)return h end function e.cross(f,g)local h=b('Frame',{Size=UDim2.
fromOffset(12,12),Parent=f})stroke(h,d,g,13,45,6,6)stroke(h,d,g,13,-45,6,6)
return h end function e.dash(f,g)local h=b('Frame',{Size=UDim2.fromOffset(12,12)
,Parent=f})stroke(h,d,g,12,0,6,6)return h end return e end return c end function
a.e()local b=a.cache.e if not b then b={c=__modImpl()}a.cache.e=b end return b.c
end end do local function __modImpl()local b={}b.__index=b local function 
dispose(c)local d=typeof(c)if d=='RBXScriptConnection'then c:Disconnect()elseif
d=='Instance'then c:Destroy()elseif d=='function'then c()elseif d=='thread'then
task.cancel(c)elseif d=='table'then local e=c.destroy or c.Destroy or c.
Disconnect if e then e(c)end end end function b.add(c,d)table.insert(c._items,d)
return d end function b.clean(c)local d=c._items c._items={}for e=#d,1,-1 do
local f,g=pcall(dispose,d[e])if not f then warn('sottUI: cleanup failed: '..
tostring(g))end end end b.destroy=b.clean return{new=function()return((
setmetatable({_items={}},b)))end}end function a.f()local b=a.cache.f if not b
then b={c=__modImpl()}a.cache.f=b end return b.c end end do local function 
__modImpl()local b={}b.__index=b local c=function(c)warn(c)end function b.
connect(d,e)local f=table.clone(d._list)table.insert(f,e)d._list=f return
function()local g=table.clone(d._list)local h=table.find(g,e)if h then table.
remove(g,h)d._list=g end end end function b.fire(d,...)for e,f in d._list do
local g,h=xpcall(f,debug.traceback,...)if not g then c(
'sottUI: listener failed: '..tostring(h))end end end function b.clear(d)d._list=
{}end return{new=function()return((setmetatable({_list={}},b)))end,setReporter=
function(d)c=d end}end function a.g()local b=a.cache.g if not b then b={c=
__modImpl()}a.cache.g=b end return b.c end end do local function __modImpl()
local b=a.a()local c=a.f()local d=a.g()local e={}local f={}f.__index=f function
f.pointer(g)return g._uis:GetMouseLocation()end function f.at(g,h)local i=h.
Position local j=g._guiService:GetGuiInset()return Vector2.new(i.X+j.X,i.Y+j.Y)
end function f.capture(g,h,i)g:release()g._move=h g._finish=i end function f.
release(g)local h=g._finish g._move=nil g._finish=nil if h then task.spawn(h,g:
pointer())end end function f.typing(g)return g._uis:GetFocusedTextBox()~=nil end
function f.destroy(g)g._move=nil g._finish=nil g._maid:clean()g.keyDown:clear()g
.keyUp:clear()g.wheel:clear()g.moved:clear()end function e.new()local g=b.
service('UserInputService')local h=c.new()local i=setmetatable({_uis=g,
_guiService=b.service('GuiService'),_maid=h,_move=nil,_finish=nil,keyDown=d.new(
),keyUp=d.new(),wheel=d.new(),moved=d.new()},f)h:add(g.InputChanged:Connect(
function(j)local k=j.UserInputType if k==Enum.UserInputType.MouseMovement then
local l=i:pointer()if i._move then i._move(l)end i.moved:fire(l)elseif k==Enum.
UserInputType.Touch then if i._move then i._move(i:at(j))end elseif k==Enum.
UserInputType.MouseWheel then i.wheel:fire(j.Position.Z)end end))h:add(g.
InputEnded:Connect(function(j,k)local l=j.UserInputType if l==Enum.UserInputType
.MouseButton1 or l==Enum.UserInputType.Touch then if i._move then local m=if l==
Enum.UserInputType.Touch then i:at(j)else i:pointer()local n=i._finish i._move=
nil i._finish=nil if n then n(m)end end end i.keyUp:fire(j,k)end))h:add(g.
InputBegan:Connect(function(j,k)i.keyDown:fire(j,k)end))return i end return e
end function a.h()local b=a.cache.h if not b then b={c=__modImpl()}a.cache.h=b
end return b.c end end do local function __modImpl()local b={}local c={[Enum.
UserInputType.MouseButton1]='MB1',[Enum.UserInputType.MouseButton2]='MB2',[Enum.
UserInputType.MouseButton3]='MB3'}local d={[Enum.KeyCode.LeftAlt]='LAlt',[Enum.
KeyCode.RightAlt]='RAlt',[Enum.KeyCode.LeftControl]='LCtrl',[Enum.KeyCode.
RightControl]='RCtrl',[Enum.KeyCode.LeftShift]='LShift',[Enum.KeyCode.RightShift
]='RShift'}local function nameOf(e)local f=c[e.UserInputType]if f then return f
end if e.UserInputType==Enum.UserInputType.Keyboard and e.KeyCode.Name~=
'Unknown'then return e.KeyCode.Name end return nil end function b.new(e,f,g)
local h=f.service('UserInputService')local i={}local j={}local k=nil local l=
false local m={}local n=nil local function modifiersHeld(o)for p,q in(o or{})do
local r=false for s,t in d do if t==q and h:IsKeyDown(s)then r=true end end if
not r then return false end end return true end local function heldModifiers(o)
local p={}for q,r in d do if q.Name~=o and h:IsKeyDown(q)then table.insert(p,r)
end end table.sort(p)return p end function i.register(o,p)table.insert(j,p)end
function i.unregister(o,p)local q=table.find(j,p)if q then table.remove(j,q)end
end function i.listen(o,p,q)i.cancel()k=p l=q==true end function i.cancel()local
o=k k=nil if o then o(nil)end end function i.state(o,p)local q=p.value if q==nil
then return false end if q.mode=='Always'then return true end if q.mode==
'Toggle'then return p.toggled==true end if q.key=='None'or k~=nil then return
false end if g()and string.sub(q.key,1,2)=='MB'then return false end return m[q.
key]==true and modifiersHeld(q.modifiers)end e.keyDown:connect(function(o,p)
local q=nameOf(o)if q==nil then return end if k then local r=c[o.UserInputType]
~=nil if r and(l or q=='MB1')then return end local s=k k=nil n=q if q=='Escape'
then(s)('None',{})elseif d[o.KeyCode]and not r then(s)(q,{})else(s)(q,
heldModifiers(q))end return end m[q]=true if n==q then return end if p or e:
typing()then return end for r,s in j do local t=s.value if t.key==q and not s.
disabled and modifiersHeld(t.modifiers)then if t.mode=='Toggle'then s.toggled=
not s.toggled end local u=s.spec.onPress if u then u(s,s.toggled)end end end end
)e.keyUp:connect(function(o)local p=nameOf(o)if p==nil then return end m[p]=nil
if n==p then n=nil end end)return i end return b end function a.i()local b=a.
cache.i if not b then b={c=__modImpl()}a.cache.i=b end return b.c end end do
local function __modImpl()local b=a.d()local c={}local d=256 local e=148 local f
=14 local g=10 local h=12 local i=(function()local i={}for j=0,6 do table.
insert(i,ColorSequenceKeypoint.new(j/6,Color3.fromHSV((j/6)%1,1,1)))end return
ColorSequence.new(i)end)()local function hex(j)return string.format(
'%02X%02X%02X',math.round(j.R*255),math.round(j.G*255),math.round(j.B*255))end
local function parseHex(j)local k=string.gsub(j,'#','')if not string.match(k,
'^%x%x%x%x%x%x$')then return nil end return Color3.fromRGB((tonumber(string.sub(
k,1,2),16)),(tonumber(string.sub(k,3,4),16)),(tonumber(string.sub(k,5,6),16)))
end c.hex=hex c.parseHex=parseHex local function open(j,k,l)local m=j.theme
local n=k.spec.alpha==true local o=h+e+g+f+(if n then g+f else 0)+g+28+h j.
popover:open(l,d,o,function(p,q)local r=k.value local s,t,u=r.color:ToHSV()local
v=r.alpha local w=b('TextButton',{Position=UDim2.fromOffset(h,h),Size=UDim2.new(
1,-2*h,0,e),BackgroundTransparency=0,Parent=p})b('UIGradient',{Transparency=
NumberSequence.new(0,1),Color=ColorSequence.new(Color3.new(1,1,1)),Parent=b(
'Frame',{Size=UDim2.fromScale(1,1),BackgroundTransparency=0,BackgroundColor3=
Color3.new(1,1,1),Parent=w,ZIndex=1})})local x=b('Frame',{Size=UDim2.fromScale(1
,1),BackgroundTransparency=0,BackgroundColor3=Color3.new(0,0,0),ZIndex=2,Parent=
w})b('UIGradient',{Rotation=90,Transparency=NumberSequence.new(1,0),Parent=x})
local y=b('Frame',{AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(10,10)
,BackgroundTransparency=1,ZIndex=3,Parent=w})b('UICorner',{CornerRadius=UDim.
new(1,0),Parent=y})b('UIStroke',{Color=Color3.new(1,1,1),Thickness=1.5,Parent=y}
)local z=h+e+g local A=b('TextButton',{Position=UDim2.fromOffset(h,z),Size=UDim2
.new(1,-2*h,0,f),BackgroundTransparency=0,BackgroundColor3=Color3.new(1,1,1),
Parent=p})b('UIGradient',{Color=i,Parent=A})local B=b('Frame',{AnchorPoint=
Vector2.new(0.5,0),Size=UDim2.new(0,3,1,0),BackgroundTransparency=0,
BackgroundColor3=Color3.new(1,1,1),ZIndex=2,Parent=A})z+=f local C,D=nil,nil if
n then z+=g C=b('TextButton',{Position=UDim2.fromOffset(h,z),Size=UDim2.new(1,-2
*h,0,f),BackgroundTransparency=0,Parent=p})D=b('Frame',{AnchorPoint=Vector2.new(
0.5,0),Size=UDim2.new(0,3,1,0),BackgroundTransparency=0,BackgroundColor3=Color3.
new(1,1,1),ZIndex=2,Parent=C})b('UIGradient',{Transparency=NumberSequence.new(0,
1),Parent=C})z+=f end z+=g local E=b('Frame',{Position=UDim2.fromOffset(h,z),
Size=UDim2.fromOffset(44,28),BackgroundTransparency=0,Parent=p})local F=b(
'TextBox',{Position=UDim2.fromOffset(h+54,z),Size=UDim2.new(1,-(2*h+54),0,28),
TextSize=14,Parent=p})m:type(F,'text',true)m:paint(F,'TextColor3','text')local 
function draw()local G=Color3.fromHSV(s,t,u)w.BackgroundColor3=Color3.fromHSV(s,
1,1)y.Position=UDim2.fromScale(t,1-u)B.Position=UDim2.fromScale(s,0)E.
BackgroundColor3=G if not F:IsFocused()then F.Text='#'..hex(G)end if C then C.
BackgroundColor3=G D.Position=UDim2.fromScale(v,0)end end local function commit(
)draw()k:set({color=Color3.fromHSV(s,t,u),alpha=v})end local function bind(G,H)
local function update(I)local J,K=G.AbsolutePosition,G.AbsoluteSize H(math.
clamp((I.X-J.X)/math.max(K.X,1),0,1),math.clamp((I.Y-J.Y)/math.max(K.Y,1),0,1))
commit()end G.InputBegan:Connect(function(I)local J=I.UserInputType if J==Enum.
UserInputType.MouseButton1 then update(j.input:pointer())j.input:capture(update)
elseif J==Enum.UserInputType.Touch then j.setScrollLocked(true)update(j.input:
at(I))j.input:capture(update,function()j.setScrollLocked(false)end)end end)end
bind(w,function(G,H)t,u=G,1-H end)bind(A,function(G)s=math.clamp(G,0,0.999)end)
if C then bind(C,function(G)v=G end)end F.FocusLost:Connect(function()local G=
parseHex(F.Text)if G then s,t,u=G:ToHSV()commit()else draw()end end)q.onRefresh(
function()local G=k.value if G.color~=Color3.fromHSV(s,t,u)then s,t,u=G.color:
ToHSV()end v=G.alpha draw()end)draw()end)end function c.swatch(j,k)local l=b(
'TextButton',{Name='Swatch',Size=UDim2.fromOffset(32,26),BackgroundTransparency=
0,ZIndex=2})local m=b('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
Parent=l})j.theme:paint(m,'Color','lineStrong')local n={root=l,width=32}n.
refresh=function()l.BackgroundColor3=k.value.color l.BackgroundTransparency=k.
value.alpha*0.8 end n.refresh()l.Activated:Connect(function()if not k.disabled
then open(j,k,l)end end)n.setInk=function(o)j.theme:paint(m,'Color',if o then
'onAccent'else'lineStrong')end n.destroy=function()l:Destroy()end return n end
function c.band(j,k,l)local m=b('Frame',{AnchorPoint=Vector2.new(0,1),Position=
UDim2.fromScale(0,1),Size=UDim2.new(1,0,0,40),BackgroundTransparency=0,ZIndex=2,
Parent=l})local n={}n.refresh=function()m.BackgroundColor3=k.value.color m.
BackgroundTransparency=k.value.alpha*0.8 end n.refresh()n.open=function()if not
k.disabled then open(j,k,l)end end n.destroy=function()end return n end return c
end function a.j()local b=a.cache.j if not b then b={c=__modImpl()}a.cache.j=b
end return b.c end end do local function __modImpl()local b={}local function 
isStart(c,d)if d==1 then return true end local e=string.sub(c,d-1,d-1)return e==
' 'or e=='/'or e=='-'or e=='_'end function b.score(c,d)if c==''then return 0 end
local e=string.lower(d)local f=string.lower(c)local g=string.find(e,f,1,true)if
g then return 1000-#e+(if isStart(e,g)then 500 else 0)end local h,i,j=0,1,-1 for
k=1,#f do local l=string.sub(f,k,k)if l~=' 'then local m=string.find(e,l,i,true)
if m==nil then return nil end h+=if isStart(e,m)then 12 elseif m==j+1 then 8
else 1 h-=math.min(m-i,6)j=m i=m+1 end end return h end function b.rank(c,d,e,f)
local g={}for h,i in d do local j=b.score(c,e(i))if j then table.insert(g,{item=
i,score=j})end end table.sort(g,function(h,i)return h.score>i.score end)local h=
{}for i=1,math.min(f,#g)do h[i]=g[i].item end return h end return b end function
a.k()local b=a.cache.k if not b then b={c=__modImpl()}a.cache.k=b end return b.c
end end do local function __modImpl()local b=a.d()local c=a.k()local d={}local e
=38 local f=8 local g=9 local h=48 local i=230 local function isPicked(j,k)if j.
spec.multi then return j.value[k]==true end return j.value==k end function d.
open(j,k,l)local m=k.spec local n=j.theme local o=m.display or tostring local p=
m.searchable==true or#m.options>=g local q=m.options local r=0 local s=math.max(
l.AbsoluteSize.X,i)local function bodyHeight()local t=math.clamp(#q,1,f)return t
*e+8 end local t=bodyHeight()+(if p then h else 0)j.popover:open(l,s,t,function(
u,v)local w=b('ScrollingFrame',{Position=UDim2.fromOffset(0,if p then h else 0),
Size=UDim2.new(1,0,1,if p then-h else 0),ScrollBarThickness=2,Parent=u})n:paint(
w,'ScrollBarImageColor3','lineStrong')local x=b('Frame',{Size=UDim2.fromScale(1,
1),Parent=w})local y={}local z=f+2 local A=b('TextLabel',{Position=UDim2.
fromOffset(14,4),Size=UDim2.new(1,-28,0,e),TextSize=16,Text='Nothing matches',
Visible=false,Parent=u})n:type(A,'text')n:paint(A,'TextColor3','faint')if p then
A.Position=UDim2.fromOffset(14,h+4)end local function draw()local B=w.
CanvasPosition.Y local C=math.floor(B/e)+1 for D=1,z do local E=y[D]local F=C+D-
1 local G=q[F]if G==nil then E.root.Visible=false else E.index=F E.option=G E.
root.Visible=true E.root.Position=UDim2.new(0,4,0,(F-1)*e+4)E.text.Text=o(G)
local H=isPicked(k,G)n:paint(E.text,'TextColor3',if H then'onAccent'else'text')n
:paint(E.root,'BackgroundColor3',if H then'accent'else'raised')E.root.
BackgroundTransparency=if H or F==r then 0 else 1 end end end local function 
refit()w.CanvasSize=UDim2.fromOffset(0,#q*e+8)A.Visible=#q==0 v.resize(
bodyHeight()+(if p then h else 0))draw()end local function choose(B)if m.multi
then local C=table.clone(k.value)C[B]=if C[B]then nil else true k:set(C)draw()
return end if k.value==B then if m.allowNull then k:set(nil)end else k:set(B)end
v.close()end for B=1,z do local C=b('TextButton',{Size=UDim2.new(1,-8,0,e-2),
BackgroundTransparency=1,Visible=false,Parent=x})n:paint(C,'BackgroundColor3',
'raised')local D=b('TextLabel',{Position=UDim2.fromOffset(10,0),Size=UDim2.new(1
,-20,1,0),TextSize=16,TextTruncate=Enum.TextTruncate.AtEnd,Parent=C})n:type(D,
'text',true)local E={root=C,text=D,index=0,option=nil}y[B]=E C.MouseEnter:
Connect(function()r=E.index draw()end)C.MouseLeave:Connect(function()if r==E.
index then r=0 draw()end end)C.Activated:Connect(function()if E.option~=nil then
choose(E.option)end end)end w:GetPropertyChangedSignal('CanvasPosition'):
Connect(draw)local B=nil if p then B=b('TextBox',{Position=UDim2.fromOffset(14,0
),Size=UDim2.new(1,-28,0,h),TextSize=24,Text='',PlaceholderText='Search',Parent=
u})n:type(B,'display')n:paint(B,'TextColor3','text')n:paint(B,
'PlaceholderColor3','faint')local C=b('Frame',{Position=UDim2.fromOffset(0,h-1),
Size=UDim2.new(1,0,0,1),BackgroundTransparency=0,Parent=u})n:paint(C,
'BackgroundColor3','line')B:GetPropertyChangedSignal('Text'):Connect(function()
local D=B.Text if D==''then q=m.options else q=c.rank(D,m.options,o,500)end r=if
#q>0 and D~=''then 1 else 0 w.CanvasPosition=Vector2.zero refit()end)end v.
onKey(function(C)if C=='Down'or C=='Up'then local D=if C=='Down'then 1 else-1 r=
math.clamp(r+D,1,math.max(#q,1))local E=(r-1)*e local F=w.AbsoluteSize.Y local G
=w.CanvasPosition.Y if E<G then w.CanvasPosition=Vector2.new(0,E)elseif E+e+8>G+
F then w.CanvasPosition=Vector2.new(0,E+e+8-F)end draw()elseif C=='Return'then
local D=q[r]if D~=nil then choose(D)end end end)refit()if not m.multi and k.
value~=nil then local C=table.find(q,k.value)if C then local D=(math.clamp(#q,1,
f))*e w.CanvasPosition=Vector2.new(0,math.max((C-1)*e-D/2+e/2,0))draw()end end
if B and not j.touch then B:CaptureFocus()end end)end return d end function a.l(
)local b=a.cache.l if not b then b={c=__modImpl()}a.cache.l=b end return b.c end
end do local function __modImpl()local b=a.d()local c={}local d=14 local e=8.6
local function display(f)local g=f.value if g==nil or g.key=='None'or g.key==
'Unknown'then return'Unset'end local h={}for i,j in g.modifiers or{}do table.
insert(h,j)end table.insert(h,g.key)return table.concat(h,'+')end local function 
cycleMode(f,g)local h=g.spec.modes if g.disabled or h==nil or#h<2 then return
end local i=table.find(h,g.value.mode)or 0 local j=h[i%#h+1]g:set({mode=j})f.
notify({title=g.label,text='Key mode: '..j,seconds=2})end local function listen(
f,g,h,i)if g.disabled then return end i(true)f.keys:listen(function(j,k)if j~=
nil then g:set({key=j,modifiers=k or{}})end i(false)h.refresh()end,g.spec.
noMouse==true)end function c.build(f,g)local h=f.theme local i=b('TextButton',{
Name='Key',Size=UDim2.fromOffset(52,26),BackgroundTransparency=1})local j=b(
'UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=i})local k=b(
'TextLabel',{Size=UDim2.fromScale(1,1),TextSize=15,TextXAlignment=Enum.
TextXAlignment.Center,ZIndex=5,Parent=i})h:type(k,'text',true)local l={root=i,
width=52}local m=false local n=false local function fit(o)local p=math.max(#o*e+
d,34)i.Size=UDim2.fromOffset(p,26)l.width=p end local function ink()local o=if m
then'accent'elseif n then'onAccent'else'muted'h:paint(k,'TextColor3',o)h:paint(j
,'Color',if m then'accent'elseif n then'onAccent'else'lineStrong')end l.refresh=
function()if m then return end local o=display(g)k.Text=o fit(o)ink()end l.
setInk=function(o)n=o ink()end l.refresh()i.Activated:Connect(function()if m
then return end listen(f,g,l,function(o)m=o if o then k.Text='Press a key'fit(
'Press a key')end ink()end)end)i.MouseButton2Click:Connect(function()cycleMode(f
,g)end)l.destroy=function()if m then f.keys:cancel()end i:Destroy()end return l
end function c.big(f,g,h)local i=f.theme local j=b('TextLabel',{AnchorPoint=
Vector2.new(0,1),Position=UDim2.new(0,12,1,-7),Size=UDim2.new(1,-24,0,36),
TextSize=32,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=3,Parent=h})i:type(j,
'display')local k={}local l=false k.refresh=function()if l then return end local
m=display(g)j.Text=m i:paint(j,'TextColor3',if m=='Unset'then'faint'else'text')
end k.refresh()k.start=function()if l then return end listen(f,g,k,function(m)l=
m if m then j.Text='Press a key'i:paint(j,'TextColor3','accent')end end)end h.
MouseButton2Click:Connect(function()cycleMode(f,g)end)k.destroy=function()if l
then f.keys:cancel()end end return k end return c end function a.m()local b=a.
cache.m if not b then b={c=__modImpl()}a.cache.m=b end return b.c end end do
local function __modImpl()local b=a.d()local c=a.b()local d={}d.PAD=12 d.HEIGHT=
92 local e=26 local f=44 local g=13 local h=0.97 local i={}i.__index=i local 
function ownSpring(j,k)table.insert(j._cleanups,function()k:destroy()end)return
k end d.own=ownSpring local function baseColor(j)local k=j.ctx.theme.tokens if j
._lit then return if j._hover then k.accentHover else k.accent end return if j.
_hover then k.raised else k.surface end local function paintBase(j)if j._wash==
nil then j._wash=ownSpring(j,c.prop(j.root,'BackgroundColor3',e))end j._wash:to(
baseColor(j))end function i.onHover(j,k)local l=k and not j.el.disabled if j.
_hover==l then return end j._hover=l paintBase(j)end function i.pressed(j,k)if j
._press==nil then local l=b('UIScale',{Parent=j.root})j._press=ownSpring(j,c.
prop(l,'Scale',f))end j._press:to(if k then h else 1)end function i.setBase(j,k)
j._lit=k paintBase(j)end function i.flood(j,k,l)if j._floodOn==k then return end
j._floodOn=k local m=j.root local n=m.AbsoluteSize if l or n.X<1 or not m.
Visible then j._lit=k if j._wash then j._wash:snap(baseColor(j))else m.
BackgroundColor3=baseColor(j)end return end local o=j._floodFrame if o==nil then
o=b('Frame',{Name='Flood',AnchorPoint=Vector2.new(0.5,0.5),
BackgroundTransparency=0,ZIndex=1,Parent=m})b('UICorner',{CornerRadius=UDim.new(
1,0),Parent=o})j.ctx.theme:paint(o,'BackgroundColor3','accent')j._floodFrame=o j
._floodSpring=ownSpring(j,c.prop(o,'Size',g))end local p=math.ceil(math.sqrt(n.X
*n.X+n.Y*n.Y)*2.6)local q=j._pressAt j._pressAt=nil local r=if q then q-m.
AbsolutePosition else n/2 o.Position=UDim2.fromOffset(r.X,r.Y)o.Visible=true if
k then j._floodSpring:snap(UDim2.fromOffset(0,0))j._floodSpring:to(UDim2.
fromOffset(p,p),function()j:setBase(true)o.Visible=false end)else j._lit=false
if j._wash then j._wash:snap(baseColor(j))else m.BackgroundColor3=baseColor(j)
end j._floodSpring:snap(UDim2.fromOffset(p,p))j._floodSpring:to(UDim2.
fromOffset(0,0),function()o.Visible=false end)end end function i.ink(j,k,l,m)
local n=j.ctx.theme.tokens local o=j._inks local p=o[k]if m or p==nil and k.
TextColor3==n[l]then if p then p:snap(n[l])else k.TextColor3=n[l]end return end
if p==nil then p=ownSpring(j,c.prop(k,'TextColor3',g+4))o[k]=p end p:to(n[l])end
function i.refreshLabel(j)j.label.Text=j.el.label end function d.new(j,k,l)local
m=b('TextButton',{Name=k.kind,Size=UDim2.new(1,0,0,l or d.HEIGHT),
BackgroundTransparency=0,ClipsDescendants=true})j.theme:paint(m,
'BackgroundColor3','surface')local n=b('TextLabel',{Name='Label',Position=UDim2.
fromOffset(d.PAD,9),Size=UDim2.new(1,-2*d.PAD,0,42),TextSize=16,TextWrapped=true
,TextYAlignment=Enum.TextYAlignment.Top,TextTruncate=Enum.TextTruncate.AtEnd,
LineHeight=1.05,Text=k.label,ZIndex=3,Parent=m})j.theme:type(n,'text',true)local
o=setmetatable({root=m,label=n,el=k,ctx=j,_cleanups={},_inks={},_hover=false,
_lit=false,_floodOn=false},i)m.MouseEnter:Connect(function()j.hover:enter(o)end)
m.InputBegan:Connect(function(p)local q=p.UserInputType if k.disabled then
return end if q==Enum.UserInputType.MouseButton1 then o._pressAt=j.input:
pointer()o:pressed(true)elseif q==Enum.UserInputType.Touch then o._pressAt=j.
input:at(p)o:pressed(true)end end)m.InputEnded:Connect(function(p)local q=p.
UserInputType if q==Enum.UserInputType.MouseButton1 or q==Enum.UserInputType.
Touch then if o._press then o:pressed(false)end end end)o.destroy=function()j.
hover:leave(o)for p,q in o._cleanups do pcall(q)end m:Destroy()end return o end
return d end function a.n()local b=a.cache.n if not b then b={c=__modImpl()}a.
cache.n=b end return b.c end end do local function __modImpl()local b=a.j()local
c=a.l()local d=a.m()local e=a.d()local f=a.b()local g=a.n()local h={}local i=g.
PAD local j=40 local k=32 local l=38 local m=26 local function bigText(n,o,p,q)
local r=e('TextLabel',{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,i,1,-7)
,Size=UDim2.new(1,-2*i,0,p+4),TextSize=p,TextTruncate=Enum.TextTruncate.AtEnd,
TextXAlignment=q or Enum.TextXAlignment.Left,ZIndex=3,Parent=o})n.theme:type(r,
'display')return r end local function addons(n,o,p)local q=p.addons if q==nil
then return 0 end local r=0 for s,t in q do local u=if t.kind=='key'then d.
build(o,t)else b.swatch(o,t)u.root.AnchorPoint=Vector2.new(1,1)u.root.Position=
UDim2.new(1,-(i+r),1,-10)u.root.ZIndex=4 u.root.Parent=n.root r+=u.width+6 t.
_view=u n._chips=n._chips or{}table.insert(n._chips,u)table.insert(n._cleanups,
function()t._view=nil u.destroy()end)end return r end local n={}function n.
toggle(o,p)local q=g.new(o,p)local r=bigText(o,q.root,k)r.Size=UDim2.new(0,70,0,
k+4)addons(q,o,p)local function draw(s)local t=p.value==true r.Text=if t then
'ON'else'OFF'q:flood(t,s)local u=if p.disabled then'faint'elseif t then
'onAccent'else'text'local v=if p.disabled then'faint'elseif t then'onAccent'else
'faint'q:ink(q.label,u,s)q:ink(r,v,s)if q._chips then for w,x in q._chips do x.
setInk(t)end end end q.root.Activated:Connect(function()if not p.disabled then p
:set(not p.value)end end)q.refresh=function()q:refreshLabel()draw(false)end
draw(true)return q end local function formatted(o)local p=o.spec if p.format
then local q,r=pcall(p.format,o,o.value)if q and r~=nil then return tostring(r)
end end return string.format('%.'..(p.decimals or 0)..'f',o.value)..(p.suffix or
'')end function n.slider(o,p)local q=g.new(o,p)local r=o.theme local s=p.spec
local t=q.root local function ratio()local u=s.max-s.min return if u<=0 then 0
else(p.value-s.min)/u end q.label.Size=UDim2.new(1,-2*i,0,22)q.label.TextWrapped
=false r:paint(q.label,'TextColor3','text')local u=bigText(o,t,l,Enum.
TextXAlignment.Right)r:paint(u,'TextColor3','text')local v=e('Frame',{Name=
'Fill',Size=UDim2.new(ratio(),0,1,0),BackgroundTransparency=0,ZIndex=2,Parent=t}
)r:paint(v,'BackgroundColor3','accentDim')local w=e('Frame',{AnchorPoint=Vector2
.new(1,0),Position=UDim2.fromScale(1,0),Size=UDim2.new(0,3,1,0),
BackgroundTransparency=0,ZIndex=2,Parent=v})r:paint(w,'BackgroundColor3',
'accent')local x=g.own(q,f.prop(v,'Size',j))local function setText()u.Text=
formatted(p)end setText()local function fromPointer(y)local z=t.AbsolutePosition
.X local A=math.max(t.AbsoluteSize.X,1)local B=math.clamp((y.X-z)/A,0,1)p:set(s.
min+(s.max-s.min)*B)end local function typedEntry()if p.disabled or q._typing
then return end q._typing=true local y=e('TextBox',{AnchorPoint=Vector2.new(0,1)
,Position=UDim2.new(0,i,1,-7),Size=UDim2.new(1,-2*i,0,l+4),TextSize=l,
TextXAlignment=Enum.TextXAlignment.Right,Text=tostring(p.value),
BackgroundTransparency=0,ZIndex=6,Parent=t})r:paint(y,'BackgroundColor3','base')
r:type(y,'display')r:paint(y,'TextColor3','accent')y:CaptureFocus()y.
SelectionStart=1 y.CursorPosition=#y.Text+1 y.FocusLost:Connect(function()local
z=tonumber(y.Text)q._typing=false y:Destroy()if z then p:set(z)end end)end t.
InputBegan:Connect(function(y)if p.disabled then return end local z=y.
UserInputType if z==Enum.UserInputType.MouseButton2 then typedEntry()elseif z==
Enum.UserInputType.MouseButton1 then local A=os.clock()if q._lastPress and A-q.
_lastPress<0.3 then q._lastPress=nil o.input:release()typedEntry()return end q.
_lastPress=A local B=o.input:pointer()fromPointer(B)o.input:capture(fromPointer)
elseif z==Enum.UserInputType.Touch then local A=o.input:at(y)local B=false o.
input:capture(function(C)if not B then local D=C-A if math.abs(D.X)>6 and math.
abs(D.X)>math.abs(D.Y)then B=true o.setScrollLocked(true)elseif math.abs(D.Y)>8
then o.input:release()return else return end end fromPointer(C)end,function(C)o.
setScrollLocked(false)if not B and(C-A).Magnitude<6 then fromPointer(C)end end)
end end)q.refresh=function()q.label.Text=p.label setText()local y=if p.disabled
then'faint'else'text'r:paint(q.label,'TextColor3',y)r:paint(u,'TextColor3',y)x:
to(UDim2.new(ratio(),0,1,0))end return q end local function pickText(o)local p=o
.spec.display or tostring local q=o.value if o.spec.multi then local r={}for s,t
in o.spec.options do if q[t]then table.insert(r,p(t))end end for s,t in q do if
t and not table.find(o.spec.options,s)then table.insert(r,p(s))end end if#r==0
then return'None',false end if#r<=2 then return table.concat(r,', '),true end
return#r..' picked',true end if q==nil then return'None',false end return p(q),
true end function n.dropdown(o,p)local q=g.new(o,p)local r=o.theme q.label.Size=
UDim2.new(1,-2*i,0,22)q.label.TextWrapped=false r:paint(q.label,'TextColor3',
'muted')local s=bigText(o,q.root,m)s.Size=UDim2.new(1,-(2*i+22),0,m+6)local t=o.
glyph.chevron(q.root,'muted')t.AnchorPoint=Vector2.new(1,1)t.Position=UDim2.new(
1,-i,1,-16)t.ZIndex=3 q.root.Activated:Connect(function()if not p.disabled then
c.open(o,p,q.root)end end)q.refresh=function()q:refreshLabel()local u,v=
pickText(p)s.Text=u r:paint(s,'TextColor3',if p.disabled or not v then'faint'
else'text')end q.refresh()return q end function n.input(o,p)local q=g.new(o,p)
local r=o.theme local s=p.spec q.label.Size=UDim2.new(1,-2*i,0,22)q.label.
TextWrapped=false r:paint(q.label,'TextColor3','muted')local t=e('TextBox',{
AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,i,1,-9),Size=UDim2.new(1,-2*i,
0,30),TextSize=20,Text=p.value or'',PlaceholderText=s.placeholder or'',
ClipsDescendants=true,TextEditable=not p.disabled,ZIndex=3,Parent=q.root})r:
type(t,'text')r:paint(t,'TextColor3','text')r:paint(t,'PlaceholderColor3',
'faint')local u=e('Frame',{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1
,0),Size=UDim2.new(1,0,0,2),BackgroundTransparency=0,Visible=false,ZIndex=4,
Parent=q.root})r:paint(u,'BackgroundColor3','accent')t.Focused:Connect(function(
)u.Visible=true end)t.FocusLost:Connect(function()u.Visible=false if s.finished
and not p:set(t.Text)then t.Text=p.value or''end end)t:GetPropertyChangedSignal(
'Text'):Connect(function()if q._applying or s.finished then return end if not p:
set(t.Text)and t.Text~=p.value then q._applying=true t.Text=p.value or''q.
_applying=false end end)q.root.Activated:Connect(function()if not p.disabled
then t:CaptureFocus()end end)q.refresh=function()q:refreshLabel()t.TextEditable=
not p.disabled if t.Text~=(p.value or'')then q._applying=true t.Text=p.value or
''q._applying=false end end return q end function n.button(o,p)local q=g.new(o,p
)local r=o.theme q.label.Text=''local s=bigText(o,q.root,m)s.TextWrapped=true s.
TextTruncate=Enum.TextTruncate.None s.Size=UDim2.new(1,-2*i,1,-14)s.
TextYAlignment=Enum.TextYAlignment.Bottom r:paint(s,'TextColor3','text')local t=
e('TextLabel',{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-i,0,8),Size=
UDim2.fromOffset(20,20),TextSize=18,Text=utf8.char(0x2192),TextXAlignment=Enum.
TextXAlignment.Right,ZIndex=3,Parent=q.root})r:type(t,'text',true)r:paint(t,
'TextColor3','muted')local u=nil local function draw()s.Text=p.label q:ink(s,if
p.disabled then'faint'else'text')q:flood(false)end q.refresh=draw draw()q.label.
Visible=false local function run()if u then task.cancel(u)u=nil end draw()q:
flood(true)q:ink(s,'onAccent')task.delay(0.22,function()if q.root.Parent then q:
flood(false)q:ink(s,'text')end end)p:fire()end q.root.Activated:Connect(function
()if p.disabled then return end if p.spec.confirm and u==nil then s.Text=
'Again to confirm'q:ink(s,'onAccent')q:flood(true)u=task.delay(2.5,function()u=
nil draw()end)return end run()end)table.insert(q._cleanups,function()if u then
task.cancel(u)end end)return q end function n.stat(o,p)local q=g.new(o,p)local r
=o.theme q.root.Active=false q.root.AutoButtonColor=false q.onHover=function()
end q.pressed=function()end q.label.Size=UDim2.new(1,-2*i,0,22)q.label.
TextWrapped=false r:paint(q.label,'TextColor3','muted')local s=bigText(o,q.root,
l)r:paint(s,'TextColor3','text')q.refresh=function()q:refreshLabel()s.Text=
tostring(p.value)end q.refresh()return q end function n.label(o,p)local q=g.new(
o,p,34)local r=o.theme local s=q.label local t=p.spec.wrap==true q.root.
BackgroundTransparency=1 q.root.Active=false q.onHover=function()end q.pressed=
function()end s.RichText=true s.TextWrapped=t s.TextSize=16 s.FontFace=r:face(
'text')r:type(s,'text')r:paint(s,'TextColor3','muted')s.TextTruncate=if t then
Enum.TextTruncate.None else Enum.TextTruncate.AtEnd s.TextYAlignment=if t then
Enum.TextYAlignment.Top else Enum.TextYAlignment.Center s.LineHeight=if t then
1.15 else 1 s.Position=UDim2.fromOffset(2,if t then 6 else 0)s.Size=if t then
UDim2.new(1,-4,1,-6)else UDim2.new(1,-4,1,0)if p.addons then local u=addons(q,o,
p)s.Size=UDim2.new(1,-(u+8),1,0)if q._chips then for v,w in q._chips do w.root.
AnchorPoint=Vector2.new(1,0.5)w.root.Position=UDim2.new(1,-2,0.5,0)end end end
if t then s:GetPropertyChangedSignal('TextBounds'):Connect(function()local u=
math.ceil(s.TextBounds.Y/o.uiScale())+12 if p._measured~=u then p._measured=u if
p._relayout then p._relayout()end end end)end q.refresh=function()s.Text=p.label
end return q end function n.divider(o,p)local q=g.new(o,p,34)local r=o.theme q.
root.BackgroundTransparency=1 q.root.Active=false q.onHover=function()end q.
pressed=function()end q.label.Position=UDim2.fromOffset(2,6)q.label.Size=UDim2.
new(1,-4,1,-6)q.label.TextYAlignment=Enum.TextYAlignment.Center r:paint(q.label,
'TextColor3','muted')q.refresh=function()q:refreshLabel()end return q end
function n.key(o,p)local q=g.new(o,p)local r=o.theme q.label.Size=UDim2.new(1,-2
*i,0,22)r:paint(q.label,'TextColor3','muted')local s=d.big(o,p,q.root)table.
insert(q._cleanups,s.destroy)q.refresh=function()q:refreshLabel()s.refresh()end
q.root.Activated:Connect(s.start)return q end function n.color(o,p)local q=g.
new(o,p)local r=b.band(o,p,q.root)table.insert(q._cleanups,r.destroy)q.refresh=
function()q:refreshLabel()r.refresh()end q.root.Activated:Connect(r.open)return
q end function h.build(o,p)local q=n[p.kind]assert(q,'sottUI: no view for '..
tostring(p.kind))local r=q(o,p)p._view=r return r end return h end function a.o(
)local b=a.cache.o if not b then b={c=__modImpl()}a.cache.o=b end return b.c end
end do local function __modImpl()local b=a.d()local c=a.b()local d={}local e=320
local f=8 local g=20 local h=26 local i=5 function d.new(j,k)local l=j.theme
local m={}local n={}local function layout()local o=k.AbsoluteSize local p=o.Y-g
for q=#m,1,-1 do local r=m[q]p-=r.height r.pos:to(UDim2.fromOffset(o.X-e-g,p))p
-=f end end local function dismiss(o)if o.gone then return end o.gone=true if o.
timer then task.cancel(o.timer)end local p=table.find(m,o)if p then table.
remove(m,p)end local q=k.AbsoluteSize o.pos:to(UDim2.fromOffset(q.X+8,o.frame.
Position.Y.Offset),function()o.pos:destroy()o.frame:Destroy()end)layout()end
function n.show(o,p)while#m>=i do dismiss(m[1])end local q=k.AbsoluteSize local
r=b('TextButton',{Name='Notice',Position=UDim2.fromOffset(q.X+8,q.Y-g-60),Size=
UDim2.fromOffset(e,60),BackgroundTransparency=0,ZIndex=30,Parent=k})l:paint(r,
'BackgroundColor3','surface')local s=b('UIStroke',{ApplyStrokeMode=Enum.
ApplyStrokeMode.Border,Parent=r})l:paint(s,'Color','lineStrong')local t=10 if p.
title and p.title~=''then local u=b('TextLabel',{Position=UDim2.fromOffset(14,t)
,Size=UDim2.new(1,-28,0,20),TextSize=15,TextTruncate=Enum.TextTruncate.AtEnd,
Text=p.title,ZIndex=31,Parent=r})l:type(u,'ui',true)l:paint(u,'TextColor3',
'text')t+=22 end local u=nil if p.text and p.text~=''then u=b('TextLabel',{
Position=UDim2.fromOffset(14,t),Size=UDim2.new(1,-28,0,20),TextSize=15,
TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top,RichText=true,Text=p.
text,ZIndex=31,Parent=r})l:type(u,'ui')l:paint(u,'TextColor3','muted')end local
v={frame=r,height=t+28,pos=c.prop(r,'Position',h),gone=false}r.Size=UDim2.
fromOffset(e,v.height)if u then task.defer(function()if v.gone then return end
local w=math.ceil(u.TextBounds.Y)if w>20 then u.Size=UDim2.new(1,-28,0,w)v.
height=t+w+10 r.Size=UDim2.fromOffset(e,v.height)layout()end end)end table.
insert(m,v)r.Activated:Connect(function()dismiss(v)end)v.timer=task.delay(p.
seconds or 5,function()v.timer=nil dismiss(v)end)layout()end function n.destroy(
o)for p,q in table.clone(m)do if q.timer then task.cancel(q.timer)end q.pos:
destroy()q.frame:Destroy()end table.clear(m)end return n end return d end
function a.p()local b=a.cache.p if not b then b={c=__modImpl()}a.cache.p=b end
return b.c end end do local function __modImpl()local b=a.d()local c=a.b()local
d={}local e=34 local f=0.55 local g=340 local h=8 function d.popover(i,j)local k
=i.theme local l={}local m=nil local function close()local n=m if n==nil then
return end m=nil n.catcher:Destroy()n.open=false n.size:to(UDim2.fromOffset(n.
width,0),function()n.size:destroy()n.frame:Destroy()end)if n.disconnectEl then n
.disconnectEl()end end function l.open(n,o,p,q,r)close()local s=j.AbsoluteSize
local t,u=o.AbsolutePosition,o.AbsoluteSize local v=math.clamp(t.X,h,s.X-p-h)
local w=t.Y+u.Y+2 local x=w+q+h>s.Y and t.Y-q-2>h local y=if x then t.Y-q-2 else
math.min(w,s.Y-q-h)local z=b('TextButton',{Name='Catcher',Size=UDim2.fromScale(1
,1),ZIndex=10,Parent=j})local A=b('Frame',{Name='Popover',Position=UDim2.
fromOffset(v,y),Size=UDim2.fromOffset(p,0),BackgroundTransparency=0,
ClipsDescendants=true,ZIndex=11,Active=true,Parent=j})k:paint(A,
'BackgroundColor3','surface')local B=b('UIStroke',{ApplyStrokeMode=Enum.
ApplyStrokeMode.Border,Parent=A})k:paint(B,'Color','lineStrong')local C=b(
'Frame',{Size=UDim2.fromScale(1,1),Parent=A})local D={frame=A,catcher=z,width=p,
open=true,size=c.prop(A,'Size',e)}m=D z.MouseButton1Down:Connect(close)z.
MouseButton2Down:Connect(close)local E={close=close,resize=function(E)if D.open
then D.size:to(UDim2.fromOffset(p,E))end end,onKey=function(E)D.onKey=E end,
onRefresh=function(E)D.onRefresh=E end}r(C,E)D.size:to(UDim2.fromOffset(p,q))end
function l.isOpen(n)return m~=nil end function l.close(n)close()end function l.
key(n,o)if m==nil then return false end if o=='Escape'then close()return true
end if m.onKey then m.onKey(o)return true end return false end return l end
function d.tooltip(i,j)local k=i.theme local l=b('Frame',{Name='Tooltip',
AutomaticSize=Enum.AutomaticSize.XY,BackgroundTransparency=0,Visible=false,
ZIndex=20,Parent=j})k:paint(l,'BackgroundColor3','raised')local m=b('UIStroke',{
ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=l})k:paint(m,'Color',
'lineStrong')b('UIPadding',{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,
10),PaddingTop=UDim.new(0,7),PaddingBottom=UDim.new(0,7),Parent=l})local n=b(
'TextLabel',{AutomaticSize=Enum.AutomaticSize.XY,TextSize=15,TextWrapped=true,
ZIndex=21,Parent=l})b('UISizeConstraint',{MaxSize=Vector2.new(g,400),Parent=n})k
:type(n,'ui')k:paint(n,'TextColor3','text')local o={}local p=nil function o.hide
(q)if p then task.cancel(p)p=nil end l.Visible=false end function o.schedule(q,r
,s)q:hide()p=task.delay(f,function()p=nil if r.Parent==nil then return end n.
Text=s l.Visible=true task.defer(function()if not l.Visible then return end
local t=j.AbsoluteSize local u=l.AbsoluteSize local v=math.clamp(r.
AbsolutePosition.X+12,h,t.X-u.X-h)local w=r.AbsolutePosition.Y+r.AbsoluteSize.Y+
4 local x=if w+u.Y+h>t.Y then r.AbsolutePosition.Y-u.Y-4 else w l.Position=UDim2
.fromOffset(v,x)end)end)end return o end function d.hover(i)local j={}local k=
nil local function clear()local l=k if l then k=nil l:onHover(false)i.tooltip:
hide()end end function j.current(l)return k end function j.enter(l,m)if k==m
then return end clear()k=m m:onHover(true)local n=m.el local o=if n.disabled and
n.disabledTip then n.disabledTip else n.tip if o and o~=''then i.tooltip:
schedule(m.root,o)end end function j.leave(l,m)if k==m then clear()end end j.
clear=clear function j.verify(l,m)local n=k if n==nil then return end local o=n.
root local p,q=o.AbsolutePosition,o.AbsoluteSize local r=m.X>=p.X and m.Y>=p.Y
and m.X<=p.X+q.X and m.Y<=p.Y+q.Y if not r or not o.Visible or o.Parent==nil or
i.popover:isOpen()then clear()end end return j end return d end function a.q()
local b=a.cache.q if not b then b={c=__modImpl()}a.cache.q=b end return b.c end
end do local function __modImpl()local b=a.g()local c={}local d={}d.__index=d
local function decimals(e)local f=string.format('%.10f',e)local g=string.match(f
,'%.(%d-)0*$')return if g then#g else 0 end local function roundTo(e,f)if f<=0
then return e end local g=math.round(e/f)*f return tonumber(string.format('%.'..
decimals(f)..'f',g))or g end c.roundTo=roundTo local function sameList(e,f)if#e
~=#f then return false end for g=1,#e do if e[g]~=f[g]then return false end end
return true end local function sameSet(e,f)for g,h in e do if h and not f[g]then
return false end end for g,h in f do if h and not e[g]then return false end end
return true end local e={toggle=function(e,f)return f==true end,slider=function(
e,f)local g=tonumber(f)if g==nil or g~=g then return nil end local h=e.spec
return math.clamp(roundTo(g,h.step or 1),h.min,h.max)end,dropdown=function(e,f)
local g=e.spec if g.multi then local h={}if type(f)=='table'then for i,j in f do
if type(i)=='number'then h[j]=true elseif j then h[i]=true end end elseif f~=nil
and f~=''then h[f]=true end if not g.keep then for i in h do if not table.find(g
.options,i)then h[i]=nil end end end return h end if f==nil or f==''then return
false end if not table.find(g.options,f)and not g.keep then return nil end
return f end,input=function(e,f)local g=if f==nil then''else tostring(f)local h=
e.spec if h.maxLength and#g>h.maxLength then g=string.sub(g,1,h.maxLength)end if
h.numeric and g~=''and g~='-'and g~='.'and tonumber(g)==nil then return nil end
if h.verify and not h.verify(g)then return nil end return g end,key=function(e,f
)if type(f)=='string'then return{key=f,mode=e.value and e.value.mode or'Toggle',
modifiers={}}end if type(f)~='table'then return nil end local g=e.value or{}
return{key=f.key or f[1]or g.key or'None',mode=f.mode or f[2]or g.mode or
'Toggle',modifiers=f.modifiers or f[3]or g.modifiers or{}}end,color=function(e,f
)if typeof(f)=='Color3'then return{color=f,alpha=e.value and e.value.alpha or 0}
end if type(f)=='table'and typeof(f.color)=='Color3'then return{color=f.color,
alpha=math.clamp(tonumber(f.alpha)or 0,0,1)}end return nil end,label=function(e,
f)return tostring(f)end,stat=function(e,f)return tostring(f)end}local function 
equal(f,g,h)local i=f.kind if i=='dropdown'and f.spec.multi then return sameSet(
g,h)end if i=='key'then return g.key==h.key and g.mode==h.mode and sameList(g.
modifiers,h.modifiers)end if i=='color'then return g.color==h.color and g.alpha
==h.alpha end return g==h end local function unwrap(f,g)if f.kind=='dropdown'and
not f.spec.multi and g==false then return nil end return g end function c.new(f,
g,h,i,j)local k=setmetatable({kind=f,id=g,label=h,spec=i,tip=i.tip,disabled=i.
disabled==true,disabledTip=i.disabledTip,visible=i.visible~=false,saved=i.saved
~=false,changed=b.new()},d)local l=e[f]local m=j if l then m=l(k,j)if m==nil and
f=='slider'then m=i.min end if m==nil and f=='dropdown'then m=false end end k.
value=unwrap(k,m)k.default=k.value return k end function d.set(f,g)local h=e[f.
kind]local i=g if h then i=h(f,g)if i==nil then return false end i=unwrap(f,i)
end local j=f.value if j~=nil and i~=nil and equal(f,j,i)then return false end
if j==nil and i==nil then return false end f.value=i f:notify()return true end
function d.reset(f)local g=f.default if f.kind=='dropdown'and f.spec.multi then
g=table.clone(g)end f:set(g)end local function redraw(f)local g=f._view if g
then g.refresh()end local h=f.host if h and h._view then h._view.refresh()end
end function d.notify(f)redraw(f)f.changed:fire(f.value)end function d.fire(f)f.
changed:fire(f.value)end function d.on(f,g)return f.changed:connect(g)end
function d.setLabel(f,g)if f.label==g then return end f.label=g if f.kind==
'label'then f.value=g local h=f._relayout if h then h()end end redraw(f)end
function d.setTip(f,g)f.tip=g end function d.setDisabled(f,g,h)f.disabled=g==
true f.disabledTip=h or f.disabledTip redraw(f)end function d.setVisible(f,g)if
f.visible==g then return end f.visible=g local h=f._relayout if h then h()end
end function d.setOptions(f,g)local h=f.spec h.options=table.clone(g)if h.multi
then if h.keep then for i,j in f.value do if j and not table.find(h.options,i)
then table.insert(h.options,i)end end else local i=false for j in f.value do if
not table.find(h.options,j)then f.value[j]=nil i=true end end if i then f:
notify()return end end elseif f.value~=nil and not table.find(h.options,f.value)
then if h.keep then table.insert(h.options,f.value)else f.value=nil f:notify()
return end end redraw(f)end function d.isModified(f)if f.kind=='button'or f.kind
=='label'or f.kind=='divider'or f.kind=='stat'then return false end local g,h=f.
value,f.default if g==nil or h==nil then return g~=h end return not equal(f,g,h)
end function d.attach(f,g)local h=f.addons if h==nil then h={}f.addons=h end
table.insert(h,g)g.host=f redraw(f)end function d.shown(f)if not f.visible then
return false end local g=f.guard return g==nil or g()end return c end function a
.r()local b=a.cache.r if not b then b={c=__modImpl()}a.cache.r=b end return b.c
end end do local function __modImpl()local b=a.r()local c={}local d={}d.__index=
d local function add(e,f,g,h,i,j)local k=b.new(f,g or(f..'#'..tostring(e._page:
nextId())),h,i,j)k.section=e k.guard=e._guard e._page:_register(k,g~=nil)table.
insert(e.rows,k)e._page:_invalidate()return k end function d.toggle(e,f,g)local
h=add(e,'toggle',f,g.label or f,g,g.default==true)if g.onChanged then h:on(g.
onChanged)end return h end function d.slider(e,f,g)g.min=g.min or 0 g.max=g.max
or 100 g.step=g.step or 1 if g.decimals==nil then local h=string.format('%.10f',
g.step)local i=string.match(h,'%.(%d-)0*$')g.decimals=if i then#i else 0 end
local h=add(e,'slider',f,g.label or f,g,g.default or g.min)if g.onChanged then h
:on(g.onChanged)end return h end function d.dropdown(e,f,g)g.options=g.options
or{}local h=g.default if h==nil and g.multi then h={}end local i=add(e,
'dropdown',f,g.label or f,g,h)if g.onChanged then i:on(g.onChanged)end return i
end function d.input(e,f,g)local h=add(e,'input',f,g.label or'',g,g.default or''
)if g.onChanged then h:on(g.onChanged)end return h end function d.key(e,f,g)
local h=add(e,'key',f,g.label or f,g,{key=g.default or'None',mode=g.mode or
'Toggle',modifiers=g.modifiers or{}})e._page.window.keys:register(h)return h end
function d.color(e,f,g)local h=add(e,'color',f,g.label or f,g,{color=g.default
or Color3.new(1,1,1),alpha=g.alphaValue or 0})if g.onChanged then h:on(g.
onChanged)end return h end function d.button(e,f,g)local h=if type(g)==
'function'then{onPressed=g}else g h.saved=false local i=add(e,'button',nil,f,h,
nil)if h.onPressed then i:on(h.onPressed)end return i end function d.label(e,f,g
)local h=g or{}h.saved=false return add(e,'label',nil,f,h,f)end function d.stat(
e,f,g)return add(e,'stat',nil,f,{saved=false},tostring(g))end function d.divider
(e,f)return add(e,'divider',nil,f or'',{saved=false},nil)end function d.addKey(e
,f,g,h)local i=b.new('key',g,h.label or f.label,h,{key=h.default or'None',mode=h
.mode or'Toggle',modifiers=h.modifiers or{}})i.section=e local j=i j.toggled=h.
toggled==true e._page:_register(i,true)e._page.window.keys:register(i)f:attach(i
)return i end function d.addColor(e,f,g,h)local i=b.new('color',g,h.label or f.
label,h,{color=h.default or Color3.new(1,1,1),alpha=h.alphaValue or 0})i.section
=e e._page:_register(i,true)f:attach(i)if h.onChanged then i:on(h.onChanged)end
return i end function d.when(e,f,g)local h=e._guard local i=f if h then i=
function()return h()and f()end end local j=setmetatable({rows=e.rows,title=e.
title,_page=e._page,_guard=i,_root=e._root or e},d)for k,l in(g or{})do l:on(
function()e._page:_invalidate()end)end return j end function c.new(e,f)return
setmetatable({title=f,rows={},_page=e,_guard=nil,_root=nil},d)end return c end
function a.s()local b=a.cache.s if not b then b={c=__modImpl()}a.cache.s=b end
return b.c end end do local function __modImpl()local b=a.o()local c=a.d()local
d=a.b()local e=a.s()local f=a.n()local g={}local h=160 local i=2 local j=20
local k=16 local l=28 local m=46 local n=30 local o=148 local p=360 local q=110
local r=18 local s=28 local t={toggle=1,button=1,key=1,color=1,stat=1,slider=2,
dropdown=2,input=2}local u={}u.__index=u local function textHeight(v,w)if v.kind
=='divider'then return 34 end if not v.spec.wrap then return 34 end if v.
_measured then return v._measured end local x=math.max(math.floor(w/7.6),10)
local y=string.gsub(v.label,'<[^>]+>','')return math.ceil(#y/x)*21+12 end
function u.nextId(v)v._ids+=1 return v._ids end function u._register(v,w,x)w.
_relayout=function()v:_invalidate()end v.window:_registerElement(w,v,x)end
function u._invalidate(v)if v._dirty then return end v._dirty=true task.defer(
function()v._dirty=false if not v.destroyed then v:layout()end end)end function
u.section(v,w)local x=e.new(v,w)table.insert(v.sections,x)v:_invalidate()return
x end function u.tabs(v,w)local x=e.new(v,'')x.tabNames=w x.activeTab=1 table.
insert(v.sections,x)local y={}for z,A in w do local B=x:when(function()return x.
activeTab==z end)B.title=A table.insert(y,B)end v:_invalidate()return y end
function u.hero(v,w)v._hero=w v:_invalidate()local x=v._heroView return{set=
function(y,z,A)w.title=z or w.title w.text=A or w.text local B=v._heroView or x
if B then B.refresh()end end}end local function buildHero(v)local w=v.window.ctx
local x=w.theme local y=v._hero local z=c('Frame',{Name='Hero',Parent=v.canvas})
local A=c('Frame',{Size=UDim2.fromOffset(o-16,o-16),BackgroundTransparency=0,
ClipsDescendants=true,Parent=z})x:paint(A,'BackgroundColor3','accent')if y.
userId then c('ImageLabel',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
BorderSizePixel=0,Image=string.format(
'rbxthumb://type=AvatarBust&id=%d&w=420&h=420',y.userId),Parent=A})end local B=
c('TextLabel',{Position=UDim2.fromOffset(o+2,16),Size=UDim2.new(1,-(o+2),0,68),
TextSize=64,TextTruncate=Enum.TextTruncate.AtEnd,Parent=z})x:type(B,'display')x:
paint(B,'TextColor3','text')local C=c('TextLabel',{Position=UDim2.fromOffset(o+2
,88),Size=UDim2.new(1,-(o+2),0,44),TextSize=17,TextWrapped=true,TextYAlignment=
Enum.TextYAlignment.Top,Parent=z})x:type(C,'text')x:paint(C,'TextColor3','muted'
)local D={root=z,refresh=function()B.Text=y.title C.Text=y.text or''end}D.
refresh()return D end local function buildHeader(v,w)local x=v.window.ctx local
y=x.theme local z=c('Frame',{Name='Header',Parent=v.canvas})if w.tabNames then
local A={}local B=0 for C,D in w.tabNames do local E=math.ceil(#D*13)+18 local F
=c('TextButton',{Position=UDim2.fromOffset(B,0),Size=UDim2.new(0,E,1,-6),
TextSize=26,Text=D,TextXAlignment=Enum.TextXAlignment.Left,Parent=z})y:type(F,
'display')A[C]=F F.Activated:Connect(function()w.activeTab=C for G,H in A do y:
paint(H,'TextColor3',if G==w.activeTab then'text'else'faint')end v:_invalidate()
end)y:paint(F,'TextColor3',if C==w.activeTab then'text'else'faint')B+=E end else
local A=c('TextLabel',{Size=UDim2.new(1,0,1,-6),TextSize=26,Text=w.title,Parent=
z})y:type(A,'display')y:paint(A,'TextColor3','text')end return z end function u.
layout(v)local w=v.frame if w==nil then return end local x=v.window.ctx.uiScale(
)local y=w.AbsoluteSize.X/x if y<1 then return end local z=y-2*j local A=math.
max(math.floor((z+i)/(h+i)),2)local B=k local C={}if v._hero then table.insert(C
,{hero=true,x=j,y=B,width=z,height=o})B+=o end for D,E in v.sections do local F=
{}for G,H in E.rows do if H:shown()then table.insert(F,H)end end if#F>0 or E.
tabNames then if E.title~=''or E.tabNames then table.insert(C,{section=E,x=j,y=B
,width=z,height=m})B+=m end local G,H={},0 local function flush()if#G==0 then
return end local I=z-(#G-1)*i local J=j for K,L in G do local M=math.min(t[L.
kind],A)local N=if K==#G then j+z-J else math.floor(I*M/H)table.insert(C,{el=L,x
=J,y=B,width=N,height=f.HEIGHT})J+=N+i end B+=f.HEIGHT+i G,H={},0 end for I,J in
F do local K=t[J.kind]if K==nil then flush()local L=textHeight(J,z)table.insert(
C,{el=J,x=j,y=B,width=z,height=L})B+=L+i else local L=math.min(K,A)if H+L>A then
flush()end table.insert(G,J)H+=L end end flush()B+=n end end local D=B-n+l w.
CanvasSize=UDim2.fromOffset(0,D)v._contentHeight=D v._placements=C v:
_applyPlacements()v:_materialize(true)v:_refreshThumb()end function u.
_applyPlacements(v)local w={}for x,y in v._placements do if y.hero then if v.
_heroView then v._heroView.root.Position=UDim2.fromOffset(y.x,y.y)v._heroView.
root.Size=UDim2.fromOffset(y.width,y.height)end elseif y.section then w[y.
section]=true local z=v._headers[y.section]if z then z.Visible=true z.Position=
UDim2.fromOffset(y.x,y.y)z.Size=UDim2.fromOffset(y.width,y.height)end else w[y.
el]=true local z=v._views[y.el]if z then v:_place(z,y)end end end for x,y in v.
_headers do if not w[x]then y.Visible=false end end for x,y in v._views do if
not w[x]then y.root.Visible=false end end end function u._place(v,w,x)local y=w.
root local z=UDim2.fromOffset(x.x,x.y)local A=y.Visible and y.Position~=z and v.
active y.Visible=true y.Size=UDim2.fromOffset(x.width,x.height)if A then if w.
_slide==nil then w._slide=f.own(w,d.prop(y,'Position',s))end w._slide:to(z)
elseif w._slide then w._slide:snap(z)else y.Position=z end end function u.
_materialize(v,w)local x=v.frame local y=v._placements if x==nil or y==nil or
not v.active then return end local z=x.CanvasPosition.Y if not w and v._lastSync
and math.abs(z-v._lastSync)<p/3 then return end v._lastSync=z local A=v.window.
ctx.uiScale()local B,C=z-p,z+x.AbsoluteSize.Y/A+p for D,E in y do local F=E.y if
F+E.height>=B and F<=C then if E.hero then if v._heroView==nil then local G=
buildHero(v)G.root.Position=UDim2.fromOffset(E.x,F)G.root.Size=UDim2.fromOffset(
E.width,E.height)v._heroView=G end elseif E.section then if v._headers[E.section
]==nil then local G=buildHeader(v,E.section)G.Position=UDim2.fromOffset(E.x,F)G.
Size=UDim2.fromOffset(E.width,E.height)v._headers[E.section]=G end elseif v.
_views[E.el]==nil then local G,H=xpcall(b.build,debug.traceback,v.window.ctx,E.
el)if G then H.root.Position=UDim2.fromOffset(E.x,F)H.root.Size=UDim2.
fromOffset(E.width,E.height)H.root.Parent=v.canvas v._views[E.el]=H else warn(
'sottUI: tile '..tostring(E.el.id)..' failed: '..tostring(H))end end end end end
function u._refreshThumb(v)local w=v.thumb if w==nil then return end local x=v.
window.ctx.uiScale()local y=v.frame.AbsoluteSize.Y/x local z=v._contentHeight or
0 if z<=y+1 or not v.active then w.Visible=false return end w.Visible=true local
A=math.max(y*y/z,40)local B=y-A local C=v.frame.CanvasPosition.Y/math.max(z-y,1)
w.Size=UDim2.new(0,3,0,A)w.Position=UDim2.new(1,-6,0,C*B)end function u.scrollTo
(v,w,x)local y=v.frame if y==nil then return end local z=v.window.ctx.uiScale()
local A=math.max((v._contentHeight or 0)-y.AbsoluteSize.Y/z,0)local B=math.
clamp(w,0,A)v._scrollTarget=B if x then v._scroll:snap(B)else v._scroll:to(B)end
end function u.wheel(v,w)if v.frame==nil or v.frame.ScrollingEnabled then return
end v:scrollTo((v._scrollTarget or v.frame.CanvasPosition.Y)-w*q)end function u.
rowY(v,w)if v._placements==nil then v:layout()end for x,y in v._placements or{}
do if y.el==w then return y.y end end return nil end function u.viewOf(v,w)
return v._views[w]end function u.mount(v,w)if v.frame then return end local x=v.
window.ctx local y=c('ScrollingFrame',{Name=v.name,Size=UDim2.fromScale(1,1),
Visible=false,ScrollingEnabled=x.touch,Parent=w})local z=c('Frame',{Name=
'Canvas',Size=UDim2.fromScale(1,1),Parent=y})local A=c('Frame',{Name='Thumb',
BackgroundTransparency=0,Visible=false,ZIndex=5,Parent=w})x.theme:paint(A,
'BackgroundColor3','lineStrong')v.frame=y v.canvas=z v.thumb=A v._scroll=d.new(0
,r,function(B)y.CanvasPosition=Vector2.new(0,B)end)y:GetPropertyChangedSignal(
'CanvasPosition'):Connect(function()v:_materialize()v:_refreshThumb()end)local B
=0 y:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()local C=y.
AbsoluteSize.X if C~=B then B=C v:_invalidate()else v:_materialize(true)v:
_refreshThumb()end end)end function u.setActive(v,w)v.active=w if v.frame then v
.frame.Visible=w if not w then v.thumb.Visible=false end end if w then v:layout(
)end end function u.destroy(v)v.destroyed=true for w,x in v._views do x.destroy(
)end v._views={}if v._scroll then v._scroll:destroy()end if v.frame then v.frame
:Destroy()v.thumb:Destroy()end end function g.new(v,w)return setmetatable({name=
w,window=v,sections={},active=false,destroyed=false,_ids=0,_dirty=false,_headers
={},_views={},_placements=nil},u)end return g end function a.t()local b=a.cache.
t if not b then b={c=__modImpl()}a.cache.t=b end return b.c end end do local 
function __modImpl()local b=a.d()local c=a.b()local d=a.k()local e={}local f=560
local g=46 local h=68 local i=7 local j=34 function e.new(k,l,m,n)local o=k.
theme local p={}local q=false local r,s,t,u local v={}local w={}local x=1 local 
function close()if not q then return end q=false r:Destroy()local y,z=s,t z:to(
UDim2.fromOffset(f,0),function()z:destroy()y:Destroy()end)table.clear(w)end
local function draw()for y,z in w do local A=v[y]if A then z.root.Visible=true z
.name.Text=A.label z.where.Text=A._pageName..(if A.section and A.section.title~=
''then' / '..A.section.title else'')z.root.BackgroundTransparency=if y==x then 0
else 1 o:paint(z.name,'TextColor3',if y==x then'onAccent'else'text')o:paint(z.
where,'TextColor3',if y==x then'onAccent'else'muted')else z.root.Visible=false
end end local y=math.min(#v,i)local z=h+(if y>0 then y*g+10 else 0)t:to(UDim2.
fromOffset(f,z))end local function run(y)if y==nil then return end close()if y.
kind=='toggle'and not y.disabled then y:set(not y.value)k.notify({title=y.label,
text=if y.value then'On'else'Off',seconds=2})elseif y.kind=='button'and not y.
disabled then y:fire()else n(y)end end local function query()local y=u.Text if y
==''then v={}else v=d.rank(y,m(),function(z)return z.label..' '..(z._pageName or
'')end,i)end x=1 draw()end function p.toggle(y)if q then close()return end q=
true local z=l.AbsoluteSize r=b('TextButton',{Size=UDim2.fromScale(1,1),ZIndex=
40,Parent=l})r.MouseButton1Down:Connect(close)s=b('Frame',{Name='Palette',
Position=UDim2.fromOffset(math.floor((z.X-f)/2),math.floor(z.Y*0.2)),Size=UDim2.
fromOffset(f,0),BackgroundTransparency=0,ClipsDescendants=true,Active=true,
ZIndex=41,Parent=l})o:paint(s,'BackgroundColor3','surface')local A=b('UIStroke',
{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=s})o:paint(A,'Color',
'lineStrong')t=c.prop(s,'Size',j)u=b('TextBox',{Position=UDim2.fromOffset(18,0),
Size=UDim2.new(1,-36,0,h),TextSize=36,Text='',PlaceholderText='Find a setting',
ZIndex=42,Parent=s})o:type(u,'display')o:paint(u,'TextColor3','text')o:paint(u,
'PlaceholderColor3','faint')for B=1,i do local C=b('TextButton',{Position=UDim2.
fromOffset(6,h+(B-1)*g+2),Size=UDim2.new(1,-12,0,g),Visible=false,ZIndex=42,
Parent=s})o:paint(C,'BackgroundColor3','accent')local D=b('TextLabel',{Position=
UDim2.fromOffset(12,0),Size=UDim2.new(0.55,-12,1,0),TextSize=16,TextTruncate=
Enum.TextTruncate.AtEnd,ZIndex=43,Parent=C})o:type(D,'text',true)o:paint(D,
'TextColor3','text')local E=b('TextLabel',{AnchorPoint=Vector2.new(1,0),Position
=UDim2.new(1,-12,0,0),Size=UDim2.new(0.45,-12,1,0),TextSize=16,TextTruncate=Enum
.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=43,Parent=C}
)o:type(E,'text')o:paint(E,'TextColor3','faint')w[B]={root=C,name=D,where=E}C.
MouseEnter:Connect(function()if x~=B then x=B draw()end end)C.Activated:Connect(
function()run(v[B])end)end u:GetPropertyChangedSignal('Text'):Connect(query)u.
FocusLost:Connect(function(B)if B then run(v[x])end end)query()u:CaptureFocus()
end function p.isOpen(y)return q end p.close=close function p.key(y,z)if not q
then return false end if z=='Escape'then close()return true end if z=='Down'or z
=='Up'then if#v>0 then x=math.clamp(x+(if z=='Down'then 1 else-1),1,#v)draw()end
return true end return false end return p end return e end function a.u()local b
=a.cache.u if not b then b={c=__modImpl()}a.cache.u=b end return b.c end end do
local function __modImpl()local b=a.g()local c={}local function rgb(d)return
Color3.fromRGB(bit32.band(bit32.rshift(d,16),255),bit32.band(bit32.rshift(d,8),
255),bit32.band(d,255))end local d={base=rgb(0x7100d),surface=rgb(0x141c18),
raised=rgb(0x1e2b25),line=rgb(0x1a2d27),lineStrong=rgb(0x2f4a40),text=rgb(
0xebe8da),muted=rgb(0x9db0a5),faint=rgb(0x5f756b),accent=rgb(0x7ee0c4),
accentHover=rgb(0x9bebd4),accentDim=rgb(0x16362d),onAccent=rgb(0xb1a13),danger=
rgb(0xe5604d)}local e='rbxasset://fonts/families/BuilderSans.json'local f=
'rbxasset://fonts/families/RobotoCondensed.json'local g={}g.__index=g function c
.defaults()return table.clone(d)end function c.new(h)local i=(c.defaults())for j
,k in(h or{})do i[j]=k end local j={tokens=i,fonts={text=e,display=f},changed=b.
new(),_paints=setmetatable({},{__mode='k'}),_types=setmetatable({},{__mode='k'})
}return((setmetatable(j,g)))end function g.paint(h,i,j,k)local l=h._paints[i]if
l==nil then l={}h._paints[i]=l end l[j]=k i[j]=h.tokens[k]end function g.face(h,
i,j)if i=='display'then return Font.new(h.fonts.display,Enum.FontWeight.
ExtraBold)end return Font.new(h.fonts.text,if j then Enum.FontWeight.Medium else
Enum.FontWeight.Regular)end function g.type(h,i,j,k)h._types[i]={family=j,medium
=k==true}i.FontFace=h:face(j,k)end function g.forget(h,i)h._paints[i]=nil h.
_types[i]=nil end function g.apply(h,i)for j,k in i do h.tokens[j]=k end for j,k
in h._paints do for l,m in k do pcall(function()j[l]=h.tokens[m]end)end end h.
changed:fire()end function g.setFonts(h,i,j)h.fonts.text=i or h.fonts.text h.
fonts.display=j or h.fonts.display for k,l in h._types do pcall(function()k.
FontFace=h:face(l.family,l.medium)end)end end return c end function a.v()local b
=a.cache.v if not b then b={c=__modImpl()}a.cache.v=b end return b.c end end do
local function __modImpl()local b=a.a()local c=a.c()local d=a.e()local e=a.h()
local f=a.i()local g=a.o()local h=a.f()local i=a.d()local j=a.b()local k=a.p()
local l=a.q()local m=a.t()local n=a.u()local o=a.s()local p=a.g()local q=a.v()
local r={}local s='main'local t=
[[https://raw.githubusercontent.com/interestng/sottUI/%s/fonts/]]local u=44
local v=70 local w=u+v local x=50 local y=Vector2.new(900,640)local z=Vector2.
new(560,400)local A=20 local B=26 local C=15 local D=24 local E=26 local F=12
local G={}G.__index=G local function randomName()local H=table.create(F)for I=1,
F do H[I]=string.char(math.random(97,122))end return table.concat(H)end local 
function encode(H)return b.service('HttpService'):JSONEncode(H)end local 
function decode(H)local I,J=pcall(function()return b.service('HttpService'):
JSONDecode(H)end)return if I then J else nil end function G._registerElement(H,I
,J,K)I._pageName=J.name I._page=J if K then if H.elements[I.id]then error(
'sottUI: element id used twice: '..I.id,3)end H.elements[I.id]=I end if I.kind~=
'divider'and I.kind~='label'and I.kind~='stat'then table.insert(H.ordered,I)end
end function G._syncMarker(H,I)local J=H._navItems[H.current]if J==nil then
return end local K=H._scale.Scale local L=H._navList local M=(J.AbsolutePosition
.X-L.AbsolutePosition.X)/K local N=J.AbsoluteSize.X/K local O=UDim2.fromOffset(M
,v-8)local P=UDim2.fromOffset(N,6)if I then H._markerAt:snap(O)H._markerSize:
snap(P)else H._markerAt:to(O)H._markerSize:to(P)end local Q=H._navClip.
AbsoluteSize.X/K local R=L.AbsoluteSize.X/K local S=0 if R>Q then S=-math.clamp(
M-20,0,R-Q+20)end if I then H._navScroll:snap(S)else H._navScroll:to(S)end end
function G.page(H,I)local J=m.new(H,I)table.insert(H.pages,J)local K=#H.pages
local L=H.ctx.theme local M=i('TextButton',{Name=I,AutomaticSize=Enum.
AutomaticSize.X,Size=UDim2.new(0,0,1,-10),TextSize=x,Text=I,LayoutOrder=K,Parent
=H._navList})L:type(M,'display')L:paint(M,'TextColor3','faint')H._navItems[K]=M
M.Activated:Connect(function()H:show(K)end)M.MouseEnter:Connect(function()if H.
current~=K then L:paint(M,'TextColor3','muted')end end)M.MouseLeave:Connect(
function()if H.current~=K then L:paint(M,'TextColor3','faint')end end)M:
GetPropertyChangedSignal('AbsoluteSize'):Connect(function()H:_syncMarker(not H.
isOpen)end)J:mount(H._pageHost)if H.current==nil then H:show(K,true)end return J
end function G.show(H,I,J)local K=H.pages[I]if K==nil or H.current==I then
return end H.ctx.hover.clear()H.ctx.popover:close()local L=H.ctx.theme local M=H
.pages[H.current]if M then M:setActive(false)L:paint(H._navItems[H.current],
'TextColor3','faint')end local N=H.current==nil or I>H.current H.current=I L:
paint(H._navItems[I],'TextColor3','text')K:setActive(true)H:_syncMarker(J)H:
_saveState()if J then return end local O=if N then 1 else-1 H._pageSlide:snap(
UDim2.fromOffset(E*O,0))H._pageSlide:to(UDim2.new())H._wipe.Visible=true H.
_wipeEdge.AnchorPoint=Vector2.new(if N then 1 else 0,0)H._wipeEdge.Position=
UDim2.fromScale(if N then 1 else 0,0)H._wipeAt:snap(UDim2.fromScale(0,0))H.
_wipeAt:to(UDim2.fromScale(-1.02*O,0),function()H._wipe.Visible=false end)end
function G.showPage(H,I)for J,K in H.pages do if K.name==I then H:show(J)return
end end end function G.reveal(H,I)local J=I._page if J==nil then return end if
not H.isOpen then H:setOpen(true)end H:showPage(J.name)local K=I.host or I J:
layout()local L=J:rowY(K)if L then J:scrollTo(L-60)task.delay(0.16,function()
local M=J:viewOf(K)if M and M.root.Parent then M:pressed(true)task.delay(0.28,
function()if M.root.Parent then M:pressed(false)end end)end end)end end function
G._targetSize(H)return if H.collapsed then UDim2.new(1,0,0,u)else UDim2.
fromScale(1,1)end function G.setOpen(H,I)if H.isOpen==I or H.destroyed then
return end H.isOpen=I H.ctx.hover.clear()H.ctx.popover:close()H._palette.close()
H.ctx.tooltip:hide()H._shutterEdge.Visible=true if I then H._root.Visible=true H
._modal.Visible=true H:_guardCursor(true)H._shutter:to(H:_targetSize(),function(
)H._shutterEdge.Visible=false end)else H._modal.Visible=false H:_guardCursor(
false)H._shutter:to(UDim2.new(1,0,0,0),function()H._shutterEdge.Visible=false if
not H.isOpen then H._root.Visible=false end end)end H.visibilityChanged:fire(I)
end function G._guardCursor(H,I)local J=b.service('UserInputService')if I then H
._gameCursor=J.MouseIconEnabled J.MouseIconEnabled=true if H._cursorGuard==nil
then H._cursorGuard=J:GetPropertyChangedSignal('MouseIconEnabled'):Connect(
function()if not J.MouseIconEnabled then H._gameCursor=false J.MouseIconEnabled=
true end end)end else if H._cursorGuard then H._cursorGuard:Disconnect()H.
_cursorGuard=nil end if H._gameCursor~=nil then J.MouseIconEnabled=H._gameCursor
H._gameCursor=nil end end end function G.toggle(H)H:setOpen(not H.isOpen)end
function G.collapse(H,I)H.collapsed=I H._shutter:to(H:_targetSize())H._grip.
Visible=not I H:_saveState()end function G.notify(H,I)if H.destroyed then return
end H.ctx.notify(I)end function G.setTheme(H,I)H.ctx.theme:apply(I)end function
G.setScale(H,I)H._scale.Scale=math.clamp(I,0.7,1.5)H:_clamp()H:_saveState()end
function G.setSubtitle(H,I)H._subtitle.Text=I end function G._clamp(H)local I=H.
_gui.AbsoluteSize local J=H.size*H._scale.Scale local K=math.clamp(H.position.X,
0,math.max(I.X-J.X,0))local L=math.clamp(H.position.Y,0,math.max(I.Y-J.Y,0))H.
position=Vector2.new(K,L)H._root.Position=UDim2.fromOffset(K,L)end function G.
_saveState(H)local I=H._files if I==nil or H._stateFile==nil or H._stateQueued
then return end H._stateQueued=true task.delay(0.5,function()H._stateQueued=
false if H.destroyed then return end local J=H.pages[H.current]I.write(H.
_stateFile,encode({x=H.position.X,y=H.position.Y,w=H.size.X,h=H.size.Y,page=J
and J.name,scale=H._scale.Scale,collapsed=H.collapsed}))end)end function G.
restorePage(H)local I=H._savedPage if I then H._savedPage=nil for J,K in H.pages
do if K.name==I then H:show(J,true)return end end end end function G.dialog(H,I,
J)if H.destroyed then return false end local K=H.ctx local L=K.theme local M=H.
_layer local N=I.width or 460 local O=I.maxHeight or 340 local P=72 local Q=i(
'TextButton',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
BackgroundColor3=Color3.new(0,0,0),ZIndex=50,Parent=M})local R=j.prop(Q,
'BackgroundTransparency',22)R:to(0.4)local S=i('Frame',{AnchorPoint=Vector2.new(
0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(N,0),
BackgroundTransparency=0,ClipsDescendants=true,Active=true,ZIndex=51,Parent=M})L
:paint(S,'BackgroundColor3','base')local T=i('UIStroke',{ApplyStrokeMode=Enum.
ApplyStrokeMode.Border,Parent=S})L:paint(T,'Color','lineStrong')local U=i(
'TextLabel',{Position=UDim2.fromOffset(20,16),Size=UDim2.new(1,-40,0,40),
TextSize=36,Text=I.title or'',ZIndex=52,Parent=S})L:type(U,'display')L:paint(U,
'TextColor3','text')local V=60 local W=I.text if W and W~=''then local X=i(
'TextLabel',{Position=UDim2.fromOffset(20,V),Size=UDim2.new(1,-40,0,22),
AutomaticSize=Enum.AutomaticSize.Y,TextSize=16,TextWrapped=true,Text=W,ZIndex=52
,Parent=S})L:type(X,'text')L:paint(X,'TextColor3','muted')V+=22+math.floor(#W/52
)*22+12 end local X=i('ScrollingFrame',{Position=UDim2.fromOffset(20,V),Size=
UDim2.new(1,-40,0,0),ScrollBarThickness=3,ZIndex=52,Parent=S})L:paint(X,
'ScrollBarImageColor3','lineStrong')local Y=false local aa={window=H,name=
'Dialog',nextId=function()H._dialogIds+=1 return H._dialogIds end,_register=
function(Z,_,aa)_._pageName='Dialog'if aa then H.elements[_.id]=_ end end,
_invalidate=function()end}local Z=o.new(aa,'')local _,ab=xpcall(J,debug.
traceback,Z)if not _ then warn('sottUI: dialog build failed: '..tostring(ab))end
local ac={}local ad=0 for ae,af in Z.rows do if af:shown()then local ag=g.build(
K,af)local ah=if af.kind=='label'or af.kind=='divider'then 34 else P ag.root.
Position=UDim2.fromOffset(0,ad)ag.root.Size=UDim2.new(1,0,0,ah)ag.root.Parent=X
ad+=ah+2 table.insert(ac,ag)end end X.CanvasSize=UDim2.fromOffset(0,ad)local ae=
math.min(ad,O)X.Size=UDim2.new(1,-40,0,ae)local af=V+ae+12 local ag=i(
'TextButton',{Position=UDim2.fromOffset(20,af),Size=UDim2.new(1,-40,0,54),
BackgroundTransparency=0,TextSize=28,Text=I.done or'Done',ZIndex=52,Parent=S})L:
type(ag,'display')L:paint(ag,'BackgroundColor3','accent')L:paint(ag,'TextColor3'
,'onAccent')local ah=af+54+20 local ai=j.prop(S,'Size',A+6)ai:to(UDim2.
fromOffset(N,ah))local function close()if Y then return end Y=true H.
_dialogClose=nil Q.Active=false for aj,ak in Z.rows do if H.elements[ak.id]==ak
then H.elements[ak.id]=nil end end if I.onClose then task.spawn(I.onClose)end R:
to(1,function()R:destroy()Q:Destroy()end)ai:to(UDim2.fromOffset(N,0),function()
for aj,ak in ac do ak.destroy()end ai:destroy()S:Destroy()end)end H._dialogClose
=close Q.MouseButton1Down:Connect(close)ag.Activated:Connect(close)return true
end function G.find(aa,ab)return aa.elements[ab]end function G.snapshot(aa)local
ab={}for ac,ad in aa.elements do if ad.saved then local ae=ad.value if ad.kind==
'color'then ae={hex=ae.color:ToHex(),alpha=ae.alpha}elseif ad.kind=='key'then ae
={key=ae.key,mode=ae.mode,modifiers=ae.modifiers,toggled=ad.toggled==true}end ab
[ac]=ae end end return ab end function G.restore(aa,ab)for ac,ad in ab do local
ae=aa.elements[ac]if ae and ae.saved then if ae.kind=='color'and type(ad)==
'table'then ae:set({color=Color3.fromHex(ad.hex or'ffffff'),alpha=ad.alpha})
elseif ae.kind=='key'and type(ad)=='table'then ae:set(ad)ae.toggled=ad.toggled==
true else ae:set(ad)end end end end function G.destroy(aa)if aa.destroyed then
return end aa.destroyed=true aa:_guardCursor(false)aa.ctx.notifications:destroy(
)for ab,ac in aa.pages do ac:destroy()end aa.ctx.input:destroy()aa._maid:clean()
aa.visibilityChanged:clear()if aa._registry and aa._registry.current==aa then aa
._registry.current=nil end end local function headerButton(aa,ab,ac,ad)local ae=
i('TextButton',{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,ac,0.5,0),
Size=UDim2.fromOffset(38,u),BackgroundTransparency=1,Parent=ab})aa.theme:paint(
ae,'BackgroundColor3','raised')local af=ad(ae,'muted')af.AnchorPoint=Vector2.
new(0.5,0.5)af.Position=UDim2.fromScale(0.5,0.5)local ag=j.prop(ae,
'BackgroundTransparency',28)ae.MouseEnter:Connect(function()ag:to(0)end)ae.
MouseLeave:Connect(function()ag:to(1)end)return ae end function r.new(aa)local
ab=aa._registry if ab and ab.current then ab.current:destroy()end local ac=h.
new()local ad=q.new(aa.theme)local ae=e.new()local af=b.service(
'UserInputService')local ag=af.TouchEnabled and not af.MouseEnabled local ah=i(
'ScreenGui',{Name=randomName(),IgnoreGuiInset=true,ResetOnSpawn=false,
ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=aa.displayOrder or 10000
})b.protect(ah)ah.Parent=b.guiParent()ac:add(ah)local ai=b.files()local aj=aa.
folder or'sottui'local ak=aa.stateFile or(aj..'/window.json')local H=nil if ai
then ai.folder(aj)local I=ai.read(ak)H=I and decode(I)end if type(H)~='table'
then H={}end local I=ah.AbsoluteSize local J=Vector2.new(math.clamp(tonumber(H.w
)or y.X,z.X,math.max(I.X,z.X)),math.clamp(tonumber(H.h)or y.Y,z.Y,math.max(I.Y,z
.Y)))local K=tonumber(H.scale)or(if I.X<800 then 0.8 else 1)local L=Vector2.new(
tonumber(H.x)or math.floor((I.X-J.X*K)/2),tonumber(H.y)or math.floor((I.Y-J.Y*K)
/2))local M=i('Frame',{Name='Root',Size=UDim2.fromOffset(J.X,J.Y),Position=UDim2
.fromOffset(L.X,L.Y),Parent=ah})local N=i('UIScale',{Scale=K,Parent=M})local O=
i('Frame',{Name='Clip',Size=UDim2.new(1,0,0,0),BackgroundTransparency=0,
ClipsDescendants=true,Active=true,Parent=M})ad:paint(O,'BackgroundColor3','base'
)local P=i('Frame',{Name='Layer',Size=UDim2.fromScale(1,1),ZIndex=100,Parent=ah}
)local Q=i('TextButton',{Name='Modal',Size=UDim2.fromOffset(0,0),Modal=true,
Visible=false,Parent=M})local R=i('TextButton',{Name='Bar',Size=UDim2.new(1,0,0,
u),Parent=O})local S=i('TextLabel',{AutomaticSize=Enum.AutomaticSize.X,Position=
UDim2.fromOffset(20,0),Size=UDim2.fromOffset(0,u),TextSize=22,Text=aa.title or
'sottoro',Parent=R})ad:type(S,'display')ad:paint(S,'TextColor3','accent')local T
=i('TextLabel',{AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromOffset(0,u),
TextSize=16,Text=aa.subtitle or'',Parent=R})ad:type(T,'text')ad:paint(T,
'TextColor3','muted')local function fitSubtitle()T.Position=UDim2.fromOffset(20+
S.AbsoluteSize.X/N.Scale+12,0)end S:GetPropertyChangedSignal('AbsoluteSize'):
Connect(fitSubtitle)task.defer(fitSubtitle)local U=i('Frame',{Name='NavClip',
Position=UDim2.fromOffset(0,u),Size=UDim2.new(1,0,0,v),ClipsDescendants=true,
Parent=O})local V=i('Frame',{Name='NavRail',Position=UDim2.fromOffset(20,0),Size
=UDim2.new(1,-20,1,0),Parent=U})local W=i('Frame',{Name='NavList',AutomaticSize=
Enum.AutomaticSize.X,Size=UDim2.new(0,0,1,0),Parent=V})i('UIListLayout',{
FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,24),SortOrder=
Enum.SortOrder.LayoutOrder,Parent=W})local X=i('Frame',{Name='Marker',Size=UDim2
.fromOffset(0,6),Position=UDim2.fromOffset(0,v-8),BackgroundTransparency=0,
ZIndex=2,Parent=V})ad:paint(X,'BackgroundColor3','accent')local Y=i('Frame',{
Position=UDim2.new(0,0,0,w-2),Size=UDim2.new(1,0,0,2),BackgroundTransparency=0,
Parent=O})ad:paint(Y,'BackgroundColor3','line')local Z=i('Frame',{Name='Body',
Position=UDim2.fromOffset(0,w),Size=UDim2.new(1,0,1,-w),ClipsDescendants=true,
Parent=O})local _=i('Frame',{Name='Pages',Size=UDim2.fromScale(1,1),Parent=Z})
local al=i('Frame',{Name='Wipe',Size=UDim2.fromScale(1,1),BackgroundTransparency
=0,Visible=false,ZIndex=8,Parent=Z})ad:paint(al,'BackgroundColor3','base')local
am=i('Frame',{Size=UDim2.new(0,8,1,0),BackgroundTransparency=0,ZIndex=9,Parent=
al})ad:paint(am,'BackgroundColor3','accent')local an=i('Frame',{AnchorPoint=
Vector2.new(0,1),Position=UDim2.fromScale(0,1),Size=UDim2.new(1,0,0,4),
BackgroundTransparency=0,Visible=false,ZIndex=12,Parent=O})ad:paint(an,
'BackgroundColor3','accent')local ao=i('TextButton',{Name='Grip',AnchorPoint=
Vector2.new(1,1),Position=UDim2.fromScale(1,1),Size=UDim2.fromOffset(20,20),
ZIndex=6,Parent=O})for ap,aq in{{UDim2.new(1,-3,1,-3),UDim2.fromOffset(10,2)},{
UDim2.new(1,-3,1,-3),UDim2.fromOffset(2,10)}}do local ar=i('Frame',{AnchorPoint=
Vector2.new(1,1),Position=aq[1],Size=aq[2],BackgroundTransparency=0,ZIndex=7,
Name='Tick'..ap,Parent=ao})ad:paint(ar,'BackgroundColor3','lineStrong')end local
ap=setmetatable({ctx=nil,pages={},elements={},ordered={},current=nil,isOpen=
false,collapsed=H.collapsed==true,destroyed=false,size=J,position=L,
visibilityChanged=p.new(),_maid=ac,_gui=ah,_root=M,_clip=O,_layer=P,_modal=Q,
_scale=N,_subtitle=T,_navClip=U,_navList=W,_navItems={},_pageHost=_,_wipe=al,
_wipeEdge=am,_shutterEdge=an,_grip=ao,_files=ai,_stateFile=ak,_savedPage=H.page,
_dialogIds=0,_registry=ab},G)if ab then ab.current=ap end local aq={theme=ad,
input=ae,touch=ag,glyph=d.new(ad),uiScale=function()return N.Scale end,
setScrollLocked=function(aq)local ar=ap.pages[ap.current]if ar and ar.frame and
ag then ar.frame.ScrollingEnabled=not aq end end}ap.ctx=aq aq.popover=l.popover(
aq,P)aq.tooltip=l.tooltip(aq,P)aq.hover=l.hover(aq)aq.notifications=k.new(aq,P)
aq.notify=function(ar)aq.notifications:show(ar)end ap.keys=f.new(ae,b,function()
return ap.isOpen end)aq.keys=ap.keys ap._markerAt=ac:add(j.prop(X,'Position',B))
ap._markerSize=ac:add(j.prop(X,'Size',B))ap._navScroll=ac:add(j.new(0,B,function
(ar)W.Position=UDim2.fromOffset(ar,0)X.Position=UDim2.new(0,X.Position.X.Offset,
0,v-8)end))ap._pageSlide=ac:add(j.prop(_,'Position',D))ap._wipeAt=ac:add(j.prop(
al,'Position',C))ap._shutter=ac:add(j.prop(O,'Size',A))ap._palette=n.new(aq,P,
function()return ap.ordered end,function(ar)ap:reveal(ar)end)local ar=
headerButton(aq,R,0,function(ar,as)return aq.glyph.cross(ar,as)end)ar.Activated:
Connect(function()ap:setOpen(false)end)local as=headerButton(aq,R,-38,function(
as,at)return aq.glyph.dash(as,at)end)as.Activated:Connect(function()ap:collapse(
not ap.collapsed)end)local at=i('TextButton',{AnchorPoint=Vector2.new(1,0.5),
Position=UDim2.new(1,-84,0.5,0),Size=UDim2.fromOffset(66,u),TextSize=16,Text=
'Search',TextXAlignment=Enum.TextXAlignment.Right,Parent=R})ad:type(at,'text',
true)ad:paint(at,'TextColor3','muted')at.MouseEnter:Connect(function()ad:paint(
at,'TextColor3','text')end)at.MouseLeave:Connect(function()ad:paint(at,
'TextColor3','muted')end)at.Activated:Connect(function()ap._palette:toggle()end)
R.InputBegan:Connect(function(au)local av=au.UserInputType if av~=Enum.
UserInputType.MouseButton1 and av~=Enum.UserInputType.Touch then return end
local aw=if av==Enum.UserInputType.Touch then ae:at(au)else ae:pointer()local ax
=ap.position ae:capture(function(ay)ap.position=ax+(ay-aw)ap:_clamp()ap:
_saveState()end)end)ao.InputBegan:Connect(function(au)local av=au.UserInputType
if av~=Enum.UserInputType.MouseButton1 and av~=Enum.UserInputType.Touch then
return end local aw=if av==Enum.UserInputType.Touch then ae:at(au)else ae:
pointer()local ax=ap.size ae:capture(function(ay)local az=N.Scale local aA=ax+(
ay-aw)/az local aB=(ah.AbsoluteSize-ap.position)/az ap.size=Vector2.new(math.
clamp(aA.X,z.X,math.max(aB.X,z.X)),math.clamp(aA.Y,z.Y,math.max(aB.Y,z.Y)))M.
Size=UDim2.fromOffset(math.floor(ap.size.X),math.floor(ap.size.Y))ap:_saveState(
)end)end)ae.moved:connect(function(au)aq.hover:verify(au)end)ae.wheel:connect(
function(au)if not ap.isOpen or aq.popover:isOpen()or ap._palette:isOpen()then
return end local av=ap.pages[ap.current]if av==nil or av.frame==nil then return
end local aw=ae:pointer()local ax,ay=av.frame.AbsolutePosition,av.frame.
AbsoluteSize if aw.X>=ax.X and aw.Y>=ax.Y and aw.X<=ax.X+ay.X and aw.Y<=ax.Y+ay.
Y then av:wheel(au)end end)ae.keyDown:connect(function(au,av)if au.UserInputType
~=Enum.UserInputType.Keyboard then return end local aw=au.KeyCode.Name if ap.
_palette:key(aw)or aq.popover:key(aw)then return end if aw=='Escape'and ap.
_dialogClose then ap._dialogClose()return end if av or ae:typing()then return
end if ap.isOpen and aw=='K'then if af:IsKeyDown(Enum.KeyCode.LeftControl)or af:
IsKeyDown(Enum.KeyCode.RightControl)then ap._palette:toggle()end end end)ac:add(
ah:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()ap:_clamp()end))ac
:add(ad.changed:connect(function()for au,av in ap.pages do for aw,ax in av.
_views do pcall(ax.refresh)end end end))local au=o.new({window=ap,nextId=
function()return 0 end,_register=function(au,av,aw)if aw then ap.elements[av.id]
=av end av._pageName=''end,_invalidate=function()end},'')ap.menuKey=au:key(
'__menu',{label='Menu',default=aa.key or'RightShift',mode='Toggle',saved=false,
onPress=function()ap:toggle()end})local av=b.service('RunService')j.setAttach(
function(aw)return av.PreRender:Connect(aw)end)ap:_clamp()if aa.fonts~=false and
ai then ac:add(task.defer(function()local aw=aa.fontTag or s local ax=c.load(aj
..'/fonts',string.format(t,aw),encode)if not ap.destroyed and(ax.text or ax.
display)then ad:setFonts(ax.text,ax.display)end end))end if aa.autoShow~=false
then task.defer(function()ap:setOpen(true)end)end return ap end function r.
setVersion(aa)s=aa end return r end function a.w()local aa=a.cache.w if not aa
then aa={c=__modImpl()}a.cache.w=aa end return aa.c end end end local aa=a.a()
local ab=a.b()local ac=a.w()local ad='0.1.0'local function registry()local ae=aa
.global('getgenv')local af=if type(ae)=='function'then ae()else _G local ag=af.
__sottui if type(ag)~='table'then ag={current=nil}af.__sottui=ag end return ag
end local ae={version=ad,motion=ab}ac.setVersion('v'..ad)function ae.window(af)
local ag=table.clone(af or{})ag._registry=registry()return ac.new(ag)end
function ae.current()return registry().current end return ae