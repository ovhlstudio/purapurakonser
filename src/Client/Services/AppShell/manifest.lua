-- src/Client/Services/AppShell/manifest.lua
-- 🎯 DEFENSIVE LOADING: Handle TopbarPlus errors gracefully
local AppShell = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TopbarController = require(script.Parent.Controller.topbar_controller)

local kernel, logger, config
local topbarController = TopbarController
local Icon = nil

function AppShell:SetKernel(k)
    kernel = k
end

function AppShell:Init()
    logger = kernel:GetModule("Logger")
    config = self.config

    logger:Info("AppShell", "INIT", "Attempting to load TopbarPlus library...")

    local topbarPlusFolder = ReplicatedStorage:FindFirstChild("TopbarPlus")
    if not topbarPlusFolder then
        logger:Error("AppShell", "FATAL",
            "TopbarPlus folder tidak ditemukan di ReplicatedStorage! " ..
            "Pastikan asset TopbarPlus sudah di-insert dari Marketplace.")
        return
    end

    local iconModule = topbarPlusFolder:FindFirstChild("Icon")
    if not iconModule then
        logger:Error("AppShell", "FATAL",
            "Icon module tidak ditemukan di TopbarPlus folder! " ..
            "Expected path: ReplicatedStorage.TopbarPlus.Icon")
        return
    end

    local success, result = pcall(require, iconModule)
    if not success then
        logger:Error("AppShell", "FATAL",
            "Gagal require TopbarPlus.Icon module!", result)
        return
    end

    Icon = result
    logger:Info("AppShell", "INIT", "TopbarPlus library loaded successfully")

    topbarController:Init({
        logger = logger,
        kernel = kernel,
        config = config,
        Icon = Icon
    })

    logger:Info("AppShell", "SYSTEM", "AppShell (Jembatan Pintar) Initialized (Menunggu Fase 4)")
end

function AppShell:PostInit()
    if not Icon then
        logger:Warn("AppShell", "POST-INIT",
            "TopbarPlus library tidak tersedia. Melewati auto-discovery tombol.")
        return
    end

    logger:Info("AppShell", "POST-INIT", "Fase 4 tercapai. Memulai auto-discovery tombol Topbar...")

    local success, err = pcall(function()
        topbarController:AutoDiscoverButtons()
    end)

    if not success then
        logger:Error("AppShell", "POST-INIT",
            "Auto-discovery tombol GAGAL!", err)
    end
end

return AppShell
