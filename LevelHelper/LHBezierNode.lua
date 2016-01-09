require "LHHelpers"

LHBezierNode = {}
function LHBezierNode:initWithDictionary(properties, physics)
	if (nil == properties) then
		print("Invalid LHBezierNode initialization!")
	end
	
	local object = {isClosed = properties["IsClosed"],
					lhUniqueName = properties["UniqueName"],
					isTile = properties["IsTile"],
					isVisible = properties["IsDrawable"],
					isLine = properties["IsSimpleLine"],
					isPath = properties["IsPath"],
					pathPoints = {},
					--pathNodes = {},
					lhTag = properties["Tag"],
					color = lh_rectFromString(properties["Color"]),
					lineWidth = properties["LineWidth"],
					lineColor = lh_rectFromString(properties["LineColor"]),
					winSize = {},
					imageSize = {},
					shape = display.newGroup()
					}
	setmetatable(object, { __index = LHBezierNode })  -- Inheritance	
	
	object:initTileVerticesFromDictionary(properties)
	if(nil ~= physics)then
		object:constructPhysicObjectFromDictionary(properties, physics)
	end
	object:constructPathPoints(properties)
		
	lh_addToDirectorGroup(object.shape)
	
	return object
end
--------------------------------------------------------------------------------
function LHBezierNode:removeSelf()
	
	--print("BEZIER RemoveSelf " .. self.lhUniqueName)

	self.isClosed = nil
	self.lhUniqueName = nil
	self.isTile = nil
	self.isVisible = nil
	self.isLine = nil
	
	for i = 1, #self.pathPoints do self.pathPoints[i]=nil end
	self.pathPoints = nil
	
	self.isPath = nil	
	self.tag = nil
	self.color = nil
	self.lineWidth = nil
	self.lineColor = nil
	self.winSize = nil
	self.imageSize = nil

--	for i = 1, #self.pathNodes do
--		local pathNode = self.pathNodes[i];
--		pathNode:removeSelf()
--		self.pathNodes[i] = nil
--	end
--	self.pathNodes = nil;
	
	if(nil ~= self.shape)then
		self.shape:removeSelf();
	end
	self.shape = nil
	
	self = nil;
end
--------------------------------------------------------------------------------
function LHBezierNode:uniqueName()
	return self.lhUniqueName;
end
--------------------------------------------------------------------------------
function LHBezierNode:setTag(tg)
	self.tag = tg;
end
--------------------------------------------------------------------------------
function LHBezierNode:tag()
	return self.tag;
end
--------------------------------------------------------------------------------
function LHBezierNode:addSpriteOnPath(lhSprite, pathSpeed, startAtEndPoint, 
						 isCyclic, restartOtherEnd, axis, flipX, flipY)
	
	pathNode = LHPathNode:initWithPoints(self.pathPoints, self.lhUniqueName);
	pathNode:setStartAtEndPoint(startAtEndPoint);
	pathNode:setSprite(lhSprite);
	pathNode.initialAngle = lhSprite.rotation;    
	pathNode:setSpeed(pathSpeed);
	pathNode.restartOtherEnd = restartOtherEnd;
	pathNode.isCyclic = isCyclic;
	pathNode.axisOrientation = axis;
	pathNode.flipX = flipX;
	pathNode.flipY = flipY;
	pathNode.isLine = self.isLine;
	--self.pathNodes[#self.pathNodes+1] = pathNode;
	
    return  pathNode;
end
--------------------------------------------------------------------------------
--PRIVATE METHODS
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function LHBezierNode:pointOnCurve(p1, p2, p3, p4, t)
	local var1
	local var2
	local var3
    local vPoint = {x = 0.0, y = 0.0}
    
    var1 = 1 - t
    var2 = var1 * var1 * var1
    var3 = t * t * t
    vPoint.x = var2*p1.x + 3*t*var1*var1*p2.x + 3*t*t*var1*p3.x + var3*p4.x
    vPoint.y = var2*p1.y + 3*t*var1*var1*p2.y + 3*t*t*var1*p3.y + var3*p4.y

	return vPoint;
end
--------------------------------------------------------------------------------
function LHBezierNode:constructPhysicObjectFromDictionary(bezierDict, physics)

	if(self.isPath)then
		return
	end

	local ptype = bezierDict["PhysicType"]
    if( 3 == ptype)then --no physics - dont create bodies
	    return;
    end
	
	local convert = {x = 1.0, y = 1.0};
	local winSize = {width = 320, height = 480};
    
	local sdensity 		= bezierDict["Density"]
	local sfriction 	= bezierDict["Friction"]
	local srestitution 	= bezierDict["Restitution"]
		
    local collisionFilter = { 	categoryBits = bezierDict["Category"], 
								maskBits 	 = bezierDict["Mask"], 
								groupIndex 	 = bezierDict["Group"] } 

	local physicType = "static"
	if ptype == 1 then
		physicType = "kinematic"
	elseif ptype == 2 then
		physicType = "dynamic"
	end

	local finalBodyShape = {}
	local currentFixInfo;
	local currentShape = {}
	
	local fixtures = bezierDict["TileVertices"];
	if(nil ~= fixtures) then
		for i = 1, #fixtures do
    	    local triangle = fixtures[i];
        
			for j = 1, #triangle do	
				local pointString = triangle[j];
				local point	= lh_pointFromString(pointString)	
			
				currentShape[#currentShape+1] = point.x
				currentShape[#currentShape+1] = point.y
	
			end
			
			triangle = nil;
		
			currentFixInfo = { density = sdensity,
							   friction = sfriction,
							   bounce = srestitution,
							   shape = lh_deepcopy(currentShape),
							   filter = scollisionFilter
								 }
			currentShape = nil
			currentShape = {}
			currentShapeRevised = nil
			currentShapeRevised = {}
			finalBodyShape[#finalBodyShape+1] = currentFixInfo;
		end
		
		self.shape.lhUniqueName = self.lhUniqueName;
		physics.addBody( self.shape, 
					 physicType,
					 unpack(finalBodyShape))
					 
		self.shape.lhTag = self.lhTag;
		self.shape.isFixedRotation = false
		self.shape.isSensor = bezierDict["IsSenzor"]	
    	return
    end
        
	local curves = bezierDict["Curves"]
	local MAX_STEPS = 25;

	local finalBodyShape = {}
	local currentFixInfo;
	local currentShape = {}
	
	for i= 1, #curves do
		
		local curve = curves[i]
    	local endCtrlPt   = lh_pointFromString(curve["EndControlPoint"])
        local startCtrlPt = lh_pointFromString(curve["StartControlPoint"])
        local endPt       = lh_pointFromString(curve["EndPoint"])
        local startPt     = lh_pointFromString(curve["StartPoint"])
  
  		if false == self.isLine then
	  		
  			local prevPoint
            local firstPt = true
            
            local t = 0.0
            while ( t >= 0.0 and  t <= 1 + (1.0 / MAX_STEPS) ) do
            	local vPoint = self:pointOnCurve(startPt, startCtrlPt, endCtrlPt, endPt, t)
				            
                if false == firstPt then

  					currentShape[#currentShape+1] = prevPoint.x*convert.x
		 			currentShape[#currentShape+1] = prevPoint.y*convert.y
		 			currentShape[#currentShape+1] = vPoint.x*convert.x
		 			currentShape[#currentShape+1] = vPoint.y*convert.y
		 					 			
						   
				   currentFixInfo = { density 	= sdensity,
									   friction = sfriction,
									   bounce 	= srestitution,
									   shape 	= lh_deepcopy(currentShape),
									   filter 	= collisionFilter }
						  			   
					finalBodyShape[#finalBodyShape+1] = currentFixInfo;
					
					currentShape = nil;
					currentShape = {}
					currentFixInfo = nil
	
                end
                
                prevPoint = vPoint;
                firstPt = false;
        
        		t = t + 1.0 / MAX_STEPS
            end
            

  		else
  		
  			currentShape[#currentShape+1] = startPt.x*convert.x
			currentShape[#currentShape+1] = startPt.y*convert.y
		 	currentShape[#currentShape+1] = endPt.x*convert.x
			currentShape[#currentShape+1] = endPt.y*convert.y
		 					 			
						   
		   currentFixInfo = {  density 	= sdensity,
							   friction = sfriction,
							   bounce 	= srestitution,
							   shape 	= lh_deepcopy(currentShape),
							   filter 	= collisionFilter }
						  			   
			finalBodyShape[#finalBodyShape+1] = currentFixInfo;
					
			currentShape = nil;
			currentShape = {}
			currentFixInfo = nil
  		end					 	
	end
	
	self.shape.lhUniqueName = self.lhUniqueName;
	physics.addBody( self.shape, 
					 physicType,
					 unpack(finalBodyShape))
					 
	self.shape.lhTag = self.lhTag;
	self.shape.isFixedRotation = false
	self.shape.isSensor = bezierDict["IsSenzor"]	
	
end
--------------------------------------------------------------------------------
function LHBezierNode:initTileVerticesFromDictionary(bezierDict)

	local convert = {x = 1.0, y = 1.0};
	local winSize = {width = 320, height = 480};	

	if true == self.isVisible then
	
		local curves = bezierDict["Curves"];
		
		local MAX_STEPS = 25;

		for i = 1, #curves do
			local currentCurve = curves[i];

	    	local endCtrlPt   = lh_pointFromString(currentCurve["EndControlPoint"])
    	    local startCtrlPt = lh_pointFromString(currentCurve["StartControlPoint"])
       	 	local endPt       = lh_pointFromString(currentCurve["EndPoint"])
        	local startPt     = lh_pointFromString(currentCurve["StartPoint"])
  
			if( false == self.isLine) then
			
				local prevPoint = {};
				local firstPt = true;
				
					
		        local t = 0.0
        	    while ( t >= 0.0 and  t <= 1 + (1.0 / MAX_STEPS) ) do
            		
            		local vPoint = self:pointOnCurve(startPt, startCtrlPt, 
            										endCtrlPt, endPt, t)


					if(false == firstPt)then
					
						local point1 = {x = prevPoint.x*convert.x, 
										y = prevPoint.y*convert.y};
						local point2 = {x = vPoint.x*convert.x,
										y = vPoint.y*convert.y};
					
						self:createLineShape(point1, point2, self.lineColor);
					end
					prevPoint = vPoint
					firstPt = false;

        			t = t + 1.0 / MAX_STEPS
            	end
			else
			
				local pos1 = {x = startPt.x*convert.x,
							  y = startPt.y*convert.y};
				local pos2 = {x = endPt.x*convert.x,
							  y = endPt.y*convert.y};
							  
				self:createLineShape(pos1, pos2, self.lineColor);
								
			end
  		end
	end
	
	local fixtures = bezierDict["TileVertices"];
	if(nil ~= fixtures) then
		for i = 1, #fixtures do
    	    local triangle = fixtures[i];
        
       	 local shapeTriangle = {}
			for j = 1, #triangle do	
				local pointString = triangle[j];
				local point	= lh_pointFromString(pointString)	
			
				shapeTriangle[#shapeTriangle+1] = point;
			end
		
			self:createShape(shapeTriangle, self.color)
    	end
    end
        
end
--------------------------------------------------------------------------------
function LHBezierNode:constructPathPoints(bezierDict)

	if false == self.isPath then
		return
	end

	local convert = {x = 1.0, y = 1.0};
	local winSize = {width = 320, height = 480};	

	local curves = bezierDict["Curves"]
	local MAX_STEPS = 25;

	for i= 1, #curves do
		
		local curve = curves[i]
    	local endCtrlPt   = lh_pointFromString(curve["EndControlPoint"])
        local startCtrlPt = lh_pointFromString(curve["StartControlPoint"])
        local endPt       = lh_pointFromString(curve["EndPoint"])
        local startPt     = lh_pointFromString(curve["StartPoint"])

  		if false == self.isLine then
            local t = 0.0
            while ( t >= 0.0 and  t <= 1 + (1.0 / MAX_STEPS) ) do
            	local vPoint = self:pointOnCurve(startPt, startCtrlPt, endCtrlPt, endPt, t)
				            
				self.pathPoints[#self.pathPoints+1] = {x = vPoint.x*convert.x, y = vPoint.y*convert.y}
                        
        		t = t + 1.0 / MAX_STEPS
            end
            
			table.remove(self.pathPoints,#self.pathPoints)
  		else

			self.pathPoints[#self.pathPoints+1] = { x = startPt.x*convert.x, y = startPt.y*convert.y}
			if(i == #curves)then
				self.pathPoints[#self.pathPoints+1] = { x = endPt.x*convert.x, y = endPt.y*convert.y}
			end
  		end					 	
	end

end
--------------------------------------------------------------------------------
function LHBezierNode:createLineShape(pt1, pt2, color)

 local line = display.newLine(pt1.x, pt1.y, pt2.x, pt2.y)
 self.shape:insert(line)
 line.width = self.lineWidth
 line:setColor(color.origin.x*255, color.origin.y*255, color.size.width*255, 255)           
 
end
--------------------------------------------------------------------------------
function LHBezierNode:createShape(poly, color)
 
    local newLine = display.newLine
    local math_floor = math.floor
    local math_min = math.min
    local math_max = math.max
    local n = #poly
 
    local minY = poly[1].y
    local maxY = poly[1].y
 
    for i = 2, n do
        minY = math_min(minY, poly[i].y)
        maxY = math_max(maxY, poly[i].y)
    end
 
    for y = minY, maxY do
 
        local ints = {}
        local int = 0
        local last = n
 
        for i = 1, n do
            local y1 = poly[last].y
            local y2 = poly[i].y
            if y1 < y2 then
                local x1 = poly[last].x
                local x2 = poly[i].x
                if (y >= y1) and (y < y2) then
                    int = int + 1
                    ints[int] = math_floor((y - y1) * (x2 - x1) / (y2 - y1) + x1)
                end
            elseif y1 > y2 then
                local x1 = poly[last].x
                local x2 = poly[i].x
                if (y >= y2) and (y < y1) then
                    int = int + 1
                    ints[int] = math_floor((y - y2) * (x1 - x2) / (y1 - y2) + x2)
                end
            end
            last = i
        end
 
        local i = 1
        while i < int do
            local line = newLine(ints[i], y, ints[i + 1], y)
            self.shape:insert(line)
            line:setColor(color.origin.x*255, color.origin.y*255, color.size.width*255, 255)
            i = i + 2
        end
    end
end
--------------------------------------------------------------------------------
