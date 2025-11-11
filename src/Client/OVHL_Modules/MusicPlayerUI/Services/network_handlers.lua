-- src/Client/OVHL_Modules/MusicPlayerUI/Services/network_handlers.lua
local NetworkHandlers = {}
NetworkHandlers.ClassName = "NetworkHandlers"
local logger, network
local playbackController
function NetworkHandlers:Init(deps)
    logger = deps.logger
    network = deps.network
    playbackController = deps.playbackController
end
function NetworkHandlers:RegisterNetworkEvents()
    if not network then
        logger:Error("MusicPlayerUI", "NETWORK", "Modul Network tidak ditemukan!")
        return
    end
    network:OnClientEvent("MusicSync", function(syncData)
        playbackController:OnMusicSync(syncData)
    end)
    network:OnClientEvent("QueueUpdated", function(newQueue)
        logger:Info("MusicPlayerUI", "SYNC", "Menerima QueueUpdated. Total: " .. #newQueue)
        -- TODO: Update UI QueueScrollFrame
    end)
end
return NetworkHandlers
