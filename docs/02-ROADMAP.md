## 🗺️ 02 - ROADMAP (V2.1.0 - Smart UI System)

**Versi:** 2.1.0 (Smart UI System)  
**Status:** FINAL  
**Tujuan:** Rencana _end-to-end_ dari folder kosong (`src/`) hingga game siap _publish_, berdasarkan `01-ARCHITECTURE.md` (V2.1.0) dengan **Smart UI System**.

---

## 📋 PERUBAHAN V2.1.0:

-   ✅ **Enhanced:** Smart UI System dengan AI-powered component discovery
-   ✅ **Fixed:** UIManager path consistency (`Server/Core/UIManager/`)
-   ✅ **Proven:** Kernel 4-Fase dengan domain priority battle tested
-   ✅ **Simplified:** Module development dengan zero boilerplate UI
-   ✅ **Future Proof:** Standardized interfaces untuk auto-discovery

---

### Fase 1: 🏗️ Foundation & Kernel Bootstrap (Priority #1)

**Tujuan:** Membangun "sistem operasi" proyek. Memastikan struktur file, Kernel, Logger, dan **Smart UI Manager** berjalan sempurna sebelum ada 1 baris kode _gameplay_ pun.

1.  **Task 1.1: Project Scaffolding (Domain Ready)**

    -   Gunakan `default.project.json` (PROVEN) untuk mapping 3 _entrypoint_: `src/Server`, `src/Shared`, `src/Client`
    -   Buat struktur folder sesuai `Decision #2.1`:
        -   **Server:** `Core/`, `Services/`, `OVHL_Modules/`
        -   **Client:** `Core/`, `Services/`, `OVHL_Modules/`
        -   **Shared:** `Logger/`, `Network/`, `OVHL_UI/`
    -   **PENTING:** Buat `src/Server/config.lua` (Global) dan `src/Server/init.server.lua` (Bootstrap Script)

2.  **Task 1.2: Implementasi Kernel 4-Fase (Anti-Crash)**

    -   Implementasi `src/Server/init.server.lua` (Bootstrap `Phase 0` - **Script**)
    -   Implementasi `src/Client/init.client.lua` (Bootstrap `Phase 0` - **LocalScript**)
    -   Implementasi `src/Server/Core/Kernel/manifest.lua` (Kernel Loader `Phase 1-3` - **ModuleScript**)
    -   Implementasi `src/Client/Core/Kernel/manifest.lua` (Kernel Loader `Phase 1-3` - **ModuleScript**)
    -   **PENTING:** `init.server.lua` **WAJIB** `require` Config dan Logger, lalu `Logger:Init(Config)` _sebelum_ `require` Kernel (sesuai `Decision #1.1`)
    -   **PENTING:** `Kernel/manifest.lua` **WAJIB** mengimplementasikan `DOMAIN_PRIORITY` (`Core` → `Services` → `OVHL_Modules`) untuk `Phase 2` dan `Phase 3` (sesuai `Decision #1.2`)

3.  **Task 1.3: Core Modules Implementation**

    -   Implementasi `Shared/Logger/manifest.lua` (menggunakan standardized naming)
    -   Implementasi `Server/config.lua` (global configuration)
    -   Implementasi `Shared/config.lua` (shared configuration)
    -   🆕 **Implementasi `Client/Core/UIManager/manifest.lua`** (SMART UI SYSTEM!)

4.  **Task 1.4: Smart UI System Validation**
    -   Buat modul _dummy_ `Client/OVHL_Modules/TestUI/` dengan struktur lengkap
    -   Test `UIManager:SetupModuleUI()` dengan kedua mode (`OVHL_UI` & `StarterGui`)
    -   Test AI-powered component discovery & multi-language pattern matching
    -   Test smart error messages untuk missing components
    -   **Kriteria Sukses:** Semua component terdeteksi, smart error messages work, zero boilerplate di module

---

### Fase 2: 🎵 Music Business Logic (Priority #2)

**Tujuan:** Implement music gameplay loop dengan **simplified UI approach**. Menghubungkan _backend_ (Server) dan _frontend_ (Client) untuk pertama kalinya.

1.  **Task 2.1: Network System dengan Auto-Discovery**

    -   Implementasi `Shared/Network/manifest.lua` dengan auto-event registry
    -   Implementasi `GetNetworkEvents()` auto-discovery pattern
    -   Test network event registration tanpa manual config

2.  **Task 2.2: Music Module (Server) - PURE BUSINESS LOGIC**

    -   Implementasi `Server/OVHL_Modules/MusicModule/` (struktur lengkap)
    -   Focus on business logic: AutoDJ, Queue management (TANPA UI complexity)
    -   Expose network events via `GetNetworkEvents()`
    -   **PENTING:** Module **DILARANG** handle UI implementation

3.  **Task 2.3: Music Player UI (Client) - SIMPLIFIED UI**

    -   Implementasi `Client/OVHL_Modules/MusicPlayerUI/` (struktur lengkap)
    -   🆕 **Gunakan `UIManager:SetupModuleUI()`** untuk UI setup (1 function call!)
    -   Simple config: hanya specify UI mode & component expectations
    -   Business logic only - no UI implementation details
    -   Handle network events untuk update UI via UIManager

4.  **Task 2.4: Integration & Validation**
    -   Test music playback → UI update flow
    -   Test kedua UI modes: OVHL_UI & StarterGui
    -   Validate smart component discovery bekerja untuk kedua mode
    -   **Kriteria Sukses:** Music play → Smart UI update working both modes tanpa error, zero manual UI code

---

### Fase 3: 🎨 UI Components & Design System (Priority #3)

**Tujuan:** Enhance UI system dengan comprehensive components dan design system berdasarkan **ADR Decision #11.1**.

1.  **Task 3.1: OVHL_UI Component Library**

    -   Implementasi `Shared/OVHL_UI/manifest.lua` sebagai design system entrypoint
    -   Implementasi comprehensive UI components:
        -   `ModalSystem/` - `small_modal.lua`, `big_modal.lua`
        -   `LayoutSystem/` - `flex.lua`, `grid.lua`
        -   `ContentComponents/` - `card.lua`, `list.lua`
        -   `FormComponents/` - `button.lua`, `slider.lua`, `toggle.lua`
    -   Apply design system (Colors, Typography, Layout) sesuai `ADR Decision #11.1`
    -   Pastikan semua components work dengan UIManager discovery

2.  **Task 3.2: Advanced UI Patterns**

    -   Implementasi modal system dengan animation menggunakan TweenService
    -   Implementasi responsive layout components dengan UIFlexItem & UIGridLayout
    -   Implementasi form components dengan hover/pressed states
    -   Tambah sound effects untuk interaction feedback

3.  **Task 3.3: StarterGui Integration Enhancement**
    -   Extend component registry dengan lebih banyak multi-language patterns
    -   Add advanced type validation untuk component matching
    -   Improve error messages dan guidance untuk UI setup
    -   **Kriteria Sukses:** Components reusable, design consistent, works dengan kedua rendering modes

---

### Fase 4: 💾 Data & Persistence (Priority #4)

**Tujuan:** Mengembangkan _experience_ dari "1 ruangan" menjadi "multi-zona" dan membuat dunia persisten (menyimpan data player).

1.  **Task 4.1: Data Module Service**

    -   Implementasi `Server/Services/DataModule/` (struktur lengkap)
    -   DataStore wrapper dengan comprehensive error handling
    -   Implementasi player persistence untuk zones & preferences
    -   Anti-race condition logic sesuai `Decision #10.2`

2.  **Task 4.2: Zone System**

    -   Implementasi `Server/OVHL_Modules/ZoneModule/` (struktur lengkap)
    -   Zone scanner berdasarkan Atribut `Zone_ID` di `Workspace`
    -   Spatial audio system berdasarkan Atribut `Audio_Side`
    -   Zone persistence & auto-teleport pada player join

3.  **Task 4.3: Permission System**
    -   Implementasi `Server/Core/PermissionSync/` (struktur lengkap)
    -   Role-based access control system
    -   Fallback system untuk Kohl's Admin
    -   Integration dengan MusicModule untuk admin commands

---

### Fase 5: 🎮 Gameplay Features & Polish (Priority #5)

**Tujuan:** Implement remaining gameplay features dan polish.

1.  **Task 5.1: World UI System**

    -   Implementasi `Client/OVHL_Modules/WorldUIModule/` (struktur lengkap)
    -   LED display system untuk "Now Playing" (cari `SurfaceGui` berdasarkan Atribut)
    -   Queue rotation system untuk "Kirim Salam" (tampilkan 10d, kembali ke Now Playing)
    -   Text filtering & moderation menggunakan `TextFilterModule`

2.  **Task 5.2: Monetization System**

    -   Implementasi `Server/Services/MonetizationModule/` (struktur lengkap)
    -   Gamepass & product integration menggunakan `MarketplaceService`
    -   Implementasi "Beli dulu baru tulis" workflow untuk Kirim Salam
    -   Integration dengan MusicModule untuk paid song requests

3.  **Task 5.3: Performance & Optimization**
    -   Memory management & cleanup procedures
    -   Performance monitoring dan logging
    -   Error handling enhancement untuk production
    -   **Kriteria Sukses:** Semua gameplay features working, monetization integrated, performance optimized

---

### Fase 6: 🚀 Production Ready & Deployment (Priority #6)

**Tujuan:** Final testing, optimization, dan deployment.

1.  **Task 6.1: Comprehensive Testing**

    -   End-to-end testing semua features
    -   Stress testing dengan multiple players
    -   Edge case handling dan error recovery testing

2.  **Task 6.2: Performance Optimization**

    -   Memory leak detection & fixing
    -   Network optimization untuk mengurangi bandwidth
    -   Load time optimization untuk better user experience

3.  **Task 6.3: Deployment & Monitoring**
    -   Production config setup (`debug.global_log_level = "INFO"`)
    -   Analytics & monitoring integration
    -   Documentation finalization dan knowledge transfer
    -   **Kriteria Sukses:** Production ready, performance optimized, semua systems operational

---

## 🎯 SUCCESS CRITERIA PER FASE:

-   **Fase 1:** Kernel boot + UIManager working + Smart component discovery validated
-   **Fase 2:** Music play → Smart UI update working both modes tanpa manual UI code
-   **Fase 3:** Comprehensive UI components + Enhanced StarterGui integration + Design system consistent
-   **Fase 4:** Player persistence working + Zone system operational + Permission system functional
-   **Fase 5:** All gameplay features working + Monetization integrated + Performance optimized
-   **Fase 6:** Production ready + Comprehensive testing passed + Deployment successful
