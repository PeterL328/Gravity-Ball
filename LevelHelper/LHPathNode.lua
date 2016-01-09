require "LHHelpers"
require "LHBezierNode"

LHPathNode = {}
function LHPathNode:initWithPoints(points, name)
	if (nil == points) then
		print("Invalid LHPathNode initialization!")
	end
		
	local object = {coronaSprite = nil,
					lhUniqueName = name,
					pathPoints = lh_deepcopy(points),
					speed = 0.2,
					interval = 0.01,
					startAtEndPoint = false,
					isCyclic = false,
					flipX = false,
					flipY = false,
					restartOtherEnd = false,
					axisOrientation = 0, -- 1 is x 2 is y
					currentPoint = 1,
					elapsed = 0.0,
					initialAngle = 0,
					time = os.clock(),
					isLine = true,
					paused = false,
					pathNotifierId = nil,
					prevPathPosition = {x = 0, y = 0},
					firstTime = true
					}
	setmetatable(object, { __index = LHPathNode })  -- Inheritance	
		
	if(#object.pathPoints > 0)then
        object.prevPathPosition =  object.pathPoints[1];
    end
    
	Runtime:addEventListener( "enterFrame", object )

	return object
end
--------------------------------------------------------------------------------
function LHPathNode:removeSelf()
	
	self.coronaSprite = nil;
	self.lhUniqueName = nil;
	
	Runtime:removeEventListener("enterFrame", self);
	print("path remove self");
	--for i = 1, #self.pathPoints do self.pathPoints[i]=nil end
	self.pathPoints = nil
	
	self.speed = nil
	self.interval = nil
	self.startAtEndPoint = nil
	self.isCyclic = nil
	self.restartOtherEnd = nil
	self.axisOrientation = nil
	self.currentPoint = nil
	self.elapsed = nil
	self.initialAngle = nil
	self.time = nil
	self.isLine = nil
	self.paused = nil
	self.pathNotifierId = nil
	self.pathNotifierSel= nil
	self.firstTime = nil
	
	self = nil;
end
--------------------------------------------------------------------------------
function LHPathNode:uniqueName()
	return self.lhUniqueName;
end
--------------------------------------------------------------------------------
function LHPathNode:setSpeed(val)
	self.speed = val;
	self.interval = self.speed/(#self.pathPoints-1);	
end
--------------------------------------------------------------------------------
function LHPathNode:speed()
	return self.speed;
end
--------------------------------------------------------------------------------
function LHPathNode:setPaused(val)
	self.paused = val
end
--------------------------------------------------------------------------------
function LHPathNode:isPaused()
	return self.paused;
end
--------------------------------------------------------------------------------
function LHPathNode:setStartAtEndPoint(val)
	self.startAtEndPoint = val;
    
    if(self.startAtEndPoint == 1)then
    	self.pathPoints = self:inversePoints(self.pathPoints)
    end
end
--------------------------------------------------------------------------------
function LHPathNode:setSprite(sprite)
	self.coronaSprite = sprite
	if(#self.pathPoints > 0)then
        self.prevPathPosition =  self.pathPoints[1];
    end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--PRIVATE METHODS
--------------------------------------------------------------------------------
function LHPathNode:inversePoints(points)

	local invertedPoints = {}
	for i = #points,1,-1 do
		invertedPoints[#invertedPoints+1] = points[i]
	end
	
	points = nil;
	return invertedPoints
end
--------------------------------------------------------------------------------
function LHPathNode:rotationDegreeFromPoint ( srcObj, dstObj )
 
	local xDist = dstObj.x-srcObj.x
   	local yDist = dstObj.y-srcObj.y
    local angleBetween = math.deg( math.atan( yDist/xDist ) )
        
    if ( srcObj.x < dstObj.x ) then 
        angleBetween = angleBetween+90
    else 
        angleBetween = angleBetween-90 
    end
        
    return angleBetween
end
--------------------------------------------------------------------------------
function LHPathNode:MIN(A, B)

	if(A < B)then
		return A;
	else
		return B;
	end
	
	return A;
end
--------------------------------------------------------------------------------
function LHPathNode:enterFrame( event )
        
    --    print("path print");
    if(self == nil)then
	    return;
    end
    
	if(self.firstTime)then
		self.time = event.time/1000
		self.firstTime = false
	end

	if(nil == self.coronaSprite)then
		return;
	end
	
	if(self.paused)then 
		self.time 	  = event.time/1000 
		return;
	end
	
	if(nil == self.pathPoints)then
		return;
	end
    
	local startPosition = self.pathPoints[self.currentPoint];
	local previousPoint = self.currentPoint -1;
	if(previousPoint < 1)then
		previousPoint = 1;
	end
	
	local prevPosition = self.pathPoints[previousPoint];
	local endPosition = startPosition;
		
	local startAngle = self:rotationDegreeFromPoint(startPosition,prevPosition)
	if(self.currentPoint == 1)then
		startAngle = self.initialAngle-90;
	end
	
	local endAngle = startAngle;
	
	if( (self.currentPoint + 1) <= #self.pathPoints)then
		endPosition = self.pathPoints[self.currentPoint+1]
		endAngle = self:rotationDegreeFromPoint(endPosition,startPosition);		
	else 
		if(self.isCyclic)then
	
			if(false == self.restartOtherEnd)then
				self.pathPoints = self:inversePoints(self.pathPoints)
			end
			
			if(self.flipX)then
				self.coronaSprite.xScale = -1*self.coronaSprite.xScale;
			end
			
			if(self.flipY)then
				self.coronaSprite.yScale = -1*self.coronaSprite.yScale;
			end
			
			self.currentPoint = 0;
		end
        
        if(nil ~= self.pathNotifierId)then    
	        self.pathNotifierId(self.coronaSprite, self.lhUniqueName)

			if(false == self.isCyclic)then
                self.paused = true;
            end
        end
	end
	
	if(self.axisOrientation == 1)then
		startAngle =startAngle+ 90.0;
	end
	if(self.axisOrientation == 1)then
		endAngle = endAngle + 90.0;
	end
	
	if(startAngle > 360)then
		startAngle = startAngle - 360;
	end
	if(endAngle > 360)then
		endAngle = endAngle - 360;
	end
		
	local t = self:MIN(1.0, self.elapsed/self.interval);
	
	local deltaP = lh_Sub( endPosition, startPosition );

	local newPos = {x = startPosition.x + deltaP.x * t, 
					y = startPosition.y + deltaP.y * t};
            
	if(startAngle > 270 and startAngle < 360 and
	   endAngle > 0 and endAngle < 90)then
		startAngle = startAngle - 360;
	end
	
	
	if(startAngle > 0 and startAngle < 90 and
	   endAngle < 360 and endAngle > 270)then
		startAngle = startAngle + 360;
	end
	
	local deltaA = endAngle - startAngle;
	local newAngle = startAngle + deltaA*t;

	if(newAngle > 360)then
		newAngle = newAngle - 360;
	end
	
	if(nil ~= self.coronaSprite)then
		local sprPos = {x = self.coronaSprite.x, y = self.coronaSprite.y};
		local sprDelta={ x = newPos.x - self.prevPathPosition.x, y = newPos.y - self.prevPathPosition.y};
		
		self.coronaSprite.x = sprPos.x + sprDelta.x;
		self.coronaSprite.y = sprPos.y + sprDelta.y;
		
		self.prevPathPosition = newPos;		
	end


	if(self.axisOrientation ~= 0)then
		self.coronaSprite.rotation = newAngle;
	end
	
	if(self.isLine)then
		if(self.axisOrientation ~= 0)then
			self.coronaSprite.rotation = endAngle;
		end
	end
	
	local dist = lh_Distance(self.prevPathPosition, endPosition);
		
	if(0.001 > dist)then
		if(self.currentPoint + 1 <= #self.pathPoints)then
			self.elapsed = 0;
			self.currentPoint =self.currentPoint+ 1;     
		end
	end
    
	self.elapsed  = self.elapsed + (event.time/1000 - self.time)
	self.time 	  = event.time/1000 

end
--------------------------------------------------------------------------------