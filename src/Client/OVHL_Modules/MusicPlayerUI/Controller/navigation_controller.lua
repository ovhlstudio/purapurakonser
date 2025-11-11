-- src/Client/OVHL_Modules/MusicPlayerUI/Controller/navigation_controller.lua
local NavigationController = {}
NavigationController.ClassName = "NavigationController"
local logger, ui
function NavigationController:Init(injectedLogger, uiComponents)
    logger = injectedLogger
    ui = uiComponents
end
function NavigationController:SetupInitialState()
    if not ui.now_playing_page then
        logger:Error("MusicPlayerUI", "STATE", "now_playing_page tidak ditemukan oleh UIManager!")
        return
    end
    ui.now_playing_page.Visible = true
    if ui.page_container then ui.page_container.Visible = false end
    if ui.content_frame then
        for _, page in ipairs(ui.content_frame:GetChildren()) do
            if page:IsA("Frame") then page.Visible = false end
        end
    end
    logger:Info("MusicPlayerUI", "UI", "State awal diatur: NowPlayingPage.")
end
function NavigationController:NavigateTo(pageKey)
    logger:Info("MusicPlayerUI", "NAV", "Navigasi ke: " .. pageKey)
    if not ui.now_playing_page or not ui.page_container or not ui.content_frame or not ui.header_text then
        logger:Error("MusicPlayerUI", "NAV", "Komponen UI inti navigasi hilang!")
        return
    end
    ui.now_playing_page.Visible = false
    ui.page_container.Visible = false
    for _, page in ipairs(ui.content_frame:GetChildren()) do
        if page:IsA("Frame") then page.Visible = false end
    end
    if pageKey == "now_playing_page" then
        ui.now_playing_page.Visible = true
        ui.header_text.Text = "Now Playing"
    else
        ui.page_container.Visible = true
        if ui[pageKey] then
            ui[pageKey].Visible = true
            local header = string.gsub(pageKey, "_page", "")
            header = string.upper(string.sub(header, 1, 1)) .. string.sub(header, 2)
            ui.header_text.Text = header
        else
            logger:Warn("MusicPlayerUI", "NAV", "Halaman tidak ditemukan: " .. pageKey)
            ui.now_playing_page.Visible = true
            ui.header_text.Text = "Now Playing"
        end
    end
end
return NavigationController
