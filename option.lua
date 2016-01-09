-----------------------------------------------------------------------------------------
--
-- 
--
-----------------------------------------------------------------------------------------
module(..., package.seeall)


local composer = require( "composer" )
local scene = composer.newScene()
local widget = require "widget"
local ego = require "ego"
saveFile = ego.saveFile
loadFile = ego.loadFile
--------------------------------------------

-- forward declarations and other locals

-- 'onRelease' event listener for playBtn


local backButton
local musicOff = false
local soundOff = false
local musicCheckBox
local musicCheckMark
local soundCheckBox
local soundCheckMark
local resetGameButton



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
	

local function goToMenu()
	
	
	composer.gotoScene( "menu", "fade" , 100 )
	
	return true	-- indicates successful touch
end
local function onComplete( event )
		        if "clicked" == event.action then
		                local i = event.index
		                if 1 == i then
		                        saveFile("currentLevel.txt", 1)
		                elseif 2 == i then
		                        
						
		                end
		
						
		        end
		end
local function doReset()

	local alert = native.showAlert( "Reset Game", "Are you sure you want to reset game?", { "Yes", "No" }, onComplete )
	


return true
end
	
	
	local optionButton = display.newImageRect("optionButton.png",250,100)
	optionButton.x = display.contentWidth *0.5
	optionButton.y = display.contentHeight *0.5 -135
	
	
	local musicSwitch = display.newRetinaText("Music",0,0,"Foo",30)
	musicSwitch:setTextColor(0,0,0)
	musicSwitch.x = display.contentWidth *0.5 - 70
	musicSwitch.y = display.contentHeight *0.5 - 30
	
	local soundSwitch = display.newRetinaText("Sound",0,0,"Foo",30)
	soundSwitch:setTextColor(0,0,0)
	soundSwitch.x = display.contentWidth *0.5 - 70
	soundSwitch.y = display.contentHeight *0.5 + 40
	
	
	local background = display.newImageRect("background.png",480,320)
	background.x =display.contentWidth *0.5
	background.y = display.contentHeight *0.5
	
	musicCheckBox = display.newImageRect("checkbox.png",32,28)
	musicCheckBox.x = display.contentWidth *0.5 + 70
	musicCheckBox.y = display.contentHeight *0.5 - 30
	
	musicCheckMark = display.newImageRect("checkMark.png",35,35)
	musicCheckMark.x = display.contentWidth *0.5 + 72
	musicCheckMark.y = display.contentHeight *0.5 - 35
	
	soundCheckBox = display.newImageRect("checkbox.png",32,28)
	soundCheckBox.x = display.contentWidth *0.5 + 70
	soundCheckBox.y = display.contentHeight *0.5 + 40
	
	soundCheckMark = display.newImageRect("checkMark.png",35,35)
	soundCheckMark.x = display.contentWidth *0.5 + 72
	soundCheckMark.y = display.contentHeight *0.5 + 35
	
		resetGameButton = widget.newButton{
		label = "Reset Game",
		labelColor = { default={255}, over={128} },
		font = "Foo",
		defaultFile="playButton.png",
		overFile="playButtonOver.png",
	    width=175, height=50,
		labelYOffset = -8,
		
		onRelease = doReset	-- event listener function
	}
	resetGameButton.x = display.contentWidth*0.5 
	resetGameButton.y = display.contentHeight *0.5 + 110
	
	
	
	backButton= widget.newButton{
		defaultFile="backButton.png",
		overFile= "backButtonPressed.png",
		--remember the width and height for the retina display
		width=38, height=38,
		
		onRelease = goToMenu	-- event listener function
	}
	backButton.x = display.contentWidth *0.5/10
	backButton.y = display.contentHeight * 0.93
	
	group:insert(background)
	group:insert(musicSwitch)
	group:insert(musicCheckBox)
	group:insert(musicCheckMark)
	group:insert(soundSwitch)
	group:insert(soundCheckBox)
	group:insert(soundCheckMark)
	group:insert(optionButton)
	group:insert(backButton)
	group:insert(resetGameButton)
end

-- Called immediately after scene has moved onscreen:
function scene:enter( event )
	local group = self.view
	
		 function changeMusic (event)
	if event.phase == "ended" then
		if musicOff == true then
			musicOff = false
		musicCheckMark.alpha = 1
		
		elseif musicOff == false then 
		musicOff = true
		musicCheckMark.alpha = 0
		end
	end
	end
	
	 function changeSound (event)
	if event.phase == "ended" then
		if soundOff == true then
			soundOff = false
		soundCheckMark.alpha = 1
		
		elseif soundOff == false then 
		soundOff = true
		soundCheckMark.alpha = 0
		end
	end
	end
	
	musicCheckBox:addEventListener("touch",changeMusic)
	soundCheckBox:addEventListener("touch",changeSound)

	-- INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	
end

-- Called when scene is about to move offscreen:
function scene:exit( event )
	local group = self.view
	musicCheckBox:removeEventListener("touch",changeMusic)
	soundCheckBox:removeEventListener("touch",changeSound)
	
	-- INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
	--storyboard.purgeScene( "option")
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroy( event )
	local group = self.view
	
	 if backButton then
	 background:removeSelf()
	 background = nil
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