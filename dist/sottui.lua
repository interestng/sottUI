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
__modImpl()local b={}local c={display={0.236,0.309,0.471,0.656,0.6,0.96,0.713,
0.26,0.337,0.337,0.556,0.6,0.299,0.402,0.299,0.437,0.6,0.6,0.6,0.6,0.6,0.6,0.6,
0.6,0.6,0.6,0.319,0.319,0.6,0.6,0.6,0.493,0.899,0.672,0.663,0.642,0.689,0.6,
0.577,0.712,0.719,0.423,0.545,0.678,0.521,0.817,0.719,0.712,0.641,0.712,0.664,
0.611,0.58,0.689,0.638,0.949,0.655,0.632,0.599,0.329,0.437,0.329,0.6,0.559,0.6,
0.559,0.6,0.513,0.6,0.558,0.35,0.545,0.588,0.275,0.275,0.562,0.294,0.888,0.588,
0.563,0.6,0.6,0.393,0.499,0.374,0.588,0.524,0.819,0.544,0.524,0.502,0.363,0.376,
0.363,0.6},text={0.236,0.284,0.419,0.713,0.598,0.927,0.694,0.242,0.335,0.335,
0.45,0.6,0.272,0.399,0.272,0.383,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.292,
0.292,0.6,0.6,0.6,0.477,0.891,0.641,0.653,0.621,0.671,0.583,0.559,0.695,0.707,
0.4,0.51,0.634,0.501,0.812,0.707,0.708,0.606,0.708,0.64,0.581,0.572,0.678,0.609,
0.891,0.613,0.593,0.58,0.317,0.383,0.317,0.6,0.565,0.6,0.534,0.58,0.503,0.58,
0.549,0.324,0.528,0.568,0.25,0.25,0.527,0.272,0.873,0.568,0.56,0.58,0.58,0.367,
0.487,0.351,0.568,0.492,0.768,0.507,0.499,0.464,0.343,0.314,0.343,0.6},
textMedium={0.236,0.299,0.451,0.678,0.599,0.947,0.706,0.253,0.336,0.336,0.514,
0.6,0.288,0.401,0.288,0.416,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.308,0.308,
0.6,0.6,0.6,0.487,0.896,0.66,0.659,0.634,0.682,0.593,0.57,0.705,0.714,0.414,
0.531,0.66,0.513,0.815,0.714,0.711,0.627,0.711,0.655,0.599,0.577,0.685,0.627,
0.926,0.639,0.617,0.592,0.324,0.416,0.324,0.6,0.561,0.6,0.549,0.592,0.509,0.592,
0.555,0.34,0.538,0.58,0.265,0.265,0.548,0.285,0.882,0.58,0.562,0.592,0.592,0.383
,0.494,0.365,0.58,0.512,0.799,0.53,0.514,0.487,0.355,0.352,0.355,0.6},mono={0.6,
0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,
0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,
0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,
0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,
0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6}}function b.width(d,e,f)
local g=c[d]local h=0 for i=1,#e do local j=(string.byte(e,i))h+=g[j-31]or 0.5
end return h*f end return b end function a.j()local b=a.cache.j if not b then b=
{c=__modImpl()}a.cache.j=b end return b.c end end do local function __modImpl()
local b=a.f()local c=a.j()local d={}local e=24 local f=8 local g=12 local h=
'Press a key'local function display(i)local j=i.value if j==nil or j.key=='None'
or j.key=='Unknown'then return'Unset'end local k={}for l,m in j.modifiers or{}do
table.insert(k,m)end table.insert(k,j.key)local l=table.concat(k,'+')return if j
.mode and j.mode~='Toggle'then l..' '..string.lower(j.mode)else l end function d
.build(i,j)local k=i.theme local l=b('TextButton',{Name='Key',Size=UDim2.
fromOffset(52,38),BackgroundTransparency=1})local m=b('Frame',{AnchorPoint=
Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(1,-f,0,e),
ZIndex=4,Parent=l})b('UICorner',{CornerRadius=UDim.new(0,6),Parent=m})local n=b(
'UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=m})local o=b(
'TextLabel',{Size=UDim2.fromScale(1,1),TextSize=g,TextXAlignment=Enum.
TextXAlignment.Center,ZIndex=5,Parent=m})k:type(o,'mono')local p={root=l,width=
52}local q=false local r=false local function fit(s)local t=math.ceil(c.width(
'mono',s,g))+16+f l.Size=UDim2.fromOffset(math.max(t,44),38)p.width=l.Size.X.
Offset if p.onFit then p.onFit()end end local s=false local function ink()k:
paint(o,'TextColor3',if q then'accent'elseif r then'onAccent'else'muted')k:
paint(n,'Color',if q then'accent'elseif r then'onAccent'else'lineStrong')m.
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
local function __modImpl()local b=a.f()local c=a.b()local d={}d.PAD=12 d.HEIGHT=
38 d.NAME=14 d.RADIUS=8 local e=22 local f=40 local g=0.7 local h=26 local i=
0.97 local j=0.45 local k=0.28 local l={}l.__index=l function l.own(m,n)table.
insert(m._cleanups,function()n:destroy()end)return n end function l.onCleanup(m,
n)table.insert(m._cleanups,n)end local function baseColor(m)local n=m.ctx.theme.
tokens if m._lit then return if m._hover then n.accentHover else n.accent end
return if m._hover then n.lineStrong else n.raised end local function washTo(m)
if m._wash==nil then m._wash=m:own(c.prop(m.root,'BackgroundColor3',e))end m.
_wash:to(baseColor(m))end local function snapBase(m)local n=baseColor(m)if m.
_wash then m._wash:snap(n)else m.root.BackgroundColor3=n end end function l.
onHover(m,n)local o=n and not m.el.disabled if m._hover==o then return end m.
_hover=o for p,q in m.chips do if q.setHover then q.setHover(o)end end washTo(m)
end function l.pressed(m,n)if m._press==nil then local o=b('UIScale',{Parent=m.
root})m._press=m:own(c.prop(o,'Scale',f,g))end m._press:to(if n then i else 1)
end function l.flood(m,n,o)if m._lit==n then return end m._lit=n if o or not m.
root.Visible or not m.ctx.isShowing(m.el)then snapBase(m)else washTo(m)end end
function l.flash(m)m:flood(true)task.delay(k,function()if m.root.Parent then m:
flood(false)end end)end function l.ink(m,n,o,p)local q=m.ctx.theme.tokens local
r=m._inks[n]if p or not m.ctx.isShowing(m.el)then if r then r:snap(q[o])else n.
TextColor3=q[o]end return end if r==nil then r=m:own(c.prop(n,'TextColor3',h))m.
_inks[n]=r end r:to(q[o])end function l.retint(m)if not m._inert then snapBase(m
)end end function l.refreshName(m)local n=m.el if n.disabled then m.name.
RichText=true m.name.Text='<s>'..n.label..'</s>'else m.name.RichText=false m.
name.Text=n.label end end function d.new(m,n,o)local p=o or{}local q=b(
'TextButton',{Name=n.kind,Size=UDim2.new(1,0,0,p.height or d.HEIGHT),
BackgroundTransparency=if p.inert then 1 else 0,ClipsDescendants=true,Active=not
p.inert})if not p.inert then b('UICorner',{CornerRadius=UDim.new(0,d.RADIUS),
Parent=q})end local r=b('TextLabel',{Name='Name',Position=UDim2.fromOffset(d.PAD
,0),Size=UDim2.new(1,-2*d.PAD,1,0),TextSize=d.NAME,TextTruncate=Enum.
TextTruncate.AtEnd,Text=n.label,ZIndex=3,Parent=q})m.theme:type(r,'text',true)
local s=setmetatable({root=q,name=r,el=n,ctx=m,chips={},_cleanups={},_inks={},
_hover=false,_lit=false,_inert=p.inert==true},l)q.BackgroundColor3=baseColor(s)s
:refreshName()if p.inert then s.onHover=function()end s.pressed=function()end
else q.MouseEnter:Connect(function()m.hover:enter(s)end)local t=nil q.InputBegan
:Connect(function(u)local v=u.UserInputType if v==Enum.UserInputType.
MouseButton1 then if not n.disabled then s:pressed(true)end elseif v==Enum.
UserInputType.Touch then if not n.disabled then s:pressed(true)end t=task.delay(
j,function()t=nil local w=if n.disabled and n.disabledTip then n.disabledTip
else n.tip if w and w~=''then m.tooltip:showAt(q,w)end end)end end)local u=m.
input.pointerUp:connect(function()if s._press and s._press.target~=1 then s:
pressed(false)end if t then task.cancel(t)t=nil end end)s:onCleanup(function()u(
)if t then task.cancel(t)end end)end s.destroy=function()m.hover:leave(s)for t,u
in s._cleanups do pcall(u)end q:Destroy()end return s end return d end function
a.l()local b=a.cache.l if not b then b={c=__modImpl()}a.cache.l=b end return b.c
end end do local function __modImpl()local b=a.g()local c=a.i()local d=a.k()
local e=a.f()local f=a.j()local g=a.b()local h=a.l()local i={}local j=h.PAD
local k=h.RADIUS local l=h.HEIGHT local m=h.NAME local n=132 local o=230 local p
=28 local q=7 local r=26 local s=0.3 local t=20 local u=13 local v=20 local w=l+
4 local x=3 local y=8 local z=60 local A=14 local B=22 local C=20 local D=4
local E=34 local F=24 local G=F/2 local H=30 local I=12 local J=30 local K=80
local L=3 local M=0.72 local N=210 local O=170 local P=30 local Q=256 local R=22
local S=22 local T=15 local U={}local function listed(V)local W=V._shownOn local
X=W and W.sections[1]return X~=nil and X.flat==true end local function ownerOf(V
)local W=V.section return W and(W._root or W).masterElement end local function 
shownLabel(V)local W=ownerOf(V)if listed(V)and W and W~=V then return W.label..
' '..V.label end return V.label end local function textWidth(V,W)return f.width(
'textMedium',(string.gsub(V,'<[^>]+>','')),W)end local function addonRoom(V)
local W=0 for X,Y in V.addons or{}do if not Y.spec.chipless then if Y.kind==
'key'then local Z=Y.value local _=if Z and Z.key~='None'then Z.key else'Unset'W
+=f.width('mono',_,12)+16+y+6 else W+=b.DOT_SPACE end end end return W end local 
function isInline(V)local W=V.spec local X=#W.options if W.multi or X>x or V.
_inline==false then V._inline=false return false end if V._inline==nil then V.
_inline=X>=2 and V.value~=nil end return V._inline end function i.form(V)return
if V.kind=='dropdown'then isInline(V)else nil end local function formatted(V,W)
local X=V.spec if X.format then local Y,Z=pcall(X.format,V,W)if Y and Z~=nil
then return tostring(Z)end end return string.format('%.'..(X.decimals or 0)..'f'
,W)..(X.suffix or'')end local function readoutWidth(V)local W=V.spec local X=0
for Y,Z in{W.min,W.max,V.value}do X=math.max(X,f.width('mono',formatted(V,Z),A))
end return math.ceil(X)+2 end function i.measure(V)local W=V.kind if W=='slider'
then local X=math.max(z,textWidth(shownLabel(V),u)+8,readoutWidth(V)+8)return{
width=math.ceil(X),fader=true}elseif W=='toggle'or W=='key'or W=='color'or(W==
'label'and V.addons)then local X=p+textWidth(shownLabel(V),m)+j+addonRoom(V)
return{width=math.clamp(math.ceil(X),n,o),height=l}elseif W=='button'then return
{width=math.clamp(math.ceil(textWidth(V.label,m)+2*j),n,o),height=l}elseif W==
'dropdown'then local X=V.spec.display or tostring local Y=textWidth(shownLabel(V
),u)for Z,_ in V.spec.options do Y=math.max(Y,textWidth(X(_),m)+p+j)end if
isInline(V)then return{width=math.clamp(math.ceil(Y),n,o),height=v+#V.spec.
options*w-4}end return{width=math.clamp(math.ceil(Y),150,o),height=v+l}elseif W
=='input'then return{width=N,height=v+l}elseif W=='stat'then return{width=O,
height=P}elseif W=='divider'then return if V.label==''then{width=0,height=4}else
{width=0,height=S}elseif W=='label'then if V.spec.wrap then if V._measured then
return{width=Q,height=V._measured}end local X=string.gsub(V.label,'<[^>]+>','')
local Y=math.floor(Q/7)return{width=Q,height=math.ceil(#X/Y)*R+6}end return{
width=math.min(math.ceil(textWidth(V.label,m))+4,Q),height=R+4}end return{width=
n,height=l}end function i.masterWidth(V)return math.ceil(96+addonRoom(V))end
local function addons(V,W,X)local Y=0 local Z={}local function reflow()local _=0
for aa,ab in Z do ab.root.Position=UDim2.new(1,-(j-4+_),0.5,0)_+=ab.width+ab.gap
end if V.onReserve then V.onReserve(_)end end local function place(aa,ab)ab.root
.AnchorPoint=Vector2.new(1,0.5)ab.root.Position=UDim2.new(1,-(j-4+Y),0.5,0)ab.
root.ZIndex=4 ab.root.Parent=V.root ab.gap=if aa.kind=='key'then 6 else 0 ab.
onFit=reflow Y+=ab.width+ab.gap table.insert(Z,ab)aa._view=ab V.addonChips=V.
addonChips or{}V.addonChips[aa]=ab table.insert(V.chips,ab)V:onCleanup(function(
)aa._view=nil ab.destroy()end)end for aa,ab in X.addons or{}do if ab.kind==
'color'and not ab.spec.chipless then place(ab,b.swatch(W,ab))end end for aa,ab
in X.addons or{}do if ab.kind=='key'and not ab.spec.chipless then place(ab,d.
build(W,ab))end end return Y end local function lamp(aa,ab,V)local W=aa.theme
local X=e('ImageLabel',{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0,j+
q/2,0.5,0),Size=UDim2.fromOffset(r,r),BackgroundTransparency=1,BorderSizePixel=0
,ImageTransparency=1,ZIndex=2,Parent=ab})W:paint(X,'ImageColor3','accent')aa.
art(X,'glow.png')local Y=e('Frame',{AnchorPoint=Vector2.new(0.5,0.5),Position=
UDim2.new(0,j+q/2,0.5,0),Size=UDim2.fromOffset(q,q),BackgroundTransparency=0,
ZIndex=3,Parent=ab})e('UICorner',{CornerRadius=UDim.new(1,0),Parent=Y})W:paint(Y
,'BackgroundColor3','lineStrong')local Z=nil return function(_,ac)local ad=if _
then s else 1 if ac then if Z then Z:snap(ad)else X.ImageTransparency=ad end W:
paint(Y,'BackgroundColor3',if _ then'accent'else'lineStrong')return end if Z==
nil then Z=V:own(g.prop(X,'ImageTransparency',t))end Z:to(ad)aa.tint(Y,
'BackgroundColor3',if _ then'accent'else'lineStrong')end end local function 
padToggle(aa,ab)local ac=h.new(aa,ab)ac.name.Position=UDim2.fromOffset(p,0)local 
function reserve(ad)ac.name.Size=UDim2.new(1,-(p+j+ad),1,0)end ac.onReserve=
reserve reserve(addons(ac,aa,ab))local ad=lamp(aa,ac.root,ac)local function draw
(V)local W=ab.value==true ad(W,V)ac:ink(ac.name,if ab.disabled then'faint'elseif
W then'text'else'muted',V)for X,Y in ac.chips do if Y.setMuted then Y.setMuted(
not W)end end end ac.root.Activated:Connect(function()if not ab.disabled then ab
:set(not ab.value)end end)ac.refresh=function()ac:refreshName()if listed(ab)then
ac.name.Text=shownLabel(ab)end draw(false)end ac.refresh()draw(true)return ac
end local function masterSwitch(aa,ab)local ac=h.new(aa,ab)ac.name.TextSize=T aa
.theme:type(ac.name,'display')local function reserve(ad)ac.name.Size=UDim2.new(1
,-(2*j+ad),1,0)end ac.onReserve=reserve reserve(addons(ac,aa,ab))ac.refreshName=
function(ad)ad.name.Text=if ab.value==true then'On'else'Off'end local function 
draw(ad)local V=ab.value==true ac:refreshName()ac:flood(V,ad)ac:ink(ac.name,if
ab.disabled then'faint'elseif V then'onAccent'else'muted',ad)for W,X in ac.chips
do X.setInk(V)end end ac.root.Activated:Connect(function()if not ab.disabled
then ab:set(not ab.value)end end)ac.refresh=function()draw(false)end draw(true)
return ac end function U.toggle(aa,ab)if ab.spec.primary and not listed(ab)then
return masterSwitch(aa,ab)end return padToggle(aa,ab)end function U.slider(aa,ab
)local ac=h.new(aa,ab,{inert=true})local ad=aa.theme local V=ab.spec local W=ac.
root W.Active=true W.ClipsDescendants=false local function ratio()local X=V.max-
V.min return if X<=0 then 0 else math.clamp((ab.value-V.min)/X,0,1)end local X=
e('TextLabel',{Name='Readout',Size=UDim2.new(1,0,0,B),TextSize=A,TextXAlignment=
Enum.TextXAlignment.Center,ZIndex=3,Parent=W})ad:type(X,'mono')ac.name.
AnchorPoint=Vector2.new(0,1)ac.name.Position=UDim2.fromScale(0,1)ac.name.Size=
UDim2.new(1,0,0,C)ac.name.TextSize=u ac.name.TextXAlignment=Enum.TextXAlignment.
Center ac.name.TextTruncate=Enum.TextTruncate.None local Y=B+G local Z=C+G local
_=e('ImageLabel',{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,Y),
Size=UDim2.new(0,H,1,-(Y+Z)),BackgroundTransparency=1,BorderSizePixel=0,
ScaleType=Enum.ScaleType.Tile,TileSize=UDim2.fromOffset(H,I),ZIndex=1,Parent=W})
ad:paint(_,'ImageColor3','lineStrong')aa.art(_,'ticks.png')local ae=e('Frame',{
Name='Rail',AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,Y),Size=
UDim2.new(0,D,1,-(Y+Z)),BackgroundTransparency=0,ZIndex=2,Parent=W})e('UICorner'
,{CornerRadius=UDim.new(1,0),Parent=ae})ad:paint(ae,'BackgroundColor3','line')
local af=e('Frame',{Name='Fill',AnchorPoint=Vector2.new(0,1),Position=UDim2.
fromScale(0,1),Size=UDim2.fromScale(1,ratio()),BackgroundTransparency=0,ZIndex=2
,Parent=ae})e('UICorner',{CornerRadius=UDim.new(1,0),Parent=af})ad:paint(af,
'BackgroundColor3','accent')local ag=e('Frame',{Name='Cap',AnchorPoint=Vector2.
new(0.5,0.5),Position=UDim2.fromScale(0.5,0),Size=UDim2.fromOffset(E,F),
BackgroundTransparency=0,ZIndex=3,Parent=af})e('UICorner',{CornerRadius=UDim.
new(0,7),Parent=ag})ad:paint(ag,'BackgroundColor3','lineStrong')e('UIGradient',{
Rotation=90,Color=ColorSequence.new(Color3.fromRGB(255,255,255),Color3.fromRGB(
150,150,150)),Parent=ag})local ah=e('Frame',{AnchorPoint=Vector2.new(0.5,0.5),
Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(1,-12,0,2),
BackgroundTransparency=0,ZIndex=4,Parent=ag})e('UICorner',{CornerRadius=UDim.
new(1,0),Parent=ah})ad:paint(ah,'BackgroundColor3','text')local ai=ac:own(g.
prop(af,'Size',J))local aj=ac:own(g.prop(af,'BackgroundTransparency',J))ac.
onHover=function(ak,al)aa.tint(ag,'BackgroundColor3',if al and not ab.disabled
then'muted'else'lineStrong')end W.MouseEnter:Connect(function()aa.hover:enter(ac
)end)local function typedEntry()if ab.disabled or ac._typing then return end ac.
_typing=true X.Visible=false local ak=e('TextBox',{Size=UDim2.new(1,0,0,B),
TextSize=A,TextXAlignment=Enum.TextXAlignment.Center,Text='',PlaceholderText=
tostring(ab.value),ZIndex=6,Parent=W})ad:type(ak,'mono')ad:paint(ak,'TextColor3'
,'accent')ad:paint(ak,'PlaceholderColor3','faint')ak:CaptureFocus()ak.FocusLost:
Connect(function()local al=tonumber(ak.Text)ac._typing=false X.Visible=true ak:
Destroy()if al then ab:set(al)end end)end local function beginDrag(ak,al,am)if
ab.disabled then return end local an=ab.value local ao=math.max(ae.AbsoluteSize.
Y,1)local ap=V.max-V.min local aq=false local ar=false aa.input:capture(function
(as)local at=as-ak if not aq then if math.abs(at.Y)<L then if al and math.abs(at
.X)>8 then ar=true aa.input:release()end return end if al and math.abs(at.Y)<=
math.abs(at.X)then ar=true aa.input:release()return end aq=true ai.speed=K aa.
setScrollLocked(true)end ab:set(an-ap*at.Y/ao)end,function(as)ai.speed=J aa.
setScrollLocked(false)if not aq and not ar and(as-ak).Magnitude<8 then
typedEntry()end end,am)end W.InputBegan:Connect(function(ak)local al=ak.
UserInputType if al==Enum.UserInputType.MouseButton2 then typedEntry()elseif al
==Enum.UserInputType.MouseButton1 then beginDrag(aa.input:pointer(),false)elseif
al==Enum.UserInputType.Touch then beginDrag(aa.input:at(ak),true,ak)end end)
local ak=ownerOf(ab)local function dim()return if ak and ak.value~=true then M
else 0 end local function paintText()ad:paint(ac.name,'TextColor3',if ab.
disabled then'faint'else'muted')ad:paint(X,'TextColor3',if ab.disabled then
'faint'else'text')X.Text=formatted(ab,ab.value)end ac.refresh=function()ac:
refreshName()if listed(ab)then ac.name.Text=shownLabel(ab)end paintText()ai:to(
UDim2.fromScale(1,ratio()))aj:to(dim())end if ak then ac:onCleanup(ak:on(
function()aj:to(dim())end))end aj:snap(dim())ac:refreshName()if listed(ab)then
ac.name.Text=shownLabel(ab)end paintText()return ac end local function pickText(
aa)local ab=aa.spec.display or tostring local ac=aa.value if aa.spec.multi then
local ad={}for ae,af in aa.spec.options do if ac[af]then table.insert(ad,ab(af))
end end for ae,af in ac do if af and not table.find(aa.spec.options,ae)then
table.insert(ad,ab(ae))end end if#ad==0 then return'None',false end if#ad<=2
then return table.concat(ad,', '),true end return string.format('%s, %s +%d',ad[
1],ad[2],#ad-2),true end if ac==nil then return'None',false end return ab(ac),
true end local function caption(aa,ab,ac)ab.name.Position=UDim2.new()ab.name.
Size=UDim2.new(1,0,0,v-2)ab.name.TextSize=u aa.theme:paint(ab.name,'TextColor3',
'muted')if listed(ac)then ab.name.Text=shownLabel(ac)end end local function well
(aa,ab,ac)local ad=e(ac,{Name='Well',Position=UDim2.fromOffset(0,v),Size=UDim2.
new(1,0,0,l),BackgroundTransparency=0,ZIndex=2,Parent=ab})e('UICorner',{
CornerRadius=UDim.new(0,k),Parent=ad})aa.theme:paint(ad,'BackgroundColor3',
'raised')return ad end local function inlineOptions(aa,ab)local ac=h.new(aa,ab,{
inert=true})ac.root.Active=true caption(aa,ac,ab)local ad=ab.spec.display or
tostring local ae={}local af=''local function build()for ag,ah in ae do ah.
button:Destroy()end table.clear(ae)for ag,ah in ab.spec.options do local ai=e(
'TextButton',{Name='Option',Position=UDim2.fromOffset(0,v+(ag-1)*w),Size=UDim2.
new(1,0,0,l),BackgroundTransparency=0,ZIndex=2,Parent=ac.root})e('UICorner',{
CornerRadius=UDim.new(0,k),Parent=ai})aa.theme:paint(ai,'BackgroundColor3',
'raised')local aj=e('TextLabel',{Position=UDim2.fromOffset(p,0),Size=UDim2.new(1
,-(p+j),1,0),TextSize=m,TextTruncate=Enum.TextTruncate.AtEnd,Text=ad(ah),ZIndex=
3,Parent=ai})aa.theme:type(aj,'text',true)local ak={button=ai,label=aj,option=ah
,light=lamp(aa,ai,ac)}ai.Activated:Connect(function()if not ab.disabled then ab:
set(ah)end end)ai.MouseEnter:Connect(function()aa.tint(ai,'BackgroundColor3',
'lineStrong')end)ai.MouseLeave:Connect(function()aa.tint(ai,'BackgroundColor3',
'raised')end)table.insert(ae,ak)end end local function draw(ag)for ah,ai in ae
do local aj=ab.value==ai.option ai.light(aj,ag)ac:ink(ai.label,if ab.disabled
then'faint'elseif aj then'text'else'muted',ag)end end ac.refresh=function()local
ag=table.concat(ab.spec.options,'\0')if ag~=af then af=ag build()draw(true)if ab
._relayout then ab._relayout()end else draw(false)end end af=table.concat(ab.
spec.options,'\0')build()draw(true)return ac end function U.dropdown(aa,ab)if
isInline(ab)then return inlineOptions(aa,ab)end local ac=h.new(aa,ab,{inert=true
})local ad=aa.theme ac.root.Active=true ac.root.ClipsDescendants=false caption(
aa,ac,ab)local ae=well(aa,ac.root,'TextButton')local af=e('TextLabel',{Name=
'Value',Position=UDim2.fromOffset(j,0),Size=UDim2.new(1,-(2*j+18),1,0),TextSize=
m,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=3,Parent=ae})ad:type(af,'text',
true)local ag=aa.glyph.chevron(ae,'muted')ag.AnchorPoint=Vector2.new(1,0.5)ag.
Position=UDim2.new(1,-j,0.5,0)ag.ZIndex=3 ae.MouseEnter:Connect(function()aa.
tint(ae,'BackgroundColor3','lineStrong')end)ae.MouseLeave:Connect(function()aa.
tint(ae,'BackgroundColor3','raised')end)ae.Activated:Connect(function()if not ab
.disabled then c.open(aa,ab,ae)end end)ac.refresh=function()local ah,ai=
pickText(ab)af.Text=ah ad:paint(af,'TextColor3',if ab.disabled or not ai then
'faint'else'text')end ac.refresh()return ac end function U.input(aa,ab)local ac=
h.new(aa,ab,{inert=true})local ad=aa.theme local ae=ab.spec ac.root.Active=true
ac.root.ClipsDescendants=false caption(aa,ac,ab)local af=well(aa,ac.root,'Frame'
)local ag=e('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,
Parent=af})ad:paint(ag,'Color','line')local ah=e('TextBox',{Position=UDim2.
fromOffset(j,0),Size=UDim2.new(1,-2*j,1,0),TextSize=m,Text=ab.value or'',
PlaceholderText=ae.placeholder or'',ClipsDescendants=true,TextEditable=not ab.
disabled,ZIndex=3,Parent=af})ad:type(ah,'text',true)ad:paint(ah,'TextColor3',
'text')ad:paint(ah,'PlaceholderColor3','faint')ah.Focused:Connect(function()aa.
tint(ag,'Color','accent')end)ah.FocusLost:Connect(function(ai)aa.tint(ag,'Color'
,'line')if not ae.finished then return end if not ai or not ab:set(ah.Text)then
ah.Text=ab.value or''end end)ah:GetPropertyChangedSignal('Text'):Connect(
function()if ac._applying or ae.finished then return end if not ab:set(ah.Text)
and ah.Text~=ab.value then ac._applying=true ah.Text=ab.value or''ac._applying=
false end end)ac.refresh=function()ah.TextEditable=not ab.disabled if ah.Text~=(
ab.value or'')then ac._applying=true ah.Text=ab.value or''ac._applying=false end
end return ac end function U.button(aa,ab)local ac=h.new(aa,ab)ac.name.
TextXAlignment=Enum.TextXAlignment.Center local ad=nil local function draw()ac:
refreshName()ac:ink(ac.name,if ab.disabled then'faint'elseif ab.spec.danger then
'danger'else'text')end ac.refresh=draw draw()ac.root.Activated:Connect(function(
)if ab.disabled then return end if ab.spec.confirm and ad==nil then ac.name.Text
='Again to confirm'ac:flood(true)ac:ink(ac.name,'onAccent')ad=task.delay(2.5,
function()ad=nil ac:flood(false)draw()end)return end if ad then task.cancel(ad)
ad=nil ac:flood(false)draw()end ac:flash()ac:ink(ac.name,'onAccent')task.delay(
0.28,function()if ac.root.Parent then draw()end end)ab:fire()end)ac:onCleanup(
function()if ad then task.cancel(ad)end end)return ac end function U.stat(aa,ab)
local ac=h.new(aa,ab,{inert=true})local ad=aa.theme ac.name.Position=UDim2.new()
ac.name.Size=UDim2.fromScale(0.6,1)ad:paint(ac.name,'TextColor3','muted')local
ae=e('TextLabel',{AnchorPoint=Vector2.new(1,0),Position=UDim2.fromScale(1,0),
Size=UDim2.fromScale(0.4,1),TextSize=m,TextXAlignment=Enum.TextXAlignment.Right,
TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=3,Parent=ac.root})ad:type(ae,'mono')
ad:paint(ae,'TextColor3','text')ac.refresh=function()ac.name.Text=ab.label ae.
Text=tostring(ab.value)end ac.refresh()return ac end function U.label(aa,ab)
local ac=aa.theme if ab.addons then local ad=h.new(aa,ab)ac:paint(ad.name,
'TextColor3','muted')ad.name.RichText=true local function reserve(ae)ad.name.
Size=UDim2.new(1,-(2*j+ae),1,0)end ad.onReserve=reserve reserve(addons(ad,aa,ab)
)ad.refresh=function()ad.name.Text=ab.label end return ad end local ad=h.new(aa,
ab,{inert=true})local ae=ad.name local af=ab.spec.wrap==true ae.RichText=true ae
.TextWrapped=af ac:type(ae,'text')ac:paint(ae,'TextColor3','muted')ae.
TextTruncate=if af then Enum.TextTruncate.None else Enum.TextTruncate.AtEnd ae.
TextYAlignment=if af then Enum.TextYAlignment.Top else Enum.TextYAlignment.
Center ae.LineHeight=if af then 1.15 else 1 ae.Position=UDim2.new()ae.Size=UDim2
.fromScale(1,1)ae.Text=ab.label if af then ae:GetPropertyChangedSignal(
'TextBounds'):Connect(function()local ag=math.ceil(ae.TextBounds.Y/aa.uiScale())
+6 if ab._measured~=ag then ab._measured=ag if ab._relayout then ab._relayout()
end end end)end ad.refresh=function()ae.Text=ab.label end return ad end function
U.divider(aa,ab)local ac=h.new(aa,ab,{inert=true})local ad=aa.theme ac.name.
Position=UDim2.new()ac.name.Size=UDim2.fromScale(1,1)ac.name.TextSize=u ad:
paint(ac.name,'TextColor3','muted')ac.refresh=function()ac.name.Text=ab.label
end return ac end local function chipTile(aa,ab,ac,ad)local ae=h.new(aa,ab)aa.
theme:paint(ae.name,'TextColor3','muted')ac.root.AnchorPoint=Vector2.new(1,0.5)
ac.root.Position=UDim2.new(1,-ad,0.5,0)ac.root.ZIndex=4 ac.root.Parent=ae.root
ae.name.Size=UDim2.new(1,-(2*j+ac.width),1,0)table.insert(ae.chips,ac)ae:
onCleanup(ac.destroy)ae.refresh=function()ae:refreshName()ac.refresh()end return
ae end function U.key(aa,ab)local ac=d.build(aa,ab)local ad=chipTile(aa,ab,ac,j-
4)ad.root.Activated:Connect(ac.start)return ad end function U.color(aa,ab)local
ac=b.swatch(aa,ab)local ad=chipTile(aa,ab,ac,j-8)ad.root.Activated:Connect(ac.
open)return ad end function i.build(aa,ab)local ac=U[ab.kind]assert(ac,
'sottUI: no view for '..tostring(ab.kind))local ad=ac(aa,ab)ad.form=i.form(ab)ab
._view=ad return ad end return i end function a.m()local aa=a.cache.m if not aa
then aa={c=__modImpl()}a.cache.m=aa end return aa.c end end do local function 
__modImpl()local aa={}aa.__index=aa local ab=function(ab)warn(ab)end function aa
.connect(ac,ad)local ae=table.clone(ac._list)table.insert(ae,ad)ac._list=ae
return function()local af=table.clone(ac._list)local ag=table.find(af,ad)if ag
then table.remove(af,ag)ac._list=af end end end function aa.fire(ac,...)for ad,
ae in ac._list do local af,ag=xpcall(ae,debug.traceback,...)if not af then ab(
'sottUI: listener failed: '..tostring(ag))end end end function aa.clear(ac)ac.
_list={}end return{new=function()return((setmetatable({_list={}},aa)))end,
setReporter=function(ac)ab=ac end}end function a.n()local aa=a.cache.n if not aa
then aa={c=__modImpl()}a.cache.n=aa end return aa.c end end do local function 
__modImpl()local aa=a.n()local ab={}local ac={}ac.__index=ac local function 
decimals(ad)local ae=string.format('%.10f',ad)local af=string.match(ae,
'%.(%d-)0*$')return if af then#af else 0 end local function roundTo(ad,ae)if ae
<=0 then return ad end local af=math.round(ad/ae)*ae return tonumber(string.
format('%.'..decimals(ae)..'f',af))or af end ab.roundTo=roundTo local function 
sameList(ad,ae)if#ad~=#ae then return false end for af=1,#ad do if ad[af]~=ae[af
]then return false end end return true end local function sameSet(ad,ae)for af,
ag in ad do if ag and not ae[af]then return false end end for af,ag in ae do if
ag and not ad[af]then return false end end return true end local ad={toggle=
function(ad,ae)return ae==true end,slider=function(ad,ae)local af=tonumber(ae)if
af==nil or af~=af then return nil end local ag=ad.spec return math.clamp(
roundTo(af,ag.step or 1),ag.min,ag.max)end,dropdown=function(ad,ae)local af=ad.
spec if af.multi then local ag={}if type(ae)=='table'then for ah,ai in ae do if
type(ah)=='number'then ag[ai]=true elseif ai then ag[ah]=true end end elseif ae
~=nil and ae~=''then ag[ae]=true end if not af.keep then for ah in ag do if not
table.find(af.options,ah)then ag[ah]=nil end end end return ag end if ae==nil or
ae==''then return false end if not table.find(af.options,ae)and not af.keep then
return nil end return ae end,input=function(ad,ae)local af=if ae==nil then''else
tostring(ae)local ag=ad.spec if ag.maxLength and#af>ag.maxLength then af=string.
sub(af,1,ag.maxLength)end if ag.numeric and af~=''and af~='-'and af~='.'and
tonumber(af)==nil then return nil end if ag.verify and not ag.verify(af)then
return nil end return af end,key=function(ad,ae)if type(ae)=='string'then return
{key=ae,mode=ad.value and ad.value.mode or'Toggle',modifiers={}}end if type(ae)
~='table'then return nil end local af=ad.value or{}return{key=ae.key or ae[1]or
af.key or'None',mode=ae.mode or ae[2]or af.mode or'Toggle',modifiers=ae.
modifiers or ae[3]or af.modifiers or{}}end,color=function(ad,ae)if typeof(ae)==
'Color3'then return{color=ae,alpha=ad.value and ad.value.alpha or 0}end if type(
ae)=='table'and typeof(ae.color)=='Color3'then return{color=ae.color,alpha=math.
clamp(tonumber(ae.alpha)or 0,0,1)}end return nil end,label=function(ad,ae)return
tostring(ae)end,stat=function(ad,ae)return tostring(ae)end}local function equal(
ae,af,ag)local ah=ae.kind if ah=='dropdown'and ae.spec.multi then return
sameSet(af,ag)end if ah=='key'then return af.key==ag.key and af.mode==ag.mode
and sameList(af.modifiers,ag.modifiers)end if ah=='color'then return af.color==
ag.color and af.alpha==ag.alpha end return af==ag end local function unwrap(ae,
af)if ae.kind=='dropdown'and not ae.spec.multi and af==false then return nil end
return af end function ab.new(ae,af,ag,ah,ai)local aj=setmetatable({kind=ae,id=
af,label=ag,spec=ah,tip=ah.tip,disabled=ah.disabled==true,disabledTip=ah.
disabledTip,visible=ah.visible~=false,saved=ah.saved~=false,changed=aa.new()},ac
)local ak=ad[ae]local al=ai if ak then al=ak(aj,ai)if al==nil and ae=='slider'
then al=ah.min end if al==nil and ae=='dropdown'then al=false end end aj.value=
unwrap(aj,al)aj.default=aj.value return aj end function ac.set(ae,af)local ag=ad
[ae.kind]local ah=af if ag then ah=ag(ae,af)if ah==nil then return false end ah=
unwrap(ae,ah)end local ai=ae.value if ai~=nil and ah~=nil and equal(ae,ai,ah)
then return false end if ai==nil and ah==nil then return false end ae.value=ah
ae:notify()return true end function ac.reset(ae)local af=ae.default if ae.kind==
'dropdown'and ae.spec.multi then af=table.clone(af)end ae:set(af)end local 
function redraw(ae)local af=ae._view if af then af.refresh()end local ag=ae.host
if ag and ag._view then ag._view.refresh()end end function ac.notify(ae)redraw(
ae)ae.changed:fire(ae.value)end function ac.fire(ae)ae.changed:fire(ae.value)end
function ac.on(ae,af)return ae.changed:connect(af)end function ac.setLabel(ae,af
)if ae.label==af then return end ae.label=af if ae.kind=='label'then ae.value=af
local ag=ae._relayout if ag then ag()end end if ae._onLabel then ae._onLabel()
end redraw(ae)end function ac.setTip(ae,af)ae.tip=af end function ac.setDisabled
(ae,af,ag)ae.disabled=af==true ae.disabledTip=ag or ae.disabledTip redraw(ae)end
function ac.setVisible(ae,af)if ae.visible==af then return end ae.visible=af
local ag=ae._relayout if ag then ag()end end function ac.setOptions(ae,af)local
ag=ae.spec ag.options=table.clone(af)if ag.multi then if ag.keep then for ah,ai
in ae.value do if ai and not table.find(ag.options,ah)then table.insert(ag.
options,ah)end end else local ah=false for ai in ae.value do if not table.find(
ag.options,ai)then ae.value[ai]=nil ah=true end end if ah then ae:notify()return
end end elseif ae.value~=nil and not table.find(ag.options,ae.value)then if ag.
keep then table.insert(ag.options,ae.value)else ae.value=nil ae:notify()return
end end redraw(ae)end function ac.isModified(ae)if ae.kind=='button'or ae.kind==
'label'or ae.kind=='divider'or ae.kind=='stat'then return false end local af,ag=
ae.value,ae.default if af==nil or ag==nil then return af~=ag end return not
equal(ae,af,ag)end function ac.attach(ae,af)local ag=ae.addons if ag==nil then
ag={}ae.addons=ag end table.insert(ag,af)af.host=ae redraw(ae)end function ac.
shown(ae)if not ae.visible or(ae.kind=='label'and ae.label=='')then return false
end local af=ae.guard return af==nil or af()end return ab end function a.o()
local aa=a.cache.o if not aa then aa={c=__modImpl()}a.cache.o=aa end return aa.c
end end do local function __modImpl()local aa=a.o()local ab={}local ac={}ac.
__index=ac local function add(ad,ae,af,ag,ah,ai)local aj=aa.new(ae,af or(ae..'#'
..tostring(ad._page:nextId())),ag,ah,ai)aj.section=ad aj.guard=ad._guard ad.
_page:_register(aj,af~=nil)table.insert(ad.rows,aj)local ak=ad._root or ad if ak
.masterElement then ak.hasOptions=true end ad._page:_invalidate()return aj end
function ac.toggle(ad,ae,af)local ag=add(ad,'toggle',ae,af.label or ae,af,af.
default==true)if af.onChanged then ag:on(af.onChanged)end return ag end function
ac.master(ad,ae,af)af.primary=true local ag=ad:toggle(ae,af)ad.masterElement=ag
local ah=ad._page ag:on(function()ah:_invalidate()end)return ag end function ac.
slider(ad,ae,af)af.min=af.min or 0 af.max=af.max or 100 af.step=af.step or 1 if
af.decimals==nil then local ag=string.format('%.10f',af.step)local ah=string.
match(ag,'%.(%d-)0*$')af.decimals=if ah then#ah else 0 end local ag=add(ad,
'slider',ae,af.label or ae,af,af.default or af.min)if af.onChanged then ag:on(af
.onChanged)end return ag end function ac.dropdown(ad,ae,af)af.options=af.options
or{}local ag=af.default if ag==nil and af.multi then ag={}end local ah=add(ad,
'dropdown',ae,af.label or ae,af,ag)if af.onChanged then ah:on(af.onChanged)end
return ah end function ac.input(ad,ae,af)local ag=add(ad,'input',ae,af.label or
'',af,af.default or'')if af.onChanged then ag:on(af.onChanged)end return ag end
function ac.key(ad,ae,af)local ag=add(ad,'key',ae,af.label or ae,af,{key=af.
default or'None',mode=af.mode or'Toggle',modifiers=af.modifiers or{}})ad._page.
window.keys:register(ag)return ag end function ac.color(ad,ae,af)local ag=add(ad
,'color',ae,af.label or ae,af,{color=af.default or Color3.new(1,1,1),alpha=af.
alphaValue or 0})if af.onChanged then ag:on(af.onChanged)end return ag end
function ac.button(ad,ae,af)local ag=if type(af)=='function'then{onPressed=af}
else af ag.saved=false local ah=add(ad,'button',nil,ae,ag,nil)if ag.onPressed
then ah:on(ag.onPressed)end return ah end function ac.label(ad,ae,af)local ag=af
or{}ag.saved=false return add(ad,'label',nil,ae,ag,ae)end function ac.stat(ad,ae
,af)return add(ad,'stat',nil,ae,{saved=false},tostring(af))end function ac.
divider(ad,ae)return add(ad,'divider',nil,ae or'',{saved=false},nil)end function
ac.addKey(ad,ae,af,ag)local ah=aa.new('key',af,ag.label or ae.label,ag,{key=ag.
default or'None',mode=ag.mode or'Toggle',modifiers=ag.modifiers or{}})ah.section
=ad local ai=ah ai.toggled=ag.toggled==true if ae.kind=='toggle'and ag.onPress==
nil then ai.toggled=ae.value ag.onPress=function()ae:set(not ae.value)ai.toggled
=ae.value end end ad._page:_register(ah,true)ad._page.window.keys:register(ah)ae
:attach(ah)return ah end function ac.addColor(ad,ae,af,ag)local ah=aa.new(
'color',af,ag.label or ae.label,ag,{color=ag.default or Color3.new(1,1,1),alpha=
ag.alphaValue or 0})ah.section=ad ad._page:_register(ah,true)ae:attach(ah)if ag.
onChanged then ah:on(ag.onChanged)end return ah end function ac.when(ad,ae,af)
local ag=ad._guard local ah=ae if ag then ah=function()return ag()and ae()end
end local ai=setmetatable({rows=ad.rows,title=ad.title,_page=ad._page,_guard=ah,
_root=ad._root or ad},ac)for aj,ak in(af or{})do ak:on(function()ad._page:
_invalidate()end)end return ai end function ab.new(ad,ae)return setmetatable({
title=ae,rows={},_page=ad,_guard=nil,_root=nil},ac)end return ab end function a.
p()local aa=a.cache.p if not aa then aa={c=__modImpl()}a.cache.p=aa end return
aa.c end end do local function __modImpl()local aa=a.m()local ab=a.f()local ac=a
.j()local ad=a.b()local ae=a.p()local af={}local ag=26 local ah=36 function af.
open(ai,aj,ak)if ai._dialogClose then ai._dialogClose()end local al=ai.ctx local
am=al.theme local an=ai._layer local ao=aj.width or 460 local ap=aj.maxHeight or
340 local aq=60 local ar=ab('TextButton',{Size=UDim2.fromScale(1,1),
BackgroundTransparency=1,BackgroundColor3=Color3.new(0,0,0),ZIndex=50,Parent=an}
)local as=ad.prop(ar,'BackgroundTransparency',22)as:to(0.4)local at=ab('Frame',{
AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.
fromOffset(ao,0),BackgroundTransparency=0,ClipsDescendants=true,Active=true,
ZIndex=51,Parent=an})am:paint(at,'BackgroundColor3','base')ab('UICorner',{
CornerRadius=UDim.new(0,14),Parent=at})ab('UIScale',{Scale=al.uiScale(),Parent=
at})local b=ab('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=at
})am:paint(b,'Color','lineStrong')local c=ab('TextLabel',{Position=UDim2.
fromOffset(20,16),Size=UDim2.new(1,-40,0,40),TextSize=36,Text=aj.title or'',
ZIndex=52,Parent=at})am:type(c,'display')am:paint(c,'TextColor3','text')local d=
60 local e=aj.text if e and e~=''then local f=ab('TextLabel',{Position=UDim2.
fromOffset(20,d),Size=UDim2.new(1,-40,0,22),AutomaticSize=Enum.AutomaticSize.Y,
TextSize=16,TextWrapped=true,Text=e,ZIndex=52,Parent=at})am:type(f,'text')am:
paint(f,'TextColor3','muted')d+=22+math.floor(#e/52)*22+12 end local f=ab(
'ScrollingFrame',{Position=UDim2.fromOffset(20,d),Size=UDim2.new(1,-40,0,0),
ScrollBarThickness=3,ZIndex=52,Parent=at})am:paint(f,'ScrollBarImageColor3',
'lineStrong')local g=false local h={window=ai,name='Dialog',nextId=function()ai.
_dialogIds+=1 return ai._dialogIds end,_register=function(h,i,j)i._pageName=
'Dialog'if j then ai.elements[i.id]=i end end,_invalidate=function()end}local i=
ae.new(h,'')local j,k=xpcall(ak,debug.traceback,i)if not j then warn(
'sottUI: dialog build failed: '..tostring(k))end local l={}local m=0 for n,o in
i.rows do if o:shown()then local p=aa.build(al,o)local q=aq if o.kind=='slider'
then q=170 elseif o.kind=='dropdown'or o.kind=='input'then q=aa.measure(o).
height elseif o.kind=='divider'then q=28 elseif o.kind=='label'then local r=math
.ceil(ac.width('text',o.label,16)/(ao-48))q=if o.spec.wrap then r*21+12 else 32
end p.root.Position=UDim2.fromOffset(0,m)p.root.Size=UDim2.new(1,0,0,q)p.root.
Parent=f m+=q+3 table.insert(l,p)end end f.CanvasSize=UDim2.fromOffset(0,m)local
n=math.min(m,ap)f.Size=UDim2.new(1,-40,0,n)local o=d+n+12 local p=ab(
'TextButton',{Position=UDim2.fromOffset(20,o),Size=UDim2.new(1,-40,0,44),
BackgroundTransparency=0,TextSize=15,Text=aj.done or'Done',ZIndex=52,Parent=at})
ab('UICorner',{CornerRadius=UDim.new(0,10),Parent=p})am:type(p,'display')am:
paint(p,'BackgroundColor3','text')am:paint(p,'TextColor3','base')local q=o+44+20
local r=ad.prop(at,'Size',ag)r:to(UDim2.fromOffset(ao,q))local function close()
if g then return end g=true ai._dialogClose=nil ar.Active=false for s,t in i.
rows do if ai.elements[t.id]==t then ai.elements[t.id]=nil end for u,v in t.
addons or{}do ai.keys:unregister(v)if ai.elements[v.id]==v then ai.elements[v.id
]=nil end end end if aj.onClose then task.spawn(aj.onClose)end as:to(1,function(
)as:destroy()ar:Destroy()end)r.speed=ah r:to(UDim2.fromOffset(ao,0),function()
for s,t in l do t.destroy()end r:destroy()at:Destroy()end)end ai._dialogClose=
close ar.MouseButton1Down:Connect(close)p.Activated:Connect(close)end return af
end function a.q()local aa=a.cache.q if not aa then aa={c=__modImpl()}a.cache.q=
aa end return aa.c end end do local function __modImpl()local aa=a.a()local ab={
}local ac={text={name='SottUIText',faces={{name='Regular',weight=400,file=
'text-400.ttf'},{name='Medium',weight=500,file='text-500.ttf'}}},display={name=
'SottUIDisplay',faces={{name='SemiBold',weight=600,file='display-600.ttf'}}},
mono={name='SottUIMono',faces={{name='Medium',weight=500,file='mono-500.ttf'}}}}
local ad=10000 local function family(ae,af,ag,ah,ai)local aj={}for ak,al in ag.
faces do local am=af..'/'..al.file local an=ae.read(am)if an==nil or#an<ad then
local ao=aa.fetch(ah..al.file)if ao==nil or#ao<ad then return nil end if not ae.
write(am,ao)then return nil end end local ao=ae.asset(am)if ao==nil then return
nil end table.insert(aj,{name=al.name,weight=al.weight,style='normal',assetId=ao
})end local ak=af..'/'..ag.name..'.json'if not ae.write(ak,ai({name=ag.name,
faces=aj}))then return nil end return ae.asset(ak)end function ab.load(ae,af,ag)
local ah=aa.files()if ah==nil or aa.global('getcustomasset')==nil then return{}
end ah.folder(ae)local ai={}local aj,ak=pcall(function()ai.text=family(ah,ae,ac.
text,af,ag)ai.display=family(ah,ae,ac.display,af,ag)ai.mono=family(ah,ae,ac.mono
,af,ag)end)if not aj then warn('sottUI: fonts unavailable: '..tostring(ak))end
return ai end function ab.image(ae,af,ag)local ah=aa.files()if ah==nil or aa.
global('getcustomasset')==nil then return nil end ah.folder(ae)local ai=ae..'/'
..ag if ah.read(ai)==nil then local aj=aa.fetch(af..ag)if aj==nil or not ah.
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
nil local an=nil local function modifiersHeld(ao)for ap,aq in(ao or{})do local
ar=false for as,at in ad do if at==aq and ah:IsKeyDown(as)then ar=true end end
if not ar then return false end end return true end local function heldModifiers
(ao)local ap={}for aq,ar in ad do if aq.Name~=ao and ah:IsKeyDown(aq)then table.
insert(ap,ar)end end table.sort(ap)return ap end function ai.register(ao,ap)
table.insert(aj,ap)end function ai.unregister(ao,ap)local aq=table.find(aj,ap)if
aq then table.remove(aj,aq)end end function ai.listen(ao,ap,aq)ai.cancel()ak=ap
al=aq==true end function ai.swallowed(ao,ap)return an==ap end function ai.cancel
()local ao=ak ak=nil am=nil if ao then ao(nil)end end function ai.state(ao,ap)
local aq=ap.value if aq==nil then return false end if aq.mode=='Always'then
return true end if aq.mode=='Toggle'then return ap.toggled==true end if aq.key==
'None'or ak~=nil or ae:typing()then return false end local ar=ac[aq.key]if ar
then return not ag()and ah:IsMouseButtonPressed(ar)and modifiersHeld(aq.
modifiers)end local as,at=pcall(function()return ah:IsKeyDown((Enum.KeyCode)[aq.
key])end)return as and at and modifiersHeld(aq.modifiers)end ae.keyDown:connect(
function(ao)local ap=nameOf(ao)if ap==nil then return end if ak then local aq=ab
[ao.UserInputType]~=nil if aq and(al or ap=='MB1')then return end if ad[ao.
KeyCode]and not aq then am=ap return end local ar=ak ak=nil am=nil an=ap if ap==
'Escape'then(ar)('None',{})else(ar)(ap,heldModifiers(ap))end return end if an==
ap then return end if ae:typing()then return end for aq,ar in aj do local as=ar.
value if as.key==ap and not ar.disabled and modifiersHeld(as.modifiers)then if
as.mode=='Toggle'then ar.toggled=not ar.toggled end local at=ar.spec.onPress if
at then at(ar,ar.toggled)end end end end)ae.keyUp:connect(function(ao)local ap=
nameOf(ao)if ap==nil then return end if am==ap and ak then local aq=ak ak=nil am
=nil aq(ap,{})return end if an==ap then an=nil end for aq,ar in aj do local as=
ar.value if as.key==ap and as.mode=='Hold'and ar.spec.onRelease then ar.spec.
onRelease(ar)end end end)return ai end return aa end function a.v()local aa=a.
cache.v if not aa then aa={c=__modImpl()}a.cache.v=aa end return aa.c end end do
local function __modImpl()local aa=a.f()local ab=a.b()local ac={}local ad=320
local ae=8 local af=20 local ag=26 local ah=5 function ac.new(ai,aj)local ak=ai.
theme local al={}local am={}local function layout()local an=aj.AbsoluteSize
local ao=an.Y-af for ap=#al,1,-1 do local aq=al[ap]ao-=aq.height aq.pos:to(UDim2
.fromOffset(an.X-ad-af,ao))ao-=ae end end local function dismiss(an)if an.gone
then return end an.gone=true if an.timer then task.cancel(an.timer)end local ao=
table.find(al,an)if ao then table.remove(al,ao)end local ap=aj.AbsoluteSize an.
pos:to(UDim2.fromOffset(ap.X+8,an.frame.Position.Y.Offset),function()an.pos:
destroy()an.frame:Destroy()end)layout()end function am.show(an,ao)while#al>=ah
do dismiss(al[1])end local ap=aj.AbsoluteSize local aq=aa('TextButton',{Name=
'Notice',Position=UDim2.fromOffset(ap.X+8,ap.Y-af-60),Size=UDim2.fromOffset(ad,
60),BackgroundTransparency=0,ZIndex=80,Parent=aj})ak:paint(aq,'BackgroundColor3'
,'surface')aa('UICorner',{CornerRadius=UDim.new(0,12),Parent=aq})local ar=aa(
'UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=aq})ak:paint(ar,
'Color','lineStrong')local as=aa('Frame',{AnchorPoint=Vector2.new(0,0.5),
Position=UDim2.new(0,5,0.5,0),Size=UDim2.new(0,3,1,-24),BackgroundTransparency=0
,ZIndex=81,Parent=aq})aa('UICorner',{CornerRadius=UDim.new(1,0),Parent=as})ak:
paint(as,'BackgroundColor3','accent')local at=10 if ao.title and ao.title~=''
then local b=aa('TextLabel',{Position=UDim2.fromOffset(18,at),Size=UDim2.new(1,-
32,0,24),TextSize=22,TextTruncate=Enum.TextTruncate.AtEnd,Text=ao.title,ZIndex=
81,Parent=aq})ak:type(b,'display')ak:paint(b,'TextColor3','text')at+=26 end
local b=nil if ao.text and ao.text~=''then b=aa('TextLabel',{Position=UDim2.
fromOffset(18,at),Size=UDim2.new(1,-32,0,20),TextSize=16,TextWrapped=true,
TextYAlignment=Enum.TextYAlignment.Top,RichText=true,Text=ao.text,ZIndex=81,
Parent=aq})ak:type(b,'text')ak:paint(b,'TextColor3','muted')end local c={frame=
aq,height=at+28,pos=ab.prop(aq,'Position',ag),gone=false}aq.Size=UDim2.
fromOffset(ad,c.height)if b then task.defer(function()if c.gone then return end
local d=math.ceil(b.TextBounds.Y)if d>20 then b.Size=UDim2.new(1,-32,0,d)c.
height=at+d+10 aq.Size=UDim2.fromOffset(ad,c.height)layout()end end)end c.pos:
snap(UDim2.fromOffset(ap.X+8,ap.Y-af-c.height))table.insert(al,c)aq.Activated:
Connect(function()dismiss(c)end)c.timer=task.delay(ao.seconds or 5,function()c.
timer=nil dismiss(c)end)layout()end function am.destroy(an)for ao,ap in table.
clone(al)do if ap.timer then task.cancel(ap.timer)end ap.pos:destroy()ap.frame:
Destroy()end table.clear(al)end return am end return ac end function a.w()local
aa=a.cache.w if not aa then aa={c=__modImpl()}a.cache.w=aa end return aa.c end
end do local function __modImpl()local aa=a.f()local ab=a.b()local ac={}local ad
=34 local ae=48 local af=0.55 local ag=340 local ah=40 local ai=8 function ac.
popover(aj,ak)local al=aj.theme local am={}local an=nil local function close()
local ao=an if ao==nil then return end an=nil ao.catcher:Destroy()ao.open=false
ao.size.speed=ae ao.size:to(UDim2.fromOffset(ao.width,0),function()ao.size:
destroy()ao.frame:Destroy()end)if ao.disconnectEl then ao.disconnectEl()end end
function am.open(ao,ap,aq,ar,as)close()local at=ak.AbsoluteSize local b,c=ap.
AbsolutePosition-ak.AbsolutePosition,ap.AbsoluteSize aq=math.min(aq,at.X-2*ai)ar
=math.min(ar,at.Y-2*ai)local d=if aq>c.X then b.X+c.X-aq else b.X local e=math.
clamp(d,ai,at.X-aq-ai)local f=b.Y+c.Y+2 local g=math.max(aj.popoverTop(),ai)
local h=f+ar+ai>at.Y and b.Y-ar-2>g local i=if h then b.Y-ar-2 else math.max(
math.min(f,at.Y-ar-ai),g)local j=aa('TextButton',{Name='Catcher',Size=UDim2.
fromScale(1,1),ZIndex=60,Parent=ak})local k=aa('Frame',{Name='Popover',Position=
UDim2.fromOffset(e,i),Size=UDim2.fromOffset(aq,0),BackgroundTransparency=0,
ClipsDescendants=true,ZIndex=61,Active=true,Parent=ak})al:paint(k,
'BackgroundColor3','raised')aa('UICorner',{CornerRadius=UDim.new(0,10),Parent=k}
)local l=aa('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=k})al
:paint(l,'Color','lineStrong')local m=aa('Frame',{Size=UDim2.fromScale(1,1),
Parent=k})local n={frame=k,catcher=j,width=aq,open=true,size=ab.prop(k,'Size',ad
)}an=n j.MouseButton1Down:Connect(close)j.MouseButton2Down:Connect(close)local o
={close=close,resize=function(o)if n.open then n.size:to(UDim2.fromOffset(aq,o))
end end,onKey=function(o)n.onKey=o end,onRefresh=function(o)n.onRefresh=o end}
as(m,o)n.size:to(UDim2.fromOffset(aq,ar))end function am.isOpen(ao)return an~=
nil end function am.close(ao)close()end function am.key(ao,ap)if an==nil then
return false end if ap=='Escape'then close()return true end if an.onKey then an.
onKey(ap)return true end return false end return am end function ac.tooltip(aj,
ak)local al=aj.theme local am=aa('Frame',{Name='Tooltip',AutomaticSize=Enum.
AutomaticSize.XY,BackgroundTransparency=0,Visible=false,ZIndex=70,Parent=ak})al:
paint(am,'BackgroundColor3','raised')aa('UICorner',{CornerRadius=UDim.new(0,8),
Parent=am})local an=aa('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
Parent=am})al:paint(an,'Color','lineStrong')aa('UIPadding',{PaddingLeft=UDim.
new(0,10),PaddingRight=UDim.new(0,10),PaddingTop=UDim.new(0,7),PaddingBottom=
UDim.new(0,7),Parent=am})local ao=aa('TextLabel',{AutomaticSize=Enum.
AutomaticSize.XY,TextSize=16,TextWrapped=true,ZIndex=71,Parent=am})aa(
'UISizeConstraint',{MaxSize=Vector2.new(ag,400),Parent=ao})al:type(ao,'text')al:
paint(ao,'TextColor3','text')local ap={}local aq=nil function ap.hide(ar)if aq
then task.cancel(aq)aq=nil end am.Visible=false end local ar=ab.prop(am,
'Position',ah)function ap.showAt(as,at,b)as:hide()ao.Text=b am.Visible=true task
.defer(function()if not am.Visible then return end local c=ak.AbsoluteSize local
d=am.AbsoluteSize local e=at.AbsolutePosition-ak.AbsolutePosition local f=math.
clamp(e.X,ai,c.X-d.X-ai)local g=e.Y+at.AbsoluteSize.Y+3 local h=g+d.Y+ai>c.Y
local i=if h then e.Y-d.Y-3 else g ar:snap(UDim2.fromOffset(f,i+(if h then 8
else-8)))ar:to(UDim2.fromOffset(f,i))end)end function ap.schedule(as,at,b)as:
hide()aq=task.delay(af,function()aq=nil if at.Parent~=nil then as:showAt(at,b)
end end)end return ap end function ac.hover(aj)local ak={}local al=nil local 
function clear()local am=al if am then al=nil am:onHover(false)aj.tooltip:hide()
end end function ak.current(am)return al end function ak.enter(am,an)if al==an
then return end clear()al=an an:onHover(true)local ao=an.el local ap=if ao.
disabled and ao.disabledTip then ao.disabledTip else ao.tip if ap and ap~=''then
aj.tooltip:schedule(an.root,ap)end end function ak.leave(am,an)if al==an then
clear()end end ak.clear=clear function ak.verify(am,an)local ao=al if ao==nil
then return end local ap=ao.root local aq,ar=ap.AbsolutePosition,ap.AbsoluteSize
local as=an.X>=aq.X and an.Y>=aq.Y and an.X<=aq.X+ar.X and an.Y<=aq.Y+ar.Y if
not as or not ap.Visible or ap.Parent==nil or aj.popover:isOpen()then clear()end
end return ak end return ac end function a.x()local aa=a.cache.x if not aa then
aa={c=__modImpl()}a.cache.x=aa end return aa.c end end do local function 
__modImpl()local aa=a.m()local ab=a.f()local ac=a.j()local ad=a.b()local ae=a.p(
)local af={}local ag=14 local ah=8 local ai=6 local aj=26 local ak=10 local al=
15 local am=14 local an=14 local ao=38 local ap=12 local aq=112 local ar=260
local as=240 local at=420 local b=150 local c=20 local d=24 local e=18 local f=
22 local g=12 local h=3 local i=3 local j=16 local k={}k.__index=k function k.
nextId(l)l._ids+=1 return l._ids end function k._register(l,m,n)m._relayout=
function()l:_invalidate()end l.window:_registerElement(m,l,n)end function k.
_invalidate(l)if l._dirty then return end l._dirty=true task.defer(function()l.
_dirty=false if not l.destroyed then l:layout(not l._quiet)l._quiet=false end
end)end function k.section(l,m)local n=ae.new(l,m)table.insert(l.sections,n)l:
_invalidate()return n end function k.tabset(l)local m=ae.new(l,'')m.tabNames={}m
.activeTab=1 table.insert(l.sections,m)local n={}function n.tab(o,p)table.
insert(m.tabNames,p)local q=#m.tabNames local r=m:when(function()return m.
activeTab==q end)r.title=p local s=l._headers[m]if s then s:Destroy()l._headers[
m]=nil end l:_invalidate()return r end return n end function k.tabs(l,m)local n=
l:tabset()local o={}for p,q in m do table.insert(o,n:tab(q))end return o end
function k.hero(l,m)l._hero=m l:_invalidate()local n=l._heroView return{set=
function(o,p,q)m.title=p or m.title m.text=q or m.text local r=l._heroView or n
if r then r.refresh()end end}end local function buildHero(l)local m=l.window.ctx
local n=m.theme local o=l._hero local p=ab('Frame',{Name='Hero',ClipsDescendants
=true,Parent=l.canvas})local q=ab('ImageLabel',{AnchorPoint=Vector2.new(0.5,0.5)
,Position=UDim2.new(0.5,0,0,130),Size=UDim2.fromOffset(360,360),
BackgroundTransparency=1,BorderSizePixel=0,ImageTransparency=0.72,Parent=p})n:
paint(q,'ImageColor3','accent')m.art(q,'glow.png')if o.userId then local r=ab(
'ImageLabel',{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,16),Size
=UDim2.fromOffset(232,232),BackgroundTransparency=1,BorderSizePixel=0,Image=
string.format('rbxthumb://type=AvatarBust&id=%d&w=420&h=420',o.userId),Parent=p}
)ab('UIGradient',{Rotation=90,Transparency=NumberSequence.new({
NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.72,0),
NumberSequenceKeypoint.new(1,1)}),Parent=r})end local r=ab('TextLabel',{
AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,ag+4,1,-42),Size=UDim2.new(1,-
2*(ag+4),0,30),TextSize=24,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=2,Parent=
p})n:type(r,'display')n:paint(r,'TextColor3','text')local s=ab('TextLabel',{
AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,ag+4,1,-18),Size=UDim2.new(1,-
2*(ag+4),0,22),TextSize=14,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=2,Parent=
p})n:type(s,'text')n:paint(s,'TextColor3','muted')local t={root=p,refresh=
function()r.Text=o.title s.Text=o.text or''end}t.refresh()return t end local 
function buildHeader(l,m)local n=l.window.ctx local o=n.theme local p=ab('Frame'
,{Name='Header',Parent=l.canvas})if m.tabNames then local q={}local r=0 for s,t
in m.tabNames do local u=math.ceil(ac.width('textMedium',t,am))+an local v=ab(
'TextButton',{Position=UDim2.fromOffset(r,0),Size=UDim2.new(0,u,1,0),TextSize=am
,Text=t,TextXAlignment=Enum.TextXAlignment.Left,Parent=p})o:type(v,'text',true)q
[s]=v v.Activated:Connect(function()m.activeTab=s for w,x in q do n.tint(x,
'TextColor3',if w==m.activeTab then'text'else'faint')end l:_invalidate()end)o:
paint(v,'TextColor3',if s==m.activeTab then'text'else'faint')r+=u end return p
end local q=m.masterElement local r=ab('TextLabel',{Size=UDim2.fromScale(1,1),
TextSize=al,TextTruncate=Enum.TextTruncate.AtEnd,Text=if q then q.label else m.
title,Parent=p})o:type(r,'display')if q then local function ink(s)local t=if q.
value==true then'text'else'muted'if s then o:paint(r,'TextColor3',t)else n.tint(
r,'TextColor3',t)end end ink(true)q:on(function()ink()end)else o:paint(r,
'TextColor3','text')end return p end local function buildStrip(l,m,n)local o=l.
window.ctx local p=o.theme local q=ab('Frame',{Name='Strip',ZIndex=0,Parent=l.
canvas})local r=ab('Frame',{AnchorPoint=Vector2.new(1,0),Position=UDim2.
fromScale(1,0),Size=UDim2.new(0,1,1,0),BackgroundTransparency=0,Visible=not n,
ZIndex=0,Parent=q})p:paint(r,'BackgroundColor3','line')local s={root=q,rule=r}
local t=m.masterElement if t then local u=ab('Frame',{Size=UDim2.fromScale(1,
0.55),BackgroundTransparency=if t.value==true then 0 else 1,ZIndex=0,Parent=q})p
:paint(u,'BackgroundColor3','accentDim')ab('UIGradient',{Rotation=90,
Transparency=NumberSequence.new(0.45,1),Parent=u})local v=ad.prop(u,
'BackgroundTransparency',e)s.spring=v local w=t:on(function()if l.active then v:
to(if t.value==true then 0 else 1)else v:snap(if t.value==true then 0 else 1)end
end)s.destroy=function()w()v:destroy()end end return s end local function 
planStrip(l,m)local n=if l.flat then nil else l.masterElement local o,p={},{}for
q,r in l.rows do if r==n then continue end if l.flat or r:shown()then local s=aa
.measure(r)if s.fader then table.insert(o,{el=r,width=s.width})else table.
insert(p,{el=r,width=s.width,height=s.height})end end end local q=n~=nil or l.
title~=''or l.tabNames~=nil if#o==0 and#p==0 and not q then return nil end local
r=ag+(if q then aj+ak else 0)local s=m-ag-(if n then ao+ap else 0)local t=true
for u,v in p do local w=v.el.kind t=t and w~='label'and w~='divider'and w~=
'stat'end if t then local u,v={},{}for w,x in p do table.insert(if x.el.kind==
'toggle'then u else v,x)end table.move(v,1,#v,#u+1,u)p=u end local u={}local v=
nil for w,x in p do if v==nil or(v.y>r and v.y+x.height>s)then v={items={},y=r,
width=0}table.insert(u,v)end table.insert(v.items,x)v.width=math.max(v.width,x.
width)v.y+=x.height+ai end local w=0 for x,y in o do w+=y.width+ah end for x,y
in u do w+=y.width+ah end w=math.max(w-ah,0)local x=0 if l.tabNames then for y,z
in l.tabNames do x+=ac.width('textMedium',z,am)+an end elseif n then x=ac.width(
'display',n.label,al)else x=ac.width('display',l.title,al)end local y=math.max(w
,x,if n then aa.masterWidth(n)else 0)return{section=l,master=n,titled=q,faders=o
,columns=u,top=r,bottom=s,width=math.max(math.ceil(y)+2*ag,if l.flat then 0 else
aq)}end function k.layout(l,m)local n=l.frame if n==nil then return end l._live=
m==true and l._settled==true and l.active local o=l.window.ctx.uiScale()local p=
n.AbsoluteSize.Y/o if p<1 then return end local q={}local r=0 if l._hero then r
+=ar end for s,t in l.sections do local u=planStrip(t,p)if u then table.insert(q
,u)r+=u.width end end if l._emptyVisible then r=math.max(r,as)end local s=math.
max((l.window:minContentWidth()or 0)-r,0)local t=if#q>0 then s/#q else 0 local u
={}local v=0 if l._hero then table.insert(u,{hero=true,x=0,y=0,width=ar,height=p
})v=ar end for w,x in q do local y=x.section local z=math.floor(x.width+t)if not
y.flat then table.insert(u,{strip=y,last=w==#q,x=v,y=0,width=z,height=p})end if
x.titled then table.insert(u,{section=y,x=v+ag,y=ag,width=z-2*ag,height=aj})end
local A=v+ag for B,C in x.faders do table.insert(u,{el=C.el,x=A,y=x.top,width=C.
width,height=x.bottom-x.top})A+=C.width+ah end for B,C in x.columns do local D=x
.top for E,F in C.items do table.insert(u,{el=F.el,x=A,y=D,width=C.width,height=
F.height})D+=F.height+ai end A+=C.width+ah end if x.master then table.insert(u,{
el=x.master,x=v+ag,y=p-ag-ao,width=z-2*ag,height=ao})end v+=z end local w=math.
max(v,r)n.CanvasSize=UDim2.fromOffset(w,0)l._contentWidth=w local x=math.max(w-n
.AbsoluteSize.X/o,0)if l._scrollTarget and l._scrollTarget>x then l.
_scrollTarget=x end l._placements=u if l.active then l.window:_contentChanged(w,
m)end l:_applyPlacements()l:_materialize(true)l:_refreshThumb()l._live=false l.
_settled=l._settled or l.active end local function setRect(l,m,n)local o=UDim2.
fromOffset(m,n)if l._grow then l._grow:snap(o)else l.root.Size=o end end local 
function growTo(l,m,n,o)if l._grow==nil then l._grow=l:own(ad.prop(l.root,'Size'
,d))end l._grow:to(UDim2.fromOffset(m,n),o)end function k._applyPlacements(l)
local m={}local n={}for o,p in l._placements do if p.hero then if l._heroView
then l._heroView.root.Position=UDim2.fromOffset(p.x,p.y)l._heroView.root.Size=
UDim2.fromOffset(p.width,p.height)end elseif p.strip then n[p.strip]=true local
q=l._strips[p.strip]if q then q.root.Visible=true q.root.Position=UDim2.
fromOffset(p.x,p.y)q.root.Size=UDim2.fromOffset(p.width,p.height)q.rule.Visible=
not p.last end elseif p.section then m[p.section]=true local q=l._headers[p.
section]if q then q.Visible=true q.Position=UDim2.fromOffset(p.x,p.y)q.Size=
UDim2.fromOffset(p.width,p.height)end else m[p.el]=true local q=l._views[p.el]if
q and q.form~=aa.form(p.el)then q.destroy()l._views[p.el]=nil elseif q then l:
_place(q,p)end end end for o,p in l._headers do if not m[o]then p.Visible=false
end end for o,p in l._strips do if not n[o]then p.root.Visible=false end end for
o,p in l._views do if not m[o]and p.root.Visible and not p._folding then if l.
_live then p._folding=true growTo(p,p.root.Size.X.Offset,0,function()p._folding=
false p.root.Visible=false end)else p.root.Visible=false end end end end
function k._place(l,m,n)local o=m.root local p=UDim2.fromOffset(n.x,n.y)local q=
l._live local r=q and not o.Visible local s=m._folding==true m._folding=false o.
Visible=true if r then setRect(m,n.width,0)growTo(m,n.width,n.height)elseif s or
(q and o.Size~=UDim2.fromOffset(n.width,n.height))then growTo(m,n.width,n.height
)else setRect(m,n.width,n.height)end if q and not r and o.Position~=p then if m.
_slide==nil then m._slide=m:own(ad.prop(o,'Position',d))end m._slide:to(p)elseif
m._slide then m._slide:snap(p)else o.Position=p end end function k._materialize(
l,m)local n=l.frame local o=l._placements if n==nil or o==nil or not l.active
then return end local p=l.window.ctx.uiScale()local q=n.CanvasPosition.X/p if
not m and l._lastSync and math.abs(q-l._lastSync)<at/3 then return end l.
_lastSync=q local r,s=q-at,q+n.AbsoluteSize.X/p+at for t,u in o do local v=u.x
if v+u.width>=r and v<=s then if u.hero then if l._heroView==nil then local w=
buildHero(l)w.root.Position=UDim2.fromOffset(v,u.y)w.root.Size=UDim2.fromOffset(
u.width,u.height)l._heroView=w end elseif u.strip then if l._strips[u.strip]==
nil then local w=buildStrip(l,u.strip,u.last)w.root.Position=UDim2.fromOffset(v,
u.y)w.root.Size=UDim2.fromOffset(u.width,u.height)l._strips[u.strip]=w end
elseif u.section then if l._headers[u.section]==nil then local w=buildHeader(l,u
.section)w.Position=UDim2.fromOffset(v,u.y)w.Size=UDim2.fromOffset(u.width,u.
height)l._headers[u.section]=w end elseif l._views[u.el]==nil then u.el._shownOn
=l local w,x=xpcall(aa.build,debug.traceback,l.window.ctx,u.el)if w then x.root.
Position=UDim2.fromOffset(v,u.y)x.root.Size=UDim2.fromOffset(u.width,if l._live
then 0 else u.height)x.root.Parent=l.canvas l._views[u.el]=x if l._live then
growTo(x,u.width,u.height)end else warn('sottUI: control '..tostring(u.el.id)..
' failed: '..tostring(x))end end end end end function k._refreshThumb(l)local m=
l.thumb if m==nil then return end local n=l.window.ctx.uiScale()local o=l.frame.
AbsoluteSize.X/n local p=l._contentWidth or 0 if p<=o+1 or not l.active then m.
Visible=false return end m.Visible=true local q=o-2*j local r=math.max(q*o/p,48)
local s=q-r local t=l.frame.CanvasPosition.X/n/math.max(p-o,1)m.Size=UDim2.
fromOffset(r,h)m.Position=UDim2.new(0,j+t*s,1,-(h+i))end function k.scrollTo(l,m
,n)local o=l.frame if o==nil then return end local p=l.window.ctx.uiScale()local
q=math.max((l._contentWidth or 0)-o.AbsoluteSize.X/p,0)local r=math.clamp(m,0,q)
l._scrollTarget=r if n then l._scroll:snap(r)else l._scroll:to(r)end end
function k.wheel(l,m)if l.frame==nil or l.frame.ScrollingEnabled then return end
local n=l._scrollTarget or l.frame.CanvasPosition.X/l.window.ctx.uiScale()l:
scrollTo(n-m*b)end function k.viewOf(l,m)return l._views[m]end function k.mount(
l,m)if l.frame then return end local n=l.window.ctx local o=ab('ScrollingFrame',
{Name=l.name,Size=UDim2.fromScale(1,1),Visible=false,ScrollingDirection=Enum.
ScrollingDirection.X,ScrollingEnabled=n.touch,Parent=m})local p=ab('Frame',{Name
='Canvas',Size=UDim2.fromScale(1,1),Parent=o})local q=ab('Frame',{Name='Thumb',
BackgroundTransparency=0,Visible=false,ZIndex=5,Parent=m})ab('UICorner',{
CornerRadius=UDim.new(1,0),Parent=q})n.theme:paint(q,'BackgroundColor3',
'lineStrong')l.frame=o l.canvas=p l.thumb=q l._scroll=ad.new(0,c,function(r)o.
CanvasPosition=Vector2.new(r*n.uiScale(),0)end)l._enter=ad.prop(p,'Position',f)o
:GetPropertyChangedSignal('CanvasPosition'):Connect(function()l:_materialize()l:
_refreshThumb()end)o:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
l:_materialize(true)l:_refreshThumb()end)end function k.showList(l,m,n)l.
sections={{title='',rows=m,flat=true}}for o,p in m do p._shownOn=l end if l.
frame then if l._empty==nil then local o=l.window.ctx.theme l._empty=ab(
'TextLabel',{Position=UDim2.fromOffset(ag,ag),Size=UDim2.new(1,-2*ag,0,26),
TextSize=15,Parent=l.frame})o:type(l._empty,'text')o:paint(l._empty,'TextColor3'
,'muted')end l._empty.Text=n or''l._empty.Visible=n~=nil l._emptyVisible=n~=nil
end l:_invalidate()end function k.adopt(l)for m,n in l._views do m._view=n m.
_shownOn=l if n.refresh then n.refresh()end for o,p in n.addonChips or{}do o.
_view=p if p.refresh then p.refresh()end end end end function k.setActive(l,m,n)
l.active=m if l.frame then l.frame.Visible=m if not m then l.thumb.Visible=false
end end if m then l:layout()if l._enter then if n then l._enter:snap(UDim2.new()
)else l._enter:snap(UDim2.fromOffset(g,0))l._enter:to(UDim2.new())end end end
end function k.destroy(l)l.destroyed=true for m,n in l._views do n.destroy()end
l._views={}for m,n in l._strips do if n.destroy then n.destroy()end end l.
_strips={}if l._scroll then l._scroll:destroy()l._enter:destroy()end if l.frame
then l.frame:Destroy()l.thumb:Destroy()end end function af.new(l,m)return
setmetatable({name=m,window=l,sections={},active=false,destroyed=false,_ids=0,
_dirty=false,_headers={},_strips={},_views={},_placements=nil},k)end return af
end function a.y()local aa=a.cache.y if not aa then aa={c=__modImpl()}a.cache.y=
aa end return aa.c end end do local function __modImpl()local aa=a.f()local ab=
UDim2.fromOffset(16,72)local ac=44 return function(ad,ae,af)local ag=aa(
'TextButton',{Name='Open',Position=ab,Size=UDim2.fromOffset(ac,ac),
BackgroundTransparency=0,TextSize=24,Text='s',Visible=false,ZIndex=50,Parent=ad}
)ae:type(ag,'display')ae:paint(ag,'BackgroundColor3','accent')ae:paint(ag,
'TextColor3','onAccent')ag.Activated:Connect(af)return ag end end function a.z()
local aa=a.cache.z if not aa then aa={c=__modImpl()}a.cache.z=aa end return aa.c
end end do local function __modImpl()local aa=a.n()local ab={}local function rgb
(ac)return Color3.fromRGB(bit32.band(bit32.rshift(ac,16),255),bit32.band(bit32.
rshift(ac,8),255),bit32.band(ac,255))end local ac={base=rgb(0x50706),surface=
rgb(0xc0f0d),raised=rgb(0x151a17),line=rgb(0x191f1c),lineStrong=rgb(0x2a342f),
text=rgb(0xebe8da),muted=rgb(0x97a39c),faint=rgb(0x56615b),accent=rgb(0x7ee0c4),
accentHover=rgb(0x9bebd4),accentDim=rgb(0x16362d),onAccent=rgb(0x6231b),danger=
rgb(0xe5604d)}local ad='rbxasset://fonts/families/BuilderSans.json'local ae=
'rbxasset://fonts/families/BuilderSans.json'local af=
'rbxasset://fonts/families/RobotoMono.json'local ag={}ag.__index=ag function ab.
defaults()return table.clone(ac)end function ab.new(ah)local ai=(ab.defaults())
for aj,ak in(ah or{})do ai[aj]=ak end local aj={tokens=ai,fonts={text=ad,display
=ae,mono=af},changed=aa.new(),_paints={},_types={},_count=0}return((
setmetatable(aj,ag)))end local ah=2000 local function sweep(ai)for aj in ai.
_paints do if aj.Parent==nil then ai._paints[aj]=nil ai._types[aj]=nil end end
for aj in ai._types do if aj.Parent==nil then ai._types[aj]=nil end end end
function ag.paint(ai,aj,ak,al)local am=ai._paints[aj]if am==nil then am={}ai.
_paints[aj]=am ai._count+=1 if ai._count%ah==0 then task.defer(sweep,ai)end end
am[ak]=al aj[ak]=ai.tokens[al]end function ag.face(ai,aj,ak)if aj=='display'then
return Font.new(ai.fonts.display,Enum.FontWeight.SemiBold)end if aj=='mono'then
return Font.new(ai.fonts.mono,Enum.FontWeight.Medium)end return Font.new(ai.
fonts.text,if ak then Enum.FontWeight.Medium else Enum.FontWeight.Regular)end
function ag.type(ai,aj,ak,al)ai._types[aj]={family=ak,medium=al==true}aj.
FontFace=ai:face(ak,al)end function ag.forget(ai,aj)ai._paints[aj]=nil ai._types
[aj]=nil end function ag.apply(ai,aj)for ak,al in aj do ai.tokens[ak]=al end for
ak,al in ai._paints do for am,an in al do pcall(function()ak[am]=ai.tokens[an]
end)end end ai.changed:fire()end function ag.setFonts(ai,aj,ak,al)ai.fonts.mono=
al or ai.fonts.mono ai.fonts.text=aj or ai.fonts.text ai.fonts.display=ak or ai.
fonts.display for am,an in ai._types do pcall(function()am.FontFace=ai:face(an.
family,an.medium)end)end end return ab end function a.A()local aa=a.cache.A if
not aa then aa={c=__modImpl()}a.cache.A=aa end return aa.c end end do local 
function __modImpl()local aa=a.b()local ab={}local ac=26 function ab.new(ad)
local ae={}return function(af,ag,ah,ai)local aj=ae[af]if aj==nil then aj={}ae[af
]=aj end local ak=aj[ag]if ak==nil then ak=aa.prop(af,ag,ai or ac)aj[ag]=ak end
ak:to(ad.tokens[ah])end end return ab end function a.B()local aa=a.cache.B if
not aa then aa={c=__modImpl()}a.cache.B=aa end return aa.c end end do local 
function __modImpl()local aa=a.q()local ab=a.a()local ac=a.r()local ad=a.s()
local ae=a.u()local af=a.v()local ag=a.t()local ah=a.f()local ai=a.j()local aj=a
.b()local ak=a.w()local al=a.x()local am=a.y()local an=a.h()local ao=a.p()local
ap=a.z()local aq=a.n()local ar=a.A()local as=a.B()local at={}local b='main'local
c=[[https://raw.githubusercontent.com/interestng/sottUI/%s/fonts/]]local d={
'glow.png','shadow.png','ticks.png'}local e=420 local f=48 local g=14 local h=
1120 local i=16 local j=32 local k=0.35 local l=14 local m=14 local n=7 local o=
15 local p=14 local q=18 local r=168 local s=30 local t=30 local u=9 local v=18
local w=2 local x=22 local y=20 local z=26 local A=20 local B=24 local C=12
local D={}D.__index=D local function randomName()local E=table.create(C)for F=1,
C do E[F]=string.char(math.random(97,122))end return table.concat(E)end local 
function encode(E)return ab.service('HttpService'):JSONEncode(E)end local 
function decode(E)local F,G=pcall(function()return ab.service('HttpService'):
JSONDecode(E)end)return if F then G else nil end function D._registerElement(E,F
,G,H)if G==E._resultsPage then return end F._pageName=G.name F._page=G if H then
if E.elements[F.id]then error('sottUI: element id used twice: '..F.id,3)end E.
elements[F.id]=F end if F.kind~='divider'and F.kind~='label'and F.kind~='stat'
then table.insert(E.ordered,F)end if F.kind=='toggle'and F.spec.primary then F:
on(function()E:_drawLamps()end)E:_drawLamps()end end function D._drawLamps(E)if
E._lampsQueued or E.destroyed then return end E._lampsQueued=true task.defer(
function()E._lampsQueued=false if E.destroyed then return end local F={}for G,H
in E.ordered do if H.kind=='toggle'and H.spec.primary and H.value==true and not
H.disabled then F[H._page]=true end end for G,H in E._tabs do local I=F[G]==true
if H.on~=I then H.on=I H.glow:to(if I then 0.3 else 1)E.ctx.tint(H.dot,
'BackgroundColor3',if I then'accent'else'lineStrong')end end end)end function D.
_setPerson(E,F)E._person=F end function D.minContentWidth(E)return E._minWidth
or 0 end function D._screenWidth(E)return E._gui.AbsoluteSize.X/E._scale.Scale-2
*i end function D._contentChanged(E,F,G)if E._showing==nil then return end local
H=math.min(h,E:_screenWidth())local I=math.clamp(F,math.min(E._minWidth or 0,H),
H)E._width=I if E._autoCentre then E._autoCentre=false local J=E._gui.
AbsoluteSize local K=E._scale.Scale E._at=Vector2.new((J.X-I*K)/2,(J.Y-e*K)/2)E.
_position:snap(UDim2.fromOffset(E._at.X,E._at.Y))end E:_keepOnScreen(true)local
J=UDim2.fromOffset(I,if E.isOpen then e else 0)if G or E._rising or E._size:
moving()then E._size:to(J)else E._size:snap(J)end end function D._clamped(E,F)
local G=E._scale.Scale local H=E._gui.AbsoluteSize local I,J=(E._width or 0)*G,e
*G return Vector2.new(math.clamp(F.X,i,math.max(H.X-I-i,i)),math.clamp(F.Y,i,
math.max(H.Y-J-i,i)))end function D._keepOnScreen(E,F)local G=E._at if G==nil
then return end local H=E:_clamped(G)if H~=G then E._at=H if F then E._position:
to(UDim2.fromOffset(H.X,H.Y))else E._position:snap(UDim2.fromOffset(H.X,H.Y))end
end end function D._show(E,F,G)if E._showing==F then return end E.ctx.hover.
clear()E.ctx.popover:close()E.keys:cancel()local H=E._showing if H then H:
setActive(false)end E._showing=F if F~=E._resultsPage then E._lastPage=F end E.
_rising=not G F:setActive(true,G)E._rising=false F:adopt()E:_syncMarker(G)E:
_saveState()end function D._syncMarker(E,F)local G=E.ctx.tint local H=nil for I,
J in E._tabs do local K=E._showing==I G(J.button,'TextColor3',if K then'text'
else'muted')if K then H=J.button end end if H==nil then E._markerSize:to(UDim2.
fromOffset(0,w))return end local I=E._scale.Scale local J=(H.AbsolutePosition.X-
E._top.AbsolutePosition.X)/I local K=UDim2.new(0,J+m,1,-w)local L=UDim2.
fromOffset(H.AbsoluteSize.X/I-2*m,w)if F or E._markerSize.target==nil or E.
_markerSize.target.X.Offset==0 then E._markerAt:snap(K)E._markerSize:snap(L)else
E._markerAt:to(K)E._markerSize:to(L)end end local function addTab(E,F,G,H)local
I=E.ctx local J=I.theme local K=math.ceil(ai.width('textMedium',G,l))+2*m+o
local L=ah('TextButton',{Name=G,Size=UDim2.new(0,K,1,0),TextSize=l,Text=G,
TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=H,ZIndex=3,Parent=E._row})
ah('UIPadding',{PaddingLeft=UDim.new(0,m+o),Parent=L})J:type(L,'text',true)J:
paint(L,'TextColor3','muted')local M=ah('ImageLabel',{AnchorPoint=Vector2.new(
0.5,0.5),Position=UDim2.new(0,-o+n/2,0.5,0),Size=UDim2.fromOffset(24,24),
BackgroundTransparency=1,BorderSizePixel=0,ImageTransparency=1,ZIndex=2,Parent=L
})J:paint(M,'ImageColor3','accent')I.art(M,'glow.png')local N=ah('Frame',{
AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0,-o+n/2,0.5,0),Size=UDim2.
fromOffset(n,n),BackgroundTransparency=0,ZIndex=3,Parent=L})ah('UICorner',{
CornerRadius=UDim.new(1,0),Parent=N})J:paint(N,'BackgroundColor3','lineStrong')E
._tabs[F]={button=L,dot=N,glow=E._maid:add(aj.prop(M,'ImageTransparency',A)),on=
false}L.Activated:Connect(function()if E._box.Text~=''then E._box.Text=''end E:
_show(F)end)L.MouseEnter:Connect(function()if E._showing~=F then I.tint(L,
'TextColor3','text')end end)L.MouseLeave:Connect(function()if E._showing~=F then
I.tint(L,'TextColor3','muted')end end)end function D.page(E,F)local G=am.new(E,F
)table.insert(E.pages,G)addTab(E,G,F,2+#E.pages)G:mount(E._body)E:_drawLamps()if
not E._firstQueued then E._firstQueued=true task.defer(function()if E.destroyed
or E._showing then return end local H=E.pages[1]for I,J in E.pages do if J.name
==E._savedPage then H=J end end if H then E:_show(H,true)end end)end return G
end function D._query(E,F)if F==''then if E._showing==E._resultsPage then E:
_show(E._lastPage or E.pages[1])end E._resultsPage:showList({})return end local
G={}for H,I in E.ordered do if I.visible~=false then table.insert(G,I)end end
local H=an.settings(F,G,B)E._resultsPage:showList(H,if#H==0 then
'Nothing matches'else nil)E:_show(E._resultsPage)end function D.showPage(E,F)for
G,H in E.pages do if H.name==F then E._box.Text=''E:_show(H)return end end end
function D.show(E,F,G)local H=E.pages[F]if H then E:_show(H,G)end end function D
.reveal(E,F)local G=F._page if G then E:setOpen(true)E:showPage(G.name)end end
function D.setOpen(E,F)if E.isOpen==F or E.destroyed then return end E.isOpen=F
if E._opener then E._opener.Visible=not F end E.ctx.hover.clear()E.ctx.popover:
close()E.ctx.tooltip:hide()E.keys:cancel()if not F and E._dialogClose then E.
_dialogClose()end local G=E._width or E._minWidth or 0 if F then E._root.Visible
=true E._modal.Visible=true E:_guardCursor(true)if E._at==nil then local H=E.
_scale.Scale local I=E._gui.AbsoluteSize E._at=Vector2.new((I.X-G*H)/2,(I.Y-e*H)
/2)end E._position:snap(UDim2.fromOffset(E._at.X,E._at.Y))E._size:to(UDim2.
fromOffset(G,e))E._shadowFade:to(k)else E._modal.Visible=false E:_guardCursor(
false)E._box:ReleaseFocus()E._box.Text=''E._shadowFade:to(1)E._size:to(UDim2.
fromOffset(G,0),function()if not E.isOpen then E._root.Visible=false end end)end
E.visibilityChanged:fire(F)end function D._guardCursor(E,F)local G=ab.service(
'UserInputService')if F then E._gameCursor=G.MouseIconEnabled G.MouseIconEnabled
=true if E._cursorGuard==nil then E._cursorGuard=G:GetPropertyChangedSignal(
'MouseIconEnabled'):Connect(function()if not G.MouseIconEnabled then E.
_gameCursor=false G.MouseIconEnabled=true end end)end else if E._cursorGuard
then E._cursorGuard:Disconnect()E._cursorGuard=nil end if E._gameCursor~=nil
then G.MouseIconEnabled=E._gameCursor E._gameCursor=nil end end end function D.
toggle(E)E:setOpen(not E.isOpen)end function D.notify(E,F)if E.destroyed then
return end E.ctx.notify(F)end function D.setTheme(E,F)E.ctx.theme:apply(F)end
function D.setScale(E,F)E._scale.Scale=math.clamp(F,0.7,1.5)E:_keepOnScreen(
false)E:_saveState()end function D.setSubtitle(E,F)E._subtitleText=F end
function D._saveState(E)local F=E._files if F==nil or E._stateFile==nil or E.
_stateQueued then return end E._stateQueued=true task.delay(0.5,function()E.
_stateQueued=false if not E.destroyed then local G=E._at local H=E._lastPage F.
write(E._stateFile,encode({scale=E._scale.Scale,boxX=G and G.X,boxY=G and G.Y,
page=H and H.name}))end end)end function D.dialog(E,F,G)if E.destroyed then
return false end aa.open(E,F,G)return true end function D.find(E,F)return E.
elements[F]end function D.snapshot(E)local F={}for G,H in E.elements do if H.
saved then local I=H.value if H.kind=='color'then I={hex=I.color:ToHex(),alpha=I
.alpha}elseif H.kind=='key'then I={key=I.key,mode=I.mode,modifiers=I.modifiers,
toggled=H.toggled==true}end F[G]=I end end return F end function D.restore(E,F)
for G,H in F do local I=E.elements[G]if I and I.saved then if I.kind=='color'and
type(H)=='table'then I:set({color=Color3.fromHex(H.hex or'ffffff'),alpha=H.alpha
})elseif I.kind=='key'and type(H)=='table'then I:set(H)I.toggled=H.toggled==true
else I:set(H)end end end end function D.destroy(E)if E.destroyed then return end
E.destroyed=true E:_guardCursor(false)E.ctx.notifications:destroy()for F,G in E.
pages do G:destroy()end E._resultsPage:destroy()E.ctx.input:destroy()E._maid:
clean()E.visibilityChanged:clear()if E._registry and E._registry.current==E then
E._registry.current=nil end end function at.new(E)local F=E._registry if F and F
.current then F.current:destroy()end local G=ag.new()local H=ar.new(E.theme)
local I=ae.new()local J=ab.service('UserInputService')local K=E.touch==true or(J
.TouchEnabled and not J.MouseEnabled)local L=ah('ScreenGui',{Name=randomName(),
IgnoreGuiInset=true,ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.
Sibling,DisplayOrder=E.displayOrder or 10000})ab.protect(L)L.Parent=ab.
guiParent()G:add(L)local M=ab.files()local N=E.folder or'sottui_console'local O=
E.stateFile or(N..'/window.json')local P=nil if M then M.folder(N)local Q=M.
read(O)P=Q and decode(Q)end if type(P)~='table'then P={}end local Q=ah('Frame',{
Name='Root',Size=UDim2.fromScale(1,1),Visible=false,Parent=L})local R=tonumber(P
.scale)or(if L.AbsoluteSize.X<800 then 0.8 else 1)local S=ah('Frame',{Name=
'Layer',Size=UDim2.fromScale(1,1),ZIndex=100,Parent=L})local T=ah('TextButton',{
Name='Modal',Size=UDim2.fromOffset(0,0),Modal=true,Visible=false,Parent=Q})local
U=ah('Frame',{Name='Assembly',Size=UDim2.fromOffset(0,0),ZIndex=3,Parent=Q})
local V=ah('UIScale',{Scale=R,Parent=U})local W=ah('ImageLabel',{Name='Shadow',
Position=UDim2.fromOffset(-j,-j),Size=UDim2.new(1,2*j,1,2*j),
BackgroundTransparency=1,BorderSizePixel=0,ImageColor3=Color3.new(0,0,0),
ImageTransparency=1,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(48,48,80
,80),ZIndex=1,Parent=U})local X=ah('Frame',{Name='Box',Size=UDim2.fromScale(1,1)
,BackgroundTransparency=0,ClipsDescendants=true,Active=true,ZIndex=2,Parent=U})
ah('UICorner',{CornerRadius=UDim.new(0,g),Parent=X})H:paint(X,'BackgroundColor3'
,'base')local Y=ah('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
Thickness=1,Parent=X})H:paint(Y,'Color','line')local Z=ah('Frame',{Name='Top',
Size=UDim2.new(1,0,0,f),Active=true,ZIndex=3,Parent=X})local _=ah('Frame',{
AnchorPoint=Vector2.new(0,1),Position=UDim2.fromScale(0,1),Size=UDim2.new(1,0,0,
1),BackgroundTransparency=0,ZIndex=3,Parent=Z})H:paint(_,'BackgroundColor3',
'line')local au=ah('Frame',{Name='Row',Size=UDim2.fromScale(1,1),ZIndex=3,Parent
=Z})local av=ah('UIListLayout',{FillDirection=Enum.FillDirection.Horizontal,
VerticalAlignment=Enum.VerticalAlignment.Center,SortOrder=Enum.SortOrder.
LayoutOrder,Parent=au})local aw=E.mark or'sottoro'local ax=math.ceil(ai.width(
'mono',aw,p))+2*q-8 local ay=ah('TextLabel',{Name='Mark',Size=UDim2.new(0,ax,1,0
),TextSize=p,Text=aw,LayoutOrder=1,ZIndex=3,Parent=au})ah('UIPadding',{
PaddingLeft=UDim.new(0,q),Parent=ay})H:type(ay,'mono')H:paint(ay,'TextColor3',
'accent')local az=ah('Frame',{Name='Right',AnchorPoint=Vector2.new(1,0),Position
=UDim2.new(1,-u,0,0),Size=UDim2.new(0,r+t+6,1,0),ZIndex=3,Parent=Z})local aA=ah(
'Frame',{Name='Field',AnchorPoint=Vector2.new(0,0.5),Position=UDim2.fromScale(0,
0.5),Size=UDim2.fromOffset(r,s),BackgroundTransparency=0,ZIndex=3,Parent=az})ah(
'UICorner',{CornerRadius=UDim.new(0,8),Parent=aA})H:paint(aA,'BackgroundColor3',
'raised')local aB=ah('UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
Thickness=1,Transparency=1,Parent=aA})H:paint(aB,'Color','accent')local aC=ah(
'TextBox',{Name='Search',Position=UDim2.fromOffset(12,0),Size=UDim2.new(1,-24,1,
0),TextSize=14,Text='',PlaceholderText='Search',ClearTextOnFocus=false,
ClipsDescendants=true,ZIndex=4,Parent=aA})H:type(aC,'text')H:paint(aC,
'TextColor3','text')H:paint(aC,'PlaceholderColor3','muted')local aD=ah('Frame',{
Name='Marker',Size=UDim2.fromOffset(0,w),BackgroundTransparency=0,ZIndex=4,
Parent=Z})ah('UICorner',{CornerRadius=UDim.new(1,0),Parent=aD})H:paint(aD,
'BackgroundColor3','accent')local aE=ah('Frame',{Name='Body',Position=UDim2.
fromOffset(0,f),Size=UDim2.new(1,0,0,e-f),ClipsDescendants=true,ZIndex=2,Parent=
X})local aF=setmetatable({ctx=nil,pages={},elements={},ordered={},isOpen=false,
destroyed=false,visibilityChanged=aq.new(),_maid=G,_gui=L,_root=Q,_layer=S,
_modal=T,_scale=V,_box=aC,_body=aE,_top=Z,_row=au,_marker=aD,_tabs={},_at=if
tonumber(P.boxX)and tonumber(P.boxY)then Vector2.new(P.boxX,P.boxY)else nil,
_autoCentre=not(tonumber(P.boxX)and tonumber(P.boxY)),_savedPage=P.page,
_subtitleText=E.subtitle,_files=M,_stateFile=O,_dialogIds=0,_registry=F},D)if F
then F.current=aF end local aG={ready={},waiting={}}local aH={theme=H,input=I,
touch=K,assets={},glyph=ad.new(H),tint=as.new(H),art=function(aH,aI)local aJ=aG.
ready[aI]if aJ then aH.Image=aJ return end aG.waiting[aI]=aG.waiting[aI]or{}
table.insert(aG.waiting[aI],aH)end,uiScale=function()return V.Scale end,
popoverTop=function()return 8 end,dialogAt=function(aH)local aI=S.AbsoluteSize
return UDim2.fromOffset(math.floor((aI.X-aH*V.Scale)/2),math.floor(aI.Y*0.2))end
,isShowing=function(aH)if not aF.isOpen then return false end if aH._page==nil
and aH._shownOn==nil then return true end return aF._showing~=nil and(aH.
_shownOn==aF._showing or aH._page==aF._showing)end,setScrollLocked=function(aH)
local aI=aF._showing if aI and aI.frame and K then aI.frame.ScrollingEnabled=not
aH end end}aF.ctx=aH aH.art(W,'shadow.png')local aI=al.popover(aH,S)aH.popover=
aI aH.tooltip=al.tooltip(aH,S)aH.hover=al.hover(aH)aH.notifications=ak.new(aH,S)
aH.notify=function(aJ)aH.notifications:show(aJ)end aF.keys=af.new(I,ab,function(
)return aF.isOpen end)aH.keys=aF.keys aF._position=G:add(aj.prop(U,'Position',y)
)aF._size=G:add(aj.prop(U,'Size',x))aF._shadowFade=G:add(aj.prop(W,
'ImageTransparency',y))aF._markerAt=G:add(aj.prop(aD,'Position',z))aF.
_markerSize=G:add(aj.prop(aD,'Size',z))aF._resultsPage=am.new(aF,'Results')aF.
_resultsPage:mount(aE)local aJ=ah('TextButton',{Name='Close',AnchorPoint=Vector2
.new(1,0.5),Position=UDim2.fromScale(1,0.5),Size=UDim2.fromOffset(t,t),
BackgroundTransparency=1,ZIndex=4,Parent=az})ah('UICorner',{CornerRadius=UDim.
new(0,8),Parent=aJ})H:paint(aJ,'BackgroundColor3','raised')local aK=aH.glyph.
cross(aJ,'muted')aK.AnchorPoint=Vector2.new(0.5,0.5)aK.Position=UDim2.fromScale(
0.5,0.5)aK.ZIndex=5 local aL=G:add(aj.prop(aJ,'BackgroundTransparency',z))aJ.
MouseEnter:Connect(function()aL:to(0)aH.tooltip:schedule(aJ,'Close menu')end)aJ.
MouseLeave:Connect(function()aL:to(1)aH.tooltip:hide()end)aJ.Activated:Connect(
function()aF:setOpen(false)end)local aM=G:add(aj.prop(aB,'Transparency',z))aC.
Focused:Connect(function()aM:to(0.2)end)aC.FocusLost:Connect(function()aM:to(1)
end)aC:GetPropertyChangedSignal('Text'):Connect(function()aF:_query(aC.Text)end)
Z.InputBegan:Connect(function(aN)local aO=aN.UserInputType if aO~=Enum.
UserInputType.MouseButton1 and aO~=Enum.UserInputType.Touch then return end
local aP=if aO==Enum.UserInputType.Touch then I:at(aN)else I:pointer()local aQ=
aF._at if aQ==nil then return end aF._autoCentre=false I:capture(function(aR)aF.
_at=aF:_clamped(aQ+(aR-aP))aF._position:snap(UDim2.fromOffset(aF._at.X,aF._at.Y)
)end,function()aF:_saveState()end,if aO==Enum.UserInputType.Touch then aN else
nil)end)local function fitBar()local aN=math.ceil(av.AbsoluteContentSize.X/V.
Scale)+v+r+t+6+u if aN==aF._minWidth then return end aF._minWidth=aN local aO=aF
._showing if aO then aO:_invalidate()end task.defer(function()if not aF.
destroyed then aF:_syncMarker(true)end end)end av:GetPropertyChangedSignal(
'AbsoluteContentSize'):Connect(fitBar)task.defer(fitBar)G:add(L:
GetPropertyChangedSignal('AbsoluteSize'):Connect(function()aF:_keepOnScreen(
false)local aN=aF._showing if aN then aN._quiet=true aN:_invalidate()end end))I.
moved:connect(function(aN)aH.hover:verify(aN)end)I.wheel:connect(function(aN)if
not aF.isOpen or aH.popover:isOpen()then return end local aO=aF._showing if aO==
nil or aO.frame==nil then return end local aP=I:pointer()local aQ,aR=aO.frame.
AbsolutePosition,aO.frame.AbsoluteSize if aP.X>=aQ.X and aP.Y>=aQ.Y and aP.X<=aQ
.X+aR.X and aP.Y<=aQ.Y+aR.Y then aO:wheel(aN)end end)I.keyDown:connect(function(
aN,aO)if aN.UserInputType~=Enum.UserInputType.Keyboard then return end local aP=
aN.KeyCode.Name if aF.keys:swallowed(aP)then return end if aH.popover:key(aP)
then return end if aP=='Escape'and aF._dialogClose then aF._dialogClose()return
end if aP=='Escape'and aC.Text~=''then aC.Text=''return end if aO or I:typing()
then return end if aF.isOpen and aP=='K'then if J:IsKeyDown(Enum.KeyCode.
LeftControl)or J:IsKeyDown(Enum.KeyCode.RightControl)then aC:CaptureFocus()end
end end)G:add(H.changed:connect(function()local aN=table.clone(aF.pages)table.
insert(aN,aF._resultsPage)for aO,aP in aN do for aQ,aR in aP._views do pcall(
function()if aR.retint then aR:retint()end aR.refresh()end)end end end))local aN
=ao.new({window=aF,nextId=function()return 0 end,_register=function(aN,aO,aP)if
aP then aF.elements[aO.id]=aO end aO._pageName=''end,_invalidate=function()end},
'')aF.menuKey=aN:key('__menu',{label='Menu',default=E.key or'RightShift',mode=
'Toggle',saved=false,onPress=function()aF:toggle()end})local aO=ab.service(
'RunService')aj.setAttach(function(aP)return aO.PreRender:Connect(aP)end)if E.
fonts~=false and M then G:add(task.defer(function()local aP=E.fontTag or b local
aQ=string.format(c,aP)local aR=N..'/fonts-'..aP local aS=ac.load(aR,aQ,encode)if
aF.destroyed then return end if aS.text or aS.display or aS.mono then H:
setFonts(aS.text,aS.display,aS.mono)end for aT,aU in d do local aV=ac.image(aR,
aQ,aU)if aF.destroyed then return end if aV then aG.ready[aU]=aV local aW=aG.
waiting[aU]or{}for aX,aY in aW do aY.Image=aV end end aG.waiting[aU]=nil end end
))end if K then aF._opener=ap(L,H,function()aF:setOpen(true)end)end if E.
autoShow~=false then task.defer(function()aF:setOpen(true)end)end return aF end
function at.setVersion(au)b=au end return at end function a.C()local aa=a.cache.
C if not aa then aa={c=__modImpl()}a.cache.C=aa end return aa.c end end end
local aa=a.a()local ab=a.b()local ac=a.e()local ad=a.C()local ae='0.5.1-console'
local function registry()local af=aa.global('getgenv')local ag=if type(af)==
'function'then af()else _G local ah=ag.__sottui if type(ah)~='table'then ah={
current=nil}ag.__sottui=ah end return ah end local af={version=ae,motion=ab}ad.
setVersion('v'..ae)function af.window(ag)local ah=table.clone(ag or{})ah.
_registry=registry()return ad.new(ah)end function af.current()return registry().
current end function af.obsidian()return ac.new(af)end return af