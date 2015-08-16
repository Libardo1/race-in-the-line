local settingsLoader = require("settingsloader")
local settings = settingsLoader.loadTable("settings.json")

local rate = {}

function rate.openStoreUrl(appleId, androidId)
    settings.isRated = true
    settingsLoader.saveTable(settings, "settings.json")
    appStore = system.getInfo("targetAppStore")
    if appStore == "apple" then
        system.openURL( "itms-apps://itunes.apple.com/app/id"..appleId)
    elseif appStore == "google" then
        system.openURL( "market://details?id="..androidId)
    end
end

function rate.showDialog(appleId, androidId)
    local function onDialogPressed(event)
        if "clicked" == event.action then
            local i = event.index
            if 1 == i then
                rate.openStoreUrl(appleId, androidId)
            end
        end
    end

    local alert = native.showAlert( "Rate Race in Line", "Please, rate Race in Line to support it", { "Sure", "Later" }, onDialogPressed )
end

return rate
