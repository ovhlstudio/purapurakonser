-- src/Client/OVHL_Modules/MusicPlayerUI/Controller/playback_controller.lua
local PlaybackController = {}
PlaybackController.ClassName = "PlaybackController"
-- ... (sisa file ini sudah benar, .new() tidak ada di sini) ...
local logger, ui
local localSound
function PlaybackController:Init(injectedLogger, uiComponents)
    logger = injectedLogger
    ui = uiComponents
end
function PlaybackController:OnMusicSync(syncData)
    if not syncData or not syncData.songData then
        logger:Warn("MusicPlayerUI", "SYNC", "Menerima data MusicSync yang tidak valid.")
        return
    end
    logger:Info("MusicPlayerUI", "SYNC", "Menerima MusicSync: " .. syncData.songData["JUDUL LAGU"])
    if ui.now_playing_title then
        ui.now_playing_title.Text = syncData.songData["JUDUL LAGU"]
    end
    if ui.now_playing_artist then
        ui.now_playing_artist.Text = string.format("%s - %s - %s",
            syncData.songData["GENRE"] or "Genre",
            syncData.songData["SUB GENRE"] or "Sub",
            syncData.songData["PLACEMENT"] or "Placement"
        )
    end
    if localSound then
        localSound:Stop()
        localSound:Destroy()
        localSound = nil
    end
    localSound = Instance.new("Sound")
    localSound.SoundId = "rbxassetid://" .. syncData.songData["ASET ID"]
    localSound.Volume = 0.5
    localSound.Parent = ui.Root
    localSound.Loaded:Wait()
    if syncData.timePosition > 0 then
        localSound.TimePosition = syncData.timePosition
        logger:Info("MusicPlayerUI", "SYNC", "Sinkronisasi ke TimePosition: " .. syncData.timePosition)
    end
    if syncData.isPlaying then
        localSound:Play()
    end
    localSound.Ended:Connect(function()
        logger:Debug("MusicPlayerUI", "SYNC", "Lagu lokal selesai. Menunggu sync server...")
    end)
end
function PlaybackController:AdjustVolume(direction)
    if localSound then
        if direction == "Up" then
            localSound.Volume = math.min(localSound.Volume + 0.1, 1)
        elseif direction == "Down" then
            localSound.Volume = math.max(localSound.Volume - 0.1, 0)
        end
        logger:Debug("MusicPlayerUI", "VOLUME", "Volume Lokal: " .. localSound.Volume)
    end
end
return PlaybackController
