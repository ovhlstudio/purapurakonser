-- TopbarIntegration Service
-- Integrasi dengan TopbarPlus V3 untuk navbar

local TopbarIntegration = {}

-- Cache modules (akan di-assign di Init)
local Logger
local ClientKernel

function TopbarIntegration:Init()
    -- Get Kernel dan dependencies
    ClientKernel = require(script.Parent.Parent.Parent.init)
    Logger = ClientKernel:GetModule("Logger")

    -- Load TopbarPlus Icon module dari ReplicatedStorage
    local success, Icon = pcall(function()
        return require(game:GetService("ReplicatedStorage").TopbarPlus.Icon)
    end)

    if not success then
        Logger:Error("TopbarIntegration", "UI", "Failed to load TopbarPlus Icon")
        return
    end

    self:CreateMusicIcon(Icon)

    Logger:Info("TopbarIntegration", "UI", "Topbar Integration Initialized")
end

function TopbarIntegration:CreateMusicIcon(Icon)
    -- Create music icon dengan TopbarPlus
    self.musicIcon = Icon.new()
        :setLabel("Music Player")
        :setTooltip("Open Music Control Panel")
        :bindEvent("selected", function()
            self:OnMusicIconClicked()
        end)

    Logger:Debug("TopbarIntegration", "UI", "Music icon created")
end

function TopbarIntegration:OnMusicIconClicked()
    Logger:Info("TopbarIntegration", "UI", "Music icon clicked")

    -- Get UIModule untuk toggle music panel
    local UIModule = ClientKernel:GetModule("UIModule")
    if UIModule then
        UIModule:ToggleMusicPanel()
    else
        Logger:Warn("TopbarIntegration", "UI", "UIModule not found - UI System not ready")
    end
end

return TopbarIntegration
