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
value.alpha*0.8 p.BackgroundTransparency=if r then math.max(s,l)else s end q.
setMuted=function(s)r=s q.refresh()end q.refresh()q.open=function()if not n.
disabled then open(m,n,o)end end o.Activated:Connect(q.open)q.setInk=function()
end q.destroy=function()o:Destroy()end return q end return c end function a.g()
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
accentDim end if o._quiet then return if o._hover then p.surface else p.base end
return if o._hover then p.raised else p.surface end local function washTo(o)if o
._wash==nil then o._wash=o:own(c.prop(o.root,'BackgroundColor3',e))end o._wash:
to(baseColor(o))end local function snapBase(o)local p=baseColor(o)if o._wash
then o._wash:snap(p)else o.root.BackgroundColor3=p end end function n.onHover(o,
p)local q=p and not o.el.disabled if o._hover==q then return end o._hover=q for
r,s in o.chips do if s.setHover then s.setHover(q)end end if not(o._floodFrame
and o._floodFrame.Visible)then washTo(o)end end function n.pressed(o,p)if o.
_press==nil then local q=b('UIScale',{Parent=o.root})o._press=o:own(c.prop(q,
'Scale',f,g))end o._press:to(if p then j else 1)end function n.flood(o,p,q)if o.
_floodOn==p then return end o._floodOn=p local r=o.root local s=r.AbsoluteSize
if q or s.X<1 or not r.Visible or not o.ctx.isShowing(o.el)then o._lit=p if o.
_floodFrame then o._floodFrame.Visible=false o._floodSpring:snap(UDim2.
fromOffset(0,0))end snapBase(o)return end local t=o._floodFrame if t==nil then t
=b('Frame',{Name='Flood',AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(
0,0),BackgroundTransparency=0,ZIndex=1,Parent=r})b('UICorner',{CornerRadius=UDim
.new(1,0),Parent=t})o.ctx.theme:paint(t,'BackgroundColor3','accent')o.
_floodFrame=t o._floodSpring=o:own(c.prop(t,'Size',h))end local u=o.ctx.uiScale(
)local v=s/u local w=math.ceil(math.sqrt(v.X*v.X+v.Y*v.Y)*k)local x=o._pressAt o
._pressAt=nil local y=if x then(x-r.AbsolutePosition)/u else v/2 t.Position=
UDim2.fromOffset(y.X,y.Y)t.Visible=true if p then o._floodSpring:snap(UDim2.
fromOffset(0,0))o._floodSpring:to(UDim2.fromOffset(w,w),function()o._lit=true
local z=o._hover o._hover=false snapBase(o)o._hover=z t.Visible=false washTo(o)
end)else o._lit=false snapBase(o)o._floodSpring:snap(UDim2.fromOffset(w,w))o.
_floodSpring:to(UDim2.fromOffset(0,0),function()t.Visible=false end)end end
function n.tint(o,p,q)if o._tinted==p then return end o._tinted=p if q or not o.
ctx.isShowing(o.el)then snapBase(o)else washTo(o)end end function n.flash(o)if o
._floodOn then o:pressed(true)task.delay(0.16,function()if o.root.Parent then o:
pressed(false)end end)return end o:flood(true)task.delay(0.28,function()if o.
root.Parent and not(o.el.kind=='toggle'and o.el.value==true)then o:flood(false)
end end)end function n.ink(o,p,q,r)local s=o.ctx.theme.tokens local t=o._inks[p]
if r or not o.ctx.isShowing(o.el)then if t then t:snap(s[q])else p.TextColor3=s[
q]end return end if t==nil then t=o:own(c.prop(p,'TextColor3',i))o._inks[p]=t
end t:to(s[q])end function n.retint(o)snapBase(o)end function n.refreshName(o)
local p=o.el if p.disabled then o.name.RichText=true o.name.Text='<s>'..p.label
..'</s>'else o.name.RichText=false o.name.Text=p.label end end function d.new(o,
p,q)local r=q or{}local s=b('TextButton',{Name=p.kind,Size=UDim2.new(1,0,0,r.
height or d.HEIGHT),BackgroundTransparency=if r.inert then 1 else 0,
ClipsDescendants=true,Active=not r.inert})local t=b('TextLabel',{Name='Name',
Position=UDim2.fromOffset(d.PAD,0),Size=UDim2.new(1,-2*d.PAD,1,0),TextSize=d.
NAME,TextWrapped=true,TextTruncate=Enum.TextTruncate.AtEnd,Text=p.label,ZIndex=3
,Parent=s})o.theme:type(t,'text',true)local u=setmetatable({root=s,name=t,el=p,
ctx=o,chips={},_cleanups={},_inks={},_hover=false,_lit=false,_floodOn=false,
_tinted=false,_quiet=r.quiet==true},n)s.BackgroundColor3=baseColor(u)u:
refreshName()if r.inert then u.onHover=function()end u.pressed=function()end
else s.MouseEnter:Connect(function()o.hover:enter(u)end)local v=nil s.InputBegan
:Connect(function(w)local x=w.UserInputType if x==Enum.UserInputType.
MouseButton1 then if not p.disabled then u._pressAt=o.input:pointer()u:pressed(
true)end elseif x==Enum.UserInputType.Touch then if not p.disabled then u.
_pressAt=o.input:at(w)u:pressed(true)end v=task.delay(l,function()v=nil local y=
if p.disabled and p.disabledTip then p.disabledTip else p.tip if y and y~=''then
o.tooltip:showAt(s,y)end end)end end)local w=o.input.pointerUp:connect(function(
)if u._press and u._press.target~=1 then u:pressed(false)end if v then task.
cancel(v)v=nil end end)u:onCleanup(function()w()if v then task.cancel(v)end end)
end u.destroy=function()o.hover:leave(u)for v,w in u._cleanups do pcall(w)end s:
Destroy()end return u end return d end function a.l()local b=a.cache.l if not b
then b={c=__modImpl()}a.cache.l=b end return b.c end end do local function 
__modImpl()local b=a.g()local c=a.i()local d=a.k()local e=a.f()local f=a.j()
local g=a.b()local h=a.l()local i={}local j=h.PAD local k=22 local l=28 local m=
42 local n=28 local o=42 local p=90 local q=3 local r=12 local s=17 local t=22
local u=16 local v=1 local w=4 local x=34 local y=17 local z=34 local A=16 local
B=16 local C=64 local D={}local function addons(E,F,G,H)local I=H local J={}
local function reflow()local K=H for L,M in J do M.root.Position=UDim2.new(1,-(j
+K),0.5,0)K+=M.width+M.gap end E.name.Size=UDim2.new(1,-(2*j+K),1,0)end local 
function place(K,L)L.root.AnchorPoint=Vector2.new(1,0.5)L.root.Position=UDim2.
new(1,-(j+I),0.5,0)L.root.ZIndex=4 L.root.Parent=E.root L.gap=if K.kind=='key'
then 6 else 0 L.onFit=reflow I+=L.width table.insert(J,L)K._view=L table.insert(
E.chips,L)E:onCleanup(function()K._view=nil L.destroy()end)end for K,L in G.
addons or{}do if L.kind=='color'and not L.spec.chipless then place(L,b.swatch(F,
L))end end for K,L in G.addons or{}do if L.kind=='key'and not L.spec.chipless
then place(L,d.build(F,L))I+=6 end end return I end local function reserveRight(
E,F)E.name.Size=UDim2.new(1,-(2*j+F),1,0)end local function baseline(E,F,G)local
H=e('Frame',{Name='Track',AnchorPoint=Vector2.new(0,1),Position=UDim2.fromScale(
0,1),Size=UDim2.new(1,0,0,v),BackgroundTransparency=0,ZIndex=2,Parent=E.root})F.
theme:paint(H,'BackgroundColor3','lineStrong')local I=e('Frame',{Name='Fill',
AnchorPoint=Vector2.new(0,1),Position=UDim2.fromScale(0,1),Size=UDim2.new(G,0,0,
w),BackgroundTransparency=0,ZIndex=2,Parent=E.root})F.theme:paint(I,
'BackgroundColor3','accent')return I end function D.toggle(E,F)local G=F.spec.
primary==true local H=h.new(E,F,{quiet=not G})local I=E.theme if not G then
local J=baseline(H,E,if F.value==true then 1 else 0)local K=H:own(g.prop(J,
'Size',o))reserveRight(H,addons(H,E,F,0))local function draw(L)local M=F.value==
true H:tint(M,L)H:ink(H.name,if F.disabled then'faint'elseif M then'text'else
'muted',L)local N=UDim2.new(if M then 1 else 0,0,0,w)if L or not E.isShowing(F)
then K:snap(N)else K:to(N)end for O,P in H.chips do P.setInk(false)if P.setMuted
then P.setMuted(not M)end end end H.root.Activated:Connect(function()if not F.
disabled then F:set(not F.value)end end)H.refresh=function()H:refreshName()draw(
false)end draw(true)return H end local J=u if G then I:type(H.name,'display')H.
name.TextSize=if F.value==true then m else l H.name.TextWrapped=false H.
_nameSize=H:own(g.prop(H.name,'TextSize',n))end local K=e('Frame',{AnchorPoint=
Vector2.new(1,0.5),Position=UDim2.new(1,-j,0.5,0),Size=UDim2.fromOffset(J,J),
ZIndex=3,Parent=H.root})local L=e('UIStroke',{ApplyStrokeMode=Enum.
ApplyStrokeMode.Border,Thickness=2,Parent=K})local M=nil local N=nil local O=nil
local P=J+12 if G then M=e('TextButton',{AnchorPoint=Vector2.new(1,0),Position=
UDim2.new(1,-(j+J+4),0,0),Size=UDim2.new(0,C,1,0),ZIndex=4,Parent=H.root})N=E.
glyph.chevron(M,'muted','down')O=E.glyph.chevron(M,'muted','up')for Q,R in{N,O}
do R.AnchorPoint=Vector2.new(0.5,0.5)R.Position=UDim2.fromScale(0.5,0.5)end P+=C
M.Activated:Connect(function()F.section:togglePeek()H.refresh()end)end
reserveRight(H,addons(H,E,F,P))local function draw(Q)local R=F.value==true local
S=G and R if G then H:flood(R,Q)local T=if R then m else l if Q or not E.
isShowing(F)then H._nameSize:snap(T)else H._nameSize:to(T)end end H:ink(H.name,
if F.disabled then'faint'elseif S then'onAccent'elseif R then'text'else'muted',Q
)K.BackgroundTransparency=if R then 0 else 1 I:paint(K,'BackgroundColor3',if S
then'onAccent'else'accent')I:paint(L,'Color',if S then'onAccent'elseif R then
'accent'elseif F.disabled then'line'else'lineStrong')for T,U in H.chips do U.
setInk(S)end if M then M.Visible=not R and F.section.hasOptions==true N.Visible=
not F.section.peeking O.Visible=F.section.peeking==true end end H.root.Activated
:Connect(function()if not F.disabled then F:set(not F.value)end end)H.refresh=
function()H:refreshName()draw(false)end draw(true)return H end local function 
formatted(E,F)local G=E.spec if G.format then local H,I=pcall(G.format,E,F)if H
and I~=nil then return tostring(I)end end return string.format('%.'..(G.decimals
or 0)..'f',F)..(G.suffix or'')end function i.readoutWidth(E)local F=E.spec local
G=0 for H,I in{F.min,F.max,E.value}do G=math.max(G,f.width('display',formatted(E
,I),k))end return math.ceil(G*1.05)+2 end function D.slider(E,F)local G=h.new(E,
F,{quiet=true})local H=E.theme local I=F.spec local J=G.root local function 
ratio()local K=I.max-I.min return if K<=0 then 0 else(F.value-I.min)/K end local
K=i.readoutWidth(F)reserveRight(G,K+r)G.name.ZIndex=4 local L=e('TextLabel',{
Name='Readout',AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-j,0,0),Size=
UDim2.new(0,K,1,0),TextSize=k,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=4,
Parent=J})H:type(L,'display')local M=baseline(G,E,ratio())local N=G:own(g.prop(M
,'Size',o))local function typedEntry()if F.disabled or G._typing then return end
G._typing=true L.Visible=false local O=e('TextBox',{AnchorPoint=Vector2.new(1,0)
,Position=UDim2.new(1,-j,0,0),Size=UDim2.new(0,math.max(K,64),1,0),TextSize=k,
TextXAlignment=Enum.TextXAlignment.Right,Text='',PlaceholderText=tostring(F.
value),ZIndex=6,Parent=J})H:type(O,'display')H:paint(O,'TextColor3','accent')H:
paint(O,'PlaceholderColor3','faint')O:CaptureFocus()O.FocusLost:Connect(function
()local P=tonumber(O.Text)G._typing=false L.Visible=true O:Destroy()if P then F:
set(P)end end)end local function beginDrag(O,P,Q)if F.disabled then return end
local R=F.value local S=math.max(J.AbsoluteSize.X,1)local T=I.max-I.min local U=
false local V=false E.input:capture(function(W)local X=W-O if not U then if math
.abs(X.X)<q then if P and math.abs(X.Y)>8 then V=true E.input:release()end
return end if P and math.abs(X.X)<=math.abs(X.Y)then V=true E.input:release()
return end U=true N.speed=p E.setScrollLocked(true)end F:set(R+T*X.X/S)end,
function(W)N.speed=o E.setScrollLocked(false)if not U and not V and(W-O).
Magnitude<8 then typedEntry()end end,Q)end J.InputBegan:Connect(function(O)local
P=O.UserInputType if P==Enum.UserInputType.MouseButton2 then typedEntry()elseif
P==Enum.UserInputType.MouseButton1 then beginDrag(E.input:pointer(),false)elseif
P==Enum.UserInputType.Touch then beginDrag(E.input:at(O),true,O)end end)local 
function paintText()local O=if F.disabled then'faint'else'text'H:paint(G.name,
'TextColor3',O)H:paint(L,'TextColor3',O)L.Text=formatted(F,F.value)end G.refresh
=function()G:refreshName()paintText()N:to(UDim2.new(ratio(),0,0,w))end
paintText()return G end local function pickText(E)local F=E.spec.display or
tostring local G=E.value if E.spec.multi then local H={}for I,J in E.spec.
options do if G[J]then table.insert(H,F(J))end end for I,J in G do if J and not
table.find(E.spec.options,I)then table.insert(H,F(I))end end if#H==0 then return
'None',false end if#H<=2 then return table.concat(H,', '),true end return string
.format('%s, %s +%d',H[1],H[2],#H-2),true end if G==nil then return'None',false
end return F(G),true end function D.dropdown(E,F)local G=h.new(E,F,{quiet=true})
local H=E.theme local I=G.root baseline(G,E,0)H:paint(G.name,'TextColor3',
'muted')local J=e('TextLabel',{Name='Value',AnchorPoint=Vector2.new(1,0),
Position=UDim2.new(1,-(j+t),0,0),TextSize=s,TextTruncate=Enum.TextTruncate.AtEnd
,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=3,Parent=I})H:type(J,'text',
true)local K=E.glyph.chevron(I,'muted')K.AnchorPoint=Vector2.new(1,0.5)K.
Position=UDim2.new(1,-j,0.5,0)K.ZIndex=3 local function fit()local L=I.
AbsoluteSize.X/E.uiScale()-2*j-t if L<=0 then return end local M=f.width(
'textMedium',(pickText(F)),s)+r local N=math.max(L-M,L*0.45)G.name.Size=UDim2.
new(0,N,1,0)J.Size=UDim2.new(0,L-N,1,0)end I:GetPropertyChangedSignal(
'AbsoluteSize'):Connect(fit)I.Activated:Connect(function()if not F.disabled then
c.open(E,F,I)end end)G.refresh=function()G:refreshName()local L,M=pickText(F)J.
Text=L H:paint(J,'TextColor3',if F.disabled or not M then'faint'else'text')fit()
end G.refresh()task.defer(fit)return G end function D.input(E,F)local G=h.new(E,
F,{quiet=true})local H=E.theme local I=F.spec G.name.Size=UDim2.new(0.35,-j,1,0)
H:paint(G.name,'TextColor3','muted')local J=e('TextBox',{AnchorPoint=Vector2.
new(1,0.5),Position=UDim2.new(1,-j,0.5,0),Size=UDim2.new(0.65,-j,0,x),TextSize=y
,Text=F.value or'',PlaceholderText=I.placeholder or'',ClipsDescendants=true,
TextEditable=not F.disabled,ZIndex=3,Parent=G.root})H:type(J,'text',true)H:
paint(J,'TextColor3','text')H:paint(J,'PlaceholderColor3','faint')local K=e(
'Frame',{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.
new(1,0,0,v),BackgroundTransparency=0,ZIndex=4,Parent=G.root})H:paint(K,
'BackgroundColor3','lineStrong')J.Focused:Connect(function()H:paint(K,
'BackgroundColor3','accent')end)J.FocusLost:Connect(function(L)H:paint(K,
'BackgroundColor3','lineStrong')if not I.finished then return end if not L or
not F:set(J.Text)then J.Text=F.value or''end end)J:GetPropertyChangedSignal(
'Text'):Connect(function()if G._applying or I.finished then return end if not F:
set(J.Text)and J.Text~=F.value then G._applying=true J.Text=F.value or''G.
_applying=false end end)G.root.Activated:Connect(function()if not F.disabled
then J:CaptureFocus()end end)G.refresh=function()G:refreshName()J.TextEditable=
not F.disabled if J.Text~=(F.value or'')then G._applying=true J.Text=F.value or
''G._applying=false end end return G end function D.button(E,F)local G=h.new(E,F
)local H=nil local function draw()G:refreshName()G:ink(G.name,if F.disabled then
'faint'elseif F.spec.danger then'danger'else'text')end G.refresh=draw draw()G.
root.Activated:Connect(function()if F.disabled then return end if F.spec.confirm
and H==nil then G.name.Text='Again to confirm'G:flood(true)G:ink(G.name,
'onAccent')H=task.delay(2.5,function()H=nil G:flood(false)draw()end)return end
if H then task.cancel(H)H=nil G:flood(false)draw()end G:flash()G:ink(G.name,
'onAccent')task.delay(0.28,function()if G.root.Parent then draw()end end)F:fire(
)end)G:onCleanup(function()if H then task.cancel(H)end end)return G end function
D.stat(E,F)local G=h.new(E,F,{inert=true})local H=E.theme G.name.Position=UDim2.
new()G.name.Size=UDim2.new(1,0,0,z+4)G.name.TextSize=z G.name.TextWrapped=false
G.name.TextYAlignment=Enum.TextYAlignment.Top H:paint(G.name,'TextColor3','text'
)local I=e('TextLabel',{Position=UDim2.fromOffset(0,z+2),Size=UDim2.new(1,0,0,A+
4),TextSize=A,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=3,Parent=G.root})H:
type(I,'text')H:paint(I,'TextColor3','muted')G.refresh=function()G.name.Text=
tostring(F.value)I.Text=F.label end G.refresh()return G end function D.label(E,F
)local G=E.theme if F.addons then local H=h.new(E,F)G:paint(H.name,'TextColor3',
'muted')H.name.RichText=true reserveRight(H,addons(H,E,F,0))H.refresh=function()
H.name.Text=F.label end return H end local H=h.new(E,F,{height=32,inert=true})
local I=H.name local J=F.spec.wrap==true I.RichText=true I.TextSize=B I.
TextWrapped=J G:type(I,'text')G:paint(I,'TextColor3','muted')I.TextTruncate=if J
then Enum.TextTruncate.None else Enum.TextTruncate.AtEnd I.TextYAlignment=if J
then Enum.TextYAlignment.Top else Enum.TextYAlignment.Center I.LineHeight=if J
then 1.15 else 1 I.Position=UDim2.fromOffset(0,if J then 6 else 0)I.Size=if J
then UDim2.new(1,0,1,-6)else UDim2.fromScale(1,1)I.Text=F.label if J then I:
GetPropertyChangedSignal('TextBounds'):Connect(function()local K=math.ceil(I.
TextBounds.Y/E.uiScale())+12 if F._measured~=K then F._measured=K if F._relayout
then F._relayout()end end end)end H.refresh=function()I.Text=F.label end return
H end function D.divider(E,F)local G=h.new(E,F,{height=28,inert=true})local H=E.
theme G.name.Position=UDim2.new()G.name.Size=UDim2.fromScale(1,1)G.name.TextSize
=B H:type(G.name,'text',true)H:paint(G.name,'TextColor3','muted')G.refresh=
function()G.name.Text=F.label end return G end local function chipTile(E,F,G,H,I
)local J=h.new(E,F)E.theme:paint(J.name,'TextColor3','muted')G.root.AnchorPoint=
Vector2.new(1,0.5)G.root.Position=UDim2.new(1,-I,0.5,0)G.root.ZIndex=4 G.root.
Parent=J.root reserveRight(J,H)table.insert(J.chips,G)J:onCleanup(G.destroy)J.
refresh=function()J:refreshName()G.refresh()end return J end function D.key(E,F)
local G=d.build(E,F)local H=chipTile(E,F,G,96,j)H.root.Activated:Connect(G.start
)return H end function D.color(E,F)local G=b.swatch(E,F)local H=chipTile(E,F,G,b
.DOT_SPACE,j-8)H.root.Activated:Connect(G.open)return H end function i.build(E,F
)local G=D[F.kind]assert(G,'sottUI: no view for '..tostring(F.kind))local H=G(E,
F)F._view=H return H end return i end function a.m()local b=a.cache.m if not b
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
k.width or 460 local q=k.maxHeight or 340 local r=60 local s=c('TextButton',{
Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BackgroundColor3=Color3.new(0
,0,0),ZIndex=50,Parent=o})local t=e.prop(s,'BackgroundTransparency',22)t:to(0.4)
local u=c('Frame',{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5
,0.5),Size=UDim2.fromOffset(p,0),BackgroundTransparency=0,ClipsDescendants=true,
Active=true,ZIndex=51,Parent=o})n:paint(u,'BackgroundColor3','base')c('UIScale',
{Scale=m.uiScale(),Parent=u})local v=c('UIStroke',{ApplyStrokeMode=Enum.
ApplyStrokeMode.Border,Parent=u})n:paint(v,'Color','lineStrong')local w=c(
'TextLabel',{Position=UDim2.fromOffset(20,16),Size=UDim2.new(1,-40,0,40),
TextSize=36,Text=k.title or'',ZIndex=52,Parent=u})n:type(w,'display')n:paint(w,
'TextColor3','text')local x=60 local y=k.text if y and y~=''then local z=c(
'TextLabel',{Position=UDim2.fromOffset(20,x),Size=UDim2.new(1,-40,0,22),
AutomaticSize=Enum.AutomaticSize.Y,TextSize=16,TextWrapped=true,Text=y,ZIndex=52
,Parent=u})n:type(z,'text')n:paint(z,'TextColor3','muted')x+=22+math.floor(#y/52
)*22+12 end local z=c('ScrollingFrame',{Position=UDim2.fromOffset(20,x),Size=
UDim2.new(1,-40,0,0),ScrollBarThickness=3,ZIndex=52,Parent=u})n:paint(z,
'ScrollBarImageColor3','lineStrong')local A=false local B={window=j,name=
'Dialog',nextId=function()j._dialogIds+=1 return j._dialogIds end,_register=
function(B,C,D)C._pageName='Dialog'if D then j.elements[C.id]=C end end,
_invalidate=function()end}local C=f.new(B,'')local D,E=xpcall(l,debug.traceback,
C)if not D then warn('sottUI: dialog build failed: '..tostring(E))end local F={}
local G=0 for H,I in C.rows do if I:shown()then local J=b.build(m,I)local K=r if
I.kind=='divider'then K=28 elseif I.kind=='label'then local L=math.ceil(d.width(
'text',I.label,16)/(p-48))K=if I.spec.wrap then L*21+12 else 32 end J.root.
Position=UDim2.fromOffset(0,G)J.root.Size=UDim2.new(1,0,0,K)J.root.Parent=z G+=K
+3 table.insert(F,J)end end z.CanvasSize=UDim2.fromOffset(0,G)local H=math.min(G
,q)z.Size=UDim2.new(1,-40,0,H)local I=x+H+12 local J=c('TextButton',{Position=
UDim2.fromOffset(20,I),Size=UDim2.new(1,-40,0,54),BackgroundTransparency=0,
TextSize=28,Text=k.done or'Done',ZIndex=52,Parent=u})n:type(J,'display')n:paint(
J,'BackgroundColor3','text')n:paint(J,'TextColor3','base')local K=I+54+20 local
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
'sottUI: fonts unavailable: '..tostring(l))end return j end return c end
function a.r()local b=a.cache.r if not b then b={c=__modImpl()}a.cache.r=b end
return b.c end end do local function __modImpl()local b=a.f()local c={}local 
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
=600 local k=8 local l=2 local m=20 local n=14 local o=40 local p=16 local q=40
local r=22 local s=148 local t=60 local u=84 local v=0 local w=0 local x=66
local y=360 local z=110 local A=24 local B=28 local C={toggle=4,button=4,key=4,
color=4,slider=4,dropdown=4,stat=3,input=8}local function needs(D)local E=D.kind
if E=='stat'or E=='input'then return 0 end local F=26 if E=='slider'then F=b.
readoutWidth(D)+12 elseif E=='dropdown'then F=96 end for G,H in D.addons or{}do
if not H.spec.chipless then F+=if H.kind=='key'then 58 else 28 end end return d.
width('textMedium',D.label,g.NAME)*1.05+2*g.PAD+F end local function spanOf(D)if
D.kind=='label'and D.addons then return 4 end return C[D.kind]end local D={}D.
__index=D local function textHeight(E,F)if E.kind=='divider'then return if E.
label==''then 8 else 28 end if not E.spec.wrap then return 32 end if E._measured
then return E._measured end local G=math.max(math.floor(F/7.6),10)local H=string
.gsub(E.label,'<[^>]+>','')return math.ceil(#H/G)*21+12 end function D.nextId(E)
E._ids+=1 return E._ids end function D._register(E,F,G)F._relayout=function()E:
_invalidate()end E.window:_registerElement(F,E,G)end function D._invalidate(E)if
E._dirty then return end E._dirty=true task.defer(function()E._dirty=false if
not E.destroyed then E:layout(not E._quiet)E._quiet=false end end)end function D
.section(E,F)local G=f.new(E,F)table.insert(E.sections,G)E:_invalidate()return G
end function D.tabset(E)local F=f.new(E,'')F.tabNames={}F.activeTab=1 table.
insert(E.sections,F)local G={}function G.tab(H,I)table.insert(F.tabNames,I)local
J=#F.tabNames local K=F:when(function()return F.activeTab==J end)K.title=I local
L=E._headers[F]if L then L:Destroy()E._headers[F]=nil end E:_invalidate()return
K end return G end function D.tabs(E,F)local G=E:tabset()local H={}for I,J in F
do table.insert(H,G:tab(J))end return H end function D.hero(E,F)E._hero=F E:
_invalidate()local G=E._heroView return{set=function(H,I,J)F.title=I or F.title
F.text=J or F.text local K=E._heroView or G if K then K.refresh()end end}end
local function buildHero(E)local F=E.window.ctx local G=F.theme local H=E._hero
local I=c('Frame',{Name='Hero',Parent=E.canvas})local J=c('Frame',{Size=UDim2.
fromOffset(s-16,s-16),BackgroundTransparency=0,ClipsDescendants=true,Parent=I})G
:paint(J,'BackgroundColor3','accent')if H.userId then c('ImageLabel',{Size=UDim2
.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,Image=string.format(
'rbxthumb://type=AvatarBust&id=%d&w=420&h=420',H.userId),Parent=J})end local K=
c('TextLabel',{Position=UDim2.fromOffset(s+2,16),Size=UDim2.new(1,-(s+2),0,68),
TextSize=64,TextTruncate=Enum.TextTruncate.AtEnd,Parent=I})G:type(K,'display')G:
paint(K,'TextColor3','text')local L=c('TextLabel',{Position=UDim2.fromOffset(s+2
,88),Size=UDim2.new(1,-(s+2),0,44),TextSize=17,TextWrapped=true,TextYAlignment=
Enum.TextYAlignment.Top,Parent=I})G:type(L,'text')G:paint(L,'TextColor3','muted'
)local M={root=I,refresh=function()K.Text=H.title L.Text=H.text or''end}M.
refresh()return M end local function buildHeader(E,F)local G=E.window.ctx local
H=G.theme local I=c('Frame',{Name='Header',Parent=E.canvas})if F.tabNames then
local J={}local K=0 for L,M in F.tabNames do local N=math.ceil(d.width(
'textMedium',M,18))+20 local O=c('TextButton',{Position=UDim2.fromOffset(K,0),
Size=UDim2.new(0,N,1,-8),TextSize=18,Text=M,TextXAlignment=Enum.TextXAlignment.
Left,Parent=I})H:type(O,'text',true)J[L]=O O.Activated:Connect(function()F.
activeTab=L for P,Q in J do H:paint(Q,'TextColor3',if P==F.activeTab then'text'
else'faint')end E:_invalidate()end)H:paint(O,'TextColor3',if L==F.activeTab then
'text'else'faint')K+=N end else local J=c('TextLabel',{Size=UDim2.new(1,0,1,-6),
TextSize=26,Text=F.title,Parent=I})H:type(J,'display')H:paint(J,'TextColor3',
'text')end return I end function D.layout(E,F)local G=E.frame if G==nil then
return end E._live=F==true and E._settled==true and E.active local H=E.window.
ctx.uiScale()local I=G.AbsoluteSize.X/H if I<1 then return end local J=I-2*m
local K=J<j local L=(J-(i-1)*k)/i local M=n local N={}if E._hero then table.
insert(N,{hero=true,x=m,y=M,width=J,height=s})M+=s end local O=false for P,Q in
E.sections do local R={}for S,T in Q.rows do if T:shown()then table.insert(R,T)
end end if#R>0 or Q.tabNames then if(Q.title~=''or Q.tabNames)and not Q.
masterElement then if O then M+=r-v end table.insert(N,{section=Q,x=m,y=M,width=
J,height=q})M+=q end local S=false local T,U={},0 local function flush()if#T==0
then return end local V,W=m,0 for X,Y in T do local Z=Y.span local _=Z*L+(Z-1)*k
local aa=Y.height W=math.max(W,aa)table.insert(N,{el=Y.el,x=V,y=M,width=_,height
=aa})V+=_+k end M+=W+k T,U={},0 end for aa,V in R do local W=spanOf(V)if W==nil
then flush()if V.kind=='divider'and V.label==''and S then continue end local X=
textHeight(V,J)table.insert(N,{el=V,x=m,y=M,width=J,height=X})M+=X+l elseif V.
spec.primary then flush()local X=if V.value==true then u else t table.insert(N,{
el=V,x=m,y=M,width=J,height=X})M+=X+k+w S=true else local X=math.min(if K then W
*2 else W,i)while X<i and needs(V)>X*L+(X-1)*k do X+=if K then i-X else 4 end if
U+X>i then flush()end S=false table.insert(T,{el=V,span=X,height=if V.kind==
'stat'then x else g.HEIGHT})U+=X end end flush()local aa=Q.masterElement~=nil
and#R==1 if aa then M+=v-w else M+=r end O=aa end end local aa=M-r+o G.
CanvasSize=UDim2.fromOffset(0,aa)E._contentHeight=aa E._placements=N E:
_applyPlacements()E:_materialize(true)E:_refreshThumb()E._live=false E._settled=
E._settled or E.active end local function growTo(aa,E,F,G)if aa._grow==nil then
aa._grow=aa:own(e.prop(aa.root,'Size',B))end aa._grow:to(UDim2.fromOffset(E,F),G
)end local function setSize(aa,E,F)local G=UDim2.fromOffset(E,F)if aa._grow then
aa._grow:snap(G)else aa.root.Size=G end end function D._applyPlacements(aa)local
E={}for F,G in aa._placements do if G.hero then if aa._heroView then aa.
_heroView.root.Position=UDim2.fromOffset(G.x,G.y)aa._heroView.root.Size=UDim2.
fromOffset(G.width,G.height)end elseif G.section then E[G.section]=true local H=
aa._headers[G.section]if H then H.Visible=true H.Position=UDim2.fromOffset(G.x,G
.y)H.Size=UDim2.fromOffset(G.width,G.height)end else E[G.el]=true local H=aa.
_views[G.el]if H then aa:_place(H,G)end end end for F,G in aa._headers do if not
E[F]then G.Visible=false end end for F,G in aa._views do if not E[F]and G.root.
Visible and not G._folding then if aa._live then G._folding=true growTo(G,G.root
.Size.X.Offset,0,function()G._folding=false G.root.Visible=false end)else G.root
.Visible=false end end end end function D._place(aa,E,F)local G=E.root local H=
UDim2.fromOffset(F.x,F.y)local I=aa._live local J=I and not G.Visible local K=E.
_folding==true E._folding=false G.Visible=true if J then setSize(E,F.width,0)
growTo(E,F.width,F.height)elseif K then growTo(E,F.width,F.height)elseif I and E
._grow==nil and G.Size.Y.Offset~=F.height then growTo(E,F.width,F.height)elseif
I and E._grow and E._grow.target.Y.Offset~=F.height then growTo(E,F.width,F.
height)else setSize(E,F.width,F.height)end if I and not J and G.Position~=H then
if E._slide==nil then E._slide=E:own(e.prop(G,'Position',B))end E._slide:to(H)
elseif E._slide then E._slide:snap(H)else G.Position=H end end function D.
_materialize(aa,E)local F=aa.frame local G=aa._placements if F==nil or G==nil or
not aa.active then return end local H=aa.window.ctx.uiScale()local I=F.
CanvasPosition.Y/H if not E and aa._lastSync and math.abs(I-aa._lastSync)<y/3
then return end aa._lastSync=I local J,K=I-y,I+F.AbsoluteSize.Y/H+y for L,M in G
do local N=M.y if N+M.height>=J and N<=K then if M.hero then if aa._heroView==
nil then local O=buildHero(aa)O.root.Position=UDim2.fromOffset(M.x,N)O.root.Size
=UDim2.fromOffset(M.width,M.height)aa._heroView=O end elseif M.section then if
aa._headers[M.section]==nil then local O=buildHeader(aa,M.section)O.Position=
UDim2.fromOffset(M.x,N)O.Size=UDim2.fromOffset(M.width,M.height)aa._headers[M.
section]=O end elseif aa._views[M.el]==nil then local O,P=xpcall(b.build,debug.
traceback,aa.window.ctx,M.el)if O then P.root.Position=UDim2.fromOffset(M.x,N)P.
root.Size=UDim2.fromOffset(M.width,if aa._live then 0 else M.height)P.root.
Parent=aa.canvas aa._views[M.el]=P if aa._live then growTo(P,M.width,M.height)
end else warn('sottUI: tile '..tostring(M.el.id)..' failed: '..tostring(P))end
end end end end function D._refreshThumb(aa)local E=aa.thumb if E==nil then
return end local F=aa.window.ctx.uiScale()local G=aa.frame.AbsoluteSize.Y/F
local H=aa._contentHeight or 0 if H<=G+1 or not aa.active then E.Visible=false
return end E.Visible=true local I=math.max(G*G/H,40)local J=G-I-p local K=aa.
frame.CanvasPosition.Y/F/math.max(H-G,1)E.Size=UDim2.new(0,3,0,I)E.Position=
UDim2.new(1,-6,0,K*J)end function D.scrollTo(aa,E,F)local G=aa.frame if G==nil
then return end local H=aa.window.ctx.uiScale()local I=math.max((aa.
_contentHeight or 0)-G.AbsoluteSize.Y/H,0)local J=math.clamp(E,0,I)aa.
_scrollTarget=J if F then aa._scroll:snap(J)else aa._scroll:to(J)end end
function D.wheel(aa,E)if aa.frame==nil or aa.frame.ScrollingEnabled then return
end local F=aa._scrollTarget or aa.frame.CanvasPosition.Y/aa.window.ctx.uiScale(
)aa:scrollTo(F-E*z)end function D.rowY(aa,E)if aa._placements==nil then aa:
layout()end for F,G in aa._placements or{}do if G.el==E then return G.y end end
return nil end function D.viewOf(aa,E)return aa._views[E]end function D.mount(aa
,E)if aa.frame then return end local F=aa.window.ctx local G=c('ScrollingFrame',
{Name=aa.name,Size=UDim2.fromScale(1,1),Visible=false,ScrollingEnabled=F.touch,
Parent=E})local H=c('Frame',{Name='Canvas',Size=UDim2.fromScale(1,1),Parent=G})
local I=c('Frame',{Name='Thumb',BackgroundTransparency=0,Visible=false,ZIndex=5,
Parent=E})F.theme:paint(I,'BackgroundColor3','lineStrong')aa.frame=G aa.canvas=H
aa.thumb=I aa._scroll=e.new(0,A,function(J)G.CanvasPosition=Vector2.new(0,J*F.
uiScale())end)G:GetPropertyChangedSignal('CanvasPosition'):Connect(function()aa:
_materialize()aa:_refreshThumb()end)local J=0 G:GetPropertyChangedSignal(
'AbsoluteSize'):Connect(function()local K=G.AbsoluteSize.X if K~=J then J=K aa.
_quiet=true aa:_invalidate()else aa:_materialize(true)aa:_refreshThumb()end end)
end function D.setActive(aa,E)aa.active=E if aa.frame then aa.frame.Visible=E if
not E then aa.thumb.Visible=false end end if E then aa:layout()end end function
D.destroy(aa)aa.destroyed=true for E,F in aa._views do F.destroy()end aa._views=
{}if aa._scroll then aa._scroll:destroy()end if aa.frame then aa.frame:Destroy()
aa.thumb:Destroy()end end function h.new(aa,E)return setmetatable({name=E,window
=aa,sections={},active=false,destroyed=false,_ids=0,_dirty=false,_headers={},
_views={},_placements=nil},D)end return h end function a.y()local aa=a.cache.y
if not aa then aa={c=__modImpl()}a.cache.y=aa end return aa.c end end do local 
function __modImpl()local aa=a.f()local b=a.b()local c=a.h()local d={}local e=
600 local f=46 local g=68 local h=7 local i=34 local j=48 local function 
describe(k)local l=k._pageName or''if k.kind=='toggle'then return(if k.value
then'On, 'else'Off, ')..l end if k.kind=='slider'then return tostring(k.value)..
(k.spec.suffix or'')..', '..l end if k.kind=='dropdown'and not k.spec.multi and
k.value~=nil then return tostring((k.spec.display or tostring)(k.value))..', '..
l end return l end function d.new(k,l,m,n)local o=k.theme local p={}local q=
false local r,s,t,u local v={}local w={}local x=1 local function close()if not q
then return end q=false r:Destroy()local y,z=s,t z.speed=j z:to(UDim2.
fromOffset(e,0),function()z:destroy()y:Destroy()end)table.clear(w)end local 
function draw()if not q then return end for y,z in w do local A=v[y]if A then z.
root.Visible=true z.name.Text=A.label z.where.Text=describe(A)z.root.
BackgroundTransparency=if y==x then 0 else 1 o:paint(z.name,'TextColor3',if y==x
then'onAccent'else'text')o:paint(z.where,'TextColor3',if y==x then'onAccent'else
'muted')else z.root.Visible=false end end local y=math.min(#v,h)local z=g+(if y>
0 then y*f+10 else 0)t:to(UDim2.fromOffset(e,z))end local function run(y)if y==
nil then return end close()if y.kind=='toggle'and not y.disabled then y:set(not
y.value)k.notify({title=y.label,text=if y.value then'On'else'Off',seconds=2})
else n(y)end end local function query()local y=u.Text if y==''then v={}for z,A
in m()do if A.kind=='toggle'and A.value==true then table.insert(v,A)if#v==h then
break end end end else v=c.settings(y,m(),h)end x=1 draw()end function p.toggle(
y)if q then close()return end q=true local z=l.AbsoluteSize r=aa('TextButton',{
Size=UDim2.fromScale(1,1),BackgroundTransparency=0.45,BackgroundColor3=Color3.
new(0,0,0),ZIndex=40,Parent=l})r.MouseButton1Down:Connect(close)s=aa('Frame',{
Name='Palette',Position=UDim2.fromOffset(math.floor((z.X-e)/2),math.floor(z.Y*
0.22)),Size=UDim2.fromOffset(e,0),BackgroundTransparency=0,ClipsDescendants=true
,Active=true,ZIndex=41,Parent=l})o:paint(s,'BackgroundColor3','surface')local A=
aa('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=s})o:paint(A,
'Color','lineStrong')t=b.prop(s,'Size',i)u=aa('TextBox',{Position=UDim2.
fromOffset(18,0),Size=UDim2.new(1,-36,0,g),TextSize=36,Text='',PlaceholderText=
'Find a setting',ZIndex=42,Parent=s})o:type(u,'display')o:paint(u,'TextColor3',
'text')o:paint(u,'PlaceholderColor3','faint')for B=1,h do local C=aa(
'TextButton',{Position=UDim2.fromOffset(6,g+(B-1)*f+2),Size=UDim2.new(1,-12,0,f)
,Visible=false,ZIndex=42,Parent=s})o:paint(C,'BackgroundColor3','accent')local D
=aa('TextLabel',{Position=UDim2.fromOffset(12,0),Size=UDim2.new(0.6,-12,1,0),
TextSize=16,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=43,Parent=C})o:type(D,
'text',true)o:paint(D,'TextColor3','text')local E=aa('TextLabel',{AnchorPoint=
Vector2.new(1,0),Position=UDim2.new(1,-12,0,0),Size=UDim2.new(0.4,-12,1,0),
TextSize=16,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.
TextXAlignment.Right,ZIndex=43,Parent=C})o:type(E,'text')o:paint(E,'TextColor3',
'faint')w[B]={root=C,name=D,where=E}C.MouseEnter:Connect(function()if x~=B then
x=B draw()end end)C.Activated:Connect(function()run(v[B])end)end u:
GetPropertyChangedSignal('Text'):Connect(query)u.FocusLost:Connect(function(B)if
B then run(v[x])end end)query()u:CaptureFocus()end function p.isOpen(y)return q
end p.close=close function p.key(y,z)if not q then return false end if z==
'Escape'then close()return true end if z=='Down'or z=='Up'then if#v>0 then x=
math.clamp(x+(if z=='Down'then 1 else-1),1,#v)draw()end return true end return
false end return p end return d end function a.z()local aa=a.cache.z if not aa
then aa={c=__modImpl()}a.cache.z=aa end return aa.c end end do local function 
__modImpl()local aa=a.f()local b=UDim2.fromOffset(16,72)local c=44 return
function(d,e,f)local g=aa('TextButton',{Name='Open',Position=b,Size=UDim2.
fromOffset(c,c),BackgroundTransparency=0,TextSize=24,Text='s',Visible=false,
ZIndex=50,Parent=d})e:type(g,'display')e:paint(g,'BackgroundColor3','accent')e:
paint(g,'TextColor3','onAccent')g.Activated:Connect(f)return g end end function
a.A()local aa=a.cache.A if not aa then aa={c=__modImpl()}a.cache.A=aa end return
aa.c end end do local function __modImpl()local aa=a.n()local b={}local function 
rgb(c)return Color3.fromRGB(bit32.band(bit32.rshift(c,16),255),bit32.band(bit32.
rshift(c,8),255),bit32.band(c,255))end local c={base=rgb(0x7100d),surface=rgb(
0x141c18),raised=rgb(0x1e2b25),line=rgb(0x1a2d27),lineStrong=rgb(0x2f4a40),text=
rgb(0xebe8da),muted=rgb(0xb4c2b8),faint=rgb(0x5f756b),accent=rgb(0x7ee0c4),
accentHover=rgb(0x9bebd4),accentDim=rgb(0x1f4a3e),onAccent=rgb(0xb1a13),danger=
rgb(0xe5604d)}local d='rbxasset://fonts/families/BuilderSans.json'local e=
'rbxasset://fonts/families/RobotoCondensed.json'local f={}f.__index=f function b
.defaults()return table.clone(c)end function b.new(g)local h=(b.defaults())for i
,j in(g or{})do h[i]=j end local i={tokens=h,fonts={text=d,display=e},changed=aa
.new(),_paints={},_types={},_count=0}return((setmetatable(i,f)))end local g=2000
local function sweep(h)for i in h._paints do if i.Parent==nil then h._paints[i]=
nil h._types[i]=nil end end for i in h._types do if i.Parent==nil then h._types[
i]=nil end end end function f.paint(h,i,j,k)local l=h._paints[i]if l==nil then l
={}h._paints[i]=l h._count+=1 if h._count%g==0 then task.defer(sweep,h)end end l
[j]=k i[j]=h.tokens[k]end function f.face(h,i,j)if i=='display'then return Font.
new(h.fonts.display,Enum.FontWeight.ExtraBold)end return Font.new(h.fonts.text,
if j then Enum.FontWeight.Medium else Enum.FontWeight.Regular)end function f.
type(h,i,j,k)h._types[i]={family=j,medium=k==true}i.FontFace=h:face(j,k)end
function f.forget(h,i)h._paints[i]=nil h._types[i]=nil end function f.apply(h,i)
for j,k in i do h.tokens[j]=k end for j,k in h._paints do for l,m in k do pcall(
function()j[l]=h.tokens[m]end)end end h.changed:fire()end function f.setFonts(h,
i,j)h.fonts.text=i or h.fonts.text h.fonts.display=j or h.fonts.display for k,l
in h._types do pcall(function()k.FontFace=h:face(l.family,l.medium)end)end end
return b end function a.B()local aa=a.cache.B if not aa then aa={c=__modImpl()}a
.cache.B=aa end return aa.c end end do local function __modImpl()local aa=a.b()
local b={}local c=26 function b.new(d)local e={}return function(f,g,h,i)local j=
e[f]if j==nil then j={}e[f]=j end local k=j[g]if k==nil then k=aa.prop(f,g,i or
c)j[g]=k end k:to(d.tokens[h])end end return b end function a.C()local aa=a.
cache.C if not aa then aa={c=__modImpl()}a.cache.C=aa end return aa.c end end do
local function __modImpl()local aa=a.q()local b=a.a()local c=a.r()local d=a.s()
local e=a.u()local f=a.v()local g=a.t()local h=a.f()local i=a.b()local j=a.w()
local k=a.x()local l=a.y()local m=a.z()local n=a.p()local o=a.A()local p=a.n()
local q=a.B()local r=a.C()local s={}local t='main'local u=
[[https://raw.githubusercontent.com/interestng/sottUI/%s/fonts/]]local v=64
local w=34 local x=24 local y=860 local z=26 local A=22 local B=Vector2.new(760,
620)local C=Vector2.new(560,400)local D=30 local E=12 local F=20 local G=30
local H=22 local I=26 local J=34 local K=17 local L=12 local M={}M.__index=M
local function randomName()local N=table.create(L)for O=1,L do N[O]=string.char(
math.random(97,122))end return table.concat(N)end local function encode(N)return
b.service('HttpService'):JSONEncode(N)end local function decode(N)local O,P=
pcall(function()return b.service('HttpService'):JSONDecode(N)end)return if O
then P else nil end function M._registerElement(N,O,P,Q)O._pageName=P.name O.
_page=P if Q then if N.elements[O.id]then error(
'sottUI: element id used twice: '..O.id,3)end N.elements[O.id]=O end if O.kind~=
'divider'and O.kind~='label'and O.kind~='stat'then table.insert(N.ordered,O)end
end function M._syncMarker(N,O)local P=N._navItems[N.current]if P==nil then
return end local Q=N._scale.Scale local R=N._navList local S=(P.AbsolutePosition
.X-R.AbsolutePosition.X)/Q local T=S+P.AbsoluteSize.X/Q local U=N._navClip.
AbsoluteSize.X/Q local V=N._navScroll.target if T+V>U then V=U-T end if S+V<0
then V=-S end V=math.min(V,0)if O then N._edgeLeft:snap(S)N._edgeRight:snap(T)N.
_navScroll:snap(V)return end local W=T>N._edgeRight.target N._edgeLeft.speed=if
W then K else J N._edgeRight.speed=if W then J else K N._edgeLeft:to(S)N.
_edgeRight:to(T)N._navScroll:to(V)end function M.page(N,O)local P=l.new(N,O)
table.insert(N.pages,P)local Q=#N.pages local R=N.ctx.theme local S=h(
'TextButton',{Name=O,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.new(0,0,1,0),
TextSize=w,Text=O,LayoutOrder=Q,Parent=N._navList})R:type(S,'display')R:paint(S,
'TextColor3','faint')N._navItems[Q]=S S.Activated:Connect(function()N:show(Q)end
)S.MouseEnter:Connect(function()if N.current~=Q then N.ctx.tint(S,'TextColor3',
'muted')end end)S.MouseLeave:Connect(function()if N.current~=Q then N.ctx.tint(S
,'TextColor3','faint')end end)P:mount(N._pageHost)if N.current==nil then N:show(
Q,true)end return P end function M.show(N,O,P)local Q=N.pages[O]if Q==nil or N.
current==O then return end N.ctx.hover.clear()N.ctx.popover:close()N.keys:
cancel()local R=N.ctx.tint local S=N.pages[N.current]if S then S:setActive(false
)R(N._navItems[N.current],'TextColor3','faint')end local T=N.current==nil or O>N
.current N.current=O R(N._navItems[O],'TextColor3','text')Q:setActive(true)N:
_syncMarker(P)N:_saveState()if P then return end local U=if T then 1 else-1 N.
_pageSlide:snap(UDim2.fromOffset(I*U,0))N._pageSlide:to(UDim2.new())N._wipe.
Visible=true N._wipeEdge.AnchorPoint=Vector2.new(if T then 1 else 0,0)N.
_wipeEdge.Position=UDim2.fromScale(if T then 1 else 0,0)N._wipeAt:snap(UDim2.
fromScale(0,0))N._wipeAt:to(UDim2.fromScale(-1.02*U,0),function()N._wipe.Visible
=false end)end function M.showPage(N,O)for P,Q in N.pages do if Q.name==O then N
:show(P)return end end end function M.reveal(N,O)local P=O._page if P==nil then
return end if not N.isOpen then N:setOpen(true)end N:showPage(P.name)local Q=O.
host or O local R=O.section and(O.section._root or O.section)if R and R.
masterElement and R.masterElement.value~=true and Q~=R.masterElement then R.
peeking=true local S=P:viewOf(R.masterElement)if S then S.refresh()end end P:
layout()local S=P:rowY(Q)if S then P:scrollTo(S-60)task.delay(0.26,function()
local T=P:viewOf(Q)if T and T.root.Parent then T:flash()end end)end end function
M._targetSize(N)return if N.collapsed then UDim2.new(1,0,0,v)else UDim2.
fromScale(1,1)end function M.setOpen(N,O)if N.isOpen==O or N.destroyed then
return end N.isOpen=O if N._opener then N._opener.Visible=not O end N.ctx.hover.
clear()N.ctx.popover:close()N._palette.close()N.ctx.tooltip:hide()N.keys:cancel(
)if not O and N._dialogClose then N._dialogClose()end N._shutterEdge.Visible=
true if O then N._root.Visible=true N._modal.Visible=true N:_guardCursor(true)N.
_shutter.speed=F N._shutter:to(N:_targetSize(),function()N._shutterEdge.Visible=
false end)else N._modal.Visible=false N:_guardCursor(false)N._shutter.speed=G N.
_shutter:to(UDim2.new(1,0,0,0),function()N._shutterEdge.Visible=false if not N.
isOpen then N._root.Visible=false end end)end N.visibilityChanged:fire(O)end
function M._guardCursor(N,O)local P=b.service('UserInputService')if O then N.
_gameCursor=P.MouseIconEnabled P.MouseIconEnabled=true if N._cursorGuard==nil
then N._cursorGuard=P:GetPropertyChangedSignal('MouseIconEnabled'):Connect(
function()if not P.MouseIconEnabled then N._gameCursor=false P.MouseIconEnabled=
true end end)end else if N._cursorGuard then N._cursorGuard:Disconnect()N.
_cursorGuard=nil end if N._gameCursor~=nil then P.MouseIconEnabled=N._gameCursor
N._gameCursor=nil end end end function M.toggle(N)N:setOpen(not N.isOpen)end
function M.collapse(N,O)N.collapsed=O N._shutter:to(N:_targetSize())N._grip.
Visible=not O N:_saveState()end function M.notify(N,O)if N.destroyed then return
end N.ctx.notify(O)end function M.setTheme(N,O)N.ctx.theme:apply(O)end function
M.setScale(N,O)N._scale.Scale=math.clamp(O,0.7,1.5)N:_clamp()N:_saveState()end
function M.setSubtitle(N,O)N._subtitleLabel.Text=O end function M._clamp(N)local
O=N._gui.AbsoluteSize local P=N.size*N._scale.Scale local Q=math.clamp(N.
position.X,0,math.max(O.X-P.X,0))local R=math.clamp(N.position.Y,0,math.max(O.Y-
P.Y,0))N.position=Vector2.new(Q,R)N._root.Position=UDim2.fromOffset(Q,R)end
function M._saveState(N)local O=N._files if O==nil or N._stateFile==nil or N.
_stateQueued then return end N._stateQueued=true task.delay(0.5,function()N.
_stateQueued=false if N.destroyed then return end local P=N.pages[N.current]O.
write(N._stateFile,encode({x=N.position.X,y=N.position.Y,w=N.size.X,h=N.size.Y,
page=P and P.name,scale=N._scale.Scale,collapsed=N.collapsed}))end)end function
M.restorePage(N)local O=N._savedPage if O then N._savedPage=nil for P,Q in N.
pages do if Q.name==O then N:show(P,true)return end end end end function M.
dialog(N,O,P)if N.destroyed then return false end aa.open(N,O,P)return true end
function M.find(N,O)return N.elements[O]end function M.snapshot(N)local O={}for
P,Q in N.elements do if Q.saved then local R=Q.value if Q.kind=='color'then R={
hex=R.color:ToHex(),alpha=R.alpha}elseif Q.kind=='key'then R={key=R.key,mode=R.
mode,modifiers=R.modifiers,toggled=Q.toggled==true}end O[P]=R end end return O
end function M.restore(N,O)for P,Q in O do local R=N.elements[P]if R and R.saved
then if R.kind=='color'and type(Q)=='table'then R:set({color=Color3.fromHex(Q.
hex or'ffffff'),alpha=Q.alpha})elseif R.kind=='key'and type(Q)=='table'then R:
set(Q)R.toggled=Q.toggled==true else R:set(Q)end end end end function M.destroy(
N)if N.destroyed then return end N.destroyed=true N:_guardCursor(false)N.ctx.
notifications:destroy()for O,P in N.pages do P:destroy()end N.ctx.input:destroy(
)N._maid:clean()N.visibilityChanged:clear()if N._registry and N._registry.
current==N then N._registry.current=nil end end local function headerButton(N,O,
P,Q)local R=h('TextButton',{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,
P,0.5,0),Size=UDim2.fromOffset(44,v),BackgroundTransparency=1,Parent=O})N.theme:
paint(R,'BackgroundColor3','raised')local S=Q(R,'muted')S.AnchorPoint=Vector2.
new(0.5,0.5)S.Position=UDim2.fromScale(0.5,0.5)local T=i.prop(R,
'BackgroundTransparency',28)R.MouseEnter:Connect(function()T:to(0)end)R.
MouseLeave:Connect(function()T:to(1)end)return R end function s.new(N)local O=N.
_registry if O and O.current then O.current:destroy()end local P=g.new()local Q=
q.new(N.theme)local R=e.new()local S=b.service('UserInputService')local T=N.
touch==true or(S.TouchEnabled and not S.MouseEnabled)local U=h('ScreenGui',{Name
=randomName(),IgnoreGuiInset=true,ResetOnSpawn=false,ZIndexBehavior=Enum.
ZIndexBehavior.Sibling,DisplayOrder=N.displayOrder or 10000})b.protect(U)U.
Parent=b.guiParent()P:add(U)local V=b.files()local W=N.folder or'sottui'local X=
N.stateFile or(W..'/window.json')local Y=nil if V then V.folder(W)local Z=V.
read(X)Y=Z and decode(Z)end if type(Y)~='table'then Y={}end local Z=U.
AbsoluteSize local _=Vector2.new(math.clamp(tonumber(Y.w)or B.X,C.X,math.max(Z.X
,C.X)),math.clamp(tonumber(Y.h)or B.Y,C.Y,math.max(Z.Y,C.Y)))local ab=tonumber(Y
.scale)or(if Z.X<800 then 0.8 else 1)local ac=Vector2.new(tonumber(Y.x)or math.
floor((Z.X-_.X*ab)/2),tonumber(Y.y)or math.floor((Z.Y-_.Y*ab)/2))local ad=h(
'Frame',{Name='Root',Size=UDim2.fromOffset(_.X,_.Y),Position=UDim2.fromOffset(ac
.X,ac.Y),Parent=U})local ae=h('UIScale',{Scale=ab,Parent=ad})local af=h('Frame',
{Name='Clip',Size=UDim2.new(1,0,0,0),BackgroundTransparency=0,ClipsDescendants=
true,Active=true,Parent=ad})Q:paint(af,'BackgroundColor3','base')local ag=h(
'Frame',{Name='Layer',Size=UDim2.fromScale(1,1),ZIndex=100,Parent=U})local ah=h(
'TextButton',{Name='Modal',Size=UDim2.fromOffset(0,0),Modal=true,Visible=false,
Parent=ad})local ai=h('TextButton',{Name='Bar',Size=UDim2.new(1,0,0,v),Parent=af
})local aj=h('TextLabel',{AutomaticSize=Enum.AutomaticSize.X,Position=UDim2.
fromOffset(20,0),Size=UDim2.fromOffset(0,v),TextSize=z,Text=N.title or'sottoro',
Parent=ai})Q:type(aj,'display')Q:paint(aj,'TextColor3','accent')local ak=h(
'Frame',{Name='NavClip',Size=UDim2.new(1,0,0,v),ClipsDescendants=true,Parent=af}
)local al=h('Frame',{Name='NavRail',Size=UDim2.fromScale(1,1),Parent=ak})local
am=h('Frame',{Name='NavList',AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.new(0
,0,1,0),Parent=al})h('UIListLayout',{FillDirection=Enum.FillDirection.Horizontal
,Padding=UDim.new(0,A),SortOrder=Enum.SortOrder.LayoutOrder,Parent=am})local an=
h('Frame',{AnchorPoint=Vector2.new(1,0),Position=UDim2.fromScale(1,0),Size=UDim2
.new(0,36,1,0),BackgroundTransparency=0,Visible=false,ZIndex=3,Parent=ak})Q:
paint(an,'BackgroundColor3','base')h('UIGradient',{Transparency=NumberSequence.
new(1,0),Parent=an})local ao=h('Frame',{Name='Marker',AnchorPoint=Vector2.new(0,
1),Position=UDim2.new(0,0,1,0),Size=UDim2.new(0,0,0,4),BackgroundTransparency=0,
ZIndex=2,Parent=al})Q:paint(ao,'BackgroundColor3','accent')local ap=h('Frame',{
Position=UDim2.new(0,0,0,v-1),Size=UDim2.new(1,0,0,1),BackgroundTransparency=0,
Parent=af})Q:paint(ap,'BackgroundColor3','line')local aq=h('Frame',{Name='Body',
Position=UDim2.fromOffset(0,v),Size=UDim2.new(1,0,1,-v),ClipsDescendants=true,
Parent=af})local ar=h('Frame',{Name='Pages',Size=UDim2.fromScale(1,1),Parent=aq}
)local as=h('Frame',{Name='Fade',AnchorPoint=Vector2.new(0,1),Position=UDim2.
fromScale(0,1),Size=UDim2.new(1,-E,0,D),BackgroundTransparency=0,ZIndex=7,Parent
=aq})Q:paint(as,'BackgroundColor3','base')h('UIGradient',{Rotation=90,
Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),
NumberSequenceKeypoint.new(1,0)}),Parent=as})local at=h('Frame',{Name='Wipe',
Size=UDim2.fromScale(1,1),BackgroundTransparency=0,Visible=false,ZIndex=8,Parent
=aq})Q:paint(at,'BackgroundColor3','base')local au=h('Frame',{Size=UDim2.new(0,8
,1,0),BackgroundTransparency=0,ZIndex=9,Parent=at})Q:paint(au,'BackgroundColor3'
,'accent')local av=h('Frame',{AnchorPoint=Vector2.new(0,1),Position=UDim2.
fromScale(0,1),Size=UDim2.new(1,0,0,4),BackgroundTransparency=0,Visible=false,
ZIndex=12,Parent=af})Q:paint(av,'BackgroundColor3','accent')local aw=h(
'TextButton',{Name='Grip',AnchorPoint=Vector2.new(1,1),Position=UDim2.fromScale(
1,1),Size=UDim2.fromOffset(20,20),ZIndex=6,Parent=af})for ax,ay in{{UDim2.new(1,
-3,1,-3),UDim2.fromOffset(10,2)},{UDim2.new(1,-3,1,-3),UDim2.fromOffset(2,10)}}
do local az=h('Frame',{AnchorPoint=Vector2.new(1,1),Position=ay[1],Size=ay[2],
BackgroundTransparency=0,ZIndex=7,Name='Tick'..ax,Parent=aw})Q:paint(az,
'BackgroundColor3','lineStrong')end local ax=setmetatable({ctx=nil,pages={},
elements={},ordered={},current=nil,isOpen=false,collapsed=Y.collapsed==true,
destroyed=false,size=_,position=ac,visibilityChanged=p.new(),_maid=P,_gui=U,
_root=ad,_clip=af,_layer=ag,_modal=ah,_scale=ae,_navClip=ak,_navList=am,
_navItems={},_pageHost=ar,_wipe=at,_wipeEdge=au,_shutterEdge=av,_grip=aw,_files=
V,_stateFile=X,_savedPage=Y.page,_dialogIds=0,_registry=O},M)if O then O.current
=ax end local ay={theme=Q,input=R,touch=T,glyph=d.new(Q),tint=r.new(Q),uiScale=
function()return ae.Scale end,popoverTop=function()return ax.position.Y+v*ae.
Scale end,isShowing=function(ay)if not ax.isOpen then return false end local az=
ay._page or(ay.host and ay.host._page)return az==nil or az==ax.pages[ax.current]
end,setScrollLocked=function(ay)local az=ax.pages[ax.current]if az and az.frame
and T then az.frame.ScrollingEnabled=not ay end end}ax.ctx=ay ay.popover=k.
popover(ay,ag)ay.tooltip=k.tooltip(ay,ag)ay.hover=k.hover(ay)ay.notifications=j.
new(ay,ag)ay.notify=function(az)ay.notifications:show(az)end ax.keys=f.new(R,b,
function()return ax.isOpen end)ay.keys=ax.keys local function drawMarker()local
az,aA=ax._markerLeft,ax._markerRight ao.Position=UDim2.new(0,az,1,0)ao.Size=
UDim2.new(0,math.max(aA-az,0),0,4)end ax._markerLeft,ax._markerRight=0,0 ax.
_edgeLeft=P:add(i.new(0,J,function(az)ax._markerLeft=az drawMarker()end))ax.
_edgeRight=P:add(i.new(0,J,function(az)ax._markerRight=az drawMarker()end))ax.
_navScroll=P:add(i.new(0,J,function(az)al.Position=UDim2.fromOffset(az,0)end))ax
._pageSlide=P:add(i.prop(ar,'Position',H))ax._wipeAt=P:add(i.prop(at,'Position',
H))ax._shutter=P:add(i.prop(af,'Size',F))ax._palette=m.new(ay,ag,function()
return ax.ordered end,function(az)ax:reveal(az)end)local az=headerButton(ay,ai,0
,function(az,aA)return ay.glyph.cross(az,aA)end)az.Activated:Connect(function()
ax:setOpen(false)end)local aA=headerButton(ay,ai,-44,function(aA,aB)return ay.
glyph.dash(aA,aB)end)aA.Activated:Connect(function()ax:collapse(not ax.collapsed
)end)local aB=h('TextButton',{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(
1,-96,0.5,0),Size=UDim2.fromOffset(64,v),TextSize=17,Text='Search',
TextXAlignment=Enum.TextXAlignment.Right,Parent=ai})Q:type(aB,'text',true)Q:
paint(aB,'TextColor3','muted')aB.MouseEnter:Connect(function()ay.tint(aB,
'TextColor3','text')end)aB.MouseLeave:Connect(function()ay.tint(aB,'TextColor3',
'muted')end)aB.Activated:Connect(function()ax._palette:toggle()end)local aC=h(
'TextLabel',{AutomaticSize=Enum.AutomaticSize.X,AnchorPoint=Vector2.new(1,0.5),
Position=UDim2.new(1,-176,0.5,0),Size=UDim2.fromOffset(0,v),TextSize=17,Text=N.
subtitle or'',TextXAlignment=Enum.TextXAlignment.Right,Parent=ai})Q:type(aC,
'text')Q:paint(aC,'TextColor3','faint')ax._subtitleLabel=aC local function 
fitBar()local aD=ae.Scale local aE=ad.AbsoluteSize.X/aD local aF=20+aj.
AbsoluteSize.X/aD+24 local aG=am.AbsoluteSize.X/aD local aH=176+aC.AbsoluteSize.
X/aD+20 aC.Visible=N.subtitle~=nil and aF+aG+aH<=aE local aI=if aC.Visible then
aH else 176 ak.Position=UDim2.fromOffset(aF,0)ak.Size=UDim2.new(1,-(aF+aI),0,v)
local aJ=if aE<y then x else w for aK,aL in ax._navItems do aL.TextSize=aJ end
an.Visible=am.AbsoluteSize.X/aD>aE-aF-aI local aK=math.ceil(aF+am.AbsoluteSize.X
/aD+aI)if aJ==x and aE<aK and aK*aD<=U.AbsoluteSize.X then ax.size=Vector2.new(
aK,ax.size.Y)ad.Size=UDim2.fromOffset(aK,math.floor(ax.size.Y))ax:_clamp()end ax
:_syncMarker(true)end ax._fitBar=fitBar aj:GetPropertyChangedSignal(
'AbsoluteSize'):Connect(fitBar)aC:GetPropertyChangedSignal('AbsoluteSize'):
Connect(fitBar)ad:GetPropertyChangedSignal('AbsoluteSize'):Connect(fitBar)am:
GetPropertyChangedSignal('AbsoluteSize'):Connect(fitBar)task.defer(fitBar)ai.
InputBegan:Connect(function(aD)local aE=aD.UserInputType if aE~=Enum.
UserInputType.MouseButton1 and aE~=Enum.UserInputType.Touch then return end
local aF=if aE==Enum.UserInputType.Touch then R:at(aD)else R:pointer()local aG=
ax.position R:capture(function(aH)ax.position=aG+(aH-aF)ax:_clamp()ax:
_saveState()end)end)aw.InputBegan:Connect(function(aD)local aE=aD.UserInputType
if aE~=Enum.UserInputType.MouseButton1 and aE~=Enum.UserInputType.Touch then
return end local aF=if aE==Enum.UserInputType.Touch then R:at(aD)else R:pointer(
)local aG=ax.size R:capture(function(aH)local aI=ae.Scale local aJ=aG+(aH-aF)/aI
local aK=(U.AbsoluteSize-ax.position)/aI ax.size=Vector2.new(math.clamp(aJ.X,C.X
,math.max(aK.X,C.X)),math.clamp(aJ.Y,C.Y,math.max(aK.Y,C.Y)))ad.Size=UDim2.
fromOffset(math.floor(ax.size.X),math.floor(ax.size.Y))ax:_saveState()end)end)R.
moved:connect(function(aD)ay.hover:verify(aD)end)R.wheel:connect(function(aD)if
not ax.isOpen or ay.popover:isOpen()or ax._palette:isOpen()then return end local
aE=ax.pages[ax.current]if aE==nil or aE.frame==nil then return end local aF=R:
pointer()local aG,aH=aE.frame.AbsolutePosition,aE.frame.AbsoluteSize if aF.X>=aG
.X and aF.Y>=aG.Y and aF.X<=aG.X+aH.X and aF.Y<=aG.Y+aH.Y then aE:wheel(aD)end
end)R.keyDown:connect(function(aD,aE)if aD.UserInputType~=Enum.UserInputType.
Keyboard then return end local aF=aD.KeyCode.Name if ax.keys:swallowed(aF)then
return end if ax._palette:key(aF)or ay.popover:key(aF)then return end if aF==
'Escape'and ax._dialogClose then ax._dialogClose()return end if aE or R:typing()
then return end if ax.isOpen and aF=='K'then if S:IsKeyDown(Enum.KeyCode.
LeftControl)or S:IsKeyDown(Enum.KeyCode.RightControl)then ax._palette:toggle()
end end end)P:add(U:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
ax:_clamp()end))P:add(Q.changed:connect(function()for aD,aE in ax.pages do for
aF,aG in aE._views do pcall(function()aG:retint()aG.refresh()end)end end end))if
T then local aD=h('TextButton',{Name='Reopen',Position=UDim2.fromOffset(16,80),
Size=UDim2.fromOffset(112,44),BackgroundTransparency=0,TextSize=22,Text=N.title
or'sottoro',Visible=false,Parent=U})Q:type(aD,'display')Q:paint(aD,
'BackgroundColor3','accent')Q:paint(aD,'TextColor3','onAccent')local aE=false aD
.InputBegan:Connect(function(aF)if aF.UserInputType~=Enum.UserInputType.Touch
then return end aE=false local aG=R:at(aF)local aH=aD.AbsolutePosition-U.
AbsolutePosition R:capture(function(aI)local aJ=aI-aG if aJ.Magnitude>8 then aE=
true aD.Position=UDim2.fromOffset(aH.X+aJ.X,aH.Y+aJ.Y)end end)end)aD.Activated:
Connect(function()if not aE then ax:setOpen(true)end end)ax.visibilityChanged:
connect(function(aF)aD.Visible=not aF end)end local aD=n.new({window=ax,nextId=
function()return 0 end,_register=function(aD,aE,aF)if aF then ax.elements[aE.id]
=aE end aE._pageName=''end,_invalidate=function()end},'')ax.menuKey=aD:key(
'__menu',{label='Menu',default=N.key or'RightShift',mode='Toggle',saved=false,
onPress=function()ax:toggle()end})local aE=b.service('RunService')i.setAttach(
function(aF)return aE.PreRender:Connect(aF)end)ax:_clamp()if N.fonts~=false and
V then P:add(task.defer(function()local aF=N.fontTag or t local aG=c.load(W..
'/fonts-'..aF,string.format(u,aF),encode)if not ax.destroyed and(aG.text or aG.
display)then Q:setFonts(aG.text,aG.display)end end))end if T then ax._opener=o(U
,Q,function()ax:setOpen(true)end)end if N.autoShow~=false then task.defer(
function()ax:setOpen(true)end)end return ax end function s.setVersion(ab)t=ab
end return s end function a.D()local aa=a.cache.D if not aa then aa={c=
__modImpl()}a.cache.D=aa end return aa.c end end end local aa=a.a()local ab=a.b(
)local ac=a.e()local ad=a.D()local ae='0.1.10'local function registry()local af=
aa.global('getgenv')local ag=if type(af)=='function'then af()else _G local ah=ag
.__sottui if type(ah)~='table'then ah={current=nil}ag.__sottui=ah end return ah
end local af={version=ae,motion=ab}ad.setVersion('v'..ae)function af.window(ag)
local ah=table.clone(ag or{})ah._registry=registry()return ad.new(ah)end
function af.current()return registry().current end function af.obsidian()return
ac.new(af)end return af