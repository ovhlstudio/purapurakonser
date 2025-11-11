-- Client/Core/UIManager/manifest.lua
-- 🎯 PERBAIKAN: Ensure Root is correctly assigned + Debug logging
local UIManager = {}
local logger, config, kernel, ovhlUI

local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

function UIManager:SetKernel(k)
    kernel = k
end

function UIManager:Init()
    logger = kernel:GetModule("Logger")
    ovhlUI = kernel:GetModule("OVHL_UI")

    local configPath = script.Parent:FindFirstChild("config")
    local success, internalConfig = pcall(require, configPath)

    if success then
        config = internalConfig
    else
        logger:Error("UIManager", "CONFIG", "Gagal memuat config.lua internal!", internalConfig)
        config = { component_registry = {} }
    end

    logger:Info("UIManager", "CORE", "Smart UI Manager V2 (Precise) Initialized")
end

function UIManager:SetupModuleUI(moduleName, moduleConfig)
    local uiMode = moduleConfig.ui.mode or "OVHL_UI"
    local screenGuiName = moduleConfig.ui.screen_gui or moduleName .. "Panel"

    logger:Info("UIManager", "UI",
        "Setting up UI for " .. moduleName .. " | Mode: " .. uiMode .. " | Screen: " .. screenGuiName)

    if uiMode == "OVHL_UI" then
        return self:SetupOVHLUI(moduleName, moduleConfig)
    else
        return self:SetupStarterGui(moduleName, screenGuiName, moduleConfig)
    end
end

function UIManager:SetupStarterGui(moduleName, screenGuiName, moduleConfig)
    logger:Debug("UIManager", "UI", "Mode StarterGui: Mencari " .. screenGuiName .. " di PlayerGui...")

    local screenGui = PlayerGui:WaitForChild(screenGuiName, 10)

    if not screenGui then
        logger:Error("UIManager", "FATAL", "ScreenGui '" .. screenGuiName .. "' tidak ditemukan di PlayerGui setelah 10 detik!")
        return nil
    end

    logger:Info("UIManager", "UI", "ScreenGui '" .. screenGuiName .. "' ditemukan. Memulai component discovery...")

    local expectedComponents = moduleConfig.ui and moduleConfig.ui.components
    if not expectedComponents then
         logger:Warn("UIManager", "CONFIG", "Module " .. moduleName .. " tidak memiliki 'ui.components' di config.")
         expectedComponents = {}
    end

    local discovered = self:DiscoverComponents(screenGui, expectedComponents)

    -- 🎯 CRITICAL FIX: Ensure Root is the ScreenGui itself
    local uiInstance = {
        Name = screenGuiName,
        Root = screenGui,  -- ✅ This MUST be the ScreenGui instance
        Components = discovered,

        update = function(data)
            logger:Debug("UIManager", "UPDATE", "uiInstance:update() dipanggil untuk " .. moduleName, data)
        end
    }

    -- 🎯 DEBUG LOG: Verify Root assignment
    logger:Debug("UIManager", "DEBUG",
        "UIInstance created for " .. moduleName ..
        " | Root: " .. uiInstance.Root.Name ..
        " | Root.ClassName: " .. uiInstance.Root.ClassName ..
        " | Root.Enabled: " .. tostring(uiInstance.Root.Enabled))

    return uiInstance
end

function UIManager:SetupOVHLUI(moduleName, moduleConfig)
    if not ovhlUI then
        logger:Error("UIManager", "FATAL", "Mode OVHL_UI dipilih, tapi modul OVHL_UI tidak ditemukan!")
        return nil
    end
    logger:Info("UIManager", "UI", "Mode OVHL_UI: Merender UI untuk " .. moduleName .. "...")
    local stub = { Name = moduleName .. "_OVHL_Panel", Components = {}, update = function() end }
    logger:Warn("UIManager", "STUB", "OVHL_UI rendering belum diimplementasi (Fase 3).")
    local expectedComponents = moduleConfig.ui and moduleConfig.ui.components or {}
    self:ValidateComponents(stub.Components, expectedComponents)
    return stub
end

function UIManager:DiscoverComponents(screenGui, expectedComponents)
    local discovered = {}
    local componentRegistry = self:GetComponentRegistry()

    if not componentRegistry then
        logger:Error("UIManager", "DISCOVERY", "Kamus (Registry) UIManager kosong! Tidak bisa menemukan komponen.")
        return discovered
    end

    for logicalName, expectedType in pairs(expectedComponents) do
        local componentName = componentRegistry[logicalName]

        if componentName then
            local instance = screenGui:FindFirstChild(componentName, true)

            if instance then
                if instance:IsA(expectedType) then
                    logger:Debug("UIManager", "DISCOVERY", "Ditemukan: '" .. logicalName .. "' -> " .. instance:GetFullName())
                    discovered[logicalName] = instance
                else
                    logger:Error("UIManager", "VALIDATION",
                        "Komponen '" .. logicalName .. "' (Nama: " .. componentName .. ") TIPE SALAH!\n" ..
                        "Expected Type: " .. expectedType .. " | Found: " .. instance.ClassName)
                end
            else
                logger:Warn("UIManager", "VALIDATION",
                    "Komponen '" .. logicalName .. "' (Nama: " .. componentName .. ") TIDAK DITEMUKAN di ScreenGui.")
            end
        else
            logger:Error("UIManager", "CONFIG",
                "Komponen '" .. logicalName .. "' tidak ada di kamus UIManager/config.lua!")
        end
    end

    self:ValidateComponents(discovered, expectedComponents)
    return discovered
end

function UIManager:ValidateComponents(discovered, expectedComponents)
    local hasMissing = false
    local missingMessages = {}
    local componentCount = 0

    if not expectedComponents or not next(expectedComponents) then
        logger:Info("UIManager", "VALIDATION", "Tidak ada 'components' di UI config, validasi dilewati.")
        return
    end

    for logicalName, _ in pairs(expectedComponents) do
        componentCount = componentCount + 1
        if not discovered[logicalName] then
            hasMissing = true
            table.insert(missingMessages, "\n - '" .. logicalName .. "'")
        end
    end

    if hasMissing then
         logger:Error("UIManager", "VALIDATION",
                "Gagal menemukan " .. #missingMessages .. "/" .. componentCount .. " komponen UI!" ..
                table.concat(missingMessages) ..
                "\n🔧 Solution: Cek log UIManager di atas untuk detail (Tipe Salah / Tidak Ditemukan).")
    else
        logger:Info("UIManager", "VALIDATION", "Semua " .. componentCount .. " expected components berhasil ditemukan dan divalidasi.")
    end
end

function UIManager:GetComponentRegistry()
    if config and config.component_registry and next(config.component_registry) then
        return config.component_registry
    end

    logger:Error("UIManager", "CONFIG", "config.lua UIManager KOSONG atau GAGAL di-load!")
    return nil
end

return UIManager
