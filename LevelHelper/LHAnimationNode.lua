require "LHHelpers"
require "LHAnimationsMgr"
--------------------------------------------------------------------------------
LHAnimationNode = {}
function LHAnimationNode:initWithDictionary(properties)
	if (nil == properties) then
		print("Invalid LHAnimationNode initialization!")
	end
	
	local object = {uniqueName = properties["UniqueName"],
					startAtLaunch = properties["StartAtLaunch"],
					image = properties["Image"],
					repetitions = properties["Repetitions"],
					speed = properties["Speed"],
					loop = properties["LoopForever"],	
					framesInfo = lhAnimatioNodeGetFramesTableFromDictionary(properties),
					nodeImagePath = nil,
					sheetData = nil,
					processedFrames = nil
					}
					

	setmetatable(object, { __index = LHAnimationNode })  -- Inheritance	
	
	local sprite = require("sprite")
	local settings = LHSettings:sharedInstance();
	
	local nodeImg, rectMultiplier = settings:correctedImageFileAndTextureRect(object.image)
		
	local spr_size = lh_rectFromString(object.framesInfo[1].rect).size
	local nodeSheetData = lhAnimationNodeSheetDataForAnimNode(object, spr_size, rectMultiplier)

	object.nodeImagePath = nodeImg;
	object.sheetData = nodeSheetData;
	object.processedFrames = lhAnimationNodeFramesArrayWithSize(#object.framesInfo);

	return object
end
--------------------------------------------------------------------------------
function LHAnimationNode:removeSelf()

--	print("ANIMAITION NODE REMOVE SELF")

	self.uniqueName = nil;
	self.startAtLaunch = nil;
	self.image = nil;
	self.repetitions = nil;
	self.speed = nil;
	self.loop = nil;
	self.framesInfo = nil;	
	self = nil;
end
--------------------------------------------------------------------------------
function lhAnimationNodeSheetDataForSprite(name, uvRect, size, rectMultiplier)

local sheet = { 
frames = {
			{
				name = name,
				spriteColorRect = { x = uvRect.origin.x*rectMultiplier, 
									y = uvRect.origin.y*rectMultiplier, 
									width = uvRect.size.width*rectMultiplier, 
									height = uvRect.size.height*rectMultiplier }, 
				textureRect = { x = uvRect.origin.x*rectMultiplier, 
								y = uvRect.origin.y*rectMultiplier, 
								width = uvRect.size.width*rectMultiplier, 
								height = uvRect.size.height*rectMultiplier }, 
				spriteSourceSize = { width = size.width, 
									 height= size.height}, 
				spriteTrimmed = false,
				textureRotated = false
			},
		}
	}

	return sheet
end
--------------------------------------------------------------------------------
function lhAnimationNodeSheetDataForAnimNode(animNode, size, rectMultiplier)

	local sheet = { frames = {} };

	for j = 1, #animNode.framesInfo do
				
		local curFrame = animNode.framesInfo[j]
				
		local uvRect = lh_rectFromString(curFrame.rect)
		local frameName = curFrame.name
					
		sheet.frames[#sheet.frames +1] = 
		{
			name = frameName,
			spriteColorRect = { x = uvRect.origin.x*rectMultiplier, 
								y = uvRect.origin.y*rectMultiplier, 
								width = uvRect.size.width*rectMultiplier, 
								height = uvRect.size.height*rectMultiplier }, 
			textureRect = { x = uvRect.origin.x*rectMultiplier, 
							y = uvRect.origin.y*rectMultiplier, 
							width = uvRect.size.width*rectMultiplier, 
							height = uvRect.size.height*rectMultiplier }, 
			spriteSourceSize = { width = size.width, 
								 height= size.height}, 
			spriteTrimmed = false,
			textureRotated = false
		}
	end		
	return sheet
end
--------------------------------------------------------------------------------
function lhAnimationNodeFramesArrayWithSize(size)
	
	local frmArray = {}
	for i=1, size do
		frmArray[#frmArray+1] = i
	end
	
	return frmArray
end
--------------------------------------------------------------------------------
--MemUsage: 331.2822265625
--TexMem:   22.28224

function spriteFromAnimationsNodesAndSpriteInfo(animationNodes, spriteInfo, animationsSheet)



	local sprite = require("sprite")
	
	local settings = LHSettings:sharedInstance();
	
	local spr_name = spriteInfo["UniqueName"]
	local spr_animName = spriteInfo["AnimName"];
	local tag = spriteInfo["Tag"];
	local spr_image, rectMultiplier = settings:correctedImageFileAndTextureRect(spriteInfo["Image"])


	local spr_uvRect = lh_rectFromString(spriteInfo["UV"])
	local spr_size = lh_sizeFromString(spriteInfo["Size"])
		
	local sheedDataForSprite = lhAnimationNodeSheetDataForSprite(spr_name, spr_uvRect, spr_size, rectMultiplier);
	
	local animationsListOnSprite = LHAnimationsMgr:sharedInstance():animationsOnSpriteWithName(spr_name);
		
	if(animationsListOnSprite == nil)then
		animationsListOnSprite = LHAnimationsMgr:sharedInstance():animationsOnSpritesWithTag(tag);
	end
		
	local startAtLaunch = false;
	local seqName = spr_name;

	local sheetForSprite = sprite.newSpriteSheetFromData(spr_image,
														 system.ResourceDirectory,
														 sheedDataForSprite )		
														 
	animationsSheet[#animationsSheet +1] = sheetForSprite;
	
	if(nil == sheetForSprite)then
		print("Sheet for sprite is nil. Something is very wrong");
		return nil;
	end
	
	local multiSetArray = {{ sheet = sheetForSprite, 
							frames = {1},
							lhSeqName = spr_name,  
							lhStartFrm = 1, 
							lhFrmCount = 1, 
							lhTime = 1000, 
							lhRepetitions = 0}};
		
	if((spr_animName ~= nil and "" ~=  spr_animName and " " ~=  spr_animName and "No Animation" ~= spr_animName))
		or 
		(nil ~= animationsListOnSprite) then


		
	local startFrame = 2;
	for i = 1, #animationNodes do
		local curNode = animationNodes[i];
	
		local loop = 0;
		if false == curNode.loop then
			loop = curNode.repetitions
		end

		local speed = curNode.speed;
		if(speed < 0.001)then
			speed = 0.001
		end
		speed = speed*(#curNode.framesInfo)*1000;


		if spr_animName == curNode.uniqueName then		
		
			local newsheet = sprite.newSpriteSheetFromData(curNode.nodeImagePath,
	 											 system.ResourceDirectory,		
	 											 curNode.sheetData )	 														 
	 											 
	 		animationsSheet[#animationsSheet +1] = newsheet;
			
			multiSetArray[1] = {sheet = newsheet, 
								frames = curNode.processedFrames,
								lhSeqName = curNode.uniqueName,  
								lhStartFrm = 1, 
								lhFrmCount = #curNode.framesInfo, 
								lhTime = speed, 
								lhRepetitions = loop };	
								
			startAtLaunch = curNode.startAtLaunch;
			seqName = curNode.uniqueName;
			startFrame = 1+ #curNode.framesInfo;	
		else
		
			if(nil ~= animationsListOnSprite)then
			if(nil ~= animationsListOnSprite[curNode.uniqueName])then
					
			local newsheet = sprite.newSpriteSheetFromData(curNode.nodeImagePath,
	 														 system.ResourceDirectory,
	 														 curNode.sheetData )	 														 

			multiSetArray[#multiSetArray+1] = {	sheet = newsheet, 
											  	frames = curNode.processedFrames,
												lhSeqName = curNode.uniqueName,  
												lhStartFrm = startFrame, 
												lhFrmCount = #curNode.framesInfo, 
												lhTime = speed, 
												lhRepetitions = loop };	

			animationsSheet[#animationsSheet +1] = newsheet;
			
			startFrame = startFrame + #curNode.framesInfo;	
			end
			end
		end	
	end

	end --end long if with or


local spriteMultiSet = nil

	if(#multiSetArray > 1)then
		spriteMultiSet = sprite.newSpriteMultiSet(multiSetArray)
	else
		spriteMultiSet = sprite.newSpriteSet(multiSetArray[1].sheet, 
											 multiSetArray[1].lhStartFrm, 
											 multiSetArray[1].lhFrmCount);
	end


	for i=1, #multiSetArray do
		local info = multiSetArray[i];
						
		sprite.add(spriteMultiSet, info.lhSeqName, 
								   info.lhStartFrm,
								   info.lhFrmCount,
								   info.lhTime,
								   info.lhRepetitions);
	end

	coronaSprite = sprite.newSprite( spriteMultiSet )
	coronaSprite.xScale = coronaSprite.xScale/rectMultiplier
	coronaSprite.yScale = coronaSprite.yScale/rectMultiplier
		
	coronaSprite:prepare(seqName)
	
	coronaSprite.currentFrame = coronaSprite.currentFrame+1;
	coronaSprite.currentFrame = coronaSprite.currentFrame-1;
	
--	sheetForSprite:dispose()

	if(startAtLaunch)then
		coronaSprite:play()
	end
		
	return coronaSprite;

end
--------------------------------------------------------------------------------
function lhAnimatioNodeGetFramesTableFromDictionary(properties)

	local framesInfo = {}
	local currentFrame = {}
	local info = properties["Frames"]
	
	for i = 1, #info do
		local currentFrameInfo = info[i]
		
		currentFrame = {name = currentFrameInfo["SpriteName"], 
					    rect = currentFrameInfo["FrameRect"]}
					 
		framesInfo[#framesInfo+1] = currentFrame;
		
		currentFrame = nil
		currentFrame = {}
	end
	
	return framesInfo;
end
--------------------------------------------------------------------------------