# 🏛️ 01 - ADR (Architecture Decision Record) - FINAL

**Version 4.1.1 (Rojo Ready)** | **For Non-Technical Developers**

> **Project Map:** Pura Pura Pesta | Tampat Nonton Konser Dengan Zona Panggung Berbeda Genre

---

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

### **Decision #1: Folder-Based Auto-Discovery (NEW & SIMPLIFIED)**

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

### **Decision #2: Communication via Relative Path Registry (NEW & SIMPLIFIED)**

**Context:** Modules need to talk to each other without hardcoding paths.
**Decision:** All modules use a **relative path** (`script.Parent.Parent.init`) to access the main "Kernel".

**Implementation Pattern (Module `Server/MusicModule/init.lua`):**

```lua
local MusicManager = {}

-- Get the Kernel by going up two levels (MusicModule -> Server -> init.lua)
local ServerKernel = require(script.Parent.Parent.init)

-- Cache modules (will be assigned in Init)
local Logger
local Config

function MusicManager:Init()
    -- Get dependencies SAFELY from the Kernel
    -- This runs in Phase 3, so all modules are guaranteed to be loaded.
    Logger = ServerKernel:GetModule("Logger")
    Config = ServerKernel:GetModule("Config")

    if Logger then
        Logger:Info("MusicManager Initialized")
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

**Implementation Pattern (`Client/TopbarIntegration/init.lua`):**

```lua
-- Client/TopbarIntegration/init.lua
local TopbarIntegration = {}
local Icon = require(game:GetService("ReplicatedStorage").TopbarPlus.Icon)
local ClientKernel = require(script.Parent.Parent.init)

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

1.  **PermissionSync:** Module `PermissionSync` (di `Server/AdminModule/init.lua`) kita tetap ada dan berfungsi sebagai jembatan _logic_ (untuk cek rank internal dan _bypass_ pembayaran).
2.  **MusicCommandsServer.lua:** File ini akan **DITINGGALKAN** dan **DIABAIKAN**. Kontrol musik 100% melalui **UI kita** (`OVHL UI`).

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
-- Module (e.g., Client/UIModule/init.lua)
local ClientKernel = require(script.Parent.Parent.init)
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

### **Decision #7: AI & WORKFLOW EXECUTION POLICY (NEW V4.1)**

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

## **🚨 CRITICAL RULES FOR AI ASSISTANTS (Update V4.1)**

**❌ NEVER:**

-   (NEW) **JANGAN PERNAH** memberikan kode Lua langsung di _chat_.
-   (NEW) **JANGAN PERNAH** meminta developer _copy-paste_ baris per baris.
-   (NEW) **JANGAN ASUMSIKAN** `MusicCommandsServer.lua` akan berhasil (Sesuai Decision #5).
-   Hardcode paths like `game.ServerScriptService.PuraPuraPesta`.

**✅ ALWAYS (The Delivery Standard):**

-   **(NEW) Deliver the Fix:** Rangkum semua perubahan ke dalam **satu _bash_ script** (Sesuai Decision #7).
-   **(NEW) Pathing:** Selalu gunakan _full_ path relatif (`src/Server/...`).
-   **(NEW) Safety:** Sertakan **Backup**, **Action (cat << EOF)**, **Audit**.
-   Use `GetModule()` to access other modules.
-   Use **relative paths** (`require(script.Parent.Parent.init)`) for internal modules.
-   ONLY use **full paths** (`require(game.ServerScriptService.Server.init)`) for 3rd-party addons.

---

## **📦 MODULE TEMPLATE LIBRARY**

### **Custom Module Template (`Server/MyModule/init.lua`):**

```lua
local ModuleName = {}

-- UPDATED: Get Kernel via relative path
local ServerKernel = require(script.Parent.Parent.init)
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
        Logger:Info("[ModuleName] Initialized")
    end
end

-- ...
return ModuleName
```

---

## **📋 FILE STRUCTURE REFERENCE (V4.1)**

This is the **target structure** this ADR is built for.

```bash
src/
├── Server/
│   ├── init.lua          # Main Server Kernel
│   ├── Config.lua        # Core Module (Phase 1)
│   ├── Logger.lua        # Core Module (Phase 1)
│   ├── AdminModule/
│   │   └── init.lua
│   ├── MusicModule/
│   │   └── init.lua
│   ├── ZoneModule/
│   │   └── init.lua
│   ├── DataModule/       # (V4.1+) New Module
│   │   └── init.lua
│   ├── SalamModule/      # (V4.1+) New Module
│   │   └── init.lua
│   ├── MonetizationModule/ # (V4.1+) New Module
│   │   └── init.lua
│   └── KohlsAdminAddons/
│       └── MusicCommands.server.lua # [STATUS: ABANDONED V4.1]
│
├── Shared/
│   ├── init.lua          # Main Shared Kernel
│   ├── Theme.lua         # Core Module (Phase 1)
│   ├── TextFilter/     # (V4.1+) New Module
│   │   └── init.lua
│   ├── OVHL_UI/
│   │   └── init.lua
│   │   ├── ...
│   └── Network/
│       ├── init.lua
│       ├── ...
│
└── Client/
    ├── init.lua          # Main Client Kernel
    ├── Responsive.lua    # Core Module (Phase 1)
    ├── TopbarIntegration/
    │   └── init.lua
    ├── UIModule/
    │   └── init.lua
    ├── ZoneModule/
    │   └── init.lua
    └── WorldUIModule/    # (V4.1+) New Module
        └── init.lua
```

### **Rojo `default.project.json` (V4.1.1)**

Ini adalah _mapping_ Rojo yang **WAJIB** digunakan untuk proyek ini. AI harus menggunakan _path_ ini sebagai _ground truth_.

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
                        "$path": "src/Server/KohlsAdminAddons"
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
        warn("[SafeFunction] Invalid player")
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
        warn("[ERROR] Operation failed:", result)
        return FallbackOperation()
    end
    return result
end
```

**Layer 3: Graceful Degradation**
(Contoh: Jika `PlayWithFade` gagal, `PlayDirect`)

---

### **Error Logging Standard (V4.1 FIX)**

> **[UPDATE V4.1] Logger Fix (CRITICAL FIX)**
>
> **Context:** `Logger v3` _cache_ `EnableVerboseLogs`, membuatnya _stuck_.
>
> **Decision (Logger v4):** Hapus _local cache_. Fungsi Logger harus membaca `Config` secara **langsung**.
>
> **Implementation Pattern (V4.1):**
>
> ```lua
> -- Di dalam Logger.lua
> local Config -- Di-require di atas
>
> function Logger:Info(moduleName, ...)
>     -- Membaca Config langsung
>     if not Config.Debug.EnableVerboseLogs then return end
>     local message = string.format(...)
>     print(string.format(LOG_TEMPLATE, "🖥️ SERVER", moduleName, message))
> end
> ```

---

## **📚 GLOSSARY**

| Term               | Definition                                                                   |
| :----------------- | :--------------------------------------------------------------------------- |
| **Kernel**         | The main `init.lua` (Server/Client/Shared) that manages module loading.      |
| **Init()**         | Initialization function called by the Kernel _after_ all modules are loaded. |
| **GetModule()**    | Function on the Kernel to safely access other modules.                       |
| **RemoteWrapper**  | Abstraction layer for client-server communication.                           |
| **PermissionSync** | Bridge between Kohl's Admin and music system permissions.                    |
| **OVHL UI**        | The centralized UI system for content, modals, and components.               |

---

**Document Version:** 4.1.1
**Last Updated:** 2025-11-06
**Status:** Production Ready ✅
