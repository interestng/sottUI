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
local b={}local c=0.1 local d=0.001 local e=0.001 local f=1/20 local g={}local h
=0 local i=nil local j=nil local k=1 local l={number={encode=function(l)return{l
}end,decode=function(l)return l[1]end,rest={d}},Color3={encode=function(l)return
{l.R,l.G,l.B}end,decode=function(l)return Color3.new(math.clamp(l[1],0,1),math.
clamp(l[2],0,1),math.clamp(l[3],0,1))end,rest={e,e,e}},UDim2={encode=function(l)
return{l.X.Scale,l.X.Offset,l.Y.Scale,l.Y.Offset}end,decode=function(l)return
UDim2.new(l[1],l[2],l[3],l[4])end,rest={d,c,d,c}},Vector2={encode=function(l)
return{l.X,l.Y}end,decode=function(l)return Vector2.new(l[1],l[2])end,rest={c,c}
}}local function stopLoop()if i then i:Disconnect()i=nil end end local function 
advance(m,n)local o=m.speed*k local p=m.zeta local q,r,s,t=m.x,m.v,m.g,m.rest
local u=true if p>=1 then local v=math.exp(-o*n)for w=1,m.n do local x=q[w]-s[w]
local y=(r[w]+o*x)*n q[w]=s[w]+(x+y)*v r[w]=(r[w]-o*y)*v local z=t[w]if math.
abs(q[w]-s[w])>z or math.abs(r[w])>z*o then u=false end end else local v=o*math.
sqrt(1-p*p)local w=math.exp(-p*o*n)local x,y=math.cos(v*n),math.sin(v*n)for z=1,
m.n do local A=q[z]-s[z]local B=(r[z]+p*o*A)/v local C=w*(A*x+B*y)r[z]=w*((B*v-p
*o*A)*x-(A*v+p*o*B)*y)q[z]=s[z]+C local D=t[z]if math.abs(C)>D or math.abs(r[z])
>D*o then u=false end end end if u then for v=1,m.n do q[v]=s[v]r[v]=0 end end
return u end function b.step(m)m=math.min(m,f)local n=1 while n<=h do local o=g[
n]local p=true if not o.dead then p=advance(o,m)local q,r=pcall(o.write,o.x)if
not q then warn('sottUI: motion write failed: '..tostring(r))o.dead=true end end
if p or o.dead then o.live=false g[n]=g[h]g[h]=nil h-=1 local q=o.done o.done=
nil if q and not o.dead then local r,s=pcall(q)if not r then warn(
'sottUI: motion callback failed: '..tostring(s))end end else n+=1 end end if h==
0 then stopLoop()end end local function wake(m)if m.live or m.dead then return
end m.live=true h+=1 g[h]=m if i==nil and j then i=j(b.step)end end local m={}m.
__index=m function m.snap(n,o)if n.dead then return end n.target=o n.done=nil
local p=n.encode(o)for q=1,n.n do n.g[q]=p[q]n.x[q]=p[q]n.v[q]=0 end n.write(n.x
)end function m.to(n,o,p)if n.dead then return end if k<=0 then n:snap(o)if p
then p()end return end n.target=o n.done=p local q=n.encode(o)local r=not n.live
for s=1,n.n do if q[s]~=n.x[s]then r=false end n.g[s]=q[s]end if r then n.done=
nil if p then p()end return end wake(n)end function m.moving(n)return n.live end
function m.destroy(n)n.dead=true n.done=nil end function b.new(n,o,p,q)local r=l
[typeof(n)]assert(r,'motion: cannot animate '..typeof(n))local s=r.encode(n)
local t={}for u=1,#s do t[u]=0 end local u=r.decode local v={x=s,v=t,g=table.
clone(s),rest=r.rest,n=#s,speed=o,zeta=q or 1,encode=r.encode,write=function(v)
p(u(v))end,live=false,dead=false,target=n}return((setmetatable(v,m)))end
function b.prop(n,o,p,q)return b.new(n[o],p,function(r)n[o]=r end,q)end function
b.setAttach(n)j=n end function b.setSpeedScale(n)k=n end function b.activeCount(
)return h end function b.running()return i~=nil end function b.reset()table.
clear(g)h=0 stopLoop()end return b end function a.b()local b=a.cache.b if not b
then b={c=__modImpl()}a.cache.b=b end return b.c end end do local function 
__modImpl()local b=a.a()local c={}local function warnf(d)warn('sottUI compat: '
..d)end local function protect(d,...)if type(d)~='function'then return end local
e,f=xpcall(d,debug.traceback,...)if not e then warnf('callback failed: '..
tostring(f))end end local function isEmpty(d)return type(d)~='string'or string.
gsub(d,'%s','')==''end local d={}d.__index=d function d.RunChanged(e,...)if e.
Disabled then return end local f=e.Value if select('#',...)>0 then protect(e.
Callback,...)protect(e.Changed,...)else protect(e.Callback,f)protect(e.Changed,f
)end end function d.OnChanged(e,f)e.Changed=f end function d.SetVisible(e,f)e.
Visible=f e._el:setVisible(f)end function d.SetDisabled(e,f)e.Disabled=f==true e
._el:setDisabled(e.Disabled)if e._lib then e._lib:_rulesChanged()end end
function d.SetText(e,f)e.Text=f e._el:setLabel(f)end function d.Update(e)end
local function class()local e=setmetatable({},{__index=d})e.__index=e return e
end local e=class()local f=class()local g=class()local h=class()local i=class()
local j=class()local k=class()local l=class()local function sync(m,n)m._el:on(
function()m.Value=n(m._el)m:RunChanged()if m._lib then m._lib:_rulesChanged()end
end)end function e.SetValue(m,n)if not m._el:set(n==true)then m:RunChanged()end
for o,p in m._pickers do p._el.toggled=m.Value end end function f.SetValue(m,n)m
._el:set(n)end function f.SetMax(m,n)m.Max=n m._el.spec.max=n m._el:set(m._el.
value)m._el:setLabel(m.Text)end function f.SetMin(m,n)m.Min=n m._el.spec.min=n m
._el:set(m._el.value)m._el:setLabel(m.Text)end function g.SetValue(m,n)if not m.
_el:set(n)then m:RunChanged()end end function h.SetValue(m,n)if type(n)==
'string'and m.SpecialType=='Player'then local o=b.service('Players'):
FindFirstChild(n)n=o end if not m._el:set(n)then m:RunChanged()end end function
h.SetValues(m,n)m._el:setOptions(n)m.Values=m._el.spec.options end function h.
AddValues(m,n)local o=table.clone(m._el.spec.options)if type(n)=='table'then for
p,q in n do table.insert(o,q)end else table.insert(o,n)end m:SetValues(o)end
function h.GetActiveValues(m)if m.Multi then local n={}for o,p in m.Value do if
p then table.insert(n,o)end end return n end return if m.Value then 1 else 0 end
function i.SetValueRGB(m,n,o)local p=if m._hasAlpha then o or 0 else 0 if not m.
_el:set({color=n,alpha=p})then m:RunChanged(m.Value)end end function i.SetValue(
m,n,o)if typeof(n)=='Color3'then m:SetValueRGB(n,o)elseif type(n)=='table'then m
:SetValueRGB(Color3.fromHSV(n[1],n[2],n[3]),o)end end function j.SetValue(m,n)if
type(n)=='string'then n={n}end m._el:set({key=n[1],mode=n[2],modifiers=n[3]or{}}
)end function j.GetState(m)return m._lib.window.keys:state(m._el)end function j.
OnClick(m,n)m.Clicked=n end function k.SetText(m,n)m.Text=n m._el:setLabel(n)end
function l.SetText(m,n)m.Text=n m._el:setLabel(n)end local m={}m.__index=m local 
function register(n,o,p,q)n[o][p]=q q._idx=p if n._dialogIndexes then table.
insert(n._dialogIndexes,{shelf=o,idx=p})end return q end local function common(n
,o,p,q)return{Type=o,Text=q.Text,Disabled=q.Disabled==true,Visible=q.Visible~=
false,Tooltip=q.Tooltip,Callback=q.Callback,Changed=q.Changed,_el=p,_lib=n}end
local function tips(n,o)o.tip=n.Tooltip o.disabled=n.Disabled==true o.
disabledTip=n.DisabledTooltip o.visible=n.Visible~=false return o end function m
.AddToggle(n,o,p)local q=n._section:toggle(o,tips(p,{label=p.Text or o,default=p
.Default==true}))local r=(setmetatable(common(n._lib,'Toggle',q,p),e))r.Value=q.
value r._pickers={}r._box=n sync(r,function(s)for t,u in r._pickers do u._el.
toggled=s.value end return s.value end)return register(n._lib,'Toggles',o,r)end
m.AddCheckbox=m.AddToggle function m.AddSlider(n,o,p)local q=tonumber(p.Rounding
)or 0 local r=p.FormatDisplayValue local s local t=tips(p,{label=p.Text or o,min
=p.Min,max=p.Max,step=10^-q,decimals=q,suffix=p.Suffix,default=p.Default,format=
if r then function(t,u)return r(s,u)end else nil})local u=n._section:slider(o,t)
s=setmetatable(common(n._lib,'Slider',u,p),f)s.Value=u.value s.Min,s.Max,s.
Rounding=p.Min,p.Max,q sync(s,function(v)return v.value end)return register(n.
_lib,'Options',o,s)end function m.AddInput(n,o,p)local q=n._section:input(o,
tips(p,{label=p.Text or'',default=p.Default or'',placeholder=p.Placeholder,
numeric=p.Numeric==true,finished=p.Finished==true or p.VerifyValue~=nil,
maxLength=p.MaxLength,verify=p.VerifyValue}))local r=(setmetatable(common(n._lib
,'Input',q,p),g))r.Value=q.value r.Numeric=p.Numeric==true sync(r,function(s)
return s.value end)return register(n._lib,'Options',o,r)end local function 
playerList(n)local o=b.service('Players')local p={}for q,r in o:GetPlayers()do
if not(n and r==o.LocalPlayer)then table.insert(p,r)end end return p end
function m.AddDropdown(n,o,p)local q=p.SpecialType=='Player'local r=if q then
playerList(p.ExcludeLocalPlayer==true)else(p.Values or{})local s=p.Multi==true
local t=p.Default if type(t)=='number'then t=r[t]end if s and type(t)=='string'
then t={t}end local u=p.FormatDisplayValue local v=n._section:dropdown(o,tips(p,
{label=p.Text or o,options=r,multi=s,default=t,searchable=p.Searchable==true,
allowNull=p.AllowNull==true or q,display=function(v)local w=if q then v.Name
else v if u then local x,y=pcall(u,w)if x and y~=nil then return tostring(y)end
end return tostring(w)end}))local w=(setmetatable(common(n._lib,'Dropdown',v,p),
h))w.Value=v.value w.Values=v.spec.options w.Multi=s w.SpecialType=p.SpecialType
sync(w,function(x)return x.value end)if q then local x=b.service('Players')local 
function refresh()w:SetValues(playerList(p.ExcludeLocalPlayer==true))end table.
insert(n._lib._connections,x.PlayerAdded:Connect(refresh))table.insert(n._lib.
_connections,x.PlayerRemoving:Connect(function()task.defer(refresh)end))end
return register(n._lib,'Options',o,w)end function m.AddButton(n,o,p)local q=if
type(o)=='table'then o else{Text=o,Func=p}local r=n._section:button(q.Text or'',
tips(q,{confirm=q.DoubleClick==true}))local s=(setmetatable(common(n._lib,
'Button',r,q),l))s.Func=q.Func r:on(function()protect(s.Func)end)return s end
local function buildLabel(n,o,p)local q=if type(o)=='table'then o else{Text=o,
DoesWrap=p}local r=n._section:label(tostring(q.Text or''),{wrap=q.DoesWrap==true
or p==true})local s=(setmetatable(common(n._lib,'Label',r,q),k))s.TextLabel={}s.
_box=n return s end function m.AddLabel(n,o,p,q)if type(p)=='table'then local r=
buildLabel(n,p)register(n._lib,'Options',o,r)return r end local r=q return
buildLabel(n,o,p)end function m.AddDivider(n,o)local p=if type(o)=='table'then o
.Text else o n._section:divider(p)end function m.AddBlank()end function m.
AddDependencyBox(n)local o={}local p=n._lib local q=n._section:when(function()
for q,r in o do local s,t=r[1],r[2]if s.Disabled then return false end local u=s
.Value if s.Type=='Dropdown'and type(u)=='table'then if not u[t]then return
false end elseif u~=t then return false end end return true end)local r=(
setmetatable({_section=q,_lib=p},m))function r.SetupDependencies(s,t)o=t n.
_section._page:_invalidate()end return r end function m.SetCollapsed()end local 
function attachColor(n,o,p,q)local r=q.Transparency~=nil local s=o._box._section
local t=s:addColor(o._el,p,{label=q.Title or o.Text or p,default=q.Default or
Color3.new(1,1,1),alpha=r,alphaValue=if r then q.Transparency else 0})local u=(
setmetatable(common(n,'ColorPicker',t,q),i))u.Value=t.value.color u.Transparency
=t.value.alpha u._hasAlpha=r t:on(function()u.Value=t.value.color u.Transparency
=t.value.alpha u:RunChanged(u.Value)end)return register(n,'Options',p,u)end
local function keyArgument(n)local o=({MB1='MouseButton1',MB2='MouseButton2',MB3
='MouseButton3'})[n]if o then return(Enum.UserInputType)[o]end local p,q=pcall(
function()return(Enum.KeyCode)[n]end)return if p then q else nil end local 
function attachKey(n,o,p,q)local r=o._box._section local s=q.SyncToggleState==
true local t=if s then{'Toggle','Hold'}else q.Modes or{'Always','Toggle','Hold'}
local u=q.Mode or'Toggle'local v local w=r:addKey(o._el,p,{label=q.Text or o.
Text or p,default=q.Default or'None',mode=u,modes=t,modifiers=q.DefaultModifiers
or{},chipless=q.NoUI==true,noMouse=false,onPress=function(w,x)v.Toggled=x if n.
ToggleKeybind==v then n.window:toggle()return end if s and o.Type=='Toggle'and
not o.Disabled then if w.value.mode=='Toggle'then o:SetValue(x)elseif w.value.
mode=='Hold'then o:SetValue(true)end end protect(v.Clicked,x)protect(v.Callback,
x)end,onRelease=function(w)if s and o.Type=='Toggle'and w.value.mode=='Hold'and
not o.Disabled then o:SetValue(false)end end})v=setmetatable(common(n,
'KeyPicker',w,q),j)v.Value=w.value.key v.Mode=w.value.mode v.Modifiers=w.value.
modifiers v.Modes=t v.SyncToggleState=s v.NoUI=q.NoUI==true v.Toggled=false v.
ChangedCallback=q.ChangedCallback w:on(function()local x=w.value v.Value=x.key v
.Mode=x.mode v.Modifiers=x.modifiers v:Update()local y=keyArgument(x.key)
protect(v.ChangedCallback,y,x.modifiers)protect(v.Changed,y,x.modifiers)end)if o
.Type=='Toggle'and s then table.insert(o._pickers,v)w.toggled=o.Value end return
register(n,'Options',p,v)end function e.AddColorPicker(n,o,p)attachColor(n._lib,
n,o,p)return n end function e.AddKeyPicker(n,o,p)attachKey(n._lib,n,o,p)return n
end k.AddColorPicker=e.AddColorPicker k.AddKeyPicker=e.AddKeyPicker local n={}n.
__index=n local function makeBox(o,p)return setmetatable({_section=p,_lib=o},m)
end local function sectionBox(o,p)local q=o._page:section(p)local r=makeBox(o.
_lib,q)return r end function n.AddLeftGroupbox(o,p)return sectionBox(o,p)end n.
AddRightGroupbox=n.AddLeftGroupbox function n.AddGroupbox(o,p)return sectionBox(
o,p.Name)end local function tabbox(o)local p=o._page:tabset()local q=o._lib
return{AddTab=function(r,s)return makeBox(q,p:tab(s))end}end n.AddLeftTabbox=
tabbox n.AddRightTabbox=tabbox local o={}o.__index=o function o.AddTab(p,q,r)
local s=if type(q)=='table'then q.Name else q local t=p._lib.window:page(s)if s
=='Home'then local u=b.service('Players').LocalPlayer if u then t:hero({userId=u
.UserId,title=u.DisplayName,text=p._footer})end end local u=setmetatable({_page=
t,_lib=p._lib},n)p._lib.Tabs[s]=u return u end function o.OpenDialog(p,q,r)local
s=p._lib local t=s.window local u=s._dialogIndexes return t:dialog({title=q.
title,text=q.description,done=q.done,maxHeight=q.maxHeight,onClose=function()
local v=s._dialogOwned for w,x in v or{}do s[x.shelf][x.idx]=nil end s.
_dialogOwned=nil if q.onClose then q.onClose()end end},function(v)s.
_dialogIndexes={}r(makeBox(s,v))s._dialogOwned=s._dialogIndexes s._dialogIndexes
=u end)end local function newSaveManager(p)local q={Folder='ObsidianLibSettings'
,SubFolder='',Ignore={},AutoloadConfig=nil,Library=p}local function http()return
b.service('HttpService')end local function settings()local r=q.Folder..
'/settings'if q.SubFolder~=''then r..='/'..q.SubFolder end return r end local 
function globalFn(r)return b.global(r)end local function configPath(r)return
settings()..'/'..r..'.json'end local function ensure()local r=b.files()if r then
r.folder(settings())r.folder(q.Folder..'/themes')end end local function 
configExists(r)local s=b.files()return s~=nil and s.exists(configPath(r))end
function q.SetLibrary(r)end function q.SetFolder(r,s)q.Folder=s ensure()end
function q.SetSubFolder(r,s)q.SubFolder=s ensure()end function q.
SetIgnoreIndexes(r,s)for t,u in s do q.Ignore[u]=true end end function q.
IgnoreThemeSettings(r)q:SetIgnoreIndexes({'ThemeManager_Preset',
'ThemeManager_Scale','ThemeManager_Motion'})end function q.RefreshConfigList(r)
local s=globalFn('listfiles')if type(s)~='function'then return{}end ensure()
local t,u=pcall(s,settings())if not t or type(u)~='table'then return{}end local
v={}for w,x in u do local y=string.gsub(x,'\\','/')local z=string.match(y,
'([^/]+)%.[^/.]+$')if z and z~='autoload'then table.insert(v,z)end end table.
sort(v)return v end local r={Toggle=function(r)return{value=r.Value}end,Slider=
function(r)return{value=tostring(r.Value)}end,Dropdown=function(r)local s=r.
Value if typeof(s)=='Instance'then s=s.Name end return{value=s,multi=r.Multi}end
,ColorPicker=function(r)return{value=r.Value:ToHex(),transparency=r.Transparency
}end,KeyPicker=function(r)return{mode=r.Mode,key=r.Value,modifiers=r.Modifiers,
toggled=r.Toggled}end,Input=function(r)return{text=r.Value}end}local s={Toggle=
function(s,t)if s.Value==t.value then s:RunChanged()else s:SetValue(t.value)end
end,Slider=function(s,t)if s.Value==t.value then s:RunChanged()else s:SetValue(t
.value)end end,Dropdown=function(s,t)if s.Value==t.value then s:RunChanged()else
s:SetValue(t.value)end end,ColorPicker=function(s,t)s:SetValueRGB(Color3.
fromHex(t.value),t.transparency)end,KeyPicker=function(s,t)s:SetValue({t.key,t.
mode,t.modifiers})if t.mode=='Toggle'and t.toggled~=nil then s.Toggled=t.toggled
s._el.toggled=t.toggled s:Update()end end,Input=function(s,t)if type(t.text)~=
'string'then return end if s.Value==t.text then s:RunChanged()else s:SetValue(t.
text)end end}function q.SaveJSON(t,u)local v={}local function collect(w)for x,y
in w do local z=r[y.Type]if z and not q.Ignore[x]then local A=z(y)A.type=y.Type
A.idx=x table.insert(v,A)end end end collect(p.Toggles)collect(p.Options)local w
,x=pcall(function()return http():JSONEncode({timestamp=os.date(
'%d.%m.%Y %H:%M:%S'),name=u or'',objects=v})end)if not w then return'',false,
'Failed to encode data'end return x,true end function q.Save(t,u)if isEmpty(u)or
string.lower(u)=='autoload'then return false,'Invalid config name provided'end
ensure()local v,w,x=q:SaveJSON(u)if not w then return false,x end local y=b.
files()if y==nil or not y.write(configPath(u),v)then return false,
'Failed to write config file'end return true end function q.LoadJSON(t,u)if
isEmpty(u)then return false,'No JSON provided'end local v,w=pcall(function()
return http():JSONDecode(u)end)if not v or type(w)~='table'or type(w.objects)~=
'table'then return false,'Failed to decode config data'end for x,y in w.objects
do local z=s[y.type]if z and not q.Ignore[y.idx]then task.defer(function()local
A=p.Toggles[y.idx]or p.Options[y.idx]if A and A.Type==y.type then local B,C=
pcall(z,A,y)if not B then warnf('config value '..tostring(y.idx)..' failed: '..
tostring(C))end end end)end end return true end function q.Load(t,u)if isEmpty(u
)then return false,'No config is selected'end local v=b.files()local w=v and v.
read(configPath(u))if w==nil then return false,'Config file does not exist'end
return q:LoadJSON(w)end function q.Delete(t,u)if isEmpty(u)then return false,
'No config is selected'end if not configExists(u)then return false,
'Config file does not exist'end local v=globalFn('delfile')local w,x=pcall(v,
configPath(u))if not w then return false,'Failed to delete config file: '..
tostring(x)end if u==q.AutoloadConfig then q:DeleteAutoLoadConfig()end return
true end local function autoloadPath()return settings()..'/autoload.txt'end
function q.GetAutoloadConfig(t)ensure()local u=b.files()local v=u and u.read(
autoloadPath())if v==nil then return'none',false,'Autoload config is not set'end
if not configExists(v)then return'none',false,'Config file not found'end q.
AutoloadConfig=v return v,true end function q.SaveAutoloadConfig(t,u)if isEmpty(
u)then return false,'No config is selected'end if not configExists(u)then return
false,'Config does not exist'end local v=b.files()if v==nil or not v.write(
autoloadPath(),u)then return false,'Failed to write the autoload file'end q.
AutoloadConfig=u return true end function q.DeleteAutoLoadConfig(t)local u=b.
files()if u==nil or not u.exists(autoloadPath())then return false,
'Autoload config is not set'end local v=globalFn('delfile')local w,x=pcall(v,
autoloadPath())if not w then return false,tostring(x)end q.AutoloadConfig=nil
return true end function q.LoadAutoloadConfig(t)local u,v,w=q:GetAutoloadConfig(
)if not v or w then if w~='Autoload config is not set'then p:Notify(string.
format('Failed to load autoload config: %s',tostring(w)))end return end local x,
y=q:Load(u)if not x then p:Notify(string.format(
'Failed to load autoload config: %s',tostring(y)))return end p:Notify(string.
format('Loaded config %q',u))end function q.BuildConfigSection(t,u)local v=u:
AddGroupbox({Name='Configs'})local w=v:AddInput('SaveManager_ConfigName',{Text=
'Name',Placeholder='New config'})local x=v:AddDropdown('SaveManager_ConfigList',
{Text='Saved',Values=q:RefreshConfigList(),AllowNull=true,FormatDisplayValue=
function(x)return if x==q.AutoloadConfig then x..' (autoload)'else tostring(x)
end})q.Ignore['SaveManager_ConfigName']=true q.Ignore['SaveManager_ConfigList']=
true local function refresh()x:SetValues(q:RefreshConfigList())end local 
function selected()local y=x.Value if isEmpty(y)then p:Notify(
'Pick a config first')return nil end return y end local function report(y,z,A)p:
Notify(if y then A else tostring(z))end v:AddButton('Create',function()local y=w
.Value if isEmpty(y)then p:Notify('Give the config a name first')return end
local z,A=q:Save(y)report(z,A,string.format('Created %q',y))refresh()end)v:
AddButton({Text='Load',Func=function()local y=selected()if y then local z,A=q:
Load(y)report(z,A,string.format('Loaded %q',y))end end})v:AddButton({Text=
'Overwrite',DoubleClick=true,Func=function()local y=selected()if y then local z,
A=q:Save(y)report(z,A,string.format('Saved over %q',y))end end})v:AddButton({
Text='Delete',DoubleClick=true,Func=function()local y=selected()if y then local
z,A=q:Delete(y)report(z,A,string.format('Deleted %q',y))x:SetValue(nil)refresh()
end end})v:AddButton({Text='Load at start',Func=function()local y=selected()if y
then local z,A=q:SaveAutoloadConfig(y)report(z,A,string.format(
'%q loads at start',y))refresh()end end})v:AddButton({Text=
'Load nothing at start',Func=function()local y,z=q:DeleteAutoLoadConfig()report(
y,z,'No config loads at start')refresh()end})v:AddButton('Refresh list',refresh)
return v end return q end local function derive(p)local q,r,s=p:ToHSV()return{
accent=p,accentHover=Color3.fromHSV(q,r*0.8,math.min(s*1.08,1)),accentDim=Color3
.fromHSV(q,math.min(r*1.2,1),0.2)}end local p={Mint=Color3.fromHex('7EE0C4'),
Moss=Color3.fromHex('C5ECAE'),Lichen=Color3.fromHex('E9DEAA'),Ember=Color3.
fromHex('F0A35A'),Sky=Color3.fromHex('7AB8E0'),Bone=Color3.fromHex('EBE8DA')}
local q={'Mint','Moss','Lichen','Ember','Sky','Bone'}local function 
newThemeManager(r)local s={Folder='ObsidianLibSettings'}local function 
defaultPath()return s.Folder..'/themes/default.txt'end function s.SetLibrary(t)
end function s.SetFolder(t,u)s.Folder=u local v=b.files()if v then v.folder(u..
'/themes')end end function s.SaveDefault(t,u)local v=b.files()if v then v.write(
defaultPath(),u)end end function s.ApplyTheme(t,u)local v=p[u]if v then r.window
:setTheme(derive(v))r.Scheme.AccentColor=v end end function s.ApplyToTab(t,u)
local v=u:AddGroupbox({Name='Look'})local w=b.files()local x=w and w.read(
defaultPath())local y=if x and p[x]then x else'Mint'v:AddDropdown(
'ThemeManager_Preset',{Text='Color',Values=q,Default=y,Callback=function(z)if z
then s:ApplyTheme(z)s:SaveDefault(z)end end})v:AddSlider('ThemeManager_Scale',{
Text='Size',Min=70,Max=150,Default=math.round(r.window._scale.Scale*100),Suffix=
'%',Rounding=0,Callback=function(z)r.window:setScale(z/100)end})s:ApplyTheme(y)
return v end return s end function c.new(r)local s=false local t=setmetatable({
Toggles={},Options={},Tabs={},Toggled=false,ScreenGui=nil,Scheme={AccentColor=
Color3.fromHex('7EE0C4'),BackgroundColor=Color3.fromHex('07100D'),MainColor=
Color3.fromHex('141C18'),OutlineColor=Color3.fromHex('1A2D27'),FontColor=Color3.
fromHex('EBE8DA')},ShowToggleFrameInKeybinds=true,IsSottUI=true,_connections={},
_unloads={}},{})function t._rulesChanged(u)if s or u.window==nil then return end
s=true task.defer(function()s=false if u.window==nil or u.window.destroyed then
return end for v,w in u.window.pages do w:_invalidate()end end)end function t.
CreateWindow(u,v)local w=r.window({title=v.Title,subtitle=v.Footer,folder=v.
Folder,stateFile=v.StateFile,autoShow=v.AutoShow~=false})u.window=w u.ScreenGui=
w._gui u.Toggled=v.AutoShow~=false w.visibilityChanged:connect(function(x)u.
Toggled=x end)local x=setmetatable({_lib=u,_footer=v.Footer},o)u.Window=x return
x end function t.Notify(u,v,w)if u.window==nil then return end if type(v)==
'table'then u.window:notify({title=v.Title,text=v.Description,seconds=v.Time or
w})else u.window:notify({text=tostring(v),seconds=w})end end function t.Toggle(u
,v)if u.window then if v==nil then u.window:toggle()else u.window:setOpen(v)end
end end function t.SafeCallback(u,v,...)protect(v,...)end function t.OnUnload(u,
v)table.insert(u._unloads,v)end function t.Unload(u)for v,w in u._unloads do
protect(w)end for v,w in u._connections do w:Disconnect()end u._connections={}if
u.window then u.window:destroy()u.window=nil end u.ScreenGui=nil u.Toggled=false
end getmetatable(t).__newindex=function(u,v,w)rawset(u,v,w)if v=='ToggleKeybind'
and u.window and u.window.menuKey then u.window.keys:unregister(u.window.menuKey
)end end return{Library=t,SaveManager=newSaveManager(t),ThemeManager=
newThemeManager(t)}end return c end function a.c()local b=a.cache.c if not b
then b={c=__modImpl()}a.cache.c=b end return b.c end end do local function 
__modImpl()local b=a.a()local c={}local d={text={name='SottUIText',faces={{name=
'Regular',weight=400,file='text-400.ttf'},{name='Medium',weight=500,file=
'text-500.ttf'}}},display={name='SottUIDisplay',faces={{name='ExtraBold',weight=
800,file='display-800.ttf'}}}}local e=10000 local function family(f,g,h,i,j)
local k={}for l,m in h.faces do local n=g..'/'..m.file local o=f.read(n)if o==
nil or#o<e then local p=b.fetch(i..m.file)if p==nil or#p<e then return nil end
if not f.write(n,p)then return nil end end local p=f.asset(n)if p==nil then
return nil end table.insert(k,{name=m.name,weight=m.weight,style='normal',
assetId=p})end local l=g..'/'..h.name..'.json'if not f.write(l,j({name=h.name,
faces=k}))then return nil end return f.asset(l)end function c.load(f,g,h)local i
=b.files()if i==nil or b.global('getcustomasset')==nil then return{}end i.
folder(f)local j={}local k,l=pcall(function()j.text=family(i,f,d.text,g,h)j.
display=family(i,f,d.display,g,h)end)if not k then warn(
'sottUI: fonts unavailable: '..tostring(l))end return j end return c end
function a.d()local b=a.cache.d if not b then b={c=__modImpl()}a.cache.d=b end
return b.c end end do local function __modImpl()local b={Frame={
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
return make end function a.e()local b=a.cache.e if not b then b={c=__modImpl()}a
.cache.e=b end return b.c end end do local function __modImpl()local b=a.e()
local c={}local function stroke(d,e,f,g,h,i,j)local k=b('Frame',{AnchorPoint=
Vector2.new(0.5,0.5),Position=UDim2.fromOffset(i,j),Size=UDim2.fromOffset(g,2),
Rotation=h,BackgroundTransparency=0,Parent=d})e:paint(k,'BackgroundColor3',f)
return k end function c.new(d)local e={}function e.chevron(f,g)local h=b('Frame'
,{Size=UDim2.fromOffset(12,12),Parent=f})stroke(h,d,g,7,45,3.6,6)stroke(h,d,g,7,
-45,8.4,6)return h end function e.cross(f,g)local h=b('Frame',{Size=UDim2.
fromOffset(12,12),Parent=f})stroke(h,d,g,13,45,6,6)stroke(h,d,g,13,-45,6,6)
return h end function e.dash(f,g)local h=b('Frame',{Size=UDim2.fromOffset(12,12)
,Parent=f})stroke(h,d,g,12,0,6,6)return h end return e end return c end function
a.f()local b=a.cache.f if not b then b={c=__modImpl()}a.cache.f=b end return b.c
end end do local function __modImpl()local b={}b.__index=b local function 
dispose(c)local d=typeof(c)if d=='RBXScriptConnection'then c:Disconnect()elseif
d=='Instance'then c:Destroy()elseif d=='function'then c()elseif d=='thread'then
task.cancel(c)elseif d=='table'then local e=c.destroy or c.Destroy or c.
Disconnect if e then e(c)end end end function b.add(c,d)table.insert(c._items,d)
return d end function b.clean(c)local d=c._items c._items={}for e=#d,1,-1 do
local f,g=pcall(dispose,d[e])if not f then warn('sottUI: cleanup failed: '..
tostring(g))end end end b.destroy=b.clean return{new=function()return((
setmetatable({_items={}},b)))end}end function a.g()local b=a.cache.g if not b
then b={c=__modImpl()}a.cache.g=b end return b.c end end do local function 
__modImpl()local b={}b.__index=b local c=function(c)warn(c)end function b.
connect(d,e)local f=table.clone(d._list)table.insert(f,e)d._list=f return
function()local g=table.clone(d._list)local h=table.find(g,e)if h then table.
remove(g,h)d._list=g end end end function b.fire(d,...)for e,f in d._list do
local g,h=xpcall(f,debug.traceback,...)if not g then c(
'sottUI: listener failed: '..tostring(h))end end end function b.clear(d)d._list=
{}end return{new=function()return((setmetatable({_list={}},b)))end,setReporter=
function(d)c=d end}end function a.h()local b=a.cache.h if not b then b={c=
__modImpl()}a.cache.h=b end return b.c end end do local function __modImpl()
local b=a.a()local c=a.g()local d=a.h()local e={}local f={}f.__index=f function
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
end function a.i()local b=a.cache.i if not b then b={c=__modImpl()}a.cache.i=b
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
if n==p then n=nil end for q,r in j do local s=r.value if s.key==p and s.mode==
'Hold'and r.spec.onRelease then r.spec.onRelease(r)end end end)return i end
return b end function a.j()local b=a.cache.j if not b then b={c=__modImpl()}a.
cache.j=b end return b.c end end do local function __modImpl()local b=a.e()local
c={}local d=256 local e=148 local f=14 local g=10 local h=12 local i=(function()
local i={}for j=0,6 do table.insert(i,ColorSequenceKeypoint.new(j/6,Color3.
fromHSV((j/6)%1,1,1)))end return ColorSequence.new(i)end)()local function hex(j)
return string.format('%02X%02X%02X',math.round(j.R*255),math.round(j.G*255),math
.round(j.B*255))end local function parseHex(j)local k=string.gsub(j,'#','')if
not string.match(k,'^%x%x%x%x%x%x$')then return nil end return Color3.fromRGB((
tonumber(string.sub(k,1,2),16)),(tonumber(string.sub(k,3,4),16)),(tonumber(
string.sub(k,5,6),16)))end c.hex=hex c.parseHex=parseHex local function open(j,k
,l)local m=j.theme local n=k.spec.alpha==true local o=h+e+g+f+(if n then g+f
else 0)+g+28+h j.popover:open(l,d,o,function(p,q)local r=k.value local s,t,u=r.
color:ToHSV()local v=r.alpha local w=b('TextButton',{Position=UDim2.fromOffset(h
,h),Size=UDim2.new(1,-2*h,0,e),BackgroundTransparency=0,Parent=p})b('UIGradient'
,{Transparency=NumberSequence.new(0,1),Color=ColorSequence.new(Color3.new(1,1,1)
),Parent=b('Frame',{Size=UDim2.fromScale(1,1),BackgroundTransparency=0,
BackgroundColor3=Color3.new(1,1,1),Parent=w,ZIndex=1})})local x=b('Frame',{Size=
UDim2.fromScale(1,1),BackgroundTransparency=0,BackgroundColor3=Color3.new(0,0,0)
,ZIndex=2,Parent=w})b('UIGradient',{Rotation=90,Transparency=NumberSequence.new(
1,0),Parent=x})local y=b('Frame',{AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.
fromOffset(10,10),BackgroundTransparency=1,ZIndex=3,Parent=w})b('UICorner',{
CornerRadius=UDim.new(1,0),Parent=y})b('UIStroke',{Color=Color3.new(1,1,1),
Thickness=1.5,Parent=y})local z=h+e+g local A=b('TextButton',{Position=UDim2.
fromOffset(h,z),Size=UDim2.new(1,-2*h,0,f),BackgroundTransparency=0,
BackgroundColor3=Color3.new(1,1,1),Parent=p})b('UIGradient',{Color=i,Parent=A})
local B=b('Frame',{AnchorPoint=Vector2.new(0.5,0),Size=UDim2.new(0,3,1,0),
BackgroundTransparency=0,BackgroundColor3=Color3.new(1,1,1),ZIndex=2,Parent=A})z
+=f local C,D=nil,nil if n then z+=g C=b('TextButton',{Position=UDim2.
fromOffset(h,z),Size=UDim2.new(1,-2*h,0,f),BackgroundTransparency=0,Parent=p})D=
b('Frame',{AnchorPoint=Vector2.new(0.5,0),Size=UDim2.new(0,3,1,0),
BackgroundTransparency=0,BackgroundColor3=Color3.new(1,1,1),ZIndex=2,Parent=C})
b('UIGradient',{Transparency=NumberSequence.new(0,1),Parent=C})z+=f end z+=g
local E=b('Frame',{Position=UDim2.fromOffset(h,z),Size=UDim2.fromOffset(44,28),
BackgroundTransparency=0,Parent=p})local F=b('TextBox',{Position=UDim2.
fromOffset(h+54,z),Size=UDim2.new(1,-(2*h+54),0,28),TextSize=18,Parent=p})m:
type(F,'text',true)m:paint(F,'TextColor3','text')local function draw()local G=
Color3.fromHSV(s,t,u)w.BackgroundColor3=Color3.fromHSV(s,1,1)y.Position=UDim2.
fromScale(t,1-u)B.Position=UDim2.fromScale(s,0)E.BackgroundColor3=G if not F:
IsFocused()then F.Text='#'..hex(G)end if C then C.BackgroundColor3=G D.Position=
UDim2.fromScale(v,0)end end local function commit()draw()k:set({color=Color3.
fromHSV(s,t,u),alpha=v})end local function bind(G,H)local function update(I)
local J,K=G.AbsolutePosition,G.AbsoluteSize H(math.clamp((I.X-J.X)/math.max(K.X,
1),0,1),math.clamp((I.Y-J.Y)/math.max(K.Y,1),0,1))commit()end G.InputBegan:
Connect(function(I)local J=I.UserInputType if J==Enum.UserInputType.MouseButton1
then update(j.input:pointer())j.input:capture(update)elseif J==Enum.
UserInputType.Touch then j.setScrollLocked(true)update(j.input:at(I))j.input:
capture(update,function()j.setScrollLocked(false)end)end end)end bind(w,function
(G,H)t,u=G,1-H end)bind(A,function(G)s=math.clamp(G,0,0.999)end)if C then bind(C
,function(G)v=G end)end F.FocusLost:Connect(function()local G=parseHex(F.Text)if
G then s,t,u=G:ToHSV()commit()else draw()end end)q.onRefresh(function()local G=k
.value if G.color~=Color3.fromHSV(s,t,u)then s,t,u=G.color:ToHSV()end v=G.alpha
draw()end)draw()end)end function c.swatch(j,k)local l=b('TextButton',{Name=
'Swatch',Size=UDim2.fromOffset(20,20),BackgroundTransparency=0,ZIndex=2})local m
=b('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=l})j.theme:
paint(m,'Color','lineStrong')local n={root=l,width=20}n.refresh=function()l.
BackgroundColor3=k.value.color l.BackgroundTransparency=k.value.alpha*0.8 end n.
refresh()n.open=function()if not k.disabled then open(j,k,l)end end l.Activated:
Connect(n.open)n.setInk=function(o)j.theme:paint(m,'Color',if o then'onAccent'
else'lineStrong')end n.destroy=function()l:Destroy()end return n end return c
end function a.k()local b=a.cache.k if not b then b={c=__modImpl()}a.cache.k=b
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
a.l()local b=a.cache.l if not b then b={c=__modImpl()}a.cache.l=b end return b.c
end end do local function __modImpl()local b=a.e()local c=a.l()local d={}local e
=38 local f=8 local g=9 local h=46 local i=38 local j=260 local k=17 local 
function isPicked(l,m)if l.spec.multi then return l.value[m]==true end return l.
value==m end function d.open(l,m,n)local o=m.spec local p=l.theme local q=o.
display or tostring local r=o.searchable==true or#o.options>=g local s=o.multi==
true local t=(if r then h else 0)+(if s then i else 0)local u=o.options local v=
0 local w=''local function ordered(x)if not o.multi then return x end local y,z=
{},{}for A,B in x do table.insert(if m.value[B]then y else z,B)end table.move(z,
1,#z,#y+1,y)return y end u=ordered(u)local function bodyHeight()return math.
clamp(#u,1,f)*e+8 end local x=math.max(n.AbsoluteSize.X,j)l.popover:open(n,x,
bodyHeight()+t,function(y,z)local A=b('ScrollingFrame',{Position=UDim2.
fromOffset(0,t),Size=UDim2.new(1,0,1,-t),ScrollBarThickness=3,Parent=y})p:paint(
A,'ScrollBarImageColor3','lineStrong')local B=b('Frame',{Size=UDim2.fromScale(1,
1),Parent=A})local C={}local D=f+2 local E=b('TextLabel',{Position=UDim2.
fromOffset(14,t+4),Size=UDim2.new(1,-28,0,e),TextSize=k,Text='Nothing matches',
Visible=false,Parent=y})p:type(E,'text')p:paint(E,'TextColor3','faint')local 
function draw()local F=math.floor(A.CanvasPosition.Y/e)+1 for G=1,D do local H=C
[G]local I=F+G-1 local J=u[I]if J==nil then H.root.Visible=false else H.index=I
H.option=J H.root.Visible=true H.root.Position=UDim2.new(0,4,0,(I-1)*e+4)H.text.
Text=q(J)local K=isPicked(m,J)p:paint(H.text,'TextColor3',if K then'onAccent'
else'text')p:paint(H.root,'BackgroundColor3',if K then'accent'else'line')H.root.
BackgroundTransparency=if K or I==v then 0 else 1 end end end local function 
refit()A.CanvasSize=UDim2.fromOffset(0,#u*e+8)E.Visible=#u==0 z.resize(
bodyHeight()+t)draw()end local function refilter()local F=o.options if w~=''then
F=c.rank(w,F,q,500)end u=ordered(F)refit()end local F=nil local function choose(
G)if o.multi then local H=table.clone(m.value)H[G]=if H[G]then nil else true m:
set(H)if F and F.Text~=''then F.Text=''else refilter()end if F and not l.touch
then F:CaptureFocus()end return end if m.value==G then if o.allowNull then m:
set(nil)end else m:set(G)end z.close()end for G=1,D do local H=b('TextButton',{
Size=UDim2.new(1,-8,0,e-2),BackgroundTransparency=1,Visible=false,Parent=B})
local I=b('TextLabel',{Position=UDim2.fromOffset(10,0),Size=UDim2.new(1,-20,1,0)
,TextSize=k,TextTruncate=Enum.TextTruncate.AtEnd,Parent=H})p:type(I,'text',true)
local J={root=H,text=I,index=0,option=nil}C[G]=J H.MouseEnter:Connect(function()
v=J.index draw()end)H.MouseLeave:Connect(function()if v==J.index then v=0 draw()
end end)H.Activated:Connect(function()if J.option~=nil then choose(J.option)end
end)end A:GetPropertyChangedSignal('CanvasPosition'):Connect(draw)local G=0 if r
then F=b('TextBox',{Position=UDim2.fromOffset(14,0),Size=UDim2.new(1,-28,0,h),
TextSize=k+1,Text='',PlaceholderText='Search',Parent=y})p:type(F,'text',true)p:
paint(F,'TextColor3','text')p:paint(F,'PlaceholderColor3','faint')local H=b(
'Frame',{Position=UDim2.fromOffset(0,h-1),Size=UDim2.new(1,0,0,1),
BackgroundTransparency=0,Parent=y})p:paint(H,'BackgroundColor3','lineStrong')F:
GetPropertyChangedSignal('Text'):Connect(function()w=F.Text v=if w~=''then 1
else 0 A.CanvasPosition=Vector2.zero refilter()end)G=h end if s then local H=b(
'TextButton',{Position=UDim2.fromOffset(4,G),Size=UDim2.new(1,-8,0,i),TextSize=k
,Text='Clear all',TextXAlignment=Enum.TextXAlignment.Left,Parent=y})b(
'UIPadding',{PaddingLeft=UDim.new(0,10),Parent=H})p:type(H,'text',true)p:paint(H
,'TextColor3','muted')H.MouseEnter:Connect(function()p:paint(H,'TextColor3',
'text')end)H.MouseLeave:Connect(function()p:paint(H,'TextColor3','muted')end)H.
Activated:Connect(function()m:set({})refilter()end)end z.onKey(function(H)if H==
'Down'or H=='Up'then local I=if H=='Down'then 1 else-1 v=math.clamp(v+I,1,math.
max(#u,1))local J=(v-1)*e local K=A.AbsoluteWindowSize.Y local L=A.
CanvasPosition.Y if J<L then A.CanvasPosition=Vector2.new(0,J)elseif J+e+8>L+K
then A.CanvasPosition=Vector2.new(0,J+e+8-K)end draw()elseif H=='Return'then
local I=u[v]if I~=nil then choose(I)end end end)refit()if not o.multi and m.
value~=nil then local H=table.find(u,m.value)if H then local I=math.clamp(#u,1,f
)*e A.CanvasPosition=Vector2.new(0,math.max((H-1)*e-I/2+e/2,0))draw()end end if
F and not l.touch then F:CaptureFocus()end end)end return d end function a.m()
local b=a.cache.m if not b then b={c=__modImpl()}a.cache.m=b end return b.c end
end do local function __modImpl()local b={}local c={display={0.177,0.244,0.272,
0.655,0.507,0.609,0.642,0.165,0.301,0.303,0.276,0.276,0.26,0.348,0.219,0.387,
0.488,0.45,0.495,0.492,0.505,0.488,0.491,0.439,0.487,0.492,0.222,0.253,0.336,
0.274,0.336,0.507,0.734,0.552,0.523,0.521,0.519,0.411,0.39,0.534,0.529,0.251,
0.517,0.51,0.385,0.755,0.633,0.532,0.507,0.533,0.518,0.525,0.475,0.535,0.537,
0.811,0.546,0.55,0.421,0.322,0.414,0.322,0.333,0.494,0.256,0.524,0.517,0.501,
0.52,0.519,0.395,0.522,0.513,0.243,0.254,0.511,0.24,0.76,0.511,0.518,0.517,0.518
,0.51,0.517,0.402,0.512,0.512,0.789,0.523,0.516,0.403,0.335,0.181,0.332,0.38},
text={0.265,0.248,0.37,0.814,0.578,0.773,0.691,0.213,0.372,0.372,0.478,0.6,0.178
,0.513,0.195,0.391,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.199,0.223,0.6,0.6,
0.6,0.516,1.034,0.664,0.602,0.72,0.696,0.564,0.534,0.757,0.679,0.232,0.499,0.582
,0.525,0.827,0.689,0.784,0.579,0.789,0.593,0.578,0.56,0.656,0.668,0.967,0.602,
0.579,0.535,0.307,0.391,0.307,0.62,0.642,0,0.571,0.628,0.57,0.628,0.569,0.333,
0.529,0.572,0.239,0.242,0.504,0.222,0.895,0.573,0.604,0.628,0.628,0.363,0.5,
0.387,0.572,0.521,0.754,0.498,0.556,0.452,0.425,0.232,0.425,0.6},textMedium={
0.248,0.267,0.413,0.837,0.584,0.823,0.702,0.227,0.386,0.386,0.489,0.6,0.204,
0.473,0.211,0.406,0.59,0.59,0.59,0.59,0.59,0.59,0.59,0.59,0.59,0.59,0.221,0.245,
0.6,0.6,0.6,0.522,1.028,0.679,0.613,0.725,0.7,0.563,0.533,0.761,0.689,0.244,
0.512,0.607,0.53,0.827,0.701,0.791,0.589,0.796,0.604,0.584,0.571,0.665,0.68,
0.982,0.627,0.598,0.547,0.334,0.406,0.334,0.643,0.662,0.25,0.563,0.613,0.557,
0.613,0.561,0.321,0.528,0.567,0.233,0.235,0.514,0.221,0.901,0.568,0.593,0.613,
0.614,0.353,0.487,0.369,0.567,0.523,0.751,0.485,0.546,0.433,0.444,0.248,0.444,
0.6}}function b.width(d,e,f)local g=c[d]local h=0 for i=1,#e do local j=(string.
byte(e,i))h+=g[j-31]or 0.5 end return h*f end return b end function a.n()local b
=a.cache.n if not b then b={c=__modImpl()}a.cache.n=b end return b.c end end do
local function __modImpl()local b=a.e()local c=a.n()local d={}local e=30 local f
=8 local g=16 local h='Press a key'local function display(i)local j=i.value if j
==nil or j.key=='None'or j.key=='Unknown'then return'Unset'end local k={}for l,m
in j.modifiers or{}do table.insert(k,m)end table.insert(k,j.key)return table.
concat(k,'+')end function d.build(i,j)local k=i.theme local l=b('TextButton',{
Name='Key',Size=UDim2.fromOffset(52,60),BackgroundTransparency=1})local m=b(
'Frame',{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size
=UDim2.new(1,-f,0,e),ZIndex=4,Parent=l})local n=b('UIStroke',{ApplyStrokeMode=
Enum.ApplyStrokeMode.Border,Parent=m})local o=b('TextLabel',{Size=UDim2.
fromScale(1,1),TextSize=g,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=5,
Parent=m})k:type(o,'text',true)local p={root=l,width=52}local q=false local r=
false local function fit(s)local t=math.ceil(c.width('textMedium',s,g))+16+f l.
Size=UDim2.fromOffset(math.max(t,44),60)p.width=l.Size.X.Offset end local 
function ink()k:paint(o,'TextColor3',if q then'accent'elseif r then'onAccent'
else'muted')k:paint(n,'Color',if q then'accent'elseif r then'onAccent'else
'lineStrong')end p.refresh=function()if q then return end local s=display(j)o.
Text=s fit(s)ink()end p.setInk=function(s)r=s ink()end p.refresh()p.start=
function()if j.disabled or q then return end q=true o.Text=h fit(h)ink()i.keys:
listen(function(s,t)q=false if s~=nil then j:set({key=s,modifiers=t or{}})end p.
refresh()end,j.spec.noMouse==true)end l.Activated:Connect(p.start)l.
MouseButton2Click:Connect(function()local s=j.spec.modes if j.disabled or s==nil
or#s<2 then return end local t=table.find(s,j.value.mode)or 0 local u=s[t%#s+1]j
:set({mode=u})i.notify({title=j.label,text='Key mode: '..u,seconds=2})end)p.
destroy=function()if q then i.keys:cancel()end l:Destroy()end return p end
return d end function a.o()local b=a.cache.o if not b then b={c=__modImpl()}a.
cache.o=b end return b.c end end do local function __modImpl()local b=a.e()local
c=a.n()local d=a.b()local e={}e.PAD=14 e.HEIGHT=60 e.NAME=24 e.NAME_SMALL=19 e.
NAME_SMALLEST=16 e.VALUE=15 local f=30 local g=40 local h=0.62 local i=20 local
j=34 local k=0.965 local l=2.6 local m=0.45 local n={}n.__index=n function n.own
(o,p)table.insert(o._cleanups,function()p:destroy()end)return p end function n.
onCleanup(o,p)table.insert(o._cleanups,p)end local function baseColor(o)local p=
o.ctx.theme.tokens local q=o._face if o._lit then return if o._hover then p.
accentHover else p.accent end if q=='action'then return if o._hover then p.
lineStrong else p.raised end return if o._hover then p.raised else p.surface end
local function washTo(o)if o._wash==nil then o._wash=o:own(d.prop(o.root,
'BackgroundColor3',f))end o._wash:to(baseColor(o))end local function snapBase(o)
local p=baseColor(o)if o._wash then o._wash:snap(p)else o.root.BackgroundColor3=
p end end function n.onHover(o,p)local q=p and not o.el.disabled if o._hover==q
then return end o._hover=q if not(o._floodFrame and o._floodFrame.Visible)then
washTo(o)end end function n.pressed(o,p)if o._press==nil then local q=b(
'UIScale',{Parent=o.root})o._press=o:own(d.prop(q,'Scale',g,h))end o._press:to(
if p then k else 1)end function n.flood(o,p,q)if o._floodOn==p then return end o
._floodOn=p local r=o.root local s=r.AbsoluteSize if q or s.X<1 or not r.Visible
then o._lit=p if o._floodFrame then o._floodFrame.Visible=false o._floodSpring:
snap(UDim2.fromOffset(0,0))end snapBase(o)return end local t=o._floodFrame if t
==nil then t=b('Frame',{Name='Flood',AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2
.fromOffset(0,0),BackgroundTransparency=0,ZIndex=1,Parent=r})b('UICorner',{
CornerRadius=UDim.new(1,0),Parent=t})o.ctx.theme:paint(t,'BackgroundColor3',
'accent')o._floodFrame=t o._floodSpring=o:own(d.prop(t,'Size',i))end local u=o.
ctx.uiScale()local v=s/u local w=math.ceil(math.sqrt(v.X*v.X+v.Y*v.Y)*l)local x=
o._pressAt o._pressAt=nil local y=if x then(x-r.AbsolutePosition)/u else v/2 t.
Position=UDim2.fromOffset(y.X,y.Y)t.Visible=true if p then o._floodSpring:snap(
UDim2.fromOffset(0,0))o._floodSpring:to(UDim2.fromOffset(w,w),function()o._lit=
true snapBase(o)t.Visible=false end)else o._lit=false snapBase(o)o._floodSpring:
snap(UDim2.fromOffset(w,w))o._floodSpring:to(UDim2.fromOffset(0,0),function()t.
Visible=false end)end end function n.flash(o)if o._floodOn then o:pressed(true)
task.delay(0.16,function()if o.root.Parent then o:pressed(false)end end)return
end o:flood(true)task.delay(0.28,function()if o.root.Parent and not(o.el.kind==
'toggle'and o.el.value==true)then o:flood(false)end end)end function n.ink(o,p,q
,r)local s=o.ctx.theme.tokens local t=o._inks[p]if r then if t then t:snap(s[q])
else p.TextColor3=s[q]end return end if t==nil then t=o:own(d.prop(p,
'TextColor3',j))o._inks[p]=t end t:to(s[q])end function e.fitName(o,p,q)local r=
c.width('display',p,e.NAME)if r<=q then o.TextSize=e.NAME o.TextWrapped=false o.
LineHeight=1 return end o.TextWrapped=true o.LineHeight=0.95 local s=q*1.8 o.
TextSize=if c.width('display',p,e.NAME_SMALL)<=s then e.NAME_SMALL else e.
NAME_SMALLEST end function n.refreshName(o)local p=o.el if p.disabled then o.
name.RichText=true o.name.Text='<s>'..p.label..'</s>'else o.name.RichText=false
o.name.Text=p.label end end function e.new(o,p,q)local r=q or{}local s=b(
'TextButton',{Name=p.kind,Size=UDim2.new(1,0,0,r.height or e.HEIGHT),
BackgroundTransparency=if r.inert then 1 else 0,ClipsDescendants=true,Active=not
r.inert})local t=b('TextLabel',{Name='Name',Position=UDim2.fromOffset(e.PAD,0),
Size=UDim2.new(1,-2*e.PAD,1,0),TextSize=e.NAME,TextTruncate=Enum.TextTruncate.
AtEnd,Text=p.label,ZIndex=3,Parent=s})o.theme:type(t,'display')local u=
setmetatable({root=s,name=t,el=p,ctx=o,chips={},_face=r.face,_cleanups={},_inks=
{},_hover=false,_lit=false,_floodOn=false},n)s.BackgroundColor3=baseColor(u)u:
refreshName()if r.inert then u.onHover=function()end u.pressed=function()end
else s.MouseEnter:Connect(function()o.hover:enter(u)end)local v=nil s.InputBegan
:Connect(function(w)local x=w.UserInputType if x==Enum.UserInputType.
MouseButton1 then if not p.disabled then u._pressAt=o.input:pointer()u:pressed(
true)end elseif x==Enum.UserInputType.Touch then if not p.disabled then u.
_pressAt=o.input:at(w)u:pressed(true)end v=task.delay(m,function()v=nil local y=
if p.disabled and p.disabledTip then p.disabledTip else p.tip if y and y~=''then
o.tooltip:showAt(s,y)end end)end end)s.InputEnded:Connect(function(w)local x=w.
UserInputType if x==Enum.UserInputType.MouseButton1 or x==Enum.UserInputType.
Touch then if u._press then u:pressed(false)end if v then task.cancel(v)v=nil
end end end)u:onCleanup(function()if v then task.cancel(v)end end)end u.destroy=
function()o.hover:leave(u)for v,w in u._cleanups do pcall(w)end s:Destroy()end
return u end return e end function a.p()local b=a.cache.p if not b then b={c=
__modImpl()}a.cache.p=b end return b.c end end do local function __modImpl()
local b=a.k()local c=a.m()local d=a.o()local e=a.e()local f=a.n()local g=a.b()
local h=a.p()local i={}local j=h.PAD local k=h.NAME local l=42 local m=90 local
n=3 local o=104 local p=19 local q=22 local r={}local function addons(s,t,u)
local v=0 for w,x in u.addons or{}do if not x.spec.chipless then local y=if x.
kind=='key'then d.build(t,x)else b.swatch(t,x)y.root.AnchorPoint=Vector2.new(1,
0.5)y.root.Position=UDim2.new(1,-(j+v),0.5,0)y.root.ZIndex=4 y.root.Parent=s.
root v+=y.width+6 x._view=y table.insert(s.chips,y)s:onCleanup(function()x._view
=nil y.destroy()end)end end return v end local function reserveRight(s,t)s.name.
Size=UDim2.new(1,-(2*j+t),1,0)end local function fitToWidth(s,t,u)local function 
fit()local v=s.root.AbsoluteSize.X/t.uiScale()-2*j-u if v>0 then h.fitName(s.
name,s.el.label,v)end end s.root:GetPropertyChangedSignal('AbsoluteSize'):
Connect(fit)return fit end function r.toggle(s,t)local u=h.new(s,t)local v=
addons(u,s,t)reserveRight(u,v)local w=fitToWidth(u,s,v)local function draw(x)
local y=t.value==true u:flood(y,x)local z=if t.disabled then'faint'elseif y then
'onAccent'else'muted'u:ink(u.name,z,x)for A,B in u.chips do B.setInk(y)end end u
.root.Activated:Connect(function()if not t.disabled then t:set(not t.value)end
end)u.refresh=function()u:refreshName()w()draw(false)end draw(true)task.defer(w)
return u end local function formatted(s)local t=s.spec if t.format then local u,
v=pcall(t.format,s,s.value)if u and v~=nil then return tostring(v)end end return
string.format('%.'..(t.decimals or 0)..'f',s.value)..(t.suffix or'')end function
r.slider(s,t)local u=h.new(s,t)local v=s.theme local w=t.spec local x=u.root
local function ratio()local y=w.max-w.min return if y<=0 then 0 else(t.value-w.
min)/y end reserveRight(u,o)u.name.ZIndex=4 v:paint(u.name,'TextColor3','text')
local y=fitToWidth(u,s,o)local z=e('TextLabel',{Name='Readout',AnchorPoint=
Vector2.new(1,0),Position=UDim2.new(1,-j,0,0),Size=UDim2.new(0,o,1,0),TextSize=k
,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=4,Parent=x})v:type(z,'display')
v:paint(z,'TextColor3','text')local A=e('Frame',{Name='Fill',Size=UDim2.new(
ratio(),0,1,0),BackgroundTransparency=0,ZIndex=2,Parent=x})v:paint(A,
'BackgroundColor3','accentDim')local B=e('Frame',{AnchorPoint=Vector2.new(1,0),
Position=UDim2.fromScale(1,0),Size=UDim2.new(0,2,1,0),BackgroundTransparency=0,
ZIndex=2,Parent=A})v:paint(B,'BackgroundColor3','accent')local C=u:own(g.prop(A,
'Size',l))local function typedEntry()if t.disabled or u._typing then return end
u._typing=true z.Visible=false local D=e('TextBox',{AnchorPoint=Vector2.new(1,0)
,Position=UDim2.new(1,-j,0,0),Size=UDim2.new(0,o,1,0),TextSize=k,TextXAlignment=
Enum.TextXAlignment.Right,Text=tostring(t.value),ZIndex=6,Parent=x})v:type(D,
'display')v:paint(D,'TextColor3','accent')D:CaptureFocus()D.SelectionStart=1 D.
CursorPosition=#D.Text+1 D.FocusLost:Connect(function()local E=tonumber(D.Text)u
._typing=false z.Visible=true D:Destroy()if E then t:set(E)end end)end local 
function beginDrag(D,E)if t.disabled then return end local F=t.value local G=
math.max(x.AbsoluteSize.X,1)local H=w.max-w.min local I=false s.input:capture(
function(J)local K=J-D if not I then if math.abs(K.X)<n then if E and math.abs(K
.Y)>8 then s.input:release()end return end if E and math.abs(K.X)<=math.abs(K.Y)
then s.input:release()return end I=true C.speed=m s.setScrollLocked(true)end t:
set(F+H*K.X/G)end,function(J)C.speed=l s.setScrollLocked(false)if not I and(J-D)
.Magnitude<8 then typedEntry()end end)end x.InputBegan:Connect(function(D)local
E=D.UserInputType if E==Enum.UserInputType.MouseButton2 then typedEntry()elseif
E==Enum.UserInputType.MouseButton1 then beginDrag(s.input:pointer(),false)elseif
E==Enum.UserInputType.Touch then beginDrag(s.input:at(D),true)end end)u.refresh=
function()u:refreshName()y()z.Text=formatted(t)local D=if t.disabled then'faint'
else'text'v:paint(u.name,'TextColor3',D)v:paint(z,'TextColor3',D)C:to(UDim2.new(
ratio(),0,1,0))end z.Text=formatted(t)task.defer(y)return u end local function 
pickText(s)local t=s.spec.display or tostring local u=s.value if s.spec.multi
then local v={}for w,x in s.spec.options do if u[x]then table.insert(v,t(x))end
end for w,x in u do if x and not table.find(s.spec.options,w)then table.insert(v
,t(w))end end if#v==0 then return'None',false end if#v<=2 then return table.
concat(v,', '),true end return string.format('%s, %s +%d',v[1],v[2],#v-2),true
end if u==nil then return'None',false end return t(u),true end function r.
dropdown(s,t)local u=h.new(s,t)local v=s.theme u.name.Size=UDim2.new(0.5,-j,1,0)
v:paint(u.name,'TextColor3','muted')local w=e('TextLabel',{Name='Value',
AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-(j+q),0,0),Size=UDim2.new(0.5
,-q,1,0),TextSize=p,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.
TextXAlignment.Right,ZIndex=3,Parent=u.root})v:type(w,'text',true)local x=s.
glyph.chevron(u.root,'muted')x.AnchorPoint=Vector2.new(1,0.5)x.Position=UDim2.
new(1,-j,0.5,0)x.ZIndex=3 local function fit()local y=s.uiScale()local z=u.root.
AbsoluteSize.X/y-2*j-q if z<=0 then return end local A=f.width('textMedium',(
pickText(t)),p)+12 local B=math.max(z-A,z*0.4)u.name.Size=UDim2.new(0,B,1,0)h.
fitName(u.name,t.label,B)w.Size=UDim2.new(0,z-B,1,0)end u.root:
GetPropertyChangedSignal('AbsoluteSize'):Connect(fit)u.root.Activated:Connect(
function()if not t.disabled then c.open(s,t,u.root)end end)u.refresh=function()u
:refreshName()local y,z=pickText(t)w.Text=y v:paint(w,'TextColor3',if t.disabled
or not z then'faint'else'text')fit()end u.refresh()task.defer(fit)return u end
function r.input(s,t)local u=h.new(s,t)local v=s.theme local w=t.spec u.name.
Size=UDim2.new(0.42,-j,1,0)v:paint(u.name,'TextColor3','muted')local x=e(
'TextBox',{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-j,0.5,0),Size=
UDim2.new(0.58,-j,0,34),TextSize=18,Text=t.value or'',PlaceholderText=w.
placeholder or'',ClipsDescendants=true,TextEditable=not t.disabled,ZIndex=3,
Parent=u.root})v:type(x,'text',true)v:paint(x,'TextColor3','text')v:paint(x,
'PlaceholderColor3','faint')local y=e('Frame',{AnchorPoint=Vector2.new(0,1),
Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,2),BackgroundTransparency=0,
Visible=false,ZIndex=4,Parent=u.root})v:paint(y,'BackgroundColor3','accent')x.
Focused:Connect(function()y.Visible=true end)x.FocusLost:Connect(function()y.
Visible=false if w.finished and not t:set(x.Text)then x.Text=t.value or''end end
)x:GetPropertyChangedSignal('Text'):Connect(function()if u._applying or w.
finished then return end if not t:set(x.Text)and x.Text~=t.value then u.
_applying=true x.Text=t.value or''u._applying=false end end)u.root.Activated:
Connect(function()if not t.disabled then x:CaptureFocus()end end)u.refresh=
function()u:refreshName()x.TextEditable=not t.disabled if x.Text~=(t.value or'')
then u._applying=true x.Text=t.value or''u._applying=false end end return u end
function r.button(s,t)local u=h.new(s,t,{face='action'})local v=fitToWidth(u,s,0
)local w=nil local function draw()u:refreshName()v()u:ink(u.name,if t.disabled
then'faint'else'text')end u.refresh=draw draw()u.root.Activated:Connect(function
()if t.disabled then return end if t.spec.confirm and w==nil then u.name.Text=
'Again to confirm'u:flood(true)u:ink(u.name,'onAccent')w=task.delay(2.5,function
()w=nil u:flood(false)draw()end)return end if w then task.cancel(w)w=nil u:
flood(false)draw()end u:flash()u:ink(u.name,'onAccent')task.delay(0.28,function(
)if u.root.Parent then u:ink(u.name,'text')end end)t:fire()end)u:onCleanup(
function()if w then task.cancel(w)end end)task.defer(v)return u end function r.
stat(s,t)local u=h.new(s,t,{inert=true})local v=s.theme u.name.Position=UDim2.
new()u.name.Size=UDim2.new(1,0,0,40)u.name.TextSize=36 u.name.TextYAlignment=
Enum.TextYAlignment.Top v:paint(u.name,'TextColor3','text')local w=e('TextLabel'
,{Position=UDim2.fromOffset(0,38),Size=UDim2.new(1,0,0,20),TextSize=16,
TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=3,Parent=u.root})v:type(w,'text')v:
paint(w,'TextColor3','muted')u.refresh=function()u.name.Text=tostring(t.value)w.
Text=t.label end u.refresh()return u end function r.label(s,t)local u=s.theme if
t.addons then local v=h.new(s,t)u:paint(v.name,'TextColor3','muted')v.name.
RichText=true local w=addons(v,s,t)reserveRight(v,w)local x=fitToWidth(v,s,w)v.
refresh=function()v.name.Text=t.label x()end task.defer(x)return v end local v=h
.new(s,t,{height=32,inert=true})local w=v.name local x=t.spec.wrap==true w.
RichText=true w.TextSize=16 w.TextWrapped=x u:type(w,'text')u:paint(w,
'TextColor3','muted')w.TextTruncate=if x then Enum.TextTruncate.None else Enum.
TextTruncate.AtEnd w.TextYAlignment=if x then Enum.TextYAlignment.Top else Enum.
TextYAlignment.Center w.LineHeight=if x then 1.15 else 1 w.Position=UDim2.
fromOffset(0,if x then 6 else 0)w.Size=if x then UDim2.new(1,0,1,-6)else UDim2.
fromScale(1,1)w.Text=t.label if x then w:GetPropertyChangedSignal('TextBounds'):
Connect(function()local y=math.ceil(w.TextBounds.Y/s.uiScale())+12 if t.
_measured~=y then t._measured=y if t._relayout then t._relayout()end end end)end
v.refresh=function()w.Text=t.label end return v end function r.divider(s,t)local
u=h.new(s,t,{height=28,inert=true})local v=s.theme u.name.Position=UDim2.new()u.
name.Size=UDim2.fromScale(1,1)u.name.TextSize=16 v:type(u.name,'text',true)v:
paint(u.name,'TextColor3','muted')u.refresh=function()u.name.Text=t.label end
return u end function r.key(s,t)local u=h.new(s,t)s.theme:paint(u.name,
'TextColor3','muted')local v=d.build(s,t)v.root.AnchorPoint=Vector2.new(1,0.5)v.
root.Position=UDim2.new(1,-j,0.5,0)v.root.ZIndex=4 v.root.Parent=u.root
reserveRight(u,96)t._view=v u:onCleanup(v.destroy)u.refresh=function()u:
refreshName()v.refresh()end u.root.Activated:Connect(v.start)return u end
function r.color(s,t)local u=h.new(s,t)s.theme:paint(u.name,'TextColor3','muted'
)local v=b.swatch(s,t)v.root.AnchorPoint=Vector2.new(1,0.5)v.root.Position=UDim2
.new(1,-j,0.5,0)v.root.ZIndex=4 v.root.Parent=u.root reserveRight(u,44)u:
onCleanup(v.destroy)u.refresh=function()u:refreshName()v.refresh()end u.root.
Activated:Connect(v.open)return u end function i.build(s,t)local u=r[t.kind]
assert(u,'sottUI: no view for '..tostring(t.kind))local v=u(s,t)t._view=v return
v end return i end function a.q()local b=a.cache.q if not b then b={c=__modImpl(
)}a.cache.q=b end return b.c end end do local function __modImpl()local b=a.e()
local c=a.b()local d={}local e=320 local f=8 local g=20 local h=26 local i=5
function d.new(j,k)local l=j.theme local m={}local n={}local function layout()
local o=k.AbsoluteSize local p=o.Y-g for q=#m,1,-1 do local r=m[q]p-=r.height r.
pos:to(UDim2.fromOffset(o.X-e-g,p))p-=f end end local function dismiss(o)if o.
gone then return end o.gone=true if o.timer then task.cancel(o.timer)end local p
=table.find(m,o)if p then table.remove(m,p)end local q=k.AbsoluteSize o.pos:to(
UDim2.fromOffset(q.X+8,o.frame.Position.Y.Offset),function()o.pos:destroy()o.
frame:Destroy()end)layout()end function n.show(o,p)while#m>=i do dismiss(m[1])
end local q=k.AbsoluteSize local r=b('TextButton',{Name='Notice',Position=UDim2.
fromOffset(q.X+8,q.Y-g-60),Size=UDim2.fromOffset(e,60),BackgroundTransparency=0,
ZIndex=30,Parent=k})l:paint(r,'BackgroundColor3','surface')local s=b('UIStroke',
{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=r})l:paint(s,'Color',
'lineStrong')local t=b('Frame',{Size=UDim2.new(0,4,1,0),BackgroundTransparency=0
,ZIndex=31,Parent=r})l:paint(t,'BackgroundColor3','accent')local u=10 if p.title
and p.title~=''then local v=b('TextLabel',{Position=UDim2.fromOffset(18,u),Size=
UDim2.new(1,-32,0,24),TextSize=22,TextTruncate=Enum.TextTruncate.AtEnd,Text=p.
title,ZIndex=31,Parent=r})l:type(v,'display')l:paint(v,'TextColor3','text')u+=26
end local v=nil if p.text and p.text~=''then v=b('TextLabel',{Position=UDim2.
fromOffset(18,u),Size=UDim2.new(1,-32,0,20),TextSize=16,TextWrapped=true,
TextYAlignment=Enum.TextYAlignment.Top,RichText=true,Text=p.text,ZIndex=31,
Parent=r})l:type(v,'text')l:paint(v,'TextColor3','muted')end local w={frame=r,
height=u+28,pos=c.prop(r,'Position',h),gone=false}r.Size=UDim2.fromOffset(e,w.
height)if v then task.defer(function()if w.gone then return end local x=math.
ceil(v.TextBounds.Y)if x>20 then v.Size=UDim2.new(1,-32,0,x)w.height=u+x+10 r.
Size=UDim2.fromOffset(e,w.height)layout()end end)end table.insert(m,w)r.
Activated:Connect(function()dismiss(w)end)w.timer=task.delay(p.seconds or 5,
function()w.timer=nil dismiss(w)end)layout()end function n.destroy(o)for p,q in
table.clone(m)do if q.timer then task.cancel(q.timer)end q.pos:destroy()q.frame:
Destroy()end table.clear(m)end return n end return d end function a.r()local b=a
.cache.r if not b then b={c=__modImpl()}a.cache.r=b end return b.c end end do
local function __modImpl()local b=a.e()local c=a.b()local d={}local e=34 local f
=0.55 local g=340 local h=40 local i=8 function d.popover(j,k)local l=j.theme
local m={}local n=nil local function close()local o=n if o==nil then return end
n=nil o.catcher:Destroy()o.open=false o.size:to(UDim2.fromOffset(o.width,0),
function()o.size:destroy()o.frame:Destroy()end)if o.disconnectEl then o.
disconnectEl()end end function m.open(o,p,q,r,s)close()local t=k.AbsoluteSize
local u,v=p.AbsolutePosition,p.AbsoluteSize local w=math.clamp(u.X,i,t.X-q-i)
local x=u.Y+v.Y+2 local y=x+r+i>t.Y and u.Y-r-2>i local z=if y then u.Y-r-2 else
math.min(x,t.Y-r-i)local A=b('TextButton',{Name='Catcher',Size=UDim2.fromScale(1
,1),ZIndex=10,Parent=k})local B=b('Frame',{Name='Popover',Position=UDim2.
fromOffset(w,z),Size=UDim2.fromOffset(q,0),BackgroundTransparency=0,
ClipsDescendants=true,ZIndex=11,Active=true,Parent=k})l:paint(B,
'BackgroundColor3','raised')local C=b('UIStroke',{ApplyStrokeMode=Enum.
ApplyStrokeMode.Border,Parent=B})l:paint(C,'Color','lineStrong')local D=b(
'Frame',{Size=UDim2.fromScale(1,1),Parent=B})local E={frame=B,catcher=A,width=q,
open=true,size=c.prop(B,'Size',e)}n=E A.MouseButton1Down:Connect(close)A.
MouseButton2Down:Connect(close)local F={close=close,resize=function(F)if E.open
then E.size:to(UDim2.fromOffset(q,F))end end,onKey=function(F)E.onKey=F end,
onRefresh=function(F)E.onRefresh=F end}s(D,F)E.size:to(UDim2.fromOffset(q,r))end
function m.isOpen(o)return n~=nil end function m.close(o)close()end function m.
key(o,p)if n==nil then return false end if p=='Escape'then close()return true
end if n.onKey then n.onKey(p)return true end return false end return m end
function d.tooltip(j,k)local l=j.theme local m=b('Frame',{Name='Tooltip',
AutomaticSize=Enum.AutomaticSize.XY,BackgroundTransparency=0,Visible=false,
ZIndex=20,Parent=k})l:paint(m,'BackgroundColor3','raised')local n=b('UIStroke',{
ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=m})l:paint(n,'Color',
'lineStrong')b('UIPadding',{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,
10),PaddingTop=UDim.new(0,7),PaddingBottom=UDim.new(0,7),Parent=m})local o=b(
'TextLabel',{AutomaticSize=Enum.AutomaticSize.XY,TextSize=16,TextWrapped=true,
ZIndex=21,Parent=m})b('UISizeConstraint',{MaxSize=Vector2.new(g,400),Parent=o})l
:type(o,'text')l:paint(o,'TextColor3','text')local p={}local q=nil function p.
hide(r)if q then task.cancel(q)q=nil end m.Visible=false end local r=c.prop(m,
'Position',h)function p.showAt(s,t,u)s:hide()o.Text=u m.Visible=true task.defer(
function()if not m.Visible then return end local v=k.AbsoluteSize local w=m.
AbsoluteSize local x=math.clamp(t.AbsolutePosition.X,i,v.X-w.X-i)local y=t.
AbsolutePosition.Y+t.AbsoluteSize.Y+3 local z=y+w.Y+i>v.Y local A=if z then t.
AbsolutePosition.Y-w.Y-3 else y r:snap(UDim2.fromOffset(x,A+(if z then 8 else-8)
))r:to(UDim2.fromOffset(x,A))end)end function p.schedule(s,t,u)s:hide()q=task.
delay(f,function()q=nil if t.Parent~=nil then s:showAt(t,u)end end)end return p
end function d.hover(j)local k={}local l=nil local function clear()local m=l if
m then l=nil m:onHover(false)j.tooltip:hide()end end function k.current(m)return
l end function k.enter(m,n)if l==n then return end clear()l=n n:onHover(true)
local o=n.el local p=if o.disabled and o.disabledTip then o.disabledTip else o.
tip if p and p~=''then j.tooltip:schedule(n.root,p)end end function k.leave(m,n)
if l==n then clear()end end k.clear=clear function k.verify(m,n)local o=l if o==
nil then return end local p=o.root local q,r=p.AbsolutePosition,p.AbsoluteSize
local s=n.X>=q.X and n.Y>=q.Y and n.X<=q.X+r.X and n.Y<=q.Y+r.Y if not s or not
p.Visible or p.Parent==nil or j.popover:isOpen()then clear()end end return k end
return d end function a.s()local b=a.cache.s if not b then b={c=__modImpl()}a.
cache.s=b end return b.c end end do local function __modImpl()local b=a.h()local
c={}local d={}d.__index=d local function decimals(e)local f=string.format(
'%.10f',e)local g=string.match(f,'%.(%d-)0*$')return if g then#g else 0 end
local function roundTo(e,f)if f<=0 then return e end local g=math.round(e/f)*f
return tonumber(string.format('%.'..decimals(f)..'f',g))or g end c.roundTo=
roundTo local function sameList(e,f)if#e~=#f then return false end for g=1,#e do
if e[g]~=f[g]then return false end end return true end local function sameSet(e,
f)for g,h in e do if h and not f[g]then return false end end for g,h in f do if
h and not e[g]then return false end end return true end local e={toggle=function
(e,f)return f==true end,slider=function(e,f)local g=tonumber(f)if g==nil or g~=g
then return nil end local h=e.spec return math.clamp(roundTo(g,h.step or 1),h.
min,h.max)end,dropdown=function(e,f)local g=e.spec if g.multi then local h={}if
type(f)=='table'then for i,j in f do if type(i)=='number'then h[j]=true elseif j
then h[i]=true end end elseif f~=nil and f~=''then h[f]=true end if not g.keep
then for i in h do if not table.find(g.options,i)then h[i]=nil end end end
return h end if f==nil or f==''then return false end if not table.find(g.options
,f)and not g.keep then return nil end return f end,input=function(e,f)local g=if
f==nil then''else tostring(f)local h=e.spec if h.maxLength and#g>h.maxLength
then g=string.sub(g,1,h.maxLength)end if h.numeric and g~=''and g~='-'and g~='.'
and tonumber(g)==nil then return nil end if h.verify and not h.verify(g)then
return nil end return g end,key=function(e,f)if type(f)=='string'then return{key
=f,mode=e.value and e.value.mode or'Toggle',modifiers={}}end if type(f)~='table'
then return nil end local g=e.value or{}return{key=f.key or f[1]or g.key or
'None',mode=f.mode or f[2]or g.mode or'Toggle',modifiers=f.modifiers or f[3]or g
.modifiers or{}}end,color=function(e,f)if typeof(f)=='Color3'then return{color=f
,alpha=e.value and e.value.alpha or 0}end if type(f)=='table'and typeof(f.color)
=='Color3'then return{color=f.color,alpha=math.clamp(tonumber(f.alpha)or 0,0,1)}
end return nil end,label=function(e,f)return tostring(f)end,stat=function(e,f)
return tostring(f)end}local function equal(f,g,h)local i=f.kind if i=='dropdown'
and f.spec.multi then return sameSet(g,h)end if i=='key'then return g.key==h.key
and g.mode==h.mode and sameList(g.modifiers,h.modifiers)end if i=='color'then
return g.color==h.color and g.alpha==h.alpha end return g==h end local function 
unwrap(f,g)if f.kind=='dropdown'and not f.spec.multi and g==false then return
nil end return g end function c.new(f,g,h,i,j)local k=setmetatable({kind=f,id=g,
label=h,spec=i,tip=i.tip,disabled=i.disabled==true,disabledTip=i.disabledTip,
visible=i.visible~=false,saved=i.saved~=false,changed=b.new()},d)local l=e[f]
local m=j if l then m=l(k,j)if m==nil and f=='slider'then m=i.min end if m==nil
and f=='dropdown'then m=false end end k.value=unwrap(k,m)k.default=k.value
return k end function d.set(f,g)local h=e[f.kind]local i=g if h then i=h(f,g)if
i==nil then return false end i=unwrap(f,i)end local j=f.value if j~=nil and i~=
nil and equal(f,j,i)then return false end if j==nil and i==nil then return false
end f.value=i f:notify()return true end function d.reset(f)local g=f.default if
f.kind=='dropdown'and f.spec.multi then g=table.clone(g)end f:set(g)end local 
function redraw(f)local g=f._view if g then g.refresh()end local h=f.host if h
and h._view then h._view.refresh()end end function d.notify(f)redraw(f)f.changed
:fire(f.value)end function d.fire(f)f.changed:fire(f.value)end function d.on(f,g
)return f.changed:connect(g)end function d.setLabel(f,g)if f.label==g then
return end f.label=g if f.kind=='label'then f.value=g local h=f._relayout if h
then h()end end redraw(f)end function d.setTip(f,g)f.tip=g end function d.
setDisabled(f,g,h)f.disabled=g==true f.disabledTip=h or f.disabledTip redraw(f)
end function d.setVisible(f,g)if f.visible==g then return end f.visible=g local
h=f._relayout if h then h()end end function d.setOptions(f,g)local h=f.spec h.
options=table.clone(g)if h.multi then if h.keep then for i,j in f.value do if j
and not table.find(h.options,i)then table.insert(h.options,i)end end else local
i=false for j in f.value do if not table.find(h.options,j)then f.value[j]=nil i=
true end end if i then f:notify()return end end elseif f.value~=nil and not
table.find(h.options,f.value)then if h.keep then table.insert(h.options,f.value)
else f.value=nil f:notify()return end end redraw(f)end function d.isModified(f)
if f.kind=='button'or f.kind=='label'or f.kind=='divider'or f.kind=='stat'then
return false end local g,h=f.value,f.default if g==nil or h==nil then return g~=
h end return not equal(f,g,h)end function d.attach(f,g)local h=f.addons if h==
nil then h={}f.addons=h end table.insert(h,g)g.host=f redraw(f)end function d.
shown(f)if not f.visible then return false end local g=f.guard return g==nil or
g()end return c end function a.t()local b=a.cache.t if not b then b={c=
__modImpl()}a.cache.t=b end return b.c end end do local function __modImpl()
local b=a.t()local c={}local d={}d.__index=d local function add(e,f,g,h,i,j)
local k=b.new(f,g or(f..'#'..tostring(e._page:nextId())),h,i,j)k.section=e k.
guard=e._guard e._page:_register(k,g~=nil)table.insert(e.rows,k)e._page:
_invalidate()return k end function d.toggle(e,f,g)local h=add(e,'toggle',f,g.
label or f,g,g.default==true)if g.onChanged then h:on(g.onChanged)end return h
end function d.slider(e,f,g)g.min=g.min or 0 g.max=g.max or 100 g.step=g.step or
1 if g.decimals==nil then local h=string.format('%.10f',g.step)local i=string.
match(h,'%.(%d-)0*$')g.decimals=if i then#i else 0 end local h=add(e,'slider',f,
g.label or f,g,g.default or g.min)if g.onChanged then h:on(g.onChanged)end
return h end function d.dropdown(e,f,g)g.options=g.options or{}local h=g.default
if h==nil and g.multi then h={}end local i=add(e,'dropdown',f,g.label or f,g,h)
if g.onChanged then i:on(g.onChanged)end return i end function d.input(e,f,g)
local h=add(e,'input',f,g.label or'',g,g.default or'')if g.onChanged then h:on(g
.onChanged)end return h end function d.key(e,f,g)local h=add(e,'key',f,g.label
or f,g,{key=g.default or'None',mode=g.mode or'Toggle',modifiers=g.modifiers or{}
})e._page.window.keys:register(h)return h end function d.color(e,f,g)local h=
add(e,'color',f,g.label or f,g,{color=g.default or Color3.new(1,1,1),alpha=g.
alphaValue or 0})if g.onChanged then h:on(g.onChanged)end return h end function
d.button(e,f,g)local h=if type(g)=='function'then{onPressed=g}else g h.saved=
false local i=add(e,'button',nil,f,h,nil)if h.onPressed then i:on(h.onPressed)
end return i end function d.label(e,f,g)local h=g or{}h.saved=false return add(e
,'label',nil,f,h,f)end function d.stat(e,f,g)return add(e,'stat',nil,f,{saved=
false},tostring(g))end function d.divider(e,f)return add(e,'divider',nil,f or'',
{saved=false},nil)end function d.addKey(e,f,g,h)local i=b.new('key',g,h.label or
f.label,h,{key=h.default or'None',mode=h.mode or'Toggle',modifiers=h.modifiers
or{}})i.section=e local j=i j.toggled=h.toggled==true e._page:_register(i,true)e
._page.window.keys:register(i)f:attach(i)return i end function d.addColor(e,f,g,
h)local i=b.new('color',g,h.label or f.label,h,{color=h.default or Color3.new(1,
1,1),alpha=h.alphaValue or 0})i.section=e e._page:_register(i,true)f:attach(i)if
h.onChanged then i:on(h.onChanged)end return i end function d.when(e,f,g)local h
=e._guard local i=f if h then i=function()return h()and f()end end local j=
setmetatable({rows=e.rows,title=e.title,_page=e._page,_guard=i,_root=e._root or
e},d)for k,l in(g or{})do l:on(function()e._page:_invalidate()end)end return j
end function c.new(e,f)return setmetatable({title=f,rows={},_page=e,_guard=nil,
_root=nil},d)end return c end function a.u()local b=a.cache.u if not b then b={c
=__modImpl()}a.cache.u=b end return b.c end end do local function __modImpl()
local b=a.q()local c=a.e()local d=a.n()local e=a.b()local f=a.u()local g=a.p()
local h={}local i=12 local j=600 local k=3 local l=20 local m=14 local n=28
local o=40 local p=26 local q=148 local r=76 local s=66 local t=360 local u=110
local v=24 local w=28 local x={toggle=4,button=4,key=4,color=4,slider=4,dropdown
=4,stat=3,input=8}local function spanOf(y)if y.kind=='label'and y.addons then
return 4 end return x[y.kind]end local y={}y.__index=y local function textHeight
(z,A)if z.kind=='divider'then return 28 end if not z.spec.wrap then return 32
end if z._measured then return z._measured end local B=math.max(math.floor(A/7.6
),10)local C=string.gsub(z.label,'<[^>]+>','')return math.ceil(#C/B)*21+12 end
function y.nextId(z)z._ids+=1 return z._ids end function y._register(z,A,B)A.
_relayout=function()z:_invalidate()end z.window:_registerElement(A,z,B)end
function y._invalidate(z)if z._dirty then return end z._dirty=true task.defer(
function()z._dirty=false if not z.destroyed then z:layout()end end)end function
y.section(z,A)local B=f.new(z,A)table.insert(z.sections,B)z:_invalidate()return
B end function y.tabset(z)local A=f.new(z,'')A.tabNames={}A.activeTab=1 table.
insert(z.sections,A)local B={}function B.tab(C,D)table.insert(A.tabNames,D)local
E=#A.tabNames local F=A:when(function()return A.activeTab==E end)F.title=D local
G=z._headers[A]if G then G:Destroy()z._headers[A]=nil end z:_invalidate()return
F end return B end function y.tabs(z,A)local B=z:tabset()local C={}for D,E in A
do table.insert(C,B:tab(E))end return C end function y.hero(z,A)z._hero=A z:
_invalidate()local B=z._heroView return{set=function(C,D,E)A.title=D or A.title
A.text=E or A.text local F=z._heroView or B if F then F.refresh()end end}end
local function buildHero(z)local A=z.window.ctx local B=A.theme local C=z._hero
local D=c('Frame',{Name='Hero',Parent=z.canvas})local E=c('Frame',{Size=UDim2.
fromOffset(q-16,q-16),BackgroundTransparency=0,ClipsDescendants=true,Parent=D})B
:paint(E,'BackgroundColor3','accent')if C.userId then c('ImageLabel',{Size=UDim2
.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,Image=string.format(
'rbxthumb://type=AvatarBust&id=%d&w=420&h=420',C.userId),Parent=E})end local F=
c('TextLabel',{Position=UDim2.fromOffset(q+2,16),Size=UDim2.new(1,-(q+2),0,68),
TextSize=64,TextTruncate=Enum.TextTruncate.AtEnd,Parent=D})B:type(F,'display')B:
paint(F,'TextColor3','text')local G=c('TextLabel',{Position=UDim2.fromOffset(q+2
,88),Size=UDim2.new(1,-(q+2),0,44),TextSize=17,TextWrapped=true,TextYAlignment=
Enum.TextYAlignment.Top,Parent=D})B:type(G,'text')B:paint(G,'TextColor3','muted'
)local H={root=D,refresh=function()F.Text=C.title G.Text=C.text or''end}H.
refresh()return H end local function buildHeader(z,A)local B=z.window.ctx local
C=B.theme local D=c('Frame',{Name='Header',Parent=z.canvas})if A.tabNames then
local E={}local F=0 for G,H in A.tabNames do local I=math.ceil(d.width(
'textMedium',H,18))+20 local J=c('TextButton',{Position=UDim2.fromOffset(F,0),
Size=UDim2.new(0,I,1,-8),TextSize=18,Text=H,TextXAlignment=Enum.TextXAlignment.
Left,Parent=D})C:type(J,'text',true)E[G]=J J.Activated:Connect(function()A.
activeTab=G for K,L in E do C:paint(L,'TextColor3',if K==A.activeTab then'text'
else'faint')end z:_invalidate()end)C:paint(J,'TextColor3',if G==A.activeTab then
'text'else'faint')F+=I end else local E=c('TextLabel',{Size=UDim2.new(1,0,1,-8),
TextSize=18,Text=A.title,Parent=D})C:type(E,'text',true)C:paint(E,'TextColor3',
'text')end return D end function y.layout(z)local A=z.frame if A==nil then
return end local B=z.window.ctx.uiScale()local C=A.AbsoluteSize.X/B if C<1 then
return end local D=C-2*l local E=D<j local F=(D-(i-1)*k)/i local G=m local H={}
if z._hero then table.insert(H,{hero=true,x=l,y=G,width=D,height=q})G+=q end for
I,J in z.sections do local K={}for L,M in J.rows do if M:shown()then table.
insert(K,M)end end if#K>0 or J.tabNames then if J.title~=''or J.tabNames then
table.insert(H,{section=J,x=l,y=G,width=D,height=o})G+=o end local L,M={},0
local function flush(N)if#L==0 then return end local O,P=l,0 for Q,R in L do
local S=R.span if Q==#L and not N and R.el.kind=='input'then S+=i-M end local T=
S*F+(S-1)*k local U=R.height P=math.max(P,U)table.insert(H,{el=R.el,x=O,y=G,
width=T,height=U})O+=T+k end G+=P+k L,M={},0 end for N,O in K do local P=spanOf(
O)if P==nil then flush(false)local Q=textHeight(O,D)table.insert(H,{el=O,x=l,y=G
,width=D,height=Q})G+=Q+k elseif O.spec.primary then flush(false)table.insert(H,
{el=O,x=l,y=G,width=D,height=r})G+=r+k else local Q=math.min(if E then P*2 else
P,i)if M+Q>i then flush(false)end table.insert(L,{el=O,span=Q,height=if O.kind==
'stat'then s else g.HEIGHT})M+=Q end end flush(true)G+=p end end local I=G-p+n A
.CanvasSize=UDim2.fromOffset(0,I)z._contentHeight=I z._placements=H z:
_applyPlacements()z:_materialize(true)z:_refreshThumb()end function y.
_applyPlacements(z)local A={}for B,C in z._placements do if C.hero then if z.
_heroView then z._heroView.root.Position=UDim2.fromOffset(C.x,C.y)z._heroView.
root.Size=UDim2.fromOffset(C.width,C.height)end elseif C.section then A[C.
section]=true local D=z._headers[C.section]if D then D.Visible=true D.Position=
UDim2.fromOffset(C.x,C.y)D.Size=UDim2.fromOffset(C.width,C.height)end else A[C.
el]=true local D=z._views[C.el]if D then z:_place(D,C)end end end for B,C in z.
_headers do if not A[B]then C.Visible=false end end for B,C in z._views do if
not A[B]then C.root.Visible=false end end end function y._place(z,A,B)local C=A.
root local D=UDim2.fromOffset(B.x,B.y)local E=C.Visible and C.Position~=D and z.
active C.Visible=true C.Size=UDim2.fromOffset(B.width,B.height)if E then if A.
_slide==nil then A._slide=A:own(e.prop(C,'Position',w))end A._slide:to(D)elseif
A._slide then A._slide:snap(D)else C.Position=D end end function y._materialize(
z,A)local B=z.frame local C=z._placements if B==nil or C==nil or not z.active
then return end local D=B.CanvasPosition.Y if not A and z._lastSync and math.
abs(D-z._lastSync)<t/3 then return end z._lastSync=D local E=z.window.ctx.
uiScale()local F,G=D-t,D+B.AbsoluteSize.Y/E+t for H,I in C do local J=I.y if J+I
.height>=F and J<=G then if I.hero then if z._heroView==nil then local K=
buildHero(z)K.root.Position=UDim2.fromOffset(I.x,J)K.root.Size=UDim2.fromOffset(
I.width,I.height)z._heroView=K end elseif I.section then if z._headers[I.section
]==nil then local K=buildHeader(z,I.section)K.Position=UDim2.fromOffset(I.x,J)K.
Size=UDim2.fromOffset(I.width,I.height)z._headers[I.section]=K end elseif z.
_views[I.el]==nil then local K,L=xpcall(b.build,debug.traceback,z.window.ctx,I.
el)if K then L.root.Position=UDim2.fromOffset(I.x,J)L.root.Size=UDim2.
fromOffset(I.width,I.height)L.root.Parent=z.canvas z._views[I.el]=L else warn(
'sottUI: tile '..tostring(I.el.id)..' failed: '..tostring(L))end end end end end
function y._refreshThumb(z)local A=z.thumb if A==nil then return end local B=z.
window.ctx.uiScale()local C=z.frame.AbsoluteSize.Y/B local D=z._contentHeight or
0 if D<=C+1 or not z.active then A.Visible=false return end A.Visible=true local
E=math.max(C*C/D,40)local F=C-E local G=z.frame.CanvasPosition.Y/math.max(D-C,1)
A.Size=UDim2.new(0,3,0,E)A.Position=UDim2.new(1,-6,0,G*F)end function y.scrollTo
(z,A,B)local C=z.frame if C==nil then return end local D=z.window.ctx.uiScale()
local E=math.max((z._contentHeight or 0)-C.AbsoluteSize.Y/D,0)local F=math.
clamp(A,0,E)z._scrollTarget=F if B then z._scroll:snap(F)else z._scroll:to(F)end
end function y.wheel(z,A)if z.frame==nil or z.frame.ScrollingEnabled then return
end z:scrollTo((z._scrollTarget or z.frame.CanvasPosition.Y)-A*u)end function y.
rowY(z,A)if z._placements==nil then z:layout()end for B,C in z._placements or{}
do if C.el==A then return C.y end end return nil end function y.viewOf(z,A)
return z._views[A]end function y.mount(z,A)if z.frame then return end local B=z.
window.ctx local C=c('ScrollingFrame',{Name=z.name,Size=UDim2.fromScale(1,1),
Visible=false,ScrollingEnabled=B.touch,Parent=A})local D=c('Frame',{Name=
'Canvas',Size=UDim2.fromScale(1,1),Parent=C})local E=c('Frame',{Name='Thumb',
BackgroundTransparency=0,Visible=false,ZIndex=5,Parent=A})B.theme:paint(E,
'BackgroundColor3','lineStrong')z.frame=C z.canvas=D z.thumb=E z._scroll=e.new(0
,v,function(F)C.CanvasPosition=Vector2.new(0,F)end)C:GetPropertyChangedSignal(
'CanvasPosition'):Connect(function()z:_materialize()z:_refreshThumb()end)local F
=0 C:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()local G=C.
AbsoluteSize.X if G~=F then F=G z:_invalidate()else z:_materialize(true)z:
_refreshThumb()end end)end function y.setActive(z,A)z.active=A if z.frame then z
.frame.Visible=A if not A then z.thumb.Visible=false end end if A then z:layout(
)end end function y.destroy(z)z.destroyed=true for A,B in z._views do B.destroy(
)end z._views={}if z._scroll then z._scroll:destroy()end if z.frame then z.frame
:Destroy()z.thumb:Destroy()end end function h.new(z,A)return setmetatable({name=
A,window=z,sections={},active=false,destroyed=false,_ids=0,_dirty=false,_headers
={},_views={},_placements=nil},y)end return h end function a.v()local b=a.cache.
v if not b then b={c=__modImpl()}a.cache.v=b end return b.c end end do local 
function __modImpl()local b=a.e()local c=a.b()local d=a.l()local e={}local f=600
local g=46 local h=68 local i=7 local j=34 local function describe(k)local l=k.
_pageName or''if k.kind=='toggle'then return(if k.value then'On, 'else'Off, ')..
l end if k.kind=='slider'then return tostring(k.value)..(k.spec.suffix or'')..
', '..l end if k.kind=='dropdown'and not k.spec.multi and k.value~=nil then
return tostring((k.spec.display or tostring)(k.value))..', '..l end return l end
function e.new(k,l,m,n)local o=k.theme local p={}local q=false local r,s,t,u
local v={}local w={}local x=1 local function close()if not q then return end q=
false r:Destroy()local y,z=s,t z:to(UDim2.fromOffset(f,0),function()z:destroy()y
:Destroy()end)table.clear(w)end local function draw()for y,z in w do local A=v[y
]if A then z.root.Visible=true z.name.Text=A.label z.where.Text=describe(A)z.
root.BackgroundTransparency=if y==x then 0 else 1 o:paint(z.name,'TextColor3',if
y==x then'onAccent'else'text')o:paint(z.where,'TextColor3',if y==x then
'onAccent'else'muted')else z.root.Visible=false end end local y=math.min(#v,i)
local z=h+(if y>0 then y*g+10 else 0)t:to(UDim2.fromOffset(f,z))end local 
function run(y)if y==nil then return end close()if y.kind=='toggle'and not y.
disabled then y:set(not y.value)k.notify({title=y.label,text=if y.value then'On'
else'Off',seconds=2})else n(y)end end local function query()local y=u.Text if y
==''then v={}for z,A in m()do if A.kind=='toggle'and A.value==true then table.
insert(v,A)if#v==i then break end end end else v=d.rank(y,m(),function(z)local A
=z.section and z.section.title or''return z.label..' '..(z._pageName or'')..' '
..A..' '..(z.tip or'')end,i)end x=1 draw()end function p.toggle(y)if q then
close()return end q=true local z=l.AbsoluteSize r=b('TextButton',{Size=UDim2.
fromScale(1,1),BackgroundTransparency=0.45,BackgroundColor3=Color3.new(0,0,0),
ZIndex=40,Parent=l})r.MouseButton1Down:Connect(close)s=b('Frame',{Name='Palette'
,Position=UDim2.fromOffset(math.floor((z.X-f)/2),math.floor(z.Y*0.22)),Size=
UDim2.fromOffset(f,0),BackgroundTransparency=0,ClipsDescendants=true,Active=true
,ZIndex=41,Parent=l})o:paint(s,'BackgroundColor3','surface')local A=b('UIStroke'
,{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=s})o:paint(A,'Color',
'lineStrong')t=c.prop(s,'Size',j)u=b('TextBox',{Position=UDim2.fromOffset(18,0),
Size=UDim2.new(1,-36,0,h),TextSize=36,Text='',PlaceholderText='Find a setting',
ZIndex=42,Parent=s})o:type(u,'display')o:paint(u,'TextColor3','text')o:paint(u,
'PlaceholderColor3','faint')for B=1,i do local C=b('TextButton',{Position=UDim2.
fromOffset(6,h+(B-1)*g+2),Size=UDim2.new(1,-12,0,g),Visible=false,ZIndex=42,
Parent=s})o:paint(C,'BackgroundColor3','accent')local D=b('TextLabel',{Position=
UDim2.fromOffset(12,0),Size=UDim2.new(0.6,-12,1,0),TextSize=16,TextTruncate=Enum
.TextTruncate.AtEnd,ZIndex=43,Parent=C})o:type(D,'text',true)o:paint(D,
'TextColor3','text')local E=b('TextLabel',{AnchorPoint=Vector2.new(1,0),Position
=UDim2.new(1,-12,0,0),Size=UDim2.new(0.4,-12,1,0),TextSize=16,TextTruncate=Enum.
TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=43,Parent=C})
o:type(E,'text')o:paint(E,'TextColor3','faint')w[B]={root=C,name=D,where=E}C.
MouseEnter:Connect(function()if x~=B then x=B draw()end end)C.Activated:Connect(
function()run(v[B])end)end u:GetPropertyChangedSignal('Text'):Connect(query)u.
FocusLost:Connect(function(B)if B then run(v[x])end end)query()u:CaptureFocus()
end function p.isOpen(y)return q end p.close=close function p.key(y,z)if not q
then return false end if z=='Escape'then close()return true end if z=='Down'or z
=='Up'then if#v>0 then x=math.clamp(x+(if z=='Down'then 1 else-1),1,#v)draw()end
return true end return false end return p end return e end function a.w()local b
=a.cache.w if not b then b={c=__modImpl()}a.cache.w=b end return b.c end end do
local function __modImpl()local b=a.h()local c={}local function rgb(d)return
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
FontFace=h:face(l.family,l.medium)end)end end return c end function a.x()local b
=a.cache.x if not b then b={c=__modImpl()}a.cache.x=b end return b.c end end do
local function __modImpl()local b=a.b()local c={}local d=26 function c.new(e)
local f={}return function(g,h,i,j)local k=f[g]if k==nil then k={}f[g]=k end
local l=k[h]if l==nil then l=b.prop(g,h,j or d)k[h]=l end l:to(e.tokens[i])end
end return c end function a.y()local b=a.cache.y if not b then b={c=__modImpl()}
a.cache.y=b end return b.c end end do local function __modImpl()local b=a.a()
local c=a.d()local d=a.f()local e=a.i()local f=a.j()local g=a.q()local h=a.g()
local i=a.e()local j=a.b()local k=a.r()local l=a.s()local m=a.v()local n=a.w()
local o=a.u()local p=a.h()local q=a.x()local r=a.y()local s={}local t='main'
local u=[[https://raw.githubusercontent.com/interestng/sottUI/%s/fonts/]]local v
=64 local w=34 local x=26 local y=22 local z=Vector2.new(900,640)local A=Vector2
.new(560,400)local B=20 local C=30 local D=22 local E=26 local F=34 local G=17
local H=12 local I={}I.__index=I local function randomName()local J=table.
create(H)for K=1,H do J[K]=string.char(math.random(97,122))end return table.
concat(J)end local function encode(J)return b.service('HttpService'):JSONEncode(
J)end local function decode(J)local K,L=pcall(function()return b.service(
'HttpService'):JSONDecode(J)end)return if K then L else nil end function I.
_registerElement(J,K,L,M)K._pageName=L.name K._page=L if M then if J.elements[K.
id]then error('sottUI: element id used twice: '..K.id,3)end J.elements[K.id]=K
end if K.kind~='divider'and K.kind~='label'and K.kind~='stat'then table.insert(J
.ordered,K)end end function I._syncMarker(J,K)local L=J._navItems[J.current]if L
==nil then return end local M=J._scale.Scale local N=J._navList local O=(L.
AbsolutePosition.X-N.AbsolutePosition.X)/M local P=O+L.AbsoluteSize.X/M local Q=
J._navClip.AbsoluteSize.X/M local R=J._navScroll.target if P+R>Q then R=Q-P end
if O+R<0 then R=-O end R=math.min(R,0)if K then J._edgeLeft:snap(O)J._edgeRight:
snap(P)J._navScroll:snap(R)return end local S=P>J._edgeRight.target J._edgeLeft.
speed=if S then G else F J._edgeRight.speed=if S then F else G J._edgeLeft:to(O)
J._edgeRight:to(P)J._navScroll:to(R)end function I.page(J,K)local L=m.new(J,K)
table.insert(J.pages,L)local M=#J.pages local N=J.ctx.theme local O=i(
'TextButton',{Name=K,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.new(0,0,1,0),
TextSize=w,Text=K,LayoutOrder=M,Parent=J._navList})N:type(O,'display')N:paint(O,
'TextColor3','faint')J._navItems[M]=O O.Activated:Connect(function()J:show(M)end
)O.MouseEnter:Connect(function()if J.current~=M then J.ctx.tint(O,'TextColor3',
'muted')end end)O.MouseLeave:Connect(function()if J.current~=M then J.ctx.tint(O
,'TextColor3','faint')end end)L:mount(J._pageHost)if J.current==nil then J:show(
M,true)end return L end function I.show(J,K,L)local M=J.pages[K]if M==nil or J.
current==K then return end J.ctx.hover.clear()J.ctx.popover:close()local N=J.ctx
.tint local O=J.pages[J.current]if O then O:setActive(false)N(J._navItems[J.
current],'TextColor3','faint')end local P=J.current==nil or K>J.current J.
current=K N(J._navItems[K],'TextColor3','text')M:setActive(true)J:_syncMarker(L)
J:_saveState()if L then return end local Q=if P then 1 else-1 J._pageSlide:snap(
UDim2.fromOffset(E*Q,0))J._pageSlide:to(UDim2.new())J._wipe.Visible=true J.
_wipeEdge.AnchorPoint=Vector2.new(if P then 1 else 0,0)J._wipeEdge.Position=
UDim2.fromScale(if P then 1 else 0,0)J._wipeAt:snap(UDim2.fromScale(0,0))J.
_wipeAt:to(UDim2.fromScale(-1.02*Q,0),function()J._wipe.Visible=false end)end
function I.showPage(J,K)for L,M in J.pages do if M.name==K then J:show(L)return
end end end function I.reveal(J,K)local L=K._page if L==nil then return end if
not J.isOpen then J:setOpen(true)end J:showPage(L.name)local M=K.host or K L:
layout()local N=L:rowY(M)if N then L:scrollTo(N-60)task.delay(0.26,function()
local O=L:viewOf(M)if O and O.root.Parent then O:flash()end end)end end function
I._targetSize(J)return if J.collapsed then UDim2.new(1,0,0,v)else UDim2.
fromScale(1,1)end function I.setOpen(J,K)if J.isOpen==K or J.destroyed then
return end J.isOpen=K J.ctx.hover.clear()J.ctx.popover:close()J._palette.close()
J.ctx.tooltip:hide()J._shutterEdge.Visible=true if K then J._root.Visible=true J
._modal.Visible=true J:_guardCursor(true)J._shutter.speed=B J._shutter:to(J:
_targetSize(),function()J._shutterEdge.Visible=false end)else J._modal.Visible=
false J:_guardCursor(false)J._shutter.speed=C J._shutter:to(UDim2.new(1,0,0,0),
function()J._shutterEdge.Visible=false if not J.isOpen then J._root.Visible=
false end end)end J.visibilityChanged:fire(K)end function I._guardCursor(J,K)
local L=b.service('UserInputService')if K then J._gameCursor=L.MouseIconEnabled
L.MouseIconEnabled=true if J._cursorGuard==nil then J._cursorGuard=L:
GetPropertyChangedSignal('MouseIconEnabled'):Connect(function()if not L.
MouseIconEnabled then J._gameCursor=false L.MouseIconEnabled=true end end)end
else if J._cursorGuard then J._cursorGuard:Disconnect()J._cursorGuard=nil end if
J._gameCursor~=nil then L.MouseIconEnabled=J._gameCursor J._gameCursor=nil end
end end function I.toggle(J)J:setOpen(not J.isOpen)end function I.collapse(J,K)J
.collapsed=K J._shutter:to(J:_targetSize())J._grip.Visible=not K J:_saveState()
end function I.notify(J,K)if J.destroyed then return end J.ctx.notify(K)end
function I.setTheme(J,K)J.ctx.theme:apply(K)end function I.setScale(J,K)J._scale
.Scale=math.clamp(K,0.7,1.5)J:_clamp()J:_saveState()end function I.setSubtitle(J
,K)J._subtitleLabel.Text=K end function I._clamp(J)local K=J._gui.AbsoluteSize
local L=J.size*J._scale.Scale local M=math.clamp(J.position.X,0,math.max(K.X-L.X
,0))local N=math.clamp(J.position.Y,0,math.max(K.Y-L.Y,0))J.position=Vector2.
new(M,N)J._root.Position=UDim2.fromOffset(M,N)end function I._saveState(J)local
K=J._files if K==nil or J._stateFile==nil or J._stateQueued then return end J.
_stateQueued=true task.delay(0.5,function()J._stateQueued=false if J.destroyed
then return end local L=J.pages[J.current]K.write(J._stateFile,encode({x=J.
position.X,y=J.position.Y,w=J.size.X,h=J.size.Y,page=L and L.name,scale=J._scale
.Scale,collapsed=J.collapsed}))end)end function I.restorePage(J)local K=J.
_savedPage if K then J._savedPage=nil for L,M in J.pages do if M.name==K then J:
show(L,true)return end end end end function I.dialog(J,K,L)if J.destroyed then
return false end local M=J.ctx local N=M.theme local O=J._layer local P=K.width
or 460 local Q=K.maxHeight or 340 local R=60 local S=i('TextButton',{Size=UDim2.
fromScale(1,1),BackgroundTransparency=1,BackgroundColor3=Color3.new(0,0,0),
ZIndex=50,Parent=O})local T=j.prop(S,'BackgroundTransparency',22)T:to(0.4)local
U=i('Frame',{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
Size=UDim2.fromOffset(P,0),BackgroundTransparency=0,ClipsDescendants=true,Active
=true,ZIndex=51,Parent=O})N:paint(U,'BackgroundColor3','base')local V=i(
'UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=U})N:paint(V,
'Color','lineStrong')local W=i('TextLabel',{Position=UDim2.fromOffset(20,16),
Size=UDim2.new(1,-40,0,40),TextSize=36,Text=K.title or'',ZIndex=52,Parent=U})N:
type(W,'display')N:paint(W,'TextColor3','text')local X=60 local Y=K.text if Y
and Y~=''then local Z=i('TextLabel',{Position=UDim2.fromOffset(20,X),Size=UDim2.
new(1,-40,0,22),AutomaticSize=Enum.AutomaticSize.Y,TextSize=16,TextWrapped=true,
Text=Y,ZIndex=52,Parent=U})N:type(Z,'text')N:paint(Z,'TextColor3','muted')X+=22+
math.floor(#Y/52)*22+12 end local Z=i('ScrollingFrame',{Position=UDim2.
fromOffset(20,X),Size=UDim2.new(1,-40,0,0),ScrollBarThickness=3,ZIndex=52,Parent
=U})N:paint(Z,'ScrollBarImageColor3','lineStrong')local _=false local aa={window
=J,name='Dialog',nextId=function()J._dialogIds+=1 return J._dialogIds end,
_register=function(aa,ab,ac)ab._pageName='Dialog'if ac then J.elements[ab.id]=ab
end end,_invalidate=function()end}local ab=o.new(aa,'')local ac,ad=xpcall(L,
debug.traceback,ab)if not ac then warn('sottUI: dialog build failed: '..
tostring(ad))end local ae={}local af=0 for ag,ah in ab.rows do if ah:shown()then
local ai=g.build(M,ah)local aj=if ah.kind=='label'or ah.kind=='divider'then 32
else R ai.root.Position=UDim2.fromOffset(0,af)ai.root.Size=UDim2.new(1,0,0,aj)ai
.root.Parent=Z af+=aj+3 table.insert(ae,ai)end end Z.CanvasSize=UDim2.
fromOffset(0,af)local ag=math.min(af,Q)Z.Size=UDim2.new(1,-40,0,ag)local ah=X+ag
+12 local ai=i('TextButton',{Position=UDim2.fromOffset(20,ah),Size=UDim2.new(1,-
40,0,54),BackgroundTransparency=0,TextSize=28,Text=K.done or'Done',ZIndex=52,
Parent=U})N:type(ai,'display')N:paint(ai,'BackgroundColor3','text')N:paint(ai,
'TextColor3','base')local aj=ah+54+20 local ak=j.prop(U,'Size',B+6)ak:to(UDim2.
fromOffset(P,aj))local function close()if _ then return end _=true J.
_dialogClose=nil S.Active=false for al,am in ab.rows do if J.elements[am.id]==am
then J.elements[am.id]=nil end end if K.onClose then task.spawn(K.onClose)end T:
to(1,function()T:destroy()S:Destroy()end)ak:to(UDim2.fromOffset(P,0),function()
for al,am in ae do am.destroy()end ak:destroy()U:Destroy()end)end J._dialogClose
=close S.MouseButton1Down:Connect(close)ai.Activated:Connect(close)return true
end function I.find(aa,ab)return aa.elements[ab]end function I.snapshot(aa)local
ab={}for ac,ad in aa.elements do if ad.saved then local ae=ad.value if ad.kind==
'color'then ae={hex=ae.color:ToHex(),alpha=ae.alpha}elseif ad.kind=='key'then ae
={key=ae.key,mode=ae.mode,modifiers=ae.modifiers,toggled=ad.toggled==true}end ab
[ac]=ae end end return ab end function I.restore(aa,ab)for ac,ad in ab do local
ae=aa.elements[ac]if ae and ae.saved then if ae.kind=='color'and type(ad)==
'table'then ae:set({color=Color3.fromHex(ad.hex or'ffffff'),alpha=ad.alpha})
elseif ae.kind=='key'and type(ad)=='table'then ae:set(ad)ae.toggled=ad.toggled==
true else ae:set(ad)end end end end function I.destroy(aa)if aa.destroyed then
return end aa.destroyed=true aa:_guardCursor(false)aa.ctx.notifications:destroy(
)for ab,ac in aa.pages do ac:destroy()end aa.ctx.input:destroy()aa._maid:clean()
aa.visibilityChanged:clear()if aa._registry and aa._registry.current==aa then aa
._registry.current=nil end end local function headerButton(aa,ab,ac,ad)local ae=
i('TextButton',{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,ac,0.5,0),
Size=UDim2.fromOffset(44,v),BackgroundTransparency=1,Parent=ab})aa.theme:paint(
ae,'BackgroundColor3','raised')local af=ad(ae,'muted')af.AnchorPoint=Vector2.
new(0.5,0.5)af.Position=UDim2.fromScale(0.5,0.5)local ag=j.prop(ae,
'BackgroundTransparency',28)ae.MouseEnter:Connect(function()ag:to(0)end)ae.
MouseLeave:Connect(function()ag:to(1)end)return ae end function s.new(aa)local
ab=aa._registry if ab and ab.current then ab.current:destroy()end local ac=h.
new()local ad=q.new(aa.theme)local ae=e.new()local af=b.service(
'UserInputService')local ag=af.TouchEnabled and not af.MouseEnabled local ah=i(
'ScreenGui',{Name=randomName(),IgnoreGuiInset=true,ResetOnSpawn=false,
ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=aa.displayOrder or 10000
})b.protect(ah)ah.Parent=b.guiParent()ac:add(ah)local ai=b.files()local aj=aa.
folder or'sottui'local ak=aa.stateFile or(aj..'/window.json')local al=nil if ai
then ai.folder(aj)local am=ai.read(ak)al=am and decode(am)end if type(al)~=
'table'then al={}end local am=ah.AbsoluteSize local J=Vector2.new(math.clamp(
tonumber(al.w)or z.X,A.X,math.max(am.X,A.X)),math.clamp(tonumber(al.h)or z.Y,A.Y
,math.max(am.Y,A.Y)))local K=tonumber(al.scale)or(if am.X<800 then 0.8 else 1)
local L=Vector2.new(tonumber(al.x)or math.floor((am.X-J.X*K)/2),tonumber(al.y)or
math.floor((am.Y-J.Y*K)/2))local M=i('Frame',{Name='Root',Size=UDim2.fromOffset(
J.X,J.Y),Position=UDim2.fromOffset(L.X,L.Y),Parent=ah})local N=i('UIScale',{
Scale=K,Parent=M})local O=i('Frame',{Name='Clip',Size=UDim2.new(1,0,0,0),
BackgroundTransparency=0,ClipsDescendants=true,Active=true,Parent=M})ad:paint(O,
'BackgroundColor3','base')local P=i('Frame',{Name='Layer',Size=UDim2.fromScale(1
,1),ZIndex=100,Parent=ah})local Q=i('TextButton',{Name='Modal',Size=UDim2.
fromOffset(0,0),Modal=true,Visible=false,Parent=M})local R=i('TextButton',{Name=
'Bar',Size=UDim2.new(1,0,0,v),Parent=O})local S=i('TextLabel',{AutomaticSize=
Enum.AutomaticSize.X,Position=UDim2.fromOffset(20,0),Size=UDim2.fromOffset(0,v),
TextSize=x,Text=aa.title or'sottoro',Parent=R})ad:type(S,'display')ad:paint(S,
'TextColor3','accent')local T=i('Frame',{Name='NavClip',Size=UDim2.new(1,0,0,v),
ClipsDescendants=true,Parent=O})local U=i('Frame',{Name='NavRail',Size=UDim2.
fromScale(1,1),Parent=T})local V=i('Frame',{Name='NavList',AutomaticSize=Enum.
AutomaticSize.X,Size=UDim2.new(0,0,1,0),Parent=U})i('UIListLayout',{
FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,y),SortOrder=Enum
.SortOrder.LayoutOrder,Parent=V})local W=i('Frame',{Name='Marker',AnchorPoint=
Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.new(0,0,0,4),
BackgroundTransparency=0,ZIndex=2,Parent=U})ad:paint(W,'BackgroundColor3',
'accent')local X=i('Frame',{Position=UDim2.new(0,0,0,v-1),Size=UDim2.new(1,0,0,1
),BackgroundTransparency=0,Parent=O})ad:paint(X,'BackgroundColor3','line')local
Y=i('Frame',{Name='Body',Position=UDim2.fromOffset(0,v),Size=UDim2.new(1,0,1,-v)
,ClipsDescendants=true,Parent=O})local Z=i('Frame',{Name='Pages',Size=UDim2.
fromScale(1,1),Parent=Y})local _=i('Frame',{Name='Wipe',Size=UDim2.fromScale(1,1
),BackgroundTransparency=0,Visible=false,ZIndex=8,Parent=Y})ad:paint(_,
'BackgroundColor3','base')local an=i('Frame',{Size=UDim2.new(0,8,1,0),
BackgroundTransparency=0,ZIndex=9,Parent=_})ad:paint(an,'BackgroundColor3',
'accent')local ao=i('Frame',{AnchorPoint=Vector2.new(0,1),Position=UDim2.
fromScale(0,1),Size=UDim2.new(1,0,0,4),BackgroundTransparency=0,Visible=false,
ZIndex=12,Parent=O})ad:paint(ao,'BackgroundColor3','accent')local ap=i(
'TextButton',{Name='Grip',AnchorPoint=Vector2.new(1,1),Position=UDim2.fromScale(
1,1),Size=UDim2.fromOffset(20,20),ZIndex=6,Parent=O})for aq,ar in{{UDim2.new(1,-
3,1,-3),UDim2.fromOffset(10,2)},{UDim2.new(1,-3,1,-3),UDim2.fromOffset(2,10)}}do
local as=i('Frame',{AnchorPoint=Vector2.new(1,1),Position=ar[1],Size=ar[2],
BackgroundTransparency=0,ZIndex=7,Name='Tick'..aq,Parent=ap})ad:paint(as,
'BackgroundColor3','lineStrong')end local aq=setmetatable({ctx=nil,pages={},
elements={},ordered={},current=nil,isOpen=false,collapsed=al.collapsed==true,
destroyed=false,size=J,position=L,visibilityChanged=p.new(),_maid=ac,_gui=ah,
_root=M,_clip=O,_layer=P,_modal=Q,_scale=N,_navClip=T,_navList=V,_navItems={},
_pageHost=Z,_wipe=_,_wipeEdge=an,_shutterEdge=ao,_grip=ap,_files=ai,_stateFile=
ak,_savedPage=al.page,_dialogIds=0,_registry=ab},I)if ab then ab.current=aq end
local ar={theme=ad,input=ae,touch=ag,glyph=d.new(ad),tint=r.new(ad),uiScale=
function()return N.Scale end,setScrollLocked=function(ar)local as=aq.pages[aq.
current]if as and as.frame and ag then as.frame.ScrollingEnabled=not ar end end}
aq.ctx=ar ar.popover=l.popover(ar,P)ar.tooltip=l.tooltip(ar,P)ar.hover=l.hover(
ar)ar.notifications=k.new(ar,P)ar.notify=function(as)ar.notifications:show(as)
end aq.keys=f.new(ae,b,function()return aq.isOpen end)ar.keys=aq.keys local 
function drawMarker()local as,at=aq._markerLeft,aq._markerRight W.Position=UDim2
.new(0,as,1,0)W.Size=UDim2.new(0,math.max(at-as,0),0,4)end aq._markerLeft,aq.
_markerRight=0,0 aq._edgeLeft=ac:add(j.new(0,F,function(as)aq._markerLeft=as
drawMarker()end))aq._edgeRight=ac:add(j.new(0,F,function(as)aq._markerRight=as
drawMarker()end))aq._navScroll=ac:add(j.new(0,F,function(as)U.Position=UDim2.
fromOffset(as,0)end))aq._pageSlide=ac:add(j.prop(Z,'Position',D))aq._wipeAt=ac:
add(j.prop(_,'Position',D))aq._shutter=ac:add(j.prop(O,'Size',B))aq._palette=n.
new(ar,P,function()return aq.ordered end,function(as)aq:reveal(as)end)local as=
headerButton(ar,R,0,function(as,at)return ar.glyph.cross(as,at)end)as.Activated:
Connect(function()aq:setOpen(false)end)local at=headerButton(ar,R,-44,function(
at,au)return ar.glyph.dash(at,au)end)at.Activated:Connect(function()aq:collapse(
not aq.collapsed)end)local au=i('TextButton',{AnchorPoint=Vector2.new(1,0.5),
Position=UDim2.new(1,-96,0.5,0),Size=UDim2.fromOffset(64,v),TextSize=17,Text=
'Search',TextXAlignment=Enum.TextXAlignment.Right,Parent=R})ad:type(au,'text',
true)ad:paint(au,'TextColor3','muted')au.MouseEnter:Connect(function()ar.tint(au
,'TextColor3','text')end)au.MouseLeave:Connect(function()ar.tint(au,'TextColor3'
,'muted')end)au.Activated:Connect(function()aq._palette:toggle()end)local av=i(
'TextLabel',{AutomaticSize=Enum.AutomaticSize.X,AnchorPoint=Vector2.new(1,0.5),
Position=UDim2.new(1,-176,0.5,0),Size=UDim2.fromOffset(0,v),TextSize=17,Text=aa.
subtitle or'',TextXAlignment=Enum.TextXAlignment.Right,Parent=R})ad:type(av,
'text')ad:paint(av,'TextColor3','faint')aq._subtitleLabel=av local function 
fitBar()local aw=N.Scale local ax=M.AbsoluteSize.X/aw local ay=20+S.AbsoluteSize
.X/aw+24 local az=V.AbsoluteSize.X/aw local aA=176+av.AbsoluteSize.X/aw+20 av.
Visible=aa.subtitle~=nil and ay+az+aA<=ax local aB=if av.Visible then aA else
176 T.Position=UDim2.fromOffset(ay,0)T.Size=UDim2.new(1,-(ay+aB),0,v)aq:
_syncMarker(true)end aq._fitBar=fitBar S:GetPropertyChangedSignal('AbsoluteSize'
):Connect(fitBar)av:GetPropertyChangedSignal('AbsoluteSize'):Connect(fitBar)M:
GetPropertyChangedSignal('AbsoluteSize'):Connect(fitBar)V:
GetPropertyChangedSignal('AbsoluteSize'):Connect(fitBar)task.defer(fitBar)R.
InputBegan:Connect(function(aw)local ax=aw.UserInputType if ax~=Enum.
UserInputType.MouseButton1 and ax~=Enum.UserInputType.Touch then return end
local ay=if ax==Enum.UserInputType.Touch then ae:at(aw)else ae:pointer()local az
=aq.position ae:capture(function(aA)aq.position=az+(aA-ay)aq:_clamp()aq:
_saveState()end)end)ap.InputBegan:Connect(function(aw)local ax=aw.UserInputType
if ax~=Enum.UserInputType.MouseButton1 and ax~=Enum.UserInputType.Touch then
return end local ay=if ax==Enum.UserInputType.Touch then ae:at(aw)else ae:
pointer()local az=aq.size ae:capture(function(aA)local aB=N.Scale local aC=az+(
aA-ay)/aB local aD=(ah.AbsoluteSize-aq.position)/aB aq.size=Vector2.new(math.
clamp(aC.X,A.X,math.max(aD.X,A.X)),math.clamp(aC.Y,A.Y,math.max(aD.Y,A.Y)))M.
Size=UDim2.fromOffset(math.floor(aq.size.X),math.floor(aq.size.Y))aq:_saveState(
)end)end)ae.moved:connect(function(aw)ar.hover:verify(aw)end)ae.wheel:connect(
function(aw)if not aq.isOpen or ar.popover:isOpen()or aq._palette:isOpen()then
return end local ax=aq.pages[aq.current]if ax==nil or ax.frame==nil then return
end local ay=ae:pointer()local az,aA=ax.frame.AbsolutePosition,ax.frame.
AbsoluteSize if ay.X>=az.X and ay.Y>=az.Y and ay.X<=az.X+aA.X and ay.Y<=az.Y+aA.
Y then ax:wheel(aw)end end)ae.keyDown:connect(function(aw,ax)if aw.UserInputType
~=Enum.UserInputType.Keyboard then return end local ay=aw.KeyCode.Name if aq.
_palette:key(ay)or ar.popover:key(ay)then return end if ay=='Escape'and aq.
_dialogClose then aq._dialogClose()return end if ax or ae:typing()then return
end if aq.isOpen and ay=='K'then if af:IsKeyDown(Enum.KeyCode.LeftControl)or af:
IsKeyDown(Enum.KeyCode.RightControl)then aq._palette:toggle()end end end)ac:add(
ah:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()aq:_clamp()end))ac
:add(ad.changed:connect(function()for aw,ax in aq.pages do for ay,az in ax.
_views do pcall(az.refresh)end end end))if ag then local aw=i('TextButton',{Name
='Reopen',Position=UDim2.fromOffset(16,80),Size=UDim2.fromOffset(112,44),
BackgroundTransparency=0,TextSize=22,Text=aa.title or'sottoro',Visible=false,
Parent=ah})ad:type(aw,'display')ad:paint(aw,'BackgroundColor3','accent')ad:
paint(aw,'TextColor3','onAccent')local ax=false aw.InputBegan:Connect(function(
ay)if ay.UserInputType~=Enum.UserInputType.Touch then return end ax=false local
az=ae:at(ay)local aA=aw.AbsolutePosition ae:capture(function(aB)local aC=aB-az
if aC.Magnitude>8 then ax=true aw.Position=UDim2.fromOffset(aA.X+aC.X,aA.Y+aC.Y)
end end)end)aw.Activated:Connect(function()if not ax then aq:setOpen(true)end
end)aq.visibilityChanged:connect(function(ay)aw.Visible=not ay end)end local aw=
o.new({window=aq,nextId=function()return 0 end,_register=function(aw,ax,ay)if ay
then aq.elements[ax.id]=ax end ax._pageName=''end,_invalidate=function()end},'')
aq.menuKey=aw:key('__menu',{label='Menu',default=aa.key or'RightShift',mode=
'Toggle',saved=false,onPress=function()aq:toggle()end})local ax=b.service(
'RunService')j.setAttach(function(ay)return ax.PreRender:Connect(ay)end)aq:
_clamp()if aa.fonts~=false and ai then ac:add(task.defer(function()local ay=aa.
fontTag or t local az=c.load(aj..'/fonts',string.format(u,ay),encode)if not aq.
destroyed and(az.text or az.display)then ad:setFonts(az.text,az.display)end end)
)end if aa.autoShow~=false then task.defer(function()aq:setOpen(true)end)end
return aq end function s.setVersion(aa)t=aa end return s end function a.z()local
aa=a.cache.z if not aa then aa={c=__modImpl()}a.cache.z=aa end return aa.c end
end end local aa=a.a()local ab=a.b()local ac=a.c()local ad=a.z()local ae='0.1.0'
local function registry()local af=aa.global('getgenv')local ag=if type(af)==
'function'then af()else _G local ah=ag.__sottui if type(ah)~='table'then ah={
current=nil}ag.__sottui=ah end return ah end local af={version=ae,motion=ab}ad.
setVersion('v'..ae)function af.window(ag)local ah=table.clone(ag or{})ah.
_registry=registry()return ad.new(ah)end function af.current()return registry().
current end function af.obsidian()return ac.new(af)end return af