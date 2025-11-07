# **📚 BUKU PANDUAN SUPER: AI HARDCODE UI BUILDER**

_Complete Guide untuk Roblox UI Generation yang Professional_

## **🎯 1. PHILOSOPHI DASAR**

### **1.1 MENTAL MODEL AI**

```lua
-- SALAH: Thinking in pixels
Size = UDim2.new(0, 200, 0, 50)

-- BENAR: Thinking in percentages
Size = UDim2.new(0.8, 0, 0.1, 0)  -- 80% width, 10% height
```

### **1.2 HIERARCHI MENTAL**

```
ScreenGui (Root)
└── ContainerFrame (Layout Manager)
    └── ContentFrame (Content + Padding)
        └── UIListLayout (Auto Arrangement)
            └── SectionFrames (LayoutOrder Sequence)
```

## **🏗️ 2. STRUCTURE FRAMEWORK**

### **2.1 BASE TEMPLATE WAJIB**

```lua
-- 1. SCREEN GUI ROOT
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MusicPlayerGUI"
ScreenGui.DisplayOrder = 10
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.IgnoreGuiInset = true  -- Hindari notch/button area

-- 2. SAFE AREA CONTAINER (WAJIB UNTUK MOBILE)
local PaddingFrame = Instance.new("Frame")
PaddingFrame.Name = "PaddingFrame"
PaddingFrame.Size = UDim2.new(0.85, 0, 0.86, 0)      -- 15% margin horizontal, 14% vertical
PaddingFrame.Position = UDim2.new(0.075, 0, 0.02, 0) -- Center dengan margin
PaddingFrame.AnchorPoint = Vector2.new(0, 0)
PaddingFrame.BackgroundTransparency = 1
PaddingFrame.Parent = ScreenGui

-- 3. MAIN CONTENT CONTAINER (ASPECT RATIO LOCKED)
local MainContainer = Instance.new("Frame")
MainContainer.Name = "MainContainer"
MainContainer.Size = UDim2.new(0.4, 0, 1, 0)        -- 40% width, full height parent
MainContainer.Position = UDim2.new(0.5, 0, 0, 0)    -- Center horizontal
MainContainer.AnchorPoint = Vector2.new(0.5, 0)     -- Anchor ke center
MainContainer.BackgroundTransparency = 1
MainContainer.Parent = PaddingFrame

-- 4. ASPECT RATIO CONSTRAINT (WAJIB UNTUK CONSISTENCY)
local AspectRatio = Instance.new("UIAspectRatioConstraint")
AspectRatio.AspectRatio = 0.5625  -- 9:16 = 0.5625
AspectRatio.AspectType = Enum.AspectType.FitWithinMaxSize
AspectRatio.DominantAxis = Enum.DominantAxis.Width
AspectRatio.Parent = MainContainer

-- 5. CONTENT FRAME DENGAN PADDING
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, 0, 1, 0)           -- Full size container
ContentFrame.Position = UDim2.new(0, 0, 0, 0)
ContentFrame.AnchorPoint = Vector2.new(0, 0)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainContainer

-- 6. CONTENT PADDING (WAJIB UNTUK BREATHING SPACE)
local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingLeft = UDim.new(0, 15)        -- 15px left
ContentPadding.PaddingRight = UDim.new(0, 15)       -- 15px right
ContentPadding.PaddingTop = UDim.new(0, 15)         -- 15px top
ContentPadding.PaddingBottom = UDim.new(0, 15)      -- 15px bottom
ContentPadding.Parent = ContentFrame

-- 7. VERTICAL LAYOUT MANAGER (WAJIB)
local ContentListLayout = Instance.new("UIListLayout")
ContentListLayout.FillDirection = Enum.FillDirection.Vertical
ContentListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ContentListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
ContentListLayout.Padding = UDim.new(0, 0)          -- No extra spacing
ContentListLayout.SortOrder = Enum.SortOrder.LayoutOrder  -- WAJIB!
ContentListLayout.Parent = ContentFrame
```

### **2.2 SECTION HEIGHT DISTRIBUTION**

```lua
-- TOTAL HEIGHT = 100% (ContentFrame)
-- Distribution yang balanced:
HeaderFrame:      5%    (LayoutOrder: 1)
NowPlayingBox:    40%   (LayoutOrder: 2)
PlaylistFrame:    25%   (LayoutOrder: 3)
MediaButtonFrame: 15%   (LayoutOrder: 4)
FooterText:       8%    (LayoutOrder: 5)
-- Reserve:         7%    (Untuk padding & spacing)
```

## **🎨 3. VISUAL DESIGN SYSTEM**

### **3.1 COLOR PALETTE STANDARD**

```lua
-- PRIMARY COLORS
local COLORS = {
    PRIMARY = Color3.fromRGB(0, 170, 255),     -- Biru utama
    SECONDARY = Color3.fromRGB(255, 0, 127),   -- Pink/Magenta
    ACCENT = Color3.fromRGB(255, 255, 0),      -- Yellow
    SUCCESS = Color3.fromRGB(0, 255, 127),     -- Green
    WARNING = Color3.fromRGB(255, 170, 0),     -- Orange
    DANGER = Color3.fromRGB(255, 50, 50),      -- Red

    -- NEUTRALS
    WHITE = Color3.fromRGB(255, 255, 255),
    BLACK = Color3.fromRGB(0, 0, 0),
    GRAY_LIGHT = Color3.fromRGB(200, 200, 200),
    GRAY_MEDIUM = Color3.fromRGB(120, 120, 120),
    GRAY_DARK = Color3.fromRGB(60, 60, 60)
}

-- TRANSPARENCY LEVELS
local TRANSPARENCY = {
    SOLID = 0,           -- Full opaque
    CARD = 0.3,          -- Glass card effect
    MODAL = 0.5,         -- Semi-transparent overlay
    GHOST = 0.8,         -- Almost transparent
    INVISIBLE = 1        -- Fully transparent
}
```

### **3.2 TYPOGRAPHY SYSTEM**

```lua
-- FONT HIERARCHI
local TYPOGRAPHY = {
    DISPLAY = {
        Font = Enum.Font.GothamBlack,
        Size = 24,
        LineHeight = 1.2
    },
    HEADING = {
        Font = Enum.Font.GothamBold,
        Size = 20,
        LineHeight = 1.3
    },
    SUBHEADING = {
        Font = Enum.Font.GothamBold,
        Size = 16,
        LineHeight = 1.4
    },
    BODY = {
        Font = Enum.Font.Gotham,
        Size = 14,
        LineHeight = 1.5
    },
    CAPTION = {
        Font = Enum.Font.Gotham,
        Size = 12,
        LineHeight = 1.5
    },
    BUTTON = {
        Font = Enum.Font.GothamBold,
        Size = 14,
        LineHeight = 1.0
    }
}

-- TEXT PROPERTIES TEMPLATE
function createTextLabel(typography, text, color)
    local label = Instance.new("TextLabel")
    label.Font = typography.Font
    label.TextSize = typography.Size
    label.TextColor3 = color or COLORS.WHITE
    label.Text = text
    label.TextScaled = true                    -- WAJIB UNTUK RESPONSIVE
    label.TextWrapped = true                   -- Prevent overflow
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    return label
end
```

### **3.3 BORDER RADIUS SCALE**

```lua
local CORNER_RADIUS = {
    NONE = UDim.new(0, 0),
    SM = UDim.new(0, 5),      -- Small (5px)
    MD = UDim.new(0, 10),     -- Medium (10px)
    LG = UDim.new(0, 15),     -- Large (15px)
    XL = UDim.new(0, 20),     -- Extra Large (20px)
    FULL = UDim.new(1, 0)     -- Perfect circle
}
```

## **🔧 4. LAYOUT & SPACING SYSTEM**

### **4.1 UIListLayout PATTERNS**

```lua
-- VERTICAL LAYOUT (Primary)
function createVerticalLayout(alignment, padding)
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = alignment or Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, padding or 0)
    layout.SortOrder = Enum.SortOrder.LayoutOrder  -- WAJIB!
    return layout
end

-- HORIZONTAL LAYOUT (Secondary)
function createHorizontalLayout(alignment, padding)
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = alignment or Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, padding or 0)
    layout.SortOrder = Enum.SortOrder.LayoutOrder  -- WAJIB!
    return layout
end
```

### **4.2 SPACING SCALE**

```lua
local SPACING = {
    XS = 2,    -- Extra small (2px)
    SM = 5,     -- Small (5px)
    MD = 10,    -- Medium (10px)
    LG = 15,    -- Large (15px)
    XL = 20,    -- Extra large (20px)
    XXL = 25    -- Double extra large (25px)
}
```

### **4.3 LAYOUTORDER MANAGEMENT**

```lua
-- SYSTEMATIC LAYOUTORDER ASSIGNMENT
local LAYOUT_ORDER = {
    HEADER = 1,
    NOW_PLAYING = 2,
    PLAYLIST = 3,
    MEDIA_CONTROLS = 4,
    FOOTER = 5,

    -- Sub-items (increment by 1)
    SUB_ITEM_START = 10,

    -- Dynamic items (increment by 1 from base)
    DYNAMIC_BASE = 100
}

-- FUNCTION TO ASSIGN LAYOUTORDER
function assignLayoutOrder(container)
    local children = container:GetChildren()
    table.sort(children, function(a, b)
        return a.Name < b.Name  -- Sort by name for consistency
    end)

    for i, child in ipairs(children) do
        if child:IsA("GuiObject") then
            child.LayoutOrder = i
        end
    end
end
```

## **⚡ 5. INTERACTIVE ELEMENTS GUIDE**

### **5.1 BUTTON TYPE DECISION TREE**

```
BUTTON NEEDS CLICK EVENT?
├── YES: Use ImageButton/TextButton
│   ├── HAS IMAGE? → ImageButton
│   └── TEXT ONLY? → TextButton
└── NO: Use ImageLabel/TextLabel
    ├── DECORATIVE IMAGE? → ImageLabel
    └── STATIC TEXT? → TextLabel
```

### **5.2 IMAGE BUTTON TEMPLATE**

```lua
function createImageButton(imageId, size, layoutOrder)
    local button = Instance.new("ImageButton")
    button.Name = "ImageButton"
    button.Size = size or UDim2.new(0.1, 0, 0.8, 0)
    button.BackgroundTransparency = 1                    -- Transparent background
    button.Image = imageId or ""
    button.ImageColor3 = COLORS.WHITE
    button.ImageTransparency = 0
    button.ScaleType = Enum.ScaleType.Fit               -- Maintain aspect ratio
    button.LayoutOrder = layoutOrder or 0
    button.AutoButtonColor = false                      -- Consistent appearance
    button.ZIndex = 2                                   -- Above background
    return button
end
```

### **5.3 TEXT BUTTON TEMPLATE**

```lua
function createTextButton(text, size, layoutOrder, backgroundColor)
    local button = Instance.new("TextButton")
    button.Name = "TextButton"
    button.Size = size or UDim2.new(0.3, 0, 0.8, 0)
    button.BackgroundColor3 = backgroundColor or COLORS.SECONDARY
    button.BackgroundTransparency = TRANSPARENCY.CARD
    button.Text = text or "Button"
    button.Font = TYPOGRAPHY.BUTTON.Font
    button.TextSize = TYPOGRAPHY.BUTTON.Size
    button.TextColor3 = COLORS.WHITE
    button.TextScaled = true
    button.LayoutOrder = layoutOrder or 0
    button.AutoButtonColor = true                       -- Native hover effect
    button.ZIndex = 2

    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = CORNER_RADIUS.MD
    corner.Parent = button

    return button
end
```

## **📱 6. MOBILE-FIRST RESPONSIVE DESIGN**

### **6.1 TOUCH TARGET REQUIREMENTS**

```lua
local TOUCH_TARGET = {
    MIN_WIDTH = 40,      -- Minimum 40px width
    MIN_HEIGHT = 40,     -- Minimum 40px height
    PADDING = 10,        -- 10px between touch targets
    HITBOX_EXPANSION = 5 -- 5px invisible hitbox expansion
}

-- CHECK TOUCH TARGET COMPLIANCE
function validateTouchTarget(element)
    local absoluteSize = element.AbsoluteSize
    return absoluteSize.X >= TOUCH_TARGET.MIN_WIDTH and
           absoluteSize.Y >= TOUCH_TARGET.MIN_HEIGHT
end
```

### **6.2 RESPONSIVE BREAKPOINTS**

```lua
local BREAKPOINTS = {
    MOBILE_SMALL = 375,   -- iPhone SE, small phones
    MOBILE_MEDIUM = 414,  -- Most smartphones
    MOBILE_LARGE = 768,   -- Tablets in portrait
    DESKTOP_SMALL = 1024, -- Small desktop
    DESKTOP_LARGE = 1440  -- Large desktop
}

-- ADAPTIVE SIZING FUNCTION
function getResponsiveSize(baseSize, screenWidth)
    if screenWidth <= BREAKPOINTS.MOBILE_SMALL then
        return UDim2.new(baseSize.X.Scale * 0.9, 0, baseSize.Y.Scale * 0.9, 0)
    elseif screenWidth <= BREAKPOINTS.MOBILE_MEDIUM then
        return baseSize
    else
        return UDim2.new(baseSize.X.Scale * 1.1, 0, baseSize.Y.Scale * 1.1, 0)
    end
end
```

## **🎵 7. MUSIC PLAYER SPECIFIC COMPONENTS**

### **7.1 HEADER COMPONENT**

```lua
function createHeader()
    local header = Instance.new("Frame")
    header.Name = "HeaderFrame"
    header.Size = UDim2.new(1, 0, 0.05, 0)        -- 5% height
    header.BackgroundTransparency = 1
    header.LayoutOrder = LAYOUT_ORDER.HEADER
    header.Parent = ContentFrame

    -- Horizontal layout for header items
    local headerLayout = createHorizontalLayout(Enum.HorizontalAlignment.Center, 0)
    headerLayout.Parent = header

    -- Menu Button (Left)
    local menuButton = createImageButton("rbxassetid://MENU_ICON_ID", UDim2.new(0.2, 0, 1, 0), 1)
    menuButton.Parent = header

    -- Title (Center)
    local title = createTextLabel(TYPOGRAPHY.HEADING, "MUSIC PLAYER", COLORS.WHITE)
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.LayoutOrder = 2
    title.Parent = header

    -- Close Button (Right)
    local closeButton = createImageButton("rbxassetid://CLOSE_ICON_ID", UDim2.new(0.2, 0, 1, 0), 3)
    closeButton.Parent = header

    return header
end
```

### **7.2 NOW PLAYING COMPONENT**

```lua
function createNowPlayingBox()
    local nowPlaying = Instance.new("Frame")
    nowPlaying.Name = "NowPlayingBox"
    nowPlaying.Size = UDim2.new(1, 0, 0.4, 0)           -- 40% height
    nowPlaying.BackgroundColor3 = COLORS.WHITE
    nowPlaying.BackgroundTransparency = TRANSPARENCY.CARD
    nowPlaying.LayoutOrder = LAYOUT_ORDER.NOW_PLAYING
    nowPlaying.Parent = ContentFrame

    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = CORNER_RADIUS.XL
    corner.Parent = nowPlaying

    -- Internal padding
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, SPACING.LG)
    padding.PaddingRight = UDim.new(0, SPACING.LG)
    padding.PaddingTop = UDim.new(0, SPACING.LG)
    padding.PaddingBottom = UDim.new(0, SPACING.LG)
    padding.Parent = nowPlaying

    -- Vertical layout for content
    local layout = createVerticalLayout(Enum.HorizontalAlignment.Center, SPACING.MD)
    layout.Parent = nowPlaying

    -- Vinyl Art (40% of container)
    local vinylFrame = createVinylArt()
    vinylFrame.LayoutOrder = 1
    vinylFrame.Parent = nowPlaying

    -- Song Title (15% of container)
    local title = createTextLabel(TYPOGRAPHY.SUBHEADING, "JUDUL LAGU", COLORS.WHITE)
    title.Size = UDim2.new(0.8, 0, 0.15, 0)
    title.LayoutOrder = 2
    title.Parent = nowPlaying

    -- Artist & Genre (10% of container)
    local artistGenre = createTextLabel(TYPOGRAPHY.BODY, "Artis - Genre", COLORS.WHITE)
    artistGenre.Size = UDim2.new(0.8, 0, 0.1, 0)
    artistGenre.LayoutOrder = 3
    artistGenre.Parent = nowPlaying

    return nowPlaying
end
```

### **7.3 PLAYLIST COMPONENT**

```lua
function createPlaylistFrame()
    local playlist = Instance.new("Frame")
    playlist.Name = "PlaylistFrame"
    playlist.Size = UDim2.new(1, 0, 0.25, 0)           -- 25% height
    playlist.BackgroundTransparency = 1
    playlist.LayoutOrder = LAYOUT_ORDER.PLAYLIST
    playlist.Parent = ContentFrame

    -- Scrolling frame for playlist items
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "PlaylistScroll"
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 3
    scrollFrame.ScrollBarImageColor3 = COLORS.WHITE
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y  -- Auto expand height
    scrollFrame.Parent = playlist

    -- Scroll frame padding
    local scrollPadding = Instance.new("UIPadding")
    scrollPadding.PaddingLeft = UDim.new(0, SPACING.SM)
    scrollPadding.PaddingRight = UDim.new(0, SPACING.SM)
    scrollPadding.PaddingTop = UDim.new(0, SPACING.SM)
    scrollPadding.PaddingBottom = UDim.new(0, SPACING.SM)
    scrollPadding.Parent = scrollFrame

    -- Vertical layout for playlist items
    local scrollLayout = createVerticalLayout(Enum.HorizontalAlignment.Center, SPACING.SM)
    scrollLayout.Parent = scrollFrame

    -- Playlist item template (Hidden by default)
    local template = createPlaylistItemTemplate()
    template.Parent = scrollFrame

    return playlist, template
end
```

## **🔍 8. QUALITY ASSURANCE CHECKLIST**

### **8.1 PRE-FLIGHT CHECKLIST**

```lua
local QA_CHECKLIST = {
    "✅ All sizes use SCALE (not pixels)",
    "✅ All frames have LAYOUTORDER assigned",
    "✅ All containers have UIListLayout",
    "✅ All text elements have TEXTSCALED = true",
    "✅ Interactive elements use ImageButton/TextButton",
    "✅ Decorative elements use ImageLabel/TextLabel",
    "✅ Adequate padding around touch targets",
    "✅ Color contrast meets accessibility standards",
    "✅ All images have proper ScaleType",
    "✅ ScrollingFrames have AutomaticCanvasSize set",
    "✅ AspectRatioConstraints for fixed ratio elements"
}

function runQAChecklist(uiRoot)
    local issues = {}

    -- Check scale usage
    local descendants = uiRoot:GetDescendants()
    for _, element in ipairs(descendants) do
        if element:IsA("GuiObject") then
            -- Scale check
            if element.Size.X.Offset > 0 or element.Size.Y.Offset > 0 then
                table.insert(issues, "❌ " .. element.Name .. " uses pixel sizing")
            end

            -- LayoutOrder check
            if element:IsA("Frame") and element.LayoutOrder == 0 then
                table.insert(issues, "❌ " .. element.Name .. " has default LayoutOrder")
            end

            -- TextScaled check
            if element:IsA("TextLabel") and not element.TextScaled then
                table.insert(issues, "❌ " .. element.Name .. " missing TextScaled")
            end
        end
    end

    return issues
end
```

### **8.2 PERFORMANCE OPTIMIZATIONS**

```lua
local PERFORMANCE_TIPS = {
    "🎯 Use ClipsDescendants = true for scrolling areas",
    "🎯 Set BackgroundTransparency = 1 for invisible elements",
    "🎯 Use ImageLabel instead of Frame + ImageLabel for images",
    "🎯 Minimize use of UIStroke and UIGradient",
    "🎯 Use SurfaceGui for 3D UI instead of BillboardsGui",
    "🎯 Batch property changes using Instance.new then set parent",
    "🎯 Use Destroy() instead of Remove() for cleanup"
}
```

## **🚀 9. DEPLOYMENT & MAINTENANCE**

### **9.1 VERSION CONTROL TEMPLATE**

```lua
-- UI VERSIONING SYSTEM
local UI_VERSION = {
    MAJOR = 1,    -- Breaking changes
    MINOR = 0,    -- New features
    PATCH = 0     -- Bug fixes
}

function getUIVersionString()
    return string.format("v%d.%d.%d", UI_VERSION.MAJOR, UI_VERSION.MINOR, UI_VERSION.PATCH)
end

-- Add version to footer
FooterText.Text = "Music Player " .. getUIVersionString() .. " © 2025"
```

### **9.2 ERROR HANDLING & GRACEFUL DEGRADATION**

```lua
function safeCreateElement(elementType, properties)
    local success, element = pcall(function()
        local newElement = Instance.new(elementType)

        -- Apply properties with error handling
        for property, value in pairs(properties) do
            pcall(function()
                newElement[property] = value
            end)
        end

        return newElement
    end)

    if success then
        return element
    else
        -- Fallback to basic element
        warn("Failed to create " .. elementType .. ", using fallback")
        return Instance.new("Frame")
    end
end
```

---

### 10. CMD UNTUK AUDIT UI di StarterGui "BUKAN di PlayerGui" !

```bash
local function auditUI(object, indent, results)
    indent = indent or 0
    results = results or {}

    local objType = object.ClassName
    local objName = object.Name

    -- Collect ALL properties dengan approach yang lebih aman
    local info = {
        type = objType,
        name = objName,
        path = object:GetFullName(),
        properties = {}
    }

    -- Common properties untuk semua GUI objects
    local commonProperties = {
        "Name", "Size", "Position", "AnchorPoint", "Rotation", "Visible",
        "BackgroundColor3", "BackgroundTransparency", "BorderColor3", "BorderSizePixel",
        "ZIndex", "LayoutOrder", "ClipsDescendants"
    }

    -- Properties berdasarkan class type
    local classSpecificProps = {
        TextLabel = {"Text", "TextColor3", "TextSize", "Font", "TextScaled", "TextWrapped", "TextXAlignment", "TextYAlignment", "TextTruncate", "RichText", "MaxVisibleGraphemes"},
        TextButton = {"Text", "TextColor3", "TextSize", "Font", "TextScaled", "TextWrapped", "TextXAlignment", "TextYAlignment", "AutoButtonColor"},
        ImageLabel = {"Image", "ImageColor3", "ImageTransparency", "ScaleType", "SliceScale", "TileSize"},
        ImageButton = {"Image", "ImageColor3", "ImageTransparency", "ScaleType", "SliceScale", "TileSize", "AutoButtonColor"},
        Frame = {"BackgroundColor3", "BackgroundTransparency"},
        ScrollingFrame = {"CanvasSize", "ScrollBarThickness", "ScrollBarImageColor3", "ScrollBarImageTransparency", "ScrollingDirection", "VerticalScrollBarPosition", "AutomaticCanvasSize", "BottomImage", "MidImage", "TopImage"},
        UIListLayout = {"FillDirection", "HorizontalAlignment", "VerticalAlignment", "Padding", "SortOrder", "HorizontalFlex", "VerticalFlex", "Wraps", "ItemLineAlignment"},
        UIPadding = {"PaddingLeft", "PaddingRight", "PaddingTop", "PaddingBottom"},
        UICorner = {"CornerRadius"},
        UIStroke = {"Thickness", "Color", "Transparency", "ApplyStrokeMode"},
        UIAspectRatioConstraint = {"AspectRatio", "AspectType", "DominantAxis"},
        UISizeConstraint = {"MinSize", "MaxSize"},
        UIFlexItem = {"FlexMode", "GrowRatio", "ShrinkRatio", "ItemLineAlignment"},
        UIScale = {"Scale"},
        UIGradient = {"Color", "Transparency", "Offset", "Rotation", "Enabled"}
    }

    -- Collect common properties
    for _, propName in ipairs(commonProperties) do
        pcall(function()
            local value = object[propName]
            if value ~= nil then
                info.properties[propName] = value
            end
        end)
    end

    -- Collect class-specific properties
    local classProps = classSpecificProps[objType]
    if classProps then
        for _, propName in ipairs(classProps) do
            pcall(function()
                local value = object[propName]
                if value ~= nil then
                    info.properties[propName] = value
                end
            end)
        end
    end

    table.insert(results, info)

    -- Recursively audit children
    for _, child in ipairs(object:GetChildren()) do
        auditUI(child, indent + 1, results)
    end

    return results
end

-- Format property values untuk readability
local function formatPropertyValue(value)
    if typeof(value) == "UDim2" then
        return string.format("{%d, %d}, {%d, %d}",
            value.X.Scale, value.X.Offset,
            value.Y.Scale, value.Y.Offset)
    elseif typeof(value) == "Color3" then
        return string.format("%d, %d, %d",
            math.floor(value.R * 255), math.floor(value.G * 255), math.floor(value.B * 255))
    elseif typeof(value) == "Vector2" then
        return string.format("%d, %d", value.X, value.Y)
    elseif typeof(value) == "EnumItem" then
        return tostring(value.Name)
    elseif typeof(value) == "UDim" then
        return string.format("%d, %d", value.Scale, value.Offset)
    else
        return tostring(value)
    end
end

-- MAIN AUDIT EXECUTION
local screenGui = game.StarterGui:FindFirstChild("MusicPlayerGUI")
if screenGui then
    print("🎵 ===== MUSIC PLAYER UI COMPLETE AUDIT =====")
    local auditResults = auditUI(screenGui)

    for _, item in ipairs(auditResults) do
        print("\n" .. "📁 " .. item.type .. " : " .. item.name)
        print("📍 Path: " .. item.path)

        if next(item.properties) then
            for propName, propValue in pairs(item.properties) do
                local formattedValue = formatPropertyValue(propValue)
                print("   ⚙️  " .. propName .. ": " .. formattedValue)
            end
        else
            print("   ℹ️  No properties captured")
        end
    end

    print("\n📈 ===== AUDIT SUMMARY =====")
    print("Total Objects: " .. #auditResults)

    local responsiveCount = 0
    for _, item in ipairs(auditResults) do
        if item.properties.Size then
            local size = item.properties.Size
            if size.X.Scale > 0 or size.Y.Scale > 0 then
                responsiveCount = responsiveCount + 1
            end
        end
    end

    print("Responsive Elements: " .. responsiveCount .. "/" .. #auditResults)
    print("✅ Complete audit finished! Ready for UI Builder.")

    return auditResults
else
    print("❌ MusicPlayerGUI not found in StarterGui!")
    return nil
end

```

**🎯 FINAL REMINDER UNTUK AI:**

> **THINK IN PERCENTAGES, NOT PIXELS!**
> Setiap UI element harus responsive dan adaptable ke semua device sizes.
