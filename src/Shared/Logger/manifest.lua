-- Shared/Logger/manifest.lua
local Logger = {}
local globalConfig = nil
local kernel = nil

local LOG_LEVELS = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
}

local GLOBAL_LOG_LEVEL = LOG_LEVELS.INFO -- Default
local moduleLogLevels = {} -- 🎯 KAMUS BARU UNTUK PER-MODULE

function Logger:SetKernel(k)
    kernel = k
end

-- 🎯 FUNGSI BARU: Dipanggil oleh Kernel
function Logger:SetModuleLogLevel(moduleName, levelString)
    local level = LOG_LEVELS[string.upper(levelString)]
    if level then
        moduleLogLevels[moduleName] = level
        -- Kita tidak perlu log ini di level DEBUG
        -- print("[Logger] [SYSTEM] Log level kustom diatur untuk " .. moduleName .. ": " .. levelString)
    else
        self:Warn("Logger", "CONFIG", "Level log tidak valid '" .. levelString .. "' untuk modul " .. moduleName)
    end
end

function Logger:Init(config)
    globalConfig = config
    if globalConfig and globalConfig.debug and globalConfig.debug.global_log_level then
        local levelString = string.upper(globalConfig.debug.global_log_level)
        if LOG_LEVELS[levelString] then
            GLOBAL_LOG_LEVEL = LOG_LEVELS[levelString]
        end
    end
    print("[Logger] [SYSTEM] Logger Initialized. Global Log Level: " .. (globalConfig and globalConfig.debug.global_log_level or "INFO"))
end

local function log(level, moduleName, context, message, ...)
    local levelString = "INFO"
    for k, v in pairs(LOG_LEVELS) do
        if v == level then
            levelString = k
            break
        end
    end

    -- 🎯 LOGIC BARU: Cek level modul dulu, baru global
    local effectiveLogLevel = moduleLogLevels[moduleName] or GLOBAL_LOG_LEVEL

    if level >= effectiveLogLevel then
        local formattedMessage = message
        if select("#", ...) > 0 then
            local args = {...}
            local success, result = pcall(string.format, message, unpack(args))
            if success then
                formattedMessage = result
            else
                formattedMessage = message .. " (format error: " .. tostring(result) .. ")"
            end
        end
        print(string.format("[%s] [%s] [%s] %s", levelString, moduleName, context, formattedMessage))
    end
end

function Logger:Debug(moduleName, context, message, ...)
    log(LOG_LEVELS.DEBUG, moduleName, context, message, ...)
end

function Logger:Info(moduleName, context, message, ...)
    log(LOG_LEVELS.INFO, moduleName, context, message, ...)
end

function Logger:Warn(moduleName, context, message, ...)
    log(LOG_LEVELS.WARN, moduleName, context, message, ...)
end

function Logger:Error(moduleName, context, message, ...)
    log(LOG_LEVELS.ERROR, moduleName, context, message, ...)
end

return Logger
