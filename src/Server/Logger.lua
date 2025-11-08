-- Server Logger (V4.2) - Clean Version (No Timestamp)
-- Studio already has timestamp, so we remove duplicate

local Logger = {}
local Config = nil

local LOG_LEVELS = {
    DEBUG = 1, INFO = 2, WARN = 3, ERROR = 4, PERF = 5
}

-- Emoji Mapping
local EMOJI = {
    SERVER = "🖥️", CLIENT = "💻", SHARED = "🔗",
    MUSIC = "🎵", ZONE = "🗺️", DATA = "💾", ADMIN = "👑",
    UI = "🎨", NETWORK = "📡", MONETIZATION = "💰",
    DEBUG = "🔍", INFO = "ℹ️", WARN = "⚠️", ERROR = "💀", PERF = "⚡",
    ANNOUNCE = "📢", DATA_TYPE = "📊", ACTION = "🎬", RESULT = "✅",

    -- Common module fallbacks
    TEST = "🧪", SYSTEM = "⚙️", PLAYER = "👤", GAME = "🎮",
    DEFAULT = "❓"
}

-- Auto-detect domain from module name
local function detectDomain(moduleName)
    local lowerName = string.lower(moduleName)

    if string.find(lowerName, "music") then return "MUSIC" end
    if string.find(lowerName, "zone") then return "ZONE" end
    if string.find(lowerName, "data") then return "DATA" end
    if string.find(lowerName, "ui") then return "UI" end
    if string.find(lowerName, "network") then return "NETWORK" end
    if string.find(lowerName, "monet") then return "MONETIZATION" end
    if string.find(lowerName, "test") then return "TEST" end
    if string.find(lowerName, "player") then return "PLAYER" end

    return "DEFAULT"
end

-- Smart emoji getter with fallback
local function getEmoji(emojiKey)
    return EMOJI[emojiKey] or EMOJI.DEFAULT
end

function Logger:SetConfig(configModule)
    Config = configModule
    self:Info("Logger", "SYSTEM", "Config set successfully")
end

function Logger:Init()
    self:Info("Logger", "SYSTEM", "Logger V4.2 Initialized (Clean Version)")
end

-- ========================
-- CLEAN LOGGING METHODS (NO TIMESTAMP)
-- ========================

function Logger:Debug(moduleName, domain, messageType, message, data)
    local actualDomain = domain or detectDomain(moduleName)
    if not self:_shouldLog(moduleName, "DEBUG") then return end

    print(string.format("%s %s %s [%s] %s",
        getEmoji("SERVER"), getEmoji(actualDomain),
        getEmoji(messageType), moduleName, message))

    if data then
        print("└─ Data:", game:GetService("HttpService"):JSONEncode(data))
    end
end

function Logger:Log(moduleName, message)
    local domain = detectDomain(moduleName)
    self:Info(moduleName, domain, message)
end

function Logger:Quick(moduleName, message)
    print(string.format("%s %s %s [%s] %s",
        getEmoji("SERVER"), getEmoji("DEBUG"),
        getEmoji("DATA_TYPE"), moduleName, message))
end

function Logger:Info(moduleName, domain, message)
    local actualDomain = domain or detectDomain(moduleName)
    if not self:_shouldLog(moduleName, "INFO") then return end

    print(string.format("%s %s %s [%s] %s",
        getEmoji("SERVER"), getEmoji(actualDomain),
        getEmoji("INFO"), moduleName, message))
end

function Logger:Error(moduleName, domain, message, data)
    local actualDomain = domain or detectDomain(moduleName)

    warn(string.format("%s %s %s [%s] %s",
        getEmoji("SERVER"), getEmoji(actualDomain),
        getEmoji("ERROR"), moduleName, message))

    if data then
        warn("└─ Data:", game:GetService("HttpService"):JSONEncode(data))
    end
end

-- Private method
function Logger:_shouldLog(moduleName, level)
    if not Config then return true end

    local globalLevel = LOG_LEVELS[Config.Debug.GlobalLogLevel] or LOG_LEVELS.INFO
    local moduleLevel = Config.Debug.ModuleLevels and Config.Debug.ModuleLevels[moduleName]

    local threshold = moduleLevel and LOG_LEVELS[moduleLevel] or globalLevel
    return LOG_LEVELS[level] >= threshold
end

return Logger
