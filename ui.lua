local UI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local colors = {
    background = Color3.fromRGB(0, 0, 0),
    outline = Color3.fromRGB(0, 162, 255),
    text = Color3.fromRGB(0, 162, 255),
    accent = Color3.fromRGB(30, 30, 30),
    toggleOn = Color3.fromRGB(0, 162, 255),
    toggleOff = Color3.fromRGB(50, 50, 50),
    placeholder = Color3.fromRGB(100, 100, 100)
}
local function copyTable(t)
    local nt = {}
    for k, v in pairs(t) do
        nt[k] = type(v) == "table" and copyTable(v) or v
    end
    return nt
end
local function ApplyTheme(obj, colors)
    if not obj or not obj:IsA("GuiObject") then return end
    local bgType = obj:GetAttribute("bgType")
    if bgType then
        obj.BackgroundColor3 = colors[bgType]
    end
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        obj.TextColor3 = colors.text
    end
    if obj:IsA("UIStroke") then
        obj.Color = colors.outline
    end
    if obj:IsA("TextBox") then
        obj.PlaceholderColor3 = colors.placeholder
    end
    for _, child in pairs(obj:GetChildren()) do
        ApplyTheme(child, colors)
    end
end
local function animateIn(elem)
    elem.Position = UDim2.new(0.5, 0, 0.5, 0)
    elem.Size = UDim2.new(0, 0, 0, 0)
    elem.BackgroundTransparency = 1
    for _, child in pairs(elem:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
            child.TextTransparency = 1
        elseif child:IsA("Frame") and child.Parent == elem then
            child.BackgroundTransparency = 1
        end
    end
    local sizeTween = TweenService:Create(elem, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = elem:GetAttribute("originalSize") or UDim2.new(0, 300, 0, 400), Position = UDim2.new(0.5, -150, 0.5, -200)})
    local bgTween = TweenService:Create(elem, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 0})
    sizeTween:Play()
    bgTween:Play()
    for _, child in pairs(elem:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
            TweenService:Create(child, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
        elseif child:IsA("Frame") and child.Parent == elem then
            TweenService:Create(child, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
        end
    end
end
local function makeDraggable(frame)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            update(input)
        end
    end)
end
local function createFrame(parent, size, position, name)
    local frame = Instance.new("Frame")
    frame.Name = name or "Frame"
    frame.Size = size or UDim2.new(1, 0, 1, 0)
    frame.Position = position or UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = colors.background
    frame.BorderSizePixel = 0
    frame.Parent = parent
    frame:SetAttribute("bgType", "background")
   
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = frame
   
    local stroke = Instance.new("UIStroke")
    stroke.Color = colors.outline
    stroke.Thickness = 1
    stroke.Parent = frame
   
    return frame
end
local function createLabel(parent, text, size, position)
    local label = Instance.new("TextLabel")
    label.Size = size or UDim2.new(1, 0, 1, 0)
    label.Position = position or UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = colors.text
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end
local function createButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 30)
    button.Position = UDim2.new(0, 0, 0, 0)
    button.BackgroundColor3 = colors.accent
    button.BorderSizePixel = 0
    button.Text = ""
    button.TextColor3 = colors.text
    button.TextScaled = true
    button.Font = Enum.Font.Gotham
    button.Parent = parent
    button:SetAttribute("bgType", "accent")
   
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
   
    local stroke = Instance.new("UIStroke")
    stroke.Color = colors.outline
    stroke.Thickness = 1
    stroke.Parent = button
   
    local label = createLabel(button, text)
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
   
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local hoverTween = TweenService:Create(button, tweenInfo, {BackgroundColor3 = colors.outline})
    local normalTween = TweenService:Create(button, tweenInfo, {BackgroundColor3 = colors.accent})
   
    button.MouseEnter:Connect(function()
        hoverTween:Play()
    end)
   
    button.MouseLeave:Connect(function()
        normalTween:Play()
    end)
   
    button.Activated:Connect(function()
        callback()
        local clickTween = TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(0.98, 0, 0.95, 0)})
        clickTween:Play()
        clickTween.Completed:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        end)
    end)
   
    return button
end
local function createToggle(parent, text, defaultState, callback)
    local container = createFrame(parent, UDim2.new(1, 0, 0, 30))
    local label = createLabel(container, text .. ": ", UDim2.new(0.7, 0, 1, 0))
   
    local toggle = createFrame(container, UDim2.new(0, 40, 0.6, 0), UDim2.new(1, -50, 0.2, 0))
    toggle:SetAttribute("bgType", "toggleOff")
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0.5, 0)
    toggleCorner.Parent = toggle
   
    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = colors.outline
    toggleStroke.Thickness = 1
    toggleStroke.Parent = toggle
   
    local indicator = createFrame(toggle, UDim2.new(0.48, 0, 0.9, 0), UDim2.new(0.05, 0, 0.05, 0))
    indicator:SetAttribute("bgType", "background")
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0.5, 0)
    indicatorCorner.Parent = indicator
   
    local state = defaultState or false
    indicator.Position = UDim2.new(state and 0.9 or 0, 0, 0.05, 0)
    local function updateState()
        local targetColor = state and colors.toggleOn or colors.toggleOff
        local indColor = state and colors.toggleOn or colors.background
        TweenService:Create(toggle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(indicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = indColor}):Play()
        callback(state)
    end
   
    local dragStart, startPos
    toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position.X
            startPos = indicator.Position.X.Scale
        end
    end)
   
    toggle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragStart then
            local delta = (input.Position.X - dragStart) / toggle.AbsoluteSize.X
            local newPos = math.clamp(startPos + delta, 0, 0.9)
            indicator.Position = UDim2.new(newPos, 0, 0.05, 0)
        end
    end)
   
    toggle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local finalScale = indicator.Position.X.Scale
            state = finalScale > 0.45
            local targetPos = state and 0.9 or 0
            TweenService:Create(indicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(targetPos, 0, 0.05, 0)}):Play()
            updateState()
            dragStart = nil
        end
    end)
   
    updateState()
    return container, {state = state, updateState = updateState}
end
local function createSlider(parent, text, min, max, defaultValue, callback)
    local container = createFrame(parent, UDim2.new(1, 0, 0, 40))
    local label = createLabel(container, text .. ": " .. defaultValue, UDim2.new(1, 0, 0.4, 0))
   
    local track = createFrame(container, UDim2.new(1, -20, 0.2, 0), UDim2.new(0, 10, 0.6, 0))
    track:SetAttribute("bgType", "toggleOff")
    track.BackgroundColor3 = colors.toggleOff
   
    local fill = createFrame(track, UDim2.new((defaultValue - min) / (max - min), 0, 1, 0))
    fill:SetAttribute("bgType", "outline")
    fill.BackgroundColor3 = colors.outline
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = fill
   
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 2)
    trackCorner.Parent = track
   
    local thumb = createFrame(track, UDim2.new(0, 0, 1, 0), UDim2.new((defaultValue - min) / (max - min), -8, 0, -4))
    thumb.Size = UDim2.new(0, 16, 1, 8)
    thumb:SetAttribute("bgType", "outline")
    thumb.BackgroundColor3 = colors.outline
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(0, 8)
    thumbCorner.Parent = thumb
   
    local value = defaultValue or min
    local dragging = false
    local connectionChanged, connectionEnded
   
    local function updateValue(newValue)
        value = math.clamp(newValue, min, max)
        local percent = (value - min) / (max - min)
        TweenService:Create(fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
        TweenService:Create(thumb, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(percent, -8, 0, -4)}):Play()
        fill.BackgroundColor3 = colors.outline
        thumb.BackgroundColor3 = colors.outline
        TweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
        label.Text = text .. ": " .. math.floor(value * 100) / 100
        TweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
        callback(value)
    end
   
    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            updateValue(min + percent * (max - min))
            if connectionChanged then connectionChanged:Disconnect() end
            if connectionEnded then connectionEnded:Disconnect() end
            connectionChanged = UserInputService.InputChanged:Connect(onInputChanged)
            connectionEnded = UserInputService.InputEnded:Connect(onInputEnded)
        end
    end
   
    local function onInputChanged(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            updateValue(min + percent * (max - min))
        end
    end
   
    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            if connectionChanged then
                connectionChanged:Disconnect()
                connectionChanged = nil
            end
            if connectionEnded then
                connectionEnded:Disconnect()
                connectionEnded = nil
            end
        end
    end
   
    track.InputBegan:Connect(onInputBegan)
    track.InputChanged:Connect(onInputChanged)
    track.InputEnded:Connect(onInputEnded)
   
    updateValue(value)
    return container, {value = value, updateValue = updateValue}
end
local function createDropdown(parent, placeholder, options, callback)
    local container = createFrame(parent, UDim2.new(1, 0, 0, 30))
    local button = createButton(container, placeholder or "Select...")
    button:SetAttribute("bgType", "accent")
   
    local dropdownFrame = createFrame(container, UDim2.new(1, 0, 0, 0), UDim2.new(0, 0, 1, 5))
    dropdownFrame.Visible = false
    dropdownFrame.Size = UDim2.new(1, 0, 0, 0)
   
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 0)
    listLayout.Parent = dropdownFrame
   
    local curOptions = options
    local selected = placeholder or ""
    local function setSelected(opt)
        selected = opt
        local label = button:FindFirstChildOfClass("TextLabel")
        TweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
        label.Text = opt
        TweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
        dropdownFrame.Visible = false
        callback(opt)
    end
    local function updateOptions(newOptions)
        curOptions = newOptions
        for _, child in pairs(dropdownFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        for i, option in ipairs(newOptions) do
            local optButton = createButton(dropdownFrame, option, function()
                setSelected(option)
            end)
        end
        dropdownFrame.Size = UDim2.new(1, 0, 0, math.min(#newOptions * 30, 150))
    end
   
    for i, option in ipairs(options) do
        local optButton = createButton(dropdownFrame, option, function()
            setSelected(option)
        end)
    end
   
    local open = false
    local outsideConnection
    button.Activated:Connect(function()
        open = not open
        if open then
            dropdownFrame.Visible = true
            dropdownFrame.Size = UDim2.new(1, 0, 0, 0)
            TweenService:Create(dropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, math.min(#options * 30, 150))}):Play()
            outsideConnection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local target = UserInputService:GetMouseLocation()
                    local absPos = dropdownFrame.AbsolutePosition
                    local absSize = dropdownFrame.AbsoluteSize
                    if not (target.X >= absPos.X and target.X <= absPos.X + absSize.X and
                            target.Y >= absPos.Y and target.Y <= absPos.Y + absSize.Y) and
                       not (button.AbsolutePosition.X <= target.X and target.X <= button.AbsolutePosition.X + button.AbsoluteSize.X and
                            button.AbsolutePosition.Y <= target.Y and target.Y <= button.AbsolutePosition.Y + button.AbsoluteSize.Y) then
                        TweenService:Create(dropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                        dropdownFrame.Visible = false
                        open = false
                        if outsideConnection then
                            outsideConnection:Disconnect()
                            outsideConnection = nil
                        end
                    end
                end
            end)
        else
            TweenService:Create(dropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, 0)}):Play()
            dropdownFrame.Visible = false
            if outsideConnection then
                outsideConnection:Disconnect()
                outsideConnection = nil
            end
        end
    end)
   
    local dropObj = {selected = selected, setSelected = setSelected, updateOptions = updateOptions, getValue = function() return selected end}
    return container, dropObj
end
local function createMultiSelector(parent, placeholder, options, defaultSelected, callback)
    local container = createFrame(parent, UDim2.new(1, 0, 0, 30))
    local button = createButton(container, placeholder or "Select...")
    button:SetAttribute("bgType", "accent")
   
    local selected = copyTable(defaultSelected or {})
    local function updateLabel()
        local selText = #selected > 0 and table.concat(selected, ", ") or placeholder
        if #selText > 20 then selText = string.sub(selText, 1, 20) .. "..." end
        local label = button:FindFirstChildOfClass("TextLabel")
        TweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
        label.Text = selText
        TweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
        callback(selected)
    end
   
    local dropdownFrame = createFrame(container, UDim2.new(1, 0, 0, 0), UDim2.new(0, 0, 1, 5))
    dropdownFrame.Visible = false
    dropdownFrame.Size = UDim2.new(1, 0, 0, 0)
   
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 0)
    listLayout.Parent = dropdownFrame
   
    local optElements = {}
    for i, option in ipairs(options) do
        local optContainer = createFrame(dropdownFrame, UDim2.new(1, 0, 0, 30))
        createLabel(optContainer, option, UDim2.new(0.8, 0, 1, 0))
       
        local check = createFrame(optContainer, UDim2.new(0, 20, 0.6, 0), UDim2.new(1, -30, 0.2, 0))
        check:SetAttribute("bgType", "background")
        local checkCorner = Instance.new("UICorner")
        checkCorner.CornerRadius = UDim.new(0, 3)
        checkCorner.Parent = check
       
        local isSelected = table.find(selected, option) ~= nil
        check.BackgroundColor3 = isSelected and colors.toggleOn or colors.background
       
        optElements[i] = {option = option, check = check}
       
        optContainer.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isSelected = not isSelected
                if isSelected then
                    table.insert(selected, option)
                else
                    for j, v in ipairs(selected) do
                        if v == option then
                            table.remove(selected, j)
                            break
                        end
                    end
                end
                local targetCheckColor = isSelected and colors.toggleOn or colors.background
                TweenService:Create(check, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetCheckColor}):Play()
                updateLabel()
            end
        end)
    end
   
    local function updateChecks()
        for _, el in ipairs(optElements) do
            local isSel = table.find(selected, el.option) ~= nil
            local targetColor = isSel and colors.toggleOn or colors.background
            TweenService:Create(el.check, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor}):Play()
        end
        updateLabel()
    end
   
    local open = false
    local outsideConnection
    button.Activated:Connect(function()
        open = not open
        if open then
            dropdownFrame.Visible = true
            dropdownFrame.Size = UDim2.new(1, 0, 0, 0)
            TweenService:Create(dropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, math.min(#options * 30, 150))}):Play()
            outsideConnection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local target = UserInputService:GetMouseLocation()
                    local absPos = dropdownFrame.AbsolutePosition
                    local absSize = dropdownFrame.AbsoluteSize
                    if not (target.X >= absPos.X and target.X <= absPos.X + absSize.X and
                            target.Y >= absPos.Y and target.Y <= absPos.Y + absSize.Y) and
                       not (button.AbsolutePosition.X <= target.X and target.X <= button.AbsolutePosition.X + button.AbsoluteSize.X and
                            button.AbsolutePosition.Y <= target.Y and target.Y <= button.AbsolutePosition.Y + button.AbsoluteSize.Y) then
                        TweenService:Create(dropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                        dropdownFrame.Visible = false
                        open = false
                        if outsideConnection then
                            outsideConnection:Disconnect()
                            outsideConnection = nil
                        end
                    end
                end
            end)
        else
            TweenService:Create(dropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, 0)}):Play()
            dropdownFrame.Visible = false
            if outsideConnection then
                outsideConnection:Disconnect()
                outsideConnection = nil
            end
        end
    end)
   
    local multiObj = {selected = selected, getValue = function() return copyTable(selected) end, setValue = function(newSel)
        selected = copyTable(newSel)
        updateChecks()
        callback(selected)
    end}
    updateLabel()
    return container, multiObj
end
local function createKeybind(parent, flag, callback, defaultKey)
    local container = createFrame(parent, UDim2.new(1, 0, 0, 30))
    local label = createLabel(container, flag .. ": ", UDim2.new(0.7, 0, 1, 0))
   
    local keyLabel = createLabel(container, "", UDim2.new(0.25, 0, 1, 0), UDim2.new(0.75, 0, 0, 0))
    keyLabel.BackgroundTransparency = 0
    keyLabel.BackgroundColor3 = colors.accent
    keyLabel.Size = UDim2.new(0, 60, 0.8, 0)
    keyLabel.Position = UDim2.new(0.7, 0, 0.1, 0)
    keyLabel:SetAttribute("bgType", "accent")
    keyLabel.TextXAlignment = Enum.TextXAlignment.Center
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 4)
    keyCorner.Parent = keyLabel
   
    local binding = false
    local currentKey = defaultKey or Enum.KeyCode.Unknown
    local function setKey(key)
        currentKey = key
        TweenService:Create(keyLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
        keyLabel.Text = key.Name or "None"
        TweenService:Create(keyLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
        callback(key)
    end
   
    keyLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            binding = true
            keyLabel.Text = "..."
        end
    end)
   
    local keyConnection
    keyConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if binding and not gameProcessed and input.KeyCode ~= Enum.KeyCode.Unknown then
            setKey(input.KeyCode)
            binding = false
            keyConnection:Disconnect()
        end
    end)
   
    setKey(currentKey)
    return container, {getValue = function() return currentKey end, setValue = setKey}
end
local function createTextBox(parent, placeholder, defaultText, callback)
    local textbox = Instance.new("TextBox")
    textbox.Size = UDim2.new(1, 0, 0, 30)
    textbox.Position = UDim2.new(0, 0, 0, 0)
    textbox.BackgroundColor3 = colors.accent
    textbox.BorderSizePixel = 0
    textbox.Text = defaultText or ""
    textbox.PlaceholderText = placeholder or "Enter text..."
    textbox.TextColor3 = colors.text
    textbox.PlaceholderColor3 = colors.placeholder
    textbox.TextScaled = true
    textbox.Font = Enum.Font.Gotham
    textbox.ClearTextOnFocus = false
    textbox.Parent = parent
    textbox:SetAttribute("bgType", "accent")
   
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = textbox
   
    local stroke = Instance.new("UIStroke")
    stroke.Color = colors.outline
    stroke.Thickness = 1
    stroke.Parent = textbox
   
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local focusTween = TweenService:Create(textbox, tweenInfo, {BackgroundColor3 = colors.outline})
    local normalTween = TweenService:Create(textbox, tweenInfo, {BackgroundColor3 = colors.accent})
   
    textbox.Focused:Connect(function()
        focusTween:Play()
    end)
   
    textbox.FocusLost:Connect(function(enterPressed)
        normalTween:Play()
        if enterPressed then
            callback(textbox.Text)
        end
    end)
   
    local tbObj = {getValue = function() return textbox.Text end, setValue = function(v) textbox.Text = v; callback(v) end}
    return textbox, tbObj
end
local Tab = {}
Tab.__index = Tab
function Tab.new(parent, name, isSub, window)
    local self = setmetatable({}, Tab)
    self.Name = name
    self.Parent = parent
    self.IsSub = isSub or false
    self.window = window
    self.Content = createFrame(parent, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0))
    self.Content.Visible = false
    self.ScrollingFrame = Instance.new("ScrollingFrame")
    self.ScrollingFrame.Name = "Content"
    self.ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    self.ScrollingFrame.Position = UDim2.new(0, 0, 0, 0)
    self.ScrollingFrame.BackgroundTransparency = 1
    self.ScrollingFrame.BorderSizePixel = 0
    self.ScrollingFrame.ScrollBarThickness = 6
    self.ScrollingFrame.ScrollBarImageColor3 = colors.outline
    self.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.ScrollingFrame.Parent = self.Content
   
    self.UIListLayout = Instance.new("UIListLayout")
    self.UIListLayout.Padding = UDim.new(0, 5)
    self.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    self.UIListLayout.Parent = self.ScrollingFrame
   
    self.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, self.UIListLayout.AbsoluteContentSize.Y + 10)
    end)
    return self
end
function Tab:AddLabel(text)
    local lbl = createLabel(self.ScrollingFrame, text)
    local lblTween = TweenService:Create(lbl, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})
    lblTween:Play()
    return lbl
end
function Tab:AddButton(text, callback)
    local btn = createButton(self.ScrollingFrame, text, callback)
    local btnTween = TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})
    btnTween:Play()
    return btn
end
function Tab:AddToggle(text, defaultState, callback)
    local container, toggleData = createToggle(self.ScrollingFrame, text, defaultState, callback)
    local obj = {getValue = function() return toggleData.state end, setValue = function(v) toggleData.state = v; toggleData.updateState() end}
    table.insert(self.window.toggles, obj)
    local containerTween = TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})
    containerTween:Play()
    return container, obj
end
function Tab:AddSlider(text, min, max, defaultValue, callback)
    local container, sliderData = createSlider(self.ScrollingFrame, text, min, max, defaultValue, callback)
    local obj = {getValue = function() return sliderData.value end, setValue = function(v) sliderData.updateValue(v) end}
    table.insert(self.window.sliders, obj)
    local containerTween = TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})
    containerTween:Play()
    return container, obj
end
function Tab:AddDropdown(placeholder, options, callback)
    local container, dropData = createDropdown(self.ScrollingFrame, placeholder, options, callback)
    local obj = dropData
    table.insert(self.window.dropdowns, obj)
    local containerTween = TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})
    containerTween:Play()
    return container, obj
end
function Tab:AddMultiSelector(placeholder, options, defaultSelected, callback)
    local container, multiData = createMultiSelector(self.ScrollingFrame, placeholder, options, defaultSelected, callback)
    local obj = multiData
    table.insert(self.window.multis, obj)
    local containerTween = TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})
    containerTween:Play()
    return container, obj
end
function Tab:AddKeybind(flag, callback, defaultKey)
    local container, keyData = createKeybind(self.ScrollingFrame, flag, callback, defaultKey)
    local obj = keyData
    table.insert(self.window.keybinds, obj)
    local containerTween = TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})
    containerTween:Play()
    return container, obj
end
function Tab:AddTextBox(placeholder, defaultText, callback)
    local tb, tbObj = createTextBox(self.ScrollingFrame, placeholder, defaultText, callback)
    table.insert(self.window.textboxes, tbObj)
    local tbTween = TweenService:Create(tb, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})
    tbTween:Play()
    return tb, tbObj
end
function Tab:AddTab(name)
    local subContainer = createFrame(self.ScrollingFrame, UDim2.new(1, 0, 0, 200))
    local subLayout = Instance.new("UIListLayout")
    subLayout.Parent = subContainer
    local subTabBar = createFrame(subContainer, UDim2.new(1, 0, 0, 30))
    subTabBar:SetAttribute("bgType", "accent")
    subTabBar.BackgroundColor3 = colors.accent
    local subTabLabel = createLabel(subTabBar, name)
    local subContent = createFrame(subContainer, UDim2.new(1, 0, 1, -30), UDim2.new(0, 0, 0, 30))
    local subTab = Tab.new(subContent, name, true, self.window)
    local subTween = TweenService:Create(subContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})
    subTween:Play()
    return subTab
end
function UI:CreateWindow(title, size, position)
    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
   
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UILibraryWindow"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
   
    local mainFrame = createFrame(screenGui, UDim2.new(0, 0, 0, 0), UDim2.new(0.5, 0, 0.5, 0), "Window")
    mainFrame:SetAttribute("originalSize", size or UDim2.new(0, 300, 0, 400))
    mainFrame:SetAttribute("originalPosition", position or UDim2.new(0.5, -150, 0.5, -200))
   
    local titleLabel = createLabel(mainFrame, title, UDim2.new(1, -70, 0, 40), UDim2.new(0, 10, 0, 0))
    titleLabel.BackgroundTransparency = 0
    titleLabel.BackgroundColor3 = colors.accent
    titleLabel:SetAttribute("bgType", "accent")
    makeDraggable(titleLabel)
   
    local closeButton = createButton(mainFrame, "X", function()
        local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 0, 0, 0)})
        closeTween:Play()
        closeTween.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end)
    closeButton.BackgroundColor3 = colors.toggleOn
    closeButton:SetAttribute("bgType", "toggleOn")
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0, 10)
   
    local tabBar = createFrame(mainFrame, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 40))
    tabBar.BackgroundColor3 = colors.accent
    tabBar:SetAttribute("bgType", "accent")
   
    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.FillDirection = Enum.FillDirection.Horizontal
    tabListLayout.Padding = UDim.new(0, 5)
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Parent = tabBar
   
    local contentContainer = createFrame(mainFrame, UDim2.new(1, 0, 1, -70), UDim2.new(0, 0, 0, 70))
   
    local notificationsContainer = Instance.new("Frame")
    notificationsContainer.Name = "Notifications"
    notificationsContainer.Size = UDim2.new(0, 0, 0, 0)
    notificationsContainer.Position = UDim2.new(1, -300, 1, -10)
    notificationsContainer.AnchorPoint = Vector2.new(1, 1)
    notificationsContainer.BackgroundTransparency = 1
    notificationsContainer.Parent = screenGui
   
    local notifListLayout = Instance.new("UIListLayout")
    notifListLayout.Padding = UDim.new(0, 5)
    notifListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notifListLayout.Parent = notificationsContainer
   
    notifListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        notificationsContainer.Size = UDim2.new(0, 290, 0, notifListLayout.AbsoluteContentSize.Y + 10)
    end)
   
    local tabs = {}
    local currentTab = nil
    local hasSettings = false
    local settingsTab = nil
    local window = {
        screenGui = screenGui,
        toggles = {},
        sliders = {},
        dropdowns = {},
        multis = {},
        keybinds = {},
        textboxes = {},
        configs = {},
        Notify = function(self, title, description, duration)
            duration = duration or 5
            local notif = createFrame(notificationsContainer, UDim2.new(1, 0, 0, 50))
            local titleLabel = createLabel(notif, title, UDim2.new(1, 0, 0, 20), UDim2.new(0, 5, 0, 5))
            titleLabel.TextScaled = false
            titleLabel.TextSize = 14
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.TextYAlignment = Enum.TextYAlignment.Top
            local descLabel = createLabel(notif, description, UDim2.new(1, -10, 0, 20), UDim2.new(0, 5, 0, 25))
            descLabel.TextScaled = false
            descLabel.TextSize = 12
            descLabel.Font = Enum.Font.Gotham
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.TextYAlignment = Enum.TextYAlignment.Top
            descLabel.TextWrapped = true
            local progressBar = createFrame(notif, UDim2.new(1, -10, 0, 4), UDim2.new(0, 5, 1, -9))
            progressBar:SetAttribute("bgType", "toggleOff")
            local progressFill = createFrame(progressBar, UDim2.new(0, 0, 1, 0))
            progressFill:SetAttribute("bgType", "toggleOn")
            local progressCorner = Instance.new("UICorner")
            progressCorner.CornerRadius = UDim.new(1, 0)
            progressCorner.Parent = progressBar
            local fillCorner = progressCorner:Clone()
            fillCorner.Parent = progressFill
            local startPos = notif.Position
            notif.Position = UDim2.new(1, 0, startPos.Y.Scale, startPos.Y.Offset)
            local slideIn = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = startPos})
            slideIn:Play()
            local progressTween = TweenService:Create(progressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 1, 0)})
            progressTween:Play()
            spawn(function()
                wait(duration)
                local slideOut = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 0, startPos.Y.Scale, startPos.Y.Offset)})
                slideOut:Play()
                slideOut.Completed:Connect(function()
                    notif:Destroy()
                end)
            end)
        end,
        AddTab = function(name)
            if name == "Settings" then return end
            local tab = Tab.new(contentContainer, name, false, window)
            if not hasSettings then
                hasSettings = true
                table.insert(tabs, tab)
                settingsTab = Tab.new(contentContainer, "Settings", false, window)
                table.insert(tabs, settingsTab)
                setupSettingsTab()
            else
                table.insert(tabs, #tabs - 1, tab)
            end
            local tabButton = createButton(tabBar, name, function()
                switchTab(tab)
            end)
            local btnLabel = tabButton:FindFirstChildOfClass("TextLabel")
            tabButton.Size = UDim2.new(0, btnLabel.TextBounds.X + 20, 1, 0)
            if #tabs == 2 then
                switchTab(tabs[1])
            end
            return tab
        end,
        GetConfigData = function(self)
            local data = {
                toggles = {},
                sliders = {},
                dropdowns = {},
                multis = {},
                keybinds = {},
                textboxes = {}
            }
            for i, obj in ipairs(self.toggles) do
                data.toggles[i] = obj.getValue()
            end
            for i, obj in ipairs(self.sliders) do
                data.sliders[i] = obj.getValue()
            end
            for i, obj in ipairs(self.dropdowns) do
                data.dropdowns[i] = obj.getValue()
            end
            for i, obj in ipairs(self.multis) do
                data.multis[i] = obj.getValue()
            end
            for i, obj in ipairs(self.keybinds) do
                data.keybinds[i] = obj.getValue()
            end
            for i, obj in ipairs(self.textboxes) do
                data.textboxes[i] = obj.getValue()
            end
            return data
        end,
        LoadConfig = function(self, name)
            local data = self.configs[name]
            if not data then return end
            for i, v in ipairs(data.toggles or {}) do
                if self.toggles[i] then self.toggles[i].setValue(v) end
            end
            for i, v in ipairs(data.sliders or {}) do
                if self.sliders[i] then self.sliders[i].setValue(v) end
            end
            for i, v in ipairs(data.dropdowns or {}) do
                if self.dropdowns[i] then self.dropdowns[i].setSelected(v) end
            end
            for i, v in ipairs(data.multis or {}) do
                if self.multis[i] then self.multis[i].setValue(v) end
            end
            for i, v in ipairs(data.keybinds or {}) do
                if self.keybinds[i] then self.keybinds[i].setValue(v) end
            end
            for i, v in ipairs(data.textboxes or {}) do
                if self.textboxes[i] then self.textboxes[i].setValue(v) end
            end
        end,
        UpdateSpecial = function(self)
            for _, obj in ipairs(self.toggles) do
                obj.setValue(obj.getValue())
            end
            for _, obj in ipairs(self.sliders) do
                obj.setValue(obj.getValue())
            end
            for _, obj in ipairs(self.multis) do
                obj.setValue(obj.getValue())
            end
        end,
        Destroy = function(self)
            local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 0, 0, 0)})
            closeTween:Play()
            closeTween.Completed:Connect(function()
                screenGui:Destroy()
            end)
        end
    }
    function setupSettingsTab()
        local colorNames = {"background", "outline", "text", "accent", "toggleOn", "toggleOff", "placeholder"}
        for _, cname in ipairs(colorNames) do
            settingsTab:AddLabel(cname:upper())
            local r = math.floor(colors[cname].R * 255 + 0.5)
            local g = math.floor(colors[cname].G * 255 + 0.5)
            local b = math.floor(colors[cname].B * 255 + 0.5)
            settingsTab:AddSlider("Red", 0, 255, r, function(val)
                r = val
                colors[cname] = Color3.fromRGB(r, g, b)
                ApplyTheme(window.screenGui, colors)
                window:UpdateSpecial()
            end)
            settingsTab:AddSlider("Green", 0, 255, g, function(val)
                g = val
                colors[cname] = Color3.fromRGB(r, g, b)
                ApplyTheme(window.screenGui, colors)
                window:UpdateSpecial()
            end)
            settingsTab:AddSlider("Blue", 0, 255, b, function(val)
                b = val
                colors[cname] = Color3.fromRGB(r, g, b)
                ApplyTheme(window.screenGui, colors)
                window:UpdateSpecial()
            end)
        end
        settingsTab:AddLabel("Config Manager")
        local nameTB, _ = settingsTab:AddTextBox("Config Name", "", function() end)
        settingsTab:AddButton("Save Config", function()
            local name = nameTB.Text
            if name == "" then return end
            window.configs[name] = window:GetConfigData()
            updateConfigDropdown()
        end)
        local container, configDropObj = settingsTab:AddDropdown("Select Config to Load", {}, function(name)
            window:LoadConfig(name)
        end)
        local function updateConfigDropdown()
            local names = {}
            for k in pairs(window.configs) do
                table.insert(names, k)
            end
            table.sort(names)
            configDropObj.updateOptions(names)
            configDropObj.setSelected("")
        end
        settingsTab:AddButton("Delete Selected", function()
            local name = configDropObj.selected
            if name and window.configs[name] then
                window.configs[name] = nil
                updateConfigDropdown()
            end
        end)
    end
   
    local function switchTab(tab)
        local oldTab = currentTab
        currentTab = tab
        if oldTab then
            oldTab.Content.Visible = true
            local leaveTween = TweenService:Create(oldTab.Content, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(-1, 0, 0, 0)})
            leaveTween:Play()
            leaveTween.Completed:Connect(function()
                oldTab.Content.Visible = false
                oldTab.Content.Position = UDim2.new(0, 0, 0, 0)
            end)
        end
        tab.Content.Position = oldTab and UDim2.new(1, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
        tab.Content.Visible = true
        if oldTab then
            local enterTween = TweenService:Create(tab.Content, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 0, 0, 0)})
            enterTween:Play()
        end
    end
   
    animateIn(mainFrame)
    return window
end
function UI:CreateButton(parent, text, callback)
    return createButton(parent, text, callback)
end
function UI:CreateToggle(parent, text, defaultState, callback)
    return createToggle(parent, text, defaultState, callback)
end
function UI:CreateSlider(parent, text, min, max, defaultValue, callback)
    return createSlider(parent, text, min, max, defaultValue, callback)
end
function UI:CreateDropdown(parent, placeholder, options, callback)
    return createDropdown(parent, placeholder, options, callback)
end
function UI:CreateMultiSelector(parent, placeholder, options, defaultSelected, callback)
    return createMultiSelector(parent, placeholder, options, defaultSelected, callback)
end
function UI:CreateKeybind(parent, flag, callback, defaultKey)
    return createKeybind(parent, flag, callback, defaultKey)
end
function UI:CreateTextBox(parent, placeholder, defaultText, callback)
    return createTextBox(parent, placeholder, defaultText, callback)
end
function UI:LoadConfig(jsonString)
    local success, config = pcall(function()
        return HttpService:JSONDecode(jsonString)
    end)
    if success then
        return config
    else
        warn("Failed to load config: " .. tostring(config))
        return {}
    end
end
function UI:SaveConfig(config)
    local success, json = pcall(function()
        return HttpService:JSONEncode(config)
    end)
    if success then
        return json
    else
        warn("Failed to save config: " .. tostring(json))
        return nil
    end
end
return UI
