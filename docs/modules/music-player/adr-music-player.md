**OKE BRO!** Gua buatkan **PROJECT BLUEPRINT** lengkap! 📘

## 🎯 **PROJECT NAME: SMART PLAYER**

```
SMART PLAYER - Intelligent Music System
Version: 1.0
Architecture: Modular + Plug & Play + Auto-Scan
```

## 📁 **FIXED NAMA-NAMA YANG HARUS DIPAKAI:**

### **CORE FRAMES:**

```
ScreenGui
└── SmartPlayer (Frame)
    ├── HeaderSection (Frame)
    │   ├── BackButton (ImageButton)
    │   ├── HeaderText (TextLabel)
    │   └── SearchButton (ImageButton)
    │
    ├── BodySection (Frame)
    │   ├── NowPlayingPage (Frame)
    │   ├── LibraryPage (Frame)
    │   ├── SongListPage (Frame)
    │   ├── RequestPage (Frame)
    │   └── FavoritesPage (Frame)
    │
    ├── FooterSection (Frame)
    │   ├── MenuButton (ImageButton)
    │   ├── HomeButton (ImageButton)
    │   └── BackButton (ImageButton)
    │
    ├── MenuPopup (Frame)
    │   ├── MenuScrollFrame (ScrollingFrame)
    │   └── MenuItemTemplate (Frame)
    │
    └── ToastContainer (Frame)
        └── ToastTemplate (Frame)
```

### **PAGE COMPONENTS (WAJIB):**

**NowPlayingPage:**

-   `VinylFrame`, `AlbumArt`, `SongTitle`, `ArtistGenreSub`
-   `QueueScrollFrame`, `QueueItemTemplate`
-   `PrevButton`, `PlayButton`, `NextButton`
-   `VolDownButton`, `VolumeSlider`, `VolumeFill`, `VolUpButton`
-   `VoteSkipButton`, `LoveButton`, `EqualizerButton`

**LibraryPage:**

-   `GenreScrollFrame`, `GenreCardTemplate`
-   `GenreName`, `SongCount`

**SongListPage:**

-   `SearchBox`, `SongsScrollFrame`, `SongItemTemplate`
-   `PlayButton`, `SongTitle`, `ArtistName`, `GenreLabel`, `AddToQueueButton`

**RequestPage:**

-   `AssetIdInput`, `PreviewButton`, `RequestButton`, `RequestHistory`

**FavoritesPage:**

-   `FavoritesScrollFrame` (pakai SongItemTemplate)

## 🔧 **ARCHITECTURE RULES:**

### **1. AUTO-REGISTER SYSTEM:**

```lua
-- SETUP: Cukup register sekali
SmartPlayer:registerPage("library", libraryPage, "Music Library")

-- PAGE BARU: Tinggal tambah, auto work!
SmartPlayer:registerPage("stats", statsPage, "Statistics")
```

### **2. SMART COLOR SYSTEM:**

```lua
-- Auto color dari nama genre
local color = SmartPlayer:getGenreColor("DANGDUT")
```

### **3. TOAST SYSTEM:**

```lua
-- Notifikasi apapun
SmartPlayer:showToast("Message", "type", duration)
```

### **4. TEXT SCROLL SYSTEM:**

```lua
-- Auto scroll kalau text panjang
SmartPlayer:startTextScroll(textLabel)
```

## 🎮 **CORE MODULES:**

### **MODULE 1: SMART DATA MANAGER**

-   Auto fetch dari Google Sheets API
-   Auto detect genre & lagu baru
-   Auto generate colors
-   Cache system

### **MODULE 2: PLUG & PLAY REGISTRY**

-   Page auto-discovery
-   Navigation auto-generate
-   Menu auto-populate

### **MODULE 3: INTELLIGENT PLAYBACK**

-   Smart queue management
-   Vote to skip dengan timeout
-   Cross-fade between songs
-   Memory management (stop destroyed sounds)

### **MODULE 4: UNIVERSAL TOAST**

-   Position: Top-right stack
-   Types: info, success, warning, error
-   Auto-layout & auto-dismiss

### **MODULE 5: RESPONSIVE LAYOUT**

-   Mobile-first design
-   Adaptive to screen size
-   Consistent spacing

## 📋 **NEXT ACTION ITEMS:**

### **PHASE 1: CORE FRAMEWORK** ✅

-   [ ] SmartPlayer main container
-   [ ] Auto-register system
-   [ ] Page navigation
-   [ ] Toast system

### **PHASE 2: MUSIC ENGINE** 🎵

-   [ ] Smart data fetcher
-   [ ] Playback controller
-   [ ] Queue system
-   [ ] Vote to skip

### **PHASE 3: PAGES** 📱

-   [ ] NowPlaying page
-   [ ] Library page (genre cards)
-   [ ] SongList page (search + list)
-   [ ] Request page
-   [ ] Favorites page

### **PHASE 4: POLISH** ✨

-   [ ] Text scrolling
-   [ ] Smart colors
-   [ ] Animations
-   [ ] Error handling

## 🚀 **SMART FEATURES:**

-   ✅ **Zero Hardcode** - semua data dari API
-   ✅ **Auto Everything** - colors, icons, layout
-   ✅ **Modular** - tambah page/fitur tanpa edit core
-   ✅ **Self-Healing** - error recovery built-in
-   ✅ **Scalable** - handle ratusan lagu & genre

## 💡 **FUTURE EXPANSION IDEAS:**

-   **Social Features**: Party mode, collaborative queues
-   **AI Recommendations**: "Because you listened to X..."
-   **Offline Mode**: Cache recently played
-   **Themes**: Light/dark mode, custom colors
-   **Analytics**: Most played songs, popular genres

**PROJECT SMART PLAYER READY TO BUILD!** 🎉

Simpen blueprint ini, semua harus ikut structure dan naming convention yang udah ditetapin!
