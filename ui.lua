
local Library = {Toggle = true, FirstTab = nil, TabCount = 0, ColorTable = {}, CurrentTab = nil, tick = tick(), Connections = {}, flags = {}}
local cloneref = cloneref or function(v) return v; end
local function getservice(v) return cloneref(game:GetService(v)); end
local http_request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request;
local shared = (getgenv and getgenv()) or shared or _G
local ReplicatedStorage = getservice("ReplicatedStorage")
local UserInputService = getservice("UserInputService")
local TweenService = getservice("TweenService")
local HttpService = getservice("HttpService")
local TextService = getservice("TextService")
local RunService = getservice("RunService")
local Players = getservice("Players")
local IsMobile = UserInputService.TouchEnabled 
shared.Dachshund = shared.Dachshund or {}
shared.Dachshund.flags = shared.Dachshund.flags or {}
shared.Dachshund.Elements = shared.Dachshund.Elements or {}
shared.Dachshund.ElementCounter = 0

local function requesturl(i, v)
if RunService:IsStudio() then
return nil
end
if v == nil and not RunService:IsStudio() then
local req = http_request({
Url = i,
Method = "GET"
})
if req.StatusCode ~= 200 then
return nil, req.StatusCode
end
return req.Body
end
local baseurl = "https://raw.githubusercontent.com/nfpw/XXSCRIPT/refs/heads/main/Library/Folder/ModuleFolder.lua"
local req = http_request({
Url = baseurl..i,
Method = "GET"
})
if req.StatusCode ~= 200 then
return nil, req.StatusCode
end
return req.Body
end
local function asset(name: string, v)
if shared.Dachshund.DachshundLoadAssets then
local asset = Assets[name]
if not asset then
return
end
if not getcustomasset then
v.Image = asset.rbxassetid
return
end
if not isfile(asset.filename) then
local success, err = pcall(function()
local content = requesturl(asset.url)
if content then
writefile(asset.filename, content)
end
end)
if not success then
v.Image = asset.rbxassetid
return
end
end
pcall(function()
v.Image = getcustomasset(asset.filename)
end)
end
end
local function makedraggable(ClickObject: GuiObject, Object: GuiObject)
local Dragging = nil
local DragInput = nil
local DragStart = nil
local StartPosition = nil
table.insert(Library.Connections, ClickObject.InputBegan:Connect(function(Input)
if UserInputService:GetFocusedTextBox() == nil then
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
Dragging = true
DragStart = Input.Position
StartPosition = Object.Position
table.insert(Library.Connections, Input.Changed:Connect(function()
if Input.UserInputState == Enum.UserInputState.End then
Dragging = false
end
end))
end
end
end))
table.insert(Library.Connections, ClickObject.InputChanged:Connect(function(Input)
if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
DragInput = Input
end
end))
table.insert(Library.Connections, UserInputService.InputChanged:Connect(function(Input)
if Input == DragInput and Dragging then
local Delta = Input.Position - DragStart
Object.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
end
end))
end
local function makeresizable(MainFrame: GuiObject, MinHeight: number, MaxHeight: number, MinWidth: number, MaxWidth: number)
if MainFrame.Size.X.Offset == 0 or MainFrame.Size.Y.Offset == 0 then
local initialWidth = math.clamp(400, MinWidth, MaxWidth)
local initialHeight = math.clamp(300, MinHeight, MaxHeight)
MainFrame.Size = UDim2.new(0, initialWidth, 0, initialHeight)
end
local CornerResizeHandle = Instance.new("TextButton")
CornerResizeHandle.Name = "CornerResizeHandle"
CornerResizeHandle.Parent = MainFrame
CornerResizeHandle.BackgroundTransparency = 1
CornerResizeHandle.Size = UDim2.new(0, 20, 0, 20)
CornerResizeHandle.Position = UDim2.new(1, -20, 1, -20)
CornerResizeHandle.ZIndex = 11
CornerResizeHandle.Text = ">"
CornerResizeHandle.TextColor3 = Color3.fromRGB(150, 150, 150)
CornerResizeHandle.TextSize = 16
CornerResizeHandle.Font = Enum.Font.SourceSansBold
CornerResizeHandle.Rotation = 45
local Dragging = false
local DraggingCorner = false
local StartPos = nil
local StartSize = nil
local function UpdateTabSizes(NewSize)
local tbContainer = MainFrame:FindFirstChild("Holder"):FindFirstChild("TBContainer")
if tbContainer then
local holder = tbContainer:FindFirstChild("Holder")
if holder then
local tabButtons = {}
for _, child in next, holder:GetChildren() do
if child:IsA("TextButton") then
table.insert(tabButtons, child)
end
end
local tabCount = #tabButtons
if tabCount > 0 then
local buttonWidth = math.floor((NewSize.X.Offset - 19) / tabCount)
for i, TabButton in next, tabButtons do
TabButton.Size = UDim2.new(0, buttonWidth, 1, 0)
TabButton.Position = UDim2.new(0, (buttonWidth * (i-1)) + (i * 2), 0, 0)
end
end
end
end
local tContainer = MainFrame:FindFirstChild("Holder"):FindFirstChild("TContainer")
if tContainer then
for _, Tab in next, tContainer:GetChildren() do
if Tab:IsA("ScrollingFrame") then
Tab.Size = UDim2.new(1, 0, 1, 0)
if Tab:FindFirstChild("LeftSide") then
Tab.LeftSide.Size = UDim2.new(0.5, -5, 1, 0)
end
if Tab:FindFirstChild("RightSide") then
Tab.RightSide.Size = UDim2.new(0.5, -5, 1, 0)
end
Tab.CanvasSize = UDim2.new(0, 0, 0, math.max(
Tab.LeftSide and Tab.LeftSide.ListLayout.AbsoluteContentSize.Y or 0,
Tab.RightSide and Tab.RightSide.ListLayout.AbsoluteContentSize.Y or 0) + 15)
end
end
end
end
end
task.spawn(function()
repeat task.wait() until MainFrame:FindFirstChild("Holder") and MainFrame.Holder:FindFirstChild("TBContainer") and MainFrame.Holder.TBContainer:FindFirstChild("Holder")
task.wait(1.4)
UpdateTabSizes(MainFrame.Size)
end)
table.insert(Library.Connections, CornerResizeHandle.InputBegan:Connect(function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
DraggingCorner = true
StartPos = Input.Position
StartSize = MainFrame.Size
table.insert(Library.Connections, Input.Changed:Connect(function()
if Input.UserInputState == Enum.UserInputState.End then
DraggingCorner = false
end
end))
end
end))
table.insert(Library.Connections, UserInputService.InputChanged:Connect(function(Input)
if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
local Delta = Input.Position.Y - StartPos
local NewHeight = math.clamp(StartSize.Y.Offset + Delta, MinHeight, MaxHeight)
local NewSize = UDim2.new(StartSize.X.Scale, StartSize.X.Offset, 0, NewHeight)
MainFrame.Size = NewSize
UpdateTabSizes(NewSize)
elseif DraggingCorner and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
local Delta = Input.Position - StartPos
local NewWidth = math.clamp(StartSize.X.Offset + Delta.X, MinWidth, MaxWidth)
local NewHeight = math.clamp(StartSize.Y.Offset + Delta.Y, MinHeight, MaxHeight)
local NewSize = UDim2.new(0, NewWidth, 0, NewHeight)
MainFrame.Size = NewSize
UpdateTabSizes(NewSize)
end
end))
end
local function crebutton(Screen: GuiObject, Main: GuiObject, Config: {Color: Color3}, Toggle: (boolean?) -> ())
if not IsMobile then return nil end
local aakdkakak = 10
local ReopenButton = Instance.new("Frame")
ReopenButton.Name = "ReopenButton"
ReopenButton.Parent = Screen
ReopenButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ReopenButton.Size = UDim2.new(0, 45, 0, 45)
ReopenButton.Position = UDim2.new(0.85, 50, 0.8, -200)
ReopenButton.Visible = false
ReopenButton.ZIndex = aakdkakak
local borderFrame1 = Instance.new("Frame")
borderFrame1.Name = "BorderFrame1"
borderFrame1.Size = UDim2.new(1, -2, 1, -2)
borderFrame1.Position = UDim2.new(0, 1, 0, 1)
borderFrame1.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
borderFrame1.BorderSizePixel = 0
borderFrame1.Parent = ReopenButton
borderFrame1.ZIndex = aakdkakak + 1
local borderFrame2 = Instance.new("Frame")
borderFrame2.Name = "BorderFrame2"
borderFrame2.Size = UDim2.new(1, -2, 1, -2)
borderFrame2.Position = UDim2.new(0, 1, 0, 1)
borderFrame2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
borderFrame2.BorderSizePixel = 0
borderFrame2.Parent = borderFrame1
borderFrame2.ZIndex = aakdkakak + 2
local borderFrame3 = Instance.new("Frame")
borderFrame3.Name = "BorderFrame3"
borderFrame3.Size = UDim2.new(1, -6, 1, -6)
borderFrame3.Position = UDim2.new(0, 3, 0, 3)
borderFrame3.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
borderFrame3.BorderSizePixel = 0
borderFrame3.Parent = borderFrame2
borderFrame3.ZIndex = aakdkakak + 3
local innerFrame = Instance.new("Frame")
innerFrame.Name = "InnerFrame"
innerFrame.Size = UDim2.new(1, -2, 1, -2)
innerFrame.Position = UDim2.new(0, 1, 0, 1)
innerFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
innerFrame.BorderSizePixel = 0
innerFrame.Parent = borderFrame3
innerFrame.ZIndex = aakdkakak + 4
local frameGradient = Instance.new("UIGradient")
frameGradient.Name = "FrameGradient"
frameGradient.Rotation = 90
frameGradient.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Config.Color:Lerp(Color3.fromRGB(0, 0, 0), 0.1)),
ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 0, 0)),
ColorSequenceKeypoint.new(1, Config.Color:Lerp(Color3.fromRGB(0, 0, 0), 0.1))
})
frameGradient.Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 0.7),
NumberSequenceKeypoint.new(0.5, 0.9),
NumberSequenceKeypoint.new(1, 0.7)
})
frameGradient.Parent = innerFrame
local gradientFrame = Instance.new("Frame")
gradientFrame.Name = "GradientFrame"
gradientFrame.Size = UDim2.new(1, 0, 0, 1)
gradientFrame.Position = UDim2.new(0, 0, 0, 0)
gradientFrame.BackgroundColor3 = Config.Color
gradientFrame.BorderSizePixel = 0
gradientFrame.Parent = innerFrame
gradientFrame.ZIndex = aakdkakak + 6
local gradient = Instance.new("UIGradient")
gradient.Name = "TopGradient"
gradient.Color = ColorSequence.new{
ColorSequenceKeypoint.new(0, Config.Color),
ColorSequenceKeypoint.new(0.25, Config.Color:Lerp(Color3.fromRGB(180, 100, 160), 0.5)),
ColorSequenceKeypoint.new(0.75, Config.Color:Lerp(Color3.fromRGB(180, 230, 100), 0.5)),
ColorSequenceKeypoint.new(1, Config.Color:Lerp(Color3.fromRGB(180, 100, 160), 0.5))
}
gradient.Parent = gradientFrame
local lineee = Instance.new("Frame")
lineee.Name = "lineee"
lineee.Size = UDim2.new(1, 0, 0, 1)
lineee.Position = UDim2.new(0, 0, 0, 1)
lineee.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
lineee.BackgroundTransparency = 0.2
lineee.BorderSizePixel = 0
lineee.Parent = innerFrame
lineee.ZIndex = aakdkakak + 8
local textLabel = Instance.new("TextLabel")
textLabel.Name = "ButtonText"
textLabel.Size = UDim2.new(1, 0, 1, 0)
textLabel.Position = UDim2.new(0, 0, 0, 0)
textLabel.BackgroundTransparency = 1
textLabel.Text = "+"
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.TextScaled = true
textLabel.TextSize = 30
textLabel.Font = Enum.Font.Code
textLabel.TextXAlignment = Enum.TextXAlignment.Center
textLabel.TextYAlignment = Enum.TextYAlignment.Center
textLabel.Parent = innerFrame
textLabel.ZIndex = aakdkakak + 9
local textGradient = Instance.new("UIGradient")
textGradient.Name = "TextGradient"
textGradient.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Config.Color),
ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
})
textGradient.Transparency = NumberSequence.new(0.5)
textGradient.Parent = textLabel
table.insert(Library.ColorTable, gradientFrame)
table.insert(Library.ColorTable, textLabel)
table.insert(Library.ColorTable, frameGradient)
table.insert(Library.ColorTable, gradient)
makedraggable(ReopenButton, ReopenButton)
local deltabooleanomg = false
table.insert(Library.Connections, innerFrame.InputEnded:Connect(function(Input)
if Input.UserInputType == Enum.UserInputType.Touch or Input.UserInputType == Enum.UserInputType.MouseButton1 then
deltabooleanomg = not deltabooleanomg
Toggle(deltabooleanomg)
end
end))
task.delay(2, function()
ReopenButton.Visible = true
end)
return ReopenButton
end
function Library:CreateWindow(Config: {WindowName: string, Color: Color3, MinHeight: number?, MaxHeight: number?, InitialHeight: number?}, Parent: Instance): Window
local WindowInit: Window = {}
if Config == nil then
Config = {
WindowName = "Dachshund hub",
Color = Color3.fromRGB(0, 162, 255),
Keybind = Enum.KeyCode.RightShift,
MinHeight = 100,
MaxHeight = 600,
InitialHeight = 400,
MinWidth = 300,
MaxWidth = 800,
InitialWidth = 500,
Assets = false
}
else
if Config.Assets == nil then
Config.Assets = false
end
Config.Keybind = Config.Keybind or Enum.KeyCode.RightShift
Config.WindowName = "Dachshund hub"
Config.Color = Config.Color or Color3.fromRGB(0, 162, 255)
Config.MinHeight = Config.MinHeight or 100
Config.MaxHeight = Config.MaxHeight or 600
Config.InitialHeight = Config.InitialHeight or 400
Config.MinWidth = Config.MinWidth or 300
Config.MaxWidth = Config.MaxWidth or 800
Config.InitialWidth = Config.InitialWidth or 500
end
if Config.Assets then
shared.Dachshund.DachshundLoadAssets = true
end
local Folder = nil
if RunService:IsStudio() then
Folder = ReplicatedStorage.Bracket
else
Folder = loadstring(requesturl("https://raw.githubusercontent.com/nfpw/XXSCRIPT/refs/heads/main/Library/Folder/ModuleFolder.lua"))()
end
repeat wait() until Folder ~= nil
local Screen = Folder.Bracket:Clone()
local Main = Screen.Main
local Holder = Main.Holder
local Topbar = Main.Topbar
local TContainer = Holder.TContainer
local TBContainer = Holder.TBContainer.Holder
Main.Size = UDim2.new(0, Config.InitialWidth, 0, Config.InitialHeight)
makeresizable(Main, Config.MinHeight, Config.MaxHeight, Config.MinWidth, Config.MaxWidth)
Screen.Name = HttpService:GenerateGUID(false)
Screen.Parent = Parent
Topbar.WindowName.Text = Config.WindowName
function Library:SetWindowName(str)
Topbar.WindowName.Text = str
end
local TestScreenGui = Instance.new("ScreenGui")
TestScreenGui.Parent = Screen
local Notifications = nil
if RunService:IsStudio() then
Notifications = require(ReplicatedStorage.notif).New(TestScreenGui, Color3.fromRGB(0, 162, 255))
else
Notifications = loadstring(requesturl("https://raw.githubusercontent.com/nfpw/XXSCRIPT/refs/heads/main/Library/NotificationModule.lua"))().New(TestScreenGui, Config.Color)
end
repeat wait() until Notifications ~= nil
local Toggle; Toggle = function(State)
if State then
Main.Visible = true
if WindowInit.ReopenButton then
WindowInit.ReopenButton.Visible = true
end
else
for _, Pallete in next, Screen:GetChildren() do
if Pallete:IsA("Frame") and Pallete.Name ~= "Main" and Pallete.Name ~= "Hud" and Pallete.Name ~= "KeybindViewer" and Pallete.Name ~= "ToggleList" then
Pallete.Visible = false
end
end
Main.Visible = false
if WindowInit.ReopenButton then
WindowInit.ReopenButton.Visible = true
end
end
Library.Toggle = State
end
local ReopenButton = crebutton(Screen, Main, Config, Toggle)
local SearchBar = Topbar.SearchBar
table.insert(Library.Connections, SearchBar.MouseEnter:Connect(function()
if not SearchBar:IsFocused() then
TweenService:Create(SearchBar, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
end
end))
table.insert(Library.Connections, SearchBar.MouseLeave:Connect(function()
if not SearchBar:IsFocused() then
TweenService:Create(SearchBar, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
end
end))
table.insert(Library.Connections, SearchBar.Focused:Connect(function()
TweenService:Create(SearchBar, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
end))
table.insert(Library.Connections, SearchBar.FocusLost:Connect(function()
TweenService:Create(SearchBar, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
end))
--makedraggable(Topbar, Main)
makedraggable(Main, Main)
local Close = Topbar.Close
if IsMobile then
table.insert(Library.Connections, Close.InputBegan:Connect(function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
Close.TextColor3 = Config.Color
end
end))
table.insert(Library.Connections, Close.InputEnded:Connect(function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
Close.TextColor3 = Color3.fromRGB(150, 150, 150)
Screen.ToolTip.Visible = false
Toggle(false)
end
end))
else
Close.Visible = false
end
WindowInit.ReopenButton = ReopenButton
WindowInit.ToggleVisibility = Toggle
table.insert(Library.ColorTable, ReopenButton)
local AllSections = {}
local IsTabSwitching = false
local function FilterSections(SearchText)
SearchText = string.lower(SearchText)
local CurrentTab = Library.CurrentTab or TContainer:FindFirstChild(Library.FirstTab .. " T")
if not CurrentTab then return end
for SectionFrame, SectionData in next, AllSections do
if SectionData.TabParent == CurrentTab then
local SectionName = SectionData.Name
local Found = string.find(string.lower(SectionName), SearchText)
if SearchText == "" then
SectionFrame.Visible = true
SectionFrame.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
if SectionFrame:FindFirstChild("Highlight") then
SectionFrame.Highlight:Destroy()
end
else
if Found then
SectionFrame.Visible = true
SectionFrame.Title.TextColor3 = Config.Color
if not SectionFrame:FindFirstChild("Highlight") then
local Highlight = Instance.new("Frame")
Highlight.Name = "Highlight"
Highlight.Parent = SectionFrame
Highlight.BackgroundColor3 = Config.Color
Highlight.BorderSizePixel = 0
Highlight.Position = UDim2.new(0, 0, 1, 0)
Highlight.Size = UDim2.new(1, 0, 0, 2)
Highlight.ZIndex = 2
table.insert(Library.ColorTable, Highlight)
else
SectionFrame.Highlight.BackgroundColor3 = Config.Color
end
else
SectionFrame.Visible = false
SectionFrame.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
if SectionFrame:FindFirstChild("Highlight") then
SectionFrame.Highlight:Destroy()
end
end
end
end
end
end
table.insert(Library.Connections, SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
FilterSections(SearchBar.Text)
end))
table.insert(Library.Connections, SearchBar.Changed:Connect(function(Property)
if Property == "Text" then
FilterSections(SearchBar.Text)
end
end))
local TransitionFrame = nil
local function CreateTransitionFrame(Parent, Color)
if TransitionFrame then
TransitionFrame:Destroy()
end
TransitionFrame = Instance.new("Frame")
TransitionFrame.Name = "TransitionFrame"
TransitionFrame.Parent = Parent
TransitionFrame.BackgroundColor3 = Color or Color3.fromRGB(0, 0, 0)
TransitionFrame.BorderSizePixel = 0
TransitionFrame.Size = UDim2.new(0, 0, 1, 0)
TransitionFrame.Position = UDim2.new(1, 0, 0, 0)
TransitionFrame.AnchorPoint = Vector2.new(1, 0)
TransitionFrame.ZIndex = 10
if shared.Dachshund and shared.Dachshund.DachshundLoadAssets then
TransitionFrame.Visible = false
else
TransitionFrame.Visible = true
end
local gradientClone = Folder.UIGradient:Clone()
gradientClone.Parent = TransitionFrame
return TransitionFrame
end
local function AnimateTabOut(Tab, TabButton, Callback)
if not Tab or not Tab.Visible then
if Callback then Callback() end
return
end
local bac = Tab.BackgroundColor3 or Color3.fromRGB(0, 0, 0)
local transition = CreateTransitionFrame(Tab.Parent, bac)
local slideInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local slideTween = TweenService:Create(transition, slideInfo, {
Size = UDim2.new(1, 0, 1, 0)
})
if TabButton then
TweenService:Create(TabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
BackgroundTransparency = 1
}):Play()
local underline = TabButton:FindFirstChild("Underline")
if underline then
TweenService:Create(underline, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
Size = UDim2.new(0, 0, 0, 2),
Position = UDim2.new(0.5, 0, 1, -2)
}):Play()
end
end
table.insert(Library.Connections, slideTween.Completed:Connect(function()
Tab.Visible = false
if Callback then Callback() end
end))
slideTween:Play()
end
local function AnimateTabIn(Tab, TabButton)
if not Tab then return end
Tab.Visible = true
if TransitionFrame then
local slideInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
TransitionFrame.AnchorPoint = Vector2.new(0, 0)
TransitionFrame.Position = UDim2.new(0, 0, 0, 0)
local slideTween = TweenService:Create(TransitionFrame, slideInfo, {
Size = UDim2.new(0, 0, 1, 0)
})
slideTween.Completed:Connect(function()
if TransitionFrame then
TransitionFrame:Destroy()
TransitionFrame = nil
end
end)
slideTween:Play()
end
if TabButton then
TweenService:Create(TabButton, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
BackgroundTransparency = 0
}):Play()
local underline = TabButton:FindFirstChild("Underline")
if underline then
underline.Visible = true
underline.Size = UDim2.new(0, 0, 0, 2)
underline.Position = UDim2.new(0.5, 0, 1, -2)
TweenService:Create(underline, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
Size = UDim2.new(1, 0, 0, 2),
Position = UDim2.new(0, 0, 1, -2)
}):Play()
end
end
end
local function SwitchToTab(NewTab, NewTabButton)
if IsTabSwitching or Library.CurrentTab == NewTab then return end
IsTabSwitching = true
for _, element in next, shared.Dachshund.Elements do
if element.Type == "ColorPicker" then
element:ClosePallete()
end
end
local OldTab = Library.CurrentTab
local OldTabButton = nil
if OldTab then
local oldTabName = OldTab.Name:gsub(" T$", " TB")
OldTabButton = TBContainer:FindFirstChild(oldTabName)
end
AnimateTabOut(OldTab, OldTabButton, function()
Library.CurrentTab = NewTab
AnimateTabIn(NewTab, NewTabButton)
SearchBar.Text = ""
FilterSections("")
IsTabSwitching = false
end)
end
local function CloseAll()
for _, Tab in next, TContainer:GetChildren() do
if Tab:IsA("ScrollingFrame") then
Tab.Visible = false
end
end
end
local function ResetAll()
for _, TabButton in next, TBContainer:GetChildren() do
if TabButton:IsA("TextButton") then
TabButton.BackgroundTransparency = 1
local underline = TabButton:FindFirstChild("Underline")
if underline then
underline.Visible = false
end
end
end
for _, TabButton in next, TBContainer:GetChildren() do
if TabButton:IsA("TextButton") then
TabButton.Size = UDim2.new(0, 480 / Library.TabCount, 1, 0)
end
end
for _, Pallete in next, Screen:GetChildren() do
if Pallete:IsA("Frame") and Pallete.Name ~= "Main" then
Pallete.Visible = false
end
end
for SectionFrame, _ in next, AllSections do
SectionFrame.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
if SectionFrame:FindFirstChild("Highlight") then
SectionFrame.Highlight:Destroy()
end
end
end
local function KeepFirst()
for _, Tab in next, TContainer:GetChildren() do
if Tab:IsA("ScrollingFrame") then
if Tab.Name == Library.FirstTab .. " T" then
Tab.Visible = true
Library.CurrentTab = Tab
else
Tab.Visible = false
end
end
end
for _, TabButton in next, TBContainer:GetChildren() do
if TabButton:IsA("TextButton") then
if TabButton.Name == Library.FirstTab .. " TB" then
TabButton.BackgroundTransparency = 0
local underline = TabButton:FindFirstChild("Underline")
if underline then
underline.Visible = true
end
else
TabButton.BackgroundTransparency = 1
end
end
end
end
local function ChangeColor(Color)
if not Screen or not Screen.Parent then
return
end
Config.Color = Color
Notifications.AccentColor = Color
for i, v in next, Library.ColorTable do
if not v or not v.Parent then
table.remove(Library.ColorTable, i)
continue
end
local isButtonElement = false
if v.Parent and v.Parent.Name and string.find(v.Parent.Name, " B$") then
isButtonElement = true
elseif v.Name and string.find(v.Name, " B$") then
isButtonElement = true
elseif v.ClassName == "TextButton" or v.ClassName == "ImageButton" then
if v.Parent and v.Parent.Parent and string.find(tostring(v.Parent.Parent), "Button") then
isButtonElement = true
end
end
if not isButtonElement then
if v:IsA("ImageButton") then
v.ImageColor3 = Color
elseif v.Name == "GlowEffect" then
v.BackgroundColor3 = Color
elseif v.Name == "WindowGlow" and v:IsA("UIStroke") then
v.Color = Color
elseif v.Name == "GlowFrame" and v:IsA("Frame") then
v.BackgroundColor3 = Color
elseif v:IsA("TextLabel") and v.Name == "ButtonText" then
v.TextColor3 = Color3.fromRGB(255, 255, 255)
if v:FindFirstChild("TextGradient") then
v.TextGradient.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color),
ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
})
end
elseif v:IsA("Frame") and v.Name == "GradientFrame" then
v.BackgroundColor3 = Color
elseif v:IsA("UIGradient") then
if v.Name == "TopGradient" then
v.Color = ColorSequence.new{
ColorSequenceKeypoint.new(0, Color),
ColorSequenceKeypoint.new(0.25, Color:Lerp(Color3.fromRGB(180, 100, 160), 0.5)),
ColorSequenceKeypoint.new(0.75, Color:Lerp(Color3.fromRGB(180, 230, 100), 0.5)),
ColorSequenceKeypoint.new(1, Color:Lerp(Color3.fromRGB(180, 100, 160), 0.5))
}
elseif v.Name == "FrameGradient" then
v.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color:Lerp(Color3.fromRGB(0, 0, 0), 0.1)),
ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 0, 0)),
ColorSequenceKeypoint.new(1, Color:Lerp(Color3.fromRGB(0, 0, 0), 0.1))
})
elseif v.Name == "TextGradient" then
v.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color),
ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
})
end
else
local nognig = false
local bipbopt = false
if v.Parent and v.Parent.Name and string.find(v.Parent.Name, " T$") and v.Name == "Toggle" then
nognig = true
end
if v.Parent and v.Parent.Name and string.find(v.Parent.Name, " T$") then
if v.Name == "Background" or v.Name == "Title" then
bipbopt = true
end
end
if not nognig and not bipbopt then
v.BackgroundColor3 = Color
end
end
end
end
for UniqueID, Element in next, shared.Dachshund.Elements do
if not Element or (Element.Object and not Element.Object.Parent) then
shared.Dachshund.Elements[UniqueID] = nil
continue
end
if Element.Type == "Toggle" and Element.UpdateColors then
Element:UpdateColors()
elseif Element.Type == "TextBox" and Element.UpdateColors then
Element:UpdateColors()
elseif Element.Type == "Button" and Element.UpdateColors then
Element:UpdateColors()
end
end
if SearchBar and SearchBar.Text ~= "" then
FilterSections(SearchBar.Text)
end
end
local function ChangeFont(Font)
if not Screen or not Screen.Parent then return end
local function UpdateElementFont(element)
if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
element.Font = Font
end
end
for _, child in next, Screen:GetDescendants() do
UpdateElementFont(child)
end
if Notifications and Notifications.Container then
for _, child in next, Notifications.Container:GetDescendants() do
UpdateElementFont(child)
end
end
for UniqueID, Element in next, shared.Dachshund.Elements do
if not Element or (Element.Object and not Element.Object.Parent) then
shared.Dachshund.Elements[UniqueID] = nil
continue
end
if Element.UpdateFont then
Element:UpdateFont(Font)
elseif Element.Object then
UpdateElementFont(Element.Object)
end
end
end
function WindowInit:ChangeColor(Color)
ChangeColor(Color)
end
function WindowInit:Toggle(State)
Toggle(State)
end
function WindowInit:SetBackground(ImageId)
if shared.Dachshund.DachshundLoadAssets then
Holder.Image = ImageId
end
end
function WindowInit:Notify(title, content, duration)
duration = duration or 15
Notifications:CreateNotification(title, content, duration)
end
function WindowInit:SetBackgroundColor(Color)
Holder.ImageColor3 = Color
end
function WindowInit:SetBackgroundTransparency(Transparency)
Holder.ImageTransparency = Transparency
end
function WindowInit:SetTileOffset(Offset)
Holder.TileSize = UDim2.new(0, Offset, 0, Offset)
end
function WindowInit:SetTileScale(Scale)
Holder.TileSize = UDim2.new(Scale, 0, Scale, 0)
end
function WindowInit:SetFont(Font)
ChangeFont(Font)
end
function WindowInit:CreateTab(Name: string): Tab
local TabInit: Tab = {}
local Tab = Folder.Tab:Clone()
local TabButton = Folder.TabButton:Clone()
Library.Connections = Library.Connections or {}
Tab.Name = Name .. " T"
Tab.Parent = TContainer
TabButton.Name = Name .. " TB"
TabButton.Parent = TBContainer
TabButton.Title.Text = Name
TabButton.BackgroundColor3 = Config.Color
local Underline = TabButton.Underline
Underline.BackgroundColor3 = Config.Color
table.insert(Library.ColorTable, Underline)
table.insert(Library.ColorTable, TabButton)
Library.TabCount = Library.TabCount + 1
if Library.TabCount == 1 then
Library.FirstTab = Name
Underline.Visible = true
end
CloseAll()
ResetAll()
KeepFirst()
local function GetSide(Longest)
if Longest then
if Tab.LeftSide.ListLayout.AbsoluteContentSize.Y > Tab.RightSide.ListLayout.AbsoluteContentSize.Y then
return Tab.LeftSide
else
return Tab.RightSide
end
else
if Tab.LeftSide.ListLayout.AbsoluteContentSize.Y > Tab.RightSide.ListLayout.AbsoluteContentSize.Y then
return Tab.RightSide
else
return Tab.LeftSide
end
end
end
table.insert(Library.Connections, TabButton.InputBegan:Connect(function(Input)
if not TabButton or not TabButton.Parent then return end
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
SwitchToTab(Tab, TabButton)
end
end))
table.insert(Library.Connections, TabButton.MouseEnter:Connect(function()
if not TabButton or not TabButton.Parent then return end
if Library.CurrentTab ~= Tab then
TweenService:Create(TabButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
BackgroundTransparency = 0.7
}):Play()
end
end))
table.insert(Library.Connections, TabButton.MouseLeave:Connect(function()
if not TabButton or not TabButton.Parent then return end
if Library.CurrentTab ~= Tab then
TweenService:Create(TabButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
BackgroundTransparency = 1
}):Play()
end
end))
table.insert(Library.Connections, Tab.LeftSide.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
if not Tab or not Tab.Parent then return end
if GetSide(true).Name == Tab.LeftSide.Name then
Tab.CanvasSize = UDim2.new(0, 0, 0, Tab.LeftSide.ListLayout.AbsoluteContentSize.Y + 15)
else
Tab.CanvasSize = UDim2.new(0, 0, 0, Tab.RightSide.ListLayout.AbsoluteContentSize.Y + 15)
end
end))
table.insert(Library.Connections, Tab.RightSide.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
if not Tab or not Tab.Parent then return end
if GetSide(true).Name == Tab.LeftSide.Name then
Tab.CanvasSize = UDim2.new(0, 0, 0, Tab.LeftSide.ListLayout.AbsoluteContentSize.Y + 15)
else
Tab.CanvasSize = UDim2.new(0, 0, 0, Tab.RightSide.ListLayout.AbsoluteContentSize.Y + 15)
end
end))
function TabInit:CreateSection(Name: string, Side: string?): Section
local SectionInit: Section = {}
local Section = Folder.Section:Clone()
Section.Name = Name .. " S"
Library.Connections = Library.Connections or {}
local sslsid
if Side then
Side = Side:lower()
if Side == "left" then
sslsid = Tab.LeftSide
elseif Side == "right" then
sslsid = Tab.RightSide
else
sslsid = GetSide(false)
end
else
sslsid = GetSide(false)
end
Section.Parent = sslsid
Section.Title.Text = Name
Section.Title.Size = UDim2.new(0, Section.Title.TextBounds.X + 10, 0, 2)
AllSections[Section] = {
Name = Name,
TabParent = Tab
}
if string.find(Section.Parent.Name:lower(), "left") then
Section.Parent.Padding.PaddingRight = UDim.new(0, 3)
elseif string.find(Section.Parent.Name:lower(), "right") then
Section.Parent.Padding.PaddingLeft = UDim.new(0, 3)
end
table.insert(Library.Connections, Section.Container.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
if not Section or not Section.Parent then return end
Section.Size = UDim2.new(1, 0, 0, Section.Container.ListLayout.AbsoluteContentSize.Y + 15)
end))
function SectionInit:SetVisible(Visible: boolean)
Section.Visible = Visible
end
function SectionInit:IsVisible(): boolean
return Section.Visible
end
function SectionInit:ToggleVisibility()
Section.Visible = not Section.Visible
return Section.Visible
end
function SectionInit:CreateLabel(Name: string, WrapText: boolean?): Element
local LabelInit: Element = {}
shared.Dachshund.ElementCounter += 1
local UniqueID = Name .. " - " .. shared.Dachshund.ElementCounter
local Label = Folder.Label:Clone()
Label.Name = Name .. " L"
Label.Parent = Section.Container
Label.Text = Name
Label.TextWrapped = WrapText or false
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
if WrapText then
Label.Size = UDim2.new(1, -10, 0, 0)
Label.AutomaticSize = Enum.AutomaticSize.Y
else
Label.AutomaticSize = Enum.AutomaticSize.None
Label.Size = UDim2.new(1, -10, 0, Label.TextBounds.Y)
end
function LabelInit:SetVisible(Visible: boolean)
if Label and Label.Parent then
Label.Visible = Visible
end
end
function LabelInit:IsVisible(): boolean
return Label and Label.Parent and Label.Visible
end
function LabelInit:ToggleVisibility()
if Label and Label.Parent then
Label.Visible = not Label.Visible
return Label.Visible
end
return false
end
function LabelInit:UpdateText(Text)
if Label and Label.Parent then
Label.Text = Text
if not WrapText then
Label.Size = UDim2.new(1, -10, 0, Label.TextBounds.Y)
end
end
end
function LabelInit:SetWrapText(Wrap: boolean)
if Label and Label.Parent then
Label.TextWrapped = Wrap
if Wrap then
Label.AutomaticSize = Enum.AutomaticSize.Y
Label.Size = UDim2.new(1, -10, 0, 0)
else
Label.AutomaticSize = Enum.AutomaticSize.None
Label.Size = UDim2.new(1, -10, 0, Label.TextBounds.Y)
end
end
end
LabelInit.Type = "Label"
LabelInit.UniqueID = UniqueID
shared.Dachshund.Elements[UniqueID] = LabelInit
return LabelInit
end
function SectionInit:CreateButton(Name: string, Callback: () -> (), WrapText: boolean?): Element
local ButtonInit: Element = {}
shared.Dachshund.ElementCounter += 1
local UniqueID = Name .. " - " .. shared.Dachshund.ElementCounter
local Button = Folder.Button:Clone()
Button.Name = Name .. " B"
Button.Parent = Section.Container
Button.Title.Text = Name
Button.Title.TextWrapped = WrapText or false
Button.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Library.Connections = Library.Connections or {}
if WrapText then
Button.Title.AutomaticSize = Enum.AutomaticSize.Y
Button.Title.Size = UDim2.new(1, -10, 0, 0)
Button.AutomaticSize = Enum.AutomaticSize.Y
Button.Size = UDim2.new(1, -10, 0, 0)
else
Button.Title.AutomaticSize = Enum.AutomaticSize.None
Button.AutomaticSize = Enum.AutomaticSize.None
Button.Size = UDim2.new(1, -10, 0, Button.Title.TextBounds.Y + 5)
end
local DefaultColor = Color3.fromRGB(0, 0, 0)
Button.BackgroundColor3 = DefaultColor
local IsPressed = false
local IsHovered = false
table.insert(Library.ColorTable, Button)
local TweenInfoe = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local function UpdateButtonColor()
if not Button or not Button.Parent then return end
local TargetColor = IsPressed and Config.Color or IsHovered and Color3.fromRGB(60, 60, 60) or DefaultColor
TweenService:Create(Button, TweenInfoe, {BackgroundColor3 = TargetColor}):Play()
end
local function SimulateButtonPress()
if not Button or not Button.Parent then return end
IsPressed = true
UpdateButtonColor()
task.delay(0.1, function()
if Button and Button.Parent then
IsPressed = false
UpdateButtonColor()
end
end)
end
local ButtonConnections = {}
table.insert(ButtonConnections, Button.InputBegan:Connect(function(Input)
if not Button or not Button.Parent then return end
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
IsPressed = true
UpdateButtonColor()
end
end))
table.insert(ButtonConnections, Button.InputEnded:Connect(function(Input)
if not Button or not Button.Parent then return end
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
IsPressed = false
UpdateButtonColor()
Callback()
end
end))
table.insert(ButtonConnections, Button.MouseEnter:Connect(function()
if not Button or not Button.Parent then return end
IsHovered = true
if not IsPressed then
UpdateButtonColor()
end
end))
table.insert(ButtonConnections, Button.MouseLeave:Connect(function()
if not Button or not Button.Parent then return end
IsHovered = false
UpdateButtonColor()
end))
for _, connection in next, ButtonConnections do
table.insert(Library.Connections, connection)
end
function ButtonInit:SetVisible(Visible: boolean)
if Button and Button.Parent then
Button.Visible = Visible
end
end
function ButtonInit:IsVisible(): boolean
return Button and Button.Parent and Button.Visible
end
function ButtonInit:ToggleVisibility()
if Button and Button.Parent then
Button.Visible = not Button.Visible
end
end
function ButtonInit:UpdateColors()
UpdateButtonColor()
end
function ButtonInit:SetWrapText(Wrap: boolean)
if Button and Button.Parent then
Button.Title.TextWrapped = Wrap
if Wrap then
Button.Title.AutomaticSize = Enum.AutomaticSize.Y
Button.Title.Size = UDim2.new(1, -10, 0, 0)
Button.AutomaticSize = Enum.AutomaticSize.Y
Button.Size = UDim2.new(1, -10, 0, 0)
else
Button.Title.AutomaticSize = Enum.AutomaticSize.None
Button.AutomaticSize = Enum.AutomaticSize.None
Button.Size = UDim2.new(1, -10, 0, Button.Title.TextBounds.Y + 5)
end
end
end
local KeybindObject = nil
function ButtonInit:CreateKeybind(Bind, KeybindCallback)
if UserInputService.TouchEnabled then
return {
SetBind = function() end,
GetBind = function() return Enum.KeyCode.Unknown end
}
end
local KeybindInit = {}
Bind = (typeof(Bind) == "EnumItem" and tostring(Bind):gsub("Enum.KeyCode.", "")) or Bind or "NONE"
local WaitingForBind = false
local Selected = Bind
local Blacklist = {}
Button.Keybind.Visible = true
Button.Keybind.Text = "[ " .. Bind .. " ]"
Button.Keybind.TextColor3 = Color3.fromRGB(255, 255, 255)
table.insert(Library.Connections, Button.Keybind.MouseButton1Click:Connect(function()
Button.Keybind.Text = "[ ... ]"
WaitingForBind = true
local keybindFlash = TweenService:Create(Button.Keybind,
TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
TextTransparency = 0.5
})
keybindFlash:Play()
local connection; connection = Button.Keybind:GetPropertyChangedSignal("Text"):Connect(function()
if Button.Keybind.Text ~= "[ ... ]" then
keybindFlash:Cancel()
Button.Keybind.TextTransparency = 0
connection:Disconnect()
end
end)
table.insert(Library.Connections, connection)
end))
table.insert(Library.Connections, Button.Keybind.MouseButton2Click:Connect(function()
Button.Keybind.Text = "[ NONE ]"
Selected = "NONE"
end))
table.insert(Library.Connections, Button.Keybind:GetPropertyChangedSignal("TextBounds"):Connect(function()
Button.Keybind.Size = UDim2.new(0, Button.Keybind.TextBounds.X, 1, 0)
end))
table.insert(Library.Connections, UserInputService.InputBegan:Connect(function(Input)
if UserInputService:GetFocusedTextBox() == nil then
if WaitingForBind and Input.UserInputType == Enum.UserInputType.Keyboard then
local Key = tostring(Input.KeyCode):gsub("Enum.KeyCode.", "")
if not table.find(Blacklist, Key) then
Button.Keybind.Text = "[ " .. Key .. " ]"
Selected = Key
if KeybindCallback then
KeybindCallback(Key)
end
else
Button.Keybind.Text = "[ NONE ]"
Selected = "NONE"
end
WaitingForBind = false
elseif Input.UserInputType == Enum.UserInputType.Keyboard then
local Key = tostring(Input.KeyCode):gsub("Enum.KeyCode.", "")
if Key == Selected and Selected ~= "NONE" then
SimulateButtonPress()
Callback()
if KeybindCallback then
KeybindCallback(Key)
end
end
end
end
end))
function KeybindInit:SetBind(Key)
local keyString = (typeof(Key) == "EnumItem" and tostring(Key):gsub("Enum.KeyCode.", "")) or Key
Button.Keybind.Text = "[ " .. keyString .. " ]"
Selected = keyString
end
function KeybindInit:GetBind()
local success, enum = pcall(function() return Enum.KeyCode[Selected] end)
return success and enum or Enum.KeyCode.Unknown
end
KeybindObject = KeybindInit
return KeybindInit
end
function ButtonInit:GetKeybind()
return KeybindObject
end
ButtonInit.Type = "Button"
ButtonInit.UniqueID = UniqueID
shared.Dachshund.Elements[UniqueID] = ButtonInit
return ButtonInit
end
function SectionInit:CreateTextBox(Name: string, PlaceHolder: string, NumbersOnly: boolean, Callback: (Value: any) -> (), WrapText: boolean?): Element
local TextBoxInit: Element = {}
shared.Dachshund.ElementCounter += 1
local UniqueID = Name .. " - " .. shared.Dachshund.ElementCounter
local TextBox = Folder.TextBox:Clone()
TextBox.Name = Name .. " T"
TextBox.Parent = Section.Container
TextBox.Title.Text = Name
TextBox.Background.Input.PlaceholderText = PlaceHolder
TextBox.Title.Size = UDim2.new(1, 0, 0, TextBox.Title.TextBounds.Y + 5)
TextBox.Size = UDim2.new(1, -10, 0, TextBox.Title.TextBounds.Y + 25)
Library.Connections = Library.Connections or {}
table.insert(Library.ColorTable, TextBox.Background)
table.insert(Library.ColorTable, TextBox.Title)
TextBox.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
local focusTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local hoverTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tooltipTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local originalBackgroundColor = TextBox.Background.BackgroundColor3
local originalBorderColor = TextBox.Background.BorderColor3
local originalTransparency = TextBox.Background.BackgroundTransparency
local originalTitleColor = TextBox.Title.TextColor3
TextBox.Title.TextWrapped = WrapText or false
if WrapText then
TextBox.Title.AutomaticSize = Enum.AutomaticSize.Y
TextBox.Title.Size = UDim2.new(1, 0, 0, 0)
TextBox.Size = UDim2.new(1, -10, 0, TextBox.Title.TextBounds.Y + 25)
else
TextBox.Title.AutomaticSize = Enum.AutomaticSize.None
end
function TextBoxInit:UpdateColors()
if not TextBox or not TextBox.Parent then return end
if TextBox.Background.Input:IsFocused() then
TextBox.Background.BorderColor3 = Config.Color
TextBox.Title.TextColor3 = Config.Color
else
TextBox.Background.BorderColor3 = originalBorderColor
TextBox.Title.TextColor3 = originalTitleColor
end
end
table.insert(Library.Connections, TextBox.Background.Input.Focused:Connect(function()
if not TextBox or not TextBox.Parent then return end
TweenService:Create(TextBox.Background, focusTweenInfo, {
BackgroundColor3 = originalBackgroundColor:lerp(Color3.fromRGB(255, 255, 255), 0.1),
BorderColor3 = Config.Color,
BackgroundTransparency = math.max(0, originalTransparency - 0.1)
}):Play()
TweenService:Create(TextBox.Title, focusTweenInfo, {TextColor3 = Config.Color}):Play()
end))
table.insert(Library.Connections, TextBox.Background.Input.FocusLost:Connect(function()
if not TextBox or not TextBox.Parent then return end
TweenService:Create(TextBox.Background, focusTweenInfo, {
BackgroundColor3 = originalBackgroundColor,
BorderColor3 = originalBorderColor,
BackgroundTransparency = originalTransparency
}):Play()
TweenService:Create(TextBox.Title, focusTweenInfo, {TextColor3 = originalTitleColor}):Play()
local inputText = TextBox.Background.Input.Text
if NumbersOnly then
local numberValue = tonumber(inputText) or 0
if numberValue then Callback(numberValue) end
else
Callback(inputText)
end
end))
table.insert(Library.Connections, TextBox.MouseEnter:Connect(function()
if not TextBox or not TextBox.Parent then return end
if not TextBox.Background.Input:IsFocused() then
TweenService:Create(TextBox.Background, hoverTweenInfo, {
BackgroundColor3 = originalBackgroundColor:lerp(Color3.fromRGB(255, 255, 255), 0.05),
BackgroundTransparency = math.max(0, originalTransparency - 0.05)
}):Play()
end
end))
table.insert(Library.Connections, TextBox.MouseLeave:Connect(function()
if not TextBox or not TextBox.Parent then return end
if not TextBox.Background.Input:IsFocused() then
TweenService:Create(TextBox.Background, hoverTweenInfo, {
BackgroundColor3 = originalBackgroundColor,
BackgroundTransparency = originalTransparency
}):Play()
end
end))
function TextBoxInit:SetValue(String)
if not TextBox or not TextBox.Parent then return end
TextBox.Background.Input.Text = tostring(String)
local highlightTween = TweenService:Create(TextBox.Background, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
BackgroundColor3 = originalBackgroundColor:lerp(Config.Color, 0.3)
})
highlightTween:Play()
highlightTween.Completed:Connect(function()
if not TextBox or not TextBox.Parent then return end
TweenService:Create(TextBox.Background, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
BackgroundColor3 = originalBackgroundColor
}):Play()
end)
Callback(String)
end
function TextBoxInit:GetValue()
if not TextBox or not TextBox.Parent then return "" end
return TextBox.Background.Input.Text
end
function TextBoxInit:SetVisible(Visible: boolean)
if TextBox and TextBox.Parent then
TextBox.Visible = Visible
end
end
function TextBoxInit:IsVisible(): boolean
return TextBox and TextBox.Parent and TextBox.Visible
end
function TextBoxInit:ToggleVisibility()
if TextBox and TextBox.Parent then
TextBox.Visible = not TextBox.Visible
return TextBox.Visible
end
return false
end
TextBoxInit.Type = "TextBox"
TextBoxInit.UniqueID = UniqueID
shared.Dachshund.Elements[UniqueID] = TextBoxInit
return TextBoxInit
end
function SectionInit:CreateToggle(Name: string, Default: boolean?, Callback: (State: boolean) -> (), Status: string?, Info: string?, WrapText: boolean?): Element
local ToggleInit: Element = {}
shared.Dachshund.ElementCounter += 1
local UniqueID = Name .. " - " .. shared.Dachshund.ElementCounter
local DefaultLocal = Default or false
local StatusLocal = Status or "normal"
local InfoLocal = Info
local Toggle = Folder.Toggle:Clone()
Toggle.Name = Name .. " T"
Toggle.Parent = Section.Container
Toggle.Title.Text = Name
Toggle.Size = UDim2.new(1, -10, 0, Toggle.Title.TextBounds.Y + 5)
Library.Connections = Library.Connections or {}
Toggle.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
local StatusConfig = {
dangerous = {
color = Color3.fromRGB(255, 85, 85),
icon = "(!)",
description = "Dangerous"
},
buggy = {
color = Color3.fromRGB(255, 200, 0),
icon = "(B)",
description = "Buggy"
},
normal = {
color = Config.Color or Color3.fromRGB(0, 162, 255),
icon = "",
description = "Normal"
}
}
local StatusIndicator = Toggle.StatusIndicator
StatusIndicator.ZIndex = Toggle.ZIndex + 1
StatusIndicator.Visible = StatusLocal ~= "normal"
StatusIndicator.TextColor3 = Color3.fromRGB(255, 255, 255)
if StatusLocal ~= "normal" then
StatusIndicator.Size = UDim2.new(0, StatusIndicator.TextBounds.X + 4, 1, 0)
end
local InfoIndicator = Toggle.InfoIndicator
InfoIndicator.ZIndex = Toggle.ZIndex + 1
InfoIndicator.Visible = InfoLocal ~= nil
InfoIndicator.BorderSizePixel = 0
InfoIndicator.TextColor3 = Color3.fromRGB(255, 255, 255)
if InfoLocal then
InfoIndicator.Size = UDim2.new(0, InfoIndicator.TextBounds.X + 8, 0, InfoIndicator.TextBounds.X + 8)
InfoIndicator.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
InfoIndicator.BackgroundTransparency = 0.3
end
local InfoTooltip = nil
if InfoLocal then
InfoTooltip = Instance.new("Frame")
InfoTooltip.Name = "InfoTooltip"
InfoTooltip.Size = UDim2.new(0, 200, 0, 50)
InfoTooltip.Position = UDim2.new(0, 0, 1, 5)
InfoTooltip.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
InfoTooltip.BorderSizePixel = 1
InfoTooltip.BorderColor3 = Color3.fromRGB(0, 162, 255)
InfoTooltip.Visible = false
InfoTooltip.ZIndex = Toggle.ZIndex + 10
InfoTooltip.Parent = Toggle
local TooltipShadow = Instance.new("Frame")
TooltipShadow.Name = "Shadow"
TooltipShadow.Size = UDim2.new(1, 8, 1, 8)
TooltipShadow.Position = UDim2.new(0, 4, 0, 4)
TooltipShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TooltipShadow.BackgroundTransparency = 0.7
TooltipShadow.BorderSizePixel = 0
TooltipShadow.ZIndex = InfoTooltip.ZIndex - 1
TooltipShadow.Parent = InfoTooltip
local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 6)
ShadowCorner.Parent = TooltipShadow
local AccentLine = Instance.new("Frame")
AccentLine.Name = "AccentLine"
AccentLine.Size = UDim2.new(1, 0, 0, 2)
AccentLine.Position = UDim2.new(0, 0, 0, 0)
AccentLine.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
AccentLine.BorderSizePixel = 0
AccentLine.ZIndex = InfoTooltip.ZIndex + 1
AccentLine.Parent = InfoTooltip
local TooltipText = Instance.new("TextLabel")
TooltipText.Name = "Text"
TooltipText.Size = UDim2.new(1, -10, 1, -10)
TooltipText.Position = UDim2.new(0, 5, 0, 5)
TooltipText.BackgroundTransparency = 1
TooltipText.Text = InfoLocal
TooltipText.TextColor3 = Color3.fromRGB(255, 255, 255)
TooltipText.TextScaled = false
TooltipText.Font = Enum.Font.SourceSans
TooltipText.TextSize = 14
TooltipText.TextWrapped = true
TooltipText.TextXAlignment = Enum.TextXAlignment.Left
TooltipText.TextYAlignment = Enum.TextYAlignment.Top
TooltipText.ZIndex = InfoTooltip.ZIndex + 1
TooltipText.Parent = InfoTooltip
task.wait()
local textBounds = TooltipText.TextBounds
InfoTooltip.Size = UDim2.new(0, math.max(textBounds.X + 10, 150), 0, textBounds.Y + 10)
InfoTooltip.Position = UDim2.new(1, -InfoTooltip.Size.X.Offset, 1, 5)
end
local function UpdateTitleSize()
local keybindWidth = Toggle.Keybind.Visible and Toggle.Keybind.Size.X.Offset or 0
local statusWidth = 0
local infoWidth = 0
if StatusLocal ~= "normal" and StatusIndicator.Visible then
statusWidth = StatusIndicator.Size.X.Offset + 5
end
if InfoLocal and InfoIndicator.Visible then
infoWidth = InfoIndicator.Size.X.Offset + 5
end
local totalOffset = keybindWidth + statusWidth + infoWidth + 15
Toggle.Title.Size = UDim2.new(1, -totalOffset, 1, 0)
local currentRightOffset = 5
if Toggle.Keybind.Visible then
currentRightOffset += keybindWidth
end
if InfoLocal and InfoIndicator.Visible then
InfoIndicator.Position = UDim2.new(1, -currentRightOffset - InfoIndicator.Size.X.Offset, 0.5, -InfoIndicator.Size.Y.Offset/2)
currentRightOffset += InfoIndicator.Size.X.Offset + 5
end
if StatusLocal ~= "normal" and StatusIndicator.Visible then
StatusIndicator.Position = UDim2.new(1, -currentRightOffset - StatusIndicator.Size.X.Offset, 0, 0)
end
end
local function UpdateTextSizes()
StatusIndicator.TextSize = Toggle.Title.TextSize
if InfoLocal then
InfoIndicator.TextSize = Toggle.Title.TextSize
InfoIndicator.Size = UDim2.new(0, InfoIndicator.TextBounds.X + 8, 0, InfoIndicator.TextBounds.X + 8)
end
if StatusLocal ~= "normal" then
StatusIndicator.Size = UDim2.new(0, StatusIndicator.TextBounds.X + 4, 1, 0)
end
UpdateTitleSize()
end
table.insert(Library.Connections, StatusIndicator:GetPropertyChangedSignal("TextBounds"):Connect(function()
if StatusLocal ~= "normal" then
StatusIndicator.Size = UDim2.new(0, StatusIndicator.TextBounds.X + 4, 1, 0)
UpdateTitleSize()
end
end))
if InfoLocal then
table.insert(Library.Connections, InfoIndicator:GetPropertyChangedSignal("TextBounds"):Connect(function()
InfoIndicator.Size = UDim2.new(0, InfoIndicator.TextBounds.X + 8, 0, InfoIndicator.TextBounds.X + 8)
UpdateTitleSize()
end))
end
UpdateTitleSize()
if InfoLocal then
local function ShowInfoTooltip()
if InfoTooltip then
InfoTooltip.Visible = true
InfoTooltip.Size = UDim2.new(0, 0, 0, InfoTooltip.Size.Y.Offset)
local showTween = TweenService:Create(InfoTooltip,
TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
Size = UDim2.new(0, math.max(InfoTooltip.Text.TextBounds.X + 10, 150), 0, InfoTooltip.Text.TextBounds.Y + 10)
})
showTween:Play()
end
end
local function HideInfoTooltip()
if InfoTooltip then
local hideTween = TweenService:Create(InfoTooltip,
TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
Size = UDim2.new(0, 0, 0, InfoTooltip.Size.Y.Offset)
})
hideTween:Play()
hideTween.Completed:Connect(function()
InfoTooltip.Visible = false
end)
end
end
table.insert(Library.Connections, InfoIndicator.MouseEnter:Connect(ShowInfoTooltip))
table.insert(Library.Connections, InfoIndicator.MouseLeave:Connect(HideInfoTooltip))
table.insert(Library.Connections, InfoIndicator.TouchTap:Connect(function()
ShowInfoTooltip()
task.wait(3)
HideInfoTooltip()
end))
table.insert(Library.Connections, InfoIndicator.MouseEnter:Connect(function()
local hoverTween = TweenService:Create(InfoIndicator,
TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
TextColor3 = Color3.fromRGB(255, 255, 255),
BackgroundTransparency = 0.1
})
hoverTween:Play()
end))
table.insert(Library.Connections, InfoIndicator.MouseLeave:Connect(function()
local unhoverTween = TweenService:Create(InfoIndicator,
TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
TextColor3 = Color3.fromRGB(150, 150, 150),
BackgroundTransparency = 0.3
})
unhoverTween:Play()
end))
end
table.insert(Library.ColorTable, Toggle.Toggle)
local ToggleState = false
local toggleAnimInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local textAnimInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local glowAnimInfo = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local statusAnimInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local GlowFrame = Toggle.Toggle.GlowEffect
if StatusLocal == "normal" then
table.insert(Library.ColorTable, GlowFrame)
end
if Toggle.Toggle:FindFirstChild("UICorner") then
local GlowCorner = Toggle.Toggle.UICorner:Clone()
GlowCorner.CornerRadius = UDim.new(0, GlowCorner.CornerRadius.Offset + 2)
GlowCorner.Parent = GlowFrame
end
local function SetState(State)
if not Toggle or not Toggle.Parent then return end
if not Library.flags then return end
if not shared.Dachshund.flags then return end
TweenService:Create(Toggle.Toggle, toggleAnimInfo, {}):Cancel()
TweenService:Create(Toggle.Title, textAnimInfo, {}):Cancel()
TweenService:Create(GlowFrame, glowAnimInfo, {}):Cancel()
local lamecolst = StatusConfig[StatusLocal].color
if State then
local toggleTween = TweenService:Create(Toggle.Toggle, toggleAnimInfo, {
BackgroundColor3 = lamecolst
})
local textTween = TweenService:Create(Toggle.Title, textAnimInfo, {
TextColor3 = lamecolst,
TextStrokeTransparency = 0.8
})
local glowTween = TweenService:Create(GlowFrame, glowAnimInfo, {
BackgroundTransparency = 0.7
})
local statusPulseTween = TweenService:Create(StatusIndicator, statusAnimInfo, {
TextTransparency = 0.3
})
toggleTween:Play()
textTween:Play()
glowTween:Play()
if StatusLocal ~= "normal" then
statusPulseTween:Play()
end
else
local toggleTween = TweenService:Create(Toggle.Toggle, toggleAnimInfo, {
BackgroundColor3 = Color3.fromRGB(0, 0, 0)
})
local textTween = TweenService:Create(Toggle.Title, textAnimInfo, {
TextColor3 = Color3.fromRGB(255, 255, 255),
TextStrokeTransparency = 1
})
local glowTween = TweenService:Create(GlowFrame, toggleAnimInfo, {
BackgroundTransparency = 1
})
local statusResetTween = TweenService:Create(StatusIndicator, statusAnimInfo, {
TextTransparency = 0
})
toggleTween:Play()
textTween:Play()
glowTween:Play()
if StatusLocal ~= "normal" then
statusResetTween:Play()
end
end
ToggleState = State
Callback(State)
end
table.insert(Library.Connections, Toggle.MouseEnter:Connect(function()
local lamecolst = StatusConfig[StatusLocal].color
if not ToggleState then
local hoverTween = TweenService:Create(Toggle.Toggle,
TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
BackgroundColor3 = Color3.fromRGB(70, 70, 70)
})
hoverTween:Play()
end
local titleHoverTween = TweenService:Create(Toggle.Title,
TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
TextColor3 = ToggleState and lamecolst or Color3.fromRGB(255, 255, 255)
})
titleHoverTween:Play()
if StatusLocal ~= "normal" then
local statusHoverTween = TweenService:Create(StatusIndicator,
TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
TextTransparency = 0.2
})
statusHoverTween:Play()
end
end))
table.insert(Library.Connections, Toggle.MouseLeave:Connect(function()
local lamecolst = StatusConfig[StatusLocal].color
if not ToggleState then
local unhoverTween = TweenService:Create(Toggle.Toggle,
TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
BackgroundColor3 = Color3.fromRGB(0, 0, 0)
})
unhoverTween:Play()
end
local titleUnhoverTween = TweenService:Create(Toggle.Title,
TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
TextColor3 = ToggleState and lamecolst or Color3.fromRGB(255, 255, 255)
})
titleUnhoverTween:Play()
if StatusLocal ~= "normal" then
local statusUnhoverTween = TweenService:Create(StatusIndicator,
TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
TextTransparency = ToggleState and 0.3 or 0
})
statusUnhoverTween:Play()
end
end))
table.insert(Library.Connections, Toggle.InputBegan:Connect(function(Input)
if UserInputService:GetFocusedTextBox() == nil then
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
if not Library.flags then return end
if not shared.Dachshund.flags then return end
ToggleState = not ToggleState
SetState(ToggleState)
end
end
end))
function ToggleInit:SetState(State)
SetState(State)
end
function ToggleInit:GetState()
return ToggleState
end
function ToggleInit:SetStatus(NewStatus)
if StatusConfig[NewStatus] then
StatusLocal = NewStatus
local newconfig = StatusConfig[NewStatus]
StatusIndicator.Text = newconfig.icon
StatusIndicator.TextColor3 = newconfig.color
StatusIndicator.Visible = NewStatus ~= "normal"
GlowFrame.BackgroundColor3 = newconfig.color
if NewStatus ~= "normal" then
StatusIndicator.Size = UDim2.new(0, StatusIndicator.TextBounds.X + 4, 1, 0)
end
UpdateTitleSize()
if ToggleState then
Toggle.Toggle.BackgroundColor3 = newconfig.color
Toggle.Title.TextColor3 = newconfig.color
end
end
end
function ToggleInit:GetStatus()
return StatusLocal
end
function ToggleInit:SetInfo(NewInfo)
InfoLocal = NewInfo
if InfoLocal then
InfoIndicator.Visible = true
if InfoTooltip then
InfoTooltip.Text.Text = InfoLocal
local textBounds = InfoTooltip.Text.TextBounds
InfoTooltip.Size = UDim2.new(0, math.max(textBounds.X + 10, 150), 0, textBounds.Y + 10)
end
else
InfoIndicator.Visible = false
if InfoTooltip then
InfoTooltip.Visible = false
end
end
UpdateTitleSize()
end
function ToggleInit:GetInfo()
return InfoLocal
end
function ToggleInit:UpdateColors()
if StatusLocal == "normal" then
local newcolor = Config.Color or Color3.fromRGB(0, 162, 255)
StatusConfig.normal.color = newcolor
if ToggleState then
Toggle.Toggle.BackgroundColor3 = newcolor
Toggle.Title.TextColor3 = newcolor
end
GlowFrame.BackgroundColor3 = newcolor
pcall(function()
if Toggle.Title.TextColor3 ~= Color3.fromRGB(255, 255, 255) and
Toggle.Title.TextColor3 ~= Color3.fromRGB(255, 255, 255) then
Toggle.Title.TextColor3 = newcolor
end
end)
end
end
local KeybindObject = nil
function ToggleInit:CreateKeybind(Bind, KeybindCallback, DefaultMode)
if UserInputService.TouchEnabled then
return {
SetBind = function() end,
GetBind = function() return Enum.KeyCode.Unknown end,
SetMode = function() end,
GetMode = function() return "Toggle" end
}
end
local KeybindInit = {}
Bind = (typeof(Bind) == "EnumItem" and tostring(Bind):gsub("Enum.KeyCode.", "")) or Bind or "NONE"
local KeybindMode = (DefaultMode == "Hold" and "Hold") or "Toggle"
local WaitingForBind = false
local Selected = Bind
local Blacklist = {}
local firstClickReceived = false
local pendingBind = nil
local lastClickTime = 0
Toggle.Keybind.Visible = true
Toggle.Keybind.Text = "[ " .. Bind .. " ]"
Toggle.Keybind.TextColor3 = Color3.fromRGB(255, 255, 255)
UpdateTitleSize()
local function GetInputName(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
return "LeftClick"
elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
return "RightClick"
elseif input.UserInputType == Enum.UserInputType.Keyboard then
return tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
end
return nil
end
local function IsMouseButton(bindName)
return bindName == "LeftClick" or bindName == "RightClick"
end
local ModePopup = Toggle:FindFirstChild("ModePopup")
local innerFrame = ModePopup and ModePopup.BorderFrame1.BorderFrame2.BorderFrame3:FindFirstChild("InnerFrame")
local ToggleModeButton = innerFrame and innerFrame:FindFirstChild("ToggleMode")
local HoldModeButton = innerFrame and innerFrame:FindFirstChild("HoldMode")
local RemoveKeybindButton = innerFrame and innerFrame:FindFirstChild("RemoveKeybind")
local function UpdateSelectedButton()
if ToggleModeButton then
local existingGradient = ToggleModeButton:FindFirstChild("SelectionGradient")
if existingGradient then
existingGradient:Destroy()
end
end
if HoldModeButton then
local existingGradient = HoldModeButton:FindFirstChild("SelectionGradient")
if existingGradient then
existingGradient:Destroy()
end
end
local selectedButton = (KeybindMode == "Toggle" and ToggleModeButton) or HoldModeButton
if selectedButton then
local gradient = Instance.new("UIGradient")
gradient.Name = "SelectionGradient"
gradient.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
})
gradient.Rotation = 90
gradient.Parent = selectedButton
end
end
if ToggleModeButton and HoldModeButton then
UpdateSelectedButton()
end
if ToggleModeButton then
table.insert(Library.Connections, ToggleModeButton.MouseButton1Click:Connect(function()
KeybindMode = "Toggle"
UpdateSelectedButton()
ModePopup.Visible = false
end))
end
if HoldModeButton then
table.insert(Library.Connections, HoldModeButton.MouseButton1Click:Connect(function()
KeybindMode = "Hold"
UpdateSelectedButton()
ModePopup.Visible = false
end))
end
if RemoveKeybindButton then
table.insert(Library.Connections, RemoveKeybindButton.MouseButton1Click:Connect(function()
Toggle.Keybind.Text = "[ NONE ]"
Selected = "NONE"
ModePopup.Visible = false
end))
end
table.insert(Library.Connections, Toggle.Keybind.MouseButton2Click:Connect(function()
if ModePopup then
ModePopup.Visible = not ModePopup.Visible
ModePopup.Position = UDim2.new(0, Toggle.Keybind.AbsolutePosition.X - Toggle.AbsolutePosition.X, 1, 5)
end
end))
table.insert(Library.Connections, Toggle.Keybind.InputBegan:Connect(function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
lastClickTime = tick()
Toggle.Keybind.Text = "[ ... ]"
WaitingForBind = true
firstClickReceived = false
pendingBind = nil
local keybindFlash = TweenService:Create(Toggle.Keybind,
TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
TextTransparency = 0.5
})
keybindFlash:Play()
local connection; connection = Toggle.Keybind:GetPropertyChangedSignal("Text"):Connect(function()
if Toggle.Keybind.Text ~= "[ ... ]" then
keybindFlash:Cancel()
Toggle.Keybind.TextTransparency = 0
connection:Disconnect()
end
end)
table.insert(Library.Connections, connection)
end
end))
table.insert(Library.Connections, Toggle.Keybind:GetPropertyChangedSignal("TextBounds"):Connect(function()
Toggle.Keybind.Size = UDim2.new(0, Toggle.Keybind.TextBounds.X, 1, 0)
UpdateTitleSize()
end))
table.insert(Library.Connections, UserInputService.InputBegan:Connect(function(Input)
if UserInputService:GetFocusedTextBox() == nil then
local inputName = GetInputName(Input)
if WaitingForBind and inputName then
local currentTime = tick()
if IsMouseButton(inputName) and (currentTime - lastClickTime) < 0.2 then
return
end
if not firstClickReceived then
if not table.find(Blacklist, inputName) then
firstClickReceived = true
pendingBind = inputName
Toggle.Keybind.Text = "[ Press again... ]"
else
Toggle.Keybind.Text = "[ NONE ]"
Selected = "NONE"
WaitingForBind = false
firstClickReceived = false
pendingBind = nil
end
else
if inputName == pendingBind then
Toggle.Keybind.Text = "[ " .. inputName .. " ]"
Selected = inputName
if KeybindCallback then
KeybindCallback(inputName)
end
WaitingForBind = false
firstClickReceived = false
pendingBind = nil
else
Toggle.Keybind.Text = "[ NONE ]"
Selected = "NONE"
WaitingForBind = false
firstClickReceived = false
pendingBind = nil
end
end
elseif inputName and inputName == Selected and Selected ~= "NONE" then
if KeybindMode == "Toggle" then
ToggleState = not ToggleState
SetState(ToggleState)
if KeybindCallback then
KeybindCallback(inputName)
end
elseif KeybindMode == "Hold" then
SetState(true)
if KeybindCallback then
KeybindCallback(inputName)
end
end
end
end
end))
table.insert(Library.Connections, UserInputService.InputEnded:Connect(function(Input)
if KeybindMode == "Hold" then
local inputName = GetInputName(Input)
if inputName == Selected and Selected ~= "NONE" then
SetState(false)
end
end
end))
function KeybindInit:SetBind(Key)
local keyString
if typeof(Key) == "EnumItem" then
keyString = tostring(Key):gsub("Enum.KeyCode.", "")
elseif typeof(Key) == "string" then
keyString = Key
else
keyString = "NONE"
end
Toggle.Keybind.Text = "[ " .. keyString .. " ]"
Selected = keyString
end
function KeybindInit:GetBind()
if IsMouseButton(Selected) then
return Selected
else
local success, enum = pcall(function() return Enum.KeyCode[Selected] end)
return success and enum or Enum.KeyCode.Unknown
end
end
function KeybindInit:SetMode(Mode)
if Mode == "Toggle" or Mode == "Hold" then
KeybindMode = Mode
UpdateSelectedButton()
end
end
function KeybindInit:GetMode()
return KeybindMode
end
KeybindObject = KeybindInit
return KeybindInit
end
function ToggleInit:GetKeybind()
return KeybindObject
end
function ToggleInit:SetVisible(Visible: boolean)
if Toggle and Toggle.Parent then
Toggle.Visible = Visible
end
end
function ToggleInit:IsVisible(): boolean
return Toggle and Toggle.Parent and Toggle.Visible
end
function ToggleInit:ToggleVisibility()
if Toggle and Toggle.Parent then
Toggle.Visible = not Toggle.Visible
return Toggle.Visible
end
return false
end
Toggle.Title.TextWrapped = WrapText or false
if WrapText then
Toggle.Title.AutomaticSize = Enum.AutomaticSize.Y
Toggle.Size = UDim2.new(1, -10, 0, 0)
Toggle.AutomaticSize = Enum.AutomaticSize.Y
else
Toggle.Title.AutomaticSize = Enum.AutomaticSize.None
end
ToggleInit.Type = "Toggle"
ToggleInit.UniqueID = UniqueID
shared.Dachshund.Elements[UniqueID] = ToggleInit
SetState(DefaultLocal)
return ToggleInit
end
function SectionInit:CreateSlider(Name: string, Min: number, Max: number, Default: number?, Precise: boolean?, Callback: (Value: number) -> (), WrapText: boolean?): Element
local SliderInit: Element = {}
shared.Dachshund.ElementCounter += 1
local UniqueID = Name .. " - " .. shared.Dachshund.ElementCounter
local DefaultLocal = Default or 50
local Slider = Folder.Slider:Clone()
Slider.Name = Name .. " S"
Slider.Parent = Section.Container
Library.Connections = Library.Connections or {}
Slider.Title.Text = Name
Slider.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Slider.Slider.Bar.Size = UDim2.new(Min / Max, 0, 1, 0)
Slider.Slider.Bar.BackgroundColor3 = Config.Color
Slider.Value.PlaceholderText = tostring(Min / Max)
Slider.Title.Size = UDim2.new(1, 0, 0, Slider.Title.TextBounds.Y + 5)
Slider.Size = UDim2.new(1, -10, 0, Slider.Title.TextBounds.Y + 15)
table.insert(Library.ColorTable, Slider.Slider.Bar)
Slider.Value.ClearTextOnFocus = false
Slider.Value.TextEditable = true
Slider.Value.ZIndex = 10
local GlowFrame = Slider.Slider.Bar.GlowEffect
table.insert(Library.ColorTable, GlowFrame)
if Slider.Slider.Bar:FindFirstChild("UICorner") then
local GlowCorner = Slider.Slider.Bar.UICorner:Clone()
GlowCorner.CornerRadius = UDim.new(0, GlowCorner.CornerRadius.Offset + 2)
GlowCorner.Parent = GlowFrame
end
local glowAnimInfo = TweenInfo.new(
0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0
)
local function playGlow()
if not Slider or not Slider.Parent then return end
local glowTween = TweenService:Create(GlowFrame, glowAnimInfo, {BackgroundTransparency = 0.7})
glowTween:Play()
return glowTween
end
local function stopGlow()
if not Slider or not Slider.Parent then return end
TweenService:Create(GlowFrame, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
end
local GlobalSliderValue = 0
local Dragging = false
local function Sliding(Input)
if not Slider or not Slider.Parent then return end
local Position = UDim2.new(math.clamp((Input.Position.X - Slider.Slider.AbsolutePosition.X) / Slider.Slider.AbsoluteSize.X, 0, 1), 0, 1, 0)
Slider.Slider.Bar.Size = Position
local SliderPrecise = ((Position.X.Scale * Max) / Max) * (Max - Min) + Min
local SliderNonPrecise = math.floor(((Position.X.Scale * Max) / Max) * (Max - Min) + Min)
local SliderValue = Precise and SliderNonPrecise or SliderPrecise
SliderValue = tonumber(string.format("%.2f", SliderValue))
GlobalSliderValue = SliderValue
Slider.Value.PlaceholderText = tostring(SliderValue)
Callback(GlobalSliderValue)
end
local function SetValue(Value)
if not Slider or not Slider.Parent then return end
GlobalSliderValue = Value
Slider.Slider.Bar.Size = UDim2.new(Value / Max, 0, 1, 0)
Slider.Value.PlaceholderText = tostring(Value)
Callback(Value)
end
table.insert(Library.Connections, Slider.Value.FocusLost:Connect(function()
if not Slider or not Slider.Parent then return end
local inputText = Slider.Value.Text
local inputValue = tonumber(inputText)
if inputText == "" or not inputValue then
Slider.Value.Text = ""
return
end
inputValue = math.clamp(inputValue, Min, Max)
if Precise then
inputValue = math.floor(inputValue)
else
inputValue = tonumber(string.format("%.2f", inputValue))
end
GlobalSliderValue = inputValue
Slider.Slider.Bar.Size = UDim2.new(inputValue / Max, 0, 1, 0)
Slider.Value.PlaceholderText = tostring(inputValue)
Callback(inputValue)
Slider.Value.Text = ""
end))
local textboxClicked = false
table.insert(Library.Connections, Slider.Value.InputBegan:Connect(function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
textboxClicked = true
Slider.Value:CaptureFocus()
end
end))
table.insert(Library.Connections, Slider.Value.InputEnded:Connect(function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
textboxClicked = false
end
end))
table.insert(Library.Connections, Slider.InputBegan:Connect(function(Input)
if not Slider or not Slider.Parent then return end
if UserInputService:GetFocusedTextBox() == nil and not textboxClicked then
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
Sliding(Input)
Dragging = true
playGlow()
end
end
end))
table.insert(Library.Connections, Slider.InputEnded:Connect(function(Input)
if not Slider or not Slider.Parent then return end
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
Dragging = false
stopGlow()
end
end))
table.insert(Library.Connections, UserInputService.InputChanged:Connect(function(Input)
if not Slider or not Slider.Parent then return end
if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
if Dragging then
Sliding(Input)
end
end
end))
table.insert(Library.Connections, Slider.MouseEnter:Connect(function()
if not Slider or not Slider.Parent then return end
if not Dragging then playGlow() end
end))
table.insert(Library.Connections, Slider.MouseLeave:Connect(function()
if not Slider or not Slider.Parent then return end
if not Dragging then stopGlow() end
end))
function SliderInit:SetValue(Value)
SetValue(Value)
end
function SliderInit:GetValue()
return GlobalSliderValue
end
function SliderInit:SetVisible(Visible: boolean)
if Slider and Slider.Parent then
Slider.Visible = Visible
end
end
function SliderInit:IsVisible(): boolean
return Slider and Slider.Parent and Slider.Visible
end
function SliderInit:ToggleVisibility()
if Slider and Slider.Parent then
Slider.Visible = not Slider.Visible
return Slider.Visible
end
return false
end
function SliderInit:UpdateColors()
if Slider and Slider.Parent then
Slider.Slider.Bar.BackgroundColor3 = Config.Color
GlowFrame.BackgroundColor3 = Config.Color
end
end
Slider.Title.TextWrapped = WrapText or false
if WrapText then
Slider.Title.AutomaticSize = Enum.AutomaticSize.Y
Slider.Title.Size = UDim2.new(1, 0, 0, 0)
Slider.AutomaticSize = Enum.AutomaticSize.Y
else
Slider.Title.AutomaticSize = Enum.AutomaticSize.None
end
SetValue(DefaultLocal)
SliderInit.Type = "Slider"
SliderInit.UniqueID = UniqueID
shared.Dachshund.Elements[UniqueID] = SliderInit
return SliderInit
end
function SectionInit:CreateDropdown(Name: string, OptionTable: {string}, Callback: (Value: any) -> (), InitialValue: any?, Multi: boolean?, WrapText: boolean?, KeepRemoved: boolean?): Element
local DropdownInit: Element = {}
shared.Dachshund.ElementCounter += 1
local UniqueID = Name .. " - " .. shared.Dachshund.ElementCounter
local Dropdown = Folder.Dropdown:Clone()
Dropdown.Name = Name .. (Multi and " MD" or " D")
Dropdown.Parent = Section.Container
Library.Connections = Library.Connections or {}
local SearchOption = Folder.SearchOption:Clone()
SearchOption.Name = "SearchBar"
SearchOption.Parent = Dropdown.Container.Holder.Container
SearchOption.PlaceholderText = "Search options..."
SearchOption.BackgroundColor3 = Dropdown.BackgroundColor3
SearchOption.BackgroundTransparency = 1
SearchOption.BorderSizePixel = 0
SearchOption.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchOption.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
SearchOption.Size = UDim2.new(1, 0, 0, SearchOption.TextBounds.Y + 5)
Dropdown.Title.Text = Name
Dropdown.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Dropdown.Title.Size = UDim2.new(1, 0, 0, Dropdown.Title.TextBounds.Y + 5)
Dropdown.Container.Position = UDim2.new(0, 0, 0, Dropdown.Title.TextBounds.Y + 5)
Dropdown.Size = UDim2.new(1, -10, 0, Dropdown.Title.TextBounds.Y + 25)
Dropdown.Container.Holder.Size = UDim2.new(1, -5, 0, 0)
Dropdown.Container.Holder.Visible = false
local DropdownToggle = false
local SelectedOptions = {}
local CurrentSelectedOption = nil
local isAnimating = false
local AllOptions = {}
local collapsedSize = Dropdown.Title.TextBounds.Y + 25
local expandedSize = 0
local holderExpandedSize = 0
local springInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local hoverInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local function PreCalculateSizes()
holderExpandedSize = Dropdown.Container.Holder.Container.ListLayout.AbsoluteContentSize.Y
expandedSize = holderExpandedSize + collapsedSize + 5
end
local function HighlightText(textLabel, searchText, optionName)
if searchText == "" then
textLabel.Text = optionName
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
return
end
local lowerOption = string.lower(optionName)
local lowerSearch = string.lower(searchText)
local startPos, endPos = string.find(lowerOption, lowerSearch, 1, true)
if startPos then
local beforeText = string.sub(optionName, 1, startPos - 1)
local highlightText = string.sub(optionName, startPos, endPos)
local afterText = string.sub(optionName, endPos + 1)
local r = math.floor(Config.Color.R * 255)
local g = math.floor(Config.Color.G * 255)
local b = math.floor(Config.Color.B * 255)
local hexColor = string.format("#%02x%02x%02x", r, g, b)
textLabel.RichText = true
textLabel.Text = beforeText .. '<font color="' .. hexColor .. '"><b>' .. highlightText .. '</b></font>' .. afterText
else
textLabel.RichText = false
textLabel.Text = optionName
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
end
end
local function FilterOptions(searchText)
local visibleCount = 1
for _, option in pairs(AllOptions) do
if option and option.Parent then
local shouldShow = searchText == "" or string.find(string.lower(option.Name), string.lower(searchText), 1, true)
option.Visible = shouldShow
if shouldShow then
visibleCount = visibleCount + 1
HighlightText(option.Title, searchText, option.Name)
end
end
end
task.wait()
PreCalculateSizes()
if DropdownToggle then
TweenService:Create(Dropdown, springInfo, {
Size = UDim2.new(1, -10, 0, expandedSize)
}):Play()
TweenService:Create(Dropdown.Container.Holder, springInfo, {
Size = UDim2.new(1, -5, 0, holderExpandedSize)
}):Play()
end
end
table.insert(Library.Connections, SearchOption.Changed:Connect(function(property)
if property == "Text" then
FilterOptions(SearchOption.Text)
end
end))
local function ClearSearch()
SearchOption.Text = ""
for _, option in pairs(AllOptions) do
if option and option.Parent then
option.Title.RichText = false
option.Title.Text = option.Name
option.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
end
end
FilterOptions("")
end
local function UpdateText()
if Multi then
local selectedArray = {}
local selectedCount = 0
for option, isSelected in next, SelectedOptions do
if isSelected then
table.insert(selectedArray, option)
selectedCount += 1
end
end
if selectedCount == 0 then
Dropdown.Container.Value.Text = "None"
return
end
if selectedCount > 1 then
Dropdown.Container.Value.Text = string.format("%d selected", selectedCount)
else
Dropdown.Container.Value.Text = selectedArray[1]
end
else
Dropdown.Container.Value.Text = CurrentSelectedOption or ""
end
end
local function UpdateOptionVisual(Option, isSelected, immediate)
local targetTransparency = isSelected and 0.7 or 1
local targetColor = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 255, 255)
if immediate then
Option.BackgroundTransparency = targetTransparency
Option.Title.TextColor3 = targetColor
else
TweenService:Create(Option, hoverInfo, {BackgroundTransparency = targetTransparency}):Play()
TweenService:Create(Option.Title, hoverInfo, {TextColor3 = targetColor}):Play()
end
end
local function UpdateSingleSelection(selectedOption, immediate)
for _, child in next, AllOptions do
if child and child.Parent then
local isSelected = child.Name == selectedOption
UpdateOptionVisual(child, isSelected, immediate)
if isSelected then
CurrentSelectedOption = selectedOption
Dropdown.Container.Value.Text = selectedOption
end
end
end
end
local function SetOptionsVisibility(visible)
SearchOption.TextTransparency = visible and 0 or 1
SearchOption.BackgroundTransparency = 1
for _, child in next, AllOptions do
if child and child.Parent then
child.Title.TextTransparency = visible and 0 or 1
if Multi then
child.BackgroundTransparency = visible and (SelectedOptions[child.Name] and 0.7 or 1) or 1
else
child.BackgroundTransparency = visible and (CurrentSelectedOption == child.Name and 0.7 or 1) or 1
end
end
end
end
local function UpdateDropdownSize()
if DropdownToggle then
PreCalculateSizes()
TweenService:Create(Dropdown, springInfo, {
Size = UDim2.new(1, -10, 0, expandedSize)
}):Play()
TweenService:Create(Dropdown.Container.Holder, springInfo, {
Size = UDim2.new(1, -5, 0, holderExpandedSize)
}):Play()
end
end
table.insert(Library.Connections, Dropdown.MouseButton1Click:Connect(function()
if not Dropdown or not Dropdown.Parent then return end
if isAnimating then return end
isAnimating = true
DropdownToggle = not DropdownToggle
if DropdownToggle then
PreCalculateSizes()
Dropdown.Container.Holder.Visible = true
Dropdown.Container.Holder.ClipsDescendants = true
SetOptionsVisibility(true)
local dropdownTween = TweenService:Create(Dropdown, springInfo, {
Size = UDim2.new(1, -10, 0, expandedSize),
BackgroundTransparency = 0.95
})
local holderTween = TweenService:Create(Dropdown.Container.Holder, springInfo, {
Size = UDim2.new(1, -5, 0, holderExpandedSize)
})
dropdownTween:Play()
holderTween:Play()
else
SetOptionsVisibility(false)
ClearSearch()
local dropdownTween = TweenService:Create(Dropdown, springInfo, {
Size = UDim2.new(1, -10, 0, collapsedSize),
BackgroundTransparency = 1
})
local holderTween = TweenService:Create(Dropdown.Container.Holder, springInfo, {
Size = UDim2.new(1, -5, 0, 0)
})
dropdownTween:Play()
holderTween:Play()
end
local connection; connection = RunService.Heartbeat:Connect(function()
if (not DropdownToggle and math.abs(Dropdown.Size.Y.Offset - collapsedSize) < 1) or
(DropdownToggle and math.abs(Dropdown.Size.Y.Offset - expandedSize) < 1) then
connection:Disconnect()
if not DropdownToggle then
Dropdown.Container.Holder.Visible = false
end
isAnimating = false
end
end)
end))
table.insert(Library.Connections, Dropdown.MouseEnter:Connect(function()
if not Dropdown or not Dropdown.Parent then return end
TweenService:Create(Dropdown, hoverInfo, {
BackgroundTransparency = DropdownToggle and 0.9 or 0.97
}):Play()
end))
table.insert(Library.Connections, Dropdown.MouseLeave:Connect(function()
if not Dropdown or not Dropdown.Parent then return end
TweenService:Create(Dropdown, hoverInfo, {
BackgroundTransparency = DropdownToggle and 0.95 or 1
}):Play()
end))
local function AddOptionConnections(Option, OptionName, originalSize)
if Multi then
table.insert(Library.Connections, Option.MouseButton1Up:Connect(function()
if not Option or not Option.Parent then return end
local clickTween1 = TweenService:Create(Option, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset - 2, originalSize.Y.Scale, originalSize.Y.Offset)})
local clickTween2 = TweenService:Create(Option, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = originalSize})
clickTween1:Play()
clickTween1.Completed:Wait()
clickTween2:Play()
SelectedOptions[OptionName] = not SelectedOptions[OptionName]
UpdateOptionVisual(Option, SelectedOptions[OptionName])
UpdateText()
local selectedArray = {}
for k, v in next, SelectedOptions do
if v then table.insert(selectedArray, k) end
end
local returnValue = Callback(selectedArray)
if type(returnValue) == "table" then
SelectedOptions = {}
for _, v in next, returnValue do
SelectedOptions[v] = true
end
for _, child in next, AllOptions do
if child and child.Parent then
UpdateOptionVisual(child, SelectedOptions[child.Name])
end
end
UpdateText()
end
end))
table.insert(Library.Connections, Option.MouseEnter:Connect(function()
if not Option or not Option.Parent then return end
if not SelectedOptions[OptionName] then
TweenService:Create(Option, hoverInfo, {
BackgroundTransparency = 0.85,
Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, originalSize.Y.Scale, originalSize.Y.Offset + 1)
}):Play()
end
end))
table.insert(Library.Connections, Option.MouseLeave:Connect(function()
if not Option or not Option.Parent then return end
TweenService:Create(Option, hoverInfo, {
Size = originalSize,
BackgroundTransparency = SelectedOptions[OptionName] and 0.7 or 1
}):Play()
end))
else
table.insert(Library.Connections, Option.MouseButton1Click:Connect(function()
if not Option or not Option.Parent then return end
local clickTween1 = TweenService:Create(Option, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset - 2, originalSize.Y.Scale, originalSize.Y.Offset)})
local clickTween2 = TweenService:Create(Option, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = originalSize})
clickTween1:Play()
clickTween1.Completed:Wait()
clickTween2:Play()
UpdateSingleSelection(OptionName)
Callback(OptionName)
end))
table.insert(Library.Connections, Option.MouseEnter:Connect(function()
if not Option or not Option.Parent then return end
if CurrentSelectedOption ~= OptionName then
TweenService:Create(Option, hoverInfo, {
BackgroundTransparency = 0.85,
Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, originalSize.Y.Scale, originalSize.Y.Offset + 1)
}):Play()
end
end))
table.insert(Library.Connections, Option.MouseLeave:Connect(function()
if not Option or not Option.Parent then return end
TweenService:Create(Option, hoverInfo, {
Size = originalSize,
BackgroundTransparency = CurrentSelectedOption == OptionName and 0.7 or 1
}):Play()
end))
end
end
for _, OptionName in next, OptionTable do
local Option = Folder.Option:Clone()
Option.Name = OptionName
Option.Parent = Dropdown.Container.Holder.Container
Option.Title.Text = OptionName
Option.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Option.BackgroundColor3 = Config.Color
Option.Size = UDim2.new(1, 0, 0, Option.Title.TextBounds.Y + 5)
table.insert(Library.ColorTable, Option)
table.insert(AllOptions, Option)
local originalSize = Option.Size
if Multi then
if InitialValue and type(InitialValue) == "table" then
for _, v in next, InitialValue do
if v == OptionName then
SelectedOptions[OptionName] = true
break
end
end
end
UpdateOptionVisual(Option, SelectedOptions[OptionName], true)
else
if InitialValue and InitialValue == OptionName then
UpdateSingleSelection(OptionName, true)
end
end
AddOptionConnections(Option, OptionName, originalSize)
end
task.spawn(function()
wait()
PreCalculateSizes()
if InitialValue then
if Multi and type(InitialValue) == "table" then
for _, v in next, InitialValue do
SelectedOptions[v] = true
end
UpdateText()
elseif not Multi then
for _, optionName in next, OptionTable do
if optionName == InitialValue then
UpdateSingleSelection(InitialValue, true)
Callback(InitialValue)
break
end
end
end
end
end)
function DropdownInit:UpdateColors()
if SearchOption and SearchOption.Text ~= "" then
FilterOptions(SearchOption.Text)
end
end
function DropdownInit:GetOption()
if Multi then
local selected = {}
for k, v in next, SelectedOptions do
if v then table.insert(selected, k) end
end
return selected
else
return CurrentSelectedOption or ""
end
end
function DropdownInit:SetOption(value)
if Multi then
SelectedOptions = {}
if type(value) == "table" then
for _, v in next, value do
SelectedOptions[v] = true
end
end
for _, child in next, AllOptions do
if child and child.Parent then
UpdateOptionVisual(child, SelectedOptions[child.Name])
end
end
UpdateText()
else
if value then
UpdateSingleSelection(value)
end
end
Callback(value)
end
function DropdownInit:SetVisible(Visible: boolean)
if Dropdown and Dropdown.Parent then
Dropdown.Visible = Visible
end
end
function DropdownInit:IsVisible(): boolean
return Dropdown and Dropdown.Parent and Dropdown.Visible
end
function DropdownInit:ToggleVisibility()
if Dropdown and Dropdown.Parent then
Dropdown.Visible = not Dropdown.Visible
return Dropdown.Visible
end
return false
end
function DropdownInit:ClearOptions()
for _, child in next, AllOptions do
if child and child.Parent then
child:Destroy()
end
end
AllOptions = {}
if not KeepRemoved then
if Multi then
SelectedOptions = {}
Dropdown.Container.Value.Text = "None"
else
CurrentSelectedOption = nil
Dropdown.Container.Value.Text = ""
end
else
UpdateText()
end
UpdateDropdownSize()
end
function DropdownInit:AddOption(OptionName: string | {any}, SelectImmediately: boolean?)
if type(OptionName) == "table" then
for _, option in next, OptionName do
self:AddOption(tostring(option), SelectImmediately)
end
UpdateDropdownSize()
return
end
local str = tostring(OptionName)
for _, child in next, AllOptions do
if child and child.Parent and child.Name == str then
return
end
end
local Option = Folder.Option:Clone()
Option.Name = str
Option.Parent = Dropdown.Container.Holder.Container
Option.Title.Text = str
Option.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Option.BackgroundColor3 = Config.Color
Option.Size = UDim2.new(1, 0, 0, Option.Title.TextBounds.Y + 5)
table.insert(Library.ColorTable, Option)
table.insert(AllOptions, Option)
local originalSize = Option.Size
if Multi then
if SelectedOptions[str] == nil then
SelectedOptions[str] = false
end
if SelectImmediately then
SelectedOptions[str] = true
end
UpdateOptionVisual(Option, SelectedOptions[str], true)
else
if SelectImmediately then
UpdateSingleSelection(str, true)
elseif CurrentSelectedOption == str then
UpdateOptionVisual(Option, true, true)
end
end
AddOptionConnections(Option, str, originalSize)
if Multi then
UpdateText()
end
UpdateDropdownSize()
if SearchOption.Text ~= "" then
FilterOptions(SearchOption.Text)
end
end
function DropdownInit:RemoveOption(OptionName: string)
local str = tostring(OptionName)
for i, child in next, AllOptions do
if child and child.Parent and child.Name == str then
child:Destroy()
table.remove(AllOptions, i)
break
end
end
if not KeepRemoved then
if Multi then
SelectedOptions[str] = nil
UpdateText()
else
if CurrentSelectedOption == str then
CurrentSelectedOption = nil
Dropdown.Container.Value.Text = ""
end
end
else
UpdateText()
end
UpdateDropdownSize()
end
function DropdownInit:ChangeOptions(NewOptionTable: {string}, NewInitialValue: any?)
self:ClearOptions()
self:AddOption(NewOptionTable)
if NewInitialValue then
self:SetOption(NewInitialValue)
end
end
Dropdown.Title.TextWrapped = WrapText or false
if WrapText then
Dropdown.Title.AutomaticSize = Enum.AutomaticSize.Y
Dropdown.Title.Size = UDim2.new(1, 0, 0, 0)
Dropdown.Container.Position = UDim2.new(0, 0, 0, Dropdown.Title.TextBounds.Y + 5)
Dropdown.Size = UDim2.new(1, -10, 0, Dropdown.Title.TextBounds.Y + 25)
else
Dropdown.Title.AutomaticSize = Enum.AutomaticSize.None
end
DropdownInit.Type = Multi and "MultiDropdown" or "Dropdown"
DropdownInit.UniqueID = UniqueID
shared.Dachshund.Elements[UniqueID] = DropdownInit
return DropdownInit
end
-- its so skidded i just gived up
function SectionInit:CreateColorpicker(Name: string, Callback: (Color: Color3, Transparency: number?) -> (), IsAccentColorpicker: boolean?, WrapText: boolean?, AttachToToggle: Element?): Element
local ColorpickerInit: Element = {}
shared.Dachshund.ElementCounter += 1
local UniqueID = Name .. " - " .. shared.Dachshund.ElementCounter
local Colorpicker = Folder.Colorpicker:Clone()
local Pallete = Folder.Palette:Clone()
Pallete.Name = Name .. " P " .. shared.Dachshund.ElementCounter
Library.Connections = Library.Connections or {}
if AttachToToggle and AttachToToggle.Type == "Toggle" then
local ToggleFrame = nil
for _, child in next, Section.Container:GetChildren() do
if child.Name == AttachToToggle.UniqueID:gsub(" %- %d+", "") .. " T" then
ToggleFrame = child
break
end
end
if ToggleFrame then
Library.Connections = Library.Connections or {}
local existingIndicators = 0
for _, child in next, ToggleFrame:GetChildren() do
if child.Name == "ColorIndicator" then
existingIndicators = existingIndicators + 1
end
end
local ColorIndicator = Instance.new("Frame")
ColorIndicator.Name = "ColorIndicator"
ColorIndicator.Size = UDim2.new(0, 16, 0, 8)
local baseX = ToggleFrame.Title.TextBounds.X + 20
local spacing = 20
ColorIndicator.Position = UDim2.new(0, baseX + (existingIndicators * spacing), 0.5, 2)
ColorIndicator.AnchorPoint = Vector2.new(0, 0.5)
ColorIndicator.BackgroundColor3 = Config.Color or Color3.fromRGB(0, 162, 255)
ColorIndicator.BorderSizePixel = 0
ColorIndicator.BorderColor3 = Color3.fromRGB(0, 0, 0)
ColorIndicator.Parent = ToggleFrame
ColorIndicator.ZIndex = 3
local ColorGradient = Instance.new("UIGradient")
ColorGradient.Name = "Gradient"
ColorGradient.Rotation = 90
ColorGradient.Color = ColorSequence.new{
ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 255, 255)),
ColorSequenceKeypoint.new(1.000, Color3.fromRGB(182, 182, 182))
}
ColorGradient.Parent = ColorIndicator
local GlowFrame = Instance.new("Frame")
GlowFrame.Name = "GlowEffect"
GlowFrame.Size = UDim2.new(1, 2, 1, 2)
GlowFrame.Position = UDim2.new(0, -1, 0, -1)
GlowFrame.BackgroundColor3 = ColorIndicator.BackgroundColor3
GlowFrame.BackgroundTransparency = 0.8
GlowFrame.BorderSizePixel = 0
GlowFrame.Parent = ColorIndicator
GlowFrame.ZIndex = ColorIndicator.ZIndex - 1
Pallete.Name = Name .. " P " .. shared.Dachshund.ElementCounter
Pallete.Parent = Screen
Pallete.Visible = false
local RainbowToggle = Instance.new("TextButton")
RainbowToggle.Name = "RainbowToggle"
RainbowToggle.Parent = Pallete
RainbowToggle.AnchorPoint = Vector2.new(1, 0)
RainbowToggle.Size = UDim2.new(0, 20, 0, 20)
RainbowToggle.Position = UDim2.new(1, 25, 0, 2)
RainbowToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
RainbowToggle.BorderSizePixel = 0
RainbowToggle.BorderColor3 = Color3.fromRGB(0, 162, 255)
RainbowToggle.Text = "-"
RainbowToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
RainbowToggle.TextScaled = true
RainbowToggle.Font = Enum.Font.Gotham
RainbowToggle.ZIndex = 3
table.insert(Library.ColorTable, RainbowToggle)
ColorpickerInit.RainbowToggle = RainbowToggle
local ColorTable = {Hue = 1, Saturation = 0, Value = 1}
local CurrentTransparency = 0
local ColorRender = nil
local HueRender = nil
local TransparencyRender = nil
local ColorpickerRender = nil
local RainbowRender = nil
local IsRainbowEnabled = false
local sh1tcon = nil
local GradientPalette = Pallete.GradientPalette
local ColorSlider = Pallete.ColorSlider
local TransparencySlider = Pallete.TransparencySlider
local ColorPreview = Pallete.ColorPreview
local InputBox = Pallete.InputFrame.InputBox
local Dot = GradientPalette.Dot
local function UpdateColor()
if not ToggleFrame or not ToggleFrame.Parent then return end
local currentColor = Color3.fromHSV(ColorTable.Hue, ColorTable.Saturation, ColorTable.Value)
ColorIndicator.BackgroundColor3 = currentColor
GlowFrame.BackgroundColor3 = currentColor
GradientPalette.BackgroundColor3 = Color3.fromHSV(ColorTable.Hue, 1, 1)
ColorPreview.BackgroundColor3 = currentColor
ColorPreview.BackgroundTransparency = CurrentTransparency
local r, g, b = math.round(currentColor.R * 255), math.round(currentColor.G * 255), math.round(currentColor.B * 255)
local alpha = math.round((1 - CurrentTransparency) * 255)
InputBox.PlaceholderText = string.format("RGBA: %d, %d, %d, %d", r, g, b, alpha)
Dot.Position = UDim2.new(ColorTable.Saturation, 0, 1 - ColorTable.Value, 0)
Callback(currentColor, CurrentTransparency)
if IsAccentColorpicker then
ChangeColor(currentColor, CurrentTransparency)
end
end
local function ihatemyself(position)
local palettepos = Pallete.AbsolutePosition
local palettesize = Pallete.AbsoluteSize
return position.X >= palettepos.X and position.X <= palettepos.X + palettesize.X and position.Y >= palettepos.Y and position.Y <= palettepos.Y + palettesize.Y
end
local function closePalette()
Pallete.Visible = false
if ColorpickerRender then
ColorpickerRender:Disconnect()
ColorpickerRender = nil
end
if sh1tcon then
sh1tcon:Disconnect()
sh1tcon = nil
end
end
local function blehh()
if sh1tcon then
sh1tcon:Disconnect()
end
sh1tcon = UserInputService.InputBegan:Connect(function(input, gp)
if not gp and Pallete.Visible then
local inputpos
if input.UserInputType == Enum.UserInputType.MouseButton1 then
inputpos = UserInputService:GetMouseLocation()
elseif input.UserInputType == Enum.UserInputType.Touch then
inputpos = input.Position
else
return
end
if not ihatemyself(inputpos) then
closePalette()
end
end
end)
table.insert(Library.Connections, sh1tcon)
end
table.insert(Library.Connections, RainbowToggle.MouseButton1Click:Connect(function()
IsRainbowEnabled = not IsRainbowEnabled
if IsRainbowEnabled then
RainbowToggle.BackgroundColor3 = Config.Color or Color3.fromRGB(0, 162, 255)
RainbowToggle.BackgroundTransparency = Config.Transparency or 0
RainbowToggle.Text = "+"
RainbowRender = RunService.PreRender:Connect(function()
if not ToggleFrame or not ToggleFrame.Parent then
if RainbowRender then
RainbowRender:Disconnect()
RainbowRender = nil
end
return
end
ColorTable.Hue = (tick() * 0.5) % 1
ColorTable.Saturation = 1
ColorTable.Value = 1
UpdateColor()
end)
else
RainbowToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
RainbowToggle.BackgroundTransparency = 0
RainbowToggle.Text = "-"
if RainbowRender then
RainbowRender:Disconnect()
RainbowRender = nil
end
end
end))
table.insert(Library.Connections, ColorIndicator.InputBegan:Connect(function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
if not Pallete.Visible then
ColorpickerRender = RunService.PreRender:Connect(function()
if not ToggleFrame or not ToggleFrame.Parent then
if ColorpickerRender then
ColorpickerRender:Disconnect()
ColorpickerRender = nil
end
return
end
local pos = ColorIndicator.AbsolutePosition
Pallete.Position = UDim2.new(0, pos.X - 129, 0, pos.Y + 20)
end)
Pallete.Visible = true
blehh()
else
closePalette()
end
end
end))
table.insert(Library.Connections, ColorIndicator.MouseEnter:Connect(function()
TweenService:Create(GlowFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
BackgroundTransparency = 0.4
}):Play()
end))
table.insert(Library.Connections, ColorIndicator.MouseLeave:Connect(function()
TweenService:Create(GlowFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
BackgroundTransparency = 0.8
}):Play()
end))
local function getananddRelativePosition(input, guiObject)
local inputPos
if input.UserInputType == Enum.UserInputType.Touch then
inputPos = input.Position
else
inputPos = UserInputService:GetMouseLocation()
end
local guiPos = guiObject.AbsolutePosition
local guiSize = guiObject.AbsoluteSize
return Vector2.new(
(inputPos.X - guiPos.X) / guiSize.X,
(inputPos.Y - guiPos.Y) / guiSize.Y
)
end
local function fakuroblox(input, guiObject)
local mouse = UserInputService:GetMouseLocation()
return Vector2.new(
(mouse.X - guiObject.AbsolutePosition.X) / guiObject.AbsoluteSize.X,
((mouse.Y - 60) - guiObject.AbsolutePosition.Y) / guiObject.AbsoluteSize.Y
)
end
table.insert(Library.Connections, GradientPalette.InputBegan:Connect(function(Input)
if not ToggleFrame or not ToggleFrame.Parent then return end
if UserInputService:GetFocusedTextBox() == nil then
if Input.UserInputType == Enum.UserInputType.MouseButton1 then
if IsRainbowEnabled then
IsRainbowEnabled = false
RainbowToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
RainbowToggle.Text = "-"
if RainbowRender then RainbowRender:Disconnect() end
end
if ColorRender then ColorRender:Disconnect() end
ColorRender = RunService.PreRender:Connect(function()
if not ToggleFrame or not ToggleFrame.Parent then
if ColorRender then
ColorRender:Disconnect()
ColorRender = nil
end
return
end
local relativePos = fakuroblox(Input, GradientPalette)
local clampedX = math.clamp(relativePos.X, 0, 1)
local clampedY = math.clamp(relativePos.Y, 0, 1)
Dot.Position = UDim2.new(clampedX, 0, clampedY, 0)
ColorTable.Saturation = clampedX
ColorTable.Value = 1 - clampedY
UpdateColor()
end)
elseif Input.UserInputType == Enum.UserInputType.Touch then
if IsRainbowEnabled then
IsRainbowEnabled = false
RainbowToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
RainbowToggle.Text = "-"
if RainbowRender then RainbowRender:Disconnect() end
end
if ColorRender then ColorRender:Disconnect() end
ColorRender = RunService.PreRender:Connect(function()
if not ToggleFrame or not ToggleFrame.Parent then
if ColorRender then
ColorRender:Disconnect()
ColorRender = nil
end
return
end
local relativePos = getananddRelativePosition(Input, GradientPalette)
local clampedX = math.clamp(relativePos.X, 0, 1)
local clampedY = math.clamp(relativePos.Y, 0, 1)
Dot.Position = UDim2.new(clampedX, 0, clampedY, 0)
ColorTable.Saturation = clampedX
ColorTable.Value = 1 - clampedY
UpdateColor()
end)
end
end
end))
table.insert(Library.Connections, GradientPalette.InputEnded:Connect(function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
if ColorRender then ColorRender:Disconnect() end
end
end))
table.insert(Library.Connections, ColorSlider.InputBegan:Connect(function(Input)
if not ToggleFrame or not ToggleFrame.Parent then return end
if UserInputService:GetFocusedTextBox() == nil then
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
if IsRainbowEnabled then
IsRainbowEnabled = false
RainbowToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
RainbowToggle.Text = "-"
if RainbowRender then
RainbowRender:Disconnect()
RainbowRender = nil
end
end
if HueRender then HueRender:Disconnect() end
HueRender = RunService.PreRender:Connect(function()
if not ToggleFrame or not ToggleFrame.Parent then
if HueRender then
HueRender:Disconnect()
HueRender = nil
end
return
end
local relativePos = getananddRelativePosition(Input, ColorSlider)
ColorTable.Hue = 1 - math.clamp(relativePos.X, 0, 1)
UpdateColor()
end)
end
end
end))
table.insert(Library.Connections, ColorSlider.InputEnded:Connect(function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
if HueRender then HueRender:Disconnect() end
end
end))
table.insert(Library.Connections, TransparencySlider.InputBegan:Connect(function(Input)
if not ToggleFrame or not ToggleFrame.Parent then return end
if UserInputService:GetFocusedTextBox() == nil then
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
if TransparencyRender then TransparencyRender:Disconnect() end
TransparencyRender = RunService.PreRender:Connect(function()
if not ToggleFrame or not ToggleFrame.Parent then
if TransparencyRender then
TransparencyRender:Disconnect()
TransparencyRender = nil
end
return
end
local relativePos = getananddRelativePosition(Input, TransparencySlider)
CurrentTransparency = math.clamp(relativePos.X, 0, 1)
UpdateColor()
end)
end
end
end))
table.insert(Library.Connections, TransparencySlider.InputEnded:Connect(function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
if TransparencyRender then TransparencyRender:Disconnect() end
end
end))
local function UpdateTransparencySlider()
if not ToggleFrame or not ToggleFrame.Parent then return end
TransparencySlider.BackgroundColor3 = Color3.fromHSV(ColorTable.Hue, ColorTable.Saturation, ColorTable.Value)
end
table.insert(Library.Connections, InputBox.FocusLost:Connect(function(Enter)
if not ToggleFrame or not ToggleFrame.Parent then return end
if Enter then
local input = string.gsub(InputBox.Text, " ", "")
local colorValues = string.split(input, ",")
if #colorValues >= 3 then
local r = math.clamp(tonumber(colorValues[1]) or 255, 0, 255)
local g = math.clamp(tonumber(colorValues[2]) or 0, 0, 255)
local b = math.clamp(tonumber(colorValues[3]) or 0, 0, 255)
local a = 255
if #colorValues >= 4 then
a = math.clamp(tonumber(colorValues[4]) or 255, 0, 255)
end
local newColor = Color3.fromRGB(r, g, b)
local newTransparency = 1 - (a / 255)
ColorpickerInit:UpdateColor(newColor, newTransparency)
end
InputBox.Text = ""
end
end))
function ColorpickerInit:UpdateColor(Color, Transparency)
if not ToggleFrame or not ToggleFrame.Parent then return end
Transparency = Transparency or 0
if IsRainbowEnabled then
IsRainbowEnabled = false
RainbowToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
RainbowToggle.BackgroundTransparency = 0
RainbowToggle.Text = "-"
if RainbowRender then
RainbowRender:Disconnect()
RainbowRender = nil
end
end
local Hue, Saturation, Value = Color:ToHSV()
ColorTable = {Hue = Hue, Saturation = Saturation, Value = Value}
CurrentTransparency = Transparency
UpdateColor()
UpdateTransparencySlider()
end
function ColorpickerInit:GetValue()
return ColorIndicator.BackgroundColor3, CurrentTransparency
end
function ColorpickerInit:GetColor()
return ColorIndicator.BackgroundColor3
end
function ColorpickerInit:GetTransparency()
return CurrentTransparency
end
function ColorpickerInit:SetVisible(Visible: boolean)
ColorIndicator.Visible = Visible
end
function ColorpickerInit:IsVisible(): boolean
return ColorIndicator.Visible
end
function ColorpickerInit:ToggleVisibility()
ColorIndicator.Visible = not ColorIndicator.Visible
return ColorIndicator.Visible
end
function ColorpickerInit:ClosePallete()
closePalette()
end
function ColorpickerInit:SetTransparency(transparency)
CurrentTransparency = math.clamp(transparency, 0, 1)
UpdateColor()
end
function ColorpickerInit:IsRainbowEnabled()
return IsRainbowEnabled
end
function ColorpickerInit:SetRainbow(state)
if state ~= IsRainbowEnabled then
RainbowToggle.MouseButton1Click:Fire()
end
end
UpdateColor()
UpdateTransparencySlider()
ColorpickerInit.Type = "AttachedColorPicker"
ColorpickerInit.UniqueID = UniqueID
ColorpickerInit.IsAccentColorpicker = IsAccentColorpicker or false
shared.Dachshund.Elements[UniqueID] = ColorpickerInit
return ColorpickerInit
end
end
Colorpicker.Name = Name .. " CP"
Colorpicker.Parent = Section.Container
Colorpicker.Title.Text = Name
Colorpicker.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Colorpicker.Size = UDim2.new(1, -10, 0, Colorpicker.Title.TextBounds.Y + 5)
Pallete.Name = Name .. " P " .. shared.Dachshund.ElementCounter
Pallete.Parent = Screen
Pallete.Visible = false
local RainbowToggle = Instance.new("TextButton")
RainbowToggle.Name = "RainbowToggle"
RainbowToggle.Parent = Pallete
RainbowToggle.AnchorPoint = Vector2.new(1, 0)
RainbowToggle.Size = UDim2.new(0, 20, 0, 20)
RainbowToggle.Position = UDim2.new(1, 25, 0, 2)
RainbowToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
RainbowToggle.BorderSizePixel = 0
RainbowToggle.BorderColor3 = Color3.fromRGB(0, 162, 255)
RainbowToggle.Text = "-"
RainbowToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
RainbowToggle.TextScaled = true
RainbowToggle.Font = Enum.Font.Gotham
RainbowToggle.ZIndex = 3
table.insert(Library.ColorTable, RainbowToggle)
ColorpickerInit.RainbowToggle = RainbowToggle
local ColorTable = {Hue = 1, Saturation = 0, Value = 1}
local CurrentTransparency = 0
local ColorRender = nil
local HueRender = nil
local TransparencyRender = nil
local ColorpickerRender = nil
local RainbowRender = nil
local IsRainbowEnabled = false
local sh1tcon = nil
local GradientPalette = Pallete.GradientPalette
local ColorSlider = Pallete.ColorSlider
local TransparencySlider = Pallete.TransparencySlider
local ColorPreview = Pallete.ColorPreview
local InputBox = Pallete.InputFrame.InputBox
local Dot = GradientPalette.Dot
local function UpdateColor()
local currentColor = Color3.fromHSV(ColorTable.Hue, ColorTable.Saturation, ColorTable.Value)
Colorpicker.Color.BackgroundColor3 = currentColor
GradientPalette.BackgroundColor3 = Color3.fromHSV(ColorTable.Hue, 1, 1)
ColorPreview.BackgroundColor3 = currentColor
ColorPreview.BackgroundTransparency = CurrentTransparency
local r, g, b = math.round(currentColor.R * 255), math.round(currentColor.G * 255), math.round(currentColor.B * 255)
local alpha = math.round((1 - CurrentTransparency) * 255)
InputBox.PlaceholderText = string.format("RGBA: %d, %d, %d, %d", r, g, b, alpha)
Dot.Position = UDim2.new(ColorTable.Saturation, 0, 1 - ColorTable.Value, 0)
Callback(currentColor, CurrentTransparency)
if IsAccentColorpicker then
ChangeColor(currentColor, CurrentTransparency)
end
end
local function ihatemyself(position)
local palettepos = Pallete.AbsolutePosition
local palettesize = Pallete.AbsoluteSize
return position.X >= palettepos.X and position.X <= palettepos.X + palettesize.X and position.Y >= palettepos.Y and position.Y <= palettepos.Y + palettesize.Y
end
local function closePalette()
Pallete.Visible = false
if ColorpickerRender then
ColorpickerRender:Disconnect()
ColorpickerRender = nil
end
if sh1tcon then
sh1tcon:Disconnect()
sh1tcon = nil
end
end
local function blehh()
if sh1tcon then
sh1tcon:Disconnect()
end
sh1tcon = UserInputService.InputBegan:Connect(function(input, gp)
if not gp and Pallete.Visible then
local inputpos
if input.UserInputType == Enum.UserInputType.MouseButton1 then
inputpos = UserInputService:GetMouseLocation()
elseif input.UserInputType == Enum.UserInputType.Touch then
inputpos = input.Position
else
return
end
if not ihatemyself(inputpos) then
closePalette()
end
end
end)
end
table.insert(Library.Connections, RainbowToggle.MouseButton1Click:Connect(function()
IsRainbowEnabled = not IsRainbowEnabled
if IsRainbowEnabled then
RainbowToggle.BackgroundColor3 = Config.Color or Color3.fromRGB(0, 162, 255)
RainbowToggle.BackgroundTransparency = Config.Transparency or 0
RainbowToggle.Text = "+"
RainbowRender = RunService.PreRender:Connect(function()
if not Colorpicker or not Colorpicker.Parent then
if RainbowRender then
RainbowRender:Disconnect()
RainbowRender = nil
end
return
end
ColorTable.Hue = (tick() * 0.5) % 1
ColorTable.Saturation = 1
ColorTable.Value = 1
UpdateColor()
end)
else
RainbowToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
RainbowToggle.BackgroundTransparency = 0
RainbowToggle.Text = "-"
if RainbowRender then
RainbowRender:Disconnect()
RainbowRender = nil
end
end
end))
table.insert(Library.Connections, Colorpicker.InputBegan:Connect(function(Input)
if not Colorpicker or not Colorpicker.Parent then return end
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
if not Pallete.Visible then
ColorpickerRender = RunService.PreRender:Connect(function()
if not Colorpicker or not Colorpicker.Parent then
if ColorpickerRender then
ColorpickerRender:Disconnect()
ColorpickerRender = nil
end
return
end
local pos = Colorpicker.Color.AbsolutePosition
Pallete.Position = UDim2.new(0, pos.X - 129, 0, pos.Y + 52)
end)
Pallete.Visible = true
blehh()
else
closePalette()
end
end
end))
local function getananddRelativePosition(input, guiObject)
local inputPos
if input.UserInputType == Enum.UserInputType.Touch then
inputPos = input.Position
else
inputPos = UserInputService:GetMouseLocation()
end
local guiPos = guiObject.AbsolutePosition
local guiSize = guiObject.AbsoluteSize
return Vector2.new(
(inputPos.X - guiPos.X) / guiSize.X,
(inputPos.Y - guiPos.Y) / guiSize.Y
)
end
local function fakuroblox(input, guiObject)
local mouse = UserInputService:GetMouseLocation()
return Vector2.new(
(mouse.X - guiObject.AbsolutePosition.X) / guiObject.AbsoluteSize.X,
((mouse.Y - 60) - guiObject.AbsolutePosition.Y) / guiObject.AbsoluteSize.Y
)
end
table.insert(Library.Connections, GradientPalette.InputBegan:Connect(function(Input)
if not Colorpicker or not Colorpicker.Parent then return end
if UserInputService:GetFocusedTextBox() == nil then
if Input.UserInputType == Enum.UserInputType.MouseButton1 then
if IsRainbowEnabled then
IsRainbowEnabled = false
RainbowToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
RainbowToggle.Text = "-"
if RainbowRender then RainbowRender:Disconnect() end
end
if ColorRender then ColorRender:Disconnect() end
ColorRender = RunService.PreRender:Connect(function()
if not Colorpicker or not Colorpicker.Parent then
if ColorRender then
ColorRender:Disconnect()
ColorRender = nil
end
return
end
local relativePos = fakuroblox(Input, GradientPalette)
local clampedX = math.clamp(relativePos.X, 0, 1)
local clampedY = math.clamp(relativePos.Y, 0, 1)
Dot.Position = UDim2.new(clampedX, 0, clampedY, 0)
ColorTable.Saturation = clampedX
ColorTable.Value = 1 - clampedY
UpdateColor()
end)
elseif Input.UserInputType == Enum.UserInputType.Touch then
if IsRainbowEnabled then
IsRainbowEnabled = false
RainbowToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
RainbowToggle.Text = "-"
if RainbowRender then RainbowRender:Disconnect() end
end
if ColorRender then ColorRender:Disconnect() end
ColorRender = RunService.PreRender:Connect(function()
if not Colorpicker or not Colorpicker.Parent then
if ColorRender then
ColorRender:Disconnect()
ColorRender = nil
end
return
end
local relativePos = getananddRelativePosition(Input, GradientPalette)
local clampedX = math.clamp(relativePos.X, 0, 1)
local clampedY = math.clamp(relativePos.Y, 0, 1)
Dot.Position = UDim2.new(clampedX, 0, clampedY, 0)
ColorTable.Saturation = clampedX
ColorTable.Value = 1 - clampedY
UpdateColor()
end)
end
end
end))
table.insert(Library.Connections, GradientPalette.InputEnded:Connect(function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
if ColorRender then ColorRender:Disconnect() end
end
end))
table.insert(Library.Connections, ColorSlider.InputBegan:Connect(function(Input)
if not Colorpicker or not Colorpicker.Parent then return end
if UserInputService:GetFocusedTextBox() == nil then
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
if IsRainbowEnabled then
IsRainbowEnabled = false
RainbowToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
RainbowToggle.Text = "-"
if RainbowRender then
RainbowRender:Disconnect()
RainbowRender = nil
end
end
if HueRender then HueRender:Disconnect() end
HueRender = RunService.PreRender:Connect(function()
if not Colorpicker or not Colorpicker.Parent then
if HueRender then
HueRender:Disconnect()
HueRender = nil
end
return
end
local relativePos = getananddRelativePosition(Input, ColorSlider)
ColorTable.Hue = 1 - math.clamp(relativePos.X, 0, 1)
UpdateColor()
end)
end
end
end))
table.insert(Library.Connections, ColorSlider.InputEnded:Connect(function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
if HueRender then HueRender:Disconnect() end
end
end))
table.insert(Library.Connections, TransparencySlider.InputBegan:Connect(function(Input)
if not Colorpicker or not Colorpicker.Parent then return end
if UserInputService:GetFocusedTextBox() == nil then
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
if TransparencyRender then TransparencyRender:Disconnect() end
TransparencyRender = RunService.PreRender:Connect(function()
if not Colorpicker or not Colorpicker.Parent then
if TransparencyRender then
TransparencyRender:Disconnect()
TransparencyRender = nil
end
return
end
local relativePos = getananddRelativePosition(Input, TransparencySlider)
CurrentTransparency = math.clamp(relativePos.X, 0, 1)
UpdateColor()
end)
end
end
end))
table.insert(Library.Connections, TransparencySlider.InputEnded:Connect(function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
if TransparencyRender then TransparencyRender:Disconnect() end
end
end))
local function UpdateTransparencySlider()
if not Colorpicker or not Colorpicker.Parent then return end
TransparencySlider.BackgroundColor3 = Color3.fromHSV(ColorTable.Hue, ColorTable.Saturation, ColorTable.Value)
end
function ColorpickerInit:UpdateColor(Color, Transparency)
Transparency = Transparency or 0
if IsRainbowEnabled then
IsRainbowEnabled = false
RainbowToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
RainbowToggle.BackgroundTransparency = 0
RainbowToggle.Text = "-"
if RainbowRender then
RainbowRender:Disconnect()
RainbowRender = nil
end
end
local Hue, Saturation, Value = Color:ToHSV()
ColorTable = {Hue = Hue, Saturation = Saturation, Value = Value}
CurrentTransparency = Transparency
UpdateColor()
UpdateTransparencySlider()
end
function ColorpickerInit:UpdateColors(AccentColor, AccentTransparency)
if IsRainbowEnabled and AccentColor then
RainbowToggle.BackgroundColor3 = AccentColor
RainbowToggle.BackgroundTransparency = AccentTransparency or 0
end
end
function ColorpickerInit:GetValue()
return Colorpicker.Color.BackgroundColor3, CurrentTransparency
end
function ColorpickerInit:GetColor()
return Colorpicker.Color.BackgroundColor3
end
function ColorpickerInit:GetTransparency()
return CurrentTransparency
end
function ColorpickerInit:IsRainbowEnabled()
return IsRainbowEnabled
end
function ColorpickerInit:SetRainbow(state)
if state ~= IsRainbowEnabled then
RainbowToggle.MouseButton1Click:Fire()
end
end
function ColorpickerInit:SetVisible(Visible: boolean)
Colorpicker.Visible = Visible
end
function ColorpickerInit:IsVisible(): boolean
return Colorpicker.Visible
end
function ColorpickerInit:ToggleVisibility()
Colorpicker.Visible = not Colorpicker.Visible
return Colorpicker.Visible
end
function ColorpickerInit:ClosePallete()
closePalette()
end
function ColorpickerInit:SetTransparency(transparency)
CurrentTransparency = math.clamp(transparency, 0, 1)
UpdateColor()
end
UpdateColor()
UpdateTransparencySlider()
Colorpicker.Title.TextWrapped = WrapText or false
if WrapText then
Colorpicker.Title.AutomaticSize = Enum.AutomaticSize.Y
Colorpicker.Size = UDim2.new(1, -10, 0, 0)
Colorpicker.AutomaticSize = Enum.AutomaticSize.Y
else
Colorpicker.Title.AutomaticSize = Enum.AutomaticSize.None
end
ColorpickerInit.Type = "ColorPicker"
ColorpickerInit.UniqueID = UniqueID
ColorpickerInit.IsAccentColorpicker = IsAccentColorpicker or false
shared.Dachshund.Elements[UniqueID] = ColorpickerInit
return ColorpickerInit
end
function SectionInit:CreateDivider(): Element
local DividerInit: Element = {}
shared.Dachshund.ElementCounter += 1
local UniqueID = "Divider - " .. shared.Dachshund.ElementCounter
local Divider = Instance.new("Frame")
Divider.Name = "Divider"
Divider.Parent = Section.Container
Divider.BackgroundTransparency = 1
Divider.Size = UDim2.new(1, -10, 0, 5)
Divider.ZIndex = 3
local Line = Instance.new("Frame")
Line.Name = "Line"
Line.Parent = Divider
Line.Size = UDim2.new(1, 0, 1, 0)
Line.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
Line.BorderSizePixel = 0
Line.ZIndex = 3
function DividerInit:SetVisible(Visible: boolean)
Divider.Visible = Visible
end
function DividerInit:IsVisible(): boolean
return Divider.Visible
end
function DividerInit:ToggleVisibility()
Divider.Visible = not Divider.Visible
return Divider.Visible
end
function DividerInit:SetColor(Color: Color3)
Line.BackgroundColor3 = Color
end
DividerInit.Type = "Divider"
DividerInit.UniqueID = UniqueID
shared.Dachshund.Elements[UniqueID] = DividerInit
return DividerInit
end
return SectionInit
end
return TabInit
end
local ClearButton = Topbar:FindFirstChild("SearchBar").ClearButton
table.insert(Library.Connections, Topbar.SearchBar.Changed:Connect(function(Property)
if Property == "Text" then
ClearButton.Visible = Topbar.SearchBar.Text ~= ""
end
end))
table.insert(Library.Connections, ClearButton.MouseButton1Click:Connect(function()
Topbar.SearchBar.Text = ""
end))
table.insert(Library.Connections, ClearButton.TouchTap:Connect(function()
Topbar.SearchBar.Text = ""
end))
function Library:GetTextBounds(Text, Font, Size, Resolution)
local Bounds = TextService:GetTextSize(Text, Size, Font, Resolution or Vector2.new(1920, 1080))
return Bounds.X, Bounds.Y
end -- credits linoria library
function Library:Hud()
local HudInit = {}
local Hud = Folder.Hud:Clone()
local InfoText = Hud.BorderFrame1.BorderFrame2.BorderFrame3.InnerFrame.InfoText
Hud.Parent = Screen
local padding = {
right = 10,
bottom = 10,
left = 10,
top = 10
}
Hud.AnchorPoint = Vector2.new(1, 0)
Hud.Position = UDim2.new(1, -padding.right, 0, padding.top)
Hud.Visible = true
table.insert(Library.ColorTable, Hud.BorderFrame1.BorderFrame2.BorderFrame3.InnerFrame.GradientFrame)
-- Make Hud draggable by default
makedraggable(Hud, Hud)
local function updateSize()
local text = InfoText.Text
if text and text ~= "" then
local X, Y = Library:GetTextBounds(text, InfoText.Font, InfoText.TextSize, Vector2.new(10000, 10000))
Hud.Size = UDim2.new(
0, X + padding.left + padding.right,
0, (Y * 1.2) + padding.top + padding.bottom
)
InfoText.Position = UDim2.new(0, padding.left, 0, padding.top)
InfoText.Size = UDim2.new(1, -(padding.left + padding.right), 1, -(padding.top + padding.bottom))
end
end
function HudInit:SetText(text)
InfoText.Text = tostring(text)
updateSize()
return self
end
function HudInit:SetVisibility(bool)
Hud.Visible = bool
return self
end
function HudInit:GetText()
return InfoText.Text
end
function HudInit:IsVisible()
return Hud.Visible
end
function HudInit:SetTextColor(color)
InfoText.TextColor3 = color
return self
end
function HudInit:SetTextSize(size)
InfoText.TextSize = size
updateSize()
return self
end
function HudInit:SetFont(fe)
InfoText.Font = fe
updateSize()
return self
end
function HudInit:SetPadding(right, bottom, left, top)
padding.right = right or padding.right
padding.bottom = bottom or padding.bottom
padding.left = left or padding.left
padding.top = top or padding.top
Hud.Position = UDim2.new(1, -padding.right, 0, padding.top)
updateSize()
return self
end
function HudInit:SetDraggable(draggable)
if draggable and makedraggable then
makedraggable(Hud, Hud)
end
return self
end
function HudInit:SetPosition(position)
Hud.Position = position
return self
end
function HudInit:GetPosition()
return Hud.Position
end
updateSize()
return HudInit
end
local uitoggle = Config.Keybind
local toggleboleanshit = true
table.insert(Library.Connections, UserInputService.InputBegan:Connect(function(input, gp)
if UserInputService:GetFocusedTextBox() == nil and input.KeyCode == uitoggle and not gp then
toggleboleanshit = not toggleboleanshit
Toggle(toggleboleanshit)
end
end))
function Library:ChangeToggleKeybind(newbindomg)
uitoggle = newbindomg
end
local function cparticle()
local particle = Instance.new("Frame")
particle.Size = UDim2.new(0, 2, 0, 2)
particle.Position = UDim2.new(math.random(), 0, 0, -10)
particle.BackgroundColor3 = Config.Color
particle.BorderSizePixel = 0
particle.Parent = WindowInit.particlesFrame
particle.ZIndex = 20
table.insert(WindowInit.particles, {
frame = particle,
velocity = Vector2.new(math.random(-20, 20) * 0.01, math.random(30, 80) * 0.01),
life = 0
})
end
local function uparticle(deltaTime)
for i = #WindowInit.particles, 1, -1 do
local particle = WindowInit.particles[i]
particle.life = particle.life + deltaTime
if particle.life > 3 then
particle.frame:Destroy()
table.remove(WindowInit.particles, i)
else
local pos = particle.frame.Position
particle.frame.Position = UDim2.new(
pos.X.Scale + particle.velocity.X * deltaTime,
pos.X.Offset,
pos.Y.Scale + particle.velocity.Y * deltaTime,
pos.Y.Offset
)
local alpha = 1 - (particle.life / 3)
particle.frame.BackgroundTransparency = 1 - alpha
end
end
end
function WindowInit:CreateParticles(enableParticles)
if enableParticles then
if not self.particles then
self.particles = {}
end
if not self.particlesFrame then
self.particlesFrame = Instance.new("Frame")
self.particlesFrame.Name = "ParticlesFrame"
self.particlesFrame.Size = UDim2.new(1, 0, 1, 0)
self.particlesFrame.BackgroundTransparency = 1
self.particlesFrame.Parent = Screen.Main
end
if not Library.Connections.ParticleConnection then
Library.Connections.ParticleConnection = RunService.Heartbeat:Connect(function(deltaTime)
if Screen and Screen.Main and Screen.Main.Visible then
if math.random() < 0.1 then
cparticle()
end
uparticle(deltaTime)
end
end)
end
else
if Library.Connections.ParticleConnection then
Library.Connections.ParticleConnection:Disconnect()
Library.Connections.ParticleConnection = nil
end
if self.particlesFrame then
self.particlesFrame:Destroy()
self.particlesFrame = nil
end
if self.particles then
for _, particle in next, self.particles do
particle.frame:Destroy()
end
self.particles = {}
end
end
end
-- skidded CreateKeybindViewer and CreateToggleList
function Library:CreateKeybindViewer(Config)
local KeybindViewerInit = {}
Config = Config or {}
if IsMobile then
local dummy = {}
function dummy:SetVisible() end
function dummy:IsVisible() return false end
function dummy:Toggle() return false end
function dummy:SetPosition() end
function dummy:GetPosition() return UDim2.new() end
function dummy:SetSize() end
function dummy:UpdateConfig() end
function dummy:Destroy() end
function dummy:SetParent() end
function dummy:ForceUpdate() end
function dummy:SetTitle() end
function dummy:GetKeybindCount() return 0 end
return dummy
end
local ViewerConfig = {
Visible = Config.Visible ~= false,
Position = Config.Position or UDim2.new(0, 10, 0, 100),
UpdateInterval = Config.UpdateInterval or 0,
ShowToggleStates = Config.ShowToggleStates ~= false,
ShowOnlyActive = Config.ShowOnlyActive ~= false,
Draggable = Config.Draggable ~= false,
}
local KeybindViewer = Folder.KeybindViewer:Clone()
KeybindViewer.Name = "KeybindViewer"
KeybindViewer.Position = ViewerConfig.Position
KeybindViewer.Visible = ViewerConfig.Visible
local TitleBar = KeybindViewer.BorderFrame1.BorderFrame2.BorderFrame3.InnerFrame
local TitleText = TitleBar.Title
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
local Container = TitleBar.Container
local ListLayout = Container:FindFirstChild("ListLayout")
if ViewerConfig.Draggable and makedraggable then
makedraggable(TitleBar, KeybindViewer)
end
local KeybindEntries = {}
local LastUpdateTime = 0
local UpdateConnection = nil
local function CreateKeybindEntry(name, keybind, state, mode, elementType)
local Entry = Instance.new("Frame")
Entry.Name = "KeybindEntry_" .. name
Entry.Size = UDim2.new(1, 10, 0, 14)
Entry.BackgroundTransparency = 1
Entry.Parent = Container
Entry.ZIndex = TitleBar.ZIndex + 2
local displayText = "[" .. keybind .. "] "
if elementType == "Toggle" and mode == "Hold" then
displayText = displayText .. "[Hold] " .. name
elseif elementType == "Toggle" then
displayText = displayText .. "[Toggle] " .. name
elseif elementType == "Button" then
displayText = displayText .. "[Button] " .. name
else
displayText = displayText .. name
end
local KeybindLabel = Instance.new("TextLabel")
KeybindLabel.Name = "KeybindLabel"
KeybindLabel.Size = UDim2.new(1, -4, 1, 0)
KeybindLabel.Position = UDim2.new(0, 2, 0, 0)
KeybindLabel.BackgroundTransparency = 1
KeybindLabel.Text = displayText
local accentColor = Library.ColorTable and #Library.ColorTable > 0 and Library.ColorTable[1].BackgroundColor3 or Color3.fromRGB(0, 162, 255)
KeybindLabel.TextColor3 = state and accentColor or Color3.fromRGB(255, 255, 255)
KeybindLabel.TextScaled = true
KeybindLabel.TextSize = 11
KeybindLabel.Font = Enum.Font.SourceSans
KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
KeybindLabel.TextYAlignment = Enum.TextYAlignment.Center
KeybindLabel.TextTruncate = Enum.TextTruncate.AtEnd
KeybindLabel.Parent = Entry
KeybindLabel.ZIndex = Entry.ZIndex + 1
local TextSizeConstraint = Instance.new("UITextSizeConstraint")
TextSizeConstraint.MaxTextSize = 12
TextSizeConstraint.MinTextSize = 8
TextSizeConstraint.Parent = KeybindLabel
if state then
table.insert(Library.ColorTable, KeybindLabel)
end
return {
Entry = Entry,
KeybindLabel = KeybindLabel,
IsActive = state,
ElementType = elementType,
Mode = mode,
Keybind = keybind
}
end
local function UpdateKeybindEntry(entry, name, keybind, state, mode, elementType)
entry.IsActive = state
entry.ElementType = elementType
entry.Mode = mode
entry.Keybind = keybind
local displayText = "[" .. keybind .. "] "
if elementType == "Toggle" and mode == "Hold" then
displayText = displayText .. "[Hold] " .. name
elseif elementType == "Toggle" then
displayText = displayText .. "[Toggle] " .. name
elseif elementType == "Button" then
displayText = displayText .. "[Button] " .. name
else
displayText = displayText .. name
end
entry.KeybindLabel.Text = displayText
local accentColor = Library.ColorTable and #Library.ColorTable > 0 and Library.ColorTable[1].BackgroundColor3 or Color3.fromRGB(0, 162, 255)
entry.KeybindLabel.TextColor3 = state and accentColor or Color3.fromRGB(255, 255, 255)
local isInColorTable = false
for i, item in ipairs(Library.ColorTable) do
if item == entry.KeybindLabel then
isInColorTable = true
if not state then
table.remove(Library.ColorTable, i)
end
break
end
end
if state and not isInColorTable then
table.insert(Library.ColorTable, entry.KeybindLabel)
end
end
local function RefreshKeybindColors()
local accentColor = Library.ColorTable and #Library.ColorTable > 0 and Library.ColorTable[1].BackgroundColor3 or Color3.fromRGB(0, 162, 255)
for entryName, entry in pairs(KeybindEntries) do
if entry and entry.KeybindLabel then
entry.KeybindLabel.TextColor3 = entry.IsActive and accentColor or Color3.fromRGB(255, 255, 255)
end
end
end
local function UpdateKeybindEntries()
     local currentKeybinds = {}
     if shared.Dachshund and shared.Dachshund.Elements then
         for uniqueID, element in pairs(shared.Dachshund.Elements) do
             if element and element.GetKeybind then
                 local keybindObj = element:GetKeybind()
                 if keybindObj and keybindObj.GetBind then
                     local bind = keybindObj:GetBind()
                     local bindString = tostring(bind):gsub("Enum.KeyCode.", "")
                    if bindString ~= "NONE" and bindString ~= "Unknown" then
                         local elementName = uniqueID:gsub(" %- %d+", "")
                         local state = false
                         local mode = "Toggle"
                         local elementType = element.Type or "Toggle"
                         if elementType == "Toggle" and element.GetState then
                             state = element:GetState()
                         elseif elementType == "Button" then
                             state = nil
                         end
                         if keybindObj.GetMode then
                             mode = keybindObj:GetMode()
                         elseif keybindObj.Mode then
                             mode = keybindObj.Mode
                         elseif keybindObj.mode then
                             mode = keybindObj.mode
                         end
                         if not ViewerConfig.ShowOnlyActive or state or mode == "Hold" or elementType == "Button" then
                             currentKeybinds[elementName] = {
                                 name = elementName,
                                 keybind = bindString,
                                 state = state,
                                 mode = mode,
                                 elementType = elementType
                             }
                         end
                     end
                 end
             end
         end
    end
for entryName, entry in pairs(KeybindEntries) do
if not currentKeybinds[entryName] then
for i = #Library.ColorTable, 1, -1 do
if Library.ColorTable[i] == entry.KeybindLabel then
table.remove(Library.ColorTable, i)
break
end
end
entry.Entry:Destroy()
KeybindEntries[entryName] = nil
end
end
for entryName, keybindData in pairs(currentKeybinds) do
if KeybindEntries[entryName] then
local existingEntry = KeybindEntries[entryName]
if existingEntry.IsActive ~= keybindData.state or
existingEntry.ElementType ~= keybindData.elementType or
existingEntry.Mode ~= keybindData.mode or
existingEntry.Keybind ~= keybindData.keybind then
UpdateKeybindEntry(
existingEntry,
keybindData.name,
keybindData.keybind,
keybindData.state,
keybindData.mode,
keybindData.elementType
)
end
else
local newEntry = CreateKeybindEntry(
keybindData.name,
keybindData.keybind,
keybindData.state,
keybindData.mode,
keybindData.elementType
)
KeybindEntries[entryName] = newEntry
end
end
local sortedNames = {}
for name in pairs(KeybindEntries) do
table.insert(sortedNames, name)
end
table.sort(sortedNames)
for i, name in ipairs(sortedNames) do
if KeybindEntries[name] and KeybindEntries[name].Entry then
KeybindEntries[name].Entry.LayoutOrder = i
end
end
task.wait()
local contentHeight = math.max(ListLayout.AbsoluteContentSize.Y + 10, 10)
local maxHeight = 200
local targetHeight = math.min(contentHeight, maxHeight)
local entryCount = 0
for _ in pairs(KeybindEntries) do
entryCount = entryCount + 1
end
if entryCount == 0 then
targetHeight = 10
end
if Container.ClassName == "ScrollingFrame" then
Container.Size = UDim2.new(1, -10, 0, targetHeight)
Container.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
else
Container.Size = UDim2.new(1, -10, 0, targetHeight)
end
local totalHeight = targetHeight + 25
KeybindViewer.Size = UDim2.new(0, 200, 0, totalHeight)
end
local function StartUpdating()
if UpdateConnection then
UpdateConnection:Disconnect()
end
UpdateConnection = RunService.PreRender:Connect(function()
local currentTime = tick()
if currentTime - LastUpdateTime >= ViewerConfig.UpdateInterval then
LastUpdateTime = currentTime
if KeybindViewer.Visible then
UpdateKeybindEntries()
RefreshKeybindColors()
end
end
end)
table.insert(Library.Connections, UpdateConnection)
end
local function StopUpdating()
if UpdateConnection then
UpdateConnection:Disconnect()
for i = #Library.Connections, 1, -1 do
if Library.Connections[i] == UpdateConnection then
table.remove(Library.Connections, i)
break
end
end
UpdateConnection = nil
end
end
function KeybindViewerInit:SetVisible(visible)
KeybindViewer.Visible = visible
if visible then
RefreshKeybindColors()
UpdateKeybindEntries()
end
end
function KeybindViewerInit:IsVisible()
return KeybindViewer.Visible
end
function KeybindViewerInit:Toggle()
self:SetVisible(not KeybindViewer.Visible)
return KeybindViewer.Visible
end
function KeybindViewerInit:SetPosition(position)
KeybindViewer.Position = position
end
function KeybindViewerInit:GetPosition()
return KeybindViewer.Position
end
function KeybindViewerInit:SetSize(size)
KeybindViewer.Size = size
end
function KeybindViewerInit:UpdateConfig(newConfig)
for key, value in pairs(newConfig) do
ViewerConfig[key] = value
end
RefreshKeybindColors()
UpdateKeybindEntries()
end
function KeybindViewerInit:SetParent(parent)
KeybindViewer.Parent = parent
end
function KeybindViewerInit:ForceUpdate()
RefreshKeybindColors()
UpdateKeybindEntries()
end
function KeybindViewerInit:SetTitle(title)
TitleText.Text = title
end
function KeybindViewerInit:GetKeybindCount()
local count = 0
for _ in pairs(KeybindEntries) do
count = count + 1
end
return count
end
KeybindViewer.Parent = Screen
table.insert(Library.ColorTable, KeybindViewer.BorderFrame1.BorderFrame2.BorderFrame3.InnerFrame.GradientFrame)
StartUpdating()
task.wait(.1) -- some times i dream of saving the world
UpdateKeybindEntries()
return KeybindViewerInit
end
function Library:CreateToggleList(Config)
local ToggleListInit = {}
Config = Config or {}
if IsMobile then
local dummy = {}
function dummy:SetVisible() end
function dummy:IsVisible() return false end
function dummy:Toggle() return false end
function dummy:SetPosition() end
function dummy:GetPosition() return UDim2.new() end
function dummy:SetSize() end
function dummy:UpdateConfig() end
function dummy:Destroy() end
function dummy:SetParent() end
function dummy:ForceUpdate() end
function dummy:SetTitle() end
function dummy:GetEnabledCount() return 0 end
return dummy
end
local ViewerConfig = {
Visible = Config.Visible ~= false,
Position = Config.Position or UDim2.new(0, 220, 0, 100),
UpdateInterval = Config.UpdateInterval or 0,
ShowOnlyEnabled = Config.ShowOnlyEnabled ~= false,
ShowStatus = Config.ShowStatus ~= false,
Draggable = Config.Draggable ~= false,
Title = Config.Title or "Enabled Toggles"
}
local ToggleList = Folder.KeybindViewer:Clone()
ToggleList.Name = "ToggleList"
ToggleList.Position = ViewerConfig.Position
ToggleList.Visible = ViewerConfig.Visible
local TitleBar = ToggleList.BorderFrame1.BorderFrame2.BorderFrame3.InnerFrame
local TitleText = TitleBar.Title
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
local Container = TitleBar.Container
TitleText.Text = ViewerConfig.Title
local ListLayout = Container:FindFirstChild("ListLayout")
if ViewerConfig.Draggable and makedraggable then
makedraggable(TitleBar, ToggleList)
end
local ToggleEntries = {}
local LastUpdateTime = 0
local UpdateConnection = nil
local function CreateToggleEntry(name, state, status)
local Entry = Instance.new("Frame")
Entry.Name = "ToggleEntry_" .. name
Entry.Size = UDim2.new(1, -10, 0, 14)
Entry.BackgroundTransparency = 1
Entry.Parent = Container
Entry.ZIndex = TitleBar.ZIndex + 2
local displayText = name
local ToggleLabel = Instance.new("TextLabel")
ToggleLabel.Name = "ToggleLabel"
ToggleLabel.Size = UDim2.new(1, -4, 1, 0)
ToggleLabel.Position = UDim2.new(0, 2, 0, 0)
ToggleLabel.BackgroundTransparency = 1
ToggleLabel.Text = displayText
local textColor = Color3.fromRGB(255, 255, 255)
if status == "dangerous" then
textColor = Color3.fromRGB(255, 85, 85)
elseif status == "buggy" then
textColor = Color3.fromRGB(255, 200, 0)
else
local accentColor = Config.Color or (Library.ColorTable and #Library.ColorTable > 0 and Library.ColorTable[1].BackgroundColor3) or Color3.fromRGB(0, 162, 255)
textColor = state and accentColor or Color3.fromRGB(255, 255, 255)
end
ToggleLabel.TextColor3 = textColor
ToggleLabel.TextScaled = true
ToggleLabel.TextSize = 11
ToggleLabel.Font = Enum.Font.SourceSans
ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
ToggleLabel.TextYAlignment = Enum.TextYAlignment.Center
ToggleLabel.TextTruncate = Enum.TextTruncate.AtEnd
ToggleLabel.Parent = Entry
ToggleLabel.ZIndex = Entry.ZIndex + 1
local TextSizeConstraint = Instance.new("UITextSizeConstraint")
TextSizeConstraint.MaxTextSize = 12
TextSizeConstraint.MinTextSize = 8
TextSizeConstraint.Parent = ToggleLabel
if state and status == "normal" then
table.insert(Library.ColorTable, ToggleLabel)
end
return {
Entry = Entry,
ToggleLabel = ToggleLabel,
IsEnabled = state,
Status = status,
Name = name
}
end
local function UpdateToggleEntry(entry, name, state, status)
entry.IsEnabled = state
entry.Status = status
entry.Name = name
entry.ToggleLabel.Text = name
local textColor = Color3.fromRGB(255, 255, 255)
if status == "dangerous" then
textColor = Color3.fromRGB(255, 85, 85)
elseif status == "buggy" then
textColor = Color3.fromRGB(255, 200, 0)
else
local accentColor = Config.Color or (Library.ColorTable and #Library.ColorTable > 0 and Library.ColorTable[1].BackgroundColor3) or Color3.fromRGB(0, 162, 255)
textColor = state and accentColor or Color3.fromRGB(255, 255, 255)
end
entry.ToggleLabel.TextColor3 = textColor
local isInColorTable = false
for i, item in ipairs(Library.ColorTable) do
if item == entry.ToggleLabel then
isInColorTable = true
if not state or status ~= "normal" then
table.remove(Library.ColorTable, i)
end
break
end
end
if state and status == "normal" and not isInColorTable then
table.insert(Library.ColorTable, entry.ToggleLabel)
end
end
local function RefreshToggleColors()
for entryName, entry in pairs(ToggleEntries) do
if entry and entry.ToggleLabel then
local textColor = Color3.fromRGB(255, 255, 255)
if entry.Status == "dangerous" then
textColor = Color3.fromRGB(255, 85, 85)
elseif entry.Status == "buggy" then
textColor = Color3.fromRGB(255, 200, 0)
else
local accentColor = Config.Color or (Library.ColorTable and #Library.ColorTable > 0 and Library.ColorTable[1].BackgroundColor3) or Color3.fromRGB(0, 162, 255)
textColor = entry.IsEnabled and accentColor or Color3.fromRGB(255, 255, 255)
end
entry.ToggleLabel.TextColor3 = textColor
end
end
end
local function UpdateToggleEntries()
local currentToggles = {}
if shared.Dachshund and shared.Dachshund.Elements then
for uniqueID, element in pairs(shared.Dachshund.Elements) do
if element and element.Type == "Toggle" and element.GetState then
local elementName = uniqueID:gsub(" %- %d+", "")
local state = element:GetState()
if state or not ViewerConfig.ShowOnlyEnabled then
local status = "normal"
if element.GetStatus then
status = element:GetStatus() or "normal"
end
currentToggles[elementName] = {
name = elementName,
state = state,
status = status
}
end
end
end
end
for entryName, entry in pairs(ToggleEntries) do
if not currentToggles[entryName] then
for i = #Library.ColorTable, 1, -1 do
if Library.ColorTable[i] == entry.ToggleLabel then
table.remove(Library.ColorTable, i)
break
end
end
entry.Entry:Destroy()
ToggleEntries[entryName] = nil
end
end
for entryName, toggleData in pairs(currentToggles) do
if ToggleEntries[entryName] then
local existingEntry = ToggleEntries[entryName]
if existingEntry.IsEnabled ~= toggleData.state or existingEntry.Status ~= toggleData.status then
UpdateToggleEntry(
existingEntry,
toggleData.name,
toggleData.state,
toggleData.status
)
end
else
local newEntry = CreateToggleEntry(
toggleData.name,
toggleData.state,
toggleData.status
)
ToggleEntries[entryName] = newEntry
end
end
local sortedNames = {}
for name in pairs(ToggleEntries) do
table.insert(sortedNames, name)
end
table.sort(sortedNames)
for i, name in ipairs(sortedNames) do
if ToggleEntries[name] and ToggleEntries[name].Entry then
ToggleEntries[name].Entry.LayoutOrder = i
end
end
task.wait()
local contentHeight = math.max(ListLayout.AbsoluteContentSize.Y + 10, 10)
local maxHeight = 200
local targetHeight = math.min(contentHeight, maxHeight)
local entryCount = 0
for _ in pairs(ToggleEntries) do
entryCount = entryCount + 1
end
if entryCount == 0 then
targetHeight = 10
end
if Container.ClassName == "ScrollingFrame" then
Container.Size = UDim2.new(1, -10, 0, targetHeight)
Container.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
else
Container.Size = UDim2.new(1, -10, 0, targetHeight)
end
local totalHeight = targetHeight + 25
ToggleList.Size = UDim2.new(0, 200, 0, totalHeight)
end
local function StartUpdating()
if UpdateConnection then
UpdateConnection:Disconnect()
end
UpdateConnection = RunService.PreRender:Connect(function()
local currentTime = tick()
if currentTime - LastUpdateTime >= ViewerConfig.UpdateInterval then
LastUpdateTime = currentTime
if ToggleList.Visible then
UpdateToggleEntries()
RefreshToggleColors()
end
end
end)
table.insert(Library.Connections, UpdateConnection)
end
function ToggleListInit:SetVisible(visible)
ToggleList.Visible = visible
if visible then
RefreshToggleColors()
UpdateToggleEntries()
end
end
function ToggleListInit:IsVisible()
return ToggleList.Visible
end
function ToggleListInit:Toggle()
self:SetVisible(not ToggleList.Visible)
return ToggleList.Visible
end
function ToggleListInit:SetPosition(position)
ToggleList.Position = position
end
function ToggleListInit:GetPosition()
return ToggleList.Position
end
function ToggleListInit:ForceUpdate()
RefreshToggleColors()
UpdateToggleEntries()
end
function ToggleListInit:SetTitle(title)
TitleText.Text = title
ViewerConfig.Title = title
end
function ToggleListInit:GetEnabledCount()
local count = 0
if shared.Dachshund and shared.Dachshund.Elements then
for _, element in pairs(shared.Dachshund.Elements) do
if element and element.Type == "Toggle" and element.GetState and element:GetState() then
count = count + 1
end
end
end
return count
end
function ToggleListInit:Destroy()
if UpdateConnection then
UpdateConnection:Disconnect()
end
for _, entry in pairs(ToggleEntries) do
for i = #Library.ColorTable, 1, -1 do
if Library.ColorTable[i] == entry.ToggleLabel then
table.remove(Library.ColorTable, i)
break
end
end
end
ToggleList:Destroy()
end
ToggleList.Parent = Screen
table.insert(Library.ColorTable, ToggleList.BorderFrame1.BorderFrame2.BorderFrame3.InnerFrame.GradientFrame)
StartUpdating()
task.wait(.1) -- some times i dream of saving the world
UpdateToggleEntries()
return ToggleListInit
end
--pasted from a old source
function WindowInit:CreateGlow(enableGlow, glowConfig)
glowConfig = glowConfig or {}
if enableGlow then
if self.glowEffect then
self:CreateGlow(false)
end
self.glowEffect = Instance.new("UIStroke")
self.glowEffect.Name = "WindowGlow"
self.glowEffect.Color = glowConfig.color or Config.Color
self.glowEffect.Thickness = glowConfig.thickness or 2
self.glowEffect.Transparency = glowConfig.transparency or 0.5
self.glowEffect.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
self.glowEffect.Parent = Screen.Main
table.insert(Library.ColorTable, self.glowEffect)
local pulseEnabled = glowConfig.pulse ~= false
local pulseSpeed = glowConfig.pulseSpeed or 2
local minTransparency = glowConfig.minTransparency or 0.2
local maxTransparency = glowConfig.maxTransparency or 0.8
if pulseEnabled then
if not Library.Connections.GlowConnection then
Library.Connections.GlowConnection = RunService.Heartbeat:Connect(function()
if self.glowEffect and self.glowEffect.Parent then
local pulse = math.sin(tick() * pulseSpeed)
local transparency = minTransparency + (maxTransparency - minTransparency) * ((pulse + 1) / 2)
self.glowEffect.Transparency = transparency
end
end)
end
end
if glowConfig.enhanced then
self.glowFrame = Instance.new("Frame")
self.glowFrame.Name = "GlowFrame"
self.glowFrame.Size = UDim2.new(1, glowConfig.glowSize or 8, 1, glowConfig.glowSize or 8)
self.glowFrame.Position = UDim2.new(0, -(glowConfig.glowSize or 8)/2, 0, -(glowConfig.glowSize or 8)/2)
self.glowFrame.BackgroundColor3 = glowConfig.color or Config.Color
self.glowFrame.BackgroundTransparency = glowConfig.frameTransparency or 0.9
self.glowFrame.BorderSizePixel = 0
self.glowFrame.ZIndex = Screen.Main.ZIndex - 1
self.glowFrame.Parent = Screen.Main.Parent
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim2.new(0, glowConfig.cornerRadius or 8)
corner.Parent = self.glowFrame
table.insert(Library.ColorTable, self.glowFrame)
end
else
if Library.Connections.GlowConnection then
Library.Connections.GlowConnection:Disconnect()
Library.Connections.GlowConnection = nil
end
if self.glowEffect then
for i, v in next, Library.ColorTable do
if v == self.glowEffect then
table.remove(Library.ColorTable, i)
break
end
end
self.glowEffect:Destroy()
self.glowEffect = nil
end
if self.glowFrame then
for i, v in next, Library.ColorTable do
if v == self.glowFrame then
table.remove(Library.ColorTable, i)
break
end
end
self.glowFrame:Destroy()
self.glowFrame = nil
end
end
end
function WindowInit:Destroy()
self:CreateGlow(false)
if self.particles then
for _, particle in next, self.particles do
if particle.frame then
particle.frame:Destroy()
end
end
self.particles = {}
end
if self.particlesFrame then
self.particlesFrame:Destroy()
self.particlesFrame = nil
end
if self.ReopenButton then
self.ReopenButton:Destroy()
self.ReopenButton = nil
end
for i = #Library.ColorTable, 1, -1 do
if Library.ColorTable[i] == Screen or (Library.ColorTable[i].IsDescendantOf and Library.ColorTable[i]:IsDescendantOf(Screen)) then
table.remove(Library.ColorTable, i)
end
end
if Notifications and Notifications.Container then
Notifications.Container:Destroy()
end
if Notifications then
Notifications:Destroy()
end
end
function Library:Destroy()
WindowInit:Destroy()
if shared.Dachshund and shared.Dachshund.Elements then
local vvvvvv = 0
for _ in next, shared.Dachshund.Elements do
vvvvvv += 1
end
--print("Destroyed " .. vvvvvv .. " elements")
shared.Dachshund.Elements = {}
end
if Library.Connections then
local vvvvvxx = 0
for i, connection in next, Library.Connections do
if connection and connection.Disconnect then
connection:Disconnect()
Library.Connections[i] = nil
vvvvvxx += 1
end
end
--print("Disconnected " .. vvvvvxx .. " connections")
Library.Connections = {}
end
if Library.flags or shared.Dachshund.flags then
local flagsdd = 0
local function didcone(tbl)
for i, v in next, tbl do
if type(v) == "table" then
didcone(v)
elseif typeof(v) == "RBXScriptConnection" then
v:Disconnect()
tbl[i] = nil
flagsdd += 1
elseif type(v) == "table" and type(v.Disconnect) == "function" then
v:Disconnect()
tbl[i] = nil
flagsdd += 1
elseif type(v) == "boolean" then
tbl[i] = false
elseif type(v) == "function" then
tbl[i] = nil
end
end
end
didcone(Library.flags)
didcone(shared.Dachshund.flags)
-- print("Disconnected " .. flagsdd .. " flag connections")
end
Library.ColorTable = {}
if shared.Dachshund then
shared.Dachshund.ElementCounter = 0
end
if Screen then
Screen:Destroy()
end
Library.tick = nil
Library.flags = nil
shared.Dachshund.flags = nil
--print("Library destroyed")
end
return WindowInit
end
return Library
