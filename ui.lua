-- Dachshund Hub UI Library
-- A simple animated Roblox exploit UI library with tabs, sections, and various elements.
-- Usage:
-- local Library = loadstring(game:HttpGet("your_script_url"))() -- or paste directly
-- local Window = Library:CreateWindow("Dachshund Hub")
-- local Tab1 = Window:CreateTab("Tab 1")
-- Tab1:Section("Section 1")
-- Tab1:Button("Click Me", function() print("Clicked!") end)
-- etc.

local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local function createTweenInfo(duration, easingStyle, easingDirection)
    return TweenInfo.new(duration or 0.2, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out)
end

function Library:CreateWindow(title)
    title = title or "Dachshund Hub"
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = title .. " Hub"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui") -- For exploits; use PlayerGui for normal Roblox
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 400, 0, 300)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    MainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.new(0, 0.5, 1) -- Blue outline
    MainStroke.Thickness = 2
    MainStroke.Parent = MainFrame
    
    -- Title
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, 0, 0, 30)
    TitleLabel.Position = UDim2.new(0, 0, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.TextScaled = true
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextYAlignment = Enum.TextYAlignment.Center
    TitleLabel.Parent = MainFrame
    
    -- Tab Container (Horizontal)
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 0, 30)
    TabContainer.Position = UDim2.new(0, 0, 0, 30)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 0
    TabContainer.ScrollingDirection = Enum.ScrollingDirection.X
    TabContainer.Parent = MainFrame
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    TabLayout.Parent = TabContainer
    
    -- Divider
    local DividerFrame = Instance.new("Frame")
    DividerFrame.Name = "Divider"
    DividerFrame.Size = UDim2.new(1, 0, 0, 1)
    DividerFrame.Position = UDim2.new(0, 0, 0, 59)
    DividerFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    DividerFrame.BorderSizePixel = 0
    DividerFrame.Parent = MainFrame
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, 0, 1, -60)
    ContentContainer.Position = UDim2.new(0, 0, 0, 60)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 5)
    ContentLayout.Parent = ContentContainer
    
    local tabs = {}
    local currentTab = nil
    local currentSection = nil
    
    local function switchTab(tab)
        if currentTab then
            currentTab.Visible = false
            -- Animate out
            TweenService:Create(currentTab, createTweenInfo(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        end
        currentTab = tab.content
        currentTab.Visible = true
        -- Animate in
        tab.content.Size = UDim2.new(1, 0, 0, 0)
        TweenService:Create(tab.content, createTweenInfo(0.2), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        
        -- Highlight tab button
        for _, t in pairs(tabs) do
            TweenService:Create(t.button, createTweenInfo(0.2), {BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)}):Play()
        end
        TweenService:Create(tab.button, createTweenInfo(0.2), {BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)}):Play()
    end
    
    function Window:CreateTab(name)
        local tabButton = Instance.new("TextButton")
        tabButton.Name = name .. "Tab"
        tabButton.Size = UDim2.new(0, 80, 1, 0)
        tabButton.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
        tabButton.BorderSizePixel = 0
        tabButton.Text = name
        tabButton.TextColor3 = Color3.new(1, 1, 1)
        tabButton.TextScaled = true
        tabButton.Font = Enum.Font.SourceSans
        tabButton.Parent = TabContainer
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 4)
        tabCorner.Parent = tabButton
        
        local tabContent = Instance.new("Frame")
        tabContent.Name = name .. "Content"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.Position = UDim2.new(0, 0, 0, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
        tabContent.Parent = ContentContainer
        
        local tabContentLayout = Instance.new("UIListLayout")
        tabContentLayout.Padding = UDim.new(0, 5)
        tabContentLayout.Parent = tabContent
        
        local tab = {button = tabButton, content = tabContent}
        table.insert(tabs, tab)
        
        tabButton.MouseButton1Click:Connect(function()
            switchTab(tab)
        end)
        
        -- Hover animations for tab
        tabButton.MouseEnter:Connect(function()
            if currentTab ~= tab.content then
                TweenService:Create(tabButton, createTweenInfo(0.2), {BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)}):Play()
            end
        end)
        tabButton.MouseLeave:Connect(function()
            if currentTab ~= tab.content then
                TweenService:Create(tabButton, createTweenInfo(0.2), {BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)}):Play()
            end
        end)
        
        -- Auto-switch to first tab
        if #tabs == 1 then
            switchTab(tab)
        end
        
        -- Chainable elements
        tab.Section = Section
        tab.Button = Button
        tab.Toggle = Toggle
        tab.Slider = Slider
        tab.Dropdown = Dropdown
        tab.MultiDropdown = MultiDropdown
        tab.TextInput = TextInput
        tab.Divider = Divider
        
        return tab
    end
    
    local Window = {CreateTab = Window.CreateTab}
    
    -- Element Creators (generic, add to currentSection or currentTab.content)
    local function addToContainer(parent)
        return function(element)
            if currentSection then
                element.Parent = currentSection
            else
                element.Parent = currentTab and currentTab.content or ContentContainer
            end
            return element
        end
    end
    
    local function createElement(parent, props)
        local frame = Instance.new(props.type or "Frame")
        for k, v in pairs(props) do
            if k ~= "type" then frame[k] = v end
        end
        addToContainer(parent)(frame)
        return frame
    end
    
    -- Section
    local function Section(name)
        local section = createElement(currentTab and currentTab.content or ContentContainer, {
            type = "Frame",
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = Color3.new(0.05, 0.05, 0.05),
            BorderSizePixel = 0,
            BackgroundTransparency = 0
        })
        local sectionCorner = Instance.new("UICorner")
        sectionCorner.CornerRadius = UDim.new(0, 4)
        sectionCorner.Parent = section
        
        local sectionTitle = Instance.new("TextLabel")
        sectionTitle.Size = UDim2.new(1, 0, 0, 20)
        sectionTitle.BackgroundTransparency = 1
        sectionTitle.Text = name
        sectionTitle.TextColor3 = Color3.new(1, 1, 1)
        sectionTitle.TextScaled = true
        sectionTitle.Font = Enum.Font.SourceSansBold
        sectionTitle.Parent = section
        
        local sectionContent = createElement(section, {
            type = "Frame",
            Size = UDim2.new(1, -10, 1, -25),
            Position = UDim2.new(0, 5, 0, 25),
            BackgroundTransparency = 1
        })
        local sectionLayout = Instance.new("UIListLayout")
        sectionLayout.Padding = UDim.new(0, 2)
        sectionLayout.Parent = sectionContent
        
        -- Animate section expand
        section.Size = UDim2.new(1, 0, 0, 0)
        TweenService:Create(section, createTweenInfo(0.3), {Size = UDim2.new(1, 0, 0, sectionContent.AbsoluteSize.Y + 30)}):Play()
        
        currentSection = sectionContent
        return sectionContent
    end
    
    -- Button
    local function Button(text, callback)
        local button = createElement(currentSection or (currentTab and currentTab.content) or ContentContainer, {
            type = "TextButton",
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Color3.new(0.2, 0.2, 0.2),
            BorderSizePixel = 0,
            Text = text,
            TextColor3 = Color3.new(1, 1, 1),
            TextScaled = true,
            Font = Enum.Font.SourceSans
        })
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 4)
        buttonCorner.Parent = button
        
        button.MouseButton1Click:Connect(function()
            callback()
            -- Press animation
            local pressTween = TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 28)})
            pressTween:Play()
            pressTween.Completed:Connect(function()
                TweenService:Create(button, createTweenInfo(), {Size = UDim2.new(1, 0, 0, 30)}):Play()
            end)
        end)
        
        button.MouseEnter:Connect(function()
            TweenService:Create(button, createTweenInfo(), {BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)}):Play()
        end)
        button.MouseLeave:Connect(function()
            TweenService:Create(button, createTweenInfo(), {BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)}):Play()
        end)
        
        currentSection = nil -- Reset after element
        return button
    end
    
    -- Toggle
    local function Toggle(text, default, callback)
        local toggleFrame = createElement(currentSection or (currentTab and currentTab.content) or ContentContainer, {
            type = "Frame",
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
            BorderSizePixel = 0
        })
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 4)
        toggleCorner.Parent = toggleFrame
        
        local toggleLabel = Instance.new("TextLabel")
        toggleLabel.Size = UDim2.new(1, -50, 1, 0)
        toggleLabel.Position = UDim2.new(0, 0, 0, 0)
        toggleLabel.BackgroundTransparency = 1
        toggleLabel.Text = text
        toggleLabel.TextColor3 = Color3.new(1, 1, 1)
        toggleLabel.TextScaled = true
        toggleLabel.Font = Enum.Font.SourceSans
        toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        toggleLabel.Parent = toggleFrame
        
        local toggleButton = Instance.new("TextButton")
        toggleButton.Size = UDim2.new(0, 40, 0, 20)
        toggleButton.Position = UDim2.new(1, -45, 0.5, -10)
        toggleButton.BackgroundColor3 = default and Color3.new(0, 0.5, 0) or Color3.new(0.5, 0, 0)
        toggleButton.BorderSizePixel = 0
        toggleButton.Text = ""
        toggleButton.Parent = toggleFrame
        
        local toggleKnob = Instance.new("Frame")
        toggleKnob.Size = UDim2.new(0, 16, 1, 0)
        toggleKnob.Position = default and UDim2.new(1, -16, 0, 0) or UDim2.new(0, 0, 0, 0)
        toggleKnob.BackgroundColor3 = Color3.new(1, 1, 1)
        toggleKnob.BorderSizePixel = 0
        toggleKnob.Parent = toggleButton
        
        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(0.5, 0)
        knobCorner.Parent = toggleKnob
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 10)
        buttonCorner.Parent = toggleButton
        
        local toggled = default or false
        local function updateToggle(state)
            toggled = state
            TweenService:Create(toggleButton, createTweenInfo(), {BackgroundColor3 = state and Color3.new(0, 0.5, 0) or Color3.new(0.5, 0, 0)}):Play()
            TweenService:Create(toggleKnob, createTweenInfo(), {Position = state and UDim2.new(1, -16, 0, 0) or UDim2.new(0, 0, 0, 0)}):Play()
            callback(state)
        end
        
        toggleButton.MouseButton1Click:Connect(function()
            updateToggle(not toggled)
        end)
        
        currentSection = nil
        return toggleFrame, updateToggle
    end
    
    -- Slider
    local function Slider(text, min, max, default, callback, format)
        format = format or "%.2f"
        local sliderFrame = createElement(currentSection or (currentTab and currentTab.content) or ContentContainer, {
            type = "Frame",
            Size = UDim2.new(1, 0, 0, 50),
            BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
            BorderSizePixel = 0
        })
        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(0, 4)
        sliderCorner.Parent = sliderFrame
        
        local sliderLabel = Instance.new("TextLabel")
        sliderLabel.Size = UDim2.new(1, 0, 0, 20)
        sliderLabel.BackgroundTransparency = 1
        sliderLabel.Text = text .. ": " .. string.format(format, default)
        sliderLabel.TextColor3 = Color3.new(1, 1, 1)
        sliderLabel.TextScaled = true
        sliderLabel.Font = Enum.Font.SourceSans
        sliderLabel.Parent = sliderFrame
        
        local sliderBar = Instance.new("Frame")
        sliderBar.Size = UDim2.new(1, -20, 0, 6)
        sliderBar.Position = UDim2.new(0, 10, 1, -15)
        sliderBar.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        sliderBar.BorderSizePixel = 0
        sliderBar.Parent = sliderFrame
        
        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(0, 3)
        barCorner.Parent = sliderBar
        
        local fillBar = Instance.new("Frame")
        fillBar.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fillBar.BackgroundColor3 = Color3.new(0, 0.5, 1)
        fillBar.BorderSizePixel = 0
        fillBar.Parent = sliderBar
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 3)
        fillCorner.Parent = fillBar
        
        local dragging = false
        local value = default
        
        local function updateSlider(newValue)
            value = math.clamp(newValue, min, max)
            local percent = (value - min) / (max - min)
            TweenService:Create(fillBar, createTweenInfo(), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
            sliderLabel.Text = text .. ": " .. string.format(format, value)
            callback(value)
        end
        
        sliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mouse = UserInputService:GetMouseLocation()
                local relativeX = math.clamp((mouse.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                updateSlider(min + relativeX * (max - min))
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        updateSlider(default)
        currentSection = nil
        return sliderFrame, updateSlider
    end
    
    -- Dropdown
    local function Dropdown(text, options, default, callback)
        local dropdownFrame = createElement(currentSection or (currentTab and currentTab.content) or ContentContainer, {
            type = "Frame",
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
            BorderSizePixel = 0
        })
        local dropdownCorner = Instance.new("UICorner")
        dropdownCorner.CornerRadius = UDim.new(0, 4)
        dropdownCorner.Parent = dropdownFrame
        
        local dropdownLabel = Instance.new("TextLabel")
        dropdownLabel.Size = UDim2.new(1, -30, 1, 0)
        dropdownLabel.Position = UDim2.new(0, 0, 0, 0)
        dropdownLabel.BackgroundTransparency = 1
        dropdownLabel.Text = text .. ": " .. (default or options[1] or "None")
        dropdownLabel.TextColor3 = Color3.new(1, 1, 1)
        dropdownLabel.TextScaled = true
        dropdownLabel.Font = Enum.Font.SourceSans
        dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
        dropdownLabel.Parent = dropdownFrame
        
        local dropdownButton = Instance.new("TextButton")
        dropdownButton.Size = UDim2.new(0, 25, 0, 25)
        dropdownButton.Position = UDim2.new(1, -25, 0.5, -12.5)
        dropdownButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
        dropdownButton.BorderSizePixel = 0
        dropdownButton.Text = "▼"
        dropdownButton.TextColor3 = Color3.new(1, 1, 1)
        dropdownButton.Font = Enum.Font.SourceSans
        dropdownButton.Parent = dropdownFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 4)
        buttonCorner.Parent = dropdownButton
        
        local dropdownList = Instance.new("Frame")
        dropdownList.Size = UDim2.new(1, 0, 0, 0)
        dropdownList.Position = UDim2.new(0, 0, 1, 0)
        dropdownList.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
        dropdownList.BorderSizePixel = 0
        dropdownList.Visible = false
        dropdownList.Parent = dropdownFrame
        
        local listCorner = Instance.new("UICorner")
        listCorner.CornerRadius = UDim.new(0, 4)
        listCorner.Parent = dropdownList
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 0)
        listLayout.Parent = dropdownList
        
        local selected = default or options[1]
        local open = false
        
        local function toggleList()
            open = not open
            dropdownList.Visible = open
            if open then
                local height = #options * 25
                dropdownList.Size = UDim2.new(1, 0, 0, 0)
                TweenService:Create(dropdownList, createTweenInfo(0.2), {Size = UDim2.new(1, 0, 0, height)}):Play()
            else
                TweenService:Create(dropdownList, createTweenInfo(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                wait(0.2)
                dropdownList.Visible = false
            end
        end
        
        dropdownButton.MouseButton1Click:Connect(toggleList)
        
        for i, option in ipairs(options) do
            local optionButton = Instance.new("TextButton")
            optionButton.Size = UDim2.new(1, 0, 0, 25)
            optionButton.BackgroundTransparency = 1
            optionButton.Text = option
            optionButton.TextColor3 = Color3.new(1, 1, 1)
            optionButton.TextScaled = true
            optionButton.Font = Enum.Font.SourceSans
            optionButton.Parent = dropdownList
            
            optionButton.MouseButton1Click:Connect(function()
                selected = option
                dropdownLabel.Text = text .. ": " .. selected
                callback(selected)
                toggleList()
            end)
            
            optionButton.MouseEnter:Connect(function()
                TweenService:Create(optionButton, createTweenInfo(), {BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)}):Play()
            end)
            optionButton.MouseLeave:Connect(function()
                TweenService:Create(optionButton, createTweenInfo(), {BackgroundColor3 = Color3.new(0, 0, 0)}):Play()
            end)
        end
        
        dropdownList:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            dropdownFrame.Size = UDim2.new(1, 0, 0, open and dropdownList.AbsoluteSize.Y + 30 or 30)
        end)
        
        currentSection = nil
        return dropdownFrame, function(newValue) selected = newValue; dropdownLabel.Text = text .. ": " .. selected; callback(selected) end
    end
    
    -- MultiDropdown
    local function MultiDropdown(text, options, defaults, callback)
        local multiFrame = createElement(currentSection or (currentTab and currentTab.content) or ContentContainer, {
            type = "Frame",
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
            BorderSizePixel = 0
        })
        local multiCorner = Instance.new("UICorner")
        multiCorner.CornerRadius = UDim.new(0, 4)
        multiCorner.Parent = multiFrame
        
        local multiLabel = Instance.new("TextLabel")
        multiLabel.Size = UDim2.new(1, -30, 1, 0)
        multiLabel.BackgroundTransparency = 1
        multiLabel.Text = text .. ": " .. table.concat(defaults or {}, ", ")
        multiLabel.TextColor3 = Color3.new(1, 1, 1)
        multiLabel.TextScaled = true
        multiLabel.Font = Enum.Font.SourceSans
        multiLabel.TextXAlignment = Enum.TextXAlignment.Left
        multiLabel.Parent = multiFrame
        
        local multiButton = Instance.new("TextButton")
        multiButton.Size = UDim2.new(0, 25, 0, 25)
        multiButton.Position = UDim2.new(1, -25, 0.5, -12.5)
        multiButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
        multiButton.BorderSizePixel = 0
        multiButton.Text = "▼"
        multiButton.TextColor3 = Color3.new(1, 1, 1)
        multiButton.Font = Enum.Font.SourceSans
        multiButton.Parent = multiFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 4)
        buttonCorner.Parent = multiButton
        
        local multiList = Instance.new("Frame")
        multiList.Size = UDim2.new(1, 0, 0, 0)
        multiList.Position = UDim2.new(0, 0, 1, 0)
        multiList.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
        multiList.BorderSizePixel = 0
        multiList.Visible = false
        multiList.Parent = multiFrame
        
        local listCorner = Instance.new("UICorner")
        listCorner.CornerRadius = UDim.new(0, 4)
        listCorner.Parent = multiList
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 0)
        listLayout.Parent = multiList
        
        local selected = defaults or {}
        local open = false
        
        local function toggleList()
            open = not open
            multiList.Visible = open
            if open then
                local height = #options * 25
                multiList.Size = UDim2.new(1, 0, 0, 0)
                TweenService:Create(multiList, createTweenInfo(0.2), {Size = UDim2.new(1, 0, 0, height)}):Play()
            else
                TweenService:Create(multiList, createTweenInfo(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                wait(0.2)
                multiList.Visible = false
            end
        end
        
        multiButton.MouseButton1Click:Connect(toggleList)
        
        for i, option in ipairs(options) do
            local optionFrame = Instance.new("Frame")
            optionFrame.Size = UDim2.new(1, 0, 0, 25)
            optionFrame.BackgroundTransparency = 1
            optionFrame.Parent = multiList
            
            local optionCheck = Instance.new("TextButton")
            optionCheck.Size = UDim2.new(0, 20, 0, 20)
            optionCheck.Position = UDim2.new(0, 5, 0.5, -10)
            optionCheck.BackgroundColor3 = table.find(selected, option) and Color3.new(0, 0.5, 0) or Color3.new(0.5, 0, 0)
            optionCheck.BorderSizePixel = 0
            optionCheck.Text = ""
            optionCheck.Parent = optionFrame
            
            local checkCorner = Instance.new("UICorner")
            checkCorner.CornerRadius = UDim.new(0, 3)
            checkCorner.Parent = optionCheck
            
            local optionLabel = Instance.new("TextLabel")
            optionLabel.Size = UDim2.new(1, -30, 1, 0)
            optionLabel.Position = UDim2.new(0, 30, 0, 0)
            optionLabel.BackgroundTransparency = 1
            optionLabel.Text = option
            optionLabel.TextColor3 = Color3.new(1, 1, 1)
            optionLabel.TextScaled = true
            optionLabel.Font = Enum.Font.SourceSans
            optionLabel.Parent = optionFrame
            
            optionCheck.MouseButton1Click:Connect(function()
                local idx = table.find(selected, option)
                if idx then
                    table.remove(selected, idx)
                    TweenService:Create(optionCheck, createTweenInfo(), {BackgroundColor3 = Color3.new(0.5, 0, 0)}):Play()
                else
                    table.insert(selected, option)
                    TweenService:Create(optionCheck, createTweenInfo(), {BackgroundColor3 = Color3.new(0, 0.5, 0)}):Play()
                end
                multiLabel.Text = text .. ": " .. table.concat(selected, ", ")
                callback(selected)
            end)
        end
        
        multiList:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            multiFrame.Size = UDim2.new(1, 0, 0, open and multiList.AbsoluteSize.Y + 30 or 30)
        end)
        
        currentSection = nil
        return multiFrame, function(newSelected) selected = newSelected; callback(selected) end
    end
    
    -- TextInput
    local function TextInput(text, default, callback)
        local inputFrame = createElement(currentSection or (currentTab and currentTab.content) or ContentContainer, {
            type = "Frame",
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
            BorderSizePixel = 0
        })
        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 4)
        inputCorner.Parent = inputFrame
        
        local inputLabel = Instance.new("TextLabel")
        inputLabel.Size = UDim2.new(1, 0, 0, 15)
        inputLabel.BackgroundTransparency = 1
        inputLabel.Text = text
        inputLabel.TextColor3 = Color3.new(1, 1, 1)
        inputLabel.TextScaled = true
        inputLabel.Font = Enum.Font.SourceSans
        inputLabel.TextXAlignment = Enum.TextXAlignment.Left
        inputLabel.Parent = inputFrame
        
        local inputBox = Instance.new("TextBox")
        inputBox.Size = UDim2.new(1, 0, 0, 15)
        inputBox.Position = UDim2.new(0, 0, 0.5, 0)
        inputBox.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
        inputBox.BorderSizePixel = 0
        inputBox.Text = default or ""
        inputBox.TextColor3 = Color3.new(1, 1, 1)
        inputBox.PlaceholderText = "Enter text..."
        inputBox.TextScaled = true
        inputBox.Font = Enum.Font.SourceSans
        inputBox.ClearTextOnFocus = false
        inputBox.Parent = inputFrame
        
        local boxCorner = Instance.new("UICorner")
        boxCorner.CornerRadius = UDim.new(0, 4)
        boxCorner.Parent = inputBox
        
        inputBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                callback(inputBox.Text)
            end
        end)
        
        inputBox.MouseEnter:Connect(function()
            TweenService:Create(inputBox, createTweenInfo(), {BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)}):Play()
        end)
        inputBox.MouseLeave:Connect(function()
            TweenService:Create(inputBox, createTweenInfo(), {BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)}):Play()
        end)
        
        currentSection = nil
        return inputFrame, function(newText) inputBox.Text = newText; callback(newText) end
    end
    
    -- Divider
    local function Divider()
        local div = createElement(currentSection or (currentTab and currentTab.content) or ContentContainer, {
            type = "Frame",
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = Color3.new(0.2, 0.2, 0.2),
            BorderSizePixel = 0
        })
        currentSection = nil
        return div
    end
    
    -- Expose elements to Window for backward compat
    Window.Section = Section
    Window.Button = Button
    Window.Toggle = Toggle
    Window.Slider = Slider
    Window.Dropdown = Dropdown
    Window.MultiDropdown = MultiDropdown
    Window.TextInput = TextInput
    Window.Divider = Divider
    
    return Window
end

return Library
