module(..., package.seeall)


local composer = require( "composer" )
local scene = composer.newScene()
local widget = require "widget"
local gameNetwork = require "gameNetwork"


--------------------------------------------

-- forward declarations and other locals

-- 'onRelease' event listener for playBtn


local backButton
local background
local openFeint

local onlineButton
local leaderboards
local achievements
local openFeintButton

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
	
	
		composer.gotoScene( "menu", "fade" , 100	)
	
		return true	-- indicates successful touch
	end
	
	
		

		local goToLeaderboards = function( event )
		gameNetwork.show( "leaderboards" )
	--x-	openfeint.launchDashboard( "leaderboards" )
	
		end

		local goToAchievements = function( event )
		gameNetwork.show( "achievements" )
	--x-	openfeint.launchDashboard( "achievements" )
		end

		local goToOpenFient = function( event )
			local of_product_key = "s8ro1kmEWfXnP94dt5DwA"
			local of_product_secret = "pqUz19XNti3zvNHpwjc3g93ILaKG2qvYfu3Tqfndk"
			local of_app_id = "451833"
			local display_name = "Gravity Ball"

if gameNetwork then
	if ( of_product_key and of_product_secret ) then
		gameNetwork.init( "openfeint", of_product_key, of_product_secret, displayName, of_app_id )
	else
		local function onComplete( event )
			if 1 == event.index then
				system.openURL( "http://www.openfeint.com/developers" )
			end
		end     
	end
else
	native.showAlert( "gameNetwork", "Library not found!", { "OK" } )   
end
		end
		
	background = display.newImageRect("background.png",480,320)
	background.x =display.contentWidth *0.5
	background.y = display.contentHeight *0.5
	
	openFeint = display.newImageRect("openFeint.png",81,94)
	openFeint.x = display.contentWidth *0.5 + 90
	openFeint.y = display.contentHeight *0.5 -40
	openFeint.rotation = -90
	
	
	
	gameCenter = display.newImageRect("gameCenter.png",74,74)
	gameCenter.x  = display.contentWidth *0.5 -90
	gameCenter.y = display.contentHeight *0.5 -40
	
	onlineButton = display.newImageRect("onlineButton.png",250,100)
	onlineButton.x = display.contentWidth *0.5
	onlineButton.y = display.contentHeight *0.5 -120
	
	leaderboards = widget.newButton{
		label = "Leaderboards ",
		labelColor = { default={255}, over={128} },
		font = "Foo",
		defaultFile = "playButton.png",
		overFile = "playButtonOver.png",
	    width = 175, height = 50,
		labelYOffset = -8,
		
		onRelease = goToLeaderboards	-- event listener function
	}
	leaderboards.x = display.contentWidth*0.5 -90
	leaderboards.y = display.contentHeight* 0.5 + 35
	
	achievements = widget.newButton{
		label="Achievements ",
		labelColor = { default={255}, over={128} },
		font = "Foo",
		defaultFile="playButton.png",
		overFile="playButtonOver.png",
	    width=175, height=50,
		labelYOffset = -8,
		
		onRelease = goToAchievements	-- event listener function
	}
	achievements.x = display.contentWidth*0.5 - 90 
	achievements.y = display.contentHeight*0.5 + 80
	
	openFeintButton = widget.newButton{
		label="OpenFeint ",
		labelColor = { default={255}, over={128} },
		font = "Foo",
		defaultFile="playButton.png",
		overFile="playButtonOver.png",
	    width=175, height=50,
		labelYOffset = -8,
		
		onRelease = goToOpenFient	-- event listener function
	}
	openFeintButton.x = display.contentWidth*0.5 + 90 
	openFeintButton.y = display.contentHeight*0.5 + 57.5
	
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
	group:insert(leaderboards)
	group:insert(achievements)
	group:insert(openFeint)
	group:insert(openFeintButton)
	group:insert(gameCenter)
	group:insert(onlineButton)
	group:insert(backButton)
end

-- Called immediately after scene has moved onscreen:
function scene:enter( event )
	local group = self.view

	-- INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	
end

-- Called when scene is about to move offscreen:
function scene:exit( event )
	local group = self.view
	composer.removeScene(true)
	
	-- INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
	
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