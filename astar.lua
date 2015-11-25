--	A* algorithm for Lua by Ilya Kolbin ( iskolbin@gmail.com )
--	Uses binary heap for efficient open list handling
--	Dont use any recursion
--
--	Inputs: 
--		grid		-- 2D array with movement costs
--		x0 	
--		y0			-- begin coordinate
--		x1
--		y1			-- finish coordinate
--		kwargs -- additional arguments table (may be nil)
--			.heuristics(euclidean) -- heuristics function, distance estimation, predefined functions are
--			'dijkstra', 
--			'manhattan', 
--			'euclidean'
--			'chebyshev'
--		.neighbors(recthdp) -- generating neighbors for current node, predefined functions are
--			'tex'(triangular), 
--			'orto'(rectangular, 4 neighbors), 
--			'hex'(hexagonal), 
--			'rect'(rectangular, 8 neighbors), 
--			'rectndp'(rectangular, 8 neighbors, both orthogonal neighbors must be noninfinite),
--			'recthdp'(rectangular, 8 neighbors, one of orthogonal neighbors must be noinfinite),
--   	.weight(1)	-- heuristics function weight, high values make algorithm converge fast, 
--   								 but with suboptimal solution (for infinity it behaves exactly like greedy Best First Search),
--   								 for weight == 0 its Dijkstra algorithm
--   	.minx(1)
--   	.miny(1)
--   	.maxx(#grid)
--   	.maxy(#grid[1]) -- rectangle of path search (by default searches on whole grid)
--
--	Output:
--		generator returning pair of coordinates 	

local _heuristics = {
	dijkstra = function( dx, dy )
		return 0
	end,
	
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

local _neighbors = {
	tex = function( acc, x, y, grid, minx, miny, maxx, maxy )
		local i = 1
		if y > miny and ((x+y)%2 == 0) then i, acc[i], acc[i+1] = i+2, x, y-1 end
		if y < maxy and ((x+y)%2 == 1) then i, acc[i], acc[i+1] = i+2, x, y+1 end
		if x > minx then i, acc[i], acc[i+1] = i+2, x-1, y end
		if x < maxx then i, acc[i], acc[i+1] = i+2, x+1, y end
		return acc, i-1
	end,

	orto = function( acc, x, y, grid, minx, miny, maxx, maxy )
		local i = 1
		if y > miny then i, acc[i], acc[i+1] = i+2, x, y-1 end
		if y < maxy then i, acc[i], acc[i+1] = i+2, x, y+1 end
		if x > minx then i, acc[i], acc[i+1] = i+2, x-1, y end
		if x < maxx then i, acc[i], acc[i+1] = i+2, x+1, y end
		return acc, i-1
	end,

	hex = function( acc, x, y, grid, minx, miny, maxx, maxy )
		local i = 1
		if y > miny then i, acc[i], acc[i+1] = i+2, x, y-1 end
		if y < maxy then i, acc[i], acc[i+1] = i+2, x, y+1 end
		if x > minx then i, acc[i], acc[i+1] = i+2, x-1, y end
		if x < maxx then i, acc[i], acc[i+1] = i+2, x+1, y end 
		if x < maxx and y < maxy then i, acc[i], acc[i+1] = i+2, x+1, y+1 end
		if x > minx and y < maxy then i, acc[i], acc[i+1] = i+2, x-1, y+1 end
		return acc, i - 1
	end,
		
	rect = function( acc, x, y, grid, minx, miny, maxx, maxy )
		local i = 1
		if y > miny then i, acc[i], acc[i+1] = i+2, x, y-1 end
		if y < maxy then i, acc[i], acc[i+1] = i+2, x, y+1 end
		if x > minx then i, acc[i], acc[i+1] = i+2, x-1, y end 
		if x < maxx then i, acc[i], acc[i+1] = i+2, x+1, y end 
		if x < maxx and y < maxy then i, acc[i], acc[i+1] = i+2, x+1, y+1 end
		if x > minx and y < maxy then i, acc[i], acc[i+1] = i+2, x-1, y+1 end
		if x < maxx and y > miny then i, acc[i], acc[i+1] = i+2, x+1, y-1 end
		if x > minx and y > miny then i, acc[i], acc[i+1] = i+2, x-1, y-1 end
		return acc, i - 1
	end,

	rectndp = function( acc, x, y, grid, minx, miny, maxx, maxy )
		local i = 1
		if y > miny then i, acc[i], acc[i+1] = i+2, x, y-1 end  
		if y < maxy then i, acc[i], acc[i+1] = i+2, x, y+1 end 
		if x > minx then i, acc[i], acc[i+1] = i+2, x-1, y end
		if x < maxx then i, acc[i], acc[i+1] = i+2, x+1, y end
		if x < maxx and y < maxy and grid[x+1][y] ~= math.huge and grid[x][y+1] ~= math.huge then i, acc[i], acc[i+1] = i+2, x+1, y+1 end
		if x > minx and y < maxy and grid[x-1][y] ~= math.huge and grid[x][y+1] ~= math.huge then i, acc[i], acc[i+1] = i+2, x-1, y+1 end
		if x < maxx and y > miny and grid[x+1][y] ~= math.huge and grid[x][y-1] ~= math.huge then i, acc[i], acc[i+1] = i+2, x+1, y-1 end
		if x > minx and y > miny and grid[x-1][y] ~= math.huge and grid[x][y-1] ~= math.huge then i, acc[i], acc[i+1] = i+2, x-1, y-1 end
		return acc, i - 1
	end,

	recthdp = function( acc, x, y, grid, minx, miny, maxx, maxy )
		local i = 1
		if y > miny then i, acc[i], acc[i+1] = i+2, x, y-1 end 
		if y < maxy then i, acc[i], acc[i+1] = i+2, x, y+1 end 
		if x > minx then i, acc[i], acc[i+1] = i+2, x-1, y end 
		if x < maxx then i, acc[i], acc[i+1] = i+2, x+1, y end
		if x < maxx and y < maxy and (grid[x+1][y] ~= math.huge or grid[x][y+1] ~= math.huge) then i, acc[i], acc[i+1] = i+2, x+1, y+1 end
		if x > minx and y < maxy and (grid[x-1][y] ~= math.huge or grid[x][y+1] ~= math.huge) then i, acc[i], acc[i+1] = i+2, x-1, y+1 end
		if x < maxx and y > miny and (grid[x+1][y] ~= math.huge or grid[x][y-1] ~= math.huge) then i, acc[i], acc[i+1] = i+2, x+1, y-1 end
		if x > minx and y > miny and (grid[x-1][y] ~= math.huge or grid[x][y-1] ~= math.huge) then i, acc[i], acc[i+1] = i+2, x-1, y-1 end
		return acc, i - 1
	end,
}

return function( grid, x0, y0, x1, y1, kwargs )
	local kwargs = kwargs or {}
	local weight = kwargs.weight or 1
	local minx, miny, maxx, maxy = kwargs.minx or 1, kwargs.miny or 1, kwargs.maxx or #grid, kwargs.maxy or #grid[1]
	local heuristics
	local neighbors	
	
	if kwargs.heuristics then
		if type( kwargs.heuristics ) == 'function' then
			heuristics = kwargs.heuristics
		elseif _heuristics[kwargs.heuristics] then
			heuristics = _heuristics[kwargs.heuristics]
		else
			error( 'Cannot set heuristics to ' .. tostring(kwargs.heuristics) .. '. It should be function(dx,dy)->v or one of "dijkstra", "manhattan", "euclidean", "chebyshev"' )
		end
	else
		heuristics = _heuristics.euclidean
	end

	if kwargs.neighbors then
		if type( kwargs.neighbors ) == 'function' then
			neighbors = kwargs.neighbors
		elseif _neighbors[kwargs.neighbors] then
			neighbors = _neighbors[kwargs.neighbors]
		else
			error( 'Cannot set neighbors to ' .. tostring(kwargs.neighbors) .. '. It should be function(acc, x, y, grid, minx, miny, maxx, maxy)->acc,n or one of "tex", "hex", "rect", "rectndp", "recthdp"' )
		end
	else
		neighbors = _neighbors.recthdp
	end
	
	local close = {}
	local dx, dy = x1, y1
	local start = { 0, weight * heuristics( dx, dy ), false, x1, y1, }
	local open, size = {start}, 1
	local topush = {}
	local neighborsacc = {}

	while size > 0 do
		local current = open[1]
		open[1] = open[size]
		open[size] = nil
		size = size - 1

		local index, leftIndex, rightIndex = 1, 2, 3
		while leftIndex <= size do
			local smallerChild = leftIndex
			if rightIndex <= size and open[leftIndex][2] > open[rightIndex][2] then
				smallerChild = rightIndex
			end

			if open[index][2] > open[smallerChild][2] then
				open[index], open[smallerChild] = open[smallerChild], open[index]
			else
				break
			end

			index = smallerChild
			leftIndex = index + index
			rightIndex = leftIndex + 1
		end
		
		local x, y = current[4], current[5]

 		if x == x0 and y == y0 then
			local pred
			return function()
				if current then
					pred = current
					current = current[3]
					return pred[4], pred[5]
				end
			end
		end

		close[x] = close[x] or {}
		close[x][y] = current
		local g = current[1]
			
		local count = 0
		local nacc, n = neighbors( neighborsacc, x, y, grid, minx, miny, maxx, maxy )
		for i = 1, n, 2 do
			local x_, y_ = nacc[i], nacc[i+1]
			local g_ = g + grid[x_][y_]
				
			if g_ ~= math.huge then
				local next_ = close[x_] and close[x_][y_]
				local dx, dy = x0 - x_, y0 - y_
				if not next_ then
					count = count + 1; topush[count] = { g_, g_ + weight * heuristics( dx, dy ), current, x_, y_, }
				elseif g_ < next_[1] then
					next_[1], next_[2], next_[3] = g_, g_ + weight * heuristics( dx, dy ), current
					count = count + 1; topush[count] = next_
				end
			end
		end
		
		for i = 1, count do
			open[size + i] = topush[i]
		end

		size = size + count

		for index_ = math.floor( 0.5 * size ), 1, -1 do
			local index = index_
			local leftIndex = index + index
			local rightIndex = leftIndex + 1
			while leftIndex <= size do
				local smallerChild = leftIndex
				if rightIndex <= size and open[leftIndex][2] > open[rightIndex][2] then
					smallerChild = rightIndex
				end

				if open[index][2] > open[smallerChild][2] then
					open[index], open[smallerChild] = open[smallerChild], open[index]
				else
					break
				end

				index = smallerChild
				leftIndex = index + index
				rightIndex = leftIndex + 1
			end
		end
	end
end
