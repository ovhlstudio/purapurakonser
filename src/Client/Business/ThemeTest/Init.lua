-- ThemeTest - Demonstrate Theme System Usage

local ThemeTest = {}

local ClientKernel = require(script.Parent.Parent.Parent.init)
local Logger
local SharedKernel
local Theme

function ThemeTest:Init()
    ClientKernel = require(script.Parent.Parent.Parent.init)
    Logger = ClientKernel:GetModule("Logger")
    SharedKernel = require(game:GetService("ReplicatedStorage").Shared.init)
    Theme = SharedKernel:GetModule("Theme")

    if Theme then
        Logger:Info("ThemeTest", "UI", "Theme system test initialized")
        Logger:Info("ThemeTest", "UI", "Primary color: #B3014F")
        Logger:Info("ThemeTest", "UI", "Background: #200B4B")
        Logger:Info("ThemeTest", "UI", "Secondary: #3F1B77")
    else
        Logger:Error("ThemeTest", "UI", "Theme module not found")
    end
end

return ThemeTest
