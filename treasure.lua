--[[
    TREASURE UI
    V1 - LocalScript
    Put this in StarterPlayerScripts

    Controls:
    - Button
    - Toggle
    - Slider
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--------------------------------------------------
-- TREASURE
--------------------------------------------------

local Treasure = {}

--------------------------------------------------
-- COLORS
--------------------------------------------------

local COLORS = {
    Window = Color3.fromRGB(235, 240, 255),
    Tab = Color3.fromRGB(150, 155, 180),
    TabSelected = Color3.fromRGB(125, 105, 180),

    Text = Color3.fromRGB(25, 25, 35),
    SubText = Color3.fromRGB(80, 80, 100),

    Accent = Color3.fromRGB(115, 95, 180),
    AccentLight = Color3.fromRGB(155, 140, 215),

    Background = Color3.fromRGB(220, 225, 245),
    Slider = Color3.fromRGB(120, 100, 185),
}

--------------------------------------------------
-- UTILITY
--------------------------------------------------

local function Corner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function Padding(parent, amount)
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, amount)
    padding.PaddingRight = UDim.new(0, amount)
    padding.PaddingTop = UDim.new(0, amount)
    padding.PaddingBottom = UDim.new(0, amount)
    padding.Parent = parent
    return padding
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

--------------------------------------------------
-- CREATE WINDOW
--------------------------------------------------

function Treasure:CreateWindow(options)

    options = options or {}

    local windowName = options.Name or "Treasure"

    --------------------------------------------------
    -- SCREEN GUI
    --------------------------------------------------

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TreasureUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = PlayerGui

    --------------------------------------------------
    -- MAIN WINDOW
    --------------------------------------------------

    local Window = Instance.new("Frame")
    Window.Name = "Window"
    Window.Size = UDim2.fromOffset(650, 420)
    Window.Position = UDim2.new(0.5, -325, 0.5, -210)
    Window.BackgroundColor3 = COLORS.Window
    Window.BackgroundTransparency = 0.35
    Window.BorderSizePixel = 0
    Window.Parent = ScreenGui

    Corner(Window, 12)

    --------------------------------------------------
    -- TOP BAR
    --------------------------------------------------

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = Window

    local Title = MakeText(
        TopBar,
        windowName,
        24,
        true
    )

    Title.Position = UDim2.fromOffset(18, 0)
    Title.Size = UDim2.new(1, -100, 1, 0)

    --------------------------------------------------
    -- MINIMIZE
    --------------------------------------------------

    local Minimize = Instance.new("TextButton")
    Minimize.Name = "Minimize"
    Minimize.Size = UDim2.fromOffset(40, 40)
    Minimize.Position = UDim2.new(1, -85, 0, 5)
    Minimize.BackgroundTransparency = 1
    Minimize.Text = "—"
    Minimize.TextSize = 26
    Minimize.Font = Enum.Font.GothamBold
    Minimize.TextColor3 = COLORS.Text
    Minimize.Parent = TopBar

    --------------------------------------------------
    -- CLOSE
    --------------------------------------------------

    local Close = Instance.new("TextButton")
    Close.Name = "Close"
    Close.Size = UDim2.fromOffset(40, 40)
    Close.Position = UDim2.new(1, -45, 0, 5)
    Close.BackgroundTransparency = 1
    Close.Text = "×"
    Close.TextSize = 30
    Close.Font = Enum.Font.GothamBold
    Close.TextColor3 = COLORS.Text
    Close.Parent = TopBar

    --------------------------------------------------
    -- CONTENT
    --------------------------------------------------

    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -20, 1, -60)
    Content.Position = UDim2.fromOffset(10, 50)
    Content.BackgroundTransparency = 1
    Content.Parent = Window

    --------------------------------------------------
    -- TAB BAR
    --------------------------------------------------

    local TabBar = Instance.new("Frame")
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.fromOffset(125, 1)
    TabBar.Position = UDim2.fromOffset(0, 0)
    TabBar.BackgroundTransparency = 1
    TabBar.Parent = Content

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabBar

    --------------------------------------------------
    -- PAGE HOLDER
    --------------------------------------------------

    local PageHolder = Instance.new("Frame")
    PageHolder.Name = "Pages"
    PageHolder.Size = UDim2.new(1, -135, 1, 0)
    PageHolder.Position = UDim2.fromOffset(135, 0)
    PageHolder.BackgroundColor3 = COLORS.Background
    PageHolder.BackgroundTransparency = 0.25
    PageHolder.BorderSizePixel = 0
    PageHolder.Parent = Content

    Corner(PageHolder, 10)

    --------------------------------------------------
    -- DRAGGING
    --------------------------------------------------

    local dragging = false
    local dragStart
    local startPosition

    TopBar.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = Window.Position

        end

    end)

    UserInputService.InputChanged:Connect(function(input)

        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then

            local delta = input.Position - dragStart

            Window.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )

        end

    end)

    UserInputService.InputEnded:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

            dragging = false

        end

    end)

    --------------------------------------------------
    -- MINIMIZE
    --------------------------------------------------

    local minimized = false
    local oldSize = Window.Size

    Minimize.MouseButton1Click:Connect(function()

        minimized = not minimized

        if minimized then

            oldSize = Window.Size
            Window.Size = UDim2.fromOffset(650, 50)
            Content.Visible = false

        else

            Window.Size = oldSize
            Content.Visible = true

        end

    end)

    --------------------------------------------------
    -- CLOSE
    --------------------------------------------------

    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    --------------------------------------------------
    -- WINDOW OBJECT
    --------------------------------------------------

    local WindowObject = {}

    local currentTab

    --------------------------------------------------
    -- CREATE TAB
    --------------------------------------------------

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

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 10)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = Page

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()

            Page.CanvasSize = UDim2.new(
                0,
                0,
                0,
                PageLayout.AbsoluteContentSize.Y + 15
            )

        end)

        local TabObject = {}

        --------------------------------------------------
        -- TAB SELECT
        --------------------------------------------------

        TabButton.MouseButton1Click:Connect(function()

            if currentTab then
                currentTab.Page.Visible = false
                currentTab.Button.BackgroundColor3 = COLORS.Tab
            end

            Page.Visible = true
            TabButton.BackgroundColor3 = COLORS.TabSelected

            currentTab = {
                Page = Page,
                Button = TabButton
            }

        end)

        --------------------------------------------------
        -- SECTION
        --------------------------------------------------

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

        --------------------------------------------------
        -- LABEL
        --------------------------------------------------

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

        --------------------------------------------------
        -- BUTTON
        --------------------------------------------------

        function TabObject:CreateButton(options)

            options = options or {}

            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, 0, 0, 42)
            Button.BackgroundColor3 = COLORS.Accent
            Button.BackgroundTransparency = 0.35
            Button.BorderSizePixel = 0
            Button.Text = options.Name or "Button"
            Button.TextColor3 = Color3.new(1, 1, 1)
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

        --------------------------------------------------
        -- TOGGLE
        --------------------------------------------------

        function TabObject:CreateToggle(options)

            options = options or {}

            local enabled = options.CurrentValue or false

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
            Text.TextColor3 = Color3.new(1, 1, 1)

            local State = MakeText(
                Button,
                enabled and "ON" or "OFF",
                13,
                true
            )

            State.Position = UDim2.new(1, -55, 0, 0)
            State.Size = UDim2.fromOffset(45, 42)
            State.TextXAlignment = Enum.TextXAlignment.Center
            State.TextColor3 = Color3.new(1, 1, 1)

            local ToggleObject = {}

            function ToggleObject:Set(value)

                enabled = value
                State.Text = enabled and "ON" or "OFF"

                if options.Callback then
                    options.Callback(enabled)
                end

            end

            Button.MouseButton1Click:Connect(function()
                ToggleObject:Set(not enabled)
            end)

            return ToggleObject

        end

        --------------------------------------------------
        -- SLIDER
        --------------------------------------------------

        function TabObject:CreateSlider(options)

            options = options or {}

            local min = options.Min or 0
            local max = options.Max or 100
            local value = options.Default or min

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
            Name.TextColor3 = Color3.new(1, 1, 1)

            local ValueLabel = MakeText(
                Holder,
                tostring(value),
                14,
                true
            )

            ValueLabel.Position = UDim2.new(1, -60, 0, 5)
            ValueLabel.Size = UDim2.fromOffset(50, 25)
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.TextColor3 = Color3.new(1, 1, 1)

            local Bar = Instance.new("Frame")
            Bar.Size = UDim2.new(1, -24, 0, 8)
            Bar.Position = UDim2.fromOffset(12, 43)
            Bar.BackgroundColor3 = Color3.fromRGB(190, 190, 210)
            Bar.BorderSizePixel = 0
            Bar.Parent = Holder

            Corner(Bar, 5)

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(
                (value - min) / (max - min),
                0,
                1,
                0
            )
            Fill.BackgroundColor3 = COLORS.Slider
            Fill.BorderSizePixel = 0
            Fill.Parent = Bar

            Corner(Fill, 5)

            local draggingSlider = false

            local function SetValueFromX(x)

                local percentage = math.clamp(
                    (x - Bar.AbsolutePosition.X) /
                    Bar.AbsoluteSize.X,
                    0,
                    1
                )

                value = math.floor(
                    min + ((max - min) * percentage)
                )

                Fill.Size = UDim2.new(
                    percentage,
                    0,
                    1,
                    0
                )

                ValueLabel.Text = tostring(value)

                if options.Callback then
                    options.Callback(value)
                end

            end

            Bar.InputBegan:Connect(function(input)

                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then

                    draggingSlider = true
                    SetValueFromX(input.Position.X)

                end

            end)

            UserInputService.InputChanged:Connect(function(input)

                if draggingSlider and (
                    input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch
                ) then

                    SetValueFromX(input.Position.X)

                end

            end)

            UserInputService.InputEnded:Connect(function(input)

                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then

                    draggingSlider = false

                end

            end)

            local SliderObject = {}

            function SliderObject:Set(newValue)

                value = math.clamp(newValue, min, max)

                local percentage =
                    (value - min) / (max - min)

                Fill.Size = UDim2.new(
                    percentage,
                    0,
                    1,
                    0
                )

                ValueLabel.Text = tostring(value)

                if options.Callback then
                    options.Callback(value)
                end

            end

            return SliderObject

        end

        return TabObject

    end

    return WindowObject
end

--------------------------------------------------
-- EXAMPLE
--------------------------------------------------

local Window = Treasure:CreateWindow({
    Name = "Treasure"
})

--------------------------------------------------
-- TAB 1
--------------------------------------------------

local Main = Window:CreateTab("tab1")

Main:CreateSection("tab1 content")

Main:CreateButton({
    Name = "Test Button",

    Callback = function()
        print("Button pressed!")
    end
})

Main:CreateToggle({
    Name = "Test Toggle",
    CurrentValue = false,

    Callback = function(value)
        print("Toggle:", value)
    end
})

Main:CreateSlider({
    Name = "Test Slider",
    Min = 0,
    Max = 100,
    Default = 50,

    Callback = function(value)
        print("Slider:", value)
    end
})

--------------------------------------------------
-- TAB 2
--------------------------------------------------

local Tab2 = Window:CreateTab("tab2")

Tab2:CreateSection("Another Tab")

Tab2:CreateButton({
    Name = "Hello",

    Callback = function()
        print("Hello from tab2!")
    end
})
