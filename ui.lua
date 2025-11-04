-- UI Library
local UILib = {}
UILib.__index = UILib

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

function UILib:CreateWindow(props)
    local Window = Instance.new("Frame")
    Window.Name = "DachshundWindow"
    Window.Size = props.Size or UDim2.new(0,600,0,400)
    Window.BackgroundColor3 = props.BackgroundColor or Color3.fromRGB(0,0,0)
    Window.BorderColor3 = props.OutlineColor or Color3.fromRGB(0, 102, 255)
    Window.BorderSizePixel = 2
    Window.AnchorPoint = Vector2.new(0.5,0.5)
    Window.Position = UDim2.new(0.5,0,0.5,0)
    Window.Parent = props.Parent or game.Players.LocalPlayer:WaitForChild("PlayerGui")

    Window.ClipsDescendants = true
    Window.RoundedCorner = Instance.new("UICorner", Window)
    Window.RoundedCorner.CornerRadius = UDim.new(0,8)

    local TabsFrame = Instance.new("Frame", Window)
    TabsFrame.Size = UDim2.new(0,120,1,0)
    TabsFrame.Position = UDim2.new(1,-120,0,0)
    TabsFrame.BackgroundTransparency = 1
    local TabsLayout = Instance.new("UIListLayout", TabsFrame)
    TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabsLayout.Padding = UDim.new(0,4)

    local Divider = Instance.new("Frame", Window)
    Divider.Size = UDim2.new(0,2,1,0)
    Divider.Position = UDim2.new(1,-122,0,0)
    Divider.BackgroundColor3 = Color3.fromRGB(0,102,255)

    local ContentFrame = Instance.new("ScrollingFrame", Window)
    ContentFrame.Size = UDim2.new(1,-124,1,0)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.CanvasSize = UDim2.new(0,0,0,0)
    local ContentLayout = Instance.new("UIListLayout", ContentFrame)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0,6)

    local WindowObj = {Window=Window, Tabs=TabsFrame, Content=ContentFrame, TabObjects={}}
    setmetatable(WindowObj, UILib)

    local dragging = false
    local dragInput, mousePos, framePos

    local function update(input)
        local delta = input.Position - mousePos
        Window.Position = UDim2.new(0, framePos.X + delta.X, 0, framePos.Y + delta.Y)
    end

    Window.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = Vector2.new(Window.Position.X.Offset, Window.Position.Y.Offset)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Window.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            update(dragInput)
        end
    end)

    return WindowObj
end

function UILib:AddTab(name)
    local Button = Instance.new("TextButton", self.Tabs)
    Button.Text = name
    Button.Size = UDim2.new(1,0,0,40)
    Button.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Button.TextColor3 = Color3.fromRGB(255,255,255)
    local corner = Instance.new("UICorner", Button)
    corner.CornerRadius = UDim.new(0,4)
    local TabContent = Instance.new("Frame", self.Window)
    TabContent.Size = self.Content.Size
    TabContent.Position = self.Content.Position
    TabContent.BackgroundTransparency = 1
    TabContent.Visible = false
    self.TabObjects[name] = TabContent

    Button.MouseButton1Click:Connect(function()
        for _,v in pairs(self.TabObjects) do v.Visible = false end
        TabContent.Visible = true
    end)

    return TabContent
end

function UILib:Toggle(props)
    local T = Instance.new("TextButton", props.Parent)
    T.Size = UDim2.new(1,0,0,30)
    T.Text = props.Text
    T.BackgroundColor3 = Color3.fromRGB(35,35,35)
    T.TextColor3 = Color3.fromRGB(255,255,255)
    local corner = Instance.new("UICorner", T)
    corner.CornerRadius = UDim.new(0,4)
    local state = false
    T.MouseButton1Click:Connect(function()
        state = not state
        T.BackgroundColor3 = state and Color3.fromRGB(0,102,255) or Color3.fromRGB(35,35,35)
        if props.Callback then props.Callback(state) end
    end)
end

function UILib:Slider(props)
    local F = Instance.new("Frame", props.Parent)
    F.Size = UDim2.new(1,0,0,30)
    F.BackgroundColor3 = Color3.fromRGB(35,35,35)
    local corner = Instance.new("UICorner", F)
    corner.CornerRadius = UDim.new(0,4)
    local SliderBar = Instance.new("Frame", F)
    SliderBar.Size = UDim2.new(0,0,1,0)
    SliderBar.BackgroundColor3 = Color3.fromRGB(0,102,255)
    local dragging = false
    F.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    F.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    F.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local pos = math.clamp(input.Position.X - F.AbsolutePosition.X,0,F.AbsoluteSize.X)
            SliderBar.Size = UDim2.new(0,pos,1,0)
            if props.Callback then
                local val = (pos/F.AbsoluteSize.X)*(props.Max-props.Min)+props.Min
                props.Callback(val)
            end
        end
    end)
end

function UILib:Button(props)
    local B = Instance.new("TextButton", props.Parent)
    B.Size = UDim2.new(1,0,0,30)
    B.Text = props.Text
    B.BackgroundColor3 = Color3.fromRGB(0,102,255)
    B.TextColor3 = Color3.fromRGB(255,255,255)
    local corner = Instance.new("UICorner", B)
    corner.CornerRadius = UDim.new(0,4)
    B.MouseButton1Click:Connect(function()
        if props.Callback then props.Callback() end
    end)
end

function UILib:TextInput(props)
    local Box = Instance.new("TextBox", props.Parent)
    Box.Size = UDim2.new(1,0,0,30)
    Box.PlaceholderText = props.Placeholder
    Box.BackgroundColor3 = Color3.fromRGB(35,35,35)
    Box.TextColor3 = Color3.fromRGB(255,255,255)
    local corner = Instance.new("UICorner", Box)
    corner.CornerRadius = UDim.new(0,4)
    Box.FocusLost:Connect(function(enterPressed)
        if enterPressed and props.Callback then
            props.Callback(Box.Text)
        end
    end)
end

function UILib:Divider(text)
    local F = Instance.new("Frame", self.Content)
    F.Size = UDim2.new(1,0,0,1)
    F.BackgroundColor3 = Color3.fromRGB(0,102,255)
    if text then
        local L = Instance.new("TextLabel", self.Content)
        L.Size = UDim2.new(1,0,0,20)
        L.Text = text
        L.TextColor3 = Color3.fromRGB(255,255,255)
        L.BackgroundTransparency = 1
    end
end

function UILib:Notify(title,msg,duration)
    duration = duration or 2
    local Gui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
    local Frame = Instance.new("Frame", Gui)
    Frame.Size = UDim2.new(0,250,0,80)
    Frame.Position = UDim2.new(1,-260,0,50)
    Frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
    local corner = Instance.new("UICorner", Frame)
    corner.CornerRadius = UDim.new(0,6)
    local Title = Instance.new("TextLabel", Frame)
    Title.Text = title
    Title.Size = UDim2.new(1,0,0,30)
    Title.TextColor3 = Color3.fromRGB(0,102,255)
    Title.BackgroundTransparency = 1
    local Msg = Instance.new("TextLabel", Frame)
    Msg.Text = msg
    Msg.Size = UDim2.new(1,0,1,-30)
    Msg.Position = UDim2.new(0,0,0,30)
    Msg.TextColor3 = Color3.fromRGB(255,255,255)
    Msg.BackgroundTransparency = 1
    Frame:TweenPosition(UDim2.new(1,-260,0,100), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.5, true, function()
        delay(duration,function()
            Frame:TweenPosition(UDim2.new(1,0,0,100), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.5, true, function()
                Gui:Destroy()
            end)
        end)
    end)
end

return UILib
