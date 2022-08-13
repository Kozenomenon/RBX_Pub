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

local barSize
local equippedToggle = false;
local unequippedTime = tick()
local flyAmountLeft
local flyTool

local function init_error(msg,stop)
    table.insert(util.errors,msg)
    util.stop_init = (stop and true) or util.stop_init
end

local flySettings = {
    MaxFlyTime = 75,
    FlySpeedMult = 1.75,
    FlyDrainAmount = 1,
    FlyRechargeAmount = 0.5,
    FlyRechargeDelay = 2
}

local function applySettings(newSettings)
    if newSettings and type(newSettings)=="table" then
        for i,v in pairs(newSettings) do
            flySettings[i] = v
        end
    end
end

local running = false

local flyEnabled = false
local function ToggleFlyPhysics(toggle)

	flyEnabled = toggle;
	BodyGyro.Parent = flyEnabled and HumanoidRootPart or nil;
	BodyVelocity.Parent = flyEnabled and HumanoidRootPart or nil;
	BodyGyro.CFrame = HumanoidRootPart.CFrame;
	BodyVelocity.Velocity = Vector3.new();
	Animate.Disabled = flyEnabled;
end

local function HandleMoveAction(actionName, userInputState, inputObj)
	task.wait();
	if userInputState == Enum.UserInputState.Begin then
		MoveActions[actionName] = 1;
	elseif userInputState == Enum.UserInputState.End then
		MoveActions[actionName] = 0;
	end;
	if flyEnabled then

	end;
	return Enum.ContextActionResult.Pass;
end

local jumpState = false
local function HumanoidStateChanged(oldState, newState)
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
    if Humanoid then
		if Humanoid:GetState() == Enum.HumanoidStateType.Dead then
			return;
		end;
	else
		return;
	end;
	Humanoid.PlatformStand = true;
	Humanoid.HipHeight = 0;
	if MoveAnim then
       pcall(function() MoveAnim:Play() end)
    end
	ToggleFlyPhysics(true);
	for i,v in pairs({ Humanoid.StateChanged:Connect(HumanoidStateChanged), RunService.RenderStepped:Connect(FlyMoveMath) }) do
        table.insert(events,v)
    end
end
local function RemoveEvents()
	for i, v in pairs(events) do
		pcall(function() v:Disconnect(); end);
        events[i] = nil
	end;
    table.clear(events);
end
local function UnFly()
    Humanoid.HipHeight = 1;
	if MoveAnim then
        pcall(function() MoveAnim:Stop() end)
    end
	Humanoid.PlatformStand = false;
	task.delay(0.1, function()
		Humanoid:ChangeState(Enum.HumanoidStateType.Freefall);
		Humanoid:ChangeState(Enum.HumanoidStateType.Freefall);
		Humanoid:ChangeState(Enum.HumanoidStateType.Freefall);
		Humanoid:ChangeState(Enum.HumanoidStateType.Freefall);
	end);
	ToggleFlyPhysics(false);
	RemoveEvents();
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
    task.wait(0.1);
    if not running then return end
    flyTool.Parent = LocalPlayer.Backpack;
end

function shutdown()
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
    end
    if CharacterRemovingEvent then
        pcall(function() CharacterRemovingEvent:Disconnect() end)
        CharacterRemovingEvent = nil
    end
    if ToolParentChangeEvent then
        pcall(function() ToolParentChangeEvent:Disconnect() end)
        ToolParentChangeEvent = nil
    end
    if ToolEquippedEvent then
        pcall(function() ToolEquippedEvent:Disconnect() end)
        ToolEquippedEvent = nil
    end
    if FlyBarGui then
        FlyBarGui:Destroy()
    end
end

function init(tool,newSettings,resources)
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
    applySettings(newSettings)
    LocalPlayer = Players.LocalPlayer
    ControlModule = (resources and resources["ControlModule"]) or
        require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("ControlModule"));
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    while not Character.Parent do
        Character.AncestryChanged:Wait()
    end
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    Animate = Character:WaitForChild("Animate")
    CurrentCamera = workspace.CurrentCamera
    BodyGyro = Instance.new("BodyGyro");
    BodyGyro.maxTorque = Vector3.new(1, 1, 1) * 1000000;
    BodyGyro.P = 100000;
    BodyVelocity = Instance.new("BodyVelocity");
    BodyVelocity.maxForce = Vector3.new(1, 1, 1) * 1000000;
    BodyVelocity.P = 10000;

    IdleAnim = resources and resources["IdleAnim"] and Humanoid:LoadAnimation(resources["IdleAnim"])
    MoveAnim = resources and resources["MoveAnim"] and Humanoid:LoadAnimation(resources["MoveAnim"])
    FlyBarGui = resources and resources["FlyBarGui"]
    Bar = FlyBarGui and FlyBarGui:WaitForChild("Bar")
    if Bar then
        barSize = Bar.Size
    end
    if FlyBarGui then
        FlyBarGui.Parent = LocalPlayer.PlayerGui
    end

    flyTool = tool
    flyAmountLeft = flySettings.MaxFlyTime

    ContextActionService:BindAction("forward", HandleMoveAction, false, Enum.PlayerActions.CharacterForward);
    ContextActionService:BindAction("backward", HandleMoveAction, false, Enum.PlayerActions.CharacterBackward);
    ContextActionService:BindAction("left", HandleMoveAction, false, Enum.PlayerActions.CharacterLeft);
    ContextActionService:BindAction("right", HandleMoveAction, false, Enum.PlayerActions.CharacterRight);
    ContextActionService:BindAction("up", HandleMoveAction, false, Enum.PlayerActions.CharacterJump);

    running = true
    flyEnabled = false;
    equippedToggle = false;
    unequippedTime = tick();
    jumpState = false;

    task.spawn(function()
        while running and task.wait(0.1) do
            local v23 = ControlModule:GetMoveVector();
            MoveActions.forward = -v23.Z;
            MoveActions.right = v23.X;
        end;
    end);

    if CharacterRemovingEvent then
        pcall(function() CharacterRemovingEvent:Disconnect() end)
        CharacterRemovingEvent = nil
    end
    CharacterRemovingEvent = LocalPlayer.CharacterRemoving:Connect(function()
        RemoveEvents();
        ContextActionService:UnbindAction("forward");
        ContextActionService:UnbindAction("backward");
        ContextActionService:UnbindAction("left");
        ContextActionService:UnbindAction("right");
        ContextActionService:UnbindAction("up");
    end);

    if ToolParentChangeEvent then
        pcall(function() ToolParentChangeEvent:Disconnect() end)
        ToolParentChangeEvent = nil
    end
    ToolParentChangeEvent = flyTool:GetPropertyChangedSignal("Parent"):Connect(function()
        if not flyTool.Parent then
            if FlyBarGui then
                FlyBarGui:Destroy()
            end
        end;
    end);

    if ToolEquippedEvent then
        pcall(function() ToolEquippedEvent:Disconnect() end)
        ToolEquippedEvent = nil
    end
    local otherToolConns = getconnections(flyTool.Equipped)
    for i, v in pairs(otherToolConns) do
        if v and v.Function then
            pcall(function() 
                local fEnv = getfenv(v.Function);
                if fEnv and fEnv.script then
                    sethiddenproperty(fEnv.script,"Disabled",true)
                end
            end)
            v:Disable();
        end
    end
    ToolEquippedEvent = flyTool.Equipped:Connect(ToggleToolEquipped)

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
            Bar.Size = UDim2.new(flyAmountLeft / flySettings.MaxFlyTime * barSize.X.Scale, 0, barSize.Size.Y.Scale, 0);
        end
    end;

end

util.init = init;
util.shutdown = shutdown;
util.settings = flySettings;

return util;