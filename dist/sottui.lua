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
section and d.section.title or''local h=string.lower((d._pageName or'')..' '..g
..' '..(d.tip or''))return if string.find(h,f,1,true)then 1 else nil end
function b.settings(c,d,e)local f={}for g,h in d do local i=b.setting(c,h)if i
then table.insert(f,{item=h,score=i})end end table.sort(f,function(g,h)return g.
score>h.score end)local g,h={},{}for i,j in f do local k=j.item.host or j.item
if not h[k]then h[k]=true table.insert(g,k)if#g==e then break end end end return
g end function b.rank(c,d,e,f)local g={}for h,i in d do local j=b.score(c,e(i))
if j then table.insert(g,{item=i,score=j})end end table.sort(g,function(h,i)
return h.score>i.score end)local h={}for i=1,math.min(f,#g)do h[i]=g[i].item end
return h end return b end function a.h()local b=a.cache.h if not b then b={c=
__modImpl()}a.cache.h=b end return b.c end end do local function __modImpl()
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
local E=b('TextLabel',{Position=UDim2.fromOffset(34,t+4),Size=UDim2.new(1,-52,0,
e),TextSize=k,Text='Nothing matches',Visible=false,Parent=y})p:type(E,'text')p:
paint(E,'TextColor3','faint')local function draw()local F=math.floor(A.
CanvasPosition.Y/e)+1 for G=1,D do local H=C[G]local I=F+G-1 local J=u[I]if J==
nil then H.root.Visible=false else H.index=I H.option=J H.root.Visible=true H.
root.Position=UDim2.new(0,0,0,(I-1)*e+4)H.text.Text=q(J)local K=isPicked(m,J)p:
paint(H.text,'TextColor3',if K then'text'else'muted')H.mark.Visible=K H.root.
BackgroundTransparency=if I==v then 0.4 else 1 end end end local function refit(
)A.CanvasSize=UDim2.fromOffset(0,#u*e+8)E.Visible=#u==0 z.resize(bodyHeight()+t)
draw()end local function refilter()local F=o.options if w~=''then F=c.rank(w,F,q
,500)end u=ordered(F)refit()end local F=nil local function choose(G)if o.multi
then local H=table.clone(m.value)H[G]=if H[G]then nil else true m:set(H)if F and
F.Text~=''then F.Text=''else refilter()end if F and not l.touch then F:
CaptureFocus()end return end if m.value==G then if o.allowNull then m:set(nil)
end else m:set(G)end z.close()end for G=1,D do local H=b('TextButton',{Size=
UDim2.new(1,0,0,e-2),BackgroundTransparency=1,Visible=false,Parent=B})local I=b(
'TextLabel',{Position=UDim2.fromOffset(34,0),Size=UDim2.new(1,-52,1,0),TextSize=
k,TextTruncate=Enum.TextTruncate.AtEnd,Parent=H})p:type(I,'text',true)p:paint(H,
'BackgroundColor3','raised')local J=b('Frame',{Position=UDim2.fromScale(0,0),
Size=UDim2.new(0,3,1,0),BackgroundTransparency=0,Visible=false,Parent=H})p:
paint(J,'BackgroundColor3','accent')local K={root=H,text=I,mark=J,index=0,option
=nil}C[G]=K H.MouseEnter:Connect(function()v=K.index draw()end)H.MouseLeave:
Connect(function()if v==K.index then v=0 draw()end end)H.Activated:Connect(
function()if K.option~=nil then choose(K.option)end end)end A:
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
end do local function __modImpl()local b={}local c={display={0.222,0.279,0.346,
0.619,0.619,0.964,0.734,0.173,0.312,0.309,0.435,0.515,0.19,0.338,0.23,0.355,
0.643,0.33,0.585,0.592,0.615,0.594,0.636,0.502,0.64,0.635,0.238,0.219,0.515,
0.515,0.515,0.413,0.965,0.682,0.657,0.664,0.674,0.594,0.566,0.698,0.694,0.274,
0.356,0.664,0.492,0.898,0.746,0.702,0.625,0.703,0.656,0.63,0.552,0.696,0.658,
0.962,0.669,0.623,0.563,0.313,0.352,0.31,0.557,0.552,0.283,0.569,0.616,0.556,
0.616,0.566,0.388,0.584,0.606,0.259,0.265,0.571,0.258,0.915,0.606,0.595,0.615,
0.616,0.419,0.534,0.385,0.599,0.557,0.84,0.556,0.581,0.508,0.341,0.251,0.336,
0.515},text={0.2,0.275,0.425,0.6,0.567,0.85,0.675,0.25,0.35,0.35,0.375,0.567,0.2
,0.3,0.2,0.35,0.567,0.567,0.567,0.567,0.567,0.567,0.567,0.567,0.567,0.567,0.275,
0.275,0.567,0.567,0.567,0.483,0.825,0.6,0.583,0.617,0.642,0.542,0.517,0.658,
0.667,0.25,0.25,0.575,0.5,0.858,0.683,0.658,0.575,0.658,0.583,0.567,0.575,0.65,
0.6,0.9,0.592,0.533,0.592,0.35,0.333,0.35,0.567,0.6,0.5,0.55,0.55,0.492,0.55,
0.508,0.292,0.542,0.542,0.233,0.233,0.5,0.233,0.817,0.542,0.525,0.55,0.55,0.35,
0.45,0.292,0.542,0.475,0.75,0.467,0.475,0.458,0.35,0.3,0.35,0.567},textMedium={
0.2,0.294,0.463,0.6,0.567,0.85,0.705,0.25,0.35,0.35,0.394,0.567,0.237,0.3,0.237,
0.35,0.567,0.567,0.567,0.567,0.567,0.567,0.567,0.567,0.567,0.567,0.294,0.294,
0.567,0.567,0.567,0.49,0.844,0.619,0.603,0.623,0.648,0.548,0.517,0.652,0.679,
0.263,0.267,0.619,0.5,0.883,0.708,0.665,0.594,0.665,0.603,0.579,0.575,0.662,
0.619,0.919,0.617,0.558,0.592,0.35,0.346,0.35,0.567,0.6,0.5,0.569,0.569,0.511,
0.569,0.521,0.323,0.561,0.561,0.253,0.253,0.537,0.255,0.842,0.561,0.544,0.569,
0.569,0.382,0.469,0.323,0.561,0.507,0.8,0.504,0.494,0.471,0.35,0.3,0.35,0.567}}
function b.width(d,e,f)local g=c[d]local h=0 for i=1,#e do local j=(string.byte(
e,i))h+=g[j-31]or 0.5 end return h*f end return b end function a.j()local b=a.
cache.j if not b then b={c=__modImpl()}a.cache.j=b end return b.c end end do
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
local b=a.f()local c=a.b()local d={}d.PAD=18 d.HEIGHT=46 d.NAME=17 local e=0.45
local f=30 local g=5 local h=34 local i=0.62 local j=26 local k=30 local l=3
local m={}m.__index=m function m.own(n,o)table.insert(n._cleanups,function()o:
destroy()end)return o end function m.onCleanup(n,o)table.insert(n._cleanups,o)
end function m.onHover(n,o)local p=o and not n.el.disabled if n._hover==p then
return end n._hover=p for q,r in n.chips do if r.setHover then r.setHover(p)end
end if n._wash==nil then n._wash=n:own(c.prop(n.root,'BackgroundTransparency',f)
)end n._wash:to(if p then e else 1)end function m.pressed(n,o)if n._lean==nil
then n._lean=n:own(c.prop(n.name,'Position',h,i))n._rest=n.name.Position end
local p=n._rest n._lean:to(if o then p+UDim2.fromOffset(g,0)else p)end function
m.lit(n,o,p)local q=n._bar if q==nil then q=b('Frame',{Name='Bar',Size=UDim2.
new(0,0,1,0),BackgroundTransparency=0,ZIndex=2,Parent=n.root})n.ctx.theme:paint(
q,'BackgroundColor3','accent')n._bar=q n._barSize=n:own(c.prop(q,'Size',k))end
local r=if o then l else 0 if p or not n.ctx.isShowing(n.el)then n._barSize:
snap(UDim2.new(0,r,1,0))else n._barSize:to(UDim2.new(0,r,1,0))end end function m
.ink(n,o,p,q)local r=n.ctx.theme.tokens local s=n._inks[o]if q or not n.ctx.
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
12 local q=50 local r=3 local s=17 local t=42 local u=90 local v=3 local w=24
local x=22 local y=30 local z=16 i.MASTER_HEIGHT=l i.SLIDER_HEIGHT=n local A={}
local function indentOf(B)local C=B.section local D=C and(C._root or C)if D and
D.masterElement and D.masterElement~=B then return k end return 0 end local 
function newRow(B,C,D)local E=D or{}E.indent=E.indent or indentOf(C)return h.
new(B,C,E)end local function addons(B,C,D,E)local F={}local function reflow()
local G=E for H,I in F do I.root.Position=UDim2.new(1,-(j+G),0.5,0)G+=I.width+I.
gap end B.name.Size=UDim2.new(1,-(2*j+B.indent+G),1,0)end local function place(G
,H)H.root.AnchorPoint=Vector2.new(1,0.5)H.root.ZIndex=4 H.root.Parent=B.root H.
gap=if G.kind=='key'then 6 else 0 H.onFit=reflow table.insert(F,H)G._view=H
table.insert(B.chips,H)B:onCleanup(function()G._view=nil H.destroy()end)end for
G,H in D.addons or{}do if H.kind=='color'and not H.spec.chipless then place(H,b.
swatch(C,H))end end for G,H in D.addons or{}do if H.kind=='key'and not H.spec.
chipless then place(H,d.build(C,H))end end reflow()return E end function A.
toggle(B,C)local D=C.spec.primary==true local E=newRow(B,C,{height=if D then l
else nil})local F=B.theme if D then F:type(E.name,'display')E.name.TextSize=m E.
name.TextWrapped=false end local G=e('TextLabel',{Name='State',AnchorPoint=
Vector2.new(1,0),Position=UDim2.new(1,-j,0,0),Size=UDim2.new(0,w,1,0),TextSize=h
.NAME,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=3,Parent=E.root})F:type(G,
'text',true)local H=nil local I=nil local J=nil local K=w+42 if D then H=e(
'TextButton',{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-(j+w+4),0,0),
Size=UDim2.new(0,34,1,0),ZIndex=4,Parent=E.root})I=B.glyph.chevron(H,'faint',
'down')J=B.glyph.chevron(H,'muted','up')for L,M in{I,J}do M.AnchorPoint=Vector2.
new(0.5,0.5)M.Position=UDim2.fromScale(0.5,0.5)end H.Activated:Connect(function(
)C.section:togglePeek()E.refresh()end)end addons(E,B,C,K)local function draw(L)
local M=C.value==true E:lit(M,L)E:ink(E.name,if C.disabled then'faint'elseif M
then'text'else'muted',L)G.Text=if M then'on'else'off'E:ink(G,if C.disabled then
'line'elseif M then'accent'else'faint',L)if H then H.Visible=not M and C.section
.hasOptions==true I.Visible=not C.section.peeking J.Visible=C.section.peeking==
true end end E.root.Activated:Connect(function()if not C.disabled then C:set(not
C.value)end end)E.refresh=function()E:refreshName()draw(false)end draw(true)
return E end local function formatted(B,C)local D=B.spec if D.format then local
E,F=pcall(D.format,B,C)if E and F~=nil then return tostring(F)end end return
string.format('%.'..(D.decimals or 0)..'f',C)..(D.suffix or'')end function A.
slider(B,C)local D=newRow(B,C,{height=n})local E=B.theme local F=C.spec local G=
D.root local H=D.indent local function ratio()local I=F.max-F.min return if I<=0
then 0 else(C.value-F.min)/I end D.name.Position=UDim2.fromOffset(j+H,8)D.name.
Size=UDim2.new(1,-(2*j+H+96),0,24)D.name.TextWrapped=false D._rest=nil local I=
e('TextLabel',{Name='Readout',AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,
-j,0,8),Size=UDim2.new(0,96,0,24),TextSize=s,TextXAlignment=Enum.TextXAlignment.
Right,ZIndex=4,Parent=G})E:type(I,'text',true)local J=e('Frame',{Name='Ruler',
AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,j+H,1,-6),Size=UDim2.new(1,-(2
*j+H),0,o),ClipsDescendants=true,ZIndex=2,Parent=G})local function ticks(K,L)
local M=e('ImageLabel',{AnchorPoint=Vector2.new(0,1),Position=UDim2.fromScale(0,
1),Size=UDim2.new(0,400,0,p),ScaleType=Enum.ScaleType.Tile,TileSize=UDim2.
fromOffset(q,p),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=2,Parent=K})E:
paint(M,'ImageColor3',L)return M end local K=ticks(J,'lineStrong')local L=e(
'Frame',{Name='Fill',Size=UDim2.new(ratio(),0,1,0),ClipsDescendants=true,ZIndex=
2,Parent=J})local M=ticks(L,'accent')local N=e('Frame',{AnchorPoint=Vector2.new(
1,0),Position=UDim2.fromScale(1,0),Size=UDim2.new(0,r,1,0),
BackgroundTransparency=0,ZIndex=3,Parent=L})E:paint(N,'BackgroundColor3','text')
local function applyTicks()local O=B.assets.ticks K.Image=O or''M.Image=O or''
local P=if O then 1 else 0 K.BackgroundTransparency=P M.BackgroundTransparency=P
K.BackgroundColor3=E.tokens.lineStrong M.BackgroundColor3=E.tokens.accent local
Q=J.AbsoluteSize.X/B.uiScale()K.Size=UDim2.new(0,Q,0,p)M.Size=UDim2.new(0,Q,0,p)
end G:GetPropertyChangedSignal('AbsoluteSize'):Connect(applyTicks)task.defer(
applyTicks)local O=D:own(g.prop(L,'Size',t))local function typedEntry()if C.
disabled or D._typing then return end D._typing=true I.Visible=false local P=e(
'TextBox',{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-j,0,8),Size=UDim2.
new(0,96,0,24),TextSize=s,TextXAlignment=Enum.TextXAlignment.Right,Text='',
PlaceholderText=tostring(C.value),ZIndex=6,Parent=G})E:type(P,'text',true)E:
paint(P,'TextColor3','accent')E:paint(P,'PlaceholderColor3','faint')P:
CaptureFocus()P.FocusLost:Connect(function()local Q=tonumber(P.Text)D._typing=
false I.Visible=true P:Destroy()if Q then C:set(Q)end end)end local function 
beginDrag(P,Q,R)if C.disabled then return end local S=C.value local T=math.max(J
.AbsoluteSize.X,1)local U=F.max-F.min local V=false local W=false B.input:
capture(function(X)local Y=X-P if not V then if math.abs(Y.X)<v then if Q and
math.abs(Y.Y)>8 then W=true B.input:release()end return end if Q and math.abs(Y.
X)<=math.abs(Y.Y)then W=true B.input:release()return end V=true O.speed=u B.
setScrollLocked(true)end C:set(S+U*Y.X/T)end,function(X)O.speed=t B.
setScrollLocked(false)if not V and not W and(X-P).Magnitude<8 then typedEntry()
end end,R)end G.InputBegan:Connect(function(P)local Q=P.UserInputType if Q==Enum
.UserInputType.MouseButton2 then typedEntry()elseif Q==Enum.UserInputType.
MouseButton1 then beginDrag(B.input:pointer(),false)elseif Q==Enum.UserInputType
.Touch then beginDrag(B.input:at(P),true,P)end end)local function paintText()
local P=if C.disabled then'faint'else'muted'E:paint(D.name,'TextColor3',P)E:
paint(I,'TextColor3',if C.disabled then'faint'else'text')I.Text=formatted(C,C.
value)end D.refresh=function()D:refreshName()paintText()applyTicks()O:to(UDim2.
new(ratio(),0,1,0))end paintText()return D end local function pickText(B)local C
=B.spec.display or tostring local D=B.value if B.spec.multi then local E={}for F
,G in B.spec.options do if D[G]then table.insert(E,C(G))end end for F,G in D do
if G and not table.find(B.spec.options,F)then table.insert(E,C(F))end end if#E==
0 then return'None',false end if#E<=2 then return table.concat(E,', '),true end
return string.format('%s, %s +%d',E[1],E[2],#E-2),true end if D==nil then return
'None',false end return C(D),true end function A.dropdown(B,C)local D=newRow(B,C
)local E=B.theme local F=D.root E:paint(D.name,'TextColor3','muted')local G=e(
'TextLabel',{Name='Value',AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-(j+
x),0,0),Size=UDim2.new(0.55,-x,1,0),TextSize=h.NAME,TextTruncate=Enum.
TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=3,Parent=F})E
:type(G,'text',true)local H=B.glyph.chevron(F,'faint')H.AnchorPoint=Vector2.new(
1,0.5)H.Position=UDim2.new(1,-j,0.5,0)H.ZIndex=3 D.name.Size=UDim2.new(0.45,-(j+
D.indent),1,0)F.Activated:Connect(function()if not C.disabled then c.open(B,C,F)
end end)D.refresh=function()D:refreshName()local I,J=pickText(C)G.Text=I E:
paint(G,'TextColor3',if C.disabled or not J then'faint'else'text')end D.refresh(
)return D end function A.input(B,C)local D=newRow(B,C)local E=B.theme local F=C.
spec D.name.Size=UDim2.new(0.35,-(j+D.indent),1,0)E:paint(D.name,'TextColor3',
'muted')local G=e('TextBox',{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1
,-j,0.5,0),Size=UDim2.new(0.65,-j,0,y),TextSize=h.NAME,Text=C.value or'',
PlaceholderText=F.placeholder or'',ClipsDescendants=true,TextXAlignment=Enum.
TextXAlignment.Right,TextEditable=not C.disabled,ZIndex=3,Parent=D.root})E:type(
G,'text',true)E:paint(G,'TextColor3','text')E:paint(G,'PlaceholderColor3',
'faint')local H=e('Frame',{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1
,0),Size=UDim2.new(1,0,0,1),BackgroundTransparency=0,ZIndex=4,Parent=G})E:paint(
H,'BackgroundColor3','lineStrong')G.Focused:Connect(function()E:paint(H,
'BackgroundColor3','accent')end)G.FocusLost:Connect(function(I)E:paint(H,
'BackgroundColor3','lineStrong')if not F.finished then return end if not I or
not C:set(G.Text)then G.Text=C.value or''end end)G:GetPropertyChangedSignal(
'Text'):Connect(function()if D._applying or F.finished then return end if not C:
set(G.Text)and G.Text~=C.value then D._applying=true G.Text=C.value or''D.
_applying=false end end)D.root.Activated:Connect(function()if not C.disabled
then G:CaptureFocus()end end)D.refresh=function()D:refreshName()G.TextEditable=
not C.disabled if G.Text~=(C.value or'')then D._applying=true G.Text=C.value or
''D._applying=false end end return D end function A.button(B,C)local D=newRow(B,
C)local E=nil local F=B.glyph.chevron(D.root,'faint','right')F.AnchorPoint=
Vector2.new(1,0.5)F.Position=UDim2.new(1,-j,0.5,0)F.ZIndex=3 local function draw
()D:refreshName()D:ink(D.name,if C.disabled then'faint'elseif C.spec.danger then
'danger'else'text')end D.refresh=draw draw()D.root.Activated:Connect(function()
if C.disabled then return end if C.spec.confirm and E==nil then D.name.Text=
'Again to confirm'D:ink(D.name,'accent')E=task.delay(2.5,function()E=nil draw()
end)return end if E then task.cancel(E)E=nil draw()end D:flash()C:fire()end)D:
onCleanup(function()if E then task.cancel(E)end end)return D end function A.stat
(B,C)local D=newRow(B,C,{height=36,inert=true})local E=B.theme E:paint(D.name,
'TextColor3','muted')local F=e('TextLabel',{AnchorPoint=Vector2.new(1,0),
Position=UDim2.new(1,-j,0,0),Size=UDim2.new(0.6,0,1,0),TextSize=20,
TextXAlignment=Enum.TextXAlignment.Right,ZIndex=3,Parent=D.root})E:type(F,
'display')E:paint(F,'TextColor3','text')D.refresh=function()D.name.Text=C.label
F.Text=tostring(C.value)end D.refresh()return D end function A.label(B,C)local D
=B.theme if C.addons then local E=newRow(B,C)D:paint(E.name,'TextColor3','muted'
)E.name.RichText=true addons(E,B,C,0)E.refresh=function()E.name.Text=C.label end
return E end local E=newRow(B,C,{height=30,inert=true})local F=E.name local G=C.
spec.wrap==true F.RichText=true F.TextSize=z F.TextWrapped=G D:type(F,'text')D:
paint(F,'TextColor3','muted')F.TextTruncate=if G then Enum.TextTruncate.None
else Enum.TextTruncate.AtEnd F.TextYAlignment=if G then Enum.TextYAlignment.Top
else Enum.TextYAlignment.Center F.LineHeight=if G then 1.15 else 1 F.Position=
UDim2.fromOffset(j+E.indent,if G then 6 else 0)F.Size=if G then UDim2.new(1,-(2*
j+E.indent),1,-6)else UDim2.new(1,-(2*j+E.indent),1,0)F.Text=C.label if G then F
:GetPropertyChangedSignal('TextBounds'):Connect(function()local H=math.ceil(F.
TextBounds.Y/B.uiScale())+12 if C._measured~=H then C._measured=H if C._relayout
then C._relayout()end end end)end E.refresh=function()F.Text=C.label end return
E end function A.divider(B,C)local D=newRow(B,C,{height=28,inert=true})B.theme:
paint(D.name,'TextColor3','faint')D.name.TextSize=z D.refresh=function()D.name.
Text=C.label end return D end local function chipRow(B,C,D,E)local F=newRow(B,C)
B.theme:paint(F.name,'TextColor3','muted')D.root.AnchorPoint=Vector2.new(1,0.5)D
.root.Position=UDim2.new(1,-(j-8),0.5,0)D.root.ZIndex=4 D.root.Parent=F.root F.
name.Size=UDim2.new(1,-(2*j+F.indent+E),1,0)table.insert(F.chips,D)F:onCleanup(D
.destroy)F.refresh=function()F:refreshName()D.refresh()end return F end function
A.key(B,C)local D=d.build(B,C)local E=chipRow(B,C,D,96)E.root.Activated:Connect(
D.start)return E end function A.color(B,C)local D=b.swatch(B,C)local E=chipRow(B
,C,D,b.DOT_SPACE)E.root.Activated:Connect(D.open)return E end function i.build(B
,C)local D=A[C.kind]assert(D,'sottUI: no view for '..tostring(C.kind))local E=D(
B,C)C._view=E return E end i.metrics=f return i end function a.m()local b=a.
cache.m if not b then b={c=__modImpl()}a.cache.m=b end return b.c end end do
local function __modImpl()local b={}b.__index=b local c=function(c)warn(c)end
function b.connect(d,e)local f=table.clone(d._list)table.insert(f,e)d._list=f
return function()local g=table.clone(d._list)local h=table.find(g,e)if h then
table.remove(g,h)d._list=g end end end function b.fire(d,...)for e,f in d._list
do local g,h=xpcall(f,debug.traceback,...)if not g then c(
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
:paint(u,'BackgroundColor3','base')local v=c('UIStroke',{ApplyStrokeMode=Enum.
ApplyStrokeMode.Border,Parent=u})n:paint(v,'Color','line')local w=c('TextLabel',
{Position=UDim2.fromOffset(20,16),Size=UDim2.new(1,-40,0,40),TextSize=24,Text=k.
title or'',ZIndex=52,Parent=u})n:type(w,'display')n:paint(w,'TextColor3','text')
local x=60 local y=k.text if y and y~=''then local z=c('TextLabel',{Position=
UDim2.fromOffset(20,x),Size=UDim2.new(1,-40,0,22),AutomaticSize=Enum.
AutomaticSize.Y,TextSize=16,TextWrapped=true,Text=y,ZIndex=52,Parent=u})n:type(z
,'text')n:paint(z,'TextColor3','muted')x+=22+math.floor(#y/52)*22+12 end local z
=c('ScrollingFrame',{Position=UDim2.fromOffset(20,x),Size=UDim2.new(1,-40,0,0),
ScrollBarThickness=3,ZIndex=52,Parent=u})n:paint(z,'ScrollBarImageColor3',
'lineStrong')local A=false local B={window=j,name='Dialog',nextId=function()j.
_dialogIds+=1 return j._dialogIds end,_register=function(B,C,D)C._pageName=
'Dialog'if D then j.elements[C.id]=C end end,_invalidate=function()end}local C=f
.new(B,'')local D,E=xpcall(l,debug.traceback,C)if not D then warn(
'sottUI: dialog build failed: '..tostring(E))end local F={}local G=0 for H,I in
C.rows do if I:shown()then local J=b.build(m,I)local K=r if I.kind=='divider'
then K=28 elseif I.kind=='label'then local L=math.ceil(d.width('text',I.label,16
)/(p-48))K=if I.spec.wrap then L*21+12 else 32 end J.root.Position=UDim2.
fromOffset(0,G)J.root.Size=UDim2.new(1,0,0,K)J.root.Parent=z G+=K+3 table.
insert(F,J)end end z.CanvasSize=UDim2.fromOffset(0,G)local H=math.min(G,q)z.Size
=UDim2.new(1,-40,0,H)local I=x+H+12 local J=c('TextButton',{Position=UDim2.
fromOffset(20,I),Size=UDim2.new(1,-40,0,46),BackgroundTransparency=0,TextSize=17
,Text=k.done or'Done',ZIndex=52,Parent=u})n:type(J,'text',true)n:paint(J,
'BackgroundColor3','raised')n:paint(J,'TextColor3','text')local K=I+46+14 local
L=e.prop(u,'Size',h)L:to(UDim2.fromOffset(p,K))local function close()if A then
return end A=true j._dialogClose=nil s.Active=false for M,N in C.rows do if j.
elements[N.id]==N then j.elements[N.id]=nil end for O,P in N.addons or{}do j.
keys:unregister(P)if j.elements[P.id]==P then j.elements[P.id]=nil end end end
if k.onClose then task.spawn(k.onClose)end t:to(1,function()t:destroy()s:
Destroy()end)L.speed=i L:to(UDim2.fromOffset(p,0),function()for M,N in F do N.
destroy()end L:destroy()u:Destroy()end)end j._dialogClose=close s.
MouseButton1Down:Connect(close)J.Activated:Connect(close)end return g end
function a.q()local b=a.cache.q if not b then b={c=__modImpl()}a.cache.q=b end
return b.c end end do local function __modImpl()local b=a.a()local c={}local d={
text={name='SottUIText',faces={{name='Regular',weight=400,file='text-400.ttf'},{
name='Medium',weight=500,file='text-500.ttf'}}},display={name='SottUIDisplay',
faces={{name='ExtraBold',weight=800,file='display-800.ttf'}}}}local e=10000
local function family(f,g,h,i,j)local k={}for l,m in h.faces do local n=g..'/'..
m.file local o=f.read(n)if o==nil or#o<e then local p=b.fetch(i..m.file)if p==
nil or#p<e then return nil end if not f.write(n,p)then return nil end end local
p=f.asset(n)if p==nil then return nil end table.insert(k,{name=m.name,weight=m.
weight,style='normal',assetId=p})end local l=g..'/'..h.name..'.json'if not f.
write(l,j({name=h.name,faces=k}))then return nil end return f.asset(l)end
function c.load(f,g,h)local i=b.files()if i==nil or b.global('getcustomasset')==
nil then return{}end i.folder(f)local j={}local k,l=pcall(function()j.text=
family(i,f,d.text,g,h)j.display=family(i,f,d.display,g,h)end)if not k then warn(
'sottUI: fonts unavailable: '..tostring(l))end return j end function c.image(f,g
,h)local i=b.files()if i==nil or b.global('getcustomasset')==nil then return nil
end i.folder(f)local j=f..'/'..h if i.read(j)==nil then local k=b.fetch(g..h)if
k==nil or not i.write(j,k)then return nil end end return i.asset(j)end return c
end function a.r()local b=a.cache.r if not b then b={c=__modImpl()}a.cache.r=b
end return b.c end end do local function __modImpl()local b=a.f()local c={}local 
function stroke(d,e,f,g,h,i,j)local k=b('Frame',{AnchorPoint=Vector2.new(0.5,0.5
),Position=UDim2.fromOffset(i,j),Size=UDim2.fromOffset(g,2),Rotation=h,
BackgroundTransparency=0,Parent=d})e:paint(k,'BackgroundColor3',f)return k end
function c.new(d)local e={}function e.chevron(f,g,h)local i=b('Frame',{Size=
UDim2.fromOffset(12,12),Parent=f})if h=='right'then stroke(i,d,g,7,45,6,3.6)
stroke(i,d,g,7,-45,6,8.4)elseif h=='up'then stroke(i,d,g,7,-45,3.6,6)stroke(i,d,
g,7,45,8.4,6)else stroke(i,d,g,7,45,3.6,6)stroke(i,d,g,7,-45,8.4,6)end return i
end function e.cross(f,g)local h=b('Frame',{Size=UDim2.fromOffset(12,12),Parent=
f})stroke(h,d,g,13,45,6,6)stroke(h,d,g,13,-45,6,6)return h end function e.dash(f
,g)local h=b('Frame',{Size=UDim2.fromOffset(12,12),Parent=f})stroke(h,d,g,12,0,6
,6)return h end return e end return c end function a.s()local b=a.cache.s if not
b then b={c=__modImpl()}a.cache.s=b end return b.c end end do local function 
__modImpl()local b={}b.__index=b local function dispose(c)local d=typeof(c)if d
=='RBXScriptConnection'then c:Disconnect()elseif d=='Instance'then c:Destroy()
elseif d=='function'then c()elseif d=='thread'then task.cancel(c)elseif d==
'table'then local e=c.destroy or c.Destroy or c.Disconnect if e then e(c)end end
end function b.add(c,d)table.insert(c._items,d)return d end function b.clean(c)
local d=c._items c._items={}for e=#d,1,-1 do local f,g=pcall(dispose,d[e])if not
f then warn('sottUI: cleanup failed: '..tostring(g))end end end b.destroy=b.
clean return{new=function()return((setmetatable({_items={}},b)))end}end function
a.t()local b=a.cache.t if not b then b={c=__modImpl()}a.cache.t=b end return b.c
end end do local function __modImpl()local b=a.a()local c=a.t()local d=a.n()
local e={}local f={}f.__index=f function f.pointer(g)local h=g._guiService:
GetGuiInset()return g._uis:GetMouseLocation()-h end function f.at(g,h)local i=h.
Position return Vector2.new(i.X,i.Y)end function f.capture(g,h,i,j)g:release()g.
_move=h g._finish=i g._finger=j end function f.release(g)local h=g._finish g.
_move=nil g._finish=nil g._finger=nil if h then task.spawn(h,g:pointer())end end
function f.typing(g)return g._uis:GetFocusedTextBox()~=nil end function f.
destroy(g)g._move=nil g._finish=nil g._maid:clean()g.keyDown:clear()g.keyUp:
clear()g.wheel:clear()g.moved:clear()g.pointerUp:clear()end function e.new()
local g=b.service('UserInputService')local h=c.new()local i=setmetatable({_uis=g
,_guiService=b.service('GuiService'),_maid=h,_move=nil,_finish=nil,keyDown=d.
new(),keyUp=d.new(),wheel=d.new(),moved=d.new(),pointerUp=d.new()},f)h:add(g.
InputChanged:Connect(function(j)local k=j.UserInputType if k==Enum.UserInputType
.MouseMovement then local l=i:pointer()if i._move then i._move(l)end i.moved:
fire(l)elseif k==Enum.UserInputType.Touch then if i._move and(i._finger==nil or
i._finger==j)then i._move(i:at(j))end elseif k==Enum.UserInputType.MouseWheel
then i.wheel:fire(j.Position.Z)end end))h:add(g.InputEnded:Connect(function(j,k)
local l=j.UserInputType if l==Enum.UserInputType.MouseButton1 or l==Enum.
UserInputType.Touch then if i._move and(l~=Enum.UserInputType.Touch or i._finger
==nil or i._finger==j)then local m=if l==Enum.UserInputType.Touch then i:at(j)
else i:pointer()local n=i._finish i._move=nil i._finish=nil i._finger=nil if n
then n(m)end end i.pointerUp:fire()end i.keyUp:fire(j,k)end))h:add(g.InputBegan:
Connect(function(j,k)i.keyDown:fire(j,k)end))return i end return e end function
a.u()local b=a.cache.u if not b then b={c=__modImpl()}a.cache.u=b end return b.c
end end do local function __modImpl()local b={}local c={[Enum.UserInputType.
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
end function j.cancel()local p=l l=nil n=nil if p then p(nil)end end function j.
state(p,q)local r=q.value if r==nil then return false end if r.mode=='Always'
then return true end if r.mode=='Toggle'then return q.toggled==true end if r.key
=='None'or l~=nil or f:typing()then return false end local s=d[r.key]if s then
return not h()and i:IsMouseButtonPressed(s)and modifiersHeld(r.modifiers)end
local t,u=pcall(function()return i:IsKeyDown((Enum.KeyCode)[r.key])end)return t
and u and modifiersHeld(r.modifiers)end f.keyDown:connect(function(p)local q=
nameOf(p)if q==nil then return end if l then local r=c[p.UserInputType]~=nil if
r and(m or q=='MB1')then return end if e[p.KeyCode]and not r then n=q return end
local s=l l=nil n=nil o=q if q=='Escape'then(s)('None',{})else(s)(q,
heldModifiers(q))end return end if o==q then return end if f:typing()then return
end for r,s in k do local t=s.value if t.key==q and not s.disabled and
modifiersHeld(t.modifiers)then if t.mode=='Toggle'then s.toggled=not s.toggled
end local u=s.spec.onPress if u then u(s,s.toggled)end end end end)f.keyUp:
connect(function(p)local q=nameOf(p)if q==nil then return end if n==q and l then
local r=l l=nil n=nil r(q,{})return end if o==q then o=nil end for r,s in k do
local t=s.value if t.key==q and t.mode=='Hold'and s.spec.onRelease then s.spec.
onRelease(s)end end end)return j end return b end function a.v()local b=a.cache.
v if not b then b={c=__modImpl()}a.cache.v=b end return b.c end end do local 
function __modImpl()local b=a.f()local c=a.b()local d={}local e=320 local f=8
local g=20 local h=26 local i=5 function d.new(j,k)local l=j.theme local m={}
local n={}local function layout()local o=k.AbsoluteSize local p=o.Y-g for q=#m,1
,-1 do local r=m[q]p-=r.height r.pos:to(UDim2.fromOffset(o.X-e-g,p))p-=f end end
local function dismiss(o)if o.gone then return end o.gone=true if o.timer then
task.cancel(o.timer)end local p=table.find(m,o)if p then table.remove(m,p)end
local q=k.AbsoluteSize o.pos:to(UDim2.fromOffset(q.X+8,o.frame.Position.Y.Offset
),function()o.pos:destroy()o.frame:Destroy()end)layout()end function n.show(o,p)
while#m>=i do dismiss(m[1])end local q=k.AbsoluteSize local r=b('TextButton',{
Name='Notice',Position=UDim2.fromOffset(q.X+8,q.Y-g-60),Size=UDim2.fromOffset(e,
60),BackgroundTransparency=0,ZIndex=80,Parent=k})l:paint(r,'BackgroundColor3',
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
end return b.c end end do local function __modImpl()local b=a.k()local c=a.g()
local d=a.i()local e=a.f()local f=a.b()local g={}g.HEIGHT=70 g.NAME=46 g.VALUE=
26 local h=4 local i=42 local j=90 local k=3 local l=24 local function formatted
(m,n)local o=m.spec if o.format then local p,q=pcall(o.format,m,n)if p and q~=
nil then return tostring(q)end end return string.format('%.'..(o.decimals or 0)
..'f',n)..(o.suffix or'')end local function pickText(m)local n=m.spec.display or
tostring local o=m.value if m.spec.multi then local p={}for q,r in m.spec.
options do if o[r]then table.insert(p,n(r))end end for q,r in o do if r and not
table.find(m.spec.options,q)then table.insert(p,n(q))end end if#p==0 then return
'None'end if#p<=2 then return table.concat(p,', ')end return string.format(
'%s +%d',p[1],#p-1)end return if o==nil then'None'else n(o)end local function 
valueOf(m)local n=m.kind if n=='toggle'then return if m.value==true then'On'else
'Off'elseif n=='slider'then return formatted(m,m.value)elseif n=='dropdown'then
return pickText(m)elseif n=='input'then return if m.value==''then'Empty'else
tostring(m.value)elseif n=='stat'then return tostring(m.value)end return''end
function g.focusable(m)local n=m.kind if n=='divider'or n=='stat'then return
false end return not(n=='label'and not m.addons)end function g.build(m,n,o)local
p=m.theme local q=n.kind local r=e('TextButton',{Name=q,AnchorPoint=Vector2.new(
0,0.5),Size=UDim2.fromOffset(g.NAME*18,g.HEIGHT),Active=true})local s=e(
'UIScale',{Parent=r})local t=e('TextLabel',{Name='Name',Size=UDim2.new(0.62,0,1,
0),TextSize=g.NAME,TextTruncate=Enum.TextTruncate.AtEnd,Text=n.label,Parent=r})p
:type(t,'display')local u=e('TextLabel',{Name='Value',AnchorPoint=Vector2.new(1,
0),Position=UDim2.fromScale(1,0),Size=UDim2.new(0.38,0,1,0),TextSize=g.VALUE,
TextXAlignment=Enum.TextXAlignment.Right,TextTruncate=Enum.TextTruncate.AtEnd,
Parent=r})p:type(u,'display')local v={root=r,el=n,_scale=s,_name=t,_value=u,
_cleanups={}}local w=nil local x=nil if q=='slider'then w=e('Frame',{AnchorPoint
=Vector2.new(0,1),Position=UDim2.new(0,0,1,-2),Size=UDim2.new(1,0,0,h),
BackgroundTransparency=0,Visible=false,Parent=r})p:paint(w,'BackgroundColor3',
'lineStrong')local y=e('Frame',{BackgroundTransparency=0,Size=UDim2.fromScale((n
.value-n.spec.min)/math.max(n.spec.max-n.spec.min,1e-6),1),Parent=w})p:paint(y,
'BackgroundColor3','accent')x=f.prop(y,'Size',i)table.insert(v._cleanups,
function()x:destroy()end)v._bar=w end local y={}local z=0 for A,B in n.addons or
{}do if not B.spec.chipless then local C=if B.kind=='key'then b.build(m,B)else c
.swatch(m,B)C.root.AnchorPoint=Vector2.new(1,0.5)C.root.Position=UDim2.new(1,-(
150+z),0.5,0)C.root.Visible=false C.root.Parent=r z+=C.width+8 B._view=C table.
insert(y,C)table.insert(v._cleanups,function()B._view=nil C.destroy()end)end end
v._chips=y local A={}local function ink(B,C)local D=A[B]if D==nil then D=f.prop(
B,'TextColor3',l)A[B]=D table.insert(v._cleanups,function()D:destroy()end)end D:
to(p.tokens[C])end v.focused=false local function paint()local B=q=='toggle'and
n.value==true local C=if n.disabled then'faint'elseif B then'accent'elseif v.
focused then'text'else'muted'local D=if n.disabled then'faint'elseif B then
'accent'elseif q=='toggle'then'faint'else'text'ink(t,C)ink(u,D)end function v.
setFocused(B)if v.focused==B then return end v.focused=B for C,D in y do D.root.
Visible=B end if v._bar then v._bar.Visible=B end paint()end function v.place(B,
C,D,E)r.Position=UDim2.fromOffset(B,C)s.Scale=D t.TextTransparency=E u.
TextTransparency=E if w then w.BackgroundTransparency=E w:FindFirstChildOfClass(
'Frame').BackgroundTransparency=E end end v.refresh=function()if n.disabled then
t.RichText=true t.Text='<s>'..n.label..'</s>'else t.RichText=n.kind=='label't.
Text=n.label end u.Text=valueOf(n)paint()if x then local B=n.spec.max-n.spec.min
x:to(UDim2.fromScale(if B<=0 then 0 else(n.value-n.spec.min)/B,1))end for B,C in
y do C.refresh()end end local function typedEntry()if n.disabled or v._typing
then return end v._typing=true u.Visible=false local B=e('TextBox',{AnchorPoint=
Vector2.new(1,0),Position=UDim2.fromScale(1,0),Size=UDim2.new(0.38,0,1,0),
TextSize=g.VALUE,TextXAlignment=Enum.TextXAlignment.Right,Text=if q=='input'then
tostring(n.value or'')else'',PlaceholderText=if q=='input'then(n.spec.
placeholder or'')else tostring(n.value),Parent=r})p:type(B,'display')p:paint(B,
'TextColor3','accent')p:paint(B,'PlaceholderColor3','faint')B:CaptureFocus()B.
FocusLost:Connect(function(C)v._typing=false u.Visible=true local D=B.Text B:
Destroy()if q=='input'then if not n.spec.finished or C then n:set(D)end else
local E=tonumber(D)if E then n:set(E)end end end)end function v.act()if n.
disabled then return end if q=='toggle'then n:set(not n.value)elseif q=='button'
then if n.spec.confirm and not v._armed then v._armed=true t.Text=
'Again to confirm'task.delay(2.5,function()v._armed=false v.refresh()end)return
end v._armed=false v.refresh()n:fire()elseif q=='dropdown'then d.open(m,n,u)
elseif q=='input'or q=='slider'then typedEntry()elseif q=='color'then v._swatch.
open()elseif q=='key'then v._chip.start()end end function v.nudge(B)if n.
disabled then return end if q=='slider'then n:set(n.value+B*(n.spec.step or 1))
elseif q=='toggle'then n:set(B>0)elseif q=='dropdown'and not n.spec.multi then
local C=n.spec.options local D=table.find(C,n.value)or 0 local E=C[math.clamp(D+
B,1,math.max(#C,1))]if E~=nil then n:set(E)end end end r.InputBegan:Connect(
function(B)local C=B.UserInputType if C~=Enum.UserInputType.MouseButton1 and C~=
Enum.UserInputType.Touch then return end local D=if C==Enum.UserInputType.Touch
then m.input:at(B)else m.input:pointer()if not v.focused then o:focusOn(n)return
end if q=='slider'and not n.disabled then local E=n.value local F=math.max(r.
AbsoluteSize.X,1)local G=n.spec.max-n.spec.min local H=false m.input:capture(
function(I)local J=I-D if not H and math.abs(J.X)<k then return end if not H
then H=true x.speed=j end n:set(E+G*J.X/F)end,function(I)x.speed=i if not H and(
I-D).Magnitude<8 then typedEntry()end end,if C==Enum.UserInputType.Touch then B
else nil)return end v.act()end)if q=='key'then local B=b.build(m,n)B.root.
AnchorPoint=Vector2.new(1,0.5)B.root.Position=UDim2.new(1,0,0.5,0)B.root.Parent=
r v._chip=B table.insert(v._cleanups,B.destroy)local C=v.refresh v.refresh=
function()C()B.refresh()end elseif q=='color'then local B=c.swatch(m,n)B.root.
AnchorPoint=Vector2.new(1,0.5)B.root.Position=UDim2.new(1,0,0.5,0)B.root.Parent=
r v._swatch=B table.insert(v._cleanups,B.destroy)local C=v.refresh v.refresh=
function()C()B.refresh()end end if q=='divider'or(q=='label'and not n.addons)
then t.Size=UDim2.fromScale(1,1)t.RichText=true t.TextSize=26 p:type(t,'text')u.
Visible=false r.Active=false end v.destroy=function()for B,C in v._cleanups do
pcall(C)end r:Destroy()end v.refresh()return v end return g end function a.y()
local b=a.cache.y if not b then b={c=__modImpl()}a.cache.y=b end return b.c end
end do local function __modImpl()local b=a.b()local c=a.p()local d=a.y()local e=
{}local f=5 local g=72 local h=0.05 local i=0.13 local j=0.56 local k=0.75 local
l=0.22 local m=20 local n=24 local o=820 local p={}p.__index=p function p.nextId
(q)q._ids+=1 return q._ids end function p._register(q,r,s)r._relayout=function()
q:_invalidate()end q.window:_registerElement(r,q,s)end function p._invalidate(q)
if q._dirty then return end q._dirty=true task.defer(function()q._dirty=false if
not q.destroyed then q:rebuild()end end)end function p.section(q,r)local s=c.
new(q,r)table.insert(q.sections,s)q:_invalidate()return s end function p.tabset(
q)local r={}function r.tab(s,t)return q:section(t)end return r end function p.
tabs(q,r)local s={}for t,u in r do table.insert(s,q:section(u))end return s end
function p.hero(q,r)q.window:_setPerson(r)return{set=function(s,t,u)r.title=t or
r.title r.text=u or r.text q.window:_setPerson(r)end}end local function 
headingFor(q,r)local s=q._headings[r]if s==nil then s={kind='divider',label=r.
title,spec={},shown=function()return true end,addons=nil,disabled=false}q.
_headings[r]=s end return s end function p.rebuild(q)local r=q._index or{}local
s={}for t,u in q.sections do local v={}for w,x in u.rows do if x:shown()then
table.insert(v,x)end end if#v>0 then if u.title~=''and not u.masterElement then
table.insert(s,headingFor(q,u))end for w,x in v do table.insert(s,x)end end end
local t={}for u,v in s do t[v]=u end q._list=s q._index=t q._from=r local u=q.
_focusEl local v=if u then t[u]else nil if v==nil then v=q:_firstFocusable(q.
_target or 1)end if v then q._focusEl=s[v]local w=v-(r[u]or v)if q.active and w
~=0 then q._focus:snap((q._focus.target or v)+w)end q._target=v q._focus:to(v)
end if q.active and q._built then q._blendValue=0 q._blend:snap(0)q._blend:to(1)
else q._blendValue=1 end q._built=true q.window:_reportCount(q)q:place()end
function p._firstFocusable(q,r)local s=q._list if s==nil or#s==0 then return nil
end for t=1,#s do for u,v in{r+t-1,r-t+1}do local w=s[v]if w and d.focusable(w)
then return v end end end return math.clamp(r,1,#s)end function p.step(q,r)local
s=q._list if s==nil then return end local t=q._target or 1 repeat t+=r until t<1
or t>#s or d.focusable(s[t])if t>=1 and t<=#s then q._target=t q._focusEl=s[t]q.
_focus:to(t)q:place()end end function p.focusOn(q,r)local s=q._index and q.
_index[r]if s then q._target=s q._focusEl=r q._focus:to(s)q:place()end end
function p.current(q)return q._focusEl and q._views[q._focusEl]end function p.
place(q)local r=q._list if r==nil or not q.active then return end local s=q.
_focusValue local t=q._blendValue or 1 local u=q.window local v=u._stage.
AbsoluteSize local w=u._scale.Scale local x=math.min(v.X*0.72,o)*w local y=math.
floor((v.X-x)/2)local z=v.Y*0.5 local A=q._from or{}local B={}for C,D in r do
local E=A[D]or C local F=E+(C-E)*t local G=F-s local H=math.abs(G)if H<=f then
local I=q._views[D]if I==nil then I=d.build(u.ctx,D,q)I.root.Parent=q.host q.
_views[D]=I end B[D]=true local J=G*g*(1-h*math.min(H,5))*w local K=math.max(1-i
*H,j)*w local L=math.clamp((H-k)*l,0,1)I.root.Visible=true I.root.Size=UDim2.
fromOffset(x/K,d.HEIGHT)I.place(y,z+J,K,L)I.setFocused(D==q._focusEl and H<0.5)
end end for C,D in q._views do if not B[C]then D.root.Visible=false end end end
function p.rowY(q,r)return q._index and q._index[r]end function p.viewOf(q,r)
return q._views[r]end function p.scrollTo(q,r,s)local t=q._list if t==nil then
return end local u=q:_firstFocusable(math.clamp(r,1,#t))if u then q._target=u q.
_focusEl=t[u]if s then q._focus:snap(u)else q._focus:to(u)end end end function p
.spinIn(q,r)local s=q._target or 1 q._focus:snap(s+r)q._focus:to(s)q:place()end
function p.mount(q,r)q.host=r q._focusValue=1 q._focus=b.new(1,m,function(s)q.
_focusValue=s q:place()end)q._blend=b.new(1,n,function(s)q._blendValue=s q:
place()end)end function p.setActive(q,r)q.active=r if r then q:rebuild()else for
s,t in q._views do t.root.Visible=false end end end function p.destroy(q)q.
destroyed=true for r,s in q._views do s.destroy()end q._views={}if q._focus then
q._focus:destroy()q._blend:destroy()end end function e.new(q,r)return
setmetatable({name=r,window=q,sections={},active=false,destroyed=false,_ids=0,
_dirty=false,_views={},_headings={}},p)end return e end function a.z()local b=a.
cache.z if not b then b={c=__modImpl()}a.cache.z=b end return b.c end end do
local function __modImpl()local b=a.f()local c=a.b()local d=a.h()local e={}local
f=600 local g=46 local h=68 local i=7 local j=34 local k=48 local function 
describe(l)local m=l._pageName or''if l.kind=='toggle'then return(if l.value
then'On, 'else'Off, ')..m end if l.kind=='slider'then return tostring(l.value)..
(l.spec.suffix or'')..', '..m end if l.kind=='dropdown'and not l.spec.multi and
l.value~=nil then return tostring((l.spec.display or tostring)(l.value))..', '..
m end return m end function e.new(l,m,n,o)local p=l.theme local q={}local r=
false local s,t,u,v local w={}local x={}local y=1 local function close()if not r
then return end r=false s:Destroy()local z,A=t,u A.speed=k A:to(UDim2.
fromOffset(f,0),function()A:destroy()z:Destroy()end)table.clear(x)end local 
function draw()if not r then return end for z,A in x do local B=w[z]if B then A.
root.Visible=true A.name.Text=B.label A.where.Text=describe(B)A.root.
BackgroundTransparency=if z==y then 0 else 1 p:paint(A.name,'TextColor3',if z==y
then'onAccent'else'text')p:paint(A.where,'TextColor3',if z==y then'onAccent'else
'muted')else A.root.Visible=false end end local z=math.min(#w,i)local A=h+(if z>
0 then z*g+10 else 0)u:to(UDim2.fromOffset(f,A))end local function run(z)if z==
nil then return end close()if z.kind=='toggle'and not z.disabled then z:set(not
z.value)l.notify({title=z.label,text=if z.value then'On'else'Off',seconds=2})
else o(z)end end local function query()local z=v.Text if z==''then w={}for A,B
in n()do if B.kind=='toggle'and B.value==true then table.insert(w,B)if#w==i then
break end end end else w=d.settings(z,n(),i)end y=1 draw()end function q.toggle(
z)if r then close()return end r=true local A=m.AbsoluteSize s=b('TextButton',{
Size=UDim2.fromScale(1,1),BackgroundTransparency=0.45,BackgroundColor3=Color3.
new(0,0,0),ZIndex=40,Parent=m})s.MouseButton1Down:Connect(close)t=b('Frame',{
Name='Palette',Position=UDim2.fromOffset(math.floor((A.X-f)/2),math.floor(A.Y*
0.22)),Size=UDim2.fromOffset(f,0),BackgroundTransparency=0,ClipsDescendants=true
,Active=true,ZIndex=41,Parent=m})p:paint(t,'BackgroundColor3','surface')local B=
b('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=t})p:paint(B,
'Color','lineStrong')u=c.prop(t,'Size',j)v=b('TextBox',{Position=UDim2.
fromOffset(18,0),Size=UDim2.new(1,-36,0,h),TextSize=36,Text='',PlaceholderText=
'Find a setting',ZIndex=42,Parent=t})p:type(v,'display')p:paint(v,'TextColor3',
'text')p:paint(v,'PlaceholderColor3','faint')for C=1,i do local D=b('TextButton'
,{Position=UDim2.fromOffset(6,h+(C-1)*g+2),Size=UDim2.new(1,-12,0,g),Visible=
false,ZIndex=42,Parent=t})p:paint(D,'BackgroundColor3','accent')local E=b(
'TextLabel',{Position=UDim2.fromOffset(12,0),Size=UDim2.new(0.6,-12,1,0),
TextSize=16,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=43,Parent=D})p:type(E,
'text',true)p:paint(E,'TextColor3','text')local F=b('TextLabel',{AnchorPoint=
Vector2.new(1,0),Position=UDim2.new(1,-12,0,0),Size=UDim2.new(0.4,-12,1,0),
TextSize=16,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.
TextXAlignment.Right,ZIndex=43,Parent=D})p:type(F,'text')p:paint(F,'TextColor3',
'faint')x[C]={root=D,name=E,where=F}D.MouseEnter:Connect(function()if y~=C then
y=C draw()end end)D.Activated:Connect(function()run(w[C])end)end v:
GetPropertyChangedSignal('Text'):Connect(query)v.FocusLost:Connect(function(C)if
C then run(w[y])end end)query()v:CaptureFocus()end function q.isOpen(z)return r
end q.close=close function q.key(z,A)if not r then return false end if A==
'Escape'then close()return true end if A=='Down'or A=='Up'then if#w>0 then y=
math.clamp(y+(if A=='Down'then 1 else-1),1,#w)draw()end return true end return
false end return q end return e end function a.A()local b=a.cache.A if not b
then b={c=__modImpl()}a.cache.A=b end return b.c end end do local function 
__modImpl()local b=a.f()local c=UDim2.fromOffset(16,72)local d=44 return
function(e,f,g)local h=b('TextButton',{Name='Open',Position=c,Size=UDim2.
fromOffset(d,d),BackgroundTransparency=0,TextSize=24,Text='s',Visible=false,
ZIndex=50,Parent=e})f:type(h,'display')f:paint(h,'BackgroundColor3','accent')f:
paint(h,'TextColor3','onAccent')h.Activated:Connect(g)return h end end function
a.B()local b=a.cache.B if not b then b={c=__modImpl()}a.cache.B=b end return b.c
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
return c end function a.C()local b=a.cache.C if not b then b={c=__modImpl()}a.
cache.C=b end return b.c end end do local function __modImpl()local b=a.b()local
c={}local d=26 function c.new(e)local f={}return function(g,h,i,j)local k=f[g]if
k==nil then k={}f[g]=k end local l=k[h]if l==nil then l=b.prop(g,h,j or d)k[h]=l
end l:to(e.tokens[i])end end return c end function a.D()local b=a.cache.D if not
b then b={c=__modImpl()}a.cache.D=b end return b.c end end do local function 
__modImpl()local b=a.q()local c=a.a()local d=a.r()local e=a.s()local f=a.u()
local g=a.v()local h=a.t()local i=a.f()local j=a.j()local k=a.b()local l=a.w()
local m=a.x()local n=a.z()local o=a.A()local p=a.p()local q=a.B()local r=a.n()
local s=a.C()local t=a.D()local u={}local v='main'local w=
[[https://raw.githubusercontent.com/interestng/sottUI/%s/fonts/]]local x=0.3
local y=18 local z=22 local A=28 local B=48 local C=48 local D=76 local E=5
local F=7 local G=12 local H=28 local I=560 local J={}J.__index=J local function 
randomName()local K=table.create(G)for L=1,G do K[L]=string.char(math.random(97,
122))end return table.concat(K)end local function encode(K)return c.service(
'HttpService'):JSONEncode(K)end local function decode(K)local L,M=pcall(function
()return c.service('HttpService'):JSONDecode(K)end)return if L then M else nil
end function J._registerElement(K,L,M,N)L._pageName=M.name L._page=M if N then
if K.elements[L.id]then error('sottUI: element id used twice: '..L.id,3)end K.
elements[L.id]=L end if L.kind~='divider'and L.kind~='label'and L.kind~='stat'
then table.insert(K.ordered,L)end L:on(function()local O=M:viewOf(L)if O then O.
refresh()end end)end function J._setPerson(K,L)K._personName.Text=L.title or''K.
_personLine.RichText=true K._personLine.Text=L.text or''end function J.
_reportCount(K,L)end function J._syncMarker(K,L)local M=K._navItems[K.current]if
M==nil then return end local N=K._navList local O=M.AbsolutePosition.X-N.
AbsolutePosition.X local P=UDim2.fromOffset(O,z+12)local Q=UDim2.fromOffset(M.
AbsoluteSize.X,3)if L then K._markerAt:snap(P)K._markerSize:snap(Q)else K.
_markerAt:to(P)K._markerSize:to(Q)end end function J.page(K,L)local M=n.new(K,L)
table.insert(K.pages,M)local N=#K.pages local O=K.ctx.theme local P=math.ceil(j.
width('display',L,z))+4 local Q=i('TextButton',{Name=L,Size=UDim2.fromOffset(P,z
+10),TextSize=z,Text=L,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=N,
Parent=K._navList})O:type(Q,'display')O:paint(Q,'TextColor3','faint')K._navItems
[N]=Q Q.Activated:Connect(function()K:show(N)end)Q.MouseEnter:Connect(function()
if K.current~=N then K.ctx.tint(Q,'TextColor3','muted')end end)Q.MouseLeave:
Connect(function()if K.current~=N then K.ctx.tint(Q,'TextColor3','faint')end end
)M:mount(K._stage)if K.current==nil then K:show(N,true)end return M end function
J.show(K,L,M)local N=K.pages[L]if N==nil or K.current==L then return end K.ctx.
popover:close()K.keys:cancel()local O=K.ctx.tint local P=K.pages[K.current]if P
then P:setActive(false)O(K._navItems[K.current],'TextColor3','faint')end local Q
=K.current==nil or L>K.current K.current=L O(K._navItems[L],'TextColor3','text')
N:setActive(true)K:_syncMarker(M)K:_saveState()if not M then N:spinIn(if Q then-
E else E)end end function J.showPage(K,L)for M,N in K.pages do if N.name==L then
K:show(M)return end end end function J.reveal(K,L)local M=L._page if M==nil then
return end if not K.isOpen then K:setOpen(true)end K.ctx.popover:close()K:
showPage(M.name)local N=L.host or L local O=L.section and(L.section._root or L.
section)if O and O.masterElement and O.masterElement.value~=true and N~=O.
masterElement then O.peeking=true M:rebuild()end M:focusOn(N)end function J.
setOpen(K,L)if K.isOpen==L or K.destroyed then return end K.isOpen=L if K.
_opener then K._opener.Visible=not L end K.ctx.popover:close()K._palette.close()
K.ctx.tooltip:hide()K.keys:cancel()if not L and K._dialogClose then K.
_dialogClose()end local M=K.pages[K.current]if L then K._root.Visible=true K.
_modal.Visible=true K:_guardCursor(true)K._shade:to(x)K._lift:to(UDim2.
fromScale(0,0))if M then M:rebuild()M:spinIn(F)end else K._modal.Visible=false K
:_guardCursor(false)K._lift:to(UDim2.new(0,0,0,40))K._shade:to(1,function()if
not K.isOpen then K._root.Visible=false end end)end K.visibilityChanged:fire(L)
end function J._guardCursor(K,L)local M=c.service('UserInputService')if L then K
._gameCursor=M.MouseIconEnabled M.MouseIconEnabled=true if K._cursorGuard==nil
then K._cursorGuard=M:GetPropertyChangedSignal('MouseIconEnabled'):Connect(
function()if not M.MouseIconEnabled then K._gameCursor=false M.MouseIconEnabled=
true end end)end else if K._cursorGuard then K._cursorGuard:Disconnect()K.
_cursorGuard=nil end if K._gameCursor~=nil then M.MouseIconEnabled=K._gameCursor
K._gameCursor=nil end end end function J.toggle(K)K:setOpen(not K.isOpen)end
function J.notify(K,L)if K.destroyed then return end K.ctx.notify(L)end function
J.setTheme(K,L)K.ctx.theme:apply(L)end function J.setScale(K,L)K._scale.Scale=
math.clamp(L,0.7,1.5)local M=K.pages[K.current]if M then M:place()end K:
_saveState()end function J.setSubtitle(K,L)K._subtitleText=L K._personLine.Text=
L end function J._saveState(K)local L=K._files if L==nil or K._stateFile==nil or
K._stateQueued then return end K._stateQueued=true task.delay(0.5,function()K.
_stateQueued=false if K.destroyed then return end local M=K.pages[K.current]L.
write(K._stateFile,encode({page=M and M.name,scale=K._scale.Scale}))end)end
function J.restorePage(K)local L=K._savedPage if L then K._savedPage=nil for M,N
in K.pages do if N.name==L then K:show(M,true)return end end end end function J.
dialog(K,L,M)if K.destroyed then return false end b.open(K,L,M)return true end
function J.find(K,L)return K.elements[L]end function J.snapshot(K)local L={}for
M,N in K.elements do if N.saved then local O=N.value if N.kind=='color'then O={
hex=O.color:ToHex(),alpha=O.alpha}elseif N.kind=='key'then O={key=O.key,mode=O.
mode,modifiers=O.modifiers,toggled=N.toggled==true}end L[M]=O end end return L
end function J.restore(K,L)for M,N in L do local O=K.elements[M]if O and O.saved
then if O.kind=='color'and type(N)=='table'then O:set({color=Color3.fromHex(N.
hex or'ffffff'),alpha=N.alpha})elseif O.kind=='key'and type(N)=='table'then O:
set(N)O.toggled=N.toggled==true else O:set(N)end end end end function J.destroy(
K)if K.destroyed then return end K.destroyed=true K:_guardCursor(false)K.ctx.
notifications:destroy()for L,M in K.pages do M:destroy()end K.ctx.input:destroy(
)K._maid:clean()K.visibilityChanged:clear()if K._registry and K._registry.
current==K then K._registry.current=nil end end function u.new(K)local L=K.
_registry if L and L.current then L.current:destroy()end local M=h.new()local N=
s.new(K.theme)local O=f.new()local P=c.service('UserInputService')local Q=P.
TouchEnabled and not P.MouseEnabled local R=i('ScreenGui',{Name=randomName(),
IgnoreGuiInset=true,ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.
Sibling,DisplayOrder=K.displayOrder or 10000})c.protect(R)R.Parent=c.guiParent()
M:add(R)local S=c.files()local T=K.folder or'sottui_stage'local U=K.stateFile or
(T..'/window.json')local V=nil if S then S.folder(T)local W=S.read(U)V=W and
decode(W)end if type(V)~='table'then V={}end local W=i('TextButton',{Name='Root'
,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,Parent=R})N:
paint(W,'BackgroundColor3','base')local X=i('TextButton',{Name='Modal',Size=
UDim2.fromOffset(0,0),Modal=true,Visible=false,Parent=W})local Y=i('Frame',{Size
=UDim2.fromScale(1,1),BackgroundTransparency=0,Parent=W})N:paint(Y,
'BackgroundColor3','base')i('UIGradient',{Transparency=NumberSequence.new({
NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.1,0.94),
NumberSequenceKeypoint.new(0.2,0.74),NumberSequenceKeypoint.new(0.3,0.42),
NumberSequenceKeypoint.new(0.4,0.18),NumberSequenceKeypoint.new(0.5,0.12),
NumberSequenceKeypoint.new(0.6,0.18),NumberSequenceKeypoint.new(0.7,0.42),
NumberSequenceKeypoint.new(0.8,0.74),NumberSequenceKeypoint.new(0.9,0.94),
NumberSequenceKeypoint.new(1,1)}),Parent=Y})local Z=i('Frame',{Name='Stage',Size
=UDim2.fromScale(1,1),ClipsDescendants=true,Parent=W})local _=i('Frame',{Name=
'Layer',Size=UDim2.fromScale(1,1),ZIndex=100,Parent=R})local aa=i('TextLabel',{
AutomaticSize=Enum.AutomaticSize.X,Position=UDim2.fromOffset(C,60),Size=UDim2.
fromOffset(0,z+10),TextSize=z,Text=K.title or'sottoro',ZIndex=5,Parent=W})N:
type(aa,'display')N:paint(aa,'TextColor3','accent')local ab=i('Frame',{Name=
'Nav',Position=UDim2.fromOffset(C+130,60),Size=UDim2.new(1,-(C*2+130+140),0,z+18
),ZIndex=5,Parent=W})local ac=i('Frame',{Name='List',Size=UDim2.fromScale(1,1),
ZIndex=5,Parent=ab})i('UIListLayout',{FillDirection=Enum.FillDirection.
Horizontal,Padding=UDim.new(0,A),SortOrder=Enum.SortOrder.LayoutOrder,Parent=ac}
)local ad=i('Frame',{Name='Marker',Position=UDim2.fromOffset(0,z+12),Size=UDim2.
fromOffset(0,3),BackgroundTransparency=0,ZIndex=6,Parent=ab})N:paint(ad,
'BackgroundColor3','accent')local ae=i('Frame',{AnchorPoint=Vector2.new(0,1),
Position=UDim2.new(0,C,1,-36),Size=UDim2.fromOffset(D,D),BackgroundTransparency=
0,ClipsDescendants=true,ZIndex=5,Parent=W})N:paint(ae,'BackgroundColor3',
'accent')local af=c.service('Players').LocalPlayer if af then i('ImageLabel',{
Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,Image=
string.format('rbxthumb://type=AvatarBust&id=%d&w=150&h=150',af.UserId),ZIndex=5
,Parent=ae})end local ag=i('TextLabel',{AnchorPoint=Vector2.new(0,1),Position=
UDim2.new(0,C+D+14,1,-62),Size=UDim2.fromOffset(480,36),TextSize=30,Text=if af
then af.DisplayName else'',ZIndex=5,Parent=W})N:type(ag,'display')N:paint(ag,
'TextColor3','text')local ah=i('TextLabel',{AnchorPoint=Vector2.new(0,1),
Position=UDim2.new(0,C+D+14,1,-38),Size=UDim2.fromOffset(480,22),TextSize=17,
Text=K.subtitle or'',ZIndex=5,Parent=W})N:type(ah,'text')N:paint(ah,'TextColor3'
,'muted')local ai=setmetatable({ctx=nil,pages={},elements={},ordered={},current=
nil,isOpen=false,destroyed=false,visibilityChanged=r.new(),_maid=M,_gui=R,_root=
W,_stage=Z,_layer=_,_modal=X,_scale={Scale=tonumber(V.scale)or 1},_navList=ac,
_navItems={},_personName=ag,_personLine=ah,_subtitleText=K.subtitle,_files=S,
_stateFile=U,_savedPage=V.page,_dialogIds=0,_registry=L,width=460},J)if L then L
.current=ai end local aj={theme=N,input=O,touch=Q,assets={},glyph=e.new(N),tint=
t.new(N),uiScale=function()return 1 end,popoverTop=function()return 8 end,
paletteAt=function()local aj=_.AbsoluteSize return UDim2.fromOffset(math.floor((
aj.X-I)/2),math.floor(aj.Y*0.2))end,paletteWidth=function()return I end,dialogAt
=function()local aj=_.AbsoluteSize return UDim2.fromOffset(math.floor((aj.X-460)
/2),math.floor(aj.Y*0.18))end,isShowing=function()return ai.isOpen end,
setScrollLocked=function()end}ai.ctx=aj aj.popover=m.popover(aj,_)aj.tooltip=m.
tooltip(aj,_)aj.hover=m.hover(aj)aj.notifications=l.new(aj,_)aj.notify=function(
ak)aj.notifications:show(ak)end ai.keys=g.new(O,c,function()return ai.isOpen end
)aj.keys=ai.keys ai._markerAt=M:add(k.prop(ad,'Position',H))ai._markerSize=M:
add(k.prop(ad,'Size',H))ai._shade=M:add(k.new(1,y,function(ak)W.
BackgroundTransparency=ak Y.BackgroundTransparency=if ak>=1 then 1 else 0 end))
ai._lift=M:add(k.prop(Z,'Position',y))ai._palette=o.new(aj,_,function()return ai
.ordered end,function(ak)ai:reveal(ak)end)local ak=i('TextButton',{AnchorPoint=
Vector2.new(1,1),Position=UDim2.new(1,-C+8,1,-B),Size=UDim2.fromOffset(34,34),
ZIndex=5,Parent=W})local al=aj.glyph.cross(ak,'muted')al.AnchorPoint=Vector2.
new(0.5,0.5)al.Position=UDim2.fromScale(0.5,0.5)al.ZIndex=5 ak.Activated:
Connect(function()ai:setOpen(false)end)local am=i('TextButton',{AnchorPoint=
Vector2.new(1,1),Position=UDim2.new(1,-(C+34),1,-B),Size=UDim2.fromOffset(70,34)
,TextSize=18,Text='Search',TextXAlignment=Enum.TextXAlignment.Right,ZIndex=5,
Parent=W})N:type(am,'text',true)N:paint(am,'TextColor3','muted')am.MouseEnter:
Connect(function()aj.tint(am,'TextColor3','text')end)am.MouseLeave:Connect(
function()aj.tint(am,'TextColor3','muted')end)am.Activated:Connect(function()ai.
_palette:toggle()end)O.wheel:connect(function(an)if not ai.isOpen or aj.popover:
isOpen()or ai._palette:isOpen()then return end local ao=ai.pages[ai.current]if
ao then ao:step(if an>0 then-1 else 1)end end)if Q then W.InputBegan:Connect(
function(an)if an.UserInputType~=Enum.UserInputType.Touch then return end local
ao=ai.pages[ai.current]if ao==nil then return end local ap=O:at(an)local aq=ao.
_target or 1 O:capture(function(ar)local as=math.round((ap.Y-ar.Y)/64)ao:
scrollTo(aq+as)ao:place()end,nil,an)end)end O.keyDown:connect(function(an,ao)if
an.UserInputType~=Enum.UserInputType.Keyboard then return end local ap=an.
KeyCode.Name if ai._palette:key(ap)or aj.popover:key(ap)then return end if ap==
'Escape'and ai._dialogClose then ai._dialogClose()return end if ao or O:typing()
or not ai.isOpen then return end local aq=ai.pages[ai.current]if ap=='K'and(P:
IsKeyDown(Enum.KeyCode.LeftControl)or P:IsKeyDown(Enum.KeyCode.RightControl))
then ai._palette:toggle()elseif aq and ap=='Up'then aq:step(-1)elseif aq and ap
=='Down'then aq:step(1)elseif aq and(ap=='Left'or ap=='Right')then local ar=aq:
current()if ar then ar.nudge(if ap=='Left'then-1 else 1)end elseif aq and ap==
'Return'then local ar=aq:current()if ar then ar.act()end elseif ap=='Tab'then ai
:show((ai.current%#ai.pages)+1)end end)M:add(R:GetPropertyChangedSignal(
'AbsoluteSize'):Connect(function()local an=ai.pages[ai.current]if an then an:
place()end end))M:add(N.changed:connect(function()for an,ao in ai.pages do for
ap,aq in ao._views do pcall(aq.refresh)end end end))local an=p.new({window=ai,
nextId=function()return 0 end,_register=function(an,ao,ap)if ap then ai.elements
[ao.id]=ao end ao._pageName=''end,_invalidate=function()end},'')ai.menuKey=an:
key('__menu',{label='Menu',default=K.key or'RightShift',mode='Toggle',saved=
false,onPress=function()ai:toggle()end})local ao=c.service('RunService')k.
setAttach(function(ap)return ao.PreRender:Connect(ap)end)if K.fonts~=false and S
then M:add(task.defer(function()local ap=K.fontTag or v local aq=d.load(T..
'/fonts-'..ap,string.format(w,ap),encode)if not ai.destroyed and(aq.text or aq.
display)then N:setFonts(aq.text,aq.display)end end))end if Q then ai._opener=q(R
,N,function()ai:setOpen(true)end)end if K.autoShow~=false then task.defer(
function()ai:setOpen(true)end)end return ai end function u.setVersion(aa)v=aa
end return u end function a.E()local aa=a.cache.E if not aa then aa={c=
__modImpl()}a.cache.E=aa end return aa.c end end end local aa=a.a()local ab=a.b(
)local ac=a.e()local ad=a.E()local ae='0.1.6-stage'local function registry()
local af=aa.global('getgenv')local ag=if type(af)=='function'then af()else _G
local ah=ag.__sottui if type(ah)~='table'then ah={current=nil}ag.__sottui=ah end
return ah end local af={version=ae,motion=ab}ad.setVersion('v'..ae)function af.
window(ag)local ah=table.clone(ag or{})ah._registry=registry()return ad.new(ah)
end function af.current()return registry().current end function af.obsidian()
return ac.new(af)end return af