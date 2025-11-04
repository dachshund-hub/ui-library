if not UIDebugMode then
    UIDebugMode = false
end

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local UILibrary = {}
UILibrary.__index = UILibrary

function UILibrary:CreateWindow(title, width, height, bgColor, textColor, outlineColor)
    local window = {}
    window.Tabs = {}
    window.Dragging = false

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DachshundHubUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, width, 0, height)
    frame.Position = UDim2.new(0.5, -width/2, 0.5, -height/2)
    frame.BackgroundColor3 = bgColor
    frame.BorderColor3 = outlineColor
    frame.BorderSizePixel = 2
    frame.ClipsDescendants = true
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Parent = screenGui
    frame.Name = "Window"

    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0,10)
    uicorner.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title
    titleLabel.Size = UDim2.new(1,0,0,30)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = textColor
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 20
    titleLabel.Parent = frame

    local tabHolder = Instance.new("Frame")
    tabHolder.Size = UDim2.new(0, 120, 1, -30)
    tabHolder.Position = UDim2.new(0,0,0,30)
    tabHolder.BackgroundTransparency = 1
    tabHolder.Parent = frame

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(0,2,1, -30)
    divider.Position = UDim2.new(0,120,0,30)
    divider.BackgroundColor3 = outlineColor
    divider.Parent = frame

    local contentHolder = Instance.new("Frame")
    contentHolder.Size = UDim2.new(1, -122, 1, -30)
    contentHolder.Position = UDim2.new(0,122,0,30)
    contentHolder.BackgroundTransparency = 1
    contentHolder.Parent = frame

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            window.Dragging = true
            window.DragStart = input.Position
            window.StartPos = frame.Position
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            window.Dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if window.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - window.DragStart
            frame.Position = UDim2.new(0, window.StartPos.X.Offset + delta.X, 0, window.StartPos.Y.Offset + delta.Y)
        end
    end)

    function window:AddTab(tabName)
        local tabButton = Instance.new("TextButton")
        tabButton.Text = tabName
        tabButton.Size = UDim2.new(1,0,0,30)
        tabButton.BackgroundColor3 = Color3.fromRGB(30,30,30)
        tabButton.TextColor3 = textColor
        tabButton.Font = Enum.Font.SourceSans
        tabButton.TextSize = 16
        tabButton.Parent = tabHolder

        local tabContent = Instance.new("Frame")
        tabContent.Size = UDim2.new(1,0,1,0)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
        tabContent.Parent = contentHolder

        tabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(window.Tabs) do
                tab.Content.Visible = false
            end
            tabContent.Visible = true
        end)

        local tabData = {Name = tabName, Button = tabButton, Content = tabContent}
        table.insert(window.Tabs, tabData)
        if #window.Tabs == 1 then
            tabContent.Visible = true
        end
        return tabData
    end

    function window:AddSection(tab, sectionName)
        local sectionFrame = Instance.new("Frame")
        sectionFrame.Size = UDim2.new(1,0,0,50)
        sectionFrame.BackgroundTransparency = 0.5
        sectionFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
        sectionFrame.BorderSizePixel = 0
        sectionFrame.Parent = tab.Content
        sectionFrame.LayoutOrder = #tab.Content:GetChildren() + 1

        local uic = Instance.new("UICorner")
        uic.CornerRadius = UDim.new(0,8)
        uic.Parent = sectionFrame

        local sectionLabel = Instance.new("TextLabel")
        sectionLabel.Text = sectionName
        sectionLabel.Size = UDim2.new(1,0,0,20)
        sectionLabel.BackgroundTransparency = 1
        sectionLabel.TextColor3 = Color3.fromRGB(180,180,180)
        sectionLabel.Font = Enum.Font.SourceSans
        sectionLabel.TextSize = 16
        sectionLabel.Parent = sectionFrame

        local uiList = Instance.new("UIListLayout")
        uiList.Padding = UDim.new(0,5)
        uiList.SortOrder = Enum.SortOrder.LayoutOrder
        uiList.Parent = sectionFrame

        return sectionFrame
    end

    function window:AddToggle(section, name, default, callback)
        local toggleButton = Instance.new("TextButton")
        toggleButton.Text = name .. ": " .. tostring(default)
        toggleButton.Size = UDim2.new(1,0,0,30)
        toggleButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
        toggleButton.TextColor3 = Color3.fromRGB(255,255,255)
        toggleButton.Font = Enum.Font.SourceSans
        toggleButton.TextSize = 14
        toggleButton.Parent = section

        toggleButton.MouseButton1Click:Connect(function()
            default = not default
            toggleButton.Text = name .. ": " .. tostring(default)
            if callback then
                callback(default)
            end
        end)
    end

    function window:AddButton(section, name, callback)
        local btn = Instance.new("TextButton")
        btn.Text = name
        btn.Size = UDim2.new(1,0,0,30)
        btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 14
        btn.Parent = section

        btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
    end

    function window:AddSlider(section, name, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1,0,0,30)
        frame.BackgroundColor3 = Color3.fromRGB(50,50,50)
        frame.Parent = section

        local label = Instance.new("TextLabel")
        label.Text = name .. ": " .. default
        label.Size = UDim2.new(1,0,1,0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.Font = Enum.Font.SourceSans
        label.TextSize = 14
        label.Parent = frame

        local input = Instance.new("TextBox")
        input.Text = tostring(default)
        input.Size = UDim2.new(0.3,0,1,0)
        input.Position = UDim2.new(0.7,0,0,0)
        input.BackgroundColor3 = Color3.fromRGB(70,70,70)
        input.TextColor3 = Color3.fromRGB(255,255,255)
        input.Font = Enum.Font.SourceSans
        input.TextSize = 14
        input.Parent = frame

        input.FocusLost:Connect(function(enter)
            local num = tonumber(input.Text)
            if num then
                if num < min then num = min end
                if num > max then num = max end
                input.Text = num
                label.Text = name .. ": " .. num
                if callback then callback(num) end
            end
        end)
    end

    function window:AddTextInput(section, name, placeholder, callback)
        local input = Instance.new("TextBox")
        input.PlaceholderText = placeholder or ""
        input.Text = ""
        input.Size = UDim2.new(1,0,0,30)
        input.BackgroundColor3 = Color3.fromRGB(50,50,50)
        input.TextColor3 = Color3.fromRGB(255,255,255)
        input.Font = Enum.Font.SourceSans
        input.TextSize = 14
        input.Parent = section

        input.FocusLost:Connect(function(enter)
            if callback then callback(input.Text) end
        end)
    end

    function window:AddDivider(section)
        local divider = Instance.new("Frame")
        divider.Size = UDim2.new(1,0,0,2)
        divider.BackgroundColor3 = Color3.fromRGB(100,100,100)
        divider.Parent = section
    end

    return window
end

return UILibrary
