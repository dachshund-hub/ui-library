local DachshundUI = {}
DachshundUI.__index = DachshundUI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local DEFAULTS = {
    Theme = {
        MainBg = Color3.fromRGB(30, 30, 30),
        SideBg = Color3.fromRGB(28, 28, 28),
        CardBg = Color3.fromRGB(40, 40, 40),
        HoverBg = Color3.fromRGB(50, 50, 50),
        Accent = Color3.fromRGB(0, 120, 215),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(150, 150, 150),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        CornerRadius = 8,
        AnimDuration = 0.2,
        StrokeThickness = 1
    },
    Window = {
        Size = UDim2.new(0, 500, 0, 350),
        Position = UDim2.new(0.5, -250, 0.5, -175),
        TitleBarHeight = 35,
        SidebarWidth = 160
    },
    Card = {
        Height = 70,
        Padding = 10
    },
    Notification = {
        Duration = 3,
        MaxNotifications = 5
    }
}

local tooltips = {}
local function CreateTooltip(parent, text)
    local tooltip = Instance.new("Frame")
    tooltip.Size = UDim2.new(0, 150, 0, 30)
    tooltip.BackgroundColor3 = DEFAULTS.Theme.MainBg
    tooltip.BorderSizePixel = 0
    tooltip.Visible = false
    tooltip.ZIndex = 10
    tooltip.Parent = parent.Parent.Parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, DEFAULTS.Theme.CornerRadius / 2)
    corner.Parent = tooltip

    local stroke = Instance.new("UIStroke")
    stroke.Color = DEFAULTS.Theme.Accent
    stroke.Thickness = 1
    stroke.Parent = tooltip

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = DEFAULTS.Theme.Text
    label.TextSize = 12
    label.Font = DEFAULTS.Theme.Font
    label.TextWrapped = true
    label.Parent = tooltip

    return tooltip
end

local function ShowTooltip(tooltip, mousePos, elementPos)
    if not tooltip.Visible then
        tooltip.Position = UDim2.new(0, mousePos.X + 10, 0, mousePos.Y - 15)
        tooltip.Visible = true
        TweenService:Create(tooltip, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
    end
end

local function HideTooltip(tooltip)
    if tooltip.Visible then
        TweenService:Create(tooltip, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
        tooltip.Visible = false
    end
end

local function CreateRoundedFrame(options)
    options = options or {}
    local frame = Instance.new("Frame")
    frame.Size = options.Size or UDim2.new(1, 0, 1, 0)
    frame.Position = options.Position or UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = options.BgColor or DEFAULTS.Theme.CardBg
    frame.BorderSizePixel = 0
    frame.Parent = options.Parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, options.CornerRadius or DEFAULTS.Theme.CornerRadius)
    corner.Parent = frame

    if options.Stroke then
        local stroke = Instance.new("UIStroke")
        stroke.Color = options.StrokeColor or DEFAULTS.Theme.Accent
        stroke.Thickness = options.StrokeThickness or DEFAULTS.Theme.StrokeThickness
        stroke.Parent = frame
    end

    return frame
end

local function Animate(element, properties, duration)
    duration = duration or DEFAULTS.Theme.AnimDuration
    local tween = TweenService:Create(element, TweenInfo.new(duration, Enum.EasingStyle.Quad), properties)
    tween:Play()
    return tween
end

function DachshundUI:CreateWindow(options)
    options = options or {}
    local self = setmetatable({}, DachshundUI)
    self.Options = options

    if options.Theme then
        for key, value in pairs(options.Theme, DEFAULTS.Theme) do
            DEFAULTS.Theme[key] = value
        end
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = options.Name or "DachshundUI"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    self.ScreenGui = screenGui

    self.NotificationContainer = Instance.new("Frame")
    self.NotificationContainer.Size = UDim2.new(0, 300, 1, 0)
    self.NotificationContainer.Position = UDim2.new(1, -320, 0, 0)
    self.NotificationContainer.BackgroundTransparency = 1
    self.NotificationContainer.Parent = screenGui

    local notifList = Instance.new("UIListLayout")
    notifList.SortOrder = Enum.SortOrder.LayoutOrder
    notifList.Padding = UDim.new(0, 10)
    notifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
    notifList.Parent = self.NotificationContainer

    function self:Notify(message, type)
        type = type or "info"
        if #self.NotificationContainer:GetChildren() - 1 >= DEFAULTS.Notification.MaxNotifications then
            self.NotificationContainer:GetChildren()[2]:Destroy()
        end

        local notif = CreateRoundedFrame({
            Size = UDim2.new(1, 0, 0, 50),
            BgColor = type == "success" and Color3.fromRGB(0, 120, 0) or type == "error" and Color3.fromRGB(220, 50, 50) or DEFAULTS.Theme.MainBg,
            CornerRadius = 10,
            Stroke = true,
            Parent = self.NotificationContainer
        })
        notif.Position = UDim2.new(0, 0, 1, 0)
        notif.LayoutOrder = -1

        local notifLabel = Instance.new("TextLabel")
        notifLabel.Size = UDim2.new(1, -10, 1, 0)
        notifLabel.Position = UDim2.new(0, 5, 0, 0)
        notifLabel.BackgroundTransparency = 1
        notifLabel.Text = message
        notifLabel.TextColor3 = DEFAULTS.Theme.Text
        notifLabel.TextSize = 12
        notifLabel.Font = DEFAULTS.Theme.Font
        notifLabel.TextWrapped = true
        notifLabel.Parent = notif

        Animate(notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
        wait(DEFAULTS.Notification.Duration)
        Animate(notif, {Position = UDim2.new(0, 0, -60, 0)}, 0.3).Completed:Connect(function()
            notif:Destroy()
        end)
    end

    local winSize = options.Size or DEFAULTS.Window.Size
    local winPos = options.Position or DEFAULTS.Window.Position
    self.MainWindow = CreateRoundedFrame({
        Size = winSize,
        Position = winPos,
        BgColor = DEFAULTS.Theme.MainBg,
        CornerRadius = 12,
        Stroke = true,
        Parent = screenGui
    })

    self.MainWindow.Size = UDim2.new(0, 0, 0, 0)
    self.MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Animate(self.MainWindow, {
        Size = winSize,
        Position = winPos
    }, 0.4)

    self.TitleBar = CreateRoundedFrame({
        Size = UDim2.new(1, 0, 0, DEFAULTS.Window.TitleBarHeight),
        BgColor = Color3.fromRGB(25, 25, 25),
        CornerRadius = 12,
        Parent = self.MainWindow
    })

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = options.Title or "Dachshund UI"
    titleLabel.TextColor3 = DEFAULTS.Theme.Text
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = self.TitleBar

    local dragging, dragStart, startPos = false
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainWindow.Position
        end
    end)
    self.TitleBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.MainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    self.TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 25, 0, 25)
    minBtn.Position = UDim2.new(1, -55, 0.5, -12.5)
    minBtn.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    minBtn.Text = "-"
    minBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    minBtn.TextSize = 14
    minBtn.Font = DEFAULTS.Theme.Font
    minBtn.Parent = self.TitleBar

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 4)
    minCorner.Parent = minBtn

    minBtn.MouseEnter:Connect(function() Animate(minBtn, {BackgroundTransparency = 0.2}) end)
    minBtn.MouseLeave:Connect(function() Animate(minBtn, {BackgroundTransparency = 0}) end)
    minBtn.MouseButton1Click:Connect(function()
        Animate(self.MainWindow, {Size = UDim2.new(0, 0, 0, 0)}, 0.25).Completed:Connect(function()
            self.MainWindow.Visible = false
            self:Notify("Press H to restore", "info")
        end)
    end)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -25, 0.5, -12.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(232, 65, 53)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = DEFAULTS.Theme.Text
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = self.TitleBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeBtn

    closeBtn.MouseEnter:Connect(function() Animate(closeBtn, {BackgroundColor3 = Color3.fromRGB(220, 53, 69)}) end)
    closeBtn.MouseLeave:Connect(function() Animate(closeBtn, {BackgroundColor3 = Color3.fromRGB(232, 65, 53)}) end)
    closeBtn.MouseButton1Click:Connect(function()
        Animate(self.MainWindow, {Size = UDim2.new(0, 0, 0, 0)}, 0.25).Completed:Connect(function()
            screenGui:Destroy()
        end)
    end)

    self.Sidebar = CreateRoundedFrame({
        Size = UDim2.new(0, DEFAULTS.Window.SidebarWidth, 1, -DEFAULTS.Window.TitleBarHeight),
        Position = UDim2.new(0, 0, 0, DEFAULTS.Window.TitleBarHeight),
        BgColor = DEFAULTS.Theme.SideBg,
        Parent = self.MainWindow
    })

    self.ContentArea = Instance.new("ScrollingFrame")
    self.ContentArea.Size = UDim2.new(1, -DEFAULTS.Window.SidebarWidth, 1, -DEFAULTS.Window.TitleBarHeight)
    self.ContentArea.Position = UDim2.new(0, DEFAULTS.Window.SidebarWidth, 0, DEFAULTS.Window.TitleBarHeight)
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.BorderSizePixel = 0
    self.ContentArea.ScrollBarThickness = 4
    self.ContentArea.ScrollBarImageColor3 = DEFAULTS.Theme.Accent
    self.ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.ContentArea.Parent = self.MainWindow

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, DEFAULTS.Card.Padding)
    listLayout.Parent = self.ContentArea

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.ContentArea.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
    end)

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.H and not self.MainWindow.Visible then
            self.MainWindow.Visible = true
            self.MainWindow.Size = UDim2.new(0, 0, 0, 0)
            self.MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
            Animate(self.MainWindow, {
                Size = winSize,
                Position = winPos
            }, 0.4)
        end
    end)

    self.CardCounter = 0

    return self
end

function DachshundUI:AddCard(title, content, options)
    options = options or {}
    self.CardCounter = self.CardCounter + 1

    local card = CreateRoundedFrame({
        Size = UDim2.new(1, -20, 0, options.Height or DEFAULTS.Card.Height),
        BgColor = DEFAULTS.Theme.CardBg,
        CornerRadius = options.CornerRadius or DEFAULTS.Theme.CornerRadius,
        Parent = self.ContentArea
    })
    card.LayoutOrder = self.CardCounter
    card.BackgroundTransparency = 1
    card.Rotation = 0

    Animate(card, {BackgroundTransparency = 0, Rotation = 360}, 0.5)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.3, 0, 0.4, 0)
    titleLabel.Position = UDim2.new(0, DEFAULTS.Card.Padding, 0, DEFAULTS.Card.Padding / 2)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = DEFAULTS.Theme.Text
    titleLabel.TextSize = options.TextSize or DEFAULTS.Theme.TextSize
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = card

    if content then
        content.Parent = card
        content.Position = UDim2.new(0.3, 0, 0, DEFAULTS.Card.Padding / 2)
        content.Size = UDim2.new(0.7, -20, 0.6, 0)
    end

    card.MouseEnter:Connect(function()
        Animate(card, {BackgroundColor3 = DEFAULTS.Theme.HoverBg, Size = UDim2.new(1, -18, 0, options.Height or DEFAULTS.Card.Height + 5)}, options.Duration or DEFAULTS.Theme.AnimDuration)
    end)
    card.MouseLeave:Connect(function()
        Animate(card, {BackgroundColor3 = DEFAULTS.Theme.CardBg, Size = UDim2.new(1, -20, 0, options.Height or DEFAULTS.Card.Height)}, options.Duration or DEFAULTS.Theme.AnimDuration)
    end)

    return card
end

function DachshundUI:AddParagraph(text, options)
    options = options or {}
    local para = Instance.new("TextLabel")
    para.Size = UDim2.new(1, 0, 1, 0)
    para.BackgroundTransparency = 1
    para.Text = text
    para.TextColor3 = DEFAULTS.Theme.SubText
    para.TextSize = options.TextSize or 12
    para.Font = DEFAULTS.Theme.Font
    para.TextWrapped = true
    para.TextYAlignment = Enum.TextYAlignment.Top
    para.TextXAlignment = Enum.TextXAlignment.Left
    para.TextTransparency = 1

    self:AddCard("Paragraph", para, options)
    Animate(para, {TextTransparency = 0}, 0.3)
end

function DachshundUI:AddButton(text, callback, options)
    options = options or {}
    local btnFrame = Instance.new("Frame")
    btnFrame.Size = UDim2.new(1, 0, 1, 0)
    btnFrame.BackgroundTransparency = 1

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, 0, 0.8, 0)
    btn.Position = UDim2.new(0.1, 0, 0.1, 0)
    btn.BackgroundColor3 = DEFAULTS.Theme.Accent
    btn.Text = text
    btn.TextColor3 = DEFAULTS.Theme.Text
    btn.TextSize = options.TextSize or 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = btnFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local tooltip = nil
    if options.Tip then
        tooltip = CreateTooltip(self.ContentArea, options.Tip)
        local connection
        btn.MouseEnter:Connect(function()
            local mouse = player:GetMouse()
            ShowTooltip(tooltip, Vector2.new(mouse.X, mouse.Y), btn.AbsolutePosition)
            connection = RunService.Heartbeat:Connect(function()
                local mouse = player:GetMouse()
                ShowTooltip(tooltip, Vector2.new(mouse.X, mouse.Y), btn.AbsolutePosition)
            end)
        end)
        btn.MouseLeave:Connect(function()
            if connection then connection:Disconnect() end
            HideTooltip(tooltip)
        end)
    end

    local duration = options.Duration or DEFAULTS.Theme.AnimDuration
    btn.MouseEnter:Connect(function()
        Animate(btn, {Size = UDim2.new(0.85, 0, 0.85, 0), BackgroundColor3 = Color3.fromRGB(0, 140, 235)}, duration)
    end)
    btn.MouseLeave:Connect(function()
        Animate(btn, {Size = UDim2.new(0.8, 0, 0.8, 0), BackgroundColor3 = DEFAULTS.Theme.Accent}, duration)
    end)
    btn.MouseButton1Down:Connect(function()
        Animate(btn, {Size = UDim2.new(0.75, 0, 0.75, 0)}, 0.1)
    end)
    btn.MouseButton1Up:Connect(function()
        Animate(btn, {Size = UDim2.new(0.8, 0, 0.8, 0)}, 0.1)
    end)
    btn.MouseButton1Click:Connect(function()
        callback and callback()
        options.Notify and self:Notify(options.Notify, "success")
    end)

    self:AddCard("Button", btnFrame, options)
end

function DachshundUI:AddToggle(labelText, default, callback, options)
    options = options or {}
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 1, 0)
    toggleFrame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = DEFAULTS.Theme.Text
    label.TextSize = options.TextSize or DEFAULTS.Theme.TextSize
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 35, 0, 18)
    switch.Position = UDim2.new(1, -45, 0.5, -9)
    switch.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    switch.Text = ""
    switch.Parent = toggleFrame

    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(0, 9)
    switchCorner.Parent = switch

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = DEFAULTS.Theme.Text
    knob.Parent = switch

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(0, 7)
    knobCorner.Parent = knob

    local isOn = default or false
    local duration = options.Duration or DEFAULTS.Theme.AnimDuration

    local function UpdateToggle(on)
        isOn = on
        local targetPos = on and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        local targetColor = on and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(100, 100, 100)
        Animate(knob, {Position = targetPos}, duration)
        Animate(switch, {BackgroundColor3 = targetColor}, duration)
        if callback then callback(isOn) end
    end

    switch.MouseButton1Click:Connect(function() UpdateToggle(not isOn) end)
    UpdateToggle(isOn)

    self:AddCard("Toggle", toggleFrame, options)
end

function DachshundUI:AddSlider(labelText, min, max, default, callback, options)
    options = options or {}
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 1, 0)
    sliderFrame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 0.5, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = DEFAULTS.Theme.Text
    label.TextSize = options.TextSize or DEFAULTS.Theme.TextSize
    label.Font = Enum.Font.GothamSemibold
    label.Parent = sliderFrame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.2, 0, 0.5, 0)
    valueLabel.Position = UDim2.new(0.4, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default or min)
    valueLabel.TextColor3 = DEFAULTS.Theme.Text
    valueLabel.TextSize = 12
    valueLabel.Font = DEFAULTS.Theme.Font
    valueLabel.Parent = sliderFrame

    local sliderBar = CreateRoundedFrame({
        Size = UDim2.new(0.8, 0, 0.15, 0),
        Position = UDim2.new(0.1, 0, 0.5, 0),
        BgColor = Color3.fromRGB(60, 60, 60),
        CornerRadius = 4,
        Parent = sliderFrame
    })

    local sliderTrack = CreateRoundedFrame({
        Size = UDim2.new((default or min - min) / (max - min), 0, 1, 0),
        BgColor = DEFAULTS.Theme.Accent,
        CornerRadius = 4,
        Parent = sliderBar
    })

    local sliderThumb = Instance.new("TextButton")
    sliderThumb.Size = UDim2.new(0, 12, 1, 0)
    sliderThumb.Position = UDim2.new((default or min - min) / (max - min), -6, 0, 0)
    sliderThumb.BackgroundColor3 = DEFAULTS.Theme.Text
    sliderThumb.Text = ""
    sliderThumb.Parent = sliderBar

    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(0, 4)
    thumbCorner.Parent = sliderThumb

    local sliderDragging = false
    local currentValue = default or min

    sliderThumb.MouseButton1Down:Connect(function()
        sliderDragging = true
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = player:GetMouse()
            local relativeX = math.clamp((mouse.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
            currentValue = math.floor(min + (max - min) * relativeX)
            
            local duration = options.Duration or DEFAULTS.Theme.AnimDuration
            Animate(sliderTrack, {Size = UDim2.new(relativeX, 0, 1, 0)}, duration)
            Animate(sliderThumb, {Position = UDim2.new(relativeX, -6, 0, 0)}, duration)
            Animate(valueLabel, {TextTransparency = 0.5}, 0.1).Completed:Connect(function()
                valueLabel.Text = tostring(currentValue)
                Animate(valueLabel, {TextTransparency = 0}, 0.1)
            end)
            if callback then callback(currentValue) end
        end
    end)

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, 0, 0.3, 0)
    descLabel.Position = UDim2.new(0, 0, 0.7, 0)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = "Drag to adjust"
    descLabel.TextColor3 = DEFAULTS.Theme.SubText
    descLabel.TextSize = 11
    descLabel.Font = DEFAULTS.Theme.Font
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = sliderFrame

    self:AddCard("Slider", sliderFrame, options)
end

function DachshundUI:AddDropdown(labelText, optionsList, default, callback, options)
    options = options or {}
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(1, 0, 1, 0)
    dropdownFrame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = DEFAULTS.Theme.Text
    label.TextSize = options.TextSize or DEFAULTS.Theme.TextSize
    label.Font = Enum.Font.GothamSemibold
    label.Parent = dropdownFrame

    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Size = UDim2.new(1, 0, 0.5, 0)
    dropdownBtn.Position = UDim2.new(0, 0, 0.5, 0)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    dropdownBtn.Text = (default or optionsList[1] or "Select") .. " ▼"
    dropdownBtn.TextColor3 = DEFAULTS.Theme.Text
    dropdownBtn.TextSize = 12
    dropdownBtn.Font = DEFAULTS.Theme.Font
    dropdownBtn.Parent = dropdownFrame

    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 6)
    dropdownCorner.Parent = dropdownBtn

    local dropdownList = CreateRoundedFrame({
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 5),
        BgColor = Color3.fromRGB(60, 60, 60),
        CornerRadius = 6,
        Parent = dropdownFrame
    })
    dropdownList.Visible = false

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 1)
    listLayout.Parent = dropdownList

    local isOpen = false
    local duration = options.Duration or DEFAULTS.Theme.AnimDuration

    for _, opt in ipairs(optionsList or {}) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 20)
        optBtn.BackgroundTransparency = 1
        optBtn.Text = opt
        optBtn.TextColor3 = DEFAULTS.Theme.Text
        optBtn.TextSize = 12
        optBtn.Font = DEFAULTS.Theme.Font
        optBtn.Parent = dropdownList
        
        optBtn.MouseButton1Click:Connect(function()
            dropdownBtn.Text = opt .. " ▼"
            animateDropdown(false)
            if callback then callback(opt) end
        end)
    end

    local function animateDropdown(open)
        isOpen = open
        if open then
            dropdownList.Visible = true
            dropdownList.Size = UDim2.new(1, 0, 0, 0)
            Animate(dropdownList, {Size = UDim2.new(1, 0, 0, (#optionsList or 0) * 21)}, duration)
        else
            Animate(dropdownList, {Size = UDim2.new(1, 0, 0, 0)}, duration).Completed:Connect(function()
                dropdownList.Visible = false
            end)
        end
    end

    dropdownBtn.MouseEnter:Connect(function()
        Animate(dropdownBtn, {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}, duration)
    end)
    dropdownBtn.MouseLeave:Connect(function()
        Animate(dropdownBtn, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, duration)
    end)
    dropdownBtn.MouseButton1Click:Connect(function()
        animateDropdown(not isOpen)
    end)

    self:AddCard("Dropdown", dropdownFrame, options)
end

function DachshundUI:AddColorpicker(labelText, default, callback, options)
    options = options or {}
    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(1, 0, 1, 0)
    colorFrame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0.5, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = DEFAULTS.Theme.Text
    label.TextSize = options.TextSize or DEFAULTS.Theme.TextSize
    label.Font = Enum.Font.GothamSemibold
    label.Parent = colorFrame

    local colorSwatch = CreateRoundedFrame({
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(1, -35, 0.25, 0),
        BgColor = default or Color3.fromRGB(0, 255, 0),
        CornerRadius = 4,
        Parent = colorFrame
    })

    colorSwatch.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local newColor = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
            Animate(colorSwatch, {BackgroundColor3 = newColor}, 0.3)
            if callback then callback(newColor) end
        end
    end)

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, 0, 0.5, 0)
    descLabel.Position = UDim2.new(0, 0, 0.5, 0)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = "Click to change color"
    descLabel.TextColor3 = DEFAULTS.Theme.SubText
    descLabel.TextSize = 11
    descLabel.Font = DEFAULTS.Theme.Font
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = colorFrame

    self:AddCard("Colorpicker", colorFrame, options)
end

function DachshundUI:AddKeybind(labelText, default, callback, options)
    options = options or {}
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Size = UDim2.new(1, 0, 1, 0)
    keybindFrame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = DEFAULTS.Theme.Text
    label.TextSize = options.TextSize or DEFAULTS.Theme.TextSize
    label.Font = Enum.Font.GothamSemibold
    label.Parent = keybindFrame

    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0, 50, 0, 25)
    keyBtn.Position = UDim2.new(1, -60, 0.5, -12.5)
    keyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    keyBtn.Text = default or "MB1"
    keyBtn.TextColor3 = DEFAULTS.Theme.Text
    keyBtn.TextSize = 12
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.Parent = keybindFrame

    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 6)
    keyCorner.Parent = keyBtn

    keyBtn.MouseEnter:Connect(function()
        Animate(keyBtn, {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}, options.Duration or DEFAULTS.Theme.AnimDuration)
    end)
    keyBtn.MouseLeave:Connect(function()
        Animate(keyBtn, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, options.Duration or DEFAULTS.Theme.AnimDuration)
    end)

    local binding = false
    local pulse = nil

    keyBtn.MouseButton1Click:Connect(function()
        binding = true
        keyBtn.Text = "..."
        pulse = TweenService:Create(keyBtn, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Size = UDim2.new(0, 45, 0, 22.5)})
        pulse:Play()
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if binding and not gameProcessed then
            local keyName = input.KeyCode.Name
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                keyName = "MB2"
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                keyName = "MB1"
            end
            keyBtn.Text = keyName
            binding = false
            if pulse then
                pulse:Cancel()
                pulse = nil
            end
            Animate(keyBtn, {Size = UDim2.new(0, 50, 0, 25)}, 0.15)
            if callback then callback(keyName) end
        end
    end)

    self:AddCard("Keybind", keybindFrame, options)
end

function DachshundUI:AddInput(labelText, default, callback, options)
    options = options or {}
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, 0, 1, 0)
    inputFrame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = DEFAULTS.Theme.Text
    label.TextSize = options.TextSize or DEFAULTS.Theme.TextSize
    label.Font = Enum.Font.GothamSemibold
    label.Parent = inputFrame

    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0.6, 0, 0.7, 0)
    inputBox.Position = UDim2.new(0.4, 0, 0.15, 0)
    inputBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    inputBox.Text = default or ""
    inputBox.PlaceholderText = "Enter text..."
    inputBox.TextColor3 = DEFAULTS.Theme.Text
    inputBox.TextSize = 12
    inputBox.Font = DEFAULTS.Theme.Font
    inputBox.Parent = inputFrame

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = inputBox

    inputBox.Focused:Connect(function()
        Animate(inputBox, {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}, 0.15)
    end)
    inputBox.FocusLost:Connect(function()
        Animate(inputBox, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.15)
        if callback then callback(inputBox.Text) end
    end)

    self:AddCard("Input", inputFrame, options)
end

return DachshundUI
