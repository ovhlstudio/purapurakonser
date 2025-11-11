-- Client/Core/UIManager/config.lua
-- 🎯 PERBAIKAN: Arsitektur V2. Kamus ini adalah 1-ke-1
-- key (snake_case) -> value (Nama Tepat PascalCase di Studio)
return {
    component_registry = {
        -- Halaman Utama (Kontainer)
        now_playing_page = "NowPlayingPage",
        page_container = "Page",
        content_frame = "ContentFrame",
        loading_page = "LoadingPage",
        library_page = "LibraryPage",
        song_list_page = "SongListPage",
        request_page = "RequestPage",
        shout_out_page = "ShoutOutPage",

        -- Komponen Navigasi
        nav_bar = "NavBar",
        header_text = "HeaderText",
        close_button = "CloseButton",
        search_button = "SearchButton",
        footer_menu = "FooterMenu",
        back_button = "BackButton",
        home_button = "HomeButton",
        menu_button = "MenuButton",
        menu_popup = "MenuPopup",
        menu_button_template = "MenuButtonTemplate",

        -- Komponen Status & Toast
        status_bar = "StatusBar",
        time_label = "TimeLabel",
        toast_container = "ToastContainer",
        toast_label = "ToastLabel",

        -- Halaman NowPlaying
        vinyl_frame = "VinylFrame",
        album_art = "AlbumArt",
        now_playing_title = "SongTitle",
        now_playing_artist = "ArtistGenreSub",
        love_button = "LoveButton",
        equalizer_button = "EqualizerButton",
        queue_scroll_frame = "QueueScrollFrame",
        queue_item_template = "QueueItemTemplate",

        -- Kontrol Media
        media_control_group = "MediaControlGroup",
        prev_button = "PrevButton",
        play_button = "PlayButton",
        next_button = "NextButton",
        vote_skip_button = "VoteSkipButton",
        volume_slider = "VolumeSlider",
        volume_fill = "VolumeFill",
        vol_up_button = "VolUpButton",
        vol_down_button = "VolDownButton",

        -- Halaman Library
        genre_scroll_frame = "GenreScrollingFrame",
        genre_box_template = "GenreBoxTemplate",

        -- Halaman SongList (Reusable)
        song_list_search_box = "SearchBox",
        song_list_scroll_frame = "SongListScrollingFrame",
        song_list_template = "SongListTemplate",

        -- Halaman Request
        request_asset_id_input = "RequestTexBox",
        request_play_now_button = "PlayNowButton",
        request_add_to_queue_button = "AddToQueueButton",

        -- Halaman ShoutOut
        shout_out_input = "ShoutOutTextBox",
        shout_out_send_button = "SendButton"
    }
}
