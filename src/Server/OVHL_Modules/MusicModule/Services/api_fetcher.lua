-- src/Server/OVHL_Modules/MusicModule/Services/api_fetcher.lua
local ApiFetcher = {}
ApiFetcher.ClassName = "ApiFetcher"

local HttpService = game:GetService("HttpService")
local logger

function ApiFetcher:Init(injectedLogger)
    logger = injectedLogger
end

-- 🎯 FUNGSI BARU: Untuk "meratakan" JSON bersarang
local function flattenDatabase(nestedData)
    local flatDatabase = {}

    -- Level 1: Genre (misal: "Dangdut")
    for genreName, subGenres in pairs(nestedData) do
        -- Level 2: SubGenre (misal: "Koplo")
        for subGenreName, songs in pairs(subGenres) do
            -- Level 3: Array Lagu
            for _, songData in ipairs(songs) do
                -- 🎯 Menyuntikkan data Genre & SubGenre ke dalam objek lagu
                songData["GENRE"] = genreName
                songData["SUB GENRE"] = subGenreName
                table.insert(flatDatabase, songData)
            end
        end
    end
    return flatDatabase
end

function ApiFetcher:LoadDatabase(config)
    local apiUrl = config.api.jsonDatabaseUrl

    if apiUrl and apiUrl ~= "" then
        logger:Info("MusicModule", "DATA", "Mencoba mengambil database dari API JSON...")
        local success, result = pcall(function()
            return HttpService:GetAsync(apiUrl)
        end)

        if success then
            local decodedSuccess, data = pcall(function()
                return HttpService:JSONDecode(result)
            end)

            if decodedSuccess and type(data) == "table" then
                -- 🎯 LOGIC BARU: Panggil fungsi 'flatten'
                local flatDatabase = flattenDatabase(data)
                logger:Info("MusicModule", "DATA", "BERHASIL! " .. #flatDatabase .. " lagu dimuat dari API (setelah diratakan).")
                return flatDatabase
            else
                logger:Error("MusicModule", "DATA", "Gagal me-decode JSON dari API. Menggunakan fallback.", data)
            end
        else
            logger:Error("MusicModule", "DATA", "Gagal memanggil API HTTP. Menggunakan fallback.", result)
        end
    else
        logger:Warn("MusicModule", "DATA", "API URL kosong.")
    end

    -- Fallback
    logger:Info("MusicModule", "DATA", "Memuat database fallback...")
    local fallbackDatabase = config.fallbackDatabase
    if #fallbackDatabase > 0 then
        logger:Info("MusicModule", "DATA", "Berhasil memuat " .. #fallbackDatabase .. " lagu dari fallback.")
        return fallbackDatabase
    end

    logger:Error("MusicModule", "FATAL", "Database API dan Fallback gagal dimuat!")
    return nil
end

return ApiFetcher
