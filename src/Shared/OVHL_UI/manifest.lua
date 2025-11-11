-- src/Shared/OVHL_UI/manifest.lua
-- Stub modul untuk UI Design System (Fase 3)
local OVHL_UI = {}

function OVHL_UI:SetKernel(k)
    self.Kernel = k
end

function OVHL_UI:Init()
    local logger = self.Kernel:GetModule("Logger")
    logger:Info("OVHL_UI", "SYSTEM", "OVHL_UI Module Initialized (Stub)")
end

-- API Placeholder untuk UIManager
function OVHL_UI:RenderModule(moduleName, moduleConfig)
    -- Logika rendering akan ada di Fase 3
end

return OVHL_UI
