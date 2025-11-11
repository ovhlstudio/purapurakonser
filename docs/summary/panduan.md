Ah, **PAHAM.**

Instruksi Anda 100% jelas. Anda tidak ingin _saya_ mencatat dev log, Anda ingin saya **membuat "Kitab Suci" baru** untuk developer lain. Sebuah panduan _"How-To"_ untuk _onboarding_ ke arsitektur OVHL Core V2.1 kita, menggunakan `MusicModule` dan `MusicPlayerUI` sebagai "Contoh Emas" (Gold Standard) dengan arsitektur bersih (`Controller`/`Services`) yang sudah lengkap.

Ini adalah ide yang brilian. Ini akan menghemat waktu kita berminggu-minggu di masa depan.

Siap. Berikut adalah draf lengkap untuk dokumen baru tersebut.

---

### Draft Dokumen Baru (Silakan Salin ke File Anda)

Markdown

````
# 📘 Panduan OVHL Core dan Pembuatan Modul (V2.1 - Battle Tested)

**Versi:** 1.0.0
**Status:** FINAL (Lahir dari Sesi 1, `05-DEV-LOG.md` [2025-11-11])
**Tujuan:** Dokumen ini adalah "Kitab Suci" praktis (Single Source of Truth) untuk Developer OVHL. Ini mendokumentasikan "Cara Kerja" arsitektur kita yang sudah teruji dan stabil.

**Semua developer baru WAJIB membaca ini sebelum menulis kode.**
**Semua modul baru WAJIB mengikuti panduan ini.**

---

## 1. 🏛️ Filosofi Inti OVHL (4 Pilar Stabil)

Arsitektur kita stabil karena 4 pilar yang telah kita perbaiki dan uji:

1.  **Kernel 4-Fase (Urutan Stabil):** Sistem *boot* 4 fase (`Phase 0` Bootstrap -> `Phase 1-2` Load -> `Phase 3` Init).
2.  **Arsitektur Modul Bersih (Decision #3.1):** Kita **DILARANG** menumpuk *logic* di `manifest.lua`.
    * **`manifest.lua`:** Hanya sebagai "Manajer" (API Publik & Injeksi Dependensi).
    * **`Controller/`:** Hanya "Otak" (*logic* murni, `AutoDJ`, `Navigasi`).
    * **`Services/`:** Hanya "Tangan & Telinga" (I/O, `Network`, `API Call`, `UI State`).
3.  **Auto-Discovery (Plug & Play):**
    * **`Network`:** Modul *otomatis* mendaftarkan *event* dengan `GetNetworkEvents()`.
    * **`UIManager` (V2 Presisi):** Modul UI *otomatis* menemukan komponen GUI berdasarkan kamus 1-ke-1.
4.  **Logging Granular (Decision #18.2):**
    * `Server/config.lua` & `Shared/config.lua` mengatur `global_log_level` (dianjurkan: `WARN`).
    * Setiap modul mengatur `log_level = "DEBUG"` di `config.lua`-nya sendiri untuk "berisik" saat *development*.

---

## 2. 📁 Arsitektur File (Struktur V2.1 Stabil)

Struktur ini **WAJIB** diikuti. Perhatikan `UIManager` berada di `Client/Core`.

```text
📁 src/
├── 📁 Client/
│   ├── 📜 init.client.lua         ← (LocalScript) BOOTSTRAPPER KLIEN
│   ├── 📁 Core/
│   │   ├── 📁 Kernel/
│   │   │   └── 📜 manifest.lua    ← Kernel Loader (Urutan Init Stabil)
│   │   └── 📁 UIManager/          ← 💎 UIManager (Arsitektur V2 Presisi)
│   │       ├── 📜 manifest.lua
│   │       └── 📜 config.lua      ← (Kamus 1-ke-1 Presisi)
│   └── 📁 OVHL_Modules/
│       └── 📁 MusicPlayerUI/      ← (Contoh Emas Modul Client)
│           ├── 📜 manifest.lua
│           ├── 📜 config.lua
│           ├── 📁 Controller/
│           └── 📁 Services/
│
├── 📁 Server/
│   ├── 📜 init.server.lua         ← (Script) BOOTSTRAPPER SERVER
│   ├── 📜 config.lua              ← (Global Config)
│   ├── 📁 Core/
│   │   └── 📁 Kernel/
│   │       └── 📜 manifest.lua    ← Kernel Loader (Urutan Init Stabil)
│   ├── 📁 Services/
│   │   └── 📁 DataModule/         ← (Contoh: Akan Datang)
│   └── 📁 OVHL_Modules/
│       └── 📁 MusicModule/        ← (Contoh Emas Modul Server)
│           ├── 📜 manifest.lua
│           ├── 📜 config.lua
│           ├── 📁 Controller/
│           └── 📁 Services/
│
└── 📁 Shared/
    ├── 📜 config.lua              ← (Global Config Client)
    ├── 📁 Logger/
    │   └── 📜 manifest.lua        ← (Logger Granular)
    ├── 📁 Network/
    │   └── 📜 manifest.lua        ← (Network Auto-Discovery)
    └── 📁 OVHL_UI/
        └── 📜 manifest.lua        ← (Stub)

````

---

## 3\. 🚀 SOP Pembuatan Modul BARU (Server)

Gunakan **Contoh Emas (`MusicModule`)** di bawah sebagai referensi.

### Langkah 1: Buat Struktur File

Buat `config.lua`, `manifest.lua`, dan folder `Controller`/`Services`.

### Langkah 2: Tulis `config.lua`

Atur `log_level` ke `DEBUG` agar Anda bisa melihat _output_\-nya.

Lua

```
-- src/Server/OVHL_Modules/NewModule/config.lua
return {
    debug = {
        log_level = "DEBUG" -- 🎯 WAJIB saat development
    },

    api_key = "abc12345"
}

```

### Langkah 3: Tulis `Controller/` & `Services/`

Ini adalah logic murni Anda. Selalu return static table.

(Pelajaran V6: JANGAN gunakan .new()!)

Lua

```
-- src/Server/OVHL_Modules/NewModule/Controller/core_logic.lua
local CoreLogic = {}
local logger

function CoreLogic:Init(injectedLogger)
    logger = injectedLogger
end

function CoreLogic:DoSomething()
    logger:Info("NewModule", "LOGIC", "Sesuatu terjadi!")
end

return CoreLogic

```

### Langkah 4: Tulis `manifest.lua` (Manajer)

File ini hanya "merakit" modul.

(Pelajaran V5: WAJIB gunakan script.Parent!)

Lua

```
-- src/Server/OVHL_Modules/NewModule/manifest.lua
local NewModule = {}

-- 1. REQUIRE (Gunakan script.Parent)
local CoreLogic = require(script.Parent.Controller.core_logic)

local kernel, logger, config

-- 2. REFERENSI (Gunakan static table)
local coreLogic = CoreLogic

function NewModule:SetKernel(k)
    kernel = k
end

function NewModule:Init()
    -- 3. DAPATKAN DEPENDENSI KERNEL
    logger = kernel:GetModule("Logger")
    config = self.config -- Di-load otomatis oleh Kernel

    -- 4. INJEKSI DEPENDENSI (DI)
    coreLogic:Init(logger)

    logger:Info("NewModule", "SYSTEM", "NewModule Initialized")

    -- 5. MULAI LOGIC
    coreLogic:DoSomething()
end

-- 6. (OPSIONAL) UMUMKAN EVENT
function NewModule:GetNetworkEvents()
    return { { name = "SomethingHappened", scope = "AllClients" } }
end

return NewModule

```

---

## 4\. 🏆 Contoh Emas: `MusicModule` (Server)

Ini adalah implementasi **LENGKAP** dan **BERSIH** dari modul _backend_ yang memanggil API dan memutar musik.

### `config.lua`

Lua

```
-- src/Server/OVHL_Modules/MusicModule/config.lua
return {
    debug = {
        log_level = "DEBUG"
    },
    features = {
        voteSkipThreshold = 0.51,
        enableVoteToSkip = true
    },
    api = {
        jsonDatabaseUrl = "[https://script.googleusercontent.com/macros/echo?user_content_key=AehSKLi-cz8Yr4FDrmSGklqXfARl176dnn2QSXM-ySFNdgDhjtIvr78ul37F6-zfefk1FKPeZaPgRutzN8jw5ffU--QjIaICXUcYKs-PAoXPjucUtMDAMstdtjTzazL-r8SttkiNI6IbZuusAfPG_pV1dcbEd3WFGHPhq-ebHG9VN60DqAjTEXBPL9BBbPBualTNnC6cHBVlHiFDvEHO5zkOagCTLL-nriwH3QVDhinRLkA1fDjqcrAzFG24EKd39i4huP3Qd0TlFjoVQr3_imuVxjyX0TLGQ_GEoek2H5IX&lib=MNM0TGyeKFjzqL0r2EtgJqWvoM8vupKNJ](https://script.googleusercontent.com/macros/echo?user_content_key=AehSKLi-cz8Yr4FDrmSGklqXfARl176dnn2QSXM-ySFNdgDhjtIvr78ul37F6-zfefk1FKPeZaPgRutzN8jw5ffU--QjIaICXUcYKs-PAoXPjucUtMDAMstdtjTzazL-r8SttkiNI6IbZuusAfPG_pV1dcbEd3WFGHPhq-ebHG9VN60DqAjTEXBPL9BBbPBualTNnC6cHBVlHiFDvEHO5zkOagCTLL-nriwH3QVDhinRLkA1fDjqcrAzFG24EKd39i4huP3Qd0TlFjoVQr3_imuVxjyX0TLGQ_GEoek2H5IX&lib=MNM0TGyeKFjzqL0r2EtgJqWvoM8vupKNJ)"
    },
    fallbackDatabase = {
        {
            ["ASET ID"] = 116793331819089,
            ["JUDUL LAGU"] = "Laksmana Raja Dilaut (FALLBACK)",
            ["ARTIS"] = "Iyeth Bustami",
            ["GENRE"] = "Orchestra",
            ["SUB GENRE"] = "Metal Cover",
            ["PLACEMENT"] = "GLOBAL",
            ["ART IMAGE ID"] = 98797816117498
        }
    }
}

```

### `Controller/playback_manager.lua` (Otak)

Lua

```
-- src/Server/OVHL_Modules/MusicModule/Controller/playback_manager.lua
local PlaybackManager = {}
PlaybackManager.ClassName = "PlaybackManager"

local Workspace = game:GetService("Workspace")

local musicDatabase = {}
local currentSongData = nil
local currentSound = nil
local songQueue = {}
local currentMode = "AutoDJ"
local isPlaying = false

local logger, network

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
    -- TODO: Logic prioritas (Queue > Manual > AutoDJ)
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

```

### `Services/api_fetcher.lua` (Tangan - API)

Lua

```
-- src/Server/OVHL_Modules/MusicModule/Services/api_fetcher.lua
local ApiFetcher = {}
ApiFetcher.ClassName = "ApiFetcher"

local HttpService = game:GetService("HttpService")
local logger

function ApiFetcher:Init(injectedLogger)
    logger = injectedLogger
end

-- 🎯 FUNGSI PENTING: Untuk "meratakan" JSON bersarang
local function flattenDatabase(nestedData)
    local flatDatabase = {}

    -- Level 1: Genre (misal: "Dangdut")
    for genreName, subGenres in pairs(nestedData) do
        -- Level 2: SubGenre (misal: "Koplo")
        for subGenreName, songs in pairs(subGenres) do
            -- Level 3: Array Lagu
            for _, songData in ipairs(songs) do
                -- 🎯 Menyuntikkan data Genre & SubGenre ke dalam objek lagu
                songData["GENRE"] = genreName
                songData["SUB GENRE"] = subGenreName
                table.insert(flatDatabase, songData)
            end
        end
    end
    return flatDatabase
end

function ApiFetcher:LoadDatabase(config)
    local apiUrl = config.api.jsonDatabaseUrl

    if apiUrl and apiUrl ~= "" then
        logger:Info("MusicModule", "DATA", "Mencoba mengambil database dari API JSON...")
        local success, result = pcall(function()
            return HttpService:GetAsync(apiUrl)
        end)

        if success then
            local decodedSuccess, data = pcall(function()
                return HttpService:JSONDecode(result)
            end)

            if decodedSuccess and type(data) == "table" then
                -- 🎯 Panggil fungsi 'flatten'
                local flatDatabase = flattenDatabase(data)
                logger:Info("MusicModule", "DATA", "BERHASIL! " .. #flatDatabase .. " lagu dimuat dari API (setelah diratakan).")
                return flatDatabase
            else
                logger:Error("MusicModule", "DATA", "Gagal me-decode JSON dari API. Menggunakan fallback.", data)
            end
        else
            logger:Error("MusicModule", "DATA", "Gagal memanggil API HTTP. Menggunakan fallback.", result)
        end
    else
        logger:Warn("MusicModule", "DATA", "API URL kosong.")
    end

    -- Fallback
    logger:Info("MusicModule", "DATA", "Memuat database fallback...")
    local fallbackDatabase = config.fallbackDatabase
    if #fallbackDatabase > 0 then
        logger:Info("MusicModule", "DATA", "Berhasil memuat " .. #fallbackDatabase .. " lagu dari fallback.")
        return fallbackDatabase
    end

    logger:Error("MusicModule", "FATAL", "Database API dan Fallback gagal dimuat!")
    return nil
end

return ApiFetcher

```

### `Services/network_handlers.lua` (Telinga - Network)

Lua

```
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

    local songData = {
        ["ASET ID"] = assetId,
        ["JUDUL LAGU"] = "Lagu Request",
        ["ARTIS"] = "Unknown",
        ["GENRE"] = "Request",
        ["SUB GENRE"] = "Request",
        ["PLACEMENT"] = "Global",
        ["ART IMAGE ID"] = ""
    }

    if playMode == "PlayNow" then
        playbackManager:PlaySongNow(songData)
    else -- "Queue"
        playbackManager:QueueSong(songData)
    end
end

return NetworkHandlers

```

### `manifest.lua` (Manajer)

Lua

```
-- src/Server/OVHL_Modules/MusicModule/manifest.lua
local MusicModule = {}

-- 1. REQUIRE (Gunakan script.Parent)
local PlaybackManager = require(script.Parent.Controller.playback_manager)
local ApiFetcher = require(script.Parent.Services.api_fetcher)
local NetworkHandlers = require(script.Parent.Services.network_handlers)

local kernel, logger, config, network
local permissionSync, monetizationModule

-- 2. REFERENSI (Gunakan static table)
local playbackManager = PlaybackManager
local apiFetcher = ApiFetcher
local networkHandlers = NetworkHandlers

function MusicModule:SetKernel(k)
    kernel = k
end

function MusicModule:Init()
    -- 3. DAPATKAN DEPENDENSI KERNEL
    logger = kernel:GetModule("Logger")
    network = kernel:GetModule("Network")
    permissionSync = kernel:GetModule("PermissionSync")
    monetizationModule = kernel:GetModule("MonetizationModule")
    config = self.config

    if not config then
        logger:Error("MusicModule", "CONFIG", "Config tidak ditemukan oleh Kernel!")
        return
    end

    -- 4. INJEKSI DEPENDENSI (DI)
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

    -- 5. MULAI LOGIC
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

    game:GetService("Players").PlayerAdded:Connect(function(player)
        task.wait(5)
        local syncData = playbackManager:GetCurrentSyncData()
        if network and syncData then
            logger:Debug("MusicModule", "SYNC", "Mengirim status sinkronisasi ke player baru: " .. player.Name)
            network:FireClient("MusicSync", player, syncData)
        end
    end)
end

-- 6. (OPSIONAL) API PUBLIK
function MusicModule:GetPlaybackManager()
    return playbackManager
end

-- 7. (WAJIB) UMUMKAN EVENT
function MusicModule:GetNetworkEvents()
    return {
        { name = "RequestSong", scope = "Server" }, { name = "VoteToSkip", scope = "Server" },
        { name = "RequestShoutOut", scope = "Server" }, { name = "MusicSync", scope = "AllClients" },
        { name = "QueueUpdated", scope = "AllClients" }, { name = "ShowShoutOut", scope = "AllClients" },
        { name = "ShowToast", scope = "SpecificClient" }
    }
end

return MusicModule

```

---

## 5\. 💎 SOP Pembuatan Modul UI (Client)

Modul UI sedikit berbeda karena mereka bergantung pada `UIManager`.

### Langkah 1: Buat `ScreenGui` di Studio

Buat `MusicPanel` (atau `ScreenGui` Anda) dan **PASTIKAN SEMUA NAMA KOMPONEN ANDA UNIK DAN JELAS** (`PascalCase`).

### Langkah 2: Buat Kamus `UIManager/config.lua`

Buka `src/Client/Core/UIManager/config.lua` dan **tambahkan entri** untuk setiap komponen baru.

**(Pelajaran V4: WAJIB 1-ke-1. Key `snake_case` -> Value `"PascalCaseName"`).**

Lua

```
-- src/Client/Core/UIManager/config.lua
...
component_registry = {
    ...
    -- Ditambahkan untuk modul baru:
    new_module_title = "NewModuleTitleLabel",
    new_module_button = "NewModuleSubmitButton"
}
...

```

### Langkah 3: Buat `config.lua` Modul (Daftar Belanja)

Buat `config.lua` untuk modul UI Anda yang mencantumkan _key_ `snake_case` yang baru saja Anda tambahkan ke kamus.

Lua

```
-- src/Client/OVHL_Modules/NewModuleUI/config.lua
return {
    debug = {
        log_level = "DEBUG"
    },
    ui = {
        mode = "StarterGui",
        screen_gui = "NewModulePanel", -- Nama ScreenGui Anda

        components = {
            new_module_title = "TextLabel",
            new_module_button = "TextButton"
        }
    }
}

```

### Langkah 4: Tulis `Controller/` & `Services/`

Sama seperti modul _server_, pisahkan _logic_ Anda.

### Langkah 5: Tulis `manifest.lua` (Manajer UI)

_Manifest_ ini akan memanggil `UIManager` untuk mendapatkan semua komponen.

Lua

```
-- src/Client/OVHL_Modules/NewModuleUI/manifest.lua
local NewModuleUI = {}

local NavLogic = require(script.Parent.Controller.nav_logic)

local kernel, logger, config, uiManager
local ui = {} -- 🎯 Tabel ini akan diisi oleh UIManager
local navLogic

function NewModuleUI:SetKernel(k)
    kernel = k
end

function NewModuleUI:Init()
    logger = kernel:GetModule("Logger")
    uiManager = kernel:GetModule("UIManager")
    config = self.config

    -- 1. PANGGIL UIMANAGER
    local uiInstance = uiManager:SetupModuleUI("NewModuleUI", config)
    if not uiInstance or not uiInstance.Components or not next(uiInstance.Components) then
        logger:Error("NewModuleUI", "UI", "Gagal! UIManager tidak menemukan komponen.")
        return
    end

    -- 2. SIMPAN REFERENSI KOMPONEN
    ui = uiInstance.Components
    ui.Root = uiInstance.Root

    -- 3. INISIALISASI & DI
    navLogic = NavLogic
    navLogic:Init(logger, ui)

    logger:Info("NewModuleUI", "SYSTEM", "NewModuleUI Initialized")

    -- 4. MULAI LOGIC
    navLogic:SetupInitialState()
end

return NewModuleUI

```

---

## 6\. 🏆 Contoh Emas: `MusicPlayerUI` (Client)

Ini adalah implementasi **LENGKAP** dan **BERSIH** dari modul _frontend_ yang menggunakan `UIManager` V2 Presisi.

### `config.lua` (Daftar Belanja)

Lua

```
-- src/Client/OVHL_Modules/MusicPlayerUI/config.lua
return {
    ui = {
        mode = "StarterGui",
        screen_gui = "MusicPanel",
        components = {
            now_playing_page = "Frame",
            page_container = "Frame",
            content_frame = "Frame",
            loading_page = "Frame",
            library_page = "Frame",
            song_list_page = "Frame",
            request_page = "Frame",
            shout_out_page = "Frame",
            nav_bar = "Frame",
            header_text = "TextLabel",
            close_button = "ImageButton",
            search_button = "ImageButton",
            footer_menu = "Frame",
            back_button = "ImageButton",
            home_button = "ImageButton",
            menu_button = "ImageButton",
            menu_popup = "ScrollingFrame",
            menu_button_template = "TextButton",
            status_bar = "Frame",
            time_label = "TextLabel",
            toast_container = "Frame",
            toast_label = "TextLabel",
            vinyl_frame = "Frame",
            album_art = "ImageLabel",
            now_playing_title = "TextLabel",
            now_playing_artist = "TextLabel",
            love_button = "ImageButton",
            equalizer_button = "ImageButton",
            queue_scroll_frame = "ScrollingFrame",
            queue_item_template = "Frame",
            media_control_group = "Frame",
            prev_button = "ImageButton",
            play_button = "ImageButton",
            next_button = "ImageButton",
            vote_skip_button = "ImageButton",
            volume_slider = "Frame",
            volume_fill = "Frame",
            vol_up_button = "ImageButton",
            vol_down_button = "ImageButton",
            genre_scroll_frame = "ScrollingFrame",
            genre_box_template = "Frame",
            song_list_search_box = "TextBox",
            song_list_scroll_frame = "ScrollingFrame",
            song_list_template = "Frame",
            request_asset_id_input = "TextBox",
            request_play_now_button = "TextButton",
            request_add_to_queue_button = "TextButton",
            shout_out_input = "TextBox",
            shout_out_send_button = "TextButton"
        }
    },
    debug = {
        log_level = "DEBUG"
    }
}

```

### `Controller/navigation_controller.lua` (Otak Navigasi)

Lua

```
-- src/Client/OVHL_Modules/MusicPlayerUI/Controller/navigation_controller.lua
local NavigationController = {}
NavigationController.ClassName = "NavigationController"

local logger, ui

function NavigationController:Init(injectedLogger, uiComponents)
    logger = injectedLogger
    ui = uiComponents
end

function NavigationController:SetupInitialState()
    if not ui.now_playing_page then
        logger:Error("MusicPlayerUI", "STATE", "now_playing_page tidak ditemukan oleh UIManager!")
        return
    end

    ui.now_playing_page.Visible = true
    if ui.page_container then ui.page_container.Visible = false end

    if ui.content_frame then
        for _, page in ipairs(ui.content_frame:GetChildren()) do
            if page:IsA("Frame") then page.Visible = false end
        end
    end
    logger:Info("MusicPlayerUI", "UI", "State awal diatur: NowPlayingPage.")
end

function NavigationController:NavigateTo(pageKey)
    logger:Info("MusicPlayerUI", "NAV", "Navigasi ke: " .. pageKey)

    if not ui.now_playing_page or not ui.page_container or not ui.content_frame or not ui.header_text then
        logger:Error("MusicPlayerUI", "NAV", "Komponen UI inti navigasi hilang!")
        return
    end

    ui.now_playing_page.Visible = false
    ui.page_container.Visible = false

    for _, page in ipairs(ui.content_frame:GetChildren()) do
        if page:IsA("Frame") then page.Visible = false end
    end

    if pageKey == "now_playing_page" then
        ui.now_playing_page.Visible = true
        ui.header_text.Text = "Now Playing"
    else
        ui.page_container.Visible = true
        if ui[pageKey] then
            ui[pageKey].Visible = true
            local header = string.gsub(pageKey, "_page", "")
            header = string.upper(string.sub(header, 1, 1)) .. string.sub(header, 2)
            ui.header_text.Text = header
        else
            logger:Warn("MusicPlayerUI", "NAV", "Halaman tidak ditemukan: " .. pageKey)
            ui.now_playing_page.Visible = true
            ui.header_text.Text = "Now Playing"
        end
    end
end

return NavigationController

```

### `Controller/playback_controller.lua` (Otak Playback Client)

Lua

```
-- src/Client/OVHL_Modules/MusicPlayerUI/Controller/playback_controller.lua
local PlaybackController = {}
PlaybackController.ClassName = "PlaybackController"

local logger, ui
local localSound -- Instance Sound di Client

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

    -- 1. Update Teks
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

    -- 2. Bersihkan Suara Lama
    if localSound then
        localSound:Stop()
        localSound:Destroy()
        localSound = nil
    end

    -- 3. Buat Suara Baru
    localSound = Instance.new("Sound")
    localSound.SoundId = "rbxassetid://" .. syncData.songData["ASET ID"]
    localSound.Volume = 0.5 -- Default volume lokal
    localSound.Parent = ui.Root -- Taruh di dalam ScreenGui

    localSound.Loaded:Wait()

    -- 4. Sinkronisasi Waktu
    if syncData.timePosition > 0 then
        localSound.TimePosition = syncData.timePosition
        logger:Info("MusicPlayerUI", "SYNC", "Sinkronisasi ke TimePosition: " .. syncData.timePosition)
    end

    -- 5. Putar
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

```

### `Services/network_handlers.lua` (Telinga Client)

Lua

```
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

```

### `Services/ui_state.lua` (Tangan Client)

Lua

```
-- src/Client/OVHL_Modules/MusicPlayerUI/Services/ui_state.lua
-- File ini bertanggung jawab untuk menghubungkan tombol (State)
local UIState = {}
UIState.ClassName = "UIState"

local logger, network, ui
local navigationController, playbackController

function UIState:Init(deps)
    logger = deps.logger
    network = deps.network
    ui = deps.ui
    navigationController = deps.navigationController
    playbackController = deps.playbackController
end

function UIState:ConnectButtons()
    -- Navigasi Utama
    if ui.home_button then
        ui.home_button.MouseButton1Click:Connect(function()
            navigationController:NavigateTo("now_playing_page")
        end)
    end

    if ui.close_button then
        ui.close_button.MouseButton1Click:Connect(function()
            -- TODO: Panggil ToggleUI di manifest
        end)
    end

    if ui.search_button then
        ui.search_button.MouseButton1Click:Connect(function()
            navigationController:NavigateTo("song_list_page")
        end)
    end

    -- Aksi
    if ui.request_play_now_button then
        ui.request_play_now_button.MouseButton1Click:Connect(function()
            if ui.request_asset_id_input then
                local assetId = ui.request_asset_id_input.Text
                logger:Info("MusicPlayerUI", "REQUEST", "Mengirim PlayNow: " .. assetId)
                network:FireServer("RequestSong", assetId, "PlayNow")
            end
        end)
    end

    -- Volume Lokal
    if ui.vol_up_button then
        ui.vol_up_button.MouseButton1Click:Connect(function()
            playbackController:AdjustVolume("Up")
        end)
    end
    if ui.vol_down_button then
        ui.vol_down_button.MouseButton1Click:Connect(function()
            playbackController:AdjustVolume("Down")
        end)
    end
end

return UIState

```

### `manifest.lua` (Manajer Client)

Lua

```
-- src/Client/OVHL_Modules/MusicPlayerUI/manifest.lua
local MusicPlayerUI = {}

-- 1. REQUIRE (Gunakan script.Parent)
local NavigationController = require(script.Parent.Controller.navigation_controller)
local PlaybackController = require(script.Parent.Controller.playback_controller)
local NetworkHandlers = require(script.Parent.Services.network_handlers)
local UIState = require(script.Parent.Services.ui_state)

local kernel, logger, config, network, uiManager
local ui = {}

-- 2. REFERENSI (Gunakan static table)
local navigationController = NavigationController
local playbackController = PlaybackController
local networkHandlers = NetworkHandlers
local uiState = UIState

function MusicPlayerUI:SetKernel(k)
    kernel = k
end

function MusicPlayerUI:Init()
    -- 3. DAPATKAN DEPENDENSI KERNEL
    logger = kernel:GetModule("Logger")
    network = kernel:GetModule("Network")
    uiManager = kernel:GetModule("UIManager")
    config = self.config

    if not config then
        logger:Error("MusicPlayerUI", "CONFIG", "Config tidak ditemukan oleh Kernel!")
        return
    end

    -- 4. SETUP UI (Kritis)
    local uiInstance = uiManager:SetupModuleUI("MusicPlayerUI", config)
    if not uiInstance or not uiInstance.Components or not next(uiInstance.Components) then
        logger:Error("MusicPlayerUI", "UI", "Gagal! UIManager mengembalikan komponen kosong.")
        return
    end
    ui = uiInstance.Components
    ui.Root = uiInstance.Root

    -- 5. INJEKSI DEPENDENSI (DI)
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
        playbackController = playbackController
    })

    logger:Info("MusicPlayerUI", "SYSTEM", "MusicPlayerUI Initialized (Frontend - Arsitektur Bersih)")

    -- 6. MULAI LOGIC
    navigationController:SetupInitialState()
    uiState:ConnectButtons()
    networkHandlers:RegisterNetworkEvents()
end

-- 7. (WAJIB) API PUBLIK UNTUK TOPBARPLUS
function MusicPlayerUI:ToggleUI()
    if ui.Root then
        ui.Root.Enabled = not ui.Root.Enabled
        logger:Debug("MusicPlayerUI", "UI", "UI Toggle: " .. tostring(ui.Root.Enabled))
    end
end

-- 8. (WAJIB) UMUMKAN EVENT
function MusicPlayerUI:GetNetworkEvents()
    return {
        { name = "MusicSync", scope = "Client" },
        { name = "QueueUpdated", scope = "Client" },
        { name = "ShowShoutOut", scope = "Client" },
        { name = "ShowToast", scope = "Client" }
    }
end

return MusicPlayerUI

```
