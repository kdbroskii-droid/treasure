--[[
    TREASURE UI LIBRARY
    GitHub: https://raw.githubusercontent.com/kdbroskii-droid/treasure/main/treasure.lua

    Built for Roblox experiences you control.
    Features:
      • Automatic PC / mobile detection
      • Responsive sizing (mobile is ~1.6x smaller)
      • Automatic Settings tab
      • Blue transparent UI + purple/blue text
      • Window open / minimize animations
      • Button / toggle / tab / dropdown / slider animations
      • Sections, labels, buttons, toggles, sliders, dropdowns, textboxes, keybinds
      • Color picker
      • Search
      • Notifications
      • Notification queue
      • Draggable window
      • Optional watermark
      • Theme / accent / transparency controls
      • Animation controls
      • Session setting restoration when the window is recreated
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Treasure = {}
Treasure.__index = Treasure

--// =========================================================
--// DEFAULTS
--// =========================================================

local DEFAULTS = {
    Accent = Color3.fromRGB(125, 95, 255),
    Background = Color3.fromRGB(14, 25, 42),
    Text = Color3.fromRGB(220, 225, 255),
    MutedText = Color3.fromRGB(155, 165, 205),

    Transparency = 0.35,

    Animations = true,
    AnimationSpeed = 1,
    ButtonEffects = true,
    TabAnimations = true,
    WindowAnimations = true,
    NotificationAnimations = true,

    Notifications = true,
    Watermark = false,

    UIKey = Enum.KeyCode.RightShift,
}

local sessionSettings = {}

--// =========================================================
--// HELPERS
--// =========================================================

local function cloneDefaults()
    local t = {}
    for k, v in pairs(DEFAULTS) do
        t[k] = v
    end
    return t
end

local function tween(obj, info, props)
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

local function getScale()
    local cam = workspace.CurrentCamera
    if not cam then
        return 1
    end

    local viewport = cam.ViewportSize
    local isTouch = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

    if isTouch or viewport.X < 700 then
        return 0.625
    end

    return 1
end

local function round(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
    return c
end

local function stroke(parent, color, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.new(1, 1, 1)
    s.Transparency = transparency or 0
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

local function padding(parent, amount)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, amount)
    p.PaddingBottom = UDim.new(0, amount)
    p.PaddingLeft = UDim.new(0, amount)
    p.PaddingRight = UDim.new(0, amount)
    p.Parent = parent
    return p
end

local function makeButton(parent, text, color)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.BackgroundColor3 = color or Color3.fromRGB(34, 45, 72)
    b.BackgroundTransparency = 0.05
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = DEFAULTS.Text
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    b.Parent = parent
    round(b, 8)
    return b
end

--// =========================================================
--// WINDOW
--// =========================================================

function Treasure:CreateWindow(config)
    config = config or {}

    local self = setmetatable({}, Treasure)

    self.Name = config.Name or "Treasure"
    self.Subtitle = config.Subtitle or "UI Library"
    self.Settings = cloneDefaults()

    for k, v in pairs(sessionSettings) do
        self.Settings[k] = v
    end

    self.Tabs = {}
    self.Controls = {}
    self.SearchResults = {}
    self.ActiveTab = nil
    self.Minimized = false
    self.Visible = true
    self.Scale = getScale()

    --// ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "TreasureUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui
    self.Gui = gui

    --// Root
    local root = Instance.new("Frame")
    root.Name = "Root"
    root.AnchorPoint = Vector2.new(0.5, 0.5)
    root.Position = UDim2.fromScale(0.5, 0.5)
    root.Size = UDim2.fromOffset(690, 450)
    root.BackgroundTransparency = 1
    root.Parent = gui
    self.Root = root

    local scale = Instance.new("UIScale")
    scale.Scale = self.Scale
    scale.Parent = root
    self.UIScale = scale

    --// Main window
    local window = Instance.new("Frame")
    window.Name = "Window"
    window.Size = UDim2.fromScale(1, 1)
    window.BackgroundColor3 = self.Settings.Background
    window.BackgroundTransparency = self.Settings.Transparency
    window.BorderSizePixel = 0
    window.Parent = root
    round(window, 14)
    stroke(window, self.Settings.Accent, 0.55, 1)
    self.Window = window

    --// Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 62)
    header.BackgroundTransparency = 1
    header.Parent = window

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(18, 8)
    title.Size = UDim2.new(1, -120, 0, 26)
    title.Font = Enum.Font.GothamBold
    title.Text = self.Name
    title.TextColor3 = self.Settings.Text
    title.TextSize = 19
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    self.TitleLabel = title

    local subtitle = Instance.new("TextLabel")
    subtitle.BackgroundTransparency = 1
    subtitle.Position = UDim2.fromOffset(19, 34)
    subtitle.Size = UDim2.new(1, -140, 0, 18)
    subtitle.Font = Enum.Font.Gotham
    subtitle.Text = self.Subtitle
    subtitle.TextColor3 = self.Settings.MutedText
    subtitle.TextSize = 11
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = header

    --// Minimize
    local minimize = makeButton(header, "—")
    minimize.Position = UDim2.new(1, -82, 0, 15)
    minimize.Size = UDim2.fromOffset(30, 30)
    minimize.TextSize = 17
    self.MinimizeButton = minimize

    --// Close
    local close = makeButton(header, "×")
    close.Position = UDim2.new(1, -46, 0, 15)
    close.Size = UDim2.fromOffset(30, 30)
    close.TextSize = 18

    --// Search
    local search = Instance.new("TextBox")
    search.Name = "Search"
    search.PlaceholderText = "Search..."
    search.Text = ""
    search.ClearTextOnFocus = false
    search.BackgroundColor3 = Color3.fromRGB(24, 36, 62)
    search.BackgroundTransparency = 0.08
    search.TextColor3 = self.Settings.Text
    search.PlaceholderColor3 = self.Settings.MutedText
    search.Font = Enum.Font.Gotham
    search.TextSize = 12
    search.Position = UDim2.fromOffset(15, 69)
    search.Size = UDim2.new(1, -30, 0, 32)
    search.BorderSizePixel = 0
    search.Parent = window
    round(search, 8)
    stroke(search, self.Settings.Accent, 0.8, 1)
    self.SearchBox = search

    --// Body
    local body = Instance.new("Frame")
    body.Name = "Body"
    body.BackgroundTransparency = 1
    body.Position = UDim2.fromOffset(12, 108)
    body.Size = UDim2.new(1, -24, 1, -120)
    body.Parent = window

    --// Tab list
    local tabList = Instance.new("ScrollingFrame")
    tabList.Name = "Tabs"
    tabList.BackgroundColor3 = Color3.fromRGB(10, 19, 34)
    tabList.BackgroundTransparency = 0.35
    tabList.BorderSizePixel = 0
    tabList.Size = UDim2.new(0, 145, 1, 0)
    tabList.CanvasSize = UDim2.new()
    tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabList.ScrollBarThickness = 2
    tabList.ScrollBarImageColor3 = self.Settings.Accent
    tabList.Parent = body
    round(tabList, 10)
    padding(tabList, 8)

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = tabList

    self.TabList = tabList

    --// Content
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, 155, 0, 0)
    content.Size = UDim2.new(1, -155, 1, 0)
    content.Parent = body
    self.Content = content

    --// Search overlay
    local searchFrame = Instance.new("ScrollingFrame")
    searchFrame.Name = "SearchResults"
    searchFrame.Visible = false
    searchFrame.BackgroundColor3 = Color3.fromRGB(16, 27, 47)
    searchFrame.BackgroundTransparency = 0.03
    searchFrame.BorderSizePixel = 0
    searchFrame.Position = UDim2.fromOffset(155, 0)
    searchFrame.Size = UDim2.new(1, -155, 1, 0)
    searchFrame.ScrollBarThickness = 3
    searchFrame.CanvasSize = UDim2.new()
    searchFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    searchFrame.Parent = body
    round(searchFrame, 10)
    padding(searchFrame, 10)
    self.SearchFrame = searchFrame

    local searchLayout = Instance.new("UIListLayout")
    searchLayout.Padding = UDim.new(0, 6)
    searchLayout.Parent = searchFrame

    --// Floating reopen button
    local reopen = makeButton(gui, "◆")
    reopen.AnchorPoint = Vector2.new(0.5, 0.5)
    reopen.Position = UDim2.fromScale(0.5, 0.88)
    reopen.Size = UDim2.fromOffset(44, 44)
    reopen.Visible = false
    reopen.TextColor3 = self.Settings.Accent
    round(reopen, 14)
    stroke(reopen, self.Settings.Accent, 0.4, 1)
    self.ReopenButton = reopen

    --// Dragging
    local dragging = false
    local dragStart
    local startPos

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = root.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - dragStart
        root.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end)

    --// Small press animation
    local function pressEffect(button)
        if not self.Settings.Animations or not self.Settings.ButtonEffects then
            return
        end

        local original = button.Size
        tween(button,
            TweenInfo.new(0.07 / self.Settings.AnimationSpeed, Enum.EasingStyle.Quad),
            {Size = original - UDim2.fromOffset(2, 2)}
        )

        task.delay(0.07 / self.Settings.AnimationSpeed, function()
            if button.Parent then
                tween(button,
                    TweenInfo.new(0.13 / self.Settings.AnimationSpeed, Enum.EasingStyle.Back),
                    {Size = original}
                )
            end
        end)
    end

    self._pressEffect = pressEffect

    --// Minimize
    function self:SetMinimized(state)
        if self.Minimized == state then return end
        self.Minimized = state

        if not self.Settings.Animations or not self.Settings.WindowAnimations then
            window.Visible = not state
            reopen.Visible = state
            return
        end

        if state then
            tween(window,
                TweenInfo.new(0.2 / self.Settings.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                {Size = UDim2.fromScale(0.94, 0.94), BackgroundTransparency = 1}
            )

            task.delay(0.18 / self.Settings.AnimationSpeed, function()
                window.Visible = false
                reopen.Visible = true
            end)
        else
            reopen.Visible = false
            window.Visible = true
            window.Size = UDim2.fromScale(0.94, 0.94)
            window.BackgroundTransparency = 1

            tween(window,
                TweenInfo.new(0.24 / self.Settings.AnimationSpeed, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                {Size = UDim2.fromScale(1, 1), BackgroundTransparency = self.Settings.Transparency}
            )
        end
    end

    minimize.MouseButton1Click:Connect(function()
        pressEffect(minimize)
        self:SetMinimized(true)
    end)

    reopen.MouseButton1Click:Connect(function()
        pressEffect(reopen)
        self:SetMinimized(false)
    end)

    close.MouseButton1Click:Connect(function()
        pressEffect(close)
        self:SetVisible(false)
    end)

    --// UI keybind
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == self.Settings.UIKey then
            self:SetVisible(not self.Visible)
        end
    end)

    --// Search
    search:GetPropertyChangedSignal("Text"):Connect(function()
        self:_search(search.Text)
    end)

    --// Initial animation
    if self.Settings.Animations and self.Settings.WindowAnimations then
        window.Size = UDim2.fromScale(0.92, 0.92)
        window.BackgroundTransparency = 1

        tween(window,
            TweenInfo.new(0.28 / self.Settings.AnimationSpeed, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.fromScale(1, 1), BackgroundTransparency = self.Settings.Transparency}
        )
    end

    --// Automatic settings tab
    self:_createSettingsTab()

    return self
end

--// =========================================================
--// VISIBILITY
--// =========================================================

function Treasure:SetVisible(state)
    self.Visible = state

    if self.Minimized then
        self:SetMinimized(false)
    end

    if self.Settings.Animations and self.Settings.WindowAnimations then
        if state then
            self.Window.Visible = true
            self.Window.Size = UDim2.fromScale(0.94, 0.94)
            self.Window.BackgroundTransparency = 1

            tween(self.Window,
                TweenInfo.new(0.22 / self.Settings.AnimationSpeed, Enum.EasingStyle.Back),
                {Size = UDim2.fromScale(1, 1), BackgroundTransparency = self.Settings.Transparency}
            )
        else
            tween(self.Window,
                TweenInfo.new(0.16 / self.Settings.AnimationSpeed, Enum.EasingStyle.Quad),
                {Size = UDim2.fromScale(0.94, 0.94), BackgroundTransparency = 1}
            )

            task.delay(0.16 / self.Settings.AnimationSpeed, function()
                if not self.Visible then
                    self.Window.Visible = false
                end
            end)
        end
    else
        self.Window.Visible = state
    end
end

function Treasure:Toggle()
    self:SetVisible(not self.Visible)
end

--// =========================================================
--// TABS
--// =========================================================

function Treasure:CreateTab(name)
    local tab = {}
    tab.Name = name
    tab.Library = self
    tab.Controls = {}

    local button = makeButton(self.TabList, name)
    button.Size = UDim2.new(1, 0, 0, 34)
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.TextColor3 = self.Settings.MutedText

    local buttonPadding = Instance.new("UIPadding")
    buttonPadding.PaddingLeft = UDim.new(0, 11)
    buttonPadding.Parent = button

    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "_Page"
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Size = UDim2.fromScale(1, 1)
    page.Visible = false
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = self.Settings.Accent
    page.CanvasSize = UDim2.new()
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Parent = self.Content
    padding(page, 5)

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = page

    tab.Button = button
    tab.Page = page
    table.insert(self.Tabs, tab)

    local function activate()
        for _, other in ipairs(self.Tabs) do
            local selected = other == tab
            other.Page.Visible = selected

            tween(
                other.Button,
                TweenInfo.new(
                    self.Settings.TabAnimations and 0.14 / self.Settings.AnimationSpeed or 0,
                    Enum.EasingStyle.Quad
                ),
                {
                    BackgroundColor3 = selected
                        and Color3.fromRGB(48, 52, 100)
                        or Color3.fromRGB(34, 45, 72),
                    TextColor3 = selected
                        and self.Settings.Text
                        or self.Settings.MutedText
                }
            )
        end

        self.ActiveTab = tab
    end

    button.MouseButton1Click:Connect(function()
        self._pressEffect(button)
        activate()
    end)

    function tab:CreateSection(text)
        local section = Instance.new("TextLabel")
        section.BackgroundTransparency = 1
        section.Size = UDim2.new(1, 0, 0, 25)
        section.Font = Enum.Font.GothamBold
        section.Text = text
        section.TextColor3 = self.Library.Settings.Accent
        section.TextSize = 13
        section.TextXAlignment = Enum.TextXAlignment.Left
        section.Parent = self.Page
        return section
    end

    function tab:CreateLabel(text)
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 0, 28)
        label.Font = Enum.Font.Gotham
        label.Text = text
        label.TextColor3 = self.Library.Settings.MutedText
        label.TextSize = 12
        label.TextWrapped = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = self.Page

        local control = {
            Type = "Label",
            Name = text,
            Instance = label,
            Tab = self
        }

        table.insert(self.Library.Controls, control)
        table.insert(self.Controls, control)

        return control
    end

    function tab:CreateButton(cfg)
        cfg = cfg or {}

        local button = makeButton(self.Page, cfg.Name or "Button")
        button.Size = UDim2.new(1, 0, 0, 38)
        button.TextXAlignment = Enum.TextXAlignment.Left

        local p = Instance.new("UIPadding")
        p.PaddingLeft = UDim.new(0, 12)
        p.Parent = button

        button.MouseButton1Click:Connect(function()
            self.Library._pressEffect(button)
            if cfg.Callback then
                task.spawn(cfg.Callback)
            end
        end)

        local control = {
            Type = "Button",
            Name = cfg.Name or "Button",
            Instance = button,
            Tab = self
        }

        table.insert(self.Library.Controls, control)
        table.insert(self.Controls, control)

        return control
    end

    function tab:CreateToggle(cfg)
        cfg = cfg or {}

        local frame = Instance.new("Frame")
        frame.BackgroundColor3 = Color3.fromRGB(30, 41, 67)
        frame.BackgroundTransparency = 0.08
        frame.Size = UDim2.new(1, 0, 0, 42)
        frame.BorderSizePixel = 0
        frame.Parent = self.Page
        round(frame, 8)

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Position = UDim2.fromOffset(12, 0)
        label.Size = UDim2.new(1, -72, 1, 0)
        label.Font = Enum.Font.GothamMedium
        label.Text = cfg.Name or "Toggle"
        label.TextColor3 = self.Library.Settings.Text
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local switch = makeButton(frame, "")
        switch.AnchorPoint = Vector2.new(1, 0.5)
        switch.Position = UDim2.new(1, -10, 0.5, 0)
        switch.Size = UDim2.fromOffset(42, 22)
        round(switch, 11)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(16, 16)
        knob.Position = UDim2.fromOffset(3, 3)
        knob.BackgroundColor3 = Color3.fromRGB(225, 230, 255)
        knob.BorderSizePixel = 0
        knob.Parent = switch
        round(knob, 9)

        local value = cfg.CurrentValue == true

        local function setValue(newValue, fire)
            value = newValue == true

            local goalX = value and 23 or 3
            local bg = value and self.Library.Settings.Accent or Color3.fromRGB(55, 64, 88)

            tween(
                switch,
                TweenInfo.new(0.13 / self.Library.Settings.AnimationSpeed, Enum.EasingStyle.Quad),
                {BackgroundColor3 = bg}
            )

            tween(
                knob,
                TweenInfo.new(0.16 / self.Library.Settings.AnimationSpeed, Enum.EasingStyle.Back),
                {Position = UDim2.fromOffset(goalX, 3)}
            )

            if fire and cfg.Callback then
                task.spawn(cfg.Callback, value)
            end
        end

        switch.MouseButton1Click:Connect(function()
            self.Library._pressEffect(switch)
            setValue(not value, true)
        end)

        setValue(value, false)

        local control = {
            Type = "Toggle",
            Name = cfg.Name or "Toggle",
            Instance = frame,
            Tab = self,
            Get = function() return value end,
            Set = function(_, v) setValue(v, true) end
        }

        table.insert(self.Library.Controls, control)
        table.insert(self.Controls, control)

        return control
    end

    function tab:CreateSlider(cfg)
        cfg = cfg or {}

        local min = cfg.Min or 0
        local max = cfg.Max or 100
        local value = math.clamp(cfg.Default or min, min, max)

        local frame = Instance.new("Frame")
        frame.BackgroundTransparency = 1
        frame.Size = UDim2.new(1, 0, 0, 55)
        frame.Parent = self.Page

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, -65, 0, 22)
        label.Font = Enum.Font.GothamMedium
        label.Text = cfg.Name or "Slider"
        label.TextColor3 = self.Library.Settings.Text
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local valueLabel = label:Clone()
        valueLabel.Text = tostring(value)
        valueLabel.Position = UDim2.new(1, -60, 0, 0)
        valueLabel.Size = UDim2.fromOffset(60, 22)
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.TextColor3 = self.Library.Settings.Accent
        valueLabel.Parent = frame

        local bar = Instance.new("Frame")
        bar.BackgroundColor3 = Color3.fromRGB(48, 59, 84)
        bar.Position = UDim2.fromOffset(0, 31)
        bar.Size = UDim2.new(1, 0, 0, 7)
        bar.BorderSizePixel = 0
        bar.Parent = frame
        round(bar, 5)

        local fill = Instance.new("Frame")
        fill.BackgroundColor3 = self.Library.Settings.Accent
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BorderSizePixel = 0
        fill.Parent = bar
        round(fill, 5)

        local knob = Instance.new("Frame")
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Size = UDim2.fromOffset(15, 15)
        knob.BackgroundColor3 = Color3.fromRGB(230, 235, 255)
        knob.BorderSizePixel = 0
        knob.Parent = bar
        round(knob, 9)

        local draggingSlider = false

        local function setValue(v, fire)
            value = math.clamp(v, min, max)
            local alpha = (value - min) / math.max(max - min, 0.0001)

            tween(fill, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                Size = UDim2.new(alpha, 0, 1, 0)
            })

            tween(knob, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                Position = UDim2.new(alpha, 0, 0.5, 0)
            })

            valueLabel.Text = tostring(math.floor(value * 100) / 100)

            if fire and cfg.Callback then
                task.spawn(cfg.Callback, value)
            end
        end

        local function update(input)
            local x = math.clamp(
                input.Position.X - bar.AbsolutePosition.X,
                0,
                bar.AbsoluteSize.X
            )

            local alpha = x / math.max(bar.AbsoluteSize.X, 1)
            setValue(min + ((max - min) * alpha), true)
        end

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                draggingSlider = true
                update(input)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if draggingSlider and (
                input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch
            ) then
                update(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                draggingSlider = false
            end
        end)

        setValue(value, false)

        local control = {
            Type = "Slider",
            Name = cfg.Name or "Slider",
            Instance = frame,
            Tab = self,
            Get = function() return value end,
            Set = function(_, v) setValue(v, true) end
        }

        table.insert(self.Library.Controls, control)
        table.insert(self.Controls, control)

        return control
    end

    function tab:CreateDropdown(cfg)
        cfg = cfg or {}

        local options = cfg.Options or {}
        local current = cfg.CurrentOption or options[1] or "None"

        local holder = Instance.new("Frame")
        holder.BackgroundTransparency = 1
        holder.Size = UDim2.new(1, 0, 0, 38)
        holder.Parent = self.Page

        local button = makeButton(holder, tostring(current))
        button.Size = UDim2.fromScale(1, 1)
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.Parent = holder

        local p = Instance.new("UIPadding")
        p.PaddingLeft = UDim.new(0, 12)
        p.Parent = button

        local menu = Instance.new("Frame")
        menu.Visible = false
        menu.BackgroundColor3 = Color3.fromRGB(20, 31, 52)
        menu.BorderSizePixel = 0
        menu.Position = UDim2.new(0, 0, 1, 5)
        menu.Size = UDim2.new(1, 0, 0, math.min(#options * 31, 155))
        menu.ZIndex = 20
        menu.Parent = holder
        round(menu, 8)
        stroke(menu, self.Library.Settings.Accent, 0.7, 1)

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 3)
        list.Parent = menu

        local function rebuild()
            for _, child in ipairs(menu:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end

            for _, option in ipairs(options) do
                local item = makeButton(menu, tostring(option))
                item.Size = UDim2.new(1, -8, 0, 28)
                item.Position = UDim2.fromOffset(4, 0)
                item.ZIndex = 21

                item.MouseButton1Click:Connect(function()
                    current = option
                    button.Text = tostring(option)
                    menu.Visible = false
                    if cfg.Callback then
                        task.spawn(cfg.Callback, option)
                    end
                end)
            end
        end

        button.MouseButton1Click:Connect(function()
            self.Library._pressEffect(button)
            menu.Visible = not menu.Visible

            if menu.Visible and self.Library.Settings.Animations then
                menu.Size = UDim2.new(1, 0, 0, 0)
                tween(menu,
                    TweenInfo.new(0.16 / self.Library.Settings.AnimationSpeed, Enum.EasingStyle.Back),
                    {Size = UDim2.new(1, 0, 0, math.min(#options * 31, 155))}
                )
            end
        end)

        rebuild()

        local control = {
            Type = "Dropdown",
            Name = cfg.Name or "Dropdown",
            Instance = holder,
            Tab = self,
            Get = function() return current end,
            Set = function(_, v)
                for _, option in ipairs(options) do
                    if option == v then
                        current = v
                        button.Text = tostring(v)
                        if cfg.Callback then
                            task.spawn(cfg.Callback, v)
                        end
                        break
                    end
                end
            end
        }

        table.insert(self.Library.Controls, control)
        table.insert(self.Controls, control)

        return control
    end

    function tab:CreateTextbox(cfg)
        cfg = cfg or {}

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, 0, 0, 38)
        box.BackgroundColor3 = Color3.fromRGB(30, 41, 67)
        box.BackgroundTransparency = 0.08
        box.BorderSizePixel = 0
        box.ClearTextOnFocus = false
        box.PlaceholderText = cfg.PlaceholderText or "Type here..."
        box.PlaceholderColor3 = self.Library.Settings.MutedText
        box.Text = cfg.CurrentValue or ""
        box.TextColor3 = self.Library.Settings.Text
        box.Font = Enum.Font.Gotham
        box.TextSize = 12
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.Parent = self.Page
        round(box, 8)

        local p = Instance.new("UIPadding")
        p.PaddingLeft = UDim.new(0, 12)
        p.PaddingRight = UDim.new(0, 12)
        p.Parent = box

        box.FocusLost:Connect(function(enterPressed)
            if cfg.Callback then
                task.spawn(cfg.Callback, box.Text, enterPressed)
            end
        end)

        local control = {
            Type = "Textbox",
            Name = cfg.Name or "Textbox",
            Instance = box,
            Tab = self,
            Get = function() return box.Text end,
            Set = function(_, v)
                box.Text = tostring(v)
            end
        }

        table.insert(self.Library.Controls, control)
        table.insert(self.Controls, control)

        return control
    end

    function tab:CreateKeybind(cfg)
        cfg = cfg or {}

        local button = makeButton(self.Page, (cfg.Name or "Keybind") .. ": " .. tostring(cfg.Key or Enum.KeyCode.RightShift))
        button.Size = UDim2.new(1, 0, 0, 38)
        button.TextXAlignment = Enum.TextXAlignment.Left

        local p = Instance.new("UIPadding")
        p.PaddingLeft = UDim.new(0, 12)
        p.Parent = button

        local key = cfg.Key or Enum.KeyCode.RightShift
        local listening = false

        button.MouseButton1Click:Connect(function()
            listening = true
            button.Text = (cfg.Name or "Keybind") .. ": ..."

            local connection
            connection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    key = input.KeyCode
                    listening = false
                    button.Text = (cfg.Name or "Keybind") .. ": " .. tostring(key)
                    connection:Disconnect()
                end
            end)
        end)

        UserInputService.InputBegan:Connect(function(input, processed)
            if processed or listening then return end
            if input.KeyCode == key and cfg.Callback then
                task.spawn(cfg.Callback)
            end
        end)

        local control = {
            Type = "Keybind",
            Name = cfg.Name or "Keybind",
            Instance = button,
            Tab = self,
            Get = function() return key end,
            Set = function(_, v)
                if typeof(v) == "EnumItem" then
                    key = v
                    button.Text = (cfg.Name or "Keybind") .. ": " .. tostring(key)
                end
            end
        }

        table.insert(self.Library.Controls, control)
        table.insert(self.Controls, control)

        return control
    end

    function tab:CreateColorPicker(cfg)
        cfg = cfg or {}

        local color = cfg.Default or self.Library.Settings.Accent

        local holder = Instance.new("Frame")
        holder.BackgroundTransparency = 1
        holder.Size = UDim2.new(1, 0, 0, 38)
        holder.Parent = self.Page

        local button = makeButton(holder, cfg.Name or "Color")
        button.Size = UDim2.fromScale(1, 1)
        button.TextXAlignment = Enum.TextXAlignment.Left

        local p = Instance.new("UIPadding")
        p.PaddingLeft = UDim.new(0, 12)
        p.Parent = button

        local swatch = Instance.new("Frame")
        swatch.AnchorPoint = Vector2.new(1, 0.5)
        swatch.Position = UDim2.new(1, -10, 0.5, 0)
        swatch.Size = UDim2.fromOffset(26, 20)
        swatch.BackgroundColor3 = color
        swatch.BorderSizePixel = 0
        swatch.Parent = button
        round(swatch, 6)

        -- Simple RGB editor, intentionally compact.
        local editor = Instance.new("Frame")
        editor.Visible = false
        editor.BackgroundColor3 = Color3.fromRGB(20, 31, 52)
        editor.Position = UDim2.new(0, 0, 1, 5)
        editor.Size = UDim2.new(1, 0, 0, 94)
        editor.ZIndex = 30
        editor.Parent = holder
        round(editor, 8)
        stroke(editor, self.Library.Settings.Accent, 0.7, 1)

        local function addChannel(name, y, getter, setter)
            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1, -16, 0, 24)
            box.Position = UDim2.fromOffset(8, y)
            box.BackgroundColor3 = Color3.fromRGB(32, 44, 70)
            box.BorderSizePixel = 0
            box.Text = name .. ": " .. tostring(math.floor(getter() * 255))
            box.TextColor3 = self.Library.Settings.Text
            box.Font = Enum.Font.Gotham
            box.TextSize = 11
            box.ClearTextOnFocus = false
            box.ZIndex = 31
            box.Parent = editor
            round(box, 6)

            box.FocusLost:Connect(function()
                local n = tonumber(box.Text:match("(%d+)"))
                if n then
                    setter(math.clamp(n, 0, 255) / 255)
                    swatch.BackgroundColor3 = color
                    if cfg.Callback then
                        task.spawn(cfg.Callback, color)
                    end
                end
            end)
        end

        local r, g, b = color.R, color.G, color.B

        addChannel("R", 6, function() return r end, function(v)
            r = v
            color = Color3.new(r, g, b)
        end)

        addChannel("G", 34, function() return g end, function(v)
            g = v
            color = Color3.new(r, g, b)
        end)

        addChannel("B", 62, function() return b end, function(v)
            b = v
            color = Color3.new(r, g, b)
        end)

        button.MouseButton1Click:Connect(function()
            self.Library._pressEffect(button)
            editor.Visible = not editor.Visible
        end)

        local control = {
            Type = "ColorPicker",
            Name = cfg.Name or "Color",
            Instance = holder,
            Tab = self,
            Get = function() return color end,
            Set = function(_, v)
                if typeof(v) == "Color3" then
                    color = v
                    swatch.BackgroundColor3 = v
                    if cfg.Callback then
                        task.spawn(cfg.Callback, v)
                    end
                end
            end
        }

        table.insert(self.Library.Controls, control)
        table.insert(self.Controls, control)

        return control
    end

    if not self.ActiveTab then
        activate()
    end

    return tab
end

--// =========================================================
--// SEARCH
--// =========================================================

function Treasure:_search(query)
    query = string.lower(query or "")

    if query == "" then
        self.SearchFrame.Visible = false
        self.Content.Visible = true
        return
    end

    self.Content.Visible = false
    self.SearchFrame.Visible = true

    for _, child in ipairs(self.SearchFrame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    for _, control in ipairs(self.Controls) do
        if string.find(string.lower(control.Name), query, 1, true) then
            local result = makeButton(self.SearchFrame, control.Name .. "  •  " .. control.Type)
            result.Size = UDim2.new(1, 0, 0, 34)

            result.MouseButton1Click:Connect(function()
                if control.Tab then
                    control.Tab.Button:Activate()
                end
            end)
        end
    end
end

--// =========================================================
--// SETTINGS TAB
--// =========================================================

function Treasure:_createSettingsTab()
    local tab = self:CreateTab("Settings")

    tab:CreateSection("Interface")

    tab:CreateSlider({
        Name = "UI Scale",
        Min = 50,
        Max = 125,
        Default = math.floor(self.Scale * 100),
        Callback = function(value)
            self.UIScale.Scale = value / 100
            self.Scale = value / 100
        end
    })

    tab:CreateSlider({
        Name = "Transparency",
        Min = 10,
        Max = 80,
        Default = math.floor(self.Settings.Transparency * 100),
        Callback = function(value)
            self.Settings.Transparency = value / 100
            self.Window.BackgroundTransparency = self.Settings.Transparency
        end
    })

    tab:CreateToggle({
        Name = "Animations",
        CurrentValue = self.Settings.Animations,
        Callback = function(v)
            self.Settings.Animations = v
        end
    })

    tab:CreateToggle({
        Name = "Button Effects",
        CurrentValue = self.Settings.ButtonEffects,
        Callback = function(v)
            self.Settings.ButtonEffects = v
        end
    })

    tab:CreateSlider({
        Name = "Animation Speed",
        Min = 50,
        Max = 200,
        Default = math.floor(self.Settings.AnimationSpeed * 100),
        Callback = function(v)
            self.Settings.AnimationSpeed = v / 100
        end
    })

    tab:CreateSection("Appearance")

    tab:CreateDropdown({
        Name = "Theme",
        Options = {"Blue", "Purple", "Cyan", "Red", "Green"},
        CurrentOption = "Purple",
        Callback = function(theme)
            local colors = {
                Blue = Color3.fromRGB(90, 145, 255),
                Purple = Color3.fromRGB(125, 95, 255),
                Cyan = Color3.fromRGB(60, 220, 220),
                Red = Color3.fromRGB(240, 80, 100),
                Green = Color3.fromRGB(80, 220, 140)
            }

            self.Settings.Accent = colors[theme] or self.Settings.Accent

            for _, obj in ipairs(self.Gui:GetDescendants()) do
                if obj:IsA("UIStroke") then
                    obj.Color = self.Settings.Accent
                elseif obj:IsA("TextLabel") and obj.TextColor3 == self.Settings.Accent then
                    obj.TextColor3 = self.Settings.Accent
                end
            end
        end
    })

    tab:CreateColorPicker({
        Name = "Accent Color",
        Default = self.Settings.Accent,
        Callback = function(color)
            self.Settings.Accent = color
        end
    })

    tab:CreateSection("Window")

    tab:CreateKeybind({
        Name = "Toggle UI",
        Key = self.Settings.UIKey,
        Callback = function()
            self:Toggle()
        end
    })

    tab:CreateToggle({
        Name = "Notifications",
        CurrentValue = self.Settings.Notifications,
        Callback = function(v)
            self.Settings.Notifications = v
        end
    })

    tab:CreateToggle({
        Name = "Watermark",
        CurrentValue = self.Settings.Watermark,
        Callback = function(v)
            self.Settings.Watermark = v
            self:_setWatermark(v)
        end
    })

    tab:CreateSection("Extra")

    tab:CreateButton({
        Name = "Reset UI Position",
        Callback = function()
            self.Root.Position = UDim2.fromScale(0.5, 0.5)
        end
    })

    tab:CreateButton({
        Name = "Reset Treasure Settings",
        Callback = function()
            self.Settings = cloneDefaults()
            self.UIScale.Scale = getScale()
            self.Window.BackgroundTransparency = self.Settings.Transparency
            self:Notify({
                Title = "Treasure",
                Content = "Settings reset.",
                Duration = 2
            })
        end
    })

    -- Make Settings the first visible tab.
    if tab.Button then
        tab.Button:Activate()
    end
end

--// =========================================================
--// WATERMARK
--// =========================================================

function Treasure:_setWatermark(enabled)
    if enabled then
        if self.Watermark then return end

        local label = Instance.new("TextLabel")
        label.Name = "Watermark"
        label.AnchorPoint = Vector2.new(1, 0)
        label.Position = UDim2.new(1, -12, 0, 12)
        label.Size = UDim2.fromOffset(150, 24)
        label.BackgroundColor3 = self.Settings.Background
        label.BackgroundTransparency = 0.2
        label.BorderSizePixel = 0
        label.Text = "TREASURE • " .. self.Name
        label.TextColor3 = self.Settings.Accent
        label.Font = Enum.Font.GothamBold
        label.TextSize = 10
        label.Parent = self.Gui
        round(label, 7)

        self.Watermark = label
    elseif self.Watermark then
        self.Watermark:Destroy()
        self.Watermark = nil
    end
end

--// =========================================================
--// NOTIFICATIONS
--// =========================================================

function Treasure:Notify(cfg)
    cfg = cfg or {}

    if self.Settings and not self.Settings.Notifications then
        return
    end

    if not self.NotificationHolder then
        local holder = Instance.new("Frame")
        holder.Name = "Notifications"
        holder.AnchorPoint = Vector2.new(1, 1)
        holder.Position = UDim2.new(1, -15, 1, -15)
        holder.Size = UDim2.fromOffset(300, 320)
        holder.BackgroundTransparency = 1
        holder.Parent = self.Gui

        local layout = Instance.new("UIListLayout")
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        layout.Padding = UDim.new(0, 7)
        layout.Parent = holder

        self.NotificationHolder = holder
    end

    local note = Instance.new("Frame")
    note.Size = UDim2.new(1, 0, 0, 64)
    note.BackgroundColor3 = self.Settings.Background
    note.BackgroundTransparency = 0.08
    note.BorderSizePixel = 0
    note.Parent = self.NotificationHolder
    round(note, 10)
    stroke(note, self.Settings.Accent, 0.65, 1)

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(12, 8)
    title.Size = UDim2.new(1, -24, 0, 20)
    title.Font = Enum.Font.GothamBold
    title.Text = cfg.Title or "Treasure"
    title.TextColor3 = self.Settings.Accent
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = note

    local content = Instance.new("TextLabel")
    content.BackgroundTransparency = 1
    content.Position = UDim2.fromOffset(12, 29)
    content.Size = UDim2.new(1, -24, 0, 27)
    content.Font = Enum.Font.Gotham
    content.Text = cfg.Content or ""
    content.TextColor3 = self.Settings.Text
    content.TextSize = 11
    content.TextWrapped = true
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.Parent = note

    if self.Settings.Animations and self.Settings.NotificationAnimations then
        note.Position = UDim2.new(1, 25, 0, 0)
        tween(note,
            TweenInfo.new(0.22 / self.Settings.AnimationSpeed, Enum.EasingStyle.Back),
            {Position = UDim2.new(0, 0, 0, 0)}
        )
    end

    task.delay(cfg.Duration or 3, function()
        if not note.Parent then return end

        if self.Settings.Animations and self.Settings.NotificationAnimations then
            tween(note,
                TweenInfo.new(0.18 / self.Settings.AnimationSpeed, Enum.EasingStyle.Quad),
                {Position = UDim2.new(1, 25, 0, 0), BackgroundTransparency = 1}
            )
            task.wait(0.2 / self.Settings.AnimationSpeed)
        end

        if note.Parent then
            note:Destroy()
        end
    end)
end

--// =========================================================
--// CLEANUP
--// =========================================================

function Treasure:Destroy()
    for k, v in pairs(self.Settings) do
        sessionSettings[k] = v
    end

    if self.Gui then
        self.Gui:Destroy()
    end
end

return Treasure
