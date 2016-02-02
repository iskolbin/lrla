--	Bresenham's line algorithm by Ilya Kolbin ( iskolbin@gmail.com )
--	https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm

-- Used for fast line drawing or for line of sight algorithms

--	Inputs:
--		x1
--		y1 -- start point coordinates
--		x2
--		y2 -- finish point coordinates
--		f(coolect) -- plotting function(x,y,index), which returns tuple of (boolean,result), where boolean used for halting plot
--
--	Returns:
--		result of plotting function, by default it returns table of points

local function collect()
	local t = {}
	return function( x, y, k )
		t[k] = {x, y}
		return true, t
	end
end

return function( x1, y1, x2, y2, f_ )
	local k, f = 0, f_ or collect()
	local ok, result

	if x1 == x2 then
		for y = y1, y2 do
			k = k + 1
			ok, result = f( x1, y, k )
			if not ok then
				return result
			end
		end
	elseif y1 == y2 then
		for x = x1, x2 do
			k = k + 1
			ok, result = f( x, y1, k )
			if not ok then
				return result
			end
		end
	else
		local dx, dy = x2 - x1, y2 - y1
		dx, dy = dx > 0 and dx or -dx, dy > 0 and dy or -dy
		local err = 0
		local derr = dy
		local y = y1
		for x = x1, x2 do
			k = k + 1
			ok, result = f( x, y, k )
			if not ok then
				return result
			end
			err = err + derr
			if err + err >= dx then
				y = y + 1
				err = err - dx
			end
		end 
	end
	
	return result
end
