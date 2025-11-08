-- Server Kernel (Fixed Module Discovery)

local ServerKernel = {}
ServerKernel.Modules = {}

function ServerKernel:GetModule(moduleName)
    local module = self.Modules[moduleName]
    if not module then
        warn("[KERNEL] Module not found:", moduleName)
    end
    return module
end

print("🖥️ 🚀 [KERNEL] Booting Server Kernel...")

-- === PHASE 1: CORE BOOT ===
local Logger = require(script.Logger)
ServerKernel.Modules["Logger"] = Logger
local Config = require(script.Config)
ServerKernel.Modules["Config"] = Config
print("🖥️ ✅ [KERNEL] Core: Logger, Config")

-- === PHASE 2: MODULE DISCOVERY ===
local DOMAIN_FOLDERS = { "Core", "Services", "Business" }
local loadedModules = {}

for _, domainFolder in ipairs(DOMAIN_FOLDERS) do
    local domain = script:FindFirstChild(domainFolder)
    if not domain then
        warn("🖥️ ❌ [KERNEL] Domain folder not found:", domainFolder)
        continue
    end

    -- Scan for module folders
    for _, item in ipairs(domain:GetChildren()) do
        if item:IsA("Folder") then
            local initScript = item:FindFirstChild("init")
            if initScript and initScript:IsA("ModuleScript") then
                local moduleName = item.Name
                local success, module = pcall(require, initScript)
                if success then
                    ServerKernel.Modules[moduleName] = module
                    table.insert(loadedModules, moduleName)
                    print("🖥️ ✅ [KERNEL] Loaded: " .. moduleName .. " (" .. domainFolder .. ")")
                else
                    warn("🖥️ ❌ [KERNEL] Failed to load: " .. moduleName .. " - " .. tostring(module))
                end
            end
        end
    end
end

-- Print module summary
if #loadedModules > 0 then
    print("🖥️ 📦 [KERNEL] Modules: " .. table.concat(loadedModules, ", "))
else
    print("🖥️ 📦 [KERNEL] No additional modules loaded")
end

-- === PHASE 3: INITIALIZATION ===
local initSuccess = 0
local initFailed = 0

-- Set Config in Logger first
Logger:SetConfig(Config)

-- Initialize modules
for name, module in pairs(ServerKernel.Modules) do
    if type(module) == "table" and type(module.Init) == "function" then
        local success, err = pcall(module.Init, module)
        if success then
            initSuccess = initSuccess + 1
        else
            initFailed = initFailed + 1
            warn("🖥️ ❌ [KERNEL] Init failed: " .. name .. " - " .. tostring(err))
        end
    end
end

local totalModules = #loadedModules + 2 -- +2 for Logger and Config
print("🖥️ 🎉 [KERNEL] Boot Complete! Total: " .. totalModules .. " | Init: " .. initSuccess .. "✓ " .. initFailed .. "✗")

return ServerKernel
