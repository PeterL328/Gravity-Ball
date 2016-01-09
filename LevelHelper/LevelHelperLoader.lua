--[[
//  This file was created by LevelHelper
//  http://www.levelhelper.org
//
//  Author: Bogdan Vladu
//  Copyright 2011 Bogdan Vladu. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//  The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//  Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//  This notice may not be removed or altered from any source distribution.
//  By "software" the author refers to this code file and not the application 
//  that was used to generate this file.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Version history
//  ...
//  v1.0 First version for LevelHelper 1.4
//  v1.1 Fixed spritesWithTag methods added new sprite creation methods with z order
//  v1.1.1 Fixes joint issue when using scaled sprites;
//		   Fixed path movement speed to be the same as other engines
//         Added support for path flipX flipY
//  v1.2 Faster loading, added number of frames in an animation method
//  v1.2.1 Fixed visibility status on sprites / fixed image path for android 
//  v1.2.2 Fixed path not beeing removed when removeing the sprite on it
//  v1.2.3 12 dec 11
//         Fixed a few bugs
//         Added back instantiateObjectsInGroup /instantiateSpritesInGroup
//         Updated path to move based on delta in order to be able to move a sprite added to a parallax on a path
//         Updated parallax to support the new path movement
//  v1.2.4 29 Dec 11 
//         Fixed an issue where collision handling events were not released when deleting a level
//         Fixed an issue where friction/restitution/density were not correct on bezier shapes
//         Added linearVelocity and angularVelocity properties
//         Added a few warning messages
//  v1.2.5 13 Jan 12 - Updated how animations are handled for less memory usage
//  v1.2.6 14 Jan 12 - Fixed problem on android device because of corona bug
//  v1.2.7 16 Jan 12 - Added new file LhSprite.lua with new methods
//                     Fixed bezier node not having a retrieve method
//                     Fixed beizer node not having a remove method
//                     Fixed crash when deleting a sprite inside a parallax node
//  v1.2.8 18 Jan 12 - Release some memory manually because corona does not want to
//                   - fixed setPause method for animations
//  v1.3 26 Jan 2012 - Fixed path movement not working when selecting start from other point
////////////////////////////////////////////////////////////////////////////////////////////////////////
--]]
require "config"
require "LHHelpers"
require "LHJoint"
require "LHBezierNode"
require "LHPathNode"
require "LHParallaxNode"
require "LHAnimationNode"
require "LHSettings"
require "LHAnimationsMgr"
require "LHSprite"

LevelHelper_TAG =
{ 
	DEFAULT_TAG 	= 0,
	NUMBER_OF_TAGS 	= 1
}

LevelHelperLoader = {} 
function LevelHelperLoader:initWithContentOfFile(levelFile) -- pass level file as string

	if levelFile == "" then
		print("Invalid level file given!")
	end

	local object = {LHSprites = {},
					LHAnims = {},
					LHBeziers = {},
					LHParallax = {},
					LHJoints = {},
					LHWbInfo = {},
					LHGravityInfo = nil,
					LHGameWorldSize = nil,

					loadedSprites = {}, --all LHSprite objects
					loadedBeziers = {},
					pathNotification = nil,
					loadedParallax = {},
					loadedAnimations = {}, 
					animationsSheet = {},
					--spritesSheet = {}, --this is for the 1 frame sprite
					loadedJoints = {}, -- dictionary
					preCollisionMap = {}, --dictionary
					postCollisionMap = {}, --dictionary
					
					notUsed = 1
					}
	setmetatable(object, { __index = LevelHelperLoader })  -- Inheritance
	
	object:loadLevelHelperSceneFile(levelFile, system.ResourceDirectory)
	
	return object
end
--------------------------------------------------------------------------------
function LevelHelperLoader:instantiateSprites()
	
	assert(self.notUsed,"\nASSERT\nYou can't use both methods \"instantiateSprites()\" and \"instantiateObjects()\".\nPlease use only one.\n\"instantiateSprites()\" - when you don't want physic\n\"instantiateObjects()\" - when you want physic")
	
	self.notUsed = nil
	
	self:createAnimations()
	self:createBeziers(nil)
	self:createSprites(nil)
	self:createParallaxes()
end
--------------------------------------------------------------------------------
function LevelHelperLoader:instantiateSpritesInGroup(theGroup)
	application.LevelHelperSettings.directorGroup = theGroup
	self:instantiateSprites();
end
--------------------------------------------------------------------------------
function LevelHelperLoader:instantiateObjects(physics)

	assert(self.notUsed, "\nASSERT\nYou can't use both methods \"instantiateSprites()\" and \"instantiateObjects()\".\nPlease use only one.\n\"instantiateSprites()\" - when you don't want physic\n\"instantiateObjects()\" - when you want physic")
	
	self.notUsed = nil
	
	
    self:createAnimations()
    self:createBeziers(physics)
	self:createSprites(physics)
	self:createJoints(physics)
	self:createParallaxes()
end
--------------------------------------------------------------------------------
function LevelHelperLoader:instantiateObjectsInGroup(physics, theGroup)
	if(nil == application)then
		print("LevelHelper ERROR: Missing or bad config.lua file. application is not present");
		return
	end
	
	if(nil == application.LevelHelperSettings)then
		print("LevelHelper ERROR: Missing LevelHelperSettings in config.lua file. Please see API Documentation -> Getting Started");
		return
	end

	application.LevelHelperSettings.directorGroup = theGroup
	self:instantiateObjects(physics)
end
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function LevelHelperLoader:removeSelf()

self.LHSprites = nil
self.LHAnims = nil
self.LHBeziers = nil
self.LHParallax = nil
self.LHJoints = nil
self.LHWbInfo = nil
self.LHGravityInfo = nil
self.LHGameWorldSize = nil
					
	for k, v in pairs (self.loadedSprites) do		
		if v ~= nil then
			self:removeSprite(v)
			v = nil
		end
	end	
	self.loadedSprites = nil
	
	for k, v in pairs (self.loadedBeziers) do		
		if v ~= nil then
			v:removeSelf();
		end
	end	
	self.loadedBeziers = nil

	self.pathNotification = nil	
	
	for k,v in pairs(self.loadedParallax) do 
		if v~=nil then
			v:removeSelf();
		end
	end
	self.loadedParallax = nil

	for i = 1, #self.loadedAnimations do
		self.loadedAnimations[i]:removeSelf();
		self.loadedAnimations[i] = nil;
	end
	self.loadedAnimations = nil;

	--for i = 1, #self.spritesSheet do	
	--	 self.spritesSheet[i]:dispose();
	--	 self.spritesSheet[i] = nil;
	--end
	--self.spritesSheet = nil;
	
	for i = 1, #self.animationsSheet do
		
		local sheet = self.animationsSheet[i];
		sheet:dispose();
		self.animationsSheet[i] = nil
	end
	self.animationsSheet = nil

	
	for k,v in pairs(self.loadedJoints) do 
		if v~=nil then
			v:removeSelf();
		end
	end
	self.loadedJoints = nil
	
	self.preCollisionMap = nil;
	self.postCollisionMap = nil;

	Runtime:removeEventListener("collision", self)
	
	self.notUsed = nil					
	self = nil	
	
	removeLHSettings()
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function LevelHelperLoader:setPaused(trueOrFalse)
	for k, v in pairs (self.loadedSprites) do	
		if v ~= nil then
			if nil ~= v.lhPathNode then
				v.lhPathNode:setPaused(trueOrFalse)
			end

			if(trueOrFalse)then
				if(v.animating)then
					v:pause()
					v.lhUnpauseAnimation = true;
				end
			else
				if(v.lhUnpauseAnimation ~= nil)then
					if(v.lhUnpauseAnimation)then
						v:play()
						v.lhUnpauseAnimation = nil;
					end
				end
			end
		end
	end	

	for k,v in pairs(self.loadedParallax) do 
		if v~=nil then
			v:setPaused(trueOrFalse)
		end
	end
end
--------------------------------------------------------------------------------
--SPRITES METHODS
function LevelHelperLoader:spriteWithUniqueName(uniqueName)
	if nil ~= self.loadedSprites[uniqueName] then
		return self.loadedSprites[uniqueName];
	end
	return nil
end
--------------------------------------------------------------------------------
function LevelHelperLoader:spritesWithTag(tag)
	local foundSprites = {}
	for k, v in pairs (self.loadedSprites) do	
		if tag == v.lhTag then
			foundSprites[#foundSprites+1] = v
  		end
	end
	return foundSprites
end
--------------------------------------------------------------------------------
function LevelHelperLoader:removeSprite(sprite)

	if(nil ~= sprite)then	
		if(nil ~= sprite.lhPathNode)then
			sprite.lhPathNode:removeSelf();
			sprite.lhPathNode = nil;
		end
		
		parallaxNode = sprite.lhParallaxNode;
		if(nil ~=parallaxNode)then
			parallaxNode:removeChild(sprite)
		end
		
		if(nil ~= sprite.lhUniqueName)then
			self.loadedSprites[sprite.lhUniqueName] = nil
		end
		if(nil ~= sprite.removeSelf) then
			sprite:removeSelf()
		end
		sprite = nil;
	end
end
--------------------------------------------------------------------------------
function LevelHelperLoader:removeAllSprites()
	for k, v in pairs (self.loadedSprites) do		
		if v ~= nil then
			v:removeSelf()
			self.loadedSprites[k] = nil
		end
	end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function LevelHelperLoader:bezierNodeWithUniqueName(uniqueName)
	if nil ~= self.loadedBeziers[uniqueName] then
		return self.loadedBeziers[uniqueName];
	end
	return nil
end
--------------------------------------------------------------------------------
function LevelHelperLoader:removeBezierNode(bezier)

	if(nil ~= bezier)then
		if(nil ~= bezier.lhUniqueName)then
			self.loadedBeziers[ bezier.lhUniqueName] = nil
			bezier:removeSelf()
		end
	end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--EVENTS
function LevelHelperLoader:addEventListenerToAllSprites(eventName, listener)

	local settings = LHSettings:sharedInstance();
	settings.spritesEvents[eventName] = listener;
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
function LevelHelperLoader:useLevelHelperCollisionHandling()
	Runtime:addEventListener( "collision", self);
end
--------------------------------------------------------------------------------
function LevelHelperLoader:collision(event)
	if ( event.phase == "began" ) then	
		local callbackA = self.preCollisionMap[event.object1.lhTag];
		if(nil ~= callbackA)then
	   		if(nil ~= callbackA[event.object2.lhTag])then
	   			callbackA[event.object2.lhTag](event)
	   		end
	   	end

	   	local callbackB = self.preCollisionMap[event.object2.lhTag];
	   	if(nil ~= callbackB)then
	   		if(nil ~= callbackB[event.object1.lhTag])then
				callbackB[event.object1.lhTag](event)
			end
	   	end	
    elseif ( event.phase == "ended" ) then
		local callbackA = self.postCollisionMap[event.object1.lhTag];
		if(nil ~= callbackA)then
	   		if(nil ~= callbackA[event.object2.lhTag])then
	   			callbackA[event.object2.lhTag](event)
	   		end
	   	end

	   	local callbackB = self.postCollisionMap[event.object2.lhTag];
	   		if(nil ~= callbackB)then
	   			if(nil ~= callbackB[event.object1.lhTag])then
	   				callbackB[event.object1.lhTag](event)
	   			end
			end
    end
end
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--COLLISION HANDLING METHODS
function LevelHelperLoader:registerPreColisionCallbackBetweenTags(tagA, tagB, callbackFunction)
	local tableA = self.preCollisionMap[tagA];
	if(nil == tableA)then
		local myMap = {}
		myMap[tagB] = callbackFunction;
		self.preCollisionMap[tagA] = myMap
	else
		tableA[tagB] = callbackFunction;
	end
end
--------------------------------------------------------------------------------
function LevelHelperLoader:registerPostColisionCallbackBetweenTags(tagA, tagB, callbackFunction)
	local tableA = self.postCollisionMap[tagA];
	if(nil == tableA)then
		local myMap = {}
		myMap[tagB] = callbackFunction;
		self.postCollisionMap[tagA] = myMap
	else
		tableA[tagB] = callbackFunction;
	end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--CREATION METHODS
function LevelHelperLoader:newSpriteWithUniqueName(uniqueName) --NO PHYSICS

	for i = 1, #self.LHSprites do
		local spriteInfo = self.LHSprites[i];
		if uniqueName == spriteInfo["UniqueName"] then
			local coronaSprite = self:spriteFromDictionary(spriteInfo)
			coronaSprite.lhTag = spriteInfo["Tag"]
			local newNumber = LHSettings:sharedInstance():newSpriteNumber()
			coronaSprite.lhUniqueName = "NEW_" .. spriteInfo["UniqueName"] .. "_" .. tostring(newNumber)
			coronaSprite.lhPathNode = nil
			self.loadedSprites[coronaSprite.lhUniqueName] = coronaSprite;
		
			lh_addToDirectorGroup(coronaSprite)
			
				--methods
	coronaSprite.moveOnPath = moveOnPath;
	coronaSprite.startAnimationWithUniqueName = startAnimationWithUniqueName;
	coronaSprite.prepareAnimationWithUniqueName = prepareAnimationWithUniqueName;
	coronaSprite.pauseAnimation = pauseAnimation;
	coronaSprite.playAnimation = playAnimation;
	coronaSprite.setFrame = setFrame;
	coronaSprite.animationName = animationName;
	coronaSprite.activeFrame = activeFrame;
	coronaSprite.numberOfFrames = numberOfFrames;
	coronaSprite.setNextFrame = setNextFrame;
	coronaSprite.setNextFrameAndLoop = setNextFrameAndLoop;
	coronaSprite.setPreviousFrame = setPreviousFrame;
	coronaSprite.setPreviousFrameAndLoop = setPreviousFrameAndLoop;


			return coronaSprite;
		end
	end
	return nil
end
--------------------------------------------------------------------------------
function LevelHelperLoader:newSpriteWithUniqueNameOrderedZ(uniqueName, zOrder) --NO PHYSICS
	local coronaSprite = self:newSpriteWithUniqueName(uniqueName);
	if nil ~= coronaSprite then
		local parent = coronaSprite.parent
		if(nil ~= parent)then
			parent:insert(zOrder, coronaSprite); 
		end
	end
	return coronaSprite;
end
--------------------------------------------------------------------------------
function LevelHelperLoader:newObjectWithUniqueName(uniqueName, physics)

	for i = 1, #self.LHSprites do
		local spriteInfo = self.LHSprites[i];
		if uniqueName == spriteInfo["UniqueName"] then
			local coronaSprite = self:spriteFromDictionary(spriteInfo)
			coronaSprite.lhTag = spriteInfo["Tag"]
			local newNumber = LHSettings:sharedInstance():newSpriteNumber()
			coronaSprite.lhUniqueName = "NEW_PHYSICAL_" .. spriteInfo["UniqueName"] .. "_" .. tostring(newNumber)
			coronaSprite.lhPathNode = nil
			self:createPhysicObject(coronaSprite, spriteInfo, physics)
			self.loadedSprites[coronaSprite.lhUniqueName] = coronaSprite;
			lh_addToDirectorGroup(coronaSprite)
			
				--methods
	coronaSprite.moveOnPath = moveOnPath;
	coronaSprite.startAnimationWithUniqueName = startAnimationWithUniqueName;
	coronaSprite.prepareAnimationWithUniqueName = prepareAnimationWithUniqueName;
	coronaSprite.pauseAnimation = pauseAnimation;
	coronaSprite.playAnimation = playAnimation;
	coronaSprite.setFrame = setFrame;
	coronaSprite.animationName = animationName;
	coronaSprite.activeFrame = activeFrame;
	coronaSprite.numberOfFrames = numberOfFrames;
	coronaSprite.setNextFrame = setNextFrame;
	coronaSprite.setNextFrameAndLoop = setNextFrameAndLoop;
	coronaSprite.setPreviousFrame = setPreviousFrame;
	coronaSprite.setPreviousFrameAndLoop = setPreviousFrameAndLoop;


			return coronaSprite;
		end
	end
	return nil
end
--------------------------------------------------------------------------------
function LevelHelperLoader:newObjectWithUniqueNameOrderedZ(uniqueName, physics, zOrder)
	local coronaSprite = self:newObjectWithUniqueName(uniqueName, physics);
	if nil ~= coronaSprite then
		local parent = coronaSprite.parent
		if(nil ~= parent)then
			parent:insert(zOrder, coronaSprite); 
		end
	end
	return coronaSprite;
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--JOINT METHODS
function LevelHelperLoader:jointWithUniqueName(jointName)
	return self.loadedJoints[jointName];
end
--------------------------------------------------------------------------------
function LevelHelperLoader:removeJoint(joint)
	if(nil ~= joint)then
		if(nil ~= joint.lhUniqueName)then
			self.loadedJoints[joint.lhUniqueName] = nil
		end
		if(nil ~= joint.removeSelf)then
			joint:removeSelf();
		end
	end
end
--More methods in LHJointsExt.lua - download from http://www.levelhelper.org*/
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--PATH METHODS
function LevelHelperLoader:moveSpriteOnPath(sprite, pathUniqueName, 
											speed, startAtEndPoint, isCyclic,
											restartOtherEnd, axis, flipX, flipY)
											
	print("moveSpriteOnPath is deprecated. Please use moveOnPath available in LHSprite.lua")
	if(nil == sprite)then
        return;
    end
	
	local node = self.loadedBeziers[pathUniqueName];
	
	if(nil ~= node)then
	
		pathNode = node:addSpriteOnPath(sprite, speed, startAtEndPoint, 
										 isCyclic, restartOtherEnd, axis, flipX, flipY)
						 
        
        if(nil ~= pathNode)then
	        sprite.lhPathNode = pathNode
	        pathNode.pathNotifierId = self.pathNotification
        end
	end
end
--------------------------------------------------------------------------------
--prototype for callbackFunction is local function myEndCallback(levelHelperSprite, pathName)
--must be called before instantiateObjects
function LevelHelperLoader:registerNotifierOnAllPathEndPoints(callbackFunction)
	self.pathNotification = callbackFunction;
end
--More methods in LHPathExt.lua - download from http://www.levelhelper.org*/
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--PARALLAX METHODS
function LevelHelperLoader:parallaxWithUniqueName(parallaxName)
	return self.loadedParallax[parallaxName];
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--ANIMATION METHODS
function LevelHelperLoader:startAnimationWithUniqueNameOnSprite(animName, 
																sprite)
																
	print("startAnimationWithUniqueNameOnSprite is deprecated. Please use startAnimationWithUnique available in LHSprite.lua")
																
	if(nil ~= sprite)then
		sprite:prepare(animName)
		--the following 2 lines are done in order to fix one of the multiple bugs in corona
		sprite.currentFrame = sprite.currentFrame+1;
		sprite.currentFrame = sprite.currentFrame-1;
		sprite:play()	
	end
end
--------------------------------------------------------------------------------
function LevelHelperLoader:prepareAnimationWithUniqueNameOnSprite(animName,
																sprite)
	print("prepareAnimationWithUniqueNameOnSprite is deprecated. Please use prepareAnimationWithUniqueName available in LHSprite.lua")
	
	if(nil ~= sprite)then
		sprite:prepare(animName)	
		--the following 2 lines are done in order to fix one of the multiple bugs in corona
		sprite.currentFrame = sprite.currentFrame+1;
		sprite.currentFrame = sprite.currentFrame-1;
	end
end
--------------------------------------------------------------------------------
function LevelHelperLoader:pauseAnimationOnSprite(sprite)

	print("pauseAnimationOnSprite is deprecated. Please use pauseAnimation available in LHSprite.lua")

	if(nil ~= sprite) then
		sprite:pause()
	end
end
function LevelHelperLoader:playAnimationOnSprite(sprite)

	print("playAnimationOnSprite is deprecated. Please use playAnimation available in LHSprite.lua")
	if(nil ~= sprite) then
		sprite:play()
	end
end
--More methods in LHAnimationsExt.lua - download from http://www.levelhelper.org*/
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--PHYSIC BOUNDARIES METHODS
function LevelHelperLoader:hasPhysicBoundaries()

if #self.LHWbInfo == 1 then

	local wbInfo = self.LHWbInfo[1];
    local rect = lh_rectFromString(wbInfo["WBRect"])
   
   	if rect.size.width == 0 or rect.size.height == 0 then
   		return false
   	end
   	
	return true
end
return false
end
--------------------------------------------------------------------------------
function LevelHelperLoader:getPhysicBoundariesRect()

	if false == self:hasPhysicBoundaries() then
		print("LevelHelper ERROR: Please create world boundaries inside LevelHelper in order to call \"getWorldBoundariesRect\" method.")
		return
	end

	local wbConv = {x = 1.0, y = 1.0}
    
    if convertLevel then
        wbConv = convertRatio;
    end
    
	local wbInfo = self.LHWbInfo[1];
    local rect = lh_rectFromString(wbInfo["WBRect"])
    
	return {origin = {x = rect.origin.x*wbConv.x, y = rect.origin.y*wbConv.y}, 
			size = {width = rect.size.width*wbConv.x, height = rect.size.height*wbConv.y}}
end
--------------------------------------------------------------------------------
function LevelHelperLoader:createPhysicBoundaries(physics)

	if false == self:hasPhysicBoundaries() then
		print("LevelHelper ERROR: Please create world boundaries inside LevelHelper in order to call \"createWorldBoundaries\" method.")
		return
	end
    
	local wbInfo = self.LHWbInfo[1];	
    local friction 		= wbInfo["Friction"]
    local density 		= wbInfo["Density"]
    local restitution 	= wbInfo["Restitution"]
    local rect 			= lh_rectFromString(wbInfo["WBRect"])
    
    local collisionFilter = { 	categoryBits 	= wbInfo["Category"], 
								maskBits 		= wbInfo["Mask"], 
								groupIndex 		= wbInfo["Group"] } 
								
    local borderTop = display.newLine( 0,0, 0,0 )    
    borderTop.lhTag = wbInfo["TagTop"]
	borderTop.lhUniqueName = "LH_PHYSIC_BOUNDARIES_TOP"
	
	self.loadedSprites["LH_PHYSIC_BOUNDARIES_TOP"] = borderTop;
	lh_addToDirectorGroup(borderTop)
	local wbConv = { x = 1.0, y = 1.0}
  	local shape = { rect.origin.x*wbConv.x, 
  					rect.origin.y*wbConv.y, 
  					(rect.origin.x + rect.size.width)*wbConv.x, 
	  				rect.origin.y*wbConv.y }
	physics.addBody( borderTop, "static", { density=density, 
											friction=friction, 
											bounce=restitution, 
											shape=shape, 
											filter = collisionFilter } )

    local borderLeft = display.newLine( 0,0, 0,0 )
	borderLeft.lhTag = wbInfo["TagLeft"]
	borderLeft.lhUniqueName = "LH_PHYSIC_BOUNDARIES_LEFT"

	self.loadedSprites["LH_PHYSIC_BOUNDARIES_LEFT"] = borderLeft;
	lh_addToDirectorGroup(borderLeft)
  	shape = { 	rect.origin.x*wbConv.x, 
  				rect.origin.y*wbConv.y, 
  				rect.origin.x*wbConv.x, 
  				(rect.origin.y + rect.size.height)*wbConv.y}
	physics.addBody( borderLeft, "static", { density=density, 
											friction=friction, 
											bounce=restitution, 
											shape=shape, 
											filter = collisionFilter } )

    local borderRight = display.newLine( 0,0, 0,0 )
    borderRight.lhTag = wbInfo["TagRight"]
	borderRight.lhUniqueName = "LH_PHYSIC_BOUNDARIES_RIGHT"
    self.loadedSprites["LH_PHYSIC_BOUNDARIES_RIGHT"] = borderRight;
    lh_addToDirectorGroup(borderRight)
  	shape = { 	(rect.origin.x + rect.size.width)*wbConv.x,
  				rect.origin.y*wbConv.y, 
  				(rect.origin.x + rect.size.width)*wbConv.x, 
  				(rect.origin.y + rect.size.height)*wbConv.y}
	physics.addBody( borderRight, "static", { density=density, 
											friction=friction, 
											bounce=restitution, 
											shape=shape, 
											filter = collisionFilter } )

    local borderBottom = display.newLine( 0,0, 0,0 )
    borderBottom.lhTag = wbInfo["TagBottom"]
	borderBottom.lhUniqueName = "LH_PHYSIC_BOUNDARIES_BOTTOM"
	self.loadedSprites["LH_PHYSIC_BOUNDARIES_BOTTOM"] = borderBottom;
	lh_addToDirectorGroup(borderBottom)
  	shape = { 	rect.origin.x*wbConv.x, 
  				(rect.origin.y + rect.size.height)*wbConv.y, 
	  			(rect.origin.x + rect.size.width)*wbConv.x, 
  				(rect.origin.y + rect.size.height)*wbConv.y}
	physics.addBody( borderBottom, "static", { density=density, 
											friction=friction, 
											bounce=restitution, 
											shape=shape, 
											filter = collisionFilter } )
			
	return borderTop, borderLeft, borderRight, borderBottom;
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--GRAVITY
function LevelHelperLoader:isGravityZero()
	if self.LHGravityInfo.x == 0 and self.LHGravityInfo.y == 0 then
		return true
	end
		return false;
end
--------------------------------------------------------------------------------
function LevelHelperLoader:setGravity(physics)

if(nil == self.LHGravityInfo)then
	print("Unknown error in setGravity method")
	return
end
if self.LHGravityInfo.x == 0 and self.LHGravityInfo.y == 0 then
	print("LevelHelper WARNING: Gravity is zero in this level - did you forget to define it?")
end
	physics.setGravity( self.LHGravityInfo.x, -1* self.LHGravityInfo.y )
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
--GAME WORLD
function LevelHelperLoader:getGameWorldRect()
	local wbConv = {x = 1.0, y = 1.0}
    
	local rect = self.LHGameWorldSize;
	
	return {origin = {x = rect.origin.x*wbConv.x, y = rect.origin.y*wbConv.y}, 
			size = {width = rect.size.width*wbConv.x, height = rect.size.height*wbConv.y}}
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-------PRIVATE METHODS - THIS SHOULD NOT BE USED BY THE USER--------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function LevelHelperLoader:createAnimations()
	for i = 1, #self.LHAnims do
		local animInfo = self.LHAnims[i]
		local animNode = LHAnimationNode:initWithDictionary(animInfo)
		self.loadedAnimations[#self.loadedAnimations+1] = animNode;
	end	
end
--------------------------------------------------------------------------------
function LevelHelperLoader:createBeziers(physics)
    for i = 1, #self.LHBeziers do
        local bezierInfo = self.LHBeziers[i]
        local bezierNode = LHBezierNode:initWithDictionary(bezierInfo, physics)
        if (nil ~= bezierNode) then
	        self.loadedBeziers[bezierInfo["UniqueName"]] = bezierNode;
	    end
    end
end
--------------------------------------------------------------------------------
function LevelHelperLoader:createSprites(physics)
	for i = 1, #self.LHSprites do
		local spriteInfo = self.LHSprites[i]
		self:createSpriteFromDictionary(spriteInfo, physics)	
	end
end
--------------------------------------------------------------------------------
function LevelHelperLoader:createJoints(physics)
	for j = 1, #self.LHJoints do
		local jointInfo = self.LHJoints[j]
		local lhJoint = self:createJoint(physics, jointInfo);
		if(nil ~= lhJoint)then
			self.loadedJoints[jointInfo["UniqueName"]] = lhJoint
		end
	end
end
--------------------------------------------------------------------------------
function LevelHelperLoader:createParallaxes()
	for p = 1, #self.LHParallax do
		local parInfo = self.LHParallax[p]
		local parallaxNode = LHParallaxNode:initWithDictionary(parInfo)
		if(nil ~= parallaxNode) then
			self.loadedParallax[parInfo["UniqueName"]] = parallaxNode;
		end
		
		local spritesInParallax = parInfo["Sprites"]
		for i = 1, #spritesInParallax do
			local curSprInfo = spritesInParallax[i]	
			local ratioX = curSprInfo["RatioX"]
			local ratioY = curSprInfo["RatioY"]
			local sprName= curSprInfo["SpriteName"]	
			local localSprite = self:spriteWithUniqueName(sprName)

			if(nil ~= localSprite)then
				parallaxNode:addChild(localSprite, {x = ratioX, y = ratioY})
			end
		end	
	end	
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function LevelHelperLoader:createSpriteFromDictionary(spriteInfo, physics)
	local coronaSprite = self:spriteFromDictionary(spriteInfo)

	if(coronaSprite == nil) then
		return nil
	end

	coronaSprite.lhTag = spriteInfo["Tag"]
	coronaSprite.lhUniqueName = spriteInfo["UniqueName"]
	coronaSprite.lhPathNode = nil
	coronaSprite.lhParentLoader = self;
	
	--methods
	coronaSprite.moveOnPath = moveOnPath;
	coronaSprite.startAnimationWithUniqueName = startAnimationWithUniqueName;
	coronaSprite.prepareAnimationWithUniqueName = prepareAnimationWithUniqueName;
	coronaSprite.pauseAnimation = pauseAnimation;
	coronaSprite.playAnimation = playAnimation;
	coronaSprite.setFrame = setFrame;
	coronaSprite.animationName = animationName;
	coronaSprite.activeFrame = activeFrame;
	coronaSprite.numberOfFrames = numberOfFrames;
	coronaSprite.setNextFrame = setNextFrame;
	coronaSprite.setNextFrameAndLoop = setNextFrameAndLoop;
	coronaSprite.setPreviousFrame = setPreviousFrame;
	coronaSprite.setPreviousFrameAndLoop = setPreviousFrameAndLoop;
				
	
	if(nil ~= physics)then
		self:createPhysicObject(coronaSprite, spriteInfo, physics)
	end
	
	self.loadedSprites[spriteInfo["UniqueName"]] = coronaSprite;
	
	--if(false == spriteInfo["IsInParallax"])then
		lh_addToDirectorGroup(coronaSprite)
	--end
	
	if nil == string.find(spriteInfo["PathName"], "None") or
	   nil == string.find(spriteInfo["PathName"], "") then
	
		local uniquePathName = spriteInfo["PathName"];
	    local isCyclic 		 = spriteInfo["PathIsCyclic"]
   		local pathSpeed 	 = spriteInfo["PathSpeed"]
	    local startPoint 	 = spriteInfo["PathStartPoint"] --0 is first 1 is end
		local pathOtherEnd 	 = spriteInfo["PathOtherEnd"] --false means will restart where it finishes
    	local pathOrientation= spriteInfo["PathOrientation"];
    	local flipX = spriteInfo["PathFlipX"];
    	local flipY = spriteInfo["PathFlipY"];
    	    
		local bezier = self.loadedBeziers[uniquePathName];
			
		if(nil ~= bezier)then
			local pathNode = bezier:addSpriteOnPath(coronaSprite, pathSpeed, startPoint, 
						 							isCyclic, pathOtherEnd, pathOrientation, flipX, flipY);
			coronaSprite.lhPathNode = pathNode;
			pathNode.pathNotifierId = self.pathNotification;
		end
	end
end
--------------------------------------------------------------------------------
function LevelHelperLoader:spriteFromDictionary(spriteInfo)

	local coronaSprite = spriteFromAnimationsNodesAndSpriteInfo(self.loadedAnimations, spriteInfo, self.animationsSheet) 
	
	if(coronaSprite == nil)then
		return nil;
	end
	
	coronaSprite:setReferencePoint(display.CenterReferencePoint)
	
	local animName = spriteInfo["AnimName"];
	
	local position = lh_pointFromString(spriteInfo["Position"])
	coronaSprite.x = position.x
	coronaSprite.y = position.y
	
	local convertRatio = LHSettings:sharedInstance():convertRatio()

	local scale = lh_sizeFromString(spriteInfo["Scale"])
	coronaSprite.width  = coronaSprite.width  * scale.width
	coronaSprite.height = coronaSprite.height * scale.height
	
	coronaSprite.xScale = coronaSprite.xScale*scale.width
	coronaSprite.yScale = coronaSprite.yScale*scale.height

	coronaSprite.lhScaleWidth = scale.width;
	coronaSprite.lhScaleHeight= scale.height;

	coronaSprite.rotation = spriteInfo["Angle"]
	coronaSprite.alpha 	  = spriteInfo["Opacity"]
					
	if( false == spriteInfo["IsDrawable"])then
		coronaSprite.alpha = 0.0
	end
--	if LHGroup ~= nil then
--		LHGroup:insert(spriteInstance)
--	end
		
	--local color = rectFromString(lhSprite["Color"])
	-- property not supported - only for vector objects
	--spriteInstance:setFillColor(color.origin.x*255,color.origin.y*255,color.size.width*255)	
	
	local settings = LHSettings:sharedInstance();
	for k,v in pairs(settings.spritesEvents) do
		coronaSprite:addEventListener(k,v)
	end

	return coronaSprite
end
--------------------------------------------------------------------------------
function LevelHelperLoader:createPhysicObject(coronaSprite, property, physics)

	if(property["Type"] ==3)then --no physics on this sprite
		return
	end

	local fixtures = property["ShapeFixtures"]

	local physicType = "static"
	if property["Type"] == 1 then
		physicType = "kinematic"
	elseif property["Type"] == 2 then
		physicType = "dynamic"
	end
		
	local scale = lh_sizeFromString(property["Scale"])
	local border = lh_pointFromString(property["ShapeBorder"])
	
	local collisionFilter = { 	categoryBits = property["Category"], 
								maskBits 	 = property["Mask"], 
								groupIndex 	 = property["Group"] } 

	if nil == fixtures then
		-- sprite does not have polygon points
		-- check if its circle if not make it rectangle
		local size = lh_sizeFromString(property["Size"])

		local sizeW = (size.width-border.x/2)*scale.width;
		local sizeH = (size.height-border.y/2)*scale.height;	

		if false == property["IsCircle"] then
			-- object is not circle
			physics.addBody(coronaSprite, 
							physicType,
							{ density 	= property["Density"],
							  friction	= property["Friction"],
							  bounce   	= property["Restitution"],
							  filter 	= collisionFilter,
							  shape = lh_deepcopy(lh_quadFromSize(sizeW, sizeH))})
		else
			-- object is circle		
			local radiusSize = (size.width-border.x)/2*scale.width;
			
			physics.addBody(coronaSprite, 
							physicType,
							{ 	density 	= property["Density"], 
								friction 	= property["Friction"], 
								bounce 		= property["Restitution"], 
								radius = radiusSize,
								filter = collisionFilter
							} )
		end
	else	
	
		physics.addBody(coronaSprite, 
						physicType,
						unpack(lh_polygonPointsFromStrings(fixtures, 
						 							  scale, 
						 							  property["Density"],
						 							  property["Friction"], 
						 							  property["Restitution"],
						 							  collisionFilter))
						 	)
	end
		
	coronaSprite.isFixedRotation = property["FixedRot"]
	coronaSprite.isSensor = property["IsSensor"]	
	
	coronaSprite.isBullet = property["IsBullet"]
	coronaSprite.isSleepingAllowed = property["CanSleep"]
	
	coronaSprite.linearDamping = property["LinearDamping"]
	coronaSprite.angularDamping = property["AngularDamping"]
	
	local velocity = lh_pointFromString(property["LinearVelocity"])	
	coronaSprite:setLinearVelocity( velocity.x, velocity.y)
	
	coronaSprite.angularVelocity = property["AngularVelocity"];

end
--------------------------------------------------------------------------------
function  LevelHelperLoader:createJoint(physics, jointInfo)

	local lhSprA = self.loadedSprites[jointInfo["ObjectA"]]
	local lhSprB = self.loadedSprites[jointInfo["ObjectB"]]
	local objA = lhSprA;
	local objB = lhSprB;
	
	if objA == nil then
		return nil
	end
	
	if objB == nil then
		return nil
	end
	
	if objA == objB then
		print("ObjectA equal ObjectB in joint creation - Box2D will assert.")
		return nil
	end
	
	local anchorA = lh_pointFromString(jointInfo["AnchorA"])
	local anchorB = lh_pointFromString(jointInfo["AnchorB"])
	
	anchorA.x = anchorA.x*lhSprA.lhScaleWidth;
	anchorA.y = anchorA.y*lhSprA.lhScaleHeight;
		
	anchorB.x = anchorB.x*lhSprB.lhScaleWidth;
	anchorB.y = anchorB.y*lhSprB.lhScaleHeight;
	
	if true == jointInfo["CenterOfMass"] then
		anchorA.x = 0
		anchorB.x = 0
		anchorA.y = 0
		anchorB.y = 0
	end
	
	local jointTypeName = "";
	local myJoint = nil
	if jointInfo["Type"] == 0 then -- distance joint	

		myJoint = physics.newJoint( "distance", 
										objA, 
										objB, 
										objA.x +anchorA.x,
										objA.y +anchorA.y,
										objB.x +anchorB.x,
										objB.y +anchorB.y)
		myJoint.frequency = jointInfo["Frequency"]
		myJoint.dampingRatio = jointInfo["Damping"]
		jointTypeName = "distance";
		
	elseif jointInfo["Type"] == 1 then -- revolute joint
			
		myJoint = physics.newJoint( "pivot", objA, objB, objA.x +anchorA.x, objA.y +anchorA.y)
		
		myJoint.isMotorEnabled = jointInfo["EnableMotor"]
		myJoint.motorSpeed = (-1)*jointInfo["MotorSpeed"] --for CORONA we inverse to be the same as 
														--as the other engines from left to right
		myJoint.maxMotorTorque = jointInfo["MaxTorque"]
		
		myJoint.isLimitEnabled = jointInfo["EnableLimit"]
		myJoint:setRotationLimits( jointInfo["LowerAngle"], jointInfo["UpperAngle"] )
		jointTypeName = "pivot";

	elseif jointInfo["Type"] == 2 then -- prismatic joint

		axis = lh_pointFromString(jointInfo["Axis"])
		myJoint = physics.newJoint( "piston", objA, objB, 
									objA.x +anchorA.x, objA.y +anchorA.y,
									axis.x,axis.y )
	
		myJoint.isMotorEnabled = jointInfo["EnableMotor"]
		myJoint.motorSpeed = (-1)*jointInfo["MotorSpeed"] --for CORONA we inverse to be the same as 
														--as the other engines from left to right
		myJoint.maxMotorForce = jointInfo["MaxMotorForce"]
		myJoint.isLimitEnabled = jointInfo["EnableLimit"]
		myJoint:setLimits( jointInfo["LowerTranslation"]/2, jointInfo["UpperTranslation"]/2 )
		jointTypeName = "piston";

	elseif jointInfo["Type"] == 3 then -- pulley joint
	
		groundAnchorA = lh_pointFromString(jointInfo["GroundAnchorA"])
		groundAnchorB = lh_pointFromString(jointInfo["GroundAnchorB"])
	

		myJoint = physics.newJoint( "pulley", objA, objB, 
										groundAnchorA.x,groundAnchorA.y, 
										groundAnchorB.x,groundAnchorB.y, 
										objA.x +anchorA.x,objA.y +anchorA.y, 
										objB.x +anchorB.x,objB.y +anchorB.y, 
										jointInfo["Ratio"] )
		jointTypeName = "pulley";
		
	elseif jointInfo["Type"] == 4 then -- gear joint										
		print("Corona SDK currently does not support Gear Joints. When they will make it available I will add it in LevelHelper also.");
	elseif jointInfo["Type"] == 5 then -- wheel joint

		axis = lh_pointFromString(jointInfo["Axis"])
		
		myJoint = physics.newJoint( "wheel", objA, objB, 
									objA.x +anchorA.x, objA.y +anchorA.y, 
									axis.x,axis.y )
	
		myJoint.isMotorEnabled = jointInfo["EnableMotor"];
		myJoint.motorSpeed = (-1)*jointInfo["MotorSpeed"] --for CORONA we inverse to be the same as 
														--as the other engines from left to right
		--myJoint.motorForce = jointInfo["MaxTorque"];
		
		myJoint.frequency = jointInfo["Frequency"];
		myJoint.dampingRatio = jointInfo["Damping"];
		
		jointTypeName = "wheel";
		
	elseif jointInfo["Type"] == 6 then -- weld joint

		myJoint = physics.newJoint( "weld", objA, objB, objA.x +anchorA.x,objA.y +anchorA.y )
		jointTypeName = "weld";
		
	elseif jointInfo["Type"] == 8 then -- friction joint
	
		myJoint = physics.newJoint( "friction", objA, objB, objA.x +anchorA.x, objA.y +anchorA.y)
		
		myJoint.maxForce  = jointInfo["MaxForce"];
		myJoint.maxTorque = jointInfo["MaxTorque"];
		jointTypeName = "friction";		
	else
		print("Unknown joint type " .. jointInfo["Type"] .." in LevelHelper file.")
	end
	
	if(nil ~= myJoint)then
		return LHJoint:initWithDictionary(jointInfo, myJoint, jointTypeName, lhSprA, lhSprB);
	end
	
	return nil;
end


function  LevelHelperLoader:loadLevelHelperSceneFile(levelFile, resourceDirectory)

	local path = nil;
	
	if(nil == application)then
		print("LevelHelper ERROR: Missing or bad config.lua file. \"application\" is not present. Please see API Documentation -> Getting Started.");
		return
	end
		
	if(nil ~= application.LevelHelperSettings)then
		if(nil ~= application.LevelHelperSettings.levelsSubfolder)then
			path = system.pathForFile(application.LevelHelperSettings.levelsSubfolder .. "/" .. levelFile, resourceDirectory);
		end
	end
	
	if(nil == path)then
		path = system.pathForFile(levelFile, resourceDirectory)
	end
	
	if(nil == path)then
		print("LEVELHELPER ERROR: Level file not found.");
		return;
	end

	local file = io.open(path, "r")


local lh_safeFrame = ""
local gravityInfo = nil
local gameWorldSizeInfo = nil

 	-- Determine if file exists
	if file then
   		------------------------------------------------------------------------
   		
--------------------------------------------------------------------------------
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
local lh_currentSpriteInfo = {}
local lh_readSprites = false
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
local lh_currentAnimInfo = {}
local lh_readAnims = false
----
local lh_currentAnimFramesInfo = {} --this will contain all frames 
local lh_currentFrameInfo = {} --info about the frame
local lh_readAnimFrames = false
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
local lh_currentBezierInfo = {}
local lh_readBeziers = false
----
local lh_currentBezierCurveInfo = {}
local lh_currentCurveInfo = {}
local lh_readBezierCurves = false;

local lh_currentBezierTileInfo = {}
local lh_currentTileInfo = {}
local lh_readBezierTile = false;
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
local currentParallaxInfo = {}
local readParallax = false
---
local currentParallaxSpritesInfo = {}
local currentParallaxSprInfo = {}
local readParallaxSprites = false
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


--local currentJoint = 0
local currentJointInfo = {}
local readJoints = false

--local current

--local currentFixture = 0
local lh_currentPolygonInfo = {}
local lh_currentFixtureInfo = {}
--local currentFixturePoint = 0
local lh_readFixture = false

local readSafeFrame = false


local wbInfo = {}
local readWB = false

local readGravity = false


local readGameWorldSize = false


local lh_currentKey;

local lh_dict = 0
local lh_array = 0

------------------------------------------------------------------------
local function dictEnd()
	lh_dict = lh_dict-1

	if lh_dict == 1 then
	
		if lh_readAnims then
			self.LHAnims[#self.LHAnims+1] = lh_deepcopy(lh_currentAnimInfo)
			--for k,v in pairs(lh_currentAnimInfo) do v=nil end
			lh_currentAnimInfo = nil
			lh_currentAnimInfo = {}
		end
		
		if lh_readBeziers then
			self.LHBeziers[#self.LHBeziers+1] = lh_deepcopy(lh_currentBezierInfo)
			--for k,v in pairs(lh_currentBezierInfo) do v=nil end
			lh_currentBezierInfo = nil
			lh_currentBezierInfo = {}
		end

		if readParallax then
			self.LHParallax[#self.LHParallax+1] = lh_deepcopy(currentParallaxInfo)
			--for k,v in pairs(currentParallaxInfo) do v=nil end
			currentParallaxInfo = nil
			currentParallaxInfo = {}
		end
		
		if lh_readSprites then
			self.LHSprites[#self.LHSprites+1] = lh_deepcopy(lh_currentSpriteInfo)
			--for k,v in pairs(lh_currentSpriteInfo) do v=nil end
			lh_currentSpriteInfo = nil
			lh_currentSpriteInfo = {}
		end
		
		if readWB then
--			print("end wb")
			self.LHWbInfo[#self.LHWbInfo+1] = lh_deepcopy(wbInfo)
			--for k,v in pairs(wbInfo) do v=nil end
			wbInfo = nil
			wbInfo = {}
			readWB = false
		end
		
		if readJoints then
			--print("pushing the newly created joint")
			self.LHJoints[#self.LHJoints+1] = lh_deepcopy(currentJointInfo)
			--for k,v in pairs(currentJointInfo) do v=nil end
		end
	end
	
	if lh_dict == 2 then	
		if lh_readAnimFrames then
			lh_currentAnimFramesInfo[#lh_currentAnimFramesInfo+1] = lh_deepcopy(lh_currentFrameInfo)
			--for k,v in pairs(lh_currentFrameInfo) do v=nil end
			lh_currentFrameInfo = nil
			lh_currentFrameInfo = {}
		end
		
		if lh_readBezierCurves then
			lh_currentBezierCurveInfo[#lh_currentBezierCurveInfo+1] = lh_deepcopy(lh_currentCurveInfo)
			--for k,v in pairs(lh_currentCurveInfo) do v=nil end
			lh_currentCurveInfo = nil
			lh_currentCurveInfo = {}
		end
		
		if readParallaxSprites then
			currentParallaxSpritesInfo[#currentParallaxSpritesInfo+1] = lh_deepcopy(currentParallaxSprInfo)
			--for k,v in pairs(currentParallaxSprInfo) do v=nil end
			currentParallaxSprInfo = nil
			currentParallaxSprInfo = {}
		end
	end
end


local function lh_key(arg)
	lh_currentKey = arg
--	print("KEY " .. arg)

	
	if nil ~= string.find(arg, "ANIMS_INFO") then
		lh_readAnims = true;
	end
		
	if nil ~= string.find(arg, "JOINTS_INFO") then
		readJoints = true
	end
	
	if nil ~= string.find(arg, "PARALLAX_INFO") then
		readParallax = true
	end

	if nil ~= string.find(arg, "SPRITES_INFO") then
		lh_readSprites = true
	end
	
	if nil ~= string.find(arg, "GameWorld") then
		readGameWorldSize = true
	end

	--if nil ~= string.find(arg,  "GeneralProperties") then
		--currentSprite = currentSprite + 1
	--end
	
	if nil ~= string.find(arg, "WBInfo") then
		readWB = true
	end
	
	if nil ~= string.find(arg, "Frames") then
		if lh_readAnims then
			lh_readAnimFrames = true
			lh_readAnims = false
		end
	end
	
	if nil ~= string.find(arg, "BEZIER_INFO") then
		lh_readBeziers = true;
		lh_readBezierTile = false;
		lh_readBezierCurves = false;
	end

	if nil ~= string.find(arg, "Curves") then
		if lh_readBeziers then
			lh_readBezierCurves = true
			lh_readBezierTile = false
			lh_readBeziers = false
		end
	end
	
	if nil ~= string.find(arg, "TileVertices") then
		if lh_readBeziers then
			lh_readBezierTile = true;
			lh_readBezierCurves = false;
			lh_readBeziers = false;
		end
	end
	
	if nil ~= string.find(arg, "Sprites") then
		if readParallax then
			readParallaxSprites = true
			readParallax = false
		end
	end

	if arg == "Gravity" then
		readGravity = true;
	end
	
	if nil ~= string.find(arg, "ShapeFixtures") then
		lh_readFixture = true
	end
	
	if nil ~= string.find(arg, "SafeFrame") then
		readSafeFrame = true
	end

end

local function lh_pushValue(arg)
--	print("CURRENT KEY " .. lh_currentKey)	
--	print(lh_currentKey)
--	print("VALUE")
--	print(arg)
	
	if lh_readAnims then
		lh_currentAnimInfo[lh_currentKey] = arg
	end

	if readParallax then
		currentParallaxInfo[lh_currentKey] = arg
	end
	
	if lh_readSprites then
		lh_currentSpriteInfo[lh_currentKey] = arg
	end
	
	if readJoints then
		currentJointInfo[lh_currentKey] = arg
	end
	
	if readWB then
		wbInfo[lh_currentKey] = arg
	end
	
	if lh_readAnimFrames then
		lh_currentFrameInfo[lh_currentKey] = arg
	end

	if lh_readBeziers then
		lh_currentBezierInfo[lh_currentKey] = arg
	end
	
	if lh_readBezierCurves then
		lh_currentCurveInfo[lh_currentKey] = arg
	end
	
	if lh_readBezierTile then
		lh_currentTileInfo[#lh_currentTileInfo+1] = arg
	end
	
	if readParallaxSprites then
		currentParallaxSprInfo[lh_currentKey] = arg
	end
	
	if lh_readFixture then
		lh_currentFixtureInfo[#lh_currentFixtureInfo+1] = arg
	end
	
	if readGravity then
		gravityInfo = lh_pointFromString(arg)
		readGravity = false
	end
	
	if readGameWorldSize then
		gameWorldSizeInfo = lh_rectFromString(arg)
		readGameWorldSize = false
	end
	
	if readSafeFrame then
		lh_safeFrame = arg;
		readSafeFrame = false;
	end
end


local function lh_stringValue(arg)
	lh_pushValue(arg)
end

local function lh_emptyStringValue(arg)
	lh_pushValue(" ")
end
local function lh_numberValue(arg)
	lh_pushValue(tonumber(arg))
end

local function lh_boolValue(arg)
	lh_pushValue(arg)
end


local function lh_arrayBegin(arg)
	lh_array = lh_array+1	
end

local function lh_noArray(arg)

	lh_readFixture = false	
	lh_readAnimFrames = false

	if(lh_readBeziers)then
		lh_readBeziers = false;
	end
	if lh_readBezierTile then
		lh_readBeziers = true;
	end
	
	lh_readBezierTile = false
	readParallaxSprites = false
	lh_readAnims = false		
	readParallax = false
	readJoints = false	
end


local function lh_arrayEnd(arg)
	lh_array = lh_array-1

	if lh_array == 0 then
		lh_readAnims = false
		lh_readBeziers = false
		lh_readBezierTile = false
		lh_readBezierCurves = false
		readParallax = false
		lh_readSprites = false
		readJoints = false
	end
		
	if lh_array == 2 then
		if lh_readFixture then
			lh_currentPolygonInfo[#lh_currentPolygonInfo+1] = lh_deepcopy(lh_currentFixtureInfo)
			--for k,v in pairs(lh_currentFixtureInfo) do v=nil end
			lh_currentFixtureInfo = nil;
			lh_currentFixtureInfo = {}
		end
	end
	
	if lh_array == 1 then
			
		if lh_readAnimFrames then
			lh_currentAnimInfo["Frames"] = lh_deepcopy(lh_currentAnimFramesInfo)
			--for k,v in pairs(lh_currentAnimFramesInfo) do v=nil end
			lh_readAnims = true
			lh_readAnimFrames= false
				
			lh_currentAnimFramesInfo = nil
			lh_currentAnimFramesInfo = {}
		end

		if lh_readBezierCurves then
			lh_currentBezierInfo["Curves"] = lh_deepcopy(lh_currentBezierCurveInfo)
			--for k,v in pairs(lh_currentBezierCurveInfo) do v=nil end
			lh_readBeziers = true
			lh_readBezierCurves= false
				
			lh_currentBezierCurveInfo = nil
			lh_currentBezierCurveInfo = {}
		end

		if readParallaxSprites then
			currentParallaxInfo["Sprites"] = lh_deepcopy(currentParallaxSpritesInfo)
			--for k,v in pairs(currentParallaxSpritesInfo) do v=nil end
			readParallax = true
			readParallaxSprites= false
				
			currentParallaxSpritesInfo = nil
			currentParallaxSpritesInfo = {}
		end

		if lh_readBezierTile then
			lh_currentBezierInfo["TileVertices"] = lh_deepcopy(lh_currentBezierTileInfo)
			--for k,v in pairs(lh_currentBezierTileInfo) do v=nil end
			lh_readBeziers = true
			lh_readBezierTile = false
			
			lh_currentBezierTileInfo = nil;
			lh_currentBezierTileInfo = {}
		end
		
		if lh_readFixture then
			lh_currentSpriteInfo["ShapeFixtures"] = lh_deepcopy(lh_currentPolygonInfo)
			--for k,v in pairs(lh_currentPolygonInfo) do v=nil end
			lh_readFixture = false
			--currentFixture = 0
			lh_currentPolygonInfo = nil
			lh_currentPolygonInfo = {}
		end
	end
	
	if lh_array == 2 then
		if lh_readBezierTile then
			lh_currentBezierTileInfo[#lh_currentBezierTileInfo+1] = lh_deepcopy(lh_currentTileInfo)
			--for k,v in pairs(lh_currentTileInfo) do v=nil end
			lh_currentTileInfo = nil
			lh_currentTileInfo = {}
		end
	end
end

local function lh_dictBegin(arg)
	lh_dict = lh_dict+1
end
   		
   		------------------------------------------------------------------------
   		------------------------------------------------------------------------
   		------------------------------------------------------------------------
   		for line in file:lines() do
   		--print(line)
			string.gsub(line, "<key>(.*)</key>", lh_key)
			string.gsub(line, "<string>(.*)</string>", lh_stringValue)
			string.gsub(line, "<string></string>", lh_emptyStringValue)
			string.gsub(line, "<real>(.*)</real>", lh_numberValue)
			string.gsub(line, "<integer>(.*)</integer>", lh_numberValue)
	
			if nil ~= string.find(line, "<true/>") then
				lh_boolValue(true)
			end
			if nil ~= string.find(line, "<false/>") then
				lh_boolValue(false)
			end
	
			string.gsub(line, "<dict>", lh_dictBegin)

			if nil ~= string.find(line, "</dict>") then
				dictEnd()
			end

			string.gsub(line, "<array>", lh_arrayBegin)
			string.gsub(line, "</array>", lh_arrayEnd)
			string.gsub(line, "<array/>", lh_noArray)
		end
    	
   		io.close (file)
	else
    	print( "Level file not found. Please add your level in the project directory." )
	end

	self.LHGravityInfo = gravityInfo
	self.LHGameWorldSize = gameWorldSizeInfo

 	local point = lh_pointFromString(lh_safeFrame)   	
 	LHSettings:sharedInstance().levelDeviceWidth 	= point.x
	LHSettings:sharedInstance().levelDeviceHeight 	= point.y
					
--------------------------------------------------------------------------------					
	
 --For debuging
 --[[
 	for i = 1, #self.LHAnims do
	print("-----------------------------------------------------------------------")
	print("ANIM INFO")
	print("-----------------------------------------------------------------------")
		for k, v in pairs (self.LHAnims[i]) do
			print(k)
			print(v)
			if nil ~= string.find(k, "Frames") then
			print("------------------------")
				for fk, fv in pairs (v) do
					for ffk, ffv in pairs (fv) do
						print(ffk)
						print(ffv)
					end
				end	
			print("------------------------")
			end
		end
	end
	
	print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")


print("BEZIER SIZE")
print(#self.LHBeziers)

	for i = 1, #self.LHBeziers do
	print("-----------------------------------------------------------------------")
	print("BEZIER INFO")
	print("-----------------------------------------------------------------------")
		for k, v in pairs (self.LHBeziers[i]) do
			print(k)
			print(v)
			if nil ~= string.find(k, "Curves") then
			print("------------------------")
				for fk, fv in pairs (v) do
					print("-->>>>")
					for ffk, ffv in pairs (fv) do
						print(ffk)
						print(ffv)
					end
				end	
			print("------------------------")
			end
		end
	end

	print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
	


	for i = 1, #self.LHParallax do
	print("-----------------------------------------------------------------------")
	print("PARALLAX INFO")
	print("-----------------------------------------------------------------------")
		for k, v in pairs (self.LHParallax[i]) do
			print(k)
			print(v)
			if nil ~= string.find(k, "Sprites") then
			print("------------------------")
				for fk, fv in pairs (v) do
					print("-->>>>")
					for ffk, ffv in pairs (fv) do
						print(ffk)
						print(ffv)
					end
				end	
			print("------------------------")
			end
		
		end
	end
	print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")

	for i = 1, #self.LHJoints do
	print("-----------------------------------------------------------------------")
	print("JOINT INFO")
	print("-----------------------------------------------------------------------")
		for k, v in pairs (self.LHJoints[i]) do
			print(k)
			print(v)
		end
	end

	print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")

	for i = 1, #self.LHSprites do
	print("-----------------------------------------------------------------------")
	print("SPRITE INFO")
	print("-----------------------------------------------------------------------")
		for k, v in pairs (self.LHSprites[i]) do
			print(k)
			print(v)
		end
	end
	
--	print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
	for i = 1, #self.LHWbInfo do
	print("-----------------------------------------------------------------------")
	print("WB INFO")
	print("-----------------------------------------------------------------------")
		for k, v in pairs (self.LHWbInfo[i]) do
			print(k)
			print(v)
		end
	end
	--]]
	--print("WORLD_BOUNDARIES")
	--print(worldBoundaries)		
end













