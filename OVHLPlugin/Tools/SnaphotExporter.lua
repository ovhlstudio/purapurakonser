--[[
    Project Snapshot Exporter V2
    OVHL Tools Suite - Modular Tool

    Export folder tree + source code for AI assistance
]]

local Tool = {}

-- ========================
-- TOOL METADATA
-- ========================

Tool.Name = "Project Snapshot Exporter"
Tool.Description = "Export folder tree + source code for AI (supports multiple selection)"
Tool.IconType = "image"
Tool.Icon = "rbxassetid://102193205434613"
Tool.ButtonText = "Export Snapshot" -- ✅ SUDAH DIPERBAIKI
Tool.Order = 3

-- ========================
-- TOOL LOGIC
-- ========================

local function isScriptType(inst)
    return inst:IsA("Script") or inst:IsA("LocalScript") or inst:IsA("ModuleScript")
end

-- ✅ FUNGSI GENERATE TREE DENGAN GARIS
local function generateTree(inst, depth, output, isLast)
    local indent = ""
    if depth > 0 then
        if isLast then
            indent = string.rep("  ", depth - 1) .. "└── "
        else
            indent = string.rep("  ", depth - 1) .. "├── "
        end
    end

    local icons = {
        Script = "🔧",
        LocalScript = "🎮",
        ModuleScript = "📦",
        ScreenGui = "🖼️",
        Model = "🏗️",
        Part = "🧱",
        Folder = "📂",
        RemoteEvent = "🔌",
        RemoteFunction = "🔌",
    }
    local icon = icons[inst.ClassName] or "📁"

    table.insert(output, indent .. icon .. " " .. inst.Name)

    local children = inst:GetChildren()
    table.sort(children, function(a, b)
        return a.Name < b.Name
    end)

    for i, child in ipairs(children) do
        generateTree(child, depth + 1, output, i == #children)
    end
end

local function extractScripts(inst, scripts)
    if isScriptType(inst) then
        local ok, src = pcall(function()
            return inst.Source
        end)
        if ok and src ~= "" then
            table.insert(scripts, {
                path = inst:GetFullName(),
                name = inst.Name,
                type = inst.ClassName,
                source = src,
            })
        end
    end
    for _, child in ipairs(inst:GetChildren()) do
        extractScripts(child, scripts)
    end
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
        warn("⚠️ [OVHL Tools] Select folder(s) first!")
        warn("💡 Tip: Select ServerScriptService, ReplicatedStorage, or any folder")
        return
    end

    local output = {
        "# 🎮 Roblox Project Snapshot",
        "",
        "**Generated:** " .. os.date("%Y-%m-%d %H:%M:%S"),
        "**Targets:** " .. #selected .. " folder(s)",
        "**Tool:** OVHL Tools Suite - Snapshot Exporter",
        "",
        "---",
    }

    local allScripts = {}

    for _, target in ipairs(selected) do
        table.insert(output, "")
        table.insert(output, "## 📊 " .. target:GetFullName())
        table.insert(output, "")
        table.insert(output, "```")

        local tree = {}
        generateTree(target, 0, tree, true) -- ✅ PAKAI FUNGSI TREE BARU
        for _, line in ipairs(tree) do
            table.insert(output, line)
        end
        table.insert(output, "```")

        extractScripts(target, allScripts)
    end

    table.insert(output, "")
    table.insert(output, "---")
    table.insert(output, "")
    table.insert(output, "## 💻 Source Code")
    table.insert(output, "")

    if #allScripts > 0 then
        table.sort(allScripts, function(a, b)
            return a.path < b.path
        end)

        table.insert(output, string.format("**Total Scripts Found:** %d", #allScripts))
        table.insert(output, "")

        for i, s in ipairs(allScripts) do
            table.insert(output, string.format("### %d. %s", i, s.name))
            table.insert(output, string.format("**Type:** `%s`", s.type))
            table.insert(output, string.format("**Path:** `%s`", s.path))
            table.insert(output, "")
            table.insert(output, "```lua")
            table.insert(output, s.source)
            table.insert(output, "```")
            table.insert(output, "")
        end
    else
        table.insert(output, "*No scripts found.*")
        table.insert(output, "")
    end

    table.insert(output, "---")
    table.insert(output, "")
    table.insert(output, "## 📝 How to Use with AI")
    table.insert(output, "")
    table.insert(output, "1. Paste this entire snapshot to your AI assistant")
    table.insert(output, "2. Ask questions like:")
    table.insert(output, '   - "Analyze this folder structure"')
    table.insert(output, '   - "Find potential bugs in [script name]"')
    table.insert(output, '   - "Suggest improvements for [feature]"')
    table.insert(output, '   - "Help me refactor [script name]"')
    table.insert(output, "")

    local snapshot = table.concat(output, "\n")
    local sizeKB = #snapshot / 1024

    if #snapshot >= 200000 then
        warn("⚠️ [OVHL Tools] Snapshot too large! (" .. string.format("%.1f", sizeKB) .. " KB)")
        warn("💡 Tip: Select smaller folders or subfolders")
        return
    end

    local names = {}
    for _, f in ipairs(selected) do
        table.insert(names, f.Name)
    end
    local combinedName = table.concat(names, "+")
    if #combinedName > 50 then
        combinedName = #selected .. "folders"
    end

    local script = Instance.new("Script")
    script.Name = "SNAPSHOT_" .. combinedName .. "_" .. os.date("%H%M%S")
    script.Source = snapshot
    script.Parent = game:GetService("ReplicatedStorage")

    Selection:Set({ script })
    Logger.success(string.format("✅ [OVHL Tools] Snapshot generated! %.1f KB", sizeKB))
    Logger.success("📁 Location: " .. script:GetFullName())
    Logger.success("💡 Tip: Open script → Ctrl+A → Ctrl+C → paste to AI")
    ChangeHistoryService:SetWaypoint("Snapshot Export")
end

return Tool
