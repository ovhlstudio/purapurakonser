-- src/Client/Services/AppShell/Controller/topbar_controller.lua
-- Correct TopbarPlus API: setTip + selected/deselected events
local TopbarController = {}
local logger, kernel, config
local Icon

function TopbarController:Init(deps)
    logger = deps.logger
    kernel = deps.kernel
    config = deps.config
    Icon = deps.Icon
end

function TopbarController:AutoDiscoverButtons()
    logger:Info("AppShell", "DISCOVERY", "Memulai auto-discovery tombol TopbarPlus (Hybrid Pattern)...")
    local registeredCount = 0

    local allModules = kernel:GetAllModules()

    for moduleName, module in pairs(allModules) do
        local buttonConfig = nil

        if type(module.GetTopbarConfig) == "function" then
            local success, result = pcall(module.GetTopbarConfig, module)
            if success and result then
                buttonConfig = result
                logger:Debug("AppShell", "DISCOVERY",
                    "Modul '" .. moduleName .. "' mengumumkan via GetTopbarConfig()")
            else
                logger:Warn("AppShell", "DISCOVERY",
                    "GetTopbarConfig() gagal untuk " .. moduleName .. ": " .. tostring(result))
            end
        end

        if not buttonConfig and module.config and module.config.topbar then
            buttonConfig = module.config.topbar
            if not buttonConfig.toggleApiName then
                buttonConfig.toggleApiName = "ToggleUI"
            end
            logger:Debug("AppShell", "DISCOVERY",
                "Modul '" .. moduleName .. "' mengumumkan via config.topbar")
        end

        if buttonConfig then
            local success, err = pcall(function()
                self:CreateButton(moduleName, buttonConfig)
            end)

            if success then
                registeredCount = registeredCount + 1
            else
                logger:Error("AppShell", "CREATE",
                    "Gagal membuat tombol untuk " .. moduleName, err)
            end
        end
    end

    logger:Info("AppShell", "DISCOVERY",
        "Auto-discovery selesai. Total " .. registeredCount .. " tombol TopbarPlus ter-register.")
end

function TopbarController:CreateButton(moduleName, buttonConfig)
    if not buttonConfig.name or not buttonConfig.toggleApiName or not buttonConfig.icon then
        logger:Error("AppShell", "CONFIG",
            "Konfigurasi Topbar tidak valid untuk " .. moduleName ..
            ". 'name', 'icon', & 'toggleApiName' wajib ada.", buttonConfig)
        return
    end

    logger:Debug("AppShell", "CREATE",
        "Creating TopbarPlus icon for " .. moduleName .. "...")

    local success, newIcon = pcall(function()
        return Icon.new()
    end)

    if not success then
        logger:Error("AppShell", "FATAL",
            "Icon.new() gagal untuk " .. moduleName .. "! Error: " .. tostring(newIcon))
        return
    end

    local setSuccess, setErr = pcall(function()
        newIcon:setName(buttonConfig.name)
        newIcon:setImage(buttonConfig.icon)
        if buttonConfig.tip then
            newIcon:setTip(buttonConfig.tip)
        end
    end)

    if not setSuccess then
        logger:Error("AppShell", "FATAL",
            "Gagal set properties untuk icon " .. moduleName .. "! Error: " .. tostring(setErr))
        return
    end

    local connectSuccess, connectErr = pcall(function()
        newIcon.selected:Connect(function()
            logger:Info("AppShell", "EVENT",
                "Tombol " .. moduleName .. " SELECTED!")

            local targetModule = kernel:GetModule(moduleName)
            if targetModule then
                local apiFunction = targetModule[buttonConfig.toggleApiName]
                if type(apiFunction) == "function" then
                    logger:Debug("AppShell", "API",
                        "Memanggil " .. moduleName .. ":" .. buttonConfig.toggleApiName .. "()")

                    local apiSuccess, apiErr = pcall(apiFunction, targetModule)
                    if not apiSuccess then
                        logger:Error("AppShell", "API",
                            "Error calling " .. moduleName .. ":" .. buttonConfig.toggleApiName .. "()", apiErr)
                    end
                else
                    logger:Error("AppShell", "API",
                        "Fungsi '" .. buttonConfig.toggleApiName .. "' tidak ditemukan di modul " .. moduleName)
                end
            else
                logger:Error("AppShell", "FATAL",
                    "Modul '" .. moduleName .. "' tidak ditemukan saat tombol diklik!")
            end
        end)

        newIcon.deselected:Connect(function()
            logger:Info("AppShell", "EVENT",
                "Tombol " .. moduleName .. " DESELECTED!")

            local targetModule = kernel:GetModule(moduleName)
            if targetModule then
                local apiFunction = targetModule[buttonConfig.toggleApiName]
                if type(apiFunction) == "function" then
                    pcall(apiFunction, targetModule)
                end
            end
        end)
    end)

    if not connectSuccess then
        logger:Error("AppShell", "FATAL",
            "Gagal connect event untuk " .. moduleName .. "! Error: " .. tostring(connectErr))
        return
    end

    logger:Info("AppShell", "TOPBAR",
        "Tombol '" .. buttonConfig.name .. "' berhasil dibuat dan terhubung ke " ..
        moduleName .. ":" .. buttonConfig.toggleApiName)
end

return TopbarController
