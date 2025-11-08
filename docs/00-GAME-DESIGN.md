# 🛡️ 00 - GAME DESIGN (VISI & FITUR)

**Versi:** 1.0.0
**Status:** FINAL
**Tujuan:** Dokumen ini adalah "Kitab Suci" (Single Source of Truth) untuk **Visi Proyek** dan **Pilar Gameplay**. Dokumen ini mendefinisikan _APA_ yang kita bangun.

---

## 1. 🎯 Visi & Logline Proyek

Dokumen ini mendefinisikan _gameplay loop_ fundamental, pilar, dan visi masa depan dari proyek ini.

-   **1.1. Nama Proyek:** Pura Pura Pesta
-   **1.2. Logline (Elevator Pitch):** Sebuah _social concert experience_ di Roblox di mana player bisa _join_, memilih zona panggung (seperti Dangdut) untuk merasakan _spatial audio_ yang imersif, dan berinteraksi dengan sistem musik (AutoDJ/Manual) melalui UI terpusat.

---

## 2. 🏛️ Gameplay Pillars (Pilar Utama)

### Pillar 1: Music & Zone Experience

-   **Player Onboarding:** Player yang pertama kali _join_ (belum pernah masuk) akan _spawn_ di "Zona Luar" (di luar panggung). Mereka hanya akan mendengar suara musik sayup-sayup.
-   **Zone Selection:** Player bebas berjalan dan menjelajah untuk memilih zona panggung (contoh: Zona Musik Dangdut).
-   **Spatial Audio:** _Experience_ audio akan imersif menggunakan _spatial sound_ (L dan R). Suara akan berubah (misal: menjauh, berbelok) berdasarkan pergerakan dan posisi player. Ini akan dikontrol via Atribut `Audio_Side:L` atau `Audio_Side:R` pada _part_.
-   **Music Logic (AutoDJ vs Manual):**
    -   Sistem musik punya dua mode: **AutoDJ** (default, memutar lagu random dari _playlist_ zona) dan **Manual** (dipilih oleh _role_ tertentu).
    -   Jika mode Manual selesai memutar 1 lagu, sistem akan otomatis kembali ke mode AutoDJ.
-   **Zone Filtering:** Setiap zona HANYA akan memutar lagu yang diizinkan untuk zona tersebut (berdasarkan `ZoneID` atau `ZoneName` di data lagu).
-   **World UI (LED/Video Tron):**
    -   LED panggung (SurfaceGUI) akan menyiarkan `NOW PLAYING` (Judul Lagu, Artis) secara _real-time_.
    -   _Logic_ ini akan ditangani oleh `Client/OVHL_Modules/WorldUIModule` yang mendengarkan _event_ `UpdateUI`.
    -   LED ini juga akan diinterupsi oleh siaran "Kirim Salam" (lihat Pillar 2).

### Pillar 2: UI & Interaction (OVHL UI)

-   **UI Layout:** UI musik akan berupa panel besar (ala Spotify/YT Music) dengan 2 _navigation tab_ utama: `NOW PLAYING` dan `STAGE ZONE`.
-   **Tab `NOW PLAYING`:** Fokus menampilkan info lagu yang sedang diputar (Judul, Artis, Genre).
-   **Tab `STAGE ZONE`:** Menampilkan daftar semua zona yang tersedia (Zona A, B, C) dan daftar lagu di dalam zona tersebut.
-   **Shared Components:** Kedua tab akan berbagi komponen yang sama untuk `Header` (Title, Close 'X'), `Media Controls`, dan `Footer`.
-   **Individual Volume (Client-Side):**
    -   Fitur `SetGlobalVolume` (Server-Side) **DITIADAKAN** karena menyebabkan _bug_.
    -   Volume _server_ akan dipaten 100%.
    -   Player (termasuk non-role) bisa mengatur _volume individual_ mereka sendiri via _slider_ di `OVHL UI` yang mengontrol properti `.Volume` _sound_ di _client_ mereka (via `Client/Services/AudioModule`).
-   **Fitur "Kirim Salam" (Shout-out):**
    -   Player bisa mengirim pesan untuk ditampilkan di LED panggung.
    -   **Keamanan (Wajib):** Semua pesan _wajib_ difilter menggunakan `TextService:FilterStringAsync()` (Native Roblox Filter) _sebelum_ di-broadcast.
    -   **Logic Antrian (Client-Side):** `Client/OVHL_Modules/WorldUIModule` akan memiliki _queue_ (antrian). LED akan menampilkan `NOW PLAYING` secara _default_. Jika ada "Salam" di _queue_, LED akan menampilkan "Salam" selama X detik, lalu kembali ke `NOW PLAYING`.
    -   **Logic Monetisasi (Wajib):** _Workflow_ wajib **"Beli Dulu Baru Tulis"**. Player harus menyelesaikan transaksi (via `MonetizationModule`) _sebelum_ UI untuk mengetik pesan muncul, untuk mencegah _spam antrian_.

### Pillar 3: Permission, Data & Monetization

-   **Permissions (Kontrol Musik):**
    -   Hanya _role_ tertentu (via `PermissionSync:GetRole()`) yang bisa menggunakan _Media Controls_ (Play, Pause, Stop, Next).
    -   Player biasa (tanpa _role_) tombolnya akan di-_disable_.
-   **Player Persistence (DataStore):**
    -   Sistem akan menyimpan data player menggunakan `Server/Services/DataModule/init.lua` (wrapper DataStore).
-   **Data Awal:** `LastKnownZone`. Player yang _rejoin_ akan langsung di-_spawn_ ke zona terakhir tersebut, tidak lagi di "Zona Luar".
    -   **Future-Proof:** Modul ini akan dipakai untuk menyimpan `InternalRole` (fallback), _playtime_, _badge_, dll.
-   **Monetization & Bypass (Future-Proof):**
    -   Akan ada `Server/Services/MonetizationModule/init.lua` untuk _gamepass_ dan _dev products_.
    -   **Config Flag (Wajib):** Semua fitur berbayar (Request Lagu, Kirim Salam) _wajib_ memiliki _toggle_ `true/false` di `Server/Config.lua` (global).
    -   **Permission Bypass (Wajib):** _Logic_ pembayaran **WAJIB** di-_skip_ jika `PermissionSync:GetRole(player)` me-return role yang diizinkan (misal: "OVHL_Admin").

---

## 3. 🚀 Future Vision (Visi Masa Depan)

-   **Lighting System:** Akan ada implementasi `Server/Services/LightingModule`. Sistem ini (mungkin) akan terintegrasi dengan `OVHL_Modules/MusicModule` untuk menciptakan koreografi lampu panggung yang sinkron dengan _genre_ lagu (e.g., _slow_, _rock_, _koplo_).
-   **VoteToSkip & RequestSong:** Fitur-fitur ini (yang sudah ada di `Network/Events.lua`) akan diintegrasikan penuh ke UI, termasuk _logic_ pembayaran untuk `RequestSong`.
