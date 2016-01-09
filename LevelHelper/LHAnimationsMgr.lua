require "LHHelpers"
require "config"
--------------------------------------------------------------------------------
LHAnimationsMgr = {}
lh_animationsMgr_sharedInstance = nil;
--------------------------------------------------------------------------------
function LHAnimationsMgr:init()

	local object = {animOnSpriteWithName = {},
					animOnSpritesWithTag = {}
					}
	setmetatable(object, { __index = LHAnimationsMgr })  -- Inheritance	
	
	lh_animationsMgr_sharedInstance = object;
	return object
end
--------------------------------------------------------------------------------
function removeLHAnimationsMgr()
lh_animationsMgr_sharedInstance.animOnSpriteWithName = nil;
lh_animationsMgr_sharedInstance.animOnSpritesWithTag = nil
lh_animationsMgr_sharedInstance = nil;
end
--------------------------------------------------------------------------------
function LHAnimationsMgr:sharedInstance()

	if(lh_animationsMgr_sharedInstance == nil) then
		return self:init();
	end
	
	return lh_animationsMgr_sharedInstance;
end
--------------------------------------------------------------------------------
function LHAnimationsMgr:registerAnimationWithNameOnSpriteWithName(animationName, spriteName)

 	animInfoForSprite = self.animOnSpriteWithName[spriteName];

	if(animInfoForSprite == nil)then
		local animInfo = {};
		animInfo[animationName] = 1
		self.animOnSpriteWithName[spriteName] = lh_deepcopy(animInfo);
	else
		animInfoForSprite[animationName]  = 1;
	end
end
--------------------------------------------------------------------------------
function LHAnimationsMgr:registerAnimationWithNameOnSpritesWithTag(animationName, tag)

	animInfoForTag = self.animOnSpritesWithTag[tag];

	if(animInfoForTag == nil)then
		local animInfo = {};
		animInfo[animationName] = 1
		self.animOnSpritesWithTag[tag] = lh_deepcopy(animInfo);
	else
		animInfoForTag[animationName]  = 1;
		self.animOnSpritesWithTag[tag] = lh_deepcopy(animInfoForTag);
	end
end
--------------------------------------------------------------------------------
function LHAnimationsMgr:animationsOnSpritesWithTag(tag)
	return self.animOnSpritesWithTag[tag];
end
--------------------------------------------------------------------------------
function LHAnimationsMgr:animationsOnSpriteWithName(spriteName)
	return self.animOnSpriteWithName[spriteName];
end
--------------------------------------------------------------------------------