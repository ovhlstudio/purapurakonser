-- src/Client/OVHL_Modules/MusicPlayerUI/Services/ui_state.lua
-- File ini bertanggung jawab untuk menghubungkan tombol (State)
local UIState = {}
UIState.ClassName = "UIState"

local logger, network, ui
local navigationController, playbackController
local toggleApi -- 🎯 Variabel lokal untuk menyimpan fungsi ToggleUI

function UIState:Init(deps)
    logger = deps.logger
    network = deps.network
    ui = deps.ui
    navigationController = deps.navigationController
    playbackController = deps.playbackController
    toggleApi = deps.toggleApi -- 🎯 Simpan fungsi ToggleUI
end

function UIState:ConnectButtons()
    -- Navigasi Utama
    if ui.home_button then
        ui.home_button.MouseButton1Click:Connect(function()
            navigationController:NavigateTo("now_playing_page")
        end)
    end

    if ui.close_button then
        ui.close_button.MouseButton1Click:Connect(function()
            if toggleApi then
                toggleApi() -- 🎯 Panggil fungsi ToggleUI internal
            else
                logger:Warn("UIState", "API", "toggleApi tidak ditemukan!")
            end
        end)
    end

    if ui.search_button then
        ui.search_button.MouseButton1Click:Connect(function()
            navigationController:NavigateTo("song_list_page")
        end)
    end

    -- Aksi
    if ui.request_play_now_button then
        ui.request_play_now_button.MouseButton1Click:Connect(function()
            if ui.request_asset_id_input then
                local assetId = ui.request_asset_id_input.Text
                logger:Info("MusicPlayerUI", "REQUEST", "Mengirim PlayNow: " .. assetId)
                network:FireServer("RequestSong", assetId, "PlayNow")
            end
        end)
    end

    -- Volume Lokal
    if ui.vol_up_button then
        ui.vol_up_button.MouseButton1Click:Connect(function()
            playbackController:AdjustVolume("Up")
        end)
    end
    if ui.vol_down_button then
        ui.vol_down_button.MouseButton1Click:Connect(function()
            playbackController:AdjustVolume("Down")
        end)
    end
end

return UIState
