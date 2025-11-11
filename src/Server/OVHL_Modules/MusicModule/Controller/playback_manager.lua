-- src/Server/OVHL_Modules/MusicModule/Controller/playback_manager.lua
local PlaybackManager = {}
PlaybackManager.ClassName = "PlaybackManager"

local Workspace = game:GetService("Workspace")

-- State
local musicDatabase = {}
local currentSongData = nil
local currentSound = nil
local songQueue = {}
local currentMode = "AutoDJ"
local isPlaying = false

local logger, network -- Akan di-inject oleh manifest

-- Kontainer untuk sound
local soundContainer = Workspace:FindFirstChild("OVHL_MusicContainer")
if not soundContainer then
    soundContainer = Instance.new("Folder")
    soundContainer.Name = "OVHL_MusicContainer"
    soundContainer.Parent = Workspace
end

function PlaybackManager:Init(injectedLogger, injectedNetwork)
    logger = injectedLogger
    network = injectedNetwork
end

function PlaybackManager:SetDatabase(db)
    musicDatabase = db
end

function PlaybackManager:GetCurrentSyncData()
    if currentSongData and currentSound then
        return {
            songData = currentSongData,
            timePosition = currentSound.TimePosition,
            isPlaying = isPlaying,
            mode = currentMode
        }
    end
    return nil
end

function PlaybackManager:PlaySong(songData, mode)
    if currentSound then
        currentSound:Stop()
        currentSound:Destroy()
        currentSound = nil
    end

    currentSongData = songData
    currentMode = mode

    currentSound = Instance.new("Sound")
    currentSound.SoundId = "rbxassetid://" .. songData["ASET ID"]
    currentSound.Volume = 5
    currentSound.Parent = soundContainer

    currentSound.Loaded:Wait()

    currentSound:Play()
    isPlaying = true
    logger:Info("MusicModule", "PLAYBACK", "Memutar: " .. songData["JUDUL LAGU"])

    if network then
        network:FireAllClients("MusicSync", self:GetCurrentSyncData())
    end

    currentSound.Ended:Connect(function()
        isPlaying = false
        logger:Info("MusicModule", "PLAYBACK", "Lagu selesai: " .. songData["JUDUL LAGU"])
        self:OnSongEnded()
    end)
end

function PlaybackManager:OnSongEnded()
    -- TODO: Logic prioritas
    -- 1. Cek Queue
    -- 2. Cek Manual
    -- 3. Fallback ke AutoDJ
    self:StartAutoDJ()
end

function PlaybackManager:StartAutoDJ()
    if #musicDatabase == 0 then
        logger:Warn("MusicModule", "AUTODJ", "Database lagu kosong.")
        return
    end

    currentMode = "AutoDJ"
    logger:Info("MusicModule", "AUTODJ", "AutoDJ dimulai...")

    local songToPlay = musicDatabase[math.random(#musicDatabase)]
    self:PlaySong(songToPlay, "AutoDJ")
end

-- API Publik untuk Network Handlers
function PlaybackManager:QueueSong(songData)
    logger:Info("MusicModule", "QUEUE", "Lagu ditambahkan ke antrian: " .. songData["JUDUL LAGU"])
    table.insert(songQueue, songData)
    if network then
        network:FireAllClients("QueueUpdated", songQueue)
    end
end

function PlaybackManager:PlaySongNow(songData)
    logger:Info("MusicModule", "MANUAL", "Memutar lagu manual: " .. songData["JUDUL LAGU"])
    self:PlaySong(songData, "Manual")
end

return PlaybackManager
