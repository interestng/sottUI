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
h)if i then table.insert(f,{item=h,score=i,index=g})end end table.sort(f,
function(g,h)if g.score~=h.score then return g.score>h.score end return g.index<
h.index end)local g,h={},{}for i,j in f do local k=j.item.host or j.item if not
h[k]then h[k]=true table.insert(g,k)if#g==e then break end end end return g end
function b.rank(c,d,e,f)local g={}for h,i in d do local j=b.score(c,e(i))if j
then table.insert(g,{item=i,score=j})end end table.sort(g,function(h,i)return h.
score>i.score end)local h={}for i=1,math.min(f,#g)do h[i]=g[i].item end return h
end return b end function a.h()local b=a.cache.h if not b then b={c=__modImpl()}
a.cache.h=b end return b.c end end do local function __modImpl()local b=a.f()
local c=a.h()local d={}local e=38 local f=8 local g=9 local h=46 local i=38
local j=260 local k=17 local function isPicked(l,m)if l.spec.multi then return l
.value[m]==true end return l.value==m end function d.open(l,m,n)local o=m.spec
local p=l.theme local q=o.display or tostring local r=o.searchable==true or#o.
options>=g local s=o.multi==true local t=(if r then h else 0)+(if s then i else
0)local u=o.options local v=0 local w=''local function ordered(x)if not o.multi
then return x end local y,z={},{}for A,B in x do table.insert(if m.value[B]then
y else z,B)end table.move(z,1,#z,#y+1,y)return y end u=ordered(u)local function 
bodyHeight()return math.clamp(#u,1,f)*e+8 end local x=math.max(n.AbsoluteSize.X,
j)l.popover:open(n,x,bodyHeight()+t,function(y,z)local A=b('ScrollingFrame',{
Position=UDim2.fromOffset(0,t),Size=UDim2.new(1,0,1,-t),ScrollBarThickness=3,
Parent=y})p:paint(A,'ScrollBarImageColor3','lineStrong')local B=b('Frame',{Size=
UDim2.fromScale(1,1),Parent=A})local C={}local D=f+2 local E=b('TextLabel',{
Position=UDim2.fromOffset(14,t+4),Size=UDim2.new(1,-28,0,e),TextSize=k,Text=
'Nothing matches',Visible=false,Parent=y})p:type(E,'text')p:paint(E,'TextColor3'
,'faint')local function draw()local F=math.floor(A.CanvasPosition.Y/e)+1 for G=1
,D do local H=C[G]local I=F+G-1 local J=u[I]if J==nil then H.root.Visible=false
else H.index=I H.option=J H.root.Visible=true H.root.Position=UDim2.new(0,4,0,(I
-1)*e+4)H.text.Text=q(J)local K=isPicked(m,J)p:paint(H.text,'TextColor3',if K
then'onAccent'else'text')p:paint(H.root,'BackgroundColor3',if K then'accent'else
'line')H.root.BackgroundTransparency=if K or I==v then 0 else 1 end end end
local function refit()A.CanvasSize=UDim2.fromOffset(0,#u*e+8)E.Visible=#u==0 z.
resize(bodyHeight()+t)draw()end local function refilter()local F=o.options if w
~=''then F=c.rank(w,F,q,500)end u=ordered(F)refit()end local F=nil local 
function choose(G)if o.multi then local H=table.clone(m.value)H[G]=if H[G]then
nil else true m:set(H)if F and F.Text~=''then F.Text=''else refilter()end if F
and not l.touch then F:CaptureFocus()end return end if m.value==G then if o.
allowNull then m:set(nil)end else m:set(G)end z.close()end for G=1,D do local H=
b('TextButton',{Size=UDim2.new(1,-8,0,e-2),BackgroundTransparency=1,Visible=
false,Parent=B})local I=b('TextLabel',{Position=UDim2.fromOffset(10,0),Size=
UDim2.new(1,-20,1,0),TextSize=k,TextTruncate=Enum.TextTruncate.AtEnd,Parent=H})p
:type(I,'text',true)local J={root=H,text=I,index=0,option=nil}C[G]=J H.
MouseEnter:Connect(function()v=J.index draw()end)H.MouseLeave:Connect(function()
if v==J.index then v=0 draw()end end)H.Activated:Connect(function()if J.option~=
nil then choose(J.option)end end)end A:GetPropertyChangedSignal('CanvasPosition'
):Connect(draw)local G=0 if r then F=b('TextBox',{Position=UDim2.fromOffset(14,0
),Size=UDim2.new(1,-28,0,h),TextSize=k+1,Text='',PlaceholderText='Search',Parent
=y})p:type(F,'text',true)p:paint(F,'TextColor3','text')p:paint(F,
'PlaceholderColor3','faint')local H=b('Frame',{Position=UDim2.fromOffset(0,h-1),
Size=UDim2.new(1,0,0,1),BackgroundTransparency=0,Parent=y})p:paint(H,
'BackgroundColor3','lineStrong')F:GetPropertyChangedSignal('Text'):Connect(
function()w=F.Text v=if w~=''then 1 else 0 A.CanvasPosition=Vector2.zero
refilter()end)G=h end if s then local H=b('TextButton',{Position=UDim2.
fromOffset(4,G),Size=UDim2.new(1,-8,0,i),TextSize=k,Text='Clear all',
TextXAlignment=Enum.TextXAlignment.Left,Parent=y})b('UIPadding',{PaddingLeft=
UDim.new(0,10),Parent=H})p:type(H,'text',true)p:paint(H,'TextColor3','muted')H.
MouseEnter:Connect(function()p:paint(H,'TextColor3','text')end)H.MouseLeave:
Connect(function()p:paint(H,'TextColor3','muted')end)H.Activated:Connect(
function()m:set({})refilter()end)end z.onKey(function(H)if H=='Down'or H=='Up'
then local I=if H=='Down'then 1 else-1 v=math.clamp(v+I,1,math.max(#u,1))local J
=(v-1)*e local K=A.AbsoluteWindowSize.Y local L=A.CanvasPosition.Y if J<L then A
.CanvasPosition=Vector2.new(0,J)elseif J+e+8>L+K then A.CanvasPosition=Vector2.
new(0,J+e+8-K)end draw()elseif H=='Return'then local I=u[v]if I~=nil then
choose(I)end end end)refit()if not o.multi and m.value~=nil then local H=table.
find(u,m.value)if H then local I=math.clamp(#u,1,f)*e A.CanvasPosition=Vector2.
new(0,math.max((H-1)*e-I/2+e/2,0))draw()end end if F and not l.touch then F:
CaptureFocus()end end)end return d end function a.i()local b=a.cache.i if not b
then b={c=__modImpl()}a.cache.i=b end return b.c end end do local function 
__modImpl()local b={}local c={display={0.177,0.244,0.272,0.655,0.507,0.609,0.642
,0.165,0.301,0.303,0.276,0.276,0.26,0.348,0.219,0.387,0.488,0.45,0.495,0.492,
0.505,0.488,0.491,0.439,0.487,0.492,0.222,0.253,0.336,0.274,0.336,0.507,0.734,
0.552,0.523,0.521,0.519,0.411,0.39,0.534,0.529,0.251,0.517,0.51,0.385,0.755,
0.633,0.532,0.507,0.533,0.518,0.525,0.475,0.535,0.537,0.811,0.546,0.55,0.421,
0.322,0.414,0.322,0.333,0.494,0.256,0.524,0.517,0.501,0.52,0.519,0.395,0.522,
0.513,0.243,0.254,0.511,0.24,0.76,0.511,0.518,0.517,0.518,0.51,0.517,0.402,0.512
,0.512,0.789,0.523,0.516,0.403,0.335,0.181,0.332,0.38},text={0.265,0.248,0.37,
0.814,0.578,0.773,0.691,0.213,0.372,0.372,0.478,0.6,0.178,0.513,0.195,0.391,0.6,
0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.199,0.223,0.6,0.6,0.6,0.516,1.034,0.664,
0.602,0.72,0.696,0.564,0.534,0.757,0.679,0.232,0.499,0.582,0.525,0.827,0.689,
0.784,0.579,0.789,0.593,0.578,0.56,0.656,0.668,0.967,0.602,0.579,0.535,0.307,
0.391,0.307,0.62,0.642,0,0.571,0.628,0.57,0.628,0.569,0.333,0.529,0.572,0.239,
0.242,0.504,0.222,0.895,0.573,0.604,0.628,0.628,0.363,0.5,0.387,0.572,0.521,
0.754,0.498,0.556,0.452,0.425,0.232,0.425,0.6},textMedium={0.248,0.267,0.413,
0.837,0.584,0.823,0.702,0.227,0.386,0.386,0.489,0.6,0.204,0.473,0.211,0.406,0.59
,0.59,0.59,0.59,0.59,0.59,0.59,0.59,0.59,0.59,0.221,0.245,0.6,0.6,0.6,0.522,
1.028,0.679,0.613,0.725,0.7,0.563,0.533,0.761,0.689,0.244,0.512,0.607,0.53,0.827
,0.701,0.791,0.589,0.796,0.604,0.584,0.571,0.665,0.68,0.982,0.627,0.598,0.547,
0.334,0.406,0.334,0.643,0.662,0.25,0.563,0.613,0.557,0.613,0.561,0.321,0.528,
0.567,0.233,0.235,0.514,0.221,0.901,0.568,0.593,0.613,0.614,0.353,0.487,0.369,
0.567,0.523,0.751,0.485,0.546,0.433,0.444,0.248,0.444,0.6}}function b.width(d,e,
f)local g=c[d]local h=0 for i=1,#e do local j=(string.byte(e,i))h+=g[j-31]or 0.5
end return h*f end return b end function a.j()local b=a.cache.j if not b then b=
{c=__modImpl()}a.cache.j=b end return b.c end end do local function __modImpl()
local b=a.f()local c=a.j()local d={}local e=30 local f=8 local g=16 local h=
'Press a key'local function display(i)local j=i.value if j==nil or j.key=='None'
or j.key=='Unknown'then return'Unset'end local k={}for l,m in j.modifiers or{}do
table.insert(k,m)end table.insert(k,j.key)local l=table.concat(k,'+')return if j
.mode and j.mode~='Toggle'then l..' '..string.lower(j.mode)else l end function d
.build(i,j)local k=i.theme local l=b('TextButton',{Name='Key',Size=UDim2.
fromOffset(52,54),BackgroundTransparency=1})local m=b('Frame',{AnchorPoint=
Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(1,-f,0,e),
ZIndex=4,Parent=l})local n=b('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.
Border,Parent=m})local o=b('TextLabel',{Size=UDim2.fromScale(1,1),TextSize=g,
TextXAlignment=Enum.TextXAlignment.Center,ZIndex=5,Parent=m})k:type(o,'text',
true)local p={root=l,width=52}local q=false local r=false local function fit(s)
local t=math.ceil(c.width('textMedium',s,g))+16+f l.Size=UDim2.fromOffset(math.
max(t,44),54)p.width=l.Size.X.Offset if p.onFit then p.onFit()end end local s=
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
c=a.b()local d={}d.PAD=14 d.HEIGHT=54 d.NAME=17 local e=30 local f=40 local g=
0.62 local h=20 local i=36 local j=0.965 local k=2.6 local l=0.45 local m=0.14
local n={}n.__index=n function n.own(o,p)table.insert(o._cleanups,function()p:
destroy()end)return p end function n.onCleanup(o,p)table.insert(o._cleanups,p)
end local function baseColor(o)local p=o.ctx.theme.tokens if o._lit then return
if o._hover then p.accentHover else p.accent end if o._tinted then return if o.
_hover then p.accentDim:Lerp(p.accent,m)else p.accentDim end if o._quiet then
return if o._hover then p.raised else p.surface end return if o._hover then p.
accentDim else p.raised end local function washTo(o)if o._wash==nil then o._wash
=o:own(c.prop(o.root,'BackgroundColor3',e))end o._wash:to(baseColor(o))end local 
function snapBase(o)local p=baseColor(o)if o._wash then o._wash:snap(p)else o.
root.BackgroundColor3=p end end function n.onHover(o,p)local q=p and not o.el.
disabled if o._hover==q then return end o._hover=q for r,s in o.chips do if s.
setHover then s.setHover(q)end end if not(o._floodFrame and o._floodFrame.
Visible)then washTo(o)end end function n.pressed(o,p)if o._press==nil then local
q=b('UIScale',{Parent=o.root})o._press=o:own(c.prop(q,'Scale',f,g))end o._press:
to(if p then j else 1)end function n.flood(o,p,q)if o._floodOn==p then return
end o._floodOn=p local r=o.root local s=r.AbsoluteSize if q or s.X<1 or not r.
Visible or not o.ctx.isShowing(o.el)then o._lit=p if o._floodFrame then o.
_floodFrame.Visible=false o._floodSpring:snap(UDim2.fromOffset(0,0))end
snapBase(o)return end local t=o._floodFrame if t==nil then t=b('Frame',{Name=
'Flood',AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(0,0),
BackgroundTransparency=0,ZIndex=1,Parent=r})b('UICorner',{CornerRadius=UDim.new(
1,0),Parent=t})o.ctx.theme:paint(t,'BackgroundColor3','accent')o._floodFrame=t o
._floodSpring=o:own(c.prop(t,'Size',h))end local u=o.ctx.uiScale()local v=s/u
local w=math.ceil(math.sqrt(v.X*v.X+v.Y*v.Y)*k)local x=o._pressAt o._pressAt=nil
local y=if x then(x-r.AbsolutePosition)/u else v/2 t.Position=UDim2.fromOffset(y
.X,y.Y)t.Visible=true if p then o._floodSpring:snap(UDim2.fromOffset(0,0))o.
_floodSpring:to(UDim2.fromOffset(w,w),function()o._lit=true local z=o._hover o.
_hover=false snapBase(o)o._hover=z t.Visible=false washTo(o)end)else o._lit=
false snapBase(o)o._floodSpring:snap(UDim2.fromOffset(w,w))o._floodSpring:to(
UDim2.fromOffset(0,0),function()t.Visible=false end)end end function n.tint(o,p,
q)if o._tinted==p then return end o._tinted=p if q or not o.ctx.isShowing(o.el)
then snapBase(o)else washTo(o)end end function n.flash(o)if o._floodOn then o:
pressed(true)task.delay(0.16,function()if o.root.Parent then o:pressed(false)end
end)return end o:flood(true)task.delay(0.28,function()if o.root.Parent and not(o
.el.kind=='toggle'and o.el.value==true)then o:flood(false)end end)end function n
.ink(o,p,q,r)local s=o.ctx.theme.tokens local t=o._inks[p]if r or not o.ctx.
isShowing(o.el)then if t then t:snap(s[q])else p.TextColor3=s[q]end return end
if t==nil then t=o:own(c.prop(p,'TextColor3',i))o._inks[p]=t end t:to(s[q])end
function n.retint(o)snapBase(o)end function n.refreshName(o)local p=o.el if p.
disabled then o.name.RichText=true o.name.Text='<s>'..p.label..'</s>'else o.name
.RichText=false o.name.Text=p.label end end function d.new(o,p,q)local r=q or{}
local s=b('TextButton',{Name=p.kind,Size=UDim2.new(1,0,0,r.height or d.HEIGHT),
BackgroundTransparency=if r.inert then 1 else 0,ClipsDescendants=true,Active=not
r.inert})local t=b('TextLabel',{Name='Name',Position=UDim2.fromOffset(d.PAD,0),
Size=UDim2.new(1,-2*d.PAD,1,0),TextSize=d.NAME,TextWrapped=true,TextTruncate=
Enum.TextTruncate.AtEnd,Text=p.label,ZIndex=3,Parent=s})o.theme:type(t,'text',
true)local u=setmetatable({root=s,name=t,el=p,ctx=o,chips={},_cleanups={},_inks=
{},_hover=false,_lit=false,_floodOn=false,_tinted=false,_quiet=r.quiet==true},n)
s.BackgroundColor3=baseColor(u)u:refreshName()if r.inert then u.onHover=function
()end u.pressed=function()end else s.MouseEnter:Connect(function()o.hover:enter(
u)end)local v=nil s.InputBegan:Connect(function(w)local x=w.UserInputType if x==
Enum.UserInputType.MouseButton1 then if not p.disabled then u._pressAt=o.input:
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
local t=22 local u=1 local v=3 local w=2 local x=4 local y=12 local z=34 local A
=17 local B=16 local C=50 local D=8 local E=36 local F={}local function addons(G
,H,I,J,K)local L=J local M={}local function reflow()local N=J for O,P in M do if
K then P.root.Position=UDim2.new(0,j+N,1,0)else P.root.Position=UDim2.new(1,-(j+
N),0.5,0)end N+=P.width+P.gap end if not K then G.name.Size=UDim2.new(1,-(2*j+N)
,1,0)end end local function place(N,O)O.root.AnchorPoint=if K then Vector2.new(0
,1)else Vector2.new(1,0.5)O.root.Position=if K then UDim2.new(0,j+L,1,0)else
UDim2.new(1,-(j+L),0.5,0)O.root.ZIndex=4 O.root.Parent=G.root O.gap=if N.kind==
'key'then 6 else 0 O.onFit=reflow L+=O.width table.insert(M,O)N._view=O G.
addonChips=G.addonChips or{}G.addonChips[N]=O table.insert(G.chips,O)G:
onCleanup(function()N._view=nil O.destroy()end)end for N,O in I.addons or{}do if
O.kind=='color'and not O.spec.chipless then place(O,b.swatch(H,O))end end for N,
O in I.addons or{}do if O.kind=='key'and not O.spec.chipless then place(O,d.
build(H,O))L+=6 end end return L end local function reserveRight(G,H)G.name.Size
=UDim2.new(1,-(2*j+H),1,0)end local function baseline(G,H,I,J)local K=e('Frame',
{Name='Track',AnchorPoint=Vector2.new(0,1),Position=UDim2.fromScale(0,1),Size=
UDim2.new(1,0,0,u),BackgroundTransparency=0,ZIndex=2,Parent=G.root})H.theme:
paint(K,'BackgroundColor3','lineStrong')local L=e('Frame',{Name='Fill',
AnchorPoint=Vector2.new(0,1),Position=UDim2.fromScale(0,1),Size=UDim2.new(I,0,0,
J or v),BackgroundTransparency=0,ZIndex=2,Parent=G.root})H.theme:paint(L,
'BackgroundColor3','accent')return L end function F.toggle(G,H)local I=H.spec.
primary==true local J=h.new(G,H)local K=G.theme if not I then reserveRight(J,
addons(J,G,H,0))local function draw(L)local M=H.value==true J:flood(M,L)J:ink(J.
name,if H.disabled then'faint'elseif M then'onAccent'else'text',L)for N,O in J.
chips do O.setInk(M)if O.setMuted then O.setMuted(not M)end end end J.root.
Activated:Connect(function()if not H.disabled then H:set(not H.value)end end)J.
refresh=function()J:refreshName()draw(false)end draw(true)return J end if I then
K:type(J.name,'display')J.name.TextSize=if H.value==true then m else l J.name.
TextWrapped=false J._nameSize=J:own(g.prop(J.name,'TextSize',n))end local L=
false for M,N in H.addons or{}do L=L or not N.spec.chipless end J.name.Position=
UDim2.fromOffset(j,if L then D else 0)J.name.Size=UDim2.new(1,-(2*j+C),if L then
0 else 1,if L then E else 0)local M=nil local N=nil local O=nil local P=0 if I
then M=e('TextButton',{AnchorPoint=Vector2.new(1,0),Position=UDim2.fromScale(1,0
),Size=UDim2.new(0,C,1,0),ZIndex=4,Parent=J.root})N=G.glyph.chevron(M,'muted',
'down')O=G.glyph.chevron(M,'muted','up')for Q,R in{N,O}do R.AnchorPoint=Vector2.
new(0.5,0.5)R.Position=UDim2.fromScale(0.5,0.5)end P+=C M.Activated:Connect(
function()H.section:togglePeek()J.refresh()end)end addons(J,G,H,0,true)local 
function draw(Q)local R=H.value==true local S=I and R if I then J:flood(R,Q)
local T=if R then m else l if Q or not G.isShowing(H)then J._nameSize:snap(T)
else J._nameSize:to(T)end end J:ink(J.name,if H.disabled then'faint'elseif S
then'onAccent'else'text',Q)for T,U in J.chips do U.setInk(S)end if M then local
T=H._shownOn and H._shownOn.sections[1]and H._shownOn.sections[1].flat M.Visible
=H.section.hasOptions==true and not T for U,V in{N,O}do for W,X in V:
GetChildren()do K:paint(X,'BackgroundColor3',if S then'onAccent'else'muted')end
end N.Visible=not H.section.peeking O.Visible=H.section.peeking==true end end J.
root.Activated:Connect(function()if not H.disabled then H:set(not H.value)end
end)J.refresh=function()J:refreshName()draw(false)end draw(true)return J end
local function formatted(G,H)local I=G.spec if I.format then local J,K=pcall(I.
format,G,H)if J and K~=nil then return tostring(K)end end return string.format(
'%.'..(I.decimals or 0)..'f',H)..(I.suffix or'')end function i.readoutWidth(G)
local H=G.spec local I=0 for J,K in{H.min,H.max,G.value}do I=math.max(I,f.width(
'textMedium',formatted(G,K),k))end return math.ceil(I*1.05)+2 end function F.
slider(G,H)local I=h.new(G,H,{quiet=true})local J=G.theme local K=H.spec local L
=I.root local function ratio()local M=K.max-K.min return if M<=0 then 0 else(H.
value-K.min)/M end local M=i.readoutWidth(H)reserveRight(I,M+r)I.name.ZIndex=4
local N=e('TextLabel',{Name='Readout',AnchorPoint=Vector2.new(1,0),Position=
UDim2.new(1,-j,0,0),Size=UDim2.new(0,M,1,0),TextSize=k,TextXAlignment=Enum.
TextXAlignment.Right,ZIndex=4,Parent=L})J:type(N,'text',true)local O=baseline(I,
G,ratio(),w)local P=e('Frame',{Name='Head',AnchorPoint=Vector2.new(1,1),Position
=UDim2.fromScale(1,1),Size=UDim2.fromOffset(x,y),BackgroundTransparency=0,ZIndex
=3,Parent=O})J:paint(P,'BackgroundColor3','text')local Q=I:own(g.prop(O,'Size',o
))local function typedEntry()if H.disabled or I._typing then return end I.
_typing=true N.Visible=false local R=e('TextBox',{AnchorPoint=Vector2.new(1,0),
Position=UDim2.new(1,-j,0,0),Size=UDim2.new(0,math.max(M,64),1,0),TextSize=k,
TextXAlignment=Enum.TextXAlignment.Right,Text='',PlaceholderText=tostring(H.
value),ZIndex=6,Parent=L})J:type(R,'display')J:paint(R,'TextColor3','accent')J:
paint(R,'PlaceholderColor3','faint')R:CaptureFocus()R.FocusLost:Connect(function
()local S=tonumber(R.Text)I._typing=false N.Visible=true R:Destroy()if S then H:
set(S)end end)end local function beginDrag(R,S,T)if H.disabled then return end
local U=H.value local V=math.max(L.AbsoluteSize.X,1)local W=K.max-K.min local X=
false local Y=false G.input:capture(function(Z)local _=Z-R if not X then if math
.abs(_.X)<q then if S and math.abs(_.Y)>8 then Y=true G.input:release()end
return end if S and math.abs(_.X)<=math.abs(_.Y)then Y=true G.input:release()
return end X=true Q.speed=p G.setScrollLocked(true)end H:set(U+W*_.X/V)end,
function(Z)Q.speed=o G.setScrollLocked(false)if not X and not Y and(Z-R).
Magnitude<8 then typedEntry()end end,T)end L.InputBegan:Connect(function(R)local
S=R.UserInputType if S==Enum.UserInputType.MouseButton2 then typedEntry()elseif
S==Enum.UserInputType.MouseButton1 then beginDrag(G.input:pointer(),false)elseif
S==Enum.UserInputType.Touch then beginDrag(G.input:at(R),true,R)end end)local 
function paintText()local R=if H.disabled then'faint'else'text'J:paint(I.name,
'TextColor3',R)J:paint(N,'TextColor3',R)N.Text=formatted(H,H.value)end I.refresh
=function()I:refreshName()paintText()Q:to(UDim2.new(ratio(),0,0,w))end
paintText()return I end local function pickText(G)local H=G.spec.display or
tostring local I=G.value if G.spec.multi then local J={}for K,L in G.spec.
options do if I[L]then table.insert(J,H(L))end end for K,L in I do if L and not
table.find(G.spec.options,K)then table.insert(J,H(K))end end if#J==0 then return
'None',false end if#J<=2 then return table.concat(J,', '),true end return string
.format('%s, %s +%d',J[1],J[2],#J-2),true end if I==nil then return'None',false
end return H(I),true end function F.dropdown(G,H)local I=h.new(G,H,{quiet=true})
local J=G.theme local K=I.root baseline(I,G,0)J:paint(I.name,'TextColor3',
'muted')local L=e('TextLabel',{Name='Value',AnchorPoint=Vector2.new(1,0),
Position=UDim2.new(1,-(j+t),0,0),TextSize=s,TextTruncate=Enum.TextTruncate.AtEnd
,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=3,Parent=K})J:type(L,'text',
true)local M=G.glyph.chevron(K,'muted')M.AnchorPoint=Vector2.new(1,0.5)M.
Position=UDim2.new(1,-j,0.5,0)M.ZIndex=3 local function fit()local N=K.
AbsoluteSize.X/G.uiScale()-2*j-t if N<=0 then return end local O=f.width(
'textMedium',(pickText(H)),s)+r local P=math.max(N-O,N*0.45)I.name.Size=UDim2.
new(0,P,1,0)L.Size=UDim2.new(0,N-P,1,0)end K:GetPropertyChangedSignal(
'AbsoluteSize'):Connect(fit)K.Activated:Connect(function()if not H.disabled then
c.open(G,H,K)end end)I.refresh=function()I:refreshName()local N,O=pickText(H)L.
Text=N J:paint(L,'TextColor3',if H.disabled or not O then'faint'else'text')fit()
end I.refresh()task.defer(fit)return I end function F.input(G,H)local I=h.new(G,
H,{quiet=true})local J=G.theme local K=H.spec I.name.Size=UDim2.new(0.35,-j,1,0)
J:paint(I.name,'TextColor3','muted')local L=e('TextBox',{AnchorPoint=Vector2.
new(1,0.5),Position=UDim2.new(1,-j,0.5,0),Size=UDim2.new(0.65,-j,0,z),TextSize=A
,Text=H.value or'',PlaceholderText=K.placeholder or'',ClipsDescendants=true,
TextEditable=not H.disabled,ZIndex=3,Parent=I.root})J:type(L,'text',true)J:
paint(L,'TextColor3','text')J:paint(L,'PlaceholderColor3','faint')local M=e(
'Frame',{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.
new(1,0,0,u),BackgroundTransparency=0,ZIndex=4,Parent=I.root})J:paint(M,
'BackgroundColor3','lineStrong')L.Focused:Connect(function()J:paint(M,
'BackgroundColor3','accent')end)L.FocusLost:Connect(function(N)J:paint(M,
'BackgroundColor3','lineStrong')if not K.finished then return end if not N or
not H:set(L.Text)then L.Text=H.value or''end end)L:GetPropertyChangedSignal(
'Text'):Connect(function()if I._applying or K.finished then return end if not H:
set(L.Text)and L.Text~=H.value then I._applying=true L.Text=H.value or''I.
_applying=false end end)I.root.Activated:Connect(function()if not H.disabled
then L:CaptureFocus()end end)I.refresh=function()I:refreshName()L.TextEditable=
not H.disabled if L.Text~=(H.value or'')then I._applying=true L.Text=H.value or
''I._applying=false end end return I end function F.button(G,H)local I=h.new(G,H
,{quiet=true})local J=e('Frame',{Name='Outline',Position=UDim2.fromOffset(1,1),
Size=UDim2.new(1,-2,1,-2),ZIndex=2,Parent=I.root})local K=e('UIStroke',{
ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,Parent=J})G.theme:paint(
K,'Color','lineStrong')local L=nil local function draw()I:refreshName()I:ink(I.
name,if H.disabled then'faint'elseif H.spec.danger then'danger'else'text')end I.
refresh=draw draw()I.root.Activated:Connect(function()if H.disabled then return
end if H.spec.confirm and L==nil then I.name.Text='Again to confirm'I:flood(true
)I:ink(I.name,'onAccent')L=task.delay(2.5,function()L=nil I:flood(false)draw()
end)return end if L then task.cancel(L)L=nil I:flood(false)draw()end I:flash()I:
ink(I.name,'onAccent')task.delay(0.28,function()if I.root.Parent then draw()end
end)H:fire()end)I:onCleanup(function()if L then task.cancel(L)end end)return I
end function F.stat(G,H)local I=h.new(G,H,{inert=true})local J=G.theme I.name.
Position=UDim2.fromOffset(j,0)I.name.Size=UDim2.new(0.5,-j,1,0)I.name.
TextWrapped=false J:paint(I.name,'TextColor3','muted')local K=e('TextLabel',{
AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-j,0,0),Size=UDim2.new(0.5,-j,
1,0),TextSize=h.NAME,TextXAlignment=Enum.TextXAlignment.Right,TextTruncate=Enum.
TextTruncate.AtEnd,ZIndex=3,Parent=I.root})J:type(K,'text',true)J:paint(K,
'TextColor3','text')I.refresh=function()I.name.Text=H.label K.Text=tostring(H.
value)end I.refresh()return I end function F.label(G,H)local I=G.theme if H.
addons then local J=h.new(G,H,{quiet=true})baseline(J,G,0)I:paint(J.name,
'TextColor3','muted')J.name.RichText=true reserveRight(J,addons(J,G,H,0))J.
refresh=function()J.name.Text=H.label end return J end local J=h.new(G,H,{height
=32,inert=true})local K=J.name local L=H.spec.wrap==true K.RichText=true K.
TextSize=B K.TextWrapped=L I:type(K,'text')I:paint(K,'TextColor3','muted')K.
TextTruncate=if L then Enum.TextTruncate.None else Enum.TextTruncate.AtEnd K.
TextYAlignment=if L then Enum.TextYAlignment.Top else Enum.TextYAlignment.Center
K.LineHeight=if L then 1.15 else 1 K.Position=UDim2.fromOffset(0,if L then 6
else 0)K.Size=if L then UDim2.new(1,0,1,-6)else UDim2.fromScale(1,1)K.Text=H.
label if L then K:GetPropertyChangedSignal('TextBounds'):Connect(function()local
M=math.ceil(K.TextBounds.Y/G.uiScale())+12 if H._measured~=M then H._measured=M
if H._relayout then H._relayout()end end end)end J.refresh=function()K.Text=H.
label end return J end function F.divider(G,H)local I=h.new(G,H,{height=28,inert
=true})local J=G.theme I.name.Position=UDim2.new()I.name.Size=UDim2.fromScale(1,
1)I.name.TextSize=B J:type(I.name,'text',true)J:paint(I.name,'TextColor3',
'muted')I.refresh=function()I.name.Text=H.label end return I end local function 
chipTile(G,H,I,J,K)local L=h.new(G,H)G.theme:paint(L.name,'TextColor3','muted')I
.root.AnchorPoint=Vector2.new(1,0.5)I.root.Position=UDim2.new(1,-K,0.5,0)I.root.
ZIndex=4 I.root.Parent=L.root reserveRight(L,J)table.insert(L.chips,I)L:
onCleanup(I.destroy)L.refresh=function()L:refreshName()I.refresh()end return L
end function F.key(G,H)local I=d.build(G,H)local J=chipTile(G,H,I,96,j)J.root.
Activated:Connect(I.start)return J end function F.color(G,H)local I=b.swatch(G,H
)local J=chipTile(G,H,I,b.DOT_SPACE,j-8)J.root.Activated:Connect(I.open)return J
end function i.build(G,H)local I=F[H.kind]assert(I,'sottUI: no view for '..
tostring(H.kind))local J=I(G,H)local K=H._shownOn local L=K and K.sections[1]and
K.sections[1].flat local M=H.section and(H.section._root or H.section)local N=M
and M.masterElement if L and N and N~=H then local O=J.refreshName J.refreshName
=function(P)O(P)P.name.Text=N.label..' '..H.label end J:refreshName()end H._view
=J return J end return i end function a.m()local b=a.cache.m if not b then b={c=
__modImpl()}a.cache.m=b end return b.c end end do local function __modImpl()
local b={}b.__index=b local c=function(c)warn(c)end function b.connect(d,e)local
f=table.clone(d._list)table.insert(f,e)d._list=f return function()local g=table.
clone(d._list)local h=table.find(g,e)if h then table.remove(g,h)d._list=g end
end end function b.fire(d,...)for e,f in d._list do local g,h=xpcall(f,debug.
traceback,...)if not g then c('sottUI: listener failed: '..tostring(h))end end
end function b.clear(d)d._list={}end return{new=function()return((setmetatable({
_list={}},b)))end,setReporter=function(d)c=d end}end function a.n()local b=a.
cache.n if not b then b={c=__modImpl()}a.cache.n=b end return b.c end end do
local function __modImpl()local b=a.n()local c={}local d={}d.__index=d local 
function decimals(e)local f=string.format('%.10f',e)local g=string.match(f,
'%.(%d-)0*$')return if g then#g else 0 end local function roundTo(e,f)if f<=0
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
'label'then f.value=g local h=f._relayout if h then h()end end if f._onLabel
then f._onLabel()end redraw(f)end function d.setTip(f,g)f.tip=g end function d.
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
shown(f)if not f.visible or(f.kind=='label'and f.label=='')then return false end
local g=f.guard return g==nil or g()end return c end function a.o()local b=a.
cache.o if not b then b={c=__modImpl()}a.cache.o=b end return b.c end end do
local function __modImpl()local b=a.o()local c={}local d={}d.__index=d local 
function add(e,f,g,h,i,j)local k=b.new(f,g or(f..'#'..tostring(e._page:nextId())
),h,i,j)k.section=e k.guard=e._guard e._page:_register(k,g~=nil)table.insert(e.
rows,k)local l=e._root or e if l.masterElement then l.hasOptions=true end e.
_page:_invalidate()return k end function d.toggle(e,f,g)local h=add(e,'toggle',f
,g.label or f,g,g.default==true)if g.onChanged then h:on(g.onChanged)end return
h end function d.master(e,f,g)g.primary=true local h=e:toggle(f,g)e.
masterElement=h local i=e._page h:on(function()i:_invalidate()end)local j=e.
_guard e._guard=function()if j and not j()then return false end return e.peeking
==true end return h end function d.togglePeek(e)local f=not e.peeking for g,h in
e._page.sections do h.peeking=false end e.peeking=f e._page:_invalidate()end
function d.slider(e,f,g)g.min=g.min or 0 g.max=g.max or 100 g.step=g.step or 1
if g.decimals==nil then local h=string.format('%.10f',g.step)local i=string.
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
or{}})i.section=e local j=i j.toggled=h.toggled==true if f.kind=='toggle'and h.
onPress==nil then j.toggled=f.value h.onPress=function()f:set(not f.value)j.
toggled=f.value end end e._page:_register(i,true)e._page.window.keys:register(i)
f:attach(i)return i end function d.addColor(e,f,g,h)local i=b.new('color',g,h.
label or f.label,h,{color=h.default or Color3.new(1,1,1),alpha=h.alphaValue or 0
})i.section=e e._page:_register(i,true)f:attach(i)if h.onChanged then i:on(h.
onChanged)end return i end function d.when(e,f,g)local h=e._guard local i=f if h
then i=function()return h()and f()end end local j=setmetatable({rows=e.rows,
title=e.title,_page=e._page,_guard=i,_root=e._root or e},d)for k,l in(g or{})do
l:on(function()e._page:_invalidate()end)end return j end function c.new(e,f)
return setmetatable({title=f,rows={},_page=e,_guard=nil,_root=nil},d)end return
c end function a.p()local b=a.cache.p if not b then b={c=__modImpl()}a.cache.p=b
end return b.c end end do local function __modImpl()local b=a.m()local c=a.f()
local d=a.j()local e=a.b()local f=a.p()local g={}local h=26 local i=36 function
g.open(j,k,l)if j._dialogClose then j._dialogClose()end local m=j.ctx local n=m.
theme local o=j._layer local p=k.width or 460 local q=k.maxHeight or 340 local r
=60 local s=c('TextButton',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
BackgroundColor3=Color3.new(0,0,0),ZIndex=50,Parent=o})local t=e.prop(s,
'BackgroundTransparency',22)t:to(0.4)local u=c('Frame',{AnchorPoint=Vector2.new(
0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(p,0),
BackgroundTransparency=0,ClipsDescendants=true,Active=true,ZIndex=51,Parent=o})n
:paint(u,'BackgroundColor3','base')c('UIScale',{Scale=m.uiScale(),Parent=u})
local v=c('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=u})n:
paint(v,'Color','lineStrong')local w=c('TextLabel',{Position=UDim2.fromOffset(20
,16),Size=UDim2.new(1,-40,0,40),TextSize=36,Text=k.title or'',ZIndex=52,Parent=u
})n:type(w,'display')n:paint(w,'TextColor3','text')local x=60 local y=k.text if
y and y~=''then local z=c('TextLabel',{Position=UDim2.fromOffset(20,x),Size=
UDim2.new(1,-40,0,22),AutomaticSize=Enum.AutomaticSize.Y,TextSize=16,TextWrapped
=true,Text=y,ZIndex=52,Parent=u})n:type(z,'text')n:paint(z,'TextColor3','muted')
x+=22+math.floor(#y/52)*22+12 end local z=c('ScrollingFrame',{Position=UDim2.
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
Position=UDim2.fromOffset(20,I),Size=UDim2.new(1,-40,0,54),
BackgroundTransparency=0,TextSize=28,Text=k.done or'Done',ZIndex=52,Parent=u})n:
type(J,'display')n:paint(J,'BackgroundColor3','text')n:paint(J,'TextColor3',
'base')local K=I+54+20 local L=e.prop(u,'Size',h)L:to(UDim2.fromOffset(p,K))
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
local d=a.j()local e=a.b()local f=a.p()local g=a.l()local h={}local i=12 local j
=600 local k=8 local l=2 local m=20 local n=14 local o=40 local p=16 local q=60
local r=14 local s=62 local t=88 local u=12 local v=3 local w=40 local x=22
local y=148 local z=0 local A=36 local B=360 local C=110 local D=24 local E=28
local F={toggle=4,button=4,key=4,color=4,slider=4,dropdown=4,stat=3,input=8}
local function needs(G)local H=G.kind if H=='stat'or H=='input'then return 0 end
local I=26 if H=='slider'then I=b.readoutWidth(G)+12 elseif H=='dropdown'then I=
96 end for J,K in G.addons or{}do if not K.spec.chipless then I+=if K.kind==
'key'then 58 else 28 end end return d.width('textMedium',G.label,g.NAME)*1.05+2*
g.PAD+I end local function spanOf(G)if G.kind=='label'and G.addons then return 4
end return F[G.kind]end local G={}G.__index=G local function textHeight(H,I)if H
.kind=='divider'then return if H.label==''then 8 else 28 end if not H.spec.wrap
then return 32 end if H._measured then return H._measured end local J=math.max(
math.floor(I/7.6),10)local K=string.gsub(H.label,'<[^>]+>','')return math.ceil(#
K/J)*21+12 end function G.nextId(H)H._ids+=1 return H._ids end function G.
_register(H,I,J)I._relayout=function()H:_invalidate()end H.window:
_registerElement(I,H,J)end function G._invalidate(H)if H._dirty then return end
H._dirty=true task.defer(function()H._dirty=false if not H.destroyed then H:
layout(not H._quiet)H._quiet=false end end)end function G.section(H,I)local J=f.
new(H,I)table.insert(H.sections,J)H:_invalidate()return J end function G.tabset(
H)local I=f.new(H,'')I.tabNames={}I.activeTab=1 table.insert(H.sections,I)local
J={}function J.tab(K,L)table.insert(I.tabNames,L)local M=#I.tabNames local N=I:
when(function()return I.activeTab==M end)N.title=L local O=H._headers[I]if O
then O:Destroy()H._headers[I]=nil end H:_invalidate()return N end return J end
function G.tabs(H,I)local J=H:tabset()local K={}for L,M in I do table.insert(K,J
:tab(M))end return K end function G.hero(H,I)H._hero=I H:_invalidate()local J=H.
_heroView return{set=function(K,L,M)I.title=L or I.title I.text=M or I.text
local N=H._heroView or J if N then N.refresh()end end}end local function 
buildHero(H)local I=H.window.ctx local J=I.theme local K=H._hero local L=c(
'Frame',{Name='Hero',Parent=H.canvas})local M=c('Frame',{Size=UDim2.fromOffset(y
-16,y-16),BackgroundTransparency=0,ClipsDescendants=true,Parent=L})J:paint(M,
'BackgroundColor3','accent')if K.userId then c('ImageLabel',{Size=UDim2.
fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,Image=string.format(
'rbxthumb://type=AvatarBust&id=%d&w=420&h=420',K.userId),Parent=M})end local N=
c('TextLabel',{Position=UDim2.fromOffset(y+2,16),Size=UDim2.new(1,-(y+2),0,68),
TextSize=64,TextTruncate=Enum.TextTruncate.AtEnd,Parent=L})J:type(N,'display')J:
paint(N,'TextColor3','text')local O=c('TextLabel',{Position=UDim2.fromOffset(y+2
,88),Size=UDim2.new(1,-(y+2),0,44),TextSize=17,TextWrapped=true,TextYAlignment=
Enum.TextYAlignment.Top,Parent=L})J:type(O,'text')J:paint(O,'TextColor3','muted'
)local P={root=L,refresh=function()N.Text=K.title O.Text=K.text or''end}P.
refresh()return P end local function buildHeader(H,I)local J=H.window.ctx local
K=J.theme local L=c('Frame',{Name='Header',Parent=H.canvas})if I.tabNames then
local M={}local N=0 for O,P in I.tabNames do local Q=math.ceil(d.width(
'textMedium',P,18))+20 local R=c('TextButton',{Position=UDim2.fromOffset(N,0),
Size=UDim2.new(0,Q,1,-8),TextSize=18,Text=P,TextXAlignment=Enum.TextXAlignment.
Left,Parent=L})K:type(R,'text',true)M[O]=R R.Activated:Connect(function()I.
activeTab=O for S,T in M do K:paint(T,'TextColor3',if S==I.activeTab then'text'
else'faint')end H:_invalidate()end)K:paint(R,'TextColor3',if O==I.activeTab then
'text'else'faint')N+=Q end else local M=c('TextLabel',{Size=UDim2.new(1,0,1,-6),
TextSize=26,Text=I.title,Parent=L})K:type(M,'display')K:paint(M,'TextColor3',
'text')end return L end function G.layout(H,I)local J=H.frame if J==nil then
return end H._live=I==true and H._settled==true and H.active local K=H.window.
ctx.uiScale()local L=J.AbsoluteSize.X/K if L<1 then return end local M=L-2*m
local N=M<j local O=(M-(i-1)*k)/i local P=n local Q={}if H._hero then table.
insert(Q,{hero=true,x=m,y=P,width=M,height=y})P+=y end local function placeRows(
R,S)do local T=false local U,V={},0 local function flush()if#U==0 then return
end local W,X=m,0 for Y,Z in U do local _=if N and#U==1 then i else Z.span local
aa=_*O+(_-1)*k local ab=Z.height X=math.max(X,ab)table.insert(Q,{el=Z.el,x=W,y=P
,width=aa,height=ab})W+=aa+k end P+=X+k U,V={},0 end for aa,ab in S do local W=
spanOf(ab)if W==nil then flush()if ab.kind=='divider'and ab.label==''and T then
continue end local X=textHeight(ab,M)table.insert(Q,{el=ab,x=m,y=P,width=M,
height=X})P+=X+l elseif ab.spec.primary then flush()local X=t table.insert(Q,{el
=ab,x=m,y=P,width=M,height=X})P+=X+k+z T=true else local X=if R.flat then i
elseif N then(if W<=i/3 then i/2 else i)else W while X<i and needs(ab)>X*O+(X-1)
*k do X+=if N then i-X else 4 end if V+X>i then flush()end T=false table.insert(
U,{el=ab,span=X,height=if ab.kind=='stat'then A else g.HEIGHT})V+=X end end
flush()end end local aa={}local ab=nil local function flushBoard()if#aa==0 then
return end local R=(M-k)/2 local S=1 while S<=#aa do local T,U=aa[S],aa[S+1]
local function keyed(V)for W,X in V.masterElement.addons or{}do if not X.spec.
chipless then return true end end return false end local V=keyed(T)or(U~=nil and
keyed(U))local W=if V then t else s table.insert(Q,{el=T.masterElement,x=m,y=P,
width=if U then R else M,height=W})if U then table.insert(Q,{el=U.masterElement,
x=m+R+k,y=P,width=R,height=W})end P+=W for X,Y in{T,U}do if Y and Y.peeking then
local Z={}for _,ac in Y.rows do if ac~=Y.masterElement and ac:shown()then table.
insert(Z,ac)end end local ac=P P+=u placeRows(Y,Z)P+=u-k ab={y=ac,height=P-ac,
tabX=if X==1 then m else m+R+k,tabWidth=if U then R else M}end end P+=k S+=2 end
table.clear(aa)P+=x-k end for ac,R in H.sections do if R.masterElement and not R
.flat then if R.masterElement:shown()then table.insert(aa,R)end else flushBoard(
)local S={}for T,U in R.rows do if R.flat or U:shown()then table.insert(S,U)end
end if#S>0 or R.tabNames then if R.title~=''or R.tabNames then table.insert(Q,{
section=R,x=m,y=P,width=M,height=w})P+=w end placeRows(R,S)P+=x end end end
flushBoard()local ac=H.sections[1]and H.sections[1].flat local R=P-x+(if ac then
p else o)if H._emptyVisible then R=math.max(R,q)end J.CanvasSize=UDim2.
fromOffset(0,R)H._contentHeight=R local S=math.max(R-J.AbsoluteSize.Y/H.window.
ctx.uiScale(),0)if H._scrollTarget and H._scrollTarget>S then H._scrollTarget=S
end H._placements=Q H:_placeDrawer(ab,m,M)if H.active then H.window:
_contentChanged(R,I)end H:_applyPlacements()H:_materialize(true)H:_refreshThumb(
)H._live=false H._settled=H._settled or H.active end local function growTo(aa,ab
,ac,H)if aa._grow==nil then aa._grow=aa:own(e.prop(aa.root,'Size',E))end aa.
_grow:to(UDim2.fromOffset(ab,ac),H)end local function setSize(aa,ab,ac)local H=
UDim2.fromOffset(ab,ac)if aa._grow then aa._grow:snap(H)else aa.root.Size=H end
end function G._applyPlacements(aa)local ab={}for ac,H in aa._placements do if H
.hero then if aa._heroView then aa._heroView.root.Position=UDim2.fromOffset(H.x,
H.y)aa._heroView.root.Size=UDim2.fromOffset(H.width,H.height)end elseif H.
section then ab[H.section]=true local I=aa._headers[H.section]if I then I.
Visible=true I.Position=UDim2.fromOffset(H.x,H.y)I.Size=UDim2.fromOffset(H.width
,H.height)end else ab[H.el]=true local I=aa._views[H.el]if I then aa:_place(I,H)
end end end for ac,H in aa._headers do if not ab[ac]then H.Visible=false end end
for ac,H in aa._views do if not ab[ac]and H.root.Visible and not H._folding then
if aa._live then H._folding=true growTo(H,H.root.Size.X.Offset,0,function()H.
_folding=false H.root.Visible=false end)else H.root.Visible=false end end end
end function G._place(aa,ab,ac)local H=ab.root local I=UDim2.fromOffset(ac.x,ac.
y)local J=aa._live local K=J and not H.Visible local L=ab._folding==true ab.
_folding=false H.Visible=true if K then setSize(ab,ac.width,0)growTo(ab,ac.width
,ac.height)elseif L then growTo(ab,ac.width,ac.height)elseif J and ab._grow==nil
and H.Size.Y.Offset~=ac.height then growTo(ab,ac.width,ac.height)elseif J and ab
._grow and ab._grow.target.Y.Offset~=ac.height then growTo(ab,ac.width,ac.height
)else setSize(ab,ac.width,ac.height)end if J and not K and H.Position~=I then if
ab._slide==nil then ab._slide=ab:own(e.prop(H,'Position',E))end ab._slide:to(I)
elseif ab._slide then ab._slide:snap(I)else H.Position=I end end function G.
_materialize(aa,ab)local ac=aa.frame local H=aa._placements if ac==nil or H==nil
or not aa.active then return end local I=aa.window.ctx.uiScale()local J=ac.
CanvasPosition.Y/I if not ab and aa._lastSync and math.abs(J-aa._lastSync)<B/3
then return end aa._lastSync=J local K,L=J-B,J+ac.AbsoluteSize.Y/I+B for M,N in
H do local O=N.y if O+N.height>=K and O<=L then if N.hero then if aa._heroView==
nil then local P=buildHero(aa)P.root.Position=UDim2.fromOffset(N.x,O)P.root.Size
=UDim2.fromOffset(N.width,N.height)aa._heroView=P end elseif N.section then if
aa._headers[N.section]==nil then local P=buildHeader(aa,N.section)P.Position=
UDim2.fromOffset(N.x,O)P.Size=UDim2.fromOffset(N.width,N.height)aa._headers[N.
section]=P end elseif aa._views[N.el]==nil then N.el._shownOn=aa local P,Q=
xpcall(b.build,debug.traceback,aa.window.ctx,N.el)if P then Q.root.Position=
UDim2.fromOffset(N.x,O)Q.root.Size=UDim2.fromOffset(N.width,if aa._live then 0
else N.height)Q.root.Parent=aa.canvas aa._views[N.el]=Q if aa._live then growTo(
Q,N.width,N.height)end else warn('sottUI: tile '..tostring(N.el.id)..' failed: '
..tostring(Q))end end end end end function G._refreshThumb(aa)local ab=aa.thumb
if ab==nil then return end local ac=aa.window.ctx.uiScale()local H=aa.frame.
AbsoluteSize.Y/ac local I=aa._contentHeight or 0 if I<=H+1 or not aa.active then
ab.Visible=false return end ab.Visible=true local J=math.max(H*H/I,40)local K=H-
J local L=aa.frame.CanvasPosition.Y/ac/math.max(I-H,1)ab.Size=UDim2.new(0,3,0,J)
ab.Position=UDim2.new(1,-6,0,L*K)end function G.scrollTo(aa,ab,ac)local H=aa.
frame if H==nil then return end local I=aa.window.ctx.uiScale()local J=math.max(
(aa._contentHeight or 0)-H.AbsoluteSize.Y/I,0)local K=math.clamp(ab,0,J)aa.
_scrollTarget=K if ac then aa._scroll:snap(K)else aa._scroll:to(K)end end
function G.wheel(aa,ab)if aa.frame==nil or aa.frame.ScrollingEnabled then return
end local ac=aa._scrollTarget or aa.frame.CanvasPosition.Y/aa.window.ctx.
uiScale()aa:scrollTo(ac-ab*C)end function G.rowY(aa,ab)if aa._placements==nil
then aa:layout()end for ac,H in aa._placements or{}do if H.el==ab then return H.
y end end return nil end function G.viewOf(aa,ab)return aa._views[ab]end
function G.mount(aa,ab)if aa.frame then return end local ac=aa.window.ctx local
H=c('ScrollingFrame',{Name=aa.name,Size=UDim2.fromScale(1,1),Visible=false,
ScrollingEnabled=ac.touch,Parent=ab})local I=c('Frame',{Name='Canvas',Size=UDim2
.fromScale(1,1),Parent=H})local J=c('Frame',{Name='Thumb',BackgroundTransparency
=0,Visible=false,ZIndex=5,Parent=ab})ac.theme:paint(J,'BackgroundColor3',
'lineStrong')aa.frame=H aa.canvas=I aa.thumb=J aa._scroll=e.new(0,D,function(K)H
.CanvasPosition=Vector2.new(0,K*ac.uiScale())end)H:GetPropertyChangedSignal(
'CanvasPosition'):Connect(function()aa:_materialize()aa:_refreshThumb()end)local
K=0 H:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()local L=H.
AbsoluteSize.X if L~=K then K=L aa._quiet=true aa:_invalidate()else aa:
_materialize(true)aa:_refreshThumb()end end)end function G.showList(aa,ab,ac)aa.
sections={{title='',rows=ab,flat=true}}for H,I in ab do I._shownOn=aa end if aa.
frame then if aa._empty==nil then local H=aa.window.ctx.theme aa._empty=c(
'TextLabel',{Position=UDim2.fromOffset(m,12),Size=UDim2.new(1,-2*m,0,36),
TextSize=17,Parent=aa.frame})H:type(aa._empty,'text')H:paint(aa._empty,
'TextColor3','muted')end aa._empty.Text=ac or''aa._empty.Visible=ac~=nil aa.
_emptyVisible=ac~=nil end aa:_invalidate()end function G.adopt(aa)for ab,ac in
aa._views do ab._view=ac ab._shownOn=aa if ac.refresh then ac.refresh()end for H
,I in ac.addonChips or{}do H._view=I if I.refresh then I.refresh()end end end
end function G._placeDrawer(aa,ab,ac,H)if aa._drawer==nil then local I=aa.window
.ctx.theme local J=c('Frame',{Name='Drawer',BackgroundTransparency=0,ZIndex=0,
Parent=aa.canvas})I:paint(J,'BackgroundColor3','base')local K=c('Frame',{Name=
'Tab',Size=UDim2.new(0,0,0,v),BackgroundTransparency=0,ZIndex=1,Parent=J})I:
paint(K,'BackgroundColor3','accent')aa._drawer=J aa._drawerTab=K end aa._drawer.
Visible=ab~=nil if ab then aa._drawer.Position=UDim2.fromOffset(ac,ab.y)aa.
_drawer.Size=UDim2.fromOffset(H,ab.height)aa._drawerTab.Position=UDim2.
fromOffset(ab.tabX-ac,0)aa._drawerTab.Size=UDim2.new(0,ab.tabWidth,0,v)end end
function G.fitHeight(aa,ab)local ac=0 for H,I in aa._placements or{}do if I.el
then local J=I.y+I.height if J+r<=ab and J>ac then ac=J end end end if ac==0
then return ab end local H=math.huge for I,J in aa._placements do if J.y>=ac and
J.y<H then H=J.y end end return math.min(ac+r,H)end function G.setActive(aa,ab)
aa.active=ab if aa.frame then aa.frame.Visible=ab if not ab then aa.thumb.
Visible=false end end if ab then aa:layout()end end function G.destroy(aa)aa.
destroyed=true for ab,ac in aa._views do ac.destroy()end aa._views={}if aa.
_scroll then aa._scroll:destroy()end if aa.frame then aa.frame:Destroy()aa.thumb
:Destroy()end end function h.new(aa,ab)return setmetatable({name=ab,window=aa,
sections={},active=false,destroyed=false,_ids=0,_dirty=false,_headers={},_views=
{},_placements=nil},G)end return h end function a.y()local aa=a.cache.y if not
aa then aa={c=__modImpl()}a.cache.y=aa end return aa.c end end do local function 
__modImpl()local aa=a.f()local ab=UDim2.fromOffset(16,72)local ac=44 return
function(b,c,d)local e=aa('TextButton',{Name='Open',Position=ab,Size=UDim2.
fromOffset(ac,ac),BackgroundTransparency=0,TextSize=24,Text='s',Visible=false,
ZIndex=50,Parent=b})c:type(e,'display')c:paint(e,'BackgroundColor3','accent')c:
paint(e,'TextColor3','onAccent')e.Activated:Connect(d)return e end end function
a.z()local aa=a.cache.z if not aa then aa={c=__modImpl()}a.cache.z=aa end return
aa.c end end do local function __modImpl()local aa=a.n()local ab={}local 
function rgb(ac)return Color3.fromRGB(bit32.band(bit32.rshift(ac,16),255),bit32.
band(bit32.rshift(ac,8),255),bit32.band(ac,255))end local ac={base=rgb(0x7100d),
surface=rgb(0x141c18),raised=rgb(0x1e2b25),line=rgb(0x1a2d27),lineStrong=rgb(
0x2f4a40),text=rgb(0xebe8da),muted=rgb(0xb4c2b8),faint=rgb(0x5f756b),accent=rgb(
0x7ee0c4),accentHover=rgb(0x9bebd4),accentDim=rgb(0x1f4a3e),onAccent=rgb(0xb1a13
),danger=rgb(0xe5604d)}local b='rbxasset://fonts/families/BuilderSans.json'local
c='rbxasset://fonts/families/RobotoCondensed.json'local d={}d.__index=d function
ab.defaults()return table.clone(ac)end function ab.new(e)local f=(ab.defaults())
for g,h in(e or{})do f[g]=h end local g={tokens=f,fonts={text=b,display=c},
changed=aa.new(),_paints={},_types={},_count=0}return((setmetatable(g,d)))end
local e=2000 local function sweep(f)for g in f._paints do if g.Parent==nil then
f._paints[g]=nil f._types[g]=nil end end for g in f._types do if g.Parent==nil
then f._types[g]=nil end end end function d.paint(f,g,h,i)local j=f._paints[g]if
j==nil then j={}f._paints[g]=j f._count+=1 if f._count%e==0 then task.defer(
sweep,f)end end j[h]=i g[h]=f.tokens[i]end function d.face(f,g,h)if g=='display'
then return Font.new(f.fonts.display,Enum.FontWeight.ExtraBold)end return Font.
new(f.fonts.text,if h then Enum.FontWeight.Medium else Enum.FontWeight.Regular)
end function d.type(f,g,h,i)f._types[g]={family=h,medium=i==true}g.FontFace=f:
face(h,i)end function d.forget(f,g)f._paints[g]=nil f._types[g]=nil end function
d.apply(f,g)for h,i in g do f.tokens[h]=i end for h,i in f._paints do for j,k in
i do pcall(function()h[j]=f.tokens[k]end)end end f.changed:fire()end function d.
setFonts(f,g,h)f.fonts.text=g or f.fonts.text f.fonts.display=h or f.fonts.
display for i,j in f._types do pcall(function()i.FontFace=f:face(j.family,j.
medium)end)end end return ab end function a.A()local aa=a.cache.A if not aa then
aa={c=__modImpl()}a.cache.A=aa end return aa.c end end do local function 
__modImpl()local aa=a.b()local ab={}local ac=26 function ab.new(b)local c={}
return function(d,e,f,g)local h=c[d]if h==nil then h={}c[d]=h end local i=h[e]if
i==nil then i=aa.prop(d,e,g or ac)h[e]=i end i:to(b.tokens[f])end end return ab
end function a.B()local aa=a.cache.B if not aa then aa={c=__modImpl()}a.cache.B=
aa end return aa.c end end do local function __modImpl()local aa=a.q()local ab=a
.a()local ac=a.r()local b=a.s()local c=a.u()local d=a.v()local e=a.t()local f=a.
f()local g=a.j()local h=a.b()local i=a.w()local j=a.x()local k=a.y()local l=a.h(
)local m=a.p()local n=a.z()local o=a.n()local p=a.A()local q=a.B()local r={}
local s='main'local t=
[[https://raw.githubusercontent.com/interestng/sottUI/%s/fonts/]]local u=520
local v=64 local w=64 local x=76 local y=18 local z=26 local A=17 local B=16
local C=1 local D=64 local E=124 local F=40 local G=44 local H=28 local I=12
local J=600 local K=760 local L=38 local M=28 local N=30 local O=30 local P=4
local Q=6 local R=24 local S=12 local T={}T.__index=T local function randomName(
)local U=table.create(S)for V=1,S do U[V]=string.char(math.random(97,122))end
return table.concat(U)end local function encode(U)return ab.service(
'HttpService'):JSONEncode(U)end local function decode(U)local V,W=pcall(function
()return ab.service('HttpService'):JSONDecode(U)end)return if V then W else nil
end function T._registerElement(U,V,W,X)if W==U._resultsPage or W==U._onPage
then return end V._pageName=W.name V._page=W if X then if U.elements[V.id]then
error('sottUI: element id used twice: '..V.id,3)end U.elements[V.id]=V end if V.
kind~='divider'and V.kind~='label'and V.kind~='stat'then table.insert(U.ordered,
V)end if V.kind=='toggle'then V:on(function()if U._showing==U._onPage and U.
isOpen then U:_fillOn()end if V.spec.primary then U:_drawChips()if U._showing==U
._resultsPage then U._resultsPage:_invalidate()end end end)if V.spec.primary
then V._onLabel=function()U:_drawChips()end if V.value==true then U:_drawChips()
end end end end function T._drawChips(U)if U._chipsQueued or U.destroyed then
return end U._chipsQueued=true task.defer(function()U._chipsQueued=false if U.
destroyed then return end local V={}for W,X in U.ordered do if X.kind=='toggle'
and X.spec.primary and X.value==true and not X.disabled and X:shown()then table.
insert(V,X)end end for W,X in U._chips do X:Destroy()end table.clear(U._chips)
local W=U.ctx.theme local X=0 local function widthOf(Y)return math.ceil(g.width(
'textMedium',Y,A))+2*B end local function add(Y,Z,_,ad)local ae=widthOf(Y)local
af=f('TextButton',{Name='Chip',Size=UDim2.new(0,ae,1,0),BackgroundTransparency=0
,TextSize=A,Text=Y,LayoutOrder=Z,ZIndex=3,Parent=U._chipRow})X+=ae+C W:type(af,
'text',true)W:paint(af,'BackgroundColor3','surface')W:paint(af,'TextColor3',
'accent')af.MouseEnter:Connect(function()U.ctx.tint(af,'BackgroundColor3',
'accent')U.ctx.tint(af,'TextColor3','onAccent')task.defer(function()U.ctx.
tooltip:schedule(af,_)end)end)af.MouseLeave:Connect(function()U.ctx.tint(af,
'BackgroundColor3','surface')U.ctx.tint(af,'TextColor3','accent')U.ctx.tooltip:
hide()end)af.Activated:Connect(ad)table.insert(U._chips,af)end local ad=U._scale
.Scale local ae=U:_dockPoint()local af=ae+(U._dockWidth or 0)*ad/2 local Y=(U.
_gui.AbsoluteSize.X-af)/ad-C-I for Z,_ in V do local ag=#V-Z local ah=widthOf(_.
label)+(if ag>0 then D else 0)if Z>Q or X+ah>Y then add('+'..(ag+1),100+Z,
'Show everything running',function()U:_fillOn()U:_show(U._onPage)end)break end
add(_.label,100+Z,'Turn off '.._.label,function()_:set(false)end)end U._chipRow.
Size=UDim2.new(0,X,1,0)end)end function T._setPerson(ad,ae)ad._person=ae end
function T._contentChanged(ad,ae,af)if ad._showing==nil then return end local ag
=ad._scale.Scale local ah=ad._sheetRoom/ag-I local U=math.min(ae,J,ah)if ae>U
then U=ad._showing:fitHeight(U)end local V=UDim2.new(0,ad._sheetWidth,0,U)if af
or ad._sheetRise then ad._panelSize:to(V)else ad._panelSize:snap(V)end end
function T._placeSheet(ad)local ae=ad._scale.Scale local af,ag=ad:_dockPoint()
local ah=af-(ad._dockWidth or 0)*ae/2 local U=ag-v*ae local V=ad._gui.
AbsoluteSize.Y local W=U>=V/2 ad._sheetAbove=W ad._sheetRoom=if W then U else V-
ag ad._panel.AnchorPoint=Vector2.new(0,if W then 1 else 0)ad._panel.Position=
UDim2.fromOffset(math.floor(ah),math.floor(if W then U else ag))end function T.
_dockPoint(ad)local ae=ad._dockAt if ae then return ae.X,ae.Y end local af=ad.
_gui.AbsoluteSize return af.X/2,af.Y-x end function T._home(ad)local ae=ad.
_dockAt return if ae then UDim2.fromOffset(ae.X,ae.Y)else UDim2.new(0.5,0,1,-x)
end function T._away(ad)local ae=ad._dockAt if ae and ae.Y<ad._gui.AbsoluteSize.
Y/2 then return UDim2.fromOffset(ae.X,-I)end return ad:_home()+UDim2.fromOffset(
0,v*ad._scale.Scale+x+I)end function T._clampDock(ad)local ae=ad._dockAt if ae==
nil then return end local af=ad._scale.Scale local ag=ad._gui.AbsoluteSize local
ah=(ad._dockWidth or 0)*af/2 ad._dockAt=Vector2.new(math.clamp(ae.X,math.min(ah+
I,ag.X/2),math.max(ag.X-ah-I,ag.X/2)),math.clamp(ae.Y,v*af+I,math.max(ag.Y-I,v*
af+I)))end function T._show(ad,ae,af)if ad._showing==ae then return end ad.ctx.
hover.clear()ad.ctx.popover:close()ad.keys:cancel()local ag=ad._showing if ag
then ag:setActive(false)end local ah=ad._leaving if ah and ah~=ae then ah:
setActive(false)end ad._leaving=nil ad._showing=ae ad:_placeSheet()ad._sheetRise
=not af ae:setActive(true)ad._sheetRise=false ae:adopt()ad:_syncMarker(af)ad:
_saveState()end function T._hideSheet(ad)local ae=ad._showing if ae==nil then
return end ad.ctx.hover.clear()ad.ctx.popover:close()ad.keys:cancel()ad._showing
=nil ad._leaving=ae ad._panelSize:to(UDim2.new(0,ad._sheetWidth,0,0),function()
if ad._leaving==ae then ad._leaving=nil ae:setActive(false)end end)ad:
_syncMarker()end function T._syncMarker(ad,ae)local af=ad.ctx.tint local ag=nil
for ah,U in ad._words do local V=ad._showing==ah if U:IsA('TextButton')and U.
Text~=''then af(U,'TextColor3',if V then'text'else'muted')end if V then ag=U end
end if ag==nil or ag==ad._homeAvatar then ad._markerSize:to(UDim2.fromOffset(0,P
))return end ad.ctx.theme:paint(ad._marker,'BackgroundColor3',if ag==ad.
_homeAvatar then'onAccent'else'accent')local ah=ad._scale.Scale local U=(ag.
AbsolutePosition.X-ad._dock.AbsolutePosition.X)/ah local V=UDim2.fromOffset(U,if
ad._sheetAbove==false then v-P else 0)local W=UDim2.fromOffset(ag.AbsoluteSize.X
/ah,P)if ae or ad._markerSize.target==nil or ad._markerSize.target.X.Offset==0
then ad._markerAt:snap(V)else ad._markerAt:to(V)end if ae then ad._markerSize:
snap(W)else ad._markerSize:to(W)end end local function bindWord(ad,ae,af)ad.
_words[ae]=af af.Activated:Connect(function()if ad._box.Text~=''then ad._box.
Text=''end if ad._showing==ae then ad:_hideSheet()else ad:_show(ae)end end)end
local function addWord(ad,ae,af,ag)local ah=ad.ctx.theme local U=math.ceil(g.
width('textMedium',af,y))+2 local V=f('TextButton',{Name=af,Size=UDim2.new(0,U,1
,0),TextSize=y,Text=af,LayoutOrder=ag,ZIndex=3,Parent=ad._row})ah:type(V,'text',
true)ah:paint(V,'TextColor3','muted')bindWord(ad,ae,V)V.MouseEnter:Connect(
function()if ad._showing~=ae then ad.ctx.tint(V,'TextColor3','text')end end)V.
MouseLeave:Connect(function()if ad._showing~=ae then ad.ctx.tint(V,'TextColor3',
'muted')end end)end function T.page(ad,ae)local af=k.new(ad,ae)table.insert(ad.
pages,af)if ae=='Home'and ad._homeAvatar then bindWord(ad,af,ad._homeAvatar)else
addWord(ad,af,ae,2+#ad.pages)end af:mount(ad._panel)return af end function T.
_fillOn(ad)local ae,af={},{}for ag,ah in ad.ordered do if ah.kind=='toggle'and
ah.value==true then table.insert(if ah.spec.primary then ae else af,ah)end end
if#ae==0 then ae=af end ad._onPage:showList(ae,if#ae==0 then'Nothing is on'else
nil)end function T._query(ad,ae)if ae==''then if ad._showing==ad._resultsPage
then ad:_hideSheet()end ad._resultsPage:showList({})return end local af={}for ag
,ah in ad.ordered do if ah.visible~=false then table.insert(af,ah)end end local
ag=l.settings(ae,af,R)ad._resultsPage:showList(ag,if#ag==0 then'Nothing matches'
else nil)ad:_show(ad._resultsPage)end function T.showPage(ad,ae)for af,ag in ad.
pages do if ag.name==ae then ad._box.Text=''ad:_show(ag)return end end end
function T.show(ad,ae,af)local ag=ad.pages[ae]if ag then ad:_show(ag,af)end end
function T.reveal(ad,ae)local af=ae._page if af then ad:setOpen(true)ad:
showPage(af.name)end end function T.setOpen(ad,ae)if ad.isOpen==ae or ad.
destroyed then return end ad.isOpen=ae if ad._opener then ad._opener.Visible=not
ae end ad.ctx.hover.clear()ad.ctx.popover:close()ad.ctx.tooltip:hide()ad.keys:
cancel()if not ae and ad._dialogClose then ad._dialogClose()end if ae then ad.
_root.Visible=true ad._modal.Visible=true ad:_guardCursor(true)ad._at:to(ad:
_home())ad:_drawChips()else ad._modal.Visible=false ad:_guardCursor(false)ad.
_box:ReleaseFocus()ad._box.Text=''ad:_hideSheet()ad._at:to(ad:_away(),function()
if not ad.isOpen then ad._root.Visible=false end end)end ad.visibilityChanged:
fire(ae)end function T._guardCursor(ad,ae)local af=ab.service('UserInputService'
)if ae then ad._gameCursor=af.MouseIconEnabled af.MouseIconEnabled=true if ad.
_cursorGuard==nil then ad._cursorGuard=af:GetPropertyChangedSignal(
'MouseIconEnabled'):Connect(function()if not af.MouseIconEnabled then ad.
_gameCursor=false af.MouseIconEnabled=true end end)end else if ad._cursorGuard
then ad._cursorGuard:Disconnect()ad._cursorGuard=nil end if ad._gameCursor~=nil
then af.MouseIconEnabled=ad._gameCursor ad._gameCursor=nil end end end function
T.toggle(ad)ad:setOpen(not ad.isOpen)end function T.notify(ad,ae)if ad.destroyed
then return end ad.ctx.notify(ae)end function T.setTheme(ad,ae)ad.ctx.theme:
apply(ae)end function T.setScale(ad,ae)local af=math.clamp(ae,0.7,1.5)ad._scale.
Scale=af ad._panelScale.Scale=af ad:_placeSheet()ad:_drawChips()ad:_saveState()
end function T.setSubtitle(ad,ae)ad._subtitleText=ae end function T._saveState(
ad)local ae=ad._files if ae==nil or ad._stateFile==nil or ad._stateQueued then
return end ad._stateQueued=true task.delay(0.5,function()ad._stateQueued=false
if not ad.destroyed then local af=ad._dockAt ae.write(ad._stateFile,encode({
scale=ad._scale.Scale,dockX=af and af.X,dockY=af and af.Y}))end end)end function
T.dialog(ad,ae,af)if ad.destroyed then return false end aa.open(ad,ae,af)return
true end function T.find(ad,ae)return ad.elements[ae]end function T.snapshot(ad)
local ae={}for af,ag in ad.elements do if ag.saved then local ah=ag.value if ag.
kind=='color'then ah={hex=ah.color:ToHex(),alpha=ah.alpha}elseif ag.kind=='key'
then ah={key=ah.key,mode=ah.mode,modifiers=ah.modifiers,toggled=ag.toggled==true
}end ae[af]=ah end end return ae end function T.restore(ad,ae)for af,ag in ae do
local ah=ad.elements[af]if ah and ah.saved then if ah.kind=='color'and type(ag)
=='table'then ah:set({color=Color3.fromHex(ag.hex or'ffffff'),alpha=ag.alpha})
elseif ah.kind=='key'and type(ag)=='table'then ah:set(ag)ah.toggled=ag.toggled==
true else ah:set(ag)end end end end function T.destroy(ad)if ad.destroyed then
return end ad.destroyed=true ad:_guardCursor(false)ad.ctx.notifications:destroy(
)for ae,af in ad.pages do af:destroy()end ad._onPage:destroy()ad._resultsPage:
destroy()ad.ctx.input:destroy()ad._maid:clean()ad.visibilityChanged:clear()if ad
._registry and ad._registry.current==ad then ad._registry.current=nil end end
function r.new(ad)local ae=ad._registry if ae and ae.current then ae.current:
destroy()end local af=e.new()local ag=p.new(ad.theme)local ah=c.new()local U=ab.
service('UserInputService')local V=ad.touch==true or(U.TouchEnabled and not U.
MouseEnabled)local W=f('ScreenGui',{Name=randomName(),IgnoreGuiInset=true,
ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=ad.
displayOrder or 10000})ab.protect(W)W.Parent=ab.guiParent()af:add(W)local X=ab.
files()local Y=ad.folder or'sottui_board'local Z=ad.stateFile or(Y..
'/window.json')local _=nil if X then X.folder(Y)local ai=X.read(Z)_=ai and
decode(ai)end if type(_)~='table'then _={}end local ai=f('Frame',{Name='Root',
Size=UDim2.fromScale(1,1),Visible=false,Parent=W})local aj=tonumber(_.scale)or(
if W.AbsoluteSize.X<800 then 0.8 else 1)local ak=f('Frame',{Name='Layer',Size=
UDim2.fromScale(1,1),ZIndex=100,Parent=W})local al=f('TextButton',{Name='Modal',
Size=UDim2.fromOffset(0,0),Modal=true,Visible=false,Parent=ai})local am=f(
'Frame',{Name='Assembly',AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0
,1,v),Size=UDim2.fromOffset(400,v),ZIndex=3,Parent=ai})local an=f('UIScale',{
Scale=aj,Parent=am})local ao=f('Frame',{Name='Dock',Size=UDim2.fromScale(1,1),
BackgroundTransparency=0,ClipsDescendants=true,Active=true,ZIndex=3,Parent=am})
ag:paint(ao,'BackgroundColor3','surface')local ap=f('Frame',{Name='Row',Size=
UDim2.fromScale(1,1),ZIndex=3,Parent=ao})local aq=f('UIListLayout',{
FillDirection=Enum.FillDirection.Horizontal,VerticalAlignment=Enum.
VerticalAlignment.Center,Padding=UDim.new(0,z),SortOrder=Enum.SortOrder.
LayoutOrder,Parent=ap})local ar=f('TextButton',{Name='Avatar',Size=UDim2.
fromOffset(w,w),BackgroundTransparency=0,ClipsDescendants=true,Text='',
LayoutOrder=1,ZIndex=3,Parent=ap})ag:paint(ar,'BackgroundColor3','accent')local
as=ab.service('Players').LocalPlayer if as then f('ImageLabel',{Size=UDim2.
fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,Image=string.format(
'rbxthumb://type=AvatarBust&id=%d&w=150&h=150',as.UserId),ZIndex=3,Parent=ar})
end local at=f('Frame',{Name='Running',Position=UDim2.fromScale(1,0),Size=UDim2.
new(0,0,1,0),BackgroundTransparency=0,ZIndex=3,Parent=am})ag:paint(at,
'BackgroundColor3','lineStrong')f('UIPadding',{PaddingLeft=UDim.new(0,C),Parent=
at})f('UIListLayout',{FillDirection=Enum.FillDirection.Horizontal,
VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,C),SortOrder=
Enum.SortOrder.LayoutOrder,Parent=at})local function tintFocus(au,av)ag:paint(au
,'BackgroundColor3',av)end local au=f('TextBox',{Name='Search',Size=UDim2.
fromOffset(E,F),BackgroundTransparency=0,TextSize=y,Text='',PlaceholderText=
'Search',ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,
LayoutOrder=300,ZIndex=3,Parent=ap})f('UIPadding',{PaddingLeft=UDim.new(0,12),
PaddingRight=UDim.new(0,8),Parent=au})ag:paint(au,'BackgroundColor3','surface')
au.Focused:Connect(function()tintFocus(au,'base')end)au.FocusLost:Connect(
function()tintFocus(au,'surface')end)ag:type(au,'text')ag:paint(au,'TextColor3',
'text')local av=f('Frame',{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,-
12,0.5,0),Size=UDim2.fromOffset(1,28),BackgroundTransparency=0,ZIndex=4,Parent=
au})ag:paint(av,'BackgroundColor3','lineStrong')ag:paint(au,'PlaceholderColor3',
'muted')local aw=f('Frame',{Name='Marker',Size=UDim2.fromOffset(0,P),
BackgroundTransparency=0,ZIndex=4,Parent=ao})ag:paint(aw,'BackgroundColor3',
'accent')local ax=f('Frame',{Name='Sheet',AnchorPoint=Vector2.new(0,1),Position=
UDim2.new(0,0,1,-(x+v)),Size=UDim2.new(0,u,0,0),BackgroundTransparency=0,
ClipsDescendants=true,Active=true,ZIndex=2,Parent=ai})ag:paint(ax,
'BackgroundColor3','surface')local ay=f('UIScale',{Scale=aj,Parent=ax})local az=
setmetatable({ctx=nil,pages={},elements={},ordered={},isOpen=false,destroyed=
false,width=u,visibilityChanged=o.new(),_maid=af,_gui=W,_root=ai,_layer=ak,
_modal=al,_scale=an,_panelScale=ay,_box=au,_panel=ax,_dock=ao,_row=ap,_marker=aw
,_chipRow=at,_homeAvatar=ar,_chips={},_sheetRoom=600,_sheetWidth=u,_dockAt=if
tonumber(_.dockX)and tonumber(_.dockY)then Vector2.new(_.dockX,_.dockY)else nil,
_words={},_subtitleText=ad.subtitle,_files=X,_stateFile=Z,_dialogIds=0,_registry
=ae},T)if ae then ae.current=az end local aA={theme=ag,input=ah,touch=V,assets={
},glyph=b.new(ag),tint=q.new(ag),uiScale=function()return an.Scale end,
popoverTop=function()return 8 end,dialogAt=function(aA)local aB=ak.AbsoluteSize
return UDim2.fromOffset(math.floor((aB.X-aA*an.Scale)/2),math.floor(aB.Y*0.2))
end,isShowing=function(aA)if not az.isOpen then return false end if aA._page==
nil and aA._shownOn==nil then return true end return az._showing~=nil and(aA.
_shownOn==az._showing or aA._page==az._showing)end,setScrollLocked=function(aA)
local aB=az._showing if aB and aB.frame and V then aB.frame.ScrollingEnabled=not
aA end end}az.ctx=aA local aB=j.popover(aA,ak)aA.popover=aB aA.tooltip=j.
tooltip(aA,ak)aA.hover=j.hover(aA)aA.notifications=i.new(aA,ak)aA.notify=
function(aC)aA.notifications:show(aC)end az.keys=d.new(ah,ab,function()return az
.isOpen end)aA.keys=az.keys az._at=af:add(h.prop(am,'Position',M))az._at:snap(az
:_away())az._panelSize=af:add(h.prop(ax,'Size',L))az._markerAt=af:add(h.prop(aw,
'Position',N))az._markerSize=af:add(h.prop(aw,'Size',N))local aC=af:add(h.prop(
am,'Size',O))az._onPage=k.new(az,'On')az._resultsPage=k.new(az,'Results')az.
_onPage:mount(ax)az._resultsPage:mount(ax)local aD=f('TextButton',{Name='Close',
Size=UDim2.new(0,G,1,0),LayoutOrder=400,ZIndex=4,Parent=ap})local aE=aA.glyph.
cross(aD,'muted')aE.AnchorPoint=Vector2.new(0.5,0.5)aE.Position=UDim2.new(0.5,4,
0.5,0)aE.ZIndex=4 local aF=f('Frame',{AnchorPoint=Vector2.new(0,0.5),Position=
UDim2.fromScale(0,0.5),Size=UDim2.fromOffset(1,H),BackgroundTransparency=0,
ZIndex=4,Parent=aD})ag:paint(aF,'BackgroundColor3','lineStrong')ar.MouseEnter:
Connect(function()aA.tint(ar,'BackgroundColor3','accentHover')end)ar.MouseLeave:
Connect(function()aA.tint(ar,'BackgroundColor3','accent')end)ao.InputBegan:
Connect(function(aG)local aH=aG.UserInputType if aH~=Enum.UserInputType.
MouseButton1 and aH~=Enum.UserInputType.Touch then return end local aI=if aH==
Enum.UserInputType.Touch then ah:at(aG)else ah:pointer()local aJ,aK=az:
_dockPoint()ah:capture(function(aL)local aM=aL-aI az._dockAt=Vector2.new(aJ+aM.X
,aK+aM.Y)az:_clampDock()az._at:snap(az:_home())az:_placeSheet()local aN=az.
_showing if aN then aN:_invalidate()end end,function()az:_drawChips()az:
_syncMarker(true)az:_saveState()end,if aH==Enum.UserInputType.Touch then aG else
nil)end)aD.Activated:Connect(function()az:setOpen(false)end)aD.MouseEnter:
Connect(function()aA.tooltip:schedule(aD,'Close menu')end)aD.MouseLeave:Connect(
function()aA.tooltip:hide()end)au:GetPropertyChangedSignal('Text'):Connect(
function()az:_query(au.Text)end)local function fitDock()local aG=math.ceil(aq.
AbsoluteContentSize.X/an.Scale)az._dockWidth=aG aC:snap(UDim2.fromOffset(aG,v))
az:_clampDock()if az.isOpen then az._at:snap(az:_home())else az._at:snap(az:
_away())end az:_placeSheet()az:_drawChips()task.defer(function()if not az.
destroyed then az._sheetWidth=math.clamp(az._dockWidth,u,K)az._panelSize:snap(
UDim2.new(0,az._sheetWidth,0,ax.Size.Y.Offset))az:_syncMarker(true)end end)end
aq:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(fitDock)task.defer(
fitDock)af:add(W:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()az:
_clampDock()if az.isOpen then az._at:snap(az:_home())end az:_placeSheet()az:
_drawChips()local aG=az._showing if aG then aG:_invalidate()end end))ah.moved:
connect(function(aG)aA.hover:verify(aG)end)ah.wheel:connect(function(aG)if not
az.isOpen or aA.popover:isOpen()then return end local aH=az._showing if aH==nil
or aH.frame==nil then return end local aI=ah:pointer()local aJ,aK=aH.frame.
AbsolutePosition,aH.frame.AbsoluteSize if aI.X>=aJ.X and aI.Y>=aJ.Y and aI.X<=aJ
.X+aK.X and aI.Y<=aJ.Y+aK.Y then aH:wheel(aG)end end)ah.keyDown:connect(function
(aG,aH)if aG.UserInputType~=Enum.UserInputType.Keyboard then return end local aI
=aG.KeyCode.Name if az.keys:swallowed(aI)then return end if aA.popover:key(aI)
then return end if aI=='Escape'and az._dialogClose then az._dialogClose()return
end if aI=='Escape'and au.Text~=''then au.Text=''return end if aH or ah:typing()
then return end if az.isOpen and aI=='K'then if U:IsKeyDown(Enum.KeyCode.
LeftControl)or U:IsKeyDown(Enum.KeyCode.RightControl)then au:CaptureFocus()end
end end)af:add(ag.changed:connect(function()local aG=table.clone(az.pages)table.
insert(aG,az._onPage)table.insert(aG,az._resultsPage)for aH,aI in aG do for aJ,
aK in aI._views do pcall(function()aK:retint()aK.refresh()end)end end end))local
aG=m.new({window=az,nextId=function()return 0 end,_register=function(aG,aH,aI)if
aI then az.elements[aH.id]=aH end aH._pageName=''end,_invalidate=function()end},
'')az.menuKey=aG:key('__menu',{label='Menu',default=ad.key or'RightShift',mode=
'Toggle',saved=false,onPress=function()az:toggle()end})local aH=ab.service(
'RunService')h.setAttach(function(aI)return aH.PreRender:Connect(aI)end)if ad.
fonts~=false and X then af:add(task.defer(function()local aI=ad.fontTag or s
local aJ=string.format(t,aI)local aK=Y..'/fonts-'..aI local aL=ac.load(aK,aJ,
encode)if not az.destroyed and(aL.text or aL.display)then ag:setFonts(aL.text,aL
.display)end end))end if V then az._opener=n(W,ag,function()az:setOpen(true)end)
end if ad.autoShow~=false then task.defer(function()az:setOpen(true)end)end
return az end function r.setVersion(ad)s=ad end return r end function a.C()local
aa=a.cache.C if not aa then aa={c=__modImpl()}a.cache.C=aa end return aa.c end
end end local aa=a.a()local ab=a.b()local ac=a.e()local ad=a.C()local ae=
'0.4.2-board'local function registry()local af=aa.global('getgenv')local ag=if
type(af)=='function'then af()else _G local ah=ag.__sottui if type(ah)~='table'
then ah={current=nil}ag.__sottui=ah end return ah end local af={version=ae,
motion=ab}ad.setVersion('v'..ae)function af.window(ag)local ah=table.clone(ag or
{})ah._registry=registry()return ad.new(ah)end function af.current()return
registry().current end function af.obsidian()return ac.new(af)end return af