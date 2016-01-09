require "LevelHelperLoader"
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function LevelHelperLoader:jointsWithTag(tag)
	joints = {}
	for k, v in pairs (self.loadedJoints) do		
		if v ~= nil then
			if v.tag == tag then
				joints[#joints+1] = v;
			end
		end
	end	
	return joints;
end
--------------------------------------------------------------------------------		
function LevelHelperLoader:removeJointWithUniqueName(jointName)
	joint = self:jointWithUniqueName(jointName)
	self:removeJoint(joint)
end
--------------------------------------------------------------------------------
function LevelHelperLoader:removeAllJoints()
	for k, v in pairs (self.loadedJoints) do		
		self:removeJoint(v)
	end
end
--------------------------------------------------------------------------------
function LevelHelperLoader:removeAllJointsWithTag(tag)
	for k, v in pairs (self.loadedJoints) do		
		if v.tag == tag then
			self:removeJoint(v)
		end
	end
end
--------------------------------------------------------------------------------
function LevelHelperLoader:removeAllJointsWithType(jointType)
	for k, v in pairs (self.loadedJoints) do		
		if v.type == jointType then
			self:removeJoint(v)
		end
	end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------