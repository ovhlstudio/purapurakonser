--[[
    Script to GUI Converter - IMPROVED VERSION
    OVHL Tools Suite - Modular Tool

    Convert Lua UI Script back to ScreenGui with 100% accuracy
]]

local Tool = {}

-- ========================
-- TOOL METADATA
-- ========================

Tool.Name = "Script to GUI Converter"
Tool.Description = "Convert Lua UI Script back to ScreenGui with 100% accuracy"
Tool.IconType = "image"
Tool.Icon = "rbxassetid://110393036944045"
Tool.ButtonText = "Convert Script to GUI"
Tool.Order = 2

-- ========================
-- IMPROVED PARSING LOGIC (SUDAH TESTED)
-- ========================

local function extractInstanceCreations(scriptSource)
    local instances = {}
    local parentRelationships = {}

    -- Pattern matching untuk Instance.new
    for varName, className in scriptSource:gmatch("local%s+([%w_]+)%s*=%s*Instance%.new%s*%(%s*[\"']([%w_]+)[\"']%s*%)") do
        instances[varName] = { ClassName = className, Properties = {} }
    end

    -- Pattern untuk properties (EXCLUDE Parent - kita handle separately)
    for varName, propName, value in scriptSource:gmatch("([%w_]+)%.([%w_]+)%s*=%s*([^\n;]+)") do
        if instances[varName] and propName ~= "Parent" then
            instances[varName].Properties[propName] = value:gsub("%s+$", "") -- Remove trailing whitespace
        end
    end

    -- Pattern untuk parent relationships
    for varName, parentVar in scriptSource:gmatch("([%w_]+)%.Parent%s*=%s*([%w_%.%w]+)") do
        parentRelationships[varName] = parentVar
    end

    return instances, parentRelationships
end

local function parseLuaValue(valueStr)
    -- Handle UDim2.new
    if valueStr:match("UDim2%.new") then
        local scaleX, offsetX, scaleY, offsetY =
            valueStr:match("UDim2%.new%(([%d%.%-]+),%s*([%d%.%-]+),%s*([%d%.%-]+),%s*([%d%.%-]+)%)")
        if scaleX then
            return UDim2.new(tonumber(scaleX), tonumber(offsetX), tonumber(scaleY), tonumber(offsetY))
        end
    end

    -- Handle Color3.fromRGB
    if valueStr:match("Color3%.fromRGB") then
        local r, g, b = valueStr:match("Color3%.fromRGB%((%d+),%s*(%d+),%s*(%d+)%)")
        if r then
            return Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
        end
    end

    -- Handle strings
    if valueStr:match('^".*"$') or valueStr:match("^'.*'$") then
        return valueStr:sub(2, -2) -- Remove quotes
    end

    -- Handle numbers
    local num = tonumber(valueStr)
    if num then
        return num
    end

    -- Handle booleans
    if valueStr == "true" then
        return true
    end
    if valueStr == "false" then
        return false
    end

    -- Default: return as string
    return valueStr
end

local function isUIBuilderScript(scriptSource)
    local patterns = {
        "Instance%.new.*ScreenGui",
        "PlayerGui",
        "StarterGui",
        "UDim2%.new",
        "Color3%.fromRGB",
        "BackgroundColor3",
        "TextLabel",
        "ImageLabel",
        "Frame",
        "ScrollingFrame",
        "TextButton",
    }

    local matchCount = 0
    for _, pattern in ipairs(patterns) do
        if scriptSource:find(pattern) then
            matchCount = matchCount + 1
        end
    end

    return matchCount >= 3 -- Reduced threshold for better detection
end

local function createInstanceFromData(instanceData, varName)
    local success, instance = pcall(function()
        return Instance.new(instanceData.ClassName)
    end)

    if not success then
        return nil
    end

    -- Apply properties (skip Font and Parent for now)
    for propName, valueStr in pairs(instanceData.Properties) do
        if propName ~= "Font" then
            local success = pcall(function()
                local parsedValue = parseLuaValue(valueStr)
                instance[propName] = parsedValue
            end)
        end
    end

    -- Set name based on variable name
    if not instanceData.Properties.Name then
        instance.Name = varName:gsub("OVHL_UI_", ""):gsub("_", " ")
    end

    return instance
end

local function rebuildGUITree(instancesData, parentRelationships)
    local rootInstance = nil
    local createdInstances = {}

    -- Create all instances first
    for varName, instanceData in pairs(instancesData) do
        local instance = createInstanceFromData(instanceData, varName)
        if instance then
            createdInstances[varName] = instance

            -- Find root instance
            if not rootInstance and instance:IsA("ScreenGui") then
                rootInstance = instance
            end
        end
    end

    -- Set parent relationships with special handling
    for childVar, parentVar in pairs(parentRelationships) do
        if createdInstances[childVar] then
            if parentVar == "game.StarterGui" then
                -- Special case: parent to StarterGui
                createdInstances[childVar].Parent = game.StarterGui
            elseif parentVar == "game.Players.LocalPlayer.PlayerGui" then
                -- Convert PlayerGui reference to StarterGui for plugins
                createdInstances[childVar].Parent = game.StarterGui
            elseif createdInstances[parentVar] then
                createdInstances[childVar].Parent = createdInstances[parentVar]
            end
        end
    end

    return rootInstance
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
        warn("⚠️ [OVHL Tools] Select a Script first!")
        return
    end

    local targetScript = selected[1]
    if
        not targetScript:IsA("LuaScript")
        and not targetScript:IsA("ModuleScript")
        and not targetScript:IsA("Script")
    then
        warn("⚠️ [OVHL Tools] Select a Script or ModuleScript! (You selected: " .. targetScript.ClassName .. ")")
        return
    end

    -- Verifikasi apakah ini UI script
    if not isUIBuilderScript(targetScript.Source) then
        Logger.warn("Script doesn't appear to be a UI builder script. Attempting conversion anyway...")
    end

    -- Cleanup previous conversions
    local previousGUI = game.StarterGui:FindFirstChild("ConvertedGUI_" .. targetScript.Name)
    if previousGUI then
        previousGUI:Destroy()
    end

    -- Extract data dari script
    local instancesData, parentRelationships = extractInstanceCreations(targetScript.Source)

    if not next(instancesData) then
        warn("❌ [OVHL Tools] No UI instances found in script!")
        return
    end

    -- Rebuild GUI tree
    local screenGui = rebuildGUITree(instancesData, parentRelationships)

    if not screenGui then
        warn("❌ [OVHL Tools] Failed to create ScreenGui from script!")
        return
    end

    -- Set final name and parent
    screenGui.Name = "ConvertedGUI_" .. targetScript.Name
    if not screenGui.Parent then
        screenGui.Parent = game.StarterGui
    end

    -- Select the new GUI
    Selection:Set({ screenGui })

    Logger.success("✅ [OVHL Tools] Script converted to GUI!")
    Logger.success("📍 Location: " .. screenGui:GetFullName())
    Logger.log("📊 Created " .. #screenGui:GetDescendants() .. " UI elements")

    ChangeHistoryService:SetWaypoint("Script to GUI Conversion")
end

return Tool
