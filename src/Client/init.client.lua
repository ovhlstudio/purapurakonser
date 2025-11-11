-- File ini adalah LOCALSCRIPT, otomatis jalan oleh Rojo
print("PHASE 0: Client Bootstrap...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

-- 1. Load Modul Inti (Urutan WAJIB - JANGAN DIBALIK!)
local sharedConfig = require(Shared.config) -- 🎯 PERBAIKAN: Load shared config
local logger = require(Shared.Logger.manifest)

-- 2. Injeksi Dependensi
logger:Init(sharedConfig) -- 🎯 PERBAIKAN: Kirim config ke Logger

-- 3. Panggil Kernel Utama (ModuleScript)
local kernel = require(script.Core.Kernel.manifest)

-- 4. Mulai 3-Phase Loader (Phase 1, 2, 3)
kernel:Init(sharedConfig, logger) -- Kirim config ke Kernel juga

logger:Info("Bootstrap", "SYSTEM", "PHASE 0: Bootstrap Selesai. Kernel mengambil alih.")
