--[[
	Drawing UI - Is Mouse Hover on UI element script example - by Kozenomenon#0001
	can also be used for checking any other vector2, if within bounds of drawing ui element
	
	functions:
	
	LinesAreIntersecting  		
		takes 4 vectors as input representing endpoints for 2 lines. 
		will return whether lines are:
		- definitely intersecting (YES) 
		- definitely not intersecting (NO) 
		- or might be intersecting (COLLINEAR)
		for the purposes of 'is mouse hover' the code below only 
		considers it intersecting if YES is returned 
	
	IsPointWithinDrawingElement	
		takes a drawing element (Drawing.new) and a vector2.
		does simple box/bounds check so it "fails fast" first. 
		if simple check passes, does more checks for quads,tris,& circles.

	IsMouseWithinDrawingElement	
		takes a drawing element (Drawing.new). 
		gets mouse location and then checks IsPointWithinDrawingElement
		this is separated just so other points could be checked if needed
]]

local UserInputService = game:GetService("UserInputService")

function LinesAreIntersecting(ln1v1: Vector2,ln1v2: Vector2,ln2v1: Vector2,ln2v2: Vector2)
    -- https://stackoverflow.com/questions/217578/how-can-i-determine-whether-a-2d-point-is-within-a-polygon
    local d1, d2
    local a1, a2, b1, b2, c1, c2
    -- Convert vector 1 to a line (line 1) of infinite length.
    -- We want the line in linear equation standard form: A*x + B*y + C = 0
    -- See: http:--en.wikipedia.org/wiki/Linear_equation
    a1 = ln1v2.Y - ln1v1.Y
    b1 = ln1v1.X - ln1v2.X
    c1 = (ln1v2.X * ln1v1.Y) - (ln1v1.X * ln1v2.Y)
    -- Every point (x,y), that solves the equation above, is on the line,
    -- every point that does not solve it, is not. The equation will have a
    -- positive result if it is on one side of the line and a negative one 
    -- if is on the other side of it. We insert (x1,y1) and (x2,y2) of vector
    -- 2 into the equation above.
    d1 = (a1 * ln2v1.X) + (b1 * ln2v1.Y) + c1
    d2 = (a1 * ln2v2.X) + (b1 * ln2v2.Y) + c1
    -- If d1 and d2 both have the same sign, they are both on the same side
    -- of our line 1 and in that case no intersection is possible. Careful, 
    -- 0 is a special case, that's why we don't test ">=" and "<=", 
    -- but "<" and ">".
    if (d1 > 0 and d2 > 0) or (d1 < 0 and d2 < 0) then return "NO" end
    -- The fact that vector 2 intersected the infinite line 1 above doesn't 
    -- mean it also intersects the vector 1. Vector 1 is only a subset of that
    -- infinite line 1, so it may have intersected that line before the vector
    -- started or after it ended. To know for sure, we have to repeat the
    -- the same test the other way round. We start by calculating the 
    -- infinite line 2 in linear equation standard form.
    a2 = ln2v2.Y - ln2v1.Y
    b2 = ln2v1.X - ln2v2.X
    c2 = (ln2v2.X * ln2v1.Y) - (ln2v1.X * ln2v2.Y)
    -- Calculate d1 and d2 again, this time using points of vector 1.
    d1 = (a2 * ln1v1.X) + (b2 * ln1v1.Y) + c2
    d2 = (a2 * ln1v2.X) + (b2 * ln1v2.Y) + c2
    -- Again, if both have the same sign (and neither one is 0),
    -- no intersection is possible.
    if (d1 > 0 and d2 > 0) or (d1 < 0 and d2 < 0) then return "NO" end
    -- If we get here, only two possibilities are left. Either the two
    -- vectors intersect in exactly one point or they are collinear, which
    -- means they intersect in any number of points from zero to infinite.
    if ((a1 * b2) - (a2 * b1) == 0.0) then return "COLLINEAR" end
    -- If they are not collinear, they must intersect in exactly one point.
    return "YES"
end
function IsPointWithinDrawingElement(el,point: Vector2)
	-- ah, this is where the drawing element's type is hidden at 
	local eltyp = getmetatable(el).__type
	local xmin,xmax,ymin,ymax
	local pnts,rad
	if eltyp == "Triangle" then
		-- get simple box around tri for quick check
		xmin = math.min(el.PointA.X,el.PointB.X,el.PointC.X)
		xmax = math.max(el.PointA.X,el.PointB.X,el.PointC.X)
		ymin = math.min(el.PointA.Y,el.PointB.Y,el.PointC.Y)
		ymax = math.max(el.PointA.Y,el.PointB.Y,el.PointC.Y)
		-- set points array for deeper check, if simple passes
		pnts = { el.PointA,el.PointB,el.PointC }
	elseif eltyp == "Square" or eltyp == "Image" then
		-- square and image are simple box check only 
		xmin = el.Position.X
		xmax = el.Position.X+el.Size.X
		ymin = el.Position.Y
		ymax = el.Position.Y+el.Size.Y
	elseif eltyp == "Text" then
		-- text is also simple box check only, but how to 
		-- get bounds differs from square/image 
		xmin = el.Center and el.Position.X-el.TextBounds.X/2 or el.Position.X
		xmax = el.Center and el.Position.X+el.TextBounds.X/2 or el.Position.X+el.TextBounds.X
		ymin = el.Position.Y
		ymax = el.Position.Y+el.TextBounds.Y
	elseif eltyp == "Quad" then
		-- get simple bounds for quad for quick check, point must be within this first 
		xmin = math.min(el.PointA.X,el.PointB.X,el.PointC.X,el.PointD.X)
		xmax = math.max(el.PointA.X,el.PointB.X,el.PointC.X,el.PointD.X)
		ymin = math.min(el.PointA.Y,el.PointB.Y,el.PointC.Y,el.PointD.Y)
		ymax = math.max(el.PointA.Y,el.PointB.Y,el.PointC.Y,el.PointD.Y)
		-- set points in array for deeper check, if simple check passes
		pnts = { el.PointA,el.PointB,el.PointC,el.PointD }
	elseif eltyp == "Circle" then
		-- set radius aside so we know to do distance check
		rad = el.Radius
		-- if point is within simple box check 
		xmin = el.Position.X-rad
		xmax = el.Position.X+rad
		ymin = el.Position.Y-rad
		ymax = el.Position.Y+rad
	end
	-- this is the quick check. 
	-- if point not within these general bounds, then it cannot be within drawing element
	local chk = point.X>=xmin and point.X<=xmax and point.Y>=ymin and point.Y<=ymax
	if chk and pnts then
		-- this is to check further for quads and tris
		-- will use test line from left of screen on X axis, at point's Y coord
		-- if intersection count is odd then point is within the shape, if 0 or even 
		-- then it means the point is outside the shape. 
		local lines = {}
		local last
		-- convert the points of the shape to lines ( table of {vector2,vector2} )
		for i,v in ipairs(pnts) do
			if last then table.insert(lines,{Vector2.new(last.X,last.Y),Vector2.new(v.X,v.Y)}) end
			last = v
		end
		-- since loop was on points, we need to make the last line to complete shape
		table.insert(lines,{Vector2.new(last.X,last.Y),Vector2.new(pnts[1].X,pnts[1].Y)})
		-- this is the test line going from -100 X which should be off screen 
		-- and going to the point, so using the point's Y value
		local test = {Vector2.new(-100,point.Y),Vector2.new(point.X,point.Y)}
		local hits = 0
		-- count the number of intersections for all the lines, with the test line
		for i,v in pairs(lines) do
			if LinesAreIntersecting(test[1],test[2],v[1],v[2])=="YES" then 
				hits = hits+1
			end
		end
		-- modulus 2 will say if 0/even or odd
		chk = hits%2~=0
	elseif chk and rad then
		-- this is to check for circles
		-- uses simple distance check on the point and center of circle
		-- if distance is equal or less than radius then it is within circle 
		-- sqrt is a costly operation, so we rely on simple check above first 
		local distSq = math.pow(math.max(el.Position.X,point.X)-math.min(el.Position.X,point.X),2) + -- a^2
					   math.pow(math.max(el.Position.Y,point.Y)-math.min(el.Position.Y,point.Y),2)	 -- b^2
		-- c^2 = a^2 + b^2, solving for c (distance)
		local dist = math.sqrt(distSq)
		chk = dist<=rad
	end
	return chk
end
function IsMouseWithinDrawingElement(el)
	local mloc = UserInputService:GetMouseLocation()
	return IsPointWithinDrawingElement(el,mloc)
end


--[[  ********************************************************
********************************************************
		TEST STUFF BELOW HERE 
		Draws some shapes and uses render stepped loop 
		to check if mouse hovering, when true color changes
********************************************************
	********************************************************]]
local RunService = game:GetService("RunService")
-- put it all in a global so we can cleanup if you run script again 
getgenv().TestUI = getgenv().TestUI or {}
local dbg = getgenv().TestUI
for i,v in pairs(dbg) do
	pcall(function() v.Visible = false end)
	pcall(function() v:Remove() end)
	pcall(function() dbg[i] = nil end)
end
-- function makes creating drawing little cleaner
function MakeDraw(obj, props)
	local tmpObj
	if (Drawing and obj and props and type(props) == "table") then
		tmpObj = Drawing.new(obj)
		for i, v in next, props do
			tmpObj[i] = v
		end
	end
	return tmpObj
end
-- setup the test UI
function SetupUI()
    -- just a black background to see shapes better on
	dbg.TestBack = dbg.TestBack or MakeDraw("Square",{
		Color = Color3.new(0,0,0),
		Transparency = 0.45,
		Size = Vector2.new(400,400),
		Visible = true,
		Filled = true
	})
    -- red triangle that will change to green when hovered, and brighter when clicked
    dbg.TestTri1 = dbg.TestTri1 or MakeDraw("Triangle",{
        Thickness = 2,
        Visible = true,
        Filled = true,
        Transparency=0.66
    })
    -- slanted quad that is magenta until hovered becomes cyan
	dbg.TestQuad1 = dbg.TestQuad1 or MakeDraw("Quad",{
		Thickness = 2,
		Visible = true,
		Filled = true,
		Transparency=0.66
	})
    -- 8 sided circle (so octagon lol) changes from orange to yellow when hovered
	dbg.TestCircle1 = dbg.TestCircle1 or MakeDraw("Circle",{
		Thickness = 2,
		Visible = true,
		Filled = true,
		Radius = 39,
		NumSides = 8,
		Transparency=0.66
	})
    -- 48 sided circle goes from green to blue when hovered
	dbg.TestCircle2 = dbg.TestCircle2 or MakeDraw("Circle",{
		Thickness = 2,
		Visible = true,
		Filled = true,
		Radius = 43,
		NumSides = 48,
		Transparency=0.66
	})
end

-- used to flag if mouse button is down
local clicked
-- function called on render stepped
function UpdateUI()
	-- viewport size
	local width,height = workspace.CurrentCamera.ViewportSize.X,workspace.CurrentCamera.ViewportSize.Y
	
	local tb = dbg.TestBack
    if tb then
	    tb.Position = Vector2.new(width/2+50,height/2+50)
    end
	
	local tt1 = dbg.TestTri1
    if tt1 then
        tt1.PointA = Vector2.new(width/2+255,height/2+133)
        tt1.PointB = Vector2.new(width/2+328,height/2+104)
        tt1.PointC = Vector2.new(width/2+269,height/2+177)
        -- is hover over this tri
        local tt1_h = IsMouseWithinDrawingElement(tt1)
        -- red until hover then green and brighter when clicked
        tt1.Color = clicked and tt1_h and Color3.new(0,1,0) or tt1_h and Color3.new(0,0.8,0) or Color3.new(0.8,0,0)
    end
	
	local tq1 = dbg.TestQuad1
    if tq1 then
        tq1.PointA = Vector2.new(width/2+225,height/2+183)
        tq1.PointB = Vector2.new(width/2+158,height/2+219)
        tq1.PointC = Vector2.new(width/2+281,height/2+294)
        tq1.PointD = Vector2.new(width/2+343,height/2+236)
        -- is hover over this quad
        local tq1_h = IsMouseWithinDrawingElement(tq1)
        -- magenta then cyan when hovered and brighter on click
        tq1.Color = clicked and tq1_h and Color3.new(0,1,1) or tq1_h and Color3.new(0,0.8,0.8) or Color3.new(0.8,0,0.8)
    end
	
	local tc1 = dbg.TestCircle1
    if tc1 then
        local tc1_h = IsMouseWithinDrawingElement(tc1)
        tc1.Position = Vector2.new(width/2+150,height/2+299)
        -- orange until hover then yellow and brighter on click
        tc1.Color = clicked and tc1_h and Color3.new(1,1,0) or tc1_h and Color3.new(0.85,0.85,0) or Color3.new(0.9,0.33,0)
    end
	
	local tc2 = dbg.TestCircle2
    if tc2 then
        local tc2_h = IsMouseWithinDrawingElement(tc2)
        tc2.Position = Vector2.new(width/2+350,height/2+319)
        -- green then blue on hover and brighter on click
        tc2.Color = clicked and tc2_h and Color3.new(0,0,1) or tc2_h and Color3.new(0,0,0.8) or Color3.new(0.33,0.77,0)
    end
end

function InitTestUI()
    -- create ui elements
    SetupUI()
    -- check if render stepped previously connected and disconnect if so
    if getgenv().TestUI_RenderLoop then
        pcall(function() getgenv().TestUI_RenderLoop:Disconnect() end)
        getgenv().TestUI_RenderLoop = nil
    end
    -- connect render stepped and store the connection in case script ran again
    getgenv().TestUI_RenderLoop = RunService.RenderStepped:Connect(function(deltaTime)
        UpdateUI()
    end)
    -- connect input began/ended and check if need to disconnect first 
    if getgenv().TestUI_InputBegan then
        pcall(function() getgenv().TestUI_InputBegan:Disconnect() end)
        getgenv().TestUI_InputBegan = nil
    end
    getgenv().TestUI_InputBegan = UserInputService.InputBegan:Connect(function(input,GPE)
        if not GPE and input.UserInputType == Enum.UserInputType.MouseButton1 then
            clicked = true -- user is clicking the left mouse button
        end
    end)
    if getgenv().TestUI_InputEnded then
        pcall(function() getgenv().TestUI_InputEnded:Disconnect() end)
        getgenv().TestUI_InputEnded = nil
    end
    getgenv().TestUI_InputEnded = UserInputService.InputEnded:Connect(function(input,GPE)
        if not GPE and input.UserInputType == Enum.UserInputType.MouseButton1 then
            clicked = false -- user has released the left mouse button
        end
    end)
end

InitTestUI()