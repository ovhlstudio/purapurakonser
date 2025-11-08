-- Server Configuration (V4.2 Logger Standard)
-- Decision #8: Multi-Level Logging System

return {
    Debug = {
        -- Global log level (overrides module levels if set)
        GlobalLogLevel = "DEBUG", -- "DEBUG" | "INFO" | "WARN" | "ERROR" | "NONE"

        -- Per-module log levels (optional, overrides global)
        ModuleLevels = {
            MusicModule = "DEBUG",
            ZoneModule = "INFO",
            DataModule = "ERROR",
        },

        -- Performance logging (always separate toggle)
        EnablePerfLogs = false,
    },

    -- Future: Monetization toggles (Fase 6)
    Monetization = {
        EnableSongRequests = false,
        EnableKirimSalam = false
    }
}
