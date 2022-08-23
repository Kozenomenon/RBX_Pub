--[[
    version 1.1.10
]]
local version = "1.1.10"
local RunService,Players,ContextActionService

local function makeTable(t)
    local _t = (t and type(t)=="table" and t) or {}
    setmetatable(_t,{})
    return _t
end
-- will be returned at end
local util = makeTable({
    shutdownBegin = Instance.new("BindableEvent"),  -- when Fly Util shutdown starts, cannot call util funcs until done
    shutdownEnd = Instance.new("BindableEvent"),    -- when Fly Util shutdown is finished, can now call util funcs
    initBegin = Instance.new("BindableEvent"),      -- Fly Util starts initialization, cannot call util funcs until done
    initEnd = Instance.new("BindableEvent"),        -- Fly Util init has finished, can now call util funcs
    onFly = Instance.new("BindableEvent"),          -- when Flying is about to be turned on, Tool.Equipped was triggered
    onUnFly = Instance.new("BindableEvent"),        -- when Flying is about to be turned off, Tool.Unequipped (or Tool.Equipped again) was triggered
    onFire = Instance.new("BindableEvent"),         -- when Tool.Activated is triggered
    errors = makeTable()
})
-- internal locals
local LocalPlayer,Backpack,ControlModule,Character,Humanoid,BodyGyro,BodyVelocity,HumanoidRootPart,Animate,CurrentCamera,IdleAnim,MoveAnim,FlyBarGui,Bar
local internal,_sched,_p,_init,_events,_threads = makeTable(),makeTable(),makeTable(),makeTable(),makeTable(),makeTable()

local MoveActions,flySettings = {},{}

local barSize,equippedToggle,unequippedTime,flyAmountLeft,flyTool,running,flyEnabled,jumpState,flyToolParent

--------
do ----- 
--------

--------
end ----
--------

--------
do ----- Internal schedule / async tasks
--------
local _scheduled,_scheduledMax,_scheduleMinToProcess,_scheduleMaxToProcess,_schedulerRunning,_schedulerEvent,_schedulerEventFunc,_removeSchedulerEvent
--- schedules the provided function (and calls it with any args after)
function _sched:add(f, ...)
    if not _sched:running() then return end
    table.insert(_scheduled, {f, ...})
    return #_scheduled
end
--- yields the current thread until the scheduler gives the ok
function _sched:wait()
    if not _sched:running() then return end
    local thread = coroutine.running()
    _sched:add(function()
        coroutine.resume(thread)
    end)
    coroutine.yield()
end
function _sched:running()
    if _schedulerRunning then
        if not _scheduled or not _schedulerEvent or not _schedulerEventFunc or not _removeSchedulerEvent then
            _sched:start()
        end
        return true
    else
        if _schedulerEvent then
            _sched:stop()
        end
        return false
    end
end
function _sched:start()
    if _removeSchedulerEvent and type(_removeSchedulerEvent)=="function" then _removeSchedulerEvent() end
    if _scheduled and type(_scheduled)=="table" then table.clear(_scheduled) end
    _scheduled = nil
    _scheduled = makeTable()
    _scheduledMax = 1000
    _scheduleMinToProcess = 8
    _scheduleMaxToProcess = 15
    _schedulerRunning = false
    _schedulerEvent = nil
    _schedulerEventFunc = nil
    _schedulerEventFunc = function(deltaTimeOrDoAll)
        if not _sched:running() then return end
        local doAll = deltaTimeOrDoAll and type(deltaTimeOrDoAll)=="boolean"
        if not doAll and #_scheduled > _scheduledMax then
            table.remove(_scheduled, #_scheduled)
        end
        local cnt = 0
        local min = type(_scheduleMinToProcess)=="number" and _scheduleMinToProcess or 8
        local max = type(_scheduleMaxToProcess)=="number" and _scheduleMaxToProcess or 15
        while #_scheduled>0 and doAll or cnt<math.random(min,max) do
            if not _schedulerRunning then
                break
            end
            cnt=cnt+1
            local currentf = _scheduled[1]
            table.remove(_scheduled, 1)
            if type(currentf) == "table" and type(currentf[1]) == "function" then
                pcall(unpack(currentf))
            end
        end
    end
    _removeSchedulerEvent = nil
    _removeSchedulerEvent = function()
        local removed
        if _schedulerEvent then
            local succ_rem,err_rem = pcall(function() _schedulerEvent:Disconnect();return; end)
            removed = succ_rem
        end
        if not removed and RunService then
            local hbConns = getconnections(RunService.Heartbeat)
            for i,v in pairs(hbConns) do
                if v and v.Function == _schedulerEventFunc then
                    _p:warn("scheduler - found connection when should have disconnected already!")
                    local succ_rem,err_rem = pcall(function() v:Disconnect();return; end)
                    if not succ_rem then
                        pcall(function() v:Disable();return; end)
                    end
                    break
                end
            end
        end
        _schedulerEvent = nil
    end
    _schedulerEvent = RunService.Heartbeat:Connect(_schedulerEventFunc)
    _schedulerRunning = true
    _p:debug("scheduler - started")
end
function _sched:stop(complete)
    if _removeSchedulerEvent and type(_removeSchedulerEvent)=="function" then _removeSchedulerEvent() end
    if complete and _schedulerEventFunc and type(_schedulerEventFunc)=="function" then
        _schedulerEventFunc(true)
    end
    if _scheduled and type(_scheduled)=="table" then table.clear(_scheduled) end
    _scheduled = nil
    _scheduledMax = nil
    _scheduleMinToProcess = nil
    _scheduleMaxToProcess = nil
    _schedulerRunning = nil
    _schedulerEvent = nil
    _schedulerEventFunc = nil
    _removeSchedulerEvent = nil
    _p:debug("scheduler - stopped. completed=",complete)
end
--------
end ---- Internal schedule / async tasks
--------

--------
do ----- Thread Loop Control
--------
local __threads,__maxWait,__runThreadFunc,__killThread,__threadsRunning
function _threads:running()
    if __threadsRunning then
        if  not __threads or type(__threads)~="table" or
            not __maxWait or type(__maxWait)~="number" or
            not __runThreadFunc or type(__runThreadFunc)~="function" or
            not __killThread or type(__killThread)~="function" then
            _threads:start(true)
        end
        return true
    else
        if __threads or __maxWait or __runThreadFunc or __killThread then
            _threads:stop(true)
        end
        return false
    end
end
function _threads:add(name,interval,func,await)
    local me = self
    local function __t_add()
        if not name or type(name)~="string" or #name==0 then return end
        if not func or type(func)~="function" then return end
        if not me:running() then return end
        local cadence = (interval and type(interval)=="number" and interval>0 and interval) or 0.1
        _p:info("ThreadAdd - Begin. Name=",name," | Interval=",cadence," | Func=",func)
        local th = __threads[name]
        local co = th and th.co
        local state = (co and coroutine.status(co)) or "nil"
        if co and state~="dead" then
            _p:warn("ThreadAdd - !Existing! Name=",name,"| Thread=",(co and tostring(co) or "nil")," | Status=",state,
                                            " | runs=",(th and th.cnt~=nil and tostring(th.cnt) or "nil"),
                                            " | Interval=",(th and th.interval~=nil and tostring(th.interval) or "nil"),
                                            " | Func=",(th and th.func and tostring(th.func) or "nil"))
            __killThread(name,th)
        end
        th = th or makeTable()
        __threads[name] = th
        th.kill = false
        th.interval = cadence
        th.func = func
        th.cnt = 0
        th.co = coroutine.create(__runThreadFunc)
        coroutine.resume(th.co,name)
        _p:info("ThreadAdd - Success. Name=",name," | Interval=",th.interval," | Func=",th.func," | Thread=",th.co," | Status=",coroutine.status(th.co))
    end
    if await then
        __t_add()
    else
        coroutine.wrap(__t_add)()
    end
end
function _threads:remove(name,await)
    local function  __t_remove()
        if not name or type(name)~="string" or #name==0 then return end
        if not __threads or type(__threads)~="table" then return end
        local th = __threads[name]
        if th then
            local co = th and th.co
            local state = (co and coroutine.status(co)) or "nil"
            _p:info("ThreadRemove - Begin. Name=",name,"| Thread=",(co and tostring(co) or "nil"),
                                                      " | Status=",state,
                                                      " | runs=",(th and th.cnt~=nil and tostring(th.cnt) or "nil"),
                                                      " | Interval=",(th and th.interval~=nil and tostring(th.interval) or "nil"),
                                                      " | Func=",(th and th.func and tostring(th.func) or "nil"))
            if co and state~="dead" then
                __killThread(name,th)
                state = (co and coroutine.status(co)) or "nil"
            end
            _p:info("ThreadRemove - End. Name=",name,"| Thread=",(co and tostring(co) or "nil"),
                                                    " | Status=",state,
                                                    " | runs=",(th and th.cnt~=nil and tostring(th.cnt) or "nil"),
                                                    " | Interval=",(th and th.interval~=nil and tostring(th.interval) or "nil"),
                                                    " | Func=",(th and th.func and tostring(th.func) or "nil"))
            th = nil
            __threads[name] = nil
        else
            _p:info("ThreadRemove - Not Found. Name=",name)
        end
    end
    if await then
        __t_remove()
    else
        coroutine.wrap(__t_remove)()
    end
end
function _threads:start(await)
    local me = self
    me:stop(await)
    __threads = makeTable()
    __maxWait = 2
    __runThreadFunc = nil
    __killThread = nil
    __threadsRunning = false
    __runThreadFunc = function(nm)
        if not me:running() then return end
        task.wait()
        local th = __threads[nm]
        _p:debug("Thread Begin - Name=",nm," | runs=",(th and th.cnt~=nil and tostring(th.cnt) or "nil"),
                                           " | Interval=",(th and th.interval~=nil and tostring(th.interval) or "nil"),
                                           " | Func=",(th and th.func and tostring(th.func) or "nil"),
                                           " | Thread=",(th and th.co and tostring(th.co) or "nil"))
        if th then th.cnt = 0 end
        while th and not th.kill and th.func and task.wait(th.interval) do
            th = __threads[nm]
            if th and not th.kill and th.func then
                th.func()
                th.cnt = th.cnt + 1
            end
        end
        _p:debug("Thread End - Name=",nm," | runs=",(th and th.cnt~=nil and tostring(th.cnt) or "nil"),
                                         " | Interval=",(th and th.interval~=nil and tostring(th.interval) or "nil"),
                                         " | Func=",(th and th.func and tostring(th.func) or "nil"),
                                         " | Thread=",(th and th.co and tostring(th.co) or "nil"))
    end
    __killThread = function(nm,th)
        if not nm or type(nm)~="string" or #nm==0 then return end
        if not th or type(th)~="table" then return end
        if not me:running() then return end
        th.kill = true
        local co = th and th.co
        if not co or type(co)~="thread" then return end
        local tm = tick()
        local maxWait = type(__maxWait)=="number" and __maxWait or 2
        while co and coroutine.status(co)~="dead" do
            local nowTm = tick()
            if nowTm-tm>maxWait then
                _p:warn("__killThread - !Killing! Name=",nm,"| Waited Time=",nowTm-tm," | Killing thread=",co)
                coroutine.close(co)
                _p:warn("__killThread - !Killed! Name=",nm,"| thread=",co," | status=",coroutine.status(co))
            end
            task.wait()
        end
        _p:debug("__killThread End. Name=",nm,"| Waited Time=",tick()-tm,"| thread=",(co and tostring(co) or "nil")," | status=",(co and coroutine.status(co) or "nil"))
    end
    __threadsRunning = true
end
function _threads:stop(await)
    local me = self
    local function __t_clear()
        if __threads and type(__threads)=="table" then
            _p:info("ThreadClear - Begin. Count=",#__threads)
            for i,v in pairs(__threads) do
                _p:debug("ThreadClear - Name=",i," | th=",v)
                me:remove(i,true)
            end
            table.clear(__threads)
            _p:info("ThreadClear - End. Count=",#__threads)
        end
        __threads = nil
        __maxWait = nil
        __runThreadFunc = nil
        __killThread = nil
        __threadsRunning = false
    end
    if await then
        __t_clear()
    else
        coroutine.wrap(__t_clear)()
    end
end
--------
end ---- Thread Loop Control
--------

--------
do ----- Print Output
--------
local _rconsoleprint,_prnt_nl,_prnt_pref,_prnt,_rconsoleclear,_rconsolecreate,_rconsolename,_rconsolewarn,_rconsoleerr,_rconsoleinfo
local _pColors = makeTable({
    ["WHITE"]=Color3.fromRGB(255,255,255),
    ["RED"]=Color3.fromRGB(255,0,0),
    ["GREEN"]=Color3.fromRGB(0,255,0),
    ["BLUE"]=Color3.fromRGB(0,0,255),
    ["BLACK"]=Color3.fromRGB(0,0,0),
    ["YELLOW"]=Color3.fromRGB(255,255,0),
    ["CYAN"]=Color3.fromRGB(0,255,255),
    ["MAGENTA"]=Color3.fromRGB(255,0,255)
})
------
do ---  print func setup (initial)
------
_rconsoleprint = rconsoleprint or KRNL_LOADED and rconsoleinfo or output or printoutput or printdebug or print
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
local function _trim(s)
    return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
end
local function _argsToPrintLine(...)
    local args = {...}
    local txt = ""
    for i,v in ipairs(args) do
        if #txt > 0 then
            txt = _trim(txt) .. " | "
        end
        txt = txt .. tostring(v)
    end
    return txt
end

local function _pcon(pargs,prefix,prefclr)
    prefix = prefix or ""
    if flySettings and flySettings.PrintUseExternalConsole and _prnt and type(_prnt)=="function" then
        if _sched:running() then
            _sched:add(_prnt,_argsToPrintLine(unpack(pargs)),prefix,prefclr)
        else
            _prnt(_argsToPrintLine(unpack(pargs)),prefix,prefclr)
        end
    --[[elseif printconsole then
        local s = _argsToPrintLine((#prefix>0 and (prefix..":: ")) or "",unpack(pargs))
        local c = _pColors[prefclr] or _pColors.WHITE
        local r,g,b = c.R*255,c.G*255,c.B*255

        if _sched:running() then
            _sched:add(printconsole,s,r,g,b)
        else
            printconsole(s,r,g,b)
        end]]
    else
        if _sched:running() then
            _sched:add(print,(#prefix>0 and (prefix..":: ")) or "",unpack(pargs))
        else
            print((#prefix>0 and (prefix..":: ")) or "",unpack(pargs))
        end
    end
end
function _p:error(...)
    if flySettings and flySettings.PrintError then
        _pcon({...},"FlyUtil::Error","RED")
    end
end
function _p:warn(...)
    if flySettings and flySettings.PrintWarn then
        _pcon({...},"FlyUtil::Warn","YELLOW")
    end
end
function _p:info(...)
    if flySettings and flySettings.PrintInfo then
        _pcon({...},"FlyUtil","WHITE")
    end
end
function _p:debug(...)
    if flySettings and flySettings.PrintDebug then
        _pcon({...},"FlyUtil::Debug","MAGENTA")
    end
end
function _p:clear()
    if flySettings and flySettings.PrintUseExternalConsole and _rconsoleclear and type(_rconsoleclear)=="function" then
        _rconsoleclear()
    end
end
-------
end ---- Print Output
--------

--------
do ----- Internal Init
--------
function _init:error(msg,stop)
    _p:error("init_error! stop? ",stop," msg=",msg)
    table.insert(util.errors,msg)
    util.stop_init = (stop and true) or util.stop_init
end

function _init:applySettings(newSettings)
    if newSettings and type(newSettings)=="table" then
        for i,v in pairs(newSettings) do
            local old = flySettings[i]
            if old~=v then
                flySettings[i] = v
                _p:debug("applySettings - ",i," - old=",old," | new=",v)
            end
        end
    end
end

function _init:loadResources(resources)
    if resources then
        if not IdleAnim then
            local tmpIdleAsset; tmpIdleAsset = resources["IdleAnim"]
            if tmpIdleAsset then
                IdleAnim = Humanoid:LoadAnimation(resources["IdleAnim"])
                _p:debug("loadResources - IdleAnim loaded.")
            else
                _p:debug("loadResources - No IdleAnim.")
            end
        end
        if not MoveAnim then
            local tmpMoveAsset; tmpMoveAsset = resources["MoveAnim"]
            if tmpMoveAsset then
                MoveAnim = Humanoid:LoadAnimation(resources["MoveAnim"])
                _p:debug("loadResources - MoveAnim loaded.")
            else
                _p:debug("loadResources - No MoveAnim.")
            end
        end
        if not FlyBarGui then
            local tmpFlyBar; tmpFlyBar = resources["FlyBarGui"]
            if tmpFlyBar and typeof(tmpFlyBar)=="Instance" and tmpFlyBar.ClassName=="ScreenGui" then
                local tmpBar = tmpFlyBar:WaitForChild("Bar")
                if tmpBar and typeof(tmpBar)=="Instance" and tmpBar.ClassName=="Frame" then
                    FlyBarGui = tmpFlyBar
                    Bar = tmpBar
                    barSize = Bar.Size
                    FlyBarGui.Parent = LocalPlayer.PlayerGui
                    FlyBarGui.Enabled = true
                    _p:debug("loadResources - FlyBarGui=",FlyBarGui," | Bar=",Bar," | barSize=",barSize)
                else
                    _p:debug("loadResources - Nil/Invalid Bar=",tmpBar)
                end
            else
                _p:debug("loadResources - Nil/Invalid FlyBarGui=",tmpFlyBar)
            end
        end
    end
end

function _init:validateParms(tool,settings,resources)
    if not game or not game:IsLoaded() then
        _init:error("Game not loaded yet!",true)
        return false
    else
        RunService = (resources and resources["RunService"]) or game:FindService("RunService")
        Players = (resources and resources["Players"]) or game:FindService("Players")
        ContextActionService = (resources and resources["ContextActionService"]) or game:FindService("ContextActionService")
    end
    if not(RunService and Players and ContextActionService) then
        _init:error("Services not available",true)
        return false
    end
    if not tool or typeof(tool)~="Instance" or not tool:IsA("Tool") then
        _init:error("Invalid or Nil Tool provided.",true)
        return false
    end
    return true
end

function _init:begin(toolParm,settingsParm,resourcesParm)

    LocalPlayer,Backpack,ControlModule,Character,Humanoid,BodyGyro,BodyVelocity,HumanoidRootPart,Animate,CurrentCamera,IdleAnim,MoveAnim,FlyBarGui,Bar = 
        nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
    MoveActions = nil
    flySettings = nil
    barSize,equippedToggle,unequippedTime,flyAmountLeft,flyTool,running,flyEnabled,jumpState,flyToolParent = 
        nil,nil,nil,nil,nil,nil,nil,nil,nil

    flySettings = makeTable({
        MaxFlyTime = 1200,
        FlySpeedMult = 2.5,
        FlyDrainAmount = 1,
        FlyRechargeAmount = 0.5,
        FlyRechargeDelay = 1,
        NoDisableAnimate = false,
        ToolRemainsEquipped = false,
        ToolUsesActivated = false,
        ToolActivatedCooldown = 0,
        HipHeightAdjustment = 0,
        NoPlatformStand = false,
    
        PrintUseExternalConsole = false,
        PrintError = false,
        PrintWarn = false,
        PrintInfo = false,
        PrintDebug = false
    })
    _init:applySettings(settingsParm)
    _p:info("init - Applied Settings. ")

    _p:info("init - Begin")

    if _init:validateParms(toolParm,settingsParm,resourcesParm) then
        _p:info("init - Initial Checks Passed")
    else
        _p:error("init - parm validation failure")
        return
    end

    local tool,resources
    tool = toolParm
    resources = resourcesParm
    
    _sched:start()
    _p:info("init - scheduler started")

    LocalPlayer = Players.LocalPlayer
    Backpack = LocalPlayer:WaitForChild("Backpack")
    _p:debug("init - Backpack=",Backpack)
    ControlModule = (resources and resources["ControlModule"]) or
        require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("ControlModule"));
    _p:debug("init - ControlModule=",ControlModule)
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
    _p:debug("init - Character=",Character," | Parent=",Character.Parent)
    while not Character.Parent do
        _p:debug("init - Character.Parent is nil, waiting on ancestry changed...")
        Character.AncestryChanged:Wait();
    end
    _p:debug("init - Character.Parent=",Character.Parent)
    Humanoid = Character:WaitForChild("Humanoid")
    _p:debug("init - Humanoid=",Humanoid)
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    _p:debug("init - HumanoidRootPart=",HumanoidRootPart)
    if flySettings.NoDisableAnimate then
        Animate = nil
    else
        Animate = Character:WaitForChild("Animate")
        _p:debug("init - Animate=",Animate)
    end
    CurrentCamera = workspace.CurrentCamera
    _p:debug("init - CurrentCamera=",CurrentCamera)
    if BodyGyro then
        _p:warn("init - BodyGyro was not nil >>> ",BodyGyro)
        pcall(function() BodyGyro.Parent=nil;BodyGyro:Destroy();return;end)
    end
    BodyGyro = Instance.new("BodyGyro");
    BodyGyro.maxTorque = Vector3.new(1, 1, 1) * 1000000;
    BodyGyro.P = 100000;
    _p:debug("init - BodyGyro=",BodyGyro)
    if BodyVelocity then
        _p:warn("init - BodyVelocity was not nil >>> ",BodyVelocity)
        pcall(function() BodyVelocity.Parent=nil;BodyVelocity:Destroy();return;end)
    end
    BodyVelocity = Instance.new("BodyVelocity");
    BodyVelocity.maxForce = Vector3.new(1, 1, 1) * 1000000;
    BodyVelocity.P = 10000;
    _p:debug("init - BodyVelocity=",BodyVelocity)

    _p:info("init - Main Instances Complete")

    _init:loadResources(resources)
    if not IdleAnim or not MoveAnim or not FlyBarGui or not Bar then
        local startTm = tick()
        _p:debug("init - waiting for resource load... StartTime=",startTm)
        while (not IdleAnim or not MoveAnim or not FlyBarGui or not Bar) and startTm>(tick()-5) do
            task.wait(0.1)
            _p:debug("init - Attempt loadResources. IdleAnim=",IdleAnim," | MoveAnim=",MoveAnim," | FlyBarGui=",FlyBarGui," | Bar=",Bar," | TimeLeft=",startTm-(tick()-5))
            _init:loadResources(resources)
        end
        _p:debug("init - loadResources success? ",(IdleAnim and MoveAnim and FlyBarGui and Bar)==true," | TimeTaken=",(tick()-startTm))
    end

    flyTool = tool
    flyToolParent = tool and tool.Parent
    if not flyToolParent then
        _p:warn("init - FlyTool has no Parent!")
    else
        _p:debug("init - FlyTool=",flyTool)
        _p:debug("init - FlyTool.Parent=",flyToolParent)
    end
    flyAmountLeft = flySettings.MaxFlyTime

    MoveActions = makeTable({
        forward = 0,
        backward = 0,
        right = 0,
        left = 0,
        up = 0
    })

    running = true
    flyEnabled = false;
    equippedToggle = false;
    unequippedTime = tick();
    jumpState = false;

    ContextActionService:BindAction("forward", internal.HandleMoveAction, false, Enum.PlayerActions.CharacterForward);
    ContextActionService:BindAction("backward", internal.HandleMoveAction, false, Enum.PlayerActions.CharacterBackward);
    ContextActionService:BindAction("left", internal.HandleMoveAction, false, Enum.PlayerActions.CharacterLeft);
    ContextActionService:BindAction("right", internal.HandleMoveAction, false, Enum.PlayerActions.CharacterRight);
    ContextActionService:BindAction("up", internal.HandleMoveAction, false, Enum.PlayerActions.CharacterJump);
    _p:debug("init - ContextActions Bound.")

    _threads:start(true)
    _threads:add("MoveActions",0.1,function()
        if not running then return end
        local moveVec = ControlModule and ControlModule:GetMoveVector() or Humanoid and Humanoid.MoveDirection or Vector3:new(0,0,0);
        MoveActions.forward = -moveVec.Z;
        MoveActions.right = moveVec.X;
    end)
    _p:debug("init - MoveActions Loop Started.")

    _events:clear()
    _events:add("CharacterRemovingEvent",LocalPlayer.CharacterRemoving,function()
        _p:debug("CharacterRemovingEvent - Begin")
        util:shutdown()
        _p:debug("CharacterRemovingEvent - End")
    end)
    _p:debug("init - Connected CharacterRemovingEvent")

    _events:add("ToolParentChangeEvent",flyTool:GetPropertyChangedSignal("Parent"),function()
        _p:debug("ToolParentChangeEvent - Old=",flyToolParent," | New=",flyTool.Parent)
        flyToolParent = flyTool.Parent
        if equippedToggle and flySettings.ToolRemainsEquipped and (not flyToolParent or flyToolParent~=Character) then
            equippedToggle = false;
            internal:UnFly();
            unequippedTime = tick();
        end
        --[[
        _p:debug("ToolParentChangeEvent - Begin")
        if not flyTool.Parent then
            if FlyBarGui then
                pcall(function()
                    --FlyBarGui:Destroy()
                    --_p:debug("ToolParentChangeEvent - FlyBarGui destroyed")
                    FlyBarGui.Enabled = false
                    _p:debug("ToolParentChangeEvent - FlyBarGui disabled")
                end)
            end
        end;
        _p:debug("ToolParentChangeEvent - End")
        ]]
    end)
    _p:debug("init - Connected ToolParentChangeEvent")

    local function removeConnections(signal,parent)
        local cnt = 0
        local otherToolConns = getconnections(signal)
        _p:debug("init - removeConnections signal=",signal," | parent=",parent," | Cnt=",#otherToolConns)
        for i, v in pairs(otherToolConns) do
            _p:debug("init - removeConnections::",i," | Function=",(v and v.Function))
            if v and v.Function then
                
                local func = v.Function
                local succ_fi,fi = pcall(function()
                    return debug.getinfo(func)
                end)
                if succ_fi then
                    if flySettings.PrintDebug then
                        _p:debug("init - removeConnections - got func info. Func=",func," | Cnt=",#fi)
                        for i2,v2 in pairs(fi) do
                            _p:debug(" --- FuncInfo::",i2,"=",v2," | type=",type(v2), " | typeof=",typeof(v2))
                        end
                    end
                else
                    _p:error("init - removeConnections - failed getting func info! Func=",func," | Error=",fi)
                end
                local succ_fEnv,fEnv = pcall(function() 
                    local tmpfEnv = getfenv(func);
                    _p:debug("init - removeConnections::",i," | script=",(tmpfEnv and tmpfEnv.script))
                    if tmpfEnv and tmpfEnv.script and tmpfEnv.script.Parent==parent then
                        sethiddenproperty(tmpfEnv.script,"Disabled",true)
                        _p:debug("init - removeConnections::",i," | Disabled script=",(tmpfEnv and tmpfEnv.script)," | parent=",(tmpfEnv and tmpfEnv.script and tmpfEnv.script.Parent))
                        cnt = cnt + 1
                    else
                        _p:debug("init - removeConnections::",i," | Ignoring script=",(tmpfEnv and tmpfEnv.script)," | parent=",(tmpfEnv and tmpfEnv.script and tmpfEnv.script.Parent))
                        tmpfEnv = nil
                    end
                    return tmpfEnv
                end)
                if not succ_fEnv then
                    _p:error("init - removeConnections - failed disabling other env! Func=",func," | Error=",fEnv)
                end
                if succ_fEnv and fEnv then
                    _p:debug("init - removeConnections - disabling connection. Func=",func," | source=",fi.source)
                    local succ_dis,err_dis = pcall(function()
                        v:Disable();
                        return
                    end)
                    if succ_dis then
                        _p:debug("init - removeConnections - disabled connection. Func=",func," | source=",fi.source)
                    else
                        _p:error("init - removeConnections - failed to disable! Func=",func," | Error=",err_dis)
                    end
                end
            end
        end
        return cnt
    end
    local equippedCnt = removeConnections(flyTool.Equipped,flyTool)
    local unequippedCnt = removeConnections(flyTool.Unequipped,flyTool)
    local activatedCnt = removeConnections(flyTool.Activated,flyTool)
    _p:debug("init - conns removed - Equipped=",equippedCnt," | Unequipped=",unequippedCnt," | Activated=",activatedCnt)
    if equippedCnt==0 then
        local toolScript = flyTool:FindFirstAncestorWhichIsA("LocalScript")
        if toolScript then
            _p:debug("init - removeConnections - alt method found tool script=",toolScript)
            sethiddenproperty(toolScript,"Disabled",true)
            _p:debug("init - removeConnections - Disabled script=",toolScript)
        else
            local toolChilds = flyTool:GetChildren()
            for i,v in pairs(toolChilds) do
                _p:debug("init - removeConnections - child::",i,"=",v," type=",type(v)," typeof=",typeof(v)," class=",(v["ClassName"] or "nil"))
                if v and typeof(v)=="Instance" and v.ClassName=="LocalScript" then
                    _p:debug("init - removeConnections - alt method2 found tool script=",v)
                    sethiddenproperty(v,"Disabled",true)
                    _p:debug("init - removeConnections - Disabled script=",v)
                end
            end
        end
    end
    _events:add("ToolEquippedEvent",flyTool.Equipped,flySettings.ToolRemainsEquipped and internal.ToolEquipped or internal.ToggleToolEquipped)
    _p:debug("init - Connected "..(flySettings.ToolRemainsEquipped and "internal.ToolEquipped" or "internal.ToggleToolEquipped"))
    if flySettings.ToolRemainsEquipped then
        _events:add("ToolUnequippedEvent",flyTool.Unequipped,internal.ToolUnequipped)
        _p:debug("init - Connected internal.ToolUnequipped")
    end
    if flySettings.ToolUsesActivated then
        _events:add("ToolActivatedEvent",flyTool.Activated,internal.ToolActivated)
        _p:debug("init - Connected internal.ToolActivated")
    end

    _threads:add("FlyLoop",0.1,function()
        if not running then return end
        if equippedToggle then
            flyAmountLeft = flyAmountLeft - flySettings.FlyDrainAmount;
        elseif tick() - unequippedTime > flySettings.FlyRechargeDelay then
            flyAmountLeft = flyAmountLeft + flySettings.FlyRechargeAmount;
        end;
        if flyAmountLeft > flySettings.MaxFlyTime then
            flyAmountLeft = flySettings.MaxFlyTime;
        elseif flyAmountLeft < 0 then
            flyAmountLeft = 0;
            equippedToggle = false;
            internal:UnFly();
            unequippedTime = tick();
            flyTool.Parent = Backpack;
        end;
        if Bar then
            Bar.Size = UDim2.new(flyAmountLeft / flySettings.MaxFlyTime * barSize.X.Scale, 0, barSize.Y.Scale, 0);
        end
    end)

    _p:info("init - End")
end
--------
end ---- Internal Init
--------

--------
do ----- Internal Events Mgmt
--------
local __events
function _events:remove(name)
    if not name or type(name)~="string" or #name==0 then
        return
    end
    __events = __events or makeTable()
    local ev=__events[name]
    if ev and typeof(ev)=="RBXScriptConnection" then
        local succ_ev,err_ev = pcall(function() ev:Disconnect();return; end)
        if succ_ev then
            _p:debug("RemoveEvent - Success. Name=",name)
        else
            _p:error("RemoveEvent - Failed! Name=",name," | Error=",err_ev)
        end
    end
    __events[name]=nil
end
function _events:add(name,signal,func)
    if not name or type(name)~="string" or #name==0 or not signal or typeof(signal)~="RBXScriptSignal" or not func or type(func)~="function" then
        return
    end
    __events = __events or makeTable()
    _events:remove(name)
    local succ_ev,err_ev = pcall(function() __events[name]=signal:Connect(func);return; end)
    if succ_ev then
        _p:debug("AddEvent - Success. Name=",name)
    else
        _p:error("AddEvent - Failed! Name=",name," | Error=",err_ev)
    end
end
function _events:clear()
    __events = __events or makeTable()
    for i,v in pairs(__events) do
        _events:remove(i)
    end
    table.clear(__events)
end
--------
end ---- Internal Events Mgmt
--------

--------
do ----- Internal Fly Mechanics
--------
function internal:ToggleFlyPhysics(toggle)
    _p:debug("ToggleFlyPhysics Begin - ",toggle)
	flyEnabled = toggle;
	if BodyGyro then
        BodyGyro.Parent = flyEnabled and HumanoidRootPart or nil;
        BodyGyro.CFrame = HumanoidRootPart.CFrame;
    end
    if BodyVelocity then
	    BodyVelocity.Parent = flyEnabled and HumanoidRootPart or nil;
	    BodyVelocity.Velocity = Vector3.new();
    end
    if Animate then
	    Animate.Disabled = flyEnabled;
    end
    _p:debug("ToggleFlyPhysics End - ",toggle)
end
function internal.HandleMoveAction(actionName, userInputState, inputObj)
	--task.wait();
	if userInputState == Enum.UserInputState.Begin then
		MoveActions[actionName] = 1;
        _p:debug("MoveAction Begin - ",actionName)
	elseif userInputState == Enum.UserInputState.End then
		MoveActions[actionName] = 0;
        _p:debug("MoveAction End - ",actionName)
	end;
	if flyEnabled then

	end;
	return Enum.ContextActionResult.Pass;
end
function internal.HumanoidStateChanged(oldState, newState)
    _p:debug("HumanoidStateChanged Old=",oldState," | New=",newState)
	if newState == Enum.HumanoidStateType.Landed then
		jumpState = false;
		return;
	end;
	if newState == Enum.HumanoidStateType.Jumping then
		jumpState = true;
	end;
end
function internal.FlyMoveMath()
	if flyEnabled then
		local cf = CurrentCamera.CFrame;
		local v13 = cf.rightVector * (MoveActions.right - MoveActions.left) + cf.lookVector * (MoveActions.forward - MoveActions.backward)
                    + cf.upVector * MoveActions.up
		if v13:Dot(v13) > 0 then
			v13 = v13.unit;
		end;
		BodyGyro.CFrame = cf;
		BodyVelocity.Velocity = v13 * Humanoid.WalkSpeed * flySettings.FlySpeedMult;
	end;
end
function internal:Fly()
    if flyEnabled then return end
    _p:debug("Fly Begin")
    util.onFly:Fire()
    if Humanoid then
		if Humanoid:GetState() == Enum.HumanoidStateType.Dead then
            _p:error("Fly - Dead! Cannot 'Fly'")
			return
        else
            if not flySettings.NoPlatformStand then
                Humanoid.PlatformStand = true
            end
            local hipAdj = flySettings.HipHeightAdjustment
            if hipAdj~=nil and type(hipAdj)=="number" then
                Humanoid.HipHeight = Humanoid.HipHeight + hipAdj
            end
		end
	else
        _p:error("Fly - No Humanoid!!! Cannot 'Fly'")
		return
	end
	if MoveAnim then
        local succ_play,err_play = pcall(function()
            MoveAnim:Play()
            _p:debug("Fly - MoveAnim played")
            return
        end)
        if not succ_play then
            _p:error("Fly - failed to play MoveAnim. Error=",err_play)
        end
    end
	internal:ToggleFlyPhysics(true);
    _events:add("HumanoidStateChanged",Humanoid.StateChanged,internal.HumanoidStateChanged)
    _events:add("RenderStepped_FlyMoveMath",RunService.RenderStepped,internal.FlyMoveMath)
    _p:debug("Fly End")
end
function internal:UnFly()
    if not flyEnabled then return end
    _p:debug("UnFly Begin")
    util.onUnFly:Fire()
	if MoveAnim then
        local succ_stop,err_stop = pcall(function()
            MoveAnim:Stop()
            _p:debug("UnFly - MoveAnim stopped")
            return
        end)
        if not succ_stop then
            _p:error("UnFly - Failed to stop MoveAnim! Error=",err_stop)
        end
    end
    if Humanoid then
        local hipAdj = flySettings.HipHeightAdjustment
        if hipAdj~=nil and type(hipAdj)=="number" then
            Humanoid.HipHeight = Humanoid.HipHeight - hipAdj
        end
        if not flySettings.NoPlatformStand then
            Humanoid.PlatformStand = false
        end
        task.delay(0.1, function()
            Humanoid:ChangeState(Enum.HumanoidStateType.Freefall);
            Humanoid:ChangeState(Enum.HumanoidStateType.Freefall);
            Humanoid:ChangeState(Enum.HumanoidStateType.Freefall);
            Humanoid:ChangeState(Enum.HumanoidStateType.Freefall);
            _p:debug("UnFly - Humanoid State Changed >>> ",Humanoid:GetState())
        end);
    end
	internal:ToggleFlyPhysics(false);
    _events:remove("HumanoidStateChanged")
    _events:remove("RenderStepped_FlyMoveMath")
    _p:debug("UnFly End")
end
function internal.ToolEquipped()
    coroutine.wrap(function()
        if not running then return end
        if not equippedToggle and flyAmountLeft > 0 then
            internal:Fly();
            equippedToggle = true;
        else
            task.wait(0.1);
            if not running then return end
            flyTool.Parent = Backpack
        end
    end)()
end
function internal.ToolUnequipped()
    coroutine.wrap(function()
        if not running then return end
        if equippedToggle then
            internal:UnFly();
            equippedToggle = false;
            unequippedTime = tick();
        end
    end)()
end
function internal.ToggleToolEquipped()
    coroutine.wrap(function()
        if not running then return end
        if equippedToggle then
            internal:UnFly();
            equippedToggle = false;
            unequippedTime = tick();
        elseif not equippedToggle and flyAmountLeft > 0 then
            internal:Fly();
            equippedToggle = true;
        end;
        task.wait(0.1);
        if not running then return end
        flyTool.Parent = Backpack
    end)()
end
local lastActivated
function internal.ToolActivated()
    if not running or not equippedToggle then return end
    local nowTm = tick()
    if not lastActivated or not flySettings.ToolActivatedCooldown or nowTm-lastActivated>=flySettings.ToolActivatedCooldown then
        util.onFire:Fire()
        lastActivated = nowTm
    end
end
--------
end ---- Internal Fly Mechanics
--------



local shutdownRunning=false
function util:shutdown()
    if shutdownRunning then return end
    shutdownRunning=true
    util.shutdownBegin:Fire()
    coroutine.wrap(function()
        task.wait()
        _p:info("shutdown - Begin")
        running = false
        internal:UnFly();
        equippedToggle = false;
        unequippedTime = tick();
        jumpState = false;
        _events:clear()
        _threads:stop(true)
        if ContextActionService then
            ContextActionService:UnbindAction("forward");
            ContextActionService:UnbindAction("backward");
            ContextActionService:UnbindAction("left");
            ContextActionService:UnbindAction("right");
            ContextActionService:UnbindAction("up");
            _p:debug("shutdown - ContextActions unbound.")
        end
        --[[
        if FlyBarGui then
            local succ_des,err_des = pcall(function()
                --FlyBarGui:Destroy();
                --_p:debug("shutdown - FlyBarGui destroyed")
                FlyBarGui.Enabled = false
                return
            end)
            if not succ_des then
                _p:error("shutdown - failed to destroy FlyBarGui! Error=",err_des)
            end
        end
        ]]
        if BodyVelocity then
            local succ_des,err_des = pcall(function() BodyVelocity.Parent=nil;BodyVelocity:Destroy();return;end)
            if succ_des then
                BodyVelocity=nil
                _p:debug("shutdown - BodyVelocity destroyed")
            else
                _p:error("shutdown - failed to destroy BodyVelocity! Error=",err_des)
            end
        end
        if BodyGyro then
            local succ_des,err_des = pcall(function() BodyGyro.Parent=nil;BodyGyro:Destroy();return;end)
            if succ_des then
                BodyGyro=nil
                _p:debug("shutown - BodyGyro destroyed")
            else
                _p:error("shutdown - failed to destroy BodyGyro! Error=",err_des)
            end
        end
        task.wait(0.1)
        _sched:stop(true)
        _p:info("shutdown - Scheduler stopped")
        _p:info("shutdown - End")
        shutdownRunning=false
        LocalPlayer,Backpack,ControlModule,Character,Humanoid,BodyGyro,BodyVelocity,HumanoidRootPart,Animate,CurrentCamera,IdleAnim,MoveAnim,FlyBarGui,Bar = 
            nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
        MoveActions = nil
        barSize,equippedToggle,unequippedTime,flyAmountLeft,flyTool,running,flyEnabled,jumpState,flyToolParent = 
            nil,nil,nil,nil,nil,nil,nil,nil,nil
        util.shutdownEnd:Fire()
    end)()
end

local initRunning=false
function util:init(toolParm,settingsParm,resourcesParm)
    if initRunning then return end
    initRunning=true
    util.initBegin:Fire()
    local tool,_settings,resources = toolParm,settingsParm,resourcesParm
    coroutine.wrap(function()
        task.wait()
        _init:begin(tool,_settings,resources)
        initRunning=false
        util.initEnd:Fire()
    end)()
end

function util:getStatus()
    if initRunning or shutdownRunning then
        return "wait"
    elseif running then
        return "not_running"
    else
        return "running"
    end
end

function util:updateSettings(updatedSettings)
    if initRunning then
        _p:error("updateSettings - init is running! cannot update settings now.")
        return
    elseif shutdownRunning then
        _p:error("updateSettings - shutdown is running! cannot update settings now.")
        return
    elseif not running then
        _p:error("updateSettings - fly util is NOT running! call 'init' to begin.")
        return
    end
    if updatedSettings and type(updatedSettings)=="table" then
        _init:applySettings(updatedSettings)
    end
end

return util;