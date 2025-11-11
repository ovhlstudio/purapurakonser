-- src/Server/OVHL_Modules/MusicModule/config.lua
-- 🎯 INI ADALAH KONFIGURASI BACKEND (SERVER-SIDE)
return {
    debug = {
        log_level = "DEBUG"
    },

    -- 🎯 SEMUA LOGIKA GAMEPLAY ADA DI SINI (SESUAI PERMINTAAN ANDA)
    features = {
        -- Fitur Playback
        enableAutoDJ = true,
        enableVoteToSkip = true,
        voteSkipThreshold = 0.51, -- (51% dari total player)

        -- Fitur Monetisasi & Aksi
        enableSongRequest = true,  -- (Request via Asset ID)
        enableShoutOut = true,     -- (Kirim Salam)

        -- 🎯 PERMISSION & BYPASS (SESUAI 00-GAME-DESIGN.MD & DISKUSI)
        permissionBypassRoles = {
            "Creator",
            "OVHL_Admin"
        },

        -- Role yang bisa request lagu (VVIP)
        songRequestRoles = {
            "VVIP"
        },

        -- Role yang bisa kirim salam (VIP)
        shoutOutRoles = {
            "VIP",
            "VVIP"
        }
        -- Catatan: Player biasa bisa menggunakan fitur ini via "Bayar per Aksi"
        -- Logic itu akan ada di MonetizationModule
    },

    api = {
        jsonDatabaseUrl = "https://script.googleusercontent.com/macros/echo?user_content_key=AehSKLi-cz8Yr4FDrmSGklqXfARl176dnn2QSXM-ySFNdgDhjtIvr78ul37F6-zfefk1FKPeZaPgRutzN8jw5ffU--QjIaICXUcYKs-PAoXPjucUtMDAMstdtjTzazL-r8SttkiNI6IbZuusAfPG_pV1dcbEd3WFGHPhq-ebHG9VN60DqAjTEXBPL9BBbPBualTNnC6cHBVlHiFDvEHO5zkOagCTLL-nriwH3QVDhinRLkA1fDjqcrAzFG24EKd39i4huP3Qd0TlFjoVQr3_imuVxjyX0TLGQ_GEoek2H5IX&lib=MNM0TGyeKFjzqL0r2EtgJqWvoM8vupKNJ"
    },

    fallbackDatabase = {
        {
            ["ASET ID"] = 116793331819089,
            ["JUDUL LAGU"] = "Laksmana Raja Dilaut (FALLBACK)",
            ["ARTIS"] = "Iyeth Bustami",
            ["GENRE"] = "Orchestra",
            ["SUB GENRE"] = "Metal Cover",
            ["PLACEMENT"] = "GLOBAL",
            ["ART IMAGE ID"] = 98797816117498
        }
    }
}
