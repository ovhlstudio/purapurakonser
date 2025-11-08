-- Client Logger - Clean Version (No Timestamp)

local Logger = {}

local LOG_LEVELS = {
    DEBUG = 1, INFO = 2, WARN = 3, ERROR = 4
}

-- Emoji Mapping
local EMOJI = {
    CLIENT = "💻",
    MUSIC = "🎵", ZONE = "🗺️", UI = "🎨",
    DEBUG = "🔍", INFO = "ℹ️", WARN = "⚠️", ERROR = "💀",
    ANNOUNCE = "📢", DATA_TYPE = "📊", ACTION = "🎬",
    TEST = "🧪", SYSTEM = "⚙️", DEFAULT = "❓"
}

local function detectDomain(moduleName)
    local lowerName = string.lower(moduleName)

    if string.find(lowerName, "music") then return "MUSIC" end
    if string.find(lowerName, "zone") then return "ZONE" end
    if string.find(lowerName, "ui") then return "UI" end
    if string.find(lowerName, "test") then return "TEST" end

    return "DEFAULT"
end

local function getEmoji(emojiKey)
    return EMOJI[emojiKey] or EMOJI.DEFAULT
end

function Logger:Init()
    self:Info("Logger", "SYSTEM", "Client Logger Initialized (Clean)")
end

function Logger:Debug(moduleName, domain, message)
    local actualDomain = domain or detectDomain(moduleName)
    print(string.format("%s %s %s [%s] %s",
        EMOJI.CLIENT, getEmoji(actualDomain),
        EMOJI.DEBUG, moduleName, message))
end

function Logger:Info(moduleName, domain, message)
    local actualDomain = domain or detectDomain(moduleName)
    print(string.format("%s %s %s [%s] %s",
        EMOJI.CLIENT, getEmoji(actualDomain),
        EMOJI.INFO, moduleName, message))
end

function Logger:Error(moduleName, domain, message)
    local actualDomain = domain or detectDomain(moduleName)
    warn(string.format("%s %s %s [%s] %s",
        EMOJI.CLIENT, getEmoji(actualDomain),
        EMOJI.ERROR, moduleName, message))
end

function Logger:Log(moduleName, message)
    local domain = detectDomain(moduleName)
    self:Info(moduleName, domain, message)
end

function Logger:Quick(moduleName, message)
    print(string.format("%s %s %s [%s] %s",
        EMOJI.CLIENT, EMOJI.DEBUG,
        EMOJI.DATA_TYPE, moduleName, message))
end

return Logger
