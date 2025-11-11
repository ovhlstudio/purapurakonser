# 🛠️ OVHL Tools Suite - Developer Documentation

**Created by:** Omniverse Highland Studio  
**Version:** 2.0 - Modular Architecture  
**License:** MIT

---

## 📦 What is OVHL Tools Suite?

OVHL Tools Suite is a **modular plugin system** for Roblox Studio that provides a collection of productivity tools for developers. The plugin features a modern dashboard UI with sidebar navigation and supports easy addition of new tools.

### Current Tools:

1. **🎨 GUI to Script Converter** - Convert ScreenGui to 100% accurate Lua code
2. **📸 Project Snapshot Exporter** - Export project tree + source code for AI assistance

---

## 🏗️ Architecture Overview

### File Structure:

```
📁 OVHLToolsSuite (Plugin Script)
  ├── 📄 Main.lua (Dashboard + Tool Loader)
  └── 📁 Tools (Folder)
      ├── 📦 GUIConverter.lua (ModuleScript)
      ├── 📦 SnapshotExporter.lua (ModuleScript)
      └── 📦 YourNewTool.lua (Add your own!)
```

### How It Works:

1. **Main.lua** creates the dashboard UI
2. **Tool Loader** automatically scans the `Tools/` folder
3. Each **ModuleScript** in `Tools/` = 1 tool in the dashboard
4. Tools are displayed as cards with execute buttons
5. No need to modify Main.lua when adding new tools!

---

## 🚀 How to Add a New Tool

### Step 1: Create ModuleScript

1. Open the plugin in Roblox Studio
2. Find `Main > Tools` folder
3. Create new **ModuleScript** inside `Tools/`
4. Name it whatever you want (e.g., `TemplateGenerator`)

### Step 2: Use the Tool Template

```lua
--[[
    Your Tool Name
    OVHL Tools Suite - Modular Tool

    Brief description of what this tool does
]]

local Tool = {}

-- ========================
-- TOOL METADATA (REQUIRED)
-- ========================

Tool.Name = "Your Tool Name"              -- Displayed in dashboard
Tool.Description = "What your tool does"  -- Card description
Tool.Icon = "🔧"                          -- Emoji icon
Tool.IconType = "emoji"                   -- "emoji" or "image"
Tool.ButtonText = "Execute Tool"          -- Button text
Tool.Order = 3                            -- Display order (lower = higher)

-- Optional: Use custom image icon instead of emoji
-- Tool.IconType = "image"
-- Tool.Icon = "rbxassetid://123456789"

-- ========================
-- TOOL LOGIC
-- ========================

-- Your helper functions here
local function yourHelperFunction()
    -- Your code
end

-- ========================
-- TOOL EXECUTION (REQUIRED)
-- ========================

function Tool.Execute(context)
    -- Context provides access to:
    -- context.plugin          - Plugin instance
    -- context.Selection       - game:GetService("Selection")
    -- context.ChangeHistoryService - For undo/redo
    -- context.Logger          - Logger.success(), Logger.warn(), Logger.log()

    local Selection = context.Selection
    local Logger = context.Logger

    -- Your tool logic here
    local selected = Selection:Get()

    if #selected == 0 then
        warn("⚠️ [OVHL Tools] Please select something first!")
        return
    end

    -- Do your thing...
    Logger.success("✅ [OVHL Tools] Tool executed successfully!")

    -- Optional: Create undo waypoint
    context.ChangeHistoryService:SetWaypoint("Your Tool Action")
end

-- ========================
-- RETURN MODULE (REQUIRED)
-- ========================

return Tool
```

### Step 3: Save and Reload

1. Save your ModuleScript
2. Reopen the OVHL Tools dashboard
3. Your tool will automatically appear!

---

## 📋 Tool Metadata Reference

### Required Fields:

| Field         | Type     | Description                      |
| ------------- | -------- | -------------------------------- |
| `Name`        | string   | Tool name displayed in dashboard |
| `Description` | string   | Brief description shown on card  |
| `Icon`        | string   | Emoji (🔧) or asset ID           |
| `IconType`    | string   | `"emoji"` or `"image"`           |
| `ButtonText`  | string   | Text on execute button           |
| `Execute`     | function | Main tool function               |

### Optional Fields:

| Field   | Type   | Default | Description                   |
| ------- | ------ | ------- | ----------------------------- |
| `Order` | number | 999     | Display order (lower = first) |

---

## 🎨 Icon System

### Using Emoji Icons (Recommended):

```lua
Tool.Icon = "🎨"
Tool.IconType = "emoji"
```

### Using Image Icons:

```lua
Tool.Icon = "rbxassetid://123456789"
Tool.IconType = "image"
```

**Note:** Make sure the asset is accessible in Roblox!

---

## 🔧 Context API Reference

When your tool executes, it receives a `context` table with these services:

### context.plugin

The plugin instance itself. Use for creating widgets, toolbars, etc.

```lua
local widget = context.plugin:CreateDockWidgetPluginGui(...)
```

### context.Selection

Roblox Selection service.

```lua
local selected = context.Selection:Get()
context.Selection:Set({object})
```

### context.ChangeHistoryService

For undo/redo support.

```lua
context.ChangeHistoryService:SetWaypoint("Action Name")
```

### context.Logger

Logging system with 3 levels:

```lua
context.Logger.success("✅ Success message")  -- Always shows
context.Logger.warn("⚠️ Warning message")     -- Shows if DEBUG_MODE
context.Logger.log("📝 Debug message")        -- Shows if DEBUG_MODE
```

**Tip:** Use `Logger.success()` for important user-facing messages!

---

## 📝 Best Practices

### ✅ DO:

-   Use descriptive tool names
-   Provide clear error messages
-   Use Logger.success() for completion messages
-   Set ChangeHistoryService waypoints for undoable actions
-   Validate user input before processing
-   Use emoji icons for quick visual identification

### ❌ DON'T:

-   Print spam to output (respect DEBUG_MODE)
-   Forget to validate Selection:Get()
-   Use blocking operations (use pcall for safety)
-   Modify Main.lua unless absolutely necessary

---

## 🐛 Debugging

### Enable Debug Mode:

In `Main.lua`, set:

```lua
local DEBUG_MODE = true
```

This will show all `Logger.log()` and `Logger.warn()` calls.

### Common Issues:

**Tool not appearing?**

-   Check if ModuleScript is in `Tools/` folder
-   Verify module returns a table with required fields
-   Check Output for error messages

**Tool executes but nothing happens?**

-   Enable DEBUG_MODE to see detailed logs
-   Wrap your code in pcall() to catch errors
-   Check if you're using context services correctly

---

## 🎯 Example Tool Ideas

Here are some tool ideas you can implement:

1. **📋 Script Template Generator**

    - Create boilerplate code for common patterns
    - ModuleScript, RemoteEvent handlers, etc.

2. **🔍 Dependency Finder**

    - Find all `require()` calls in project
    - Map module dependencies

3. **📊 Code Statistics**

    - Count total lines of code
    - Show breakdown by file type

4. **🧹 Unused Script Finder**

    - Detect scripts that aren't referenced

5. **🔄 Batch Rename Tool**

    - Rename multiple objects with patterns

6. **📝 Comment Generator**

    - Auto-add documentation headers

7. **🎯 Quick Actions**
    - Common folder structure creation
    - Asset organization tools

---

## 🤝 Contributing

Want to share your tools with the community?

1. Create your tool following this guide
2. Test it thoroughly
3. Share the ModuleScript code
4. Others can drop it into their `Tools/` folder!

---

## 📄 License

MIT License - Feel free to modify and distribute!

---

## 💬 Support

If you need help or have questions:

1. Check this README first
2. Enable DEBUG_MODE to see detailed logs
3. Verify your tool structure matches the template
4. Ask your friendly AI assistant! 🤖

---

**Happy Coding! 🚀**  
_- Omniverse Highland Studio_
