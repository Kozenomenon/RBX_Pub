--[[
	sumdumui by KoZ

	this is a fork of a ui lib i found some other scripts to be using. 
	i wanted to be able to configure some things like colors and padding..
	so i made this.

	use the lib like so: 
-----------------------------------------------------------------------------
	local uilib = loadstring(game:HttpGetAsync(<url>))()
	local win = uilib:CreateWindow("My Cool UI")
	
	local folder = win:AddFolder('stuff')
	folder:AddToggle({text = "This is a toggle", callback = function(v) print(v) end})
	folder:AddButton({text = 'button', callback = function() print('button clicked') end})
	folder:AddSlider({text = 'slider', min = 1, max = 100, callback = function(v) print(v) end})
	folder:AddList({text = 'option', values = {'yo', 'yes'}, callback = function(v) print(v) end})
	folder:AddBox({text = 'text box', callback = function(v) print(v) end})
	folder:AddColor({text = 'color', callback = function(v) print(v) end})
	
	win:AddSwitcher({text = 'switcher1', values = {'some option', 'another yay','wut dis','hrrdrr','ok ok i git it'}, callback = function(v) print(v) end})

	local bindOption1 = win:AddBind({text = "Bind 1",key = "M",toggle=true, 
	callback = function(state) 
		print(bindOption1.flag,state,uilib.flags[bindOption1.flag]) 
	end,
	bindcallback = function()
		print(bindOption1.bindflag,uilib.flags[bindOption1.bindflag])
	end})
	
	uilib:Init({
		TitleFont = Enum.Font.GothamBold,
		NormalFont = Enum.Font.Gotham,
		SpecialFont = Enum.Font.Code,
		TitleFontSize = 17,
		NormalFontSize = 17,
		SubFontSize = 16,
		InputFontSize = 15,
		SmallFontSize = 14,
		BlendColor1 = Color3.fromRGB(0,3,3), 
		BlendColor2 = Color3.fromRGB(0,255,255),
		WindowWidth = 300,
		Padding = {
			Top = 5,
			Right = 10,
			Bottom = 5,
			Left = 10
		}
	})
-----------------------------------------------------------------------------
	or other init settings...
	WindowBackColor = Color3.fromRGB(0,40,40),
	TitleBackColor = Color3.fromRGB(0,12,12),
	ForegroundColor = Color3.fromRGB(0,255,255),
	SlightColor = Color3.fromRGB(0, 48, 48),
	BoxBackColor = Color3.fromRGB(0,18,18),
	MainOpenColor = Color3.fromRGB(0,22,22),
	SubOpenColor = Color3.fromRGB(0,45,45),
	OutlineColor = Color3.fromRGB(0,87,87),
	OpenColor = Color3.fromRGB(0,135,135),
	CloseColor = Color3.fromRGB(0,130,130),
	AccentColor = Color3.fromRGB(0,143,143),
	InputColor = Color3.fromRGB(0,230,230),
	WindowBackColor_BlendRate = 0.13,
	TitleBackColor_BlendRate = 0.025,
	ForegroundColor_BlendRate = 1,
	SlightColor_BlendRate = 0.185,
	BoxBackColor_BlendRate = 0.05,
	MainOpenColor_BlendRate = 0.065,
	SubOpenColor_BlendRate = 0.14,
	OutlineColor_BlendRate = 0.325,
	OpenColor_BlendRate = 0.56,
	CloseColor_BlendRate = 0.5,
	AccentColor_BlendRate = 0.55,
	InputColor_BlendRate = 0.9,
	BlendColors = {
		{
			BlendColor = Color3.fromRGB(0,0,0)
		},
		{
			BlendColor = Color3.fromRGB(0,0,44)
		},
		{
			BlendColor = Color3.fromRGB(66,6,22),
			--BlendChannels = Color3.new(0.5,0.75,0.25)
		},
		{
			BlendColor = Color3.fromRGB(222, 222, 222),
			--BlendChannels = Color3.new(1,0.33,0.77)
		}
	},
]]

--[[
	utiity functions
]]
local function blend_value(v1: number,v2: number,perc: number)
	return math.clamp(v1 - (v1 - v2)*perc,0,1)
end
local function color_blend(c1: Color3,c2: Color3,rate: Color3)
	return Color3.fromRGB(
		blend_value(c1.R,c2.R,rate.R)*255,
		blend_value(c1.G,c2.G,rate.G)*255,
		blend_value(c1.B,c2.B,rate.B)*255
	)
end
local function ends_with(str, ending)
	return ending == "" or str:sub(-#ending) == ending
 end
--

local library = {
	flags = {}, 
	windows = {}, 
	open = true, 
	settings = {
		TitleFont = Enum.Font.GothamBold,
		NormalFont = Enum.Font.Gotham,
		SpecialFont = Enum.Font.Code,
		TitleFontSize = 17,
		NormalFontSize = 17,
		SubFontSize = 16,
		InputFontSize = 15,
		SmallFontSize = 14,
		WindowBackColor = Color3.fromRGB(0,40,40),
		TitleBackColor = Color3.fromRGB(0,12,12),
		ForegroundColor = Color3.fromRGB(0,255,255),
		SlightColor = Color3.fromRGB(0, 48, 48),
		BoxBackColor = Color3.fromRGB(0,18,18),
		MainOpenColor = Color3.fromRGB(0,22,22),
		SubOpenColor = Color3.fromRGB(0,45,45),
		OutlineColor = Color3.fromRGB(0,87,87),
		OpenColor = Color3.fromRGB(0,135,135),
		CloseColor = Color3.fromRGB(0,130,130),
		AccentColor = Color3.fromRGB(0,143,143),
		InputColor = Color3.fromRGB(0,230,230),
		WindowBackColor_BlendRate = 0.13,
		TitleBackColor_BlendRate = 0.025,
		ForegroundColor_BlendRate = 1,
		SlightColor_BlendRate = 0.185,
		BoxBackColor_BlendRate = 0.05,
		MainOpenColor_BlendRate = 0.065,
		SubOpenColor_BlendRate = 0.14,
		OutlineColor_BlendRate = 0.325,
		OpenColor_BlendRate = 0.56,
		CloseColor_BlendRate = 0.5,
		AccentColor_BlendRate = 0.55,
		InputColor_BlendRate = 0.9,
		WindowWidth = 300,
		Padding = {
			Top = 0,
			Right = 0,
			Bottom = 0,
			Left = 0
		},
		SubPadding = {
			Top = 0,
			Right = 0,
			Bottom = 0,
			Left = 0
		}
	}
}

local function get_blend_rate(option,defaultRate,baseRate)
	local rate = (type(option)=="number" and option) or (type(defaultRate)=="number" and defaultRate) or 1
	return Color3.new(math.clamp(rate*baseRate.R,0,1),
					  math.clamp(rate*baseRate.G,0,1),
					  math.clamp(rate*baseRate.B,0,1))
end
local function setup_settings(settings)
	if (settings) then
		local sett = library.settings
		if (settings.BlendColor1 and settings.BlendColor2) then
			settings.BlendColors = settings.BlendColors or {}
			settings.BlendColors[1] = {
				BlendColor = (typeof(settings.BlendColor1) == "Color3" and settings.BlendColor1) or Color3.new(0,0,0)
			}
			settings.BlendColors[2] = {
				BlendColor = (typeof(settings.BlendColor2) == "Color3" and settings.BlendColor2) or Color3.new(1,1,1),
				BlendRate = ((type(settings.BlendRate)=="number") and settings.BlendRate) or 1,
				  BlendChannels = ((typeof(settings.BlendChannels)=="Color3") and settings.BlendChannels) or Color3.new(1,1,1)
			}
		end
		if (settings.BlendColors and type(settings.BlendColors)=="table") then
			for i,v in pairs(sett) do
				if type(i)=="string" and ends_with(i,"Color") and typeof(v)=="Color3" then
					local clr
					for i2,v2 in pairs(settings.BlendColors) do
						if v2.BlendColor and typeof(v2.BlendColor) == "Color3" then
							local rate = ((type(v2.BlendRate)=="number") and v2.BlendRate) or 1
							local channels = ((typeof(v2.BlendChannels)=="Color3") and v2.BlendChannels) or Color3.new(1,1,1)
							local rateFinal = Color3.new(channels.R*rate,channels.G*rate,channels.B*rate)
							if not clr then
								clr = color_blend(Color3.new(0,0,0),v2.BlendColor,rateFinal)
							else 
								clr = color_blend(clr,v2.BlendColor,get_blend_rate(settings[i.."_BlendRate"],sett[i.."_BlendRate"],rateFinal))
							end
						end
					end
					sett[i] = clr or sett[i]
				end
			end
		end
		for i,v in pairs(settings) do
			sett[i] = v
		end
	end
end

--Services
local runService = game:GetService"RunService"
local tweenService = game:GetService"TweenService"
local textService = game:GetService"TextService"
local inputService = game:GetService"UserInputService"

--Locals
local dragging, dragInput, dragStart, startPos, dragObject

local blacklistedKeys = { --add or remove keys if you find the need to
	Enum.KeyCode.Unknown,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Slash,Enum.KeyCode.Tab,Enum.KeyCode.Backspace,Enum.KeyCode.Escape
}
local whitelistedMouseinputs = { --add or remove mouse inputs if you find the need to
	Enum.UserInputType.MouseButton1,Enum.UserInputType.MouseButton2,Enum.UserInputType.MouseButton3
}

--Functions
local function round(num, bracket)
	bracket = bracket or 1
	local a = math.floor(num/bracket + (math.sign(num) * 0.5)) * bracket
	if a < 0 then
		a = a + bracket
	end
	return a
end

local function keyCheck(x,x1)
	for _,v in next, x1 do
		if v == x then
			return true
		end
	end
end

local function getKey(value,table)
	for _,v in next, table do
		if v == value then
			return _
		end
	end
end

local function update(input)
	local delta = input.Position - dragStart
	local yPos = (startPos.Y.Offset + delta.Y) < -36 and -36 or startPos.Y.Offset + delta.Y
	dragObject:TweenPosition(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, yPos), "Out", "Quint", 0.1, true)
end

--From: https://devforum.roblox.com/t/how-to-create-a-simple-rainbow-effect-using-tweenService/221849/2
local chromaColor
local rainbowTime = 5
spawn(function()
	while wait() do
		chromaColor = Color3.fromHSV(tick() % rainbowTime / rainbowTime, 1, 1)
	end
end)

function library:Create(class, properties)
	properties = typeof(properties) == "table" and properties or {}
	local inst = Instance.new(class)
	for property, value in next, properties do
		inst[property] = value
	end
	return inst
end

local function getVertSize(subHolder)
	return subHolder and (2.125*library.settings.SubFontSize) or (2.3529411*library.settings.TitleFontSize)
end

local function createOptionHolder(holderTitle, parent, parentTable, subHolder)
	local size = getVertSize(subHolder)
	local width = (subHolder and parent.UIPadding and parent.AbsoluteSize.X - parent.UIPadding.PaddingLeft.Offset - parent.UIPadding.PaddingRight.Offset) or library.settings.WindowWidth
    parentTable.main = library:Create("ImageButton", {
		LayoutOrder = subHolder and parentTable.position or 0,
		Position = UDim2.new(0, 20 + ((library.settings.WindowWidth+20) * (parentTable.position or 0)), 0, 20),
		Size = UDim2.new(0,width,0,size),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = library.settings.WindowBackColor, 
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.04,
		ClipsDescendants = true,
		Parent = parent
	})
	
	local round
	if not subHolder then
		round = library:Create("ImageLabel", {
			Size = UDim2.new(0, width, 0, size),
			BackgroundTransparency = 1,
			Image = "rbxassetid://3570695787",
			ImageColor3 = parentTable.open and (subHolder and library.settings.SubOpenColor or library.settings.MainOpenColor) or (subHolder and library.settings.MainOpenColor or library.settings.TitleBackColor),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(100, 100, 100, 100),
			SliceScale = 0.04,
			Parent = parentTable.main
		})
	end
	
	local title = library:Create("TextLabel", {
		Size = UDim2.new(0, width, 0, size),
		BackgroundTransparency = subHolder and 0 or 1,
		BackgroundColor3 = library.settings.TitleBackColor,
		BorderSizePixel = 0,
		Text = holderTitle,
		TextSize = subHolder and library.settings.SubFontSize or library.settings.TitleFontSize,
		Font = library.settings.TitleFont,
		TextColor3 = library.settings.ForegroundColor, 
		Parent = parentTable.main
	})
	
	local closeHolder = library:Create("Frame", {
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(-1, 0, 1, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Parent = title
	})
	
	local close = library:Create("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, -size - (size*0.4), 1, -size - (size*0.4)),
		Rotation = parentTable.open and 90 or 180,
		BackgroundTransparency = 1,
		Image = "rbxassetid://4918373417",
		ImageColor3 = parentTable.open and library.settings.CloseColor or library.settings.OpenColor,
		ScaleType = Enum.ScaleType.Fit,
		Parent = closeHolder
	})
	
	parentTable.content = library:Create("Frame", {
		Position = UDim2.new(0, 0, 0, size),
		Size = UDim2.new(1, 0, 1, -size),
		BackgroundTransparency = 1,
		Parent = parentTable.main
	})
	
	local layout = library:Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = parentTable.content
	})

    library:Create("UIPadding", {
		PaddingTop = UDim.new(0,(subHolder and library.settings.SubPadding and library.settings.SubPadding.Top) or (library.settings.Padding and library.settings.Padding.Top) or 0),
		PaddingRight = UDim.new(0,(subHolder and library.settings.SubPadding and library.settings.SubPadding.Right) or (library.settings.Padding and library.settings.Padding.Right) or 0),
		PaddingBottom = UDim.new(0,(subHolder and library.settings.SubPadding and library.settings.SubPadding.Bottom) or (library.settings.Padding and library.settings.Padding.Bottom) or 0),
		PaddingLeft = UDim.new(0,(subHolder and library.settings.SubPadding and library.settings.SubPadding.Left) or (library.settings.Padding and library.settings.Padding.Left) or 0),
		Parent = parentTable.content
	})
	
	layout.Changed:connect(function()
        local height = parentTable.content.UIPadding.PaddingTop.Offset + parentTable.content.UIPadding.PaddingBottom.Offset + layout.AbsoluteContentSize.Y
		parentTable.content.Size = UDim2.new(1, 0, 0, height)
		parentTable.main.Size = #parentTable.options > 0 and parentTable.open and UDim2.new(0, width, 0, height + size) or UDim2.new(0, width, 0, size)
	end)
	
	if not subHolder then		
		title.InputBegan:connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragObject = parentTable.main
				dragging = true
				dragStart = input.Position
				startPos = dragObject.Position
			end
		end)
		title.InputChanged:connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				dragInput = input
			end
		end)
			title.InputEnded:connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
	end
	
	local inContact
	local clicking
	closeHolder.InputBegan:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			clicking = true
			parentTable.open = not parentTable.open
			tweenService:Create(close, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = parentTable.open and 90 or 180, ImageColor3 = library.settings.ForegroundColor}):Play()
			if subHolder then
				tweenService:Create(title, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = parentTable.open and library.settings.SubOpenColor or library.settings.MainOpenColor}):Play()
			else
				tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = parentTable.open and library.settings.MainOpenColor or library.settings.TitleBackColor}):Play()
			end
            local height = parentTable.content.UIPadding.PaddingTop.Offset + parentTable.content.UIPadding.PaddingBottom.Offset + layout.AbsoluteContentSize.Y
			parentTable.main:TweenSize(#parentTable.options > 0 and parentTable.open and UDim2.new(0, width, 0, height + size) or UDim2.new(0, width, 0, size), "Out", "Quad", 0.2, true)
		elseif input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			tweenService:Create(close, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.InputColor}):Play()
		end
	end)

	closeHolder.InputEnded:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			clicking = false
			if inContact then
				tweenService:Create(close, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.InputColor}):Play()
			else
				tweenService:Create(close, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = parentTable.open and library.settings.CloseColor or library.settings.OpenColor}):Play()
			end
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = false
			if not clicking then
				tweenService:Create(close, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = parentTable.open and library.settings.CloseColor or library.settings.OpenColor}):Play()
			end
		end
	end)

	function parentTable:SetTitle(newTitle)
		title.Text = tostring(newTitle)
	end
	
	return parentTable
end
	
local function createLabel(option, parent)
	local main = library:Create("TextLabel", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		Text = " " .. option.text,
		TextSize = library.settings.NormalFontSize,
		Font = library.settings.NormalFont,
		TextColor3 = library.settings.ForegroundColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = parent.content
	})
	
	setmetatable(option, {__newindex = function(t, i, v)
		if i == "Text" then
			main.Text = " " .. tostring(v)
		end
	end})
end

local function createToggle(option, parent)
	local main = library:Create("TextLabel", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 31),
		BackgroundTransparency = 1,
		Text = " " .. option.text,
		TextSize = library.settings.NormalFontSize,
		Font = library.settings.NormalFont,
		TextColor3 = library.settings.ForegroundColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = parent.content
	})
	
	local tickboxOutline = library:Create("ImageLabel", {
		Position = UDim2.new(1, -6, 0, 4),
		Size = UDim2.new(-1, 10, 1, -10),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = option.state and library.settings.AccentColor or library.settings.OutlineColor,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = main
	})
	
	local tickboxInner = library:Create("ImageLabel", {
		Position = UDim2.new(0, 2, 0, 2),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = option.state and library.settings.AccentColor or library.settings.BoxBackColor,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = tickboxOutline
	})
	
	local checkmarkHolder = library:Create("Frame", {
		Position = UDim2.new(0, 4, 0, 4),
		Size = option.state and UDim2.new(1, -8, 1, -8) or UDim2.new(0, 0, 1, -8),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = tickboxOutline
	})
	
	local checkmark = library:Create("ImageLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Image = "rbxassetid://4919148038",
		ImageColor3 = library.settings.BoxBackColor,
		Parent = checkmarkHolder
	})
	
	local inContact
	main.InputBegan:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			option:SetState(not option.state)
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			tweenService:Create(tickboxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.AccentColor}):Play()
			if option.state then
				tweenService:Create(tickboxInner, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.AccentColor}):Play()
			end
		end
	end)
	
	main.InputEnded:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = false
			tweenService:Create(tickboxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
			if option.state then
				tweenService:Create(tickboxInner, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
			end
		end
	end)
	
	function option:SetState(state)
		library.flags[self.flag] = state
		self.state = state
		checkmarkHolder:TweenSize(option.state and UDim2.new(1, -8, 1, -8) or UDim2.new(0, 0, 1, -8), "Out", "Quad", 0.2, true)
		tweenService:Create(tickboxInner, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = state and library.settings.AccentColor or library.settings.BoxBackColor}):Play()
		if state then
			tweenService:Create(tickboxOutline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.AccentColor}):Play()
		else
			if inContact then
				tweenService:Create(tickboxOutline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.AccentColor}):Play()
			else
				tweenService:Create(tickboxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
			end
		end
		self.callback(state)
	end

	if option.state then
		delay(1, function() option.callback(true) end)
	end
	
	setmetatable(option, {__newindex = function(t, i, v)
		if i == "Text" then
			main.Text = " " .. tostring(v)
		end
	end})
end

local function createButton(option, parent)
	local main = library:Create("TextLabel", {
		ZIndex = 2,
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, getVertSize(true)),
		BackgroundTransparency = 1,
		Text = " " .. option.text,
		TextSize = library.settings.NormalFontSize,
		Font = library.settings.NormalFont,
		TextColor3 = library.settings.ForegroundColor,
		Parent = parent.content
	})
	
	local round = library:Create("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, -12, 1, -10),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = library.settings.SlightColor,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = main
	})
	
	local inContact
	local clicking
	main.InputBegan:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			library.flags[option.flag] = true
			clicking = true
			tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.AccentColor}):Play()
			option.callback()
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			tweenService:Create(round, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
		end
	end)
	
	main.InputEnded:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			clicking = false
			if inContact then
				tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
			else
				tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.SlightColor}):Play()
			end
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = false
			if not clicking then
				tweenService:Create(round, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.SlightColor}):Play()
			end
		end
	end)
end

local function createBind(option, parent)
	local binding
	local holding
	local loop
	local text = string.match(option.key, "Mouse") and string.sub(option.key, 1, 5) .. string.sub(option.key, 12, 13) or option.key

	local main = library:Create("TextLabel", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, getVertSize(true)-1),
		BackgroundTransparency = 1,
		Text = " " .. option.text,
		TextSize = library.settings.NormalFontSize,
		Font = library.settings.NormalFont,
		TextColor3 = library.settings.ForegroundColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = parent.content
	})
	
	local round = library:Create("ImageLabel", {
		Position = UDim2.new(1, -6 + ((option.toggle and -1*(getVertSize(true)-1+6)) or 0), 0, 4),
		Size = UDim2.new(0, -textService:GetTextSize(text, library.settings.SubFontSize, library.settings.NormalFont, Vector2.new(9e9, 9e9)).X - library.settings.SubFontSize, 1, -10),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = library.settings.SlightColor,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = main
	})
	
	local bindinput = library:Create("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextSize = library.settings.SubFontSize,
		Font = library.settings.SpecialFont,
		TextColor3 = library.settings.ForegroundColor,
		Parent = round
	})

	local inContact
	local bindInContact
	local tickboxOutline
	local tickboxInner
	if option.toggle then

		tickboxOutline = library:Create("ImageLabel", {
			Position = UDim2.new(1, -6, 0, 4),
			Size = UDim2.new(-1, 10, 1, -10),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			BackgroundTransparency = 1,
			Image = "rbxassetid://3570695787",
			ImageColor3 = option.state and library.settings.AccentColor or library.settings.OutlineColor,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(100, 100, 100, 100),
			SliceScale = 0.02,
			Parent = main
		})
		
		tickboxInner = library:Create("ImageLabel", {
			Position = UDim2.new(0, 2, 0, 2),
			Size = UDim2.new(1, -4, 1, -4),
			BackgroundTransparency = 1,
			Image = "rbxassetid://3570695787",
			ImageColor3 = option.state and library.settings.AccentColor or library.settings.BoxBackColor,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(100, 100, 100, 100),
			SliceScale = 0.02,
			Parent = tickboxOutline
		})
		
		local checkmarkHolder = library:Create("Frame", {
			Position = UDim2.new(0, 4, 0, 4),
			Size = option.state and UDim2.new(1, -8, 1, -8) or UDim2.new(0, 0, 1, -8),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Parent = tickboxOutline
		})
		
		local checkmark = library:Create("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			BackgroundTransparency = 1,
			Image = "rbxassetid://4919148038",
			ImageColor3 = library.settings.BoxBackColor,
			Parent = checkmarkHolder
		})
		
		main.InputBegan:connect(function(input)
			if not bindInContact and not binding then
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					option:SetState(not option.state)
				end
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					inContact = true
					tweenService:Create(tickboxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.AccentColor}):Play()
					if option.state then
						tweenService:Create(tickboxInner, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.AccentColor}):Play()
					end
				end
			end
		end)
		
		main.InputEnded:connect(function(input)
			if not bindInContact and not binding then
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					inContact = false
					tweenService:Create(tickboxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
					if option.state then
						tweenService:Create(tickboxInner, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
					end
				end
			end
		end)
		
		function option:SetState(state)
			library.flags[self.flag] = state
			self.state = state
			checkmarkHolder:TweenSize(option.state and UDim2.new(1, -8, 1, -8) or UDim2.new(0, 0, 1, -8), "Out", "Quad", 0.2, true)
			tweenService:Create(tickboxInner, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = state and library.settings.AccentColor or library.settings.BoxBackColor}):Play()
			if state then
				tweenService:Create(tickboxOutline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.AccentColor}):Play()
			else
				if inContact then
					tweenService:Create(tickboxOutline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.AccentColor}):Play()
				else
					tweenService:Create(tickboxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
				end
			end
			self.callback(state)
		end
	
		if option.state then
			delay(1, function() option.callback(true) end)
		end

	end
	
	local inptgt = ((option.toggle and round) or main)
	inptgt.InputBegan:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if (option.toggle) then
				bindInContact = true
				tweenService:Create(tickboxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
				if option.state then
					tweenService:Create(tickboxInner, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
				end
			else
				inContact = true
			end
			if not binding then
				tweenService:Create(round, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
			end
		end
	end)
	 
	inptgt.InputEnded:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			binding = true
			bindinput.Text = "..."
			tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.AccentColor}):Play()
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if (option.toggle) then
				bindInContact = false
				if inContact then
					tweenService:Create(tickboxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.AccentColor}):Play()
					if option.state then
						tweenService:Create(tickboxInner, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.AccentColor}):Play()
					end
				end
			else
				inContact = false
			end
			if not binding then
				tweenService:Create(round, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.SlightColor}):Play()
			end
		end
	end)
	
	inputService.InputBegan:connect(function(input)
		if inputService:GetFocusedTextBox() then return end
		if (input.KeyCode.Name == option.key or input.UserInputType.Name == option.key) and not binding then
			if option.hold then
				loop = runService.Heartbeat:connect(function()
					if binding then
						option.callback(true)
						loop:Disconnect()
						loop = nil
					else
						option.callback()
					end
				end)
			elseif option.toggle then
				option:SetState(not option.state)
			else
				option.callback()
			end
		elseif binding then
			local key
			pcall(function()
				if not keyCheck(input.KeyCode, blacklistedKeys) then
					key = input.KeyCode
				end
			end)
			pcall(function()
				if keyCheck(input.UserInputType, whitelistedMouseinputs) and not key then
					key = input.UserInputType
				end
			end)
			key = key or option.key
			option:SetKey(key)
		end
	end)
	
	inputService.InputEnded:connect(function(input)
		if input.KeyCode.Name == option.key or input.UserInputType.Name == option.key or input.UserInputType.Name == "MouseMovement" then
			if loop then
				loop:Disconnect()
				loop = nil
				option.callback(true)
			end
		end
	end)
	
	function option:SetKey(key)
		binding = false
		if loop then
			loop:Disconnect()
			loop = nil
		end
		self.key = key or self.key
		self.key = self.key.Name or self.key
		library.flags[self.bindflag or self.flag] = self.key
		if string.match(self.key, "Mouse") then
			bindinput.Text = string.sub(self.key, 1, 5) .. string.sub(self.key, 12, 13)
		else
			bindinput.Text = self.key
		end
		tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = inContact and library.settings.OutlineColor or library.settings.SlightColor}):Play()
		round.Size = UDim2.new(0, -textService:GetTextSize(bindinput.Text, library.settings.InputFontSize, library.settings.NormalFont, Vector2.new(9e9, 9e9)).X - library.settings.SubFontSize, 1, -10)	
		if option.bindcallback and type(option.bindcallback) == "function" then
			option.bindcallback()
		end
	end
end

local function createSlider(option, parent)
	local main = library:Create("Frame", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 1,
		Parent = parent.content
	})
	
	local title = library:Create("TextLabel", {
		Position = UDim2.new(0, 0, 0, 4),
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = " " .. option.text,
		TextSize = library.settings.NormalFontSize,
		Font = library.settings.NormalFont,
		TextColor3 = library.settings.ForegroundColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = main
	})
	
	local slider = library:Create("ImageLabel", {
		Position = UDim2.new(0, 10, 0, getVertSize(true)),
		Size = UDim2.new(1, -20, 0, 5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = library.settings.BoxBackColor,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = main
	})
	
	local fill = library:Create("ImageLabel", {
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = library.settings.OutlineColor,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = slider
	})
	
	local circle = library:Create("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new((option.value - option.min) / (option.max - option.min), 0, 0.5, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = library.settings.OutlineColor,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 1,
		Parent = slider
	})
	
	local valueRound = library:Create("ImageLabel", {
		Position = UDim2.new(1, -6, 0, 4),
		Size = UDim2.new(0, -60, 0, 18),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = library.settings.SlightColor,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = main
	})
	
	local inputvalue = library:Create("TextBox", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = option.value,
		TextColor3 = library.settings.InputColor,
		TextSize = library.settings.InputFontSize,
		TextWrapped = true,
		Font = library.settings.NormalFont,
		Parent = valueRound
	})
	
	if option.min >= 0 then
		fill.Size = UDim2.new((option.value - option.min) / (option.max - option.min), 0, 1, 0)
	else
		fill.Position = UDim2.new((0 - option.min) / (option.max - option.min), 0, 0, 0)
		fill.Size = UDim2.new(option.value / (option.max - option.min), 0, 1, 0)
	end
	
	local sliding
	local inContact
	main.InputBegan:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			tweenService:Create(fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.AccentColor}):Play()
			tweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(3.5, 0, 3.5, 0), ImageColor3 = library.settings.AccentColor}):Play()
			sliding = true
			option:SetValue(option.min + ((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X) * (option.max - option.min))
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not sliding then
				tweenService:Create(fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
				tweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(2.8, 0, 2.8, 0), ImageColor3 = library.settings.OutlineColor}):Play()
			end
		end
	end)
	
	inputService.InputChanged:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and sliding then
			option:SetValue(option.min + ((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X) * (option.max - option.min))
		end
	end)

	main.InputEnded:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = false
			if inContact then
				tweenService:Create(fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.AccentColor}):Play()
				tweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(2.8, 0, 2.8, 0), ImageColor3 = library.settings.AccentColor}):Play()
			else
				tweenService:Create(fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
				tweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 0), ImageColor3 = library.settings.OutlineColor}):Play()
			end
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = false
			inputvalue:ReleaseFocus()
			if not sliding then
				tweenService:Create(fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
				tweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 0), ImageColor3 = library.settings.OutlineColor}):Play()
			end
		end
	end)

	inputvalue.FocusLost:connect(function()
		tweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 0), ImageColor3 = library.settings.OutlineColor}):Play()
		option:SetValue(tonumber(inputvalue.Text) or option.value)
	end)

	function option:SetValue(value)
		value = round(value, option.float)
		value = math.clamp(value, self.min, self.max)
		circle:TweenPosition(UDim2.new((value - self.min) / (self.max - self.min), 0, 0.5, 0), "Out", "Quad", 0.1, true)
		if self.min >= 0 then
			fill:TweenSize(UDim2.new((value - self.min) / (self.max - self.min), 0, 1, 0), "Out", "Quad", 0.1, true)
		else
			fill:TweenPosition(UDim2.new((0 - self.min) / (self.max - self.min), 0, 0, 0), "Out", "Quad", 0.1, true)
			fill:TweenSize(UDim2.new(value / (self.max - self.min), 0, 1, 0), "Out", "Quad", 0.1, true)
		end
		library.flags[self.flag] = value
		self.value = value
		inputvalue.Text = value
		self.callback(value)
	end
end

local function createSwitcher(option,parent)
	local valueCount = 0
	local lblTgl = true
	local currSelIdx
	if option and option.values and type(option.values)=="table" then
		for i,v in ipairs(option.values) do
			if tostring(v)==tostring(option.value) then
				currSelIdx = i
				break
			end
		end
		if not currSelIdx and option.value then
			option.values[#option.values+1]=tostring(option.value)
			currSelIdx = #option.values
		end
	elseif option and option.value then
		option.values = { tostring(option.value) }
		currSelIdx = 0
	else
		return nil
	end
	
	local main = library:Create("Frame", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, getVertSize()),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = parent.content
	})

	local round = library:Create("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, -12, 1, -10),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = library.settings.SlightColor,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = main
	})

	local sel1 = library:Create("TextLabel", {
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = option.value,
		TextSize = library.settings.NormalFontSize,
		Font = library.settings.NormalFont,
		TextColor3 = library.settings.ForegroundColor,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = main
	})

	local sel2 = library:Create("TextLabel", {
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = " ",
		TextSize = library.settings.NormalFontSize,
		Font = library.settings.NormalFont,
		TextColor3 = library.settings.ForegroundColor,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextTransparency = 1,
		Parent = main
	})

	local leftHolder = library:Create("Frame", {
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(2.25, 0, 1, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Parent = round
	})
	local leftBtn = library:Create("ImageLabel", {
		AnchorPoint = Vector2.new(0.5,0.5),
		Position = UDim2.new(0, getVertSize()*0.5, 0.5, 0),
		Size = UDim2.new(-1.25, 0, 1, -10),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Rotation = 180,
		BackgroundTransparency = 1,
		Image = "rbxassetid://4918373417",
		ImageColor3 = library.settings.OpenColor,
		ScaleType = Enum.ScaleType.Stretch,
		Parent = leftHolder
	})

	local rightHolder = library:Create("Frame", {
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(-2.25, 0, 1, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Parent = round
	})
	local rightBtn = library:Create("ImageLabel", {
		AnchorPoint = Vector2.new(0.5,0.5),
		Position = UDim2.new(1, -getVertSize()*0.5, 0.5, 0),
		Size = UDim2.new(-1.25, 0, 1, -10),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Rotation = 0,
		BackgroundTransparency = 1,
		Image = "rbxassetid://4918373417",
		ImageColor3 = library.settings.OpenColor,
		ScaleType = Enum.ScaleType.Stretch,
		Parent = rightHolder
	})

	local btnInContact = {false,false}
	local btnClicking = {false,false}
	for idx=1,2 do
		local holder = (idx==1 and leftHolder) or rightHolder
		local btn = (idx==1 and leftBtn) or rightBtn
		holder.InputBegan:connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				btnClicking[idx] = true
				tweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.ForegroundColor}):Play()
				option:Switch((idx==2 and 1) or -1)
			elseif input.UserInputType == Enum.UserInputType.MouseMovement then
				btnInContact[idx] = true
				tweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.InputColor}):Play()
			end
		end)
		holder.InputEnded:connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				btnClicking[idx] = false
				tweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = (btnInContact[idx] and library.settings.InputColor) or library.settings.OpenColor}):Play()
			elseif input.UserInputType == Enum.UserInputType.MouseMovement then
				btnInContact[idx] = false
				if not btnClicking[idx] then
					tweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OpenColor}):Play()
				end
			end
		end)
	end

	function option:SetValue(value)
		self.values = self.values or {}

		local newIdx = getKey(tostring(value),self.values)
		if not newIdx then
			self.values[#self.values+1] = tostring(value)
			newIdx = #self.values
		end

		self:Switch(newIdx - currSelIdx)
	end

	local switchRunning
	function option:Switch(idxChange: number)
		if switchRunning or not self.values or #self.values == 0 or idxChange == 0 then
			return
		end
		switchRunning = true
		for _=1,math.abs(idxChange) do

			local newIdx = currSelIdx + (idxChange/math.abs(idxChange))
			while newIdx > #self.values do
				newIdx = newIdx - #self.values
			end
			while newIdx < 1 do
				newIdx = newIdx + #self.values
			end
			
			local oldTxt,newTxt = (lblTgl and sel1) or sel2,(lblTgl and sel2) or sel1
			newTxt.Text = self.values[newIdx]
			tweenService:Create(oldTxt,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position = UDim2.new((idxChange < 0 and 1) or -1,0,0,0)}):Play()
			tweenService:Create(oldTxt,TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{TextTransparency = 1}):Play()
			newTxt.Position = UDim2.new((idxChange > 0 and 1) or -1,0,0,0)
			tweenService:Create(newTxt,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position = UDim2.new(0,0,0,0)}):Play()
			tweenService:Create(newTxt,TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{TextTransparency = 0}):Play()
			self.value = self.values[newIdx]
			currSelIdx = newIdx
			lblTgl = not lblTgl
			library.flags[self.flag] = self.value

		end
		self:callback(self.value)
		switchRunning = false
	end
end

local function createList(option, parent, holder)
	local valueCount = 0
	
	local main = library:Create("Frame", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, getVertSize()+12),
		BackgroundTransparency = 1,
		Parent = parent.content
	})
	
	local round = library:Create("ImageLabel", {
		Position = UDim2.new(0, 6, 0, 4),
		Size = UDim2.new(1, -12, 1, -10),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = library.settings.SlightColor,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = main
	})
	
	local title = library:Create("TextLabel", {
		Position = UDim2.new(0, 12, 0, 8),
		Size = UDim2.new(1, -24, 0, library.settings.SmallFontSize),
		BackgroundTransparency = 1,
		Text = option.text,
		TextSize = library.settings.SmallFontSize,
		Font = library.settings.TitleFont,
		TextColor3 = library.settings.AccentColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = main
	})
	
	local listvalue = library:Create("TextLabel", {
		Position = UDim2.new(0, 12, 0, 20),
		Size = UDim2.new(1, -24, 0, 24),
		BackgroundTransparency = 1,
		Text = option.value,
		TextSize = library.settings.InputFontSize,
		Font = library.settings.NormalFont,
		TextColor3 = library.settings.ForegroundColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = main
	})
	
	library:Create("ImageLabel", {
		Position = UDim2.new(1, -(getVertSize()*0.375), 0, (getVertSize()*0.375)),
		Size = UDim2.new(-1, getVertSize()*0.75, 1, -(getVertSize()*0.75)),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Rotation = 90,
		BackgroundTransparency = 1,
		Image = "rbxassetid://4918373417",
		ImageColor3 = library.settings.AccentColor,
		ScaleType = Enum.ScaleType.Fit,
		Parent = round
	})
	
	option.mainHolder = library:Create("ImageButton", {
		ZIndex = 3,
		Size = UDim2.new(0, library.settings.WindowWidth-10, 0, getVertSize()+12),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageTransparency = 1,
		ImageColor3 = library.settings.BoxBackColor,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Visible = false,
		Parent = library.base
	})
	
	local content = library:Create("ScrollingFrame", {
		ZIndex = 3,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarImageColor3 = library.settings.WindowBackColor,
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Parent = option.mainHolder
	})
	
	library:Create("UIPadding", {
		PaddingTop = UDim.new(0, 6),
		PaddingLeft = UDim.new(0,4),
		Parent = content
	})
	
	local layout = library:Create("UIListLayout", {
		Parent = content
	})
	
	layout.Changed:connect(function()
		option.mainHolder.Size = UDim2.new(0, library.settings.WindowWidth - 10, 0, (valueCount > 4 and (4 * getVertSize()) or layout.AbsoluteContentSize.Y) + 12)
		content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
	end)
	
	local inContact
	round.InputBegan:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if library.activePopup then
				library.activePopup:Close()
			else
				local position = main.AbsolutePosition
				option.mainHolder.Position = UDim2.new(0, position.X - 5, 0, position.Y - 6)
				option.open = true
				option.mainHolder.Visible = true
				library.activePopup = option
				content.ScrollBarThickness = 6
				option.mainHolder.ImageTransparency = 1
				tweenService:Create(option.mainHolder, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, position.X - 5, 0, position.Y - 3)}):Play()
				tweenService:Create(option.mainHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.1), {ImageTransparency = 0, Position = UDim2.new(0, position.X - 5, 0, position.Y + getVertSize() + 12)}):Play()
				for _,label in next, content:GetChildren() do
					if label:IsA"TextLabel" then
						label.BackgroundTransparency = 1
						label.TextTransparency = 1
						tweenService:Create(label, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
					end
				end
			end
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not option.open then
				tweenService:Create(round, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
			end
		end
	end)
	
	round.InputEnded:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = false
			if not option.open then
				tweenService:Create(round, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.SlightColor}):Play()
			end
		end
	end)
	
	function option:AddValue(value)
		valueCount = valueCount + 1
		local label = library:Create("TextLabel", {
			ZIndex = 3,
			Size = UDim2.new(1, -4, 0, getVertSize()-4),
			BackgroundColor3 = library.settings.SlightColor,
			BorderSizePixel = 2,
			BorderColor3 = library.settings.BoxBackColor,
			Text = "    " .. value,
			TextSize = library.settings.SmallFontSize,
			TextTransparency = self.open and 0 or 1,
			Font = library.settings.NormalFont,
			TextColor3 = library.settings.ForegroundColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = content
		})
		
		local inContact
		local clicking
		label.InputBegan:connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				clicking = true
				local twn = tweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = library.settings.AccentColor})
				twn.Completed:Connect(function()
					if library.activePopup then
						library.activePopup:Close()
					end
				end)
				twn:Play()
				self:SetValue(value)
			end
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				inContact = true
				if not clicking then
					tweenService:Create(label, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = library.settings.OutlineColor}):Play()
				end
			end
		end)
		
		label.InputEnded:connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				clicking = false
				tweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = inContact and library.settings.OutlineColor or library.settings.SlightColor}):Play()
			end
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				inContact = false
				if not clicking then
					tweenService:Create(label, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = library.settings.SlightColor}):Play()
				end
			end
		end)
	end

	if not table.find(option.values, option.value) then
		option:AddValue(option.value)
	end
	
	for _, value in next, option.values do
		option:AddValue(tostring(value))
	end
	
	function option:RemoveValue(value)
		for _,label in next, content:GetChildren() do
			if label:IsA"TextLabel" and label.Text == "	" .. value then
				label:Destroy()
				valueCount = valueCount - 1
				break
			end
		end
		if self.value == value then
			self:SetValue("")
		end
	end
	
	function option:SetValue(value)
		library.flags[self.flag] = tostring(value)
		self.value = tostring(value)
		listvalue.Text = self.value
		self.callback(value)
	end
	
	function option:Close()
		library.activePopup = nil
		self.open = false
		content.ScrollBarThickness = 0
		local position = main.AbsolutePosition
		tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = inContact and library.settings.OutlineColor or library.settings.SlightColor}):Play()
		tweenService:Create(self.mainHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 1, Position = UDim2.new(0, position.X - 5, 0, position.Y -10)}):Play()
		for _,label in next, content:GetChildren() do
			if label:IsA"TextLabel" then
				tweenService:Create(label, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
			end
		end
		wait(0.3)
		--delay(0.3, function()
			if not self.open then
				self.mainHolder.Visible = false
			end
		--end)
	end

	return option
end

local function createBox(option, parent)
	local main = library:Create("Frame", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundTransparency = 1,
		Parent = parent.content
	})
	
	local outline = library:Create("ImageLabel", {
		Position = UDim2.new(0, 6, 0, 4),
		Size = UDim2.new(1, -12, 1, -10),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = library.settings.OutlineColor,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = main
	})
	
	local round = library:Create("ImageLabel", {
		Position = UDim2.new(0, 8, 0, 6),
		Size = UDim2.new(1, -library.settings.SubFontSize, 1, -library.settings.SmallFontSize),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = library.settings.BoxBackColor,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.01,
		Parent = main
	})
	
	local title = library:Create("TextLabel", {
		Position = UDim2.new(0, 12, 0, 8),
		Size = UDim2.new(1, -24, 0, library.settings.SmallFontSize),
		BackgroundTransparency = 1,
		Text = option.text,
		TextSize = library.settings.SmallFontSize,
		Font = library.settings.TitleFont,
		TextColor3 = library.settings.OutlineColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = main
	})
	
	local inputvalue = library:Create("TextBox", {
		Position = UDim2.new(0, 12, 0, 20),
		Size = UDim2.new(1, -24, 0, 24),
		BackgroundTransparency = 1,
		Text = option.value,
		TextSize = library.settings.InputFontSize,
		Font = library.settings.NormalFont,
		TextColor3 = library.settings.ForegroundColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Parent = main
	})
	
	local inContact
	local focused
	main.InputBegan:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if not focused then inputvalue:CaptureFocus() end
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not focused then
				tweenService:Create(outline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.AccentColor}):Play()
			end
		end
	end)
	
	main.InputEnded:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = false
			if not focused then
				tweenService:Create(outline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
			end
		end
	end)
	
	inputvalue.Focused:connect(function()
		focused = true
		tweenService:Create(outline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.AccentColor}):Play()
	end)
	
	inputvalue.FocusLost:connect(function(enter)
		focused = false
		tweenService:Create(outline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
		option:SetValue(inputvalue.Text, enter)
	end)
	
	function option:SetValue(value, enter)
		library.flags[self.flag] = tostring(value)
		self.value = tostring(value)
		inputvalue.Text = self.value
		self.callback(value, enter)
	end
end

local function createColorPickerWindow(option)
	option.mainHolder = library:Create("ImageButton", {
		ZIndex = 3,
		Size = UDim2.new(0, library.settings.WindowWidth-10, 0, 180),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageTransparency = 1,
		ImageColor3 = library.settings.TitleBackColor,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = library.base
	})
		
	local hue, sat, val = Color3.toHSV(option.color)
	hue, sat, val = hue == 0 and 1 or hue, sat + 0.005, val - 0.005
	local editinghue
	local editingsatval
	local currentColor = option.color
	local previousColors = {[1] = option.color}
	local originalColor = option.color
	local rainbowEnabled
	local rainbowLoop
	local reset_clicking
	local reset_inContact
	local undo_clicking
	local undo_inContact
	local set_clicking
	local set_inContact
	local rainbow_clicking
	local rainbow_inContact
	
	function option:updateVisuals(Color)
		currentColor = Color
		self.visualize2.ImageColor3 = Color
		hue, sat, val = Color3.toHSV(Color)
		hue = hue == 0 and 1 or hue
		self.satval.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
		self.hueSlider.Position = UDim2.new(1 - hue, 0, 0, 0)
		self.satvalSlider.Position = UDim2.new(sat, 0, 1 - val, 0)
	end
	
	option.hue = library:Create("ImageLabel", {
		ZIndex = 3,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 8, 1, -8),
		Size = UDim2.new(1, -100, 0, 22),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = option.mainHolder
	})
	
	local Gradient = library:Create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.157, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(0.323, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.488, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.817, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
		}),
		Parent = option.hue
	})
	
	option.hueSlider = library:Create("Frame", {
		ZIndex = 3,
		Position = UDim2.new(1 - hue, 0, 0, 0),
		Size = UDim2.new(0, 2, 1, 0),
		BackgroundTransparency = 1,
		BackgroundColor3 = library.settings.BoxBackColor,
		BorderColor3 = library.settings.ForegroundColor,
		Parent = option.hue
	})
	
	option.hue.InputBegan:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			editinghue = true
			X = (option.hue.AbsolutePosition.X + option.hue.AbsoluteSize.X) - option.hue.AbsolutePosition.X
			X = (Input.Position.X - option.hue.AbsolutePosition.X) / X
			X = X < 0 and 0 or X > 0.995 and 0.995 or X
			option:updateVisuals(Color3.fromHSV(1 - X, sat, val))
		end
	end)
	
	inputService.InputChanged:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement and editinghue then
			X = (option.hue.AbsolutePosition.X + option.hue.AbsoluteSize.X) - option.hue.AbsolutePosition.X
			X = (Input.Position.X - option.hue.AbsolutePosition.X) / X
			X = X <= 0 and 0 or X >= 0.995 and 0.995 or X
			option:updateVisuals(Color3.fromHSV(1 - X, sat, val))
		end
	end)
	
	option.hue.InputEnded:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			editinghue = false
		end
	end)
	
	option.satval = library:Create("ImageLabel", {
		ZIndex = 3,
		Position = UDim2.new(0, 8, 0, 8),
		Size = UDim2.new(1, -100, 1, -42),
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
		BorderSizePixel = 0,
		Image = "rbxassetid://4155801252",
		ImageTransparency = 1,
		ClipsDescendants = true,
		Parent = option.mainHolder
	})
	
	option.satvalSlider = library:Create("Frame", {
		ZIndex = 3,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(sat, 0, 1 - val, 0),
		Size = UDim2.new(0, 4, 0, 4),
		Rotation = 45,
		BackgroundTransparency = 1,
		BackgroundColor3 = library.settings.ForegroundColor,
		Parent = option.satval
	})
	
	option.satval.InputBegan:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			editingsatval = true
			X = (option.satval.AbsolutePosition.X + option.satval.AbsoluteSize.X) - option.satval.AbsolutePosition.X
			Y = (option.satval.AbsolutePosition.Y + option.satval.AbsoluteSize.Y) - option.satval.AbsolutePosition.Y
			X = (Input.Position.X - option.satval.AbsolutePosition.X) / X
			Y = (Input.Position.Y - option.satval.AbsolutePosition.Y) / Y
			X = X <= 0.005 and 0.005 or X >= 1 and 1 or X
			Y = Y <= 0 and 0 or Y >= 0.995 and 0.995 or Y
			option:updateVisuals(Color3.fromHSV(hue, X, 1 - Y))
		end
	end)
	
	inputService.InputChanged:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement and editingsatval then
			X = (option.satval.AbsolutePosition.X + option.satval.AbsoluteSize.X) - option.satval.AbsolutePosition.X
			Y = (option.satval.AbsolutePosition.Y + option.satval.AbsoluteSize.Y) - option.satval.AbsolutePosition.Y
			X = (Input.Position.X - option.satval.AbsolutePosition.X) / X
			Y = (Input.Position.Y - option.satval.AbsolutePosition.Y) / Y
			X = X <= 0.005 and 0.005 or X >= 1 and 1 or X
			Y = Y <= 0 and 0 or Y >= 0.995 and 0.995 or Y
			option:updateVisuals(Color3.fromHSV(hue, X, 1 - Y))
		end
	end)
	
	option.satval.InputEnded:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			editingsatval = false
		end
	end)
	
	option.visualize2 = library:Create("ImageLabel", {
		ZIndex = 3,
		Position = UDim2.new(1, -8, 0, 8),
		Size = UDim2.new(0, -80, 0, 80),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = currentColor,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = option.mainHolder
	})
	
	option.resetColor = library:Create("ImageLabel", {
		ZIndex = 3,
		Position = UDim2.new(1, -8, 0, 92),
		Size = UDim2.new(0, -80, 0, library.settings.InputFontSize+3),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageTransparency = 1,
		ImageColor3 = library.settings.BoxBackColor,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = option.mainHolder
	})
	
	option.resetText = library:Create("TextLabel", {
		ZIndex = 3,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "Reset",
		TextTransparency = 1,
		Font = library.settings.SpecialFont,
		TextSize = library.settings.InputFontSize,
		TextColor3 = library.settings.ForegroundColor,
		Parent = option.resetColor
	})
	
	
	option.resetColor.InputBegan:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 and not rainbowEnabled then
			reset_clicking = true
			tweenService:Create(option.resetColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.AccentColor}):Play()
			previousColors = {originalColor}
			option:SetColor(originalColor)
		end
		if Input.UserInputType == Enum.UserInputType.MouseMovement and not dragging then
			reset_inContact = true
			tweenService:Create(option.resetColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
		end
	end)
	
	option.resetColor.InputEnded:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 and not rainbowEnabled then
			reset_clicking = false
			if reset_inContact then
				tweenService:Create(option.resetColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
			else
				tweenService:Create(option.resetColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.BoxBackColor}):Play()
			end
		end
		if Input.UserInputType == Enum.UserInputType.MouseMovement and not dragging then
			reset_inContact = false
			if not reset_clicking then
				tweenService:Create(option.resetColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.BoxBackColor}):Play()
			end
		end
	end)
	
	option.undoColor = library:Create("ImageLabel", {
		ZIndex = 3,
		Position = UDim2.new(1, -8, 0, 92 + (library.settings.InputFontSize+5)),
		Size = UDim2.new(0, -80, 0, library.settings.InputFontSize+3),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageTransparency = 1,
		ImageColor3 = library.settings.BoxBackColor,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = option.mainHolder
	})
	
	option.undoText = library:Create("TextLabel", {
		ZIndex = 3,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "Undo",
		TextTransparency = 1,
		Font = library.settings.SpecialFont,
		TextSize = library.settings.InputFontSize,
		TextColor3 = library.settings.ForegroundColor,
		Parent = option.undoColor
	})
	
	option.undoColor.InputBegan:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 and not rainbowEnabled then
			undo_clicking = true
			tweenService:Create(option.undoColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.AccentColor}):Play()
			local Num = #previousColors == 1 and 0 or 1
			option:SetColor(previousColors[#previousColors - Num])
			if #previousColors ~= 1 then
				table.remove(previousColors, #previousColors)
			end
		end
		if Input.UserInputType == Enum.UserInputType.MouseMovement and not dragging then
			undo_inContact = true
			tweenService:Create(option.undoColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
		end
	end)
	
	option.undoColor.InputEnded:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 and not rainbowEnabled then
			undo_clicking = false
			if undo_inContact then
				tweenService:Create(option.undoColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
			else
				tweenService:Create(option.undoColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.BoxBackColor}):Play()
			end
		end
		if Input.UserInputType == Enum.UserInputType.MouseMovement and not dragging then
			if not undo_clicking then
				tweenService:Create(option.undoColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.BoxBackColor}):Play()
			end
		end
	end)
	
	option.setColor = library:Create("ImageLabel", {
		ZIndex = 3,
		Position = UDim2.new(1, -8, 0, 92 + (library.settings.InputFontSize+5)*2),
		Size = UDim2.new(0, -80, 0, library.settings.InputFontSize+3),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageTransparency = 1,
		ImageColor3 = library.settings.BoxBackColor,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = option.mainHolder
	})
	
	option.setText = library:Create("TextLabel", {
		ZIndex = 3,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "Set",
		TextTransparency = 1,
		Font = library.settings.SpecialFont,
		TextSize = library.settings.InputFontSize,
		TextColor3 = library.settings.ForegroundColor,
		Parent = option.setColor
	})
	
	option.setColor.InputBegan:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 and not rainbowEnabled then
			set_clicking = true
			tweenService:Create(option.setColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.AccentColor}):Play()
			table.insert(previousColors, currentColor)
			option:SetColor(currentColor)
		end
		if Input.UserInputType == Enum.UserInputType.MouseMovement and not dragging then
			set_inContact = true
			tweenService:Create(option.setColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
		end
	end)
	
	option.setColor.InputEnded:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 and not rainbowEnabled then
			set_clicking = false
			if set_inContact then
				tweenService:Create(option.setColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
			else
				tweenService:Create(option.setColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.BoxBackColor}):Play()
			end
		end
		if Input.UserInputType == Enum.UserInputType.MouseMovement and not dragging then
			if not set_clicking then
				tweenService:Create(option.setColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.BoxBackColor}):Play()
			end
		end
	end)
	
	option.rainbow = library:Create("ImageLabel", {
		ZIndex = 3,
		Position = UDim2.new(1, -8, 0, 92 + (library.settings.InputFontSize+5)*3),
		Size = UDim2.new(0, -80, 0, library.settings.InputFontSize+3),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageTransparency = 1,
		ImageColor3 = library.settings.BoxBackColor,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = option.mainHolder
	})
	
	option.rainbowText = library:Create("TextLabel", {
		ZIndex = 3,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "Rainbow",
		TextTransparency = 1,
		Font = library.settings.SpecialFont,
		TextSize = library.settings.InputFontSize,
		TextColor3 = library.settings.ForegroundColor,
		Parent = option.rainbow
	})
	
	option.rainbow.InputBegan:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			rainbow_clicking = true
			tweenService:Create(option.rainbow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.AccentColor}):Play()
			rainbowEnabled = not rainbowEnabled
			if rainbowEnabled then
				rainbowLoop = runService.Heartbeat:connect(function()
					option:SetColor(chromaColor)
					option.rainbowText.TextColor3 = chromaColor
				end)
			else
				rainbowLoop:Disconnect()
				option:SetColor(previousColors[#previousColors])
				option.rainbowText.TextColor3 = library.settings.ForegroundColor
			end
		end
		if Input.UserInputType == Enum.UserInputType.MouseMovement and not dragging then
			rainbow_inContact = true
			tweenService:Create(option.rainbow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
		end
	end)
	
	option.rainbow.InputEnded:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			rainbow_clicking = false
			if rainbow_inContact then
				tweenService:Create(option.rainbow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
			else
				tweenService:Create(option.rainbow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.BoxBackColor}):Play()
			end
		end
		if Input.UserInputType == Enum.UserInputType.MouseMovement and not dragging then
			if not rainbow_clicking then
				tweenService:Create(option.rainbow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.BoxBackColor}):Play()
			end
		end
	end)
	
	return option
end

local function createColor(option, parent, holder)
	option.main = library:Create("TextLabel", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 31),
		BackgroundTransparency = 1,
		Text = " " .. option.text,
		TextSize = library.settings.NormalFontSize,
		Font = library.settings.NormalFont,
		TextColor3 = library.settings.ForegroundColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = parent.content
	})
	
	local colorBoxOutline = library:Create("ImageLabel", {
		Position = UDim2.new(1, -6, 0, 4),
		Size = UDim2.new(-1, 10, 1, -10),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = library.settings.OutlineColor,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = option.main
	})
	
	option.visualize = library:Create("ImageLabel", {
		Position = UDim2.new(0, 2, 0, 2),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = option.color,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = colorBoxOutline
	})
	
	local inContact
	option.main.InputBegan:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if not option.mainHolder then createColorPickerWindow(option) end
			if library.activePopup then
				library.activePopup:Close()
			end
			local position = option.main.AbsolutePosition
			option.mainHolder.Position = UDim2.new(0, position.X - 5, 0, position.Y - 6)
			option.open = true
			option.mainHolder.Visible = true
			library.activePopup = option
			tweenService:Create(option.mainHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0, Position = UDim2.new(0, position.X - 5, 0, position.Y - 3)}):Play()
			tweenService:Create(option.mainHolder, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.1), {Position = UDim2.new(0, position.X - 5, 0, position.Y + getVertSize())}):Play()
			tweenService:Create(option.satval, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
			for _,object in next, option.mainHolder:GetDescendants() do
				if object:IsA"TextLabel" then
					tweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
				elseif object:IsA"ImageLabel" then
					tweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
				elseif object:IsA"Frame" then
					tweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
				end
			end
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not option.open then
				tweenService:Create(colorBoxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.AccentColor}):Play()
			end
		end
	end)
	
	option.main.InputEnded:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not option.open then
				tweenService:Create(colorBoxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.settings.OutlineColor}):Play()
			end
		end
	end)
	
	function option:SetColor(newColor)
		if self.mainHolder then
			self:updateVisuals(newColor)
		end
		self.visualize.ImageColor3 = newColor
		library.flags[self.flag] = newColor
		self.color = newColor
		self.callback(newColor)
	end
	
	function option:Close()
		library.activePopup = nil
		self.open = false
		local position = self.main.AbsolutePosition
		tweenService:Create(self.mainHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 1, Position = UDim2.new(0, position.X - 5, 0, position.Y - 10)}):Play()
		tweenService:Create(self.satval, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
		for _,object in next, self.mainHolder:GetDescendants() do
			if object:IsA"TextLabel" then
				tweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
			elseif object:IsA"ImageLabel" then
				tweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 1}):Play()
			elseif object:IsA"Frame" then
				tweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
			end
		end
		delay(0.3, function()
			if not self.open then
				self.mainHolder.Visible = false
			end 
		end)
	end
end

local function loadOptions(option, holder)
	for _,newOption in next, option.options do
		if newOption.type == "label" then
			createLabel(newOption, option)
		elseif newOption.type == "toggle" then
			createToggle(newOption, option)
		elseif newOption.type == "button" then
			createButton(newOption, option)
		elseif newOption.type == "switcher" then
			createSwitcher(newOption,option)
		elseif newOption.type == "list" then
			createList(newOption, option, holder)
		elseif newOption.type == "box" then
			createBox(newOption, option)
		elseif newOption.type == "bind" then
			createBind(newOption, option)
		elseif newOption.type == "slider" then
			createSlider(newOption, option)
		elseif newOption.type == "color" then
			createColor(newOption, option, holder)
		elseif newOption.type == "folder" then
			newOption:init()
		end
	end
end

local function fixFlagText(text)
	return (text and type(text) == "string" and text:gsub(' ','_')) or ''
end

local function getFnctions(parent)
	function parent:AddLabel(option)
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text)
		option.type = "label"
		option.position = #self.options
		table.insert(self.options, option)
		
		return option
	end
	
	function parent:AddToggle(option)
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text)
		option.state = typeof(option.state) == "boolean" and option.state or false
		option.callback = typeof(option.callback) == "function" and option.callback or function() end
		option.type = "toggle"
		option.position = #self.options
		option.flag = option.flag or fixFlagText(option.text)
		library.flags[option.flag] = option.state
		table.insert(self.options, option)
		
		return option
	end
	
	function parent:AddButton(option)
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text)
		option.callback = typeof(option.callback) == "function" and option.callback or function() end
		option.type = "button"
		option.position = #self.options
		option.flag = option.flag or fixFlagText(option.text)
		table.insert(self.options, option)
		
		return option
	end
	
	function parent:AddBind(option)
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text)
		option.key = (option.key and option.key.Name) or option.key or "F"
		option.hold = typeof(option.hold) == "boolean" and option.hold or false
		option.callback = typeof(option.callback) == "function" and option.callback or function() end
		option.type = "bind"
		option.position = #self.options
		if (option.toggle) then
			option.state = typeof(option.state) == "boolean" and option.state or false
			option.flag = option.flag or fixFlagText(option.text)
			option.bindflag = option.bindflag or ("Bind_" .. option.flag)
			library.flags[option.flag] = option.state
			library.flags[option.bindflag] = option.key
		else
			option.flag = option.flag or fixFlagText(option.text)
			library.flags[option.flag] = option.key
		end
		table.insert(self.options, option)
		
		return option
	end
	
	function parent:AddSlider(option)
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text)
		option.min = typeof(option.min) == "number" and option.min or 0
		option.max = typeof(option.max) == "number" and option.max or 0
		option.dual = typeof(option.dual) == "boolean" and option.dual or false
		option.value = math.clamp(typeof(option.value) == "number" and option.value or option.min, option.min, option.max)
		option.value2 = typeof(option.value2) == "number" and option.value2 or option.max
		option.callback = typeof(option.callback) == "function" and option.callback or function() end
		option.float = typeof(option.value) == "number" and option.float or 1
		option.type = "slider"
		option.position = #self.options
		option.flag = option.flag or fixFlagText(option.text)
		library.flags[option.flag] = option.value
		table.insert(self.options, option)
		
		return option
	end

	function parent:AddSwitcher(option)
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text)
		option.values = typeof(option.values) == "table" and option.values or {}
		option.value = tostring(option.value or option.values[1] or "")
		option.callback = typeof(option.callback) == "function" and option.callback or function() end
		option.type = "switcher"
		option.position = #self.options
		option.flag = option.flag or fixFlagText(option.text)
		library.flags[option.flag] = option.value
		table.insert(self.options, option)

		return option
	end
	
	function parent:AddList(option)
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text)
		option.values = typeof(option.values) == "table" and option.values or {}
		option.value = tostring(option.value or option.values[1] or "")
		option.callback = typeof(option.callback) == "function" and option.callback or function() end
		option.open = false
		option.type = "list"
		option.position = #self.options
		option.flag = option.flag or fixFlagText(option.text)
		library.flags[option.flag] = option.value
		table.insert(self.options, option)
		
		return option
	end
	
	function parent:AddBox(option)
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text)
		option.value = tostring(option.value or "")
		option.callback = typeof(option.callback) == "function" and option.callback or function() end
		option.type = "box"
		option.position = #self.options
		option.flag = option.flag or fixFlagText(option.text)
		library.flags[option.flag] = option.value
		table.insert(self.options, option)
		
		return option
	end
	
	function parent:AddColor(option)
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text)
		option.color = typeof(option.color) == "table" and Color3.new(tonumber(option.color[1]), tonumber(option.color[2]), tonumber(option.color[3])) or option.color or Color3.new(255, 255, 255)
		option.callback = typeof(option.callback) == "function" and option.callback or function() end
		option.open = false
		option.type = "color"
		option.position = #self.options
		option.flag = option.flag or fixFlagText(option.text)
		library.flags[option.flag] = option.color
		table.insert(self.options, option)
		
		return option
	end
	
	function parent:AddFolder(title)
		local option = {}
		option.title = tostring(title)
		option.options = {}
		option.open = false
		option.type = "folder"
		option.position = #self.options
		table.insert(self.options, option)
		
		getFnctions(option)
		
		function option:init()
			createOptionHolder(self.title, parent.content, self, true)
			loadOptions(self, parent)
		end
		
		return option
	end
end

function library:CreateWindow(title)
	local window = {title = tostring(title), options = {}, open = true, canInit = true, init = false, position = #self.windows}
	getFnctions(window)
	
	table.insert(library.windows, window)
	
	return window
end

local UIToggle
local UnlockMouse
function library:Init(settings)

	setup_settings(settings)
	
	self.base = self.base or self:Create("ScreenGui")
	local guiPar
	if syn and syn.protect_gui then
		syn.protect_gui(self.base)
		guiPar = game:GetService("CoreGui")
	else
		gethui = gethui or hiddenUI or get_hidden_gui or nil
		if gethui then
			getconnections = getconnections or get_signal_connections
			if getconnections then
				local succ_dc,dc = pcall(function()
					local conns = getconnections(game.DescendantAdded)
					local cnt
					if conns then
						cnt = #conns
						for i,v in pairs(conns) do
							v:Disconnect()
							cnt = cnt-1
						end
					end
					return cnt
				end)
				if succ_dc and dc and type(dc)=="number" and dc==0 then
					guiPar = gethui()
				end
			end
		end
	end
	if not guiPar then
		game:GetService"Players".LocalPlayer:Kick("Error: exploit does not support safe gui!")
		return
	end
	self.base.Parent = guiPar

	self.cursor = self.cursor or self:Create("Frame", {
		ZIndex = 100,
		AnchorPoint = Vector2.new(0, 0),
		Size = UDim2.new(0, 5, 0, 5),
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		Parent = self.base
	})
	
	for _, window in next, self.windows do
		if window.canInit and not window.init then
			window.init = true
			createOptionHolder(window.title, self.base, window)
			loadOptions(window)
		end
	end
end

function library:Close()
	self.open = not self.open
	self.cursor.Visible = self.open
	if self.activePopup then
		self.activePopup:Close()
	end
	for _, window in next, self.windows do
		if window.main then
			window.main.Visible = self.open
		end
	end
end

inputService.InputBegan:connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if library.activePopup then
			if input.Position.X < library.activePopup.mainHolder.AbsolutePosition.X or input.Position.Y < library.activePopup.mainHolder.AbsolutePosition.Y then
				library.activePopup:Close()
			end
		end
		if library.activePopup then
			if input.Position.X > library.activePopup.mainHolder.AbsolutePosition.X + library.activePopup.mainHolder.AbsoluteSize.X or input.Position.Y > library.activePopup.mainHolder.AbsolutePosition.Y + library.activePopup.mainHolder.AbsoluteSize.Y then
				library.activePopup:Close()
			end
		end
	end
end)

inputService.InputChanged:connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement and library.cursor then
		local mouse = inputService:GetMouseLocation() + Vector2.new(0, -36)
		library.cursor.Position = UDim2.new(0, mouse.X - 2, 0, mouse.Y - 2)
	end
	if input == dragInput and dragging then
		update(input)
	end
end)

return library