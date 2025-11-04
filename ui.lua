-- UI Library
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local UIDebugMode = false -- user sets this before calling library

local UILib = {}
UILib.Windows = {}

local function debugPrint(...)
    if UIDebugMode then
        print("[UI DEBUG]:", ...)
    end
end

local function create(instance, props)
    local obj = Instance.new(instance)
    for k,v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

local function createTween(obj, props, duration, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.Out
    local tween = TweenService:Create(obj, TweenInfo.new(duration or 0.3, style, dir), props)
    tween:Play()
    return tween
end

local function dragify(frame)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                   startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function UILib:CreateWindow(options)
    options = options or {}
    local title = options.Title or "Dachshund Hub"
    local bgColor = options.BackgroundColor or Color3.fromRGB(0,0,0)
    local outlineColor = options.OutlineColor or Color3.fromRGB(0,162,255)
    local textColor = options.TextColor or Color3.fromRGB(255,255,255)
    local size = options.Size or UDim2.new(0, 500, 0, 350)

    local screenGui = create("ScreenGui",{Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"), ResetOnSpawn = false})
    local window = create("Frame",{
        Parent = screenGui,
        BackgroundColor3 = bgColor,
        BorderColor3 = outlineColor,
        BorderSizePixel = 2,
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        ClipsDescendants = true
    })
    window.Name = "DachshundHubWindow"
    window.AnchorPoint = Vector2.new(0.5,0.5)
    window.Visible = true
    window.AutoButtonColor = false
    dragify(window)

    local titleLabel = create("TextLabel",{
        Parent = window,
        Text = title,
        Size = UDim2.new(1,0,0,30),
        BackgroundTransparency = 1,
        TextColor3 = textColor,
        Font = Enum.Font.SourceSansBold,
        TextSize = 20
    })

    local tabsFrame = create("Frame",{
        Parent = window,
        BackgroundColor3 = bgColor,
        BorderSizePixel = 0,
        Size = UDim2.new(0,120,1,-30),
        Position = UDim2.new(0,0,0,30)
    })

    local divider = create("Frame",{
        Parent = window,
        BackgroundColor3 = outlineColor,
        BorderSizePixel = 0,
        Size = UDim2.new(0,2,1,-30),
        Position = UDim2.new(0,120,0,30)
    })

    local contentFrame = create("Frame",{
        Parent = window,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -122, 1, -30),
        Position = UDim2.new(0,122,0,30)
    })

    local windowTable = {
        ScreenGui = screenGui,
        Window = window,
        TabsFrame = tabsFrame,
        Divider = divider,
        ContentFrame = contentFrame,
        Tabs = {}
    }

    function windowTable:AddTab(name)
        local button = create("TextButton",{
            Parent = self.TabsFrame,
            Text = name,
            Size = UDim2.new(1,0,0,30),
            BackgroundTransparency = 1,
            TextColor3 = textColor,
            Font = Enum.Font.SourceSansBold,
            TextSize = 16
        })
        local tabFrame = create("Frame",{
            Parent = self.ContentFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,1,0),
            Visible = false
        })
        button.MouseButton1Click:Connect(function()
            for _,v in pairs(self.Tabs) do
                v.Frame.Visible = false
            end
            tabFrame.Visible = true
        end)
        table.insert(self.Tabs,{Button = button, Frame = tabFrame})
        return tabFrame
    end

    function windowTable:Toggle(options)
        options = options or {}
        local name = options.Text or "Toggle"
        local callback = options.Callback or function() end
        local toggleFrame = create("Frame",{Parent = options.Parent or self.ContentFrame, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,30)})
        local toggleButton = create("TextButton",{Parent = toggleFrame, Text = "[ ] "..name, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextColor3 = textColor, Font = Enum.Font.SourceSans, TextSize = 16})
        local toggled = false
        toggleButton.MouseButton1Click:Connect(function()
            toggled = not toggled
            toggleButton.Text = (toggled and "[X] " or "[ ] ")..name
            pcall(callback,toggled)
        end)
    end

    function windowTable:Slider(options)
        options = options or {}
        local sliderFrame = create("Frame",{Parent = options.Parent or self.ContentFrame, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,40)})
        local sliderLabel = create("TextLabel",{Parent = sliderFrame, Text = options.Text or "Slider", Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, TextColor3 = textColor, Font = Enum.Font.SourceSans, TextSize = 16})
        local sliderBar = create("Frame",{Parent = sliderFrame, BackgroundColor3 = outlineColor, Size = UDim2.new(1,0,0,4), Position = UDim2.new(0,0,0,25)})
        local sliderFill = create("Frame",{Parent = sliderBar, BackgroundColor3 = textColor, Size = UDim2.new(0,0,1,0)})
        local min = options.Min or 0
        local max = options.Max or 100
        local callback = options.Callback or function() end
        sliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local function updateSlider(x)
                    local relativeX = math.clamp(x - sliderBar.AbsolutePosition.X,0,sliderBar.AbsoluteSize.X)
                    local value = min + (max-min)*(relativeX/sliderBar.AbsoluteSize.X)
                    sliderFill.Size = UDim2.new(relativeX/sliderBar.AbsoluteSize.X,0,1,0)
                    pcall(callback,value)
                end
                updateSlider(UserInputService:GetMouseLocation().X)
                local conn
                conn = UserInputService.InputChanged:Connect(function(input2)
                    if input2.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input2.Position.X)
                    end
                end)
                local upConn
                upConn = UserInputService.InputEnded:Connect(function(input2)
                    if input2.UserInputType == Enum.UserInputType.MouseButton1 then
                        conn:Disconnect()
                        upConn:Disconnect()
                    end
                end)
            end
        end)
    end

    function windowTable:Button(options)
        options = options or {}
        local buttonFrame = create("Frame",{Parent = options.Parent or self.ContentFrame, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,30)})
        local button = create("TextButton",{Parent = buttonFrame, Text = options.Text or "Button", Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextColor3 = textColor, Font = Enum.Font.SourceSans, TextSize = 16})
        button.MouseButton1Click:Connect(function()
            pcall(options.Callback)
        end)
    end

    function windowTable:TextInput(options)
        options = options or {}
        local inputFrame = create("Frame",{Parent = options.Parent or self.ContentFrame, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,30)})
        local box = create("TextBox",{Parent = inputFrame, Text = options.Placeholder or "", Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextColor3 = textColor, Font = Enum.Font.SourceSans, TextSize = 16})
        box.FocusLost:Connect(function(enter)
            if enter then
                pcall(options.Callback,box.Text)
            end
        end)
    end

    function windowTable:Divider(text)
        local div = create("Frame",{Parent = self.ContentFrame, BackgroundColor3 = outlineColor, Size = UDim2.new(1,0,0,2)})
        if text then
            local label = create("TextLabel",{Parent = div, Text = text, BackgroundTransparency = 1, TextColor3 = textColor, Font = Enum.Font.SourceSans, TextSize = 16, Position = UDim2.new(0,5,0,-18)})
        end
    end

    function windowTable:Notify(title,message,duration)
        duration = duration or 3
        local notifGui = create("ScreenGui",{Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"), ResetOnSpawn = false})
        local frame = create("Frame",{Parent = notifGui, BackgroundColor3 = bgColor, BorderColor3 = outlineColor, BorderSizePixel = 2, Size = UDim2.new(0,250,0,100), Position = UDim2.new(0.5,-125,0,50)})
        local titleLabel = create("TextLabel",{Parent = frame, Text = title or "Notification", Size = UDim2.new(1,0,0,30), BackgroundTransparency = 1, TextColor3 = textColor, Font = Enum.Font.SourceSansBold, TextSize = 18})
        local msgLabel = create("TextLabel",{Parent = frame, Text = message or "", Size = UDim2.new(1,0,0,70), Position = UDim2.new(0,0,0,30), BackgroundTransparency = 1, TextColor3 = textColor, Font = Enum.Font.SourceSans, TextSize = 16, TextWrapped = true})
        spawn(function()
            wait(duration)
            frame:Destroy()
            notifGui:Destroy()
        end)
    end

    table.insert(UILib.Windows,windowTable)
    debugPrint("Window created:",title)
    return windowTable
end

return UILib
