-- Shared Kernel (3-Phase Loading System)

local SharedKernel = {}
SharedKernel.Modules = {}

function SharedKernel:GetModule(moduleName)
    local module = self.Modules[moduleName]
    if not module then
        warn("[SHARED KERNEL] Module not found:", moduleName)
    end
    return module
end

-- === PHASE 1: CORE BOOT ===
-- Load Theme first (foundation for all UI)
local Theme = require(script.Theme)
SharedKernel.Modules["Theme"] = Theme

-- === PHASE 2: MODULE DISCOVERY ===
local MODULE_FOLDERS = { "Network", "OVHL_UI", "TextFilter" }

for _, folderName in ipairs(MODULE_FOLDERS) do
    local folder = script:FindFirstChild(folderName)
    if not folder then continue end

    for _, item in ipairs(folder:GetChildren()) do
        if item:IsA("ModuleScript") and item.Name == "init" then
            local moduleName = folderName
            local success, module = pcall(require, item)
            if success then
                SharedKernel.Modules[moduleName] = module
                print("[SHARED KERNEL] Loaded module:", moduleName)
            else
                warn("[SHARED KERNEL] Failed to load module:", moduleName, module)
            end
        end
    end
end

-- === PHASE 3: INITIALIZATION ===
for name, module in pairs(SharedKernel.Modules) do
    if type(module) == "table" and type(module.Init) == "function" then
        local success, err = pcall(module.Init, module)
        if not success then
            warn("[SHARED KERNEL] Failed to initialize module:", name, err)
        else
            print("[SHARED KERNEL] Initialized module:", name)
        end
    end
end

print("🔗 📢 [SHARED KERNEL] Shared Kernel Boot Complete!")
return SharedKernel
