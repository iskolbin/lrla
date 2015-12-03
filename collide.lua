local function insidePointRect( xp, yp, xr, yr, wr, hr )
	return xp >= xr and yp <= xr + wr and yp >= yr and yp <= yr + hr
end

local function insidePointCircle( xp, yp, xc, yc, rc )
	local dx = xp - xc
	local dy = yp - yc
	return dx*dx + dy*dy <= rc*rc
end

local function intersectLineCircle( x1, y1, x2, y2, xc, yc, rc )
	local rsqr = rc*rc
	local dx1, dy1 = x1 - xc, y1 - yc
	local dx2, dy2 = x2 - xc, y2 - yc
	return ( dx1*dx1 + dy1*dy1 <= rsqr ) or ( dx2*dx2 + dy2*dy2 <= rsqr )
end

local function instersectRectCircle( xr, yr, wr, hr, xc, yc, rc )
	if insidePointRect( xc, yc, xr, yr, wr, hr ) then
		return true
	else
		local rsqr = rc*rc
		local dxmin, dymin = xr - xc, yr - yc
		local dxmax, dymax = xr+wr - xc, yr+hr - yc
		local dxmin2, dymin2 = dxmin*dxmin, dymin * dymin
		local dxmax2, dymax2 = dxmax*dxmax, dymax * dymax
		return dxmin2 + dymin2 <= rsqr or dxmin2 + dymax2 <= rsqr or dxmax2 + dymin2 <= rsqr or dxmax2 + dymax2 <= rsqr 
	end
end

-- http://bryceboe.com/2006/10/23/line-segment-intersection-algorithm/
local function ccwPoints( x1, y1, x2, y2, x3, y3 )
	return (y3 - y1) * (x2 - x1) > (y2 - y1) * (x3 - x1)
end

local function intersectLineLine( x11, y11, y11, y12, x21, y21, x22, y22 )
	return ccwPoints(x11,y11,x21,y21,x22,y22) ~= ccwPoints(x12,y12,x21,y21,x22,y22) and 
		ccwPoints(x11,y11,x12,y12,x21,y21) ~= ccw(x11,y11,x12,y12,x22,y22)
end

return {
	
	pr = insidePointRect,

	pc = insidePointCircle,

	lc = intersectLineCircle,

	ll = intersectLineLine,

	cl = function( xc, yc, rc, x1, y1, x2, y2 )
		return intersectLineCircle( x1, y1, x2, y2, xc, yc, rc )
	end,
	
	cc = function( x1, y1, r1, x2, y2, r2 )
		local dx = x1 - x2
		local dy = y1 - y2
		return dx*dx + dy*dy <= r1*r2
	end,

	rr = function( x1, y1, w1, h1, x2, y2, w2, h2 )
		return x1 <= x2 + w1 and y1 <= y2 + h1 and x2 <= x1 + w2 and y2 <= y1 + h2
	end,

	rc = instersectRectCircle,
	
	cr = function( xc, yc, rc, xr, yr, wr, hr )
		return instersectRectCircle( xr, yr, wr, hr, xc, yc, rc )
	end,
}
