local composer = require( "composer" )
local scene = composer.newScene()
local facebook = require( "facebook" )
local rate = require("rate")

local settingsLoader = require "settingsloader"

-- include Corona's "widget" library
local widget = require "widget"
local util = require "util"

local facebookAppId = "432126356925184"

local playerScore

local function facebookListener(event)
    if (event.type == "session") then
        if ("login" == event.phase) then
            facebook.showDialog("apprequests", {title="You can't beat that!", message=string.format("I got %d points in Race in the Line", playerScore)})
        end
    end
end

local function onRetryPressed(event)
    composer.hideOverlay("slideUp", 200)
end

local function onSharePressed(event)
    facebook.login(facebookAppId, facebookListener, {"publish_actions"})
end

local function onRatePressed(event)
    local appleId = "886118322"
    local androidId = "com.almlof.raceintheline"
    rate.openStoreUrl(appleId, androidId)
end

function scene:create( event )
	local sceneGroup = self.view
    playerScore = event.params.score
    
    local background = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, 640, display.contentHeight)
    util.setFillRGB(background, 0, 0, 0)
    background.alpha = 0.65

    local backgroundImage = display.newImage(sceneGroup, "game_over_background.png")
    backgroundImage.x = display.contentCenterX
    backgroundImage.y = display.contentCenterY

    display.newText
    {
        parent = sceneGroup,
        x = display.contentCenterX - 160,
        y = display.contentCenterY + 15,
        text = string.format("%d", playerScore),
        font = "BebasNeue",
        fontSize = 38
    }

    local settings = settingsLoader.loadTable("settings.json")
    local highScore = settings.highScore

    if playerScore > highScore then
        highScore = playerScore
        settings.highScore = highScore
        settingsLoader.saveTable(settings, "settings.json")
    end

    display.newText
    {
        parent = sceneGroup,
        x = display.contentCenterX + 160,
        y = display.contentCenterY + 15,
        text = string.format("%d", highScore),
        font = "BebasNeue",
        fontSize = 38
    }

    local retryBackground = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY + 150, 420, 100)
    util.setFillRGB(retryBackground, 173, 173, 173)

    local shareBackground = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY + 270, 420, 100)
    util.setFillRGB(shareBackground, 173, 173, 173)

    local rateBackground = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY + 390, 420, 100)
    util.setFillRGB(rateBackground, 173, 173, 173)

    local retryButton = display.newText
    {
        x = retryBackground.x,
        y = retryBackground.y,
        text = "Retry",
        font = "BebasNeue",
        fontSize = 54
    }
    util.setFillRGB(retryButton, 218, 218, 218)
    retryButton:addEventListener("touch", onRetryPressed)

    local shareButton = display.newText
    {
        x = shareBackground.x,
        y = shareBackground.y,
        text = "Share",
        font = "BebasNeue",
        fontSize = 54
    }
    util.setFillRGB(shareButton, 218, 218, 218)
    shareButton:addEventListener("touch", onSharePressed)

    local rateButton = display.newText
    {
        x = rateBackground.x,
        y = rateBackground.y,
        text = "Rate",
        font = "BebasNeue",
        fontSize = 54
    }
    util.setFillRGB(rateButton, 218, 218, 218)
    rateButton:addEventListener("touch", onRatePressed)

    sceneGroup:insert(retryButton)
    sceneGroup:insert(shareButton)
    sceneGroup:insert(rateButton)
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
    local parent = event.parent
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
        parent:restartGame()
		-- Called when the scene is now off screen
	end	
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
