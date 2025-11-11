# 📔 05 - DEV LOG (Development Journal)

**Versi:** 2.1.0
**Status:** STABIL (Fase 2 Selesai)
**Tujuan:** Ini adalah jurnal progres harian proyek. File ini WAJIB diisi oleh Developer (Manusia) setiap kali selesai mengeksekusi _task_ dari AI. AI WAJIB membaca entri terakhir di file ini sebelum memulai _task_ baru.

**Log terbaru selalu di baris paling atas.**

---

### [2025-11-11] - Sesi 1: Fondasi (Fase 1) & Implementasi MusicModule (Fase 2)

-   **[STATUS]:** BERHASIL (Stabil)
-   **[FILE_CHANGES]:**

    -   `CREATED: (Seluruh struktur folder V2.1.0)`
    -   `CREATED: src/Server/init.server.lua` (Bootstrap)
    -   `CREATED: src/Client/init.client.lua` (Bootstrap)
    -   `MODIFIED: src/Server/config.lua` (Global Config - Log Level WARN)
    -   `MODIFIED: src/Shared/config.lua` (Shared Config - Log Level WARN)
    -   `MODIFIED: src/Shared/Logger/manifest.lua` (Implementasi Per-Module Log Level)
    -   `CREATED: src/Shared/OVHL_UI/manifest.lua` (Stub)
    -   `MODIFIED: src/Server/Core/Kernel/manifest.lua` (Implementasi Kernel 4-Fase + Hotfix Urutan Init + Registrasi Log Level)
    -   `MODIFIED: src/Client/Core/Kernel/manifest.lua` (Implementasi Kernel 4-Fase + Hotfix Urutan Init + Registrasi Log Level)
    -   `MODIFIED: src/Shared/Network/manifest.lua` (Implementasi Penuh Auto-Discovery)
    -   `CREATED: src/Client/Core/UIManager/config.lua` (Arsitektur V2 - Kamus Presisi 1-ke-1)
    -   `CREATED: src/Client/Core/UIManager/manifest.lua` (Arsitektur V2 - Logic Presisi 1-ke-1)
    -   `MODIFIED: src/Server/OVHL_Modules/MusicModule/config.lua` (Database Fallback + API URL + Log Level DEBUG)
    -   `CREATED: src/Server/OVHL_Modules/MusicModule/manifest.lua` (Manajer Bersih)
    -   `CREATED: src/Server/OVHL_Modules/MusicModule/Controller/playback_manager.lua` (Otak Backend)
    -   `CREATED: src/Server/OVHL_Modules/MusicModule/Services/api_fetcher.lua` (Logika API "Flatten")
    -   `CREATED: src/Server/OVHL_Modules/MusicModule/Services/network_handlers.lua` (Handler Event)
    -   `MODIFIED: src/Client/OVHL_Modules/MusicPlayerUI/config.lua` (Daftar Belanja 49 Komponen + Log Level DEBUG)
    -   `CREATED: src/Client/OVHL_Modules/MusicPlayerUI/manifest.lua` (Manajer Bersih)
    -   `CREATED: src/Client/OVHL_Modules/MusicPlayerUI/Controller/navigation_controller.lua` (Logika Navigasi)
    -   `CREATED: src/Client/OVHL_Modules/MusicPlayerUI/Controller/playback_controller.lua` (Logika Playback Client)
    -   `CREATED: src/Client/OVHL_Modules/MusicPlayerUI/Services/network_handlers.lua` (Handler Event Client)
    -   `CREATED: src/Client/OVHL_Modules/MusicPlayerUI/Services/ui_state.lua` (Koneksi Tombol)

-   **[ERROR_LOG]:** N/A (Semua _crash_ saat _booting_ telah diperbaiki).

-   **[SOLUSI/CATATAN (HISTORIS SESI INI)]:**

    1.  **Fase 1.1 - 1.3 (Fondasi):** Membangun seluruh _scaffolding_ V2.1.0 dari nol.
    2.  **Koreksi Arsitektur #1 (Kritis):** Memindahkan `UIManager` dari `Server/Core` (typo di dokumen awal) ke `Client/Core` (lokasi yang logis). Ini dicatat di `04-ADR-LOG.md`.
    3.  **Koreksi Arsitektur #2 (Kritis):** Memperbaiki urutan inisialisasi `Phase 3` di **Server** dan **Client Kernel**. Modul `Shared` (seperti `Network`) sekarang di-`Init()` **SEBELUM** `OVHL_Modules` (seperti `MusicModule` / `MusicPlayerUI`) yang membutuhkannya. Ini memperbaiki _crash_ dependensi di kedua sisi.
    4.  **Koreksi Arsitektur #3 (Kritis):** Mengganti total arsitektur `UIManager`. Membuang _logic_ "AI" (pencocokan nama parsial) yang "cerewet" dan menyebabkan _crash_. Menggantinya dengan **Arsitektur V2 (Presisi)**:
        -   `UIManager/config.lua` sekarang adalah "Kamus 1-ke-1" (`snake_case_key` -> `"PascalCaseName"`).
        -   `UIManager/manifest.lua` sekarang menggunakan `:FindFirstChild(namaAsli, true)` yang 100% presisi.
        -   `MusicPlayerUI/config.lua` adalah "Daftar Belanja" berisi 49 _key snake_case_.
    5.  **Hasil UIManager:** `[INFO] [UIManager] [VALIDATION] Semua 49 expected components berhasil ditemukan dan divalidasi.` **SUKSES.**
    6.  **Koreksi Arsitektur #4 (Network):** Menambahkan `GetNetworkEvents()` ke `MusicPlayerUI` (Client) agar `Network` (Client) tahu _event_ apa yang harus didengarkan dari Server, memperbaiki _warning_ `event yang tidak terdaftar`.
    7.  **Koreksi Arsitektur #5 (Arsitektur Bersih):** Memindahkan semua _stub logic_ dari `manifest.lua` ke file `Controller/` dan `Services/` yang sesuai (sesuai `Decision #3.1`). Ini memperbaiki _bug_ "kerja 2x".
    8.  **Koreksi Arsitektur #6 (API Fetcher):** Meng-upgrade `api_fetcher.lua` untuk menangani _dictionary_ JSON bersarang dari Google Sheets API, "meratakannya" (`flatten`) menjadi satu _database_ lagu, dan menyuntikkan data `Genre` / `SubGenre` ke dalam setiap lagu.
    9.  **Fase 2.1 (Network):** Mengimplementasikan `Network/manifest.lua` dengan _auto-discovery_ penuh (`GetNetworkEvents()`).
    10. **Fase 2.2 & 2.3 (Music):** Mengimplementasikan _logic_ `MusicModule` (Server) dan `MusicPlayerUI` (Client) dengan arsitektur bersih (`Controller`/`Services`).
    11. **Fase 2.4 (Playback):** Berhasil mengimplementasikan _logic_ _playback_ _end-to-end_. Server memanggil API, memuat 26 lagu, memulai `AutoDJ`, memutar `Sound` di `Workspace`, dan mengirim _event_ `MusicSync`. Client menerima _event_, memutar `Sound` secara lokal, dan melakukan sinkronisasi `TimePosition`. **AUDIO TERDENGAR.**
    12. **Fitur Logging (Granular):** Meng-upgrade `Logger` dan `Kernel` untuk mendukung **Per-Module Log Level**. Modul stabil (Kernel, Network, UIManager) sekarang "diam" (menggunakan global `WARN`), sementara modul aktif (MusicModule, MusicPlayerUI) "berisik" (menggunakan `DEBUG`).
    13. **Hasil Sistem:** Server dan Client sekarang _boot_ dengan stabil tanpa _error_.

-   **[DISKUSI LOGIKA ADR MUSIC PANEL (V4) (PENTING!)]:**

    -   **Visi Inti:** Visi `00-GAME-DESIGN.md` (Zonasi, World UI, Kirim Salam) di-**MERGER** dengan `adr-music-player.md` (Smart UI).
    -   **Arsitektur UI (V4):** Menggunakan "Reusable View".
        -   `NowPlayingPage` (Visible: true) adalah tampilan _default_.
        -   `Page` (Visible: false) adalah kontainer _default_ untuk halaman lain.
        -   `Page` berisi `BannerFrame` (Tunggal) dan `ContentFrame` (Dinamis).
        -   `ContentFrame` berisi semua halaman lain (`LibraryPage`, `SongListPage`, `RequestPage`, `ShoutOutPage`, `LoadingPage`).
        -   `SongListPage` akan digunakan ulang (reusable) untuk menampilkan hasil _Search_, _Genre_, dan _Favorites_.
    -   **Logika Data (V4):**
        -   `MusicModule` akan mencoba `API JSON` (Prioritas 1).
        -   Jika gagal, akan menggunakan `fallbackDatabase` dari `MusicModule/config.lua` (Prioritas 2).
    -   **Skema Data (V4):** `ASET ID`, `JUDUL LAGU`, `ARTIS`, `GENRE`, `SUB GENRE`, `PLACEMENT`, `ART IMAGE ID`. (Skema ini 100% cocok dengan API).
    -   **Data Binding (V4):**
        -   `now_playing_title` (TextLabel) <- `JUDUL LAGU`.
        -   `now_playing_artist` (TextLabel) <- `"GENRE - SUB GENRE - PLACEMENT"`.
    -   **Logika Playback (V4):** Tiga Prioritas: **Manual Play** (Admin `PlayNowButton`) > **Antrian** (`AddToQueueButton`) > **AutoDJ** (Fallback).
    -   **Logika Navigasi (V4):**
        -   UI dipanggil via tombol `TopbarPlus` (Eksternal).
        -   Tampilan _default_ saat terbuka adalah `NowPlayingPage`.
        -   Player menavigasi ke halaman lain via `FooterMenu` atau `MenuPopup`.
    -   **Logika Fitur & Permission (V4) (Kritis):**
        -   **Volume:** 100% Lokal (Client-side). `PermissionSync` tidak dilibatkan.
        -   **Vote-to-Skip:** 51% (dikonfigurasi di `Server/config.lua`).
        -   **Zonasi (DITUNDA):** Fitur `ZoneModule` (Task 4.2) ditunda. `LibraryPage` untuk sementara akan berfungsi sebagai pemilih _playlist_ global.
        -   **Monetisasi & Permission (Granular):**
            -   `PermissionSync` akan mengecek semua aksi (Request, ShoutOut, PlayNow).
            -   **Kreator:** Me-bypass semua _check_ (pembayaran & _permission_).
            -   **VIP:** Bisa menggunakan fitur dasar (misal: `ShoutOutPage`), tapi **TIDAK BISA** menggunakan `RequestPage` (via Asset ID).
            -   **VVIP / Bayar per Aksi:** Bisa menggunakan `RequestPage` (via Asset ID).
            -   **Player Biasa:** Tidak bisa menggunakan fitur berbayar tanpa transaksi.

-   **[NEXT STEP (YANG AKAN DATANG)]:**
    1.  **Fase 2 (Navigasi):** Implementasi _logic_ navigasi penuh di `Client/MusicPlayerUI/Services/ui_state.lua` (mengisi `MenuPopup`, menghubungkan `BackButton`, `SearchButton`, dll).
    2.  **Fase 2 (Data Binding Penuh):** Memperbarui `playback_controller.lua` (Client) untuk mengikat sisa data (`AlbumArt`, `TimePosition` _slider_).
    3.  **Fase 2 (Fitur):** Implementasi _logic_ `VoteToSkip`, `ShoutOutPage`, dan `RequestPage` (saat ini hanya _stub_).
    4.  **Fase 3 (UI):** Mengganti _stub_ `OVHL_UI` dengan implementasi _design system_ penuh.
    5.  **Fase 4 (Core):** Implementasi `Server/Services/DataModule` dan `Server/Core/PermissionSync` (yang saat ini `nil` dan menyebabkan `[WARN]`).
    6.  **Fase 5 (World UI):** Implementasi `WorldUIModule` (Pilar 1) untuk menampilkan `NOW PLAYING` di LED panggung.
