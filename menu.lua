-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------
module(..., package.seeall)


local composer = require( "composer" )
local scene = composer.newScene()

--require("oAuth") 
local ui = require ("ui")
local facebook = require("facebook")
local json = require("json")
local tableView = require("tableView")
promote = require("promote")
local widget = require "widget"
gameNetwork = require "gameNetwork"
 require "analytics"
 require("oAuth") 
--------------------------------------------

-- forward declarations and other locals
local playBtn
local option
local online
local rateIt
local application_key = "UTJG144SD44RAFIHMAAQ"--5H1FM5T9EAZQLNYBGCL6 for lite version
-- 'onRelease' event listener for playBtn

--promote.offerRating(5, "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=428920239")








-------------------FACEBOOK-----------------------------



local fbButton = display.newImageRect ("FaceBook.png",32,32)
	fbButton.x = display.contentWidth*0.5 -220
	fbButton.y = display.contentHeight*0.5 +140

	
local function printTable( t, label, level )
if label then print( label ) end
level = level or 1
if t then
for k,v in pairs( t ) do
local prefix = ""
for i=1,level do
prefix = prefix .. "\t"
end

print( prefix .. "[" .. tostring(k) .. "] = " .. tostring(v) )
if type( v ) == "table" then
print( prefix .. "{" )
printTable( v, nil, level + 1 )
print( prefix .. "}" )
end
end
end
end


local callFacebook = function()
local facebookListener = function( event )
if ( "session" == event.type ) then
if ( "login" == event.phase ) then

local theMessage = "I just played Gravity Ball! I scored " .. score .. " points!"

facebook.request( "me/feed", "POST", {
message=theMessage,
name="Do you think you can beat my score?",
caption="Play Gravity Ball now to find out!",
link="http://itunes.apple.com/us/app/your-app-name/id1234567890?mt=8",
picture="http://yoursite.com/yourimage.png" } )
end
end
end
-- Naturally you will want to put your own info above

facebook.login( "1234567890", facebookListener, { "publish_stream" } )
end
-- the above should be your Facebook app ID

local function callFB (event)
if event.phase == "ended" then
callFacebook()
end
end
fbButton:addEventListener("touch", callFB)
-----------------END FACEBOOK-------------------------------------------

-------------------TWITTER----------------------------------------
--[[
consumer_key = "QlMqxdgXTyBmQ6ZGSEzyTA"
consumer_secret = "VDxBBosOyyqfsgPnUBKeIQ5VzS7rgo8N0v5kGpvlM"
local access_token
local access_token_secret
local user_id
local screen_name

--your web address below can be anything from what i can make out as long as it is the same as the callback url set in twitter settings
--twitter sends the webaddress with the token back to your app and the code strips out the token to use to authorise it
--doing it this way, means the web popup closes itself - if it doesn't it means there is some kind of problem with the code
--I found that out the hard way!!

local twitter_request = (oAuth.getRequestToken(consumer_key, "http://gravityballgame.net", "http://twitter.com/oauth/request_token", consumer_secret))
local twitter_request_token = twitter_request.token
local twitter_request_token_secret = twitter_request.token_secret

local function listener(event)
print("listener")
local remain_open = true
local url = event.url

if url:find("oauth_token") then

url = url:sub(url:find("?") + 1, url:len())

local authorize_response = responseToTable(url, {"=", "&amp;"})
remain_open = false

local access_response = responseToTable(oAuth.getAccessToken(authorize_response.oauth_token, authorize_response.oauth_verifier, twitter_request_token_secret, consumer_key, consumer_secret, "https://api.twitter.com/oauth/access_token"), {"=", "&amp;"})

access_token = access_response.oauth_token
access_token_secret = access_response.oauth_token_secret
user_id = access_response.user_id
screen_name = access_response.screen_name
-- API CALL:
------------------------------
--change the message posted
local params = {}
params[1] =
{
key = 'status',
value = "I just scored " .. score .. " points on #PixelSlice! http://itunes.apple.com/us/app/pixel-slice-plus/id439509275?mt=8"
}

request_response = oAuth.makeRequest("http://api.twitter.com/1/statuses/update.json", params, consumer_key, access_token, consumer_secret, access_token_secret, "POST")
print("req resp ",request_response)
end

return remain_open
end

--this is your webpopup, change position/size as you wish
function tweetit (event)
--native.showWebPopup(10, 10, 460, 360, "http://api.twitter.com/oauth/authorize?oauth_token=" .. twitter_request_token, {urlRequest = listener})
system.openURL(10, 20, 300, 450, "http://api.twitter.com/oauth/authorize?oauth_token=" .. twitter_request_token, {urlRequest = listener})

end


--I use this for testing on a mac, but lack of textfield makes it difficult for my app, i may as well use device
--you could use a random message generator for testing purposes so as to send a unique message each time,
--would let you see messages in terminal then

--system.openURL(10, 20, 300, 450, "http://api.twitter.com/oauth/authorize?oauth_token=" .. twitter_request_token, {urlRequest = listener})

--this is the bit that strips the token from the web address returned
--/////////////////////////////////////////////////////////////////////////////////////
--// RESPONSE TO TABLE
--/////////////////////////////////////////////////////////////////////////////////////
function responseToTable(str, delimeters)
local obj = {}

while str:find(delimeters[1]) ~= nil do
if #delimeters > 1 then
local key_index = 1
local val_index = str:find(delimeters[1])
local key = str:sub(key_index, val_index - 1)

str = str:sub((val_index + delimeters[1]:len()))

local end_index
local value

if str:find(delimeters[2]) == nil then
end_index = str:len()
value = str
else
end_index = str:find(delimeters[2])
value = str:sub(1, (end_index - 1))
str = str:sub((end_index + delimeters[2]:len()), str:len())
end
obj[key] = value
print(key .. ":" .. value)
else

local val_index = str:find(delimeters[1])
str = str:sub((val_index + delimeters[1]:len()))

local end_index
local value

if str:find(delimeters[1]) == nil then
end_index = str:len()
value = str
else
end_index = str:find(delimeters[1])
value = str:sub(1, (end_index - 1))
str = str:sub(end_index, str:len())
end
obj[#obj + 1] = value
print(value)
end
end
return obj
end
]]
local twitterButton = display.newImageRect ("Twitter.png",32,32)
twitterButton.x = display.contentWidth*0.5 -185
twitterButton.y =  display.contentHeight*0.5 +140


--twitterButton:addEventListener("tap", tweetit)    
--------------------------------------------------------------------
------------------END TWITTER--------------------------------------


local function onSystemEvent( event ) 
    if event.type == "applicationStart" then
        gameNetwork.init( "gamecenter", {listener=initCallback} )
        return true
    end
end

local function initCallback( event )
    if event.data then
        native.showAlert( "Success!", "", { "OK" } )
    end
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
	
	
	
local function onPlayBtnRelease()
	composer.gotoScene( "levelSelect", "fade" , 100 )
	
	return true	-- indicates successful touch
end
local function goToOption()
	composer.gotoScene( "option", "fade" , 100 )
	
	return true	-- indicates successful touch
end
local function goToOnline()
	composer.gotoScene( "online", "fade" , 100 )
	
	return true	-- indicates successful touch
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
	

	-- display a background image
	local background = display.newImageRect("background.png",480,320)
	background.x = display.contentWidth *0.5 
	background.y = display.contentHeight *0.5
	
	
	
	
	local title = display.newImageRect("title.png", 600,150)
	title.x = display.contentWidth*0.5 + 35
	title.y = 65
	
	
	
	
	-- create/position logo/title image on upper-half of the screen
	
	--!!!!!!!remember to include the width and height in order for the system to find retina display!!!
	
	
	
	playBtn = widget.newButton{
		label = "Play ",
		labelYOffset = -8,
		labelColor = { default={255}, over={128} },
		font = "Foo",
		defaultFile ="playButton.png",
		overFile ="playButtonOver.png",
	    width = 175, height = 50,
		
		onRelease = onPlayBtnRelease	-- event listener function
	}
	playBtn.x = display.contentWidth*0.5
	playBtn.y = display.contentHeight - 170
	
	
		option = widget.newButton{
		label="Options ",
		labelYOffset = -8,
		labelColor = { default={255}, over={128} },
		font = "Foo",
		defaultFile="playButton.png",
		overFile="playButtonOver.png",
		width=175, height=50,
		onRelease = goToOption-- event listener function
	}
	option.x = display.contentWidth*0.5
	option.y = display.contentHeight - 125
	
		online = widget.newButton{
		label="Online ",
		labelYOffset = -8,
		labelColor = { default={255}, over={128} },
		font = "Foo",
		defaultFile="playButton.png",
		overFile="playButtonOver.png",
		width=175, height=50,
		onRelease = goToOnline	-- event listener function
	}
	online.x = display.contentWidth*0.5
	online.y = display.contentHeight - 80
	
		rateIt = widget.newButton{
		label="Rate me! ",
		labelYOffset = -8,
		labelColor = { default={255}, over={128} },
		font = "Foo",
		defaultFile="playButton.png",
		overFile="playButtonOver.png",
		width=175, height=50,
		onRelease = doRating	-- event listener function
	}
	rateIt.x = display.contentWidth*0.5
	rateIt.y = display.contentHeight - 35
	
	
	
	-- all display objects must be inserted into group
	
	-- you must insert .view property for widgets
	group:insert( background )
	group:insert( title )
	group:insert( fbButton )
	group:insert( twitterButton )
	group:insert( playBtn )
	group:insert( rateIt)
	group:insert( online )
	group:insert( option )
	
	
	--remember to remove the widget 
	
end

-- Called immediately after scene has moved onscreen:
function scene:enter( event )
	local group = self.view
	
	analytics.init( application_key )
	Runtime:addEventListener( "system", onSystemEvent )
	
end


-- Called when scene is about to move offscreen:
function scene:exit( event )
	local group = self.view
	
	Runtime:removeEventListener( "system", onSystemEvent )
	-- INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroy( event )
	local group = self.view
	
	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end
	if rateIt then
		 rateIt:removeSelf()	-- widgets must be manually removed
		rateIt = nil
	end
	if online then
		online:removeSelf()	-- widgets must be manually removed
		online  = nil
	end
	if option then
		option:removeSelf()	-- widgets must be manually removed
		option  = nil
	end
end

--[[local monitorMem = function()
		collectgarbage()
	  	print( "\nMemUsage: " .. collectgarbage("count") )
	  
	  	local textMem = system.getInfo( "textureMemoryUsed" ) / 1000000
	  	print( "TexMem:   " .. textMem )
	end
	
	Runtime:addEventListener( "enterFrame", monitorMem )]]
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