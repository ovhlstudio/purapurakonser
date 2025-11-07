# 🗺️ 04 - ROADMAP (V2 - FROM SCRATCH)

**Tujuan:** Rencana _end-to-end_ dari folder kosong (`src/`) hingga game siap _publish_, berdasarkan `01-ADR-FINAL.md` dan `00-Blueprint-AI-Context.md`.

---

### Fase 1: 🏗️ Fondasi & Kernel Bootstrap (Prioritas #1)

**Tujuan:** Membangun "sistem operasi" proyek. Memastikan struktur file, Kernel, dan _logger_ (prioritas #1) berjalan sempurna sebelum ada 1 baris kode _gameplay_ pun.

1.  **Task 1.1: Project Scaffolding**

    -   Buat `default.project.json` (Rojo).
    -   Petakan 3 _entrypoint_ utama: `src/Server` (ServerScriptService), `src/Shared` (ReplicatedStorage), `src/Client` (StarterPlayerScripts).
    -   Buat _semua_ struktur folder kosong sesuai `FILE STRUCTURE REFERENCE` di `01-ADR-FINAL.md`. (Misal: `Server/MusicModule`, `Client/UIModule`, `Shared/Network`, `Shared/OVHL_UI/ModalSystem`, dll).

2.  **Task 1.2: Implementasi 3-Phase Kernel (Bootstrap)**

    -   Implementasi `src/Server/init.lua` (Server Kernel).
    -   Implementasi `src/Client/init.lua` (Client Kernel).
    -   Implementasi `src/Shared/init.lua` (Shared Kernel).
    -   _Pola:_ Semua Kernel harus mengikuti pola 3-Phase Load (Phase 1: Core, Phase 2: Auto-Discovery, Phase 3: Init).

3.  **Task 1.3: Implementasi Core Modules (Phase 1 Load)**

    -   **Server:** Buat `Logger.lua` (dengan fix V4.1) dan `Config.lua`.
    -   **Client:** Buat `Logger.lua` dan `Responsive.lua`.
    -   **Shared:** Buat `Theme.lua`.

4.  **Task 1.4: Validasi Kernel**
    -   Buat modul _dummy_ `Server/TestModule/init.lua` dan `Client/TestModule/init.lua`.
    -   Masing-masing modul cuma punya `Init()` yang isinya `print("[TestModule] Server/Client Initialized!")`.
    -   **Kriteria Sukses:** Saat _play_ di Studio, _output_ (Server & Client) harus nampilin _print_ dari _logger_ (Phase 1) dan _TestModule_ (Phase 3) tanpa ada _error_ `require`.

---

### Fase 2: 🎨 UI Engine & Komponen (Prioritas #2)

**Tujuan:** Membangun `OVHL UI System` (prioritas #2). Di akhir fase ini, kita punya "Lego" UI yang siap dipakai, tapi belum ada _logic_ data.

1.  **Task 2.1: Implementasi UI Kernel (`OVHL_UI`)**

    -   Buat `Shared/OVHL_UI/init.lua`. Ini adalah _entrypoint_ yang akan nge-link semua komponen UI via _discovery_.
    -   Buat _base function_ `OVHLUI.Create()` untuk _styling_ konsisten.

2.  **Task 2.2: Implementasi Sistem Layout**

    -   Buat `Shared/OVHL_UI/ModalSystem/` (Modal, Dialog).
    -   Buat `Shared/OVHL_UI/LayoutSystem/` (Grid, Stack).

3.  **Task 2.3: Implementasi Komponen Inti**

    -   Buat `Shared/OVHL_UI/ContentComponents/` (Card, List).
    -   Buat `Shared/OVHL_UI/FormComponents/` (Button, Slider, Toggle).

4.  **Task 2.4: Validasi UI Engine**
    -   Gunakan kembali `Client/TestModule/init.lua` dari Fase 1.
    -   Di `Init()`, panggil `Kernel:GetModule("OVHLUI")`.
    -   Bikin 1 `TextButton` manual, pas diklik, panggil `OVHLUI.ModalSystem:Open(...)`.
    -   **Kriteria Sukses:** Modal harus muncul. Di dalem modal itu, kita panggil `Stack`, `Card`, dan `Button` dari _engine_ kita. Semuanya harus tampil dengan _style_ dari `Theme.lua` tanpa _error_.

---

### Fase 3: 🎧 Gameplay Loop Awal (Music & UI Logic)

**Tujuan:** Menghubungkan _backend_ (Server) dan _frontend_ (Client) untuk pertama kalinya. Membuat _vertical slice_ utama: Musik main dan UI merespon.

1.  **Task 3.1: Implementasi Network Foundation**

    -   Buat `Shared/Network/init.lua`, `Events.lua`, dan `RemoteWrapper.lua`.
    -   Daftarkan _event_ awal di `Events.lua`: `UpdateUI`, `VoteToSkip`, `RequestSong`.

2.  **Task 3.2: Implementasi Permission (Bypass-Only)**

    -   _Install_ Kohl's Admin (hanya untuk API-nya, bukan untuk UI).
    -   Implementasi `Server/AdminModule/init.lua` (termasuk `PermissionSync`).
    -   **PENTING:** Kita **SKIP** `MusicCommands.server.lua` (sesuai _log_ kegagalan). Modul ini cuma kita pake buat nge-cek _role_ (bypass).

3.  **Task 3.3: Implementasi Music Backend**

    -   Implementasi `Server/MusicModule/init.lua`.
    -   Buat _logic_ AutoDJ & Manual.
    -   Wajib `GetModule("PermissionSync")` untuk cek _role_.
    -   Wajib `GetModule("RemoteWrapper")` dan panggil `FireAllClients("UpdateUI", data)` tiap lagu ganti.

4.  **Task 3.4: Implementasi Topbar & UI Frontend**

    -   _Install_ TopbarPlus V3.
    -   Implementasi `Client/TopbarIntegration/init.lua`. Buat 1 ikon musik.
    -   Implementasi `Client/UIModule/init.lua`.
    -   `UIModule` dengerin `OnClientEvent("UpdateUI")`.
    -   `UIModule` pake `OVHLUI` (dari Fase 2) untuk nampilin data lagu di tab "NOW PLAYING".
    -   Hubungkan klik ikon TopbarPlus untuk memanggil `UIModule:ToggleMusicPanel()`.

5.  **Task 3.5: Validasi Loop**
    -   **Kriteria Sukses:** Player _join_. Lagu AutoDJ main. `UpdateUI` ke-tembak. Player klik ikon TopbarPlus. Modal `OVHLUI` muncul. Tab "NOW PLAYING" nampilin judul lagu yang bener.

---

### Fase 4: 💾 Zona, Dunia, & Persistence

**Tujuan:** Mengembangkan _experience_ dari "1 ruangan" menjadi "multi-zona" dan membuat dunia persisten (menyimpan data player).

1.  **Task 4.1: Implementasi DataStore (Fitur Baru)**

    -   Buat `Server/DataModule/init.lua` (Core Module, Phase 1 Load).
    -   Ini adalah _wrapper_ terpusat untuk `DataStoreService:GetAsync/SetAsync`.

2.  **Task 4.2: Implementasi Zone Backend & Persistence**

    -   Implementasi `Server/ZoneModule/init.lua`.
    -   `ZoneModule` akan `GetModule("DataModule")`.
    -   Fungsi: `OnPlayerJoin` -> `DataModule:GetLastZone(player)` -> Teleport player ke zona itu (atau ke "Zona Luar" jika data `nil`).
    -   Fungsi: `OnZoneChange` -> `DataModule:SaveLastZone(player, newZone)`.

3.  **Task 4.3: Implementasi Zone Frontend & Spatial Audio**

    -   Implementasi `Client/ZoneModule/init.lua`.
    -   Buat fungsi `ShowZoneSelector()`.
    -   Update `UIModule` (Fase 3) untuk nampilin tab "STAGE ZONE" yang nampilin daftar zona dari `ZoneModule`.
    -   Implementasi _client-side logic_ (bisa di `ZoneModule` atau modul baru `SpatialAudioModule`) yang mendeteksi player masuk _part_ zona (pake atribut/CollectionService) dan mengaktifkan _spatial audio_ (L/R).

4.  **Task 4.4: Validasi Persistence**
    -   **Kriteria Sukses:** Player _join_ (pertama kali), _spawn_ di "Zona Luar". Pindah ke "Zona Dangdut". _Leave_ game. _Rejoin_. Player harus langsung _spawn_ di "Zona Dangdut".

---

### Fase 5: 📺 Interaksi Dunia (LED & Kirim Salam)

**Tujuan:** Menghidupkan panggung dengan LED interaktif (Video Tron) dan mengimplementasikan fitur _social_ "Kirim Salam".

1.  **Task 5.1: Implementasi Text Filtering (Keamanan)**

    -   Buat _utility module_ baru, misal `Shared/TextFilter/init.lua`.
    -   Isinya adalah _wrapper_ aman untuk `TextService:FilterStringAsync()`. Ini **wajib** ada sebelum _logic_ "Kirim Salam".

2.  **Task 5.2: Implementasi World UI Frontend**

    -   Buat `Client/WorldUIModule/init.lua`.
    -   Modul ini dengerin 2 _event_: `UpdateUI` (untuk Now Playing) dan `UpdateSalam` (untuk Kirim Salam).
    -   Implementasi _logic_ **Queue Rotasi**:
        -   Simpan `currentSongTitle` dan `salamQueue = {}`.
        -   Buat _controller loop_ (coroutine) yang nge-cek `salamQueue`.
        -   Jika _queue_ > 0, tampilkan `salamQueue[1]` selama 10 detik, lalu `table.remove`.
        -   Jika _queue_ == 0, tampilkan `currentSongTitle`.
    -   Implementasi _renderer_ yang nyari `SurfaceGui` di `workspace` (pake atribut `KirimSalam:true` atau `NowPlaying:true`) dan ganti `.Text`-nya.

3.  **Task 5.3: Implementasi Kirim Salam Backend**

    -   Daftarkan `RequestSalam` dan `UpdateSalam` di `Events.lua` (Fase 3).
    -   Buat `Server/SalamModule/init.lua`.
    -   Dengerin `OnServerEvent("RequestSalam")`.
    -   **Alur Wajib:** `OnRequest` -> `TextFilter:Filter(text)` -> (Jika lolos) -> `RemoteWrapper:FireAllClients("UpdateSalam", filteredText)`.

4.  **Task 5.4: Validasi Interaksi**
    -   **Kriteria Sukses:** LED panggung nampilin "Now Playing". Player kirim salam. Teks di LED ganti jadi salam (yang udah disensor), nunggu 10 detik, terus balik lagi nampilin "Now Playing".

---

### Fase 6: 💰 Monetisasi & Rilis (Prioritas Terakhir)

**Tujuan:** Mengaktifkan _logic_ pembayaran untuk fitur-fitur premium dan mempersiapkan game untuk _publish_.

1.  **Task 6.1: Implementasi Monetization Backend**

    -   Buat `Server/MonetizationModule/init.lua`.
    -   Isi dengan fungsi _wrapper_ untuk `MarketplaceService` (cek _gamepass_, _prompt_ pembelian).
    -   Fungsi utama: `HandleSongRequestPayment(player)` dan `HandleSalamPayment(player)`.

2.  **Task 6.2: Update Config**

    -   Tambahkan di `Server/Config.lua`:
        ```lua
        Config.Monetization = {
            EnableSongRequests = false, -- Default false
            EnableKirimSalam = false    -- Default false
        }
        ```

3.  **Task 6.3: Integrasi Pembayaran (Song Request)**

    -   Update `Server/MusicModule/init.lua`.
    -   Di `HandleSongRequest`, tambahkan _logic_:
        1.  Cek _role_ (bypass).
        2.  Jika bukan _role_, cek `Config.Monetization.EnableSongRequests`.
        3.  Jika `true`, panggil `MonetizationModule:HandleSongRequestPayment(player)`. Baru _play_ lagu jika _return_ `true`.

4.  **Task 6.4: Integrasi Pembayaran (Kirim Salam)**

    -   Update `Server/SalamModule/init.lua`.
    -   Di `OnServerEvent("RequestSalam")`, tambahkan _logic_ **"Beli Dulu Baru Tulis"**.
    -   _Logic_ `RequestSalam` harus dipecah:
        1.  Client klik tombol "Kirim Salam" -> `FireServer("RequestSalamPayment")`.
        2.  `SalamModule` dengerin ini, panggil `MonetizationModule:HandleSalamPayment(player)`.
        3.  Jika berhasil, `FireClient(player, "PaymentSuccessSalam")`.
        4.  _Client_ (UI) baru nampilin _pop-up_ buat ngetik pesan.
        5.  Player ngetik -> `FireServer("SubmitSalamText", text)`.
        6.  `SalamModule` dengerin ini -> `TextFilter:Filter(text)` -> `FireAllClients("UpdateSalam")`.

5.  **Task 6.5: Finalisasi & Deploy**
    -   _Testing_ end-to-end semua fitur.
    -   _Review_ semua _performance guideline_ (debounce, `task.wait`).
    -   Ubah `Config.Environment` jadi `"production"`.
    -   **Kriteria Sukses:** Game siap _publish_.
