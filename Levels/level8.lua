-----------------------------------------------------------------------------------------
module(..., package.seeall)
-- level2.lua
--
-----------------------------------------------------------------------------------------
local widget = require "widget"
local composer = require( "composer" )
local scene = composer.newScene()
require "LevelHelperLoader"

ego = require "ego"
 saveFile = ego.saveFile
loadFile = ego.loadFile

--------------------------------------------
local resumeButton
local skipLevelButton
local levelsButton
local rateMeButton
local scoreText
local gameIsActive = false



local shadeRect
local bestScore
local gameOverDisplay
local restartModule



local pauseButton
local rePlayButton
	
	
local score = 500
local physics = require("physics")

physics.start()

physics.setGravity(1,9.8)
local tableGroup = display.newGroup()

-- forward declarations and other locals


local function doNextLevel( event )
			
				
				
		
		end



local function doRating(event)
if event.phase == "ended" then
local url = "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa"
url = url .. "/wa/viewContentsUserReviews?"
url = url .. "type=Purple+Software&id="
url = url .. "YOU own apple id"-----!!!!!!!--------

system.openURL(url)
end
end


 --***************************************************

	-- saveValue() --> used for saving high score, etc.
	
	--***************************************************
	local saveValue = function( strFilename, strValue )
		-- will save specified value to specified file
		local theFile = strFilename
		local theValue = strValue
		
		local path = system.pathForFile( theFile, system.DocumentsDirectory )
		
		-- io.open opens a file at path. returns nil if no file found
		local file = io.open( path, "w+" )
		if file then
		   -- write game score to the text file
		   file:write( theValue )
		   io.close( file )
		end
	end
	
	--***************************************************

	-- loadValue() --> load saved value from file (returns loaded value as string)
	
	--***************************************************
	local loadValue = function( strFilename )
		-- will load specified file, or create new file if it doesn't exist
		
		local theFile = strFilename
		
		local path = system.pathForFile( theFile, system.DocumentsDirectory )
		
		-- io.open opens a file at path. returns nil if no file found
		local file = io.open( path, "r" )
		if file then
		   -- read all contents of file into a string
		   local contents = file:read( "*a" )
		   io.close( file )
		   return contents
		else
		   -- create file b/c it doesn't exist yet
		   file = io.open( path, "w" )
		   file:write( "0" )
		   io.close( file )
		   return "0"
		end
	end
	
	
		local comma_value = function(amount)
		local formatted = amount
			while true do  
			formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
			if (k==0) then
		  		break
			end
	  	end
		
		return formatted
	end
	




 	
-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:create( event )
	local group = self.view
	
	local Group = display.newGroup()
	



	local function doResume()
	if pauseButton.isActive == false and scoreText.isActive == false and rePlayButton.isActive == false then
	pauseButton.isActive = true
	
	scoreText.isActive = true 

	
	rePlayButton.isActive = true
	transition.to(tableGroup,{time = 100,alpha = 0})
	physics.start()
	
	return true
	end
	end
	
local function doReplay(event)

				storyboard.gotoScene("level2","fade",200)
	return true
	
end
 function doSkip(event)
 currentLevel = loadFile ("currentLevel.txt")

    if tonumber(currentLevel) < 3 then
        saveFile("currentLevel.txt", 3)
    end
				transition.to(tableGroup,{time = 100,alpha = 0})
				storyboard.gotoScene("level3","fade",200)
				
			
	return true
	
end

	local function goToLevels(event)
	
	
	if pauseButton.isActive == false and scoreText.isActive == false and rePlayButton.isActive == false then

 	pauseButton.isActive = true
	
	scoreText.isActive = true 

	
	rePlayButton.isActive = true




	transition.to( tableGroup, { time=100, alpha=0  } )
		
	transition.to( shadeRect, { time=100, alpha=0 } )
	
	
	storyboard.gotoScene( "levelSelect", "fade" , 200	)
	
	
	end

	

	return true
	



end

local function doPause (event)
	if pauseButton.isActive == true and scoreText.isActive == true and rePlayButton.isActive == true then
	
	gameIsActive = false
	
	physics.pause()
	

	
	pauseButton.isActive = false

	
	scoreText.isActive = false 

	
	rePlayButton.isActive = false


	
if not shadeRect then
	 shadeRect = display.newRect( 0, 0, 480, 320 )
		shadeRect:setFillColor( 0, 0, 0, 255 )
		shadeRect.alpha = 0
end
local pauseLabel = display.newImageRect("PauseLabel.png",200,75)
pauseLabel.x = display.contentWidth *0.5
pauseLabel.y = display.contentHeight*0.5 -120
pauseLabel.alpha = 0


gameOverDisplay = display.newImageRect( "table.png",250,400)
gameOverDisplay.x = display.contentWidth *0.5
gameOverDisplay.y = display.contentHeight *0.5
gameOverDisplay.rotation = 90
gameOverDisplay.alpha = 0 

resumeButton = widget.newButton{
		default="ResumeButton.png",
		over="ResumeButtonPressed.png",
		
		
		
		width=150, height=50,
		onRelease = doResume	-- event listener function
	}
	resumeButton.view:setReferencePoint( display.CenterReferencePoint )
	resumeButton.view.x = display.contentWidth *0.5 - 5
	resumeButton.view.y = display.contentHeight * 0.5 - 65
	
skipLevelButton = widget.newButton{
		default="skipLevelButton.png",
		over="skipLevelButtonPressed.png",
		
		
		
		width=175, height=50,
		onRelease = doSkip	-- event listener function
	}
	skipLevelButton.view:setReferencePoint( display.CenterReferencePoint )
	skipLevelButton.view.x = display.contentWidth *0.5 
	skipLevelButton.view.y = display.contentHeight * 0.5 - 20

levelsButton = widget.newButton{
		default="LevelsButton.png",
		over="LevelsButtonPressed.png",
		
		
		
		width=150, height=50,
		onRelease = goToLevels	-- event listener function
	}
	levelsButton.view:setReferencePoint( display.CenterReferencePoint )
	levelsButton.view.x = display.contentWidth *0.5 
	levelsButton.view.y = display.contentHeight * 0.5 + 27


rateMeButton = widget.newButton{
		default="RateButton.png",
		over="RateButtonPressed.png",
		
		
		
		width=175, height=50,
		onRelease = doRating	-- event listener function
	}
	rateMeButton.view:setReferencePoint( display.CenterReferencePoint )
	rateMeButton.view.x = display.contentWidth *0.5 
	rateMeButton.view.y = display.contentHeight * 0.5 + 72
	
	
	
	tableGroup:insert(shadeRect)
	tableGroup:insert(gameOverDisplay)
	tableGroup:insert(resumeButton.view)
	tableGroup:insert(skipLevelButton.view)
	tableGroup:insert(levelsButton.view)
	tableGroup:insert(rateMeButton.view)
	tableGroup:insert(pauseLabel)
	
	tableGroup.alpha = 1
	
transition.to( shadeRect, { time=200, alpha=0.65 } )
transition.to( gameOverDisplay, { time=200, alpha=1 } )
transition.to( pauseLabel, { time=200, alpha=1 })
end
end


	
	
	
	local background = display.newImageRect("background.png",480,320)
	background.x = display.contentWidth *0.5
	background.y = display.contentHeight *0.5

	
	
	
	scoreText = display.newRetinaText("Score:"..score,0,0,"Foo",15)
	scoreText.x = display.contentWidth *0.5 +140
	scoreText.y = display.contentHeight * 0.5 -140
	scoreText:setTextColor(0,0,0)
	
 	pauseButton = widget.newButton{
		default="pauseButton.png",
		over="pauseButtonPressed.png",
		
		
		
		width=32, height=32,
		onRelease = doPause	-- event listener function
	}
	pauseButton.view:setReferencePoint( display.CenterReferencePoint )
	pauseButton.view.x = display.contentWidth *0.5 - 220
	pauseButton.view.y = display.contentHeight * 0.5 - 140
	
	
	rePlayButton = widget.newButton{
		default="replayButton.png",
		over="replayButtonPressed.png",
		
		
		
		width=32, height=32,
		onRelease = doReplay	-- event listener function
	}
	rePlayButton.view:setReferencePoint( display.CenterReferencePoint )
	rePlayButton.view.x = display.contentWidth *0.5 -180
	
	rePlayButton.view.y = display.contentHeight * 0.5 - 140

	
 	
 	
 	
 	
 	
 	
 	group:insert(background)
	application.LevelHelperSettings.directorGroup = group
	Loader = LevelHelperLoader:initWithContentOfFile("Level8.plhs")
	Loader:instantiateObjects(physics)
 	group:insert(scoreText)
 	group:insert(rePlayButton.view)
	group:insert(pauseButton.view)
	
	
	
	
	
	
end


-- Called immediately after scene has moved onscreen:
function scene:enter( event )
	local group = self.view
	
	
	physics.start()


		pauseButton.isActive = true

	
	scoreText.isActive = true

	
	rePlayButton.isActive = true
	
end

-- Called when scene is about to move offscreen:
function scene:exit( event )
	local group = self.view
	
	storyboard.purgeScene( "level8")
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroy( event )
	local group = self.view
	
	if pauseButton then
		pauseButton:removeSelf()	-- widgets must be manually removed
		pauseButton = nil
	end
	if rePlayButton then
		rePlayButton:removeSelf()	-- widgets must be manually removed
		rePlayButton = nil
	end
	if shadeRect then
		--shadeRect:removeSelf()
		display.remove( shadeRect )
		shadeRect = nil
	end		
	if resumeButton then
		resumeButton:removeSelf()
		resumeButton = nil
	end
	if restartButton then 
		restartButton:removeSelf()
		resumeButton = nil
	end
	if levelsButton then 
		levelsButton:removeSelf()
		levelsButton = nil
	end
	if rateMeButton then 
		rateMeButton:removeSelf()
		rateMeButton = nil
	end
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "create", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enter", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exit", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene