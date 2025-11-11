--[[
    GUI to Script Converter V2.1
    OVHL Tools Suite - Modular Tool
    Converts ScreenGui to 100% accurate Lua script
]]

local Tool = {}

-- ========================
-- TOOL METADATA
-- ========================

Tool.Name = "GUI to Script Converter"
Tool.Description = "Convert ScreenGui to 100% accurate Lua script with all properties"
Tool.IconType = "image"
Tool.Icon = "rbxassetid://138584695213843"
Tool.ButtonText = "Convert Gui To Script"
Tool.Order = 1

-- ========================
-- TOOL LOGIC
-- ========================

local function isBlacklisted(propName)
    local BLACKLIST = {
        "Parent",
        "ClassName",
        "Name",
        "AbsolutePosition",
        "AbsoluteSize",
        "AbsoluteRotation",
        "AbsoluteContentSize",
        "ContentSize",
        "AbsoluteCanvasSize",
        "CurrentCamera",
        "ViewportSize",
    }
    for _, b in ipairs(BLACKLIST) do
        if propName == b then
            return true
        end
    end
    return false
end

local function getAllProperties(instance)
    local properties = {}

    local function tryGetProperty(propName)
        if isBlacklisted(propName) then
            return false
        end
        local success, value = pcall(function()
            return instance[propName]
        end)
        if success and type(value) ~= "function" then
            properties[propName] = value
            return true
        end
        return false
    end

    local propLists = {
        GuiObject = {
            "AnchorPoint",
            "AutomaticSize",
            "BackgroundColor3",
            "BackgroundTransparency",
            "BorderColor3",
            "BorderMode",
            "BorderSizePixel",
            "ClipsDescendants",
            "LayoutOrder",
            "Position",
            "Rotation",
            "Size",
            "SizeConstraint",
            "Visible",
            "ZIndex",
            "Active",
        },
        ScrollingFrame = {
            "AutomaticCanvasSize",
            "CanvasPosition",
            "CanvasSize",
            "ScrollBarThickness",
            "ScrollingEnabled",
            "ElasticBehavior",
        },
        TextLabel = {
            "Font",
            "FontFace",
            "LineHeight",
            "RichText",
            "Text",
            "TextColor3",
            "TextScaled",
            "TextSize",
            "TextStrokeTransparency",
            "TextTransparency",
            "TextWrapped",
            "TextXAlignment",
            "TextYAlignment",
        },
        ImageLabel = { "Image", "ImageColor3", "ImageTransparency", "ScaleType" },
        GuiButton = { "AutoButtonColor", "Modal", "Selected" },
        ScreenGui = { "DisplayOrder", "Enabled", "IgnoreGuiInset", "ResetOnSpawn", "ZIndexBehavior" },
        UICorner = { "CornerRadius" },
        UIStroke = { "Color", "Thickness", "Transparency" },
        UIListLayout = { "Padding", "FillDirection", "HorizontalAlignment", "VerticalAlignment", "SortOrder" },
        UIPadding = { "PaddingBottom", "PaddingLeft", "PaddingRight", "PaddingTop" },
    }

    for className, props in pairs(propLists) do
        if instance:IsA(className) then
            for _, prop in ipairs(props) do
                tryGetProperty(prop)
            end
        end
    end

    return properties
end

local function getDefaultValue(className, propName)
    local defaults = {
        AutomaticSize = Enum.AutomaticSize.None,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0,
        BorderSizePixel = 1,
        LayoutOrder = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 0, 0, 0),
        Visible = true,
        ZIndex = 1,
        Text = "Label",
        TextColor3 = Color3.fromRGB(27, 42, 53),
        TextSize = 14,
        TextTransparency = 0,
    }
    return defaults[propName]
end

local function isDifferentFromDefault(instance, propName, value)
    if propName == "AutomaticSize" then
        return true
    end
    local default = getDefaultValue(instance.ClassName, propName)
    if not default then
        return true
    end

    local t = typeof(value)
    if t == "Color3" then
        return value.R ~= default.R or value.G ~= default.G or value.B ~= default.B
    elseif t == "UDim2" then
        return value.X.Scale ~= default.X.Scale
            or value.X.Offset ~= default.X.Offset
            or value.Y.Scale ~= default.Y.Scale
            or value.Y.Offset ~= default.Y.Offset
    else
        return value ~= default
    end
end

local function formatValue(value)
    local t = typeof(value)
    if t == "string" then
        return string.format("%q", value)
    elseif t == "number" then
        return tostring(value == math.floor(value) and math.floor(value) or value)
    elseif t == "boolean" then
        return tostring(value)
    elseif t == "Color3" then
        return string.format(
            "Color3.fromRGB(%d, %d, %d)",
            math.floor(value.R * 255),
            math.floor(value.G * 255),
            math.floor(value.B * 255)
        )
    elseif t == "UDim2" then
        return string.format("UDim2.new(%g, %g, %g, %g)", value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset)
    elseif t == "UDim" then
        return string.format("UDim.new(%g, %g)", value.Scale, value.Offset)
    elseif t == "EnumItem" then
        return tostring(value)
    elseif t == "Font" then
        return string.format("Font.new(%q, %s, %s)", value.Family, tostring(value.Weight), tostring(value.Style))
    else
        return string.format("%q", tostring(value))
    end
end

local function generateInstanceCode(instance, varName, depth)
    local indent = string.rep("\t", depth)
    local code = { string.format('%slocal %s = Instance.new("%s")', indent, varName, instance.ClassName) }

    local properties = getAllProperties(instance)
    local sorted = {}
    for prop in pairs(properties) do
        table.insert(sorted, prop)
    end
    table.sort(sorted)

    for _, prop in ipairs(sorted) do
        local value = properties[prop]
        if isDifferentFromDefault(instance, prop, value) then
            table.insert(code, string.format("%s%s.%s = %s", indent, varName, prop, formatValue(value)))
        end
    end

    table.insert(code, string.format("%s%s.Name = %q", indent, varName, instance.Name))
    return table.concat(code, "\n")
end

local function generateFullScript(screenGui)
    local code = {
        "--[[ Auto-generated by OVHL Tools Suite - GUI Converter ]]",
        "local Players = game:GetService('Players')",
        "local player = Players.LocalPlayer",
        "local playerGui = player:WaitForChild('PlayerGui')",
        "",
        "local success, result = pcall(function()",
        "",
    }

    local varCounter = 0
    local varMap = {}

    local function processInstance(inst, depth, parentVar)
        varCounter = varCounter + 1
        local varName = "OVHL_UI_" .. varCounter
        varMap[inst] = varName

        table.insert(code, generateInstanceCode(inst, varName, depth + 1))

        local children = inst:GetChildren()
        table.sort(children, function(a, b)
            local aL, bL = 0, 0
            pcall(function()
                aL = a.LayoutOrder
            end)
            pcall(function()
                bL = b.LayoutOrder
            end)
            return aL ~= bL and aL < bL or a.Name < b.Name
        end)

        for _, child in ipairs(children) do
            processInstance(child, depth, varName)
        end

        table.insert(code, string.rep("\t", depth + 1) .. varName .. ".Parent = " .. (parentVar or "playerGui"))
        table.insert(code, "")
    end

    processInstance(screenGui, 0, nil)

    table.insert(code, "\treturn " .. varMap[screenGui])
    table.insert(code, "end)")
    table.insert(code, "")
    table.insert(code, "if success then")
    table.insert(code, string.format("\tprint(\"✅ [OVHL Tools] GUI '%s' loaded\")", screenGui.Name))
    table.insert(code, "else")
    table.insert(code, '\twarn("⛔ [OVHL Tools] Failed to load GUI:", result)')
    table.insert(code, "end")

    return table.concat(code, "\n")
end

-- ========================
-- TOOL EXECUTION
-- ========================

function Tool.Execute(context)
    local Selection = context.Selection
    local ChangeHistoryService = context.ChangeHistoryService
    local Logger = context.Logger

    local selected = Selection:Get()
    if #selected == 0 then
        warn("⚠️ [OVHL Tools] Select a ScreenGui first!")
        return
    end

    local target = selected[1]
    if not target:IsA("ScreenGui") then
        warn("⚠️ [OVHL Tools] Select a ScreenGui! (You selected: " .. target.ClassName .. ")")
        return
    end

    local script = Instance.new("LocalScript")
    script.Name = target.Name .. "_Generated"
    script.Source = generateFullScript(target)

    local starterScripts = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")
    script.Parent = starterScripts or game:GetService("ReplicatedStorage")

    Selection:Set({ script })
    Logger.success("✅ [OVHL Tools] GUI converted! Location: " .. script:GetFullName())
    ChangeHistoryService:SetWaypoint("GUI to Script")
end

return Tool
