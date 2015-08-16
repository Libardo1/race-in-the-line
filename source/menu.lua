local composer = require( "composer" )
local scene = composer.newScene()

local widget = require "widget"
local util = require "util"

local function onStartPressed(event)
    composer.gotoScene("game", {
        effect = "fade",
        time = 300
    })
end

function scene:create( event )
	local sceneGroup = self.view
    
    local background = display.newImage(sceneGroup, "start_menu_background.png")
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local buttonBackground = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY + 200, 420, 100)
    util.setFillRGB(buttonBackground, 173, 173, 173)

    local startButton = display.newText 
    {
        parent = sceneGroup,
        x = display.contentCenterX,
        y = display.contentCenterY + 200,
        text = "START",
        font = "BebasNeue",
        fontSize = 60
    }
    util.setFillRGB(startButton, 218, 218, 218)
    startButton:addEventListener("touch", onStartPressed)
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
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
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
