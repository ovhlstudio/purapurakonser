-- File ini adalah SCRIPT, otomatis jalan oleh Rojo
print("PHASE 0: Server Bootstrap...")

-- 1. Load Modul Inti (Urutan WAJIB - JANGAN DIBALIK!)
local config = require(script.config)
local logger = require(game:GetService("ReplicatedStorage").Shared.Logger.manifest)

-- 2. Injeksi Dependensi (Memutus Circular Dependency)
-- Logger sekarang NYALA dan punya akses ke config
logger:Init(config)

-- 3. Panggil Kernel Utama (ModuleScript)
local kernel = require(script.Core.Kernel.manifest)

-- 4. Mulai 3-Phase Loader (Phase 1, 2, 3)
kernel:Init(config, logger)

logger:Info("Bootstrap", "SYSTEM", "PHASE 0: Bootstrap Selesai. Kernel mengambil alih.")
