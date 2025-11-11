-- src/Client/Core/Kernel/manifest.lua
-- Phase 4 PostInit untuk AppShell discovery
local ClientKernel = {}
ClientKernel.Modules = {}
local logger

local DISCOVERY_PRIORITY = { "Core", "Services", "OVHL_Modules" }
local INIT_DOMAINS_INTERNAL = { "Core", "Services" }

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SHARED_PATH = ReplicatedStorage:WaitForChild("Shared")

function ClientKernel:GetModule(moduleName)
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

function ClientKernel:GetAllModules()
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

local function initializeDomain(domainFolder, kernel, logger)
    if not domainFolder then return end
    for _, item in ipairs(domainFolder:GetChildren()) do
        local moduleName = item.Name
        local module = kernel.Modules[moduleName]
        if module and module ~= kernel and (not module.IsInitialized) then
            if module.SetKernel then module:SetKernel(kernel) end

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

local function postInitDomain(domainFolder, kernel, logger)
    if not domainFolder then return end
    for _, item in ipairs(domainFolder:GetChildren()) do
        local moduleName = item.Name
        local module = kernel.Modules[moduleName]
        if module and module ~= kernel and type(module.PostInit) == "function" then
            local success, err = pcall(module.PostInit, module)
            if not success then
                logger:Error("Kernel", "SYSTEM", "PHASE 4: Modul " .. moduleName .. " GAGAL di-PostInit!", err)
            end
        end
    end
end

function ClientKernel:Init(configModule, loggerModule)
    logger = loggerModule
    ClientKernel.Modules["Logger"] = logger
    ClientKernel.Modules["Kernel"] = self

    if loggerModule and loggerModule.IsInitialized == nil then
        loggerModule.IsInitialized = true
    end

    logger:Info("Kernel", "SYSTEM", "PHASE 1: Core Boot Selesai.")

    local rootScript = script:FindFirstAncestorOfClass("LocalScript")
    if not rootScript then
        logger:Error("Kernel", "SYSTEM", "PHASE 2: FATAL! Tidak dapat menemukan root 'Client' LocalScript.")
        return
    end

    logger:Info("Kernel", "SYSTEM", "PHASE 2: Module Discovery Dimulai...")

    for _, domainName in ipairs(DISCOVERY_PRIORITY) do
        local domainFolder = rootScript:FindFirstChild(domainName)
        discoverModules(domainFolder, ClientKernel.Modules, logger)
    end

    logger:Info("Kernel", "SYSTEM", "PHASE 2B: Loading Shared Modules...")
    discoverModules(SHARED_PATH, ClientKernel.Modules, logger)

    local sharedModules, internalModules = {}, {}
    for moduleName, module in pairs(ClientKernel.Modules) do
        if moduleName ~= "Kernel" and moduleName ~= "Logger" then
            local isInternal = false
            for _, domainName in ipairs(DISCOVERY_PRIORITY) do
                local domainFolder = rootScript:FindFirstChild(domainName)
                if domainFolder and domainFolder:FindFirstChild(moduleName) then
                    isInternal = true; break;
                end
            end
            if isInternal then table.insert(internalModules, moduleName)
            else table.insert(sharedModules, moduleName) end
        end
    end
    if #internalModules > 0 then logger:Info("Kernel", "SYSTEM", "Internal Modules Loaded: " .. table.concat(internalModules, ", ")) end
    if #sharedModules > 0 then logger:Info("Kernel", "SYSTEM", "Shared Modules Loaded: " .. table.concat(sharedModules, ", "))
    else logger:Warn("Kernel", "SYSTEM", "Tidak ada Shared modules yang ter-load!") end

    logger:Info("Kernel", "SYSTEM", "PHASE 2: Module Discovery Selesai.")
    logger:Info("Kernel", "SYSTEM", "PHASE 3: Inisialisasi Dimulai (Urutan Diperbaiki)...")

    for _, domainName in ipairs(INIT_DOMAINS_INTERNAL) do
        local domainFolder = rootScript:FindFirstChild(domainName)
        logger:Debug("Kernel", "SYSTEM", "PHASE 3: Initializing Domain " .. domainName)
        initializeDomain(domainFolder, self, logger)
    end

    logger:Debug("Kernel", "SYSTEM", "PHASE 3: Initializing Domain Shared")
    initializeDomain(SHARED_PATH, self, logger)

    local ovhlFolder = rootScript:FindFirstChild("OVHL_Modules")
    logger:Debug("Kernel", "SYSTEM", "PHASE 3: Initializing Domain OVHL_Modules")
    initializeDomain(ovhlFolder, self, logger)

    logger:Info("Kernel", "SYSTEM", "PHASE 3: Inisialisasi Selesai.")

    logger:Info("Kernel", "SYSTEM", "PHASE 4: PostInit Dimulai (Late Discovery)...")

    for _, domainName in ipairs({"Services"}) do
        local domainFolder = rootScript:FindFirstChild(domainName)
        postInitDomain(domainFolder, self, logger)
    end

    logger:Info("Kernel", "SYSTEM", "PHASE 4: PostInit Selesai. Client Siap.")
end

return ClientKernel
