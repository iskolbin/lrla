-- ASCII grid utility for Lua by Ilya Kolbin ( iskolbin@gmail.com )

-- Example usage:
--local kwargs = asciigrid.addcodes{ invertY = true, indexXY = true,
	--['#'] = 1.0,
	--['^'] = 0.2,
	--['v'] = 0.4,
	--['0'] = 0.5,
	--['T'] = 0.7,
	--['.'] = 0.0,
--}

--local s = [[
--####.....###.#####....#####
--..#........................
--...........................
--.....##.........vvv........
--....#.......#..............
--..................TT.......
--.......^^..................
--.....T..0......0.00........]]

--local grid = asciigrid.decode( s, kwargs )
--print( asciigrid.encode( asciigrid.decode(s, kwargs ), kwargs ) == s)

local function split( str, delim )
	local result, pat, lastPos = {}, "(.-)" .. (delim or '[\n\r]') .. "()", 1
	for part, pos in str:gmatch( pat ) do
		result[#result+1] = part
		lastPos = pos
	end
	result[#result+1] = str:sub( lastPos )
	return result
end

local asciigrid = {
	new = function( width, height, fill )
		local grid = {}
		for i = 1, width do
			grid[i] = {}
			for j = 1, height do
				grid[i][j] = fill or false
			end
		end
		return grid
	end,
	
	decode = function( str, kwargs )
		local ss = split( str )
		
		local nrows = #ss
		local ncols = #ss[1]
		local grid = {}
		
		local invertY, indexXY = kwargs.invertY, kwargs.indexXY
		
		if indexXY then
			for i = 1, ncols do
				grid[i] = {}
			end
		else
			for i = 1, nrows do
				grid[i] = {}
			end
		end
		
		if indexXY and invertY then
			for y = 1, nrows do for x = 1, ncols do
				grid[x][nrows-y+1] = kwargs[ss[y]:sub(x,x)]
			end end
		
		elseif indexXY and not invertY then
			for y = 1, nrows do for x = 1, ncols do
				grid[x][y] = kwargs[ss[y]:sub(x,x)]
			end end
		
		elseif not indexXY and invertY then
			for y = 1, nrows do for x = 1, ncols do
				grid[nrows-y+1][x] = kwargs[ss[y]:sub(x,x)]
			end end
		
		elseif not indexXY and not invertY then
			for y = 1, nrows do for x = 1, ncols do
				grid[y][x] = kwargs[ss[y]:sub(x,x)]
			end end
		end

		return grid
	end,
	
	encode = function( grid, kwargs )
		local n, m = #grid, #grid[1]
		local invertY, indexXY = kwargs.invertY, kwargs.indexXY
		local buffer = {}
		local tconcat = table.concat
		
		if kwargs.indexXY then
			if kwargs.invertY then
				for y = 1, m do
					local b = {}; for x = 1, n do b[x] = kwargs[grid[x][m-y+1]] end
					buffer[y] = tconcat( b )
				end
			else
				for y = 1, m do
					local b = {}; for x = 1, n do b[x] = kwargs[grid[x][y]] end
					buffer[y] = tconcat( b )
				end
			end
		else
			if kwargs.invertY then
				for y = 1, n do
					local b = {}; for x = 1, m do b[x] = kwargs[grid[n-y+1][x]] end
					buffer[y] = tconcat( b )
				end
			else
				for y = 1, n do
					local b = {}; for x = 1, m do b[x] = kwargs[grid[y][x]] end
					buffer[y] = tconcat( b )
				end
			end
		end
		
		return tconcat( buffer, kwargs.lineSeparator or '\n' )
	end,
	
	addcodes = function( kwargs )
		local t = {}
		for k, v in pairs( kwargs ) do t[v] = k end
		for k, v in pairs( t ) do kwargs[k] = v end
		return kwargs
	end,
	
	copygrid = function( grid, fill )
		local newgrid = {}
		if type( fill ) == 'function' then
			for i = 1, #grid do 
				newgrid[i] = {}
				for j = 1, #grid[i] do
					newgrid[i][j] = fill( grid[i][j] )
				end
			end
		elseif type( fill ) == 'nil' then
			for i = 1, #grid do 
				newgrid[i] = {}
				for j = 1, #grid[i] do
					newgrid[i][j] = grid[i][j]
				end
			end
		else
			for i = 1, #grid do 
				newgrid[i] = {}
				for j = 1, #grid[i] do
					newgrid[i][j] = fill
				end
			end
		end
		
		return newgrid
	end,
}


return asciigrid
