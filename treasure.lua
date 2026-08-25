--==================================================
-- TREASURE UI LIBRARY
-- V2
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Treasure = {}

--==================================================
-- DEVICE DETECTION
--==================================================

local IsMobile =
    UserInputService.TouchEnabled
    and not UserInputService.KeyboardEnabled

--==================================================
-- COLORS
--==================================================

local COLORS = {
    Window = Color3.fromRGB(235, 240, 255),
    Background = Color3.fromRGB(220, 225, 245),

    Tab = Color3.fromRGB(150, 155, 180),
    TabSelected = Color3.fromRGB(125, 105, 180),

    Accent = Color3.fromRGB(115, 95, 180),
    AccentLight = Color3.fromRGB(155, 140, 215),

    Text = Color3.fromRGB(25, 25, 35),
    SubText = Color3.fromRGB(80, 80, 100),

    White = Color3.fromRGB(255, 255, 255),
}

--==================================================
-- UTILITIES
--==================================================

local function Corner(parent, radius)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent

    return corner
end

local function MakeText(parent, text, size, bold)

    local label = Instance.new("TextLabel")

    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = COLORS.Text
    label.TextSize = size or 16
    label.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left

    label.Parent = parent

    return label
end

--==================================================
-- WINDOW
--==================================================

function Treasure:CreateWindow(options)

    options = options or {}

    local WindowName = options.Name or "Treasure"

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TreasureUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = PlayerGui

    --==================================================
    -- WINDOW
    --==================================================

    local Window = Instance.new("Frame")

    Window.Name = "Window"
    Window.Size = UDim2.fromOffset(650, 420)

    Window.AnchorPoint = Vector2.new(0.5, 0.5)
    Window.Position = UDim2.fromScale(0.5, 0.5)

    Window.BackgroundColor3 = COLORS.Window
    Window.BackgroundTransparency = 0.35
    Window.BorderSizePixel = 0

    Window.Parent = ScreenGui

    Corner(Window, 12)

    --==================================================
    -- DEVICE SCALE
    --==================================================

    local DeviceScale = Instance.new("UIScale")
    DeviceScale.Name = "DeviceScale"

    if IsMobile then
        DeviceScale.Scale = 1 / 1.6
    else
        DeviceScale.Scale = 1
    end

    DeviceScale.Parent = Window

    --==================================================
    -- TOP BAR
    --==================================================

    local TopBar = Instance.new("Frame")

    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = Window

    local Title = MakeText(
        TopBar,
        WindowName,
        24,
        true
    )

    Title.Position = UDim2.fromOffset(18, 0)
    Title.Size = UDim2.new(1, -100, 1, 0)

    --==================================================
    -- MINIMIZE
    --==================================================

    local Minimize = Instance.new("TextButton")

    Minimize.Size = UDim2.fromOffset(40, 40)
    Minimize.Position = UDim2.new(1, -85, 0, 5)

    Minimize.BackgroundTransparency = 1
    Minimize.Text = "—"
    Minimize.TextSize = 26
    Minimize.Font = Enum.Font.GothamBold
    Minimize.TextColor3 = COLORS.Text

    Minimize.Parent = TopBar

    --==================================================
    -- CLOSE
    --==================================================

    local Close = Instance.new("TextButton")

    Close.Size = UDim2.fromOffset(40, 40)
    Close.Position = UDim2.new(1, -45, 0, 5)

    Close.BackgroundTransparency = 1
    Close.Text = "×"
    Close.TextSize = 30
    Close.Font = Enum.Font.GothamBold
    Close.TextColor3 = COLORS.Text

    Close.Parent = TopBar

    --==================================================
    -- CONTENT
    --==================================================

    local Content = Instance.new("Frame")

    Content.Size = UDim2.new(1, -20, 1, -60)
    Content.Position = UDim2.fromOffset(10, 50)

    Content.BackgroundTransparency = 1
    Content.Parent = Window

    --==================================================
    -- TAB BAR
    --==================================================

    local TabBar = Instance.new("Frame")

    TabBar.Size = UDim2.fromOffset(125, 1)
    TabBar.BackgroundTransparency = 1

    TabBar.Parent = Content

    local TabLayout = Instance.new("UIListLayout")

    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    TabLayout.Parent = TabBar

    --==================================================
    -- PAGE HOLDER
    --==================================================

    local PageHolder = Instance.new("Frame")

    PageHolder.Size = UDim2.new(1, -135, 1, 0)
    PageHolder.Position = UDim2.fromOffset(135, 0)

    PageHolder.BackgroundColor3 = COLORS.Background
    PageHolder.BackgroundTransparency = 0.25
    PageHolder.BorderSizePixel = 0

    PageHolder.Parent = Content

    Corner(PageHolder, 10)

    --==================================================
    -- DRAGGING
    --==================================================

    local dragging = false
    local dragStart
    local startPosition

    TopBar.InputBegan:Connect(function(input)

        if
            input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then

            dragging = true
            dragStart = input.Position
            startPosition = Window.Position

        end

    end)

    UserInputService.InputChanged:Connect(function(input)

        if not dragging then
            return
        end

        if
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        then

            local delta = input.Position - dragStart

            local scale = DeviceScale.Scale

            Window.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X / scale,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y / scale
            )

        end

    end)

    UserInputService.InputEnded:Connect(function(input)

        if
            input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then

            dragging = false

        end

    end)

    --==================================================
    -- MINIMIZE
    --==================================================

    local minimized = false
    local OldSize = Window.Size

    Minimize.MouseButton1Click:Connect(function()

        minimized = not minimized

        if minimized then

            OldSize = Window.Size

            Window.Size = UDim2.fromOffset(650, 50)
            Content.Visible = false

        else

            Window.Size = OldSize
            Content.Visible = true

        end

    end)

    --==================================================
    -- CLOSE
    --==================================================

    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    --==================================================
    -- WINDOW OBJECT
    --==================================================

    local WindowObject = {}

    local CurrentTab

    --==================================================
    -- CREATE TAB
    --==================================================

    function WindowObject:CreateTab(tabName)

        local TabButton = Instance.new("TextButton")

        TabButton.Name = tabName
        TabButton.Size = UDim2.new(1, 0, 0, 42)

        TabButton.BackgroundColor3 = COLORS.Tab
        TabButton.BackgroundTransparency = 0.35
        TabButton.BorderSizePixel = 0

        TabButton.Text = tabName
        TabButton.TextColor3 = COLORS.Text
        TabButton.TextSize = 16
        TabButton.Font = Enum.Font.GothamBold

        TabButton.Parent = TabBar

        Corner(TabButton, 8)

        --==================================================
        -- PAGE
        --==================================================

        local Page = Instance.new("ScrollingFrame")

        Page.Name = tabName .. "_Page"

        Page.Size = UDim2.new(1, -20, 1, -20)
        Page.Position = UDim2.fromOffset(10, 10)

        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0

        Page.ScrollBarThickness = 4
        Page.Visible = false

        Page.CanvasSize = UDim2.new(0, 0, 0, 0)

        Page.Parent = PageHolder

        local Layout = Instance.new("UIListLayout")

        Layout.Padding = UDim.new(0, 10)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder

        Layout.Parent = Page

        Layout:GetPropertyChangedSignal(
            "AbsoluteContentSize"
        ):Connect(function()

            Page.CanvasSize = UDim2.new(
                0,
                0,
                0,
                Layout.AbsoluteContentSize.Y + 15
            )

        end)

        local TabObject = {}

        --==================================================
        -- SELECT TAB
        --==================================================

        TabButton.MouseButton1Click:Connect(function()

            if CurrentTab then

                CurrentTab.Page.Visible = false
                CurrentTab.Button.BackgroundColor3 = COLORS.Tab

            end

            Page.Visible = true
            TabButton.BackgroundColor3 = COLORS.TabSelected

            CurrentTab = {
                Page = Page,
                Button = TabButton
            }

        end)

        --==================================================
        -- SECTION
        --==================================================

        function TabObject:CreateSection(text)

            local Section = MakeText(
                Page,
                text,
                17,
                true
            )

            Section.Size = UDim2.new(1, 0, 0, 30)

            return Section
        end

        --==================================================
        -- LABEL
        --==================================================

        function TabObject:CreateLabel(text)

            local Label = MakeText(
                Page,
                text,
                14,
                false
            )

            Label.Size = UDim2.new(1, 0, 0, 28)

            return Label
        end

        --==================================================
        -- BUTTON
        --==================================================

        function TabObject:CreateButton(options)

            options = options or {}

            local Button = Instance.new("TextButton")

            Button.Size = UDim2.new(1, 0, 0, 42)

            Button.BackgroundColor3 = COLORS.Accent
            Button.BackgroundTransparency = 0.35
            Button.BorderSizePixel = 0

            Button.Text = options.Name or "Button"
            Button.TextColor3 = COLORS.White
            Button.TextSize = 15
            Button.Font = Enum.Font.GothamBold

            Button.Parent = Page

            Corner(Button, 8)

            Button.MouseButton1Click:Connect(function()

                if options.Callback then
                    options.Callback()
                end

            end)

            return Button
        end

        --==================================================
        -- TOGGLE
        --==================================================

        function TabObject:CreateToggle(options)

            options = options or {}

            local Enabled = options.CurrentValue or false

            local Button = Instance.new("TextButton")

            Button.Size = UDim2.new(1, 0, 0, 42)

            Button.BackgroundColor3 = COLORS.Accent
            Button.BackgroundTransparency = 0.45
            Button.BorderSizePixel = 0

            Button.Text = ""
            Button.Parent = Page

            Corner(Button, 8)

            local Text = MakeText(
                Button,
                options.Name or "Toggle",
                15,
                true
            )

            Text.Position = UDim2.fromOffset(12, 0)
            Text.Size = UDim2.new(1, -70, 1, 0)
            Text.TextColor3 = COLORS.White

            local State = MakeText(
                Button,
                Enabled and "ON" or "OFF",
                13,
                true
            )

            State.Position = UDim2.new(1, -55, 0, 0)
            State.Size = UDim2.fromOffset(45, 42)

            State.TextXAlignment = Enum.TextXAlignment.Center
            State.TextColor3 = COLORS.White

            local ToggleObject = {}

            function ToggleObject:Set(value)

                Enabled = value

                State.Text = Enabled and "ON" or "OFF"

                if options.Callback then
                    options.Callback(Enabled)
                end

            end

            Button.MouseButton1Click:Connect(function()

                ToggleObject:Set(not Enabled)

            end)

            return ToggleObject
        end

        --==================================================
        -- SLIDER
        --==================================================

        function TabObject:CreateSlider(options)

            options = options or {}

            local Min = options.Min or 0
            local Max = options.Max or 100
            local Value = options.Default or Min

            local Holder = Instance.new("Frame")

            Holder.Size = UDim2.new(1, 0, 0, 65)

            Holder.BackgroundColor3 = COLORS.Accent
            Holder.BackgroundTransparency = 0.45
            Holder.BorderSizePixel = 0

            Holder.Parent = Page

            Corner(Holder, 8)

            local Name = MakeText(
                Holder,
                options.Name or "Slider",
                14,
                true
            )

            Name.Position = UDim2.fromOffset(12, 5)
            Name.Size = UDim2.new(1, -80, 0, 25)
            Name.TextColor3 = COLORS.White

            local ValueLabel = MakeText(
                Holder,
                tostring(Value),
                14,
                true
            )

            ValueLabel.Position = UDim2.new(1, -60, 0, 5)
            ValueLabel.Size = UDim2.fromOffset(50, 25)

            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.TextColor3 = COLORS.White

            local Bar = Instance.new("Frame")

            Bar.Size = UDim2.new(1, -24, 0, 8)
            Bar.Position = UDim2.fromOffset(12, 43)

            Bar.BackgroundColor3 = Color3.fromRGB(190, 190, 210)
            Bar.BorderSizePixel = 0

            Bar.Parent = Holder

            Corner(Bar, 5)

            local Fill = Instance.new("Frame")

            Fill.Size = UDim2.new(
                (Value - Min) / (Max - Min),
                0,
                1,
                0
            )

            Fill.BackgroundColor3 = COLORS.AccentLight
            Fill.BorderSizePixel = 0

            Fill.Parent = Bar

            Corner(Fill, 5)

            local SliderDragging = false

            local function SetFromX(x)

                local Percentage = math.clamp(
                    (x - Bar.AbsolutePosition.X)
                    / Bar.AbsoluteSize.X,
                    0,
                    1
                )

                Value = math.floor(
                    Min + ((Max - Min) * Percentage)
                )

                Fill.Size = UDim2.new(
                    Percentage,
                    0,
                    1,
                    0
                )

                ValueLabel.Text = tostring(Value)

                if options.Callback then
                    options.Callback(Value)
                end

            end

            Bar.InputBegan:Connect(function(input)

                if
                    input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch
                then

                    SliderDragging = true

                    SetFromX(input.Position.X)

                end

            end)

            UserInputService.InputChanged:Connect(function(input)

                if not SliderDragging then
                    return
                end

                if
                    input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch
                then

                    SetFromX(input.Position.X)

                end

            end)

            UserInputService.InputEnded:Connect(function(input)

                if
                    input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch
                then

                    SliderDragging = false

                end

            end)

            local SliderObject = {}

            function SliderObject:Set(newValue)

                Value = math.clamp(
                    newValue,
                    Min,
                    Max
                )

                local Percentage =
                    (Value - Min) / (Max - Min)

                Fill.Size = UDim2.new(
                    Percentage,
                    0,
                    1,
                    0
                )

                ValueLabel.Text = tostring(Value)

                if options.Callback then
                    options.Callback(Value)
                end

            end

            return SliderObject
        end

        --==================================================
        -- DROPDOWN
        --==================================================

        function TabObject:CreateDropdown(options)

            options = options or {}

            local Choices = options.Options or {}
            local Current = options.CurrentOption or Choices[1]

            local Holder = Instance.new("Frame")

            Holder.Size = UDim2.new(1, 0, 0, 42)

            Holder.BackgroundColor3 = COLORS.Accent
            Holder.BackgroundTransparency = 0.35
            Holder.BorderSizePixel = 0

            Holder.ClipsDescendants = true
            Holder.Parent = Page

            Corner(Holder, 8)

            local MainButton = Instance.new("TextButton")

            MainButton.Size = UDim2.new(1, 0, 0, 42)

            MainButton.BackgroundTransparency = 1
            MainButton.Text = ""

            MainButton.Parent = Holder

            local Name = MakeText(
                MainButton,
                options.Name or "Dropdown",
                15,
                true
            )

            Name.Position = UDim2.fromOffset(12, 0)
            Name.Size = UDim2.new(0.5, 0, 1, 0)
            Name.TextColor3 = COLORS.White

            local Selected = MakeText(
                MainButton,
                tostring(Current or "None"),
                14,
                false
            )

            Selected.Position = UDim2.new(0.5, 0, 0, 0)
            Selected.Size = UDim2.new(0.5, -12, 1, 0)

            Selected.TextXAlignment = Enum.TextXAlignment.Right
            Selected.TextColor3 = COLORS.White

            local Open = false

            local OptionsFrame = Instance.new("Frame")

            OptionsFrame.Position = UDim2.fromOffset(8, 45)
            OptionsFrame.Size = UDim2.new(1, -16, 0, 0)

            OptionsFrame.BackgroundColor3 = COLORS.Background
            OptionsFrame.BackgroundTransparency = 0.1
            OptionsFrame.BorderSizePixel = 0

            OptionsFrame.Parent = Holder

            Corner(OptionsFrame, 6)

            local OptionLayout = Instance.new("UIListLayout")

            OptionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            OptionLayout.Padding = UDim.new(0, 3)

            OptionLayout.Parent = OptionsFrame

            local function Refresh()

                for _, child in ipairs(OptionsFrame:GetChildren()) do

                    if child:IsA("TextButton") then
                        child:Destroy()
                    end

                end

                for _, Choice in ipairs(Choices) do

                    local OptionButton = Instance.new("TextButton")

                    OptionButton.Size = UDim2.new(1, 0, 0, 34)

                    OptionButton.BackgroundColor3 = COLORS.Accent
                    OptionButton.BackgroundTransparency = 0.3
                    OptionButton.BorderSizePixel = 0

                    OptionButton.Text = tostring(Choice)
                    OptionButton.TextColor3 = COLORS.White
                    OptionButton.TextSize = 14
                    OptionButton.Font = Enum.Font.Gotham

                    OptionButton.Parent = OptionsFrame

                    Corner(OptionButton, 5)

                    OptionButton.MouseButton1Click:Connect(function()

                        Current = Choice
                        Selected.Text = tostring(Current)

                        Open = false

                        local height = 0

                        Holder.Size = UDim2.new(
                            1,
                            0,
                            0,
                            42
                        )

                        OptionsFrame.Size = UDim2.new(
                            1,
                            -16,
                            0,
                            height
                        )

                        if options.Callback then
                            options.Callback(Current)
                        end

                    end)

                end

            end

            MainButton.MouseButton1Click:Connect(function()

                Open = not Open

                if Open then

                    local height =
                        (#Choices * 34)
                        + ((#Choices - 1) * 3)

                    Holder.Size = UDim2.new(
                        1,
                        0,
                        0,
                        50 + height
                    )

                    OptionsFrame.Size = UDim2.new(
                        1,
                        -16,
                        0,
                        height
                    )

                else

                    Holder.Size = UDim2.new(
                        1,
                        0,
                        0,
                        42
                    )

                    OptionsFrame.Size = UDim2.new(
                        1,
                        -16,
                        0,
                        0
                    )

                end

            end)

            Refresh()

            local DropdownObject = {}

            function DropdownObject:Set(value)

                for _, Choice in ipairs(Choices) do

                    if Choice == value then

                        Current = value
                        Selected.Text = tostring(value)

                        if options.Callback then
                            options.Callback(value)
                        end

                        break

                    end

                end

            end

            function DropdownObject:Refresh(newChoices)

                Choices = newChoices or Choices
                Refresh()

            end

            return DropdownObject
        end

        return TabObject

    end

    --==================================================
    -- RETURN
    --==================================================

    return WindowObject
end

return Treasure
