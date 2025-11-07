# 🏛️ 02 - ADR Log (Catatan Perubahan Arsitektur)

**Tujuan:** Mencatat _kenapa_ dan _kapan_ keputusan arsitektur (ADR) diubah.
**Aturan:** Entri terbaru SELALU di paling atas (Reverse Chronological).

---

### [2025-11-07] - Penambahan Decision #8, #9, #10 - Arsitektur V4.2

-   **[KEPUTUSAN]:** Menambahkan tiga (3) Decision baru ke `01-ADR-FINAL.md`, menaikkan versi ke v4.2.
    -   `Decision #8: Logger & Log Level System`
    -   `Decision #9: Module Domain Organization`
    -   `Decision #10: Attribute-Based Builder Contract`
-   **[KONTEKS]:** Dokumen ADR V4.1.1 (dan Blueprint V1) belum memiliki standar yang jelas untuk tiga area kritis:
    1.  _Logging:_ Butuh kontrol granular (DEBUG vs INFO) untuk _production_.
    2.  _Arsitektur:_ Struktur folder "flat" sulit di-_maintain_.
    3.  _Workflow:_ Tidak ada "kontrak" resmi antara Builder (desainer) dan Scripter (koder).
-   **[ALASAN]:**
    -   **Decision #8:** Mengimplementasi Logger multi-level agar log _production_ bersih, namun _development_ tetap bisa _verbose_ (rinci) via `Config.lua`.
    -   **Decision #9:** Mengadopsi arsitektur 3-Domain (`Core`, `Services`, `Business`) untuk memisahkan tanggung jawab (Separation of Concerns) dan mempermudah _maintenance_ jangka panjang.
    -   **Decision #10:** Menetapkan "kontrak" via Atribut (Attributes) agar Builder bisa mengkonfigurasi _gameplay_ (seperti `Zone_ID`) tanpa menyentuh kode Lua, menciptakan workflow "Zero Code Touch".

---

### [2025-11-06] - Perubahan Decision #5 & #7, Penambahan Logger Fix (V4.1)

-   **[KEPUTUSAN]:**
    1.  Merombak **Decision #5 (Kohl's Admin)** dari "Cara Integrasi" menjadi **"Abandoned"** (Ditinggalkan).
    2.  Menambahkan **Decision #7 (AI & Workflow Execution Policy)**.
    3.  Memperbarui **Decision #4 (Logger)** dengan _bugfix_ V4.1.
    4.  Menghapus `SetGlobalVolume` dari arsitektur.
-   **[KONTEKS]:**
    -   Selama pengembangan Fase 3 (dicatat di `log-konser.md`), integrasi `MusicCommandsServer.lua` dengan Kohl's Admin GAGAL TOTAL.
    -   Ditemukan _bug_ kritis pada _cache_ `Logger` V3.
    -   Pengiriman kode manual via _copy-paste_ terbukti rentan _human-error_.
-   **[ALASAN]:**
    -   **(Decision #5):** Kohl's Admin `registerCommand` gagal karena _race condition_ atau _load order_ yang tidak terdokumentasi. Daripada membuang waktu, kita _pivot_ ke 100% kontrol via `OVHL UI`.
    -   **(Decision #7):** Untuk standarisasi dan mencegah _human-error_, semua _code delivery_ AI _wajib_ menggunakan `bash` script dengan _backup_ otomatis.
    -   **(Logger Fix):** `Logger:Info()` harus membaca `Config.Debug.EnableVerboseLogs` secara _real-time_, bukan dari _local cache_.
    -   **(Global Volume):** Menyebabkan _bug desync_ di _client_. Kontrol volume 100% diserahkan ke _client_.
