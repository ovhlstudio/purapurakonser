--[[
    Tool Name Here
    OVHL Tools Suite - Modular Tool

    Brief description of what this tool does.
    Add more details if needed.
]]

local Tool = {}

-- ========================
-- TOOL METADATA (REQUIRED)
-- ========================

Tool.Name = "Your Tool Name"
Tool.Description = "Brief description shown in dashboard card"
Tool.Icon = "🔧" -- Emoji icon (or use rbxassetid for image)
Tool.IconType = "emoji" -- "emoji" or "image"
Tool.ButtonText = "Execute"
Tool.Order = 3 -- Display order (lower number = appears first)

-- Optional: Use custom image icon
-- Tool.IconType = "image"
-- Tool.Icon = "rbxassetid://123456789"

-- ========================
-- HELPER FUNCTIONS
-- ========================

-- Add your private helper functions here
local function helperFunction1()
    -- Your code
end

local function helperFunction2()
    -- Your code
end

-- ========================
-- TOOL EXECUTION (REQUIRED)
-- ========================

--[[
    Main execution function called when user clicks the button

    @param context - Table containing plugin services:
        - context.plugin: Plugin instance
        - context.Selection: Selection service
        - context.ChangeHistoryService: For undo/redo
        - context.Logger: Logging system
            - Logger.success(msg) - Always shows
            - Logger.warn(msg) - Shows if DEBUG_MODE
            - Logger.log(msg) - Shows if DEBUG_MODE
]]
function Tool.Execute(context)
    -- Extract services from context
    local plugin = context.plugin
    local Selection = context.Selection
    local ChangeHistoryService = context.ChangeHistoryService
    local Logger = context.Logger

    -- Example: Get selected objects
    local selected = Selection:Get()

    if #selected == 0 then
        warn("⚠️ [OVHL Tools] Please select something first!")
        return
    end

    -- Your tool logic here
    -- ...

    -- Example: Success message
    Logger.success("✅ [OVHL Tools] Tool executed successfully!")

    -- Optional: Create undo waypoint
    ChangeHistoryService:SetWaypoint("Your Tool Action")
end

-- ========================
-- RETURN MODULE (REQUIRED)
-- ========================

return Tool
