# 🏛️ 01 - ADR (Architecture Decision Record) - FINAL

**Version 4.2 (Logger, Domain, Contract Ready)** | **For Technical Developers & AI**

> **Project Map:** Pura Pura Pesta | Tampat Nonton Konser Dengan Zona Panggung Berbeda Genre

---

## 🚀 CHANGELOG V4.2 (NEW)

-   **Tambahan (Decision #8):** Menambahkan `Logger & Log Level System` untuk kontrol log granular (Debug vs Info) dengan format emoji.
-   **Tambahan (Decision #9):** Menambahkan `Module Domain Organization` (Core, Services, Business) untuk arsitektur yang lebih rapi.
-   **Tambahan (Decision #10):** Menambahkan `Attribute-Based Builder Contract` untuk workflow "zero code touch" bagi builder.
-   **Update:** Mengganti `File Structure Reference` V4.1 dengan V4.2 (Domain-based).
-   **Update:** Memperbarui `Module Template` untuk menyesuaikan _relative path_ setelah migrasi domain.

## 🚀 CHANGELOG V4.1.1

-   **Penambahan:** Menambahkan _snippet_ `default.project.json` yang sudah _work_ ke dalam ADR (di bawah File Structure) untuk mengunci _path mapping_ Rojo dan mencegah ambiguitas AI.

## 🚀 CHANGELOG V4.1

-   **Integrasi 3rd Party (Decision #5):** Diperbarui dari "How-to" menjadi **"Abandoned"**.
-   **Logger Fix (V4):** Modul Logger diperbarui untuk memperbaiki bug _cache_ `EnableVerboseLogs`.
-   **AI Workflow (Decision #7):** Menambahkan **Decision #7 (AI & Workflow Execution Policy)**.
-   **Aturan AI:** Memperbarui "Critical Rules for AI Assistants".
-   **Global Volume (Decision):** Fitur `SetGlobalVolume` **DITIADAKAN**.

---

## **📌 DOCUMENT PURPOSE**

This ADR is the **SINGLE SOURCE OF TRUTH** for:

-   How modules communicate
-   How to integrate 3rd party systems
-   Step-by-step examples
-   What AI assistants MUST know

**Target Audience:** Non-technical developers + AI assistants

---

## **🎯 CORE ARCHITECTURE DECISIONS**

### **Decision #1: Folder-Based Auto-Discovery (Simplified)**

**Context:** We need plug-and-play modules without manual registration.
**Decision:** Use a 3-phase loading process managed by a main "Kernel" `init.lua`.

**Implementation Pattern (Main `Server/init.lua`):**

```lua
-- This is the "Kernel"
local ServerKernel = {}
ServerKernel.Modules = {}

-- Central function to get modules
function ServerKernel:GetModule(moduleName)
    local module = self.Modules[moduleName]
    if not module then
        warn("[KERNEL] Module not found:", moduleName)
    end
    return module
end

-- === PHASE 1: CORE BOOT ===
-- Manually load critical modules at the same level (sibling files)
local Logger = require(script.Logger)
ServerKernel.Modules["Logger"] = Logger
local Config = require(script.Config)
ServerKernel.Modules["Config"] = Config

-- === PHASE 2: MODULE DISCOVERY ===
-- Auto-scan FOLDERS (not all files) for modules
-- [UPDATE V4.2]: This logic is expanded by Decision #9 to scan domain folders
for _, item in ipairs(script:GetChildren()) do
    if item:IsA("Folder") and item:FindFirstChild("init") then
        local moduleName = item.Name
        local success, module = pcall(require, item.init)
        if success then
            ServerKernel.Modules[moduleName] = module
        else
            warn("[KERNEL] Failed to load module:", moduleName, module)
        end
    end
end

-- === PHASE 3: INITIALIZATION ===
-- After ALL modules are loaded and registered, call their :Init()
for name, module in pairs(ServerKernel.Modules) do
    if type(module) == "table" and type(module.Init) == "function" then
        local success, err = pcall(module.Init, module)
        if not success then
            warn("[KERNEL] Failed to initialize module:", name, err)
        end
    end
end

return ServerKernel
```

**Why This Matters:**

-   ✅ **Plug-and-Play:** Drop a new folder with `init.lua` and it's loaded.
-   ✅ **Dependency Safe:** All modules `require`'d first, then `Init`'d second.

---

### **Decision #2: Communication via Relative Path Registry**

**Context:** Modules need to talk to each other without hardcoding paths.
**Decision:** All modules use a **relative path** (`script.Parent.Parent.init` or `script.Parent.Parent.Parent.init`) to access the main "Kernel".

**Implementation Pattern (Module `Server/Business/MusicModule/init.lua`):**

```lua
local MusicManager = {}

-- [UPDATE V4.2]: Get the Kernel by going up three levels
-- (MusicModule -> Business -> Server -> init.lua)
local ServerKernel = require(script.Parent.Parent.Parent.init)

-- Cache modules (will be assigned in Init)
local Logger
local Config

function MusicManager:Init()
    -- Get dependencies SAFELY from the Kernel
    -- This runs in Phase 3, so all modules are guaranteed to be loaded.
    Logger = ServerKernel:GetModule("Logger")
    Config = ServerKernel:GetModule("Config")

    if Logger then
        -- [UPDATE V4.2]: Using new Logger standard
        Logger:Info("MusicModule", "MUSIC", "MusicManager Initialized")
    end
end

-- ...
return MusicManager
```

**Why This Matters:**

-   ✅ **Rojo-Friendly:** Works with any Rojo structure.
-   ✅ **Scalable:** Move the `Server` folder, code doesn't break.

---

### **Decision #3: Network Communication via RemoteWrapper**

**Context:** Client-Server communication needs to be safe and typed.
**Decision:** Centralized RemoteEvent/RemoteFunction wrapper.

**File Structure:**

```
Shared/Network/
├── init.lua
├── Events.lua
├── RemoteWrapper.lua
└── Serializer.lua
```

**Events.lua - Define ALL Remotes Here:**

```lua
return {
    -- Format: [EventName] = "RemoteType"
    -- Music System Events
    ["UpdateUI"] = "Event",
    ["VoteToSkip"] = "Event",
    -- Music System Functions
    ["RequestSong"] = "Function",
    -- ... (V4.1+ Fitur Baru)
}
```

**RemoteWrapper.lua - Safe Communication:**

```lua
local RemoteWrapper = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = require(script.Parent.Events)
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder")
RemotesFolder.Name = "Remotes"
RemotesFolder.Parent = ReplicatedStorage

-- (Auto-create remotes from Events.lua) ...
-- ... (Wrapper functions: FireClient, FireAllClients, FireServer, etc) ...
-- ... (Wrapper listeners: OnServerEvent, OnClientEvent) ...

return RemoteWrapper
```

**Why This Matters:**

-   ✅ All network communication in ONE place.
-   ✅ Easy to add new remotes (just add to Events.lua).

---

### **Decision #4: TopbarPlus Integration - Navbar Specialist**

**Context:** We need a mobile-friendly navbar.
**Decision:** Use TopbarPlus for navbar actions and OVHL UI System for content display.

**Division of Responsibilities:**

```lua
-- 🎪 TOPBARPLUS V3 (Navbar Specialist)
Responsibilities = {
    "Navbar Icons & Positioning",
    "Dropdown Menu Systems",
    -- ...
}

-- 🎨 OVHL UI SYSTEM (Content Specialist)
Responsibilities = {
    "Modal Popups & Dialogs",
    "Content Panels & Layouts",
    -- ...
}
```

**Implementation Pattern (`Client/Services/TopbarIntegration/init.lua`):**

```lua
-- Client/Services/TopbarIntegration/init.lua
local TopbarIntegration = {}
local Icon = require(game:GetService("ReplicatedStorage").TopbarPlus.Icon)
-- [UPDATE V4.2] Pathing updated for domain structure
local ClientKernel = require(script.Parent.Parent.Parent.init)

function TopbarIntegration:Init()
    local musicIcon = Icon.new()
        :setLabel("Music")
        -- ...

    -- Open OVHL UI modal when icon clicked
    musicIcon.selected:Connect(function()
        local UIModule = ClientKernel:GetModule("UIModule")
        if UIModule then
             -- UIModule akan memanggil OVHLUI.ModalSystem:Open(...)
             UIModule:ToggleMusicPanel()
        end
    end)
end

return TopbarIntegration
```

**Why This Matters:**

-   ✅ Each system does what it's best at.
-   ✅ Clean separation of concerns.

---

### **Decision #5: Integrasi 3rd Party (Kohl's Admin) --- Abandoned (V4.1)**

**Context:** Upaya untuk mendaftarkan command `/play` via `MusicCommandsServer.lua` ke Kohl's Admin System **gagal total**.
**Decision:** Kami **MENGABANDON** integrasi penuh dengan Kohl's Admin for _feature commands_.

1.  **PermissionSync:** Module `PermissionSync` (sekarang di `Server/Core/PermissionSync/init.lua`) kita tetap ada dan berfungsi sebagai jembatan _logic_ (untuk cek rank internal dan _bypass_ pembayaran).
2.  **MusicCommandsServer.lua:** File ini akan **DIPINDAHKAN** ke `Server/Legacy/` dan **DIABAIKAN**. Kontrol musik 100% melalui **UI kita** (`OVHL UI`).

**Hasil: Arsitektur Inti kita kini 100% _independent_ dari 3rd party _admin system_ yang rapuh.**

---

### **Decision #6: OVHL UI System - Centralized Content Management**

**Context:** We need consistent, branded UI components. TopbarPlus handles navbar but not complex content.
**Decision:** Create OVHL UI System specializing in modal content, layouts, and reusable components.

**Architecture Pattern:**

```bash
Shared/OVHL_UI/
├── init.lua          # UI Kernel / Component Factory
├── 🎪 ModalSystem/    # Popups, Dialogs
├── 📐 LayoutSystem/   # Grid, Stack
├── 🎨 ContentComponents/ # Card, List
└── 📝 FormComponents/   # Input, Slider, Button
```

**Implementation Pattern:**

```lua
-- Module (e.g., Client/Services/UIModule/init.lua)
-- [UPDATE V4.2] Pathing updated for domain structure
local ClientKernel = require(script.Parent.Parent.Parent.init)
local OVHLUI

function UIModule:Init()
    local SharedKernel = require(game:GetService("ReplicatedStorage").Shared.init)
    OVHLUI = SharedKernel:GetModule("OVHL_UI")
end

-- Module hanya panggil OVHL UI, tidak create UI sendiri
function UIModule:ShowMusicPanel()
    if not OVHLUI then return end

    -- Memanggil ModalSystem yang ada di dalam OVHL_UI
    OVHLUI.ModalSystem:Open("MusicPanel", {
        title = "Music Controller",
        content = {
            type = "Stack", -- Menggunakan Stack Layout
            -- ...
        }
    })
end
```

**Why This Matters:**

-   ✅ Consistent branding across all modules.
-   ✅ Modules focus on logic, not UI creation.

---

### **Decision #7: AI & WORKFLOW EXECUTION POLICY (V4.1)**

**Context:** _Delivery_ kode manual rentan terhadap _human error_.
**Decision:** Semua _code delivery_ dari AI harus mengikuti _atomic execution principle_ (via `bash` script).

**Implementation Policy (Wajib Dijalankan Oleh Developer):**

| **Langkah**             | **Deskripsi & File**                                            | **Rationale**                  |
| :---------------------- | :-------------------------------------------------------------- | :----------------------------- |
| **I: Eksekusi**         | Jalankan `bash lokal/tools/run.sh` dari _root_.                 | Standardisasi _pathing_.       |
| **II: Backup Otomatis** | Script WAJIB backup ke `./lokal/backups/...`.                   | Memungkinkan _rollback_ cepat. |
| **III: Code Delivery**  | Pengiriman kode _harus_ `cat << 'EOF' > [file_path]`.           | _Zero-human-error_ copy-paste. |
| **IV: Audit & Exit**    | Script harus menyertakan _audit check_ (`if [ ! -s "$file" ]`). | Memastikan integritas proyek.  |

---

### **Decision #8: Logger & Log Level System (NEW V4.2)**

**Context:**
Developer butuh kontrol granular terhadap log output. Di development, butuh log detail (DEBUG). Di production, cuma butuh INFO/ERROR.

**Decision:**
Implementasi **Multi-Level Logger** dengan emoji-based formatting dan per-module log control.

---

#### **8.1. Log Level Hierarchy**

```lua
-- Server/Logger.lua
local LOG_LEVELS = {
    DEBUG = 1,   -- 🔍 Verbose: function calls, data dumps
    INFO = 2,    -- ℹ️ Normal: user actions, state changes
    WARN = 3,    -- ⚠️ Warning: recoverable errors, deprecations
    ERROR = 4,   -- 💀 Critical: failures, exceptions
    PERF = 5     -- ⚡ Performance: timing data
}
```

---

#### **8.2. Config Structure**

```lua
-- Server/Config.lua
return {
    Debug = {
        -- Global log level (overrides module levels if set)
        GlobalLogLevel = "INFO", -- "DEBUG" | "INFO" | "WARN" | "ERROR" | "NONE"

        -- Per-module log levels (optional, overrides global)
        ModuleLevels = {
            MusicModule = "DEBUG",
            ZoneModule = "INFO",
            DataModule = "ERROR",
        },

        -- Performance logging (always separate toggle)
        EnablePerfLogs = false,
    }
}
```

---

#### **8.3. Log Format Specification**

**Template:**

```
[HH:MM:SS] {REALM} {DOMAIN} {LEVEL} {TYPE} [{MODULE}] {MESSAGE}
└─ Data: {JSON_DUMP} (optional, only DEBUG level)
```

**Emoji Mapping:**

```lua
local EMOJI = {
    -- Realm
    SERVER = "🖥️",
    CLIENT = "💻",
    SHARED = "🔗",

    -- Domain (Module Category)
    MUSIC = "🎵",
    ZONE = "🗺️",
    DATA = "💾",
    ADMIN = "👑",
    UI = "🎨",
    NETWORK = "📡",
    MONETIZATION = "💰",

    -- Level
    DEBUG = "🔍",
    INFO = "ℹ️",
    WARN = "⚠️",
    ERROR = "💀",
    PERF = "⚡",

    -- Type (Message Nature)
    ANNOUNCE = "📢", -- User-facing actions
    DATA = "📊",     -- Data dumps/inspection
    ACTION = "🎬",   -- System actions
    RESULT = "✅",   -- Success confirmations
}
```

---

#### **8.4. Implementation Pattern**

```lua
-- Server/Logger.lua
local Logger = {}
local Config -- Assigned during Init
local LOG_LEVELS = { DEBUG = 1, INFO = 2, WARN = 3, ERROR = 4, PERF = 5 }

function Logger:Init()
    local ServerKernel = require(script.Parent.init)
    Config = ServerKernel:GetModule("Config")
end

-- Core logging function
local function ShouldLog(moduleName, level)
    if not Config then return true end -- Fallback during boot

    local globalLevel = LOG_LEVELS[Config.Debug.GlobalLogLevel] or LOG_LEVELS.INFO
    local moduleLevel = Config.Debug.ModuleLevels[moduleName]

    local threshold = moduleLevel and LOG_LEVELS[moduleLevel] or globalLevel
    return LOG_LEVELS[level] >= threshold
end

function Logger:Debug(moduleName, domain, messageType, message, data)
    if not ShouldLog(moduleName, "DEBUG") then return end

    local timestamp = os.date("%H:%M:%S")
    local formatted = string.format(
        "[%s] 🖥️ %s 🔍 %s [%s] %s",
        timestamp,
        EMOJI[domain] or "❓",
        EMOJI[messageType] or "📢",
        moduleName,
        message
    )
    print(formatted)

    if data then
        print("└─ Data:", game:GetService("HttpService"):JSONEncode(data))
    end
end

function Logger:Info(moduleName, domain, message)
    if not ShouldLog(moduleName, "INFO") then return end

    local timestamp = os.date("%H:%M:%S")
    print(string.format(
        "[%s] 🖥️ %s ℹ️ 📢 [%s] %s",
        timestamp,
        EMOJI[domain] or "❓",
        moduleName,
        message
    ))
end

function Logger:Error(moduleName, domain, message, data)
    -- Errors ALWAYS log (ignore level checks)
    local timestamp = os.date("%H:%M:%S")
    warn(string.format(
        "[%s] 🖥️ %s 💀 📢 [%s] %s",
        timestamp,
        EMOJI[domain] or "❓",
        moduleName,
        message
    ))

    if data then
        warn("└─ Data:", game:GetService("HttpService"):JSONEncode(data))
    end
end

function Logger:Perf(moduleName, domain, operation, durationMs)
    if not Config or not Config.Debug.EnablePerfLogs then return end

    local timestamp = os.date("%H:%M:%S")
    print(string.format(
        "[%s] 🖥️ %s ⚡ 📢 [%s] %s took %.2fms",
        timestamp,
        EMOJI[domain] or "❓",
        moduleName,
        operation,
        durationMs
    ))
end

return Logger
```

---

#### **8.5. Usage Examples**

**Development Mode (`GlobalLogLevel = "DEBUG"`):**

```lua
-- Server/Business/MusicModule/init.lua
function MusicManager:PlaySong(songID, zone)
    local startTime = os.clock()

    Logger:Debug("MusicModule", "MUSIC", "DATA", "PlaySong called", {
        SongID = songID,
        Zone = zone
    })

    -- ... actual logic ...

    Logger:Info("MusicModule", "MUSIC", "Playing: Kopi Dangdut - Fahmi Shahab")

    local elapsed = (os.clock() - startTime) * 1000
    Logger:Perf("MusicModule", "MUSIC", "PlaySong", elapsed)
end
```

**Output (Development):**

```🖥️ 🎵 🔍 📊 [MusicModule] PlaySong called
└─ Data: {"SongID":"123","Zone":"dangdut"} 🖥️ 🎵 ℹ️ 📢 [MusicModule] Playing: Kopi Dangdut - Fahmi Shahab 🖥️ 🎵 ⚡ 📢 [MusicModule] PlaySong took 850.32ms
```

**Output (Production - `GlobalLogLevel = "INFO"`):**

```🖥️ 🎵 ℹ️ 📢 [MusicModule] Playing: Kopi Dangdut - Fahmi Shahab

```

**Output (Errors - ALWAYS show):**

```🖥️ 💾 💀 📢 [DataModule] CRITICAL: Data save failed for Player1
└─ Data: {"PlayerID":12345,"Error":"Request was throttled"}
```

---

#### **8.6. Builder/Scripter Workflow**

**For Builders:**

1. Buka `Server/Config.lua`
2. Set `GlobalLogLevel = "DEBUG"` untuk testing
3. Set `GlobalLogLevel = "INFO"` untuk production

**For Scripters:**

1. Gunakan `Logger:Debug()` untuk development logging
2. Gunakan `Logger:Info()` untuk user-facing actions
3. Gunakan `Logger:Error()` untuk critical failures
4. Gunakan `Logger:Perf()` untuk performance profiling

**Zero Learning Curve:** Module apapun cukup panggil `Logger:[Level]()`, Config otomatis mengatur apa yang ditampilkan.

---

#### **8.7. Why This Matters**

✅ **Granular Control:** Set log level per modul atau global.
✅ **Production-Ready:** Production logs tetap bersih tanpa debug spam.
✅ **Performance Monitoring:** Track bottleneck tanpa modify code.
✅ **Emoji Visual Aid:** Scan logs dengan cepat (domain, level).
✅ **Zero Manual Filter:** Config-driven, bukan hardcode `if DEBUG then`.

---

## **Decision #9: Module Domain Organization (NEW V4.2)**

**Context:**
Proyek besar butuh organisasi modul berdasarkan **responsibility domain** (Logic, Service, Business). Folder flat bikin hard maintenance.

**Decision:**
Implementasi **3-Tier Module Architecture** dengan domain-based folder grouping.

---

### **9.1. Domain Hierarchy (File Structure V4.2)**

Ini adalah **struktur file target** yang baru, menggantikan referensi V4.1.

```
Server/
├── init.lua                    # Kernel (unchanged)
├── Config.lua                  # Core (Phase 1)
├── Logger.lua                  # Core (Phase 1)
│
├── 🎯 Core/                    # System Foundations
│   ├── PermissionSync/         # Authorization logic (dulu AdminModule)
│   │   └── init.lua
│   └── ErrorHandler/           # Global error boundary (future)
│       └── init.lua
│
├── 🛎️ Services/                 # External Integrations
│   ├── DataModule/             # DataStore wrapper
│   │   └── init.lua
│   ├── MonetizationModule/     # Gamepass/DevProducts
│   │   └── init.lua
│   └── TextFilterModule/       # Roblox text filtering (future)
│       └── init.lua
│
├── 🎮 Business/                # Game Logic (Domain Specific)
│   ├── MusicModule/            # Music playback, AutoDJ
│   │   └── init.lua
│   ├── ZoneModule/             # Zone teleport, spatial audio
│   │   └── init.lua
│   └── SalamModule/            # Shoutout system
│       └── init.lua
│
└── 🔧 Legacy/                  # Deprecated/Abandoned
    └── KohlsAdminAddons/
        └── MusicCommands.server.lua
```

_(Struktur `Shared/` dan `Client/` akan mengikuti pola yang sama)_

---

### **9.2. Domain Definitions**

| Domain       | Emoji | Purpose                                    | Examples                              |
| ------------ | ----- | ------------------------------------------ | ------------------------------------- |
| **Core**     | 🎯    | System foundations, cross-cutting concerns | Permissions, Error Handling, Security |
| **Services** | 🛎️    | External integrations, I/O operations      | DataStore, Monetization, APIs         |
| **Business** | 🎮    | Game-specific logic, domain rules          | Music, Zones, Gameplay                |
| **Legacy**   | 🔧    | Deprecated/abandoned code (archived)       | Kohl's Admin addons                   |

---

### **9.3. Module Categorization Rules**

**Ask These Questions:**

1.  **"Does this module interact with Roblox services?"**
    → YES: Put in `Services/`
    → NO: Continue

2.  **"Is this game-specific logic?"**
    → YES: Put in `Business/`
    → NO: Continue

3.  **"Is this a system-wide concern (auth, errors)?"**
    → YES: Put in `Core/`

4.  **"Is this abandoned/deprecated?"**
    → YES: Put in `Legacy/`

---

### **9.4. Migration from Flat Structure**

**Before (V4.1):**

```
Server/
├── AdminModule/        # 🎯 Core
├── MusicModule/        # 🎮 Business
├── DataModule/         # 🛎️ Service
├── MonetizationModule/ # 🛎️ Service
```

**After (V4.2):**

```
Server/
├── Core/
│   └── PermissionSync/ (rename dari AdminModule)
├── Business/
│   └── MusicModule/
└── Services/
    ├── DataModule/
    └── MonetizationModule/
```

**Path Change Impact:**

-   **Kernel:** Auto-discovery perlu di-update (lihat 9.5).
-   **Relative Paths:** `script.Parent.Parent.init` menjadi `script.Parent.Parent.Parent.init` (naik 1 level lagi).
-   **GetModule():** Nama tetap sama (`GetModule("MusicModule")`).

---

### **9.5. Updated Kernel (Phase 2 Discovery)**

Ini adalah **update** untuk `Phase 2` dari **Decision #1**.

```lua
-- Server/init.lua
-- === PHASE 2: MODULE DISCOVERY ===
local DOMAIN_FOLDERS = { "Core", "Services", "Business" }

for _, domainFolder in ipairs(DOMAIN_FOLDERS) do
    local domain = script:FindFirstChild(domainFolder)
    if not domain then continue end

    for _, item in ipairs(domain:GetChildren()) do
        if item:IsA("Folder") and item:FindFirstChild("init") then
            local moduleName = item.Name
            local success, module = pcall(require, item.init)
            if success then
                ServerKernel.Modules[moduleName] = module
            else
                warn("[KERNEL] Failed to load module:", moduleName, module)
            end
        end
    end
end
```

---

### **9.6. Benefits**

✅ **Mental Model:** Developer langsung tau "ini modul business logic atau service?"
✅ **Scalability:** Tambah modul baru, tinggal tentuin domainnya.
✅ **Code Review:** Reviewer langsung tau scope/responsibility.
✅ **Future AI:** AI bisa kategorisasi otomatis berdasarkan domain.

---

## **Decision #10: Attribute-Based Builder Contract (NEW V4.2)**

**Context:**
Builder harus bisa **configure game logic via Attributes** tanpa touch code. Scripter **WAJIB** respect attribute naming conventions.

**Decision:**
Implementasi **Attribute Contract System** dengan strict naming conventions dan auto-validation.

---

### **10.1. Attribute Naming Convention**

**Format:**

```
[Domain]_[Property]:[Value]
```

**Examples:**

```
Zone_ID: "dangdut"           # String
Audio_Side: "L"              # Enum (L/R/C)
Spawn_Priority: 10           # Number
UI_IsInteractable: true      # Boolean
```

---

### **10.2. Domain-Specific Attributes**

#### **🗺️ Zone System**

```lua
-- Model: Workspace.Stages.DangdutStage
Attributes = {
    Zone_ID = "dangdut",          -- (String) Unique zone identifier
    Zone_DisplayName = "Dangdut", -- (String) UI-friendly name
    Spawn_Position = Vector3,     -- (Vector3) Player spawn point
    Spawn_Priority = 1            -- (Number) Default spawn (1 = highest)
}
```

#### **🎵 Audio System**

```lua
-- Part: Workspace.AudioEmitters.SpeakerLeft
Attributes = {
    Audio_Side = "L",             -- (String) "L" | "R" | "C" (Center)
    Audio_ZoneID = "dangdut",     -- (String) Which zone this speaker belongs to
    Audio_MaxDistance = 100       -- (Number) Spatial audio range
}
```

#### **🎨 UI World Elements (LED/Video Tron)**

```lua
-- Part: Workspace.LED.DangdutScreen (with SurfaceGui)
Attributes = {
    UI_Type = "NowPlaying",       -- (String) "NowPlaying" | "Shoutout"
    UI_ZoneID = "dangdut",        -- (String) Which zone
    UI_RefreshRate = 0.5          -- (Number) Update interval (seconds)
}
```

---

### **10.3. Builder Workflow (Zero Code)**

**Step 1: Create Model**

```
Builder creates: Workspace.Stages.RockStage
```

**Step 2: Add Attributes (via Studio Properties)**

```
Zone_ID: "rock"
Zone_DisplayName: "Rock Zone"
Spawn_Position: Vector3.new(0, 5, 0)
```

**Step 3: Test**

```
Script auto-detects → Zone registered → Players can teleport
```

**NO CODE TOUCH REQUIRED** ✅

---

### **10.4. Scripter Contract (Validation)**

**All modules MUST validate attributes on Init:**

```lua
-- Server/Business/ZoneModule/init.lua
local ZoneModule = {}
local Logger
local ServerKernel

function ZoneModule:Init()
    ServerKernel = require(script.Parent.Parent.Parent.init)
    Logger = ServerKernel:GetModule("Logger")
    self:ScanZones()
end

function ZoneModule:ScanZones()
    local stages = workspace:WaitForChild("Stages")

    for _, stage in ipairs(stages:GetChildren()) do
        local zoneID = stage:GetAttribute("Zone_ID")
        local displayName = stage:GetAttribute("Zone_DisplayName")
        local spawnPos = stage:GetAttribute("Spawn_Position")

        -- VALIDATION (Builder Contract)
        if not zoneID then
            Logger:Error("ZoneModule", "ZONE", "Missing Zone_ID attribute", {
                Model = stage.Name
            })
            continue
        end

        if not displayName then
            Logger:Warn("ZoneModule", "ZONE", "Missing Zone_DisplayName, using Zone_ID", {
                Model = stage.Name
            })
            displayName = zoneID
        end

        -- Register zone
        self.Zones[zoneID] = {
            Model = stage,
            DisplayName = displayName,
            SpawnPosition = spawnPos or stage.PrimaryPart.Position
        }

        Logger:Info("ZoneModule", "ZONE", string.format(
            "Registered zone: %s (%s)", zoneID, displayName
        ))
    end
end
```

---

### **10.5. Attribute Contract Documentation**

**Create:** `docs/AttributeContract.md`

```markdown
# 🏗️ Attribute Contract for Builders

## Zone System

### Required Attributes

-   `Zone_ID` (String): Unique identifier (lowercase, no spaces)
-   `Zone_DisplayName` (String): Name shown in UI

### Optional Attributes

-   `Spawn_Position` (Vector3): Custom spawn point
-   `Spawn_Priority` (Number): Default spawn (1 = highest)

### Example Setup

1. Create model: `Workspace.Stages.DangdutStage`
2. Add attributes:
    - Zone_ID: `"dangdut"`
    - Zone_DisplayName: `"Dangdut Zone"`
3. Test: Join game → Zone appears in UI

## Audio System

### Required Attributes (for Speaker Parts)

-   `Audio_Side` (String): `"L"` or `"R"` or `"C"`
-   `Audio_ZoneID` (String): Must match a Zone_ID

### Optional Attributes

-   `Audio_MaxDistance` (Number): Spatial audio range (default: 100)
```

---

### **10.6. Benefits**

✅ **Builder Independence:** Builder bisa test tanpa nunggu scripter.
✅ **Type Safety:** Attribute validation di script, bukan runtime error.
✅ **Documentation:** Contract jadi single source of truth.
✅ **Hot Reload:** Ganti attribute → auto update (no reboot).
✅ **AI Future-Proof:** AI bisa generate attribute setup dari natural language.

---

## **🚨 CRITICAL RULES FOR AI ASSISTANTS (Update V4.1)**

**(NOTE: Referensi utama AI adalah `00-Blueprint-AI-Doctrine.md`. Ini adalah rangkuman teknis.)**

**❌ NEVER:**

-   (NEW) **JANGAN PERNAH** memberikan kode Lua langsung di _chat_.
-   (NEW) **JANGAN PERNAH** meminta developer _copy-paste_ baris per baris.
-   (NEW) **JANGAN ASUMSIKAN** `MusicCommandsServer.lua` akan berhasil (Sesuai Decision #5).
-   Hardcode paths like `game.ServerScriptService.PuraPuraPesta`.

**✅ ALWAYS (The Delivery Standard):**

-   **(NEW) Deliver the Fix:** Rangkum semua perubahan ke dalam **satu _bash_ script** (Sesuai Decision #7).
-   **(NEW) Pathing:** Selalu gunakan _full_ path relatif (`src/Server/Business/...`).
-   **(NEW) Safety:** Sertakan **Backup**, **Action (cat << EOF)**, **Audit**.
-   Use `GetModule()` to access other modules.
-   Use **relative paths** (`require(script.Parent.Parent.Parent.init)`) for internal modules.
-   ONLY use **full paths** (`require(game.ServerScriptService.Server.init)`) for 3rd-party addons.

---

## **📦 MODULE TEMPLATE LIBRARY (Update V4.2)**

### **Custom Module Template (`Server/Business/MyModule/init.lua`):**

```lua
local ModuleName = {}

-- [UPDATE V4.2]: Get Kernel via relative path (3 levels up)
local ServerKernel = require(script.Parent.Parent.Parent.init)
-- Example: Get Shared Kernel
local SharedKernel = require(game:GetService("ReplicatedStorage").Shared.init)

-- Cache modules (will be assigned in Init)
local Logger
local Config
local RemoteWrapper

function ModuleName:Init()
    -- Get dependencies
    Logger = ServerKernel:GetModule("Logger")
    Config = ServerKernel:GetModule("Config")
    RemoteWrapper = SharedKernel:GetModule("RemoteWrapper")

    if Logger then
        -- [UPDATE V4.2]: New Logger Standard
        Logger:Info("ModuleName", "❓", "ModuleName Initialized")
    end
end

-- ...
return ModuleName
```

---

## **📋 FILE STRUCTURE REFERENCE (DEPRECATED V4.1)**

Struktur file di bawah ini **SUDAH DIGANTIKAN** oleh **Decision #9.1 (Domain Hierarchy)**.

---

### **Rojo `default.project.json` (V4.1.1)**

Ini adalah _mapping_ Rojo yang **WAJIB** digunakan untuk proyek ini. AI harus menggunakan _path_ ini sebagai _ground truth_. (Mapping ini tetap valid bahkan setelah Decision #9, karena kita tetap map folder `src/Server` utamanya).

```json
{
    "name": "PuraPuraPesta",
    "tree": {
        "$className": "DataModel",

        "ServerScriptService": {
            "Server": {
                "$path": "src/Server"
            },

            "Kohl's Admin": {
                "$className": "Folder",
                "Config": {
                    "$className": "Configuration",
                    "Addons": {
                        "$path": "src/Server/Legacy/KohlsAdminAddons"
                    }
                }
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

## **🛠 ERROR HANDLING PATTERNS**

### **The Three-Layer Safety Net:**

**Layer 1: Defensive Checks**

```lua
function SafeFunction(player, data)
    if not player or not player:IsA("Player") then
        -- [UPDATE V4.2] Gunakan Logger
        Logger:Warn("MyModule", "❓", "Invalid player passed to SafeFunction")
        return nil
    end
end
```

**Layer 2: Protected Calls (pcall)**

```lua
function TryDangerousOperation()
    local success, result = pcall(function()
        return DangerousOperation()
    end)
    if not success then
        -- [UPDATE V4.2] Gunakan Logger
        Logger:Error("MyModule", "❓", "Operation failed", { error = result })
        return FallbackOperation()
    end
    return result
end
```

**Layer 3: Graceful Degradation**
(Contoh: Jika `PlayWithFade` gagal, `PlayDirect`)

---

### **Error Logging Standard (V4.2 FIX)**

> **[UPDATE V4.2] Logger Fix (CRITICAL FIX)**
>
> **Context:** `Logger v3` (di V4.1) _cache_ `EnableVerboseLogs`, membuatnya _stuck_.
>
> **Decision (Logger v4.2):** Hapus _local cache_. Fungsi Logger (seperti `ShouldLog` di Decision #8.4) harus membaca `Config` secara **langsung** setiap kali dipanggil. Ini memastikan perubahan `Config.lua` langsung aktif tanpa perlu _restart_ server.

---

## **📚 GLOSSARY**

| Term                   | Definition                                                                   |
| :--------------------- | :--------------------------------------------------------------------------- |
| **Kernel**             | The main `init.lua` (Server/Client/Shared) that manages module loading.      |
| **Init()**             | Initialization function called by the Kernel _after_ all modules are loaded. |
| **GetModule()**        | Function on the Kernel to safely access other modules.                       |
| **RemoteWrapper**      | Abstraction layer for client-server communication.                           |
| **PermissionSync**     | (Dulu AdminModule) Bridge for authorization logic.                           |
| **OVHL UI**            | The centralized UI system for content, modals, and components.               |
| **Domain**             | (V4.2) Kategori modul: `Core`, `Services`, atau `Business`.                  |
| **Attribute Contract** | (V4.2) Aturan Atribut (Attributes) untuk workflow Builder-Scripter.          |

---

**Document Version:** 4.2
**Last Updated:** 2025-11-07
**Status:** Production Ready ✅
