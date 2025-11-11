-- src/Server/OVHL_Modules/MusicModule/manifest.lua
local MusicModule = {}

local PlaybackManager = require(script.Parent.Controller.playback_manager)
local ApiFetcher = require(script.Parent.Services.api_fetcher)
local NetworkHandlers = require(script.Parent.Services.network_handlers)

local kernel, logger, config, network
local permissionSync, monetizationModule

local playbackManager = PlaybackManager
local apiFetcher = ApiFetcher
local networkHandlers = NetworkHandlers

function MusicModule:SetKernel(k)
    kernel = k
end

function MusicModule:Init()
    logger = kernel:GetModule("Logger")
    network = kernel:GetModule("Network")
    permissionSync = kernel:GetModule("PermissionSync")
    monetizationModule = kernel:GetModule("MonetizationModule")

    config = self.config
    if not config then
        logger:Error("MusicModule", "CONFIG", "Config tidak ditemukan oleh Kernel!")
        return
    end

    playbackManager:Init(logger, network)
    apiFetcher:Init(logger)
    networkHandlers:Init({
        logger = logger,
        network = network,
        permissionSync = permissionSync,
        monetizationModule = monetizationModule,
        playbackManager = playbackManager
    })

    logger:Info("MusicModule", "SYSTEM", "MusicModule Initialized (Backend - Arsitektur Bersih)")

    coroutine.wrap(function()
        local db = apiFetcher:LoadDatabase(config)
        if db then
            playbackManager:SetDatabase(db)
            playbackManager:StartAutoDJ()
        else
            logger:Error("MusicModule", "FATAL", "Database gagal dimuat! AutoDJ tidak akan mulai.")
        end
    end)()

    if network then
        networkHandlers:RegisterNetworkEvents()
    else
        logger:Error("MusicModule", "FATAL", "Modul Network tidak ditemukan!")
    end

    -- 4. Hubungkan listener untuk player baru
    game:GetService("Players").PlayerAdded:Connect(function(player)
        task.wait(5)
        local syncData = playbackManager:GetCurrentSyncData()
        if network and syncData then
            logger:Debug("MusicModule", "SYNC", "Mengirim status sinkronisasi ke player baru: " .. player.Name)

            -- 🎯 PERBAIKAN: Urutan argumen dibalik (eventName, player, ...)
            network:FireClient("MusicSync", player, syncData)
        end
    end)
end

function MusicModule:GetPlaybackManager()
    return playbackManager
end

function MusicModule:GetNetworkEvents()
    return {
        { name = "RequestSong", scope = "Server" }, { name = "VoteToSkip", scope = "Server" },
        { name = "RequestShoutOut", scope = "Server" }, { name = "MusicSync", scope = "AllClients" },
        { name = "QueueUpdated", scope = "AllClients" }, { name = "ShowShoutOut", scope = "AllClients" },
        { name = "ShowToast", scope = "SpecificClient" }
    }
end

return MusicModule
