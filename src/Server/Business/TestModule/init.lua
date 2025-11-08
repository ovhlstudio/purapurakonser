-- Server Test Module (Fase 1.4 Validation)

local TestModule = {}

local ServerKernel = require(script.Parent.Parent.Parent.init)
local Logger
local Config

function TestModule:Init()
    Logger = ServerKernel:GetModule("Logger")
    Config = ServerKernel:GetModule("Config")

    if Logger then
        Logger:Info("TestModule", "❓", "TestModule Server Initialized!")
        Logger:Debug("TestModule", "DATA", "DATA_TYPE", "Server test debug message", {
            test = true,
            version = "V4.2"
        })
    else
        warn("❌ Logger not found in TestModule!")
    end
end

return TestModule
