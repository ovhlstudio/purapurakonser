-- ExampleModule - Clean Logger Demo

local ExampleModule = {}

local ServerKernel = require(script.Parent.Parent.Parent.init)
local Logger

function ExampleModule:Init()
    Logger = ServerKernel:GetModule("Logger")

    if Logger then
        -- Demo semua style logging
        Logger:Info("ExampleModule", "SYSTEM", "Clean logger demo")
        Logger:Info("ExampleModule", "Auto-domain detection")
        Logger:Log("ExampleModule", "Simple log message")
        Logger:Quick("ExampleModule", "Quick debug")
        Logger:Info("NewChatModule", "Unknown module - uses fallback")

        Logger:Debug("ExampleModule", "DATA", "DATA_TYPE", "Debug with data", {
            players = 5,
            test = true
        })
    else
        print("❌ Logger not available")
    end
end

return ExampleModule
