-- Xiaolin Wu's line algorithm by Ilya Kolbin ( iskolbin@gmail.com )
-- https://en.wikipedia.org/wiki/Xiaolin_Wu%27s_line_algorithm

-- Used for antialiased line drawing or for fine-grained line of sight algorithms

--	Inputs:
--		x1
--		y1 -- start point coordinates
--		x2
--		y2 -- finish point coordinates
--		f(collect) -- plotting function(x,y,v,index), which returns tuple of (boolean,result), where boolean used for halting plot
--
--	Returns:
--		result of plotting function, by default it returns table of points

local function collect()
	local t = {}
	return function( x, y, v, k )
		t[k] = {x, y, v}
		return true, t
	end
end

return function( x1, y1, x2, y2, f_ )
	local k, f = 0, f_ or collect()
	local ok, result

	if x2 < x1 then
		x1, x2 = x2, x1
		y1, y2 = y2, y1
	end
			
	if x1 == x2 then
		for y = y1, y2 do
			k = k + 1
			ok, result = f( x1, y, 1, k )
			if not ok then 
				return result 
			end
		end
	elseif y1 == y2 then
		for x = x1, x2 do
			k = k + 1
			ok, result = f( x, y1, 1, k ) 
			if not ok then 
				return result
			end
		end
	else
		local dx, dy = x2 - x1, y2 - y1
		local floor = math.floor
		local gradient = dy / dx
		local xend = floor( x1 + 0.5 )
		local yend = y1 + gradient * ( xend - x1 )
		local xpxl1, ypxl1 = xend, floor( yend ) 
		local xgap = 0.5 - ( x1 - xend )
		
		local temp = (yend - ypxl1)*xgap 
		
		ok, result = f( xpxl1, ypxl1, 1 - temp, k )
		if not ok then 
			return result
		end
		
		ok, result = f( xpxl1, ypxl1 + 1, temp, k )
		if not ok then 
			return result
		end
		
		local intery = yend + gradient
		
		xend = floor( x2 + 0.5 )
		yend = y2 + gradient * (xend - x2)
		xgap = x2 + 0.5 - xend
		
		local xpxl2 = xend
		local ypxl2 = floor( yend )
		
		k = 2
		for x = xpxl1 + 1, xpxl2 - 1 do
			local ipart_intery = floor( intery )
			local fpart_intery = intery - ipart_intery
			
			k = k + 1
			ok, result = f( x, ipart_intery, 1 - fpart_intery, k )
			if not ok then 
				return result
			end
			
			k = k + 1
			ok, result = f( x, ipart_intery + 1, fpart_intery, k )
			if not ok then 
				return result 
			end

			intery = intery + gradient
		end
		
		temp = (yend - floor( yend )) * xgap
		
		k = k + 1
		ok, result = f( xpxl2, ypxl2, 1 - temp, k )
		if not ok then
			return result
		end

		k = k + 1
		ok, result = f( xpxl2, ypxl2 + 1, temp, k)
		if not ok then 
			return result 
		end
	end
	
	return result
end
