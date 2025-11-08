# 🏛️ 01 - ARSITEKTUR (KITAB SUCI TEKNIS)

**Versi:** 1.0.0
**Status:** FINAL
**Tujuan:** Dokumen ini adalah "Kitab Suci" (Single Source of Truth) untuk **Arsitektur Teknis Proyek**. Dokumen ini mendefinisikan _BAGAIMANA_ kita membangun "OVHL Core System" yang _reusable_, _scalable_, _anti-crash_, dan _future-proof_.

---

## 🚀 POKOK-POKOK ARSITEKTUR

1.  **Entrypoint Dikelola Rojo:** `init.server.lua` (Script) & `init.client.lua` (LocalScript) adalah _entrypoint_ yang otomatis jalan, bukan `ModuleScript`.
2.  **Kernel 4-Fase:** Bootstrap (`Phase 0`) terpisah dari Kernel Loader (`Phase 1-3`) untuk menjamin _priority load_ (Logger & Config).
3.  **Prioritas Domain (Anti-Crash):** Kernel **WAJIB** me-load dan meng-`Init` modul sesuai urutan prioritas: `Core` -> `Services` -> `OVHL_Modules`. Ini menjamin `Services` (Penyedia) sudah siap sebelum `OVHL_Modules` (Pengguna) memanggilnya.
4.  **Logger Terpusat:** Satu `Shared/Logger` dipakai oleh Server & Client, di-Init dengan _Dependency Injection_ (anti _circular dependency_).
5.  **Struktur Domain:** Modul dibagi berdasarkan tanggung jawab: `Core`, `Services`, `OVHL_Modules` (menggantikan "Business").
6.  **Struktur Internal Modul (Anti-"God File"):** Setiap modul **WAJIB** memisahkan `init.lua` (API), `Config.lua`, `Controller/` (Otak), dan `Services/` (Telinga & Tangan).
7.  **Komunikasi Aman (Anti-Circular):** Komunikasi antar modul _hanya_ via `Kernel:GetModule()`, dan _hanya_ di dalam `Init()` (untuk _cache_), BUKAN di _top-level_. Logika baru jalan _setelah_ `Phase 3` selesai.
8.  **Permission Aggregator (Anti-Crash):** Sistem izin (`Core/PermissionSync`) adalah _service_ internal yang _mencoba_ membaca Kohl's Admin dan memiliki _fallback_ penuh (cek Gamepass, Grup) jika Kohl's gagal.

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
local Kernel = require(script.Core.Kernel)

-- 4. Mulai 3-Phase Loader (Phase 1, 2, 3)
Kernel:Init(Config, Logger) -- Beri Kernel akses langsung ke modul inti

Logger:Info("Bootstrap", "SYSTEM", "PHASE 0: Bootstrap Selesai. Kernel mengambil alih.")
```

#### 1.2. Fase 1-3: Kernel Loader (Dengan Prioritas Domain)

`Core/Kernel.lua` (ModuleScript) berisi _logic_ 3-Phase Loader yang aman dan **mengikuti urutan prioritas** untuk menjamin `Services` siap sebelum `OVHL_Modules`.

**Contoh Kode (`src/Server/Core/Kernel.lua`):**

```lua
local ServerKernel = {}
ServerKernel.Modules = {}

-- Cache modul inti dari Phase 0
local Logger
local Config

-- (FIX) DOMAIN_PRIORITY WAJIB untuk urutan load
local DOMAIN_PRIORITY = { "Core", "Services", "OVHL_Modules" }

-- Central function to get modules
function ServerKernel:GetModule(moduleName)
    local module = self.Modules[moduleName]
    if not module then
        Logger:Warn("Kernel", "SYSTEM", "Module not found: " .. moduleName)
    end
    return module
end

function ServerKernel:Init(configModule, loggerModule)
    -- === PHASE 1: CORE BOOT ===
    Config = configModule
    Logger = loggerModule
    ServerKernel.Modules["Config"] = Config
    ServerKernel.Modules["Logger"] = Logger
    ServerKernel.Modules["Kernel"] = self

    Logger:Info("Kernel", "SYSTEM", "PHASE 1: Core Boot Selesai.")

    -- === PHASE 2: MODULE DISCOVERY (SESUAI URUTAN PRIORITAS) ===
    Logger:Info("Kernel", "SYSTEM", "PHASE 2: Module Discovery Dimulai...")
    for _, domainName in ipairs(DOMAIN_PRIORITY) do
        local domainFolder = script.Parent.Parent:FindFirstChild(domainName)
        if not domainFolder then
            Logger:Warn("Kernel", "SYSTEM", "Domain folder not found: " .. domainName)
            continue
        end

        for _, item in ipairs(domainFolder:GetChildren()) do
            if item:IsA("Folder") and item:FindFirstChild("init") then
                local moduleName = item.Name
                if ServerKernel.Modules[moduleName] then continue end

                -- pcall WAJIB untuk 3rd party & syntax error
                local success, module = pcall(require, item.init)
                if success then
                    ServerKernel.Modules[moduleName] = module
                    Logger:Debug("Kernel", "SYSTEM", "ACTION", "Modul " .. moduleName .. " di-load")
                else
                    Logger:Error("Kernel", "SYSTEM", "PHASE 2: Modul " .. moduleName .. " GAGAL di-load!", module)
                end
            end
        end
    end
    Logger:Info("Kernel", "SYSTEM", "PHASE 2: Module Discovery Selesai.")

    -- === PHASE 3: INITIALIZATION (SESUAI URUTAN PRIORITAS) ===
    Logger:Info("Kernel", "SYSTEM", "PHASE 3: Inisialisasi Dimulai...")
    for _, domainName in ipairs(DOMAIN_PRIORITY) do
        local domainFolder = script.Parent.Parent:FindFirstChild(domainName)
        if not domainFolder then continue end

        for _, item in ipairs(domainFolder:GetChildren()) do
            local moduleName = item.Name
            local module = ServerKernel.Modules[moduleName]

            -- Cek jika modul sudah di-load & belum di-Init
            if module and module ~= self then -- Jangan Init diri sendiri (Kernel)
                if type(module) == "table" and type(module.Init) == "function" then
                    local success, err = pcall(module.Init, module)
                    if not success then
                        Logger:Error("Kernel", "SYSTEM", "PHASE 3: Modul " .. moduleName .. " GAGAL di-Init!", err)
                    end
                end
            end
        end
    end
    Logger:Info("Kernel", "SYSTEM", "PHASE 3: Inisialisasi Selesai. Server Siap.")
end

return ServerKernel
```

#### 1.3. Ketahanan Sistem (Anti-Crash)

Arsitektur ini _anti-crash_.

1.  **Anti-Crash 3rd Party:** Seluruh proses `require` di `Phase 2` dibungkus dalam `pcall`. Jika `TopbarIntegration` gagal (karena `TopbarPlus` tidak ada), `Logger` akan mencatat error dan Kernel **TETAP LANJUT** me-load 9 modul lainnya.
2.  **Anti-Crash Urutan Load:** `DOMAIN_PRIORITY` menjamin `Services/` (Penyedia) sudah 100% di-`Init()` _sebelum_ `OVHL_Modules/` (Pengguna) mulai di-`Init()`. Ini menyelesaikan masalah "A -> Z -> X".
3.  **Anti-Crash Config Nil:** Modul **WAJIB** mengikuti `Decision #4.2` (Defensive Config) untuk mencegah _crash_ "index nil".

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
📁 src/
├── 📁 Client/
│   ├── 📜 init.client.lua         <-- (LocalScript) BOOTSTRAPPER KLIEN
│   └── 📁 Core/
│       └── 📜 Kernel.lua          <-- (ModuleScript) Kernel Loader Klien
│   └── ... (Services, OVHL_Modules)
│
├── 📁 Server/
│   ├── 📜 init.server.lua         <-- (Script) BOOTSTRAPPER SERVER
│   ├── 📜 Config.lua              <-- (ModuleScript) Config (Global)
│   └── 📁 Core/
│       ├── 📜 Kernel.lua          <-- (ModuleScript) Kernel Loader Server
│       └── 📁 PermissionSync/     <-- (Modul)
│           └── 📜 init.lua
│   ├── 📁 Services/
│   │   └── 📁 DataModule/         <-- (Modul)
│   │       └── 📜 init.lua
│   └── 📁 OVHL_Modules/           <-- (Modul) NAMA BARU
│       └── 📁 MusicModule/
│           └── 📜 init.lua
│
└── 📁 Shared/
    ├── 📁 Logger/                 <-- (Modul) Logger Terpusat
    │   └── 📜 init.lua
    └── 📁 Network/                <-- (Modul) Remote Event Wrapper
        └── 📜 init.lua
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

Untuk menghindari "God Files" (file `init.lua` 2000 baris) dan menjamin _maintenance_ yang gampang, setiap modul **WAJIB** mengikuti struktur folder internal ini:

#### 3.1. Pola Struktur Folder (WAJIB)

```text
📁 NamaModul/
├── 📜 init.lua        (API Publik / "Wajah")
├── 📜 Config.lua      (Setting / Konstanta Modul)
│
├── 📁 Controller/     ("Otak" / Logic Bisnis)
│   └── 📜 MainLogic.lua   (atau file eskalasi seperti AutoDJ.lua)
│
└── 📁 Services/       ("Tangan & Telinga" / Pendukung)
    ├── 📜 Handlers.lua    (Semua Event Listener)
    └── 📜 State.lua       (Manajemen Memori / Cache Runtime)
```

#### 3.2. Penjelasan Peran

1.  **`init.lua` (API Publik):**
    -   Satu-satunya file yang di-`require` oleh `Kernel`.
    -   **Tugas:** Me-`require` file-file dari `Controller/` dan `Services/`, mengambil _dependencies_ (`Logger`, `DataModule`) dari `Kernel`, menyuntikkannya ke _pekerja_ internal, dan me-_return_ tabel API publik (`:PlaySong()`, `:GetRole()`).
2.  **`Config.lua`:**
    -   Berisi `return { ... }` dengan setting _khusus_ modul itu.
3.  **`📁 Controller/` ("Otak"):**
    -   Berisi _semua_ logika bisnis murni. File-file ini yang _memutuskan_ "apa yang harus dilakukan".
    -   Contoh: `AutoDJ.lua`, `Scanner.lua`.
4.  **`📁 Services/` ("Tangan & Telinga"):**
    -   Berisi _semua_ logika pendukung, _event_, dan manajemen data.
    -   **`Handlers.lua`:** Wajib ada. Menangani semua `Remote:OnServerEvent`, `Players.PlayerAdded`, `.Touched`, dll.
    -   **`State.lua`:** Wajib ada. Tempat nyimpen _cache_ `playerRoles` atau `CurrentSong`. **WAJIB** membersihkan data player saat `PlayerRemoving` (lihat `Decision #X (Memory Cleanup)`).

#### 3.3. Penjelasan: Kenapa Manual Registry? (PENTING)

Struktur internal modul (Level 2) **WAJIB** menggunakan "Manual Registry" (`require` manual), tidak seperti Kernel (Level 1) yang menggunakan "Smart Discover".

**Kenapa?**

1.  **Kendali Urutan Loading:** `init.lua` _harus_ menjamin `Config.lua` di-`require` **sebelum** `Controller/MainLogic.lua` yang menggunakannya. _Smart discover_ tidak bisa menjamin urutan ini dan akan menyebabkan _crash_.
2.  **Dependency Injection:** _Manual registry_ memungkinkan `init.lua` (Manajer) menyuntikkan "alat" (seperti `Logger` atau `DataModule`) ke "pekerja"-nya (`MainLogic:Init(Logger, DataModule)`). _Smart discover_ tidak bisa melakukan ini.

---

### Decision #4: Komunikasi Antar Modul (Registry)

Modul dilarang `require` modul lain secara langsung. Komunikasi **WAJIB** melalui `Kernel:GetModule()`.

#### 4.1. Aturan Anti-Circular Dependency

1.  **DILARANG** `require` modul lain di _top-level_ (di luar fungsi).
2.  **DILARANG** memanggil `Kernel:GetModule()` di _top-level_.
3.  **WAJIB** memanggil `Kernel:GetModule()` **HANYA** di dalam `Init()` (Phase 3) dan menyimpannya di _cache_ (`State.lua` atau `local`).
4.  **WAJIB** memanggil fungsi modul lain (misal: `DataModule:SaveData()`) HANYA _setelah_ `Phase 3` selesai (misal: di dalam _event handler_ seperti `OnPlayerAdded` atau `OnServerEvent`).

#### 4.2. (BARU) Aturan Defensive Config (Anti-Crash)

Modul _apapun_ yang membaca dari `Config.lua` (global) **WAJIB** melakukannya secara _defensive_ (aman) dan **TIDAK BOLEH** berasumsi tabelnya ada.

**Pola yang SALAH (Akan Crash):**

```lua
-- DILARANG: Asumsi Config.Monetization ada
if Config.Monetization.EnableSongRequests then ... end
```

**Pola yang BENAR (Wajib Diterapkan):**

```lua
-- WAJIB: Gunakan 'and' (short-circuiting) atau 'or' (default value)

-- Cara 1: Cek rantai (Aman jika nil)
local isEnabled = Config.Monetization and Config.Monetization.EnableSongRequests
if isEnabled then
    -- ...
end

-- Cara 2: Pakai 'or' (Set default jika nil)
local isEnabled = Config.Monetization and Config.Monetization.EnableSongRequests or false
if isEnabled then
    -- ...
end
```

**Hasil:** Jika Dev lupa nulis tabel `Monetization` di `Config.lua`, `isEnabled` akan jadi `false` (paling aman) dan **game tidak akan crash**.

---

### Decision #5: Komunikasi Network (RemoteWrapper)

Semua komunikasi Client-Server **WAJIB** melalui `RemoteWrapper` terpusat.

**Struktur File (`src/Shared/Network/`):**

```text
Network/
├── 📜 init.lua             (API: :FireAllClients, :OnServerEvent)
├── 📜 Events.lua           (Data: Daftar RemoteEvent)
└── 📁 Controller/
    └── 📜 RemoteWrapper.lua (Eskalasi Logic: Pembuatan Remote)
```

**`Events.lua` (Contoh):**

```lua
return {
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
DEBUG = 1   -- 🔍 Verbose (HANYA development)
INFO = 2    -- ℹ️ Normal (Default production)
WARN = 3    -- ⚠️ Warning
ERROR = 4   -- 💀 Critical (SELALU tampil)
PERF = 5    -- ⚡ Performance (Opsional)
```

#### 6.2. Struktur Config (`src/Server/Config.lua`)

```lua
return {
    Debug = {
        GlobalLogLevel = "INFO", -- "DEBUG" | "INFO"
        ModuleLevels = {
            MusicModule = "DEBUG", -- Override: MusicModule bawel
        },
        EnablePerfLogs = false,
    }
}
```

#### 6.3. Format Log (Clean - Tanpa Timestamp)

`{REALM} {DOMAIN} {LEVEL} {TYPE} [{MODULE}] {MESSAGE}`

**Contoh Output (`GlobalLogLevel = "INFO"`):**

```text
🖥️ 🎵 ℹ️ 📢 [MusicModule] Playing: Kopi Dangdut - Fahmi Shahab
```

#### 6.4. Template Kode Logger (`src/Shared/Logger/init.lua`)

```lua
local Logger = {}
local Config -- (FIX) Ditugaskan oleh Kernel via Init()
-- ... (HttpService, RunService, IS_SERVER, ENV_EMOJI, LOG_LEVELS) ...

function Logger:Init(configModule)
    Config = configModule
    self:Info("Logger", "SYSTEM", "Logger V1.0.0 (Unified) Initialized")
end

-- (FIX) Core logging function yang Config-aware
local function ShouldLog(moduleName, level)
    local globalLevelKey = "INFO"
    if Config and Config.Debug and Config.Debug.GlobalLogLevel then
        globalLevelKey = Config.Debug.GlobalLogLevel
    end
    local globalLevel = LOG_LEVELS[globalLevelKey] or LOG_LEVELS.INFO

    local moduleLevelKey = nil
    if Config and Config.Debug and Config.Debug.ModuleLevels then
        moduleLevelKey = Config.Debug.ModuleLevels[moduleName]
    end

    -- (FIX) Fallback jika modul lupa di-input
    local threshold = moduleLevelKey and LOG_LEVELS[moduleLevelKey] or globalLevel
    return LOG_LEVELS[level] >= threshold
end

-- (FIX) Fungsi log tanpa timestamp
function Logger:Info(moduleName, domain, message)
    if not ShouldLog(moduleName, "INFO") then return end
    print(string.format(
        "%s %s %s 📢 [%s] %s",
        ENV_EMOJI, getEmoji(domain), getEmoji("INFO"), moduleName, message
    ))
end
-- ... (fungsi Debug, Error, Warn, Perf) ...
return Logger
```

---

### Decision #7: Kontrak Atribut (Builder-Scripter)

Builder (Desainer) **WAJIB** mengkonfigurasi _gameplay_ via Atribut. Scripter (Koder) **WAJIB** memvalidasi Atribut tersebut.

#### 7.1. Konvensi Penamaan

`[Domain]_[Property]` (Contoh: `Zone_ID`, `Audio_Side`, `UI_Type`)

#### 7.2. Kontrak Scripter (Validasi WAJIB)

Modul (seperti `ZoneModule/Controller/Scanner.lua`) **WAJIB** memvalidasi Atribut dan memberikan _fallback_ jika Atribut tidak ada, menggunakan `Logger:Warn` atau `Logger:Error`.

**Contoh Kode (`src/Server/OVHL_Modules/ZoneModule/Controller/Scanner.lua`):**

```lua
function Scanner.ScanZones()
    local Logger = ServerKernel:GetModule("Logger") -- Asumsi Kernel sudah di-pass
    -- ...
    for _, stage in ipairs(stages:GetChildren()) do
        local zoneID = stage:GetAttribute("Zone_ID")

        -- VALIDASI KONTRAK
        if not zoneID then
            Logger:Error("ZoneModule", "ZONE", "Missing WAJIB Attribute: Zone_ID", {
                Model = stage:GetFullName()
            })
            continue -- Skip zona invalid
        end
    end
end
```

---

### Decision #8: Integrasi 3rd Party (TopbarPlus)

Integrasi **WAJIB** diisolasi di dalam modul `Services/`. Kegagalan 3rd party _tidak boleh_ merusak Kernel.

-   **Ketahanan:** `pcall` di `Phase 2` Kernel (Decision #1.2) akan menangkap error jika `TopbarPlus` gagal di-`require`, dan hanya `TopbarIntegration` yang akan mati.

**Contoh Kode (`src/Client/Services/TopbarIntegration/init.lua`):**

```lua
-- ... (Cache Kernel, Logger) ...
-- (FIX) Path 3rd Party yang Benar
local Icon = require(game:GetService("ReplicatedStorage").TopbarPlus.Icon)

function TopbarIntegration:Init()
    -- ... (Get Logger, dll) ...
    local musicIcon = Icon.new():setLabel("Music")
    musicIcon.selected:Connect(function()
        local UIModule = ClientKernel:GetModule("UIModule")
        if UIModule then
             UIModule:ToggleMusicPanel()
        end
    end)
end
return TopbarIntegration
```

---

### Decision #9: Arsitektur Permission Terpadu (Aggregator)

Ini adalah perombakan **FINAL** (V3) berdasarkan masukan `MainModule.lua` dan _config_ Kohl's.

**Konteks:**
Sistem kita butuh sistem izin yang _robust_ dan _anti-crash_. Kita perlu `require` Kohl's Admin sebagai sumber izin utama, tapi kita **WAJIB** punya _fallback_ penuh jika Kohl's gagal.

**Keputusan:**
Modul `Core/PermissionSync` akan menjadi "Permission Aggregator". Modul ini akan memiliki _service fallback_ internal yang _mencerminkan_ logika Kohl's (cek Gamepass, Grup, dll).

#### 9.1. Struktur Internal `Core/PermissionSync`

Modul ini akan "Eskalasi" (Sesuai Decision #3.2):

```text
📁 Core/PermissionSync/
├── 📜 init.lua        (API Publik: :GetRole(player))
├── 📜 Config.lua      (Config: Fallback Roles, gamepassId, groupId)
├── 📁 Controller/
│   ├── 📜 Logic_Kohl.lua    (Pekerja Internal: Logic untuk baca API Kohl's)
│   └── 📜 Logic_OVHL.lua    (Pekerja Internal: Logic untuk baca Config Fallback)
└── 📁 Services/
    ├── 📜 Handlers.lua    (Event: OnPlayerAdded untuk pre-cache)
    └── 📜 State.lua       (Cache: KohlInterface, playerRoles[userId])
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

1.  **Cek Cache:** Cek `Services/State.lua`. Jika role player ada, `return` role dari cache.
2.  **Coba Kohl's Admin (Prioritas 1):**
    -   Di `Init()`, `pcall` `require(Kohl.MainModule)`. Jika berhasil, simpan `_K` di `State.lua`.
    -   Jika `_K` ada, panggil `Controller/Logic_Kohl:GetRole(_K, player)`.
    -   `Logic_Kohl` akan membaca `_K.Data.members[userId].persist` dan `_K.Data.roles[roleId]` dan me-return role yang _di-mapping_.
3.  **Coba Fallback OVHL (Prioritas 2):**
    -   (Hanya jalan jika Kohl's gagal di-load ATAU `Logic_Kohl` me-return "OVHL_Guest").
    -   `Logger:Info("PermissionSync", "ADMIN", "Kohl's tidak ditemukan/Guest, cek fallback internal OVHL...")`.
    -   Panggil `Controller/Logic_OVHL:GetRole(player)`.
4.  **Logika Fallback (`Logic_OVHL.lua`):**
    -   `Logic_OVHL` akan `require` `Config.lua` (milik `PermissionSync`) dan `MonetizationModule`.
    -   Dia akan cek `Config.userRoles`, `Config.gamepassRoles`, dan `Config.groupRoles`.
    -   Dia akan mengambil role _tertinggi_ yang ditemukan.
5.  **Return:** Simpan role final ("OVHL_Admin", "OVHL_VIP", atau "OVHL_Guest") ke cache `State.lua` dan `return` role tersebut.

---

### Decision #10: (BARU) Aturan Penanganan Error

#### 10.1. Memory Cleanup (Anti-Memory Leak)

Semua modul yang memiliki `Services/State.lua` (cache) **WAJIB** membersihkan _cache_ player saat player _leave_. Ini akan ditangani secara terpusat oleh `Server/Services/PlayerSessionModule` (jika dibuat) atau modul `Services/Handlers.lua` internal modul itu sendiri yang nge-bind ke `PlayerRemoving`.

#### 10.2. Anti-Race Condition

_Service_ kritis yang diakses bersamaan (terutama `Services/DataModule`) **WAJIB** mengimplementasikan _Promise/Queue system_ untuk _request_ `LoadData`. Jika `Modul A` dan `Modul B` memanggil `DataModule:LoadData(player)` di _frame_ yang sama, `DataStore` hanya boleh dipanggil **satu kali**.

---

### Decision #11: UI Engine (OVHL UI System)

Semua UI kustom (Modal, Panel, Tombol) **WAJIB** menggunakan `OVHL UI System` terpusat (yang akan kita bangun di Fase 2).

**Struktur File (`src/Shared/OVHL_UI/`):**

```text
📁 Shared/OVHL_UI/
├── 📜 init.lua          <-- UI Kernel / Component Factory
├── 📁 ModalSystem/    <-- Popups, Dialogs
├── 📁 LayoutSystem/   <-- Grid, Stack
├── 📁 ContentComponents/ <-- Card, List
└── 📁 FormComponents/   <-- Button, Slider
```

Modul `OVHL_Modules/` (seperti `Client/OVHL_Modules/UIModule`) dilarang `Instance.new("Frame")`. Mereka **WAJIB** memanggil `OVHLUI.ModalSystem:Open(...)`.

---

### Decision #12: Filosofi & Panduan UI Generation

(Bagian ini adalah _refactor_ dari `05-ui-builder.md`, mengunci standar _hardcode_ UI).

#### 12.1. Filosofi Dasar

-   **Thinking in Percentages, NOT Pixels:** AI **WAJIB** menggunakan `UDim2.new(SCALE, 0, SCALE, 0)` untuk ukuran. Ukuran berbasis piksel (Offset) dilarang kecuali untuk `UIPadding`, `UIStroke`, atau `ScrollBarThickness`.
-   **Hierarki Wajib:** `ScreenGui` -> `PaddingFrame` (Safe Area) -> `MainContainer` (Aspect Ratio) -> `ContentFrame` (UIPadding) -> `UIListLayout`.
-   **Layout Wajib:** Semua _item_ **WAJIB** diatur oleh `UIListLayout` atau `UIGridLayout`. Pengaturan posisi manual (`Position`) dilarang keras kecuali untuk _container_ utama.
-   **Responsive Wajib:** Semua elemen teks **WAJIB** `TextScaled = true` (kecuali ditentukan lain).

#### 12.2. Visual Design System (Ringkasan)

(AI akan merujuk ke tabel `COLORS`, `TYPOGRAPHY`, `CORNER_RADIUS` saat membuat UI di Fase 2).

#### 12.3. Template Fungsi UI (Contoh)

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

#### 12.4. Audit & QA (Sesuai `05-ui-builder.md` Section 10)

-   AI akan menggunakan _logic_ dari `05-ui-builder.md` Section 10 (fungsi `auditUI`) sebagai referensi mental untuk _self-check_ kode UI yang dihasilkannya.
-   **Checklist AI (Wajib):**
    1.  ✅ Semua ukuran pakai SCALE?
    2.  ✅ Semua elemen punya `LayoutOrder`?
    3.  ✅ Semua teks pakai `TextScaled = true`?
    4.  ✅ `ScreenGui.IgnoreGuiInset = true`?
    5.  ✅ `UIAspectRatioConstraint` dipakai untuk container utama?

---

**Dokumen Selesai. Versi 1.0.0.**
