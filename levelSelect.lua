-----------------------------------------------------------------------------------------
--
-- levelSelect.lua
--
-----------------------------------------------------------------------------------------

module(..., package.seeall)


local widget = require "widget"
local composer = require( "composer" )
local scene = composer.newScene()
local ego = require "ego"
 saveFile = ego.saveFile
 loadFile = ego.loadFile
--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5
local backButton

local level = {}
 	local function checkForFile ()
        currentLevel = loadFile ("currentLevel.txt")
       if currentLevel == "empty" then
                currentLevel = 1
                saveFile("currentLevel.txt", currentLevel)
        end
end

local function goToLevel (event)
      composer.gotoScene(event.target.scene,"fade",200)
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
	
	local function onBackbuttonRelease()

	composer.gotoScene( "menu", "fade", 200 )
end

	local background = display.newImageRect("background.png",480,320)
	background.x =display.contentWidth *0.5
	background.y = display.contentHeight *0.5
	group:insert( background)
 	 --!!!!do this to make text for retina display

	

	 local levelselect = display.newImageRect("LevelSelect.png",450,100)
 	 
 	 
 		
	--text:setReferencePoint(display.CenterReferencePoint)
	levelselect.x = display.contentWidth*0.5 
	levelselect.y = display.contentHeight *0.5 -130
	group:insert(levelselect)
	





 	backButton= widget.newButton{
		defaultFile="backButton.png",
		overFile= "backButtonPressed.png",
		--remember the width and height for the retina display
		width=38, height=38,
		
		onRelease = onBackbuttonRelease	-- event listener function
	}
	backButton.x = display.contentWidth *0.5/10
	backButton.y = display.contentHeight * 0.93
	group:insert(backButton)

		checkForFile()
	function setupLevels()
        for i = 1, 20 do
                if tonumber(currentLevel) >= i then
                        	level[i] = widget.newButton{
							label=i,
							labelColor = { default={255}, over={128} },
							font = "Foo",
							defaultFile="levelButton.png",
							overFile="levelButton.png",
	   						 width=48, height=48,
								onRelease = goToLevel
												}
							
								level[i].x = i*70 + 30 
								if i >5 and i < 11 then
								level[i].x =(i-5)*70 + 30
								end
								if i > 10 and i<16 then 
								level[i].x =(i-10)*70 + 30
								end			
								if i > 15 and i<=20 then 
								level[i].x =(i-15)*70 + 30
								end
								
								if i < 6 and i > 0 then 
								level[i].y =  100
								elseif i > 5 and i < 11 then 
								level[i].y =  150 
								elseif i > 10 and i < 16 then 
								level[i].y =  200
								elseif i > 15 and i <= 20  then 
								level[i].y =  250
								end
								level[i].scene = "level"..i..""
					group:insert(level[i])
                elseif tonumber(currentLevel) < i then
                       level[i] = widget.newButton{
							
							defaultFile="lockButton.png",
						
	   						 width=48, height=48,
								
												}
								
								level[i].x = i*70 + 30 
								if i >5 and i < 11 then
								level[i].x =(i-5)*70 + 30
								end
								if i > 10 and i<16 then 
								level[i].x =(i-10)*70 + 30
								end			
								if i > 15 and i<=20 then 
								level[i].x =(i-15)*70 + 30
								end
								
								if i < 6 and i > 0 then 
								level[i].y =  100
								elseif i > 5 and i < 11 then 
								level[i].y =  150 
								elseif i > 10 and i < 16 then 
								level[i].y =  200
								elseif i > 15 and i <= 20  then 
								level[i].y =  250
								end
								--level[i].scene = "level"..i..""
                       group:insert(level[i])
                end
        end
end

setupLevels()
		

	
end

-- Called immediately after scene has moved onscreen:
function scene:enter( event )
	local group = self.view

	
	
	
 
-----------------------------
end

-- Called when scene is about to move offscreen:
function scene:exit( event )
	local group = self.view
	--[[if level[i] then
	for i = 1,20 do
	level[i]:removeSelf()
	level[i] = nil
	end
end]]
composer.remoteScene(true)
end
-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroy( event )
	local group = self.view
	
	
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "create", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterS", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exit", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene