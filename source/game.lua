local RevMob = require("revmob")
local composer = require( "composer" )
local scene = composer.newScene()

local settingsLoader = require "settingsloader"

-- include Corona's "widget" library
local widget = require "widget"
local util = require "util"

local physics = require("physics")
physics.start()
physics.setGravity(0, 0)

local PATH_COUNT = 15
local INITIAL_PATH_INDEX = 0

local INITIAL_SCROLL_SPEED = 4
local MAX_SCROLL_SPEED = 7
local SCROLL_SPEED_DELTA = 0.002

local scrollSpeed = INITIAL_SCROLL_SPEED

local gameGroup
local currentPath
local nextPath
local score

local paths = {}

local player

local currentScoreLabel

local initialPath
local banner 
local dieSound
local tyresSound
local bestScore

local prevX

local function getRandomPathIndex()
    local index = math.random(PATH_COUNT)
    if index == currentPath.index then
        if index == PATH_COUNT then
            index = index - 1
        else
            index = index + 1
        end
    end
    return index
end

local function chooseAndPlaceNextPath()
    currentY = currentPath.y
    nextPath = paths[getRandomPathIndex()]
    nextPath.x = display.contentCenterX 
    nextPath.y = currentY - nextPath.contentHeight + 5
    nextPath.isVisible = true
end

local function moveBackground(event)
    if currentPath.contentBounds.yMin >= display.contentHeight then
        currentPath.isVisible = false
        currentPath = nextPath
        chooseAndPlaceNextPath()
    end
    scrollSpeed = math.min(scrollSpeed + SCROLL_SPEED_DELTA, MAX_SCROLL_SPEED)
    currentPath:translate(0, scrollSpeed) 
    nextPath:translate(0, scrollSpeed) 
    score = score + 0.4
    currentScoreLabel.text = string.format("%d", score)
end

local function playerTouchListener(event)
    if event.phase == "began" then
        prevX = event.x
    end
    if event.phase == "moved" then
        difference = event.x - prevX
        if difference > 7 then
            player.rotation = 30
        elseif difference < -7 then
            player.rotation = -30
        else
            player.rotation = 0
        end
        player.x = player.x + difference 
        prevX = event.x
    end
    if event.phase == "ended" then
        player.rotation = 0
    end
    return true
end

local function revMobListener(event)
    local eventType = event.type
    if eventType == "adNotReceived" or eventType == "adClicked" or eventType == "adClosed" then
    end

end

local function onGameOver()
    banner:hide()
    player:removeEventListener("collision", player)
    Runtime:removeEventListener("enterFrame", moveBackground)
    Runtime:removeEventListener("touch", playerTouchListener)
    audio.play(dieSound)
    system.vibrate()
    composer.showOverlay("gameOver", {
        effect = "slideDown",
        isModal = true,
        time = 200,
        params = {
            score = score
        }
    })
end

local function onBallCollision(self, event)
    if (event.phase == "began") then
        onGameOver()
    end
end


local function createPath(pathNumber)
    local physicsData = (require ("path_"..pathNumber)).physicsData(scaleFactor)
    local path = display.newImage(gameGroup, string.format("path_%d.png", pathNumber))
    path.x = 5000
    path.y = 5000
    path.isVisible = false
    physics.addBody( path, physicsData:get("path_"..pathNumber) )
    path.index = pathNumber
    return path
end

function scene:restartGame()
    banner:show()
    local settings = settingsLoader.loadTable("settings.json")
    local highScore = settings.highScore
    bestScore.text = string.format("Best: %d", highScore)
    for index, path in ipairs(paths) do 
        path.isVisible = false
        path.x = 5000
        path.y = 5000
    end
    scrollSpeed = INITIAL_SCROLL_SPEED
    score = 0
    currentPath = initialPath
    currentPath.x = display.contentCenterX 
    currentPath.y = display.contentCenterY
    currentPath.isVisible = true

    player.x = display.contentCenterX 
    player.y = display.contentCenterY + 30
    player.rotation = 0
    chooseAndPlaceNextPath()
    Runtime:addEventListener( "enterFrame", moveBackground )
    Runtime:addEventListener("touch", playerTouchListener)
    player:addEventListener("collision", player)
    audio.play(tyresSound)
end


function scene:create( event )
	local sceneGroup = self.view
    gameGroup = display.newGroup()
    sceneGroup:insert(gameGroup)

    score = 0
    local background = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)

    util.setFillRGB(background, 0, 0, 0)
    gameGroup:insert(background)

    for i = 1, PATH_COUNT do
        path = createPath(i)
        table.insert(paths, path)
    end

    currentPath = createPath(INITIAL_PATH_INDEX)
    currentPath.x = display.contentCenterX 
    currentPath.y = display.contentCenterY
    currentPath.isVisible = true
    initialPath = currentPath
    chooseAndPlaceNextPath()

    player = display.newImage("car.png")
    player.x = display.contentCenterX 
    player.y = display.contentCenterY + 30
    physics.addBody(player, "dynamic", {radius=5})
    player.isBullet = true
    sceneGroup:insert(player)
    player.collision = onBallCollision
    player:addEventListener("collision", player)

    local hudGroup = display.newGroup()
    
    local scoreBox = display.newImage(hudGroup, "score_box.png")
    scoreBox.x = display.contentCenterX
    scoreBox.y = 0

    currentScoreLabel = display.newText(hudGroup, string.format("%d", score), display.contentCenterX, 18, "BebasNeue", 32)
    util.setFillRGB(currentScoreLabel, 255, 255, 255)
    local settings = settingsLoader.loadTable("settings.json")
    local highScore = settings.highScore
    bestScore = display.newText(hudGroup, string.format("Best: %d", highScore), display.contentCenterX, 48, "BebasNeue", 18)
    util.setFillRGB(bestScore, 255, 255, 255)

    local hintRectangle = display.newRect(hudGroup, display.contentCenterX, display.viewableContentHeight - 140, display.viewableContentHeight, 120)
    util.setFillRGB(hintRectangle, 163, 163, 163)
    hintRectangle.alpha = 0.75

    local leftArrows = display.newImage(hudGroup, "arrows_left.png")
    leftArrows.x = 50
    leftArrows.y = hintRectangle.y

    local rightArrows = display.newImage(hudGroup, "arrows_right.png")
    rightArrows.x = display.contentWidth - 50
    rightArrows.y = hintRectangle.y

    local options = {
        parent = hudGroup,
        text = "SLIDE YOUR FINGER",
        x = display.contentCenterX,
        y = hintRectangle.y,
        font = "BebasNeue",
        fontSize = 42,
        align = "center"}
    local hintText = display.newText(options)
    util.setFillRGB(hintText, 255, 255, 255)
    hintText.alpha = 0.75

    sceneGroup:insert(hudGroup)
    banner = RevMob.createBanner({x= display.contentCenterX, y = display.contentHeight - 40})
    dieSound = audio.loadSound( "sound/gameover.wav" )
    tyresSound = audio.loadSound( "sound/tyres.wav" )
    Runtime:addEventListener( "enterFrame", moveBackground )
    Runtime:addEventListener("touch", playerTouchListener)
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
        audio.play(tyresSound)
        banner:show()
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
        banner:hide()
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
    banner:release()
	
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
