-----------------------------------------------------------------------------------------
module(..., package.seeall)
-- level1.lua
--
-----------------------------------------------------------------------------------------
local widget = require "widget"
local composer = require( "composer" )
local scene = composer.newScene()
require "LevelHelperLoader"
local ego = require "ego"
saveFile = ego.saveFile
loadFile = ego.loadFile

local BezierCurve = require "BezierCurve"

-------------------------------------------

local points = {}
local hasMoved = false
local line
local pointsGroup


local bezierPath = {}

---------------------------------------------
local resumeButton
local skipLevelButton
local levelsButton
local rateMeButton
local scoreText
local gameIsActive = false

 
highscore = loadFile ("highscore.txt")

local shadeRect
local bestScore
local gameIsActive = false
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

------------------------CURVE------------------------------------------
----------------------------------------------------------------------



local function squareDistance(pointA, pointB)
	local dx = pointA.x - pointB.x
	local dy = pointA.y - pointB.y
	return dx*dx + dy*dy
end

-- Returns distance between two points
local function distance(pointA, pointB)
	return math.sqrt(squareDistance(pointA, pointB))
end

-- Returns perpendicular distance from point p0 to line defined by p1,p2
local function perpendicularDistance(p0, p1, p2)
	if (p1.x == p2.x) then
		return math.abs(p0.x - p1.x)
	end
	local m = (p2.y - p1.y) / (p2.x - p1.x) --slope
	local b = p1.y - m * p1.x --offset
	local dist = math.abs(p0.y - m * p0.x - b)
	dist = dist / math.sqrt(m*m + 1)
	return dist
end
	
-- Returns a normalized vector
local function normalizeVector(v)
	local magnitude = distance({x = 0, y = 0}, v)
	return {x = v.x/magnitude, y = v.y/magnitude}
end

-- Simplifies the path by eliminating points that are too close
local function polySimplify(tolerance)
	local newPoints = {}
	table.insert(newPoints, points[1])
	local lastPoint = points[1]
	
	local squareTolerance = tolerance*tolerance
	for i = 2, #points do
		if (squareDistance(points[i], lastPoint) >= squareTolerance) then
			table.insert(newPoints, points[i])
			lastPoint = points[i]
		end
	end
	points = newPoints
	hasMoved = true
end

-- Algorithm to simplify a curve and keep major curve points
local function DouglasPeucker(pts, epsilon)
	--Find the point with the maximum distance
	local dmax = 0
	local index = 0
	for i = 3, #pts do 
		d = perpendicularDistance(pts[i], pts[1], pts[#pts])
		if d > dmax then
			index = i
			dmax = d
		end
	end
	
	local results = {}
	
	--If max distance is greater than epsilon, recursively simplify
	if dmax >= epsilon then
		--Recursive call
		local tempPts = {}
		for i = 1, index-1 do table.insert(tempPts, pts[i]) end
		local results1 = DouglasPeucker(tempPts, epsilon)
		
		local tempPts = {}
		for i = index, #pts do table.insert(tempPts, pts[i]) end
		local results2 = DouglasPeucker(tempPts, epsilon)

		-- Build the result list
		for i = 1, #results1-1 do table.insert(results, results1[i]) end
		for i = 1, #results2 do table.insert(results, results2[i]) end
	else
		for i = 1, #pts do table.insert(results, pts[i]) end
	end
	
	--Return the result
	return results
end



-----------------------------END-----------------------------------------
--------------------------------------------------------------------
local function onSystemEvent ()
 if score > tonumber(highscore) then --We use tonumber as highscore is a string when loaded
 saveFile("highscore.txt", score)
 score =score - 1 
 end
 end


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
	local function updateScore()

	score =score - 1 
end

	local function checkForScore ()
if highscore == "empty" then
	highscore = 0
	saveFile("highscore.txt", highscore)
end
end
	checkForScore()

 
 function plotPoints(event)
	
		if (event.phase == "ended") then
			print("You have started with "..#points.." points.")
		
			
			polySimplify(10)
			print("After polySimplify(10) you have "..#points.." points.")
		for i = 1, 2 do
			local pts = {}
			for i = 1, #points do table.insert(pts, points[i]) end
			local pt = #points
			points = DouglasPeucker(pts, 1)
		
		end
		
			--physics.addBody(line,"dynamic", { density=3.0, friction=0.5, bounce=0.3 })
		else
			local point = {x = event.x, y = event.y}
			table.insert(points, point)
			hasMoved = true
		end

	end


-- Draw new lines every frame
 function drawLines()
	if (hasMoved == false) then
		return true
	end
	hasMoved = false
	
	-- Draw the line
	
	if (line) then line:removeSelf() end
	
	if (#points > 1) then
		line = display.newLine(points[1].x, points[1].y, points[2].x, points[2].y)
		group:insert(line)
		for i = 3, #points do
			line:append(points[i].x, points[i].y)
		end
		line:setColor(0,0,0)
		line.width = 4
	end
	

end

	local function doResume()
		if pauseButton.isEnabled == false and scoreText.isEnabled == false and rePlayButton.isEnabled == false then
		pauseButton.isEnabled = true
		scoreText.isEnabled = true 
		rePlayButton.isEnabled = true
		transition.to(tableGroup,{time = 100,alpha = 0})
		physics.start()
	
		return true
	end
	end
	
	local function doReplay(event)
		composer.gotoScene("level1","fade",200)
		return true
	
	end

	local function doSkip(event)
		currentLevel = loadFile ("currentLevel.txt")
   		if tonumber(currentLevel) < 2 then
     	   saveFile("currentLevel.txt", 2)
   		end
		transition.to(tableGroup,{time = 100,alpha = 0})
		composer.gotoScene("level2","fade",200)			 
		return true
end

	local function goToLevels(event)
	
	
	if pauseButton.isEnabled == false and scoreText.isEnabled == false and rePlayButton.isEnabled == false then
 	pauseButton.isEnabled = true
	scoreText.isEnabled = true 
	rePlayButton.isEnabled = true




	transition.to( tableGroup, { time=100, alpha=0  } )
		
	transition.to( shadeRect, { time=100, alpha=0 } )
	
	
	composer.gotoScene( "levelSelect", "fade" , 200	)
	
	
	end

	

	return true
	



end


local function doPause (event)
	
	if pauseButton.isEnabled == true and scoreText.isEnabled == true and rePlayButton.isEnabled == true then
	physics.pause()
print("fuch you")
	gameIsActive = false
	pauseButton.isEnabled = false
	scoreText.isEnabled = false 
	rePlayButton.isEnabled = false
	
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
		defaultFile="ResumeButton.png",
		overFile="ResumeButtonPressed.png",
		
		
		
		width=150, height=50,
		onRelease = doResume	-- event listener function
	}
	resumeButton.x = display.contentWidth *0.5 - 5
	resumeButton.y = display.contentHeight * 0.5 - 65
	
skipLevelButton = widget.newButton{
		defaultFile="skipLevelButton.png",
		overFile="skipLevelButtonPressed.png",	
		width = 175, height = 50,
		onRelease = doSkip	-- event listener function
	}
	skipLevelButton.x = display.contentWidth *0.5 
	skipLevelButton.y = display.contentHeight * 0.5 - 20

levelsButton = widget.newButton{
		defaultFile = "LevelsButton.png",
		overFile = "LevelsButtonPressed.png",
		
		
		
		width=150, height=50,
		onRelease = goToLevels	-- event listener function
	}
	levelsButton.x = display.contentWidth *0.5 
	levelsButton.y = display.contentHeight * 0.5 + 27


rateMeButton = widget.newButton{
		defaultFile="RateButton.png",
		overFile="RateButtonPressed.png",
		
		
		
		width=175, height=50,
		onRelease = doRating	-- event listener function
	}
	rateMeButton.x = display.contentWidth *0.5 
	rateMeButton.y = display.contentHeight * 0.5 + 72
	
	
	
	tableGroup:insert(shadeRect)
	tableGroup:insert(gameOverDisplay)
	tableGroup:insert(resumeButton)
	tableGroup:insert(skipLevelButton)
	tableGroup:insert(levelsButton)
	tableGroup:insert(rateMeButton)
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

	
	
	
	scoreText = display.newText("Score: "..	
score,0,0,"Foo",15)
	scoreText.x = display.contentWidth *0.5 +140
	scoreText.y = display.contentHeight * 0.5 -140
	scoreText:setTextColor(0,0,0)
	
 	pauseButton = widget.newButton{
		defaultFile="pauseButton.png",
		overFile="pauseButtonPressed.png",
		
		
		
		width=32, height=32,
		onRelease = doPause	-- event listener function
	}
	pauseButton.x = display.contentWidth *0.5 - 220
	pauseButton.y = display.contentHeight * 0.5 - 140
	
	
	rePlayButton = widget.newButton{
		defaultFile = "replayButton.png",
		overFile = "replayButtonPressed.png",
		
		
		
		width=32, height=32,
		onRelease = doReplay	-- event listener function
	}
	rePlayButton.x = display.contentWidth *0.5 -180
	
	rePlayButton.y = display.contentHeight * 0.5 - 140

	
 	
 	
 	
 	
 	
 	
 	group:insert(background)
 	group:insert(scoreText)
 	group:insert(rePlayButton)
	group:insert(pauseButton)
	
	
	timer.performWithDelay(1000, updateScore, 0)
	

	
	
end


-- Called immediately after scene has moved onscreen:
function scene:enter( event )
	local group = self.view
	
	
	physics.start()
	application.LevelHelperSettings.directorGroup = group
	Loader = LevelHelperLoader:initWithContentOfFile("Level1.plhs")
	Loader:instantiateObjects(physics)
	pauseButton.isEnabled = true
	scoreText.isEnabled = true	
	rePlayButton.isEnabled = true
	timer1 = timer.performWithDelay(1000,addtoit,0)

	Runtime:addEventListener( "system", onSystemEvent )
	Runtime:addEventListener("touch", plotPoints)
	Runtime:addEventListener("enterFrame", drawLines)
	
end

-- Called when scene is about to move offscreen:
function scene:exit( event )
	local group = self.view
	
	composer.removeScene()
	Runtime:removeEventListener( "system", onSystemEvent )
	Runtime:removeEventListener("touch", plotPoints)
	Runtime:removeEventListener("enterFrame", drawLines)
	Runtime:removeEventListener("enterFrame", drawLines)
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