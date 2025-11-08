# 🏛️ 01 - ARSITEKTUR (KITAB SUCI TEKNIS)

**Versi:** 2.1 (Refactored, Permission V3)
**Status:** FINAL
**Tujuan:** Dokumen ini adalah "Kitab Suci" (Single Source of Truth) untuk **Arsitektur Teknis Proyek**. Dokumen ini mendefinisikan _BAGAIMANA_ kita membangun.

---

## 🚀 POKOK-POKOK ARSITEKTUR

1.  **Entrypoint Dikelola Rojo:** `init.server.lua` (Script) & `init.client.lua` (LocalScript) adalah _entrypoint_ yang otomatis jalan, bukan `ModuleScript`.
2.  **Kernel 4-Fase:** Bootstrap (`Phase 0`) terpisah dari Kernel Loader (`Phase 1-3`) untuk menjamin _priority load_ (Logger & Config).
3.  **Logger Terpusat:** Satu `Shared/Logger` dipakai oleh Server & Client, di-Init dengan _Dependency Injection_ (anti _circular dependency_).
4.  **Struktur Domain:** Modul dibagi berdasarkan tanggung jawab: `Core`, `Services`, `OVHL_Modules` (menggantikan "Business").
5.  **Pemisahan Internal Modul:** Setiap modul **WAJIB** punya "Pola Dasar 5 File" (`init`, `Config`, `Logic`, `State`, `Handlers`) dan boleh "Eskalasi" (nambah file _pekerja_ internal).
6.  **Komunikasi Aman:** Komunikasi antar modul _hanya_ via `Kernel:GetModule()`, dan _hanya_ di dalam `Init()` (anti _circular dependency_).
7.  **Permission Aggregator (Anti-Crash):** Sistem izin (`Core/PermissionSync`) adalah _service_ internal yang _mencoba_ membaca Kohl's Admin dan memiliki _fallback_ penuh (cek Gamepass, Grup) jika Kohl's gagal.

---

## 🏛️ KEPUTUSAN ARSITEKTUR (DECISIONS)

### Decision #1: Arsitektur Kernel (Bootstrap & Loader)

Ini adalah keputusan paling fundamental yang mem-fix _priority load_ dan _circular dependency_.

#### 1.1. Fase 0: Bootstrap (Entrypoint Script)

`init.server.lua` (Script) dan `init.client.lua` (LocalScript) bertugas HANYA untuk menyalakan modul-modul inti _sebelum_ Kernel utama jalan.

**Contoh Kode (`src/Server/init.server.lua`):**

```lua
-- File ini adalah SCRIPT, otomatis jalan oleh Rojo
print("PHASE 0: Server Bootstrap...")

-- 1. Load Modul Inti (Urutan WAJIB)
local Config = require(script.Config)
local Logger = require(game:GetService("ReplicatedStorage").Shared.Logger.init)

-- 2. Injeksi Dependensi (Memutus Circular Dependency)
-- Logger sekarang NYALA dan punya akses ke Config
Logger:Init(Config)

-- 3. Panggil Kernel Utama (ModuleScript)
-- Kernel sekarang bisa :GetModule("Logger") atau :GetModule("Config")
local Kernel = require(script.Core.Kernel)

-- 4. Mulai 3-Phase Loader (Phase 1, 2, 3)
Kernel:Init(Config, Logger) -- Beri Kernel akses langsung ke modul inti

print("PHASE 0: Bootstrap Selesai. Kernel mengambil alih.")
```

#### 1.2. Fase 1-3: Kernel Loader (ModuleScript)

`Core/Kernel.lua` (ModuleScript) berisi _logic_ 3-Phase Loader yang aman.

**Contoh Kode (`src/Server/Core/Kernel.lua`):**

```lua
local ServerKernel = {}
ServerKernel.Modules = {}

-- Cache modul inti dari Phase 0
local Logger
local Config

-- Central function to get modules
function ServerKernel:GetModule(moduleName)
    local module = self.Modules[moduleName]
    if not module then
        -- Logger dijamin sudah ada
        Logger:Warn("Kernel", "SYSTEM", "Module not found: " .. moduleName)
    end
    return module
end

function ServerKernel:Init(configModule, loggerModule)
    -- === PHASE 1: CORE BOOT (Menyimpan Modul Inti) ===
    Config = configModule
    Logger = loggerModule
    ServerKernel.Modules["Config"] = Config
    ServerKernel.Modules["Logger"] = Logger

    Logger:Info("Kernel", "SYSTEM", "PHASE 1: Core Boot Selesai.")

    -- === PHASE 2: MODULE DISCOVERY (Registrasi) ===
    -- (Sesuai Decision #2: Domain Hierarchy - NAMA BARU)
    local DOMAIN_FOLDERS = { "Core", "Services", "OVHL_Modules" }

    for _, domainFolder in ipairs(DOMAIN_FOLDERS) do
        local domain = script.Parent.Parent:FindFirstChild(domainFolder) -- Naik ke Server/ lalu turun
        if not domain then continue end

        for _, item in ipairs(domain:GetChildren()) do
            if item:IsA("Folder") and item:FindFirstChild("init") then
                local moduleName = item.Name
                if ServerKernel.Modules[moduleName] then continue end -- Hindari load ulang (misal: Kernel)

                -- pcall WAJIB untuk 3rd party & syntax error
                local success, module = pcall(require, item.init)

                if success then
                    ServerKernel.Modules[moduleName] = module
                else
                    -- Jika modul gagal di-load, sisa sistem tetap jalan
                    Logger:Error("Kernel", "SYSTEM", "PHASE 2: Modul " .. moduleName .. " GAGAL di-load!", module)
                end
            end
        end
    end
    Logger:Info("Kernel", "SYSTEM", "PHASE 2: Module Discovery Selesai.")

    -- === PHASE 3: INITIALIZATION (Inter-dependency) ===
    -- Di sini semua modul sudah di-require, tapi belum :Init()
    -- Ini aman dari circular dependency
    for name, module in pairs(ServerKernel.Modules) do
        -- Hindari Init ulang modul inti
        if name ~= "Logger" and name ~= "Config" then
            if type(module) == "table" and type(module.Init) == "function" then
                -- (FIX) Bungkus :Init() dalam pcall juga
                local success, err = pcall(module.Init, module)
                if not success then
                    Logger:Error("Kernel", "SYSTEM", "PHASE 3: Modul " .. name .. " GAGAL di-Init!", err)
                end
            end
        end
    end
    Logger:Info("Kernel", "SYSTEM", "PHASE 3: Inisialisasi Selesai. Server Siap.")
end

return ServerKernel
```

#### 1.3. Ketahanan Sistem (Anti-Crash)

Arsitektur ini _anti-crash_. Seluruh proses `require` di `Phase 2` dibungkus dalam `pcall`. Jika `Modul A` (misal: `TopbarIntegration`) gagal di-load (karena error _syntax_ atau 3rd party `TopbarPlus` tidak ada), `pcall` akan menangkapnya. `Logger` akan mencatat error, dan **hanya `Modul A` yang gagal**. Kernel akan _tetap lanjut_ me-load `Modul B`, `C`, dan `D`. Sisa 9 modul lain akan tetap berjalan normal.

---

### Decision #2: Struktur Folder (Domain Organization)

Mengadopsi arsitektur 3-Domain (`Core`, `Services`, `OVHL_Modules`) untuk memisahkan tanggung jawab (Separation of Concerns).

| Domain           | Emoji | Tujuan                          | Contoh                         |
| :--------------- | :---- | :------------------------------ | :----------------------------- |
| **Core**         | 🎯    | Fondasi sistem, lintas modul    | Kernel, PermissionSync         |
| **Services**     | 🛎️    | Integrasi eksternal, I/O        | DataModule, MonetizationModule |
| **OVHL_Modules** | 🎮    | (BARU) Logika gameplay spesifik | MusicModule, ZoneModule        |
| **Legacy**       | 🔧    | Kode usang (Diarsipkan)         | Kohl's Admin Addons            |

#### 2.1. Struktur File V2 (Target)

Struktur ini **WAJIB** diikuti dan sudah _Rojo-aware_ (`.server.lua` / `.client.lua`).

```text
src/
├── Client/
│   ├── init.client.lua         <-- (LocalScript) BOOTSTRAPPER KLIEN
│   └── Core/
│       └── Kernel.lua          <-- (ModuleScript) Kernel Loader Klien
│   └── ... (Services, OVHL_Modules)
│
├── Server/
│   ├── init.server.lua         <-- (Script) BOOTSTRAPPER SERVER
│   ├── Config.lua              <-- (ModuleScript) Config
│   └── Core/
│       └── Kernel.lua          <-- (ModuleScript) Kernel Loader Server
│       └── PermissionSync/     <-- (Modul)
│           └── init.lua
│   ├── Services/
│   │   └── DataModule/         <-- (Modul)
│   │       └── init.lua
│   └── OVHL_Modules/           <-- (Modul) NAMA BARU
│       └── MusicModule/
│           └── init.lua
│
└── Shared/
    ├── Logger/                 <-- (Modul) Logger Terpusat
    │   └── init.lua
    └── Network/                <-- (Modul) Remote Event Wrapper
        └── init.lua
```

#### 2.2. Rojo `default.project.json` (FIXED)

Ini adalah _mapping_ Rojo yang **WAJIB** digunakan. (Blok `Kohl's Admin` telah **dihapus** sesuai permintaan).

```json
{
    "name": "PuraPuraPesta",
    "tree": {
        "$className": "DataModel",

        "ServerScriptService": {
            "Server": {
                "$path": "src/Server"
            }
        },

        "ReplicatedStorage": {
            "Shared": {
                "$path": "src/Shared"
            }
        },

        "StarterPlayer": {
            "StarterPlayerScripts": {
                "Client": {
                    "$path": "src/Client"
                }
            }
        }
    }
}
```

---

### Decision #3: Struktur Internal Modul (BARU)

Untuk menghindari "God Files" (file `init.lua` 2000 baris), setiap modul **WAJIB** mengikuti Pola Dasar 5 File dan Aturan Eskalasi.

#### 3.1. Pola Dasar 5 File

Setiap modul baru di `OVHL_Modules/`, `Services/`, atau `Core/` **WAJIB** dimulai dengan 5 file ini:

```text
NamaModul/
├── init.lua        (API / Controller)
├── Config.lua      (Setting / Konstanta)
├── Logic.lua       (Otak / Fungsi Private)
├── State.lua       (Memori / Data Runtime)
└── Handlers.lua    (Telinga / Event Listeners)
```

-   **`init.lua` ("Wajah"):** Satu-satunya file yang di-`require` oleh `Kernel`. Bertugas me-`require` file internalnya (`Config`, `Logic`, dll) dan mengambil _dependencies_ (`Logger`, `DataModule`) dari `Kernel:GetModule()`.
-   **`Logic.lua` ("Otak"):** Berisi fungsi-fungsi _private_ yang rumit.
-   **`Handlers.lua` ("Telinga"):** Berisi semua _listener_ event (`_onRemoteRequest`, `_onPlayerJoin`).

#### 3.2. Aturan Eskalasi (Jika Modul Kompleks)

Jika file "Pekerja" (seperti `Logic.lua`) menjadi terlalu kompleks (misal > 300 baris), file tersebut **WAJIB** dipecah menjadi file-file _pekerja_ yang lebih spesifik. File _pekerja_ tambahan ini tetap dianggap _private_ dan HANYA boleh di-`require` oleh `init.lua` modul itu sendiri.

**Contoh Struktur Eskalasi (`src/Server/OVHL_Modules/MusicModule/`):**

```text
MusicModule/
├── init.lua            <-- "Wajah". API: :PlaySong(), :RequestSong(), :Init()
├── Config.lua          <-- (Pola Dasar)
├── State.lua           <-- (Pola Dasar)
├── Handlers.lua        <-- (Pola Dasar)
│
├── AutoDJ.lua          <-- (Eskalasi dari Logic) Logic AutoDJ
└── Queue.lua           <-- (Eskalasi dari Logic) Logic antrian RequestSong
```

_(Di sini, file `Logic.lua` digantikan oleh `AutoDJ.lua` dan `Queue.lua`)_

#### 3.3. Penjelasan: Kenapa Manual Registry? (PENTING)

Struktur internal modul (Level 2) **WAJIB** menggunakan "Manual Registry" (`require` manual), tidak seperti Kernel (Level 1) yang menggunakan "Smart Discover".

**Kenapa?**

1.  **Kendali Urutan Loading:** `init.lua` _harus_ menjamin `Config.lua` di-`require` **sebelum** `Logic.lua` yang menggunakannya. _Smart discover_ tidak bisa menjamin urutan ini dan akan menyebabkan _crash_.
2.  **Dependency Injection:** _Manual registry_ memungkinkan `init.lua` (Manajer) menyuntikkan "alat" (seperti `Logger` atau `DataModule`) ke "pekerja"-nya (`Logic.lua`).

    ```lua
    -- Di dalam init.lua
    local Logic = require(script.Logic)
    local Logger = Kernel:GetModule("Logger")

    -- "Suntik" alat ke pekerja
    Logic:Init(Logger)
    ```

---

### Decision #4: Komunikasi Antar Modul (Registry)

Modul dilarang `require` modul lain secara langsung. Komunikasi **WAJIB** melalui `Kernel:GetModule()`.

#### 4.1. Aturan Anti-Circular Dependency

1.  **DILARANG** `require` modul lain di _top-level_ (di luar fungsi).
2.  **DILARANG** memanggil `Kernel:GetModule()` di _top-level_.
3.  **WAJIB** memanggil `Kernel:GetModule()` **HANYA** di dalam `Init()` (Phase 3) dan menyimpannya di _cache_ (variabel `local`).

Ini menjamin bahwa saat `Init()` dipanggil, _semua_ modul lain sudah di-`require` (Phase 2) dan siap diambil.

**Contoh Kode (`src/Server/OVHL_Modules/MusicModule/init.lua`):**

```lua
local MusicModule = {}

-- (FIX) Path Kernel V2
local ServerKernel = require(script.Parent.Parent.Parent.Core.Kernel)
local Logger

-- Dependensi Internal (Pekerja)
local AutoDJ = require(script.AutoDJ)
local Queue = require(script.Queue)
local ModulConfig = require(script.Config)
local ModulState = require(script.State)
local Handlers = require(script.Handlers)

-- Cache Modul Layanan (DIISI SAAT INIT)
local PermissionSync
local RemoteWrapper

function MusicModule:Init()
    -- WAJIB: Ambil dependensi HANYA di dalam Init()
    Logger = ServerKernel:GetModule("Logger")
    PermissionSync = ServerKernel:GetModule("PermissionSync")

    local SharedKernel = require(game:GetService("ReplicatedStorage").Shared.Kernel)
    RemoteWrapper = SharedKernel:GetModule("RemoteWrapper")

    -- Inisialisasi pekerja internal (lewatkan dependensi)
    Handlers:Init(ServerKernel, self) -- 'self' adalah tabel MusicModule
    AutoDJ:Init(ServerKernel, self)

    Logger:Info("MusicModule", "MUSIC", "MusicModule Initialized")
end

-- Fungsi Publik (API)
function MusicModule:RequestSong(player, songId)
    -- Aman dipakai karena Init() sudah jalan
    local role = PermissionSync:GetRole(player)

    if role == "OVHL_Admin" or role == "OVHL_VIP" then
        -- Panggil pekerja internal
        Queue:AddSong(songId, player)
    else
        Logger:Warn("MusicModule", "MUSIC", "Gagal request (no perm)")
        -- (Opsional: Panggil MonetizationModule)
    end
end

return MusicModule
```

---

### Decision #5: Komunikasi Network (RemoteWrapper)

Semua komunikasi Client-Server **WAJIB** melalui `RemoteWrapper` terpusat.

**Struktur File (`src/Shared/Network/`):**

```text
Network/
├── init.lua          <-- API Publik (RemoteWrapper)
├── Events.lua        <-- WAJIB: Daftar semua RemoteEvent/Function
└── RemoteWrapper.lua <-- Logic internal (pembuatan remote)
```

**`Events.lua` (Contoh):**

```lua
return {
    -- Format: [EventName] = "RemoteType"
    ["UpdateUI"] = "Event",     -- Server -> Client
    ["RequestSong"] = "Event",  -- Client -> Server
    ["RequestSalam"] = "Event", -- Client -> Server
}
```

---

### Decision #6: Logger & Log Level System

Sistem **WAJIB** menggunakan satu Logger Terpusat (`Shared/Logger`) yang _Config-aware_.

#### 6.1. Log Level Hierarchy

```
DEBUG = 1   -- 🔍 Verbose: data dumps, pemanggilan fungsi (HANYA development)
INFO = 2    -- ℹ️ Normal: aksi user, perubahan state (Default production)
WARN = 3    -- ⚠️ Warning: error yang bisa pulih, deprecated
ERROR = 4   -- 💀 Critical: kegagalan, exceptions (SELALU tampil)
PERF = 5    -- ⚡ Performance: data timing (Opsional)
```

#### 6.2. Struktur Config (`src/Server/Config.lua`)

```lua
return {
    Debug = {
        GlobalLogLevel = "INFO", -- "DEBUG" | "INFO" | "WARN" | "ERROR"

        ModuleLevels = {
            MusicModule = "DEBUG", -- Override: MusicModule bawel
            ZoneModule = "INFO",   -- Override: ZoneModule diam
        },

        EnablePerfLogs = false,
    }
}
```

#### 6.3. Format Log (Clean - Tanpa Timestamp)

**Template:**
`{REALM} {DOMAIN} {LEVEL} {TYPE} [{MODULE}] {MESSAGE}`
`└─ Data: {JSON_DUMP} (opsional)`

**Contoh Output (`GlobalLogLevel = "DEBUG"`):**

```text
🖥️ 🎵 🔍 📊 [MusicModule] PlaySong called
└─ Data: {"SongID":"123","Zone":"dangdut"}
🖥️ 🎵 ℹ️ 📢 [MusicModule] Playing: Kopi Dangdut - Fahmi Shahab
🖥️ 🎵 ⚡ 📢 [MusicModule] PlaySong took 850.32ms
```

**Contoh Output (`GlobalLogLevel = "INFO"`):**

```text
🖥️ 🎵 ℹ️ 📢 [MusicModule] Playing: Kopi Dangdut - Fahmi Shahab
```

#### 6.4. Template Kode Logger (`src/Shared/Logger/init.lua`)

```lua
local Logger = {}
local Config -- (FIX) Ditugaskan oleh Kernel via Init()
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local IS_SERVER = RunService:IsServer()
local ENV_EMOJI = IS_SERVER and "🖥️" or "💻"
local LOG_LEVELS = { DEBUG = 1, INFO = 2, WARN = 3, ERROR = 4, PERF = 5 }
-- ... (Tabel EMOJI lengkap) ...

-- (FIX) Init sekarang menerima Config yang sudah di-load
function Logger:Init(configModule)
    Config = configModule
    if Config or not IS_SERVER then -- Klien tidak butuh config
        self:Info("Logger", "SYSTEM", "Logger V5 (Unified) Initialized")
    else
        self:Error("Logger", "SYSTEM", "Logger Init FAILED: Config module is nil!")
    end
end

-- (FIX) Core logging function yang Config-aware
local function ShouldLog(moduleName, level)
    -- Klien (yang Config-nya nil) default ke INFO
    local globalLevelKey = "INFO"
    if Config and Config.Debug and Config.Debug.GlobalLogLevel then
        globalLevelKey = Config.Debug.GlobalLogLevel
    end
    local globalLevel = LOG_LEVELS[globalLevelKey] or LOG_LEVELS.INFO

    local moduleLevelKey = nil
    if Config and Config.Debug and Config.Debug.ModuleLevels then
        moduleLevelKey = Config.Debug.ModuleLevels[moduleName]
    end

    local threshold = moduleLevelKey and LOG_LEVELS[moduleLevelKey] or globalLevel
    return LOG_LEVELS[level] >= threshold
end

local function getEmoji(key)
    -- ... (logic get emoji)
end

-- (FIX) Fungsi log tanpa timestamp
function Logger:Info(moduleName, domain, message)
    if not ShouldLog(moduleName, "INFO") then return end
    print(string.format(
        "%s %s %s 📢 [%s] %s",
        ENV_EMOJI, getEmoji(domain), getEmoji("INFO"), moduleName, message
    ))
end

function Logger:Debug(moduleName, domain, messageType, message, data)
    if not ShouldLog(moduleName, "DEBUG") then return end
    print(string.format(
        "%s %s %s %s [%s] %s",
        ENV_EMOJI, getEmoji(domain), getEmoji("DEBUG"), getEmoji(messageType), moduleName, message
    ))
    if data then
        -- ... (logic pcall JSONEncode) ...
        print("└─ Data:", jsonData)
    end
end

function Logger:Error(moduleName, domain, message, data)
    -- Error SELALU log
    warn(string.format(
        "%s %s %s 📢 [%s] %s",
        ENV_EMOJI, getEmoji(domain), getEmoji("ERROR"), moduleName, message
    ))
    if data then
        -- ... (logic pcall JSONEncode) ...
        warn("└─ Data:", jsonData)
    end
end

-- ... (fungsi Warn, Perf) ...

return Logger
```

---

### Decision #7: Kontrak Atribut (Builder-Scripter)

Builder (Desainer) **WAJIB** mengkonfigurasi _gameplay_ via Atribut. Scripter (Koder) **WAJIB** memvalidasi Atribut tersebut.

#### 7.1. Konvensi Penamaan

`[Domain]_[Property]` (Contoh: `Zone_ID`, `Audio_Side`, `UI_Type`)

#### 7.2. Kontrak Scripter (Validasi WAJIB)

Semua modul yang membaca Atribut (seperti `ZoneModule`) **WAJIB** memvalidasinya saat `Init()` dan memberikan _fallback_ jika Atribut tidak ada, menggunakan `Logger:Warn` atau `Logger:Error`.

**Contoh Kode (`src/Server/OVHL_Modules/ZoneModule/Logic.lua`):**

```lua
function Logic.ScanZones()
    local Logger = ServerKernel:GetModule("Logger") -- Asumsi Kernel sudah di-pass
    local stages = workspace:WaitForChild("Stages")

    for _, stage in ipairs(stages:GetChildren()) do
        local zoneID = stage:GetAttribute("Zone_ID")

        -- VALIDASI KONTRAK
        if not zoneID then
            Logger:Error("ZoneModule", "ZONE", "Missing WAJIB Attribute: Zone_ID", {
                Model = stage:GetFullName()
            })
            continue -- Skip zona invalid
        end

        local displayName = stage:GetAttribute("Zone_DisplayName")
        if not displayName then
            Logger:Warn("ZoneModule", "ZONE", "Missing Attribute: Zone_DisplayName. Using Zone_ID.", {
                Model = stage.Name
            })
            displayName = zoneID
        end

        -- ... (registrasi zona)
    end
end
```

---

### Decision #8: Integrasi 3rd Party (TopbarPlus)

Integrasi **WAJIB** diisolasi di dalam modul `Services/`. Kegagalan 3rd party _tidak boleh_ merusak Kernel.

-   **Pembagian Tanggung Jawab:** TopbarPlus HANYA menangani ikon di _navbar_. `OVHL UI` (Decision #10) menangani _isi_ panel/modal.
-   **Ketahanan:** `pcall` di `Phase 2` Kernel (Decision #1.2) akan menangkap error jika `TopbarPlus` gagal di-`require`, dan hanya `TopbarIntegration` yang akan mati.

**Contoh Kode (`src/Client/Services/TopbarIntegration/init.lua`):**

```lua
local TopbarIntegration = {}
-- (FIX) Path 3rd Party yang Benar
local Icon = require(game:GetService("ReplicatedStorage").TopbarPlus.Icon)
local ClientKernel

function TopbarIntegration:Init()
    ClientKernel = require(script.Parent.Parent.Parent.Core.Kernel)
    local Logger = ClientKernel:GetModule("Logger")

    local musicIcon = Icon.new():setLabel("Music")

    musicIcon.selected:Connect(function()
        local UIModule = ClientKernel:GetModule("UIModule")
        if UIModule then
             -- Memanggil modul OVHL_Modules/ untuk membuka panel
             UIModule:ToggleMusicPanel()
        end
    end)
    Logger:Info("TopbarIntegration", "UI", "Topbar icon created")
end

return TopbarIntegration
```

---

### Decision #9: Arsitektur Permission Terpadu (Aggregator)

Ini adalah perombakan **FINAL** (V3) berdasarkan masukan `MainModule.lua` dan _config_ Kohl's.

**Konteks:**
Sistem kita butuh sistem izin yang _robust_ dan _anti-crash_. Kita perlu `require` Kohl's Admin sebagai sumber izin utama, tapi kita **WAJIB** punya _fallback_ jika Kohl's gagal.

**Keputusan:**
Modul `Core/PermissionSync` akan menjadi "Permission Aggregator". Modul ini akan memiliki _service fallback_ internal yang _mencerminkan_ logika Kohl's (cek Gamepass, Grup, dll).

#### 9.1. Struktur Internal `Core/PermissionSync`

Modul ini akan "Eskalasi" (Sesuai Decision #3.2):

```text
Core/PermissionSync/
├── init.lua        (API Publik: :GetRole(player))
├── Config.lua      (Config Fallback: berisi userRoles, gamepassRoles, groupRoles internal kita)
├── State.lua       (Cache: playerRoles[userId], KohlInterface)
├── Handlers.lua    (Event: OnPlayerAdded untuk pre-cache)
├── Logic_Kohl.lua    (Pekerja Internal: Logic untuk baca API Kohl's)
└── Logic_OVHL.lua    (Pekerja Internal: Logic untuk baca Config.lua fallback kita)
```

#### 9.2. `Config.lua` Fallback (Meniru Kohl's)

File `Core/PermissionSync/Config.lua` kita akan berisi struktur _fallback_ yang akan dipakai jika Kohl's gagal di-load.

```lua
-- Core/PermissionSync/Config.lua
return {
    -- Definisikan Role Internal kita
    Roles = {
        OVHL_Guest = { Rank = 0 },
        OVHL_VIP = { Rank = 1 },
        OVHL_Admin = { Rank = 100 }
    },
    -- Sumber Izin Internal (Fallback)
    userRoles = {
        OVHL_Admin = { 12345, 67890 }, -- UserID
    },
    gamepassRoles = {
        [987654321] = { "OVHL_VIP" } -- ID Gamepass
    },
    groupRoles = {
        [1234567] = { -- ID Grup
            { rank = 255, role = "OVHL_Admin" },
            { rank = 100, role = "OVHL_VIP" }
        }
    }
}
```

#### 9.3. Alur Logika `PermissionSync:GetRole(player)` (Di dalam `init.lua`)

Ini adalah alur _anti-crash_ kita:

1.  **Cek Cache:** Cek `State.lua`. Jika role player ada, `return` role dari cache.

2.  **Coba Kohl's Admin (Prioritas 1):**

    -   Di `Init()`, `pcall` `require(Kohl.MainModule)`. Jika berhasil, simpan `_K` di `State.lua`.
    -   Jika `_K` ada di `State`, panggil `Logic_Kohl:GetRole(_K, player)`.
    -   `Logic_Kohl` akan membaca `_K.Data.members[userId].persist` dan `_K.Data.roles[roleId]` (sesuai temuan kita) dan me-return role yang _di-mapping_ (misal: "Admin" Kohl's -> "OVHL_Admin").

3.  **Coba Fallback OVHL (Prioritas 2):**

    -   (Hanya jalan jika Kohl's gagal di-load ATAU `Logic_Kohl` me-return "OVHL_Guest").
    -   `Logger:Info("PermissionSync", "ADMIN", "Kohl's tidak ditemukan/Guest, cek fallback internal OVHL...")`.
    -   Panggil `Logic_OVHL:GetRole(player)`.

4.  **Logika Fallback (`Logic_OVHL.lua`):**

    -   `Logic_OVHL` akan `require` `Config.lua` (milik `PermissionSync`) dan `MonetizationModule`.
    -   Dia akan cek `Config.userRoles`, `Config.gamepassRoles`, dan `Config.groupRoles`.
    -   Dia akan mengambil role _tertinggi_ yang ditemukan.

5.  **Return:** Simpan role final ("OVHL_Admin", "OVHL_VIP", atau "OVHL_Guest") ke cache `State.lua` dan `return` role tersebut.

---

### Decision #10: UI Engine (OVHL UI System)

Semua UI kustom (Modal, Panel, Tombol) **WAJIB** menggunakan `OVHL UI System` terpusat (yang akan kita bangun di Fase 2).

**Struktur File (`src/Shared/OVHL_UI/`):**

```text
Shared/OVHL_UI/
├── init.lua          <-- UI Kernel / Component Factory
├── ModalSystem/    <-- Popups, Dialogs
├── LayoutSystem/   <-- Grid, Stack
├── ContentComponents/ <-- Card, List
└── FormComponents/   <-- Button, Slider
```

Modul `OVHL_Modules/` (seperti `Client/OVHL_Modules/UIModule`) dilarang `Instance.new("Frame")`. Mereka **WAJIB** memanggil `OVHLUI.ModalSystem:Open(...)`.

---

### Decision #11: Filosofi & Panduan UI Generation

(Bagian ini adalah _refactor_ dari `05-ui-builder.md`, mengunci standar _hardcode_ UI).

#### 11.1. Filosofi Dasar

-   **Thinking in Percentages, NOT Pixels:** AI **WAJIB** menggunakan `UDim2.new(SCALE, 0, SCALE, 0)` untuk ukuran. Ukuran berbasis piksel (Offset) dilarang kecuali untuk `UIPadding`, `UIStroke`, atau `ScrollBarThickness`.
-   **Hierarki Wajib:** `ScreenGui` -> `PaddingFrame` (Safe Area) -> `MainContainer` (Aspect Ratio) -> `ContentFrame` (UIPadding) -> `UIListLayout`.
-   **Layout Wajib:** Semua _item_ **WAJIB** diatur oleh `UIListLayout` atau `UIGridLayout`. Pengaturan posisi manual (`Position`) dilarang keras kecuali untuk _container_ utama.
-   **Responsive Wajib:** Semua elemen teks **WAJIB** `TextScaled = true` (kecuali ditentukan lain).

#### 11.2. Visual Design System (Ringkasan)

(AI akan merujuk ke fungsi-fungsi di bawah ini saat membuat UI di Fase 2).

-   **Colors:** (Disalin dari `05-ui-builder.md` Section 3.1)
    ```lua
    local COLORS = {
        PRIMARY = Color3.fromRGB(0, 170, 255),
        SECONDARY = Color3.fromRGB(255, 0, 127),
        GRAY_DARK = Color3.fromRGB(60, 60, 60)
        -- ... etc
    }
    ```
-   **Typography:** (Disalin dari `05-ui-builder.md` Section 3.2)
    ```lua
    local TYPOGRAPHY = {
        DISPLAY = { Font = Enum.Font.GothamBlack, Size = 24 },
        HEADING = { Font = Enum.Font.GothamBold, Size = 20 },
        BODY = { Font = Enum.Font.Gotham, Size = 14 }
        -- ... etc
    }
    ```
-   **Corner Radius:** (Disalin dari `05-ui-builder.md` Section 3.3)
    ```lua
    local CORNER_RADIUS = {
        SM = UDim.new(0, 5),
        MD = UDim.new(0, 10),
        LG = UDim.new(0, 15)
        -- ... etc
    }
    ```

#### 11.3. Template Fungsi UI (Contoh)

AI **WAJIB** mengadopsi template ini saat menulis kode UI.

-   **Template TextLabel (Wajib `TextScaled`)**

    ```lua
    function createTextLabel(typography, text, color)
        local label = Instance.new("TextLabel")
        label.Font = typography.Font
        label.TextSize = typography.Size
        label.TextColor3 = color or COLORS.WHITE
        label.Text = text
        label.TextScaled = true -- WAJIB
        label.TextWrapped = true
        label.BackgroundTransparency = 1
        return label
    end
    ```

-   **Template Vertical Layout (Wajib `LayoutOrder`)**
    ```lua
    function createVerticalLayout(padding)
        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.Padding = UDim.new(0, padding or 0)
        layout.SortOrder = Enum.SortOrder.LayoutOrder -- WAJIB!
        return layout
    end
    ```

#### 11.4. Audit & QA (Sesuai `05-ui-builder.md` Section 10)

-   AI akan menggunakan _logic_ dari `05-ui-builder.md` Section 10 (fungsi `auditUI`) sebagai referensi mental untuk _self-check_ kode UI yang dihasilkannya.
-   **Checklist AI (Wajib):**
    1.  ✅ Semua ukuran pakai SCALE?
    2.  ✅ Semua elemen punya `LayoutOrder`?
    3.  ✅ Semua teks pakai `TextScaled = true`?
    4.  ✅ `ScreenGui.IgnoreGuiInset = true`?
    5.  ✅ `UIAspectRatioConstraint` dipakai untuk container utama?

---

**Dokumen Selesai. Versi 2.1 (Refactored, Permission V3).**
