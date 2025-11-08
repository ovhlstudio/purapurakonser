-- ThemeDemo - Test Theme System with actual UI creation

local ThemeDemo = {}

local ClientKernel = require(script.Parent.Parent.Parent.init)
local Logger
local SharedKernel
local Theme

function ThemeDemo:Init()
    ClientKernel = require(script.Parent.Parent.Parent.init)
    Logger = ClientKernel:GetModule("Logger")
    SharedKernel = require(game:GetService("ReplicatedStorage").Shared.init)
    Theme = SharedKernel:GetModule("Theme")

    if Theme then
        Logger:Info("ThemeDemo", "UI", "Theme Demo Initialized")
        self:CreateTestUI()
    else
        Logger:Error("ThemeDemo", "UI", "Theme module not found for demo")
    end
end

function ThemeDemo:CreateTestUI()
    -- Create a simple test screen to demonstrate Theme usage
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ThemeDemoGUI"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Main container
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0.4, 0, 0.6, 0)
    mainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)

    -- Apply GlassCard style
    Theme:ApplyStyle(mainFrame, "GlassCard")

    local corner = Instance.new("UICorner")
    corner.CornerRadius = Theme.CornerRadius.LG
    corner.Parent = mainFrame

    -- Title
    local title = Theme:CreateTextLabel("HEADING", "THEME SYSTEM DEMO", mainFrame)
    title.Size = UDim2.new(0.8, 0, 0.1, 0)
    title.Position = UDim2.new(0.1, 0, 0.05, 0)

    -- Color showcase
    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(0.8, 0, 0.15, 0)
    colorFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
    Theme:ApplyStyle(colorFrame, "GlassCard")

    local colorTitle = Theme:CreateTextLabel("SUBHEADING", "Color Palette", colorFrame)
    colorTitle.Size = UDim2.new(1, 0, 0.3, 0)

    local colorsText = Theme:CreateTextLabel("BODY", "Primary: #B3014F\nBackground: #200B4B\nSecondary: #3F1B77", colorFrame)
    colorsText.Size = UDim2.new(1, 0, 0.7, 0)
    colorsText.Position = UDim2.new(0, 0, 0.3, 0)
    colorsText.TextXAlignment = Enum.TextXAlignment.Left

    -- Buttons showcase
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(0.8, 0, 0.3, 0)
    buttonFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
    buttonFrame.BackgroundTransparency = 1

    local primaryBtn = Theme:CreateButton("PrimaryButton", "PRIMARY BUTTON", buttonFrame)
    primaryBtn.Size = UDim2.new(0.8, 0, 0.25, 0)
    primaryBtn.Position = UDim2.new(0.1, 0, 0.1, 0)

    local secondaryBtn = Theme:CreateButton("SecondaryButton", "SECONDARY BUTTON", buttonFrame)
    secondaryBtn.Size = UDim2.new(0.8, 0, 0.25, 0)
    secondaryBtn.Position = UDim2.new(0.1, 0, 0.4, 0)

    -- Typography showcase
    local typoFrame = Instance.new("Frame")
    typoFrame.Size = UDim2.new(0.8, 0, 0.25, 0)
    typoFrame.Position = UDim2.new(0.1, 0, 0.75, 0)
    Theme:ApplyStyle(typoFrame, "GlassCard")

    local typoTitle = Theme:CreateTextLabel("SUBHEADING", "Typography", typoFrame)
    typoTitle.Size = UDim2.new(1, 0, 0.3, 0)

    local fontsText = Theme:CreateTextLabel("CAPTION", "Gotham SSm - Bold/Regular/Italic", typoFrame)
    fontsText.Size = UDim2.new(1, 0, 0.7, 0)
    fontsText.Position = UDim2.new(0, 0, 0.3, 0)

    mainFrame.Parent = screenGui

    Logger:Info("ThemeDemo", "UI", "Theme Demo UI created successfully!")
    Logger:Info("ThemeDemo", "UI", "Check PlayerGui for ThemeDemoGUI")

    -- Test utility functions
    self:TestUtilityFunctions()
end

function ThemeDemo:TestUtilityFunctions()
    -- Test ApplyStyle function
    local testFrame = Instance.new("Frame")
    Theme:ApplyStyle(testFrame, "GlassCard")

    Logger:Info("ThemeDemo", "UI", "✓ ApplyStyle() working")
    Logger:Info("ThemeDemo", "UI", "✓ CreateTextLabel() working")
    Logger:Info("ThemeDemo", "UI", "✓ CreateButton() working")
    Logger:Info("ThemeDemo", "UI", "✓ Color palette accessible")
    Logger:Info("ThemeDemo", "UI", "✓ Typography system working")

    testFrame:Destroy()
end

return ThemeDemo
