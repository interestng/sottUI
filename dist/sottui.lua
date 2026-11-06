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
format('Saved over %q',m))end end})j:AddButton({Text='Delete',DoubleClick=true,
Risky=true,Func=function()local m=selected()if m then local n,o=e:Delete(m)
report(n,o,string.format('Deleted %q',m))l:SetValue(nil)refresh()end end})j:
AddButton({Text='Load at start',Func=function()local m=selected()if m then local
n,o=e:SaveAutoloadConfig(m)report(n,o,string.format('%q loads at start',m))
refresh()end end})j:AddButton({Text='Load nothing at start',Func=function()local
m,n=e:DeleteAutoLoadConfig()report(m,n,'No config loads at start')refresh()end})
j:AddButton('Refresh list',refresh)return j end return e end return c end
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
local q={}local r=p._lib p._section._page._guarded=true local s=p._section:when(
function()for s,t in q do local u,v=t[1],t[2]if u.Disabled then return false end
local w=u.Value if u.Type=='Dropdown'and type(w)=='table'then if not w[v]then
return false end elseif w~=v then return false end end return true end)local t=(
setmetatable({_section=s,_lib=r},o))function t.SetupDependencies(u,v)q=v p.
_section._page:_invalidate()end return t end function o.SetCollapsed()end local 
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
local w=s.Mode or'Toggle'local x local y=t:addKey(q._el,r,{label=s.Text or q.
Text or r,default=s.Default or'None',mode=w,modes=v,modifiers=s.DefaultModifiers
or{},chipless=s.NoUI==true,noMouse=false,onPress=function(y,z)if p.ToggleKeybind
==x then p.window:toggle()return end if q.Type=='Toggle'and q.Disabled then y.
toggled=q.Value return end x.Toggled=z local A=y.value.mode if u and q.Type==
'Toggle'then if A=='Toggle'then q:SetValue(z)elseif A=='Hold'then q:SetValue(
true)end end if A=='Toggle'or A=='Press'then protect(x.Clicked,z)protect(x.
Callback,z)end end,onRelease=function(y)if u and q.Type=='Toggle'and y.value.
mode=='Hold'and not q.Disabled then q:SetValue(false)end end})x=setmetatable(
common(p,'KeyPicker',y,s),l)x.Value=y.value.key x.Mode=y.value.mode x.Modifiers=
y.value.modifiers x.Modes=v x.SyncToggleState=u x.NoUI=s.NoUI==true x.Toggled=
false x.ChangedCallback=s.ChangedCallback y:on(function()local z=y.value x.Value
=z.key x.Mode=z.mode x.Modifiers=z.modifiers x:Update()local A=keyArgument(z.key
)protect(x.ChangedCallback,A,z.modifiers)protect(x.Changed,A,z.modifiers)end)if
q.Type=='Toggle'and u then table.insert(q._pickers,x)y.toggled=q.Value end
return register(p,'Options',r,x)end function g.AddColorPicker(p,q,r)attachColor(
p._lib,p,q,r)return p end function g.AddKeyPicker(p,q,r)attachKey(p._lib,p,q,r)
return p end m.AddColorPicker=g.AddColorPicker m.AddKeyPicker=g.AddKeyPicker
local p={}p.__index=p local function makeBox(q,r)return setmetatable({_section=r
,_lib=q},o)end local function sectionBox(q,r)local s=q._page:section(r)local t=
makeBox(q._lib,s)return t end function p.AddLeftGroupbox(q,r)return sectionBox(q
,r)end p.AddRightGroupbox=p.AddLeftGroupbox function p.AddGroupbox(q,r)return
sectionBox(q,r.Name)end local function tabbox(q)local r=q._page:tabset()local s=
q._lib return{AddTab=function(t,u)return makeBox(s,r:tab(u))end}end p.
AddLeftTabbox=tabbox p.AddRightTabbox=tabbox local q={}q.__index=q function q.
AddTab(r,s,t)local u=if type(s)=='table'then s.Name else s local v=r._lib.window
:page(u)if u=='Home'then local w=b.service('Players').LocalPlayer if w then r.
_lib.Hero=v:hero({userId=w.UserId,title=w.DisplayName,text=r._footer})end end
local w=setmetatable({_page=v,_lib=r._lib},p)r._lib.Tabs[u]=w return w end
function q.OpenDialog(r,s,t)local u=r._lib local v=u.window local w=u.
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
math.min(m-i,6)j=m i=m+1 end end return h end function b.rank(c,d,e,f)local g={}
for h,i in d do local j=b.score(c,e(i))if j then table.insert(g,{item=i,score=j}
)end end table.sort(g,function(h,i)return h.score>i.score end)local h={}for i=1,
math.min(f,#g)do h[i]=g[i].item end return h end return b end function a.h()
local b=a.cache.h if not b then b={c=__modImpl()}a.cache.h=b end return b.c end
end do local function __modImpl()local b=a.f()local c=a.h()local d={}local e=38
local f=8 local g=9 local h=46 local i=38 local j=260 local k=17 local function 
isPicked(l,m)if l.spec.multi then return l.value[m]==true end return l.value==m
end function d.open(l,m,n)local o=m.spec local p=l.theme local q=o.display or
tostring local r=o.searchable==true or#o.options>=g local s=o.multi==true local
t=(if r then h else 0)+(if s then i else 0)local u=o.options local v=0 local w=
''local function ordered(x)if not o.multi then return x end local y,z={},{}for A
,B in x do table.insert(if m.value[B]then y else z,B)end table.move(z,1,#z,#y+1,
y)return y end u=ordered(u)local function bodyHeight()return math.clamp(#u,1,f)*
e+8 end local x=math.max(n.AbsoluteSize.X,j)l.popover:open(n,x,bodyHeight()+t,
function(y,z)local A=b('ScrollingFrame',{Position=UDim2.fromOffset(0,t),Size=
UDim2.new(1,0,1,-t),ScrollBarThickness=3,Parent=y})p:paint(A,
'ScrollBarImageColor3','lineStrong')local B=b('Frame',{Size=UDim2.fromScale(1,1)
,Parent=A})local C={}local D=f+2 local E=b('TextLabel',{Position=UDim2.
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
Size=UDim2.fromOffset(math.max(t,44),54)p.width=l.Size.X.Offset end local s=
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
0.62 local h=20 local i=22 local j=0.965 local k=2.6 local l=0.45 local m={}m.
__index=m function m.own(n,o)table.insert(n._cleanups,function()o:destroy()end)
return o end function m.onCleanup(n,o)table.insert(n._cleanups,o)end local 
function baseColor(n)local o=n.ctx.theme.tokens local p=n._face if n._lit then
return if n._hover then o.accentHover else o.accent end if p=='action'then
return if n._hover then o.raised else o.base end return if n._hover then o.
raised else o.surface end local function washTo(n)if n._wash==nil then n._wash=n
:own(c.prop(n.root,'BackgroundColor3',e))end n._wash:to(baseColor(n))end local 
function snapBase(n)local o=baseColor(n)if n._wash then n._wash:snap(o)else n.
root.BackgroundColor3=o end end function m.onHover(n,o)local p=o and not n.el.
disabled if n._hover==p then return end n._hover=p for q,r in n.chips do if r.
setHover then r.setHover(p)end end if not(n._floodFrame and n._floodFrame.
Visible)then washTo(n)end end function m.pressed(n,o)if n._press==nil then local
p=b('UIScale',{Parent=n.root})n._press=n:own(c.prop(p,'Scale',f,g))end n._press:
to(if o then j else 1)end function m.flood(n,o,p)if n._floodOn==o then return
end n._floodOn=o local q=n.root local r=q.AbsoluteSize if p or r.X<1 or not q.
Visible or not n.ctx.isShowing(n.el)then n._lit=o if n._floodFrame then n.
_floodFrame.Visible=false n._floodSpring:snap(UDim2.fromOffset(0,0))end
snapBase(n)return end local s=n._floodFrame if s==nil then s=b('Frame',{Name=
'Flood',AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(0,0),
BackgroundTransparency=0,ZIndex=1,Parent=q})b('UICorner',{CornerRadius=UDim.new(
1,0),Parent=s})n.ctx.theme:paint(s,'BackgroundColor3','accent')n._floodFrame=s n
._floodSpring=n:own(c.prop(s,'Size',h))end local t=n.ctx.uiScale()local u=r/t
local v=math.ceil(math.sqrt(u.X*u.X+u.Y*u.Y)*k)local w=n._pressAt n._pressAt=nil
local x=if w then(w-q.AbsolutePosition)/t else u/2 s.Position=UDim2.fromOffset(x
.X,x.Y)s.Visible=true if o then n._floodSpring:snap(UDim2.fromOffset(0,0))n.
_floodSpring:to(UDim2.fromOffset(v,v),function()n._lit=true local y=n._hover n.
_hover=false snapBase(n)n._hover=y s.Visible=false washTo(n)end)else n._lit=
false snapBase(n)n._floodSpring:snap(UDim2.fromOffset(v,v))n._floodSpring:to(
UDim2.fromOffset(0,0),function()s.Visible=false end)end end function m.flash(n)
if n._floodOn then n:pressed(true)task.delay(0.16,function()if n.root.Parent
then n:pressed(false)end end)return end n:flood(true)task.delay(0.28,function()
if n.root.Parent and not(n.el.kind=='toggle'and n.el.value==true)then n:flood(
false)end end)end function m.ink(n,o,p,q)local r=n.ctx.theme.tokens local s=n.
_inks[o]if q or not n.ctx.isShowing(n.el)then if s then s:snap(r[p])else o.
TextColor3=r[p]end return end if s==nil then s=n:own(c.prop(o,'TextColor3',i))n.
_inks[o]=s end s:to(r[p])end function m.retint(n)snapBase(n)end function m.
refreshName(n)local o=n.el if o.disabled then n.name.RichText=true n.name.Text=
'<s>'..o.label..'</s>'else n.name.RichText=false n.name.Text=o.label end end
function d.new(n,o,p)local q=p or{}local r=b('TextButton',{Name=o.kind,Size=
UDim2.new(1,0,0,q.height or d.HEIGHT),BackgroundTransparency=if q.inert then 1
else 0,ClipsDescendants=true,Active=not q.inert})local s=b('TextLabel',{Name=
'Name',Position=UDim2.fromOffset(d.PAD,0),Size=UDim2.new(1,-2*d.PAD,1,0),
TextSize=d.NAME,TextWrapped=true,TextTruncate=Enum.TextTruncate.AtEnd,Text=o.
label,ZIndex=3,Parent=r})n.theme:type(s,'text',true)local t=setmetatable({root=r
,name=s,el=o,ctx=n,chips={},_face=q.face,_cleanups={},_inks={},_hover=false,_lit
=false,_floodOn=false},m)r.BackgroundColor3=baseColor(t)t:refreshName()if q.
inert then t.onHover=function()end t.pressed=function()end else r.MouseEnter:
Connect(function()n.hover:enter(t)end)local u=nil r.InputBegan:Connect(function(
v)local w=v.UserInputType if w==Enum.UserInputType.MouseButton1 then if not o.
disabled then t._pressAt=n.input:pointer()t:pressed(true)end elseif w==Enum.
UserInputType.Touch then if not o.disabled then t._pressAt=n.input:at(v)t:
pressed(true)end u=task.delay(l,function()u=nil local x=if o.disabled and o.
disabledTip then o.disabledTip else o.tip if x and x~=''then n.tooltip:showAt(r,
x)end end)end end)local v=n.input.pointerUp:connect(function()if t._press and t.
_press.target~=1 then t:pressed(false)end if u then task.cancel(u)u=nil end end)
t:onCleanup(function()v()if u then task.cancel(u)end end)end t.destroy=function(
)n.hover:leave(t)for u,v in t._cleanups do pcall(v)end r:Destroy()end return t
end return d end function a.l()local b=a.cache.l if not b then b={c=__modImpl()}
a.cache.l=b end return b.c end end do local function __modImpl()local b=a.g()
local c=a.i()local d=a.k()local e=a.f()local f=a.j()local g=a.b()local h=a.l()
local i={}local j=h.PAD local k=22 local l=42 local m=42 local n=90 local o=3
local p=12 local q=17 local r=22 local s=12 local t=16 local u=2 local v=34
local w=17 local x=34 local y=16 local z=16 local A=64 local B={}local function 
addons(C,D,E,F)local G=F local function place(H,I)I.root.AnchorPoint=Vector2.
new(1,0.5)I.root.Position=UDim2.new(1,-(j+G),0.5,0)I.root.ZIndex=4 I.root.Parent
=C.root G+=I.width H._view=I table.insert(C.chips,I)C:onCleanup(function()H.
_view=nil I.destroy()end)end for H,I in E.addons or{}do if I.kind=='color'and
not I.spec.chipless then place(I,b.swatch(D,I))end end for H,I in E.addons or{}
do if I.kind=='key'and not I.spec.chipless then place(I,d.build(D,I))G+=6 end
end return G end local function reserveRight(C,D)C.name.Size=UDim2.new(1,-(2*j+D
),1,0)end function B.toggle(C,D)local E=h.new(C,D)local F=C.theme local G=D.spec
.primary==true local H=if G then t else s if G then F:type(E.name,'display')E.
name.TextSize=l E.name.TextWrapped=false end local I=e('Frame',{AnchorPoint=
Vector2.new(1,0.5),Position=UDim2.new(1,-j,0.5,0),Size=UDim2.fromOffset(H,H),
ZIndex=3,Parent=E.root})local J=e('UIStroke',{ApplyStrokeMode=Enum.
ApplyStrokeMode.Border,Thickness=2,Parent=I})local K=nil local L=nil local M=nil
local N=H+12 if G and D.section.hasOptions then K=e('TextButton',{AnchorPoint=
Vector2.new(1,0),Position=UDim2.new(1,-(j+H+4),0,0),Size=UDim2.new(0,A,1,0),
ZIndex=4,Parent=E.root})L=C.glyph.chevron(K,'muted','down')M=C.glyph.chevron(K,
'muted','up')for O,P in{L,M}do P.AnchorPoint=Vector2.new(0.5,0.5)P.Position=
UDim2.fromScale(0.5,0.5)end N+=A K.Activated:Connect(function()D.section:
togglePeek()E.refresh()end)end reserveRight(E,addons(E,C,D,N))local function 
draw(O)local P=D.value==true local Q=G and P if G then E:flood(P,O)end E:ink(E.
name,if D.disabled then'faint'elseif Q then'onAccent'elseif P then'text'else
'muted',O)I.BackgroundTransparency=if P then 0 else 1 F:paint(I,
'BackgroundColor3',if Q then'onAccent'else'accent')F:paint(J,'Color',if Q then
'onAccent'elseif P then'accent'elseif D.disabled then'line'else'lineStrong')for
R,S in E.chips do S.setInk(Q)end if K then K.Visible=not P L.Visible=not D.
section.peeking M.Visible=D.section.peeking==true end end E.root.Activated:
Connect(function()if not D.disabled then D:set(not D.value)end end)E.refresh=
function()E:refreshName()draw(false)end draw(true)return E end local function 
formatted(C,D)local E=C.spec if E.format then local F,G=pcall(E.format,C,D)if F
and G~=nil then return tostring(G)end end return string.format('%.'..(E.decimals
or 0)..'f',D)..(E.suffix or'')end function i.readoutWidth(C)local D=C.spec local
E=0 for F,G in{D.min,D.max,C.value}do E=math.max(E,f.width('display',formatted(C
,G),k))end return math.ceil(E*1.05)+2 end function B.slider(C,D)local E=h.new(C,
D)local F=C.theme local G=D.spec local H=E.root local function ratio()local I=G.
max-G.min return if I<=0 then 0 else(D.value-G.min)/I end local I=i.
readoutWidth(D)reserveRight(E,I+p)E.name.ZIndex=4 local J=e('TextLabel',{Name=
'Readout',AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-j,0,0),Size=UDim2.
new(0,I,1,0),TextSize=k,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=4,Parent
=H})F:type(J,'display')local K=e('Frame',{AnchorPoint=Vector2.new(0,1),Position=
UDim2.fromScale(0,1),Size=UDim2.new(1,0,0,u),BackgroundTransparency=0,ZIndex=2,
Parent=H})F:paint(K,'BackgroundColor3','lineStrong')local L=e('Frame',{Name=
'Fill',Size=UDim2.new(ratio(),0,1,0),BackgroundTransparency=0,ZIndex=2,Parent=H}
)F:paint(L,'BackgroundColor3','accentDim')local M=e('Frame',{AnchorPoint=Vector2
.new(0,1),Position=UDim2.fromScale(0,1),Size=UDim2.new(1,0,0,u),
BackgroundTransparency=0,ZIndex=2,Parent=L})F:paint(M,'BackgroundColor3',
'accent')local N=E:own(g.prop(L,'Size',m))local function typedEntry()if D.
disabled or E._typing then return end E._typing=true J.Visible=false local O=e(
'TextBox',{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-j,0,0),Size=UDim2.
new(0,math.max(I,64),1,0),TextSize=k,TextXAlignment=Enum.TextXAlignment.Right,
Text='',PlaceholderText=tostring(D.value),ZIndex=6,Parent=H})F:type(O,'display')
F:paint(O,'TextColor3','accent')F:paint(O,'PlaceholderColor3','faint')O:
CaptureFocus()O.FocusLost:Connect(function()local P=tonumber(O.Text)E._typing=
false J.Visible=true O:Destroy()if P then D:set(P)end end)end local function 
beginDrag(O,P,Q)if D.disabled then return end local R=D.value local S=math.max(H
.AbsoluteSize.X,1)local T=G.max-G.min local U=false local V=false C.input:
capture(function(W)local X=W-O if not U then if math.abs(X.X)<o then if P and
math.abs(X.Y)>8 then V=true C.input:release()end return end if P and math.abs(X.
X)<=math.abs(X.Y)then V=true C.input:release()return end U=true N.speed=n C.
setScrollLocked(true)end D:set(R+T*X.X/S)end,function(W)N.speed=m C.
setScrollLocked(false)if not U and not V and(W-O).Magnitude<8 then typedEntry()
end end,Q)end H.InputBegan:Connect(function(O)local P=O.UserInputType if P==Enum
.UserInputType.MouseButton2 then typedEntry()elseif P==Enum.UserInputType.
MouseButton1 then beginDrag(C.input:pointer(),false)elseif P==Enum.UserInputType
.Touch then beginDrag(C.input:at(O),true,O)end end)local function paintText()
local O=if D.disabled then'faint'else'text'F:paint(E.name,'TextColor3',O)F:
paint(J,'TextColor3',O)J.Text=formatted(D,D.value)end E.refresh=function()E:
refreshName()paintText()N:to(UDim2.new(ratio(),0,1,0))end paintText()return E
end local function pickText(C)local D=C.spec.display or tostring local E=C.value
if C.spec.multi then local F={}for G,H in C.spec.options do if E[H]then table.
insert(F,D(H))end end for G,H in E do if H and not table.find(C.spec.options,G)
then table.insert(F,D(G))end end if#F==0 then return'None',false end if#F<=2
then return table.concat(F,', '),true end return string.format('%s, %s +%d',F[1]
,F[2],#F-2),true end if E==nil then return'None',false end return D(E),true end
function B.dropdown(C,D)local E=h.new(C,D)local F=C.theme local G=E.root F:
paint(E.name,'TextColor3','muted')local H=e('TextLabel',{Name='Value',
AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-(j+r),0,0),TextSize=q,
TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Right,
ZIndex=3,Parent=G})F:type(H,'text',true)local I=C.glyph.chevron(G,'muted')I.
AnchorPoint=Vector2.new(1,0.5)I.Position=UDim2.new(1,-j,0.5,0)I.ZIndex=3 local 
function fit()local J=G.AbsoluteSize.X/C.uiScale()-2*j-r if J<=0 then return end
local K=f.width('textMedium',(pickText(D)),q)+p local L=math.max(J-K,J*0.45)E.
name.Size=UDim2.new(0,L,1,0)H.Size=UDim2.new(0,J-L,1,0)end G:
GetPropertyChangedSignal('AbsoluteSize'):Connect(fit)G.Activated:Connect(
function()if not D.disabled then c.open(C,D,G)end end)E.refresh=function()E:
refreshName()local J,K=pickText(D)H.Text=J F:paint(H,'TextColor3',if D.disabled
or not K then'faint'else'text')fit()end E.refresh()task.defer(fit)return E end
function B.input(C,D)local E=h.new(C,D)local F=C.theme local G=D.spec E.name.
Size=UDim2.new(0.35,-j,1,0)F:paint(E.name,'TextColor3','muted')local H=e(
'TextBox',{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-j,0.5,0),Size=
UDim2.new(0.65,-j,0,v),TextSize=w,Text=D.value or'',PlaceholderText=G.
placeholder or'',ClipsDescendants=true,TextEditable=not D.disabled,ZIndex=3,
Parent=E.root})F:type(H,'text',true)F:paint(H,'TextColor3','text')F:paint(H,
'PlaceholderColor3','faint')local I=e('Frame',{AnchorPoint=Vector2.new(0,1),
Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,u),BackgroundTransparency=0,
ZIndex=4,Parent=E.root})F:paint(I,'BackgroundColor3','lineStrong')H.Focused:
Connect(function()F:paint(I,'BackgroundColor3','accent')end)H.FocusLost:Connect(
function(J)F:paint(I,'BackgroundColor3','lineStrong')if not G.finished then
return end if not J or not D:set(H.Text)then H.Text=D.value or''end end)H:
GetPropertyChangedSignal('Text'):Connect(function()if E._applying or G.finished
then return end if not D:set(H.Text)and H.Text~=D.value then E._applying=true H.
Text=D.value or''E._applying=false end end)E.root.Activated:Connect(function()if
not D.disabled then H:CaptureFocus()end end)E.refresh=function()E:refreshName()H
.TextEditable=not D.disabled if H.Text~=(D.value or'')then E._applying=true H.
Text=D.value or''E._applying=false end end return E end function B.button(C,D)
local E=h.new(C,D,{face='action'})local F=C.theme local G=nil local H=e(
'UIStroke',{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=E.root})F:paint(H
,'Color','lineStrong')local I=C.glyph.chevron(E.root,'muted','right')I.
AnchorPoint=Vector2.new(1,0.5)I.Position=UDim2.new(1,-j,0.5,0)reserveRight(E,r)
local function draw()E:refreshName()E:ink(E.name,if D.disabled then'faint'elseif
D.spec.danger then'danger'else'text')end E.refresh=draw draw()E.root.Activated:
Connect(function()if D.disabled then return end if D.spec.confirm and G==nil
then E.name.Text='Again to confirm'E:flood(true)E:ink(E.name,'onAccent')G=task.
delay(2.5,function()G=nil E:flood(false)draw()end)return end if G then task.
cancel(G)G=nil E:flood(false)draw()end E:flash()E:ink(E.name,'onAccent')task.
delay(0.28,function()if E.root.Parent then draw()end end)D:fire()end)E:
onCleanup(function()if G then task.cancel(G)end end)return E end function B.stat
(C,D)local E=h.new(C,D,{inert=true})local F=C.theme E.name.Position=UDim2.new()E
.name.Size=UDim2.new(1,0,0,x+4)E.name.TextSize=x E.name.TextWrapped=false E.name
.TextYAlignment=Enum.TextYAlignment.Top F:paint(E.name,'TextColor3','text')local
G=e('TextLabel',{Position=UDim2.fromOffset(0,x+2),Size=UDim2.new(1,0,0,y+4),
TextSize=y,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=3,Parent=E.root})F:type(G
,'text')F:paint(G,'TextColor3','muted')E.refresh=function()E.name.Text=tostring(
D.value)G.Text=D.label end E.refresh()return E end function B.label(C,D)local E=
C.theme if D.addons then local F=h.new(C,D)E:paint(F.name,'TextColor3','muted')F
.name.RichText=true reserveRight(F,addons(F,C,D,0))F.refresh=function()F.name.
Text=D.label end return F end local F=h.new(C,D,{height=32,inert=true})local G=F
.name local H=D.spec.wrap==true G.RichText=true G.TextSize=z G.TextWrapped=H E:
type(G,'text')E:paint(G,'TextColor3','muted')G.TextTruncate=if H then Enum.
TextTruncate.None else Enum.TextTruncate.AtEnd G.TextYAlignment=if H then Enum.
TextYAlignment.Top else Enum.TextYAlignment.Center G.LineHeight=if H then 1.15
else 1 G.Position=UDim2.fromOffset(0,if H then 6 else 0)G.Size=if H then UDim2.
new(1,0,1,-6)else UDim2.fromScale(1,1)G.Text=D.label if H then G:
GetPropertyChangedSignal('TextBounds'):Connect(function()local I=math.ceil(G.
TextBounds.Y/C.uiScale())+12 if D._measured~=I then D._measured=I if D._relayout
then D._relayout()end end end)end F.refresh=function()G.Text=D.label end return
F end function B.divider(C,D)local E=h.new(C,D,{height=28,inert=true})local F=C.
theme E.name.Position=UDim2.new()E.name.Size=UDim2.fromScale(1,1)E.name.TextSize
=z F:type(E.name,'text',true)F:paint(E.name,'TextColor3','muted')E.refresh=
function()E.name.Text=D.label end return E end local function chipTile(C,D,E,F,G
)local H=h.new(C,D)C.theme:paint(H.name,'TextColor3','muted')E.root.AnchorPoint=
Vector2.new(1,0.5)E.root.Position=UDim2.new(1,-G,0.5,0)E.root.ZIndex=4 E.root.
Parent=H.root reserveRight(H,F)H:onCleanup(E.destroy)H.refresh=function()H:
refreshName()E.refresh()end return H end function B.key(C,D)local E=d.build(C,D)
local F=chipTile(C,D,E,96,j)F.root.Activated:Connect(E.start)return F end
function B.color(C,D)local E=b.swatch(C,D)local F=chipTile(C,D,E,b.DOT_SPACE,j-8
)F.root.Activated:Connect(E.open)return F end function i.build(C,D)local E=B[D.
kind]assert(E,'sottUI: no view for '..tostring(D.kind))local F=E(C,D)D._view=F
return F end return i end function a.m()local b=a.cache.m if not b then b={c=
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
'label'then f.value=g local h=f._relayout if h then h()end end redraw(f)end
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
table.insert(h,g)g.host=f redraw(f)end function d.shown(f)if not f.visible then
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
function __modImpl()local b=a.m()local c=a.f()local d=a.b()local e=a.p()local f=
{}local g=26 local h=36 function f.open(i,j,k)local l=i.ctx local m=l.theme
local n=i._layer local o=j.width or 460 local p=j.maxHeight or 340 local q=60
local r=c('TextButton',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
BackgroundColor3=Color3.new(0,0,0),ZIndex=50,Parent=n})local s=d.prop(r,
'BackgroundTransparency',22)s:to(0.4)local t=c('Frame',{AnchorPoint=Vector2.new(
0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(o,0),
BackgroundTransparency=0,ClipsDescendants=true,Active=true,ZIndex=51,Parent=n})m
:paint(t,'BackgroundColor3','base')local u=c('UIStroke',{ApplyStrokeMode=Enum.
ApplyStrokeMode.Border,Parent=t})m:paint(u,'Color','lineStrong')local v=c(
'TextLabel',{Position=UDim2.fromOffset(20,16),Size=UDim2.new(1,-40,0,40),
TextSize=36,Text=j.title or'',ZIndex=52,Parent=t})m:type(v,'display')m:paint(v,
'TextColor3','text')local w=60 local x=j.text if x and x~=''then local y=c(
'TextLabel',{Position=UDim2.fromOffset(20,w),Size=UDim2.new(1,-40,0,22),
AutomaticSize=Enum.AutomaticSize.Y,TextSize=16,TextWrapped=true,Text=x,ZIndex=52
,Parent=t})m:type(y,'text')m:paint(y,'TextColor3','muted')w+=22+math.floor(#x/52
)*22+12 end local y=c('ScrollingFrame',{Position=UDim2.fromOffset(20,w),Size=
UDim2.new(1,-40,0,0),ScrollBarThickness=3,ZIndex=52,Parent=t})m:paint(y,
'ScrollBarImageColor3','lineStrong')local z=false local A={window=i,name=
'Dialog',nextId=function()i._dialogIds+=1 return i._dialogIds end,_register=
function(A,B,C)B._pageName='Dialog'if C then i.elements[B.id]=B end end,
_invalidate=function()end}local B=e.new(A,'')local C,D=xpcall(k,debug.traceback,
B)if not C then warn('sottUI: dialog build failed: '..tostring(D))end local E={}
local F=0 for G,H in B.rows do if H:shown()then local I=b.build(l,H)local J=if H
.kind=='label'or H.kind=='divider'then 32 else q I.root.Position=UDim2.
fromOffset(0,F)I.root.Size=UDim2.new(1,0,0,J)I.root.Parent=y F+=J+3 table.
insert(E,I)end end y.CanvasSize=UDim2.fromOffset(0,F)local G=math.min(F,p)y.Size
=UDim2.new(1,-40,0,G)local H=w+G+12 local I=c('TextButton',{Position=UDim2.
fromOffset(20,H),Size=UDim2.new(1,-40,0,54),BackgroundTransparency=0,TextSize=28
,Text=j.done or'Done',ZIndex=52,Parent=t})m:type(I,'display')m:paint(I,
'BackgroundColor3','text')m:paint(I,'TextColor3','base')local J=H+54+20 local K=
d.prop(t,'Size',g)K:to(UDim2.fromOffset(o,J))local function close()if z then
return end z=true i._dialogClose=nil r.Active=false for L,M in B.rows do if i.
elements[M.id]==M then i.elements[M.id]=nil end end if j.onClose then task.
spawn(j.onClose)end s:to(1,function()s:destroy()r:Destroy()end)K.speed=h K:to(
UDim2.fromOffset(o,0),function()for L,M in E do M.destroy()end K:destroy()t:
Destroy()end)end i._dialogClose=close r.MouseButton1Down:Connect(close)I.
Activated:Connect(close)end return f end function a.q()local b=a.cache.q if not
b then b={c=__modImpl()}a.cache.q=b end return b.c end end do local function 
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
.X local y=math.clamp(x,j,u.X-r-j)local z=v.Y+w.Y+2 local A=z+s+j>u.Y and v.Y-s-
2>j local B=if A then v.Y-s-2 else math.min(z,u.Y-s-j)local C=b('TextButton',{
Name='Catcher',Size=UDim2.fromScale(1,1),ZIndex=60,Parent=l})local D=b('Frame',{
Name='Popover',Position=UDim2.fromOffset(y,B),Size=UDim2.fromOffset(r,0),
BackgroundTransparency=0,ClipsDescendants=true,ZIndex=61,Active=true,Parent=l})m
:paint(D,'BackgroundColor3','raised')local E=b('UIStroke',{ApplyStrokeMode=Enum.
ApplyStrokeMode.Border,Parent=D})m:paint(E,'Color','lineStrong')local F=b(
'Frame',{Size=UDim2.fromScale(1,1),Parent=D})local G={frame=D,catcher=C,width=r,
open=true,size=c.prop(D,'Size',e)}o=G C.MouseButton1Down:Connect(close)C.
MouseButton2Down:Connect(close)local H={close=close,resize=function(H)if G.open
then G.size:to(UDim2.fromOffset(r,H))end end,onKey=function(H)G.onKey=H end,
onRefresh=function(H)G.onRefresh=H end}t(F,H)G.size:to(UDim2.fromOffset(r,s))end
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
=600 local k=3 local l=20 local m=14 local n=28 local o=40 local p=22 local q=
148 local r=84 local s=5 local t=66 local u=360 local v=110 local w=24 local x=
28 local y={toggle=4,button=4,key=4,color=4,slider=4,dropdown=4,stat=3,input=8}
local function needs(z)local A=z.kind if A=='stat'or A=='input'then return 0 end
local B=26 if A=='slider'then B=b.readoutWidth(z)+12 elseif A=='dropdown'then B=
96 end for C,D in z.addons or{}do if not D.spec.chipless then B+=if D.kind==
'key'then 58 else 28 end end return d.width('textMedium',z.label,g.NAME)*1.05+2*
g.PAD+B end local function spanOf(z)if z.kind=='label'and z.addons then return 4
end return y[z.kind]end local z={}z.__index=z local function textHeight(A,B)if A
.kind=='divider'then return if A.label==''then 8 else 28 end if not A.spec.wrap
then return 32 end if A._measured then return A._measured end local C=math.max(
math.floor(B/7.6),10)local D=string.gsub(A.label,'<[^>]+>','')return math.ceil(#
D/C)*21+12 end function z.nextId(A)A._ids+=1 return A._ids end function z.
_register(A,B,C)B._relayout=function()A:_invalidate()end A.window:
_registerElement(B,A,C)end function z._invalidate(A)if A._dirty then return end
A._dirty=true task.defer(function()A._dirty=false if not A.destroyed then A:
layout(not A._quiet)A._quiet=false end end)end function z.section(A,B)local C=f.
new(A,B)table.insert(A.sections,C)A:_invalidate()return C end function z.tabset(
A)local B=f.new(A,'')B.tabNames={}B.activeTab=1 table.insert(A.sections,B)local
C={}function C.tab(D,E)table.insert(B.tabNames,E)local F=#B.tabNames local G=B:
when(function()return B.activeTab==F end)G.title=E local H=A._headers[B]if H
then H:Destroy()A._headers[B]=nil end A:_invalidate()return G end return C end
function z.tabs(A,B)local C=A:tabset()local D={}for E,F in B do table.insert(D,C
:tab(F))end return D end function z.hero(A,B)A._hero=B A:_invalidate()local C=A.
_heroView return{set=function(D,E,F)B.title=E or B.title B.text=F or B.text
local G=A._heroView or C if G then G.refresh()end end}end local function 
buildHero(A)local B=A.window.ctx local C=B.theme local D=A._hero local E=c(
'Frame',{Name='Hero',Parent=A.canvas})local F=c('Frame',{Size=UDim2.fromOffset(q
-16,q-16),BackgroundTransparency=0,ClipsDescendants=true,Parent=E})C:paint(F,
'BackgroundColor3','accent')if D.userId then c('ImageLabel',{Size=UDim2.
fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,Image=string.format(
'rbxthumb://type=AvatarBust&id=%d&w=420&h=420',D.userId),Parent=F})end local G=
c('TextLabel',{Position=UDim2.fromOffset(q+2,16),Size=UDim2.new(1,-(q+2),0,68),
TextSize=64,TextTruncate=Enum.TextTruncate.AtEnd,Parent=E})C:type(G,'display')C:
paint(G,'TextColor3','text')local H=c('TextLabel',{Position=UDim2.fromOffset(q+2
,88),Size=UDim2.new(1,-(q+2),0,44),TextSize=17,TextWrapped=true,TextYAlignment=
Enum.TextYAlignment.Top,Parent=E})C:type(H,'text')C:paint(H,'TextColor3','muted'
)local I={root=E,refresh=function()G.Text=D.title H.Text=D.text or''end}I.
refresh()return I end local function buildHeader(A,B)local C=A.window.ctx local
D=C.theme local E=c('Frame',{Name='Header',Parent=A.canvas})if B.tabNames then
local F={}local G=0 for H,I in B.tabNames do local J=math.ceil(d.width(
'textMedium',I,18))+20 local K=c('TextButton',{Position=UDim2.fromOffset(G,0),
Size=UDim2.new(0,J,1,-8),TextSize=18,Text=I,TextXAlignment=Enum.TextXAlignment.
Left,Parent=E})D:type(K,'text',true)F[H]=K K.Activated:Connect(function()B.
activeTab=H for L,M in F do D:paint(M,'TextColor3',if L==B.activeTab then'text'
else'faint')end A:_invalidate()end)D:paint(K,'TextColor3',if H==B.activeTab then
'text'else'faint')G+=J end else local F=c('TextLabel',{Size=UDim2.new(1,0,1,-6),
TextSize=26,Text=B.title,Parent=E})D:type(F,'display')D:paint(F,'TextColor3',
'text')end return E end function z.layout(A,B)local C=A.frame if C==nil then
return end A._live=B==true and A._settled==true and A.active local D=A.window.
ctx.uiScale()local E=C.AbsoluteSize.X/D if E<1 then return end local F=E-2*l
local G=F<j local H=(F-(i-1)*k)/i local I=m local J={}if A._hero then table.
insert(J,{hero=true,x=l,y=I,width=F,height=q})I+=q end for K,L in A.sections do
local M={}for N,O in L.rows do if O:shown()then table.insert(M,O)end end if#M>0
or L.tabNames then if(L.title~=''or L.tabNames)and not L.masterElement then
table.insert(J,{section=L,x=l,y=I,width=F,height=o})I+=o end local N,O={},0
local function flush(P)if#N==0 then return end local Q,R=l,0 for S,T in N do
local U=T.span if S==#N and not P then U+=i-O end local V=U*H+(U-1)*k local W=T.
height R=math.max(R,W)table.insert(J,{el=T.el,x=Q,y=I,width=V,height=W})Q+=V+k
end I+=R+k N,O={},0 end for P,Q in M do local R=spanOf(Q)if R==nil then flush(
false)local S=textHeight(Q,F)table.insert(J,{el=Q,x=l,y=I,width=F,height=S})I+=S
+k elseif Q.spec.primary then flush(false)table.insert(J,{el=Q,x=l,y=I,width=F,
height=r})I+=r+k else local S=math.min(if G then R*2 else R,i)while S<i and
needs(Q)>S*H+(S-1)*k do S+=if G then i-S else 4 end if O+S>i then flush(false)
end table.insert(N,{el=Q,span=S,height=if Q.kind=='stat'then t else g.HEIGHT})O
+=S end end flush(true)I+=if L.masterElement and#M==1 then s else p end end
local K=I-p+n C.CanvasSize=UDim2.fromOffset(0,K)A._contentHeight=K A._placements
=J A:_applyPlacements()A:_materialize(true)A:_refreshThumb()A._live=false A.
_settled=A._settled or A.active end local function growTo(A,B,C,D)if A._grow==
nil then A._grow=A:own(e.prop(A.root,'Size',x))end A._grow:to(UDim2.fromOffset(B
,C),D)end local function setSize(A,B,C)local D=UDim2.fromOffset(B,C)if A._grow
then A._grow:snap(D)else A.root.Size=D end end function z._applyPlacements(A)
local B={}for C,D in A._placements do if D.hero then if A._heroView then A.
_heroView.root.Position=UDim2.fromOffset(D.x,D.y)A._heroView.root.Size=UDim2.
fromOffset(D.width,D.height)end elseif D.section then B[D.section]=true local E=
A._headers[D.section]if E then E.Visible=true E.Position=UDim2.fromOffset(D.x,D.
y)E.Size=UDim2.fromOffset(D.width,D.height)end else B[D.el]=true local E=A.
_views[D.el]if E then A:_place(E,D)end end end for C,D in A._headers do if not B
[C]then D.Visible=false end end for C,D in A._views do if not B[C]and D.root.
Visible and not D._folding then if A._live then D._folding=true growTo(D,D.root.
Size.X.Offset,0,function()D._folding=false D.root.Visible=false end)else D.root.
Visible=false end end end end function z._place(A,B,C)local D=B.root local E=
UDim2.fromOffset(C.x,C.y)local F=A._live local G=F and not D.Visible local H=B.
_folding==true B._folding=false D.Visible=true if G then setSize(B,C.width,0)
growTo(B,C.width,C.height)elseif H then growTo(B,C.width,C.height)else setSize(B
,C.width,C.height)end if F and not G and D.Position~=E then if B._slide==nil
then B._slide=B:own(e.prop(D,'Position',x))end B._slide:to(E)elseif B._slide
then B._slide:snap(E)else D.Position=E end end function z._materialize(A,B)local
C=A.frame local D=A._placements if C==nil or D==nil or not A.active then return
end local E=A.window.ctx.uiScale()local F=C.CanvasPosition.Y/E if not B and A.
_lastSync and math.abs(F-A._lastSync)<u/3 then return end A._lastSync=F local G,
H=F-u,F+C.AbsoluteSize.Y/E+u for I,J in D do local K=J.y if K+J.height>=G and K
<=H then if J.hero then if A._heroView==nil then local L=buildHero(A)L.root.
Position=UDim2.fromOffset(J.x,K)L.root.Size=UDim2.fromOffset(J.width,J.height)A.
_heroView=L end elseif J.section then if A._headers[J.section]==nil then local L
=buildHeader(A,J.section)L.Position=UDim2.fromOffset(J.x,K)L.Size=UDim2.
fromOffset(J.width,J.height)A._headers[J.section]=L end elseif A._views[J.el]==
nil then local L,M=xpcall(b.build,debug.traceback,A.window.ctx,J.el)if L then M.
root.Position=UDim2.fromOffset(J.x,K)M.root.Size=UDim2.fromOffset(J.width,if A.
_live then 0 else J.height)M.root.Parent=A.canvas A._views[J.el]=M if A._live
then growTo(M,J.width,J.height)end else warn('sottUI: tile '..tostring(J.el.id)
..' failed: '..tostring(M))end end end end end function z._refreshThumb(A)local
B=A.thumb if B==nil then return end local C=A.window.ctx.uiScale()local D=A.
frame.AbsoluteSize.Y/C local E=A._contentHeight or 0 if E<=D+1 or not A.active
then B.Visible=false return end B.Visible=true local F=math.max(D*D/E,40)local G
=D-F local H=A.frame.CanvasPosition.Y/C/math.max(E-D,1)B.Size=UDim2.new(0,3,0,F)
B.Position=UDim2.new(1,-6,0,H*G)end function z.scrollTo(A,B,C)local D=A.frame if
D==nil then return end local E=A.window.ctx.uiScale()local F=math.max((A.
_contentHeight or 0)-D.AbsoluteSize.Y/E,0)local G=math.clamp(B,0,F)A.
_scrollTarget=G if C then A._scroll:snap(G)else A._scroll:to(G)end end function
z.wheel(A,B)if A.frame==nil or A.frame.ScrollingEnabled then return end local C=
A._scrollTarget or A.frame.CanvasPosition.Y/A.window.ctx.uiScale()A:scrollTo(C-B
*v)end function z.rowY(A,B)if A._placements==nil then A:layout()end for C,D in A
._placements or{}do if D.el==B then return D.y end end return nil end function z
.viewOf(A,B)return A._views[B]end function z.mount(A,B)if A.frame then return
end local C=A.window.ctx local D=c('ScrollingFrame',{Name=A.name,Size=UDim2.
fromScale(1,1),Visible=false,ScrollingEnabled=C.touch,Parent=B})local E=c(
'Frame',{Name='Canvas',Size=UDim2.fromScale(1,1),Parent=D})local F=c('Frame',{
Name='Thumb',BackgroundTransparency=0,Visible=false,ZIndex=5,Parent=B})C.theme:
paint(F,'BackgroundColor3','lineStrong')A.frame=D A.canvas=E A.thumb=F A._scroll
=e.new(0,w,function(G)D.CanvasPosition=Vector2.new(0,G*C.uiScale())end)D:
GetPropertyChangedSignal('CanvasPosition'):Connect(function()A:_materialize()A:
_refreshThumb()end)local G=0 D:GetPropertyChangedSignal('AbsoluteSize'):Connect(
function()local H=D.AbsoluteSize.X if H~=G then G=H A._quiet=true A:_invalidate(
)else A:_materialize(true)A:_refreshThumb()end end)end function z.setActive(A,B)
A.active=B if A.frame then A.frame.Visible=B if not B then A.thumb.Visible=false
end end if B then A:layout()end end function z.destroy(A)A.destroyed=true for B,
C in A._views do C.destroy()end A._views={}if A._scroll then A._scroll:destroy()
end if A.frame then A.frame:Destroy()A.thumb:Destroy()end end function h.new(A,B
)return setmetatable({name=B,window=A,sections={},active=false,destroyed=false,
_ids=0,_dirty=false,_headers={},_views={},_placements=nil},z)end return h end
function a.y()local b=a.cache.y if not b then b={c=__modImpl()}a.cache.y=b end
return b.c end end do local function __modImpl()local b=a.f()local c=a.b()local
d=a.h()local e={}local f=600 local g=46 local h=68 local i=7 local j=34 local k=
48 local function describe(l)local m=l._pageName or''if l.kind=='toggle'then
return(if l.value then'On, 'else'Off, ')..m end if l.kind=='slider'then return
tostring(l.value)..(l.spec.suffix or'')..', '..m end if l.kind=='dropdown'and
not l.spec.multi and l.value~=nil then return tostring((l.spec.display or
tostring)(l.value))..', '..m end return m end function e.new(l,m,n,o)local p=l.
theme local q={}local r=false local s,t,u,v local w={}local x={}local y=1 local 
function close()if not r then return end r=false s:Destroy()local z,A=t,u A.
speed=k A:to(UDim2.fromOffset(f,0),function()A:destroy()z:Destroy()end)table.
clear(x)end local function draw()if not r then return end for z,A in x do local
B=w[z]if B then A.root.Visible=true A.name.Text=B.label A.where.Text=describe(B)
A.root.BackgroundTransparency=if z==y then 0 else 1 p:paint(A.name,'TextColor3',
if z==y then'onAccent'else'text')p:paint(A.where,'TextColor3',if z==y then
'onAccent'else'muted')else A.root.Visible=false end end local z=math.min(#w,i)
local A=h+(if z>0 then z*g+10 else 0)u:to(UDim2.fromOffset(f,A))end local 
function run(z)if z==nil then return end close()if z.kind=='toggle'and not z.
disabled then z:set(not z.value)l.notify({title=z.label,text=if z.value then'On'
else'Off',seconds=2})else o(z)end end local function query()local z=v.Text if z
==''then w={}for A,B in n()do if B.kind=='toggle'and B.value==true then table.
insert(w,B)if#w==i then break end end end else w=d.rank(z,n(),function(A)local B
=A.section and A.section.title or''return A.label..' '..(A._pageName or'')..' '
..B..' '..(A.tip or'')end,i)end y=1 draw()end function q.toggle(z)if r then
close()return end r=true local A=m.AbsoluteSize s=b('TextButton',{Size=UDim2.
fromScale(1,1),BackgroundTransparency=0.45,BackgroundColor3=Color3.new(0,0,0),
ZIndex=40,Parent=m})s.MouseButton1Down:Connect(close)t=b('Frame',{Name='Palette'
,Position=UDim2.fromOffset(math.floor((A.X-f)/2),math.floor(A.Y*0.22)),Size=
UDim2.fromOffset(f,0),BackgroundTransparency=0,ClipsDescendants=true,Active=true
,ZIndex=41,Parent=m})p:paint(t,'BackgroundColor3','surface')local B=b('UIStroke'
,{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=t})p:paint(B,'Color',
'lineStrong')u=c.prop(t,'Size',j)v=b('TextBox',{Position=UDim2.fromOffset(18,0),
Size=UDim2.new(1,-36,0,h),TextSize=36,Text='',PlaceholderText='Find a setting',
ZIndex=42,Parent=t})p:type(v,'display')p:paint(v,'TextColor3','text')p:paint(v,
'PlaceholderColor3','faint')for C=1,i do local D=b('TextButton',{Position=UDim2.
fromOffset(6,h+(C-1)*g+2),Size=UDim2.new(1,-12,0,g),Visible=false,ZIndex=42,
Parent=t})p:paint(D,'BackgroundColor3','accent')local E=b('TextLabel',{Position=
UDim2.fromOffset(12,0),Size=UDim2.new(0.6,-12,1,0),TextSize=16,TextTruncate=Enum
.TextTruncate.AtEnd,ZIndex=43,Parent=D})p:type(E,'text',true)p:paint(E,
'TextColor3','text')local F=b('TextLabel',{AnchorPoint=Vector2.new(1,0),Position
=UDim2.new(1,-12,0,0),Size=UDim2.new(0.4,-12,1,0),TextSize=16,TextTruncate=Enum.
TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=43,Parent=D})
p:type(F,'text')p:paint(F,'TextColor3','faint')x[C]={root=D,name=E,where=F}D.
MouseEnter:Connect(function()if y~=C then y=C draw()end end)D.Activated:Connect(
function()run(w[C])end)end v:GetPropertyChangedSignal('Text'):Connect(query)v.
FocusLost:Connect(function(C)if C then run(w[y])end end)query()v:CaptureFocus()
end function q.isOpen(z)return r end q.close=close function q.key(z,A)if not r
then return false end if A=='Escape'then close()return true end if A=='Down'or A
=='Up'then if#w>0 then y=math.clamp(y+(if A=='Down'then 1 else-1),1,#w)draw()end
return true end return false end return q end return e end function a.z()local b
=a.cache.z if not b then b={c=__modImpl()}a.cache.z=b end return b.c end end do
local function __modImpl()local b=a.n()local c={}local function rgb(d)return
Color3.fromRGB(bit32.band(bit32.rshift(d,16),255),bit32.band(bit32.rshift(d,8),
255),bit32.band(d,255))end local d={base=rgb(0x7100d),surface=rgb(0x141c18),
raised=rgb(0x1e2b25),line=rgb(0x1a2d27),lineStrong=rgb(0x2f4a40),text=rgb(
0xebe8da),muted=rgb(0xb4c2b8),faint=rgb(0x5f756b),accent=rgb(0x7ee0c4),
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
return c end function a.A()local b=a.cache.A if not b then b={c=__modImpl()}a.
cache.A=b end return b.c end end do local function __modImpl()local b=a.b()local
c={}local d=26 function c.new(e)local f={}return function(g,h,i,j)local k=f[g]if
k==nil then k={}f[g]=k end local l=k[h]if l==nil then l=b.prop(g,h,j or d)k[h]=l
end l:to(e.tokens[i])end end return c end function a.B()local b=a.cache.B if not
b then b={c=__modImpl()}a.cache.B=b end return b.c end end do local function 
__modImpl()local b=a.q()local c=a.a()local d=a.r()local e=a.s()local f=a.u()
local g=a.v()local h=a.t()local i=a.f()local j=a.b()local k=a.w()local l=a.x()
local m=a.y()local n=a.z()local o=a.p()local p=a.n()local q=a.A()local r=a.B()
local s={}local t='main'local u=
[[https://raw.githubusercontent.com/interestng/sottUI/%s/fonts/]]local v=64
local w=34 local x=26 local y=22 local z=Vector2.new(900,640)local A=Vector2.
new(560,400)local B=20 local C=30 local D=22 local E=26 local F=34 local G=17
local H=12 local I={}I.__index=I local function randomName()local J=table.
create(H)for K=1,H do J[K]=string.char(math.random(97,122))end return table.
concat(J)end local function encode(J)return c.service('HttpService'):JSONEncode(
J)end local function decode(J)local K,L=pcall(function()return c.service(
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
current==K then return end J.ctx.hover.clear()J.ctx.popover:close()J.keys:
cancel()local N=J.ctx.tint local O=J.pages[J.current]if O then O:setActive(false
)N(J._navItems[J.current],'TextColor3','faint')end local P=J.current==nil or K>J
.current J.current=K N(J._navItems[K],'TextColor3','text')M:setActive(true)J:
_syncMarker(L)J:_saveState()if L then return end local Q=if P then 1 else-1 J.
_pageSlide:snap(UDim2.fromOffset(E*Q,0))J._pageSlide:to(UDim2.new())J._wipe.
Visible=true J._wipeEdge.AnchorPoint=Vector2.new(if P then 1 else 0,0)J.
_wipeEdge.Position=UDim2.fromScale(if P then 1 else 0,0)J._wipeAt:snap(UDim2.
fromScale(0,0))J._wipeAt:to(UDim2.fromScale(-1.02*Q,0),function()J._wipe.Visible
=false end)end function I.showPage(J,K)for L,M in J.pages do if M.name==K then J
:show(L)return end end end function I.reveal(J,K)local L=K._page if L==nil then
return end if not J.isOpen then J:setOpen(true)end J:showPage(L.name)local M=K.
host or K L:layout()local N=L:rowY(M)if N then L:scrollTo(N-60)task.delay(0.26,
function()local O=L:viewOf(M)if O and O.root.Parent then O:flash()end end)end
end function I._targetSize(J)return if J.collapsed then UDim2.new(1,0,0,v)else
UDim2.fromScale(1,1)end function I.setOpen(J,K)if J.isOpen==K or J.destroyed
then return end J.isOpen=K J.ctx.hover.clear()J.ctx.popover:close()J._palette.
close()J.ctx.tooltip:hide()J.keys:cancel()J._shutterEdge.Visible=true if K then
J._root.Visible=true J._modal.Visible=true J:_guardCursor(true)J._shutter.speed=
B J._shutter:to(J:_targetSize(),function()J._shutterEdge.Visible=false end)else
J._modal.Visible=false J:_guardCursor(false)J._shutter.speed=C J._shutter:to(
UDim2.new(1,0,0,0),function()J._shutterEdge.Visible=false if not J.isOpen then J
._root.Visible=false end end)end J.visibilityChanged:fire(K)end function I.
_guardCursor(J,K)local L=c.service('UserInputService')if K then J._gameCursor=L.
MouseIconEnabled L.MouseIconEnabled=true if J._cursorGuard==nil then J.
_cursorGuard=L:GetPropertyChangedSignal('MouseIconEnabled'):Connect(function()if
not L.MouseIconEnabled then J._gameCursor=false L.MouseIconEnabled=true end end)
end else if J._cursorGuard then J._cursorGuard:Disconnect()J._cursorGuard=nil
end if J._gameCursor~=nil then L.MouseIconEnabled=J._gameCursor J._gameCursor=
nil end end end function I.toggle(J)J:setOpen(not J.isOpen)end function I.
collapse(J,K)J.collapsed=K J._shutter:to(J:_targetSize())J._grip.Visible=not K J
:_saveState()end function I.notify(J,K)if J.destroyed then return end J.ctx.
notify(K)end function I.setTheme(J,K)J.ctx.theme:apply(K)end function I.setScale
(J,K)J._scale.Scale=math.clamp(K,0.7,1.5)J:_clamp()J:_saveState()end function I.
setSubtitle(J,K)J._subtitleLabel.Text=K end function I._clamp(J)local K=J._gui.
AbsoluteSize local L=J.size*J._scale.Scale local M=math.clamp(J.position.X,0,
math.max(K.X-L.X,0))local N=math.clamp(J.position.Y,0,math.max(K.Y-L.Y,0))J.
position=Vector2.new(M,N)J._root.Position=UDim2.fromOffset(M,N)end function I.
_saveState(J)local K=J._files if K==nil or J._stateFile==nil or J._stateQueued
then return end J._stateQueued=true task.delay(0.5,function()J._stateQueued=
false if J.destroyed then return end local L=J.pages[J.current]K.write(J.
_stateFile,encode({x=J.position.X,y=J.position.Y,w=J.size.X,h=J.size.Y,page=L
and L.name,scale=J._scale.Scale,collapsed=J.collapsed}))end)end function I.
restorePage(J)local K=J._savedPage if K then J._savedPage=nil for L,M in J.pages
do if M.name==K then J:show(L,true)return end end end end function I.dialog(J,K,
L)if J.destroyed then return false end b.open(J,K,L)return true end function I.
find(J,K)return J.elements[K]end function I.snapshot(J)local K={}for L,M in J.
elements do if M.saved then local N=M.value if M.kind=='color'then N={hex=N.
color:ToHex(),alpha=N.alpha}elseif M.kind=='key'then N={key=N.key,mode=N.mode,
modifiers=N.modifiers,toggled=M.toggled==true}end K[L]=N end end return K end
function I.restore(J,K)for L,M in K do local N=J.elements[L]if N and N.saved
then if N.kind=='color'and type(M)=='table'then N:set({color=Color3.fromHex(M.
hex or'ffffff'),alpha=M.alpha})elseif N.kind=='key'and type(M)=='table'then N:
set(M)N.toggled=M.toggled==true else N:set(M)end end end end function I.destroy(
J)if J.destroyed then return end J.destroyed=true J:_guardCursor(false)J.ctx.
notifications:destroy()for K,L in J.pages do L:destroy()end J.ctx.input:destroy(
)J._maid:clean()J.visibilityChanged:clear()if J._registry and J._registry.
current==J then J._registry.current=nil end end local function headerButton(J,K,
L,M)local N=i('TextButton',{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,
L,0.5,0),Size=UDim2.fromOffset(44,v),BackgroundTransparency=1,Parent=K})J.theme:
paint(N,'BackgroundColor3','raised')local O=M(N,'muted')O.AnchorPoint=Vector2.
new(0.5,0.5)O.Position=UDim2.fromScale(0.5,0.5)local P=j.prop(N,
'BackgroundTransparency',28)N.MouseEnter:Connect(function()P:to(0)end)N.
MouseLeave:Connect(function()P:to(1)end)return N end function s.new(J)local K=J.
_registry if K and K.current then K.current:destroy()end local L=h.new()local M=
q.new(J.theme)local N=f.new()local O=c.service('UserInputService')local P=O.
TouchEnabled and not O.MouseEnabled local Q=i('ScreenGui',{Name=randomName(),
IgnoreGuiInset=true,ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.
Sibling,DisplayOrder=J.displayOrder or 10000})c.protect(Q)Q.Parent=c.guiParent()
L:add(Q)local R=c.files()local S=J.folder or'sottui'local T=J.stateFile or(S..
'/window.json')local U=nil if R then R.folder(S)local V=R.read(T)U=V and decode(
V)end if type(U)~='table'then U={}end local V=Q.AbsoluteSize local W=Vector2.
new(math.clamp(tonumber(U.w)or z.X,A.X,math.max(V.X,A.X)),math.clamp(tonumber(U.
h)or z.Y,A.Y,math.max(V.Y,A.Y)))local X=tonumber(U.scale)or(if V.X<800 then 0.8
else 1)local Y=Vector2.new(tonumber(U.x)or math.floor((V.X-W.X*X)/2),tonumber(U.
y)or math.floor((V.Y-W.Y*X)/2))local Z=i('Frame',{Name='Root',Size=UDim2.
fromOffset(W.X,W.Y),Position=UDim2.fromOffset(Y.X,Y.Y),Parent=Q})local _=i(
'UIScale',{Scale=X,Parent=Z})local aa=i('Frame',{Name='Clip',Size=UDim2.new(1,0,
0,0),BackgroundTransparency=0,ClipsDescendants=true,Active=true,Parent=Z})M:
paint(aa,'BackgroundColor3','base')local ab=i('Frame',{Name='Layer',Size=UDim2.
fromScale(1,1),ZIndex=100,Parent=Q})local ac=i('TextButton',{Name='Modal',Size=
UDim2.fromOffset(0,0),Modal=true,Visible=false,Parent=Z})local ad=i('TextButton'
,{Name='Bar',Size=UDim2.new(1,0,0,v),Parent=aa})local ae=i('TextLabel',{
AutomaticSize=Enum.AutomaticSize.X,Position=UDim2.fromOffset(20,0),Size=UDim2.
fromOffset(0,v),TextSize=x,Text=J.title or'sottoro',Parent=ad})M:type(ae,
'display')M:paint(ae,'TextColor3','accent')local af=i('Frame',{Name='NavClip',
Size=UDim2.new(1,0,0,v),ClipsDescendants=true,Parent=aa})local ag=i('Frame',{
Name='NavRail',Size=UDim2.fromScale(1,1),Parent=af})local ah=i('Frame',{Name=
'NavList',AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.new(0,0,1,0),Parent=ag})
i('UIListLayout',{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0
,y),SortOrder=Enum.SortOrder.LayoutOrder,Parent=ah})local ai=i('Frame',{Name=
'Marker',AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.
new(0,0,0,4),BackgroundTransparency=0,ZIndex=2,Parent=ag})M:paint(ai,
'BackgroundColor3','accent')local aj=i('Frame',{Position=UDim2.new(0,0,0,v-1),
Size=UDim2.new(1,0,0,1),BackgroundTransparency=0,Parent=aa})M:paint(aj,
'BackgroundColor3','line')local ak=i('Frame',{Name='Body',Position=UDim2.
fromOffset(0,v),Size=UDim2.new(1,0,1,-v),ClipsDescendants=true,Parent=aa})local
al=i('Frame',{Name='Pages',Size=UDim2.fromScale(1,1),Parent=ak})local am=i(
'Frame',{Name='Wipe',Size=UDim2.fromScale(1,1),BackgroundTransparency=0,Visible=
false,ZIndex=8,Parent=ak})M:paint(am,'BackgroundColor3','base')local an=i(
'Frame',{Size=UDim2.new(0,8,1,0),BackgroundTransparency=0,ZIndex=9,Parent=am})M:
paint(an,'BackgroundColor3','accent')local ao=i('Frame',{AnchorPoint=Vector2.
new(0,1),Position=UDim2.fromScale(0,1),Size=UDim2.new(1,0,0,4),
BackgroundTransparency=0,Visible=false,ZIndex=12,Parent=aa})M:paint(ao,
'BackgroundColor3','accent')local ap=i('TextButton',{Name='Grip',AnchorPoint=
Vector2.new(1,1),Position=UDim2.fromScale(1,1),Size=UDim2.fromOffset(20,20),
ZIndex=6,Parent=aa})for aq,ar in{{UDim2.new(1,-3,1,-3),UDim2.fromOffset(10,2)},{
UDim2.new(1,-3,1,-3),UDim2.fromOffset(2,10)}}do local as=i('Frame',{AnchorPoint=
Vector2.new(1,1),Position=ar[1],Size=ar[2],BackgroundTransparency=0,ZIndex=7,
Name='Tick'..aq,Parent=ap})M:paint(as,'BackgroundColor3','lineStrong')end local
aq=setmetatable({ctx=nil,pages={},elements={},ordered={},current=nil,isOpen=
false,collapsed=U.collapsed==true,destroyed=false,size=W,position=Y,
visibilityChanged=p.new(),_maid=L,_gui=Q,_root=Z,_clip=aa,_layer=ab,_modal=ac,
_scale=_,_navClip=af,_navList=ah,_navItems={},_pageHost=al,_wipe=am,_wipeEdge=an
,_shutterEdge=ao,_grip=ap,_files=R,_stateFile=T,_savedPage=U.page,_dialogIds=0,
_registry=K},I)if K then K.current=aq end local ar={theme=M,input=N,touch=P,
glyph=e.new(M),tint=r.new(M),uiScale=function()return _.Scale end,isShowing=
function(ar)if not aq.isOpen then return false end local as=ar._page or(ar.host
and ar.host._page)return as==nil or as==aq.pages[aq.current]end,setScrollLocked=
function(ar)local as=aq.pages[aq.current]if as and as.frame and P then as.frame.
ScrollingEnabled=not ar end end}aq.ctx=ar ar.popover=l.popover(ar,ab)ar.tooltip=
l.tooltip(ar,ab)ar.hover=l.hover(ar)ar.notifications=k.new(ar,ab)ar.notify=
function(as)ar.notifications:show(as)end aq.keys=g.new(N,c,function()return aq.
isOpen end)ar.keys=aq.keys local function drawMarker()local as,at=aq._markerLeft
,aq._markerRight ai.Position=UDim2.new(0,as,1,0)ai.Size=UDim2.new(0,math.max(at-
as,0),0,4)end aq._markerLeft,aq._markerRight=0,0 aq._edgeLeft=L:add(j.new(0,F,
function(as)aq._markerLeft=as drawMarker()end))aq._edgeRight=L:add(j.new(0,F,
function(as)aq._markerRight=as drawMarker()end))aq._navScroll=L:add(j.new(0,F,
function(as)ag.Position=UDim2.fromOffset(as,0)end))aq._pageSlide=L:add(j.prop(al
,'Position',D))aq._wipeAt=L:add(j.prop(am,'Position',D))aq._shutter=L:add(j.
prop(aa,'Size',B))aq._palette=n.new(ar,ab,function()return aq.ordered end,
function(as)aq:reveal(as)end)local as=headerButton(ar,ad,0,function(as,at)return
ar.glyph.cross(as,at)end)as.Activated:Connect(function()aq:setOpen(false)end)
local at=headerButton(ar,ad,-44,function(at,au)return ar.glyph.dash(at,au)end)at
.Activated:Connect(function()aq:collapse(not aq.collapsed)end)local au=i(
'TextButton',{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-96,0.5,0),
Size=UDim2.fromOffset(64,v),TextSize=17,Text='Search',TextXAlignment=Enum.
TextXAlignment.Right,Parent=ad})M:type(au,'text',true)M:paint(au,'TextColor3',
'muted')au.MouseEnter:Connect(function()ar.tint(au,'TextColor3','text')end)au.
MouseLeave:Connect(function()ar.tint(au,'TextColor3','muted')end)au.Activated:
Connect(function()aq._palette:toggle()end)local av=i('TextLabel',{AutomaticSize=
Enum.AutomaticSize.X,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-176,
0.5,0),Size=UDim2.fromOffset(0,v),TextSize=17,Text=J.subtitle or'',
TextXAlignment=Enum.TextXAlignment.Right,Parent=ad})M:type(av,'text')M:paint(av,
'TextColor3','faint')aq._subtitleLabel=av local function fitBar()local aw=_.
Scale local ax=Z.AbsoluteSize.X/aw local ay=20+ae.AbsoluteSize.X/aw+24 local az=
ah.AbsoluteSize.X/aw local aA=176+av.AbsoluteSize.X/aw+20 av.Visible=J.subtitle
~=nil and ay+az+aA<=ax local aB=if av.Visible then aA else 176 af.Position=UDim2
.fromOffset(ay,0)af.Size=UDim2.new(1,-(ay+aB),0,v)aq:_syncMarker(true)end aq.
_fitBar=fitBar ae:GetPropertyChangedSignal('AbsoluteSize'):Connect(fitBar)av:
GetPropertyChangedSignal('AbsoluteSize'):Connect(fitBar)Z:
GetPropertyChangedSignal('AbsoluteSize'):Connect(fitBar)ah:
GetPropertyChangedSignal('AbsoluteSize'):Connect(fitBar)task.defer(fitBar)ad.
InputBegan:Connect(function(aw)local ax=aw.UserInputType if ax~=Enum.
UserInputType.MouseButton1 and ax~=Enum.UserInputType.Touch then return end
local ay=if ax==Enum.UserInputType.Touch then N:at(aw)else N:pointer()local az=
aq.position N:capture(function(aA)aq.position=az+(aA-ay)aq:_clamp()aq:
_saveState()end)end)ap.InputBegan:Connect(function(aw)local ax=aw.UserInputType
if ax~=Enum.UserInputType.MouseButton1 and ax~=Enum.UserInputType.Touch then
return end local ay=if ax==Enum.UserInputType.Touch then N:at(aw)else N:pointer(
)local az=aq.size N:capture(function(aA)local aB=_.Scale local aC=az+(aA-ay)/aB
local aD=(Q.AbsoluteSize-aq.position)/aB aq.size=Vector2.new(math.clamp(aC.X,A.X
,math.max(aD.X,A.X)),math.clamp(aC.Y,A.Y,math.max(aD.Y,A.Y)))Z.Size=UDim2.
fromOffset(math.floor(aq.size.X),math.floor(aq.size.Y))aq:_saveState()end)end)N.
moved:connect(function(aw)ar.hover:verify(aw)end)N.wheel:connect(function(aw)if
not aq.isOpen or ar.popover:isOpen()or aq._palette:isOpen()then return end local
ax=aq.pages[aq.current]if ax==nil or ax.frame==nil then return end local ay=N:
pointer()local az,aA=ax.frame.AbsolutePosition,ax.frame.AbsoluteSize if ay.X>=az
.X and ay.Y>=az.Y and ay.X<=az.X+aA.X and ay.Y<=az.Y+aA.Y then ax:wheel(aw)end
end)N.keyDown:connect(function(aw,ax)if aw.UserInputType~=Enum.UserInputType.
Keyboard then return end local ay=aw.KeyCode.Name if aq._palette:key(ay)or ar.
popover:key(ay)then return end if ay=='Escape'and aq._dialogClose then aq.
_dialogClose()return end if ax or N:typing()then return end if aq.isOpen and ay
=='K'then if O:IsKeyDown(Enum.KeyCode.LeftControl)or O:IsKeyDown(Enum.KeyCode.
RightControl)then aq._palette:toggle()end end end)L:add(Q:
GetPropertyChangedSignal('AbsoluteSize'):Connect(function()aq:_clamp()end))L:
add(M.changed:connect(function()for aw,ax in aq.pages do for ay,az in ax._views
do pcall(function()az:retint()az.refresh()end)end end end))if P then local aw=i(
'TextButton',{Name='Reopen',Position=UDim2.fromOffset(16,80),Size=UDim2.
fromOffset(112,44),BackgroundTransparency=0,TextSize=22,Text=J.title or'sottoro'
,Visible=false,Parent=Q})M:type(aw,'display')M:paint(aw,'BackgroundColor3',
'accent')M:paint(aw,'TextColor3','onAccent')local ax=false aw.InputBegan:
Connect(function(ay)if ay.UserInputType~=Enum.UserInputType.Touch then return
end ax=false local az=N:at(ay)local aA=aw.AbsolutePosition-Q.AbsolutePosition N:
capture(function(aB)local aC=aB-az if aC.Magnitude>8 then ax=true aw.Position=
UDim2.fromOffset(aA.X+aC.X,aA.Y+aC.Y)end end)end)aw.Activated:Connect(function()
if not ax then aq:setOpen(true)end end)aq.visibilityChanged:connect(function(ay)
aw.Visible=not ay end)end local aw=o.new({window=aq,nextId=function()return 0
end,_register=function(aw,ax,ay)if ay then aq.elements[ax.id]=ax end ax.
_pageName=''end,_invalidate=function()end},'')aq.menuKey=aw:key('__menu',{label=
'Menu',default=J.key or'RightShift',mode='Toggle',saved=false,onPress=function()
aq:toggle()end})local ax=c.service('RunService')j.setAttach(function(ay)return
ax.PreRender:Connect(ay)end)aq:_clamp()if J.fonts~=false and R then L:add(task.
defer(function()local ay=J.fontTag or t local az=d.load(S..'/fonts',string.
format(u,ay),encode)if not aq.destroyed and(az.text or az.display)then M:
setFonts(az.text,az.display)end end))end if J.autoShow~=false then task.defer(
function()aq:setOpen(true)end)end return aq end function s.setVersion(aa)t=aa
end return s end function a.C()local aa=a.cache.C if not aa then aa={c=
__modImpl()}a.cache.C=aa end return aa.c end end end local aa=a.a()local ab=a.b(
)local ac=a.e()local ad=a.C()local ae='0.1.0'local function registry()local af=
aa.global('getgenv')local ag=if type(af)=='function'then af()else _G local ah=ag
.__sottui if type(ah)~='table'then ah={current=nil}ag.__sottui=ah end return ah
end local af={version=ae,motion=ab}ad.setVersion('v'..ae)function af.window(ag)
local ah=table.clone(ag or{})ah._registry=registry()return ad.new(ah)end
function af.current()return registry().current end function af.obsidian()return
ac.new(af)end return af