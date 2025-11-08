# 🗺️ 02 - ROADMAP (V1.0.0)

**Versi:** 1.0.0
**Status:** FINAL
**Tujuan:** Rencana _end-to-end_ dari folder kosong (`src/`) hingga game siap _publish_, berdasarkan `01-ARCHITECTURE.md` (V1.0.0) dan `00-GAME-DESIGN.md`.

---

### Fase 1: 🏗️ Fondasi & Kernel Bootstrap (Prioritas #1)

**Tujuan:** Membangun "sistem operasi" proyek. Memastikan struktur file, Kernel, dan _logger_ (prioritas #1) berjalan sempurna sebelum ada 1 baris kode _gameplay_ pun.

1.  **Task 1.1: Project Scaffolding (Domain Ready)**

    -   Gunakan `default.project.json` (yang sudah bersih) untuk memetakan 3 _entrypoint_ utama: `src/Server`, `src/Shared`, `src/Client`.
    -   Buat struktur folder kosong sesuai `Decision #2` (Domain Hierarchy):
    -   **Server:** Buat `Core/`, `Services/`, `OVHL_Modules/`, `Legacy/`.
    -   **Client:** Buat `Core/`, `Services/`, `OVHL_Modules/`.
    -   **Shared:** Buat `Logger/`, `Network/`, `OVHL_UI/`.
    -   **PENTING:** Buat `src/Server/Config.lua` (Global) dan `src/Server/init.server.lua` (Bootstrap).

2.  **Task 1.2: Implementasi Kernel 4-Fase (Anti-Crash)**

    -   Implementasi `src/Server/init.server.lua` (Bootstrap `Phase 0`).
    -   Implementasi `src/Client/init.client.lua` (Bootstrap `Phase 0`).
    -   Implementasi `src/Server/Core/Kernel.lua` (Kernel Loader `Phase 1-3`).
    -   Implementasi `src/Client/Core/Kernel.lua` (Kernel Loader `Phase 1-3`).
    -   **PENTING:** `init.server.lua` **WAJIB** `require` Config dan Logger, lalu `Logger:Init(Config)` _sebelum_ `require` Kernel (sesuai `Decision #1.1`).
    -   **PENTING:** `Kernel.lua` **WAJIB** mengimplementasikan `DOMAIN_PRIORITY` (`Core` -> `Services` -> `OVHL_Modules`) untuk `Phase 2` dan `Phase 3` (sesuai `Decision #1.2`).

3.  **Task 1.3: Implementasi Core Modules (Fase 1)**

    -   Implementasi `Shared/Logger/` (menggunakan Pola 5 File). `Logic.lua` akan berisi `ShouldLog()`, `init.lua` akan berisi `Info()`, `Debug()`, `Error()`.

4.  **Task 1.4: Validasi Kernel**
    -   Buat modul _dummy_ `Server/OVHL_Modules/TestModule/` (lengkap dengan 5 file: `init`, `Config`, `Controller/MainLogic`, `Services/Handlers`, `Services/State`).
    -   `init.lua`-nya hanya punya `Init()` yang isinya `Logger:Info("TestModule", "TEST", "TestModule Server Initialized!")`.
    -   **Kriteria Sukses:** Saat _play_ di Studio, _output_ harus nampilin log dari `Logger` (Phase 0) dan `TestModule` (Phase 3) tanpa ada _error_ `require`. Ini membuktikan Kernel 4-Fase berjalan.

---

### Fase 2: 🎨 UI Engine & Komponen (Prioritas #2)

**Tujuan:** Membangun `OVHL UI System` (prioritas #2). Di akhir fase ini, kita punya "Lego" UI yang siap dipakai, tapi belum ada _logic_ data. (Sesuai `Decision #10` & `#11`).

1.  **Task 2.1: Implementasi UI Kernel (`OVHL_UI`)**

    -   Buat `Shared/OVHL_UI/init.lua`. Ini adalah _entrypoint_ yang akan nge-link semua komponen UI via _discovery_ internal (sesuai `Decision #3.3`).
    -   Buat _base function_ `OVHLUI.Create()` untuk _styling_ konsisten berdasarkan `Filosofi UI Generation` (Decision #11).

2.  **Task 2.2: Implementasi Sistem Layout & Modal**

    -   Buat `Shared/OVHL_UI/ModalSystem/` (Modal, Dialog).
    -   Buat `Shared/OVHL_UI/LayoutSystem/` (Grid, Stack).

3.  **Task 2.3: Implementasi Komponen Inti**

    -   Buat `Shared/OVHL_UI/ContentComponents/` (Card, List).
    -   Buat `Shared/OVHL_UI/FormComponents/` (Button, Slider, Toggle).

4.  **Task 2.4: Validasi UI Engine**
    -   Gunakan kembali `Client/OVHL_Modules/TestModule/init.lua` dari Fase 1.
    -   Di `Init()`, panggil `Kernel:GetModule("OVHLUI")`.
    -   Bikin 1 `TextButton` manual, pas diklik, panggil `OVHLUI.ModalSystem:Open(...)`.
    -   **Kriteria Sukses:** Modal harus muncul. Di dalem modal itu, kita panggil `Stack`, `Card`, dan `Button` dari _engine_ kita. Semuanya harus tampil dengan _style_ (Color, Corner) dari `Decision #11.2` tanpa _error_.

---

### Fase 3: 🎧 Gameplay Loop Awal (Music & UI Logic)

**Tujuan:** Menghubungkan _backend_ (Server) dan _frontend_ (Client) untuk pertama kalinya. Membuat _vertical slice_ utama: Musik main dan UI merespon.

1.  **Task 3.1: Implementasi Network Foundation**

    -   Buat `Shared/Network/` (lengkap dengan `init.lua`, `Events.lua`, `Controller/RemoteWrapper.lua`) (sesuai `Decision #5`).
    -   Daftarkan _event_ awal di `Events.lua`: `UpdateUI`, `VoteToSkip`, `RequestSong`.

2.  **Task 3.2: Implementasi Permission (Aggregator)**

    -   Implementasi `Core/PermissionSync/` (lengkap dengan `init`, `Config`, `Controller/Logic_Kohl`, `Controller/Logic_OVHL`, `Services/Handlers`, `Services/State`) sesuai `Decision #9`.
    -   **PENTING:** `Logic_OVHL.lua` **WAJIB** `require` `MonetizationModule` (meskipun modulnya masih kosong) untuk cek Gamepass _fallback_.

3.  **Task 3.3: Implementasi Music Backend**

    -   Implementasi `Server/OVHL_Modules/MusicModule/` (struktur eskalasi: `init`, `Config`, `State`, `Handlers`, `Controller/AutoDJ`, `Controller/Queue`).
    -   `init.lua` **WAJIB** `GetModule("PermissionSync")` dan `GetModule("RemoteWrapper")`.
    -   `Controller/AutoDJ.lua` berisi _logic_ AutoDJ & Manual.
    -   `Services/Handlers.lua` **WAJIB** memanggil `RemoteWrapper:FireAllClients("UpdateUI", data)` tiap lagu ganti.
    -   Gunakan `Logger:Info()` dan `Logger:Debug()` (sesuai `Decision #6`).

4.  **Task 3.4: Implementasi Topbar & UI Frontend**

    -   _Install_ TopbarPlus V3 (sesuai `Decision #8`).
    -   Implementasi `Client/Services/TopbarIntegration/` (Pola 5 File).
    -   Implementasi `Client/OVHL_Modules/UIModule/` (struktur eskalasi: `init`, `Config`, `State`, `Handlers`, `Controller/NowPlayingPage`, `Controller/StageZonePage`).
    -   `Services/Handlers.lua` (di `UIModule`) dengerin `OnClientEvent("UpdateUI")`.
    -   `Controller/NowPlayingPage.lua` pake `OVHLUI` (dari Fase 2) untuk nampilin data lagu di tab "NOW PLAYING".
    -   Hubungkan klik ikon TopbarPlus (`TopbarIntegration/Services/Handlers.lua`) untuk memanggil `UIModule:ToggleMusicPanel()`.

5.  **Task 3.5: Validasi Loop**
    -   **Kriteria Sukses:** Player _join_. Lagu AutoDJ main. `UpdateUI` ke-tembak. Player klik ikon TopbarPlus. Modal `OVHLUI` muncul. Tab "NOW PLAYING" nampilin judul lagu yang bener.

---

### Fase 4: 💾 Zona, Dunia, & Persistence

**Tujuan:** Mengembangkan _experience_ dari "1 ruangan" menjadi "multi-zona" dan membuat dunia persisten (menyimpan data player).

1.  **Task 4.1: Implementasi DataStore Service**

    -   Buat `Server/Services/DataModule/` (Pola 5 File).
    -   `Controller/Logic.lua` berisi _wrapper_ `pcall` untuk `DataStoreService:GetAsync/SetAsync` dan _logic_ Anti-Race Condition (Decision #10.2).

2.  **Task 4.2: Implementasi Zone Backend & Persistence**

    -   Implementasi `Server/OVHL_Modules/ZoneModule/` (struktur eskalasi: `init`, `Config`, `State`, `Handlers`, `Controller/Scanner`, `Controller/Persistence`).
    -   `init.lua` **WAJIB** `GetModule("DataModule")`.
    -   `Controller/Scanner.lua` **WAJIB** memvalidasi Atribut (`Zone_ID`) di `Workspace` (sesuai `Decision #7`).
    -   `Services/Handlers.lua` (dengar `OnPlayerJoin`) akan memanggil `Controller/Persistence.lua` untuk `DataModule:GetLastZone(player)` -> Teleport player.
    -   `Services/Handlers.lua` (dengar `OnZoneChange`) akan memanggil `Controller/Persistence.lua` untuk `DataModule:SaveLastZone(player, newZone)`.

3.  **Task 4.3: Implementasi Zone Frontend**

    -   Implementasi `Client/OVHL_Modules/ZoneModule/` (Pola 5 File).
    -   Update `Client/OVHL_Modules/UIModule` (Fase 3) untuk nampilin tab "STAGE ZONE" yang datanya diambil dari `ZoneModule`.
    -   Buat `Client/Services/AudioModule` (Pola 5 File).
    -   `Client/OVHL_Modules/ZoneModule/Services/Handlers.lua` mendeteksi player masuk _part_ zona dan memanggil `AudioModule` untuk mengaktifkan _spatial audio_ (berdasarkan Atribut `Audio_Side`).

4.  **Task 4.4: Validasi Persistence & Contract**
    -   **Kriteria Sukses 1:** Builder taruh 2 _part_ di `Workspace` dan kasih Atribut `Zone_ID`. Kedua zona itu harus muncul di UI.
    -   **Kriteria Sukses 2:** Player _join_ (pertama kali), _spawn_ di "Zona Luar". Pindah ke "Zona Dangdut". _Leave_ game. _Rejoin_. Player harus langsung _spawn_ di "Zona Dangdut".

---

### Fase 5: 📺 Interaksi Dunia (LED & Kirim Salam)

**Tujuan:** Menghidupkan panggung dengan LED interaktif (Video Tron) dan mengimplementasikan fitur _social_ "Kirim Salam".

1.  **Task 5.1: Implementasi Text Filtering Service**

    -   Buat `Server/Services/TextFilterModule/` (Pola 5 File).
    -   `Controller/Logic.lua` berisi _wrapper_ aman untuk `TextService:FilterStringAsync()`.

2.  **Task 5.2: Implementasi World UI Frontend**

    -   Buat `Client/OVHL_Modules/WorldUIModule/` (struktur eskalasi).
    -   `Services/Handlers.lua` dengerin 2 _event_: `UpdateUI` (Now Playing) dan `UpdateSalam` (Kirim Salam).
    -   `Controller/QueueController.lua` berisi _logic_ **Queue Rotasi** (tampilkan Salam 10d, lalu kembali ke Now Playing).
    -   `Controller/Logic.lua` (lainnya) mencari `SurfaceGui` di `workspace` berdasarkan Atribut `UI_Type: "NowPlaying"` dan ganti `.Text`-nya.

3.  **Task 5.3: Implementasi Kirim Salam Backend**

    -   Daftarkan `RequestSalamPayment` dan `SubmitSalamText` di `Events.lua` (menggantikan `RequestSalam`).
    -   Buat `Server/OVHL_Modules/SalamModule/` (Pola 5 File).
    -   `Services/Handlers.lua` dengerin `OnServerEvent("SubmitSalamText")`.
    -   `Controller/Logic.lua` **WAJIB** `GetModule("TextFilterModule")` -> `TextFilter:Filter(text)` -> (Jika lolos) -> `RemoteWrapper:FireAllClients("UpdateSalam", filteredText)`.

4.  **Task 5.4: Validasi Interaksi**
    -   **Kriteria Sukses:** LED panggung nampilin "Now Playing". Player kirim salam. Teks di LED ganti jadi salam (yang udah disensor), nunggu 10 detik, terus balik lagi nampilin "Now Playing".

---

### Fase 6: 💰 Monetisasi & Rilis (Prioritas Terakhir)

**Tujuan:** Mengaktifkan _logic_ pembayaran untuk fitur-fitur premium dan mempersiapkan game untuk _publish_.

1.  **Task 6.1: Implementasi Monetization Service**

    -   Buat `Server/Services/MonetizationModule/` (Pola 5 File).
    -   `Controller/Logic.lua` berisi _wrapper_ untuk `MarketplaceService` (cek _gamepass_, _prompt_ pembelian).
    -   Fungsi utama: `CheckGamepass(player, "VIP_Access")`, `HandleSongRequestPayment(player)` dan `HandleSalamPayment(player)`.

2.  **Task 6.2: Update Config (Global)**

    -   Pastikan `Server/Config.lua` memiliki:
        ```lua
        Config.Monetization = {
            EnableSongRequests = false, -- Default false
            EnableKirimSalam = false    -- Default false
        }
        -- Pastikan Config.Debug.GlobalLogLevel sudah ada
        ```

3.  **Task 6.3: Integrasi Pembayaran (Song Request)**

    -   Update `Server/OVHL_Modules/MusicModule/`.
    -   Di `Services/Handlers.lua` (Handle `RequestSong`), tambahkan _logic_:
        1.  Cek _role_ via `PermissionSync:GetRole(player)`.
        2.  Jika bukan _role_ (bukan Admin/VIP), cek `Config.Monetization and Config.Monetization.EnableSongRequests` (Defensive Config).
        3.  Jika `true`, panggil `MonetizationModule:HandleSongRequestPayment(player)`. Baru panggil `Controller/Queue.lua` jika `true`.

4.  **Task 6.4: Integrasi Pembayaran (Kirim Salam)**

    -   Update `Server/OVHL_Modules/SalamModule/`.
    -   Implementasi _logic_ **"Beli Dulu Baru Tulis"** (sesuai Blueprint).
    -   `Services/Handlers.lua` akan:
        1.  Dengerin `OnServerEvent("RequestSalamPayment")`.
        2.  Panggil `MonetizationModule:HandleSalamPayment(player)` (atau di-bypass oleh `PermissionSync`).
        3.  Jika berhasil, `FireClient(player, "PaymentSuccessSalam")`.
        4.  Dengerin `OnServerEvent("SubmitSalamText")` -> Panggil `Controller/Logic.lua` (untuk filter & broadcast).

5.  **Task 6.5: Finalisasi & Deploy**
    -   _Testing_ end-to-end semua fitur.
    -   _Review_ semua _performance guideline_ (`Decision #10` - Memory Cleanup & Race Condition).
    -   Ubah `Server/Config.lua` -> `Debug.GlobalLogLevel = "INFO"` (sesuai `Decision #6`).
    -   **Kriteria Sukses:** Game siap _publish_.
