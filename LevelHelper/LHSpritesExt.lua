require "LevelHelperLoader"
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function LevelHelperLoader:removeSpriteWithUniqueName(uniqueName)
	if nil ~= self.loadedSprites[uniqueName] then
		self.loadedSprites[uniqueName]:removeSelf()
		self.loadedSprites[uniqueName] = nil;
	end
end
--------------------------------------------------------------------------------
function LevelHelperLoader:removeSpritesWithTag(tag)
	for k, v in pairs (self.loadedSprites) do
		if tag == v.lhTag then
			v:removeSelf()
			self.loadedSprites[k] = nil
  		end
	end
end
--------------------------------------------------------------------------------
function LevelHelperLoader:isSpriteWithUniqueNameInLevel(uniqueName)
	if nil ~= self.loadedSprites[uniqueName] then
		return true
	end
	return false
end
--------------------------------------------------------------------------------
