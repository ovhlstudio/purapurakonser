-- Shared Theme System
-- Color palette and design tokens for OVHL UI System

local Theme = {}

-- ========================
-- COLOR PALETTE
-- ========================

Theme.Colors = {
    -- PRIMARY (Brand Color)
    PRIMARY = Color3.fromHex("B3014F"),
    PRIMARY_HOVER = Color3.fromHex("D50F66"),

    -- BACKGROUND
    BACKGROUND = Color3.fromHex("200B4B"),
    BACKGROUND_CARD = Color3.fromHex("200B4B"),

    -- SECONDARY/ACCENT
    SECONDARY = Color3.fromHex("3F1B77"),
    SECONDARY_HOVER = Color3.fromHex("50257B"),

    -- NEUTRALS
    TEXT = Color3.fromHex("FFFFFF"),
    BORDER = Color3.fromHex("FFFFFF"),
    STROKE = Color3.fromHex("FFFFFF"),

    -- STATES (Future use)
    SUCCESS = Color3.fromHex("00FF7F"),
    WARNING = Color3.fromHex("FFAA00"),
    ERROR = Color3.fromHex("FF3232"),
    DISABLED = Color3.fromHex("666666"),

    -- ASSET REFERENCES
    ASSETS = {
        VERTICAL_CARD = "rbxassetid://136464578605531",
        HORIZONTAL_CARD = "rbxassetid://73725792085238"
    }
}

-- ========================
-- TYPOGRAPHY SYSTEM
-- ========================

Theme.Typography = {
    HEADING = {
        Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        Size = 20,
        LineHeight = 1.0
    },

    SUBHEADING = {
        Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        Size = 16,
        LineHeight = 1.0
    },

    BODY = {
        Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Size = 14,
        LineHeight = 1.0
    },

    CAPTION = {
        Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Italic),
        Size = 12,
        LineHeight = 1.0
    },

    BUTTON = {
        Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        Size = 14,
        LineHeight = 1.0
    }
}

-- ========================
-- SPACING SYSTEM
-- ========================

Theme.Spacing = {
    -- Container spacing
    CONTAINER = 15,
    SECTION = 10,
    ITEM = 5,
    BUTTON_GROUP = 10,

    -- Touch targets (mobile friendly)
    TOUCH_MIN = 40,
    TOUCH_PADDING = 10,

    -- Scale system
    XS = 2,
    SM = 5,
    MD = 10,
    LG = 15,
    XL = 20,
    XXL = 25
}

-- ========================
-- BORDER RADIUS SCALE
-- ========================

Theme.CornerRadius = {
    NONE = UDim.new(0, 0),
    SM = UDim.new(0, 5),      -- Buttons
    MD = UDim.new(0, 10),     -- Cards
    LG = UDim.new(0, 15),     -- Containers
    XL = UDim.new(0, 20),     -- Main container
    FULL = UDim.new(1, 0)     -- Circles
}

-- ========================
-- COMPONENT TEMPLATES
-- ========================

Theme.Components = {
    GlassCard = {
        BackgroundColor3 = Theme.Colors.BACKGROUND,
        BackgroundTransparency = 0.6,
        BorderColor3 = Theme.Colors.BORDER,
        BorderTransparency = 0.7,
        BorderSizePixel = 0
    },

    PrimaryButton = {
        BackgroundColor3 = Theme.Colors.PRIMARY,
        BackgroundTransparency = 0.3,
        TextColor3 = Theme.Colors.TEXT,
        Font = Theme.Typography.BUTTON.Font,
        TextSize = Theme.Typography.BUTTON.Size,
        TextScaled = true,
        AutoButtonColor = true
    },

    SecondaryButton = {
        BackgroundColor3 = Theme.Colors.SECONDARY,
        BackgroundTransparency = 0.3,
        TextColor3 = Theme.Colors.TEXT,
        Font = Theme.Typography.BUTTON.Font,
        TextSize = Theme.Typography.BUTTON.Size,
        TextScaled = true,
        AutoButtonColor = true
    },

    IconButton = {
        BackgroundTransparency = 1,
        ImageColor3 = Theme.Colors.TEXT,
        AutoButtonColor = false,
        BorderSizePixel = 0
    },

    IconButtonPrimary = {
        BackgroundTransparency = 1,
        ImageColor3 = Theme.Colors.PRIMARY,
        AutoButtonColor = false,
        BorderSizePixel = 0
    },

    IconButtonSecondary = {
        BackgroundTransparency = 1,
        ImageColor3 = Theme.Colors.SECONDARY,
        AutoButtonColor = false,
        BorderSizePixel = 0
    },

    TextLabel = {
        BackgroundTransparency = 1,
        TextColor3 = Theme.Colors.TEXT,
        TextScaled = true,
        TextWrapped = true,
        RichText = false
    }
}

-- ========================
-- UTILITY FUNCTIONS
-- ========================

-- Apply component style to an instance
function Theme:ApplyStyle(instance, styleName)
    local style = self.Components[styleName]
    if not style then
        warn("[THEME] Style not found:", styleName)
        return
    end

    for property, value in pairs(style) do
        pcall(function()
            instance[property] = value
        end)
    end

    -- Auto-add corner radius if specified
    if styleName:find("Button") or styleName:find("Card") then
        local corner = Instance.new("UICorner")
        if styleName:find("Primary") or styleName:find("Secondary") then
            corner.CornerRadius = self.CornerRadius.SM
        elseif styleName:find("Card") then
            corner.CornerRadius = self.CornerRadius.MD
        end
        corner.Parent = instance
    end
end

-- Create styled text label
function Theme:CreateTextLabel(typography, text, parent)
    local label = Instance.new("TextLabel")

    -- Apply base text label style
    self:ApplyStyle(label, "TextLabel")

    -- Apply typography
    local typo = self.Typography[typography] or self.Typography.BODY
    label.Font = typo.Font
    label.TextSize = typo.Size
    label.LineHeight = typo.LineHeight
    label.Text = text

    if parent then
        label.Parent = parent
    end

    return label
end

-- Create styled button
function Theme:CreateButton(style, text, parent)
    local button = Instance.new("TextButton")

    self:ApplyStyle(button, style)
    button.Text = text

    if parent then
        button.Parent = parent
    end

    return button
end

return Theme
