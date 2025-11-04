local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local UILibrary = {}
UILibrary.__index = UILibrary

function UILibrary:CreateWindow(title, width, height, bgColor, textColor, outlineColor)
    local window = {}
    window.Tabs = {}
    window.Sections = {}
    window.UIElements = {}

    window.BackgroundColor = bgColor or Color3.fromRGB(0,0,0)
    window.TextColor = textColor or Color3.fromRGB(255,255,255)
    window.OutlineColor = outlineColor or Color3.fromRGB(0,100,255)
    window.Title = title or "Window"
    window.Width = width or 600
    window.Height = height or 400

    window.ScreenGui = Instance.new("ScreenGui")
    window.ScreenGui.ResetOnSpawn = false
    window.ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    window.Frame = Instance.new("Frame")
    window.Frame.Size = UDim2.new(0, window.Width, 0, window.Height)
    window.Frame.Position = UDim2.new(0.5, -window.Width/2, 0.5, -window.Height/2)
    window.Frame.BackgroundColor3 = window.BackgroundColor
    window.Frame.BorderColor3 = window.OutlineColor
    window.Frame.BorderSizePixel = 2
    window.Frame.ClipsDescendants = true
    window.Frame.Parent = window.ScreenGui
    window.Frame.AnchorPoint = Vector2.new(0.5,0.5)
    window.Frame.Active = true
    window.Frame.Draggable = true

    window.TitleLabel = Instance.new("TextLabel")
    window.TitleLabel.Size = UDim2.new(1,0,0,30)
    window.TitleLabel.Position = UDim2.new(0,0,0,0)
    window.TitleLabel.BackgroundTransparency = 1
    window.TitleLabel.Text = window.Title
    window.TitleLabel.TextColor3 = window.TextColor
    window.TitleLabel.Font = Enum.Font.SourceSansBold
    window.TitleLabel.TextSize = 18
    window.TitleLabel.Parent = window.Frame

    window.TabHolder = Instance.new("Frame")
    window.TabHolder.Size = UDim2.new(0, 120, 1, -30)
    window.TabHolder.Position = UDim2.new(1, -120, 0, 30)
    window.TabHolder.BackgroundTransparency = 1
    window.TabHolder.Parent = window.Frame

    window.Divider = Instance.new("Frame")
    window.Divider.Size = UDim2.new(0,2,1, -30)
    window.Divider.Position = UDim2.new(1, -122, 0, 30)
    window.Divider.BackgroundColor3 = window.OutlineColor
    window.Divider.BorderSizePixel = 0
    window.Divider.Parent = window.Frame

    window.ContentHolder = Instance.new("ScrollingFrame")
    window.ContentHolder.Size = UDim2.new(1, -122, 1, -30)
    window.ContentHolder.Position = UDim2.new(0,0,0,30)
    window.ContentHolder.BackgroundTransparency = 1
    window.ContentHolder.ScrollBarThickness = 4
    window.ContentHolder.Parent = window.Frame
    window.ContentHolder.CanvasSize = UDim2.new(0,0,0,0)
    window.ContentHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y

    function window:AddTab(name)
        local tab = {}
        tab.Name = name
        tab.Button = Instance.new("TextButton")
        tab.Button.Size = UDim2.new(1,0,0,30)
        tab.Button.Text = name
        tab.Button.TextColor3 = window.TextColor
        tab.Button.BackgroundColor3 = Color3.fromRGB(30,30,30)
        tab.Button.Font = Enum.Font.SourceSans
        tab.Button.TextSize = 16
        tab.Button.Parent = window.TabHolder

        tab.Sections = {}

        tab.Button.MouseButton1Click:Connect(function()
            for _, sec in pairs(window.Sections) do
                sec.Frame.Visible = false
            end
            for _, sec in pairs(tab.Sections) do
                sec.Frame.Visible = true
            end
        end)

        table.insert(window.Tabs, tab)
        return tab
    end

    function window:AddSection(tab, name)
        local section = {}
        section.Name = name
        section.Frame = Instance.new("Frame")
        section.Frame.Size = UDim2.new(1,-10,0,0)
        section.Frame.BackgroundTransparency = 1
        section.Frame.LayoutOrder = #window.ContentHolder:GetChildren()
        section.Frame.Visible = true
        section.Layout = Instance.new("UIListLayout")
        section.Layout.Padding = UDim.new(0,5)
        section.Layout.SortOrder = Enum.SortOrder.LayoutOrder
        section.Layout.Parent = section.Frame
        section.Frame.Parent = window.ContentHolder

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Text = name
        titleLabel.Size = UDim2.new(1,0,0,20)
        titleLabel.BackgroundTransparency = 1
        titleLabel.TextColor3 = window.TextColor
        titleLabel.Font = Enum.Font.SourceSansBold
        titleLabel.TextSize = 16
        titleLabel.Parent = section.Frame

        tab.Sections[name] = section
        table.insert(window.Sections, section)
        return section
    end

    function window:AddButton(section, text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,0,30)
        btn.Text = text
        btn.TextColor3 = window.TextColor
        btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 16
        btn.Parent = section.Frame
        btn.MouseButton1Click:Connect(callback)
        table.insert(window.UIElements, btn)
        return btn
    end

    function window:AddToggle(section, text, default, callback)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1,0,0,30)
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.Parent = section.Frame

        local label = Instance.new("TextLabel")
        label.Text = text
        label.Size = UDim2.new(0.7,0,1,0)
        label.BackgroundTransparency = 1
        label.TextColor3 = window.TextColor
        label.Font = Enum.Font.SourceSans
        label.TextSize = 16
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggleFrame

        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0.3, -5,1,0)
        toggleBtn.Position = UDim2.new(0.7,5,0,0)
        toggleBtn.Text = default and "ON" or "OFF"
        toggleBtn.TextColor3 = window.TextColor
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        toggleBtn.Font = Enum.Font.SourceSans
        toggleBtn.TextSize = 16
        toggleBtn.Parent = toggleFrame

        local value = default
        toggleBtn.MouseButton1Click:Connect(function()
            value = not value
            toggleBtn.Text = value and "ON" or "OFF"
            callback(value)
        end)

        table.insert(window.UIElements, toggleFrame)
        return toggleFrame
    end

    function window:AddSlider(section, text, min, max, default, callback)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Size = UDim2.new(1,0,0,40)
        sliderFrame.BackgroundTransparency = 1
        sliderFrame.Parent = section.Frame

        local label = Instance.new("TextLabel")
        label.Text = text.." : "..default
        label.Size = UDim2.new(1,0,0,20)
        label.BackgroundTransparency = 1
        label.TextColor3 = window.TextColor
        label.Font = Enum.Font.SourceSans
        label.TextSize = 16
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = sliderFrame

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1,0,0,10)
        bar.Position = UDim2.new(0,0,0,25)
        bar.BackgroundColor3 = Color3.fromRGB(50,50,50)
        bar.BorderSizePixel = 0
        bar.Parent = sliderFrame

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
        fill.BackgroundColor3 = window.OutlineColor
        fill.BorderSizePixel = 0
        fill.Parent = bar

        local dragging = false
        fill.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(pos,0,1,0)
                local val = min + (max-min)*pos
                label.Text = text.." : "..math.floor(val)
                callback(val)
            end
        end)

        table.insert(window.UIElements, sliderFrame)
        return sliderFrame
    end

    function window:AddTextInput(section, labelText, placeholder, callback)
        local inputFrame = Instance.new("Frame")
        inputFrame.Size = UDim2.new(1,0,0,30)
        inputFrame.BackgroundTransparency = 1
        inputFrame.Parent = section.Frame

        local label = Instance.new("TextLabel")
        label.Text = labelText
        label.Size = UDim2.new(0.4,0,1,0)
        label.BackgroundTransparency = 1
        label.TextColor3 = window.TextColor
        label.Font = Enum.Font.SourceSans
        label.TextSize = 16
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = inputFrame

        local textbox = Instance.new("TextBox")
        textbox.Size = UDim2.new(0.6,0,1,0)
        textbox.Position = UDim2.new(0.4,5,0,0)
        textbox.Text = placeholder or ""
        textbox.TextColor3 = window.TextColor
        textbox.BackgroundColor3 = Color3.fromRGB(50,50,50)
        textbox.Font = Enum.Font.SourceSans
        textbox.TextSize = 16
        textbox.ClearTextOnFocus = false
        textbox.Parent = inputFrame

        textbox.FocusLost:Connect(function()
            callback(textbox.Text)
        end)

        table.insert(window.UIElements, inputFrame)
        return inputFrame
    end

    function window:AddDivider(section)
        local div = Instance.new("Frame")
        div.Size = UDim2.new(1,0,0,2)
        div.BackgroundColor3 = window.OutlineColor
        div.BorderSizePixel = 0
        div.Parent = section.Frame
        table.insert(window.UIElements, div)
        return div
    end

    return window
end

return UILibrary
