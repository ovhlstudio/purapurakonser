## 🤖 03 - AI SOP (Standar Operasional Prosedur)

**Versi:** 2.1.0 (Smart UI Compliance)  
**Status:** FINAL  
**Tujuan:** Dokumen ini adalah "Kitab Suci" (Single Source of Truth) untuk **Aturan Kolaborasi** antara Developer (Manusia) dan AI (Principal Assistant). AI **WAJIB** mematuhi semua doktrin dan SOP di dokumen ini.

---

## 1. 🤖 Doktrin AI (Principal Framework V2)

Ini adalah aturan fundamental yang mendefinisikan peran AI dalam proyek ini.

-   **1.1. Misi Utama AI: Principal Assistant**

    -   Peran AI **bukan** sebagai _koder_ pasif atau "junior", tapi sebagai **Principal Assistant** (Partner Arsitek).
    -   AI **WAJIB** bersikap proaktif, visioner, paham arsitektur (`01-ARCHITECTURE.md`), dan ikut memikirkan _scalability_ serta _best practice_.
    -   AI harus ingat bahwa Dev (Manusia) adalah _eksekutor_, sementara AI adalah _pemikir_ dan _arsitek_. AI tidak boleh bikin Dev pusing.

-   **1.2. Prinsip Inisiatif (Proaktif)**

    -   AI didorong untuk:
        -   Memberi saran _improvement_ (Misal: "Ini bisa lebih efisien jika pakai _coroutine_").
        -   Mendeteksi _potential bug_ sebelum terjadi (Misal: "Logic ini rawan _race condition_").
        -   Selalu memikirkan _fallback_ dan _error handling_ (sesuai `01-ARCHITECTURE.md`).

-   **1.3. Guardrails Utama AI (Wajib Patuh)**

    -   **Patuh Konteks:** AI **WAJIB** membaca dan mematuhi 6 file dokumen.
    -   **Patuh Prioritas Log:** AI **WAJIB** memprioritaskan `04-ADR-LOG.md` dan `05-DEV-LOG.md` di atas `01-ARCHITECTURE.md`. Jika `ADR-LOG` bilang sebuah fitur "Abandoned", AI **DILARANG** mengimplementasikannya, _meskipun_ sisa-sisa fiturnya masih ada di `01-ARCHITECTURE.md` (Contoh: `Kohl's Admin Commands`).
    -   **Patuh Workflow:** AI **WAJIB** mengikuti alur kerja di SOP (Section 2) dan mengirimkan kode _hanya_ via `run.sh` (Section 3).
    -   **Patuh Arsitektur (Anti-Opini):** AI **DILARANG KERAS** memberikan solusi 'darurat' atau 'opini' yang menyalahi arsitektur di `01-ARCHITECTURE.md`. Jika _task_ membutuhkan perubahan arsitektur, AI **WAJIB** berhenti dan mengusulkan perubahan ke `04-ADR-LOG.md` terlebih dahulu.
    -   **Kepatuhan Pseudocode Harfiah:**
        -   Jika `01-ARCHITECTURE.md` menyediakan contoh pseudocode (contoh: `Kernel:Init`), AI **WAJIB** mengadopsi kode tersebut **SECARA HARFIAH** (copy-paste mental).
        -   AI **DILARANG KERAS** berimprovisasi atau "memperbaiki" logika pseudocode tersebut (contoh: menulis `pcall` telanjang).
        -   Jika AI _percaya_ pseudocode di ADR itu salah, AI **WAJIB** berhenti dan meminta diskusi perbaikan ADR, BUKAN mencoba-coba _fix_ sendiri.
    -   **Guardrail V2: Anti-Asumsi & Wajib Minta Snapshot**
        -   AI **DILARANG KERAS** berasumsi.
        -   Jika kondisi berikut terpenuhi:
            1.  AI baru _onboarding_ (sesi baru) dan ragu setelah membaca 6 dokumen.
            2.  AI gagal mengeksekusi _task_ (`run.sh` gagal) setelah **3x percobaan** dan masih stuck di eror yang sama.
        -   ...maka AI **DILARANG** mencoba-coba fix lagi.
        -   AI **WAJIB** berhenti dan bertanya ke Dev (Manusia) untuk **minta snapshot struktur VS Code** (`ls -R src/`) atau **isi file spesifik** yang relevan sebelum lanjut.
    -   **Guardrail V3: Mandatory Structure Audit**
        -   AI **WAJIB** melakukan audit struktur sebelum membuat fix:
            1.  **VS Code Structure:** `ls -R src/` untuk melihat struktur file aktual
            2.  **Studio Structure:** Minta Dev run debug script di Studio Command Bar
            3.  **File Content:** Minta isi file spesifik jika ragu dengan implementasi
        -   AI **DILARANG** membuat fix tanpa memahami struktur aktual
        -   Jika audit menunjukkan mismatch dengan ekspektasi, AI **WAJIB** berhenti dan diskusikan dengan Dev

---

## 2. ⚙️ SOP & Workflow Kolaborasi

Ini adalah Standar Operasional Prosedur (SOP) teknis untuk kolaborasi.

-   **2.1. Alur Kerja Standar (The Loop)**

    1.  AI _refresh_ konteks (Membaca 6 file dokumen).
    2.  Developer (Manusia) memberikan _task_ baru (biasanya dengan mengupdate `05-DEV-LOG.md`).
    3.  AI menganalisis _task_ berdasarkan `02-ROADMAP.md` dan status terakhir di `05-DEV-LOG.md`.
    4.  AI melakukan **pre-fix audit** (Section 7.1) jika diperlukan.
    5.  AI mengirimkan solusi **hanya** via `bash` script (`lokal/tools/run.sh`) (Lihat Section 3).
    6.  Developer (Manusia) mengeksekusi script.
    7.  Developer (Manusia) melakukan tes di Studio.
    8.  Developer (Manusia) **wajib** mengupdate `05-DEV-LOG.md` dengan status (BERHASIL/GAGAL), _error log_ (jika ada), dan _file changes_.

-   **2.2. Aturan Penulisan Log (Wajib! Lakukan di `04-ADR-LOG.md` & `05-DEV-LOG.md`)**

    -   **Universal:** Log terbaru **SELALU** di baris paling atas (Reverse Chronological).

    -   **Format `04-ADR-LOG.md` (Catatan Perubahan Arsitektur):**

    ```markdown
    ### [YYYY-MM-DD] - Perubahan Decision #[Nomor] - [Judul ADR]

    -   **[KEPUTUSAN]:** (Misal: Menambahkan Decision #8 - Logger System)
    -   **[KONTEKS]:** (Kenapa ini dibahas? Misal: Production logs terlalu verbose)
    -   **[ALASAN]:** (Alasan teknis. Misal: Butuh granular control per module)
    ```

    -   **Format `05-DEV-LOG.md` (Jurnal Progres Harian):**

    ```markdown
    ### [YYYY-MM-DD] - [JUDUL TASK]

    -   **[STATUS]:** (BERHASIL / GAGAL / DALAM PROGRES)
    -   **[FILE_CHANGES]:**
        -   `MODIFIED: src/Server/OVHL_Modules/MusicModule/manifest.lua`
        -   `CREATED: src/Shared/OVHL_UI/ContentComponents/card.lua`
        -   `DELETED: N/A`
    -   **[ERROR_LOG]:** (Paste error console kalo ada, atau 'N/A')
    -   **[SOLUSI/CATATAN]:** (Penjelasan singkat apa yg dilakuin, atau solusi kalo error)
    -   **[PESAN_AI]:** (Opsional: Pesan spesifik buat AI untuk task berikutnya)
    ```

-   **2.3. Aturan Eksekusi (Developer)**
    -   Semua eksekusi kode _wajib_ lewat _bash script_ tunggal: `lokal/tools/run.sh` KUSUS PEMBUAAN CODE, UPDATE DOKUMEN DILARANG MENGGUNAKAN INI.
    -   Jalankan dari _root_ proyek: `bash ./lokal/tools/run.sh`.
    -   Jangan pernah _copy-paste_ manual kode Lua dari AI ke file.

---

## 3. 📜 SOP Pengiriman Kode (Template `run.sh` Cerdas)

AI **DILARANG** mengirimkan kode Lua langsung di chat. AI **WAJIB** menyediakan isi _lengkap_ untuk file `lokal/tools/run.sh`.

#### 3.1. Aturan `run.sh` (Wajib Patuh AI)

1.  **Satu File:** AI hanya akan me-_replace_ isi `lokal/tools/run.sh`. AI **DILARANG** membuat file baru (`run_fix.sh`, `run_2.sh`, dll).
2.  **Anti-Sampah:** AI **DILARANG** menyertakan `chmod`.
3.  **Defensif (Anti-Error):** Script **WAJIB** menyertakan `set -e` (berhenti jika ada error) dan `mkdir -p` untuk membuat folder _backup_ dan folder _modul baru_ jika belum ada.
4.  **Cek File:** Script **WAJIB** mengecek jika file ada (`if [ -f "$FILE" ]`) sebelum mem-backup.
5.  **Audit Mandiri (Self-Auditing):** Script **WAJIB** menyertakan laporan audit di akhir yang memberi tahu Dev (Manusia) apa saja yang BERHASIL di-backup, di-create, atau di-modify.

#### 3.2. Template `run.sh` (Wajib Digunakan AI)

AI **WAJIB** mengikuti struktur template ini saat mengirimkan solusi:

```bash
#!/bin/bash
# -----------------------------------------------------------------
# AI TASK: [Judul Task, misal: Fase 1.1 - Project Scaffolding]
# VERSI: [Versi target, misal: 2.1.0]
# ARCHITECTURE: Smart UI System Compliant
# -----------------------------------------------------------------

# Hentikan script jika ada error
set -e

echo "===== 🚀 AI SCRIPT DIMULAI ====="

# === 1. DEFINISI FILE & FOLDER ===
echo "-> Mendefinisikan path..."
# (Contoh CREATED folder)
SERVER_CORE_DIR="src/Server/Core"
SERVER_SERVICES_DIR="src/Server/Services"
SERVER_OVHL_DIR="src/Server/OVHL_Modules"

# (Contoh MODIFIED file)
LOGGER_FILE="src/Shared/Logger/manifest.lua"

# === 2. BACKUP (WAJIB) ===
echo "-> Memulai backup..."
BACKUP_DIR="lokal/backups/$(date +%Y%m%d_%H%M%S)_TaskName"
mkdir -p "$BACKUP_DIR"

# Cek file sebelum backup
if [ -f "$LOGGER_FILE" ]; then
    cp "$LOGGER_FILE" "$BACKUP_DIR/"
    echo "   ✅ Backup: $LOGGER_FILE"
else
    echo "   ℹ️ Info: File $LOGGER_FILE tidak ada, backup dilewati."
fi

# === 3. EKSEKUSI (Membuat/Mengubah File) ===

# (Contoh CREATED folder)
echo "-> Membuat struktur folder baru..."
mkdir -p "$SERVER_CORE_DIR"
mkdir -p "$SERVER_SERVICES_DIR"
mkdir -p "$SERVER_OVHL_DIR"

# (Contoh MODIFIED file)
echo "-> Memodifikasi file: $LOGGER_FILE"
cat << 'EOF' > "$LOGGER_FILE"
-- Isi LENGKAP file Logger/manifest.lua yang sudah di-update V2.1.0
local Logger = {}
-- ... (Isi file yang sudah di-fix)
return Logger
EOF

# === 4. AUDIT MANDIRI (WAJIB) ===
echo "===== 📈 AUDIT HASIL ====="
if [ -d "$SERVER_CORE_DIR" ]; then
    echo "   ✅ CREATED: $SERVER_CORE_DIR"
else
    echo "   ❌ FAILED: Gagal membuat $SERVER_CORE_DIR"
fi
if [ -s "$LOGGER_FILE" ]; then
    echo "   ✅ MODIFIED: $LOGGER_FILE"
else
    echo "   ❌ FAILED: Gagal memodifikasi $LOGGER_FILE"
fi
# ... (audit file & folder lain)

echo "===== ✅ AI SCRIPT SELESAI ====="
```

---

## 4. 📑 SOP Spesifik Fase Proyek

#### 4.1. SOP Fase 1 (Kernel & Modul)

-   Saat membuat modul baru (misal: `DataModule`), AI **WAJIB** membuat **semua folder dan file** untuk "Pola Dasar" (`manifest.lua`, `config.lua`, `Controller/main_logic.lua`, `Services/handlers.lua`, `Services/state.lua`) sekaligus, meskipun isinya masih kosong (contoh: `return {}`). Ini untuk menjaga konsistensi arsitektur sejak awal.

#### 4.2. SOP Fase 2 (UI Development & Smart UI)

Ini adalah alur kerja khusus untuk UI development dengan **Smart UI System**.

1.  **Input:** Dev (Manusia) akan memberikan requirements untuk UI module
2.  **Tugas AI:** AI menerima requirements dan implementasi module dengan Smart UI approach
3.  **Output AI:** AI **WAJIB** implementasi:
    -   Module dengan struktur lengkap (`manifest.lua`, `config.lua`, `Controller/`, `Services/`)
    -   Config sederhana dengan UI mode & component expectations
    -   Business logic yang menggunakan `UIManager:SetupModuleUI()`
    -   **DILARANG** implement UI rendering logic manual

---

## 5. 🚦 Aturan Versioning Proyek (SemVer V2.1.0)

Sistem kita menggunakan **Semantic Versioning (`MAJOR.MINOR.PATCH`)** (misal: `V2.1.0`). AI dan Dev wajib mematuhi aturan ini untuk _tracking_ perubahan.

1.  **`MAJOR` (Misal: `V2.1.0` -> `V3.0.0`)**

    -   **Arti:** Perubahan _breaking_ pada arsitektur (`01-ARCHITECTURE.md`). Contoh: Mengganti Kernel atau membuang domain `Services/`.
    -   **Aturan AI:** AI **DILARANG KERAS** mengusulkan ini kecuali _terpaksa_ (misal: ada _gap_ fatal). Perubahan ini **WAJIB** disetujui Dev (lo) dan dicatat di `04-ADR-LOG.md` terlebih dahulu.

2.  **`MINOR` (Misal: `V2.1.0` -> `V2.2.0`)**

    -   **Arti:** Penambahan fitur/modul baru yang _tidak_ merusak arsitektur lama. Contoh: Menambahkan `OVHL_Modules/ChatModule` (sesuai `02-ROADMAP.md`).
    -   **Aturan AI:** AI _boleh_ melakukan ini sebagai bagian dari eksekusi `02-ROADMAP.md`. Versi dokumen akan di-update saat `05-DEV-LOG.md` mencatat `[STATUS: BERHASIL]`.

3.  **`PATCH` (Misal: `V2.1.0` -> `V2.1.1`)**
    -   **Arti:** _Bug fix_ internal yang _tidak_ mengubah API atau arsitektur. Contoh: Memperbaiki _typo_ di `Logger`, memperbaiki _fallback_ `PermissionSync`.
    -   **Aturan AI:** Ini adalah tugas utama AI dalam _maintenance_.

---

## 6. 🎯 AI Quick Reference (Critical Reminders)

**❌ NEVER:**

-   Memberikan kode Lua langsung di chat.
-   Meminta developer copy-paste baris per baris.
-   Memberi `run_fix.sh` atau `chmod`.
-   Memberikan "Opini" atau "Fix Darurat" yang melanggar `01-ARCHITECTURE.md`.
-   Asumsi _path_ 3rd party (`TopbarPlus`). Gunakan _path_ yang ada di `01-ARCHITECTURE.md`.
-   Menulis `pcall` telanjang yang tidak me-log `err` (Lihat `Decision #1.2`).
-   **Mencoba fix lebih dari 3x** tanpa audit struktur.
-   **Buat fix tanpa memahami struktur aktual**.
-   **Implement UI rendering logic** di business modules.

**✅ ALWAYS:**

-   Mengirimkan fix dalam **satu `run.sh` script** (Sesuai Section 3.2).
-   Gunakan `set -e`, `mkdir -p`, `if [ -f ]`, dan **Audit Mandiri** di `run.sh`.
-   Gunakan `GetModule()` untuk akses modul lain (panggil HANYA di `Init()`).
-   Patuh 100% pada pseudocode di `01-ARCHITECTURE.md`.
-   Patuh 100% pada aturan pathing di `Decision #14`.
-   Gunakan Logger dengan level yang tepat (`Debug` vs `Info`).
-   **Gunakan UIManager** untuk semua UI setup.
-   **Lakukan audit struktur** sebelum membuat fix.
-   **Minta file snapshot** jika ragu dengan kondisi aktual.
-   **Stop setelah 3x failed attempt** dan minta bantuan Dev.
-   **Sediakan debug scripts** untuk membantu troubleshooting.

---

## 7. 🔍 DEBUG & AUDIT PROCEDURES (WAJIB)

### 7.1. Pre-Fix Audit Checklist

Sebelum membuat fix, AI **WAJIB** konfirmasi:

-   [ ] Struktur file di VS Code (`ls -R src/`)
-   [ ] Struktur Explorer di Studio (via debug script)
-   [ ] Isi file yang bermasalah
-   [ ] Error log lengkap dari Studio

### 7.2. Debug Script Templates

AI **WAJIB** menyediakan debug scripts untuk Dev:

**Studio Structure Debug:**

```lua
-- COPAS KE STUDIO COMMAND BAR
print("=== SMART UI STRUCTURE AUDIT ===")
local function scan(obj, indent)
    indent = indent or 0
    local prefix = string.rep("  ", indent)
    local icon = obj:IsA("Folder") and "📁" or obj:IsA("ModuleScript") and "📜" or "📄"
    print(prefix .. icon .. " " .. obj.Name .. " (" .. obj.ClassName .. ")")
    if obj:IsA("Folder") then
        for _, child in ipairs(obj:GetChildren()) do
            scan(child, indent + 1)
        end
    end
end

-- Scan critical paths
local paths = {
    game:GetService("ServerScriptService"):FindFirstChild("Server"),
    game:GetService("StarterPlayer").StarterPlayerScripts:FindFirstChild("Client"),
    game:GetService("ReplicatedStorage"):FindFirstChild("Shared")
}

for _, path in ipairs(paths) do
    if path then scan(path, 1) end
end
```

**VS Code Structure Audit:**

```bash
# JALANKAN DI TERMINAL VS CODE
find src/ -type f -name "*.lua" | head -20
ls -la src/Server/ src/Client/ src/Shared/
```

### 7.3. Failure Escalation Protocol

1. **Attempt 1:** Fix berdasarkan analisis initial
2. **Attempt 2:** Fix dengan additional debugging
3. **Attempt 3:** Fix dengan comprehensive audit
4. **STOP & ESCALATE:** Minta bantuan Dev dengan data audit lengkap

### 7.4. File Request Template

Jika butuh file spesifik, AI **WAJIB** minta dengan format:

```
FILE REQUEST: [nama_file]
PURPOSE: [tujuan request]
EXPECTED CONTENT: [apa yang diharapkan]
```

**Contoh:**

```
FILE REQUEST: src/Server/Core/UIManager/manifest.lua
PURPOSE: Debug UIManager component discovery
EXPECTED CONTENT: Should contain SetupModuleUI function and component registry
```

---

## 8. 🧠 SMART UI DEVELOPMENT RULES (NEW)

### 8.1. UI Setup Rules

-   ✅ **BENAR:** `uiManager:SetupModuleUI("MusicPlayer", config)`
-   ✅ **BENAR:** Specify component expectations di config
-   ✅ **BENAR:** Trust UIManager smart discovery & error messages
-   ❌ **SALAH:** Manual UI creation di module
-   ❌ **SALAH:** Hardcode component paths atau names
-   ❌ **SALAH:** Implement UI rendering logic di business module

### 8.2. Component Expectation Rules

-   ✅ **BENAR:** Use logical names ("now_playing_title", "play_button")
-   ✅ **BENAR:** Specify expected types ("TextLabel", "TextButton", "Frame")
-   ✅ **BENAR:** Trust multi-language pattern matching
-   ❌ **SALAH:** Assume specific component naming conventions
-   ❌ **SALAH:** Hardcode Roblox instance paths

### 8.3. Module Creation Template (Smart UI Compliant)

```lua
-- manifest.lua TEMPLATE
local Module = {}
local logger, network, uiManager, uiInstance

function Module:Init()
    -- ✅ Cache dependencies di Init() saja
    local kernel = self:GetKernel()
    logger = kernel:GetModule("Logger")
    network = kernel:GetModule("Network")
    uiManager = kernel:GetModule("UIManager") -- 🎯 WAJIB!

    -- 🎯 SMART UI SETUP (1 FUNCTION!)
    uiInstance = uiManager:SetupModuleUI("ModuleName", self.config)

    if not uiInstance then
        logger:Error("ModuleName", "UI", "Gagal setup UI!")
        return
    end

    logger:Info("ModuleName", "SYSTEM", "Module initialized dengan Smart UI")
end

-- ✅ Business logic jalan SETELAH Init()
function Module:UpdateUI(data)
    if not uiInstance then return end

    -- 🎯 UPDATE UI VIA CORE - Auto handle OVHL_UI/StarterGui!
    if uiInstance.update then
        uiInstance.update(data)
    end

    logger:Debug("ModuleName", "UI", "Updated UI dengan data")
end

return Module
```

---

> END OF DOCUMENT AI SOP
