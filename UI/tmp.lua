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