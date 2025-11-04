local UILibrary = {}
UILibrary.__index = UILibrary

-- Utility function to create instance
local function Create(class, properties)
	local obj = Instance.new(class)
	if properties then
		for k,v in pairs(properties) do
			obj[k] = v
		end
	end
	return obj
end

local function Round(frame, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,radius)
	corner.Parent = frame
end

-- Main Window creator
function UILibrary:CreateWindow(settings)
	settings = settings or {}
	local window = {}

	local title = settings.Title or "Window"
	local size = settings.Size or UDim2.new(0,600,0,400)
	local bgColor = settings.BackgroundColor or Color3.fromRGB(0,0,0)
	local textColor = settings.TextColor or Color3.fromRGB(255,255,255)
	local outlineColor = settings.OutlineColor or Color3.fromRGB(0,162,255)

	local screenGui = Create("ScreenGui", {
		Parent = game:GetService("CoreGui"),
		Name = title.."GUI",
		ResetOnSpawn = false
	})

	local frame = Create("Frame", {
		Parent = screenGui,
		Size = size,
		Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
		BackgroundColor3 = bgColor,
		BorderColor3 = outlineColor,
		BorderSizePixel = 2
	})
	Round(frame,10)

	local titleLabel = Create("TextLabel", {
		Parent = frame,
		Text = title,
		TextColor3 = textColor,
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,30),
		Font = Enum.Font.GothamBold,
		TextSize = 18
	})

	local tabHolder = Create("Frame", {
		Parent = frame,
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,1,-30),
		Position = UDim2.new(0,0,0,30)
	})

	local tabButtons = Create("Frame", {
		Parent = tabHolder,
		Size = UDim2.new(1,0,0,30),
		BackgroundTransparency = 1
	})

	local tabContents = Create("Frame", {
		Parent = tabHolder,
		Size = UDim2.new(1,0,1,-30),
		Position = UDim2.new(0,0,0,30),
		BackgroundTransparency = 1
	})

	local tabs = {}
	local currentTab

	-- Tab creation
	function window:AddTab(name)
		local tab = {}
		tabs[name] = tab

		local btn = Create("TextButton", {
			Parent = tabButtons,
			Text = name,
			Size = UDim2.new(0,100,1,0),
			Position = UDim2.new(0,#tabButtons:GetChildren()*100,0,0),
			BackgroundColor3 = Color3.fromRGB(20,20,20),
			TextColor3 = textColor,
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			TextSize = 14
		})
		Round(btn,6)

		local content = Create("Frame", {
			Parent = tabContents,
			Size = UDim2.new(1,0,1,0),
			BackgroundTransparency = 1,
			Visible = false
		})

		local layout = Create("UIListLayout", {Parent = content, Padding = UDim.new(0,5), SortOrder = Enum.SortOrder.LayoutOrder})

		function tab:AddSection(titleText)
			local section = {}
			local sectionFrame = Create("Frame", {
				Parent = content,
				Size = UDim2.new(1,0,0,30),
				BackgroundColor3 = Color3.fromRGB(30,30,30),
				BorderColor3 = outlineColor,
				BorderSizePixel = 2
			})
			Round(sectionFrame,6)

			local titleLabel = Create("TextLabel", {
				Parent = sectionFrame,
				Text = titleText,
				TextColor3 = textColor,
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,1,0),
				Font = Enum.Font.GothamBold,
				TextSize = 16
			})

			function section:AddDivider(text)
				local divider = Create("TextLabel", {
					Parent = sectionFrame,
					Text = text or "────────",
					TextColor3 = textColor,
					BackgroundTransparency = 1,
					Size = UDim2.new(1,0,0,20),
					Font = Enum.Font.Gotham,
					TextSize = 14
				})
			end

			function section:AddButton(text, callback)
				local button = Create("TextButton", {
					Parent = sectionFrame,
					Text = text,
					Size = UDim2.new(1,0,0,25),
					BackgroundColor3 = Color3.fromRGB(50,50,50),
					TextColor3 = textColor,
					Font = Enum.Font.GothamBold,
					TextSize = 14
				})
				Round(button,6)
				button.MouseButton1Click:Connect(function()
					if callback then callback() end
				end)
			end

			function section:AddToggle(text, callback)
				local toggleFrame = Create("Frame", {
					Parent = sectionFrame,
					Size = UDim2.new(1,0,0,25),
					BackgroundColor3 = Color3.fromRGB(40,40,40),
					BorderColor3 = outlineColor,
					BorderSizePixel = 2
				})
				Round(toggleFrame,6)

				local label = Create("TextLabel", {
					Parent = toggleFrame,
					Text = text,
					TextColor3 = textColor,
					BackgroundTransparency = 1,
					Size = UDim2.new(0.7,0,1,0),
					Font = Enum.Font.Gotham,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					Position = UDim2.new(0,5,0,0)
				})

				local toggleBtn = Create("TextButton", {
					Parent = toggleFrame,
					Size = UDim2.new(0.3,-5,1,0),
					Position = UDim2.new(0.7,5,0,0),
					Text = "OFF",
					BackgroundColor3 = Color3.fromRGB(60,60,60),
					TextColor3 = textColor,
					Font = Enum.Font.GothamBold,
					TextSize = 14
				})
				Round(toggleBtn,6)

				local toggled = false
				toggleBtn.MouseButton1Click:Connect(function()
					toggled = not toggled
					toggleBtn.Text = toggled and "ON" or "OFF"
					if callback then callback(toggled) end
				end)
			end

			function section:AddSlider(text, min, max, callback)
				local sliderFrame = Create("Frame", {
					Parent = sectionFrame,
					Size = UDim2.new(1,0,0,30),
					BackgroundColor3 = Color3.fromRGB(40,40,40),
					BorderColor3 = outlineColor,
					BorderSizePixel = 2
				})
				Round(sliderFrame,6)

				local label = Create("TextLabel", {
					Parent = sliderFrame,
					Text = text,
					TextColor3 = textColor,
					BackgroundTransparency = 1,
					Size = UDim2.new(1,0,0.5,0),
					Font = Enum.Font.Gotham,
					TextSize = 14
				})

				local bar = Create("Frame", {
					Parent = sliderFrame,
					Size = UDim2.new(1, -10,0,10),
					Position = UDim2.new(0,5,0,20),
					BackgroundColor3 = Color3.fromRGB(60,60,60)
				})
				Round(bar,5)

				local handle = Create("Frame", {
					Parent = bar,
					Size = UDim2.new(0,10,1,0),
					BackgroundColor3 = outlineColor
				})
				Round(handle,5)

				local dragging = false
				handle.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
					end
				end)
				handle.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)
				bar.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
						local rel = math.clamp(input.Position.X - bar.AbsolutePosition.X,0,bar.AbsoluteSize.X)
						handle.Size = UDim2.new(0,rel,1,0)
						if callback then callback(min + ((max-min)*(rel/bar.AbsoluteSize.X))) end
					end
				end)
			end

			function section:AddTextBox(placeholder, callback)
				local box = Create("TextBox", {
					Parent = sectionFrame,
					Size = UDim2.new(1,0,0,25),
					BackgroundColor3 = Color3.fromRGB(60,60,60),
					TextColor3 = textColor,
					PlaceholderText = placeholder or "",
					Font = Enum.Font.Gotham,
					TextSize = 14
				})
				Round(box,6)
				box.FocusLost:Connect(function(enterPressed)
					if enterPressed and callback then
						callback(box.Text)
					end
				end)
			end

			return section
		end

		btn.MouseButton1Click:Connect(function()
			if currentTab then currentTab.Visible = false end
			content.Visible = true
			currentTab = content
		end)

		if not currentTab then
			content.Visible = true
			currentTab = content
		end

		return tab
	end

	return window
end

return UILibrary
