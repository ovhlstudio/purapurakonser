## 🏛️ 04 - ADR LOG (Catatan Perubahan Arsitektur)

**Versi:** 2.1.0 (Smart UI System)  
**Status:** FINAL  
**Tujuan:** Mencatat _kenapa_ dan _kapan_ keputusan arsitektur (ADR) di `01-ARCHITECTURE.md` diubah.  
**Aturan:** Entri terbaru SELALU di paling atas (Reverse Chronological).

---

### [2025-11-11] - Decision #23 (KOREKSI V2) - Integrasi TopbarPlus & AppShell

-   **[KEPUTUSAN]:** Mengadopsi `TopbarPlus` dari Marketplace, dan membuat Modul "Jembatan" (`AppShell`) di dalam domain **Services**.
-   **[KONTEKS]:**
    -   `MusicPlayerUI` membutuhkan titik masuk (entry point) `ToggleUI()`.
    -   Aset `TopbarPlus` berada di `ReplicatedStorage.TopbarPlus.Icon` (bukan di `src/`).
    -   Modul _gameplay_ (`OVHL_Modules`) dilarang memanggil _path_ eksternal secara langsung.
-   **[ALASAN (KOREKSI ARSITEKTUR)]:**
    -   `AppShell` adalah _integrasi eksternal_, bukan _logic gameplay_.
    -   Sesuai `Decision #2`, _domain_ yang tepat untuk integrasi eksternal adalah `Services`.
-   **[PERUBAHAN FUNDAMENTAL]:**
    1.  Dibuat modul "Jembatan Pintar" (Auto-Discovery) baru di: **`src/Client/Services/AppShell/`**.
    2.  `AppShell` adalah satu-satunya modul yang me-_require_ `ReplicatedStorage.TopbarPlus.Icon`.
    3.  `AppShell` akan secara otomatis memindai semua modul lain untuk fungsi `GetTopbarConfig()`.
    4.  Modul lain (seperti `MusicPlayerUI`) akan "mengumumkan" tombol mereka dengan mengimplementasikan `GetTopbarConfig()`.

---

### [2025-11-11] - Decision #23 (KOREKSI) - Integrasi Library TopbarPlus

-   **[KEPUTUSAN]:** Mengadopsi `TopbarPlus` sebagai _library_ UI standar dari Marketplace.
-   **[KONTEKS]:**
    -   Modul `MusicPlayerUI` membutuhkan titik masuk (entry point) untuk `ToggleUI()`.
    -   Aset `TopbarPlus` **TIDAK** di-sync via Rojo (`src/`).
-   **[LOKASI ASET (PENTING!)]:** `ReplicatedStorage.TopbarPlus.Icon` (ModuleScript).
-   **[ALASAN]:**
    -   Standarisasi API tombol _top-bar_.
    -   Menghindari dependensi _hardcoded_ di dalam modul _gameplay_ (Separation of Concerns).
-   **[PERUBAHAN FUNDAMENTAL]:**
    1.  Modul _gameplay_ (seperti `MusicPlayerUI`) **DILARANG KERAS** me-_require_ `ReplicatedStorage.TopbarPlus.Icon` secara langsung.
    2.  Dibuat modul "Jembatan" (Bridge) baru: **`Client/OVHL_Modules/AppShell/`**.
    3.  `AppShell` adalah satu-satunya modul yang diizinkan untuk me-_require_ `TopbarPlus` dan bertugas menghubungkannya dengan modul Kernel lain (seperti `MusicPlayerUI:ToggleUI()`).

---

### [2024-11-11] - Koreksi Kritis Decision #22 - Relokasi UIManager ke Client

-   **[KEPUTUSAN]:** Memindahkan `UIManager` dari `Server/Core/UIManager` ke `Client/Core/UIManager`.
-   **[KONTEKS]:**
    -   Saat meninjau Fase 1 (Task 1.3), ditemukan konflik arsitektur fundamental.
    -   `01-ARCHITECTURE.md` menempatkan `UIManager` di `Server/Core/`.
    -   Namun, `UIManager` secara logis **HARUS** beroperasi di `Client` untuk mengakses `StarterGui`, me-render `OVHL_UI`, dan melakukan _component discovery_.
    -   Modul `Client` (seperti `MusicPlayerUI`) tidak dapat memanggil `GetModule("UIManager")` jika modul tersebut berada di Server.
-   **[ALASAN]:**
    -   **Separation of Concerns:** Server tidak boleh dan tidak bisa mengelola _rendering state_ Client.
    -   **Logical Cohesion:** `UIManager` adalah _core infrastructure_ untuk **Client**, bukan Server.
    -   **Fixing Typo:** Ini mengoreksi _typo_ arsitektural di `01-ARCHITECTURE.md` (Decision #2.1 dan #22) dan menyelaraskannya dengan _intent_ sebenarnya dari Smart UI System.
-   **[PERUBAHAN FUNDAMENTAL]:**
    1.  Path kanonis untuk `UIManager` diubah menjadi `src/Client/Core/UIManager/`.
    2.  Semua referensi di dokumen lain (Roadmap, Arsitektur) harus disesuaikan.

### [2024-11-10] - Decision #22 - Core UI Manager & Smart Component Discovery

---

-   **[KEPUTUSAN]:** Implementasi Core UI Manager dengan AI-powered component discovery
-   **[KONTEKS]:**
    -   Modul mengalami complexity berulang dalam UI setup
    -   Perlu smart system yang handle UI complexity secara centralized
    -   Butuh AI-powered component discovery untuk multi-language support
    -   Inconsistency dalam UI implementation across modules
-   **[ALASAN]:**
    -   **Zero Boilerplate:** Modul hanya panggil 1 function untuk setup UI
    -   **Smart Discovery:** AI pattern matching untuk component detection
    -   **Multi-language Support:** Baca component names dalam English/Indonesian
    -   **Centralized Logic:** Semua UI complexity di handle core system
    -   **Better Error Messages:** Smart guidance untuk fix UI issues
-   **[PERUBAHAN FUNDAMENTAL]:**
    1.  Tambah `Server/Core/UIManager/` sebagai core module
    2.  Modul tidak perlu handle UI implementation details
    3.  Simplified module config - hanya specify expectations
    4.  AI-powered component classification dengan type validation

#### ARCHITECTURE IMPACT:

-   **Module Development:** Simplified - hanya specify UI mode & component expectations
-   **Kernel:** Load UIManager sebagai core module
-   **Module Contracts:** Changed - UI setup via UIManager, bukan manual implementation

---

### [2025-11-10] - Decision #21 - Standardized Module Interfaces

-   **[KEPUTUSAN]:** Modul wajib implement well-known functions untuk auto-discovery
-   **[KONTEKS]:** Butuh standardized way untuk systems auto-discover module capabilities
-   **[ALASAN]:**
    -   **Auto-Discovery:** Systems bisa automatically discover module capabilities
    -   **Future Proof:** Bisa tambah systems baru tanpa breaking changes
    -   **Tooling Support:** AI dan tools bisa analyze module capabilities
    -   **Documentation:** Self-documenting module interfaces
-   **[PERUBAHAN]:**
    -   Introduce `GetNetworkEvents()`, `GetDependencies()`, `GetAPIs()`
    -   Enable future extensions tanpa breaking changes

---

### [2024-11-10] - Decision #20 - Clean Separation - Business Logic vs UI Components

-   **[KEPUTUSAN]:** Pisahkan clean antara business logic UI dan pure UI components
-   **[KONTEKS]:** Architecture violation of separation of concerns di desain sebelumnya
-   **[ALASAN]:**
    -   **Clean Architecture:** Business logic ≠ Rendering logic
    -   **Max Reusability:** OVHL_UI components bisa dipakai semua business modul
    -   **Better Organization:** MusicPlayerUI fokus music business, OVHL_UI fokus rendering
-   **[PERUBAHAN]:**
    1.  Rename `UIModule` → `MusicPlayerUI` (business logic)
    2.  `OVHL_UI` tetap sebagai pure UI component library
    3.  Business modules compose UI components sesuai need

---

### [2024-11-10] - Decision #19 - Fully Modular Architecture & Auto-Discovery

-   **[KEPUTUSAN]:** Implementasi zero-configuration modular architecture dengan auto-discovery
-   **[KONTEKS]:**
    -   Manual registry menyebabkan tight coupling
    -   Modul baru harus configure multiple places
    -   Tidak mencapai goal "drag and drop" modularity
-   **[ALASAN]:**
    -   **True Modularity:** Modul fully self-contained
    -   **Zero Configuration:** Drop folder, automatically work
    -   **Auto-Discovery:** Kernel dan Network system smart detect modul
    -   **Future Proof:** System scalable tanpa modification existing code
-   **[PERUBAHAN]:**
    1.  Network system auto-discover events dari modul
    2.  Kernel enhanced untuk better module discovery
    3.  Hapus semua manual registry patterns
    4.  Standardized module communication via Kernel APIs

---

### [2024-11-10] - Decision #18 - Naming Convention & File Structure Standard

-   **[KEPUTUSAN]:** Standarisasi naming convention dan file structure across semua project
-   **[KONTEKS]:**
    -   Ditemukan inkonsistensi naming (manifest.lua vs Config.lua vs OVHL_UI)
    -   Struktur Shared folder tidak jelas
    -   Perlu standard yang konsisten untuk maintainability
-   **[ALASAN]:**
    -   **Consistency:** Semua developer dan AI pake standard yang sama
    -   **Readability:** Code lebih mudah dibaca dan dipahami
    -   **Maintenance:** Perubahan lebih mudah dan predictable
-   **[STANDARD BARU]:**

#### 🏷️ NAMING CONVENTION:

1.  **Files:** `snake_case.lua` (manifest.lua, config.lua, music_module.lua)
2.  **Folders:** `PascalCase` (Logger, OVHL_UI, MusicModule)
3.  **Variables/Functions:** `camelCase` (getModule, createButton, currentSong)
4.  **Constants:** `UPPER_SNAKE_CASE` (MAX_PLAYERS, DEFAULT_VOLUME)

#### 📁 FILE STRUCTURE:

1.  **Config:** Hanya di `Server/config.lua` untuk global settings
2.  **Modul Config:** `Module/config.lua` untuk config internal modul
3.  **Manifest:** Hanya untuk modul yang punya internal complexity

#### 🔧 CONFIG MANAGEMENT:

-   **Global:** `Server/config.lua` → App-level settings
-   **Modul:** `Module/config.lua` → Module-specific settings
-   **Shared:** Independent modules (tidak tergantung global config)

---

### [2024-11-10] - Decision #17 - Modular Configuration & Self-Contained Modules

-   **[KEPUTUSAN]:** Setiap modul wajib self-contained dengan config internal sendiri
-   **[KONTEKS]:**
    -   Modul butuh config spesifik (debug levels, UI modes, feature flags)
    -   Tidak sustainable bergantung pada global config saja
    -   Perlu isolation dan independence antar modul
-   **[ALASAN]:**
    -   **Independence:** Modul bisa develop dan test independently
    -   **Config Scoping:** Setting yang relevan hanya untuk modul tersebut
    -   **Flexibility:** Bisa disable/enable fitur per modul
    -   **Maintenance:** Gak perlu edit global config untuk perubahan modul
-   **[IMPLEMENTASI]:**

#### CONFIG STRUCTURE:

```lua
-- MusicModule/config.lua
return {
    debug = {
        log_level = "INFO",  -- "DEBUG" | "INFO" | "ERROR"
        enable_perf_logs = false
    },
    ui = {
        mode = "OVHL_UI",    -- "OVHL_UI" | "StarterGui"
        screen_gui_name = "MusicPanel",
        components = { ... }
    },
    features = {
        enable_song_requests = true,
        enable_auto_dj = true
    }
}
```

#### MODULE INIT FLOW:

1.  Kernel load `manifest.lua`
2.  Manifest require `config.lua` internal
3.  Manifest inject config ke controllers & services
4.  Module initialize dengan config sendiri

---

### [2024-11-10] - Decision #16 - Naming Convention & File Structure Standardization

-   **[KEPUTUSAN]:** Standarisasi naming convention dan file structure across semua project
-   **[KONTEKS]:**
    -   Ditemukan inkonsistensi naming (manifest.lua vs Config.lua vs OVHL_UI)
    -   Struktur Shared folder tidak jelas
    -   Perlu standard yang konsisten untuk maintainability
-   **[ALASAN]:**
    -   **Consistency:** Semua developer dan AI pake standard yang sama
    -   **Readability:** Code lebih mudah dibaca dan dipahami
    -   **Maintenance:** Perubahan lebih mudah dan predictable
-   **[STANDARD BARU]:**

#### 🏷️ NAMING CONVENTION:

1.  **Files:** `snake_case.lua` (manifest.lua, config.lua, music_module.lua)
2.  **Folders:** `PascalCase` (Logger, OVHL_UI, MusicModule)
3.  **Variables/Functions:** `camelCase` (getModule, createButton, currentSong)
4.  **Constants:** `UPPER_SNAKE_CASE` (MAX_PLAYERS, DEFAULT_VOLUME)

#### 📁 FILE STRUCTURE:

1.  **Config:** Hanya di `Server/config.lua` untuk global settings
2.  **Modul Config:** `Module/config.lua` untuk config internal modul
3.  **Manifest:** Hanya untuk modul yang punya internal complexity

#### 🔧 CONFIG MANAGEMENT:

-   **Global:** `Server/config.lua` → App-level settings
-   **Modul:** `Module/config.lua` → Module-specific settings
-   **Shared:** Independent modules (tidak tergantung global config)

---

### [2024-11-10] - Decision #15 - Hybrid UI Rendering System

-   **[KEPUTUSAN]:** Implementasi dual UI strategy - OVHL_UI Engine ATAU StarterGui Manual Components
-   **[KONTEKS]:**
    -   Butuh fleksibilitas untuk dev customize UI tanpa modify code
    -   AI-generated UI mungkin tidak selalu perfect untuk semua use case
    -   Perlu bridge antara data-driven system dan manual UI design
-   **[ALASAN]:**
    -   **Development Speed:** Rapid prototyping dengan StarterGui
    -   **Customization:** Dev bisa design UI visually di Studio
    -   **Fallback:** Jika AI UI kurang bagus, bisa switch ke manual
    -   **Progressive:** Bisa mulai manual, migrate ke AI UI later
-   **[SUPERSEDED BY DECISION #22]:**
    -   Approach ini digantikan oleh Core UIManager yang lebih comprehensive
    -   UIManager handle hybrid logic secara centralized

---

### [2024-11-10] - Decision #11.1 - OVHL UI Design System Specification

-   **[KEPUTUSAN]:** Standardisasi lengkap OVHL UI Design System dengan modern Roblox UI features
-   **[KONTEKS]:**
    -   Perlu konsistensi visual across semua modul UI
    -   Roblox telah release UI system modern (Flex, Grid, Aspect Ratio)
    -   Butuh responsive system yang works across semua device
-   **[ALASAN]:**
    -   **Visual Consistency:** Semua modul pakai design system yang sama
    -   **Modern Features:** Leverage Flex/Grid system untuk responsive layouts
    -   **Maintainability:** Centralized design system mudah di-update
    -   **Developer Experience:** Clear guidelines untuk AI dan manual development
-   **[SPECIFICATION]:**

#### 🎨 COLOR SYSTEM:

```lua
COLORS = {
    PRIMARY = Color3.fromHex("#F11D7A"),    -- Pink neon (brand)
    SECONDARY = Color3.fromHex("#472275"),  -- Purple deep (brand)
    BACKGROUND = Color3.fromHex("#000000"), -- Hitam solid
    GLASS = Color3.fromHex("#1A1A1A"),      -- Glassmorphism base
    GLASS_ACCENT = Color3.fromHex("#2A2A2A"),
    TEXT_WHITE = Color3.fromHex("#FFFFFF"),
    TEXT_GRAY = Color3.fromHex("#CCCCCC"),
    TEXT_DISABLED = Color3.fromHex("#888888"),
    HOVER = Color3.fromHex("#333333"),
    PRESSED = Color3.fromHex("#444444"),
    SUCCESS = Color3.fromHex("#00FF88"),
    ERROR = Color3.fromHex("#FF4444")
}
```

#### 🖋️ TYPOGRAPHY SYSTEM:

```lua
TYPOGRAPHY = {
    HEADING = {Font = Enum.Font.GothamBold, Size = 24, LineHeight = 1.2},
    SUBHEADING = {Font = Enum.Font.GothamBold, Size = 18, LineHeight = 1.3},
    BODY = {Font = Enum.Font.Gotham, Size = 14, LineHeight = 1.4},
    BUTTON = {Font = Enum.Font.GothamBold, Size = 16, LineHeight = 1.1},
    CAPTION = {Font = Enum.Font.Gotham, Size = 12, LineHeight = 1.2}
}
```

#### 📐 LAYOUT & SPACING:

```lua
SPACING = {
    XS = UDim.new(0, 4),   -- 4px
    SM = UDim.new(0, 8),   -- 8px
    MD = UDim.new(0, 16),  -- 16px
    LG = UDim.new(0, 24),  -- 24px
    XL = UDim.new(0, 32)   -- 32px
}

CORNER_RADIUS = {
    SM = UDim.new(0, 4),   -- 4px radius
    MD = UDim.new(0, 8),   -- 8px radius
    LG = UDim.new(0, 12),  -- 12px radius
    XL = UDim.new(0, 16)   -- 16px radius
}
```

#### 🔧 MODERN LAYOUT SYSTEMS:

1.  **FLEX CONTAINERS:** UIFlexItem dengan FlexMode (Fill/Grow/Shrink/Custom)
2.  **GRID LAYOUTS:** UIGridLayout dengan CellPadding & FillDirectionMaxCells
3.  **ASPECT RATIO:** UIAspectRatioConstraint untuk consistent proportions
4.  **TEXT SCALING:** UITextSizeConstraint + TextTruncate.AtEnd untuk readability

#### 🎭 INTERACTION PATTERNS:

-   **Hover:** Background color change + subtle scale animation
-   **Pressed:** Color darken + scale down slightly
-   **Disabled:** Reduced opacity + gray color
-   **Transitions:** TweenService untuk smooth animations
-   **Sound Effects:** Click sounds untuk feedback audio

#### 📱 RESPONSIVE BEHAVIOR:

-   **Mobile First:** Design untuk mobile, enhance untuk desktop
-   **Flexible Layouts:** UIFlexItem untuk adaptive sizing
-   **Safe Areas:** Handle different screen ratios and notches
-   **Text Scaling:** Auto-adjust text size berdasarkan container size

---

> END OF DOCUMENT ADR LOG
