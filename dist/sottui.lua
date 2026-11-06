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
Parent=n.root})local r=n.el.spec.primary==true n.ctx.theme:paint(q,
'BackgroundColor3',if r then'accent'else'accentDim')if not r then local s=b(
'Frame',{Name='Edge',Size=UDim2.new(0,l,1,0),BackgroundTransparency=0,ZIndex=2,
Parent=q})n.ctx.theme:paint(s,'BackgroundColor3','accent')end q.ClipsDescendants
=true n._bar=q n._barSize=n:own(c.prop(q,'Size',k))end local r=if o then UDim2.
new(1,0,1,-2)else UDim2.new(0,0,1,-2)if p or not n.ctx.isShowing(n.el)then n.
_barSize:snap(r)else n._barSize:to(r)end end function m.ink(n,o,p,q)local r=n.
ctx.theme.tokens local s=n._inks[o]if q or not n.ctx.isShowing(n.el)then if s
then s:snap(r[p])else o.TextColor3=r[p]end return end if s==nil then s=n:own(c.
prop(o,'TextColor3',j))n._inks[o]=s end s:to(r[p])end function m.flash(n)n:
pressed(true)n:onHover(true)task.delay(0.22,function()if n.root.Parent then n:
pressed(false)n:onHover(false)end end)end function m.retint(n)end function m.
refreshName(n)local o=n.el if o.disabled then n.name.RichText=true n.name.Text=
'<s>'..o.label..'</s>'else n.name.RichText=false n.name.Text=o.label end end
function d.new(n,o,p)local q=p or{}local r=q.indent or 0 local s=b('TextButton',
{Name=o.kind,Size=UDim2.new(1,0,0,q.height or d.HEIGHT),BackgroundTransparency=1
,ClipsDescendants=true,Active=not q.inert})n.theme:paint(s,'BackgroundColor3',
'raised')local t=b('TextLabel',{Name='Name',Position=UDim2.fromOffset(d.PAD+r,0)
,Size=UDim2.new(1,-(2*d.PAD+r),1,0),TextSize=d.NAME,TextWrapped=true,
TextTruncate=Enum.TextTruncate.AtEnd,Text=o.label,ZIndex=3,Parent=s})n.theme:
type(t,'text',true)local u=setmetatable({root=s,name=t,el=o,ctx=n,chips={},
indent=r,_cleanups={},_inks={},_hover=false},m)u:refreshName()if q.inert then u.
onHover=function()end u.pressed=function()end else s.MouseEnter:Connect(function
()n.hover:enter(u)end)local v=nil s.InputBegan:Connect(function(w)local x=w.
UserInputType if x==Enum.UserInputType.MouseButton1 then if not o.disabled then
u:pressed(true)end elseif x==Enum.UserInputType.Touch then if not o.disabled
then u:pressed(true)end v=task.delay(0.45,function()v=nil local y=if o.disabled
and o.disabledTip then o.disabledTip else o.tip if y and y~=''then n.tooltip:
showAt(s,y)end end)end end)local w=n.input.pointerUp:connect(function()if u.
_lean then u:pressed(false)end if v then task.cancel(v)v=nil end end)u:
onCleanup(function()w()if v then task.cancel(v)end end)end u.destroy=function()n
.hover:leave(u)for v,w in u._cleanups do pcall(w)end s:Destroy()end return u end
return d end function a.l()local b=a.cache.l if not b then b={c=__modImpl()}a.
cache.l=b end return b.c end end do local function __modImpl()local b=a.g()local
c=a.i()local d=a.k()local e=a.f()local f=a.j()local g=a.b()local h=a.l()local i=
{}local j=h.PAD local k=16 local l=62 local m=25 local n=62 local o=12 local p=4
local q=40 local r=4 local s=12 local t=6 local u=17 local v=42 local w=90 local
x=3 local y=24 local z=22 local A=30 local B=16 i.MASTER_HEIGHT=l i.
SLIDER_HEIGHT=n local C={}local function indentOf(D)local E=D._shownOn if E and
E.sections[1]and E.sections[1].flat then return 0 end local F=D.section local G=
F and(F._root or F)if G and G.masterElement and G.masterElement~=D then return k
end return 0 end local function newRow(D,E,F)local G=F or{}G.indent=G.indent or
indentOf(E)local H=h.new(D,E,G)local I=E._shownOn if I and I.sections[1]and I.
sections[1].flat then local J=E.section and(E.section._root or E.section)local K
=J and J.masterElement if K and K~=E then local L=H.refreshName H.refreshName=
function(M)L(M)M.name.Text=K.label..' '..E.label end H:refreshName()end end if G
.indent>0 then local J=e('Frame',{Name='Stretch',Size=UDim2.new(0,3,1,0),
BackgroundTransparency=0,ZIndex=1,Parent=H.root})D.theme:paint(J,
'BackgroundColor3','accentDim')end return H end local function addons(D,E,F,G)
local H={}local function reflow()local I=G for J,K in H do K.root.Position=UDim2
.new(1,-(j+I),0.5,0)I+=K.width+K.gap end D.name.Size=UDim2.new(1,-(2*j+D.indent+
I),1,0)end local function place(I,J)J.root.AnchorPoint=Vector2.new(1,0.5)J.root.
ZIndex=4 J.root.Parent=D.root J.gap=if I.kind=='key'then 6 else 0 J.onFit=reflow
table.insert(H,J)I._view=J table.insert(D.chips,J)D:onCleanup(function()I._view=
nil J.destroy()end)end for I,J in F.addons or{}do if J.kind=='color'and not J.
spec.chipless then place(J,b.swatch(E,J))end end for I,J in F.addons or{}do if J
.kind=='key'and not J.spec.chipless then place(J,d.build(E,J))end end reflow()
return G end function C.toggle(D,E)local F=E.spec.primary==true local G=newRow(D
,E,{height=if F then l else nil})local H=D.theme if F then H:type(G.name,
'display')G.name.TextSize=m G.name.TextWrapped=false end local I=e('TextLabel',{
Name='State',AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-j,0,0),Size=
UDim2.new(0,y,1,0),TextSize=h.NAME,TextXAlignment=Enum.TextXAlignment.Right,
ZIndex=3,Parent=G.root})H:type(I,'text',true)local J=nil local K=nil local L=nil
local M=y+42 if F then J=e('TextButton',{AnchorPoint=Vector2.new(1,0),Position=
UDim2.new(1,-(j+y+4),0,0),Size=UDim2.new(0,34,1,0),ZIndex=4,Parent=G.root})K=D.
glyph.chevron(J,'muted','down')L=D.glyph.chevron(J,'muted','up')for N,O in{K,L}
do O.AnchorPoint=Vector2.new(0.5,0.5)O.Position=UDim2.fromScale(0.5,0.5)end J.
Activated:Connect(function()E.section:togglePeek()G.refresh()end)end addons(G,D,
E,M)local function draw(N)local O=E.value==true G:lit(O,N)local P=F and O G:ink(
G.name,if E.disabled then'faint'elseif P then'onAccent'elseif O then'text'else
'muted',N)I.Text=if O then'on'else'off'G:ink(I,if E.disabled then'line'elseif P
then'onAccent'elseif O then'accentHover'else'muted',N)for Q,R in G.chips do R.
setInk(P)if R.setMuted then R.setMuted(not O)end end if J then J.Visible=not O
and E.section.hasOptions==true K.Visible=not E.section.peeking L.Visible=E.
section.peeking==true end end G.root.Activated:Connect(function()if not E.
disabled then E:set(not E.value)end end)G.refresh=function()G:refreshName()draw(
false)end draw(true)return G end local function formatted(D,E)local F=D.spec if
F.format then local G,H=pcall(F.format,D,E)if G and H~=nil then return tostring(
H)end end return string.format('%.'..(F.decimals or 0)..'f',E)..(F.suffix or'')
end function C.slider(D,E)local F=newRow(D,E,{height=n})local G=D.theme local H=
E.spec local I=F.root local J=F.indent local function ratio()local K=H.max-H.min
return if K<=0 then 0 else(E.value-H.min)/K end F.name.Position=UDim2.
fromOffset(j+J,8)F.name.Size=UDim2.new(1,-(2*j+J+96),0,24)F.name.TextWrapped=
false F._rest=nil local K=e('TextLabel',{Name='Readout',AnchorPoint=Vector2.new(
1,0),Position=UDim2.new(1,-j,0,8),Size=UDim2.new(0,96,0,24),TextSize=u,
TextXAlignment=Enum.TextXAlignment.Right,ZIndex=4,Parent=I})G:type(K,'text',true
)local L=e('Frame',{Name='Ruler',AnchorPoint=Vector2.new(0,1),Position=UDim2.
new(0,j+J,1,-6),Size=UDim2.new(1,-(2*j+J),0,o),ClipsDescendants=true,ZIndex=2,
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
Right,ZIndex=3,Parent=H})G:type(I,'text',true)local J=D.glyph.chevron(H,'muted')
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
_relayout if h then h()end end if f._onLabel then f._onLabel()end redraw(f)end
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
table.insert(h,g)g.host=f redraw(f)end function d.shown(f)if not f.visible or(f.
kind=='label'and f.label=='')then return false end local g=f.guard return g==nil
or g()end return c end function a.o()local b=a.cache.o if not b then b={c=
__modImpl()}a.cache.o=b end return b.c end end do local function __modImpl()
local b=a.o()local c={}local d={}d.__index=d local function add(e,f,g,h,i,j)
local k=b.new(f,g or(f..'#'..tostring(e._page:nextId())),h,i,j)k.section=e k.
guard=e._guard e._page:_register(k,g~=nil)table.insert(e.rows,k)local l=e._root
or e if l.masterElement then l.hasOptions=true end e._page:_invalidate()return k
end function d.toggle(e,f,g)local h=add(e,'toggle',f,g.label or f,g,g.default==
true)if g.onChanged then h:on(g.onChanged)end return h end function d.master(e,f
,g)g.primary=true local h=e:toggle(f,g)e.masterElement=h local i=e._page h:on(
function()i:_invalidate()end)local j=e._guard e._guard=function()if j and not j(
)then return false end return h.value==true or e.peeking==true end return h end
function d.togglePeek(e)e.peeking=not e.peeking e._page:_invalidate()end
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
theme local o=j._layer local p=k.width or j.width local q=k.maxHeight or 340
local r=60 local s=c('TextButton',{Size=UDim2.fromScale(1,1),
BackgroundTransparency=1,BackgroundColor3=Color3.new(0,0,0),ZIndex=50,Parent=o})
local t=e.prop(s,'BackgroundTransparency',22)local u=c('Frame',{Position=m.
dialogAt(p),Size=UDim2.fromOffset(p,0),BackgroundTransparency=0,ClipsDescendants
=true,Active=true,ZIndex=51,Parent=o})n:paint(u,'BackgroundColor3','base')c(
'UIScale',{Scale=m.uiScale(),Parent=u})local v=c('UIStroke',{ApplyStrokeMode=
Enum.ApplyStrokeMode.Border,Parent=u})n:paint(v,'Color','line')local w=c(
'TextLabel',{Position=UDim2.fromOffset(20,16),Size=UDim2.new(1,-40,0,40),
TextSize=24,Text=k.title or'',ZIndex=52,Parent=u})n:type(w,'display')n:paint(w,
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
UDim2.fromOffset(20,I),Size=UDim2.new(1,-40,0,46),BackgroundTransparency=0,
TextSize=17,Text=k.done or'Done',ZIndex=52,Parent=u})n:type(J,'text',true)n:
paint(J,'BackgroundColor3','raised')n:paint(J,'TextColor3','text')local K=I+46+
14 local L=e.prop(u,'Size',h)L:to(UDim2.fromOffset(p,K))local function close()if
A then return end A=true j._dialogClose=nil s.Active=false for M,N in C.rows do
if j.elements[N.id]==N then j.elements[N.id]=nil end for O,P in N.addons or{}do
j.keys:unregister(P)if j.elements[P.id]==P then j.elements[P.id]=nil end end end
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
local d=a.j()local e=a.b()local f=a.l()local g=a.p()local h={}local i=0 local j=
34 local k=6 local l=0.9 local m=52 local n=18 local o=2 local p=360 local q=100
local r=24 local s=28 local t=30 local u={}u.__index=u local function heightOf(v
,w)local x=v.kind if x=='slider'then return b.SLIDER_HEIGHT end if x=='stat'then
return 36 end if x=='divider'then return if v.label==''then 8 else 28 end if x==
'label'and not v.addons then if not v.spec.wrap then return 30 end if v.
_measured then return v._measured end local y=string.gsub(v.label,'<[^>]+>','')
local z=math.ceil(d.width('text',y,16)/math.max(w-2*f.PAD,40))return z*21+12 end
if x=='toggle'and v.spec.primary then return b.MASTER_HEIGHT end return f.HEIGHT
end function u.nextId(v)v._ids+=1 return v._ids end function u._register(v,w,x)w
._relayout=function()v:_invalidate()end v.window:_registerElement(w,v,x)end
function u._invalidate(v)if v._dirty then return end v._dirty=true task.defer(
function()v._dirty=false if not v.destroyed then v:layout(not v._quiet)v._quiet=
false end end)end function u.section(v,w)local x=g.new(v,w)table.insert(v.
sections,x)v:_invalidate()return x end function u.tabset(v)local w=g.new(v,'')w.
tabNames={}w.activeTab=1 table.insert(v.sections,w)local x={}function x.tab(y,z)
table.insert(w.tabNames,z)local A=#w.tabNames local B=w:when(function()return w.
activeTab==A end)B.title=z local C=v._headers[w]if C then C:Destroy()v._headers[
w]=nil end v:_invalidate()return B end return x end function u.tabs(v,w)local x=
v:tabset()local y={}for z,A in w do table.insert(y,x:tab(A))end return y end
function u.hero(v,w)v.window:_setPerson(w)return{set=function(x,y,z)w.title=y or
w.title w.text=z or w.text v.window:_setPerson(w)end}end local function 
buildHeader(v,w)local x=v.window.ctx local y=x.theme local z=c('Frame',{Name=
'Header',Parent=v.canvas})if w.tabNames then local A={}local B=f.PAD for C,D in
w.tabNames do local E=math.ceil(d.width('display',D,15))+18 local F=c(
'TextButton',{Position=UDim2.fromOffset(B,0),Size=UDim2.new(0,E,1,-6),TextSize=
15,Text=D,TextXAlignment=Enum.TextXAlignment.Left,Parent=z})y:type(F,'display')A
[C]=F F.Activated:Connect(function()w.activeTab=C for G,H in A do y:paint(H,
'TextColor3',if G==w.activeTab then'text'else'faint')end v:_invalidate()end)y:
paint(F,'TextColor3',if C==w.activeTab then'text'else'faint')B+=E end else local
A=c('TextLabel',{Position=UDim2.fromOffset(f.PAD,0),Size=UDim2.new(1,-2*f.PAD,1,
-6),TextSize=23,TextYAlignment=Enum.TextYAlignment.Bottom,Text=w.title,Parent=z}
)y:type(A,'display')y:paint(A,'TextColor3','text')end return z end function u.
layout(v,w)local x=v.frame if x==nil then return end v._live=w==true and v.
_settled==true and v.active local y=v.window.ctx.uiScale()local z=x.AbsoluteSize
.X/y if z<1 then return end local A=i local B={}local C=v._expansion if C then C
.y=nil end local D=false for E,F in v.sections do local G={}for H,I in F.rows do
if F.flat or I:shown()then table.insert(G,I)end end if#G>0 or F.tabNames then if
(F.title~=''or F.tabNames)and not F.masterElement then if D then A+=n-o end
table.insert(B,{section=F,y=A,height=m})A+=m end for H,I in G do local J=
heightOf(I,z)table.insert(B,{el=I,y=A,height=J})A+=J if C and C.el==I then C.y=A
A+=C.height end end local H=F.masterElement~=nil and#G==1 A+=if H then o else n
D=H end end if C and C.y==nil then v._live=false v:collapse()return end local E=
A+(if v.sections[1]and v.sections[1].flat then k else j)if v._emptyText then E=
math.max(E,54)end x.CanvasSize=UDim2.fromOffset(0,E)local F=math.max(E-x.
AbsoluteSize.Y/y,0)if v._scrollTarget and v._scrollTarget>F then v._scrollTarget
=F v._scroll:snap(F)end v._contentHeight=E v._placements=B v._width=z if C then
local G=UDim2.fromOffset(0,C.y or 0)if v._live then C.at:to(G)else C.at:snap(G)
end C.frame.Size=UDim2.new(1,0,0,C.frame.Size.Y.Offset)end v:_applyPlacements()v
:_materialize(true)v:_refreshThumb()if v.active then v.window:_contentChanged(E,
v._live)end v._live=false v._settled=v._settled or v.active end local function 
growTo(v,w,x)if v._grow==nil then v._grow=v:own(e.prop(v.root,'Size',s))end v.
_grow:to(UDim2.new(1,0,0,w),x)end local function setHeight(v,w)local x=UDim2.
new(1,0,0,w)if v._grow then v._grow:snap(x)else v.root.Size=x end end function u
._applyPlacements(v)local w={}for x,y in v._placements do if y.section then w[y.
section]=true local z=v._headers[y.section]if z then z.Visible=true z.Size=UDim2
.new(1,0,0,y.height)local A=UDim2.fromOffset(0,y.y)local B=v._headerSlides[y.
section]if v._live and z.Position~=A then if B==nil then B=e.prop(z,'Position',s
)v._headerSlides[y.section]=B end B:to(A)elseif B then B:snap(A)else z.Position=
A end end else w[y.el]=true local z=v._views[y.el]if z then v:_place(z,y)end end
end for x,y in v._headers do if not w[x]then y.Visible=false end end for x,y in
v._views do if not w[x]and y.root.Visible and not y._folding then if v._live
then y._folding=true growTo(y,0,function()y._folding=false y.root.Visible=false
end)else y.root.Visible=false end end end end function u._place(v,w,x)local y=w.
root local z=UDim2.fromOffset(0,x.y)local A=v._live local B=A and not y.Visible
local C=w._folding==true w._folding=false y.Visible=true if B then setHeight(w,0
)growTo(w,x.height)elseif C then growTo(w,x.height)else setHeight(w,x.height)end
if A and not B and y.Position~=z then if w._slide==nil then w._slide=w:own(e.
prop(y,'Position',s))end w._slide:to(z)elseif w._slide then w._slide:snap(z)else
y.Position=z end end function u._materialize(v,w)local x=v.frame local y=v.
_placements if x==nil or y==nil or not v.active then return end local z=v.window
.ctx.uiScale()local A=x.CanvasPosition.Y/z if not w and v._lastSync and math.
abs(A-v._lastSync)<p/3 then return end v._lastSync=A local B,C=A-p,A+x.
AbsoluteSize.Y/z+p for D,E in y do local F=E.y if F+E.height>=B and F<=C then if
E.section then if v._headers[E.section]==nil then local G=buildHeader(v,E.
section)G.Position=UDim2.fromOffset(0,F)G.Size=UDim2.new(1,0,0,E.height)v.
_headers[E.section]=G end elseif v._views[E.el]==nil then E.el._shownOn=v local
G,H=xpcall(b.build,debug.traceback,v.window.ctx,E.el)if G then H.root.Position=
UDim2.fromOffset(0,F)H.root.Size=UDim2.new(1,0,0,if v._live then 0 else E.height
)H.root.Parent=v.canvas v._views[E.el]=H v._rows[H.root]=E.el if v._live then
growTo(H,E.height)end else warn('sottUI: row '..tostring(E.el.id)..' failed: '..
tostring(H))end end end end end function u.expand(v,w,x,y)local z=w local A=nil
while z and z~=v.canvas do if v._rows[z]then A=v._rows[z]break end z=z.Parent
end if A==nil then return false end local B=v._expansion v:collapse()if B and B.
el==A then return true end local C=v.window.ctx local D=c('Frame',{Name=
'Expansion',Size=UDim2.new(1,0,0,0),BackgroundTransparency=0,ClipsDescendants=
true,ZIndex=2,Parent=v.canvas})C.theme:paint(D,'BackgroundColor3','base')local E
=c('Frame',{Size=UDim2.new(1,0,0,x),Parent=D})local F={el=A,frame=D,height=x,at=
e.prop(D,'Position',s),grow=e.prop(D,'Size',t)}v._expansion=F local G={close=
function()if v._expansion==F then v:collapse()end end,resize=function(G)if v.
_expansion~=F or F.height==G then return end F.height=G E.Size=UDim2.new(1,0,0,G
)F.grow:to(UDim2.new(1,0,0,G))v:_invalidate()end,onKey=function(G)F.onKey=G end,
onRefresh=function(G)F.onRefresh=G end}v:layout(true)F.at:snap(UDim2.fromOffset(
0,F.y or 0))y(E,G)F.grow:to(UDim2.new(1,0,0,x))local H=C.uiScale()local I=v.
frame.AbsoluteSize.Y/H local J=v._scrollTarget or v.frame.CanvasPosition.Y/H
local K=(F.y or 0)+x if K>J+I then v:scrollTo(K-I+12)end return true end
function u.collapse(v)local w=v._expansion if w==nil then return end v.
_expansion=nil w.grow:to(UDim2.new(1,0,0,0),function()w.grow:destroy()w.at:
destroy()w.frame:Destroy()end)v:layout(true)end function u.expansionKey(v,w)
local x=v._expansion if x==nil then return false end if w=='Escape'then v:
collapse()return true end if x.onKey and(w=='Up'or w=='Down'or w=='Return')then
x.onKey(w)return true end return false end function u.pointerInExpansion(v,w)
local x=v._expansion if x==nil then return false end local y,z=x.frame.
AbsolutePosition,x.frame.AbsoluteSize return w.X>=y.X and w.Y>=y.Y and w.X<=y.X+
z.X and w.Y<=y.Y+z.Y end function u._refreshThumb(v)local w=v.thumb if w==nil
then return end local x=v.window.ctx.uiScale()local y=v.frame.AbsoluteSize.Y/x
local z=v._contentHeight or 0 if z<=y+1 or not v.active then w.Visible=false
return end w.Visible=true v._thumbStamp=(v._thumbStamp or 0)+1 local A=v.
_thumbStamp task.delay(l,function()if v._thumbStamp==A and not v.destroyed then
w.Visible=false end end)local B=math.max(y*y/z,40)local C=y-B local D=v.frame.
CanvasPosition.Y/x/math.max(z-y,1)w.Size=UDim2.new(0,2,0,B)w.Position=UDim2.new(
1,-4,0,D*C)end function u.scrollTo(v,w,x)local y=v.frame if y==nil then return
end local z=v.window.ctx.uiScale()local A=math.max((v._contentHeight or 0)-y.
AbsoluteSize.Y/z,0)local B=math.clamp(w,0,A)v._scrollTarget=B if x then v.
_scroll:snap(B)else v._scroll:to(B)end end function u.wheel(v,w)if v.frame==nil
or v.frame.ScrollingEnabled then return end local x=v._scrollTarget or v.frame.
CanvasPosition.Y/v.window.ctx.uiScale()v:scrollTo(x-w*q)end function u.rowY(v,w)
if v._placements==nil then v:layout()end for x,y in v._placements or{}do if y.el
==w then return y.y end end return nil end function u.viewOf(v,w)return v._views
[w]end function u.mount(v,w)if v.frame then return end local x=v.window.ctx
local y=c('ScrollingFrame',{Name=v.name,Size=UDim2.fromScale(1,1),Visible=false,
ScrollingEnabled=x.touch,Parent=w})local z=c('Frame',{Name='Canvas',Size=UDim2.
fromScale(1,1),Parent=y})local A=c('Frame',{Name='Thumb',BackgroundTransparency=
0,Visible=false,ZIndex=5,Parent=w})x.theme:paint(A,'BackgroundColor3',
'lineStrong')v.frame=y v.canvas=z v.thumb=A v._scroll=e.new(0,r,function(B)y.
CanvasPosition=Vector2.new(0,B*x.uiScale())end)y:GetPropertyChangedSignal(
'CanvasPosition'):Connect(function()v:_materialize()v:_refreshThumb()end)local B
=0 y:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()local C=y.
AbsoluteSize.X if C~=B then B=C v._quiet=true v:_invalidate()else v:
_materialize(true)v:_refreshThumb()end end)end function u.showList(v,w,x)v.
sections={{title='',rows=w,flat=true}}for y,z in w do z._shownOn=v end v.
_emptyText=x if v.frame then if v._empty==nil then local y=v.window.ctx.theme v.
_empty=c('TextLabel',{Position=UDim2.fromOffset(f.PAD,8),Size=UDim2.new(1,-2*f.
PAD,0,36),TextSize=17,Parent=v.frame})y:type(v._empty,'text')y:paint(v._empty,
'TextColor3','faint')end v._empty.Text=x or''v._empty.Visible=x~=nil end v:
_invalidate()end function u.adopt(v)for w,x in v._views do w._view=x w._shownOn=
v if x.refresh then x.refresh()end end end function u.setActive(v,w)v.active=w
if v.frame then v.frame.Visible=w if not w then v.thumb.Visible=false end end if
w then v:layout()end end function u.destroy(v)v.destroyed=true for w,x in v.
_views do x.destroy()end v._views={}for w,x in v._headerSlides do x:destroy()end
if v._expansion then v._expansion.grow:destroy()v._expansion.at:destroy()end if
v._scroll then v._scroll:destroy()end if v.frame then v.frame:Destroy()v.thumb:
Destroy()end end function h.new(v,w)return setmetatable({name=w,window=v,
sections={},active=false,destroyed=false,_ids=0,_dirty=false,_headers={},
_headerSlides={},_views={},_rows={},_placements=nil},u)end return h end function
a.y()local b=a.cache.y if not b then b={c=__modImpl()}a.cache.y=b end return b.c
end end do local function __modImpl()local b=a.f()local c=UDim2.fromOffset(16,72
)local d=44 return function(e,f,g)local h=b('TextButton',{Name='Open',Position=c
,Size=UDim2.fromOffset(d,d),BackgroundTransparency=0,TextSize=24,Text='s',
Visible=false,ZIndex=50,Parent=e})f:type(h,'display')f:paint(h,
'BackgroundColor3','accent')f:paint(h,'TextColor3','onAccent')h.Activated:
Connect(g)return h end end function a.z()local b=a.cache.z if not b then b={c=
__modImpl()}a.cache.z=b end return b.c end end do local function __modImpl()
local b=a.n()local c={}local function rgb(d)return Color3.fromRGB(bit32.band(
bit32.rshift(d,16),255),bit32.band(bit32.rshift(d,8),255),bit32.band(d,255))end
local d={base=rgb(0x7100d),surface=rgb(0x141c18),raised=rgb(0x1e2b25),line=rgb(
0x1a2d27),lineStrong=rgb(0x2f4a40),text=rgb(0xebe8da),muted=rgb(0xb4c2b8),faint=
rgb(0x5f756b),accent=rgb(0x7ee0c4),accentHover=rgb(0x9bebd4),accentDim=rgb(
0x1f4a3e),onAccent=rgb(0xb1a13),danger=rgb(0xe5604d)}local e=
'rbxasset://fonts/families/BuilderSans.json'local f=
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
return c end function a.A()local b=a.cache.A if not b then b={c=__modImpl()}a.
cache.A=b end return b.c end end do local function __modImpl()local b=a.b()local
c={}local d=26 function c.new(e)local f={}return function(g,h,i,j)local k=f[g]if
k==nil then k={}f[g]=k end local l=k[h]if l==nil then l=b.prop(g,h,j or d)k[h]=l
end l:to(e.tokens[i])end end return c end function a.B()local b=a.cache.B if not
b then b={c=__modImpl()}a.cache.B=b end return b.c end end do local function 
__modImpl()local b=a.q()local c=a.a()local d=a.r()local e=a.s()local f=a.u()
local g=a.v()local h=a.t()local i=a.f()local j=a.j()local k=a.b()local l=a.w()
local m=a.x()local n=a.y()local o=a.h()local p=a.p()local q=a.z()local r=a.n()
local s=a.A()local t=a.B()local u={}local v='main'local w=
[[https://raw.githubusercontent.com/interestng/sottUI/%s/fonts/]]local x=420
local y=64 local z=64 local A=76 local B=19 local C=24 local D=17 local E=16
local F=1 local G=64 local H=124 local I=40 local J=44 local K=28 local L=34
local M=12 local N=600 local O=560 local P=38 local Q=28 local R=30 local S=30
local T=4 local U=6 local V=24 local W=12 local X={}X.__index=X local function 
randomName()local Y=table.create(W)for Z=1,W do Y[Z]=string.char(math.random(97,
122))end return table.concat(Y)end local function encode(Y)return c.service(
'HttpService'):JSONEncode(Y)end local function decode(Y)local Z,_=pcall(function
()return c.service('HttpService'):JSONDecode(Y)end)return if Z then _ else nil
end function X._registerElement(Y,Z,_,aa)if _==Y._resultsPage or _==Y._onPage
then return end Z._pageName=_.name Z._page=_ if aa then if Y.elements[Z.id]then
error('sottUI: element id used twice: '..Z.id,3)end Y.elements[Z.id]=Z end if Z.
kind~='divider'and Z.kind~='label'and Z.kind~='stat'then table.insert(Y.ordered,
Z)end if Z.kind=='toggle'then Z:on(function()if Y._showing==Y._onPage and Y.
isOpen then Y:_fillOn()end if Z.spec.primary then Y:_drawChips()end end)if Z.
spec.primary then Z._onLabel=function()Y:_drawChips()end if Z.value==true then Y
:_drawChips()end end end end function X._drawChips(aa)if aa._chipsQueued or aa.
destroyed then return end aa._chipsQueued=true task.defer(function()aa.
_chipsQueued=false if aa.destroyed then return end local Y={}for Z,_ in aa.
ordered do if _.kind=='toggle'and _.spec.primary and _.value==true and not _.
disabled and _:shown()then table.insert(Y,_)end end for Z,_ in aa._chips do _:
Destroy()end table.clear(aa._chips)local Z=aa.ctx.theme local _=0 local function 
widthOf(ab)return math.ceil(j.width('display',ab,D))+2*E end local function add(
ab,ac,ad)local ae=widthOf(ab)local af=i('TextButton',{Name='Chip',Size=UDim2.
new(0,ae,1,0),BackgroundTransparency=0,TextSize=D,Text=ab,LayoutOrder=ac,ZIndex=
3,Parent=aa._chipRow})_+=ae+F Z:type(af,'display')Z:paint(af,'BackgroundColor3',
'surface')Z:paint(af,'TextColor3','accent')af.MouseEnter:Connect(function()aa.
ctx.tint(af,'BackgroundColor3','accent')aa.ctx.tint(af,'TextColor3','onAccent')
end)af.MouseLeave:Connect(function()aa.ctx.tint(af,'BackgroundColor3','surface')
aa.ctx.tint(af,'TextColor3','accent')end)af.Activated:Connect(ad)table.insert(aa
._chips,af)end local ab=aa._scale.Scale local ac=aa:_dockPoint()local ad=ac+(aa.
_dockWidth or 0)*ab/2 local ae=(aa._gui.AbsoluteSize.X-ad)/ab-F-M for af,ag in Y
do local ah=#Y-af local ai=widthOf(ag.label)+(if ah>0 then G else 0)if af>U or _
+ai>ae then add('+'..(ah+1),100+af,function()aa:_fillOn()aa:_show(aa._onPage)end
)break end add(ag.label,100+af,function()ag:set(false)end)end aa._chipRow.Size=
UDim2.new(0,math.max(_-F,0),1,0)end)end function X._setPerson(aa,ab)aa._person=
ab end function X._contentChanged(aa,ab,ac)if aa._showing==nil then return end
local ad=aa._scale.Scale local ae=aa._sheetRoom/ad-M local af=math.min(ab,N,ae)
local ag=UDim2.new(0,aa._sheetWidth,0,af)aa._sheetFade.Visible=ab>af if ac or aa
._sheetRise then aa._panelSize:to(ag)else aa._panelSize:snap(ag)end end function
X._placeSheet(aa)local ab=aa._scale.Scale local ac,ad=aa:_dockPoint()local ae=ac
-(aa._dockWidth or 0)*ab/2 local af=ad-y*ab local ag=aa._gui.AbsoluteSize.Y
local ah=af>=ag/2 aa._sheetAbove=ah aa._sheetRoom=if ah then af else ag-ad aa.
_panel.AnchorPoint=Vector2.new(0,if ah then 1 else 0)aa._panel.Position=UDim2.
fromOffset(math.floor(ae),math.floor(if ah then af else ad))end function X.
_dockPoint(aa)local ab=aa._dockAt if ab then return ab.X,ab.Y end local ac=aa.
_gui.AbsoluteSize return ac.X/2,ac.Y-A end function X._home(aa)local ab=aa.
_dockAt return if ab then UDim2.fromOffset(ab.X,ab.Y)else UDim2.new(0.5,0,1,-A)
end function X._away(aa)return aa:_home()+UDim2.fromOffset(0,y*aa._scale.Scale+A
+M)end function X._clampDock(aa)local ab=aa._dockAt if ab==nil then return end
local ac=aa._scale.Scale local ad=aa._gui.AbsoluteSize local ae=(aa._dockWidth
or 0)*ac/2 aa._dockAt=Vector2.new(math.clamp(ab.X,math.min(ae+M,ad.X/2),math.
max(ad.X-ae-M,ad.X/2)),math.clamp(ab.Y,y*ac+M,math.max(ad.Y-M,y*ac+M)))end
function X._show(aa,ab,ac)if aa._showing==ab then return end aa.ctx.hover.clear(
)aa.ctx.popover:close()aa.keys:cancel()local ad=aa._showing if ad then ad:
setActive(false)end local ae=aa._leaving if ae and ae~=ab then ae:setActive(
false)end aa._leaving=nil aa._showing=ab aa:_placeSheet()aa._sheetRise=not ac ab
:setActive(true)aa._sheetRise=false ab:adopt()aa:_syncMarker(ac)aa:_saveState()
end function X._hideSheet(aa)local ab=aa._showing if ab==nil then return end aa.
ctx.hover.clear()aa.ctx.popover:close()aa.keys:cancel()aa._showing=nil aa.
_leaving=ab aa._panelSize:to(UDim2.new(0,aa._sheetWidth,0,0),function()if aa.
_leaving==ab then aa._leaving=nil ab:setActive(false)end end)aa:_syncMarker()end
function X._syncMarker(aa,ab)local ac=aa.ctx.tint local ad=nil for ae,af in aa.
_words do local ag=aa._showing==ae if af:IsA('TextButton')and af.Text~=''then
ac(af,'TextColor3',if ag then'text'else'muted')end if ag then ad=af end end if
ad==nil then aa._markerSize:to(UDim2.fromOffset(0,T))return end aa.ctx.theme:
paint(aa._marker,'BackgroundColor3',if ad==aa._homeAvatar then'onAccent'else
'accent')local ae=aa._scale.Scale local af=(ad.AbsolutePosition.X-aa._dock.
AbsolutePosition.X)/ae local ag=UDim2.fromOffset(af,if aa._sheetAbove==false
then y-T else 0)local ah=UDim2.fromOffset(ad.AbsoluteSize.X/ae,T)if ab or aa.
_markerSize.target==nil or aa._markerSize.target.X.Offset==0 then aa._markerAt:
snap(ag)else aa._markerAt:to(ag)end if ab then aa._markerSize:snap(ah)else aa.
_markerSize:to(ah)end end local function bindWord(aa,ab,ac)aa._words[ab]=ac ac.
Activated:Connect(function()if aa._box.Text~=''then aa._box.Text=''end if aa.
_showing==ab then aa:_hideSheet()else aa:_show(ab)end end)end local function 
addWord(aa,ab,ac,ad)local ae=aa.ctx.theme local af=math.ceil(j.width('display',
ac,B))+2 local ag=i('TextButton',{Name=ac,Size=UDim2.new(0,af,1,0),TextSize=B,
Text=ac,LayoutOrder=ad,ZIndex=3,Parent=aa._row})ae:type(ag,'display')ae:paint(ag
,'TextColor3','muted')bindWord(aa,ab,ag)ag.MouseEnter:Connect(function()if aa.
_showing~=ab then aa.ctx.tint(ag,'TextColor3','text')end end)ag.MouseLeave:
Connect(function()if aa._showing~=ab then aa.ctx.tint(ag,'TextColor3','muted')
end end)end function X.page(aa,ab)local ac=n.new(aa,ab)table.insert(aa.pages,ac)
if ab=='Home'and aa._homeAvatar then bindWord(aa,ac,aa._homeAvatar)else addWord(
aa,ac,ab,2+#aa.pages)end ac:mount(aa._panel)return ac end function X._fillOn(aa)
local ab,ac={},{}for ad,ae in aa.ordered do if ae.kind=='toggle'and ae.value==
true then table.insert(if ae.spec.primary then ab else ac,ae)end end if#ab==0
then ab=ac end aa._onPage:showList(ab,if#ab==0 then'Nothing is on'else nil)end
function X._query(aa,ab)if ab==''then if aa._showing==aa._resultsPage then aa:
_hideSheet()end aa._resultsPage:showList({})return end local ac=o.settings(ab,aa
.ordered,V)aa._resultsPage:showList(ac,if#ac==0 then'Nothing matches'else nil)aa
:_show(aa._resultsPage)end function X.showPage(aa,ab)for ac,ad in aa.pages do if
ad.name==ab then aa._box.Text=''aa:_show(ad)return end end end function X.show(
aa,ab,ac)local ad=aa.pages[ab]if ad then aa:_show(ad,ac)end end function X.
reveal(aa,ab)local ac=ab._page if ac then aa:setOpen(true)aa:showPage(ac.name)
end end function X.setOpen(aa,ab)if aa.isOpen==ab or aa.destroyed then return
end aa.isOpen=ab if aa._opener then aa._opener.Visible=not ab end aa.ctx.hover.
clear()aa.ctx.popover:close()aa.ctx.tooltip:hide()aa.keys:cancel()if not ab and
aa._dialogClose then aa._dialogClose()end if ab then aa._root.Visible=true aa.
_modal.Visible=true aa:_guardCursor(true)aa._at:to(aa:_home())aa:_drawChips()
else aa._modal.Visible=false aa:_guardCursor(false)aa._box:ReleaseFocus()aa._box
.Text=''aa:_hideSheet()aa._at:to(aa:_away(),function()if not aa.isOpen then aa.
_root.Visible=false end end)end aa.visibilityChanged:fire(ab)end function X.
_guardCursor(aa,ab)local ac=c.service('UserInputService')if ab then aa.
_gameCursor=ac.MouseIconEnabled ac.MouseIconEnabled=true if aa._cursorGuard==nil
then aa._cursorGuard=ac:GetPropertyChangedSignal('MouseIconEnabled'):Connect(
function()if not ac.MouseIconEnabled then aa._gameCursor=false ac.
MouseIconEnabled=true end end)end else if aa._cursorGuard then aa._cursorGuard:
Disconnect()aa._cursorGuard=nil end if aa._gameCursor~=nil then ac.
MouseIconEnabled=aa._gameCursor aa._gameCursor=nil end end end function X.toggle
(aa)aa:setOpen(not aa.isOpen)end function X.notify(aa,ab)if aa.destroyed then
return end aa.ctx.notify(ab)end function X.setTheme(aa,ab)aa.ctx.theme:apply(ab)
end function X.setScale(aa,ab)local ac=math.clamp(ab,0.7,1.5)aa._scale.Scale=ac
aa._panelScale.Scale=ac aa:_placeSheet()aa:_drawChips()aa:_saveState()end
function X.setSubtitle(aa,ab)aa._subtitleText=ab end function X._saveState(aa)
local ab=aa._files if ab==nil or aa._stateFile==nil or aa._stateQueued then
return end aa._stateQueued=true task.delay(0.5,function()aa._stateQueued=false
if not aa.destroyed then local ac=aa._dockAt ab.write(aa._stateFile,encode({
scale=aa._scale.Scale,dockX=ac and ac.X,dockY=ac and ac.Y}))end end)end function
X.dialog(aa,ab,ac)if aa.destroyed then return false end b.open(aa,ab,ac)return
true end function X.find(aa,ab)return aa.elements[ab]end function X.snapshot(aa)
local ab={}for ac,ad in aa.elements do if ad.saved then local ae=ad.value if ad.
kind=='color'then ae={hex=ae.color:ToHex(),alpha=ae.alpha}elseif ad.kind=='key'
then ae={key=ae.key,mode=ae.mode,modifiers=ae.modifiers,toggled=ad.toggled==true
}end ab[ac]=ae end end return ab end function X.restore(aa,ab)for ac,ad in ab do
local ae=aa.elements[ac]if ae and ae.saved then if ae.kind=='color'and type(ad)
=='table'then ae:set({color=Color3.fromHex(ad.hex or'ffffff'),alpha=ad.alpha})
elseif ae.kind=='key'and type(ad)=='table'then ae:set(ad)ae.toggled=ad.toggled==
true else ae:set(ad)end end end end function X.destroy(aa)if aa.destroyed then
return end aa.destroyed=true aa:_guardCursor(false)aa.ctx.notifications:destroy(
)for ab,ac in aa.pages do ac:destroy()end aa._onPage:destroy()aa._resultsPage:
destroy()aa.ctx.input:destroy()aa._maid:clean()aa.visibilityChanged:clear()if aa
._registry and aa._registry.current==aa then aa._registry.current=nil end end
function u.new(aa)local ab=aa._registry if ab and ab.current then ab.current:
destroy()end local ac=h.new()local ad=s.new(aa.theme)local ae=f.new()local af=c.
service('UserInputService')local ag=aa.touch==true or(af.TouchEnabled and not af
.MouseEnabled)local ah=i('ScreenGui',{Name=randomName(),IgnoreGuiInset=true,
ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=aa.
displayOrder or 10000})c.protect(ah)ah.Parent=c.guiParent()ac:add(ah)local ai=c.
files()local Y=aa.folder or'sottui_dock'local Z=aa.stateFile or(Y..
'/window.json')local _=nil if ai then ai.folder(Y)local aj=ai.read(Z)_=aj and
decode(aj)end if type(_)~='table'then _={}end local aj=i('Frame',{Name='Root',
Size=UDim2.fromScale(1,1),Visible=false,Parent=ah})local ak=tonumber(_.scale)or(
if ah.AbsoluteSize.X<800 then 0.8 else 1)local al=i('Frame',{Name='Layer',Size=
UDim2.fromScale(1,1),ZIndex=100,Parent=ah})local am=i('TextButton',{Name='Modal'
,Size=UDim2.fromOffset(0,0),Modal=true,Visible=false,Parent=aj})local an=i(
'Frame',{Name='Assembly',AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0
,1,y),Size=UDim2.fromOffset(400,y),ZIndex=3,Parent=aj})local ao=i('UIScale',{
Scale=ak,Parent=an})local ap=i('Frame',{Name='Dock',Size=UDim2.fromScale(1,1),
BackgroundTransparency=0,ClipsDescendants=true,Active=true,ZIndex=3,Parent=an})
ad:paint(ap,'BackgroundColor3','surface')local aq=i('Frame',{Name='Row',Size=
UDim2.fromScale(1,1),ZIndex=3,Parent=ap})local ar=i('UIListLayout',{
FillDirection=Enum.FillDirection.Horizontal,VerticalAlignment=Enum.
VerticalAlignment.Center,Padding=UDim.new(0,C),SortOrder=Enum.SortOrder.
LayoutOrder,Parent=aq})local as=i('TextButton',{Name='Avatar',Size=UDim2.
fromOffset(z,z),BackgroundTransparency=0,ClipsDescendants=true,Text='',
LayoutOrder=1,ZIndex=3,Parent=aq})ad:paint(as,'BackgroundColor3','accent')local
at=c.service('Players').LocalPlayer if at then i('ImageLabel',{Size=UDim2.
fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,Image=string.format(
'rbxthumb://type=AvatarBust&id=%d&w=150&h=150',at.UserId),ZIndex=3,Parent=as})
end local au=i('Frame',{Name='Running',Position=UDim2.new(1,F,0,0),Size=UDim2.
new(0,0,1,0),BackgroundTransparency=0,ZIndex=3,Parent=an})ad:paint(au,
'BackgroundColor3','lineStrong')i('UIListLayout',{FillDirection=Enum.
FillDirection.Horizontal,VerticalAlignment=Enum.VerticalAlignment.Center,Padding
=UDim.new(0,F),SortOrder=Enum.SortOrder.LayoutOrder,Parent=au})local function 
tintFocus(av,aw)ad:paint(av,'BackgroundColor3',aw)end local av=i('TextBox',{Name
='Search',Size=UDim2.fromOffset(H,I),BackgroundTransparency=0,TextSize=B,Text=''
,PlaceholderText='Search',ClearTextOnFocus=false,ClipsDescendants=true,
TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=300,ZIndex=3,Parent=aq})i(
'UIPadding',{PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,8),Parent=av})ad
:paint(av,'BackgroundColor3','surface')av.Focused:Connect(function()tintFocus(av
,'base')end)av.FocusLost:Connect(function()tintFocus(av,'surface')end)ad:type(av
,'display')ad:paint(av,'TextColor3','text')ad:paint(av,'PlaceholderColor3',
'muted')local aw=i('Frame',{Name='Marker',Size=UDim2.fromOffset(0,T),
BackgroundTransparency=0,ZIndex=4,Parent=ap})ad:paint(aw,'BackgroundColor3',
'accent')local ax=i('Frame',{Name='Sheet',AnchorPoint=Vector2.new(0,1),Position=
UDim2.new(0,0,1,-(A+y)),Size=UDim2.new(0,x,0,0),BackgroundTransparency=0,
ClipsDescendants=true,Active=true,ZIndex=2,Parent=aj})ad:paint(ax,
'BackgroundColor3','surface')local ay=i('Frame',{Name='Fade',AnchorPoint=Vector2
.new(0,1),Position=UDim2.fromScale(0,1),Size=UDim2.new(1,0,0,L),
BackgroundTransparency=0,Visible=false,ZIndex=20,Parent=ax})ad:paint(ay,
'BackgroundColor3','surface')i('UIGradient',{Rotation=90,Transparency=
NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1
,0)}),Parent=ay})local az=i('UIScale',{Scale=ak,Parent=ax})local aA=
setmetatable({ctx=nil,pages={},elements={},ordered={},isOpen=false,destroyed=
false,width=x,visibilityChanged=r.new(),_maid=ac,_gui=ah,_root=aj,_layer=al,
_modal=am,_scale=ao,_panelScale=az,_box=av,_panel=ax,_dock=ap,_row=aq,_marker=aw
,_sheetFade=ay,_chipRow=au,_homeAvatar=as,_chips={},_sheetRoom=600,_sheetWidth=x
,_dockAt=if tonumber(_.dockX)and tonumber(_.dockY)then Vector2.new(_.dockX,_.
dockY)else nil,_words={},_subtitleText=aa.subtitle,_files=ai,_stateFile=Z,
_dialogIds=0,_registry=ab},X)if ab then ab.current=aA end local aB={theme=ad,
input=ae,touch=ag,assets={},glyph=e.new(ad),tint=t.new(ad),uiScale=function()
return ao.Scale end,popoverTop=function()return 8 end,dialogAt=function(aB)local
aC=al.AbsoluteSize return UDim2.fromOffset(math.floor((aC.X-aB*ao.Scale)/2),math
.floor(aC.Y*0.2))end,isShowing=function(aB)if not aA.isOpen or aA._showing==nil
then return false end return aB._shownOn==aA._showing or aB._page==aA._showing
end,setScrollLocked=function(aB)local aC=aA._showing if aC and aC.frame and ag
then aC.frame.ScrollingEnabled=not aB end end}aA.ctx=aB local aC=m.popover(aB,al
)aB.popover={open=function(aD,aE,aF,aG,aH)local aI=aA._showing if aI==nil or not
aI:expand(aE,aG,aH)then aC:open(aE,aF,aG,aH)end end,close=function()aC:close()
local aD=aA._showing if aD then aD:collapse()end end,isOpen=function()return aC:
isOpen()end,key=function(aD,aE)if aC:key(aE)then return true end local aF=aA.
_showing return aF~=nil and aF:expansionKey(aE)end}aB.tooltip=m.tooltip(aB,al)aB
.hover=m.hover(aB)aB.notifications=l.new(aB,al)aB.notify=function(aD)aB.
notifications:show(aD)end aA.keys=g.new(ae,c,function()return aA.isOpen end)aB.
keys=aA.keys aA._at=ac:add(k.prop(an,'Position',Q))aA._at:snap(aA:_away())aA.
_panelSize=ac:add(k.prop(ax,'Size',P))aA._markerAt=ac:add(k.prop(aw,'Position',R
))aA._markerSize=ac:add(k.prop(aw,'Size',R))local aD=ac:add(k.prop(an,'Size',S))
aA._onPage=n.new(aA,'On')aA._resultsPage=n.new(aA,'Results')aA._onPage:mount(ax)
aA._resultsPage:mount(ax)local aE=i('TextButton',{Name='Close',Size=UDim2.new(0,
J,1,0),LayoutOrder=400,ZIndex=4,Parent=aq})local aF=aB.glyph.cross(aE,'muted')aF
.AnchorPoint=Vector2.new(0.5,0.5)aF.Position=UDim2.new(0.5,4,0.5,0)aF.ZIndex=4
local aG=i('Frame',{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.fromScale(0,
0.5),Size=UDim2.fromOffset(1,K),BackgroundTransparency=0,ZIndex=4,Parent=aE})ad:
paint(aG,'BackgroundColor3','lineStrong')as.MouseEnter:Connect(function()aB.
tint(as,'BackgroundColor3','accentHover')end)as.MouseLeave:Connect(function()aB.
tint(as,'BackgroundColor3','accent')end)ap.InputBegan:Connect(function(aH)local
aI=aH.UserInputType if aI~=Enum.UserInputType.MouseButton1 and aI~=Enum.
UserInputType.Touch then return end local aJ=if aI==Enum.UserInputType.Touch
then ae:at(aH)else ae:pointer()local aK,aL=aA:_dockPoint()ae:capture(function(aM
)local aN=aM-aJ aA._dockAt=Vector2.new(aK+aN.X,aL+aN.Y)aA:_clampDock()aA._at:
snap(aA:_home())aA:_placeSheet()end,function()aA:_drawChips()aA:_syncMarker(true
)aA:_saveState()end,if aI==Enum.UserInputType.Touch then aH else nil)end)aE.
Activated:Connect(function()aA:setOpen(false)end)av:GetPropertyChangedSignal(
'Text'):Connect(function()aA:_query(av.Text)end)local function fitDock()local aH
=math.ceil(ar.AbsoluteContentSize.X/ao.Scale)aA._dockWidth=aH aD:snap(UDim2.
fromOffset(aH,y))aA:_clampDock()if aA.isOpen then aA._at:snap(aA:_home())else aA
._at:snap(aA:_away())end aA:_placeSheet()aA:_drawChips()task.defer(function()if
not aA.destroyed then local aI=(av.AbsolutePosition.X-ap.AbsolutePosition.X)/ao.
Scale aA._sheetWidth=math.clamp(math.floor(aI),x,O)ax.Size=UDim2.new(0,aA.
_sheetWidth,0,ax.Size.Y.Offset)aA:_syncMarker(true)end end)end ar:
GetPropertyChangedSignal('AbsoluteContentSize'):Connect(fitDock)task.defer(
fitDock)ac:add(ah:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()aA:
_clampDock()if aA.isOpen then aA._at:snap(aA:_home())end aA:_placeSheet()aA:
_drawChips()local aH=aA._showing if aH then aH:_invalidate()end end))ae.moved:
connect(function(aH)aB.hover:verify(aH)end)ae.wheel:connect(function(aH)if not
aA.isOpen or aB.popover:isOpen()then return end local aI=aA._showing if aI==nil
or aI.frame==nil then return end local aJ=ae:pointer()local aK,aL=aI.frame.
AbsolutePosition,aI.frame.AbsoluteSize if aJ.X>=aK.X and aJ.Y>=aK.Y and aJ.X<=aK
.X+aL.X and aJ.Y<=aK.Y+aL.Y then if not aI:pointerInExpansion(aJ)then aI:wheel(
aH)end end end)ae.keyDown:connect(function(aH,aI)if aH.UserInputType~=Enum.
UserInputType.Keyboard then return end local aJ=aH.KeyCode.Name if aA.keys:
swallowed(aJ)then return end if aB.popover:key(aJ)then return end if aJ==
'Escape'and aA._dialogClose then aA._dialogClose()return end if aJ=='Escape'and
av.Text~=''then av.Text=''return end if aI or ae:typing()then return end if aA.
isOpen and aJ=='K'then if af:IsKeyDown(Enum.KeyCode.LeftControl)or af:IsKeyDown(
Enum.KeyCode.RightControl)then av:CaptureFocus()end end end)ac:add(ad.changed:
connect(function()for aH,aI in aA.pages do for aJ,aK in aI._views do pcall(
function()aK:retint()aK.refresh()end)end end end))local aH=p.new({window=aA,
nextId=function()return 0 end,_register=function(aH,aI,aJ)if aJ then aA.elements
[aI.id]=aI end aI._pageName=''end,_invalidate=function()end},'')aA.menuKey=aH:
key('__menu',{label='Menu',default=aa.key or'RightShift',mode='Toggle',saved=
false,onPress=function()aA:toggle()end})local aI=c.service('RunService')k.
setAttach(function(aJ)return aI.PreRender:Connect(aJ)end)if aa.fonts~=false and
ai then ac:add(task.defer(function()local aJ=aa.fontTag or v local aK=string.
format(w,aJ)local aL=Y..'/fonts-'..aJ local aM=d.load(aL,aK,encode)if not aA.
destroyed and(aM.text or aM.display)then ad:setFonts(aM.text,aM.display)end end)
)end if ag then aA._opener=q(ah,ad,function()aA:setOpen(true)end)end if aa.
autoShow~=false then task.defer(function()aA:setOpen(true)end)end return aA end
function u.setVersion(aa)v=aa end return u end function a.C()local aa=a.cache.C
if not aa then aa={c=__modImpl()}a.cache.C=aa end return aa.c end end end local
aa=a.a()local ab=a.b()local ac=a.e()local ad=a.C()local ae='0.2.7-dock'local 
function registry()local af=aa.global('getgenv')local ag=if type(af)=='function'
then af()else _G local ah=ag.__sottui if type(ah)~='table'then ah={current=nil}
ag.__sottui=ah end return ah end local af={version=ae,motion=ab}ad.setVersion(
'v'..ae)function af.window(ag)local ah=table.clone(ag or{})ah._registry=
registry()return ad.new(ah)end function af.current()return registry().current
end function af.obsidian()return ac.new(af)end return af