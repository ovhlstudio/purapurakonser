-- src/Shared/Network/manifest.lua
-- Implementasi Penuh Auto-Discovery Network System (Decision #19.1)
local Network = {}
Network.Events = {}
Network.Functions = {}

local Kernel = nil
local logger = nil

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local isServer = RunService:IsServer()
local localPlayer = not isServer and game:GetService("Players").LocalPlayer

-- 🎯 Container untuk semua event
local eventContainer = ReplicatedStorage:FindFirstChild("OVHL_NetworkEvents")
if not eventContainer then
    eventContainer = Instance.new("Folder")
    eventContainer.Name = "OVHL_NetworkEvents"
    eventContainer.Parent = ReplicatedStorage
end

function Network:SetKernel(k)
    Kernel = k
end

function Network:Init()
    logger = Kernel:GetModule("Logger")

    -- Auto-discovery hanya boleh jalan SETELAH semua modul lain di-load
    -- Tapi SEBELUM modul lain mulai menggunakannya.
    -- Init() (Phase 3) adalah tempat yang tepat.
    self:AutoDiscoverEvents()

    logger:Info("Network", "SYSTEM", "Network Module Initialized (Full Auto-Discovery)")
end

-- 🎯 Fungsi Auto-Discovery (Decision #19.1)
function Network:AutoDiscoverEvents()
    logger:Info("Network", "DISCOVERY", "Memulai auto-discovery network events...")
    local registeredCount = 0

    -- Gunakan :GetAllModules() yang baru kita tambahkan ke Kernel
    local allModules = Kernel:GetAllModules()

    for moduleName, module in pairs(allModules) do
        if type(module.GetNetworkEvents) == "function" then
            local events = module:GetNetworkEvents()
            if events then
                logger:Debug("Network", "DISCOVERY", "Modul '" .. moduleName .. "' mengumumkan " .. #events .. " event.")
                self:RegisterEvents(events)
                registeredCount = registeredCount + #events
            end
        end
    end

    logger:Info("Network", "DISCOVERY", "Auto-discovery selesai. Total " .. registeredCount .. " event ter-register.")
end

-- 🎯 Fungsi Registrasi Internal
function Network:RegisterEvents(eventList)
    for _, eventInfo in ipairs(eventList) do
        local eventName = eventInfo.name
        local isFunction = eventInfo.type == "Function"

        local registry = isFunction and self.Functions or self.Events
        local instanceType = isFunction and "RemoteFunction" or "RemoteEvent"

        if not registry[eventName] then
            local eventInstance = eventContainer:FindFirstChild(eventName)
            if not eventInstance then
                if isServer then
                    eventInstance = Instance.new(instanceType)
                    eventInstance.Name = eventName
                    eventInstance.Parent = eventContainer
                    logger:Debug("Network", "REGISTER", "Event baru dibuat di Server: " .. eventName)
                else
                    logger:Debug("Network", "REGISTER", "Menunggu event Server: " .. eventName)
                    eventInstance = eventContainer:WaitForChild(eventName, 30)
                end
            end

            if eventInstance then
                registry[eventName] = eventInstance
            else
                logger:Error("Network", "REGISTER", "Gagal mendaftarkan event: " .. eventName .. " (Timeout?)")
            end
        end
    end
end

-- === API PUBLIK ===

-- 🎯 API SISI SERVER
function Network:FireClient(eventName, player, ...)
    if not isServer then return logger:Warn("Network", "API", "FireClient hanya bisa dipanggil dari Server") end
    local event = self.Events[eventName]
    if event then
        event:FireClient(player, ...)
    else
        logger:Warn("Network", "API", "Mencoba FireClient event yang tidak terdaftar: " .. eventName)
    end
end

function Network:FireAllClients(eventName, ...)
    if not isServer then return logger:Warn("Network", "API", "FireAllClients hanya bisa dipanggil dari Server") end
    local event = self.Events[eventName]
    if event then
        event:FireAllClients(...)
    else
        logger:Warn("Network", "API", "Mencoba FireAllClients event yang tidak terdaftar: " .. eventName)
    end
end

function Network:OnServerEvent(eventName, callback)
    if not isServer then return logger:Warn("Network", "API", "OnServerEvent hanya bisa dipanggil dari Server") end
    local event = self.Events[eventName]
    if event then
        return event.OnServerEvent:Connect(callback)
    else
        logger:Warn("Network", "API", "Mencoba OnServerEvent event yang tidak terdaftar: " .. eventName)
    end
end

-- 🎯 API SISI CLIENT
function Network:FireServer(eventName, ...)
    if isServer then return logger:Warn("Network", "API", "FireServer hanya bisa dipanggil dari Client") end
    local event = self.Events[eventName]
    if event then
        event:FireServer(...)
    else
        logger:Warn("Network", "API", "Mencoba FireServer event yang tidak terdaftar: " .. eventName)
    end
end

function Network:OnClientEvent(eventName, callback)
    if isServer then return logger:Warn("Network", "API", "OnClientEvent hanya bisa dipanggil dari Client") end
    local event = self.Events[eventName]
    if event then
        return event.OnClientEvent:Connect(callback)
    else
        logger:Warn("Network", "API", "Mencoba OnClientEvent event yang tidak terdaftar: " .. eventName)
    end
end

-- TODO: Implementasi RemoteFunction (InvokeServer, OnServerInvoke, etc.)

return Network
