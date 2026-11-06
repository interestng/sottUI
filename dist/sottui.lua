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
SetMax(o,p)o.Max=p o._el.spec.max=p o._el:set(o._el.value)o._el:setLabel(o.Text)
end function h.SetMin(o,p)o.Min=p o._el.spec.min=p o._el:set(o._el.value)o._el:
setLabel(o.Text)end function i.SetValue(o,p)if not o._el:set(p)then o:
RunChanged()end end function j.SetValue(o,p)if type(p)=='string'and o.
SpecialType=='Player'then local q=b.service('Players'):FindFirstChild(p)p=q end
if not o._el:set(p)then o:RunChanged()end end function j.SetValues(o,p)o._el:
setOptions(p)o.Values=o._el.spec.options end function j.AddValues(o,p)local q=
table.clone(o._el.spec.options)if type(p)=='table'then for r,s in p do table.
insert(q,s)end else table.insert(q,p)end o:SetValues(q)end function j.
GetActiveValues(o)if o.Multi then local p={}for q,r in o.Value do if r then
table.insert(p,q)end end return p end return if o.Value then 1 else 0 end
function k.SetValueRGB(o,p,q)local r=if o._hasAlpha then q or 0 else 0 if not o.
_el:set({color=p,alpha=r})then o:RunChanged(o.Value)end end function k.SetValue(
o,p,q)if typeof(p)=='Color3'then o:SetValueRGB(p,q)elseif type(p)=='table'then o
:SetValueRGB(Color3.fromHSV(p[1],p[2],p[3]),q)end end function l.SetValue(o,p)if
type(p)=='string'then p={p}end o._el:set({key=p[1],mode=p[2],modifiers=p[3]or{}}
)end function l.GetState(o)return o._lib.window.keys:state(o._el)end function l.
OnClick(o,p)o.Clicked=p end function m.SetText(o,p)o.Text=p o._el:setLabel(p)end
function n.SetText(o,p)o.Text=p o._el:setLabel(p)end local o={}o.__index=o local 
function register(p,q,r,s)p[q][r]=s s._idx=r if p._dialogIndexes then table.
insert(p._dialogIndexes,{shelf=q,idx=r})end return s end local function common(p
,q,r,s)return{Type=q,Text=s.Text,Disabled=s.Disabled==true,Visible=s.Visible~=
false,Tooltip=s.Tooltip,Callback=s.Callback,Changed=s.Changed,_el=r,_lib=p}end
local function tips(p,q)q.tip=p.Tooltip q.disabled=p.Disabled==true q.
disabledTip=p.DisabledTooltip q.visible=p.Visible~=false return q end function o
.AddToggle(p,q,r)local s=p._section local t=tips(r,{label=r.Text or q,default=r.
Default==true})local u=#s.rows==0 and s._root==nil and s.title~=''local v if u
and(r.Text=='Enabled'or r.Text==s.title)then t.label=s.title v=s:master(q,t)else
v=s:toggle(q,t)end local w=(setmetatable(common(p._lib,'Toggle',v,r),g))w.Value=
v.value w._pickers={}w._box=p sync(w,function(x)for y,z in w._pickers do z._el.
toggled=x.value z.Toggled=x.value end return x.value end,true)return register(p.
_lib,'Toggles',q,w)end o.AddCheckbox=o.AddToggle function o.AddSlider(p,q,r)
local s=tonumber(r.Rounding)or 0 local t=r.FormatDisplayValue local u local v=
tips(r,{label=r.Text or q,min=r.Min,max=r.Max,step=10^-s,decimals=s,suffix=r.
Suffix,default=r.Default,format=if t then function(v,w)return t(u,w)end else nil
})local w=p._section:slider(q,v)u=setmetatable(common(p._lib,'Slider',w,r),h)u.
Value=w.value u.Min,u.Max,u.Rounding=r.Min,r.Max,s sync(u,function(x)return x.
value end)return register(p._lib,'Options',q,u)end function o.AddInput(p,q,r)
local s=p._section:input(q,tips(r,{label=r.Text or'',default=r.Default or'',
placeholder=r.Placeholder,numeric=r.Numeric==true,finished=r.Finished==true or r
.VerifyValue~=nil,maxLength=r.MaxLength,verify=r.VerifyValue}))local t=(
setmetatable(common(p._lib,'Input',s,r),i))t.Value=s.value t.Numeric=r.Numeric==
true sync(t,function(u)return u.value end)return register(p._lib,'Options',q,t)
end local function playerList(p)local q=b.service('Players')local r={}for s,t in
q:GetPlayers()do if not(p and t==q.LocalPlayer)then table.insert(r,t)end end
return r end function o.AddDropdown(p,q,r)local s=r.SpecialType=='Player'local t
=if s then playerList(r.ExcludeLocalPlayer==true)else(r.Values or{})local u=r.
Multi==true local v=r.Default if type(v)=='number'then v=t[v]end if u and type(v
)=='string'then v={v}end local w=r.FormatDisplayValue local x=p._section:
dropdown(q,tips(r,{label=r.Text or q,options=t,multi=u,default=v,searchable=r.
Searchable==true,allowNull=r.AllowNull==true or s,display=function(x)local y=if
s then x.Name else x if w then local z,A=pcall(w,y)if z and A~=nil then return
tostring(A)end end return tostring(y)end}))local y=(setmetatable(common(p._lib,
'Dropdown',x,r),j))y.Value=x.value y.Values=x.spec.options y.Multi=u y.
SpecialType=r.SpecialType sync(y,function(z)return z.value end,true)if s then
local z=b.service('Players')local function refresh()y:SetValues(playerList(r.
ExcludeLocalPlayer==true))end table.insert(p._lib._connections,z.PlayerAdded:
Connect(refresh))table.insert(p._lib._connections,z.PlayerRemoving:Connect(
function()task.defer(refresh)end))end return register(p._lib,'Options',q,y)end
function o.AddButton(p,q,r)local s=if type(q)=='table'then q else{Text=q,Func=r}
local t=p._section:button(s.Text or'',tips(s,{confirm=s.DoubleClick==true,danger
=s.Risky==true}))local u=(setmetatable(common(p._lib,'Button',t,s),n))u.Func=s.
Func t:on(function()protect(u.Func)end)return u end local function buildLabel(p,
q,r)local s=if type(q)=='table'then q else{Text=q,DoesWrap=r}local t=p._section:
label(tostring(s.Text or''),{wrap=s.DoesWrap==true or r==true})local u=(
setmetatable(common(p._lib,'Label',t,s),m))u.TextLabel={}u._box=p return u end
function o.AddLabel(p,q,r)if type(r)=='table'then local s=buildLabel(p,r)
register(p._lib,'Options',q,s)return s end return buildLabel(p,q,r)end function
o.AddStat(p,q,r)local s=p._section:stat(q,r)return{SetValue=function(t,u)s:set(u
)end}end function o.AddDivider(p,q)local r=if type(q)=='table'then q.Text else q
p._section:divider(r)end function o.AddBlank()end function o.AddDependencyBox(p)
local q={}local r=p._lib p._section._page._guarded=true local s=p._section._root
or p._section local t=p._section:when(function()for t,u in q do local v,w=u[1],u
[2]if v._el==s.masterElement and w==true then continue end if v.Disabled then
return false end local x=v.Value if v.Type=='Dropdown'and type(x)=='table'then
if not x[w]then return false end elseif x~=w then return false end end return
true end)local u=(setmetatable({_section=t,_lib=r},o))function u.
SetupDependencies(v,w)q=w p._section._page:_invalidate()end return u end
function o.SetCollapsed()end local function attachColor(p,q,r,s)local t=s.
Transparency~=nil local u=q._box._section local v=u:addColor(q._el,r,{label=s.
Title or q.Text or r,default=s.Default or Color3.new(1,1,1),alpha=t,alphaValue=
if t then s.Transparency else 0})local w=(setmetatable(common(p,'ColorPicker',v,
s),k))w.Value=v.value.color w.Transparency=v.value.alpha w._hasAlpha=t v:on(
function()w.Value=v.value.color w.Transparency=v.value.alpha w:RunChanged(w.
Value)end)return register(p,'Options',r,w)end local function keyArgument(p)local
q=({MB1='MouseButton1',MB2='MouseButton2',MB3='MouseButton3'})[p]if q then
return(Enum.UserInputType)[q]end local r,s=pcall(function()return(Enum.KeyCode)[
p]end)return if r then s else nil end local function attachKey(p,q,r,s)local t=q
._box._section local u=s.SyncToggleState==true local v=if u then{'Toggle','Hold'
}else s.Modes or{'Always','Toggle','Hold'}local w=s.Mode or'Toggle'local x local
y=t:addKey(q._el,r,{label=q._el.label or s.Text or r,default=s.Default or'None',
mode=w,modes=v,modifiers=s.DefaultModifiers or{},chipless=s.NoUI==true,noMouse=
false,onPress=function(y,z)if p.ToggleKeybind==x then p.window:toggle()return
end if q.Type=='Toggle'and q.Disabled then y.toggled=q.Value return end x.
Toggled=z local A=y.value.mode if u and q.Type=='Toggle'then if A=='Toggle'then
q:SetValue(z)elseif A=='Hold'then q:SetValue(true)end end if A=='Toggle'or A==
'Press'then protect(x.Clicked,z)protect(x.Callback,z)end end,onRelease=function(
y)if u and q.Type=='Toggle'and y.value.mode=='Hold'and not q.Disabled then q:
SetValue(false)end end})x=setmetatable(common(p,'KeyPicker',y,s),l)x.Value=y.
value.key x.Mode=y.value.mode x.Modifiers=y.value.modifiers x.Modes=v x.
SyncToggleState=u x.NoUI=s.NoUI==true x.Toggled=false x.ChangedCallback=s.
ChangedCallback y:on(function()local z=y.value x.Value=z.key x.Mode=z.mode x.
Modifiers=z.modifiers x:Update()local A=keyArgument(z.key)protect(x.
ChangedCallback,A,z.modifiers)protect(x.Changed,A,z.modifiers)end)if q.Type==
'Toggle'and u then table.insert(q._pickers,x)y.toggled=q.Value end return
register(p,'Options',r,x)end function g.AddColorPicker(p,q,r)attachColor(p._lib,
p,q,r)return p end function g.AddKeyPicker(p,q,r)attachKey(p._lib,p,q,r)return p
end m.AddColorPicker=g.AddColorPicker m.AddKeyPicker=g.AddKeyPicker local p={}p.
__index=p local function makeBox(q,r)return setmetatable({_section=r,_lib=q},o)
end local function sectionBox(q,r)local s=q._page:section(r)local t=makeBox(q.
_lib,s)return t end function p.AddLeftGroupbox(q,r)return sectionBox(q,r)end p.
AddRightGroupbox=p.AddLeftGroupbox function p.AddGroupbox(q,r)return sectionBox(
q,r.Name)end local function tabbox(q)local r=q._page:tabset()local s=q._lib
return{AddTab=function(t,u)return makeBox(s,r:tab(u))end}end p.AddLeftTabbox=
tabbox p.AddRightTabbox=tabbox local q={}q.__index=q function q.AddTab(r,s,t)
local u=if type(s)=='table'then s.Name else s local v=r._lib.window:page(u)if u
=='Home'then local w=b.service('Players').LocalPlayer if w then r._lib.Hero=v:
hero({userId=w.UserId,title=w.DisplayName,text=r._footer})end end local w=
setmetatable({_page=v,_lib=r._lib},p)r._lib.Tabs[u]=w return w end function q.
OpenDialog(r,s,t)local u=r._lib local v=u.window local w=u._dialogIndexes return
v:dialog({title=s.title,text=s.description,done=s.done,maxHeight=s.maxHeight,
onClose=function()local x=u._dialogOwned for y,z in x or{}do u[z.shelf][z.idx]=
nil end u._dialogOwned=nil if s.onClose then s.onClose()end end},function(x)u.
_dialogIndexes={}t(makeBox(u,x))u._dialogOwned=u._dialogIndexes u._dialogIndexes
=w end)end function e.new(r)local s=false local t=setmetatable({Toggles={},
Options={},Tabs={},Toggled=false,ScreenGui=nil,Scheme={AccentColor=Color3.
fromHex('7EE0C4'),BackgroundColor=Color3.fromHex('07100D'),MainColor=Color3.
fromHex('141C18'),OutlineColor=Color3.fromHex('1A2D27'),FontColor=Color3.
fromHex('EBE8DA')},ShowToggleFrameInKeybinds=true,IsSottUI=true,_connections={},
_unloads={}},{})function t._rulesChanged(u)if s or u.window==nil then return end
s=true task.defer(function()s=false if u.window==nil or u.window.destroyed then
return end for v,w in u.window.pages do if w._guarded then w:_invalidate()end
end end)end function t.CreateWindow(u,v)local w=r.window({title=v.Title,subtitle
=v.Footer,folder=v.Folder,stateFile=v.StateFile,autoShow=v.AutoShow~=false})u.
window=w u.ScreenGui=w._gui u.Toggled=v.AutoShow~=false w.visibilityChanged:
connect(function(x)u.Toggled=x end)local x=setmetatable({_lib=u,_footer=v.Footer
},q)u.Window=x return x end function t.Notify(u,v,w)if u.window==nil then return
end if type(v)=='table'then u.window:notify({title=v.Title,text=v.Description,
seconds=v.Time or w})else u.window:notify({text=tostring(v),seconds=w})end end
function t.Toggle(u,v)if u.window then if v==nil then u.window:toggle()else u.
window:setOpen(v)end end end function t.SafeCallback(u,v,...)protect(v,...)end
function t.OnUnload(u,v)table.insert(u._unloads,v)end function t.Unload(u)for v,
w in u._unloads do protect(w)end for v,w in u._connections do w:Disconnect()end
u._connections={}if u.window then u.window:destroy()u.window=nil end u.ScreenGui
=nil u.Toggled=false end getmetatable(t).__newindex=function(u,v,w)rawset(u,v,w)
if v=='ToggleKeybind'and u.window and u.window.menuKey then u.window.keys:
unregister(u.window.menuKey)end end return{Library=t,SaveManager=c.new(t),
ThemeManager=d.new(t)}end return e end function a.e()local b=a.cache.e if not b
then b={c=__modImpl()}a.cache.e=b end return b.c end end do local function 
__modImpl()local b={Frame={BackgroundTransparency=1,BorderSizePixel=0},TextLabel
={BackgroundTransparency=1,BorderSizePixel=0,TextXAlignment=Enum.TextXAlignment.
Left},TextButton={BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=
false,Text=''},TextBox={BackgroundTransparency=1,BorderSizePixel=0,
ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left},ScrollingFrame={
BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,CanvasSize=UDim2
.new(),ScrollingDirection=Enum.ScrollingDirection.Y}}local function make(c,d,e)
local f=Instance.new(c)local g=b[c]if g then for h,i in g do f[h]=i end end
local h=nil if d then for i,j in d do if i=='Parent'then h=j else f[i]=j end end
end if e then for i,j in e do j.Parent=f end end if h then f.Parent=h end return
f end return make end function a.f()local b=a.cache.f if not b then b={c=
__modImpl()}a.cache.f=b end return b.c end end do local function __modImpl()
local b=a.f()local c={}local d=256 local e=148 local f=14 local g=10 local h=12
local i=(function()local i={}for j=0,6 do table.insert(i,ColorSequenceKeypoint.
new(j/6,Color3.fromHSV((j/6)%1,1,1)))end return ColorSequence.new(i)end)()local 
function hex(j)return string.format('%02X%02X%02X',math.round(j.R*255),math.
round(j.G*255),math.round(j.B*255))end local function parseHex(j)local k=string.
gsub(j,'#','')if not string.match(k,'^%x%x%x%x%x%x$')then return nil end return
Color3.fromRGB((tonumber(string.sub(k,1,2),16)),(tonumber(string.sub(k,3,4),16))
,(tonumber(string.sub(k,5,6),16)))end c.hex=hex c.parseHex=parseHex local 
function open(j,k,l)local m=j.theme local n=k.spec.alpha==true local o=h+e+g+f+(
if n then g+f else 0)+g+28+h j.popover:open(l,d,o,function(p,q)local r=k.value
local s,t,u=r.color:ToHSV()local v=r.alpha local w=b('TextButton',{Position=
UDim2.fromOffset(h,h),Size=UDim2.new(1,-2*h,0,e),BackgroundTransparency=0,Parent
=p})b('UIGradient',{Transparency=NumberSequence.new(0,1),Color=ColorSequence.
new(Color3.new(1,1,1)),Parent=b('Frame',{Size=UDim2.fromScale(1,1),
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
Position=UDim2.fromOffset(h+54,z),Size=UDim2.new(1,-(2*h+54),0,28),TextSize=18,
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
ToHSV()end v=G.alpha draw()end)draw()end)end c.DOT_SPACE=28 local j=12 function
c.swatch(k,l)local m=b('TextButton',{Name='Swatch',Size=UDim2.new(0,c.DOT_SPACE,
1,0),ZIndex=4})local n=b('Frame',{AnchorPoint=Vector2.new(0.5,0.5),Position=
UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(j,j),BackgroundTransparency=0,
ZIndex=4,Parent=m})b('UICorner',{CornerRadius=UDim.new(1,0),Parent=n})local o={
root=m,width=c.DOT_SPACE}o.refresh=function()n.BackgroundColor3=l.value.color n.
BackgroundTransparency=l.value.alpha*0.8 end o.refresh()o.open=function()if not
l.disabled then open(k,l,m)end end m.Activated:Connect(o.open)o.setInk=function(
)end o.destroy=function()m:Destroy()end return o end return c end function a.g()
local b=a.cache.g if not b then b={c=__modImpl()}a.cache.g=b end return b.c end
end do local function __modImpl()local b={}local function isStart(c,d)if d==1
then return true end local e=string.sub(c,d-1,d-1)return e==' 'or e=='/'or e==
'-'or e=='_'end function b.score(c,d)if c==''then return 0 end local e=string.
lower(d)local f=string.lower(c)local g=string.find(e,f,1,true)if g then return
1000-#e+(if isStart(e,g)then 500 else 0)end local h,i,j=0,1,-1 for k=1,#f do
local l=string.sub(f,k,k)if l~=' 'then local m=string.find(e,l,i,true)if m==nil
then return nil end h+=if isStart(e,m)then 12 elseif m==j+1 then 8 else 1 h-=
math.min(m-i,6)j=m i=m+1 end end return h end function b.setting(c,d)local e=b.
score(c,d.label)if e then return e+100 end local f=string.lower(c)local g=d.
section and d.section.title or''local h=string.lower((d._pageName or'')..' '..g)
return if string.find(h,f,1,true)then 1 else nil end function b.settings(c,d,e)
local f={}for g,h in d do local i=b.setting(c,h)if i then table.insert(f,{item=h
,score=i})end end table.sort(f,function(g,h)return g.score>h.score end)local g,h
={},{}for i,j in f do local k=j.item.host or j.item if not h[k]then h[k]=true
table.insert(g,k)if#g==e then break end end end return g end function b.rank(c,d
,e,f)local g={}for h,i in d do local j=b.score(c,e(i))if j then table.insert(g,{
item=i,score=j})end end table.sort(g,function(h,i)return h.score>i.score end)
local h={}for i=1,math.min(f,#g)do h[i]=g[i].item end return h end return b end
function a.h()local b=a.cache.h if not b then b={c=__modImpl()}a.cache.h=b end
return b.c end end do local function __modImpl()local b=a.f()local c=a.h()local
d={}local e=38 local f=8 local g=9 local h=46 local i=38 local j=260 local k=17
local function isPicked(l,m)if l.spec.multi then return l.value[m]==true end
return l.value==m end function d.open(l,m,n)local o=m.spec local p=l.theme local
q=o.display or tostring local r=o.searchable==true or#o.options>=g local s=o.
multi==true local t=(if r then h else 0)+(if s then i else 0)local u=o.options
local v=0 local w=''local function ordered(x)if not o.multi then return x end
local y,z={},{}for A,B in x do table.insert(if m.value[B]then y else z,B)end
table.move(z,1,#z,#y+1,y)return y end u=ordered(u)local function bodyHeight()
return math.clamp(#u,1,f)*e+8 end local x=math.max(n.AbsoluteSize.X,j)l.popover:
open(n,x,bodyHeight()+t,function(y,z)local A=b('ScrollingFrame',{Position=UDim2.
fromOffset(0,t),Size=UDim2.new(1,0,1,-t),ScrollBarThickness=3,Parent=y})p:paint(
A,'ScrollBarImageColor3','lineStrong')local B=b('Frame',{Size=UDim2.fromScale(1,
1),Parent=A})local C={}local D=f+2 local E=b('TextLabel',{Position=UDim2.
fromOffset(34,t+4),Size=UDim2.new(1,-52,0,e),TextSize=k,Text='Nothing matches',
Visible=false,Parent=y})p:type(E,'text')p:paint(E,'TextColor3','faint')local 
function draw()local F=math.floor(A.CanvasPosition.Y/e)+1 for G=1,D do local H=C
[G]local I=F+G-1 local J=u[I]if J==nil then H.root.Visible=false else H.index=I
H.option=J H.root.Visible=true H.root.Position=UDim2.new(0,0,0,(I-1)*e+4)H.text.
Text=q(J)local K=isPicked(m,J)p:paint(H.text,'TextColor3',if K then'text'else
'muted')H.mark.Visible=K H.root.BackgroundTransparency=if I==v then 0.4 else 1
end end end local function refit()A.CanvasSize=UDim2.fromOffset(0,#u*e+8)E.
Visible=#u==0 z.resize(bodyHeight()+t)draw()end local function refilter()local F
=o.options if w~=''then F=c.rank(w,F,q,500)end u=ordered(F)refit()end local F=
nil local function choose(G)if o.multi then local H=table.clone(m.value)H[G]=if
H[G]then nil else true m:set(H)if F and F.Text~=''then F.Text=''else refilter()
end if F and not l.touch then F:CaptureFocus()end return end if m.value==G then
if o.allowNull then m:set(nil)end else m:set(G)end z.close()end for G=1,D do
local H=b('TextButton',{Size=UDim2.new(1,0,0,e-2),BackgroundTransparency=1,
Visible=false,Parent=B})local I=b('TextLabel',{Position=UDim2.fromOffset(34,0),
Size=UDim2.new(1,-52,1,0),TextSize=k,TextTruncate=Enum.TextTruncate.AtEnd,Parent
=H})p:type(I,'text',true)p:paint(H,'BackgroundColor3','raised')local J=b('Frame'
,{Position=UDim2.fromScale(0,0),Size=UDim2.new(0,3,1,0),BackgroundTransparency=0
,Visible=false,Parent=H})p:paint(J,'BackgroundColor3','accent')local K={root=H,
text=I,mark=J,index=0,option=nil}C[G]=K H.MouseEnter:Connect(function()v=K.index
draw()end)H.MouseLeave:Connect(function()if v==K.index then v=0 draw()end end)H.
Activated:Connect(function()if K.option~=nil then choose(K.option)end end)end A:
GetPropertyChangedSignal('CanvasPosition'):Connect(draw)local G=0 if r then F=b(
'TextBox',{Position=UDim2.fromOffset(34,0),Size=UDim2.new(1,-52,0,h),TextSize=k+
1,Text='',PlaceholderText='Search',Parent=y})p:type(F,'text',true)p:paint(F,
'TextColor3','text')p:paint(F,'PlaceholderColor3','faint')local H=b('Frame',{
Position=UDim2.fromOffset(0,h-1),Size=UDim2.new(1,0,0,1),BackgroundTransparency=
0,Parent=y})p:paint(H,'BackgroundColor3','lineStrong')F:
GetPropertyChangedSignal('Text'):Connect(function()w=F.Text v=if w~=''then 1
else 0 A.CanvasPosition=Vector2.zero refilter()end)G=h end if s then local H=b(
'TextButton',{Position=UDim2.fromOffset(0,G),Size=UDim2.new(1,0,0,i),TextSize=k,
Text='Clear all',TextXAlignment=Enum.TextXAlignment.Left,Parent=y})b('UIPadding'
,{PaddingLeft=UDim.new(0,34),Parent=H})p:type(H,'text',true)p:paint(H,
'TextColor3','muted')H.MouseEnter:Connect(function()p:paint(H,'TextColor3',
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
end do local function __modImpl()local b={}local c={display={0.304,0.358,0.522,
0.757,0.71,1.132,1.001,0.278,0.371,0.371,0.431,0.736,0.349,0.416,0.349,0.308,
0.786,0.703,0.783,0.789,0.781,0.789,0.791,0.726,0.803,0.791,0.344,0.349,0.736,
0.736,0.736,0.715,1.253,0.933,0.914,0.942,0.933,0.863,0.799,1.012,0.989,0.373,
0.734,0.951,0.754,1.148,0.988,1.013,0.861,1.013,0.932,0.867,0.848,0.968,0.904,
1.213,0.94,0.918,0.857,0.36,0.308,0.36,0.736,0.655,0.319,0.776,0.765,0.771,0.765
,0.78,0.482,0.766,0.755,0.315,0.313,0.733,0.315,1.166,0.755,0.781,0.765,0.765,
0.48,0.71,0.501,0.755,0.706,1.078,0.764,0.706,0.66,0.363,0.293,0.363,0.736},text
={0.254,0.24,0.353,0.654,0.564,0.85,0.686,0.199,0.309,0.309,0.443,0.635,0.265,
0.488,0.28,0.444,0.611,0.343,0.572,0.576,0.584,0.58,0.595,0.531,0.579,0.594,0.28
,0.268,0.635,0.635,0.635,0.529,0.885,0.7,0.645,0.703,0.697,0.585,0.561,0.718,
0.72,0.354,0.536,0.66,0.545,0.868,0.729,0.77,0.615,0.77,0.633,0.613,0.644,0.673,
0.678,0.935,0.652,0.623,0.595,0.31,0.444,0.31,0.635,0.5,0.5,0.551,0.589,0.551,
0.589,0.573,0.341,0.555,0.567,0.242,0.272,0.552,0.262,0.873,0.581,0.597,0.59,
0.59,0.401,0.513,0.34,0.581,0.554,0.812,0.559,0.548,0.504,0.327,0.239,0.327,
0.635},textMedium={0.242,0.251,0.366,0.672,0.574,0.867,0.688,0.205,0.319,0.319,
0.433,0.635,0.272,0.481,0.287,0.454,0.617,0.36,0.579,0.583,0.596,0.59,0.601,
0.541,0.588,0.6,0.287,0.276,0.635,0.635,0.635,0.539,0.895,0.71,0.654,0.707,0.708
,0.591,0.567,0.721,0.729,0.373,0.55,0.678,0.555,0.886,0.739,0.769,0.63,0.769,
0.648,0.623,0.656,0.685,0.688,0.955,0.675,0.633,0.606,0.324,0.454,0.324,0.635,
0.5,0.5,0.563,0.6,0.56,0.6,0.58,0.349,0.562,0.577,0.253,0.28,0.567,0.271,0.883,
0.591,0.601,0.6,0.6,0.417,0.521,0.351,0.591,0.567,0.83,0.572,0.564,0.515,0.336,
0.249,0.336,0.635}}function b.width(d,e,f)local g=c[d]local h=0 for i=1,#e do
local j=(string.byte(e,i))h+=g[j-31]or 0.5 end return h*f end return b end
function a.j()local b=a.cache.j if not b then b={c=__modImpl()}a.cache.j=b end
return b.c end end do local function __modImpl()local b=a.f()local c=a.j()local
d={}local e=30 local f=8 local g=16 local h='Press a key'local function display(
i)local j=i.value if j==nil or j.key=='None'or j.key=='Unknown'then return
'Unset'end local k={}for l,m in j.modifiers or{}do table.insert(k,m)end table.
insert(k,j.key)local l=table.concat(k,'+')return if j.mode and j.mode~='Toggle'
then l..' '..string.lower(j.mode)else l end function d.build(i,j)local k=i.theme
local l=b('TextButton',{Name='Key',Size=UDim2.fromOffset(52,54),
BackgroundTransparency=1})local m=b('Frame',{AnchorPoint=Vector2.new(0.5,0.5),
Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(1,-f,0,e),ZIndex=4,Parent=l})
local n=b('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=m})
local o=b('TextLabel',{Size=UDim2.fromScale(1,1),TextSize=g,TextXAlignment=Enum.
TextXAlignment.Center,ZIndex=5,Parent=m})k:type(o,'text',true)local p={root=l,
width=52}local q=false local r=false local function fit(s)local t=math.ceil(c.
width('textMedium',s,g))+16+f l.Size=UDim2.fromOffset(math.max(t,44),54)p.width=
l.Size.X.Offset if p.onFit then p.onFit()end end local s=false local function 
ink()k:paint(o,'TextColor3',if q then'accent'elseif r then'onAccent'else'muted')
k:paint(n,'Color',if q then'accent'elseif r then'onAccent'else'lineStrong')m.
Visible=q or s or display(j)~='Unset'end p.setHover=function(t)s=t ink()end p.
refresh=function()if q then return end local t=display(j)o.Text=t fit(t)ink()end
p.setInk=function(t)r=t ink()end p.refresh()p.start=function()if j.disabled or q
then return end q=true o.Text=h fit(h)ink()i.keys:listen(function(t,u)q=false if
t~=nil then j:set({key=t,modifiers=u or{}})end p.refresh()end,j.spec.noMouse==
true)end l.Activated:Connect(p.start)l.MouseButton2Click:Connect(function()local
t=j.spec.modes if j.disabled or t==nil or#t<2 then return end local u=table.
find(t,j.value.mode)or 0 local v=t[u%#t+1]j:set({mode=v})i.notify({title=j.label
,text='Key mode: '..v,seconds=2})end)p.destroy=function()if q then i.keys:
cancel()end l:Destroy()end return p end return d end function a.k()local b=a.
cache.k if not b then b={c=__modImpl()}a.cache.k=b end return b.c end end do
local function __modImpl()local b=a.f()local c=a.b()local d={}d.PAD=18 d.HEIGHT=
46 d.NAME=17 local e=0.45 local f=30 local g=5 local h=34 local i=0.62 local j=
26 local k=30 local l=3 local m={}m.__index=m function m.own(n,o)table.insert(n.
_cleanups,function()o:destroy()end)return o end function m.onCleanup(n,o)table.
insert(n._cleanups,o)end function m.onHover(n,o)local p=o and not n.el.disabled
if n._hover==p then return end n._hover=p for q,r in n.chips do if r.setHover
then r.setHover(p)end end if n._wash==nil then n._wash=n:own(c.prop(n.root,
'BackgroundTransparency',f))end n._wash:to(if p then e else 1)end function m.
pressed(n,o)if n._lean==nil then n._lean=n:own(c.prop(n.name,'Position',h,i))n.
_rest=n.name.Position end local p=n._rest n._lean:to(if o then p+UDim2.
fromOffset(g,0)else p)end function m.lit(n,o,p)local q=n._bar if q==nil then q=
b('Frame',{Name='Bar',Size=UDim2.new(0,0,1,0),BackgroundTransparency=0,ZIndex=2,
Parent=n.root})n.ctx.theme:paint(q,'BackgroundColor3','accent')n._bar=q n.
_barSize=n:own(c.prop(q,'Size',k))end local r=if o and n.el.spec.primary then
UDim2.new(1,0,1,-2)else UDim2.new(0,if o then l else 0,1,0)if p or not n.ctx.
isShowing(n.el)then n._barSize:snap(r)else n._barSize:to(r)end end function m.
ink(n,o,p,q)local r=n.ctx.theme.tokens local s=n._inks[o]if q or not n.ctx.
isShowing(n.el)then if s then s:snap(r[p])else o.TextColor3=r[p]end return end
if s==nil then s=n:own(c.prop(o,'TextColor3',j))n._inks[o]=s end s:to(r[p])end
function m.flash(n)n:pressed(true)n:onHover(true)task.delay(0.22,function()if n.
root.Parent then n:pressed(false)n:onHover(false)end end)end function m.retint(n
)end function m.refreshName(n)local o=n.el if o.disabled then n.name.RichText=
true n.name.Text='<s>'..o.label..'</s>'else n.name.RichText=false n.name.Text=o.
label end end function d.new(n,o,p)local q=p or{}local r=q.indent or 0 local s=
b('TextButton',{Name=o.kind,Size=UDim2.new(1,0,0,q.height or d.HEIGHT),
BackgroundTransparency=1,ClipsDescendants=true,Active=not q.inert})n.theme:
paint(s,'BackgroundColor3','raised')local t=b('TextLabel',{Name='Name',Position=
UDim2.fromOffset(d.PAD+r,0),Size=UDim2.new(1,-(2*d.PAD+r),1,0),TextSize=d.NAME,
TextWrapped=true,TextTruncate=Enum.TextTruncate.AtEnd,Text=o.label,ZIndex=3,
Parent=s})n.theme:type(t,'text',true)local u=setmetatable({root=s,name=t,el=o,
ctx=n,chips={},indent=r,_cleanups={},_inks={},_hover=false},m)u:refreshName()if
q.inert then u.onHover=function()end u.pressed=function()end else s.MouseEnter:
Connect(function()n.hover:enter(u)end)local v=nil s.InputBegan:Connect(function(
w)local x=w.UserInputType if x==Enum.UserInputType.MouseButton1 then if not o.
disabled then u:pressed(true)end elseif x==Enum.UserInputType.Touch then if not
o.disabled then u:pressed(true)end v=task.delay(0.45,function()v=nil local y=if
o.disabled and o.disabledTip then o.disabledTip else o.tip if y and y~=''then n.
tooltip:showAt(s,y)end end)end end)local w=n.input.pointerUp:connect(function()
if u._lean then u:pressed(false)end if v then task.cancel(v)v=nil end end)u:
onCleanup(function()w()if v then task.cancel(v)end end)end u.destroy=function()n
.hover:leave(u)for v,w in u._cleanups do pcall(w)end s:Destroy()end return u end
return d end function a.l()local b=a.cache.l if not b then b={c=__modImpl()}a.
cache.l=b end return b.c end end do local function __modImpl()local b=a.g()local
c=a.i()local d=a.k()local e=a.f()local f=a.j()local g=a.b()local h=a.l()local i=
{}local j=h.PAD local k=16 local l=62 local m=25 local n=62 local o=18 local p=
12 local q=40 local r=4 local s=12 local t=3 local u=17 local v=42 local w=90
local x=3 local y=24 local z=22 local A=30 local B=16 i.MASTER_HEIGHT=l i.
SLIDER_HEIGHT=n local C={}local function indentOf(D)local E=D.section local F=E
and(E._root or E)if F and F.masterElement and F.masterElement~=D then return k
end return 0 end local function newRow(D,E,F)local G=F or{}G.indent=G.indent or
indentOf(E)local H=h.new(D,E,G)if G.indent>0 then local I=e('Frame',{Name=
'Stretch',Size=UDim2.new(0,3,1,0),BackgroundTransparency=0,ZIndex=1,Parent=H.
root})D.theme:paint(I,'BackgroundColor3','accentDim')end return H end local 
function addons(D,E,F,G)local H={}local function reflow()local I=G for J,K in H
do K.root.Position=UDim2.new(1,-(j+I),0.5,0)I+=K.width+K.gap end D.name.Size=
UDim2.new(1,-(2*j+D.indent+I),1,0)end local function place(I,J)J.root.
AnchorPoint=Vector2.new(1,0.5)J.root.ZIndex=4 J.root.Parent=D.root J.gap=if I.
kind=='key'then 6 else 0 J.onFit=reflow table.insert(H,J)I._view=J table.insert(
D.chips,J)D:onCleanup(function()I._view=nil J.destroy()end)end for I,J in F.
addons or{}do if J.kind=='color'and not J.spec.chipless then place(J,b.swatch(E,
J))end end for I,J in F.addons or{}do if J.kind=='key'and not J.spec.chipless
then place(J,d.build(E,J))end end reflow()return G end function C.toggle(D,E)
local F=E.spec.primary==true local G=newRow(D,E,{height=if F then l else nil})
local H=D.theme if F then H:type(G.name,'display')G.name.TextSize=m G.name.
TextWrapped=false end local I=e('TextLabel',{Name='State',AnchorPoint=Vector2.
new(1,0),Position=UDim2.new(1,-j,0,0),Size=UDim2.new(0,y,1,0),TextSize=h.NAME,
TextXAlignment=Enum.TextXAlignment.Right,ZIndex=3,Parent=G.root})H:type(I,'text'
,true)local J=nil local K=nil local L=nil local M=y+42 if F then J=e(
'TextButton',{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-(j+y+4),0,0),
Size=UDim2.new(0,34,1,0),ZIndex=4,Parent=G.root})K=D.glyph.chevron(J,'faint',
'down')L=D.glyph.chevron(J,'muted','up')for N,O in{K,L}do O.AnchorPoint=Vector2.
new(0.5,0.5)O.Position=UDim2.fromScale(0.5,0.5)end J.Activated:Connect(function(
)E.section:togglePeek()G.refresh()end)end addons(G,D,E,M)local function draw(N)
local O=E.value==true G:lit(O,N)local P=F and O G:ink(G.name,if E.disabled then
'faint'elseif P then'onAccent'elseif O then'text'else'muted',N)I.Text=if O then
'on'else'off'G:ink(I,if E.disabled then'line'elseif P then'onAccent'elseif O
then'accent'else'muted',N)for Q,R in G.chips do R.setInk(P)end if J then J.
Visible=not O and E.section.hasOptions==true K.Visible=not E.section.peeking L.
Visible=E.section.peeking==true end end G.root.Activated:Connect(function()if
not E.disabled then E:set(not E.value)end end)G.refresh=function()G:refreshName(
)draw(false)end draw(true)return G end local function formatted(D,E)local F=D.
spec if F.format then local G,H=pcall(F.format,D,E)if G and H~=nil then return
tostring(H)end end return string.format('%.'..(F.decimals or 0)..'f',E)..(F.
suffix or'')end function C.slider(D,E)local F=newRow(D,E,{height=n})local G=D.
theme local H=E.spec local I=F.root local J=F.indent local function ratio()local
K=H.max-H.min return if K<=0 then 0 else(E.value-H.min)/K end F.name.Position=
UDim2.fromOffset(j+J,8)F.name.Size=UDim2.new(1,-(2*j+J+96),0,24)F.name.
TextWrapped=false F._rest=nil local K=e('TextLabel',{Name='Readout',AnchorPoint=
Vector2.new(1,0),Position=UDim2.new(1,-j,0,8),Size=UDim2.new(0,96,0,24),TextSize
=u,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=4,Parent=I})G:type(K,'text',
true)local L=e('Frame',{Name='Ruler',AnchorPoint=Vector2.new(0,1),Position=UDim2
.new(0,j+J,1,-6),Size=UDim2.new(1,-(2*j+J),0,o),ClipsDescendants=true,ZIndex=2,
Parent=I})local function ticks(M,N)local O=e('ImageLabel',{AnchorPoint=Vector2.
new(0,1),Position=UDim2.fromScale(0,1),Size=UDim2.new(0,400,0,p),ScaleType=Enum.
ScaleType.Tile,TileSize=UDim2.fromOffset(q,p),BackgroundTransparency=1,
BorderSizePixel=0,ZIndex=2,Parent=M})G:paint(O,'ImageColor3',N)return O end
local M=ticks(L,'lineStrong')local N=e('Frame',{Name='Fill',Size=UDim2.new(
ratio(),0,1,0),ClipsDescendants=true,ZIndex=2,Parent=L})local O=ticks(N,'accent'
)local P=e('Frame',{AnchorPoint=Vector2.new(1,0),Position=UDim2.fromScale(1,0),
Size=UDim2.new(0,t,1,0),BackgroundTransparency=0,ZIndex=3,Parent=N})G:paint(P,
'BackgroundColor3','text')local function applyTicks()local Q=D.assets.ticks M.
Image=Q or''O.Image=Q or''local R=if Q then 1 else 0 M.BackgroundTransparency=R
O.BackgroundTransparency=R M.BackgroundColor3=G.tokens.lineStrong O.
BackgroundColor3=G.tokens.accent local S=L.AbsoluteSize.X/D.uiScale()M.Size=
UDim2.new(0,S,0,p)O.Size=UDim2.new(0,S,0,p)end I:GetPropertyChangedSignal(
'AbsoluteSize'):Connect(applyTicks)task.defer(applyTicks)local Q=F:own(g.prop(N,
'Size',v))local function typedEntry()if E.disabled or F._typing then return end
F._typing=true K.Visible=false local R=e('TextBox',{AnchorPoint=Vector2.new(1,0)
,Position=UDim2.new(1,-j,0,8),Size=UDim2.new(0,96,0,24),TextSize=u,
TextXAlignment=Enum.TextXAlignment.Right,Text='',PlaceholderText=tostring(E.
value),ZIndex=6,Parent=I})G:type(R,'text',true)G:paint(R,'TextColor3','accent')G
:paint(R,'PlaceholderColor3','faint')R:CaptureFocus()R.FocusLost:Connect(
function()local S=tonumber(R.Text)F._typing=false K.Visible=true R:Destroy()if S
then E:set(S)end end)end local function beginDrag(R,S,T)if E.disabled then
return end local U=E.value local V=math.max(L.AbsoluteSize.X,1)local W=H.max-H.
min local X=false local Y=false D.input:capture(function(Z)local _=Z-R if not X
then if math.abs(_.X)<x then if S and math.abs(_.Y)>8 then Y=true D.input:
release()end return end if S and math.abs(_.X)<=math.abs(_.Y)then Y=true D.input
:release()return end X=true Q.speed=w D.setScrollLocked(true)end E:set(U+W*_.X/V
)end,function(Z)Q.speed=v D.setScrollLocked(false)if not X and not Y and(Z-R).
Magnitude<8 then typedEntry()end end,T)end I.InputBegan:Connect(function(R)local
S=R.UserInputType if S==Enum.UserInputType.MouseButton2 then typedEntry()elseif
S==Enum.UserInputType.MouseButton1 then beginDrag(D.input:pointer(),false)elseif
S==Enum.UserInputType.Touch then beginDrag(D.input:at(R),true,R)end end)local 
function paintText()local R=if E.disabled then'faint'else'muted'G:paint(F.name,
'TextColor3',R)G:paint(K,'TextColor3',if E.disabled then'faint'else'text')K.Text
=formatted(E,E.value)end F.refresh=function()F:refreshName()paintText()
applyTicks()Q:to(UDim2.new(ratio(),0,1,0))end paintText()return F end local 
function pickText(D)local E=D.spec.display or tostring local F=D.value if D.spec
.multi then local G={}for H,I in D.spec.options do if F[I]then table.insert(G,E(
I))end end for H,I in F do if I and not table.find(D.spec.options,H)then table.
insert(G,E(H))end end if#G==0 then return'None',false end if#G<=2 then return
table.concat(G,', '),true end return string.format('%s, %s +%d',G[1],G[2],#G-2),
true end if F==nil then return'None',false end return E(F),true end function C.
dropdown(D,E)local F=newRow(D,E)local G=D.theme local H=F.root G:paint(F.name,
'TextColor3','muted')local I=e('TextLabel',{Name='Value',AnchorPoint=Vector2.
new(1,0),Position=UDim2.new(1,-(j+z),0,0),Size=UDim2.new(0.55,-z,1,0),TextSize=h
.NAME,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.
Right,ZIndex=3,Parent=H})G:type(I,'text',true)local J=D.glyph.chevron(H,'faint')
J.AnchorPoint=Vector2.new(1,0.5)J.Position=UDim2.new(1,-j,0.5,0)J.ZIndex=3 F.
name.Size=UDim2.new(0.45,-(j+F.indent),1,0)H.Activated:Connect(function()if not
E.disabled then c.open(D,E,H)end end)F.refresh=function()F:refreshName()local K,
L=pickText(E)I.Text=K G:paint(I,'TextColor3',if E.disabled or not L then'faint'
else'text')end F.refresh()return F end function C.input(D,E)local F=newRow(D,E)
local G=D.theme local H=E.spec F.name.Size=UDim2.new(0.35,-(j+F.indent),1,0)G:
paint(F.name,'TextColor3','muted')local I=e('TextBox',{AnchorPoint=Vector2.new(1
,0.5),Position=UDim2.new(1,-j,0.5,0),Size=UDim2.new(0.65,-j,0,A),TextSize=h.NAME
,Text=E.value or'',PlaceholderText=H.placeholder or'',ClipsDescendants=true,
TextXAlignment=Enum.TextXAlignment.Right,TextEditable=not E.disabled,ZIndex=3,
Parent=F.root})G:type(I,'text',true)G:paint(I,'TextColor3','text')G:paint(I,
'PlaceholderColor3','faint')local J=e('Frame',{AnchorPoint=Vector2.new(0,1),
Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,1),BackgroundTransparency=0,
ZIndex=4,Parent=I})G:paint(J,'BackgroundColor3','lineStrong')I.Focused:Connect(
function()G:paint(J,'BackgroundColor3','accent')end)I.FocusLost:Connect(function
(K)G:paint(J,'BackgroundColor3','lineStrong')if not H.finished then return end
if not K or not E:set(I.Text)then I.Text=E.value or''end end)I:
GetPropertyChangedSignal('Text'):Connect(function()if F._applying or H.finished
then return end if not E:set(I.Text)and I.Text~=E.value then F._applying=true I.
Text=E.value or''F._applying=false end end)F.root.Activated:Connect(function()if
not E.disabled then I:CaptureFocus()end end)F.refresh=function()F:refreshName()I
.TextEditable=not E.disabled if I.Text~=(E.value or'')then F._applying=true I.
Text=E.value or''F._applying=false end end return F end function C.button(D,E)
local F=newRow(D,E)local G=e('Frame',{Name='Block',Position=UDim2.new(0,j+F.
indent,0,r),Size=UDim2.new(1,-(2*j+F.indent),1,-2*r),BackgroundTransparency=0,
ZIndex=1,Parent=F.root})D.theme:paint(G,'BackgroundColor3','raised')F.name.
Position+=UDim2.fromOffset(s,0)local H=nil local function draw()F:refreshName()F
:ink(F.name,if E.disabled then'faint'elseif E.spec.danger then'danger'else'text'
)end F.refresh=draw draw()F.root.Activated:Connect(function()if E.disabled then
return end if E.spec.confirm and H==nil then F.name.Text='Again to confirm'F:
ink(F.name,'accent')H=task.delay(2.5,function()H=nil draw()end)return end if H
then task.cancel(H)H=nil draw()end F:flash()E:fire()end)F:onCleanup(function()if
H then task.cancel(H)end end)return F end function C.stat(D,E)local F=newRow(D,E
,{height=36,inert=true})local G=D.theme G:paint(F.name,'TextColor3','muted')
local H=e('TextLabel',{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-j,0,0)
,Size=UDim2.new(0.6,0,1,0),TextSize=20,TextXAlignment=Enum.TextXAlignment.Right,
ZIndex=3,Parent=F.root})G:type(H,'display')G:paint(H,'TextColor3','text')F.
refresh=function()F.name.Text=E.label H.Text=tostring(E.value)end F.refresh()
return F end function C.label(D,E)local F=D.theme if E.addons then local G=
newRow(D,E)F:paint(G.name,'TextColor3','muted')G.name.RichText=true addons(G,D,E
,0)G.refresh=function()G.name.Text=E.label end return G end local G=newRow(D,E,{
height=30,inert=true})local H=G.name local I=E.spec.wrap==true H.RichText=true H
.TextSize=B H.TextWrapped=I F:type(H,'text')F:paint(H,'TextColor3','muted')H.
TextTruncate=if I then Enum.TextTruncate.None else Enum.TextTruncate.AtEnd H.
TextYAlignment=if I then Enum.TextYAlignment.Top else Enum.TextYAlignment.Center
H.LineHeight=if I then 1.15 else 1 H.Position=UDim2.fromOffset(j+G.indent,if I
then 6 else 0)H.Size=if I then UDim2.new(1,-(2*j+G.indent),1,-6)else UDim2.new(1
,-(2*j+G.indent),1,0)H.Text=E.label if I then H:GetPropertyChangedSignal(
'TextBounds'):Connect(function()local J=math.ceil(H.TextBounds.Y/D.uiScale())+12
if E._measured~=J then E._measured=J if E._relayout then E._relayout()end end
end)end G.refresh=function()H.Text=E.label end return G end function C.divider(D
,E)local F=newRow(D,E,{height=28,inert=true})D.theme:paint(F.name,'TextColor3',
'faint')F.name.TextSize=B F.refresh=function()F.name.Text=E.label end return F
end local function chipRow(D,E,F,G)local H=newRow(D,E)D.theme:paint(H.name,
'TextColor3','muted')F.root.AnchorPoint=Vector2.new(1,0.5)F.root.Position=UDim2.
new(1,-(j-8),0.5,0)F.root.ZIndex=4 F.root.Parent=H.root H.name.Size=UDim2.new(1,
-(2*j+H.indent+G),1,0)table.insert(H.chips,F)H:onCleanup(F.destroy)H.refresh=
function()H:refreshName()F.refresh()end return H end function C.key(D,E)local F=
d.build(D,E)local G=chipRow(D,E,F,96)G.root.Activated:Connect(F.start)return G
end function C.color(D,E)local F=b.swatch(D,E)local G=chipRow(D,E,F,b.DOT_SPACE)
G.root.Activated:Connect(F.open)return G end function i.build(D,E)local F=C[E.
kind]assert(F,'sottUI: no view for '..tostring(E.kind))local G=F(D,E)E._view=G
return G end i.metrics=f return i end function a.m()local b=a.cache.m if not b
then b={c=__modImpl()}a.cache.m=b end return b.c end end do local function 
__modImpl()local b={}b.__index=b local c=function(c)warn(c)end function b.
connect(d,e)local f=table.clone(d._list)table.insert(f,e)d._list=f return
function()local g=table.clone(d._list)local h=table.find(g,e)if h then table.
remove(g,h)d._list=g end end end function b.fire(d,...)for e,f in d._list do
local g,h=xpcall(f,debug.traceback,...)if not g then c(
'sottUI: listener failed: '..tostring(h))end end end function b.clear(d)d._list=
{}end return{new=function()return((setmetatable({_list={}},b)))end,setReporter=
function(d)c=d end}end function a.n()local b=a.cache.n if not b then b={c=
__modImpl()}a.cache.n=b end return b.c end end do local function __modImpl()
local b=a.n()local c={}local d={}d.__index=d local function decimals(e)local f=
string.format('%.10f',e)local g=string.match(f,'%.(%d-)0*$')return if g then#g
else 0 end local function roundTo(e,f)if f<=0 then return e end local g=math.
round(e/f)*f return tonumber(string.format('%.'..decimals(f)..'f',g))or g end c.
roundTo=roundTo local function sameList(e,f)if#e~=#f then return false end for g
=1,#e do if e[g]~=f[g]then return false end end return true end local function 
sameSet(e,f)for g,h in e do if h and not f[g]then return false end end for g,h
in f do if h and not e[g]then return false end end return true end local e={
toggle=function(e,f)return f==true end,slider=function(e,f)local g=tonumber(f)if
g==nil or g~=g then return nil end local h=e.spec return math.clamp(roundTo(g,h.
step or 1),h.min,h.max)end,dropdown=function(e,f)local g=e.spec if g.multi then
local h={}if type(f)=='table'then for i,j in f do if type(i)=='number'then h[j]=
true elseif j then h[i]=true end end elseif f~=nil and f~=''then h[f]=true end
if not g.keep then for i in h do if not table.find(g.options,i)then h[i]=nil end
end end return h end if f==nil or f==''then return false end if not table.find(g
.options,f)and not g.keep then return nil end return f end,input=function(e,f)
local g=if f==nil then''else tostring(f)local h=e.spec if h.maxLength and#g>h.
maxLength then g=string.sub(g,1,h.maxLength)end if h.numeric and g~=''and g~='-'
and g~='.'and tonumber(g)==nil then return nil end if h.verify and not h.verify(
g)then return nil end return g end,key=function(e,f)if type(f)=='string'then
return{key=f,mode=e.value and e.value.mode or'Toggle',modifiers={}}end if type(f
)~='table'then return nil end local g=e.value or{}return{key=f.key or f[1]or g.
key or'None',mode=f.mode or f[2]or g.mode or'Toggle',modifiers=f.modifiers or f[
3]or g.modifiers or{}}end,color=function(e,f)if typeof(f)=='Color3'then return{
color=f,alpha=e.value and e.value.alpha or 0}end if type(f)=='table'and typeof(f
.color)=='Color3'then return{color=f.color,alpha=math.clamp(tonumber(f.alpha)or
0,0,1)}end return nil end,label=function(e,f)return tostring(f)end,stat=function
(e,f)return tostring(f)end}local function equal(f,g,h)local i=f.kind if i==
'dropdown'and f.spec.multi then return sameSet(g,h)end if i=='key'then return g.
key==h.key and g.mode==h.mode and sameList(g.modifiers,h.modifiers)end if i==
'color'then return g.color==h.color and g.alpha==h.alpha end return g==h end
local function unwrap(f,g)if f.kind=='dropdown'and not f.spec.multi and g==false
then return nil end return g end function c.new(f,g,h,i,j)local k=setmetatable({
kind=f,id=g,label=h,spec=i,tip=i.tip,disabled=i.disabled==true,disabledTip=i.
disabledTip,visible=i.visible~=false,saved=i.saved~=false,changed=b.new()},d)
local l=e[f]local m=j if l then m=l(k,j)if m==nil and f=='slider'then m=i.min
end if m==nil and f=='dropdown'then m=false end end k.value=unwrap(k,m)k.default
=k.value return k end function d.set(f,g)local h=e[f.kind]local i=g if h then i=
h(f,g)if i==nil then return false end i=unwrap(f,i)end local j=f.value if j~=nil
and i~=nil and equal(f,j,i)then return false end if j==nil and i==nil then
return false end f.value=i f:notify()return true end function d.reset(f)local g=
f.default if f.kind=='dropdown'and f.spec.multi then g=table.clone(g)end f:set(g
)end local function redraw(f)local g=f._view if g then g.refresh()end local h=f.
host if h and h._view then h._view.refresh()end end function d.notify(f)redraw(f
)f.changed:fire(f.value)end function d.fire(f)f.changed:fire(f.value)end
function d.on(f,g)return f.changed:connect(g)end function d.setLabel(f,g)if f.
label==g then return end f.label=g if f.kind=='label'then f.value=g local h=f.
_relayout if h then h()end end redraw(f)end function d.setTip(f,g)f.tip=g end
function d.setDisabled(f,g,h)f.disabled=g==true f.disabledTip=h or f.disabledTip
redraw(f)end function d.setVisible(f,g)if f.visible==g then return end f.visible
=g local h=f._relayout if h then h()end end function d.setOptions(f,g)local h=f.
spec h.options=table.clone(g)if h.multi then if h.keep then for i,j in f.value
do if j and not table.find(h.options,i)then table.insert(h.options,i)end end
else local i=false for j in f.value do if not table.find(h.options,j)then f.
value[j]=nil i=true end end if i then f:notify()return end end elseif f.value~=
nil and not table.find(h.options,f.value)then if h.keep then table.insert(h.
options,f.value)else f.value=nil f:notify()return end end redraw(f)end function
d.isModified(f)if f.kind=='button'or f.kind=='label'or f.kind=='divider'or f.
kind=='stat'then return false end local g,h=f.value,f.default if g==nil or h==
nil then return g~=h end return not equal(f,g,h)end function d.attach(f,g)local
h=f.addons if h==nil then h={}f.addons=h end table.insert(h,g)g.host=f redraw(f)
end function d.shown(f)if not f.visible or(f.kind=='label'and f.label=='')then
return false end local g=f.guard return g==nil or g()end return c end function a
.o()local b=a.cache.o if not b then b={c=__modImpl()}a.cache.o=b end return b.c
end end do local function __modImpl()local b=a.o()local c={}local d={}d.__index=
d local function add(e,f,g,h,i,j)local k=b.new(f,g or(f..'#'..tostring(e._page:
nextId())),h,i,j)k.section=e k.guard=e._guard e._page:_register(k,g~=nil)table.
insert(e.rows,k)local l=e._root or e if l.masterElement then l.hasOptions=true
end e._page:_invalidate()return k end function d.toggle(e,f,g)local h=add(e,
'toggle',f,g.label or f,g,g.default==true)if g.onChanged then h:on(g.onChanged)
end return h end function d.master(e,f,g)g.primary=true local h=e:toggle(f,g)e.
masterElement=h local i=e._page h:on(function()i:_invalidate()end)local j=e.
_guard e._guard=function()if j and not j()then return false end return h.value==
true or e.peeking==true end return h end function d.togglePeek(e)e.peeking=not e
.peeking e._page:_invalidate()end function d.slider(e,f,g)g.min=g.min or 0 g.max
=g.max or 100 g.step=g.step or 1 if g.decimals==nil then local h=string.format(
'%.10f',g.step)local i=string.match(h,'%.(%d-)0*$')g.decimals=if i then#i else 0
end local h=add(e,'slider',f,g.label or f,g,g.default or g.min)if g.onChanged
then h:on(g.onChanged)end return h end function d.dropdown(e,f,g)g.options=g.
options or{}local h=g.default if h==nil and g.multi then h={}end local i=add(e,
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
toggled==true if f.kind=='toggle'and h.onPress==nil then j.toggled=f.value h.
onPress=function()f:set(not f.value)j.toggled=f.value end end e._page:_register(
i,true)e._page.window.keys:register(i)f:attach(i)return i end function d.
addColor(e,f,g,h)local i=b.new('color',g,h.label or f.label,h,{color=h.default
or Color3.new(1,1,1),alpha=h.alphaValue or 0})i.section=e e._page:_register(i,
true)f:attach(i)if h.onChanged then i:on(h.onChanged)end return i end function d
.when(e,f,g)local h=e._guard local i=f if h then i=function()return h()and f()
end end local j=setmetatable({rows=e.rows,title=e.title,_page=e._page,_guard=i,
_root=e._root or e},d)for k,l in(g or{})do l:on(function()e._page:_invalidate()
end)end return j end function c.new(e,f)return setmetatable({title=f,rows={},
_page=e,_guard=nil,_root=nil},d)end return c end function a.p()local b=a.cache.p
if not b then b={c=__modImpl()}a.cache.p=b end return b.c end end do local 
function __modImpl()local b=a.m()local c=a.f()local d=a.j()local e=a.b()local f=
a.p()local g={}local h=26 local i=36 function g.open(j,k,l)if j._dialogClose
then j._dialogClose()end local m=j.ctx local n=m.theme local o=j._layer local p=
k.width or j.width local q=k.maxHeight or 340 local r=60 local s=c('TextButton',
{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BackgroundColor3=Color3.new(
0,0,0),ZIndex=50,Parent=o})local t=e.prop(s,'BackgroundTransparency',22)local u=
c('Frame',{Position=m.dialogAt(),Size=UDim2.fromOffset(p,0),
BackgroundTransparency=0,ClipsDescendants=true,Active=true,ZIndex=51,Parent=o})n
:paint(u,'BackgroundColor3','base')c('UIScale',{Scale=m.uiScale(),Parent=u})
local v=c('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=u})n:
paint(v,'Color','line')local w=c('TextLabel',{Position=UDim2.fromOffset(20,16),
Size=UDim2.new(1,-40,0,40),TextSize=24,Text=k.title or'',ZIndex=52,Parent=u})n:
type(w,'display')n:paint(w,'TextColor3','text')local x=60 local y=k.text if y
and y~=''then local z=c('TextLabel',{Position=UDim2.fromOffset(20,x),Size=UDim2.
new(1,-40,0,22),AutomaticSize=Enum.AutomaticSize.Y,TextSize=16,TextWrapped=true,
Text=y,ZIndex=52,Parent=u})n:type(z,'text')n:paint(z,'TextColor3','muted')x+=22+
math.floor(#y/52)*22+12 end local z=c('ScrollingFrame',{Position=UDim2.
fromOffset(20,x),Size=UDim2.new(1,-40,0,0),ScrollBarThickness=3,ZIndex=52,Parent
=u})n:paint(z,'ScrollBarImageColor3','lineStrong')local A=false local B={window=
j,name='Dialog',nextId=function()j._dialogIds+=1 return j._dialogIds end,
_register=function(B,C,D)C._pageName='Dialog'if D then j.elements[C.id]=C end
end,_invalidate=function()end}local C=f.new(B,'')local D,E=xpcall(l,debug.
traceback,C)if not D then warn('sottUI: dialog build failed: '..tostring(E))end
local F={}local G=0 for H,I in C.rows do if I:shown()then local J=b.build(m,I)
local K=r if I.kind=='divider'then K=28 elseif I.kind=='label'then local L=math.
ceil(d.width('text',I.label,16)/(p-48))K=if I.spec.wrap then L*21+12 else 32 end
J.root.Position=UDim2.fromOffset(0,G)J.root.Size=UDim2.new(1,0,0,K)J.root.Parent
=z G+=K+3 table.insert(F,J)end end z.CanvasSize=UDim2.fromOffset(0,G)local H=
math.min(G,q)z.Size=UDim2.new(1,-40,0,H)local I=x+H+12 local J=c('TextButton',{
Position=UDim2.fromOffset(20,I),Size=UDim2.new(1,-40,0,46),
BackgroundTransparency=0,TextSize=17,Text=k.done or'Done',ZIndex=52,Parent=u})n:
type(J,'text',true)n:paint(J,'BackgroundColor3','raised')n:paint(J,'TextColor3',
'text')local K=I+46+14 local L=e.prop(u,'Size',h)L:to(UDim2.fromOffset(p,K))
local function close()if A then return end A=true j._dialogClose=nil s.Active=
false for M,N in C.rows do if j.elements[N.id]==N then j.elements[N.id]=nil end
for O,P in N.addons or{}do j.keys:unregister(P)if j.elements[P.id]==P then j.
elements[P.id]=nil end end end if k.onClose then task.spawn(k.onClose)end t:to(1
,function()t:destroy()s:Destroy()end)L.speed=i L:to(UDim2.fromOffset(p,0),
function()for M,N in F do N.destroy()end L:destroy()u:Destroy()end)end j.
_dialogClose=close s.MouseButton1Down:Connect(close)J.Activated:Connect(close)
end return g end function a.q()local b=a.cache.q if not b then b={c=__modImpl()}
a.cache.q=b end return b.c end end do local function __modImpl()local b=a.a()
local c={}local d={text={name='SottUIText',faces={{name='Regular',weight=400,
file='text-400.ttf'},{name='Medium',weight=500,file='text-500.ttf'}}},display={
name='SottUIDisplay',faces={{name='ExtraBold',weight=800,file='display-800.ttf'}
}}}local e=10000 local function family(f,g,h,i,j)local k={}for l,m in h.faces do
local n=g..'/'..m.file local o=f.read(n)if o==nil or#o<e then local p=b.fetch(i
..m.file)if p==nil or#p<e then return nil end if not f.write(n,p)then return nil
end end local p=f.asset(n)if p==nil then return nil end table.insert(k,{name=m.
name,weight=m.weight,style='normal',assetId=p})end local l=g..'/'..h.name..
'.json'if not f.write(l,j({name=h.name,faces=k}))then return nil end return f.
asset(l)end function c.load(f,g,h)local i=b.files()if i==nil or b.global(
'getcustomasset')==nil then return{}end i.folder(f)local j={}local k,l=pcall(
function()j.text=family(i,f,d.text,g,h)j.display=family(i,f,d.display,g,h)end)if
not k then warn('sottUI: fonts unavailable: '..tostring(l))end return j end
function c.image(f,g,h)local i=b.files()if i==nil or b.global('getcustomasset')
==nil then return nil end i.folder(f)local j=f..'/'..h if i.read(j)==nil then
local k=b.fetch(g..h)if k==nil or not i.write(j,k)then return nil end end return
i.asset(j)end return c end function a.r()local b=a.cache.r if not b then b={c=
__modImpl()}a.cache.r=b end return b.c end end do local function __modImpl()
local b=a.f()local c={}local function stroke(d,e,f,g,h,i,j)local k=b('Frame',{
AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromOffset(i,j),Size=UDim2.
fromOffset(g,2),Rotation=h,BackgroundTransparency=0,Parent=d})e:paint(k,
'BackgroundColor3',f)return k end function c.new(d)local e={}function e.chevron(
f,g,h)local i=b('Frame',{Size=UDim2.fromOffset(12,12),Parent=f})if h=='right'
then stroke(i,d,g,7,45,6,3.6)stroke(i,d,g,7,-45,6,8.4)elseif h=='up'then stroke(
i,d,g,7,-45,3.6,6)stroke(i,d,g,7,45,8.4,6)else stroke(i,d,g,7,45,3.6,6)stroke(i,
d,g,7,-45,8.4,6)end return i end function e.cross(f,g)local h=b('Frame',{Size=
UDim2.fromOffset(12,12),Parent=f})stroke(h,d,g,13,45,6,6)stroke(h,d,g,13,-45,6,6
)return h end function e.dash(f,g)local h=b('Frame',{Size=UDim2.fromOffset(12,12
),Parent=f})stroke(h,d,g,12,0,6,6)return h end return e end return c end
function a.s()local b=a.cache.s if not b then b={c=__modImpl()}a.cache.s=b end
return b.c end end do local function __modImpl()local b={}b.__index=b local 
function dispose(c)local d=typeof(c)if d=='RBXScriptConnection'then c:
Disconnect()elseif d=='Instance'then c:Destroy()elseif d=='function'then c()
elseif d=='thread'then task.cancel(c)elseif d=='table'then local e=c.destroy or
c.Destroy or c.Disconnect if e then e(c)end end end function b.add(c,d)table.
insert(c._items,d)return d end function b.clean(c)local d=c._items c._items={}
for e=#d,1,-1 do local f,g=pcall(dispose,d[e])if not f then warn(
'sottUI: cleanup failed: '..tostring(g))end end end b.destroy=b.clean return{new
=function()return((setmetatable({_items={}},b)))end}end function a.t()local b=a.
cache.t if not b then b={c=__modImpl()}a.cache.t=b end return b.c end end do
local function __modImpl()local b=a.a()local c=a.t()local d=a.n()local e={}local
f={}f.__index=f function f.pointer(g)local h=g._guiService:GetGuiInset()return g
._uis:GetMouseLocation()-h end function f.at(g,h)local i=h.Position return
Vector2.new(i.X,i.Y)end function f.capture(g,h,i,j)g:release()g._move=h g.
_finish=i g._finger=j end function f.release(g)local h=g._finish g._move=nil g.
_finish=nil g._finger=nil if h then task.spawn(h,g:pointer())end end function f.
typing(g)return g._uis:GetFocusedTextBox()~=nil end function f.destroy(g)g._move
=nil g._finish=nil g._maid:clean()g.keyDown:clear()g.keyUp:clear()g.wheel:clear(
)g.moved:clear()g.pointerUp:clear()end function e.new()local g=b.service(
'UserInputService')local h=c.new()local i=setmetatable({_uis=g,_guiService=b.
service('GuiService'),_maid=h,_move=nil,_finish=nil,keyDown=d.new(),keyUp=d.new(
),wheel=d.new(),moved=d.new(),pointerUp=d.new()},f)h:add(g.InputChanged:Connect(
function(j)local k=j.UserInputType if k==Enum.UserInputType.MouseMovement then
local l=i:pointer()if i._move then i._move(l)end i.moved:fire(l)elseif k==Enum.
UserInputType.Touch then if i._move and(i._finger==nil or i._finger==j)then i.
_move(i:at(j))end elseif k==Enum.UserInputType.MouseWheel then i.wheel:fire(j.
Position.Z)end end))h:add(g.InputEnded:Connect(function(j,k)local l=j.
UserInputType if l==Enum.UserInputType.MouseButton1 or l==Enum.UserInputType.
Touch then if i._move and(l~=Enum.UserInputType.Touch or i._finger==nil or i.
_finger==j)then local m=if l==Enum.UserInputType.Touch then i:at(j)else i:
pointer()local n=i._finish i._move=nil i._finish=nil i._finger=nil if n then n(m
)end end i.pointerUp:fire()end i.keyUp:fire(j,k)end))h:add(g.InputBegan:Connect(
function(j,k)i.keyDown:fire(j,k)end))return i end return e end function a.u()
local b=a.cache.u if not b then b={c=__modImpl()}a.cache.u=b end return b.c end
end do local function __modImpl()local b={}local c={[Enum.UserInputType.
MouseButton1]='MB1',[Enum.UserInputType.MouseButton2]='MB2',[Enum.UserInputType.
MouseButton3]='MB3'}local d={MB1=Enum.UserInputType.MouseButton1,MB2=Enum.
UserInputType.MouseButton2,MB3=Enum.UserInputType.MouseButton3}local e={[Enum.
KeyCode.LeftAlt]='LAlt',[Enum.KeyCode.RightAlt]='RAlt',[Enum.KeyCode.LeftControl
]='LCtrl',[Enum.KeyCode.RightControl]='RCtrl',[Enum.KeyCode.LeftShift]='LShift',
[Enum.KeyCode.RightShift]='RShift'}local function nameOf(f)local g=c[f.
UserInputType]if g then return g end if f.UserInputType==Enum.UserInputType.
Keyboard and f.KeyCode.Name~='Unknown'then return f.KeyCode.Name end return nil
end function b.new(f,g,h)local i=g.service('UserInputService')local j={}local k=
{}local l=nil local m=false local n=nil local o=nil local function modifiersHeld
(p)for q,r in(p or{})do local s=false for t,u in e do if u==r and i:IsKeyDown(t)
then s=true end end if not s then return false end end return true end local 
function heldModifiers(p)local q={}for r,s in e do if r.Name~=p and i:IsKeyDown(
r)then table.insert(q,s)end end table.sort(q)return q end function j.register(p,
q)table.insert(k,q)end function j.unregister(p,q)local r=table.find(k,q)if r
then table.remove(k,r)end end function j.listen(p,q,r)j.cancel()l=q m=r==true
end function j.swallowed(p,q)return o==q end function j.cancel()local p=l l=nil
n=nil if p then p(nil)end end function j.state(p,q)local r=q.value if r==nil
then return false end if r.mode=='Always'then return true end if r.mode==
'Toggle'then return q.toggled==true end if r.key=='None'or l~=nil or f:typing()
then return false end local s=d[r.key]if s then return not h()and i:
IsMouseButtonPressed(s)and modifiersHeld(r.modifiers)end local t,u=pcall(
function()return i:IsKeyDown((Enum.KeyCode)[r.key])end)return t and u and
modifiersHeld(r.modifiers)end f.keyDown:connect(function(p)local q=nameOf(p)if q
==nil then return end if l then local r=c[p.UserInputType]~=nil if r and(m or q
=='MB1')then return end if e[p.KeyCode]and not r then n=q return end local s=l l
=nil n=nil o=q if q=='Escape'then(s)('None',{})else(s)(q,heldModifiers(q))end
return end if o==q then return end if f:typing()then return end for r,s in k do
local t=s.value if t.key==q and not s.disabled and modifiersHeld(t.modifiers)
then if t.mode=='Toggle'then s.toggled=not s.toggled end local u=s.spec.onPress
if u then u(s,s.toggled)end end end end)f.keyUp:connect(function(p)local q=
nameOf(p)if q==nil then return end if n==q and l then local r=l l=nil n=nil r(q,
{})return end if o==q then o=nil end for r,s in k do local t=s.value if t.key==q
and t.mode=='Hold'and s.spec.onRelease then s.spec.onRelease(s)end end end)
return j end return b end function a.v()local b=a.cache.v if not b then b={c=
__modImpl()}a.cache.v=b end return b.c end end do local function __modImpl()
local b=a.f()local c=a.b()local d={}local e=320 local f=8 local g=20 local h=26
local i=5 function d.new(j,k)local l=j.theme local m={}local n={}local function 
layout()local o=k.AbsoluteSize local p=o.Y-g for q=#m,1,-1 do local r=m[q]p-=r.
height r.pos:to(UDim2.fromOffset(o.X-e-g,p))p-=f end end local function dismiss(
o)if o.gone then return end o.gone=true if o.timer then task.cancel(o.timer)end
local p=table.find(m,o)if p then table.remove(m,p)end local q=k.AbsoluteSize o.
pos:to(UDim2.fromOffset(q.X+8,o.frame.Position.Y.Offset),function()o.pos:
destroy()o.frame:Destroy()end)layout()end function n.show(o,p)while#m>=i do
dismiss(m[1])end local q=k.AbsoluteSize local r=b('TextButton',{Name='Notice',
Position=UDim2.fromOffset(q.X+8,q.Y-g-60),Size=UDim2.fromOffset(e,60),
BackgroundTransparency=0,ZIndex=80,Parent=k})l:paint(r,'BackgroundColor3',
'surface')local s=b('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
Parent=r})l:paint(s,'Color','lineStrong')local t=b('Frame',{Size=UDim2.new(0,4,1
,0),BackgroundTransparency=0,ZIndex=81,Parent=r})l:paint(t,'BackgroundColor3',
'accent')local u=10 if p.title and p.title~=''then local v=b('TextLabel',{
Position=UDim2.fromOffset(18,u),Size=UDim2.new(1,-32,0,24),TextSize=22,
TextTruncate=Enum.TextTruncate.AtEnd,Text=p.title,ZIndex=81,Parent=r})l:type(v,
'display')l:paint(v,'TextColor3','text')u+=26 end local v=nil if p.text and p.
text~=''then v=b('TextLabel',{Position=UDim2.fromOffset(18,u),Size=UDim2.new(1,-
32,0,20),TextSize=16,TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top,
RichText=true,Text=p.text,ZIndex=81,Parent=r})l:type(v,'text')l:paint(v,
'TextColor3','muted')end local w={frame=r,height=u+28,pos=c.prop(r,'Position',h)
,gone=false}r.Size=UDim2.fromOffset(e,w.height)if v then task.defer(function()if
w.gone then return end local x=math.ceil(v.TextBounds.Y)if x>20 then v.Size=
UDim2.new(1,-32,0,x)w.height=u+x+10 r.Size=UDim2.fromOffset(e,w.height)layout()
end end)end w.pos:snap(UDim2.fromOffset(q.X+8,q.Y-g-w.height))table.insert(m,w)r
.Activated:Connect(function()dismiss(w)end)w.timer=task.delay(p.seconds or 5,
function()w.timer=nil dismiss(w)end)layout()end function n.destroy(o)for p,q in
table.clone(m)do if q.timer then task.cancel(q.timer)end q.pos:destroy()q.frame:
Destroy()end table.clear(m)end return n end return d end function a.w()local b=a
.cache.w if not b then b={c=__modImpl()}a.cache.w=b end return b.c end end do
local function __modImpl()local b=a.f()local c=a.b()local d={}local e=34 local f
=48 local g=0.55 local h=340 local i=40 local j=8 function d.popover(k,l)local m
=k.theme local n={}local o=nil local function close()local p=o if p==nil then
return end o=nil p.catcher:Destroy()p.open=false p.size.speed=f p.size:to(UDim2.
fromOffset(p.width,0),function()p.size:destroy()p.frame:Destroy()end)if p.
disconnectEl then p.disconnectEl()end end function n.open(p,q,r,s,t)close()local
u=l.AbsoluteSize local v,w=q.AbsolutePosition-l.AbsolutePosition,q.AbsoluteSize
r=math.min(r,u.X-2*j)s=math.min(s,u.Y-2*j)local x=if r>w.X then v.X+w.X-r else v
.X local y=math.clamp(x,j,u.X-r-j)local z=v.Y+w.Y+2 local A=math.max(k.
popoverTop(),j)local B=z+s+j>u.Y and v.Y-s-2>A local C=if B then v.Y-s-2 else
math.max(math.min(z,u.Y-s-j),A)local D=b('TextButton',{Name='Catcher',Size=UDim2
.fromScale(1,1),ZIndex=60,Parent=l})local E=b('Frame',{Name='Popover',Position=
UDim2.fromOffset(y,C),Size=UDim2.fromOffset(r,0),BackgroundTransparency=0,
ClipsDescendants=true,ZIndex=61,Active=true,Parent=l})m:paint(E,
'BackgroundColor3','raised')local F=b('UIStroke',{ApplyStrokeMode=Enum.
ApplyStrokeMode.Border,Parent=E})m:paint(F,'Color','lineStrong')local G=b(
'Frame',{Size=UDim2.fromScale(1,1),Parent=E})local H={frame=E,catcher=D,width=r,
open=true,size=c.prop(E,'Size',e)}o=H D.MouseButton1Down:Connect(close)D.
MouseButton2Down:Connect(close)local I={close=close,resize=function(I)if H.open
then H.size:to(UDim2.fromOffset(r,I))end end,onKey=function(I)H.onKey=I end,
onRefresh=function(I)H.onRefresh=I end}t(G,I)H.size:to(UDim2.fromOffset(r,s))end
function n.isOpen(p)return o~=nil end function n.close(p)close()end function n.
key(p,q)if o==nil then return false end if q=='Escape'then close()return true
end if o.onKey then o.onKey(q)return true end return false end return n end
function d.tooltip(k,l)local m=k.theme local n=b('Frame',{Name='Tooltip',
AutomaticSize=Enum.AutomaticSize.XY,BackgroundTransparency=0,Visible=false,
ZIndex=70,Parent=l})m:paint(n,'BackgroundColor3','raised')local o=b('UIStroke',{
ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=n})m:paint(o,'Color',
'lineStrong')b('UIPadding',{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,
10),PaddingTop=UDim.new(0,7),PaddingBottom=UDim.new(0,7),Parent=n})local p=b(
'TextLabel',{AutomaticSize=Enum.AutomaticSize.XY,TextSize=16,TextWrapped=true,
ZIndex=71,Parent=n})b('UISizeConstraint',{MaxSize=Vector2.new(h,400),Parent=p})m
:type(p,'text')m:paint(p,'TextColor3','text')local q={}local r=nil function q.
hide(s)if r then task.cancel(r)r=nil end n.Visible=false end local s=c.prop(n,
'Position',i)function q.showAt(t,u,v)t:hide()p.Text=v n.Visible=true task.defer(
function()if not n.Visible then return end local w=l.AbsoluteSize local x=n.
AbsoluteSize local y=u.AbsolutePosition-l.AbsolutePosition local z=math.clamp(y.
X,j,w.X-x.X-j)local A=y.Y+u.AbsoluteSize.Y+3 local B=A+x.Y+j>w.Y local C=if B
then y.Y-x.Y-3 else A s:snap(UDim2.fromOffset(z,C+(if B then 8 else-8)))s:to(
UDim2.fromOffset(z,C))end)end function q.schedule(t,u,v)t:hide()r=task.delay(g,
function()r=nil if u.Parent~=nil then t:showAt(u,v)end end)end return q end
function d.hover(k)local l={}local m=nil local function clear()local n=m if n
then m=nil n:onHover(false)k.tooltip:hide()end end function l.current(n)return m
end function l.enter(n,o)if m==o then return end clear()m=o o:onHover(true)local
p=o.el local q=if p.disabled and p.disabledTip then p.disabledTip else p.tip if
q and q~=''then k.tooltip:schedule(o.root,q)end end function l.leave(n,o)if m==o
then clear()end end l.clear=clear function l.verify(n,o)local p=m if p==nil then
return end local q=p.root local r,s=q.AbsolutePosition,q.AbsoluteSize local t=o.
X>=r.X and o.Y>=r.Y and o.X<=r.X+s.X and o.Y<=r.Y+s.Y if not t or not q.Visible
or q.Parent==nil or k.popover:isOpen()then clear()end end return l end return d
end function a.x()local b=a.cache.x if not b then b={c=__modImpl()}a.cache.x=b
end return b.c end end do local function __modImpl()local b=a.m()local c=a.f()
local d=a.j()local e=a.b()local f=a.l()local g=a.p()local h={}local i=6 local j=
18 local k=44 local l=18 local m=2 local n=360 local o=100 local p=24 local q=28
local r=30 local s={}s.__index=s local function heightOf(t,u)local v=t.kind if v
=='slider'then return b.SLIDER_HEIGHT end if v=='stat'then return 36 end if v==
'divider'then return if t.label==''then 8 else 28 end if v=='label'and not t.
addons then if not t.spec.wrap then return 30 end if t._measured then return t.
_measured end local w=string.gsub(t.label,'<[^>]+>','')local x=math.ceil(d.
width('text',w,16)/math.max(u-2*f.PAD,40))return x*21+12 end if v=='toggle'and t
.spec.primary then return b.MASTER_HEIGHT end return f.HEIGHT end function s.
nextId(t)t._ids+=1 return t._ids end function s._register(t,u,v)u._relayout=
function()t:_invalidate()end t.window:_registerElement(u,t,v)end function s.
_invalidate(t)if t._dirty then return end t._dirty=true task.defer(function()t.
_dirty=false if not t.destroyed then t:layout(not t._quiet)t._quiet=false end
end)end function s.section(t,u)local v=g.new(t,u)table.insert(t.sections,v)t:
_invalidate()return v end function s.tabset(t)local u=g.new(t,'')u.tabNames={}u.
activeTab=1 table.insert(t.sections,u)local v={}function v.tab(w,x)table.insert(
u.tabNames,x)local y=#u.tabNames local z=u:when(function()return u.activeTab==y
end)z.title=x local A=t._headers[u]if A then A:Destroy()t._headers[u]=nil end t:
_invalidate()return z end return v end function s.tabs(t,u)local v=t:tabset()
local w={}for x,y in u do table.insert(w,v:tab(y))end return w end function s.
hero(t,u)t.window:_setPerson(u)return{set=function(v,w,x)u.title=w or u.title u.
text=x or u.text t.window:_setPerson(u)end}end local function buildHeader(t,u)
local v=t.window.ctx local w=v.theme local x=c('Frame',{Name='Header',Parent=t.
canvas})if u.tabNames then local y={}local z=f.PAD for A,B in u.tabNames do
local C=math.ceil(d.width('display',B,15))+18 local D=c('TextButton',{Position=
UDim2.fromOffset(z,0),Size=UDim2.new(0,C,1,-6),TextSize=15,Text=B,TextXAlignment
=Enum.TextXAlignment.Left,Parent=x})w:type(D,'display')y[A]=D D.Activated:
Connect(function()u.activeTab=A for E,F in y do w:paint(F,'TextColor3',if E==u.
activeTab then'text'else'faint')end t:_invalidate()end)w:paint(D,'TextColor3',if
A==u.activeTab then'text'else'faint')z+=C end else local y=c('TextLabel',{
Position=UDim2.fromOffset(f.PAD,0),Size=UDim2.new(1,-2*f.PAD,1,-6),TextSize=15,
TextYAlignment=Enum.TextYAlignment.Bottom,Text=u.title,Parent=x})w:type(y,
'display')w:paint(y,'TextColor3','text')end return x end function s.layout(t,u)
local v=t.frame if v==nil then return end t._live=u==true and t._settled==true
and t.active local w=t.window.ctx.uiScale()local x=v.AbsoluteSize.X/w if x<1
then return end local y=i local z={}local A=t._expansion if A then A.y=nil end
local B=false for C,D in t.sections do local E={}for F,G in D.rows do if G:
shown()then table.insert(E,G)end end if#E>0 or D.tabNames then if(D.title~=''or
D.tabNames)and not D.masterElement then if B then y+=l-m end table.insert(z,{
section=D,y=y,height=k})y+=k end for F,G in E do local H=heightOf(G,x)table.
insert(z,{el=G,y=y,height=H})y+=H if A and A.el==G then A.y=y y+=A.height end
end local F=D.masterElement~=nil and#E==1 y+=if F then m else l B=F end end if A
and A.y==nil then t._live=false t:collapse()return end local C=y+j v.CanvasSize=
UDim2.fromOffset(0,C)local D=math.max(C-v.AbsoluteSize.Y/w,0)if t._scrollTarget
and t._scrollTarget>D then t._scrollTarget=D t._scroll:snap(D)end t.
_contentHeight=C t._placements=z t._width=x if A then local E=UDim2.fromOffset(0
,A.y or 0)if t._live then A.at:to(E)else A.at:snap(E)end A.frame.Size=UDim2.new(
1,0,0,A.frame.Size.Y.Offset)end t:_applyPlacements()t:_materialize(true)t:
_refreshThumb()if t.active then t.window:_contentChanged(C,t._live)end t._live=
false t._settled=t._settled or t.active end local function growTo(t,u,v)if t.
_grow==nil then t._grow=t:own(e.prop(t.root,'Size',q))end t._grow:to(UDim2.new(1
,0,0,u),v)end local function setHeight(t,u)local v=UDim2.new(1,0,0,u)if t._grow
then t._grow:snap(v)else t.root.Size=v end end function s._applyPlacements(t)
local u={}for v,w in t._placements do if w.section then u[w.section]=true local
x=t._headers[w.section]if x then x.Visible=true x.Size=UDim2.new(1,0,0,w.height)
local y=UDim2.fromOffset(0,w.y)local z=t._headerSlides[w.section]if t._live and
x.Position~=y then if z==nil then z=e.prop(x,'Position',q)t._headerSlides[w.
section]=z end z:to(y)elseif z then z:snap(y)else x.Position=y end end else u[w.
el]=true local x=t._views[w.el]if x then t:_place(x,w)end end end for v,w in t.
_headers do if not u[v]then w.Visible=false end end for v,w in t._views do if
not u[v]and w.root.Visible and not w._folding then if t._live then w._folding=
true growTo(w,0,function()w._folding=false w.root.Visible=false end)else w.root.
Visible=false end end end end function s._place(t,u,v)local w=u.root local x=
UDim2.fromOffset(0,v.y)local y=t._live local z=y and not w.Visible local A=u.
_folding==true u._folding=false w.Visible=true if z then setHeight(u,0)growTo(u,
v.height)elseif A then growTo(u,v.height)else setHeight(u,v.height)end if y and
not z and w.Position~=x then if u._slide==nil then u._slide=u:own(e.prop(w,
'Position',q))end u._slide:to(x)elseif u._slide then u._slide:snap(x)else w.
Position=x end end function s._materialize(t,u)local v=t.frame local w=t.
_placements if v==nil or w==nil or not t.active then return end local x=t.window
.ctx.uiScale()local y=v.CanvasPosition.Y/x if not u and t._lastSync and math.
abs(y-t._lastSync)<n/3 then return end t._lastSync=y local z,A=y-n,y+v.
AbsoluteSize.Y/x+n for B,C in w do local D=C.y if D+C.height>=z and D<=A then if
C.section then if t._headers[C.section]==nil then local E=buildHeader(t,C.
section)E.Position=UDim2.fromOffset(0,D)E.Size=UDim2.new(1,0,0,C.height)t.
_headers[C.section]=E end elseif t._views[C.el]==nil then local E,F=xpcall(b.
build,debug.traceback,t.window.ctx,C.el)if E then F.root.Position=UDim2.
fromOffset(0,D)F.root.Size=UDim2.new(1,0,0,if t._live then 0 else C.height)F.
root.Parent=t.canvas t._views[C.el]=F t._rows[F.root]=C.el if t._live then
growTo(F,C.height)end else warn('sottUI: row '..tostring(C.el.id)..' failed: '..
tostring(F))end end end end end function s.expand(t,u,v,w)local x=u local y=nil
while x and x~=t.canvas do if t._rows[x]then y=t._rows[x]break end x=x.Parent
end if y==nil then return false end local z=t._expansion t:collapse()if z and z.
el==y then return true end local A=t.window.ctx local B=c('Frame',{Name=
'Expansion',Size=UDim2.new(1,0,0,0),BackgroundTransparency=0,ClipsDescendants=
true,ZIndex=2,Parent=t.canvas})A.theme:paint(B,'BackgroundColor3','surface')
local C=c('Frame',{Size=UDim2.new(1,0,0,v),Parent=B})local D={el=y,frame=B,
height=v,at=e.prop(B,'Position',q),grow=e.prop(B,'Size',r)}t._expansion=D local
E={close=function()if t._expansion==D then t:collapse()end end,resize=function(E
)if t._expansion~=D or D.height==E then return end D.height=E C.Size=UDim2.new(1
,0,0,E)D.grow:to(UDim2.new(1,0,0,E))t:_invalidate()end,onKey=function(E)D.onKey=
E end,onRefresh=function(E)D.onRefresh=E end}t:layout(true)D.at:snap(UDim2.
fromOffset(0,D.y or 0))w(C,E)D.grow:to(UDim2.new(1,0,0,v))local F=A.uiScale()
local G=t.frame.AbsoluteSize.Y/F local H=t._scrollTarget or t.frame.
CanvasPosition.Y/F local I=(D.y or 0)+v if I>H+G then t:scrollTo(I-G+12)end
return true end function s.collapse(t)local u=t._expansion if u==nil then return
end t._expansion=nil u.grow:to(UDim2.new(1,0,0,0),function()u.grow:destroy()u.at
:destroy()u.frame:Destroy()end)t:layout(true)end function s.expansionKey(t,u)
local v=t._expansion if v==nil then return false end if u=='Escape'then t:
collapse()return true end if v.onKey and(u=='Up'or u=='Down'or u=='Return')then
v.onKey(u)return true end return false end function s.pointerInExpansion(t,u)
local v=t._expansion if v==nil then return false end local w,x=v.frame.
AbsolutePosition,v.frame.AbsoluteSize return u.X>=w.X and u.Y>=w.Y and u.X<=w.X+
x.X and u.Y<=w.Y+x.Y end function s._refreshThumb(t)local u=t.thumb if u==nil
then return end local v=t.window.ctx.uiScale()local w=t.frame.AbsoluteSize.Y/v
local x=t._contentHeight or 0 if x<=w+1 or not t.active then u.Visible=false
return end u.Visible=true local y=math.max(w*w/x,40)local z=w-y local A=t.frame.
CanvasPosition.Y/v/math.max(x-w,1)u.Size=UDim2.new(0,2,0,y)u.Position=UDim2.new(
1,-4,0,A*z)end function s.scrollTo(t,u,v)local w=t.frame if w==nil then return
end local x=t.window.ctx.uiScale()local y=math.max((t._contentHeight or 0)-w.
AbsoluteSize.Y/x,0)local z=math.clamp(u,0,y)t._scrollTarget=z if v then t.
_scroll:snap(z)else t._scroll:to(z)end end function s.wheel(t,u)if t.frame==nil
or t.frame.ScrollingEnabled then return end local v=t._scrollTarget or t.frame.
CanvasPosition.Y/t.window.ctx.uiScale()t:scrollTo(v-u*o)end function s.rowY(t,u)
if t._placements==nil then t:layout()end for v,w in t._placements or{}do if w.el
==u then return w.y end end return nil end function s.viewOf(t,u)return t._views
[u]end function s.mount(t,u)if t.frame then return end local v=t.window.ctx
local w=c('ScrollingFrame',{Name=t.name,Size=UDim2.fromScale(1,1),Visible=false,
ScrollingEnabled=v.touch,Parent=u})local x=c('Frame',{Name='Canvas',Size=UDim2.
fromScale(1,1),Parent=w})local y=c('Frame',{Name='Thumb',BackgroundTransparency=
0,Visible=false,ZIndex=5,Parent=u})v.theme:paint(y,'BackgroundColor3',
'lineStrong')t.frame=w t.canvas=x t.thumb=y t._scroll=e.new(0,p,function(z)w.
CanvasPosition=Vector2.new(0,z*v.uiScale())end)w:GetPropertyChangedSignal(
'CanvasPosition'):Connect(function()t:_materialize()t:_refreshThumb()end)local z
=0 w:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()local A=w.
AbsoluteSize.X if A~=z then z=A t._quiet=true t:_invalidate()else t:
_materialize(true)t:_refreshThumb()end end)end function s.setActive(t,u)t.active
=u if t.frame then t.frame.Visible=u if not u then t.thumb.Visible=false end end
if u then t:layout()end end function s.destroy(t)t.destroyed=true for u,v in t.
_views do v.destroy()end t._views={}for u,v in t._headerSlides do v:destroy()end
if t._expansion then t._expansion.grow:destroy()t._expansion.at:destroy()end if
t._scroll then t._scroll:destroy()end if t.frame then t.frame:Destroy()t.thumb:
Destroy()end end function h.new(t,u)return setmetatable({name=u,window=t,
sections={},active=false,destroyed=false,_ids=0,_dirty=false,_headers={},
_headerSlides={},_views={},_rows={},_placements=nil},s)end return h end function
a.y()local b=a.cache.y if not b then b={c=__modImpl()}a.cache.y=b end return b.c
end end do local function __modImpl()local b=a.f()local c=a.b()local d=a.h()
local e={}local f=420 local g=46 local h=68 local i=7 local j=34 local k=48
local function describe(l)local m=l._pageName or''if l.kind=='toggle'then return
(if l.value then'On, 'else'Off, ')..m end if l.kind=='slider'then return
tostring(l.value)..(l.spec.suffix or'')..', '..m end if l.kind=='dropdown'and
not l.spec.multi and l.value~=nil then return tostring((l.spec.display or
tostring)(l.value))..', '..m end return m end function e.new(l,m,n,o)local p=l.
theme local q={}local r=false local s,t,u,v local w={}local x={}local y=1 local 
function close()if not r then return end r=false s:Destroy()local z,A=t,u A.
speed=k A:to(UDim2.fromOffset(f,0),function()A:destroy()z:Destroy()end)table.
clear(x)end local function draw()if not r then return end for z,A in x do local
B=w[z]if B then A.root.Visible=true A.name.Text=B.label A.where.Text=describe(B)
A.root.BackgroundTransparency=if z==y then 0 else 1 p:paint(A.name,'TextColor3',
if z==y then'text'else'muted')p:paint(A.where,'TextColor3','faint')else A.root.
Visible=false end end local z=math.min(#w,i)local A=h+(if z>0 then z*g+10 else 0
)u:to(UDim2.fromOffset(f,A))end local function run(z)if z==nil then return end
close()if z.kind=='toggle'and not z.disabled then z:set(not z.value)l.notify({
title=z.label,text=if z.value then'On'else'Off',seconds=2})else o(z)end end
local function query()local z=v.Text if z==''then w={}for A,B in n()do if B.kind
=='toggle'and B.value==true then table.insert(w,B)if#w==i then break end end end
else w=d.settings(z,n(),i)end y=1 draw()end function q.toggle(z)if r then close(
)return end r=true f=l.paletteWidth()s=b('TextButton',{Size=UDim2.fromScale(1,1)
,BackgroundTransparency=1,ZIndex=40,Parent=m})s.MouseButton1Down:Connect(close)t
=b('Frame',{Name='Palette',Position=l.paletteAt(),Size=UDim2.fromOffset(f,0),
BackgroundTransparency=0,ClipsDescendants=true,Active=true,ZIndex=41,Parent=m})p
:paint(t,'BackgroundColor3','surface')local A=b('UIStroke',{ApplyStrokeMode=Enum
.ApplyStrokeMode.Border,Parent=t})p:paint(A,'Color','lineStrong')u=c.prop(t,
'Size',j)v=b('TextBox',{Position=UDim2.fromOffset(18,0),Size=UDim2.new(1,-36,0,h
),TextSize=22,Text='',PlaceholderText='Find a setting',ZIndex=42,Parent=t})p:
type(v,'display')p:paint(v,'TextColor3','text')p:paint(v,'PlaceholderColor3',
'faint')for B=1,i do local C=b('TextButton',{Position=UDim2.fromOffset(6,h+(B-1)
*g+2),Size=UDim2.new(1,-12,0,g),Visible=false,ZIndex=42,Parent=t})p:paint(C,
'BackgroundColor3','raised')local D=b('TextLabel',{Position=UDim2.fromOffset(12,
0),Size=UDim2.new(0.6,-12,1,0),TextSize=16,TextTruncate=Enum.TextTruncate.AtEnd,
ZIndex=43,Parent=C})p:type(D,'text',true)p:paint(D,'TextColor3','text')local E=
b('TextLabel',{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,0),Size=
UDim2.new(0.4,-12,1,0),TextSize=16,TextTruncate=Enum.TextTruncate.AtEnd,
TextXAlignment=Enum.TextXAlignment.Right,ZIndex=43,Parent=C})p:type(E,'text')p:
paint(E,'TextColor3','faint')x[B]={root=C,name=D,where=E}C.MouseEnter:Connect(
function()if y~=B then y=B draw()end end)C.Activated:Connect(function()run(w[B])
end)end v:GetPropertyChangedSignal('Text'):Connect(query)v.FocusLost:Connect(
function(B)if B then run(w[y])end end)query()v:CaptureFocus()end function q.
isOpen(z)return r end q.close=close function q.key(z,A)if not r then return
false end if A=='Escape'then close()return true end if A=='Down'or A=='Up'then
if#w>0 then y=math.clamp(y+(if A=='Down'then 1 else-1),1,#w)draw()end return
true end return false end return q end return e end function a.z()local b=a.
cache.z if not b then b={c=__modImpl()}a.cache.z=b end return b.c end end do
local function __modImpl()local b=a.f()local c=UDim2.fromOffset(16,72)local d=44
return function(e,f,g)local h=b('TextButton',{Name='Open',Position=c,Size=UDim2.
fromOffset(d,d),BackgroundTransparency=0,TextSize=24,Text='s',Visible=false,
ZIndex=50,Parent=e})f:type(h,'display')f:paint(h,'BackgroundColor3','accent')f:
paint(h,'TextColor3','onAccent')h.Activated:Connect(g)return h end end function
a.A()local b=a.cache.A if not b then b={c=__modImpl()}a.cache.A=b end return b.c
end end do local function __modImpl()local b=a.n()local c={}local function rgb(d
)return Color3.fromRGB(bit32.band(bit32.rshift(d,16),255),bit32.band(bit32.
rshift(d,8),255),bit32.band(d,255))end local d={base=rgb(0x7100d),surface=rgb(
0x141c18),raised=rgb(0x1e2b25),line=rgb(0x1a2d27),lineStrong=rgb(0x2f4a40),text=
rgb(0xebe8da),muted=rgb(0xb4c2b8),faint=rgb(0x5f756b),accent=rgb(0x7ee0c4),
accentHover=rgb(0x9bebd4),accentDim=rgb(0x1f4a3e),onAccent=rgb(0xb1a13),danger=
rgb(0xe5604d)}local e='rbxasset://fonts/families/BuilderSans.json'local f=
'rbxasset://fonts/families/RobotoCondensed.json'local g={}g.__index=g function c
.defaults()return table.clone(d)end function c.new(h)local i=(c.defaults())for j
,k in(h or{})do i[j]=k end local j={tokens=i,fonts={text=e,display=f},changed=b.
new(),_paints={},_types={},_count=0}return((setmetatable(j,g)))end local h=2000
local function sweep(i)for j in i._paints do if j.Parent==nil then i._paints[j]=
nil i._types[j]=nil end end for j in i._types do if j.Parent==nil then i._types[
j]=nil end end end function g.paint(i,j,k,l)local m=i._paints[j]if m==nil then m
={}i._paints[j]=m i._count+=1 if i._count%h==0 then task.defer(sweep,i)end end m
[k]=l j[k]=i.tokens[l]end function g.face(i,j,k)if j=='display'then return Font.
new(i.fonts.display,Enum.FontWeight.ExtraBold)end return Font.new(i.fonts.text,
if k then Enum.FontWeight.Medium else Enum.FontWeight.Regular)end function g.
type(i,j,k,l)i._types[j]={family=k,medium=l==true}j.FontFace=i:face(k,l)end
function g.forget(i,j)i._paints[j]=nil i._types[j]=nil end function g.apply(i,j)
for k,l in j do i.tokens[k]=l end for k,l in i._paints do for m,n in l do pcall(
function()k[m]=i.tokens[n]end)end end i.changed:fire()end function g.setFonts(i,
j,k)i.fonts.text=j or i.fonts.text i.fonts.display=k or i.fonts.display for l,m
in i._types do pcall(function()l.FontFace=i:face(m.family,m.medium)end)end end
return c end function a.B()local b=a.cache.B if not b then b={c=__modImpl()}a.
cache.B=b end return b.c end end do local function __modImpl()local b=a.b()local
c={}local d=26 function c.new(e)local f={}return function(g,h,i,j)local k=f[g]if
k==nil then k={}f[g]=k end local l=k[h]if l==nil then l=b.prop(g,h,j or d)k[h]=l
end l:to(e.tokens[i])end end return c end function a.C()local b=a.cache.C if not
b then b={c=__modImpl()}a.cache.C=b end return b.c end end do local function 
__modImpl()local b=a.q()local c=a.a()local d=a.r()local e=a.s()local f=a.u()
local g=a.v()local h=a.t()local i=a.f()local j=a.j()local k=a.b()local l=a.w()
local m=a.x()local n=a.y()local o=a.z()local p=a.p()local q=a.A()local r=a.n()
local s=a.B()local t=a.C()local u={}local v='main'local w=
[[https://raw.githubusercontent.com/interestng/sottUI/%s/fonts/]]local x=62
local y=46 local z=92 local A=28 local B=8 local C=3 local D=12 local E=4 local
F=30 local G=18 local H=30 local I=30 local J=420 local K=340 local L=640 local
M=22 local N=32 local O=22 local P=22 local Q=34 local R=17 local S=12 local T=5
local U=72 local V={}V.__index=V local function randomName()local W=table.
create(S)for X=1,S do W[X]=string.char(math.random(97,122))end return table.
concat(W)end local function encode(W)return c.service('HttpService'):JSONEncode(
W)end local function decode(W)local X,Y=pcall(function()return c.service(
'HttpService'):JSONDecode(W)end)return if X then Y else nil end function V.
_registerElement(W,X,Y,Z)X._pageName=Y.name X._page=Y if Z then if W.elements[X.
id]then error('sottUI: element id used twice: '..X.id,3)end W.elements[X.id]=X
end if X.kind~='divider'and X.kind~='label'and X.kind~='stat'then table.insert(W
.ordered,X)end if X.kind=='toggle'then X:on(function()W:_markRail()end)W:
_markRail()end end function V._markRail(W)if W._railQueued then return end W.
_railQueued=true task.defer(function()W._railQueued=false if W.destroyed then
return end local X=0 for Y,Z in W.ordered do if Z.kind=='toggle'and Z.value==
true then X+=1 end end X=math.min(X,F)local Y=W._railTicks for Z=1,math.max(X,#Y
)do local _=Y[Z]if _==nil then _=i('Frame',{Size=UDim2.fromOffset(T,D),
BackgroundTransparency=0,Parent=W._handleBar})W.ctx.theme:paint(_,
'BackgroundColor3','accent')Y[Z]=_ end _.Visible=Z<=X _.Position=UDim2.
fromOffset(0,(Z-1)*(D+E))end local Z=math.max(X*(D+E)-E,D)W._handleBar.Size=
UDim2.fromOffset(T,Z)W._handleBar.BackgroundTransparency=if X==0 then 0 else 1 W
._handle.Size=UDim2.fromOffset(W._handle.Size.X.Offset,Z+24)end)end function V.
_contentChanged(W,X,Y)local Z=W._headHeight or y local _=W._gui.AbsoluteSize.Y/W
._scale.Scale local aa=math.min(Z+X+B,_)local ab=UDim2.new(1,-x,0,aa)if Y then W
._columnSize:to(ab)else W._columnSize:snap(ab)end end function V._syncMarker(aa,
ab)local W=aa._navItems[aa.current]if W==nil then return end local X=W.Position.
Y.Offset local Y=X+W.Size.Y.Offset if ab then aa._edgeTop:snap(X)aa._edgeBottom:
snap(Y)return end local Z=Y>aa._edgeBottom.target aa._edgeTop.speed=if Z then R
else Q aa._edgeBottom.speed=if Z then Q else R aa._edgeTop:to(X)aa._edgeBottom:
to(Y)end function V._setPerson(aa,ab)aa._person=ab aa:_syncHead()end function V.
_syncHead(aa)local ab=aa.pages[aa.current]if ab==nil then return end local W=aa.
_person local X=ab.name=='Home'and W~=nil aa._headTitle.Visible=X if X then aa.
_headTitle.Text=W.title aa._headLine.RichText=true aa._headLine.Text=W.text or''
aa._headLine.Position=UDim2.fromOffset(18,z-34)else aa._headLine.RichText=false
aa._headLine.Text=aa._subtitleText or''aa._headLine.Position=UDim2.fromOffset(18
,12)end local Y=if X then z else y aa._headHeight=Y aa._head.Size=UDim2.new(1,0,
0,Y)aa._headRule.Position=UDim2.fromOffset(0,Y-1)aa._body.Position=UDim2.
fromOffset(0,Y)aa._body.Size=UDim2.new(1,0,1,-Y)end function V.page(aa,ab)local
W=n.new(aa,ab)table.insert(aa.pages,W)local X=#aa.pages local Y=aa.ctx.theme
local Z=math.ceil(j.width('display',ab,G))+H local _=i('TextButton',{Name=ab,
Position=UDim2.fromOffset(0,aa._navUsed),Size=UDim2.fromOffset(x,Z),Parent=aa.
_navList})aa._navUsed+=Z aa._navList.CanvasSize=UDim2.fromOffset(0,aa._navUsed)
local ac=i('TextLabel',{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.
fromScale(0.5,0.5),Size=UDim2.fromOffset(Z,x),Rotation=-90,TextSize=G,Text=ab,
TextXAlignment=Enum.TextXAlignment.Center,Parent=_})Y:type(ac,'display')Y:paint(
ac,'TextColor3','faint')aa._navItems[X]=_ aa._navWords[X]=ac _.Activated:
Connect(function()aa:show(X)end)_.MouseEnter:Connect(function()if aa.current~=X
then aa.ctx.tint(ac,'TextColor3','muted')end end)_.MouseLeave:Connect(function()
if aa.current~=X then aa.ctx.tint(ac,'TextColor3','faint')end end)W:mount(aa.
_pageHost)if aa.current==nil then aa:show(X,true)end return W end function V.
show(aa,ab,ac)local W=aa.pages[ab]if W==nil or aa.current==ab then return end aa
.ctx.hover.clear()aa.ctx.popover:close()aa.keys:cancel()local X=aa.ctx.tint
local Y=aa.pages[aa.current]if Y then Y:setActive(false)X(aa._navWords[aa.
current],'TextColor3','faint')end local Z=aa.current==nil or ab>aa.current aa.
current=ab X(aa._navWords[ab],'TextColor3','text')W:setActive(true)aa:_syncHead(
)aa:_syncMarker(ac)aa:_saveState()W:layout()if ac then return end local _=if Z
then 1 else-1 aa._pageSlide:snap(UDim2.fromOffset(0,P*_))aa._pageSlide:to(UDim2.
new())aa._wipe.Visible=true aa._wipeEdge.AnchorPoint=Vector2.new(0,if Z then 1
else 0)aa._wipeEdge.Position=UDim2.fromScale(0,if Z then 1 else 0)aa._wipeAt:
snap(UDim2.fromScale(0,0))aa._wipeAt:to(UDim2.fromScale(0,-1.02*_),function()aa.
_wipe.Visible=false end)end function V.showPage(aa,ab)for ac,W in aa.pages do if
W.name==ab then aa:show(ac)return end end end function V.reveal(aa,ab)local ac=
ab._page if ac==nil then return end if not aa.isOpen then aa:setOpen(true)end aa
.ctx.popover:close()aa:showPage(ac.name)local W=ab.host or ab local X=ab.section
and(ab.section._root or ab.section)if X and X.masterElement and X.masterElement.
value~=true and W~=X.masterElement then X.peeking=true local Y=ac:viewOf(X.
masterElement)if Y then Y.refresh()end end ac:layout()local Y=ac:rowY(W)if Y
then ac:scrollTo(Y-60)task.delay(0.26,function()local Z=ac:viewOf(W)if Z and Z.
root.Parent then Z:flash()end end)end end function V.setOpen(aa,ab)if aa.isOpen
==ab or aa.destroyed then return end aa.isOpen=ab if aa._opener then aa._opener.
Visible=not ab end aa.ctx.hover.clear()aa.ctx.popover:close()aa._palette.close()
aa.ctx.tooltip:hide()aa.keys:cancel()if not ab and aa._dialogClose then aa.
_dialogClose()end local ac=aa:_panelWidth()if ab then aa._root.Visible=true aa.
_modal.Visible=true aa._handle.Visible=false aa:_guardCursor(true)aa._slide.
speed=M aa._slide:to(UDim2.fromOffset(0,aa._rootY))else aa._modal.Visible=false
aa:_guardCursor(false)aa._slide.speed=N aa._slide:to(UDim2.fromOffset(-ac,aa.
_rootY),function()if not aa.isOpen then aa._root.Visible=false aa._handle.
Visible=true end end)end aa.visibilityChanged:fire(ab)end function V._panelWidth
(aa)return(x+aa.width)*aa._scale.Scale+2 end function V._guardCursor(aa,ab)local
ac=c.service('UserInputService')if ab then aa._gameCursor=ac.MouseIconEnabled ac
.MouseIconEnabled=true if aa._cursorGuard==nil then aa._cursorGuard=ac:
GetPropertyChangedSignal('MouseIconEnabled'):Connect(function()if not ac.
MouseIconEnabled then aa._gameCursor=false ac.MouseIconEnabled=true end end)end
else if aa._cursorGuard then aa._cursorGuard:Disconnect()aa._cursorGuard=nil end
if aa._gameCursor~=nil then ac.MouseIconEnabled=aa._gameCursor aa._gameCursor=
nil end end end function V.toggle(aa)aa:setOpen(not aa.isOpen)end function V.
notify(aa,ab)if aa.destroyed then return end aa.ctx.notify(ab)end function V.
setTheme(aa,ab)aa.ctx.theme:apply(ab)end function V.setScale(aa,ab)aa._scale.
Scale=math.clamp(ab,0.7,1.5)aa:_fit()if not aa.isOpen then aa._slide:snap(UDim2.
fromOffset(-aa:_panelWidth(),aa._rootY))end local ac=aa.pages[aa.current]if ac
and ac._scrollTarget then ac:scrollTo(ac._scrollTarget,true)end aa:_saveState()
end function V.setSubtitle(aa,ab)aa._subtitleText=ab aa:_syncHead()end function
V._fit(aa)local ab=aa._gui.AbsoluteSize.Y/aa._scale.Scale aa._root.Size=UDim2.
fromOffset(x+aa.width,ab)end function V._saveState(aa)local ab=aa._files if ab==
nil or aa._stateFile==nil or aa._stateQueued then return end aa._stateQueued=
true task.delay(0.5,function()aa._stateQueued=false if aa.destroyed then return
end local ac=aa.pages[aa.current]ab.write(aa._stateFile,encode({w=aa.width,page=
ac and ac.name,scale=aa._scale.Scale}))end)end function V.restorePage(aa)local
ab=aa._savedPage if ab then aa._savedPage=nil for ac,W in aa.pages do if W.name
==ab then aa:show(ac,true)return end end end end function V.dialog(aa,ab,ac)if
aa.destroyed then return false end b.open(aa,ab,ac)return true end function V.
find(aa,ab)return aa.elements[ab]end function V.snapshot(aa)local ab={}for ac,W
in aa.elements do if W.saved then local X=W.value if W.kind=='color'then X={hex=
X.color:ToHex(),alpha=X.alpha}elseif W.kind=='key'then X={key=X.key,mode=X.mode,
modifiers=X.modifiers,toggled=W.toggled==true}end ab[ac]=X end end return ab end
function V.restore(aa,ab)for ac,W in ab do local X=aa.elements[ac]if X and X.
saved then if X.kind=='color'and type(W)=='table'then X:set({color=Color3.
fromHex(W.hex or'ffffff'),alpha=W.alpha})elseif X.kind=='key'and type(W)==
'table'then X:set(W)X.toggled=W.toggled==true else X:set(W)end end end end
function V.destroy(aa)if aa.destroyed then return end aa.destroyed=true aa:
_guardCursor(false)aa.ctx.notifications:destroy()for ab,ac in aa.pages do ac:
destroy()end aa.ctx.input:destroy()aa._maid:clean()aa.visibilityChanged:clear()
if aa._registry and aa._registry.current==aa then aa._registry.current=nil end
end function u.new(aa)local ab=aa._registry if ab and ab.current then ab.current
:destroy()end local ac=h.new()local W=s.new(aa.theme)local X=f.new()local Y=c.
service('UserInputService')local Z=aa.touch==true or(Y.TouchEnabled and not Y.
MouseEnabled)local _=i('ScreenGui',{Name=randomName(),IgnoreGuiInset=true,
ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=aa.
displayOrder or 10000})c.protect(_)_.Parent=c.guiParent()ac:add(_)local ad=c.
files()local ae=aa.folder or'sottui_edge'local af=aa.stateFile or(ae..
'/window.json')local ag=nil if ad then ad.folder(ae)local ah=ad.read(af)ag=ah
and decode(ah)end if type(ag)~='table'then ag={}end local ah=_.AbsoluteSize
local ai=tonumber(ag.scale)or(if ah.Y<620 then 0.85 else 1)local aj=math.clamp(
tonumber(ag.w)or J,K,L)local ak=-(x+aj)*ai-2 local al=i('Frame',{Name='Root',
Position=UDim2.fromOffset(ak,0),Size=UDim2.fromOffset(x+aj,ah.Y/ai),Parent=_})
local am=i('UIScale',{Scale=ai,Parent=al})local an=i('Frame',{Name='Layer',Size=
UDim2.fromScale(1,1),ZIndex=100,Parent=_})local ao=i('TextButton',{Name='Modal',
Size=UDim2.fromOffset(0,0),Modal=true,Visible=false,Parent=al})local ap=i(
'Frame',{Name='Spine',Size=UDim2.new(0,x,1,0),BackgroundTransparency=0,
ClipsDescendants=true,Parent=al})W:paint(ap,'BackgroundColor3','surface')local
aq=math.ceil(j.width('display',aa.title or'sottoro',G))+H local ar=i('Frame',{
Size=UDim2.fromOffset(x,aq),Parent=ap})local as=i('TextLabel',{AnchorPoint=
Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(aq,
x),Rotation=-90,TextSize=G,Text=aa.title or'sottoro',TextXAlignment=Enum.
TextXAlignment.Center,Parent=ar})W:type(as,'display')W:paint(as,'TextColor3',
'accent')local at=i('ScrollingFrame',{Name='Nav',Position=UDim2.fromOffset(0,aq)
,Size=UDim2.new(1,0,1,-(aq+x)),ScrollingEnabled=true,ScrollingDirection=Enum.
ScrollingDirection.Y,Parent=ap})local au=i('Frame',{Name='Marker',Position=UDim2
.new(0,0,0,0),Size=UDim2.new(0,4,0,0),BackgroundTransparency=0,ZIndex=3,Parent=
at})W:paint(au,'BackgroundColor3','accent')local av=i('Frame',{AnchorPoint=
Vector2.new(0,1),Position=UDim2.fromScale(0,1),Size=UDim2.fromOffset(x,x),
BackgroundTransparency=0,ClipsDescendants=true,Parent=ap})W:paint(av,
'BackgroundColor3','accent')local aw=c.service('Players').LocalPlayer if aw then
i('ImageLabel',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
BorderSizePixel=0,Image=string.format(
'rbxthumb://type=AvatarBust&id=%d&w=150&h=150',aw.UserId),Parent=av})end local
ax=i('Frame',{Name='Column',Position=UDim2.fromOffset(x,0),Size=UDim2.new(1,-x,1
,0),BackgroundTransparency=0,ClipsDescendants=true,Active=true,Parent=al})W:
paint(ax,'BackgroundColor3','base')local ay=i('Frame',{Name='Rail',Size=UDim2.
new(0,C,1,0),BackgroundTransparency=0,Parent=ax})W:paint(ay,'BackgroundColor3',
'line')local az=i('Frame',{Name='Head',Size=UDim2.new(1,0,0,y),Parent=ax})local
aA=i('TextLabel',{Position=UDim2.fromOffset(18,12),Size=UDim2.new(1,-60,0,I+8),
TextSize=I,TextTruncate=Enum.TextTruncate.AtEnd,Parent=az})W:type(aA,'display')W
:paint(aA,'TextColor3','text')local aB=i('TextLabel',{Position=UDim2.fromOffset(
18,12),Size=UDim2.new(1,-36,0,22),TextSize=16,TextTruncate=Enum.TextTruncate.
AtEnd,Parent=az})W:type(aB,'text')W:paint(aB,'TextColor3','muted')local aC=i(
'Frame',{Position=UDim2.fromOffset(C,y-1),Size=UDim2.new(1,-C,0,1),
BackgroundTransparency=0,Parent=ax})W:paint(aC,'BackgroundColor3','line')local
aD=i('Frame',{Name='Body',Position=UDim2.fromOffset(0,y),Size=UDim2.new(1,0,1,-y
),ClipsDescendants=true,ZIndex=2,Parent=ax})local aE=i('Frame',{Name='Pages',
Size=UDim2.fromScale(1,1),Parent=aD})local aF=i('Frame',{Name='Wipe',Size=UDim2.
fromScale(1,1),BackgroundTransparency=0,Visible=false,ZIndex=8,Parent=aD})W:
paint(aF,'BackgroundColor3','base')local aG=i('Frame',{Size=UDim2.new(1,0,0,3),
BackgroundTransparency=0,ZIndex=9,Parent=aF})W:paint(aG,'BackgroundColor3',
'accent')local aH=i('TextButton',{Name='Handle',AnchorPoint=Vector2.new(0,0.5),
Position=UDim2.new(0,0,0.5,0),Size=UDim2.fromOffset(if Z then 28 else 16,U+24),
Visible=false,Parent=_})local aI=i('Frame',{AnchorPoint=Vector2.new(0,0.5),
Position=UDim2.fromScale(0,0.5),Size=UDim2.fromOffset(T,U),
BackgroundTransparency=0,Parent=aH})W:paint(aI,'BackgroundColor3','accent')local
aJ=i('TextButton',{Name='Grip',AnchorPoint=Vector2.new(1,0),Position=UDim2.
fromScale(1,0),Size=UDim2.new(0,8,1,0),ZIndex=6,Parent=ax})local aK=
setmetatable({ctx=nil,pages={},elements={},ordered={},current=nil,isOpen=false,
destroyed=false,width=aj,visibilityChanged=r.new(),_maid=ac,_gui=_,_root=al,
_rootY=0,_layer=an,_modal=ao,_scale=am,_navList=at,_navItems={},_navWords={},
_navUsed=0,_pageHost=aE,_wipe=aF,_wipeEdge=aG,_handle=aH,_headTitle=aA,_head=az,
_headRule=aC,_body=aD,_handleBar=aI,_railTicks={},_headLine=aB,_subtitleText=aa.
subtitle,_files=ad,_stateFile=af,_savedPage=ag.page,_dialogIds=0,_registry=ab},V
)if ab then ab.current=aK end local aL={theme=W,input=X,touch=Z,assets={},glyph=
e.new(W),tint=t.new(W),uiScale=function()return am.Scale end,popoverTop=function
()return 8 end,paletteAt=function()return UDim2.fromOffset(x*am.Scale+8,8)end,
paletteWidth=function()return aK.width*am.Scale-16 end,dialogAt=function()return
UDim2.fromOffset(x*am.Scale,0)end,isShowing=function(aL)if not aK.isOpen then
return false end local aM=aL._page or(aL.host and aL.host._page)return aM==nil
or aM==aK.pages[aK.current]end,setScrollLocked=function(aL)local aM=aK.pages[aK.
current]if aM and aM.frame and Z then aM.frame.ScrollingEnabled=not aL end end}
aK.ctx=aL local aM=m.popover(aL,an)aL.popover={open=function(aN,aO,aP,aQ,aR)
local aS=aK.pages[aK.current]if aS==nil or not aS:expand(aO,aQ,aR)then aM:open(
aO,aP,aQ,aR)end end,close=function()aM:close()local aN=aK.pages[aK.current]if aN
then aN:collapse()end end,isOpen=function()return aM:isOpen()end,key=function(aN
,aO)if aM:key(aO)then return true end local aP=aK.pages[aK.current]return aP~=
nil and aP:expansionKey(aO)end}aL.tooltip=m.tooltip(aL,an)aL.hover=m.hover(aL)aL
.notifications=l.new(aL,an)aL.notify=function(aN)aL.notifications:show(aN)end aK
.keys=g.new(X,c,function()return aK.isOpen end)aL.keys=aK.keys local function 
drawMarker()local aN,aO=aK._markerTop or 0,aK._markerBottom or 0 au.Position=
UDim2.new(0,0,0,aN)au.Size=UDim2.new(0,4,0,math.max(aO-aN,0))end aK._edgeTop=ac:
add(k.new(0,Q,function(aN)aK._markerTop=aN drawMarker()end))aK._edgeBottom=ac:
add(k.new(0,Q,function(aN)aK._markerBottom=aN drawMarker()end))aK._pageSlide=ac:
add(k.prop(aE,'Position',O))aK._wipeAt=ac:add(k.prop(aF,'Position',O))aK._slide=
ac:add(k.prop(al,'Position',M))aK._columnSize=ac:add(k.prop(ax,'Size',A))aK.
_palette=o.new(aL,an,function()return aK.ordered end,function(aN)aK:reveal(aN)
end)local aN=i('TextButton',{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-
6,0,6),Size=UDim2.fromOffset(34,34),Parent=az})local aO=aL.glyph.cross(aN,
'muted')aO.AnchorPoint=Vector2.new(0.5,0.5)aO.Position=UDim2.fromScale(0.5,0.5)
aN.Activated:Connect(function()aK:setOpen(false)end)local aP=i('TextButton',{
AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-46,0,11),Size=UDim2.
fromOffset(60,24),TextSize=16,Text='Search',TextXAlignment=Enum.TextXAlignment.
Right,Parent=az})W:type(aP,'text',true)W:paint(aP,'TextColor3','muted')aP.
MouseEnter:Connect(function()aL.tint(aP,'TextColor3','text')end)aP.MouseLeave:
Connect(function()aL.tint(aP,'TextColor3','muted')end)aP.Activated:Connect(
function()aK._palette:toggle()end)aB.Size=UDim2.new(1,-(36+110),0,22)aH.
Activated:Connect(function()aK:setOpen(true)end)aJ.InputBegan:Connect(function(
aQ)local aR=aQ.UserInputType if aR~=Enum.UserInputType.MouseButton1 and aR~=Enum
.UserInputType.Touch then return end local aS=if aR==Enum.UserInputType.Touch
then X:at(aQ)else X:pointer()local aT=aK.width X:capture(function(aU)aK.width=
math.clamp(aT+(aU.X-aS.X)/am.Scale,K,L)aK:_fit()aK:_saveState()end)end)X.moved:
connect(function(aQ)aL.hover:verify(aQ)end)X.wheel:connect(function(aQ)if not aK
.isOpen or aL.popover:isOpen()or aK._palette:isOpen()then return end local aR=aK
.pages[aK.current]if aR==nil or aR.frame==nil then return end local aS=X:
pointer()local aT,aU=aR.frame.AbsolutePosition,aR.frame.AbsoluteSize if aS.X>=aT
.X and aS.Y>=aT.Y and aS.X<=aT.X+aU.X and aS.Y<=aT.Y+aU.Y then if not aR:
pointerInExpansion(aS)then aR:wheel(aQ)end end end)X.keyDown:connect(function(aQ
,aR)if aQ.UserInputType~=Enum.UserInputType.Keyboard then return end local aS=aQ
.KeyCode.Name if aK.keys:swallowed(aS)then return end if aK._palette:key(aS)or
aL.popover:key(aS)then return end if aS=='Escape'and aK._dialogClose then aK.
_dialogClose()return end if aR or X:typing()then return end if aK.isOpen and aS
=='K'then if Y:IsKeyDown(Enum.KeyCode.LeftControl)or Y:IsKeyDown(Enum.KeyCode.
RightControl)then aK._palette:toggle()end end end)ac:add(_:
GetPropertyChangedSignal('AbsoluteSize'):Connect(function()aK:_fit()end))ac:add(
W.changed:connect(function()for aQ,aR in aK.pages do for aS,aT in aR._views do
pcall(function()aT:retint()aT.refresh()end)end end end))local aQ=p.new({window=
aK,nextId=function()return 0 end,_register=function(aQ,aR,aS)if aS then aK.
elements[aR.id]=aR end aR._pageName=''end,_invalidate=function()end},'')aK.
menuKey=aQ:key('__menu',{label='Menu',default=aa.key or'RightShift',mode=
'Toggle',saved=false,onPress=function()aK:toggle()end})local aR=c.service(
'RunService')k.setAttach(function(aS)return aR.PreRender:Connect(aS)end)if aa.
fonts~=false and ad then ac:add(task.defer(function()local aS=aa.fontTag or v
local aT=string.format(w,aS)local aU=ae..'/fonts-'..aS local aV=d.load(aU,aT,
encode)if not aK.destroyed and(aV.text or aV.display)then W:setFonts(aV.text,aV.
display)end local aW=d.image(aU,aT,'ticks.png')if aW and not aK.destroyed then
aL.assets.ticks=aW W.changed:fire()end end))end if Z then aK._opener=q(_,W,
function()aK:setOpen(true)end)end if aa.autoShow~=false then task.defer(function
()aK:setOpen(true)end)else aH.Visible=true end return aK end function u.
setVersion(aa)v=aa end return u end function a.D()local aa=a.cache.D if not aa
then aa={c=__modImpl()}a.cache.D=aa end return aa.c end end end local aa=a.a()
local ab=a.b()local ac=a.e()local ad=a.D()local ae='0.1.7-edge'local function 
registry()local af=aa.global('getgenv')local ag=if type(af)=='function'then af()
else _G local ah=ag.__sottui if type(ah)~='table'then ah={current=nil}ag.
__sottui=ah end return ah end local af={version=ae,motion=ab}ad.setVersion('v'..
ae)function af.window(ag)local ah=table.clone(ag or{})ah._registry=registry()
return ad.new(ah)end function af.current()return registry().current end function
af.obsidian()return ac.new(af)end return af