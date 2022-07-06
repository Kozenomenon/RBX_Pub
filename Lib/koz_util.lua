--[[
	Koz's LUA Script Utility 
    Performs exploit normalization and console print setup. 
    Provides GUI
	Version: 1.0 | 2022-07-05
]]--

local RunService,Players,UserInputService,TextService

-- will be returned at end
local util = {}
util.errors = {}
-- internal locals
local _rconsoleprint,_prnt_nl,_prnt_pref,_prnt,_rconsoleclear,_rconsolecreate,_rconsolename,_rconsolewarn,_rconsoleerr,_rconsoleinfo

function init_error(msg,stop)
    table.insert(util.errors,msg)
    util.stop_init = (stop and true) or util.stop_init
end

local settings = {
    DebugToFile = nil,
    PreferRobloxConsolePrints = true,
    PrintVerbose = false,

    ToggleGui = "G", -- keybind to show/hide the info gui 
    KillScriptKey = "F1",
    GuiOpenSpeed = 0.5,
    GetGuiTitle = function() return "No 'GetGuiTitle' Was Set!" end,
    Toggles = {},
    MainGUI = { --[[ Main GUI ]]--
		Enabled = true, -- set to false and gui will not function at all 
		TextOutlineRGB = {0,0,0}, -- (R)ed,(G)reen,(B)lue values for text outline color. Values are 0-255.
		TextRGB = {0,255,255}, -- (R)ed,(G)reen,(B)lue values for text color. Values are 0-255.
		TextSize = 18, -- Font size
		BorderRGB = {0,88,88}, -- color for gui borders
		BackgroundRGB = {0,36,36}, -- color for gui background
		InactiveFadeFactor = 1, -- multiplier on the fade when mouse is not hovering the gui. >1 fades less, <1 fades more
		PositionXOffset = 0, -- values other than 0 will adjust left/right position of gui. <0 moves left. >0 moves right.
		PositionYOffset = 0, -- values other than 0 will adjust up/down position of gui. <0 moves up. >0 moves down.
		--Width
	},
	NotifyGUI = { --[[ Notification GUI ]]--
		Enabled = true, -- set to false and notifications will not pop up on the ui, during script load or during play 
		TextSize = 27, -- font size 
		ShowLines = 6, -- controls how many notify text lines can display, and will affect vertical placement 
		DisplayTime = 3, -- how many seconds a notify text displays for 
		TextOutlineRGB = {0,0,0}, -- color of outline on text, applies to all types. 
		DefaultRGB = {245,245,245}, -- (R)ed,(G)reen,(B)lue values for text color. Values are 0-255. by notify type.
		InfoRGB = {239,239,192},
		WarnRGB = {255,255,0},
		ErrorRGB = {255,64,0},
		SuccessRGB = {0,255,0},
		DebugRGB = {222,128,255},
	},
}
function applySettings(newSettings)

    for i,v in pairs(newSettings) do
        settings[i] = v
    end

    util.LogColor.Default = Color3.fromRGB(unpack(settings.NotifyGUI.DefaultRGB or {245,245,245}))
	util.LogColor.Info = Color3.fromRGB(unpack(settings.NotifyGUI.InfoRGB or {239,239,192}))
	util.LogColor.Warn = Color3.fromRGB(unpack(settings.NotifyGUI.WarnRGB or {255,255,0}))
	util.LogColor.Error = Color3.fromRGB(unpack(settings.NotifyGUI.ErrorRGB or {255,64,0}))
	util.LogColor.Success = Color3.fromRGB(unpack(settings.NotifyGUI.SuccessRGB or {0,255,0}))
	util.LogColor.Debug = Color3.fromRGB(unpack(settings.NotifyGUI.DebugRGB or {222,128,255}))
end

------
do ---  print func setup (initial)
------
_rconsoleprint = KRNL_LOADED and rconsoleinfo or rconsoleprint or output or printoutput or printdebug or print
_prnt_nl = _rconsoleprint == rconsoleprint
_prnt_pref = function(clr,msg)
    if _prnt_nl and clr and msg then
        _rconsoleprint("[")
        if identifyexecutor and identifyexecutor()=="ScriptWare" then
            _rconsoleprint(msg,clr:lower())
        else
            _rconsoleprint("@@"..clr.."@@")
            _rconsoleprint(msg)
            _rconsoleprint("@@LIGHT_GRAY@@")
        end
        _rconsoleprint("] ")
    end
end
_prnt = function(msg: string, prefix: string, pref_color: string)
    msg = msg or ""
    if _prnt_nl then
        if #msg==0 or msg:sub(#msg)~="\n" then msg = msg.."\n" end
    end
    if prefix and #prefix>0 then
        if _prnt_nl and pref_color and #pref_color>0 then
            _prnt_pref(pref_color,prefix)
        else
            msg = "["..prefix.."] "..msg
        end
    end
    _rconsoleprint(msg)
end
_rconsoleclear = rconsoleclear or consoleclear or function() end
_rconsolecreate = rconsolecreate or consolecreate or function() end
_rconsolename = rconsolename or consolesettitle or rconsolesettitle or function() end
_rconsolewarn = rconsolewarn or function(msg: string) _prnt(msg,"WARN","YELLOW") end
_rconsoleerr = rconsoleerr or function(msg: string) _prnt(msg,"ERROR","RED") end
_rconsoleinfo = rconsoleinfo or function(msg: string) _prnt(msg,"INFO","CYAN") end
------
end -- 
------

------
do ---  exploit normalizations and checks
------
getrawmetatable = getrawmetatable
setrawmetatable = setrawmetatable
setreadonly = setreadonly or (make_writeable and make_readonly and (function(tbl,flg) if flg then make_writeable(tbl) else make_readonly(tbl) end end))
setidentity = setidentity or (syn and syn.set_thread_identity) or setthreadcontext or set_thread_context
getidentity = setidentity and (getidentity or (syn and syn.get_thread_identity) or getthreadidentity or getthreadcontext or get_thread_context)
getcallingscript = getcallingscript or get_calling_script
getloadedmodules = getloadedmodules or get_loaded_modules
hookfunction = hookfunction or hookfunc or detour_function or replaceclosure
--restoreclosure? (Elysian)
getgc = getgc or get_gc_objects
getregistry = getregistry or getreg or get_gc_objects
secure_call = (syn and syn.secure_call) or (KRNL_SAFE_CALL and function(a,b,...) return KRNL_SAFE_CALL(a,...) end)
readfile = readfile --or error("Exploit unsupported! No 'readfile' function!")
writefile = writefile --or error("Exploit unsupported! No 'writefile' function!")
isfile = isfile or function(fn) local ftxt = nil; pcall(function() ftxt = readfile(fn) end) return (ftxt ~= nil) end
Drawing = Drawing --or warn("Exploit does not support Drawing for Gui!")
------
end -- 
------

------
do ---  exploit requirements check
------
if not secure_call then
    secure_call = function(a,b,...)
        if typeof(a)=="function" then
            return a(...)
        else
            return nil
        end
    end
end
if not readfile then init_error("Exploit unsupported! No 'readfile' function!",true) end
if not writefile then init_error("Exploit unsupported! No 'writefile' function!",true) end
if not Drawing then init_error("Exploit unsupported! No 'Drawing' for UI!",true) end
if not getrawmetatable then init_error("Exploit unsupported! No 'getrawmetatable' function!",true) end
if not setrawmetatable then init_error("Exploit unsupported! No 'setrawmetatable' function!",true) end
if not setreadonly then init_error("Exploit unsupported! No 'setreadonly' (metatable) function!",true) end
if not setidentity then init_error("Exploit unsupported! No 'setidentity' function!",true) end
if not getidentity then init_error("Exploit unsupported! No 'getidentity' function!",true) end
if not getcallingscript then init_error("Exploit unsupported! No 'getcallingscript' function!",true) end
if not getloadedmodules then init_error("Exploit unsupported! No 'getloadedmodules' function!",true) end
------
end -- 
------

------
do ---  
------

------
end --  
------

function addFunctions()
------
do --- scheduler / async tasks
------
local scheduled = {}
--- schedules the provided function (and calls it with any args after)
function util:_schedule(f, ...)
    table.insert(scheduled, {f, ...})
    return #scheduled
end

--- yields the current thread until the scheduler gives the ok
function util:_scheduleWait()
    local thread = coroutine.running()
    self:_schedule(function()
        coroutine.resume(thread)
    end)
    coroutine.yield()
end

function util:_startScheduler()
    local me = self
    if me._schedulerEvent then
        pcall(function() me._schedulerEvent:Disconnect() end)
        me._schedulerEvent = nil
    end
    me._schedulerRunning = false
    me._schedulerEvent = RunService.Heartbeat:Connect(function(deltaTime)
        if #scheduled > 1000 then
            table.remove(scheduled, #scheduled)
        end
        local cnt = 0
        while #scheduled>0 and cnt<math.random(3,10) do
            cnt=cnt+1
            local currentf = scheduled[1]
            table.remove(scheduled, 1)
            if type(currentf) == "table" and type(currentf[1]) == "function" then
                pcall(unpack(currentf))
            end
        end
    end)
    me._schedulerRunning = true
end
function util:_stopScheduler()
    local me = self
    if me._schedulerEvent then
        pcall(function() me._schedulerEvent:Disconnect() end)
        me._schedulerEvent = nil
    end
    table.clear(scheduled)
    me._schedulerRunning = false
end
------
end -- schedule / async tasks
------

-----
do -- Log Type / Color
-----
util.LogType = {
	Default = 1,
	Info = 2,
	Warn = 3,
	Error = 4,
	Success = 5,
	Debug = 6
}
util.LogColor = {
	Default = Color3.fromRGB(245,245,245),
	Info = Color3.fromRGB(239,239,192),
	Warn = Color3.fromRGB(255,255,0),
	Error = Color3.fromRGB(255,64,0),
	Success = Color3.fromRGB(0,255,0),
	Debug = Color3.fromRGB(222,128,255)
}
function util:_getLogColor(logType)
    local me = self
    return me.LogColor[me:_TableContains(me.LogType,logType)] or me.LogColor.Default
end
-----
end
-----

-----
do -- Print & Misc Utility
-----

function util:_trim(s)
    return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
end
function util:_argsToPrintLine(...)
    local args = {...}
    local txt = ""
    for i,v in ipairs(args) do
        if #txt > 0 then
            txt = self:_trim(txt) .. " | "
        end
        txt = txt .. tostring(v)
    end
    return txt
end
function util:_actualDebugToFile(pargs,prefix)
    local fn = settings.DebugToFile
    if fn and appendfile and writefile and isfile then
        local content = prefix.." "..self:_argsToPrintLine(unpack(pargs))
        if isfile(fn) then
            appendfile(fn, content)
        else
            writefile(fn, content)
        end
    end
end
function util:_debugToFile(pargs,prefix)
    if not settings.DebugToFile then
        return
    end
    if self._schedulerRunning then
        self:_schedule(self._actualDebugToFile,self,pargs,prefix)
    else
        self:_actualDebugToFile(pargs,prefix)
    end
end
function util:_actualPcon(pargs,prefix,prefclr)
    if settings.PreferRobloxConsolePrints and _prnt then
        _prnt(self:_argsToPrintLine(unpack(pargs)),prefix,prefclr)
    else
        print(prefix or "",unpack(pargs))
    end
    self:_debugToFile(pargs,prefix)
end
function util:_timePrefix()
    if self._Kill_Meh and self._killTmStart then
        return tostring(tick()-self._killTmStart):sub(1,5),"YELLOW"
    elseif not self._init and self._initTmStart then
        return tostring(tick()-self._initTmStart):sub(1,5),"CYAN"
    end
    return
end
function util:_pcon(...)
    local args = {...}
    local tmpref,clr = self:_timePrefix()
    if self._schedulerRunning then
        self:_schedule(self._actualPcon,self,args,tmpref,clr)
    else
        self:_actualPcon(args,tmpref,clr)
    end
end
function util:_perr(...)
    if self._schedulerRunning then
        self:_schedule(_rconsoleerr,self:_argsToPrintLine(...))
    else
        _rconsoleerr(self:_argsToPrintLine(...))
    end
    self:_debugToFile({...},"[ERROR]")
end
function util:_pwarn(...)
    if self._schedulerRunning then
        self:_schedule(_rconsolewarn,self:_argsToPrintLine(...))
    else
        _rconsolewarn(self:_argsToPrintLine(...))
    end
    self:_debugToFile({...},"[WARN]")
end
function util:_pinfo(...)
    if self._schedulerRunning then
        self:_schedule(_rconsoleinfo,self:_argsToPrintLine(...))
    else
        _rconsoleinfo(self:_argsToPrintLine(...))
    end
    self:_debugToFile({...},"[INFO]")
end
function util:_pdbg(...)
    if settings.PrintVerbose then self:_plog({...},self.LogType.Debug) end
end
function util:_psucc(...)
    self:_plog({...},self.LogType.Success)
end
function util:_plog(pargs,logtype)
    local pref = self:_TableContains(self.LogType,logtype) or "Default"
    if pref=="Error" then self:_perr(unpack(pargs)) 
    elseif pref=="Warn" then self:_pwarn(unpack(pargs))
    elseif pref=="Info" then self:_pinfo(unpack(pargs))
    elseif pref=="Default" then self:_pcon(unpack(pargs))
    else
        local clr = pref=="Debug" and "MAGENTA" or pref=="Success" and "GREEN" or nil
        if pref~="Debug" or settings.PrintVerbose then
            if self._schedulerRunning then
                self:_schedule(self._actualPcon,self,pargs,pref,clr)
            else
                self:_actualPcon(pargs,pref,clr)
            end
        end
    end
end
function util:_pconclear()
    if settings.PreferRobloxConsolePrints and _rconsoleclear then
        _rconsoleclear()
    end
end
function util:_notify(msg,logtype)
    self:_plog({msg},logtype)
    self._notifies = self._notifies or {}
    local notify = {["msg"] = msg, ["tm"] = tick(), ["logtype"]=logtype}
    table.insert(self._notifies,1,notify)
end
function util:_TableContains(tbl,val)
    if tbl and type(tbl) == "table" then
        for i,v in pairs(tbl) do
            if v==val then
                return i
            end
        end
    end
    return
end
function util:_TableCopy(t)
    local copy = t and type(t)=="table" and {} or nil
    if copy then
        for i,v in pairs(t) do
            if v and type(v)=="table" then
                copy[i] = self:_TableCopy(v)
            else
                copy[i] = v
            end
        end
    end
    return copy
end
function util:_instancePath(inst: Instance,path: string)
    if inst and typeof(inst)=="Instance" then
        path = path and type(path)=="string" and #path>0 and inst.Name.."."..path or inst.Name
        if inst~=game and not inst.Parent then
            return "nil."..path
        elseif inst~=game and inst.Parent then
            return self:_instancePath(inst.Parent,path)
        end
    end
    return path
end
function util:_searchPathForParents(inst: Instance,parents: table)
    if inst and typeof(inst)=="Instance" and inst~=game and parents and type(parents)=="table" and #parents>0 then
        return table.find(parents,inst) or inst.Parent and table.find(parents,inst.Parent) or inst.Parent and self:_searchPathForParents(inst.Parent) or false
    end
    return false
end

------
end -- Utility
------

-----
do -- GUI 
-----
function util:_getKeycode(bind)
    return (pcall(function() return (Enum.KeyCode[bind]) end) and Enum.KeyCode[bind] or bind)
end
function util:_draw(obj, props)
    local tmpObj
    if (Drawing and obj and type(obj)=="string" and props and type(props) == "table") then
        tmpObj = Drawing.new(obj)
        local mt = getmetatable(tmpObj)
        if not mt.__type then mt.__type = obj end

        for i, v in next, props do
            tmpObj[i] = v
        end
    end
    return tmpObj
end
function util:_getGuiText()
    local me = self
    local txt = (
		" [%s] Show / Hide Gui\n"):format(
            settings.ToggleGui
    )
    for i,v in pairs(settings.Toggles) do
        if v and v.Key and v.GetText and v.Callback and 
           typeof(v.GetText)=="function" and typeof(v.Callback)=="function" then
            txt = txt..(" [%s] %s\n"):format(v.Key,v:GetText())
        end
    end
    return txt
end
function util:_linesAreIntersecting(ln1v1: Vector2,ln1v2: Vector2,ln2v1: Vector2,ln2v2: Vector2 )
    -- https://stackoverflow.com/questions/217578/how-can-i-determine-whether-a-2d-point-is-within-a-polygon
    local d1, d2
    local a1, a2, b1, b2, c1, c2
    -- Convert vector 1 to a line (line 1) of infinite length.
    -- We want the line in linear equation standard form: A*x + B*y + C = 0
    -- See: http:--en.wikipedia.org/wiki/Linear_equation
    a1 = ln1v2.Y - ln1v1.Y
    b1 = ln1v1.X - ln1v2.X
    c1 = (ln1v2.X * ln1v1.Y) - (ln1v1.X * ln1v2.Y)
    -- Every point (x,y), that solves the equation above, is on the line,
    -- every point that does not solve it, is not. The equation will have a
    -- positive result if it is on one side of the line and a negative one 
    -- if is on the other side of it. We insert (x1,y1) and (x2,y2) of vector
    -- 2 into the equation above.
    d1 = (a1 * ln2v1.X) + (b1 * ln2v1.Y) + c1
    d2 = (a1 * ln2v2.X) + (b1 * ln2v2.Y) + c1
    -- If d1 and d2 both have the same sign, they are both on the same side
    -- of our line 1 and in that case no intersection is possible. Careful, 
    -- 0 is a special case, that's why we don't test ">=" and "<=", 
    -- but "<" and ">".
    if (d1 > 0 and d2 > 0) or (d1 < 0 and d2 < 0) then return "NO" end
    -- The fact that vector 2 intersected the infinite line 1 above doesn't 
    -- mean it also intersects the vector 1. Vector 1 is only a subset of that
    -- infinite line 1, so it may have intersected that line before the vector
    -- started or after it ended. To know for sure, we have to repeat the
    -- the same test the other way round. We start by calculating the 
    -- infinite line 2 in linear equation standard form.
    a2 = ln2v2.Y - ln2v1.Y
    b2 = ln2v1.X - ln2v2.X
    c2 = (ln2v2.X * ln2v1.Y) - (ln2v1.X * ln2v2.Y)
    -- Calculate d1 and d2 again, this time using points of vector 1.
    d1 = (a2 * ln1v1.X) + (b2 * ln1v1.Y) + c2
    d2 = (a2 * ln1v2.X) + (b2 * ln1v2.Y) + c2
    -- Again, if both have the same sign (and neither one is 0),
    -- no intersection is possible.
    if (d1 > 0 and d2 > 0) or (d1 < 0 and d2 < 0) then return "NO" end
    -- If we get here, only two possibilities are left. Either the two
    -- vectors intersect in exactly one point or they are collinear, which
    -- means they intersect in any number of points from zero to infinite.
    if ((a1 * b2) - (a2 * b1) == 0.0) then return "COLLINEAR" end
    -- If they are not collinear, they must intersect in exactly one point.
    return "YES"
end
function util:_isPointWithinDrawingElement(el,point)
    -- ah, this is where the drawing element's type is hidden at
    local eltyp = getmetatable(el).__type
    local xmin,xmax,ymin,ymax
    local pnts,rad
    if eltyp == "Triangle" then
        -- get simple box around tri for quick check
        xmin = math.min(el.PointA.X,el.PointB.X,el.PointC.X)
        xmax = math.max(el.PointA.X,el.PointB.X,el.PointC.X)
        ymin = math.min(el.PointA.Y,el.PointB.Y,el.PointC.Y)
        ymax = math.max(el.PointA.Y,el.PointB.Y,el.PointC.Y)
        -- set points array for deeper check, if simple passes
        pnts = { el.PointA,el.PointB,el.PointC }
    elseif eltyp == "Square" or eltyp == "Image" then
        -- square and image are simple box check only 
        xmin = el.Position.X
        xmax = el.Position.X+el.Size.X
        ymin = el.Position.Y
        ymax = el.Position.Y+el.Size.Y
    elseif eltyp == "Text" then
        -- text is also simple box check only, but how to 
        -- get bounds differs from square/image 
        xmin = el.Center and el.Position.X-el.TextBounds.X/2 or el.Position.X
        xmax = el.Center and el.Position.X+el.TextBounds.X/2 or el.Position.X+el.TextBounds.X
        ymin = el.Position.Y
        ymax = el.Position.Y+el.TextBounds.Y
    elseif eltyp == "Quad" then
        -- get simple bounds for quad for quick check, point must be within this first 
        xmin = math.min(el.PointA.X,el.PointB.X,el.PointC.X,el.PointD.X)
        xmax = math.max(el.PointA.X,el.PointB.X,el.PointC.X,el.PointD.X)
        ymin = math.min(el.PointA.Y,el.PointB.Y,el.PointC.Y,el.PointD.Y)
        ymax = math.max(el.PointA.Y,el.PointB.Y,el.PointC.Y,el.PointD.Y)
        -- set points in array for deeper check, if simple check passes
        pnts = { el.PointA,el.PointB,el.PointC,el.PointD }
    elseif eltyp == "Circle" then
        -- set radius aside so we know to do distance check
        rad = el.Radius
        -- if point is within simple box check 
        xmin = el.Position.X-rad
        xmax = el.Position.X+rad
        ymin = el.Position.Y-rad
        ymax = el.Position.Y+rad
    end
    -- this is the quick check. 
    -- if point not within these general bounds, then it cannot be within drawing element
    local chk = point.X>=xmin and point.X<=xmax and point.Y>=ymin and point.Y<=ymax
    if chk and pnts then
        -- this is to check further for quads and tris
        -- will use test line from left of screen on X axis, at point's Y coord
        -- if intersection count is odd then point is within the shape, if 0 or even 
        -- then it means the point is outside the shape. 
        local lines = {}
        local last
        -- convert the points of the shape to lines ( table of {vector2,vector2} )
        for i,v in ipairs(pnts) do
            if last then table.insert(lines,{Vector2.new(last.X,last.Y),Vector2.new(v.X,v.Y)}) end
            last = v
        end
        -- since loop was on points, we need to make the last line to complete shape
        table.insert(lines,{Vector2.new(last.X,last.Y),Vector2.new(pnts[1].X,pnts[1].Y)})
        -- this is the test line going from -100 X which should be off screen 
        -- and going to the point, so using the point's Y value
        local test = {Vector2.new(-100,point.Y),Vector2.new(point.X,point.Y)}
        local hits = 0
        -- count the number of intersections for all the lines, with the test line
        for i,v in pairs(lines) do
            if self:_linesAreIntersecting(test[1],test[2],v[1],v[2])=="YES" then 
                hits = hits+1
            end
        end
        -- modulus 2 will say if 0/even or odd
        chk = hits%2~=0
    elseif chk and rad then
        -- this is to check for circles
        -- uses simple distance check on the point and center of circle
        -- if distance is equal or less than radius then it is within circle 
        -- sqrt is a costly operation, so we rely on simple check above first 
        local distSq = math.pow(math.max(el.Position.X,point.X)-math.min(el.Position.X,point.X),2) + -- a^2
                        math.pow(math.max(el.Position.Y,point.Y)-math.min(el.Position.Y,point.Y),2)	 -- b^2
        -- c^2 = a^2 + b^2, solving for c (distance)
        local dist = math.sqrt(distSq)
        chk = dist<=rad
    end
    return chk
end
function util:_isMouseWithinGuiElement(el)
    local mloc = UserInputService:GetMouseLocation()
    return self:_isPointWithinDrawingElement(el,mloc)
end
function util:_updateGui()
    local conf = settings.MainGUI
    if self._gui and conf and conf.Enabled and workspace.CurrentCamera then
        local gui = self._gui

        local txtsz = conf.TextSize or 18
        local mainTxt = self:_getGuiText()
        local mainTxtSz = TextService:GetTextSize(mainTxt,txtsz,Enum.Font.Code,Vector2.new(1000,1000))
        local lns = mainTxt:split('\n')
        local width = math.max(conf.Width or 0,mainTxtSz.X+10,100)
        local height = math.max(txtsz*(#lns+2)+20,mainTxtSz.Y+20+txtsz*2,100)

        
        local srn_w = workspace.CurrentCamera.ViewportSize.X
        local srn_h = workspace.CurrentCamera.ViewportSize.Y
        local openleft = -(width+15) + (conf.PositionXOffset or 0)
        local closeleft = 5
        -- slide in/out
        self._showGui_Track = self._showGui_Track or {Show=self._showGui,Current=0,Time=tick()+settings.GuiOpenSpeed,Start=0,Base=settings.GuiOpenSpeed}
        local trk = self._showGui_Track
        if trk.Time>tick() then
            local prog = 1 - (trk.Time-tick())/trk.Base
            local tot = self._showGui and (1-trk.Start) or (0-trk.Start)
            trk.Current = trk.Start + prog*tot
        else
            trk.Current = self._showGui and 1 or 0
            trk.Start = trk.Current
            trk.Time = 0
            trk.Base = settings.GuiOpenSpeed
        end
        local top = srn_h - (height+70) + (conf.PositionYOffset or 0)
        local pos = Vector2.new(srn_w+closeleft,top):Lerp(Vector2.new(srn_w+openleft,top),trk.Current)
        local left = pos.X
        local right = left+width
        local bottom = top+height

        local mloc = UserInputService:GetMouseLocation()
        if not self._Player then
            self._Player = Players.LocalPlayer
        end
        local hasGunCursor = self._Player:GetMouse().Icon:match("Gun")
        local hover = not hasGunCursor and self:_isMouseWithinGuiElement(gui.SquareMain)-- mloc.X>=left and mloc.X<=right and mloc.Y>=top and mloc.Y<=bottom

        local killClrMod = 0
        local txtClr = Color3.fromRGB(unpack(conf.TextRGB or {0,255,255}))
        local brdClr = Color3.fromRGB(unpack(conf.BorderRGB or {0,88,88}))
        local bckClr = Color3.fromRGB(unpack(conf.BackgroundRGB or {0,36,36}))
        local fadeFactor = conf.InactiveFadeFactor or 1
        local txtTrns = hover and 1 or self._Kill_Meh and 0.85 * fadeFactor or 0.55 * fadeFactor 
        local brdTrns = hover and 1 or self._Kill_Meh and 0.85 * fadeFactor or 0.65 * fadeFactor 
        local bckTrns = hover and 0.55 or self._Kill_Meh and 0.45 * fadeFactor or 0.15 * fadeFactor
        if self._Kill_Meh and self._killTmStart then
            killClrMod = math.clamp((tick() - self._killTmStart)/3,0,1)
            local v3 = Vector3.new(255,255,0):Lerp(Vector3.new(255,64,0),killClrMod)
            txtClr = Color3.fromRGB(v3.X,v3.Y,v3.Z)
            v3 = Vector3.new(88,88,0):Lerp(Vector3.new(88,22,0),killClrMod)
            brdClr = Color3.fromRGB(v3.X,v3.Y,v3.Z)
            v3 = Vector3.new(36,36,0):Lerp(Vector3.new(36,9,0),killClrMod)
            bckClr = Color3.fromRGB(v3.X,v3.Y,v3.Z)
        end

        local tm = gui.TextMain
        if tm then
            tm.Text = mainTxt
            tm.Position = Vector2.new(left+5,top+txtsz+10)
            tm.Visible = true--self._showGui
            tm.Transparency = txtTrns
            tm.Color = txtClr
        end
        local sm = gui.SquareMain
        if sm then
            sm.Size = Vector2.new(width,height)
            sm.Position = Vector2.new(left,top)
            sm.Visible = true--self._showGui
            sm.Transparency = bckTrns
            sm.Color = bckClr
        end
        local qm = gui.QuadMain
        if qm then
            qm.PointA = Vector2.new(right,top)
            qm.PointB = Vector2.new(left,top)
            qm.PointC = Vector2.new(left,bottom)
            qm.PointD = Vector2.new(right,bottom)
            qm.Visible = true--self._showGui
            qm.Transparency = brdTrns
            qm.Color = brdClr
        end

        local tt = gui.TitleText
        if tt then
            --local sz = TextService:GetTextSize(tt.Text,txtsz,Enum.Font.Code,Vector2.new(width,txtsz))
            --tt.Position = Vector2.new(left + width/2 - sz.X/2,top+3)
            tt.Position = Vector2.new(left + width/2,top+3)
            tt.Visible = true--self._showGui
            tt.Transparency = txtTrns
            tt.Color = txtClr
        end
        local tl = gui.TitleLine
        if tl then
            local y = top+txtsz+6
            tl.From = Vector2.new(left+1,y)
            tl.To = Vector2.new(right-1,y)
            tl.Visible = true--self._showGui
            tl.Transparency = brdTrns
            tl.Color = brdClr
        end

        local ft = gui.FooterText
        if ft then
            --local sz = TextService:GetTextSize(ft.Text,txtsz,Enum.Font.Code,Vector2.new(width,txtsz))
            --ft.Position = Vector2.new(left + width/2 - sz.X/2,bottom-txtsz-3)
            ft.Position = Vector2.new(left+width/2,bottom-txtsz-3)
            ft.Visible = true--self._showGui
            ft.Transparency = txtTrns
            ft.Color = txtClr
            ft.Text = self._Kill_Meh and "~~~ KILLING SCRIPT -BYE! ~~~" or ("~~~ [%s] Script Kill ~~~"):format(settings.KillScriptKey)
        end
        local fl = gui.FooterLine
        if fl then
            local y = bottom - txtsz - 6
            fl.From = Vector2.new(left+1,y)
            fl.To = Vector2.new(right-1,y)
            fl.Visible = true--self._showGui
            fl.Transparency = brdTrns
            fl.Color = brdClr
        end

        local sht = gui.ShowHideTri
        local shtb = gui.ShowHideTriBrd
        local hovsh = false
        if sht and shtb then
            local x = self._showGui and left+8 or trk.Current==0 and math.min(srn_w-8,left+8) or left+8+txtsz
            local y = top+5
            sht.PointA = Vector2.new(x,y)
            sht.PointB = Vector2.new(x,y+txtsz-3)
            sht.PointC = Vector2.new(x + (self._showGui and txtsz or -txtsz),y+(txtsz-3)/2)
            shtb.PointA = sht.PointA
            shtb.PointB = sht.PointB
            shtb.PointC = sht.PointC
            sht.Visible = true
            shtb.Visible = true
            if not hasGunCursor and (hover or not self._showGui) then
                hovsh = self:_isMouseWithinGuiElement(sht)-- self._showGui and mloc.X>=x and mloc.X<=sht.PointC.X and mloc.Y>=top and mloc.Y<=sht.PointB.Y or not self._showGui and mloc.X<=x and mloc.X>=sht.PointC.X and mloc.Y>=top and mloc.Y<=sht.PointB.Y
            end
            sht.Transparency = brdTrns
            shtb.Transparency = brdTrns
            sht.Color = hovsh and txtClr or hover and Color3.new(brdClr.R*1.65,brdClr.G*1.65,brdClr.B*1.65) or brdClr
            if hovsh and self._clicked then
                self._clicked = false
                self:ToggleGUI()
            end
        end

        local ct,ctb,csk,cskb = gui.CursorTri,gui.CursorTriBrd,gui.CursorStk,gui.CursorStkBrd
        if ct and ctb and csk and cskb then
            ct.Visible = not hasGunCursor and (hover or hovsh)
            ctb.Visible = not hasGunCursor and (hover or hovsh)
            ct.PointA = Vector2.new(mloc.X,mloc.Y)
            ctb.PointA = ct.PointA
            ct.PointB = Vector2.new(mloc.X,mloc.Y+18)
            ctb.PointB = ct.PointB
            ct.PointC = Vector2.new(mloc.X+12,mloc.Y+12)
            ctb.PointC = ct.PointC
            csk.Visible = not hasGunCursor and (hover or hovsh)
            csk.PointA = Vector2.new(mloc.X+7,mloc.Y+15.5)
            cskb.PointA = csk.PointA
            csk.PointB = Vector2.new(mloc.X+5,mloc.Y+16.5)
            cskb.PointB = csk.PointB
            csk.PointC = Vector2.new(mloc.X+6.5,mloc.Y+19.75)
            cskb.PointC = csk.PointC
            csk.PointD = Vector2.new(mloc.X+8.5,mloc.Y+18.75)
            cskb.PointD = csk.PointD
        end

        self._debugData = self._debugData or {}
        self._debugData.GuiTrk = nil--self._showGui_Track

        self:_updateNotifyGui()
        self:_updateInfoUI()
        self:_updateDebugUI()
    end
end
function util:_updateNotifyGui()
    
    local tmtk = tick()
    local conf = settings.NotifyGUI or {}
    local sz = conf.TextSize or 27
    local maxTm = conf.DisplayTime or 3
    local lns = self._Kill_Meh and ((conf.ShowLines or 6)+4) or conf.ShowLines or 6
    if self._notifies then
        local removing = true
        while removing do
            local removed = false
            for i,v in pairs(self._notifies) do
                local dur = tmtk - (v and v.tm or 0)
                if dur > maxTm then
                    table.remove(self._notifies,i)
                    if v and v.gui then
                        v.gui.Visible = false
                        pcall(function() v.gui:Remove() end)
                        v.gui = nil
                    end
                    removed = true
                    break
                else
                    v.dur = math.clamp(dur,0,maxTm)
                end
            end
            if not removed then removing = false end
        end
        local oclr = Color3.fromRGB(unpack(conf.TextOutlineRGB or {0,0,0}))
        local scrn_w = workspace.CurrentCamera.ViewportSize.X
        local posX = scrn_w*0.38--scrn_w / 2 - scrn_w*0.22
        local posY = sz*lns
        for i,v in pairs(self._notifies) do
            if not v.gui then
                v.gui = self:_draw("Text", {
                    Size = sz,
                    Outline = true,
                    OutlineColor = oclr,
                    Color = self:_getLogColor(v.logtype),
                    Text = v.msg,
                    Visible = true,
                    Font = 3
                })
            end
            v.gui.Transparency = v.dur<maxTm*0.85 and 1 or math.clamp(maxTm*0.85-v.dur*0.85,0,1)
            v.gui.Position = Vector2.new(posX,posY-(i*sz))
        end
    end
end
function util:_updateInfoUI()
    local me = self
    me._infoGui = me._infoGui or {}
    local info = me._infoGui
    local basePos = Vector2.new(100,workspace.CurrentCamera.ViewportSize.Y*0.65)
    local accumHt = 0
    local removing = true
    local tmtk = tick()
    while removing do
        local removed = false
        for i,v in pairs(info) do
            if v.RemoveAt and v.RemoveAt<tmtk then
                if v and v.gui then
                    v.gui.Visible = false
                    pcall(function() v.gui:Remove() end)
                    v.gui = nil
                end
                info[i] = nil
                removed = true
                break
            end
        end
        if not removed then removing = false end
    end
    for i,v in pairs(info) do
        if not v.Visible then
            if v.gui then v.gui.Visible = false end
            continue
        end
        if not v.gui then
            v.gui = me:_draw("Text", {
                Size = v.Size or 36,
                Outline = v.Outline==nil and true or v.Outline,
                OutlineColor = v.OutlineColor or Color3.new(0,0,0),
                Color = v.Color or Color3.new(1, 0.6, 0),
                Font = v.Font or 3
            })
        end
        v.gui.Text = v.getText and v.getText(v) or v.Text
        v.gui.Color = v.getColor and v.getColor(v) or v.Color or Color3.new(1, 0.6, 0)
        if v.RemoveAt and v.AppendTimeLeft then
            v.gui.Text = v.gui.Text.." "..(tostring(v.RemoveAt-tmtk):sub(1,3))
        end
        v.gui.Visible = v.Visible
        accumHt = accumHt+v.gui.Size
        v.gui.Position = Vector2.new(basePos.X,basePos.Y-accumHt)
    end
end
function util:_addUpdateInfoElement(name,values)
    local me = self
    me._infoGui = me._infoGui or {}
    local info = me._infoGui
    info[name] = info[name] or {}
    for i,v in pairs(values) do
        info[name][i] = v
    end
end
function util:_updateDebugUI()
    if not settings.EnableDebug or not self._debugUI then return end
    local me = self
    local dbg = me._debugUI

    local width,height = workspace.CurrentCamera.ViewportSize.X,workspace.CurrentCamera.ViewportSize.Y
    local dbt = dbg.DebugText
    if dbt then
        local txt
        if me._debugData then
            for i,v in pairs(me._debugData) do
                if v==nil then continue end
                txt = (txt or "").."["..tostring(i).."]: "..tostring(v).."\n"
                if type(v)=="table" then
                    for i2,v2 in pairs(v) do
                        txt = txt.." -- ".."["..tostring(i2).."]: "
                        if v2 and type(v2)=="table" then
                            local v2txt
                            for i3,v3 in pairs(v2) do
                                v2txt = (v2txt and v2txt.." | " or "").."["..tostring(i3).."]: "..(v3 and tostring(v3) or "nil")
                            end
                            txt = txt..(v2txt or "empty").."\n"
                        else
                            txt = txt..(v2 and tostring(v2) or "nil").."\n"
                        end
                    end
                end
            end
        end
        dbt.Visible = txt and #txt>0 or false
        dbt.Text = txt or ""
        dbt.Position = Vector2.new(width/2-dbt.TextBounds.X/2,height/2-dbt.TextBounds.Y/2)
    end
end
function util:setupGui(startOpen)
    local me = self
    me._gui = me._gui or {}
    local gui = me._gui
    me:teardownGuiElements(gui)
    
    --[[
    me._loadConfStatus = nil
    me._saveConfStatus = nil
    me._resetDefStatus = nil
    ]]

    local conf = settings.MainGUI or {}

    if not conf.Enabled then 
        me:_pcon("Gui Disabled")
        return
    end

    local txtsz = conf.TextSize or 18
    local txtoclr = conf.TextOutlineRGB or {0,0,0}
    local txtclr = conf.TextRGB or {0,255,255}
    local brdclr = conf.BorderRGB or {0,88,88}
    local bckclr = conf.BackgroundRGB or {0,36,36}

    local mainTxt = me:_getGuiText()
    --local lns = mainTxt:split('\n')

    gui.TextMain  = me:_draw("Text", {
        Size = txtsz,
        Outline = true,
        OutlineColor = Color3.fromRGB(unpack(txtoclr)),
        Color = Color3.fromRGB(unpack(txtclr)),
        Text = mainTxt,
        Font = 3,
        ZIndex = 3
    })

    gui.SquareMain = me:_draw("Square",{
        Size = Vector2.new(100,100),
        Color = Color3.fromRGB(unpack(bckclr)),
        Thickness = 1,
        Filled = true,
        ZIndex = 1
    })

    gui.QuadMain = me:_draw("Quad",{
        Color = Color3.fromRGB(unpack(brdclr)),
        Thickness = 3,
        Filled = false,
        ZIndex = 2
    })

    gui.TitleLine = me:_draw("Line",{
        Color = Color3.fromRGB(unpack(brdclr)),
        Thickness = 2,
        ZIndex = 2
    })
    gui.TitleText = me:_draw("Text",{
        Size = txtsz,
        Center = true,
        Outline = true,
        OutlineColor = Color3.fromRGB(unpack(txtoclr)),
        Color = Color3.fromRGB(unpack(txtclr)),
        Text = settings:GetGuiTitle(),
        Font = 3,
        ZIndex = 3
    })

    gui.FooterLine = me:_draw("Line",{
        Color = Color3.fromRGB(unpack(brdclr)),
        Thickness = 2,
        ZIndex = 2
    })
    gui.FooterText = me:_draw("Text",{
        Size = txtsz,
        Center = true,
        Outline = true,
        OutlineColor = Color3.fromRGB(unpack(txtoclr)),
        Color = Color3.fromRGB(unpack(txtclr)),
        Text = me._Kill_Meh and "~~~ KILLING SCRIPT -BYE! ~~~" or ("~~~ [%s] Script Kill ~~~"):format(settings.KillScriptKey),
        Font = 3,
        ZIndex = 3
    })

    gui.ShowHideTri = me:_draw("Triangle",{
        Color = Color3.fromRGB(unpack(txtclr)),
        Filled = true,
        Thickness = 1,
        ZIndex = 4
    })
    gui.ShowHideTriBrd = me:_draw("Triangle",{
        Color = Color3.fromRGB(unpack(txtoclr)),
        Filled = false,
        Thickness = 1,
        ZIndex = 4
    })
    
    gui.CursorStk = me:_draw("Quad",{
        Color = Color3.new(1,1,1),
        Filled = true,
        Thickness = 1,
        ZIndex = 9
    })
    gui.CursorStkBrd = me:_draw("Quad",{
        Color = Color3.new(0,0,0),
        Filled = false,
        Thickness = 1,
        ZIndex = 9
    })
    gui.CursorTri = me:_draw("Triangle",{
        Color = Color3.new(1,1,1),
        Filled = true,
        Thickness = 1,
        ZIndex = 9
    })
    gui.CursorTriBrd = me:_draw("Triangle",{
        Color = Color3.new(0,0,0),
        Filled = false,
        Thickness = 1,
        ZIndex = 9
    })
    

    if startOpen and not me._showGui then
        me:ToggleGUI()
    end

    me:_pcon("Gui Created")

    me:setupDebugUI()
end
function util:setupDebugUI()
    local me = self
    me._debugUI = me._debugUI or {}
    local dbg = me._debugUI
    me:teardownGuiElements(dbg)

    if not settings.EnableDebug then return end

    dbg.DebugText = me:_draw("Text",{
        Outline = true,
        OutlineColor = Color3.new(0,0,0),
        Color = Color3.new(1,1,1),
        Font = 3,
        Size = 27,
        --Center = true
    })
end
function util:teardownGuiElements(gui)
    if gui then
        for i,v in pairs(gui) do
            pcall(function() v.Visible = false end)
            pcall(function() v:Remove() end)
            pcall(function() gui[i] = nil end)
        end
    end
end
function util:ToggleGUI()
	local me = self
	me._showGui = not me._showGui
    local gspd = settings.GuiOpenSpeed
	me._showGui_Track = me._showGui_Track or {Show=me._showGui,Current=0,Start=0,Base=gspd,Time=0}
	local trk = me._showGui_Track
	trk.Show = me._showGui
	trk.Start = trk.Current
	if me._showGui then
		trk.Base = gspd-trk.Current*gspd
	else
		trk.Base = gspd-(1-trk.Current)*gspd
	end
	trk.Time = tick()+trk.Base
end
------
end -- GUI
------

------
do ---  Input 
------
function util:setupInput()
	local me = self
	if (me._InputBeganEvent) then
		pcall(function() me._InputBeganEvent:Disconnect() end)
		pcall(function() me._InputBeganEvent = nil end)
	end
	me._InputBeganEvent = UserInputService.InputBegan:Connect(function(inputObj, GPE)
		if not GPE and not me._Kill_Meh and not me._Rejoining then
			local ctrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
			local alt = UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)
            if not ctrl and not alt then
                if inputObj.UserInputType == Enum.UserInputType.MouseButton1 then
                    me._clicked = true
                end
                if inputObj.KeyCode == me:_getKeycode(settings.ToggleGui) then
                    me:ToggleGUI()
                elseif inputObj.KeyCode == me:_getKeycode(settings.KillScriptKey) then
                    me:shutdown()
                else
                    for i,v in pairs(settings.Toggles) do
                        if v and v.Key and v.GetText and v.Callback and 
                           typeof(v.GetText)=="function" and typeof(v.Callback)=="function" then
                            if inputObj.KeyCode == v.Key then
                                v:Callback()
                                break
                            end
                        end
                    end
                end
            end

            me:_updateGui()
		end
	end)
	if (me._InputEndedEvent) then
		pcall(function() me._InputEndedEvent:Disconnect() end)
		pcall(function() me._InputEndedEvent = nil end)
	end
	me._InputEndedEvent = UserInputService.InputEnded:Connect(function(inputObj, GPE)
		if not GPE and inputObj.UserInputType == Enum.UserInputType.MouseButton1 then
			me._clicked = false
		end
	end)
	me:_pcon("UTIL - Inputs connected")
end
------
end --  Input
------

------
do ---  Shutdown
------
function util:shutdown()
    local me = self
    me._killTmStart = tick()
	me._Kill_Meh = true
    local shutdownMsg = settings.GetGuiTitle().." - SHUTDOWN STARTED"
	me:_notify(shutdownMsg,me.LogType.Warn)
    if (me._InputEndedEvent) then
		pcall(function() me._InputEndedEvent:Disconnect() end)
		pcall(function() me._InputEndedEvent = nil end)
	end
    if (me._InputBeganEvent) then
		pcall(function() me._InputBeganEvent:Disconnect() end)
		pcall(function() me._InputBeganEvent = nil end)
	end
    -- give time for loops to see the kill flag
	task.wait(0.75)
    -- viewport
	if me._ViewportChangeEvent then
		pcall(function() me._ViewportChangeEvent:Disconnect() end)
		me._ViewportChangeEvent = nil
		me:_pcon("UTIL - Shutdown - Viewport - ChangedEvent Disconnected")
	end

    me:_notify("Shutting down GUI",me.LogType.Warn)

	-- give time for notifies 
	if tick()-me._killTmStart<3 then task.wait(3-(tick()-me._killTmStart)) end

	-- final teardown- the gui and render loop
	if me._RenderEvent then
		pcall(function() me._RenderEvent:Disconnect() end)
		pcall(function() me._RenderEvent = nil end)
		me:_pcon("UTIL - Shutdown - Render - Event Disconnected")
	end

    if me._debugUI then
		me:teardownGuiElements(me._debugUI)
		me._debugUI = nil
	end
	if me._gui then
		me:teardownGuiElements(me._gui)
		me._gui = nil
		me:_pcon("UTIL - Shutdown - Main UI - Removed")
	end
	if me._infoGui then
		for i,v in pairs(me._infoGui) do
			if not v.gui then continue end
			v.gui.Visible = false
			pcall(function() v.gui:Remove() end)
			me._infoGui[i] = nil
		end
		me:_pcon("UTIL - Shutdown - Info UI - Removed")
	end
	if me._notifies then
		for i,v in pairs(me._notifies) do
			v.gui.Visible = false
			pcall(function() v.gui:Remove() end)
			me._notifies[i] = nil
		end
		me:_pcon("UTIL - Shutdown - Notifications - Removed")
	end

    task.wait(0.75)
    me:_stopScheduler()

    if rconsoleclose and settings.PreferRobloxConsolePrints then
		coroutine.wrap(function() 
			task.wait(5)
			rconsoleclose()
		end)()
	end
end
------
end --  Shutdown
------
end

function init(newSettings,services)
    if not game or not game:IsLoaded() then
        init_error("Game not loaded yet!",true)
    else
        RunService = (services and services["RunService"]) or game:FindService("RunService")
        Players = (services and services["Players"]) or game:FindService("Players")
        UserInputService = (services and services["UserInputService"]) or game:FindService("UserInputService")
        TextService = (services and services["TextService"]) or game:FindService("TextService")
    end
    applySettings(newSettings)
    _rconsoleclear()
    _rconsolecreate()
    _rconsolename(settings:GetGuiTitle())
    if util.stop_init then
        for i,v in pairs(util.errors) do
            _rconsoleerr(v)
        end
    else
        addFunctions()
        util:setupGui(settings.ShowGui)
        if util._RenderEvent then
            pcall(function() util._RenderEvent:Disconnect() end)
            pcall(function() util._RenderEvent = nil end)
            util:_pcon("UTIL - Existing render event disconnected")
        end
        util._RenderEvent = RunService.RenderStepped:Connect(function()
            util:_updateGui()
        end)
        util:_pcon("UTIL - Render event loop running")

        util:_startScheduler()
        util:_pcon("UTIL - Scheduler Started")

        if util._ViewportChangeEvent then
            pcall(function() util._ViewportChangeEvent:Disconnect() end)
            util._ViewportChangeEvent = nil
            util:_pcon("UTIL - Existing ViewportChangedEvent disconnected")
        end
        util._ViewportChangeEvent = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            if not util._Kill_Meh then
                util:_updateGui()
            else
                pcall(function() util._ViewportChangeEvent:Disconnect() end)
            end
        end)
        util:_pcon("UTIL - ViewportChangedEvent connected")

        util:setupInput()

        util:_pcon("==== UTIL - Init Complete ====")
        util._init = true

        util:_notify("UTIL is Ready For Use!",util.LogType.Success)
    end
    return util
end

return init