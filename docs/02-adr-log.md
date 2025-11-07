# 📓 02 - ADR LOG (Architecture Decision Log)

**Tujuan:** Dokumen ini adalah arsip (log) dari _setiap_ perubahan keputusan arsitektur. Ini adalah "catatan sejarah" untuk melacak _kenapa_ `01-ADR-FINAL.md` diubah. Log terbaru selalu di atas.

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
