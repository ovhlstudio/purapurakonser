-- src/Client/OVHL_Modules/MusicPlayerUI/manifest.lua
-- ScreenGui.Enabled toggle logic
local MusicPlayerUI = {}

local NavigationController = require(script.Parent.Controller.navigation_controller)
local PlaybackController = require(script.Parent.Controller.playback_controller)
local NetworkHandlers = require(script.Parent.Services.network_handlers)
local UIState = require(script.Parent.Services.ui_state)

local kernel, logger, config, network, uiManager
local ui = {}

local navigationController = NavigationController
local playbackController = PlaybackController
local networkHandlers = NetworkHandlers
local uiState = UIState

local function toggleUI()
    if not ui.Root then
        if logger then
            logger:Error("MusicPlayerUI", "TOGGLE", "FATAL: ui.Root adalah nil! UI belum di-setup.")
        else
            warn("[MusicPlayerUI] FATAL: ui.Root adalah nil!")
        end
        return
    end

    if not ui.Root:IsA("ScreenGui") then
        logger:Error("MusicPlayerUI", "TOGGLE", "FATAL: ui.Root bukan ScreenGui! Type: " .. ui.Root.ClassName)
        return
    end

    ui.Root.Enabled = not ui.Root.Enabled

    logger:Info("MusicPlayerUI", "TOGGLE",
        "ScreenGui.Enabled = " .. tostring(ui.Root.Enabled) ..
        " | Panel sekarang " .. (ui.Root.Enabled and "VISIBLE" or "HIDDEN"))
end

function MusicPlayerUI:SetKernel(k)
    kernel = k
end

function MusicPlayerUI:Init()
    logger = kernel:GetModule("Logger")
    network = kernel:GetModule("Network")
    uiManager = kernel:GetModule("UIManager")
    config = self.config

    if not config then
        logger:Error("MusicPlayerUI", "CONFIG", "Config tidak ditemukan oleh Kernel!")
        return
    end

    local uiInstance = uiManager:SetupModuleUI("MusicPlayerUI", config)
    if not uiInstance or not uiInstance.Components or not next(uiInstance.Components) then
        logger:Error("MusicPlayerUI", "UI", "Gagal! UIManager mengembalikan komponen kosong.")
        return
    end

    ui.Components = uiInstance.Components
    ui.Root = uiInstance.Root

    if not ui.Root then
        logger:Error("MusicPlayerUI", "FATAL", "ui.Root adalah nil setelah UIManager setup!")
        return
    end

    if not ui.Root:IsA("ScreenGui") then
        logger:Error("MusicPlayerUI", "FATAL",
            "ui.Root bukan ScreenGui! Type: " .. ui.Root.ClassName)
        return
    end

    logger:Info("MusicPlayerUI", "INIT",
        "UI Root verified: " .. ui.Root.Name .. " (ScreenGui) | Initial Enabled: " .. tostring(ui.Root.Enabled))

    for key, component in pairs(uiInstance.Components) do
        ui[key] = component
    end

    navigationController:Init(logger, ui)
    playbackController:Init(logger, ui)
    networkHandlers:Init({
        logger = logger,
        network = network,
        playbackController = playbackController
    })

    uiState:Init({
        logger = logger,
        network = network,
        ui = ui,
        navigationController = navigationController,
        playbackController = playbackController,
        toggleApi = toggleUI
    })

    logger:Info("MusicPlayerUI", "SYSTEM", "MusicPlayerUI Initialized (Frontend - Arsitektur Bersih)")

    navigationController:SetupInitialState()
    uiState:ConnectButtons()
    networkHandlers:RegisterNetworkEvents()
end

function MusicPlayerUI:ToggleUI()
    logger:Info("MusicPlayerUI", "API", "ToggleUI() PUBLIC API dipanggil via TopbarPlus!")
    toggleUI()
end

function MusicPlayerUI:GetTopbarConfig()
    local topbarConfig = config and config.topbar

    if not topbarConfig then
        logger:Warn("MusicPlayerUI", "TOPBAR", "Config topbar tidak ditemukan!")
        return nil
    end

    return {
        name = topbarConfig.name,
        icon = topbarConfig.icon,
        tip = topbarConfig.tip,
        toggleApiName = "ToggleUI"
    }
end

function MusicPlayerUI:GetNetworkEvents()
    return {
        { name = "MusicSync", scope = "Client" },
        { name = "QueueUpdated", scope = "Client" },
        { name = "ShowShoutOut", scope = "Client" },
        { name = "ShowToast", scope = "Client" }
    }
end

return MusicPlayerUI
