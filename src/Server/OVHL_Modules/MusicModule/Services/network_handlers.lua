-- src/Server/OVHL_Modules/MusicModule/Services/network_handlers.lua
local NetworkHandlers = {}
NetworkHandlers.ClassName = "NetworkHandlers"

local logger, network, permissionSync, monetizationModule
local playbackManager -- Akan di-inject

function NetworkHandlers:Init(deps)
    logger = deps.logger
    network = deps.network
    permissionSync = deps.permissionSync
    monetizationModule = deps.monetizationModule
    playbackManager = deps.playbackManager
end

function NetworkHandlers:RegisterNetworkEvents()
    network:OnServerEvent("RequestSong", function(player, assetId, playMode)
        self:OnRequestSong(player, assetId, playMode)
    end)
    -- TODO: Hubungkan VoteToSkip dan RequestShoutOut
end

function NetworkHandlers:OnRequestSong(player, assetId, playMode)
    logger:Debug("MusicModule", "NETWORK", "Menerima RequestSong dari " .. player.Name, {assetId, playMode})

    local role = "Guest"
    if permissionSync then
        role = permissionSync:GetRole(player)
    else
        logger:Warn("MusicModule", "PERM", "PermissionSync tidak ditemukan, semua request diblokir.")
        network:FireClient("ShowToast", player, "error", "Fitur request sedang tidak tersedia.")
        return
    end

    if role == "Creator" then
        -- Bypass
    else
        if role ~= "VVIP" then
             network:FireClient("ShowToast", player, "error", "Anda harus VVIP untuk fitur ini.")
             return
        end
    end

    -- TODO: Validasi Asset ID

    local songData = {
        ["ASET ID"] = assetId,
        ["JUDUL LAGU"] = "Lagu Request",
        ["ARTIS"] = "Unknown",
        ["GENRE"] = "Request",
        ["SUB GENRE"] = "Request",
        ["PLACEMENT"] = "Global",
        ["ART IMAGE ID"] = "" -- TODO: Dapatkan Art Image
    }

    if playMode == "PlayNow" then
        playbackManager:PlaySongNow(songData)
    else -- "Queue"
        playbackManager:QueueSong(songData)
    end
end

return NetworkHandlers
