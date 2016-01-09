-- Promotion Library for Corona SDK
-- Written by Reflare
-- http://reflare.com
-- Licensed AS IS meaning -> use it for whatever you want, don't blame me if it crashes

module(..., package.seeall)

local savefile = "crossSale.txt"
local numfile = "crossRate.txt"
local alertText = "If you like this app, please consider leaving a rating in the AppStore."
local btnRate = "Rate me!"
local btnNotNow = "Not Now"
local btnNever = "Don't Ask Again"

-- Do not customize below this line, unless you know what you are doing!

function autoWrappedText(text, font, size, color, width)
		
		-- Multi Line Text Wrapping Code
		-- Written by Cromax
		-- http://developer.anscamobile.com/code/multiline-text-width-pixel
	 	
        if text == '' then return false end
        font = font or native.systemFont
        size = tonumber(size) or 12
        color = color or {255, 255, 255}
        width = width or display.stageWidth

        local result = display.newGroup()
        local currentLine = ''
        local currentLineLength = 0
        local lineCount = 0
        local left = 0
        for line in string.gmatch(text, "[^\n]+") do
                for word, spacer in string.gmatch(line, "([^%s%-]+)([%s%-]*)") do
                        local tempLine = currentLine..word..spacer
                        local tempDisplayLine = display.newText(tempLine, 0, 0, font, size)
                        if tempDisplayLine.width <= width then
                                currentLine = tempLine
                                currentLineLength = tempDisplayLine.width
                        else
                                local newDisplayLine = display.newText(currentLine, 0, (size * 1.1) * (lineCount - 1), font, size)
                                newDisplayLine:setTextColor(color[1], color[2], color[3])
                                result:insert(newDisplayLine)
                                lineCount = lineCount + 1
                                if string.len(word) <= width then
                                        currentLine = word..spacer
                                        currentLineLength = string.len(word)
                                else
                                        local newDisplayLine = display.newText(word, 0, (size * 1.1) * (lineCount - 1), font, size)
                                        newDisplayLine:setTextColor(color[1], color[2], color[3])
                                        result:insert(newDisplayLine)
                                        lineCount = lineCount + 1
                                        currentLine = ''
                                        currentLineLength = 0
                                end 
                        end

						tempDisplayLine:removeSelf();
						tempDisplayLine=nil;
                end
                local newDisplayLine = display.newText(currentLine, 0, (size * 1.1) * (lineCount - 1), font, size)
                newDisplayLine:setTextColor(color[1], color[2], color[3])
                result:insert(newDisplayLine)
                lineCount = lineCount + 1
                currentLine = ''
                currentLineLength = 0
        end
        result:setReferencePoint(display.CenterReferencePoint)
        return result
end

function strsplit(delimiter, text)
  local list = {}
  local pos = 1
  while 1 do
    local first, last = string.find(text, delimiter, pos)
    if first then -- found?
      table.insert(list, string.sub(text, pos, first-1))
      pos = last+1
    else
      table.insert(list, string.sub(text, pos))
      break
    end
  end
  return list
end


local function evaluateURL(event)
	if ( event.isError ) then
	       print( "Offline...")
	else
			local path = system.pathForFile(savefile, system.DocumentsDirectory)
			local fh,reason = io.open(path,"r")
			local oldText = ""
			if fh then
				oldText = fh:read("*a")
				io.close(fh)
			end
	
			if event.response ~= oldText then
				fh = io.open(path,"w")
				fh:write(event.response)
				
				local content = strsplit("||",event.response)
				
				-- Display News Update
				print("show news")
				local newsGroup = display.newGroup()
				local newsBG = display.newImageRect("promote/news.jpg",768,170)
				local newsClose = display.newImageRect("promote/close.png",30,30)
				local newsText = autoWrappedText(content[2], native.systemFont, 22, {255,255,255}, 1200)
				newsBG.x = display.contentWidth / 2
				newsBG.y = display.contentHeight - 170 / 2
				newsClose.x = display.contentWidth - 50
				newsClose.y = display.contentHeight - 120
				newsText.x = display.contentWidth / 2
				newsText.y = display.contentHeight - 170 / 2
				newsGroup:insert(newsBG)
				newsGroup:insert(newsClose)
				newsGroup:insert(newsText)
				newsGroup.y = newsGroup.y + 170
				local function closeNews(event)
					transition.to(newsGroup,{duration=1500,y=newsGroup.y+170})
				end
				transition.to(newsGroup,{duration=1500, y=newsGroup.y-170})
				newsClose:addEventListener("touch",closeNews)
				local function openNews(event)
					system.openURL(content[1])
				end
				newsText:addEventListener("touch",openNews)
			end
	end
end

function displayNews(url)
	network.request( url, "GET", evaluateURL )
end

function offerRating(threshold , url)
	local path = system.pathForFile(numfile, system.DocumentsDirectory)
	local fh,reason = io.open(path,"r")
	local launch = nil
	
	if fh then
		launch = tonumber(fh:read("*a"))
	else
		launch = 0
	end
	
	if launch == -1 then
		return
	end
	
	launch = launch + 1
	
	if launch % threshold == 0 then
		local function onComplete( event )
		        if "clicked" == event.action then
		                local i = event.index
		                if 1 == i then
		                        system.openURL( url )
		                elseif 2 == i then
		                        
						else 
							launch = -1
		                end
		
						fh = io.open(path,"w")
						fh:write(launch)
		        end
		end
		
		local alert = native.showAlert("",alertText, {btnRate, btnNotNow, btnNever}, onComplete)
		
	else
		fh = io.open(path,"w")
		fh:write(launch)
	end
	
end