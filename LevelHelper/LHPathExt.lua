require "LHPathNode"
require "LevelHelperLoader"
--------------------------------------------------------------------------------
function LevelHelperLoader:pausePathMovementForSprite(pauseStatus, sprite)

    if(sprite == nil)then
        return;    
    end
    local pathNode = sprite.lhPathNode;
    if(nil ~= pathNode)then
		pathNode:setPaused(pauseStatus)
    end
end
--------------------------------------------------------------------------------
function LevelHelperLoader:cancelPathMovementForSprite(sprite)

    if(sprite == nil)then
        return;    
    end

    if(nil ~= sprite.lhPathNode)then
	    sprite.lhPathNode:removeSelf()
		sprite.lhPathNode = nil
    end

end
--------------------------------------------------------------------------------
--prototype for callbackFunction is local function myEndCallback(sprite, pathName)
function LevelHelperLoader:registerNotifierOnPathEndForSprite(callbackFunction, sprite)

	if(sprite == nil)then
		return
	end
	
    if(nil ~= sprite.lhPathNode)then
		sprite.lhPathNode.pathNotifierId = callbackFunction
    end

end
--------------------------------------------------------------------------------
function LevelHelperLoader:moveSpriteWithUniqueNameOnPath( spriteName, 
														   pathName,
														   speed, 
														   startAtEndPoint,
														   isCyclic,
														   restartOtherEnd,
														   axis,
														   flipX,
														   flipY)

	local lhSprite = self:spriteWithUniqueName(spriteName)
	self:moveSpriteOnPath(lhSprite, pathName, speed, startAtEndPoint, 
						 isCyclic, restartOtherEnd, axis, flipX, flipY)
														   														   
end
--------------------------------------------------------------------------------
function LevelHelperLoader:pausePathMovementForSpriteWithUniqueName(pauseStatus, 
																	sprName)

	local lhSprite = self:spriteWithUniqueName(sprName)
	self:pausePathMovementForSprite(pauseStatus, lhSprite)

end
--------------------------------------------------------------------------------
function LevelHelperLoader:cancelPathMovementForSpriteWithUniqueName(spriteName)

	local lhSprite = self:spriteWithUniqueName(spriteName)
	self:cancelPathMovementForSprite(lhSprite)
end
--------------------------------------------------------------------------------
function LevelHelperLoader:registerNotifierOnPathEndForSpriteWithUniqueName(callbackFunction, spriteName)
	local lhSprite = self:spriteWithUniqueName(spriteName)
	self:registerNotifierOnPathEndForSprite(callbackFunction, lhSprite)
end
--------------------------------------------------------------------------------