
LHJoint = {}
function LHJoint:initWithDictionary(property, crnJoint, jointType, lhSprA, lhSprB)
	if property == nil or nil == crnJoint then
		print("Invalid LHJoint init!")
		return nil;
	end
	local object = {lhTag = property["Tag"],
					lhUniqueName = property["UniqueName"],
					coronaJoint = crnJoint,
					type = jointType,
					lhSpriteA = lhSprA,
					lhSpriteB = lhSprB,
					customValues = {}
					}
	setmetatable(object, { __index = LHJoint })  -- Inheritance	
	
	return object
end
--------------------------------------------------------------------------------
function LHJoint:tag()
	return self.tag;
end
--------------------------------------------------------------------------------
function LHJoint:removeSelf()
		
	if(self.type ~= "weld")then
		if(nil ~= self.coronaJoint)then
			if(nil~= self.coronaJoint.removeSelf)then
				self.coronaJoint:removeSelf()
			end
		end
	else
		print("Corona SDK has a bug on weld joints. removeSelf methods is not present.")
	end
	
	self.coronaJoint = nil
	self.lhTag = nil
	self.type = nil;
	self.lhSpriteA = nil;
	self.lhSpriteB = nil;
	self.lhUniqueName = nil
	self.customValues = nil
	self = nil
end
--------------------------------------------------------------------------------
function LHJoint:setCustomValue(value, key)
	self.customValues[key] = value;
end
--------------------------------------------------------------------------------
function LHJoint:customValueForKey(key)
	return self.customValues[key];
end
--------------------------------------------------------------------------------