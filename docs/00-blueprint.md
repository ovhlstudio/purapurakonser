# 🛡️ 00 - BLUEPRINT & AI DOCTRINE

**Versi:** 2.0  
**Status:** FINAL  
**Tujuan:** Dokumen ini adalah "Kitab Suci" (Single Source of Truth) untuk Visi Proyek dan Aturan Kolaborasi (SOP) antara Developer (Manusia) dan AI (Principal Assistant). AI **wajib** mematuhi semua doktrin dan SOP di dokumen ini.

---

## 1. 🎯 Visi & Logline Proyek

Dokumen ini mendefinisikan _gameplay loop_ fundamental, pilar, dan visi masa depan dari proyek ini.

-   **1.1. Nama Proyek:** Pura Pura Pesta
-   **1.2. Logline (Elevator Pitch):** Sebuah _social concert experience_ di Roblox di mana player bisa _join_, memilih zona panggung (seperti Dangdut) untuk merasakan _spatial audio_ yang imersif, dan berinteraksi dengan sistem musik (AutoDJ/Manual) melalui UI terpusat.

### 1.3. Gameplay Pillars (Pilar Utama)

#### Pillar 1: Music & Zone Experience

-   **Player Onboarding:** Player yang pertama kali _join_ (belum pernah masuk) akan _spawn_ di "Zona Luar" (di luar panggung). Mereka hanya akan mendengar suara musik sayup-sayup.
-   **Zone Selection:** Player bebas berjalan dan menjelajah untuk memilih zona panggung (contoh: Zona Musik Dangdut).
-   **Spatial Audio:** _Experience_ audio akan imersif menggunakan _spatial sound_ (L dan R). Suara akan berubah (misal: menjauh, berbelok) berdasarkan pergerakan dan posisi player. Ini akan dikontrol via Atribut `Audio_Side:L` atau `Audio_Side:R` pada _part_.
-   **Music Logic (AutoDJ vs Manual):**
    -   Sistem musik punya dua mode: **AutoDJ** (default, memutar lagu random dari _playlist_ zona) dan **Manual** (dipilih oleh _role_ tertentu).
    -   Jika mode Manual selesai memutar 1 lagu, sistem akan otomatis kembali ke mode AutoDJ.
-   **Zone Filtering:** Setiap zona HANYA akan memutar lagu yang diizinkan untuk zona tersebut (berdasarkan `ZoneID` atau `ZoneName` di data lagu).
-   **World UI (LED/Video Tron):**
    -   LED panggung (SurfaceGUI) akan menyiarkan `NOW PLAYING` (Judul Lagu, Artis) secara _real-time_.
    -   _Logic_ ini akan ditangani oleh `Client/WorldUIModule` yang mendengarkan _event_ `UpdateUI`.
    -   LED ini juga akan diinterupsi oleh siaran "Kirim Salam" (lihat Pillar 2).

#### Pillar 2: UI & Interaction (OVHL UI)

-   **UI Layout:** UI musik akan berupa panel besar (ala Spotify/YT Music) dengan 2 _navigation tab_ utama: `NOW PLAYING` dan `STAGE ZONE`.
-   **Tab `NOW PLAYING`:** Fokus menampilkan info lagu yang sedang diputar (Judul, Artis, Genre).
-   **Tab `STAGE ZONE`:** Menampilkan daftar semua zona yang tersedia (Zona A, B, C) dan daftar lagu di dalam zona tersebut.
-   **Shared Components:** Kedua tab akan berbagi komponen yang sama untuk `Header` (Title, Close 'X'), `Media Controls`, dan `Footer`.
-   **Individual Volume (Client-Side):**
    -   Fitur `SetGlobalVolume` (Server-Side) **DITIADAKAN** karena menyebabkan _bug_.
    -   Volume _server_ akan dipaten 100%.
    -   Player (termasuk non-role) bisa mengatur _volume individual_ mereka sendiri via _slider_ di `OVHL UI` yang mengontrol properti `.Volume` _sound_ di _client_ mereka.
-   **Fitur "Kirim Salam" (Shout-out):**
    -   Player bisa mengirim pesan untuk ditampilkan di LED panggung.
    -   **Keamanan (Wajib):** Semua pesan _wajib_ difilter menggunakan `TextService:FilterStringAsync()` (Native Roblox Filter) _sebelum_ di-broadcast.
    -   **Logic Antrian (Client-Side):** `Client/WorldUIModule` akan memiliki _queue_ (antrian). LED akan menampilkan `NOW PLAYING` secara _default_. Jika ada "Salam" di _queue_, LED akan menampilkan "Salam" selama X detik, lalu kembali ke `NOW PLAYING`.
    -   **Logic Monetisasi (Wajib):** _Workflow_ wajib **"Beli Dulu Baru Tulis"**. Player harus menyelesaikan transaksi (via `MonetizationModule`) _sebelum_ UI untuk mengetik pesan muncul, untuk mencegah _spam antrian_.

#### Pillar 3: Permission, Data & Monetization

-   **Permissions (Kontrol Musik):**
    -   Hanya _role_ tertentu (via `PermissionSync`) yang bisa menggunakan _Media Controls_ (Play, Pause, Stop, Next).
    -   Player biasa (tanpa _role_) tombolnya akan di-_disable_.
-   **Player Persistence (DataStore):**
    -   Sistem akan menyimpan data player menggunakan `Server/Services/DataModule/init.lua` (wrapper DataStore).
    -   **Data Awal:** `LastKnownZone`. Player yang _rejoin_ akan langsung di-_spawn_ ke zona terakhir tersebut, tidak lagi di "Zona Luar".
    -   **Future-Proof:** Modul ini akan dipakai untuk menyimpan data _playtime_, _badge_, dll.
-   **Monetization & Bypass (Future-Proof):**
    -   Akan ada `Server/Services/MonetizationModule/init.lua` untuk _gamepass_ dan _dev products_.
    -   **Config Flag (Wajib):** Semua fitur berbayar (Request Lagu, Kirim Salam) _wajib_ memiliki _toggle_ `true/false` di `Server/Config.lua`.
    -   **Permission Bypass (Wajib):** _Logic_ pembayaran **WAJIB** di-_skip_ jika player memiliki _role_ (dicek via `PermissionSync:CanPlayerDo(...)`).

### 1.4. Future Vision (Visi Masa Depan)

-   **Lighting System:** Akan ada implementasi `LightingSystem`. Sistem ini (mungkin) akan terintegrasi dengan `MusicModule` untuk menciptakan koreografi lampu panggung yang sinkron dengan _genre_ lagu (e.g., _slow_, _rock_, _koplo_).
-   **VoteToSkip & RequestSong:** Fitur-fitur ini (yang sudah ada di ADR) akan diintegrasikan penuh ke UI, termasuk _logic_ pembayaran untuk `RequestSong`.

---

## 2. 🤖 Doktrin AI (Principal Framework)

Ini adalah aturan fundamental yang mendefinisikan peran AI dalam proyek ini.

-   **2.1. Misi Utama AI:** Peran AI **bukan** sebagai _koder_ pasif, tapi sebagai **Principal Assistant** (Partner Arsitek). AI harus proaktif, visioner, paham arsitektur, dan ikut memikirkan _scalability_ serta _best practice_.

-   **2.2. Prinsip Inisiatif:** AI didorong untuk:

    -   Memberi saran _improvement_ (Misal: "Ini bisa lebih efisien jika pakai _coroutine_").
    -   Mendeteksi _potential bug_ sebelum terjadi (Misal: "Logic ini rawan _race condition_").
    -   Selalu memikirkan _fallback_ dan _error handling_ (sesuai ADR `ERROR HANDLING PATTERNS`).

-   **2.3. Guardrails Utama AI (Wajib Patuh):**
    -   **Anti-Asumsi:** Dilarang keras berasumsi. Selalu patuh pada `01-ADR-FINAL.md`. Jika ada yang tidak jelas, tanyakan.
    -   **Patuh Workflow:** Wajib mengikuti alur kerja di SOP (Section 3).
    -   **Konteks adalah Raja:** Wajib membaca `03-DEV-Log.md` (terutama entri terakhir) _sebelum_ memberikan solusi, untuk memahami _state_ proyek saat ini.
    -   **Paham Sejarah:** Wajib merujuk `02-ADR-Log.md` untuk paham _kenapa_ sebuah keputusan teknis (misal: Abandoned Kohl's Admin) diambil.

---

## 3. ⚙️ SOP & Workflow Kolaborasi

Ini adalah Standar Operasional Prosedur (SOP) teknis untuk kolaborasi.

-   **3.1. Alur Kerja Standar (The Loop):**

    1. AI _refresh_ konteks (Membaca 5 file: Blueprint, ADR, ADR-Log, DEV-Log, AttributeContract).
    2. Developer (Manusia) memberikan _task_ baru (biasanya dengan mengupdate `03-DEV-Log.md`).
    3. AI menganalisis _task_ berdasarkan _state_ terakhir di `03-DEV-Log.md`.
    4. AI mengirimkan solusi **hanya** via `bash` script (`lokal/tools/run.sh`).
    5. Developer (Manusia) mengeksekusi script.
    6. Developer (Manusia) melakukan tes di Studio.
    7. Developer (Manusia) **wajib** mengupdate `03-DEV-Log.md` dengan status (BERHASIL/GAGAL), _error log_ (jika ada), dan _file changes_.

-   **3.2. Aturan Penulisan Log (Wajib!):**

    -   **Universal:** Log terbaru **SELALU** di baris paling atas (Reverse Chronological).
    -   **Format `03-DEV-Log.md`:**

        ```markdown
        ### [YYYY-MM-DD] - [JUDUL TASK]

        -   **[STATUS]:** (BERHASIL / GAGAL / DALAM PROGRES)
        -   **[FILE_CHANGES]:**
            -   `MODIFIED: src/Server/Business/MusicModule/init.lua`
            -   `CREATED: src/Shared/OVHL_UI/ContentComponents/Card.lua`
            -   `DELETED: N/A`
        -   **[ERROR_LOG]:** (Paste error console kalo ada, atau 'N/A')
        -   **[SOLUSI/CATATAN]:** (Penjelasan singkat apa yg dilakuin, atau solusi kalo error)
        -   **[PESAN_AI]:** (Opsional: Pesan spesifik buat AI untuk task berikutnya)
        ```

    -   **Format `02-ADR-Log.md`:**

        ```markdown
        ### [YYYY-MM-DD] - Perubahan Decision #[Nomor] - [Judul ADR]

        -   **[KEPUTUSAN]:** (Misal: Menambahkan Decision #8 - Logger System)
        -   **[KONTEKS]:** (Kenapa ini dibahas? Misal: Production logs terlalu verbose)
        -   **[ALASAN]:** (Alasan teknis. Misal: Butuh granular control per module)
        ```

-   **3.3. Aturan Eksekusi (Developer):**

    -   Semua eksekusi kode _wajib_ lewat _bash script_ tunggal.
    -   Jalankan dari _root_ proyek: `bash ./lokal/tools/run.sh`
    -   Jangan pernah _copy-paste_ manual kode Lua dari AI ke file.

-   **3.4. Aturan Pengiriman Kode (AI):**
    -   Wajib mengirim kode via `bash` dengan `cat << 'EOF' > [path]`.
    -   Script _wajib_ menyertakan _backup_ otomatis ke `./lokal/backups/`.
    -   Script _wajib_ menyertakan _audit_ di akhir untuk cek file terisi.

---

## 4. 🗂️ Struktur Konteks Proyek

Ini adalah daftar file yang WAJIB dibaca AI setiap kali memulai sesi.

-   **`00-blueprint.md`:** (File ini) Visi, Doktrin, dan SOP.
-   **`01-ADR-FINAL.md`:** Kitab Suci Arsitektur (Technical Bible V5.0).
-   **`02-ADR-Log.md`:** Catatan Sejarah Perubahan Arsitektur.
-   **`03-DEV-Log.md`:** Jurnal Progres, Error, dan Status Terakhir Proyek.
-   **`docs/AttributeContract.md`:** Kontrak Builder-Scripter untuk konfigurasi via Attributes.

---

## 5. 🏗️ Builder-Scripter Workflow

### 5.1. Builder Responsibilities (Zero Code Touch)

**Apa yang Builder Kerjain:**

-   ✅ Buat model di Workspace (contoh: `Workspace.Stages.DangdutStage`)
-   ✅ Tambah Attributes via Properties panel di Studio
-   ✅ Test langsung di Studio tanpa nunggu scripter
-   ✅ Lihat `docs/AttributeContract.md` untuk tau attribute apa aja yang tersedia

**Contoh Real Workflow Builder:**

1. Builder bikin model panggung baru: `Workspace.Stages.RockStage`
2. Builder buka Properties → Add Attribute:
    - `Zone_ID` (String): `"rock"`
    - `Zone_DisplayName` (String): `"Rock Zone"`
    - `Spawn_Position` (Vector3): `Vector3.new(100, 5, 0)`
3. Builder klik Play di Studio → Zone langsung muncul di UI
4. **ZERO CODE TOUCH** ✅

### 5.2. Scripter Responsibilities (Attribute Validation)

**Apa yang Scripter Kerjain:**

-   ✅ Validate attributes di module `Init()`
-   ✅ Handle missing/invalid attributes dengan graceful defaults
-   ✅ Update `docs/AttributeContract.md` setiap kali tambah attribute baru
-   ✅ Log warning/error kalau builder salah setup attribute

**Contoh Real Workflow Scripter:**

```lua
-- Server/Business/ZoneModule/init.lua
function ZoneModule:ScanZones()
    for _, stage in ipairs(workspace.Stages:GetChildren()) do
        local zoneID = stage:GetAttribute("Zone_ID")

        -- VALIDATION (Builder Contract)
        if not zoneID then
            Logger:Error("ZoneModule", "ZONE", "Missing Zone_ID attribute", {
                Model = stage.Name
            })
            continue -- Skip invalid zone
        end

        -- Register zone dengan defaults
        self.Zones[zoneID] = {
            Model = stage,
            DisplayName = stage:GetAttribute("Zone_DisplayName") or zoneID,
            SpawnPosition = stage:GetAttribute("Spawn_Position") or stage.PrimaryPart.Position
        }
    end
end
```

### 5.3. The Contract (Aturan Baku)

**Builder MUST:**

-   Follow attribute naming convention di `AttributeContract.md`
-   Cek dokumentasi sebelum tanya ke scripter
-   Test setup sendiri dulu sebelum report bug

**Scripter MUST:**

-   Validate + provide defaults untuk semua attributes
-   Update `AttributeContract.md` kalau ada attribute baru
-   Log error yang jelas kalau builder salah setup

**Both MUST:**

-   Saling komunikasi via `AttributeContract.md` sebagai single source of truth
-   Jangan hardcode config di script (selalu pakai attributes kalau bisa)

---

## 6. 📊 Logging Standards (Production vs Development)

### 6.1. Log Level Hierarchy

```lua
DEBUG  → 🔍 Verbose: function calls, data dumps (development only)
INFO   → ℹ️ Normal: user actions, state changes (production default)
WARN   → ⚠️ Warning: recoverable errors, deprecations
ERROR  → 💀 Critical: failures, exceptions (always shown)
PERF   → ⚡ Performance: timing data (optional, for profiling)
```

### 6.2. Development vs Production Output

**🔧 Development Mode (`Config.Debug.GlobalLogLevel = "DEBUG"`):**

```
[14:32:01] 🖥️ 🎵 🔍 📊 [MusicModule] PlaySong called
└─ Data: {"SongID":"123","Zone":"dangdut"}
[14:32:01] 🖥️ 🎵 ℹ️ 📢 [MusicModule] Playing: Kopi Dangdut - Fahmi Shahab
[14:32:02] 🖥️ 🎵 ⚡ 📢 [MusicModule] PlaySong took 850.32ms
```

**🚀 Production Mode (`Config.Debug.GlobalLogLevel = "INFO"`):**

```
[14:32:01] 🖥️ 🎵 ℹ️ 📢 [MusicModule] Playing: Kopi Dangdut - Fahmi Shahab
```

**🔥 Error Mode (Always Shows):**

```
[14:35:12] 🖥️ 💾 💀 📢 [DataModule] CRITICAL: Data save failed for Player1
└─ Data: {"PlayerID":12345,"Error":"Request was throttled"}
```

### 6.3. Emoji Legend

| Category   | Emoji | Meaning                 |
| ---------- | ----- | ----------------------- |
| **Realm**  | 🖥️    | Server                  |
|            | 💻    | Client                  |
|            | 🔗    | Shared                  |
| **Domain** | 🎵    | Music                   |
|            | 🗺️    | Zone                    |
|            | 💾    | Data                    |
|            | 👑    | Admin                   |
|            | 🎨    | UI                      |
|            | 📡    | Network                 |
|            | 💰    | Monetization            |
| **Level**  | 🔍    | Debug                   |
|            | ℹ️    | Info                    |
|            | ⚠️    | Warning                 |
|            | 💀    | Error                   |
|            | ⚡    | Performance             |
| **Type**   | 📢    | Announce (user-facing)  |
|            | 📊    | Data (dumps/inspection) |
|            | 🎬    | Action (system actions) |
|            | ✅    | Result (success)        |

### 6.4. How to Configure

**For Builder/Designer (via Config.lua):**

```lua
-- Server/Config.lua
Debug = {
    GlobalLogLevel = "INFO",  -- Change to "DEBUG" for testing

    -- Optional: Per-module override
    ModuleLevels = {
        MusicModule = "DEBUG",  -- Only MusicModule shows debug logs
        ZoneModule = "INFO",
    },

    EnablePerfLogs = false,  -- Set true untuk track performance
}
```

**Zero Script Touch:** Builder cukup ganti string `"DEBUG"` jadi `"INFO"`, save, test.

---

## 7. 🎯 AI Quick Reference (Critical Reminders)

**❌ NEVER:**

-   Memberikan kode Lua langsung di chat
-   Meminta developer copy-paste baris per baris
-   Berasumsi `MusicCommandsServer.lua` akan berhasil (Decision #5: Abandoned)
-   Hardcode paths seperti `game.ServerScriptService.PuraPuraPesta`
-   Ignore `AttributeContract.md` saat bikin fitur yang butuh builder input

**✅ ALWAYS:**

-   Deliver fix dalam **satu bash script** (Decision #7)
-   Gunakan full path relatif (`src/Server/...`)
-   Sertakan **Backup**, **Action (cat << EOF)**, **Audit**
-   Gunakan `GetModule()` untuk akses module lain
-   Cek `docs/AttributeContract.md` kalau feature butuh Attributes
-   Gunakan relative paths (`require(script.Parent.Parent.init)`) untuk internal modules
-   Gunakan full paths (`require(game.ServerScriptService.Server.init)`) HANYA untuk 3rd-party addons

**✅ DECISION CHECKLIST (Before Coding):**

1. Apakah ini butuh attribute baru? → Update `AttributeContract.md`
2. Apakah ini modul baru? → Tentukan domain (Core/Services/Business)
3. Apakah ini butuh network communication? → Tambah ke `Network/Events.lua`
4. Apakah ini butuh log? → Gunakan Logger dengan level yang tepat
5. Apakah ini butuh permission check? → Gunakan `PermissionSync`

---

**Document Version:** 2.0  
**Last Updated:** 2025-11-07  
**Status:** Production Ready ✅
