-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
--

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )
local RevMob = require("revmob")

-- include the Corona "composer" module
local composer = require "composer"

local settingsLoader = require("settingsloader")
local settings = settingsLoader.loadTable("settings.json")

local rate = require("rate")

local REVMOB_IDS = { ["Android"] = "ID", ["iPhone OS"] = "ID" }

local startGame = function()
    local backgroundMusic = audio.loadStream( "sound/background.mp3" )
    audio.play(backgroundMusic, {loops=-1})
    composer.gotoScene( "menu" )
end

local revmobListener = function(event)
    startGame()
end

RevMob.startSessionWithListener(REVMOB_IDS, revmobListener)

local appleId = "886118322"
local androidId = "com.almlof.raceintheline"

local function appRun()
    if settings == nil then
        settings = {}
        settings.runCount = 1
        settings.highScore = 0
        settings.isRated = false
        settingsLoader.saveTable(settings, "settings.json")
    else
        local runCount = settings.runCount
        runCount = runCount + 1
        settings.runCount = runCount
        settingsLoader.saveTable(settings, "settings.json")
        if runCount % 5 == 0 and not settings.isRated then
            rate.showDialog(appleId, androidId)
        end
    end
end

appRun()

