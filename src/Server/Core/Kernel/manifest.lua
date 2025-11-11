local ServerKernel = {}
ServerKernel.Modules = {}
local logger, config

local DISCOVERY_PRIORITY = { "Core", "Services", "OVHL_Modules" }
local INIT_DOMAINS_INTERNAL = { "Core", "Services" }

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SHARED_PATH = ReplicatedStorage:WaitForChild("Shared")

function ServerKernel:GetModule(moduleName)
    local module = self.Modules[moduleName]
    if not module then
        if logger then
            logger:Warn("Kernel", "SYSTEM", "Module not found: " .. moduleName)
        else
            warn("Kernel: Module not found (logger not yet available): " .. moduleName)
        end
    end
    return module
end

function ServerKernel:GetAllModules()
    return self.Modules
end

local function discoverModules(path, kernelModules, logger)
    if not path then return end
    for _, item in ipairs(path:GetChildren()) do
        if item:IsA("Folder") then
            local manifestFile = item:FindFirstChild("manifest")
            if manifestFile and manifestFile:IsA("ModuleScript") then
                local moduleName = item.Name
                if kernelModules[moduleName] then continue end
                local success, module = pcall(require, manifestFile)
                if success then
                    -- 🎯 MUAT CONFIG DI SINI (JIKA ADA)
                    local configPath = manifestFile.Parent:FindFirstChild("config")
                    if configPath and configPath:IsA("ModuleScript") then
                        local configSuccess, moduleConfig = pcall(require, configPath)
                        if configSuccess then
                            module.config = moduleConfig
                        else
                             if logger then logger:Warn("Kernel", "CONFIG", "Gagal require config untuk " .. moduleName) end
                        end
                    end

                    kernelModules[moduleName] = module
                    if logger then
                        logger:Debug("Kernel", "SYSTEM", "Modul " .. moduleName .. " di-load dari " .. path.Name)
                    end
                else
                    if logger then
                        logger:Error("Kernel", "SYSTEM", "PHASE 2: Modul " .. moduleName .. " GAGAL di-load!", module)
                    end
                end
            end
        end
    end
end

-- Fungsi helper untuk Init
local function initializeDomain(domainFolder, kernel, logger)
    if not domainFolder then return end
    for _, item in ipairs(domainFolder:GetChildren()) do
        local moduleName = item.Name
        local module = kernel.Modules[moduleName]
        if module and module ~= kernel and (not module.IsInitialized) then
            if module.SetKernel then module:SetKernel(kernel) end

            -- 🎯 LOGIC BARU: Registrasi Log Level
            if module.config and module.config.debug and module.config.debug.log_level then
                logger:SetModuleLogLevel(moduleName, module.config.debug.log_level)
            end

            if type(module.Init) == "function" then
               local success, err = pcall(module.Init, module)
               if not success then
                    logger:Error("Kernel", "SYSTEM", "PHASE 3: Modul " .. moduleName .. " GAGAL di-Init!", err)
               end
               module.IsInitialized = true
            end
        end
    end
end

function ServerKernel:Init(configModule, loggerModule)
    config = configModule
    logger = loggerModule
    ServerKernel.Modules["Config"] = config
    ServerKernel.Modules["Logger"] = logger
    ServerKernel.Modules["Kernel"] = self

    if loggerModule.IsInitialized == nil then
        loggerModule.IsInitialized = true
    end

    logger:Info("Kernel", "SYSTEM", "PHASE 1: Core Boot Selesai.")
    local rootScript = script:FindFirstAncestorOfClass("Script")
    if not rootScript then
        logger:Error("Kernel", "SYSTEM", "PHASE 2: FATAL! Tidak dapat menemukan root 'Server' Script.")
        return
    end

    logger:Info("Kernel", "SYSTEM", "PHASE 2: Module Discovery Dimulai...")

    -- PHASE 2A: Load Internal Domains
    for _, domainName in ipairs(DISCOVERY_PRIORITY) do
        local domainFolder = rootScript:FindFirstChild(domainName)
        discoverModules(domainFolder, ServerKernel.Modules, logger)
    end

    -- PHASE 2B: Load Shared Modules
    logger:Info("Kernel", "SYSTEM", "PHASE 2B: Loading Shared Modules...")
    discoverModules(SHARED_PATH, ServerKernel.Modules, logger)

    logger:Info("Kernel", "SYSTEM", "PHASE 2: Module Discovery Selesai.")
    logger:Info("Kernel", "SYSTEM", "PHASE 3: Inisialisasi Dimulai (Urutan Diperbaiki)...")

    -- 1. Init Core & Services
    for _, domainName in ipairs(INIT_DOMAINS_INTERNAL) do
        local domainFolder = rootScript:FindFirstChild(domainName)
        logger:Debug("Kernel", "SYSTEM", "PHASE 3: Initializing Domain " .. domainName)
        initializeDomain(domainFolder, self, logger)
    end

    -- 2. Init Shared
    logger:Debug("Kernel", "SYSTEM", "PHASE 3: Initializing Domain Shared")
    initializeDomain(SHARED_PATH, self, logger)

    -- 3. Init OVHL_Modules
    local ovhlFolder = rootScript:FindFirstChild("OVHL_Modules")
    logger:Debug("Kernel", "SYSTEM", "PHASE 3: Initializing Domain OVHL_Modules")
    initializeDomain(ovhlFolder, self, logger)

    logger:Info("Kernel", "SYSTEM", "PHASE 3: Inisialisasi Selesai. Server Siap.")
end

return ServerKernel
