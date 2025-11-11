--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║           OVHL TOOLS SUITE - MAIN DASHBOARD             ║
    ║         Created by: Omniverse Highland Studio            ║
    ╚═══════════════════════════════════════════════════════════╝
]]

-- ========================
-- PLUGIN INITIALIZATION
-- ========================

local toolbar = plugin:CreateToolbar("OVHL Tools")
local mainButton = toolbar:CreateButton("OVHL Tools Suite", "Open OVHL Tools Dashboard", "rbxassetid://100481932617711")

local Selection = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

-- ========================
-- SHARED LOGGER SYSTEM
-- ========================

local DEBUG_MODE = false

local Logger = {}

function Logger.log(message)
    if DEBUG_MODE then
        print(message)
    end
end

function Logger.warn(message)
    if DEBUG_MODE then
        warn(message)
    end
end

function Logger.success(message)
    print(message)
end

-- ========================
-- TOOL LOADER SYSTEM
-- ========================

local ToolLoader = {}
ToolLoader.tools = {}

function ToolLoader:LoadTools()
    local toolsFolder = script:FindFirstChild("Tools")
    if not toolsFolder then
        warn("⚠️ [OVHL Tools] Tools folder not found! Creating empty folder...")
        toolsFolder = Instance.new("Folder")
        toolsFolder.Name = "Tools"
        toolsFolder.Parent = script
        return
    end

    for _, module in ipairs(toolsFolder:GetChildren()) do
        if module:IsA("ModuleScript") then
            local success, tool = pcall(function()
                return require(module)
            end)

            if success and type(tool) == "table" then
                if tool.Name and tool.Description and tool.Execute then
                    table.insert(self.tools, tool)
                    Logger.log("✅ Loaded tool: " .. tool.Name)
                else
                    Logger.warn("⚠️ Invalid tool structure in: " .. module.Name)
                end
            else
                Logger.warn("⚠️ Failed to load tool: " .. module.Name)
            end
        end
    end

    table.sort(self.tools, function(a, b)
        return (a.Order or 999) < (b.Order or 999)
    end)

    Logger.log(string.format("📦 Loaded %d tool(s)", #self.tools))
end

function ToolLoader:GetTools()
    return self.tools
end

-- ========================
-- UI CREATION SYSTEM - YANG SUDAH DIPERBAIKI
-- ========================

local widgetInfo = DockWidgetPluginGuiInfo.new(
    Enum.InitialDockState.Float,
    false,
    false,
    350, -- Width
    500, -- Height
    300,
    500
)

local widget = plugin:CreateDockWidgetPluginGui("OVHLToolsSuite", widgetInfo)
widget.Title = "🛠️ OVHL Tools Suite"
widget.Name = "OVHLToolsSuite"

local UI = {}

-- ✅ FUNGSI CREATE DASHBOARD YANG SUDAH DIPERBAIKI
function UI:CreateDashboard()
    widget:ClearAllChildren()

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = widget

    -- HEADER
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    header.BorderSizePixel = 0
    header.Parent = mainFrame

    -- Header icon
    local headerIcon = Instance.new("ImageLabel")
    headerIcon.Size = UDim2.new(0, 32, 0, 32)
    headerIcon.Position = UDim2.new(0, 10, 0, 14)
    headerIcon.BackgroundTransparency = 1
    headerIcon.Image = "rbxassetid://100481932617711"
    headerIcon.ScaleType = Enum.ScaleType.Fit
    headerIcon.Parent = header

    local headerTitle = Instance.new("TextLabel")
    headerTitle.Size = UDim2.new(1, -50, 0, 25)
    headerTitle.Position = UDim2.new(0, 50, 0, 10)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "OVHL Tools Suite"
    headerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    headerTitle.TextSize = 16
    headerTitle.Font = Enum.Font.GothamBold
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.Parent = header

    local headerSubtitle = Instance.new("TextLabel")
    headerSubtitle.Size = UDim2.new(1, -50, 0, 18)
    headerSubtitle.Position = UDim2.new(0, 50, 0, 32)
    headerSubtitle.BackgroundTransparency = 1
    headerSubtitle.Text = "by Omniverse Highland Studio"
    headerSubtitle.TextColor3 = Color3.fromRGB(150, 150, 160)
    headerSubtitle.TextSize = 11
    headerSubtitle.Font = Enum.Font.Gotham
    headerSubtitle.TextXAlignment = Enum.TextXAlignment.Left
    headerSubtitle.Parent = header

    -- SCROLLING CONTENT
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, -100)
    scrollFrame.Position = UDim2.new(0, 0, 0, 60)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Parent = mainFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 12)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scrollFrame

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = scrollFrame

    -- FOOTER
    local footer = Instance.new("Frame")
    footer.Size = UDim2.new(1, 0, 0, 40)
    footer.Position = UDim2.new(0, 0, 1, -40)
    footer.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    footer.BorderSizePixel = 0
    footer.Parent = mainFrame

    local currentYear = os.date("%Y")
    local footerText = Instance.new("TextLabel")
    footerText.Size = UDim2.new(1, -20, 1, 0)
    footerText.Position = UDim2.new(0, 10, 0, 0)
    footerText.BackgroundTransparency = 1
    footerText.Text = "(c) " .. currentYear .. " - Omniverse Highland Studio"
    footerText.TextColor3 = Color3.fromRGB(150, 150, 160)
    footerText.TextSize = 11
    footerText.Font = Enum.Font.Gotham
    footerText.TextXAlignment = Enum.TextXAlignment.Left
    footerText.Parent = footer

    return scrollFrame
end

-- ✅ FUNGSI CREATE TOOL CARD YANG SUDAH DIPERBAIKI (HAPUS YANG DUPLIKAT!)
function UI:CreateToolCard(parent, tool)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 130)
    card.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    card.BorderSizePixel = 0
    card.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = card

    -- Icon Area
    local iconContainer = Instance.new("Frame")
    iconContainer.Size = UDim2.new(0, 50, 1, -50)
    iconContainer.BackgroundTransparency = 1
    iconContainer.Parent = card

    -- Icon (image atau emoji)
    if tool.IconType == "image" and tool.Icon then
        local iconImage = Instance.new("ImageLabel")
        iconImage.Size = UDim2.new(0, 36, 0, 36)
        iconImage.Position = UDim2.new(0.5, -18, 0.5, -18)
        iconImage.BackgroundTransparency = 1
        iconImage.Image = tool.Icon
        iconImage.ScaleType = Enum.ScaleType.Fit
        iconImage.Parent = iconContainer
    else
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(0, 36, 0, 36)
        iconLabel.Position = UDim2.new(0.5, -18, 0.5, -18)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = tool.Icon or "🔧"
        iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        iconLabel.TextSize = 20
        iconLabel.Font = Enum.Font.GothamBold
        iconLabel.Parent = iconContainer
    end

    -- Text Container
    local textContainer = Instance.new("Frame")
    textContainer.Size = UDim2.new(1, -60, 1, -50)
    textContainer.Position = UDim2.new(0, 55, 0, 0)
    textContainer.BackgroundTransparency = 1
    textContainer.Parent = card

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -10, 0, 24)
    title.Position = UDim2.new(0, 5, 0, 12)
    title.BackgroundTransparency = 1
    title.Text = tool.Name
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 15
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextTruncate = Enum.TextTruncate.AtEnd
    title.Parent = textContainer

    -- Description
    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -10, 1, -40)
    desc.Position = UDim2.new(0, 5, 0, 40)
    desc.BackgroundTransparency = 1
    desc.Text = tool.Description
    desc.TextColor3 = Color3.fromRGB(180, 180, 190)
    desc.TextSize = 12
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextWrapped = true
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.Parent = textContainer

    -- Execute Button
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 36)
    button.Position = UDim2.new(0, 10, 1, -42)
    button.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    button.Text = tool.ButtonText or "Execute"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 13
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = true
    button.Parent = card

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button

    -- Hover Effect
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(98, 111, 255)
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    end)

    -- Execute tool
    button.MouseButton1Click:Connect(function()
        local context = {
            plugin = plugin,
            Selection = Selection,
            ChangeHistoryService = ChangeHistoryService,
            Logger = Logger,
        }

        local success, err = pcall(function()
            tool.Execute(context)
        end)

        if not success then
            warn("⚠️ [OVHL Tools] Error executing " .. tool.Name .. ": " .. tostring(err))
        end
    end)

    return card
end

-- ✅ FUNGSI POPULATE TOOLS
function UI:PopulateTools(container)
    local tools = ToolLoader:GetTools()

    if #tools == 0 then
        local noTools = Instance.new("TextLabel")
        noTools.Size = UDim2.new(1, -10, 0, 80)
        noTools.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
        noTools.Text = "⚠️ No tools found!\n\nAdd ModuleScripts to Tools folder"
        noTools.TextColor3 = Color3.fromRGB(150, 150, 160)
        noTools.TextSize = 12
        noTools.Font = Enum.Font.Gotham
        noTools.Parent = container

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = noTools
        return
    end

    for _, tool in ipairs(tools) do
        self:CreateToolCard(container, tool)
    end

    -- Coming soon section
    local comingSoon = Instance.new("TextLabel")
    comingSoon.Size = UDim2.new(1, -10, 0, 60)
    comingSoon.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    comingSoon.Text = "🚀 Tools Lain Akan Segera Hadir...\n\nCheck README.md to add your own!"
    comingSoon.TextColor3 = Color3.fromRGB(150, 150, 160)
    comingSoon.TextSize = 11
    comingSoon.Font = Enum.Font.Gotham
    comingSoon.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = comingSoon
end

-- ========================
-- MAIN INITIALIZATION
-- ========================

local function initialize()
    -- Load all tools
    ToolLoader:LoadTools()

    -- Setup button click
    mainButton.Click:Connect(function()
        widget.Enabled = not widget.Enabled
        if widget.Enabled then
            local container = UI:CreateDashboard()
            UI:PopulateTools(container)
        end
    end)

    Logger.success("✨ [OVHL Tools Suite] Ready! Click toolbar button to open.")
end

-- Start plugin
initialize()
