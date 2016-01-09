require "LHHelpers"
require "LHPathNode"

--------------------------------------------------------------------------------
--[[
--example
local spr = loader:spriteWithUniqueName("GlassSmall");
spr:moveOnPath("Bezier", 3, true, true,false, 1, true, false)
--]]

function moveOnPath(sprite, pathUniqueName, speed, 
					startAtEndPoint, isCyclic,
					restartOtherEnd, axis, flipX, flipY)

	if(nil == sprite)then
        return;
    end
	
	local loader = sprite.lhParentLoader;
	if(nil == loader)then
		return
	end
	
	local node = loader.loadedBeziers[pathUniqueName];
	
	if(nil ~= node)then
	
		pathNode = node:addSpriteOnPath(sprite, speed, startAtEndPoint, 
										 isCyclic, restartOtherEnd, axis, flipX, flipY)
        
        if(nil ~= pathNode)then
	        sprite.lhPathNode = pathNode
	        pathNode.pathNotifierId = loader.pathNotification
        end
	end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--ANIMATION METHODS
--spr:startAnimationWithUniqueName("OtherAnim2")
function startAnimationWithUniqueName(sprite,animName)
	if(nil ~= sprite)then
		sprite:prepare(animName)
		--the following 2 lines are done in order to fix one of the multiple bugs in corona
		sprite.currentFrame = sprite.currentFrame+1;
		sprite.currentFrame = sprite.currentFrame-1;
		sprite:play()	
	end
end
--------------------------------------------------------------------------------
--spr:prepareAnimationWithUniqueName("OtherAnim2")
function prepareAnimationWithUniqueName(sprite,animName)
	if(nil ~= sprite)then
		sprite:prepare(animName)	
		--the following 2 lines are done in order to fix one of the multiple bugs in corona
		sprite.currentFrame = sprite.currentFrame+1;
		sprite.currentFrame = sprite.currentFrame-1;
	end
end
--------------------------------------------------------------------------------
--spr:pauseAnimation()
function pauseAnimation(sprite)
	if(nil ~= sprite) then
		sprite:pause()
	end
end
--------------------------------------------------------------------------------
--spr:playAnimation()
function playAnimation(sprite)
	if(nil ~= sprite) then
		sprite:play()
	end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--spr:setFrame(1)
function setFrame(sprite, frameNumber)
	sprite.currentFrame = frameNumber;
end
--------------------------------------------------------------------------------
--spr:animationName()
function animationName(sprite)
	return sprite.sequence;
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--spr:activeFrame()
function activeFrame(sprite)
	if nil == sprite then
		return -1;
	end
	return sprite.currentFrame;
end
--------------------------------------------------------------------------------
--spr:numberOfFrames()
function numberOfFrames(sprite)

	local loader = sprite.lhParentLoader;
	for i =1, #loader.loadedAnimations do
		local curNode = loader.loadedAnimations[i];
	
		if(curNode.uniqueName == sprite.sequence)then
			return #curNode.framesInfo
		end
	end
	return 0;
end
--------------------------------------------------------------------------------
--spr:setNextFrame()
function setNextFrame(sprite)
	sprite.currentFrame = sprite.currentFrame + 1;
end
--------------------------------------------------------------------------------
--spr:setNextFrameAndLoop()
function setNextFrameAndLoop(sprite)

	if(sprite.currentFrame == sprite:numberOfFrames()) then
		sprite.currentFrame = 1;
	else
		sprite.currentFrame = sprite.currentFrame + 1;
	end
end
--------------------------------------------------------------------------------
--spr:setPreviousFrame()
function setPreviousFrame(sprite)
	if(nil ~= sprite)then
		sprite.currentFrame = sprite.currentFrame - 1;
	end
end
--------------------------------------------------------------------------------
function setPreviousFrameAndLoop(sprite)

	if(sprite.currentFrame == 1) then
		sprite.currentFrame = sprite:numberOfFrames();
	else
		sprite.currentFrame = sprite.currentFrame - 1;
	end
end
--------------------------------------------------------------------------------