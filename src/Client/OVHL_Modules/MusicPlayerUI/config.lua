-- src/Client/OVHL_Modules/MusicPlayerUI/config.lua
-- 🎯 HYBRID PATTERN: Metadata di config, logic di GetTopbarConfig()
return {
    debug = {
        log_level = "DEBUG"
    },

    -- 🎯 TOPBAR METADATA (Static Config)
    topbar = {
        name = "MusicPlayer",
        icon = "rbxassetid://1300013920",
        tip = "Buka Music Player (OVHL)"
        -- NOTE: toggleApiName tidak perlu, convention adalah "ToggleUI"
    },

    features = {
        showLibraryPage = true,
        showRequestPage = true,
        showShoutOutPage = true,
        showFavoritesPage = true,
        showVoteSkipButton = true,
        showLoveButton = true,
        showEqualizerButton = false
    },

    ui = {
        mode = "StarterGui",
        screen_gui = "MusicPanel",

        components = {
            now_playing_page = "Frame",
            page_container = "Frame",
            content_frame = "Frame",
            loading_page = "Frame",
            library_page = "Frame",
            song_list_page = "Frame",
            request_page = "Frame",
            shout_out_page = "Frame",
            nav_bar = "Frame",
            header_text = "TextLabel",
            close_button = "ImageButton",
            search_button = "ImageButton",
            footer_menu = "Frame",
            back_button = "ImageButton",
            home_button = "ImageButton",
            menu_button = "ImageButton",
            menu_popup = "ScrollingFrame",
            menu_button_template = "TextButton",
            status_bar = "Frame",
            time_label = "TextLabel",
            toast_container = "Frame",
            toast_label = "TextLabel",
            vinyl_frame = "Frame",
            album_art = "ImageLabel",
            now_playing_title = "TextLabel",
            now_playing_artist = "TextLabel",
            love_button = "ImageButton",
            equalizer_button = "ImageButton",
            queue_scroll_frame = "ScrollingFrame",
            queue_item_template = "Frame",
            media_control_group = "Frame",
            prev_button = "ImageButton",
            play_button = "ImageButton",
            next_button = "ImageButton",
            vote_skip_button = "ImageButton",
            volume_slider = "Frame",
            volume_fill = "Frame",
            vol_up_button = "ImageButton",
            vol_down_button = "ImageButton",
            genre_scroll_frame = "ScrollingFrame",
            genre_box_template = "Frame",
            song_list_search_box = "TextBox",
            song_list_scroll_frame = "ScrollingFrame",
            song_list_template = "Frame",
            request_asset_id_input = "TextBox",
            request_play_now_button = "TextButton",
            request_add_to_queue_button = "TextButton",
            shout_out_input = "TextBox",
            shout_out_send_button = "TextButton"
        }
    }
}
