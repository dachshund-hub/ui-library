local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local UI = {}

function UI:CreateWindow(config)
    local window = Instance.new("Frame")
    window.Size = config.Size or UDim2.new(0, 400, 0, 300)
    window.Position = UDim2.new(0.5, -200, 0.5, -150)
    window.BackgroundColor3 = config.BackgroundColor or Color3.fromRGB(0,0,0)
    window.BorderSizePixel = 0
    window.AnchorPoint = Vector2.new(0.5,0.5)
    window.ClipsDescendants = true
    window.Name = "DachshundHubWindow"
    window.Parent = config.Parent or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    local outline = Instance.new("UICorner")
    outline.CornerRadius = UDim.new(0, 10)
    outline.Parent = window

    local border = Instance.new("Frame")
    border.Size = UDim2.new(1, 4, 1, 4)
    border.Position = UDim2.new(0, -2, 0, -2)
    border.BackgroundColor3 = config.OutlineColor or Color3.fromRGB(0, 162, 255)
    border.ZIndex = 0
    border.Parent = window
    local borderCorner = Instance.new("UICorner")
    borderCorner.CornerRadius = UDim.new(0, 12)
    borderCorner.Parent = border

    local title = Instance.new("TextLabel")
    title.Text = "Dachshund Hub"
    title.TextColor3 = config.TextColor or Color3.fromRGB(255,255,255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Parent = window

    local tabsFrame = Instance.new("Frame")
    tabsFrame.Size = UDim2.new(0, 100, 1, -30)
    tabsFrame.Position = UDim2.new(1, -100, 0, 30)
    tabsFrame.BackgroundTransparency = 1
    tabsFrame.Parent = window

    local tabsDivider = Instance.new("Frame")
    tabsDivider.Size = UDim2.new(0, 2, 1, -30)
    tabsDivider.Position = UDim2.new(1, -102, 0, 30)
    tabsDivider.BackgroundColor3 = config.OutlineColor or Color3.fromRGB(0, 162, 255)
    tabsDivider.BorderSizePixel = 0
    tabsDivider.Parent = window

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -104, 1, -30)
    contentFrame.Position = UDim2.new(0, 0, 0, 30)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = window

    -- Dragging
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
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
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    -- Animations
    window.Visible = false
    window:TweenSize(window.Size, Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    window.Visible = true

    return {
        Window = window,
        Tabs = tabsFrame,
        Content = contentFrame,
        AddTab = function(self, tabName)
            local tabButton = Instance.new("TextButton")
            tabButton.Size = UDim2.new(1,0,0,30)
            tabButton.Text = tabName
            tabButton.BackgroundTransparency = 0.2
            tabButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
            tabButton.TextColor3 = Color3.fromRGB(255,255,255)
            tabButton.Parent = self.Tabs
            local tabContent = Instance.new("Frame")
            tabContent.Size = UDim2.new(1,0,1,0)
            tabContent.BackgroundTransparency = 1
            tabContent.Visible = false
            tabContent.Parent = self.Content
            tabButton.MouseButton1Click:Connect(function()
                for _, c in pairs(self.Content:GetChildren()) do
                    if c:IsA("Frame") then
                        c.Visible = false
                    end
                end
                tabContent.Visible = true
            end)
            return {
                Content = tabContent,
                AddToggle = function(_, name, callback)
                    local toggle = Instance.new("TextButton")
                    toggle.Text = name.." [OFF]"
                    toggle.Size = UDim2.new(1, -10, 0, 30)
                    toggle.Position = UDim2.new(0, 5, 0, #tabContent:GetChildren()*35)
                    toggle.BackgroundColor3 = Color3.fromRGB(20,20,20)
                    toggle.TextColor3 = Color3.fromRGB(255,255,255)
                    toggle.Parent = tabContent
                    local toggled = false
                    toggle.MouseButton1Click:Connect(function()
                        toggled = not toggled
                        toggle.Text = name.." ["..(toggled and "ON" or "OFF").."]"
                        callback(toggled)
                    end)
                end
            }
        end
    }
end

return UI
