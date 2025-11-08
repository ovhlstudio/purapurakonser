-- Client Test Module (Fase 1.4 Validation)

local TestModule = {}

local ClientKernel = require(script.Parent.Parent.Parent.init)
local Logger

function TestModule:Init()
    Logger = ClientKernel:GetModule("Logger")

    if Logger then
        Logger:Info("TestModule", "❓", "TestModule Client Initialized!")
    else
        warn("❌ Client Logger not found in TestModule!")
    end
end

return TestModule
