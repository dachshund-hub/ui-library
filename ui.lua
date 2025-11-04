local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local UI = {}
UI.__index = UI

function UI:CreateWindow(size, title)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DachshundHub_" .. HttpService:GenerateGUID(false)
    screenGui.Parent = CoreGui
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local window = Instance.new("Frame")
    window.Size = UDim2.new(0, size.X.Offset, 0, size.Y.Offset)
    window.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    window.BackgroundColor3 = Color3.fromRGB(0,0,0)
    window.BorderColor3 = Color3.fromRGB(0,0,255)
    window.BorderSizePixel = 2
    window.AnchorPoint = Vector2.new(0.5,0.5)
    window.Parent = screenGui
    window.ClipsDescendants = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,12)
    corner.Parent = window

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1,0,0,40)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 24
    titleLabel.TextColor3 = Color3.fromRGB(0,0,255)
    titleLabel.Parent = window

    -- Window dragging
    local dragging, dragStart, startPos
    window.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    window.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                        startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Tabs
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(0,120,1, -40)
    tabContainer.Position = UDim2.new(1,-120,0,40)
    tabContainer.BackgroundColor3 = Color3.fromRGB(0,0,0)
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = window

    local tabList = Instance.new("UIListLayout")
    tabList.Padding = UDim.new(0,5)
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Parent = tabContainer

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(0,2,1,-40)
    divider.Position = UDim2.new(1,-122,0,40)
    divider.BackgroundColor3 = Color3.fromRGB(0,0,255)
    divider.BorderSizePixel = 0
    divider.Parent = window

    local mainContainer = Instance.new("Frame")
    mainContainer.Size = UDim2.new(1,-124,1,-40)
    mainContainer.Position = UDim2.new(0,0,0,40)
    mainContainer.BackgroundTransparency = 1
    mainContainer.Parent = window

    local function CreateTab(name)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1,0,0,40)
        button.Text = name
        button.Font = Enum.Font.Gotham
        button.TextSize = 18
        button.TextColor3 = Color3.fromRGB(0,0,255)
        button.BackgroundColor3 = Color3.fromRGB(0,0,0)
        button.BorderSizePixel = 0
        button.Parent = tabContainer

        local content = Instance.new("Frame")
        content.Size = UDim2.new(1,0,1,0)
        content.BackgroundTransparency = 1
        content.Visible = false
        content.Parent = mainContainer

        button.MouseButton1Click:Connect(function()
            for _,v in pairs(mainContainer:GetChildren()) do
                if v:IsA("Frame") then v.Visible = false end
            end
            content.Visible = true
        end)

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0,5)
        layout.Parent = content

        local tabFunctions = {}

        function tabFunctions:AddToggle(text, callback)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1,-20,0,30)
            frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
            frame.Parent = content

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0,6)
            corner.Parent = frame

            local label = Instance.new("TextLabel")
            label.Text = text
            label.Size = UDim2.new(0.7,0,1,0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(255,255,255)
            label.Font = Enum.Font.Gotham
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0,30,0,30)
            btn.Position = UDim2.new(0.75,0,0,0)
            btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
            btn.BorderColor3 = Color3.fromRGB(0,0,255)
            btn.BorderSizePixel = 2
            btn.Parent = frame

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0,6)
            btnCorner.Parent = btn

            local toggled = false
            btn.MouseButton1Click:Connect(function()
                toggled = not toggled
                local tween = TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = toggled and Color3.fromRGB(0,0,255) or Color3.fromRGB(0,0,0)})
                tween:Play()
                callback(toggled)
            end)
        end

        function tabFunctions:AddButton(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,-20,0,30)
            btn.Text = text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 16
            btn.TextColor3 = Color3.fromRGB(0,0,255)
            btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
            btn.BorderSizePixel = 0
            btn.Parent = content

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0,6)
            corner.Parent = btn

            btn.MouseButton1Click:Connect(callback)
        end

        function tabFunctions:AddSlider(text, min, max, default, callback)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1,-20,0,40)
            frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
            frame.Parent = content

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0,6)
            corner.Parent = frame

            local label = Instance.new("TextLabel")
            label.Text = text.." : "..default
            label.Size = UDim2.new(1,0,0,20)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(255,255,255)
            label.Font = Enum.Font.Gotham
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame

            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1,0,0,10)
            sliderFrame.Position = UDim2.new(0,0,0,25)
            sliderFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
            sliderFrame.Parent = frame

            local slider = Instance.new("Frame")
            slider.Size = UDim2.new((default-min)/(max-min),0,1,0)
            slider.BackgroundColor3 = Color3.fromRGB(0,0,255)
            slider.Parent = sliderFrame

            local dragging = false
            sliderFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            sliderFrame.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            sliderFrame.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X)/sliderFrame.AbsoluteSize.X,0,1)
                    slider.Size = UDim2.new(pos,0,1,0)
                    local val = math.floor(pos*(max-min)+min)
                    label.Text = text.." : "..val
                    callback(val)
                end
            end)
        end

        function tabFunctions:AddTextInput(text, callback)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1,-20,0,30)
            frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
            frame.Parent = content

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0,6)
            corner.Parent = frame

            local textBox = Instance.new("TextBox")
            textBox.Size = UDim2.new(1,0,1,0)
            textBox.BackgroundTransparency = 1
            textBox.TextColor3 = Color3.fromRGB(255,255,255)
            textBox.Font = Enum.Font.Gotham
            textBox.TextSize = 16
            textBox.PlaceholderText = text
            textBox.ClearTextOnFocus = false
            textBox.Parent = frame

            textBox.FocusLost:Connect(function(enter)
                if enter then
                    callback(textBox.Text)
                end
            end)
        end

        function tabFunctions:AddDivider()
            local div = Instance.new("Frame")
            div.Size = UDim2.new(1,-20,0,2)
            div.BackgroundColor3 = Color3.fromRGB(0,0,255)
            div.BorderSizePixel = 0
            div.Parent = content
        end

        return tabFunctions
    end

    return {Window=window, CreateTab=CreateTab}
end

return UI
