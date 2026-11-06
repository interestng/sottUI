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
__modImpl()local b=a.a()local c={}local function isEmpty(d)return type(d)~=
'string'or string.gsub(d,'%s','')==''end function c.new(d)local e={Folder=
'ObsidianLibSettings',SubFolder='',Ignore={},AutoloadConfig=nil,Library=d}local 
function http()return b.service('HttpService')end local function settings()local
f=e.Folder..'/settings'if e.SubFolder~=''then f..='/'..e.SubFolder end return f
end local function globalFn(f)return b.global(f)end local function configPath(f)
return settings()..'/'..f..'.json'end local function ensure()local f=b.files()if
f then f.folder(settings())f.folder(e.Folder..'/themes')end end local function 
configExists(f)local g=b.files()return g~=nil and g.exists(configPath(f))end
function e.SetLibrary(f)end function e.SetFolder(f,g)e.Folder=g ensure()end
function e.SetSubFolder(f,g)e.SubFolder=g ensure()end function e.
SetIgnoreIndexes(f,g)for h,i in g do e.Ignore[i]=true end end function e.
IgnoreThemeSettings(f)e:SetIgnoreIndexes({'ThemeManager_Preset',
'ThemeManager_Scale','ThemeManager_Motion'})end function e.RefreshConfigList(f)
local g=globalFn('listfiles')if type(g)~='function'then return{}end ensure()
local h,i=pcall(g,settings())if not h or type(i)~='table'then return{}end local
j={}for k,l in i do local m=string.gsub(l,'\\','/')local n=string.match(m,
'([^/]+)%.[^/.]+$')if n and n~='autoload'then table.insert(j,n)end end table.
sort(j)return j end local f={Toggle=function(f)return{value=f.Value}end,Slider=
function(f)return{value=tostring(f.Value)}end,Dropdown=function(f)local g=f.
Value if typeof(g)=='Instance'then g=g.Name end return{value=g,multi=f.Multi}end
,ColorPicker=function(f)return{value=f.Value:ToHex(),transparency=f.Transparency
}end,KeyPicker=function(f)return{mode=f.Mode,key=f.Value,modifiers=f.Modifiers,
toggled=f.Toggled}end,Input=function(f)return{text=f.Value}end}local g={Toggle=
function(g,h)if g.Value==h.value then g:RunChanged()else g:SetValue(h.value)end
end,Slider=function(g,h)if g.Value==h.value then g:RunChanged()else g:SetValue(h
.value)end end,Dropdown=function(g,h)if g.Value==h.value then g:RunChanged()else
g:SetValue(h.value)end end,ColorPicker=function(g,h)g:SetValueRGB(Color3.
fromHex(h.value),h.transparency)end,KeyPicker=function(g,h)g:SetValue({h.key,h.
mode,h.modifiers})if h.mode=='Toggle'and h.toggled~=nil then g.Toggled=h.toggled
g._el.toggled=h.toggled g:Update()end end,Input=function(g,h)if type(h.text)~=
'string'then return end if g.Value==h.text then g:RunChanged()else g:SetValue(h.
text)end end}function e.SaveJSON(h,i)local j={}local function collect(k)for l,m
in k do local n=f[m.Type]if n and not e.Ignore[l]then local o=n(m)o.type=m.Type
o.idx=l table.insert(j,o)end end end collect(d.Toggles)collect(d.Options)local k
,l=pcall(function()return http():JSONEncode({timestamp=os.date(
'%d.%m.%Y %H:%M:%S'),name=i or'',objects=j})end)if not k then return'',false,
'Failed to encode data'end return l,true end function e.Save(h,i)if isEmpty(i)or
string.lower(i)=='autoload'then return false,'Invalid config name provided'end
ensure()local j,k,l=e:SaveJSON(i)if not k then return false,l end local m=b.
files()if m==nil or not m.write(configPath(i),j)then return false,
'Failed to write config file'end return true end function e.LoadJSON(h,i)if
isEmpty(i)then return false,'No JSON provided'end local j,k=pcall(function()
return http():JSONDecode(i)end)if not j or type(k)~='table'or type(k.objects)~=
'table'then return false,'Failed to decode config data'end for l,m in k.objects
do local n=g[m.type]if n and not e.Ignore[m.idx]then task.defer(function()local
o=d.Toggles[m.idx]or d.Options[m.idx]if o and o.Type==m.type then local p,q=
pcall(n,o,m)if not p then warn('sottUI compat: config value '..tostring(m.idx)..
' failed: '..tostring(q))end end end)end end return true end function e.Load(h,i
)if isEmpty(i)then return false,'No config is selected'end local j=b.files()
local k=j and j.read(configPath(i))if k==nil then return false,
'Config file does not exist'end return e:LoadJSON(k)end function e.Delete(h,i)if
isEmpty(i)then return false,'No config is selected'end if not configExists(i)
then return false,'Config file does not exist'end local j=globalFn('delfile')
local k,l=pcall(j,configPath(i))if not k then return false,
'Failed to delete config file: '..tostring(l)end if i==e.AutoloadConfig then e:
DeleteAutoLoadConfig()end return true end local function autoloadPath()return
settings()..'/autoload.txt'end function e.GetAutoloadConfig(h)ensure()local i=b.
files()local j=i and i.read(autoloadPath())if j==nil then return'none',false,
'Autoload config is not set'end if not configExists(j)then return'none',false,
'Config file not found'end e.AutoloadConfig=j return j,true end function e.
SaveAutoloadConfig(h,i)if isEmpty(i)then return false,'No config is selected'end
if not configExists(i)then return false,'Config does not exist'end local j=b.
files()if j==nil or not j.write(autoloadPath(),i)then return false,
'Failed to write the autoload file'end e.AutoloadConfig=i return true end
function e.DeleteAutoLoadConfig(h)local i=b.files()if i==nil or not i.exists(
autoloadPath())then return false,'Autoload config is not set'end local j=
globalFn('delfile')local k,l=pcall(j,autoloadPath())if not k then return false,
tostring(l)end e.AutoloadConfig=nil return true end function e.
LoadAutoloadConfig(h)local i,j,k=e:GetAutoloadConfig()if not j or k then if k~=
'Autoload config is not set'then d:Notify(string.format(
'Failed to load autoload config: %s',tostring(k)))end return end local l,m=e:
Load(i)if not l then d:Notify(string.format('Failed to load autoload config: %s'
,tostring(m)))return end d:Notify(string.format('Loaded config %q',i))end
function e.BuildConfigSection(h,i)local j=i:AddGroupbox({Name='Configs'})local k
=j:AddInput('SaveManager_ConfigName',{Text='Name',Placeholder='New config'})
local l=j:AddDropdown('SaveManager_ConfigList',{Text='Saved',Values=e:
RefreshConfigList(),AllowNull=true,FormatDisplayValue=function(l)return if l==e.
AutoloadConfig then l..' (autoload)'else tostring(l)end})e.Ignore[
'SaveManager_ConfigName']=true e.Ignore['SaveManager_ConfigList']=true local 
function refresh()l:SetValues(e:RefreshConfigList())end local function selected(
)local m=l.Value if isEmpty(m)then d:Notify('Pick a config first')return nil end
return m end local function report(m,n,o)d:Notify(if m then o else tostring(n))
end j:AddButton('Create',function()local m=k.Value if isEmpty(m)then d:Notify(
'Give the config a name first')return end local n,o=e:Save(m)report(n,o,string.
format('Created %q',m))refresh()end)j:AddButton({Text='Load',Func=function()
local m=selected()if m then local n,o=e:Load(m)report(n,o,string.format(
'Loaded %q',m))end end})j:AddButton({Text='Overwrite',DoubleClick=true,Func=
function()local m=selected()if m then local n,o=e:Save(m)report(n,o,string.
format('Saved over %q',m))end end})j:AddButton({Text='Load at start',Func=
function()local m=selected()if m then local n,o=e:SaveAutoloadConfig(m)report(n,
o,string.format('%q loads at start',m))refresh()end end})j:AddButton({Text=
'Load nothing at start',Func=function()local m,n=e:DeleteAutoLoadConfig()report(
m,n,'No config loads at start')refresh()end})j:AddButton('Refresh list',refresh)
j:AddButton({Text='Delete',DoubleClick=true,Risky=true,Func=function()local m=
selected()if m then local n,o=e:Delete(m)report(n,o,string.format('Deleted %q',m
))l:SetValue(nil)refresh()end end})return j end return e end return c end
function a.c()local b=a.cache.c if not b then b={c=__modImpl()}a.cache.c=b end
return b.c end end do local function __modImpl()local b=a.a()local c={}local 
function derive(d)local e,f,g=d:ToHSV()return{accent=d,accentHover=Color3.
fromHSV(e,f*0.8,math.min(g*1.08,1)),accentDim=Color3.fromHSV(e,math.min(f*1.2,1)
,0.2)}end local d={Mint=Color3.fromHex('7EE0C4'),Moss=Color3.fromHex('C5ECAE'),
Lichen=Color3.fromHex('E9DEAA'),Ember=Color3.fromHex('F0A35A'),Sky=Color3.
fromHex('7AB8E0'),Bone=Color3.fromHex('EBE8DA')}local e={'Mint','Moss','Lichen',
'Ember','Sky','Bone'}function c.new(f)local g={Folder='ObsidianLibSettings'}
local function defaultPath()return g.Folder..'/themes/default.txt'end function g
.SetLibrary(h)end function g.SetFolder(h,i)g.Folder=i local j=b.files()if j then
j.folder(i..'/themes')end end function g.SaveDefault(h,i)local j=b.files()if j
then j.write(defaultPath(),i)end end function g.ApplyTheme(h,i)local j=d[i]if j
then f.window:setTheme(derive(j))f.Scheme.AccentColor=j end end function g.
ApplyToTab(h,i)local j=i:AddGroupbox({Name='Look'})local k=b.files()local l=k
and k.read(defaultPath())local m=if l and d[l]then l else'Mint'j:AddDropdown(
'ThemeManager_Preset',{Text='Color',Values=e,Default=m,Callback=function(n)if n
then g:ApplyTheme(n)g:SaveDefault(n)end end})j:AddSlider('ThemeManager_Scale',{
Text='Size',Min=70,Max=150,Default=math.round(f.window._scale.Scale*100),Suffix=
'%',Rounding=0,Callback=function(n)f.window:setScale(n/100)end})g:ApplyTheme(m)
return j end return g end return c end function a.d()local b=a.cache.d if not b
then b={c=__modImpl()}a.cache.d=b end return b.c end end do local function 
__modImpl()local b=a.a()local c=a.c()local d=a.d()local e={}local function warnf
(f)warn('sottUI compat: '..f)end local function protect(f,...)if type(f)~=
'function'then return end local g,h=xpcall(f,debug.traceback,...)if not g then
warnf('callback failed: '..tostring(h))end end local f={}f.__index=f function f.
RunChanged(g,...)if g.Disabled then return end local h=g.Value if select('#',...
)>0 then protect(g.Callback,...)protect(g.Changed,...)else protect(g.Callback,h)
protect(g.Changed,h)end end function f.OnChanged(g,h)g.Changed=h end function f.
SetVisible(g,h)g.Visible=h g._el:setVisible(h)end function f.SetDisabled(g,h)g.
Disabled=h==true g._el:setDisabled(g.Disabled)if g._lib then g._lib:
_rulesChanged()end end function f.SetText(g,h)g.Text=h g._el:setLabel(h)end
function f.Update(g)end local function class()local g=setmetatable({},{__index=f
})g.__index=g return g end local g=class()local h=class()local i=class()local j=
class()local k=class()local l=class()local m=class()local n=class()local 
function sync(o,p,q)o._el:on(function()o.Value=p(o._el)o:RunChanged()if q then o
._lib:_rulesChanged()end end)end function g.SetValue(o,p)if not o._el:set(p==
true)then o:RunChanged()end for q,r in o._pickers do r._el.toggled=o.Value r.
Toggled=o.Value end end function h.SetValue(o,p)o._el:set(p)end function h.
SetMax(o,p)o.Max=p o._el.spec.max=p o._el:set(o._el.value)local q=o._el._view if
q then q.refresh()end end function h.SetMin(o,p)o.Min=p o._el.spec.min=p o._el:
set(o._el.value)local q=o._el._view if q then q.refresh()end end function i.
SetValue(o,p)if not o._el:set(p)then o:RunChanged()end end function j.SetValue(o
,p)if type(p)=='string'and o.SpecialType=='Player'then local q=b.service(
'Players'):FindFirstChild(p)p=q end if not o._el:set(p)then o:RunChanged()end
end function j.SetValues(o,p)o._el:setOptions(p)o.Values=o._el.spec.options end
function j.AddValues(o,p)local q=table.clone(o._el.spec.options)if type(p)==
'table'then for r,s in p do table.insert(q,s)end else table.insert(q,p)end o:
SetValues(q)end function j.GetActiveValues(o)if o.Multi then local p={}for q,r
in o.Value do if r then table.insert(p,q)end end return p end return if o.Value
then 1 else 0 end function k.SetValueRGB(o,p,q)local r=if o._hasAlpha then q or
0 else 0 if not o._el:set({color=p,alpha=r})then o:RunChanged(o.Value)end end
function k.SetValue(o,p,q)if typeof(p)=='Color3'then o:SetValueRGB(p,q)elseif
type(p)=='table'then o:SetValueRGB(Color3.fromHSV(p[1],p[2],p[3]),q)end end
function l.SetValue(o,p)if type(p)=='string'then p={p}end o._el:set({key=p[1],
mode=p[2],modifiers=p[3]or{}})end function l.GetState(o)return o._lib.window.
keys:state(o._el)end function l.OnClick(o,p)o.Clicked=p end function m.SetText(o
,p)o.Text=p o._el:setLabel(p)end function n.SetText(o,p)o.Text=p o._el:setLabel(
p)end local o={}o.__index=o local function register(p,q,r,s)p[q][r]=s s._idx=r
if p._dialogIndexes then table.insert(p._dialogIndexes,{shelf=q,idx=r})end
return s end local function common(p,q,r,s)return{Type=q,Text=s.Text,Disabled=s.
Disabled==true,Visible=s.Visible~=false,Tooltip=s.Tooltip,Callback=s.Callback,
Changed=s.Changed,_el=r,_lib=p}end local function tips(p,q)q.tip=p.Tooltip q.
disabled=p.Disabled==true q.disabledTip=p.DisabledTooltip q.visible=p.Visible~=
false return q end function o.AddToggle(p,q,r)local s=p._section local t=tips(r,
{label=r.Text or q,default=r.Default==true})local u=#s.rows==0 and s._root==nil
and s.title~=''local v if u and(r.Text=='Enabled'or r.Text==s.title)then t.label
=s.title v=s:master(q,t)else v=s:toggle(q,t)end local w=(setmetatable(common(p.
_lib,'Toggle',v,r),g))w.Value=v.value w._pickers={}w._box=p sync(w,function(x)
for y,z in w._pickers do z._el.toggled=x.value z.Toggled=x.value end return x.
value end,true)return register(p._lib,'Toggles',q,w)end o.AddCheckbox=o.
AddToggle function o.AddSlider(p,q,r)local s=tonumber(r.Rounding)or 0 local t=r.
FormatDisplayValue local u local v=tips(r,{label=r.Text or q,min=r.Min,max=r.Max
,step=10^-s,decimals=s,suffix=r.Suffix,default=r.Default,format=if t then
function(v,w)return t(u,w)end else nil})local w=p._section:slider(q,v)u=
setmetatable(common(p._lib,'Slider',w,r),h)u.Value=w.value u.Min,u.Max,u.
Rounding=r.Min,r.Max,s sync(u,function(x)return x.value end)return register(p.
_lib,'Options',q,u)end function o.AddInput(p,q,r)local s=p._section:input(q,
tips(r,{label=r.Text or'',default=r.Default or'',placeholder=r.Placeholder,
numeric=r.Numeric==true,finished=r.Finished==true or r.VerifyValue~=nil,
maxLength=r.MaxLength,verify=r.VerifyValue}))local t=(setmetatable(common(p._lib
,'Input',s,r),i))t.Value=s.value t.Numeric=r.Numeric==true sync(t,function(u)
return u.value end)return register(p._lib,'Options',q,t)end local function 
playerList(p)local q=b.service('Players')local r={}for s,t in q:GetPlayers()do
if not(p and t==q.LocalPlayer)then table.insert(r,t)end end return r end
function o.AddDropdown(p,q,r)local s=r.SpecialType=='Player'local t=if s then
playerList(r.ExcludeLocalPlayer==true)else(r.Values or{})local u=r.Multi==true
local v=r.Default if type(v)=='number'then v=t[v]end if u and type(v)=='string'
then v={v}end local w=r.FormatDisplayValue local x=p._section:dropdown(q,tips(r,
{label=r.Text or q,options=t,multi=u,default=v,searchable=r.Searchable==true,
allowNull=r.AllowNull==true or s,display=function(x)local y=if s then x.Name
else x if w then local z,A=pcall(w,y)if z and A~=nil then return tostring(A)end
end return tostring(y)end}))local y=(setmetatable(common(p._lib,'Dropdown',x,r),
j))y.Value=x.value y.Values=x.spec.options y.Multi=u y.SpecialType=r.SpecialType
sync(y,function(z)return z.value end,true)if s then local z=b.service('Players')
local function refresh()y:SetValues(playerList(r.ExcludeLocalPlayer==true))end
table.insert(p._lib._connections,z.PlayerAdded:Connect(refresh))table.insert(p.
_lib._connections,z.PlayerRemoving:Connect(function()task.defer(refresh)end))end
return register(p._lib,'Options',q,y)end function o.AddButton(p,q,r)local s=if
type(q)=='table'then q else{Text=q,Func=r}local t=p._section:button(s.Text or'',
tips(s,{confirm=s.DoubleClick==true,danger=s.Risky==true}))local u=(
setmetatable(common(p._lib,'Button',t,s),n))u.Func=s.Func t:on(function()
protect(u.Func)end)return u end local function buildLabel(p,q,r)local s=if type(
q)=='table'then q else{Text=q,DoesWrap=r}local t=p._section:label(tostring(s.
Text or''),{wrap=s.DoesWrap==true or r==true})local u=(setmetatable(common(p.
_lib,'Label',t,s),m))u.TextLabel={}u._box=p return u end function o.AddLabel(p,q
,r)if type(r)=='table'then local s=buildLabel(p,r)register(p._lib,'Options',q,s)
return s end return buildLabel(p,q,r)end function o.AddStat(p,q,r)local s=p.
_section:stat(q,r)return{SetValue=function(t,u)s:set(u)end}end function o.
AddDivider(p,q)local r=if type(q)=='table'then q.Text else q p._section:divider(
r)end function o.AddBlank()end function o.AddDependencyBox(p)local q={}local r=p
._lib p._section._page._guarded=true local s=p._section._root or p._section
local t=p._section:when(function()for t,u in q do local v,w=u[1],u[2]if v._el==s
.masterElement and w==true then continue end if v.Disabled then return false end
local x=v.Value if v.Type=='Dropdown'and type(x)=='table'then if not x[w]then
return false end elseif x~=w then return false end end return true end)local u=(
setmetatable({_section=t,_lib=r},o))function u.SetupDependencies(v,w)q=w p.
_section._page:_invalidate()end return u end function o.SetCollapsed()end local 
function attachColor(p,q,r,s)local t=s.Transparency~=nil local u=q._box._section
local v=u:addColor(q._el,r,{label=s.Title or q.Text or r,default=s.Default or
Color3.new(1,1,1),alpha=t,alphaValue=if t then s.Transparency else 0})local w=(
setmetatable(common(p,'ColorPicker',v,s),k))w.Value=v.value.color w.Transparency
=v.value.alpha w._hasAlpha=t v:on(function()w.Value=v.value.color w.Transparency
=v.value.alpha w:RunChanged(w.Value)end)return register(p,'Options',r,w)end
local function keyArgument(p)local q=({MB1='MouseButton1',MB2='MouseButton2',MB3
='MouseButton3'})[p]if q then return(Enum.UserInputType)[q]end local r,s=pcall(
function()return(Enum.KeyCode)[p]end)return if r then s else nil end local 
function attachKey(p,q,r,s)local t=q._box._section local u=s.SyncToggleState==
true local v=if u then{'Toggle','Hold'}else s.Modes or{'Always','Toggle','Hold'}
local w=s.Mode or'Toggle'local x local y=t:addKey(q._el,r,{label=q._el.label or
s.Text or r,default=s.Default or'None',mode=w,modes=v,modifiers=s.
DefaultModifiers or{},chipless=s.NoUI==true,noMouse=false,onPress=function(y,z)
if p.ToggleKeybind==x then p.window:toggle()return end if q.Type=='Toggle'and q.
Disabled then y.toggled=q.Value return end x.Toggled=z local A=y.value.mode if u
and q.Type=='Toggle'then if A=='Toggle'then q:SetValue(z)elseif A=='Hold'then q:
SetValue(true)end end if A=='Toggle'or A=='Press'then protect(x.Clicked,z)
protect(x.Callback,z)end end,onRelease=function(y)if u and q.Type=='Toggle'and y
.value.mode=='Hold'and not q.Disabled then q:SetValue(false)end end})x=
setmetatable(common(p,'KeyPicker',y,s),l)x.Value=y.value.key x.Mode=y.value.mode
x.Modifiers=y.value.modifiers x.Modes=v x.SyncToggleState=u x.NoUI=s.NoUI==true
x.Toggled=false x.ChangedCallback=s.ChangedCallback y:on(function()local z=y.
value x.Value=z.key x.Mode=z.mode x.Modifiers=z.modifiers x:Update()local A=
keyArgument(z.key)protect(x.ChangedCallback,A,z.modifiers)protect(x.Changed,A,z.
modifiers)end)if q.Type=='Toggle'and u then table.insert(q._pickers,x)y.toggled=
q.Value end return register(p,'Options',r,x)end function g.AddColorPicker(p,q,r)
attachColor(p._lib,p,q,r)return p end function g.AddKeyPicker(p,q,r)attachKey(p.
_lib,p,q,r)return p end m.AddColorPicker=g.AddColorPicker m.AddKeyPicker=g.
AddKeyPicker local p={}p.__index=p local function makeBox(q,r)return
setmetatable({_section=r,_lib=q},o)end local function sectionBox(q,r)local s=q.
_page:section(r)local t=makeBox(q._lib,s)return t end function p.AddLeftGroupbox
(q,r)return sectionBox(q,r)end p.AddRightGroupbox=p.AddLeftGroupbox function p.
AddGroupbox(q,r)return sectionBox(q,r.Name)end local function tabbox(q)local r=q
._page:tabset()local s=q._lib return{AddTab=function(t,u)return makeBox(s,r:tab(
u))end}end p.AddLeftTabbox=tabbox p.AddRightTabbox=tabbox local q={}q.__index=q
function q.AddTab(r,s,t)local u=if type(s)=='table'then s.Name else s local v=r.
_lib.window:page(u)if u=='Home'then local w=b.service('Players').LocalPlayer if
w then r._lib.Hero=v:hero({userId=w.UserId,title=w.DisplayName,text=r._footer})
end end local w=setmetatable({_page=v,_lib=r._lib},p)r._lib.Tabs[u]=w return w
end function q.OpenDialog(r,s,t)local u=r._lib local v=u.window local w=u.
_dialogIndexes return v:dialog({title=s.title,text=s.description,done=s.done,
maxHeight=s.maxHeight,onClose=function()local x=u._dialogOwned for y,z in x or{}
do u[z.shelf][z.idx]=nil end u._dialogOwned=nil if s.onClose then s.onClose()end
end},function(x)u._dialogIndexes={}t(makeBox(u,x))u._dialogOwned=u.
_dialogIndexes u._dialogIndexes=w end)end function e.new(r)local s=false local t
=setmetatable({Toggles={},Options={},Tabs={},Toggled=false,ScreenGui=nil,Scheme=
{AccentColor=Color3.fromHex('7EE0C4'),BackgroundColor=Color3.fromHex('07100D'),
MainColor=Color3.fromHex('141C18'),OutlineColor=Color3.fromHex('1A2D27'),
FontColor=Color3.fromHex('EBE8DA')},ShowToggleFrameInKeybinds=true,IsSottUI=true
,_connections={},_unloads={}},{})function t._rulesChanged(u)if s or u.window==
nil then return end s=true task.defer(function()s=false if u.window==nil or u.
window.destroyed then return end for v,w in u.window.pages do if w._guarded then
w:_invalidate()end end end)end function t.CreateWindow(u,v)local w=r.window({
title=v.Title,subtitle=v.Footer,folder=v.Folder,stateFile=v.StateFile,autoShow=v
.AutoShow~=false})u.window=w u.ScreenGui=w._gui u.Toggled=v.AutoShow~=false w.
visibilityChanged:connect(function(x)u.Toggled=x end)local x=setmetatable({_lib=
u,_footer=v.Footer},q)u.Window=x return x end function t.Notify(u,v,w)if u.
window==nil then return end if type(v)=='table'then u.window:notify({title=v.
Title,text=v.Description,seconds=v.Time or w})else u.window:notify({text=
tostring(v),seconds=w})end end function t.Toggle(u,v)if u.window then if v==nil
then u.window:toggle()else u.window:setOpen(v)end end end function t.
SafeCallback(u,v,...)protect(v,...)end function t.OnUnload(u,v)table.insert(u.
_unloads,v)end function t.Unload(u)for v,w in u._unloads do protect(w)end for v,
w in u._connections do w:Disconnect()end u._connections={}if u.window then u.
window:destroy()u.window=nil end u.ScreenGui=nil u.Toggled=false end
getmetatable(t).__newindex=function(u,v,w)rawset(u,v,w)if v=='ToggleKeybind'and
u.window and u.window.menuKey then u.window.keys:unregister(u.window.menuKey)end
end return{Library=t,SaveManager=c.new(t),ThemeManager=d.new(t)}end return e end
function a.e()local b=a.cache.e if not b then b={c=__modImpl()}a.cache.e=b end
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
return make end function a.f()local b=a.cache.f if not b then b={c=__modImpl()}a
.cache.f=b end return b.c end end do local function __modImpl()local b=a.f()
local c={}local d=256 local e=148 local f=14 local g=10 local h=12 local i=(
function()local i={}for j=0,6 do table.insert(i,ColorSequenceKeypoint.new(j/6,
Color3.fromHSV((j/6)%1,1,1)))end return ColorSequence.new(i)end)()local function 
hex(j)return string.format('%02X%02X%02X',math.round(j.R*255),math.round(j.G*255
),math.round(j.B*255))end local function parseHex(j)local k=string.gsub(j,'#',''
)if not string.match(k,'^%x%x%x%x%x%x$')then return nil end return Color3.
fromRGB((tonumber(string.sub(k,1,2),16)),(tonumber(string.sub(k,3,4),16)),(
tonumber(string.sub(k,5,6),16)))end c.hex=hex c.parseHex=parseHex local function 
open(j,k,l)local m=j.theme local n=k.spec.alpha==true local o=h+e+g+f+(if n then
g+f else 0)+g+28+h j.popover:open(l,d,o,function(p,q)local r=k.value local s,t,u
=r.color:ToHSV()local v=r.alpha local w=b('TextButton',{Position=UDim2.
fromOffset(h,h),Size=UDim2.new(1,-2*h,0,e),BackgroundTransparency=0,Parent=p})b(
'UIGradient',{Transparency=NumberSequence.new(0,1),Color=ColorSequence.new(
Color3.new(1,1,1)),Parent=b('Frame',{Size=UDim2.fromScale(1,1),
BackgroundTransparency=0,BackgroundColor3=Color3.new(1,1,1),Parent=w,ZIndex=1})}
)local x=b('Frame',{Size=UDim2.fromScale(1,1),BackgroundTransparency=0,
BackgroundColor3=Color3.new(0,0,0),ZIndex=2,Parent=w})b('UIGradient',{Rotation=
90,Transparency=NumberSequence.new(1,0),Parent=x})local y=b('Frame',{AnchorPoint
=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(10,10),BackgroundTransparency=1,
ZIndex=3,Parent=w})b('UICorner',{CornerRadius=UDim.new(1,0),Parent=y})b(
'UIStroke',{Color=Color3.new(1,1,1),Thickness=1.5,Parent=y})local z=h+e+g local
A=b('TextButton',{Position=UDim2.fromOffset(h,z),Size=UDim2.new(1,-2*h,0,f),
BackgroundTransparency=0,BackgroundColor3=Color3.new(1,1,1),Parent=p})b(
'UIGradient',{Color=i,Parent=A})local B=b('Frame',{AnchorPoint=Vector2.new(0.5,0
),Size=UDim2.new(0,3,1,0),BackgroundTransparency=0,BackgroundColor3=Color3.new(1
,1,1),ZIndex=2,Parent=A})z+=f local C,D=nil,nil if n then z+=g C=b('TextButton',
{Position=UDim2.fromOffset(h,z),Size=UDim2.new(1,-2*h,0,f),
BackgroundTransparency=0,Parent=p})D=b('Frame',{AnchorPoint=Vector2.new(0.5,0),
Size=UDim2.new(0,3,1,0),BackgroundTransparency=0,BackgroundColor3=Color3.new(1,1
,1),ZIndex=2,Parent=C})b('UIGradient',{Transparency=NumberSequence.new(0,1),
Parent=C})z+=f end z+=g local E=b('Frame',{Position=UDim2.fromOffset(h,z),Size=
UDim2.fromOffset(44,28),BackgroundTransparency=0,Parent=p})local F=b('TextBox',{
Position=UDim2.fromOffset(h+54,z),Size=UDim2.new(1,-(2*h+54),0,28),TextSize=14,
Parent=p})m:type(F,'text',true)m:paint(F,'TextColor3','text')local function draw
()local G=Color3.fromHSV(s,t,u)w.BackgroundColor3=Color3.fromHSV(s,1,1)y.
Position=UDim2.fromScale(t,1-u)B.Position=UDim2.fromScale(s,0)E.BackgroundColor3
=G if not F:IsFocused()then F.Text='#'..hex(G)end if C then C.BackgroundColor3=G
D.Position=UDim2.fromScale(v,0)end end local function commit()draw()k:set({color
=Color3.fromHSV(s,t,u),alpha=v})end local function bind(G,H)local function 
update(I)local J,K=G.AbsolutePosition,G.AbsoluteSize H(math.clamp((I.X-J.X)/math
.max(K.X,1),0,1),math.clamp((I.Y-J.Y)/math.max(K.Y,1),0,1))commit()end G.
InputBegan:Connect(function(I)local J=I.UserInputType if J==Enum.UserInputType.
MouseButton1 then update(j.input:pointer())j.input:capture(update)elseif J==Enum
.UserInputType.Touch then j.setScrollLocked(true)update(j.input:at(I))j.input:
capture(update,function()j.setScrollLocked(false)end,I)end end)end bind(w,
function(G,H)t,u=G,1-H end)bind(A,function(G)s=math.clamp(G,0,0.999)end)if C
then bind(C,function(G)v=G end)end F.FocusLost:Connect(function()local G=
parseHex(F.Text)if G then s,t,u=G:ToHSV()commit()else draw()end end)q.onRefresh(
function()local G=k.value if G.color~=Color3.fromHSV(s,t,u)then s,t,u=G.color:
ToHSV()end v=G.alpha draw()end)draw()end)end c.DOT_SPACE=30 local j=10 local k=
18 local l=0.72 function c.swatch(m,n)local o=b('TextButton',{Name='Swatch',Size
=UDim2.new(0,c.DOT_SPACE,1,0),ZIndex=4})local p=b('Frame',{AnchorPoint=Vector2.
new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(k,j),
BackgroundTransparency=0,ZIndex=4,Parent=o})b('UICorner',{CornerRadius=UDim.new(
0,3),Parent=p})local q={root=o,width=c.DOT_SPACE}local r=false q.refresh=
function()p.BackgroundColor3=n.value.color local s=n.value.alpha*0.8 p.
BackgroundTransparency=if r then math.max(s,l)else s end local s=false local 
function reach()o.Visible=not r or s or m.touch end q.setMuted=function(t)r=t q.
refresh()reach()end q.setHover=function(t)s=t reach()end q.refresh()q.open=
function()if not n.disabled then open(m,n,o)end end o.Activated:Connect(q.open)q
.setInk=function()end q.destroy=function()o:Destroy()end return q end return c
end function a.g()local b=a.cache.g if not b then b={c=__modImpl()}a.cache.g=b
end return b.c end end do local function __modImpl()local b={}local function 
isStart(c,d)if d==1 then return true end local e=string.sub(c,d-1,d-1)return e==
' 'or e=='/'or e=='-'or e=='_'end function b.score(c,d)if c==''then return 0 end
local e=string.lower(d)local f=string.lower(c)local g=string.find(e,f,1,true)if
g then return 1000-#e+(if isStart(e,g)then 500 else 0)end local h,i,j=0,1,-1 for
k=1,#f do local l=string.sub(f,k,k)if l~=' 'then local m=string.find(e,l,i,true)
if m==nil then return nil end h+=if isStart(e,m)then 12 elseif m==j+1 then 8
else 1 h-=math.min(m-i,6)j=m i=m+1 end end return h end function b.setting(c,d)
local e=b.score(c,d.label)if e then return e+100 end local f=string.lower(c)
local g=d.section and d.section.title or''local h=string.lower((d._pageName or''
)..' '..g)return if string.find(h,f,1,true)then 1 else nil end function b.
settings(c,d,e)local f={}for g,h in d do local i=b.setting(c,h)if i then table.
insert(f,{item=h,score=i,index=g})end end table.sort(f,function(g,h)if g.score~=
h.score then return g.score>h.score end return g.index<h.index end)local g,h={},
{}for i,j in f do local k=j.item.host or j.item if not h[k]then h[k]=true table.
insert(g,k)if#g==e then break end end end return g end function b.rank(c,d,e,f)
local g={}for h,i in d do local j=b.score(c,e(i))if j then table.insert(g,{item=
i,score=j})end end table.sort(g,function(h,i)return h.score>i.score end)local h=
{}for i=1,math.min(f,#g)do h[i]=g[i].item end return h end return b end function
a.h()local b=a.cache.h if not b then b={c=__modImpl()}a.cache.h=b end return b.c
end end do local function __modImpl()local b=a.f()local c=a.h()local d={}local e
=34 local f=8 local g=9 local h=40 local i=34 local j=220 local k=14 local 
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
Text=q(J)local K=isPicked(m,J)p:paint(H.text,'TextColor3',if K then'accent'else
'text')H.mark.Visible=K p:paint(H.root,'BackgroundColor3','lineStrong')H.root.
BackgroundTransparency=if I==v then 0 else 1 end end end local function refit()A
.CanvasSize=UDim2.fromOffset(0,#u*e+8)E.Visible=#u==0 z.resize(bodyHeight()+t)
draw()end local function refilter()local F=o.options if w~=''then F=c.rank(w,F,q
,500)end u=ordered(F)refit()end local F=nil local function choose(G)if o.multi
then local H=table.clone(m.value)H[G]=if H[G]then nil else true m:set(H)if F and
F.Text~=''then F.Text=''else refilter()end if F and not l.touch then F:
CaptureFocus()end return end if m.value==G then if o.allowNull then m:set(nil)
end else m:set(G)end z.close()end for G=1,D do local H=b('TextButton',{Size=
UDim2.new(1,-8,0,e-2),BackgroundTransparency=1,Visible=false,Parent=B})b(
'UICorner',{CornerRadius=UDim.new(0,7),Parent=H})local I=b('TextLabel',{Position
=UDim2.fromOffset(10,0),Size=UDim2.new(1,-36,1,0),TextSize=k,TextTruncate=Enum.
TextTruncate.AtEnd,Parent=H})p:type(I,'text',true)local J=b('Frame',{AnchorPoint
=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),Size=UDim2.fromOffset(7,7),
BackgroundTransparency=0,Visible=false,Parent=H})b('UICorner',{CornerRadius=UDim
.new(1,0),Parent=J})p:paint(J,'BackgroundColor3','accent')local K={root=H,text=I
,mark=J,index=0,option=nil}C[G]=K H.MouseEnter:Connect(function()v=K.index draw(
)end)H.MouseLeave:Connect(function()if v==K.index then v=0 draw()end end)H.
Activated:Connect(function()if K.option~=nil then choose(K.option)end end)end A:
GetPropertyChangedSignal('CanvasPosition'):Connect(draw)local G=0 if r then F=b(
'TextBox',{Position=UDim2.fromOffset(14,0),Size=UDim2.new(1,-28,0,h),TextSize=k+
1,Text='',PlaceholderText='Search',Parent=y})p:type(F,'text',true)p:paint(F,
'TextColor3','text')p:paint(F,'PlaceholderColor3','faint')local H=b('Frame',{
Position=UDim2.fromOffset(0,h-1),Size=UDim2.new(1,0,0,1),BackgroundTransparency=
0,Parent=y})p:paint(H,'BackgroundColor3','lineStrong')F:
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
F and not l.touch then F:CaptureFocus()end end)end return d end function a.i()
local b=a.cache.i if not b then b={c=__modImpl()}a.cache.i=b end return b.c end
end do local function __modImpl()local b={}local c={display={0.236,0.309,0.471,
0.656,0.6,0.96,0.713,0.26,0.337,0.337,0.556,0.6,0.299,0.402,0.299,0.437,0.6,0.6,
0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.319,0.319,0.6,0.6,0.6,0.493,0.899,0.672,0.663,
0.642,0.689,0.6,0.577,0.712,0.719,0.423,0.545,0.678,0.521,0.817,0.719,0.712,
0.641,0.712,0.664,0.611,0.58,0.689,0.638,0.949,0.655,0.632,0.599,0.329,0.437,
0.329,0.6,0.559,0.6,0.559,0.6,0.513,0.6,0.558,0.35,0.545,0.588,0.275,0.275,0.562
,0.294,0.888,0.588,0.563,0.6,0.6,0.393,0.499,0.374,0.588,0.524,0.819,0.544,0.524
,0.502,0.363,0.376,0.363,0.6},text={0.236,0.284,0.419,0.713,0.598,0.927,0.694,
0.242,0.335,0.335,0.45,0.6,0.272,0.399,0.272,0.383,0.6,0.6,0.6,0.6,0.6,0.6,0.6,
0.6,0.6,0.6,0.292,0.292,0.6,0.6,0.6,0.477,0.891,0.641,0.653,0.621,0.671,0.583,
0.559,0.695,0.707,0.4,0.51,0.634,0.501,0.812,0.707,0.708,0.606,0.708,0.64,0.581,
0.572,0.678,0.609,0.891,0.613,0.593,0.58,0.317,0.383,0.317,0.6,0.565,0.6,0.534,
0.58,0.503,0.58,0.549,0.324,0.528,0.568,0.25,0.25,0.527,0.272,0.873,0.568,0.56,
0.58,0.58,0.367,0.487,0.351,0.568,0.492,0.768,0.507,0.499,0.464,0.343,0.314,
0.343,0.6},textMedium={0.236,0.299,0.451,0.678,0.599,0.947,0.706,0.253,0.336,
0.336,0.514,0.6,0.288,0.401,0.288,0.416,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,
0.308,0.308,0.6,0.6,0.6,0.487,0.896,0.66,0.659,0.634,0.682,0.593,0.57,0.705,
0.714,0.414,0.531,0.66,0.513,0.815,0.714,0.711,0.627,0.711,0.655,0.599,0.577,
0.685,0.627,0.926,0.639,0.617,0.592,0.324,0.416,0.324,0.6,0.561,0.6,0.549,0.592,
0.509,0.592,0.555,0.34,0.538,0.58,0.265,0.265,0.548,0.285,0.882,0.58,0.562,0.592
,0.592,0.383,0.494,0.365,0.58,0.512,0.799,0.53,0.514,0.487,0.355,0.352,0.355,0.6
}}function b.width(d,e,f)local g=c[d]local h=0 for i=1,#e do local j=(string.
byte(e,i))h+=g[j-31]or 0.5 end return h*f end return b end function a.j()local b
=a.cache.j if not b then b={c=__modImpl()}a.cache.j=b end return b.c end end do
local function __modImpl()local b=a.f()local c=a.j()local d={}local e=24 local f
=8 local g=13 local h='Press a key'local function display(i)local j=i.value if j
==nil or j.key=='None'or j.key=='Unknown'then return'Unset'end local k={}for l,m
in j.modifiers or{}do table.insert(k,m)end table.insert(k,j.key)local l=table.
concat(k,'+')return if j.mode and j.mode~='Toggle'then l..' '..string.lower(j.
mode)else l end function d.build(i,j)local k=i.theme local l=b('TextButton',{
Name='Key',Size=UDim2.fromOffset(52,36),BackgroundTransparency=1})local m=b(
'Frame',{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size
=UDim2.new(1,-f,0,e),ZIndex=4,Parent=l})b('UICorner',{CornerRadius=UDim.new(0,6)
,Parent=m})local n=b('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
Parent=m})local o=b('TextLabel',{Size=UDim2.fromScale(1,1),TextSize=g,
TextXAlignment=Enum.TextXAlignment.Center,ZIndex=5,Parent=m})k:type(o,'text',
true)local p={root=l,width=52}local q=false local r=false local function fit(s)
local t=math.ceil(c.width('textMedium',s,g))+16+f l.Size=UDim2.fromOffset(math.
max(t,44),36)p.width=l.Size.X.Offset if p.onFit then p.onFit()end end local s=
false local function ink()k:paint(o,'TextColor3',if q then'accent'elseif r then
'onAccent'else'muted')k:paint(n,'Color',if q then'accent'elseif r then'onAccent'
else'lineStrong')m.Visible=q or s or display(j)~='Unset'end p.setHover=function(
t)s=t ink()end p.refresh=function()if q then return end local t=display(j)o.Text
=t fit(t)ink()end p.setInk=function(t)r=t ink()end p.refresh()p.start=function()
if j.disabled or q then return end q=true o.Text=h fit(h)ink()i.keys:listen(
function(t,u)q=false if t~=nil then j:set({key=t,modifiers=u or{}})end p.
refresh()end,j.spec.noMouse==true)end l.Activated:Connect(p.start)l.
MouseButton2Click:Connect(function()local t=j.spec.modes if j.disabled or t==nil
or#t<2 then return end local u=table.find(t,j.value.mode)or 0 local v=t[u%#t+1]j
:set({mode=v})i.notify({title=j.label,text='Key mode: '..v,seconds=2})end)p.
destroy=function()if q then i.keys:cancel()end l:Destroy()end return p end
return d end function a.k()local b=a.cache.k if not b then b={c=__modImpl()}a.
cache.k=b end return b.c end end do local function __modImpl()local b=a.f()local
c=a.b()local d={}d.PAD=12 d.HEIGHT=36 d.NAME=14 d.RADIUS=8 local e=22 local f=40
local g=0.7 local h=26 local i=0.97 local j=0.45 local k=0.28 local l={}l.
__index=l function l.own(m,n)table.insert(m._cleanups,function()n:destroy()end)
return n end function l.onCleanup(m,n)table.insert(m._cleanups,n)end local 
function baseColor(m)local n=m.ctx.theme.tokens if m._lit then return if m.
_hover then n.accentHover else n.accent end if m._flat then return if m._hover
then n.raised else n.surface end return if m._hover then n.lineStrong else n.
raised end local function washTo(m)if m._wash==nil then m._wash=m:own(c.prop(m.
root,'BackgroundColor3',e))end m._wash:to(baseColor(m))end local function 
snapBase(m)local n=baseColor(m)if m._wash then m._wash:snap(n)else m.root.
BackgroundColor3=n end end function l.onHover(m,n)local o=n and not m.el.
disabled if m._hover==o then return end m._hover=o for p,q in m.chips do if q.
setHover then q.setHover(o)end end washTo(m)end function l.pressed(m,n)if m.
_press==nil then local o=b('UIScale',{Parent=m.root})m._press=m:own(c.prop(o,
'Scale',f,g))end m._press:to(if n then i else 1)end function l.flood(m,n,o)if m.
_lit==n then return end m._lit=n if o or not m.root.Visible or not m.ctx.
isShowing(m.el)then snapBase(m)else washTo(m)end end function l.flash(m)m:flood(
true)task.delay(k,function()if m.root.Parent then m:flood(false)end end)end
function l.ink(m,n,o,p)local q=m.ctx.theme.tokens local r=m._inks[n]if p or not
m.ctx.isShowing(m.el)then if r then r:snap(q[o])else n.TextColor3=q[o]end return
end if r==nil then r=m:own(c.prop(n,'TextColor3',h))m._inks[n]=r end r:to(q[o])
end function l.retint(m)if not m._inert then snapBase(m)end end function l.
refreshName(m)local n=m.el if n.disabled then m.name.RichText=true m.name.Text=
'<s>'..n.label..'</s>'else m.name.RichText=false m.name.Text=n.label end end
function d.new(m,n,o)local p=o or{}local q=b('TextButton',{Name=n.kind,Size=
UDim2.new(1,0,0,p.height or d.HEIGHT),BackgroundTransparency=if p.inert then 1
else 0,ClipsDescendants=true,Active=not p.inert})if not p.inert then b(
'UICorner',{CornerRadius=UDim.new(0,d.RADIUS),Parent=q})end local r=b(
'TextLabel',{Name='Name',Position=UDim2.fromOffset(d.PAD,0),Size=UDim2.new(1,-2*
d.PAD,1,0),TextSize=d.NAME,TextTruncate=Enum.TextTruncate.AtEnd,Text=n.label,
ZIndex=3,Parent=q})m.theme:type(r,'text',true)local s=setmetatable({root=q,name=
r,el=n,ctx=m,chips={},_cleanups={},_inks={},_hover=false,_lit=false,_inert=p.
inert==true,_flat=p.flat==true},l)q.BackgroundColor3=baseColor(s)s:refreshName()
if p.inert then s.onHover=function()end s.pressed=function()end else q.
MouseEnter:Connect(function()m.hover:enter(s)end)local t=nil q.InputBegan:
Connect(function(u)local v=u.UserInputType if v==Enum.UserInputType.MouseButton1
then if not n.disabled then s:pressed(true)end elseif v==Enum.UserInputType.
Touch then if not n.disabled then s:pressed(true)end t=task.delay(j,function()t=
nil s._tipShown=true local w=if n.disabled and n.disabledTip then n.disabledTip
else n.tip if w and w~=''then m.tooltip:showAt(q,w)end end)end end)local u=m.
input.pointerUp:connect(function()if s._press and s._press.target~=1 then s:
pressed(false)end if t then task.cancel(t)t=nil end if s._tipShown then s.
_tipShown=false m.tooltip:hide()end end)s:onCleanup(function()u()if t then task.
cancel(t)end end)end s.destroy=function()m.hover:leave(s)for t,u in s._cleanups
do pcall(u)end q:Destroy()end return s end return d end function a.l()local b=a.
cache.l if not b then b={c=__modImpl()}a.cache.l=b end return b.c end end do
local function __modImpl()local b=a.g()local c=a.i()local d=a.k()local e=a.f()
local f=a.j()local g=a.b()local h=a.l()local i={}local j=h.PAD local k=h.RADIUS
local l=h.HEIGHT local m=h.NAME local n=36 local o=20 local p=14 local q=3 local
r=30 local s=0.72 local t=72 local u=52 local v=0.55 local w=20 local x=8 local
y=30 local z=80 local A=3 local B=0.82 local C=0.93 local D=0 local E=0.6 local
F=2 local G=28 local H=12 local I=30 local J=13 local K=3 local L=16 local M=22
local N=21 local O=28 local P=26 local Q=8 local R=16 local S={}local function 
listed(T)local U=T._shownOn local V=U and U.sections[1]return V~=nil and V.flat
==true end local function ownerOf(T)local U=T.section return U and(U._root or U)
.masterElement end local function shownLabel(T)local U=ownerOf(T)if listed(T)and
U and U~=T then return U.label..' '..T.label end return T.label end local 
function textWidth(T,U)return f.width('textMedium',(string.gsub(T,'<[^>]+>',''))
,U)end local function segmentsFit(T,U)local V=T.spec local W=#V.options if V.
multi or V.allowNull or T.value==nil or W<2 or W>K then return false end local X
=V.display or tostring local Y=textWidth(T.label,m)+L+2*j for Z,_ in V.options
do Y+=textWidth(X(_),J)+2*H end return Y<=U end function i.form(T)if T.kind~=
'dropdown'then return nil end if not segmentsFit(T,T._rowWidth or 0)then return
false end local U={}for V,W in T.spec.options do table.insert(U,tostring(W))end
return table.concat(U,'\0')end function i.measure(T,U)T._rowWidth=U local V=T.
kind if V=='divider'then return if T.label==''then Q else P elseif V=='label'and
not T.addons then if not T.spec.wrap then return O end if T._measured then
return T._measured end local W=string.gsub(T.label,'<[^>]+>','')local X=math.
max(math.floor(U/7),10)return math.ceil(#W/X)*N+8 end return l end local 
function formatted(T,U)local V=T.spec if V.format then local W,X=pcall(V.format,
T,U)if W and X~=nil then return tostring(X)end end return string.format('%.'..(V
.decimals or 0)..'f',U)..(V.suffix or'')end local function readoutWidth(T)local
U=T.spec local V=0 for W,X in{U.min,U.max,T.value}do V=math.max(V,f.width(
'textMedium',formatted(T,X),m))end return math.ceil(V)+4 end local function 
addons(T,U,V,W)local X=W local Y={}local function reflow()local Z=W for _,aa in
Y do aa.root.Position=UDim2.new(1,-(j+Z),0.5,0)Z+=aa.width+aa.gap end if T.
onReserve then T.onReserve(Z)end end local function place(aa,Z)Z.root.
AnchorPoint=Vector2.new(1,0.5)Z.root.Position=UDim2.new(1,-(j+X),0.5,0)Z.root.
ZIndex=4 Z.root.Parent=T.root Z.gap=x Z.onFit=reflow X+=Z.width+Z.gap table.
insert(Y,Z)aa._view=Z T.addonChips=T.addonChips or{}T.addonChips[aa]=Z table.
insert(T.chips,Z)T:onCleanup(function()aa._view=nil Z.destroy()end)end for aa,Z
in V.addons or{}do if Z.kind=='color'and not Z.spec.chipless then place(Z,b.
swatch(U,Z))end end for aa,Z in V.addons or{}do if Z.kind=='key'and not Z.spec.
chipless then place(Z,d.build(U,Z))end end return X end local function switch(aa
,T)local U=aa.theme local V=T.root local W=e('ImageLabel',{AnchorPoint=Vector2.
new(0.5,0.5),Position=UDim2.new(1,-(j+n/2),0.5,0),Size=UDim2.fromOffset(t,u),
BackgroundTransparency=1,BorderSizePixel=0,ImageTransparency=1,ZIndex=2,Parent=V
})U:paint(W,'ImageColor3','accent')aa.art(W,'glow.png')local X=e('Frame',{Name=
'Switch',AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-j,0.5,0),Size=
UDim2.fromOffset(n,o),BackgroundTransparency=0,ZIndex=3,Parent=V})e('UICorner',{
CornerRadius=UDim.new(1,0),Parent=X})U:paint(X,'BackgroundColor3','lineStrong')
local Y=e('Frame',{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,q,0.5,0),
Size=UDim2.fromOffset(p,p),BackgroundTransparency=0,ZIndex=4,Parent=X})e(
'UICorner',{CornerRadius=UDim.new(1,0),Parent=Y})U:paint(Y,'BackgroundColor3',
'muted')local Z,_=nil,nil return function(ab,ac)local ad=UDim2.new(0,if ab then
n-p-q else q,0.5,0)local ae=if ab then v else 1 local af=if ab then'accent'else
'lineStrong'local ag=if ab then'onAccent'else'muted'if ac then if Z then Z:snap(
ad)_:snap(ae)else Y.Position=ad W.ImageTransparency=ae end U:paint(X,
'BackgroundColor3',af)U:paint(Y,'BackgroundColor3',ag)return end if Z==nil then
Z=T:own(g.prop(Y,'Position',r,s))_=T:own(g.prop(W,'ImageTransparency',w))end Z:
to(ad)_:to(ae)aa.tint(X,'BackgroundColor3',af)aa.tint(Y,'BackgroundColor3',ag)
end end function S.toggle(aa,ab)local ac=ab.spec.primary==true and not listed(ab
)local ad=h.new(aa,ab,{flat=true})ad.isHead=ac if ac then ad.name.TextSize=R aa.
theme:type(ad.name,'display')ad.root.BackgroundTransparency=1 end local function 
reserve(ae)ad.name.Size=UDim2.new(1,-(2*j+ae),1,0)end ad.onReserve=reserve
reserve(addons(ad,aa,ab,n+x))local ae=switch(aa,ad)local function draw(af)local
ag=ab.value==true ae(ag,af)ad:ink(ad.name,if ab.disabled then'faint'elseif ag or
ac then'text'else'muted',af)for T,U in ad.chips do if U.setMuted then U.
setMuted(not ag)end end end ad.root.Activated:Connect(function()if not ab.
disabled then ab:set(not ab.value)end end)ad.refresh=function()ad:refreshName()
if listed(ab)then ad.name.Text=shownLabel(ab)end draw(false)end ad:refreshName()
if listed(ab)then ad.name.Text=shownLabel(ab)end draw(true)return ad end
function S.slider(aa,ab)local ac=h.new(aa,ab,{inert=true})local ad=aa.theme
local ae=ab.spec local af=ac.root af.Active=true af.BackgroundTransparency=0 e(
'UICorner',{CornerRadius=UDim.new(0,k),Parent=af})ad:paint(af,'BackgroundColor3'
,'raised')local function ratio()local ag=ae.max-ae.min return if ag<=0 then 0
else math.clamp((ab.value-ae.min)/ag,0,1)end local ag=readoutWidth(ab)ac.name.
Size=UDim2.new(1,-(2*j+ag+8),1,0)local T=e('TextLabel',{Name='Readout',
AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-j,0,0),Size=UDim2.new(0,ag,1,
0),TextSize=m,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=3,Parent=af})ad:
type(T,'text',true)local U=e('Frame',{Name='Fill',Size=UDim2.fromScale(ratio(),1
),BackgroundTransparency=B,ZIndex=1,Parent=af})e('UICorner',{CornerRadius=UDim.
new(0,k),Parent=U})ad:paint(U,'BackgroundColor3','accent')local V=e('Frame',{
Name='Edge',AnchorPoint=Vector2.new(1,0.5),Position=UDim2.fromScale(1,0.5),Size=
UDim2.new(0,F,1,-12),BackgroundTransparency=D,ZIndex=2,Parent=U})e('UICorner',{
CornerRadius=UDim.new(1,0),Parent=V})ad:paint(V,'BackgroundColor3','accent')
local W=ac:own(g.prop(U,'Size',y))local X=ac:own(g.prop(U,
'BackgroundTransparency',y))local Y=ac:own(g.prop(V,'BackgroundTransparency',y))
ac.onHover=function(Z,_)aa.tint(af,'BackgroundColor3',if _ and not ab.disabled
then'lineStrong'else'raised')end af.MouseEnter:Connect(function()aa.hover:enter(
ac)end)local function typedEntry()if ab.disabled or ac._typing then return end
ac._typing=true T.Visible=false local Z=e('TextBox',{AnchorPoint=Vector2.new(1,0
),Position=UDim2.new(1,-j,0,0),Size=UDim2.new(0,math.max(ag,64),1,0),TextSize=m,
TextXAlignment=Enum.TextXAlignment.Right,Text='',PlaceholderText=tostring(ab.
value),ZIndex=6,Parent=af})ad:type(Z,'text',true)ad:paint(Z,'TextColor3',
'accent')ad:paint(Z,'PlaceholderColor3','faint')Z:CaptureFocus()Z.FocusLost:
Connect(function()local _=tonumber(Z.Text)ac._typing=false T.Visible=true Z:
Destroy()if _ then ab:set(_)end end)end local function beginDrag(Z,_,ah)if ab.
disabled then return end local ai=ab.value local aj=math.max(af.AbsoluteSize.X,1
)local ak=ae.max-ae.min local al=false local am=false aa.input:capture(function(
an)local ao=an-Z if not al then if math.abs(ao.X)<A then if _ and math.abs(ao.Y)
>8 then am=true aa.input:release()end return end if _ and math.abs(ao.X)<=math.
abs(ao.Y)then am=true aa.input:release()return end al=true W.speed=z aa.
setScrollLocked(true)end ab:set(ai+ak*ao.X/aj)end,function(an)W.speed=y aa.
setScrollLocked(false)if not al and not am and(an-Z).Magnitude<8 then
typedEntry()end end,ah)end af.InputBegan:Connect(function(ah)local ai=ah.
UserInputType if ai==Enum.UserInputType.MouseButton2 then typedEntry()elseif ai
==Enum.UserInputType.MouseButton1 then beginDrag(aa.input:pointer(),false)elseif
ai==Enum.UserInputType.Touch then beginDrag(aa.input:at(ah),true,ah)end end)
local ah=ownerOf(ab)local function resting()return ah~=nil and ah.value~=true
end local function overText()local ai=ab._rowWidth or 0 local aj=ratio()*ai
local ak=j+textWidth(ac.name.Text,m)+6 local al=ai-j-ag-6 return(aj>j-6 and aj<
ak)or(aj>al and aj<ai-j+4)end local function light(ai)local aj=resting()local ak
=if aj then C else B local al=if overText()then 1 elseif aj then E else D if ai
then X:snap(ak)Y:snap(al)else X:to(ak)Y:to(al)end end local function paintText()
ad:paint(ac.name,'TextColor3',if ab.disabled then'faint'else'text')ad:paint(T,
'TextColor3',if ab.disabled then'faint'else'text')T.Text=formatted(ab,ab.value)
if listed(ab)then ac.name.Text=shownLabel(ab)end end ac.refresh=function()ac:
refreshName()paintText()W:to(UDim2.fromScale(ratio(),1))light()end if ah then ac
:onCleanup(ah:on(function()light()end))end light(true)paintText()return ac end
local function pickText(aa)local ab=aa.spec.display or tostring local ac=aa.
value if aa.spec.multi then local ad={}for ae,af in aa.spec.options do if ac[af]
then table.insert(ad,ab(af))end end for ae,af in ac do if af and not table.find(
aa.spec.options,ae)then table.insert(ad,ab(ae))end end if#ad==0 then return
'None',false end if#ad<=2 then return table.concat(ad,', '),true end return
string.format('%s, %s +%d',ad[1],ad[2],#ad-2),true end if ac==nil then return
'None',false end return ab(ac),true end local function refreshCaption(aa,ab)aa:
refreshName()if listed(ab)then aa.name.Text=shownLabel(ab)end end local function 
segments(aa,ab)local ac=h.new(aa,ab,{inert=true})local ad=aa.theme ac.root.
Active=true ac.root.MouseEnter:Connect(function()aa.hover:enter(ac)end)ad:paint(
ac.name,'TextColor3','muted')refreshCaption(ac,ab)local ae=ab.spec.display or
tostring local af=0 local ag={}for ah,ai in ab.spec.options do local aj=math.
ceil(textWidth(ae(ai),J))+2*H table.insert(ag,{option=ai,x=af,width=aj})af+=aj
end local ah=e('Frame',{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-4,
0.5,0),Size=UDim2.fromOffset(af,G),BackgroundTransparency=0,ZIndex=2,Parent=ac.
root})e('UICorner',{CornerRadius=UDim.new(0,k),Parent=ah})ad:paint(ah,
'BackgroundColor3','raised')local ai=e('Frame',{BackgroundTransparency=0,ZIndex=
2,Parent=ah})e('UICorner',{CornerRadius=UDim.new(0,k),Parent=ai})ad:paint(ai,
'BackgroundColor3','accentDim')ac.name.Size=UDim2.new(1,-(j+af+L),1,0)local aj=
ac:own(g.prop(ai,'Position',I))local ak=ac:own(g.prop(ai,'Size',I))for al,am in
ag do local an=e('TextButton',{Position=UDim2.fromOffset(am.x,0),Size=UDim2.new(
0,am.width,1,0),TextSize=J,Text=ae(am.option),ZIndex=3,TextXAlignment=Enum.
TextXAlignment.Center,Parent=ah})ad:type(an,'text',true)am.button=an an.
Activated:Connect(function()if not ab.disabled then ab:set(am.option)end end)end
local function draw(al)for am,an in ag do local ao=ab.value==an.option ac:ink(an
.button,if ab.disabled then'faint'elseif ao then'accent'else'muted',al)if ao
then local T=UDim2.fromOffset(an.x,0)local U=UDim2.new(0,an.width,1,0)if al then
aj:snap(T)ak:snap(U)else aj:to(T)ak:to(U)end end end end ac.refresh=function()
refreshCaption(ac,ab)draw(false)end draw(true)return ac end function S.dropdown(
aa,ab)if i.form(ab)then return segments(aa,ab)end local ac=h.new(aa,ab,{flat=
true})local ad=aa.theme local ae=ac.root ae.ClipsDescendants=true ad:paint(ac.
name,'TextColor3','muted')if listed(ab)then ac.name.Text=shownLabel(ab)end ac.
name.Size=UDim2.new(0.45,-j,1,0)local af=e('TextLabel',{Name='Value',AnchorPoint
=Vector2.new(1,0),Position=UDim2.new(1,-(j+M),0,0),Size=UDim2.new(0.55,-(j+M),1,
0),TextSize=m,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.
TextXAlignment.Right,ZIndex=3,Parent=ae})ad:type(af,'text',true)local ag=aa.
glyph.chevron(ae,'muted')ag.AnchorPoint=Vector2.new(1,0.5)ag.Position=UDim2.new(
1,-j,0.5,0)ag.ZIndex=3 ae.Activated:Connect(function()if not ab.disabled then c.
open(aa,ab,ae)end end)ac.refresh=function()refreshCaption(ac,ab)local ah,ai=
pickText(ab)af.Text=ah ad:paint(af,'TextColor3',if ab.disabled or not ai then
'faint'else'text')end ac.refresh()return ac end function S.input(aa,ab)local ac=
h.new(aa,ab,{inert=true})local ad=aa.theme local ae=ab.spec ac.root.Active=true
ac.root.MouseEnter:Connect(function()aa.hover:enter(ac)end)ac.name.Size=UDim2.
new(0.38,-j,1,0)ad:paint(ac.name,'TextColor3','muted')local af=e('Frame',{
AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-4,0.5,0),Size=UDim2.new(
0.62,-4,0,G),BackgroundTransparency=0,ZIndex=2,Parent=ac.root})e('UICorner',{
CornerRadius=UDim.new(0,k),Parent=af})ad:paint(af,'BackgroundColor3','raised')
local ag=e('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,
Transparency=1,Parent=af})ad:paint(ag,'Color','accent')local ah=e('TextBox',{
Position=UDim2.fromOffset(10,0),Size=UDim2.new(1,-20,1,0),TextSize=m,Text=ab.
value or'',PlaceholderText=ae.placeholder or'',ClipsDescendants=true,
TextEditable=not ab.disabled,ZIndex=3,Parent=af})ad:type(ah,'text',true)ad:
paint(ah,'TextColor3','text')ad:paint(ah,'PlaceholderColor3','faint')local ai=ac
:own(g.prop(ag,'Transparency',I))ah.Focused:Connect(function()ai:to(0.2)end)ah.
FocusLost:Connect(function(aj)ai:to(1)if not ae.finished then return end if not
aj or not ab:set(ah.Text)then ah.Text=ab.value or''end end)ah:
GetPropertyChangedSignal('Text'):Connect(function()if ac._applying or ae.
finished then return end if not ab:set(ah.Text)and ah.Text~=ab.value then ac.
_applying=true ah.Text=ab.value or''ac._applying=false end end)ac.refresh=
function()refreshCaption(ac,ab)ah.TextEditable=not ab.disabled if ah.Text~=(ab.
value or'')then ac._applying=true ah.Text=ab.value or''ac._applying=false end
end return ac end function S.button(aa,ab)local ac=h.new(aa,ab)ac.name.
TextXAlignment=Enum.TextXAlignment.Center local ad=nil local function draw()ac:
refreshName()ac:ink(ac.name,if ab.disabled then'faint'elseif ab.spec.danger then
'danger'else'text')end ac.refresh=draw draw()ac.root.Activated:Connect(function(
)if ab.disabled then return end if ab.spec.confirm and ad==nil then ac.name.Text
='Again to confirm'ac:flood(true)ac:ink(ac.name,'onAccent')ad=task.delay(2.5,
function()ad=nil ac:flood(false)draw()end)return end if ad then task.cancel(ad)
ad=nil ac:flood(false)draw()end ac:flash()ac:ink(ac.name,'onAccent')task.delay(
0.28,function()if ac.root.Parent then draw()end end)ab:fire()end)ac:onCleanup(
function()if ad then task.cancel(ad)end end)return ac end function S.stat(aa,ab)
local ac=h.new(aa,ab,{inert=true})local ad=aa.theme ac.name.Size=UDim2.new(0.6,-
j,1,0)ad:paint(ac.name,'TextColor3','muted')local ae=e('TextLabel',{AnchorPoint=
Vector2.new(1,0),Position=UDim2.new(1,-j,0,0),Size=UDim2.new(0.4,-j,1,0),
TextSize=m,TextXAlignment=Enum.TextXAlignment.Right,TextTruncate=Enum.
TextTruncate.AtEnd,ZIndex=3,Parent=ac.root})ad:type(ae,'text',true)ad:paint(ae,
'TextColor3','text')ac.refresh=function()ac.name.Text=ab.label ae.Text=tostring(
ab.value)end ac.refresh()return ac end function S.label(aa,ab)local ac=aa.theme
if ab.addons then local ad=h.new(aa,ab,{flat=true})ac:paint(ad.name,'TextColor3'
,'muted')ad.name.RichText=true local function reserve(ae)ad.name.Size=UDim2.new(
1,-(2*j+ae),1,0)end ad.onReserve=reserve reserve(addons(ad,aa,ab,0))ad.refresh=
function()ad.name.Text=ab.label end return ad end local ad=h.new(aa,ab,{inert=
true})local ae=ad.name local af=ab.spec.wrap==true ae.RichText=true ae.
TextWrapped=af ac:type(ae,'text')ac:paint(ae,'TextColor3','muted')ae.
TextTruncate=if af then Enum.TextTruncate.None else Enum.TextTruncate.AtEnd ae.
TextYAlignment=if af then Enum.TextYAlignment.Top else Enum.TextYAlignment.
Center ae.LineHeight=if af then 1.15 else 1 ae.Position=UDim2.fromOffset(j,if af
then 4 else 0)ae.Size=UDim2.new(1,-2*j,1,if af then-4 else 0)ae.Text=ab.label if
af then ae:GetPropertyChangedSignal('TextBounds'):Connect(function()local ag=
math.ceil(ae.TextBounds.Y/aa.uiScale())+8 if ab._measured~=ag then ab._measured=
ag if ab._relayout then ab._relayout()end end end)end ad.refresh=function()ae.
Text=ab.label end return ad end function S.divider(aa,ab)local ac=h.new(aa,ab,{
inert=true})local ad=aa.theme ad:paint(ac.name,'TextColor3','muted')ac.refresh=
function()ac.name.Text=ab.label end return ac end local function chipTile(aa,ab,
ac,ad)local ae=h.new(aa,ab,{flat=true})aa.theme:paint(ae.name,'TextColor3',
'muted')ac.root.AnchorPoint=Vector2.new(1,0.5)ac.root.Position=UDim2.new(1,-ad,
0.5,0)ac.root.ZIndex=4 ac.root.Parent=ae.root ae.name.Size=UDim2.new(1,-(2*j+ac.
width),1,0)table.insert(ae.chips,ac)ae:onCleanup(ac.destroy)ae.refresh=function(
)ae:refreshName()ac.refresh()end return ae end function S.key(aa,ab)local ac=d.
build(aa,ab)local ad=chipTile(aa,ab,ac,j-4)ad.root.Activated:Connect(ac.start)
return ad end function S.color(aa,ab)local ac=b.swatch(aa,ab)local ad=chipTile(
aa,ab,ac,j-8)ad.root.Activated:Connect(ac.open)return ad end function i.build(aa
,ab)local ac=S[ab.kind]assert(ac,'sottUI: no view for '..tostring(ab.kind))local
ad=ac(aa,ab)ad.form=i.form(ab)ab._view=ad return ad end return i end function a.
m()local aa=a.cache.m if not aa then aa={c=__modImpl()}a.cache.m=aa end return
aa.c end end do local function __modImpl()local aa={}aa.__index=aa local ab=
function(ab)warn(ab)end function aa.connect(ac,ad)local ae=table.clone(ac._list)
table.insert(ae,ad)ac._list=ae return function()local af=table.clone(ac._list)
local ag=table.find(af,ad)if ag then table.remove(af,ag)ac._list=af end end end
function aa.fire(ac,...)for ad,ae in ac._list do local af,ag=xpcall(ae,debug.
traceback,...)if not af then ab('sottUI: listener failed: '..tostring(ag))end
end end function aa.clear(ac)ac._list={}end return{new=function()return((
setmetatable({_list={}},aa)))end,setReporter=function(ac)ab=ac end}end function
a.n()local aa=a.cache.n if not aa then aa={c=__modImpl()}a.cache.n=aa end return
aa.c end end do local function __modImpl()local aa=a.n()local ab={}local ac={}ac
.__index=ac local function decimals(ad)local ae=string.format('%.10f',ad)local
af=string.match(ae,'%.(%d-)0*$')return if af then#af else 0 end local function 
roundTo(ad,ae)if ae<=0 then return ad end local af=math.round(ad/ae)*ae return
tonumber(string.format('%.'..decimals(ae)..'f',af))or af end ab.roundTo=roundTo
local function sameList(ad,ae)if#ad~=#ae then return false end for af=1,#ad do
if ad[af]~=ae[af]then return false end end return true end local function 
sameSet(ad,ae)for af,ag in ad do if ag and not ae[af]then return false end end
for af,ag in ae do if ag and not ad[af]then return false end end return true end
local ad={toggle=function(ad,ae)return ae==true end,slider=function(ad,ae)local
af=tonumber(ae)if af==nil or af~=af then return nil end local ag=ad.spec return
math.clamp(roundTo(af,ag.step or 1),ag.min,ag.max)end,dropdown=function(ad,ae)
local af=ad.spec if af.multi then local ag={}if type(ae)=='table'then for ah,ai
in ae do if type(ah)=='number'then ag[ai]=true elseif ai then ag[ah]=true end
end elseif ae~=nil and ae~=''then ag[ae]=true end if not af.keep then for ah in
ag do if not table.find(af.options,ah)then ag[ah]=nil end end end return ag end
if ae==nil or ae==''then return false end if not table.find(af.options,ae)and
not af.keep then return nil end return ae end,input=function(ad,ae)local af=if
ae==nil then''else tostring(ae)local ag=ad.spec if ag.maxLength and#af>ag.
maxLength then af=string.sub(af,1,ag.maxLength)end if ag.numeric and af~=''and
af~='-'and af~='.'and tonumber(af)==nil then return nil end if ag.verify and not
ag.verify(af)then return nil end return af end,key=function(ad,ae)if type(ae)==
'string'then return{key=ae,mode=ad.value and ad.value.mode or'Toggle',modifiers=
{}}end if type(ae)~='table'then return nil end local af=ad.value or{}return{key=
ae.key or ae[1]or af.key or'None',mode=ae.mode or ae[2]or af.mode or'Toggle',
modifiers=ae.modifiers or ae[3]or af.modifiers or{}}end,color=function(ad,ae)if
typeof(ae)=='Color3'then return{color=ae,alpha=ad.value and ad.value.alpha or 0}
end if type(ae)=='table'and typeof(ae.color)=='Color3'then return{color=ae.color
,alpha=math.clamp(tonumber(ae.alpha)or 0,0,1)}end return nil end,label=function(
ad,ae)return tostring(ae)end,stat=function(ad,ae)return tostring(ae)end}local 
function equal(ae,af,ag)local ah=ae.kind if ah=='dropdown'and ae.spec.multi then
return sameSet(af,ag)end if ah=='key'then return af.key==ag.key and af.mode==ag.
mode and sameList(af.modifiers,ag.modifiers)end if ah=='color'then return af.
color==ag.color and af.alpha==ag.alpha end return af==ag end local function 
unwrap(ae,af)if ae.kind=='dropdown'and not ae.spec.multi and af==false then
return nil end return af end function ab.new(ae,af,ag,ah,ai)local aj=
setmetatable({kind=ae,id=af,label=ag,spec=ah,tip=ah.tip,disabled=ah.disabled==
true,disabledTip=ah.disabledTip,visible=ah.visible~=false,saved=ah.saved~=false,
changed=aa.new()},ac)local ak=ad[ae]local al=ai if ak then al=ak(aj,ai)if al==
nil and ae=='slider'then al=ah.min end if al==nil and ae=='dropdown'then al=
false end end aj.value=unwrap(aj,al)aj.default=aj.value return aj end function
ac.set(ae,af)local ag=ad[ae.kind]local ah=af if ag then ah=ag(ae,af)if ah==nil
then return false end ah=unwrap(ae,ah)end local ai=ae.value if ai~=nil and ah~=
nil and equal(ae,ai,ah)then return false end if ai==nil and ah==nil then return
false end ae.value=ah ae:notify()return true end function ac.reset(ae)local af=
ae.default if ae.kind=='dropdown'and ae.spec.multi then af=table.clone(af)end ae
:set(af)end local function redraw(ae)local af=ae._view if af then af.refresh()
end local ag=ae.host if ag and ag._view then ag._view.refresh()end end function
ac.notify(ae)redraw(ae)ae.changed:fire(ae.value)end function ac.fire(ae)ae.
changed:fire(ae.value)end function ac.on(ae,af)return ae.changed:connect(af)end
function ac.setLabel(ae,af)if ae.label==af then return end ae.label=af if ae.
kind=='label'then ae.value=af local ag=ae._relayout if ag then ag()end end
redraw(ae)end function ac.setTip(ae,af)ae.tip=af end function ac.setDisabled(ae,
af,ag)ae.disabled=af==true ae.disabledTip=ag or ae.disabledTip redraw(ae)end
function ac.setVisible(ae,af)if ae.visible==af then return end ae.visible=af
local ag=ae._relayout if ag then ag()end end function ac.setOptions(ae,af)local
ag=ae.spec ag.options=table.clone(af)if ae._relayout then ae._relayout()end if
ag.multi then if ag.keep then for ah,ai in ae.value do if ai and not table.find(
ag.options,ah)then table.insert(ag.options,ah)end end else local ah=false for ai
in ae.value do if not table.find(ag.options,ai)then ae.value[ai]=nil ah=true end
end if ah then ae:notify()return end end elseif ae.value~=nil and not table.
find(ag.options,ae.value)then if ag.keep then table.insert(ag.options,ae.value)
else ae.value=nil ae:notify()return end end redraw(ae)end function ac.isModified
(ae)if ae.kind=='button'or ae.kind=='label'or ae.kind=='divider'or ae.kind==
'stat'then return false end local af,ag=ae.value,ae.default if af==nil or ag==
nil then return af~=ag end return not equal(ae,af,ag)end function ac.attach(ae,
af)local ag=ae.addons if ag==nil then ag={}ae.addons=ag end table.insert(ag,af)
af.host=ae redraw(ae)end function ac.shown(ae)if not ae.visible or(ae.kind==
'label'and ae.label=='')then return false end local af=ae.guard return af==nil
or af()end return ab end function a.o()local aa=a.cache.o if not aa then aa={c=
__modImpl()}a.cache.o=aa end return aa.c end end do local function __modImpl()
local aa=a.o()local ab={}local ac={}ac.__index=ac local function add(ad,ae,af,ag
,ah,ai)local aj=aa.new(ae,af or(ae..'#'..tostring(ad._page:nextId())),ag,ah,ai)
aj.section=ad aj.guard=ad._guard ad._page:_register(aj,af~=nil)table.insert(ad.
rows,aj)ad._page:_invalidate()return aj end function ac.toggle(ad,ae,af)local ag
=add(ad,'toggle',ae,af.label or ae,af,af.default==true)if af.onChanged then ag:
on(af.onChanged)end return ag end function ac.master(ad,ae,af)af.primary=true
local ag=ad:toggle(ae,af)ad.masterElement=ag local ah=ad._page ag:on(function()
ah:_invalidate()end)return ag end function ac.slider(ad,ae,af)af.min=af.min or 0
af.max=af.max or 100 af.step=af.step or 1 if af.decimals==nil then local ag=
string.format('%.10f',af.step)local ah=string.match(ag,'%.(%d-)0*$')af.decimals=
if ah then#ah else 0 end local ag=add(ad,'slider',ae,af.label or ae,af,af.
default or af.min)if af.onChanged then ag:on(af.onChanged)end return ag end
function ac.dropdown(ad,ae,af)af.options=af.options or{}local ag=af.default if
ag==nil and af.multi then ag={}end local ah=add(ad,'dropdown',ae,af.label or ae,
af,ag)if af.onChanged then ah:on(af.onChanged)end return ah end function ac.
input(ad,ae,af)local ag=add(ad,'input',ae,af.label or'',af,af.default or'')if af
.onChanged then ag:on(af.onChanged)end return ag end function ac.key(ad,ae,af)
local ag=add(ad,'key',ae,af.label or ae,af,{key=af.default or'None',mode=af.mode
or'Toggle',modifiers=af.modifiers or{}})ad._page.window.keys:register(ag)return
ag end function ac.color(ad,ae,af)local ag=add(ad,'color',ae,af.label or ae,af,{
color=af.default or Color3.new(1,1,1),alpha=af.alphaValue or 0})if af.onChanged
then ag:on(af.onChanged)end return ag end function ac.button(ad,ae,af)local ag=
if type(af)=='function'then{onPressed=af}else af ag.saved=false local ah=add(ad,
'button',nil,ae,ag,nil)if ag.onPressed then ah:on(ag.onPressed)end return ah end
function ac.label(ad,ae,af)local ag=af or{}ag.saved=false return add(ad,'label',
nil,ae,ag,ae)end function ac.stat(ad,ae,af)return add(ad,'stat',nil,ae,{saved=
false},tostring(af))end function ac.divider(ad,ae)return add(ad,'divider',nil,ae
or'',{saved=false},nil)end function ac.addKey(ad,ae,af,ag)local ah=aa.new('key',
af,ag.label or ae.label,ag,{key=ag.default or'None',mode=ag.mode or'Toggle',
modifiers=ag.modifiers or{}})ah.section=ad local ai=ah ai.toggled=ag.toggled==
true if ae.kind=='toggle'and ag.onPress==nil then ai.toggled=ae.value ag.onPress
=function()ae:set(not ae.value)ai.toggled=ae.value end end ad._page:_register(ah
,true)ad._page.window.keys:register(ah)ae:attach(ah)return ah end function ac.
addColor(ad,ae,af,ag)local ah=aa.new('color',af,ag.label or ae.label,ag,{color=
ag.default or Color3.new(1,1,1),alpha=ag.alphaValue or 0})ah.section=ad ad._page
:_register(ah,true)ae:attach(ah)if ag.onChanged then ah:on(ag.onChanged)end
return ah end function ac.when(ad,ae,af)local ag=ad._guard local ah=ae if ag
then ah=function()return ag()and ae()end end local ai=setmetatable({rows=ad.rows
,title=ad.title,_page=ad._page,_guard=ah,_root=ad._root or ad},ac)for aj,ak in(
af or{})do ak:on(function()ad._page:_invalidate()end)end return ai end function
ab.new(ad,ae)return setmetatable({title=ae,rows={},_page=ad,_guard=nil,_root=nil
},ac)end return ab end function a.p()local aa=a.cache.p if not aa then aa={c=
__modImpl()}a.cache.p=aa end return aa.c end end do local function __modImpl()
local aa=a.m()local ab=a.f()local ac=a.j()local ad=a.b()local ae=a.p()local af={
}local ag=26 local ah=36 function af.open(ai,aj,ak)if ai._dialogClose then ai.
_dialogClose()end local al=ai.ctx local am=al.theme local an=ai._layer local ao=
aj.width or 460 local b=aj.maxHeight or 340 local c=38 local d=ab('TextButton',{
Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BackgroundColor3=Color3.new(0
,0,0),ZIndex=50,Parent=an})local e=ad.prop(d,'BackgroundTransparency',22)e:to(
0.4)local f=ab('Frame',{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.
fromScale(0.5,0.5),Size=UDim2.fromOffset(ao,0),BackgroundTransparency=0,
ClipsDescendants=true,Active=true,ZIndex=51,Parent=an})am:paint(f,
'BackgroundColor3','base')ab('UICorner',{CornerRadius=UDim.new(0,14),Parent=f})
ab('UIScale',{Scale=al.uiScale(),Parent=f})local g=ab('UIStroke',{
ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=f})am:paint(g,'Color',
'lineStrong')local h=ab('TextLabel',{Position=UDim2.fromOffset(20,16),Size=UDim2
.new(1,-40,0,40),TextSize=20,Text=aj.title or'',ZIndex=52,Parent=f})am:type(h,
'display')am:paint(h,'TextColor3','text')local i=60 local j=aj.text if j and j~=
''then local k=ab('TextLabel',{Position=UDim2.fromOffset(20,i),Size=UDim2.new(1,
-40,0,22),AutomaticSize=Enum.AutomaticSize.Y,TextSize=16,TextWrapped=true,Text=j
,ZIndex=52,Parent=f})am:type(k,'text')am:paint(k,'TextColor3','muted')i+=22+math
.floor(#j/52)*22+12 end local k=ab('ScrollingFrame',{Position=UDim2.fromOffset(
20,i),Size=UDim2.new(1,-40,0,0),ScrollBarThickness=3,ZIndex=52,Parent=f})am:
paint(k,'ScrollBarImageColor3','lineStrong')local l=false local m={window=ai,
name='Dialog',nextId=function()ai._dialogIds+=1 return ai._dialogIds end,
_register=function(m,n,o)n._pageName='Dialog'if o then ai.elements[n.id]=n end
end,_invalidate=function()end}local n=ae.new(m,'')local o,p=xpcall(ak,debug.
traceback,n)if not o then warn('sottUI: dialog build failed: '..tostring(p))end
local q={}local r=0 for s,t in n.rows do if t:shown()then aa.measure(t,ao-40)
local u=aa.build(al,t)local v=c if t.kind=='divider'then v=28 elseif t.kind==
'label'then local w=math.ceil(ac.width('text',t.label,16)/(ao-48))v=if t.spec.
wrap then w*21+12 else 32 end u.root.Position=UDim2.fromOffset(0,r)u.root.Size=
UDim2.new(1,0,0,v)u.root.Parent=k r+=v+3 table.insert(q,u)end end k.CanvasSize=
UDim2.fromOffset(0,r)local s=math.min(r,b)k.Size=UDim2.new(1,-40,0,s)local t=i+s
+12 local u=ab('TextButton',{Position=UDim2.fromOffset(20,t),Size=UDim2.new(1,-
40,0,44),BackgroundTransparency=0,TextSize=15,Text=aj.done or'Done',ZIndex=52,
Parent=f})ab('UICorner',{CornerRadius=UDim.new(0,10),Parent=u})am:type(u,
'display')am:paint(u,'BackgroundColor3','accent')am:paint(u,'TextColor3',
'onAccent')local v=t+44+20 local w=ad.prop(f,'Size',ag)w:to(UDim2.fromOffset(ao,
v))local function close()if l then return end l=true ai._dialogClose=nil d.
Active=false for x,y in n.rows do if ai.elements[y.id]==y then ai.elements[y.id]
=nil end for z,A in y.addons or{}do ai.keys:unregister(A)if ai.elements[A.id]==A
then ai.elements[A.id]=nil end end end if aj.onClose then task.spawn(aj.onClose)
end e:to(1,function()e:destroy()d:Destroy()end)w.speed=ah w:to(UDim2.fromOffset(
ao,0),function()for x,y in q do y.destroy()end w:destroy()f:Destroy()end)end ai.
_dialogClose=close d.MouseButton1Down:Connect(close)u.Activated:Connect(close)
end return af end function a.q()local aa=a.cache.q if not aa then aa={c=
__modImpl()}a.cache.q=aa end return aa.c end end do local function __modImpl()
local aa=a.a()local ab={}local ac={text={name='SottUIText',faces={{name=
'Regular',weight=400,file='text-400.ttf'},{name='Medium',weight=500,file=
'text-500.ttf'}}},display={name='SottUIDisplay',faces={{name='SemiBold',weight=
600,file='display-600.ttf'}}}}local ad=10000 local function family(ae,af,ag,ah,
ai)local aj={}for ak,al in ag.faces do local am=af..'/'..al.file local an=ae.
read(am)if an==nil or#an<ad then local ao=aa.fetch(ah..al.file)if ao==nil or#ao<
ad then return nil end if not ae.write(am,ao)then return nil end end local ao=ae
.asset(am)if ao==nil then return nil end table.insert(aj,{name=al.name,weight=al
.weight,style='normal',assetId=ao})end local ak=af..'/'..ag.name..'.json'if not
ae.write(ak,ai({name=ag.name,faces=aj}))then return nil end return ae.asset(ak)
end function ab.load(ae,af,ag)local ah=aa.files()if ah==nil or aa.global(
'getcustomasset')==nil then return{}end ah.folder(ae)local ai={}local aj,ak=
pcall(function()ai.text=family(ah,ae,ac.text,af,ag)ai.display=family(ah,ae,ac.
display,af,ag)end)if not aj then warn('sottUI: fonts unavailable: '..tostring(ak
))end return ai end function ab.image(ae,af,ag)local ah=aa.files()if ah==nil or
aa.global('getcustomasset')==nil then return nil end ah.folder(ae)local ai=ae..
'/'..ag if ah.read(ai)==nil then local aj=aa.fetch(af..ag)if aj==nil or not ah.
write(ai,aj)then return nil end end return ah.asset(ai)end return ab end
function a.r()local aa=a.cache.r if not aa then aa={c=__modImpl()}a.cache.r=aa
end return aa.c end end do local function __modImpl()local aa=a.f()local ab={}
local function stroke(ac,ad,ae,af,ag,ah,ai)local aj=aa('Frame',{AnchorPoint=
Vector2.new(0.5,0.5),Position=UDim2.fromOffset(ah,ai),Size=UDim2.fromOffset(af,2
),Rotation=ag,BackgroundTransparency=0,Parent=ac})ad:paint(aj,'BackgroundColor3'
,ae)return aj end function ab.new(ac)local ad={}function ad.chevron(ae,af,ag)
local ah=aa('Frame',{Size=UDim2.fromOffset(12,12),Parent=ae})if ag=='right'then
stroke(ah,ac,af,7,45,6,3.6)stroke(ah,ac,af,7,-45,6,8.4)elseif ag=='up'then
stroke(ah,ac,af,7,-45,3.6,6)stroke(ah,ac,af,7,45,8.4,6)else stroke(ah,ac,af,7,45
,3.6,6)stroke(ah,ac,af,7,-45,8.4,6)end return ah end function ad.cross(ae,af)
local ag=aa('Frame',{Size=UDim2.fromOffset(12,12),Parent=ae})stroke(ag,ac,af,13,
45,6,6)stroke(ag,ac,af,13,-45,6,6)return ag end function ad.dash(ae,af)local ag=
aa('Frame',{Size=UDim2.fromOffset(12,12),Parent=ae})stroke(ag,ac,af,12,0,6,6)
return ag end return ad end return ab end function a.s()local aa=a.cache.s if
not aa then aa={c=__modImpl()}a.cache.s=aa end return aa.c end end do local 
function __modImpl()local aa={}aa.__index=aa local function dispose(ab)local ac=
typeof(ab)if ac=='RBXScriptConnection'then ab:Disconnect()elseif ac=='Instance'
then ab:Destroy()elseif ac=='function'then ab()elseif ac=='thread'then task.
cancel(ab)elseif ac=='table'then local ad=ab.destroy or ab.Destroy or ab.
Disconnect if ad then ad(ab)end end end function aa.add(ab,ac)table.insert(ab.
_items,ac)return ac end function aa.clean(ab)local ac=ab._items ab._items={}for
ad=#ac,1,-1 do local ae,af=pcall(dispose,ac[ad])if not ae then warn(
'sottUI: cleanup failed: '..tostring(af))end end end aa.destroy=aa.clean return{
new=function()return((setmetatable({_items={}},aa)))end}end function a.t()local
aa=a.cache.t if not aa then aa={c=__modImpl()}a.cache.t=aa end return aa.c end
end do local function __modImpl()local aa=a.a()local ab=a.t()local ac=a.n()local
ad={}local ae={}ae.__index=ae function ae.pointer(af)local ag=af._guiService:
GetGuiInset()return af._uis:GetMouseLocation()-ag end function ae.at(af,ag)local
ah=ag.Position return Vector2.new(ah.X,ah.Y)end function ae.capture(af,ag,ah,ai)
af:release()af._move=ag af._finish=ah af._finger=ai end function ae.release(af)
local ag=af._finish af._move=nil af._finish=nil af._finger=nil if ag then task.
spawn(ag,af:pointer())end end function ae.typing(af)return af._uis:
GetFocusedTextBox()~=nil end function ae.destroy(af)af._move=nil af._finish=nil
af._maid:clean()af.keyDown:clear()af.keyUp:clear()af.wheel:clear()af.moved:
clear()af.pointerUp:clear()end function ad.new()local af=aa.service(
'UserInputService')local ag=ab.new()local ah=setmetatable({_uis=af,_guiService=
aa.service('GuiService'),_maid=ag,_move=nil,_finish=nil,keyDown=ac.new(),keyUp=
ac.new(),wheel=ac.new(),moved=ac.new(),pointerUp=ac.new()},ae)ag:add(af.
InputChanged:Connect(function(ai)local aj=ai.UserInputType if aj==Enum.
UserInputType.MouseMovement then local ak=ah:pointer()if ah._move then ah._move(
ak)end ah.moved:fire(ak)elseif aj==Enum.UserInputType.Touch then if ah._move and
(ah._finger==nil or ah._finger==ai)then ah._move(ah:at(ai))end elseif aj==Enum.
UserInputType.MouseWheel then ah.wheel:fire(ai.Position.Z)end end))ag:add(af.
InputEnded:Connect(function(ai,aj)local ak=ai.UserInputType if ak==Enum.
UserInputType.MouseButton1 or ak==Enum.UserInputType.Touch then if ah._move and(
ak~=Enum.UserInputType.Touch or ah._finger==nil or ah._finger==ai)then local al=
if ak==Enum.UserInputType.Touch then ah:at(ai)else ah:pointer()local am=ah.
_finish ah._move=nil ah._finish=nil ah._finger=nil if am then am(al)end end ah.
pointerUp:fire()end ah.keyUp:fire(ai,aj)end))ag:add(af.InputBegan:Connect(
function(ai,aj)ah.keyDown:fire(ai,aj)end))return ah end return ad end function a
.u()local aa=a.cache.u if not aa then aa={c=__modImpl()}a.cache.u=aa end return
aa.c end end do local function __modImpl()local aa={}local ab={[Enum.
UserInputType.MouseButton1]='MB1',[Enum.UserInputType.MouseButton2]='MB2',[Enum.
UserInputType.MouseButton3]='MB3'}local ac={MB1=Enum.UserInputType.MouseButton1,
MB2=Enum.UserInputType.MouseButton2,MB3=Enum.UserInputType.MouseButton3}local ad
={[Enum.KeyCode.LeftAlt]='LAlt',[Enum.KeyCode.RightAlt]='RAlt',[Enum.KeyCode.
LeftControl]='LCtrl',[Enum.KeyCode.RightControl]='RCtrl',[Enum.KeyCode.LeftShift
]='LShift',[Enum.KeyCode.RightShift]='RShift'}local function nameOf(ae)local af=
ab[ae.UserInputType]if af then return af end if ae.UserInputType==Enum.
UserInputType.Keyboard and ae.KeyCode.Name~='Unknown'then return ae.KeyCode.Name
end return nil end function aa.new(ae,af,ag)local ah=af.service(
'UserInputService')local ai={}local aj={}local ak=nil local al=false local am=
nil local an=nil local function modifiersHeld(ao)for b,c in(ao or{})do local d=
false for e,f in ad do if f==c and ah:IsKeyDown(e)then d=true end end if not d
then return false end end return true end local function heldModifiers(ao)local
b={}for c,d in ad do if c.Name~=ao and ah:IsKeyDown(c)then table.insert(b,d)end
end table.sort(b)return b end function ai.register(ao,b)table.insert(aj,b)end
function ai.unregister(ao,b)local c=table.find(aj,b)if c then table.remove(aj,c)
end end function ai.listen(ao,b,c)ai.cancel()ak=b al=c==true end function ai.
swallowed(ao,b)return an==b end function ai.cancel()local ao=ak ak=nil am=nil if
ao then ao(nil)end end function ai.state(ao,b)local c=b.value if c==nil then
return false end if c.mode=='Always'then return true end if c.mode=='Toggle'then
return b.toggled==true end if c.key=='None'or ak~=nil or ae:typing()then return
false end local d=ac[c.key]if d then return not ag()and ah:IsMouseButtonPressed(
d)and modifiersHeld(c.modifiers)end local e,f=pcall(function()return ah:
IsKeyDown((Enum.KeyCode)[c.key])end)return e and f and modifiersHeld(c.modifiers
)end ae.keyDown:connect(function(ao)local b=nameOf(ao)if b==nil then return end
if ak then local c=ab[ao.UserInputType]~=nil if c and(al or b=='MB1')then return
end if ad[ao.KeyCode]and not c then am=b return end local d=ak ak=nil am=nil an=
b if b=='Escape'then(d)('None',{})else(d)(b,heldModifiers(b))end return end if
an==b then return end if ae:typing()then return end for c,d in aj do local e=d.
value if e.key==b and not d.disabled and modifiersHeld(e.modifiers)then if e.
mode=='Toggle'then d.toggled=not d.toggled end local f=d.spec.onPress if f then
f(d,d.toggled)end end end end)ae.keyUp:connect(function(ao)local b=nameOf(ao)if
b==nil then return end if am==b and ak then local c=ak ak=nil am=nil c(b,{})
return end if an==b then an=nil end for c,d in aj do local e=d.value if e.key==b
and e.mode=='Hold'and d.spec.onRelease then d.spec.onRelease(d)end end end)
return ai end return aa end function a.v()local aa=a.cache.v if not aa then aa={
c=__modImpl()}a.cache.v=aa end return aa.c end end do local function __modImpl()
local aa=a.f()local ab=a.b()local ac={}local ad=320 local ae=8 local af=20 local
ag=26 local ah=5 function ac.new(ai,aj)local ak=ai.theme local al={}local am={}
local function layout()local an=aj.AbsoluteSize local ao=an.Y-af for b=#al,1,-1
do local c=al[b]ao-=c.height c.pos:to(UDim2.fromOffset(an.X-ad-af,ao))ao-=ae end
end local function dismiss(an)if an.gone then return end an.gone=true if an.
timer then task.cancel(an.timer)end local ao=table.find(al,an)if ao then table.
remove(al,ao)end local b=aj.AbsoluteSize an.pos:to(UDim2.fromOffset(b.X+8,an.
frame.Position.Y.Offset),function()an.pos:destroy()an.frame:Destroy()end)layout(
)end function am.show(an,ao)while#al>=ah do dismiss(al[1])end local b=aj.
AbsoluteSize local c=aa('TextButton',{Name='Notice',Position=UDim2.fromOffset(b.
X+8,b.Y-af-60),Size=UDim2.fromOffset(ad,60),BackgroundTransparency=0,ZIndex=80,
Parent=aj})ak:paint(c,'BackgroundColor3','surface')aa('UICorner',{CornerRadius=
UDim.new(0,12),Parent=c})local d=aa('UIStroke',{ApplyStrokeMode=Enum.
ApplyStrokeMode.Border,Parent=c})ak:paint(d,'Color','lineStrong')local e=aa(
'Frame',{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,5,0.5,0),Size=UDim2
.new(0,3,1,-24),BackgroundTransparency=0,ZIndex=81,Parent=c})aa('UICorner',{
CornerRadius=UDim.new(1,0),Parent=e})ak:paint(e,'BackgroundColor3','accent')
local f=10 if ao.title and ao.title~=''then local g=aa('TextLabel',{Position=
UDim2.fromOffset(18,f),Size=UDim2.new(1,-32,0,24),TextSize=22,TextTruncate=Enum.
TextTruncate.AtEnd,Text=ao.title,ZIndex=81,Parent=c})ak:type(g,'display')ak:
paint(g,'TextColor3','text')f+=26 end local g=nil if ao.text and ao.text~=''then
g=aa('TextLabel',{Position=UDim2.fromOffset(18,f),Size=UDim2.new(1,-32,0,20),
TextSize=16,TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top,RichText=
true,Text=ao.text,ZIndex=81,Parent=c})ak:type(g,'text')ak:paint(g,'TextColor3',
'muted')end local h={frame=c,height=f+28,pos=ab.prop(c,'Position',ag),gone=false
}c.Size=UDim2.fromOffset(ad,h.height)if g then task.defer(function()if h.gone
then return end local i=math.ceil(g.TextBounds.Y)if i>20 then g.Size=UDim2.new(1
,-32,0,i)h.height=f+i+10 c.Size=UDim2.fromOffset(ad,h.height)layout()end end)end
h.pos:snap(UDim2.fromOffset(b.X+8,b.Y-af-h.height))table.insert(al,h)c.Activated
:Connect(function()dismiss(h)end)h.timer=task.delay(ao.seconds or 5,function()h.
timer=nil dismiss(h)end)layout()end function am.destroy(an)for ao,b in table.
clone(al)do if b.timer then task.cancel(b.timer)end b.pos:destroy()b.frame:
Destroy()end table.clear(al)end return am end return ac end function a.w()local
aa=a.cache.w if not aa then aa={c=__modImpl()}a.cache.w=aa end return aa.c end
end do local function __modImpl()local aa=a.f()local ab=a.b()local ac={}local ad
=34 local ae=48 local af=0.55 local ag=340 local ah=40 local ai=8 function ac.
popover(aj,ak)local al=aj.theme local am={}local an=nil local function close()
local ao=an if ao==nil then return end an=nil ao.catcher:Destroy()ao.open=false
ao.size.speed=ae ao.size:to(UDim2.fromOffset(ao.width,0),function()ao.size:
destroy()ao.frame:Destroy()end)if ao.disconnectEl then ao.disconnectEl()end end
function am.open(ao,b,c,d,e)close()aj.tooltip:hide()local f=ak.AbsoluteSize
local g,h=b.AbsolutePosition-ak.AbsolutePosition,b.AbsoluteSize c=math.min(c,f.X
-2*ai)d=math.min(d,f.Y-2*ai)local i=if c>h.X then g.X+h.X-c else g.X local j=
math.clamp(i,ai,f.X-c-ai)local k=g.Y+h.Y+2 local l=math.max(aj.popoverTop(),ai)
local m=k+d+ai>f.Y and g.Y-d-2>l local n=if m then g.Y-d-2 else math.max(math.
min(k,f.Y-d-ai),l)local o=aa('TextButton',{Name='Catcher',Size=UDim2.fromScale(1
,1),ZIndex=60,Parent=ak})local p=aa('Frame',{Name='Popover',Position=UDim2.
fromOffset(j,n),Size=UDim2.fromOffset(c,0),BackgroundTransparency=0,
ClipsDescendants=true,ZIndex=61,Active=true,Parent=ak})al:paint(p,
'BackgroundColor3','raised')aa('UICorner',{CornerRadius=UDim.new(0,10),Parent=p}
)local q=aa('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=p})al
:paint(q,'Color','lineStrong')local r=aa('Frame',{Size=UDim2.fromScale(1,1),
Parent=p})local s={frame=p,catcher=o,width=c,open=true,size=ab.prop(p,'Size',ad)
}an=s o.MouseButton1Down:Connect(close)o.MouseButton2Down:Connect(close)local t=
{close=close,resize=function(t)if s.open then s.size:to(UDim2.fromOffset(c,t))
end end,onKey=function(t)s.onKey=t end,onRefresh=function(t)s.onRefresh=t end}e(
r,t)s.size:to(UDim2.fromOffset(c,d))end function am.isOpen(ao)return an~=nil end
function am.close(ao)close()end function am.key(ao,b)if an==nil then return
false end if b=='Escape'then close()return true end if an.onKey then an.onKey(b)
return true end return false end return am end function ac.tooltip(aj,ak)local
al=aj.theme local am=aa('Frame',{Name='Tooltip',AutomaticSize=Enum.AutomaticSize
.XY,BackgroundTransparency=0,Visible=false,ZIndex=70,Parent=ak})al:paint(am,
'BackgroundColor3','raised')aa('UICorner',{CornerRadius=UDim.new(0,8),Parent=am}
)local an=aa('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=am})
al:paint(an,'Color','lineStrong')aa('UIPadding',{PaddingLeft=UDim.new(0,10),
PaddingRight=UDim.new(0,10),PaddingTop=UDim.new(0,7),PaddingBottom=UDim.new(0,7)
,Parent=am})local ao=aa('TextLabel',{AutomaticSize=Enum.AutomaticSize.XY,
TextSize=16,TextWrapped=true,ZIndex=71,Parent=am})aa('UISizeConstraint',{MaxSize
=Vector2.new(ag,400),Parent=ao})al:type(ao,'text')al:paint(ao,'TextColor3',
'text')local b={}local c=nil function b.hide(d)if c then task.cancel(c)c=nil end
am.Visible=false end local d=ab.prop(am,'Position',ah)function b.showAt(e,f,g)e:
hide()ao.Text=g am.Visible=true task.defer(function()if not am.Visible then
return end local h=ak.AbsoluteSize local i=am.AbsoluteSize local j=f.
AbsolutePosition-ak.AbsolutePosition local k=math.clamp(j.X,ai,h.X-i.X-ai)local
l=j.Y+f.AbsoluteSize.Y+3 local m=l+i.Y+ai>h.Y local n=if m then j.Y-i.Y-3 else l
d:snap(UDim2.fromOffset(k,n+(if m then 8 else-8)))d:to(UDim2.fromOffset(k,n))end
)end function b.schedule(e,f,g)e:hide()c=task.delay(af,function()c=nil if f.
Parent~=nil then e:showAt(f,g)end end)end return b end function ac.hover(aj)
local ak={}local al=nil local function clear()local am=al if am then al=nil am:
onHover(false)aj.tooltip:hide()end end function ak.current(am)return al end
function ak.enter(am,an)if al==an then return end clear()al=an an:onHover(true)
local ao=an.el local b=if ao.disabled and ao.disabledTip then ao.disabledTip
else ao.tip if b and b~=''then aj.tooltip:schedule(an.root,b)end end function ak
.leave(am,an)if al==an then clear()end end ak.clear=clear function ak.verify(am,
an)local ao=al if ao==nil then return end local b=ao.root local c,d=b.
AbsolutePosition,b.AbsoluteSize local e=an.X>=c.X and an.Y>=c.Y and an.X<=c.X+d.
X and an.Y<=c.Y+d.Y if not e or not b.Visible or b.Parent==nil or aj.popover:
isOpen()then clear()end end return ak end return ac end function a.x()local aa=a
.cache.x if not aa then aa={c=__modImpl()}a.cache.x=aa end return aa.c end end
do local function __modImpl()local aa=a.m()local ab=a.f()local ac=a.j()local ad=
a.b()local ae=a.p()local af={}local ag=14 local ah=14 local ai=14 local aj=12
local ak=560 local al=6 local am=14 local an=42 local ao=3 local b=16 local c=14
local d=16 local e=112 local f=360 local g=110 local h=24 local i=26 local j=18
local k=24 local l=10 local m=44 local n=3 local o=4 local p=40 local q={}q.
__index=q function q.nextId(r)r._ids+=1 return r._ids end function q._register(r
,s,t)s._relayout=function()r:_invalidate()end r.window:_registerElement(s,r,t)
end function q._invalidate(r)if r._dirty then return end r._dirty=true task.
defer(function()r._dirty=false if not r.destroyed then r:layout(not r._quiet)r.
_quiet=false end end)end function q.section(r,s)local t=ae.new(r,s)table.insert(
r.sections,t)r:_invalidate()return t end function q.tabset(r)local s=ae.new(r,''
)s.tabNames={}s.activeTab=1 table.insert(r.sections,s)local t={}function t.tab(u
,v)table.insert(s.tabNames,v)local w=#s.tabNames local x=s:when(function()return
s.activeTab==w end)x.title=v local y=r._headers[s]if y then y:Destroy()r.
_headers[s]=nil end r:_invalidate()return x end return t end function q.tabs(r,s
)local t=r:tabset()local u={}for v,w in s do table.insert(u,t:tab(w))end return
u end function q.hero(r,s)r._hero=s r:_invalidate()local t=r._heroView return{
set=function(u,v,w)s.title=v or s.title s.text=w or s.text local x=r._heroView
or t if x then x.refresh()end end}end local function card(r,s,t)local u=ab(
'Frame',{Name=t,BackgroundTransparency=0,ZIndex=0,Parent=s})ab('UICorner',{
CornerRadius=UDim.new(0,am),Parent=u})r:paint(u,'BackgroundColor3','surface')
local v=ab('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,
Parent=u})r:paint(v,'Color','line')return u,v end local function buildHero(r)
local s=r.window.ctx local t=s.theme local u=r._hero local v=card(t,r.canvas,
'Hero')v.ClipsDescendants=true local w=ab('ImageLabel',{AnchorPoint=Vector2.new(
0.5,0.5),Position=UDim2.new(0,66,0.5,0),Size=UDim2.fromOffset(300,300),
BackgroundTransparency=1,BorderSizePixel=0,ImageTransparency=0.68,Parent=v})t:
paint(w,'ImageColor3','accent')s.art(w,'glow.png')if u.userId then local x=ab(
'ImageLabel',{Position=UDim2.fromOffset(10,4),Size=UDim2.fromOffset(112,112),
BackgroundTransparency=1,BorderSizePixel=0,Image=string.format(
'rbxthumb://type=AvatarBust&id=%d&w=420&h=420',u.userId),Parent=v})ab(
'UIGradient',{Rotation=90,Transparency=NumberSequence.new({
NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.75,0),
NumberSequenceKeypoint.new(1,1)}),Parent=x})end local x=ab('TextLabel',{Position
=UDim2.fromOffset(136,30),Size=UDim2.new(1,-152,0,34),TextSize=28,TextTruncate=
Enum.TextTruncate.AtEnd,ZIndex=2,Parent=v})t:type(x,'display')t:paint(x,
'TextColor3','text')local y=ab('TextLabel',{Position=UDim2.fromOffset(136,62),
Size=UDim2.new(1,-152,0,22),TextSize=15,TextTruncate=Enum.TextTruncate.AtEnd,
ZIndex=2,Parent=v})t:type(y,'text')t:paint(y,'TextColor3','muted')local z={root=
v,refresh=function()x.Text=u.title y.Text=u.text or''end}z.refresh()return z end
local function buildHeader(r,s)local t=r.window.ctx local u=t.theme local v=ab(
'Frame',{Name='Header',Parent=r.canvas})if s.tabNames then local w={}local x=0
for y,z in s.tabNames do local A=math.ceil(ac.width('textMedium',z,c))+d local B
=ab('TextButton',{Position=UDim2.fromOffset(x,0),Size=UDim2.new(0,A,1,0),
TextSize=c,Text=z,TextXAlignment=Enum.TextXAlignment.Left,Parent=v})u:type(B,
'text',true)w[y]=B B.Activated:Connect(function()s.activeTab=y for C,D in w do t
.tint(D,'TextColor3',if C==s.activeTab then'text'else'muted')end r:_invalidate()
end)u:paint(B,'TextColor3',if y==s.activeTab then'text'else'muted')x+=A end
return v end local w=ab('TextLabel',{Size=UDim2.fromScale(1,1),TextSize=b,
TextTruncate=Enum.TextTruncate.AtEnd,Text=s.title,Parent=v})u:type(w,'display')u
:paint(w,'TextColor3','text')return v end local function buildCard(r,s)local t=r
.window.ctx local u=t.theme local v,w=card(u,r.canvas,'Card')local x={root=v}
local y=s.masterElement if y then local z=y.value==true local A=ab('Frame',{Size
=UDim2.new(1,0,0,m),BackgroundTransparency=if z then 0 else 1,ZIndex=0,Parent=v}
)ab('UICorner',{CornerRadius=UDim.new(0,am),Parent=A})u:paint(A,
'BackgroundColor3','accentDim')ab('UIGradient',{Rotation=90,Transparency=
NumberSequence.new(0.25,1),Parent=A})u:paint(w,'Color',if z then'accentDim'else
'line')local B=ad.prop(A,'BackgroundTransparency',j)local C=y:on(function()local
C=y.value==true if r.active then B:to(if C then 0 else 1)t.tint(w,'Color',if C
then'accentDim'else'line')else B:snap(if C then 0 else 1)u:paint(w,'Color',if C
then'accentDim'else'line')end end)x.destroy=function()C()B:destroy()end end
return x end function q.layout(r,s)local t=r.frame if t==nil then return end r.
_live=s==true and r._settled==true and r.active local u=r.window.ctx.uiScale()
local v=t.AbsoluteSize.X/u if v<1 then return end local w=v-2*ag local x=r.
sections[1]~=nil and r.sections[1].flat==true local y=if w<ak or x then 1 else 2
local z=(w-aj*(y-1))/y local A={}local B=ah if r._hero then table.insert(A,{hero
=true,x=ag,y=B,width=w,height=e})B+=e+aj end local C=table.create(y,B)for D,E in
r.sections do local F=if E.flat then nil else E.masterElement local G=if F and F
:shown()then F else nil local H=G~=nil or(E.title~=nil and E.title~='')or E.
tabNames~=nil local I=z-2*al local J={}local K=0 for L,M in E.rows do if M~=F
and(E.flat or M:shown())then local N=aa.measure(M,I)table.insert(J,{el=M,height=
N})K+=N+ao end end if#J==0 and G==nil and E.tabNames==nil then continue end
local L=1 for M=2,y do if C[M]<C[L]-0.5 then L=M end end local M=ag+(L-1)*(z+aj)
local N=C[L]local O=(if H then an else al)+K+(if#J>0 then al-ao else 0)table.
insert(A,{card=E,x=M,y=N,width=z,height=O})if G then aa.measure(G,I)table.
insert(A,{el=G,x=M+al,y=N,width=I,height=an})elseif H then table.insert(A,{
section=E,x=M+al+12,y=N,width=z-2*(al+12),height=an})end local P=N+(if H then an
else al)for Q,R in J do table.insert(A,{el=R.el,x=M+al,y=P,width=I,height=R.
height})P+=R.height+ao end C[L]=N+O+aj end local D=B for E,F in C do D=math.max(
D,F)end D+=ai-aj t.CanvasSize=UDim2.fromOffset(0,D)r._contentHeight=D local E=
math.max(D-t.AbsoluteSize.Y/u,0)if r._scrollTarget and r._scrollTarget>E then r.
_scrollTarget=E r._scroll:snap(E)end r._placements=A r:_applyPlacements()r:
_materialize(true)r:_refreshThumb()r._live=false r._settled=r._settled or r.
active end local function setRect(r,s,t)local u=UDim2.fromOffset(s,t)if r._grow
then r._grow:snap(u)else r.root.Size=u end end local function growTo(r,s,t,u)if
r._grow==nil then r._grow=r:own(ad.prop(r.root,'Size',i))end r._grow:to(UDim2.
fromOffset(s,t),u)end function q._applyPlacements(r)local s={}local t={}for u,v
in r._placements do if v.hero then if r._heroView then r._heroView.root.Position
=UDim2.fromOffset(v.x,v.y)r._heroView.root.Size=UDim2.fromOffset(v.width,v.
height)end elseif v.card then t[v.card]=true local w=r._cards[v.card]if w then w
.root.Visible=true local x=UDim2.fromOffset(v.x,v.y)local y=UDim2.fromOffset(v.
width,v.height)if r._live then if w.at==nil then w.at=ad.prop(w.root,'Position',
i)w.size=ad.prop(w.root,'Size',i)end w.at:to(x)w.size:to(y)elseif w.at then w.at
:snap(x)w.size:snap(y)else w.root.Position=x w.root.Size=y end end elseif v.
section then s[v.section]=true local w=r._headers[v.section]if w then w.Visible=
true w.Position=UDim2.fromOffset(v.x,v.y)w.Size=UDim2.fromOffset(v.width,v.
height)end else s[v.el]=true local w=r._views[v.el]if w and w.form~=aa.form(v.el
)then w.destroy()r._views[v.el]=nil elseif w then r:_place(w,v)end end end for u
,v in r._headers do if not s[u]then v.Visible=false end end for u,v in r._cards
do if not t[u]then v.root.Visible=false end end for u,v in r._views do if not s[
u]and v.root.Visible and not v._folding then if r._live then v._folding=true
growTo(v,v.root.Size.X.Offset,0,function()v._folding=false v.root.Visible=false
end)else v.root.Visible=false end end end end function q._place(r,s,t)local u=s.
root local v=UDim2.fromOffset(t.x,t.y)local w=r._live local x=w and not u.
Visible local y=s._folding==true s._folding=false u.Visible=true if x then
setRect(s,t.width,0)growTo(s,t.width,t.height)elseif y or(w and u.Size~=UDim2.
fromOffset(t.width,t.height))then growTo(s,t.width,t.height)else setRect(s,t.
width,t.height)end if w and not x and u.Position~=v then if s._slide==nil then s
._slide=s:own(ad.prop(u,'Position',i))end s._slide:to(v)elseif s._slide then s.
_slide:snap(v)else u.Position=v end end function q._materialize(r,s)local t=r.
frame local u=r._placements if t==nil or u==nil or not r.active then return end
local v=r.window.ctx.uiScale()local w=t.CanvasPosition.Y/v if not s and r.
_lastSync and math.abs(w-r._lastSync)<f/3 then return end r._lastSync=w local x,
y=w-f,w+t.AbsoluteSize.Y/v+f for z,A in u do local B=A.y if B+A.height>=x and B
<=y then if A.hero then if r._heroView==nil then local C=buildHero(r)C.root.
Position=UDim2.fromOffset(A.x,B)C.root.Size=UDim2.fromOffset(A.width,A.height)r.
_heroView=C end elseif A.card then if r._cards[A.card]==nil then local C=
buildCard(r,A.card)C.root.Position=UDim2.fromOffset(A.x,B)C.root.Size=UDim2.
fromOffset(A.width,A.height)r._cards[A.card]=C end elseif A.section then if r.
_headers[A.section]==nil then local C=buildHeader(r,A.section)C.Position=UDim2.
fromOffset(A.x,B)C.Size=UDim2.fromOffset(A.width,A.height)r._headers[A.section]=
C end elseif r._views[A.el]==nil then A.el._shownOn=r local C,D=xpcall(aa.build,
debug.traceback,r.window.ctx,A.el)if C then D.root.Position=UDim2.fromOffset(A.x
,B)D.root.Size=UDim2.fromOffset(A.width,if r._live then 0 else A.height)D.root.
Parent=r.canvas r._views[A.el]=D if r._live then growTo(D,A.width,A.height)end
else warn('sottUI: row '..tostring(A.el.id)..' failed: '..tostring(D))end end
end end end function q._refreshThumb(r)local s=r.thumb if s==nil then return end
local t=r.window.ctx.uiScale()local u=r.frame.AbsoluteSize.Y/t local v=r.
_contentHeight or 0 if v<=u+1 or not r.active then s.Visible=false return end s.
Visible=true local w=u-2*ah local x=math.max(w*u/v,p)local y=w-x local z=r.frame
.CanvasPosition.Y/t/math.max(v-u,1)s.Size=UDim2.fromOffset(n,x)s.Position=UDim2.
new(1,-(n+o),0,ah+z*y)end function q.scrollTo(r,s,t)local u=r.frame if u==nil
then return end local v=r.window.ctx.uiScale()local w=math.max((r._contentHeight
or 0)-u.AbsoluteSize.Y/v,0)local x=math.clamp(s,0,w)r._scrollTarget=x if t then
r._scroll:snap(x)else r._scroll:to(x)end end function q.wheel(r,s)if r.frame==
nil or r.frame.ScrollingEnabled then return end local t=r._scrollTarget or r.
frame.CanvasPosition.Y/r.window.ctx.uiScale()r:scrollTo(t-s*g)end function q.
viewOf(r,s)return r._views[s]end function q.mount(r,s)if r.frame then return end
local t=r.window.ctx local u=ab('ScrollingFrame',{Name=r.name,Size=UDim2.
fromScale(1,1),Visible=false,ScrollingEnabled=t.touch,Parent=s})local v=ab(
'Frame',{Name='Canvas',Size=UDim2.fromScale(1,1),Parent=u})local w=ab('Frame',{
Name='Thumb',BackgroundTransparency=0,Visible=false,ZIndex=5,Parent=s})ab(
'UICorner',{CornerRadius=UDim.new(1,0),Parent=w})t.theme:paint(w,
'BackgroundColor3','lineStrong')r.frame=u r.canvas=v r.thumb=w r._scroll=ad.new(
0,h,function(x)u.CanvasPosition=Vector2.new(0,x*t.uiScale())end)r._enter=ad.
prop(v,'Position',k)u:GetPropertyChangedSignal('CanvasPosition'):Connect(
function()r:_materialize()r:_refreshThumb()end)local x=0 u:
GetPropertyChangedSignal('AbsoluteSize'):Connect(function()local y=u.
AbsoluteSize.X if y~=x then x=y r._quiet=true r:_invalidate()else r:
_materialize(true)r:_refreshThumb()end end)end function q.showList(r,s,t)r.
sections={{title='',rows=s,flat=true}}for u,v in s do v._shownOn=r end if r.
frame then if r._empty==nil then local u=r.window.ctx.theme r._empty=ab(
'TextLabel',{Position=UDim2.fromOffset(ag+12,ah+6),Size=UDim2.new(1,-2*(ag+12),0
,26),TextSize=15,ZIndex=2,Parent=r.frame})u:type(r._empty,'text')u:paint(r.
_empty,'TextColor3','muted')end r._empty.Text=t or''r._empty.Visible=t~=nil end
r:_invalidate()end function q.adopt(r)for s,t in r._views do s._view=t s.
_shownOn=r if t.refresh then t.refresh()end for u,v in t.addonChips or{}do u.
_view=v if v.refresh then v.refresh()end end end end function q.setActive(r,s,t)
r.active=s if r.frame then r.frame.Visible=s if not s then r.thumb.Visible=false
end end if s then r:layout()if r._enter then if t then r._enter:snap(UDim2.new()
)else r._enter:snap(UDim2.fromOffset(0,l))r._enter:to(UDim2.new())end end end
end function q.destroy(r)r.destroyed=true for s,t in r._views do t.destroy()end
r._views={}for s,t in r._cards do if t.destroy then t.destroy()end if t.at then
t.at:destroy()t.size:destroy()end end r._cards={}if r._scroll then r._scroll:
destroy()r._enter:destroy()end if r.frame then r.frame:Destroy()r.thumb:Destroy(
)end end function af.new(r,s)return setmetatable({name=s,window=r,sections={},
active=false,destroyed=false,_ids=0,_dirty=false,_headers={},_cards={},_views={}
,_placements=nil},q)end return af end function a.y()local aa=a.cache.y if not aa
then aa={c=__modImpl()}a.cache.y=aa end return aa.c end end do local function 
__modImpl()local aa=a.f()local ab=UDim2.fromOffset(16,72)local ac=44 return
function(ad,ae,af)local ag=aa('TextButton',{Name='Open',Position=ab,Size=UDim2.
fromOffset(ac,ac),BackgroundTransparency=0,TextSize=24,Text='s',Visible=false,
ZIndex=50,Parent=ad})ae:type(ag,'display')ae:paint(ag,'BackgroundColor3',
'accent')ae:paint(ag,'TextColor3','onAccent')ag.Activated:Connect(af)return ag
end end function a.z()local aa=a.cache.z if not aa then aa={c=__modImpl()}a.
cache.z=aa end return aa.c end end do local function __modImpl()local aa=a.n()
local ab={}local function rgb(ac)return Color3.fromRGB(bit32.band(bit32.rshift(
ac,16),255),bit32.band(bit32.rshift(ac,8),255),bit32.band(ac,255))end local ac={
base=rgb(0x50706),surface=rgb(0xc0f0d),raised=rgb(0x151a17),line=rgb(0x191f1c),
lineStrong=rgb(0x2a342f),text=rgb(0xebe8da),muted=rgb(0x97a39c),faint=rgb(
0x56615b),accent=rgb(0x7ee0c4),accentHover=rgb(0x9bebd4),accentDim=rgb(0x16362d)
,onAccent=rgb(0x6231b),danger=rgb(0xe5604d)}local ad=
'rbxasset://fonts/families/BuilderSans.json'local ae=
'rbxasset://fonts/families/BuilderSans.json'local af={}af.__index=af function ab
.defaults()return table.clone(ac)end function ab.new(ag)local ah=(ab.defaults())
for ai,aj in(ag or{})do ah[ai]=aj end local ai={tokens=ah,fonts={text=ad,display
=ae},changed=aa.new(),_paints={},_types={},_count=0}return((setmetatable(ai,af))
)end local ag=2000 local function sweep(ah)for ai in ah._paints do if ai.Parent
==nil then ah._paints[ai]=nil ah._types[ai]=nil end end for ai in ah._types do
if ai.Parent==nil then ah._types[ai]=nil end end end function af.paint(ah,ai,aj,
ak)local al=ah._paints[ai]if al==nil then al={}ah._paints[ai]=al ah._count+=1 if
ah._count%ag==0 then task.defer(sweep,ah)end end al[aj]=ak ai[aj]=ah.tokens[ak]
end function af.face(ah,ai,aj)if ai=='display'then return Font.new(ah.fonts.
display,Enum.FontWeight.SemiBold)end return Font.new(ah.fonts.text,if aj then
Enum.FontWeight.Medium else Enum.FontWeight.Regular)end function af.type(ah,ai,
aj,ak)ah._types[ai]={family=aj,medium=ak==true}ai.FontFace=ah:face(aj,ak)end
function af.forget(ah,ai)ah._paints[ai]=nil ah._types[ai]=nil end function af.
apply(ah,ai)for aj,ak in ai do ah.tokens[aj]=ak end for aj,ak in ah._paints do
for al,am in ak do pcall(function()aj[al]=ah.tokens[am]end)end end ah.changed:
fire()end function af.setFonts(ah,ai,aj)ah.fonts.text=ai or ah.fonts.text ah.
fonts.display=aj or ah.fonts.display for ak,al in ah._types do pcall(function()
ak.FontFace=ah:face(al.family,al.medium)end)end end return ab end function a.A()
local aa=a.cache.A if not aa then aa={c=__modImpl()}a.cache.A=aa end return aa.c
end end do local function __modImpl()local aa=a.b()local ab={}local ac=26
function ab.new(ad)local ae={}return function(af,ag,ah,ai)local aj=ad._paints[af
]if aj==nil then aj={}ad._paints[af]=aj end aj[ag]=ah local ak=ae[af]if ak==nil
then ak={}ae[af]=ak end local al=ak[ag]if al==nil then al=aa.prop(af,ag,ai or ac
)ak[ag]=al end al:to(ad.tokens[ah])end end return ab end function a.B()local aa=
a.cache.B if not aa then aa={c=__modImpl()}a.cache.B=aa end return aa.c end end
do local function __modImpl()local aa=a.q()local ab=a.a()local ac=a.r()local ad=
a.s()local ae=a.u()local af=a.v()local ag=a.t()local ah=a.f()local ai=a.j()local
aj=a.b()local ak=a.w()local al=a.x()local am=a.y()local an=a.h()local ao=a.p()
local b=a.z()local c=a.n()local d=a.A()local e=a.B()local f={}local g='main'
local h=[[https://raw.githubusercontent.com/interestng/sottUI/%s/fonts/]]local i
={'glow.png','shadow.png'}local j=860 local k=560 local l=48 local m=14 local n=
16 local o=32 local p=0.35 local q=14 local r=14 local s=7 local t=15 local u=17
local v=18 local w=168 local x=30 local y=96 local z=12 local A=30 local B=9
local C=2 local D=22 local E=20 local F=26 local G=20 local H=24 local I=12
local J={}J.__index=J local function randomName()local K=table.create(I)for L=1,
I do K[L]=string.char(math.random(97,122))end return table.concat(K)end local 
function encode(K)return ab.service('HttpService'):JSONEncode(K)end local 
function decode(K)local L,M=pcall(function()return ab.service('HttpService'):
JSONDecode(K)end)return if L then M else nil end function J._registerElement(K,L
,M,N)if M==K._resultsPage then return end L._pageName=M.name L._page=M if N then
if K.elements[L.id]then error('sottUI: element id used twice: '..L.id,3)end K.
elements[L.id]=L end if L.kind~='divider'and L.kind~='label'and L.kind~='stat'
then table.insert(K.ordered,L)end if L.kind=='toggle'and L.spec.primary then L:
on(function()K:_drawLamps()end)K:_drawLamps()end end function J._drawLamps(K)if
K._lampsQueued or K.destroyed then return end K._lampsQueued=true task.defer(
function()K._lampsQueued=false if K.destroyed then return end local L={}for M,N
in K.ordered do if N.kind=='toggle'and N.spec.primary and N.value==true and not
N.disabled then L[N._page]=true end end for M,N in K._tabs do local O=L[M]==true
if N.on~=O then N.on=O N.glow:to(if O then 0.3 else 1)N.fade:to(if O then 0 else
1)end end end)end function J._fit(K)local L=K._scale.Scale local M=K._gui.
AbsoluteSize/L K._width=math.min(j,M.X-2*n)K._height=math.min(k,M.Y-2*n)K._body.
Size=UDim2.new(1,0,0,K._height-l)K._size:snap(UDim2.fromOffset(K._width,if K.
isOpen then K._height else 0))K:_fitBar()end function J._fitBar(K)local L=K.
_rowLayout.AbsoluteContentSize.X/K._scale.Scale local M=K._width-L-A-6-B-z local
N=math.min(M,w)local O=N>=y K._field.Visible=O K._field.Size=UDim2.fromOffset(if
O then N else 0,x)K._right.Size=UDim2.new(0,(if O then N else 0)+A+6,1,0)end
function J._clamped(K,L)local M=K._scale.Scale local N=K._gui.AbsoluteSize local
O,P=K._width*M,K._height*M return Vector2.new(math.clamp(L.X,n,math.max(N.X-O-n,
n)),math.clamp(L.Y,n,math.max(N.Y-P-n,n)))end function J._keepOnScreen(K,L)local
M=K._at if M==nil then return end local N=K:_clamped(M)if N~=M then K._at=N if L
then K._position:to(UDim2.fromOffset(N.X,N.Y))else K._position:snap(UDim2.
fromOffset(N.X,N.Y))end end end function J._show(K,L,M)if K._showing==L then
return end K.ctx.hover.clear()K.ctx.popover:close()K.keys:cancel()local N=K.
_showing if N then N:setActive(false)end K._showing=L if L~=K._resultsPage then
K._lastPage=L end L:setActive(true,M)L:adopt()K:_syncMarker(M)K:_saveState()end
function J._syncMarker(K,L)local M=K.ctx.tint local N=nil for O,P in K._tabs do
local Q=K._showing==O M(P.button,'TextColor3',if Q then'text'else'muted')if Q
then N=P.button end end if N==nil then K._markerSize:to(UDim2.fromOffset(0,C))
return end local O=K._scale.Scale local P=(N.AbsolutePosition.X-K._top.
AbsolutePosition.X)/O local Q=UDim2.new(0,P+r,1,-C)local R=UDim2.fromOffset(N.
AbsoluteSize.X/O-2*r,C)if L or K._markerSize.target==nil or K._markerSize.target
.X.Offset==0 then K._markerAt:snap(Q)K._markerSize:snap(R)else K._markerAt:to(Q)
K._markerSize:to(R)end end local function addTab(K,L,M,N)local O=K.ctx local P=O
.theme local Q=math.ceil(ai.width('textMedium',M,q))+2*r+t local R=ah(
'TextButton',{Name=M,Size=UDim2.new(0,Q,1,0),TextSize=q,Text=M,TextXAlignment=
Enum.TextXAlignment.Left,LayoutOrder=N,ZIndex=3,Parent=K._row})ah('UIPadding',{
PaddingLeft=UDim.new(0,r+t),Parent=R})P:type(R,'text',true)P:paint(R,
'TextColor3','muted')local S=ah('ImageLabel',{AnchorPoint=Vector2.new(0.5,0.5),
Position=UDim2.new(0,-t+s/2,0.5,0),Size=UDim2.fromOffset(24,24),
BackgroundTransparency=1,BorderSizePixel=0,ImageTransparency=1,ZIndex=2,Parent=R
})P:paint(S,'ImageColor3','accent')O.art(S,'glow.png')local T=ah('Frame',{
AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0,-t+s/2,0.5,0),Size=UDim2.
fromOffset(s,s),BackgroundTransparency=0,ZIndex=3,Parent=R})ah('UICorner',{
CornerRadius=UDim.new(1,0),Parent=T})T.BackgroundTransparency=1 P:paint(T,
'BackgroundColor3','accent')K._tabs[L]={button=R,dot=T,glow=K._maid:add(aj.prop(
S,'ImageTransparency',G)),fade=K._maid:add(aj.prop(T,'BackgroundTransparency',G)
),on=false}R.Activated:Connect(function()if K._box.Text~=''then K._box.Text=''
end K:_show(L)end)R.MouseEnter:Connect(function()if K._showing~=L then O.tint(R,
'TextColor3','text')end end)R.MouseLeave:Connect(function()if K._showing~=L then
O.tint(R,'TextColor3','muted')end end)end function J.page(K,L)local M=am.new(K,L
)table.insert(K.pages,M)addTab(K,M,L,2+#K.pages)M:mount(K._body)K:_drawLamps()if
not K._firstQueued then K._firstQueued=true task.defer(function()if K.destroyed
or K._showing then return end local N=K.pages[1]for O,P in K.pages do if P.name
==K._savedPage then N=P end end if N then K:_show(N,true)end end)end return M
end function J._query(K,L)if L==''then if K._showing==K._resultsPage then K:
_show(K._lastPage or K.pages[1])end K._resultsPage:showList({})return end local
M={}for N,O in K.ordered do if O.visible~=false then table.insert(M,O)end end
local N=an.settings(L,M,H)K._resultsPage:showList(N,if#N==0 then
'Nothing matches'else nil)K:_show(K._resultsPage)end function J.showPage(K,L)for
M,N in K.pages do if N.name==L then K._box.Text=''K:_show(N)return end end end
function J.show(K,L,M)local N=K.pages[L]if N then K:_show(N,M)end end function J
.reveal(K,L)local M=L._page if M then K:setOpen(true)K:showPage(M.name)end end
function J.setOpen(K,L)if K.isOpen==L or K.destroyed then return end K.isOpen=L
if K._opener then K._opener.Visible=not L end K.ctx.hover.clear()K.ctx.popover:
close()K.ctx.tooltip:hide()K.keys:cancel()if not L and K._dialogClose then K.
_dialogClose()end local M=K._width if L then K._root.Visible=true K._modal.
Visible=true K:_guardCursor(true)if K._at==nil then local N=K._scale.Scale local
O=K._gui.AbsoluteSize K._at=Vector2.new((O.X-M*N)/2,(O.Y-K._height*N)/2)end K.
_at=K:_clamped(K._at)K._position:snap(UDim2.fromOffset(K._at.X,K._at.Y))K._size:
to(UDim2.fromOffset(M,K._height))K._shadowFade:to(p)else K._modal.Visible=false
K:_guardCursor(false)K._box:ReleaseFocus()K._box.Text=''K._shadowFade:to(1)K.
_size:to(UDim2.fromOffset(M,0),function()if not K.isOpen then K._root.Visible=
false end end)end K.visibilityChanged:fire(L)end function J._guardCursor(K,L)
local M=ab.service('UserInputService')if L then K._gameCursor=M.MouseIconEnabled
M.MouseIconEnabled=true if K._cursorGuard==nil then K._cursorGuard=M:
GetPropertyChangedSignal('MouseIconEnabled'):Connect(function()if not M.
MouseIconEnabled then K._gameCursor=false M.MouseIconEnabled=true end end)end
else if K._cursorGuard then K._cursorGuard:Disconnect()K._cursorGuard=nil end if
K._gameCursor~=nil then M.MouseIconEnabled=K._gameCursor K._gameCursor=nil end
end end function J.toggle(K)K:setOpen(not K.isOpen)end function J.notify(K,L)if
K.destroyed then return end K.ctx.notify(L)end function J.setTheme(K,L)K.ctx.
theme:apply(L)end function J.setScale(K,L)K._scale.Scale=math.clamp(L,0.7,1.5)K:
_fit()K:_keepOnScreen(false)local M=K._showing if M then M:scrollTo(M.
_scrollTarget or 0,true)end K:_saveState()end function J._saveState(K)local L=K.
_files if L==nil or K._stateFile==nil or K._stateQueued then return end K.
_stateQueued=true task.delay(0.5,function()K._stateQueued=false if not K.
destroyed then local M=K._at local N=K._lastPage L.write(K._stateFile,encode({
scale=K._scale.Scale,boxX=M and M.X,boxY=M and M.Y,page=N and N.name}))end end)
end function J.dialog(K,L,M)if K.destroyed then return false end aa.open(K,L,M)
return true end function J.find(K,L)return K.elements[L]end function J.snapshot(
K)local L={}for M,N in K.elements do if N.saved then local O=N.value if N.kind==
'color'then O={hex=O.color:ToHex(),alpha=O.alpha}elseif N.kind=='key'then O={key
=O.key,mode=O.mode,modifiers=O.modifiers,toggled=N.toggled==true}end L[M]=O end
end return L end function J.restore(K,L)for M,N in L do local O=K.elements[M]if
O and O.saved then if O.kind=='color'and type(N)=='table'then O:set({color=
Color3.fromHex(N.hex or'ffffff'),alpha=N.alpha})elseif O.kind=='key'and type(N)
=='table'then O:set(N)O.toggled=N.toggled==true else O:set(N)end end end end
function J.destroy(K)if K.destroyed then return end K.destroyed=true K:
_guardCursor(false)K.ctx.notifications:destroy()for L,M in K.pages do M:destroy(
)end K._resultsPage:destroy()K.ctx.input:destroy()K._maid:clean()K.
visibilityChanged:clear()if K._registry and K._registry.current==K then K.
_registry.current=nil end end function f.new(K)local L=K._registry if L and L.
current then L.current:destroy()end local M=ag.new()local N=d.new(K.theme)local
O=ae.new()local P=ab.service('UserInputService')local Q=K.touch==true or(P.
TouchEnabled and not P.MouseEnabled)local R=ah('ScreenGui',{Name=randomName(),
IgnoreGuiInset=true,ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.
Sibling,DisplayOrder=K.displayOrder or 10000})ab.protect(R)R.Parent=ab.
guiParent()M:add(R)local S=ab.files()local T=K.folder or'sottui_sections'local U
=K.stateFile or(T..'/window.json')local V=nil if S then S.folder(T)local W=S.
read(U)V=W and decode(W)end if type(V)~='table'then V={}end local W=ah('Frame',{
Name='Root',Size=UDim2.fromScale(1,1),Visible=false,Parent=R})local X=tonumber(V
.scale)or(if R.AbsoluteSize.X<800 then 0.8 else 1)local Y=ah('Frame',{Name=
'Layer',Size=UDim2.fromScale(1,1),ZIndex=100,Parent=R})local Z=ah('TextButton',{
Name='Modal',Size=UDim2.fromOffset(0,0),Modal=true,Visible=false,Parent=W})local
_=ah('Frame',{Name='Assembly',Size=UDim2.fromOffset(0,0),ZIndex=3,Parent=W})
local ap=ah('UIScale',{Scale=X,Parent=_})local aq=ah('ImageLabel',{Name='Shadow'
,Position=UDim2.fromOffset(-o,-o),Size=UDim2.new(1,2*o,1,2*o),
BackgroundTransparency=1,BorderSizePixel=0,ImageColor3=Color3.new(0,0,0),
ImageTransparency=1,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(48,48,80
,80),ZIndex=1,Parent=_})local ar=ah('Frame',{Name='Box',Size=UDim2.fromScale(1,1
),BackgroundTransparency=0,ClipsDescendants=true,Active=true,ZIndex=2,Parent=_})
ah('UICorner',{CornerRadius=UDim.new(0,m),Parent=ar})N:paint(ar,
'BackgroundColor3','base')local as=ah('UIStroke',{ApplyStrokeMode=Enum.
ApplyStrokeMode.Border,Thickness=1,Parent=ar})N:paint(as,'Color','line')local at
=ah('Frame',{Name='Top',Size=UDim2.new(1,0,0,l),Active=true,ZIndex=3,Parent=ar})
local au=ah('Frame',{AnchorPoint=Vector2.new(0,1),Position=UDim2.fromScale(0,1),
Size=UDim2.new(1,0,0,1),BackgroundTransparency=0,ZIndex=3,Parent=at})N:paint(au,
'BackgroundColor3','line')local av=ah('Frame',{Name='Row',Size=UDim2.fromScale(1
,1),ZIndex=3,Parent=at})local aw=ah('UIListLayout',{FillDirection=Enum.
FillDirection.Horizontal,VerticalAlignment=Enum.VerticalAlignment.Center,
SortOrder=Enum.SortOrder.LayoutOrder,Parent=av})local ax=K.title or'sottoro'
local ay=math.ceil(ai.width('display',ax,u))+2*v-8 local az=ah('TextLabel',{Name
='Mark',Size=UDim2.new(0,ay,1,0),TextSize=u,Text=ax,LayoutOrder=1,ZIndex=3,
Parent=av})ah('UIPadding',{PaddingLeft=UDim.new(0,v),Parent=az})N:type(az,
'display')N:paint(az,'TextColor3','accent')local aA=ah('Frame',{Name='Right',
AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-B,0,0),Size=UDim2.new(0,w+A+6
,1,0),ZIndex=3,Parent=at})local aB=ah('Frame',{Name='Field',AnchorPoint=Vector2.
new(0,0.5),Position=UDim2.fromScale(0,0.5),Size=UDim2.fromOffset(w,x),
BackgroundTransparency=0,ZIndex=3,Parent=aA})ah('UICorner',{CornerRadius=UDim.
new(0,8),Parent=aB})N:paint(aB,'BackgroundColor3','raised')local aC=ah(
'UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,Transparency
=1,Parent=aB})N:paint(aC,'Color','accent')local aD=ah('TextBox',{Name='Search',
Position=UDim2.fromOffset(12,0),Size=UDim2.new(1,-24,1,0),TextSize=14,Text='',
PlaceholderText='Search',ClearTextOnFocus=false,ClipsDescendants=true,ZIndex=4,
Parent=aB})N:type(aD,'text')N:paint(aD,'TextColor3','text')N:paint(aD,
'PlaceholderColor3','muted')local aE=ah('Frame',{Name='Marker',Size=UDim2.
fromOffset(0,C),BackgroundTransparency=0,ZIndex=4,Parent=at})ah('UICorner',{
CornerRadius=UDim.new(1,0),Parent=aE})N:paint(aE,'BackgroundColor3','accent')
local aF=ah('Frame',{Name='Body',Position=UDim2.fromOffset(0,l),Size=UDim2.new(1
,0,0,k-l),ClipsDescendants=true,ZIndex=2,Parent=ar})local aG=setmetatable({ctx=
nil,pages={},elements={},ordered={},isOpen=false,destroyed=false,
visibilityChanged=c.new(),_maid=M,_gui=R,_root=W,_layer=Y,_modal=Z,_scale=ap,
_box=aD,_field=aB,_right=aA,_rowLayout=aw,_body=aF,_top=at,_row=av,_tabs={},_at=
if tonumber(V.boxX)and tonumber(V.boxY)then Vector2.new(V.boxX,V.boxY)else nil,
_savedPage=V.page,_files=S,_stateFile=U,_dialogIds=0,_registry=L},J)if L then L.
current=aG end local aH={ready={},waiting={}}local aI={theme=N,input=O,touch=Q,
glyph=ad.new(N),tint=e.new(N),art=function(aI,aJ)local aK=aH.ready[aJ]if aK then
aI.Image=aK return end aH.waiting[aJ]=aH.waiting[aJ]or{}table.insert(aH.waiting[
aJ],aI)end,uiScale=function()return ap.Scale end,popoverTop=function()return 8
end,isShowing=function(aI)if not aG.isOpen then return false end if aI._page==
nil and aI._shownOn==nil then return true end return aG._showing~=nil and(aI.
_shownOn==aG._showing or aI._page==aG._showing)end,setScrollLocked=function(aI)
local aJ=aG._showing if aJ and aJ.frame and Q then aJ.frame.ScrollingEnabled=not
aI end end}aG.ctx=aI aI.art(aq,'shadow.png')local aJ=al.popover(aI,Y)aI.popover=
aJ aI.tooltip=al.tooltip(aI,Y)aI.hover=al.hover(aI)aI.notifications=ak.new(aI,Y)
aI.notify=function(aK)aI.notifications:show(aK)end aG.keys=af.new(O,ab,function(
)return aG.isOpen end)aI.keys=aG.keys aG._position=M:add(aj.prop(_,'Position',E)
)aG._size=M:add(aj.prop(_,'Size',D))aG._shadowFade=M:add(aj.prop(aq,
'ImageTransparency',E))aG._markerAt=M:add(aj.prop(aE,'Position',F))aG.
_markerSize=M:add(aj.prop(aE,'Size',F))aG:_fit()aG._resultsPage=am.new(aG,
'Results')aG._resultsPage:mount(aF)local aK=ah('TextButton',{Name='Close',
AnchorPoint=Vector2.new(1,0.5),Position=UDim2.fromScale(1,0.5),Size=UDim2.
fromOffset(A,A),BackgroundTransparency=1,ZIndex=4,Parent=aA})ah('UICorner',{
CornerRadius=UDim.new(0,8),Parent=aK})N:paint(aK,'BackgroundColor3','raised')
local aL=aI.glyph.cross(aK,'muted')aL.AnchorPoint=Vector2.new(0.5,0.5)aL.
Position=UDim2.fromScale(0.5,0.5)aL.ZIndex=5 local aM=M:add(aj.prop(aK,
'BackgroundTransparency',F))aK.MouseEnter:Connect(function()aM:to(0)aI.tooltip:
schedule(aK,'Close menu')end)aK.MouseLeave:Connect(function()aM:to(1)aI.tooltip:
hide()end)aK.Activated:Connect(function()aG:setOpen(false)end)local aN=M:add(aj.
prop(aC,'Transparency',F))aD.Focused:Connect(function()aN:to(0.2)end)aD.
FocusLost:Connect(function()aN:to(1)end)aD:GetPropertyChangedSignal('Text'):
Connect(function()aG:_query(aD.Text)end)at.InputBegan:Connect(function(aO)local
aP=aO.UserInputType if aP~=Enum.UserInputType.MouseButton1 and aP~=Enum.
UserInputType.Touch then return end local aQ=if aP==Enum.UserInputType.Touch
then O:at(aO)else O:pointer()local aR=aG._at if aR==nil then return end O:
capture(function(aS)aG._at=aG:_clamped(aR+(aS-aQ))aG._position:snap(UDim2.
fromOffset(aG._at.X,aG._at.Y))end,function()aG:_saveState()end,if aP==Enum.
UserInputType.Touch then aO else nil)end)aw:GetPropertyChangedSignal(
'AbsoluteContentSize'):Connect(function()task.defer(function()if not aG.
destroyed then aG:_fitBar()aG:_syncMarker(true)end end)end)M:add(R:
GetPropertyChangedSignal('AbsoluteSize'):Connect(function()aG:_fit()aG:
_keepOnScreen(false)end))O.moved:connect(function(aO)aI.hover:verify(aO)end)O.
wheel:connect(function(aO)if not aG.isOpen or aI.popover:isOpen()or aG.
_dialogClose then return end local aP=aG._showing if aP==nil or aP.frame==nil
then return end local aQ=O:pointer()local aR,aS=aP.frame.AbsolutePosition,aP.
frame.AbsoluteSize if aQ.X>=aR.X and aQ.Y>=aR.Y and aQ.X<=aR.X+aS.X and aQ.Y<=aR
.Y+aS.Y then aP:wheel(aO)end end)O.keyDown:connect(function(aO,aP)if aO.
UserInputType~=Enum.UserInputType.Keyboard then return end local aQ=aO.KeyCode.
Name if aG.keys:swallowed(aQ)then return end if aI.popover:key(aQ)then return
end if aQ=='Escape'and aG._dialogClose then aG._dialogClose()return end if aQ==
'Escape'and aD.Text~=''then aD.Text=''return end if aP or O:typing()then return
end if aG.isOpen and aQ=='K'then if P:IsKeyDown(Enum.KeyCode.LeftControl)or P:
IsKeyDown(Enum.KeyCode.RightControl)then aD:CaptureFocus()end end end)M:add(N.
changed:connect(function()local aO=table.clone(aG.pages)table.insert(aO,aG.
_resultsPage)for aP,aQ in aO do for aR,aS in aQ._views do pcall(function()if aS.
retint then aS:retint()end aS.refresh()end)end end end))local aO=ao.new({window=
aG,nextId=function()return 0 end,_register=function(aO,aP,aQ)if aQ then aG.
elements[aP.id]=aP end aP._pageName=''end,_invalidate=function()end},'')aG.
menuKey=aO:key('__menu',{label='Menu',default=K.key or'RightShift',mode='Toggle'
,saved=false,onPress=function()aG:toggle()end})local aP=ab.service('RunService')
aj.setAttach(function(aQ)return aP.PreRender:Connect(aQ)end)if K.fonts~=false
and S then M:add(task.defer(function()local aQ=K.fontTag or g local aR=string.
format(h,aQ)local aS=T..'/fonts-'..aQ local aT=ac.load(aS,aR,encode)if aG.
destroyed then return end if aT.text or aT.display then N:setFonts(aT.text,aT.
display)end for aU,aV in i do local aW=ac.image(aS,aR,aV)if aG.destroyed then
return end if aW then aH.ready[aV]=aW local aX=aH.waiting[aV]or{}for aY,aZ in aX
do aZ.Image=aW end end aH.waiting[aV]=nil end end))end if Q then aG._opener=b(R,
N,function()aG:setOpen(true)end)end if K.autoShow~=false then task.defer(
function()aG:setOpen(true)end)end return aG end function f.setVersion(ap)g=ap
end return f end function a.C()local aa=a.cache.C if not aa then aa={c=
__modImpl()}a.cache.C=aa end return aa.c end end end local aa=a.a()local ab=a.b(
)local ac=a.e()local ad=a.C()local ae='0.6.7-sections'local function registry()
local af=aa.global('getgenv')local ag=if type(af)=='function'then af()else _G
local ah=ag.__sottui if type(ah)~='table'then ah={current=nil}ag.__sottui=ah end
return ah end local af={version=ae,motion=ab}ad.setVersion('v'..ae)function af.
window(ag)local ah=table.clone(ag or{})ah._registry=registry()return ad.new(ah)
end function af.current()return registry().current end function af.obsidian()
return ac.new(af)end return af