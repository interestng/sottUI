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
ToHSV()end v=G.alpha draw()end)draw()end)end c.DOT_SPACE=30 local j=10 local k=
18 local l=0.72 function c.swatch(m,n)local o=b('TextButton',{Name='Swatch',Size
=UDim2.new(0,c.DOT_SPACE,1,0),ZIndex=4})local p=b('Frame',{AnchorPoint=Vector2.
new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(k,j),
BackgroundTransparency=0,ZIndex=4,Parent=o})local q={root=o,width=c.DOT_SPACE}
local r=false q.refresh=function()p.BackgroundColor3=n.value.color local s=n.
value.alpha*0.8 p.BackgroundTransparency=if r then math.max(s,l)else s end local
s=false local function reach()o.Visible=not r or s or m.touch end q.setMuted=
function(t)r=t q.refresh()reach()end q.setHover=function(t)s=t reach()end q.
refresh()q.open=function()if not n.disabled then open(m,n,o)end end o.Activated:
Connect(q.open)q.setInk=function()end q.destroy=function()o:Destroy()end return
q end return c end function a.g()local b=a.cache.g if not b then b={c=__modImpl(
)}a.cache.g=b end return b.c end end do local function __modImpl()local b={}
local function isStart(c,d)if d==1 then return true end local e=string.sub(c,d-1
,d-1)return e==' 'or e=='/'or e=='-'or e=='_'end function b.score(c,d)if c==''
then return 0 end local e=string.lower(d)local f=string.lower(c)local g=string.
find(e,f,1,true)if g then return 1000-#e+(if isStart(e,g)then 500 else 0)end
local h,i,j=0,1,-1 for k=1,#f do local l=string.sub(f,k,k)if l~=' 'then local m=
string.find(e,l,i,true)if m==nil then return nil end h+=if isStart(e,m)then 12
elseif m==j+1 then 8 else 1 h-=math.min(m-i,6)j=m i=m+1 end end return h end
function b.setting(c,d)local e=b.score(c,d.label)if e then return e+100 end
local f=string.lower(c)local g=d.section and d.section.title or''local h=string.
lower((d._pageName or'')..' '..g)return if string.find(h,f,1,true)then 1 else
nil end function b.settings(c,d,e)local f={}for g,h in d do local i=b.setting(c,
h)if i then table.insert(f,{item=h,score=i})end end table.sort(f,function(g,h)
return g.score>h.score end)local g,h={},{}for i,j in f do local k=j.item.host or
j.item if not h[k]then h[k]=true table.insert(g,k)if#g==e then break end end end
return g end function b.rank(c,d,e,f)local g={}for h,i in d do local j=b.score(c
,e(i))if j then table.insert(g,{item=i,score=j})end end table.sort(g,function(h,
i)return h.score>i.score end)local h={}for i=1,math.min(f,#g)do h[i]=g[i].item
end return h end return b end function a.h()local b=a.cache.h if not b then b={c
=__modImpl()}a.cache.h=b end return b.c end end do local function __modImpl()
local b=a.f()local c=a.h()local d={}local e=38 local f=8 local g=9 local h=46
local i=38 local j=260 local k=17 local function isPicked(l,m)if l.spec.multi
then return l.value[m]==true end return l.value==m end function d.open(l,m,n)
local o=m.spec local p=l.theme local q=o.display or tostring local r=o.
searchable==true or#o.options>=g local s=o.multi==true local t=(if r then h else
0)+(if s then i else 0)local u=o.options local v=0 local w=''local function 
ordered(x)if not o.multi then return x end local y,z={},{}for A,B in x do table.
insert(if m.value[B]then y else z,B)end table.move(z,1,#z,#y+1,y)return y end u=
ordered(u)local function bodyHeight()return math.clamp(#u,1,f)*e+8 end local x=
math.max(n.AbsoluteSize.X,j)l.popover:open(n,x,bodyHeight()+t,function(y,z)local
A=b('ScrollingFrame',{Position=UDim2.fromOffset(0,t),Size=UDim2.new(1,0,1,-t),
ScrollBarThickness=3,Parent=y})p:paint(A,'ScrollBarImageColor3','lineStrong')
local B=b('Frame',{Size=UDim2.fromScale(1,1),Parent=A})local C={}local D=f+2
local E=b('TextLabel',{Position=UDim2.fromOffset(14,t+4),Size=UDim2.new(1,-28,0,
e),TextSize=k,Text='Nothing matches',Visible=false,Parent=y})p:type(E,'text')p:
paint(E,'TextColor3','faint')local function draw()local F=math.floor(A.
CanvasPosition.Y/e)+1 for G=1,D do local H=C[G]local I=F+G-1 local J=u[I]if J==
nil then H.root.Visible=false else H.index=I H.option=J H.root.Visible=true H.
root.Position=UDim2.new(0,4,0,(I-1)*e+4)H.text.Text=q(J)local K=isPicked(m,J)p:
paint(H.text,'TextColor3',if K then'onAccent'else'text')p:paint(H.root,
'BackgroundColor3',if K then'accent'else'line')H.root.BackgroundTransparency=if
K or I==v then 0 else 1 end end end local function refit()A.CanvasSize=UDim2.
fromOffset(0,#u*e+8)E.Visible=#u==0 z.resize(bodyHeight()+t)draw()end local 
function refilter()local F=o.options if w~=''then F=c.rank(w,F,q,500)end u=
ordered(F)refit()end local F=nil local function choose(G)if o.multi then local H
=table.clone(m.value)H[G]=if H[G]then nil else true m:set(H)if F and F.Text~=''
then F.Text=''else refilter()end if F and not l.touch then F:CaptureFocus()end
return end if m.value==G then if o.allowNull then m:set(nil)end else m:set(G)end
z.close()end for G=1,D do local H=b('TextButton',{Size=UDim2.new(1,-8,0,e-2),
BackgroundTransparency=1,Visible=false,Parent=B})local I=b('TextLabel',{Position
=UDim2.fromOffset(10,0),Size=UDim2.new(1,-20,1,0),TextSize=k,TextTruncate=Enum.
TextTruncate.AtEnd,Parent=H})p:type(I,'text',true)local J={root=H,text=I,index=0
,option=nil}C[G]=J H.MouseEnter:Connect(function()v=J.index draw()end)H.
MouseLeave:Connect(function()if v==J.index then v=0 draw()end end)H.Activated:
Connect(function()if J.option~=nil then choose(J.option)end end)end A:
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
byte(e,i))h+=g[j-31]or 0.5 end return h*f end return b end function a.j()local b
=a.cache.j if not b then b={c=__modImpl()}a.cache.j=b end return b.c end end do
local function __modImpl()local b=a.f()local c=a.j()local d={}local e=30 local f
=8 local g=16 local h='Press a key'local function display(i)local j=i.value if j
==nil or j.key=='None'or j.key=='Unknown'then return'Unset'end local k={}for l,m
in j.modifiers or{}do table.insert(k,m)end table.insert(k,j.key)local l=table.
concat(k,'+')return if j.mode and j.mode~='Toggle'then l..' '..string.lower(j.
mode)else l end function d.build(i,j)local k=i.theme local l=b('TextButton',{
Name='Key',Size=UDim2.fromOffset(52,54),BackgroundTransparency=1})local m=b(
'Frame',{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size
=UDim2.new(1,-f,0,e),ZIndex=4,Parent=l})local n=b('UIStroke',{ApplyStrokeMode=
Enum.ApplyStrokeMode.Border,Parent=m})local o=b('TextLabel',{Size=UDim2.
fromScale(1,1),TextSize=g,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=5,
Parent=m})k:type(o,'text',true)local p={root=l,width=52}local q=false local r=
false local function fit(s)local t=math.ceil(c.width('textMedium',s,g))+16+f l.
Size=UDim2.fromOffset(math.max(t,44),54)p.width=l.Size.X.Offset if p.onFit then
p.onFit()end end local s=false local function ink()k:paint(o,'TextColor3',if q
then'accent'elseif r then'onAccent'else'muted')k:paint(n,'Color',if q then
'accent'elseif r then'onAccent'else'lineStrong')m.Visible=q or s or display(j)~=
'Unset'end p.setHover=function(t)s=t ink()end p.refresh=function()if q then
return end local t=display(j)o.Text=t fit(t)ink()end p.setInk=function(t)r=t
ink()end p.refresh()p.start=function()if j.disabled or q then return end q=true
o.Text=h fit(h)ink()i.keys:listen(function(t,u)q=false if t~=nil then j:set({key
=t,modifiers=u or{}})end p.refresh()end,j.spec.noMouse==true)end l.Activated:
Connect(p.start)l.MouseButton2Click:Connect(function()local t=j.spec.modes if j.
disabled or t==nil or#t<2 then return end local u=table.find(t,j.value.mode)or 0
local v=t[u%#t+1]j:set({mode=v})i.notify({title=j.label,text='Key mode: '..v,
seconds=2})end)p.destroy=function()if q then i.keys:cancel()end l:Destroy()end
return p end return d end function a.k()local b=a.cache.k if not b then b={c=
__modImpl()}a.cache.k=b end return b.c end end do local function __modImpl()
local b=a.f()local c=a.b()local d={}d.PAD=14 d.HEIGHT=54 d.NAME=17 local e=30
local f=40 local g=0.62 local h=20 local i=36 local j=0.965 local k=2.6 local l=
0.45 local m=0.14 local n={}n.__index=n function n.own(o,p)table.insert(o.
_cleanups,function()p:destroy()end)return p end function n.onCleanup(o,p)table.
insert(o._cleanups,p)end local function baseColor(o)local p=o.ctx.theme.tokens
if o._lit then return if o._hover then p.accentHover else p.accent end if o.
_tinted then return if o._hover then p.accentDim:Lerp(p.accent,m)else p.
accentDim end if o._quiet then return if o._hover then p.raised else p.surface
end return if o._hover then p.accentDim else p.raised end local function washTo(
o)if o._wash==nil then o._wash=o:own(c.prop(o.root,'BackgroundColor3',e))end o.
_wash:to(baseColor(o))end local function snapBase(o)local p=baseColor(o)if o.
_wash then o._wash:snap(p)else o.root.BackgroundColor3=p end end function n.
onHover(o,p)local q=p and not o.el.disabled if o._hover==q then return end o.
_hover=q for r,s in o.chips do if s.setHover then s.setHover(q)end end if not(o.
_floodFrame and o._floodFrame.Visible)then washTo(o)end end function n.pressed(o
,p)if o._press==nil then local q=b('UIScale',{Parent=o.root})o._press=o:own(c.
prop(q,'Scale',f,g))end o._press:to(if p then j else 1)end function n.flood(o,p,
q)if o._floodOn==p then return end o._floodOn=p local r=o.root local s=r.
AbsoluteSize if q or s.X<1 or not r.Visible or not o.ctx.isShowing(o.el)then o.
_lit=p if o._floodFrame then o._floodFrame.Visible=false o._floodSpring:snap(
UDim2.fromOffset(0,0))end snapBase(o)return end local t=o._floodFrame if t==nil
then t=b('Frame',{Name='Flood',AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.
fromOffset(0,0),BackgroundTransparency=0,ZIndex=1,Parent=r})b('UICorner',{
CornerRadius=UDim.new(1,0),Parent=t})o.ctx.theme:paint(t,'BackgroundColor3',
'accent')o._floodFrame=t o._floodSpring=o:own(c.prop(t,'Size',h))end local u=o.
ctx.uiScale()local v=s/u local w=math.ceil(math.sqrt(v.X*v.X+v.Y*v.Y)*k)local x=
o._pressAt o._pressAt=nil local y=if x then(x-r.AbsolutePosition)/u else v/2 t.
Position=UDim2.fromOffset(y.X,y.Y)t.Visible=true if p then o._floodSpring:snap(
UDim2.fromOffset(0,0))o._floodSpring:to(UDim2.fromOffset(w,w),function()o._lit=
true local z=o._hover o._hover=false snapBase(o)o._hover=z t.Visible=false
washTo(o)end)else o._lit=false snapBase(o)o._floodSpring:snap(UDim2.fromOffset(w
,w))o._floodSpring:to(UDim2.fromOffset(0,0),function()t.Visible=false end)end
end function n.tint(o,p,q)if o._tinted==p then return end o._tinted=p if q or
not o.ctx.isShowing(o.el)then snapBase(o)else washTo(o)end end function n.flash(
o)if o._floodOn then o:pressed(true)task.delay(0.16,function()if o.root.Parent
then o:pressed(false)end end)return end o:flood(true)task.delay(0.28,function()
if o.root.Parent and not(o.el.kind=='toggle'and o.el.value==true)then o:flood(
false)end end)end function n.ink(o,p,q,r)local s=o.ctx.theme.tokens local t=o.
_inks[p]if r or not o.ctx.isShowing(o.el)then if t then t:snap(s[q])else p.
TextColor3=s[q]end return end if t==nil then t=o:own(c.prop(p,'TextColor3',i))o.
_inks[p]=t end t:to(s[q])end function n.retint(o)snapBase(o)end function n.
refreshName(o)local p=o.el if p.disabled then o.name.RichText=true o.name.Text=
'<s>'..p.label..'</s>'else o.name.RichText=false o.name.Text=p.label end end
function d.new(o,p,q)local r=q or{}local s=b('TextButton',{Name=p.kind,Size=
UDim2.new(1,0,0,r.height or d.HEIGHT),BackgroundTransparency=if r.inert then 1
else 0,ClipsDescendants=true,Active=not r.inert})local t=b('TextLabel',{Name=
'Name',Position=UDim2.fromOffset(d.PAD,0),Size=UDim2.new(1,-2*d.PAD,1,0),
TextSize=d.NAME,TextWrapped=true,TextTruncate=Enum.TextTruncate.AtEnd,Text=p.
label,ZIndex=3,Parent=s})o.theme:type(t,'text',true)local u=setmetatable({root=s
,name=t,el=p,ctx=o,chips={},_cleanups={},_inks={},_hover=false,_lit=false,
_floodOn=false,_tinted=false,_quiet=r.quiet==true},n)s.BackgroundColor3=
baseColor(u)u:refreshName()if r.inert then u.onHover=function()end u.pressed=
function()end else s.MouseEnter:Connect(function()o.hover:enter(u)end)local v=
nil s.InputBegan:Connect(function(w)local x=w.UserInputType if x==Enum.
UserInputType.MouseButton1 then if not p.disabled then u._pressAt=o.input:
pointer()u:pressed(true)end elseif x==Enum.UserInputType.Touch then if not p.
disabled then u._pressAt=o.input:at(w)u:pressed(true)end v=task.delay(l,function
()v=nil local y=if p.disabled and p.disabledTip then p.disabledTip else p.tip if
y and y~=''then o.tooltip:showAt(s,y)end end)end end)local w=o.input.pointerUp:
connect(function()if u._press and u._press.target~=1 then u:pressed(false)end if
v then task.cancel(v)v=nil end end)u:onCleanup(function()w()if v then task.
cancel(v)end end)end u.destroy=function()o.hover:leave(u)for v,w in u._cleanups
do pcall(w)end s:Destroy()end return u end return d end function a.l()local b=a.
cache.l if not b then b={c=__modImpl()}a.cache.l=b end return b.c end end do
local function __modImpl()local b=a.g()local c=a.i()local d=a.k()local e=a.f()
local f=a.j()local g=a.b()local h=a.l()local i={}local j=h.PAD local k=17 local
l=28 local m=28 local n=28 local o=42 local p=90 local q=3 local r=12 local s=17
local t=22 local u=16 local v=1 local w=4 local x=11 local y=12 local z=2 local
A=4 local B=12 local C=34 local D=17 local E=16 local F=46 local G={}local 
function addons(H,I,J,K)local L=K local M={}local function reflow()local N=K for
O,P in M do P.root.Position=UDim2.new(1,-(j+N),0.5,0)N+=P.width+P.gap end H.name
.Size=UDim2.new(1,-(2*j+N),1,0)end local function place(N,O)O.root.AnchorPoint=
Vector2.new(1,0.5)O.root.Position=UDim2.new(1,-(j+L),0.5,0)O.root.ZIndex=4 O.
root.Parent=H.root O.gap=if N.kind=='key'then 6 else 0 O.onFit=reflow L+=O.width
table.insert(M,O)N._view=O H.addonChips=H.addonChips or{}H.addonChips[N]=O table
.insert(H.chips,O)H:onCleanup(function()N._view=nil O.destroy()end)end for N,O
in J.addons or{}do if O.kind=='color'and not O.spec.chipless then place(O,b.
swatch(I,O))end end for N,O in J.addons or{}do if O.kind=='key'and not O.spec.
chipless then place(O,d.build(I,O))L+=6 end end return L end local function 
reserveRight(H,I)H.name.Size=UDim2.new(1,-(2*j+I),1,0)end local function 
baseline(H,I,J,K)local L=e('Frame',{Name='Track',AnchorPoint=Vector2.new(0,1),
Position=UDim2.fromScale(0,1),Size=UDim2.new(1,0,0,v),BackgroundTransparency=0,
ZIndex=2,Parent=H.root})I.theme:paint(L,'BackgroundColor3','lineStrong')local M=
e('Frame',{Name='Fill',AnchorPoint=Vector2.new(0,1),Position=UDim2.fromScale(0,1
),Size=UDim2.new(J,0,0,K or w),BackgroundTransparency=0,ZIndex=2,Parent=H.root})
I.theme:paint(M,'BackgroundColor3','accent')return M end function G.toggle(H,I)
local J=I.spec.primary==true local K=h.new(H,I,{quiet=not J})local L=H.theme if
not J then local M=baseline(K,H,if I.value==true then 1 else 0)local N=K:own(g.
prop(M,'Size',o))local O=e('Frame',{Name='Mark',AnchorPoint=Vector2.new(1,0.5),
Position=UDim2.new(1,-j,0.5,0),Size=UDim2.fromOffset(x,x),ZIndex=3,Parent=K.root
})local P=e('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,
Parent=O})reserveRight(K,addons(K,H,I,x+y))local function draw(Q)local R=I.value
==true O.BackgroundTransparency=if R then 0 else 1 L:paint(O,'BackgroundColor3',
'accent')L:paint(P,'Color',if R then'accent'elseif I.disabled then'line'else
'muted')K:tint(R,Q)K:ink(K.name,if I.disabled then'faint'elseif R then
'accentHover'else'muted',Q)local S=UDim2.new(if R then 1 else 0,0,0,w)if Q or
not H.isShowing(I)then N:snap(S)else N:to(S)end for T,U in K.chips do U.setInk(
false)if U.setMuted then U.setMuted(not R)end end end K.root.Activated:Connect(
function()if not I.disabled then I:set(not I.value)end end)K.refresh=function()K
:refreshName()draw(false)end draw(true)return K end local M=u if J then L:type(K
.name,'display')K.name.TextSize=if I.value==true then m else l K.name.
TextWrapped=false K._nameSize=K:own(g.prop(K.name,'TextSize',n))end local N=e(
'Frame',{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-j,0.5,0),Size=
UDim2.fromOffset(M,M),ZIndex=3,Parent=K.root})local O=e('UIStroke',{
ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=2,Parent=N})local P=nil
local Q=nil local R=nil local S=M+12 if J then P=e('TextButton',{AnchorPoint=
Vector2.new(1,0),Position=UDim2.new(1,-(j+M+4),0,0),Size=UDim2.new(0,F,1,0),
ZIndex=4,Parent=K.root})Q=H.glyph.chevron(P,'muted','down')R=H.glyph.chevron(P,
'muted','up')for T,U in{Q,R}do U.AnchorPoint=Vector2.new(0.5,0.5)U.Position=
UDim2.fromScale(0.5,0.5)end S+=F P.Activated:Connect(function()I.section:
togglePeek()K.refresh()end)end reserveRight(K,addons(K,H,I,S))local function 
draw(T)local U=I.value==true local V=J and U if J then K:flood(U,T)local W=if U
then m else l if T or not H.isShowing(I)then K._nameSize:snap(W)else K._nameSize
:to(W)end end K:ink(K.name,if I.disabled then'faint'elseif V then'onAccent'
elseif U then'text'else'muted',T)N.BackgroundTransparency=if U then 0 else 1 L:
paint(N,'BackgroundColor3',if V then'onAccent'else'accent')L:paint(O,'Color',if
V then'onAccent'elseif U then'accent'elseif I.disabled then'line'else
'lineStrong')for W,X in K.chips do X.setInk(V)end if P then local W=I._shownOn
and I._shownOn.sections[1]and I._shownOn.sections[1].flat P.Visible=I.section.
hasOptions==true and not W for X,Y in{Q,R}do for Z,_ in Y:GetChildren()do L:
paint(_,'BackgroundColor3',if V then'onAccent'else'muted')end end Q.Visible=not
I.section.peeking R.Visible=I.section.peeking==true end end K.root.Activated:
Connect(function()if not I.disabled then I:set(not I.value)end end)K.refresh=
function()K:refreshName()draw(false)end draw(true)return K end local function 
formatted(H,I)local J=H.spec if J.format then local K,L=pcall(J.format,H,I)if K
and L~=nil then return tostring(L)end end return string.format('%.'..(J.decimals
or 0)..'f',I)..(J.suffix or'')end function i.readoutWidth(H)local I=H.spec local
J=0 for K,L in{I.min,I.max,H.value}do J=math.max(J,f.width('textMedium',
formatted(H,L),k))end return math.ceil(J*1.05)+2 end function G.slider(H,I)local
J=h.new(H,I,{quiet=true})local K=H.theme local L=I.spec local M=J.root local 
function ratio()local N=L.max-L.min return if N<=0 then 0 else(I.value-L.min)/N
end local N=i.readoutWidth(I)reserveRight(J,N+r)J.name.ZIndex=4 local O=e(
'TextLabel',{Name='Readout',AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-j
,0,0),Size=UDim2.new(0,N,1,0),TextSize=k,TextXAlignment=Enum.TextXAlignment.
Right,ZIndex=4,Parent=M})K:type(O,'text',true)local P=baseline(J,H,ratio(),z)
local Q=e('Frame',{Name='Head',AnchorPoint=Vector2.new(1,1),Position=UDim2.
fromScale(1,1),Size=UDim2.fromOffset(A,B),BackgroundTransparency=0,ZIndex=3,
Parent=P})K:paint(Q,'BackgroundColor3','text')local R=J:own(g.prop(P,'Size',o))
local function typedEntry()if I.disabled or J._typing then return end J._typing=
true O.Visible=false local S=e('TextBox',{AnchorPoint=Vector2.new(1,0),Position=
UDim2.new(1,-j,0,0),Size=UDim2.new(0,math.max(N,64),1,0),TextSize=k,
TextXAlignment=Enum.TextXAlignment.Right,Text='',PlaceholderText=tostring(I.
value),ZIndex=6,Parent=M})K:type(S,'display')K:paint(S,'TextColor3','accent')K:
paint(S,'PlaceholderColor3','faint')S:CaptureFocus()S.FocusLost:Connect(function
()local T=tonumber(S.Text)J._typing=false O.Visible=true S:Destroy()if T then I:
set(T)end end)end local function beginDrag(S,T,U)if I.disabled then return end
local V=I.value local W=math.max(M.AbsoluteSize.X,1)local X=L.max-L.min local Y=
false local Z=false H.input:capture(function(_)local aa=_-S if not Y then if
math.abs(aa.X)<q then if T and math.abs(aa.Y)>8 then Z=true H.input:release()end
return end if T and math.abs(aa.X)<=math.abs(aa.Y)then Z=true H.input:release()
return end Y=true R.speed=p H.setScrollLocked(true)end I:set(V+X*aa.X/W)end,
function(aa)R.speed=o H.setScrollLocked(false)if not Y and not Z and(aa-S).
Magnitude<8 then typedEntry()end end,U)end M.InputBegan:Connect(function(aa)
local S=aa.UserInputType if S==Enum.UserInputType.MouseButton2 then typedEntry()
elseif S==Enum.UserInputType.MouseButton1 then beginDrag(H.input:pointer(),false
)elseif S==Enum.UserInputType.Touch then beginDrag(H.input:at(aa),true,aa)end
end)local function paintText()local aa=if I.disabled then'faint'else'text'K:
paint(J.name,'TextColor3',aa)K:paint(O,'TextColor3',aa)O.Text=formatted(I,I.
value)end J.refresh=function()J:refreshName()paintText()R:to(UDim2.new(ratio(),0
,0,z))end paintText()return J end local function pickText(aa)local H=aa.spec.
display or tostring local I=aa.value if aa.spec.multi then local J={}for K,L in
aa.spec.options do if I[L]then table.insert(J,H(L))end end for K,L in I do if L
and not table.find(aa.spec.options,K)then table.insert(J,H(K))end end if#J==0
then return'None',false end if#J<=2 then return table.concat(J,', '),true end
return string.format('%s, %s +%d',J[1],J[2],#J-2),true end if I==nil then return
'None',false end return H(I),true end function G.dropdown(aa,H)local I=h.new(aa,
H,{quiet=true})local J=aa.theme local K=I.root baseline(I,aa,0)J:paint(I.name,
'TextColor3','muted')local L=e('TextLabel',{Name='Value',AnchorPoint=Vector2.
new(1,0),Position=UDim2.new(1,-(j+t),0,0),TextSize=s,TextTruncate=Enum.
TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=3,Parent=K})J
:type(L,'text',true)local M=aa.glyph.chevron(K,'muted')M.AnchorPoint=Vector2.
new(1,0.5)M.Position=UDim2.new(1,-j,0.5,0)M.ZIndex=3 local function fit()local N
=K.AbsoluteSize.X/aa.uiScale()-2*j-t if N<=0 then return end local O=f.width(
'textMedium',(pickText(H)),s)+r local P=math.max(N-O,N*0.45)I.name.Size=UDim2.
new(0,P,1,0)L.Size=UDim2.new(0,N-P,1,0)end K:GetPropertyChangedSignal(
'AbsoluteSize'):Connect(fit)K.Activated:Connect(function()if not H.disabled then
c.open(aa,H,K)end end)I.refresh=function()I:refreshName()local N,O=pickText(H)L.
Text=N J:paint(L,'TextColor3',if H.disabled or not O then'faint'else'text')fit()
end I.refresh()task.defer(fit)return I end function G.input(aa,H)local I=h.new(
aa,H,{quiet=true})local J=aa.theme local K=H.spec I.name.Size=UDim2.new(0.35,-j,
1,0)J:paint(I.name,'TextColor3','muted')local L=e('TextBox',{AnchorPoint=Vector2
.new(1,0.5),Position=UDim2.new(1,-j,0.5,0),Size=UDim2.new(0.65,-j,0,C),TextSize=
D,Text=H.value or'',PlaceholderText=K.placeholder or'',ClipsDescendants=true,
TextEditable=not H.disabled,ZIndex=3,Parent=I.root})J:type(L,'text',true)J:
paint(L,'TextColor3','text')J:paint(L,'PlaceholderColor3','faint')local M=e(
'Frame',{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.
new(1,0,0,v),BackgroundTransparency=0,ZIndex=4,Parent=I.root})J:paint(M,
'BackgroundColor3','lineStrong')L.Focused:Connect(function()J:paint(M,
'BackgroundColor3','accent')end)L.FocusLost:Connect(function(N)J:paint(M,
'BackgroundColor3','lineStrong')if not K.finished then return end if not N or
not H:set(L.Text)then L.Text=H.value or''end end)L:GetPropertyChangedSignal(
'Text'):Connect(function()if I._applying or K.finished then return end if not H:
set(L.Text)and L.Text~=H.value then I._applying=true L.Text=H.value or''I.
_applying=false end end)I.root.Activated:Connect(function()if not H.disabled
then L:CaptureFocus()end end)I.refresh=function()I:refreshName()L.TextEditable=
not H.disabled if L.Text~=(H.value or'')then I._applying=true L.Text=H.value or
''I._applying=false end end return I end function G.button(aa,H)local I=h.new(aa
,H,{quiet=true})local J=e('Frame',{Name='Outline',Position=UDim2.fromOffset(1,1)
,Size=UDim2.new(1,-2,1,-2),ZIndex=2,Parent=I.root})local K=e('UIStroke',{
ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,Parent=J})aa.theme:
paint(K,'Color','lineStrong')local L=nil local function draw()I:refreshName()I:
ink(I.name,if H.disabled then'faint'elseif H.spec.danger then'danger'else'text')
end I.refresh=draw draw()I.root.Activated:Connect(function()if H.disabled then
return end if H.spec.confirm and L==nil then I.name.Text='Again to confirm'I:
flood(true)I:ink(I.name,'onAccent')L=task.delay(2.5,function()L=nil I:flood(
false)draw()end)return end if L then task.cancel(L)L=nil I:flood(false)draw()end
I:flash()I:ink(I.name,'onAccent')task.delay(0.28,function()if I.root.Parent then
draw()end end)H:fire()end)I:onCleanup(function()if L then task.cancel(L)end end)
return I end function G.stat(aa,H)local I=h.new(aa,H,{inert=true})local J=aa.
theme I.name.Position=UDim2.fromOffset(j,0)I.name.Size=UDim2.new(0.5,-j,1,0)I.
name.TextWrapped=false J:paint(I.name,'TextColor3','muted')local K=e('TextLabel'
,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-j,0,0),Size=UDim2.new(0.5,-
j,1,0),TextSize=h.NAME,TextXAlignment=Enum.TextXAlignment.Right,TextTruncate=
Enum.TextTruncate.AtEnd,ZIndex=3,Parent=I.root})J:type(K,'text',true)J:paint(K,
'TextColor3','text')I.refresh=function()I.name.Text=H.label K.Text=tostring(H.
value)end I.refresh()return I end function G.label(aa,H)local I=aa.theme if H.
addons then local J=h.new(aa,H,{quiet=true})baseline(J,aa,0)I:paint(J.name,
'TextColor3','muted')J.name.RichText=true reserveRight(J,addons(J,aa,H,0))J.
refresh=function()J.name.Text=H.label end return J end local J=h.new(aa,H,{
height=32,inert=true})local K=J.name local L=H.spec.wrap==true K.RichText=true K
.TextSize=E K.TextWrapped=L I:type(K,'text')I:paint(K,'TextColor3','muted')K.
TextTruncate=if L then Enum.TextTruncate.None else Enum.TextTruncate.AtEnd K.
TextYAlignment=if L then Enum.TextYAlignment.Top else Enum.TextYAlignment.Center
K.LineHeight=if L then 1.15 else 1 K.Position=UDim2.fromOffset(0,if L then 6
else 0)K.Size=if L then UDim2.new(1,0,1,-6)else UDim2.fromScale(1,1)K.Text=H.
label if L then K:GetPropertyChangedSignal('TextBounds'):Connect(function()local
M=math.ceil(K.TextBounds.Y/aa.uiScale())+12 if H._measured~=M then H._measured=M
if H._relayout then H._relayout()end end end)end J.refresh=function()K.Text=H.
label end return J end function G.divider(aa,H)local I=h.new(aa,H,{height=28,
inert=true})local J=aa.theme I.name.Position=UDim2.new()I.name.Size=UDim2.
fromScale(1,1)I.name.TextSize=E J:type(I.name,'text',true)J:paint(I.name,
'TextColor3','muted')I.refresh=function()I.name.Text=H.label end return I end
local function chipTile(aa,H,I,J,K)local L=h.new(aa,H)aa.theme:paint(L.name,
'TextColor3','muted')I.root.AnchorPoint=Vector2.new(1,0.5)I.root.Position=UDim2.
new(1,-K,0.5,0)I.root.ZIndex=4 I.root.Parent=L.root reserveRight(L,J)table.
insert(L.chips,I)L:onCleanup(I.destroy)L.refresh=function()L:refreshName()I.
refresh()end return L end function G.key(aa,H)local I=d.build(aa,H)local J=
chipTile(aa,H,I,96,j)J.root.Activated:Connect(I.start)return J end function G.
color(aa,H)local I=b.swatch(aa,H)local J=chipTile(aa,H,I,b.DOT_SPACE,j-8)J.root.
Activated:Connect(I.open)return J end function i.build(aa,H)local I=G[H.kind]
assert(I,'sottUI: no view for '..tostring(H.kind))local J=I(aa,H)local K=H.
_shownOn local L=K and K.sections[1]and K.sections[1].flat local M=H.section and
(H.section._root or H.section)local N=M and M.masterElement if L and N and N~=H
then local O=J.refreshName J.refreshName=function(P)O(P)P.name.Text=N.label..' '
..H.label end J:refreshName()end H._view=J return J end return i end function a.
m()local aa=a.cache.m if not aa then aa={c=__modImpl()}a.cache.m=aa end return
aa.c end end do local function __modImpl()local aa={}aa.__index=aa local b=
function(b)warn(b)end function aa.connect(c,d)local e=table.clone(c._list)table.
insert(e,d)c._list=e return function()local f=table.clone(c._list)local g=table.
find(f,d)if g then table.remove(f,g)c._list=f end end end function aa.fire(c,...
)for d,e in c._list do local f,g=xpcall(e,debug.traceback,...)if not f then b(
'sottUI: listener failed: '..tostring(g))end end end function aa.clear(c)c._list
={}end return{new=function()return((setmetatable({_list={}},aa)))end,setReporter
=function(c)b=c end}end function a.n()local aa=a.cache.n if not aa then aa={c=
__modImpl()}a.cache.n=aa end return aa.c end end do local function __modImpl()
local aa=a.n()local b={}local c={}c.__index=c local function decimals(d)local e=
string.format('%.10f',d)local f=string.match(e,'%.(%d-)0*$')return if f then#f
else 0 end local function roundTo(d,e)if e<=0 then return d end local f=math.
round(d/e)*e return tonumber(string.format('%.'..decimals(e)..'f',f))or f end b.
roundTo=roundTo local function sameList(d,e)if#d~=#e then return false end for f
=1,#d do if d[f]~=e[f]then return false end end return true end local function 
sameSet(d,e)for f,g in d do if g and not e[f]then return false end end for f,g
in e do if g and not d[f]then return false end end return true end local d={
toggle=function(d,e)return e==true end,slider=function(d,e)local f=tonumber(e)if
f==nil or f~=f then return nil end local g=d.spec return math.clamp(roundTo(f,g.
step or 1),g.min,g.max)end,dropdown=function(d,e)local f=d.spec if f.multi then
local g={}if type(e)=='table'then for h,i in e do if type(h)=='number'then g[i]=
true elseif i then g[h]=true end end elseif e~=nil and e~=''then g[e]=true end
if not f.keep then for h in g do if not table.find(f.options,h)then g[h]=nil end
end end return g end if e==nil or e==''then return false end if not table.find(f
.options,e)and not f.keep then return nil end return e end,input=function(d,e)
local f=if e==nil then''else tostring(e)local g=d.spec if g.maxLength and#f>g.
maxLength then f=string.sub(f,1,g.maxLength)end if g.numeric and f~=''and f~='-'
and f~='.'and tonumber(f)==nil then return nil end if g.verify and not g.verify(
f)then return nil end return f end,key=function(d,e)if type(e)=='string'then
return{key=e,mode=d.value and d.value.mode or'Toggle',modifiers={}}end if type(e
)~='table'then return nil end local f=d.value or{}return{key=e.key or e[1]or f.
key or'None',mode=e.mode or e[2]or f.mode or'Toggle',modifiers=e.modifiers or e[
3]or f.modifiers or{}}end,color=function(d,e)if typeof(e)=='Color3'then return{
color=e,alpha=d.value and d.value.alpha or 0}end if type(e)=='table'and typeof(e
.color)=='Color3'then return{color=e.color,alpha=math.clamp(tonumber(e.alpha)or
0,0,1)}end return nil end,label=function(d,e)return tostring(e)end,stat=function
(d,e)return tostring(e)end}local function equal(e,f,g)local h=e.kind if h==
'dropdown'and e.spec.multi then return sameSet(f,g)end if h=='key'then return f.
key==g.key and f.mode==g.mode and sameList(f.modifiers,g.modifiers)end if h==
'color'then return f.color==g.color and f.alpha==g.alpha end return f==g end
local function unwrap(e,f)if e.kind=='dropdown'and not e.spec.multi and f==false
then return nil end return f end function b.new(e,f,g,h,i)local j=setmetatable({
kind=e,id=f,label=g,spec=h,tip=h.tip,disabled=h.disabled==true,disabledTip=h.
disabledTip,visible=h.visible~=false,saved=h.saved~=false,changed=aa.new()},c)
local k=d[e]local l=i if k then l=k(j,i)if l==nil and e=='slider'then l=h.min
end if l==nil and e=='dropdown'then l=false end end j.value=unwrap(j,l)j.default
=j.value return j end function c.set(e,f)local g=d[e.kind]local h=f if g then h=
g(e,f)if h==nil then return false end h=unwrap(e,h)end local i=e.value if i~=nil
and h~=nil and equal(e,i,h)then return false end if i==nil and h==nil then
return false end e.value=h e:notify()return true end function c.reset(e)local f=
e.default if e.kind=='dropdown'and e.spec.multi then f=table.clone(f)end e:set(f
)end local function redraw(e)local f=e._view if f then f.refresh()end local g=e.
host if g and g._view then g._view.refresh()end end function c.notify(e)redraw(e
)e.changed:fire(e.value)end function c.fire(e)e.changed:fire(e.value)end
function c.on(e,f)return e.changed:connect(f)end function c.setLabel(e,f)if e.
label==f then return end e.label=f if e.kind=='label'then e.value=f local g=e.
_relayout if g then g()end end if e._onLabel then e._onLabel()end redraw(e)end
function c.setTip(e,f)e.tip=f end function c.setDisabled(e,f,g)e.disabled=f==
true e.disabledTip=g or e.disabledTip redraw(e)end function c.setVisible(e,f)if
e.visible==f then return end e.visible=f local g=e._relayout if g then g()end
end function c.setOptions(e,f)local g=e.spec g.options=table.clone(f)if g.multi
then if g.keep then for h,i in e.value do if i and not table.find(g.options,h)
then table.insert(g.options,h)end end else local h=false for i in e.value do if
not table.find(g.options,i)then e.value[i]=nil h=true end end if h then e:
notify()return end end elseif e.value~=nil and not table.find(g.options,e.value)
then if g.keep then table.insert(g.options,e.value)else e.value=nil e:notify()
return end end redraw(e)end function c.isModified(e)if e.kind=='button'or e.kind
=='label'or e.kind=='divider'or e.kind=='stat'then return false end local f,g=e.
value,e.default if f==nil or g==nil then return f~=g end return not equal(e,f,g)
end function c.attach(e,f)local g=e.addons if g==nil then g={}e.addons=g end
table.insert(g,f)f.host=e redraw(e)end function c.shown(e)if not e.visible or(e.
kind=='label'and e.label=='')then return false end local f=e.guard return f==nil
or f()end return b end function a.o()local aa=a.cache.o if not aa then aa={c=
__modImpl()}a.cache.o=aa end return aa.c end end do local function __modImpl()
local aa=a.o()local b={}local c={}c.__index=c local function add(d,e,f,g,h,i)
local j=aa.new(e,f or(e..'#'..tostring(d._page:nextId())),g,h,i)j.section=d j.
guard=d._guard d._page:_register(j,f~=nil)table.insert(d.rows,j)local k=d._root
or d if k.masterElement then k.hasOptions=true end d._page:_invalidate()return j
end function c.toggle(d,e,f)local g=add(d,'toggle',e,f.label or e,f,f.default==
true)if f.onChanged then g:on(f.onChanged)end return g end function c.master(d,e
,f)f.primary=true local g=d:toggle(e,f)d.masterElement=g local h=d._page g:on(
function()h:_invalidate()end)local i=d._guard d._guard=function()if i and not i(
)then return false end return d.peeking==true end return g end function c.
togglePeek(d)local e=not d.peeking for f,g in d._page.sections do g.peeking=
false end d.peeking=e d._page:_invalidate()end function c.slider(d,e,f)f.min=f.
min or 0 f.max=f.max or 100 f.step=f.step or 1 if f.decimals==nil then local g=
string.format('%.10f',f.step)local h=string.match(g,'%.(%d-)0*$')f.decimals=if h
then#h else 0 end local g=add(d,'slider',e,f.label or e,f,f.default or f.min)if
f.onChanged then g:on(f.onChanged)end return g end function c.dropdown(d,e,f)f.
options=f.options or{}local g=f.default if g==nil and f.multi then g={}end local
h=add(d,'dropdown',e,f.label or e,f,g)if f.onChanged then h:on(f.onChanged)end
return h end function c.input(d,e,f)local g=add(d,'input',e,f.label or'',f,f.
default or'')if f.onChanged then g:on(f.onChanged)end return g end function c.
key(d,e,f)local g=add(d,'key',e,f.label or e,f,{key=f.default or'None',mode=f.
mode or'Toggle',modifiers=f.modifiers or{}})d._page.window.keys:register(g)
return g end function c.color(d,e,f)local g=add(d,'color',e,f.label or e,f,{
color=f.default or Color3.new(1,1,1),alpha=f.alphaValue or 0})if f.onChanged
then g:on(f.onChanged)end return g end function c.button(d,e,f)local g=if type(f
)=='function'then{onPressed=f}else f g.saved=false local h=add(d,'button',nil,e,
g,nil)if g.onPressed then h:on(g.onPressed)end return h end function c.label(d,e
,f)local g=f or{}g.saved=false return add(d,'label',nil,e,g,e)end function c.
stat(d,e,f)return add(d,'stat',nil,e,{saved=false},tostring(f))end function c.
divider(d,e)return add(d,'divider',nil,e or'',{saved=false},nil)end function c.
addKey(d,e,f,g)local h=aa.new('key',f,g.label or e.label,g,{key=g.default or
'None',mode=g.mode or'Toggle',modifiers=g.modifiers or{}})h.section=d local i=h
i.toggled=g.toggled==true if e.kind=='toggle'and g.onPress==nil then i.toggled=e
.value g.onPress=function()e:set(not e.value)i.toggled=e.value end end d._page:
_register(h,true)d._page.window.keys:register(h)e:attach(h)return h end function
c.addColor(d,e,f,g)local h=aa.new('color',f,g.label or e.label,g,{color=g.
default or Color3.new(1,1,1),alpha=g.alphaValue or 0})h.section=d d._page:
_register(h,true)e:attach(h)if g.onChanged then h:on(g.onChanged)end return h
end function c.when(d,e,f)local g=d._guard local h=e if g then h=function()
return g()and e()end end local i=setmetatable({rows=d.rows,title=d.title,_page=d
._page,_guard=h,_root=d._root or d},c)for j,k in(f or{})do k:on(function()d.
_page:_invalidate()end)end return i end function b.new(d,e)return setmetatable({
title=e,rows={},_page=d,_guard=nil,_root=nil},c)end return b end function a.p()
local aa=a.cache.p if not aa then aa={c=__modImpl()}a.cache.p=aa end return aa.c
end end do local function __modImpl()local aa=a.m()local b=a.f()local c=a.j()
local d=a.b()local e=a.p()local f={}local g=26 local h=36 function f.open(i,j,k)
if i._dialogClose then i._dialogClose()end local l=i.ctx local m=l.theme local n
=i._layer local o=j.width or 460 local p=j.maxHeight or 340 local q=60 local r=
b('TextButton',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
BackgroundColor3=Color3.new(0,0,0),ZIndex=50,Parent=n})local s=d.prop(r,
'BackgroundTransparency',22)s:to(0.4)local t=b('Frame',{AnchorPoint=Vector2.new(
0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(o,0),
BackgroundTransparency=0,ClipsDescendants=true,Active=true,ZIndex=51,Parent=n})m
:paint(t,'BackgroundColor3','base')b('UIScale',{Scale=l.uiScale(),Parent=t})
local u=b('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=t})m:
paint(u,'Color','lineStrong')local v=b('TextLabel',{Position=UDim2.fromOffset(20
,16),Size=UDim2.new(1,-40,0,40),TextSize=36,Text=j.title or'',ZIndex=52,Parent=t
})m:type(v,'display')m:paint(v,'TextColor3','text')local w=60 local x=j.text if
x and x~=''then local y=b('TextLabel',{Position=UDim2.fromOffset(20,w),Size=
UDim2.new(1,-40,0,22),AutomaticSize=Enum.AutomaticSize.Y,TextSize=16,TextWrapped
=true,Text=x,ZIndex=52,Parent=t})m:type(y,'text')m:paint(y,'TextColor3','muted')
w+=22+math.floor(#x/52)*22+12 end local y=b('ScrollingFrame',{Position=UDim2.
fromOffset(20,w),Size=UDim2.new(1,-40,0,0),ScrollBarThickness=3,ZIndex=52,Parent
=t})m:paint(y,'ScrollBarImageColor3','lineStrong')local z=false local A={window=
i,name='Dialog',nextId=function()i._dialogIds+=1 return i._dialogIds end,
_register=function(A,B,C)B._pageName='Dialog'if C then i.elements[B.id]=B end
end,_invalidate=function()end}local B=e.new(A,'')local C,D=xpcall(k,debug.
traceback,B)if not C then warn('sottUI: dialog build failed: '..tostring(D))end
local E={}local F=0 for G,H in B.rows do if H:shown()then local I=aa.build(l,H)
local J=q if H.kind=='divider'then J=28 elseif H.kind=='label'then local K=math.
ceil(c.width('text',H.label,16)/(o-48))J=if H.spec.wrap then K*21+12 else 32 end
I.root.Position=UDim2.fromOffset(0,F)I.root.Size=UDim2.new(1,0,0,J)I.root.Parent
=y F+=J+3 table.insert(E,I)end end y.CanvasSize=UDim2.fromOffset(0,F)local G=
math.min(F,p)y.Size=UDim2.new(1,-40,0,G)local H=w+G+12 local I=b('TextButton',{
Position=UDim2.fromOffset(20,H),Size=UDim2.new(1,-40,0,54),
BackgroundTransparency=0,TextSize=28,Text=j.done or'Done',ZIndex=52,Parent=t})m:
type(I,'display')m:paint(I,'BackgroundColor3','text')m:paint(I,'TextColor3',
'base')local J=H+54+20 local K=d.prop(t,'Size',g)K:to(UDim2.fromOffset(o,J))
local function close()if z then return end z=true i._dialogClose=nil r.Active=
false for L,M in B.rows do if i.elements[M.id]==M then i.elements[M.id]=nil end
for N,O in M.addons or{}do i.keys:unregister(O)if i.elements[O.id]==O then i.
elements[O.id]=nil end end end if j.onClose then task.spawn(j.onClose)end s:to(1
,function()s:destroy()r:Destroy()end)K.speed=h K:to(UDim2.fromOffset(o,0),
function()for L,M in E do M.destroy()end K:destroy()t:Destroy()end)end i.
_dialogClose=close r.MouseButton1Down:Connect(close)I.Activated:Connect(close)
end return f end function a.q()local aa=a.cache.q if not aa then aa={c=
__modImpl()}a.cache.q=aa end return aa.c end end do local function __modImpl()
local aa=a.a()local b={}local c={text={name='SottUIText',faces={{name='Regular',
weight=400,file='text-400.ttf'},{name='Medium',weight=500,file='text-500.ttf'}}}
,display={name='SottUIDisplay',faces={{name='ExtraBold',weight=800,file=
'display-800.ttf'}}}}local d=10000 local function family(e,f,g,h,i)local j={}for
k,l in g.faces do local m=f..'/'..l.file local n=e.read(m)if n==nil or#n<d then
local o=aa.fetch(h..l.file)if o==nil or#o<d then return nil end if not e.write(m
,o)then return nil end end local o=e.asset(m)if o==nil then return nil end table
.insert(j,{name=l.name,weight=l.weight,style='normal',assetId=o})end local k=f..
'/'..g.name..'.json'if not e.write(k,i({name=g.name,faces=j}))then return nil
end return e.asset(k)end function b.load(e,f,g)local h=aa.files()if h==nil or aa
.global('getcustomasset')==nil then return{}end h.folder(e)local i={}local j,k=
pcall(function()i.text=family(h,e,c.text,f,g)i.display=family(h,e,c.display,f,g)
end)if not j then warn('sottUI: fonts unavailable: '..tostring(k))end return i
end function b.image(e,f,g)local h=aa.files()if h==nil or aa.global(
'getcustomasset')==nil then return nil end h.folder(e)local i=e..'/'..g if h.
read(i)==nil then local j=aa.fetch(f..g)if j==nil or not h.write(i,j)then return
nil end end return h.asset(i)end return b end function a.r()local aa=a.cache.r
if not aa then aa={c=__modImpl()}a.cache.r=aa end return aa.c end end do local 
function __modImpl()local aa=a.f()local b={}local function stroke(c,d,e,f,g,h,i)
local j=aa('Frame',{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromOffset(h
,i),Size=UDim2.fromOffset(f,2),Rotation=g,BackgroundTransparency=0,Parent=c})d:
paint(j,'BackgroundColor3',e)return j end function b.new(c)local d={}function d.
chevron(e,f,g)local h=aa('Frame',{Size=UDim2.fromOffset(12,12),Parent=e})if g==
'right'then stroke(h,c,f,7,45,6,3.6)stroke(h,c,f,7,-45,6,8.4)elseif g=='up'then
stroke(h,c,f,7,-45,3.6,6)stroke(h,c,f,7,45,8.4,6)else stroke(h,c,f,7,45,3.6,6)
stroke(h,c,f,7,-45,8.4,6)end return h end function d.cross(e,f)local g=aa(
'Frame',{Size=UDim2.fromOffset(12,12),Parent=e})stroke(g,c,f,13,45,6,6)stroke(g,
c,f,13,-45,6,6)return g end function d.dash(e,f)local g=aa('Frame',{Size=UDim2.
fromOffset(12,12),Parent=e})stroke(g,c,f,12,0,6,6)return g end return d end
return b end function a.s()local aa=a.cache.s if not aa then aa={c=__modImpl()}a
.cache.s=aa end return aa.c end end do local function __modImpl()local aa={}aa.
__index=aa local function dispose(b)local c=typeof(b)if c=='RBXScriptConnection'
then b:Disconnect()elseif c=='Instance'then b:Destroy()elseif c=='function'then
b()elseif c=='thread'then task.cancel(b)elseif c=='table'then local d=b.destroy
or b.Destroy or b.Disconnect if d then d(b)end end end function aa.add(b,c)table
.insert(b._items,c)return c end function aa.clean(b)local c=b._items b._items={}
for d=#c,1,-1 do local e,f=pcall(dispose,c[d])if not e then warn(
'sottUI: cleanup failed: '..tostring(f))end end end aa.destroy=aa.clean return{
new=function()return((setmetatable({_items={}},aa)))end}end function a.t()local
aa=a.cache.t if not aa then aa={c=__modImpl()}a.cache.t=aa end return aa.c end
end do local function __modImpl()local aa=a.a()local b=a.t()local c=a.n()local d
={}local e={}e.__index=e function e.pointer(f)local g=f._guiService:GetGuiInset(
)return f._uis:GetMouseLocation()-g end function e.at(f,g)local h=g.Position
return Vector2.new(h.X,h.Y)end function e.capture(f,g,h,i)f:release()f._move=g f
._finish=h f._finger=i end function e.release(f)local g=f._finish f._move=nil f.
_finish=nil f._finger=nil if g then task.spawn(g,f:pointer())end end function e.
typing(f)return f._uis:GetFocusedTextBox()~=nil end function e.destroy(f)f._move
=nil f._finish=nil f._maid:clean()f.keyDown:clear()f.keyUp:clear()f.wheel:clear(
)f.moved:clear()f.pointerUp:clear()end function d.new()local f=aa.service(
'UserInputService')local g=b.new()local h=setmetatable({_uis=f,_guiService=aa.
service('GuiService'),_maid=g,_move=nil,_finish=nil,keyDown=c.new(),keyUp=c.new(
),wheel=c.new(),moved=c.new(),pointerUp=c.new()},e)g:add(f.InputChanged:Connect(
function(i)local j=i.UserInputType if j==Enum.UserInputType.MouseMovement then
local k=h:pointer()if h._move then h._move(k)end h.moved:fire(k)elseif j==Enum.
UserInputType.Touch then if h._move and(h._finger==nil or h._finger==i)then h.
_move(h:at(i))end elseif j==Enum.UserInputType.MouseWheel then h.wheel:fire(i.
Position.Z)end end))g:add(f.InputEnded:Connect(function(i,j)local k=i.
UserInputType if k==Enum.UserInputType.MouseButton1 or k==Enum.UserInputType.
Touch then if h._move and(k~=Enum.UserInputType.Touch or h._finger==nil or h.
_finger==i)then local l=if k==Enum.UserInputType.Touch then h:at(i)else h:
pointer()local m=h._finish h._move=nil h._finish=nil h._finger=nil if m then m(l
)end end h.pointerUp:fire()end h.keyUp:fire(i,j)end))g:add(f.InputBegan:Connect(
function(i,j)h.keyDown:fire(i,j)end))return h end return d end function a.u()
local aa=a.cache.u if not aa then aa={c=__modImpl()}a.cache.u=aa end return aa.c
end end do local function __modImpl()local aa={}local b={[Enum.UserInputType.
MouseButton1]='MB1',[Enum.UserInputType.MouseButton2]='MB2',[Enum.UserInputType.
MouseButton3]='MB3'}local c={MB1=Enum.UserInputType.MouseButton1,MB2=Enum.
UserInputType.MouseButton2,MB3=Enum.UserInputType.MouseButton3}local d={[Enum.
KeyCode.LeftAlt]='LAlt',[Enum.KeyCode.RightAlt]='RAlt',[Enum.KeyCode.LeftControl
]='LCtrl',[Enum.KeyCode.RightControl]='RCtrl',[Enum.KeyCode.LeftShift]='LShift',
[Enum.KeyCode.RightShift]='RShift'}local function nameOf(e)local f=b[e.
UserInputType]if f then return f end if e.UserInputType==Enum.UserInputType.
Keyboard and e.KeyCode.Name~='Unknown'then return e.KeyCode.Name end return nil
end function aa.new(e,f,g)local h=f.service('UserInputService')local i={}local j
={}local k=nil local l=false local m=nil local n=nil local function 
modifiersHeld(o)for p,q in(o or{})do local r=false for s,t in d do if t==q and h
:IsKeyDown(s)then r=true end end if not r then return false end end return true
end local function heldModifiers(o)local p={}for q,r in d do if q.Name~=o and h:
IsKeyDown(q)then table.insert(p,r)end end table.sort(p)return p end function i.
register(o,p)table.insert(j,p)end function i.unregister(o,p)local q=table.find(j
,p)if q then table.remove(j,q)end end function i.listen(o,p,q)i.cancel()k=p l=q
==true end function i.swallowed(o,p)return n==p end function i.cancel()local o=k
k=nil m=nil if o then o(nil)end end function i.state(o,p)local q=p.value if q==
nil then return false end if q.mode=='Always'then return true end if q.mode==
'Toggle'then return p.toggled==true end if q.key=='None'or k~=nil or e:typing()
then return false end local r=c[q.key]if r then return not g()and h:
IsMouseButtonPressed(r)and modifiersHeld(q.modifiers)end local s,t=pcall(
function()return h:IsKeyDown((Enum.KeyCode)[q.key])end)return s and t and
modifiersHeld(q.modifiers)end e.keyDown:connect(function(o)local p=nameOf(o)if p
==nil then return end if k then local q=b[o.UserInputType]~=nil if q and(l or p
=='MB1')then return end if d[o.KeyCode]and not q then m=p return end local r=k k
=nil m=nil n=p if p=='Escape'then(r)('None',{})else(r)(p,heldModifiers(p))end
return end if n==p then return end if e:typing()then return end for q,r in j do
local s=r.value if s.key==p and not r.disabled and modifiersHeld(s.modifiers)
then if s.mode=='Toggle'then r.toggled=not r.toggled end local t=r.spec.onPress
if t then t(r,r.toggled)end end end end)e.keyUp:connect(function(o)local p=
nameOf(o)if p==nil then return end if m==p and k then local q=k k=nil m=nil q(p,
{})return end if n==p then n=nil end for q,r in j do local s=r.value if s.key==p
and s.mode=='Hold'and r.spec.onRelease then r.spec.onRelease(r)end end end)
return i end return aa end function a.v()local aa=a.cache.v if not aa then aa={c
=__modImpl()}a.cache.v=aa end return aa.c end end do local function __modImpl()
local aa=a.f()local b=a.b()local c={}local d=320 local e=8 local f=20 local g=26
local h=5 function c.new(i,j)local k=i.theme local l={}local m={}local function 
layout()local n=j.AbsoluteSize local o=n.Y-f for p=#l,1,-1 do local q=l[p]o-=q.
height q.pos:to(UDim2.fromOffset(n.X-d-f,o))o-=e end end local function dismiss(
n)if n.gone then return end n.gone=true if n.timer then task.cancel(n.timer)end
local o=table.find(l,n)if o then table.remove(l,o)end local p=j.AbsoluteSize n.
pos:to(UDim2.fromOffset(p.X+8,n.frame.Position.Y.Offset),function()n.pos:
destroy()n.frame:Destroy()end)layout()end function m.show(n,o)while#l>=h do
dismiss(l[1])end local p=j.AbsoluteSize local q=aa('TextButton',{Name='Notice',
Position=UDim2.fromOffset(p.X+8,p.Y-f-60),Size=UDim2.fromOffset(d,60),
BackgroundTransparency=0,ZIndex=80,Parent=j})k:paint(q,'BackgroundColor3',
'surface')local r=aa('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
Parent=q})k:paint(r,'Color','lineStrong')local s=aa('Frame',{Size=UDim2.new(0,4,
1,0),BackgroundTransparency=0,ZIndex=81,Parent=q})k:paint(s,'BackgroundColor3',
'accent')local t=10 if o.title and o.title~=''then local u=aa('TextLabel',{
Position=UDim2.fromOffset(18,t),Size=UDim2.new(1,-32,0,24),TextSize=22,
TextTruncate=Enum.TextTruncate.AtEnd,Text=o.title,ZIndex=81,Parent=q})k:type(u,
'display')k:paint(u,'TextColor3','text')t+=26 end local u=nil if o.text and o.
text~=''then u=aa('TextLabel',{Position=UDim2.fromOffset(18,t),Size=UDim2.new(1,
-32,0,20),TextSize=16,TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top,
RichText=true,Text=o.text,ZIndex=81,Parent=q})k:type(u,'text')k:paint(u,
'TextColor3','muted')end local v={frame=q,height=t+28,pos=b.prop(q,'Position',g)
,gone=false}q.Size=UDim2.fromOffset(d,v.height)if u then task.defer(function()if
v.gone then return end local w=math.ceil(u.TextBounds.Y)if w>20 then u.Size=
UDim2.new(1,-32,0,w)v.height=t+w+10 q.Size=UDim2.fromOffset(d,v.height)layout()
end end)end v.pos:snap(UDim2.fromOffset(p.X+8,p.Y-f-v.height))table.insert(l,v)q
.Activated:Connect(function()dismiss(v)end)v.timer=task.delay(o.seconds or 5,
function()v.timer=nil dismiss(v)end)layout()end function m.destroy(n)for o,p in
table.clone(l)do if p.timer then task.cancel(p.timer)end p.pos:destroy()p.frame:
Destroy()end table.clear(l)end return m end return c end function a.w()local aa=
a.cache.w if not aa then aa={c=__modImpl()}a.cache.w=aa end return aa.c end end
do local function __modImpl()local aa=a.f()local b=a.b()local c={}local d=34
local e=48 local f=0.55 local g=340 local h=40 local i=8 function c.popover(j,k)
local l=j.theme local m={}local n=nil local function close()local o=n if o==nil
then return end n=nil o.catcher:Destroy()o.open=false o.size.speed=e o.size:to(
UDim2.fromOffset(o.width,0),function()o.size:destroy()o.frame:Destroy()end)if o.
disconnectEl then o.disconnectEl()end end function m.open(o,p,q,r,s)close()local
t=k.AbsoluteSize local u,v=p.AbsolutePosition-k.AbsolutePosition,p.AbsoluteSize
q=math.min(q,t.X-2*i)r=math.min(r,t.Y-2*i)local w=if q>v.X then u.X+v.X-q else u
.X local x=math.clamp(w,i,t.X-q-i)local y=u.Y+v.Y+2 local z=math.max(j.
popoverTop(),i)local A=y+r+i>t.Y and u.Y-r-2>z local B=if A then u.Y-r-2 else
math.max(math.min(y,t.Y-r-i),z)local C=aa('TextButton',{Name='Catcher',Size=
UDim2.fromScale(1,1),ZIndex=60,Parent=k})local D=aa('Frame',{Name='Popover',
Position=UDim2.fromOffset(x,B),Size=UDim2.fromOffset(q,0),BackgroundTransparency
=0,ClipsDescendants=true,ZIndex=61,Active=true,Parent=k})l:paint(D,
'BackgroundColor3','raised')local E=aa('UIStroke',{ApplyStrokeMode=Enum.
ApplyStrokeMode.Border,Parent=D})l:paint(E,'Color','lineStrong')local F=aa(
'Frame',{Size=UDim2.fromScale(1,1),Parent=D})local G={frame=D,catcher=C,width=q,
open=true,size=b.prop(D,'Size',d)}n=G C.MouseButton1Down:Connect(close)C.
MouseButton2Down:Connect(close)local H={close=close,resize=function(H)if G.open
then G.size:to(UDim2.fromOffset(q,H))end end,onKey=function(H)G.onKey=H end,
onRefresh=function(H)G.onRefresh=H end}s(F,H)G.size:to(UDim2.fromOffset(q,r))end
function m.isOpen(o)return n~=nil end function m.close(o)close()end function m.
key(o,p)if n==nil then return false end if p=='Escape'then close()return true
end if n.onKey then n.onKey(p)return true end return false end return m end
function c.tooltip(j,k)local l=j.theme local m=aa('Frame',{Name='Tooltip',
AutomaticSize=Enum.AutomaticSize.XY,BackgroundTransparency=0,Visible=false,
ZIndex=70,Parent=k})l:paint(m,'BackgroundColor3','raised')local n=aa('UIStroke',
{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=m})l:paint(n,'Color',
'lineStrong')aa('UIPadding',{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,
10),PaddingTop=UDim.new(0,7),PaddingBottom=UDim.new(0,7),Parent=m})local o=aa(
'TextLabel',{AutomaticSize=Enum.AutomaticSize.XY,TextSize=16,TextWrapped=true,
ZIndex=71,Parent=m})aa('UISizeConstraint',{MaxSize=Vector2.new(g,400),Parent=o})
l:type(o,'text')l:paint(o,'TextColor3','text')local p={}local q=nil function p.
hide(r)if q then task.cancel(q)q=nil end m.Visible=false end local r=b.prop(m,
'Position',h)function p.showAt(s,t,u)s:hide()o.Text=u m.Visible=true task.defer(
function()if not m.Visible then return end local v=k.AbsoluteSize local w=m.
AbsoluteSize local x=t.AbsolutePosition-k.AbsolutePosition local y=math.clamp(x.
X,i,v.X-w.X-i)local z=x.Y+t.AbsoluteSize.Y+3 local A=z+w.Y+i>v.Y local B=if A
then x.Y-w.Y-3 else z r:snap(UDim2.fromOffset(y,B+(if A then 8 else-8)))r:to(
UDim2.fromOffset(y,B))end)end function p.schedule(s,t,u)s:hide()q=task.delay(f,
function()q=nil if t.Parent~=nil then s:showAt(t,u)end end)end return p end
function c.hover(j)local k={}local l=nil local function clear()local m=l if m
then l=nil m:onHover(false)j.tooltip:hide()end end function k.current(m)return l
end function k.enter(m,n)if l==n then return end clear()l=n n:onHover(true)local
o=n.el local p=if o.disabled and o.disabledTip then o.disabledTip else o.tip if
p and p~=''then j.tooltip:schedule(n.root,p)end end function k.leave(m,n)if l==n
then clear()end end k.clear=clear function k.verify(m,n)local o=l if o==nil then
return end local p=o.root local q,r=p.AbsolutePosition,p.AbsoluteSize local s=n.
X>=q.X and n.Y>=q.Y and n.X<=q.X+r.X and n.Y<=q.Y+r.Y if not s or not p.Visible
or p.Parent==nil or j.popover:isOpen()then clear()end end return k end return c
end function a.x()local aa=a.cache.x if not aa then aa={c=__modImpl()}a.cache.x=
aa end return aa.c end end do local function __modImpl()local aa=a.m()local b=a.
f()local c=a.j()local d=a.b()local e=a.p()local f=a.l()local g={}local h=12
local i=600 local j=8 local k=2 local l=20 local m=14 local n=40 local o=16
local p=60 local q=14 local r=76 local s=10 local t=40 local u=22 local v=148
local w=50 local x=64 local y=0 local z=36 local A=360 local B=110 local C=24
local D=28 local E={toggle=4,button=4,key=4,color=4,slider=4,dropdown=4,stat=3,
input=8}local function needs(F)local G=F.kind if G=='stat'or G=='input'then
return 0 end local H=26 if G=='slider'then H=aa.readoutWidth(F)+12 elseif G==
'dropdown'then H=96 end for I,J in F.addons or{}do if not J.spec.chipless then H
+=if J.kind=='key'then 58 else 28 end end return c.width('textMedium',F.label,f.
NAME)*1.05+2*f.PAD+H end local function spanOf(F)if F.kind=='label'and F.addons
then return 4 end return E[F.kind]end local F={}F.__index=F local function 
textHeight(G,H)if G.kind=='divider'then return if G.label==''then 8 else 28 end
if not G.spec.wrap then return 32 end if G._measured then return G._measured end
local I=math.max(math.floor(H/7.6),10)local J=string.gsub(G.label,'<[^>]+>','')
return math.ceil(#J/I)*21+12 end function F.nextId(G)G._ids+=1 return G._ids end
function F._register(G,H,I)H._relayout=function()G:_invalidate()end G.window:
_registerElement(H,G,I)end function F._invalidate(G)if G._dirty then return end
G._dirty=true task.defer(function()G._dirty=false if not G.destroyed then G:
layout(not G._quiet)G._quiet=false end end)end function F.section(G,H)local I=e.
new(G,H)table.insert(G.sections,I)G:_invalidate()return I end function F.tabset(
G)local H=e.new(G,'')H.tabNames={}H.activeTab=1 table.insert(G.sections,H)local
I={}function I.tab(J,K)table.insert(H.tabNames,K)local L=#H.tabNames local M=H:
when(function()return H.activeTab==L end)M.title=K local N=G._headers[H]if N
then N:Destroy()G._headers[H]=nil end G:_invalidate()return M end return I end
function F.tabs(G,H)local I=G:tabset()local J={}for K,L in H do table.insert(J,I
:tab(L))end return J end function F.hero(G,H)G._hero=H G:_invalidate()local I=G.
_heroView return{set=function(J,K,L)H.title=K or H.title H.text=L or H.text
local M=G._heroView or I if M then M.refresh()end end}end local function 
buildHero(G)local H=G.window.ctx local I=H.theme local J=G._hero local K=b(
'Frame',{Name='Hero',Parent=G.canvas})local L=b('Frame',{Size=UDim2.fromOffset(v
-16,v-16),BackgroundTransparency=0,ClipsDescendants=true,Parent=K})I:paint(L,
'BackgroundColor3','accent')if J.userId then b('ImageLabel',{Size=UDim2.
fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,Image=string.format(
'rbxthumb://type=AvatarBust&id=%d&w=420&h=420',J.userId),Parent=L})end local M=
b('TextLabel',{Position=UDim2.fromOffset(v+2,16),Size=UDim2.new(1,-(v+2),0,68),
TextSize=64,TextTruncate=Enum.TextTruncate.AtEnd,Parent=K})I:type(M,'display')I:
paint(M,'TextColor3','text')local N=b('TextLabel',{Position=UDim2.fromOffset(v+2
,88),Size=UDim2.new(1,-(v+2),0,44),TextSize=17,TextWrapped=true,TextYAlignment=
Enum.TextYAlignment.Top,Parent=K})I:type(N,'text')I:paint(N,'TextColor3','muted'
)local O={root=K,refresh=function()M.Text=J.title N.Text=J.text or''end}O.
refresh()return O end local function buildHeader(G,H)local I=G.window.ctx local
J=I.theme local K=b('Frame',{Name='Header',Parent=G.canvas})if H.tabNames then
local L={}local M=0 for N,O in H.tabNames do local P=math.ceil(c.width(
'textMedium',O,18))+20 local Q=b('TextButton',{Position=UDim2.fromOffset(M,0),
Size=UDim2.new(0,P,1,-8),TextSize=18,Text=O,TextXAlignment=Enum.TextXAlignment.
Left,Parent=K})J:type(Q,'text',true)L[N]=Q Q.Activated:Connect(function()H.
activeTab=N for R,S in L do J:paint(S,'TextColor3',if R==H.activeTab then'text'
else'faint')end G:_invalidate()end)J:paint(Q,'TextColor3',if N==H.activeTab then
'text'else'faint')M+=P end else local L=b('TextLabel',{Size=UDim2.new(1,0,1,-6),
TextSize=26,Text=H.title,Parent=K})J:type(L,'display')J:paint(L,'TextColor3',
'text')end return K end function F.layout(G,H)local I=G.frame if I==nil then
return end G._live=H==true and G._settled==true and G.active local J=G.window.
ctx.uiScale()local K=I.AbsoluteSize.X/J if K<1 then return end local L=K-2*l
local M=L<i local N=(L-(h-1)*j)/h local O=m local P={}if G._hero then table.
insert(P,{hero=true,x=l,y=O,width=L,height=v})O+=v end local function placeRows(
Q,R)do local S=false local T,U={},0 local function flush()if#T==0 then return
end local V,W=l,0 for X,Y in T do local Z=if M and#T==1 then h else Y.span local
_=Z*N+(Z-1)*j local ab=Y.height W=math.max(W,ab)table.insert(P,{el=Y.el,x=V,y=O,
width=_,height=ab})V+=_+j end O+=W+j T,U={},0 end for ab,V in R do local W=
spanOf(V)if W==nil then flush()if V.kind=='divider'and V.label==''and S then
continue end local X=textHeight(V,L)table.insert(P,{el=V,x=l,y=O,width=L,height=
X})O+=X+k elseif V.spec.primary then flush()local X=if V.value==true then x else
w table.insert(P,{el=V,x=l,y=O,width=L,height=X})O+=X+j+y S=true else local X=if
Q.flat then h elseif M then(if W<=h/3 then h/2 else h)else W while X<h and
needs(V)>X*N+(X-1)*j do X+=if M then h-X else 4 end if U+X>h then flush()end S=
false table.insert(T,{el=V,span=X,height=if V.kind=='stat'then z else f.HEIGHT})
U+=X end end flush()end end local ab={}local function flushBoard()if#ab==0 then
return end local Q=(L-j)/2 local R=1 while R<=#ab do local S,T=ab[R],ab[R+1]
table.insert(P,{el=S.masterElement,x=l,y=O,width=if T then Q else L,height=r})if
T then table.insert(P,{el=T.masterElement,x=l+Q+j,y=O,width=Q,height=r})end O+=r
+j for U,V in{S,T}do if V and V.peeking then local W={}for X,Y in V.rows do if Y
~=V.masterElement and Y:shown()then table.insert(W,Y)end end placeRows(V,W)O+=s
end end R+=2 end table.clear(ab)O+=u-j end for Q,R in G.sections do if R.
masterElement and not R.flat then if R.masterElement:shown()then table.insert(ab
,R)end else flushBoard()local S={}for T,U in R.rows do if R.flat or U:shown()
then table.insert(S,U)end end if#S>0 or R.tabNames then if R.title~=''or R.
tabNames then table.insert(P,{section=R,x=l,y=O,width=L,height=t})O+=t end
placeRows(R,S)O+=u end end end flushBoard()local Q=G.sections[1]and G.sections[1
].flat local R=O-u+(if Q then o else n)if G._emptyVisible then R=math.max(R,p)
end I.CanvasSize=UDim2.fromOffset(0,R)G._contentHeight=R local S=math.max(R-I.
AbsoluteSize.Y/G.window.ctx.uiScale(),0)if G._scrollTarget and G._scrollTarget>S
then G._scrollTarget=S end G._placements=P if G.active then G.window:
_contentChanged(R,H)end G:_applyPlacements()G:_materialize(true)G:_refreshThumb(
)G._live=false G._settled=G._settled or G.active end local function growTo(ab,G,
H,I)if ab._grow==nil then ab._grow=ab:own(d.prop(ab.root,'Size',D))end ab._grow:
to(UDim2.fromOffset(G,H),I)end local function setSize(ab,G,H)local I=UDim2.
fromOffset(G,H)if ab._grow then ab._grow:snap(I)else ab.root.Size=I end end
function F._applyPlacements(ab)local G={}for H,I in ab._placements do if I.hero
then if ab._heroView then ab._heroView.root.Position=UDim2.fromOffset(I.x,I.y)ab
._heroView.root.Size=UDim2.fromOffset(I.width,I.height)end elseif I.section then
G[I.section]=true local J=ab._headers[I.section]if J then J.Visible=true J.
Position=UDim2.fromOffset(I.x,I.y)J.Size=UDim2.fromOffset(I.width,I.height)end
else G[I.el]=true local J=ab._views[I.el]if J then ab:_place(J,I)end end end for
H,I in ab._headers do if not G[H]then I.Visible=false end end for H,I in ab.
_views do if not G[H]and I.root.Visible and not I._folding then if ab._live then
I._folding=true growTo(I,I.root.Size.X.Offset,0,function()I._folding=false I.
root.Visible=false end)else I.root.Visible=false end end end end function F.
_place(ab,G,H)local I=G.root local J=UDim2.fromOffset(H.x,H.y)local K=ab._live
local L=K and not I.Visible local M=G._folding==true G._folding=false I.Visible=
true if L then setSize(G,H.width,0)growTo(G,H.width,H.height)elseif M then
growTo(G,H.width,H.height)elseif K and G._grow==nil and I.Size.Y.Offset~=H.
height then growTo(G,H.width,H.height)elseif K and G._grow and G._grow.target.Y.
Offset~=H.height then growTo(G,H.width,H.height)else setSize(G,H.width,H.height)
end if K and not L and I.Position~=J then if G._slide==nil then G._slide=G:own(d
.prop(I,'Position',D))end G._slide:to(J)elseif G._slide then G._slide:snap(J)
else I.Position=J end end function F._materialize(ab,G)local H=ab.frame local I=
ab._placements if H==nil or I==nil or not ab.active then return end local J=ab.
window.ctx.uiScale()local K=H.CanvasPosition.Y/J if not G and ab._lastSync and
math.abs(K-ab._lastSync)<A/3 then return end ab._lastSync=K local L,M=K-A,K+H.
AbsoluteSize.Y/J+A for N,O in I do local P=O.y if P+O.height>=L and P<=M then if
O.hero then if ab._heroView==nil then local Q=buildHero(ab)Q.root.Position=UDim2
.fromOffset(O.x,P)Q.root.Size=UDim2.fromOffset(O.width,O.height)ab._heroView=Q
end elseif O.section then if ab._headers[O.section]==nil then local Q=
buildHeader(ab,O.section)Q.Position=UDim2.fromOffset(O.x,P)Q.Size=UDim2.
fromOffset(O.width,O.height)ab._headers[O.section]=Q end elseif ab._views[O.el]
==nil then O.el._shownOn=ab local Q,R=xpcall(aa.build,debug.traceback,ab.window.
ctx,O.el)if Q then R.root.Position=UDim2.fromOffset(O.x,P)R.root.Size=UDim2.
fromOffset(O.width,if ab._live then 0 else O.height)R.root.Parent=ab.canvas ab.
_views[O.el]=R if ab._live then growTo(R,O.width,O.height)end else warn(
'sottUI: tile '..tostring(O.el.id)..' failed: '..tostring(R))end end end end end
function F._refreshThumb(ab)local G=ab.thumb if G==nil then return end local H=
ab.window.ctx.uiScale()local I=ab.frame.AbsoluteSize.Y/H local J=ab.
_contentHeight or 0 if J<=I+1 or not ab.active then G.Visible=false return end G
.Visible=true local K=math.max(I*I/J,40)local L=I-K local M=ab.frame.
CanvasPosition.Y/H/math.max(J-I,1)G.Size=UDim2.new(0,3,0,K)G.Position=UDim2.new(
1,-6,0,M*L)end function F.scrollTo(ab,G,H)local I=ab.frame if I==nil then return
end local J=ab.window.ctx.uiScale()local K=math.max((ab._contentHeight or 0)-I.
AbsoluteSize.Y/J,0)local L=math.clamp(G,0,K)ab._scrollTarget=L if H then ab.
_scroll:snap(L)else ab._scroll:to(L)end end function F.wheel(ab,G)if ab.frame==
nil or ab.frame.ScrollingEnabled then return end local H=ab._scrollTarget or ab.
frame.CanvasPosition.Y/ab.window.ctx.uiScale()ab:scrollTo(H-G*B)end function F.
rowY(ab,G)if ab._placements==nil then ab:layout()end for H,I in ab._placements
or{}do if I.el==G then return I.y end end return nil end function F.viewOf(ab,G)
return ab._views[G]end function F.mount(ab,G)if ab.frame then return end local H
=ab.window.ctx local I=b('ScrollingFrame',{Name=ab.name,Size=UDim2.fromScale(1,1
),Visible=false,ScrollingEnabled=H.touch,Parent=G})local J=b('Frame',{Name=
'Canvas',Size=UDim2.fromScale(1,1),Parent=I})local K=b('Frame',{Name='Thumb',
BackgroundTransparency=0,Visible=false,ZIndex=5,Parent=G})H.theme:paint(K,
'BackgroundColor3','lineStrong')ab.frame=I ab.canvas=J ab.thumb=K ab._scroll=d.
new(0,C,function(L)I.CanvasPosition=Vector2.new(0,L*H.uiScale())end)I:
GetPropertyChangedSignal('CanvasPosition'):Connect(function()ab:_materialize()ab
:_refreshThumb()end)local L=0 I:GetPropertyChangedSignal('AbsoluteSize'):
Connect(function()local M=I.AbsoluteSize.X if M~=L then L=M ab._quiet=true ab:
_invalidate()else ab:_materialize(true)ab:_refreshThumb()end end)end function F.
showList(ab,G,H)ab.sections={{title='',rows=G,flat=true}}for I,J in G do J.
_shownOn=ab end if ab.frame then if ab._empty==nil then local I=ab.window.ctx.
theme ab._empty=b('TextLabel',{Position=UDim2.fromOffset(l,12),Size=UDim2.new(1,
-2*l,0,36),TextSize=17,Parent=ab.frame})I:type(ab._empty,'text')I:paint(ab.
_empty,'TextColor3','muted')end ab._empty.Text=H or''ab._empty.Visible=H~=nil ab
._emptyVisible=H~=nil end ab:_invalidate()end function F.adopt(ab)for G,H in ab.
_views do G._view=H G._shownOn=ab if H.refresh then H.refresh()end for I,J in H.
addonChips or{}do I._view=J if J.refresh then J.refresh()end end end end
function F.fitHeight(ab,G)local H=0 for I,J in ab._placements or{}do if J.el
then local K=J.y+J.height if K+q<=G and K>H then H=K end end end if H==0 then
return G end local I=math.huge for J,K in ab._placements do if K.y>=H and K.y<I
then I=K.y end end return math.min(H+q,I)end function F.setActive(ab,G)ab.active
=G if ab.frame then ab.frame.Visible=G if not G then ab.thumb.Visible=false end
end if G then ab:layout()end end function F.destroy(ab)ab.destroyed=true for G,H
in ab._views do H.destroy()end ab._views={}if ab._scroll then ab._scroll:
destroy()end if ab.frame then ab.frame:Destroy()ab.thumb:Destroy()end end
function g.new(ab,G)return setmetatable({name=G,window=ab,sections={},active=
false,destroyed=false,_ids=0,_dirty=false,_headers={},_views={},_placements=nil}
,F)end return g end function a.y()local aa=a.cache.y if not aa then aa={c=
__modImpl()}a.cache.y=aa end return aa.c end end do local function __modImpl()
local aa=a.f()local ab=UDim2.fromOffset(16,72)local b=44 return function(c,d,e)
local f=aa('TextButton',{Name='Open',Position=ab,Size=UDim2.fromOffset(b,b),
BackgroundTransparency=0,TextSize=24,Text='s',Visible=false,ZIndex=50,Parent=c})
d:type(f,'display')d:paint(f,'BackgroundColor3','accent')d:paint(f,'TextColor3',
'onAccent')f.Activated:Connect(e)return f end end function a.z()local aa=a.cache
.z if not aa then aa={c=__modImpl()}a.cache.z=aa end return aa.c end end do
local function __modImpl()local aa=a.n()local ab={}local function rgb(b)return
Color3.fromRGB(bit32.band(bit32.rshift(b,16),255),bit32.band(bit32.rshift(b,8),
255),bit32.band(b,255))end local b={base=rgb(0x7100d),surface=rgb(0x141c18),
raised=rgb(0x1e2b25),line=rgb(0x1a2d27),lineStrong=rgb(0x2f4a40),text=rgb(
0xebe8da),muted=rgb(0xb4c2b8),faint=rgb(0x5f756b),accent=rgb(0x7ee0c4),
accentHover=rgb(0x9bebd4),accentDim=rgb(0x1f4a3e),onAccent=rgb(0xb1a13),danger=
rgb(0xe5604d)}local c='rbxasset://fonts/families/BuilderSans.json'local d=
'rbxasset://fonts/families/RobotoCondensed.json'local e={}e.__index=e function
ab.defaults()return table.clone(b)end function ab.new(f)local g=(ab.defaults())
for h,i in(f or{})do g[h]=i end local h={tokens=g,fonts={text=c,display=d},
changed=aa.new(),_paints={},_types={},_count=0}return((setmetatable(h,e)))end
local f=2000 local function sweep(g)for h in g._paints do if h.Parent==nil then
g._paints[h]=nil g._types[h]=nil end end for h in g._types do if h.Parent==nil
then g._types[h]=nil end end end function e.paint(g,h,i,j)local k=g._paints[h]if
k==nil then k={}g._paints[h]=k g._count+=1 if g._count%f==0 then task.defer(
sweep,g)end end k[i]=j h[i]=g.tokens[j]end function e.face(g,h,i)if h=='display'
then return Font.new(g.fonts.display,Enum.FontWeight.ExtraBold)end return Font.
new(g.fonts.text,if i then Enum.FontWeight.Medium else Enum.FontWeight.Regular)
end function e.type(g,h,i,j)g._types[h]={family=i,medium=j==true}h.FontFace=g:
face(i,j)end function e.forget(g,h)g._paints[h]=nil g._types[h]=nil end function
e.apply(g,h)for i,j in h do g.tokens[i]=j end for i,j in g._paints do for k,l in
j do pcall(function()i[k]=g.tokens[l]end)end end g.changed:fire()end function e.
setFonts(g,h,i)g.fonts.text=h or g.fonts.text g.fonts.display=i or g.fonts.
display for j,k in g._types do pcall(function()j.FontFace=g:face(k.family,k.
medium)end)end end return ab end function a.A()local aa=a.cache.A if not aa then
aa={c=__modImpl()}a.cache.A=aa end return aa.c end end do local function 
__modImpl()local aa=a.b()local ab={}local b=26 function ab.new(c)local d={}
return function(e,f,g,h)local i=d[e]if i==nil then i={}d[e]=i end local j=i[f]if
j==nil then j=aa.prop(e,f,h or b)i[f]=j end j:to(c.tokens[g])end end return ab
end function a.B()local aa=a.cache.B if not aa then aa={c=__modImpl()}a.cache.B=
aa end return aa.c end end do local function __modImpl()local aa=a.q()local ab=a
.a()local b=a.r()local c=a.s()local d=a.u()local e=a.v()local f=a.t()local g=a.
f()local h=a.j()local i=a.b()local j=a.w()local k=a.x()local l=a.y()local m=a.h(
)local n=a.p()local o=a.z()local p=a.n()local q=a.A()local r=a.B()local s={}
local t='main'local u=
[[https://raw.githubusercontent.com/interestng/sottUI/%s/fonts/]]local v=520
local w=64 local x=64 local y=76 local z=18 local A=26 local B=17 local C=16
local D=1 local E=64 local F=124 local G=40 local H=44 local I=28 local J=12
local K=600 local L=760 local M=38 local N=28 local O=30 local P=30 local Q=4
local R=6 local S=24 local T=12 local U={}U.__index=U local function randomName(
)local V=table.create(T)for W=1,T do V[W]=string.char(math.random(97,122))end
return table.concat(V)end local function encode(V)return ab.service(
'HttpService'):JSONEncode(V)end local function decode(V)local W,X=pcall(function
()return ab.service('HttpService'):JSONDecode(V)end)return if W then X else nil
end function U._registerElement(V,W,X,Y)if X==V._resultsPage or X==V._onPage
then return end W._pageName=X.name W._page=X if Y then if V.elements[W.id]then
error('sottUI: element id used twice: '..W.id,3)end V.elements[W.id]=W end if W.
kind~='divider'and W.kind~='label'and W.kind~='stat'then table.insert(V.ordered,
W)end if W.kind=='toggle'then W:on(function()if V._showing==V._onPage and V.
isOpen then V:_fillOn()end if W.spec.primary then V:_drawChips()if V._showing==V
._resultsPage then V._resultsPage:_invalidate()end end end)if W.spec.primary
then W._onLabel=function()V:_drawChips()end if W.value==true then V:_drawChips()
end end end end function U._drawChips(V)if V._chipsQueued or V.destroyed then
return end V._chipsQueued=true task.defer(function()V._chipsQueued=false if V.
destroyed then return end local W={}for X,Y in V.ordered do if Y.kind=='toggle'
and Y.spec.primary and Y.value==true and not Y.disabled and Y:shown()then table.
insert(W,Y)end end for X,Y in V._chips do Y:Destroy()end table.clear(V._chips)
local X=V.ctx.theme local Y=0 local function widthOf(Z)return math.ceil(h.width(
'textMedium',Z,B))+2*C end local function add(Z,_,ac,ad)local ae=widthOf(Z)local
af=g('TextButton',{Name='Chip',Size=UDim2.new(0,ae,1,0),BackgroundTransparency=0
,TextSize=B,Text=Z,LayoutOrder=_,ZIndex=3,Parent=V._chipRow})Y+=ae+D X:type(af,
'text',true)X:paint(af,'BackgroundColor3','surface')X:paint(af,'TextColor3',
'accent')af.MouseEnter:Connect(function()V.ctx.tint(af,'BackgroundColor3',
'accent')V.ctx.tint(af,'TextColor3','onAccent')task.defer(function()V.ctx.
tooltip:schedule(af,ac)end)end)af.MouseLeave:Connect(function()V.ctx.tint(af,
'BackgroundColor3','surface')V.ctx.tint(af,'TextColor3','accent')V.ctx.tooltip:
hide()end)af.Activated:Connect(ad)table.insert(V._chips,af)end local ac=V._scale
.Scale local ad=V:_dockPoint()local ae=ad+(V._dockWidth or 0)*ac/2 local af=(V.
_gui.AbsoluteSize.X-ae)/ac-D-J for Z,_ in W do local ag=#W-Z local ah=widthOf(_.
label)+(if ag>0 then E else 0)if Z>R or Y+ah>af then add('+'..(ag+1),100+Z,
'Show everything running',function()V:_fillOn()V:_show(V._onPage)end)break end
add(_.label,100+Z,'Turn off '.._.label,function()_:set(false)end)end V._chipRow.
Size=UDim2.new(0,Y,1,0)end)end function U._setPerson(ac,ad)ac._person=ad end
function U._contentChanged(ac,ad,ae)if ac._showing==nil then return end local af
=ac._scale.Scale local ag=ac._sheetRoom/af-J local ah=math.min(ad,K,ag)if ad>ah
then ah=ac._showing:fitHeight(ah)end local V=UDim2.new(0,ac._sheetWidth,0,ah)if
ae or ac._sheetRise then ac._panelSize:to(V)else ac._panelSize:snap(V)end end
function U._placeSheet(ac)local ad=ac._scale.Scale local ae,af=ac:_dockPoint()
local ag=ae-(ac._dockWidth or 0)*ad/2 local ah=af-w*ad local V=ac._gui.
AbsoluteSize.Y local W=ah>=V/2 ac._sheetAbove=W ac._sheetRoom=if W then ah else
V-af ac._panel.AnchorPoint=Vector2.new(0,if W then 1 else 0)ac._panel.Position=
UDim2.fromOffset(math.floor(ag),math.floor(if W then ah else af))end function U.
_dockPoint(ac)local ad=ac._dockAt if ad then return ad.X,ad.Y end local ae=ac.
_gui.AbsoluteSize return ae.X/2,ae.Y-y end function U._home(ac)local ad=ac.
_dockAt return if ad then UDim2.fromOffset(ad.X,ad.Y)else UDim2.new(0.5,0,1,-y)
end function U._away(ac)local ad=ac._dockAt if ad and ad.Y<ac._gui.AbsoluteSize.
Y/2 then return UDim2.fromOffset(ad.X,-J)end return ac:_home()+UDim2.fromOffset(
0,w*ac._scale.Scale+y+J)end function U._clampDock(ac)local ad=ac._dockAt if ad==
nil then return end local ae=ac._scale.Scale local af=ac._gui.AbsoluteSize local
ag=(ac._dockWidth or 0)*ae/2 ac._dockAt=Vector2.new(math.clamp(ad.X,math.min(ag+
J,af.X/2),math.max(af.X-ag-J,af.X/2)),math.clamp(ad.Y,w*ae+J,math.max(af.Y-J,w*
ae+J)))end function U._show(ac,ad,ae)if ac._showing==ad then return end ac.ctx.
hover.clear()ac.ctx.popover:close()ac.keys:cancel()local af=ac._showing if af
then af:setActive(false)end local ag=ac._leaving if ag and ag~=ad then ag:
setActive(false)end ac._leaving=nil ac._showing=ad ac:_placeSheet()ac._sheetRise
=not ae ad:setActive(true)ac._sheetRise=false ad:adopt()ac:_syncMarker(ae)ac:
_saveState()end function U._hideSheet(ac)local ad=ac._showing if ad==nil then
return end ac.ctx.hover.clear()ac.ctx.popover:close()ac.keys:cancel()ac._showing
=nil ac._leaving=ad ac._panelSize:to(UDim2.new(0,ac._sheetWidth,0,0),function()
if ac._leaving==ad then ac._leaving=nil ad:setActive(false)end end)ac:
_syncMarker()end function U._syncMarker(ac,ad)local ae=ac.ctx.tint local af=nil
for ag,ah in ac._words do local V=ac._showing==ag if ah:IsA('TextButton')and ah.
Text~=''then ae(ah,'TextColor3',if V then'text'else'muted')end if V then af=ah
end end if af==nil or af==ac._homeAvatar then ac._markerSize:to(UDim2.
fromOffset(0,Q))return end ac.ctx.theme:paint(ac._marker,'BackgroundColor3',if
af==ac._homeAvatar then'onAccent'else'accent')local ag=ac._scale.Scale local ah=
(af.AbsolutePosition.X-ac._dock.AbsolutePosition.X)/ag local V=UDim2.fromOffset(
ah,if ac._sheetAbove==false then w-Q else 0)local W=UDim2.fromOffset(af.
AbsoluteSize.X/ag,Q)if ad or ac._markerSize.target==nil or ac._markerSize.target
.X.Offset==0 then ac._markerAt:snap(V)else ac._markerAt:to(V)end if ad then ac.
_markerSize:snap(W)else ac._markerSize:to(W)end end local function bindWord(ac,
ad,ae)ac._words[ad]=ae ae.Activated:Connect(function()if ac._box.Text~=''then ac
._box.Text=''end if ac._showing==ad then ac:_hideSheet()else ac:_show(ad)end end
)end local function addWord(ac,ad,ae,af)local ag=ac.ctx.theme local ah=math.
ceil(h.width('textMedium',ae,z))+2 local V=g('TextButton',{Name=ae,Size=UDim2.
new(0,ah,1,0),TextSize=z,Text=ae,LayoutOrder=af,ZIndex=3,Parent=ac._row})ag:
type(V,'text',true)ag:paint(V,'TextColor3','muted')bindWord(ac,ad,V)V.MouseEnter
:Connect(function()if ac._showing~=ad then ac.ctx.tint(V,'TextColor3','text')end
end)V.MouseLeave:Connect(function()if ac._showing~=ad then ac.ctx.tint(V,
'TextColor3','muted')end end)end function U.page(ac,ad)local ae=l.new(ac,ad)
table.insert(ac.pages,ae)if ad=='Home'and ac._homeAvatar then bindWord(ac,ae,ac.
_homeAvatar)else addWord(ac,ae,ad,2+#ac.pages)end ae:mount(ac._panel)return ae
end function U._fillOn(ac)local ad,ae={},{}for af,ag in ac.ordered do if ag.kind
=='toggle'and ag.value==true then table.insert(if ag.spec.primary then ad else
ae,ag)end end if#ad==0 then ad=ae end ac._onPage:showList(ad,if#ad==0 then
'Nothing is on'else nil)end function U._query(ac,ad)if ad==''then if ac._showing
==ac._resultsPage then ac:_hideSheet()end ac._resultsPage:showList({})return end
local ae={}for af,ag in ac.ordered do if ag.visible~=false then table.insert(ae,
ag)end end local af=m.settings(ad,ae,S)ac._resultsPage:showList(af,if#af==0 then
'Nothing matches'else nil)ac:_show(ac._resultsPage)end function U.showPage(ac,ad
)for ae,af in ac.pages do if af.name==ad then ac._box.Text=''ac:_show(af)return
end end end function U.show(ac,ad,ae)local af=ac.pages[ad]if af then ac:_show(af
,ae)end end function U.reveal(ac,ad)local ae=ad._page if ae then ac:setOpen(true
)ac:showPage(ae.name)end end function U.setOpen(ac,ad)if ac.isOpen==ad or ac.
destroyed then return end ac.isOpen=ad if ac._opener then ac._opener.Visible=not
ad end ac.ctx.hover.clear()ac.ctx.popover:close()ac.ctx.tooltip:hide()ac.keys:
cancel()if not ad and ac._dialogClose then ac._dialogClose()end if ad then ac.
_root.Visible=true ac._modal.Visible=true ac:_guardCursor(true)ac._at:to(ac:
_home())ac:_drawChips()else ac._modal.Visible=false ac:_guardCursor(false)ac.
_box:ReleaseFocus()ac._box.Text=''ac:_hideSheet()ac._at:to(ac:_away(),function()
if not ac.isOpen then ac._root.Visible=false end end)end ac.visibilityChanged:
fire(ad)end function U._guardCursor(ac,ad)local ae=ab.service('UserInputService'
)if ad then ac._gameCursor=ae.MouseIconEnabled ae.MouseIconEnabled=true if ac.
_cursorGuard==nil then ac._cursorGuard=ae:GetPropertyChangedSignal(
'MouseIconEnabled'):Connect(function()if not ae.MouseIconEnabled then ac.
_gameCursor=false ae.MouseIconEnabled=true end end)end else if ac._cursorGuard
then ac._cursorGuard:Disconnect()ac._cursorGuard=nil end if ac._gameCursor~=nil
then ae.MouseIconEnabled=ac._gameCursor ac._gameCursor=nil end end end function
U.toggle(ac)ac:setOpen(not ac.isOpen)end function U.notify(ac,ad)if ac.destroyed
then return end ac.ctx.notify(ad)end function U.setTheme(ac,ad)ac.ctx.theme:
apply(ad)end function U.setScale(ac,ad)local ae=math.clamp(ad,0.7,1.5)ac._scale.
Scale=ae ac._panelScale.Scale=ae ac:_placeSheet()ac:_drawChips()ac:_saveState()
end function U.setSubtitle(ac,ad)ac._subtitleText=ad end function U._saveState(
ac)local ad=ac._files if ad==nil or ac._stateFile==nil or ac._stateQueued then
return end ac._stateQueued=true task.delay(0.5,function()ac._stateQueued=false
if not ac.destroyed then local ae=ac._dockAt ad.write(ac._stateFile,encode({
scale=ac._scale.Scale,dockX=ae and ae.X,dockY=ae and ae.Y}))end end)end function
U.dialog(ac,ad,ae)if ac.destroyed then return false end aa.open(ac,ad,ae)return
true end function U.find(ac,ad)return ac.elements[ad]end function U.snapshot(ac)
local ad={}for ae,af in ac.elements do if af.saved then local ag=af.value if af.
kind=='color'then ag={hex=ag.color:ToHex(),alpha=ag.alpha}elseif af.kind=='key'
then ag={key=ag.key,mode=ag.mode,modifiers=ag.modifiers,toggled=af.toggled==true
}end ad[ae]=ag end end return ad end function U.restore(ac,ad)for ae,af in ad do
local ag=ac.elements[ae]if ag and ag.saved then if ag.kind=='color'and type(af)
=='table'then ag:set({color=Color3.fromHex(af.hex or'ffffff'),alpha=af.alpha})
elseif ag.kind=='key'and type(af)=='table'then ag:set(af)ag.toggled=af.toggled==
true else ag:set(af)end end end end function U.destroy(ac)if ac.destroyed then
return end ac.destroyed=true ac:_guardCursor(false)ac.ctx.notifications:destroy(
)for ad,ae in ac.pages do ae:destroy()end ac._onPage:destroy()ac._resultsPage:
destroy()ac.ctx.input:destroy()ac._maid:clean()ac.visibilityChanged:clear()if ac
._registry and ac._registry.current==ac then ac._registry.current=nil end end
function s.new(ac)local ad=ac._registry if ad and ad.current then ad.current:
destroy()end local ae=f.new()local af=q.new(ac.theme)local ag=d.new()local ah=ab
.service('UserInputService')local V=ac.touch==true or(ah.TouchEnabled and not ah
.MouseEnabled)local W=g('ScreenGui',{Name=randomName(),IgnoreGuiInset=true,
ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=ac.
displayOrder or 10000})ab.protect(W)W.Parent=ab.guiParent()ae:add(W)local X=ab.
files()local Y=ac.folder or'sottui_board'local Z=ac.stateFile or(Y..
'/window.json')local _=nil if X then X.folder(Y)local ai=X.read(Z)_=ai and
decode(ai)end if type(_)~='table'then _={}end local ai=g('Frame',{Name='Root',
Size=UDim2.fromScale(1,1),Visible=false,Parent=W})local aj=tonumber(_.scale)or(
if W.AbsoluteSize.X<800 then 0.8 else 1)local ak=g('Frame',{Name='Layer',Size=
UDim2.fromScale(1,1),ZIndex=100,Parent=W})local al=g('TextButton',{Name='Modal',
Size=UDim2.fromOffset(0,0),Modal=true,Visible=false,Parent=ai})local am=g(
'Frame',{Name='Assembly',AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0
,1,w),Size=UDim2.fromOffset(400,w),ZIndex=3,Parent=ai})local an=g('UIScale',{
Scale=aj,Parent=am})local ao=g('Frame',{Name='Dock',Size=UDim2.fromScale(1,1),
BackgroundTransparency=0,ClipsDescendants=true,Active=true,ZIndex=3,Parent=am})
af:paint(ao,'BackgroundColor3','surface')local ap=g('Frame',{Name='Row',Size=
UDim2.fromScale(1,1),ZIndex=3,Parent=ao})local aq=g('UIListLayout',{
FillDirection=Enum.FillDirection.Horizontal,VerticalAlignment=Enum.
VerticalAlignment.Center,Padding=UDim.new(0,A),SortOrder=Enum.SortOrder.
LayoutOrder,Parent=ap})local ar=g('TextButton',{Name='Avatar',Size=UDim2.
fromOffset(x,x),BackgroundTransparency=0,ClipsDescendants=true,Text='',
LayoutOrder=1,ZIndex=3,Parent=ap})af:paint(ar,'BackgroundColor3','accent')local
as=ab.service('Players').LocalPlayer if as then g('ImageLabel',{Size=UDim2.
fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,Image=string.format(
'rbxthumb://type=AvatarBust&id=%d&w=150&h=150',as.UserId),ZIndex=3,Parent=ar})
end local at=g('Frame',{Name='Running',Position=UDim2.fromScale(1,0),Size=UDim2.
new(0,0,1,0),BackgroundTransparency=0,ZIndex=3,Parent=am})af:paint(at,
'BackgroundColor3','lineStrong')g('UIPadding',{PaddingLeft=UDim.new(0,D),Parent=
at})g('UIListLayout',{FillDirection=Enum.FillDirection.Horizontal,
VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,D),SortOrder=
Enum.SortOrder.LayoutOrder,Parent=at})local function tintFocus(au,av)af:paint(au
,'BackgroundColor3',av)end local au=g('TextBox',{Name='Search',Size=UDim2.
fromOffset(F,G),BackgroundTransparency=0,TextSize=z,Text='',PlaceholderText=
'Search',ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,
LayoutOrder=300,ZIndex=3,Parent=ap})g('UIPadding',{PaddingLeft=UDim.new(0,12),
PaddingRight=UDim.new(0,8),Parent=au})af:paint(au,'BackgroundColor3','surface')
au.Focused:Connect(function()tintFocus(au,'base')end)au.FocusLost:Connect(
function()tintFocus(au,'surface')end)af:type(au,'text')af:paint(au,'TextColor3',
'text')local av=g('Frame',{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,-
12,0.5,0),Size=UDim2.fromOffset(1,28),BackgroundTransparency=0,ZIndex=4,Parent=
au})af:paint(av,'BackgroundColor3','lineStrong')af:paint(au,'PlaceholderColor3',
'muted')local aw=g('Frame',{Name='Marker',Size=UDim2.fromOffset(0,Q),
BackgroundTransparency=0,ZIndex=4,Parent=ao})af:paint(aw,'BackgroundColor3',
'accent')local ax=g('Frame',{Name='Sheet',AnchorPoint=Vector2.new(0,1),Position=
UDim2.new(0,0,1,-(y+w)),Size=UDim2.new(0,v,0,0),BackgroundTransparency=0,
ClipsDescendants=true,Active=true,ZIndex=2,Parent=ai})af:paint(ax,
'BackgroundColor3','surface')local ay=g('UIScale',{Scale=aj,Parent=ax})local az=
setmetatable({ctx=nil,pages={},elements={},ordered={},isOpen=false,destroyed=
false,width=v,visibilityChanged=p.new(),_maid=ae,_gui=W,_root=ai,_layer=ak,
_modal=al,_scale=an,_panelScale=ay,_box=au,_panel=ax,_dock=ao,_row=ap,_marker=aw
,_chipRow=at,_homeAvatar=ar,_chips={},_sheetRoom=600,_sheetWidth=v,_dockAt=if
tonumber(_.dockX)and tonumber(_.dockY)then Vector2.new(_.dockX,_.dockY)else nil,
_words={},_subtitleText=ac.subtitle,_files=X,_stateFile=Z,_dialogIds=0,_registry
=ad},U)if ad then ad.current=az end local aA={theme=af,input=ag,touch=V,assets={
},glyph=c.new(af),tint=r.new(af),uiScale=function()return an.Scale end,
popoverTop=function()return 8 end,dialogAt=function(aA)local aB=ak.AbsoluteSize
return UDim2.fromOffset(math.floor((aB.X-aA*an.Scale)/2),math.floor(aB.Y*0.2))
end,isShowing=function(aA)if not az.isOpen then return false end if aA._page==
nil and aA._shownOn==nil then return true end return az._showing~=nil and(aA.
_shownOn==az._showing or aA._page==az._showing)end,setScrollLocked=function(aA)
local aB=az._showing if aB and aB.frame and V then aB.frame.ScrollingEnabled=not
aA end end}az.ctx=aA local aB=k.popover(aA,ak)aA.popover=aB aA.tooltip=k.
tooltip(aA,ak)aA.hover=k.hover(aA)aA.notifications=j.new(aA,ak)aA.notify=
function(aC)aA.notifications:show(aC)end az.keys=e.new(ag,ab,function()return az
.isOpen end)aA.keys=az.keys az._at=ae:add(i.prop(am,'Position',N))az._at:snap(az
:_away())az._panelSize=ae:add(i.prop(ax,'Size',M))az._markerAt=ae:add(i.prop(aw,
'Position',O))az._markerSize=ae:add(i.prop(aw,'Size',O))local aC=ae:add(i.prop(
am,'Size',P))az._onPage=l.new(az,'On')az._resultsPage=l.new(az,'Results')az.
_onPage:mount(ax)az._resultsPage:mount(ax)local aD=g('TextButton',{Name='Close',
Size=UDim2.new(0,H,1,0),LayoutOrder=400,ZIndex=4,Parent=ap})local aE=aA.glyph.
cross(aD,'muted')aE.AnchorPoint=Vector2.new(0.5,0.5)aE.Position=UDim2.new(0.5,4,
0.5,0)aE.ZIndex=4 local aF=g('Frame',{AnchorPoint=Vector2.new(0,0.5),Position=
UDim2.fromScale(0,0.5),Size=UDim2.fromOffset(1,I),BackgroundTransparency=0,
ZIndex=4,Parent=aD})af:paint(aF,'BackgroundColor3','lineStrong')ar.MouseEnter:
Connect(function()aA.tint(ar,'BackgroundColor3','accentHover')end)ar.MouseLeave:
Connect(function()aA.tint(ar,'BackgroundColor3','accent')end)ao.InputBegan:
Connect(function(aG)local aH=aG.UserInputType if aH~=Enum.UserInputType.
MouseButton1 and aH~=Enum.UserInputType.Touch then return end local aI=if aH==
Enum.UserInputType.Touch then ag:at(aG)else ag:pointer()local aJ,aK=az:
_dockPoint()ag:capture(function(aL)local aM=aL-aI az._dockAt=Vector2.new(aJ+aM.X
,aK+aM.Y)az:_clampDock()az._at:snap(az:_home())az:_placeSheet()local aN=az.
_showing if aN then aN:_invalidate()end end,function()az:_drawChips()az:
_syncMarker(true)az:_saveState()end,if aH==Enum.UserInputType.Touch then aG else
nil)end)aD.Activated:Connect(function()az:setOpen(false)end)aD.MouseEnter:
Connect(function()aA.tooltip:schedule(aD,'Close menu')end)aD.MouseLeave:Connect(
function()aA.tooltip:hide()end)au:GetPropertyChangedSignal('Text'):Connect(
function()az:_query(au.Text)end)local function fitDock()local aG=math.ceil(aq.
AbsoluteContentSize.X/an.Scale)az._dockWidth=aG aC:snap(UDim2.fromOffset(aG,w))
az:_clampDock()if az.isOpen then az._at:snap(az:_home())else az._at:snap(az:
_away())end az:_placeSheet()az:_drawChips()task.defer(function()if not az.
destroyed then az._sheetWidth=math.clamp(az._dockWidth,v,L)az._panelSize:snap(
UDim2.new(0,az._sheetWidth,0,ax.Size.Y.Offset))az:_syncMarker(true)end end)end
aq:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(fitDock)task.defer(
fitDock)ae:add(W:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()az:
_clampDock()if az.isOpen then az._at:snap(az:_home())end az:_placeSheet()az:
_drawChips()local aG=az._showing if aG then aG:_invalidate()end end))ag.moved:
connect(function(aG)aA.hover:verify(aG)end)ag.wheel:connect(function(aG)if not
az.isOpen or aA.popover:isOpen()then return end local aH=az._showing if aH==nil
or aH.frame==nil then return end local aI=ag:pointer()local aJ,aK=aH.frame.
AbsolutePosition,aH.frame.AbsoluteSize if aI.X>=aJ.X and aI.Y>=aJ.Y and aI.X<=aJ
.X+aK.X and aI.Y<=aJ.Y+aK.Y then aH:wheel(aG)end end)ag.keyDown:connect(function
(aG,aH)if aG.UserInputType~=Enum.UserInputType.Keyboard then return end local aI
=aG.KeyCode.Name if az.keys:swallowed(aI)then return end if aA.popover:key(aI)
then return end if aI=='Escape'and az._dialogClose then az._dialogClose()return
end if aI=='Escape'and au.Text~=''then au.Text=''return end if aH or ag:typing()
then return end if az.isOpen and aI=='K'then if ah:IsKeyDown(Enum.KeyCode.
LeftControl)or ah:IsKeyDown(Enum.KeyCode.RightControl)then au:CaptureFocus()end
end end)ae:add(af.changed:connect(function()local aG=table.clone(az.pages)table.
insert(aG,az._onPage)table.insert(aG,az._resultsPage)for aH,aI in aG do for aJ,
aK in aI._views do pcall(function()aK:retint()aK.refresh()end)end end end))local
aG=n.new({window=az,nextId=function()return 0 end,_register=function(aG,aH,aI)if
aI then az.elements[aH.id]=aH end aH._pageName=''end,_invalidate=function()end},
'')az.menuKey=aG:key('__menu',{label='Menu',default=ac.key or'RightShift',mode=
'Toggle',saved=false,onPress=function()az:toggle()end})local aH=ab.service(
'RunService')i.setAttach(function(aI)return aH.PreRender:Connect(aI)end)if ac.
fonts~=false and X then ae:add(task.defer(function()local aI=ac.fontTag or t
local aJ=string.format(u,aI)local aK=Y..'/fonts-'..aI local aL=b.load(aK,aJ,
encode)if not az.destroyed and(aL.text or aL.display)then af:setFonts(aL.text,aL
.display)end end))end if V then az._opener=o(W,af,function()az:setOpen(true)end)
end if ac.autoShow~=false then task.defer(function()az:setOpen(true)end)end
return az end function s.setVersion(ac)t=ac end return s end function a.C()local
aa=a.cache.C if not aa then aa={c=__modImpl()}a.cache.C=aa end return aa.c end
end end local aa=a.a()local ab=a.b()local ac=a.e()local ad=a.C()local ae=
'0.4.0-board'local function registry()local af=aa.global('getgenv')local ag=if
type(af)=='function'then af()else _G local ah=ag.__sottui if type(ah)~='table'
then ah={current=nil}ag.__sottui=ah end return ah end local af={version=ae,
motion=ab}ad.setVersion('v'..ae)function af.window(ag)local ah=table.clone(ag or
{})ah._registry=registry()return ad.new(ah)end function af.current()return
registry().current end function af.obsidian()return ac.new(af)end return af