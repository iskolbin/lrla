--	Shadowcasting algoritm for Lua by Ilya Kolbin ( iskolbin@gmail.com )
--	Converted from recursive shadowcasting ( see http://www.roguebasin.com/index.php?title=FOV_using_recursive_shadowcasting ) by Björn Bergström [bjorn.bergstrom@roguelikedevelopment.org]

--	Inputs:
--		grid	-- 2D array or obstacles
--		x0
--		y0		-- light source position
--		kwargs -- additional arguments (may be nil)
--			.power(1) -- power of light source
--			.decay(1/power) -- decay factor
--			.distance(euclidean)	-- function evaluating distance, predefined functions are
--				'manhattan',
--				'euclidean',
--				'chebyshev'
--			.minx,
--			.miny,
--			.maxx,
--			.maxy -- scrolling rectangle, by default whole grid is considered
--
--	Returns:
--		sparse 2D array of light values

local _heuristics = {
	manhattan = function( dx, dy )
		local absdx, absdy = dx > 0 and dx or -dx, dy > 0 and dy or -dy
		return absdx + absdy
	end,

	euclidean = function( dx, dy )
		return (dx*dx + dy*dy)^0.5
	end,

	chebyshev = function( dx, dy )
		local absdx, absdy = dx > 0 and dx or -dx, dy > 0 and dy or -dy
		return absdx > absdy and absdx or absdy
	end
}

local _topology = {
	rect = {
		{ 0,-1,-1, 0},
		{-1, 0, 0,-1},
		{ 0, 1,-1, 0},
		{ 1, 0, 0,-1},
		{ 0,-1, 1, 0},
		{-1, 0, 0, 1},
		{ 0, 1, 1, 0},
		{ 1, 0, 0, 1},
	}
}

return function( grid, x0, y0, kwargs_ )
	local kwargs = kwargs_ or {}
	local minx, miny = kwargs.minx or 1, kwargs.miny or 1
	local maxx, maxy = kwargs.maxx or #grid, kwargs.maxy or #grid[1]
	local radius = kwargs.power or 1
	local decay = kwargs.decay or 1/radius
	local light = {[x0] = {[y0] = radius}} -- light the starting cell
	local distance, topology

	if kwargs.distance then
		if type( kwargs.distance ) == 'function' then
			distance = kwargs.distance
		elseif _heuristics[kwargs.distance] then
			distance = _heuristics[kwargs.distance]
		else
			error( 'Cannot set distance heuristics to ' .. tostring(kwargs.distance) .. '. It should be function(dx,dy) or one of "manhattan", "euclidean", "chebyshev"' )
		end
	else
		distance = _heuristics.euclidean
	end

	if kwargs.topology then
		if type( kwargs.topology ) == 'table' then
			topology = kwargs.topology
		elseif _topology[kwargs.topology] then
			topology = _topology[kwargs.topology]
		else
			error( 'Cannot set topology to ' .. tostring(kwargs.topology) .. '. It should be table or "rect"' )
		end
	else
		topology = _topology['rect']
	end

	local stack = {}

	for i = 1, #topology do
		local xxyy = topology[i]
		local xx, xy, yx, yy = xxyy[1], xxyy[2], xxyy[3], xxyy[4]
		
		local n = 3
		stack[1], stack[2], stack[3] = 1, 1, 0
	
		while n > 0 do
			local row, start, finish = stack[n-2], stack[n-1], stack[n]
			n = n - 3

			if start >= finish then
				local newStart = 0
				local blocked = false
				for dy = -row, -radius, -1 do
					if blocked then 
						break 
					end
				
					local invdy05add = 1 / (dy + 0.5)
					local invdy05sub = 1 / (dy - 0.5)
					local leftSlope  = (dy - 1.5) * invdy05add --(dx - 0.5) / (dy + 0.5)
					local rightSlope = (dy - 0.5) * invdy05sub --(dx + 0.5) / (dy - 0.5)
					
					for dx = dy, 0 do
						local x = x0
						if xx == 1 then
							x = x + dx
						elseif xx == -1 then
							x = x - dx
						end
						if xy == 1 then
							x = x + dy
						elseif xy == -1 then
							x = x - dy
						end

						local y = y0
						if yx == 1 then
							y = y + dx
						elseif yx == -1 then
							y = y - dx
						end
						if yy == 1 then
							y = y + dy
						elseif yy == -1 then
							y = y - dy
						end
					
						leftSlope  = leftSlope  + invdy05add
						rightSlope = rightSlope + invdy05sub
					
						if (x >= minx and y >= miny and x <= maxx and y <= maxy) and start >= rightSlope then
							if finish > leftSlope then
								break
							else
								-- check if it's within the lightable area and light if needed
								local radius_ = distance( dx, dy )
								if radius_ <= radius then
									local bright = 1.0 - decay * radius_
									light[x] = light[x] or {}
									light[x][y] = bright
								end
				 
								if blocked then -- previous cell was a blocking one
									if grid[x][y] >= 1 then -- hit a wall
										newStart = rightSlope
									else
										blocked = false
										start = newStart
									end
							
								elseif grid[x][y] >= 1 and -dy < radius then -- hit a wall within sight line
									blocked = true
									n = n + 3
									stack[n-2], stack[n-1], stack[n] = -dy + 1, start, leftSlope
									newStart = rightSlope
								end
							end
						end
					end
				end
			end
		end
	end
	return light
end
