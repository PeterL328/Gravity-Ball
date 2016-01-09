require "LHAnimationNode"
require "LevelHelperLoader"

--[[
All methods have been deprecated in favor of the methods provided in LHSprite.lua
Use the animation methods provided in LHSprite.lua.
All methods have example on how to use them.
--]]
--------------------------------------------------------------------------------
function LevelHelperLoader:setFrameOnSprite(sprite, frameNumber)

	print("Deprecated!! Please see comments on the top of LHAnimationsExt.lua")
	sprite.currentFrame = frameNumber;
end
function LevelHelperLoader:setFrameOnSpriteWithUniqueName(spriteName, frameNumber)
	print("Deprecated!! Please see comments on the top of LHAnimationsExt.lua")
	lhSprite = self:spriteWithUniqueName(spriteName);
	self:setFrameOnSprite(lhSprite, frameNumber);
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function LevelHelperLoader:animationNameOnSpriteWithUniqueName(spriteName)
	print("Deprecated!! Please see comments on the top of LHAnimationsExt.lua")
	lhSprite = self:spriteWithUniqueName(spriteName)
	return self:animationNameOnSprite(lhSprite)
end
--------------------------------------------------------------------------------
function LevelHelperLoader:animationNameOnSprite(sprite)
	print("Deprecated!! Please see comments on the top of LHAnimationsExt.lua")
	return sprite.sequence;
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function LevelHelperLoader:currentFrameOnSprite(sprite)
	print("Deprecated!! Please see comments on the top of LHAnimationsExt.lua")
	if nil == sprite then
		return -1;
	end
	
	return sprite.currentFrame;
end
--------------------------------------------------------------------------------
function LevelHelperLoader:numberOfFramesInAnimationNamed(animName)
	print("Deprecated!! Please see comments on the top of LHAnimationsExt.lua")
	for i =1, #self.loadedAnimations do
		local curNode = self.loadedAnimations[i];
	
		if(curNode.uniqueName == animName)then
			return #curNode.framesInfo
		end
	end
	return 0;
end
--------------------------------------------------------------------------------
function LevelHelperLoader:currentFrameOnSpriteWithUniqueName(spriteName)
	print("Deprecated!! Please see comments on the top of LHAnimationsExt.lua")
	lhSprite = self:spriteWithUniqueName(spriteName)
	return self:currentFrameOnSprite(lhSprite)
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function LevelHelperLoader:setNextFrameOnSprite(sprite)
	print("Deprecated!! Please see comments on the top of LHAnimationsExt.lua")
	sprite.currentFrame = sprite.currentFrame + 1;
end
--------------------------------------------------------------------------------
function LevelHelperLoader:setNextFrameOnSpriteWithUniqueName(uniqueName)
	print("Deprecated!! Please see comments on the top of LHAnimationsExt.lua")
	levelHelperSprite = self:spriteWithUniqueName(uniqueName)
	self:setNextFrameOnSprite(levelHelperSprite)
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function LevelHelperLoader:setPreviousFrameOnSprite(sprite)
	print("Deprecated!! Please see comments on the top of LHAnimationsExt.lua")
	if(nil ~= sprite)then
		sprite.currentFrame = sprite.currentFrame - 1;
	end
end
--------------------------------------------------------------------------------
function LevelHelperLoader:setPreviousFrameOnSpriteWithUniqueName(uniqueName)
	print("Deprecated!! Please see comments on the top of LHAnimationsExt.lua")
	levelHelperSprite = self:spriteWithUniqueName(uniqueName)
	self:setPreviousFrameOnSprite(levelHelperSprite)
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function LevelHelperLoader:startAnimationWithUniqueNameOnSpriteWithUniqueName(animName, spriteName)
	print("Deprecated!! Please see comments on the top of LHAnimationsExt.lua")
	levelHelperSprite = self:spriteWithUniqueName(spriteName)
	self:startAnimationWithUniqueNameOnSprite(animName, levelHelperSprite)
end
--------------------------------------------------------------------------------
function LevelHelperLoader:prepareAnimationWithUniqueNameOnSpriteWithUniqueName(animName, spriteName)
	print("Deprecated!! Please see comments on the top of LHAnimationsExt.lua")
	levelHelperSprite = self:spriteWithUniqueName(spriteName)
	self:prepareAnimationWithUniqueNameOnSprite(animName, levelHelperSprite);
end
--------------------------------------------------------------------------------
function LevelHelperLoader:pauseAnimationOnSpriteWithUniqueName(spriteName)
	print("Deprecated!! Please see comments on the top of LHAnimationsExt.lua")
	levelhelperSprite = self:spriteWithUniqueName(spriteName)
	self:pauseAnimationOnSprite(levelHelperSprite);
end
--------------------------------------------------------------------------------
function LevelHelperLoader:playAnimationOnSpriteWithUniqueName(spriteName)
	print("Deprecated!! Please see comments on the top of LHAnimationsExt.lua")
	levelhelperSprite = self:spriteWithUniqueName(spriteName)
	self:playAnimationOnSprite(levelHelperSprite);
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------