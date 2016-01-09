-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

background = display.newImageRect("background.png",480,320)
background.x = display.contentWidth *0.5
background.y = display.contentHeight *0.5
-- include the Corona "storyboard" module
local composer = require "composer"

-- load menu screen
composer.gotoScene( "menu" )