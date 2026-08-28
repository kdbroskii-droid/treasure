--[[
    Treasure UI Library
    Version 1.0.0
    A Rayfield-inspired UI template for Roblox Studio games
]]

local Treasure = {}
Treasure.__index = Treasure

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

-- Constants
local DEFAULT_THEME = {
    Name = "Default",
    Background = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.35,
    Accent = Color3.fromRGB(120, 80, 255),
    AccentTransparency = 0.35,
    TextColor = Color3.fromRGB(255, 255, 255),
    SecondaryText = Color3.fromRGB(200, 200, 255),
    BorderColor = Color3.fromRGB(255, 255, 255),
    BorderTransparency = 0.5,
    ButtonColor = Color3.fromRGB(120, 80, 255),
    ButtonHover = Color3.fromRGB(140, 100, 255),
    ToggleOn = Color3.fromRGB(120, 80, 255),
    ToggleOff = Color3.fromRGB(60, 60, 80),
    SliderColor = Color3.fromRGB(120, 80, 255),
    DropdownColor = Color3.fromRGB(60, 60, 80),
    SectionColor = Color3.fromRGB(120, 80, 255),
}

local THEMES = {
    Default = DEFAULT_THEME,
    Purple = {
        Name = "Purple",
        Background = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.35,
        Accent = Color3.fromRGB(160, 60, 255),
        AccentTransparency = 0.35,
        TextColor = Color3.fromRGB(255, 255, 255),
        SecondaryText = Color3.fromRGB(220, 180, 255),
        BorderColor = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.5,
        ButtonColor = Color3.fromRGB(160, 60, 255),
        ButtonHover = Color3.fromRGB(180, 80, 255),
        ToggleOn = Color3.fromRGB(160, 60, 255),
        ToggleOff = Color3.fromRGB(60, 60, 80),
        SliderColor = Color3.fromRGB(160, 60, 255),
        DropdownColor = Color3.fromRGB(60, 60, 80),
        SectionColor = Color3.fromRGB(160, 60, 255),
    },
    Blue = {
        Name = "Blue",
        Background = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.35,
        Accent = Color3.fromRGB(60, 120, 255),
        AccentTransparency = 0.35,
        TextColor = Color3.fromRGB(255, 255, 255),
        SecondaryText = Color3.fromRGB(180, 200, 255),
        BorderColor = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.5,
        ButtonColor = Color3.fromRGB(60, 120, 255),
        ButtonHover = Color3.fromRGB(80, 140, 255),
        ToggleOn = Color3.fromRGB(60, 120, 255),
        ToggleOff = Color3.fromRGB(60, 60, 80),
        SliderColor = Color3.fromRGB(60, 120, 255),
        DropdownColor = Color3.fromRGB(60, 60, 80),
        SectionColor = Color3.fromRGB(60, 120, 255),
    },
    Dark = {
        Name = "Dark",
        Background = Color3.fromRGB(30, 30, 40),
        BackgroundTransparency = 0.2,
        Accent = Color3.fromRGB(100, 80, 200),
        AccentTransparency = 0.3,
        TextColor = Color3.fromRGB(255, 255, 255),
        SecondaryText = Color3.fromRGB(200, 200, 220),
        BorderColor = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.3,
        ButtonColor = Color3.fromRGB(100, 80, 200),
        ButtonHover = Color3.fromRGB(120, 100, 220),
        ToggleOn = Color3.fromRGB(100, 80, 200),
        ToggleOff = Color3.fromRGB(60, 60, 70),
        SliderColor = Color3.fromRGB(100, 80, 200),
        DropdownColor = Color3.fromRGB(60, 60, 70),
        SectionColor = Color3.fromRGB(100, 80, 200),
    },
    Light = {
        Name = "Light",
        Background = Color3.fromRGB(245, 245, 255),
        BackgroundTransparency = 0.2,
        Accent = Color3.fromRGB(80, 60, 180),
        AccentTransparency = 0.3,
        TextColor = Color3.fromRGB(40, 40, 60),
        SecondaryText = Color3.fromRGB(80, 80, 100),
        BorderColor = Color3.fromRGB(100, 80, 200),
        BorderTransparency = 0.3,
        ButtonColor = Color3.fromRGB(80, 60, 180),
        ButtonHover = Color3.fromRGB(100, 80, 200),
        ToggleOn = Color3.fromRGB(80, 60, 180),
        ToggleOff = Color3.fromRGB(200, 200, 210),
        SliderColor = Color3.fromRGB(80, 60, 180),
        DropdownColor = Color3.fromRGB(200, 200, 210),
        SectionColor = Color3.fromRGB(80, 60, 180),
    }
}

-- Internal state
local currentTheme = "Default"
local currentScale = 1
local animationsEnabled = true
local reduceAnimations = false
local showNotifications = true
local uiEnabled = true
local windows = {}
local notificationContainer = nil
local floatingButton = nil
local isMobile = false

-- Utility functions
local function IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

local function GetScreenSize()
    return workspace.CurrentCamera.ViewportSize
end

local function CreateRoundedFrame(parent, size, position, color, transparency, cornerRadius)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = color
    frame.BackgroundTransparency = transparency
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius or 8)
    corner.Parent = frame
    
    return frame
end

local function CreateShadow(frame, size, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Size = size or UDim2.new(1, 0, 1, 0)
    shadow.Position = UDim2.new(0, 0, 0, 0)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316044069"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = transparency or 0.3
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(8, 8, 8, 8)
    shadow.Parent = frame
    return shadow
end

local function TweenObject(object, properties, duration, style, direction)
    if not object then return end
    local tweenInfo = TweenInfo.new(
        duration or 0.25,
        style or Enum.EasingStyle.Quint,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Notification System
local function CreateNotificationContainer()
    if notificationContainer then return end
    
    notificationContainer = Instance.new("Frame")
    notificationContainer.Size = UDim2.new(0, 350, 0, 0)
    notificationContainer.Position = UDim2.new(1, -370, 0, 80)
    notificationContainer.BackgroundTransparency = 1
    notificationContainer.Parent = game:GetService("CoreGui")
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Parent = notificationContainer
    
    local padding = Instance.new("UIPadding")
    padding.PaddingBottom = UDim.new(0, 8)
    padding.PaddingTop = UDim.new(0, 8)
    padding.Parent = notificationContainer
end

function Treasure:Notify(config)
    if not showNotifications then return end
    
    CreateNotificationContainer()
    
    local title = config.Title or "Treasure"
    local content = config.Content or ""
    local duration = config.Duration or 3
    
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(1, 0, 0, 60)
    notification.BackgroundColor3 = THEMES[currentTheme].Background
    notification.BackgroundTransparency = THEMES[currentTheme].BackgroundTransparency + 0.1
    notification.BorderSizePixel = 0
    notification.Parent = notificationContainer
    notification.Position = UDim2.new(0, 0, 0, -80)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification
    
    local shadow = CreateShadow(notification, UDim2.new(1, 4, 1, 4), 0.2)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 0, 24)
    titleLabel.Position = UDim2.new(0, 12, 0, 4)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = THEMES[currentTheme].TextColor
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = notification
    
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -40, 0, 28)
    contentLabel.Position = UDim2.new(0, 12, 0, 28)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = THEMES[currentTheme].SecondaryText
    contentLabel.TextSize = 14
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.Font = Enum.Font.SourceSans
    contentLabel.Parent = notification
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -30, 0, 4)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = THEMES[currentTheme].SecondaryText
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.SourceSans
    closeBtn.Parent = notification
    
    local progress = Instance.new("Frame")
    progress.Size = UDim2.new(1, 0, 0, 2)
    progress.Position = UDim2.new(0, 0, 1, -2)
    progress.BackgroundColor3 = THEMES[currentTheme].Accent
    progress.BackgroundTransparency = THEMES[currentTheme].AccentTransparency
    progress.BorderSizePixel = 0
    progress.Parent = notification
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 2)
    progressCorner.Parent = progress
    
    -- Animate in
    TweenObject(notification, {
        Position = UDim2.new(0, 0, 0, 0)
    }, 0.3, Enum.EasingStyle.Quint)
    
    -- Progress bar
    local progressTween = TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 2)
    })
    progressTween:Play()
    
    local function CloseNotification()
        progressTween:Cancel()
        TweenObject(notification, {
            Position = UDim2.new(0, 0, 0, -80)
        }, 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        
        task.wait(0.25)
        notification:Destroy()
    end
    
    closeBtn.MouseButton1Click:Connect(CloseNotification)
    
    task.wait(duration)
    if notification and notification.Parent then
        CloseNotification()
    end
end

-- Settings Management
local settingsData = {
    theme = "Default",
    scale = 1,
    animations = true,
    reduceAnimations = false,
    showNotifications = true,
    uiEnabled = true,
}

function Treasure:SaveSettings()
    -- In a real implementation, this would save to DataStore
    -- For now, we just keep in memory
    for key, value in pairs(settingsData) do
        if key == "theme" then
            currentTheme = value
        elseif key == "scale" then
            currentScale = value
        elseif key == "animations" then
            animationsEnabled = value
        elseif key == "reduceAnimations" then
            reduceAnimations = value
        elseif key == "showNotifications" then
            showNotifications = value
        elseif key == "uiEnabled" then
            uiEnabled = value
        end
    end
end

function Treasure:LoadSettings()
    -- In a real implementation, this would load from DataStore
    -- For now, we use defaults
    self:ApplyTheme(currentTheme)
    self:SetScale(currentScale)
end

function Treasure:ApplyTheme(themeName)
    local theme = THEMES[themeName]
    if not theme then return end
    
    currentTheme = themeName
    settingsData.theme = themeName
    
    -- Update all windows
    for _, window in pairs(windows) do
        window:ApplyTheme(theme)
    end
    
    self:SaveSettings()
end

function Treasure:SetScale(scale)
    scale = math.clamp(scale, 0.75, 1.25)
    currentScale = scale
    settingsData.scale = scale
    
    for _, window in pairs(windows) do
        window:SetScale(scale)
    end
    
    self:SaveSettings()
end

-- Window Class
local Window = {}
Window.__index = Window

function Window:ApplyTheme(theme)
    if self.MainFrame then
        self.MainFrame.BackgroundColor3 = theme.Background
        self.MainFrame.BackgroundTransparency = theme.BackgroundTransparency
        
        if self.TitleLabel then
            self.TitleLabel.TextColor3 = theme.TextColor
        end
        if self.SubtitleLabel then
            self.SubtitleLabel.TextColor3 = theme.SecondaryText
        end
        if self.TabContainer then
            for _, child in pairs(self.TabContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    child.TextColor3 = theme.SecondaryText
                end
            end
        end
    end
end

function Window:SetScale(scale)
    if self.UIScale then
        self.UIScale.Scale = scale
    end
end

function Window:CreateTab(name)
    local tabData = {
        Name = name,
        Buttons = {},
        Controls = {},
    }
    
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(0, 100, 1, 0)
    tabButton.BackgroundTransparency = 1
    tabButton.Text = name
    tabButton.TextColor3 = THEMES[currentTheme].SecondaryText
    tabButton.TextSize = 16
    tabButton.Font = Enum.Font.SourceSans
    tabButton.Parent = self.TabContainer
    tabButton.AutoButtonColor = false
    
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Size = UDim2.new(1, -20, 1, -20)
    tabContent.Position = UDim2.new(0, 10, 0, 10)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.ScrollBarThickness = 4
    tabContent.ScrollBarImageColor3 = THEMES[currentTheme].Accent
    tabContent.ScrollBarImageTransparency = 0.5
    tabContent.Parent = self.ContentContainer
    tabContent.Visible = false
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = tabContent
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    local padding = Instance.new("UIPadding")
    padding.PaddingBottom = UDim.new(0, 8)
    padding.PaddingTop = UDim.new(0, 8)
    padding.Parent = tabContent
    
    tabData.Content = tabContent
    tabData.Layout = layout
    tabData.TabButton = tabButton
    
    -- Select first tab by default
    if #self.Tabs == 0 then
        self:SelectTab(tabData)
    end
    
    table.insert(self.Tabs, tabData)
    
    -- Tab click
    tabButton.MouseButton1Click:Connect(function()
        self:SelectTab(tabData)
    end)
    
    -- Update tab colors
    self:UpdateTabs()
    
    return {
        CreateSection = function(self, sectionName)
            return tabData:CreateSection(sectionName)
        end,
        CreateButton = function(self, config)
            return tabData:CreateButton(config)
        end,
        CreateToggle = function(self, config)
            return tabData:CreateToggle(config)
        end,
        CreateSlider = function(self, config)
            return tabData:CreateSlider(config)
        end,
        CreateDropdown = function(self, config)
            return tabData:CreateDropdown(config)
        end,
        CreateTextbox = function(self, config)
            return tabData:CreateTextbox(config)
        end,
        CreateLabel = function(self, text)
            return tabData:CreateLabel(text)
        end,
        CreateKeybind = function(self, config)
            return tabData:CreateKeybind(config)
        end,
    }
end

function Window:SelectTab(tabData)
    if self.SelectedTab == tabData then return end
    
    self.SelectedTab = tabData
    
    -- Hide all tab contents
    for _, tab in pairs(self.Tabs) do
        tab.Content.Visible = false
        tab.TabButton.TextColor3 = THEMES[currentTheme].SecondaryText
    end
    
    -- Show selected tab
    tabData.Content.Visible = true
    tabData.TabButton.TextColor3 = THEMES[currentTheme].Accent
    
    self:UpdateTabs()
end

function Window:UpdateTabs()
    if not self.TabContainer then return end
    
    local totalWidth = 0
    local tabCount = 0
    
    for _, child in pairs(self.TabContainer:GetChildren()) do
        if child:IsA("TextButton") then
            tabCount = tabCount + 1
        end
    end
    
    local width = math.min(100, (self.TabContainer.AbsoluteSize.X - 20) / tabCount)
    
    for _, child in pairs(self.TabContainer:GetChildren()) do
        if child:IsA("TextButton") then
            child.Size = UDim2.new(0, width, 1, 0)
        end
    end
end

function Window:CreateSettingsTab()
    local settingsTab = self:CreateTab("Settings")
    
    settingsTab:CreateSection("UI Settings")
    
    local uiToggle = settingsTab:CreateToggle({
        Name = "Enable UI",
        CurrentValue = uiEnabled,
        Callback = function(value)
            uiEnabled = value
            settingsData.uiEnabled = value
            self.MainFrame.Visible = value
            Treasure:SaveSettings()
        end
    })
    
    local scaleSlider = settingsTab:CreateSlider({
        Name = "UI Scale",
        Min = 0.75,
        Max = 1.25,
        Default = currentScale,
        Increment = 0.01,
        Callback = function(value)
            Treasure:SetScale(value)
        end
    })
    
    local animationsToggle = settingsTab:CreateToggle({
        Name = "Animations",
        CurrentValue = animationsEnabled,
        Callback = function(value)
            animationsEnabled = value
            settingsData.animations = value
            Treasure:SaveSettings()
        end
    })
    
    local reduceAnimToggle = settingsTab:CreateToggle({
        Name = "Reduce Animations",
        CurrentValue = reduceAnimations,
        Callback = function(value)
            reduceAnimations = value
            settingsData.reduceAnimations = value
            Treasure:SaveSettings()
        end
    })
    
    settingsTab:CreateSection("Theme")
    
    local themeDropdown = settingsTab:CreateDropdown({
        Name = "Theme",
        Options = {"Default", "Purple", "Blue", "Dark", "Light"},
        CurrentOption = currentTheme,
        Callback = function(value)
            Treasure:ApplyTheme(value)
        end
    })
    
    settingsTab:CreateSection("Notifications")
    
    local notifToggle = settingsTab:CreateToggle({
        Name = "Show Notifications",
        CurrentValue = showNotifications,
        Callback = function(value)
            showNotifications = value
            settingsData.showNotifications = value
            Treasure:SaveSettings()
        end
    })
    
    settingsTab:CreateSection("Actions")
    
    settingsTab:CreateButton({
        Name = "Reset Settings",
        Callback = function()
            Treasure:ApplyTheme("Default")
            Treasure:SetScale(1)
            animationsEnabled = true
            reduceAnimations = false
            showNotifications = true
            uiEnabled = true
            settingsData = {
                theme = "Default",
                scale = 1,
                animations = true,
                reduceAnimations = false,
                showNotifications = true,
                uiEnabled = true,
            }
            Treasure:SaveSettings()
            Treasure:Notify({
                Title = "Treasure",
                Content = "Settings have been reset!",
                Duration = 2
            })
        end
    })
    
    settingsTab:CreateButton({
        Name = "Close UI",
        Callback = function()
            self:Close()
        end
    })
    
    return settingsTab
end

function Window:Close()
    if self.Closing then return end
    self.Closing = true
    
    -- Close animation
    local duration = reduceAnimations and 0.1 or 0.2
    TweenObject(self.MainFrame, {
        Size = UDim2.new(0.7, 0, 0.7, 0),
        Position = UDim2.new(0.15, 0, 0.15, 0),
        BackgroundTransparency = 1,
    }, duration, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    
    task.wait(duration + 0.1)
    
    self.MainFrame.Visible = false
    
    -- Show floating button if minimized
    if self.Minimized then
        self:ShowFloatingButton()
    end
end

function Window:Minimize()
    if self.Minimized then return end
    self.Minimized = true
    
    local duration = reduceAnimations and 0.1 or 0.25
    TweenObject(self.MainFrame, {
        Size = UDim2.new(0.1, 0, 0.1, 0),
        Position = UDim2.new(0.45, 0, 0.45, 0),
        BackgroundTransparency = 1,
    }, duration, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    
    task.wait(duration + 0.1)
    self.MainFrame.Visible = false
    
    self:ShowFloatingButton()
end

function Window:ShowFloatingButton()
    if floatingButton then return end
    
    local buttonSize = isMobile and 50 or 40
    
    floatingButton = Instance.new("ImageButton")
    floatingButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    floatingButton.Position = UDim2.new(0.9, 0, 0.1, 0)
    floatingButton.BackgroundColor3 = THEMES[currentTheme].Background
    floatingButton.BackgroundTransparency = THEMES[currentTheme].BackgroundTransparency + 0.1
    floatingButton.BorderSizePixel = 0
    floatingButton.Parent = game:GetService("CoreGui")
    floatingButton.Image = ""
    floatingButton.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = floatingButton
    
    local shadow = CreateShadow(floatingButton, UDim2.new(1, 4, 1, 4), 0.3)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = isMobile and "T" or "T"
    label.TextColor3 = THEMES[currentTheme].TextColor
    label.TextSize = isMobile and 24 or 18
    label.Font = Enum.Font.SourceSansBold
    label.Parent = floatingButton
    
    -- Make draggable
    local dragging = false
    local dragStart, startPos
    
    floatingButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = floatingButton.Position
        end
    end)
    
    floatingButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    floatingButton.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale + (delta.X / GetScreenSize().X),
                0,
                startPos.Y.Scale + (delta.Y / GetScreenSize().Y),
                0
            )
            floatingButton.Position = newPos
        end
    end)
    
    floatingButton.MouseButton1Click:Connect(function()
        self:Restore()
    end)
    
    -- Animate in
    floatingButton.Size = UDim2.new(0, 0, 0, 0)
    TweenObject(floatingButton, {
        Size = UDim2.new(0, buttonSize, 0, buttonSize)
    }, 0.3, Enum.EasingStyle.Quint)
end

function Window:Restore()
    if not self.Minimized then return end
    self.Minimized = false
    
    if floatingButton then
        floatingButton:Destroy()
        floatingButton = nil
    end
    
    self.MainFrame.Visible = true
    
    local duration = reduceAnimations and 0.1 or 0.3
    TweenObject(self.MainFrame, {
        Size = UDim2.new(0, self.WindowSize.X, 0, self.WindowSize.Y),
        Position = UDim2.new(0.5, -self.WindowSize.X/2, 0.5, -self.WindowSize.Y/2),
        BackgroundTransparency = THEMES[currentTheme].BackgroundTransparency,
    }, duration, Enum.EasingStyle.Quint)
end

function Window:Toggle()
    if self.MainFrame.Visible then
        self:Minimize()
    else
        self:Restore()
    end
end

function Window:Destroy()
    if self.MainFrame then
        self.MainFrame:Destroy()
    end
    if floatingButton then
        floatingButton:Destroy()
        floatingButton = nil
    end
    self.Destroyed = true
end

-- Create Window
function Treasure:CreateWindow(config)
    local window = setmetatable({}, Window)
    window.Tabs = {}
    window.Minimized = false
    window.Closing = false
    window.Destroyed = false
    
    isMobile = IsMobile()
    
    local screenSize = GetScreenSize()
    local windowWidth = isMobile and math.min(400, screenSize.X * 0.85) or math.min(500, screenSize.X * 0.6)
    local windowHeight = isMobile and math.min(500, screenSize.Y * 0.75) or math.min(600, screenSize.Y * 0.7)
    
    window.WindowSize = Vector2.new(windowWidth, windowHeight)
    
    -- Main Frame
    local mainFrame = CreateRoundedFrame(
        game:GetService("CoreGui"),
        UDim2.new(0, windowWidth, 0, windowHeight),
        UDim2.new(0.5, -windowWidth/2, 0.5, -windowHeight/2),
        THEMES[currentTheme].Background,
        THEMES[currentTheme].BackgroundTransparency,
        12
    )
    mainFrame.ClipsDescendants = true
    
    -- Shadow
    local shadow = CreateShadow(mainFrame, UDim2.new(1, 8, 1, 8), 0.3)
    shadow.ZIndex = 0
    
    -- UI Scale
    local uiScale = Instance.new("UIScale")
    uiScale.Scale = currentScale
    uiScale.Parent = mainFrame
    
    window.MainFrame = mainFrame
    window.UIScale = uiScale
    
    -- Top Bar
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = THEMES[currentTheme].Accent
    topBar.BackgroundTransparency = THEMES[currentTheme].AccentTransparency + 0.2
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame
    
    local topBarCorner = Instance.new("UICorner")
    topBarCorner.CornerRadius = UDim.new(0, 12)
    topBarCorner.Parent = topBar
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = config.Name or "Treasure"
    titleLabel.TextColor3 = THEMES[currentTheme].TextColor
    titleLabel.TextSize = isMobile and 20 or 22
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = topBar
    
    window.TitleLabel = titleLabel
    
    -- Subtitle
    if config.Subtitle then
        local subtitleLabel = Instance.new("TextLabel")
        subtitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
        subtitleLabel.Position = UDim2.new(0, 12, 0, 22)
        subtitleLabel.BackgroundTransparency = 1
        subtitleLabel.Text = config.Subtitle
        subtitleLabel.TextColor3 = THEMES[currentTheme].SecondaryText
        subtitleLabel.TextSize = isMobile and 12 or 14
        subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        subtitleLabel.Font = Enum.Font.SourceSans
        subtitleLabel.Parent = topBar
        window.SubtitleLabel = subtitleLabel
        topBar.Size = UDim2.new(1, 0, 0, 55)
    end
    
    -- Minimize Button
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -65, 0, 5)
    minBtn.BackgroundTransparency = 1
    minBtn.Text = "─"
    minBtn.TextColor3 = THEMES[currentTheme].TextColor
    minBtn.TextSize = 20
    minBtn.Font = Enum.Font.SourceSans
    minBtn.Parent = topBar
    minBtn.AutoButtonColor = false
    
    minBtn.MouseButton1Click:Connect(function()
        window:Minimize()
    end)
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = THEMES[currentTheme].TextColor
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.SourceSans
    closeBtn.Parent = topBar
    closeBtn.AutoButtonColor = false
    
    closeBtn.MouseButton1Click:Connect(function()
        window:Close()
    end)
    
    -- Tab Container
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 30)
    tabContainer.Position = UDim2.new(0, 0, 0, topBar.Size.Y.Offset + 5)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.Parent = tabContainer
    
    window.TabContainer = tabContainer
    
    -- Content Container
    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, 0, 1, -(topBar.Size.Y.Offset + 35))
    contentContainer.Position = UDim2.new(0, 0, 0, topBar.Size.Y.Offset + 35)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ClipsDescendants = true
    contentContainer.Parent = mainFrame
    
    window.ContentContainer = contentContainer
    
    -- Make draggable
    local dragging = false
    local dragStart, startPos
    
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    topBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    topBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale + (delta.X / GetScreenSize().X),
                0,
                startPos.Y.Scale + (delta.Y / GetScreenSize().Y),
                0
            )
            mainFrame.Position = newPos
        end
    end)
    
    -- Opening animation
    mainFrame.Size = UDim2.new(0, windowWidth * 0.95, 0, windowHeight * 0.95)
    mainFrame.Position = UDim2.new(0.5, -windowWidth * 0.95/2, 0.5, -windowHeight * 0.95/2 + 10)
    mainFrame.BackgroundTransparency = THEMES[currentTheme].BackgroundTransparency + 0.2
    
    task.wait(0.05)
    
    TweenObject(mainFrame, {
        Size = UDim2.new(0, windowWidth, 0, windowHeight),
        Position = UDim2.new(0.5, -windowWidth/2, 0.5, -windowHeight/2),
        BackgroundTransparency = THEMES[currentTheme].BackgroundTransparency,
    }, reduceAnimations and 0.15 or 0.3, Enum.EasingStyle.Quint)
    
    -- Create settings tab automatically
    window:CreateSettingsTab()
    
    -- Store window
    table.insert(windows, window)
    
    -- Return API
    return {
        CreateTab = function(self, name)
            return window:CreateTab(name)
        end,
        ApplyTheme = function(self, theme)
            window:ApplyTheme(theme)
        end,
        SetScale = function(self, scale)
            window:SetScale(scale)
        end,
        Toggle = function(self)
            window:Toggle()
        end,
        Close = function(self)
            window:Close()
        end,
        Destroy = function(self)
            window:Destroy()
        end,
        Minimize = function(self)
            window:Minimize()
        end,
        Restore = function(self)
            window:Restore()
        end,
    }
end

-- Tab Class
local Tab = {}
Tab.__index = Tab

function Tab:CreateSection(name)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -10, 0, 30)
    section.BackgroundTransparency = 1
    section.Parent = self.Content
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = THEMES[currentTheme].SectionColor
    label.TextSize = isMobile and 14 or 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.SourceSansBold
    label.Parent = section
    
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.new(0, 0, 1, -2)
    divider.BackgroundColor3 = THEMES[currentTheme].Accent
    divider.BackgroundTransparency = THEMES[currentTheme].AccentTransparency + 0.3
    divider.BorderSizePixel = 0
    divider.Parent = section
    
    return section
end

function Tab:CreateButton(config)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 35)
    button.BackgroundColor3 = THEMES[currentTheme].ButtonColor
    button.BackgroundTransparency = THEMES[currentTheme].AccentTransparency + 0.1
    button.TextColor3 = THEMES[currentTheme].TextColor
    button.TextSize = isMobile and 15 or 16
    button.Font = Enum.Font.SourceSans
    button.Text = config.Name or "Button"
    button.Parent = self.Content
    button.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        if UserInputService.MouseEnabled then
            TweenObject(button, {
                BackgroundTransparency = THEMES[currentTheme].AccentTransparency - 0.1
            }, 0.15)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if UserInputService.MouseEnabled then
            TweenObject(button, {
                BackgroundTransparency = THEMES[currentTheme].AccentTransparency + 0.1
            }, 0.15)
        end
    end)
    
    -- Click animation
    button.MouseButton1Click:Connect(function()
        -- Fun click animation
        TweenObject(button, {
            Size = UDim2.new(1, -10, 0, 32),
            BackgroundTransparency = THEMES[currentTheme].AccentTransparency + 0.2
        }, 0.08, Enum.EasingStyle.Quad)
        
        task.wait(0.08)
        
        TweenObject(button, {
            Size = UDim2.new(1, -10, 0, 35),
            BackgroundTransparency = THEMES[currentTheme].AccentTransparency + 0.1
        }, 0.08, Enum.EasingStyle.Quad)
        
        if config.Callback then
            pcall(config.Callback)
        end
    end)
    
    return button
end

function Tab:CreateToggle(config)
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(1, -10, 0, 35)
    toggle.BackgroundTransparency = 1
    toggle.Parent = self.Content
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Toggle"
    label.TextColor3 = THEMES[currentTheme].TextColor
    label.TextSize = isMobile and 15 or 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.SourceSans
    label.Parent = toggle
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 50, 0, 28)
    toggleFrame.Position = UDim2.new(1, -55, 0.5, -14)
    toggleFrame.BackgroundColor3 = THEMES[currentTheme].ToggleOff
    toggleFrame.BackgroundTransparency = 0.3
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = toggle
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleFrame
    
    local toggleButton = Instance.new("Frame")
    toggleButton.Size = UDim2.new(0, 22, 0, 22)
    toggleButton.Position = UDim2.new(0, 3, 0.5, -11)
    toggleButton.BackgroundColor3 = THEMES[currentTheme].TextColor
    toggleButton.BackgroundTransparency = 0.2
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = toggleFrame
    
    local toggleBtnCorner = Instance.new("UICorner")
    toggleBtnCorner.CornerRadius = UDim.new(1, 0)
    toggleBtnCorner.Parent = toggleButton
    
    local value = config.CurrentValue or false
    local callback = config.Callback
    
    local function UpdateToggle(newValue)
        value = newValue
        local targetX = value and 25 or 3
        TweenObject(toggleButton, {
            Position = UDim2.new(0, targetX, 0.5, -11)
        }, 0.2, Enum.EasingStyle.Quad)
        
        TweenObject(toggleFrame, {
            BackgroundColor3 = value and THEMES[currentTheme].ToggleOn or THEMES[currentTheme].ToggleOff
        }, 0.2, Enum.EasingStyle.Quad)
        
        if callback then
            pcall(callback, value)
        end
    end
    
    -- Click handler
    local inputHandler = Instance.new("Frame")
    inputHandler.Size = UDim2.new(1, 0, 1, 0)
    inputHandler.BackgroundTransparency = 1
    inputHandler.Parent = toggleFrame
    
    inputHandler.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            UpdateToggle(not value)
        end
    end)
    
    -- Set initial state
    UpdateToggle(value)
    
    local api = {
        Set = function(self, newValue)
            UpdateToggle(newValue)
        end,
        Get = function(self)
            return value
        end
    }
    
    return api
end

function Tab:CreateSlider(config)
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, -10, 0, 50)
    slider.BackgroundTransparency = 1
    slider.Parent = self.Content
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, -10, 0, 20)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Slider"
    label.TextColor3 = THEMES[currentTheme].TextColor
    label.TextSize = isMobile and 15 or 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.SourceSans
    label.Parent = slider
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.2, 0, 0, 20)
    valueLabel.Position = UDim2.new(0.8, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(config.Default or 50)
    valueLabel.TextColor3 = THEMES[currentTheme].SecondaryText
    valueLabel.TextSize = isMobile and 14 or 15
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Font = Enum.Font.SourceSans
    valueLabel.Parent = slider
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -10, 0, 4)
    track.Position = UDim2.new(0, 5, 0, 30)
    track.BackgroundColor3 = THEMES[currentTheme].DropdownColor
    track.BackgroundTransparency = 0.3
    track.BorderSizePixel = 0
    track.Parent = slider
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0.5, 0, 1, 0)
    fill.BackgroundColor3 = THEMES[currentTheme].SliderColor
    fill.BackgroundTransparency = THEMES[currentTheme].AccentTransparency
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 16, 0, 16)
    handle.Position = UDim2.new(0.5, -8, 0.5, -8)
    handle.BackgroundColor3 = THEMES[currentTheme].SliderColor
    handle.BackgroundTransparency = THEMES[currentTheme].AccentTransparency
    handle.BorderSizePixel = 0
    handle.Parent = track
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = handle
    
    local min = config.Min or 0
    local max = config.Max or 100
    local current = config.Default or 50
    local increment = config.Increment or 1
    local callback = config.Callback
    
    local function UpdateSlider(value)
        value = math.clamp(value, min, max)
        if increment then
            value = math.floor(value / increment + 0.5) * increment
        end
        current = value
        
        local percent = (value - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        handle.Position = UDim2.new(percent, -8, 0.5, -8)
        valueLabel.Text = tostring(value)
        
        if callback then
            pcall(callback, value)
        end
    end
    
    -- Track click
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            local pos = input.Position.X - track.AbsolutePosition.X
            local percent = math.clamp(pos / track.AbsoluteSize.X, 0, 1)
            local value = min + (max - min) * percent
            UpdateSlider(value)
        end
    end)
    
    -- Handle drag
    local dragging = false
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    track.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                         input.UserInputType == Enum.UserInputType.Touch) then
            local pos = input.Position.X - track.AbsolutePosition.X
            local percent = math.clamp(pos / track.AbsoluteSize.X, 0, 1)
            local value = min + (max - min) * percent
            UpdateSlider(value)
        end
    end)
    
    -- Set initial value
    UpdateSlider(current)
    
    local api = {
        Set = function(self, value)
            UpdateSlider(value)
        end,
        Get = function(self)
            return current
        end
    }
    
    return api
end

function Tab:CreateDropdown(config)
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(1, -10, 0, 35)
    dropdown.BackgroundTransparency = 1
    dropdown.ClipsDescendants = false
    dropdown.Parent = self.Content
    dropdown.AutomaticSize = Enum.AutomaticSize.Y
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Dropdown"
    label.TextColor3 = THEMES[currentTheme].TextColor
    label.TextSize = isMobile and 15 or 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.SourceSans
    label.Parent = dropdown
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(0, 120, 1, 0)
    dropdownButton.Position = UDim2.new(1, -125, 0, 0)
    dropdownButton.BackgroundColor3 = THEMES[currentTheme].DropdownColor
    dropdownButton.BackgroundTransparency = 0.3
    dropdownButton.TextColor3 = THEMES[currentTheme].TextColor
    dropdownButton.TextSize = isMobile and 14 or 15
    dropdownButton.Font = Enum.Font.SourceSans
    dropdownButton.Text = config.CurrentOption or "Select"
    dropdownButton.Parent = dropdown
    dropdownButton.AutoButtonColor = false
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 6)
    dropdownCorner.Parent = dropdownButton
    
    local optionsContainer = Instance.new("Frame")
    optionsContainer.Size = UDim2.new(0, 120, 0, 0)
    optionsContainer.Position = UDim2.new(1, -125, 1, 0)
    optionsContainer.BackgroundColor3 = THEMES[currentTheme].Background
    optionsContainer.BackgroundTransparency = THEMES[currentTheme].BackgroundTransparency + 0.1
    optionsContainer.ClipsDescendants = true
    optionsContainer.Parent = dropdown
    optionsContainer.ZIndex = 2
    optionsContainer.Visible = false
    
    local optionsCorner = Instance.new("UICorner")
    optionsCorner.CornerRadius = UDim.new(0, 6)
    optionsCorner.Parent = optionsContainer
    
    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.Padding = UDim.new(0, 2)
    optionsLayout.Parent = optionsContainer
    
    local optionsList = {}
    local isOpen = false
    local currentOption = config.CurrentOption or config.Options[1]
    local callback = config.Callback
    
    local function UpdateOptions()
        -- Clear old options
        for _, child in pairs(optionsContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        local optionHeight = isMobile and 30 or 28
        
        for _, optionName in pairs(config.Options) do
            local optionBtn = Instance.new("TextButton")
            optionBtn.Size = UDim2.new(1, 0, 0, optionHeight)
            optionBtn.BackgroundTransparency = 0.5
            optionBtn.TextColor3 = THEMES[currentTheme].TextColor
            optionBtn.TextSize = isMobile and 14 or 15
            optionBtn.Font = Enum.Font.SourceSans
            optionBtn.Text = optionName
            optionBtn.Parent = optionsContainer
            optionBtn.ZIndex = 3
            optionBtn.AutoButtonColor = false
            
            optionBtn.MouseEnter:Connect(function()
                optionBtn.BackgroundTransparency = 0.2
            end)
            
            optionBtn.MouseLeave:Connect(function()
                optionBtn.BackgroundTransparency = 0.5
            end)
            
            optionBtn.MouseButton1Click:Connect(function()
                currentOption = optionName
                dropdownButton.Text = optionName
                if callback then
                    pcall(callback, optionName)
                end
                CloseDropdown()
            end)
            
            table.insert(optionsList, optionBtn)
        end
        
        -- Update container size
        local totalHeight = #config.Options * (optionHeight + 2)
        optionsContainer.Size = UDim2.new(0, 120, 0, totalHeight)
    end
    
    local function OpenDropdown()
        if isOpen then return end
        isOpen = true
        
        -- Show and animate
        optionsContainer.Visible = true
        optionsContainer.Size = UDim2.new(0, 120, 0, 0)
        
        TweenObject(optionsContainer, {
            Size = UDim2.new(0, 120, 0, #config.Options * (isMobile and 30 or 28))
        }, reduceAnimations and 0.1 or 0.25, Enum.EasingStyle.Quad)
        
        -- Update dropdown size to accommodate options
        dropdown.AutomaticSize = Enum.AutomaticSize.Y
        dropdown.Size = UDim2.new(1, -10, 0, 35 + #config.Options * (isMobile and 30 or 28))
    end
    
    local function CloseDropdown()
        if not isOpen then return end
        isOpen = false
        
        TweenObject(optionsContainer, {
            Size = UDim2.new(0, 120, 0, 0)
        }, reduceAnimations and 0.1 or 0.2, Enum.EasingStyle.Quad)
        
        task.wait(reduceAnimations and 0.1 or 0.2)
        optionsContainer.Visible = false
        
        -- Reset size
        dropdown.Size = UDim2.new(1, -10, 0, 35)
        dropdown.AutomaticSize = Enum.AutomaticSize.None
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        if isOpen then
            CloseDropdown()
        else
            OpenDropdown()
        end
    end)
    
    -- Initialize
    UpdateOptions()
    dropdownButton.Text = currentOption
    
    local api = {
        Set = function(self, option)
            if table.find(config.Options, option) then
                currentOption = option
                dropdownButton.Text = option
                if callback then
                    pcall(callback, option)
                end
            end
        end,
        Get = function(self)
            return currentOption
        end,
        Refresh = function(self, newOptions)
            config.Options = newOptions
            UpdateOptions()
            if not table.find(newOptions, currentOption) then
                currentOption = newOptions[1]
                dropdownButton.Text = currentOption
            end
        end,
        Open = function(self)
            OpenDropdown()
        end,
        Close = function(self)
            CloseDropdown()
        end
    }
    
    return api
end

function Tab:CreateTextbox(config)
    local textbox = Instance.new("Frame")
    textbox.Size = UDim2.new(1, -10, 0, 35)
    textbox.BackgroundTransparency = 1
    textbox.Parent = self.Content
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Textbox"
    label.TextColor3 = THEMES[currentTheme].TextColor
    label.TextSize = isMobile and 15 or 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.SourceSans
    label.Parent = textbox
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0, 120, 1, 0)
    input.Position = UDim2.new(1, -125, 0, 0)
    input.BackgroundColor3 = THEMES[currentTheme].DropdownColor
    input.BackgroundTransparency = 0.3
    input.TextColor3 = THEMES[currentTheme].TextColor
    input.TextSize = isMobile and 14 or 15
    input.Font = Enum.Font.SourceSans
    input.PlaceholderText = config.PlaceholderText or "Enter..."
    input.PlaceholderColor3 = THEMES[currentTheme].SecondaryText
    input.Parent = textbox
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = input
    
    local callback = config.Callback
    
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then
            pcall(callback, input.Text)
        end
    end)
    
    return input
end

function Tab:CreateLabel(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = text or "Label"
    label.TextColor3 = THEMES[currentTheme].SecondaryText
    label.TextSize = isMobile and 14 or 15
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = self.Content
    
    local api = {
        Set = function(self, newText)
            label.Text = newText
        end,
        Get = function(self)
            return label.Text
        end
    }
    
    return api
end

function Tab:CreateKeybind(config)
    local keybind = Instance.new("Frame")
    keybind.Size = UDim2.new(1, -10, 0, 35)
    keybind.BackgroundTransparency = 1
    keybind.Parent = self.Content
    
    -- Only show on PC
    if IsMobile() then
        keybind.Visible = false
        return {}
    end
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Keybind"
    label.TextColor3 = THEMES[currentTheme].TextColor
    label.TextSize = isMobile and 15 or 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.SourceSans
    label.Parent = keybind
    
    local keyButton = Instance.new("TextButton")
    keyButton.Size = UDim2.new(0, 80, 1, 0)
    keyButton.Position = UDim2.new(1, -85, 0, 0)
    keyButton.BackgroundColor3 = THEMES[currentTheme].DropdownColor
    keyButton.BackgroundTransparency = 0.3
    keyButton.TextColor3 = THEMES[currentTheme].TextColor
    keyButton.TextSize = isMobile and 14 or 15
    keyButton.Font = Enum.Font.SourceSans
    keyButton.Text = config.CurrentKeybind and config.CurrentKeybind.Name or "None"
    keyButton.Parent = keybind
    keyButton.AutoButtonColor = false
    
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 6)
    keyCorner.Parent = keyButton
    
    local currentKey = config.CurrentKeybind or Enum.KeyCode.None
    local callback = config.Callback
    local listening = false
    
    keyButton.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyButton.Text = "..."
        keyButton.BackgroundColor3 = THEMES[currentTheme].Accent
        
        local inputConnection
        inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                listening = false
                currentKey = input.KeyCode
                keyButton.Text = currentKey.Name
                keyButton.BackgroundColor3 = THEMES[currentTheme].DropdownColor
                inputConnection:Disconnect()
                if callback then
                    pcall(callback)
                end
            end
        end)
        
        -- Timeout after 5 seconds
        task.wait(5)
        if listening then
            listening = false
            keyButton.Text = currentKey.Name ~= "None" and currentKey.Name or "None"
            keyButton.BackgroundColor3 = THEMES[currentTheme].DropdownColor
            if inputConnection then
                inputConnection:Disconnect()
            end
        end
    end)
    
    return {
        Set = function(self, key)
            currentKey = key
            keyButton.Text = key.Name
        end,
        Get = function(self)
            return currentKey
        end
    }
end

-- Initialize
Treasure:LoadSettings()

-- Return the library
return Treasure
