local RunService,Players,ContextActionService

-- will be returned at end
local util = {}
util.errors = {}
-- internal locals
local LocalPlayer,ControlModule,Character,Humanoid,BodyGyro,BodyVelocity,HumanoidRootPart,Animate,CurrentCamera,IdleAnim,MoveAnim,FlyBarGui,Bar,
    ToolParentChangeEvent,ToolEquippedEvent,CharacterRemovingEvent

local MoveActions = {
	forward = 0,
	backward = 0,
	right = 0,
	left = 0,
    up = 0
}

local flySettings = {
    MaxFlyTime = 75,
    FlySpeedMult = 1.75,
    FlyDrainAmount = 1,
    FlyRechargeAmount = 0.5,
    FlyRechargeDelay = 2,
    PrintError = true,
    PrintInfo = true,
    PrintVerbose = true
}

local barSize
local equippedToggle = false;
local unequippedTime = tick()
local flyAmountLeft
local flyTool

local function myError(...)
    if flySettings.PrintError then
        print("FlyUtil::Error:: ",...)
    end
end
local function myInfo(...)
    if flySettings.PrintInfo then
        print("FlyUtil:: ",...)
    end
end
local function myVerbose(...)
    if flySettings.PrintVerbose then
        print("FlyUtil::Verbose:: ",...)
    end
end

local function init_error(msg,stop)
    myError("init_error! stop? ",stop," msg=",msg)
    table.insert(util.errors,msg)
    util.stop_init = (stop and true) or util.stop_init
end

local function applySettings(newSettings)
    if newSettings and type(newSettings)=="table" then
        for i,v in pairs(newSettings) do
            local old = flySettings[i]
            if old~=v then
                flySettings[i] = v
                myVerbose("applySettings - ",i," - old=",old," | new=",v)
            end
        end
    end
end

local running = false

local flyEnabled = false
local function ToggleFlyPhysics(toggle)
    myVerbose("ToggleFlyPhysics Begin - ",toggle)
	flyEnabled = toggle;
	BodyGyro.Parent = flyEnabled and HumanoidRootPart or nil;
	BodyVelocity.Parent = flyEnabled and HumanoidRootPart or nil;
	BodyGyro.CFrame = HumanoidRootPart.CFrame;
	BodyVelocity.Velocity = Vector3.new();
	Animate.Disabled = flyEnabled;
    myVerbose("ToggleFlyPhysics End - ",toggle)
end

local function HandleMoveAction(actionName, userInputState, inputObj)
	--task.wait();
	if userInputState == Enum.UserInputState.Begin then
		MoveActions[actionName] = 1;
        myVerbose("MoveAction Begin - ",actionName)
	elseif userInputState == Enum.UserInputState.End then
		MoveActions[actionName] = 0;
        myVerbose("MoveAction End - ",actionName)
	end;
	if flyEnabled then

	end;
	return Enum.ContextActionResult.Pass;
end

local jumpState = false
local function HumanoidStateChanged(oldState, newState)
    myVerbose("HumanoidStateChanged Old=",oldState," | New=",newState)
	if newState == Enum.HumanoidStateType.Landed then
		jumpState = false;
		return;
	end;
	if newState == Enum.HumanoidStateType.Jumping then
		jumpState = true;
	end;
end

local function FlyMoveMath()
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

local events = {}
local function Fly()
    myVerbose("Fly Begin")
    if Humanoid then
		if Humanoid:GetState() == Enum.HumanoidStateType.Dead then
            myError("Dead! Cannot 'Fly'")
			return;
		end;
	else
        myError("No Humanoid!!! Cannot 'Fly'")
		return;
	end;
	Humanoid.PlatformStand = true;
	Humanoid.HipHeight = 0;
	if MoveAnim then
        pcall(function()
            MoveAnim:Play()
            myVerbose("MoveAnim played")
        end)
    end
	ToggleFlyPhysics(true);
	for i,v in pairs({ Humanoid.StateChanged:Connect(HumanoidStateChanged), RunService.RenderStepped:Connect(FlyMoveMath) }) do
        table.insert(events,v)
    end
    myVerbose("Fly End")
end
local function RemoveEvents()
	for i, v in pairs(events) do
		pcall(function() v:Disconnect(); end);
        myVerbose("Disconnected::",i,v)
        events[i] = nil
	end;
    table.clear(events);
end
local function UnFly()
    myVerbose("UnFly Begin")
    Humanoid.HipHeight = 1;
	if MoveAnim then
        pcall(function()
            MoveAnim:Stop()
            myVerbose("MoveAnim stopped")
        end)
    end
	Humanoid.PlatformStand = false;
	task.delay(0.1, function()
		Humanoid:ChangeState(Enum.HumanoidStateType.Freefall);
		Humanoid:ChangeState(Enum.HumanoidStateType.Freefall);
		Humanoid:ChangeState(Enum.HumanoidStateType.Freefall);
		Humanoid:ChangeState(Enum.HumanoidStateType.Freefall);
        myVerbose("Humanoid State Changed >>> ",Humanoid:GetState())
	end);
	ToggleFlyPhysics(false);
	RemoveEvents();
    myVerbose("UnFly End")
end

local function ToggleToolEquipped()
    if not running then return end
    if equippedToggle then
        equippedToggle = false;
        UnFly();
        unequippedTime = tick();
    elseif not equippedToggle and flyAmountLeft > 0 then
        equippedToggle = true;
        Fly();
    end;
    --task.wait(0.1);
    --if not running then return end
    flyTool.Parent = LocalPlayer.Backpack;
end

function shutdown()
    myInfo("shutdown - Begin")
    running = false
    UnFly();
    equippedToggle = false;
    unequippedTime = tick();
    jumpState = false;
    RemoveEvents();
    if ContextActionService then
        ContextActionService:UnbindAction("forward");
        ContextActionService:UnbindAction("backward");
        ContextActionService:UnbindAction("left");
        ContextActionService:UnbindAction("right");
        ContextActionService:UnbindAction("up");
        myVerbose("shutdown - ContextActions unbound.")
    end
    if CharacterRemovingEvent then
        pcall(function() CharacterRemovingEvent:Disconnect() end)
        CharacterRemovingEvent = nil
        myVerbose("shutdown - Disconnected CharacterRemovingEvent")
    end
    if ToolParentChangeEvent then
        pcall(function() ToolParentChangeEvent:Disconnect() end)
        ToolParentChangeEvent = nil
        myVerbose("shutdown - Disconnected ToolParentChangeEvent")
    end
    if ToolEquippedEvent then
        pcall(function() ToolEquippedEvent:Disconnect() end)
        ToolEquippedEvent = nil
        myVerbose("shutdown - Disconnected ToolEquippedEvent")
    end
    if FlyBarGui then
        pcall(function()
            FlyBarGui:Destroy();
            myVerbose("shutdown - FlyBarGui destroyed")
        end)
    end
    myInfo("shutdown - End")
end

function init(tool,newSettings,resources)
    myInfo("init - Begin")

    if not game or not game:IsLoaded() then
        init_error("Game not loaded yet!",true)
        return
    else
        RunService = (resources and resources["RunService"]) or game:FindService("RunService")
        Players = (resources and resources["Players"]) or game:FindService("Players")
        ContextActionService = (resources and resources["ContextActionService"]) or game:FindService("ContextActionService")
    end
    if not(RunService and Players and ContextActionService) then
        init_error("Services not available",true)
        return
    end
    if not tool or typeof(tool)~="Instance" or not tool:IsA("Tool") then
        init_error("Invalid or Nil Tool provided.",true)
        return
    end

    myVerbose("init - Initial Checks Passed")
    
    applySettings(newSettings)
    LocalPlayer = Players.LocalPlayer
    ControlModule = (resources and resources["ControlModule"]) or
        require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("ControlModule"));
    myVerbose("init - ControlModule=",ControlModule)
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
    myVerbose("init - Character=",Character," | Parent=",Character.Parent)
    while not Character.Parent do
        Character.AncestryChanged:Wait();
        myVerbose("Waited on Character.Parent=",Character.Parent)
    end
    Humanoid = Character:WaitForChild("Humanoid")
    myVerbose("init - Humanoid=",Humanoid)
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    myVerbose("init - HumanoidRootPart=",HumanoidRootPart)
    Animate = Character:WaitForChild("Animate")
    myVerbose("init - Animate=",Animate)
    CurrentCamera = workspace.CurrentCamera
    BodyGyro = Instance.new("BodyGyro");
    BodyGyro.maxTorque = Vector3.new(1, 1, 1) * 1000000;
    BodyGyro.P = 100000;
    myVerbose("init - BodyGyro=",BodyGyro)
    BodyVelocity = Instance.new("BodyVelocity");
    BodyVelocity.maxForce = Vector3.new(1, 1, 1) * 1000000;
    BodyVelocity.P = 10000;
    myVerbose("init - BodyVelocity=",BodyVelocity)

    IdleAnim = nil
    MoveAnim = nil
    FlyBarGui = nil
    Bar = nil
    local function loadResources()
        if resources then
            if not IdleAnim then
                local tmpIdleAsset = resources["IdleAnim"]
                if tmpIdleAsset then
                    IdleAnim = Humanoid:LoadAnimation(resources["IdleAnim"])
                    myVerbose("loadResources - IdleAnim loaded.")
                else
                    myVerbose("loadResources - No IdleAnim.")
                end
            end
            if not MoveAnim then
                local tmpMoveAsset = resources["MoveAnim"]
                if tmpMoveAsset then
                    MoveAnim = Humanoid:LoadAnimation(resources["MoveAnim"])
                    myVerbose("loadResources - MoveAnim loaded.")
                else
                    myVerbose("loadResources - No MoveAnim.")
                end
            end
            if not FlyBarGui then
                local tmpFlyBar = resources["FlyBarGui"]
                if tmpFlyBar and typeof(tmpFlyBar)=="Instance" and tmpFlyBar.ClassName=="ScreenGui" then
                    local tmpBar = tmpFlyBar:WaitForChild("Bar")
                    if tmpBar and typeof(tmpBar)=="Instance" and tmpBar.ClassName=="Frame" then
                        FlyBarGui = tmpFlyBar
                        Bar = tmpBar
                        barSize = Bar.Size
                        FlyBarGui.Parent = LocalPlayer.PlayerGui
                        myVerbose("loadResources - FlyBarGui=",FlyBarGui," | Bar=",Bar," | barSize=",barSize)
                    else
                        myVerbose("loadResources - Nil/Invalid Bar=",tmpBar)
                    end
                else
                    myVerbose("loadResources - Nil/Invalid FlyBarGui=",tmpFlyBar)
                end
            end
        end
    end
    loadResources()
    if not IdleAnim or not MoveAnim or not FlyBarGui or not Bar then
        coroutine.wrap(function()
            local startTm = tick()
            myVerbose("init - Kicking off coroutine for resource load... StartTime=",startTm)
            while (not IdleAnim or not MoveAnim or not FlyBarGui or not Bar) and startTm>(tick()-5) do
                task.wait(0.1)
                myVerbose("init - Attempt loadResources. IdleAnim=",IdleAnim," | MoveAnim=",MoveAnim," | FlyBarGui=",FlyBarGui," | Bar=",Bar," | TimeLeft=",startTm-(tick()-5))
                loadResources()
            end
            myVerbose("init - loadResources success? ",(IdleAnim and MoveAnim and FlyBarGui and Bar)," | TimeTaken=",(tick()-startTm))
        end)()
    end

    flyTool = tool
    flyAmountLeft = flySettings.MaxFlyTime

    ContextActionService:BindAction("forward", HandleMoveAction, false, Enum.PlayerActions.CharacterForward);
    ContextActionService:BindAction("backward", HandleMoveAction, false, Enum.PlayerActions.CharacterBackward);
    ContextActionService:BindAction("left", HandleMoveAction, false, Enum.PlayerActions.CharacterLeft);
    ContextActionService:BindAction("right", HandleMoveAction, false, Enum.PlayerActions.CharacterRight);
    ContextActionService:BindAction("up", HandleMoveAction, false, Enum.PlayerActions.CharacterJump);
    myVerbose("init - ContextActions Bound.")

    running = true
    flyEnabled = false;
    equippedToggle = false;
    unequippedTime = tick();
    jumpState = false;

    task.spawn(function()
        while running and task.wait(0.1) do
            local v23 = ControlModule and ControlModule:GetMoveVector() or Humanoid and Humanoid.MoveDirection or Vector3:new(0,0,0);
            MoveActions.forward = -v23.Z;
            MoveActions.right = v23.X;
        end;
    end);

    if CharacterRemovingEvent then
        pcall(function() CharacterRemovingEvent:Disconnect() end)
        CharacterRemovingEvent = nil
        myVerbose("init - Disconnected CharacterRemovingEvent")
    end
    CharacterRemovingEvent = LocalPlayer.CharacterRemoving:Connect(function()
        myVerbose("CharacterRemovingEvent - Begin")
        RemoveEvents();
        ContextActionService:UnbindAction("forward");
        ContextActionService:UnbindAction("backward");
        ContextActionService:UnbindAction("left");
        ContextActionService:UnbindAction("right");
        ContextActionService:UnbindAction("up");
        myVerbose("CharacterRemovingEvent - End")
    end);
    myVerbose("init - Connected CharacterRemovingEvent")

    if ToolParentChangeEvent then
        pcall(function() ToolParentChangeEvent:Disconnect() end)
        ToolParentChangeEvent = nil
        myVerbose("init - Disconnected ToolParentChangeEvent")
    end
    ToolParentChangeEvent = flyTool:GetPropertyChangedSignal("Parent"):Connect(function()
        myVerbose("ToolParentChangeEvent - Begin")
        if not flyTool.Parent then
            if FlyBarGui then
                pcall(function()
                    FlyBarGui:Destroy()
                    myVerbose("ToolParentChangeEvent - FlyBarGui destroyed")
                end)
            end
        end;
        myVerbose("ToolParentChangeEvent - End")
    end);
    myVerbose("init - Connected ToolParentChangeEvent")

    if ToolEquippedEvent then
        pcall(function() ToolEquippedEvent:Disconnect() end)
        ToolEquippedEvent = nil
        myVerbose("init - Disconnected ToolEquippedEvent")
    end
    local otherToolConns = getconnections(flyTool.Equipped)
    myVerbose("init - otherToolConns Cnt=",#otherToolConns)
    for i, v in pairs(otherToolConns) do
        myVerbose("init - otherToolConns::",i," | Function=",(v and v.Function))
        if v and v.Function then
            local succ_fi,fi = pcall(function()
                return debug.getinfo(v.Function)
            end)
            if succ_fi then
                if flySettings.PrintVerbose then
                    myVerbose("init - got func info. Func=",v.Function," | Cnt=",#fi)
                    for i2,v2 in pairs(fi) do
                        myVerbose(" --- FuncInfo::",i2,"=",v2," | type=",type(v2), " | typeof=",typeof(v2))
                    end
                end
            else
                myError("init - failed getting func info! Func=",v.Function," | Error=",fi)
            end
            local succ_fEnv,fEnv = pcall(function() 
                local tmpfEnv = getfenv(v.Function);
                myVerbose("init - otherToolConns::",i," | script=",(tmpfEnv and tmpfEnv.script))
                if tmpfEnv and tmpfEnv.script then
                    sethiddenproperty(tmpfEnv.script,"Disabled",true)
                    myVerbose("init - disabled other script. Source=",gethiddenproperty(tmpfEnv.script,"Source"))
                end
                return tmpfEnv
            end)
            if not succ_fEnv then
                myError("init - failed disabling other env! Func=",v.Function," | Error=",fEnv)
            end
            myVerbose("init - disabling connection. Func=",v.Function," | Source=",fi.Source)
            local succ_dis,err_dis = pcall(function()
                v:Disable();
                return
            end)
            if succ_dis then
                myVerbose("init - disabled connection. Func=",v.Function," | Source=",fi.Source)
            else
                myError("init - failed to disable! Func=",v.Function," | Error=",err_dis)
            end
        end
    end
    ToolEquippedEvent = flyTool.Equipped:Connect(ToggleToolEquipped)
    myVerbose("init - Connected ToggleToolEquipped")

    coroutine.wrap(function()
        myVerbose("init - running loop started")
        while running and task.wait(0.1) do
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
                UnFly();
                unequippedTime = tick();
            end;
            if Bar then
                Bar.Size = UDim2.new(flyAmountLeft / flySettings.MaxFlyTime * barSize.X.Scale, 0, barSize.Y.Scale, 0);
            end
        end;
        myVerbose("init - running loop ended")
    end)()

    myInfo("init - End")
end

util.init = init;
util.shutdown = shutdown;
util.settings = flySettings;

return util;