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
A=4 local B=12 local C=34 local D=17 local E=16 local F=50 local G=44 local H=8
local I=36 local J={}local function addons(K,L,M,N,O)local P=N local Q={}local 
function reflow()local R=N for S,T in Q do if O then T.root.Position=UDim2.new(0
,j+R,1,0)else T.root.Position=UDim2.new(1,-(j+R),0.5,0)end R+=T.width+T.gap end
if not O then K.name.Size=UDim2.new(1,-(2*j+R),1,0)end end local function place(
R,S)S.root.AnchorPoint=if O then Vector2.new(0,1)else Vector2.new(1,0.5)S.root.
Position=if O then UDim2.new(0,j+P,1,0)else UDim2.new(1,-(j+P),0.5,0)S.root.
ZIndex=4 S.root.Parent=K.root S.gap=if R.kind=='key'then 6 else 0 S.onFit=reflow
P+=S.width table.insert(Q,S)R._view=S K.addonChips=K.addonChips or{}K.addonChips
[R]=S table.insert(K.chips,S)K:onCleanup(function()R._view=nil S.destroy()end)
end for R,S in M.addons or{}do if S.kind=='color'and not S.spec.chipless then
place(S,b.swatch(L,S))end end for R,S in M.addons or{}do if S.kind=='key'and not
S.spec.chipless then place(S,d.build(L,S))P+=6 end end return P end local 
function reserveRight(K,L)K.name.Size=UDim2.new(1,-(2*j+L),1,0)end local 
function baseline(K,L,M,N)local O=e('Frame',{Name='Track',AnchorPoint=Vector2.
new(0,1),Position=UDim2.fromScale(0,1),Size=UDim2.new(1,0,0,v),
BackgroundTransparency=0,ZIndex=2,Parent=K.root})L.theme:paint(O,
'BackgroundColor3','lineStrong')local P=e('Frame',{Name='Fill',AnchorPoint=
Vector2.new(0,1),Position=UDim2.fromScale(0,1),Size=UDim2.new(M,0,0,N or w),
BackgroundTransparency=0,ZIndex=2,Parent=K.root})L.theme:paint(P,
'BackgroundColor3','accent')return P end function J.toggle(K,L)local M=L.spec.
primary==true local N=h.new(K,L,{quiet=not M})local O=K.theme if not M then
local P=baseline(N,K,if L.value==true then 1 else 0)local Q=N:own(g.prop(P,
'Size',o))local R=e('Frame',{Name='Mark',AnchorPoint=Vector2.new(1,0.5),Position
=UDim2.new(1,-j,0.5,0),Size=UDim2.fromOffset(x,x),ZIndex=3,Parent=N.root})local
S=e('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,Parent=R
})reserveRight(N,addons(N,K,L,x+y))local function draw(T)local U=L.value==true R
.BackgroundTransparency=if U then 0 else 1 O:paint(R,'BackgroundColor3','accent'
)O:paint(S,'Color',if U then'accent'elseif L.disabled then'line'else'muted')N:
tint(U,T)N:ink(N.name,if L.disabled then'faint'elseif U then'accentHover'else
'muted',T)local V=UDim2.new(if U then 1 else 0,0,0,w)if T or not K.isShowing(L)
then Q:snap(V)else Q:to(V)end for W,X in N.chips do X.setInk(false)if X.setMuted
then X.setMuted(not U)end end end N.root.Activated:Connect(function()if not L.
disabled then L:set(not L.value)end end)N.refresh=function()N:refreshName()draw(
false)end draw(true)return N end local P=u if M then O:type(N.name,'display')N.
name.TextSize=if L.value==true then m else l N.name.TextWrapped=false N.
_nameSize=N:own(g.prop(N.name,'TextSize',n))end N.name.Position=UDim2.
fromOffset(j,H)N.name.Size=UDim2.new(1,-(2*j+P+8),0,I)local Q=e('Frame',{
AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-j,0,H+(I-P)/2),Size=UDim2.
fromOffset(P,P),ZIndex=3,Parent=N.root})local R=e('UIStroke',{ApplyStrokeMode=
Enum.ApplyStrokeMode.Border,Thickness=2,Parent=Q})local S=nil local T=nil local
U=nil local V=P+12 if M then S=e('TextButton',{AnchorPoint=Vector2.new(1,1),
Position=UDim2.fromScale(1,1),Size=UDim2.fromOffset(F,G),ZIndex=4,Parent=N.root}
)T=K.glyph.chevron(S,'muted','down')U=K.glyph.chevron(S,'muted','up')for W,X in{
T,U}do X.AnchorPoint=Vector2.new(0.5,0.5)X.Position=UDim2.fromScale(0.5,0.5)end
V+=F S.Activated:Connect(function()L.section:togglePeek()N.refresh()end)end
addons(N,K,L,0,true)local function draw(W)local X=L.value==true local Y=M and X
if M then N:flood(X,W)local Z=if X then m else l if W or not K.isShowing(L)then
N._nameSize:snap(Z)else N._nameSize:to(Z)end end N:ink(N.name,if L.disabled then
'faint'elseif Y then'onAccent'elseif X then'text'else'muted',W)Q.
BackgroundTransparency=if X then 0 else 1 O:paint(Q,'BackgroundColor3',if Y then
'onAccent'else'accent')O:paint(R,'Color',if Y then'onAccent'elseif X then
'accent'elseif L.disabled then'line'else'lineStrong')for Z,_ in N.chips do _.
setInk(Y)end if S then local Z=L._shownOn and L._shownOn.sections[1]and L.
_shownOn.sections[1].flat S.Visible=L.section.hasOptions==true and not Z for _,
aa in{T,U}do for ab,ac in aa:GetChildren()do O:paint(ac,'BackgroundColor3',if Y
then'onAccent'else'muted')end end T.Visible=not L.section.peeking U.Visible=L.
section.peeking==true end end N.root.Activated:Connect(function()if not L.
disabled then L:set(not L.value)end end)N.refresh=function()N:refreshName()draw(
false)end draw(true)return N end local function formatted(aa,ab)local ac=aa.spec
if ac.format then local K,L=pcall(ac.format,aa,ab)if K and L~=nil then return
tostring(L)end end return string.format('%.'..(ac.decimals or 0)..'f',ab)..(ac.
suffix or'')end function i.readoutWidth(aa)local ab=aa.spec local ac=0 for K,L
in{ab.min,ab.max,aa.value}do ac=math.max(ac,f.width('textMedium',formatted(aa,L)
,k))end return math.ceil(ac*1.05)+2 end function J.slider(aa,ab)local ac=h.new(
aa,ab,{quiet=true})local K=aa.theme local L=ab.spec local M=ac.root local 
function ratio()local N=L.max-L.min return if N<=0 then 0 else(ab.value-L.min)/N
end local N=i.readoutWidth(ab)reserveRight(ac,N+r)ac.name.ZIndex=4 local O=e(
'TextLabel',{Name='Readout',AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-j
,0,0),Size=UDim2.new(0,N,1,0),TextSize=k,TextXAlignment=Enum.TextXAlignment.
Right,ZIndex=4,Parent=M})K:type(O,'text',true)local P=baseline(ac,aa,ratio(),z)
local Q=e('Frame',{Name='Head',AnchorPoint=Vector2.new(1,1),Position=UDim2.
fromScale(1,1),Size=UDim2.fromOffset(A,B),BackgroundTransparency=0,ZIndex=3,
Parent=P})K:paint(Q,'BackgroundColor3','text')local R=ac:own(g.prop(P,'Size',o))
local function typedEntry()if ab.disabled or ac._typing then return end ac.
_typing=true O.Visible=false local S=e('TextBox',{AnchorPoint=Vector2.new(1,0),
Position=UDim2.new(1,-j,0,0),Size=UDim2.new(0,math.max(N,64),1,0),TextSize=k,
TextXAlignment=Enum.TextXAlignment.Right,Text='',PlaceholderText=tostring(ab.
value),ZIndex=6,Parent=M})K:type(S,'display')K:paint(S,'TextColor3','accent')K:
paint(S,'PlaceholderColor3','faint')S:CaptureFocus()S.FocusLost:Connect(function
()local T=tonumber(S.Text)ac._typing=false O.Visible=true S:Destroy()if T then
ab:set(T)end end)end local function beginDrag(S,T,U)if ab.disabled then return
end local V=ab.value local W=math.max(M.AbsoluteSize.X,1)local X=L.max-L.min
local Y=false local Z=false aa.input:capture(function(_)local ad=_-S if not Y
then if math.abs(ad.X)<q then if T and math.abs(ad.Y)>8 then Z=true aa.input:
release()end return end if T and math.abs(ad.X)<=math.abs(ad.Y)then Z=true aa.
input:release()return end Y=true R.speed=p aa.setScrollLocked(true)end ab:set(V+
X*ad.X/W)end,function(ad)R.speed=o aa.setScrollLocked(false)if not Y and not Z
and(ad-S).Magnitude<8 then typedEntry()end end,U)end M.InputBegan:Connect(
function(ad)local S=ad.UserInputType if S==Enum.UserInputType.MouseButton2 then
typedEntry()elseif S==Enum.UserInputType.MouseButton1 then beginDrag(aa.input:
pointer(),false)elseif S==Enum.UserInputType.Touch then beginDrag(aa.input:at(ad
),true,ad)end end)local function paintText()local ad=if ab.disabled then'faint'
else'text'K:paint(ac.name,'TextColor3',ad)K:paint(O,'TextColor3',ad)O.Text=
formatted(ab,ab.value)end ac.refresh=function()ac:refreshName()paintText()R:to(
UDim2.new(ratio(),0,0,z))end paintText()return ac end local function pickText(aa
)local ab=aa.spec.display or tostring local ac=aa.value if aa.spec.multi then
local ad={}for K,L in aa.spec.options do if ac[L]then table.insert(ad,ab(L))end
end for K,L in ac do if L and not table.find(aa.spec.options,K)then table.
insert(ad,ab(K))end end if#ad==0 then return'None',false end if#ad<=2 then
return table.concat(ad,', '),true end return string.format('%s, %s +%d',ad[1],ad
[2],#ad-2),true end if ac==nil then return'None',false end return ab(ac),true
end function J.dropdown(aa,ab)local ac=h.new(aa,ab,{quiet=true})local ad=aa.
theme local K=ac.root baseline(ac,aa,0)ad:paint(ac.name,'TextColor3','muted')
local L=e('TextLabel',{Name='Value',AnchorPoint=Vector2.new(1,0),Position=UDim2.
new(1,-(j+t),0,0),TextSize=s,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment
=Enum.TextXAlignment.Right,ZIndex=3,Parent=K})ad:type(L,'text',true)local M=aa.
glyph.chevron(K,'muted')M.AnchorPoint=Vector2.new(1,0.5)M.Position=UDim2.new(1,-
j,0.5,0)M.ZIndex=3 local function fit()local N=K.AbsoluteSize.X/aa.uiScale()-2*j
-t if N<=0 then return end local O=f.width('textMedium',(pickText(ab)),s)+r
local P=math.max(N-O,N*0.45)ac.name.Size=UDim2.new(0,P,1,0)L.Size=UDim2.new(0,N-
P,1,0)end K:GetPropertyChangedSignal('AbsoluteSize'):Connect(fit)K.Activated:
Connect(function()if not ab.disabled then c.open(aa,ab,K)end end)ac.refresh=
function()ac:refreshName()local N,O=pickText(ab)L.Text=N ad:paint(L,'TextColor3'
,if ab.disabled or not O then'faint'else'text')fit()end ac.refresh()task.defer(
fit)return ac end function J.input(aa,ab)local ac=h.new(aa,ab,{quiet=true})local
ad=aa.theme local K=ab.spec ac.name.Size=UDim2.new(0.35,-j,1,0)ad:paint(ac.name,
'TextColor3','muted')local L=e('TextBox',{AnchorPoint=Vector2.new(1,0.5),
Position=UDim2.new(1,-j,0.5,0),Size=UDim2.new(0.65,-j,0,C),TextSize=D,Text=ab.
value or'',PlaceholderText=K.placeholder or'',ClipsDescendants=true,TextEditable
=not ab.disabled,ZIndex=3,Parent=ac.root})ad:type(L,'text',true)ad:paint(L,
'TextColor3','text')ad:paint(L,'PlaceholderColor3','faint')local M=e('Frame',{
AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,v)
,BackgroundTransparency=0,ZIndex=4,Parent=ac.root})ad:paint(M,'BackgroundColor3'
,'lineStrong')L.Focused:Connect(function()ad:paint(M,'BackgroundColor3','accent'
)end)L.FocusLost:Connect(function(N)ad:paint(M,'BackgroundColor3','lineStrong')
if not K.finished then return end if not N or not ab:set(L.Text)then L.Text=ab.
value or''end end)L:GetPropertyChangedSignal('Text'):Connect(function()if ac.
_applying or K.finished then return end if not ab:set(L.Text)and L.Text~=ab.
value then ac._applying=true L.Text=ab.value or''ac._applying=false end end)ac.
root.Activated:Connect(function()if not ab.disabled then L:CaptureFocus()end end
)ac.refresh=function()ac:refreshName()L.TextEditable=not ab.disabled if L.Text~=
(ab.value or'')then ac._applying=true L.Text=ab.value or''ac._applying=false end
end return ac end function J.button(aa,ab)local ac=h.new(aa,ab,{quiet=true})
local ad=e('Frame',{Name='Outline',Position=UDim2.fromOffset(1,1),Size=UDim2.
new(1,-2,1,-2),ZIndex=2,Parent=ac.root})local K=e('UIStroke',{ApplyStrokeMode=
Enum.ApplyStrokeMode.Border,Thickness=1,Parent=ad})aa.theme:paint(K,'Color',
'lineStrong')local L=nil local function draw()ac:refreshName()ac:ink(ac.name,if
ab.disabled then'faint'elseif ab.spec.danger then'danger'else'text')end ac.
refresh=draw draw()ac.root.Activated:Connect(function()if ab.disabled then
return end if ab.spec.confirm and L==nil then ac.name.Text='Again to confirm'ac:
flood(true)ac:ink(ac.name,'onAccent')L=task.delay(2.5,function()L=nil ac:flood(
false)draw()end)return end if L then task.cancel(L)L=nil ac:flood(false)draw()
end ac:flash()ac:ink(ac.name,'onAccent')task.delay(0.28,function()if ac.root.
Parent then draw()end end)ab:fire()end)ac:onCleanup(function()if L then task.
cancel(L)end end)return ac end function J.stat(aa,ab)local ac=h.new(aa,ab,{inert
=true})local ad=aa.theme ac.name.Position=UDim2.fromOffset(j,0)ac.name.Size=
UDim2.new(0.5,-j,1,0)ac.name.TextWrapped=false ad:paint(ac.name,'TextColor3',
'muted')local K=e('TextLabel',{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1
,-j,0,0),Size=UDim2.new(0.5,-j,1,0),TextSize=h.NAME,TextXAlignment=Enum.
TextXAlignment.Right,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=3,Parent=ac.
root})ad:type(K,'text',true)ad:paint(K,'TextColor3','text')ac.refresh=function()
ac.name.Text=ab.label K.Text=tostring(ab.value)end ac.refresh()return ac end
function J.label(aa,ab)local ac=aa.theme if ab.addons then local ad=h.new(aa,ab,
{quiet=true})baseline(ad,aa,0)ac:paint(ad.name,'TextColor3','muted')ad.name.
RichText=true reserveRight(ad,addons(ad,aa,ab,0))ad.refresh=function()ad.name.
Text=ab.label end return ad end local ad=h.new(aa,ab,{height=32,inert=true})
local K=ad.name local L=ab.spec.wrap==true K.RichText=true K.TextSize=E K.
TextWrapped=L ac:type(K,'text')ac:paint(K,'TextColor3','muted')K.TextTruncate=if
L then Enum.TextTruncate.None else Enum.TextTruncate.AtEnd K.TextYAlignment=if L
then Enum.TextYAlignment.Top else Enum.TextYAlignment.Center K.LineHeight=if L
then 1.15 else 1 K.Position=UDim2.fromOffset(0,if L then 6 else 0)K.Size=if L
then UDim2.new(1,0,1,-6)else UDim2.fromScale(1,1)K.Text=ab.label if L then K:
GetPropertyChangedSignal('TextBounds'):Connect(function()local M=math.ceil(K.
TextBounds.Y/aa.uiScale())+12 if ab._measured~=M then ab._measured=M if ab.
_relayout then ab._relayout()end end end)end ad.refresh=function()K.Text=ab.
label end return ad end function J.divider(aa,ab)local ac=h.new(aa,ab,{height=28
,inert=true})local ad=aa.theme ac.name.Position=UDim2.new()ac.name.Size=UDim2.
fromScale(1,1)ac.name.TextSize=E ad:type(ac.name,'text',true)ad:paint(ac.name,
'TextColor3','muted')ac.refresh=function()ac.name.Text=ab.label end return ac
end local function chipTile(aa,ab,ac,ad,K)local L=h.new(aa,ab)aa.theme:paint(L.
name,'TextColor3','muted')ac.root.AnchorPoint=Vector2.new(1,0.5)ac.root.Position
=UDim2.new(1,-K,0.5,0)ac.root.ZIndex=4 ac.root.Parent=L.root reserveRight(L,ad)
table.insert(L.chips,ac)L:onCleanup(ac.destroy)L.refresh=function()L:
refreshName()ac.refresh()end return L end function J.key(aa,ab)local ac=d.build(
aa,ab)local ad=chipTile(aa,ab,ac,96,j)ad.root.Activated:Connect(ac.start)return
ad end function J.color(aa,ab)local ac=b.swatch(aa,ab)local ad=chipTile(aa,ab,ac
,b.DOT_SPACE,j-8)ad.root.Activated:Connect(ac.open)return ad end function i.
build(aa,ab)local ac=J[ab.kind]assert(ac,'sottUI: no view for '..tostring(ab.
kind))local ad=ac(aa,ab)local K=ab._shownOn local L=K and K.sections[1]and K.
sections[1].flat local M=ab.section and(ab.section._root or ab.section)local N=M
and M.masterElement if L and N and N~=ab then local O=ad.refreshName ad.
refreshName=function(P)O(P)P.name.Text=N.label..' '..ab.label end ad:
refreshName()end ab._view=ad return ad end return i end function a.m()local aa=a
.cache.m if not aa then aa={c=__modImpl()}a.cache.m=aa end return aa.c end end
do local function __modImpl()local aa={}aa.__index=aa local ab=function(ab)warn(
ab)end function aa.connect(ac,ad)local b=table.clone(ac._list)table.insert(b,ad)
ac._list=b return function()local c=table.clone(ac._list)local d=table.find(c,ad
)if d then table.remove(c,d)ac._list=c end end end function aa.fire(ac,...)for
ad,b in ac._list do local c,d=xpcall(b,debug.traceback,...)if not c then ab(
'sottUI: listener failed: '..tostring(d))end end end function aa.clear(ac)ac.
_list={}end return{new=function()return((setmetatable({_list={}},aa)))end,
setReporter=function(ac)ab=ac end}end function a.n()local aa=a.cache.n if not aa
then aa={c=__modImpl()}a.cache.n=aa end return aa.c end end do local function 
__modImpl()local aa=a.n()local ab={}local ac={}ac.__index=ac local function 
decimals(ad)local b=string.format('%.10f',ad)local c=string.match(b,'%.(%d-)0*$'
)return if c then#c else 0 end local function roundTo(ad,b)if b<=0 then return
ad end local c=math.round(ad/b)*b return tonumber(string.format('%.'..decimals(b
)..'f',c))or c end ab.roundTo=roundTo local function sameList(ad,b)if#ad~=#b
then return false end for c=1,#ad do if ad[c]~=b[c]then return false end end
return true end local function sameSet(ad,b)for c,d in ad do if d and not b[c]
then return false end end for c,d in b do if d and not ad[c]then return false
end end return true end local ad={toggle=function(ad,b)return b==true end,slider
=function(ad,b)local c=tonumber(b)if c==nil or c~=c then return nil end local d=
ad.spec return math.clamp(roundTo(c,d.step or 1),d.min,d.max)end,dropdown=
function(ad,b)local c=ad.spec if c.multi then local d={}if type(b)=='table'then
for e,f in b do if type(e)=='number'then d[f]=true elseif f then d[e]=true end
end elseif b~=nil and b~=''then d[b]=true end if not c.keep then for e in d do
if not table.find(c.options,e)then d[e]=nil end end end return d end if b==nil
or b==''then return false end if not table.find(c.options,b)and not c.keep then
return nil end return b end,input=function(ad,b)local c=if b==nil then''else
tostring(b)local d=ad.spec if d.maxLength and#c>d.maxLength then c=string.sub(c,
1,d.maxLength)end if d.numeric and c~=''and c~='-'and c~='.'and tonumber(c)==nil
then return nil end if d.verify and not d.verify(c)then return nil end return c
end,key=function(ad,b)if type(b)=='string'then return{key=b,mode=ad.value and ad
.value.mode or'Toggle',modifiers={}}end if type(b)~='table'then return nil end
local c=ad.value or{}return{key=b.key or b[1]or c.key or'None',mode=b.mode or b[
2]or c.mode or'Toggle',modifiers=b.modifiers or b[3]or c.modifiers or{}}end,
color=function(ad,b)if typeof(b)=='Color3'then return{color=b,alpha=ad.value and
ad.value.alpha or 0}end if type(b)=='table'and typeof(b.color)=='Color3'then
return{color=b.color,alpha=math.clamp(tonumber(b.alpha)or 0,0,1)}end return nil
end,label=function(ad,b)return tostring(b)end,stat=function(ad,b)return
tostring(b)end}local function equal(b,c,d)local e=b.kind if e=='dropdown'and b.
spec.multi then return sameSet(c,d)end if e=='key'then return c.key==d.key and c
.mode==d.mode and sameList(c.modifiers,d.modifiers)end if e=='color'then return
c.color==d.color and c.alpha==d.alpha end return c==d end local function unwrap(
b,c)if b.kind=='dropdown'and not b.spec.multi and c==false then return nil end
return c end function ab.new(b,c,d,e,f)local g=setmetatable({kind=b,id=c,label=d
,spec=e,tip=e.tip,disabled=e.disabled==true,disabledTip=e.disabledTip,visible=e.
visible~=false,saved=e.saved~=false,changed=aa.new()},ac)local h=ad[b]local i=f
if h then i=h(g,f)if i==nil and b=='slider'then i=e.min end if i==nil and b==
'dropdown'then i=false end end g.value=unwrap(g,i)g.default=g.value return g end
function ac.set(b,c)local d=ad[b.kind]local e=c if d then e=d(b,c)if e==nil then
return false end e=unwrap(b,e)end local f=b.value if f~=nil and e~=nil and
equal(b,f,e)then return false end if f==nil and e==nil then return false end b.
value=e b:notify()return true end function ac.reset(b)local c=b.default if b.
kind=='dropdown'and b.spec.multi then c=table.clone(c)end b:set(c)end local 
function redraw(b)local c=b._view if c then c.refresh()end local d=b.host if d
and d._view then d._view.refresh()end end function ac.notify(b)redraw(b)b.
changed:fire(b.value)end function ac.fire(b)b.changed:fire(b.value)end function
ac.on(b,c)return b.changed:connect(c)end function ac.setLabel(b,c)if b.label==c
then return end b.label=c if b.kind=='label'then b.value=c local d=b._relayout
if d then d()end end if b._onLabel then b._onLabel()end redraw(b)end function ac
.setTip(b,c)b.tip=c end function ac.setDisabled(b,c,d)b.disabled=c==true b.
disabledTip=d or b.disabledTip redraw(b)end function ac.setVisible(b,c)if b.
visible==c then return end b.visible=c local d=b._relayout if d then d()end end
function ac.setOptions(b,c)local d=b.spec d.options=table.clone(c)if d.multi
then if d.keep then for e,f in b.value do if f and not table.find(d.options,e)
then table.insert(d.options,e)end end else local e=false for f in b.value do if
not table.find(d.options,f)then b.value[f]=nil e=true end end if e then b:
notify()return end end elseif b.value~=nil and not table.find(d.options,b.value)
then if d.keep then table.insert(d.options,b.value)else b.value=nil b:notify()
return end end redraw(b)end function ac.isModified(b)if b.kind=='button'or b.
kind=='label'or b.kind=='divider'or b.kind=='stat'then return false end local c,
d=b.value,b.default if c==nil or d==nil then return c~=d end return not equal(b,
c,d)end function ac.attach(b,c)local d=b.addons if d==nil then d={}b.addons=d
end table.insert(d,c)c.host=b redraw(b)end function ac.shown(b)if not b.visible
or(b.kind=='label'and b.label=='')then return false end local c=b.guard return c
==nil or c()end return ab end function a.o()local aa=a.cache.o if not aa then aa
={c=__modImpl()}a.cache.o=aa end return aa.c end end do local function __modImpl
()local aa=a.o()local ab={}local ac={}ac.__index=ac local function add(ad,b,c,d,
e,f)local g=aa.new(b,c or(b..'#'..tostring(ad._page:nextId())),d,e,f)g.section=
ad g.guard=ad._guard ad._page:_register(g,c~=nil)table.insert(ad.rows,g)local h=
ad._root or ad if h.masterElement then h.hasOptions=true end ad._page:
_invalidate()return g end function ac.toggle(ad,b,c)local d=add(ad,'toggle',b,c.
label or b,c,c.default==true)if c.onChanged then d:on(c.onChanged)end return d
end function ac.master(ad,b,c)c.primary=true local d=ad:toggle(b,c)ad.
masterElement=d local e=ad._page d:on(function()e:_invalidate()end)local f=ad.
_guard ad._guard=function()if f and not f()then return false end return ad.
peeking==true end return d end function ac.togglePeek(ad)local b=not ad.peeking
for c,d in ad._page.sections do d.peeking=false end ad.peeking=b ad._page:
_invalidate()end function ac.slider(ad,b,c)c.min=c.min or 0 c.max=c.max or 100 c
.step=c.step or 1 if c.decimals==nil then local d=string.format('%.10f',c.step)
local e=string.match(d,'%.(%d-)0*$')c.decimals=if e then#e else 0 end local d=
add(ad,'slider',b,c.label or b,c,c.default or c.min)if c.onChanged then d:on(c.
onChanged)end return d end function ac.dropdown(ad,b,c)c.options=c.options or{}
local d=c.default if d==nil and c.multi then d={}end local e=add(ad,'dropdown',b
,c.label or b,c,d)if c.onChanged then e:on(c.onChanged)end return e end function
ac.input(ad,b,c)local d=add(ad,'input',b,c.label or'',c,c.default or'')if c.
onChanged then d:on(c.onChanged)end return d end function ac.key(ad,b,c)local d=
add(ad,'key',b,c.label or b,c,{key=c.default or'None',mode=c.mode or'Toggle',
modifiers=c.modifiers or{}})ad._page.window.keys:register(d)return d end
function ac.color(ad,b,c)local d=add(ad,'color',b,c.label or b,c,{color=c.
default or Color3.new(1,1,1),alpha=c.alphaValue or 0})if c.onChanged then d:on(c
.onChanged)end return d end function ac.button(ad,b,c)local d=if type(c)==
'function'then{onPressed=c}else c d.saved=false local e=add(ad,'button',nil,b,d,
nil)if d.onPressed then e:on(d.onPressed)end return e end function ac.label(ad,b
,c)local d=c or{}d.saved=false return add(ad,'label',nil,b,d,b)end function ac.
stat(ad,b,c)return add(ad,'stat',nil,b,{saved=false},tostring(c))end function ac
.divider(ad,b)return add(ad,'divider',nil,b or'',{saved=false},nil)end function
ac.addKey(ad,b,c,d)local e=aa.new('key',c,d.label or b.label,d,{key=d.default or
'None',mode=d.mode or'Toggle',modifiers=d.modifiers or{}})e.section=ad local f=e
f.toggled=d.toggled==true if b.kind=='toggle'and d.onPress==nil then f.toggled=b
.value d.onPress=function()b:set(not b.value)f.toggled=b.value end end ad._page:
_register(e,true)ad._page.window.keys:register(e)b:attach(e)return e end
function ac.addColor(ad,b,c,d)local e=aa.new('color',c,d.label or b.label,d,{
color=d.default or Color3.new(1,1,1),alpha=d.alphaValue or 0})e.section=ad ad.
_page:_register(e,true)b:attach(e)if d.onChanged then e:on(d.onChanged)end
return e end function ac.when(ad,b,c)local d=ad._guard local e=b if d then e=
function()return d()and b()end end local f=setmetatable({rows=ad.rows,title=ad.
title,_page=ad._page,_guard=e,_root=ad._root or ad},ac)for g,h in(c or{})do h:
on(function()ad._page:_invalidate()end)end return f end function ab.new(ad,b)
return setmetatable({title=b,rows={},_page=ad,_guard=nil,_root=nil},ac)end
return ab end function a.p()local aa=a.cache.p if not aa then aa={c=__modImpl()}
a.cache.p=aa end return aa.c end end do local function __modImpl()local aa=a.m()
local ab=a.f()local ac=a.j()local ad=a.b()local b=a.p()local c={}local d=26
local e=36 function c.open(f,g,h)if f._dialogClose then f._dialogClose()end
local i=f.ctx local j=i.theme local k=f._layer local l=g.width or 460 local m=g.
maxHeight or 340 local n=60 local o=ab('TextButton',{Size=UDim2.fromScale(1,1),
BackgroundTransparency=1,BackgroundColor3=Color3.new(0,0,0),ZIndex=50,Parent=k})
local p=ad.prop(o,'BackgroundTransparency',22)p:to(0.4)local q=ab('Frame',{
AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.
fromOffset(l,0),BackgroundTransparency=0,ClipsDescendants=true,Active=true,
ZIndex=51,Parent=k})j:paint(q,'BackgroundColor3','base')ab('UIScale',{Scale=i.
uiScale(),Parent=q})local r=ab('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.
Border,Parent=q})j:paint(r,'Color','lineStrong')local s=ab('TextLabel',{Position
=UDim2.fromOffset(20,16),Size=UDim2.new(1,-40,0,40),TextSize=36,Text=g.title or
'',ZIndex=52,Parent=q})j:type(s,'display')j:paint(s,'TextColor3','text')local t=
60 local u=g.text if u and u~=''then local v=ab('TextLabel',{Position=UDim2.
fromOffset(20,t),Size=UDim2.new(1,-40,0,22),AutomaticSize=Enum.AutomaticSize.Y,
TextSize=16,TextWrapped=true,Text=u,ZIndex=52,Parent=q})j:type(v,'text')j:paint(
v,'TextColor3','muted')t+=22+math.floor(#u/52)*22+12 end local v=ab(
'ScrollingFrame',{Position=UDim2.fromOffset(20,t),Size=UDim2.new(1,-40,0,0),
ScrollBarThickness=3,ZIndex=52,Parent=q})j:paint(v,'ScrollBarImageColor3',
'lineStrong')local w=false local x={window=f,name='Dialog',nextId=function()f.
_dialogIds+=1 return f._dialogIds end,_register=function(x,y,z)y._pageName=
'Dialog'if z then f.elements[y.id]=y end end,_invalidate=function()end}local y=b
.new(x,'')local z,A=xpcall(h,debug.traceback,y)if not z then warn(
'sottUI: dialog build failed: '..tostring(A))end local B={}local C=0 for D,E in
y.rows do if E:shown()then local F=aa.build(i,E)local G=n if E.kind=='divider'
then G=28 elseif E.kind=='label'then local H=math.ceil(ac.width('text',E.label,
16)/(l-48))G=if E.spec.wrap then H*21+12 else 32 end F.root.Position=UDim2.
fromOffset(0,C)F.root.Size=UDim2.new(1,0,0,G)F.root.Parent=v C+=G+3 table.
insert(B,F)end end v.CanvasSize=UDim2.fromOffset(0,C)local D=math.min(C,m)v.Size
=UDim2.new(1,-40,0,D)local E=t+D+12 local F=ab('TextButton',{Position=UDim2.
fromOffset(20,E),Size=UDim2.new(1,-40,0,54),BackgroundTransparency=0,TextSize=28
,Text=g.done or'Done',ZIndex=52,Parent=q})j:type(F,'display')j:paint(F,
'BackgroundColor3','text')j:paint(F,'TextColor3','base')local G=E+54+20 local H=
ad.prop(q,'Size',d)H:to(UDim2.fromOffset(l,G))local function close()if w then
return end w=true f._dialogClose=nil o.Active=false for I,J in y.rows do if f.
elements[J.id]==J then f.elements[J.id]=nil end for K,L in J.addons or{}do f.
keys:unregister(L)if f.elements[L.id]==L then f.elements[L.id]=nil end end end
if g.onClose then task.spawn(g.onClose)end p:to(1,function()p:destroy()o:
Destroy()end)H.speed=e H:to(UDim2.fromOffset(l,0),function()for I,J in B do J.
destroy()end H:destroy()q:Destroy()end)end f._dialogClose=close o.
MouseButton1Down:Connect(close)F.Activated:Connect(close)end return c end
function a.q()local aa=a.cache.q if not aa then aa={c=__modImpl()}a.cache.q=aa
end return aa.c end end do local function __modImpl()local aa=a.a()local ab={}
local ac={text={name='SottUIText',faces={{name='Regular',weight=400,file=
'text-400.ttf'},{name='Medium',weight=500,file='text-500.ttf'}}},display={name=
'SottUIDisplay',faces={{name='ExtraBold',weight=800,file='display-800.ttf'}}}}
local ad=10000 local function family(b,c,d,e,f)local g={}for h,i in d.faces do
local j=c..'/'..i.file local k=b.read(j)if k==nil or#k<ad then local l=aa.fetch(
e..i.file)if l==nil or#l<ad then return nil end if not b.write(j,l)then return
nil end end local l=b.asset(j)if l==nil then return nil end table.insert(g,{name
=i.name,weight=i.weight,style='normal',assetId=l})end local h=c..'/'..d.name..
'.json'if not b.write(h,f({name=d.name,faces=g}))then return nil end return b.
asset(h)end function ab.load(b,c,d)local e=aa.files()if e==nil or aa.global(
'getcustomasset')==nil then return{}end e.folder(b)local f={}local g,h=pcall(
function()f.text=family(e,b,ac.text,c,d)f.display=family(e,b,ac.display,c,d)end)
if not g then warn('sottUI: fonts unavailable: '..tostring(h))end return f end
function ab.image(b,c,d)local e=aa.files()if e==nil or aa.global(
'getcustomasset')==nil then return nil end e.folder(b)local f=b..'/'..d if e.
read(f)==nil then local g=aa.fetch(c..d)if g==nil or not e.write(f,g)then return
nil end end return e.asset(f)end return ab end function a.r()local aa=a.cache.r
if not aa then aa={c=__modImpl()}a.cache.r=aa end return aa.c end end do local 
function __modImpl()local aa=a.f()local ab={}local function stroke(ac,ad,b,c,d,e
,f)local g=aa('Frame',{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.
fromOffset(e,f),Size=UDim2.fromOffset(c,2),Rotation=d,BackgroundTransparency=0,
Parent=ac})ad:paint(g,'BackgroundColor3',b)return g end function ab.new(ac)local
ad={}function ad.chevron(b,c,d)local e=aa('Frame',{Size=UDim2.fromOffset(12,12),
Parent=b})if d=='right'then stroke(e,ac,c,7,45,6,3.6)stroke(e,ac,c,7,-45,6,8.4)
elseif d=='up'then stroke(e,ac,c,7,-45,3.6,6)stroke(e,ac,c,7,45,8.4,6)else
stroke(e,ac,c,7,45,3.6,6)stroke(e,ac,c,7,-45,8.4,6)end return e end function ad.
cross(b,c)local d=aa('Frame',{Size=UDim2.fromOffset(12,12),Parent=b})stroke(d,ac
,c,13,45,6,6)stroke(d,ac,c,13,-45,6,6)return d end function ad.dash(b,c)local d=
aa('Frame',{Size=UDim2.fromOffset(12,12),Parent=b})stroke(d,ac,c,12,0,6,6)return
d end return ad end return ab end function a.s()local aa=a.cache.s if not aa
then aa={c=__modImpl()}a.cache.s=aa end return aa.c end end do local function 
__modImpl()local aa={}aa.__index=aa local function dispose(ab)local ac=typeof(ab
)if ac=='RBXScriptConnection'then ab:Disconnect()elseif ac=='Instance'then ab:
Destroy()elseif ac=='function'then ab()elseif ac=='thread'then task.cancel(ab)
elseif ac=='table'then local ad=ab.destroy or ab.Destroy or ab.Disconnect if ad
then ad(ab)end end end function aa.add(ab,ac)table.insert(ab._items,ac)return ac
end function aa.clean(ab)local ac=ab._items ab._items={}for ad=#ac,1,-1 do local
b,c=pcall(dispose,ac[ad])if not b then warn('sottUI: cleanup failed: '..
tostring(c))end end end aa.destroy=aa.clean return{new=function()return((
setmetatable({_items={}},aa)))end}end function a.t()local aa=a.cache.t if not aa
then aa={c=__modImpl()}a.cache.t=aa end return aa.c end end do local function 
__modImpl()local aa=a.a()local ab=a.t()local ac=a.n()local ad={}local b={}b.
__index=b function b.pointer(c)local d=c._guiService:GetGuiInset()return c._uis:
GetMouseLocation()-d end function b.at(c,d)local e=d.Position return Vector2.
new(e.X,e.Y)end function b.capture(c,d,e,f)c:release()c._move=d c._finish=e c.
_finger=f end function b.release(c)local d=c._finish c._move=nil c._finish=nil c
._finger=nil if d then task.spawn(d,c:pointer())end end function b.typing(c)
return c._uis:GetFocusedTextBox()~=nil end function b.destroy(c)c._move=nil c.
_finish=nil c._maid:clean()c.keyDown:clear()c.keyUp:clear()c.wheel:clear()c.
moved:clear()c.pointerUp:clear()end function ad.new()local c=aa.service(
'UserInputService')local d=ab.new()local e=setmetatable({_uis=c,_guiService=aa.
service('GuiService'),_maid=d,_move=nil,_finish=nil,keyDown=ac.new(),keyUp=ac.
new(),wheel=ac.new(),moved=ac.new(),pointerUp=ac.new()},b)d:add(c.InputChanged:
Connect(function(f)local g=f.UserInputType if g==Enum.UserInputType.
MouseMovement then local h=e:pointer()if e._move then e._move(h)end e.moved:
fire(h)elseif g==Enum.UserInputType.Touch then if e._move and(e._finger==nil or
e._finger==f)then e._move(e:at(f))end elseif g==Enum.UserInputType.MouseWheel
then e.wheel:fire(f.Position.Z)end end))d:add(c.InputEnded:Connect(function(f,g)
local h=f.UserInputType if h==Enum.UserInputType.MouseButton1 or h==Enum.
UserInputType.Touch then if e._move and(h~=Enum.UserInputType.Touch or e._finger
==nil or e._finger==f)then local i=if h==Enum.UserInputType.Touch then e:at(f)
else e:pointer()local j=e._finish e._move=nil e._finish=nil e._finger=nil if j
then j(i)end end e.pointerUp:fire()end e.keyUp:fire(f,g)end))d:add(c.InputBegan:
Connect(function(f,g)e.keyDown:fire(f,g)end))return e end return ad end function
a.u()local aa=a.cache.u if not aa then aa={c=__modImpl()}a.cache.u=aa end return
aa.c end end do local function __modImpl()local aa={}local ab={[Enum.
UserInputType.MouseButton1]='MB1',[Enum.UserInputType.MouseButton2]='MB2',[Enum.
UserInputType.MouseButton3]='MB3'}local ac={MB1=Enum.UserInputType.MouseButton1,
MB2=Enum.UserInputType.MouseButton2,MB3=Enum.UserInputType.MouseButton3}local ad
={[Enum.KeyCode.LeftAlt]='LAlt',[Enum.KeyCode.RightAlt]='RAlt',[Enum.KeyCode.
LeftControl]='LCtrl',[Enum.KeyCode.RightControl]='RCtrl',[Enum.KeyCode.LeftShift
]='LShift',[Enum.KeyCode.RightShift]='RShift'}local function nameOf(b)local c=ab
[b.UserInputType]if c then return c end if b.UserInputType==Enum.UserInputType.
Keyboard and b.KeyCode.Name~='Unknown'then return b.KeyCode.Name end return nil
end function aa.new(b,c,d)local e=c.service('UserInputService')local f={}local g
={}local h=nil local i=false local j=nil local k=nil local function 
modifiersHeld(l)for m,n in(l or{})do local o=false for p,q in ad do if q==n and
e:IsKeyDown(p)then o=true end end if not o then return false end end return true
end local function heldModifiers(l)local m={}for n,o in ad do if n.Name~=l and e
:IsKeyDown(n)then table.insert(m,o)end end table.sort(m)return m end function f.
register(l,m)table.insert(g,m)end function f.unregister(l,m)local n=table.find(g
,m)if n then table.remove(g,n)end end function f.listen(l,m,n)f.cancel()h=m i=n
==true end function f.swallowed(l,m)return k==m end function f.cancel()local l=h
h=nil j=nil if l then l(nil)end end function f.state(l,m)local n=m.value if n==
nil then return false end if n.mode=='Always'then return true end if n.mode==
'Toggle'then return m.toggled==true end if n.key=='None'or h~=nil or b:typing()
then return false end local o=ac[n.key]if o then return not d()and e:
IsMouseButtonPressed(o)and modifiersHeld(n.modifiers)end local p,q=pcall(
function()return e:IsKeyDown((Enum.KeyCode)[n.key])end)return p and q and
modifiersHeld(n.modifiers)end b.keyDown:connect(function(l)local m=nameOf(l)if m
==nil then return end if h then local n=ab[l.UserInputType]~=nil if n and(i or m
=='MB1')then return end if ad[l.KeyCode]and not n then j=m return end local o=h
h=nil j=nil k=m if m=='Escape'then(o)('None',{})else(o)(m,heldModifiers(m))end
return end if k==m then return end if b:typing()then return end for n,o in g do
local p=o.value if p.key==m and not o.disabled and modifiersHeld(p.modifiers)
then if p.mode=='Toggle'then o.toggled=not o.toggled end local q=o.spec.onPress
if q then q(o,o.toggled)end end end end)b.keyUp:connect(function(l)local m=
nameOf(l)if m==nil then return end if j==m and h then local n=h h=nil j=nil n(m,
{})return end if k==m then k=nil end for n,o in g do local p=o.value if p.key==m
and p.mode=='Hold'and o.spec.onRelease then o.spec.onRelease(o)end end end)
return f end return aa end function a.v()local aa=a.cache.v if not aa then aa={c
=__modImpl()}a.cache.v=aa end return aa.c end end do local function __modImpl()
local aa=a.f()local ab=a.b()local ac={}local ad=320 local b=8 local c=20 local d
=26 local e=5 function ac.new(f,g)local h=f.theme local i={}local j={}local 
function layout()local k=g.AbsoluteSize local l=k.Y-c for m=#i,1,-1 do local n=i
[m]l-=n.height n.pos:to(UDim2.fromOffset(k.X-ad-c,l))l-=b end end local function 
dismiss(k)if k.gone then return end k.gone=true if k.timer then task.cancel(k.
timer)end local l=table.find(i,k)if l then table.remove(i,l)end local m=g.
AbsoluteSize k.pos:to(UDim2.fromOffset(m.X+8,k.frame.Position.Y.Offset),function
()k.pos:destroy()k.frame:Destroy()end)layout()end function j.show(k,l)while#i>=e
do dismiss(i[1])end local m=g.AbsoluteSize local n=aa('TextButton',{Name=
'Notice',Position=UDim2.fromOffset(m.X+8,m.Y-c-60),Size=UDim2.fromOffset(ad,60),
BackgroundTransparency=0,ZIndex=80,Parent=g})h:paint(n,'BackgroundColor3',
'surface')local o=aa('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
Parent=n})h:paint(o,'Color','lineStrong')local p=aa('Frame',{Size=UDim2.new(0,4,
1,0),BackgroundTransparency=0,ZIndex=81,Parent=n})h:paint(p,'BackgroundColor3',
'accent')local q=10 if l.title and l.title~=''then local r=aa('TextLabel',{
Position=UDim2.fromOffset(18,q),Size=UDim2.new(1,-32,0,24),TextSize=22,
TextTruncate=Enum.TextTruncate.AtEnd,Text=l.title,ZIndex=81,Parent=n})h:type(r,
'display')h:paint(r,'TextColor3','text')q+=26 end local r=nil if l.text and l.
text~=''then r=aa('TextLabel',{Position=UDim2.fromOffset(18,q),Size=UDim2.new(1,
-32,0,20),TextSize=16,TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top,
RichText=true,Text=l.text,ZIndex=81,Parent=n})h:type(r,'text')h:paint(r,
'TextColor3','muted')end local s={frame=n,height=q+28,pos=ab.prop(n,'Position',d
),gone=false}n.Size=UDim2.fromOffset(ad,s.height)if r then task.defer(function()
if s.gone then return end local t=math.ceil(r.TextBounds.Y)if t>20 then r.Size=
UDim2.new(1,-32,0,t)s.height=q+t+10 n.Size=UDim2.fromOffset(ad,s.height)layout()
end end)end s.pos:snap(UDim2.fromOffset(m.X+8,m.Y-c-s.height))table.insert(i,s)n
.Activated:Connect(function()dismiss(s)end)s.timer=task.delay(l.seconds or 5,
function()s.timer=nil dismiss(s)end)layout()end function j.destroy(k)for l,m in
table.clone(i)do if m.timer then task.cancel(m.timer)end m.pos:destroy()m.frame:
Destroy()end table.clear(i)end return j end return ac end function a.w()local aa
=a.cache.w if not aa then aa={c=__modImpl()}a.cache.w=aa end return aa.c end end
do local function __modImpl()local aa=a.f()local ab=a.b()local ac={}local ad=34
local b=48 local c=0.55 local d=340 local e=40 local f=8 function ac.popover(g,h
)local i=g.theme local j={}local k=nil local function close()local l=k if l==nil
then return end k=nil l.catcher:Destroy()l.open=false l.size.speed=b l.size:to(
UDim2.fromOffset(l.width,0),function()l.size:destroy()l.frame:Destroy()end)if l.
disconnectEl then l.disconnectEl()end end function j.open(l,m,n,o,p)close()local
q=h.AbsoluteSize local r,s=m.AbsolutePosition-h.AbsolutePosition,m.AbsoluteSize
n=math.min(n,q.X-2*f)o=math.min(o,q.Y-2*f)local t=if n>s.X then r.X+s.X-n else r
.X local u=math.clamp(t,f,q.X-n-f)local v=r.Y+s.Y+2 local w=math.max(g.
popoverTop(),f)local x=v+o+f>q.Y and r.Y-o-2>w local y=if x then r.Y-o-2 else
math.max(math.min(v,q.Y-o-f),w)local z=aa('TextButton',{Name='Catcher',Size=
UDim2.fromScale(1,1),ZIndex=60,Parent=h})local A=aa('Frame',{Name='Popover',
Position=UDim2.fromOffset(u,y),Size=UDim2.fromOffset(n,0),BackgroundTransparency
=0,ClipsDescendants=true,ZIndex=61,Active=true,Parent=h})i:paint(A,
'BackgroundColor3','raised')local B=aa('UIStroke',{ApplyStrokeMode=Enum.
ApplyStrokeMode.Border,Parent=A})i:paint(B,'Color','lineStrong')local C=aa(
'Frame',{Size=UDim2.fromScale(1,1),Parent=A})local D={frame=A,catcher=z,width=n,
open=true,size=ab.prop(A,'Size',ad)}k=D z.MouseButton1Down:Connect(close)z.
MouseButton2Down:Connect(close)local E={close=close,resize=function(E)if D.open
then D.size:to(UDim2.fromOffset(n,E))end end,onKey=function(E)D.onKey=E end,
onRefresh=function(E)D.onRefresh=E end}p(C,E)D.size:to(UDim2.fromOffset(n,o))end
function j.isOpen(l)return k~=nil end function j.close(l)close()end function j.
key(l,m)if k==nil then return false end if m=='Escape'then close()return true
end if k.onKey then k.onKey(m)return true end return false end return j end
function ac.tooltip(g,h)local i=g.theme local j=aa('Frame',{Name='Tooltip',
AutomaticSize=Enum.AutomaticSize.XY,BackgroundTransparency=0,Visible=false,
ZIndex=70,Parent=h})i:paint(j,'BackgroundColor3','raised')local k=aa('UIStroke',
{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=j})i:paint(k,'Color',
'lineStrong')aa('UIPadding',{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,
10),PaddingTop=UDim.new(0,7),PaddingBottom=UDim.new(0,7),Parent=j})local l=aa(
'TextLabel',{AutomaticSize=Enum.AutomaticSize.XY,TextSize=16,TextWrapped=true,
ZIndex=71,Parent=j})aa('UISizeConstraint',{MaxSize=Vector2.new(d,400),Parent=l})
i:type(l,'text')i:paint(l,'TextColor3','text')local m={}local n=nil function m.
hide(o)if n then task.cancel(n)n=nil end j.Visible=false end local o=ab.prop(j,
'Position',e)function m.showAt(p,q,r)p:hide()l.Text=r j.Visible=true task.defer(
function()if not j.Visible then return end local s=h.AbsoluteSize local t=j.
AbsoluteSize local u=q.AbsolutePosition-h.AbsolutePosition local v=math.clamp(u.
X,f,s.X-t.X-f)local w=u.Y+q.AbsoluteSize.Y+3 local x=w+t.Y+f>s.Y local y=if x
then u.Y-t.Y-3 else w o:snap(UDim2.fromOffset(v,y+(if x then 8 else-8)))o:to(
UDim2.fromOffset(v,y))end)end function m.schedule(p,q,r)p:hide()n=task.delay(c,
function()n=nil if q.Parent~=nil then p:showAt(q,r)end end)end return m end
function ac.hover(g)local h={}local i=nil local function clear()local j=i if j
then i=nil j:onHover(false)g.tooltip:hide()end end function h.current(j)return i
end function h.enter(j,k)if i==k then return end clear()i=k k:onHover(true)local
l=k.el local m=if l.disabled and l.disabledTip then l.disabledTip else l.tip if
m and m~=''then g.tooltip:schedule(k.root,m)end end function h.leave(j,k)if i==k
then clear()end end h.clear=clear function h.verify(j,k)local l=i if l==nil then
return end local m=l.root local n,o=m.AbsolutePosition,m.AbsoluteSize local p=k.
X>=n.X and k.Y>=n.Y and k.X<=n.X+o.X and k.Y<=n.Y+o.Y if not p or not m.Visible
or m.Parent==nil or g.popover:isOpen()then clear()end end return h end return ac
end function a.x()local aa=a.cache.x if not aa then aa={c=__modImpl()}a.cache.x=
aa end return aa.c end end do local function __modImpl()local aa=a.m()local ab=a
.f()local ac=a.j()local ad=a.b()local b=a.p()local c=a.l()local d={}local e=12
local f=600 local g=8 local h=2 local i=20 local j=14 local k=40 local l=16
local m=60 local n=14 local o=88 local p=10 local q=40 local r=22 local s=148
local t=0 local u=36 local v=360 local w=110 local x=24 local y=28 local z={
toggle=4,button=4,key=4,color=4,slider=4,dropdown=4,stat=3,input=8}local 
function needs(A)local B=A.kind if B=='stat'or B=='input'then return 0 end local
C=26 if B=='slider'then C=aa.readoutWidth(A)+12 elseif B=='dropdown'then C=96
end for D,E in A.addons or{}do if not E.spec.chipless then C+=if E.kind=='key'
then 58 else 28 end end return ac.width('textMedium',A.label,c.NAME)*1.05+2*c.
PAD+C end local function spanOf(A)if A.kind=='label'and A.addons then return 4
end return z[A.kind]end local A={}A.__index=A local function textHeight(B,C)if B
.kind=='divider'then return if B.label==''then 8 else 28 end if not B.spec.wrap
then return 32 end if B._measured then return B._measured end local D=math.max(
math.floor(C/7.6),10)local E=string.gsub(B.label,'<[^>]+>','')return math.ceil(#
E/D)*21+12 end function A.nextId(B)B._ids+=1 return B._ids end function A.
_register(B,C,D)C._relayout=function()B:_invalidate()end B.window:
_registerElement(C,B,D)end function A._invalidate(B)if B._dirty then return end
B._dirty=true task.defer(function()B._dirty=false if not B.destroyed then B:
layout(not B._quiet)B._quiet=false end end)end function A.section(B,C)local D=b.
new(B,C)table.insert(B.sections,D)B:_invalidate()return D end function A.tabset(
B)local C=b.new(B,'')C.tabNames={}C.activeTab=1 table.insert(B.sections,C)local
D={}function D.tab(E,F)table.insert(C.tabNames,F)local G=#C.tabNames local H=C:
when(function()return C.activeTab==G end)H.title=F local I=B._headers[C]if I
then I:Destroy()B._headers[C]=nil end B:_invalidate()return H end return D end
function A.tabs(B,C)local D=B:tabset()local E={}for F,G in C do table.insert(E,D
:tab(G))end return E end function A.hero(B,C)B._hero=C B:_invalidate()local D=B.
_heroView return{set=function(E,F,G)C.title=F or C.title C.text=G or C.text
local H=B._heroView or D if H then H.refresh()end end}end local function 
buildHero(B)local C=B.window.ctx local D=C.theme local E=B._hero local F=ab(
'Frame',{Name='Hero',Parent=B.canvas})local G=ab('Frame',{Size=UDim2.fromOffset(
s-16,s-16),BackgroundTransparency=0,ClipsDescendants=true,Parent=F})D:paint(G,
'BackgroundColor3','accent')if E.userId then ab('ImageLabel',{Size=UDim2.
fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,Image=string.format(
'rbxthumb://type=AvatarBust&id=%d&w=420&h=420',E.userId),Parent=G})end local H=
ab('TextLabel',{Position=UDim2.fromOffset(s+2,16),Size=UDim2.new(1,-(s+2),0,68),
TextSize=64,TextTruncate=Enum.TextTruncate.AtEnd,Parent=F})D:type(H,'display')D:
paint(H,'TextColor3','text')local I=ab('TextLabel',{Position=UDim2.fromOffset(s+
2,88),Size=UDim2.new(1,-(s+2),0,44),TextSize=17,TextWrapped=true,TextYAlignment=
Enum.TextYAlignment.Top,Parent=F})D:type(I,'text')D:paint(I,'TextColor3','muted'
)local J={root=F,refresh=function()H.Text=E.title I.Text=E.text or''end}J.
refresh()return J end local function buildHeader(B,C)local D=B.window.ctx local
E=D.theme local F=ab('Frame',{Name='Header',Parent=B.canvas})if C.tabNames then
local G={}local H=0 for I,J in C.tabNames do local K=math.ceil(ac.width(
'textMedium',J,18))+20 local L=ab('TextButton',{Position=UDim2.fromOffset(H,0),
Size=UDim2.new(0,K,1,-8),TextSize=18,Text=J,TextXAlignment=Enum.TextXAlignment.
Left,Parent=F})E:type(L,'text',true)G[I]=L L.Activated:Connect(function()C.
activeTab=I for M,N in G do E:paint(N,'TextColor3',if M==C.activeTab then'text'
else'faint')end B:_invalidate()end)E:paint(L,'TextColor3',if I==C.activeTab then
'text'else'faint')H+=K end else local G=ab('TextLabel',{Size=UDim2.new(1,0,1,-6)
,TextSize=26,Text=C.title,Parent=F})E:type(G,'display')E:paint(G,'TextColor3',
'text')end return F end function A.layout(B,C)local D=B.frame if D==nil then
return end B._live=C==true and B._settled==true and B.active local E=B.window.
ctx.uiScale()local F=D.AbsoluteSize.X/E if F<1 then return end local G=F-2*i
local H=G<f local I=(G-(e-1)*g)/e local J=j local K={}if B._hero then table.
insert(K,{hero=true,x=i,y=J,width=G,height=s})J+=s end local function placeRows(
L,M)do local N=false local O,P={},0 local function flush()if#O==0 then return
end local Q,R=i,0 for S,T in O do local U=if H and#O==1 then e else T.span local
V=U*I+(U-1)*g local W=T.height R=math.max(R,W)table.insert(K,{el=T.el,x=Q,y=J,
width=V,height=W})Q+=V+g end J+=R+g O,P={},0 end for Q,R in M do local S=spanOf(
R)if S==nil then flush()if R.kind=='divider'and R.label==''and N then continue
end local T=textHeight(R,G)table.insert(K,{el=R,x=i,y=J,width=G,height=T})J+=T+h
elseif R.spec.primary then flush()local T=o table.insert(K,{el=R,x=i,y=J,width=G
,height=T})J+=T+g+t N=true else local T=if L.flat then e elseif H then(if S<=e/3
then e/2 else e)else S while T<e and needs(R)>T*I+(T-1)*g do T+=if H then e-T
else 4 end if P+T>e then flush()end N=false table.insert(O,{el=R,span=T,height=
if R.kind=='stat'then u else c.HEIGHT})P+=T end end flush()end end local L={}
local function flushBoard()if#L==0 then return end local M=(G-g)/2 local N=1
while N<=#L do local O,P=L[N],L[N+1]table.insert(K,{el=O.masterElement,x=i,y=J,
width=if P then M else G,height=o})if P then table.insert(K,{el=P.masterElement,
x=i+M+g,y=J,width=M,height=o})end J+=o+g for Q,R in{O,P}do if R and R.peeking
then local S={}for T,U in R.rows do if U~=R.masterElement and U:shown()then
table.insert(S,U)end end placeRows(R,S)J+=p end end N+=2 end table.clear(L)J+=r-
g end for M,N in B.sections do if N.masterElement and not N.flat then if N.
masterElement:shown()then table.insert(L,N)end else flushBoard()local O={}for P,
Q in N.rows do if N.flat or Q:shown()then table.insert(O,Q)end end if#O>0 or N.
tabNames then if N.title~=''or N.tabNames then table.insert(K,{section=N,x=i,y=J
,width=G,height=q})J+=q end placeRows(N,O)J+=r end end end flushBoard()local M=B
.sections[1]and B.sections[1].flat local N=J-r+(if M then l else k)if B.
_emptyVisible then N=math.max(N,m)end D.CanvasSize=UDim2.fromOffset(0,N)B.
_contentHeight=N local O=math.max(N-D.AbsoluteSize.Y/B.window.ctx.uiScale(),0)if
B._scrollTarget and B._scrollTarget>O then B._scrollTarget=O end B._placements=K
if B.active then B.window:_contentChanged(N,C)end B:_applyPlacements()B:
_materialize(true)B:_refreshThumb()B._live=false B._settled=B._settled or B.
active end local function growTo(B,C,D,E)if B._grow==nil then B._grow=B:own(ad.
prop(B.root,'Size',y))end B._grow:to(UDim2.fromOffset(C,D),E)end local function 
setSize(B,C,D)local E=UDim2.fromOffset(C,D)if B._grow then B._grow:snap(E)else B
.root.Size=E end end function A._applyPlacements(B)local C={}for D,E in B.
_placements do if E.hero then if B._heroView then B._heroView.root.Position=
UDim2.fromOffset(E.x,E.y)B._heroView.root.Size=UDim2.fromOffset(E.width,E.height
)end elseif E.section then C[E.section]=true local F=B._headers[E.section]if F
then F.Visible=true F.Position=UDim2.fromOffset(E.x,E.y)F.Size=UDim2.fromOffset(
E.width,E.height)end else C[E.el]=true local F=B._views[E.el]if F then B:_place(
F,E)end end end for D,E in B._headers do if not C[D]then E.Visible=false end end
for D,E in B._views do if not C[D]and E.root.Visible and not E._folding then if
B._live then E._folding=true growTo(E,E.root.Size.X.Offset,0,function()E.
_folding=false E.root.Visible=false end)else E.root.Visible=false end end end
end function A._place(B,C,D)local E=C.root local F=UDim2.fromOffset(D.x,D.y)
local G=B._live local H=G and not E.Visible local I=C._folding==true C._folding=
false E.Visible=true if H then setSize(C,D.width,0)growTo(C,D.width,D.height)
elseif I then growTo(C,D.width,D.height)elseif G and C._grow==nil and E.Size.Y.
Offset~=D.height then growTo(C,D.width,D.height)elseif G and C._grow and C._grow
.target.Y.Offset~=D.height then growTo(C,D.width,D.height)else setSize(C,D.width
,D.height)end if G and not H and E.Position~=F then if C._slide==nil then C.
_slide=C:own(ad.prop(E,'Position',y))end C._slide:to(F)elseif C._slide then C.
_slide:snap(F)else E.Position=F end end function A._materialize(B,C)local D=B.
frame local E=B._placements if D==nil or E==nil or not B.active then return end
local F=B.window.ctx.uiScale()local G=D.CanvasPosition.Y/F if not C and B.
_lastSync and math.abs(G-B._lastSync)<v/3 then return end B._lastSync=G local H,
I=G-v,G+D.AbsoluteSize.Y/F+v for J,K in E do local L=K.y if L+K.height>=H and L
<=I then if K.hero then if B._heroView==nil then local M=buildHero(B)M.root.
Position=UDim2.fromOffset(K.x,L)M.root.Size=UDim2.fromOffset(K.width,K.height)B.
_heroView=M end elseif K.section then if B._headers[K.section]==nil then local M
=buildHeader(B,K.section)M.Position=UDim2.fromOffset(K.x,L)M.Size=UDim2.
fromOffset(K.width,K.height)B._headers[K.section]=M end elseif B._views[K.el]==
nil then K.el._shownOn=B local M,N=xpcall(aa.build,debug.traceback,B.window.ctx,
K.el)if M then N.root.Position=UDim2.fromOffset(K.x,L)N.root.Size=UDim2.
fromOffset(K.width,if B._live then 0 else K.height)N.root.Parent=B.canvas B.
_views[K.el]=N if B._live then growTo(N,K.width,K.height)end else warn(
'sottUI: tile '..tostring(K.el.id)..' failed: '..tostring(N))end end end end end
function A._refreshThumb(B)local C=B.thumb if C==nil then return end local D=B.
window.ctx.uiScale()local E=B.frame.AbsoluteSize.Y/D local F=B._contentHeight or
0 if F<=E+1 or not B.active then C.Visible=false return end C.Visible=true local
G=math.max(E*E/F,40)local H=E-G local I=B.frame.CanvasPosition.Y/D/math.max(F-E,
1)C.Size=UDim2.new(0,3,0,G)C.Position=UDim2.new(1,-6,0,I*H)end function A.
scrollTo(B,C,D)local E=B.frame if E==nil then return end local F=B.window.ctx.
uiScale()local G=math.max((B._contentHeight or 0)-E.AbsoluteSize.Y/F,0)local H=
math.clamp(C,0,G)B._scrollTarget=H if D then B._scroll:snap(H)else B._scroll:to(
H)end end function A.wheel(B,C)if B.frame==nil or B.frame.ScrollingEnabled then
return end local D=B._scrollTarget or B.frame.CanvasPosition.Y/B.window.ctx.
uiScale()B:scrollTo(D-C*w)end function A.rowY(B,C)if B._placements==nil then B:
layout()end for D,E in B._placements or{}do if E.el==C then return E.y end end
return nil end function A.viewOf(B,C)return B._views[C]end function A.mount(B,C)
if B.frame then return end local D=B.window.ctx local E=ab('ScrollingFrame',{
Name=B.name,Size=UDim2.fromScale(1,1),Visible=false,ScrollingEnabled=D.touch,
Parent=C})local F=ab('Frame',{Name='Canvas',Size=UDim2.fromScale(1,1),Parent=E})
local G=ab('Frame',{Name='Thumb',BackgroundTransparency=0,Visible=false,ZIndex=5
,Parent=C})D.theme:paint(G,'BackgroundColor3','lineStrong')B.frame=E B.canvas=F
B.thumb=G B._scroll=ad.new(0,x,function(H)E.CanvasPosition=Vector2.new(0,H*D.
uiScale())end)E:GetPropertyChangedSignal('CanvasPosition'):Connect(function()B:
_materialize()B:_refreshThumb()end)local H=0 E:GetPropertyChangedSignal(
'AbsoluteSize'):Connect(function()local I=E.AbsoluteSize.X if I~=H then H=I B.
_quiet=true B:_invalidate()else B:_materialize(true)B:_refreshThumb()end end)end
function A.showList(B,C,D)B.sections={{title='',rows=C,flat=true}}for E,F in C
do F._shownOn=B end if B.frame then if B._empty==nil then local E=B.window.ctx.
theme B._empty=ab('TextLabel',{Position=UDim2.fromOffset(i,12),Size=UDim2.new(1,
-2*i,0,36),TextSize=17,Parent=B.frame})E:type(B._empty,'text')E:paint(B._empty,
'TextColor3','muted')end B._empty.Text=D or''B._empty.Visible=D~=nil B.
_emptyVisible=D~=nil end B:_invalidate()end function A.adopt(B)for C,D in B.
_views do C._view=D C._shownOn=B if D.refresh then D.refresh()end for E,F in D.
addonChips or{}do E._view=F if F.refresh then F.refresh()end end end end
function A.fitHeight(B,C)local D=0 for E,F in B._placements or{}do if F.el then
local G=F.y+F.height if G+n<=C and G>D then D=G end end end if D==0 then return
C end local E=math.huge for F,G in B._placements do if G.y>=D and G.y<E then E=G
.y end end return math.min(D+n,E)end function A.setActive(B,C)B.active=C if B.
frame then B.frame.Visible=C if not C then B.thumb.Visible=false end end if C
then B:layout()end end function A.destroy(B)B.destroyed=true for C,D in B._views
do D.destroy()end B._views={}if B._scroll then B._scroll:destroy()end if B.frame
then B.frame:Destroy()B.thumb:Destroy()end end function d.new(B,C)return
setmetatable({name=C,window=B,sections={},active=false,destroyed=false,_ids=0,
_dirty=false,_headers={},_views={},_placements=nil},A)end return d end function
a.y()local aa=a.cache.y if not aa then aa={c=__modImpl()}a.cache.y=aa end return
aa.c end end do local function __modImpl()local aa=a.f()local ab=UDim2.
fromOffset(16,72)local ac=44 return function(ad,b,c)local d=aa('TextButton',{
Name='Open',Position=ab,Size=UDim2.fromOffset(ac,ac),BackgroundTransparency=0,
TextSize=24,Text='s',Visible=false,ZIndex=50,Parent=ad})b:type(d,'display')b:
paint(d,'BackgroundColor3','accent')b:paint(d,'TextColor3','onAccent')d.
Activated:Connect(c)return d end end function a.z()local aa=a.cache.z if not aa
then aa={c=__modImpl()}a.cache.z=aa end return aa.c end end do local function 
__modImpl()local aa=a.n()local ab={}local function rgb(ac)return Color3.fromRGB(
bit32.band(bit32.rshift(ac,16),255),bit32.band(bit32.rshift(ac,8),255),bit32.
band(ac,255))end local ac={base=rgb(0x7100d),surface=rgb(0x141c18),raised=rgb(
0x1e2b25),line=rgb(0x1a2d27),lineStrong=rgb(0x2f4a40),text=rgb(0xebe8da),muted=
rgb(0xb4c2b8),faint=rgb(0x5f756b),accent=rgb(0x7ee0c4),accentHover=rgb(0x9bebd4)
,accentDim=rgb(0x1f4a3e),onAccent=rgb(0xb1a13),danger=rgb(0xe5604d)}local ad=
'rbxasset://fonts/families/BuilderSans.json'local b=
'rbxasset://fonts/families/RobotoCondensed.json'local c={}c.__index=c function
ab.defaults()return table.clone(ac)end function ab.new(d)local e=(ab.defaults())
for f,g in(d or{})do e[f]=g end local f={tokens=e,fonts={text=ad,display=b},
changed=aa.new(),_paints={},_types={},_count=0}return((setmetatable(f,c)))end
local d=2000 local function sweep(e)for f in e._paints do if f.Parent==nil then
e._paints[f]=nil e._types[f]=nil end end for f in e._types do if f.Parent==nil
then e._types[f]=nil end end end function c.paint(e,f,g,h)local i=e._paints[f]if
i==nil then i={}e._paints[f]=i e._count+=1 if e._count%d==0 then task.defer(
sweep,e)end end i[g]=h f[g]=e.tokens[h]end function c.face(e,f,g)if f=='display'
then return Font.new(e.fonts.display,Enum.FontWeight.ExtraBold)end return Font.
new(e.fonts.text,if g then Enum.FontWeight.Medium else Enum.FontWeight.Regular)
end function c.type(e,f,g,h)e._types[f]={family=g,medium=h==true}f.FontFace=e:
face(g,h)end function c.forget(e,f)e._paints[f]=nil e._types[f]=nil end function
c.apply(e,f)for g,h in f do e.tokens[g]=h end for g,h in e._paints do for i,j in
h do pcall(function()g[i]=e.tokens[j]end)end end e.changed:fire()end function c.
setFonts(e,f,g)e.fonts.text=f or e.fonts.text e.fonts.display=g or e.fonts.
display for h,i in e._types do pcall(function()h.FontFace=e:face(i.family,i.
medium)end)end end return ab end function a.A()local aa=a.cache.A if not aa then
aa={c=__modImpl()}a.cache.A=aa end return aa.c end end do local function 
__modImpl()local aa=a.b()local ab={}local ac=26 function ab.new(ad)local b={}
return function(c,d,e,f)local g=b[c]if g==nil then g={}b[c]=g end local h=g[d]if
h==nil then h=aa.prop(c,d,f or ac)g[d]=h end h:to(ad.tokens[e])end end return ab
end function a.B()local aa=a.cache.B if not aa then aa={c=__modImpl()}a.cache.B=
aa end return aa.c end end do local function __modImpl()local aa=a.q()local ab=a
.a()local ac=a.r()local ad=a.s()local b=a.u()local c=a.v()local d=a.t()local e=a
.f()local f=a.j()local g=a.b()local h=a.w()local i=a.x()local j=a.y()local k=a.
h()local l=a.p()local m=a.z()local n=a.n()local o=a.A()local p=a.B()local q={}
local r='main'local s=
[[https://raw.githubusercontent.com/interestng/sottUI/%s/fonts/]]local t=520
local u=64 local v=64 local w=76 local x=18 local y=26 local z=17 local A=16
local B=1 local C=64 local D=124 local E=40 local F=44 local G=28 local H=12
local I=600 local J=760 local K=38 local L=28 local M=30 local N=30 local O=4
local P=6 local Q=24 local R=12 local S={}S.__index=S local function randomName(
)local T=table.create(R)for U=1,R do T[U]=string.char(math.random(97,122))end
return table.concat(T)end local function encode(T)return ab.service(
'HttpService'):JSONEncode(T)end local function decode(T)local U,V=pcall(function
()return ab.service('HttpService'):JSONDecode(T)end)return if U then V else nil
end function S._registerElement(T,U,V,W)if V==T._resultsPage or V==T._onPage
then return end U._pageName=V.name U._page=V if W then if T.elements[U.id]then
error('sottUI: element id used twice: '..U.id,3)end T.elements[U.id]=U end if U.
kind~='divider'and U.kind~='label'and U.kind~='stat'then table.insert(T.ordered,
U)end if U.kind=='toggle'then U:on(function()if T._showing==T._onPage and T.
isOpen then T:_fillOn()end if U.spec.primary then T:_drawChips()if T._showing==T
._resultsPage then T._resultsPage:_invalidate()end end end)if U.spec.primary
then U._onLabel=function()T:_drawChips()end if U.value==true then T:_drawChips()
end end end end function S._drawChips(T)if T._chipsQueued or T.destroyed then
return end T._chipsQueued=true task.defer(function()T._chipsQueued=false if T.
destroyed then return end local U={}for V,W in T.ordered do if W.kind=='toggle'
and W.spec.primary and W.value==true and not W.disabled and W:shown()then table.
insert(U,W)end end for V,W in T._chips do W:Destroy()end table.clear(T._chips)
local V=T.ctx.theme local W=0 local function widthOf(X)return math.ceil(f.width(
'textMedium',X,z))+2*A end local function add(X,Y,Z,_)local ae=widthOf(X)local
af=e('TextButton',{Name='Chip',Size=UDim2.new(0,ae,1,0),BackgroundTransparency=0
,TextSize=z,Text=X,LayoutOrder=Y,ZIndex=3,Parent=T._chipRow})W+=ae+B V:type(af,
'text',true)V:paint(af,'BackgroundColor3','surface')V:paint(af,'TextColor3',
'accent')af.MouseEnter:Connect(function()T.ctx.tint(af,'BackgroundColor3',
'accent')T.ctx.tint(af,'TextColor3','onAccent')task.defer(function()T.ctx.
tooltip:schedule(af,Z)end)end)af.MouseLeave:Connect(function()T.ctx.tint(af,
'BackgroundColor3','surface')T.ctx.tint(af,'TextColor3','accent')T.ctx.tooltip:
hide()end)af.Activated:Connect(_)table.insert(T._chips,af)end local ae=T._scale.
Scale local af=T:_dockPoint()local X=af+(T._dockWidth or 0)*ae/2 local Y=(T._gui
.AbsoluteSize.X-X)/ae-B-H for Z,_ in U do local ag=#U-Z local ah=widthOf(_.label
)+(if ag>0 then C else 0)if Z>P or W+ah>Y then add('+'..(ag+1),100+Z,
'Show everything running',function()T:_fillOn()T:_show(T._onPage)end)break end
add(_.label,100+Z,'Turn off '.._.label,function()_:set(false)end)end T._chipRow.
Size=UDim2.new(0,W,1,0)end)end function S._setPerson(ae,af)ae._person=af end
function S._contentChanged(ae,af,ag)if ae._showing==nil then return end local ah
=ae._scale.Scale local T=ae._sheetRoom/ah-H local U=math.min(af,I,T)if af>U then
U=ae._showing:fitHeight(U)end local V=UDim2.new(0,ae._sheetWidth,0,U)if ag or ae
._sheetRise then ae._panelSize:to(V)else ae._panelSize:snap(V)end end function S
._placeSheet(ae)local af=ae._scale.Scale local ag,ah=ae:_dockPoint()local T=ag-(
ae._dockWidth or 0)*af/2 local U=ah-u*af local V=ae._gui.AbsoluteSize.Y local W=
U>=V/2 ae._sheetAbove=W ae._sheetRoom=if W then U else V-ah ae._panel.
AnchorPoint=Vector2.new(0,if W then 1 else 0)ae._panel.Position=UDim2.
fromOffset(math.floor(T),math.floor(if W then U else ah))end function S.
_dockPoint(ae)local af=ae._dockAt if af then return af.X,af.Y end local ag=ae.
_gui.AbsoluteSize return ag.X/2,ag.Y-w end function S._home(ae)local af=ae.
_dockAt return if af then UDim2.fromOffset(af.X,af.Y)else UDim2.new(0.5,0,1,-w)
end function S._away(ae)local af=ae._dockAt if af and af.Y<ae._gui.AbsoluteSize.
Y/2 then return UDim2.fromOffset(af.X,-H)end return ae:_home()+UDim2.fromOffset(
0,u*ae._scale.Scale+w+H)end function S._clampDock(ae)local af=ae._dockAt if af==
nil then return end local ag=ae._scale.Scale local ah=ae._gui.AbsoluteSize local
T=(ae._dockWidth or 0)*ag/2 ae._dockAt=Vector2.new(math.clamp(af.X,math.min(T+H,
ah.X/2),math.max(ah.X-T-H,ah.X/2)),math.clamp(af.Y,u*ag+H,math.max(ah.Y-H,u*ag+H
)))end function S._show(ae,af,ag)if ae._showing==af then return end ae.ctx.hover
.clear()ae.ctx.popover:close()ae.keys:cancel()local ah=ae._showing if ah then ah
:setActive(false)end local T=ae._leaving if T and T~=af then T:setActive(false)
end ae._leaving=nil ae._showing=af ae:_placeSheet()ae._sheetRise=not ag af:
setActive(true)ae._sheetRise=false af:adopt()ae:_syncMarker(ag)ae:_saveState()
end function S._hideSheet(ae)local af=ae._showing if af==nil then return end ae.
ctx.hover.clear()ae.ctx.popover:close()ae.keys:cancel()ae._showing=nil ae.
_leaving=af ae._panelSize:to(UDim2.new(0,ae._sheetWidth,0,0),function()if ae.
_leaving==af then ae._leaving=nil af:setActive(false)end end)ae:_syncMarker()end
function S._syncMarker(ae,af)local ag=ae.ctx.tint local ah=nil for T,U in ae.
_words do local V=ae._showing==T if U:IsA('TextButton')and U.Text~=''then ag(U,
'TextColor3',if V then'text'else'muted')end if V then ah=U end end if ah==nil or
ah==ae._homeAvatar then ae._markerSize:to(UDim2.fromOffset(0,O))return end ae.
ctx.theme:paint(ae._marker,'BackgroundColor3',if ah==ae._homeAvatar then
'onAccent'else'accent')local T=ae._scale.Scale local U=(ah.AbsolutePosition.X-ae
._dock.AbsolutePosition.X)/T local V=UDim2.fromOffset(U,if ae._sheetAbove==false
then u-O else 0)local W=UDim2.fromOffset(ah.AbsoluteSize.X/T,O)if af or ae.
_markerSize.target==nil or ae._markerSize.target.X.Offset==0 then ae._markerAt:
snap(V)else ae._markerAt:to(V)end if af then ae._markerSize:snap(W)else ae.
_markerSize:to(W)end end local function bindWord(ae,af,ag)ae._words[af]=ag ag.
Activated:Connect(function()if ae._box.Text~=''then ae._box.Text=''end if ae.
_showing==af then ae:_hideSheet()else ae:_show(af)end end)end local function 
addWord(ae,af,ag,ah)local T=ae.ctx.theme local U=math.ceil(f.width('textMedium',
ag,x))+2 local V=e('TextButton',{Name=ag,Size=UDim2.new(0,U,1,0),TextSize=x,Text
=ag,LayoutOrder=ah,ZIndex=3,Parent=ae._row})T:type(V,'text',true)T:paint(V,
'TextColor3','muted')bindWord(ae,af,V)V.MouseEnter:Connect(function()if ae.
_showing~=af then ae.ctx.tint(V,'TextColor3','text')end end)V.MouseLeave:
Connect(function()if ae._showing~=af then ae.ctx.tint(V,'TextColor3','muted')end
end)end function S.page(ae,af)local ag=j.new(ae,af)table.insert(ae.pages,ag)if
af=='Home'and ae._homeAvatar then bindWord(ae,ag,ae._homeAvatar)else addWord(ae,
ag,af,2+#ae.pages)end ag:mount(ae._panel)return ag end function S._fillOn(ae)
local af,ag={},{}for ah,T in ae.ordered do if T.kind=='toggle'and T.value==true
then table.insert(if T.spec.primary then af else ag,T)end end if#af==0 then af=
ag end ae._onPage:showList(af,if#af==0 then'Nothing is on'else nil)end function
S._query(ae,af)if af==''then if ae._showing==ae._resultsPage then ae:_hideSheet(
)end ae._resultsPage:showList({})return end local ag={}for ah,T in ae.ordered do
if T.visible~=false then table.insert(ag,T)end end local ah=k.settings(af,ag,Q)
ae._resultsPage:showList(ah,if#ah==0 then'Nothing matches'else nil)ae:_show(ae.
_resultsPage)end function S.showPage(ae,af)for ag,ah in ae.pages do if ah.name==
af then ae._box.Text=''ae:_show(ah)return end end end function S.show(ae,af,ag)
local ah=ae.pages[af]if ah then ae:_show(ah,ag)end end function S.reveal(ae,af)
local ag=af._page if ag then ae:setOpen(true)ae:showPage(ag.name)end end
function S.setOpen(ae,af)if ae.isOpen==af or ae.destroyed then return end ae.
isOpen=af if ae._opener then ae._opener.Visible=not af end ae.ctx.hover.clear()
ae.ctx.popover:close()ae.ctx.tooltip:hide()ae.keys:cancel()if not af and ae.
_dialogClose then ae._dialogClose()end if af then ae._root.Visible=true ae.
_modal.Visible=true ae:_guardCursor(true)ae._at:to(ae:_home())ae:_drawChips()
else ae._modal.Visible=false ae:_guardCursor(false)ae._box:ReleaseFocus()ae._box
.Text=''ae:_hideSheet()ae._at:to(ae:_away(),function()if not ae.isOpen then ae.
_root.Visible=false end end)end ae.visibilityChanged:fire(af)end function S.
_guardCursor(ae,af)local ag=ab.service('UserInputService')if af then ae.
_gameCursor=ag.MouseIconEnabled ag.MouseIconEnabled=true if ae._cursorGuard==nil
then ae._cursorGuard=ag:GetPropertyChangedSignal('MouseIconEnabled'):Connect(
function()if not ag.MouseIconEnabled then ae._gameCursor=false ag.
MouseIconEnabled=true end end)end else if ae._cursorGuard then ae._cursorGuard:
Disconnect()ae._cursorGuard=nil end if ae._gameCursor~=nil then ag.
MouseIconEnabled=ae._gameCursor ae._gameCursor=nil end end end function S.toggle
(ae)ae:setOpen(not ae.isOpen)end function S.notify(ae,af)if ae.destroyed then
return end ae.ctx.notify(af)end function S.setTheme(ae,af)ae.ctx.theme:apply(af)
end function S.setScale(ae,af)local ag=math.clamp(af,0.7,1.5)ae._scale.Scale=ag
ae._panelScale.Scale=ag ae:_placeSheet()ae:_drawChips()ae:_saveState()end
function S.setSubtitle(ae,af)ae._subtitleText=af end function S._saveState(ae)
local af=ae._files if af==nil or ae._stateFile==nil or ae._stateQueued then
return end ae._stateQueued=true task.delay(0.5,function()ae._stateQueued=false
if not ae.destroyed then local ag=ae._dockAt af.write(ae._stateFile,encode({
scale=ae._scale.Scale,dockX=ag and ag.X,dockY=ag and ag.Y}))end end)end function
S.dialog(ae,af,ag)if ae.destroyed then return false end aa.open(ae,af,ag)return
true end function S.find(ae,af)return ae.elements[af]end function S.snapshot(ae)
local af={}for ag,ah in ae.elements do if ah.saved then local T=ah.value if ah.
kind=='color'then T={hex=T.color:ToHex(),alpha=T.alpha}elseif ah.kind=='key'then
T={key=T.key,mode=T.mode,modifiers=T.modifiers,toggled=ah.toggled==true}end af[
ag]=T end end return af end function S.restore(ae,af)for ag,ah in af do local T=
ae.elements[ag]if T and T.saved then if T.kind=='color'and type(ah)=='table'then
T:set({color=Color3.fromHex(ah.hex or'ffffff'),alpha=ah.alpha})elseif T.kind==
'key'and type(ah)=='table'then T:set(ah)T.toggled=ah.toggled==true else T:set(ah
)end end end end function S.destroy(ae)if ae.destroyed then return end ae.
destroyed=true ae:_guardCursor(false)ae.ctx.notifications:destroy()for af,ag in
ae.pages do ag:destroy()end ae._onPage:destroy()ae._resultsPage:destroy()ae.ctx.
input:destroy()ae._maid:clean()ae.visibilityChanged:clear()if ae._registry and
ae._registry.current==ae then ae._registry.current=nil end end function q.new(ae
)local af=ae._registry if af and af.current then af.current:destroy()end local
ag=d.new()local ah=o.new(ae.theme)local T=b.new()local U=ab.service(
'UserInputService')local V=ae.touch==true or(U.TouchEnabled and not U.
MouseEnabled)local W=e('ScreenGui',{Name=randomName(),IgnoreGuiInset=true,
ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=ae.
displayOrder or 10000})ab.protect(W)W.Parent=ab.guiParent()ag:add(W)local X=ab.
files()local Y=ae.folder or'sottui_board'local Z=ae.stateFile or(Y..
'/window.json')local _=nil if X then X.folder(Y)local ai=X.read(Z)_=ai and
decode(ai)end if type(_)~='table'then _={}end local ai=e('Frame',{Name='Root',
Size=UDim2.fromScale(1,1),Visible=false,Parent=W})local aj=tonumber(_.scale)or(
if W.AbsoluteSize.X<800 then 0.8 else 1)local ak=e('Frame',{Name='Layer',Size=
UDim2.fromScale(1,1),ZIndex=100,Parent=W})local al=e('TextButton',{Name='Modal',
Size=UDim2.fromOffset(0,0),Modal=true,Visible=false,Parent=ai})local am=e(
'Frame',{Name='Assembly',AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0
,1,u),Size=UDim2.fromOffset(400,u),ZIndex=3,Parent=ai})local an=e('UIScale',{
Scale=aj,Parent=am})local ao=e('Frame',{Name='Dock',Size=UDim2.fromScale(1,1),
BackgroundTransparency=0,ClipsDescendants=true,Active=true,ZIndex=3,Parent=am})
ah:paint(ao,'BackgroundColor3','surface')local ap=e('Frame',{Name='Row',Size=
UDim2.fromScale(1,1),ZIndex=3,Parent=ao})local aq=e('UIListLayout',{
FillDirection=Enum.FillDirection.Horizontal,VerticalAlignment=Enum.
VerticalAlignment.Center,Padding=UDim.new(0,y),SortOrder=Enum.SortOrder.
LayoutOrder,Parent=ap})local ar=e('TextButton',{Name='Avatar',Size=UDim2.
fromOffset(v,v),BackgroundTransparency=0,ClipsDescendants=true,Text='',
LayoutOrder=1,ZIndex=3,Parent=ap})ah:paint(ar,'BackgroundColor3','accent')local
as=ab.service('Players').LocalPlayer if as then e('ImageLabel',{Size=UDim2.
fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,Image=string.format(
'rbxthumb://type=AvatarBust&id=%d&w=150&h=150',as.UserId),ZIndex=3,Parent=ar})
end local at=e('Frame',{Name='Running',Position=UDim2.fromScale(1,0),Size=UDim2.
new(0,0,1,0),BackgroundTransparency=0,ZIndex=3,Parent=am})ah:paint(at,
'BackgroundColor3','lineStrong')e('UIPadding',{PaddingLeft=UDim.new(0,B),Parent=
at})e('UIListLayout',{FillDirection=Enum.FillDirection.Horizontal,
VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,B),SortOrder=
Enum.SortOrder.LayoutOrder,Parent=at})local function tintFocus(au,av)ah:paint(au
,'BackgroundColor3',av)end local au=e('TextBox',{Name='Search',Size=UDim2.
fromOffset(D,E),BackgroundTransparency=0,TextSize=x,Text='',PlaceholderText=
'Search',ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,
LayoutOrder=300,ZIndex=3,Parent=ap})e('UIPadding',{PaddingLeft=UDim.new(0,12),
PaddingRight=UDim.new(0,8),Parent=au})ah:paint(au,'BackgroundColor3','surface')
au.Focused:Connect(function()tintFocus(au,'base')end)au.FocusLost:Connect(
function()tintFocus(au,'surface')end)ah:type(au,'text')ah:paint(au,'TextColor3',
'text')local av=e('Frame',{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,-
12,0.5,0),Size=UDim2.fromOffset(1,28),BackgroundTransparency=0,ZIndex=4,Parent=
au})ah:paint(av,'BackgroundColor3','lineStrong')ah:paint(au,'PlaceholderColor3',
'muted')local aw=e('Frame',{Name='Marker',Size=UDim2.fromOffset(0,O),
BackgroundTransparency=0,ZIndex=4,Parent=ao})ah:paint(aw,'BackgroundColor3',
'accent')local ax=e('Frame',{Name='Sheet',AnchorPoint=Vector2.new(0,1),Position=
UDim2.new(0,0,1,-(w+u)),Size=UDim2.new(0,t,0,0),BackgroundTransparency=0,
ClipsDescendants=true,Active=true,ZIndex=2,Parent=ai})ah:paint(ax,
'BackgroundColor3','surface')local ay=e('UIScale',{Scale=aj,Parent=ax})local az=
setmetatable({ctx=nil,pages={},elements={},ordered={},isOpen=false,destroyed=
false,width=t,visibilityChanged=n.new(),_maid=ag,_gui=W,_root=ai,_layer=ak,
_modal=al,_scale=an,_panelScale=ay,_box=au,_panel=ax,_dock=ao,_row=ap,_marker=aw
,_chipRow=at,_homeAvatar=ar,_chips={},_sheetRoom=600,_sheetWidth=t,_dockAt=if
tonumber(_.dockX)and tonumber(_.dockY)then Vector2.new(_.dockX,_.dockY)else nil,
_words={},_subtitleText=ae.subtitle,_files=X,_stateFile=Z,_dialogIds=0,_registry
=af},S)if af then af.current=az end local aA={theme=ah,input=T,touch=V,assets={}
,glyph=ad.new(ah),tint=p.new(ah),uiScale=function()return an.Scale end,
popoverTop=function()return 8 end,dialogAt=function(aA)local aB=ak.AbsoluteSize
return UDim2.fromOffset(math.floor((aB.X-aA*an.Scale)/2),math.floor(aB.Y*0.2))
end,isShowing=function(aA)if not az.isOpen then return false end if aA._page==
nil and aA._shownOn==nil then return true end return az._showing~=nil and(aA.
_shownOn==az._showing or aA._page==az._showing)end,setScrollLocked=function(aA)
local aB=az._showing if aB and aB.frame and V then aB.frame.ScrollingEnabled=not
aA end end}az.ctx=aA local aB=i.popover(aA,ak)aA.popover=aB aA.tooltip=i.
tooltip(aA,ak)aA.hover=i.hover(aA)aA.notifications=h.new(aA,ak)aA.notify=
function(aC)aA.notifications:show(aC)end az.keys=c.new(T,ab,function()return az.
isOpen end)aA.keys=az.keys az._at=ag:add(g.prop(am,'Position',L))az._at:snap(az:
_away())az._panelSize=ag:add(g.prop(ax,'Size',K))az._markerAt=ag:add(g.prop(aw,
'Position',M))az._markerSize=ag:add(g.prop(aw,'Size',M))local aC=ag:add(g.prop(
am,'Size',N))az._onPage=j.new(az,'On')az._resultsPage=j.new(az,'Results')az.
_onPage:mount(ax)az._resultsPage:mount(ax)local aD=e('TextButton',{Name='Close',
Size=UDim2.new(0,F,1,0),LayoutOrder=400,ZIndex=4,Parent=ap})local aE=aA.glyph.
cross(aD,'muted')aE.AnchorPoint=Vector2.new(0.5,0.5)aE.Position=UDim2.new(0.5,4,
0.5,0)aE.ZIndex=4 local aF=e('Frame',{AnchorPoint=Vector2.new(0,0.5),Position=
UDim2.fromScale(0,0.5),Size=UDim2.fromOffset(1,G),BackgroundTransparency=0,
ZIndex=4,Parent=aD})ah:paint(aF,'BackgroundColor3','lineStrong')ar.MouseEnter:
Connect(function()aA.tint(ar,'BackgroundColor3','accentHover')end)ar.MouseLeave:
Connect(function()aA.tint(ar,'BackgroundColor3','accent')end)ao.InputBegan:
Connect(function(aG)local aH=aG.UserInputType if aH~=Enum.UserInputType.
MouseButton1 and aH~=Enum.UserInputType.Touch then return end local aI=if aH==
Enum.UserInputType.Touch then T:at(aG)else T:pointer()local aJ,aK=az:_dockPoint(
)T:capture(function(aL)local aM=aL-aI az._dockAt=Vector2.new(aJ+aM.X,aK+aM.Y)az:
_clampDock()az._at:snap(az:_home())az:_placeSheet()local aN=az._showing if aN
then aN:_invalidate()end end,function()az:_drawChips()az:_syncMarker(true)az:
_saveState()end,if aH==Enum.UserInputType.Touch then aG else nil)end)aD.
Activated:Connect(function()az:setOpen(false)end)aD.MouseEnter:Connect(function(
)aA.tooltip:schedule(aD,'Close menu')end)aD.MouseLeave:Connect(function()aA.
tooltip:hide()end)au:GetPropertyChangedSignal('Text'):Connect(function()az:
_query(au.Text)end)local function fitDock()local aG=math.ceil(aq.
AbsoluteContentSize.X/an.Scale)az._dockWidth=aG aC:snap(UDim2.fromOffset(aG,u))
az:_clampDock()if az.isOpen then az._at:snap(az:_home())else az._at:snap(az:
_away())end az:_placeSheet()az:_drawChips()task.defer(function()if not az.
destroyed then az._sheetWidth=math.clamp(az._dockWidth,t,J)az._panelSize:snap(
UDim2.new(0,az._sheetWidth,0,ax.Size.Y.Offset))az:_syncMarker(true)end end)end
aq:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(fitDock)task.defer(
fitDock)ag:add(W:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()az:
_clampDock()if az.isOpen then az._at:snap(az:_home())end az:_placeSheet()az:
_drawChips()local aG=az._showing if aG then aG:_invalidate()end end))T.moved:
connect(function(aG)aA.hover:verify(aG)end)T.wheel:connect(function(aG)if not az
.isOpen or aA.popover:isOpen()then return end local aH=az._showing if aH==nil or
aH.frame==nil then return end local aI=T:pointer()local aJ,aK=aH.frame.
AbsolutePosition,aH.frame.AbsoluteSize if aI.X>=aJ.X and aI.Y>=aJ.Y and aI.X<=aJ
.X+aK.X and aI.Y<=aJ.Y+aK.Y then aH:wheel(aG)end end)T.keyDown:connect(function(
aG,aH)if aG.UserInputType~=Enum.UserInputType.Keyboard then return end local aI=
aG.KeyCode.Name if az.keys:swallowed(aI)then return end if aA.popover:key(aI)
then return end if aI=='Escape'and az._dialogClose then az._dialogClose()return
end if aI=='Escape'and au.Text~=''then au.Text=''return end if aH or T:typing()
then return end if az.isOpen and aI=='K'then if U:IsKeyDown(Enum.KeyCode.
LeftControl)or U:IsKeyDown(Enum.KeyCode.RightControl)then au:CaptureFocus()end
end end)ag:add(ah.changed:connect(function()local aG=table.clone(az.pages)table.
insert(aG,az._onPage)table.insert(aG,az._resultsPage)for aH,aI in aG do for aJ,
aK in aI._views do pcall(function()aK:retint()aK.refresh()end)end end end))local
aG=l.new({window=az,nextId=function()return 0 end,_register=function(aG,aH,aI)if
aI then az.elements[aH.id]=aH end aH._pageName=''end,_invalidate=function()end},
'')az.menuKey=aG:key('__menu',{label='Menu',default=ae.key or'RightShift',mode=
'Toggle',saved=false,onPress=function()az:toggle()end})local aH=ab.service(
'RunService')g.setAttach(function(aI)return aH.PreRender:Connect(aI)end)if ae.
fonts~=false and X then ag:add(task.defer(function()local aI=ae.fontTag or r
local aJ=string.format(s,aI)local aK=Y..'/fonts-'..aI local aL=ac.load(aK,aJ,
encode)if not az.destroyed and(aL.text or aL.display)then ah:setFonts(aL.text,aL
.display)end end))end if V then az._opener=m(W,ah,function()az:setOpen(true)end)
end if ae.autoShow~=false then task.defer(function()az:setOpen(true)end)end
return az end function q.setVersion(ae)r=ae end return q end function a.C()local
aa=a.cache.C if not aa then aa={c=__modImpl()}a.cache.C=aa end return aa.c end
end end local aa=a.a()local ab=a.b()local ac=a.e()local ad=a.C()local ae=
'0.4.1-board'local function registry()local af=aa.global('getgenv')local ag=if
type(af)=='function'then af()else _G local ah=ag.__sottui if type(ah)~='table'
then ah={current=nil}ag.__sottui=ah end return ah end local af={version=ae,
motion=ab}ad.setVersion('v'..ae)function af.window(ag)local ah=table.clone(ag or
{})ah._registry=registry()return ad.new(ah)end function af.current()return
registry().current end function af.obsidian()return ac.new(af)end return af