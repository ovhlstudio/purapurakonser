## 🏛️ 01 - ARSITEKTUR (KITAB SUCI TEKNIS - BATTLE TESTED)

**Versi:** 2.1.0 (Smart UI System)  
**Status:** FINAL  
**Tujuan:** Dokumen "Kitab Suci" yang sudah teruji dari pengalaman implementasi nyata. Mendefinisikan **OVHL Core System** yang _reusable_, _scalable_, _anti-crash_, dan **fully modular**.

---

## 🚀 POKOK-POKOK ARSITEKTUR (BATTLE TESTED)

1.  **Entrypoint Rojo Managed:** `init.server.lua` (Script) & `init.client.lua` (LocalScript) sebagai entrypoint otomatis
2.  **Kernel 4-Fase Proven:** Bootstrap (`Phase 0`) → Loader (`Phase 1-3`) - **SUDAH TERBUKTI WORK**
3.  **Domain Priority Critical:** `Core` → `Services` → `OVHL_Modules` → `Shared` - **WAJIB urutan ini**
4.  **Fully Modular Architecture:** Zero-configuration, auto-discovery, plug & play modules
5.  **Smart UI System:** Core UI Manager dengan AI-powered component discovery - **NEW**
6.  **Clean Separation:** Business Logic vs UI Components vs Infrastructure - **LESSON LEARNED**
7.  **Standardized Interfaces:** Modul expose metadata via well-known functions untuk auto-discovery
8.  **Anti-Circular Dependency Strict:** Komunikasi hanya via Kernel APIs, cache di Init() only
9.  **Modular Configuration:** Setiap modul self-contained dengan config internal
10. **Standardized Naming:** Files `snake_case.lua`, folders `PascalCase`, variables `camelCase`

---

## 🏛️ KEPUTUSAN ARSITEKTUR (BATTLE TESTED DECISIONS)

### Decision #1: Arsitektur Kernel 4-Fase (PROVEN WORKING)

**KONTEKS PRAKTIS:** Sistem harus boot dengan urutan prioritas ketat untuk hindari circular dependency dan crash.

#### 1.1. Fase 0: Bootstrap (Entrypoint Script) - **CRITICAL**

`init.server.lua` (Script) dan `init.client.lua` (LocalScript) bertugas HANYA menyalakan modul inti **sebelum** Kernel utama.

**Contoh Kode TERBUKTI WORK (`src/Server/init.server.lua`):**

```lua
-- File ini adalah SCRIPT, otomatis jalan oleh Rojo
print("PHASE 0: Server Bootstrap...")

-- 1. Load Modul Inti (Urutan WAJIB - JANGAN DIBALIK!)
local config = require(script.config)
local logger = require(game:GetService("ReplicatedStorage").Shared.Logger.manifest)

-- 2. Injeksi Dependensi (Memutus Circular Dependency)
-- Logger sekarang NYALA dan punya akses ke config
logger:Init(config)

-- 3. Panggil Kernel Utama (ModuleScript)
local kernel = require(script.Core.Kernel.manifest)

-- 4. Mulai 3-Phase Loader (Phase 1, 2, 3)
kernel:Init(config, logger)

logger:Info("Bootstrap", "SYSTEM", "PHASE 0: Bootstrap Selesai. Kernel mengambil alih.")
```

#### 1.2. Fase 1-3: Kernel Loader (Dengan Prioritas Domain) - **PROVEN**

`Core/Kernel/manifest.lua` (ModuleScript) berisi logic 3-Phase Loader yang **SUDAH TERBUKTI AMAN**.

**Contoh Kode WORKING (`src/Server/Core/Kernel/manifest.lua`):**

```lua
local ServerKernel = {}
ServerKernel.Modules = {}
local logger, config

-- 🎯 URUTAN DISCOVERY (Loading)
local DISCOVERY_PRIORITY = { "Core", "Services", "OVHL_Modules" }

-- 🎯 URUTAN INISIALISASI (PENTING!)
-- Shared (Network) harus Init SEBELUM OVHL_Modules (MusicModule)
local INIT_DOMAINS_INTERNAL = { "Core", "Services" }
-- Shared dan OVHL_Modules akan di-handle terpisah

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SHARED_PATH = ReplicatedStorage:WaitForChild("Shared")

function ServerKernel:GetModule(moduleName)
    local module = self.Modules[moduleName]
    if not module then
        if logger then
            logger:Warn("Kernel", "SYSTEM", "Module not found: " .. moduleName)
        else
            warn("Kernel: Module not found (logger not yet available): " .. moduleName)
        end
    end
    return module
end

-- 🎯 API BARU UNTUK NETWORK
function ServerKernel:GetAllModules()
    return self.Modules
end

local function discoverModules(path, kernelModules, logger)
    -- ... (kode discoverModules tidak berubah) ...
end

-- Fungsi helper untuk Init
local function initializeDomain(domainFolder, kernel, logger)
    if not domainFolder then return end
    for _, item in ipairs(domainFolder:GetChildren()) do
        local module = kernel.Modules[item.Name]
        if module and module ~= kernel and (not module.IsInitialized) then
            if module.SetKernel then module:SetKernel(kernel) end

            if type(module.Init) == "function" then
               local success, err = pcall(module.Init, module)
               if not success then
                    logger:Error("Kernel", "SYSTEM", "PHASE 3: Modul " .. item.Name .. " GAGAL di-Init!", err)
               end
               module.IsInitialized = true
            end
        end
    end
end

function ServerKernel:Init(configModule, loggerModule)
    config = configModule
    logger = loggerModule
    ServerKernel.Modules["Config"] = config
    ServerKernel.Modules["Logger"] = logger
    ServerKernel.Modules["Kernel"] = self

    if loggerModule.IsInitialized == nil then
        loggerModule.IsInitialized = true
    end

    logger:Info("Kernel", "SYSTEM", "PHASE 1: Core Boot Selesai.")

    local rootScript = script:FindFirstAncestorOfClass("Script")
    -- ... (cek rootScript) ...

    logger:Info("Kernel", "SYSTEM", "PHASE 2: Module Discovery Dimulai...")

    -- PHASE 2A: Load Internal Domains
    for _, domainName in ipairs(DISCOVERY_PRIORITY) do
        local domainFolder = rootScript:FindFirstChild(domainName)
        discoverModules(domainFolder, ServerKernel.Modules, logger)
    end

    -- PHASE 2B: Load Shared Modules (FIX BARU)
    logger:Info("Kernel", "SYSTEM", "PHASE 2B: Loading Shared Modules...")
    discoverModules(SHARED_PATH, ServerKernel.Modules, logger)

    logger:Info("Kernel", "SYSTEM", "PHASE 2: Module Discovery Selesai.")
    logger:Info("Kernel", "SYSTEM", "PHASE 3: Inisialisasi Dimulai (Urutan Diperbaiki)...")

    -- 🎯 FASE 3: URUTAN INIT YANG BENAR (FIX BARU)

    -- 1. Init Core & Services
    for _, domainName in ipairs(INIT_DOMAINS_INTERNAL) do
        local domainFolder = rootScript:FindFirstChild(domainName)
        initializeDomain(domainFolder, self, logger)
    end

    -- 2. Init Shared (Network, Logger, dll)
    initializeDomain(SHARED_PATH, self, logger)

    -- 3. Init OVHL_Modules (MusicModule, dll)
    local ovhlFolder = rootScript:FindFirstChild("OVHL_Modules")
    initializeDomain(ovhlFolder, self, logger)

    logger:Info("Kernel", "SYSTEM", "PHASE 3: Inisialisasi Selesai. Server Siap.")
end

return ServerKernel
```

**Contoh Kode WORKING (`src/Client/Core/Kernel/manifest.lua`):**

```lua
local ClientKernel = {}
ClientKernel.Modules = {}
local logger

-- 🎯 URUTAN DISCOVERY (Loading)
local DISCOVERY_PRIORITY = { "Core", "Services", "OVHL_Modules" }

-- 🎯 URUTAN INISIALISASI (PENTING!)
local INIT_DOMAINS_INTERNAL = { "Core", "Services" }

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SHARED_PATH = ReplicatedStorage:WaitForChild("Shared")

function ClientKernel:GetModule(moduleName)
    -- ... (kode GetModule tidak berubah) ...
end

-- 🎯 API BARU UNTUK NETWORK
function ClientKernel:GetAllModules()
    return self.Modules
end

local function discoverModules(path, kernelModules, logger)
    -- ... (kode discoverModules tidak berubah) ...
end

-- Fungsi helper untuk Init
local function initializeDomain(domainFolder, kernel, logger)
    if not domainFolder then return end
    for _, item in ipairs(domainFolder:GetChildren()) do
        local module = kernel.Modules[item.Name]
        if module and module ~= kernel and (not module.IsInitialized) then
            if module.SetKernel then module:SetKernel(kernel) end

            if type(module.Init) == "function" then
               local success, err = pcall(module.Init, module)
               if not success then
                    logger:Error("Kernel", "SYSTEM", "PHASE 3: Modul " .. item.Name .. " GAGAL di-Init!", err)
               end
               module.IsInitialized = true
            end
        end
    end
end

function ClientKernel:Init(configModule, loggerModule)
    logger = loggerModule
    ClientKernel.Modules["Logger"] = logger
    ClientKernel.Modules["Kernel"] = self

    if loggerModule and loggerModule.IsInitialized == nil then
        loggerModule.IsInitialized = true
    end

    logger:Info("Kernel", "SYSTEM", "PHASE 1: Core Boot Selesai.")

    local rootScript = script:FindFirstAncestorOfClass("LocalScript")
    -- ... (cek rootScript) ...

    logger:Info("Kernel", "SYSTEM", "PHASE 2: Module Discovery Dimulai...")

    -- PHASE 2A: Load Internal Domains
    for _, domainName in ipairs(DISCOVERY_PRIORITY) do
        local domainFolder = rootScript:FindFirstChild(domainName)
        discoverModules(domainFolder, ClientKernel.Modules, logger)
    end

    -- PHASE 2B: Load Shared Modules
    logger:Info("Kernel", "SYSTEM", "PHASE 2B: Loading Shared Modules...")
    discoverModules(SHARED_PATH, ClientKernel.Modules, logger)
    -- ... (logging internal vs shared) ...

    logger:Info("Kernel", "SYSTEM", "PHASE 2: Module Discovery Selesai.")
    logger:Info("Kernel", "SYSTEM", "PHASE 3: Inisialisasi Dimulai (Urutan Diperbaiki)...")

    -- 🎯 FASE 3: URUTAN INIT YANG BENAR (FIX BARU)

    -- 1. Init Core & Services
    for _, domainName in ipairs(INIT_DOMAINS_INTERNAL) do
        local domainFolder = rootScript:FindFirstChild(domainName)
        initializeDomain(domainFolder, self, logger)
    end

    -- 2. Init Shared (Network, Logger, dll)
    initializeDomain(SHARED_PATH, self, logger)

    -- 3. Init OVHL_Modules (MusicPlayerUI, dll)
    local ovhlFolder = rootScript:FindFirstChild("OVHL_Modules")
    initializeDomain(ovhlFolder, self, logger)

    logger:Info("Kernel", "SYSTEM", "PHASE 3: Inisialisasi Selesai. Client Siap.")
end

return ClientKernel
```

---

### Decision #2: Struktur Folder Domain Organization (PROVEN)

**KONTEKS PRAKTIS:** Organisasi folder berdasarkan tanggung jawab untuk separation of concerns.

| Domain           | Emoji | Tujuan                       | Contoh                                | Keterangan    |
| ---------------- | ----- | ---------------------------- | ------------------------------------- | ------------- |
| **Core**         | 🎯    | Fondasi sistem, lintas modul | Kernel, PermissionSync, **UIManager** | Load pertama  |
| **Services**     | 🛎️    | Integrasi eksternal, I/O     | DataModule, MonetizationModule        | Load kedua    |
| **OVHL_Modules** | 🎮    | Logika gameplay spesifik     | MusicModule, ZoneModule               | Load ketiga   |
| **Shared**       | 🔄    | Shared resources, components | Logger, Network, OVHL_UI              | Load terakhir |

#### 2.1. Struktur File PROVEN (Battle Tested) - **UPDATED**

```text
./                                  ← Root kerja VS Code
📁 src/                            ← Root folder semua source code
├── 📁 Client/
│   ├── 📜 init.client.lua         ← (LocalScript) BOOTSTRAPPER KLIEN - PROVEN
│   ├── 📁 Core/
│   │   ├── 📁 Kernel/
│   │   │   └── 📜 manifest.lua    ← (ModuleScript) Kernel Loader - PROVEN
│   │   └── 📁 UIManager/          ← 🆕 CORE UI MANAGER (SMART!) - **FIXED PATH**
│   │       ├── 📜 manifest.lua    ← Smart UI discovery & management
│   │       └── 📜 config.lua      ← UI component registry
│   └── 📁 OVHL_Modules/
│       └── 📁 MusicPlayerUI/      ← UI BUSINESS LOGIC (SMART UI)
│           ├── 📜 manifest.lua    ← API + UI config sederhana
│           ├── 📜 config.lua      ← Hanya mode & component expectations
│           ├── 📁 Controller/     ← Business logic (TANPA UI complexity)
│           └── 📁 Services/       ← Network listeners, state
│
├── 📁 Server/
│   ├── 📜 init.server.lua         ← (Script) BOOTSTRAPPER SERVER - PROVEN
│   ├── 📜 config.lua              ← (ModuleScript) Global Config
│   ├── 📁 Core/
│   │   ├── 📁 Kernel/
│   │   │   └── 📜 manifest.lua    ← (ModuleScript) Kernel Loader - PROVEN
│   │   ├── 📁 PermissionSync/     ← (Modul) Permission system
│   │   │   ├── 📜 manifest.lua
│   │   │   └── 📜 config.lua
│   ├── 📁 Services/
│   │   └── 📁 DataModule/         ← (Modul) Data persistence
│   │       ├── 📜 manifest.lua
│   │       └── 📜 config.lua
│   └── 📁 OVHL_Modules/
│       └── 📁 MusicModule/        ← BUSINESS LOGIC (PURE)
│           ├── 📜 manifest.lua    ← API + GetNetworkEvents()
│           ├── 📜 config.lua      ← Business settings
│           ├── 📁 Controller/     ← AutoDJ, Queue logic
│           └── 📁 Services/       ← Event handlers, state
│
└── 📁 Shared/
    ├── 📁 Logger/                 ← (Modul) Logger Terpusat - PROVEN
    │   └── 📜 manifest.lua
    ├── 📁 Network/                ← (Modul) Auto-Discovery Network
    │   └── 📜 manifest.lua        ← Auto-event registry
    └── 📁 OVHL_UI/                ← (Modul) Pure UI Components - PROVEN
        ├── 📜 manifest.lua        ← Design System + Components
        ├── 📁 ModalSystem/        ← UI Components (BUKAN business logic)
        │   ├── 📜 small_modal.lua
        │   └── 📜 big_modal.lua
        ├── 📁 LayoutSystem/
        │   ├── 📜 flex.lua
        │   └── 📜 grid.lua
        ├── 📁 ContentComponents/
        │   ├── 📜 card.lua
        │   └── 📜 list.lua
        └── 📁 FormComponents/
            ├── 📜 button.lua
            └── 📜 slider.lua
```

#### 2.2. Rojo `default.project.json` (PROVEN WORKING)

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

### Decision #3: Struktur Internal Modul (PROVEN PATTERN)

**KONTEKS PRAKTIS:** Hindari "God Files" dengan separation of concerns dalam modul.

#### 3.1. Pola Struktur Folder (WAJIB & TESTED)

```text
📁 MusicModule/                    ← PascalCase folder
├── 📜 manifest.lua    (API Publik + Well-known functions)
├── 📜 config.lua      (Module config - snake_case)
│
├── 📁 Controller/     ("Otak" / Business Logic)
│   └── 📜 auto_dj.lua   (snake_case internal files)
│   └── 📜 queue.lua
│
└── 📁 Services/       ("Tangan & Telinga" / Support)
    ├── 📜 handlers.lua  (Event Listeners - snake_case)
    └── 📜 state.lua     (Memory Management / Cache)
```

#### 3.2. Module Config Structure (PROVEN) - **ENHANCED FOR SMART UI**

```lua
-- MusicPlayerUI/config.lua (CONTOH SIMPLE!)
return {
    -- 🎯 UI CONFIG SEDERHANA - Core UIManager handle complexity
    ui = {
        mode = "StarterGui",  -- "OVHL_UI" atau "StarterGui"
        screen_gui = "MusicPanel",  -- Nama ScreenGui (optional)

        components = {  -- 🎯 EXPECTED COMPONENTS (untuk validation & discovery)
            now_playing_title = "TextLabel",
            now_playing_artist = "TextLabel",
            play_button = "TextButton",
            pause_button = "TextButton",
            volume_slider = "Frame"  -- Slider biasanya Frame container
        }
    },

    -- Business config tetap
    debug = {
        log_level = "INFO",
        enable_perf_logs = false
    },
    features = {
        enable_song_requests = true
    }
}
```

---

### Decision #4: Komunikasi Antar Modul (BATTLE TESTED)

**KONTEKS PRAKTIS:** Hindari circular dependency dan enable modular communication.

#### 4.1. Aturan Anti-Circular Dependency (STRICT & PROVEN)

1.  **🚫 DILARANG** `require` modul lain di _top-level_ (di luar fungsi)
2.  **🚫 DILARANG** memanggil `Kernel:GetModule()` di _top-level_
3.  **✅ WAJIB** memanggil `Kernel:GetModule()` **HANYA** di dalam `Init()` (Phase 3) dan menyimpannya di _cache_
4.  **✅ WAJIB** memanggil fungsi modul lain HANYA _setelah_ `Phase 3` selesai

#### 4.2. Pola yang BENAR (PROVEN WORKING) - **ENHANCED WITH UIMANAGER**

```lua
-- MusicPlayerUI/manifest.lua - CONTOH SUPER SIMPLE!
local MusicPlayerUI = {}
local logger, network, uiManager, uiInstance

function MusicPlayerUI:Init()
    -- ✅ Cache dependencies di Init() saja
    local kernel = self:GetKernel()
    logger = kernel:GetModule("Logger")
    network = kernel:GetModule("Network")
    uiManager = kernel:GetModule("UIManager")  -- 🎯 PAKAI CORE UI MANAGER!

    -- 🎯 UI SETUP SUPER SIMPLE - Core handle complexity!
    uiInstance = uiManager:SetupModuleUI("MusicPlayer", self.config)

    if not uiInstance then
        logger:Error("MusicPlayerUI", "UI", "Gagal setup UI!")
        return
    end

    logger:Info("MusicPlayerUI", "SYSTEM", "MusicPlayerUI Initialized dengan Smart UI")
end

-- ✅ Business logic jalan SETELAH Init()
function MusicPlayerUI:UpdateNowPlaying(songData)
    if not uiInstance then return end

    -- 🎯 UPDATE UI VIA CORE - Auto handle OVHL_UI/StarterGui!
    uiInstance.update({
        title = songData.title,
        artist = songData.artist,
        isPlaying = true
    })

    logger:Debug("MusicPlayerUI", "UI", "Updated now playing: " .. songData.title)
end

return MusicPlayerUI
```

---

### Decision #18: Naming Convention & File Structure (PROVEN)

#### 18.1. File Naming Convention (CONSISTENT)

-   **Files:** `snake_case.lua` (manifest.lua, config.lua, auto_dj.lua)
-   **Folders:** `PascalCase` (Logger, OVHL_UI, MusicModule, MusicPlayerUI)
-   **Variables/Functions:** `camelCase` (getModule, createButton, currentSong)
-   **Constants:** `UPPER_SNAKE_CASE` (MAX_PLAYERS, DEFAULT_VOLUME)

#### 18.2. Config Management Hierarchy (PROVEN)

```lua
-- Global (App-level) - Server/config.lua
return {
    app_name = "PuraPuraPesta",
    version = "2.1.0",  -- 🎯 VERSION BUMP!
    debug = {
        global_log_level = "INFO",
        enable_perf_logs = false
    }
}

-- Module-specific - MusicModule/config.lua
return {
    debug = {
        log_level = "DEBUG",  -- Override untuk module ini
        enable_perf_logs = true
    },
    features = {
        enable_song_requests = true
    }
}
```

#### 18.3. Module Independence Principle (ENHANCED)

-   Setiap modul **WAJIB** self-contained dengan config internal
-   Modul **BOLEH** expose metadata via well-known functions untuk auto-discovery
-   Modul **DILARANG** bergantung pada implementation details modul lain
-   Modul **WAJIB** communicate via Kernel APIs dan standardized interfaces

---

### Decision #19: Fully Modular Architecture & Auto-Discovery (NEW - BATTLE TESTED)

**KONTEKS PRAKTIS:** Setelah mengalami masalah manual registry, kita implement fully modular system.

#### 19.1. Auto-Discovery Patterns (PROVEN SOLUTION)

```lua
-- Network System Auto-Discovery
function Network:AutoDiscoverEvents()
    for moduleName, module in pairs(self.Kernel:GetAllModules()) do
        if module.GetNetworkEvents then
            local events = module:GetNetworkEvents()
            self:RegisterEvents(events) -- Auto-register!
        end
    end
end

-- Module Implementation
function MusicModule:GetNetworkEvents()
    return {
        {name = "MusicChanged", scope = "AllClients"},
        {name = "PlaybackStateChanged", scope = "AllClients"},
        {name = "RequestSong", scope = "Server"}
    }
end

function MusicPlayerUI:GetNetworkEvents()
    return {
        {name = "MusicChanged", scope = "Client"},
        {name = "PlaybackStateChanged", scope = "Client"}
    }
end
```

#### 19.2. Zero-Configuration Benefits

-   **Plug & Play:** Drop modul folder, sistem otomatis kerja
-   **No Manual Registry:** Tidak perlu edit Network system atau file config lain
-   **True Reusability:** Modul bisa dipakai di project lain tanpa modification
-   **Scalable:** Tambah modul baru tanpa sentuh existing code

---

### Decision #20: Clean Separation - Business Logic vs UI Components (NEW - LESSON LEARNED)

**KONTEKS PRAKTIS:** Setelah mengalami confusion antara business logic dan UI rendering.

#### 20.1. Domain Responsibilities (CLEAR SEPARATION)

| Domain                     | Purpose            | Responsibility                  | Example                                       |
| -------------------------- | ------------------ | ------------------------------- | --------------------------------------------- |
| **OVHL_UI (Shared)**       | Pure UI Components | Rendering, Styling, Layout      | `CreateButton()`, `OpenModal()`               |
| **MusicPlayerUI (Client)** | UI Business Logic  | Music-specific UI logic         | `UpdateNowPlaying()`, `HandleMusicControls()` |
| **MusicModule (Server)**   | Business Logic     | Music playback logic            | `PlaySong()`, `AutoDJ()`, `QueueManagement()` |
| **UIManager (Core)**       | UI Infrastructure  | Smart UI discovery & management | `SetupModuleUI()`, `DiscoverComponents()`     |

#### 20.2. Communication Flow (CLEAN ARCHITECTURE) - **ENHANCED**

```
[MusicModule] --(Network Events)--> [MusicPlayerUI] --(UIManager APIs)--> [Screen]
    Business Logic                      UI Business Logic      Smart UI Management
        🎵                                  🎛️                          🧠
                                                ↓
                                      { OVHL_UI atau StarterGui }
```

---

### Decision #21: Standardized Module Interfaces (NEW - FUTURE PROOF)

**KONTEKS PRAKTIS:** Untuk enable future extensions dan systems integration.

#### 21.1. Well-Known Functions (OPTIONAL BUT RECOMMENDED)

```lua
-- Untuk modul yang butuh network communication
function Module:GetNetworkEvents()
    return {
        {name = "EventName", scope = "AllClients|SpecificClient|Server"}
    }
}

-- Untuk modul yang butuh explicit dependencies
function Module:GetDependencies()
    return {"Logger", "Network", "UIManager"}  -- 🎯 TAMBAH UIMANAGER!
}

-- Untuk modul yang expose public APIs
function Module:GetAPIs()
    return {"PublicFunction1", "PublicFunction2", "PublicProperty"}
}

-- Untuk modul yang butuh configuration validation
function Module:ValidateConfig(config)
    return config.debug ~= nil and config.features ~= nil
}
```

#### 21.2. Benefits

-   **Auto-Discovery:** Systems bisa automatically discover module capabilities
-   **Future Proof:** Bisa tambah systems baru tanpa breaking changes
-   **Tooling Support:** AI dan tools bisa analyze module capabilities
-   **Documentation:** Self-documenting module interfaces

---

### Decision #22: Core UI Manager & Smart Component Discovery (NEW - GAME CHANGER)

**KONTEKS PRAKTIS:** Setelah mengalami complexity UI setup di setiap modul, kita implement centralized smart UI management.

#### 22.1. Core UIManager Architecture

```lua
-- Client/Core/UIManager/manifest.lua  -- 🎯 PATH KOREKSI (CLIENT-SIDE)
local UIManager = {}
local logger, config

function UIManager:Init()
    logger = self:GetKernel():GetModule("Logger")
    config = self:GetKernel():GetModule("Config")
    logger:Info("UIManager", "CORE", "Smart UI Manager Initialized")
end

-- 🎯 MAIN API: Setup UI untuk modul (SIMPLE!)
function UIManager:SetupModuleUI(moduleName, moduleConfig)
    local uiMode = moduleConfig.ui.mode or "OVHL_UI"
    local screenGuiName = moduleConfig.ui.screen_gui or moduleName .. "Panel"

    logger:Info("UIManager", "UI",
        "Setting up UI for " .. moduleName .. " | Mode: " .. uiMode .. " | Screen: " .. screenGuiName)

    if uiMode == "OVHL_UI" then
        return self:SetupOVHLUI(moduleName, moduleConfig)
    else
        return self:SetupStarterGui(moduleName, screenGuiName, moduleConfig)
    end
end
```

#### 22.2. Smart Component Discovery (AI-POWERED)

```lua
-- 🧠 SMART COMPONENT DISCOVERY & CLASSIFICATION
function UIManager:DiscoverComponents(screenGui, expectedComponents)
    local discovered = {}
    local componentRegistry = self:GetComponentRegistry()

    -- Traverse seluruh screenGui dengan AI pattern matching
    self:TraverseAndClassify(screenGui, "", discovered, componentRegistry)

    -- 🎯 VALIDATE & LOG MISSING COMPONENTS DENGAN SMART MESSAGES
    self:ValidateComponents(discovered, expectedComponents)

    return discovered
end

function UIManager:ClassifyComponent(child, fullPath, registry)
    local name = string.lower(child.Name)
    local path = string.lower(fullPath)

    -- 🧠 MULTI-LANGUAGE PATTERN MATCHING
    for logicalName, patterns in pairs(registry) do
        for _, pattern in ipairs(patterns.names) do
            if string.find(name, pattern) or string.find(path, pattern) then
                -- 🎯 TYPE VALIDATION
                if self:IsValidType(child, patterns.types) then
                    return {
                        logicalName = logicalName,
                        expectedType = patterns.types[1]
                    }
                else
                    logger:Warn("UIManager", "VALIDATION",
                        "Component '" .. fullPath .. "' type mismatch. Expected: " ..
                        table.concat(patterns.types, ", ") .. " | Found: " .. child.ClassName)
                end
            end
        end
    end
    return nil
end
```

#### 22.3. Smart Error Messages & Validation

```lua
function UIManager:ValidateComponents(discovered, expectedComponents)
    local registry = self:GetComponentRegistry()

    for logicalName, expectedType in pairs(expectedComponents) do
        if not discovered[logicalName] then
            -- 🎯 SMART ERROR MESSAGE DENGAN SOLUTION GUIDANCE
            local patterns = registry[logicalName]
            local expectedTypes = patterns and table.concat(patterns.types, " or ") or "Unknown"
            local namePatterns = patterns and table.concat(patterns.names, ", ") or "Unknown"

            logger:Error("UIManager", "VALIDATION",
                "Component '" .. logicalName .. "' tidak ditemukan!\n" ..
                "💡 Expected: " .. expectedTypes .. " dengan nama mengandung: " .. namePatterns .. "\n" ..
                "🔧 Solution: Buat component dengan type dan nama yang sesuai di ScreenGui")
        end
    end
end
```

#### 22.4. Component Registry (Extendable)

```lua
function UIManager:GetComponentRegistry()
    return {
        now_playing_title = {
            names = {"title", "judul", "songname", "namalagu", "nowplaying", "currentsong"},
            types = {"TextLabel", "TextButton"}
        },
        now_playing_artist = {
            names = {"artist", "artis", "penyanyi", "singer", "band", "musisi"},
            types = {"TextLabel", "TextButton"}
        },
        play_button = {
            names = {"play", "main", "start", "putar", "begin", "run"},
            types = {"TextButton", "ImageButton"}
        },
        pause_button = {
            names = {"pause", "jeda", "stop", "berhenti", "halt"},
            types = {"TextButton", "ImageButton"}
        },
        volume_slider = {
            names = {"volume", "vol", "sound", "suara", "slider", "progress"},
            types = {"Frame", "ImageButton"}
        }
        -- Bisa extend lagi...
    }
end
```

#### 22.5. Benefits Smart UI System

-   **✅ Zero Boilerplate** - Modul cuma panggil 1 function
-   **✅ AI-Powered Discovery** - Auto find components berdasarkan multi-language patterns
-   **✅ Smart Error Messages** - Clear guidance untuk fix issues
-   **✅ Type Validation** - Auto validate component types
-   **✅ Easy Migration** - Ganti UI mode tinggal ubah 1 config
-   **✅ Centralized Logic** - Semua UI complexity di core

---

## 🎯 QUICK START GUIDE (BATTLE TESTED) - **UPDATED**

### 1. Setup Project Structure

```bash
# Gunakan struktur di Decision #2.1 (Updated dengan UIManager)
# Pastikan Rojo config sesuai Decision #2.2
```

### 2. Implement Kernel First

```lua
-- Copy-paste code dari Decision #1.1 dan #1.2
-- JANGAN diubah urutan phase atau domain priority!
```

### 3. Add Core Modules

```lua
-- Logger (Shared/Logger/manifest.lua) - wajib pertama
-- Config (Server/config.lua, Shared/config.lua)
-- UIManager (Server/Core/UIManager/manifest.lua) - 🆕 SMART UI! - PATH FIXED
```

### 4. Create Business Modules (SUPER SIMPLE!)

```lua
-- MusicPlayerUI/config.lua (SIMPLE!)
return {
    ui = {
        mode = "StarterGui",  -- Pilih UI engine
        screen_gui = "MusicPanel",
        components = {
            now_playing_title = "TextLabel",
            play_button = "TextButton"
        }
    }
}

-- MusicPlayerUI/manifest.lua (SIMPLE!)
function MusicPlayerUI:Init()
    local kernel = self:GetKernel()
    self.uiManager = kernel:GetModule("UIManager")
    self.ui = self.uiManager:SetupModuleUI("MusicPlayer", self.config)
    -- Done! Core handle UI complexity
end
```

### 5. Test & Validate

```lua
-- Expected output:
-- PHASE 0: Server Bootstrap...
-- PHASE 0: Client Bootstrap...
-- Shared Modules Loaded: OVHL_UI, Network, UIManager
-- MusicModule Initialized
-- MusicPlayerUI Initialized dengan Smart UI
-- 🔍 UIManager: Found 5 components untuk MusicPlayer
```

## 🚨 COMMON PITFALLS & SOLUTIONS (LESSONS LEARNED) - **UPDATED**

### ❌ "Module not found: OVHLUI"

**Solution:** Pastikan module name consistency - Kernel simpan `OVHL_UI`, cari `OVHL_UI`

### ❌ "Kernel tidak tersedia"

**Solution:** Implement `SetKernel()` di modul dan Kernel injection di Phase 3

### ❌ Circular Dependency

**Solution:** Ikuti strict rules di Decision #4.1 - hanya cache di Init()

### ❌ Shared Modules Not Loading

**Solution:** Pastikan Client Kernel ada Phase 2B (Shared loading) setelah internal domains

### ❌ "Component tidak ditemukan"

**Solution:** UIManager akan kasih smart error message dengan expected types & names

### ❌ UI Complexity di Modul

**Solution:** Gunakan Core UIManager - modul hanya specify expectations, core handle implementation
